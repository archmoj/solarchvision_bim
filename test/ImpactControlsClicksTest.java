import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

// UI_caseBar.handleImpactControlsClicks() (uiCaseBar.pde) was partially
// covered (163/250 instructions) - its own per-cell hit-test
// (impactControlsCellBounds(), a plain 2x5 grid-cell formula) and the
// STUDY.plotLayoutIndex/impactGraphIndex state transitions it drives are
// pure logic, no graphics at all, but none of its own many sub-cases
// (6 cells, several impactGraphIndex-pair transitions per cell) were
// exercised directly.
//
// This covers the simplest of them: cell 0 (n == 0), with STUDY.
// plotLayoutIndex == -1 - its own smallest sub-branch
// (plotLayoutIndex -1 -> -2), chosen specifically to avoid needing the
// exact impactGraphIndex_* constant values for the other, more involved
// sub-cases. The click point's own cell-0 bounds are hand-derived
// directly from impactControlsCellBounds()'s own formula (col = n % 5,
// row = n / 5, rx/ry centered on a 2x5 grid), not guessed.
//
// callAction("Active Shade") - called unconditionally once a click
// lands in cell 0, after the plotLayoutIndex branch - needs allActions
// actually built first (callAction() looks the name up directly, with
// no "not found" guard of its own), so build_allActions() runs in
// setup, the same way several of this suite's other action-dispatch
// tests already do.
class ImpactControlsClicksTest {

  @Test
  void cellZeroClick_withPlotLayoutMinusOne_advancesPlotLayoutIndex () {
    solarchvision_bim app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
    app.build_allActions(); // callAction("Active Shade") needs this registered first

    // Cell 0 of impactControlsCellBounds()'s own 2x5 grid: col=0, row=0,
    // rx=ry=-0.25. With offsetX=offsetY=0, w=h=100: x in (-47.5,-2.5),
    // y in (-45,-5) - (-25,-25) sits safely inside both.
    app.X_clicked = -25;
    app.Y_clicked = -25;
    app.STUDY.plotLayoutIndex = -1;

    app.UI_caseBar.handleImpactControlsClicks(0, 0, 100, 100);

    assertEquals(-2, app.STUDY.plotLayoutIndex);
  }

  @Test
  void clickOutsideEveryCell_doesNothing () {
    solarchvision_bim app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>();
    app.build_allActions();

    app.X_clicked = 10000; // far outside any of the 6 cells
    app.Y_clicked = 10000;
    app.STUDY.plotLayoutIndex = -1;

    assertDoesNotThrow(() -> app.UI_caseBar.handleImpactControlsClicks(0, 0, 100, 100));

    assertEquals(-1, app.STUDY.plotLayoutIndex, "no cell was hit, so nothing should have changed");
  }
}
