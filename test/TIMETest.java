import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

class TIMETest {

  private static solarchvision_bim app;
  private static solarchvision_bim.TIME time;

  @BeforeAll
  static void setUp () {
    app = new solarchvision_bim();
    time = app.TIME;
  }

  // --- safeDate -----------------------------------------------------

  @Test
  void safeDate_wrapsIntoZeroTo366Range () {
    assertEquals(0, time.safeDate(0));
    assertEquals(365, time.safeDate(-1));   // one day before the epoch wraps to the last index
    assertEquals(0, time.safeDate(366));    // exactly one full (366-day) year wraps back to 0
  }

  @Test
  void safeDate_epsilonRecoversFromFloatingPointUndershoot () {
    // 0.001 is added before flooring specifically so a value that should
    // be an exact integer, but landed just under it due to float error
    // (here 4.9999999 instead of 5), still floors to the intended 5
    // rather than silently landing a day early.
    assertEquals(5, time.safeDate(4.9999999f));
  }

  // --- convert2Day / convert2Date ----------------------------------

  // convert2Day() is dead code (not called anywhere in src/, confirmed
  // by grep) and was deliberately left on the old 365-day approximation
  // when the rest of TIME moved to 366 (see its own comment in
  // time.pde) - these two tests pin down that it's still unchanged,
  // not that 365 is still correct anywhere else in this class.
  @Test
  void convert2Day_insertsExtraDaysAtEachThreshold () {
    assertEquals(0, time.convert2Day(0));
    assertEquals(30, time.convert2Day(30));   // below the first threshold: unchanged
    assertEquals(32, time.convert2Day(31));   // crosses the 31 threshold: +1
    assertEquals(95, time.convert2Day(92));   // crosses all of 31/62/93: +3
    assertEquals(185, time.convert2Day(180)); // crosses all 5 thresholds: +5
  }

  @Test
  void convert2Day_wrapsDateAngleModulo360 () {
    assertEquals(time.convert2Day(359), time.convert2Day(-1));
    assertEquals(time.convert2Day(0), time.convert2Day(360));
  }

  @Test
  void convert2Date_matchesASequentialJanuaryFirstCalendar () {
    // Unlike the createCalendar() table (see class comment),
    // convert2Date counts sequentially from January 1 = index 0.
    assertEquals(0, time.convert2Date(1, 1));    // Jan 1
    assertEquals(30, time.convert2Date(1, 31));  // Jan 31
    assertEquals(31, time.convert2Date(2, 1));   // Feb 1
    assertEquals(60, time.convert2Date(3, 1));   // Mar 1 (31 + 29 days before it - Feb is always 29 in this generic calendar)
    assertEquals(365, time.convert2Date(12, 31)); // last day of a 366-day year
  }

  // --- calendar lookup tables (built by createCalendar) -----------

  // None of the known-index values below changed when lengthOfMonths[1]
  // grew from 28 to 29 (see createCalendar()'s own comment in time.pde):
  // index 0 is Mar 21 and index 286 is Jan 1 regardless of February's
  // length (the days from Mar 21 to Dec 31 - which is what separates
  // them - never pass through February at all), and index 200 (Oct 7)
  // sits inside that same Feb-independent Mar21..Dec31 stretch too.
  @Test
  void calendarLookups_matchTheNowruzAlignedWalkAtKnownIndices () {
    assertEquals(3, time.getMonth_fromDate(0));
    assertEquals(21, time.getDay_fromDate(0));
    assertEquals("0321", time.getMMDD(0));
    assertEquals("March 21", time.getDayText(0));

    assertEquals(1, time.getMonth_fromDate(286));
    assertEquals(1, time.getDay_fromDate(286));
    assertEquals("0101", time.getMMDD(286));
    assertEquals("January 1", time.getDayText(286));

    assertEquals(10, time.getMonth_fromDate(200));
    assertEquals(7, time.getDay_fromDate(200));
    assertEquals("1007", time.getMMDD(200));
  }

  @Test
  void calendarLookups_goThroughSafeDateSoOutOfRangeIndicesStillResolve () {
    // getMonth_fromDate/getDay_fromDate/etc. all route their argument
    // through safeDate() first, so values outside [0, 366) still land on
    // a valid table entry instead of throwing.
    assertEquals(time.getMonth_fromDate(0), time.getMonth_fromDate(366));
    assertEquals(time.getDay_fromDate(0), time.getDay_fromDate(366));
    // index 365 (the last slot before the wrap back to index 0 / Mar 21)
    // is Mar 20 either way - it's always the day right before Mar 21,
    // regardless of February's length.
    assertEquals(time.getMonth_fromDate(365), time.getMonth_fromDate(-1));
  }

