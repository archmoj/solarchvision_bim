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
//
// show() does briefly READ (never write) UI_menuBar's own `pre_screen`
// global - see show()'s own comment below for why: opening this overlay
// via the "Show Keyboard Map" menu item would otherwise bake the still-
// open dropdown's pixels into keyboardMap_pre_screen forever.
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

  // Esc + F1-F12, grouped visually into 3 groups of 4 (F1-F4, F5-F8,
  // F9-F12) by a small gap after F4 and after F8 - see
  // keyGapUnitsAfter(). Insert/Home/PageUp/Delete/End/PageDown used to
  // sit on this same line; they now live in their own block directly
  // above the arrow cluster instead (buildNavBlockLayout()), matching
  // where a real keyboard puts them - so they appear here only once,
  // never duplicated.
  final String[][] F_ROW = {
    {"ESC","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12"}
  };

  // CapsLock sits before "a" on the home row - every key after it on
  // that row shifts right automatically, since layoutRows() lays a row
  // out left-to-right by accumulating each key's own width. Backspace,
  // "\", Enter and right-Shift are all deliberately widened (see
  // keyWidthUnits()) so their four right edges land on the exact same
  // column - every one of these 5 rows (this one included, via
  // Ctrl/Alt/Space/Ctrl on the bottom row) is exactly 16 units wide.
  final String[][] MAIN_ROWS = {
    {"`","1","2","3","4","5","6","7","8","9","0","-","=","BACKSPACE"},
    {"TAB","q","w","e","r","t","y","u","i","o","p","[","]","\\"},
    {"CAPSLOCK","a","s","d","f","g","h","j","k","l",";","'","ENTER"},
    {"SHIFT_L","z","x","c","v","b","n","m",",",".","/","SHIFT_R"},
    {"CTRL_L","ALT_L","SPACE","ALT_R","CTRL_R"}
  };

  // F1-F12's width, chosen so F12's right edge lands on the same 16-unit
  // column as Backspace/"\"/Enter/right-Shift/right-Ctrl: the F-row is
  // Esc (2 units) + a 0.5-unit gap + 12 F-keys + 2 more 0.5-unit gaps
  // (after F4 and after F8) = 2 + 0.5 + 12*w + 1.0 = 16, so
  // w = (16 - 3.5) / 12.
  final float FKEY_WIDTH = (16f - 3.5f) / 12f;

  // Relative widths (in "units", 1 unit = one ordinary key) for the few
  // keys that aren't a plain single-unit square - everything not listed
  // here defaults to 1. Backspace/"\"/Enter/right-Shift are sized so
  // their row's total is exactly 16 units (their four right edges
  // align); Ctrl/Alt/AltGr all match left-Shift's width; Space is sized
  // so right-Ctrl's right edge lands on that same 16-unit column; F1-F12
  // are sized so F12's right edge lands there too (see FKEY_WIDTH).
  float keyWidthUnits (String label) {
    switch (label) {
      case "BACKSPACE": return 3f;     // row0: 13 + 3 = 16
      case "\\": return 2.5f;          // row1: 13.5 + 2.5 = 16
      case "TAB": return 1.5f;
      case "CAPSLOCK": return 1.75f;
      case "ENTER": return 3.25f;      // row2: 12.75 + 3.25 = 16
      case "SHIFT_L": return 2f;       // unchanged - the sizing reference for Ctrl/Alt below
      case "SHIFT_R": return 4f;       // row3: 12 + 4 = 16
      case "CTRL_L": case "CTRL_R": case "ALT_L": case "ALT_R": return 2f; // matches SHIFT_L
      case "SPACE": return 8f;         // row4: 2+2+8+2+2 = 16, so right-Ctrl's right edge = 16 too
      case "ESC": return 2f;           // matches Shift/Ctrl/Alt's width
      case "F1": case "F2": case "F3": case "F4": case "F5": case "F6":
      case "F7": case "F8": case "F9": case "F10": case "F11": case "F12":
        return FKEY_WIDTH;
      default: return 1f;
    }
  }

  // Esc/F-row groups F1-F12 into 3 groups of 4 (F1-F4 | F5-F8 | F9-F12)
  // with a small gap after F4 and after F8 - same technique real
  // keyboards use, by inserting a gap after the last key of each group.
  float keyGapUnitsAfter (String label) {
    switch (label) {
      case "ESC": return 0.5f;
      case "F4": return 0.5f;
      case "F8": return 0.5f;
      default: return 0f;
    }
  }

  final String[][] ARROW_ROWS = {
    {"", "UP", ""},
    {"LEFT", "DOWN", "RIGHT"}
  };

  // Insert/Delete, Home/PageUp, End/PageDown - 3 rows of 2 (not 2 rows of
  // 3 any more), the block that sits directly above the arrow cluster.
  // 2 wider columns instead of 3 narrower ones gives each label (full
  // words like "Insert"/"Delete") room to fit at a normal text size - no
  // more need for the smaller narrow-column font the old 3-column
  // version needed.
  final String[][] NAV_BLOCK_ROWS = {
    {"INSERT", "DELETE"},
    {"HOME", "PAGE_UP"},
    {"END", "PAGE_DOWN"}
  };

  // All 6 of this block's labels (one-line or two-line alike) share one
  // text size - see draw().
  boolean isNavBlockLabel (String label) {
    switch (label) {
      case "INSERT": case "DELETE": case "HOME": case "END":
      case "PAGE_UP": case "PAGE_DOWN":
        return true;
      default: return false;
    }
  }

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
  // those as two lines instead of calling this. A "\n" in the returned
  // text (Page Up/Page Down) means draw() stacks it as two lines too.
  String keyDisplayText (String label) {
    switch (label) {
      case "BACKSPACE": return "Backspace";
      case "TAB": return "Tab";
      case "CAPSLOCK": return "Caps";
      case "ENTER": case "NUM_ENTER": return "Enter";
      case "SHIFT_L": case "SHIFT_R": return "Shift";
      case "CTRL_L": case "CTRL_R": return "Ctrl";
      case "ALT_L": return "Alt";
      case "ALT_R": return "AltGr";
      case "SPACE": return "";
      case "ESC": return "Esc";
      case "DELETE": return "Delete";
      case "INSERT": return "Insert";
      case "HOME": return "Home";
      case "END": return "End";
      case "PAGE_UP": return "Page\nUp";
      case "PAGE_DOWN": return "Page\nDown";
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
  // True exactly when UI_menuBar's dropdown is still the last thing
  // actually painted on screen: reached via "Show Keyboard Map" in the
  // menu, the click/Enter handler (mouseClicked.pde /
  // UI_menuBar.keyPressed()) runs this action's show() BEFORE calling
  // UI_menuBar.deselect() - so at that exact moment the dropdown is
  // still on screen even though selected_parent != -1 is the only trace
  // of it left in state. Split out from show() purely so this condition
  // is itself unit-testable without touching real graphics (show()'s
  // own image()/get() calls aren't, see show()'s comment below).
  boolean menuDropdownStillOnScreen () {
    return (UI_menuBar.selected_parent != -1) && (pre_screen != null);
  }

  void show () {
    if (this.visible) return;
    buildKeyboardMapBindingsIfNeeded();

    // If we captured our own pre_screen while that dropdown was still
    // on screen, it would be baked into keyboardMap_pre_screen forever
    // - the dropdown itself will have long since closed by the time
    // hide() restores that capture, so nothing would ever repaint over
    // it. Repainting UI_menuBar's own pre_screen first erases the
    // dropdown from the actual screen (exactly what UI_menuBar.
    // deselect() itself would do), so our capture below is clean
    // either way - whether we were opened via the menu or via "?"
    // (where selected_parent is already -1 and this is a no-op).
    if (menuDropdownStillOnScreen()) {
      image(pre_screen, 0, pixel_A);
    }

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

  // 125% of the original size, per an earlier request to make the
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

  // Insert/Delete, Home/PageUp, End/PageDown - 3 rows of 2, sat directly
  // on top of the arrow cluster, its own left/right edges matching the
  // arrow cluster's (same total span, 3 unit-wide columns, just now
  // split into 2 wider columns instead of 3 narrower ones - each column
  // is 1.5 units wide, so 2 * 1.5 = 3, same span as the arrow cluster's
  // 3 one-unit columns). Built explicitly for the same reason the
  // numpad is: a uniform grid is all it needs, but it has to line up
  // with a specific caller-chosen span (the arrow cluster's), not its
  // own independent one.
  ArrayList<LaidOutKey> buildNavBlockLayout (float left, float top) {
    ArrayList<LaidOutKey> keys = new ArrayList<LaidOutKey>();
    float unit = keyUnit();
    float colWidth = 1.5 * unit;
    float y = top;
    for (String[] row : NAV_BLOCK_ROWS) {
      float x = left;
      for (String label : row) {
        keys.add(new LaidOutKey(label, x, y, colWidth, unit));
        x += colWidth;
      }
      y += unit;
    }
    return keys;
  }

  ArrayList<LaidOutKey> buildLayout () {
    ArrayList<LaidOutKey> keys = new ArrayList<LaidOutKey>();
    float unit = keyUnit();
    float[] box = boundingBox();
    float padding = unit;

    float mainLeft = box[0] + padding;
    float mainTop = box[1] + padding;

    // Esc + F1-F12 (3 groups of 4), top-left corner of the overlay,
    // above everything else.
    keys.addAll(layoutRows(F_ROW, mainLeft, mainTop));

    float rowsTop = mainTop + 1.5 * unit;
    keys.addAll(layoutRows(MAIN_ROWS, mainLeft, rowsTop));

    // Every MAIN_ROWS row is exactly 16 units wide now (Backspace/"\"/
    // Enter/right-Shift/the Ctrl+Alt+Space+Alt+Ctrl row all land on the
    // same right edge - see keyWidthUnits()).
    float mainWidthUnits = 16f;
    float clusterLeft = mainLeft + mainWidthUnits * unit + 0.5 * unit;

    // Arrow cluster (2 rows), bottom edge aligned with Space's bottom
    // edge: Space sits on MAIN_ROWS' last row (index 4), whose bottom is
    // rowsTop + 5*unit, so the 2-row-tall arrow cluster must start at
    // rowsTop + 3*unit.
    float arrowTop = rowsTop + 3 * unit;
    for (int r = 0; r < ARROW_ROWS.length; r++) {
      for (int c = 0; c < ARROW_ROWS[r].length; c++) {
        String label = ARROW_ROWS[r][c];
        if (label.length() == 0) continue;
        keys.add(new LaidOutKey(label, clusterLeft + c * unit, arrowTop + r * unit, unit, unit));
      }
    }

    // Insert/Delete + Home/PageUp + End/PageDown, 3 rows tall, same
    // left/right span as the arrow cluster below it - moved up one more
    // row, leaving a 1-unit gap above the arrow cluster instead of
    // touching it.
    keys.addAll(buildNavBlockLayout(clusterLeft, arrowTop - 4 * unit));

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
      String disp = keyDisplayText(k.label);
      if (shifted != null) {
        // Shift-variant on top, base character on the bottom - same
        // arrangement a real key cap uses.
        textSize(0.32 * keyUnit());
        text(shifted, k.x + k.w / 2, k.y + k.h * 0.32);
        text(disp, k.x + k.w / 2, k.y + k.h * 0.68);
      } else if (isNavBlockLabel(k.label)) {
        // Insert/Delete/Home/End/PageUp/PageDown all share one text
        // size, one-line or two-line alike.
        textSize(0.28 * keyUnit());
        if (disp.indexOf("\n") >= 0) {
          String[] parts = disp.split("\n");
          text(parts[0], k.x + k.w / 2, k.y + k.h * 0.32);
          text(parts[1], k.x + k.w / 2, k.y + k.h * 0.68);
        } else {
          text(disp, k.x + k.w / 2, k.y + k.h / 2);
        }
      } else if (k.label.equals("NUM_ENTER") || k.label.equals("NUM_LOCK")) {
        // Smaller font for the numpad's own "Enter"/"Num" caps.
        textSize(0.28 * keyUnit());
        text(disp, k.x + k.w / 2, k.y + k.h / 2);
      } else {
        textSize(0.4 * keyUnit());
        text(disp, k.x + k.w / 2, k.y + k.h / 2);
      }
    }

    ArrayList<String> lines = describeHoveredKey(hovered);
    if (lines.size() > 0) {
      // Laid out in up to 3 columns rather than one long column, so a
      // key with many bindings (Shift/Ctrl/Alt, say) never overflows
      // past the overlay's own bottom edge: a column only holds as many
      // lines as actually fit above that edge, and the next line spills
      // into the next column instead of past the bottom.
      float hintTextSize = 0.45 * keyUnit();
      float lineHeight = 1.4 * hintTextSize;
      float boxTop = mainClusterBottom(keys) + 0.5 * keyUnit();
      float bottomLimit = box[3] - 0.25 * keyUnit();
      int linesPerColumn = max(1, (int) floor((bottomLimit - boxTop) / lineHeight));
      int columnCount = 3;
      float firstColumnX = box[0] + keyUnit();
      float columnWidth = (box[2] - firstColumnX) / columnCount;

      textAlign(LEFT, TOP);
      textSize(hintTextSize);
      fill(255);
      // No bold variant of the overlay's own font is loaded (font.pde
      // only ever loads one weight), so the combo ("Ctrl+[dot]", say)
      // is faux-bolded by drawing it twice, offset by roughly a device
      // pixel - thickens every stroke enough to read as bold without a
      // second font file.
      float boldOffset = max(1, 0.04 * hintTextSize);
      int maxLines = min(lines.size(), linesPerColumn * columnCount);
      for (int i = 0; i < maxLines; i++) {
        int col = i / linesPerColumn;
        int row = i % linesPerColumn;
        float tx = firstColumnX + col * columnWidth;
        float ty = boxTop + row * lineHeight;

        // keyboardMapSplitLineForDisplay() also swaps the combo's tiny,
        // easily-confused punctuation (".", ",", "'", ...) for a
        // readable bracketed name, e.g. "Ctrl+.: ..." renders as
        // "Ctrl+[dot]: ..." - see that function's own comment
        // (keyboardMapBindings.pde) for why the underlying data/lookup
        // table itself is left untouched.
        String[] parts = keyboardMapSplitLineForDisplay(lines.get(i));
        String combo = parts[0];
        String description = parts[1];

        text(combo, tx, ty);
        text(combo, tx + boldOffset, ty);
        text(": " + description, tx + textWidth(combo) + boldOffset, ty);
      }
    }
  }

  float mainClusterBottom (ArrayList<LaidOutKey> keys) {
    float bottom = 0;
    for (LaidOutKey k : keys) bottom = max(bottom, k.y + k.h);
    return bottom;
  }
}
