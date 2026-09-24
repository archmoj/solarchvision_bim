import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// putAction/putValueAction (a private helper and a package-visible one,
// respectively) are exercised together here since putValueAction is the
// only way to reach putAction's Action-taking overload from outside
// actions.pde - which is also how every ValueModifier.pde method and
// UI_rollout.registerSpinnerActions() actually reach it, so this is
// exercising the real path, not a shortcut around it.
class ActionsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>();
  }

  // ================= reviseByUpdateFlags ===================================

  @Test
  void reviseByUpdateFlags_zeroFlags_revisesNothing () {
    app.UI_caseBar.update = false;
    app.STUDY.update = false;
    app.WIN3D.update = false;
    app.WORLD.update = false;
    app.UI_rollout.update = false;

    app.reviseByUpdateFlags(0, 0, 0);

    assertFalse(app.UI_caseBar.update);
    assertFalse(app.STUDY.update);
    assertFalse(app.WIN3D.update);
    assertFalse(app.WORLD.update);
    assertFalse(app.UI_rollout.update);
  }

  @Test
  void reviseByUpdateFlags_update1_revisesCaseBarStudyAndRollout () {
    app.UI_caseBar.update = false;
    app.STUDY.update = false;
    app.WIN3D.update = false;
    app.UI_rollout.update = false;

    app.reviseByUpdateFlags(1, 0, 0);

    assertTrue(app.UI_caseBar.update);
    assertTrue(app.STUDY.update);
    assertTrue(app.UI_rollout.update);
    assertFalse(app.WIN3D.update); // update2/update3 weren't set
  }

  @Test
  void reviseByUpdateFlags_update2_revisesWIN3DAndRollout () {
    app.WIN3D.update = false;
    app.STUDY.update = false;
    app.UI_rollout.update = false;

    app.reviseByUpdateFlags(0, 1, 0);

    assertTrue(app.WIN3D.update);
    assertTrue(app.UI_rollout.update);
    assertFalse(app.STUDY.update);
  }

  @Test
  void reviseByUpdateFlags_update3_revisesWORLDAndRollout () {
    app.WORLD.update = false;
    app.UI_rollout.update = false;

    app.reviseByUpdateFlags(0, 0, 1);

    assertTrue(app.WORLD.update);
    assertTrue(app.UI_rollout.update);
  }

  // ================= putValueAction: registration ==========================

  @Test
  void putValueAction_registersUnderTheNormalizedKey () {
    float[] value = {5};
    app.putValueAction("Test Field",
      () -> value[0],
      (v) -> { value[0] = v; },
      0, 100, 1,
      0, 0, 0);

    assertTrue(app.allActions.containsKey("test_field"));
  }

  @Test
  void putValueAction_multiWordName_alsoRegistersTheLiteralLowercasedCaption () {
    // putAction's "withSpace" fallback (for menu items like "Select Group")
    // applies here too, since putValueAction reaches it the same way.
    float[] value = {5};
    app.putValueAction("Test Field",
      () -> value[0],
      (v) -> { value[0] = v; },
      0, 100, 1,
      0, 0, 0);

    assertTrue(app.allActions.containsKey("test field"));
    assertSame(app.allActions.get("test_field"), app.allActions.get("test field"));
  }

  // ================= putValueAction: validation/rounding ===================

  @Test
  void putValueAction_setsTheRequestedValue_whenWithinRange () {
    float[] value = {5};
    app.putValueAction("Test Field",
      () -> value[0],
      (v) -> { value[0] = v; },
      0, 100, 1,
      0, 0, 0);

    app.allActions.get("test_field").run(new String[]{"test_field", "42"});

    assertEquals(42, value[0], 0.001f);
  }

  @Test
  void putValueAction_ignoresOutOfRangeValue () {
    float[] value = {5};
    app.putValueAction("Test Field",
      () -> value[0],
      (v) -> { value[0] = v; },
      0, 100, 1,
      0, 0, 0);

    app.allActions.get("test_field").run(new String[]{"test_field", "150"});

    assertEquals(5, value[0], 0.001f); // unchanged
  }

  @Test
  void putValueAction_ignoresNonNumericValue () {
    float[] value = {5};
    app.putValueAction("Test Field",
      () -> value[0],
      (v) -> { value[0] = v; },
      0, 100, 1,
      0, 0, 0);

    app.allActions.get("test_field").run(new String[]{"test_field", "not-a-number"});

    assertEquals(5, value[0], 0.001f); // unchanged
  }

  @Test
  void putValueAction_missingValueArgument_doesNotThrowOrChangeTheField () {
    float[] value = {5};
    app.putValueAction("Test Field",
      () -> value[0],
      (v) -> { value[0] = v; },
      0, 100, 1,
      0, 0, 0);

    assertDoesNotThrow(() -> app.allActions.get("test_field").run(new String[]{"test_field"}));
    assertEquals(5, value[0], 0.001f);
  }

  @Test
  void putValueAction_roundsToTheNearestStep () {
    float[] value = {0};
    app.putValueAction("Test Field",
      () -> value[0],
      (v) -> { value[0] = v; },
      0, 100, 5,
      0, 0, 0);

    app.allActions.get("test_field").run(new String[]{"test_field", "42"});

    assertEquals(40, value[0], 0.001f); // matches funcs.roundTo(42, 5)
  }

  // ================= putValueAction: no-op when unchanged ===================

  @Test
  void putValueAction_doesNotRevise_whenTheRoundedValueEqualsTheCurrentOne () {
    float[] value = {10};
    app.STUDY.update = false;
    app.UI_caseBar.update = false;

    app.putValueAction("Test Field",
      () -> value[0],
      (v) -> { value[0] = v; },
      0, 100, 1,
      1, 0, 0);

    app.allActions.get("test_field").run(new String[]{"test_field", "10"});

    assertFalse(app.STUDY.update);
    assertFalse(app.UI_caseBar.update);
  }

  @Test
  void putValueAction_revises_whenTheValueActuallyChanges () {
    float[] value = {10};
    app.STUDY.update = false;
    app.UI_caseBar.update = false;

    app.putValueAction("Test Field",
      () -> value[0],
      (v) -> { value[0] = v; },
      0, 100, 1,
      1, 0, 0);

    app.allActions.get("test_field").run(new String[]{"test_field", "20"});

    assertTrue(app.STUDY.update);
    assertTrue(app.UI_caseBar.update);
  }

  // ================= putValueAction: onChanged ==============================

  @Test
  void putValueAction_onChanged_firesOnlyOnARealChange_withTheOldAndNewValues () {
    float[] value = {10};
    float[] observedOld = {-999};
    float[] observedNew = {-999};
    int[] callCount = {0};

    app.putValueAction("Test Field",
      () -> value[0],
      (v) -> { value[0] = v; },
      0, 100, 1,
      0, 0, 0,
      (o, n) -> { observedOld[0] = o; observedNew[0] = n; callCount[0]++; });

    app.allActions.get("test_field").run(new String[]{"test_field", "10"}); // unchanged
    assertEquals(0, callCount[0]);

    app.allActions.get("test_field").run(new String[]{"test_field", "25"}); // real change
    assertEquals(1, callCount[0]);
    assertEquals(10, observedOld[0], 0.001f);
    assertEquals(25, observedNew[0], 0.001f);
  }

  // ================= putValueAction: dynamic bounds =========================

  @Test
  void putValueAction_dynamicBounds_areReadFreshOnEveryCall_notCachedAtRegistration () {
    float[] value = {0};
    int[] max = {10};

    app.putValueAction("Test Field",
      () -> value[0],
      (v) -> { value[0] = v; },
      () -> 0f, () -> (float) max[0],
      1,
      0, 0, 0);

    app.allActions.get("test_field").run(new String[]{"test_field", "20"}); // out of range while max == 10
    assertEquals(0, value[0], 0.001f);

    max[0] = 30; // widen the bound *after* registration

    app.allActions.get("test_field").run(new String[]{"test_field", "20"}); // now in range
    assertEquals(20, value[0], 0.001f);
  }
}
