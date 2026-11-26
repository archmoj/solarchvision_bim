import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import processing.core.PShape;

class Sky3DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= shouldDraw ========================================

  @Test
  void shouldDraw_isFalseWhenDisplaySurfaceIsOffRegardlessOfWindow () {
    app.Sky3D.displaySurface = false;
    assertFalse(app.Sky3D.shouldDraw(app.TypeWindow.WIN3D));
  }

  @Test
  void shouldDraw_isFalseForStudyAndWorldWindowsEvenWhenVisible () {
    app.Sky3D.displaySurface = true;
    assertFalse(app.Sky3D.shouldDraw(app.TypeWindow.STUDY));
    assertFalse(app.Sky3D.shouldDraw(app.TypeWindow.WORLD));
  }

  @Test
  void shouldDraw_isTrueForAnOrdinaryVisibleWindow () {
    app.Sky3D.displaySurface = true;
    assertTrue(app.Sky3D.shouldDraw(app.TypeWindow.WIN3D));
  }

  // ================= activePalette =====================================

  @Test
  void activePalette_returnsTheActiveSetWhenImpactTypeIsActive () {
    app.WIN3D.impactTypeIndex = app.Impact_ACTIVE;
    app.Sky3D.activeColorScaleIndex = 5;
    app.Sky3D.activeColorScaleDirection = 1;
    app.Sky3D.activeColorScaleFactor = 0.5f;

    float[] result = app.Sky3D.activePalette();

    assertEquals(5f, result[0], 0.0001f);
    assertEquals(1f, result[1], 0.0001f);
    assertEquals(0.5f, result[2], 0.0001f);
  }

  @Test
  void activePalette_returnsThePassiveSetWhenImpactTypeIsPassive () {
    app.WIN3D.impactTypeIndex = app.Impact_PASSIVE;
    app.Sky3D.passiveColorScaleIndex = 8;
    app.Sky3D.passiveColorScaleDirection = -1;
    app.Sky3D.passiveColorScaleFactor = 0.25f;

    float[] result = app.Sky3D.activePalette();

    assertEquals(8f, result[0], 0.0001f);
    assertEquals(-1f, result[1], 0.0001f);
    assertEquals(0.25f, result[2], 0.0001f);
  }

  // ================= computeTessellatedSubFaces / caching ===============

  @Test
  void computeTessellatedSubFaces_atTessellationZeroReturnsTheFaceItselfUnitNormalized () {
    // These 3 points are already unit vectors, so normalization should
    // leave them unchanged - a clean way to confirm the pipeline (which
    // does normalize every sub-face vertex) without needing to hand-pick
    // a non-trivial normalization result.
    app.skyVertices = new float[][]{{1, 0, 0}, {0, 1, 0}, {0, 0, 1}};
    app.skyFaces = new int[][]{{0, 1, 2}};

    float[][][] subFaces = app.Sky3D.computeTessellatedSubFaces(0, 0);

    assertEquals(1, subFaces.length); // tessellation<=0 -> exactly 1 sub-face, the whole face
    assertArrayEquals(new float[]{1, 0, 0}, subFaces[0][0], 0.0001f);
    assertArrayEquals(new float[]{0, 1, 0}, subFaces[0][1], 0.0001f);
    assertArrayEquals(new float[]{0, 0, 1}, subFaces[0][2], 0.0001f);
  }

  @Test
  void getTessellatedSubFaces_cachesByTessellationLevelUntilItChanges () {
    app.skyVertices = new float[][]{{1, 0, 0}, {0, 1, 0}, {0, 0, 1}};
    app.skyFaces = new int[][]{{0, 1, 2}};

    float[][][] first = app.Sky3D.getTessellatedSubFaces(0, 0);
    float[][][] second = app.Sky3D.getTessellatedSubFaces(0, 0);
    assertSame(first, second); // same tessellation level -> served from cache, not recomputed

    float[][][] third = app.Sky3D.getTessellatedSubFaces(0, 1); // different tessellation -> cache rebuilt
    assertNotSame(first, third);
  }

  @Test
  void invalidateTessellationCache_forcesARebuildEvenAtTheSameTessellationLevel () {
    app.skyVertices = new float[][]{{1, 0, 0}, {0, 1, 0}, {0, 0, 1}};
    app.skyFaces = new int[][]{{0, 1, 2}};

    float[][][] first = app.Sky3D.getTessellatedSubFaces(0, 0);

    app.Sky3D.invalidateTessellationCache();
    float[][][] second = app.Sky3D.getTessellatedSubFaces(0, 0); // same level, but cache was invalidated

    assertNotSame(first, second);
  }

  // ================= to_XML / from_XML round trip ======================

  @Test
  void toXMLThenFromXML_roundTripsEveryField () {
    app.Sky3D.displaySurface = false;
    app.Sky3D.displayTessellation = 2;
    app.Sky3D.radius = 12345;
    app.Sky3D.activeColorScaleIndex = 5;
    app.Sky3D.activeColorScaleDirection = 1;
    app.Sky3D.activeColorScaleFactor = 0.5f;
    app.Sky3D.passiveColorScaleIndex = 8;
    app.Sky3D.passiveColorScaleDirection = -1;
    app.Sky3D.passiveColorScaleFactor = 0.25f;
    app.Sky3D.inclinationStep = 1.5f;
    app.Sky3D.orientationStep = 2.5f;
    app.Sky3D.inclinationCount = 4;
    app.Sky3D.orientationCount = 8;
    app.Sky3D.calculatedResolution = 5;

    processing.data.XML root = new processing.data.XML("root");
    app.Sky3D.to_XML(root);

    solarchvision_bim.Sky3D fresh = app.new Sky3D();
    fresh.from_XML(root);

    assertFalse(fresh.displaySurface);
    assertEquals(2, fresh.displayTessellation);
    assertEquals(12345f, fresh.radius, 0.0001f);
    assertEquals(5, fresh.activeColorScaleIndex);
    assertEquals(1, fresh.activeColorScaleDirection);
    assertEquals(0.5f, fresh.activeColorScaleFactor, 0.0001f);
    assertEquals(8, fresh.passiveColorScaleIndex);
    assertEquals(-1, fresh.passiveColorScaleDirection);
    assertEquals(0.25f, fresh.passiveColorScaleFactor, 0.0001f);
    assertEquals(1.5f, fresh.inclinationStep, 0.0001f);
    assertEquals(2.5f, fresh.orientationStep, 0.0001f);
    assertEquals(4, fresh.inclinationCount);
    assertEquals(8, fresh.orientationCount);
    assertEquals(5f, fresh.calculatedResolution, 0.0001f);
  }

  // ================= sunIsBelowHorizon / win3DCache sun-awareness ======
  // Drives cacheWriteDomeFlat()'s choice between flatColor and
  // nightFlatColor (black) - not directly tested here, since it's a
  // one-line fill-color pick inside PShape-building code in the same
  // untestable-headless category as the rest of this class's own
  // draw()-adjacent methods (see test/README.md). What's covered
  // instead: sunIsBelowHorizon() itself (a pure function of STATION/
  // SHADE_DATE_ANGLE/SHADE_HOUR_ANGLE), and that it's actually part of
  // the PShape cache's own key - without that, switching from day to
  // night wouldn't invalidate the cached dome at all, leaving it stuck
  // showing whatever color it was last built with.

  @Test
  void sunIsBelowHorizon_isFalseAtSolarNoon () {
    app.STATION.latitude = 0;
    app.SHADE_DATE_ANGLE = 0;
    app.SHADE_HOUR_ANGLE = 12;

    assertFalse(app.Sky3D.sunIsBelowHorizon());
  }

  @Test
  void sunIsBelowHorizon_isTrueAtSolarMidnight () {
    app.STATION.latitude = 0;
    app.SHADE_DATE_ANGLE = 0;
    app.SHADE_HOUR_ANGLE = 0;

    assertTrue(app.Sky3D.sunIsBelowHorizon());
  }

  @Test
  void win3DCache_isValid_invalidatesWhenTheSunCrossesTheHorizon () {
    app.STATION.latitude = 0;
    app.SHADE_DATE_ANGLE = 0;
    app.SHADE_HOUR_ANGLE = 12; // sun up

    // win3DCache_isValid() only null-checks this field - a bare PShape
    // (not app.createShape(), which may depend on a live renderer/
    // surface this headless test doesn't have) is enough to stand in for
    // "a cache already exists" without needing a real, drawable shape.
    app.Sky3D.win3DCache = new PShape();
    app.Sky3D.win3DCache_recordState(0, 1, 1);
    assertTrue(app.Sky3D.win3DCache_isValid(0, 1, 1));

    app.SHADE_HOUR_ANGLE = 0; // sun down now - nothing else changed

    assertFalse(app.Sky3D.win3DCache_isValid(0, 1, 1));
  }

  @Test
  void win3DCache_recordState_capturesTheCurrentSkyIsBlackValue () {
    app.STATION.latitude = 0;
    app.SHADE_DATE_ANGLE = 0;
    app.SHADE_HOUR_ANGLE = 12; // sun up

    app.Sky3D.win3DCache_recordState(0, 1, 1);

    assertFalse(app.Sky3D.win3DCache_skyIsBlack);
  }

  // ================= cameraIsOutsideAtmosphere / skyIsBlack ============
  // "In space" is the other way the sky reads as black, same as night -
  // see moon3D.pde's own request this was added for. WIN3D.
  // cameraPositionScaled() (viewport3D.pde) is what actually carries the
  // camera's real-world position here, already divided back down out of
  // overallScale into this class's own real units (radius, e.g.).

  @Test
  void cameraIsOutsideAtmosphere_isFalseWellInsideTheRadius () {
    app.overallScale = 1;
    app.WIN3D.cameraX = 0;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = app.Sky3D.radius * 0.5f;

    assertFalse(app.Sky3D.cameraIsOutsideAtmosphere());
  }

  @Test
  void cameraIsOutsideAtmosphere_isTrueWellBeyondTheRadius () {
    app.overallScale = 1;
    app.WIN3D.cameraX = 0;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = app.Sky3D.radius * 2;

    assertTrue(app.Sky3D.cameraIsOutsideAtmosphere());
  }

  @Test
  void cameraIsOutsideAtmosphere_dividesOutOverallScaleFirst () {
    // Same camera-space position as the "well beyond" test above, but
    // stored at a different overallScale - cameraPositionScaled() has to
    // divide that back out before comparing against radius (a real-
    // world distance), or this would wrongly read as outside (or
    // inside) depending on whatever overallScale the project happens to
    // be at, rather than the camera's actual real-world distance.
    app.overallScale = 100;
    app.WIN3D.cameraX = 0;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = app.Sky3D.radius * 2 * app.overallScale;

    assertTrue(app.Sky3D.cameraIsOutsideAtmosphere());

    app.WIN3D.cameraZ = app.Sky3D.radius * 0.5f * app.overallScale;

    assertFalse(app.Sky3D.cameraIsOutsideAtmosphere());
  }

  @Test
  void skyIsBlack_isTrueFromSpace_evenAtSolarNoon () {
    app.STATION.latitude = 0;
    app.SHADE_DATE_ANGLE = 0;
    app.SHADE_HOUR_ANGLE = 12; // sun up - sunIsBelowHorizon() alone is false
    app.overallScale = 1;
    app.WIN3D.cameraX = 0;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = app.Sky3D.radius * 2; // but the camera's left the atmosphere

    assertFalse(app.Sky3D.sunIsBelowHorizon());
    assertTrue(app.Sky3D.skyIsBlack());
    assertEquals(app.Sky3D.nightFlatColor, app.Sky3D.currentFlatColor());
  }

  @Test
  void win3DCache_isValid_invalidatesWhenTheCameraLeavesTheAtmosphere () {
    app.STATION.latitude = 0;
    app.SHADE_DATE_ANGLE = 0;
    app.SHADE_HOUR_ANGLE = 12; // sun up
    app.overallScale = 1;
    app.WIN3D.cameraX = 0;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = app.Sky3D.radius * 0.5f; // inside

    app.Sky3D.win3DCache = new PShape();
    app.Sky3D.win3DCache_recordState(0, 1, 1);
    assertTrue(app.Sky3D.win3DCache_isValid(0, 1, 1));

    app.WIN3D.cameraZ = app.Sky3D.radius * 2; // camera dollies out past the atmosphere - nothing else changed

    assertFalse(app.Sky3D.win3DCache_isValid(0, 1, 1));
  }
}
