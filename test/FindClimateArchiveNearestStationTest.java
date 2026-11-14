import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;

// findClimateArchiveNearestStation() (updateClimateArchive.pde) was
// extracted from inside updateClimateArchive()'s own climateArchiveShould
// Load branch so downloadClimateArchive() (downloadClimateArchive.pde)
// could call it directly too - fixing a real bug: "Download Climate
// Archive" used to do nothing at all the first time it was ever clicked,
// because climateArchiveNearestStationIndex (globalVariables.pde) starts
// at -1 and was previously only ever computed as a side effect of "Use
// Climate Archive" (actions.pde) having run updateClimateArchive() with
// climateArchiveShouldLoad already true. These tests cover both the
// extracted lookup itself and the regression it fixes.
class FindClimateArchiveNearestStationTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.sketchPath(); // see SaveProjectTest.java's own comment on why this is needed before any loadStrings() call - downloadClimateArchive() ends by calling updateClimateArchive(), which calls load_climateArchive(), which calls loadStrings()
  }

  private solarchvision_bim.STATION archiveStationAt (String city, float lon, float lat) {
    solarchvision_bim.STATION s = app.new STATION();
    s.setCity(city);
    s.setLongitude(lon);
    s.setLatitude(lat);
    return s;
  }

  // --- findClimateArchiveNearestStation() itself ------------------------

  @Test
  void picksTheClosestStationByCurrentStationPosition () {
    app.STATION.setLongitude(0);
    app.STATION.setLatitude(0);

    app.climateArchiveCoordinates = new solarchvision_bim.STATION[] {
      archiveStationAt("FAR", 10, 10),
      archiveStationAt("NEAREST", 1, 1),
      archiveStationAt("MEDIUM", -5, -5)
    };

    app.findClimateArchiveNearestStation();

    assertEquals(1, app.climateArchiveNearestStationIndex);
    float expectedDist = app.funcs.lon_lat_dist(1, 1, 0, 0);
    assertEquals(expectedDist, app.climateArchiveNearestStationDist, 1f);
  }

  @Test
  void reComputesWhenStationHasMoved_notStaleFromAPreviousCall () {
    app.climateArchiveCoordinates = new solarchvision_bim.STATION[] {
      archiveStationAt("WEST", -50, 0),
      archiveStationAt("EAST", 50, 0)
    };

    app.STATION.setLongitude(-50);
    app.STATION.setLatitude(0);
    app.findClimateArchiveNearestStation();
    assertEquals(0, app.climateArchiveNearestStationIndex); // WEST

    // STATION moves (e.g. a command-line SetLatLon) - a second call must
    // reflect the new position, not keep returning the first result.
    app.STATION.setLongitude(50);
    app.STATION.setLatitude(0);
    app.findClimateArchiveNearestStation();
    assertEquals(1, app.climateArchiveNearestStationIndex); // EAST
  }

  // --- the regression: downloadClimateArchive() on a never-"Use"d state -

  @Test
  void downloadClimateArchive_findsTheStationOnItsOwn_withoutUseClimateArchiveHavingRunFirst () throws Exception {
    // Reproduces the exact bug: climateArchiveNearestStationIndex still
    // sitting at its never-computed default, as it always is right after
    // startup/a fresh STATION move, before "Use Climate Archive" has ever
    // run updateClimateArchive() once.
    assertEquals(-1, app.climateArchiveNearestStationIndex);

    app.climateArchiveCoordinates = new solarchvision_bim.STATION[] {
      archiveStationAt("TESTCITY", 0, 0)
    };
    app.STATION.setLongitude(0);
    app.STATION.setLatitude(0);

    // Narrow the year range to one single year so this touches exactly
    // 12 month-files, and pre-create every one of them (empty is fine -
    // load_climateArchive() skips a file with no real data rows without
    // throwing, confirmed by LoadClimateArchiveTest's own
    // anHourWithNoRealReadingsYet_isSkippedWithoutThrowing) so the
    // "File dir = new File(target); if (!dir.isFile())" check is always
    // false and this test never attempts a real network download.
    app.climateArchiveStart = 2024;
    app.climateArchiveEnd = 2024;

    Path tempDir = Files.createTempDirectory("climateArchiveTest");
    app.Folder_climateArchive = tempDir.toString();
    for (int m = 1; m <= 12; m++) {
      String FN = "2024" + app.nf(m, 2) + "_TESTCITY.csv";
      Files.createFile(tempDir.resolve(FN));
    }

    app.downloadClimateArchive();

    // Before the fix, the whole body of downloadClimateArchive() was
    // guarded by "if (climateArchiveNearestStationIndex != -1)" and
    // nothing here would have run at all - climateArchiveNearestStation
    // Index would still be -1 and climateArchiveShouldLoad would still be
    // false afterwards.
    assertEquals(0, app.climateArchiveNearestStationIndex);
    assertTrue(app.climateArchiveShouldLoad);
  }
}
