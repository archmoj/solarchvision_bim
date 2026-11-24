import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers modify3D.pde's applySemiRegularTiling_Selection() and its first
// entry point, tilingRhombitrihexagon_Selection() (3.4.6.4 - triangles,
// squares, and hexagons), plus buildSemiRegularCandidates_UV()'s own
// SEMIREGULAR_RHOMBITRIHEXAGONAL branch. Same hand-built one-face,
// one-group fixture style as TilingSelectionTest.java's own regular-Tiling
// family tests, but covering this family's one deliberate difference:
// every piece still gets created, but only the whole, unclipped copies of
// the pattern's own highest-vertex-count shape (hexagons here) end up
// selected afterward.
class SemiRegularTilingSelectionTest {

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

  // --- tilingRhombitrihexagon_Selection (a full integration test) ----

  @Test
  void tilingRhombitrihexagon_tilesALargeFaceWithoutLosingOrDoublingAnyArea () {
    setUpOneFace(new float[][]{{0, 0, 0}, {10, 0, 0}, {10, 10, 0}, {0, 10, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingRhombitrihexagon_Selection();

    assertTrue(app.allFaces.nodes.length > 1, "a 10x10 face at edgeSize=1 should produce many pieces");
    assertEquals(100.0f, totalFacesArea(), 0.01f, "triangles + squares + hexagons + every clipped boundary fragment should still add up to the full 10x10 = 100 area");

    boolean foundTriangle = false, foundSquare = false, foundHexagon = false;
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      int n = app.allFaces.nodes[f].length;
      if (n == 3) foundTriangle = true;
      if (n == 4) foundSquare = true;
      if (n == 6) foundHexagon = true;
    }
    assertTrue(foundTriangle, "a face this much bigger than one tile should contain at least one triangle");
    assertTrue(foundSquare, "a face this much bigger than one tile should contain at least one square");
    assertTrue(foundHexagon, "a face this much bigger than one tile should contain at least one hexagon");
  }

  @Test
  void tilingRhombitrihexagon_everyPieceKeepsTheBaseFacesOwnNormalDirection () {
    // Regression test for a winding-direction bug: the square candidate's
    // own 4 corners (buildSemiRegularCandidates_UV()'s SEMIREGULAR_RHOMBITRIHEXAGONAL
    // branch) were originally listed clockwise, the opposite winding from
    // the hexagon's and triangle's own counter-clockwise order - every
    // square this pattern created came out with its normal flipped
    // relative to the base face (and to its own neighboring hexagons/
    // triangles), even though every piece's own area still came out
    // correct (faceNormalUnit()'s cross(U, V) sign doesn't affect its
    // magnitude) - which is why the area-conservation test above couldn't
    // have caught it on its own.
    setUpOneFace(new float[][]{{0, 0, 0}, {10, 0, 0}, {10, 10, 0}, {0, 10, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    float[][] originalBaseVertices = app.Modify3D.faceBaseVertices(0);
    float[] originalNormal = app.Modify3D.faceNormalUnit(originalBaseVertices);

    app.Modify3D.tilingRhombitrihexagon_Selection();

    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      float[][] verts = app.Modify3D.faceBaseVertices(f);
      float[] normal = app.Modify3D.faceNormalUnit(verts);
      float dot = normal[0] * originalNormal[0] + normal[1] * originalNormal[1] + normal[2] * originalNormal[2];
      assertTrue(dot > 0.9f, "face " + f + " (" + verts.length + " vertices) should keep the base face's own normal direction, not an inverted one - dot was " + dot);
    }
  }

  @Test
  void tilingRhombitrihexagon_selectsOnlyTheWholeUnclippedHexagons () {
    // The 3.4.6.4 pattern's own highest-vertex-count shape is the hexagon
    // (6 vertices, vs. the square's 4 and the triangle's 3) - every other
    // piece, including any hexagon-shaped boundary fragment that happened
    // to still land on 6 vertices after clipping, must stay unselected.
    setUpOneFace(new float[][]{{0, 0, 0}, {10, 0, 0}, {10, 10, 0}, {0, 10, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingRhombitrihexagon_Selection();

    int[] selection = app.Select3D.faceSelection;
    assertTrue(selection.length > 0, "a 10x10 face at edgeSize=1 should contain at least one whole, unclipped hexagon");

    float expectedHexagonArea = (3 * (float) Math.sqrt(3) / 2) * app.User3D.tileEdgeSize * app.User3D.tileEdgeSize;

    for (int idx : selection) {
      assertEquals(6, app.allFaces.nodes[idx].length, "every selected face must be a hexagon");

      float[][] verts = app.Modify3D.faceBaseVertices(idx);
      float[] normal = app.Modify3D.faceNormalUnit(verts);
      float area = app.Modify3D.polygonArea3D(verts, normal);
      // A regular, unclipped edgeSize-1 hexagon's own exact area - a
      // clipped-but-coincidentally-6-vertex fragment would not match this
      // precisely, so this is a stronger check than vertex count alone.
      assertEquals(expectedHexagonArea, area, 0.0001f, "a selected hexagon must be a true, unclipped regular hexagon, not a same-vertex-count clipped fragment");
    }

    // At least one 6-vertex face should exist that did NOT make the
    // selection (a boundary hexagon clipped down to a still-6-vertex
    // shape) - otherwise this test (and the exact-area check above)
    // wouldn't actually be exercising the "not the clipped polygons" rule.
    boolean foundUnselectedSixVertexFace = false;
    java.util.HashSet<Integer> selectedSet = new java.util.HashSet<Integer>();
    for (int idx : selection) selectedSet.add(idx);
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      if ((app.allFaces.nodes[f].length == 6) && !selectedSet.contains(f)) foundUnselectedSixVertexFace = true;
    }
    assertTrue(foundUnselectedSixVertexFace, "setup check - this face size should produce at least one clipped-but-still-6-vertex boundary fragment to tell apart from a true whole hexagon");
  }

  @Test
  void tilingRhombitrihexagon_tilesATooSmallFaceWithAnEmptySelection () {
    // Unlike a bounded pattern, this one tiles the whole plane with no
    // gaps - so a face much smaller than one hexagon at this edgeSize
    // isn't "missed" the way an oversized edgeSize can miss a face in the
    // regular Tiling family (there, the grid is re-centered on the face's
    // own bounding box, but every candidate can still clip to nothing if
    // edgeSize is big enough; here, whatever single piece of the pattern
    // the face happens to fall inside always clips down to cover it).
    // What should still hold: the covered area matches the tiny face
    // exactly, and since a fragment this small can only ever be a clipped
    // (not whole) piece, the selection comes out empty.
    setUpOneFace(new float[][]{{0, 0, 0}, {0.05f, 0, 0}, {0.05f, 0.05f, 0}, {0, 0.05f, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingRhombitrihexagon_Selection();

    assertEquals(0.05f * 0.05f, totalFacesArea(), 0.0001f, "whatever single piece of the pattern the face falls inside should still cover its own full, tiny area");
    assertEquals(0, app.Select3D.faceSelection.length, "a fragment this much smaller than one hexagon can only be a clipped piece, so nothing should qualify for selection");
  }

  // --- tilingTruncatedHexagon_Selection (a full integration test) ----

  @Test
  void tilingTruncatedHexagon_tilesALargeFaceWithoutLosingOrDoublingAnyArea () {
    setUpOneFace(new float[][]{{0, 0, 0}, {15, 0, 0}, {15, 15, 0}, {0, 15, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingTruncatedHexagon_Selection();

    assertTrue(app.allFaces.nodes.length > 1, "a 15x15 face at edgeSize=1 should produce many pieces");
    assertEquals(225.0f, totalFacesArea(), 0.01f, "triangles + dodecagons + every clipped boundary fragment should still add up to the full 15x15 = 225 area");

    boolean foundTriangle = false, foundDodecagon = false;
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      int n = app.allFaces.nodes[f].length;
      if (n == 3) foundTriangle = true;
      if (n == 12) foundDodecagon = true;
    }
    assertTrue(foundTriangle, "a face this much bigger than one tile should contain at least one triangle");
    assertTrue(foundDodecagon, "a face this much bigger than one tile should contain at least one dodecagon");
  }

  @Test
  void tilingTruncatedHexagon_everyPieceKeepsTheBaseFacesOwnNormalDirection () {
    // Same regression shape as the Rhombitrihexagon normal-direction test -
    // this pattern's triangle winding was verified by hand (shoelace check)
    // before writing the code, but this test is what would actually catch
    // a regression if that winding were ever broken again.
    setUpOneFace(new float[][]{{0, 0, 0}, {15, 0, 0}, {15, 15, 0}, {0, 15, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    float[][] originalBaseVertices = app.Modify3D.faceBaseVertices(0);
    float[] originalNormal = app.Modify3D.faceNormalUnit(originalBaseVertices);

    app.Modify3D.tilingTruncatedHexagon_Selection();

    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      float[][] verts = app.Modify3D.faceBaseVertices(f);
      float[] normal = app.Modify3D.faceNormalUnit(verts);
      float dot = normal[0] * originalNormal[0] + normal[1] * originalNormal[1] + normal[2] * originalNormal[2];
      assertTrue(dot > 0.9f, "face " + f + " (" + verts.length + " vertices) should keep the base face's own normal direction, not an inverted one - dot was " + dot);
    }
  }

  @Test
  void tilingTruncatedHexagon_selectsOnlyTheWholeUnclippedDodecagons () {
    // The 3.12.12 pattern's own highest-vertex-count shape is the dodecagon
    // (12 vertices, vs. the triangle's 3) - every other piece, including
    // any dodecagon-shaped boundary fragment that happened to still land
    // on 12 vertices after clipping, must stay unselected.
    setUpOneFace(new float[][]{{0, 0, 0}, {15, 0, 0}, {15, 15, 0}, {0, 15, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingTruncatedHexagon_Selection();

    int[] selection = app.Select3D.faceSelection;
    assertTrue(selection.length > 0, "a 15x15 face at edgeSize=1 should contain at least one whole, unclipped dodecagon");

    float expectedDodecagonArea = 3 * (2 + (float) Math.sqrt(3)) * app.User3D.tileEdgeSize * app.User3D.tileEdgeSize;

    for (int idx : selection) {
      assertEquals(12, app.allFaces.nodes[idx].length, "every selected face must be a dodecagon");

      float[][] verts = app.Modify3D.faceBaseVertices(idx);
      float[] normal = app.Modify3D.faceNormalUnit(verts);
      float area = app.Modify3D.polygonArea3D(verts, normal);
      // A regular, unclipped edgeSize-1 dodecagon's own exact area - a
      // clipped-but-coincidentally-12-vertex fragment would not match this
      // precisely, so this is a stronger check than vertex count alone.
      assertEquals(expectedDodecagonArea, area, 0.0001f, "a selected dodecagon must be a true, unclipped regular dodecagon, not a same-vertex-count clipped fragment");
    }
  }

  @Test
  void tilingTruncatedHexagon_tilesATooSmallFaceWithAnEmptySelection () {
    // Same whole-plane-coverage reasoning as the Rhombitrihexagon version:
    // a face much smaller than one tile still gets covered exactly by
    // whatever single piece it falls inside, and a fragment this small can
    // only ever be a clipped (not whole) piece, so the selection is empty.
    setUpOneFace(new float[][]{{0, 0, 0}, {0.05f, 0, 0}, {0.05f, 0.05f, 0}, {0, 0.05f, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingTruncatedHexagon_Selection();

    assertEquals(0.05f * 0.05f, totalFacesArea(), 0.0001f, "whatever single piece of the pattern the face falls inside should still cover its own full, tiny area");
    assertEquals(0, app.Select3D.faceSelection.length, "a fragment this much smaller than one dodecagon can only be a clipped piece, so nothing should qualify for selection");
  }

  // --- tilingTrihexagon_Selection (a full integration test) ----

  @Test
  void tilingTrihexagon_tilesALargeFaceWithoutLosingOrDoublingAnyArea () {
    setUpOneFace(new float[][]{{0, 0, 0}, {12, 0, 0}, {12, 12, 0}, {0, 12, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingTrihexagon_Selection();

    assertTrue(app.allFaces.nodes.length > 1, "a 12x12 face at edgeSize=1 should produce many pieces");
    assertEquals(144.0f, totalFacesArea(), 0.01f, "triangles + hexagons + every clipped boundary fragment should still add up to the full 12x12 = 144 area");

    boolean foundTriangle = false, foundHexagon = false;
    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      int n = app.allFaces.nodes[f].length;
      if (n == 3) foundTriangle = true;
      if (n == 6) foundHexagon = true;
    }
    assertTrue(foundTriangle, "a face this much bigger than one tile should contain at least one triangle");
    assertTrue(foundHexagon, "a face this much bigger than one tile should contain at least one hexagon");
  }

  @Test
  void tilingTrihexagon_everyPieceKeepsTheBaseFacesOwnNormalDirection () {
    // Same regression shape as the other two patterns' normal-direction
    // tests - this pattern's triangle winding (v1, apex, v2) was verified
    // by hand (shoelace check) before writing the code, but this test is
    // what would actually catch a regression if that winding were ever
    // broken again.
    setUpOneFace(new float[][]{{0, 0, 0}, {12, 0, 0}, {12, 12, 0}, {0, 12, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    float[][] originalBaseVertices = app.Modify3D.faceBaseVertices(0);
    float[] originalNormal = app.Modify3D.faceNormalUnit(originalBaseVertices);

    app.Modify3D.tilingTrihexagon_Selection();

    for (int f = 0; f < app.allFaces.nodes.length; f++) {
      float[][] verts = app.Modify3D.faceBaseVertices(f);
      float[] normal = app.Modify3D.faceNormalUnit(verts);
      float dot = normal[0] * originalNormal[0] + normal[1] * originalNormal[1] + normal[2] * originalNormal[2];
      assertTrue(dot > 0.9f, "face " + f + " (" + verts.length + " vertices) should keep the base face's own normal direction, not an inverted one - dot was " + dot);
    }
  }

  @Test
  void tilingTrihexagon_selectsOnlyTheWholeUnclippedHexagons () {
    // The 3.6.3.6 pattern's own highest-vertex-count shape is the hexagon
    // (6 vertices, vs. the triangle's 3) - every other piece, including any
    // hexagon-shaped boundary fragment that happened to still land on 6
    // vertices after clipping, must stay unselected.
    setUpOneFace(new float[][]{{0, 0, 0}, {12, 0, 0}, {12, 12, 0}, {0, 12, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingTrihexagon_Selection();

    int[] selection = app.Select3D.faceSelection;
    assertTrue(selection.length > 0, "a 12x12 face at edgeSize=1 should contain at least one whole, unclipped hexagon");

    float expectedHexagonArea = (3 * (float) Math.sqrt(3) / 2) * app.User3D.tileEdgeSize * app.User3D.tileEdgeSize;

    for (int idx : selection) {
      assertEquals(6, app.allFaces.nodes[idx].length, "every selected face must be a hexagon");

      float[][] verts = app.Modify3D.faceBaseVertices(idx);
      float[] normal = app.Modify3D.faceNormalUnit(verts);
      float area = app.Modify3D.polygonArea3D(verts, normal);
      // A regular, unclipped edgeSize-1 hexagon's own exact area - a
      // clipped-but-coincidentally-6-vertex fragment would not match this
      // precisely, so this is a stronger check than vertex count alone.
      assertEquals(expectedHexagonArea, area, 0.0001f, "a selected hexagon must be a true, unclipped regular hexagon, not a same-vertex-count clipped fragment");
    }
  }

  @Test
  void tilingTrihexagon_tilesATooSmallFaceWithAnEmptySelection () {
    // Same whole-plane-coverage reasoning as the other two patterns: a face
    // much smaller than one tile still gets covered exactly by whatever
    // single piece it falls inside, and a fragment this small can only ever
    // be a clipped (not whole) piece, so the selection is empty.
    setUpOneFace(new float[][]{{0, 0, 0}, {0.05f, 0, 0}, {0.05f, 0.05f, 0}, {0, 0.05f, 0}});
    app.User3D.tileEdgeSize = 1.0f;
    app.User3D.tileRotation = 0;

    app.Modify3D.tilingTrihexagon_Selection();

    assertEquals(0.05f * 0.05f, totalFacesArea(), 0.0001f, "whatever single piece of the pattern the face falls inside should still cover its own full, tiny area");
    assertEquals(0, app.Select3D.faceSelection.length, "a fragment this much smaller than one hexagon can only be a clipped piece, so nothing should qualify for selection");
  }
}