  @Test
  void getMM_returnsJustTheTwoDigitMonth () {
    assertEquals("03", time.getMM(0));   // March 21
    assertEquals("01", time.getMM(286)); // January 1
  }

  // --- updateDate -----------------------------------------------------

  @Test
  void updateDate_derivesMonthDayAndHourFromTheCurrentDate () {
    time.date = 286.5f; // January 1, half a day in

    time.updateDate();

    assertEquals(1, time.month);
    assertEquals(1, time.day);
    assertEquals(12, time.hour);
  }

  @Test
  void updateDate_truncatesTheHourRatherThanRounding () {
    time.date = 286.99f; // just under a full day past January 1's start

    time.updateDate();

    assertEquals(23, time.hour); // int(24 * 0.99) = 23, not 24
  }

  // --- to_XML / from_XML round trip -----------------------------------

  @Test
  void toXMLThenFromXML_roundTripsEveryField () {
    solarchvision_bim.TIME original = app.TIME;
    original.modelRun = 6;
    original.year = 2024;
    original.month = 7;
    original.day = 15;
    original.hour = 14;
    original.beginDay = 200;
    original.date = 123.5f;

    processing.data.XML root = new processing.data.XML("root");
    original.to_XML(root);

    solarchvision_bim.TIME fresh = app.new TIME();
    fresh.from_XML(root);

    assertEquals(6, fresh.modelRun);
    assertEquals(2024, fresh.year);
    assertEquals(7, fresh.month);
    assertEquals(15, fresh.day);
    assertEquals(14, fresh.hour);
    assertEquals(200, fresh.beginDay);
    assertEquals(123.5f, fresh.date, 0.0001f);
  }

  // --- isLeapYear (step 4a groundwork: pure, no callers yet) ---------

  @Test
  void isLeapYear_trueForOrdinaryMultiplesOfFour () {
    assertTrue(time.isLeapYear(2024));
    assertTrue(time.isLeapYear(2028));
  }

  @Test
  void isLeapYear_falseForNonMultiplesOfFour () {
    assertFalse(time.isLeapYear(2025));
    assertFalse(time.isLeapYear(2026));
    assertFalse(time.isLeapYear(2027));
  }

  @Test
  void isLeapYear_falseForCenturyYearsNotDivisibleBy400 () {
    // 1900 and 2100 are both divisible by 100 but not by 400, so the
    // ordinary "divisible by 4" rule alone would wrongly call them leap
    assertFalse(time.isLeapYear(1900));
    assertFalse(time.isLeapYear(2100));
  }

  @Test
  void isLeapYear_trueForCenturyYearsDivisibleBy400 () {
    assertTrue(time.isLeapYear(2000));
    assertTrue(time.isLeapYear(1600));
  }

  // --- lengthOfMonthInRealYear (step 4b) ------------------------------

  @Test
  void lengthOfMonthInRealYear_februaryTracksLeapYearNotTheGenericTable () {
    // the generic calendar's own lengthOfMonths[1] is always 29 (see
    // time.pde) - this must NOT follow that for a real, non-leap year
    assertEquals(29, time.lengthOfMonthInRealYear(2024, 2));
    assertEquals(28, time.lengthOfMonthInRealYear(2025, 2));
    assertEquals(28, time.lengthOfMonthInRealYear(1900, 2));
    assertEquals(29, time.lengthOfMonthInRealYear(2000, 2));
  }

  @Test
  void lengthOfMonthInRealYear_otherMonthsMatchTheGenericTableRegardlessOfYear () {
    assertEquals(31, time.lengthOfMonthInRealYear(2024, 1));
    assertEquals(30, time.lengthOfMonthInRealYear(2025, 4));
    assertEquals(31, time.lengthOfMonthInRealYear(2025, 12));
  }

  // --- isValidRealDate (step 4b: the actual "Feb 29 validation") -----

  @Test
  void isValidRealDate_february29thIsValidOnlyInALeapYear () {
    assertTrue(time.isValidRealDate(2024, 2, 29));
    assertTrue(time.isValidRealDate(2000, 2, 29));
    assertFalse(time.isValidRealDate(2025, 2, 29));
    assertFalse(time.isValidRealDate(1900, 2, 29)); // divisible by 100, not by 400
  }

