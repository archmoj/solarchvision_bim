import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// The camera-viewpoint command family (extraCommands.pde's __TOP__/
// __FRONT__/__LEFT__/__BACK__/__RIGHT__/__BOTTOM__/__SW__/__SE__/__NE__/
// __NW__) all delegate to UI_setTo_View_3DViewPoint(n) (uiSetTo.pde),
// which in turn drives WIN3D.rotateZ_3DViewport_around_Selection()/
// rotateXY_3DViewport_around_Selection() - real rotation math (camera
// position, pivot, trig), not just a field flip. All 10 commands, plus
// the helper itself, were at 0% coverage.
//
// Each call's own angle argument is built as "(target - WIN3D.rotationX)"
// (or rotationZ) - so inside rotateZ_3DViewport_around_Selection()'s own
// "this.rotationX += t", the result is current + (target - current),
// landing on exactly `target` regardless of whatever rotationX/rotationZ
// started at. That's what's checked directly below: a deterministic,
// hand-verifiable invariant, without re-deriving the fuller camera-
// position/pivot trig cascade those two methods also run alongside it
// (Select3D.getPivot() et al. - exercised here as a side effect, but not
// asserted on).
class ViewpointCommandsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    // Same reasoning as ViewNavigationCommandsTest.java/RunScriptTest.java:
    // these are exactly the kind of bare, single-word commands ("Top",
    // "Front", ...) a menu/toolbar action is also very likely registered
    // under - an empty allActions map sidesteps that collision entirely.
    app.allActions = new java.util.HashMap<>();
  }

  // Every one of these commands calls WIN3D.apply_currentCameraIndex()
  // first (after forcing currentCameraIndex to 0), which itself
  // overwrites rotationX/rotationZ from camera index 0's own stored
  // values - NOT whatever this test last set them to - before the rotate
  // calls below ever run. So setting a sentinel here isn't about making
  // the command "override an untouched default"; it's there so the
  // assertions below aren't vacuously true merely because rotationX/
  // rotationZ already happened to sit at the exact target - a reader can
  // see the command (via apply_currentCameraIndex() + the rotate calls'
  // own "target - current, added back" math) truly lands on that target
  // from an arbitrary starting point, not just from this app's one
  // particular bare-construction default (rotationX=90, rotationZ=-45,
  // viewport3D.pde - which also happens to be camera index 0's own
  // stored value, seeded from those same fields at construction time via
  // Cameras.add_first(), cameras.pde).
  private void setSentinelRotation () {
    app.WIN3D.rotationX = 12.5f;
    app.WIN3D.rotationZ = -67.5f;
  }

  @Test
  void top_setsRotationXAndZToZero () {
    setSentinelRotation();

    assertEquals("", app.runScriptLine("TOP"));

    assertEquals(0f, app.WIN3D.rotationX, 0.0001f);
    assertEquals(0f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void front_setsRotationXTo90AndZToZero () {
    setSentinelRotation();

    assertEquals("", app.runScriptLine("FRONT"));

    assertEquals(90f, app.WIN3D.rotationX, 0.0001f);
    assertEquals(0f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void left_setsRotationXTo90AndZToMinus90 () {
    setSentinelRotation();

    assertEquals("", app.runScriptLine("LEFT"));

    assertEquals(90f, app.WIN3D.rotationX, 0.0001f);
    assertEquals(-90f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void back_setsRotationXTo90AndZTo180 () {
    setSentinelRotation();

    assertEquals("", app.runScriptLine("BACK"));

    assertEquals(90f, app.WIN3D.rotationX, 0.0001f);
    assertEquals(180f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void right_setsRotationXTo90AndZTo90 () {
    setSentinelRotation();

    assertEquals("", app.runScriptLine("RIGHT"));

    assertEquals(90f, app.WIN3D.rotationX, 0.0001f);
    assertEquals(90f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void bottom_setsRotationXTo180AndZToZero () {
    setSentinelRotation();

    assertEquals("", app.runScriptLine("BOTTOM"));

    assertEquals(180f, app.WIN3D.rotationX, 0.0001f);
    assertEquals(0f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void southWest_setsRotationXTo90AndZToMinus45 () {
    setSentinelRotation();

    assertEquals("", app.runScriptLine("S.W."));

    assertEquals(90f, app.WIN3D.rotationX, 0.0001f);
    assertEquals(-45f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void southEast_setsRotationXTo90AndZTo45 () {
    setSentinelRotation();

    assertEquals("", app.runScriptLine("S.E."));

    assertEquals(90f, app.WIN3D.rotationX, 0.0001f);
    assertEquals(45f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void northEast_setsRotationXTo90AndZTo135 () {
    setSentinelRotation();

    assertEquals("", app.runScriptLine("N.E."));

    assertEquals(90f, app.WIN3D.rotationX, 0.0001f);
    assertEquals(135f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void northWest_setsRotationXTo90AndZToMinus135 () {
    setSentinelRotation();

    assertEquals("", app.runScriptLine("N.W."));

    assertEquals(90f, app.WIN3D.rotationX, 0.0001f);
    assertEquals(-135f, app.WIN3D.rotationZ, 0.0001f);
  }

  // ================= shared setup: currentCameraIndex is always forced to 0 ==

  @Test
  void everyViewpointCommand_forcesCurrentCameraIndexToZero () {
    app.WIN3D.currentCameraIndex = 3;

    app.runScriptLine("TOP");

    assertEquals(0, app.WIN3D.currentCameraIndex, "UI_setTo_View_3DViewPoint() always resets to the Free Viewport camera (index 0) first");
  }
}
