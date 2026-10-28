import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

class FindScenarioCloseToStatTest {

  private static solarchvision_bim app;

  @BeforeAll
  static void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void findsTheExactMatchingIndexWhenTheStatisticEqualsAnElement () {
    float[] values = {10, 20, 30, 40, 50};
    // Average of a symmetric series is 30, which is values[2] exactly.
    int out = app._FIND_SCENARIO_CLOSE_TO_STAT(values, app.STAT_N_Ave);
    assertEquals(2, out);
  }

  @Test
  void searchesTheOriginalArrayOrderNotNORMALsInternalSortedCopy () {
    float[] unsorted = {50, 10, 30, 20, 40};
    // The minimum is always 10, but it sits at index 1 in this
    // (deliberately unsorted) array and index 0 in the sorted order
    // NORMAL computes internally - these must NOT be conflated.
    int out = app._FIND_SCENARIO_CLOSE_TO_STAT(unsorted, app.STAT_N_Min);
    assertEquals(1, out);
  }

  @Test
  void picksTheNearestElementWhenThereIsNoExactMatch () {
    float[] values = {10, 22, 35};
    // Average is 22.333..., closest to values[1]=22 (diff ~0.33) over
    // values[0]=10 (diff ~12.33) or values[2]=35 (diff ~12.67).
    int out = app._FIND_SCENARIO_CLOSE_TO_STAT(values, app.STAT_N_Ave);
    assertEquals(1, out);
  }

  @Test
  void returnsMinusOneWhenNoValuesAreDefined () {
    float[] values = {app.FLOAT_undefined, app.FLOAT_undefined};
    int out = app._FIND_SCENARIO_CLOSE_TO_STAT(values, app.STAT_N_Ave);
    assertEquals(-1, out);
  }

  // ================= _FIND_SCENARIOS_CLOSE_TO_STAT (multi-sample) ========

  @Test
  void multiSample_withSampleCountOne_matchesTheSingleSampleFunctionExactly () {
    float[] unsorted = {50, 10, 30, 20, 40};
    int[] out = app._FIND_SCENARIOS_CLOSE_TO_STAT(unsorted, app.STAT_N_Min, 1);
    assertEquals(1, out.length);
    assertEquals(app._FIND_SCENARIO_CLOSE_TO_STAT(unsorted, app.STAT_N_Min), out[0]);
  }

  @Test
  void multiSample_returnsTheNNearestInNearestFirstOrder () {
    float[] values = {10, 22, 24, 35};
    // Average is 22.75: nearest is values[1]=22 (diff 0.75), then
    // values[2]=24 (diff 1.25), then values[3]=35, then values[0]=10.
    int[] out = app._FIND_SCENARIOS_CLOSE_TO_STAT(values, app.STAT_N_Ave, 2);
    assertArrayEquals(new int[]{1, 2}, out);
  }

  @Test
  void multiSample_capsAtHowManyDefinedValuesExist () {
    float[] values = {10, 20, 30};
    // Only 3 defined values exist - asking for 5 samples still returns
    // just those 3, nearest-first, rather than padding or erroring.
    int[] out = app._FIND_SCENARIOS_CLOSE_TO_STAT(values, app.STAT_N_Ave, 5);
    assertEquals(3, out.length);
  }

  @Test
  void multiSample_skipsUndefinedValues () {
    float[] values = {app.FLOAT_undefined, 10, app.FLOAT_undefined, 30};
    int[] out = app._FIND_SCENARIOS_CLOSE_TO_STAT(values, app.STAT_N_Ave, 3);
    // Average of the two defined values is 20 - both are equally close
    // (diff 10 each), so both come back, in their original index order,
    // and the undefined slots are never included.
    assertArrayEquals(new int[]{1, 3}, out);
  }

  @Test
  void multiSample_returnsEmptyArray_neverNull_whenNothingIsDefined () {
    float[] values = {app.FLOAT_undefined, app.FLOAT_undefined};
    int[] out = app._FIND_SCENARIOS_CLOSE_TO_STAT(values, app.STAT_N_Ave, 3);
    assertNotNull(out);
    assertEquals(0, out.length);
  }

  @Test
  void multiSample_returnsEmptyArray_whenSampleCountIsZeroOrLess () {
    float[] values = {10, 20, 30};
    assertEquals(0, app._FIND_SCENARIOS_CLOSE_TO_STAT(values, app.STAT_N_Ave, 0).length);
  }

  // ================= scenarioSampleCount ====================================
  // Replaces what used to be a single global SCENARIO_SAMPLE_COUNT every
  // FIND_SCENARIOS_CLOSE_TO_DAILY_STAT() caller passed in - now decided per
  // stat instead. Must stay in agreement with scenarioSampleWeight()'s own
  // classification of the same stats (AveragedScenarioValuesTest.java).

  @Test
  void sampleCount_isOne_forMinAndMax () {
    assertEquals(1, app.scenarioSampleCount(app.STAT_N_Min));
    assertEquals(1, app.scenarioSampleCount(app.STAT_N_Max));
  }

  @Test
  void sampleCount_isThree_forAveAndTheThreeWholeDistributionStats () {
    assertEquals(3, app.scenarioSampleCount(app.STAT_N_Ave));
    assertEquals(3, app.scenarioSampleCount(app.STAT_N_MidLow));
    assertEquals(3, app.scenarioSampleCount(app.STAT_N_Middle));
    assertEquals(3, app.scenarioSampleCount(app.STAT_N_MidHigh));
  }

  @Test
  void sampleCount_isTwo_forThePercentilesAndMedian () {
    assertEquals(2, app.scenarioSampleCount(app.STAT_N_M25));
    assertEquals(2, app.scenarioSampleCount(app.STAT_N_M50));
    assertEquals(2, app.scenarioSampleCount(app.STAT_N_M75));
  }
}
