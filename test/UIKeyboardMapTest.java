import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.util.ArrayList;
import processing.event.KeyEvent;
import processing.event.Event;

// Covers UI_keyboardMap's own layout/hover logic (uiKeyboardMap.pde) and
// its wiring into keyPressed()/mouseClicked() (solarchvision_bim.pde/
// mouseClicked.pde) and the "Guide" menu (uiMenuBar.pde/actions.pde).
//
// show()/draw() themselves call Processing's real get()/image()/fill()/
// rect()/text() - confirmed-to-throw against this harness's uninitialized
// graphics context, the same category UIMenuBarShortcutsTest.java's own
// header comment already documents for openParentMenu(). Every test
// below that needs the overlay "open" therefore sets
// app.UI_keyboardMap.visible = true directly instead of calling show(),
// which also conveniently matches how hide() is actually exercised in
// real use after a from-closed show() already ran: keyboardMap_pre_screen
// stays null either way, and hide()'s own image(...) call is already
// guarded on it being non-null, so nothing here ever reaches a real
// graphics call. The "Show Keyboard Map" action is likewise only ever
// confirmed to be *registered*, never actually run, for the same reason.
class UIKeyboardMapTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>();
    app.build_allActions();
    app.frameCount = 100;
    app.control = app.USER_GUI;
    app.UI_menuBar.selected_parent = -1;

    // The overlay's own bounds are now derived from the on-screen union
    // of WORLD/WIN3D/STUDY (see panelUnionBounds()), not from the key
    // layout - so, same convention already used by MouseClickedTest.java
    // and MouseClickedStudyHoverPinTest.java, give the three panels
    // explicit, sane screen geometry rather than relying on their tiny
    // pre-setup()/pre-updateFrameLayout() placeholder defaults.
    app.WORLD.cX = 0; app.WORLD.cY = 0; app.WORLD.dX = 600; app.WORLD.dY = 400; app.WORLD.ImageScale = 1;
    app.STUDY.cX = 600; app.STUDY.cY = 0; app.STUDY.dX = 600; app.STUDY.dY = 400; app.STUDY.ImageScale = 1;
    app.WIN3D.cX = 0; app.WIN3D.cY = 400; app.WIN3D.dX = 1200; app.WIN3D.dY = 400; app.WIN3D.ImageScale = 1;
  }

  private KeyEvent keyEvent (char key, int modifiers) {
    return new KeyEvent(null, 0, KeyEvent.PRESS, modifiers, key, (int) key, false);
  }

  // ================= layout / hover lookup ==================================

  @Test
  void buildLayout_includesTheMainRowsNavClusterAndNumpad () {
    ArrayList<solarchvision_bim.UI_keyboardMap.LaidOutKey> keys = app.UI_keyboardMap.buildLayout();
    ArrayList<String> labels = new ArrayList<>();
    for (solarchvision_bim.UI_keyboardMap.LaidOutKey k : keys) labels.add(k.label);

    assertTrue(labels.contains("SHIFT_L"));
    assertTrue(labels.contains("SHIFT_R"));
    assertTrue(labels.contains("CTRL_L"));
    assertTrue(labels.contains("ALT_L"));
    assertTrue(labels.contains("ALT_R"));
    assertTrue(labels.contains("SPACE"));
    assertTrue(labels.contains("ESC"));
    assertTrue(labels.contains("CAPSLOCK"));
    assertTrue(labels.contains("UP"));
    assertTrue(labels.contains("DELETE"));
    // Top row is now just Esc + F1-F12 - Home/End/Insert/Delete/PgUp/PgDn
    // moved into their own block directly above the arrow cluster.
    assertTrue(labels.contains("F1"));
    assertTrue(labels.contains("F12"));
    assertTrue(labels.contains("HOME"));
    assertTrue(labels.contains("END"));
    assertTrue(labels.contains("INSERT"));
    assertTrue(labels.contains("PAGE_UP"));
    assertTrue(labels.contains("PAGE_DOWN"));
    // Numpad keys use their own distinct "NUM..." labels, never the bare
    // digit/operator labels the main row already uses - no duplicate
    // same-label keys left anywhere in the layout.
    assertTrue(labels.contains("NUM7"));
    assertEquals(1, labels.stream().filter(l -> l.equals("7")).count());
    assertEquals(1, labels.stream().filter(l -> l.equals("NUM7")).count());
    // ESC appears only once - top row only, no separate nav cluster.
    assertEquals(1, labels.stream().filter(l -> l.equals("ESC")).count());
  }

  @Test
  void buildLayout_hasNoDuplicateLabelsAnywhere () {
    // "Avoid double keys" - every label in the whole layout is unique,
    // including the numpad (its tall "+"/Enter and wide "0" are each one
    // LaidOutKey now, not two stacked/side-by-side same-label keys).
    ArrayList<solarchvision_bim.UI_keyboardMap.LaidOutKey> keys = app.UI_keyboardMap.buildLayout();
    java.util.HashSet<String> seen = new java.util.HashSet<>();
    for (solarchvision_bim.UI_keyboardMap.LaidOutKey k : keys) {
      assertFalse(seen.contains(k.label), "duplicate label: " + k.label);
      seen.add(k.label);
    }
  }

  @Test
  void buildLayout_capsLockSitsBeforeA_andShiftsARightOfCapsLock () {
    ArrayList<solarchvision_bim.UI_keyboardMap.LaidOutKey> keys = app.UI_keyboardMap.buildLayout();
    solarchvision_bim.UI_keyboardMap.LaidOutKey capsLock = null;
    solarchvision_bim.UI_keyboardMap.LaidOutKey aKey = null;
    for (solarchvision_bim.UI_keyboardMap.LaidOutKey k : keys) {
      if (k.label.equals("CAPSLOCK")) capsLock = k;
      if (k.label.equals("a")) aKey = k;
    }
    assertNotNull(capsLock, "CapsLock must be laid out");
    assertNotNull(aKey, "the 'a' key must be laid out");
    assertEquals(capsLock.y, aKey.y, 0.001f, "CapsLock sits on the same row as 'a'");
    assertTrue(aKey.x > capsLock.x, "'a' must be shifted right of CapsLock");
    assertEquals(capsLock.x + capsLock.w, aKey.x, 0.001f, "'a' starts right where CapsLock ends");
  }

  @Test
  void buildLayout_fRowHasAGapAfterF4AndAfterF8_groupingIntoThreesOfFour () {
    ArrayList<solarchvision_bim.UI_keyboardMap.LaidOutKey> keys = app.UI_keyboardMap.buildLayout();
    java.util.Map<String, solarchvision_bim.UI_keyboardMap.LaidOutKey> byLabel = new java.util.HashMap<>();
    for (solarchvision_bim.UI_keyboardMap.LaidOutKey k : keys) byLabel.put(k.label, k);

    solarchvision_bim.UI_keyboardMap.LaidOutKey f4 = byLabel.get("F4");
    solarchvision_bim.UI_keyboardMap.LaidOutKey f5 = byLabel.get("F5");
    solarchvision_bim.UI_keyboardMap.LaidOutKey f8 = byLabel.get("F8");
    solarchvision_bim.UI_keyboardMap.LaidOutKey f9 = byLabel.get("F9");
    solarchvision_bim.UI_keyboardMap.LaidOutKey f1 = byLabel.get("F1");
    solarchvision_bim.UI_keyboardMap.LaidOutKey f2 = byLabel.get("F2");

    // Within a group of 4, consecutive keys touch (no gap).
    assertEquals(f1.x + f1.w, f2.x, 0.001f, "F1 and F2 must be adjacent, no gap within a group");
    // Between groups, there's a gap bigger than a plain touching seam.
    assertTrue(f5.x > f4.x + f4.w + 0.001f, "there must be a gap between F4 and F5");
    assertTrue(f9.x > f8.x + f8.w + 0.001f, "there must be a gap between F8 and F9");
  }

  @Test
  void buildLayout_navBlockSitsAboveTheArrowCluster_withAOneUnitGap () {
    // Now 3 rows of 2 (Insert/Delete, Home/PageUp, End/PageDown) instead
    // of 2 rows of 3 - 2 wider columns so each full-word label fits. And
    // now moved up one more row, leaving a 1-unit gap above the arrow
    // cluster instead of touching it.
    ArrayList<solarchvision_bim.UI_keyboardMap.LaidOutKey> keys = app.UI_keyboardMap.buildLayout();
    java.util.Map<String, solarchvision_bim.UI_keyboardMap.LaidOutKey> byLabel = new java.util.HashMap<>();
    for (solarchvision_bim.UI_keyboardMap.LaidOutKey k : keys) byLabel.put(k.label, k);

    solarchvision_bim.UI_keyboardMap.LaidOutKey insert = byLabel.get("INSERT");
    solarchvision_bim.UI_keyboardMap.LaidOutKey deleteKey = byLabel.get("DELETE");
    solarchvision_bim.UI_keyboardMap.LaidOutKey home = byLabel.get("HOME");
    solarchvision_bim.UI_keyboardMap.LaidOutKey pageUp = byLabel.get("PAGE_UP");
    solarchvision_bim.UI_keyboardMap.LaidOutKey end = byLabel.get("END");
    solarchvision_bim.UI_keyboardMap.LaidOutKey pageDown = byLabel.get("PAGE_DOWN");
    solarchvision_bim.UI_keyboardMap.LaidOutKey leftOfUp = null, up = null;
    for (solarchvision_bim.UI_keyboardMap.LaidOutKey k : keys) {
      if (k.label.equals("UP")) up = k;
      if (k.label.equals("LEFT")) leftOfUp = k; // ARROW_ROWS' left column
    }

    assertNotNull(insert); assertNotNull(deleteKey); assertNotNull(home);
    assertNotNull(pageUp); assertNotNull(end); assertNotNull(pageDown);
    assertNotNull(up, "the arrow cluster's UP key must be laid out");
    assertNotNull(leftOfUp, "the arrow cluster's LEFT key must be laid out");

    // Row pairs share an x (left column: Insert/Home/End; right column:
    // Delete/PageUp/PageDown).
    assertEquals(insert.x, home.x, 0.001f);
    assertEquals(insert.x, end.x, 0.001f);
    assertEquals(deleteKey.x, pageUp.x, 0.001f);
    assertEquals(deleteKey.x, pageDown.x, 0.001f);

    // Its own left/right edges still match the arrow cluster's (which
    // spans 3 one-unit columns starting at leftOfUp.x).
    assertEquals(leftOfUp.x, insert.x, 0.001f, "nav block's left edge must match the arrow cluster's left edge");
    assertEquals(leftOfUp.x + 3 * up.w, deleteKey.x + deleteKey.w, 0.001f,
      "nav block's right edge must match the arrow cluster's right edge");

    // 3 rows, stacked with no gap between themselves, but now a 1-unit
    // gap between the nav block's bottom row and the arrow cluster.
    assertEquals(insert.y + insert.h, home.y, 0.001f, "row 1 touches row 2");
    assertEquals(home.y + home.h, end.y, 0.001f, "row 2 touches row 3");
    assertEquals(end.y + end.h + end.h, up.y, 0.001f,
      "there must be a 1-unit (one row height) gap between the nav block and the arrow cluster");
  }

  @Test
  void keyWidthUnits_fKeysAlignF12sRightEdgeWithBackspace () {
    ArrayList<solarchvision_bim.UI_keyboardMap.LaidOutKey> keys = app.UI_keyboardMap.buildLayout();
    java.util.Map<String, solarchvision_bim.UI_keyboardMap.LaidOutKey> byLabel = new java.util.HashMap<>();
    for (solarchvision_bim.UI_keyboardMap.LaidOutKey k : keys) byLabel.put(k.label, k);

    solarchvision_bim.UI_keyboardMap.LaidOutKey f12 = byLabel.get("F12");
    solarchvision_bim.UI_keyboardMap.LaidOutKey backspace = byLabel.get("BACKSPACE");
    assertNotNull(f12); assertNotNull(backspace);

    assertEquals(backspace.x + backspace.w, f12.x + f12.w, 0.001f,
      "F12's right edge must align with Backspace's right edge");
  }

  @Test
  void isNavBlockLabel_coversExactlyTheSixNavBlockKeys () {
    for (String label : new String[]{"INSERT", "DELETE", "HOME", "END", "PAGE_UP", "PAGE_DOWN"}) {
      assertTrue(app.UI_keyboardMap.isNavBlockLabel(label), label + " must be a nav-block label");
    }
    for (String label : new String[]{"ESC", "UP", "F1", "CAPSLOCK", "NUM_LOCK"}) {
      assertFalse(app.UI_keyboardMap.isNavBlockLabel(label), label + " must NOT be a nav-block label");
    }
  }

  @Test
  void buildLayout_arrowClusterBottomAlignsWithSpaceBottom () {
    ArrayList<solarchvision_bim.UI_keyboardMap.LaidOutKey> keys = app.UI_keyboardMap.buildLayout();
    solarchvision_bim.UI_keyboardMap.LaidOutKey space = null, down = null;
    for (solarchvision_bim.UI_keyboardMap.LaidOutKey k : keys) {
      if (k.label.equals("SPACE")) space = k;
      if (k.label.equals("DOWN")) down = k; // ARROW_ROWS' bottom row
    }
    assertNotNull(space); assertNotNull(down);
    assertEquals(space.y + space.h, down.y + down.h, 0.001f,
      "the arrow cluster's bottom row must end on the same line as Space");
  }

  @Test
  void buildLayout_escIsAtTheTopLeftOfTheOverlay () {
    ArrayList<solarchvision_bim.UI_keyboardMap.LaidOutKey> keys = app.UI_keyboardMap.buildLayout();
    solarchvision_bim.UI_keyboardMap.LaidOutKey esc = null;
    for (solarchvision_bim.UI_keyboardMap.LaidOutKey k : keys) {
      if (k.label.equals("ESC")) esc = k;
    }
    assertNotNull(esc, "ESC must be laid out somewhere");
    for (solarchvision_bim.UI_keyboardMap.LaidOutKey k : keys) {
      assertTrue(esc.x <= k.x, "ESC must be at least as far left as every other key");
      assertTrue(esc.y <= k.y, "ESC must be at least as far up as every other key");
    }
  }

  @Test
  void keyAt_findsTheKeyContainingAPoint_andNullOutsideAll () {
    ArrayList<solarchvision_bim.UI_keyboardMap.LaidOutKey> keys = app.UI_keyboardMap.buildLayout();
    solarchvision_bim.UI_keyboardMap.LaidOutKey first = keys.get(0);
    float cx = first.x + first.w / 2;
    float cy = first.y + first.h / 2;

    assertSame(first, app.UI_keyboardMap.keyAt(keys, cx, cy));
    assertNull(app.UI_keyboardMap.keyAt(keys, -9999, -9999));
  }

  @Test
  void isInsideBounds_falseWhenNotVisible_regardlessOfPoint () {
    app.UI_keyboardMap.visible = false;
    assertFalse(app.UI_keyboardMap.isInsideBounds(0, 0));
  }

  @Test
  void isInsideBounds_trueInsideTheKeyboardsOwnBox_falseFarOutside () {
    app.UI_keyboardMap.visible = true;
    float[] box = app.UI_keyboardMap.boundingBox();
    float midX = (box[0] + box[2]) / 2;
    float midY = (box[1] + box[3]) / 2;

    assertTrue(app.UI_keyboardMap.isInsideBounds(midX, midY));
    assertFalse(app.UI_keyboardMap.isInsideBounds(box[2] + 10000, box[3] + 10000));
  }

  @Test
  void describeHoveredKey_null_returnsEmpty () {
    assertTrue(app.UI_keyboardMap.describeHoveredKey(null).isEmpty());
  }

  @Test
  void describeHoveredKey_ordinaryKey_looksUpItsOwnBindings () {
    solarchvision_bim.UI_keyboardMap.LaidOutKey equalsKey = app.UI_keyboardMap.new LaidOutKey("=", 0, 0, 10, 10);
    ArrayList<String> lines = app.UI_keyboardMap.describeHoveredKey(equalsKey);
    assertEquals(3, lines.size());
  }

  @Test
  void describeHoveredKey_shiftAndCtrlKeys_aggregateAcrossTheWholeTable_bothLeftAndRight () {
    // Both Shift keys behave the same, and both Ctrl keys behave the
    // same - the real dispatch code never distinguishes left/right for
    // either (e.isShiftDown()/e.isControlDown()), so the overlay doesn't
    // either.
    solarchvision_bim.UI_keyboardMap.LaidOutKey shiftL = app.UI_keyboardMap.new LaidOutKey("SHIFT_L", 0, 0, 10, 10);
    solarchvision_bim.UI_keyboardMap.LaidOutKey shiftR = app.UI_keyboardMap.new LaidOutKey("SHIFT_R", 0, 0, 10, 10);
    solarchvision_bim.UI_keyboardMap.LaidOutKey ctrlL = app.UI_keyboardMap.new LaidOutKey("CTRL_L", 0, 0, 10, 10);
    solarchvision_bim.UI_keyboardMap.LaidOutKey ctrlR = app.UI_keyboardMap.new LaidOutKey("CTRL_R", 0, 0, 10, 10);

    ArrayList<String> shiftLLines = app.UI_keyboardMap.describeHoveredKey(shiftL);
    ArrayList<String> shiftRLines = app.UI_keyboardMap.describeHoveredKey(shiftR);
    ArrayList<String> ctrlLLines = app.UI_keyboardMap.describeHoveredKey(ctrlL);
    ArrayList<String> ctrlRLines = app.UI_keyboardMap.describeHoveredKey(ctrlR);

    assertTrue(shiftLLines.contains("Shift+s: Next Sky Scenario"));
    assertEquals(shiftLLines, shiftRLines, "Shift_L and Shift_R must show the identical list");
    assertFalse(ctrlLLines.isEmpty());
    assertEquals(ctrlLLines, ctrlRLines, "Ctrl_L and Ctrl_R must show the identical list");
  }

  @Test
  void describeHoveredKey_altGr_isInert_unlikeTheOrdinaryLeftAlt () {
    // ALT_L ("Alt") aggregates every Alt binding; ALT_R ("AltGr") is a
    // genuinely different physical key with nothing bound to it, so it
    // stays empty even though Shift/Ctrl's right-hand keys no longer do.
    solarchvision_bim.UI_keyboardMap.LaidOutKey altL = app.UI_keyboardMap.new LaidOutKey("ALT_L", 0, 0, 10, 10);
    solarchvision_bim.UI_keyboardMap.LaidOutKey altR = app.UI_keyboardMap.new LaidOutKey("ALT_R", 0, 0, 10, 10);
    assertFalse(app.UI_keyboardMap.describeHoveredKey(altL).isEmpty());
    assertTrue(app.UI_keyboardMap.describeHoveredKey(altR).isEmpty());
  }

  @Test
  void keyDisplayText_altRIsLabelledAltGr_distinctFromTheLeftAlt () {
    assertEquals("Alt", app.UI_keyboardMap.keyDisplayText("ALT_L"));
    assertEquals("AltGr", app.UI_keyboardMap.keyDisplayText("ALT_R"));
  }

  @Test
  void keyDisplayText_namedKeysUseTheirFullWord () {
    assertEquals("Backspace", app.UI_keyboardMap.keyDisplayText("BACKSPACE"));
    assertEquals("Insert", app.UI_keyboardMap.keyDisplayText("INSERT"));
    assertEquals("Delete", app.UI_keyboardMap.keyDisplayText("DELETE"));
    assertEquals("Page\nUp", app.UI_keyboardMap.keyDisplayText("PAGE_UP"));
    assertEquals("Page\nDown", app.UI_keyboardMap.keyDisplayText("PAGE_DOWN"));
  }

  @Test
  void buildLayout_backspaceBackslashEnterAndRightShift_shareTheSameRightEdge () {
    // Backspace, "\", Enter and right-Shift are each the last key of
    // their own row, and are each sized so that row totals exactly 16
    // units - their four right edges must land on the same column.
    ArrayList<solarchvision_bim.UI_keyboardMap.LaidOutKey> keys = app.UI_keyboardMap.buildLayout();
    java.util.Map<String, solarchvision_bim.UI_keyboardMap.LaidOutKey> byLabel = new java.util.HashMap<>();
    for (solarchvision_bim.UI_keyboardMap.LaidOutKey k : keys) byLabel.put(k.label, k);

    solarchvision_bim.UI_keyboardMap.LaidOutKey backspace = byLabel.get("BACKSPACE");
    solarchvision_bim.UI_keyboardMap.LaidOutKey backslash = byLabel.get("\\");
    solarchvision_bim.UI_keyboardMap.LaidOutKey enter = byLabel.get("ENTER");
    solarchvision_bim.UI_keyboardMap.LaidOutKey shiftR = byLabel.get("SHIFT_R");
    assertNotNull(backspace); assertNotNull(backslash); assertNotNull(enter); assertNotNull(shiftR);

    float rightEdge = backspace.x + backspace.w;
    assertEquals(rightEdge, backslash.x + backslash.w, 0.001f, "\\'s right edge must match Backspace's");
    assertEquals(rightEdge, enter.x + enter.w, 0.001f, "Enter's right edge must match Backspace's");
    assertEquals(rightEdge, shiftR.x + shiftR.w, 0.001f, "right-Shift's right edge must match Backspace's");
  }

  @Test
  void keyWidthUnits_ctrlAndAltAllMatchLeftShift () {
    float shiftLWidth = app.UI_keyboardMap.keyWidthUnits("SHIFT_L");
    assertEquals(shiftLWidth, app.UI_keyboardMap.keyWidthUnits("CTRL_L"), 0.001f);
    assertEquals(shiftLWidth, app.UI_keyboardMap.keyWidthUnits("CTRL_R"), 0.001f);
    assertEquals(shiftLWidth, app.UI_keyboardMap.keyWidthUnits("ALT_L"), 0.001f);
    assertEquals(shiftLWidth, app.UI_keyboardMap.keyWidthUnits("ALT_R"), 0.001f);
  }

  @Test
  void keyWidthUnits_escMatchesShiftAndAltWidth () {
    float shiftLWidth = app.UI_keyboardMap.keyWidthUnits("SHIFT_L");
    assertEquals(shiftLWidth, app.UI_keyboardMap.keyWidthUnits("ESC"), 0.001f);
    assertEquals(app.UI_keyboardMap.keyWidthUnits("ALT_L"), app.UI_keyboardMap.keyWidthUnits("ESC"), 0.001f);
  }

  @Test
  void buildLayout_rightCtrlRightEdge_alignsWithTheBackspaceGroup () {
    ArrayList<solarchvision_bim.UI_keyboardMap.LaidOutKey> keys = app.UI_keyboardMap.buildLayout();
    java.util.Map<String, solarchvision_bim.UI_keyboardMap.LaidOutKey> byLabel = new java.util.HashMap<>();
    for (solarchvision_bim.UI_keyboardMap.LaidOutKey k : keys) byLabel.put(k.label, k);

    solarchvision_bim.UI_keyboardMap.LaidOutKey backspace = byLabel.get("BACKSPACE");
    solarchvision_bim.UI_keyboardMap.LaidOutKey ctrlR = byLabel.get("CTRL_R");
    assertNotNull(backspace); assertNotNull(ctrlR);

    assertEquals(backspace.x + backspace.w, ctrlR.x + ctrlR.w, 0.001f,
      "right-Ctrl's right edge must align with the Backspace/\\/Enter/right-Shift group");
  }

  @Test
  void keyShiftedVariant_matchesTheRequestedSymbolPairs () {
    assertEquals("~", app.UI_keyboardMap.keyShiftedVariant("`"));
    assertEquals(":", app.UI_keyboardMap.keyShiftedVariant(";"));
    assertEquals("<", app.UI_keyboardMap.keyShiftedVariant(","));
    assertEquals(">", app.UI_keyboardMap.keyShiftedVariant("."));
    assertEquals("?", app.UI_keyboardMap.keyShiftedVariant("/"));
    String topRow = "!@#$%^&*()_+{}|<>?";
    String bottomRow = "1234567890-=[]\\,./";
    assertEquals(topRow.length(), bottomRow.length());
    for (int i = 0; i < bottomRow.length(); i++) {
      String base = String.valueOf(bottomRow.charAt(i));
      String expectedShifted = String.valueOf(topRow.charAt(i));
      assertEquals(expectedShifted, app.UI_keyboardMap.keyShiftedVariant(base),
        "shift variant of '" + base + "'");
    }
  }

  @Test
  void keyShiftedVariant_excludesLettersAndSpecialKeys () {
    // "excluding alphabet" - no letter gets a second line, and neither
    // do the named special keys (Enter/Tab/Shift/...).
    assertNull(app.UI_keyboardMap.keyShiftedVariant("a"));
    assertNull(app.UI_keyboardMap.keyShiftedVariant("z"));
    assertNull(app.UI_keyboardMap.keyShiftedVariant("ENTER"));
    assertNull(app.UI_keyboardMap.keyShiftedVariant("SPACE"));
    assertNull(app.UI_keyboardMap.keyShiftedVariant("CAPSLOCK"));
  }

  @Test
  void keyShiftedVariant_numpadKeysAreExcluded_sinceTheyHaveNoPrintedShiftSymbol () {
    // The numpad's own "NUM..." labels never collide with keyShiftedVariant()'s
    // plain-character keys, so a numpad "7" or "/" never gets a two-line cap.
    assertNull(app.UI_keyboardMap.keyShiftedVariant("NUM7"));
    assertNull(app.UI_keyboardMap.keyShiftedVariant("NUM_DIV"));
  }

  @Test
  void describeHoveredKey_numpadKey_showsTheSameBindingsAsItsMainRowEquivalent () {
    solarchvision_bim.UI_keyboardMap.LaidOutKey num1 = app.UI_keyboardMap.new LaidOutKey("NUM1", 0, 0, 10, 10);
    solarchvision_bim.UI_keyboardMap.LaidOutKey plain1 = app.UI_keyboardMap.new LaidOutKey("1", 0, 0, 10, 10);
    assertEquals(app.UI_keyboardMap.describeHoveredKey(plain1), app.UI_keyboardMap.describeHoveredKey(num1));
    assertFalse(app.UI_keyboardMap.describeHoveredKey(num1).isEmpty());
  }

  @Test
  void describeHoveredKey_numLock_isInert () {
    solarchvision_bim.UI_keyboardMap.LaidOutKey numLock = app.UI_keyboardMap.new LaidOutKey("NUM_LOCK", 0, 0, 10, 10);
    assertTrue(app.UI_keyboardMap.describeHoveredKey(numLock).isEmpty());
  }

  @Test
  void keyDisplayText_arrowKeys_useAsciiSafeGlyphs_notUnrenderableUnicode () {
    // The original Unicode arrow glyphs (↑↓←→) silently failed to render
    // as actual key-cap text - replaced with plain ASCII that any font
    // can draw.
    assertEquals("^", app.UI_keyboardMap.keyDisplayText("UP"));
    assertEquals("v", app.UI_keyboardMap.keyDisplayText("DOWN"));
    assertEquals("<", app.UI_keyboardMap.keyDisplayText("LEFT"));
    assertEquals(">", app.UI_keyboardMap.keyDisplayText("RIGHT"));
    for (String glyph : new String[]{"^", "v", "<", ">"}) {
      assertFalse(glyph.codePoints().anyMatch(cp -> cp > 127), "must be plain ASCII");
    }
  }

  // ================= show()/hide() - without ever reaching get()/image() ===

  @Test
  void show_whenAlreadyVisible_isANoOp_andNeverReachesGet () {
    app.UI_keyboardMap.visible = true;
    assertDoesNotThrow(() -> app.UI_keyboardMap.show());
    assertTrue(app.UI_keyboardMap.visible);
    assertNull(app.UI_keyboardMap.keyboardMap_pre_screen, "must not have captured anything");
  }

  // menuDropdownStillOnScreen() is show()'s own guard for the "opened via
  // the 'Show Keyboard Map' menu item while the dropdown is still the
  // last thing actually painted on screen" bug: runSelectedItem() (which
  // fires this action) runs before UI_menuBar.deselect() restores the
  // screen, so selected_parent != -1 at the moment show() is called.
  // Split out of show() specifically so this condition is checkable
  // without going anywhere near the real get()/image() calls show()
  // itself can't be exercised through here (see this file's own header
  // comment).

  @Test
  void menuDropdownStillOnScreen_falseWhenNoMenuIsOpen () {
    app.UI_menuBar.selected_parent = -1;
    app.pre_screen = app.createImage(1, 1, app.RGB);
    assertFalse(app.UI_keyboardMap.menuDropdownStillOnScreen());
  }

  @Test
  void menuDropdownStillOnScreen_falseWhenMenuOpenButNoPreScreenCapturedYet () {
    app.UI_menuBar.selected_parent = 0;
    app.pre_screen = null;
    assertFalse(app.UI_keyboardMap.menuDropdownStillOnScreen());
  }

  @Test
  void menuDropdownStillOnScreen_trueWhenAMenuIsOpenAndPreScreenIsCaptured () {
    app.UI_menuBar.selected_parent = 0;
    app.pre_screen = app.createImage(1, 1, app.RGB);
    assertTrue(app.UI_keyboardMap.menuDropdownStillOnScreen());
  }

  @Test
  void hide_withNoCapturedPreScreen_justClearsVisible_andNeverReachesImage () {
    app.UI_keyboardMap.visible = true;
    app.UI_keyboardMap.keyboardMap_pre_screen = null;
    assertDoesNotThrow(() -> app.UI_keyboardMap.hide());
    assertFalse(app.UI_keyboardMap.visible);
  }

  @Test
  void hide_whenAlreadyClosed_isANoOp () {
    app.UI_keyboardMap.visible = false;
    assertDoesNotThrow(() -> app.UI_keyboardMap.hide());
    assertFalse(app.UI_keyboardMap.visible);
  }

  // ================= keyPressed() wiring =====================================

  @Test
  void keyPressed_anyKeyWhileVisible_closesItAndIsConsumed () {
    app.UI_keyboardMap.visible = true;
    app.X_clicked = 999; // sentinel - the close branch returns before this would change
    app.Y_clicked = 999;

    assertDoesNotThrow(() -> app.keyPressed(keyEvent('a', 0)));

    assertFalse(app.UI_keyboardMap.visible);
  }

  @Test
  void keyPressed_questionMarkWhileVisible_justClosesIt_likeAnyOtherKey () {
    app.UI_keyboardMap.visible = true;
    assertDoesNotThrow(() -> app.keyPressed(keyEvent('?', 0)));
    assertFalse(app.UI_keyboardMap.visible);
  }

  @Test
  void keyPressed_escWhileVisible_closesItAndZeroesKey_soItDoesNotAlsoQuitTheSketch () {
    // Regression: closing the overlay with Esc must ALSO zero out `key`,
    // the same fix (and for the same reason) the isInProgress() branch
    // and the ordinary Esc-cascade branch already apply elsewhere in
    // this file (see KeyPressedGuardsTest.java's
    // escWhileInProgress_zeroesKeyEvenWithNoActiveWindow) - otherwise
    // PApplet's own post-keyPressed() default behavior (quit the whole
    // sketch on Esc) fires right after this method returns, so pressing
    // Esc to dismiss the keyboard map was also exiting the program.
    //
    // `key` is a plain PApplet field, not something a direct, synthetic
    // call to keyPressed(e) populates on its own (only PApplet's real
    // handleKeyEvent() dispatch does that) - so it's set here exactly as
    // it would be immediately before a real keyPressed() call, same
    // convention KeyPressedGuardsTest.java already uses.
    app.UI_keyboardMap.visible = true;
    app.key = app.ESC;

    assertDoesNotThrow(() -> app.keyPressed(keyEvent((char) app.ESC, 0)));

    assertFalse(app.UI_keyboardMap.visible, "Esc must still close the overlay");
    assertEquals(0, app.key, "Esc must be zeroed so PApplet's own quit-on-Esc default can't fire");
  }

  @Test
  void keyPressed_nonEscKeyWhileVisible_leavesKeyUntouched () {
    app.UI_keyboardMap.visible = true;
    app.key = 'a';

    assertDoesNotThrow(() -> app.keyPressed(keyEvent('a', 0)));

    assertFalse(app.UI_keyboardMap.visible);
    assertEquals('a', app.key, "only Esc gets zeroed - an ordinary key must be left alone");
  }

  @Test
  void keyPressed_questionMarkWhileTypingACommand_doesNotOpenIt () {
    app.typeUserCommand = 1;
    assertDoesNotThrow(() -> app.keyPressed(keyEvent('?', 0)));
    assertFalse(app.UI_keyboardMap.visible);
  }

  @Test
  void keyPressed_ctrlQuestionMark_doesNotOpenIt () {
    // Guards on !e.isControlDown() specifically so a real Ctrl-combo
    // that happens to also produce '?' on some layout can never
    // accidentally open this instead of whatever Ctrl+<key> does.
    assertDoesNotThrow(() -> app.keyPressed(keyEvent('?', Event.CTRL)));
    assertFalse(app.UI_keyboardMap.visible);
  }

  // ================= mouseClicked() wiring ===================================

  @Test
  void mouseClicked_whileVisible_insideItsBounds_doesNothing () {
    app.UI_keyboardMap.visible = true;
    float[] box = app.UI_keyboardMap.boundingBox();
    app.mouseX = (int) ((box[0] + box[2]) / 2);
    app.mouseY = (int) ((box[1] + box[3]) / 2);

    assertDoesNotThrow(() -> app.mouseClicked());

    assertTrue(app.UI_keyboardMap.visible, "a click inside the keyboard must not close it");
  }

  @Test
  void mouseClicked_whileVisible_outsideItsBounds_closesIt () {
    app.UI_keyboardMap.visible = true;
    float[] box = app.UI_keyboardMap.boundingBox();
    app.mouseX = (int) (box[2] + 10000);
    app.mouseY = (int) (box[3] + 10000);

    assertDoesNotThrow(() -> app.mouseClicked());

    assertFalse(app.UI_keyboardMap.visible);
  }

  // ================= "Guide" menu wiring ======================================

  @Test
  void showKeyboardMapAction_isRegistered () {
    assertTrue(app.allActions.containsKey("show keyboard map"));
  }

  @Test
  void guideMenu_existsInTheMenuBarWithTheShowKeyboardMapItem () {
    boolean found = false;
    for (String[] parentRow : app.UI_menuBar.Items) {
      if (parentRow[0].equals("Guide")) {
        found = true;
        assertEquals("Show Keyboard Map", parentRow[1]);
      }
    }
    assertTrue(found, "no \"Guide\" parent found in UI_menuBar.Items");
  }

  @Test
  void guideMenu_hasAFreeUnusedAcceleratorLetter () {
    boolean found = false;
    for (String[] shortcut : app.UI_menuBar.PARENT_SHORTCUTS) {
      if (shortcut[1].equals("Guide")) {
        found = true;
        assertEquals("G", shortcut[0]);
      }
    }
    assertTrue(found, "no Alt+<letter> shortcut registered for \"Guide\"");
  }
}
