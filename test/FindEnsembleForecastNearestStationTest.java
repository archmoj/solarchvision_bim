import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// findEnsembleForecastNearestStation() (updateEnsembleForecast.pde) was
// added so download_ensembleForecast() (downloadEnsembleForecast.pde)
// could call it directly too - fixing a real bug: STATION's own
// ensembleForecastFilename (the NAEFS grid-point name forecast filenames
// are built from) was previously only ever set by an explicit NAEFS
// marker click (selectEnsembleForecastStation(), mouseClicked.pde) or
// left at STATION's hardcoded startup default - never refreshed by a
// command-line SETLAT/SETLON/SETLATLON/SETLONLAT (extraCommands.pde)
// move, so "Download Ensemble Forecast" could silently keep downloading
// data for the wrong, stale location after such a move. These tests
// cover both the lookup itself and the regression it fixes.
class FindEnsembleForecastNearestStationTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();

    // Replaced with a single no-op layer (an empty name is this
    // codebase's own "skip this layer" signal - see allLayers[f].name.
    // equals("") in both download_ensembleForecast() and update_ensemble
    // Forecast()) so download_ensembleForecast() never reaches its own
    // network-downloading branch in these tests - only the nearest-
    // station lookup at the very top of that function, which is what's
    // under test here, actually runs.
    app.allLayers = new solarchvision_bim.LAYER[] {
      app.new LAYER(1, 0, 0, "", "", "", "")
    };
  }

  private solarchvision_bim.STATION gridPointAt (String filename, float lon, float lat) {
    solarchvision_bim.STATION s = app.new STATION();
    s.setEnsembleForecastFilename(filename);
    s.setLongitude(lon);
    s.setLatitude(lat);
    return s;
  }

  // --- findEnsembleForecastNearestStation() itself ----------------------

  @Test
  void setsStationFilenameToTheClosestGridPointByCurrentStationPosition () {
    app.STATION.setLongitude(0);
    app.STATION.setLatitude(0);
    app.STATION.setEnsembleForecastFilename("STALE");

    app.ensembleForecastCoordinates = new solarchvision_bim.STATION[] {
      gridPointAt("FAR_GRID", 10, 10),
      gridPointAt("NEAREST_GRID", 1, 1),
      gridPointAt("MEDIUM_GRID", -5, -5)
    };

    app.findEnsembleForecastNearestStation();

    assertEquals("NEAREST_GRID", app.STATION.getEnsembleForecastFilename());
  }

  @Test
  void reComputesWhenStationHasMoved_notStaleFromAPreviousCall () {
    app.ensembleForecastCoordinates = new solarchvision_bim.STATION[] {
      gridPointAt("WEST_GRID", -50, 0),
      gridPointAt("EAST_GRID", 50, 0)
    };

    app.STATION.setLongitude(-50);
    app.STATION.setLatitude(0);
    app.findEnsembleForecastNearestStation();
    assertEquals("WEST_GRID", app.STATION.getEnsembleForecastFilename());

    // STATION moves (e.g. a command-line SetLatLon) - a second call must
    // reflect the new position, not keep returning the first result.
    app.STATION.setLongitude(50);
    app.STATION.setLatitude(0);
    app.findEnsembleForecastNearestStation();
    assertEquals("EAST_GRID", app.STATION.getEnsembleForecastFilename());
  }

  // --- the regression: download_ensembleForecast() on a stale filename -

  @Test
  void downloadEnsembleForecast_refreshesTheStaleFilename_evenWithoutAMarkerClick () {
    // Simulates STATION having been moved from the command line (SetLat/
    // SetLon/SetLatLon/SetLonLat) to somewhere near EAST_GRID, with
    // ensembleForecastFilename still left over from wherever it was
    // before (a previous click, or the hardcoded startup default) -
    // never updated by that command-line move.
    app.ensembleForecastCoordinates = new solarchvision_bim.STATION[] {
      gridPointAt("WEST_GRID", -50, 0),
      gridPointAt("EAST_GRID", 50, 0)
    };

    app.STATION.setEnsembleForecastFilename("STALE_FROM_A_PREVIOUS_CLICK");
    app.STATION.setLongitude(50);
    app.STATION.setLatitude(0);

    app.download_ensembleForecast(2024, 1, 15, 12);

    // Before the fix, this field was never touched by download_ensemble
    // Forecast() itself, so it would still read "STALE_FROM_A_PREVIOUS_
    // CLICK" here, and every filename/link built from it inside that
    // call would have targeted the wrong (stale) grid point.
    assertEquals("EAST_GRID", app.STATION.getEnsembleForecastFilename());
  }
}
