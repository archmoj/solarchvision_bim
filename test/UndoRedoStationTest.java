import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers undoRedoStation.pde: seedStationHistory()/trackStationChange()
// (the frame-polled stand-in for a begin/end hook, since STATION has
// none of its own - see that file's own header comment),
// undoStationChange()/redoStationChange(), and
// restoreProjectStationSnapshot()'s own behavior (no recursive
// recording, update_station(0) called afterward). Same "bare `new
// solarchvision_bim()`, no setup()" style UndoRedoTest.java/
// UndoRedoViewport3DTest.java already use.
//
// frameCount is simulated here, same reason and same style as
// UndoRedoViewport3DTest.java: a "drag" (the GUI latitude/longitude
// spinner, STATION's own equivalent of a held camera drag) is several
// back-to-back frameCount values each changing STATION a little; a "new
// gesture" is the same but with at least one quiet frameCount value in
// between, which is also what a one-shot change (a map click, a
// command-line SETLAT) naturally looks like - a single changed frame
// with quiet frames on both sides.
class UndoRedoStationTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    // undoStationChange()/redoStationChange() go through
    // restoreProjectStationSnapshot(), which calls update_station(-1) -
    // that reaches update_climateTypicalYear() (among the other
    // Folder_climate*/Folder_ensemble* loaders), which reads
    // Folder_climateTypicalYear. That field is only ever set inside
    // update_input_folders() (updateFolders.pde) - never by BaseFolder
    // alone - so without calling it here too, Folder_climateTypicalYear
    // stays null and the file lookup logs a bogus "null/<filename>.epw"
    // path instead of a real (if still missing, in this temp dir) one.
    // See Earth3DTest.java's own comment on why this is
    // app.BaseFolder = ... rather than app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
    app.update_input_folders(); // Folder_climateTypicalYear/Folder_climateEngineering/... are null until this runs
  }

  // A bare `new solarchvision_bim()` never runs drawInitialFrames.pde's
  // frame-22 branch, so seedStationHistory() - the one thing that
  // actually establishes the baseline - needs calling explicitly here,
  // same as seed() does in the other two undo/redo test files.
  private void seed () {
    app.seedStationHistory();
  }

  // One frame of a station "gesture": sets frameCount, nudges
  // STATION.latitude to some new value (the one field every test below
  // needs to tell snapshots apart), and runs the same per-frame check
  // draw() calls for real. Callers space frame numbers apart by more
  // than 1 to get separate, non-coalescing gestures, and keep them
  // consecutive to simulate one continuous spinner drag.
  private void recordStationStep (int frame, float latitude) {
    app.frameCount = frame;
    app.STATION.setLatitude(latitude);
    app.trackStationChange();
  }

  // ================= seedStationHistory ===================================

  @Test
  void seedStationHistory_establishesASingleBaselineEntry () {
    seed();

    assertEquals(1, app.stationHistory.size());
    assertEquals(0, app.stationHistoryIndex);
  }

  @Test
  void seedStationHistory_calledAgainResetsToANewSingleEntryBaseline () {
    seed();
    recordStationStep(10, 5); // a second entry
    assertEquals(2, app.stationHistory.size());

    seed(); // e.g. Open/Fetch loading a different project, conceptually

    assertEquals(1, app.stationHistory.size());
    assertEquals(0, app.stationHistoryIndex);
  }

  // ================= trackStationChange ===================================

  @Test
  void trackStationChange_beforeSeedHasRun_recordsNothing () {
    assertEquals(-1, app.stationHistoryIndex); // sanity check: seed() was never called

    app.frameCount = 10;
    app.STATION.setLatitude(5);
    app.trackStationChange();

    assertEquals(0, app.stationHistory.size());
    assertEquals(-1, app.stationHistoryIndex);
  }

  @Test
  void trackStationChange_withNothingChanged_recordsNothing () {
    seed();

    app.frameCount = 10;
    app.trackStationChange(); // STATION untouched since seed()

    assertEquals(1, app.stationHistory.size());
    assertEquals(0, app.stationHistoryIndex);
  }

  @Test
  void trackStationChange_withAChange_appendsANewStepAndAdvancesHistoryIndex () {
    seed();

    recordStationStep(10, 5);

    assertEquals(2, app.stationHistory.size());
    assertEquals(1, app.stationHistoryIndex);
  }

  @Test
  void trackStationChange_whileIsRestoringStationSnapshotIsSet_recordsNothing () {
    seed();
    app.isRestoringStationSnapshot = true;

    app.frameCount = 10;
    app.STATION.setLatitude(5);
    app.trackStationChange();

    assertEquals(1, app.stationHistory.size());
    assertEquals(0, app.stationHistoryIndex);
  }

  @Test
  void trackStationChange_consecutiveFramesWithChanges_coalesceIntoOneEntry () {
    // Simulates a held latitude-spinner drag: STATION changes a little
    // on several back-to-back frames - the whole continuous gesture
    // should fold into one history entry, not one per frame.
    seed();
    float baselineLatitude = app.STATION.getLatitude();

    recordStationStep(10, baselineLatitude + 1);
    assertEquals(2, app.stationHistory.size(), "the first frame of the drag starts a new entry");

    recordStationStep(11, baselineLatitude + 2); // still the same drag - the very next frame
    recordStationStep(12, baselineLatitude + 3); // still the same drag

    assertEquals(2, app.stationHistory.size(), "the whole continuous drag should still be just one entry");
    assertEquals(1, app.stationHistoryIndex);

    app.undoStationChange();

    assertEquals(baselineLatitude, app.STATION.getLatitude(), 0.0001f, "undo should land back on the pre-drag baseline, not some mid-drag frame");
  }

  @Test
  void trackStationChange_separateGesturesWithAQuietFrameBetween_recordsTwoEntries () {
    seed();
    float baselineLatitude = app.STATION.getLatitude();

    recordStationStep(10, baselineLatitude + 1); // gesture 1 (e.g. a map click)
    assertEquals(2, app.stationHistory.size());

    app.frameCount = 11; // a quiet frame in between - nothing changes
    app.trackStationChange();
    assertEquals(2, app.stationHistory.size(), "a quiet frame with nothing changed shouldn't record anything");

    recordStationStep(12, baselineLatitude + 2); // gesture 2 (e.g. a command-line SETLAT), not contiguous with gesture 1

    assertEquals(3, app.stationHistory.size(), "a gesture separated by a quiet frame should start its own entry, not coalesce into the last one");
    assertEquals(2, app.stationHistoryIndex);
  }

  @Test
  void trackStationChange_boundsHistoryToMaxUndoStationSteps () {
    seed();
    float baselineLatitude = app.STATION.getLatitude();

    int frame = 10;
    for (int i = 0; i < app.MAX_UNDO_STATION + 10; i++) {
      recordStationStep(frame, baselineLatitude + frame); // each its own gesture - frame jumps by 10, well past the "still dragging" window
      frame += 10;
    }

    assertTrue(app.stationHistory.size() <= app.MAX_UNDO_STATION + 1, "expected the list to be capped, was " + app.stationHistory.size());
    assertEquals(app.stationHistory.size() - 1, app.stationHistoryIndex, "historyIndex should still point at the newest entry after trimming");
  }

  // ================= undo / redo ==========================================

  @Test
  void undo_atTheBaseline_doesNothing () {
    seed();

    app.undoStationChange();

    assertEquals(0, app.stationHistoryIndex);
    assertEquals(1, app.stationHistory.size());
  }

  @Test
  void redo_atTheNewestEntry_doesNothing () {
    seed();
    recordStationStep(10, app.STATION.getLatitude() + 5);

    app.redoStationChange();

    assertEquals(1, app.stationHistoryIndex);
  }

  @Test
  void undo_movesHistoryIndexBackOneStep () {
    seed();
    float baselineLatitude = app.STATION.getLatitude();
    recordStationStep(10, baselineLatitude + 1);
    recordStationStep(20, baselineLatitude + 2);
    assertEquals(2, app.stationHistoryIndex);

    app.undoStationChange();

    assertEquals(1, app.stationHistoryIndex);
  }

  @Test
  void redo_movesHistoryIndexForwardOneStepAfterAnUndo () {
    seed();
    float baselineLatitude = app.STATION.getLatitude();
    recordStationStep(10, baselineLatitude + 1);
    recordStationStep(20, baselineLatitude + 2);
    app.undoStationChange();
    assertEquals(1, app.stationHistoryIndex);

    app.redoStationChange();

    assertEquals(2, app.stationHistoryIndex);
  }

  @Test
  void aFreshGestureAfterAnUndo_discardsTheRedoBranchBeforeAppending () {
    seed(); // history[0]
    float baselineLatitude = app.STATION.getLatitude();
    recordStationStep(10, baselineLatitude + 1); // history[1]
    recordStationStep(20, baselineLatitude + 2); // history[2]
    assertEquals(3, app.stationHistory.size());

    app.undoStationChange(); // historyIndex -> 1, history[2] still sitting there as a redo target

    recordStationStep(30, baselineLatitude + 3); // a fresh gesture - history[2] (the old redo branch) must be gone, replaced by this new one

    assertEquals(3, app.stationHistory.size());
    assertEquals(2, app.stationHistoryIndex);
  }

  @Test
  void undoThenRedo_roundTripsSTATIONFieldsExactly () {
    seed(); // baseline: Toronto (lat 43.67, lon -79.63 - see globalVariables.pde's own STATION construction)
    float baselineLatitude = app.STATION.getLatitude();
    float baselineLongitude = app.STATION.getLongitude();

    app.frameCount = 10;
    app.STATION.setLatitude(baselineLatitude + 1);
    app.trackStationChange(); // history[1]: latitude changed, longitude still at its baseline

    app.frameCount = 20; // a separate gesture
    app.STATION.setLatitude(baselineLatitude + 2);
    app.STATION.setLongitude(baselineLongitude + 2);
    app.trackStationChange(); // history[2]: both changed

    app.undoStationChange(); // back to history[1]
    assertEquals(baselineLatitude + 1, app.STATION.getLatitude(), 0.0001f);
    assertEquals(baselineLongitude, app.STATION.getLongitude(), 0.0001f, "longitude hadn't changed yet when history[1] was recorded");

    app.undoStationChange(); // back to the baseline
    assertEquals(baselineLatitude, app.STATION.getLatitude(), 0.0001f);
    assertEquals(baselineLongitude, app.STATION.getLongitude(), 0.0001f);

    app.redoStationChange();
    app.redoStationChange();

    assertEquals(baselineLatitude + 2, app.STATION.getLatitude(), 0.0001f);
    assertEquals(baselineLongitude + 2, app.STATION.getLongitude(), 0.0001f);
  }

  @Test
  void undo_callsUpdateStationSoDerivedGlobalsResync () {
    // update_station(-1) (called by restoreProjectStationSnapshot()) is
    // what re-syncs the locationLatitude global from STATION, among
    // everything else it does - the same re-sync every other live
    // STATION-moving path relies on too, just at the cheaper Step 0
    // (react.pde's own applyLocationChange, valueModifier.pde's
    // Location Latitude setter) - see undoRedoStation.pde's own header
    // comment for why undo/redo needs the full -1 reload instead.
    // Checking this global, rather than STATION.getLatitude() itself,
    // is what actually proves update_station() ran at all - a plain
    // STATION.from_XML() alone wouldn't touch it.
    seed();
    float baselineLatitude = app.STATION.getLatitude();
    recordStationStep(10, baselineLatitude + 5);

    // trackStationChange() itself never calls update_station() - only a
    // restore does (see undoRedoStation.pde's own header comment) - so
    // locationLatitude is still whatever it was before this edit, same
    // as it would be after any real live edit until that edit's own
    // call site runs update_station() itself. Setting it to a
    // recognizably wrong value here is what actually proves the
    // assertion below: that undo's own update_station(-1) call is what
    // corrects it, not some leftover value from construction.
    app.locationLatitude = -999;

    app.undoStationChange();

    assertEquals(baselineLatitude, app.locationLatitude, 0.0001f, "undo should have called update_station(-1), which re-syncs this global from STATION");
  }

  @Test
  void undo_revisesUI_rolloutSoTheLocationPanelActuallyRedraws () {
    // The actual bug this guards against: without this,
    // restoreProjectStationSnapshot() correctly restores STATION itself
    // (confirmed by undoThenRedo_roundTripsSTATIONFieldsExactly above),
    // but the "Location & Data" panel's own code/city/province/country/
    // elevation/... text fields are read inside applyRolloutUpdate.pde,
    // which bails out immediately unless UI_rollout.update is set - so
    // without a revise() call here, an undo/redo visibly moves the map
    // pin (driven separately by update_station(0)'s own WORLD.revise())
    // while those text fields keep showing whatever was there right
    // before the undo/redo, even though STATION's own data is already
    // correct underneath.
    seed();
    recordStationStep(10, app.STATION.getLatitude() + 5);
    app.UI_rollout.updated(); // simulate "already drawn this frame" (update = false)

    app.undoStationChange();

    assertTrue(app.UI_rollout.update, "undo must flag UI_rollout for a redraw so the Location panel picks up the restored fields");
  }

  // ================= restoreProjectStationSnapshot: guard behavior =======

  @Test
  void restoreProjectStationSnapshot_clearsTheGuardOnceDone () {
    seed();
    recordStationStep(10, app.STATION.getLatitude() + 5);

    app.undoStationChange();

    assertFalse(app.isRestoringStationSnapshot, "the guard must be cleared again once the restore finishes");
  }

  @Test
  void restoreProjectStationSnapshot_isNotMistakenForANewGestureOnTheNextFramesPoll () {
    // The actual bug this guards against: without
    // isRestoringStationSnapshot, undoStationChange()'s own
    // STATION.from_XML() write would look, to the very next frame's
    // trackStationChange(), exactly like a user-driven change - and get
    // recorded as a brand new gesture, turning every undo into a
    // redo-able "change" of its own.
    seed();
    recordStationStep(10, app.STATION.getLatitude() + 5);
    int sizeBeforeUndo = app.stationHistory.size();

    app.undoStationChange();

    app.frameCount = 11; // the very next frame after the restore
    app.trackStationChange();

    assertEquals(sizeBeforeUndo, app.stationHistory.size(), "the restore itself must not be recorded as a new gesture");
  }

  // ================= independence from Scene3D/Viewport3D's own histories

  @Test
  void modelEditsDoNotRecordAStationHistoryStep () {
    app.Terrain.Mesh = new float[app.Terrain.rowCount][app.Terrain.columnCount][3]; // needed by Terrain.to_XML(), reached by beginScene3DChange()/endScene3DChange() - see UndoRedoTest.java's own setUp()
    app.seedScene3DHistory();
    seed();

    app.beginScene3DChange();
    app.endScene3DChange();

    assertEquals(1, app.stationHistory.size(), "a model edit alone must not touch the station history");
  }

  @Test
  void viewportChangesDoNotRecordAStationHistoryStep () {
    app.seedViewport3DHistory();
    seed();

    app.frameCount = 10;
    app.WIN3D.cameraX = 5;
    app.trackViewport3DChange();

    assertEquals(1, app.stationHistory.size(), "a viewport change alone must not touch the station history");
  }

  @Test
  void stationChangesDoNotRecordAViewport3DHistoryStep () {
    app.seedViewport3DHistory();
    seed();

    recordStationStep(10, app.STATION.getLatitude() + 5);

    assertEquals(1, app.viewport3DHistory.size(), "a station change alone must not touch the viewport history");
  }

  @Test
  void undoStationChange_leavesTheModelAndViewportUntouched () {
    app.seedViewport3DHistory();
    seed();

    app.WIN3D.cameraX = 42;
    recordStationStep(10, app.STATION.getLatitude() + 5);

    app.undoStationChange();

    assertEquals(42f, app.WIN3D.cameraX, 0.0001f, "a station undo must leave the viewport exactly as it was");
  }

  // ================= wired as actions (Tools menu) ========================

  @Test
  void undoStationChangeAction_isRegisteredAndMatchesTheDirectCall () {
    app.allActions = new java.util.HashMap<>(); // fresh app never populates this itself - see UndoRedoViewport3DTest.java's own comment on the same requirement
    app.build_allActions();

    seed();
    float baselineLatitude = app.STATION.getLatitude();
    recordStationStep(10, baselineLatitude + 5);

    app.callAction("Undo Station Change");

    assertEquals(baselineLatitude, app.STATION.getLatitude(), 0.0001f);
    assertEquals(0, app.stationHistoryIndex);
  }

  @Test
  void redoStationChangeAction_isRegisteredAndMatchesTheDirectCall () {
    app.allActions = new java.util.HashMap<>();
    app.build_allActions();

    seed();
    float baselineLatitude = app.STATION.getLatitude();
    recordStationStep(10, baselineLatitude + 5);
    app.undoStationChange();

    app.callAction("Redo Station Change");

    assertEquals(baselineLatitude + 5, app.STATION.getLatitude(), 0.0001f);
    assertEquals(1, app.stationHistoryIndex);
  }

  // ================= menu bar wiring ======================================

  @Test
  void menuBar_toolsMenuListsUndoAndRedoStationChange () {
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
        // order issue unrelated to this feature), so this checks each
        // item defensively rather than assuming every slot is a string.
        for (String item : menu) {
          if ("Undo Station Change".equals(item)) foundUndo = true;
          if ("Redo Station Change".equals(item)) foundRedo = true;
        }
      }
    }

    assertTrue(foundUndo, "\"Undo Station Change\" should be listed in the Tools menu");
    assertTrue(foundRedo, "\"Redo Station Change\" should be listed in the Tools menu");
  }
}
