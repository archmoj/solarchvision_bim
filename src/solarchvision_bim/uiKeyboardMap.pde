// UI_keyboardMap - a "?"-triggered, click-outside-or-any-key-dismissed
// overlay drawing a full keyboard (+ numpad) on top of everything, purely
// as a hover-driven reference: no highlighting of "currently active"
// keys, no click-to-fire. Hovering a key shows every binding on it
// (keyboardMapBindings.pde); hovering EITHER Shift key shows every
// binding anywhere that uses Shift, and likewise for Ctrl. ALT_L shows
// every binding that uses Alt; ALT_R is drawn as "AltGr" and stays
// inert, since it really is a different physical key (the real dispatch
// code's e.isShiftDown()/e.isControlDown()/e.isAltDown() never
// distinguish left/right Shift or Ctrl, but there is no such thing as a
// generic "right Alt" in that sense - AltGr is its own key).
//
// Uses its own dedicated pre_screen-style capture/restore field (NOT
// UI_menuBar's shared `pre_screen` global) so the two can never clobber
// each other - same technique drawViewport2DLayers.pde's
// studyHover_pre_screen and hoverOnWorldStations.pde's
// worldHover_pre_screen already use for the same "restore, then redraw a
// temporary overlay on top, every frame it's open" need.
class UI_keyboardMap {

  boolean visible = false;
  PImage keyboardMap_pre_screen = null;

  // How far inside the WORLD+WIN3D+STUDY panel union the overlay's
  // scrim/click-region is inset, on all four sides.
  final float OVERLAY_PADDING = 50;

  // One row per laid-out key: {label, x, y, w, h}. Rebuilt fresh on
  // every call (cheap - a few dozen rows) rather than cached, so it's
  // always correct even if the window is resized while this is open.
  class LaidOutKey {
    String label;
    float x, y, w, h;
    LaidOutKey (String label, float x, float y, float w, float h) {
      this.label = label;
      this.x = x; this.y = y; this.w = w; this.h = h;
    }
  }

  // Not `static` - this is a non-static inner class (same as UI_menuBar,
  // STUDY, WORLD, WIN3D, ...), and Java only allows static members of an
  // inner class when they're compile-time constants of a primitive/String
  // type; an array never qualifies, static or not. One instance exists
  // anyway (globalVariables.pde's own UI_keyboardMap singleton), so this
  // costs nothing.

  // Esc + function row + Home/End/Insert/Delete + Page Up/Down, all on
  // one line, same as a real keyboard's top row.
  final String[][] F_ROW = {
    {"ESC","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12",
     "HOME","END","INSERT","DELETE","PAGE_UP","PAGE_DOWN"}
  };

  // CapsLock sits before "a" on the home row - every key after it on
  // that row shifts right automatically, since layoutRows() lays a row
  // out left-to-right by accumulating each key's own width.
  final String[][] MAIN_ROWS = {
    {"`","1","2","3","4","5","6","7","8","9","0","-","=","BACKSPACE"},
    {"TAB","q","w","e","r","t","y","u","i","o","p","[","]","\\"},
    {"CAPSLOCK","a","s","d","f","g","h","j","k","l",";","'","ENTER"},
    {"SHIFT_L","z","x","c","v","b","n","m",",",".","/","SHIFT_R"},
    {"CTRL_L","ALT_L","SPACE","ALT_R","CTRL_R"}
  };

  // Relative widths (in "units", 1 unit = one ordinary key) for the few
  // keys that aren't a plain single-unit square - everything not listed
  // here defaults to 1.
  float keyWidthUnits (String label) {
    switch (label) {
      case "BACKSPACE": return 2f;
      case "TAB": return 1.5f;
      case "CAPSLOCK": return 1.75f;
      case "ENTER": return 2f;
      case "SHIFT_L": case "SHIFT_R": return 2f;
      case "CTRL_L": case "CTRL_R": case "ALT_L": return 1.25f;
      case "ALT_R": return 1.6f; // a bit wider - "AltGr" is a longer label
      case "SPACE": return 6f;
      case "ESC": return 1.25f;
      case "HOME": case "END": case "INSERT": case "DELETE": return 1.25f;
      case "PAGE_UP": case "PAGE_DOWN": return 1.25f;
      default: return 1f;
    }
  }

