import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// +MoveTowardsSelection (extraCommands.pde's __$MOVETOWARDSSELECTION__)
// dispatches to WIN3D.move_3DViewport_towards_Selection(t), which reads
// Select3D.getPivot() (pure array math, already relied on being
// headlessly safe by SelectionConversionCommandsTest.java and others)
// then calls moveCameraTowards()/reverseTransform_3DViewport() - pure
// trig, the same functions ViewpointCommandsTest.java/
// ScaleAndTargetRollWheelTest.java already confirm are headlessly safe.
// Nothing here needed a refactor - every piece was already provably
// pure - just never exercised together through this entry point before.
// Was at 0% coverage.
//
// Select3D's own bare-construction BoundingBox/pivotAlignment defaults
// put getPivot() at exactly (0, 0, 0), so WIN3D.cameraX/Y/Z are set to
// non-default sentinel values below - otherwise the "move toward the
// pivot" delta would trivially be zero regardless of t, proving nothing.
// rotationX/rotationZ are pinned to 0 (rather than their own
// bare-construction defaults of 90/-45) purely to keep the resulting
// reverseTransform_3DViewport() trig simple enough to hand-verify
// (rotateAroundZ/rotateAroundX by 0 degrees is the identity).
class MoveTowardsSelectionTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
    app.WIN3D.cameraX = 10;
    app.WIN3D.cameraY = 20;
    app.WIN3D.cameraZ = 30;
    app.WIN3D.rotationX = 0;
    app.WIN3D.rotationZ = 0;
    app.overallScale = 1;
  }

  @Test
  void movesTheCameraHalfwayTowardsTheDefaultOriginPivot () {
    // t = pow(2, 0.5 * wheelValue); wheelValue=-2 -> t=0.5, i.e. exactly
    // halfway from the camera's current position to the pivot (0,0,0).
    // Hand-derived expected result (moveCameraTowards() then
    // reverseTransform_3DViewport(), both pure, with rotationX=rotationZ=0
    // and WIN3D's own bare-construction zoom=90/referenceScale=100):
    //   newCamera = (5, 10, 15)
    //   positionX = -5, positionY = 10, positionZ ~= 71.6025
    assertEquals("", app.runScriptLine("+MOVETOWARDSSELECTION -2"));

    assertEquals(5f, app.WIN3D.cameraX, 0.001f);
    assertEquals(10f, app.WIN3D.cameraY, 0.001f);
    assertEquals(15f, app.WIN3D.cameraZ, 0.001f);
    assertEquals(-5f, app.WIN3D.positionX, 0.001f);
    assertEquals(10f, app.WIN3D.positionY, 0.001f);
    assertEquals(71.6025f, app.WIN3D.positionZ, 0.001f);
  }

  @Test
  void aTOfOne_leavesTheCameraExactlyWhereItWas () {
    // wheelValue=0 -> t=pow(2,0)=1 -> moveCameraTowards()'s own
    // "xO + t*dx" is an identity when t=1 (dx = camera - xO, so
    // xO + 1*dx = camera unchanged).
    assertEquals("", app.runScriptLine("+MOVETOWARDSSELECTION 0"));

    assertEquals(10f, app.WIN3D.cameraX, 0.001f);
    assertEquals(20f, app.WIN3D.cameraY, 0.001f);
    assertEquals(30f, app.WIN3D.cameraZ, 0.001f);
  }

  @Test
  void withNoArgument_returnsAHintAndChangesNothing () {
    assertEquals("+MoveTowardsSelection ?", app.runScriptLine("+MOVETOWARDSSELECTION"));

    assertEquals(10f, app.WIN3D.cameraX, 0.001f);
    assertEquals(20f, app.WIN3D.cameraY, 0.001f);
    assertEquals(30f, app.WIN3D.cameraZ, 0.001f);
  }
}
