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

  // ======================= Esc-abort cascade (new this session) ==========
  // Inside the isInProgress() guard above, keyPressed() does two more
  // things before returning (solarchvision_bim.pde): (1) if the key IS
  // Esc and activeProgressWindow (progressWindow.pde) is non-null, set
  // its abortRequested flag; (2) if the key IS Esc at all - window or no
  // window - zero out `key` so PApplet's own post-keyPressed() default
  // behavior (quit the whole sketch on Esc) can't fire out from under a
  // still-running action. Neither of those was covered by the 3 guard
  // tests above, which only ever exercise the "skip the whole body"
  // paths.
  //
  // `key` is a plain PApplet field, not something a direct, synthetic
  // call to keyPressed(e) populates on its own (that only happens via
  // PApplet's real handleKeyEvent() dispatch, which these tests
  // deliberately bypass - same reasoning as the KeyEvent-construction
  // comment at the top of this file) - so each test below sets app.key
  // itself, exactly as it would be set immediately before a real
  // keyPressed() call.

  @Test
  void escWhileInProgress_zeroesKeyEvenWithNoActiveWindow () {
    app.isShadingViewport = true; // isInProgress() == true
    app.key = app.ESC;
    app.activeProgressWindow = null; // nothing to abort - must not throw

    assertDoesNotThrow(() -> app.keyPressed(plainKeyEvent()));

    assertEquals(0, app.key, "Esc must still be zeroed so PApplet's own quit-on-Esc default can't fire");
  }

  @Test
  void nonEscKeyWhileInProgress_leavesKeyUntouched () {
    app.isShadingViewport = true;
    app.key = 'a';
    app.activeProgressWindow = null;

    assertDoesNotThrow(() -> app.keyPressed(plainKeyEvent()));

    assertEquals('a', app.key, "only Esc is special-cased here - any other key must be left alone");
  }

  @Test
  void escWhileInProgress_withNoActiveWindow_doesNotThrow () {
    // Esc is the common case where no action happens to be showing a
    // ProgressWindow at all (canShowProgressWindow() == false, or the
    // action simply hasn't reached setVisible(true) yet) - must be a
    // total no-op on the abort side, not a NullPointerException.
    app.isShadingViewport = true;
    app.key = app.ESC;
    app.activeProgressWindow = null;

    assertDoesNotThrow(() -> app.keyPressed(plainKeyEvent()));
  }

  @Test
  void escWhileInProgress_withRealActiveWindow_setsAbortRequested () {
    if (java.awt.GraphicsEnvironment.isHeadless()) return; // needs a real display - see ProgressWindowTest.java's own comment

    app.isShadingViewport = true;
    app.key = app.ESC;
    solarchvision_bim.ProgressWindow win = app.new ProgressWindow("Test");
    app.activeProgressWindow = win;

    try {
      assertDoesNotThrow(() -> app.keyPressed(plainKeyEvent()));
      assertTrue(win.abortRequested);
    } finally {
      win.dispose();
    }
  }

  @Test
  void nonEscKeyWhileInProgress_withRealActiveWindow_doesNotSetAbortRequested () {
    if (java.awt.GraphicsEnvironment.isHeadless()) return;

    app.isShadingViewport = true;
    app.key = 'a';
    solarchvision_bim.ProgressWindow win = app.new ProgressWindow("Test");
    app.activeProgressWindow = win;

    try {
      assertDoesNotThrow(() -> app.keyPressed(plainKeyEvent()));
      assertFalse(win.abortRequested);
    } finally {
      win.dispose();
    }
  }

  // ================= isMouseGuideOpenChord() ==================================
  // Split out of keyPressed()'s own Ctrl+? condition (solarchvision_bim.pde)
  // purely so this chord-matching logic is testable on its own - going
  // through keyPressed() itself would need either an already-open
  // UI_mouseGuide (which sidesteps this exact check via its own close-
  // on-any-key branch - see UIMouseGuideTest.java) or a real show() call
  // that touches real graphics. Pure logic, no Processing graphics calls.

  @Test
  void isMouseGuideOpenChord_matchesCtrlQuestionMark () {
    assertTrue(app.isMouseGuideOpenChord('?', true, false, false));
  }

  @Test
  void isMouseGuideOpenChord_matchesCtrlShiftSlashFallback () {
    // The platform-quirk fallback: Ctrl can suppress Shift+/'s own
    // shifted-character translation on some platforms, reporting the
    // bare '/' even though Shift is genuinely held.
    assertTrue(app.isMouseGuideOpenChord('/', true, false, true));
  }

  @Test
  void isMouseGuideOpenChord_requiresControl () {
    assertFalse(app.isMouseGuideOpenChord('?', false, false, false));
  }

  @Test
  void isMouseGuideOpenChord_bareSlashWithoutShift_doesNotMatch () {
    // Ctrl+/ alone (no Shift) is a different, unclaimed chord - must not
    // be swallowed by the mouse guide's own '/' fallback.
    assertFalse(app.isMouseGuideOpenChord('/', true, false, false));
  }

  @Test
  void isMouseGuideOpenChord_altDown_doesNotMatch () {
    assertFalse(app.isMouseGuideOpenChord('?', true, true, false));
  }
}
