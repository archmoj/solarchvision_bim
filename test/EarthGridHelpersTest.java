import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

// Exercises the pure, deterministic grid-cell helpers in Earth3D.pde
// (solarchvision_Earth3D) directly - no window, no OpenGL/P3D context,
// no texture images loaded. See test/README.md for how this gets built
// and run.
//
// solarchvision_Earth3D is a non-static inner class - Processing's
// preprocessor turns every .pde tab's top-level `class solarchvision_X`
// into an inner class of the generated sketch class (solarchvision_bim),
// so building one needs a live sketch instance (`app.new
// solarchvision_Earth3D()`). Constructing solarchvision_bim() itself does
// NOT open a window or touch the GPU: the main tab's field initializers
// only build plain data-holder objects (STATION, LAYER, SHADE, WIN3D,
// ...); the actual graphics surfaces (createGraphics(..., P3D) etc.) are
// only created later, inside setup(), which these tests never call.
//
// isStationGridCell/isRoundGridLine/unwrapLon are declared
// package-private (not private) in Earth3D.pde specifically so this test
// class - deliberately left in the same (default/unnamed) package as the
// generated sketch class - can call them directly, with no reflection.
class EarthGridHelpersTest {

  private static solarchvision_bim app;
  private static solarchvision_bim.solarchvision_Earth3D earth;

  @BeforeAll
  static void setUp () {
    app = new solarchvision_bim();
    earth = app.new solarchvision_Earth3D();
  }

  // --- isStationGridCell ----------------------------------------------

  @Test
  void isStationGridCell_matchesTheCellContainingTheStation () {
    float stationLat = 45.47f;  // the default (Toronto) station's own coords
    float stationLon = -73.75f; // are close enough to another city's for a
                                 // clear, non-edge-case test point

    float latStep = earth.lat_step;
    float lonStep = earth.lon_step;

    // Same alphaTop/betaRight cell math Earth3D itself uses (see
    // computeElevationBumpBilinear() and isStationGridCell()).
    float alphaTop  = 90  - (float) Math.floor((90  - stationLat) / latStep) * latStep;
    float betaRight = 180 - (float) Math.floor((180 - stationLon) / lonStep) * lonStep;

    assertTrue(earth.isStationGridCell(alphaTop, betaRight, stationLat, stationLon));
  }

  @Test
  void isStationGridCell_rejectsTheNeighboringCells () {
    float stationLat = 45.47f;
    float stationLon = -73.75f;

    float latStep = earth.lat_step;
    float lonStep = earth.lon_step;

    float alphaTop  = 90  - (float) Math.floor((90  - stationLat) / latStep) * latStep;
    float betaRight = 180 - (float) Math.floor((180 - stationLon) / lonStep) * lonStep;

    assertFalse(earth.isStationGridCell(alphaTop + latStep, betaRight, stationLat, stationLon));
    assertFalse(earth.isStationGridCell(alphaTop - latStep, betaRight, stationLat, stationLon));
    assertFalse(earth.isStationGridCell(alphaTop, betaRight + lonStep, stationLat, stationLon));
    assertFalse(earth.isStationGridCell(alphaTop, betaRight - lonStep, stationLat, stationLon));
  }

  // --- isRoundGridLine --------------------------------------------------

  @Test
  void isRoundGridLine_acceptsExactAndNegativeMultiplesOfStep () {
    assertTrue(earth.isRoundGridLine(5f, 1f));
    assertTrue(earth.isRoundGridLine(-12f, 1f));
    assertTrue(earth.isRoundGridLine(0f, 1f));
    assertTrue(earth.isRoundGridLine(4f, 2f));
  }

  @Test
  void isRoundGridLine_rejectsNonMultiples () {
    assertFalse(earth.isRoundGridLine(5.5f, 1f));
    assertFalse(earth.isRoundGridLine(3f, 2f));
  }

  @Test
  void isRoundGridLine_treatsNonPositiveStepAsNeverRound () {
    assertFalse(earth.isRoundGridLine(0f, 0f));
    assertFalse(earth.isRoundGridLine(3f, -1f));
  }

  // --- unwrapLon ----------------------------------------------------

  @Test
  void unwrapLon_leavesNearbyLongitudesUnchanged () {
    assertEquals(10f, earth.unwrapLon(10f, 5f), 0.0001f);
  }

  @Test
  void unwrapLon_wrapsWestwardAcrossTheAntimeridian () {
    // A tile edge at -179 is only 2deg west of a station at +179 going
    // the short way across the seam, not 358deg away in raw degrees.
    float unwrapped = earth.unwrapLon(-179f, 179f);
    assertEquals(181f, unwrapped, 0.0001f);
  }

  @Test
  void unwrapLon_wrapsEastwardAcrossTheAntimeridian () {
    float unwrapped = earth.unwrapLon(179f, -179f);
    assertEquals(-181f, unwrapped, 0.0001f);
  }
}
