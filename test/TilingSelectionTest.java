import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers modify3D.pde's applyTiling_Selection() and its three Modify-menu
// entry points (tilingSquare_Selection/tilingHexagon_Selection/
// tilingEquilateral_Selection), plus the geometry helpers built for them
// (clipPolygonToFaceBoundary3D/clipPolygon_halfPlane3D/polygonArea3D/
// buildTilingCandidates_UV). Same hand-built one-face, one-group fixture
// style as ModifyGeometryTest.java's own tessellateTriangular_Selection
// integration tests.
class TilingSelectionTest {

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

  // Sum of every current face's own area, via the same polygonArea3D()
  // the implementation uses to reject degenerate slivers - used below as
  // a tiling-pattern-agnostic correctness check: however a face gets cut
  // up, the pieces' areas should always add back up to the original.
  private float totalFacesArea () {
    float sum = 0;
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      float[][] verts = app.Modify3D.faceBaseVertices(f);
      float[] normal = app.Modify3D.faceNormalUnit(verts);
      sum += app.Modify3D.polygonArea3D(verts, normal);
    }
    return sum;
  }

  // --- tilingSquare_Selection (a full integration test) ---------------

  @Test
  void tilingSquare_tilesAFlushRectangleIntoExactWholeSquares () {
    // A 2x3 rectangle, flush with tileEdgeSize=1 in both directions -
    // the exact example used while designing this feature: centering a
    // spacing-1 grid aligned to the face's own first edge on a 2x3 face
    // lands flush on all four sides, giving exactly 6 whole tiles with
    // zero clipping (and, crucially, none of the padding ring
    // buildTilingCandidates_UV() adds around it survives the degenerate-
    // sliver area filter - see polygonArea3D's own usage above it).
    setUpOneFace(new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 3, 0}, {0, 3, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingSquare_Selection();

    assertEquals(6, app.allFaces.nodes.length);
    assertEquals(12, app.allVertices.length); // a 3x4 grid of shared vertices (3 u-values x 4 v-values), no duplicates

    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      assertEquals(4, app.allFaces.nodes[f].length, "every tile should be a whole, unclipped square - face " + f);
    }

    assertEquals(6.0f, totalFacesArea(), 0.0001f, "6 unit squares should account for the whole 2x3 = 6 area, with nothing missing or double-counted");
  }

  @Test
  void tilingSquare_clipsBoundaryTilesToFitInsteadOfDroppingThem () {
    // 1.5 x 2: the height (2) is a whole multiple of tileEdgeSize but the
    // width (1.5) isn't, so every tile is clipped down to a narrower
    // 0.75-wide strip in u - and, per the explicit "clip to fit, don't
    // drop them" decision, all 4 of them (2 columns x 2 rows) should
    // still be there, just narrower, rather than 2 of them vanishing.
    setUpOneFace(new float[][]{{0, 0, 0}, {1.5f, 0, 0}, {1.5f, 2, 0}, {0, 2, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingSquare_Selection();

    assertEquals(4, app.allFaces.nodes.length);
    assertEquals(3.0f, totalFacesArea(), 0.0001f, "the clipped pieces should still add up to the full 1.5x2 = 3 area");
  }

  @Test
  void tilingSquare_rotationTiltsTheGridButKeepsTheTotalAreaExact () {
    // A 4x4 square, rotated 45 degrees off the face's own first edge -
    // no longer flush with the boundary, so this fragments into many
    // more (smaller, irregularly-clipped) pieces than the 16 a
    // zero-rotation grid would give - but the total covered area must
    // stay exactly the original 16, whatever shape the pieces end up.
    setUpOneFace(new float[][]{{0, 0, 0}, {4, 0, 0}, {4, 4, 0}, {0, 4, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 45;

    app.Modify3D.tilingSquare_Selection();

    assertTrue(app.allFaces.nodes.length > 16, "a 45-degree-rotated grid should fragment into more, smaller pieces than the flush-aligned 16");
    assertEquals(16.0f, totalFacesArea(), 0.001f);
  }

  // --- tilingHexagon_Selection (a full integration test) ---------------

  @Test
  void tilingHexagon_tilesALargeFaceWithoutLosingOrDoublingAnyArea () {
    setUpOneFace(new float[][]{{0, 0, 0}, {5, 0, 0}, {5, 5, 0}, {0, 5, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingHexagon_Selection();

    assertTrue(app.allFaces.nodes.length > 1, "a 5x5 face at edgeSize=1 should produce more than one hexagon-pattern piece");
    assertEquals(25.0f, totalFacesArea(), 0.01f);

    boolean foundWholeHexagon = false;
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      if (app.allFaces.nodes[f].length == 6) foundWholeHexagon = true;
    }
    assertTrue(foundWholeHexagon, "a face this much bigger than one tile should contain at least one unclipped, whole hexagon");
  }

  // --- tilingEquilateral_Selection (a full integration test) -----------

  @Test
  void tilingEquilateral_tilesALargeFaceWithoutLosingOrDoublingAnyArea () {
    setUpOneFace(new float[][]{{0, 0, 0}, {5, 0, 0}, {5, 5, 0}, {0, 5, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingEquilateral_Selection();

    assertTrue(app.allFaces.nodes.length > 1, "a 5x5 face at edgeSize=1 should produce more than one triangular piece");
    assertEquals(25.0f, totalFacesArea(), 0.01f);

    boolean foundWholeTriangle = false;
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      if (app.allFaces.nodes[f].length == 3) foundWholeTriangle = true;
    }
    assertTrue(foundWholeTriangle, "a face this much bigger than one tile should contain at least one unclipped, whole triangle");
  }

  // --- shared selection/group plumbing, same as the tessellate family ---

  @Test
  void tilingSquare_appendsTheNewFacesToTheSelectionAndExtendsTheGroupRange () {
    setUpOneFace(new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingSquare_Selection();

    assertEquals(4, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 3}, app.allGroups.Faces[0], "the group's face range should grow to cover all 4 new tiles");
    assertArrayEquals(new int[]{0, 1, 2, 3}, app.Select3D.faceSelection, "all 4 new tiles should end up selected");
  }
}
