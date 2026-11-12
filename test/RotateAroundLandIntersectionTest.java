import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// WIN3D.rotateXY_3DViewport_around_LandIntersection() (viewport3D.pde),
// the function behind +OrbitLand, was untested - 160 instructions.
// OrbitSelectionCommandsTest.java's own header comment originally
// skipped it as "needs real terrain-ray intersection, harder to
// guarantee safe/predictable headlessly" - revisited now with what this
// session has since confirmed about Terrain.intersect() specifically:
// it's already fully covered directly elsewhere (0 missed instructions
// in the merged report), so calling it here is calling an already-
// proven-safe function, not an unknown one.
//
// Terrain.rowCount is set to 1 first - the exact same fix
// HandleWin3DClickAtTest.java's own RIGHT-click test already
// established for the identical reason: Terrain.intersect()'s own cell
// count is (rowCount-1)*(columnCount-1), and rowCount defaults to 20,
// not 0, so its loop runs by default and reads a null this.Mesh
// (confirmed by a real failure earlier this session, not assumed).
// Setting rowCount to 1 makes that cell count exactly 0, guaranteeing a
// clean "nothing hit" (RxP[0] < 0) result rather than depending on real
// elevation data this suite doesn't have - and
// rotateXY_3DViewport_around_LandIntersection() itself returns
// immediately on exactly that result, before touching any WIN3D state
// at all, which is what each test below actually confirms.
class RotateAroundLandIntersectionTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.Terrain.rowCount = 1; // see this file's own header comment
  }

  @Test
  void onAMiss_doesNotThrow () {
    assertDoesNotThrow(() -> app.WIN3D.rotateXY_3DViewport_around_LandIntersection(10));
  }

  @Test
  void onAMiss_changesNoWIN3DState () {
    app.WIN3D.rotationZ = 5;
    app.WIN3D.cameraX = 1;
    app.WIN3D.cameraY = 2;
    app.WIN3D.cameraZ = 3;

    app.WIN3D.rotateXY_3DViewport_around_LandIntersection(10);

    assertEquals(5f, app.WIN3D.rotationZ, 0.0001f, "must return before its own \"this.rotationZ += t\" line");
    assertEquals(1f, app.WIN3D.cameraX, 0.0001f);
    assertEquals(2f, app.WIN3D.cameraY, 0.0001f);
    assertEquals(3f, app.WIN3D.cameraZ, 0.0001f);
  }
}
