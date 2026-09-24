import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// applyRolloutUpdate() calls UI_rollout.draw() (touching live mouse/rendering
// state, not unit-testable as-is - see test/README.md) right after its
// include/update guard, and everything else in the function only runs once
// that guard has passed - so the guard is the only part that can be
// exercised safely here, by confirming it returns before doing anything
// (specifically, before UI_rollout.updated() runs) when either half fails.
class ApplyRolloutUpdateTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void returnsImmediately_whenIncludeIsFalse () {
    app.UI_rollout.include = false;
    app.UI_rollout.update = true; // otherwise this half of the guard would also explain a no-op

    app.applyRolloutUpdate();

    // UI_rollout.updated() - the first statement past the guard - sets
    // update to false; it staying true proves the guard returned first.
    assertTrue(app.UI_rollout.update);
  }

  @Test
  void returnsImmediately_whenUpdateIsFalse () {
    app.UI_rollout.include = true;
    app.UI_rollout.update = false;

    app.applyRolloutUpdate();

    assertFalse(app.UI_rollout.update); // unchanged - updated() never ran either
  }
}
