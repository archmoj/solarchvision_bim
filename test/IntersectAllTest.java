import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// intersectAll() (isIntersectedFaces.pde) has 3 overloads - the 2-arg and
// 3-arg convenience wrappers, and the explicit-stamp implementation they
// both ultimately delegate to - all at 0% coverage, even though what it
// calls (isIntersected_Faces()/testFaceHit()) is already covered directly
// by FaceIntersectionTest.java. intersectAll() itself does real work on
// top of those two: combining a hit/miss result with the P/N/distance
// lookup into the single 8-float array callers actually use (face id,
// P.x/y/z, distance, N.x/y/z), including the "no hit" sentinel array
// neither lower-level function returns on its own.
//
// Reuses FaceIntersectionTest.java's own exact minimal single-triangle,
// single-cell grid setup (buildSingleTriangleFace()/buildSingleTriangleGrid(),
// same field values) so the expected hit result here - face 1, P=(0.5,0.5,0),
// dist=10, N=(0,0,1) - is the same one that file's own
// testFaceHit_hitsWhenTheRayCrossesTheTriangleInterior test already
// derives and pins for the same ray.
class IntersectAllTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  private void buildSingleTriangleFace () {
    app.entirePointsX = new java.util.ArrayList<Float>();
    app.entirePointsY = new java.util.ArrayList<Float>();
    app.entirePointsZ = new java.util.ArrayList<Float>();
    app.entireFaces = new java.util.ArrayList<int[]>();
    app.entireFaces.add(new int[0]); // index 0 is reserved/empty, as buildFaceGrid does

    float[][] triangle = {{0, 0, 0}, {2, 0, 0}, {0, 2, 0}};
    for (float[] p : triangle) {
      app.entirePointsX.add(p[0]);
      app.entirePointsY.add(p[1]);
      app.entirePointsZ.add(p[2]);
    }
    app.entireFaces.add(new int[]{0, 1, 2});
  }

  private void buildSingleTriangleGrid (boolean castsShadow) {
    buildSingleTriangleFace();

    app.gridMinX = app.gridMinY = -10;
    app.gridMinZ = -10;
    app.gridMaxX = app.gridMaxY = 10;
    app.gridMaxZ = 20;
    app.gridNx = app.gridNy = app.gridNz = 1;
    app.cellSizeX = (app.gridMaxX - app.gridMinX) / app.gridNx;
    app.cellSizeY = (app.gridMaxY - app.gridMinY) / app.gridNy;
    app.cellSizeZ = (app.gridMaxZ - app.gridMinZ) / app.gridNz;

    app.gridCells = new processing.data.IntList[1];
    app.gridCells[0] = new processing.data.IntList();
    app.gridCells[0].append(1); // our one real face, index 1

    app.faceTestStampSize = 2; // getRayStampState() lazily sizes this thread's own array from this - see that method's own comment

    app.entireFaceCastsShadow = new java.util.ArrayList<Boolean>();
    app.entireFaceCastsShadow.add(true);  // index 0, unused here
    app.entireFaceCastsShadow.add(castsShadow);
  }

  private static final float EPS = 0.001f;

  @Test
  void twoArgOverload_onAHit_returnsFaceIdPointDistanceAndNormalTogether () {
    buildSingleTriangleGrid(true);

    float[] result = app.intersectAll(new float[]{0.5f, 0.5f, 10}, new float[]{0, 0, -1});

    assertEquals(8, result.length);
    assertEquals(1f, result[0], EPS);   // face id
    assertEquals(0.5f, result[1], EPS); // P.x
    assertEquals(0.5f, result[2], EPS); // P.y
    assertEquals(0f, result[3], EPS);   // P.z
    assertEquals(10f, result[4], EPS);  // distance
    assertEquals(0f, result[5], EPS);   // N.x
    assertEquals(0f, result[6], EPS);   // N.y
    assertEquals(1f, result[7], EPS);   // N.z
  }

  @Test
  void threeArgOverload_withAFirstGuess_returnsTheSameHitResult () {
    buildSingleTriangleGrid(true);

    // firstGuess is only a fast-path hint (its own comment) - the result
    // must be identical whether or not it happens to guess right.
    float[] result = app.intersectAll(new float[]{0.5f, 0.5f, 10}, new float[]{0, 0, -1}, 1);

    assertEquals(1f, result[0], EPS);
    assertEquals(10f, result[4], EPS);
  }

  @Test
  void onAMiss_returnsTheSentinelArrayWithFaceIdMinusOneAndUndefinedFields () {
    buildSingleTriangleGrid(true);

    // Same ray origin, but pointing away from the triangle instead of
    // toward it (+Z instead of -Z) - never hits anything in the grid.
    float[] result = app.intersectAll(new float[]{0.5f, 0.5f, 10}, new float[]{0, 0, 1});

    assertEquals(8, result.length);
    assertEquals(-1f, result[0], EPS);
    for (int i = 1; i < 8; i++) {
      assertEquals(app.FLOAT_undefined, result[i], EPS, "index " + i + " must stay undefined on a miss");
    }
  }
}
