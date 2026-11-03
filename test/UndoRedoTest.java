import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// Covers undoRedo.pde: seedUndoHistory()/recordHistoryStep() (hooked
// into model_changed()), undo()/redo(), and restoreProjectSnapshot()'s
// own behavior (viewport left alone, no recursive recording, selection
// clamped to the restored data). Same setup SaveProjectTest.java uses -
// buildProjectSnapshot()/parse_XML_variables() reach the same 25+
// classes' to_XML()/from_XML() that saveProject()/load_project() do.
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
  // seedUndoHistory() - the one thing that actually establishes the
  // baseline - needs calling explicitly here, same as any other
  // startup-only step the other test files already work around.
  private void seed () {
    app.seedUndoHistory();
  }

  // Builds one real triangle (a face, inside a new group) the same way
  // SaveProjectTest.java's own fetchProject round-trip test does, then
  // deletes it - a small but genuine "add something, remove it" edit
  // pair to drive the integration-style tests below.
  //
  // import_objects_OBJ() is a low-level primitive that deliberately
  // never calls model_changed() itself (see fileSelected.pde's own
  // comment on its real call site) - every real caller is responsible
  // for calling it right after, exactly once, which is mirrored here so
  // this helper records a step the same way an actual OBJ import does.
  private void createOneFaceViaImport () throws IOException {
    Path objFile = Files.createTempFile("undo-redo-test", ".obj");
    Files.writeString(objFile, "g triangle\nv 0 0 0\nv 1 0 0\nv 1 1 0\nf 1 2 3\n");
    app.import_objects_OBJ(objFile.toString(), 5, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);
    app.model_changed();
  }

  private void deleteTheOneFace () {
    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.faceSelection = new int[]{0};
    app.Delete3D.selection();
  }

  // ================= seedUndoHistory ====================================

  @Test
  void seedUndoHistory_establishesASingleBaselineEntry () {
    seed();

    assertEquals(1, app.history.size());
    assertEquals(0, app.historyIndex);
  }

  @Test
  void seedUndoHistory_calledAgainResetsToANewSingleEntryBaseline () {
    seed();
    app.model_changed(); // a second entry
    assertEquals(2, app.history.size());

    seed(); // e.g. "New" or opening a different project, conceptually

    assertEquals(1, app.history.size());
    assertEquals(0, app.historyIndex);
  }

  // ================= recordHistoryStep (via model_changed()) ============

  @Test
  void modelChanged_beforeSeedUndoHistoryHasRun_recordsNothing () {
    assertEquals(-1, app.historyIndex); // sanity check: seed() was never called

    app.model_changed();

    assertEquals(0, app.history.size());
    assertEquals(-1, app.historyIndex);
  }

  @Test
  void modelChanged_appendsANewStepAndAdvancesHistoryIndex () {
    seed();

    app.model_changed();

    assertEquals(2, app.history.size());
    assertEquals(1, app.historyIndex);
  }

  @Test
  void modelChanged_whileIsRestoringSnapshotIsSet_recordsNothing () {
    // Exercises the reentrancy guard directly rather than only through
    // a real restore - see isRestoringSnapshot's own comment on why
    // parse_XML_variables() needs this (several classes' from_XML()
    // calls model_changed() by way of makeEmpty()).
    seed();
    app.isRestoringSnapshot = true;

    app.model_changed();

    assertEquals(1, app.history.size());
    assertEquals(0, app.historyIndex);
  }

  @Test
  void modelChanged_afterAnUndo_discardsTheRedoBranchBeforeAppending () {
    seed();            // history[0]
    app.model_changed(); // history[1]
    app.model_changed(); // history[2]
    assertEquals(3, app.history.size());

    app.undo(); // historyIndex -> 1, history[2] still sitting there as a redo target

    app.model_changed(); // a fresh edit - history[2] (the old redo branch) must be gone, replaced by this new one

    assertEquals(3, app.history.size());
    assertEquals(2, app.historyIndex);
  }

  @Test
  void modelChanged_boundsHistoryToMaxUndoSteps () {
    seed();

    for (int i = 0; i < app.MAX_UNDO_STEPS + 10; i++) {
      app.model_changed();
    }

    assertTrue(app.history.size() <= app.MAX_UNDO_STEPS + 1, "expected the list to be capped, was " + app.history.size());
    assertEquals(app.history.size() - 1, app.historyIndex, "historyIndex should still point at the newest entry after trimming");
  }

  // ================= undo / redo =========================================

  @Test
  void undo_atTheBaseline_doesNothing () {
    seed();

    app.undo();

    assertEquals(0, app.historyIndex);
    assertEquals(1, app.history.size());
  }

  @Test
  void redo_atTheNewestEntry_doesNothing () {
    seed();
    app.model_changed();

    app.redo();

    assertEquals(1, app.historyIndex);
  }

  @Test
  void undo_movesHistoryIndexBackOneStep () {
    seed();
    app.model_changed();
    app.model_changed();
    assertEquals(2, app.historyIndex);

    app.undo();

    assertEquals(1, app.historyIndex);
  }

  @Test
  void redo_movesHistoryIndexForwardOneStepAfterAnUndo () {
    seed();
    app.model_changed();
    app.model_changed();
    app.undo();
    assertEquals(1, app.historyIndex);

    app.redo();

    assertEquals(2, app.historyIndex);
  }

  // ================= restoreProjectSnapshot: what it does and doesn't touch

  @Test
  void restoreProjectSnapshot_neverRecursesIntoRecordHistoryStep () {
    // parse_XML_variables() reaches model_changed() close to nine times
    // on its own (Faces/Model1Ds/Model2Ds/Solids/Polylines/Points/
    // Cameras/Sections/Groups' from_XML() -> makeEmpty()) - without
    // isRestoringSnapshot, each of those would append its own spurious
    // entry and the two asserts below would both fail.
    seed();
    app.model_changed();
    int historySizeBeforeUndo = app.history.size();

    app.undo();

    assertEquals(historySizeBeforeUndo, app.history.size(), "a restore must not append new history entries");
    assertFalse(app.isRestoringSnapshot, "the guard must be cleared again once the restore finishes");
  }

  @Test
  void restoreProjectSnapshot_leavesTheCurrentCameraPositionUntouched () {
    seed(); // baseline captured with camera at its default position

    app.WIN3D.cameraX = 123;
    app.model_changed(); // a modeling edit, unrelated to the camera move above - still captures cameraX=123 into this step's own snapshot

    app.WIN3D.cameraX = 999; // the user navigates after that edit, not going through model_changed()

    app.undo(); // back to the baseline

    assertEquals(999f, app.WIN3D.cameraX, 0.0001f, "undo must leave the viewport exactly where the user left it");
  }

  @Test
  void restoreProjectSnapshot_clampsSelectionsThatNoLongerFitTheRestoredData () throws IOException {
    seed(); // baseline: no faces at all
    createOneFaceViaImport(); // records exactly one step - history is now [baseline, one-face]

    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.faceSelection = new int[]{0}; // valid right now, against the one imported face

    app.undo(); // back to the baseline - zero faces - without Select3D.clampSelectionsToCurrentData() this selection would now be stale

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

    app.undo();

    assertEquals(1, app.allFaces.nodes.length);
  }

  @Test
  void addThenDeleteThenUndoThenRedo_deletesItAgain () throws IOException {
    seed();

    createOneFaceViaImport();
    deleteTheOneFace();
    app.undo();
    assertEquals(1, app.allFaces.nodes.length, "setup check");

    app.redo();

    assertEquals(0, app.allFaces.nodes.length);
  }

  @Test
  void undoTwiceThenRedoTwice_roundTripsBackToTheSameState () throws IOException {
    seed();                              // step 0: nothing
    createOneFaceViaImport();            // step 1: one face
    deleteTheOneFace();                  // step 2: no faces again

    app.undo();
    app.undo();
    assertEquals(0, app.historyIndex);
    assertEquals(0, app.allFaces.nodes.length);

    app.redo();
    assertEquals(1, app.allFaces.nodes.length);

    app.redo();
    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(2, app.historyIndex);
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
