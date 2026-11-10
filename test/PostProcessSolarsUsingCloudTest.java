import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// postProcess_solarsUsingCloud() - previously untested - derives
// LAYER_dirnorrad/LAYER_difhorrad/LAYER_glohorrad from LAYER_cloudcover
// via funcs.SunPositionRadiation() (already covered directly in
// FunctionsTest.java), only where cloud cover is defined. This only
// confirms the WIRING - the date/hour-angle math handed to that
// function, and what gets written back from its own result array - not
// the astronomical calculation itself, same scoping choice as
// ScriptCommandFileIOTest.java's own EXPORT.* tests make for their own
// already-tested targets.
class PostProcessSolarsUsingCloudTest {

  private solarchvision_bim app;
  private int numLayers;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    numLayers = app.allLayers.length;
  }

  // Same minimal fixture reasoning as PostProcessFillGapsTest.java's own
  // freshTypicalYearArray(): climateTypicalYearStart/End default to 1/1,
  // so only k == 0 is ever touched here.
  private float[][][][] freshTypicalYearArray () {
    float[][][][] values = new float[24][365][numLayers][1];
    for (int h = 0; h < 24; h++) {
      for (int l = 0; l < numLayers; l++) {
        values[h][0][l][0] = app.FLOAT_undefined;
      }
    }
    return values;
  }

  @Test
  void aDefinedCloudCover_derivesAllThreeRadiationLayers_fromSunPositionRadiation () {
    app.climateTypicalYearValues = freshTypicalYearArray();
    int hour = 12, day = 0;
    float cloud = 5f;
    app.climateTypicalYearValues[hour][day][app.LAYER_cloudcover.id][0] = cloud;

    // The same already-tested function this one calls internally, given
    // the exact date/hour-angle arguments postProcessSolarsUsingCloud.
    // pde's own source computes for day 0, hour 12 - ground truth to
    // compare the wiring against, not a re-test of the astronomy itself.
    float DATE_ANGLE = (360 * ((286 + day) % 365) / 365.0f);
    float[] expected = app.funcs.SunPositionRadiation(DATE_ANGLE, (float) hour, cloud);

    app.postProcess_solarsUsingCloud(app.dataID_climateTypicalYear);

    assertEquals(expected[4], app.climateTypicalYearValues[hour][day][app.LAYER_dirnorrad.id][0], 0.0001f);
    assertEquals(expected[5], app.climateTypicalYearValues[hour][day][app.LAYER_difhorrad.id][0], 0.0001f);
    assertEquals(expected[4] * expected[3] + expected[5], app.climateTypicalYearValues[hour][day][app.LAYER_glohorrad.id][0], 0.0001f);
  }

  @Test
  void leavesAllThreeRadiationLayersUntouched_whenCloudCoverIsUndefined () {
    app.climateTypicalYearValues = freshTypicalYearArray();
    // LAYER_cloudcover left undefined everywhere

    app.postProcess_solarsUsingCloud(app.dataID_climateTypicalYear);

    int hour = 12, day = 0;
    assertTrue(app.is_undefined(app.climateTypicalYearValues[hour][day][app.LAYER_dirnorrad.id][0]));
    assertTrue(app.is_undefined(app.climateTypicalYearValues[hour][day][app.LAYER_difhorrad.id][0]));
    assertTrue(app.is_undefined(app.climateTypicalYearValues[hour][day][app.LAYER_glohorrad.id][0]));
  }

  @Test
  void leavesCurrentDataSource_exactlyAsItWasBeforeTheCall () {
    app.climateTypicalYearValues = freshTypicalYearArray();
    app.currentDataSource = app.dataID_climateArchive;

    app.postProcess_solarsUsingCloud(app.dataID_climateTypicalYear);

    assertEquals(app.dataID_climateArchive, app.currentDataSource);
  }
}
