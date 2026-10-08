import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// draw()/drawTabs()/drawTrackBackground()/drawDaysBands()/
// drawDaysMonthLabels()/renderImpactLayerIndexGrid()/drawWrappedRect()
// all touch live drawing primitives (fill(), rect(), text(), ...) and
// aren't unit-testable as-is (see test/README.md). What's covered
// instead: the pure math (scaledIndexFromClick, dayOfYearFromClick,
// impactCellBounds, scenarioRange, scenarioCurrentValues,
// scenarioTickLabel) and the four click handlers (handleHoursClick,
// handleDaysClick, handleScenarioClick, handleImpactLayerIndexClicks) -
// none of which touch drawing, only isInside()/runScriptLine()
// dispatch. handleHoursClick and handleScenarioClick were pulled out of
// drawHoursTab/drawScenarioTab specifically to make this possible,
// matching handleDaysClick/handleImpactLayerIndexClicks, which already
// had their own dedicated functions.
class UI_caseBarTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= scaledIndexFromClick ====================================

  @Test
  void scaledIndexFromClick_atTheStartOfTheRange_withAHalfBucketOffset () {
    // Hours' own offset (-0.5): a click at the very start of bucket 0
    // (x=5 of 10px-wide buckets) lands mid-bucket, resolving to index 0.
    assertEquals(0, app.UI_caseBar.scaledIndexFromClick(5, 0, 240, 24.0f, -0.5f));
  }

  @Test
  void scaledIndexFromClick_oneBucketIn_withAHalfBucketOffset () {
    assertEquals(1, app.UI_caseBar.scaledIndexFromClick(15, 0, 240, 24.0f, -0.5f));
  }

  @Test
  void scaledIndexFromClick_atTheEndOfTheRange_withAHalfBucketOffset () {
    assertEquals(23, app.UI_caseBar.scaledIndexFromClick(235, 0, 240, 24.0f, -0.5f));
  }

  @Test
  void scaledIndexFromClick_noOffset_mapsLinearly () {
    // Days' own usage: offset 0, so the click position maps directly.
    assertEquals(100, app.UI_caseBar.scaledIndexFromClick(100, 0, 365, 365.0f, 0));
  }

  // ================= dayOfYearFromClick =======================================

  @Test
  void dayOfYearFromClick_beforeTheWrapPoint_addsTheMarchEquinoxOffset () {
    assertEquals(200, app.UI_caseBar.dayOfYearFromClick(279, 0, 365));
  }

  @Test
  void dayOfYearFromClick_pastTheWrapPoint_wrapsAroundToZero () {
    // +286 pushes clickX=79 (-> scaled index 79) to exactly 365, which
    // wraps to 0 - this is the TIME.date convention (0 == March 21,
    // 286 == Jan 1) documented in solarchvision_bim.pde's setup().
    assertEquals(0, app.UI_caseBar.dayOfYearFromClick(79, 0, 365));
  }

  // ================= impactCellBounds =========================================

  @Test
  void impactCellBounds_cellZero_isTheTopLeftCorner () {
    float[] b = app.UI_caseBar.impactCellBounds(0, 0, 0, 300, 300);
    assertEquals(52f, b[0], 0.01f);
    assertEquals(148f, b[1], 0.01f);
    assertEquals(55f, b[2], 0.01f);
    assertEquals(145f, b[3], 0.01f);
  }

  @Test
  void impactCellBounds_cellFour_isTheCenteredAroundTheOffset () {
    float[] b = app.UI_caseBar.impactCellBounds(4, 0, 0, 300, 300);
    assertEquals(-48f, b[0], 0.01f);
    assertEquals(48f, b[1], 0.01f);
    assertEquals(-45f, b[2], 0.01f);
    assertEquals(45f, b[3], 0.01f);
  }

  @Test
  void impactCellBounds_cellEight_isTheBottomRightCorner () {
    float[] b = app.UI_caseBar.impactCellBounds(8, 0, 0, 300, 300);
    assertEquals(-148f, b[0], 0.01f);
    assertEquals(-52f, b[1], 0.01f);
    assertEquals(-145f, b[2], 0.01f);
    assertEquals(-55f, b[3], 0.01f);
  }

  // ================= scenarioRange ============================================

  @Test
  void scenarioRange_climateEngineering_isTheFixed1950To2050Range () {
    int[] r = app.UI_caseBar.scenarioRange(app.dataID_climateEngineering);
    assertArrayEquals(new int[]{1950, 2050}, r);
  }

  @Test
  void scenarioRange_climateArchive_isTheSameFixedRangeAsClimateEngineering () {
    int[] r = app.UI_caseBar.scenarioRange(app.dataID_climateArchive);
    assertArrayEquals(new int[]{1950, 2050}, r);
  }

  @Test
  void scenarioRange_climateTypicalYear_isAlsoTheSameFixedRange () {
    int[] r = app.UI_caseBar.scenarioRange(app.dataID_climateTypicalYear);
    assertArrayEquals(new int[]{1950, 2050}, r);
  }

  @Test
  void scenarioRange_ensembleForecast_isTheEnsembleForecastStartEndGlobals () {
    app.ensembleForecastStart = 1;
    app.ensembleForecastEnd = 43;
    int[] r = app.UI_caseBar.scenarioRange(app.dataID_ensembleForecast);
    assertArrayEquals(new int[]{1, 43}, r);
  }

  @Test
  void scenarioRange_ensembleObservation_isTheEnsembleObservationStartEndGlobals () {
    app.ensembleObservationStart = 1;
    app.ensembleObservationEnd = 20;
    int[] r = app.UI_caseBar.scenarioRange(app.dataID_ensembleObservation);
    assertArrayEquals(new int[]{1, 20}, r);
  }

  @Test
  void scenarioRange_anUnrecognizedDataSource_fallsBackToZeroOne () {
    int[] r = app.UI_caseBar.scenarioRange(-1);
    assertArrayEquals(new int[]{0, 1}, r);
  }

  // ================= scenarioCurrentValues ====================================

  @Test
  void scenarioCurrentValues_climateEngineeringOrArchive_isSampleYearStartEnd () {
    app.sampleYearStart = 1980;
    app.sampleYearEnd = 2020;
    assertArrayEquals(new int[]{1980, 2020}, app.UI_caseBar.scenarioCurrentValues(app.dataID_climateEngineering));
    assertArrayEquals(new int[]{1980, 2020}, app.UI_caseBar.scenarioCurrentValues(app.dataID_climateArchive));
  }

  @Test
  void scenarioCurrentValues_ensembleForecast_isSampleMemberStartEnd () {
    app.sampleMemberStart = 1;
    app.sampleMemberEnd = 43;
    assertArrayEquals(new int[]{1, 43}, app.UI_caseBar.scenarioCurrentValues(app.dataID_ensembleForecast));
  }

  @Test
  void scenarioCurrentValues_ensembleObservation_isSampleStationStartEnd () {
    app.sampleStationStart = 1;
    app.sampleStationEnd = 20;
    assertArrayEquals(new int[]{1, 20}, app.UI_caseBar.scenarioCurrentValues(app.dataID_ensembleObservation));
  }

  @Test
  void scenarioCurrentValues_anUnrecognizedDataSource_fallsBackToZeroZero () {
    assertArrayEquals(new int[]{0, 0}, app.UI_caseBar.scenarioCurrentValues(-1));
  }

  // ================= scenarioTickLabel ========================================

  @Test
  void scenarioTickLabel_climateEngineering_everyFifthTickIsABar () {
    assertEquals("|", app.UI_caseBar.scenarioTickLabel(app.dataID_climateEngineering, 0, 1950));
  }

  @Test
  void scenarioTickLabel_climateEngineering_offTickIsADot () {
    assertEquals(".", app.UI_caseBar.scenarioTickLabel(app.dataID_climateEngineering, 3, 1950));
  }

  @Test
  void scenarioTickLabel_climateEngineering_everyTenthTickFromFive_isADecadeLabel () {
    // j=5 is also a j%5==0 tick ("|"), but the decade-label branch wins.
    assertEquals("1950s", app.UI_caseBar.scenarioTickLabel(app.dataID_climateEngineering, 5, 1950));
  }

  @Test
  void scenarioTickLabel_climateArchive_alsoGetsDecadeLabels () {
    assertEquals("1950s", app.UI_caseBar.scenarioTickLabel(app.dataID_climateArchive, 5, 1950));
  }

  @Test
  void scenarioTickLabel_climateTypicalYear_isNotDecadeLabeled_fallsBackToBarsAndDots () {
    // Only climateEngineering/climateArchive get the decade-label
    // treatment, even at a j%10==5 position.
    assertEquals("|", app.UI_caseBar.scenarioTickLabel(app.dataID_climateTypicalYear, 5, 1950));
  }

  @Test
  void scenarioTickLabel_ensembleForecast_isAlwaysTheMemberNumber () {
    assertEquals("4", app.UI_caseBar.scenarioTickLabel(app.dataID_ensembleForecast, 3, 1));
  }

  @Test
  void scenarioTickLabel_ensembleObservation_looksUpTheNearestStationCode () {
    app.ensembleObservationCoordinates = new solarchvision_bim.STATION[]{app.new STATION(), app.new STATION(), app.new STATION()};
    app.ensembleObservationCoordinates[2].setCode("ABC");
    app.ensembleObservationNearestStationIndex[0] = 2;

    assertEquals("ABC", app.UI_caseBar.scenarioTickLabel(app.dataID_ensembleObservation, 0, 1));
  }

  // ================= handleHoursClick =========================================

  @Test
  void handleHoursClick_leftClick_setsStartHour () {
    app.allActions = new java.util.HashMap<>();
    app.vm.startHour(0);
    app.X_clicked = 15;
    app.Y_clicked = 10;
    app.mouseButton = app.LEFT;

    app.UI_caseBar.handleHoursClick(0, 0, 240, 20);

    assertEquals(1, app.STUDY.startHour);
  }

  @Test
  void handleHoursClick_rightClick_setsEndHour () {
    app.allActions = new java.util.HashMap<>();
    app.vm.endHour(0);
    app.X_clicked = 15;
    app.Y_clicked = 10;
    app.mouseButton = app.RIGHT;

    app.UI_caseBar.handleHoursClick(0, 0, 240, 20);

    assertEquals(1, app.STUDY.endHour);
  }

  @Test
  void handleHoursClick_outsideTheTrack_doesNothing () {
    app.allActions = new java.util.HashMap<>();
    app.vm.startHour(0);
    int before = app.STUDY.startHour;
    app.X_clicked = -1; // the "nothing clicked" sentinel
    app.Y_clicked = -1;
    app.mouseButton = app.LEFT;

    app.UI_caseBar.handleHoursClick(0, 0, 240, 20);

    assertEquals(before, app.STUDY.startHour);
  }

  // ================= handleDaysClick ==========================================

  @Test
  void handleDaysClick_leftClick_setsDateAndShiftsBeginDayByTheSameDelta () {
    app.allActions = new java.util.HashMap<>();
    app.vm.date(0);
    app.vm.beginDay(0);
    app.TIME.date = 100;
    app.TIME.beginDay = 50;
    app.X_clicked = 279; // -> dayOfYearFromClick(279, 0, 365) == 200
    app.Y_clicked = 10;
    app.mouseButton = app.LEFT;

    app.UI_caseBar.handleDaysClick(0, 0, 365, 20);

    assertEquals(200f, app.TIME.date, 0.001f);
    // newBeginDay = (50 + (200 - 100) + 365) % 365 = 150
    assertEquals(150, app.TIME.beginDay);
  }

  @Test
  void handleDaysClick_rightClick_setsDayIncrementFromTheDragSpan () {
    app.allActions = new java.util.HashMap<>();
    app.vm.dayIncrement(0);
    app.TIME.date = 50;
    app.STUDY.startDay = 0;
    app.STUDY.endDay = 12;
    app.X_clicked = 179; // -> dayOfYearFromClick(179, 0, 365) == 100
    app.Y_clicked = 10;
    app.mouseButton = app.RIGHT;

    app.UI_caseBar.handleDaysClick(0, 0, 365, 20);

    // roundTo((100 - 50) / 12, 0.5) == 4.0
    assertEquals(4.0f, app.STUDY.dayIncrement, 0.001f);
  }

  @Test
  void handleDaysClick_rightClick_neverGoesBelowOne () {
    app.allActions = new java.util.HashMap<>();
    app.vm.dayIncrement(0);
    app.TIME.date = 100;
    app.STUDY.startDay = 0;
    app.STUDY.endDay = 12;
    // dayOfYearFromClick(179, 0, 365) == 100, exactly TIME.date itself -
    // a zero-length drag, which without the clamp would compute a
    // selectedValue of 0.
    app.X_clicked = 179;
    app.Y_clicked = 10;
    app.mouseButton = app.RIGHT;

    app.UI_caseBar.handleDaysClick(0, 0, 365, 20);

    assertEquals(1f, app.STUDY.dayIncrement, 0.001f);
  }

  @Test
  void handleDaysClick_outsideTheTrack_doesNothing () {
    app.allActions = new java.util.HashMap<>();
    app.vm.date(0);
    float before = app.TIME.date;
    app.X_clicked = -1;
    app.Y_clicked = -1;
    app.mouseButton = app.LEFT;

    app.UI_caseBar.handleDaysClick(0, 0, 365, 20);

    assertEquals(before, app.TIME.date, 0.001f);
  }

  // ================= handleScenarioClick ======================================

  @Test
  void handleScenarioClick_climateEngineering_leftSetsSampleYearStart () {
    app.allActions = new java.util.HashMap<>();
    app.vm.sampleYearStart(0);
    app.currentDataSource = app.dataID_climateEngineering;
    app.X_clicked = 110;
    app.Y_clicked = 10;
    app.mouseButton = app.LEFT;

    app.UI_caseBar.handleScenarioClick(0, 0, 200, 20, 1980, 2000);

    assertEquals(1991, app.sampleYearStart);
  }

  @Test
  void handleScenarioClick_climateEngineering_rightSetsSampleYearEnd () {
    app.allActions = new java.util.HashMap<>();
    app.vm.sampleYearEnd(0);
    app.currentDataSource = app.dataID_climateEngineering;
    app.X_clicked = 110;
    app.Y_clicked = 10;
    app.mouseButton = app.RIGHT;

    app.UI_caseBar.handleScenarioClick(0, 0, 200, 20, 1980, 2000);

    assertEquals(1991, app.sampleYearEnd);
  }

  @Test
  void handleScenarioClick_ensembleForecast_leftSetsSampleMemberStart () {
    app.allActions = new java.util.HashMap<>();
    app.vm.sampleMemberStart(0);
    app.currentDataSource = app.dataID_ensembleForecast;
    app.X_clicked = 110;
    app.Y_clicked = 10;
    app.mouseButton = app.LEFT;

    app.UI_caseBar.handleScenarioClick(0, 0, 200, 20, 1, 21);

    assertEquals(12, app.sampleMemberStart);
  }

  @Test
  void handleScenarioClick_ensembleObservation_leftSetsSampleStationStart () {
    app.allActions = new java.util.HashMap<>();
    app.vm.sampleStationStart(0);
    // Sample Station Start's own bounds are ensembleObservationStart/End
    // (the default End is just nearestWeatherStationCount, 1 by
    // default) - widened here so 12 is actually in range.
    app.ensembleObservationStart = 1;
    app.ensembleObservationEnd = 20;
    app.currentDataSource = app.dataID_ensembleObservation;
    app.X_clicked = 110;
    app.Y_clicked = 10;
    app.mouseButton = app.LEFT;

    app.UI_caseBar.handleScenarioClick(0, 0, 200, 20, 1, 21);

    assertEquals(12, app.sampleStationStart);
  }

  @Test
  void handleScenarioClick_anUnrecognizedDataSource_dispatchesNothing () {
    app.allActions = new java.util.HashMap<>();
    app.currentDataSource = app.dataID_climateTypicalYear; // none of the three handled branches
    app.X_clicked = 110;
    app.Y_clicked = 10;
    app.mouseButton = app.LEFT;

    assertDoesNotThrow(() -> app.UI_caseBar.handleScenarioClick(0, 0, 200, 20, 1980, 2000));
  }

  @Test
  void handleScenarioClick_outsideTheTrack_doesNothing () {
    app.allActions = new java.util.HashMap<>();
    app.vm.sampleYearStart(0);
    app.currentDataSource = app.dataID_climateEngineering;
    int before = app.sampleYearStart;
    app.X_clicked = -1;
    app.Y_clicked = -1;
    app.mouseButton = app.LEFT;

    app.UI_caseBar.handleScenarioClick(0, 0, 200, 20, 1980, 2000);

    assertEquals(before, app.sampleYearStart);
  }

  // ================= handleImpactLayerIndexClicks =============================

  @Test
  void handleImpactLayerIndexClicks_clickingACell_setsImpactLayerIndex () {
    app.allActions = new java.util.HashMap<>();
    app.vm.impactLayerIndex(0);
    // Dead center of cell 4 (see impactCellBounds_cellFour_... above).
    app.X_clicked = 0;
    app.Y_clicked = 0;

    app.UI_caseBar.handleImpactLayerIndexClicks(0, 0, 300, 300);

    assertEquals(4, app.STUDY.impactLayerIndex);
  }

  @Test
  void handleImpactLayerIndexClicks_outsideEveryCell_doesNothing () {
    app.allActions = new java.util.HashMap<>();
    app.vm.impactLayerIndex(0);
    int before = app.STUDY.impactLayerIndex;
    app.X_clicked = 10000;
    app.Y_clicked = 10000;

    app.UI_caseBar.handleImpactLayerIndexClicks(0, 0, 300, 300);

    assertEquals(before, app.STUDY.impactLayerIndex);
  }
}
