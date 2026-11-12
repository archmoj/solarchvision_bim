import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// extraCommands.pde's "+"-prefixed incremental view-rotation commands -
// +ORBITSELECTIONXY, +ORBITSELECTIONZ, +ORBITSELECTION, +CAMERAROLLXYZ -
// each compute a delta from their own numeric argument(s) and WIN3D.
// rotationStep, then add it onto WIN3D.rotationZ or rotationX via
// WIN3D.rotateXY_3DViewport_around_Selection()/rotateZ_3DViewport_
// around_Selection() - the same two methods ViewpointCommandsTest.java
// already confirms are headlessly safe (pure trig/array math, no
// drawing). Since each is a plain "+=" by a value computed before the
// call, the resulting rotationX/rotationZ is exactly old value + delta,
// independent of whatever the fuller camera-position/pivot trig cascade
// those methods also run computes. All 4 commands were at 0% coverage.
class OrbitSelectionCommandsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
    app.WIN3D.rotationStep = 1; // sentinel: keeps every delta below a plain, round number
  }

  // ================= +ORBITSELECTIONXY (rotationZ only) ======================

  @Test
  void orbitSelectionXY_addsMinusTenTimesDxTimesRotationStepToRotationZ () {
    app.WIN3D.rotationZ = 10;
    app.WIN3D.rotationX = 77; // sentinel - must be untouched by this command

    assertEquals("", app.runScriptLine("+ORBITSELECTIONXY 2"));

    assertEquals(10 - 10 * 2 * 1, app.WIN3D.rotationZ, 0.0001f); // -10
    assertEquals(77f, app.WIN3D.rotationX, 0.0001f);
  }

  @Test
  void orbitSelectionXY_withNoArgument_returnsAHintAndChangesNothing () {
    app.WIN3D.rotationZ = 10;

    assertEquals("+OrbitSelectionXY ?", app.runScriptLine("+ORBITSELECTIONXY"));

    assertEquals(10f, app.WIN3D.rotationZ, 0.0001f);
  }

  // ================= +ORBITSELECTIONZ (rotationX only) =======================

  @Test
  void orbitSelectionZ_addsMinusTenTimesDyTimesRotationStepToRotationX () {
    app.WIN3D.rotationX = 20;
    app.WIN3D.rotationZ = 77; // sentinel - must be untouched by this command

    assertEquals("", app.runScriptLine("+ORBITSELECTIONZ 3"));

    assertEquals(20 - 10 * 3 * 1, app.WIN3D.rotationX, 0.0001f); // -10
    assertEquals(77f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void orbitSelectionZ_withNoArgument_returnsAHintAndChangesNothing () {
    app.WIN3D.rotationX = 20;

    assertEquals("+OrbitSelectionZ ?", app.runScriptLine("+ORBITSELECTIONZ"));

    assertEquals(20f, app.WIN3D.rotationX, 0.0001f);
  }

  // ================= +ORBITSELECTION (both, named dx=/dy= params) ============

  @Test
  void orbitSelection_appliesDxToRotationZAndDyToRotationX () {
    app.WIN3D.rotationZ = 10;
    app.WIN3D.rotationX = 20;

    assertEquals("", app.runScriptLine("+ORBITSELECTION dx=2 dy=3"));

    assertEquals(10 - 10 * 2 * 1, app.WIN3D.rotationZ, 0.0001f); // -10
    assertEquals(20 - 10 * 3 * 1, app.WIN3D.rotationX, 0.0001f); // -10
  }

  @Test
  void orbitSelection_missingOneParam_defaultsItToZero () {
    // getF()'s own default (0) for a parameter that's simply absent, not
    // "dx=2" alone failing to parse - dy is left out entirely here.
    app.WIN3D.rotationZ = 10;
    app.WIN3D.rotationX = 20;

    assertEquals("", app.runScriptLine("+ORBITSELECTION dx=2"));

    assertEquals(10 - 10 * 2 * 1, app.WIN3D.rotationZ, 0.0001f); // dx=2 applied
    assertEquals(20f, app.WIN3D.rotationX, 0.0001f); // dy defaulted to 0 - no change
  }

  @Test
  void orbitSelection_withNoArguments_returnsAHintAndChangesNothing () {
    app.WIN3D.rotationZ = 10;
    app.WIN3D.rotationX = 20;

    assertEquals("+OrbitSelection dx=? dy=?", app.runScriptLine("+ORBITSELECTION"));

    assertEquals(10f, app.WIN3D.rotationZ, 0.0001f);
    assertEquals(20f, app.WIN3D.rotationX, 0.0001f);
  }

  // ================= +CAMERAROLLXYZ (axis picked by User3D.targetAxisIndex) ==

  @Test
  void cameraRollXYZ_withTargetAxisZero_addsPlainDeltaToRotationX () {
    app.User3D.targetAxisIndex = 0;
    app.WIN3D.rotationX = 5;
    app.WIN3D.rotationZ = 77; // sentinel - must be untouched on this axis

    assertEquals("", app.runScriptLine("+CAMERAROLLXYZ 4"));

    assertEquals(5 + 4 * 1, app.WIN3D.rotationX, 0.0001f); // 9 - note: no "-10 *" here, unlike +ORBITSELECTIONZ
    assertEquals(77f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void cameraRollXYZ_withTargetAxisOne_addsPlainDeltaToRotationZ () {
    app.User3D.targetAxisIndex = 1;
    app.WIN3D.rotationZ = 5;
    app.WIN3D.rotationX = 77; // sentinel - must be untouched on this axis

    assertEquals("", app.runScriptLine("+CAMERAROLLXYZ 4"));

    assertEquals(5 + 4 * 1, app.WIN3D.rotationZ, 0.0001f); // 9
    assertEquals(77f, app.WIN3D.rotationX, 0.0001f);
  }

  @Test
  void cameraRollXYZ_withNeitherTargetAxis_changesNothing () {
    app.User3D.targetAxisIndex = -999;
    app.WIN3D.rotationX = 5;
    app.WIN3D.rotationZ = 5;

    assertEquals("", app.runScriptLine("+CAMERAROLLXYZ 4"));

    assertEquals(5f, app.WIN3D.rotationX, 0.0001f);
    assertEquals(5f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void cameraRollXYZ_withNoArgument_returnsAHintAndChangesNothing () {
    app.User3D.targetAxisIndex = 0;
    app.WIN3D.rotationX = 5;

    assertEquals("+CameraRollXYZ ?", app.runScriptLine("+CAMERAROLLXYZ"));

    assertEquals(5f, app.WIN3D.rotationX, 0.0001f);
  }
}
