import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// SolarImpacts.calculate_Impact_CurrentPreBaked() (solarImpacts.pde) was
// the single largest fully-untested function in the whole codebase -
// 1728 instructions, 124 branches - bigger even than calculate_
// VertexSolar_array() (SolarArraySmokeTest.java's own comment on why
// THAT one can't be tested headlessly: it unconditionally needs a real
// PGraphics via buildFaceGrid()/createShape()).
//
// This one is different: nothing in it calls createShape()/
// createGraphics()/touches WIN3D.graphics - confirmed by reading the
// whole ~640-line function, not just assumed from its name. Its one
// real GUI-shaped risk, a Swing/AWT ProgressWindow, is explicitly
// guarded by canShowProgressWindow() (preBakeViewport3D.pde):
// `!java.awt.GraphicsEnvironment.isHeadless()` - the function's own
// author already wrote this specifically for a headless run, same as
// this test environment, so that window is never actually constructed
// here. Its other potential risks are each already defused by their own
// existing guards: real disk I/O only happens behind `record_IMG ==
// true` (bare-construction default: false); its two PNG-texture lookups
// (Model2DsTexture/diffuseShadings) only call loadImage() behind a
// `new File(...).exists()` check, so a path built from this test's null
// Folder_Shadings (a literal "null/..." string - safe, not an NPE)
// simply never resolves to a real file and stays null, exactly the
// "no bake exists yet" fallback the function's own comment describes.
//
// Like SolarArraySmokeTest.java's own calculate_GlobalSolar_array()
// test, this is deliberately a SMOKE test: fully hand-verifying its
// numeric output would mean reimplementing its own scenario-averaged,
// per-pixel palette math independently to cross-check against - its own
// separate, larger effort. RES1/RES2 (the real per-pixel grid this
// function iterates, normally 400x400) are shrunk to 4x4 here purely so
// the test completes quickly - the function does spin up a real
// background thread pool (java.util.concurrent.ExecutorService) for its
// own accumulation loop, same as the real app does; nothing is mocked
// out. 4 is deliberately NOT the same size as resize_Image_array()'s own
// 2x2 placeholder images, so a resulting width of 4 is unambiguous proof
// the real per-day image replaced the placeholder, not just that both
// happen to look alike.
class CalculateImpactCurrentPreBakedSmokeTest {

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

    app.allSolarImpacts.RES1 = 4;
    app.allSolarImpacts.RES2 = 4;
    app.allSolarImpacts.rebuild_Image_array = true; // its own bare-construction default too, set explicitly for clarity
  }

  @Test
  void runsToCompletionOnRealWeatherData_andReplacesThePlaceholderDayImageWithARealOne () {
    assertDoesNotThrow(() -> app.allSolarImpacts.calculate_Impact_CurrentPreBaked());

    assertFalse(app.allSolarImpacts.isCalculatingImpact, "must be reset to false once the whole call finishes");
    assertFalse(app.allSolarImpacts.rebuild_Image_array, "the rebuild flag must be consumed by its own resize_Image_array() call");

    // STUDY.startDay (0) -> index 1 in this.Image[q][] (index 0 is the
    // "total" image, at j == -1). Checked for both Impact_ACTIVE (0) and
    // Impact_PASSIVE (1) - numberOfImpactVariations covers both every
    // single day.
    int dayIndex = app.STUDY.startDay + 1;
    assertEquals(4, app.allSolarImpacts.Image[app.Impact_ACTIVE][dayIndex].width, "the 2x2 placeholder must have been replaced by a real RES1xRES2 image");
    assertEquals(4, app.allSolarImpacts.Image[app.Impact_PASSIVE][dayIndex].width);
  }
}
