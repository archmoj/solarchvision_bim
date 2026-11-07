import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.util.ArrayList;

// meshPointCloud_gridXY() (meshPointCloudGrid.pde) is pure geometry -
// like meshPointCloud_delaunayXY() (see MeshPointCloudTest.java's own
// comment), directly testable from a bare, never-setup()'d instance
// with no file I/O at all.
class MeshPointCloudGridTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= degenerate / rejected input ======================================================

  @Test
  void meshPointCloudGrid_fewerThanFourPoints_returnsEmptyList () {
    // meshPointCloud_gridXY()'s own minimum (4) is higher than Delaunay's
    // own (3) - even a single fully-occupied 2x2 block of cells needs at
    // least that many distinct points to ever exist at all.
    ArrayList<int[]> result = app.meshPointCloud_gridXY(new float[]{ 0, 1, 2 }, new float[]{ 0, 1, 0 }, null);
    assertNotNull(result);
    assertEquals(0, result.size());
  }

  @Test
  void meshPointCloudGrid_mismatchedArrayLengths_returnsEmptyListWithoutThrowing () {
    assertDoesNotThrow(() -> {
      ArrayList<int[]> result = app.meshPointCloud_gridXY(new float[]{ 0, 1, 2, 3 }, new float[]{ 0, 1, 2 }, null);
      assertEquals(0, result.size());
    });
  }

  @Test
  void meshPointCloudGrid_overTheMaxPointsCap_returnsEmptyListWithoutThrowing () {
    int n = app.MESH_POINT_CLOUD_GRID_MAX_POINTS + 1;
    float[] xs = new float[n];
    float[] ys = new float[n];
    for (int i = 0; i < n; i++) { xs[i] = i; ys[i] = i % 7; } // content doesn't matter - rejected on count alone

    assertDoesNotThrow(() -> {
      ArrayList<int[]> result = app.meshPointCloud_gridXY(xs, ys, null);
      assertEquals(0, result.size());
    });
  }

  // ================= basic quad creation ======================================================

  @Test
  void meshPointCloudGrid_fourCornersOfASquare_producesExactlyOneQuadInBoundaryOrder () {
    // n = 4 - meshPointCloud_gridXY()'s own floor-at-2-cells-per-axis
    // (meshPointCloudGrid.pde's own comment on that) means this always
    // sizes down to a 2x2 grid regardless of MESH_POINT_CLOUD_GRID_
    // TARGET_POINTS_PER_CELL, with each of these 4 points landing in its
    // own distinct corner cell - exactly one 2x2 block exists, so
    // exactly one quad comes out, and with these points this clean,
    // their own index order IS the quad's own (p00, p10, p11, p01)
    // boundary-walk order.
    float[] xs = { 0, 1, 1, 0 };
    float[] ys = { 0, 0, 1, 1 };

    ArrayList<int[]> result = app.meshPointCloud_gridXY(xs, ys, null);

    assertEquals(1, result.size());
    assertArrayEquals(new int[]{ 0, 1, 2, 3 }, result.get(0));
  }

  // ================= fill pass ======================================================

  @Test
  void meshPointCloudGrid_fillPass_bridgesAnEmptyCenterCell () {
    // A 3x3 grid of cells (gridCols == gridRows == 3, see the n/aspect
    // math below), 4 points placed at the exact center of 8 of its 9
    // cells - every cell EXCEPT the middle one (1, 1), deliberately left
    // with no point of its own at all. Without the fill pass
    // (meshPointCloud_gridXY()'s own comment on it), every one of the 4
    // possible 2x2 blocks in a 3x3 grid touches that empty center cell,
    // so all 4 would be skipped as holes and this would return nothing;
    // with it, the center cell borrows a neighbor's own representative
    // and all 4 blocks become real quads.
    //
    // n = 32 (8 cells x 4 points each) makes targetCellCount = 32/4 = 8,
    // and round(sqrt(8)) = 3 - the same MESH_POINT_CLOUD_GRID_TARGET_
    // POINTS_PER_CELL this file reuses directly from meshPointCloudGrid.
    // pde, not a number invented just for this test.
    ArrayList<Float> xsList = new ArrayList<Float>();
    ArrayList<Float> ysList = new ArrayList<Float>();
    for (int cx = 0; cx < 3; cx++) {
      for (int cy = 0; cy < 3; cy++) {
        if ((cx == 1) && (cy == 1)) continue; // the deliberately-empty center cell
        for (int p = 0; p < 4; p++) {
          xsList.add(cx + 0.5f);
          ysList.add(cy + 0.5f);
        }
      }
    }

    float[] xs = new float[xsList.size()];
    float[] ys = new float[ysList.size()];
    for (int i = 0; i < xs.length; i++) { xs[i] = xsList.get(i); ys[i] = ysList.get(i); }

    assertEquals(32, xs.length); // 8 cells x 4 points - sanity-checks the setup above, not the algorithm itself

    ArrayList<int[]> result = app.meshPointCloud_gridXY(xs, ys, null);

    assertEquals(4, result.size(), "all 4 of a 3x3 grid's own 2x2 blocks should survive once the center cell is filled");
  }

  // ================= progress reporting ======================================================

  @Test
  void meshPointCloudGrid_progressListener_calledOncePerPointInIncreasingOrder () {
    float[] xs = { 0, 1, 1, 0 };
    float[] ys = { 0, 0, 1, 1 };
    int n = xs.length;

    ArrayList<Integer> insertedCounts = new ArrayList<Integer>();
    ArrayList<Integer> totalCounts = new ArrayList<Integer>();

    app.meshPointCloud_gridXY(xs, ys, (inserted, total) -> {
      insertedCounts.add(inserted);
      totalCounts.add(total);
    });

    assertEquals(n, insertedCounts.size(), "one call per point BINNED - see meshPointCloud_gridXY()'s own progress comment for why that's a different operation from Delaunay's own \"per point inserted\"");
    for (int i = 0; i < n; i++) {
      assertEquals(i + 1, insertedCounts.get(i));
      assertEquals(n, totalCounts.get(i));
    }
  }

  @Test
  void meshPointCloudGrid_nullProgressListener_doesNotThrow () {
    assertDoesNotThrow(() -> {
      app.meshPointCloud_gridXY(new float[]{ 0, 1, 1, 0 }, new float[]{ 0, 0, 1, 1 }, null);
    });
  }
}
