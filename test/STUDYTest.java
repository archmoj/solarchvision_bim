import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class STUDYTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= isInHourlyRange ===================================

  @Test
  void isInHourlyRange_normalRangeIncludesOnlyHoursBetweenStartAndEnd () {
    app.STUDY.startHour = 8;
    app.STUDY.endHour = 18; // startHour <= endHour -> a normal (non-wrapping) range
    assertFalse(app.STUDY.isInHourlyRange(7));
    assertTrue(app.STUDY.isInHourlyRange(8));
    assertTrue(app.STUDY.isInHourlyRange(18));
    assertFalse(app.STUDY.isInHourlyRange(19));
  }

  @Test
  void isInHourlyRange_wrappingRangeExcludesOnlyHoursStrictlyBetweenEndAndStart () {
    app.STUDY.startHour = 20;
    app.STUDY.endHour = 4; // startHour > endHour -> wraps past midnight
    assertTrue(app.STUDY.isInHourlyRange(23));
    assertTrue(app.STUDY.isInHourlyRange(0));
    assertTrue(app.STUDY.isInHourlyRange(4));
    assertFalse(app.STUDY.isInHourlyRange(12)); // strictly between end and start -> excluded
  }

  // ================= computeWrappedDayIndex (newly extracted) ==========

  @Test
  void computeWrappedDayIndex_mapsJAndJAddToADayOfYearIndex () {
    app.STUDY.dayIncrement = 1;
    app.STUDY.daysMergedCount = 0; // avoids the round(0.5*daysMergedCount) tie-breaking case entirely
    app.TIME.beginDay = 0;

    assertEquals(0, app.STUDY.computeWrappedDayIndex(0, 0));
  }

  @Test
  void computeWrappedDayIndex_wrapsNegativeResultsForward () {
    app.STUDY.dayIncrement = 1;
    app.STUDY.daysMergedCount = 0;
    app.TIME.beginDay = -10;

    assertEquals(355, app.STUDY.computeWrappedDayIndex(0, 0));
  }

  @Test
  void computeWrappedDayIndex_wrapsResultsPast365BackToZero () {
    app.STUDY.dayIncrement = 1;
    app.STUDY.daysMergedCount = 0;
    app.TIME.beginDay = 0;

    assertEquals(35, app.STUDY.computeWrappedDayIndex(400, 0));
  }

  // ================= countDefinedPrefix (newly extracted) ===============

  @Test
  void countDefinedPrefix_countsLeadingDefinedValues () {
    float u = app.FLOAT_undefined;
    assertEquals(3, app.STUDY.countDefinedPrefix(new float[]{1, 2, 3, u, u}));
  }

  @Test
  void countDefinedPrefix_isZeroWhenTheFirstValueIsAlreadyUndefined () {
    float u = app.FLOAT_undefined;
    assertEquals(0, app.STUDY.countDefinedPrefix(new float[]{u, 1, 2}));
  }

  @Test
  void countDefinedPrefix_isTheFullLengthWhenEveryValueIsDefined () {
    assertEquals(3, app.STUDY.countDefinedPrefix(new float[]{1, 2, 3}));
  }


  @Test
  void requestRedraw_flagsStudyForUpdate () {
    app.STUDY.update = false;
    app.STUDY.requestRedraw();
    assertTrue(app.STUDY.update);
  }

  @Test
  void requestDataRefresh_flagsBothDataAndTheView () {
    app.developDataUpdate = false;
    app.STUDY.update = false;
    app.WIN3D.update = false;

    app.STUDY.requestDataRefresh();

    assertTrue(app.developDataUpdate);
    assertTrue(app.STUDY.update);
    assertTrue(app.WIN3D.update);
  }

  // ================= changeJoinDays ======================================

  @Test
  void changeJoinDays_isClampedBetween1And365 () {
    app.STUDY.daysMergedCount = 364;
    app.STUDY.changeJoinDays(5);
    assertEquals(365, app.STUDY.daysMergedCount);

    app.STUDY.daysMergedCount = 2;
    app.STUDY.changeJoinDays(-5);
    assertEquals(1, app.STUDY.daysMergedCount);
  }

  // ================= changeJEnd ==========================================

  @Test
  void changeJEnd_growsAndRecomputesUScale () {
    app.STUDY.startDay = 0;
    app.STUDY.endDay = 12;

    app.STUDY.changeJEnd(1);

    assertEquals(13, app.STUDY.endDay);
    assertEquals(18.0f / 13f, app.STUDY.horizontalUnitScale, 0.0001f);
  }

  @Test
  void changeJEnd_isClampedToStayAboveJStart () {
    app.STUDY.startDay = 5;
    app.STUDY.endDay = 5; // already at the floor
    app.STUDY.changeJEnd(-1);
    assertEquals(5, app.STUDY.endDay); // the delta is undone, staying put
  }

  @Test
  void changeJEnd_isClampedToAtMost61ColumnsWide () {
    app.STUDY.startDay = 0;
    app.STUDY.endDay = 62;
    app.STUDY.changeJEnd(1);
    assertEquals(62, app.STUDY.endDay); // the delta is undone
  }

  // ================= changeSkyScenario ===================================

  @Test
  void changeSkyScenario_cyclesForwardAndWrapsFrom4To1 () {
    app.STUDY.skyScenarioIndex = 4;
    app.STUDY.changeSkyScenario(1);
    assertEquals(1, app.STUDY.skyScenarioIndex);
  }

  @Test
  void changeSkyScenario_cyclesBackwardAndWrapsFrom1To4 () {
    app.STUDY.skyScenarioIndex = 1;
    app.STUDY.changeSkyScenario(-1);
    assertEquals(4, app.STUDY.skyScenarioIndex);
  }

  // ================= decreaseSumInterval / increaseSumInterval ==========

  @Test
  void decreaseSumInterval_stepsDownFrom24To18 () {
    app.STUDY.probabilityWidthInterval = 24;
    app.STUDY.decreaseSumInterval(); // >24 doesn't apply at exactly 24; >6 does: 24-6=18
    assertEquals(18, app.STUDY.probabilityWidthInterval);
  }

  @Test
  void decreaseSumInterval_snapsFiveDownToFour () {
    app.STUDY.probabilityWidthInterval = 6;
    app.STUDY.decreaseSumInterval(); // not >6, so the >1 branch fires: 6-1=5, then snapped to 4
    assertEquals(4, app.STUDY.probabilityWidthInterval);
  }

  @Test
  void increaseSumInterval_stepsUpFrom6To12 () {
    app.STUDY.probabilityWidthInterval = 6;
    app.STUDY.increaseSumInterval(); // not <6, and <24: +6
    assertEquals(12, app.STUDY.probabilityWidthInterval);
  }

  @Test
  void increaseSumInterval_snapsFiveUpToSix () {
    app.STUDY.probabilityWidthInterval = 4;
    app.STUDY.increaseSumInterval(); // <6, so +1: 5, then snapped to 6
    assertEquals(6, app.STUDY.probabilityWidthInterval);
  }

  // ================= handlePlainCharKey ==================================

  @Test
  void handlePlainCharKey_togglesDisplayFlagsAndAdjustsprobabilityHeightInterval () {
    app.STUDY.showRawLines = false;
    app.key = 'v';
    app.STUDY.handlePlainCharKey();
    assertTrue(app.STUDY.showRawLines);

    app.STUDY.probabilityHeightInterval = 8;
    app.key = '{';
    app.STUDY.handlePlainCharKey();
    assertEquals(16f, app.STUDY.probabilityHeightInterval, 0.0001f);
  }

  @Test
  void handlePlainCharKey_widensTheJoinWindowOnGreaterThan () {
    app.STUDY.daysMergedCount = 10;
    app.key = '>';
    app.STUDY.handlePlainCharKey();
    assertEquals(12, app.STUDY.daysMergedCount);
  }

  // ================= handleCtrlCharKey ===================================

  @Test
  void handleCtrlCharKey_togglesImpactSummaryAndScalesVScale () {
    app.STUDY.showImpactSummary = true;
    app.key = ';';
    app.STUDY.handleCtrlCharKey();
    assertFalse(app.STUDY.showImpactSummary);

    app.STUDY.verticalUnitScale = 100;
    app.key = '"';
    app.STUDY.handleCtrlCharKey();
    assertEquals((float) (100 * Math.sqrt(2.0)), app.STUDY.verticalUnitScale, 0.01f);
  }

  // ================= handleCtrlCodedKey ==================================

  @Test
  void handleCtrlCodedKey_cyclesTheCurrentLayerForwardAndBackward () {
    app.currentLayerId = 0;

    app.keyCode = app.UP;
    app.STUDY.handleCtrlCodedKey(null); // isShiftDown() isn't reached for UP/DOWN/LEFT/RIGHT
    assertEquals(1, app.currentLayerId);

    app.keyCode = app.DOWN;
    app.STUDY.handleCtrlCodedKey(null);
    assertEquals(0, app.currentLayerId);
  }

  @Test
  void handleCtrlCodedKey_cyclesimpactGraphIndexForwardAndWraps () {
    app.STUDY.impactGraphIndex = app.STUDY.PLOT_IMPACTS_MODE_COUNT - 1; // at the top end

    app.keyCode = app.RIGHT;
    app.STUDY.handleCtrlCodedKey(null);

    assertEquals(0, app.STUDY.impactGraphIndex); // wrapped back to 0
  }

  // ================= to_XML / from_XML round trip ========================

  @Test
  void toXMLThenFromXML_roundTripsEveryField () {
    app.STUDY.startHour = 6;
    app.STUDY.endHour = 20;
    app.STUDY.startDay = 1;
    app.STUDY.endDay = 10;
    app.STUDY.dayIncrement = 15;
    app.STUDY.daysMergedCount = 5;
    app.STUDY.strokeScale = 0.75f;
    app.STUDY.horizontalUnitScale = 2f;
    app.STUDY.skyScenarioIndex = 3;
    app.STUDY.filterTypeIndex = 2;
    app.STUDY.export_info_node = true;
    app.STUDY.export_info_norm = true;
    app.STUDY.export_info_prob = false;
    app.STUDY.SORT_ColorScaleIndex = 2;
    app.STUDY.activeColorScaleFactor = 0.5f;
    app.STUDY.opacityPercentage = 60;
    app.STUDY.rect_scale = 1.25f;
    app.STUDY.rect_offset_x = 0.6f;
    app.STUDY.showImpactSummary = false;
    app.STUDY.impactLayerIndex = 2;
    app.STUDY.impactGraphIndex = 3;
    app.STUDY.updateImpactGraph = false;
    app.STUDY.showRawLines = true;
    app.STUDY.showStatisticalRanges = false;
    app.STUDY.showNormalLines = false;
    app.STUDY.showProbabilities = true;
    app.STUDY.probabilityWidthInterval = 6;
    app.STUDY.probabilityHeightInterval = 16;
    app.STUDY.plotLayoutIndex = 4;
    app.STUDY.impactTypeIndex = app.Impact_PASSIVE;

    processing.data.XML root = new processing.data.XML("root");
    app.STUDY.to_XML(root);

    solarchvision_bim.STUDY fresh = app.new STUDY();
    fresh.from_XML(root);

    assertEquals(6, fresh.startHour);
    assertEquals(20, fresh.endHour);
    assertEquals(1, fresh.startDay);
    assertEquals(10, fresh.endDay);
    assertEquals(15f, fresh.dayIncrement, 0.0001f);
    assertEquals(5, fresh.daysMergedCount);
    assertEquals(3, fresh.skyScenarioIndex);
    assertTrue(fresh.export_info_node);
    assertFalse(fresh.export_info_prob);
    assertEquals(2, fresh.SORT_ColorScaleIndex);
    assertEquals(0.5f, fresh.activeColorScaleFactor, 0.0001f);
    assertFalse(fresh.showImpactSummary);
    assertEquals(2, fresh.impactLayerIndex);
    assertEquals(3, fresh.impactGraphIndex);
    assertTrue(fresh.showRawLines);
    assertFalse(fresh.showStatisticalRanges);
    assertEquals(6, fresh.probabilityWidthInterval);
    assertEquals(16f, fresh.probabilityHeightInterval, 0.0001f);
    assertEquals(4, fresh.plotLayoutIndex);
    assertEquals(app.Impact_PASSIVE, fresh.impactTypeIndex);
  }

  // ================= revise / updated ====================================

  @Test
  void reviseThenUpdated_toggleTheUpdateFlag () {
    app.STUDY.update = false;
    app.STUDY.revise();
    assertTrue(app.STUDY.update);
    app.STUDY.updated();
    assertFalse(app.STUDY.update);
  }

  // ================= keyPressed (top-level guard only) ===================
  // keyPressed(KeyEvent e) touches e.isAltDown()/e.isControlDown() right
  // after the include guard, so it isn't callable with a real event here
  // without constructing one (see test/README.md's testing approach - no
  // other test in this suite constructs a KeyEvent either). The one branch
  // that's still safely testable is the include guard itself, since it
  // returns before e is ever touched.

  @Test
  void keyPressed_doesNothingAndDoesNotTouchTheEventWhenIncludeIsFalse () {
    app.STUDY.include = false;
    assertDoesNotThrow(() -> app.STUDY.keyPressed(null));
  }

  // ================= handlePlainCharKey (remaining branches) =============

  @Test
  void handlePlainCharKey_narrowsTheJoinWindowOnLessThan () {
    app.STUDY.daysMergedCount = 10;
    app.key = '<';
    app.STUDY.handlePlainCharKey();
    assertEquals(8, app.STUDY.daysMergedCount);
  }

  @Test
  void handlePlainCharKey_growsAndShrinksJEndOnParens () {
    app.STUDY.startDay = 0;
    app.STUDY.endDay = 12;

    app.key = ')';
    app.STUDY.handlePlainCharKey();
    assertEquals(13, app.STUDY.endDay);

    app.key = '(';
    app.STUDY.handlePlainCharKey();
    assertEquals(12, app.STUDY.endDay);
  }

  @Test
  void handlePlainCharKey_cyclesSkyScenarioForwardAndBackward () {
    app.STUDY.skyScenarioIndex = 1;

    app.key = 'S';
    app.STUDY.handlePlainCharKey();
    assertEquals(2, app.STUDY.skyScenarioIndex);

    app.key = 's';
    app.STUDY.handlePlainCharKey();
    assertEquals(1, app.STUDY.skyScenarioIndex);
  }

  @Test
  void handlePlainCharKey_upperV_alsoTogglesDisplayRaws () {
    app.STUDY.showRawLines = false;
    app.key = 'V';
    app.STUDY.handlePlainCharKey();
    assertTrue(app.STUDY.showRawLines);
  }

  @Test
  void handlePlainCharKey_mAndM_toggleDisplaySorted () {
    app.STUDY.showStatisticalRanges = false;
    app.key = 'm';
    app.STUDY.handlePlainCharKey();
    assertTrue(app.STUDY.showStatisticalRanges);

    app.key = 'M';
    app.STUDY.handlePlainCharKey();
    assertFalse(app.STUDY.showStatisticalRanges);
  }

  @Test
  void handlePlainCharKey_nAndN_toggleDisplayNormals () {
    app.STUDY.showNormalLines = false;
    app.key = 'n';
    app.STUDY.handlePlainCharKey();
    assertTrue(app.STUDY.showNormalLines);

    app.key = 'N';
    app.STUDY.handlePlainCharKey();
    assertFalse(app.STUDY.showNormalLines);
  }

  @Test
  void handlePlainCharKey_bAndB_toggleDisplayProbs () {
    app.STUDY.showProbabilities = false;
    app.key = 'b';
    app.STUDY.handlePlainCharKey();
    assertTrue(app.STUDY.showProbabilities);

    app.key = 'B';
    app.STUDY.handlePlainCharKey();
    assertFalse(app.STUDY.showProbabilities);
  }

  @Test
  void handlePlainCharKey_curlyBraces_growAndShrinkprobabilityHeightInterval () {
    app.STUDY.probabilityHeightInterval = 8;

    app.key = '{';
    app.STUDY.handlePlainCharKey();
    assertEquals(16f, app.STUDY.probabilityHeightInterval, 0.0001f);

    app.key = '}';
    app.STUDY.handlePlainCharKey();
    assertEquals(8f, app.STUDY.probabilityHeightInterval, 0.0001f);
  }

  @Test
  void handlePlainCharKey_curlyBraceGrowth_isClampedAt32 () {
    app.STUDY.probabilityHeightInterval = 32;
    app.key = '{';
    app.STUDY.handlePlainCharKey();
    assertEquals(32f, app.STUDY.probabilityHeightInterval, 0.0001f); // not < 32, so the guard blocks it
  }

  @Test
  void handlePlainCharKey_curlyBraceShrink_isClampedAt2 () {
    app.STUDY.probabilityHeightInterval = 2;
    app.key = '}';
    app.STUDY.handlePlainCharKey();
    assertEquals(2f, app.STUDY.probabilityHeightInterval, 0.0001f); // not > 2, so the guard blocks it
  }

  @Test
  void handlePlainCharKey_squareBrackets_decreaseAndIncreaseSumInterval () {
    app.STUDY.probabilityWidthInterval = 24;

    app.key = '[';
    app.STUDY.handlePlainCharKey();
    assertEquals(18, app.STUDY.probabilityWidthInterval); // >24 doesn't apply at exactly 24; >6 does

    app.key = ']';
    app.STUDY.handlePlainCharKey();
    assertEquals(24, app.STUDY.probabilityWidthInterval);
  }

  // ================= handleCtrlCharKey (remaining branch) ================

  @Test
  void handleCtrlCharKey_singleQuote_scalesVScaleDown () {
    app.STUDY.verticalUnitScale = 100;
    app.key = '\'';
    app.STUDY.handleCtrlCharKey();
    assertEquals((float) (100 * Math.sqrt(0.5)), app.STUDY.verticalUnitScale, 0.01f);
  }
}
