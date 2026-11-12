import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// mouseReleased() has 3 of its own early-return guards - frameCount vs
// Last_initializationStep (the same guard MouseMovedTest.java's own
// setup already works around), control != USER_GUI, and
// dragging_started == 0 - in front of resetPickListDragState()/
// normalizeClickRegion() and a final dispatch to finishFrameDragSelection()
// (FRAME_drag_IMG == true) or finishWin3DSelection() (false, the
// bare-construction default - already proven headlessly safe in
// FinishWin3DSelectionTest.java). All were at 0% coverage on this
// function itself.
//
// finishFrameDragSelection() does real drawing (rect()/stroke()), so
// this file only exercises the FRAME_drag_IMG == false path through to
// finishWin3DSelection() - the same reasoning FinishWin3DSelectionTest.java
// already documents for stopping short of ITS drawing branches.
class MouseReleasedDispatchTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void beforeInitializationHasFinished_returnsImmediately () {
    // frameCount's own bare-construction default (0) is already <=
    // Last_initializationStep's default (25) - left untouched here to
    // double as that case, same as MouseMovedTest.java's own equivalent
    // test does.
    app.dragging_started = 1; // would otherwise pass every later guard too

    assertDoesNotThrow(() -> app.mouseReleased());

    assertEquals(1, app.dragging_started, "unchanged - must return before ever resetting it");
  }

  @Test
  void whenControlIsNotUserGui_returnsImmediately () {
    app.frameCount = 100;
    app.control = app.USER_AUTO;
    app.dragging_started = 1;

    assertDoesNotThrow(() -> app.mouseReleased());

    assertEquals(1, app.dragging_started);
  }

  @Test
  void whenNoDragHasStarted_returnsImmediately () {
    app.frameCount = 100;
    app.control = app.USER_GUI;
    // dragging_started's own bare-construction default (0) is already
    // this guard's "no drag" value - left untouched here to double as
    // that case.

    assertDoesNotThrow(() -> app.mouseReleased());
  }

  @Test
  void aFullRelease_dispatchesThroughToFinishWin3DSelectionAndResetsDraggingStarted () {
    app.frameCount = 100;
    app.control = app.USER_GUI;
    app.dragging_started = 1;
    app.WIN3D.include = true;
    app.mouseX = 3; // strictly inside WIN3D's own rectangle - see FinishWin3DSelectionTest.java
    app.mouseY = 1;

    assertDoesNotThrow(() -> app.mouseReleased());

    assertEquals(0, app.dragging_started, "every successful release clears it, regardless of which branch it dispatched to");
  }
}