  @Test
  void isValidRealDate_rejectsOutOfRangeMonthOrDay () {
    assertFalse(time.isValidRealDate(2025, 0, 15));
    assertFalse(time.isValidRealDate(2025, 13, 15));
    assertFalse(time.isValidRealDate(2025, 4, 31));  // April has 30 days
    assertFalse(time.isValidRealDate(2025, 1, 0));
  }

  @Test
  void isValidRealDate_acceptsOrdinaryInRangeDates () {
    assertTrue(time.isValidRealDate(2025, 1, 1));
    assertTrue(time.isValidRealDate(2025, 4, 30));
    assertTrue(time.isValidRealDate(2025, 12, 31));
  }

  // --- dayOfYearInRealYear (step 4b) ----------------------------------

  @Test
  void dayOfYearInRealYear_januaryFirstIsAlwaysDayOne () {
    assertEquals(1, time.dayOfYearInRealYear(2024, 1, 1));
    assertEquals(1, time.dayOfYearInRealYear(2025, 1, 1));
  }

  @Test
  void dayOfYearInRealYear_decemberThirtyFirstReflectsTheRealYearLength () {
    assertEquals(366, time.dayOfYearInRealYear(2024, 12, 31)); // leap
    assertEquals(365, time.dayOfYearInRealYear(2025, 12, 31)); // common
  }

  @Test
  void dayOfYearInRealYear_marchFirstShiftsByOneDependingOnFebruary () {
    assertEquals(61, time.dayOfYearInRealYear(2024, 3, 1)); // 31 + 29 + 1
    assertEquals(60, time.dayOfYearInRealYear(2025, 3, 1)); // 31 + 28 + 1
  }

  // --- daysFromRealCivilEpoch / weekdayFromRealDate (step 4b) ---------

  @Test
  void weekdayFromRealDate_epochDateIsThursday () {
    // 1970-01-01, day 0 of the Unix civil epoch, was a Thursday
    assertEquals(0L, time.daysFromRealCivilEpoch(1970, 1, 1));
    assertEquals(4, time.weekdayFromRealDate(1970, 1, 1)); // 0=Sunday..6=Saturday
  }

  @Test
  void weekdayFromRealDate_matchesKnownHistoricalWeekdays () {
    // cross-checked against a reference proleptic-Gregorian calendar
    assertEquals(6, time.weekdayFromRealDate(2000, 1, 1));  // Saturday
    assertEquals(1, time.weekdayFromRealDate(2024, 1, 1));  // Monday
    assertEquals(4, time.weekdayFromRealDate(2024, 2, 29)); // Thursday (leap day)
  }

  @Test
  void weekdayFromRealDate_handlesDatesBeforeTheEpochWithoutGoingNegative () {
    // 1600-02-29 is a leap day in a 400-divisible century year, and
    // well before the 1970 epoch - exercises the "+7" guard against
    // Java's sign-preserving "%" on a negative days-since-epoch value
    assertEquals(2, time.weekdayFromRealDate(1600, 2, 29)); // Tuesday
  }

  // --- monthDayFromGenericIndex (step 4c: inverse of convert2Date) ---

  @Test
  void monthDayFromGenericIndex_isTheExactInverseOfConvert2Date () {
    // same (month, day) pairs convert2Date_matchesASequentialJanuaryFirstCalendar
    // above already pins down, round-tripped the other way
    assertArrayEquals(new int[]{1, 1}, time.monthDayFromGenericIndex(0));    // Jan 1
    assertArrayEquals(new int[]{1, 31}, time.monthDayFromGenericIndex(30)); // Jan 31
    assertArrayEquals(new int[]{2, 1}, time.monthDayFromGenericIndex(31));  // Feb 1
    assertArrayEquals(new int[]{2, 29}, time.monthDayFromGenericIndex(59)); // Feb 29 (generic slot)
    assertArrayEquals(new int[]{3, 1}, time.monthDayFromGenericIndex(60));  // Mar 1
    assertArrayEquals(new int[]{12, 31}, time.monthDayFromGenericIndex(365)); // Dec 31
  }

  @Test
  void monthDayFromGenericIndex_wrapsOutOfRangeIndicesLikeConvert2Date () {
    assertArrayEquals(time.monthDayFromGenericIndex(0), time.monthDayFromGenericIndex(366));
    assertArrayEquals(time.monthDayFromGenericIndex(365), time.monthDayFromGenericIndex(-1));
  }

  // --- genericIndexFromRealDate (step 4c) -----------------------------

