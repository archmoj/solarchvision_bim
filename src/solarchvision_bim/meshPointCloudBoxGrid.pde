// Minimal, dependency-free BOX-GRID 2.5D meshing of a point cloud - a
// third meshing option, alongside meshPointCloud_delaunayXY() (mesh
// Point Cloud.pde) and meshPointCloud_gridXY() (meshPointCloudGrid.pde).
// Reuses that second file's own grid-sizing/binning/fill-pass reasoning
// AND its own tuning constants (MESH_POINT_CLOUD_GRID_MAX_POINTS/
// TARGET_POINTS_PER_CELL/FILL_RADIUS) directly - see that file's own
// header comment for the full reasoning behind each - but produces a
// fundamentally different RESULT: instead of one quad per 2x2 block of
// cells, connecting each cell's own actual (independently-varying-Z,
// generally non-rectangular) points the way meshPointCloud_gridXY()
// does, this gives EVERY occupied (or filled) cell its own flat-topped,
// perfectly axis-aligned BOX - a horizontal rectangle at that cell's own
// representative Z, snapped to the CELL's own boundary (never the real
// point's own scattered X/Y position), with 4 vertical walls down to a
// shared base level - a stepped, bar-chart-like "grid of boxes" look,
// closer to a voxel/extruded-grid terrain rendering than a smooth,
// sloped surface.
//
// "Mesh2" is this app's own name (Create3D's own add_Mesh2(), create3D.
// pde) for a face built from just 2 diagonal corners, with the other 2
// corners computed to keep the whole thing a perfect axis-aligned
// rectangle (one of X/Y/Z held constant across all 4 corners) - exactly
// what each of a box's own 5 faces (1 flat top, 4 vertical sides) are,
// and why this algorithm needs SEVERAL of those per cell (lasCreateBox
// GridFaces(), importLas.pde) rather than the single, generally non-
// rectangular Mesh4-style quad meshPointCloud_gridXY() builds instead.
//
// Deliberately does NOT reuse meshPointCloud_gridXY()'s own binning/
// fill code directly (even though the logic below is close to
// identical) - the 2 functions build genuinely different final
// structures (this one also needs to carry a Z per cell, that one never
// does) from the exact same binning step, and threading that one
// difference through a shared helper would need either an awkward
// multi-value return or an out-parameter array just to hand a 2D int
// grid back to 2 different callers - a little duplicated binning code
// between 2 algorithms that are never both run on the same import stays
// simpler to read on its own than that plumbing would be.
//
// Unlike meshPointCloud_delaunayXY()'s/meshPointCloud_gridXY()'s own
// int[]-index-based ArrayLists, this returns one BoxGridCell (below) per
// occupied cell - a plain geometry description (that cell's own XY
// rectangle, its own top Z), not an index into any existing point at
// all, since a box's own corners are SYNTHESIZED grid-aligned
// coordinates that generally don't match any real scattered input point
// exactly (only that cell's own representative Z survives into the
// result). Turning that into real allPoints/allFaces entries is left to
// the caller (importLas.pde's own lasCreateBoxGridFaces()) - the same
// "stay ignorant of allPoints/allFaces/current_Material/..." reasoning
// meshPointCloud.pde's own header comment already gives for the other 2
// algorithms.

// One occupied (or filled) cell's own box geometry: a flat, axis-
// aligned rectangle from (minX, minY) to (maxX, maxY) in the XY plane,
// at height topZ - lasCreateBoxGridFaces() (importLas.pde) is what
// actually turns this into a real box (that flat top plus 4 vertical
// walls).
class BoxGridCell {
  float minX, maxX, minY, maxY, topZ;
}

