// Minimal, dependency-free 2.5D Delaunay triangulation of a point
// cloud - the default "mesh the points into a surface" step every
// point-cloud importer this app has (currently just importLas.pde) uses.
// Kept in its own file, and deliberately ignorant of allPoints/allFaces/
// current_Material/... (everything app-specific) so any future point-
// cloud format (E57, XYZ/PTS, PCD, ...) can reuse this exact algorithm
// unchanged - the same way importGlb.pde's own binReadU32LE()/
// binReadFloatLE()/binReadDoubleLE() already get reused by importStl.
// pde/importLas.pde for plain byte-reading rather than each format
// duplicating its own copy.
//
// "2.5D" - this triangulates the point cloud's own (x, y) positions only
// (a classic 2D Delaunay triangulation, via the standard Bowyer-Watson
// incremental algorithm), then lets each resulting triangle simply keep
// whichever z each of its own 3 corners already had. Correct, and the
// standard approach, for a heightfield-like cloud - one z per (x, y),
// the overwhelmingly common shape for aerial/terrain LiDAR (which is
// exactly the kind of point cloud a LAS file - this app's only point-
// cloud import format so far - typically holds) - but NOT a general
// arbitrary-surface reconstruction: a cloud with any overhang (two
// different z values genuinely at the same (x, y), e.g. a scan of a
// building facade or the underside of a bridge) will still triangulate
// without error, but the result won't be a meaningful surface at the
// overhanging part. A true arbitrary-surface technique (e.g. Poisson
// surface reconstruction, or ball-pivoting) would need per-point normals
// this version never computes, and is real extra work on top of this -
// left for a future version if a non-heightfield use case actually
// comes up.
//
// Performance: this is the textbook incremental Bowyer-Watson algorithm
// with NO spatial index (a k-d tree/grid) behind the "which triangles
// does this new point's circumcircle contain" search in
// meshInsertPoint() below - every triangle currently in the
// triangulation is re-tested against every new point, so this still
// degrades well before a true large-scale point cloud's own size (this
// is the real, remaining O(n^2)-ish cost - fixing it means adding real
// triangle adjacency and walking from a recently-touched triangle
// instead of scanning all of them, a bigger change left for later).
// What meshInsertPoint() does once it HAS found those bad triangles is
// no longer part of that cost, though: both removing them from
// triangles and finding the resulting hole's own boundary edges are
// now each a single O(T)/O(E) pass (a HashMap keyed by each edge's own
// canonical (min, max) vertex-index pair for the boundary search, and
// an Iterator.remove() single pass for the removal) - earlier versions
// of this file did both in ways that, while never changing the actual
// RESULT, cost meaningfully more than they needed to on top of the
// O(n^2) scan above (ArrayList.removeAll() checking every remaining
// triangle's own membership in the just-found bad list, and an edge-by-
// edge O(E^2) pairwise comparison for the boundary search).
// meshSpatialSortOrder() (below) softens that remaining O(n^2)-ish cost
// a bit further, without actually fixing its own shape: it chooses a
// spatially-coherent order to insert the n real points in (instead of
// just the caller's own array order), which - for real-world point
// clouds, rarely already spatially coherent on their own - meaningfully
// cuts how many triangles that circumcircle scan ends up touching per
// point, on average, even though it doesn't change what the scan itself
// costs per triangle it does touch. See that function's own comment for
// why insertion order matters at all, given the final triangulation
// RESULT never depends on it.
//
// MESH_POINT_CLOUD_MAX_POINTS (below) is a deliberate, honest cap on
// top of all of this - see its own comment for why, and for what a
// caller sees once it's hit. meshPointCloud_delaunayXY()'s own optional
// MeshPointCloudProgressListener parameter (also below) exists
// specifically so a caller's UI can show real progress through however
// long this actually takes, rather than looking indistinguishable from
// a genuine hang for that whole stretch.

// A cloud larger than this is skipped entirely (not triangulated at
// all - a caller falls back to importing loose points only, see e.g.
// import_objects_LAS()'s own use of this file) rather than left to run
// for minutes-to-hours: a single LAS tile can easily hold several
// million points, far past where this file's own un-accelerated Bowyer-
// Watson stays practical. Deliberately generous for a hand-rolled, no-
// external-library triangulator (not tuned against real timings) -
// lower it if it's still too slow on real files, or raise it once a
// real need shows up.
final int MESH_POINT_CLOUD_MAX_POINTS = 50000;

