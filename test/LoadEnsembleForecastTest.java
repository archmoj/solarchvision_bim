import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// load_ensembleForecast() (loadEnsembleForecast.pde) was untested - 165
// instructions - and parses a real NAEFS (North American Ensemble
// Forecast System) file: projects/test/data/NAEFS/2026111300_GEPS-NAEFS-RAW_
// TORONTO_PEARSON_INTL_ON_CA_TMP-SFC_000-384.xml, matching STATION's own
// bare-construction ensembleForecastFilename ("CYYZ-MAN" - actually the
// file naming here follows the station's city/province/country name,
// not its airport code; TORONTO_PEARSON_INTL_ON_CA is STATION's own
// ensembleObservationFilename, reused for NAEFS too per this project's
// own real downloaded fixture).
//
// Unlike SWOB's single current observation, a NAEFS file holds many
// <forecast> blocks (one per forecast hour, spanning 000-384), each
// with a real <model id="N">value</model> per ensemble member - the
// "k" (id - 1) dimension load_ensembleForecast() writes into.
// "TMP-SFC" is surface air temperature (°C) - the file's own <forecast_
// element> header confirms this - mapped to LAYER_drybulb here, the
// same way a real caller (update_ensembleForecast(), not used directly
// by this test - see this file's own header reasoning on
// LoadEnsembleObservationTest.java's analogous choice) would pick the
// layer per filename.
class LoadEnsembleForecastTest {

  private solarchvision_bim app;
  private static final float EPS = 0.01f;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.sketchPath(); // see LoadClimateTypicalYearTest.java's own comment on why

    // The real production allocation (updateEnsembleForecast.pde) -
    // ensembleForecastStart/End's own bare-construction defaults (1, 43)
    // give a 43-member-wide k dimension, comfortably covering this
    // file's own 24 real ensemble members.
    int numLayers = app.allLayers.length;
    int numMembers = 1 + app.ensembleForecastEnd - app.ensembleForecastStart;
    app.ensembleForecastValues = new float[24][365][numLayers][numMembers];
    for (float[][][] perJ : app.ensembleForecastValues) {
      for (float[][] perLayer : perJ) {
        for (float[] perK : perLayer) {
          java.util.Arrays.fill(perK, app.FLOAT_undefined);
        }
      }
    }
  }

  private String realNaefsTmpPath () {
    return System.getProperty("user.dir") + "/projects/test/data/NAEFS/2026111300_GEPS-NAEFS-RAW_TORONTO_PEARSON_INTL_ON_CA_TMP-SFC_000-384.xml";
  }

  @Test
  void loadsTheRealNaefsFile_withoutThrowing () {
    assertDoesNotThrow(() -> app.load_ensembleForecast(realNaefsTmpPath(), app.LAYER_drybulb.id));
  }

  @Test
  void parsesTheFirstForecastHour_everyRealEnsembleMember () {
    app.load_ensembleForecast(realNaefsTmpPath(), app.LAYER_drybulb.id);

    // The file's own first <forecast> block: forecast_hour="6",
    // valid_time="2026111306" -> THE_YEAR=2026,MONTH=11,DAY=13,HOUR=6.
    // STATION's own real timezoneLongitude (-75): now_i = 6 -
    // int(-(-75)/15) = 6 - 5 = 1.
    int i = 1;
    int j = app.TIME.convert2Date(11, 13);

    // The file's own first 6 real <model id="N">value</model> entries
    // (id - 1 = k).
    float[] expected = {-0.6f, 0.4f, 0.2f, -0.2f, -0.6f, 0.2f};
    for (int k = 0; k < expected.length; k++) {
      assertEquals(expected[k], app.ensembleForecastValues[i][j][app.LAYER_drybulb.id][k], EPS, "model id " + (k + 1));
    }
  }

  @Test
  void aMemberIdPastTheConfiguredRange_isSkippedWithoutThrowing () {
    // ensembleForecastEnd's own bare-construction default is 43, so no
    // id in this real file (up to the low dozens) would actually
    // exceed it - this instead directly confirms the "k <
    // (1 + ensembleForecastEnd - ensembleForecastStart)" guard itself
    // doesn't throw when deliberately made impossible to satisfy,
    // rather than depending on the fixture having an out-of-range id by
    // chance.
    app.ensembleForecastEnd = app.ensembleForecastStart; // 1-member-wide range - every real id here is now out of range

    assertDoesNotThrow(() -> app.load_ensembleForecast(realNaefsTmpPath(), app.LAYER_drybulb.id));
  }
}
