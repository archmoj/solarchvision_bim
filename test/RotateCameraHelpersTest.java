import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// mouseDragged.pde's rotateCameraXY()/rotateCameraZ()/rotateCameraBoth()
// are thin wrappers that build a "+OrbitSelectionXY"/"+OrbitSelectionZ"/
// "+OrbitSelection" command string from their own float argument(s) -
// via plain string concatenation, so e.g. rotateCameraXY(2) dispatches
// runScriptLine("+OrbitSelectionXY 2.0") - and hand it to runScriptLine().
// That's the exact mechanism OrbitSelectionCommandsTest.java already
// verifies in detail (down to the "old value + delta" arithmetic on
// WIN3D.rotationX/rotationZ), so these tests just confirm the wrapper
// itself builds the right command string and reaches it; see that file
// for why the resulting rotationX/rotationZ math is correct. All 3 were
// at 0% coverage.
class RotateCameraHelpersTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
    app.WIN3D.rotationStep = 1; // sentinel: keeps every delta a plain, round number
  }

  @Test
  void rotateCameraXY_dispatchesToOrbitSelectionXY () {
    app.WIN3D.rotationZ = 10;
    app.WIN3D.rotationX = 77; // sentinel - must be untouched (XY-only)

    app.rotateCameraXY(2);

    assertEquals(10 - 10 * 2 * 1, app.WIN3D.rotationZ, 0.0001f); // -10
    assertEquals(77f, app.WIN3D.rotationX, 0.0001f);
  }

  @Test
  void rotateCameraZ_dispatchesToOrbitSelectionZ () {
    app.WIN3D.rotationX = 20;
    app.WIN3D.rotationZ = 77; // sentinel - must be untouched (Z-only)

    app.rotateCameraZ(3);

    assertEquals(20 - 10 * 3 * 1, app.WIN3D.rotationX, 0.0001f); // -10
    assertEquals(77f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void rotateCameraBoth_dispatchesToOrbitSelectionWithDxAndDy () {
    app.WIN3D.rotationZ = 10;
    app.WIN3D.rotationX = 20;

    app.rotateCameraBoth(2, 3);

    assertEquals(10 - 10 * 2 * 1, app.WIN3D.rotationZ, 0.0001f); // -10, from dx
    assertEquals(20 - 10 * 3 * 1, app.WIN3D.rotationX, 0.0001f); // -10, from dy
  }

  @Test
  void rotateCameraBoth_handlesNegativeAndFractionalDeltas () {
    // A non-integer argument, to confirm the float-to-string-to-float
    // round trip through the command string survives intact, not just
    // the clean whole numbers above.
    app.WIN3D.rotationZ = 10;
    app.WIN3D.rotationX = 20;

    app.rotateCameraBoth(-1.5f, 0.5f);

    assertEquals(10 - 10 * -1.5f * 1, app.WIN3D.rotationZ, 0.0001f); // 25
    assertEquals(20 - 10 * 0.5f * 1, app.WIN3D.rotationX, 0.0001f); // 15
  }
}
