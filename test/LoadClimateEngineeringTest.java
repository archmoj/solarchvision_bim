import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// load_climateEngineering() (loadClimateEngineering.pde) was at 0%
// coverage (738 instructions) - one of the "remote/network data
// loading" functions flagged earlier, but it turns out not to need a
// network at all: it parses a real CWEEDS (.WY3) file straight off
// disk, and the repo bundles real ones (input/climate/CWEEDS/). This
// loads the real Toronto station file directly - the same real-local-
// file strategy LoadClimateTypicalYearTest.java already established
// for the EPW format, just for CWEEDS's own fixed-width column layout
// (substring(start,end), not comma-delimited) and its 20 real years
// (1998-2017) instead of one typical one.
//
// Expected values below are read directly off the file's own first
// real data line and its documented column layout - not invented -
// including its unit conversions (pressure/drybulb *0.1, radiation
// values /3.6, windspeed *0.1*3.6, ceiling height *10) and its sentinel-
// value handling (ceiling height 7777 is its own distinct "unlimited"
// sentinel, mapped straight to 1000 - unlike a value that's merely
// ">= 1000", which also clamps to 1000 but through the *10 scaling
// path instead; 9999/99999/999/99 are each that field's own distinct
// "no data" sentinel).
//
// The file is large (~175,000 lines, 20 real years) - this test parses
// all of it, so it's noticeably slower than LoadClimateTypicalYearTest.java's
// single-year equivalent, but still well within normal test-suite
// bounds (no network, no external process).
class LoadClimateEngineeringTest {

  private solarchvision_bim app;
  private static final float EPS = 0.01f;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.sketchPath(); // see LoadClimateTypicalYearTest.java's own comment on why

    // The real production allocation (update_climateEngineering.pde),
    // done directly here instead of through that whole function -
    // climateEngineeringStart/End's own bare-construction defaults
    // (1970/2017) give a 48-year-wide k dimension, comfortably covering
    // this file's own real 1998-2017 range.
    int numLayers = app.allLayers.length;
    int numYears = 1 + app.climateEngineeringEnd - app.climateEngineeringStart;
    app.climateEngineeringValues = new float[24][365][numLayers][numYears];
    app.climateEngineeringFlags = new boolean[24][365][numLayers][numYears];
    for (float[][][] perJ : app.climateEngineeringValues) {
      for (float[][] perLayer : perJ) {
        for (float[] perK : perLayer) {
          java.util.Arrays.fill(perK, app.FLOAT_undefined);
        }
      }
    }
  }

  private String realCweedsPath () {
    return System.getProperty("user.dir") + "/input/climate/CWEEDS/CAN_ON_TORONTO-INTL-A_6158731_CWEEDS2011_1998-2017.WY3";
  }

  @Test
  void loadsTheRealTorontoFile_withoutThrowing () {
    assertDoesNotThrow(() -> app.load_climateEngineering(realCweedsPath()));
  }

  @Test
  void parsesTheFirstDataLine_1998_01_01_hour1_intoHourZeroDayZeroYear1998 () {
    app.load_climateEngineering(realCweedsPath());

    int i = 0; // hour 1 -> index 0
    int j = app.TIME.convert2Date(1, 1); // January 1st -> 0
    int k = 1998 - app.climateEngineeringStart; // 28

    // Raw CWEEDS line (station id/date columns, then the fields below):
    // 6158731A1998010101   0   0M    0Q    0M    0Q   0Q   0Q99999 0   57 4000  129 00001000 10045 -133 -163   0    0  9  9 1
    assertEquals(0, j, "test precondition: January 1st must map to day-of-year index 0");
    assertEquals(28, k, "test precondition: 1998 - climateEngineeringStart (1970)");
    assertEquals(1004.5f, app.climateEngineeringValues[i][j][app.LAYER_pressure.id][k], EPS); // 10045 * 0.1
    assertEquals(-13.3f, app.climateEngineeringValues[i][j][app.LAYER_drybulb.id][k], EPS); // -133 * 0.1
    assertEquals(0f, app.climateEngineeringValues[i][j][app.LAYER_glohorrad.id][k], EPS); // night hour
    assertEquals(0f, app.climateEngineeringValues[i][j][app.LAYER_dirnorrad.id][k], EPS);
    assertEquals(0f, app.climateEngineeringValues[i][j][app.LAYER_difhorrad.id][k], EPS);
    assertEquals(0f, app.climateEngineeringValues[i][j][app.LAYER_windspd.id][k], EPS);
    assertEquals(0f, app.climateEngineeringValues[i][j][app.LAYER_winddir.id][k], EPS);
    assertEquals(9f, app.climateEngineeringValues[i][j][app.LAYER_cloudcover.id][k], EPS);
    assertEquals(570f, app.climateEngineeringValues[i][j][app.LAYER_ceilingsky.id][k], EPS); // raw 57, below 1000, so *10 (not the 7777/">=1000" clamp)
  }

  @Test
  void setsDataFlags_forEveryValueItSuccessfullyParsed () {
    app.load_climateEngineering(realCweedsPath());

    int j = app.TIME.convert2Date(1, 1);
    int k = 1998 - app.climateEngineeringStart;
    assertTrue(app.climateEngineeringFlags[0][j][app.LAYER_drybulb.id][k]);
  }

  @Test
  void aSummerDaytimeHour_hasRealNonZeroSolarRadiation_andTheUnlimitedCeilingSentinel () {
    app.load_climateEngineering(realCweedsPath());

    int i = 11; // hour 12
    int j = app.TIME.convert2Date(7, 1); // July 1st, 1998
    int k = 1998 - app.climateEngineeringStart;

    // Raw line: 6158731A199807011243603318S 3080S  486S 1024Q 932Q 166Q9999960 7777 2230  322 00000000  9876  226   96 340   92  8  4 0
    float glohorrad = app.climateEngineeringValues[i][j][app.LAYER_glohorrad.id][k];
    float dirnorrad = app.climateEngineeringValues[i][j][app.LAYER_dirnorrad.id][k];

    assertTrue(app.is_defined(glohorrad), "a July noon reading must be a real, defined value - not left at FLOAT_undefined");
    assertEquals(3318f / 3.6f, glohorrad, EPS);
    assertEquals(3080f / 3.6f, dirnorrad, EPS);

    // Ceiling height's own 4 checks are separate, sequential "if"
    // statements, not an if/else-if chain - so the "== 7777" clamp to
    // 1000 is NOT exempt from the final "*10" scaling step that follows
    // it (only "== 9999" skips that). Raw 7777 here: clamped to 1000 by
    // the 7777 check, re-clamped (a no-op) by ">= 1000", then still
    // multiplied by 10 since 1000 != 9999 -> 10000. The Jan 1st test
    // above (raw 57, below every clamp) only ever goes through that
    // final "*10" once, which is why its own expected value is the
    // simpler 570, not 10x that.
    assertEquals(10000f, app.climateEngineeringValues[i][j][app.LAYER_ceilingsky.id][k], EPS);
  }
}
