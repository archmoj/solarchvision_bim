import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Tropo3D.loadSlotIfMatch() (tropo3D.pde) was untested. It's the real
// per-slot GEOMET image matcher load_images() calls 24 times (once per
// TROPO_timeSteps's own bare-construction default) - but load_images()
// itself isn't what's tested here: it builds its own search hour from
// currentUTC() -> getNow_inUTC(), which reads the real system clock,
// making its own result different every time this suite runs rather
// than a fixed, verifiable one against a fixture pinned to one specific
// hour (projects/test/data/GEOMET/20261113_23/). loadSlotIfMatch()
// itself has no such dependency - a plain string match against whatever
// hour label it's given - so that's what's tested directly, the same
// reasoning LoadClimateTypicalYearTest.java's own header gives for
// testing load_climateTypicalYear() directly rather than the fuller
// update_climateTypicalYear() around it.
//
// The fixture holds 24 real PNGs, one per hour of the day (00-23),
// each named "HH_<lat1>_<lon1>_<lat2>_<lon2>_.png" with the 4 bounding-
// box numbers in millidegrees (tropo3D.pde's own BOUNDARY_SCALE =
// 0.001) - confirmed directly from one real filename, not invented:
// "14_081130_042585_078130_044755_.png" decodes to BoundariesX =
// [-81.13, -78.13], BoundariesY = [42.585, 44.755] (Toronto's own
// surrounding area), and the image itself is a real, valid 1800x900 PNG
// (confirmed with `file`, not assumed).
class TropoGeometLoadTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.sketchPath(); // see LoadClimateTypicalYearTest.java's own comment on why - loadImage() needs this too
    app.Folder_GEOMET = System.getProperty("user.dir") + "/projects/test/data/GEOMET/20261113_23";
    app.Tropo3D.resize_images(); // allocates Filenames/Map/BoundariesX/Y to TROPO_timeSteps - null otherwise
  }

  @Test
  void loadSlotIfMatch_withARealMatchingHour_loadsTheRealImageAndDecodesItsBoundaries () {
    String[] allFilenames = app.sort(app.OPESYS.getFiles(app.Folder_GEOMET));

    app.Tropo3D.loadSlotIfMatch(0, allFilenames, "14");

    assertEquals("14_081130_042585_078130_044755_.png", app.Tropo3D.Filenames[0]);
    assertEquals(-81.13f, app.Tropo3D.BoundariesX[0][0], 0.001f);
    assertEquals(42.585f, app.Tropo3D.BoundariesY[0][0], 0.001f);
    assertEquals(-78.13f, app.Tropo3D.BoundariesX[0][1], 0.001f);
    assertEquals(44.755f, app.Tropo3D.BoundariesY[0][1], 0.001f);
    assertEquals(1800, app.Tropo3D.Map[0].width, "a real, successfully-decoded PNG must have been loaded");
    assertEquals(900, app.Tropo3D.Map[0].height);
  }

  @Test
  void loadSlotIfMatch_withNoMatchingHour_leavesTheSlotAtItsResetDefault () {
    String[] allFilenames = app.sort(app.OPESYS.getFiles(app.Folder_GEOMET));

    app.Tropo3D.loadSlotIfMatch(0, allFilenames, "99"); // no file for hour 99

    // resetSlot()'s own default, set by resize_images() -> reset(), left
    // untouched since loadSlotIfMatch()'s own search loop never finds a
    // match.
    assertEquals("", app.Tropo3D.Filenames[0]);
    assertEquals(2, app.Tropo3D.Map[0].width);
  }
}
