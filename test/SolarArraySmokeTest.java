import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// calculate_GlobalSolar_array() was one of the two largest fully-
// untested functions in the whole codebase - 964 missed instructions,
// 72 missed branches. It runs a real per-day/per-hour solar-position
// and radiation accumulation loop over STUDY.startDay..endDay, reading
// whatever's in currentDataSource via getValue_currentDataSource() -
// so, loaded with the real Toronto weather data
// LoadClimateTypicalYearTest.java parses (rather than a hand-crafted
// synthetic day or two), this exercises a realistic, varied year of
// real sun angles/cloud cover/radiation values through its actual
// logic, not just its empty-data short-circuit.
//
// This is deliberately a SMOKE test, not an exact-value one: fully
// hand-verifying its numeric output would mean reimplementing its
// entire per-hour sun-position/radiation-binning math independently
// (in Python, say) to cross-check against - a separate, much larger
// effort of its own. What's checked here instead: it runs to
// completion on real data without throwing, its own "needs rebuilding"
// flag is actually consumed (proving it didn't bail out early), and
// its output array ends up genuinely populated (not left entirely at
// FLOAT_undefined) - together, strong evidence that the real
// accumulation loop actually ran, not just its guards.
//
// calculate_VertexSolar_array() (its own sibling, 1459 missed
// instructions) is NOT covered here: an earlier version of this file
// tried the same smoke test for it, and it threw a real
// NullPointerException - it unconditionally calls buildFaceGrid(),
// which (confirmed directly by that failure, not just suspected)
// reaches Faces.build_win3DCache() -> createShape() for at least one
// face (the grid's own reserved empty slot, per its own "Provide an
// empty item at index 0" comment - isIntersectedFaces.pde), and
// createShape() needs a live PGraphics ("this.g") that a bare,
// never-setup()'d instance never has. Setting should_rebuildFaceGrid =
// false to skip that call entirely was considered, but buildFaceGrid()
// is also what initializes entireFaces/entirePointsX/Y/Z in the first
// place - skipping it would just trade one untested failure mode for a
// second, different, unverified one. calculate_VertexSolar_array()
// joins ShadeViewport()/preBakeViewport()/update_frame_layout() as a
// function that genuinely needs a real sketch surface to run at all,
// not just one that hadn't been tested yet.
class SolarArraySmokeTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.sketchPath(); // see LoadClimateTypicalYearTest.java's own comment on why

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

    app.load_climateTypicalYear(System.getProperty("user.dir") + "/input/climate/TMYEPW/CAN_ON_Toronto.716240_CWEC.epw");
    app.currentDataSource = app.dataID_climateTypicalYear;
  }

  @Test
  void globalSolarArray_runsOnRealWeatherData_andProducesDefinedResults () {
    app.GlobalSolar_rebuild_array = true;

    assertDoesNotThrow(() -> app.calculate_GlobalSolar_array());

    assertFalse(app.GlobalSolar_rebuild_array, "the rebuild flag must be consumed, proving the real computation ran rather than bailing out early");

    boolean anyDefined = false;
    outer:
    for (float[][] perDay : app.GlobalSolar[app.Impact_ACTIVE]) {
      for (float[] perA : perDay) {
        for (float v : perA) {
          if (app.is_defined(v)) {
            anyDefined = true;
            break outer;
          }
        }
      }
    }
    assertTrue(anyDefined, "at least one sky direction, on at least one day, must have ended up with a real (not FLOAT_undefined) radiation value from a full year of real weather data");
  }
}
