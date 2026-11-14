import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// load_climateArchive() (loadClimateArchive.pde) parses real CLMREC CSV
// data for Toronto (input/climate/CLMREC/) - previously all 324 files
// in this fixture were cached HTML error pages (an earlier version of
// this test documented that finding and tested the function's own
// robustness against it instead), but the download itself has since
// been fixed (a missing station code and missing required URL
// parameters - see inputClimateArchiveCoordinates.pde/
// downloadClimateArchive.pde) and real CSV data now exists.
//
// That real data uncovered a THIRD, deeper bug this test exists to
// cover: load_climateArchive()'s own column indices didn't match
// ECCC's real CSV schema at all. The real header (2001+ files, 31
// columns) is "Longitude (x)","Latitude (y)","Station Name","Climate
// ID","Date/Time (LST)","Year","Month","Day","Time (LST)","Flag","Temp
// (°C)","Temp Flag","Dew Point Temp (°C)","Dew Point Temp Flag","Rel
// Hum (%)","Rel Hum Flag","Precip. Amount (mm)","Precip. Amount
// Flag","Wind Dir (10s deg)","Wind Dir Flag","Wind Spd (km/h)","Wind
// Spd Flag","Visibility (km)","Visibility Flag","Stn Press
// (kPa)","Stn Press Flag","Hmdx","Hmdx Flag","Wind Chill","Wind Chill
// Flag","Weather" - Year/Month/Day/Time sit at indices 5/6/7/8, not
// 1/2/3/4 as the function assumed before (which are actually Latitude/
// Station Name/Climate ID/Date-Time) - confirmed by mapping the real
// header string to a real data row with a standalone script, not
// guessed, which is also how this fix was found in the first place
// (the crash this test guards against: "43.68", the real Latitude
// value, getting parsed as a year).
//
// Many of the earliest hours in any given month's file have no real
// sensor readings yet (just the first 9 identifying columns) - a real,
// common row shape, not a malformed one - so this also confirms those
// are still safely skipped, now via the corrected "parts.length < 9"/
// "parts.length > 30" guards (the old ones, sized for the wrong
// indices, would have under- or over-shot the real minimum width
// needed).
class LoadClimateArchiveTest {

  private solarchvision_bim app;
  private static final float EPS = 0.01f;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.sketchPath(); // see LoadClimateTypicalYearTest.java's own comment on why

    int numLayers = app.allLayers.length;
    int numYears = 1 + app.climateArchiveEnd - app.climateArchiveStart; // climateArchiveEnd is year()-based - computed, not hardcoded, for exactly that reason
    app.climateArchiveValues = new float[24][365][numLayers][numYears];
    for (float[][][] perJ : app.climateArchiveValues) {
      for (float[][] perLayer : perJ) {
        for (float[] perK : perLayer) {
          java.util.Arrays.fill(perK, app.FLOAT_undefined);
        }
      }
    }
  }

  private String realFile (String name) {
    return System.getProperty("user.dir") + "/input/climate/CLMREC/" + name;
  }

  @Test
  void loadsARealFile_withoutThrowing () {
    assertDoesNotThrow(() -> app.load_climateArchive(realFile("201307_TORONTO INTL A.csv")));
  }

  @Test
  void parsesARealRow_rainShowers_2013_06_11_09h00 () {
    app.load_climateArchive(realFile("201306_TORONTO INTL A.csv"));

    int i = 9;
    int j = app.TIME.convert2Date(6, 11);
    int k = 2013 - app.climateArchiveStart;

    // Real row: "...","2013-06-11 09:00","2013","06","11","09:00","",
    // "17.8","","16.0","","89","","","","34","","21","","24.1","",
    // "98.66","","","","","","Rain Showers"
    assertEquals(17.8f, app.climateArchiveValues[i][j][app.LAYER_drybulb.id][k], EPS);
    assertEquals(89f, app.climateArchiveValues[i][j][app.LAYER_relhum.id][k], EPS);
    assertEquals(340f, app.climateArchiveValues[i][j][app.LAYER_winddir.id][k], EPS); // 34 * 10
    assertEquals(21f, app.climateArchiveValues[i][j][app.LAYER_windspd.id][k], EPS);
    assertEquals(986.6f, app.climateArchiveValues[i][j][app.LAYER_pressure.id][k], EPS); // 98.66 * 10
    assertEquals(10f, app.climateArchiveValues[i][j][app.LAYER_cloudcover.id][k], EPS); // "Rain Showers" matches none of the named cases -> the "else" 10
  }

  @Test
  void parsesARealRow_clear_2013_07_11_01h00 () {
    app.load_climateArchive(realFile("201307_TORONTO INTL A.csv"));

    int i = 1;
    int j = app.TIME.convert2Date(7, 11);
    int k = 2013 - app.climateArchiveStart;

    // Real row: "...","2013-07-11 01:00","2013","07","11","01:00","",
    // "17.7","","12.0","","69","","","","31","","22","","24.1","",
    // "99.12","","","","","","Clear"
    assertEquals(17.7f, app.climateArchiveValues[i][j][app.LAYER_drybulb.id][k], EPS);
    assertEquals(69f, app.climateArchiveValues[i][j][app.LAYER_relhum.id][k], EPS);
    assertEquals(310f, app.climateArchiveValues[i][j][app.LAYER_winddir.id][k], EPS); // 31 * 10
    assertEquals(22f, app.climateArchiveValues[i][j][app.LAYER_windspd.id][k], EPS);
    assertEquals(991.2f, app.climateArchiveValues[i][j][app.LAYER_pressure.id][k], EPS); // 99.12 * 10
    assertEquals(0f, app.climateArchiveValues[i][j][app.LAYER_cloudcover.id][k], EPS); // "Clear" -> 0
  }

  @Test
  void aWeatherDescriptionWithAnEmbeddedComma_stillParsesEveryOtherFieldCorrectly () {
    // Real row (201306, a different hour): "...","Rain,Fog" - splits
    // into 32 fields instead of 31, but every field this function reads
    // sits at a lower index than the split, so it's unaffected.
    app.load_climateArchive(realFile("201306_TORONTO INTL A.csv"));

    int i = 7;
    int j = app.TIME.convert2Date(6, 16);
    int k = 2013 - app.climateArchiveStart;

    assertEquals(16.7f, app.climateArchiveValues[i][j][app.LAYER_drybulb.id][k], EPS);
    assertEquals(91f, app.climateArchiveValues[i][j][app.LAYER_relhum.id][k], EPS);
  }

  @Test
  void anHourWithNoRealReadingsYet_isSkippedWithoutThrowing () {
    // The earliest hours in most files have only the first 9
    // identifying columns, no real sensor data - a real, common shape,
    // not malformed.
    assertDoesNotThrow(() -> app.load_climateArchive(realFile("200001_TORONTO INTL A.csv")));

    int i = 0;
    int j = app.TIME.convert2Date(1, 1);
    int k = 2000 - app.climateArchiveStart;
    assertFalse(app.is_defined(app.climateArchiveValues[i][j][app.LAYER_drybulb.id][k]));
  }
}
