import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.util.ArrayList;

// meshPointCloud_delaunayXY() (meshPointCloud.pde) is pure geometry - it
// never touches allPoints/allFaces/current_Material/... or anything else
// app-specific (see that file's own header comment for why) - so unlike
// most of this app, it's directly testable from a bare, never-setup()'d
// instance with no file I/O, no BaseFolder, no sketchPath() at all.
//
// These tests check real, known-in-advance Delaunay triangulation shapes
// (a square, a square with its own center point) rather than just "it
// doesn't throw" - the standard Euler-formula relationship for a planar
// point-set triangulation, triangles = 2n - h - 2 (n points, h of them
// on the convex hull), is what pins each expected triangle count down,
// not a number picked by just running the code once and copying its
// output.
class MeshPointCloudTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= degenerate / rejected input ======================================================

  @Test
  void meshPointCloud_fewerThanThreePoints_returnsEmptyList () {
    ArrayList<int[]> result = app.meshPointCloud_delaunayXY(new float[]{ 0, 1 }, new float[]{ 0, 1 }, null);
    assertNotNull(result);
    assertEquals(0, result.size());
  }

  @Test
  void meshPointCloud_mismatchedArrayLengths_returnsEmptyListWithoutThrowing () {
    // A caller bug (pairing xs/ys of different lengths) - see
    // meshPointCloud_delaunayXY()'s own header comment for why this is
    // "nothing to triangulate" rather than an error.
    assertDoesNotThrow(() -> {
      ArrayList<int[]> result = app.meshPointCloud_delaunayXY(new float[]{ 0, 1, 2 }, new float[]{ 0, 1 }, null);
      assertEquals(0, result.size());
    });
  }

  @Test
  void meshPointCloud_overTheMaxPointsCap_returnsEmptyListWithoutThrowing () {
    int n = app.MESH_POINT_CLOUD_DELAUNAY_MAX_POINTS + 1;
    float[] xs = new float[n];
    float[] ys = new float[n];
    for (int i = 0; i < n; i++) { xs[i] = i; ys[i] = i % 7; } // content doesn't matter - this is rejected on count alone, before any point is ever looked at

    assertDoesNotThrow(() -> {
      ArrayList<int[]> result = app.meshPointCloud_delaunayXY(xs, ys, null);
      assertEquals(0, result.size());
    });
  }

  @Test
  void meshPointCloud_collinearPoints_doesNotThrow () {
    // 3 points on a single line - meshMakeTriangle()'s own degenerate-
    // circumcircle fallback (meshPointCloud.pde) is what this exercises;
    // no real circumcircle exists for collinear points.
    assertDoesNotThrow(() -> {
      app.meshPointCloud_delaunayXY(new float[]{ 0, 1, 2 }, new float[]{ 0, 0, 0 }, null);
    });
  }

  @Test
  void meshPointCloud_everyPointCoincident_doesNotThrow () {
    // Every point at the exact same (x, y) - spanMax would be 0 without
    // meshPointCloud_delaunayXY()'s own "spanMax <= 0 -> 1" guard
    // (meshPointCloud.pde), which this is specifically here to exercise.
    assertDoesNotThrow(() -> {
      app.meshPointCloud_delaunayXY(new float[]{ 5, 5, 5 }, new float[]{ 5, 5, 5 }, null);
    });
  }

  // ================= known triangulation shapes ======================================================

  @Test
  void meshPointCloud_fourCornersOfASquare_triangulatesIntoExactlyTwoTriangles () {
    // n = 4, all 4 on the convex hull (h = 4): triangles = 2n - h - 2 =
    // 2*4 - 4 - 2 = 2 - the textbook minimal case.
    float[] xs = { 0, 1, 1, 0 };
    float[] ys = { 0, 0, 1, 1 };

    ArrayList<int[]> result = app.meshPointCloud_delaunayXY(xs, ys, null);

    assertEquals(2, result.size());
    assertEveryTriangleHasThreeDistinctValidIndices(result, 4);
    assertEveryPointCovered(result, 4);
  }

  @Test
  void meshPointCloud_squareWithItsOwnCenterPoint_triangulatesIntoExactlyFourTriangles () {
    // n = 5 (the square's own 4 corners + its exact center), h = 4 (the
    // center is strictly interior, not on the hull): triangles =
    // 2*5 - 4 - 2 = 4 - the classic "pinwheel" split of a square around
    // its own center.
    float[] xs = { 0, 1, 1, 0, 0.5f };
    float[] ys = { 0, 0, 1, 1, 0.5f };

    ArrayList<int[]> result = app.meshPointCloud_delaunayXY(xs, ys, null);

    assertEquals(4, result.size());
    assertEveryTriangleHasThreeDistinctValidIndices(result, 5);
    assertEveryPointCovered(result, 5);
  }

  @Test
  void meshPointCloud_scatteredPoints_coversEveryPointWithValidNonDegenerateTriangles () {
    // No exact expected count here (an arbitrary scattered set's own
    // convex hull size isn't worth computing by hand just to pin one
    // down) - instead, the structural properties any correct
    // triangulation of this point set must have: every point index used
    // at least once, every triangle made of 3 distinct, in-range
    // indices, and at least n - 2 triangles (the minimum any planar
    // triangulation of n points can have, when every point sits on the
    // convex hull - the least a correct result could ever produce).
    float[] xs = { 0, 2, 1, 3, 0, 4, 2.5f };
    float[] ys = { 0, 0, 3, 3, 4, 1, 1.5f };
    int n = xs.length;

    ArrayList<int[]> result = app.meshPointCloud_delaunayXY(xs, ys, null);

    assertTrue(result.size() >= n - 2, "expected at least " + (n - 2) + " triangles, got " + result.size());
    assertEveryTriangleHasThreeDistinctValidIndices(result, n);
    assertEveryPointCovered(result, n);
  }

  // ================= progress reporting ======================================================

  @Test
  void meshPointCloud_progressListener_calledOncePerPointInIncreasingOrder () {
    float[] xs = { 0, 1, 1, 0, 0.5f };
    float[] ys = { 0, 0, 1, 1, 0.5f };
    int n = xs.length;

    ArrayList<Integer> insertedCounts = new ArrayList<Integer>();
    ArrayList<Integer> totalCounts = new ArrayList<Integer>();

    app.meshPointCloud_delaunayXY(xs, ys, (inserted, total) -> {
      insertedCounts.add(inserted);
      totalCounts.add(total);
    });

    assertEquals(n, insertedCounts.size(), "one call per real point, never for the 3 internal super-triangle points");
    for (int i = 0; i < n; i++) {
      assertEquals(i + 1, insertedCounts.get(i), "pointsInserted should count up from 1");
      assertEquals(n, totalCounts.get(i), "totalPoints should always equal n");
    }
  }

  @Test
  void meshPointCloud_nullProgressListener_doesNotThrow () {
    assertDoesNotThrow(() -> {
      app.meshPointCloud_delaunayXY(new float[]{ 0, 1, 2 }, new float[]{ 0, 1, 0 }, null);
    });
  }

  // ================= insertion-order helper (meshSpatialSortOrder) ===========================

  @Test
  void meshSpatialSortOrder_returnsAValidPermutationOfEveryIndex () {
    // See meshSpatialSortOrder()'s own comment (meshPointCloud.pde) for
    // why insertion order is chosen deliberately rather than left as
    // plain array order - this only checks that whatever order it picks
    // is still a genuine permutation (every index 0..n-1 exactly once),
    // since the final triangulation's own correctness is already
    // covered by the tests above, regardless of what order fed it.
    float[] xs = { 5, 1, 9, 3, 7, 2, 8, 4, 6, 0 };
    float[] ys = { 2, 8, 1, 6, 4, 9, 0, 5, 3, 7 };
    int n = xs.length;

    float minX = 0, maxX = 9, minY = 0, maxY = 9;
    int[] order = app.meshSpatialSortOrder(xs, ys, n, minX, maxX, minY, maxY);

    assertEquals(n, order.length);

    boolean[] seen = new boolean[n];
    for (int index : order) {
      assertTrue((index >= 0) && (index < n), "index " + index + " out of range");
      assertFalse(seen[index], "index " + index + " appeared more than once");
      seen[index] = true;
    }
    for (int i = 0; i < n; i++) {
      assertTrue(seen[i], "index " + i + " never appeared in the order");
    }
  }

  // ================= shared assertions ======================================================

  private void assertEveryTriangleHasThreeDistinctValidIndices (ArrayList<int[]> triangles, int n) {
    for (int[] t : triangles) {
      assertEquals(3, t.length);
      assertTrue((t[0] >= 0) && (t[0] < n) && (t[1] >= 0) && (t[1] < n) && (t[2] >= 0) && (t[2] < n),
          "triangle index out of range [0, " + n + "): " + t[0] + ", " + t[1] + ", " + t[2]);
      assertTrue((t[0] != t[1]) && (t[1] != t[2]) && (t[0] != t[2]),
          "degenerate triangle with a repeated vertex: " + t[0] + ", " + t[1] + ", " + t[2]);
    }
  }

  private void assertEveryPointCovered (ArrayList<int[]> triangles, int n) {
    boolean[] covered = new boolean[n];
    for (int[] t : triangles) {
      covered[t[0]] = true;
      covered[t[1]] = true;
      covered[t[2]] = true;
    }
    for (int i = 0; i < n; i++) {
      assertTrue(covered[i], "point " + i + " was never used by any triangle");
    }
  }
}
