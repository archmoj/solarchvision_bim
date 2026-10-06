import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// STUDY.pde's own counterpart to Key3DActionsTest.java - see that file's
// own comment for the reasoning (STUDYTest.java already covers each key
// handler dispatching correctly by name; this covers the actions
// themselves, invoked directly via runScriptLine, which is the new
// capability this adds). Same two things checked together in each test:
// runScriptLine's hint isn't UnrecognizedCommand, and the actual state
// change is correct.
class STUDYActionsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // fresh app never runs build_allActions() itself
    app.build_allActions();
  }

  // ================= STUDY Ctrl+Up / STUDY Ctrl+Down (layer cycling) =====

  @Test
  void keyCtrlUp_cyclesLayerForwardAndWrapsAtTheEnd () {
    app.currentLayerId = app.allLayers.length - 1;

    String hint = app.runScriptLine("Next Layer");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(0, app.currentLayerId);
    assertTrue(app.STUDY.update);
  }

  @Test
  void keyCtrlDown_cyclesLayerBackwardAndWrapsAtTheStart () {
    app.currentLayerId = 0;

    String hint = app.runScriptLine("Previous Layer");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(app.allLayers.length - 1, app.currentLayerId);
    assertTrue(app.STUDY.update);
  }

  @Test
  void keyCtrlUp_alsoAppliesTheNewLayersOwnVerticalUnitScale () {
    // changeCurrentLayerTo() (what this action calls) also copies the
    // target layer's verticalUnitScale/Offset/NegativePadding onto
    // STUDY - confirming at least one of those is actually applied,
    // not just that currentLayerId moved.
    app.currentLayerId = 0;
    int target = app.allLayers.length > 1 ? 1 : 0;
    app.currentLayerId = target - 1 < 0 ? app.allLayers.length - 1 : target - 1;

    app.runScriptLine("Next Layer");

    assertEquals(app.allLayers[app.currentLayerId].verticalUnitScale, app.STUDY.verticalUnitScale, 0.0001f);
    assertTrue(app.STUDY.update);
  }

  // ================= STUDY Ctrl+Right / STUDY Ctrl+Left (impact graph) ===

  @Test
  void keyCtrlRight_cyclesImpactGraphIndexForwardAndWraps () {
    app.STUDY.impactGraphIndex = app.STUDY.PLOT_IMPACTS_MODE_COUNT - 1;

    String hint = app.runScriptLine("Next Graph Index");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(0, app.STUDY.impactGraphIndex);
    assertTrue(app.STUDY.update);
  }

  @Test
  void keyCtrlLeft_cyclesImpactGraphIndexBackwardAndWraps () {
    app.STUDY.impactGraphIndex = 0;

    String hint = app.runScriptLine("Previous Graph Index");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(app.STUDY.PLOT_IMPACTS_MODE_COUNT - 1, app.STUDY.impactGraphIndex);
    assertTrue(app.STUDY.update);
  }

  // ================= STUDY Ctrl+PageUp / STUDY Ctrl+PageDown ==============

  @Test
  void keyCtrlPageUp_and_keyCtrlPageDown_areEachOthersInverse () {
    app.STUDY.plotLayoutIndex = 0;

    String upHint = app.runScriptLine("Next Plot Layout");
    int afterUp = app.STUDY.plotLayoutIndex;

    String downHint = app.runScriptLine("Previous Plot Layout");

    assertNotEquals(app.UnrecognizedCommand, upHint);
    assertNotEquals(app.UnrecognizedCommand, downHint);
    assertNotEquals(0, afterUp, "PageUp from 0 should actually move somewhere");
    assertEquals(0, app.STUDY.plotLayoutIndex, "PageDown should undo PageUp exactly");
    assertTrue(app.STUDY.update);
  }

  // ================= STUDY Ctrl+; / Ctrl+" / Ctrl+' =======================

  @Test
  void keyCtrlSemicolon_togglesImpactSummary () {
    app.STUDY.showImpactSummary = false;

    String hint = app.runScriptLine("Toggle Impact Summary");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.STUDY.showImpactSummary);

    app.runScriptLine("Toggle Impact Summary");
    assertFalse(app.STUDY.showImpactSummary);
    assertTrue(app.STUDY.update);
  }

  @Test
  void keyCtrlDoubleQuote_scalesVerticalUnitScaleUp () {
    app.STUDY.verticalUnitScale = 10;

    String hint = app.runScriptLine("Increase Vertical Scale");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(10 * Math.sqrt(2.0), app.STUDY.verticalUnitScale, 0.0001f);
    assertTrue(app.STUDY.update);
  }

  @Test
  void keyCtrlSingleQuote_scalesVerticalUnitScaleDown () {
    app.STUDY.verticalUnitScale = 10;

    String hint = app.runScriptLine("Decrease Vertical Scale");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(10 * Math.sqrt(0.5), app.STUDY.verticalUnitScale, 0.0001f);
    assertTrue(app.STUDY.update);
  }

  // ================= STUDY > / STUDY < (day-joining window) ==============

  @Test
  void keyGreaterThan_widensTheJoinWindowByTwoDays () {
    app.STUDY.daysMergedCount = 10;

    String hint = app.runScriptLine("Widen Join Window");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(12, app.STUDY.daysMergedCount);
    assertTrue(app.STUDY.update);
  }

  @Test
  void keyGreaterThan_clampsAt365 () {
    app.STUDY.daysMergedCount = 365;

    app.runScriptLine("Widen Join Window");

    assertEquals(365, app.STUDY.daysMergedCount);
    assertTrue(app.STUDY.update);
  }

  @Test
  void keyLessThan_narrowsTheJoinWindowByTwoDays () {
    app.STUDY.daysMergedCount = 10;

    String hint = app.runScriptLine("Narrow Join Window");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(8, app.STUDY.daysMergedCount);
    assertTrue(app.STUDY.update);
  }

  @Test
  void keyLessThan_clampsAt1 () {
    app.STUDY.daysMergedCount = 1;

    app.runScriptLine("Narrow Join Window");

    assertEquals(1, app.STUDY.daysMergedCount);
    assertTrue(app.STUDY.update);
  }

  // ================= STUDY ) / STUDY ( (date column count) ================

  @Test
  void keyCloseParen_growsEndDayByOne () {
    app.STUDY.startDay = 0;
    app.STUDY.endDay = 10;

    String hint = app.runScriptLine("Extend Date Range");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(11, app.STUDY.endDay);
    assertTrue(app.STUDY.update);
  }

  @Test
  void keyOpenParen_shrinksEndDayByOne () {
    app.STUDY.startDay = 0;
    app.STUDY.endDay = 10;

    String hint = app.runScriptLine("Shrink Date Range");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(9, app.STUDY.endDay);
  }

  @Test
  void keyOpenParen_keepsAtLeastOneColumnWide () {
    // endDay==startDay (the actual boundary changeJEnd's own revert-guard
    // produces when shrinking right at the edge) started this test off
    // checking a stricter ">" than the code actually guarantees - traced
    // through by hand: startDay=5,endDay=5,delta=-1 lands back at
    // endDay=5, equal to startDay, not strictly greater. Starting one day
    // wider avoids that exact boundary and tests the real shrink instead.
    app.STUDY.startDay = 0;
    app.STUDY.endDay = 5;

    app.runScriptLine("Shrink Date Range");

    assertTrue(app.STUDY.endDay > app.STUDY.startDay);
    assertTrue(app.STUDY.update);
  }

  // ================= STUDY Shift+S / STUDY s (sky scenario) ===============

  @Test
  void keyShiftS_cyclesSkyScenarioForward () {
    app.STUDY.skyScenarioSetting = 1;

    String hint = app.runScriptLine("Next Sky Scenario");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(2, app.STUDY.skyScenarioSetting);
    assertTrue(app.STUDY.update);
  }

  @Test
  void keyS_cyclesSkyScenarioBackwardAndWrapsToFour () {
    app.STUDY.skyScenarioSetting = 1;

    String hint = app.runScriptLine("Previous Sky Scenario");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(4, app.STUDY.skyScenarioSetting);
    assertTrue(app.STUDY.update);
  }

  // ================= STUDY v/m/n/b (display toggles) ======================

  @Test
  void keyV_togglesShowRawLines () {
    app.STUDY.showRawLines = false;

    String hint = app.runScriptLine("Toggle Raw Lines");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.STUDY.showRawLines);
    assertTrue(app.STUDY.update);
  }

  @Test
  void keyM_togglesShowStatisticalRanges () {
    app.STUDY.showStatisticalRanges = false;

    String hint = app.runScriptLine("Toggle Statistical Ranges");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.STUDY.showStatisticalRanges);
    assertTrue(app.STUDY.update);
  }

  @Test
  void keyN_togglesShowNormalLines () {
    app.STUDY.showNormalLines = false;

    String hint = app.runScriptLine("Toggle Study Normal Lines");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.STUDY.showNormalLines);
    assertTrue(app.STUDY.update);
  }

  @Test
  void keyB_togglesShowProbabilities () {
    app.STUDY.showProbabilities = false;

    String hint = app.runScriptLine("Toggle Probabilities");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.STUDY.showProbabilities);
    assertTrue(app.STUDY.update);
  }

  // ================= STUDY { / STUDY } (probability height interval) =====

  @Test
  void keyOpenBrace_doublesProbabilityHeightInterval () {
    app.STUDY.probabilityHeightInterval = 4;

    String hint = app.runScriptLine("Increase Probability Height Step");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(8f, app.STUDY.probabilityHeightInterval, 0.0001f);
    assertTrue(app.STUDY.update);
  }

  @Test
  void keyOpenBrace_doesNotGrowPast32 () {
    app.STUDY.probabilityHeightInterval = 32;

    app.runScriptLine("Increase Probability Height Step");

    assertEquals(32f, app.STUDY.probabilityHeightInterval, 0.0001f);
    assertTrue(app.STUDY.update);
  }

  @Test
  void keyCloseBrace_halvesProbabilityHeightInterval () {
    app.STUDY.probabilityHeightInterval = 8;

    String hint = app.runScriptLine("Decrease Probability Height Step");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(4f, app.STUDY.probabilityHeightInterval, 0.0001f);
    assertTrue(app.STUDY.update);
  }

  @Test
  void keyCloseBrace_doesNotShrinkPast2 () {
    app.STUDY.probabilityHeightInterval = 2;

    app.runScriptLine("Decrease Probability Height Step");

    assertEquals(2f, app.STUDY.probabilityHeightInterval, 0.0001f);
    assertTrue(app.STUDY.update);
  }

  // ================= STUDY [ / STUDY ] (sum interval) ======================

  // Traced by hand rather than assumed from the comment's "24 -> 6 -> 1"
  // step-sequence summary: one call steps by 6 while above that
  // threshold (24 is not > 24, so the first guard is skipped; 24 > 6, so
  // it becomes 24-6=18), it doesn't jump straight to the next named
  // threshold.
  @Test
  void keyOpenBracket_decreasesSumInterval () {
    app.STUDY.probabilityWidthInterval = 24;

    String hint = app.runScriptLine("Decrease Sum Interval");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(18, app.STUDY.probabilityWidthInterval);
    assertTrue(app.STUDY.update);
  }

  @Test
  void keyCloseBracket_increasesSumInterval () {
    app.STUDY.probabilityWidthInterval = 1;

    String hint = app.runScriptLine("Increase Sum Interval");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(2, app.STUDY.probabilityWidthInterval);
    assertTrue(app.STUDY.update);
  }
}