  // Esc/F-row has a small gap between Esc, the F-key block, the
  // Home/End/Insert/Delete block and the Page Up/Down pair - modelled
  // the same way real keyboards group them, by inserting a gap after
  // the last key of each group.
  float keyGapUnitsAfter (String label) {
    switch (label) {
      case "ESC": return 0.5f;
      case "F12": return 0.5f;
      case "DELETE": return 0.5f;
      default: return 0f;
    }
  }

  final String[][] ARROW_ROWS = {
    {"", "UP", ""},
    {"LEFT", "DOWN", "RIGHT"}
  };

  // Shift-vs-base symbol pairs, keyed by the UNSHIFTED character as it
  // appears on MAIN_ROWS - every key here (and only these; letters are
  // deliberately excluded, since shift+letter is just the uppercase
  // letter and needs no second line) gets its shifted character printed
  // above the base character on its key cap, same as a real keyboard.
  String keyShiftedVariant (String label) {
    switch (label) {
      case "`": return "~";
      case "1": return "!";
      case "2": return "@";
      case "3": return "#";
      case "4": return "$";
      case "5": return "%";
      case "6": return "^";
      case "7": return "&";
      case "8": return "*";
      case "9": return "(";
      case "0": return ")";
      case "-": return "_";
      case "=": return "+";
      case "[": return "{";
      case "]": return "}";
      case "\\": return "|";
      case ";": return ":";
      case "'": return "\"";
      case ",": return "<";
      case ".": return ">";
      case "/": return "?";
      default: return null;
    }
  }

  // Display text shown on a key cap - mostly the label itself, except
  // for the handful of symbolic names that aren't literal characters.
  // Arrow keys use plain ASCII (^ v < >) rather than Unicode arrow
  // glyphs - the Unicode glyphs silently failed to render (missing glyph
  // in the font actually used at draw time), leaving the key caps blank.
  // Not used for a key that has a keyShiftedVariant() - draw() prints
  // those as two lines instead of calling this.
  String keyDisplayText (String label) {
    switch (label) {
      case "BACKSPACE": return "Bksp";
      case "TAB": return "Tab";
      case "CAPSLOCK": return "Caps";
      case "ENTER": case "NUM_ENTER": return "Enter";
      case "SHIFT_L": case "SHIFT_R": return "Shift";
      case "CTRL_L": case "CTRL_R": return "Ctrl";
      case "ALT_L": return "Alt";
      case "ALT_R": return "AltGr";
      case "SPACE": return "";
      case "ESC": return "Esc";
      case "DELETE": return "Del";
      case "INSERT": return "Ins";
      case "HOME": return "Home";
      case "END": return "End";
      case "PAGE_UP": return "PgUp";
      case "PAGE_DOWN": return "PgDn";
      case "NUM_LOCK": return "Num";
      case "NUM_DIV": return "/";
      case "NUM_MUL": return "*";
      case "NUM_SUB": return "-";
      case "NUM_ADD": return "+";
      case "NUM_DOT": return ".";
      case "NUM0": return "0";
      case "NUM1": return "1";
      case "NUM2": return "2";
      case "NUM3": return "3";
      case "NUM4": return "4";
      case "NUM5": return "5";
      case "NUM6": return "6";
      case "NUM7": return "7";
      case "NUM8": return "8";
      case "NUM9": return "9";
      case "UP": return "^";
      case "DOWN": return "v";
      case "LEFT": return "<";
      case "RIGHT": return ">";
      default: return label;
    }
  }

  // The numpad reuses the same physical digits/operators as the main
  // keyboard (hovering either should show the identical binding, since
  // the real dispatch code sees the identical character either way), but
  // is laid out with its own distinct "NUM..." labels rather than the
  // bare characters - that's what lets keyShiftedVariant()/draw() tell a
  // numpad "7" apart from the main row's "7" (the numpad has no
  // shift-printed symbol) without the two ever colliding on-screen as
  // duplicate same-label keys. This maps a numpad label back to the
  // plain character/name describeHoveredKey() should actually look up;
  // null for a numpad key with nothing bound to it (Num Lock).
  String numpadPlainLabel (String label) {
    switch (label) {
      case "NUM0": return "0";
      case "NUM1": return "1";
      case "NUM2": return "2";
      case "NUM3": return "3";
      case "NUM4": return "4";
      case "NUM5": return "5";
      case "NUM6": return "6";
      case "NUM7": return "7";
      case "NUM8": return "8";
      case "NUM9": return "9";
      case "NUM_DOT": return ".";
      case "NUM_DIV": return "/";
      case "NUM_SUB": return "-";
      case "NUM_ENTER": return "ENTER";
      default: return null; // NUM_LOCK, NUM_MUL, NUM_ADD: nothing bound
    }
  }

