import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// UI_toolBar.dismissHelper()/toggleHelper() (uiToolBar.pde) were both at
// 0% coverage even in the merged (unit + image) report. Of the whole
// "specific UI-widget rendering states" gap, these are the only two
// with a safe, non-drawing branch worth testing on their own:
//
// - dismissHelper() is pure field logic throughout - no drawing at all,
//   in either of its two branches.
// - toggleHelper() flips HelperState first, then either returns
//   immediately (if the flip just turned the helper OFF) or falls
//   through to real text/shape drawing (fill()/rect()/text()) to show
//   it. Only the "just turned off" branch is exercised here.
//
// Deliberately NOT covered: drawDrop()/drawPower() (UI_toolBar),
// drawChildRow() (UI_menuBar), and ViewFromTheSky() - each reaches a
// real drawing call (pushMatrix()/fill()/beginShape(), or
// SKY2D_graphics.beginDraw() for the latter) on its very first executed
// line, or unconditionally along every one of its own branches - no
// safe slice to isolate here short of a larger refactor, the same
// category as ShadeViewport()/preBakeViewport().
class ToolbarHelperTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void dismissHelper_whenTheHelperIsShowing_hidesItAndRevisesTheMenuBar () {
    app.UI_toolBar.HelperState = true;
    app.UI_menuBar.update = false; // sentinel - revise() must flip this back to true

    app.UI_toolBar.dismissHelper();

    assertFalse(app.UI_toolBar.HelperState);
    assertTrue(app.UI_menuBar.update);
  }

  @Test
  void dismissHelper_whenTheHelperIsAlreadyHidden_isANoOp () {
    // HelperState's own bare-construction default (false) - left
    // untouched here to double as that case.
    app.UI_menuBar.update = false;

    assertDoesNotThrow(() -> app.UI_toolBar.dismissHelper());

    assertFalse(app.UI_toolBar.HelperState);
    assertFalse(app.UI_menuBar.update, "the no-op branch must never call revise()");
  }

  @Test
  void toggleHelper_whenItWasShowing_turnsItOffAndReturnsWithoutDrawingAnything () {
    // Starting from HelperState == true: toggleHelper()'s own first line
    // flips it to false, landing on its early-return branch before ever
    // reaching text()/fill()/rect() - the only way to call this
    // function at all without a real graphics context.
    app.UI_toolBar.HelperState = true;
    app.UI_menuBar.update = false;

    assertDoesNotThrow(() -> app.UI_toolBar.toggleHelper(0, 0, "View Point", 0, 0, 0, 0));

    assertFalse(app.UI_toolBar.HelperState);
    assertTrue(app.UI_menuBar.update);
  }
}
