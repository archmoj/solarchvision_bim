import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class Rotate3DTest {

  private solarchvision_bim app;
  private static final float HALF_PI = (float) (Math.PI / 2);

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= selection() dispatcher ==========================

  @Test
  void selection_vertexCategoryDispatchesToVerticesAndConvertsDegreesToRadians () {
    app.allVertices = new float[][]{{1, 0, 0}};
    app.current_ObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.Vertex_ids = new int[]{0};

    app.Rotate3D.selection(0, 0, 0, 90, 2); // 90 DEGREES around Z

    assertArrayEquals(new float[]{0, 1, 0}, app.allVertices[0], 0.0001f);
  }

  // ================= rotateAroundVector ===============================

  @Test
  void rotateAroundVector_rotatesAQuarterTurnAroundEachAxis () {
    assertArrayEquals(new float[]{0, 1, 0}, app.Rotate3D.rotateAroundVector(1, 0, 0, HALF_PI, 2), 0.0001f); // Z
    assertArrayEquals(new float[]{0, 0, -1}, app.Rotate3D.rotateAroundVector(1, 0, 0, HALF_PI, 1), 0.0001f); // Y
    assertArrayEquals(new float[]{0, 0, 1}, app.Rotate3D.rotateAroundVector(0, 1, 0, HALF_PI, 0), 0.0001f); // X
  }

  @Test
  void rotateAroundVector_isTheIdentityForAnyOtherVectorIndex () {
    assertArrayEquals(new float[]{1, 2, 3}, app.Rotate3D.rotateAroundVector(1, 2, 3, HALF_PI, 9), 0.0001f);
  }

  // ================= rotatePointAroundReferencePivot ===================

  @Test
  void rotatePointAroundReferencePivot_matchesRotateAroundVectorUnderTheDefaultIdentityPivot () {
    float[] result = app.Rotate3D.rotatePointAroundReferencePivot(1, 0, 0, HALF_PI, 2);
    assertArrayEquals(new float[]{0, 1, 0}, result, 0.0001f);
  }

  // ================= softSelection ====================================

  @Test
  void softSelection_scalesTheRotationAngleItselfByWeightNotTheResultingPosition () {
    // A weight of 0.5 rotates by HALF the angle (45deg), not halfway
    // between the unrotated and fully-rotated positions - a genuinely
    // different blend than Scale3D.softSelection's linear value lerp.
    app.allVertices = new float[][]{{1, 0, 0}};
    app.Select3D.softSelection_ids = new int[]{0};
    app.Select3D.softSelection_values = new float[]{0.5f};

    app.Rotate3D.softSelection(0, 0, 0, HALF_PI, 2);

    float expected = (float) (Math.PI / 4); // 45deg
    assertArrayEquals(
      new float[]{(float) Math.cos(expected), (float) Math.sin(expected), 0},
      app.allVertices[0], 0.0001f);
  }

  // ================= LandPoints / Vertices / Polylines / Faces =========

  @Test
  void landPoints_rotatesOnlyTheSelectedGridCells () {
    app.Land3D.num_columns = 3;
    app.Land3D.Mesh = new float[1][3][3];
    app.Land3D.Mesh[0][1] = new float[]{1, 0, 0};

    app.Select3D.LandPoint_ids = new int[]{1};

    app.Rotate3D.LandPoints(0, 0, 0, HALF_PI, 2);

    assertArrayEquals(new float[]{0, 1, 0}, app.Land3D.Mesh[0][1], 0.0001f);
    assertArrayEquals(new float[]{0, 0, 0}, app.Land3D.Mesh[0][0], 0.0001f); // untouched
  }

  @Test
  void vertices_rotatesOnlyTheSelectedPoints () {
    app.allVertices = new float[][]{{1, 0, 0}, {100, 100, 100}};
    app.Select3D.Vertex_ids = new int[]{0};

    app.Rotate3D.Vertices(0, 0, 0, HALF_PI, 2);

    assertArrayEquals(new float[]{0, 1, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{100, 100, 100}, app.allVertices[1], 0.0001f); // untouched
  }

  @Test
  void polylines_rotatesEveryVertexTouchedBySelectedPolylines () {
    app.allVertices = new float[][]{{1, 0, 0}, {0, 0, 0}};
    app.allPolylines.nodes = new int[][]{{0}};
    app.Select3D.Polyline_ids = new int[]{0};

    app.Rotate3D.Polylines(0, 0, 0, HALF_PI, 2);

    assertArrayEquals(new float[]{0, 1, 0}, app.allVertices[0], 0.0001f);
  }

  @Test
  void faces_rotatesEveryVertexTouchedBySelectedFaces () {
    app.allVertices = new float[][]{{1, 0, 0}, {0, 0, 0}};
    app.allFaces.nodes = new int[][]{{0}};
    app.Select3D.Face_ids = new int[]{0};

    app.Rotate3D.Faces(0, 0, 0, HALF_PI, 2);

    assertArrayEquals(new float[]{0, 1, 0}, app.allVertices[0], 0.0001f);
  }

  // ================= Solids ===========================================

  @Test
  void solids_rotatesPositionAndAddsToItsOwnStoredZRotationInDegrees () {
    app.allSolids.DEF = new float[][]{new float[13]};
    app.allSolids.DEF[0][0] = 1; // posX
    // DEF[11] is the solid's own Z rotation, per Solids.RotateZ.

    app.Select3D.Solid_ids = new int[]{0};

    app.Rotate3D.Solids(0, 0, 0, HALF_PI, 2);

    assertArrayEquals(new float[]{0, 1, 0}, java.util.Arrays.copyOf(app.allSolids.DEF[0], 3), 0.0001f);
    assertEquals(90f, app.allSolids.DEF[0][11], 0.001f); // r converted back to degrees
  }

  // ================= Cameras ==========================================

  @Test
  void cameras_remapsTheVectorIndexRatherThanSwappingValues () {
    // Unlike Move3D/Scale3D's Cameras() (which swap the dy/dz VALUES),
    // this one remaps WHICH axis formula the_Vector selects: a request
    // for Z (2) actually runs the Y-axis (1) formula. Checked by
    // comparing against rotateAroundVector called with the
    // already-remapped index directly, not just asserting a single
    // hardcoded result. The companion test below covers the_Vector=0,
    // which is left unremapped.
    app.allCameras.options = new float[][]{new float[9]};
    app.allCameras.Type = new int[]{0};
    app.allCameras.num = 1;
    app.allCameras.options[0][0] = 1; // posX=1

    app.Select3D.Camera_ids = new int[]{0};

    app.Rotate3D.Cameras(0, 0, 0, HALF_PI, 2); // request Z...

    float[] expected = app.Rotate3D.rotateAroundVector(1, 0, 0, HALF_PI, 1); // ...actually runs as Y
    assertEquals(expected[0], app.allCameras.options[0][0], 0.0001f);
    assertEquals(expected[1], app.allCameras.options[0][1], 0.0001f);
    assertEquals(expected[2], app.allCameras.options[0][2], 0.0001f);
  }

  @Test
  void cameras_leavesTheXAxisRequestUnremapped () {
    app.allCameras.options = new float[][]{new float[9]};
    app.allCameras.Type = new int[]{0};
    app.allCameras.num = 1;
    app.allCameras.options[0][1] = 1; // posY=1

    app.Select3D.Camera_ids = new int[]{0};

    app.Rotate3D.Cameras(0, 0, 0, HALF_PI, 0); // request X - no remap

    float[] expected = app.Rotate3D.rotateAroundVector(0, 1, 0, HALF_PI, 0);
    assertEquals(expected[2], app.allCameras.options[0][2], 0.0001f);
  }

  @Test
  void cameras_refreshesTheViewOnlyWhenRotatingTheCurrentCamera () {
    app.allCameras.options = new float[][]{new float[9]};
    app.allCameras.Type = new int[]{0};
    app.allCameras.num = 1;
    app.allCameras.options[0][0] = 1;

    app.WIN3D.currentCamera = 0;
    app.Select3D.Camera_ids = new int[]{0};

    app.Rotate3D.Cameras(0, 0, 0, HALF_PI, 0); // the_Vector=0 needs no remap, simplest case to verify against

    // apply_currentCamera() ran, mirroring the camera's new (rotated) position into WIN3D.
    assertEquals(app.allCameras.options[0][0], app.WIN3D.position_X, 0.0001f);
    assertEquals(app.allCameras.options[0][1], app.WIN3D.position_Y, 0.0001f);
    assertEquals(app.allCameras.options[0][2], app.WIN3D.position_Z, 0.0001f);
  }

  // ================= Model1Ds ==========================================

  @Test
  void model1Ds_rotatesPositionAndSubtractsRFromItsOwnRotationOnlyForZAxis () {
    app.allModel1Ds.f_data = new float[][]{new float[11], new float[11]};
    app.allModel1Ds.f_data[0][0] = 1; // X
    app.allModel1Ds.f_data[0][4] = 5; // its own rotation field
    app.allModel1Ds.f_data[1][0] = 1;
    app.allModel1Ds.f_data[1][4] = 5;

    // Rotate index 0 around Z only - index 1 is never included in this
    // call, so it can't be affected by it.
    app.Select3D.Model1D_ids = new int[]{0};
    app.Rotate3D.Model1Ds(0, 0, 0, HALF_PI, 2);
    assertEquals(5f - HALF_PI, app.allModel1Ds.f_data[0][4], 0.0001f); // Z: own rotation updated

    // Rotate index 1 around X only, in a completely separate call.
    app.Select3D.Model1D_ids = new int[]{1};
    app.Rotate3D.Model1Ds(0, 0, 0, HALF_PI, 0);
    assertEquals(5f, app.allModel1Ds.f_data[1][4], 0.0001f); // X: own rotation untouched
  }

  // ================= Model2Ds ==========================================

  @Test
  void model2Ds_rotatesPositionOnly () {
    app.allModel2Ds.XYZS = new float[][]{new float[4]};
    app.allModel2Ds.XYZS[0][0] = 1;

    app.Select3D.Model2D_ids = new int[]{0};

    app.Rotate3D.Model2Ds(0, 0, 0, HALF_PI, 2);

    assertArrayEquals(new float[]{0, 1, 0}, java.util.Arrays.copyOf(app.allModel2Ds.XYZS[0], 3), 0.0001f);
  }

  // ================= Groups (full integration tests) ====================

  @Test
  void groups_rotatesTheGroupsOwnVerticesAndPivotIncludingThePivotsOwnZRotation () {
    app.allVertices = new float[][]{{1, 0, 0}};
    app.allFaces.nodes = new int[][]{{0}};
    app.allPolylines.nodes = new int[0][];

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};
    app.allGroups.Polylines[0] = new int[]{0, -1};
    app.allGroups.Model1Ds[0] = new int[]{0, -1};
    app.allGroups.Model2Ds[0] = new int[]{0, -1};
    app.allGroups.Solids[0] = new int[]{0, -1};
    app.allGroups.Pivots[0] = new float[]{1, 0, 0, 1, 1, 1, 0, 0, 0};

    app.Select3D.Group_ids = new int[]{0};

    app.Rotate3D.Groups(HALF_PI, 2);

    assertArrayEquals(new float[]{0, 1, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{0, 1, 0}, java.util.Arrays.copyOf(app.allGroups.Pivots[0], 3), 0.0001f);
    assertEquals(90f, app.allGroups.Pivots[0][8], 0.001f); // Pivots[8] = its own Z rotation, in degrees
  }

  @Test
  void groups_rotatesOwnedModel1DsPositionButDoesNotUpdateItsOwnRotationField () {
    // Found bug (not fixed here, flagged for confirmation): the direct
    // Model1Ds() function above DOES update the model's own rotation
    // field for a Z-axis rotation (setRotation(f, getRotation(f) - r)),
    // but this exact same line is present here too, just commented out
    // ("//allModel1Ds.setRotation(f, allModel1Ds.getRotation(f) + r);"),
    // with the if/else-if branches left empty. The practical effect: a
    // Model1D rotated as part of a GROUP rotation swings around the
    // group's pivot correctly, but its own individual orientation is
    // left exactly as it was - while rotating that SAME Model1D directly
    // (not as part of a group) DOES update its orientation. This test
    // locks in the current (likely unintended) behavior rather than the
    // one Model1Ds() itself would suggest.
    app.allVertices = new float[0][3];
    app.allFaces.nodes = new int[0][];
    app.allPolylines.nodes = new int[0][];

    app.allModel1Ds.f_data = new float[][]{new float[11]};
    app.allModel1Ds.f_data[0][0] = 1; // X
    app.allModel1Ds.f_data[0][4] = 5; // its own rotation field
    app.allModel1Ds.num = 1;

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, -1};
    app.allGroups.Polylines[0] = new int[]{0, -1};
    app.allGroups.Model1Ds[0] = new int[]{0, 0};
    app.allGroups.Model2Ds[0] = new int[]{0, -1};
    app.allGroups.Solids[0] = new int[]{0, -1};
    app.allGroups.Pivots[0] = new float[9];

    app.Select3D.Group_ids = new int[]{0};

    app.Rotate3D.Groups(HALF_PI, 2);

    assertArrayEquals(new float[]{0, 1, 0}, java.util.Arrays.copyOf(app.allModel1Ds.f_data[0], 3), 0.0001f);
    assertEquals(5f, app.allModel1Ds.f_data[0][4], 0.0001f); // unchanged, unlike the direct Model1Ds() path
  }

  @Test
  void groups_cascadesIntoOwnedSolidsIncludingTheirOwnRotation () {
    app.allVertices = new float[0][3];
    app.allFaces.nodes = new int[0][];
    app.allPolylines.nodes = new int[0][];

    app.allSolids.DEF = new float[][]{new float[13]};
    app.allSolids.DEF[0][0] = 1;

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, -1};
    app.allGroups.Polylines[0] = new int[]{0, -1};
    app.allGroups.Model1Ds[0] = new int[]{0, -1};
    app.allGroups.Model2Ds[0] = new int[]{0, -1};
    app.allGroups.Solids[0] = new int[]{0, 0};
    app.allGroups.Pivots[0] = new float[9];

    app.Select3D.Group_ids = new int[]{0};
    // Section_ids left empty, same reasoning as the Solids() test's
    // sibling in Move3DTest/Scale3DTest.

    app.Rotate3D.Groups(HALF_PI, 2);

    assertArrayEquals(new float[]{0, 1, 0}, java.util.Arrays.copyOf(app.allSolids.DEF[0], 3), 0.0001f);
    assertEquals(90f, app.allSolids.DEF[0][11], 0.001f); // unlike Model1Ds, Solids' own rotation DOES update here
  }
}
