import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// The simplest of the four buildSubFace()s tested this session (see
// Sun3DTest.java, Moon3DTest.java, Earth3DTest.java): same tb/ta
// station-centering as Earth3D.pde, same plain unrotated texture mapping
// (this is a weather-data overlay tied to real lat/lon, same reasoning as
// Earth's own geography - not a celestial body needing tidal locking), but
// with no separate buildVertex() helper and, unlike Earth3D.pde, no
// per-vertex pixel sampling (no computeElevationBump() equivalent at all -
// the shell sits at one constant altitude) - so no load_images()/no
// graphics-context blocker to work around here; directly callable with no
// extra setup.
class Tropo3DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  private float tropoRadius () {
    return app.FLOAT_r_Earth + app.Tropo3D.TROPOSPHERE_ALTITUDE_M;
  }

  // ================= corner winding =============================================

  @Test
  void buildSubFace_returnsFourCorners_inTheEstablishedWindingOrder () {
    float latStep = app.Tropo3D.lat_step;
    float lonStep = app.Tropo3D.lon_step;

    solarchvision_bim.Tropo3D.FaceVertex[] subFace = app.Tropo3D.buildSubFace(10, 20, tropoRadius(), 0, 0, 1, 1);

    assertEquals(10f, subFace[0].lat, 0.0001f, "corner 0: (Alpha, Beta) as given");
    assertEquals(20f, subFace[0].lon, 0.0001f);
    assertEquals(10f, subFace[1].lat, 0.0001f, "corner 1: Alpha unchanged");
    assertEquals(20 - lonStep, subFace[1].lon, 0.0001f, "corner 1: Beta -= lon_step");
    assertEquals(10 - latStep, subFace[2].lat, 0.0001f, "corner 2: both -= step");
    assertEquals(20 - lonStep, subFace[2].lon, 0.0001f);
    assertEquals(10 - latStep, subFace[3].lat, 0.0001f, "corner 3: Alpha -= lat_step");
    assertEquals(20f, subFace[3].lon, 0.0001f, "corner 3: Beta unchanged");
  }

  // ================= texture mapping: direct, unrotated =========================

  @Test
  void buildSubFace_textureMapping_isADirectOffsetFromAlphaBeta_noRotationInvolved () {
    // Same reasoning as Earth3DTest.java's equivalent test: Alpha=0,Beta=0
    // lands exactly at the image center regardless of where the station
    // is - this mapping is pinned to real geography/weather data, not to
    // the station's view, so there's no tidal-locking frame here at all.
    solarchvision_bim.Tropo3D.FaceVertex[] center = app.Tropo3D.buildSubFace(0, 0, tropoRadius(), 0, 0, 1, 1);
    assertEquals(0.5f, center[0].u, 0.0001f);
    assertEquals(0.5f, center[0].v, 0.0001f);

    solarchvision_bim.Tropo3D.FaceVertex[] quarterEast = app.Tropo3D.buildSubFace(0, 90, tropoRadius(), 0, 0, 1, 1);
    assertEquals(0.75f, quarterEast[0].u, 0.0001f);
    assertEquals(0.5f, quarterEast[0].v, 0.0001f);
  }

  @Test
  void buildSubFace_withTextureDisabled_leavesUVAtZero () {
    app.Tropo3D.displayTexture = false;

    solarchvision_bim.Tropo3D.FaceVertex[] subFace = app.Tropo3D.buildSubFace(10, 20, tropoRadius(), 0, 0, 1, 1);

    assertEquals(0f, subFace[0].u);
    assertEquals(0f, subFace[0].v);
  }

  // ================= station-centering ===========================================

  @Test
  void buildSubFace_atTheStationsOwnCoordinates_centersOnTheStationAtTheShellAltitude () {
    // Same tb/ta construction as Earth3D.pde: rotates so the station's own
    // (lat, lon) sits at the model's origin/orientation. Checked with
    // Alpha/Beta set to the station's own coordinates, so corner 0 (which
    // uses them unmodified - see the winding test above) is the point
    // directly overhead. A few meters' tolerance (a bit more than
    // Earth3DTest.java's: this class works in float throughout, not
    // double, so the rotation chain accumulates slightly more error) on
    // an ~6,378,000m Earth radius and a 10,000m shell altitude.
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

      solarchvision_bim.Tropo3D.FaceVertex[] subFace =
          app.Tropo3D.buildSubFace(station[0], station[1], tropoRadius(), 0, 0, 1, 1);

      String label = "lat=" + station[0] + " lon=" + station[1];
      assertEquals(0f, subFace[0].x, 2f, label);
      assertEquals(0f, subFace[0].y, 2f, label);
      assertEquals(app.Tropo3D.TROPOSPHERE_ALTITUDE_M, subFace[0].z, 2f, label);
    }
  }

  // ================= allUVsInRange ===============================================

  @Test
  void allUVsInRange_trueInsideTheTileFalseFarOutside () {
    // Matches how draw() actually calls this: each image tile covers only
    // a narrow slice of the globe (its own BoundariesX/Y, here stood in
    // for with a 36deg-wide tile via ScaleX/ScaleY=0.1), not the full
    // -180..180 range - so a point outside that tile's own span needs to
    // actually be far from CEN_lon/CEN_lat to fall out of [0,1], not just
    // anywhere outside -180..180.
    solarchvision_bim.Tropo3D.FaceVertex[] inside = app.Tropo3D.buildSubFace(0, 0, tropoRadius(), 0, 0, 0.1f, 0.1f);
    assertTrue(app.Tropo3D.allUVsInRange(inside));

    solarchvision_bim.Tropo3D.FaceVertex[] outside = app.Tropo3D.buildSubFace(0, 170, tropoRadius(), 0, 0, 0.1f, 0.1f);
    assertFalse(app.Tropo3D.allUVsInRange(outside));
  }
}
