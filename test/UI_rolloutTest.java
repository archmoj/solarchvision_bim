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
}
