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
    assertTrue(app.allActions.containsKey("begin_day"));
    assertTrue(app.allActions.containsKey("latitude"));
    assertTrue(app.allActions.containsKey("longitude"));
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
}
