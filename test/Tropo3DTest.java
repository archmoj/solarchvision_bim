import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.io.IOException;

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

  // ================= advanceHourForward / advanceHourBackward ===================
  // Plain date-rollover arithmetic - no file I/O, no graphics, so directly
  // testable with no setup at all (unlike buildSubFace() above, where the
  // class being otherwise simple is exactly what makes it testable without
  // extra workarounds - this is the same story one level further).

  private solarchvision_bim.Tropo3D.DateTimeUTC dateTime (int year, int month, int day, int hour) {
    solarchvision_bim.Tropo3D.DateTimeUTC dt = app.Tropo3D.new DateTimeUTC();
    dt.year = year;
    dt.month = month;
    dt.day = day;
    dt.hour = hour;
    return dt;
  }

  @Test
  void advanceHourForward_byItself_justIncrementsTheHour () {
    solarchvision_bim.Tropo3D.DateTimeUTC dt = dateTime(2026, 6, 15, 10);

    app.Tropo3D.advanceHourForward(dt);

    assertEquals(11, dt.hour);
    assertEquals(15, dt.day);
    assertEquals(6, dt.month);
    assertEquals(2026, dt.year);
  }

  @Test
  void advanceHourForward_atTheEndOfADay_rollsIntoTheNextDay () {
    solarchvision_bim.Tropo3D.DateTimeUTC dt = dateTime(2026, 6, 15, 23);

    app.Tropo3D.advanceHourForward(dt);

    assertEquals(0, dt.hour);
    assertEquals(16, dt.day);
    assertEquals(6, dt.month);
  }

  @Test
  void advanceHourForward_attheEndOfAMonth_rollsIntoTheNextMonth () {
    // June has 30 days (see TIME.lengthOfMonths).
    solarchvision_bim.Tropo3D.DateTimeUTC dt = dateTime(2026, 6, 30, 23);

    app.Tropo3D.advanceHourForward(dt);

    assertEquals(0, dt.hour);
    assertEquals(1, dt.day);
    assertEquals(7, dt.month);
    assertEquals(2026, dt.year);
  }

  @Test
  void advanceHourForward_atTheEndOfTheYear_rollsIntoTheNextYear () {
    solarchvision_bim.Tropo3D.DateTimeUTC dt = dateTime(2026, 12, 31, 23);

    app.Tropo3D.advanceHourForward(dt);

    assertEquals(0, dt.hour);
    assertEquals(1, dt.day);
    assertEquals(1, dt.month);
    assertEquals(2027, dt.year);
  }

  @Test
  void advanceHourBackward_byItself_justDecrementsTheHour () {
    solarchvision_bim.Tropo3D.DateTimeUTC dt = dateTime(2026, 6, 15, 10);

    app.Tropo3D.advanceHourBackward(dt);

    assertEquals(9, dt.hour);
    assertEquals(15, dt.day);
    assertEquals(6, dt.month);
  }

  @Test
  void advanceHourBackward_atTheStartOfADay_rollsIntoThePreviousDay () {
    solarchvision_bim.Tropo3D.DateTimeUTC dt = dateTime(2026, 6, 15, 0);

    app.Tropo3D.advanceHourBackward(dt);

    assertEquals(23, dt.hour);
    assertEquals(14, dt.day);
    assertEquals(6, dt.month);
  }

  @Test
  void advanceHourBackward_atTheStartOfAMonth_rollsIntoThePreviousMonth () {
    // Confirmed by hand against the real compiled app before fixing this:
    // the original "if (dt.day < 0)" check left day sitting at the
    // otherwise-invalid value 0 instead of rolling over, since days are
    // 1..lengthOfMonths[month-1] (see TIME.pde) and decrementing from 1
    // lands exactly on 0, never below it. February has 28 days here (see
    // TIME.lengthOfMonths - no leap-year handling in this app).
    solarchvision_bim.Tropo3D.DateTimeUTC dt = dateTime(2026, 3, 1, 0);

    app.Tropo3D.advanceHourBackward(dt);

    assertEquals(23, dt.hour);
    assertEquals(28, dt.day);
    assertEquals(2, dt.month);
    assertEquals(2026, dt.year);
  }

  @Test
  void advanceHourBackward_atTheStartOfTheYear_rollsIntoThePreviousYear () {
    // Same off-by-one, one level up: months are 1..12, so this is the
    // "month lands exactly on 0" case for the year boundary specifically
    // - confirmed by hand that fixing only the day check above, without
    // this one too, would have made this case throw
    // (TIME.lengthOfMonths[month - 1] indexing at [-1]) instead of
    // silently producing an invalid date.
    solarchvision_bim.Tropo3D.DateTimeUTC dt = dateTime(2026, 1, 1, 0);

    app.Tropo3D.advanceHourBackward(dt);

    assertEquals(23, dt.hour);
    assertEquals(31, dt.day);
    assertEquals(12, dt.month);
    assertEquals(2025, dt.year);
  }

  // ================= buildDomainStamp / buildParameterStamp =====================

  @Test
  void buildDomainStamp_dependsOnWMS_type () {
    app.WMS_type = app.DataType.SATELLITE_GOES;
    assertEquals("east_vis_1km", app.Tropo3D.buildDomainStamp());

    app.WMS_type = app.DataType.FORECAST_HRDPS;
    assertEquals("HRDPS.CONTINENTAL", app.Tropo3D.buildDomainStamp());

    app.WMS_type = app.DataType.FORECAST_RDPS;
    assertEquals("RDPS.ETA", app.Tropo3D.buildDomainStamp());

    app.WMS_type = app.DataType.FORECAST_GDPS;
    assertEquals("GDPS.ETA", app.Tropo3D.buildDomainStamp());
  }

  @Test
  void buildParameterStamp_isEmptyForSatelliteGOES_cloudCoverOtherwise () {
    app.WMS_type = app.DataType.SATELLITE_GOES;
    assertEquals("", app.Tropo3D.buildParameterStamp());

    app.WMS_type = app.DataType.FORECAST_HRDPS;
    assertEquals("_NT&STYLES=CLOUD", app.Tropo3D.buildParameterStamp());
  }

  // ================= computeDownloadBoundaries ===================================

  @Test
  void computeDownloadBoundaries_centersOnTheStation_latSpanNarrowedByCosLatitude () {
    app.STATION.latitude = 43.7f;
    app.STATION.longitude = -79.4f;
    app.Tropo3D.resize_images();

    app.Tropo3D.computeDownloadBoundaries(0);

    assertEquals(-84.4f, app.Tropo3D.BoundariesX[0][0], 0.001f);
    assertEquals(-74.4f, app.Tropo3D.BoundariesX[0][1], 0.001f);
    // TROPO_BOUNDARY_HALF_SPAN * cos(43.7deg) - narrower in latitude than
    // in longitude, same reasoning as a degree of longitude covering less
    // real distance than a degree of latitude away from the equator.
    float expectedHalfSpanLat = app.Tropo3D.TROPO_BOUNDARY_HALF_SPAN * app.funcs.cos_ang(43.7f);
    assertEquals(43.7f - expectedHalfSpanLat, app.Tropo3D.BoundariesY[0][0], 0.001f);
    assertEquals(43.7f + expectedHalfSpanLat, app.Tropo3D.BoundariesY[0][1], 0.001f);
  }

  // ================= buildRequestUrl / buildLocalFilename ========================

  @Test
  void buildRequestUrl_includesLayerBoundsAndTime () {
    app.STATION.latitude = 43.7f;
    app.STATION.longitude = -79.4f;
    app.Tropo3D.resize_images();
    app.Tropo3D.computeDownloadBoundaries(0);
    app.WMS_type = app.DataType.FORECAST_HRDPS;

    solarchvision_bim.Tropo3D.DateTimeUTC dt = dateTime(2026, 10, 6, 14);
    String url = app.Tropo3D.buildRequestUrl(app.Tropo3D.buildDomainStamp(), app.Tropo3D.buildParameterStamp(), dt, 0);

    assertTrue(url.startsWith("https://geo.weather.gc.ca/geomet?"), url);
    assertTrue(url.contains("LAYERS=HRDPS.CONTINENTAL_NT&STYLES=CLOUD"), url);
    assertTrue(url.contains("BBOX=40.085,-84.400,47.315,-74.400"), url);
    assertTrue(url.contains("&TIME=2026-10-06T14:00:00Z"), url);
  }

  @Test
  void buildRequestUrl_forSatelliteGOES_usesADifferentServiceAndDateFormat () {
    app.STATION.latitude = 43.7f;
    app.STATION.longitude = -79.4f;
    app.Tropo3D.resize_images();
    app.Tropo3D.computeDownloadBoundaries(0);
    app.WMS_type = app.DataType.SATELLITE_GOES;

    solarchvision_bim.Tropo3D.DateTimeUTC dt = dateTime(2026, 10, 6, 14);
    String url = app.Tropo3D.buildRequestUrl(app.Tropo3D.buildDomainStamp(), app.Tropo3D.buildParameterStamp(), dt, 0);

    assertTrue(url.startsWith("https://mesonet.agron.iastate.edu/cgi-bin/wms/goes/east_vis.cgi?"), url);
    // buildRequestUrl() always prepends "&TIME=" before appending its own
    // timeStamp, and the SATELLITE_GOES branch's timeStamp itself already
    // starts with "&DATE=..." - so this is genuinely "&TIME=&DATE=...",
    // not a typo; confirmed against the real compiled app before writing
    // this assertion, since it looks easy to get wrong by just reasoning
    // about it on paper.
    assertTrue(url.contains("&TIME=&DATE=2026-10-06&time=14:00:00:00Z"), url);
  }

  @Test
  void buildLocalFilename_encodesHourAndBoundariesInMillidegrees () {
    app.STATION.latitude = 43.7f;
    app.STATION.longitude = -79.4f;
    app.Tropo3D.resize_images();
    app.Tropo3D.computeDownloadBoundaries(0);

    solarchvision_bim.Tropo3D.DateTimeUTC dt = dateTime(2026, 10, 6, 14);
    String fn = app.Tropo3D.buildLocalFilename(0, 0, dt);

    assertEquals("14_084400_040085_074400_047315_.png", fn);
  }

  // ================= resize_images / resetSlot ====================================

  @Test
  void resizeImages_allocatesEmptyPlaceholderSlots () {
    app.Tropo3D.resize_images();

    assertEquals(app.TROPO_timeSteps, app.Tropo3D.Filenames.length);
    assertEquals("", app.Tropo3D.Filenames[0]);
    assertEquals(2, app.Tropo3D.Map[0].width);
    assertEquals(2, app.Tropo3D.Map[0].height);
    assertEquals(0f, app.Tropo3D.BoundariesX[0][0]);
    assertEquals(0f, app.Tropo3D.BoundariesX[0][1]);
    assertEquals(0f, app.Tropo3D.BoundariesY[0][0]);
    assertEquals(0f, app.Tropo3D.BoundariesY[0][1]);
  }

  // ================= shouldDraw / clamp01 ==========================================

  @Test
  void shouldDraw_isFalseWhenDisplaySurfaceOrDisplayTextureIsOffOrForStudy () {
    app.Tropo3D.displaySurface = true;
    app.Tropo3D.displayTexture = true;
    assertTrue(app.Tropo3D.shouldDraw(app.TypeWindow.WIN3D));

    app.Tropo3D.displaySurface = false;
    assertFalse(app.Tropo3D.shouldDraw(app.TypeWindow.WIN3D));

    app.Tropo3D.displaySurface = true;
    app.Tropo3D.displayTexture = false;
    assertFalse(app.Tropo3D.shouldDraw(app.TypeWindow.WIN3D));

    app.Tropo3D.displayTexture = true;
    assertFalse(app.Tropo3D.shouldDraw(app.TypeWindow.STUDY));
  }

  @Test
  void clamp01_clampsToTheUnitRange () {
    assertEquals(0f, app.Tropo3D.clamp01(-0.5f), 0.0001f);
    assertEquals(0.5f, app.Tropo3D.clamp01(0.5f), 0.0001f);
    assertEquals(1f, app.Tropo3D.clamp01(1.5f), 0.0001f);
  }

  // ================= to_XML / from_XML round trip ==================================

  @Test
  void toXMLThenFromXML_roundTripsDisplaySettings () {
    app.Tropo3D.displaySurface = true;
    app.Tropo3D.displayTexture = false;

    processing.data.XML root = new processing.data.XML("root");
    app.Tropo3D.to_XML(root);

    solarchvision_bim.Tropo3D fresh = app.new Tropo3D();
    fresh.from_XML(root);

    assertTrue(fresh.displaySurface);
    assertFalse(fresh.displayTexture);
  }

  // ================= recolorCloudLayer / recolorSatelliteVisibility ===============
  // Both read/write real files (no this.g/graphics-context dependency
  // this time - they use plain bit-shifting on the pixel color, not
  // Processing's red()/green()/blue(), so none of the Earth3D.pde-style
  // blocker applies here). Their loop bound is hardcoded to
  // TROPO_DOWNLOAD_WIDTH*TROPO_DOWNLOAD_HEIGHT - matching what the real
  // download endpoint always actually returns - not the image's own
  // dimensions, confirmed the hard way (a too-small test image throws
  // ArrayIndexOutOfBoundsException), so the fixture has to actually be
  // that size.

  private Path makeTestImage (int[] pixelArgb) throws IOException {
    int w = app.Tropo3D.TROPO_DOWNLOAD_WIDTH, h = app.Tropo3D.TROPO_DOWNLOAD_HEIGHT;
    processing.core.PImage img = app.createImage(w, h, processing.core.PConstants.ARGB);
    img.loadPixels();
    for (int i = 0; i < img.pixels.length; i++) {
      img.pixels[i] = (i < pixelArgb.length) ? pixelArgb[i] : app.color(0, 0, 0, 255);
    }
    img.updatePixels();
    Path path = Files.createTempFile("tropo-recolor-test", ".png");
    img.save(path.toString());
    return path;
  }

  @Test
  void recolorCloudLayer_transparentStaysTransparent_opaqueBecomesInvertedGrayscaleAlpha () throws IOException {
    Path path = makeTestImage(new int[]{
      app.color(100, 50, 25, 0),   // alpha 0 -> fully transparent, regardless of color
      app.color(200, 50, 25, 255), // alpha 255, red 200
    });

    app.Tropo3D.recolorCloudLayer(path.toString());

    processing.core.PImage result = app.loadImage(path.toString());
    result.loadPixels();

    int p0 = result.pixels[0];
    assertEquals(0, (p0 >> 24) & 0xFF, "alpha"); // color(0, 0): black, fully transparent

    int p1 = result.pixels[1];
    assertEquals(200, (p1 >> 24) & 0xFF, "alpha - the original red channel becomes the new alpha");
    assertEquals(230, (p1 >> 16) & 0xFF, "red");   // 255 - 0.125*200 = 230
    assertEquals(230, (p1 >> 8) & 0xFF, "green");  // color(gray, alpha): r=g=b
    assertEquals(230, p1 & 0xFF, "blue");
  }

  @Test
  void recolorSatelliteVisibility_dimPixelsBecomeFixedLightBlue_brightPixelsInvertToGrayscale () throws IOException {
    Path path = makeTestImage(new int[]{
      app.color(50, 0, 0, 255),  // red 50 < 255/3 - dim
      app.color(200, 0, 0, 255), // red 200 >= 255/3 - bright
    });

    app.Tropo3D.recolorSatelliteVisibility(path.toString());

    processing.core.PImage result = app.loadImage(path.toString());
    result.loadPixels();

    int p0 = result.pixels[0];
    assertEquals(191, (p0 >> 16) & 0xFF, "red");
    assertEquals(191, (p0 >> 8) & 0xFF, "green");
    assertEquals(255, p0 & 0xFF, "blue");
    assertEquals(255, (p0 >> 24) & 0xFF, "alpha");

    int p1 = result.pixels[1];
    int expectedGray = (int) ((255 - 200) * 3f / 2f); // (255-colValue)*n/(n-1), n=3
    assertEquals(expectedGray, (p1 >> 16) & 0xFF, "red");
    assertEquals(expectedGray, (p1 >> 8) & 0xFF, "green");
    assertEquals(expectedGray, p1 & 0xFF, "blue");
    assertEquals(255, (p1 >> 24) & 0xFF, "alpha");
  }
}
