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
}
