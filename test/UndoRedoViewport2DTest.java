import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers undoRedoViewport2D.pde: seedViewport2DHistory()/
// trackViewport2DChange() (the frame-polled stand-in for a begin/end
// hook, since STUDY has none of its own - see that file's own header
// comment), undoViewport2DChange()/redoViewport2DChange(), and
// restoreProjectViewport2DSnapshot()'s own behavior (no recursive
// recording, the broad reviseByUpdateFlags()/applyCaseBarAndBake/
// updateImpactGraph follow-up fired afterward). Same "bare `new
// solarchvision_bim()`, no setup()" style UndoRedoViewport3DTest.java/
// UndoRedoStationTest.java already use.
//
// frameCount is simulated here, same reason and same style as the
// other two frame-polled histories: a "drag" (a held spinner, e.g. End
// Day) is several back-to-back frameCount values each changing STUDY a
// little; a "new gesture" is the same but with at least one quiet
// frameCount value in between, which is also what a one-shot change (a
// case-bar wheel notch, a command-line End Day) naturally looks like.
class UndoRedoViewport2DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // A bare `new solarchvision_bim()` never runs drawInitialFrames.pde's
  // frame-22 branch, so seedViewport2DHistory() - the one thing that
  // actually establishes the baseline - needs calling explicitly here,
  // same as seed() does in the other two frame-polled test files.
  private void seed () {
    app.seedViewport2DHistory();
  }

  // One frame of a Viewport2D "gesture": sets frameCount, nudges
  // STUDY.endDay to some new value (the one field every test below
  // needs to tell snapshots apart), and runs the same per-frame check
  // draw() calls for real. Callers space frame numbers apart by more
  // than 1 to get separate, non-coalescing gestures, and keep them
  // consecutive to simulate one continuous drag.
  private void recordViewport2DStep (int frame, int endDay) {
    app.frameCount = frame;
    app.STUDY.endDay = endDay;
    app.trackViewport2DChange();
  }

  // ================= seedViewport2DHistory =================================

  @Test
  void seedViewport2DHistory_establishesASingleBaselineEntry () {
    seed();

    assertEquals(1, app.viewport2DHistory.size());
    assertEquals(0, app.viewport2DHistoryIndex);
  }

  @Test
  void seedViewport2DHistory_calledAgainResetsToANewSingleEntryBaseline () {
    seed();
    recordViewport2DStep(10, app.STUDY.endDay + 1); // a second entry
    assertEquals(2, app.viewport2DHistory.size());

    seed(); // e.g. Open/Fetch loading a different project, conceptually

    assertEquals(1, app.viewport2DHistory.size());
    assertEquals(0, app.viewport2DHistoryIndex);
  }

  // ================= trackViewport2DChange ==================================

  @Test
  void trackViewport2DChange_beforeSeedHasRun_recordsNothing () {
    assertEquals(-1, app.viewport2DHistoryIndex); // sanity check: seed() was never called

    app.frameCount = 10;
    app.STUDY.endDay = app.STUDY.endDay + 5;
    app.trackViewport2DChange();

    assertEquals(0, app.viewport2DHistory.size());
    assertEquals(-1, app.viewport2DHistoryIndex);
  }

  @Test
  void trackViewport2DChange_withNothingChanged_recordsNothing () {
    seed();

    app.frameCount = 10;
    app.trackViewport2DChange(); // STUDY untouched since seed()

    assertEquals(1, app.viewport2DHistory.size());
    assertEquals(0, app.viewport2DHistoryIndex);
  }

  @Test
  void trackViewport2DChange_withAChange_appendsANewStepAndAdvancesHistoryIndex () {
    seed();

    recordViewport2DStep(10, app.STUDY.endDay + 5);

    assertEquals(2, app.viewport2DHistory.size());
    assertEquals(1, app.viewport2DHistoryIndex);
  }

  @Test
  void trackViewport2DChange_whileIsRestoringViewport2DSnapshotIsSet_recordsNothing () {
    seed();
    app.isRestoringViewport2DSnapshot = true;

    app.frameCount = 10;
    app.STUDY.endDay = app.STUDY.endDay + 5;
    app.trackViewport2DChange();

    assertEquals(1, app.viewport2DHistory.size());
    assertEquals(0, app.viewport2DHistoryIndex);
  }

  @Test
  void trackViewport2DChange_consecutiveFramesWithChanges_coalesceIntoOneEntry () {
    // Simulates a held End Day spinner drag: STUDY changes a little on
    // several back-to-back frames - the whole continuous gesture should
    // fold into one history entry, not one per frame.
    seed();
    int baselineEndDay = app.STUDY.endDay;

    recordViewport2DStep(10, baselineEndDay + 1);
    assertEquals(2, app.viewport2DHistory.size(), "the first frame of the drag starts a new entry");

    recordViewport2DStep(11, baselineEndDay + 2); // still the same drag - the very next frame
    recordViewport2DStep(12, baselineEndDay + 3); // still the same drag

    assertEquals(2, app.viewport2DHistory.size(), "the whole continuous drag should still be just one entry");
    assertEquals(1, app.viewport2DHistoryIndex);

    app.undoViewport2DChange();

    assertEquals(baselineEndDay, app.STUDY.endDay, "undo should land back on the pre-drag baseline, not some mid-drag frame");
  }

  @Test
  void trackViewport2DChange_separateGesturesWithAQuietFrameBetween_recordsTwoEntries () {
    seed();
    int baselineEndDay = app.STUDY.endDay;

    recordViewport2DStep(10, baselineEndDay + 1); // gesture 1 (e.g. a case-bar wheel notch)
    assertEquals(2, app.viewport2DHistory.size());

    app.frameCount = 11; // a quiet frame in between - nothing changes
    app.trackViewport2DChange();
    assertEquals(2, app.viewport2DHistory.size(), "a quiet frame with nothing changed shouldn't record anything");

    recordViewport2DStep(12, baselineEndDay + 2); // gesture 2 (e.g. a command-line End Day), not contiguous with gesture 1

    assertEquals(3, app.viewport2DHistory.size(), "a gesture separated by a quiet frame should start its own entry, not coalesce into the last one");
    assertEquals(2, app.viewport2DHistoryIndex);
  }

  @Test
  void trackViewport2DChange_boundsHistoryToMaxUndoViewport2DSteps () {
    seed();
    int baselineEndDay = app.STUDY.endDay;

    int frame = 10;
    for (int i = 0; i < app.MAX_UNDO_VIEWPORT2D + 10; i++) {
      recordViewport2DStep(frame, baselineEndDay + (i % 300) + 1); // each its own gesture - frame jumps by 10, well past the "still dragging" window
      frame += 10;
    }

    assertTrue(app.viewport2DHistory.size() <= app.MAX_UNDO_VIEWPORT2D + 1, "expected the list to be capped, was " + app.viewport2DHistory.size());
    assertEquals(app.viewport2DHistory.size() - 1, app.viewport2DHistoryIndex, "historyIndex should still point at the newest entry after trimming");
  }

  // ================= undo / redo ============================================

  @Test
  void undo_atTheBaseline_doesNothing () {
    seed();

    app.undoViewport2DChange();

    assertEquals(0, app.viewport2DHistoryIndex);
    assertEquals(1, app.viewport2DHistory.size());
  }

  @Test
  void redo_atTheNewestEntry_doesNothing () {
    seed();
    recordViewport2DStep(10, app.STUDY.endDay + 5);

    app.redoViewport2DChange();

    assertEquals(1, app.viewport2DHistoryIndex);
  }

  @Test
  void undo_movesHistoryIndexBackOneStep () {
    seed();
    int baselineEndDay = app.STUDY.endDay;
    recordViewport2DStep(10, baselineEndDay + 1);
    recordViewport2DStep(20, baselineEndDay + 2);
    assertEquals(2, app.viewport2DHistoryIndex);

    app.undoViewport2DChange();

    assertEquals(1, app.viewport2DHistoryIndex);
  }

  @Test
  void redo_movesHistoryIndexForwardOneStepAfterAnUndo () {
    seed();
    int baselineEndDay = app.STUDY.endDay;
    recordViewport2DStep(10, baselineEndDay + 1);
    recordViewport2DStep(20, baselineEndDay + 2);
    app.undoViewport2DChange();
    assertEquals(1, app.viewport2DHistoryIndex);

    app.redoViewport2DChange();

    assertEquals(2, app.viewport2DHistoryIndex);
  }

  @Test
  void aFreshGestureAfterAnUndo_discardsTheRedoBranchBeforeAppending () {
    seed(); // history[0]
    int baselineEndDay = app.STUDY.endDay;
    recordViewport2DStep(10, baselineEndDay + 1); // history[1]
    recordViewport2DStep(20, baselineEndDay + 2); // history[2]
    assertEquals(3, app.viewport2DHistory.size());

    app.undoViewport2DChange(); // historyIndex -> 1, history[2] still sitting there as a redo target

    recordViewport2DStep(30, baselineEndDay + 3); // a fresh gesture - history[2] (the old redo branch) must be gone, replaced by this new one

    assertEquals(3, app.viewport2DHistory.size());
    assertEquals(2, app.viewport2DHistoryIndex);
  }

  @Test
  void undoThenRedo_roundTripsSTUDYFieldsExactly () {
    seed(); // baseline
    int baselineEndDay = app.STUDY.endDay;
    int baselineStartHour = app.STUDY.startHour;

    app.frameCount = 10;
    app.STUDY.endDay = baselineEndDay + 1;
    app.trackViewport2DChange(); // history[1]: endDay changed, startHour still at its baseline

    app.frameCount = 20; // a separate gesture
    app.STUDY.endDay = baselineEndDay + 2;
    app.STUDY.startHour = baselineStartHour + 1;
    app.trackViewport2DChange(); // history[2]: both changed

    app.undoViewport2DChange(); // back to history[1]
    assertEquals(baselineEndDay + 1, app.STUDY.endDay);
    assertEquals(baselineStartHour, app.STUDY.startHour, "startHour hadn't changed yet when history[1] was recorded");

    app.undoViewport2DChange(); // back to the baseline
    assertEquals(baselineEndDay, app.STUDY.endDay);
    assertEquals(baselineStartHour, app.STUDY.startHour);

    app.redoViewport2DChange();
    app.redoViewport2DChange();

    assertEquals(baselineEndDay + 2, app.STUDY.endDay);
    assertEquals(baselineStartHour + 1, app.STUDY.startHour);
  }

  @Test
  void undo_revisesEveryViewAStudyChangeMightTouch () {
    // restoreProjectViewport2DSnapshot() has no meaningful old/new pair
    // to diff per field (unlike a live spinner edit), so it takes the
    // broad route: reviseByUpdateFlags(1, 1, 1) - see that function's
    // own body (actions.pde). Checking all four flags it sets is what
    // actually proves that broad follow-up ran, not just that STUDY
    // itself was restored.
    seed();
    recordViewport2DStep(10, app.STUDY.endDay + 5);
    app.UI_caseBar.updated();
    app.UI_rollout.updated();
    app.STUDY.updated();
    app.WIN3D.updated();

    app.undoViewport2DChange();

    assertTrue(app.UI_caseBar.update, "undo must flag UI_caseBar for a redraw");
    assertTrue(app.UI_rollout.update, "undo must flag UI_rollout for a redraw");
    assertTrue(app.STUDY.update, "undo must flag STUDY for a redraw");
    assertTrue(app.WIN3D.update, "undo must flag WIN3D for a redraw");
  }

  @Test
  void undo_forcesTheImpactGraphToRecompute () {
    seed();
    recordViewport2DStep(10, app.STUDY.endDay + 5);
    app.STUDY.updateImpactGraph = false; // simulate "already recomputed this frame"

    app.undoViewport2DChange();

    assertTrue(app.STUDY.updateImpactGraph, "undo must force the Impact graph to recompute from the restored plot layout/impact selection");
  }

  // ================= restoreProjectViewport2DSnapshot: guard behavior =======

  @Test
  void restoreProjectViewport2DSnapshot_clearsTheGuardOnceDone () {
    seed();
    recordViewport2DStep(10, app.STUDY.endDay + 5);

    app.undoViewport2DChange();

    assertFalse(app.isRestoringViewport2DSnapshot, "the guard must be cleared again once the restore finishes");
  }

  @Test
  void restoreProjectViewport2DSnapshot_isNotMistakenForANewGestureOnTheNextFramesPoll () {
    // The actual bug this guards against: without
    // isRestoringViewport2DSnapshot, undoViewport2DChange()'s own
    // STUDY.from_XML() write would look, to the very next frame's
    // trackViewport2DChange(), exactly like a user-driven change - and
    // get recorded as a brand new gesture, turning every undo into a
    // redo-able "change" of its own.
    seed();
    recordViewport2DStep(10, app.STUDY.endDay + 5);
    int sizeBeforeUndo = app.viewport2DHistory.size();

    app.undoViewport2DChange();

    app.frameCount = 11; // the very next frame after the restore
    app.trackViewport2DChange();

    assertEquals(sizeBeforeUndo, app.viewport2DHistory.size(), "the restore itself must not be recorded as a new gesture");
  }

  // ================= independence from the other three histories ============

  @Test
  void modelEditsDoNotRecordAViewport2DHistoryStep () {
    app.Terrain.Mesh = new float[app.Terrain.rowCount][app.Terrain.columnCount][3]; // needed by Terrain.to_XML(), reached by beginScene3DChange()/endScene3DChange() - see UndoRedoTest.java's own setUp()
    app.seedScene3DHistory();
    seed();

    app.beginScene3DChange();
    app.endScene3DChange();

    assertEquals(1, app.viewport2DHistory.size(), "a model edit alone must not touch the Viewport2D history");
  }

  @Test
  void viewportChangesDoNotRecordAViewport2DHistoryStep () {
    app.seedViewport3DHistory();
    seed();

    app.frameCount = 10;
    app.WIN3D.cameraX = 5;
    app.trackViewport3DChange();

    assertEquals(1, app.viewport2DHistory.size(), "a Viewport3D change alone must not touch the Viewport2D history");
  }

  @Test
  void stationChangesDoNotRecordAViewport2DHistoryStep () {
    app.seedStationHistory();
    seed();

    app.frameCount = 10;
    app.STATION.setLatitude(app.STATION.getLatitude() + 5);
    app.trackStationChange();

    assertEquals(1, app.viewport2DHistory.size(), "a station change alone must not touch the Viewport2D history");
  }

  @Test
  void viewport2DChangesDoNotRecordAnyOfTheOtherThreeHistorySteps () {
    app.Terrain.Mesh = new float[app.Terrain.rowCount][app.Terrain.columnCount][3]; // needed by Terrain.to_XML(), reached by seedScene3DHistory() - see UndoRedoTest.java's own setUp()
    app.seedScene3DHistory();
    app.seedViewport3DHistory();
    app.seedStationHistory();
    seed();

    recordViewport2DStep(10, app.STUDY.endDay + 5);

    assertEquals(1, app.scene3DHistory.size(), "a Viewport2D change alone must not touch the model history");
    assertEquals(1, app.viewport3DHistory.size(), "a Viewport2D change alone must not touch the Viewport3D history");
    assertEquals(1, app.stationHistory.size(), "a Viewport2D change alone must not touch the station history");
  }

  @Test
  void undoViewport2DChange_leavesTheModelViewportAndStationUntouched () {
    app.seedViewport3DHistory();
    app.seedStationHistory();
    seed();

    app.WIN3D.cameraX = 42;
    float stationLatitude = app.STATION.getLatitude();
    recordViewport2DStep(10, app.STUDY.endDay + 5);

    app.undoViewport2DChange();

    assertEquals(42f, app.WIN3D.cameraX, 0.0001f, "a Viewport2D undo must leave the 3D viewport exactly as it was");
    assertEquals(stationLatitude, app.STATION.getLatitude(), 0.0001f, "a Viewport2D undo must leave the station exactly as it was");
  }

  // ================= wired as actions (Tools menu) ===========================

  @Test
  void undoViewport2DChangeAction_isRegisteredAndMatchesTheDirectCall () {
    app.allActions = new java.util.HashMap<>(); // fresh app never populates this itself - see UndoRedoViewport3DTest.java's own comment on the same requirement
    app.build_allActions();

    seed();
    int baselineEndDay = app.STUDY.endDay;
    recordViewport2DStep(10, baselineEndDay + 5);

    app.callAction("Undo Viewport2D Change");

    assertEquals(baselineEndDay, app.STUDY.endDay);
    assertEquals(0, app.viewport2DHistoryIndex);
  }

  @Test
  void redoViewport2DChangeAction_isRegisteredAndMatchesTheDirectCall () {
    app.allActions = new java.util.HashMap<>();
    app.build_allActions();

    seed();
    int baselineEndDay = app.STUDY.endDay;
    recordViewport2DStep(10, baselineEndDay + 5);
    app.undoViewport2DChange();

    app.callAction("Redo Viewport2D Change");

    assertEquals(baselineEndDay + 5, app.STUDY.endDay);
    assertEquals(1, app.viewport2DHistoryIndex);
  }

  // ================= menu bar wiring ==========================================

  @Test
  void menuBar_toolsMenuListsUndoAndRedoViewport2DChange () {
    // uiMenuBar.pde's own Items array, not actions.pde's allActions map -
    // this is what actually proves the menu entry exists for a person to
    // click, not just that the backing action is callable.
    String[][] items = app.UI_menuBar.Items;

    boolean foundUndo = false;
    boolean foundRedo = false;
    for (String[] menu : items) {
      if ((menu.length > 0) && "Tools".equals(menu[0])) {
        // Some entries here are null on a bare, just-constructed app
        // instance (divider slots - a separate, pre-existing field-init-
        // order issue unrelated to this feature - see
        // UndoRedoStationTest.java's own comment on the same thing), so
        // this checks each item defensively rather than assuming every
        // slot is a string.
        for (String item : menu) {
          if ("Undo Viewport2D Change".equals(item)) foundUndo = true;
          if ("Redo Viewport2D Change".equals(item)) foundRedo = true;
        }
      }
    }

    assertTrue(foundUndo, "\"Undo Viewport2D Change\" should be listed in the Tools menu");
    assertTrue(foundRedo, "\"Redo Viewport2D Change\" should be listed in the Tools menu");
  }
}
