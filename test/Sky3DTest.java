import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

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
    app.WIN3D.Impact_TYPE = app.Impact_ACTIVE;
    app.Sky3D.ACTIVE_palette_CLR = 5;
    app.Sky3D.ACTIVE_palette_DIR = 1;
    app.Sky3D.ACTIVE_palette_MLT = 0.5f;

    float[] result = app.Sky3D.activePalette();

    assertEquals(5f, result[0], 0.0001f);
    assertEquals(1f, result[1], 0.0001f);
    assertEquals(0.5f, result[2], 0.0001f);
  }

  @Test
  void activePalette_returnsThePassiveSetWhenImpactTypeIsPassive () {
    app.WIN3D.Impact_TYPE = app.Impact_PASSIVE;
    app.Sky3D.PASSIVE_palette_CLR = 8;
    app.Sky3D.PASSIVE_palette_DIR = -1;
    app.Sky3D.PASSIVE_palette_MLT = 0.25f;

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
    app.Sky3D.ACTIVE_palette_CLR = 5;
    app.Sky3D.ACTIVE_palette_DIR = 1;
    app.Sky3D.ACTIVE_palette_MLT = 0.5f;
    app.Sky3D.PASSIVE_palette_CLR = 8;
    app.Sky3D.PASSIVE_palette_DIR = -1;
    app.Sky3D.PASSIVE_palette_MLT = 0.25f;
    app.Sky3D.stp_slp = 1.5f;
    app.Sky3D.stp_dir = 2.5f;
    app.Sky3D.num_slp = 4;
    app.Sky3D.num_dir = 8;
    app.Sky3D.calculatedResolution = 5;

    processing.data.XML root = new processing.data.XML("root");
    app.Sky3D.to_XML(root);

    solarchvision_bim.Sky3D fresh = app.new Sky3D();
    fresh.from_XML(root);

    assertFalse(fresh.displaySurface);
    assertEquals(2, fresh.displayTessellation);
    assertEquals(12345f, fresh.radius, 0.0001f);
    assertEquals(5, fresh.ACTIVE_palette_CLR);
    assertEquals(1, fresh.ACTIVE_palette_DIR);
    assertEquals(0.5f, fresh.ACTIVE_palette_MLT, 0.0001f);
    assertEquals(8, fresh.PASSIVE_palette_CLR);
    assertEquals(-1, fresh.PASSIVE_palette_DIR);
    assertEquals(0.25f, fresh.PASSIVE_palette_MLT, 0.0001f);
    assertEquals(1.5f, fresh.stp_slp, 0.0001f);
    assertEquals(2.5f, fresh.stp_dir, 0.0001f);
    assertEquals(4, fresh.num_slp);
    assertEquals(8, fresh.num_dir);
    assertEquals(5f, fresh.calculatedResolution, 0.0001f);
  }
}