// Lets a caller of meshPointCloud_delaunayXY() (below) show real
// progress through a triangulation that - see this file's own header
// comment on performance - can take a genuinely long time, rather than
// the caller's own UI looking stuck for that whole stretch with nothing
// to tell a person watching it apart from an actual hang. Deliberately
// just this one callback, with no reference to console printing,
// ProgressWindow, or anything else app-specific - same "ignorant of
// everything app-specific" reasoning as this file's own header comment
// gives for not touching allPoints/allFaces/current_Material/... -  a
// caller (e.g. importLas.pde's own LasMeshProgressReporter) decides
// entirely for itself how (or whether) to actually show this.
interface MeshPointCloudProgressListener {
  // Called once per real point actually inserted into the triangulation
  // (see meshPointCloud_delaunayXY()'s own main loop) - never for the 3
  // super-triangle points, and never at all for a call that returns
  // before starting (too few points, or over MESH_POINT_CLOUD_MAX_POINTS -
  // both already have their own, separate "nothing to report progress
  // on" meaning, so a caller never sees e.g. onPointInserted(0, 0)).
  // pointsInserted counts up from 1 to totalPoints (== xs.length/
  // ys.length, the same n meshPointCloud_delaunayXY() was called with).
  void onPointInserted (int pointsInserted, int totalPoints);
}

// One triangle, mid-construction, as 3 indices into whatever point
// array meshPointCloud_delaunayXY() was called with - the super-
// triangle's own 3 extra points (appended after the caller's own n real
// points, at indices n/n+1/n+2 - see meshPointCloud_delaunayXY()'s own
// px/py) are included like any other index while triangulating, and
// only filtered back out right before that function returns.
class MeshTriangle {
  int a, b, c;
  // Circumcircle of (a, b, c), cached once at construction time
  // (meshMakeTriangle(), below) - meshInsertPoint() re-tests EVERY
  // triangle currently in the triangulation against each new point, so
  // computing each one's own circumcircle only once (not once per point
  // later tested against it) matters.
  float cx, cy, cRadiusSquared;
}

