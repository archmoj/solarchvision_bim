import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

// Exercises solarchvision_TIME (the `TIME` global) - safeDate's
// float-to-index wrapping, the Date_Angle <-> day-of-year conversions,
// and the pre-built calendar lookup tables. All pure and deterministic:
// createCalendar() (which builds the lookup tables) only does in-memory
// arithmetic, no file I/O, no station/weather data.
//
// `TIME` is already a package-private, pre-constructed instance field on
// the sketch (`solarchvision_TIME TIME = new solarchvision_TIME();`),
// and its constructor already calls createCalendar(), so the lookup
// tables are ready as soon as the sketch is built - no extra setup
// needed here.
//
// A note on indices: createCalendar() starts its (month, day) walk from
// k=285, not 0, so index 0 lands on March 21 rather than January 1. This
// is intentional - the table is built around the Iranian/Persian solar
// calendar, whose new year (Nowruz) begins on the March equinox (March
// 21 on the Gregorian calendar). convert2Date, in contrast, does count
// sequentially from a Gregorian January 1 = index 0 - the two are
// separate, unrelated indexing schemes that happen to live in the same
// class, not a round-trippable pair.
class TIMETest {

  private static solarchvision_bim app;
  private static solarchvision_bim.solarchvision_TIME time;

  @BeforeAll
  static void setUp () {
    app = new solarchvision_bim();
    time = app.TIME;
  }

  // --- safeDate -----------------------------------------------------

  @Test
  void safeDate_wrapsIntoZeroTo365Range () {
    assertEquals(0, time.safeDate(0));
    assertEquals(364, time.safeDate(-1));   // one day before the epoch wraps to the last index
    assertEquals(0, time.safeDate(365));    // exactly one full year wraps back to 0
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
    assertEquals(59, time.convert2Date(3, 1));   // Mar 1 (31 + 28 days before it)
    assertEquals(364, time.convert2Date(12, 31)); // last day of a 365-day year
  }

  // --- calendar lookup tables (built by createCalendar) -----------

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
    // through safeDate() first, so values outside [0, 365) still land on
    // a valid table entry instead of throwing.
    assertEquals(time.getMonth_fromDate(0), time.getMonth_fromDate(365));
    assertEquals(time.getDay_fromDate(0), time.getDay_fromDate(365));
    assertEquals(time.getMonth_fromDate(364), time.getMonth_fromDate(-1));
  }
}
