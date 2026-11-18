import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.util.ArrayList;
import processing.event.KeyEvent;
import processing.event.Event;

// Covers UI_mouseGuide's own layout/hover logic (uiMouseGuide.pde) and
// its wiring into keyPressed()/mouseClicked() (solarchvision_bim.pde/
// mouseClicked.pde) and the "Guide" menu (uiMenuBar.pde/actions.pde) -
// UIKeyboardMapTest.java's own counterpart, same structure, same
// get()/image()-throws-against-this-harness limitation (that file's own
// header comment explains it in full) applying here identically: every
// test below that needs the overlay "open" sets
// app.UI_mouseGuide.visible = true directly instead of calling show().
class UIMouseGuideTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>();
    app.build_allActions();
    app.frameCount = 100;
    app.control = app.USER_GUI;
    app.UI_menuBar.selected_parent = -1;

    // Same panel geometry convention UIKeyboardMapTest.java's own setUp()
    // uses - boundingBox()/panelUnionBounds() are identical logic here.
    app.WORLD.cX = 0; app.WORLD.cY = 0; app.WORLD.dX = 600; app.WORLD.dY = 400; app.WORLD.ImageScale = 1;
    app.STUDY.cX = 600; app.STUDY.cY = 0; app.STUDY.dX = 600; app.STUDY.dY = 400; app.STUDY.ImageScale = 1;
    app.WIN3D.cX = 0; app.WIN3D.cY = 400; app.WIN3D.dX = 1200; app.WIN3D.dY = 400; app.WIN3D.ImageScale = 1;
  }

  private KeyEvent keyEvent (char key, int modifiers) {
    return new KeyEvent(null, 0, KeyEvent.PRESS, modifiers, key, (int) key, false);
  }

  // ================= layout / hover lookup ==================================

  @Test
  void buildLayout_laysOutExactlyThreePads_oneForEachViewport () {
    ArrayList<solarchvision_bim.UI_mouseGuide.LaidOutPad> pads = app.UI_mouseGuide.buildLayout();
    assertEquals(3, pads.size());
    ArrayList<String> viewports = new ArrayList<>();
    for (solarchvision_bim.UI_mouseGuide.LaidOutPad p : pads) viewports.add(p.viewport);
    assertTrue(viewports.contains("WORLD"));
    assertTrue(viewports.contains("STUDY"));
    assertTrue(viewports.contains("WIN3D"));
  }

  @Test
  void buildLayout_padsDoNotOverlap () {
    ArrayList<solarchvision_bim.UI_mouseGuide.LaidOutPad> pads = app.UI_mouseGuide.buildLayout();
    for (int i = 0; i < pads.size(); i++) {
      for (int j = i + 1; j < pads.size(); j++) {
        solarchvision_bim.UI_mouseGuide.LaidOutPad a = pads.get(i);
        solarchvision_bim.UI_mouseGuide.LaidOutPad b = pads.get(j);
        boolean overlapsX = (a.x < b.x + b.w) && (b.x < a.x + a.w);
        boolean overlapsY = (a.y < b.y + b.h) && (b.y < a.y + a.h);
        assertFalse(overlapsX && overlapsY, a.viewport + " and " + b.viewport + " pads overlap");
      }
    }
  }

  @Test
  void padAt_pointInsideAPad_returnsThatPad () {
    ArrayList<solarchvision_bim.UI_mouseGuide.LaidOutPad> pads = app.UI_mouseGuide.buildLayout();
    solarchvision_bim.UI_mouseGuide.LaidOutPad first = pads.get(0);
    float cx = first.x + first.w / 2;
    float cy = first.y + first.h / 2;

    solarchvision_bim.UI_mouseGuide.LaidOutPad found = app.UI_mouseGuide.padAt(pads, cx, cy);
    assertNotNull(found);
    assertEquals(first.viewport, found.viewport);
  }

  @Test
  void padAt_pointOutsideEveryPad_returnsNull () {
    ArrayList<solarchvision_bim.UI_mouseGuide.LaidOutPad> pads = app.UI_mouseGuide.buildLayout();
    assertNull(app.UI_mouseGuide.padAt(pads, -99999, -99999));
  }

  // ================= menuDropdownStillOnScreen() =============================
  // Same three cases as UI_keyboardMap's own menuDropdownStillOnScreen()
  // tests (UIKeyboardMapTest.java) - this is a deliberately duplicated,
  // not shared, guard (see uiMouseGuide.pde's own header comment).

  @Test
  void menuDropdownStillOnScreen_falseWhenNoMenuIsOpen () {
    app.UI_menuBar.selected_parent = -1;
    app.pre_screen = app.createImage(1, 1, app.RGB);
    assertFalse(app.UI_mouseGuide.menuDropdownStillOnScreen());
  }

  @Test
  void menuDropdownStillOnScreen_falseWhenMenuOpenButNoPreScreenCapturedYet () {
    app.UI_menuBar.selected_parent = 0;
    app.pre_screen = null;
    assertFalse(app.UI_mouseGuide.menuDropdownStillOnScreen());
  }

  @Test
  void menuDropdownStillOnScreen_trueWhenAMenuIsOpenAndPreScreenIsCaptured () {
    app.UI_menuBar.selected_parent = 0;
    app.pre_screen = app.createImage(1, 1, app.RGB);
    assertTrue(app.UI_mouseGuide.menuDropdownStillOnScreen());
  }

  // ================= show()/hide() ============================================

  @Test
  void show_whenAlreadyVisible_isANoOp_andNeverReachesGet () {
    app.UI_mouseGuide.visible = true;
    assertDoesNotThrow(() -> app.UI_mouseGuide.show());
    assertTrue(app.UI_mouseGuide.visible);
    assertNull(app.UI_mouseGuide.mouseGuide_pre_screen, "must not have captured anything");
  }

  @Test
  void hide_whenNotVisible_isANoOp () {
    assertDoesNotThrow(() -> app.UI_mouseGuide.hide());
    assertFalse(app.UI_mouseGuide.visible);
  }

  // ================= keyPressed() wiring =====================================

  @Test
  void keyPressed_anyKeyWhileVisible_closesItAndIsConsumed () {
    app.UI_mouseGuide.visible = true;
    assertDoesNotThrow(() -> app.keyPressed(keyEvent('a', 0)));
    assertFalse(app.UI_mouseGuide.visible);
  }

  @Test
  void keyPressed_escWhileVisible_closesItAndZeroesKey_soItDoesNotAlsoQuitTheSketch () {
    // Same regression-guard reasoning as UI_keyboardMap's own identical
    // test (UIKeyboardMapTest.java).
    app.UI_mouseGuide.visible = true;
    app.key = app.ESC;

    assertDoesNotThrow(() -> app.keyPressed(keyEvent((char) app.ESC, 0)));

    assertFalse(app.UI_mouseGuide.visible, "Esc must still close the overlay");
    assertEquals(0, app.key, "Esc must be zeroed so PApplet's own quit-on-Esc default can't fire");
  }

  @Test
  void keyPressed_nonEscKeyWhileVisible_leavesKeyUntouched () {
    app.UI_mouseGuide.visible = true;
    app.key = 'a';

    assertDoesNotThrow(() -> app.keyPressed(keyEvent('a', 0)));

    assertFalse(app.UI_mouseGuide.visible);
    assertEquals('a', app.key, "only Esc gets zeroed - an ordinary key must be left alone");
  }

  @Test
  void keyPressed_ctrlQuestionMarkWhileTypingACommand_doesNotOpenIt () {
    app.typeUserCommand = 1;
    assertDoesNotThrow(() -> app.keyPressed(keyEvent('?', Event.CTRL)));
    assertFalse(app.UI_mouseGuide.visible);
  }

  @Test
  void keyPressed_plainQuestionMark_doesNotOpenTheMouseGuide () {
    // Guards on e.isControlDown() specifically - plain '?' (no Ctrl)
    // must keep opening the keyboard map (UIKeyboardMapTest.java), never
    // the mouse guide.
    assertDoesNotThrow(() -> app.keyPressed(keyEvent('?', 0)));
    assertFalse(app.UI_mouseGuide.visible);
  }

  // isMouseGuideOpenChord() itself (solarchvision_bim.pde) is tested
  // directly in KeyPressedGuardsTest.java - it was split out of
  // keyPressed()'s own condition specifically so the chord-matching
  // logic (including the isShiftDown()-and-'/' fallback, for a platform
  // that reports the bare '/' char instead of '?' once Ctrl joins Shift)
  // could be unit-tested without needing an already-open overlay or a
  // real show() call that touches real graphics - see that function's
  // own comment, and KeyPressedGuardsTest.java's tests of it.

  // ================= mouseClicked() wiring ===================================

  @Test
  void mouseClicked_whileVisible_insideItsBounds_doesNothing () {
    app.UI_mouseGuide.visible = true;
    float[] box = app.UI_mouseGuide.boundingBox();
    app.mouseX = (int) ((box[0] + box[2]) / 2);
    app.mouseY = (int) ((box[1] + box[3]) / 2);

    assertDoesNotThrow(() -> app.mouseClicked());

    assertTrue(app.UI_mouseGuide.visible, "a click inside the mouse guide must not close it");
  }

  @Test
  void mouseClicked_whileVisible_outsideItsBounds_closesIt () {
    app.UI_mouseGuide.visible = true;
    float[] box = app.UI_mouseGuide.boundingBox();
    app.mouseX = (int) (box[2] + 10000);
    app.mouseY = (int) (box[3] + 10000);

    assertDoesNotThrow(() -> app.mouseClicked());

    assertFalse(app.UI_mouseGuide.visible);
  }

  // ================= "Guide" menu wiring ======================================

  @Test
  void showMouseGuideAction_isRegistered () {
    assertTrue(app.allActions.containsKey("show mouse guide"));
  }

  @Test
  void guideMenu_includesTheShowMouseGuideItem_afterShowKeyboardMap () {
    boolean found = false;
    for (String[] parentRow : app.UI_menuBar.Items) {
      if (parentRow[0].equals("Guide")) {
        found = true;
        assertEquals("Show Keyboard Map", parentRow[1]);
        assertEquals("Show Mouse Guide", parentRow[2]);
      }
    }
    assertTrue(found, "no \"Guide\" parent found in UI_menuBar.Items");
  }
}
