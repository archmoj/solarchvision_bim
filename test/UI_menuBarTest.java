import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// draw()/drawParentTab()/drawChildMenu()/drawChildRow() touch live
// rendering and mouse state (fill(), text(), mouseX/mouseY, ...) and
// aren't unit-testable as-is (see test/README.md) - not covered here.
// What's covered instead: moveSelection() (the shared Up/Down/Left/Right
// logic, used by both keyPressed() and the held-key repeat) and the
// processHeldKey()/keyReleased() bookkeeping around it.
class UI_menuBarTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.UI_menuBar.Items = new String[][] {
      {"File", "New", "Open", "Save"},
      {"Edit", "Copy", "Paste"},
      {"View", "Zoom In", "—", "Zoom Out"}
    };
  }

  // ================= moveSelection - child (Up/Down) ===========================

  @Test
  void moveSelection_downMovesToTheNextChild () {
    app.UI_menuBar.selected_parent = 0;
    app.UI_menuBar.selected_child = 1;
    app.UI_menuBar.moveSelection(app.DOWN);
    assertEquals(2, app.UI_menuBar.selected_child);
  }

  @Test
  void moveSelection_downStaysOnTheLastChild () {
    app.UI_menuBar.selected_parent = 0;
    app.UI_menuBar.selected_child = 3; // "Save", the last child
    app.UI_menuBar.moveSelection(app.DOWN);
    assertEquals(3, app.UI_menuBar.selected_child);
  }

  @Test
  void moveSelection_upMovesToThePreviousChild () {
    app.UI_menuBar.selected_parent = 0;
    app.UI_menuBar.selected_child = 2;
    app.UI_menuBar.moveSelection(app.UP);
    assertEquals(1, app.UI_menuBar.selected_child);
  }

  @Test
  void moveSelection_upStopsAtTheParentTabItself () {
    app.UI_menuBar.selected_parent = 0;
    app.UI_menuBar.selected_child = 1;
    app.UI_menuBar.moveSelection(app.UP);
    assertEquals(0, app.UI_menuBar.selected_child); // no child selected - just the tab
  }

  @Test
  void moveSelection_downSkipsOverADivider () {
    app.UI_menuBar.selected_parent = 2; // "View": Zoom In(1), divider(2), Zoom Out(3)
    app.UI_menuBar.selected_child = 1;
    app.UI_menuBar.moveSelection(app.DOWN);
    assertEquals(3, app.UI_menuBar.selected_child); // lands on Zoom Out, not the divider
  }

  // ================= moveSelection - parent (Left/Right) =======================

  @Test
  void moveSelection_rightMovesToTheNextParentAndClampsChildIntoItsRange () {
    app.UI_menuBar.selected_parent = 0; // "File" has 4 rows (index 0..3)
    app.UI_menuBar.selected_child = 3;  // "Save"
    app.UI_menuBar.moveSelection(app.RIGHT);
    assertEquals(1, app.UI_menuBar.selected_parent); // "Edit"
    assertEquals(2, app.UI_menuBar.selected_child);  // clamped down: Edit only has index 0..2
  }

  @Test
  void moveSelection_rightStaysOnTheLastParent () {
    app.UI_menuBar.selected_parent = 2; // "View", the last parent
    app.UI_menuBar.selected_child = 1;
    app.UI_menuBar.moveSelection(app.RIGHT);
    assertEquals(2, app.UI_menuBar.selected_parent);
  }

  @Test
  void moveSelection_rightSkipsOverADividerInTheNewParent () {
    app.UI_menuBar.selected_parent = 1; // "Edit"
    app.UI_menuBar.selected_child = 2;  // "Paste"
    app.UI_menuBar.moveSelection(app.RIGHT);
    assertEquals(2, app.UI_menuBar.selected_parent); // "View": index 2 is a divider there
    assertEquals(1, app.UI_menuBar.selected_child);  // lands on "Zoom In" instead
  }

  @Test
  void moveSelection_leftMovesToThePreviousParentAndClampsChildIntoItsRange () {
    app.UI_menuBar.selected_parent = 2; // "View" has 4 rows (index 0..3)
    app.UI_menuBar.selected_child = 3;  // "Zoom Out"
    app.UI_menuBar.moveSelection(app.LEFT);
    assertEquals(1, app.UI_menuBar.selected_parent); // "Edit"
    assertEquals(2, app.UI_menuBar.selected_child);  // clamped down: Edit only has index 0..2
  }

  @Test
  void moveSelection_leftStaysOnTheFirstParent () {
    app.UI_menuBar.selected_parent = 0;
    app.UI_menuBar.selected_child = 1;
    app.UI_menuBar.moveSelection(app.LEFT);
    assertEquals(0, app.UI_menuBar.selected_parent);
  }

  // ================= keyReleased / processHeldKey ==============================

  @Test
  void processHeldKey_doesNothingWhenTheMenuIsClosed () {
    app.UI_menuBar.selected_parent = -1;
    app.UI_menuBar.navKeyHeld = true;
    app.UI_menuBar.navKeyCode = app.DOWN;
    app.UI_menuBar.navKeyFrameCounter = app.UI_menuBar.NAV_KEY_INITIAL_DELAY_FRAMES;

    app.UI_menuBar.processHeldKey();

    assertEquals(-1, app.UI_menuBar.selected_parent); // unchanged - menu isn't open
  }

  @Test
  void processHeldKey_doesNotFireBeforeTheInitialDelayElapses () {
    app.UI_menuBar.selected_parent = 0;
    app.UI_menuBar.selected_child = 0;
    app.UI_menuBar.navKeyHeld = true;
    app.UI_menuBar.navKeyCode = app.DOWN;
    app.UI_menuBar.navKeyFrameCounter = 0;
    app.UI_menuBar.navKeyRepeating = false;

    for (int i = 0; i < app.UI_menuBar.NAV_KEY_INITIAL_DELAY_FRAMES - 1; i++) {
      app.UI_menuBar.processHeldKey();
    }
    assertEquals(0, app.UI_menuBar.selected_child);

    app.UI_menuBar.processHeldKey(); // the delay-th call - now it fires
    assertEquals(1, app.UI_menuBar.selected_child);
    assertTrue(app.UI_menuBar.navKeyRepeating);
  }

  @Test
  void processHeldKey_repeatsEveryFrameAfterTheInitialDelay () {
    app.UI_menuBar.selected_parent = 0;
    app.UI_menuBar.selected_child = 0;
    app.UI_menuBar.navKeyHeld = true;
    app.UI_menuBar.navKeyCode = app.DOWN;
    app.UI_menuBar.navKeyFrameCounter = app.UI_menuBar.NAV_KEY_INITIAL_DELAY_FRAMES - 1;
    app.UI_menuBar.navKeyRepeating = false;

    app.UI_menuBar.processHeldKey(); // crosses the initial delay - fires
    assertEquals(1, app.UI_menuBar.selected_child);

    app.UI_menuBar.processHeldKey(); // NAV_KEY_REPEAT_FRAMES == 1 - fires again immediately
    assertEquals(2, app.UI_menuBar.selected_child);
  }

  @Test
  void keyReleased_clearsNavKeyHeldOnlyWhenTheSameKeyComesBackUp () {
    app.UI_menuBar.navKeyHeld = true;
    app.UI_menuBar.navKeyCode = app.DOWN;

    app.key = (char) app.CODED;
    app.keyCode = app.UP; // a DIFFERENT key releasing
    app.UI_menuBar.keyReleased();
    assertTrue(app.UI_menuBar.navKeyHeld);

    app.keyCode = app.DOWN; // the actual held key releasing
    app.UI_menuBar.keyReleased();
    assertFalse(app.UI_menuBar.navKeyHeld);
  }

  @Test
  void keyReleased_ignoresAnUncodedKeyRelease () {
    app.UI_menuBar.navKeyHeld = true;
    app.UI_menuBar.navKeyCode = app.DOWN;

    app.key = (char) 'a'; // not a CODED key at all (e.g. Enter isn't tracked as held)
    app.UI_menuBar.keyReleased();
    assertTrue(app.UI_menuBar.navKeyHeld);
  }

  @Test
  void processHeldKey_doesNothingWhenNotHeld () {
    app.UI_menuBar.selected_parent = 0;
    app.UI_menuBar.selected_child = 0;
    app.UI_menuBar.navKeyHeld = false;
    app.UI_menuBar.navKeyCode = app.DOWN;
    app.UI_menuBar.navKeyFrameCounter = app.UI_menuBar.NAV_KEY_INITIAL_DELAY_FRAMES;

    app.UI_menuBar.processHeldKey();

    assertEquals(0, app.UI_menuBar.selected_child); // unchanged - key isn't held
  }

  @Test
  void processHeldKey_repeatingPastTheLastChildStaysClampedAndDoesNotThrow () {
    app.UI_menuBar.selected_parent = 0; // "File" has 4 rows (index 0..3)
    app.UI_menuBar.selected_child = 3;  // already at the last row
    app.UI_menuBar.navKeyHeld = true;
    app.UI_menuBar.navKeyCode = app.DOWN;
    app.UI_menuBar.navKeyFrameCounter = 0;
    app.UI_menuBar.navKeyRepeating = false;

    assertDoesNotThrow(() -> {
      for (int i = 0; i < 50; i++) app.UI_menuBar.processHeldKey();
    });
    assertEquals(3, app.UI_menuBar.selected_child); // clamped, never runs off the end
  }

  // ================= stepChild / clampChild (direct) ============================

  @Test
  void stepChild_skipsDividersAndFindsTheNextRealItem () {
    // "View": Zoom In(1), divider(2), Zoom Out(3)
    assertEquals(3, app.UI_menuBar.stepChild(2, 1, 1));
  }

  @Test
  void stepChild_returnsFromUnchangedWhenThereIsNowhereFurtherToGo () {
    assertEquals(3, app.UI_menuBar.stepChild(0, 3, 1)); // "File", already at the last row
  }

  @Test
  void clampChild_leavesAValidIndexUnchanged () {
    assertEquals(2, app.UI_menuBar.clampChild(1, 2)); // "Edit" index 2 is "Paste", not a divider
  }

  @Test
  void clampChild_clampsAnOutOfRangeIndexDownToTheLastRow () {
    assertEquals(2, app.UI_menuBar.clampChild(1, 10)); // "Edit" only has index 0..2
  }

  @Test
  void clampChild_skipsBackToTheNearestRealItemWhenLandingOnADivider () {
    assertEquals(1, app.UI_menuBar.clampChild(2, 2)); // "View" index 2 is the divider
  }

  @Test
  void clampChild_searchesForwardWhenBackwardOnlyReachesTheParentTab () {
    // "Tools": divider(1), divider(2), Cut(3) - stepping back from index 2 only
    // reaches the tab itself (0), so clampChild must search forward instead.
    app.UI_menuBar.Items = new String[][] { {"Tools", "—", "—", "Cut"} };
    assertEquals(3, app.UI_menuBar.clampChild(0, 2));
  }

  @Test
  void clampChild_fallsBackToTheParentTabWhenEveryChildIsADivider () {
    app.UI_menuBar.Items = new String[][] { {"Empty", "—", "—", "—"} };
    assertEquals(0, app.UI_menuBar.clampChild(0, 2));
  }

  // ================= isHoverSuppressed ===========================================

  @Test
  void isHoverSuppressed_falseBeforeAnyKeyboardNavigation () {
    assertFalse(app.UI_menuBar.isHoverSuppressed());
  }

  @Test
  void isHoverSuppressed_trueRightAfterMoveSelectionWithoutTheMouseMoving () {
    app.UI_X_moved = 50;
    app.UI_Y_moved = 60;
    app.UI_menuBar.selected_parent = 0;
    app.UI_menuBar.moveSelection(app.DOWN);

    assertTrue(app.UI_menuBar.isHoverSuppressed());
  }

  @Test
  void isHoverSuppressed_falseOnceTheMouseActuallyMoves () {
    app.UI_X_moved = 50;
    app.UI_Y_moved = 60;
    app.UI_menuBar.selected_parent = 0;
    app.UI_menuBar.moveSelection(app.DOWN);

    app.UI_X_moved = 999; // the mouse moved since the key press

    assertFalse(app.UI_menuBar.isHoverSuppressed());
  }

  // ================= runSelectedItem =============================================

  @Test
  void runSelectedItem_doesNothingWhenTheMenuIsClosed () {
    boolean[] ran = {false};
    app.allActions = new java.util.HashMap<>();
    app.allActions.put("copy", (args) -> ran[0] = true);

    app.UI_menuBar.selected_parent = -1;
    app.UI_menuBar.selected_child = 1;
    app.UI_menuBar.runSelectedItem();

    assertFalse(ran[0]);
  }

  @Test
  void runSelectedItem_doesNothingWhenOnlyTheParentTabIsSelected () {
    boolean[] ran = {false};
    app.allActions = new java.util.HashMap<>();
    app.allActions.put("copy", (args) -> ran[0] = true);

    app.UI_menuBar.selected_parent = 1; // "Edit"
    app.UI_menuBar.selected_child = 0;  // the tab itself, not a real item
    app.UI_menuBar.runSelectedItem();

    assertFalse(ran[0]);
  }

  @Test
  void runSelectedItem_runsTheRegisteredActionForTheSelectedChild () {
    boolean[] ran = {false};
    app.allActions = new java.util.HashMap<>();
    app.allActions.put("copy", (args) -> ran[0] = true);

    app.UI_menuBar.selected_parent = 1; // "Edit"
    app.UI_menuBar.selected_child = 1;  // "Copy"
    app.UI_menuBar.runSelectedItem();

    assertTrue(ran[0]);
  }

  @Test
  void runSelectedItem_doesNotThrowWhenNoActionIsRegisteredForTheItem () {
    app.allActions = new java.util.HashMap<>(); // "paste" intentionally not registered

    app.UI_menuBar.selected_parent = 1; // "Edit"
    app.UI_menuBar.selected_child = 2;  // "Paste"

    assertDoesNotThrow(() -> app.UI_menuBar.runSelectedItem());
  }

  // ================= cleanDividersFromParent ====================================
  // Every parent's own Items[i] gets its dividers stripped out once, up
  // front (constructor/populateLayerMenu(), uiMenuBar.pde) rather than
  // skipped over repeatedly while drawing or navigating. These tests
  // call cleanDividersFromParent() directly on a hand-built raw array,
  // the same way StarTilingTest.java tests appendStarTransform_UV()
  // directly rather than only through the tiling commands that use it.

  @Test
  void cleanDividersFromParent_stripsDividersAndRecordsWhereEachOneSat () {
    app.UI_menuBar.Items[0] = new String[]{"File", "New", "—", "Open", "Save", "—", "Quit"};
    app.UI_menuBar.cleanDividersFromParent(0);

    assertArrayEquals(new String[]{"File", "New", "Open", "Save", "Quit"}, app.UI_menuBar.Items[0]);
    assertFalse(app.UI_menuBar.childDividerBeforeRow[0][1]); // "New" - nothing above it
    assertTrue(app.UI_menuBar.childDividerBeforeRow[0][2]);  // "Open" - a divider sat right above it
    assertFalse(app.UI_menuBar.childDividerBeforeRow[0][3]); // "Save"
    assertTrue(app.UI_menuBar.childDividerBeforeRow[0][4]);  // "Quit"
  }

  @Test
  void cleanDividersFromParent_collapsesConsecutiveDividersIntoOneFlag () {
    app.UI_menuBar.Items[0] = new String[]{"File", "New", "—", "—", "Open"};
    app.UI_menuBar.cleanDividersFromParent(0);

    assertArrayEquals(new String[]{"File", "New", "Open"}, app.UI_menuBar.Items[0]);
    assertTrue(app.UI_menuBar.childDividerBeforeRow[0][2]); // "Open" - still just one flag, not two rows
  }

  @Test
  void cleanDividersFromParent_leavesAParentWithNoDividersUnchanged () {
    app.UI_menuBar.Items[1] = new String[]{"Edit", "Copy", "Paste"};
    app.UI_menuBar.cleanDividersFromParent(1);

    assertArrayEquals(new String[]{"Edit", "Copy", "Paste"}, app.UI_menuBar.Items[1]);
    assertFalse(app.UI_menuBar.childDividerBeforeRow[1][1]);
    assertFalse(app.UI_menuBar.childDividerBeforeRow[1][2]);
  }

  // This is the actual bug report this cleanup fixes: moveSelection()'s
  // Left/Right carries the same selected_child index from one parent to
  // another (clampChild(), uiMenuBar.pde) - before this cleanup, that
  // index counted raw array slots, dividers included, so two parents
  // with a different number of dividers above the same ordinal item put
  // a different real item at the same index. Cleaning both removes that
  // difference: index 2 is "the 2nd real item" in every parent, no
  // matter how many dividers either one happens to have above it.
  @Test
  void cleaningMakesTheSameChildIndexMeanTheSameVisualPositionAcrossParentsWithDifferentDividerCounts () {
    app.UI_menuBar.Items[0] = new String[]{"A", "a1", "—", "a2", "a3"};          // one divider before "a2"
    app.UI_menuBar.Items[1] = new String[]{"B", "b1", "—", "—", "b2", "b3"};     // two dividers before "b2"

    app.UI_menuBar.cleanDividersFromParent(0);
    app.UI_menuBar.cleanDividersFromParent(1);

    assertEquals("a2", app.UI_menuBar.Items[0][2]);
    assertEquals("b2", app.UI_menuBar.Items[1][2]);
  }

  // ================= populateLayerMenu ===========================================
  // populateLayerMenu() rebuilds the "Layer" parent's own child list from
  // scratch on every call (into a local raw array, not directly into
  // this.Items[LayersID_in_Bar] - see its own header comment), with one
  // divider between the live allLayers entries and the fixed "developed"
  // analysis layers. build_allActions() (actions.pde) depends on that
  // divider's own position in the RETURNED array to skip it and to offset
  // the developed layers' indices past it - this test checks the
  // returned array still carries it, exactly as before, while this.Items
  // itself (what rendering/navigation actually uses) gets it cleaned out.

  // Both tests below find "Wind power"/the divider by searching rather
  // than computing their index from allLayers.length: populateLayerMenu()
  // has a separate, pre-existing off-by-one (the divider's own slot,
  // "base + 0", collides with the last allLayers entry's own index, so
  // the last allLayers description is silently lost) that isn't this
  // cleanup's to fix, and searching keeps these tests valid regardless
  // of whether/when that gets fixed separately.

  // These two use their own fresh app (rather than the shared one from
  // @BeforeEach, above, whose own Items this class replaces wholesale
  // with a hand-built, Layer-less array) so populateLayerMenu() can find
  // its real "Layer" parent, built by the real buildMenuItems().

  @Test
  void populateLayerMenu_returnsARawArrayWithItsOwnDividerIntact () {
    solarchvision_bim freshApp = new solarchvision_bim();
    freshApp.allLayers = new solarchvision_bim.LAYER[] {
      freshApp.new LAYER(1, 0, 0, "", "Layer One", "Couche Un", ""),
      freshApp.new LAYER(1, 0, 0, "", "Layer Two", "Couche Deux", "")
    };

    String[] raw = freshApp.UI_menuBar.populateLayerMenu();

    assertEquals("Layer One", raw[1]);
    int dividerIndex = java.util.Arrays.asList(raw).indexOf(freshApp.___divider___);
    assertTrue(dividerIndex > 0, "the returned array must still carry its own divider");
    assertEquals("Wind power", raw[dividerIndex + 1],
      "the divider build_allActions() (actions.pde) relies on must still sit right before the developed layers");
  }

  @Test
  void populateLayerMenu_leavesThisDotItemsForTheLayerParentCleaned () {
    solarchvision_bim freshApp = new solarchvision_bim();
    freshApp.allLayers = new solarchvision_bim.LAYER[] {
      freshApp.new LAYER(1, 0, 0, "", "Layer One", "Couche Un", "")
    };

    freshApp.UI_menuBar.populateLayerMenu();
    int layerIndex = freshApp.UI_menuBar.LayersID_in_Bar;
    String[] cleaned = freshApp.UI_menuBar.Items[layerIndex];

    for (String item : cleaned) {
      assertFalse(freshApp.UI_menuBar.isDivider(item), "this.Items itself must have no divider entries left: " + item);
    }

    int windPowerIndex = java.util.Arrays.asList(cleaned).indexOf("Wind power");
    assertTrue(windPowerIndex > 0);
    assertTrue(freshApp.UI_menuBar.childDividerBeforeRow[layerIndex][windPowerIndex],
      "a divider sat directly above \"Wind power\" before cleaning");
  }
}
