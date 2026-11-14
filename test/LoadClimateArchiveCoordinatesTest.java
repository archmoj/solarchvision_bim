import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// loadClimateArchiveCoordinates() (inputClimateArchiveCoordinates.pde)
// parses the real, repo-bundled input/coordinates/CLMREC.txt station
// list - this test specifically verifies the fix just made to it: the
// loader built every climateArchiveCoordinates[] entry's STATION object
// from CLMREC.txt's own real columns (Name, Province, Latitude,
// Longitude, Elevation, ...) but never called .setCode(...) - confirmed
// directly by reading the loader next to the file's own real header
// row ("Name,Province,Climate ID,Station ID,WMO ID,...") - so
// getCode() always returned "" regardless of the file's real content.
// downloadClimateArchive()'s own download URL uses exactly that code as
// its "stationID=" parameter, so every real download request this app
// ever made went out with an empty station id - almost certainly why
// every file in the CLMREC fixture (input/climate/CLMREC/) turned out
// to be a cached HTML error page instead of real CSV data
// (LoadClimateArchiveTest.java's own header comment documents that
// finding). The fix: climateArchiveCoordinates[f].setCode(parts[3]) -
// CLMREC.txt's own "Station ID" column, the 4th one.
class LoadClimateArchiveCoordinatesTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.BaseFolder = System.getProperty("user.dir");
    app.sketchPath(); // see LoadClimateTypicalYearTest.java's own comment on why
    app.update_input_folders(); // BaseFolder-only derivation (unlike update_project_folders(), nothing project-specific to worry about overwriting) - sets Folder_Coordinates among others
  }

  @Test
  void loadsTheRealCoordinatesFile_withoutThrowing () {
    assertDoesNotThrow(() -> app.loadClimateArchiveCoordinates());
  }

  @Test
  void torontoIntlA_getsItsRealStationIdCode_notAnEmptyString () {
    app.loadClimateArchiveCoordinates();

    // The real row in CLMREC.txt: "TORONTO INTL A,ONTARIO,6158731,51459,
    // 71624,YYZ,43.68,-79.63,...,173.4,..." - Station ID (parts[3]) is
    // "51459", the real ECCC numeric id for this station (independently
    // confirmed against multiple real, working example download URLs
    // for this exact station elsewhere).
    solarchvision_bim.STATION torontoIntlA = null;
    for (solarchvision_bim.STATION s : app.climateArchiveCoordinates) {
      if (s.getCity().equals("TORONTO INTL A")) {
        torontoIntlA = s;
        break;
      }
    }

    assertNotNull(torontoIntlA, "test precondition: TORONTO INTL A must be in the real coordinates file");
    assertEquals("51459", torontoIntlA.getCode());
    assertEquals(43.68f, torontoIntlA.getLatitude(), 0.001f);
    assertEquals(-79.63f, torontoIntlA.getLongitude(), 0.001f);
  }
}
