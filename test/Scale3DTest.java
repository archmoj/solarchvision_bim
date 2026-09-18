import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Exercises solarchvision_Scale3D (Scale3D.pde), reached through the
// pre-constructed `app.Scale3D` field. Every function scales some part
// of the scene around a given pivot (x0, y0, z0) by (sx, sy, sz),
// dispatched by current_ObjectCategory through selection().
//
// Nearly every function routes each point through scalePointAroundPivot,
// which itself calls Select3D.translateOutside_ReferencePivot /
// translateInside_ReferencePivot - already confirmed in Select3DTest.java
// to be inverse transforms, and under Select3D's DEFAULT state (identity
// BoundingBox, alignX/Y/Z=0) both reduce to a no-op. That default state
// is exactly what a freshly-constructed `app` already has, so none of
// the tests below need to touch BoundingBox/alignX/Y/Z at all -
// scalePointAroundPivot(x, y, z, x0, y0, z0, sx, sy, sz) reduces cleanly
// to sx*(x-x0)+x0 (and the same for y/z), which is what every expected
// value here is computed from.
//
// NOT covered: Scale3D.Sections(). Same reasoning as Move3DTest's
// skipped Sections() test - it unconditionally calls allSolidImpacts.
// calculate_Impact_selectedSections(), keyed off the SAME
// Select3D.Section_ids being scaled, so there's no way to test its move
// logic without also triggering a real solar-impact image
// recalculation. Its own scale logic (setU/setV) is trivial enough
// (multiply by sx/sy) that nothing new is really left unverified.
//
// A fresh `app` per test since these all mutate shared scene state.
class Scale3DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= selection() dispatcher ==========================

  @Test
  void selection_vertexCategoryDispatchesToVertices () {
    app.allVertices = new float[][]{{3, 0, 0}};
    app.current_ObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.Vertex_ids = new int[]{0};

    app.Scale3D.selection(1, 0, 0, 2, 1, 1);

    assertArrayEquals(new float[]{5, 0, 0}, app.allVertices[0], 0.0001f); // 2*(3-1)+1
  }

  // ================= scalePointAroundPivot ============================

  @Test
  void scalePointAroundPivot_scalesTheDistanceFromThePivot () {
    float[] result = app.Scale3D.scalePointAroundPivot(3, 4, 5, 1, 0, 1, 2, 1, 3);
    assertArrayEquals(new float[]{5, 4, 13}, result, 0.0001f); // 2*(3-1)+1, 1*(4-0)+0, 3*(5-1)+1
  }

  // ================= LandPoints =======================================

  @Test
  void landPoints_scalesOnlyTheSelectedGridCells () {
    app.Land3D.num_columns = 3;
    app.Land3D.Mesh = new float[1][3][3];
    app.Land3D.Mesh[0][1] = new float[]{3, 0, 0};

    app.Select3D.LandPoint_ids = new int[]{1}; // row 0, col 1

    app.Scale3D.LandPoints(1, 0, 0, 2, 1, 1);

    assertArrayEquals(new float[]{5, 0, 0}, app.Land3D.Mesh[0][1], 0.0001f);
    assertArrayEquals(new float[]{0, 0, 0}, app.Land3D.Mesh[0][0], 0.0001f); // untouched
  }

  // ================= softSelection ====================================

  @Test
  void softSelection_blendsBetweenUnscaledAndFullyScaledByWeight () {
    // A weight of 0.5 should land halfway between "not scaled at all"
    // (x0 + x = 3) and "fully scaled" (x0 + sx*x = 1 + 3*2 = 7) - this is
    // a genuinely different formula from scalePointAroundPivot (no
    // translateOutside/Inside involved at all), so it's checked on its
    // own rather than assumed to match the pattern above.
    app.allVertices = new float[][]{{3, 0, 0}};
    app.Select3D.softSelection_ids = new int[]{0};
    app.Select3D.softSelection_values = new float[]{0.5f};

    app.Scale3D.softSelection(1, 0, 0, 3, 1, 1);

    assertArrayEquals(new float[]{5, 0, 0}, app.allVertices[0], 0.0001f); // 0.5*7 + 0.5*3
  }

  @Test
  void softSelection_fullWeightMatchesAFullScale () {
    app.allVertices = new float[][]{{3, 0, 0}};
    app.Select3D.softSelection_ids = new int[]{0};
    app.Select3D.softSelection_values = new float[]{1f};

    app.Scale3D.softSelection(1, 0, 0, 3, 1, 1);

    assertArrayEquals(new float[]{7, 0, 0}, app.allVertices[0], 0.0001f); // x0 + sx*(x-x0) = 1+3*2
  }

  // ================= Vertices =========================================

  @Test
  void vertices_scalesOnlyTheSelectedPoints () {
    app.allVertices = new float[][]{{3, 0, 0}, {100, 100, 100}};
    app.Select3D.Vertex_ids = new int[]{0};

    app.Scale3D.Vertices(1, 0, 0, 2, 1, 1);

    assertArrayEquals(new float[]{5, 0, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{100, 100, 100}, app.allVertices[1], 0.0001f); // untouched
  }

  // ================= Polylines / Faces ================================

  @Test
  void polylines_scalesEveryVertexTouchedBySelectedPolylines () {
    app.allVertices = new float[][]{{3, 0, 0}, {0, 0, 0}};
    app.allPolylines.nodes = new int[][]{{0}};
    app.Select3D.Polyline_ids = new int[]{0};

    app.Scale3D.Polylines(1, 0, 0, 2, 1, 1);

    assertArrayEquals(new float[]{5, 0, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{0, 0, 0}, app.allVertices[1], 0.0001f); // untouched
  }

  @Test
  void faces_scalesEveryVertexTouchedBySelectedFaces () {
    app.allVertices = new float[][]{{3, 0, 0}, {0, 0, 0}};
    app.allFaces.nodes = new int[][]{{0}};
    app.Select3D.Face_ids = new int[]{0};

    app.Scale3D.Faces(1, 0, 0, 2, 1, 1);

    assertArrayEquals(new float[]{5, 0, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{0, 0, 0}, app.allVertices[1], 0.0001f); // untouched
  }

  // ================= Solids ===========================================

  @Test
  void solids_scalesPositionAndMultipliesTheStoredScaleFactors () {
    app.allSolids.DEF = new float[][]{new float[13]};
    app.allSolids.DEF[0][0] = 3; // posX
    app.allSolids.DEF[0][6] = 1; // scaleX (columns 6-8, per Solids.Scale)
    app.allSolids.DEF[0][7] = 1;
    app.allSolids.DEF[0][8] = 1;

    app.Select3D.Solid_ids = new int[]{0};
    // Section_ids left empty - same reasoning as Move3DTest's Solids
    // test: it makes the mandatory calculate_Impact_selectedSections()
    // call a safe no-op regardless of what was actually scaled here.

    app.Scale3D.Solids(1, 0, 0, 2, 3, 4);

    assertEquals(5f, app.allSolids.DEF[0][0], 0.0001f); // posX: 2*(3-1)+1
    assertEquals(2f, app.allSolids.DEF[0][6], 0.0001f); // scaleX *= sx
    assertEquals(3f, app.allSolids.DEF[0][7], 0.0001f); // scaleY *= sy
    assertEquals(4f, app.allSolids.DEF[0][8], 0.0001f); // scaleZ *= sz
  }

  // ================= Cameras ==========================================

  @Test
  void cameras_swapsYAndZBeforeScalingAndRefreshesTheViewIfItIsTheCurrentCamera () {
    app.allCameras.options = new float[][]{new float[9]};
    app.allCameras.Type = new int[]{0};
    app.allCameras.num = 1;
    app.allCameras.options[0][0] = 3; // posX

    app.WIN3D.currentCamera = 0;
    app.Select3D.Camera_ids = new int[]{0};

    // sy and sz get swapped internally -> effectively applies (sx=2, sy=4, sz=3)
    app.Scale3D.Cameras(1, 0, 0, 2, 3, 4);

    assertEquals(5f, app.allCameras.options[0][0], 0.0001f); // posX: 2*(3-1)+1
    assertEquals(0f, app.allCameras.options[0][1], 0.0001f); // posY: 4*(0-0)+0
    assertEquals(0f, app.allCameras.options[0][2], 0.0001f); // posZ: 3*(0-0)+0

    // apply_currentCamera() ran, so WIN3D mirrors the camera's new position.
    assertEquals(5f, app.WIN3D.position_X, 0.0001f);
  }

  // ================= Model1Ds ==========================================

  @Test
  void model1Ds_scalesPositionAndMultipliesItsMagnitudeBySz () {
    app.allModel1Ds.f_data = new float[][]{new float[11]};
    app.allModel1Ds.f_data[0][0] = 3; // X
    app.allModel1Ds.f_data[0][3] = 1; // magnitude (per Model1Ds.magS)

    app.Select3D.Model1D_ids = new int[]{0};

    app.Scale3D.Model1Ds(1, 0, 0, 2, 1, 4);

    assertEquals(5f, app.allModel1Ds.f_data[0][0], 0.0001f); // X: 2*(3-1)+1
    assertEquals(4f, app.allModel1Ds.f_data[0][3], 0.0001f); // magnitude *= sz
  }

  // ================= Model2Ds ==========================================

  @Test
  void model2Ds_scalesMagnitudeOnlyForTreesNotForPeople () {
    app.allModel2Ds.XYZS = new float[][]{new float[4], new float[4]};
    app.allModel2Ds.XYZS[0][0] = 3; // tree's X
    app.allModel2Ds.XYZS[0][3] = 1; // tree's magnitude
    app.allModel2Ds.XYZS[1][0] = 3; // person's X
    app.allModel2Ds.XYZS[1][3] = 1; // person's magnitude
    // isTree(n) is `abs(n) > num_files_PEOPLE` and num_files_PEOPLE
    // defaults to 0, so MAP value 0 reads as "not a tree" (a person)
    // and any nonzero MAP value reads as "a tree".
    app.allModel2Ds.MAP = new int[]{1, 0};

    app.Select3D.Model2D_ids = new int[]{0, 1};

    app.Scale3D.Model2Ds(1, 0, 0, 2, 1, 4);

    assertEquals(5f, app.allModel2Ds.XYZS[0][0], 0.0001f); // both positions still scale
    assertEquals(5f, app.allModel2Ds.XYZS[1][0], 0.0001f);
    assertEquals(4f, app.allModel2Ds.XYZS[0][3], 0.0001f); // tree: magnitude scaled
    assertEquals(1f, app.allModel2Ds.XYZS[1][3], 0.0001f); // person: magnitude untouched
  }

  // ================= Groups (full integration tests) ====================

  @Test
  void groups_scalesTheGroupsOwnVerticesAndItsPivot () {
    app.allVertices = new float[][]{{3, 0, 0}};
    app.allFaces.nodes = new int[][]{{0}};
    app.allPolylines.nodes = new int[0][];

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};
    app.allGroups.Polylines[0] = new int[]{0, -1};
    app.allGroups.Model1Ds[0] = new int[]{0, -1};
    app.allGroups.Model2Ds[0] = new int[]{0, -1};
    app.allGroups.Solids[0] = new int[]{0, -1};
    app.allGroups.Pivots[0] = new float[]{3, 0, 0, 1, 1, 1, 0, 0, 0};

    app.Select3D.Group_ids = new int[]{0};

    app.Scale3D.Groups(1, 0, 0, 2, 1, 1);

    assertArrayEquals(new float[]{5, 0, 0}, app.allVertices[0], 0.0001f);
    assertEquals(5f, app.allGroups.Pivots[0][0], 0.0001f);
  }

  @Test
  void groups_cascadesIntoItsOwnedModel1DsModel2DsAndSolids () {
    app.allVertices = new float[0][3];
    app.allFaces.nodes = new int[0][];
    app.allPolylines.nodes = new int[0][];

    app.allModel1Ds.f_data = new float[][]{new float[11]};
    app.allModel1Ds.f_data[0][0] = 3;
    app.allModel1Ds.f_data[0][3] = 1;
    app.allModel1Ds.num = 1;

    app.allModel2Ds.XYZS = new float[][]{new float[4]};
    app.allModel2Ds.XYZS[0][0] = 3;
    app.allModel2Ds.XYZS[0][3] = 1;
    app.allModel2Ds.MAP = new int[]{1}; // a tree
    app.allModel2Ds.num = 1;

    app.allSolids.DEF = new float[][]{new float[13]};
    app.allSolids.DEF[0][0] = 3;
    app.allSolids.DEF[0][6] = 1;

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, -1};
    app.allGroups.Polylines[0] = new int[]{0, -1};
    app.allGroups.Model1Ds[0] = new int[]{0, 0};
    app.allGroups.Model2Ds[0] = new int[]{0, 0};
    app.allGroups.Solids[0] = new int[]{0, 0};
    app.allGroups.Pivots[0] = new float[9];

    app.Select3D.Group_ids = new int[]{0};
    // Section_ids stays empty, same reasoning as the Solids() test above.

    app.Scale3D.Groups(1, 0, 0, 2, 1, 4);

    assertEquals(5f, app.allModel1Ds.f_data[0][0], 0.0001f);
    assertEquals(4f, app.allModel1Ds.f_data[0][3], 0.0001f);

    assertEquals(5f, app.allModel2Ds.XYZS[0][0], 0.0001f);
    assertEquals(4f, app.allModel2Ds.XYZS[0][3], 0.0001f); // it's a tree, so magS applied

    assertEquals(5f, app.allSolids.DEF[0][0], 0.0001f);
    assertEquals(2f, app.allSolids.DEF[0][6], 0.0001f);
  }
}
