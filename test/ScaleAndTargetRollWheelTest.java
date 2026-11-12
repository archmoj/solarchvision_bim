import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// scaleObjectsWheel()/scaleSkydomeWheel()/scaleAllModelWheel()/
// handleTargetRollXYZWheel() (mouseWheel.pde) are thin wrappers - the
// same shape as RotateCameraHelpersTest.java's rotateCameraXY() et al. -
// dispatching to +ScaleObjects/+ScaleSkydome/+ScaleAllModel/
// +TargetRollXYZ via runScriptLine(). All 4 were at 0% coverage, even
// though each underlying command is otherwise already covered.
//
// The scale commands are pure field arithmetic on overallScale/
// Sky3D.radius - a factor of pow(2.0, 0.25) each way, so 4 applications
// of one direction exactly undo 4 of the other. +TargetRollXYZ
// additionally calls WIN3D.reverseTransform_3DViewport() - confirmed
// pure trig math (rotateAroundZ/rotateAroundX, no drawing), the same
// category as the rotate-around-selection methods
// ViewpointCommandsTest.java already relies on being headlessly safe.
class ScaleAndTargetRollWheelTest {

  private static final float EPS = 0.0001f;
  private static final float RADIUS_EPS = 1f; // Sky3D.radius is ~50000 - a looser absolute tolerance is appropriate there

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
  }

  // ================= scaleObjectsWheel =======================================
  // overallScale's own bare-construction default is 1.0.

  @Test
  void scaleObjectsWheel_positive_shrinksOverallScale () {
    app.scaleObjectsWheel(1);

    assertEquals(1f / (float) Math.pow(2.0, 0.25), app.overallScale, EPS);
  }

  @Test
  void scaleObjectsWheel_negative_growsOverallScale () {
    app.scaleObjectsWheel(-1);

    assertEquals((float) Math.pow(2.0, 0.25), app.overallScale, EPS);
  }

  @Test
  void scaleObjectsWheel_zero_changesNothing () {
    app.scaleObjectsWheel(0);

    assertEquals(1f, app.overallScale, EPS);
  }

  // ================= scaleSkydomeWheel ========================================
  // Sky3D.radius's own bare-construction default is 50000.

  @Test
  void scaleSkydomeWheel_positive_growsTheSkydomeRadius () {
    app.scaleSkydomeWheel(1);

    assertEquals(50000f * (float) Math.pow(2.0, 0.25), app.Sky3D.radius, RADIUS_EPS);
  }

  @Test
  void scaleSkydomeWheel_negative_shrinksTheSkydomeRadius () {
    app.scaleSkydomeWheel(-1);

    assertEquals(50000f / (float) Math.pow(2.0, 0.25), app.Sky3D.radius, RADIUS_EPS);
  }

  // ================= scaleAllModelWheel =======================================
  // Drives both overallScale and Sky3D.radius together, in the same
  // direction, unlike the two single-target commands above.

  @Test
  void scaleAllModelWheel_positive_shrinksBothOverallScaleAndSkydomeRadius () {
    app.scaleAllModelWheel(1);

    assertEquals(1f / (float) Math.pow(2.0, 0.25), app.overallScale, EPS);
    assertEquals(50000f / (float) Math.pow(2.0, 0.25), app.Sky3D.radius, RADIUS_EPS);
  }

  @Test
  void scaleAllModelWheel_negative_growsBothOverallScaleAndSkydomeRadius () {
    app.scaleAllModelWheel(-1);

    assertEquals((float) Math.pow(2.0, 0.25), app.overallScale, EPS);
    assertEquals(50000f * (float) Math.pow(2.0, 0.25), app.Sky3D.radius, RADIUS_EPS);
  }

  // ================= handleTargetRollXYZWheel =================================

  @Test
  void handleTargetRollXYZWheel_withTargetAxisZero_addsPlainDeltaToRotationX () {
    app.User3D.targetAxisIndex = 0;
    app.WIN3D.rotationStep = 1;
    app.WIN3D.rotationX = 5;
    app.WIN3D.rotationZ = 77; // sentinel - must be untouched on this axis

    app.handleTargetRollXYZWheel(4);

    assertEquals(9f, app.WIN3D.rotationX, EPS); // 5 + 4*1 - no "-10*" factor, same formula as +CameraRollXYZ
    assertEquals(77f, app.WIN3D.rotationZ, EPS);
  }

  @Test
  void handleTargetRollXYZWheel_withTargetAxisOne_addsPlainDeltaToRotationZ () {
    app.User3D.targetAxisIndex = 1;
    app.WIN3D.rotationStep = 1;
    app.WIN3D.rotationZ = 5;
    app.WIN3D.rotationX = 77; // sentinel - must be untouched on this axis

    app.handleTargetRollXYZWheel(4);

    assertEquals(9f, app.WIN3D.rotationZ, EPS);
    assertEquals(77f, app.WIN3D.rotationX, EPS);
  }

  @Test
  void handleTargetRollXYZWheel_withNeitherTargetAxis_changesNeitherRotation () {
    app.User3D.targetAxisIndex = -999;
    app.WIN3D.rotationX = 5;
    app.WIN3D.rotationZ = 5;

    assertDoesNotThrow(() -> app.handleTargetRollXYZWheel(4));

    assertEquals(5f, app.WIN3D.rotationX, EPS);
    assertEquals(5f, app.WIN3D.rotationZ, EPS);
  }
}
