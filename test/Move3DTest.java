import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class Move3DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= selection() dispatcher ==========================

  @Test
  void selection_vertexCategoryDispatchesToVertices () {
    app.allVertices = new float[][]{{1, 2, 3}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.VertexIndices = new int[]{0};

    app.Move3D.selection(1, 1, 1);

    assertArrayEquals(new float[]{2, 3, 4}, app.allVertices[0], 0.0001f);
  }

  @Test
  void selection_faceCategoryDispatchesToFaces () {
    app.allVertices = new float[][]{{1, 2, 3}};
    app.allFaces.nodes = new int[][]{{0}};
    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.FaceIndices = new int[]{0};

    app.Move3D.selection(1, 1, 1);

    assertArrayEquals(new float[]{2, 3, 4}, app.allVertices[0], 0.0001f);
  }

  // ================= Terrain Vertices =====================================

  @Test
  void landPoints_movesOnlyTheSelectedGridCells () {
    app.Terrain.columnCount = 3;
    app.Terrain.Mesh = new float[2][3][3]; // 2 rows x 3 columns, all zero

    app.Select3D.terrainVertexIndices = new int[]{4}; // flat index 4 -> row 1, col 1

    app.Move3D.TerrainVertices(1, 2, 3);

    assertArrayEquals(new float[]{1, 2, 3}, app.Terrain.Mesh[1][1], 0.0001f);
    assertArrayEquals(new float[]{0, 0, 0}, app.Terrain.Mesh[0][0], 0.0001f); // untouched
  }

  // ================= softSelection ===================================

  @Test
  void softSelection_scalesTheOffsetByEachVerticesWeight () {
    app.allVertices = new float[][]{{0, 0, 0}, {0, 0, 0}};
    app.Select3D.softSelectionIndices = new int[]{0, 1};
    app.Select3D.softSelection_values = new float[]{1f, 0.5f};

    app.Move3D.softSelection(2, 4, 6);

    assertArrayEquals(new float[]{2, 4, 6}, app.allVertices[0], 0.0001f);   // full weight
    assertArrayEquals(new float[]{1, 2, 3}, app.allVertices[1], 0.0001f);   // half weight
  }

  // ================= Vertices ========================================

  @Test
  void vertices_movesOnlyTheSelectedPoints () {
    app.allVertices = new float[][]{{1, 1, 1}, {5, 5, 5}};
    app.Select3D.VertexIndices = new int[]{1};

    app.Move3D.Vertices(1, 1, 1);

    assertArrayEquals(new float[]{1, 1, 1}, app.allVertices[0], 0.0001f); // untouched
    assertArrayEquals(new float[]{6, 6, 6}, app.allVertices[1], 0.0001f);
  }

  // ================= Polylines ========================================

  @Test
  void polylines_movesEveryVertexTouchedBySelectedPolylines () {
    app.allVertices = new float[][]{{0, 0, 0}, {0, 0, 0}, {0, 0, 0}};
    app.allPolylines.nodes = new int[][]{{0, 1}};
    app.Select3D.PolylineIndices = new int[]{0};

    app.Move3D.Polylines(1, 1, 1);

    assertArrayEquals(new float[]{1, 1, 1}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{1, 1, 1}, app.allVertices[1], 0.0001f);
    assertArrayEquals(new float[]{0, 0, 0}, app.allVertices[2], 0.0001f); // not touched by the polyline
  }

  // ================= Faces ===========================================

  @Test
  void faces_movesEveryVertexTouchedBySelectedFaces () {
    app.allVertices = new float[][]{{0, 0, 0}, {0, 0, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.Select3D.FaceIndices = new int[]{0};

    app.Move3D.Faces(1, 1, 1);

    assertArrayEquals(new float[]{1, 1, 1}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{1, 1, 1}, app.allVertices[1], 0.0001f);
  }

  @Test
  void faces_nowFlagsTheViewportForRedrawLikeEverySiblingFunction () {
    // Fixed bug: Faces() used to be the one move function here with no
    // model_changed() call at the end, leaving the
    // viewport's "needs redraw" flag untouched after a move that could
    // move vertices - unlike every sibling function (Vertices() included
    // below for direct comparison). Fixed by adding the same call the
    // others already end with.
    app.allVertices = new float[][]{{0, 0, 0}};
    app.allFaces.nodes = new int[][]{{0}};
    app.Select3D.FaceIndices = new int[]{0};

    app.WIN3D.update = false;
    app.Move3D.Faces(1, 1, 1);
    assertTrue(app.WIN3D.update);

    app.WIN3D.update = false;
    app.Select3D.VertexIndices = new int[]{0};
    app.Move3D.Vertices(1, 1, 1);
    assertTrue(app.WIN3D.update); // unchanged: still true, exactly like Faces() now
  }

  // ================= Model1Ds / Model2Ds ===============================

  @Test
  void model1Ds_movesOnlyTheSelectedRow () {
    app.allModel1Ds.f_data = new float[][]{new float[11], new float[11]};
    app.allModel1Ds.f_data[1][0] = 5;
    app.Select3D.Model1DIndices = new int[]{1};

    app.Move3D.Model1Ds(1, 2, 3);

    assertArrayEquals(new float[]{0, 0, 0}, java.util.Arrays.copyOf(app.allModel1Ds.f_data[0], 3), 0.0001f);
    assertArrayEquals(new float[]{6, 2, 3}, java.util.Arrays.copyOf(app.allModel1Ds.f_data[1], 3), 0.0001f);
  }

  @Test
  void model2Ds_movesOnlyTheSelectedRow () {
    app.allModel2Ds.XYZS = new float[][]{new float[4], new float[4]};
    app.allModel2Ds.XYZS[1][0] = 5;
    app.Select3D.Model2DIndices = new int[]{1};

    app.Move3D.Model2Ds(1, 2, 3);

    assertArrayEquals(new float[]{0, 0, 0}, java.util.Arrays.copyOf(app.allModel2Ds.XYZS[0], 3), 0.0001f);
    assertArrayEquals(new float[]{6, 2, 3}, java.util.Arrays.copyOf(app.allModel2Ds.XYZS[1], 3), 0.0001f);
  }

  // ================= Solids (via moveSolid) ===========================

  @Test
  void solids_movesOnlyTheSelectedSolidAndLeavesSectionRecalculationAsANoOp () {
    app.allSolids.DEF = new float[][]{new float[13], new float[13]};
    app.allSolids.DEF[1][0] = 5;
    app.Select3D.SolidIndices = new int[]{1};
    // Select3D.SectionIndices is left empty - allSolidImpacts.
    // calculate_Impact_selectedSections()'s own loop is keyed off that
    // array, so leaving it empty makes the mandatory call a safe no-op
    // regardless of what was actually moved here.

    app.Move3D.Solids(1, 2, 3);

    assertArrayEquals(new float[]{0, 0, 0}, java.util.Arrays.copyOf(app.allSolids.DEF[0], 3), 0.0001f);
    assertArrayEquals(new float[]{6, 2, 3}, java.util.Arrays.copyOf(app.allSolids.DEF[1], 3), 0.0001f);
  }

  // ================= Cameras ==========================================

  @Test
  void cameras_swapsYAndZBeforeMovingAndRefreshesTheViewIfItIsTheCurrentCamera () {
    // allCameras' constructor already creates one default camera via
    // add_first(), so overwriting `options` alone to a length-2 array
    // leaves `Type`/`num` stale at their original length-1 state -
    // keeping all three in sync is what get_type() (called inside
    // apply_currentCameraIndex()) actually needs to not throw.
    app.allCameras.options = new float[][]{new float[9], new float[9]};
    app.allCameras.Type = new int[]{0, 0};
    app.allCameras.num = 2;

    app.WIN3D.currentCameraIndex = 1;
    app.Select3D.CameraIndices = new int[]{1}; // moving the CURRENT camera

    app.Move3D.Cameras(1, 2, 3); // dy and dz get swapped internally -> actually applies (1, 3, 2)

    assertEquals(1f, app.allCameras.options[1][0], 0.0001f);
    assertEquals(3f, app.allCameras.options[1][1], 0.0001f);
    assertEquals(2f, app.allCameras.options[1][2], 0.0001f);

    // apply_currentCameraIndex() ran, so WIN3D's own position now mirrors the
    // moved (and swapped) camera values.
    assertEquals(1f, app.WIN3D.positionX, 0.0001f);
    assertEquals(3f, app.WIN3D.positionY, 0.0001f);
    assertEquals(2f, app.WIN3D.positionZ, 0.0001f);
  }

  @Test
  void cameras_movingANonCurrentCameraDoesNotRefreshTheView () {
    app.allCameras.options = new float[][]{new float[9], new float[9]};
    app.allCameras.Type = new int[]{0, 0};
    app.allCameras.num = 2;

    app.WIN3D.currentCameraIndex = 1;
    app.Select3D.CameraIndices = new int[]{0}; // moving a DIFFERENT camera

    // Captured rather than assumed: WIN3D.positionY/Z don't actually
    // default to 0 (they're 5 and 55, a preset starting viewpoint), so
    // asserting "unchanged" needs the real before-value, not a guess.
    float beforeX = app.WIN3D.positionX;
    float beforeY = app.WIN3D.positionY;
    float beforeZ = app.WIN3D.positionZ;

    app.Move3D.Cameras(1, 2, 3);

    // Camera 0 moved...
    assertEquals(1f, app.allCameras.options[0][0], 0.0001f);
    // ...but WIN3D's own position is untouched, since camera 0 isn't current.
    assertEquals(beforeX, app.WIN3D.positionX, 0.0001f);
    assertEquals(beforeY, app.WIN3D.positionY, 0.0001f);
    assertEquals(beforeZ, app.WIN3D.positionZ, 0.0001f);
  }

  // ================= Groups (full integration tests) ====================

  @Test
  void groups_movesTheGroupsOwnVerticesAndItsPivot () {
    app.allVertices = new float[][]{{0, 0, 0}};
    app.allFaces.nodes = new int[][]{{0}};
    app.allPolylines.nodes = new int[0][];

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};
    app.allGroups.Polylines[0] = new int[]{0, -1};
    app.allGroups.Model1Ds[0] = new int[]{0, -1};
    app.allGroups.Model2Ds[0] = new int[]{0, -1};
    app.allGroups.Solids[0] = new int[]{0, -1};
    app.allGroups.Pivots[0] = new float[9]; // all zero

    app.Select3D.GroupIndices = new int[]{0};

    app.Move3D.Groups(1, 2, 3);

    assertArrayEquals(new float[]{1, 2, 3}, app.allVertices[0], 0.0001f);
    assertEquals(1f, app.allGroups.Pivots[0][0], 0.0001f);
    assertEquals(2f, app.allGroups.Pivots[0][1], 0.0001f);
    assertEquals(3f, app.allGroups.Pivots[0][2], 0.0001f);
  }

  @Test
  void groups_cascadesIntoItsOwnedModel1DsModel2DsAndSolids () {
    app.allVertices = new float[0][3];
    app.allFaces.nodes = new int[0][];
    app.allPolylines.nodes = new int[0][];

    app.allModel1Ds.f_data = new float[][]{new float[11]};
    app.allModel1Ds.f_data[0][0] = 10;
    app.allModel1Ds.num = 1;

    app.allModel2Ds.XYZS = new float[][]{new float[4]};
    app.allModel2Ds.XYZS[0][0] = 20;
    app.allModel2Ds.num = 1;

    app.allSolids.DEF = new float[][]{new float[13]};
    app.allSolids.DEF[0][0] = 30;

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, -1};
    app.allGroups.Polylines[0] = new int[]{0, -1};
    app.allGroups.Model1Ds[0] = new int[]{0, 0};
    app.allGroups.Model2Ds[0] = new int[]{0, 0};
    app.allGroups.Solids[0] = new int[]{0, 0};
    app.allGroups.Pivots[0] = new float[9];

    app.Select3D.GroupIndices = new int[]{0};
    // SectionIndices stays empty, same reasoning as the Solids() test above.

    app.Move3D.Groups(1, 2, 3);

    assertEquals(11f, app.allModel1Ds.f_data[0][0], 0.0001f);
    assertEquals(2f, app.allModel1Ds.f_data[0][1], 0.0001f);
    assertEquals(3f, app.allModel1Ds.f_data[0][2], 0.0001f);

    assertEquals(21f, app.allModel2Ds.XYZS[0][0], 0.0001f);
    assertEquals(2f, app.allModel2Ds.XYZS[0][1], 0.0001f);
    assertEquals(3f, app.allModel2Ds.XYZS[0][2], 0.0001f);

    assertEquals(31f, app.allSolids.DEF[0][0], 0.0001f);
    assertEquals(2f, app.allSolids.DEF[0][1], 0.0001f);
    assertEquals(3f, app.allSolids.DEF[0][2], 0.0001f);
  }
}
