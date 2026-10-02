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
class Key2DActionsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // fresh app never runs build_allActions() itself
    app.build_allActions();
  }

  // ================= key2D Ctrl+Up / key2D Ctrl+Down (layer cycling) =====

  @Test
  void keyCtrlUp_cyclesLayerForwardAndWrapsAtTheEnd () {
    app.currentLayerId = app.allLayers.length - 1;

    String hint = app.runScriptLine("key2D Ctrl+Up");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(0, app.currentLayerId);
  }

  @Test
  void keyCtrlDown_cyclesLayerBackwardAndWrapsAtTheStart () {
    app.currentLayerId = 0;

    String hint = app.runScriptLine("key2D Ctrl+Down");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(app.allLayers.length - 1, app.currentLayerId);
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

    app.runScriptLine("key2D Ctrl+Up");

    assertEquals(app.allLayers[app.currentLayerId].verticalUnitScale, app.STUDY.verticalUnitScale, 0.0001f);
  }

  // ================= key2D Ctrl+Right / key2D Ctrl+Left (impact graph) ===

  @Test
  void keyCtrlRight_cyclesImpactGraphIndexForwardAndWraps () {
    app.STUDY.impactGraphIndex = app.STUDY.PLOT_IMPACTS_MODE_COUNT - 1;

    String hint = app.runScriptLine("key2D Ctrl+Right");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(0, app.STUDY.impactGraphIndex);
  }

  @Test
  void keyCtrlLeft_cyclesImpactGraphIndexBackwardAndWraps () {
    app.STUDY.impactGraphIndex = 0;

    String hint = app.runScriptLine("key2D Ctrl+Left");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(app.STUDY.PLOT_IMPACTS_MODE_COUNT - 1, app.STUDY.impactGraphIndex);
  }

  // ================= key2D Ctrl+PageUp / key2D Ctrl+PageDown ==============

  @Test
  void keyCtrlPageUp_and_keyCtrlPageDown_areEachOthersInverse () {
    app.STUDY.plotLayoutIndex = 0;

    String upHint = app.runScriptLine("key2D Ctrl+PageUp");
    int afterUp = app.STUDY.plotLayoutIndex;

    String downHint = app.runScriptLine("key2D Ctrl+PageDown");

    assertNotEquals(app.UnrecognizedCommand, upHint);
    assertNotEquals(app.UnrecognizedCommand, downHint);
    assertNotEquals(0, afterUp, "PageUp from 0 should actually move somewhere");
    assertEquals(0, app.STUDY.plotLayoutIndex, "PageDown should undo PageUp exactly");
  }

  // ================= key2D Ctrl+; / Ctrl+" / Ctrl+' =======================

  @Test
  void keyCtrlSemicolon_togglesImpactSummary () {
    app.STUDY.showImpactSummary = false;

    String hint = app.runScriptLine("key2D Ctrl+;");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.STUDY.showImpactSummary);

    app.runScriptLine("key2D Ctrl+;");
    assertFalse(app.STUDY.showImpactSummary);
  }

  @Test
  void keyCtrlDoubleQuote_scalesVerticalUnitScaleUp () {
    app.STUDY.verticalUnitScale = 10;

    String hint = app.runScriptLine("key2D Ctrl+\"");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(10 * Math.sqrt(2.0), app.STUDY.verticalUnitScale, 0.0001f);
  }

  @Test
  void keyCtrlSingleQuote_scalesVerticalUnitScaleDown () {
    app.STUDY.verticalUnitScale = 10;

    String hint = app.runScriptLine("key2D Ctrl+'");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(10 * Math.sqrt(0.5), app.STUDY.verticalUnitScale, 0.0001f);
  }

  // ================= key2D > / key2D < (day-joining window) ==============

  @Test
  void keyGreaterThan_widensTheJoinWindowByTwoDays () {
    app.STUDY.daysMergedCount = 10;

    String hint = app.runScriptLine("key2D >");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(12, app.STUDY.daysMergedCount);
  }

  @Test
  void keyGreaterThan_clampsAt365 () {
    app.STUDY.daysMergedCount = 365;

    app.runScriptLine("key2D >");

    assertEquals(365, app.STUDY.daysMergedCount);
  }

  @Test
  void keyLessThan_narrowsTheJoinWindowByTwoDays () {
    app.STUDY.daysMergedCount = 10;

    String hint = app.runScriptLine("key2D <");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(8, app.STUDY.daysMergedCount);
  }

  @Test
  void keyLessThan_clampsAt1 () {
    app.STUDY.daysMergedCount = 1;

    app.runScriptLine("key2D <");

    assertEquals(1, app.STUDY.daysMergedCount);
  }

  // ================= key2D ) / key2D ( (date column count) ================

  @Test
  void keyCloseParen_growsEndDayByOne () {
    app.STUDY.startDay = 0;
    app.STUDY.endDay = 10;

    String hint = app.runScriptLine("key2D )");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(11, app.STUDY.endDay);
  }

  @Test
  void keyOpenParen_shrinksEndDayByOne () {
    app.STUDY.startDay = 0;
    app.STUDY.endDay = 10;

    String hint = app.runScriptLine("key2D (");

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

    app.runScriptLine("key2D (");

    assertTrue(app.STUDY.endDay > app.STUDY.startDay);
  }

  // ================= key2D Shift+S / key2D s (sky scenario) ===============

  @Test
  void keyShiftS_cyclesSkyScenarioForward () {
    app.STUDY.skyScenarioSetting = 1;

    String hint = app.runScriptLine("key2D Shift+S");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(2, app.STUDY.skyScenarioSetting);
  }

  @Test
  void keyS_cyclesSkyScenarioBackwardAndWrapsToFour () {
    app.STUDY.skyScenarioSetting = 1;

    String hint = app.runScriptLine("key2D s");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(4, app.STUDY.skyScenarioSetting);
  }

  // ================= key2D v/m/n/b (display toggles) ======================

  @Test
  void keyV_togglesShowRawLines () {
    app.STUDY.showRawLines = false;

    String hint = app.runScriptLine("key2D v");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.STUDY.showRawLines);
  }

  @Test
  void keyM_togglesShowStatisticalRanges () {
    app.STUDY.showStatisticalRanges = false;

    String hint = app.runScriptLine("key2D m");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.STUDY.showStatisticalRanges);
  }

  @Test
  void keyN_togglesShowNormalLines () {
    app.STUDY.showNormalLines = false;

    String hint = app.runScriptLine("key2D n");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.STUDY.showNormalLines);
  }

  @Test
  void keyB_togglesShowProbabilities () {
    app.STUDY.showProbabilities = false;

    String hint = app.runScriptLine("key2D b");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.STUDY.showProbabilities);
  }

  // ================= key2D { / key2D } (probability height interval) =====

  @Test
  void keyOpenBrace_doublesProbabilityHeightInterval () {
    app.STUDY.probabilityHeightInterval = 4;

    String hint = app.runScriptLine("key2D {");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(8f, app.STUDY.probabilityHeightInterval, 0.0001f);
  }

  @Test
  void keyOpenBrace_doesNotGrowPast32 () {
    app.STUDY.probabilityHeightInterval = 32;

    app.runScriptLine("key2D {");

    assertEquals(32f, app.STUDY.probabilityHeightInterval, 0.0001f);
  }

  @Test
  void keyCloseBrace_halvesProbabilityHeightInterval () {
    app.STUDY.probabilityHeightInterval = 8;

    String hint = app.runScriptLine("key2D }");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(4f, app.STUDY.probabilityHeightInterval, 0.0001f);
  }

  @Test
  void keyCloseBrace_doesNotShrinkPast2 () {
    app.STUDY.probabilityHeightInterval = 2;

    app.runScriptLine("key2D }");

    assertEquals(2f, app.STUDY.probabilityHeightInterval, 0.0001f);
  }

  // ================= key2D [ / key2D ] (sum interval) ======================

  // Traced by hand rather than assumed from the comment's "24 -> 6 -> 1"
  // step-sequence summary: one call steps by 6 while above that
  // threshold (24 is not > 24, so the first guard is skipped; 24 > 6, so
  // it becomes 24-6=18), it doesn't jump straight to the next named
  // threshold.
  @Test
  void keyOpenBracket_decreasesSumInterval () {
    app.STUDY.probabilityWidthInterval = 24;

    String hint = app.runScriptLine("key2D [");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(18, app.STUDY.probabilityWidthInterval);
  }

  @Test
  void keyCloseBracket_increasesSumInterval () {
    app.STUDY.probabilityWidthInterval = 1;

    String hint = app.runScriptLine("key2D ]");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(2, app.STUDY.probabilityWidthInterval);
  }
}
