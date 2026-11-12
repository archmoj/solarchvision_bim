import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// handleTruckOrbitWheel() (mouseWheel.pde) picks one of adjustPositionXWheel()/
// adjustPositionYWheel()/adjustRotationXWheel()/adjustRotationZWheel() -
// each already fully covered elsewhere via their own +PositionX/+PositionY/
// +RotationX/+RotationZ commands - based on User3D.toolParameterModifier
// (0: Truck, 1: Orbit) and User3D.targetAxisIndex (0/1). What was still
// missing was handleTruckOrbitWheel()'s OWN 4 branch combinations ever
// being exercised directly (6 missed instructions, 4 of its 8 branches),
// not the downstream functions themselves.
class HandleTruckOrbitWheelTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
    app.WIN3D.positionStep = 1;
    app.WIN3D.rotationStep = 1;
    app.overallScale = 1;
  }

  @Test
  void truckWithAxisZero_adjustsPositionX () {
    app.User3D.toolParameterModifier = 0;
    app.User3D.targetAxisIndex = 0;
    app.WIN3D.positionX = 10;
    app.WIN3D.positionY = 77; // sentinel - must be untouched

    app.handleTruckOrbitWheel(5);

    assertEquals(15f, app.WIN3D.positionX, 0.0001f);
    assertEquals(77f, app.WIN3D.positionY, 0.0001f);
  }

  @Test
  void truckWithAxisOne_adjustsPositionY () {
    app.User3D.toolParameterModifier = 0;
    app.User3D.targetAxisIndex = 1;
    app.WIN3D.positionY = 10;
    app.WIN3D.positionX = 77; // sentinel - must be untouched

    app.handleTruckOrbitWheel(5);

    assertEquals(15f, app.WIN3D.positionY, 0.0001f);
    assertEquals(77f, app.WIN3D.positionX, 0.0001f);
  }

  @Test
  void orbitWithAxisZero_adjustsRotationX () {
    app.User3D.toolParameterModifier = 1;
    app.User3D.targetAxisIndex = 0;
    app.WIN3D.rotationX = 10;
    app.WIN3D.rotationZ = 77; // sentinel - must be untouched

    app.handleTruckOrbitWheel(5);

    assertEquals(15f, app.WIN3D.rotationX, 0.0001f);
    assertEquals(77f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void orbitWithAxisOne_adjustsRotationZ () {
    app.User3D.toolParameterModifier = 1;
    app.User3D.targetAxisIndex = 1;
    app.WIN3D.rotationZ = 10;
    app.WIN3D.rotationX = 77; // sentinel - must be untouched

    app.handleTruckOrbitWheel(5);

    assertEquals(15f, app.WIN3D.rotationZ, 0.0001f);
    assertEquals(77f, app.WIN3D.rotationX, 0.0001f);
  }

  @Test
  void neitherTruckNorOrbit_changesNothing () {
    app.User3D.toolParameterModifier = -999;
    app.User3D.targetAxisIndex = 0;
    app.WIN3D.positionX = 10;
    app.WIN3D.positionY = 10;
    app.WIN3D.rotationX = 10;
    app.WIN3D.rotationZ = 10;

    app.handleTruckOrbitWheel(5);

    assertEquals(10f, app.WIN3D.positionX, 0.0001f);
    assertEquals(10f, app.WIN3D.positionY, 0.0001f);
    assertEquals(10f, app.WIN3D.rotationX, 0.0001f);
    assertEquals(10f, app.WIN3D.rotationZ, 0.0001f);
  }
}
