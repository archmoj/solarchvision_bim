import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class AveragedScenarioValuesTest {

  private solarchvision_bim app;
  private static final float EPS = 0.0001f;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= scenarioSampleWeight =================================
  // Rank-based (nearest-first) triangular weight: sampleCount, sampleCount-1,
  // ..., 1. sampleCount == 2 is exactly the requested 2:1 weighting.

  @Test
  void weight_isOneForTheOnlySample_whenSampleCountIsOne () {
    assertEquals(1f, app.scenarioSampleWeight(0, 1), EPS);
  }

  @Test
  void weight_isTwoToOne_whenSampleCountIsTwo () {
    assertEquals(2f, app.scenarioSampleWeight(0, 2), EPS); // closest
    assertEquals(1f, app.scenarioSampleWeight(1, 2), EPS); // 2nd-closest
  }

  @Test
  void weight_isThreeTwoOne_whenSampleCountIsThree () {
    assertEquals(3f, app.scenarioSampleWeight(0, 3), EPS);
    assertEquals(2f, app.scenarioSampleWeight(1, 3), EPS);
    assertEquals(1f, app.scenarioSampleWeight(2, 3), EPS);
  }

  // ================= averagedScenarioHourlyValues ==========================
  // Exercises the real getValue_currentDataSource()/filter() path, the same
  // way DataUtilsTest.java's setValueThenGetValue test sets up a data
  // source directly - climateTypicalYear is the simplest one (k is always
  // just 0, "current typical year").

  private int maxLayerId () {
    return Math.max(app.LAYER_cloudcover.id,
           Math.max(app.LAYER_dirnorrad.id,
           Math.max(app.LAYER_difhorrad.id,
           Math.max(app.LAYER_direffect.id, app.LAYER_difeffect.id))));
  }

  // Writes a fully-defined, filter-passing day (now_j, now_k) with given
  // direct/diffuse radiation+effect raw values (the *1000 scale
  // getValue_currentDataSource()'s raw Pa/Pb/Pc/Pd are read at, before each
  // call site's own 0.001 scaling) at hour 0, and a defined cloud-cover
  // value somewhere in that day (filter_DAILY, this test's default,
  // aggregates across all 24 hours, so any one hour is enough to make
  // filter() find data and - with the default skyScenarioSetting == 1,
  // "all scenarios" - return true unconditionally).
  private void setDay (int now_j, int now_k, float rawRdir, float rawRdif, float rawEdir, float rawEdif) {
    app.climateTypicalYearValues[0][now_j][app.LAYER_dirnorrad.id][now_k] = rawRdir;
    app.climateTypicalYearValues[0][now_j][app.LAYER_difhorrad.id][now_k] = rawRdif;
    app.climateTypicalYearValues[0][now_j][app.LAYER_direffect.id][now_k] = rawEdir;
    app.climateTypicalYearValues[0][now_j][app.LAYER_difeffect.id][now_k] = rawEdif;
    app.climateTypicalYearValues[0][now_j][app.LAYER_cloudcover.id][now_k] = 0; // any defined value
  }

  private void setUpTypicalYearSource (int numJ, int numK) {
    app.currentDataSource = app.dataID_climateTypicalYear;
    int numLayers = maxLayerId() + 1;
    app.climateTypicalYearValues = new float[24][numJ][numLayers][numK];
    for (float[][][] perJ : app.climateTypicalYearValues) {
      for (float[][] perLayer : perJ) {
        for (float[] perK : perLayer) {
          java.util.Arrays.fill(perK, app.FLOAT_undefined);
        }
      }
    }
  }

  @Test
  void hourlyValues_weightsTheClosestSampleTwiceTheSecond () {
    setUpTypicalYearSource(2, 2);
    setDay(0, 0, 1000, 0, 0, 0); // closest sample: R_dir raw 1000 -> 1.0 scaled
    setDay(1, 0, 4000, 0, 0, 0); // 2nd-closest: R_dir raw 4000 -> 4.0 scaled

    int[] sampleNowK = { 0, 0 };
    int[] sampleNowJ = { 0, 1 };

    float[] avg = app.averagedScenarioHourlyValues(0, sampleNowK, sampleNowJ);

    assertNotNull(avg);
    // (2*1.0 + 1*4.0) / 3 = 2.0 - a plain average would have given 2.5.
    assertEquals(2.0f, avg[0], EPS);
  }

  @Test
  void hourlyValues_reducesToTheQualifyingSampleAlone_whenTheClosestOneHasNoData () {
    setUpTypicalYearSource(2, 2);
    // now_j=0 is left entirely undefined (no setDay call) - the closest
    // sample has nothing usable for this hour.
    setDay(1, 0, 3000, 0, 0, 0); // 2nd-closest: R_dir raw 3000 -> 3.0 scaled

    int[] sampleNowK = { 0, 0 };
    int[] sampleNowJ = { 0, 1 };

    float[] avg = app.averagedScenarioHourlyValues(0, sampleNowK, sampleNowJ);

    assertNotNull(avg);
    // Only the 2nd sample qualifies - its own weight is normalized to
    // 100%, not stretched or diluted by the missing closest sample.
    assertEquals(3.0f, avg[0], EPS);
  }

  @Test
  void hourlyValues_isNull_whenNoSampleHasUsableData () {
    setUpTypicalYearSource(2, 2);
    // Neither day is ever written - everything stays FLOAT_undefined.

    int[] sampleNowK = { 0, 0 };
    int[] sampleNowJ = { 0, 1 };

    assertNull(app.averagedScenarioHourlyValues(0, sampleNowK, sampleNowJ));
  }

  @Test
  void hourlyValues_withOneSample_equalsThatSampleExactly () {
    setUpTypicalYearSource(1, 1);
    setDay(0, 0, 5000, 2000, 1000, 500);

    int[] sampleNowK = { 0 };
    int[] sampleNowJ = { 0 };

    float[] avg = app.averagedScenarioHourlyValues(0, sampleNowK, sampleNowJ);

    assertNotNull(avg);
    assertEquals(5.0f, avg[0], EPS);
    assertEquals(2.0f, avg[1], EPS);
    assertEquals(1.0f, avg[2], EPS);
    assertEquals(0.5f, avg[3], EPS);
  }

  // ================= averagedScenarioLayerValue ============================
  // No filter check at all (matches Sun3D.pde's first call site) - only
  // is_undefined() gates a sample.

  @Test
  void layerValue_weightsTheClosestSampleTwiceTheSecond () {
    setUpTypicalYearSource(2, 2);
    app.climateTypicalYearValues[0][0][app.LAYER_dirnorrad.id][0] = 1000;
    app.climateTypicalYearValues[0][1][app.LAYER_dirnorrad.id][0] = 4000;

    int[] sampleNowK = { 0, 0 };
    int[] sampleNowJ = { 0, 1 };

    float avg = app.averagedScenarioLayerValue(0, sampleNowK, sampleNowJ, app.LAYER_dirnorrad.id);

    // (2*1000 + 1*4000) / 3 = 2000 - a plain average would have given 2500.
    assertEquals(2000f, avg, EPS);
  }

  @Test
  void layerValue_isFLOAT_undefined_whenNoSampleHasAValue () {
    setUpTypicalYearSource(1, 1);
    // Left undefined.

    int[] sampleNowK = { 0 };
    int[] sampleNowJ = { 0 };

    assertEquals(app.FLOAT_undefined, app.averagedScenarioLayerValue(0, sampleNowK, sampleNowJ, app.LAYER_dirnorrad.id));
  }
}
