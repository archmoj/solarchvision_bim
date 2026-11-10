import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// postProcess_developDATA() - previously untested - derives a single,
// user-selected LAYER_developed layer (developLayerOption) from other
// already-present layers, for every hour/day/k-slot of a given data
// source. Two of its own branches (DEV_RadiationOnTracker and every
// DEV_RadiationOn{South,East,...,Surface} case) are thin wrappers around
// SolarAtSurface() (already covered directly in SolarAtSurfaceTest.java)
// and funcs.SunPosition() (already covered in FunctionsTest.java/
// Sun3DTest.java/others) - same scoping choice as
// PostProcessSolarsUsingCloudTest.java's own target makes for
// funcs.SunPositionRadiation(): these tests confirm the WIRING (which
// Alpha/Beta each direction picks, that the right inputs reach those
// functions, that LAYER_developed's own label metadata gets set), not
// the underlying solar geometry a second time.
//
// Every range this function reads directly from globals (STUDY.startDay/
// endDay/dayIncrement/daysMergedCount, TIME.beginDay) is narrowed to its
// own smallest single-slot case below, the same reasoning
// PostProcessClimaticSolarForecastTest.java's own header comment
// explains for that file - every (now_i, now_j, now_k) combination this
// function could otherwise touch collapses down to exactly one hour, one
// day. Confirmed directly against the real compiled app that this
// fixture really does land on hour 12, day 0 - not assumed from reading
// the date-arithmetic alone.
class PostProcessDevelopDataTest {

  private solarchvision_bim app;
  private int numLayers;
  private static final int HOUR = 12;
  private static final int DAY = 0;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    numLayers = app.allLayers.length;

    app.STUDY.startDay = 0;
    app.STUDY.endDay = 0;
    app.STUDY.dayIncrement = 1;
    app.STUDY.daysMergedCount = 1;
    app.TIME.beginDay = 0;

