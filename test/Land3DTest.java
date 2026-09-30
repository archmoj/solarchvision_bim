import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class TerrainTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= shouldDraw ========================================

  @Test
  void shouldDraw_isFalseWhenDisplaySurfaceOrLoadMeshIsOff () {
    app.Terrain.displaySurface = false;
    app.Terrain.loadMesh = true;
    assertFalse(app.Terrain.shouldDraw(app.TypeWindow.WIN3D));

    app.Terrain.displaySurface = true;
    app.Terrain.loadMesh = false;
    assertFalse(app.Terrain.shouldDraw(app.TypeWindow.WIN3D));
  }

  @Test
  void shouldDraw_isFalseForStudyAndWorldWindows () {
    app.Terrain.displaySurface = true;
    app.Terrain.loadMesh = true;
    assertFalse(app.Terrain.shouldDraw(app.TypeWindow.STUDY));
    assertFalse(app.Terrain.shouldDraw(app.TypeWindow.WORLD));
  }

  @Test
  void shouldDraw_isTrueForAnOrdinaryWindowWhenVisibleAndLoaded () {
    app.Terrain.displaySurface = true;
    app.Terrain.loadMesh = true;
    assertTrue(app.Terrain.shouldDraw(app.TypeWindow.WIN3D));
  }

  // ================= landCellBaseVertices ===============================

  @Test
  void landCellBaseVertices_extractsTheFourCornersOfACell () {
    app.Terrain.Mesh = new float[][][]{
      {{0, 0, 0}, {0, 1, 0}},
      {{1, 0, 0}, {1, 1, 0}}
    };

    float[][] corners = app.Terrain.landCellBaseVertices(0, 0);

    assertArrayEquals(new float[]{0, 0, 0}, corners[0], 0.0001f);
    assertArrayEquals(new float[]{1, 0, 0}, corners[1], 0.0001f);
    assertArrayEquals(new float[]{1, 1, 0}, corners[2], 0.0001f);
    assertArrayEquals(new float[]{0, 1, 0}, corners[3], 0.0001f);
  }

  // ================= flat_mesh / normalizeMeshElevation =================

  @Test
  void flatMesh_buildsAMeshWithZeroElevationEverywhereAndSetsLoadMesh () {
    app.Terrain.rowCount = 2;
    app.Terrain.columnCount = 3;
    app.Terrain.loadMesh = false;

    app.Terrain.flat_mesh();

    assertEquals(2, app.Terrain.Mesh.length);
    assertEquals(3, app.Terrain.Mesh[0].length);
    for (float[][] row : app.Terrain.Mesh) {
      for (float[] cell : row) assertEquals(0f, cell[2], 0.0001f);
    }
    assertTrue(app.Terrain.loadMesh);
  }

  @Test
  void normalizeMeshElevation_subtractsTheCornerElevationPlusHeightAboveGroundFromEveryZ () {
    app.Terrain.Mesh = new float[][][]{
      {{0, 0, 100}, {0, 0, 150}},
      {{0, 0, 120}, {0, 0, 130}}
    };
    app.Terrain.rowCount = 2;
    app.Terrain.columnCount = 2;

    app.Terrain.normalizeMeshElevation();

    float h = 100 + app.HeightAboveGround; // baseline: Mesh[0][0][2] + HeightAboveGround
    assertEquals(100 - h, app.Terrain.Mesh[0][0][2], 0.0001f);
    assertEquals(150 - h, app.Terrain.Mesh[0][1][2], 0.0001f);
    assertEquals(130 - h, app.Terrain.Mesh[1][1][2], 0.0001f);
  }

  // ================= shouldStrokeLandSubFace / projectLandSubFaceForWIN3D

  @Test
  void shouldStrokeLandSubFace_dependsOnDisplayTextureAndWhichMapIsInUse () {
    app.Terrain.displayTexture = true;
    assertTrue(app.Terrain.shouldStrokeLandSubFace(-1));  // no texture map in use -> stroke it
    assertFalse(app.Terrain.shouldStrokeLandSubFace(0));  // a real texture map is in use -> don't

    app.Terrain.displayTexture = false;
    app.allFaces.displayEdges = true;
    assertTrue(app.Terrain.shouldStrokeLandSubFace(0)); // falls back to the global edges setting
    app.allFaces.displayEdges = false;
    assertFalse(app.Terrain.shouldStrokeLandSubFace(0));
  }

  @Test
  void projectLandSubFaceForWIN3D_scalesAndFlipsY () {
    app.overallScale = 2;
    app.WIN3D.scale = 3;

    float[][] result = app.Terrain.projectLandSubFaceForWIN3D(new float[][]{{1, 2, 3}});

    assertEquals(6f, result[0][0], 0.0001f);  // 1 * 2 * 3
    assertEquals(-12f, result[0][1], 0.0001f); // -(2 * 2 * 3)
    assertEquals(18f, result[0][2], 0.0001f);  // 3 * 2 * 3
  }

  // ================= intersect / intersectLandCell ======================

  @Test
  void intersect_hitsALandCellThroughItsCentroid () {
    app.Terrain.rowCount = 2;
    app.Terrain.columnCount = 2;
    app.Terrain.Mesh = new float[][][]{
      {{0, 0, 0}, {0, 2, 0}},
      {{2, 0, 0}, {2, 2, 0}}
    };

    float[] result = app.Terrain.intersect(new float[]{1, 1, 10}, new float[]{0, 0, -1});

    assertEquals(0f, result[0], 0.0001f); // only 1 cell exists, index 0
    assertEquals(1f, result[1], 0.0001f);
    assertEquals(1f, result[2], 0.0001f);
    assertEquals(0f, result[3], 0.0001f);
    assertEquals(10f, result[4], 0.0001f);
  }

  @Test
  void intersect_returnsMinusOneWhenNothingIsHit () {
    app.Terrain.rowCount = 2;
    app.Terrain.columnCount = 2;
    app.Terrain.Mesh = new float[][][]{
      {{0, 0, 0}, {0, 2, 0}},
      {{2, 0, 0}, {2, 2, 0}}
    };

    float[] result = app.Terrain.intersect(new float[]{50, 50, 10}, new float[]{0, 0, -1});

    assertEquals(-1f, result[0], 0.0001f);
  }

  // ================= to_XML / from_XML round trip ======================

  @Test
  void toXMLThenFromXML_roundTripsTheMeshAndDisplaySettings () {
    app.Terrain.rowCount = 1;
    app.Terrain.columnCount = 2;
    app.Terrain.Mesh = new float[][][]{{{1, 2, 3}, {4, 5, 6}}};
    app.Terrain.displayTessellation = 2;
    app.Terrain.loadTextures = false;
    app.Terrain.loadMesh = false;
    app.Terrain.displaySurface = false;
    app.Terrain.displayPoints = true;
    app.Terrain.displayTexture = false;
    app.Terrain.displayDepth = true;
    app.Terrain.colorScaleIndex = 3;
    app.Terrain.colorScaleDirection = -1;
    app.Terrain.colorScaleFactor = 0.2f;
    app.Terrain.skipStart = 2;
    app.Terrain.skipEnd = 1;
    app.Terrain.Textures_num = 0; // keep the Textures block a no-op - see the dedicated test below for it populated

    processing.data.XML root = new processing.data.XML("root");
    app.Terrain.to_XML(root);

    solarchvision_bim.Terrain fresh = app.new Terrain();
    fresh.Textures_horizontalUnitScale = new float[0];
    fresh.Textures_verticalUnitScale = new float[0];
    fresh.from_XML(root);

    assertEquals(1, fresh.rowCount);
    assertEquals(2, fresh.columnCount);
    assertArrayEquals(new float[]{1, 2, 3}, fresh.Mesh[0][0], 0.001f);
    assertArrayEquals(new float[]{4, 5, 6}, fresh.Mesh[0][1], 0.001f);
    assertEquals(2, fresh.displayTessellation);
    assertFalse(fresh.loadTextures);
    assertFalse(fresh.loadMesh);
    assertFalse(fresh.displaySurface);
    assertTrue(fresh.displayPoints);
    assertFalse(fresh.displayTexture);
    assertTrue(fresh.displayDepth);
    assertEquals(3, fresh.colorScaleIndex);
    assertEquals(2, fresh.skipStart);
    assertEquals(1, fresh.skipEnd);
  }
}
