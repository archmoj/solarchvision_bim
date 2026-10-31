import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class STUDYTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // fresh app never runs build_allActions() itself
    app.build_allActions(); // most of STUDY's key handlers now dispatch through allActions
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

  // ================= effectiveDayTime ===================================
  // The fix for the hour-range over-extrapolation bug: funcs.DayTime()
  // (astronomical daylight duration) clamped to the duration of the
  // user's own selected hour range, via isInHourlyRange(), whenever that
  // range is narrower than the full day. SolarImpacts.pde, calculate_
  // GlobalSolar_array.pde, calculate_VertexSolar_array.pde and STUDY.pde's
  // own plotImpact_global() all extrapolate valuesSUM/valuesNUM (an
  // average over only the hours actually satisfying isInHourlyRange())
  // into a day total by multiplying by this duration - restricting the
  // range down to a single hour used to still multiply by the full day's
  // daylight duration as if that one hour's value were a fair day-average,
  // which is what these tests guard against regressing.

  // Mid-latitude, near summer solstice - plain DayTime() is comfortably
  // more than 7 hours here, so the clamping tests below exercise genuine
  // clamping rather than a degenerate edge case.
  static final float TEST_LAT = 45f;
  static final float TEST_DATE_ANGLE = 90f;

  @Test
  void effectiveDayTime_defaultRange_isUnchangedFromPlainDayTime () {
    app.STUDY.startHour = 0;
    app.STUDY.endHour = 23;

    float plain = app.funcs.DayTime(TEST_LAT, TEST_DATE_ANGLE);
    float effective = app.STUDY.effectiveDayTime(TEST_LAT, TEST_DATE_ANGLE);

    assertEquals(plain, effective, 0.0001f, "the default, unrestricted range must give exactly the same value every existing consistency test was built against");
  }

  @Test
  void effectiveDayTime_singleHourRange_clampsToOneHour () {
    app.STUDY.startHour = 12;
    app.STUDY.endHour = 12;

    float plain = app.funcs.DayTime(TEST_LAT, TEST_DATE_ANGLE);
    assertTrue(plain > 1f, "sanity check: plain DayTime should be well above 1 hour here");

    assertEquals(1f, app.STUDY.effectiveDayTime(TEST_LAT, TEST_DATE_ANGLE), 0.0001f);
  }

  @Test
  void effectiveDayTime_sevenHourRange_clampsToSevenHours () {
    app.STUDY.startHour = 9;
    app.STUDY.endHour = 15; // 9,10,11,12,13,14,15 -> 7 hours

    float plain = app.funcs.DayTime(TEST_LAT, TEST_DATE_ANGLE);
    assertTrue(plain > 7f, "sanity check: plain DayTime should be well above 7 hours here");

    assertEquals(7f, app.STUDY.effectiveDayTime(TEST_LAT, TEST_DATE_ANGLE), 0.0001f);
  }

  @Test
  void effectiveDayTime_wrappingRange_countsHoursAcrossMidnightCorrectly () {
    app.STUDY.startHour = 22;
    app.STUDY.endHour = 2; // 22,23,0,1,2 -> 5 hours, wraps past midnight

    assertEquals(5f, app.STUDY.effectiveDayTime(TEST_LAT, TEST_DATE_ANGLE), 0.0001f);
  }

  @Test
  void effectiveDayTime_rangeWiderThanDayTime_stillYieldsPlainDayTime () {
    app.STUDY.startHour = 0;
    app.STUDY.endHour = 20; // 21 hours - wider than any plausible DayTime at this latitude/date

    float plain = app.funcs.DayTime(TEST_LAT, TEST_DATE_ANGLE);
    float effective = app.STUDY.effectiveDayTime(TEST_LAT, TEST_DATE_ANGLE);

    assertEquals(plain, effective, 0.0001f, "a selected range wider than the astronomical day must not inflate the result beyond the plain DayTime()");
  }

  // ================= selectedRangeHours =================================

  @Test
  void selectedRangeHours_defaultRange_isTwentyFour () {
    app.STUDY.startHour = 0;
    app.STUDY.endHour = 23;
    assertEquals(24, app.STUDY.selectedRangeHours());
  }

  @Test
  void selectedRangeHours_singleHour_isOne () {
    app.STUDY.startHour = 12;
    app.STUDY.endHour = 12;
    assertEquals(1, app.STUDY.selectedRangeHours());
  }

  @Test
  void selectedRangeHours_wrappingRange_countsAcrossMidnight () {
    app.STUDY.startHour = 22;
    app.STUDY.endHour = 2; // 22,23,0,1,2 -> 5 hours
    assertEquals(5, app.STUDY.selectedRangeHours());
  }

  // ================= paletteColorscaleMultiplier =========================
  // The counterpart to effectiveDayTime() for a palette's own legend:
  // scales a colorscale multiplier so its displayed maximum shrinks
  // proportionally for a restricted hour range, using a fixed 12-hour
  // nominal reference rather than a specific date's astronomical
  // DayTime() (several legend-drawing sites have no particular date in
  // scope, and a palette drawn once per graph shouldn't shift with
  // whichever day happened to be processed last).

  @Test
  void paletteColorscaleMultiplier_defaultRange_isUnchanged () {
    app.STUDY.startHour = 0;
    app.STUDY.endHour = 23;
    assertEquals(0.625f, app.STUDY.paletteColorscaleMultiplier(0.625f), 0.0001f);
  }

  @Test
  void paletteColorscaleMultiplier_singleHourRange_scalesByTwelve () {
    app.STUDY.startHour = 12;
    app.STUDY.endHour = 12;
    assertEquals(0.625f * 12f, app.STUDY.paletteColorscaleMultiplier(0.625f), 0.0001f);
  }

  @Test
  void paletteColorscaleMultiplier_threeHourRange_scalesByFour () {
    app.STUDY.startHour = 11;
    app.STUDY.endHour = 13; // 11,12,13 -> 3 hours
    assertEquals(0.625f * 4f, app.STUDY.paletteColorscaleMultiplier(0.625f), 0.0001f);
  }

  @Test
  void paletteColorscaleMultiplier_rangeWiderThanNominal_doesNotInflateBeyondOriginal () {
    app.STUDY.startHour = 0;
    app.STUDY.endHour = 14; // 15 hours - wider than the 12-hour nominal reference
    assertEquals(0.625f, app.STUDY.paletteColorscaleMultiplier(0.625f), 0.0001f);
  }

  @Test
  void paletteColorscaleMultiplier_endToEnd_matchesTheMotivatingExample () {
    // The user's own example: 0.625 = allFaces.activeColorscaleFactor's
    // calibrated value, giving a default max of 8 kWh/m2 via the
    // swatch formula 0.5*q/PAL_multiplier at q=10 (5/PAL_multiplier).
    app.STUDY.startHour = 0;
    app.STUDY.endHour = 23;
    float defaultMax = 5f / app.STUDY.paletteColorscaleMultiplier(0.625f);
    assertEquals(8f, defaultMax, 0.01f);

    app.STUDY.startHour = 12;
    app.STUDY.endHour = 12;
    float oneHourMax = 5f / app.STUDY.paletteColorscaleMultiplier(0.625f);
    assertTrue(oneHourMax < 1f, "a one-hour analysis's own max should land well under 1 kWh/m2, not stay anywhere near 8 (" + oneHourMax + ")");
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
  void requestStudyRedraw_flagsStudyForUpdate () {
    app.STUDY.update = false;
    app.requestStudyRedraw();
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
    app.STUDY.skyScenarioSetting = 4;
    app.STUDY.changeSkyScenario(1);
    assertEquals(1, app.STUDY.skyScenarioSetting);
  }

  @Test
  void changeSkyScenario_cyclesBackwardAndWrapsFrom1To4 () {
    app.STUDY.skyScenarioSetting = 1;
    app.STUDY.changeSkyScenario(-1);
    assertEquals(4, app.STUDY.skyScenarioSetting);
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
    app.STUDY.skyScenarioSetting = 3;
    app.STUDY.temporalFilterSetting = 2;
    app.STUDY.rawLinesExporter = true;
    app.STUDY.normalLinesExporter = true;
    app.STUDY.probabilitiesExporter = false;
    app.STUDY.statisticalRangesColorscaleIndex = 2;
    app.STUDY.activeColorscaleFactor = 0.5f;
    app.STUDY.opacityPercentage = 60;
    app.STUDY.centralGraphScale = 1.25f;
    app.STUDY.centralGraphOffsetX = 0.0f;
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
    assertEquals(3, fresh.skyScenarioSetting);
    assertTrue(fresh.rawLinesExporter);
    assertFalse(fresh.probabilitiesExporter);
    assertEquals(2, fresh.statisticalRangesColorscaleIndex);
    assertEquals(0.5f, fresh.activeColorscaleFactor, 0.0001f);
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
    app.STUDY.skyScenarioSetting = 1;

    app.key = 'S';
    app.STUDY.handlePlainCharKey();
    assertEquals(2, app.STUDY.skyScenarioSetting);

    app.key = 's';
    app.STUDY.handlePlainCharKey();
    assertEquals(1, app.STUDY.skyScenarioSetting);
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

  // ================= dayCellBounds ======================================
  // The bounding square each day index's rectangle is recorded with, via
  // recordDayHighlightCandidate() (STUDY.pde), for draw_STUDY_layers.pde's
  // own live, every-frame redraw of whichever one impactDisplayDay
  // currently points at - pure math, pulled out specifically so it can be
  // checked here without the surrounding functions' own this.graphics
  // calls, which need a real drawing pass already underway (consistent
  // with every other STUDY.pde/hover.pde function that touches
  // this.graphics not being independently testable - see e.g.
  // WorldStationHoverTest.java's own header comment on place_WORLD_hover()).
  // Matches, verbatim, the bounds every plotImpact_wind/urban/global call
  // already draws its own per-day backdrop square within (dayCellBounds()'s
  // own comment, STUDY.pde).

  @Test
  void dayCellBounds_isCenteredOnTheDayColumnWithNoOffsetOrScaling () {
    app.STUDY.centralGraphOffsetX = 0;
    app.STUDY.centralGraphScale = 200; // 100 * (200/200) = 100 -> half-width/height of 100 * sx_Plot

    float[] b = app.STUDY.dayCellBounds(3, 10f); // j=3, sx_Plot=10

    // cx = (3 + 0 + 0.5) * 10 = 35; half = 100 * (200/200) * 10 = 1000
    assertEquals(35f - 1000f, b[0], 0.001f); // x (left edge)
    assertEquals(-1000f, b[1], 0.001f);      // y (top edge)
    assertEquals(2000f, b[2], 0.001f);       // w
    assertEquals(2000f, b[3], 0.001f);       // h
  }

  @Test
  void dayCellBounds_shrinksWithCentralGraphScale () {
    app.STUDY.centralGraphOffsetX = 0;
    app.STUDY.centralGraphScale = 100; // half the default 200 -> half the size

    float[] b = app.STUDY.dayCellBounds(0, 10f);

    // cx = (0 + 0 + 0.5) * 10 = 5; half = 100 * (100/200) * 10 = 500
    assertEquals(5f - 500f, b[0], 0.001f);
    assertEquals(-500f, b[1], 0.001f);
    assertEquals(1000f, b[2], 0.001f);
    assertEquals(1000f, b[3], 0.001f);
  }

  @Test
  void dayCellBounds_shiftsWithCentralGraphOffsetX () {
    app.STUDY.centralGraphOffsetX = 2;
    app.STUDY.centralGraphScale = 200;

    float[] b = app.STUDY.dayCellBounds(0, 10f);

    // cx = (0 + 2 + 0.5) * 10 = 25; half = 1000, so x = 25 - 1000
    assertEquals(25f - 1000f, b[0], 0.001f);
  }

  @Test
  void dayCellBounds_advancesByOneSxPlotPerDayIndex () {
    app.STUDY.centralGraphOffsetX = 0;
    app.STUDY.centralGraphScale = 200;

    float[] b0 = app.STUDY.dayCellBounds(0, 10f);
    float[] b1 = app.STUDY.dayCellBounds(1, 10f);

    assertEquals(10f, b1[0] - b0[0], 0.001f); // one sx_Plot farther right
    assertEquals(b0[1], b1[1], 0.001f);       // same vertical placement
  }
}