    app.climateTypicalYearValues = freshArray();
  }

  private float[][][][] freshArray () {
    float[][][][] values = new float[24][365][numLayers][1];
    for (int i = 0; i < 24; i++) {
      for (int j = 0; j < 365; j++) {
        for (int l = 0; l < numLayers; l++) {
          values[i][j][l][0] = app.FLOAT_undefined;
        }
      }
    }
    return values;
  }

  // ================= DEV_WindPower ========================================

  @Test
  void devWindPower_computesTheStandardWindPowerFormula_fromWindSpeed () {
    float windSpeedKmh = 10f;
    app.climateTypicalYearValues[HOUR][DAY][app.LAYER_windspd.id][0] = windSpeedKmh;
    app.developLayerOption = app.DEV_WindPower;

    app.postProcess_developDATA(app.dataID_climateTypicalYear);

    // 0.5 * air density (1.23) * swept area (1) * (speed in m/s)^3 -
    // speed converted from km/h to m/s by dividing by 3.6.
    double expected = 0.5 * 1.23 * 1 * Math.pow(windSpeedKmh / 3.6, 3);
    assertEquals(expected, app.climateTypicalYearValues[HOUR][DAY][app.LAYER_developed.id][0], 0.001);

    assertEquals("Wind power", app.LAYER_developed.descriptions[app.Language_EN]);
    assertEquals(0.05f, app.LAYER_developed.verticalUnitScale, 0.0001f);
  }

  @Test
  void devWindPower_withNoWindSpeedDefined_leavesTheHourUndefined () {
    // The function's own leading, unconditional setValue_currentDataSource(
    // ..., LAYER_developed.id, FLOAT_undefined) for every (i, j, k) means
    // an hour with no usable input data is reset, not left at some stale
    // previous value.
    app.climateTypicalYearValues[HOUR][DAY][app.LAYER_developed.id][0] = 999f; // stale leftover value
    app.developLayerOption = app.DEV_WindPower;

    app.postProcess_developDATA(app.dataID_climateTypicalYear);

    assertTrue(app.is_undefined(app.climateTypicalYearValues[HOUR][DAY][app.LAYER_developed.id][0]));
  }

  // ================= DEV_RadiationOn{South,East,...,Surface} =============
  // Every one of these picks a different, fixed (Alpha, Beta) pair - or,
  // for DEV_RadiationOnSurface, the user's own developLayerAngleInclination/
  // Orientation - then calls SolarAtSurface() with it.

  private float expectedSolarAtSurface (float R_dir, float R_dif, float alpha, float beta) {
    float DATE_ANGLE = (360 * ((286 + DAY) % 365) / 365.0f);
    float[] SunR = app.funcs.SunPosition(app.STATION.getLatitude(), DATE_ANGLE, (float) HOUR);
    return app.SolarAtSurface(SunR[1], SunR[2], SunR[3], R_dir, R_dif, alpha, beta, app.globalAlbedo);
  }

  @Test
  void devRadiationOnSouth_usesAlphaZeroBetaZero () {
    float R_dir = 200f, R_dif = 80f;
    app.climateTypicalYearValues[HOUR][DAY][app.LAYER_dirnorrad.id][0] = R_dir;
    app.climateTypicalYearValues[HOUR][DAY][app.LAYER_difhorrad.id][0] = R_dif;
    app.developLayerOption = app.DEV_RadiationOnSouth;

    app.postProcess_developDATA(app.dataID_climateTypicalYear);

    assertEquals(expectedSolarAtSurface(R_dir, R_dif, 0, 0), app.climateTypicalYearValues[HOUR][DAY][app.LAYER_developed.id][0], 0.001f);
  }

  @Test
  void devRadiationOnEast_usesAlphaZeroBeta90_differentFromSouth () {
    float R_dir = 200f, R_dif = 80f;
    app.climateTypicalYearValues[HOUR][DAY][app.LAYER_dirnorrad.id][0] = R_dir;
    app.climateTypicalYearValues[HOUR][DAY][app.LAYER_difhorrad.id][0] = R_dif;
    app.developLayerOption = app.DEV_RadiationOnEast;

    app.postProcess_developDATA(app.dataID_climateTypicalYear);

    float actual = app.climateTypicalYearValues[HOUR][DAY][app.LAYER_developed.id][0];
    assertEquals(expectedSolarAtSurface(R_dir, R_dif, 0, 90), actual, 0.001f);
    assertNotEquals(expectedSolarAtSurface(R_dir, R_dif, 0, 0), actual, 0.001f, "sanity check: East and South really do differ for this sun position");
  }

  @Test
  void devRadiationOnSurface_usesTheUsersOwnInclinationAndOrientationAngles_insteadOfAFixedDirection () {
    float R_dir = 200f, R_dif = 80f;
    app.climateTypicalYearValues[HOUR][DAY][app.LAYER_dirnorrad.id][0] = R_dir;
    app.climateTypicalYearValues[HOUR][DAY][app.LAYER_difhorrad.id][0] = R_dif;
    app.developLayerAngleInclination = 30f;
    app.developLayerAngleOrientation = 60f;
    app.developLayerOption = app.DEV_RadiationOnSurface;

    app.postProcess_developDATA(app.dataID_climateTypicalYear);

    assertEquals(expectedSolarAtSurface(R_dir, R_dif, 30f, 60f), app.climateTypicalYearValues[HOUR][DAY][app.LAYER_developed.id][0], 0.001f);
  }

  @Test
  void devRadiationOnSouth_withEitherRadiationInputUndefined_leavesTheHourUndefined () {
    app.climateTypicalYearValues[HOUR][DAY][app.LAYER_dirnorrad.id][0] = 200f;
    // LAYER_difhorrad left undefined
    app.developLayerOption = app.DEV_RadiationOnSouth;

    app.postProcess_developDATA(app.dataID_climateTypicalYear);

    assertTrue(app.is_undefined(app.climateTypicalYearValues[HOUR][DAY][app.LAYER_developed.id][0]));
  }

  // ================= the precipitation ("RAIN") computation ==============

  @Test
  void theComputedRainValue_hasNoEffectOnLayerDeveloped_regardlessOfDevelopLayerOption () {
    // A real finding, not a hypothetical: postProcessDevelopData.pde's
    // own RAIN local variable is computed (the difference between two
    // precipitation readings 12 hours apart, sign-flipped when T <= 0 -
    // two developer names are even left in comments on that sign flip,
    // "Lewis"/"Mojtaba") but never written anywhere, through
    // setValue_currentDataSource() or otherwise, for the rest of this
    // function. Confirmed directly against the real compiled app:
    // changing precipitation data wildly, on top of an otherwise
    // identical fixture, produces the exact same LAYER_developed output.
    float R_dir = 200f, R_dif = 80f;
    app.climateTypicalYearValues[HOUR][DAY][app.LAYER_dirnorrad.id][0] = R_dir;
    app.climateTypicalYearValues[HOUR][DAY][app.LAYER_difhorrad.id][0] = R_dif;
    app.developLayerOption = app.DEV_RadiationOnSouth;

    app.postProcess_developDATA(app.dataID_climateTypicalYear);
    float withoutPrecipitation = app.climateTypicalYearValues[HOUR][DAY][app.LAYER_developed.id][0];

    app.climateTypicalYearValues[HOUR][DAY][app.LAYER_developed.id][0] = app.FLOAT_undefined; // undo the leading reset for a fair rerun
    app.climateTypicalYearValues[HOUR][DAY][app.LAYER_precipitation.id][0] = 999f;
    int nextI = HOUR + 12, nextJ = DAY; // the function's own "12 hours later" pairing
    if (nextI >= 24) { nextI -= 24; nextJ = (nextJ + 1) % 365; }
    app.climateTypicalYearValues[nextI][nextJ][app.LAYER_precipitation.id][0] = -999f;

    app.postProcess_developDATA(app.dataID_climateTypicalYear);
    float withPrecipitation = app.climateTypicalYearValues[HOUR][DAY][app.LAYER_developed.id][0];

    assertEquals(withoutPrecipitation, withPrecipitation, 0.0001f);
  }

  // ================= restoration of saved-and-swapped state ===============

  @Test
  void restoresCurrentDataSourceAndStudysDayFields_afterTheCall_andClearsDevelopDataUpdate () {
    app.currentDataSource = app.dataID_climateArchive;
    app.STUDY.dayIncrement = 7f;
    app.STUDY.daysMergedCount = 3;
    app.developDataUpdate = true;

    app.postProcess_developDATA(app.dataID_climateTypicalYear);

    assertEquals(app.dataID_climateArchive, app.currentDataSource);
    assertEquals(7f, app.STUDY.dayIncrement, 0.0001f);
    assertEquals(3, app.STUDY.daysMergedCount);
    assertFalse(app.developDataUpdate);
  }
}
