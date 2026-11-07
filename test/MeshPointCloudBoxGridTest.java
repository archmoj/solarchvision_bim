import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.util.ArrayList;

// meshPointCloud_boxGridXY() (meshPointCloudBoxGrid.pde) is pure
// geometry - like meshPointCloud_delaunayXY()/meshPointCloud_gridXY()
// (see MeshPointCloudTest.java's/MeshPointCloudGridTest.java's own
// comments), directly testable from a bare, never-setup()'d instance
// with no file I/O at all.
//
// BoxGridCell (meshPointCloudBoxGrid.pde) is a non-static inner class
// of solarchvision_bim (unlike MeshPointCloudProgressListener, an
// interface - implicitly static regardless of where it's declared, so
// that one needs no qualification at all) - every reference to its own
// TYPE below is written out as solarchvision_bim.BoxGridCell for
// exactly that reason.
class MeshPointCloudBoxGridTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= degenerate / rejected input ======================================================

  @Test
  void meshPointCloudBoxGrid_emptyInput_returnsEmptyList () {
    ArrayList<solarchvision_bim.BoxGridCell> result = app.meshPointCloud_boxGridXY(new float[0], new float[0], new float[0], null);
    assertNotNull(result);
    assertEquals(0, result.size());
  }

  @Test
  void meshPointCloudBoxGrid_mismatchedArrayLengths_returnsEmptyListWithoutThrowing () {
    assertDoesNotThrow(() -> {
      ArrayList<solarchvision_bim.BoxGridCell> result = app.meshPointCloud_boxGridXY(new float[]{ 0, 1 }, new float[]{ 0, 1 }, new float[]{ 0 }, null);
      assertEquals(0, result.size());
    });
  }

  @Test
  void meshPointCloudBoxGrid_overTheMaxPointsCap_returnsEmptyListWithoutThrowing () {
    int n = app.MESH_POINT_CLOUD_GRID_MAX_POINTS + 1;
    float[] xs = new float[n];
    float[] ys = new float[n];
    float[] zs = new float[n];
    for (int i = 0; i < n; i++) { xs[i] = i; ys[i] = i % 7; zs[i] = 0; }

    assertDoesNotThrow(() -> {
      ArrayList<solarchvision_bim.BoxGridCell> result = app.meshPointCloud_boxGridXY(xs, ys, zs, null);
      assertEquals(0, result.size());
    });
  }

  // ================= grid-aligned geometry (the whole point of this algorithm) ===========================

  @Test
  void meshPointCloudBoxGrid_everyCellSharesTheSameWidthAndHeight_confirmingGridAlignment () {
    // The one property that distinguishes this algorithm from
    // meshPointCloud_gridXY()'s own quad - see meshPointCloudBoxGrid.
    // pde's own header comment ("orthogonal"/grid-aligned, not the real
    // scattered point positions): every cell's own rectangle comes from
    // the GRID itself, uniform across the whole mesh, never from how
    // close together or far apart the real points underneath it happen
    // to be. 4 points, placed with no regular spacing between them at
    // all - if the resulting boxes were instead shaped by the points'
    // own real distances from each other, their own widths/heights
    // would vary just as irregularly; built from the grid instead, every
    // one of them must come out identical.
    float[] xs = { 0.1f, 1.2f, 1.3f, 0.4f };
    float[] ys = { 0.2f, 0.3f, 1.4f, 1.1f };
    float[] zs = { 5, 5, 5, 5 };

    ArrayList<solarchvision_bim.BoxGridCell> result = app.meshPointCloud_boxGridXY(xs, ys, zs, null);

    assertEquals(4, result.size());

    float width = result.get(0).maxX - result.get(0).minX;
    float height = result.get(0).maxY - result.get(0).minY;
    assertTrue(width > 0);
    assertTrue(height > 0);
    for (solarchvision_bim.BoxGridCell cell : result) {
      assertEquals(width, cell.maxX - cell.minX, 0.0001f, "every cell should share the same width - the grid's own, not the points' own spacing");
      assertEquals(height, cell.maxY - cell.minY, 0.0001f, "every cell should share the same height");
    }
  }

  // ================= fill pass ======================================================

  @Test
  void meshPointCloudBoxGrid_singlePoint_fillsAllFourCellsOfTheMinimumGrid () {
    // n = 1 - gridCols/gridRows floor at 2 each (meshPointCloudBoxGrid.
    // pde reuses meshPointCloudGrid.pde's own identical floor), giving a
    // 2x2 grid (4 cells) with only 1 real point to go around. Without
    // the fill pass, 3 of those 4 cells would come up empty and only 1
    // box would ever be produced; with it, every cell is within fill
    // radius of the one real point (a 2x2 grid's own cells are all
    // mutually Chebyshev-adjacent), so all 4 get a box - each with its
    // own distinct cell rectangle, but the SAME borrowed topZ.
    float[] xs = { 5 };
    float[] ys = { 5 };
    float[] zs = { 42 };

    ArrayList<solarchvision_bim.BoxGridCell> result = app.meshPointCloud_boxGridXY(xs, ys, zs, null);

    assertEquals(4, result.size());
    for (solarchvision_bim.BoxGridCell cell : result) {
      assertEquals(42f, cell.topZ, 0.001f, "every cell, including the 3 filled ones, should borrow the one real point's own Z");
    }
  }

  @Test
  void meshPointCloudBoxGrid_fillPass_bridgesAnEmptyCenterCell () {
    // Same 3x3-grid, deliberately-empty-center-cell construction as
    // MeshPointCloudGridTest.java's own identical test - see that test's
    // own comment for exactly why 32 points (8 cells x 4 points) gives a
    // 3x3 grid. Unlike the quad algorithm (which needs a whole 2x2
    // BLOCK, so the center cell being empty costs all 4 surrounding
    // blocks at once), this algorithm gives every cell its own
    // independent box - so without the fill pass this would be missing
    // exactly 1 of 9 possible boxes (8), and with it, all 9.
    ArrayList<Float> xsList = new ArrayList<Float>();
    ArrayList<Float> ysList = new ArrayList<Float>();
    ArrayList<Float> zsList = new ArrayList<Float>();
    for (int cx = 0; cx < 3; cx++) {
      for (int cy = 0; cy < 3; cy++) {
        if ((cx == 1) && (cy == 1)) continue;
        for (int p = 0; p < 4; p++) {
          xsList.add(cx + 0.5f);
          ysList.add(cy + 0.5f);
          zsList.add((float) (cx + cy)); // varying Z, just so no 2 cells are suspiciously identical
        }
      }
    }

    float[] xs = new float[xsList.size()];
    float[] ys = new float[ysList.size()];
    float[] zs = new float[zsList.size()];
    for (int i = 0; i < xs.length; i++) { xs[i] = xsList.get(i); ys[i] = ysList.get(i); zs[i] = zsList.get(i); }

    ArrayList<solarchvision_bim.BoxGridCell> result = app.meshPointCloud_boxGridXY(xs, ys, zs, null);

    assertEquals(9, result.size(), "all 9 of a 3x3 grid's own cells should have a box once the center one is filled");
  }

  // ================= progress reporting ======================================================

  @Test
  void meshPointCloudBoxGrid_progressListener_calledOncePerPointInIncreasingOrder () {
    float[] xs = { 0, 1, 1, 0 };
    float[] ys = { 0, 0, 1, 1 };
    float[] zs = { 0, 0, 0, 0 };
    int n = xs.length;

    ArrayList<Integer> insertedCounts = new ArrayList<Integer>();
    ArrayList<Integer> totalCounts = new ArrayList<Integer>();

    app.meshPointCloud_boxGridXY(xs, ys, zs, (inserted, total) -> {
      insertedCounts.add(inserted);
      totalCounts.add(total);
    });

    assertEquals(n, insertedCounts.size());
    for (int i = 0; i < n; i++) {
      assertEquals(i + 1, insertedCounts.get(i));
      assertEquals(n, totalCounts.get(i));
    }
  }

  @Test
  void meshPointCloudBoxGrid_nullProgressListener_doesNotThrow () {
    assertDoesNotThrow(() -> {
      app.meshPointCloud_boxGridXY(new float[]{ 0, 1 }, new float[]{ 0, 1 }, new float[]{ 0, 1 }, null);
    });
  }
}
