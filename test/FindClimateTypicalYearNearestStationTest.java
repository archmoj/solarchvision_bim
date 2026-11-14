import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

import java.nio.file.Files;
import java.nio.file.Path;

// findClimateTypicalYearNearestStation() (updateClimateTypicalYear.pde)
// was added so download_climateTypicalYear() (downloadClimateTypicalYearD
// .pde) could call it directly too - fixing a real bug: STATION's own
// climateTypicalYearFilename/climateTypicalYearDownload (the EPW city and
// its download link) were previously only ever set by an explicit TMYEPW
// marker click (selectClimateTypicalYearStation(), mouseClicked.pde) or
// left at STATION's hardcoded startup default (whose climateTypicalYear
// Download is blank there) - never refreshed by a command-line SETLAT/
// SETLON/SETLATLON/SETLONLAT (extraCommands.pde) move, so "Download
// Climate Typical Year" could silently keep targeting the wrong, stale
// city (or no download link at all) after such a move. These tests cover
// both the lookup itself and the regression it fixes.
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

  // --- findClimateTypicalYearNearestStation() itself --------------------

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

    // STATION moves (e.g. a command-line SetLatLon) - a second call must
    // reflect the new position, not keep returning the first result.
    app.STATION.setLongitude(50);
    app.STATION.setLatitude(0);
    app.findClimateTypicalYearNearestStation();
    assertEquals("EAST_CITY", app.STATION.getClimateTypicalYearFilename());
    assertEquals("http://example.com/east.zip", app.STATION.getClimateTypicalYearDownload());
  }

  // --- the regression: download_climateTypicalYear() on a stale filename -

  @Test
  void downloadClimateTypicalYear_refreshesTheStaleFilename_evenWithoutAMarkerClick () throws Exception {
    // Simulates STATION having been moved from the command line (SetLat/
    // SetLon/SetLatLon/SetLonLat) to somewhere near EAST_CITY, with
    // climateTypicalYearFilename/climateTypicalYearDownload still left
    // over from wherever it was before (a previous click, or the
    // hardcoded startup default) - never updated by that command-line
    // move.
    app.climateTypicalYearCoordinates = new solarchvision_bim.STATION[] {
      epwCityAt("WEST_CITY", "http://example.com/west.zip", -50, 0),
      epwCityAt("EAST_CITY", "http://example.com/east.zip", 50, 0)
    };

    app.STATION.setClimateTypicalYearFilename("STALE_FROM_A_PREVIOUS_CLICK");
    app.STATION.setClimateTypicalYearDownload("");
    app.STATION.setLongitude(50);
    app.STATION.setLatitude(0);

    // Pre-create the (now correctly resolved) target .epw file so the
    // "File dir = new File(the_target + \".epw\"); if (!dir.isFile())"
    // check is false and this test never attempts a real network
    // download.
    Path tempDir = Files.createTempDirectory("climateTypicalYearTest");
    app.Folder_climateTypicalYear = tempDir.toString();
    Files.createFile(tempDir.resolve("EAST_CITY.epw"));

    app.download_climateTypicalYear();

    // Before the fix, these fields were never touched by download_
    // climateTypicalYear() itself, so they would still read the stale
    // values here, and the (skipped, in this test) download would have
    // targeted the wrong city.
    assertEquals("EAST_CITY", app.STATION.getClimateTypicalYearFilename());
    assertEquals("http://example.com/east.zip", app.STATION.getClimateTypicalYearDownload());
  }
}
