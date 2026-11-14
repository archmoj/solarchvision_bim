import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// load_climateArchive() (loadClimateArchive.pde) was untested - 314
// instructions. input/climate/CLMREC/ bundles 324 real files (one per
// month, 2000-2026, for Toronto) for exactly this function - but every
// single one of them, checked directly across the whole directory (not
// sampled), turns out to be a cached HTML error page from the ECCC
// historical-climate-data site, not real CSV weather data - apparently
// every one of these downloads hit the same failure (a block, a
// maintenance page, or similar) at capture time, not just an unlucky
// few. This is worth flagging on its own: the fixture's real content
// doesn't match what its name and location suggest, and more CLMREC
// files being added later won't fix that by itself if they come from
// the same broken capture.
//
// Given that, this tests the one thing the fixture can actually verify
// honestly: that load_climateArchive() handles this real failure mode -
// a non-CSV file sitting where CSV is expected - robustly, without
// throwing or silently fabricating data, rather than inventing CSV
// content the fixture doesn't contain. Confirmed first (not assumed)
// that no line from this file's own row 19 onward has the 5+ comma-
// separated fields load_climateArchive()'s own "parts.length < 5"
// guard requires to attempt parsing a row at all - every line is
// skipped by that guard, so climateArchiveValues is never written to.
class LoadClimateArchiveTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.sketchPath(); // see LoadClimateTypicalYearTest.java's own comment on why

    int numLayers = app.allLayers.length;
    int numYears = 1 + app.climateArchiveEnd - app.climateArchiveStart;
    app.climateArchiveValues = new float[24][365][numLayers][numYears];
    for (float[][][] perJ : app.climateArchiveValues) {
      for (float[][] perLayer : perJ) {
        for (float[] perK : perLayer) {
          java.util.Arrays.fill(perK, app.FLOAT_undefined);
        }
      }
    }
  }

  @Test
  void aCachedHtmlErrorPage_doesNotThrow_andLeavesEveryValueUndefined () {
    String realFile = System.getProperty("user.dir") + "/input/climate/CLMREC/200101_TORONTO INTL A.csv";

    assertDoesNotThrow(() -> app.load_climateArchive(realFile));

    boolean anyDefined = false;
    outer:
    for (float[][][] perI : app.climateArchiveValues) {
      for (float[][] perJ : perI) {
        for (float[] perL : perJ) {
          for (float v : perL) {
            if (app.is_defined(v)) { anyDefined = true; break outer; }
          }
        }
      }
    }
    assertFalse(anyDefined, "an HTML error page has no real data rows for load_climateArchive()'s own \"parts.length < 5\" guard to let through");
  }
}