  @Test
  void genericIndexFromRealDate_matchesConvert2DateForAnyValidRealDate () {
    assertEquals(time.convert2Date(1, 1), time.genericIndexFromRealDate(2025, 1, 1));
    assertEquals(time.convert2Date(3, 1), time.genericIndexFromRealDate(2025, 3, 1));
    assertEquals(time.convert2Date(2, 29), time.genericIndexFromRealDate(2024, 2, 29)); // leap year
  }

  @Test
  void genericIndexFromRealDate_rejectsFebruary29thInANonLeapRealYear () {
    // the exact gap convert2Date() alone cannot see: it would happily
    // return 59 here too, the same as for 2024
    assertEquals(-1, time.genericIndexFromRealDate(2025, 2, 29));
    assertEquals(-1, time.genericIndexFromRealDate(1900, 2, 29));
  }

  @Test
  void genericIndexFromRealDate_rejectsOtherOutOfRangeRealDates () {
    assertEquals(-1, time.genericIndexFromRealDate(2025, 4, 31)); // April has 30 days
    assertEquals(-1, time.genericIndexFromRealDate(2025, 13, 1));
  }

  // --- realDateFromGenericIndex (step 4c) -----------------------------

  @Test
  void realDateFromGenericIndex_roundTripsAnOrdinaryDateForAnyYear () {
    solarchvision_bim.TIME.RealDate rd = time.realDateFromGenericIndex(60, 2025); // Mar 1
    assertEquals(2025, rd.year);
    assertEquals(3, rd.month);
    assertEquals(1, rd.day);
    assertTrue(rd.valid);
  }

  @Test
  void realDateFromGenericIndex_february29thSlotIsValidOnlyInALeapYear () {
    solarchvision_bim.TIME.RealDate leap = time.realDateFromGenericIndex(59, 2024);
    assertEquals(2, leap.month);
    assertEquals(29, leap.day);
    assertTrue(leap.valid);

    // same generic slot, a non-leap target real year: this is the
    // "undefined/empty for that year" Feb-29 gap made explicit
    solarchvision_bim.TIME.RealDate common = time.realDateFromGenericIndex(59, 2025);
    assertEquals(2, common.month);
    assertEquals(29, common.day);
    assertFalse(common.valid);
  }

  @Test
  void genericIndexFromRealDate_and_realDateFromGenericIndex_roundTripForEveryValidRealDate () {
    // exhaustive round trip, both leap and common real years, every
    // month: genericIndexFromRealDate then back through
    // realDateFromGenericIndex always recovers the same valid date
    for (int year : new int[]{2024, 2025}) {
      for (int month = 1; month <= 12; month++) {
        int daysInMonth = time.lengthOfMonthInRealYear(year, month);
        for (int day = 1; day <= daysInMonth; day++) {
          int idx = time.genericIndexFromRealDate(year, month, day);
          assertTrue(idx >= 0, "expected a valid index for " + year + "-" + month + "-" + day);

          solarchvision_bim.TIME.RealDate rd = time.realDateFromGenericIndex(idx, year);
          assertTrue(rd.valid);
          assertEquals(month, rd.month);
          assertEquals(day, rd.day);
        }
      }
    }
  }

  // --- persianMonthLength (step 4d, Table B) --------------------------

  @Test
  void persianMonthLength_sixThirtyOneDayPositionsForTheSlowAphelionHalf () {
    for (int position = 0; position < 6; position++) {
      assertEquals(31, time.persianMonthLength(position, 2025));
    }
  }

  @Test
  void persianMonthLength_fiveThirtyDayPositionsForTheFastPerihelionHalf () {
    for (int position = 6; position < 11; position++) {
      assertEquals(30, time.persianMonthLength(position, 2025));
    }
  }

  @Test
  void persianMonthLength_lastPositionFollowsIsLeapYearLikeRealFebruaryDoes () {
    assertEquals(30, time.persianMonthLength(11, 2024)); // leap
    assertEquals(29, time.persianMonthLength(11, 2025)); // common
  }

  @Test
  void persianMonthLength_allTwelvePositionsSumToThatRealYearsOwnTrueLength () {
    for (int year : new int[]{2024, 2025}) {
      int total = 0;
      for (int position = 0; position < 12; position++) {
        total += time.persianMonthLength(position, year);
      }
      assertEquals(time.isLeapYear(year) ? 366 : 365, total);
    }
  }

  // --- dateAngleFromRealDate (step 4d, rewritten: Table-B-stepped) ---

  // Every one of these expected values was cross-checked with a Python
  // simulation of this function before being written here - see
  // time.pde's own comment on dateAngleFromRealDate and
  // persianMonthLength for the physics and the walk this implements.

