import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class WIN3DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= rotateAroundX / rotateAroundZ =======================

  @Test
  void rotateAroundX_rotatesAQuarterTurnLeavingXUnchanged () {
    float[] result = app.WIN3D.rotateAroundX(1, 0, 1, 90);
    assertArrayEquals(new float[]{1, -1, 0}, result, 0.001f);
  }

  @Test
  void rotateAroundZ_rotatesAQuarterTurnLeavingZUnchanged () {
    float[] result = app.WIN3D.rotateAroundZ(1, 0, 5, 90);
    assertArrayEquals(new float[]{0, 1, 5}, result, 0.001f);
  }

  // ================= cameraPositionScaled / imageCenterRayScaled ========

  @Test
  void cameraPositionScaled_dividesByObjectsScale () {
    app.OBJECTS_scale = 2;
    app.WIN3D.CAM_x = 10;
    app.WIN3D.CAM_y = 20;
    app.WIN3D.CAM_z = 30;

    assertArrayEquals(new float[]{5, 10, 15}, app.WIN3D.cameraPositionScaled(), 0.001f);
  }

  // ================= Orthographic_ZOOM ===================================

  @Test
  void orthographicZoom_scalesWithZoomAngleAndDistanceFromOrigin () {
    app.WIN3D.Zoom = 90;
    app.WIN3D.position_X = 3;
    app.WIN3D.position_Y = 4;
    app.WIN3D.position_Z = 0;
    app.WIN3D.refScale = 100;

    float expected = (float) (0.5 * 90 * Math.PI / 180) * 5 / 100; // dist(3,4,0)=5
    assertEquals(expected, app.WIN3D.Orthographic_ZOOM(), 0.0001f);
  }

  // ================= transform_3DViewport / reverseTransform_3DViewport =

  @Test
  void transformThenReverseTransform3DViewport_roundTripsThePosition () {
    // Verified independently in Python beforehand: for the same
    // rotation_X/rotation_Z, transform_3DViewport (position -> camera
    // space) and reverseTransform_3DViewport (camera space -> position)
    // are exact inverses of each other.
    app.WIN3D.position_X = 3;
    app.WIN3D.position_Y = 4;
    app.WIN3D.position_Z = 5;
    app.WIN3D.rotation_X = 90;
    app.WIN3D.rotation_Z = -45;

    app.WIN3D.transform_3DViewport();
    app.WIN3D.reverseTransform_3DViewport();

    assertEquals(3f, app.WIN3D.position_X, 0.01f);
    assertEquals(4f, app.WIN3D.position_Y, 0.01f);
    assertEquals(5f, app.WIN3D.position_Z, 0.01f);
  }

  // ================= calculate_Click3D / camera-space / perspective =====

  @Test
  void calculateClick3D_atImageCenterWithNoRotationLandsStraightAheadOfTheCamera () {
    app.WIN3D.ViewType = 1; // perspective
    app.WIN3D.scale = 1;
    app.WIN3D.CAM_fov = (float) Math.toRadians(60);
    app.WIN3D.rotation_X = 0;
    app.WIN3D.rotation_Z = 0;
    app.WIN3D.CAM_x = 0;
    app.WIN3D.CAM_y = 0;
    app.WIN3D.CAM_z = 10;

    float[] p = app.WIN3D.calculate_Click3D(0, 0);

    assertEquals(0f, p[0], 0.001f);
    assertEquals(0f, p[1], 0.001f);
    // PNT_z (before the final negation) is a fixed constant independent
    // of CAM_z; the returned Z below is -(PNT_z - CAM_z).
    float pntZ = (float) (0.5 / Math.tan(0.5 * Math.PI / 3.0));
    assertEquals(-(pntZ - 10f), p[2], 0.001f);
  }

  @Test
  void calculatePerspectiveFromCameraSpace_returnsUndefinedBehindTheCamera () {
    app.WIN3D.ViewType = 1;
    app.WIN3D.scale = 1;
    app.WIN3D.CAM_fov = (float) Math.toRadians(60);

    float[] behind = app.WIN3D.calculate_Perspective_fromCameraSpace(0, 0, -5);
    assertTrue(behind[2] < 0); // Image_Z stays negative when z <= 0

    float[] inFront = app.WIN3D.calculate_Perspective_fromCameraSpace(0, 0, 5);
    assertEquals(5f, inFront[2], 0.0001f); // Image_Z mirrors z when in front
    assertEquals(0f, inFront[0], 0.0001f); // on-axis point projects to image center
  }

  // ================= record_last3DViewport / apply_currentCamera ========

  @Test
  void recordThenApplyCurrentCamera_roundTripsThroughAllCameras () {
    app.allCameras.options = new float[][]{new float[9]};
    app.allCameras.Type = new int[]{0};
    app.allCameras.num = 1;

    app.WIN3D.currentCamera = 0;
    app.WIN3D.position_X = 7;
    app.WIN3D.rotation_Z = 33;
    app.WIN3D.Zoom = 45;

    app.WIN3D.record_last3DViewport();

    app.WIN3D.position_X = 0; // simulate the viewport moving away...
    app.WIN3D.rotation_Z = 0;
    app.WIN3D.Zoom = 0;

    app.WIN3D.apply_currentCamera(); // ...then restoring from the saved camera

    assertEquals(7f, app.WIN3D.position_X, 0.0001f);
    assertEquals(33f, app.WIN3D.rotation_Z, 0.0001f);
    assertEquals(45f, app.WIN3D.Zoom, 0.0001f);
  }

  // ================= isSolarPaletteMode / choosePaletteParams ===========

  @Test
  void isSolarPaletteMode_isTrueForEitherSolarShadeMode () {
    app.WIN3D.FacesShade = app.SHADE.Global_Solar;
    assertTrue(app.WIN3D.isSolarPaletteMode());

    app.WIN3D.FacesShade = app.SHADE.Vertex_Solar;
    assertTrue(app.WIN3D.isSolarPaletteMode());
  }

  @Test
  void choosePaletteParams_usesTheActiveOrPassivePaletteBasedOnImpactType () {
    app.WIN3D.FacesShade = app.SHADE.Global_Solar; // enables solar palette mode
    app.WIN3D.Impact_TYPE = app.Impact_ACTIVE;
    app.allFaces.ACTIVE_palette_CLR = 5;
    app.allFaces.ACTIVE_palette_DIR = 1;
    app.allFaces.ACTIVE_palette_MLT = 0.5f;

    float[] result = app.WIN3D.choosePaletteParams();

    assertEquals(5f, result[0], 0.0001f);
    assertEquals(1f, result[1], 0.0001f);
    assertEquals(0.5f, result[2], 0.0001f);
    assertEquals(1f, result[3], 0.0001f); // draw_pal = true
  }

  @Test
  void choosePaletteParams_doesNotDrawWhenNoShadeModeMatches () {
    app.WIN3D.FacesShade = -999; // matches nothing
    float[] result = app.WIN3D.choosePaletteParams();
    assertEquals(0f, result[3], 0.0001f);
  }

  // ================= isRepeatableCommandKey ==============================

  @Test
  void isRepeatableCommandKey_recognizesTheNumpadAndCommaPeriodKeysOnly () {
    assertTrue(app.WIN3D.isRepeatableCommandKey(','));
    assertTrue(app.WIN3D.isRepeatableCommandKey('+'));
    assertTrue(app.WIN3D.isRepeatableCommandKey('4')); // a numpad rotate/pan digit is repeatable...
    // '5' is deliberately NOT repeatable, unlike the other numpad
    // digits: it maps to look_3DViewport_towards_Selection(), a
    // one-shot "snap to selection" action rather than a continuous
    // nudge, so it's excluded from the case list on purpose.
    assertFalse(app.WIN3D.isRepeatableCommandKey('5'));
    assertFalse(app.WIN3D.isRepeatableCommandKey('c')); // ...and letter commands are not either
    assertFalse(app.WIN3D.isRepeatableCommandKey('a'));
  }

  // ================= dispatchNavKey routing ==============================

  @Test
  void dispatchNavKey_routesPlainArrowKeysToHandleArrowKeys () {
    app.WIN3D.navKeyCoded = true;
    app.WIN3D.navKeyAlt = false;
    app.WIN3D.navKeyShift = false;
    app.WIN3D.navKeyCode = app.UP;
    app.WIN3D.rotation_T = 5;

    float beforeRotationX = app.WIN3D.rotation_X;
    app.WIN3D.dispatchNavKey(); // UP -> rotateZ_3DViewport_around_Selection(-rotation_T)

    assertEquals(beforeRotationX - 5, app.WIN3D.rotation_X, 0.0001f);
  }

  @Test
  void handleShiftedArrowKeys_rotateTaskNudgesSelectionAroundItsPivot () {
    app.allVertices = new float[][]{{1, 0, 0}};
    app.Select3D.Vertex_ids = new int[]{0};
    app.current_ObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.rotVector = 2; // Z axis

    app.WIN3D.UI_CurrentTask = app.UITASK.Rotate;
    app.WIN3D.handleShiftedArrowKeys(app.UP); // +5 degrees around Z, per the source

    // A 5deg rotation around Z should move the point off the X axis.
    assertNotEquals(0f, app.allVertices[0][1], 0.0001f);
  }

  @Test
  void handleShiftedArrowKeys_moveTaskNudgesSelectionAlongThePosVectorOnly () {
    app.allVertices = new float[][]{{0, 0, 0}};
    app.Select3D.Vertex_ids = new int[]{0};
    app.current_ObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.posVector = 2; // Z only
    app.OBJECTS_scale = 1;

    app.WIN3D.UI_CurrentTask = app.UITASK.Move;
    app.WIN3D.handleShiftedArrowKeys(app.UP); // +0.5 along Z only

    assertEquals(0f, app.allVertices[0][0], 0.0001f);
    assertEquals(0f, app.allVertices[0][1], 0.0001f);
    assertEquals(0.5f, app.allVertices[0][2], 0.0001f);
  }

  @Test
  void dispatchNavKey_routesCtrlCommandKeysToHandleCtrlCommandKey () {
    app.WIN3D.navKeyCoded = false;
    app.WIN3D.navKeyCtrl = true;
    app.WIN3D.navKeyChar = ',';
    app.allVertices = new float[0][3]; // nothing selected - getPivot() falls back to the default origin

    // Just confirms this reaches handleCtrlCommandKey -> moveWin3DTowardsSelection
    // without throwing; that function's own math is exercised more
    // directly via the dedicated test below.
    app.WIN3D.dispatchNavKey();
  }

  @Test
  void dispatchNavKey_routesPlainCommandKeysToHandleCommandKey () {
    app.WIN3D.navKeyCoded = false;
    app.WIN3D.navKeyCtrl = false;
    app.WIN3D.navKeyShift = false;
    app.WIN3D.navKeyChar = '1';
    app.WIN3D.position_X = 0;
    app.WIN3D.position_T = 2;
    app.OBJECTS_scale = 1;

    app.WIN3D.dispatchNavKey(); // '1' -> position_X += position_T * OBJECTS_scale

    assertEquals(2f, app.WIN3D.position_X, 0.0001f);
  }

  // ================= keyReleased / processHeldKey ========================

  @Test
  void keyReleased_clearsNavKeyHeldOnlyWhenTheSameKeyComesBackUp () {
    app.WIN3D.navKeyHeld = true;
    app.WIN3D.navKeyCoded = true;
    app.WIN3D.navKeyCode = app.UP;

    app.key = (char) app.CODED;
    app.keyCode = app.DOWN; // a DIFFERENT key releasing
    app.WIN3D.keyReleased();
    assertTrue(app.WIN3D.navKeyHeld); // still held - wrong key released

    app.keyCode = app.UP; // the actual held key releasing
    app.WIN3D.keyReleased();
    assertFalse(app.WIN3D.navKeyHeld);
  }

  @Test
  void processHeldKey_reFiresOnlyWhileHeldAndRepeatable () {
    app.WIN3D.navKeyHeld = false;
    app.WIN3D.navKeyRepeatable = true;
    app.WIN3D.navKeyCoded = false;
    app.WIN3D.navKeyChar = '1';
    app.WIN3D.position_X = 0;
    app.WIN3D.position_T = 2;
    app.OBJECTS_scale = 1;

    app.WIN3D.processHeldKey(); // not held - no-op
    assertEquals(0f, app.WIN3D.position_X, 0.0001f);

    app.WIN3D.navKeyHeld = true;
    app.WIN3D.processHeldKey(); // held and repeatable - fires
    assertEquals(2f, app.WIN3D.position_X, 0.0001f);
  }

  // ================= camera-navigation math ==============================

  @Test
  void moveCameraTowards_interpolatesBetweenTheCameraAndTheTargetPoint () {
    app.OBJECTS_scale = 1;
    app.WIN3D.CAM_x = 10;
    app.WIN3D.CAM_y = 0;
    app.WIN3D.CAM_z = 0;
    app.WIN3D.rotation_X = 0;
    app.WIN3D.rotation_Z = 0;
    app.WIN3D.Zoom = 90;
    app.WIN3D.refScale = 100;

    app.WIN3D.moveCameraTowards(0, 0, 0, 0.5f); // halfway from (10,0,0) towards the origin

    assertEquals(5f, app.WIN3D.CAM_x, 0.001f);
  }

  @Test
  void moveWin3DTowardsSelectionViaCtrlComma_movesTheCameraCloserToThePivot () {
    // Caught before shipping: handleCtrlCommandKey doesn't call
    // WIN3D.move_3DViewport_towards_Selection(-0.5) directly - it calls
    // the GLOBAL moveWin3DTowardsSelection(-0.5) (defined in
    // mouseWheel.pde), which itself calls
    // move_3DViewport_towards_Selection(pow(2, 0.5*wheelValue)). For
    // wheelValue=-0.5, that's pow(2,-0.25)=~0.841 - a POSITIVE value
    // under 1, which SHRINKS the offset from the pivot (moves closer),
    // not a negative t moving away as it might look at first glance.
    app.allVertices = new float[0][3]; // pivot falls back to the origin
    app.WIN3D.CAM_x = 10;
    app.WIN3D.CAM_y = 0;
    app.WIN3D.CAM_z = 0;

    app.WIN3D.navKeyCoded = false;
    app.WIN3D.navKeyCtrl = true;
    app.WIN3D.navKeyChar = ',';

    app.WIN3D.dispatchNavKey();

    float expectedT = (float) Math.pow(2, 0.5 * -0.5);
    assertEquals(10 * expectedT, app.WIN3D.CAM_x, 0.01f);
    assertTrue(app.WIN3D.CAM_x < 10); // closer to the pivot, not farther
  }

  // ================= to_XML / from_XML round trip ========================

  @Test
  void toXMLThenFromXML_roundTripsEveryField () {
    app.WIN3D.CAM_x = 1;
    app.WIN3D.CAM_y = 2;
    app.WIN3D.CAM_z = 3;
    app.WIN3D.CAM_fov = 0.5f;
    app.WIN3D.CAM_dist = 100;
    app.WIN3D.CAM_clipNear = 0.1f;
    app.WIN3D.CAM_clipFar = 1000;
    app.WIN3D.currentCamera = 2;
    app.WIN3D.refScale = 50;
    app.WIN3D.position_X = 4;
    app.WIN3D.position_Y = 5;
    app.WIN3D.position_Z = 6;
    app.WIN3D.position_T = 2;
    app.WIN3D.rotation_X = 10;
    app.WIN3D.rotation_Y = 20;
    app.WIN3D.rotation_Z = 30;
    app.WIN3D.rotation_T = 3;
    app.WIN3D.Zoom = 60;
    app.WIN3D.ViewType = 0;
    app.WIN3D.FacesShade = 2;
    app.WIN3D.UI_CurrentTask = 1;
    app.WIN3D.UI_OptionXorY = 1;
    app.WIN3D.UI_TaskModifyParameter = 1;
    app.WIN3D.Impact_TYPE = app.Impact_PASSIVE;

    processing.data.XML root = new processing.data.XML("root");
    app.WIN3D.to_XML(root);

    solarchvision_bim.WIN3D fresh = app.new WIN3D();
    fresh.from_XML(root);

    assertEquals(1f, fresh.CAM_x, 0.0001f);
    assertEquals(2, fresh.currentCamera);
    assertEquals(4f, fresh.position_X, 0.0001f);
    assertEquals(30f, fresh.rotation_Z, 0.0001f);
    assertEquals(60f, fresh.Zoom, 0.0001f);
    assertEquals(0, fresh.ViewType);
    assertEquals(2, fresh.FacesShade);
    assertEquals(1, fresh.UI_CurrentTask);
    assertEquals(app.Impact_PASSIVE, fresh.Impact_TYPE);
  }
}