  // Named show()/hide() rather than open()/close() - "open" is one of
  // Processing 4.5.x's own reserved module-declaration keywords (same
  // category as "to", already hit and renamed around once this session,
  // see importIfc.pde's ifcAngleDiffCCW()/its own comment): its rewritten
  // CLI preprocessor misparses a plain method call named "open" as if it
  // were starting a `module`/`open module` declaration, even completely
  // outside any module syntax. Processing 4.4.x has no such reservation,
  // but this avoids depending on which CLI version actually runs it.
  void show () {
    if (this.visible) return;
    buildKeyboardMapBindingsIfNeeded();
    this.keyboardMap_pre_screen = get(0, 0, width, height);
    this.visible = true;
    redraw();
  }

  void hide () {
    if (!this.visible) return;
    this.visible = false;
    if (this.keyboardMap_pre_screen != null) {
      image(this.keyboardMap_pre_screen, 0, 0);
    }
    redraw();
  }

  // The on-screen union of the three main panels (WORLD, WIN3D, STUDY),
  // regardless of which of them is currently included in the active
  // layout - a panel's on-screen rect is [cX, cY, cX + dX/ImageScale,
  // cY + dY/ImageScale], the same formula mouseClicked.pde already uses
  // for hit-testing these panels.
  float[] panelUnionBounds () {
    float left = Float.MAX_VALUE, top = Float.MAX_VALUE;
    float right = -Float.MAX_VALUE, bottom = -Float.MAX_VALUE;

    left = min(left, STUDY.cX); left = min(left, WORLD.cX); left = min(left, WIN3D.cX);
    top = min(top, STUDY.cY); top = min(top, WORLD.cY); top = min(top, WIN3D.cY);
    right = max(right, STUDY.cX + STUDY.dX / STUDY.ImageScale);
    right = max(right, WORLD.cX + WORLD.dX / WORLD.ImageScale);
    right = max(right, WIN3D.cX + WIN3D.dX / WIN3D.ImageScale);
    bottom = max(bottom, STUDY.cY + STUDY.dY / STUDY.ImageScale);
    bottom = max(bottom, WORLD.cY + WORLD.dY / WORLD.ImageScale);
    bottom = max(bottom, WIN3D.cY + WIN3D.dY / WIN3D.ImageScale);

    return new float[]{ left, top, right, bottom };
  }

  // The overlay's own drawn region: the panel union, inset by
  // OVERLAY_PADDING on every side. This is both the scrim rectangle
  // drawn in draw() and the click-region used by isInsideBounds() - a
  // click inside this does nothing (no click-to-fire in this version), a
  // click anywhere outside it closes the overlay (mouseClicked.pde
  // already swallows either case, so nothing beneath ever sees this same
  // click).
  float[] boundingBox () {
    float[] box = panelUnionBounds();
    return new float[]{
      box[0] + OVERLAY_PADDING, box[1] + OVERLAY_PADDING,
      box[2] - OVERLAY_PADDING, box[3] - OVERLAY_PADDING
    };
  }

  boolean isInsideBounds (float x, float y) {
    if (!this.visible) return false;
    float[] box = boundingBox();
    return isInside(x, y, box[0], box[1], box[2], box[3]);
  }

  // 125% of the original size, per the earlier request to make the
  // keyboard, its text, and its hover labels 25% larger.
  float keyUnit () {
    return 1.25 * 2.2 * MessageSize;
  }

