import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class Earth3DTest {

  private solarchvision_bim app;
  private solarchvision_bim.solarchvision_Earth3D earth;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    earth = app.Earth3D;
  }

  // ================= recomputeLevelOfDetailDependents ====================

  @Test
  void recomputeLevelOfDetailDependents_derivesClipRadiusAndStepFromLevelOfDetail () {
    app.STATION.latitude = 0; // keeps computeClipRadiusDegreesLon's cos_ang(0)=1 simple
    app.Earth3D.levelOfDetail = 2;

    app.Earth3D.recomputeLevelOfDetailDependents();

    assertEquals(2f, app.Earth3D.clipRadiusDegrees_Lat, 0.0001f); // 4.0 / 2
    assertEquals(2f / 32f, app.Earth3D.lat_step, 0.0001f);
    assertEquals(2f / 32f, app.Earth3D.lon_step, 0.0001f);
    // At the equator, computeClipRadiusDegreesLon just rounds clipRadiusDegrees_Lat.
    assertEquals(2f, app.Earth3D.clipRadiusDegrees_Lon, 0.0001f);
  }

  // ================= clamp01 ============================================

  @Test
  void clamp01_clampsToTheUnitRange () {
    assertEquals(0f, app.Earth3D.clamp01(-0.5f), 0.0001f);
    assertEquals(0.5f, app.Earth3D.clamp01(0.5f), 0.0001f);
    assertEquals(1f, app.Earth3D.clamp01(1.5f), 0.0001f);
  }

  // ================= shouldDraw =========================================

  @Test
  void shouldDraw_isFalseWhenDisplaySurfaceIsOffOrForStudyAndWorld () {
    app.Earth3D.displaySurface = false;
    assertFalse(app.Earth3D.shouldDraw(app.TypeWindow.WIN3D));

    app.Earth3D.displaySurface = true;
    assertFalse(app.Earth3D.shouldDraw(app.TypeWindow.STUDY));
    assertFalse(app.Earth3D.shouldDraw(app.TypeWindow.WORLD));
    assertTrue(app.Earth3D.shouldDraw(app.TypeWindow.WIN3D));
  }

  // ================= computeClipRadiusDegreesLon ========================

  @Test
  void computeClipRadiusDegreesLon_growsWithLatitudeAndIsClampedTo180 () {
    app.Earth3D.clipRadiusDegrees_Lat = 4;

    assertEquals(4f, app.Earth3D.computeClipRadiusDegreesLon(0), 0.001f); // cos(0)=1 -> unchanged
    // Near a pole, dividing by a tiny cos_ang would blow up - clamped to 180 instead.
    assertEquals(180f, app.Earth3D.computeClipRadiusDegreesLon(89.99f), 0.001f);
  }

  @Test
  void computeClipRadiusDegreesLon_isAtLeastOne () {
    app.Earth3D.clipRadiusDegrees_Lat = 0.001f;
    assertEquals(1f, app.Earth3D.computeClipRadiusDegreesLon(0), 0.001f);
  }

  // ================= to_XML / from_XML round trip ========================

  @Test
  void toXMLThenFromXML_roundTripsDisplaySettingsAndRecomputesDependents () {
    app.Earth3D.displaySurface = false;
    app.Earth3D.displayTexture = false;
    app.Earth3D.levelOfDetail = 2;

    processing.data.XML root = new processing.data.XML("root");
    app.Earth3D.to_XML(root);

    solarchvision_bim.solarchvision_Earth3D fresh = app.new solarchvision_Earth3D();
    fresh.from_XML(root);

    assertFalse(fresh.displaySurface);
    assertFalse(fresh.displayTexture);
    assertEquals(2f, fresh.levelOfDetail, 0.0001f);
    // from_XML calls recomputeLevelOfDetailDependents() itself, so the
    // dependent fields reflect the LOADED levelOfDetail, not whatever
    // the fresh instance's constructor originally computed for its own
    // default levelOfDetail.
    assertEquals(2f, fresh.clipRadiusDegrees_Lat, 0.0001f); // 4.0 / 2
  }

  // ================= isStationGridCell ====================================

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

  // ================= isRoundGridLine ======================================

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

  // ================= unwrapLon ============================================

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