// Builds a 2D Delaunay triangulation of the points (xs[i], ys[i]) for
// i in 0..xs.length-1 (xs/ys must be the same length), by the standard
// Bowyer-Watson incremental algorithm - see this file's own header
// comment for what "2.5D" means for a caller using the result as a
// surface, and for MESH_POINT_CLOUD_MAX_POINTS's own cap.
//
// Returns each triangle as one int[3] of indices into the SAME xs/ys
// arrays passed in (0-based, in the caller's own order) - never indices
// into allPoints or anything else app-specific, so a caller (e.g.
// lasMeshPointCloud(), importLas.pde) maps each one through its own
// point-index table itself. Returns an empty list (never null) for
// fewer than 3 points, a length mismatch between xs/ys, or a point
// count over MESH_POINT_CLOUD_MAX_POINTS (see that constant's own
// comment) - every one of those is "nothing to triangulate" rather than
// an error, since a caller treating "no triangles" as "fall back to
// loose points" is exactly the sensible, non-fatal response to all of
// them alike.
//
// progress (nullable - pass null for no progress reporting at all) gets
// one onPointInserted() call per real point inserted - see MeshPoint
// CloudProgressListener's own comment above for exactly when/how often.
ArrayList<int[]> meshPointCloud_delaunayXY (float[] xs, float[] ys, MeshPointCloudProgressListener progress) {

  ArrayList<int[]> result = new ArrayList<int[]>();

  int n = xs.length;
  if (n > MESH_POINT_CLOUD_MAX_POINTS) {
    println("\nPoint cloud meshing: " + n + " points is over this version's own " + MESH_POINT_CLOUD_MAX_POINTS + "-point cap - skipped (the points themselves were still imported, just not meshed into a surface)");
    return result;
  }
  if ((n < 3) || (ys.length != n)) return result; // too few points (or a caller bug pairing mismatched arrays) - nothing a triangle could ever be built from

  // Working copy of every point this triangulation touches - the
  // caller's own n real points (indices 0..n-1, values unchanged) plus
  // 3 extra "super-triangle" points (indices n, n+1, n+2) large enough
  // to contain every real point, so the very first real point can
  // always be inserted into a triangulation that already has at least
  // one triangle to start from. Any triangle still touching one of
  // these 3 extra points is scaffolding, not part of the real points'
  // own triangulation - filtered back out in this function's own tail,
  // below.
  float minX = xs[0], maxX = xs[0], minY = ys[0], maxY = ys[0];
  for (int i = 1; i < n; i++) {
    if (xs[i] < minX) minX = xs[i];
    if (xs[i] > maxX) maxX = xs[i];
    if (ys[i] < minY) minY = ys[i];
    if (ys[i] > maxY) maxY = ys[i];
  }

  float spanMax = max(maxX - minX, maxY - minY);
  if (spanMax <= 0) spanMax = 1; // every point coincident - degenerate, but still shouldn't scale a super-triangle by 0 below
  float midX = (minX + maxX) / 2, midY = (minY + maxY) / 2;

  // A triangle this large (20x the point cloud's own span, in every
  // direction) safely contains every real point with room to spare -
  // only its own existence (not its exact size) matters, since it's
  // fully removed again before this function returns.
  float[] superX = { midX - 20 * spanMax, midX,                midX + 20 * spanMax };
  float[] superY = { midY -      spanMax, midY + 20 * spanMax, midY -      spanMax };

  float[] px = new float[n + 3];
  float[] py = new float[n + 3];
  arrayCopy(xs, px, n);
  arrayCopy(ys, py, n);
  for (int s = 0; s < 3; s++) { px[n + s] = superX[s]; py[n + s] = superY[s]; }

  ArrayList<MeshTriangle> triangles = new ArrayList<MeshTriangle>();
  triangles.add(meshMakeTriangle(px, py, n, n + 1, n + 2));

  // See meshSpatialSortOrder()'s own comment for why insertion order -
  // despite never changing the final RESULT - is still worth choosing
  // deliberately rather than just going 0, 1, 2, ... n-1 (a LAS file's
  // own scan-line order, for the one caller this currently has).
  int[] insertOrder = meshSpatialSortOrder(xs, ys, n, minX, maxX, minY, maxY);

  for (int oi = 0; oi < n; oi++) {
    meshInsertPoint(triangles, px, py, insertOrder[oi]);
    if (progress != null) progress.onPointInserted(oi + 1, n);
  }

  for (MeshTriangle t : triangles) {
    if ((t.a < n) && (t.b < n) && (t.c < n)) { // scaffolding (touches a super-triangle point) - see this function's own comment above for why
      result.add(new int[]{ t.a, t.b, t.c });
    }
  }

  return result;
}

