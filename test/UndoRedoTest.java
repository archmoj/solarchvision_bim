import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// Covers undoRedo.pde: seedModel3DHistory()/beginUndoableEdit()/
// commitUndoableEdit() (hooked into beginModel3DChange()/endModel3DChange()),
// undo()/redo(), and restoreProjectSnapshot()'s own behavior (viewport
// left alone, no recursive recording, selection clamped to the restored
// data). Same setup SaveProjectTest.java uses -
// buildProjectSnapshot()/parse_XML_variables() reach the same 25+
// classes' to_XML()/from_XML() that saveProject()/load_project() do.
//
// No frameCount simulation anywhere in this file, unlike the previous
// version - coalescing a composite action (several nested
// beginModel3DChange()/endModel3DChange() pairs) into one history entry is
// now a property of model3DChangeDepth itself, not something that needs a
// stand-in for draw()'s own frame loop to exercise.
class UndoRedoTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws IOException {
    app = new solarchvision_bim();
    app.Terrain.Mesh = new float[app.Terrain.rowCount][app.Terrain.columnCount][3];
    app.BaseFolder = Files.createTempDirectory("solarchvision-bim-undoredo-test").toString();
    app.sketchPath(); // see SaveProjectTest.java's own comment on why this is needed before any loadImage()/loadStrings()/createInput()
    app.update_project_folders();
  }

  // A bare `new solarchvision_bim()` never runs drawInitialFrames.pde's
  // frame-22 branch (that's gated on the real Processing draw loop), so
  // seedModel3DHistory() - the one thing that actually establishes the
  // baseline - needs calling explicitly here, same as any other
  // startup-only step the other test files already work around.
  private void seed () {
    app.seedModel3DHistory();
  }

  // A minimal "one edit happened" pair for tests that only care about
  // the undo/redo bookkeeping itself (history size, historyIndex, the
  // reentrancy guard, ...), not any particular mutation.
  private void simulateEdit () {
    app.beginModel3DChange();
    app.endModel3DChange();
  }

  // Builds one real triangle (a face, inside a new group) the same way
  // SaveProjectTest.java's own fetchProject round-trip test does, then
  // deletes it - a small but genuine "add something, remove it" edit
  // pair to drive the integration-style tests below.
  //
  // import_objects_OBJ() is a low-level primitive that deliberately
  // never calls beginModel3DChange()/endModel3DChange() itself (see
  // fileSelected.pde's own comment on its real call site) - every real
  // caller is responsible for wrapping it, which is mirrored here so
  // this helper records a step the same way an actual OBJ import does.
  private void createOneFaceViaImport () throws IOException {
    app.beginModel3DChange();
    Path objFile = Files.createTempFile("undo-redo-test", ".obj");
    Files.writeString(objFile, "g triangle\nv 0 0 0\nv 1 0 0\nv 1 1 0\nf 1 2 3\n");
    app.import_objects_OBJ(objFile.toString(), 5, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);
    app.endModel3DChange();
  }

  private void deleteTheOneFace () {
    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.faceSelection = new int[]{0};
    app.Delete3D.selection(); // wraps its own several sub-steps in beginModel3DChange()/endModel3DChange() now - see delete3D.pde's own comment
  }

  // ================= seedModel3DHistory ====================================

  @Test
  void seedModel3DHistory_establishesASingleBaselineEntry () {
    seed();

    assertEquals(1, app.model3DHistory.size());
    assertEquals(0, app.model3DHistoryIndex);
  }

  @Test
  void seedModel3DHistory_calledAgainResetsToANewSingleEntryBaseline () {
    seed();
    simulateEdit(); // a second entry
    assertEquals(2, app.model3DHistory.size());

    seed(); // e.g. "New" or opening a different project, conceptually

    assertEquals(1, app.model3DHistory.size());
    assertEquals(0, app.model3DHistoryIndex);
  }

  // ================= beginUndoableEdit/commitUndoableEdit ================

  @Test
  void beginModel3DChange_beforeseedModel3DHistoryHasRun_recordsNothing () {
    assertEquals(-1, app.model3DHistoryIndex); // sanity check: seed() was never called

    simulateEdit();

    assertEquals(0, app.model3DHistory.size());
    assertEquals(-1, app.model3DHistoryIndex);
  }

  @Test
  void endModel3DChange_appendsANewStepAndAdvancesHistoryIndex () {
    seed();

    simulateEdit();

    assertEquals(2, app.model3DHistory.size());
    assertEquals(1, app.model3DHistoryIndex);
  }

  @Test
  void beginModel3DChange_whileisRestoringModel3DSnapshotIsSet_recordsNothing () {
    // Exercises the reentrancy guard directly rather than only through
    // a real restore - see isRestoringModel3DSnapshot's own comment on why
    // parse_XML_variables() needs this (several classes' from_XML()
    // calls beginModel3DChange()/endModel3DChange() by way of makeEmpty()).
    seed();
    app.isRestoringModel3DSnapshot = true;

    simulateEdit();

    assertEquals(1, app.model3DHistory.size());
    assertEquals(0, app.model3DHistoryIndex);
  }

  @Test
  void endModel3DChange_afterAnUndo_discardsTheRedoBranchBeforeAppending () {
    seed();          // history[0]
    simulateEdit();  // history[1]
    simulateEdit();  // history[2]
    assertEquals(3, app.model3DHistory.size());

    app.undoModel3DChange(); // historyIndex -> 1, history[2] still sitting there as a redo target

    simulateEdit(); // a fresh edit - history[2] (the old redo branch) must be gone, replaced by this new one

    assertEquals(3, app.model3DHistory.size());
    assertEquals(2, app.model3DHistoryIndex);
  }

  @Test
  void nestedBeginEndPairs_coalesceIntoOneEntryInsteadOfOnePerInnerPair () {
    // The actual bug this covers: Delete3D.selection() calls its own
    // several sub-steps (faceSelection(), then separately
    // isolatedVertices_Selection()), each already wrapped in their own
    // beginModel3DChange()/endModel3DChange() pair - without the OUTER
    // composite also wrapping the whole sequence, each inner pair would
    // independently record its own step, and a single "Delete" (one
    // user-facing action) would need two undos to fully reverse. This
    // exercises the mechanism directly, isolated from Delete3D itself:
    // an outer pair wrapping two inner pairs still only records once.
    seed(); // history[0]

    app.beginModel3DChange(); // depth 0 -> 1 - the outer, composite action
    app.beginModel3DChange(); // depth 1 -> 2 - first inner sub-step - should be a no-op for the history
    app.endModel3DChange();   // depth 2 -> 1
    app.beginModel3DChange(); // depth 1 -> 2 - second inner sub-step - also a no-op
    app.endModel3DChange();   // depth 2 -> 1
    app.endModel3DChange();   // depth 1 -> 0 - only this transition actually records

    assertEquals(2, app.model3DHistory.size(), "the whole nested sequence should record as exactly one step");
    assertEquals(1, app.model3DHistoryIndex);
  }

  @Test
  void endModel3DChange_withAStrayCallAndNoMatchingBegin_doesNotGoNegativeOrBreakLaterPairing () {
    // See endModel3DChange()'s own comment: a call site that was only
    // mechanically renamed (model_changed() -> endModel3DChange()),
    // without yet getting its own beginModel3DChange(), must not
    // permanently wedge model3DChangeDepth for every later, properly
    // paired edit in the same session. The stray call itself still
    // records a step (model3DChangeDepth genuinely does return to 0, and
    // commitUndoableEdit() can't tell "a real edit whose begin() got
    // missed" apart from "truly nothing happened" - this is the same
    // safe degradation to the old post-edit-only behavior that every
    // not-yet-converted call site elsewhere in the app currently gets) -
    // what actually matters here is only that model3DChangeDepth itself
    // comes back to a clean 0, not negative, so every LATER properly
    // paired edit keeps working normally afterward.
    seed();

    app.endModel3DChange(); // stray - no matching begin
    assertEquals(0, app.model3DChangeDepth, "should clamp at 0, not go negative");
    assertEquals(2, app.model3DHistory.size(), "the stray call still closes out and records a step - that's expected, not what's under test here");

    simulateEdit(); // a normal, correctly paired edit afterward

    assertEquals(3, app.model3DHistory.size(), "the stray call shouldn't have broken this one recording normally");
    assertEquals(2, app.model3DHistoryIndex);
  }

  @Test
  void endModel3DChange_boundsHistoryToMaxUndoSteps () {
    seed();

    for (int i = 0; i < app.MAX_UNDO_MODEL3D + 10; i++) {
      simulateEdit();
    }

    assertTrue(app.model3DHistory.size() <= app.MAX_UNDO_MODEL3D + 1, "expected the list to be capped, was " + app.model3DHistory.size());
    assertEquals(app.model3DHistory.size() - 1, app.model3DHistoryIndex, "historyIndex should still point at the newest entry after trimming");
  }

  // ================= undo / redo =========================================

  @Test
  void undo_atTheBaseline_doesNothing () {
    seed();

    app.undoModel3DChange();

    assertEquals(0, app.model3DHistoryIndex);
    assertEquals(1, app.model3DHistory.size());
  }

  @Test
  void redo_atTheNewestEntry_doesNothing () {
    seed();
    simulateEdit();

    app.redoModel3DChange();

    assertEquals(1, app.model3DHistoryIndex);
  }

  @Test
  void undo_movesHistoryIndexBackOneStep () {
    seed();
    simulateEdit();
    simulateEdit();
    assertEquals(2, app.model3DHistoryIndex);

    app.undoModel3DChange();

    assertEquals(1, app.model3DHistoryIndex);
  }

  @Test
  void redo_movesHistoryIndexForwardOneStepAfterAnUndo () {
    seed();
    simulateEdit();
    simulateEdit();
    app.undoModel3DChange();
    assertEquals(1, app.model3DHistoryIndex);

    app.redoModel3DChange();

    assertEquals(2, app.model3DHistoryIndex);
  }

  // ================= restoreProjectSnapshot: what it does and doesn't touch

  @Test
  void restoreProjectSnapshot_neverRecursesIntoCommitUndoableEdit () {
    // parse_XML_variables() reaches beginModel3DChange()/endModel3DChange()
    // close to nine times on its own (Faces/Model1Ds/Model2Ds/Solids/
    // Polylines/Points/Cameras/Sections/Groups' from_XML() ->
    // makeEmpty()) - without isRestoringModel3DSnapshot, each of those would
    // append its own spurious entry and the two asserts below would
    // both fail.
    seed();
    simulateEdit();
    int historySizeBeforeUndo = app.model3DHistory.size();

    app.undoModel3DChange();

    assertEquals(historySizeBeforeUndo, app.model3DHistory.size(), "a restore must not append new history entries");
    assertFalse(app.isRestoringModel3DSnapshot, "the guard must be cleared again once the restore finishes");
  }

  @Test
  void restoreProjectSnapshot_leavesTheCurrentCameraPositionUntouched () {
    seed(); // baseline captured with camera at its default position

    app.WIN3D.cameraX = 123;
    simulateEdit(); // a modeling edit, unrelated to the camera move above - still captures cameraX=123 into this step's own snapshot

    app.WIN3D.cameraX = 999; // the user navigates after that edit, not going through beginModel3DChange()/endModel3DChange()

    app.undoModel3DChange(); // back to the baseline

    assertEquals(999f, app.WIN3D.cameraX, 0.0001f, "undo must leave the viewport exactly where the user left it");
  }

  @Test
  void restoreProjectSnapshot_clampsSelectionsThatNoLongerFitTheRestoredData () throws IOException {
    seed(); // baseline: no faces at all
    createOneFaceViaImport(); // records exactly one step - history is now [baseline, one-face]

    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.faceSelection = new int[]{0}; // valid right now, against the one imported face

    app.undoModel3DChange(); // back to the baseline - zero faces - without Select3D.clampSelectionsToCurrentData() this selection would now be stale

    assertEquals(0, app.Select3D.faceSelection.length);
  }

  // ================= end-to-end: the originally reported scenario =======

  @Test
  void addThenDeleteThenUndo_bringsTheDeletedGeometryBack () throws IOException {
    seed();

    createOneFaceViaImport();
    assertEquals(1, app.allFaces.nodes.length, "setup check");

    deleteTheOneFace();
    assertEquals(0, app.allFaces.nodes.length, "setup check");

    app.undoModel3DChange();

    assertEquals(1, app.allFaces.nodes.length);
  }

  @Test
  void addThenDeleteThenUndoThenRedo_deletesItAgain () throws IOException {
    seed();

    createOneFaceViaImport();
    deleteTheOneFace();
    app.undoModel3DChange();
    assertEquals(1, app.allFaces.nodes.length, "setup check");

    app.redoModel3DChange();

    assertEquals(0, app.allFaces.nodes.length);
  }

  @Test
  void undoTwiceThenRedoTwice_roundTripsBackToTheSameState () throws IOException {
    seed();                              // step 0: nothing
    createOneFaceViaImport();            // step 1: one face
    deleteTheOneFace();                  // step 2: no faces again

    app.undoModel3DChange();
    app.undoModel3DChange();
    assertEquals(0, app.model3DHistoryIndex);
    assertEquals(0, app.allFaces.nodes.length);

    app.redoModel3DChange();
    assertEquals(1, app.allFaces.nodes.length);

    app.redoModel3DChange();
    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(2, app.model3DHistoryIndex);
  }

  @Test
  void deleteThroughDeleteSelection_recordsExactlyOneStepNotTwo () throws IOException {
    // Delete3D.selection() internally calls faceSelection() AND,
    // separately, isolatedVertices_Selection() for FACE category - this
    // confirms the whole thing still coalesces into one history entry
    // (via Delete3D.selection()'s own beginModel3DChange()/endModel3DChange()
    // wrapping, not a stand-in for it), not two.
    seed();                    // history[0]
    createOneFaceViaImport();  // history[1]
    int sizeBeforeDelete = app.model3DHistory.size();

    deleteTheOneFace();

    assertEquals(sizeBeforeDelete + 1, app.model3DHistory.size(), "one delete, through Delete3D.selection(), should record exactly one new entry");
  }

  // ================= the previously-reported selection bug ===============

  @Test
  void undo_restoresTheSelectionAsItWasRightBeforeTheNextEditNotWhenTheEntryWasFirstRecorded () throws IOException {
    // Reproduces the originally reported scenario: build something
    // (whatever gets auto-selected the moment it's built is irrelevant
    // and deliberately left in place here, as face 0), manually select
    // something else afterward (a pure selection change - no
    // beginModel3DChange()/endModel3DChange() pair, so no new history entry
    // gets recorded for it), then delete that. Undoing the delete should
    // bring back what was manually selected right before the delete
    // (face 1), not whatever was selected back when the three-face step
    // was itself first recorded (face 0) - the original report: "insert
    // parallel openings, select the middle one, delete it, undo - the
    // wrong face ends up selected".
    //
    // Under the current design this is exact, not frame-approximated:
    // deleteTheOneFace()'s own beginModel3DChange() call (inside
    // Delete3D.selection(), before anything it does mutates the model)
    // is what refreshes history[historyIndex] with whatever is actually
    // selected at that precise moment.
    seed();

    Path objFile = Files.createTempFile("undo-redo-selection-test", ".obj");
    Files.writeString(objFile,
      "g three_faces\n" +
      "v 0 0 0\nv 1 0 0\nv 1 1 0\n" +
      "v 2 0 0\nv 3 0 0\nv 3 1 0\n" +
      "v 4 0 0\nv 5 0 0\nv 5 1 0\n" +
      "f 1 2 3\nf 4 5 6\nf 7 8 9\n");
    app.beginModel3DChange();
    app.import_objects_OBJ(objFile.toString(), 5, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);
    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.faceSelection = new int[]{0}; // whatever the "modifier" itself left selected
    app.endModel3DChange(); // records the three-face step, with face 0 selected at this exact moment

    // The user manually selects the middle face afterward - deliberately
    // not going through beginModel3DChange()/endModel3DChange().
    app.Select3D.faceSelection = new int[]{1};

    app.Delete3D.selection(); // deletes the (manually, correctly) selected middle face - its own beginModel3DChange() refreshes history[historyIndex] with faceSelection=[1] first
    assertEquals(2, app.allFaces.nodes.length, "setup check");

    app.undoModel3DChange();

    assertEquals(3, app.allFaces.nodes.length, "setup check");
    assertArrayEquals(new int[]{1}, app.Select3D.faceSelection,
      "should restore face 1 (manually selected right before the delete), not face 0 (selected when the three-face step was first recorded)");
  }

  // ================= move3D/rotate3D/scale3D: this step's conversion ====

  @Test
  void moveFaces_isUndoable () throws IOException {
    // Move3D.selection() is a pure mutually-exclusive dispatcher (one
    // "else if" chain, unlike Delete3D.selection()) - each sub-method
    // (Faces() here) already represents exactly one discrete edit on its
    // own, so it needed its own beginModel3DChange() but selection() itself
    // doesn't need any wrapping of its own.
    seed();
    createOneFaceViaImport();

    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.faceSelection = new int[]{0};
    float xBefore = app.allPoints.getX(0);

    app.Move3D.selection(10, 0, 0);
    assertEquals(xBefore + 10, app.allPoints.getX(0), 0.0001f, "setup check");

    app.undoModel3DChange();

    assertEquals(xBefore, app.allPoints.getX(0), 0.0001f);
  }

  @Test
  void scaleModel2Ds_isUndoable () {
    seed();

    app.beginModel3DChange(); // before the mutation, so the baseline (no Model2Ds) is what history[0] ends up holding
    app.allModel2Ds.XYZS = new float[][]{{10, 0, 0, 2}};
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.TREES_KIND};
    app.allModel2Ds.FileIndex = new int[]{1};
    app.allModel2Ds.Mirror = new boolean[]{false};
    app.allModel2Ds.num = 1;
    app.endModel3DChange(); // records this setup as its own step, so undo below has somewhere to land

    app.currentObjectCategory = app.ObjectCategory.MODEL2D;
    app.Select3D.model2DSelection = new int[]{0};

    app.Scale3D.selection(0, 0, 0, 2, 2, 2);
    assertEquals(4f, app.allModel2Ds.getS(0), 0.0001f, "setup check");

    app.undoModel3DChange();

    assertEquals(2f, app.allModel2Ds.getS(0), 0.0001f);
  }

  // ================= react.pde: this step's conversion ===================

  @Test
  void applyPosValue_spinnerDrivenMove_recordsExactlyOneStepNotTwo () throws IOException {
    // react.applyPosValue used to call endModel3DChange() itself AFTER
    // calling Move3D.selection() - which (since the move3D/rotate3D/
    // scale3D step) already fully handles its own beginModel3DChange()/
    // endModel3DChange() pair internally. That trailing call is now
    // removed (see react.pde's own comment on why it had become
    // redundant, not just harmlessly repeated like it used to be before
    // endModel3DChange() carried any undo-recording side effect of its
    // own). This confirms one spinner-driven move still records as
    // exactly one step, not two.
    seed();
    createOneFaceViaImport();
    int sizeBeforeMove = app.model3DHistory.size();

    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.faceSelection = new int[]{0};
    app.Select3D.positionVectorIndex = 0; // X axis
    float xBefore = app.allPoints.getX(0);

    app.react.applyPosValue.run(0, 10); // old=0, new=10 -> delta=10 along X

    assertEquals(xBefore + 10, app.allPoints.getX(0), 0.0001f, "setup check");
    assertEquals(sizeBeforeMove + 1, app.model3DHistory.size(), "one spinner-driven move should record exactly one new entry, not two");
  }

  // ================= viewport3D.pde: this step's conversion ==============

  @Test
  void incrementParameterMove_keyboardNudge_recordsExactlyOneStepNotTwo () throws IOException {
    // WIN3D.incrementParameter() is the keyboard-nudge equivalent of
    // react.pde's applyPosValue/applyRotValue/applyScaleValue - same
    // redundant-trailing-call issue, same fix: Move3D.selection() (and
    // its Rotate3D/Scale3D siblings) already wrap their own
    // beginModel3DChange()/endModel3DChange() pair, so incrementParameter()
    // no longer calls it again itself for those three tools.
    seed();
    createOneFaceViaImport();
    int sizeBefore = app.model3DHistory.size();

    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.faceSelection = new int[]{0};
    app.Select3D.positionVectorIndex = 0; // X axis
    float xBefore = app.allPoints.getX(0);

    app.WIN3D.currentTool = app.UITASK.Move;
    app.WIN3D.incrementParameter(1); // one nudge, dx = 0.5 * 1 = 0.5

    assertEquals(xBefore + 0.5f, app.allPoints.getX(0), 0.0001f, "setup check");
    assertEquals(sizeBefore + 1, app.model3DHistory.size(), "one keyboard nudge should record exactly one new entry, not two");
  }

  // ================= deleteAll()/load_project(): this step's fixes ======

  @Test
  void deleteAll_recordsExactlyOneStepNotNinePerMakeEmptyCall () throws IOException {
    // deleteAll() ("New") calls nine different classes' own makeEmpty() -
    // each now its own complete beginModel3DChange()/endModel3DChange() pair
    // (Faces/Model1Ds/Model2Ds/Solids/Polylines/Points/Cameras/Sections/
    // Groups) - without deleteAll() ALSO wrapping the whole sequence in
    // its own pair, each of those nine would have independently recorded
    // its own history entry.
    seed();
    createOneFaceViaImport(); // something to actually delete, so this isn't a no-op
    int sizeBeforeDeleteAll = app.model3DHistory.size();

    app.deleteAll();

    // deleteAll() also reseeds the history (see its own comment) - so
    // rather than asserting an exact size here (which seeding resets
    // outright), this confirms the seed left exactly the one fresh
    // baseline entry it always does, not nine-plus-whatever-came-before.
    assertEquals(1, app.model3DHistory.size(), "deleteAll() should reseed to a single fresh baseline, not leave nine spurious entries behind");
    assertEquals(0, app.model3DHistoryIndex);
  }

  @Test
  void fetchProject_doesNotCorruptHistoryViaLoadProjectsOwnFromXmlCascade () throws IOException {
    // load_project() (used by Open and, via fetchProject(), Fetch) reaches
    // beginModel3DChange()/endModel3DChange() repeatedly on its own, the exact
    // same way restoreProjectSnapshot() does (see that function's own
    // comment) - parse_XML_variables()'s own from_XML() cascade, several
    // classes' makeEmpty() each firing independently. load_project() now
    // wraps that part in isRestoringModel3DSnapshot too (previously only
    // restoreProjectSnapshot() did), so opening or fetching a project no
    // longer records several spurious, partially-loaded history entries.
    //
    // fetchProject()'s own try/catch around load_project() happens to
    // swallow a separate, pre-existing limitation of this headless test
    // environment (update_frame_layout()'s own createGraphics() call -
    // see FileSelectedTest.java's and SaveProjectTest.java's own notes),
    // which fires AFTER parse_XML_variables() has already fully run - so
    // this test still exercises the actual fix, even though it can't
    // reach load_project()'s own seedModel3DHistory() call at the very end
    // (same reasoning as SaveProjectTest.java's own fetchProject test).
    seed();
    createOneFaceViaImport();
    app.holdProject();
    int sizeBeforeFetch = app.model3DHistory.size();

    app.fetchProject();

    assertEquals(sizeBeforeFetch, app.model3DHistory.size(), "fetching a project must not append spurious history entries via its own from_XML() cascade");
  }

  // ================= fileSelected.pde: this step's conversion ===========

  @Test
  void fileSelectedImportObj_isUndoableAsOneStep () throws IOException {
    // _fileSelected_ImportObj() (and its seven siblings - ImportGlb/
    // ImportStl/ImportDxf/ImportPly/ImportDae/ImportIfc/ImportGbxml, all
    // converted the same way) is the real UI entry point behind
    // import_objects_OBJ() - this confirms the whole thing (the
    // allGroups.beginNewGroup() this wrapper does, together with the
    // import itself) now records as one undoable step through the real
    // caller, not just through the createOneFaceViaImport() test helper
    // used elsewhere in this file (which calls import_objects_OBJ()
    // directly, bypassing this wrapper and its own beginModel3DChange()).
    seed();
    int sizeBefore = app.model3DHistory.size();
    assertEquals(0, app.allGroups.num, "setup check");

    Path objFile = Files.createTempFile("undo-redo-fileselected-test", ".obj");
    Files.writeString(objFile, "g triangle\nv 0 0 0\nv 1 0 0\nv 1 1 0\nf 1 2 3\n");
    app._fileSelected_ImportObj(objFile.toFile());

    // 2, not 1: _fileSelected_ImportObj() pre-creates a group via its own
    // "if (allGroups.num == 0)" check, and import_objects_OBJ() ALSO
    // unconditionally creates its own (addToLastGroup defaults to false -
    // see importObj.pde's own "if (addToLastGroup == false)
    // allGroups.beginNewGroup()") - the two checks are independent, so
    // going through the real wrapper (unlike this file's own
    // createOneFaceViaImport() helper, which calls import_objects_OBJ()
    // directly and only ever sees the second one) creates both.
    assertEquals(2, app.allGroups.num, "setup check");
    assertEquals(1, app.allFaces.nodes.length, "setup check");
    assertEquals(sizeBefore + 1, app.model3DHistory.size(), "the import, including both of its own group creations, should record as exactly one step");

    app.undoModel3DChange();

    assertEquals(0, app.allGroups.num, "undo should remove both groups this import created too, not just the face");
    assertEquals(0, app.allFaces.nodes.length);
  }

  // ================= modify3D.pde: this step's conversion ================

  @Test
  void insertParallelOpenings_isUndoable () {
    // insertParallelOpenings_Selection() - and its 22 siblings in this
    // file (insertCorner/Rotated/EdgeOpenings, the tessellate* family,
    // forceTriangulateFaces, optimizeFace, extrudeFaceEdges,
    // autoNormalFaces, weldScene/ObjectsVertices, separateVertices,
    // offsetVertices, repositionVertices) - had NO beginModel3DChange()/
    // endModel3DChange() call anywhere in their own call chain before this
    // step, not even a bare model_changed() under the old design, so
    // none of them recorded an undo step at all. This is the exact
    // function from the originally reported bug (insert parallel
    // openings, select the middle one, delete it, undo) - the manual
    // setup mirrors ModifyGeometryTest.java's own integration test for
    // this same function.
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.User3D.modifierOpeningDeviation = 0.5f;
    app.User3D.modifierOpeningArea = 0.25f;
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};
    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    seed(); // baseline captured after the manual setup above - this is the state undo should return to

    app.Modify3D.insertParallelOpenings_Selection();

    assertEquals(9, app.allFaces.nodes.length, "setup check"); // the (re-shaped) base face + 4 sides x 2 quads

    app.undoModel3DChange();

    assertEquals(1, app.allFaces.nodes.length, "undo should bring back the single original face");
  }

  @Test
  void isolateSelection_recordsExactlyOneStepNotFour () {
    // isolate_Selection() wraps its own four already-converted sub-calls
    // (changeVisibilityFaces_Scene/_Selection, changeVisibilityPolylines_
    // Scene/_Selection) in its own beginModel3DChange()/endModel3DChange()
    // pair - same reasoning as Delete3D.selection()'s own comment -
    // without it, each of the four would independently record its own
    // step.
    seed();
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {1, 1, 0}};
    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;
    int sizeBefore = app.model3DHistory.size();

    app.Modify3D.isolate_Selection();

    assertEquals(sizeBefore + 1, app.model3DHistory.size(), "isolate should record exactly one step, not four");
  }

  // ================= create3D.pde: this step's conversion ================

  @Test
  void addBoxCore_isUndoable () {
    // None of create3D.pde's 28 add_X() geometry-creation functions had
    // any beginModel3DChange()/endModel3DChange() call anywhere before this
    // step (not even a bare model_changed() under the old design) - this
    // confirms the standard conversion (begin at the function's own true
    // top, all 28 have no early-return guard except add_Mesh) actually
    // makes a create action undoable.
    seed();
    int sizeBefore = app.model3DHistory.size();

    app.Create3D.add_Box_Core(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 2, 3, 90);

    assertEquals(6, app.allFaces.nodes.length, "setup check");
    assertEquals(sizeBefore + 1, app.model3DHistory.size());

    app.undoModel3DChange();

    assertEquals(0, app.allFaces.nodes.length);
  }

  @Test
  void addDefaultModel_recordsExactlyOneStepNotDozens () {
    // add_DefaultModel() ("3D-model N" actions, actions.pde) is a
    // composite of many runScriptLine() calls, each dispatching to its
    // own already-wrapped create/group function - same reasoning as
    // Delete3D.selection()'s own comment, this confirms its own outer
    // beginModel3DChange()/endModel3DChange() pair correctly coalesces all
    // of them into one step.
    //
    // runScriptLine() dispatches through app.allActions, which a fresh
    // app never populates itself (build_allActions() is normally only
    // ever called from setup()) - see MouseDraggedTest.java's own
    // comment on the same requirement.
    app.allActions = new java.util.HashMap<>();
    app.build_allActions();

    seed();
    int sizeBefore = app.model3DHistory.size();

    app.Create3D.add_DefaultModel(1); // the simplest of the eleven built-in default models

    assertTrue(app.allFaces.nodes.length > 0, "setup check: should have built something");
    assertEquals(sizeBefore + 1, app.model3DHistory.size(), "one default-model load should record exactly one step");

    app.undoModel3DChange();

    assertEquals(0, app.allFaces.nodes.length);
  }

  // ================= extraCommands.pde: this step's conversion ===========

  @Test
  void personCommand_isUndoable () {
    // The exact bug __PERSON__'s own comment documents: "add a person,
    // undo doesn't remove it - no history entry existed to undo back
    // to". That comment describes a fix already made to call
    // endModel3DChange() instead of view_changed() - what was still
    // missing, and is added by this step, is beginModel3DChange().
    app.allActions = new java.util.HashMap<>();
    app.build_allActions();

    seed();
    int sizeBefore = app.model3DHistory.size();

    app.runScriptLine("Person m=0 x=0 y=0 z=0");

    assertEquals(1, app.allModel2Ds.num, "setup check");
    assertEquals(sizeBefore + 1, app.model3DHistory.size());

    app.undoModel3DChange();

    assertEquals(0, app.allModel2Ds.num);
  }

  @Test
  void deleteCommand_withMultipleTargets_recordsExactlyOneStepNotPerTarget () {
    // __DELETE__ can target several categories in one command (e.g.
    // "Delete faces lines") - each already its own self-contained
    // beginModel3DChange()/endModel3DChange() pair (the various makeEmpty()
    // calls) - this confirms its own outer pair correctly coalesces
    // both targets into one step, not two.
    app.allActions = new java.util.HashMap<>();
    app.build_allActions();

    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.allPolylines.nodes = new int[][]{{0, 1}};
    app.allPolylines.options = new int[][]{{0, 0, 0, 0, 0, 0}}; // material, tessellation, layer, visibility, weight, close - see polylines.pde's own get/set pairs
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {1, 1, 0}};

    seed();
    int sizeBefore = app.model3DHistory.size();

    app.runScriptLine("Delete faces lines");

    assertEquals(0, app.allFaces.nodes.length, "setup check");
    assertEquals(0, app.allPolylines.nodes.length, "setup check");
    assertEquals(sizeBefore + 1, app.model3DHistory.size(), "one Delete command targeting two categories should record exactly one step");
  }

  // ================= importIfc.pde: this step's conversion ===============

  @Test
  void importObjectsIFC_isUndoableAsOneStep () throws IOException {
    // import_objects_IFC() previously called endModel3DChange() exactly
    // once, at the very end of the whole import (see its own file
    // comment on why it avoids calling Create3D.add_Mesh() per face),
    // but had no beginModel3DChange() of its own - meaning every IFC
    // import still only got the old post-edit-only recording, same gap
    // class as everything else converted across this whole effort. This
    // also covers ifcRotateImportedModelToTrueNorth()'s own nested
    // Rotate3D.selection() calls (not exercised here, since this
    // fixture has no IfcSite/north rotation, but structurally covered
    // by the same outer pair either way) and allGroups.beginNewGroup(),
    // both reached before the import's own trailing endModel3DChange().
    //
    // Minimal fixture mirrors ImportObjectsIFCTest.java's own smallest
    // IfcFacetedBrep snippet (one quad face) - see that file's own
    // comment on why a bare, never-setup()'d instance is directly
    // testable here (no WIN3D.graphics/PImage reached).
    Path ifcFileTmp = Files.createTempFile("undo-redo-ifc-test", ".ifc");
    Files.writeString(ifcFileTmp, """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        """
    );

    seed();
    int sizeBefore = app.model3DHistory.size();

    app.import_objects_IFC(ifcFileTmp.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length, "setup check");
    assertEquals(sizeBefore + 1, app.model3DHistory.size());

    app.undoModel3DChange();

    assertEquals(0, app.allFaces.nodes.length);
  }

  // ================= Select3D.clampSelectionsToCurrentData ==============

  @Test
  void clampSelectionsToCurrentData_dropsOutOfRangeIndicesAndKeepsValidOnes () {
    app.allFaces.nodes = new int[2][3];
    app.allFaces.options = new int[2][6];
    app.Select3D.faceSelection = new int[]{0, 1, 5}; // 5 doesn't exist

    app.Select3D.clampSelectionsToCurrentData();

    assertArrayEquals(new int[]{0, 1}, app.Select3D.faceSelection);
  }

  @Test
  void clampSelectionsToCurrentData_withNothingOutOfRange_leavesTheSelectionAsIs () {
    app.allGroups.makeEmpty(3);
    app.Select3D.groupSelection = new int[]{0, 2};

    app.Select3D.clampSelectionsToCurrentData();

    assertArrayEquals(new int[]{0, 2}, app.Select3D.groupSelection);
  }
}