  ArrayList<LaidOutKey> layoutRows (String[][] rows, float left, float top) {
    ArrayList<LaidOutKey> keys = new ArrayList<LaidOutKey>();
    float unit = keyUnit();
    float y = top;
    for (String[] row : rows) {
      float x = left;
      for (String label : row) {
        float w = keyWidthUnits(label) * unit;
        if (label.length() > 0) keys.add(new LaidOutKey(label, x, y, w, unit));
        x += w + keyGapUnitsAfter(label) * unit;
      }
      y += unit;
    }
    return keys;
  }

  // The numpad, laid out explicitly (not through layoutRows()'s uniform
  // grid) so the "+" and Enter keys can genuinely span two rows and "0"
  // can genuinely span two columns - one physical key, one LaidOutKey,
  // rather than two same-label keys stacked or sat side by side.
  ArrayList<LaidOutKey> buildNumpadLayout (float left, float top) {
    ArrayList<LaidOutKey> keys = new ArrayList<LaidOutKey>();
    float unit = keyUnit();
    float c0 = left, c1 = left + unit, c2 = left + 2 * unit, c3 = left + 3 * unit;
    float r0 = top, r1 = top + unit, r2 = top + 2 * unit, r3 = top + 3 * unit, r4 = top + 4 * unit;

    keys.add(new LaidOutKey("NUM_LOCK", c0, r0, unit, unit));
    keys.add(new LaidOutKey("NUM_DIV", c1, r0, unit, unit));
    keys.add(new LaidOutKey("NUM_MUL", c2, r0, unit, unit));
    keys.add(new LaidOutKey("NUM_SUB", c3, r0, unit, unit));

    keys.add(new LaidOutKey("NUM7", c0, r1, unit, unit));
    keys.add(new LaidOutKey("NUM8", c1, r1, unit, unit));
    keys.add(new LaidOutKey("NUM9", c2, r1, unit, unit));
    keys.add(new LaidOutKey("NUM_ADD", c3, r1, unit, 2 * unit)); // spans r1-r2

    keys.add(new LaidOutKey("NUM4", c0, r2, unit, unit));
    keys.add(new LaidOutKey("NUM5", c1, r2, unit, unit));
    keys.add(new LaidOutKey("NUM6", c2, r2, unit, unit));

    keys.add(new LaidOutKey("NUM1", c0, r3, unit, unit));
    keys.add(new LaidOutKey("NUM2", c1, r3, unit, unit));
    keys.add(new LaidOutKey("NUM3", c2, r3, unit, unit));
    keys.add(new LaidOutKey("NUM_ENTER", c3, r3, unit, 2 * unit)); // spans r3-r4

    keys.add(new LaidOutKey("NUM0", c0, r4, 2 * unit, unit)); // spans c0-c1
    keys.add(new LaidOutKey("NUM_DOT", c2, r4, unit, unit));

    return keys;
  }

  ArrayList<LaidOutKey> buildLayout () {
    ArrayList<LaidOutKey> keys = new ArrayList<LaidOutKey>();
    float unit = keyUnit();
    float[] box = boundingBox();
    float padding = unit;

    float mainLeft = box[0] + padding;
    float mainTop = box[1] + padding;

    // Esc + F1-F12 + Home/End/Insert/Delete + PgUp/PgDn, top-left corner
    // of the overlay, above everything else.
    keys.addAll(layoutRows(F_ROW, mainLeft, mainTop));

    float rowsTop = mainTop + 1.5 * unit;
    keys.addAll(layoutRows(MAIN_ROWS, mainLeft, rowsTop));

    // Widest MAIN_ROWS row is the top number row: ` 1-9 0 - = (13 single
    // units) + Backspace (2 units) = 15 units.
    float mainWidthUnits = 15f;
    float clusterLeft = mainLeft + mainWidthUnits * unit + 0.5 * unit;

    // Arrow cluster, roughly level with the main block's lower rows.
    float arrowTop = rowsTop + 3.5 * unit;
    for (int r = 0; r < ARROW_ROWS.length; r++) {
      for (int c = 0; c < ARROW_ROWS[r].length; c++) {
        String label = ARROW_ROWS[r][c];
        if (label.length() == 0) continue;
        keys.add(new LaidOutKey(label, clusterLeft + c * unit, arrowTop + r * unit, unit, unit));
      }
    }

    // Numpad, to the right of the arrow cluster, starting level with the
    // main typing block (not the Esc/F-row).
    float numpadLeft = clusterLeft + 3.5 * unit;
    keys.addAll(buildNumpadLayout(numpadLeft, rowsTop));

    return keys;
  }

