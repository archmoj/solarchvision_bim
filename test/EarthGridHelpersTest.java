import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

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
