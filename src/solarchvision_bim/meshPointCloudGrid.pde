// Minimal, dependency-free GRID-based 2.5D meshing of a point cloud -
// the fast, default alternative to meshPointCloud.pde's own Bowyer-
// Watson Delaunay triangulation (meshPointCloud_delaunayXY()), kept in
// its own file the same way importLas.pde/meshPointCloud.pde already
// split apart by concern. Shares meshPointCloud.pde's own
// MeshPointCloudProgressListener (defined there, used by both) and that
// file's own "2.5D" scope (its own header comment) - a heightfield, one
// z per (x, y) - rather than redefining either.
//
// Why a second algorithm at all: meshPointCloud_delaunayXY()'s own
// circumcircle scan is still O(n^2)-ish even after the fixes
// meshPointCloud.pde's own "Performance" comment documents (removing a
// bad triangle, and finding the resulting hole's own boundary, are each
// a single O(T)/O(E) pass now, and meshSpatialSortOrder() softens the
// remaining scan's real-world average case) - none of that changes the
// scan's own WORST-CASE shape, which a real spatial index (triangle
// adjacency + walking) would need to fix properly, and hasn't been
// built yet. This file sidesteps the problem entirely instead, by
// giving up something Delaunay keeps - using literally every point - in
// exchange for a real O(n) algorithm: bin the points onto a plain,
// regular XY grid (one representative point per cell, picked by
// proximity to that cell's own center) and mesh the grid itself (each
// fully-occupied 2x2 block of cells becomes a single quad face - see
// the quad-emitting loop, below, for why a single quad rather than 2
// triangles) - no circumcircle, no incremental rebuilding, a single
// pass over the points to bin them plus a single pass over the grid to
// mesh it.
//
// What this gives up, relative to Delaunay: a cell with more than one
// point only ever keeps ONE of them (the one closest to that cell's own
// center) - every other point in that cell contributes nothing to the
// resulting MESH (though the point itself is still imported into
// allPoints regardless - meshing is a separate step from importing, see
// importLas.pde's own lasMeshPointCloud(), the only caller so far). For
// a roughly-evenly-sampled aerial/terrain LiDAR cloud (this app's own
// documented common case - see meshPointCloud.pde's own "2.5D" comment)
// that loss is usually small, and the resulting grid resolution stays
// close to the cloud's own real point spacing; for a sparse or very
// unevenly-sampled cloud it can lose real detail Delaunay wouldn't have.
// A cell with NO point at all also just leaves its own 2x2
// neighborhood untriangulated (a hole), rather than Delaunay's own
// "connect whatever's nearest regardless of gaps" behavior - correct
// for genuinely missing data, but means a sparse cloud's own edges can
// come out visibly more ragged here than under Delaunay.

// Far more generous than meshPointCloud_delaunayXY()'s own MESH_POINT_
// CLOUD_MAX_POINTS (meshPointCloud.pde, 50000) specifically because this
// algorithm doesn't share that one's O(n^2)-ish blowup risk at all -
// binning the points and triangulating the grid are each a single O(n)/
// O(cells) pass, so a far larger cloud still finishes in reasonable
// time. Still a real cap, not "no limit at all": gridCols/gridRows
// (meshPointCloud_gridXY(), below) are sized from n, so a truly
// unbounded n would still mean unbounded memory for the grid's own 2D
// arrays - deliberately generous, not tuned against real timings/memory
// - lower it if a real file ever needs that, or raise it once a real
// need shows up.
final int MESH_POINT_CLOUD_GRID_MAX_POINTS = 2000000;

