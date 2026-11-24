import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers undoRedoViewport3D.pde: seedViewport3DHistory()/
// trackViewport3DChange() (the frame-polled stand-in for
// beginScene3DChange()/endScene3DChange(), since Viewport3D has no
// begin/end hook of its own - see that file's own header comment),
// undoViewport3DChange()/redoViewport3DChange(), and
// restoreProjectViewport3DSnapshot()'s own behavior (no recursive
// recording, WIN3D flagged for a redraw). Same "bare `new
// solarchvision_bim()`, no setup()" style UndoRedoTest.java and
// WIN3DTest.java already use for WIN3D.to_XML()/from_XML() - neither
// touches WIN3D.graphics/PImage/live mouse state.
//
// frameCount IS simulated here, unlike UndoRedoTest.java - that's the
// whole point of this file's own coalescing logic (see
// trackViewport3DChange()'s own comment): a "drag" is several
// back-to-back frameCount values each changing WIN3D a little, a "new
// gesture" is the same but with at least one quiet frameCount value in
// between. PApplet's own frameCount field is public and directly
// settable, so each test drives it explicitly rather than relying on
// a real draw() loop.
class UndoRedoViewport3DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.Terrain.Mesh = new float[app.Terrain.rowCount][app.Terrain.columnCount][3]; // needed by Terrain.to_XML(), reached whenever a test also drives app.seedScene3DHistory()/beginScene3DChange() - same setup UndoRedoTest.java uses
  }

  // A bare `new solarchvision_bim()` never runs drawInitialFrames.pde's
  // frame-22 branch (gated on the real Processing draw loop), so
  // seedViewport3DHistory() - the one thing that actually establishes
  // the baseline - needs calling explicitly here, same as seed() does
  // for Scene3D in UndoRedoTest.java.
  private void seed () {
    app.seedViewport3DHistory();
  }

  // One frame of a viewport "gesture": sets frameCount, nudges
  // WIN3D.cameraX to some new value (the one WIN3D field every test
  // below needs to tell snapshots apart), and runs the same per-frame
  // check draw() calls for real. Callers space frame numbers apart by
  // more than 1 to get separate, non-coalescing gestures, and keep them
  // consecutive to simulate one continuous drag.
  private void recordViewportStep (int frame, float cameraX) {
    app.frameCount = frame;
    app.WIN3D.cameraX = cameraX;
    app.trackViewport3DChange();
  }

  // ================= seedViewport3DHistory ================================

  @Test
  void seedViewport3DHistory_establishesASingleBaselineEntry () {
    seed();

    assertEquals(1, app.viewport3DHistory.size());
    assertEquals(0, app.viewport3DHistoryIndex);
  }

  @Test
  void seedViewport3DHistory_calledAgainResetsToANewSingleEntryBaseline () {
    seed();
    recordViewportStep(10, 5); // a second entry
    assertEquals(2, app.viewport3DHistory.size());

    seed(); // e.g. "New" or opening a different project, conceptually

    assertEquals(1, app.viewport3DHistory.size());
    assertEquals(0, app.viewport3DHistoryIndex);
  }

  // ================= trackViewport3DChange ================================

  @Test
  void trackViewport3DChange_beforeSeedHasRun_recordsNothing () {
    assertEquals(-1, app.viewport3DHistoryIndex); // sanity check: seed() was never called

    app.frameCount = 10;
    app.WIN3D.cameraX = 5;
    app.trackViewport3DChange();

    assertEquals(0, app.viewport3DHistory.size());
    assertEquals(-1, app.viewport3DHistoryIndex);
  }

  @Test
  void trackViewport3DChange_withNothingChanged_recordsNothing () {
    seed();

    app.frameCount = 10;
    app.trackViewport3DChange(); // WIN3D untouched since seed()

    assertEquals(1, app.viewport3DHistory.size());
    assertEquals(0, app.viewport3DHistoryIndex);
  }

  @Test
  void trackViewport3DChange_withAChange_appendsANewStepAndAdvancesHistoryIndex () {
    seed();

    recordViewportStep(10, 5);

    assertEquals(2, app.viewport3DHistory.size());
    assertEquals(1, app.viewport3DHistoryIndex);
  }

  @Test
  void trackViewport3DChange_whileIsRestoringViewport3DSnapshotIsSet_recordsNothing () {
    // Exercises the reentrancy guard directly, same way
    // UndoRedoTest.java's own isRestoringScene3DSnapshot test does -
    // without it, restoreProjectViewport3DSnapshot()'s own
    // WIN3D.from_XML() write would look, to the very next poll, exactly
    // like a brand new gesture.
    seed();
    app.isRestoringViewport3DSnapshot = true;

    app.frameCount = 10;
    app.WIN3D.cameraX = 5;
    app.trackViewport3DChange();

    assertEquals(1, app.viewport3DHistory.size());
    assertEquals(0, app.viewport3DHistoryIndex);
  }

  @Test
  void trackViewport3DChange_consecutiveFramesWithChanges_coalesceIntoOneEntry () {
    // Simulates a held mouse drag: WIN3D changes a little on several
    // back-to-back frames - the whole continuous gesture should fold
    // into one history entry, not one per frame.
    seed();

    recordViewportStep(10, 1);
    assertEquals(2, app.viewport3DHistory.size(), "the first frame of the drag starts a new entry");

    recordViewportStep(11, 2); // still the same drag - the very next frame
    recordViewportStep(12, 3); // still the same drag

    assertEquals(2, app.viewport3DHistory.size(), "the whole continuous drag should still be just one entry");
    assertEquals(1, app.viewport3DHistoryIndex);

    app.undoViewport3DChange();

    assertEquals(0f, app.WIN3D.cameraX, 0.0001f, "undo should land back on the pre-drag baseline, not some mid-drag frame");
  }

  @Test
  void trackViewport3DChange_separateGesturesWithAQuietFrameBetween_recordsTwoEntries () {
    seed();

    recordViewportStep(10, 1); // gesture 1
    assertEquals(2, app.viewport3DHistory.size());

    app.frameCount = 11; // a quiet frame in between - nothing changes
    app.trackViewport3DChange();
    assertEquals(2, app.viewport3DHistory.size(), "a quiet frame with nothing changed shouldn't record anything");

    recordViewportStep(12, 2); // gesture 2, not contiguous with gesture 1

    assertEquals(3, app.viewport3DHistory.size(), "a gesture separated by a quiet frame should start its own entry, not coalesce into the last one");
    assertEquals(2, app.viewport3DHistoryIndex);
  }

  @Test
  void trackViewport3DChange_boundsHistoryToMaxUndoViewport3DSteps () {
    seed();

    int frame = 10;
    for (int i = 0; i < app.MAX_UNDO_VIEWPORT3D + 10; i++) {
      recordViewportStep(frame, frame); // each its own gesture - frame jumps by 10, well past the "still dragging" window
      frame += 10;
    }

    assertTrue(app.viewport3DHistory.size() <= app.MAX_UNDO_VIEWPORT3D + 1, "expected the list to be capped, was " + app.viewport3DHistory.size());
    assertEquals(app.viewport3DHistory.size() - 1, app.viewport3DHistoryIndex, "historyIndex should still point at the newest entry after trimming");
  }

  // ================= undo / redo ==========================================

  @Test
  void undo_atTheBaseline_doesNothing () {
    seed();

    app.undoViewport3DChange();

    assertEquals(0, app.viewport3DHistoryIndex);
    assertEquals(1, app.viewport3DHistory.size());
  }

  @Test
  void redo_atTheNewestEntry_doesNothing () {
    seed();
    recordViewportStep(10, 5);

    app.redoViewport3DChange();

    assertEquals(1, app.viewport3DHistoryIndex);
  }

  @Test
  void undo_movesHistoryIndexBackOneStep () {
    seed();
    recordViewportStep(10, 1);
    recordViewportStep(20, 2);
    assertEquals(2, app.viewport3DHistoryIndex);

    app.undoViewport3DChange();

    assertEquals(1, app.viewport3DHistoryIndex);
  }

  @Test
  void redo_movesHistoryIndexForwardOneStepAfterAnUndo () {
    seed();
    recordViewportStep(10, 1);
    recordViewportStep(20, 2);
    app.undoViewport3DChange();
    assertEquals(1, app.viewport3DHistoryIndex);

    app.redoViewport3DChange();

    assertEquals(2, app.viewport3DHistoryIndex);
  }

  @Test
  void aFreshGestureAfterAnUndo_discardsTheRedoBranchBeforeAppending () {
    seed();                  // history[0]
    recordViewportStep(10, 1); // history[1]
    recordViewportStep(20, 2); // history[2]
    assertEquals(3, app.viewport3DHistory.size());

    app.undoViewport3DChange(); // historyIndex -> 1, history[2] still sitting there as a redo target

    recordViewportStep(30, 3); // a fresh gesture - history[2] (the old redo branch) must be gone, replaced by this new one

    assertEquals(3, app.viewport3DHistory.size());
    assertEquals(2, app.viewport3DHistoryIndex);
  }

  @Test
  void undoThenRedo_roundTripsWIN3DFieldsExactly () {
    seed(); // baseline: cameraX=0 (WIN3D's own field default), rotationZ at whatever WIN3D's own field default is
    float rotationZBaseline = app.WIN3D.rotationZ;

    app.frameCount = 10;
    app.WIN3D.cameraX = 100;
    app.trackViewport3DChange(); // history[1]: cameraX=100, rotationZ still at its baseline

    app.frameCount = 20; // a separate gesture
    app.WIN3D.cameraX = 200;
    app.WIN3D.rotationZ = -90;
    app.trackViewport3DChange(); // history[2]: cameraX=200, rotationZ=-90

    app.undoViewport3DChange(); // back to history[1]
    assertEquals(100f, app.WIN3D.cameraX, 0.0001f);
    assertEquals(rotationZBaseline, app.WIN3D.rotationZ, 0.0001f, "rotationZ hadn't changed yet when history[1] was recorded");

    app.undoViewport3DChange(); // back to the baseline
    assertEquals(0f, app.WIN3D.cameraX, 0.0001f);

    app.redoViewport3DChange();
    app.redoViewport3DChange();

    assertEquals(200f, app.WIN3D.cameraX, 0.0001f);
    assertEquals(-90f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void undo_setsWIN3DUpdateSoTheViewportRedraws () {
    seed();
    recordViewportStep(10, 5);
    app.WIN3D.updated(); // simulate "already drawn this frame" (update = false)

    app.undoViewport3DChange();

    assertTrue(app.WIN3D.update, "undo must flag WIN3D for a redraw from the restored position");
  }

  // ================= restoreProjectViewport3DSnapshot: guard behavior ====

  @Test
  void restoreProjectViewport3DSnapshot_clearsTheGuardOnceDone () {
    seed();
    recordViewportStep(10, 5);

    app.undoViewport3DChange();

    assertFalse(app.isRestoringViewport3DSnapshot, "the guard must be cleared again once the restore finishes");
  }

  @Test
  void restoreProjectViewport3DSnapshot_isNotMistakenForANewGestureOnTheNextFramesPoll () {
    // The actual bug this guards against: without
    // isRestoringViewport3DSnapshot, undoViewport3DChange()'s own
    // WIN3D.from_XML() write would look, to the very next frame's
    // trackViewport3DChange(), exactly like a user-driven change - and
    // get recorded as a brand new gesture, turning every undo into a
    // redo-able "change" of its own.
    seed();
    recordViewportStep(10, 5);
    int sizeBeforeUndo = app.viewport3DHistory.size();

    app.undoViewport3DChange();

    app.frameCount = 11; // the very next frame after the restore
    app.trackViewport3DChange();

    assertEquals(sizeBeforeUndo, app.viewport3DHistory.size(), "the restore itself must not be recorded as a new gesture");
  }

  // ================= independence from Scene3D's own history =============

  @Test
  void modelEditsDoNotRecordAViewport3DHistoryStep () {
    app.seedScene3DHistory();
    seed();

    app.beginScene3DChange();
    app.endScene3DChange();

    assertEquals(1, app.viewport3DHistory.size(), "a model edit alone must not touch the viewport history");
  }

  @Test
  void viewportChangesDoNotRecordAScene3DHistoryStep () {
    app.seedScene3DHistory();
    seed();

    recordViewportStep(10, 5);

    assertEquals(1, app.scene3DHistory.size(), "a viewport change alone must not touch the model history");
  }

  @Test
  void undoViewport3DChange_leavesTheModelUntouched () {
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};

    seed();
    recordViewportStep(10, 5);

    app.undoViewport3DChange();

    assertEquals(1, app.allFaces.nodes.length, "a viewport undo must leave the model exactly as it was");
  }

  // ================= wired as actions (Ctrl+Shift+Z / Ctrl+Shift+Y) ======

  @Test
  void undoViewport3DChangeAction_isRegisteredAndMatchesTheDirectCall () {
    app.allActions = new java.util.HashMap<>(); // fresh app never populates this itself - see MouseDraggedTest.java's own comment on the same requirement
    app.build_allActions();

    seed();
    recordViewportStep(10, 50);

    app.callAction("Undo Viewport3D Change");

    assertEquals(0f, app.WIN3D.cameraX, 0.0001f);
    assertEquals(0, app.viewport3DHistoryIndex);
  }

  @Test
  void redoViewport3DChangeAction_isRegisteredAndMatchesTheDirectCall () {
    app.allActions = new java.util.HashMap<>();
    app.build_allActions();

    seed();
    recordViewportStep(10, 50);
    app.undoViewport3DChange();

    app.callAction("Redo Viewport3D Change");

    assertEquals(50f, app.WIN3D.cameraX, 0.0001f);
    assertEquals(1, app.viewport3DHistoryIndex);
  }

  // ================= "Visibility" menu Show/Hide toggles =================
  //
  // Covers writeVisibilityToggleState()/readVisibilityToggleState()
  // (undoRedoViewport3D.pde): the "Visibility" menu's Show/Hide display
  // flags (Terrain/Sky/Sun/Faces/Edges/... - uiMenuBar.pde's own
  // PARENT_VISIBILITY block) ride along in the same WIN3D snapshot/poll
  // pipeline as the camera, so Ctrl+Shift+Z/Y (not Ctrl+Z/Y) undo/redo
  // them - the bug this file's own header comment was expanded for.

  @Test
  void toggleFacesDisplayAll_recordsAViewport3DHistoryStepNotAScene3DOne () {
    app.seedScene3DHistory();
    seed();

    app.frameCount = 10;
    app.allFaces.displayAll = !app.allFaces.displayAll; // the live "Show/Hide Faces" action's own effect (actions.pde)
    app.trackViewport3DChange();

    assertEquals(2, app.viewport3DHistory.size(), "a visibility toggle must record a viewport history step");
    assertEquals(1, app.scene3DHistory.size(), "a visibility toggle must NOT record a model history step");
  }

  @Test
  void undoViewport3DChange_restoresAFacesDisplayAllToggle () {
    seed();
    boolean baseline = app.allFaces.displayAll;

    app.frameCount = 10;
    app.allFaces.displayAll = !baseline;
    app.trackViewport3DChange();

    app.undoViewport3DChange();

    assertEquals(baseline, app.allFaces.displayAll, "Ctrl+Shift+Z must undo the visibility toggle");
  }

  @Test
  void redoViewport3DChange_reappliesAFacesDisplayAllToggle () {
    seed();
    boolean baseline = app.allFaces.displayAll;

    app.frameCount = 10;
    app.allFaces.displayAll = !baseline;
    app.trackViewport3DChange();

    app.undoViewport3DChange();
    app.redoViewport3DChange();

    assertEquals(!baseline, app.allFaces.displayAll, "Ctrl+Shift+Y must redo the visibility toggle");
  }

  @Test
  void undoThenRedo_roundTripsEveryVisibilityMenuToggleExactly () {
    // One of each of the ~two dozen "Visibility" menu flags
    // writeVisibilityToggleState()/readVisibilityToggleState() cover -
    // confirms the full set actually round-trips, not just the one
    // field the tests above already isolate.
    seed();

    app.frameCount = 10;
    app.Terrain.displaySurface = !app.Terrain.displaySurface;
    app.Terrain.displayTexture = !app.Terrain.displayTexture;
    app.Terrain.displayPoints = !app.Terrain.displayPoints;
    app.Terrain.displayDepth = !app.Terrain.displayDepth;
    app.allPoints.displayAll = !app.allPoints.displayAll;
    app.allFaces.displayEdges = !app.allFaces.displayEdges;
    app.allFaces.showNormalLines = !app.allFaces.showNormalLines;
    app.allModel1Ds.displayLeaves = !app.allModel1Ds.displayLeaves;
    app.allModel1Ds.displayAll = !app.allModel1Ds.displayAll;
    app.allModel2Ds.displayAll = !app.allModel2Ds.displayAll;
    app.allPolylines.displayAll = !app.allPolylines.displayAll;
    app.allFaces.displayAll = !app.allFaces.displayAll;
    app.allSolids.displayAll = !app.allSolids.displayAll;
    app.allSections.displayAll = !app.allSections.displayAll;
    app.allCameras.displayAll = !app.allCameras.displayAll;
    app.Sky3D.displaySurface = !app.Sky3D.displaySurface;
    app.Sun3D.displayGrid = !app.Sun3D.displayGrid;
    app.Sun3D.displayPath = !app.Sun3D.displayPath;
    app.Sun3D.displayPattern = !app.Sun3D.displayPattern;
    app.Sun3D.displaySurface = !app.Sun3D.displaySurface;
    app.Moon3D.displaySurface = !app.Moon3D.displaySurface;
    app.Earth3D.displaySurface = !app.Earth3D.displaySurface;
    app.Tropo3D.displaySurface = !app.Tropo3D.displaySurface;
    app.allSolarImpacts.displayImage = !app.allSolarImpacts.displayImage;
    app.allSolidImpacts.displayImage = !app.allSolidImpacts.displayImage;
    app.allWindFlows.displayAll = !app.allWindFlows.displayAll;

    boolean terrainDisplaySurface = app.Terrain.displaySurface;
    boolean terrainDisplayTexture = app.Terrain.displayTexture;
    boolean terrainDisplayPoints = app.Terrain.displayPoints;
    boolean terrainDisplayDepth = app.Terrain.displayDepth;
    boolean pointsDisplayAll = app.allPoints.displayAll;
    boolean facesDisplayEdges = app.allFaces.displayEdges;
    boolean facesShowNormalLines = app.allFaces.showNormalLines;
    boolean model1DsDisplayLeaves = app.allModel1Ds.displayLeaves;
    boolean model1DsDisplayAll = app.allModel1Ds.displayAll;
    boolean model2DsDisplayAll = app.allModel2Ds.displayAll;
    boolean polylinesDisplayAll = app.allPolylines.displayAll;
    boolean facesDisplayAll = app.allFaces.displayAll;
    boolean solidsDisplayAll = app.allSolids.displayAll;
    boolean sectionsDisplayAll = app.allSections.displayAll;
    boolean camerasDisplayAll = app.allCameras.displayAll;
    boolean skyDisplaySurface = app.Sky3D.displaySurface;
    boolean sunDisplayGrid = app.Sun3D.displayGrid;
    boolean sunDisplayPath = app.Sun3D.displayPath;
    boolean sunDisplayPattern = app.Sun3D.displayPattern;
    boolean sunDisplaySurface = app.Sun3D.displaySurface;
    boolean moonDisplaySurface = app.Moon3D.displaySurface;
    boolean earthDisplaySurface = app.Earth3D.displaySurface;
    boolean tropoDisplaySurface = app.Tropo3D.displaySurface;
    boolean solarImpactsDisplayImage = app.allSolarImpacts.displayImage;
    boolean solidImpactsDisplayImage = app.allSolidImpacts.displayImage;
    boolean windFlowDisplayAll = app.allWindFlows.displayAll;

    app.trackViewport3DChange();

    app.undoViewport3DChange();
    app.redoViewport3DChange();

    assertEquals(terrainDisplaySurface, app.Terrain.displaySurface);
    assertEquals(terrainDisplayTexture, app.Terrain.displayTexture);
    assertEquals(terrainDisplayPoints, app.Terrain.displayPoints);
    assertEquals(terrainDisplayDepth, app.Terrain.displayDepth);
    assertEquals(pointsDisplayAll, app.allPoints.displayAll);
    assertEquals(facesDisplayEdges, app.allFaces.displayEdges);
    assertEquals(facesShowNormalLines, app.allFaces.showNormalLines);
    assertEquals(model1DsDisplayLeaves, app.allModel1Ds.displayLeaves);
    assertEquals(model1DsDisplayAll, app.allModel1Ds.displayAll);
    assertEquals(model2DsDisplayAll, app.allModel2Ds.displayAll);
    assertEquals(polylinesDisplayAll, app.allPolylines.displayAll);
    assertEquals(facesDisplayAll, app.allFaces.displayAll);
    assertEquals(solidsDisplayAll, app.allSolids.displayAll);
    assertEquals(sectionsDisplayAll, app.allSections.displayAll);
    assertEquals(camerasDisplayAll, app.allCameras.displayAll);
    assertEquals(skyDisplaySurface, app.Sky3D.displaySurface);
    assertEquals(sunDisplayGrid, app.Sun3D.displayGrid);
    assertEquals(sunDisplayPath, app.Sun3D.displayPath);
    assertEquals(sunDisplayPattern, app.Sun3D.displayPattern);
    assertEquals(sunDisplaySurface, app.Sun3D.displaySurface);
    assertEquals(moonDisplaySurface, app.Moon3D.displaySurface);
    assertEquals(earthDisplaySurface, app.Earth3D.displaySurface);
    assertEquals(tropoDisplaySurface, app.Tropo3D.displaySurface);
    assertEquals(solarImpactsDisplayImage, app.allSolarImpacts.displayImage);
    assertEquals(solidImpactsDisplayImage, app.allSolidImpacts.displayImage);
    assertEquals(windFlowDisplayAll, app.allWindFlows.displayAll);
  }

  // ============= "Selection" menu Show/Hide Selected ... toggles =============
  //
  // Covers writeSelectionDisplayState()/readSelectionDisplayState()
  // (undoRedoViewport3D.pde): the "Selection" menu's Show/Hide Selected
  // ... display flags (Select3D's own display fields, as opposed to its
  // selection-set fields) ride along in the same WIN3D snapshot/poll
  // pipeline as the camera, so Ctrl+Shift+Z/Y (not Ctrl+Z/Y) undo/redo
  // them too, same as the Visibility menu toggles above.

  @Test
  void toggleSolidDisplayEdges_recordsAViewport3DHistoryStepNotAScene3DOne () {
    app.seedScene3DHistory();
    seed();

    app.frameCount = 10;
    app.Select3D.solidDisplayEdges = !app.Select3D.solidDisplayEdges; // the live "Show/Hide Selected Solids" action's own effect (actions.pde)
    app.trackViewport3DChange();

    assertEquals(2, app.viewport3DHistory.size(), "a selection-display toggle must record a viewport history step");
    assertEquals(1, app.scene3DHistory.size(), "a selection-display toggle must NOT record a model history step");
  }

  @Test
  void undoViewport3DChange_restoresASolidDisplayEdgesToggle () {
    seed();
    boolean baseline = app.Select3D.solidDisplayEdges;

    app.frameCount = 10;
    app.Select3D.solidDisplayEdges = !baseline;
    app.trackViewport3DChange();

    app.undoViewport3DChange();

    assertEquals(baseline, app.Select3D.solidDisplayEdges, "Ctrl+Shift+Z must undo the selection-display toggle");
  }

  @Test
  void redoViewport3DChange_reappliesASolidDisplayEdgesToggle () {
    seed();
    boolean baseline = app.Select3D.solidDisplayEdges;

    app.frameCount = 10;
    app.Select3D.solidDisplayEdges = !baseline;
    app.trackViewport3DChange();

    app.undoViewport3DChange();
    app.redoViewport3DChange();

    assertEquals(!baseline, app.Select3D.solidDisplayEdges, "Ctrl+Shift+Y must redo the selection-display toggle");
  }

  @Test
  void undoThenRedo_roundTripsEverySelectionMenuToggleExactly () {
    // One of each of the 16 "Selection" menu flags
    // writeSelectionDisplayState()/readSelectionDisplayState() cover -
    // confirms the full set actually round-trips, not just the one
    // field the tests above already isolate.
    seed();

    app.frameCount = 10;
    app.Select3D.solidDisplayEdges = !app.Select3D.solidDisplayEdges;
    app.Select3D.sectionDisplayEdges = !app.Select3D.sectionDisplayEdges;
    app.Select3D.cameraDisplayFrustum = !app.Select3D.cameraDisplayFrustum;
    app.Select3D.terrainDisplayVertices = !app.Select3D.terrainDisplayVertices;
    app.Select3D.faceDisplayEdges = !app.Select3D.faceDisplayEdges;
    app.Select3D.polylineDisplayVertices = !app.Select3D.polylineDisplayVertices;
    app.Select3D.faceDisplayVertexSelection = !app.Select3D.faceDisplayVertexSelection;
    app.Select3D.polylineDisplayVertexSelection = !app.Select3D.polylineDisplayVertexSelection;
    app.Select3D.vertexDisplayMarkers = !app.Select3D.vertexDisplayMarkers;
    app.Select3D.pivotDisplayReference = !app.Select3D.pivotDisplayReference;
    app.Select3D.groupDisplayPivot = !app.Select3D.groupDisplayPivot;
    app.Select3D.groupDisplayEdges = !app.Select3D.groupDisplayEdges;
    app.Select3D.groupDisplayBox = !app.Select3D.groupDisplayBox;
    app.Select3D.model2DDisplayBounds = !app.Select3D.model2DDisplayBounds;
    app.Select3D.model1DDisplayBounds = !app.Select3D.model1DDisplayBounds;
    app.Select3D.modifierDisplayBoundingBox = !app.Select3D.modifierDisplayBoundingBox;

    boolean solidDisplayEdges = app.Select3D.solidDisplayEdges;
    boolean sectionDisplayEdges = app.Select3D.sectionDisplayEdges;
    boolean cameraDisplayFrustum = app.Select3D.cameraDisplayFrustum;
    boolean terrainDisplayVertices = app.Select3D.terrainDisplayVertices;
    boolean faceDisplayEdges = app.Select3D.faceDisplayEdges;
    boolean polylineDisplayVertices = app.Select3D.polylineDisplayVertices;
    boolean faceDisplayVertexSelection = app.Select3D.faceDisplayVertexSelection;
    boolean polylineDisplayVertexSelection = app.Select3D.polylineDisplayVertexSelection;
    boolean vertexDisplayMarkers = app.Select3D.vertexDisplayMarkers;
    boolean pivotDisplayReference = app.Select3D.pivotDisplayReference;
    boolean groupDisplayPivot = app.Select3D.groupDisplayPivot;
    boolean groupDisplayEdges = app.Select3D.groupDisplayEdges;
    boolean groupDisplayBox = app.Select3D.groupDisplayBox;
    boolean model2DDisplayBounds = app.Select3D.model2DDisplayBounds;
    boolean model1DDisplayBounds = app.Select3D.model1DDisplayBounds;
    boolean modifierDisplayBoundingBox = app.Select3D.modifierDisplayBoundingBox;

    app.trackViewport3DChange();

    app.undoViewport3DChange();
    app.redoViewport3DChange();

    assertEquals(solidDisplayEdges, app.Select3D.solidDisplayEdges);
    assertEquals(sectionDisplayEdges, app.Select3D.sectionDisplayEdges);
    assertEquals(cameraDisplayFrustum, app.Select3D.cameraDisplayFrustum);
    assertEquals(terrainDisplayVertices, app.Select3D.terrainDisplayVertices);
    assertEquals(faceDisplayEdges, app.Select3D.faceDisplayEdges);
    assertEquals(polylineDisplayVertices, app.Select3D.polylineDisplayVertices);
    assertEquals(faceDisplayVertexSelection, app.Select3D.faceDisplayVertexSelection);
    assertEquals(polylineDisplayVertexSelection, app.Select3D.polylineDisplayVertexSelection);
    assertEquals(vertexDisplayMarkers, app.Select3D.vertexDisplayMarkers);
    assertEquals(pivotDisplayReference, app.Select3D.pivotDisplayReference);
    assertEquals(groupDisplayPivot, app.Select3D.groupDisplayPivot);
    assertEquals(groupDisplayEdges, app.Select3D.groupDisplayEdges);
    assertEquals(groupDisplayBox, app.Select3D.groupDisplayBox);
    assertEquals(model2DDisplayBounds, app.Select3D.model2DDisplayBounds);
    assertEquals(model1DDisplayBounds, app.Select3D.model1DDisplayBounds);
    assertEquals(modifierDisplayBoundingBox, app.Select3D.modifierDisplayBoundingBox);
  }
}
