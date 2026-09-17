import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Exercises the spatial-grid math and per-face ray/triangle test in
// isIntersected_Faces.pde: cellIndexX/Y/Z, cellFlatIndex,
// rayHitsGridBounds, and SOLARCHVISION_testFaceHit.
//
// This .pde tab has no `class solarchvision_X { ... }` wrapper - it's
// plain fields and functions, so Processing's preprocessor splices them
// directly into the generated solarchvision_bim class instead of a
// nested inner class. That means the grid's state (gridMinX, cellSizeX,
// entirePointsX, entireFaces, ...) is just package-private fields on
// `app` itself, settable directly - which lets these tests build a tiny,
// fully-controlled scene (a single triangle, an explicit bounding box)
// by hand instead of going through the expensive, rendering-dependent
// SOLARCHVISION_buildFaceGrid() (which walks the real scene via
// allFaces.draw(TypeWindow.RENDER)).
//
// NOT covered here: SOLARCHVISION_isIntersected_Faces() and
// intersectAll(), the grid-traversal entry points - they need a fully
// populated grid (gridCells, faceTestStamp, ...) that SOLARCHVISION_
// buildFaceGrid() would normally set up. Worth adding once there's a way
// to build that minimal grid state by hand too.
//
// A fresh `app` per test (not a shared @BeforeAll instance) since these
// tests mutate shared mutable fields (entirePointsX, entireFaces, grid
// bounds) - isolating each test avoids one test's scene leaking into
// another's.
class FaceIntersectionTest {

  private solarchvision_bim app;
  private static final float EPS = 0.001f;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // --- cellIndexX / cellIndexY / cellIndexZ ---------------------------

  @Test
  void cellIndexX_mapsWorldCoordinatesToCellIndices () {
    app.gridMinX = 0;
    app.gridNx = 5;
    app.cellSizeX = 2; // 5 cells covering [0, 10)

    assertEquals(0, app.cellIndexX(0));
    assertEquals(0, app.cellIndexX(1.9f));
    assertEquals(1, app.cellIndexX(2.0f));
    assertEquals(4, app.cellIndexX(9.999f));
  }

  @Test
  void cellIndexX_clampsOutOfRangeCoordinatesToTheEdgeCell () {
    app.gridMinX = 0;
    app.gridNx = 5;
    app.cellSizeX = 2;

    assertEquals(0, app.cellIndexX(-5));   // below the grid: clamp to the first cell
    assertEquals(4, app.cellIndexX(100));  // beyond the grid: clamp to the last cell
  }

  @Test
  void cellIndexY_and_cellIndexZ_useTheirOwnAxisFields () {
    // Different bounds/resolution per axis, to catch any accidental
    // cross-wiring between the X/Y/Z implementations.
    app.gridMinY = -10;
    app.gridNy = 10;
    app.cellSizeY = 1; // 10 cells covering [-10, 0)

    app.gridMinZ = 100;
    app.gridNz = 2;
    app.cellSizeZ = 5; // 2 cells covering [100, 110)

    assertEquals(0, app.cellIndexY(-10));
    assertEquals(3, app.cellIndexY(-7));
    assertEquals(9, app.cellIndexY(-0.5f));

    assertEquals(0, app.cellIndexZ(100));
    assertEquals(1, app.cellIndexZ(106));
  }

  @Test
  void cellFlatIndex_isUniqueAcrossTheWholeGrid () {
    // Note: cellFlatIndex's formula ((ix * gridNy + iy) * gridNz + iz)
    // doesn't reference gridNx at all - the caller is expected to keep
    // ix < gridNx itself, so it's left unset here.
    app.gridNy = 10;
    app.gridNz = 2;

    assertEquals(0, app.cellFlatIndex(0, 0, 0));
    assertEquals(25, app.cellFlatIndex(1, 2, 1)); // (1*10 + 2) * 2 + 1
    assertEquals(99, app.cellFlatIndex(4, 9, 1)); // (4*10 + 9) * 2 + 1 - last cell of a 5x10x2 grid
  }

  // --- rayHitsGridBounds ------------------------------------------

  private void setUnitCubeBounds () {
    app.gridMinX = app.gridMinY = app.gridMinZ = 0;
    app.gridMaxX = app.gridMaxY = app.gridMaxZ = 10;
  }

  @Test
  void rayHitsGridBounds_findsTheEntryDistanceFromOutside () {
    setUnitCubeBounds();
    float[] tEnter = new float[1];
    boolean hit = app.rayHitsGridBounds(
      new float[]{-5, 5, 5}, new float[]{1, 0, 0}, tEnter);
    assertTrue(hit);
    assertEquals(5f, tEnter[0], EPS);
  }

