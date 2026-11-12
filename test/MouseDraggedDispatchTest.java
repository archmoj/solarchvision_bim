import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// mouseDragged() has 3 of its own early-return guards - isInProgress()
// (the same real data-race guard mouseClicked() uses, per its own
// comment), frameCount vs Last_initializationStep, and control !=
// USER_GUI - then either a FRAME_drag_IMG short-circuit straight to
// startFrameDragIfNeeded(), or (when picker-scrollbar dragging doesn't
// claim the gesture first) a WIN3D.include/WORLD.include pair, NOT
// mutually exclusive by design (its own comment: a drag can reach both
// handleWin3DDrag() and handleWorldDrag() in the same call). All of this
// was at 0% coverage on mouseDragged() itself, even though every
// function it calls was already separately covered by
// MouseDraggedTest.java's own direct calls - reused here with the exact
// same WIN3D geometry/mouse setup its own
// handleWin3DDrag_beginsTheDragAndDispatchesOnceInsideOnBothEnds test uses.
class MouseDraggedDispatchTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see MouseDraggedTest.java's own setUp comment
    app.build_allActions();
  }

  @Test
  void whenAnythingIsInProgress_returnsImmediately () {
    app.isShadingViewport = true; // any one of isInProgress()'s own flags would do
    app.frameCount = 100;
    app.control = app.USER_GUI;
    app.dragging_started = 0;
    app.pmouseX = 100;
    app.pmouseY = 100;

    assertDoesNotThrow(() -> app.mouseDragged());

    assertEquals(0, app.dragging_started, "unchanged - must return before even checking FRAME_drag_IMG");
  }

  @Test
  void beforeInitializationHasFinished_returnsImmediately () {
    // frameCount's own bare-construction default (0) is already <=
    // Last_initializationStep's default (25) - left untouched here to
    // double as that case, same reasoning as MouseReleasedDispatchTest.java's
    // own equivalent test.
    app.control = app.USER_GUI;
    app.dragging_started = 0;

    assertDoesNotThrow(() -> app.mouseDragged());

    assertEquals(0, app.dragging_started);
  }

  @Test
  void whenControlIsNotUserGui_returnsImmediately () {
    app.frameCount = 100;
    app.control = app.USER_AUTO;
    app.dragging_started = 0;

    assertDoesNotThrow(() -> app.mouseDragged());

    assertEquals(0, app.dragging_started);
  }

  @Test
  void whenFrameDragImgIsActive_dispatchesOnlyToStartFrameDragIfNeeded () {
    app.frameCount = 100;
    app.control = app.USER_GUI;
    app.FRAME_drag_IMG = true;
    app.dragging_started = 0;
    app.pmouseX = 111;
    app.pmouseY = 222;
    // WIN3D/WORLD setup deliberately left at bare defaults - if this
    // branch failed to short-circuit and fell through to them too,
    // that's exactly what the assertions below would also happen to be
    // consistent with, so the real proof here is X_click1/Y_click1:
    // startFrameDragIfNeeded() is the only path that sets them from
    // pmouseX/pmouseY (mouseDragged.pde's own comment on it).

    assertDoesNotThrow(() -> app.mouseDragged());

    assertEquals(1, app.dragging_started);
    assertEquals(111, app.X_click1);
    assertEquals(222, app.Y_click1);
  }

  @Test
  void aFullDragOverWIN3D_dispatchesThroughToHandleWin3DDrag () {
    app.frameCount = 100;
    app.control = app.USER_GUI;
    app.FRAME_drag_IMG = false;
    app.WIN3D.include = true;
    app.WIN3D.cX = 0;
    app.WIN3D.cY = 0;
    app.WIN3D.dX = 400;
    app.WIN3D.dY = 300;
    app.pmouseX = 100;
    app.pmouseY = 100;
    app.mouseX = 140; // moved +40px right - see MouseDraggedTest.java's own identical setup
    app.mouseY = 100;
    app.dragging_started = 0;
    app.WORLD.include = false; // keep this test isolated to the WIN3D branch

    assertDoesNotThrow(() -> app.mouseDragged());

    assertEquals(1, app.dragging_started, "handleWin3DDrag() must have been reached and begun the drag");
  }
}
