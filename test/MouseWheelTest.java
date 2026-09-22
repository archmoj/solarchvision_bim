import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class MouseWheelTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= shiftAndClampRange ====================================

  @Test
  void shiftAndClampRange_shiftsBothEndsUpTogetherOnPositiveWheel () {
    int[] r = app.shiftAndClampRange(10, 20, 1, 0, 100);
    assertArrayEquals(new int[]{11, 21}, r);
  }

  @Test
  void shiftAndClampRange_shiftsBothEndsDownTogetherOnNegativeWheel () {
    int[] r = app.shiftAndClampRange(10, 20, -1, 0, 100);
    assertArrayEquals(new int[]{9, 19}, r);
  }

  @Test
  void shiftAndClampRange_clampsStartToTheLowerBound () {
    int[] r = app.shiftAndClampRange(0, 5, -1, 0, 100);
    // start: 0-1=-1 -> clamped to 0; end: 5-1=4, not clamped
    assertArrayEquals(new int[]{0, 4}, r);
  }

  @Test
  void shiftAndClampRange_clampsToTheUpperBound () {
    int[] r = app.shiftAndClampRange(95, 100, 1, 0, 100);
    assertArrayEquals(new int[]{96, 100}, r);
  }

  @Test
  void shiftAndClampRange_isANoOpForAZeroWheelValue () {
    int[] r = app.shiftAndClampRange(10, 20, 0, 0, 100);
    assertArrayEquals(new int[]{10, 20}, r);
  }

  // ================= handleHoursCaseBarWheel ================================

  @Test
  void handleHoursCaseBarWheel_advancesBothEndsByOneHourOnPositiveWheel () {
    app.STUDY.i_Start = 5;
    app.STUDY.i_End = 10;

    app.handleHoursCaseBarWheel(1);

    assertEquals(6, app.STUDY.i_Start);
    assertEquals(11, app.STUDY.i_End);
  }

  @Test
  void handleHoursCaseBarWheel_wrapsFrom23BackTo0 () {
    app.STUDY.i_Start = 23;
    app.STUDY.i_End = 23;

    app.handleHoursCaseBarWheel(1);

    assertEquals(0, app.STUDY.i_Start);
    assertEquals(0, app.STUDY.i_End);
  }

  @Test
  void handleHoursCaseBarWheel_wrapsFrom0BackTo23OnNegativeWheel () {
    app.STUDY.i_Start = 0;
    app.STUDY.i_End = 0;

    app.handleHoursCaseBarWheel(-1);

    assertEquals(23, app.STUDY.i_Start);
    assertEquals(23, app.STUDY.i_End);
  }

  // ================= handleDaysCaseBarWheel =================================

  @Test
  void handleDaysCaseBarWheel_increasesJoinDaysByTwoOnPositiveWheel () {
    app.STUDY.joinDays = 10;
    app.STUDY.j_End = 12; // cap = 365/12 = 30

    app.handleDaysCaseBarWheel(1);

    assertEquals(12, app.STUDY.joinDays);
  }

  @Test
  void handleDaysCaseBarWheel_clampsToAtLeastOne () {
    app.STUDY.joinDays = 1;

    app.handleDaysCaseBarWheel(-1);

    assertEquals(1, app.STUDY.joinDays); // 1-2=-1 -> clamped to 1
  }

  @Test
  void handleDaysCaseBarWheel_clampsToTheThreeSixtyFiveOverJEndCeiling () {
    app.STUDY.joinDays = 100;
    app.STUDY.j_End = 12; // cap = 365/12 = 30

    app.handleDaysCaseBarWheel(1);

    assertEquals(365 / 12, app.STUDY.joinDays);
  }

  // ================= handleScenarioCaseBarWheel =============================

  @Test
  void handleScenarioCaseBarWheel_shiftsTheCweedsSampleRangeWhenCweedsIsActive () {
    app.CurrentDataSource = app.dataID_CLIMATE_CWEEDS;
    app.SampleYear_Start = 1980;
    app.SampleYear_End = 1985;

    app.handleScenarioCaseBarWheel(1);

    assertEquals(1981, app.SampleYear_Start);
    assertEquals(1986, app.SampleYear_End);
  }

  @Test
  void handleScenarioCaseBarWheel_leavesCweedsRangeAloneWhenADifferentSourceIsActive () {
    app.CurrentDataSource = app.dataID_ENSEMBLE_FORECAST;
    app.SampleYear_Start = 1980;
    app.SampleYear_End = 1985;

    app.handleScenarioCaseBarWheel(1);

    assertEquals(1980, app.SampleYear_Start); // untouched
    assertEquals(1985, app.SampleYear_End);
  }

  @Test
  void handleScenarioCaseBarWheel_shiftsTheEnsembleForecastMemberRangeWhenActive () {
    app.CurrentDataSource = app.dataID_ENSEMBLE_FORECAST;
    app.SampleMember_Start = 5;
    app.SampleMember_End = 10;

    app.handleScenarioCaseBarWheel(1);

    assertEquals(6, app.SampleMember_Start);
    assertEquals(11, app.SampleMember_End);
  }

  // ================= handleWorldZoomWheel ====================================

  @Test
  void handleWorldZoomWheel_zoomsInOnPositiveWheelWhenOverWorld () {
    app.WORLD.include = true;
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;
    app.X_clicked = 100;
    app.Y_clicked = 100;
    app.WORLD.Zoom = 5;

    app.handleWorldZoomWheel(1);

    assertEquals(4, app.WORLD.Zoom); // positive wheel -> Zoom -= 1
  }

  @Test
  void handleWorldZoomWheel_clampsToTheOneToNineRange () {
    app.WORLD.include = true;
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;
    app.X_clicked = 100;
    app.Y_clicked = 100;
    app.WORLD.Zoom = 9;

    app.handleWorldZoomWheel(-1); // would push Zoom to 10

    assertEquals(9, app.WORLD.Zoom);
  }

  @Test
  void handleWorldZoomWheel_isANoOpWhenTheClickIsOutsideWorld () {
    app.WORLD.include = true;
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;
    app.X_clicked = 9999; // outside
    app.Y_clicked = 9999;
    app.WORLD.Zoom = 5;

    app.handleWorldZoomWheel(1);

    assertEquals(5, app.WORLD.Zoom);
  }

  // ================= zoomWin3DViewport ========================================

  @Test
  void zoomWin3DViewport_movesPositionZInPerspectiveView () {
    app.WIN3D.ViewType = 1; // perspective
    app.WIN3D.position_Z = 0;
    app.WIN3D.position_T = 2;
    app.OBJECTS_scale = 1;

    app.zoomWin3DViewport(3);

    assertEquals(-6f, app.WIN3D.position_Z, 0.0001f); // -wheelValue*position_T*scale
  }

  @Test
  void zoomWin3DViewport_scalesZoomMultiplicativelyInOrthographicView () {
    app.WIN3D.ViewType = 0; // orthographic
    app.WIN3D.Zoom = 10;

    app.zoomWin3DViewport(1);

    assertEquals(20f, app.WIN3D.Zoom, 0.0001f); // *2^1
  }

  // ================= adjustWin3DElevationWheel ================================

  @Test
  void adjustWin3DElevationWheel_increasesZoomAngleOnPositiveWheel () {
    app.WIN3D.Zoom = 60;
    app.adjustWin3DElevationWheel(1);
    assertTrue(app.WIN3D.Zoom > 60);
  }

  @Test
  void adjustWin3DElevationWheel_decreasesZoomAngleOnNegativeWheel () {
    app.WIN3D.Zoom = 60;
    app.adjustWin3DElevationWheel(-1);
    assertTrue(app.WIN3D.Zoom < 60);
  }

  // ================= scaleObjectsWheel / scaleSkydomeWheel / scaleAllModelWheel

  @Test
  void scaleObjectsWheel_shrinksObjectsScaleOnPositiveWheel () {
    app.OBJECTS_scale = 1;
    app.scaleObjectsWheel(1);
    assertEquals((float) (1 / Math.pow(2.0, 0.25)), app.OBJECTS_scale, 0.0001f);
  }

  @Test
  void scaleObjectsWheel_growsObjectsScaleOnNegativeWheel () {
    app.OBJECTS_scale = 1;
    app.scaleObjectsWheel(-1);
    assertEquals((float) Math.pow(2.0, 0.25), app.OBJECTS_scale, 0.0001f);
  }

  @Test
  void scaleSkydomeWheel_growsRadiusOnPositiveWheel () {
    app.Sky3D.radius = 100;
    app.scaleSkydomeWheel(1);
    assertEquals((float) (100 * Math.pow(2.0, 0.25)), app.Sky3D.radius, 0.01f);
  }

  @Test
  void scaleAllModelWheel_shrinksBothObjectsScaleAndSkydomeRadiusOnPositiveWheel () {
    app.OBJECTS_scale = 1;
    app.Sky3D.radius = 100;

    app.scaleAllModelWheel(1);

    assertEquals((float) (1 / Math.pow(2.0, 0.25)), app.OBJECTS_scale, 0.0001f);
    assertEquals((float) (100 / Math.pow(2.0, 0.25)), app.Sky3D.radius, 0.01f);
  }

  // ================= handleTargetRollXYZWheel / handleCameraRollXYZWheel =====

  @Test
  void handleTargetRollXYZWheel_rotatesXWhenOptionXorYIsZero () {
    app.WIN3D.UI_OptionXorY = 0;
    app.WIN3D.rotation_T = 2;
    app.WIN3D.rotation_X = 0;
    app.WIN3D.rotation_Z = 5;

    app.handleTargetRollXYZWheel(3);

    assertEquals(6f, app.WIN3D.rotation_X, 0.0001f); // 3*2
    assertEquals(5f, app.WIN3D.rotation_Z, 0.0001f); // untouched
  }

  @Test
  void handleTargetRollXYZWheel_rotatesZWhenOptionXorYIsOne () {
    app.WIN3D.UI_OptionXorY = 1;
    app.WIN3D.rotation_T = 2;
    app.WIN3D.rotation_X = 5;
    app.WIN3D.rotation_Z = 0;

    app.handleTargetRollXYZWheel(3);

    assertEquals(6f, app.WIN3D.rotation_Z, 0.0001f);
    assertEquals(5f, app.WIN3D.rotation_X, 0.0001f); // untouched
  }

  // ================= adjustPositionXWheel / YWheel / RotationXWheel / ZWheel =

  @Test
  void adjustPositionXWheel_movesPositionXScaledByPositionTAndObjectsScale () {
    app.WIN3D.position_X = 0;
    app.WIN3D.position_T = 2;
    app.OBJECTS_scale = 3;

    app.adjustPositionXWheel(1);

    assertEquals(6f, app.WIN3D.position_X, 0.0001f);
  }

  @Test
  void adjustPositionYWheel_movesPositionYScaledByPositionTAndObjectsScale () {
    app.WIN3D.position_Y = 0;
    app.WIN3D.position_T = 2;
    app.OBJECTS_scale = 3;

    app.adjustPositionYWheel(1);

    assertEquals(6f, app.WIN3D.position_Y, 0.0001f);
  }

  @Test
  void adjustRotationXWheel_rotatesXScaledByRotationT () {
    app.WIN3D.rotation_X = 0;
    app.WIN3D.rotation_T = 4;

    app.adjustRotationXWheel(2);

    assertEquals(8f, app.WIN3D.rotation_X, 0.0001f);
  }

  @Test
  void adjustRotationZWheel_rotatesZScaledByRotationT () {
    app.WIN3D.rotation_Z = 0;
    app.WIN3D.rotation_T = 4;

    app.adjustRotationZWheel(2);

    assertEquals(8f, app.WIN3D.rotation_Z, 0.0001f);
  }

  // ================= handleTruckOrbitWheel ====================================

  @Test
  void handleTruckOrbitWheel_truckModeOptionXorYZeroAdjustsPositionXOnly () {
    app.WIN3D.UI_TaskModifyParameter = 0; // Truck
    app.WIN3D.UI_OptionXorY = 0;
    app.WIN3D.position_T = 1;
    app.OBJECTS_scale = 1;
    app.WIN3D.position_X = 0;
    app.WIN3D.position_Y = 0;

    app.handleTruckOrbitWheel(2);

    assertEquals(2f, app.WIN3D.position_X, 0.0001f);
    assertEquals(0f, app.WIN3D.position_Y, 0.0001f);
  }

  @Test
  void handleTruckOrbitWheel_orbitModeOptionXorYOneAdjustsRotationZOnly () {
    app.WIN3D.UI_TaskModifyParameter = 1; // Orbit
    app.WIN3D.UI_OptionXorY = 1;
    app.WIN3D.rotation_T = 1;
    app.WIN3D.rotation_X = 0;
    app.WIN3D.rotation_Z = 0;

    app.handleTruckOrbitWheel(2);

    assertEquals(2f, app.WIN3D.rotation_Z, 0.0001f);
    assertEquals(0f, app.WIN3D.rotation_X, 0.0001f);
  }

  // ================= handleViewportWheel (dispatcher spot checks) ===========

  @Test
  void handleViewportWheel_zoomOrbitPanZoomsTheViewport () {
    app.WIN3D.UI_CurrentTask = app.UITASK.Zoom_Orbit_Pan;
    app.WIN3D.ViewType = 0;
    app.WIN3D.Zoom = 10;

    app.handleViewportWheel(1);

    assertEquals(20f, app.WIN3D.Zoom, 0.0001f); // zoomWin3DViewport ran
  }

  @Test
  void handleViewportWheel_panHeightAdjustsElevationNotZoomMultiplicatively () {
    app.WIN3D.UI_CurrentTask = app.UITASK.Pan_Height;
    app.WIN3D.Zoom = 60;

    app.handleViewportWheel(1);

    assertTrue(app.WIN3D.Zoom > 60); // adjustWin3DElevationWheel ran, not zoomWin3DViewport
    assertNotEquals(120f, app.WIN3D.Zoom, 0.0001f); // *2 would be the (wrong) multiplicative path
  }

  @Test
  void handleViewportWheel_modelSizeScalesObjects () {
    app.WIN3D.UI_CurrentTask = app.UITASK.ModelSize_Pan_TargetRoll;
    app.OBJECTS_scale = 1;

    app.handleViewportWheel(1);

    assertEquals((float) (1 / Math.pow(2.0, 0.25)), app.OBJECTS_scale, 0.0001f);
  }

  // ================= handleMoveWheel (now shares computeMoveDelta)

  @Test
  void handleMoveWheel_movesTheSelectedVertexAlongItsConstrainedAxis () {
    app.current_ObjectCategory = app.ObjectCategory.VERTEX;
    app.allVertices = new float[][]{{1, 2, 3}};
    app.Select3D.Vertex_ids = new int[]{0};
    app.Select3D.posVector = 2; // Z-only

    app.handleMoveWheel(-4); // d = -wheelValue = 4

    assertEquals(1f, app.allPoints.getX(0), 0.0001f); // untouched: X constrained out
    assertEquals(2f, app.allPoints.getY(0), 0.0001f); // untouched: Y constrained out
    assertEquals(7f, app.allPoints.getZ(0), 0.0001f); // 3 + 4
  }

  @Test
  void handleMoveWheel_movesFreelyOnAllAxesWhenPosVectorIsAll () {
    app.current_ObjectCategory = app.ObjectCategory.VERTEX;
    app.allVertices = new float[][]{{0, 0, 0}};
    app.Select3D.Vertex_ids = new int[]{0};
    app.Select3D.posVector = 3; // All

    app.handleMoveWheel(-2); // d = 2

    assertEquals(2f, app.allPoints.getX(0), 0.0001f);
    assertEquals(2f, app.allPoints.getY(0), 0.0001f);
    assertEquals(2f, app.allPoints.getZ(0), 0.0001f);
  }
}
