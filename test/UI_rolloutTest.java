import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// this.Spinner(...)/_Spinner(...) touch live mouse/rendering state (stroke(),
// fill(), text(), mouse click position) and aren't unit-testable as-is (see
// test/README.md) - not covered here. What's covered instead: the plain
// bookkeeping around them (revise()/updated(), the rollout category
// structure buildAllRollouts()/pushParent()/pushChild() build, and
// formatSpinnerValue()), plus registerSpinnerActions() itself, whose own
// body is just a list of vm.<name>(0) calls with no rendering involved -
// exercised per-method in more detail in ValueModifierTest.java.
class UI_rolloutTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= revise / updated =======================================

  @Test
  void revise_setsUpdateTrue () {
    app.UI_rollout.update = false;
    app.UI_rollout.revise();
    assertTrue(app.UI_rollout.update);
  }

  @Test
  void updated_setsUpdateFalse () {
    app.UI_rollout.update = true;
    app.UI_rollout.updated();
    assertFalse(app.UI_rollout.update);
  }

  // ================= rollout structure (built by the constructor) ==========

  @Test
  void constructor_buildsANonEmptySetOfParentCategories_eachWithItsOwnLabel () {
    assertFalse(app.UI_rollout.allRollouts.isEmpty());
    for (java.util.ArrayList<String> category : app.UI_rollout.allRollouts) {
      assertFalse(category.isEmpty()); // index 0 is always the category's own label
    }
  }

  @Test
  void pushParent_thenPushChild_appendsIntoTheJustPushedCategory () {
    int sizeBefore = app.UI_rollout.allRollouts.size();

    int parentIndex = app.UI_rollout.pushParent("Test Parent");
    int childIndex = app.UI_rollout.pushChild("Test Child");

    assertEquals(sizeBefore, parentIndex); // the new category is appended at the end
    assertEquals(1, childIndex); // index 0 is the parent's own label, pushed by pushParent
    assertEquals("Test Parent", app.UI_rollout.allRollouts.get(parentIndex).get(0));
    assertEquals("Test Child", app.UI_rollout.allRollouts.get(parentIndex).get(childIndex));
  }

  @Test
  void pushChild_appendsASecondChildAfterTheFirst () {
    app.UI_rollout.pushParent("Test Parent");
    app.UI_rollout.pushChild("First Child");
    int secondIndex = app.UI_rollout.pushChild("Second Child");

    assertEquals(2, secondIndex);
  }

  // ================= formatSpinnerValue ======================================

  @Test
  void formatSpinnerValue_formatsWholeNumbersWithNoDecimalPlaces () {
    assertEquals("5", app.UI_rollout.formatSpinnerValue(5));
    assertEquals("31", app.UI_rollout.formatSpinnerValue(31));
    assertEquals("0", app.UI_rollout.formatSpinnerValue(0));
    assertEquals("-10", app.UI_rollout.formatSpinnerValue(-10));
  }

  // ================= spinner text-edit state =================================

  @Test
  void beginSpinnerEdit_activatesEditingWithTheGivenCaptionAndFormattedValue () {
    app.UI_rollout.beginSpinnerEdit("Begin day", 15);

    assertTrue(app.UI_rollout.isEditingSpinner());
    assertEquals("Begin day", app.UI_rollout.editCaption);
    assertEquals("15", app.UI_rollout.editText);
    assertEquals(2, app.UI_rollout.editCursor); // cursor starts after the last digit
    assertFalse(app.UI_rollout.editCommit);
  }

  @Test
  void isEditingSpinner_falseBeforeAnyEditBegins () {
    assertFalse(app.UI_rollout.isEditingSpinner());
  }

  // ================= registerSpinnerActions ==================================

  @Test
  void registerSpinnerActions_registersAllValueModifiersWithoutThrowing () {
    app.allActions = new java.util.HashMap<>();
    int before = app.allActions.size();

    assertDoesNotThrow(() -> app.UI_rollout.registerSpinnerActions());

    assertTrue(app.allActions.size() > before);
    assertTrue(app.allActions.containsKey("day"));
    assertTrue(app.allActions.containsKey("location_latitude"));
    assertTrue(app.allActions.containsKey("location_longitude"));
  }

  // ================= dispatchEditKey ==========================================

  @Test
  void dispatchEditKey_leftMovesCursorLeftWhenNotAtStart () {
    app.UI_rollout.editText = "abc";
    app.UI_rollout.editCursor = 2;
    app.UI_rollout.dispatchEditKey(true, app.LEFT, (char) 0);
    assertEquals(1, app.UI_rollout.editCursor);
  }

  @Test
  void dispatchEditKey_leftDoesNothingAtStart () {
    app.UI_rollout.editText = "abc";
    app.UI_rollout.editCursor = 0;
    app.UI_rollout.dispatchEditKey(true, app.LEFT, (char) 0);
    assertEquals(0, app.UI_rollout.editCursor);
  }

  @Test
  void dispatchEditKey_rightMovesCursorRightWhenNotAtEnd () {
    app.UI_rollout.editText = "abc";
    app.UI_rollout.editCursor = 1;
    app.UI_rollout.dispatchEditKey(true, app.RIGHT, (char) 0);
    assertEquals(2, app.UI_rollout.editCursor);
  }

  @Test
  void dispatchEditKey_rightDoesNothingAtEnd () {
    app.UI_rollout.editText = "abc";
    app.UI_rollout.editCursor = 3;
    app.UI_rollout.dispatchEditKey(true, app.RIGHT, (char) 0);
    assertEquals(3, app.UI_rollout.editCursor);
  }

  @Test
  void dispatchEditKey_backspaceRemovesCharacterBeforeCursor () {
    app.UI_rollout.editText = "abc";
    app.UI_rollout.editCursor = 2;
    app.UI_rollout.dispatchEditKey(false, 0, app.BACKSPACE);
    assertEquals("ac", app.UI_rollout.editText);
    assertEquals(1, app.UI_rollout.editCursor);
  }

  @Test
  void dispatchEditKey_backspaceDoesNothingAtStart () {
    app.UI_rollout.editText = "abc";
    app.UI_rollout.editCursor = 0;
    app.UI_rollout.dispatchEditKey(false, 0, app.BACKSPACE);
    assertEquals("abc", app.UI_rollout.editText);
  }

  @Test
  void dispatchEditKey_deleteRemovesCharacterAfterCursor () {
    app.UI_rollout.editText = "abc";
    app.UI_rollout.editCursor = 1;
    app.UI_rollout.dispatchEditKey(false, 0, app.DELETE);
    assertEquals("ac", app.UI_rollout.editText);
    assertEquals(1, app.UI_rollout.editCursor);
  }

  @Test
  void dispatchEditKey_deleteDoesNothingAtEnd () {
    app.UI_rollout.editText = "abc";
    app.UI_rollout.editCursor = 3;
    app.UI_rollout.dispatchEditKey(false, 0, app.DELETE);
    assertEquals("abc", app.UI_rollout.editText);
  }

  // ================= keyReleased / processHeldKey =============================

  @Test
  void processHeldKey_doesNothingWhenNotEditing () {
    app.UI_rollout.editActive = false;
    app.UI_rollout.navKeyHeld = true;
    app.UI_rollout.navKeyCoded = true;
    app.UI_rollout.navKeyCode = app.LEFT;
    app.UI_rollout.navKeyFrameCounter = app.UI_rollout.NAV_KEY_INITIAL_DELAY_FRAMES; // already past threshold
    app.UI_rollout.editText = "abc";
    app.UI_rollout.editCursor = 2;

    app.UI_rollout.processHeldKey();

    assertEquals(2, app.UI_rollout.editCursor); // unchanged - not editing
  }

  @Test
  void processHeldKey_doesNotFireBeforeTheInitialDelayElapses () {
    app.UI_rollout.editActive = true;
    app.UI_rollout.navKeyHeld = true;
    app.UI_rollout.navKeyCoded = true;
    app.UI_rollout.navKeyCode = app.LEFT;
    app.UI_rollout.navKeyFrameCounter = 0;
    app.UI_rollout.navKeyRepeating = false;
    app.UI_rollout.editText = "abc";
    app.UI_rollout.editCursor = 2;

    for (int i = 0; i < app.UI_rollout.NAV_KEY_INITIAL_DELAY_FRAMES - 1; i++) {
      app.UI_rollout.processHeldKey();
    }
    assertEquals(2, app.UI_rollout.editCursor);

    app.UI_rollout.processHeldKey(); // the delay-th call - now it fires
    assertEquals(1, app.UI_rollout.editCursor);
    assertTrue(app.UI_rollout.navKeyRepeating);
  }

  @Test
  void processHeldKey_repeatsEveryFrameAfterTheInitialDelay () {
    app.UI_rollout.editActive = true;
    app.UI_rollout.navKeyHeld = true;
    app.UI_rollout.navKeyCoded = true;
    app.UI_rollout.navKeyCode = app.LEFT;
    app.UI_rollout.navKeyFrameCounter = app.UI_rollout.NAV_KEY_INITIAL_DELAY_FRAMES - 1;
    app.UI_rollout.navKeyRepeating = false;
    app.UI_rollout.editText = "abcde";
    app.UI_rollout.editCursor = 4;

    app.UI_rollout.processHeldKey(); // crosses the initial delay - fires
    assertEquals(3, app.UI_rollout.editCursor);

    app.UI_rollout.processHeldKey(); // NAV_KEY_REPEAT_FRAMES == 1 - fires again immediately
    assertEquals(2, app.UI_rollout.editCursor);
  }

  @Test
  void keyReleased_clearsNavKeyHeldOnlyWhenTheSameCodedKeyComesBackUp () {
    app.UI_rollout.navKeyHeld = true;
    app.UI_rollout.navKeyCoded = true;
    app.UI_rollout.navKeyCode = app.LEFT;

    app.key = (char) app.CODED;
    app.keyCode = app.RIGHT; // a DIFFERENT key releasing
    app.UI_rollout.keyReleased();
    assertTrue(app.UI_rollout.navKeyHeld);

    app.keyCode = app.LEFT; // the actual held key releasing
    app.UI_rollout.keyReleased();
    assertFalse(app.UI_rollout.navKeyHeld);
  }

  @Test
  void keyReleased_clearsNavKeyHeldOnlyWhenTheSameUncodedKeyComesBackUp () {
    app.UI_rollout.navKeyHeld = true;
    app.UI_rollout.navKeyCoded = false;
    app.UI_rollout.navKeyChar = app.BACKSPACE;

    app.key = app.DELETE; // a DIFFERENT key releasing
    app.UI_rollout.keyReleased();
    assertTrue(app.UI_rollout.navKeyHeld);

    app.key = app.BACKSPACE; // the actual held key releasing
    app.UI_rollout.keyReleased();
    assertFalse(app.UI_rollout.navKeyHeld);
  }

  @Test
  void keyReleased_ignoresAnUncodedKeyReleaseWhileACodedKeyIsHeld () {
    app.UI_rollout.navKeyHeld = true;
    app.UI_rollout.navKeyCoded = true;
    app.UI_rollout.navKeyCode = app.LEFT;

    app.key = 'a'; // an uncoded key, while a coded arrow key is held
    app.UI_rollout.keyReleased();
    assertTrue(app.UI_rollout.navKeyHeld);
  }

  @Test
  void keyReleased_ignoresACodedKeyReleaseWhileAnUncodedKeyIsHeld () {
    app.UI_rollout.navKeyHeld = true;
    app.UI_rollout.navKeyCoded = false;
    app.UI_rollout.navKeyChar = app.BACKSPACE;

    app.key = (char) app.CODED;
    app.keyCode = app.LEFT; // a coded key, while an uncoded Backspace is held
    app.UI_rollout.keyReleased();
    assertTrue(app.UI_rollout.navKeyHeld);
  }

  // ================= dispatchEditKey ignores keys it doesn't own ================

  @Test
  void dispatchEditKey_ignoresOtherCodedKeysLikeUp () {
    app.UI_rollout.editText = "abc";
    app.UI_rollout.editCursor = 1;
    app.UI_rollout.dispatchEditKey(true, app.UP, (char) 0); // only Left/Right are handled
    assertEquals(1, app.UI_rollout.editCursor);
  }

  @Test
  void dispatchEditKey_ignoresNonRepeatableUncodedKeysLikeEnter () {
    app.UI_rollout.editText = "abc";
    app.UI_rollout.editCursor = 1;
    app.UI_rollout.dispatchEditKey(false, 0, app.ENTER); // Enter is handled in keyPressed(), not here
    assertEquals("abc", app.UI_rollout.editText);
    assertEquals(1, app.UI_rollout.editCursor);
  }

  // ================= boundary repeat regression ==================================

  @Test
  void processHeldKey_repeatingRightPastTheEndStaysClampedAndDoesNotThrow () {
    app.UI_rollout.editActive = true;
    app.UI_rollout.editText = "abc";
    app.UI_rollout.editCursor = 3; // already at the end
    app.UI_rollout.navKeyHeld = true;
    app.UI_rollout.navKeyCoded = true;
    app.UI_rollout.navKeyCode = app.RIGHT;
    app.UI_rollout.navKeyFrameCounter = 0;
    app.UI_rollout.navKeyRepeating = false;

    assertDoesNotThrow(() -> {
      for (int i = 0; i < 50; i++) app.UI_rollout.processHeldKey();
    });
    assertEquals(3, app.UI_rollout.editCursor);
  }

  @Test
  void processHeldKey_repeatingDeletePastTheEndStaysClampedAndDoesNotThrow () {
    app.UI_rollout.editActive = true;
    app.UI_rollout.editText = "a";
    app.UI_rollout.editCursor = 1; // nothing after the cursor to delete
    app.UI_rollout.navKeyHeld = true;
    app.UI_rollout.navKeyCoded = false;
    app.UI_rollout.navKeyChar = app.DELETE;
    app.UI_rollout.navKeyFrameCounter = 0;
    app.UI_rollout.navKeyRepeating = false;

    assertDoesNotThrow(() -> {
      for (int i = 0; i < 50; i++) app.UI_rollout.processHeldKey();
    });
    assertEquals("a", app.UI_rollout.editText); // untouched, never read past the end
  }

  // ================= renderButtonBounds / handleRenderButtonClick =========
  // ================= (the "SOLARCHVISION render" button) ===================
  // drawRenderButton() itself (rect()/fill()/text()) isn't covered here,
  // same reasoning as this class's other draw()-touching methods (top-of-
  // file comment) - what's covered is the pure geometry
  // (renderButtonBounds()) and the click logic (handleRenderButtonClick()),
  // which calls no graphics functions at all, by design (drawRenderButton()'s
  // own comment on why they're split).

  // cX/cY/dX/dY/view_S all ultimately derive from pixel_W/pixel_H/pixel_A/
  // pixel_B (globals.pde), which stay at their own Java-default 0 in a
  // bare `new solarchvision_bim()` test instance - only setup() computes
  // them for real. Left at their own field-initializer defaults, dY in
  // particular (2 * pixel_H) collapses to 0, which doesn't make
  // renderButtonBounds() degenerate on its own (y1 still ends up < y2),
  // but isInside() (global_functions.pde) uses strict `<`, not `<=`, so
  // any other similarly-zeroed combination can silently produce a
  // bounds box no click position computed from those same zeroed values
  // could ever land strictly inside. Set explicitly here instead of
  // relying on those defaults, so every one of these tests' own click
  // targets are computed against real, known numbers.
  private void setExplicitRolloutBounds () {
    app.UI_rollout.cX = 100;
    app.UI_rollout.cY = 200;
    app.UI_rollout.dX = 300;
    app.UI_rollout.dY = 400;
    app.UI_rollout.view_S = 1;
  }

  @Test
  void renderButtonBounds_isPinnedToTheBottomOfThePanel () {
    setExplicitRolloutBounds();

    float[] b = app.UI_rollout.renderButtonBounds();

    assertEquals(105f, b[0], 0.01f); // x1
    assertEquals(395f, b[1], 0.01f); // x2
    assertEquals(570f, b[2], 0.01f); // y1 == cY + dY - 5 - 25
    assertEquals(595f, b[3], 0.01f); // y2 == cY + dY - 5, bottom-anchored
  }

  @Test
  void handleRenderButtonClick_outsideTheButton_doesNothing () {
    app.allActions = new java.util.HashMap<>();
    boolean[] ran = {false};
    app.allActions.put("prebake viewport", (args) -> ran[0] = true);

    setExplicitRolloutBounds();
    float[] b = app.UI_rollout.renderButtonBounds();
    int clickedX = (int) (b[0] - 100); // well to the left of the button
    app.X_clicked = clickedX;
    app.Y_clicked = (int) b[2];

    app.UI_rollout.handleRenderButtonClick();

    assertFalse(ran[0]);
    assertEquals(clickedX, app.X_clicked); // click NOT consumed
  }

  @Test
  void handleRenderButtonClick_whileEditingASpinner_doesNothing () {
    app.allActions = new java.util.HashMap<>();
    boolean[] ran = {false};
    app.allActions.put("prebake viewport", (args) -> ran[0] = true);
    app.UI_rollout.editActive = true;

    setExplicitRolloutBounds();
    float[] b = app.UI_rollout.renderButtonBounds();
    app.X_clicked = (int) (0.5f * (b[0] + b[1]));
    app.Y_clicked = (int) (0.5f * (b[2] + b[3]));

    app.UI_rollout.handleRenderButtonClick();

    assertFalse(ran[0]);
  }

  @Test
  void handleRenderButtonClick_insideTheButton_skipsUnshadeWhenShadingIsOff_andUsesSkinPotentialActive () {
    app.allActions = new java.util.HashMap<>();
    java.util.List<String> calledOrder = new java.util.ArrayList<>();
    app.allActions.put("prebake viewport", (args) -> calledOrder.add("prebake"));
    app.allActions.put("unshade viewport", (args) -> calledOrder.add("unshade"));
    app.allActions.put("skin potential (active)", (args) -> calledOrder.add("active"));
    app.allActions.put("skin potential (passive)", (args) -> calledOrder.add("passive"));

    app.WIN3D.showShading = false; // "if necessary" - not necessary here
    app.STUDY.impactTypeIndex = app.Impact_ACTIVE;

    setExplicitRolloutBounds();
    float[] b = app.UI_rollout.renderButtonBounds();
    app.X_clicked = (int) (0.5f * (b[0] + b[1]));
    app.Y_clicked = (int) (0.5f * (b[2] + b[3]));

    app.UI_rollout.handleRenderButtonClick();

    assertEquals(java.util.Arrays.asList("prebake", "active"), calledOrder);
    assertEquals(-1, app.X_clicked); // click consumed, same as the generic rollout catch-all
    assertEquals(-1, app.Y_clicked);
  }

  @Test
  void handleRenderButtonClick_alsoUnshadesWhenShadingIsOn_andUsesSkinPotentialPassive () {
    app.allActions = new java.util.HashMap<>();
    java.util.List<String> calledOrder = new java.util.ArrayList<>();
    app.allActions.put("prebake viewport", (args) -> calledOrder.add("prebake"));
    app.allActions.put("unshade viewport", (args) -> calledOrder.add("unshade"));
    app.allActions.put("skin potential (active)", (args) -> calledOrder.add("active"));
    app.allActions.put("skin potential (passive)", (args) -> calledOrder.add("passive"));

    app.WIN3D.showShading = true; // "if necessary" - it is, here
    app.STUDY.impactTypeIndex = app.Impact_PASSIVE;

    setExplicitRolloutBounds();
    float[] b = app.UI_rollout.renderButtonBounds();
    app.X_clicked = (int) (0.5f * (b[0] + b[1]));
    app.Y_clicked = (int) (0.5f * (b[2] + b[3]));

    app.UI_rollout.handleRenderButtonClick();

    assertEquals(java.util.Arrays.asList("prebake", "unshade", "passive"), calledOrder);
  }
}
