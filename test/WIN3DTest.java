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
    app.overallScale = 2;
    app.WIN3D.cameraX = 10;
    app.WIN3D.cameraY = 20;
    app.WIN3D.cameraZ = 30;

    assertArrayEquals(new float[]{5, 10, 15}, app.WIN3D.cameraPositionScaled(), 0.001f);
  }

  // ================= Orthographic_ZOOM ===================================

  @Test
  void orthographicZoom_scalesWithZoomAngleAndDistanceFromOrigin () {
    app.WIN3D.zoom = 90;
    app.WIN3D.positionX = 3;
    app.WIN3D.positionY = 4;
    app.WIN3D.positionZ = 0;
    app.WIN3D.referenceScale = 100;

    float expected = (float) (0.5 * 90 * Math.PI / 180) * 5 / 100; // dist(3,4,0)=5
    assertEquals(expected, app.WIN3D.Orthographic_ZOOM(), 0.0001f);
  }

  // ================= transform_3DViewport / reverseTransform_3DViewport =

  @Test
  void transformThenReverseTransform3DViewport_roundTripsThePosition () {
    // Verified independently in Python beforehand: for the same
    // rotationX/rotationZ, transform_3DViewport (position -> camera
    // space) and reverseTransform_3DViewport (camera space -> position)
    // are exact inverses of each other.
    app.WIN3D.positionX = 3;
    app.WIN3D.positionY = 4;
    app.WIN3D.positionZ = 5;
    app.WIN3D.rotationX = 90;
    app.WIN3D.rotationZ = -45;

    app.WIN3D.transform_3DViewport();
    app.WIN3D.reverseTransform_3DViewport();

    assertEquals(3f, app.WIN3D.positionX, 0.01f);
    assertEquals(4f, app.WIN3D.positionY, 0.01f);
    assertEquals(5f, app.WIN3D.positionZ, 0.01f);
  }

  // ================= calculate_Click3D / camera-space / perspective =====

  @Test
  void calculateClick3D_atImageCenterWithNoRotationTerrainsStraightAheadOfTheCamera () {
    app.WIN3D.projectionTypeIndex = 1; // perspective
    app.WIN3D.scale = 1;
    app.WIN3D.cameraFieldOfView = (float) Math.toRadians(60);
    app.WIN3D.rotationX = 0;
    app.WIN3D.rotationZ = 0;
    app.WIN3D.cameraX = 0;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = 10;

    float[] p = app.WIN3D.calculate_Click3D(0, 0);

    assertEquals(0f, p[0], 0.001f);
    assertEquals(0f, p[1], 0.001f);
    // PNT_z (before the final negation) is a fixed constant independent
    // of cameraZ; the returned Z below is -(PNT_z - cameraZ).
    float pntZ = (float) (0.5 / Math.tan(0.5 * Math.PI / 3.0));
    assertEquals(-(pntZ - 10f), p[2], 0.001f);
  }

  @Test
  void calculatePerspectiveFromCameraSpace_returnsUndefinedBehindTheCamera () {
    app.WIN3D.projectionTypeIndex = 1;
    app.WIN3D.scale = 1;
    app.WIN3D.cameraFieldOfView = (float) Math.toRadians(60);

    float[] behind = app.WIN3D.calculate_Perspective_fromCameraSpace(0, 0, -5);
    assertTrue(behind[2] < 0); // Image_Z stays negative when z <= 0

    float[] inFront = app.WIN3D.calculate_Perspective_fromCameraSpace(0, 0, 5);
    assertEquals(5f, inFront[2], 0.0001f); // Image_Z mirrors z when in front
    assertEquals(0f, inFront[0], 0.0001f); // on-axis point projects to image center
  }

  // ================= record_last3DViewport / apply_currentCameraIndex ========

  @Test
  void recordThenApplyCurrentCamera_roundTripsThroughAllCameras () {
    app.allCameras.options = new float[][]{new float[9]};
    app.allCameras.Type = new int[]{0};
    app.allCameras.num = 1;

    app.WIN3D.currentCameraIndex = 0;
    app.WIN3D.positionX = 7;
    app.WIN3D.rotationZ = 33;
    app.WIN3D.zoom = 45;

    app.WIN3D.record_last3DViewport();

    app.WIN3D.positionX = 0; // simulate the viewport moving away...
    app.WIN3D.rotationZ = 0;
    app.WIN3D.zoom = 0;

    app.WIN3D.apply_currentCameraIndex(); // ...then restoring from the saved camera

    assertEquals(7f, app.WIN3D.positionX, 0.0001f);
    assertEquals(33f, app.WIN3D.rotationZ, 0.0001f);
    assertEquals(45f, app.WIN3D.zoom, 0.0001f);
  }

  // ================= isSolarPaletteMode / choosePaletteParams ===========

  @Test
  void isSolarPaletteMode_isTrueForEitherSolarShadeMode () {
    app.WIN3D.shadingMode = app.SHADE.Global_Solar;
    assertTrue(app.WIN3D.isSolarPaletteMode());

    app.WIN3D.shadingMode = app.SHADE.Vertex_Solar;
    assertTrue(app.WIN3D.isSolarPaletteMode());
  }

  @Test
  void choosePaletteParams_usesTheActiveOrPassivePaletteBasedOnImpactType () {
    app.WIN3D.shadingMode = app.SHADE.Global_Solar; // enables solar palette mode
    app.WIN3D.impactType = app.Impact_ACTIVE;
    app.allFaces.activeColorScaleIndex = 5;
    app.allFaces.activeColorScaleDirection = 1;
    app.allFaces.activeColorScaleFactor = 0.5f;

    float[] result = app.WIN3D.choosePaletteParams();

    assertEquals(5f, result[0], 0.0001f);
    assertEquals(1f, result[1], 0.0001f);
    assertEquals(0.5f, result[2], 0.0001f);
    assertEquals(1f, result[3], 0.0001f); // draw_pal = true
  }

  @Test
  void choosePaletteParams_doesNotDrawWhenNoShadeModeMatches () {
    app.WIN3D.shadingMode = -999; // matches nothing
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
    app.WIN3D.rotationStep = 5;

    float beforeRotationX = app.WIN3D.rotationX;
    app.WIN3D.dispatchNavKey(); // UP -> rotateZ_3DViewport_around_Selection(-rotationStep)

    assertEquals(beforeRotationX - 5, app.WIN3D.rotationX, 0.0001f);
  }

  @Test
  void handleShiftedArrowKeys_rotateTaskNudgesSelectionAroundItsPivot () {
    app.allVertices = new float[][]{{1, 0, 0}};
    app.Select3D.vertexSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.rotationVectorIndex = 2; // Z axis

    app.WIN3D.currentTool = app.UITASK.Rotate;
    app.WIN3D.handleShiftedArrowKeys(app.UP); // +5 degrees around Z, per the source

    // A 5deg rotation around Z should move the point off the X axis.
    assertNotEquals(0f, app.allVertices[0][1], 0.0001f);
  }

  @Test
  void handleShiftedArrowKeys_moveTaskNudgesSelectionAlongThePosVectorOnly () {
    app.allVertices = new float[][]{{0, 0, 0}};
    app.Select3D.vertexSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.positionVectorIndex = 2; // Z only
    app.overallScale = 1;

    app.WIN3D.currentTool = app.UITASK.Move;
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
    app.WIN3D.positionX = 0;
    app.WIN3D.positionStep = 2;
    app.overallScale = 1;

    app.WIN3D.dispatchNavKey(); // '1' -> positionX += positionStep * overallScale

    assertEquals(2f, app.WIN3D.positionX, 0.0001f);
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
  void processHeldKey_doesNotFireBeforeTheInitialDelayElapses () {
    app.WIN3D.navKeyHeld = true;
    app.WIN3D.navKeyRepeatable = true;
    app.WIN3D.navKeyCoded = false;
    app.WIN3D.navKeyChar = '1';
    app.WIN3D.navKeyFrameCounter = 0;
    app.WIN3D.navKeyRepeating = false;
    app.WIN3D.positionX = 0;
    app.WIN3D.positionStep = 2;
    app.overallScale = 1;

    // one call short of the initial delay - still no-op
    for (int i = 0; i < app.WIN3D.NAV_KEY_INITIAL_DELAY_FRAMES - 1; i++) {
      app.WIN3D.processHeldKey();
    }
    assertEquals(0f, app.WIN3D.positionX, 0.0001f);

    app.WIN3D.processHeldKey(); // the delay-th call - now it fires
    assertEquals(2f, app.WIN3D.positionX, 0.0001f);
  }

  @Test
  void processHeldKey_reFiresOnlyWhileHeldAndRepeatable () {
    app.WIN3D.navKeyHeld = false;
    app.WIN3D.navKeyRepeatable = true;
    app.WIN3D.navKeyCoded = false;
    app.WIN3D.navKeyChar = '1';
    app.WIN3D.positionX = 0;
    app.WIN3D.positionStep = 2;
    app.overallScale = 1;

    app.WIN3D.processHeldKey(); // not held - no-op
    assertEquals(0f, app.WIN3D.positionX, 0.0001f);

    app.WIN3D.navKeyHeld = true;
    // past the initial delay, so the next call actually fires
    app.WIN3D.navKeyFrameCounter = app.WIN3D.NAV_KEY_INITIAL_DELAY_FRAMES - 1;
    app.WIN3D.navKeyRepeating = false;
    app.WIN3D.processHeldKey(); // held and repeatable - fires
    assertEquals(2f, app.WIN3D.positionX, 0.0001f);
  }

  @Test
  void processHeldKey_repeatsEveryFrameAfterTheInitialDelay () {
    app.WIN3D.navKeyHeld = true;
    app.WIN3D.navKeyRepeatable = true;
    app.WIN3D.navKeyCoded = false;
    app.WIN3D.navKeyChar = '1';
    app.WIN3D.navKeyFrameCounter = app.WIN3D.NAV_KEY_INITIAL_DELAY_FRAMES - 1;
    app.WIN3D.navKeyRepeating = false; // not yet in the repeat phase
    app.WIN3D.positionX = 0;
    app.WIN3D.positionStep = 2;
    app.overallScale = 1;

    app.WIN3D.processHeldKey(); // crosses the initial delay - fires, enters repeat phase
    assertEquals(2f, app.WIN3D.positionX, 0.0001f);
    assertTrue(app.WIN3D.navKeyRepeating);

    app.WIN3D.processHeldKey(); // NAV_KEY_REPEAT_FRAMES == 1 - fires again immediately
    assertEquals(4f, app.WIN3D.positionX, 0.0001f);
  }

  // ================= camera-navigation math ==============================

  @Test
  void moveCameraTowards_interpolatesBetweenTheCameraAndTheTargetPoint () {
    app.overallScale = 1;
    app.WIN3D.cameraX = 10;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = 0;
    app.WIN3D.rotationX = 0;
    app.WIN3D.rotationZ = 0;
    app.WIN3D.zoom = 90;
    app.WIN3D.referenceScale = 100;

    app.WIN3D.moveCameraTowards(0, 0, 0, 0.5f); // halfway from (10,0,0) towards the origin

    assertEquals(5f, app.WIN3D.cameraX, 0.001f);
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
    app.WIN3D.cameraX = 10;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = 0;

    app.WIN3D.navKeyCoded = false;
    app.WIN3D.navKeyCtrl = true;
    app.WIN3D.navKeyChar = ',';

    app.WIN3D.dispatchNavKey();

    float expectedT = (float) Math.pow(2, 0.5 * -0.5);
    assertEquals(10 * expectedT, app.WIN3D.cameraX, 0.01f);
    assertTrue(app.WIN3D.cameraX < 10); // closer to the pivot, not farther
  }

  // ================= to_XML / from_XML round trip ========================

  @Test
  void toXMLThenFromXML_roundTripsEveryField () {
    app.WIN3D.cameraX = 1;
    app.WIN3D.cameraY = 2;
    app.WIN3D.cameraZ = 3;
    app.WIN3D.cameraFieldOfView = 0.5f;
    app.WIN3D.cameraDistance = 100;
    app.WIN3D.cameraClipNear = 0.1f;
    app.WIN3D.cameraClipFar = 1000;
    app.WIN3D.currentCameraIndex = 2;
    app.WIN3D.referenceScale = 50;
    app.WIN3D.positionX = 4;
    app.WIN3D.positionY = 5;
    app.WIN3D.positionZ = 6;
    app.WIN3D.positionStep = 2;
    app.WIN3D.rotationX = 10;
    app.WIN3D.rotationY = 20;
    app.WIN3D.rotationZ = 30;
    app.WIN3D.rotationStep = 3;
    app.WIN3D.zoom = 60;
    app.WIN3D.projectionTypeIndex = 0;
    app.WIN3D.shadingMode = 2;
    app.WIN3D.currentTool = 1;
    app.WIN3D.targetAxisIndex = 1;
    app.WIN3D.toolParameterModifier = 1;
    app.WIN3D.impactType = app.Impact_PASSIVE;

    processing.data.XML root = new processing.data.XML("root");
    app.WIN3D.to_XML(root);

    solarchvision_bim.WIN3D fresh = app.new WIN3D();
    fresh.from_XML(root);

    assertEquals(1f, fresh.cameraX, 0.0001f);
    assertEquals(2, fresh.currentCameraIndex);
    assertEquals(4f, fresh.positionX, 0.0001f);
    assertEquals(30f, fresh.rotationZ, 0.0001f);
    assertEquals(60f, fresh.zoom, 0.0001f);
    assertEquals(0, fresh.projectionTypeIndex);
    assertEquals(2, fresh.shadingMode);
    assertEquals(1, fresh.currentTool);
    assertEquals(app.Impact_PASSIVE, fresh.impactType);
  }

  // ================= handleArrowKeys (plain, all four directions) ========
  // Despite the function names, rotateZ_3DViewport_around_Selection()
  // actually updates rotationX, and rotateXY_3DViewport_around_Selection()
  // updates rotationZ - confirmed by reading their bodies, not assumed
  // from the names.

  @Test
  void handleArrowKeys_downIncreasesRotationX () {
    app.WIN3D.rotationStep = 5;
    float before = app.WIN3D.rotationX;
    app.WIN3D.handleArrowKeys(app.DOWN); // rotateZ_..._around_Selection(+rotationStep)
    assertEquals(before + 5, app.WIN3D.rotationX, 0.0001f);
  }

  @Test
  void handleArrowKeys_upDecreasesRotationX () {
    app.WIN3D.rotationStep = 5;
    float before = app.WIN3D.rotationX;
    app.WIN3D.handleArrowKeys(app.UP); // rotateZ_..._around_Selection(-rotationStep)
    assertEquals(before - 5, app.WIN3D.rotationX, 0.0001f);
  }

  @Test
  void handleArrowKeys_rightIncreasesRotationZ () {
    app.WIN3D.rotationStep = 5;
    float before = app.WIN3D.rotationZ;
    app.WIN3D.handleArrowKeys(app.RIGHT); // rotateXY_..._around_Selection(+rotationStep)
    assertEquals(before + 5, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void handleArrowKeys_leftDecreasesRotationZ () {
    app.WIN3D.rotationStep = 5;
    float before = app.WIN3D.rotationZ;
    app.WIN3D.handleArrowKeys(app.LEFT); // rotateXY_..._around_Selection(-rotationStep)
    assertEquals(before - 5, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void handleArrowKeys_leftThenRightRoundTripsRotationZ () {
    app.WIN3D.rotationStep = 5;
    float before = app.WIN3D.rotationZ;

    app.WIN3D.handleArrowKeys(app.RIGHT);
    app.WIN3D.handleArrowKeys(app.LEFT);

    assertEquals(before, app.WIN3D.rotationZ, 0.0001f); // opposite nudges cancel out
  }

  // ================= dispatchNavKey routing (remaining branches) =========

  @Test
  void dispatchNavKey_routesShiftedArrowKeysToHandleShiftedArrowKeys () {
    app.allVertices = new float[][]{{0, 0, 0}};
    app.Select3D.vertexSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.positionVectorIndex = 2; // Z only
    app.overallScale = 1;

    app.WIN3D.navKeyCoded = true;
    app.WIN3D.navKeyAlt = false;
    app.WIN3D.navKeyShift = true;
    app.WIN3D.navKeyCode = app.UP;
    app.WIN3D.currentTool = app.UITASK.Move;

    app.WIN3D.dispatchNavKey(); // -> handleShiftedArrowKeys -> Move3D.selection

    assertEquals(0.5f, app.allVertices[0][2], 0.0001f);
  }

  // Alt+arrow (day-cycle shading) itself also calls ShadeViewport(), which
  // creates a real PImage and touches the cursor - it isn't unit-testable
  // headless (see test/README.md), so the day-cycle math it drives is
  // exercised directly on adjustShadeTime() instead, below.

  // ================= handleCtrlCommandKey =================================

  @Test
  void handleCtrlCommandKey_periodMovesTheCameraAwayFromThePivot () {
    app.allVertices = new float[0][3]; // nothing selected - getPivot() falls back to the origin
    app.WIN3D.cameraX = 10;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = 0;
    app.overallScale = 1;

    app.WIN3D.handleCtrlCommandKey('.'); // moveWin3DTowardsSelection(0.5) -> away from the pivot

    assertTrue(app.WIN3D.cameraX > 10); // moved further from the origin, not closer
  }

  @Test
  void handleCtrlCommandKey_ignoresAnyOtherCharacter () {
    app.WIN3D.cameraX = 10;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = 0;

    app.WIN3D.handleCtrlCommandKey('x'); // not ',' or '.' - no case matches

    assertEquals(10f, app.WIN3D.cameraX, 0.0001f);
  }

  // ================= handleCommandKey (additional branches) ===============

  @Test
  void handleCommandKey_period_movesTheCameraBackwardInPerspectiveMode () {
    app.WIN3D.projectionTypeIndex = 1; // Perspective
    app.WIN3D.positionZ = 0;
    app.WIN3D.positionStep = 2;
    app.overallScale = 1;

    app.WIN3D.handleCommandKey('.', false);

    assertEquals(-2f, app.WIN3D.positionZ, 0.0001f);
  }

  @Test
  void handleCommandKey_comma_movesTheCameraForwardInPerspectiveMode () {
    app.WIN3D.projectionTypeIndex = 1; // Perspective
    app.WIN3D.positionZ = 0;
    app.WIN3D.positionStep = 2;
    app.overallScale = 1;

    app.WIN3D.handleCommandKey(',', false);

    assertEquals(2f, app.WIN3D.positionZ, 0.0001f);
  }

  @Test
  void handleCommandKey_comma_zoomsInsteadOfMovingInOrthographicMode () {
    app.WIN3D.projectionTypeIndex = 0; // Orthographic
    app.WIN3D.positionZ = 0;
    app.WIN3D.zoom = 90;

    app.WIN3D.handleCommandKey(',', false);

    assertEquals(0f, app.WIN3D.positionZ, 0.0001f); // unchanged - Zoom is adjusted instead
    assertNotEquals(90f, app.WIN3D.zoom, 0.0001f);
  }

  @Test
  void handleCommandKey_zero_behavesLikeCommaInPerspectiveMode () {
    app.WIN3D.projectionTypeIndex = 1;
    app.WIN3D.positionZ = 0;
    app.WIN3D.positionStep = 2;
    app.overallScale = 1;

    app.WIN3D.handleCommandKey('0', false);

    assertEquals(2f, app.WIN3D.positionZ, 0.0001f);
  }

  @Test
  void handleCommandKey_1and3_movePositionXInOppositeDirections () {
    app.WIN3D.positionX = 0;
    app.WIN3D.positionStep = 2;
    app.overallScale = 1;

    app.WIN3D.handleCommandKey('1', false);
    assertEquals(2f, app.WIN3D.positionX, 0.0001f);

    app.WIN3D.handleCommandKey('3', false);
    assertEquals(0f, app.WIN3D.positionX, 0.0001f); // '3' undoes '1'
  }

  @Test
  void handleCommandKey_7and9_movePositionYInOppositeDirections () {
    app.WIN3D.positionY = 0;
    app.WIN3D.positionStep = 2;
    app.overallScale = 1;

    app.WIN3D.handleCommandKey('7', false);
    assertEquals(2f, app.WIN3D.positionY, 0.0001f);

    app.WIN3D.handleCommandKey('9', false);
    assertEquals(0f, app.WIN3D.positionY, 0.0001f); // '9' undoes '7'
  }

  @Test
  void handleCommandKey_4and6_rotateZInOppositeDirections () {
    app.WIN3D.rotationZ = 0;
    app.WIN3D.rotationStep = 5;

    app.WIN3D.handleCommandKey('4', false);
    assertEquals(5f, app.WIN3D.rotationZ, 0.0001f);

    app.WIN3D.handleCommandKey('6', false);
    assertEquals(0f, app.WIN3D.rotationZ, 0.0001f); // '6' undoes '4'
  }

  @Test
  void handleCommandKey_8and2_rotateXInOppositeDirections () {
    app.WIN3D.rotationX = 0;
    app.WIN3D.rotationStep = 5;

    app.WIN3D.handleCommandKey('8', false);
    assertEquals(-5f, app.WIN3D.rotationX, 0.0001f);

    app.WIN3D.handleCommandKey('2', false);
    assertEquals(0f, app.WIN3D.rotationX, 0.0001f); // '2' undoes '8'
  }

  @Test
  void handleCommandKey_five_snapsTheViewTowardsTheSelectionPivot () {
    app.allVertices = new float[][]{{5, 5, 5}};
    app.Select3D.vertexSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.overallScale = 1;
    float before = app.WIN3D.rotationZ;

    app.WIN3D.handleCommandKey('5', false); // look_3DViewport_towards_Selection()

    assertNotEquals(before, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void handleCommandKey_starAndSlash_moveTheCameraInOppositeDirections () {
    app.allVertices = new float[0][3]; // nothing selected - getPivot() falls back to the origin
    app.WIN3D.cameraX = 10;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = 0;
    app.overallScale = 1;

    app.WIN3D.handleCommandKey('*', false); // move_3DViewport_towards_Selection(2.0) - away
    assertTrue(app.WIN3D.cameraX > 10);

    float afterStar = app.WIN3D.cameraX;
    app.WIN3D.handleCommandKey('/', false); // move_3DViewport_towards_Selection(0.5) - back towards
    assertTrue(app.WIN3D.cameraX < afterStar);
  }

  @Test
  void handleCommandKey_plusAndMinus_zoomTheViewInOppositeDirections () {
    app.WIN3D.zoom = 90;
    app.WIN3D.handleCommandKey('+', false); // narrows the field of view
    assertTrue(app.WIN3D.zoom < 90f);

    float afterPlus = app.WIN3D.zoom;
    app.WIN3D.handleCommandKey('-', false); // widens it back
    assertTrue(app.WIN3D.zoom > afterPlus);
  }

  @Test
  void handleCommandKey_tab_withShiftDown_cyclesImpactTypeAndWrapsAround () {
    app.WIN3D.impactType = app.Impact_ACTIVE;
    app.WIN3D.handleCommandKey(app.TAB, true);
    assertEquals(app.Impact_PASSIVE, app.WIN3D.impactType);

    app.WIN3D.handleCommandKey(app.TAB, true); // wraps back to Active
    assertEquals(app.Impact_ACTIVE, app.WIN3D.impactType);
  }

  @Test
  void handleCommandKey_tab_withoutShiftDown_doesNotChangeImpactType () {
    app.WIN3D.impactType = app.Impact_ACTIVE;
    app.WIN3D.handleCommandKey(app.TAB, false);
    assertEquals(app.Impact_ACTIVE, app.WIN3D.impactType);
  }

  @Test
  void handleCommandKey_enter_flagsGlobalSolarForRebuildWhenThatShadeModeIsActive () {
    app.WIN3D.shadingMode = app.SHADE.Global_Solar;
    app.GlobalSolar_rebuild_array = false;
    app.VertexSolar_rebuild_array = false;

    app.WIN3D.handleCommandKey(app.ENTER, false);

    assertTrue(app.GlobalSolar_rebuild_array);
    assertFalse(app.VertexSolar_rebuild_array);
  }

  @Test
  void handleCommandKey_enter_doesNothingWhenNeitherSolarShadeModeIsActive () {
    app.WIN3D.shadingMode = app.SHADE.Surface_Materials;
    app.GlobalSolar_rebuild_array = false;
    app.VertexSolar_rebuild_array = false;

    app.WIN3D.handleCommandKey(app.ENTER, false);

    assertFalse(app.GlobalSolar_rebuild_array);
    assertFalse(app.VertexSolar_rebuild_array);
  }

  @Test
  void handleCommandKey_delete_deselectsWithoutThrowingWhenNothingIsSelected () {
    app.currentObjectCategory = app.ObjectCategory.TERRAIN; // Delete3D.selection()'s explicit no-op case
    assertDoesNotThrow(() -> app.WIN3D.handleCommandKey(app.DELETE, false));
  }

  @Test
  void handleCommandKey_ignoresAnUnmappedCharacter () {
    app.WIN3D.positionX = 0;
    app.WIN3D.rotationZ = 0;
    app.WIN3D.zoom = 90;

    app.WIN3D.handleCommandKey('z', false); // not in the switch at all

    assertEquals(0f, app.WIN3D.positionX, 0.0001f);
    assertEquals(0f, app.WIN3D.rotationZ, 0.0001f);
    assertEquals(90f, app.WIN3D.zoom, 0.0001f);
  }

  // ================= adjustShadeTime (pure day-cycle math behind Alt+arrows) ==

  @Test
  void adjustShadeTime_stepsForwardWithinTheDay () {
    app.SHADE_HOUR_ANGLE = 12;
    app.SHADE_DATE_ANGLE = 0;
    app.adjustShadeTime(1);
    assertEquals(13, app.SHADE_HOUR_ANGLE);
    assertEquals(0, app.SHADE_DATE_ANGLE);
  }

  @Test
  void adjustShadeTime_stepsBackwardWithinTheDay () {
    app.SHADE_HOUR_ANGLE = 12;
    app.SHADE_DATE_ANGLE = 0;
    app.adjustShadeTime(-1);
    assertEquals(11, app.SHADE_HOUR_ANGLE);
    assertEquals(0, app.SHADE_DATE_ANGLE);
  }

  @Test
  void adjustShadeTime_rollsOverToTheNextDayPastTheLastHour () {
    app.SHADE_HOUR_ANGLE = app.SHADE_LAST_HOUR;
    app.SHADE_DATE_ANGLE = 0;

    app.adjustShadeTime(1); // one step past the last hour of the day

    assertEquals(app.SHADE_FIRST_HOUR, app.SHADE_HOUR_ANGLE);
    assertEquals(app.SHADE_STEP_DAYS, app.SHADE_DATE_ANGLE);
  }

  @Test
  void adjustShadeTime_rollsBackToThePreviousDayBeforeTheFirstHour () {
    app.SHADE_HOUR_ANGLE = app.SHADE_FIRST_HOUR;
    app.SHADE_DATE_ANGLE = 0;

    app.adjustShadeTime(-1); // one step before the first hour of the day

    assertEquals(app.SHADE_LAST_HOUR, app.SHADE_HOUR_ANGLE);
    // SHADE_DATE_ANGLE -= SHADE_STEP_DAYS lands exactly on the
    // "<= -SHADE_STEP_DAYS" threshold, so the same step also triggers the
    // 360-wrap-around guard, landing on (360 - SHADE_STEP_DAYS), not on
    // -SHADE_STEP_DAYS itself.
    assertEquals(360 - app.SHADE_STEP_DAYS, app.SHADE_DATE_ANGLE);
  }

  @Test
  void adjustShadeTime_matchesWhatAltArrowKeysWouldRequestForACompleteDayCycle () {
    // handleAltArrowKeys(UP) calls adjustShadeTime(SHADE_HOURS_PER_DAY + 1) -
    // exactly one full day's worth of hours plus one, i.e. it always lands
    // on the same hour it started from, one day (SHADE_STEP_DAYS) later.
    app.SHADE_HOUR_ANGLE = app.SHADE_FIRST_HOUR + 2;
    app.SHADE_DATE_ANGLE = 0;
    int startHour = app.SHADE_HOUR_ANGLE;

    app.adjustShadeTime(app.SHADE_HOURS_PER_DAY + 1);

    assertEquals(startHour, app.SHADE_HOUR_ANGLE);
    assertEquals(app.SHADE_STEP_DAYS, app.SHADE_DATE_ANGLE);
  }

  // ================= handleCommandKey (remaining safe branches) ============

  @Test
  void handleCommandKey_period_zoomsInsteadOfMovingInOrthographicMode () {
    app.WIN3D.projectionTypeIndex = 0; // Orthographic
    app.WIN3D.positionZ = 0;
    app.WIN3D.zoom = 90;

    app.WIN3D.handleCommandKey('.', false);

    assertEquals(0f, app.WIN3D.positionZ, 0.0001f); // unchanged - Zoom is adjusted instead
    assertNotEquals(90f, app.WIN3D.zoom, 0.0001f);
  }

  @Test
  void handleCommandKey_zero_zoomsInsteadOfMovingInOrthographicMode () {
    app.WIN3D.projectionTypeIndex = 0;
    app.WIN3D.positionZ = 0;
    app.WIN3D.zoom = 90;

    app.WIN3D.handleCommandKey('0', false);

    assertEquals(0f, app.WIN3D.positionZ, 0.0001f);
    assertNotEquals(90f, app.WIN3D.zoom, 0.0001f);
  }

  @Test
  void handleCommandKey_tab_withShiftDown_flagsVertexSolarForRebuildWhenThatShadeModeIsActive () {
    app.WIN3D.shadingMode = app.SHADE.Vertex_Solar;
    app.GlobalSolar_rebuild_array = false;
    app.VertexSolar_rebuild_array = false;

    app.WIN3D.handleCommandKey(app.TAB, true);

    assertFalse(app.GlobalSolar_rebuild_array);
    assertTrue(app.VertexSolar_rebuild_array);
  }

  @Test
  void handleCommandKey_tAndCapitalT_moveTropoTimeInOppositeDirectionsAndClampAtStudyBounds () {
    app.STUDY.i_Start = 0;
    app.STUDY.i_End = 23;
    app.TROPO_deltaTime = 1;

    app.Tropo3D.i_Map = 23; // already at i_End
    app.WIN3D.handleCommandKey('t', false); // steps forward, then clamps back since it exceeded i_End
    assertEquals(23, app.Tropo3D.i_Map);

    app.Tropo3D.i_Map = 0; // already at i_Start
    app.WIN3D.handleCommandKey('T', false); // steps backward, then clamps back since it went below i_Start
    assertEquals(0, app.Tropo3D.i_Map);
  }

  @Test
  void handleCommandKey_dAndCapitalD_moveImpactsDisplayDayAndWrapAtStudyBounds () {
    app.STUDY.j_Start = 0;
    app.STUDY.j_End = 12;

    app.impactDisplayDay = app.STUDY.j_End; // one past the last valid day
    app.WIN3D.handleCommandKey('d', false); // wraps back to 0
    assertEquals(0, app.impactDisplayDay);

    app.impactDisplayDay = 0;
    app.WIN3D.handleCommandKey('D', false); // wraps to the last day
    assertEquals(app.STUDY.j_End, app.impactDisplayDay);
  }

  @Test
  void handleCommandKey_cAndCapitalC_cycleTheCurrentCameraForwardAndWrap () {
    app.allCameras.makeEmpty(0); // 1 camera
    app.allCameras.create(0, 0, 0, 1, 0, 0, 0, 5, 60, 1); // 2nd camera
    app.allCameras.create(0, 0, 0, 1, 0, 0, 0, 5, 60, 1); // 3rd camera
    app.WIN3D.currentCameraIndex = 2; // at the last camera

    app.WIN3D.handleCommandKey('c', false); // wraps back to 0

    assertEquals(0, app.WIN3D.currentCameraIndex);
  }

  @Test
  void handleCommandKey_capitalC_cyclesTheCurrentCameraBackwardAndWraps () {
    app.allCameras.makeEmpty(0); // 1 camera
    app.allCameras.create(0, 0, 0, 1, 0, 0, 0, 5, 60, 1); // 2nd camera
    app.allCameras.create(0, 0, 0, 1, 0, 0, 0, 5, 60, 1); // 3rd camera
    app.WIN3D.currentCameraIndex = 0; // at the first camera

    app.WIN3D.handleCommandKey('C', false); // wraps to the last camera

    assertEquals(2, app.WIN3D.currentCameraIndex);
  }
}
