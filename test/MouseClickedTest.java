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
// Three more functions below (SOLARCHVISION_pickOrAssignFaceProperty,
// SOLARCHVISION_pickOrAssignModel2DSeedMaterial,
// SOLARCHVISION_pickOrAssignModel1DProperty) were extracted from
// mouseClicked() in this session too: its UITASK.Seed_Material/
// Tessellation/Layer/Visibility/Weight handling for a clicked FACE (or
// GROUP/POLYLINE resolving to one), its Seed_Material handling for a
// clicked MODEL2D instance, and its per-property handling for a clicked
// MODEL1D instance were each a single self-contained "read
// WIN3D.UI_CurrentTask/UI_TaskModifyParameter, either Pick into a
// User3D.default_*/create_* field or Assign back onto the object(s)"
// block, reachable from exactly one call site each and not touching
// mouseX/mouseY/mouseButton or any Select3D/UI state - unlike the
// dispatcher around them. Each was moved out verbatim (structure only,
// no behavior change), including one existing quirk preserved
// deliberately rather than fixed: SOLARCHVISION_pickOrAssignFaceProperty's
// Assign(all) branch calls allFaces.setClose(...) for the Weight case
// instead of setWeight(...), same as the original inline code did.
//
// NOT covered: mouseClicked() itself and SOLARCHVISION_buildMenuActions()
// - together these still make up the vast majority of this 3800+ line
// file, but they're an enormous, deeply state-dependent dispatcher (menu
// bar hit-testing, per-UITASK create/modify/pick/assign branches across
// every object category, drag-vs-click disambiguation) that reads
// mouseX/mouseY/mouseButton and dozens of other UI globals directly.
// Meaningfully testing more of it would need either a much larger
// refactor than fits in one session, or synthetic setup so elaborate
// (faking an entire toolbar/menu layout) that it would mostly just be
// re-testing the setters/creators already covered directly in their own
// files (Move3D, Create3D, Model1Ds/Model2Ds, etc.) - the extractions
// above were chosen because they were self-contained, genuinely
// duplicated or cleanly single-purpose, and safe to pull out without
// touching that surrounding dispatch logic at all.
// SOLARCHVISION_findNearestStation()/SOLARCHVISION_findNearbyStations()
// are already covered directly in NearestStationTest.java from an
// earlier session, not repeated here.
//
// A fourth function, SOLARCHVISION_computeClickRay, was extracted this
// session as well - and unlike the others, it genuinely deduplicates
// code across two different files: WIN3D.pde's own
// rotateXY_3DViewport_around_LandIntersection() had this exact "turn a
// screen click into a 3D ray, accounting for perspective vs.
// orthographic view" setup inlined a second time, confirmed
// character-for-character identical (modulo `this.` vs `WIN3D.` on the
// handful of fields it reads, since that copy lived inside the WIN3D
// class itself) before extracting - both call sites now call this one
// function instead.
//
// Two more functions, SOLARCHVISION_getMoveOriginPoint and
// SOLARCHVISION_computeMoveDelta, were extracted from mouseClicked()'s
// UITASK.Move handling this session: finding the selected object's own
// reference point (a GROUP's pivot, or the last-selected id's position
// for MODEL2D/MODEL1D/SOLID/VERTEX - any other category left
// undefined, same as before) and turning that plus the clicked point
// into a move vector constrained to Select3D.posVector's axis. A small,
// genuinely dead commented-out alternative implementation
// (Select3D.translateOutside_ReferencePivot(...)) that sat in the
// original delta computation was dropped during the extraction - it
// was already inert (commented out), so removing it doesn't change
// behavior.
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

  // ============ SOLARCHVISION_computeCreateParams (extracted) ===========

  @Test
  void computeCreateParams_derivesHalfExtentsAndRotationFromUserPreferences () {
    app.User3D.create_Orientation = 0; // not 360, so this is used directly rather than falling back to WIN3D.rotation_Z
    app.User3D.create_Length = 4;  // positive -> deterministic, no randomize
    app.User3D.create_Width = 6;
    app.User3D.create_Height = 2;
    app.User3D.create_powX = 2;
    app.User3D.create_powY = 2;
    app.User3D.create_powZ = 2;
    app.User3D.create_powRnd = 0;
    app.User3D.create_Volume = 0;
    app.current_ObjectCategory = app.ObjectCategory.SOLID; // not excluded from the alignment offset
    app.Select3D.alignX = 0;
    app.Select3D.alignY = 0;
    app.Select3D.alignZ = 0;

    solarchvision_bim.SOLARCHVISION_CreateParams p = app.SOLARCHVISION_computeCreateParams(new float[]{0, 10, 20, 30});

    assertEquals(10f, p.x, 0.0001f);
    assertEquals(20f, p.y, 0.0001f);
    assertEquals(30f, p.z, 0.0001f);
    assertEquals(0f, p.rot, 0.0001f);
    assertEquals(2f, p.rx, 0.0001f); // half of create_Length
    assertEquals(3f, p.ry, 0.0001f); // half of create_Width
    assertEquals(1f, p.rz, 0.0001f); // half of create_Height
    assertEquals(2f, p.px, 0.0001f);
    assertEquals(2f, p.py, 0.0001f);
    assertEquals(2f, p.pz, 0.0001f);
  }

  @Test
  void computeCreateParams_orientation360FallsBackToTheCurrentViewportRotation () {
    app.User3D.create_Orientation = 360;
    app.WIN3D.rotation_Z = 47;
    app.User3D.create_Length = 1;
    app.User3D.create_Width = 1;
    app.User3D.create_Height = 1;

    solarchvision_bim.SOLARCHVISION_CreateParams p = app.SOLARCHVISION_computeCreateParams(new float[]{0, 0, 0, 0});

    assertEquals(47f, p.rot, 0.0001f);
  }

  @Test
  void computeCreateParams_offsetsPositionByHalfExtentsScaledByAlignment () {
    app.User3D.create_Length = 4; // rx=2
    app.User3D.create_Width = 6;  // ry=3
    app.User3D.create_Height = 2; // rz=1
    app.current_ObjectCategory = app.ObjectCategory.SOLID; // not excluded from this offset
    app.Select3D.alignX = 1;
    app.Select3D.alignY = -1;
    app.Select3D.alignZ = 0;

    solarchvision_bim.SOLARCHVISION_CreateParams p = app.SOLARCHVISION_computeCreateParams(new float[]{0, 10, 20, 30});

    assertEquals(10 - 2 * 1, p.x, 0.0001f); // x -= rx * alignX
    assertEquals(20 - 3 * -1, p.y, 0.0001f); // y -= ry * alignY
    assertEquals(30f, p.z, 0.0001f); // alignZ=0 -> unchanged
  }

  @Test
  void computeCreateParams_skipsTheAlignmentOffsetForModel1DModel2DLandPointCameraAndSection () {
    app.User3D.create_Length = 4;
    app.Select3D.alignX = 1; // would shift x if this category weren't excluded

    for (int category : new int[]{
      app.ObjectCategory.MODEL1D, app.ObjectCategory.MODEL2D, app.ObjectCategory.LANDPOINT,
      app.ObjectCategory.CAMERA, app.ObjectCategory.SECTION
    }) {
      app.current_ObjectCategory = category;
      solarchvision_bim.SOLARCHVISION_CreateParams p = app.SOLARCHVISION_computeCreateParams(new float[]{0, 10, 20, 30});
      assertEquals(10f, p.x, 0.0001f, "category " + category + " should not be offset");
    }
  }

  @Test
  void computeCreateParams_derivesHeightFromVolumeWhenVolumeIsSet () {
    app.User3D.create_Length = 4; // rx=2
    app.User3D.create_Width = 4;  // ry=2
    app.User3D.create_Height = 999; // overridden by the volume calculation below
    app.User3D.create_powX = 2;
    app.User3D.create_powY = 2;
    app.User3D.create_powZ = 2; // A=0.5 for pz==2
    app.User3D.create_Volume = 32; // rz = 32 / (8*2*2) = 1, then divided by A^(1/3)

    solarchvision_bim.SOLARCHVISION_CreateParams p = app.SOLARCHVISION_computeCreateParams(new float[]{0, 0, 0, 0});

    float expectedRz = (1f) / (float) Math.pow(0.5, 1.0 / 3.0);
    assertEquals(expectedRz, p.rz, 0.001f);
  }

  @Test
  void computeCreateParams_negativeLengthRandomizesWithinAQuarterToFullOfItsMagnitude () {
    app.User3D.create_Length = -8; // "randomize" sentinel: 0.5*(-8) = -4 -> rx becomes random(1, 4)

    solarchvision_bim.SOLARCHVISION_CreateParams p = app.SOLARCHVISION_computeCreateParams(new float[]{0, 0, 0, 0});

    assertTrue(p.rx >= 1f && p.rx <= 4f);
  }

  // ======== SOLARCHVISION_computeCameraParamsAtPoint (extracted) ========

  @Test
  void computeCameraParamsAtPoint_derivesPositionFromCamSpaceUnderIdentityRotation () {
    // Verified independently in Python beforehand, reusing the same
    // reverseTransform_3DViewport formula already confirmed in
    // WIN3DTest.java's round-trip test.
    app.WIN3D.rotation_X = 0;
    app.WIN3D.rotation_Z = 0;
    app.EyeLevel = 1.5f;

    solarchvision_bim.SOLARCHVISION_CameraParams cp = app.SOLARCHVISION_computeCameraParamsAtPoint(10, 20, 30);

    assertEquals(-10f, cp.pX, 0.01f);
    assertEquals(20f, cp.pY, 0.01f);
    assertEquals(55.1025f, cp.pZ, 0.01f);
  }

  @Test
  void computeCameraParamsAtPoint_accountsForTheCurrentViewportRotation () {
    app.WIN3D.rotation_X = 90;
    app.WIN3D.rotation_Z = -45;
    app.EyeLevel = 1.5f;

    solarchvision_bim.SOLARCHVISION_CameraParams cp = app.SOLARCHVISION_computeCameraParamsAtPoint(10, 20, 30);

    assertEquals(7.0711f, cp.pX, 0.01f);
    assertEquals(31.5f, cp.pY, 0.01f);
    assertEquals(107.8157f, cp.pZ, 0.01f);
  }

  @Test
  void computeCameraParamsAtPoint_leavesWIN3DsOwnStateExactlyAsItWasBeforeTheCall () {
    app.WIN3D.CAM_x = 111;
    app.WIN3D.CAM_y = 222;
    app.WIN3D.CAM_z = 333;
    app.WIN3D.position_X = 1;
    app.WIN3D.position_Y = 2;
    app.WIN3D.position_Z = 3;
    app.WIN3D.rotation_X = 4;
    app.WIN3D.rotation_Y = 5;
    app.WIN3D.rotation_Z = 6;
    app.WIN3D.Zoom = 77;

    app.SOLARCHVISION_computeCameraParamsAtPoint(10, 20, 30);

    assertEquals(111f, app.WIN3D.CAM_x, 0.0001f);
    assertEquals(222f, app.WIN3D.CAM_y, 0.0001f);
    assertEquals(333f, app.WIN3D.CAM_z, 0.0001f);
    assertEquals(1f, app.WIN3D.position_X, 0.0001f);
    assertEquals(2f, app.WIN3D.position_Y, 0.0001f);
    assertEquals(3f, app.WIN3D.position_Z, 0.0001f);
    assertEquals(4f, app.WIN3D.rotation_X, 0.0001f);
    assertEquals(5f, app.WIN3D.rotation_Y, 0.0001f);
    assertEquals(6f, app.WIN3D.rotation_Z, 0.0001f);
    assertEquals(77f, app.WIN3D.Zoom, 0.0001f);
  }

  @Test
  void computeCameraParamsAtPoint_returnsTheCurrentViewportTypeAndZoom () {
    app.WIN3D.ViewType = 1;
    app.WIN3D.Zoom = 55;

    solarchvision_bim.SOLARCHVISION_CameraParams cp = app.SOLARCHVISION_computeCameraParamsAtPoint(0, 0, 0);

    assertEquals(1, cp.type);
    assertEquals(55f, cp.zoom, 0.0001f);
  }

  // ======= SOLARCHVISION_computeSectionParams (extracted) ================

  @Test
  void computeSectionParams_horizontalFaceProducesATypeOneSectionAtItsCentroid () {
    // A flat, CCW-wound square in the XY plane at Z=5 - its bounding box
    // is thinnest along Z, so this becomes a horizontal (Type 1) section
    // centered at the face's own centroid. Verified independently in
    // Python beforehand, including the second-pass "is this section
    // built backwards" check - this winding does NOT trigger a flip.
    app.allVertices = new float[][]{{0, 0, 5}, {2, 0, 5}, {2, 2, 5}, {0, 2, 5}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.mouseButton = app.LEFT;

    solarchvision_bim.SOLARCHVISION_SectionParams sp = app.SOLARCHVISION_computeSectionParams(0, new float[]{0, 0, 0, 0});

    assertTrue(sp.createNew);
    assertEquals(1, sp.Type);
    assertEquals(1f, sp.X, 0.001f);
    assertEquals(1f, sp.Y, 0.001f);
    assertEquals(5f, sp.Z, 0.001f);
    assertEquals(0f, sp.R, 0.001f);
    assertEquals(2f, sp.U, 0.001f);
    assertEquals(2f, sp.V, 0.001f);
  }

  @Test
  void computeSectionParams_verticalFaceProducesATypeTwoSection () {
    // A flat square standing in the XZ plane (constant Y) - thinnest
    // along Y, becoming a vertical (Type 2) section.
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 0, 4}, {0, 0, 4}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.mouseButton = app.LEFT;

    solarchvision_bim.SOLARCHVISION_SectionParams sp = app.SOLARCHVISION_computeSectionParams(0, new float[]{0, 0, 0, 0});

    assertTrue(sp.createNew);
    assertEquals(2, sp.Type);
    assertEquals(1f, sp.X, 0.001f);
    assertEquals(2f, sp.Y, 0.001f);
    assertEquals(0f, sp.Z, 0.001f);
    assertEquals(2f, sp.U, 0.001f);
    assertEquals(4f, sp.V, 0.001f);
  }

  @Test
  void computeSectionParams_detectsAndCorrectsABackwardsWoundFace () {
    // Same horizontal square as the first test, but wound clockwise
    // instead of counter-clockwise - the second-pass consistency check
    // (comparing the face's own normal against the resulting section
    // plane's normal) now finds them pointing opposite ways and flips
    // the section (R += 180, X and Z negated) to compensate. Confirmed
    // in Python beforehand that this exact winding is what triggers it.
    app.allVertices = new float[][]{{0, 0, 5}, {0, 2, 5}, {2, 2, 5}, {2, 0, 5}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.mouseButton = app.LEFT;

    solarchvision_bim.SOLARCHVISION_SectionParams sp = app.SOLARCHVISION_computeSectionParams(0, new float[]{0, 0, 0, 0});

    assertEquals(1, sp.Type);
    assertEquals(-1f, sp.X, 0.001f);
    assertEquals(1f, sp.Y, 0.001f);
    assertEquals(-5f, sp.Z, 0.001f);
    assertEquals(180f, sp.R, 0.001f);
  }

  @Test
  void computeSectionParams_rightClickAlwaysCreatesAHorizontalSectionAtTheClickPoint () {
    app.mouseButton = app.RIGHT;

    solarchvision_bim.SOLARCHVISION_SectionParams sp = app.SOLARCHVISION_computeSectionParams(0, new float[]{0, 11, 22, 33});

    assertTrue(sp.createNew);
    assertEquals(1, sp.Type);
    assertEquals(11f, sp.X, 0.0001f);
    assertEquals(22f, sp.Y, 0.0001f);
    assertEquals(33f, sp.Z, 0.0001f);
  }

  @Test
  void computeSectionParams_isANoOpForATwoNodeFaceOnLeftClick () {
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}}; // only 2 nodes - too few for a plane
    app.mouseButton = app.LEFT;

    app.allSolidImpacts.X[app.allSolidImpacts.sectionType] = 99;
    app.allSolidImpacts.sectionType = 0;

    solarchvision_bim.SOLARCHVISION_SectionParams sp = app.SOLARCHVISION_computeSectionParams(0, new float[]{0, 0, 0, 0});

    assertFalse(sp.createNew);
    assertEquals(99f, sp.X, 0.0001f); // left at allSolidImpacts' current default, untouched
  }

  // ======= SOLARCHVISION_pickOrAssignFaceProperty (extracted) ===========

  @Test
  void pickOrAssignFaceProperty_isANoOpWhenTheCurrentTaskIsntOneOfTheFiveProperties () {
    app.WIN3D.UI_CurrentTask = app.UITASK.Move; // not one of the five
    app.WIN3D.UI_TaskModifyParameter = 1;
    app.allFaces.options = new int[][]{{9, 9, 9, 9, 9, 9}};
    app.User3D.default_Material = -1;

    app.SOLARCHVISION_pickOrAssignFaceProperty(0);

    assertEquals(-1, app.User3D.default_Material); // untouched
  }

  @Test
  void pickOrAssignFaceProperty_pickReadsTheClickedFacesValueIntoTheMatchingDefault () {
    app.WIN3D.UI_CurrentTask = app.UITASK.Seed_Material;
    app.WIN3D.UI_TaskModifyParameter = 1; // Pick
    app.allFaces.options = new int[][]{{42, 0, 0, 0, 0, 0}};

    app.SOLARCHVISION_pickOrAssignFaceProperty(0);

    assertEquals(42, app.User3D.default_Material);
  }

  @Test
  void pickOrAssignFaceProperty_assignSubWritesTheDefaultOntoJustTheClickedFace () {
    app.WIN3D.UI_CurrentTask = app.UITASK.Weight;
    app.WIN3D.UI_TaskModifyParameter = 2; // Assign(sub)
    app.User3D.default_Weight = 7;
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}};

    app.SOLARCHVISION_pickOrAssignFaceProperty(0);

    assertEquals(7, app.allFaces.getWeight(0));
    assertEquals(0, app.allFaces.getWeight(1)); // the other face is untouched
  }

  @Test
  void pickOrAssignFaceProperty_assignAllWritesTheDefaultOntoEveryFaceInTheClickedFacesGroup () {
    app.WIN3D.UI_CurrentTask = app.UITASK.Layer;
    app.WIN3D.UI_TaskModifyParameter = 3; // Assign(all)
    app.User3D.default_Layer = 5;
    app.allFaces.options = new int[][]{
      {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}
    };
    app.allGroups.makeEmpty(0);
    app.allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0); // group spanning faces [0,3) at creation time
    app.allGroups.setStart_Face(0, 0);
    app.allGroups.setStop_Face(0, 2); // faces 0..2 belong to this one group

    app.SOLARCHVISION_pickOrAssignFaceProperty(1); // click lands on the middle face of the group

    assertEquals(5, app.allFaces.getLayer(0));
    assertEquals(5, app.allFaces.getLayer(1));
    assertEquals(5, app.allFaces.getLayer(2));
  }

  @Test
  void pickOrAssignFaceProperty_assignAllsWeightCaseUsesSetCloseNotSetWeight () {
    // Documents the pre-existing quirk this extraction preserves
    // verbatim rather than fixing: unlike Pick and Assign(sub) just
    // above it, Assign(all)'s Weight case writes via allFaces.setClose,
    // not setWeight.
    app.WIN3D.UI_CurrentTask = app.UITASK.Weight;
    app.WIN3D.UI_TaskModifyParameter = 3; // Assign(all)
    app.User3D.default_Weight = 3;
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.allGroups.makeEmpty(0);
    app.allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    app.allGroups.setStart_Face(0, 0);
    app.allGroups.setStop_Face(0, 0);

    app.SOLARCHVISION_pickOrAssignFaceProperty(0);

    assertEquals(0, app.allFaces.getWeight(0)); // NOT written
    assertEquals(3, app.allFaces.getClose(0));   // written instead
  }

  // === SOLARCHVISION_pickOrAssignModel2DSeedMaterial (extracted) ========

  @Test
  void pickOrAssignModel2DSeedMaterial_isANoOpWhenTheCurrentTaskIsntSeedMaterial () {
    app.WIN3D.UI_CurrentTask = app.UITASK.Move;
    app.WIN3D.UI_TaskModifyParameter = 1;
    app.allModel2Ds.num_files_PEOPLE = 2;
    app.allModel2Ds.MAP = new int[]{5};
    app.User3D.create_Plant_Type = -1;

    app.SOLARCHVISION_pickOrAssignModel2DSeedMaterial(0);

    assertEquals(-1, app.User3D.create_Plant_Type); // untouched
  }

  @Test
  void pickOrAssignModel2DSeedMaterial_pickOfAPersonReadsItsTypeIntoCreatePersonType () {
    app.WIN3D.UI_CurrentTask = app.UITASK.Seed_Material;
    app.WIN3D.UI_TaskModifyParameter = 1; // Pick
    app.allModel2Ds.num_files_PEOPLE = 5;
    app.allModel2Ds.MAP = new int[]{3}; // 3 <= num_files_PEOPLE -> a person

    app.SOLARCHVISION_pickOrAssignModel2DSeedMaterial(0);

    assertEquals(3, app.User3D.create_Person_Type);
  }

  @Test
  void pickOrAssignModel2DSeedMaterial_pickOfATreeReadsItsOffsetTypeIntoCreatePlantType () {
    app.WIN3D.UI_CurrentTask = app.UITASK.Seed_Material;
    app.WIN3D.UI_TaskModifyParameter = 1; // Pick
    app.allModel2Ds.num_files_PEOPLE = 5;
    app.allModel2Ds.MAP = new int[]{8}; // 8 > num_files_PEOPLE -> a tree, offset type = 8-5 = 3

    app.SOLARCHVISION_pickOrAssignModel2DSeedMaterial(0);

    assertEquals(3, app.User3D.create_Plant_Type);
  }

  @Test
  void pickOrAssignModel2DSeedMaterial_assignWritesTheCurrentTypePreservingTheInstancesOwnSign () {
    app.WIN3D.UI_CurrentTask = app.UITASK.Seed_Material;
    app.WIN3D.UI_TaskModifyParameter = 2; // Assign
    app.allModel2Ds.num_files_PEOPLE = 5;
    app.allModel2Ds.MAP = new int[]{-8}; // a tree instance, flipped (negative)
    app.User3D.create_Plant_Type = 1;

    app.SOLARCHVISION_pickOrAssignModel2DSeedMaterial(0);

    assertEquals(-6, app.allModel2Ds.MAP[0]); // -(1 + 5), sign kept negative
  }

  @Test
  void pickOrAssignModel2DSeedMaterial_assignAllIsTreatedTheSameAsAssignSub () {
    app.WIN3D.UI_CurrentTask = app.UITASK.Seed_Material;
    app.WIN3D.UI_TaskModifyParameter = 3; // Assign(all) - no group distinction for MODEL2D
    app.allModel2Ds.num_files_PEOPLE = 5;
    app.allModel2Ds.MAP = new int[]{2}; // a person instance
    app.User3D.create_Person_Type = 4;

    app.SOLARCHVISION_pickOrAssignModel2DSeedMaterial(0);

    assertEquals(4, app.allModel2Ds.MAP[0]);
  }

  // ==== SOLARCHVISION_pickOrAssignModel1DProperty (extracted) ===========

  @Test
  void pickOrAssignModel1DProperty_pickOfASingleTaskReadsOnlyThatOneField () {
    app.WIN3D.UI_TaskModifyParameter = 1; // Pick
    app.WIN3D.UI_CurrentTask = app.UITASK.BranchTilt;
    app.allModel1Ds.makeEmpty(0);
    app.allModel1Ds.create(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0); // create one instance to pick from
    app.allModel1Ds.setBranchTilt(0, 12.5f);
    app.User3D.create_Model1D_BranchTilt = -1;
    app.User3D.create_Model1D_LeafSize = -1;

    app.SOLARCHVISION_pickOrAssignModel1DProperty(0);

    assertEquals(12.5f, app.User3D.create_Model1D_BranchTilt, 0.0001f);
    assertEquals(-1f, app.User3D.create_Model1D_LeafSize, 0.0001f); // untouched: a different task
  }

  @Test
  void pickOrAssignModel1DProperty_assignOfASingleTaskWritesOnlyThatOneField () {
    app.WIN3D.UI_TaskModifyParameter = 2; // Assign
    app.WIN3D.UI_CurrentTask = app.UITASK.TrunkSize;
    app.allModel1Ds.makeEmpty(0);
    app.allModel1Ds.create(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    app.User3D.create_Model1D_TrunkSize = 6.25f;

    app.SOLARCHVISION_pickOrAssignModel1DProperty(0);

    assertEquals(6.25f, app.allModel1Ds.getTrunkSize(0), 0.0001f);
  }

  @Test
  void pickOrAssignModel1DProperty_model1DsPropsPicksAllThreeCoveredFieldsAtOnce () {
    app.WIN3D.UI_TaskModifyParameter = 1; // Pick
    app.WIN3D.UI_CurrentTask = app.UITASK.Model1DsProps;
    app.allModel1Ds.makeEmpty(0);
    app.allModel1Ds.create(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    app.allModel1Ds.setDegreeMax(0, 4);
    app.allModel1Ds.setTrunkSize(0, 2.5f);
    app.allModel1Ds.setLeafSize(0, 1.5f);

    app.SOLARCHVISION_pickOrAssignModel1DProperty(0);

    assertEquals(4, app.User3D.create_Model1D_DegreeMax);
    assertEquals(2.5f, app.User3D.create_Model1D_TrunkSize, 0.0001f);
    assertEquals(1.5f, app.User3D.create_Model1D_LeafSize, 0.0001f);
  }

  @Test
  void pickOrAssignModel1DProperty_isANoOpWhenModifyParameterIsZero () {
    app.WIN3D.UI_TaskModifyParameter = 0; // neither Pick nor Assign
    app.WIN3D.UI_CurrentTask = app.UITASK.BranchTwist;
    app.allModel1Ds.makeEmpty(0);
    app.allModel1Ds.create(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    app.allModel1Ds.setBranchTwist(0, 9);
    app.User3D.create_Model1D_BranchTwist = -1;

    app.SOLARCHVISION_pickOrAssignModel1DProperty(0);

    assertEquals(-1f, app.User3D.create_Model1D_BranchTwist, 0.0001f); // untouched
  }

  // ========= SOLARCHVISION_computeClickRay (extracted) ===================
  // Also de-duplicates: WIN3D.rotateXY_3DViewport_around_LandIntersection()
  // used to have this exact ray setup inlined a second time (confirmed
  // character-for-character identical, modulo `this.` vs `WIN3D.`, before
  // extracting) - it now calls this too.

  @Test
  void computeClickRay_perspectiveAtImageCenterWithNoRotation_matchesHandComputedValue () {
    // Same setup as WIN3DTest's calculateClick3D_atImageCenterWithNoRotation...
    // test, so ray_end is already confirmed there; this only checks the
    // extra ray_start/direction arithmetic layered on top of it.
    app.WIN3D.ViewType = 1; // perspective
    app.WIN3D.scale = 1;
    app.WIN3D.CAM_fov = (float) Math.toRadians(60);
    app.WIN3D.rotation_X = 0;
    app.WIN3D.rotation_Z = 0;
    app.WIN3D.CAM_x = 0;
    app.WIN3D.CAM_y = 0;
    app.WIN3D.CAM_z = 10;
    app.OBJECTS_scale = 1;

    solarchvision_bim.SOLARCHVISION_ClickRay ray = app.SOLARCHVISION_computeClickRay(0, 0);

    assertArrayEquals(new float[]{0, 0, 10}, ray.start, 0.001f);

    float pntZ = (float) (0.5 / Math.tan(0.5 * Math.PI / 3.0));
    assertArrayEquals(new float[]{0, 0, -pntZ}, ray.direction, 0.001f);
  }

  @Test
  void computeClickRay_dividesTheCameraPositionByObjectsScale () {
    app.WIN3D.ViewType = 1;
    app.WIN3D.scale = 1;
    app.WIN3D.CAM_fov = (float) Math.toRadians(60);
    app.WIN3D.CAM_x = 20;
    app.WIN3D.CAM_y = 0;
    app.WIN3D.CAM_z = 0;
    app.OBJECTS_scale = 2;

    solarchvision_bim.SOLARCHVISION_ClickRay ray = app.SOLARCHVISION_computeClickRay(0, 0);

    assertEquals(10f, ray.start[0], 0.001f); // 20 / 2
  }

  @Test
  void computeClickRay_perspectiveAlwaysStartsAtTheCameraRegardlessOfClickPosition () {
    // In perspective, every ray shares the same origin (the camera) -
    // only the direction changes with where on screen you clicked.
    app.WIN3D.ViewType = 1;
    app.WIN3D.scale = 1;
    app.WIN3D.CAM_fov = (float) Math.toRadians(60);
    app.WIN3D.CAM_x = 5;
    app.WIN3D.CAM_y = -3;
    app.WIN3D.CAM_z = 10;
    app.OBJECTS_scale = 1;

    solarchvision_bim.SOLARCHVISION_ClickRay centerRay = app.SOLARCHVISION_computeClickRay(0, 0);
    solarchvision_bim.SOLARCHVISION_ClickRay offCenterRay = app.SOLARCHVISION_computeClickRay(80, -40);

    assertArrayEquals(centerRay.start, offCenterRay.start, 0.0001f);
    assertNotEquals(centerRay.direction[0], offCenterRay.direction[0], 0.0001f);
  }

  @Test
  void computeClickRay_orthographicAtImageCenterStartsExactlyAtTheCamera () {
    // At the image center, ray_end (0,0) equals ray_center (0,0), so
    // the orthographic offset is exactly zero and the start point
    // matches the plain camera position, same as the perspective case.
    app.WIN3D.ViewType = 0; // orthographic
    app.WIN3D.scale = 1;
    app.WIN3D.rotation_X = 0;
    app.WIN3D.rotation_Z = 0;
    app.WIN3D.CAM_x = 1;
    app.WIN3D.CAM_y = 2;
    app.WIN3D.CAM_z = 3;
    app.WIN3D.position_X = 7;
    app.WIN3D.position_Y = 8;
    app.WIN3D.position_Z = 9;
    app.WIN3D.refScale = 100;
    app.WIN3D.Zoom = 90;
    app.OBJECTS_scale = 1;

    solarchvision_bim.SOLARCHVISION_ClickRay ray = app.SOLARCHVISION_computeClickRay(0, 0);

    assertArrayEquals(new float[]{1, 2, 3}, ray.start, 0.001f);
  }

  @Test
  void computeClickRay_orthographicRaysStayParallelRegardlessOfClickPosition () {
    // The defining property of orthographic projection: unlike
    // perspective, the ray's DIRECTION is the same no matter where on
    // screen you clicked - only its start point shifts.
    app.WIN3D.ViewType = 0; // orthographic
    app.WIN3D.scale = 1;
    app.WIN3D.rotation_X = 0;
    app.WIN3D.rotation_Z = 0;
    app.WIN3D.CAM_x = 0;
    app.WIN3D.CAM_y = 0;
    app.WIN3D.CAM_z = 10;
    app.WIN3D.position_X = 3;
    app.WIN3D.position_Y = 4;
    app.WIN3D.position_Z = 0;
    app.WIN3D.refScale = 100;
    app.WIN3D.Zoom = 90;
    app.OBJECTS_scale = 1;

    solarchvision_bim.SOLARCHVISION_ClickRay centerRay = app.SOLARCHVISION_computeClickRay(0, 0);
    solarchvision_bim.SOLARCHVISION_ClickRay offCenterRay = app.SOLARCHVISION_computeClickRay(50, -30);

    assertArrayEquals(centerRay.direction, offCenterRay.direction, 0.0001f);
    assertNotEquals(centerRay.start[0], offCenterRay.start[0], 0.0001f); // but the start point does shift
  }

  // ========== SOLARCHVISION_getMoveOriginPoint (extracted) ===============

  @Test
  void getMoveOriginPoint_forAGroupReturnsTheSelectionsPivot () {
    // Same BoundingBox/align setup already confirmed directly in
    // Select3DTest's getPivot test - this only checks that the Move
    // handling routes GROUP through getPivot() at all.
    app.current_ObjectCategory = app.ObjectCategory.GROUP;
    app.Select3D.BoundingBox = new float[][]{
      {0, 0, 0, 1, 1, 1, 0, 0, 0},
      {5, 5, 5, 1, 1, 1, 0, 0, 0},
      {10, 10, 10, 1, 1, 1, 0, 0, 0}
    };
    app.Select3D.alignX = 1;
    app.Select3D.alignY = 1;
    app.Select3D.alignZ = 1;

    float[] origin = app.SOLARCHVISION_getMoveOriginPoint();

    assertArrayEquals(new float[]{10, 10, 10}, origin, 0.001f);
  }

  @Test
  void getMoveOriginPoint_forAModel2DReturnsTheLastSelectedInstancesPosition () {
    app.current_ObjectCategory = app.ObjectCategory.MODEL2D;
    app.allModel2Ds.MAP = new int[]{0, 0, 0}; // 3 instances, values unused by getX/Y/Z
    app.allModel2Ds.XYZS = new float[][]{
      {1, 1, 1, 1}, {2, 2, 2, 1}, {99, 88, 77, 1} // last one should win
    };
    app.Select3D.Model2D_ids = new int[]{0, 2}; // last id is 2, not the last array entry

    float[] origin = app.SOLARCHVISION_getMoveOriginPoint();

    assertArrayEquals(new float[]{99, 88, 77}, origin, 0.0001f);
  }

  @Test
  void getMoveOriginPoint_forAVertexReturnsThatPointsCoordinates () {
    app.current_ObjectCategory = app.ObjectCategory.VERTEX;
    app.allVertices = new float[][]{{0, 0, 0}, {3, 4, 5}};
    app.Select3D.Vertex_ids = new int[]{1};

    float[] origin = app.SOLARCHVISION_getMoveOriginPoint();

    assertArrayEquals(new float[]{3, 4, 5}, origin, 0.0001f);
  }

  @Test
  void getMoveOriginPoint_isUndefinedForACategoryMoveDoesntHandle () {
    app.current_ObjectCategory = app.ObjectCategory.CAMERA; // not one of the five handled

    float[] origin = app.SOLARCHVISION_getMoveOriginPoint();

    assertFalse(app.is_defined(origin[0]));
    assertFalse(app.is_defined(origin[1]));
    assertFalse(app.is_defined(origin[2]));
  }

  // ========== SOLARCHVISION_computeMoveDelta (extracted) ==================

  @Test
  void computeMoveDelta_withPosVectorThreeMovesFreelyOnAllThreeAxes () {
    app.Select3D.posVector = 3; // "All"

    float[] d = app.SOLARCHVISION_computeMoveDelta(1, 2, 3, 4, 6, 8);

    assertArrayEquals(new float[]{3, 4, 5}, d, 0.0001f);
  }

  @Test
  void computeMoveDelta_withPosVectorZeroKeepsOnlyX () {
    app.Select3D.posVector = 0;

    float[] d = app.SOLARCHVISION_computeMoveDelta(1, 2, 3, 4, 6, 8);

    assertArrayEquals(new float[]{3, 0, 0}, d, 0.0001f);
  }

  @Test
  void computeMoveDelta_withPosVectorOneKeepsOnlyY () {
    app.Select3D.posVector = 1;

    float[] d = app.SOLARCHVISION_computeMoveDelta(1, 2, 3, 4, 6, 8);

    assertArrayEquals(new float[]{0, 4, 0}, d, 0.0001f);
  }

  @Test
  void computeMoveDelta_withPosVectorTwoKeepsOnlyZ () {
    app.Select3D.posVector = 2; // posVector's own default

    float[] d = app.SOLARCHVISION_computeMoveDelta(1, 2, 3, 4, 6, 8);

    assertArrayEquals(new float[]{0, 0, 5}, d, 0.0001f);
  }
}
