import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// finishWin3DSelection() (mouseReleased.pde) has the exact same shape as
// handleWin3DWheel() (HandleWin3DWheelTest.java): a WIN3D.include guard,
// then an isInside(mouseX, mouseY, ...) guard against WIN3D's own screen
// rectangle, before dispatching further. Both guards were at 0% coverage
// on this function itself.
//
// Unlike handleWin3DWheel(), what's past those guards here - isRectSelectTask()
// ? performRectSelect() : (currentTool == GetLength) ? performGetLengthMeasurement()
// : nothing - does real drawing in its first two branches (pushMatrix()/
// rect()/stroke(), or ray casting), so this file deliberately stops at
// proving the "neither" case is reached safely: on a bare app, User3D.
// currentTool defaults to UITASK.zoom_Orbit_Pan, which is neither
// UITASK.RectSelect nor greater than UITASK.Move (the two ways
// isRectSelectTask() can be true) nor UITASK.GetLength - so passing both
// guards still reaches no drawing call, which is what the third test
// below actually exercises and relies on.
class FinishWin3DSelectionTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void whenWin3DIsNotIncluded_returnsImmediately () {
    app.WIN3D.include = false;
    app.mouseX = 3; // inside the rectangle - would otherwise pass this guard
    app.mouseY = 1;

    assertDoesNotThrow(() -> app.finishWin3DSelection());
  }

  @Test
  void whenTheReleaseIsOutsideWIN3DsOwnRectangle_returnsImmediately () {
    app.WIN3D.include = true;
    // mouseX/mouseY's own bare-construction default (0) is already
    // outside WIN3D's rectangle (cX=2..cX+dX=4 at bare-construction
    // pixel_W/pixel_A/pixel_B/pixel_H defaults - see HandleWin3DWheelTest.java),
    // left untouched here to double as that case.

    assertDoesNotThrow(() -> app.finishWin3DSelection());
  }

  @Test
  void whenIncludedAndInsideTheRectangle_passesBothGuardsWithoutDrawing () {
    app.WIN3D.include = true;
    app.mouseX = 3; // strictly between WIN3D.cX (2) and cX+dX (4)
    app.mouseY = 1; // strictly between WIN3D.cY (0) and cY+dY (2)
    // User3D.currentTool is left at its bare default (zoom_Orbit_Pan) -
    // neither isRectSelectTask() nor "== GetLength" fires, so this reaches
    // (and returns from) the end of the function with no drawing call.

    assertDoesNotThrow(() -> app.finishWin3DSelection());
  }
}
