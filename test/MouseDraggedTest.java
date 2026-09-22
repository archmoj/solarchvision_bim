import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class MouseDraggedTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= startFrameDragIfNeeded ===============================

  @Test
  void startFrameDragIfNeeded_recordsTheStartPointAndMarksDraggingStarted () {
    app.dragging_started = 0;
    app.pmouseX = 111;
    app.pmouseY = 222;

    app.startFrameDragIfNeeded();

    assertEquals(1, app.dragging_started);
    assertEquals(111, app.X_click1);
    assertEquals(222, app.Y_click1);
  }

  @Test
  void startFrameDragIfNeeded_isANoOpOnceADragIsAlreadyInProgress () {
    app.dragging_started = 1;
    app.X_click1 = 5;
    app.Y_click1 = 6;
    app.pmouseX = 999;
    app.pmouseY = 999;

    app.startFrameDragIfNeeded();

    assertEquals(5, app.X_click1); // untouched
    assertEquals(6, app.Y_click1);
  }

  // ================= handleWin3DDrag =======================================

  @Test
  void handleWin3DDrag_isANoOpWhenTheDragStartedOutsideWIN3D () {
    app.WIN3D.cX = 0;
    app.WIN3D.cY = 0;
    app.WIN3D.dX = 400;
    app.WIN3D.dY = 300;
    app.pmouseX = -50; // started outside
    app.pmouseY = 100;
    app.mouseX = 100;
    app.mouseY = 100;
    app.dragging_started = 0;

    app.handleWin3DDrag();

    assertEquals(0, app.dragging_started); // never started
  }

  @Test
  void handleWin3DDrag_beginsTheDragAndDispatchesOnceInsideOnBothEnds () {
    app.WIN3D.cX = 0;
    app.WIN3D.cY = 0;
    app.WIN3D.dX = 400;
    app.WIN3D.dY = 300;
    app.pmouseX = 100;
    app.pmouseY = 100;
    app.mouseX = 140; // moved +40px right
    app.mouseY = 100;
    app.dragging_started = 0;

    app.WIN3D.UI_CurrentTask = app.UITASK.Pan_TargetRoll;
    app.mouseButton = app.LEFT; // -> panBothAxes(dx, dy)
    app.WIN3D.position_T = 1;
    float beforeX = app.WIN3D.position_X;

    app.handleWin3DDrag();

    assertEquals(1, app.dragging_started);
    assertEquals(100, app.X_click1);
    assertEquals(100, app.Y_click1);
    // dx = 40/400 = 0.1 -> position_X += 100 * 0.1 * 1 * OBJECTS_scale(1) = 10
    assertEquals(beforeX + 10f, app.WIN3D.position_X, 0.001f);
  }

  // ================= handleWorldDrag =======================================

  @Test
  void handleWorldDrag_isANoOpAtLowZoomLevels () {
    app.WORLD.Zoom = 2;
    float before = app.WORLD.panOffsetLon;

    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;
    app.pmouseX = 100;
    app.pmouseY = 100;
    app.mouseX = 150;
    app.mouseY = 100;

    app.handleWorldDrag();

    assertEquals(before, app.WORLD.panOffsetLon, 0.0001f);
  }

  @Test
  void handleWorldDrag_pansByDegreesPerPixelWhenZoomedIn () {
    app.WORLD.Zoom = 5;
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 360;
    app.WORLD.dY = 180;
    app.WORLD.sX = 1;
    app.WORLD.sY = 1;
    app.WORLD.panOffsetLon = 0;
    app.WORLD.panOffsetLat = 0;

    app.pmouseX = 100;
    app.pmouseY = 100;
    app.mouseX = 110; // +10px right
    app.mouseY = 90;  // -10px up

    app.handleWorldDrag();

    // lonPerPixel = 360*1/360 = 1; dxPixels = 10 -> panOffsetLon -= 10
    assertEquals(-10f, app.WORLD.panOffsetLon, 0.01f);
    // latPerPixel = 180*1/180 = 1; dyPixels = -10 -> panOffsetLat += -10
    assertEquals(-10f, app.WORLD.panOffsetLat, 0.01f);
  }

  // ================= dispatchWin3DTaskDrag =================================

  @Test
  void dispatchWin3DTaskDrag_panTargetRollLeftClickPansBothAxes () {
    app.WIN3D.UI_CurrentTask = app.UITASK.Pan_TargetRoll;
    app.mouseButton = app.LEFT;
    app.WIN3D.position_T = 2;
    app.WIN3D.position_X = 0;
    app.WIN3D.position_Y = 0;

    app.dispatchWin3DTaskDrag(0.1f, 0.2f);

    assertEquals(100 * 0.1f * 2 * app.OBJECTS_scale, app.WIN3D.position_X, 0.01f);
    assertEquals(100 * 0.2f * 2 * app.OBJECTS_scale, app.WIN3D.position_Y, 0.01f);
  }

  @Test
  void dispatchWin3DTaskDrag_panXTargetRollLeftClickPansOnlyX () {
    app.WIN3D.UI_CurrentTask = app.UITASK.PanX_TargetRoll;
    app.mouseButton = app.LEFT;
    app.WIN3D.position_T = 1;
    app.WIN3D.position_X = 0;
    app.WIN3D.position_Y = 0;

    app.dispatchWin3DTaskDrag(0.3f, 0.4f);

    assertEquals(100 * 0.3f * app.WIN3D.position_T * app.OBJECTS_scale, app.WIN3D.position_X, 0.01f);
    assertEquals(0f, app.WIN3D.position_Y, 0.0001f); // untouched
  }

  @Test
  void dispatchWin3DTaskDrag_zoomOrbitPanRightClickPansInsteadOfOrbiting () {
    app.WIN3D.UI_CurrentTask = app.UITASK.Zoom_Orbit_Pan;
    app.mouseButton = app.RIGHT;
    app.WIN3D.position_T = 1;
    app.WIN3D.position_X = 0;
    app.WIN3D.position_Y = 0;
    app.WIN3D.rotation_Z = 0;

    app.dispatchWin3DTaskDrag(0.1f, 0.1f);

    assertEquals(10f, app.WIN3D.position_X, 0.01f); // panBothAxes ran
    assertEquals(0f, app.WIN3D.rotation_Z, 0.0001f); // orbitCamera did NOT run
  }

  @Test
  void dispatchWin3DTaskDrag_targetRollXYTargetRollZPicksAxisByOptionXorY () {
    // Per the original's combined conditions: LEFT+OptionXorY==1 (or
    // RIGHT+OptionXorY==0) does rollZ-only; the opposite pairing does
    // rollX-only.
    app.WIN3D.UI_CurrentTask = app.UITASK.TargetRollXY_TargetRollZ;
    app.WIN3D.rotation_T = 1;

    app.mouseButton = app.LEFT;
    app.WIN3D.UI_OptionXorY = 1;
    app.WIN3D.rotation_Z = 0;
    app.WIN3D.rotation_X = 0;

    app.dispatchWin3DTaskDrag(2, 3);

    assertEquals(20f, app.WIN3D.rotation_Z, 0.01f); // rotateTargetZOnly(dx=2) ran
    assertEquals(0f, app.WIN3D.rotation_X, 0.0001f); // rotateTargetXOnly did NOT run
  }

  // ================= panBothAxes / panXAxis / panYAxis ====================

  @Test
  void panBothAxes_movesPositionXAndYScaledByPositionTAndObjectsScale () {
    app.WIN3D.position_X = 1;
    app.WIN3D.position_Y = 2;
    app.WIN3D.position_T = 3;
    app.OBJECTS_scale = 2;

    app.panBothAxes(0.5f, -0.5f);

    assertEquals(1 + 100 * 0.5f * 3 * 2, app.WIN3D.position_X, 0.01f);
    assertEquals(2 + 100 * -0.5f * 3 * 2, app.WIN3D.position_Y, 0.01f);
  }

  @Test
  void panXAxis_movesOnlyX () {
    app.WIN3D.position_X = 0;
    app.WIN3D.position_Y = 5;
    app.WIN3D.position_T = 1;
    app.OBJECTS_scale = 1;

    app.panXAxis(0.2f);

    assertEquals(20f, app.WIN3D.position_X, 0.01f);
    assertEquals(5f, app.WIN3D.position_Y, 0.0001f);
  }

  @Test
  void panYAxis_movesOnlyY () {
    app.WIN3D.position_X = 5;
    app.WIN3D.position_Y = 0;
    app.WIN3D.position_T = 1;
    app.OBJECTS_scale = 1;

    app.panYAxis(0.2f);

    assertEquals(5f, app.WIN3D.position_X, 0.0001f);
    assertEquals(20f, app.WIN3D.position_Y, 0.01f);
  }

  // ================= rotateTargetXY / ZOnly / XOnly ========================

  @Test
  void rotateTargetXY_rotatesBothZAndXScaledByRotationT () {
    app.WIN3D.rotation_Z = 0;
    app.WIN3D.rotation_X = 0;
    app.WIN3D.rotation_T = 2;

    app.rotateTargetXY(0.5f, -0.5f);

    assertEquals(10f, app.WIN3D.rotation_Z, 0.01f);  // 10*0.5*2
    assertEquals(-10f, app.WIN3D.rotation_X, 0.01f); // 10*-0.5*2
  }

  @Test
  void rotateTargetZOnly_rotatesOnlyZ () {
    app.WIN3D.rotation_Z = 0;
    app.WIN3D.rotation_X = 7;
    app.WIN3D.rotation_T = 1;

    app.rotateTargetZOnly(1);

    assertEquals(10f, app.WIN3D.rotation_Z, 0.01f);
    assertEquals(7f, app.WIN3D.rotation_X, 0.0001f); // untouched
  }

  @Test
  void rotateTargetXOnly_rotatesOnlyX () {
    app.WIN3D.rotation_X = 0;
    app.WIN3D.rotation_Z = 7;
    app.WIN3D.rotation_T = 1;

    app.rotateTargetXOnly(1);

    assertEquals(10f, app.WIN3D.rotation_X, 0.01f);
    assertEquals(7f, app.WIN3D.rotation_Z, 0.0001f); // untouched
  }

  // ================= orbitCamera / orbitXOnly / orbitZOnly ================

  @Test
  void orbitCamera_rotatesBothZAndXInTheOppositeDirectionOfTargetRoll () {
    app.WIN3D.rotation_Z = 0;
    app.WIN3D.rotation_X = 0;
    app.WIN3D.rotation_T = 1;

    app.orbitCamera(0.5f, 0.5f);

    assertEquals(-5f, app.WIN3D.rotation_Z, 0.01f);
    assertEquals(-5f, app.WIN3D.rotation_X, 0.01f);
  }

  @Test
  void orbitXOnly_rotatesOnlyX () {
    app.WIN3D.rotation_X = 0;
    app.WIN3D.rotation_Z = 3;
    app.WIN3D.rotation_T = 1;

    app.orbitXOnly(1);

    assertEquals(-10f, app.WIN3D.rotation_X, 0.01f);
    assertEquals(3f, app.WIN3D.rotation_Z, 0.0001f);
  }

  @Test
  void orbitZOnly_rotatesOnlyZ () {
    app.WIN3D.rotation_Z = 0;
    app.WIN3D.rotation_X = 3;
    app.WIN3D.rotation_T = 1;

    app.orbitZOnly(1);

    assertEquals(-10f, app.WIN3D.rotation_Z, 0.01f);
    assertEquals(3f, app.WIN3D.rotation_X, 0.0001f);
  }

  // ================= handleTruckOrbitTask ==================================

  @Test
  void handleTruckOrbitTask_truckModeOptionXorYZeroPansXOnLeftClick () {
    app.WIN3D.UI_TaskModifyParameter = 0; // Truck
    app.WIN3D.UI_OptionXorY = 0;
    app.mouseButton = app.LEFT;
    app.WIN3D.position_T = 1;
    app.WIN3D.position_X = 0;
    app.WIN3D.position_Y = 0;

    app.handleTruckOrbitTask(0.2f, 0.3f);

    assertEquals(20f, app.WIN3D.position_X, 0.01f); // panXAxis ran
    assertEquals(0f, app.WIN3D.position_Y, 0.0001f); // panYAxis did NOT run
  }

  @Test
  void handleTruckOrbitTask_orbitModeOptionXorYZeroOrbitsXOnLeftClick () {
    app.WIN3D.UI_TaskModifyParameter = 1; // Orbit
    app.WIN3D.UI_OptionXorY = 0;
    app.mouseButton = app.LEFT;
    app.WIN3D.rotation_T = 1;
    app.WIN3D.rotation_X = 0;
    app.WIN3D.rotation_Z = 0;

    app.handleTruckOrbitTask(0.2f, 0.3f);

    assertEquals(-3f, app.WIN3D.rotation_X, 0.01f); // orbitXOnly(dy=0.3) ran
    assertEquals(0f, app.WIN3D.rotation_Z, 0.0001f); // orbitZOnly did NOT run
  }
}
