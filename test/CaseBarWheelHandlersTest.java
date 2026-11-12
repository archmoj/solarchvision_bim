import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// handleHoursCaseBarWheel()/handleDaysCaseBarWheel()/handleScenarioCaseBarWheel()
// (mouseWheel.pde) are thin wrappers - the same shape as
// RotateCameraHelpersTest.java's rotateCameraXY() et al. - that build a
// "+Hours"/"+Days"/"+Scenario" command string from their own float
// argument and dispatch it through runScriptLine(). All 3 were at 0%
// coverage, even though +HOURS/+DAYS/+SCENARIO are each already
// substantially covered elsewhere directly.
class CaseBarWheelHandlersTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
  }

  // ================= handleHoursCaseBarWheel ================================
  // STUDY's own bare-construction defaults: startHour 0, endHour 23.

  @Test
  void positiveWheelValue_advancesBothHoursByOne_wrappingEndHourPast23ToZero () {
    app.handleHoursCaseBarWheel(1);

    assertEquals(1, app.STUDY.startHour);
    assertEquals(0, app.STUDY.endHour, "23 + 1 wraps to 0");
  }

  @Test
  void negativeWheelValue_stepsBothHoursBack_wrappingStartHourBelowZeroTo23 () {
    app.handleHoursCaseBarWheel(-1);

    assertEquals(23, app.STUDY.startHour, "0 - 1 wraps to 23");
    assertEquals(22, app.STUDY.endHour);
  }

  @Test
  void zeroWheelValue_changesNeitherHour () {
    app.handleHoursCaseBarWheel(0);

    assertEquals(0, app.STUDY.startHour);
    assertEquals(23, app.STUDY.endHour);
  }

  // ================= handleDaysCaseBarWheel =================================
  // STUDY.daysMergedCount's own bare-construction default (30) already
  // sits at its own clamp ceiling here (365 / STUDY.endDay == 365/12 ==
  // 30, integer division) - a "+2" from there clamps right back down to
  // 30, an unobservable no-op - so the "advances" case below starts from
  // a lower value instead, to actually see it move.

  @Test
  void positiveWheelValue_advancesDaysMergedCountByTwo () {
    app.STUDY.daysMergedCount = 10;

    app.handleDaysCaseBarWheel(1);

    assertEquals(12, app.STUDY.daysMergedCount);
  }

  @Test
  void negativeWheelValue_decreasesDaysMergedCountByTwo_fromTheDefault () {
    app.handleDaysCaseBarWheel(-1);

    assertEquals(28, app.STUDY.daysMergedCount); // 30 - 2, well above the floor of 1
  }

  @Test
  void positiveWheelValue_atTheDefaultCeiling_isAnUnobservableNoOp () {
    // Pins the ceiling-clamp fact above explicitly, rather than leaving
    // it as only an explanatory comment on the test that works around it.
    assertEquals(30, app.STUDY.daysMergedCount, "test precondition: the bare default");

    app.handleDaysCaseBarWheel(1);

    assertEquals(30, app.STUDY.daysMergedCount, "32 clamped back down to the ceiling (365 / STUDY.endDay) lands exactly on the unchanged value");
  }

  // ================= handleScenarioCaseBarWheel =============================
  // currentDataSource's own bare-construction default is
  // dataID_climateTypicalYear - none of +Scenario's 4 internal branches
  // (climateEngineering/climateArchive/ensembleForecast/ensembleObservation)
  // match it, so this is a safe, total no-op by default.

  @Test
  void onTheDefaultDataSource_doesNotThrow_andChangesNoSampleRange () {
    int ySt = app.sampleYearStart, ySe = app.sampleYearEnd;
    int mSt = app.sampleMemberStart, mSe = app.sampleMemberEnd;
    int sSt = app.sampleStationStart, sSe = app.sampleStationEnd;

    assertDoesNotThrow(() -> app.handleScenarioCaseBarWheel(1));

    assertEquals(ySt, app.sampleYearStart);
    assertEquals(ySe, app.sampleYearEnd);
    assertEquals(mSt, app.sampleMemberStart);
    assertEquals(mSe, app.sampleMemberEnd);
    assertEquals(sSt, app.sampleStationStart);
    assertEquals(sSe, app.sampleStationEnd);
  }
}
