import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// draw() and keyPressed(KeyEvent) touch live rendering/mouse state and, for
// keyPressed(), the event's isControlDown()/isAltDown() right after the
// frameCount/control guards, so they aren't unit-testable headless as-is
// (see test/README.md - no test in this suite constructs a KeyEvent).
// What's covered instead: the global, no-arg keyReleased() - both its own
// Ctrl/Alt "restore the previous addNewSelectionToPreviousSelection"
// bookkeeping, and that it actually reaches every sub-object's own
// keyReleased() (UI_menuBar / UI_consoleBar / UI_rollout / WIN3D), each of
// which is exercised in more detail in its own dedicated test file.
class solarchvision_bimTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= keyReleased - addNewSelectionToPreviousSelection ======

  @Test
  void keyReleased_restoresThePreviousFlagWhenControlIsReleased () {
    app.addNewSelectionToPreviousSelection = 1; // as if Ctrl was still held
    app.addNewSelectionToPreviousSelection_beforeModifierKey = -1; // what it was before Ctrl
    app.addNewSelectionToPreviousSelection_isOverridden = true;

    app.key = (char) app.CODED;
    app.keyCode = app.CONTROL;
    app.keyReleased();

    assertEquals(-1, app.addNewSelectionToPreviousSelection);
    assertFalse(app.addNewSelectionToPreviousSelection_isOverridden);
  }

  @Test
  void keyReleased_restoresThePreviousFlagWhenAltIsReleased () {
    app.addNewSelectionToPreviousSelection = -1; // as if Alt was still held
    app.addNewSelectionToPreviousSelection_beforeModifierKey = 1; // what it was before Alt
    app.addNewSelectionToPreviousSelection_isOverridden = true;

    app.key = (char) app.CODED;
    app.keyCode = app.ALT;
    app.keyReleased();

    assertEquals(1, app.addNewSelectionToPreviousSelection);
    assertFalse(app.addNewSelectionToPreviousSelection_isOverridden);
  }

  @Test
  void keyReleased_resetsTheFlagToZeroForAnyOtherKeyRelease () {
    app.addNewSelectionToPreviousSelection = 1;
    app.addNewSelectionToPreviousSelection_isOverridden = true;

    app.key = 'a'; // not CODED at all, e.g. a letter key going up
    app.keyReleased();

    assertEquals(0, app.addNewSelectionToPreviousSelection);
  }

  @Test
  void keyReleased_resetsTheFlagForAnyOtherCodedKeyRelease () {
    app.addNewSelectionToPreviousSelection = 1;

    app.key = (char) app.CODED;
    app.keyCode = app.DOWN; // coded, but neither CONTROL nor ALT
    app.keyReleased();

    assertEquals(0, app.addNewSelectionToPreviousSelection);
  }

  // ================= keyReleased - routes to every sub-object ==============

  @Test
  void keyReleased_alsoClearsUI_menuBarsHeldArrowKey () {
    app.UI_menuBar.navKeyHeld = true;
    app.UI_menuBar.navKeyCode = app.DOWN;

    app.key = (char) app.CODED;
    app.keyCode = app.DOWN;
    app.keyReleased();

    assertFalse(app.UI_menuBar.navKeyHeld);
  }

  @Test
  void keyReleased_alsoClearsUI_consoleBarsHeldBackspace () {
    app.UI_consoleBar.navKeyHeld = true;
    app.UI_consoleBar.navKeyCoded = false;
    app.UI_consoleBar.navKeyChar = app.BACKSPACE;

    app.key = app.BACKSPACE;
    app.keyReleased();

    assertFalse(app.UI_consoleBar.navKeyHeld);
  }

  @Test
  void keyReleased_alsoClearsUI_rolloutsHeldDelete () {
    app.UI_rollout.navKeyHeld = true;
    app.UI_rollout.navKeyCoded = false;
    app.UI_rollout.navKeyChar = app.DELETE;

    app.key = app.DELETE;
    app.keyReleased();

    assertFalse(app.UI_rollout.navKeyHeld);
  }

  @Test
  void keyReleased_alsoClearsWIN3DsHeldCommandKey () {
    app.WIN3D.navKeyHeld = true;
    app.WIN3D.navKeyCoded = false;
    app.WIN3D.navKeyChar = '1';

    app.key = '1';
    app.keyReleased();

    assertFalse(app.WIN3D.navKeyHeld);
  }

  @Test
  void keyReleased_onlyClearsTheSubObjectHoldingTheReleasedKeyNotTheOthers () {
    // Four different keys held at once, each by a different sub-object -
    // releasing one must not disturb the other three.
    app.UI_menuBar.navKeyHeld = true;
    app.UI_menuBar.navKeyCode = app.DOWN;

    app.UI_consoleBar.navKeyHeld = true;
    app.UI_consoleBar.navKeyCoded = true;
    app.UI_consoleBar.navKeyCode = app.LEFT;

    app.UI_rollout.navKeyHeld = true;
    app.UI_rollout.navKeyCoded = false;
    app.UI_rollout.navKeyChar = app.BACKSPACE;

    app.WIN3D.navKeyHeld = true;
    app.WIN3D.navKeyCoded = false;
    app.WIN3D.navKeyChar = '1';

    // Release the console bar's Left - the only one of the four this matches.
    app.key = (char) app.CODED;
    app.keyCode = app.LEFT;
    app.keyReleased();

    assertTrue(app.UI_menuBar.navKeyHeld);   // held Down, not Left - untouched
    assertFalse(app.UI_consoleBar.navKeyHeld); // held Left, coded - cleared
    assertTrue(app.UI_rollout.navKeyHeld);   // held Backspace, uncoded - untouched
    assertTrue(app.WIN3D.navKeyHeld);        // held '1', uncoded - untouched
  }

  @Test
  void keyReleased_isSafeToCallAgainOnceAlreadyCleared () {
    app.UI_menuBar.navKeyHeld = true;
    app.UI_menuBar.navKeyCode = app.DOWN;

    app.key = (char) app.CODED;
    app.keyCode = app.DOWN;

    app.keyReleased(); // clears it
    assertFalse(app.UI_menuBar.navKeyHeld);

    assertDoesNotThrow(() -> app.keyReleased()); // calling it again is a no-op, not an error
    assertFalse(app.UI_menuBar.navKeyHeld);
  }
}
