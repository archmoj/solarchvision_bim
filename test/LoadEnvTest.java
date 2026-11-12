import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// load_env() (loadEnv.pde) reads a ".env" file (relative to the sketch)
// for TERRAINTAP_API_KEY/GOOGLE_STATIC_MAPS_API_KEY, line by line,
// key=value. Was at 0% coverage.
//
// Deliberately does NOT assume whether a real .env file exists in
// whatever environment runs this suite - an earlier version of this
// file assumed one never would and asserted the keys stay at their
// default empty string, which failed the moment it ran somewhere with a
// real .env present (a private dev machine, say). These tests instead
// check only what's true either way: load_env() never throws, reading
// the same file twice is idempotent, and neither key field is ever left
// null. None of that depends on - or reveals - whatever the file
// actually contains, if anything.
//
// loadStrings() itself throws "Files must be loaded inside setup() or
// after it has been called." unless sketchPath() has been called at
// least once first (PApplet's own lazy caching - see SaveProjectTest.java's
// own comment on the exact same requirement for loadStrings()/loadImage()/
// createInput()), so that's done here regardless of whether a file is
// actually found.
class LoadEnvTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.sketchPath(); // see SaveProjectTest.java's own comment on why this is needed before any loadStrings() call
  }

  @Test
  void doesNotThrow_whetherOrNotADotEnvFileIsActuallyPresent () {
    assertDoesNotThrow(() -> app.load_env());
  }

  @Test
  void neverLeavesEitherApiKeyFieldNull () {
    app.load_env();

    assertNotNull(app.TERRAINTAP_API_KEY);
    assertNotNull(app.GOOGLE_STATIC_MAPS_API_KEY);
  }

  @Test
  void readingTheSameFileTwice_isIdempotent () {
    // Whether or not a .env exists, calling load_env() again must land
    // on the exact same values the first call did - a stable, repeatable
    // re-read, not something that drifts (or clears itself) on a second
    // pass over the same (unchanged) file.
    app.load_env();
    String firstTerraintap = app.TERRAINTAP_API_KEY;
    String firstGoogleMaps = app.GOOGLE_STATIC_MAPS_API_KEY;

    app.load_env();

    assertEquals(firstTerraintap, app.TERRAINTAP_API_KEY);
    assertEquals(firstGoogleMaps, app.GOOGLE_STATIC_MAPS_API_KEY);
  }
}
