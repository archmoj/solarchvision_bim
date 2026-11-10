import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// postProcess_solarEffects() - previously untested - derives
// LAYER_direffect/LAYER_difeffect from LAYER_drybulb (temperature) and
// LAYER_dirnorrad/LAYER_difhorrad (direct/diffuse radiation) via a
// simple (18 - T) * R formula, only where all three inputs are defined.
// Pure array math, no graphics - same shape and dataSource-restoring
// convention as postProcess_fillGaps() (see PostProcessFillGapsTest.java's
// own header comment).
class PostProcessSolarEffectsTest {

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
  void computesBothEffectLayers_whenAllThreeInputsAreDefined () {
    app.climateTypicalYearValues = freshTypicalYearArray();
    int hour = 10, day = 0;
    app.climateTypicalYearValues[hour][day][app.LAYER_drybulb.id][0] = 8f; // T
    app.climateTypicalYearValues[hour][day][app.LAYER_dirnorrad.id][0] = 100f; // R_dir
    app.climateTypicalYearValues[hour][day][app.LAYER_difhorrad.id][0] = 50f; // R_dif

    app.postProcess_solarEffects(app.dataID_climateTypicalYear);

    // (18 - 8) * 100 = 1000, (18 - 8) * 50 = 500
    assertEquals(1000f, app.climateTypicalYearValues[hour][day][app.LAYER_direffect.id][0], 0.0001f);
    assertEquals(500f, app.climateTypicalYearValues[hour][day][app.LAYER_difeffect.id][0], 0.0001f);
  }

  @Test
  void aNegativeResult_whenTemperatureExceeds18Degrees_isKeptAsIs () {
    // Nothing in the formula clamps this to zero - a hot hour produces
    // a genuinely negative "effect" value, not a floor at 0.
    app.climateTypicalYearValues = freshTypicalYearArray();
    int hour = 14, day = 0;
    app.climateTypicalYearValues[hour][day][app.LAYER_drybulb.id][0] = 30f; // T > 18
    app.climateTypicalYearValues[hour][day][app.LAYER_dirnorrad.id][0] = 100f;
    app.climateTypicalYearValues[hour][day][app.LAYER_difhorrad.id][0] = 50f;

    app.postProcess_solarEffects(app.dataID_climateTypicalYear);

    assertEquals(-1200f, app.climateTypicalYearValues[hour][day][app.LAYER_direffect.id][0], 0.0001f); // (18-30)*100
    assertEquals(-600f, app.climateTypicalYearValues[hour][day][app.LAYER_difeffect.id][0], 0.0001f); // (18-30)*50
  }

  @Test
  void leavesBothEffectLayersUntouched_whenAnyOneOfTheThreeInputsIsUndefined () {
    app.climateTypicalYearValues = freshTypicalYearArray();
    int hour = 5, day = 0;
    app.climateTypicalYearValues[hour][day][app.LAYER_drybulb.id][0] = 8f;
    app.climateTypicalYearValues[hour][day][app.LAYER_dirnorrad.id][0] = 100f;
    // LAYER_difhorrad left undefined

    app.postProcess_solarEffects(app.dataID_climateTypicalYear);

    assertTrue(app.is_undefined(app.climateTypicalYearValues[hour][day][app.LAYER_direffect.id][0]));
    assertTrue(app.is_undefined(app.climateTypicalYearValues[hour][day][app.LAYER_difeffect.id][0]));
  }

  @Test
  void leavesCurrentDataSource_exactlyAsItWasBeforeTheCall () {
    app.climateTypicalYearValues = freshTypicalYearArray();
    app.currentDataSource = app.dataID_climateArchive;

    app.postProcess_solarEffects(app.dataID_climateTypicalYear);

    assertEquals(app.dataID_climateArchive, app.currentDataSource);
  }
}
