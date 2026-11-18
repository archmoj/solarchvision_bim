import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import processing.event.KeyEvent;
import processing.event.Event;

// Covers this session's Alt+<letter> menu-bar shortcuts: openParentMenu(String),
// openParentMenuByKeyCode(int), mnemonicIndexIn(String), the PARENT_SHORTCUTS
// table itself (uiMenuBar.pde), the "^<Parent>" command actions it drives
// (actions.pde's build_allActions()), and the altHeld tracking wired into
// solarchvision_bim.pde's keyPressed(KeyEvent)/keyReleased().
//
// openParentMenu() calls Processing's get() (a real graphics call) only when
// opening from a fully-closed menu (selected_parent == -1) - confirmed
// empirically to throw a NullPointerException against this harness's
// uninitialized graphics context (this.g is null), the same category of
// untestable-as-written call ClearHoverTest.java/PlaceHoversAtTest.java
// already work around. Every test below that can reach openParentMenu()
// (directly, via openParentMenuByKeyCode(), or via a "^<Parent>" action)
// therefore starts from an already-open parent, never from closed.
//
// draw()/drawParentTab() themselves (the mnemonic-letter highlighting) touch
// live rendering and aren't covered here either, per UI_menuBarTest.java's
// own header comment.
class UIMenuBarShortcutsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  private int indexOf (String parentName) {
    for (int i = 0; i < app.UI_menuBar.Items.length; i++) {
      if (app.UI_menuBar.Items[i][0].equals(parentName)) return i;
    }
    throw new IllegalStateException("parent not found: " + parentName);
  }

  // ================= openParentMenu =======================================

  @Test
  void openParentMenu_switchesToAnotherAlreadyOpenParentAndRevises () {
    app.UI_menuBar.selected_parent = indexOf("File"); // already open - no get() call
    app.UI_menuBar.selected_child = 3;
    app.UI_menuBar.updated();

    assertDoesNotThrow(() -> app.UI_menuBar.openParentMenu("Edit"));

    assertEquals(indexOf("Edit"), app.UI_menuBar.selected_parent);
    assertEquals(0, app.UI_menuBar.selected_child); // reset
    assertTrue(app.UI_menuBar.update); // revise() fired
  }

  @Test
  void openParentMenu_unknownParentNameIsANoOp () {
    app.UI_menuBar.selected_parent = indexOf("File");
    app.UI_menuBar.selected_child = 2;
    app.UI_menuBar.updated();

    app.UI_menuBar.openParentMenu("Nonexistent Parent");

    assertEquals(indexOf("File"), app.UI_menuBar.selected_parent); // unchanged
    assertEquals(2, app.UI_menuBar.selected_child); // unchanged
    assertFalse(app.UI_menuBar.update); // revise() never called
  }

  @Test
  void openParentMenu_reopeningTheSameAlreadyOpenParentResetsSelectedChild () {
    app.UI_menuBar.selected_parent = indexOf("Edit");
    app.UI_menuBar.selected_child = 2;

    app.UI_menuBar.openParentMenu("Edit");

    assertEquals(indexOf("Edit"), app.UI_menuBar.selected_parent);
    assertEquals(0, app.UI_menuBar.selected_child);
  }

  // ================= openParentMenuByKeyCode ==============================

  @Test
  void openParentMenuByKeyCode_opensTheMatchingParentForARegisteredLetter () {
    app.UI_menuBar.selected_parent = indexOf("File"); // already open - no get() call
    boolean found = app.UI_menuBar.openParentMenuByKeyCode((int) 'S'); // "Select"
    assertTrue(found);
    assertEquals(indexOf("Select"), app.UI_menuBar.selected_parent);
  }

  @Test
  void openParentMenuByKeyCode_unmappedKeyCodeReturnsFalseAndLeavesStateUnchanged () {
    app.UI_menuBar.selected_parent = indexOf("File");
    app.UI_menuBar.selected_child = 1;

    boolean found = app.UI_menuBar.openParentMenuByKeyCode((int) 'Z'); // not a registered shortcut letter

    assertFalse(found);
    assertEquals(indexOf("File"), app.UI_menuBar.selected_parent);
    assertEquals(1, app.UI_menuBar.selected_child);
  }

  @Test
  void openParentMenuByKeyCode_matchedLetterWhoseParentIsMissingFromItemsStillReturnsTrue () {
    // PARENT_SHORTCUTS is a fixed table, independent of whatever Items
    // currently holds - a letter match alone is enough for
    // openParentMenuByKeyCode() to report "consumed", even though
    // openParentMenu() itself silently no-ops when the name isn't found.
    app.UI_menuBar.Items = new String[][] { {"File", "New", "Open"} };
    app.UI_menuBar.selected_parent = 0;
    app.UI_menuBar.selected_child = 1;

    boolean found = app.UI_menuBar.openParentMenuByKeyCode((int) 'S'); // "Select" - not in this fixture

    assertTrue(found);
    assertEquals(0, app.UI_menuBar.selected_parent); // unchanged - "Select" wasn't found
    assertEquals(1, app.UI_menuBar.selected_child);
  }

  // ================= mnemonicIndexIn ======================================

  @Test
  void mnemonicIndexIn_firstLetterCase () {
    assertEquals(0, app.UI_menuBar.mnemonicIndexIn("Select")); // "S" is Select's own first letter
  }

  @Test
  void mnemonicIndexIn_nonFirstLetterCases () {
    assertEquals(2, app.UI_menuBar.mnemonicIndexIn("Layer")); // L-A-Y-E-R: "L" went to Location, Layer got "Y"
    assertEquals(1, app.UI_menuBar.mnemonicIndexIn("Shade")); // S-H-A-D-E: "S" went to Select, Shade got "H"
  }

  @Test
  void mnemonicIndexIn_midWordLetter () {
    assertEquals(6, app.UI_menuBar.mnemonicIndexIn("Selection")); // S-E-L-E-C-T-I-O-N: "I" at index 6
  }

  @Test
  void mnemonicIndexIn_returnsMinusOneForAnUnregisteredName () {
    assertEquals(-1, app.UI_menuBar.mnemonicIndexIn("Nonexistent Parent"));
  }

  // ================= PARENT_SHORTCUTS self-consistency ====================

  @Test
  void parentShortcuts_hasExactlyTwentyEntries () {
    // 19 + "G" for the new "Guide" menu (uiKeyboardMap.pde's own
    // UIKeyboardMapTest.java covers that one specifically).
    assertEquals(20, app.UI_menuBar.PARENT_SHORTCUTS.length);
  }

  @Test
  void parentShortcuts_everyLetterIsUnique () {
    java.util.Set<String> letters = new java.util.HashSet<>();
    for (String[] entry : app.UI_menuBar.PARENT_SHORTCUTS) {
      assertTrue(letters.add(entry[0]), "duplicate shortcut letter: " + entry[0]);
    }
  }

  @Test
  void parentShortcuts_everyLetterActuallyAppearsInItsOwnParentName () {
    for (String[] entry : app.UI_menuBar.PARENT_SHORTCUTS) {
      String letter = entry[0];
      String parentName = entry[1];
      assertTrue(
        parentName.toUpperCase().contains(letter),
        "\"" + letter + "\" is not a letter in \"" + parentName + "\""
      );
    }
  }

  @Test
  void parentShortcuts_everyParentNameHasARealEntryInTheLiveMenu () {
    // PARENT_SHORTCUTS and buildMenuItems() both derive from the same
    // PARENT_* constants, but this guards against the two ever drifting
    // apart (e.g. a parent renamed in one place and not the other).
    for (String[] entry : app.UI_menuBar.PARENT_SHORTCUTS) {
      assertDoesNotThrow(() -> indexOf(entry[1]));
    }
  }

  // ================= "^<Parent>" command actions (actions.pde) ============

  @Test
  void parentActions_areRegisteredForEveryMenuParent () {
    app.allActions = new java.util.HashMap<>();
    app.build_allActions();

    for (String[] menu : app.UI_menuBar.Items) {
      String key = "^" + menu[0].toLowerCase().replace(' ', '_');
      assertTrue(app.allActions.containsKey(key), "missing action for " + key);
    }
  }

  @Test
  void parentActions_runningOneOpensTheRightParent () {
    app.allActions = new java.util.HashMap<>();
    app.build_allActions();
    app.UI_menuBar.selected_parent = indexOf("File"); // already open - avoids openParentMenu()'s get() call

    app.callAction("^select");

    assertEquals(indexOf("Select"), app.UI_menuBar.selected_parent);
  }

  // ================= altHeld tracking (keyPressed/keyReleased) ============

  @Test
  void altHeld_becomesTrueOnAnAltKeypressAndRevisesTheMenuBar () {
    app.control = app.USER_GUI;
    app.frameCount = 100;
    app.UI_menuBar.updated();

    app.keyPressed(new KeyEvent(null, 0, KeyEvent.PRESS, Event.ALT, (char) 0, app.ALT, false));

    assertTrue(app.UI_menuBar.altHeld);
    assertTrue(app.UI_menuBar.update);
  }

  @Test
  void altHeld_doesNotReviseAgainOnASecondAltKeypressWithNoChange () {
    app.control = app.USER_GUI;
    app.frameCount = 100;
    app.UI_menuBar.altHeld = true;
    app.UI_menuBar.updated();

    app.keyPressed(new KeyEvent(null, 0, KeyEvent.PRESS, Event.ALT, (char) 0, app.ALT, false));

    assertTrue(app.UI_menuBar.altHeld);
    assertFalse(app.UI_menuBar.update); // no change - revise() must not fire again
  }

  @Test
  void altFLetterKeypress_opensFileWithoutOrdinaryFHandlingInterfering () {
    app.control = app.USER_GUI;
    app.frameCount = 100;
    app.UI_menuBar.selected_parent = indexOf("Edit"); // already open - avoids get()

    app.keyPressed(new KeyEvent(null, 0, KeyEvent.PRESS, Event.ALT, 'f', (int) 'F', false));

    assertEquals(indexOf("File"), app.UI_menuBar.selected_parent);
  }

  @Test
  void altFLetterKeypress_stillOpensTheMenuWhileTheConsoleBarIsActiveForTyping () {
    // Regression test: the mnemonic-letter highlight (altHeld) already lit
    // up while a command was being typed (typeUserCommand == 1), but the
    // shortcut itself used to be gated on typeUserCommand == 0 and so
    // silently did nothing - Alt+<letter> must actually open the menu
    // here too, not just highlight the letter.
    app.control = app.USER_GUI;
    app.frameCount = 100;
    app.typeUserCommand = 1; // console bar is active, mid-typed-command
    app.UI_consoleBar.editText = "some partial command";
    app.UI_menuBar.selected_parent = indexOf("Edit"); // already open - avoids get()

    app.keyPressed(new KeyEvent(null, 0, KeyEvent.PRESS, Event.ALT, 'f', (int) 'F', false));

    assertEquals(indexOf("File"), app.UI_menuBar.selected_parent);
    // and it must not have leaked an 'f' character into the command line
    assertEquals("some partial command", app.UI_consoleBar.editText);
  }

  @Test
  void keyReleased_clearsAltHeldWhenAltComesUp () {
    app.UI_menuBar.altHeld = true;
    app.UI_menuBar.updated();

    app.key = (char) app.CODED;
    app.keyCode = app.ALT;
    app.keyReleased();

    assertFalse(app.UI_menuBar.altHeld);
    assertTrue(app.UI_menuBar.update);
  }

  @Test
  void keyReleased_releasingControlDoesNotTouchAltHeld () {
    app.UI_menuBar.altHeld = true;
    app.UI_menuBar.updated();

    app.key = (char) app.CODED;
    app.keyCode = app.CONTROL;
    app.keyReleased();

    assertTrue(app.UI_menuBar.altHeld); // CONTROL release is a different branch - must not clear it
  }
}
