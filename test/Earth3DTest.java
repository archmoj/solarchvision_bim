import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Exercises solarchvision_Earth3D (Earth3D.pde), reached through the
// pre-constructed `app.Earth3D` field.
//
// isStationGridCell()/isRoundGridLine()/unwrapLon() are already covered
// directly in EarthGridHelpersTest.java from an earlier session - not
// repeated here.
//
// NOT covered: resize_images()/load_images()/loadOneImage() (real
// loadImage() file reads), resolveTextureSource()/
// worldTileFullyCoversWindow()/useWorldTileDirectly()/
// compositeWorldTiles() (depend on WORLD's live tile file system on
// disk), and the whole draw()/rendering family (beginWIN3DSphere,
// addFaceWIN3D, addTriangleWIN3D, endWIN3DSphere, collectGridEdges,
// addGridEdge, flushEdgeBatch, writeMaterial, writeMTLHeader,
// writeTextureMap, drawFace, writeFaceHTML, writeFaceOBJ,
// writeOBJFaceIndices) - real WIN3D.graphics calls and/or real file
// output.
//
// ALSO not covered, discovered while writing this suite:
// computeElevationBump() (and everything that calls it -
// computeElevationBumpBilinear(), buildVertex(), buildSubFace(),
// buildStationVertex()). It calls PApplet.green(c) internally, which
// delegates to this.g (the sketch's primary PGraphics) to know the
// current color mode/range. A real running sketch sets this.g up
// through Processing's own setup()/draw() lifecycle; a bare
// `new solarchvision_bim()` never does, leaving it null, and
// PApplet.createGraphics() - the usual workaround for exercising
// Processing color utilities standalone - itself throws when this.g is
// null (it's implemented in terms of an already-existing primary
// graphics context, so it can't bootstrap one from nothing either).
// There's no pure-JUnit way to reach these functions without a live
// Processing surface, so - the same principle as every rendering
// function skipped elsewhere in this project - they're left untested
// here rather than worked around with something fragile.
//
// A fresh `app` per test since these mutate shared scene state.
class Earth3DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
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
}
