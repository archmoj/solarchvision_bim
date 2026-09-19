import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

class NormalStatsTest {

  private static solarchvision_bim app;
  private static final float EPS = 0.001f;

  @BeforeAll
  static void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void oddCount_computesAllNineStatistics () {
    float[] r = app.SOLARCHVISION_NORMAL(new float[]{10, 20, 30, 40, 50});

    assertEquals(10f, r[app.STAT_N_Min], EPS);
    assertEquals(50f, r[app.STAT_N_Max], EPS);
    assertEquals(30f, r[app.STAT_N_Ave], EPS);
    assertEquals(30f, r[app.STAT_N_Middle], EPS);       // symmetric weights on a linear series == the average
    assertEquals(36.6667f, r[app.STAT_N_MidHigh], EPS); // weighted toward the higher-index (larger) values
    assertEquals(25f, r[app.STAT_N_MidLow], EPS);        // weighted toward the lower-index (smaller) values
    assertEquals(30f, r[app.STAT_N_M50], EPS);           // odd count: the exact middle element
    assertEquals(20f, r[app.STAT_N_M25], EPS);
    assertEquals(50f, r[app.STAT_N_M75], EPS);
  }

  @Test
  void evenCount_M50AveragesTheTwoMiddleElements () {
    float[] r = app.SOLARCHVISION_NORMAL(new float[]{10, 20, 30, 40});
    assertEquals(25f, r[app.STAT_N_M50], EPS); // average of the 2nd and 3rd sorted values (20, 30)
  }

  @Test
  void inputIsSortedRegardlessOfOriginalOrder () {
    float[] r = app.SOLARCHVISION_NORMAL(new float[]{30, 10, 20});
    assertEquals(10f, r[app.STAT_N_Min], EPS);
    assertEquals(30f, r[app.STAT_N_Max], EPS);
    assertEquals(20f, r[app.STAT_N_M50], EPS);
  }

  @Test
  void undefinedValuesAreExcludedFromEveryStatistic () {
    // FLOAT_undefined is a huge sentinel, so it sorts to the end and
    // falls outside the first NV (defined-count) elements the function
    // actually uses - undefined entries anywhere in the input should
    // give the exact same result as if they were never there at all.
    float[] withUndefined = app.SOLARCHVISION_NORMAL(
      new float[]{30, app.FLOAT_undefined, 10, app.FLOAT_undefined, 20});
    float[] withoutUndefined = app.SOLARCHVISION_NORMAL(new float[]{10, 20, 30});

    assertArrayEquals(withoutUndefined, withUndefined, EPS);
  }

  @Test
  void allUndefinedInputReturnsAllUndefinedOutput () {
    float[] r = app.SOLARCHVISION_NORMAL(new float[]{app.FLOAT_undefined, app.FLOAT_undefined});
    for (float v : r) {
      assertEquals(app.FLOAT_undefined, v, EPS);
    }
  }
}
