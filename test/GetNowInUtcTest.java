import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// getNowInUtc.pde's day/month/year rollover logic used to live entirely
// inside getNow_inUTC() itself, which reads Processing's own real-clock
// functions (year()/month()/day()/hour()) - making the rollover branches
// impossible to exercise deterministically (10/16 of its JaCoCo branches
// were never hit by any existing test, since every test run's "now" only
// ever visits the LocationTimeZone == 0 shape by construction - see
// getNowInUtcTest_zeroOffset... below). The rollover arithmetic is now
// split out into convert_LocalToUTC(LocationTimeZone, year, month, day,
// hour) (same body, see getNowInUtc.pde), a pure function this file
// exercises directly with fixed inputs; getNow_inUTC() is now just a
// 2-line wrapper that captures the real clock and delegates to it.
class GetNowInUtcTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= convert_LocalToUTC: zero offset ========================

  @Test
  void convertLocalToUTC_zeroOffset_returnsEveryFieldUnchanged () {
    assertArrayEquals(new int[]{2024, 6, 15, 10}, app.convert_LocalToUTC(0, 2024, 6, 15, 10));
  }

  // ================= convert_LocalToUTC: positive offset (local is ahead of UTC) =====

  @Test
  void convertLocalToUTC_positiveOffset_subtractsHoursWithNoRollover () {
    // 10:00 local at UTC+5 is 05:00 UTC the same day.
    assertArrayEquals(new int[]{2024, 6, 15, 5}, app.convert_LocalToUTC(5, 2024, 6, 15, 10));
  }

  @Test
  void convertLocalToUTC_positiveOffset_hourUnderflow_rollsBackADay () {
    // 03:00 local at UTC+5 is the previous day, 22:00 UTC.
    assertArrayEquals(new int[]{2024, 6, 14, 22}, app.convert_LocalToUTC(5, 2024, 6, 15, 3));
  }

  @Test
  void convertLocalToUTC_positiveOffset_dayUnderflow_rollsBackAMonth_toItsLastDay () {
    // Day 1 rolling back a day lands in the previous month, whose last day
    // comes from TIME.lengthOfMonths - June 1st -> May 31st.
    assertArrayEquals(new int[]{2024, 5, 31, 22}, app.convert_LocalToUTC(5, 2024, 6, 1, 3));
  }

  @Test
  void convertLocalToUTC_positiveOffset_monthUnderflow_rollsBackAYear_toDecember () {
    // January 1st rolling back a day lands in December of the previous year.
    assertArrayEquals(new int[]{2023, 12, 31, 22}, app.convert_LocalToUTC(5, 2024, 1, 1, 3));
  }

  // ================= convert_LocalToUTC: negative offset (local is behind UTC) ======

  @Test
  void convertLocalToUTC_negativeOffset_addsHoursWithNoRollover () {
    // 10:00 local at UTC-5 is 15:00 UTC the same day.
    assertArrayEquals(new int[]{2024, 6, 15, 15}, app.convert_LocalToUTC(-5, 2024, 6, 15, 10));
  }

  @Test
  void convertLocalToUTC_negativeOffset_hourOverflow_rollsForwardADay () {
    // 20:00 local at UTC-5 is the next day, 01:00 UTC.
    assertArrayEquals(new int[]{2024, 6, 16, 1}, app.convert_LocalToUTC(-5, 2024, 6, 15, 20));
  }

  @Test
  void convertLocalToUTC_negativeOffset_dayOverflow_rollsForwardAMonth () {
    // June 30th (June's own last day, TIME.lengthOfMonths) rolling forward
    // a day lands on July 1st.
    assertArrayEquals(new int[]{2024, 7, 1, 1}, app.convert_LocalToUTC(-5, 2024, 6, 30, 20));
  }

  @Test
  void convertLocalToUTC_negativeOffset_monthOverflow_rollsForwardAYear_toJanuary () {
    // December 31st rolling forward a day lands in January of the next year.
    assertArrayEquals(new int[]{2025, 1, 1, 1}, app.convert_LocalToUTC(-5, 2024, 12, 31, 20));
  }

  // ================= getNow_inUTC: thin wrapper over the real clock =========
  // The default STATION (Toronto, longitude -79.63 - see globalVariables.pde)
  // rounds to a LocationTimeZone of exactly 0 (getLocationTimeZone():
  // roundTo(-79.63/15, 15) == roundTo(-5.309, 15) == 0, the nearest multiple
  // of 15), so convert_LocalToUTC()'s zero-offset branch applies and
  // getNow_inUTC() must return the real clock's year/month/day/hour
  // untouched - checkable deterministically against app.year()/month()/
  // day()/hour() (the same Processing clock functions it calls internally)
  // without needing to fake "now".

  @Test
  void getNowInUTC_withTheDefaultStation_passesTheRealClockThroughUnchanged () {
    assertEquals(0, app.getLocationTimeZone(), "test precondition: default STATION's offset must be 0 for this to be deterministic");

    int[] expected = {app.year(), app.month(), app.day(), app.hour()};
    assertArrayEquals(expected, app.getNow_inUTC());
  }

  @Test
  void getNowInUTC_delegatesToConvertLocalToUTC_withTheStationsOwnTimeZone () {
    // A station far enough west of Toronto to round to a non-zero
    // LocationTimeZone (Vancouver, longitude -123.17 -> roundTo(-8.21, 15)
    // == -15, i.e. UTC-15 - an unrealistic timezone, but this only exists
    // to prove getNow_inUTC() actually threads getLocationTimeZone()'s
    // result through to convert_LocalToUTC(), not to model a real place).
    app.STATION.setLongitude(-123.17f);
    assertEquals(-15, app.getLocationTimeZone(), "test precondition");

    int[] viaWrapper = app.getNow_inUTC();
    int[] viaDirectCall = app.convert_LocalToUTC(-15, app.year(), app.month(), app.day(), app.hour());

    assertArrayEquals(viaDirectCall, viaWrapper);
  }
}