// Computes a spatially-coherent visiting order for inserting the n real
// points (xs[0..n-1], ys[0..n-1]) into the Bowyer-Watson triangulation
// above, instead of just 0, 1, 2, ... n-1 (a LAS file's own scan-line
// order, for the one caller this currently has) - Delaunay
// triangulation's own RESULT doesn't depend on insertion order at all
// (the same final set of triangles comes out regardless, barring tie-
// breaking on genuinely degenerate input), but how much work meshInsert
// Point()'s own un-accelerated circumcircle scan has to do along the
// way does: that scan still tests every triangle CURRENTLY in the
// triangulation (see this file's own header comment, "Performance," for
// why), and consecutive insertions build up more triangles near each
// other - and so touch fewer of them per new point, on average - when
// consecutive POINTS are near each other in space, rather than
// scattered across the whole cloud the way file order usually is. This
// doesn't fix that scan's own O(n^2)-ish shape (a real spatial index,
// not just a better insertion order, would be needed for that - see
// this file's own header comment again), but meaningfully cuts how much
// of it actually gets paid for real-world point clouds, which (unlike a
// LAS file's own scan order) are rarely already spatially coherent.
//
// A plain grid, visited in "boustrophedon" (row by row, alternating
// left-to-right/right-to-left each row, the way an ox plows a field)
// order: simple to get right, and good enough for this - a true space-
// filling curve (e.g. Hilbert) packs slightly better at the row-to-row
// seam, but isn't worth the real extra complexity (bit-interleaving a
// 2D index) for what would still only be a constant-factor improvement
// on top of this.
int[] meshSpatialSortOrder (float[] xs, float[] ys, int n, float minX, float maxX, float minY, float maxY) {

  // Roughly 1 point per cell on average - a coarser grid (fewer, bigger
  // cells) packs more points into each cell (whose own internal order
  // stays arbitrary, so less benefit from sorting at all); a finer one
  // has more empty/near-empty cells to walk past for no benefit either
  // way. Neither extreme breaks correctness - only how much this
  // actually helps.
  int gridSize = max(1, (int) Math.ceil(Math.sqrt((double) n)));

  float spanX = maxX - minX, spanY = maxY - minY;
  float cellWidth  = (spanX > 0) ? (spanX / gridSize) : 1; // every point sharing the same X (or Y) - cellWidth/Height would otherwise be 0, and dividing by it below undefined
  float cellHeight = (spanY > 0) ? (spanY / gridSize) : 1;

  ArrayList<ArrayList<Integer>> cells = new ArrayList<ArrayList<Integer>>(gridSize * gridSize);
  for (int c = 0; c < gridSize * gridSize; c++) cells.add(new ArrayList<Integer>());

  for (int i = 0; i < n; i++) {
    int cellX = (int) ((xs[i] - minX) / cellWidth);
    int cellY = (int) ((ys[i] - minY) / cellHeight);
    // The point(s) exactly at maxX/maxY (and, in principle, any float
    // rounding at an earlier cell boundary) would otherwise compute a
    // cell index 1 past this grid's own last row/column - clamped into
    // range rather than ever indexing cells out of bounds.
    if (cellX >= gridSize) cellX = gridSize - 1;
    if (cellY >= gridSize) cellY = gridSize - 1;
    if (cellX < 0) cellX = 0;
    if (cellY < 0) cellY = 0;

    cells.get(cellY * gridSize + cellX).add(i);
  }

  int[] order = new int[n];
  int oi = 0;
  for (int row = 0; row < gridSize; row++) {
    boolean leftToRight = (row % 2) == 0; // the "boustrophedon" turn - see this function's own header comment
    for (int col = 0; col < gridSize; col++) {
      int cellX = leftToRight ? col : (gridSize - 1 - col);
      for (int pointIndex : cells.get(row * gridSize + cellX)) {
        order[oi] = pointIndex;
        oi += 1;
      }
    }
  }

  return order;
}

// One point's own insertion into the triangulation so far - the
// Bowyer-Watson step: find every triangle whose own circumcircle
// contains (px[p], py[p]) ("bad" triangles - the Delaunay condition
// these would otherwise violate), remove them, and re-triangulate the
// resulting hole by connecting p to every one of the hole's own
// boundary edges (an edge that belonged to exactly one bad triangle,
// not two - the two bad triangles sharing an interior edge of the hole
// both get removed, so only the hole's real outer boundary survives the
// "toggle" step meshToggleEdge() does, below).
//
// The circumcircle scan just below (which triangle in triangles is
// "bad") is still the one real O(n^2)-ish cost here - see this file's
// own header comment ("Performance") for why, and for what fixing that
// would actually take. Everything AFTER that - removing the bad
// triangles via Iterator.remove() and finding the hole's own boundary
// via meshToggleEdge() - is a single O(T)/O(E) pass each, regardless
// of how that scan was done.
void meshInsertPoint (ArrayList<MeshTriangle> triangles, float[] px, float[] py, int p) {

  // Finds AND removes every bad triangle in the same single pass, via
  // the list's own Iterator.remove() - never ArrayList.removeAll(),
  // whose own "is this element in the list I was given" check costs a
  // full scan of ITS OWN argument per element of triangles, turning one
  // O(T) removal into an O(T x badTriangles.size()) one for no reason
  // the result needs (see this file's own header comment).
  ArrayList<MeshTriangle> badTriangles = new ArrayList<MeshTriangle>();
  java.util.Iterator<MeshTriangle> it = triangles.iterator();
  while (it.hasNext()) {
    MeshTriangle t = it.next();
    float ddx = px[p] - t.cx, ddy = py[p] - t.cy;
    if ((ddx * ddx + ddy * ddy) < t.cRadiusSquared) {
      badTriangles.add(t);
      it.remove();
    }
  }

  // The hole's own boundary - every edge of every bad triangle, kept in
  // one HashMap<Long, int[]> keyed by meshEdgeKey() (below)'s own
  // direction-agnostic (min vertex, max vertex) encoding of that edge,
  // via meshToggleEdge(): a boundary edge (belonging to exactly one bad
  // triangle) is inserted once and stays; an interior edge (shared by
  // two adjacent bad triangles, each walking it in the opposite
  // direction from the other) gets inserted once then immediately
  // removed again by its own second, opposite-winding occurrence -
  // O(1) (amortized) per edge, O(E) total, rather than every edge
  // compared pairwise against every other edge.
  HashMap<Long, int[]> boundaryEdges = new HashMap<Long, int[]>();
  for (MeshTriangle t : badTriangles) {
    meshToggleEdge(boundaryEdges, t.a, t.b);
    meshToggleEdge(boundaryEdges, t.b, t.c);
    meshToggleEdge(boundaryEdges, t.c, t.a);
  }

  for (int[] e : boundaryEdges.values()) {
    triangles.add(meshMakeTriangle(px, py, e[0], e[1], p));
  }
}

