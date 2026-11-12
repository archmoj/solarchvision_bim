import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import processing.event.KeyEvent;

// keyPressed(KeyEvent) (solarchvision_bim.pde) was at 0% coverage. Its
// entire body - Undo/Redo, the UI_menuBar/UI_rollout/STUDY/WORLD/WIN3D
// dispatch, the Esc cascade, and everything else - sits behind 3 nested
// guards: isInProgress(), "if (frameCount > Last_initializationStep)",
// and "if (control == USER_GUI)". That makes these 3 guards a safely
// bounded slice to test on their own: each one, on its own, skips the
// WHOLE rest of the function, so none of them risk touching the deeper
// per-key dispatch tables (already separately covered by WIN3DTest.java/
// WIN3DActionsTest.java for WIN3D.keyPressed() specifically) that would
// need a carefully chosen "safe" key code to avoid otherwise.
//
// X_clicked/Y_clicked are the first thing set once past all 3 guards (to
// -1/-1, unconditionally) - checked here via a sentinel value, so each
// test can tell "the guard fired" apart from "the guard passed and the
// body happened to leave X_clicked/Y_clicked alone anyway".
//
// Builds a real processing.event.KeyEvent via its own public constructor
// (nativeObject, millis, action, modifiers, key, keyCode, isAutoRepeat) -
// the same class/constructor Processing itself uses to build the event
// this method receives. Event.CTRL/ALT/SHIFT/META's own bit values (1/2/
// 4/8 - processing.event.Event's own constant-values page) aren't needed
// here since modifiers is always 0 (no keys held) in every test below.
class KeyPressedGuardsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  private KeyEvent plainKeyEvent () {
    return new KeyEvent(null, 0, KeyEvent.PRESS, 0, 'a', 65, false);
  }

  @Test
  void whenAnythingIsInProgress_theWholeBodyIsSkipped () {
    app.isShadingViewport = true; // any one of isInProgress()'s own flags would do
    app.frameCount = 100;
    app.control = app.USER_GUI;
    app.X_clicked = 999; // sentinel - must survive untouched
    app.Y_clicked = 999;

    assertDoesNotThrow(() -> app.keyPressed(plainKeyEvent()));

    assertEquals(999, app.X_clicked);
    assertEquals(999, app.Y_clicked);
  }

  @Test
  void beforeInitializationHasFinished_theWholeBodyIsSkipped () {
    // frameCount's own bare-construction default (0) is already <=
    // Last_initializationStep's default (25) - left untouched here to
    // double as that case, same reasoning as the mouseReleased()/
    // mouseDragged()/mouseWheel() dispatch tests use.
    app.control = app.USER_GUI;
    app.X_clicked = 999;
    app.Y_clicked = 999;

    assertDoesNotThrow(() -> app.keyPressed(plainKeyEvent()));

    assertEquals(999, app.X_clicked);
    assertEquals(999, app.Y_clicked);
  }

  @Test
  void whenControlIsNotUserGui_theWholeBodyIsSkipped () {
    app.frameCount = 100;
    app.control = app.USER_AUTO;
    app.X_clicked = 999;
    app.Y_clicked = 999;

    assertDoesNotThrow(() -> app.keyPressed(plainKeyEvent()));

    assertEquals(999, app.X_clicked);
    assertEquals(999, app.Y_clicked);
  }
}
