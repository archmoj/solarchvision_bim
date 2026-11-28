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
//
// The side scrollbar (drawRolloutScrollbar() and friends, added
// alongside the Properties/Modify Selected work) splits the same way:
// drawRolloutScrollbar()/drawRolloutScrollArrowButton() themselves draw
// (fill()/stroke()/text()) and aren't covered here either, but
// everything feeding them - the rect math (rolloutScrollbarOuterRect()/
// rolloutScrollUpButtonRect()/rolloutScrollDownButtonRect()/
// rolloutScrollTrackRect()/rolloutScrollThumbRect()/
// rolloutNeedsScrollbar()) and the click/drag/wheel handlers
// (handleRolloutScrollButtonClicks()/handleRolloutScrollTrackClick()/
// handleScrollDrag()/handleWheel()) - is plain arithmetic over fields
// and the same global click/drag state (X_clicked/Y_clicked/
// dragging_started/pmouseX/pmouseY/mouseY) MouseClickedTest.java/
// MouseDraggedTest.java already drive directly, so it's covered the
// same way those are.
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

  // ================= renderViewportButtonBounds / handleRenderViewportButtonClick =========
  // ================= (the "SOLARCHVISION render" button) ===================
  // drawRenderButton() itself (rect()/fill()/text()) isn't covered here,
  // same reasoning as this class's other draw()-touching methods (top-of-
  // file comment) - what's covered is the pure geometry
  // (renderViewportButtonBounds()) and the click logic (handleRenderViewportButtonClick()),
  // which calls no graphics functions at all, by design (drawRenderButton()'s
  // own comment on why they're split).

  // cX/cY/dX/dY/view_S all ultimately derive from pixel_W/pixel_H/pixel_A/
  // pixel_B (globals.pde), which stay at their own Java-default 0 in a
  // bare `new solarchvision_bim()` test instance - only setup() computes
  // them for real. Left at their own field-initializer defaults, dY in
  // particular (2 * pixel_H) collapses to 0, which doesn't make
  // renderViewportButtonBounds() degenerate on its own (y1 still ends up < y2),
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
  void renderViewportButtonBounds_isPinnedToTheBottomOfThePanel () {
    setExplicitRolloutBounds();

    float[] b = app.UI_rollout.renderViewportButtonBounds();

    assertEquals(105f, b[0], 0.01f); // x1
    assertEquals(395f, b[1], 0.01f); // x2
    assertEquals(570f, b[2], 0.01f); // y1 == cY + dY - 5 - 25
    assertEquals(595f, b[3], 0.01f); // y2 == cY + dY - 5, bottom-anchored
  }

  @Test
  void handleRenderViewportButtonClick_outsideTheButton_doesNothing () {
    app.allActions = new java.util.HashMap<>();
    boolean[] ran = {false};
    app.allActions.put("prebake viewport", (args) -> ran[0] = true);

    setExplicitRolloutBounds();
    float[] b = app.UI_rollout.renderViewportButtonBounds();
    int clickedX = (int) (b[0] - 100); // well to the left of the button
    app.X_clicked = clickedX;
    app.Y_clicked = (int) b[2];

    app.UI_rollout.handleRenderViewportButtonClick();

    assertFalse(ran[0]);
    assertEquals(clickedX, app.X_clicked); // click NOT consumed
  }

  @Test
  void handleRenderViewportButtonClick_whileEditingASpinner_doesNothing () {
    app.allActions = new java.util.HashMap<>();
    boolean[] ran = {false};
    app.allActions.put("prebake viewport", (args) -> ran[0] = true);
    app.UI_rollout.editActive = true;

    setExplicitRolloutBounds();
    float[] b = app.UI_rollout.renderViewportButtonBounds();
    app.X_clicked = (int) (0.5f * (b[0] + b[1]));
    app.Y_clicked = (int) (0.5f * (b[2] + b[3]));

    app.UI_rollout.handleRenderViewportButtonClick();

    assertFalse(ran[0]);
  }

  @Test
  void handleRenderViewportButtonClick_insideTheButton_skipsUnshadeWhenShadingIsOff_andUsesSkinPotentialActive () {
    app.allActions = new java.util.HashMap<>();
    java.util.List<String> calledOrder = new java.util.ArrayList<>();
    app.allActions.put("prebake viewport", (args) -> calledOrder.add("prebake"));
    app.allActions.put("unshade viewport", (args) -> calledOrder.add("unshade"));
    app.allActions.put("skin potential (active)", (args) -> calledOrder.add("active"));
    app.allActions.put("skin potential (passive)", (args) -> calledOrder.add("passive"));

    app.WIN3D.showShading = false; // "if necessary" - not necessary here
    app.STUDY.impactTypeIndex = app.Impact_ACTIVE;

    setExplicitRolloutBounds();
    float[] b = app.UI_rollout.renderViewportButtonBounds();
    app.X_clicked = (int) (0.5f * (b[0] + b[1]));
    app.Y_clicked = (int) (0.5f * (b[2] + b[3]));

    app.UI_rollout.handleRenderViewportButtonClick();

    assertEquals(java.util.Arrays.asList("prebake", "active"), calledOrder);
    assertEquals(-1, app.X_clicked); // click consumed, same as the generic rollout catch-all
    assertEquals(-1, app.Y_clicked);
  }

  @Test
  void handleRenderViewportButtonClick_alsoUnshadesWhenShadingIsOn_andUsesSkinPotentialPassive () {
    app.allActions = new java.util.HashMap<>();
    java.util.List<String> calledOrder = new java.util.ArrayList<>();
    app.allActions.put("prebake viewport", (args) -> calledOrder.add("prebake"));
    app.allActions.put("unshade viewport", (args) -> calledOrder.add("unshade"));
    app.allActions.put("skin potential (active)", (args) -> calledOrder.add("active"));
    app.allActions.put("skin potential (passive)", (args) -> calledOrder.add("passive"));

    app.WIN3D.showShading = true; // "if necessary" - it is, here
    app.STUDY.impactTypeIndex = app.Impact_PASSIVE;

    setExplicitRolloutBounds();
    float[] b = app.UI_rollout.renderViewportButtonBounds();
    app.X_clicked = (int) (0.5f * (b[0] + b[1]));
    app.Y_clicked = (int) (0.5f * (b[2] + b[3]));

    app.UI_rollout.handleRenderViewportButtonClick();

    assertEquals(java.util.Arrays.asList("prebake", "unshade", "passive"), calledOrder);
  }

  // ================= renderSectionsButtonBounds / handleRenderSectionsButtonClick ====
  // ================= (the "SOLARCHVISION all sections" button) ====================
  // Same drawRenderButton()/handleRenderViewportButtonClick() split and reasoning
  // as that section's own header comment above - only the geometry
  // (renderSectionsButtonBounds()) and the pure click logic
  // (handleRenderSectionsButtonClick()) are covered here.

  @Test
  void renderSectionsButtonBounds_isStackedDirectlyAboveTheViewportButton () {
    setExplicitRolloutBounds();

    float[] viewportButton = app.UI_rollout.renderViewportButtonBounds();
    float[] b = app.UI_rollout.renderSectionsButtonBounds();

    assertEquals(viewportButton[0], b[0], 0.01f); // x1 - same width as the viewport button
    assertEquals(viewportButton[1], b[1], 0.01f); // x2
    assertEquals(viewportButton[2] - 5f, b[3], 0.01f); // y2 - same 5 * view_S margin above the viewport button's own y1
    assertEquals(viewportButton[2] - 5f - 25f, b[2], 0.01f); // y1 - same 25 * view_S height
  }

  // render_ShadowsOnSections()/calculate_ImpactOnSections()
  // (solarImpacts.pde) now take their section ids as a plain int[]
  // argument rather than being reached through the action registry, so
  // (unlike handleRenderViewportButtonClick()'s own tests above) there's no
  // allActions map to install spies into here - instead these call the
  // real functions directly, the same way the handler itself does.
  // allSections.num is kept at 0 in the "inside the button" tests below
  // so Select3D.rangeIds(allSections.num) comes back empty and both
  // functions' own per-section loops are a guaranteed no-op - same
  // reasoning SolarImpactsTest.java's own calculateImpactSelectedSections
  // _isANoOpWhenNothingIsSelected() test already relies on, since a
  // non-empty loop would reach calculate_Impact_CurrentPreBaked()'s own
  // cursor()/loadImage() calls, which throw outside a real running
  // sketch.

  @Test
  void handleRenderSectionsButtonClick_outsideTheButton_doesNothing () {
    setExplicitRolloutBounds();
    float[] b = app.UI_rollout.renderSectionsButtonBounds();
    int clickedX = (int) (b[0] - 100); // well to the left of the button

    app.allSections.num = 4; // would be a real, non-empty bake if this fired
    int[] originalSelection = new int[]{5, 7};
    app.Select3D.sectionSelection = originalSelection;
    app.X_clicked = clickedX;
    app.Y_clicked = (int) b[2];

    app.UI_rollout.handleRenderSectionsButtonClick();

    assertEquals(clickedX, app.X_clicked); // click NOT consumed
    assertSame(originalSelection, app.Select3D.sectionSelection); // Select3D.sectionSelection is never read or written by this handler at all now, let alone left untouched only because the click missed
  }

  @Test
  void handleRenderSectionsButtonClick_whileEditingASpinner_doesNothing () {
    app.UI_rollout.editActive = true;
    app.allSections.num = 4; // would be a real, non-empty bake if this fired

    setExplicitRolloutBounds();
    float[] b = app.UI_rollout.renderSectionsButtonBounds();
    int clickedX = (int) (0.5f * (b[0] + b[1]));
    app.X_clicked = clickedX;
    app.Y_clicked = (int) (0.5f * (b[2] + b[3]));

    assertDoesNotThrow(() -> app.UI_rollout.handleRenderSectionsButtonClick());

    assertEquals(clickedX, app.X_clicked); // click NOT consumed
  }

  @Test
  void handleRenderSectionsButtonClick_insideTheButton_setsActiveImpactGraphAndConsumesClick_leavingTheRealSelectionAlone () {
    app.STUDY.impactTypeIndex = app.Impact_ACTIVE;
    app.allSections.num = 0; // see this class's own comment just above

    int[] originalSelection = new int[]{1}; // never touched by this click, whatever it is
    app.Select3D.sectionSelection = originalSelection;

    setExplicitRolloutBounds();
    float[] b = app.UI_rollout.renderSectionsButtonBounds();
    app.X_clicked = (int) (0.5f * (b[0] + b[1]));
    app.Y_clicked = (int) (0.5f * (b[2] + b[3]));

    assertDoesNotThrow(() -> app.UI_rollout.handleRenderSectionsButtonClick());

    assertEquals(app.impactGraphIndex_URBAN_ACTIVE, app.STUDY.impactGraphIndex); // same assignment "Process Active Impact on Selected Sections" (actions.pde) itself makes
    assertSame(originalSelection, app.Select3D.sectionSelection); // the whole point of sections now being an argument - this never gets touched
    assertEquals(-1, app.X_clicked); // click consumed, same as the viewport button's own identical reasoning
    assertEquals(-1, app.Y_clicked);
  }

  @Test
  void handleRenderSectionsButtonClick_insideTheButton_usesPassiveWhenStudyIsPassive () {
    app.STUDY.impactTypeIndex = app.Impact_PASSIVE;
    app.allSections.num = 0; // see this class's own comment above

    setExplicitRolloutBounds();
    float[] b = app.UI_rollout.renderSectionsButtonBounds();
    app.X_clicked = (int) (0.5f * (b[0] + b[1]));
    app.Y_clicked = (int) (0.5f * (b[2] + b[3]));

    assertDoesNotThrow(() -> app.UI_rollout.handleRenderSectionsButtonClick());

    assertEquals(app.impactGraphIndex_URBAN_PASSIVE, app.STUDY.impactGraphIndex);
  }

  // ================= side scrollbar ==========================================
  // Shared numbers for every test below (view_S=1 from setExplicitRolloutBounds()
  // above, cX=100, dX=300): rolloutContentTopY=200, rolloutContentBottomY=600
  // (visible height 400) and rolloutContentHeight=1000 (needs scrolling,
  // maxScroll=600) unless a test says otherwise. Worked out by hand once
  // here, then reused as the expected values across the rect/thumb/drag
  // tests below:
  //   rolloutScrollbarWidth() = 8.5
  //   outer bar: x=389.5, y=200, w=8.5, h=400
  //   up button: x=389.5, y=200, w=8.5, h=8.5 (side == bar width)
  //   down button: x=389.5, y=591.5, w=8.5, h=8.5
  //   track: x=389.5, y=208.5, w=8.5, h=383 (bar height minus both buttons)
  //   thumb height: min(383, max(20, 383*(400/1000))) = 153.2
  //   thumb travel: 383 - 153.2 = 229.8
  //   thumb y at scrollY=0: 208.5 (track top); at scrollY=600 (max): 438.3

  private void setScrollableContent () {
    setExplicitRolloutBounds();
    app.UI_rollout.rolloutContentTopY = 200;
    app.UI_rollout.rolloutContentBottomY = 600;
    app.UI_rollout.rolloutContentHeight = 1000; // taller than the 400 visible - needs a scrollbar
  }

  @Test
  void rolloutScrollbarWidth_isTheSameSquareSizeAsASpinnersOwnArrowButtons () {
    setExplicitRolloutBounds();
    assertEquals(8.5f, app.UI_rollout.rolloutScrollbarWidth(), 0.001f);
  }

  @Test
  void rolloutNeedsScrollbar_falseWhenContentFitsWithinTheVisibleArea () {
    setExplicitRolloutBounds();
    app.UI_rollout.rolloutContentTopY = 200;
    app.UI_rollout.rolloutContentBottomY = 600;
    app.UI_rollout.rolloutContentHeight = 400; // exactly fits
    assertFalse(app.UI_rollout.rolloutNeedsScrollbar());
  }

  @Test
  void rolloutNeedsScrollbar_trueWhenContentIsTallerThanTheVisibleArea () {
    setScrollableContent();
    assertTrue(app.UI_rollout.rolloutNeedsScrollbar());
  }

  @Test
  void rolloutScrollbarOuterRect_isRightAlignedAndSpansTheVisibleContentHeight () {
    setScrollableContent();
    float[] bar = app.UI_rollout.rolloutScrollbarOuterRect();
    assertEquals(389.5f, bar[0], 0.01f);
    assertEquals(200f, bar[1], 0.01f);
    assertEquals(8.5f, bar[2], 0.01f);
    assertEquals(400f, bar[3], 0.01f);
  }

  @Test
  void rolloutScrollUpButtonRect_isASquareAtTheTopOfTheBar () {
    setScrollableContent();
    float[] up = app.UI_rollout.rolloutScrollUpButtonRect();
    assertEquals(389.5f, up[0], 0.01f);
    assertEquals(200f, up[1], 0.01f);
    assertEquals(8.5f, up[2], 0.01f);
    assertEquals(8.5f, up[3], 0.01f);
  }

  @Test
  void rolloutScrollDownButtonRect_isASquareAtTheBottomOfTheBar () {
    setScrollableContent();
    float[] down = app.UI_rollout.rolloutScrollDownButtonRect();
    assertEquals(389.5f, down[0], 0.01f);
    assertEquals(591.5f, down[1], 0.01f);
    assertEquals(8.5f, down[2], 0.01f);
    assertEquals(8.5f, down[3], 0.01f);
  }

  @Test
  void rolloutScrollTrackRect_isTheBarMinusBothButtons () {
    setScrollableContent();
    float[] track = app.UI_rollout.rolloutScrollTrackRect();
    assertEquals(389.5f, track[0], 0.01f);
    assertEquals(208.5f, track[1], 0.01f);
    assertEquals(8.5f, track[2], 0.01f);
    assertEquals(383f, track[3], 0.01f);
  }

  @Test
  void rolloutScrollThumbRect_sizedProportionallyToTheVisibleFraction_atTheTrackTopWhenUnscrolled () {
    setScrollableContent();
    app.UI_rollout.rolloutScrollY = 0;
    float[] thumb = app.UI_rollout.rolloutScrollThumbRect();
    assertEquals(208.5f, thumb[1], 0.01f); // track top
    assertEquals(153.2f, thumb[3], 0.1f);
  }

  @Test
  void rolloutScrollThumbRect_atTheTrackBottomWhenScrolledToTheMax () {
    setScrollableContent();
    app.UI_rollout.rolloutScrollY = 600; // maxScroll
    float[] thumb = app.UI_rollout.rolloutScrollThumbRect();
    assertEquals(438.3f, thumb[1], 0.1f); // 208.5 + travel (229.8)
  }

  @Test
  void rolloutScrollThumbRect_neverShrinksBelowTheMinimumHandleSize () {
    setScrollableContent();
    app.UI_rollout.rolloutContentHeight = 100000; // tiny visible fraction of a huge tab
    float[] thumb = app.UI_rollout.rolloutScrollThumbRect();
    assertEquals(20f, thumb[3], 0.01f); // 20 * view_S, view_S == 1 here
  }

  // --- handleRolloutScrollButtonClicks ---------------------------------------

  @Test
  void handleRolloutScrollButtonClicks_onTheUpButton_stepsUpAndConsumesTheClick () {
    setScrollableContent();
    app.UI_rollout.rolloutScrollY = 300;
    float[] up = app.UI_rollout.rolloutScrollUpButtonRect();
    app.X_clicked = (int) (up[0] + 0.5f * up[2]);
    app.Y_clicked = (int) (up[1] + 0.5f * up[3]);

    app.UI_rollout.handleRolloutScrollButtonClicks(up, app.UI_rollout.rolloutScrollDownButtonRect());

    assertEquals(276f, app.UI_rollout.rolloutScrollY, 0.01f); // 300 - 24*view_S
    assertEquals(-1, app.X_clicked);
    assertEquals(-1, app.Y_clicked);
  }

  @Test
  void handleRolloutScrollButtonClicks_onTheUpButton_clampsAtZero () {
    setScrollableContent();
    app.UI_rollout.rolloutScrollY = 10; // less than one step from zero
    float[] up = app.UI_rollout.rolloutScrollUpButtonRect();
    app.X_clicked = (int) (up[0] + 0.5f * up[2]);
    app.Y_clicked = (int) (up[1] + 0.5f * up[3]);

    app.UI_rollout.handleRolloutScrollButtonClicks(up, app.UI_rollout.rolloutScrollDownButtonRect());

    assertEquals(0f, app.UI_rollout.rolloutScrollY, 0.01f);
  }

  @Test
  void handleRolloutScrollButtonClicks_onTheDownButton_stepsDownAndClampsAtMaxScroll () {
    setScrollableContent();
    app.UI_rollout.rolloutScrollY = 590; // less than one step from the 600 max
    float[] down = app.UI_rollout.rolloutScrollDownButtonRect();
    app.X_clicked = (int) (down[0] + 0.5f * down[2]);
    app.Y_clicked = (int) (down[1] + 0.5f * down[3]);

    app.UI_rollout.handleRolloutScrollButtonClicks(app.UI_rollout.rolloutScrollUpButtonRect(), down);

    assertEquals(600f, app.UI_rollout.rolloutScrollY, 0.01f);
  }

  @Test
  void handleRolloutScrollButtonClicks_outsideBothButtons_doesNothing () {
    setScrollableContent();
    app.UI_rollout.rolloutScrollY = 300;
    app.X_clicked = 0; // nowhere near either button
    app.Y_clicked = 0;

    app.UI_rollout.handleRolloutScrollButtonClicks(app.UI_rollout.rolloutScrollUpButtonRect(), app.UI_rollout.rolloutScrollDownButtonRect());

    assertEquals(300f, app.UI_rollout.rolloutScrollY, 0.01f);
    assertEquals(0, app.X_clicked); // left alone - this click wasn't ours to consume
  }

  @Test
  void handleRolloutScrollButtonClicks_whileEditingASpinner_doesNothing () {
    setScrollableContent();
    app.UI_rollout.editActive = true;
    app.UI_rollout.rolloutScrollY = 300;
    float[] up = app.UI_rollout.rolloutScrollUpButtonRect();
    app.X_clicked = (int) (up[0] + 0.5f * up[2]);
    app.Y_clicked = (int) (up[1] + 0.5f * up[3]);

    app.UI_rollout.handleRolloutScrollButtonClicks(up, app.UI_rollout.rolloutScrollDownButtonRect());

    assertEquals(300f, app.UI_rollout.rolloutScrollY, 0.01f);
    assertEquals((int) (up[0] + 0.5f * up[2]), app.X_clicked); // click left untouched/unconsumed
  }

  // --- handleRolloutScrollTrackClick ------------------------------------------

  @Test
  void handleRolloutScrollTrackClick_aboveTheThumb_pagesUp () {
    setScrollableContent();
    app.UI_rollout.rolloutScrollY = 600; // thumb sits at the track's own bottom
    float[] track = app.UI_rollout.rolloutScrollTrackRect();
    float[] thumb = app.UI_rollout.rolloutScrollThumbRect();
    app.X_clicked = (int) (track[0] + 0.5f * track[2]);
    app.Y_clicked = (int) (track[1] + 10); // above the thumb, inside the track

    app.UI_rollout.handleRolloutScrollTrackClick(track, thumb);

    assertEquals(224f, app.UI_rollout.rolloutScrollY, 0.5f); // 600 - page (376)
    assertEquals(-1, app.X_clicked);
  }

  @Test
  void handleRolloutScrollTrackClick_belowTheThumb_pagesDown () {
    setScrollableContent();
    app.UI_rollout.rolloutScrollY = 0; // thumb sits at the track's own top
    float[] track = app.UI_rollout.rolloutScrollTrackRect();
    float[] thumb = app.UI_rollout.rolloutScrollThumbRect();
    app.X_clicked = (int) (track[0] + 0.5f * track[2]);
    app.Y_clicked = (int) (track[1] + track[3] - 10); // below the thumb, inside the track

    app.UI_rollout.handleRolloutScrollTrackClick(track, thumb);

    assertEquals(376f, app.UI_rollout.rolloutScrollY, 0.5f); // 0 + page (376)
  }

  @Test
  void handleRolloutScrollTrackClick_onTheThumbItself_doesNothing_leftToHandleScrollDragInstead () {
    setScrollableContent();
    app.UI_rollout.rolloutScrollY = 300;
    float[] track = app.UI_rollout.rolloutScrollTrackRect();
    float[] thumb = app.UI_rollout.rolloutScrollThumbRect();
    app.X_clicked = (int) (thumb[0] + 0.5f * thumb[2]);
    app.Y_clicked = (int) (thumb[1] + 0.5f * thumb[3]);

    app.UI_rollout.handleRolloutScrollTrackClick(track, thumb);

    assertEquals(300f, app.UI_rollout.rolloutScrollY, 0.01f);
    assertNotEquals(-1, app.X_clicked); // not consumed - a drag may still claim it
  }

  @Test
  void handleRolloutScrollTrackClick_whileEditingASpinner_doesNothing () {
    setScrollableContent();
    app.UI_rollout.editActive = true;
    app.UI_rollout.rolloutScrollY = 0;
    float[] track = app.UI_rollout.rolloutScrollTrackRect();
    float[] thumb = app.UI_rollout.rolloutScrollThumbRect();
    app.X_clicked = (int) (track[0] + 0.5f * track[2]);
    app.Y_clicked = (int) (track[1] + track[3] - 10);

    app.UI_rollout.handleRolloutScrollTrackClick(track, thumb);

    assertEquals(0f, app.UI_rollout.rolloutScrollY, 0.01f);
  }

  // --- handleScrollDrag ---------------------------------------------------------

  @Test
  void handleScrollDrag_returnsFalseWhenThisTabDoesNotNeedAScrollbar () {
    setExplicitRolloutBounds();
    app.UI_rollout.rolloutContentTopY = 200;
    app.UI_rollout.rolloutContentBottomY = 600;
    app.UI_rollout.rolloutContentHeight = 400; // fits - no scrollbar
    assertFalse(app.UI_rollout.handleScrollDrag());
  }

  @Test
  void handleScrollDrag_returnsFalseWhenThisTabIsNotIncluded () {
    setScrollableContent();
    app.UI_rollout.include = false;
    assertFalse(app.UI_rollout.handleScrollDrag());
  }

  @Test
  void handleScrollDrag_returnsFalseWhenAnotherGestureAlreadyClaimedThisDrag () {
    setScrollableContent();
    app.UI_rollout.rolloutScrollThumbDragging = false;
    app.dragging_started = 1; // some other drag (e.g. WORLD panning) already claimed it

    assertFalse(app.UI_rollout.handleScrollDrag());
    assertFalse(app.UI_rollout.rolloutScrollThumbDragging);
  }

  @Test
  void handleScrollDrag_mouseDownOutsideTheThumb_doesNotStartADrag () {
    setScrollableContent();
    app.UI_rollout.rolloutScrollThumbDragging = false;
    app.dragging_started = 0;
    app.pmouseX = 0; // nowhere near the thumb
    app.pmouseY = 0;

    assertFalse(app.UI_rollout.handleScrollDrag());
    assertFalse(app.UI_rollout.rolloutScrollThumbDragging);
    assertEquals(0, app.dragging_started); // never claimed
  }

  @Test
  void handleScrollDrag_mouseDownOnTheThumb_claimsTheDragAndStartsFromTheCurrentScroll () {
    setScrollableContent();
    app.UI_rollout.rolloutScrollY = 300;
    app.UI_rollout.rolloutScrollThumbDragging = false;
    app.dragging_started = 0;
    float[] thumb = app.UI_rollout.rolloutScrollThumbRect();
    app.pmouseX = (int) (thumb[0] + 0.5f * thumb[2]);
    app.pmouseY = (int) (thumb[1] + 0.5f * thumb[3]);
    app.mouseY = app.pmouseY; // no movement yet this same frame

    assertTrue(app.UI_rollout.handleScrollDrag());

    assertTrue(app.UI_rollout.rolloutScrollThumbDragging);
    assertEquals(1, app.dragging_started);
    assertEquals(app.pmouseX, app.X_click1);
    assertEquals(app.pmouseY, app.Y_click1);
    assertEquals(300f, app.UI_rollout.rolloutScrollY, 0.01f); // unchanged - zero delta so far
  }

  @Test
  void handleScrollDrag_alreadyDragging_movesScrollYProportionallyToMouseMovement () {
    setScrollableContent();
    app.UI_rollout.rolloutScrollThumbDragging = true; // mid-drag already - skips the "start" branch
    app.UI_rollout.rolloutScrollDrag_startMouseY = 100;
    app.UI_rollout.rolloutScrollDrag_startScrollY = 0;
    app.mouseY = 100 + 115; // mouseY is int - close to half the thumb's own travel (229.8)

    assertTrue(app.UI_rollout.handleScrollDrag());

    assertEquals(300f, app.UI_rollout.rolloutScrollY, 5f); // roughly half of maxScroll (600)
  }

  @Test
  void handleScrollDrag_alreadyDragging_clampsAtTheMaxScroll () {
    setScrollableContent();
    app.UI_rollout.rolloutScrollThumbDragging = true;
    app.UI_rollout.rolloutScrollDrag_startMouseY = 100;
    app.UI_rollout.rolloutScrollDrag_startScrollY = 0;
    app.mouseY = 100 + 1000; // far past the thumb's own travel

    assertTrue(app.UI_rollout.handleScrollDrag());

    assertEquals(600f, app.UI_rollout.rolloutScrollY, 0.01f);
  }

  // --- handleWheel ---------------------------------------------------------------

  @Test
  void handleWheel_returnsFalseWhenThisTabIsNotIncluded () {
    setScrollableContent();
    app.UI_rollout.include = false;
    assertFalse(app.UI_rollout.handleWheel(1));
  }

  @Test
  void handleWheel_returnsFalseWhenThisTabDoesNotNeedAScrollbar () {
    setExplicitRolloutBounds();
    app.UI_rollout.rolloutContentTopY = 200;
    app.UI_rollout.rolloutContentBottomY = 600;
    app.UI_rollout.rolloutContentHeight = 400; // fits
    assertFalse(app.UI_rollout.handleWheel(1));
  }

  @Test
  void handleWheel_returnsFalseWhenTheMouseIsNotOverThePanel () {
    setScrollableContent();
    app.X_clicked = 0; // nowhere near the panel
    app.Y_clicked = 0;
    assertFalse(app.UI_rollout.handleWheel(1));
  }

  @Test
  void handleWheel_positiveValue_scrollsDownByOneStepAndConsumesTheEvent () {
    setScrollableContent();
    app.UI_rollout.rolloutScrollY = 300;
    app.X_clicked = (int) (app.UI_rollout.cX + 0.5f * app.UI_rollout.dX);
    app.Y_clicked = (int) (0.5f * (app.UI_rollout.rolloutContentTopY + app.UI_rollout.rolloutContentBottomY));

    assertTrue(app.UI_rollout.handleWheel(1));

    assertEquals(324f, app.UI_rollout.rolloutScrollY, 0.01f); // 300 + 24*view_S
  }

  @Test
  void handleWheel_negativeValue_scrollsUpByOneStep () {
    setScrollableContent();
    app.UI_rollout.rolloutScrollY = 300;
    app.X_clicked = (int) (app.UI_rollout.cX + 0.5f * app.UI_rollout.dX);
    app.Y_clicked = (int) (0.5f * (app.UI_rollout.rolloutContentTopY + app.UI_rollout.rolloutContentBottomY));

    assertTrue(app.UI_rollout.handleWheel(-1));

    assertEquals(276f, app.UI_rollout.rolloutScrollY, 0.01f); // 300 - 24*view_S
  }

  @Test
  void handleWheel_clampsAtTheScrollBounds () {
    setScrollableContent();
    app.UI_rollout.rolloutScrollY = 590;
    app.X_clicked = (int) (app.UI_rollout.cX + 0.5f * app.UI_rollout.dX);
    app.Y_clicked = (int) (0.5f * (app.UI_rollout.rolloutContentTopY + app.UI_rollout.rolloutContentBottomY));

    assertTrue(app.UI_rollout.handleWheel(1));

    assertEquals(600f, app.UI_rollout.rolloutScrollY, 0.01f);
  }
}
