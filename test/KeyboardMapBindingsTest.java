import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.util.ArrayList;

// Covers keyboardMapBindings.pde's own data layer - the single source of
// truth UI_keyboardMap.pde's hover text reads from - independently of
// the overlay's drawing/layout code (UIKeyboardMapTest.java). Pure data/
// logic, no Processing graphics calls anywhere in this file, so none of
// UI_menuBarTest.java's/ClearHoverTest.java's own get()-related
// limitations apply here.
class KeyboardMapBindingsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void buildKeyboardMapBindingsIfNeeded_isIdempotent () {
    app.buildKeyboardMapBindingsIfNeeded();
    ArrayList<String[]> first = app.keyboardMapBindings;
    app.buildKeyboardMapBindingsIfNeeded();
    assertSame(first, app.keyboardMapBindings, "a second call must not rebuild the table");
  }

  @Test
  void describeKey_returnsOneLinePerBindingOnThatKey_regardlessOfCase () {
    // 's' carries two different actions depending on Shift (Next/
    // Previous Sky Scenario, viewport2D.pde's handlePlainCharKey()) -
    // both must show up, and the lookup must be case-insensitive since
    // the table always stores the unshifted label. It also happens to be
    // the "Select" menu's own Alt+<letter> mnemonic (uiMenuBar.pde's
    // PARENT_SHORTCUTS), generated onto the same physical key - a third,
    // unrelated line on the very same key label, confirming the lookup
    // doesn't special-case STUDY's own two entries as "the whole list".
    ArrayList<String> lines = app.keyboardMapDescribeKey("S");
    assertEquals(3, lines.size());
    assertTrue(lines.stream().anyMatch(l -> l.equals("s: Previous Sky Scenario")));
    assertTrue(lines.stream().anyMatch(l -> l.equals("Shift+s: Next Sky Scenario")));
    assertTrue(lines.stream().anyMatch(l -> l.equals("Alt+s: Open \"Select\" menu")));
  }

  @Test
  void describeKey_multiBindingPhysicalKey_listsEveryModifierVariant () {
    // '=' carries three different bindings depending on modifier -
    // plain (STUDY Reset), Ctrl (STUDY Zoom In), and Shift (WIN3D Narrow
    // Field of View, since '+' is Shift+'=').
    ArrayList<String> lines = app.keyboardMapDescribeKey("=");
    assertEquals(3, lines.size());
    assertTrue(lines.contains("=: Reset Study View"));
    assertTrue(lines.contains("Ctrl+=: Zoom In Study"));
    assertTrue(lines.contains("Shift+=: Narrow Field of View"));
  }

  @Test
  void describeKey_keyWithNoBindings_returnsEmpty () {
    assertTrue(app.keyboardMapDescribeKey("k").isEmpty());
  }

  @Test
  void describeModifier_ctrl_aggregatesAcrossEveryBoundKey_includingCtrlShiftCombos () {
    ArrayList<String> lines = app.keyboardMapDescribeModifier("Ctrl");

    // A plain Ctrl-only binding...
    assertTrue(lines.contains("Ctrl+=: Zoom In Study"));
    // ...and a Ctrl+Shift combo must both show up under plain "Ctrl" -
    // Ctrl is part of its requirement even though Shift is too.
    assertTrue(lines.contains("Ctrl+Shift+z: Undo Viewport3D Change"));
    // A binding that needs no modifier at all must never show up here.
    assertFalse(lines.stream().anyMatch(l -> l.equals("s: Previous Sky Scenario")));
  }

  @Test
  void describeModifier_shift_doesNotIncludePlainBindingsOnTheSameKey () {
    ArrayList<String> lines = app.keyboardMapDescribeModifier("Shift");
    assertTrue(lines.contains("Shift+s: Next Sky Scenario"));
    assertFalse(lines.contains("s: Previous Sky Scenario"));
  }

  @Test
  void describeModifier_includesTheAltLetterMenuShortcuts () {
    // Generated straight from UI_menuBar's own PARENT_SHORTCUTS table
    // (buildKeyboardMapBindingsIfNeeded()), not hand-typed - confirms
    // that generation actually ran and produced at least one real entry.
    ArrayList<String> lines = app.keyboardMapDescribeModifier("Alt");
    assertTrue(lines.contains("Alt+f: Open \"File\" menu"));
    assertTrue(lines.contains("Alt+g: Open \"Guide\" menu"));
  }

  @Test
  void modifierFieldRequires_plainBindingNeverMatchesAnyModifier () {
    assertFalse(app.keyboardMapModifierFieldRequires("", "Ctrl"));
    assertFalse(app.keyboardMapModifierFieldRequires("", "Shift"));
    assertFalse(app.keyboardMapModifierFieldRequires("", "Alt"));
  }

  @Test
  void modifierFieldRequires_comboMatchesEachOfItsOwnParts () {
    assertTrue(app.keyboardMapModifierFieldRequires("Ctrl+Shift", "Ctrl"));
    assertTrue(app.keyboardMapModifierFieldRequires("Ctrl+Shift", "Shift"));
    assertFalse(app.keyboardMapModifierFieldRequires("Ctrl+Shift", "Alt"));
  }
}