// One direction-agnostic edge key, packing its own 2 (always
// non-negative, well under 32 bits even at this file's own
// MESH_POINT_CLOUD_MAX_POINTS cap) vertex indices into a single long -
// (a, b) and (b, a) are the same shared edge between two adjacent
// triangles, which always store it with opposite winding from each
// other, so this always orders them (min index first) before packing,
// specifically so both directions hash identically.
long meshEdgeKey (int a, int b) {
  int lo = min(a, b), hi = max(a, b);
  return (((long) lo) << 32) | (hi & 0xFFFFFFFFL);
}

// Inserts edge (a, b) into boundaryEdges the first time its own key is
// seen, and removes it again the second time (see meshInsertPoint()'s
// own comment for why that's exactly the "boundary edges only" result
// this needs) - preserves (a, b)'s own original winding direction (not
// the (lo, hi) order meshEdgeKey() hashes by) in the stored int[], since
// meshMakeTriangle() (called on this map's own final values) needs a
// real, consistently-wound edge to build a correctly-oriented new
// triangle from, and a boundary edge is only ever inserted the once, so
// whichever of the (at most 2) bad triangles that edge belonged to
// recorded it first is already the only direction that ever mattered.
void meshToggleEdge (HashMap<Long, int[]> boundaryEdges, int a, int b) {
  long key = meshEdgeKey(a, b);
  if (boundaryEdges.containsKey(key)) boundaryEdges.remove(key);
  else boundaryEdges.put(key, new int[]{ a, b });
}

// Builds one MeshTriangle from 3 point indices, computing and caching
// its own circumcircle right away (see MeshTriangle's own comment for
// why) via the standard closed-form circumcenter formula from each
// point's own (x, y).
MeshTriangle meshMakeTriangle (float[] px, float[] py, int a, int b, int c) {
  MeshTriangle t = new MeshTriangle();
  t.a = a; t.b = b; t.c = c;

  float ax = px[a], ay = py[a];
  float bx = px[b], by = py[b];
  float cx = px[c], cy = py[c];

  float d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by));
  if (abs(d) < 0.000001) {
    // 3 (near-)collinear points - no real circumcircle exists. Falls
    // back to their own centroid with an effectively-infinite radius,
    // so this degenerate triangle still gets tested (and very likely
    // replaced) like any other rather than this function itself
    // throwing - genuinely collinear input points are rare but real
    // (e.g. a LAS file with many exactly-duplicated (x, y) values, one
    // per return off the same laser pulse).
    t.cx = (ax + bx + cx) / 3;
    t.cy = (ay + by + cy) / 3;
    t.cRadiusSquared = Float.MAX_VALUE;
    return t;
  }

  float a2 = ax * ax + ay * ay;
  float b2 = bx * bx + by * by;
  float c2 = cx * cx + cy * cy;

  t.cx = (a2 * (by - cy) + b2 * (cy - ay) + c2 * (ay - by)) / d;
  t.cy = (a2 * (cx - bx) + b2 * (ax - cx) + c2 * (bx - ax)) / d;

  float rdx = ax - t.cx, rdy = ay - t.cy;
  t.cRadiusSquared = rdx * rdx + rdy * rdy;

  return t;
}