// Builds a box-grid 2.5D mesh description of the points (xs[i], ys[i],
// zs[i]) for i in 0..xs.length-1 - see this file's own header comment
// for exactly what that means. Reuses meshPointCloudGrid.pde's own
// MESH_POINT_CLOUD_GRID_MAX_POINTS/TARGET_POINTS_PER_CELL/FILL_RADIUS
// constants directly (see each one's own comment there) - this
// algorithm's own binning is the same shape as meshPointCloud_gridXY()'s
// own, just carrying a Z through instead of the real points' own X/Y.
//
// Returns an empty list (never null) for an empty or mismatched input,
// or a point count over MESH_POINT_CLOUD_GRID_MAX_POINTS (same meaning
// as meshPointCloud_gridXY()'s own identical case) - "nothing to mesh"
// rather than an error either way.
ArrayList<BoxGridCell> meshPointCloud_boxGridXY (float[] xs, float[] ys, float[] zs, MeshPointCloudProgressListener progress) {

  ArrayList<BoxGridCell> result = new ArrayList<BoxGridCell>();

  int n = xs.length;
  if (n > MESH_POINT_CLOUD_GRID_MAX_POINTS) {
    println("\nPoint cloud meshing: " + n + " points is over this version's own " + MESH_POINT_CLOUD_GRID_MAX_POINTS + "-point cap - skipped (the points themselves were still imported, just not meshed into a surface)");
    return result;
  }
  if ((n < 1) || (ys.length != n) || (zs.length != n)) return result;

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

  // Same grid-sizing math as meshPointCloud_gridXY() (meshPointCloud
  // Grid.pde), using that file's own MESH_POINT_CLOUD_GRID_TARGET_
  // POINTS_PER_CELL and the same floor-at-2 reasoning - see each one's
  // own comment there.
  float aspect = spanX / spanY;
  float targetCellCount = n / MESH_POINT_CLOUD_GRID_TARGET_POINTS_PER_CELL;
  int gridCols = max(2, round(sqrt(targetCellCount * aspect)));
  int gridRows = max(2, round(sqrt(targetCellCount / aspect)));

  float cellWidth = spanX / gridCols;
  float cellHeight = spanY / gridRows;

  // Each cell's own single representative point - -1 where a cell has
  // no point in it at all - same binning as meshPointCloud_gridXY()'s
  // own identical step (see that function's own comment).
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

    if (progress != null) progress.onPointInserted(i + 1, n);
  }

  // Same nearest-neighbor fill pass as meshPointCloud_gridXY() - see
  // that function's own comment for the full reasoning (decided purely
  // from the ORIGINAL grid, no cascading, bounded to MESH_POINT_CLOUD_
  // GRID_FILL_RADIUS cells, a cell with nothing even within that radius
  // stays genuinely empty).
  int[][] filledFrom = new int[gridCols][gridRows];
  for (int cx = 0; cx < gridCols; cx++) {
    for (int cy = 0; cy < gridRows; cy++) {
      filledFrom[cx][cy] = -1;
    }
  }

  for (int cx = 0; cx < gridCols; cx++) {
    for (int cy = 0; cy < gridRows; cy++) {
      if (cellPointIndex[cx][cy] >= 0) continue;

      float cellCenterX = minX + (cx + 0.5f) * cellWidth;
      float cellCenterY = minY + (cy + 0.5f) * cellHeight;

      int bestPoint = -1;
      float bestDistSq = Float.MAX_VALUE;

      for (int radius = 1; (radius <= MESH_POINT_CLOUD_GRID_FILL_RADIUS) && (bestPoint < 0); radius++) {
        for (int dx = -radius; dx <= radius; dx++) {
          for (int dy = -radius; dy <= radius; dy++) {
            if (max(abs(dx), abs(dy)) != radius) continue;

            int nx = cx + dx, ny = cy + dy;
            if ((nx < 0) || (nx >= gridCols) || (ny < 0) || (ny >= gridRows)) continue;

            int candidate = cellPointIndex[nx][ny];
            if (candidate < 0) continue;

            float ddx = xs[candidate] - cellCenterX, ddy = ys[candidate] - cellCenterY;
            float distSq = ddx * ddx + ddy * ddy;
            if (distSq < bestDistSq) {
              bestDistSq = distSq;
              bestPoint = candidate;
            }
          }
        }
      }

      filledFrom[cx][cy] = bestPoint;
    }
  }

  for (int cx = 0; cx < gridCols; cx++) {
    for (int cy = 0; cy < gridRows; cy++) {
      if (filledFrom[cx][cy] >= 0) cellPointIndex[cx][cy] = filledFrom[cx][cy];
    }
  }

  // One box per cell that ended up with a representative point (direct
  // or borrowed) - unlike meshPointCloud_gridXY()'s own quad, which
  // needs all 4 corners of a 2x2 BLOCK, each box here only needs its
  // OWN single cell, so (beyond the fill pass above) there's no further
  // "needs its neighbors too" requirement left to cause extra holes.
  for (int cx = 0; cx < gridCols; cx++) {
    for (int cy = 0; cy < gridRows; cy++) {
      int rep = cellPointIndex[cx][cy];
      if (rep < 0) continue; // genuinely empty even after the fill pass - a real gap, left as one, same reasoning meshPointCloud_gridXY() already documents

      BoxGridCell cell = new BoxGridCell();
      cell.minX = minX + cx * cellWidth;
      cell.maxX = minX + (cx + 1) * cellWidth;
      cell.minY = minY + cy * cellHeight;
      cell.maxY = minY + (cy + 1) * cellHeight;
      cell.topZ = zs[rep];
      result.add(cell);
    }
  }

  return result;
}
