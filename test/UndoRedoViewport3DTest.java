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
}
