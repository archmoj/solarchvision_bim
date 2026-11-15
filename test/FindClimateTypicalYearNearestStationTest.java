import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// findClimateTypicalYearNearestStation() (updateClimateTypicalYear.pde) -
// a plain nearest-of-coords lookup that sets STATION's own
// climateTypicalYearFilename/climateTypicalYearDownload to whichever
// climateTypicalYearCoordinates entry is closest to STATION's current
// lon/lat. Only the lookup itself is covered here; updateStation.pde's
// own reloadClimateDataIfStationMovedAway() (ReloadClimateDataIfStation
// MovedAwayTest.java) covers WHEN this actually gets called from a
// command-line SETLAT/SETLON/SETLATLON/SETLONLAT move - calling this
// unconditionally on every ordinary load, rather than only on an actual
// large-enough relocation, is exactly what broke test/image/README.md's
// whole image-regression suite the first time this was attempted
// (ebaeecd4aa92, reverted in a9ddae2c93cd) - see that function's own
// comment.
class FindClimateTypicalYearNearestStationTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  private solarchvision_bim.STATION epwCityAt (String filename, String downloadUrl, float lon, float lat) {
    solarchvision_bim.STATION s = app.new STATION();
    s.setClimateTypicalYearFilename(filename);
    s.setClimateTypicalYearDownload(downloadUrl);
    s.setLongitude(lon);
    s.setLatitude(lat);
    return s;
  }

  @Test
  void setsBothFilenameAndDownloadLinkToTheClosestCityByCurrentStationPosition () {
    app.STATION.setLongitude(0);
    app.STATION.setLatitude(0);
    app.STATION.setClimateTypicalYearFilename("STALE");
    app.STATION.setClimateTypicalYearDownload("");

    app.climateTypicalYearCoordinates = new solarchvision_bim.STATION[] {
      epwCityAt("FAR_CITY", "http://example.com/far.zip", 10, 10),
      epwCityAt("NEAREST_CITY", "http://example.com/nearest.zip", 1, 1),
      epwCityAt("MEDIUM_CITY", "http://example.com/medium.zip", -5, -5)
    };

    app.findClimateTypicalYearNearestStation();

    assertEquals("NEAREST_CITY", app.STATION.getClimateTypicalYearFilename());
    assertEquals("http://example.com/nearest.zip", app.STATION.getClimateTypicalYearDownload());
  }

  @Test
  void reComputesWhenStationHasMoved_notStaleFromAPreviousCall () {
    app.climateTypicalYearCoordinates = new solarchvision_bim.STATION[] {
      epwCityAt("WEST_CITY", "http://example.com/west.zip", -50, 0),
      epwCityAt("EAST_CITY", "http://example.com/east.zip", 50, 0)
    };

    app.STATION.setLongitude(-50);
    app.STATION.setLatitude(0);
    app.findClimateTypicalYearNearestStation();
    assertEquals("WEST_CITY", app.STATION.getClimateTypicalYearFilename());

    // STATION moves - a second call must reflect the new position, not
    // keep returning the first result.
    app.STATION.setLongitude(50);
    app.STATION.setLatitude(0);
    app.findClimateTypicalYearNearestStation();
    assertEquals("EAST_CITY", app.STATION.getClimateTypicalYearFilename());
    assertEquals("http://example.com/east.zip", app.STATION.getClimateTypicalYearDownload());
  }

  @Test
  void doesNothingWhenCoordinatesHaveNotBeenLoadedYet () {
    // Guarded against climateTypicalYearCoordinates still being null -
    // confirmed directly: UndoRedoStationTest's own tests construct the
    // sketch and exercise update_station(-1) without loading any
    // coordinate files first, which would otherwise NPE here.
    app.climateTypicalYearCoordinates = null;
    app.STATION.setClimateTypicalYearFilename("UNCHANGED");

    assertDoesNotThrow(() -> app.findClimateTypicalYearNearestStation());

    assertEquals("UNCHANGED", app.STATION.getClimateTypicalYearFilename());
  }
}
