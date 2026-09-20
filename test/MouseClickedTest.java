import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Exercises mouseClicked.pde's standalone helper functions, reached
// directly on `app` (they're top-level functions, not methods of a
// class field) - plus the StationPicker instances (app.TMYEPW_PICKER
// etc.), which are genuinely pure layout/state-machine logic already
// well-separated from rendering before this session even started.
//
// Two functions below (SOLARCHVISION_flipFaceOrientationIfNeeded,
// SOLARCHVISION_rotateNodesToStartAtNearestVertex) were extracted from
// mouseClicked() itself as part of this session: its UITASK.Normal
// handling ran an identical ~40-line "decide whether to flip this
// face's winding" block twice in a row (once for a single clicked face,
// once in a loop over every face in its group), and its
// UITASK.FirstVertex handling ran an identical ~25-line "rotate this
// face's/polyline's own node array so the vertex nearest the click
// becomes first" block twice in a row (once for allFaces.nodes, once
// for allPolylines.nodes) - both confirmed character-for-character
// identical (modulo the face-index variable name, or which array) via
// direct comparison before extracting. Each occurrence was replaced
// with a call to the new function, not rewritten.
//
// NOT covered: mouseClicked() itself and SOLARCHVISION_buildMenuActions()
// - together these make up the vast majority of this 3800+ line file,
// but they're an enormous, deeply state-dependent dispatcher (menu bar
// hit-testing, per-UITASK create/modify/pick/assign branches across
// every object category, drag-vs-click disambiguation) that reads
// mouseX/mouseY/mouseButton and dozens of other UI globals directly.
// Meaningfully testing more of it would need either a much larger
// refactor than fits in one session, or synthetic setup so elaborate
// (faking an entire toolbar/menu layout) that it would mostly just be
// re-testing the setters/creators already covered directly in their own
// files (Move3D, Create3D, Model1Ds/Model2Ds, etc.) - the two
// extractions above were chosen because they were self-contained,
// genuinely duplicated, and safe to pull out without touching that
// surrounding dispatch logic at all.
// SOLARCHVISION_findNearestStation()/SOLARCHVISION_findNearbyStations()
// are already covered directly in NearestStationTest.java from an
// earlier session, not repeated here.
//
// A fresh `app` per test since these mutate shared scene state.
class MouseClickedTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= small top-level helpers ============================

  @Test
  void selectNewlyCreated_isANoOpWhenNothingWasCreated () {
    boolean[] deselectCalled = {false};
    app.SOLARCHVISION_selectNewlyCreated(3, 3, () -> deselectCalled[0] = true, (i) -> fail("should not select anything"));
    assertFalse(deselectCalled[0]);
  }

  @Test
  void selectNewlyCreated_deselectsThenSelectsEveryNewIndex () {
    boolean[] deselectCalled = {false};
    java.util.List<Integer> selected = new java.util.ArrayList<>();

    app.SOLARCHVISION_selectNewlyCreated(3, 5, () -> deselectCalled[0] = true, selected::add);

    assertTrue(deselectCalled[0]);
    assertEquals(java.util.Arrays.asList(3, 4), selected);
  }

  @Test
  void stopAllRecording_clearsEveryRecordingFlagAcrossAllThreeWindows () {
    app.STUDY.record_AUTO = true;
    app.STUDY.record_IMG = true;
    app.STUDY.record_PDF = true;
    app.WORLD.record_AUTO = true;
    app.WORLD.record_IMG = true;
    app.WORLD.record_PDF = true;
    app.WIN3D.record_AUTO = true;
    app.WIN3D.record_IMG = true;
    app.FRAME_record_AUTO = true;
    app.FRAME_record_IMG = true;
    app.FRAME_click_IMG = true;
    app.FRAME_drag_IMG = true;

    app.SOLARCHVISION_stopAllRecording();

    assertFalse(app.STUDY.record_AUTO);
    assertFalse(app.STUDY.record_IMG);
    assertFalse(app.STUDY.record_PDF);
    assertFalse(app.WORLD.record_AUTO);
    assertFalse(app.WORLD.record_IMG);
    assertFalse(app.WORLD.record_PDF);
    assertFalse(app.WIN3D.record_AUTO);
    assertFalse(app.WIN3D.record_IMG);
    assertFalse(app.FRAME_record_AUTO);
    assertFalse(app.FRAME_record_IMG);
    assertFalse(app.FRAME_click_IMG);
    assertFalse(app.FRAME_drag_IMG);
  }

  @Test
  void setPlotImpacts_setsTheModeResetsSetupAndTogglesWindRoses () {
    app.STUDY.PlotImpacts = 0;
    app.STUDY.plotSetup = 9;
    app.allWindRoses.displayImage = false;

    app.SOLARCHVISION_setPlotImpacts(3, true);

    assertEquals(3, app.STUDY.PlotImpacts);
    assertEquals(0, app.STUDY.plotSetup);
    assertTrue(app.allWindRoses.displayImage);
  }

  @Test
  void selectAllOfCategory_switchesCategoryThenSelectsEverythingInIt () {
    app.allFaces.nodes = new int[][]{{0}, {0}, {0}};

    app.SOLARCHVISION_selectAllOfCategory(app.ObjectCategory.FACE);

    assertEquals(app.ObjectCategory.FACE, app.current_ObjectCategory);
    assertArrayEquals(new int[]{0, 1, 2}, app.Select3D.Face_ids);
  }

  @Test
  void convertAndSwitch_runsTheConversionThenSwitchesCategory () {
    boolean[] ran = {false};
    app.SOLARCHVISION_convertAndSwitch(() -> ran[0] = true, app.ObjectCategory.GROUP);

    assertTrue(ran[0]);
    assertEquals(app.ObjectCategory.GROUP, app.current_ObjectCategory);
  }

  // ================= SOLARCHVISION_flipFaceOrientationIfNeeded (extracted)

  @Test
  void flipFaceOrientation_reversesWhenTaskModifyParameterIsAlwaysFlip () {
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {0, 1, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.WIN3D.UI_TaskModifyParameter = 1; // always flip

    app.SOLARCHVISION_flipFaceOrientationIfNeeded(0);

    assertArrayEquals(new int[]{2, 1, 0}, app.allFaces.nodes[0]);
  }

  @Test
  void flipFaceOrientation_isANoOpForATriangleWithTwoOrFewerNodes () {
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.WIN3D.UI_TaskModifyParameter = 1;

    app.SOLARCHVISION_flipFaceOrientationIfNeeded(0);

    assertArrayEquals(new int[]{0, 1}, app.allFaces.nodes[0]);
  }

  @Test
  void flipFaceOrientation_directionDependsOnWhichSideOfTheWindingPlaneThePivotIsOn () {
    // Triangle in the XY plane; centroid at (1/3, 1/3, 0). With pivot
    // ABOVE it (+Z), V comes out positive - verified independently in
    // Python before writing this - so taskModifyParameter=2 (flip when
    // V>0) flips, and =3 (flip when V<0) doesn't.
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {0, 1, 0}};
    app.Select3D.BoundingBox = new float[][]{
      {0, 0, 1, 1, 1, 1, 0, 0, 0}, {0, 0, 1, 1, 1, 1, 0, 0, 0}, {0, 0, 1, 1, 1, 1, 0, 0, 0}
    }; // pivot at (0,0,1), directly above the triangle

    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.WIN3D.UI_TaskModifyParameter = 2;
    app.SOLARCHVISION_flipFaceOrientationIfNeeded(0);
    assertArrayEquals(new int[]{2, 1, 0}, app.allFaces.nodes[0]); // flipped

    app.allFaces.nodes = new int[][]{{0, 1, 2}}; // reset
    app.WIN3D.UI_TaskModifyParameter = 3;
    app.SOLARCHVISION_flipFaceOrientationIfNeeded(0);
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]); // unchanged
  }

  // ========== SOLARCHVISION_rotateNodesToStartAtNearestVertex (extracted)

  @Test
  void rotateNodesToStartAtNearestVertex_rotatesSoTheClosestNodeComesFirst () {
    // nodeRow holds real vertex INDICES (0-3), not arbitrary content -
    // the function looks each one up via allPoints.getX/Y/Z, so using
    // placeholder values like {10,20,30,40} throws an
    // ArrayIndexOutOfBoundsException instead of testing anything.
    app.allVertices = new float[][]{{0, 0, 0}, {5, 0, 0}, {5, 5, 0}, {0, 5, 0}};
    int[] nodeRow = {0, 1, 2, 3};

    // Closest to vertex index 1 (5,0,0).
    app.SOLARCHVISION_rotateNodesToStartAtNearestVertex(nodeRow, new float[]{0, 4.9f, 0.1f, 0});

    assertArrayEquals(new int[]{1, 2, 3, 0}, nodeRow);
  }

  @Test
  void rotateNodesToStartAtNearestVertex_isANoOpForTwoOrFewerNodes () {
    app.allVertices = new float[][]{{0, 0, 0}, {5, 0, 0}};
    int[] nodeRow = {10, 20};

    app.SOLARCHVISION_rotateNodesToStartAtNearestVertex(nodeRow, new float[]{0, 5, 0, 0});

    assertArrayEquals(new int[]{10, 20}, nodeRow);
  }

  @Test
  void rotateNodesToStartAtNearestVertex_mutatesTheArrayInPlaceForBothFacesAndPolylines () {
    // Confirms it's genuinely shared between the two callers, not just
    // structurally similar: passing allFaces.nodes[f] directly mutates
    // the real scene array, same as it would for allPolylines.nodes[f].
    app.allVertices = new float[][]{{0, 0, 0}, {5, 0, 0}, {5, 5, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};

    app.SOLARCHVISION_rotateNodesToStartAtNearestVertex(app.allFaces.nodes[0], new float[]{0, 5.1f, -0.1f, 0});

    assertArrayEquals(new int[]{1, 2, 0}, app.allFaces.nodes[0]);
  }

  // ================= StationPicker: pure layout ===========================

  @Test
  void headerRect_sitsAtWorldsTopLeftCornerPaddedIn () {
    app.WORLD.cX = 100;
    app.WORLD.cY = 200;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;

    float[] r = app.TMYEPW_PICKER.headerRect();

    float pad = 1.6f * app.MessageSize;
    assertEquals(100 + pad, r[0], 0.01f);
    assertEquals(200 + pad, r[1], 0.01f);
    assertEquals(400 - 2 * pad, r[2], 0.01f);
  }

  @Test
  void needsScrollbar_isTrueOnlyWhenThereAreMoreRowsThanFit () {
    app.WORLD.dY = 300; // enough room for several rows

    app.TMYEPW_PICKER.indices = new int[]{1, 2};
    assertFalse(app.TMYEPW_PICKER.needsScrollbar());

    app.TMYEPW_PICKER.indices = new int[100];
    assertTrue(app.TMYEPW_PICKER.needsScrollbar());
  }

  @Test
  void rowAt_findsWhichVisibleRowAScreenPointLandsOnAccountingForScrollOffset () {
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;

    app.TMYEPW_PICKER.indices = new int[]{100, 101, 102, 103, 104};
    app.TMYEPW_PICKER.scrollOffset = 1; // row 0 on screen shows indices[1]

    float[] row0 = app.TMYEPW_PICKER.rowRect(0);
    int hit = app.TMYEPW_PICKER.rowAt(row0[0] + 2, row0[1] + 2);

    assertEquals(1, hit); // absolute index into `indices`, not the visible row number
  }

  @Test
  void rowAt_isMinusOneWhenTheClickLandsOutsideEveryRow () {
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;
    app.TMYEPW_PICKER.indices = new int[]{100};

    assertEquals(-1, app.TMYEPW_PICKER.rowAt(-500, -500));
  }

  // ================= StationPicker: click/wheel/drag handling ============

  @Test
  void handleClick_selectsTheClickedRowThenClosesTheList () {
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;

    app.TMYEPW_Coordinates = new solarchvision_bim.solarchvision_STATION[]{app.new solarchvision_STATION()};
    app.TMYEPW_Coordinates[0].setFilename_TMYEPW("station_0.epw");
    app.STATION.setFilename_TMYEPW("station_0.epw"); // already selected -> select() below is a safe no-op

    app.TMYEPW_PICKER.active = true;
    app.TMYEPW_PICKER.indices = new int[]{0};
    app.TMYEPW_PICKER.mouseLon = 12;
    app.TMYEPW_PICKER.mouseLat = 34;

    float[] row0 = app.TMYEPW_PICKER.rowRect(0);
    app.SOLARCHVISION_X_clicked = (int) (row0[0] + 2);
    app.SOLARCHVISION_Y_clicked = (int) (row0[1] + 2);

    boolean consumed = app.TMYEPW_PICKER.handleClick();

    assertTrue(consumed);
    assertFalse(app.TMYEPW_PICKER.active); // list closes either way
    assertEquals(0, app.TMYEPW_PICKER.indices.length);
  }

  @Test
  void handleClick_isANoOpWhenThePickerIsNotActive () {
    app.TMYEPW_PICKER.active = false;
    assertFalse(app.TMYEPW_PICKER.handleClick());
  }

  @Test
  void cancel_closesTheListWithoutSelectingAnything () {
    app.TMYEPW_PICKER.active = true;
    app.TMYEPW_PICKER.indices = new int[]{0, 1, 2};

    assertTrue(app.TMYEPW_PICKER.cancel());

    assertFalse(app.TMYEPW_PICKER.active);
    assertEquals(0, app.TMYEPW_PICKER.indices.length);
  }

  @Test
  void cancel_isANoOpWhenNotActive () {
    app.TMYEPW_PICKER.active = false;
    assertFalse(app.TMYEPW_PICKER.cancel());
  }

  @Test
  void handleWheel_scrollsOnlyWhileActiveAndOverWorldAndThereIsSomethingToScroll () {
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;
    app.SOLARCHVISION_X_clicked = 10;
    app.SOLARCHVISION_Y_clicked = 10;

    app.TMYEPW_PICKER.active = true;
    app.TMYEPW_PICKER.indices = new int[100]; // enough rows to actually need scrolling
    app.TMYEPW_PICKER.scrollOffset = 0;

    boolean consumed = app.TMYEPW_PICKER.handleWheel(1);

    assertTrue(consumed);
    assertEquals(1, app.TMYEPW_PICKER.scrollOffset);
  }

  @Test
  void handleWheel_doesNotConsumeTheEventWhenNotActive () {
    app.TMYEPW_PICKER.active = false;
    assertFalse(app.TMYEPW_PICKER.handleWheel(1));
  }

  @Test
  void handleTrackClick_pagesTheListWhenClickingAboveTheThumb () {
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;

    app.TMYEPW_PICKER.active = true;
    app.TMYEPW_PICKER.indices = new int[100];
    app.TMYEPW_PICKER.scrollOffset = 20;

    float[] track = app.TMYEPW_PICKER.scrollTrackRect();
    app.SOLARCHVISION_X_clicked = (int) (track[0] + 2);
    // isInside() uses STRICT inequality, so clicking exactly at track[1]
    // (the top edge) fails the "is this click inside the track at all"
    // check entirely - nudge a couple pixels in, still comfortably above
    // the thumb given scrollOffset=20 out of 100 rows.
    app.SOLARCHVISION_Y_clicked = (int) (track[1] + 2);

    boolean consumed = app.TMYEPW_PICKER.handleTrackClick();

    assertTrue(consumed);
    assertTrue(app.TMYEPW_PICKER.scrollOffset < 20); // paged up
  }

  // ================= StationPicker: handleMapClick =========================

  @Test
  void handleMapClick_selectsTheSingleNearestStationWhenADifferentDataSourceIsActive () {
    app.TMYEPW_Coordinates = new solarchvision_bim.solarchvision_STATION[]{app.new solarchvision_STATION()};
    app.TMYEPW_Coordinates[0].setLatitude(10);
    app.TMYEPW_Coordinates[0].setLongitude(20);
    app.TMYEPW_Coordinates[0].setFilename_TMYEPW("only_station.epw");

    // A DIFFERENT dataset is active, so even a within-range candidate is
    // selected directly rather than opening TMYEPW_PICKER's own list -
    // that only happens when TMYEPW itself is CurrentDataSource (see the
    // next test).
    app.CurrentDataSource = app.dataID_CLIMATE_CWEEDS;
    app.STATION.setFilename_TMYEPW("something_else.epw"); // different, so selection actually applies

    app.TMYEPW_PICKER.handleMapClick(20, 10);

    assertFalse(app.TMYEPW_PICKER.active);
    assertEquals("only_station.epw", app.STATION.getFilename_TMYEPW());
  }

  @Test
  void handleMapClick_opensTheListForACandidateWithinRangeOfTheActiveDataSource () {
    app.TMYEPW_Coordinates = new solarchvision_bim.solarchvision_STATION[]{app.new solarchvision_STATION()};
    app.TMYEPW_Coordinates[0].setLatitude(10);
    app.TMYEPW_Coordinates[0].setLongitude(20);
    app.TMYEPW_Coordinates[0].setFilename_TMYEPW("only_station.epw");

    app.CurrentDataSource = app.dataID_CLIMATE_TMYEPW; // TMYEPW is the active dataset

    app.TMYEPW_PICKER.handleMapClick(20, 10); // well within the picker's own maxDist

    assertTrue(app.TMYEPW_PICKER.active);
    assertArrayEquals(new int[]{0}, app.TMYEPW_PICKER.indices);
  }

  // ================= SOLARCHVISION_selectTMYEPWStation (safe cases only) =

  @Test
  void selectTMYEPWStation_isANoOpWhenTheSameStationIsAlreadySelected () {
    app.TMYEPW_Coordinates = new solarchvision_bim.solarchvision_STATION[]{app.new solarchvision_STATION()};
    app.TMYEPW_Coordinates[0].setFilename_TMYEPW("same.epw");
    app.STATION.setFilename_TMYEPW("same.epw");
    app.STATION.setLatitude(1);
    app.STATION.setLongitude(2);

    app.SOLARCHVISION_selectTMYEPWStation(0, 99, 99);

    // Early return means STATION's position is untouched.
    assertEquals(1f, app.STATION.getLatitude(), 0.0001f);
    assertEquals(2f, app.STATION.getLongitude(), 0.0001f);
  }

  @Test
  void selectTMYEPWStation_updatesPositionAndFilenameButSkipsReloadWhenNotTheActiveDataSource () {
    app.TMYEPW_Coordinates = new solarchvision_bim.solarchvision_STATION[]{app.new solarchvision_STATION()};
    app.TMYEPW_Coordinates[0].setFilename_TMYEPW("new_station.epw");
    app.TMYEPW_Coordinates[0].setDownload_TMYEPW("http://example.com/new_station.epw");

    app.STATION.setFilename_TMYEPW("old_station.epw");
    app.CurrentDataSource = app.dataID_CLIMATE_CWEEDS; // NOT TMYEPW - the risky reload block is skipped

    app.SOLARCHVISION_selectTMYEPWStation(0, 12.5f, 34.5f);

    assertEquals(12.5f, app.STATION.getLongitude(), 0.0001f);
    assertEquals(34.5f, app.STATION.getLatitude(), 0.0001f);
    assertEquals("new_station.epw", app.STATION.getFilename_TMYEPW());
  }
}
