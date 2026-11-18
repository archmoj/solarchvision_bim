// Single source of truth for everything UI_keyboardMap.pde draws hover
// text for. One row per binding: {keyLabel, modifierLabel, description}.
//
// - keyLabel matches a label used in UI_keyboardMap.pde's own
//   KEYBOARD_MAP_MAIN_ROWS/KEYBOARD_MAP_NUMPAD_ROWS layout tables (always
//   the *unshifted* key - e.g. "9" not "(", "," not "<" - so a shifted
//   symbol is represented as {baseKey, "Shift", ...} instead of inventing
//   a second key label for it).
// - modifierLabel is one of "", "Shift", "Ctrl", "Alt", "Ctrl+Shift" -
//   exactly the combination the real dispatch code
//   (viewport2D.pde/viewport3D.pde/viewportMap.pde/solarchvision_bim.pde)
//   requires for that row's description to apply.
//
// Deliberately NOT unified with those real per-panel switch-statements -
// this is the lower-risk, additive option discussed when the overlay was
// designed: a separate registry kept in sync by hand, rather than a
// refactor of the hot key-dispatch path itself. The one slice that *is*
// generated straight from existing data, so it can't drift, is the
// Alt+<letter>-opens-a-menu set, built from UI_menuBar's own
// PARENT_SHORTCUTS table in buildKeyboardMapBindingsIfNeeded() below
// rather than re-typed here.
ArrayList<String[]> keyboardMapBindings = null;

void buildKeyboardMapBindingsIfNeeded () {
  if (keyboardMapBindings != null) return;
  keyboardMapBindings = new ArrayList<String[]>();

  String[][] fixed = {

    // --- STUDY (hourly/probability graph - viewport2D.pde) ---
    {"UP", "Ctrl+Shift", "Pan Study Up"},
    {"DOWN", "Ctrl+Shift", "Pan Study Down"},
    {"LEFT", "Ctrl+Shift", "Pan Study Left"},
    {"RIGHT", "Ctrl+Shift", "Pan Study Right"},
    {"UP", "Ctrl", "Next Layer"},
    {"DOWN", "Ctrl", "Previous Layer"},
    {"RIGHT", "Ctrl", "Next Graph Index"},
    {"LEFT", "Ctrl", "Previous Graph Index"},
    {"PAGE_UP", "Ctrl", "Next Plot Layout"},
    {"PAGE_DOWN", "Ctrl", "Previous Plot Layout"},
    {";", "Ctrl", "Toggle Impact Summary"},
    {"'", "Ctrl+Shift", "Increase Vertical Scale"}, // '"' is Shift+'
    {"'", "Ctrl", "Decrease Vertical Scale"},
    {"=", "Ctrl", "Zoom In Study"},
    {"-", "Ctrl", "Zoom Out Study"},
    {"=", "", "Reset Study View"},
    {".", "Shift", "Widen Join Window"}, // '>' is Shift+.
    {",", "Shift", "Narrow Join Window"}, // '<' is Shift+,
    {"0", "Shift", "Extend Date Range"}, // ')' is Shift+0
    {"9", "Shift", "Shrink Date Range"}, // '(' is Shift+9
    {"s", "Shift", "Next Sky Scenario"},
    {"s", "", "Previous Sky Scenario"},
    {"v", "", "Toggle Raw Lines"},
    {"m", "", "Toggle Statistical Ranges (Min/Median/Max bands)"},
    {"n", "", "Toggle Study Normal Lines"},
    {"b", "", "Toggle Probabilities"},
    {"[", "Shift", "Increase Probability Height Step"}, // '{' is Shift+[
    {"]", "Shift", "Decrease Probability Height Step"}, // '}' is Shift+]
    {"[", "", "Decrease Sum Interval"},
    {"]", "", "Increase Sum Interval"},

    // --- WORLD (map - viewportMap.pde) ---
    {"`", "", "Map Zoom Out"},
    {"`", "Shift", "Map Zoom In"}, // '~' is Shift+`

    // --- WIN3D (3D viewport - viewport3D.pde) ---
    {",", "Ctrl", "Nudge Closer to Selection"},
    {".", "Ctrl", "Nudge Away from Selection"},
    {"RIGHT", "Alt", "Shade Next Day"},
    {"LEFT", "Alt", "Shade Previous Day"},
    {"UP", "Alt", "Shade Next Hour"},
    {"DOWN", "Alt", "Shade Previous Hour"},
    {"UP", "Shift", "Increase Tool Parameter"},
    {"DOWN", "Shift", "Decrease Tool Parameter"},
    {"UP", "", "Orbit Up Around Selection"},
    {"DOWN", "", "Orbit Down Around Selection"},
    {"LEFT", "", "Orbit Left Around Selection"},
    {"RIGHT", "", "Orbit Right Around Selection"},
    {"a", "", "Toggle Impact Type"},
    {"DELETE", "", "Delete Selection"},
    {",", "", "Zoom Out"},
    {"0", "", "Zoom Out"},
    {".", "", "Zoom In"},
    {"5", "", "Look at Selection"},
    {"4", "", "Turn View Left"},
    {"6", "", "Turn View Right"},
    {"8", "", "Turn View Up"},
    {"2", "", "Turn View Down"},
    {"1", "", "Pan Left"},
    {"3", "", "Pan Right"},
    {"7", "", "Pan Forward"},
    {"9", "", "Pan Backward"},
    {"8", "Shift", "Dolly Away From Selection"}, // '*' is Shift+8
    {"/", "", "Dolly Toward Selection"},
    {"=", "Shift", "Narrow Field of View"}, // '+' is Shift+=
    {"-", "", "Widen Field of View"},
    {"c", "", "Next Camera"},
    {"c", "Shift", "Previous Camera"},
    {"t", "", "Shade Next Hour"},
    {"t", "Shift", "Shade Previous Hour"},
    {"d", "", "Next Impact Day"},
    {"d", "Shift", "Previous Impact Day"},
    {"ENTER", "", "Recalculate Solar Impact"},
    {"SPACE", "", "Advance time one hour and shade the viewport"},
    {"BACKSPACE", "", "Rewind time one hour and shade the viewport"},

    // --- Global (solarchvision_bim.pde) ---
    {"z", "Ctrl", "Undo Scene3D Change"},
    {"z", "Ctrl+Shift", "Undo Viewport3D Change"},
    {"y", "Ctrl", "Redo Scene3D Change"},
    {"y", "Ctrl+Shift", "Redo Viewport3D Change"},
    {"TAB", "", "Show or hide the command bar"},
    {"ESC", "", "Cancel an in-progress edit, or close whatever is open (menu, pick list, shading preview, pinned hover point)"},
    {"/", "Shift", "Show this keyboard map"} // '?' is Shift+/
  };
  for (String[] row : fixed) keyboardMapBindings.add(row);

  // Alt+<letter> opens each top-level menu - generated from UI_menuBar's
  // own PARENT_SHORTCUTS table instead of re-typed here, so this slice
  // can't silently drift out of sync with the real menu.
  for (String[] shortcut : UI_menuBar.PARENT_SHORTCUTS) {
    keyboardMapBindings.add(new String[]{ shortcut[0].toLowerCase(), "Alt", "Open \"" + shortcut[1] + "\" menu" });
  }
}