// Builds a grid-based 2.5D mesh of the points (xs[i], ys[i]) for i in
// 0..xs.length-1 - see this file's own header comment for exactly what
// that means and gives up relative to meshPointCloud_delaunayXY()
// (meshPointCloud.pde). Same PARAMETER shape as that function (progress
// nullable, same xs/ys), and the same "an ArrayList of int[] index
// arrays into the SAME xs/ys arrays" RETURN shape - but, unlike that
// function's own always-3-long triangles, each of THESE is always a
// 4-long quad (see the quad-emitting loop, below) - a caller mapping
// over the result (e.g. importLas.pde's own lasMeshPointCloud()) just
// needs to handle a face of whatever length it actually gets, not
// assume 3, to stay interchangeable with either algorithm.
//
// Returns an empty list (never null) for fewer than 4 points (even a
// single fully-occupied 2x2 block of grid cells - the smallest possible
// non-empty result - needs at least 4 distinct points to exist at all),
// a length mismatch between xs/ys, or a point count over MESH_POINT_
// CLOUD_GRID_MAX_POINTS (see that constant's own comment for why it's
// so much higher than meshPointCloud_delaunayXY()'s own cap) - every one
// of those is "nothing to triangulate" rather than an error, the same
// reasoning meshPointCloud_delaunayXY()'s own identical cases give.
ArrayList<int[]> meshPointCloud_gridXY (float[] xs, float[] ys, MeshPointCloudProgressListener progress) {

  ArrayList<int[]> result = new ArrayList<int[]>();

  int n = xs.length;
  if (n > MESH_POINT_CLOUD_GRID_MAX_POINTS) {
    println("\nPoint cloud meshing: " + n + " points is over this version's own " + MESH_POINT_CLOUD_GRID_MAX_POINTS + "-point cap - skipped (the points themselves were still imported, just not meshed into a surface)");
    return result;
  }
  if ((n < 4) || (ys.length != n)) return result;

  float minX = xs[0], maxX = xs[0], minY = ys[0], maxY = ys[0];
  for (int i = 1; i < n; i++) {
    if (xs[i] < minX) minX = xs[i];
    if (xs[i] > maxX) maxX = xs[i];
    if (ys[i] < minY) minY = ys[i];
    if (ys[i] > maxY) maxY = ys[i];
  }

  float spanX = maxX - minX, spanY = maxY - minY;
  if (spanX <= 0) spanX = 1; // every point sharing the same x (or y) - degenerate, but still shouldn't divide by 0 below
  if (spanY <= 0) spanY = 1;

  // A grid sized so its own cells are roughly square (matching the
  // point cloud's own real aspect ratio, not stretched to fit a naive
  // N x N grid onto a non-square bounding box) and its own total cell
  // count is roughly n - about 1 point per cell on average, the same
  // target meshSpatialSortOrder() (meshPointCloud.pde) already uses for
  // its own, unrelated reason. Solving cellWidth == cellHeight (spanX /
  // gridCols == spanY / gridRows) together with gridCols * gridRows == n
  // gives exactly this pair.
  float aspect = spanX / spanY;
  int gridCols = max(1, round(sqrt(n * aspect)));
  int gridRows = max(1, round(sqrt(n / aspect)));

  float cellWidth = spanX / gridCols;
  float cellHeight = spanY / gridRows;

  // Each cell's own single representative point - -1 where a cell has
  // no point in it at all. cellBestDistSq alongside it tracks how close
  // (squared distance) that cell's own CURRENT representative is to the
  // cell's own center, so a later point landing in the same cell can
  // correctly compare against it (see this file's own header comment
  // for why "the point closest to the cell's own center" is this
  // function's own choice of representative).
  int[][] cellPointIndex = new int[gridCols][gridRows];
  float[][] cellBestDistSq = new float[gridCols][gridRows];
  for (int cx = 0; cx < gridCols; cx++) {
    for (int cy = 0; cy < gridRows; cy++) {
      cellPointIndex[cx][cy] = -1;
      cellBestDistSq[cx][cy] = Float.MAX_VALUE;
    }
  }

  for (int i = 0; i < n; i++) {
    int cellX = (int) ((xs[i] - minX) / cellWidth);
    int cellY = (int) ((ys[i] - minY) / cellHeight);
    // The point(s) exactly at maxX/maxY (and any float rounding right
    // at an earlier cell boundary) would otherwise compute a cell index
    // 1 past this grid's own last row/column - clamped into range
    // rather than ever indexing the grid out of bounds, the same
    // reasoning meshSpatialSortOrder()'s own identical clamp
    // (meshPointCloud.pde) already documents.
    if (cellX >= gridCols) cellX = gridCols - 1;
    if (cellY >= gridRows) cellY = gridRows - 1;
    if (cellX < 0) cellX = 0;
    if (cellY < 0) cellY = 0;

    float cellCenterX = minX + (cellX + 0.5f) * cellWidth;
    float cellCenterY = minY + (cellY + 0.5f) * cellHeight;
    float ddx = xs[i] - cellCenterX, ddy = ys[i] - cellCenterY;
    float distSq = ddx * ddx + ddy * ddy;

    if (distSq < cellBestDistSq[cellX][cellY]) {
      cellBestDistSq[cellX][cellY] = distSq;
      cellPointIndex[cellX][cellY] = i;
    }

    // One call per point BINNED, not per point actually kept as a
    // cell's own representative - the single O(n) pass this whole
    // function spends most of its own time in, so (unlike meshPoint
    // Cloud_delaunayXY()'s own "once per point actually inserted," a
    // genuinely different operation) this is the closest real
    // equivalent for showing progress through THIS algorithm - see
    // MeshPointCloudProgressListener's own comment (meshPointCloud.pde)
    // for why its own doc is written broadly enough to cover both.
    if (progress != null) progress.onPointInserted(i + 1, n);
  }

  // ONE quad face (4 indices, not 2 triangles) per 2x2 block of cells
  // that are ALL 4 occupied - allFaces.create() (faces.pde) already
  // accepts a face of any vertex count (the same way Create3D's own
  // add_Mesh4() already hands it exactly 4 indices for a single quad
  // face, rather than splitting into 2 triangles itself - see that
  // function, create3D.pde), so there's no need for this algorithm to
  // pick a diagonal and split at all: a flat quad has no diagonal-choice
  // ambiguity (unlike a near-circular Delaunay tie) to begin with, and
  // 1 face instead of 2 is simply less data for the exact same shape.
  // p00, p10, p11, p01 - in that order - walk the quad's own boundary
  // once around (right along the bottom edge, up the right edge, left
  // along the top edge, closing back down the left edge), the winding
  // order a face's own vertex list needs to be in. A block with any
  // empty corner is simply skipped (a hole left in the mesh, see this
  // file's own header comment on why), not filled in some other way.
  for (int col = 0; col < gridCols - 1; col++) {
    for (int row = 0; row < gridRows - 1; row++) {
      int p00 = cellPointIndex[col][row];
      int p10 = cellPointIndex[col + 1][row];
      int p01 = cellPointIndex[col][row + 1];
      int p11 = cellPointIndex[col + 1][row + 1];

      if ((p00 < 0) || (p10 < 0) || (p01 < 0) || (p11 < 0)) continue; // a hole - see this function's own comment above

      result.add(new int[]{ p00, p10, p11, p01 });
    }
  }

  return result;
}