  // Finds the laid-out key (if any) under the given point.
  LaidOutKey keyAt (ArrayList<LaidOutKey> keys, float x, float y) {
    for (LaidOutKey k : keys) {
      if (isInside(x, y, k.x, k.y, k.x + k.w, k.y + k.h)) return k;
    }
    return null;
  }

  // What hovering the given laid-out key should show. Both Shift keys
  // aggregate every Shift binding; both Ctrl keys aggregate every Ctrl
  // binding; ALT_L aggregates every Alt binding; ALT_R ("AltGr") is a
  // genuinely different physical key with no bindings of its own, so it
  // stays inert. A numpad key looks up its plain-character equivalent
  // (numpadPlainLabel()) so it shows the exact same bindings as the
  // corresponding main-row key; everything else just looks up its own
  // key label.
  ArrayList<String> describeHoveredKey (LaidOutKey k) {
    if (k == null) return new ArrayList<String>();
    switch (k.label) {
      case "SHIFT_L": case "SHIFT_R": return keyboardMapDescribeModifier("Shift");
      case "CTRL_L": case "CTRL_R": return keyboardMapDescribeModifier("Ctrl");
      case "ALT_L": return keyboardMapDescribeModifier("Alt");
      case "ALT_R": return new ArrayList<String>();
      default:
        String plain = numpadPlainLabel(k.label);
        return keyboardMapDescribeKey(plain != null ? plain : k.label);
    }
  }

  void draw () {
    if (!this.visible) return;

    // Restore, then redraw the overlay on top - every frame, the same
    // pattern the hover boxes already use, so the hover text underneath
    // the cursor can change every frame without leaving stale pixels
    // from a previous frame's longer description.
    if (this.keyboardMap_pre_screen != null) {
      image(this.keyboardMap_pre_screen, 0, 0);
    }

    float[] box = boundingBox();

    noStroke();
    fill(0, 191); // 75% opacity (0.75 * 255 ~= 191)
    rect(box[0], box[1], box[2] - box[0], box[3] - box[1]);

    ArrayList<LaidOutKey> keys = buildLayout();

    textAlign(CENTER, CENTER);

    LaidOutKey hovered = keyAt(keys, mouseX, mouseY);

    for (LaidOutKey k : keys) {
      boolean isHovered = (k == hovered);

      // Every key renders the same way (plain fill) regardless of
      // whether it's Shift/Ctrl/Alt - only the mouseover hover highlight
      // differs, and it applies uniformly to any key.
      noStroke();
      if (isHovered) {
        fill(0, 140, 255);
      } else {
        fill(40);
      }
      rect(k.x + 2, k.y + 2, k.w - 4, k.h - 4, 4);

      fill(255);
      String shifted = keyShiftedVariant(k.label);
      if (shifted != null) {
        // Shift-variant on top, base character on the bottom - same
        // arrangement a real key cap uses.
        textSize(0.32 * keyUnit());
        text(shifted, k.x + k.w / 2, k.y + k.h * 0.32);
        text(keyDisplayText(k.label), k.x + k.w / 2, k.y + k.h * 0.68);
      } else {
        textSize(0.4 * keyUnit());
        text(keyDisplayText(k.label), k.x + k.w / 2, k.y + k.h / 2);
      }
    }

    ArrayList<String> lines = describeHoveredKey(hovered);
    if (lines.size() > 0) {
      float boxTop = mainClusterBottom(keys) + 0.5 * keyUnit();
      float lineHeight = 0.5 * keyUnit();
      textAlign(LEFT, TOP);
      textSize(0.35 * keyUnit());
      fill(255);
      float ty = boxTop;
      for (String line : lines) {
        text(line, box[0] + keyUnit(), ty);
        ty += lineHeight;
      }
    }
  }

  float mainClusterBottom (ArrayList<LaidOutKey> keys) {
    float bottom = 0;
    for (LaidOutKey k : keys) bottom = max(bottom, k.y + k.h);
    return bottom;
  }
}
