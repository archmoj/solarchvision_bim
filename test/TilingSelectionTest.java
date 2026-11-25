import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers modify3D.pde's applyTiling_Selection() and its Modify-menu entry
// points (tilingSquare_Selection/tilingHexagon_Selection/
// tilingEquilateral_Selection/tilingRhombille_Selection), plus the
// geometry helpers built for them (clipPolygonToFaceBoundary3D/
// clipPolygon_halfPlane3D/polygonArea3D/buildTilingCandidates_UV). Same
// hand-built one-face, one-group fixture style as ModifyGeometryTest.java's
// own tessellateTriangular_Selection integration tests.
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

  @Test
  void tilingHexagon_selectsOnlyTheWholeUnclippedHexagons () {
    // Same selection discipline as the Semi-Regular family: every tile
    // still gets created, but only the whole, unclipped ones end up
    // selected afterward (full replace, not append) - including any
    // clipped boundary fragment that happened to still land on 6 vertices.
    setUpOneFace(new float[][]{{0, 0, 0}, {5, 0, 0}, {5, 5, 0}, {0, 5, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingHexagon_Selection();

    int[] selection = app.Select3D.faceSelection;
    assertTrue(selection.length > 0, "a 5x5 face at edgeSize=1 should contain at least one whole, unclipped hexagon");

    float expectedHexagonArea = (3 * (float) Math.sqrt(3) / 2) * app.User3D.tileEdgeSize * app.User3D.tileEdgeSize;

    for (int idx : selection) {
      assertEquals(6, app.allFaces.nodes[idx].length, "every selected face must be a hexagon");

      float[][] verts = app.Modify3D.faceBaseVertices(idx);
      float[] normal = app.Modify3D.faceNormalUnit(verts);
      float area = app.Modify3D.polygonArea3D(verts, normal);
      assertEquals(expectedHexagonArea, area, 0.0001f, "a selected hexagon must be a true, unclipped regular hexagon, not a same-vertex-count clipped fragment");
    }

    boolean foundUnselectedSixVertexFace = false;
    java.util.HashSet<Integer> selectedSet = new java.util.HashSet<Integer>();
    for (int idx : selection) selectedSet.add(idx);
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      if ((app.allFaces.nodes[f].length == 6) && !selectedSet.contains(f)) foundUnselectedSixVertexFace = true;
    }
    assertTrue(foundUnselectedSixVertexFace, "setup check - this face size should produce at least one clipped-but-still-6-vertex boundary fragment to tell apart from a true whole hexagon");
  }

  // --- tilingRhombille_Selection (a full integration test) --------------
  // Dual of the trihexagonal tiling: the same hexagon lattice as
  // tilingHexagon_Selection above, with each hexagon split into 3 rhombi.

  @Test
  void tilingRhombille_tilesALargeFaceWithoutLosingOrDoublingAnyArea () {
    setUpOneFace(new float[][]{{0, 0, 0}, {5, 0, 0}, {5, 5, 0}, {0, 5, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingRhombille_Selection();

    assertTrue(app.allFaces.nodes.length > 1, "a 5x5 face at edgeSize=1 should produce more than one rhombille-pattern piece");
    assertEquals(25.0f, totalFacesArea(), 0.01f);

    boolean foundWholeRhombus = false;
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      if (app.allFaces.nodes[f].length == 4) foundWholeRhombus = true;
    }
    assertTrue(foundWholeRhombus, "a face this much bigger than one tile should contain at least one unclipped, whole rhombus");
  }

  @Test
  void tilingRhombille_selectsOnlyTheWholeUnclippedRhombi () {
    // Same selection discipline as tilingHexagon_Selection: every tile
    // still gets created, but only the whole, unclipped ones end up
    // selected afterward (full replace, not append) - including any
    // clipped boundary fragment that happened to still land on 4 vertices.
    setUpOneFace(new float[][]{{0, 0, 0}, {5, 0, 0}, {5, 5, 0}, {0, 5, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingRhombille_Selection();

    int[] selection = app.Select3D.faceSelection;
    assertTrue(selection.length > 0, "a 5x5 face at edgeSize=1 should contain at least one whole, unclipped rhombus");

    float expectedRhombusArea = ((float) Math.sqrt(3) / 2) * app.User3D.tileEdgeSize * app.User3D.tileEdgeSize;

    for (int idx : selection) {
      assertEquals(4, app.allFaces.nodes[idx].length, "every selected face must be a rhombus");

      float[][] verts = app.Modify3D.faceBaseVertices(idx);
      float[] normal = app.Modify3D.faceNormalUnit(verts);
      float area = app.Modify3D.polygonArea3D(verts, normal);
      assertEquals(expectedRhombusArea, area, 0.0001f, "a selected rhombus must be a true, unclipped 60/120 deg rhombus, not a same-vertex-count clipped fragment");
    }

    boolean foundUnselectedFourVertexFace = false;
    java.util.HashSet<Integer> selectedSet = new java.util.HashSet<Integer>();
    for (int idx : selection) selectedSet.add(idx);
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      if ((app.allFaces.nodes[f].length == 4) && !selectedSet.contains(f)) foundUnselectedFourVertexFace = true;
    }
    assertTrue(foundUnselectedFourVertexFace, "setup check - this face size should produce at least one clipped-but-still-4-vertex boundary fragment to tell apart from a true whole rhombus");
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

  @Test
  void tilingEquilateral_selectsOnlyTheWholeUnclippedTriangles () {
    // Same selection discipline as the Semi-Regular family: every tile
    // still gets created, but only the whole, unclipped ones end up
    // selected afterward (full replace, not append) - including any
    // clipped boundary fragment that happened to still land on 3 vertices.
    setUpOneFace(new float[][]{{0, 0, 0}, {5, 0, 0}, {5, 5, 0}, {0, 5, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingEquilateral_Selection();

    int[] selection = app.Select3D.faceSelection;
    assertTrue(selection.length > 0, "a 5x5 face at edgeSize=1 should contain at least one whole, unclipped triangle");

    float expectedTriangleArea = ((float) Math.sqrt(3) / 4) * app.User3D.tileEdgeSize * app.User3D.tileEdgeSize;

    for (int idx : selection) {
      assertEquals(3, app.allFaces.nodes[idx].length, "every selected face must be a triangle");

      float[][] verts = app.Modify3D.faceBaseVertices(idx);
      float[] normal = app.Modify3D.faceNormalUnit(verts);
      float area = app.Modify3D.polygonArea3D(verts, normal);
      assertEquals(expectedTriangleArea, area, 0.0001f, "a selected triangle must be a true, unclipped equilateral triangle, not a same-vertex-count clipped fragment");
    }

    boolean foundUnselectedThreeVertexFace = false;
    java.util.HashSet<Integer> selectedSet = new java.util.HashSet<Integer>();
    for (int idx : selection) selectedSet.add(idx);
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      if ((app.allFaces.nodes[f].length == 3) && !selectedSet.contains(f)) foundUnselectedThreeVertexFace = true;
    }
    assertTrue(foundUnselectedThreeVertexFace, "setup check - this face size should produce at least one clipped-but-still-3-vertex boundary fragment to tell apart from a true whole triangle");
  }

  // --- tilingCairo_Selection (a full integration test) ------------------
  // Unlike the three grid-based patterns above, Cairo is grown outward
  // from one seed pentagon via BFS (buildTilingCandidates_UV()'s own
  // TILING_CAIRO branch) rather than placed by a closed-form row/column
  // formula - these tests cover the same area-conservation invariant the
  // other patterns rely on, plus the boundary-clip and rotation behavior,
  // to make sure the generative approach still plugs into the exact same
  // clip/dedupe/splice pipeline correctly.

  @Test
  void tilingCairo_tilesALargeFaceWithoutLosingOrDoublingAnyArea () {
    setUpOneFace(new float[][]{{0, 0, 0}, {5, 0, 0}, {5, 5, 0}, {0, 5, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingCairo_Selection();

    assertTrue(app.allFaces.nodes.length > 1, "a 5x5 face at edgeSize=1 should produce more than one pentagon-pattern piece");
    assertEquals(25.0f, totalFacesArea(), 0.01f);

    boolean foundWholePentagon = false;
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      if (app.allFaces.nodes[f].length == 5) foundWholePentagon = true;
    }
    assertTrue(foundWholePentagon, "a face this much bigger than one tile should contain at least one unclipped, whole pentagon");
  }

  @Test
  void tilingCairo_clipsBoundaryTilesToFitInsteadOfDroppingThem () {
    // A face whose boundary falls mid-pentagon almost everywhere (no
    // special alignment to the BFS growth, unlike the grid patterns'
    // flush-rectangle case) - every boundary piece must still be clipped
    // to fit, never dropped, so the total area must still come out exact.
    setUpOneFace(new float[][]{{0, 0, 0}, {3.7f, 0, 0}, {3.7f, 2.9f, 0}, {0, 2.9f, 0}});
    app.User3D.tileEdgeSize = 0.6f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingCairo_Selection();

    assertTrue(app.allFaces.nodes.length > 1);
    assertEquals(3.7f * 2.9f, totalFacesArea(), 0.01f, "clipped boundary pieces should still add up to the full face area");
  }

  @Test
  void tilingCairo_rotationTurnsThePatternButKeepsTheTotalAreaExact () {
    setUpOneFace(new float[][]{{0, 0, 0}, {5, 0, 0}, {5, 5, 0}, {0, 5, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 37;

    app.Modify3D.tilingCairo_Selection();

    assertTrue(app.allFaces.nodes.length > 1);
    assertEquals(25.0f, totalFacesArea(), 0.01f);
  }

  @Test
  void tilingCairo_selectsOnlyTheWholeUnclippedPentagonsAndExtendsTheGroupRange () {
    // The pattern's own irregular (edges a,b,a,a,a) pentagon has a fixed
    // area of 1.5*edgeSize^2 whatever its rotation (shoelace-verified while
    // deriving the geometry) - same selection discipline as the
    // Semi-Regular family: every pentagon still gets created, but only the
    // whole, unclipped ones end up selected afterward (full replace, not
    // append), including any clipped boundary fragment that happened to
    // still land on 5 vertices.
    setUpOneFace(new float[][]{{0, 0, 0}, {5, 0, 0}, {5, 5, 0}, {0, 5, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingCairo_Selection();

    int n = app.allFaces.nodes.length;
    assertTrue(n > 1);
    assertArrayEquals(new int[]{0, n - 1}, app.allGroups.Faces[0], "the group's face range should grow to cover all new tiles");

    int[] selection = app.Select3D.faceSelection;
    assertTrue(selection.length > 0, "a 5x5 face at edgeSize=1 should contain at least one whole, unclipped pentagon");

    float expectedPentagonArea = 1.5f * app.User3D.tileEdgeSize * app.User3D.tileEdgeSize;

    for (int idx : selection) {
      assertEquals(5, app.allFaces.nodes[idx].length, "every selected face must be a pentagon");

      float[][] verts = app.Modify3D.faceBaseVertices(idx);
      float[] normal = app.Modify3D.faceNormalUnit(verts);
      float area = app.Modify3D.polygonArea3D(verts, normal);
      assertEquals(expectedPentagonArea, area, 0.0001f, "a selected pentagon must be a true, unclipped Cairo pentagon, not a same-vertex-count clipped fragment");
    }

    boolean foundUnselectedFiveVertexFace = false;
    java.util.HashSet<Integer> selectedSet = new java.util.HashSet<Integer>();
    for (int idx : selection) selectedSet.add(idx);
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      if ((app.allFaces.nodes[f].length == 5) && !selectedSet.contains(f)) foundUnselectedFiveVertexFace = true;
    }
    assertTrue(foundUnselectedFiveVertexFace, "setup check - this face size should produce at least one clipped-but-still-5-vertex boundary fragment to tell apart from a true whole pentagon");
  }

  // --- shared selection/group plumbing, same as the tessellate family ---

  @Test
  void tilingSquare_selectsOnlyTheWholeUnclippedSquaresAndExtendsTheGroupRange () {
    // Same selection discipline as the Semi-Regular family: every tile
    // still gets created, but only the whole, unclipped ones end up
    // selected afterward (full replace, not append), including any
    // clipped boundary fragment that happened to still land on 4 vertices
    // (e.g. an edge-clipped square strip, still a quadrilateral but a
    // smaller, non-square one).
    setUpOneFace(new float[][]{{0, 0, 0}, {3.5f, 0, 0}, {3.5f, 3.5f, 0}, {0, 3.5f, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingSquare_Selection();

    int n = app.allFaces.nodes.length;
    assertArrayEquals(new int[]{0, n - 1}, app.allGroups.Faces[0], "the group's face range should grow to cover all new tiles");

    int[] selection = app.Select3D.faceSelection;
    assertTrue(selection.length > 0, "a 3.5x3.5 face at edgeSize=1 should contain at least one whole, unclipped square");

    for (int idx : selection) {
      assertEquals(4, app.allFaces.nodes[idx].length, "every selected face must be a quadrilateral");

      float[][] verts = app.Modify3D.faceBaseVertices(idx);
      float[] normal = app.Modify3D.faceNormalUnit(verts);
      float area = app.Modify3D.polygonArea3D(verts, normal);
      assertEquals(1.0f, area, 0.0001f, "a selected square must be a true, unclipped edgeSize-1 square, not a same-vertex-count clipped fragment");
    }

    boolean foundUnselectedFourVertexFace = false;
    java.util.HashSet<Integer> selectedSet = new java.util.HashSet<Integer>();
    for (int idx : selection) selectedSet.add(idx);
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      if ((app.allFaces.nodes[f].length == 4) && !selectedSet.contains(f)) foundUnselectedFourVertexFace = true;
    }
    assertTrue(foundUnselectedFourVertexFace, "setup check - this face size should produce at least one clipped-but-still-4-vertex boundary fragment to tell apart from a true whole square");
  }
}
