import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Exercises solarchvision_Land3D (Land3D.pde), reached through the
// pre-constructed `app.Land3D` field.
//
// getLandGrid() is already covered directly in LandGridTest.java from an
// earlier session - not repeated here.
//
// NOT covered: update_textures()/addLandTextureIfElevationJpg()/
// update_mesh()/loadMeshFromFiles()/download_mesh()/download_textures()
// - all real file/network I/O (OPESYS.getFiles, loadImage, loadXML,
// loadBytes/saveBytes against a live network endpoint). draw() and its
// whole rendering family (writeLandMaterials, beginLandGroup,
// drawLandRow, drawLandCell, drawLandSubFace, beginLandShape,
// renderLandVertex*, endLandShape, writeLandObjFace,
// writeLandDepthWalls, drawLandPoints, castShadows,
// castLandSubFaceShadow, castLandShadowClippedEdge, flushLandEdgeBatch)
// - real WIN3D.graphics/SHADOW_graphics calls or real file output.
// flat_mesh()/normalizeMeshElevation()/shouldDraw()/landCellBaseVertices()/
// shouldStrokeLandSubFace()/projectLandSubFaceForWIN3D()/intersect()
// ARE covered - all pure math/array logic.
//
// A fresh `app` per test since these mutate shared scene state.
class Land3DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= shouldDraw ========================================

  @Test
  void shouldDraw_isFalseWhenDisplaySurfaceOrLoadMeshIsOff () {
    app.Land3D.displaySurface = false;
    app.Land3D.loadMesh = true;
    assertFalse(app.Land3D.shouldDraw(app.TypeWindow.WIN3D));

    app.Land3D.displaySurface = true;
    app.Land3D.loadMesh = false;
    assertFalse(app.Land3D.shouldDraw(app.TypeWindow.WIN3D));
  }

  @Test
  void shouldDraw_isFalseForStudyAndWorldWindows () {
    app.Land3D.displaySurface = true;
    app.Land3D.loadMesh = true;
    assertFalse(app.Land3D.shouldDraw(app.TypeWindow.STUDY));
    assertFalse(app.Land3D.shouldDraw(app.TypeWindow.WORLD));
  }

  @Test
  void shouldDraw_isTrueForAnOrdinaryWindowWhenVisibleAndLoaded () {
    app.Land3D.displaySurface = true;
    app.Land3D.loadMesh = true;
    assertTrue(app.Land3D.shouldDraw(app.TypeWindow.WIN3D));
  }

  // ================= landCellBaseVertices ===============================

  @Test
  void landCellBaseVertices_extractsTheFourCornersOfACell () {
    app.Land3D.Mesh = new float[][][]{
      {{0, 0, 0}, {0, 1, 0}},
      {{1, 0, 0}, {1, 1, 0}}
    };

    float[][] corners = app.Land3D.landCellBaseVertices(0, 0);

    assertArrayEquals(new float[]{0, 0, 0}, corners[0], 0.0001f);
    assertArrayEquals(new float[]{1, 0, 0}, corners[1], 0.0001f);
    assertArrayEquals(new float[]{1, 1, 0}, corners[2], 0.0001f);
    assertArrayEquals(new float[]{0, 1, 0}, corners[3], 0.0001f);
  }

  // ================= flat_mesh / normalizeMeshElevation =================

  @Test
  void flatMesh_buildsAMeshWithZeroElevationEverywhereAndSetsLoadMesh () {
    app.Land3D.num_rows = 2;
    app.Land3D.num_columns = 3;
    app.Land3D.loadMesh = false;

    app.Land3D.flat_mesh();

    assertEquals(2, app.Land3D.Mesh.length);
    assertEquals(3, app.Land3D.Mesh[0].length);
    for (float[][] row : app.Land3D.Mesh) {
      for (float[] cell : row) assertEquals(0f, cell[2], 0.0001f);
    }
    assertTrue(app.Land3D.loadMesh);
  }

  @Test
  void normalizeMeshElevation_subtractsTheCornerElevationPlusHeightAboveGroundFromEveryZ () {
    app.Land3D.Mesh = new float[][][]{
      {{0, 0, 100}, {0, 0, 150}},
      {{0, 0, 120}, {0, 0, 130}}
    };
    app.Land3D.num_rows = 2;
    app.Land3D.num_columns = 2;

    app.Land3D.normalizeMeshElevation();

    float h = 100 + app.HeightAboveGround; // baseline: Mesh[0][0][2] + HeightAboveGround
    assertEquals(100 - h, app.Land3D.Mesh[0][0][2], 0.0001f);
    assertEquals(150 - h, app.Land3D.Mesh[0][1][2], 0.0001f);
    assertEquals(130 - h, app.Land3D.Mesh[1][1][2], 0.0001f);
  }

  // ================= shouldStrokeLandSubFace / projectLandSubFaceForWIN3D

  @Test
  void shouldStrokeLandSubFace_dependsOnDisplayTextureAndWhichMapIsInUse () {
    app.Land3D.displayTexture = true;
    assertTrue(app.Land3D.shouldStrokeLandSubFace(-1));  // no texture map in use -> stroke it
    assertFalse(app.Land3D.shouldStrokeLandSubFace(0));  // a real texture map is in use -> don't

    app.Land3D.displayTexture = false;
    app.allFaces.displayEdges = true;
    assertTrue(app.Land3D.shouldStrokeLandSubFace(0)); // falls back to the global edges setting
    app.allFaces.displayEdges = false;
    assertFalse(app.Land3D.shouldStrokeLandSubFace(0));
  }

  @Test
  void projectLandSubFaceForWIN3D_scalesAndFlipsY () {
    app.OBJECTS_scale = 2;
    app.WIN3D.scale = 3;

    float[][] result = app.Land3D.projectLandSubFaceForWIN3D(new float[][]{{1, 2, 3}});

    assertEquals(6f, result[0][0], 0.0001f);  // 1 * 2 * 3
    assertEquals(-12f, result[0][1], 0.0001f); // -(2 * 2 * 3)
    assertEquals(18f, result[0][2], 0.0001f);  // 3 * 2 * 3
  }

  // ================= intersect / intersectLandCell ======================

  @Test
  void intersect_hitsALandCellThroughItsCentroid () {
    app.Land3D.num_rows = 2;
    app.Land3D.num_columns = 2;
    app.Land3D.Mesh = new float[][][]{
      {{0, 0, 0}, {0, 2, 0}},
      {{2, 0, 0}, {2, 2, 0}}
    };

    float[] result = app.Land3D.intersect(new float[]{1, 1, 10}, new float[]{0, 0, -1});

    assertEquals(0f, result[0], 0.0001f); // only 1 cell exists, index 0
    assertEquals(1f, result[1], 0.0001f);
    assertEquals(1f, result[2], 0.0001f);
    assertEquals(0f, result[3], 0.0001f);
    assertEquals(10f, result[4], 0.0001f);
  }

  @Test
  void intersect_returnsMinusOneWhenNothingIsHit () {
    app.Land3D.num_rows = 2;
    app.Land3D.num_columns = 2;
    app.Land3D.Mesh = new float[][][]{
      {{0, 0, 0}, {0, 2, 0}},
      {{2, 0, 0}, {2, 2, 0}}
    };

    float[] result = app.Land3D.intersect(new float[]{50, 50, 10}, new float[]{0, 0, -1});

    assertEquals(-1f, result[0], 0.0001f);
  }

  // ================= to_XML / from_XML round trip ======================

  @Test
  void toXMLThenFromXML_roundTripsTheMeshAndDisplaySettings () {
    app.Land3D.num_rows = 1;
    app.Land3D.num_columns = 2;
    app.Land3D.Mesh = new float[][][]{{{1, 2, 3}, {4, 5, 6}}};
    app.Land3D.displayTessellation = 2;
    app.Land3D.loadTextures = false;
    app.Land3D.loadMesh = false;
    app.Land3D.displaySurface = false;
    app.Land3D.displayPoints = true;
    app.Land3D.displayTexture = false;
    app.Land3D.displayDepth = true;
    app.Land3D.palette_CLR = 3;
    app.Land3D.palette_DIR = -1;
    app.Land3D.palette_MLT = 0.2f;
    app.Land3D.skipStart = 2;
    app.Land3D.skipEnd = 1;
    app.Land3D.Textures_num = 0; // keep the Textures block a no-op - see the dedicated test below for it populated

    processing.data.XML root = new processing.data.XML("root");
    app.Land3D.to_XML(root);

    solarchvision_bim.solarchvision_Land3D fresh = app.new solarchvision_Land3D();
    fresh.Textures_U_scale = new float[0];
    fresh.Textures_V_scale = new float[0];
    fresh.from_XML(root);

    assertEquals(1, fresh.num_rows);
    assertEquals(2, fresh.num_columns);
    assertArrayEquals(new float[]{1, 2, 3}, fresh.Mesh[0][0], 0.001f);
    assertArrayEquals(new float[]{4, 5, 6}, fresh.Mesh[0][1], 0.001f);
    assertEquals(2, fresh.displayTessellation);
    assertFalse(fresh.loadTextures);
    assertFalse(fresh.loadMesh);
    assertFalse(fresh.displaySurface);
    assertTrue(fresh.displayPoints);
    assertFalse(fresh.displayTexture);
    assertTrue(fresh.displayDepth);
    assertEquals(3, fresh.palette_CLR);
    assertEquals(2, fresh.skipStart);
    assertEquals(1, fresh.skipEnd);
  }
}
