import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// mouseMoved() - Processing's own per-frame callback, previously
// untested - only ever does anything when a menu is currently open
// (UI_menuBar.selected_parent != -1) and the mouse has actually moved
// since last recorded: it updates UI_X_moved/UI_Y_moved, flags
// UI_menuBar for a redraw, and calls Processing's own redraw() -
// confirmed directly to be headlessly safe (no WIN3D.graphics
// dependency) before writing these assertions.
//
// Shares the exact same frameCount/Last_initializationStep gate as
// mouseDragged()/mouseReleased() (mouseDragged.pde's/mouseReleased.pde's
// own leading "if (frameCount <= Last_initializationStep) return;") -
// frameCount defaults to 0 on a bare instance (Processing's own PApplet
// field, never advanced without a real running sketch), well below
// Last_initializationStep's own default of 25, so every test here that
// wants past that gate sets frameCount explicitly, the same way
// UndoRedoStationTest.java's own frameCount-simulating tests already do.
class MouseMovedTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void belowTheInitializationGate_isACompleteNoOp () {
    app.frameCount = 0; // below Last_initializationStep's own default of 25
    app.UI_menuBar.selected_parent = 0; // a menu IS open - would otherwise matter
    app.UI_X_moved = -1;
    app.UI_Y_moved = -1;
    app.mouseX = 50;
    app.mouseY = 60;

    assertDoesNotThrow(() -> app.mouseMoved());

    assertEquals(-1, app.UI_X_moved);
    assertEquals(-1, app.UI_Y_moved);
  }

  @Test
  void pastTheGate_withNoMenuOpen_isStillANoOp () {
    app.frameCount = 100;
    app.UI_menuBar.selected_parent = -1; // no menu currently open
    app.UI_X_moved = -1;
    app.UI_Y_moved = -1;
    app.mouseX = 50;
    app.mouseY = 60;

    app.mouseMoved();

    assertEquals(-1, app.UI_X_moved);
    assertEquals(-1, app.UI_Y_moved);
  }

  @Test
  void withAMenuOpenAndTheMouseActuallyMoved_updatesTheRecordedPosition_andFlagsTheMenuBar () {
    app.frameCount = 100;
    app.UI_menuBar.selected_parent = 0;
    app.UI_X_moved = -1;
    app.UI_Y_moved = -1;
    app.mouseX = 123;
    app.mouseY = 456;
    app.UI_menuBar.update = false;

    app.mouseMoved();

    assertEquals(123, app.UI_X_moved);
    assertEquals(456, app.UI_Y_moved);
    assertTrue(app.UI_menuBar.update, "UI_menuBar.revise() should have run");
  }

  @Test
  void withAMenuOpen_butTheMouseAtTheSameRecordedPosition_doesNothing () {
    app.frameCount = 100;
    app.UI_menuBar.selected_parent = 0;
    app.UI_X_moved = 123;
    app.UI_Y_moved = 456;
    app.mouseX = 123;
    app.mouseY = 456;
    app.UI_menuBar.update = false;

    app.mouseMoved();

    assertFalse(app.UI_menuBar.update, "nothing to redraw - the mouse hasn't actually moved from its last recorded position");
  }

  @Test
  void whenControlIsNotUserGui_isANoOp_evenPastTheGateWithAMenuOpen () {
    app.frameCount = 100;
    app.control = app.USER_AUTO;
    app.UI_menuBar.selected_parent = 0;
    app.UI_X_moved = -1;
    app.UI_Y_moved = -1;
    app.mouseX = 999;
    app.mouseY = 999;

    app.mouseMoved();

    assertEquals(-1, app.UI_X_moved);
    assertEquals(-1, app.UI_Y_moved);
  }
}
