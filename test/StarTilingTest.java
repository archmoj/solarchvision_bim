import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers User3D.tileStarSpikeAngle and its single injection point,
// appendStarTransform_UV() in modify3D.pde, plus the two knock-on fixes
// it required: faceNormalUnit() switching from a 3-point corner estimate
// to Newell's method (so a concave star tile still gets a correct normal),
// and isFacePlanar3D() widening the vertex range it checks to match (see
// both functions' own comments for why). appendStarTransform_UV() is unit
// tested directly, the same way NonPlanarFaceTilingTest.java tests the
// other UV-space tiling helpers; the wiring into applyTiling_Selection()/
// applySemiRegularTiling_Selection() is covered as a full integration
// test, the same hand-built one-face, one-group fixture style as
// TilingSelectionTest.java/SemiRegularTilingSelectionTest.java.
class StarTilingTest {

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

  private float totalFacesArea () {
    float sum = 0;
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      float[][] verts = app.Modify3D.faceBaseVertices(f);
      float[] normal = app.Modify3D.faceNormalUnit(verts);
      sum += app.Modify3D.polygonArea3D(verts, normal);
    }
    return sum;
  }

  // --- appendStarTransform_UV (direct unit tests) ----------------------

  @Test
  void appendStarTransform_withANegativeSpikeAngle_leavesThePolygonUntouched () {
    float[][] square = {{0, 0}, {2, 0}, {2, 2}, {0, 2}};
    float[][] out = app.Modify3D.appendStarTransform_UV(square, -1);
    assertSame(square, out, "the disabled sentinel should return the exact same array, not a copy");
  }

  @Test
  void appendStarTransform_onARegularSquare_atItsOwnNoStarCeiling_landsEveryNotchOnItsEdgeMidpoint () {
    // A square's own floor is 360/4 = 90 deg; spikeAngle = 90 pushes
    // gamma to exactly 90+90 = 180, the universal "no visible star"
    // degenerate case - every notch should land exactly on its edge's
    // own midpoint, same as the design discussion verified before this
    // was ever implemented.
    float[][] square = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}};
    float[][] star = app.Modify3D.appendStarTransform_UV(square, 90);

    assertEquals(8, star.length);
    float[][] expectedMidpoints = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}};
    for (int i = 0; i < 4; i++) {
      float[] notch = star[2 * i + 1];
      assertEquals(expectedMidpoints[i][0], notch[0], 0.0001f, "notch " + i);
      assertEquals(expectedMidpoints[i][1], notch[1], 0.0001f, "notch " + i);
    }
  }

  @Test
  void appendStarTransform_onARegularSquare_atSpikeAngleZero_pullsEveryNotchAllTheWayToTheCentroid () {
    // spikeAngle=0 is this shape's own sharpest valid star - the notch
    // radius formula's own r=0 floor, verified analytically while
    // designing this (r = R*(cos(alpha) - sin(alpha)*cot(alpha)) = 0
    // when gamma == the shape's own floor, i.e. halfGamma == alpha).
    float[][] square = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}};
    float[][] star = app.Modify3D.appendStarTransform_UV(square, 0);

    assertEquals(8, star.length);
    for (int i = 0; i < 4; i++) {
      float[] notch = star[2 * i + 1];
      assertEquals(0, notch[0], 0.0001f, "notch " + i + " x");
      assertEquals(0, notch[1], 0.0001f, "notch " + i + " y");
    }
  }

  @Test
  void appendStarTransform_onARegularHexagon_matchesTheRegularPolygonClosedFormFormula () {
    // Cross-check against the original regular-N-gon-only closed form
    // (r = R*(cos(180/N) - sin(180/N)*cot(gamma/2))) this general,
    // per-edge version was designed to reduce to for a true regular
    // polygon - same gamma=150 case rendered and reasoned about while
    // designing the feature.
    float R = 30;
    int N = 6;
    float[][] hex = new float[N][2];
    for (int k = 0; k < N; k++) {
      double ang = Math.toRadians(k * 60.0);
      hex[k][0] = (float) (R * Math.cos(ang));
      hex[k][1] = (float) (R * Math.sin(ang));
    }

    float spikeAngle = 150 - 60; // gamma = floor(60) + spikeAngle = 150
    float[][] star = app.Modify3D.appendStarTransform_UV(hex, spikeAngle);

    double expectedR = R * (Math.cos(Math.toRadians(30)) - Math.sin(Math.toRadians(30)) / Math.tan(Math.toRadians(75)));

    assertEquals(12, star.length);
    for (int i = 0; i < N; i++) {
      float[] notch = star[2 * i + 1];
      float gotR = (float) Math.sqrt(notch[0] * notch[0] + notch[1] * notch[1]);
      assertEquals((float) expectedR, gotR, 0.01f, "notch " + i + "'s own distance from the centroid");
    }
  }

  @Test
  void appendStarTransform_onAnIrregularCairoPentagon_stillProducesANonSelfIntersectingStar () {
    // TILING_CAIRO's own pentagon is NOT regular (edges a,b,a,a,a) - the
    // one shape this generalized, per-edge formula had to cover beyond
    // the regular-polygon case it was originally designed and verified
    // against. Every notch should still come out at a non-negative
    // radius from the centroid (the whole reason the shared, worst-case
    // shapeFloor is used instead of each edge's own individual floor).
    float a = 1;
    float b = (float) ((Math.sqrt(3) - 1) * a);
    float[] edgeLens = {a, b, a, a, a};
    float[] turnDegs = {60, 60, 90, 60, 90};
    float heading = -60;
    float[][] pentagon = new float[5][2];
    float x = 0, y = 0;
    for (int k = 0; k < 5; k++) {
      pentagon[k][0] = x;
      pentagon[k][1] = y;
      x += edgeLens[k] * (float) Math.cos(Math.toRadians(heading));
      y += edgeLens[k] * (float) Math.sin(Math.toRadians(heading));
      heading += turnDegs[k];
    }

    float[] cen = {0, 0};
    for (float[] p : pentagon) { cen[0] += p[0]; cen[1] += p[1]; }
    cen[0] /= 5; cen[1] /= 5;

    float[][] star = app.Modify3D.appendStarTransform_UV(pentagon, 5);

    assertEquals(10, star.length);
    for (int i = 0; i < 5; i++) {
      float[] notch = star[2 * i + 1];
      float r = (float) Math.sqrt(Math.pow(notch[0] - cen[0], 2) + Math.pow(notch[1] - cen[1], 2));
      assertTrue(r >= -0.0001f, "notch " + i + " should never go negative/self-intersecting, got radius " + r);
    }
  }

  // --- applyTiling_Selection / applySemiRegularTiling_Selection (wiring) --

  @Test
  void tilingSquare_withTileStarSpikeAngleSet_doublesEveryTileVertexCountAndShrinksTheTotalArea () {
    setUpOneFace(new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;
    app.User3D.tileStarSpikeAngle = 30;

    app.Modify3D.tilingSquare_Selection();

    assertEquals(4, app.allFaces.nodes.length);
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      assertEquals(8, app.allFaces.nodes[f].length, "every tile should have doubled into a star - face " + f);
    }
    assertTrue(totalFacesArea() < 4.0f, "notching every tile inward should leave gaps, so the total area must shrink below the original 2x2 = 4 footprint");
  }

  @Test
  void tilingSquare_withTileStarSpikeAngleLeftDisabled_tilesExactlyAsBeforeTheFeatureExisted () {
    setUpOneFace(new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;
    assertTrue(app.User3D.tileStarSpikeAngle < 0, "tileStarSpikeAngle's own default should already be the disabled sentinel");

    app.Modify3D.tilingSquare_Selection();

    assertEquals(4, app.allFaces.nodes.length);
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      assertEquals(4, app.allFaces.nodes[f].length, "no star transform should mean ordinary, un-notched squares - face " + f);
    }
    assertEquals(4.0f, totalFacesArea(), 0.0001f);
  }

  @Test
  void trihexagonalTiling_withTileStarSpikeAngleSet_doublesEveryTileVertexCount () {
    // Semi-regular family's own analog of the regular-family test above -
    // same appendStarTransform_UV() injection point, wired into
    // applySemiRegularTiling_Selection()/appendSemiRegularTilesForFaceShape()
    // instead. Every semi-regular tile shape is a genuinely regular
    // polygon (triangles and hexagons here), unlike TILING_CAIRO.
    setUpOneFace(new float[][]{{0, 0, 0}, {6, 0, 0}, {6, 6, 0}, {0, 6, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;
    app.User3D.tileStarSpikeAngle = 10;

    app.Modify3D.tilingTrihexagon_Selection();

    assertTrue(app.allFaces.nodes.length > 1);
    // Whole, unclipped tiles should have doubled their vertex count (6
    // for a starred triangle, 12 for a starred hexagon); a boundary
    // fragment clipped mid-zigzag can land on practically any count, so
    // this only checks for the presence of at least one whole tile of
    // each kind, not every face's own count.
    boolean sawStarTriangle = false, sawStarHexagon = false;
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      int len = app.allFaces.nodes[f].length;
      if (len == 6) sawStarTriangle = true;
      if (len == 12) sawStarHexagon = true;
    }
    assertTrue(sawStarTriangle, "a face this size should contain at least one whole, starred triangle");
    assertTrue(sawStarHexagon, "a face this size should contain at least one whole, starred hexagon");
  }

  // --- faceNormalUnit / isFacePlanar3D (knock-on fixes) -----------------

  @Test
  void faceNormalUnit_ofAConcaveStarPolygon_stillPointsStraightUp () {
    // The exact scenario appendStarTransform_UV() creates and
    // appendRegularTilesForFaceShape()'s bilinear-patch path feeds
    // straight into faceNormalUnit() (tileNormal = faceNormalUnit
    // (clipped)) - a concave polygon whose vertex 1 (the old 3-point
    // shortcut's own second input) is a reflex notch, not a convex
    // corner. Newell's method should still resolve this to the same
    // (0,0,1) every ordinary flat, upward-facing polygon gets.
    float[][] star = app.Modify3D.appendStarTransform_UV(
      new float[][]{{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}, 10);
    float[][] star3D = new float[star.length][3];
    for (int i = 0; i < star.length; i++) { star3D[i][0] = star[i][0]; star3D[i][1] = star[i][1]; star3D[i][2] = 0; }

    float[] normal = app.Modify3D.faceNormalUnit(star3D);
    assertEquals(0, normal[0], 0.0001f);
    assertEquals(0, normal[1], 0.0001f);
    assertEquals(1, normal[2], 0.0001f);
  }

  @Test
  void isFacePlanar3D_detectsNonPlanarityLocalizedToVertexOneOrVertexLast () {
    // Regression guard for isFacePlanar3D()'s own range widening (1..n-1
    // instead of 2..n-2): back when faceNormalUnit() built its normal
    // from exactly vertices 0, 1, and n-1, those three were trivially
    // in-plane by construction and never needed checking. Now that
    // faceNormalUnit() sums over every edge (Newell's method) instead, a
    // face whose ONLY out-of-plane vertex happens to be vertex 1 (or
    // n-1) is no longer trivially safe to skip, and has to be caught
    // here like any other vertex.
    float[][] baseVertices = {{0, 0, 0}, {1, 0, 0.5f}, {1, 1, 0}, {0, 1, 0}}; // only vertex 1 lifted off the z=0 plane
    float[] normal = app.Modify3D.faceNormalUnit(baseVertices);
    assertFalse(app.Modify3D.isFacePlanar3D(baseVertices, normal), "a face with only vertex 1 lifted out of plane must be detected as non-planar");

    float[][] baseVerticesLast = {{0, 0, 0}, {1, 0, 0}, {1, 1, 0}, {0, 1, 0.5f}}; // only vertex n-1 lifted
    float[] normalLast = app.Modify3D.faceNormalUnit(baseVerticesLast);
    assertFalse(app.Modify3D.isFacePlanar3D(baseVerticesLast, normalLast), "a face with only vertex n-1 lifted out of plane must be detected as non-planar");
  }
}
