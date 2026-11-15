import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// findEnsembleForecastNearestStation() (updateEnsembleForecast.pde) - a
// plain nearest-of-coords lookup that sets STATION's own
// ensembleForecastFilename to whichever ensembleForecastCoordinates
// entry is closest to STATION's current lon/lat. Only the lookup itself
// is covered here; updateStation.pde's own reloadClimateDataIfStation
// MovedAway() (ReloadClimateDataIfStationMovedAwayTest.java) covers WHEN
// this actually gets called from a command-line SETLAT/SETLON/SETLATLON/
// SETLONLAT move - calling this unconditionally on every ordinary load,
// rather than only on an actual large-enough relocation, is exactly what
// broke test/image/README.md's whole image-regression suite the first
// time this was attempted (ebaeecd4aa92, reverted in a9ddae2c93cd) - see
// that function's own comment.
class FindEnsembleForecastNearestStationTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  private solarchvision_bim.STATION gridPointAt (String filename, float lon, float lat) {
    solarchvision_bim.STATION s = app.new STATION();
    s.setEnsembleForecastFilename(filename);
    s.setLongitude(lon);
    s.setLatitude(lat);
    return s;
  }

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

    // STATION moves - a second call must reflect the new position, not
    // keep returning the first result.
    app.STATION.setLongitude(50);
    app.STATION.setLatitude(0);
    app.findEnsembleForecastNearestStation();
    assertEquals("EAST_GRID", app.STATION.getEnsembleForecastFilename());
  }

  @Test
  void doesNothingWhenCoordinatesHaveNotBeenLoadedYet () {
    app.ensembleForecastCoordinates = null;
    app.STATION.setEnsembleForecastFilename("UNCHANGED");

    assertDoesNotThrow(() -> app.findEnsembleForecastNearestStation());

    assertEquals("UNCHANGED", app.STATION.getEnsembleForecastFilename());
  }
}