  @Test
  void dateAngleFromRealDate_march21stIsAlwaysTheZeroAnchor () {
    // true in both a leap and a non-leap real year, by construction
    assertEquals(0f, time.dateAngleFromRealDate(2024, 3, 21), 0.0001f);
    assertEquals(0f, time.dateAngleFromRealDate(2025, 3, 21), 0.0001f);
  }

  @Test
  void dateAngleFromRealDate_landsOnAnExactMultipleOfThirtyAtEveryPersianMonthBoundary () {
    // the core property this whole rewrite is for: unlike a linear
    // model (this function's first version, or the generic formula),
    // walking Table B's uneven positions lands exactly on 30, 60, 90...
    // degrees at each boundary regardless of how many real days that
    // position actually took - cross-checked against real calendar
    // dates 31, 62, 93... real days after Mar 21 (via Python's
    // datetime), for a leap equinox-year (starting 2024, so its own
    // flex position - spanning late Feb into March of 2025 - is 30
    // real days) and a common one (starting 2025, flex position 29
    // real days, so its boundary dates shift a day earlier)
    assertEquals(30f, time.dateAngleFromRealDate(2024, 4, 21), 0.0001f);
    assertEquals(60f, time.dateAngleFromRealDate(2024, 5, 22), 0.0001f);
    assertEquals(300f, time.dateAngleFromRealDate(2025, 1, 21), 0.0001f); // still part of the 2024-start equinox-year
    assertEquals(330f, time.dateAngleFromRealDate(2025, 2, 20), 0.0001f);
    assertEquals(0f, time.dateAngleFromRealDate(2025, 3, 21), 0.0001f);   // next equinox-year's own zero

    assertEquals(300f, time.dateAngleFromRealDate(2026, 1, 21), 0.0001f); // the 2025-start (common) equinox-year
    assertEquals(330f, time.dateAngleFromRealDate(2026, 2, 20), 0.0001f);
  }

  @Test
  void dateAngleFromRealDate_interpolatesMoreSlowlyAcrossA31DayPositionThanA30DayOne () {
    // same number of days (5) into the first position of each half:
    // the 31-day (slow/aphelion) position advances fewer degrees per
    // day than the 30-day (fast/perihelion) one - the actual
    // Kepler/eccentricity effect this step exists to approximate
    float fiveDaysIntoA31DayPosition = time.dateAngleFromRealDate(2025, 3, 26); // position 0 (starts Mar 21), day index 5
    float fiveDaysIntoA30DayPosition = time.dateAngleFromRealDate(2025, 9, 28); // position 6 (starts Sep 23), day index 5
    assertEquals(30.0 * 0 + 30.0 * 5 / 31, fiveDaysIntoA31DayPosition, 0.0001f);
    assertEquals(30.0 * 6 + 30.0 * 5 / 30, fiveDaysIntoA30DayPosition, 0.0001f);
    assertTrue(fiveDaysIntoA31DayPosition < fiveDaysIntoA30DayPosition);
  }

  @Test
  void dateAngleFromRealDate_midPositionInterpolation () {
    assertEquals(14.516129f, time.dateAngleFromRealDate(2025, 4, 5), 0.0001f);  // 15 real days into the 31-day position starting Mar 21
    assertEquals(202.0f, time.dateAngleFromRealDate(2025, 10, 15), 0.0001f);    // squarely inside the 30-day second half
  }

  @Test
  void dateAngleFromRealDate_flexPositionSizingFollowsTheDatesOwnWrittenYear () {
    // 2027-03-21 starts a common equinox-year (2027 is common) whose
    // own flex position (Esfand-equivalent) therefore has 29 real
    // days and falls late Feb/early Mar of 2028 - but 2028 is itself
    // a leap year, so a date written with year 2028 (Feb 29 included)
    // must still use isLeapYear(2028) = true for its own flex
    // position's length, per persianMonthLength's own contract, and
    // that is what actually determines where it lands - not 2027's
    assertEquals(338f, time.dateAngleFromRealDate(2028, 2, 28), 0.0001f);
    assertEquals(339f, time.dateAngleFromRealDate(2028, 2, 29), 0.0001f);
    // the day immediately before the next equinox never quite reaches
    // 360 (the same kind of "last day of a bucket" gap any day-count
    // interpolation has) - here in a leap equinox-year specifically
    assertEquals(359f, time.dateAngleFromRealDate(2024, 3, 20), 0.0001f);
  }
}
