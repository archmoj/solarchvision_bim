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
// triangulation is re-tested against every new point, so this degrades
// well before a true large-scale point cloud's own size. MESH_POINT_
// CLOUD_MAX_POINTS (below) is a deliberate, honest cap on top of that -
// see its own comment for why, and for what a caller sees once it's hit.

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
ArrayList<int[]> meshPointCloud_delaunayXY (float[] xs, float[] ys) {

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

  for (int p = 0; p < n; p++) {
    meshInsertPoint(triangles, px, py, p);
  }

  for (MeshTriangle t : triangles) {
    if ((t.a < n) && (t.b < n) && (t.c < n)) { // scaffolding (touches a super-triangle point) - see this function's own comment above for why
      result.add(new int[]{ t.a, t.b, t.c });
    }
  }

  return result;
}

// One point's own insertion into the triangulation so far - the
// Bowyer-Watson step: find every triangle whose own circumcircle
// contains (px[p], py[p]) ("bad" triangles - the Delaunay condition
// these would otherwise violate), remove them, and re-triangulate the
// resulting hole by connecting p to every one of the hole's own
// boundary edges (an edge that belonged to exactly one bad triangle,
// not two - the two bad triangles sharing an interior edge of the hole
// both get removed, so only the hole's real outer boundary survives the
// "drop any edge shared by two bad triangles" filtering below).
void meshInsertPoint (ArrayList<MeshTriangle> triangles, float[] px, float[] py, int p) {

  ArrayList<MeshTriangle> badTriangles = new ArrayList<MeshTriangle>();
  for (MeshTriangle t : triangles) {
    float ddx = px[p] - t.cx, ddy = py[p] - t.cy;
    if ((ddx * ddx + ddy * ddy) < t.cRadiusSquared) badTriangles.add(t);
  }

  // Every edge of every bad triangle, each initially assumed to be on
  // the hole's own boundary - an edge shared by two bad triangles (the
  // hole's own interior) is found and dropped (both copies) just below,
  // leaving only the hole's real boundary.
  ArrayList<int[]> edges = new ArrayList<int[]>();
  for (MeshTriangle t : badTriangles) {
    edges.add(new int[]{ t.a, t.b });
    edges.add(new int[]{ t.b, t.c });
    edges.add(new int[]{ t.c, t.a });
  }

  ArrayList<int[]> boundary = new ArrayList<int[]>();
  for (int i = 0; i < edges.size(); i++) {
    boolean shared = false;
    for (int j = 0; j < edges.size(); j++) {
      if (i == j) continue;
      if (meshSameEdge(edges.get(i), edges.get(j))) { shared = true; break; }
    }
    if (!shared) boundary.add(edges.get(i));
  }

  triangles.removeAll(badTriangles);

  for (int[] e : boundary) {
    triangles.add(meshMakeTriangle(px, py, e[0], e[1], p));
  }
}

// Same edge, in either direction - (a,b) and (b,a) are the same shared
// edge between two adjacent triangles, which always store it with
// opposite winding from each other.
boolean meshSameEdge (int[] e1, int[] e2) {
  return ((e1[0] == e2[0]) && (e1[1] == e2[1])) || ((e1[0] == e2[1]) && (e1[1] == e2[0]));
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
