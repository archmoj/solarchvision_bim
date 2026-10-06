import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class Earth3DTest {

  private solarchvision_bim app;
  private solarchvision_bim.Earth3D earth;

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

    solarchvision_bim.Earth3D fresh = app.new Earth3D();
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

  // ================= buildVertex / buildSubFace / buildStationVertex ====
  // Simpler than Sun3D.pde's/Moon3D.pde's own buildSubFace() tests: no
  // SkyFrame, no tA/tB, no tidal-locking construction at all here -
  // Earth's own texture is real geography, so it's deliberately NOT
  // re-oriented for the station/time the way the Sun's and Moon's are;
  // it's a plain, direct (Alpha, Beta) -> (u, v) mapping. The one thing
  // these still share with that pair: tb/ta rotate the model so the
  // STATION's own location sits at the origin - tested below via
  // buildStationVertex().
  //
  // Unlike Sun3D/Moon3D, computeElevationBump() (called unconditionally
  // by buildVertex() for every vertex, texture or not) reads a real pixel
  // from the loaded Earth texture - so, unlike those two, these specific
  // tests need load_images() first (a real, if small, cost the other
  // tests above have no reason to pay - kept local to the tests that
  // actually need it rather than added to the shared setUp()). That
  // surfaced a real, if incidental, blocker: it called Processing's own
  // green(c), which needs a live sketch surface (this.g) this app has no
  // other reason to require here - fixed in Earth3D.pde itself (see its
  // own comment there) by extracting the channel directly instead, which
  // also removes that dependency for the real app, not just for these
  // tests.

  private void loadRealEarthImages () {
    // BaseFolder/sketchPath() resolves wherever Processing's own CLI
    // build happens to run from, not this checkout - test/run_tests.sh
    // only cd's to the repo root before running (unlike
    // run_integration.sh/the image tests, which set up a junction for
    // exactly this), so user.dir is the reliable way to find the real,
    // bundled Earth texture from here.
    earth.Path = System.getProperty("user.dir") + "/input/images/earth";
    earth.resize_images();
    earth.load_images();
  }

  @Test
  void buildSubFace_returnsFourCorners_inTheEstablishedWindingOrder () {
    loadRealEarthImages();
    float latStep = earth.lat_step;
    float lonStep = earth.lon_step;

    solarchvision_bim.Earth3D.FaceVertex[] subFace = earth.buildSubFace(10, 20, 0, 0, 1, 1);

    float expectedU0 = 20f / 360f + 0.5f;
    float expectedV0 = -10f / 180f + 0.5f;
    float expectedU1 = (20 - lonStep) / 360f + 0.5f;
    float expectedV2 = -(10 - latStep) / 180f + 0.5f;

    assertEquals(expectedU0, subFace[0].u, 0.0001f, "corner 0: (Alpha, Beta) as given");
    assertEquals(expectedV0, subFace[0].v, 0.0001f);
    assertEquals(expectedU1, subFace[1].u, 0.0001f, "corner 1: Beta -= lon_step");
    assertEquals(expectedV0, subFace[1].v, 0.0001f, "corner 1: Alpha unchanged");
    assertEquals(expectedU1, subFace[2].u, 0.0001f, "corner 2: both -= step");
    assertEquals(expectedV2, subFace[2].v, 0.0001f);
    assertEquals(expectedU0, subFace[3].u, 0.0001f, "corner 3: Beta unchanged");
    assertEquals(expectedV2, subFace[3].v, 0.0001f, "corner 3: Alpha -= lat_step");
  }

  @Test
  void buildVertex_textureMapping_isADirectOffsetFromAlphaBeta_noRotationInvolved () {
    loadRealEarthImages();

    // Unlike Sun3D/Moon3D, there's no tidal-locking frame to account for
    // here - Alpha=0,Beta=0 should land exactly at the image center
    // (u=0.5,v=0.5) regardless of where the station is, since this
    // mapping is pinned to real geography, not to the station's view.
    solarchvision_bim.Earth3D.FaceVertex center = earth.buildVertex(0, 0, 0, 0, 1, 1);
    assertEquals(0.5f, center.u, 0.0001f);
    assertEquals(0.5f, center.v, 0.0001f);

    solarchvision_bim.Earth3D.FaceVertex quarterEast = earth.buildVertex(0, 90, 0, 0, 1, 1);
    assertEquals(0.75f, quarterEast.u, 0.0001f);
    assertEquals(0.5f, quarterEast.v, 0.0001f);
  }

  @Test
  void buildVertex_withTextureDisabled_leavesUVAtZero () {
    loadRealEarthImages();
    earth.displayTexture = false;

    solarchvision_bim.Earth3D.FaceVertex vtx = earth.buildVertex(10, 20, 0, 0, 1, 1);

    assertEquals(0f, vtx.u);
    assertEquals(0f, vtx.v);
  }

  @Test
  void buildVertex_inGlobalSolarOrVertexElevationShadingMode_alsoLeavesUVAtZero () {
    loadRealEarthImages();

    // showTexture() (see Earth3D.pde) turns the texture off in these two
    // shading modes specifically, even with displayTexture still true -
    // those modes color every face from the solar/elevation palette
    // instead, so the geography texture would never actually be seen.
    app.WIN3D.shadingMode = app.SHADE.Global_Solar;
    solarchvision_bim.Earth3D.FaceVertex globalSolar = earth.buildVertex(10, 20, 0, 0, 1, 1);
    assertEquals(0f, globalSolar.u);
    assertEquals(0f, globalSolar.v);

    app.WIN3D.shadingMode = app.SHADE.Vertex_Elevation;
    solarchvision_bim.Earth3D.FaceVertex vertexElevation = earth.buildVertex(10, 20, 0, 0, 1, 1);
    assertEquals(0f, vertexElevation.u);
    assertEquals(0f, vertexElevation.v);
  }

  @Test
  void buildStationVertex_putsXAndYNearTheOrigin_regardlessOfStationLocation () {
    loadRealEarthImages();

    // The whole point of tb/ta in buildVertex(): rotate so the station's
    // own (lat, lon) sits at the model's origin/orientation. Checked
    // across a spread of real stations (near the antimeridian too, since
    // that's where computeElevationBump()'s own longitude-wrapping
    // matters most), not just one - a couple of meters' tolerance on an
    // ~6,378,000m Earth radius, from the long double-precision rotation
    // chain in buildVertex() landing in a float at the end.
    float[][] stations = {
      {43.7f, -79.4f},   // Toronto
      {0f, 0f},          // equator / prime meridian
      {-33.9f, 151.2f},  // Sydney
      {89f, 0f},         // near the pole
      {21.3f, -157.9f},  // Honolulu - near the antimeridian
    };

    for (float[] station : stations) {
      app.STATION.latitude = station[0];
      app.STATION.longitude = station[1];

      solarchvision_bim.Earth3D.FaceVertex vtx = earth.buildStationVertex(0, 0, 1, 1);

      assertEquals(0f, vtx.x, 2f, "lat=" + station[0] + " lon=" + station[1]);
      assertEquals(0f, vtx.y, 2f, "lat=" + station[0] + " lon=" + station[1]);
    }
  }

  @Test
  void computeElevationBump_wrapsLongitudeFarOutsideTheImagesBoundaries () {
    loadRealEarthImages();

    float normal = earth.computeElevationBump(10, 20);
    float wrappedOnce = earth.computeElevationBump(10, 20 + 360);
    float wrappedTwice = earth.computeElevationBump(10, 20 - 720);

    assertEquals(normal, wrappedOnce, 0.0001f);
    assertEquals(normal, wrappedTwice, 0.0001f);
  }
}
