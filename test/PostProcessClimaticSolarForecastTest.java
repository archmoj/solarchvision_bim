import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// postProcess_climaticSolarForecast() - previously untested - is a two-
// stage radiation estimate for each ensembleForecast hour with a defined
// cloud cover: first a baseline via funcs.SunPositionRadiation() (same
// call PostProcessSolarsUsingCloudTest.java's own target makes, already
// covered there), then an "analog day" refinement that looks for
// climateEngineering days within +/-5 days of the same date whose own
// cloud cover and pressure are both close enough (CC_epsilon/AP_epsilon)
// to the forecast's - a distance-weighted average of THEIR historical
// radiation replaces the baseline wherever at least one such day is
// found; the baseline is left standing otherwise.
//
// Every range this function reads directly from globals (climateEngineering
// Start/End, ensembleForecastStart/End/MaxDays, TIME.beginDay) is narrowed
// to its own smallest possible single-slot case below (num_count == 1,
// one k, one day), the same reasoning as PostProcessFillGapsTest.java's
// own minimal fixtures, so each test below only ever has to reason about
// one hour, one day, one ensemble member and one climateEngineering year
// at a time - every other candidate day in the +/-5 window is left
// undefined and skipped by the function's own is_undefined() guards.
// Every expected value confirmed by hand against the real compiled app.
class PostProcessClimaticSolarForecastTest {

  private solarchvision_bim app;
  private int numLayers;
  private static final int HOUR = 12;
  private static final int DAY = 0; // == TIME.beginDay below, so j == 0

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    numLayers = app.allLayers.length;

    app.climateEngineeringStart = 0;
    app.climateEngineeringEnd = 0; // num_count == 1
    app.ensembleForecastStart = 0;
    app.ensembleForecastEnd = 0; // k loop: only k == 0
    app.ensembleForecastMaxDays = 1; // j_for loop: only j_for == 0
    app.TIME.beginDay = 0; // so j == DAY (0)

    app.ensembleForecastValues = freshArray();
    app.climateEngineeringValues = freshArray();
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

  private float[] baselineSunR (float cloudCover) {
    float DATE_ANGLE = (360 * ((286 + DAY) % 365) / 365.0f);
    return app.funcs.SunPositionRadiation(DATE_ANGLE, (float) HOUR, cloudCover);
  }

  @Test
  void withNoMatchingClimateEngineeringDay_fallsBackToTheSunPositionRadiationBaseline () {
    float cloud = 5f;
    app.ensembleForecastValues[HOUR][DAY][app.LAYER_cloudcover.id][0] = cloud;
    // climateEngineeringValues left entirely undefined - no candidate
    // day can ever match.

    app.postProcess_climaticSolarForecast();

    float[] expected = baselineSunR(cloud);
    assertEquals(expected[4], app.ensembleForecastValues[HOUR][DAY][app.LAYER_dirnorrad.id][0], 0.0001f);
    assertEquals(expected[5], app.ensembleForecastValues[HOUR][DAY][app.LAYER_difhorrad.id][0], 0.0001f);
    assertEquals(expected[4] * expected[3] + expected[5], app.ensembleForecastValues[HOUR][DAY][app.LAYER_glohorrad.id][0], 0.0001f);
  }

  @Test
  void withOneExactlyMatchingClimateEngineeringDay_usesItsHistoricalRadiationInstead () {
    float CC = 5f, AP = 1000f;
    app.ensembleForecastValues[HOUR][DAY][app.LAYER_cloudcover.id][0] = CC;
    app.ensembleForecastValues[HOUR][DAY][app.LAYER_pressure.id][0] = AP;

    // The one matching candidate: same hour, same day (one of the 11
    // days in the +/-5 window - the center one, offset 0), q == 0 (the
    // only climateEngineering "year" slot this fixture has) - exact
    // cloud cover and pressure, so both distances are 0, well inside
    // either epsilon.
    app.climateEngineeringValues[HOUR][DAY][app.LAYER_cloudcover.id][0] = CC;
    app.climateEngineeringValues[HOUR][DAY][app.LAYER_pressure.id][0] = AP;
    app.climateEngineeringValues[HOUR][DAY][app.LAYER_dirnorrad.id][0] = 300f;
    app.climateEngineeringValues[HOUR][DAY][app.LAYER_difhorrad.id][0] = 50f;
    app.climateEngineeringValues[HOUR][DAY][app.LAYER_glohorrad.id][0] = 350f;

    app.postProcess_climaticSolarForecast();

    // A single matching candidate's own weighted average is just its
    // own value, regardless of the exact weight - confirmed exactly,
    // not approximately, against the real compiled app.
    assertEquals(300f, app.ensembleForecastValues[HOUR][DAY][app.LAYER_dirnorrad.id][0], 0.0001f);
    assertEquals(50f, app.ensembleForecastValues[HOUR][DAY][app.LAYER_difhorrad.id][0], 0.0001f);
    assertEquals(350f, app.ensembleForecastValues[HOUR][DAY][app.LAYER_glohorrad.id][0], 0.0001f);
  }

  @Test
  void whenForecastCloudCoverItselfIsUndefined_skipsTheWholeHourEntirely () {
    // ensembleForecastValues[HOUR][DAY][cloudcover] left undefined (the
    // fixture's own default) - none of dirnorrad/difhorrad/glohorrad are
    // ever written, successful match or not.
    app.postProcess_climaticSolarForecast();

    assertTrue(app.is_undefined(app.ensembleForecastValues[HOUR][DAY][app.LAYER_dirnorrad.id][0]));
  }

  @Test
  void aCandidateDay_exactlyAtTheCloudCoverEpsilonBoundary_doesNotCount_asOneJustInsideItDoes () {
    // CC_epsilon is 1.0, and the function's own check is a strict "<",
    // not "<=" - confirmed directly: a candidate exactly 1.0 away is
    // excluded (falls back to the baseline, same as the no-match test
    // above), while one at 0.99 is accepted.
    float CC = 5f, AP = 1000f;
    app.ensembleForecastValues[HOUR][DAY][app.LAYER_cloudcover.id][0] = CC;
    app.ensembleForecastValues[HOUR][DAY][app.LAYER_pressure.id][0] = AP;
    app.climateEngineeringValues[HOUR][DAY][app.LAYER_cloudcover.id][0] = CC + 1.0f; // CC_dist == CC_epsilon exactly
    app.climateEngineeringValues[HOUR][DAY][app.LAYER_pressure.id][0] = AP; // AP_dist == 0
    app.climateEngineeringValues[HOUR][DAY][app.LAYER_dirnorrad.id][0] = 300f;

    app.postProcess_climaticSolarForecast();

    float[] expected = baselineSunR(CC);
    assertEquals(expected[4], app.ensembleForecastValues[HOUR][DAY][app.LAYER_dirnorrad.id][0], 0.0001f, "exactly at the epsilon boundary - excluded, same as no match at all");

    // Same fixture, candidate now just inside the boundary instead.
    app.climateEngineeringValues[HOUR][DAY][app.LAYER_cloudcover.id][0] = CC + 0.99f;

    app.postProcess_climaticSolarForecast();

    assertEquals(300f, app.ensembleForecastValues[HOUR][DAY][app.LAYER_dirnorrad.id][0], 0.0001f, "just inside the boundary - the one candidate now counts");
  }
}
