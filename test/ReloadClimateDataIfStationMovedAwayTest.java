import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// reloadClimateDataIfStationMovedAway() (updateStation.pde) - called
// right after SETLAT/SETLON/SETLATLON/SETLONLAT (extraCommands.pde)
// moves STATION's own lon/lat. This is the second attempt at the fix
// ebaeecd4aa92 ("fix download when lat lon is set via command line not
// the map") was originally going for: a command-line move has no station
// selection of its own (unlike a map click, which always explicitly picks
// its own exact TMYEPW/NAEFS station), so without re-deriving anything at
// all, STATION's Climate Typical Year/Ensemble Forecast filenames just
// kept pointing at whichever station a prior click (or the untouched
// startup default) had selected - however far the move actually was.
//
// But re-deriving the nearest station on EVERY move, however small, is
// what ebaeecd4aa92 actually did, and that broke test/image/README.md's
// whole image-regression suite instead (reverted in a9ddae2c93cd): the
// "nearest" row for the hardcoded Toronto/Vancouver/Montreal startup
// defaults turned out to be a different, same-city-different-source
// entry with no matching local file, silently blanking out the already-
// correct default data on every ordinary load. So this function only
// re-derives (and only actually reloads) each dataset once the move is
// big enough that the OLD position no longer counts as "nearby" the NEW
// one - using the exact same maxDist each dataset's own StationPicker
// (mouseClicked.pde) already uses to decide whether a map click landed
// unambiguously on one station. These tests cover that threshold
// directly, independent of allLayers/EPW-file setup, by calling the
// function with a synthetic before/after position rather than going
// through a full SETLAT command.
class ReloadClimateDataIfStationMovedAwayTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();

    // Keeps update_ensembleForecast()'s own per-layer loop (triggered
    // when the move is big enough) from doing anything beyond a single
    // harmless "FILE NOT FOUND" println - same empty-name "skip this
    // layer" convention download_ensembleForecast()/update_ensemble
    // Forecast() themselves already use.
    app.allLayers = new solarchvision_bim.LAYER[] {
      app.new LAYER(1, 0, 0, "", "", "", "")
    };
  }

  private solarchvision_bim.STATION epwCityAt (String filename, float lon, float lat) {
    solarchvision_bim.STATION s = app.new STATION();
    s.setClimateTypicalYearFilename(filename);
    s.setClimateTypicalYearDownload("");
    s.setLongitude(lon);
    s.setLatitude(lat);
    return s;
  }

  private solarchvision_bim.STATION gridPointAt (String filename, float lon, float lat) {
    solarchvision_bim.STATION s = app.new STATION();
    s.setEnsembleForecastFilename(filename);
    s.setLongitude(lon);
    s.setLatitude(lat);
    return s;
  }

  // 1 degree of latitude is roughly 111km (DOUBLE_r_Earth, globalVariables
  // .pde) - climateTypicalYearPicker's own threshold is 10000m (0.09deg),
  // ensembleForecastPicker's is 50000m (0.45deg). These test positions
  // stay far enough from either boundary not to be sensitive to the
  // haversine formula's own small-angle rounding.
  @Test
  void aSmallMove_leavesBothFilenamesAlone () {
    app.climateTypicalYearCoordinates = new solarchvision_bim.STATION[] { epwCityAt("ORIGINAL_CITY", 0, 0) };
    app.ensembleForecastCoordinates = new solarchvision_bim.STATION[] { gridPointAt("ORIGINAL_GRID", 0, 0) };

    app.STATION.setClimateTypicalYearFilename("ORIGINAL_CITY");
    app.STATION.setEnsembleForecastFilename("ORIGINAL_GRID");

    float oldLon = 0, oldLat = 0;
    app.STATION.setLongitude(0);
    app.STATION.setLatitude(0.01f); // ~1.1km - well under either threshold

    app.reloadClimateDataIfStationMovedAway(oldLon, oldLat);

    assertEquals("ORIGINAL_CITY", app.STATION.getClimateTypicalYearFilename());
    assertEquals("ORIGINAL_GRID", app.STATION.getEnsembleForecastFilename());
  }

  @Test
  void aMediumMove_reloadsOnlyClimateTypicalYear_notEnsembleForecast () {
    app.climateTypicalYearCoordinates = new solarchvision_bim.STATION[] {
      epwCityAt("ORIGINAL_CITY", 0, 0),
      epwCityAt("NEW_CITY", 0, 0.15f)
    };
    app.ensembleForecastCoordinates = new solarchvision_bim.STATION[] { gridPointAt("ORIGINAL_GRID", 0, 0) };

    app.STATION.setClimateTypicalYearFilename("ORIGINAL_CITY");
    app.STATION.setEnsembleForecastFilename("ORIGINAL_GRID");

    float oldLon = 0, oldLat = 0;
    app.STATION.setLongitude(0);
    app.STATION.setLatitude(0.15f); // ~16.7km - over climateTypicalYearPicker's 10000m, under ensembleForecastPicker's 50000m

    app.reloadClimateDataIfStationMovedAway(oldLon, oldLat);

    assertEquals("NEW_CITY", app.STATION.getClimateTypicalYearFilename(), "move is far enough for Climate Typical Year's own (tighter) threshold");
    assertEquals("ORIGINAL_GRID", app.STATION.getEnsembleForecastFilename(), "but not far enough for Ensemble Forecast's own (coarser) threshold");
  }

  @Test
  void aLargeMove_reloadsBothDatasets () {
    app.climateTypicalYearCoordinates = new solarchvision_bim.STATION[] {
      epwCityAt("ORIGINAL_CITY", 0, 0),
      epwCityAt("NEW_CITY", 0, 1)
    };
    app.ensembleForecastCoordinates = new solarchvision_bim.STATION[] {
      gridPointAt("ORIGINAL_GRID", 0, 0),
      gridPointAt("NEW_GRID", 0, 1)
    };

    app.STATION.setClimateTypicalYearFilename("ORIGINAL_CITY");
    app.STATION.setEnsembleForecastFilename("ORIGINAL_GRID");

    float oldLon = 0, oldLat = 0;
    app.STATION.setLongitude(0);
    app.STATION.setLatitude(1); // ~111km - over both thresholds

    app.reloadClimateDataIfStationMovedAway(oldLon, oldLat);

    assertEquals("NEW_CITY", app.STATION.getClimateTypicalYearFilename());
    assertEquals("NEW_GRID", app.STATION.getEnsembleForecastFilename());
  }

  // --- wired up end to end through the actual SETLAT/SETLON commands ---

  @Test
  void setLat_movesTheStationAndCallsThrough_withoutThrowing () {
    app.climateTypicalYearCoordinates = new solarchvision_bim.STATION[] { epwCityAt("ORIGINAL_CITY", 0, 0) };
    app.ensembleForecastCoordinates = new solarchvision_bim.STATION[] { gridPointAt("ORIGINAL_GRID", 0, 0) };
    app.STATION.setLongitude(0);
    app.STATION.setLatitude(0);
    app.STATION.setClimateTypicalYearFilename("ORIGINAL_CITY");
    app.STATION.setEnsembleForecastFilename("ORIGINAL_GRID");

    assertDoesNotThrow(() -> app.__SETLAT__(new String[] { "SETLAT", "1" }));

    assertEquals(1f, app.STATION.getLatitude(), 0.0001f);
    // Only one coordinate exists in either array here, so the "moved
    // away" reload (if it fired) would still resolve back to the same
    // filename - this just confirms the command's own dispatch reaches
    // reloadClimateDataIfStationMovedAway() safely, not a specific
    // outcome already covered by the direct tests above.
    assertEquals("ORIGINAL_CITY", app.STATION.getClimateTypicalYearFilename());
    assertEquals("ORIGINAL_GRID", app.STATION.getEnsembleForecastFilename());
  }
}
