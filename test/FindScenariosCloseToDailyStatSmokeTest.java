import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// FIND_SCENARIOS_CLOSE_TO_DAILY_STAT() (findScenarioCloseToDailyStatistic.pde)
// was at 0% coverage (324 instructions, 46 branches) - the function
// scenarioSampleCount()/_FIND_SCENARIOS_CLOSE_TO_STAT() siblings already
// covered by FindScenarioCloseToStatTest.java feed into, but itself
// never exercised: it's the one that actually reads real hourly weather
// data (getValue_currentDataSource(), filter()) across a day-merged
// window, computes NORMAL() on the result, and searches it - all of
// which needs real(ish) data to do anything beyond return an empty
// array.
//
// Same smoke-test scope as SolarArraySmokeTest.java's own comment on
// calculate_GlobalSolar_array()/calculate_VertexSolar_array(): hand (or
// Python) reimplementing this function's own nearest-scenario search
// against a real file, to independently verify an exact expected
// winning index, is its own separate, larger effort - what's checked
// here is that it runs end-to-end against a real, varied year of
// weather data and returns a well-formed, correctly-bounded result,
// which is enough to meaningfully exercise its real logic rather than
// just its own "nothing defined" early exits.
class FindScenariosCloseToDailyStatSmokeTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.sketchPath(); // see LoadClimateTypicalYearTest.java's own comment on why

    int numLayers = app.allLayers.length;
    app.climateTypicalYearValues = new float[24][365][numLayers][1];
    app.climateTypicalYearFlags = new boolean[24][365][numLayers][1];
    for (float[][][] perJ : app.climateTypicalYearValues) {
      for (float[][] perLayer : perJ) {
        for (float[] perK : perLayer) {
          java.util.Arrays.fill(perK, app.FLOAT_undefined);
        }
      }
    }

    app.load_climateTypicalYear(System.getProperty("user.dir") + "/input/climate/TMYEPW/CAN_ON_Toronto.716240_CWEC.epw");
    app.currentDataSource = app.dataID_climateTypicalYear;
  }

  @Test
  void aSummerDay_returnsAWellFormedResult_fromRealWeatherData () {
    // currentDataSource is climateTypicalYear, so get_startK_endK()
    // (already fully covered by GetStartKEndKTest.java) returns {0, 0} -
    // the only "year" a TMY file has.
    int[] startKEndK = app.get_startK_endK();
    int start_k = startKEndK[0];
    int end_k = startKEndK[1];

    // j=6 with the defaults (STUDY.dayIncrement 30.5, TIME.beginDay 0,
    // daysMergedCount 30) centers the merged-day window on day-of-year
    // ~183 (early July) - the same season LoadClimateTypicalYearTest.java's
    // own "a summer daytime hour" test already confirms has real,
    // nonzero solar radiation in this exact file. DATE_ANGLE computed
    // the same way sync_SHADE_DATE_ANGLE() does for that day-of-year
    // (ImpactDayToDayOfYearTest.java's own derivation style): 360 *
    // ((286 + 182) % 365) / 365.0 ~= 101.59.
    int j = 6;
    float DATE_ANGLE = 360f * ((286 + 182) % 365) / 365f;

    int[] result = app.FIND_SCENARIOS_CLOSE_TO_DAILY_STAT(
        app.STAT_N_Ave, start_k, end_k, j, DATE_ANGLE, app.Impact_ACTIVE);

    assertNotNull(result);
    assertTrue(result.length > 0, "a real summer day's worth of actual weather data must yield at least one usable sample");
    assertTrue(result.length <= app.scenarioSampleCount(app.STAT_N_Ave), "never more samples than scenarioSampleCount() itself allows");

    int total = (1 + end_k - start_k) * app.STUDY.daysMergedCount;
    for (int idx : result) {
      assertTrue(idx >= 0 && idx < total, "every returned index must fall inside the scenario-index space FIND_SCENARIOS_CLOSE_TO_DAILY_STAT() itself searches");
    }
  }

  @Test
  void withNoScenariosDefinedForTheRequestedDay_returnsAnEmptyArray_neverNull () {
    // A day index far enough into negative territory that none of the
    // merged days it touches were ever written by load_climateTypicalYear()
    // in the first place - every lookup stays FLOAT_undefined, exactly
    // the "nothing defined" case _FIND_SCENARIOS_CLOSE_TO_STAT() (already
    // covered directly by FindScenarioCloseToStatTest.java) handles by
    // returning an empty (never null) array.
    //
    // Re-allocating climateTypicalYearValues all-undefined again here
    // (setUp() already did, but load_climateTypicalYear() just filled
    // real values into every real calendar day - this test needs none
    // of that real data reachable) confirms the empty-array branch
    // specifically, independent of whatever real file happens to be
    // loaded.
    int numLayers = app.allLayers.length;
    app.climateTypicalYearValues = new float[24][365][numLayers][1];
    for (float[][][] perJ : app.climateTypicalYearValues) {
      for (float[][] perLayer : perJ) {
        for (float[] perK : perLayer) {
          java.util.Arrays.fill(perK, app.FLOAT_undefined);
        }
      }
    }

    int[] result = app.FIND_SCENARIOS_CLOSE_TO_DAILY_STAT(
        app.STAT_N_Ave, 0, 0, 6, 101.59f, app.Impact_ACTIVE);

    assertNotNull(result);
    assertEquals(0, result.length);
  }
}
