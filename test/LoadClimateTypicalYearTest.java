import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// load_climateTypicalYear() (loadClimateTypicalYear.pde) was at 0%
// coverage - nothing in this suite had ever actually parsed a real EPW
// file through it (MouseClickedTest.java/STATIONTest.java/etc. only ever
// poke the *filename* fields, never load real weather data). This loads
// the real, repo-bundled Toronto TMY/EPW file (input/climate/TMYEPW/
// CAN_ON_Toronto.716240_CWEC.epw) directly, the same way Sun3DTest.java/
// Moon3DTest.java/Earth3DTest.java load their own real bundled textures -
// an absolute path built from System.getProperty("user.dir") (the
// process's own working directory, the repo root per test/run_tests.sh's
// own "cd" to it before running), rather than a synthetic one, so the
// parsing itself - real EPW column layout, real sentinel values (9999/
// 99.9/77777/...), real unit conversions - gets genuinely exercised.
//
// production.pde's own update_climateTypicalYear() is what normally
// allocates climateTypicalYearValues/climateTypicalYearFlags before
// calling this - done by hand below instead, the same minimal-setup
// style AveragedScenarioValuesTest.java's own setUpTypicalYearSource()
// already uses, rather than the full update_climateTypicalYear()
// pipeline (which would also need Folder_climateTypicalYear/STATION's
// own filename to line up with a real file on disk).
//
// Expected values below for 1969-01-01, hour 1 (i=0, j=0, k=0) are read
// directly off the file's own first data line and the EPW column
// layout load_climateTypicalYear.pde's own indices assume - not
// invented - including its unit conversions (pressure *0.01, windspeed
// *3.6) and sentinel-value handling (ceiling height 77770 -> clamped to
// 1000 by the ">= 1000" rule, not treated as one of the "no data"
// sentinels 77777/88888/99999).
class LoadClimateTypicalYearTest {

  private solarchvision_bim app;
  private static final float EPS = 0.01f;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.sketchPath(); // see SaveProjectTest.java's own comment on why this is needed before any loadStrings() call

    // The real production allocation (update_climateTypicalYear.pde),
    // done directly here instead of through that whole function.
    int numLayers = app.allLayers.length;
    app.climateTypicalYearValues = new float[24][365][numLayers][1];
    app.climateTypicalYearFlags = new boolean[24][365][numLayers][1];
    for (float[][][] perJ : app.climateTypicalYearValues) {
      for (float[][] perLayer : perJ) {
        for (float[] perK : perLayer) {
          java.util.Arrays.fill(perK, app.FLOAT_undefined);
        }
      }
    }
  }

  private String realEpwPath () {
    return System.getProperty("user.dir") + "/input/climate/TMYEPW/CAN_ON_Toronto.716240_CWEC.epw";
  }

  @Test
  void loadsTheRealTorontoFile_withoutThrowing () {
    assertDoesNotThrow(() -> app.load_climateTypicalYear(realEpwPath()));
  }

  @Test
  void parsesTheFirstDataLine_1969_01_01_hour1_intoHourZeroDayZero () {
    app.load_climateTypicalYear(realEpwPath());

    int i = 0; // hour 1 -> index 0
    int j = app.TIME.convert2Date(1, 1); // January 1st -> 0
    int k = 0; // the only "year" a TMY file has

    // Raw EPW line: 1969,1,1,1,60,...,-11.9,-16.6,65,99220,0,9999,204,
    // 0,0,0,0,0,0,999900,270,4.4,3,3,25.0,77770,0,999999999,0,0.0000,1,
    // 88,0.000,0.0,0.0
    assertEquals(0, j, "test precondition: January 1st must map to day-of-year index 0");
    assertEquals(-11.9f, app.climateTypicalYearValues[i][j][app.LAYER_drybulb.id][k], EPS);
    assertEquals(992.2f, app.climateTypicalYearValues[i][j][app.LAYER_pressure.id][k], EPS); // 99220 * 0.01
    assertEquals(65f, app.climateTypicalYearValues[i][j][app.LAYER_relhum.id][k], EPS);
    assertEquals(0f, app.climateTypicalYearValues[i][j][app.LAYER_glohorrad.id][k], EPS); // night hour
    assertEquals(0f, app.climateTypicalYearValues[i][j][app.LAYER_dirnorrad.id][k], EPS);
    assertEquals(0f, app.climateTypicalYearValues[i][j][app.LAYER_difhorrad.id][k], EPS);
    assertEquals(15.84f, app.climateTypicalYearValues[i][j][app.LAYER_windspd.id][k], EPS); // 4.4 m/s * 3.6
    assertEquals(270f, app.climateTypicalYearValues[i][j][app.LAYER_winddir.id][k], EPS);
    assertEquals(3f, app.climateTypicalYearValues[i][j][app.LAYER_cloudcover.id][k], EPS);
    assertEquals(1000f, app.climateTypicalYearValues[i][j][app.LAYER_ceilingsky.id][k], EPS); // 77770 clamped by the ">= 1000" rule
  }

  @Test
  void setsDataFlags_forEveryValueItSuccessfullyParsed () {
    // load_climateTypicalYear()'s own final step - setDataFlags(dataID_climateTypicalYear) -
    // was itself at 0% coverage; this confirms it actually ran and
    // marked a real parsed value "defined" (climateTypicalYearFlags
    // defaults false everywhere - Java's bare array default - until
    // setDataFlags() flips it).
    app.load_climateTypicalYear(realEpwPath());

    int j = app.TIME.convert2Date(1, 1);
    assertTrue(app.climateTypicalYearFlags[0][j][app.LAYER_drybulb.id][0]);
  }

  @Test
  void aSummerDaytimeHour_hasRealNonZeroSolarRadiation () {
    // A clean way to confirm the parse covers the whole file, not just
    // its first line: July 1st (day-of-year index per TIME.convert2Date),
    // noon (hour 12 -> index 11), should show real daytime solar
    // radiation, not the all-night zeros 1969-01-01's hour 1 has.
    app.load_climateTypicalYear(realEpwPath());

    int i = 11; // hour 12
    int j = app.TIME.convert2Date(7, 1); // July 1st
    int k = 0;

    float dirnorrad = app.climateTypicalYearValues[i][j][app.LAYER_dirnorrad.id][k];
    float glohorrad = app.climateTypicalYearValues[i][j][app.LAYER_glohorrad.id][k];

    assertTrue(app.is_defined(dirnorrad), "a July noon reading must be a real, defined value - not left at FLOAT_undefined");
    assertTrue(app.is_defined(glohorrad));
    assertTrue(glohorrad > 0, "midday in July must show some global horizontal radiation");
  }
}
