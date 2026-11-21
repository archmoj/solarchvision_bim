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

  // ================= button-row thirds / scroll wheel / subZoneAt() ==========
  // Covers the per-touchpad sub-zones added for per-button hover
  // filtering: a left/middle/right-click button row and a scroll wheel
  // nested inside the middle third itself, same "pure geometry, no
  // graphics calls" reasoning as the layout tests above.

  @Test
  void buttonThirdRect_threeThirds_tileTheButtonRowExactlyWithNoGapOrOverlap () {
    solarchvision_bim.UI_mouseGuide.LaidOutPad p = app.UI_mouseGuide.buildLayout().get(0);
    float[] left = app.UI_mouseGuide.buttonThirdRect(p, 0);
    float[] middle = app.UI_mouseGuide.buttonThirdRect(p, 1);
    float[] right = app.UI_mouseGuide.buttonThirdRect(p, 2);

    assertEquals(left[2], middle[0], 0.001, "left/middle must share an edge");
    assertEquals(middle[2], right[0], 0.001, "middle/right must share an edge");
    assertEquals(p.x, left[0], 0.001);
    assertEquals(p.x + p.w, right[2], 0.001);
    // All three thirds span the same button-row band, flush with the
    // pad's own top edge (the button row sits at the top, not along
    // the bottom).
    assertEquals(left[1], middle[1], 0.001);
    assertEquals(middle[1], right[1], 0.001);
    assertEquals(p.y, left[1], 0.001);
  }

  @Test
  void scrollZoneRect_isCenteredOverTheMiddleThird_andNestsEntirelyInsideIt () {
    solarchvision_bim.UI_mouseGuide.LaidOutPad p = app.UI_mouseGuide.buildLayout().get(0);
    float[] middle = app.UI_mouseGuide.buttonThirdRect(p, 1);
    float[] scroll = app.UI_mouseGuide.scrollZoneRect(p);

    float middleCenterX = (middle[0] + middle[2]) / 2;
    float middleCenterY = (middle[1] + middle[3]) / 2;
    float scrollCenterX = (scroll[0] + scroll[2]) / 2;
    float scrollCenterY = (scroll[1] + scroll[3]) / 2;
    assertEquals(middleCenterX, scrollCenterX, 0.001, "scroll wheel must be centered over the middle-click third");
    assertEquals(middleCenterY, scrollCenterY, 0.001, "scroll wheel must be vertically centered within the middle-click third");
    // The scroll wheel now sits nested inside the middle third itself
    // (replacing where the "Middle\nClick" label used to be), not as a
    // separate zone below the button row - so it must stay entirely
    // within the middle third's own bounds.
    assertTrue(scroll[0] >= middle[0] && scroll[2] <= middle[2], "scroll wheel must stay within the middle third's width");
    assertTrue(scroll[1] >= middle[1] && scroll[3] <= middle[3], "scroll wheel must stay within the middle third's height");
  }

  @Test
  void subZoneAt_pointInLeftThird_returnsLEFT () {
    solarchvision_bim.UI_mouseGuide.LaidOutPad p = app.UI_mouseGuide.buildLayout().get(0);
    float[] left = app.UI_mouseGuide.buttonThirdRect(p, 0);
    float cx = (left[0] + left[2]) / 2;
    float cy = (left[1] + left[3]) / 2;
    assertEquals("LEFT", app.UI_mouseGuide.subZoneAt(p, cx, cy));
  }

  @Test
  void subZoneAt_pointInMiddleThird_returnsMIDDLE () {
    solarchvision_bim.UI_mouseGuide.LaidOutPad p = app.UI_mouseGuide.buildLayout().get(0);
    float[] middle = app.UI_mouseGuide.buttonThirdRect(p, 1);
    float[] scroll = app.UI_mouseGuide.scrollZoneRect(p);
    float cx = middle[0] + 1; // left edge of the middle third, clear of the nested scroll wheel at its center
    float cy = (middle[1] + middle[3]) / 2;
    assertTrue(cx < scroll[0], "probe point must fall outside the nested scroll wheel");
    assertEquals("MIDDLE", app.UI_mouseGuide.subZoneAt(p, cx, cy));
  }

  @Test
  void subZoneAt_pointInRightThird_returnsRIGHT () {
    solarchvision_bim.UI_mouseGuide.LaidOutPad p = app.UI_mouseGuide.buildLayout().get(0);
    float[] right = app.UI_mouseGuide.buttonThirdRect(p, 2);
    float cx = (right[0] + right[2]) / 2;
    float cy = (right[1] + right[3]) / 2;
    assertEquals("RIGHT", app.UI_mouseGuide.subZoneAt(p, cx, cy));
  }

  @Test
  void subZoneAt_pointOnTheScrollWheel_returnsSCROLL () {
    solarchvision_bim.UI_mouseGuide.LaidOutPad p = app.UI_mouseGuide.buildLayout().get(0);
    float[] scroll = app.UI_mouseGuide.scrollZoneRect(p);
    float cx = (scroll[0] + scroll[2]) / 2;
    float cy = (scroll[1] + scroll[3]) / 2;
    assertEquals("SCROLL", app.UI_mouseGuide.subZoneAt(p, cx, cy));
  }

  @Test
  void subZoneAt_pointOnTheLowerBody_returnsGENERAL () {
    solarchvision_bim.UI_mouseGuide.LaidOutPad p = app.UI_mouseGuide.buildLayout().get(0);
    // Near the pad's own bottom edge - below the button row (and its
    // now-nested scroll wheel) entirely, so none of those more specific
    // zones match; this is also where the viewport-name label is drawn.
    assertEquals("GENERAL", app.UI_mouseGuide.subZoneAt(p, p.x + p.w / 2, p.y + p.h - 1));
  }

  @Test
  void subZoneAt_pointOutsideThePad_returnsNull () {
    solarchvision_bim.UI_mouseGuide.LaidOutPad p = app.UI_mouseGuide.buildLayout().get(0);
    assertNull(app.UI_mouseGuide.subZoneAt(p, p.x - 10000, p.y - 10000));
  }
}
