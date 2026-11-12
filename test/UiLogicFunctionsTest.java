import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import processing.event.KeyEvent;

// A second pass past ToolbarHelperTest.java's own toggleHelper()/
// dismissHelper() - searching the merged report more broadly (not just
// functions literally named draw*) turned up several more UI functions
// that are pure logic with no drawing at all, previously missed because
// their names didn't suggest it:
//
// - UI_toolBar.advanceSelection() - cycles a toolbar item's selected
//   option, wrapping at both ends. No drawing anywhere in it.
// - UI_menuBar.keyPressed()/UI_rollout.keyPressed() - both reached only
//   indirectly before (KeyPressedGuardsTest.java's own investigation
//   already confirmed UI_menuBar.keyPressed() returns false immediately
//   on a bare app, as part of understanding the top-level keyPressed()'s
//   own guards - but never called directly, so it stayed at 0%
//   regardless). UI_rollout.keyPressed() has the identical shape: an
//   "if (!this.editActive) return;" guard at the very top, false by its
//   own bare-construction default.
// - UI_consoleBar.keyPressed()/runCurrentCommand() - pure text-editing/
//   command-dispatch logic (this.editText/this.allCommands), each
//   deliberately avoiding its own one real risk: keyPressed()'s Ctrl+V
//   branch hits the live system clipboard (getClipboardText() - already
//   documented elsewhere in this suite as not unit-testable as-is), and
//   runCurrentCommand()'s own empty-input branch reaches drawEmptyDirective()
//   -> drawDirective(), already confirmed safe by its own "if (g == null)
//   return;" guard (ConsolePrintHelpersTest.java's own established
//   pattern) rather than needing to be avoided.
class UiLogicFunctionsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= UI_toolBar.advanceSelection ==============================
  // Item 0 (Items[0]): {"11","Top","Front","Left","Back","Right",
  // "Bottom","S.W.","S.E.","N.E.","N.W.","Cam00","View Point","2.0"} -
  // length 14, so lastOptionIndex = 14-3 = 11 (the "N.W." slot, position
  // 11) and the wrap-forward ceiling is Items[0].length-2 = 12.

  @Test
  void advanceSelection_onADifferentItem_justFocusesIt_leavingJUnchanged () {
    // Selection's own bare-construction default (-1) is already != 0.
    int result = app.UI_toolBar.advanceSelection(0, 5, 1);

    assertEquals(5, result);
    assertEquals(0, app.UI_toolBar.Selection);
  }

  @Test
  void advanceSelection_onTheSameItem_stepsForwardByOne_noWrap () {
    app.UI_toolBar.advanceSelection(0, 5, 1); // focuses item 0 first

    int result = app.UI_toolBar.advanceSelection(0, 5, 1);

    assertEquals(6, result);
    assertEquals("6", app.UI_toolBar.Items[0][0]);
  }

  @Test
  void advanceSelection_wrapsForwardPastTheLastOption_backToOne () {
    app.UI_toolBar.advanceSelection(0, 11, 1); // focuses item 0

    int result = app.UI_toolBar.advanceSelection(0, 11, 1); // 11+1=12 >= 12 -> wraps

    assertEquals(1, result);
  }

  @Test
  void advanceSelection_wrapsBackwardPastTheFirstOption_toTheLastOptionIndex () {
    app.UI_toolBar.advanceSelection(0, 1, -1); // focuses item 0

    int result = app.UI_toolBar.advanceSelection(0, 1, -1); // 1-1=0 <= 0 -> wraps

    assertEquals(11, result); // lastOptionIndex = Items[0].length - 3 = 11
  }

  // ================= UI_menuBar.keyPressed =====================================

  @Test
  void uiMenuBar_keyPressed_onABareApp_returnsFalse () {
    assertFalse(app.UI_menuBar.keyPressed(plainKeyEvent('a', 65)));
  }

  // ================= UI_rollout.keyPressed =====================================

  @Test
  void uiRollout_keyPressed_whenNoSpinnerIsBeingEdited_doesNothing () {
    // editActive's own bare-construction default (false).
    app.UI_rollout.editText = "sentinel";

    assertDoesNotThrow(() -> app.UI_rollout.keyPressed(plainKeyEvent('a', 65)));

    assertEquals("sentinel", app.UI_rollout.editText, "unchanged - the guard must return before touching anything");
  }

  @Test
  void uiRollout_keyPressed_escWhileEditing_cancelsTheEdit () {
    app.UI_rollout.editActive = true;
    app.UI_rollout.editCaption = "some caption";
    app.UI_rollout.editText = "some typed text";
    app.UI_rollout.editCursor = 5;
    app.key = app.ESC;
    app.keyCode = 0;

    app.UI_rollout.keyPressed(plainKeyEvent(app.ESC, 0));

    assertFalse(app.UI_rollout.editActive);
    assertEquals("", app.UI_rollout.editCaption);
    assertEquals("", app.UI_rollout.editText);
    assertEquals(0, app.UI_rollout.editCursor);
  }

  // ================= UI_consoleBar.keyPressed ==================================

  @Test
  void uiConsoleBar_keyPressed_aPlainCharacter_appendsItToEditText () {
    app.UI_consoleBar.editText = "";
    app.key = 'a';
    app.keyCode = 0;

    app.UI_consoleBar.keyPressed(plainKeyEvent('a', 0));

    assertEquals("a", app.UI_consoleBar.editText);
  }

  // ================= UI_consoleBar.runCurrentCommand ===========================

  @Test
  void runCurrentCommand_withNoTextTyped_doesNotThrow () {
    // allCommands' own bare-construction default ends in "" (nothing
    // typed yet) - reaches drawEmptyDirective() -> drawDirective(),
    // already safe (its own "g == null" guard).
    assertDoesNotThrow(() -> app.UI_consoleBar.runCurrentCommand());
  }

  @Test
  void runCurrentCommand_withARealCommandTyped_runsItAndResetsTheEditor () {
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
    app.vm.cameraClipNear(0); // registers "Camera Clip Near" - see ValueModifierTest.java's own test of this exact command
    app.UI_consoleBar.editText = "Camera Clip Near 5.5";
    app.UI_consoleBar.editCursor = app.UI_consoleBar.editText.length();

    String hint = app.UI_consoleBar.runCurrentCommand();

    assertEquals(5.5f, app.WIN3D.cameraClipNear, 0.0001f, "the typed command must have actually run");
    assertEquals("", app.UI_consoleBar.editText, "the editor must reset after running");
    assertEquals(0, app.UI_consoleBar.editCursor);
    assertNotEquals(app.UnrecognizedCommand, hint);
  }

  // ================= shared helper ============================================

  private KeyEvent plainKeyEvent (char keyChar, int code) {
    return new KeyEvent(null, 0, KeyEvent.PRESS, 0, keyChar, code, false);
  }
}
