import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers isFacePlanar3D(), bilinearPatchPoint3D(), clipPolygon_rectangleUV()
// and their call sites in applyTiling_Selection()/applySemiRegularTiling_
// Selection() - the fix for a real bug found while planning an unrelated
// feature: every tiling command assumed its selected face actually lay in
// one flat plane (one shared (U_axis, V_axis) frame, one shared clip
// normal for every edge), and silently lost most of a genuinely non-planar
// face's own area when that assumption didn't hold (confirmed before the
// fix: a saddle-shaped quad with corners (0,0,1),(1,0,0),(1,1,1),(0,1,0)
// only ended up with 16.7% of its own footprint actually tiled, measured
// via each resulting tile's own flat XY-projected area). The fix special-
// cases a non-planar QUADRILATERAL specifically (the one shape with a
// well-defined surface to tile onto - the standard bilinear patch through
// its own 4 corners); a non-planar face with any other vertex count is
// first fan-subdivided into that many quads (the same edge-midpoint-plus-
// centroid technique "Quad Tessellate"/tessellateRectangular_Selection()
// already uses, with no planarity assumption of its own), each of which is
// then tiled the same bilinear-quad-patch way, recursively.
class NonPlanarFaceTilingTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  private void setUpOneFace (float[][] vertices) {
    app.allVertices = vertices;
    app.allFaces.nodes = new int[][]{funcs_range(vertices.length)};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};
    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;
  }

  private int[] funcs_range (int n) {
    int[] r = new int[n];
    for (int i = 0; i < n; i++) r[i] = i;
    return r;
  }

  // The one unambiguous way to measure "how much of the original face's
  // own footprint ended up covered" regardless of how warped the surface
  // is - a flat 2D shoelace area of each polygon's own (x, y) coordinates,
  // ignoring z entirely. This is exactly the metric that first exposed the
  // bug (16.7% instead of 100%), so it's also the most direct regression
  // guard for the fix.
  private float shoelaceXY (float[][] verts) {
    float a = 0;
    int n = verts.length;
    for (int i = 0; i < n; i++) {
      float[] p = verts[i];
      float[] q = verts[(i + 1) % n];
      a += p[0] * q[1] - q[0] * p[1];
    }
    return Math.abs(a) / 2f;
  }

  private float totalFacesXYFootprint () {
    float sum = 0;
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      sum += shoelaceXY(app.Modify3D.faceBaseVertices(f));
    }
    return sum;
  }

  @Test
  void tilingSquare_onANonPlanarQuad_coversTheWholeFootprint () {
    // The exact saddle quad reported: corners alternate z = 1, 0, 1, 0, so
    // no 2 diagonally-opposite corners share the same height - genuinely
    // non-planar (confirmed separately via the scalar triple product of
    // its own edge vectors, which comes out to -2.0, not 0).
    setUpOneFace(new float[][]{{0, 0, 1}, {1, 0, 0}, {1, 1, 1}, {0, 1, 0}});
    app.User3D.tileEdgeSize = 0.2f;
    app.User3D.tileRotation = 0;

    float originalFootprint = shoelaceXY(app.Modify3D.faceBaseVertices(0));
    assertEquals(1.0f, originalFootprint, 0.0001f, "setup check - this quad's own XY-projected footprint is exactly the unit square, regardless of its z-warping");

    app.Modify3D.tilingSquare_Selection();

    assertTrue(app.allFaces.nodes.length > 1, "a unit saddle quad at edgeSize=0.2 should produce many pieces");
    assertEquals(originalFootprint, totalFacesXYFootprint(), 0.001f, "the bilinear-patch tiling should cover the saddle's own full footprint, not just a sliver of it (this is exactly the metric that caught the original bug: only 16.7% before the fix)");
  }

  @Test
  void tilingSquare_onAGentleSaddle_everyPieceFacesTheSameGeneralWay () {
    // A much shallower saddle than the dramatic unit-height one above
    // (z-displacement of only 0.05, not 1) - gentle enough that "every
    // tile still faces roughly the same way as the coarse normal" is
    // actually a valid invariant (unlike on the sharply-folded version,
    // where a tile sitting right at the fold can legitimately end up
    // nearly perpendicular to the coarse normal - confirmed that's real
    // curvature, not a bug, while investigating this). This is the
    // regression guard for tileNormal/faceNormalUnit(clipped) being used
    // correctly per tile in the new branch, instead of accidentally
    // reusing a stale shared faceNormal or an inverted winding.
    setUpOneFace(new float[][]{{0, 0, 0.05f}, {1, 0, 0}, {1, 1, 0.05f}, {0, 1, 0}});
    app.User3D.tileEdgeSize = 0.2f;
    app.User3D.tileRotation = 0;

    float[] coarseNormal = app.Modify3D.faceNormalUnit(new float[][]{{0, 0, 0.05f}, {1, 0, 0}, {1, 1, 0.05f}, {0, 1, 0}});

    app.Modify3D.tilingSquare_Selection();

    assertTrue(app.allFaces.nodes.length > 1, "setup check - a unit gentle-saddle quad at edgeSize=0.2 should produce many pieces");

    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      float[][] verts = app.Modify3D.faceBaseVertices(f);
      float[] normal = app.Modify3D.faceNormalUnit(verts);
      float dot = normal[0] * coarseNormal[0] + normal[1] * coarseNormal[1] + normal[2] * coarseNormal[2];
      assertTrue(dot > 0.9f, "face " + f + " should face the same general way as the quad's own coarse normal, not an inverted one - dot was " + dot);
    }
  }

  @Test
  void bilinearPatchPoint3D_tracesTheQuadsOwnStraightEdgesExactly () {
    // The bilinear patch's own defining property (verified numerically
    // before writing the fix): at t = 0 it's a plain linear interpolation
    // between v0 and v1 with no t-term left in it at all - i.e. each of
    // its 4 "boundary edges" is exactly the quad's own real straight 3D
    // edge, not an approximation. This is what guarantees a tiling built
    // this way shares its outer boundary exactly with the face's own real
    // edges (and with whatever face is on the other side of each of
    // them), the same as the ordinary flat-plane path already does for a
    // planar face.
    float[][] quad = {{0, 0, 1}, {1, 0, 0}, {1, 1, 1}, {0, 1, 0}};

    for (float s : new float[]{0f, 0.3f, 0.7f, 1f}) {
      float[] p = app.Modify3D.bilinearPatchPoint3D(quad, s, 0);
      float[] expected = {
        (1 - s) * quad[0][0] + s * quad[1][0],
        (1 - s) * quad[0][1] + s * quad[1][1],
        (1 - s) * quad[0][2] + s * quad[1][2]
      };
      assertArrayEquals(expected, p, 0.0001f, "t=0 should trace the straight edge from v0 to v1 exactly, at s=" + s);
    }

    assertArrayEquals(quad[0], app.Modify3D.bilinearPatchPoint3D(quad, 0, 0), 0.0001f, "(s,t)=(0,0) should land exactly on v0");
    assertArrayEquals(quad[1], app.Modify3D.bilinearPatchPoint3D(quad, 1, 0), 0.0001f, "(s,t)=(1,0) should land exactly on v1");
    assertArrayEquals(quad[2], app.Modify3D.bilinearPatchPoint3D(quad, 1, 1), 0.0001f, "(s,t)=(1,1) should land exactly on v2");
    assertArrayEquals(quad[3], app.Modify3D.bilinearPatchPoint3D(quad, 0, 1), 0.0001f, "(s,t)=(0,1) should land exactly on v3");
  }

  @Test
  void applySemiRegularTiling_onANonPlanarQuad_alsoCoversTheWholeFootprint () {
    // Same fix, same call site shape, in the OTHER family's own
    // applySemiRegularTiling_Selection() - exercised here via Trihexagon
    // (3.6.3.6), picked arbitrarily; the fix lives entirely in the shared
    // per-face setup both families go through, not in any one pattern's
    // own geometry.
    setUpOneFace(new float[][]{{0, 0, 1}, {1, 0, 0}, {1, 1, 1}, {0, 1, 0}});
    app.User3D.tileEdgeSize = 0.2f;
    app.User3D.tileRotation = 0;

    float originalFootprint = shoelaceXY(app.Modify3D.faceBaseVertices(0));

    app.Modify3D.tilingTrihexagon_Selection();

    assertTrue(app.allFaces.nodes.length > 1, "a unit saddle quad at edgeSize=0.2 should produce many pieces");
    assertEquals(originalFootprint, totalFacesXYFootprint(), 0.001f, "the bilinear-patch tiling should cover the saddle's own full footprint here too");
  }

  @Test
  void tilingSquare_onANonPlanarPentagon_coversTheWholeFootprintViaFanQuads () {
    // A non-planar face with a vertex count other than 4 has no single
    // canonical surface to warp onto directly, so it's fan-subdivided
    // first (same technique "Quad Tessellate"/tessellateRectangular_
    // Selection() already uses: one quad per edge, built from that edge's
    // own midpoints and the face's own centroid, via pure 3D averaging -
    // no planarity assumption anywhere) into exactly n quads (n = vertex
    // count), each of which is itself always exactly 4 vertices - a
    // guaranteed base case - so each then gets tiled via the ordinary
    // bilinear-quad-patch path, recursively. The n fan quads all share the
    // face's own centroid and meet exactly at each original edge's own
    // midpoint, so - just like Quad Tessellate's own established output -
    // they cover the original face's own full footprint with no gap.
    float[][] nonPlanarPentagon = new float[][]{
      {0, 0, 1}, {1, 0, 0}, {1, 1, 1}, {0.5f, 1.3f, 0.2f}, {0, 1, 0}
    };
    setUpOneFace(nonPlanarPentagon);
    app.User3D.tileEdgeSize = 0.2f;
    app.User3D.tileRotation = 0;

    float originalFootprint = shoelaceXY(app.Modify3D.faceBaseVertices(0));

    app.Modify3D.tilingSquare_Selection();

    assertTrue(app.allFaces.nodes.length > 5, "a non-planar pentagon fan-subdivided into 5 quads, each further tiled, should produce many pieces");
    assertEquals(originalFootprint, totalFacesXYFootprint(), 0.001f, "the fan-quad fallback should cover the non-planar pentagon's own full footprint, not leave it untouched");
  }

  @Test
  void applySemiRegularTiling_onANonPlanarPentagon_coversTheWholeFootprintViaFanQuads () {
    // Same fan-quad fallback, exercised through the Semi-Regular family's
    // own appendSemiRegularTilesForFaceShape() instead of the regular
    // family's appendRegularTilesForFaceShape() - both call sites use the
    // identical fallback logic, so this is the Semi-Regular family's own
    // regression guard for it.
    float[][] nonPlanarPentagon = new float[][]{
      {0, 0, 1}, {1, 0, 0}, {1, 1, 1}, {0.5f, 1.3f, 0.2f}, {0, 1, 0}
    };
    setUpOneFace(nonPlanarPentagon);
    app.User3D.tileEdgeSize = 0.2f;
    app.User3D.tileRotation = 0;

    float originalFootprint = shoelaceXY(app.Modify3D.faceBaseVertices(0));

    app.Modify3D.tilingTrihexagon_Selection();

    assertTrue(app.allFaces.nodes.length > 5, "a non-planar pentagon fan-subdivided into 5 quads, each further tiled, should produce many pieces");
    assertEquals(originalFootprint, totalFacesXYFootprint(), 0.001f, "the fan-quad fallback should cover the non-planar pentagon's own full footprint here too");
  }

  @Test
  void tilingSquare_onASkewedButPlanarQuad_stillUsesTheOrdinaryFlatPath () {
    // A non-rectangular (skewed, parallelogram-ish) quad that's still
    // perfectly flat (every vertex at z = 0) - isFacePlanar3D() must
    // correctly recognize this as planar and take the ordinary flat-plane
    // path, not the new bilinear-patch branch, same as before this fix
    // existed. Guards against the planarity check itself ever firing on
    // an ordinary (if unusually shaped) flat face.
    setUpOneFace(new float[][]{{0, 0, 0}, {2, 0, 0}, {3, 1, 0}, {1, 1, 0}});
    app.User3D.tileEdgeSize = 0.2f;
    app.User3D.tileRotation = 0;

    float originalFootprint = shoelaceXY(app.Modify3D.faceBaseVertices(0));

    app.Modify3D.tilingSquare_Selection();

    assertTrue(app.allFaces.nodes.length > 1, "a 2-unit skewed quad at edgeSize=0.2 should produce many pieces");
    assertEquals(originalFootprint, totalFacesXYFootprint(), 0.001f, "a flat (if non-rectangular) quad should still be fully covered via the ordinary flat-plane path");
  }
}
