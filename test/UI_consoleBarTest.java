import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// draw() touches live rendering state (fill(), text(), ...) and isn't
// unit-testable as-is (see test/README.md) - not covered here. What's
// covered instead: dispatchEditKey() (the coded Up/Down/Left/Right and
// uncoded Backspace/Delete branches, shared by keyPressed() and the
// held-key repeat) and the processHeldKey()/keyReleased() bookkeeping
// around it.
class UI_consoleBarTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= dispatchEditKey - cursor movement ========================

  @Test
  void dispatchEditKey_leftMovesCursorLeftWhenNotAtStart () {
    app.UI_consoleBar.editText = "abc";
    app.UI_consoleBar.editCursor = 2;
    app.UI_consoleBar.dispatchEditKey(true, app.LEFT, (char) 0);
    assertEquals(1, app.UI_consoleBar.editCursor);
  }

  @Test
  void dispatchEditKey_leftDoesNothingAtStart () {
    app.UI_consoleBar.editText = "abc";
    app.UI_consoleBar.editCursor = 0;
    app.UI_consoleBar.dispatchEditKey(true, app.LEFT, (char) 0);
    assertEquals(0, app.UI_consoleBar.editCursor);
  }

  @Test
  void dispatchEditKey_rightMovesCursorRightWhenNotAtEnd () {
    app.UI_consoleBar.editText = "abc";
    app.UI_consoleBar.editCursor = 1;
    app.UI_consoleBar.dispatchEditKey(true, app.RIGHT, (char) 0);
    assertEquals(2, app.UI_consoleBar.editCursor);
  }

  @Test
  void dispatchEditKey_rightDoesNothingAtEnd () {
    app.UI_consoleBar.editText = "abc";
    app.UI_consoleBar.editCursor = 3;
    app.UI_consoleBar.dispatchEditKey(true, app.RIGHT, (char) 0);
    assertEquals(3, app.UI_consoleBar.editCursor);
  }

  // ================= dispatchEditKey - command history cycling ================

  @Test
  void dispatchEditKey_upStepsBackThroughCommandHistory () {
    app.allCommands = new String[] {"Command Input:", "first", "second", ""};
    app.UI_consoleBar.cycleCursor = 3;
    app.UI_consoleBar.editText = "";

    app.UI_consoleBar.dispatchEditKey(true, app.UP, (char) 0);

    assertEquals(2, app.UI_consoleBar.cycleCursor);
    assertEquals("second", app.UI_consoleBar.editText);
    assertEquals("second".length(), app.UI_consoleBar.editCursor);
  }

  @Test
  void dispatchEditKey_upDoesNothingAtTheOldestCommand () {
    app.allCommands = new String[] {"Command Input:", "first", ""};
    app.UI_consoleBar.cycleCursor = 0;
    app.UI_consoleBar.editText = "";

    app.UI_consoleBar.dispatchEditKey(true, app.UP, (char) 0);

    assertEquals(0, app.UI_consoleBar.cycleCursor);
    assertEquals("", app.UI_consoleBar.editText);
  }

  @Test
  void dispatchEditKey_downStepsForwardThroughCommandHistory () {
    app.allCommands = new String[] {"Command Input:", "first", "second", ""};
    app.UI_consoleBar.cycleCursor = 1;
    app.UI_consoleBar.editText = "first";

    app.UI_consoleBar.dispatchEditKey(true, app.DOWN, (char) 0);

    assertEquals(2, app.UI_consoleBar.cycleCursor);
    assertEquals("second", app.UI_consoleBar.editText);
  }

  @Test
  void dispatchEditKey_downDoesNothingAtTheNewestCommand () {
    app.allCommands = new String[] {"Command Input:", "first", ""};
    app.UI_consoleBar.cycleCursor = app.allCommands.length - 1;
    app.UI_consoleBar.editText = "typing...";

    app.UI_consoleBar.dispatchEditKey(true, app.DOWN, (char) 0);

    assertEquals(app.allCommands.length - 1, app.UI_consoleBar.cycleCursor);
    assertEquals("typing...", app.UI_consoleBar.editText);
  }

  // ================= dispatchEditKey - Backspace / Delete =====================

  @Test
  void dispatchEditKey_backspaceRemovesCharacterBeforeCursor () {
    app.UI_consoleBar.editText = "abc";
    app.UI_consoleBar.editCursor = 2;
    app.UI_consoleBar.dispatchEditKey(false, 0, app.BACKSPACE);
    assertEquals("ac", app.UI_consoleBar.editText);
    assertEquals(1, app.UI_consoleBar.editCursor);
  }

  @Test
  void dispatchEditKey_backspaceDoesNothingAtStart () {
    app.UI_consoleBar.editText = "abc";
    app.UI_consoleBar.editCursor = 0;
    app.UI_consoleBar.dispatchEditKey(false, 0, app.BACKSPACE);
    assertEquals("abc", app.UI_consoleBar.editText);
  }

  @Test
  void dispatchEditKey_deleteRemovesCharacterAfterCursor () {
    app.UI_consoleBar.editText = "abc";
    app.UI_consoleBar.editCursor = 1;
    app.UI_consoleBar.dispatchEditKey(false, 0, app.DELETE);
    assertEquals("ac", app.UI_consoleBar.editText);
    assertEquals(1, app.UI_consoleBar.editCursor);
  }

  @Test
  void dispatchEditKey_deleteDoesNothingAtEnd () {
    app.UI_consoleBar.editText = "abc";
    app.UI_consoleBar.editCursor = 3;
    app.UI_consoleBar.dispatchEditKey(false, 0, app.DELETE);
    assertEquals("abc", app.UI_consoleBar.editText);
  }

  // ================= keyReleased / processHeldKey ==============================

  @Test
  void processHeldKey_doesNotFireBeforeTheInitialDelayElapses () {
    app.UI_consoleBar.navKeyHeld = true;
    app.UI_consoleBar.navKeyCoded = true;
    app.UI_consoleBar.navKeyCode = app.LEFT;
    app.UI_consoleBar.navKeyFrameCounter = 0;
    app.UI_consoleBar.navKeyRepeating = false;
    app.UI_consoleBar.editText = "abc";
    app.UI_consoleBar.editCursor = 2;

    for (int i = 0; i < app.UI_consoleBar.NAV_KEY_INITIAL_DELAY_FRAMES - 1; i++) {
      app.UI_consoleBar.processHeldKey();
    }
    assertEquals(2, app.UI_consoleBar.editCursor);

    app.UI_consoleBar.processHeldKey(); // the delay-th call - now it fires
    assertEquals(1, app.UI_consoleBar.editCursor);
    assertTrue(app.UI_consoleBar.navKeyRepeating);
  }

  @Test
  void processHeldKey_repeatsEveryFrameAfterTheInitialDelay () {
    app.UI_consoleBar.navKeyHeld = true;
    app.UI_consoleBar.navKeyCoded = true;
    app.UI_consoleBar.navKeyCode = app.LEFT;
    app.UI_consoleBar.navKeyFrameCounter = app.UI_consoleBar.NAV_KEY_INITIAL_DELAY_FRAMES - 1;
    app.UI_consoleBar.navKeyRepeating = false;
    app.UI_consoleBar.editText = "abcde";
    app.UI_consoleBar.editCursor = 4;

    app.UI_consoleBar.processHeldKey(); // crosses the initial delay - fires
    assertEquals(3, app.UI_consoleBar.editCursor);

    app.UI_consoleBar.processHeldKey(); // NAV_KEY_REPEAT_FRAMES == 1 - fires again immediately
    assertEquals(2, app.UI_consoleBar.editCursor);
  }

  @Test
  void processHeldKey_doesNothingWhenNotHeld () {
    app.UI_consoleBar.navKeyHeld = false;
    app.UI_consoleBar.navKeyCoded = false;
    app.UI_consoleBar.navKeyChar = app.BACKSPACE;
    app.UI_consoleBar.editText = "abc";
    app.UI_consoleBar.editCursor = 2;

    app.UI_consoleBar.processHeldKey();

    assertEquals("abc", app.UI_consoleBar.editText); // unchanged - not held
  }

  @Test
  void keyReleased_clearsNavKeyHeldOnlyWhenTheSameCodedKeyComesBackUp () {
    app.UI_consoleBar.navKeyHeld = true;
    app.UI_consoleBar.navKeyCoded = true;
    app.UI_consoleBar.navKeyCode = app.LEFT;

    app.key = (char) app.CODED;
    app.keyCode = app.RIGHT; // a DIFFERENT key releasing
    app.UI_consoleBar.keyReleased();
    assertTrue(app.UI_consoleBar.navKeyHeld);

    app.keyCode = app.LEFT; // the actual held key releasing
    app.UI_consoleBar.keyReleased();
    assertFalse(app.UI_consoleBar.navKeyHeld);
  }

  @Test
  void keyReleased_clearsNavKeyHeldOnlyWhenTheSameUncodedKeyComesBackUp () {
    app.UI_consoleBar.navKeyHeld = true;
    app.UI_consoleBar.navKeyCoded = false;
    app.UI_consoleBar.navKeyChar = app.BACKSPACE;

    app.key = app.DELETE; // a DIFFERENT key releasing
    app.UI_consoleBar.keyReleased();
    assertTrue(app.UI_consoleBar.navKeyHeld);

    app.key = app.BACKSPACE; // the actual held key releasing
    app.UI_consoleBar.keyReleased();
    assertFalse(app.UI_consoleBar.navKeyHeld);
  }
}
