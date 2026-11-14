import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// load_ensembleObservation() (loadEnsembleObservation.pde) was untested -
// 329 instructions - and parses a real SWOB (Surface Weather
// Observation) file: projects/test/data/SWOB/2026-11-10-1500-CYYZ-MAN-swob.xml,
// Toronto Pearson's real station code (CYYZ), matching STATION's own
// bare-construction ensembleObservationFilename ("TORONTO_PEARSON_INTL_ON_CA")
// and the timezoneLongitude (-75) this parser's own time-zone adjustment
// needs.
//
// This specific fixture file's own real element list was checked
// directly (not assumed) against every field name load_ensembleObservation()
// looks for: stn_pres/air_temp/rel_hum/tot_cld_amt are present with
// real values; avg_wnd_dir_10m_mt50-60/avg_wnd_spd_10m_mt50-60/
// pcpn_amt_pst6hrs/avg_globl_solr_radn_pst1hr/tot_globl_solr_radn_pst1hr
// are either absent or MSNG (missing) across every file in this
// fixture, so those layers are deliberately not asserted on here -
// there's no real data in this batch to verify them against, only
// MSNG's own FLOAT_undefined substitution, which is less informative
// than the 4 fields that do have real values.
class LoadEnsembleObservationTest {

  private solarchvision_bim app;
  private static final float EPS = 0.01f;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.sketchPath(); // see LoadClimateTypicalYearTest.java's own comment on why

    // The real production allocation (updateEnsembleObservation.pde),
    // done directly here instead of through that whole function (which
    // also needs a real nearest-station search apparatus this test
    // doesn't - see this file's own header comment).
    int numLayers = app.allLayers.length;
    app.ensembleObservationValues = new float[24][365][numLayers][1];
    for (float[][][] perJ : app.ensembleObservationValues) {
      for (float[][] perLayer : perJ) {
        for (float[] perK : perLayer) {
          java.util.Arrays.fill(perK, app.FLOAT_undefined);
        }
      }
    }
  }

  private String realSwobPath () {
    return System.getProperty("user.dir") + "/projects/test/data/SWOB/2026-11-10-1500-CYYZ-MAN-swob.xml";
  }

  @Test
  void loadsTheRealSwobFile_withoutThrowing () {
    assertDoesNotThrow(() -> app.load_ensembleObservation(realSwobPath(), 0));
  }

  @Test
  void parsesTheRealObservation_2026_11_10_15h00UTC () {
    app.load_ensembleObservation(realSwobPath(), 0);

    // gml:timePosition is 2026-11-10T15:00:00.000Z - STATION's own real
    // timezoneLongitude (-75) shifts this by -int(-(-75)/15) = -5 hours
    // local: now_i = 15 - 5 = 10.
    int i = 10;
    int j = app.TIME.convert2Date(11, 10);
    int k = 0;

    // Real element values straight from this fixture file:
    // stn_pres=989.7 hPa, air_temp=12.2 °C, rel_hum=68 %, tot_cld_amt=10 %
    // (tot_cld_amt's own *0.1 conversion -> 1.0).
    assertEquals(989.7f, app.ensembleObservationValues[i][j][app.LAYER_pressure.id][k], EPS);
    assertEquals(12.2f, app.ensembleObservationValues[i][j][app.LAYER_drybulb.id][k], EPS);
    assertEquals(68f, app.ensembleObservationValues[i][j][app.LAYER_relhum.id][k], EPS);
    assertEquals(1.0f, app.ensembleObservationValues[i][j][app.LAYER_cloudcover.id][k], EPS);
  }

  @Test
  void aFieldMissingFromThisFile_isLeftUndefined () {
    app.load_ensembleObservation(realSwobPath(), 0);

    int i = 10;
    int j = app.TIME.convert2Date(11, 10);
    int k = 0;

    // avg_wnd_dir_10m_mt50-60 doesn't appear in this file's own element
    // list at all (confirmed directly) - load_ensembleObservation()'s
    // own "if (_a1.equals(...))" check for it simply never matches, so
    // this layer is never written and stays at this test's own
    // FLOAT_undefined seed.
    assertFalse(app.is_defined(app.ensembleObservationValues[i][j][app.LAYER_winddir.id][k]));
  }
}
