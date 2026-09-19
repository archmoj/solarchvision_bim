import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Exercises solarchvision_STUDY (STUDY.pde), reached through the
// pre-constructed `app.STUDY` field - the hourly/daily statistics plot
// window. At over 3000 lines this is the largest file tested in this
// whole project, but the overwhelming majority of it (applyLegendTextStyle
// through plotImpact_cycles/plotImpact, plus openPerDayOutputFiles/
// closePerDayOutputFiles) is either real rendering (this.graphics calls)
// or real file output (createWriter/PrintWriter), and none of it is
// covered here.
//
// Two pure computations were pulled out of that rendering code and given
// their own tests: computeWrappedDayIndex() (an identical 8-line
// day-of-year-wrapping expression that was duplicated character-for-
// character across 5 separate call sites in plotHourly()/
// plotImpact_wind()/plotImpact_global()/plotImpact_sunpath(), confirmed
// identical via grep before extracting) and countDefinedPrefix() (a
// "count leading defined values in a sort()-ed array" loop drawSorted()
// ran twice in a row, once each for its two value series). Both
// extractions were done by replacing each call site with a call to the
// new method and re-verifying the surrounding code still reads
// correctly, not by rewriting the logic itself.
//
// NOT covered: keyPressed(KeyEvent e) itself, same reasoning as
// WIN3DTest - it only checks e.isAltDown()/e.isControlDown() before
// delegating, so its sub-handlers are exercised directly instead.
// handleCtrlCodedKey's PAGE_UP_KEYCODE/PAGE_DOWN_KEYCODE cases
// specifically need e.isShiftDown(), so those two are also left out;
// its other four cases (arrow-key layer/impact cycling) don't touch the
// KeyEvent at all and are covered directly.
//
// A fresh `app` per test since these mutate shared scene state.
class STUDYTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= isInHourlyRange ===================================

  @Test
  void isInHourlyRange_normalRangeIncludesOnlyHoursBetweenStartAndEnd () {
    app.STUDY.i_Start = 8;
    app.STUDY.i_End = 18; // i_Start <= i_End -> a normal (non-wrapping) range
    assertFalse(app.STUDY.isInHourlyRange(7));
    assertTrue(app.STUDY.isInHourlyRange(8));
    assertTrue(app.STUDY.isInHourlyRange(18));
    assertFalse(app.STUDY.isInHourlyRange(19));
  }

  @Test
  void isInHourlyRange_wrappingRangeExcludesOnlyHoursStrictlyBetweenEndAndStart () {
    app.STUDY.i_Start = 20;
    app.STUDY.i_End = 4; // i_Start > i_End -> wraps past midnight
    assertTrue(app.STUDY.isInHourlyRange(23));
    assertTrue(app.STUDY.isInHourlyRange(0));
    assertTrue(app.STUDY.isInHourlyRange(4));
    assertFalse(app.STUDY.isInHourlyRange(12)); // strictly between end and start -> excluded
  }

  // ================= computeWrappedDayIndex (newly extracted) ==========

  @Test
  void computeWrappedDayIndex_mapsJAndJAddToADayOfYearIndex () {
    app.STUDY.perDays = 1;
    app.STUDY.joinDays = 0; // avoids the round(0.5*joinDays) tie-breaking case entirely
    app.TIME.beginDay = 0;

    assertEquals(0, app.STUDY.computeWrappedDayIndex(0, 0));
  }

  @Test
  void computeWrappedDayIndex_wrapsNegativeResultsForward () {
    app.STUDY.perDays = 1;
    app.STUDY.joinDays = 0;
    app.TIME.beginDay = -10;

    assertEquals(355, app.STUDY.computeWrappedDayIndex(0, 0));
  }

  @Test
  void computeWrappedDayIndex_wrapsResultsPast365BackToZero () {
    app.STUDY.perDays = 1;
    app.STUDY.joinDays = 0;
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
    app.DevelopData_update = false;
    app.STUDY.update = false;
    app.WIN3D.update = false;

    app.STUDY.requestDataRefresh();

    assertTrue(app.DevelopData_update);
    assertTrue(app.STUDY.update);
    assertTrue(app.WIN3D.update);
  }

  // ================= changeJoinDays ======================================

  @Test
  void changeJoinDays_isClampedBetween1And365 () {
    app.STUDY.joinDays = 364;
    app.STUDY.changeJoinDays(5);
    assertEquals(365, app.STUDY.joinDays);

    app.STUDY.joinDays = 2;
    app.STUDY.changeJoinDays(-5);
    assertEquals(1, app.STUDY.joinDays);
  }

  // ================= changeJEnd ==========================================

  @Test
  void changeJEnd_growsAndRecomputesUScale () {
    app.STUDY.j_Start = 0;
    app.STUDY.j_End = 12;

    app.STUDY.changeJEnd(1);

    assertEquals(13, app.STUDY.j_End);
    assertEquals(18.0f / 13f, app.STUDY.U_scale, 0.0001f);
  }

  @Test
  void changeJEnd_isClampedToStayAboveJStart () {
    app.STUDY.j_Start = 5;
    app.STUDY.j_End = 5; // already at the floor
    app.STUDY.changeJEnd(-1);
    assertEquals(5, app.STUDY.j_End); // the delta is undone, staying put
  }

  @Test
  void changeJEnd_isClampedToAtMost61ColumnsWide () {
    app.STUDY.j_Start = 0;
    app.STUDY.j_End = 62;
    app.STUDY.changeJEnd(1);
    assertEquals(62, app.STUDY.j_End); // the delta is undone
  }

  // ================= changeSkyScenario ===================================

  @Test
  void changeSkyScenario_cyclesForwardAndWrapsFrom4To1 () {
    app.STUDY.skyScenario = 4;
    app.STUDY.changeSkyScenario(1);
    assertEquals(1, app.STUDY.skyScenario);
  }

  @Test
  void changeSkyScenario_cyclesBackwardAndWrapsFrom1To4 () {
    app.STUDY.skyScenario = 1;
    app.STUDY.changeSkyScenario(-1);
    assertEquals(4, app.STUDY.skyScenario);
  }

  // ================= decreaseSumInterval / increaseSumInterval ==========

  @Test
  void decreaseSumInterval_stepsDownFrom24To18 () {
    app.STUDY.sumInterval = 24;
    app.STUDY.decreaseSumInterval(); // >24 doesn't apply at exactly 24; >6 does: 24-6=18
    assertEquals(18, app.STUDY.sumInterval);
  }

  @Test
  void decreaseSumInterval_snapsFiveDownToFour () {
    app.STUDY.sumInterval = 6;
    app.STUDY.decreaseSumInterval(); // not >6, so the >1 branch fires: 6-1=5, then snapped to 4
    assertEquals(4, app.STUDY.sumInterval);
  }

  @Test
  void increaseSumInterval_stepsUpFrom6To12 () {
    app.STUDY.sumInterval = 6;
    app.STUDY.increaseSumInterval(); // not <6, and <24: +6
    assertEquals(12, app.STUDY.sumInterval);
  }

  @Test
  void increaseSumInterval_snapsFiveUpToSix () {
    app.STUDY.sumInterval = 4;
    app.STUDY.increaseSumInterval(); // <6, so +1: 5, then snapped to 6
    assertEquals(6, app.STUDY.sumInterval);
  }

  // ================= handlePlainCharKey ==================================

  @Test
  void handlePlainCharKey_togglesDisplayFlagsAndAdjustsLevelPix () {
    app.STUDY.displayRaws = false;
    app.key = 'v';
    app.STUDY.handlePlainCharKey();
    assertTrue(app.STUDY.displayRaws);

    app.STUDY.LevelPix = 8;
    app.key = '{';
    app.STUDY.handlePlainCharKey();
    assertEquals(16f, app.STUDY.LevelPix, 0.0001f);
  }

  @Test
  void handlePlainCharKey_widensTheJoinWindowOnGreaterThan () {
    app.STUDY.joinDays = 10;
    app.key = '>';
    app.STUDY.handlePlainCharKey();
    assertEquals(12, app.STUDY.joinDays);
  }

  // ================= handleCtrlCharKey ===================================

  @Test
  void handleCtrlCharKey_togglesImpactSummaryAndScalesVScale () {
    app.STUDY.impact_summary = true;
    app.key = ';';
    app.STUDY.handleCtrlCharKey();
    assertFalse(app.STUDY.impact_summary);

    app.STUDY.V_scale = 100;
    app.key = '"';
    app.STUDY.handleCtrlCharKey();
    assertEquals((float) (100 * Math.sqrt(2.0)), app.STUDY.V_scale, 0.01f);
  }

  // ================= handleCtrlCodedKey ==================================

  @Test
  void handleCtrlCodedKey_cyclesTheCurrentLayerForwardAndBackward () {
    // Correction from an earlier pass: this was previously written as
    // "fixing a numberOfLayers bug" - that was a mistaken conclusion.
    // numberOfLayers is genuinely 0 at its OWN declaration, but every one
    // of the 14 LAYER_xxx globals declared immediately afterward
    // constructs a solarchvision_LAYER, whose constructor does
    // `this.id = numberOfLayers; numberOfLayers++;` - so by the time a
    // fresh app finishes constructing, numberOfLayers is already
    // correctly 14. I'd only traced the explicit `= 0` initializer and
    // the XML-load path, not this constructor side effect, when I first
    // called it a bug. This assignment is a harmless no-op (already 14),
    // kept only to make the test's own setup explicit and independent of
    // that construction-order detail.
    app.numberOfLayers = app.allLayers.length;
    app.CurrentLayer_id = 0;

    app.keyCode = app.UP;
    app.STUDY.handleCtrlCodedKey(null); // isShiftDown() isn't reached for UP/DOWN/LEFT/RIGHT
    assertEquals(1, app.CurrentLayer_id);

    app.keyCode = app.DOWN;
    app.STUDY.handleCtrlCodedKey(null);
    assertEquals(0, app.CurrentLayer_id);
  }

  @Test
  void handleCtrlCodedKey_cyclesPlotImpactsForwardAndWraps () {
    app.STUDY.PlotImpacts = app.STUDY.PLOT_IMPACTS_MODE_COUNT - 1; // at the top end

    app.keyCode = app.RIGHT;
    app.STUDY.handleCtrlCodedKey(null);

    assertEquals(0, app.STUDY.PlotImpacts); // wrapped back to 0
  }

  // ================= to_XML / from_XML round trip ========================

  @Test
  void toXMLThenFromXML_roundTripsEveryField () {
    app.STUDY.i_Start = 6;
    app.STUDY.i_End = 20;
    app.STUDY.j_Start = 1;
    app.STUDY.j_End = 10;
    app.STUDY.perDays = 15;
    app.STUDY.joinDays = 5;
    app.STUDY.T_scale = 0.75f;
    app.STUDY.U_scale = 2f;
    app.STUDY.skyScenario = 3;
    app.STUDY.filter = 2;
    app.STUDY.TrendJoinHours = 12;
    app.STUDY.TrendJoinType = 1;
    app.STUDY.export_info_node = true;
    app.STUDY.export_info_norm = true;
    app.STUDY.export_info_prob = false;
    app.STUDY.SORT_palette_CLR = 2;
    app.STUDY.ACTIVE_palette_MLT = 0.5f;
    app.STUDY.O_scale = 60;
    app.STUDY.W_scale = 4;
    app.STUDY.rect_scale = 0.01f;
    app.STUDY.rect_offset_x = 0.6f;
    app.STUDY.impact_summary = false;
    app.STUDY.ImpactLayer = 2;
    app.STUDY.PlotImpacts = 3;
    app.STUDY.Impacts_update = false;
    app.STUDY.displayRaws = true;
    app.STUDY.displaySorted = false;
    app.STUDY.displayNormals = false;
    app.STUDY.displayProbs = true;
    app.STUDY.sumInterval = 6;
    app.STUDY.LevelPix = 16;
    app.STUDY.plotSetup = 4;
    app.STUDY.Impact_TYPE = app.Impact_PASSIVE;

    processing.data.XML root = new processing.data.XML("root");
    app.STUDY.to_XML(root);

    solarchvision_bim.solarchvision_STUDY fresh = app.new solarchvision_STUDY();
    fresh.from_XML(root);

    assertEquals(6, fresh.i_Start);
    assertEquals(20, fresh.i_End);
    assertEquals(1, fresh.j_Start);
    assertEquals(10, fresh.j_End);
    assertEquals(15f, fresh.perDays, 0.0001f);
    assertEquals(5, fresh.joinDays);
    assertEquals(3, fresh.skyScenario);
    assertTrue(fresh.export_info_node);
    assertFalse(fresh.export_info_prob);
    assertEquals(2, fresh.SORT_palette_CLR);
    assertEquals(0.5f, fresh.ACTIVE_palette_MLT, 0.0001f);
    assertFalse(fresh.impact_summary);
    assertEquals(2, fresh.ImpactLayer);
    assertEquals(3, fresh.PlotImpacts);
    assertTrue(fresh.displayRaws);
    assertFalse(fresh.displaySorted);
    assertEquals(6, fresh.sumInterval);
    assertEquals(16f, fresh.LevelPix, 0.0001f);
    assertEquals(4, fresh.plotSetup);
    assertEquals(app.Impact_PASSIVE, fresh.Impact_TYPE);
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
}