  @Test
  void rayHitsGridBounds_missesWhenTheBoxIsBehindTheRay () {
    setUnitCubeBounds();
    float[] tEnter = new float[1];
    boolean hit = app.rayHitsGridBounds(
      new float[]{-5, 5, 5}, new float[]{-1, 0, 0}, tEnter);
    assertFalse(hit);
  }

  @Test
  void rayHitsGridBounds_clampsEntryToZeroWhenStartingInsideTheBox () {
    setUnitCubeBounds();
    float[] tEnter = new float[1];
    boolean hit = app.rayHitsGridBounds(
      new float[]{5, 5, 5}, new float[]{1, 0, 0}, tEnter);
    assertTrue(hit);
    assertEquals(0f, tEnter[0], EPS);
  }

  @Test
  void rayHitsGridBounds_missesWhenOffToTheSideOnAParallelAxis () {
    setUnitCubeBounds();
    float[] tEnter = new float[1];
    // Moving parallel to X, but sitting at y=50 - outside [0,10] on an
    // axis the ray never moves along, so it can never enter the box.
    boolean hit = app.rayHitsGridBounds(
      new float[]{-5, 50, 5}, new float[]{1, 0, 0}, tEnter);
    assertFalse(hit);
  }

  // --- SOLARCHVISION_testFaceHit (triangle branch) --------------------

  // Builds a single triangle face (A=(0,0,0), B=(2,0,0), C=(0,2,0), in
  // the z=0 plane) as face index 1, bypassing SOLARCHVISION_buildFaceGrid
  // entirely - just the raw point/face lists it would otherwise populate
  // from the real scene.
  private void buildSingleTriangleFace () {
    app.entirePointsX = new java.util.ArrayList<Float>();
    app.entirePointsY = new java.util.ArrayList<Float>();
    app.entirePointsZ = new java.util.ArrayList<Float>();
    app.entireFaces = new java.util.ArrayList<int[]>();
    app.entireFaces.add(new int[0]); // index 0 is reserved/empty, as SOLARCHVISION_buildFaceGrid does

    float[][] triangle = {{0, 0, 0}, {2, 0, 0}, {0, 2, 0}};
    for (float[] p : triangle) {
      app.entirePointsX.add(p[0]);
      app.entirePointsY.add(p[1]);
      app.entirePointsZ.add(p[2]);
    }
    app.entireFaces.add(new int[]{0, 1, 2});
  }

  @Test
  void testFaceHit_hitsWhenTheRayCrossesTheTriangleInterior () {
    buildSingleTriangleFace();
    float[] P = new float[3];
    float[] N = new float[3];
    float dist = app.SOLARCHVISION_testFaceHit(
      1, new float[]{0.5f, 0.5f, 10}, new float[]{0, 0, -1}, P, N);

    assertEquals(10f, dist, EPS);
    assertArrayEquals(new float[]{0.5f, 0.5f, 0}, P, EPS);
    assertArrayEquals(new float[]{0, 0, 1}, N, EPS);
  }

  @Test
  void testFaceHit_missesWhenThePlaneHitLandsOutsideTheTriangle () {
    buildSingleTriangleFace();
    float[] P = new float[3];
    float dist = app.SOLARCHVISION_testFaceHit(
      1, new float[]{5, 5, 10}, new float[]{0, 0, -1}, P);
    assertEquals(app.FLOAT_huge, dist, EPS);
  }

  @Test
  void testFaceHit_missesWhenTheIntersectionIsBehindTheRayOrigin () {
    buildSingleTriangleFace();
    float[] P = new float[3];
    // Ray starts below the plane and points further away from it.
    float dist = app.SOLARCHVISION_testFaceHit(
      1, new float[]{0.5f, 0.5f, -10}, new float[]{0, 0, -1}, P);
    assertEquals(app.FLOAT_huge, dist, EPS);
  }

  @Test
  void testFaceHit_returnsHugeImmediatelyForADegenerateFace () {
    app.entirePointsX = new java.util.ArrayList<Float>();
    app.entirePointsY = new java.util.ArrayList<Float>();
    app.entirePointsZ = new java.util.ArrayList<Float>();
    app.entireFaces = new java.util.ArrayList<int[]>();
    app.entireFaces.add(new int[0]);
    app.entirePointsX.add(0f); app.entirePointsY.add(0f); app.entirePointsZ.add(0f);
    app.entirePointsX.add(1f); app.entirePointsY.add(0f); app.entirePointsZ.add(0f);
    app.entireFaces.add(new int[]{0, 1}); // only 2 nodes - not a polygon

    float[] P = new float[3];
    float dist = app.SOLARCHVISION_testFaceHit(
      1, new float[]{0, 0, 10}, new float[]{0, 0, -1}, P);
    assertEquals(app.FLOAT_huge, dist, EPS);
  }
}
