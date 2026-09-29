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
}