// True if modifierField (e.g. "Ctrl+Shift") requires the given single
// modifier (e.g. "Ctrl") as part of its combination. A plain-key row
// (modifierField == "") never matches any modifier.
boolean keyboardMapModifierFieldRequires (String modifierField, String target) {
  if (modifierField == null || modifierField.length() == 0) return false;
  for (String part : modifierField.split("\\+")) {
    if (part.equals(target)) return true;
  }
  return false;
}

String keyboardMapFormatLine (String[] row) {
  String keyLabel = row[0];
  String modifierField = row[1];
  String description = row[2];
  String combo = (modifierField.length() == 0) ? keyLabel : (modifierField + "+" + keyLabel);
  return combo + ": " + description;
}

// Every binding on the given physical (unshifted) key label, regardless
// of modifier - what hovering an ordinary key shows.
ArrayList<String> keyboardMapDescribeKey (String keyLabel) {
  buildKeyboardMapBindingsIfNeeded();
  ArrayList<String> lines = new ArrayList<String>();
  for (String[] row : keyboardMapBindings) {
    if (row[0].equalsIgnoreCase(keyLabel)) lines.add(keyboardMapFormatLine(row));
  }
  return lines;
}

// Every binding that requires the given modifier (Shift/Ctrl/Alt) as
// part of its combination, anywhere on the keyboard - what hovering the
// left Shift/Ctrl/Alt key shows. Right Shift/Ctrl/Alt are deliberately
// never routed here (see UI_keyboardMap.pde) - they're drawn but inert.
ArrayList<String> keyboardMapDescribeModifier (String modifierName) {
  buildKeyboardMapBindingsIfNeeded();
  ArrayList<String> lines = new ArrayList<String>();
  for (String[] row : keyboardMapBindings) {
    if (keyboardMapModifierFieldRequires(row[1], modifierName)) lines.add(keyboardMapFormatLine(row));
  }
  return lines;
}
