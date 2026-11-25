import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.util.ArrayList;
import processing.data.FloatList;

class ModifyGeometryTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // --- remove_item_from_primary_list -----------------------------

  @Test
  void removeItem_dropsThePositionAndDecrementsValuesAtLaterPositions () {
    // Operates on ARRAY POSITION relative to q, not on the removed
    // value itself: every element sitting at a later position than the
    // removed one gets decremented by 1, regardless of its own value.
    int[] result = app.Modify3D.remove_item_from_primary_list(1, new int[]{10, 20, 30, 40});
    assertArrayEquals(new int[]{10, 29, 39}, result);
  }

  @Test
  void removeItem_atTheFirstPositionDecrementsEveryOtherElement () {
    int[] result = app.Modify3D.remove_item_from_primary_list(0, new int[]{10, 20, 30});
    assertArrayEquals(new int[]{19, 29}, result);
  }

  @Test
  void removeItem_atTheLastPositionLeavesEarlierElementsUnchanged () {
    int[] result = app.Modify3D.remove_item_from_primary_list(2, new int[]{10, 20, 30});
    assertArrayEquals(new int[]{10, 20}, result);
  }

  // --- isPolymeshCategorySelected / isGroupOrFaceCategorySelected ----

  @Test
  void isPolymeshCategorySelected_isTrueForGroupFacePolylineVertex () {
    for (int category : new int[]{
      app.ObjectCategory.GROUP, app.ObjectCategory.FACE,
      app.ObjectCategory.POLYLINE, app.ObjectCategory.VERTEX
    }) {
      app.currentObjectCategory = category;
      assertTrue(app.Modify3D.isPolymeshCategorySelected(), "category=" + category);
    }
  }

  @Test
  void isPolymeshCategorySelected_isFalseForOtherCategories () {
    app.currentObjectCategory = app.ObjectCategory.SOLID;
    assertFalse(app.Modify3D.isPolymeshCategorySelected());
  }

  @Test
  void isGroupOrFaceCategorySelected_isTrueOnlyForGroupAndFace () {
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    assertTrue(app.Modify3D.isGroupOrFaceCategorySelected());

    app.currentObjectCategory = app.ObjectCategory.FACE;
    assertTrue(app.Modify3D.isGroupOrFaceCategorySelected());

    app.currentObjectCategory = app.ObjectCategory.POLYLINE;
    assertFalse(app.Modify3D.isGroupOrFaceCategorySelected());

    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    assertFalse(app.Modify3D.isGroupOrFaceCategorySelected());
  }

  // --- faceCentroid ------------------------------------------------

  @Test
  void faceCentroid_isTheAverageOfTheVertices () {
    float[][] square = {{0, 0, 0}, {3, 0, 0}, {3, 3, 0}, {0, 3, 0}};
    float[] centroid = app.Modify3D.faceCentroid(square);
    assertArrayEquals(new float[]{1.5f, 1.5f, 0f}, centroid, 0.0001f);
  }

  // --- isFaceInGroupRange (given a hand-built group range) -----------

  @Test
  void isFaceInGroupRange_isInclusiveOnBothEnds () {
    app.allGroups.Faces = new int[][]{{2, 5}}; // group 0 spans faces 2..5

    assertTrue(app.Modify3D.isFaceInGroupRange(2, 0));  // start, inclusive
    assertTrue(app.Modify3D.isFaceInGroupRange(5, 0));  // end, inclusive
    assertTrue(app.Modify3D.isFaceInGroupRange(3, 0));  // interior
    assertFalse(app.Modify3D.isFaceInGroupRange(1, 0)); // just before
    assertFalse(app.Modify3D.isFaceInGroupRange(6, 0)); // just after
  }

  // --- faceBaseVertices (given a hand-built mesh) ---------------------

  @Test
  void faceBaseVertices_looksUpEachNodesPointInAllVertices () {
    app.allVertices = new float[][]{{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}}; // face 0 references points 0, 1, 2

    float[][] result = app.Modify3D.faceBaseVertices(0);

    assertEquals(3, result.length);
    assertArrayEquals(new float[]{1, 2, 3}, result[0], 0.0001f);
    assertArrayEquals(new float[]{4, 5, 6}, result[1], 0.0001f);
    assertArrayEquals(new float[]{7, 8, 9}, result[2], 0.0001f);
  }

  // --- compactRemovedVertices (given a hand-built mesh) ---------------

  @Test
  void compactRemovedVertices_dropsFlaggedPointsAndRemapsAllReferences () {
    app.allVertices = new float[][]{
      {0, 0, 0}, {1, 1, 1}, {2, 2, 2}, {3, 3, 3}, {4, 4, 4}
    };
    app.allFaces.nodes = new int[][]{{0, 1, 2}, {2, 3, 4}};
    app.allPolylines.nodes = new int[][]{{1, 3}};

    // Remove points 1 and 3.
    app.Modify3D.compactRemovedVertices(new boolean[]{false, true, false, true, false});

    // Surviving points, in order: former indices 0, 2, 4.
    assertEquals(3, app.allVertices.length);
    assertArrayEquals(new float[]{0, 0, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{2, 2, 2}, app.allVertices[1], 0.0001f);
    assertArrayEquals(new float[]{4, 4, 4}, app.allVertices[2], 0.0001f);

    // Every reference is rewritten to the new (compacted) indices - a
    // reference that pointed at a removed vertex becomes -1, since this
    // function assumes any such usages were already redirected
    // elsewhere before compaction runs (as weldSceneVertices_Selection
    // does, via its own remapping loop, before calling this).
    assertArrayEquals(new int[]{0, -1, 1}, app.allFaces.nodes[0]);
    assertArrayEquals(new int[]{1, -1, 2}, app.allFaces.nodes[1]);
    assertArrayEquals(new int[]{-1, -1}, app.allPolylines.nodes[0]);
  }

  // --- accumulateOffsetFromRing (given a hand-built ring face) --------

  @Test
  void accumulateOffsetFromRing_type0AccumulatesTheFacesCrossProductNormal () {
    // A flat square in the z=0 plane, wound counter-clockwise when
    // viewed from +Z: every corner's local (next-this) x (prev-this)
    // cross product points the same way here, (0,0,1), so accumulating
    // across all 4 corners of the one face vNo belongs to should give
    // 4 * (0,0,1) * _amount.
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    int[][] ringNodes = {{0, 1, 2, 3}};

    float[][] offsetValues = new float[1][3];
    int[] offsetNum = new int[1];

    app.Modify3D.accumulateOffsetFromRing(ringNodes, 0, 0, 0, 5f, offsetValues, offsetNum);

    assertArrayEquals(new float[]{0, 0, 20f}, offsetValues[0], 0.001f);
    assertEquals(4, offsetNum[0]); // one contribution per corner of the ring face
  }

  @Test
  void accumulateOffsetFromRing_type1CancelsOutOnASymmetricSquare () {
    // _type=1 sums the two edge vectors at each corner (instead of
    // taking their cross product) before normalizing - on a symmetric
    // square, those 4 unit "corner bisector" directions point exactly
    // opposite each other in pairs and cancel to zero. This is what
    // distinguishes _type=1 from _type=0 above, which does not cancel.
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    int[][] ringNodes = {{0, 1, 2, 3}};

    float[][] offsetValues = new float[1][3];
    int[] offsetNum = new int[1];

    app.Modify3D.accumulateOffsetFromRing(ringNodes, 0, 0, 1, 5f, offsetValues, offsetNum);

    assertArrayEquals(new float[]{0, 0, 0}, offsetValues[0], 0.001f);
    assertEquals(4, offsetNum[0]); // still one contribution per corner, even though they cancel
  }

  // --- tessellateTriangular_Selection (a full integration test) -----
  //
  // Unlike everything above, this drives the actual public entry point
  // end to end against a hand-built one-face, one-group scene, rather
  // than calling an extracted helper directly. It exercises
  // isGroupOrFaceCategorySelected, selectFacesAndGroups_fromCurrentSelection
  // (and, through it, Select3D.convert_Faces_to_Groups), findOwningGroupId,
  // allGroups.inserted_nFaces, faceBaseVertices/faceCentroid,
  // allPoints.create, spliceFaceWithNewFaces, and appendNewFaceSelection,
  // all wired together - closer to the "genuine integration test" the
  // rest of modify3D.pde would need than a unit test of one piece.
  //
  // Before writing it, switch_category/_selection_changed/
  // _view_changed and UI_toolBar.revise()/WIN3D.revise() were checked:
  // every one of them just sets a boolean "needs update" flag or a plain
  // numeric field, with no rendering/graphics calls - so they're safe to
  // invoke from a freshly-constructed, never-setup()'d sketch instance.

  @Test
  void tessellateTriangular_fansASingleQuadIntoFourTrianglesAroundANewCentroid () {
    // A flat 2x2 square, one face, one group spanning just that face.
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0}; // group 0 spans face 0 only

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.tessellateTriangular_Selection();

    // The one quad becomes 4 triangles (n=4), each fanning from one
    // edge of the original quad to a new centroid vertex.
    assertEquals(4, app.allFaces.nodes.length);
    assertEquals(5, app.allVertices.length); // 4 original points + 1 new centroid
    assertArrayEquals(new float[]{1, 1, 0}, app.allVertices[4], 0.0001f); // centroid of the square

    assertArrayEquals(new int[]{0, 1, 4}, app.allFaces.nodes[0]);
    assertArrayEquals(new int[]{1, 2, 4}, app.allFaces.nodes[1]);
    assertArrayEquals(new int[]{2, 3, 4}, app.allFaces.nodes[2]);
    assertArrayEquals(new int[]{3, 0, 4}, app.allFaces.nodes[3]);

    // The group's face range grew from a single face [0,0] to all 4 new
    // ones [0,3] - inserted_nFaces() extending the end pointer in place.
    assertArrayEquals(new int[]{0, 3}, app.allGroups.Faces[0]);

    // The original face's own selection, plus the 3 new faces it split
    // into (appendNewFaceSelection), in that order.
    assertArrayEquals(new int[]{0, 1, 2, 3}, app.Select3D.faceSelection);
  }

  // This function creates only ONE new vertex per face (the centroid),
  // so two different faces' centroids landing on the exact same
  // position is a near-impossible coincidence in practice - unlike
  // tessellateRectangular_Selection()'s edge-midpoints, which routinely
  // coincide between neighboring faces. There's no realistic scene to
  // reproduce an actual collision with, so this test instead places a
  // vertex that ALREADY sits exactly at the face's centroid before
  // tessellating, and checks that getOrCreateVertex_atPosition() (the
  // same helper used by tessellateRectangular_Selection() and
  // tessellateRowsColumns_Selection()) reuses that existing vertex
  // rather than creating a duplicate one on top of it.
  @Test
  void tessellateTriangular_reusesAnExistingVertexAlreadySittingAtTheCentroid_insteadOfDuplicatingIt () {
    app.allVertices = new float[][]{
      {0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}, // the face's own 4 corners
      {1, 1, 0}                                   // pre-existing, unused vertex at the face's centroid
    };
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.tessellateTriangular_Selection();

    // No new vertex was created - the fan reuses vertex 4, which was
    // already sitting exactly at (1, 1, 0).
    assertEquals(5, app.allVertices.length);

    assertArrayEquals(new int[]{0, 1, 4}, app.allFaces.nodes[0]);
    assertArrayEquals(new int[]{1, 2, 4}, app.allFaces.nodes[1]);
    assertArrayEquals(new int[]{2, 3, 4}, app.allFaces.nodes[2]);
    assertArrayEquals(new int[]{3, 0, 4}, app.allFaces.nodes[3]);
  }

  // --- tessellateRectangular_Selection (a full integration test) -----
  //
  // Same wiring as the Triangular test above, but this operation fans
  // out to a NEW EDGE-MIDPOINT vertex per side plus one shared center
  // vertex, producing quads rather than triangles - a deliberately
  // different result shape from tessellateTriangular_Selection despite
  // sharing almost the same call graph, worth distinguishing explicitly.

  @Test
  void tessellateRectangular_splitsASingleQuadIntoFourSmallerQuadsAroundANewCentroid () {
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.tessellateRectangular_Selection();

    assertEquals(4, app.allFaces.nodes.length);
    // 4 original corners + 4 new edge-midpoints + 1 new center.
    assertEquals(9, app.allVertices.length);

    // New vertices are created in this order: all 4 edge midpoints
    // (indices 4-7, one per original side, s then s_prev), then the
    // center (index 8).
    assertArrayEquals(new float[]{0, 1, 0}, app.allVertices[4], 0.0001f); // mid of corner0-corner3
    assertArrayEquals(new float[]{1, 0, 0}, app.allVertices[5], 0.0001f); // mid of corner1-corner0
    assertArrayEquals(new float[]{2, 1, 0}, app.allVertices[6], 0.0001f); // mid of corner2-corner1
    assertArrayEquals(new float[]{1, 2, 0}, app.allVertices[7], 0.0001f); // mid of corner3-corner2
    assertArrayEquals(new float[]{1, 1, 0}, app.allVertices[8], 0.0001f); // centroid

    // Each new quad is {this side's edge midpoint, the original corner,
    // the next side's edge midpoint, the shared center}.
    assertArrayEquals(new int[]{4, 0, 5, 8}, app.allFaces.nodes[0]);
    assertArrayEquals(new int[]{5, 1, 6, 8}, app.allFaces.nodes[1]);
    assertArrayEquals(new int[]{6, 2, 7, 8}, app.allFaces.nodes[2]);
    assertArrayEquals(new int[]{7, 3, 4, 8}, app.allFaces.nodes[3]);

    assertArrayEquals(new int[]{0, 3}, app.allGroups.Faces[0]);
    assertArrayEquals(new int[]{0, 1, 2, 3}, app.Select3D.faceSelection);
  }

  // This is the fix for a real bug: running Quad Tessellate a
  // SECOND time on an already-tessellated selection used to create a
  // brand-new, separate vertex for every edge shared between two
  // sibling quads from the first pass, landing exactly on top of that
  // edge's already-existing midpoint - visually one continuous grid,
  // but not actually connected by shared vertex indices across most of
  // its own interior. getOrCreateVertex_atPosition() (above
  // tessellateRectangular_Selection() itself) is the fix: reuse
  // whatever vertex is already sitting at that exact position instead
  // of duplicating it.
  @Test
  void tessellateRectangular_runASecondTime_reusesTheFirstPassesSharedEdgeMidpoints_insteadOfDuplicatingThem () {
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.tessellateRectangular_Selection(); // pass 1: 4 quads around vertex 8, confirmed shared by the test above
    app.Modify3D.tessellateRectangular_Selection(); // pass 2: tessellates those same 4 quads again

    assertEquals(16, app.allFaces.nodes.length);

    // No two vertices should ever occupy the exact same position - that
    // would mean a position got duplicated instead of reused.
    for (int i = 0; i < app.allVertices.length; i++) {
      for (int j = i + 1; j < app.allVertices.length; j++) {
        boolean samePosition = (app.allVertices[i][0] == app.allVertices[j][0])
          && (app.allVertices[i][1] == app.allVertices[j][1])
          && (app.allVertices[i][2] == app.allVertices[j][2]);
        assertFalse(samePosition, "vertex " + i + " and vertex " + j + " sit at the same position " + java.util.Arrays.toString(app.allVertices[i]) + " - should be ONE shared vertex, not two");
      }
    }

    // Every vertex that lies on an edge genuinely shared by two of the
    // 16 final faces (i.e. isn't on the original quad's own outer
    // boundary) must actually BE that one shared index, appearing in
    // both faces' own node lists - not just visually coincide.
    java.util.HashMap<Integer, Integer> useCount = new java.util.HashMap<>();
    for (int[] face : app.allFaces.nodes) {
      for (int v : face) {
        useCount.merge(v, 1, Integer::sum);
      }
    }
    int interiorVertexCount = 0;
    for (int count : useCount.values()) {
      if (count > 1) interiorVertexCount++;
    }
    assertTrue(interiorVertexCount > 0, "at least some vertices must be genuinely shared between faces after two tessellation passes");
  }

  // Two separately-selected, edge-adjacent faces tessellated in the
  // SAME call must also share their new midpoint along that common
  // edge, not just two sibling sub-faces produced from the SAME
  // original face (already covered above) - getOrCreateVertex_
  // atPosition() scans the WHOLE of allPoints, which by the time the
  // second selected face is processed already includes whatever the
  // first one just created, so this cross-face case is covered by the
  // same fix.
  @Test
  void tessellateRectangular_twoAdjacentFacesInOneCall_shareTheirCommonEdgesMidpoint () {
    // Two unit quads sharing the edge between vertex 1 and vertex 2.
    app.allVertices = new float[][]{
      {0, 0, 0}, {1, 0, 0}, {1, 1, 0}, {0, 1, 0}, // face 0
      {2, 0, 0}, {2, 1, 0}                        // face 1's own other two corners
    };
    app.allFaces.nodes = new int[][]{
      {0, 1, 2, 3},
      {1, 4, 5, 2}
    };
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}};

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 1};

    app.Select3D.faceSelection = new int[]{0, 1};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.tessellateRectangular_Selection();

    // The shared edge's midpoint, (1, 0.5, 0), must be exactly ONE
    // vertex, used by a face belonging to each original side - not two
    // coincident vertices, one per side.
    int sharedMidpointVertex = -1;
    for (int v = 0; v < app.allVertices.length; v++) {
      if ((app.allVertices[v][0] == 1) && (app.allVertices[v][1] == 0.5f) && (app.allVertices[v][2] == 0)) {
        assertEquals(-1, sharedMidpointVertex, "the shared edge's midpoint must exist as exactly one vertex, not be duplicated");
        sharedMidpointVertex = v;
      }
    }
    assertTrue(sharedMidpointVertex >= 0, "expected to find the shared edge's midpoint vertex at all");

    // Neither original corner vertex (1 or even the un-shared 0/4) is a
    // reliable "which original face did this sub-face come from?"
    // marker - a sub-face touching the shared midpoint only ever also
    // touches vertex 1 or vertex 2 (both shared) plus its OWN face's
    // center, never the far corner. Each original face's own centroid
    // is a reliable per-side marker instead: face 0's is (0.5,0.5,0),
    // face 1's is (1.5,0.5,0) - distinct positions, so distinct
    // vertices, and every one of that face's own sub-pieces touches it.
    int centerFace0Vertex = -1;
    int centerFace1Vertex = -1;
    for (int v = 0; v < app.allVertices.length; v++) {
      if ((app.allVertices[v][0] == 0.5f) && (app.allVertices[v][1] == 0.5f) && (app.allVertices[v][2] == 0)) centerFace0Vertex = v;
      if ((app.allVertices[v][0] == 1.5f) && (app.allVertices[v][1] == 0.5f) && (app.allVertices[v][2] == 0)) centerFace1Vertex = v;
    }
    assertTrue(centerFace0Vertex >= 0);
    assertTrue(centerFace1Vertex >= 0);

    boolean usedOnFace0Side = false;
    boolean usedOnFace1Side = false;
    for (int[] face : app.allFaces.nodes) {
      boolean hasSharedMidpoint = false;
      boolean hasCenterFace0 = false;
      boolean hasCenterFace1 = false;
      for (int v : face) {
        if (v == sharedMidpointVertex) hasSharedMidpoint = true;
        if (v == centerFace0Vertex) hasCenterFace0 = true;
        if (v == centerFace1Vertex) hasCenterFace1 = true;
      }
      if (hasSharedMidpoint && hasCenterFace0) usedOnFace0Side = true;
      if (hasSharedMidpoint && hasCenterFace1) usedOnFace1Side = true;
    }
    assertTrue(usedOnFace0Side, "the shared midpoint should be used by one of face 0's own tessellated pieces");
    assertTrue(usedOnFace1Side, "the shared midpoint should be used by one of face 1's own tessellated pieces");
  }

  // --- changeVisibilityFaces_Scene / reverseVisibilityFaces_Scene -----
  //
  // Unlike the *_Selection operations above, these two act on every
  // face in the scene unconditionally - no Select3D or
  // currentObjectCategory setup needed at all.

  @Test
  void changeVisibilityFacesScene_setsEveryFaceToTheGivenVisibilityRegardlessOfItsCurrentValue () {
    app.allFaces.nodes = new int[][]{{0}, {0}, {0}}; // 3 arbitrary faces
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}, {0, 0, 0, 1, 0, 0}, {0, 0, 0, 2, 0, 0}};

    app.Modify3D.changeVisibilityFaces_Scene(1);

    assertEquals(1, app.allFaces.getVisibility(0));
    assertEquals(1, app.allFaces.getVisibility(1));
    assertEquals(1, app.allFaces.getVisibility(2));
  }

  @Test
  void reverseVisibilityFacesScene_flips0and1ButLeavesOtherValuesUntouched () {
    app.allFaces.nodes = new int[][]{{0}, {0}, {0}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}, {0, 0, 0, 1, 0, 0}, {0, 0, 0, 2, 0, 0}};

    app.Modify3D.reverseVisibilityFaces_Scene();

    assertEquals(1, app.allFaces.getVisibility(0)); // 0 -> 1
    assertEquals(0, app.allFaces.getVisibility(1)); // 1 -> 0
    assertEquals(2, app.allFaces.getVisibility(2)); // anything else is left as-is
  }

  // --- changeVisibilityFaces_Selection --------------------------------
  //
  // Unlike the *_Scene versions, this one only touches faces reachable
  // through the current selection - checked here via the VERTEX
  // category branch (Select3D.convert_Vertices_to_Faces).

  @Test
  void changeVisibilityFacesSelection_onlyTouchesFacesReachableFromTheSelectedVertex () {
    app.allVertices = new float[][]{{0, 0, 0}, {1, 1, 1}};
    app.allFaces.nodes = new int[][]{{0}, {1}}; // face 0 touches vertex 0, face 1 touches vertex 1
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}};

    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0};

    app.Modify3D.changeVisibilityFaces_Selection(1);

    assertEquals(1, app.allFaces.getVisibility(0)); // reachable from vertex 0
    assertEquals(0, app.allFaces.getVisibility(1)); // not selected - untouched (default 0)
  }

  // --- changeVisibilityPolylines_Scene / _Selection / reverse -----
  //
  // Exact structural analogs of the Faces versions above, operating on
  // allPolylines instead - included for completeness since they're
  // separate functions, even though the logic mirrors what's already
  // verified for faces.

  @Test
  void changeVisibilityPolylinesScene_setsEveryPolylineRegardlessOfCurrentValue () {
    app.allPolylines.nodes = new int[][]{{0}, {0}};
    app.allPolylines.options = new int[][]{{0, 0, 0, 0, 0, 0}, {0, 0, 0, 1, 0, 0}};

    app.Modify3D.changeVisibilityPolylines_Scene(1);

    assertEquals(1, app.allPolylines.getVisibility(0));
    assertEquals(1, app.allPolylines.getVisibility(1));
  }

  @Test
  void reverseVisibilityPolylinesScene_flips0and1ButLeavesOtherValuesUntouched () {
    app.allPolylines.nodes = new int[][]{{0}, {0}, {0}};
    app.allPolylines.options = new int[][]{{0, 0, 0, 0, 0, 0}, {0, 0, 0, 1, 0, 0}, {0, 0, 0, 2, 0, 0}};

    app.Modify3D.reverseVisibilityPolylines_Scene();

    assertEquals(1, app.allPolylines.getVisibility(0));
    assertEquals(0, app.allPolylines.getVisibility(1));
    assertEquals(2, app.allPolylines.getVisibility(2));
  }

  @Test
  void changeVisibilityPolylinesSelection_isANoOpWhenTheCategoryDoesNotMatch () {
    // The whole conditional body (including the visibility-setting loop
    // itself) lives inside the GROUP/POLYLINE/VERTEX category check -
    // with a non-matching category (FACE here), nothing happens at all,
    // even if polylineSelection was already populated.
    app.allPolylines.nodes = new int[][]{{0}};
    app.allPolylines.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.Select3D.polylineSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.changeVisibilityPolylines_Selection(1);

    assertEquals(0, app.allPolylines.getVisibility(0)); // untouched
  }

  // --- isolate_Selection (a full integration test) --------------------
  //
  // Combines changeVisibilityFaces_Scene/_Selection and
  // changeVisibilityPolylines_Scene/_Selection: hide everything, then
  // reveal only what the current GROUP selection reaches - both its
  // faces AND its polylines together, which is why GROUP (rather than
  // FACE or POLYLINE alone) is the category used here: it's the only
  // one both underlying *_Selection functions' gates accept at once.

  @Test
  void isolateSelection_hidesEverythingExceptTheSelectedGroupsFacesAndPolylines () {
    app.allFaces.nodes = new int[][]{{0}, {0}, {0}}; // 3 faces
    app.allFaces.options = new int[3][6];
    app.allPolylines.nodes = new int[][]{{0}, {0}}; // 2 polylines
    app.allPolylines.options = new int[2][6];

    // Start everything visible, to prove isolate actually hides what it should.
    for (int f = 0; f < 3; f++) app.allFaces.setVisibility(f, 1);
    for (int p = 0; p < 2; p++) app.allPolylines.setVisibility(p, 1);

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{1, 1};     // group 0 reaches only face 1
    app.allGroups.Polylines[0] = new int[]{0, 0}; // and only polyline 0

    app.Select3D.groupSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.GROUP;

    app.Modify3D.isolate_Selection();

    assertEquals(0, app.allFaces.getVisibility(0));
    assertEquals(1, app.allFaces.getVisibility(1)); // the one face the group reaches
    assertEquals(0, app.allFaces.getVisibility(2));

    assertEquals(1, app.allPolylines.getVisibility(0)); // the one polyline the group reaches
    assertEquals(0, app.allPolylines.getVisibility(1));
  }

  // --- selectVertices_fromCurrentSelection -----------------------

  @Test
  void selectVerticesFromCurrentSelection_convertsFaceSelectionThenSorts () {
    app.allVertices = new float[][]{{0, 0, 0}, {1, 1, 1}, {2, 2, 2}};
    app.allFaces.nodes = new int[][]{{2, 0, 1}}; // deliberately unsorted node order
    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.selectVertices_fromCurrentSelection();

    // vertexSelection is deduped/collected in the face's own node order by
    // convert_Faces_to_Vertices, but this function always sorts
    // afterward regardless of that order.
    assertArrayEquals(new int[]{0, 1, 2}, app.Select3D.vertexSelection);
  }

  // --- selectFacesAndGroups_fromCurrentSelection ----------------------

  @Test
  void selectFacesAndGroupsFromCurrentSelection_sortsBothBeforeAndAfterConversion () {
    // Two groups whose face ranges are deliberately out of numeric order
    // relative to their group ids (group 0 -> faces 5-6, group 1 ->
    // faces 0-1): rangeUnion() walks groupSelection in whatever order it's
    // given, so if groupSelection weren't sorted first, or faceSelection weren't
    // sorted after, the result would come out as [5,6,0,1] instead of
    // ascending - this test is specifically shaped to make both sort
    // calls matter, not just one.
    app.allGroups.makeEmpty(2);
    app.allGroups.Faces[0] = new int[]{5, 6};
    app.allGroups.Faces[1] = new int[]{0, 1};
    app.allFaces.nodes = new int[7][0]; // faces 0-6 need to exist

    app.Select3D.groupSelection = new int[]{1, 0}; // deliberately unsorted input
    app.currentObjectCategory = app.ObjectCategory.GROUP;

    app.Modify3D.selectFacesAndGroups_fromCurrentSelection();

    assertArrayEquals(new int[]{0, 1}, app.Select3D.groupSelection);
    assertArrayEquals(new int[]{0, 1, 5, 6}, app.Select3D.faceSelection);
  }

  // --- repositionVertices_Selection -------------------------------

  @Test
  void repositionVertices_movesEverySelectedVertexToTheirBoundingBoxCenter () {
    // Deliberately asymmetric points, to distinguish "bounding-box
    // center" (this function's actual behavior: (min+max)/2) from
    // "average position" (which would give a different answer here):
    // min=0, max=10 -> center=5, but the average of {0,1,10} is 3.667.
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {10, 0, 0}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1, 2};

    app.Modify3D.repositionVertices_Selection();

    assertArrayEquals(new float[]{5, 0, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{5, 0, 0}, app.allVertices[1], 0.0001f);
    assertArrayEquals(new float[]{5, 0, 0}, app.allVertices[2], 0.0001f);
  }

  // --- offsetVertices_Selection (a full integration test) -------------
  //
  // Combines accumulateOffsetFromRing (already unit-tested above) with
  // averaging by contribution count and the actual point-move step -
  // reusing the same flat square, where accumulateOffsetFromRing_type0's
  // test already established the raw accumulated total is (0,0,20) with
  // 4 contributions, so this function should move the vertex by their
  // average, (0,0,5).

  @Test
  void offsetVertices_movesEachVertexByTheAverageOfItsRingNormals () {
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0};

    app.Modify3D.offsetVertices_Selection(0, 5f);

    assertArrayEquals(new float[]{0, 0, 5}, app.allVertices[0], 0.0001f);
  }

  // --- separateVertices_Selection ----------------------------------

  @Test
  void separateVertices_givesEachFaceItsOwnIndependentCopyOfASharedVertex () {
    // Vertex 0 is shared by both faces. Separating it doesn't give the
    // two faces one new shared duplicate - each usage gets its OWN
    // brand-new point at the same coordinates, so the two faces end up
    // not sharing any vertex at all afterward.
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {2, 0, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}, {0, 2}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0};

    app.Modify3D.separateVertices_Selection();

    assertEquals(5, app.allVertices.length); // 3 original + 2 independent duplicates
    assertArrayEquals(new int[]{3, 1}, app.allFaces.nodes[0]);
    assertArrayEquals(new int[]{4, 2}, app.allFaces.nodes[1]);
    assertArrayEquals(new float[]{0, 0, 0}, app.allVertices[3], 0.0001f);
    assertArrayEquals(new float[]{0, 0, 0}, app.allVertices[4], 0.0001f);
    assertEquals(0, app.Select3D.vertexSelection.length); // deselected afterward
  }

  // --- weldSceneVertices_Selection (a full integration test) ----------
  //
  // Fixed bug: this function used to declare `int found = -1;`
  // immediately followed by `if (found != -1) { ... }` around both its
  // faces-search and polylines-search loops - a condition that could
  // never be true, since `found` was just set to -1 with nothing in
  // between to change it. Both searches were unreachable dead code, so
  // the function did nothing except select vertices, build an all-false
  // toRemove array, and deselect - no welding ever actually happened.
  // Fixed by removing those two guards (see modify3D.pde); `found` is
  // what those searches COMPUTE, not a precondition for running them,
  // matching the pattern weldObjectsVertices_Selection already used
  // correctly.
  //
  // Note the weld direction here: iterating vertexSelection from largest to
  // smallest and only matching `q > vNo` means a higher-indexed vertex
  // gets welded INTO a lower-indexed one - the lower index always
  // survives.

  @Test
  void weldSceneVertices_mergesNearbyVerticesAcrossTheWholeSceneNotJustTheSelection () {
    // Point 0 and point 1 are 0.001 apart; point 2 is far away.
    app.allVertices = new float[][]{{0, 0, 0}, {0.001f, 0, 0}, {5, 5, 5}};
    app.allFaces.nodes = new int[][]{{1}}; // one face referencing the higher-indexed point of the close pair
    app.allPolylines.nodes = new int[0][];

    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1, 2};

    app.Modify3D.weldSceneVertices_Selection(0.01f);

    // Point 1 (the higher index) got welded into point 0 (the lower
    // index, which survives) and removed; point 2 (too far to merge)
    // becomes the new index 1 after compaction.
    assertEquals(2, app.allVertices.length);
    assertArrayEquals(new float[]{0, 0, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{5, 5, 5}, app.allVertices[1], 0.0001f);

    assertArrayEquals(new int[]{0}, app.allFaces.nodes[0]); // redirected from 1 to the surviving 0

    assertEquals(0, app.Select3D.vertexSelection.length); // deselected afterward
  }

  // --- weldObjectsVertices_Selection (a full integration test) --------
  //
  // This function does NOT share weldSceneVertices_Selection's bug
  // (fixed above) - its search loop has no such guard - so it was
  // already tested correctly.

  @Test
  void weldObjectsVertices_mergesNearbyVerticesAndRedirectsAllReferences () {
    // Points 0 and 1 are 0.001 apart (within max_distance); point 2 is
    // far away and should be left alone.
    app.allVertices = new float[][]{{0, 0, 0}, {0.001f, 0, 0}, {5, 5, 5}};
    app.allFaces.nodes = new int[][]{{0}, {1}}; // face 0 references point 0, face 1 references point 1
    app.allPolylines.nodes = new int[0][];

    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1, 2};

    app.Modify3D.weldObjectsVertices_Selection(0.01f);

    // Point 0 got welded into point 1 (redirected, then point 0 removed
    // and everything compacted) - point 1 survives as the new index 0,
    // and point 2 (untouched, too far to merge) becomes index 1.
    assertEquals(2, app.allVertices.length);
    assertArrayEquals(new float[]{0.001f, 0, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{5, 5, 5}, app.allVertices[1], 0.0001f);

    // Both faces now reference the same (surviving, remapped) point.
    assertArrayEquals(new int[]{0}, app.allFaces.nodes[0]);
    assertArrayEquals(new int[]{0}, app.allFaces.nodes[1]);
  }

  // --- insertEdgeOpenings_Selection (a full integration test) --------
  //
  // Unlike the tessellate*_Selection functions, this one does NOT call
  // appendNewFaceSelection - the newly-created triangular faces are
  // never added to Select3D.faceSelection, even though they now exist in the
  // scene. Worth confirming explicitly since it's easy to assume every
  // face-splitting operation updates the selection the same way.

  @Test
  void insertEdgeOpenings_insetsTheBaseFaceAndRingsItWithNewTriangles () {
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.insertEdgeOpenings_Selection(); // User3D.modifierOpeningDeviation defaults to 0.5 (edge midpoints)

    assertEquals(5, app.allFaces.nodes.length); // the inset base face + 4 new triangles
    assertEquals(8, app.allVertices.length);    // 4 original + 4 new edge points (no center point here)

    assertArrayEquals(new float[]{0, 1, 0}, app.allVertices[4], 0.0001f);
    assertArrayEquals(new float[]{1, 0, 0}, app.allVertices[5], 0.0001f);
    assertArrayEquals(new float[]{2, 1, 0}, app.allVertices[6], 0.0001f);
    assertArrayEquals(new float[]{1, 2, 0}, app.allVertices[7], 0.0001f);

    // The base face shrinks to reference only the new edge points.
    assertArrayEquals(new int[]{4, 5, 6, 7}, app.allFaces.nodes[0]);
    // Each new triangle connects one original corner back out to its two neighboring edge points.
    assertArrayEquals(new int[]{4, 0, 5}, app.allFaces.nodes[1]);
    assertArrayEquals(new int[]{5, 1, 6}, app.allFaces.nodes[2]);
    assertArrayEquals(new int[]{6, 2, 7}, app.allFaces.nodes[3]);
    assertArrayEquals(new int[]{7, 3, 4}, app.allFaces.nodes[4]);

    // The group's range grows by n=4 this time (1 base + 4 new = 5
    // faces total, vs. tessellateTriangular/Rectangular's n-1=3), since
    // the base face is kept (just reshaped) rather than being one of
    // the "new" ones.
    assertArrayEquals(new int[]{0, 4}, app.allGroups.Faces[0]);

    // Selection is untouched - see the class-level note above.
    assertArrayEquals(new int[]{0}, app.Select3D.faceSelection);
  }

  // --- forceTriangulateFaces_Selection (a full integration test) ------
  //
  // Contrast test for the ">3 nodes" gate: a triangle in the same group
  // as a quad should be left completely untouched, while the quad gets
  // fan-triangulated exactly like tessellateTriangular_Selection would.

  @Test
  void forceTriangulate_skipsATriangleButProcessesAQuadInTheSameGroup () {
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{
      {0, 1, 2},    // face 0: a triangle (already 3 nodes - should be left alone)
      {0, 1, 2, 3}  // face 1: a quad (should be triangulated)
    };
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}};

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 1}; // group 0 spans both faces

    app.Select3D.faceSelection = new int[]{0, 1};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.forceTriangulateFaces_Selection();

    assertEquals(5, app.allFaces.nodes.length); // triangle untouched + quad's 4 sub-triangles
    assertEquals(5, app.allVertices.length);    // 4 original + 1 new centroid (only from the quad)

    // The triangle is completely unchanged, still at index 0.
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);

    // The quad's fan triangulation, same shape as tessellateTriangular's.
    assertArrayEquals(new float[]{1, 1, 0}, app.allVertices[4], 0.0001f);
    assertArrayEquals(new int[]{0, 1, 4}, app.allFaces.nodes[1]);
    assertArrayEquals(new int[]{1, 2, 4}, app.allFaces.nodes[2]);
    assertArrayEquals(new int[]{2, 3, 4}, app.allFaces.nodes[3]);
    assertArrayEquals(new int[]{3, 0, 4}, app.allFaces.nodes[4]);

    assertArrayEquals(new int[]{0, 4}, app.allGroups.Faces[0]); // grew by netShift=3 (n-1 of the quad)
    assertArrayEquals(new int[]{0, 1, 2, 3, 4}, app.Select3D.faceSelection);
  }

  // --- optimizeFace_Selection (a full integration test) ----------------

  @Test
  void optimizeFace_removesRedundantCollinearVerticesFromAFace () {
    // A rectangle with a redundant point sitting exactly on the middle
    // of its bottom edge - collinear with its neighbors, so
    // funcs.optimizeVertices should drop it.
    app.allVertices = new float[][]{
      {0, 0, 0}, {1, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}
    };
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3, 4}}; // node ids double as point indices here, for simplicity

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.optimizeFace_Selection();

    // Point 1 (the redundant collinear midpoint) is dropped; the other
    // 4 node ids survive, in their original order.
    assertArrayEquals(new int[]{0, 2, 3, 4}, app.allFaces.nodes[0]);
  }

  // --- autoNormalFaces_Selection --------------------------------------

  @Test
  void autoNormalFaces_leavesAnIsolatedFaceUnchanged () {
    // Select3D.intersect() unconditionally skips face index 0
    // (`if (f > 0)`), so a lone selected face sitting at index 0 can
    // never register a hit against anything - not even itself - no
    // matter which way it's wound. See
    // autoNormalFaces_reversesAFaceWhoseNormalPointsIntoAnotherFace
    // near the end of this file for the case where a hit actually occurs.
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {0, 1, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{0, 0, 0, 1, 0, 0}}; // visible

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.autoNormalFaces_Selection();

    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
  }

  // --- insertCornerOpenings_Selection (a full integration test) ------
  //
  // Inset a single new corner point per side, forming n new quads
  // between each original edge and the shrunk (inset) base face.

  @Test
  void insertCornerOpenings_insetsTheBaseFaceAndRingsItWithQuadsFromTheOriginalEdges () {
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.User3D.modifierOpeningArea = 0.25f; // sqrt(0.25) = 0.5

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.insertCornerOpenings_Selection();

    assertEquals(5, app.allFaces.nodes.length); // the inset base face + 4 new quads
    assertEquals(8, app.allVertices.length);    // 4 original + 4 new inset corners

    assertArrayEquals(new float[]{0.5f, 0.5f, 0}, app.allVertices[4], 0.0001f);
    assertArrayEquals(new float[]{1.5f, 0.5f, 0}, app.allVertices[5], 0.0001f);
    assertArrayEquals(new float[]{1.5f, 1.5f, 0}, app.allVertices[6], 0.0001f);
    assertArrayEquals(new float[]{0.5f, 1.5f, 0}, app.allVertices[7], 0.0001f);

    assertArrayEquals(new int[]{4, 5, 6, 7}, app.allFaces.nodes[0]); // the inset base face
    // Each new quad connects one inset corner, the two ORIGINAL corners
    // of that side, and the next side's inset corner.
    assertArrayEquals(new int[]{4, 0, 1, 5}, app.allFaces.nodes[1]);
    assertArrayEquals(new int[]{5, 1, 2, 6}, app.allFaces.nodes[2]);
    assertArrayEquals(new int[]{6, 2, 3, 7}, app.allFaces.nodes[3]);
    assertArrayEquals(new int[]{7, 3, 0, 4}, app.allFaces.nodes[4]);

    // Same as insertEdgeOpenings: the group grows by n=4 (base kept +
    // 4 new = 5 faces total), and the selection is left untouched (no
    // appendNewFaceSelection call in this function either).
    assertArrayEquals(new int[]{0, 4}, app.allGroups.Faces[0]);
    assertArrayEquals(new int[]{0}, app.Select3D.faceSelection);
  }

  // --- insertParallelOpenings_Selection (a full integration test) ----
  //
  // Two new "edge" points per side (deviation-weighted toward the
  // corner from each neighboring midpoint) plus one "center" point per
  // side (area-weighted toward the centroid) - 3n new points and 2n new
  // quads total, considerably more than the other two openings variants.

  @Test
  void insertParallelOpenings_ringsTheBaseFaceWithPairedQuadsPerSide () {
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.User3D.modifierOpeningDeviation = 0.5f;
    app.User3D.modifierOpeningArea = 0.25f; // sqrt(0.25) = 0.5

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.insertParallelOpenings_Selection();

    assertEquals(9, app.allFaces.nodes.length); // the (re-shaped) base face + 4 sides x 2 quads
    assertEquals(16, app.allVertices.length);   // 4 original + 4 sides x 3 new points (A, B, center)

    // Per side s, points are created in the order A[s], B[s], center[s].
    assertArrayEquals(new float[]{0, 0.5f, 0}, app.allVertices[4], 0.0001f);  // A0
    assertArrayEquals(new float[]{0.5f, 0, 0}, app.allVertices[5], 0.0001f);  // B0
    assertArrayEquals(new float[]{0.5f, 0.5f, 0}, app.allVertices[6], 0.0001f); // center0
    assertArrayEquals(new float[]{1.5f, 0, 0}, app.allVertices[7], 0.0001f);  // A1
    assertArrayEquals(new float[]{2, 0.5f, 0}, app.allVertices[8], 0.0001f);  // B1
    assertArrayEquals(new float[]{1.5f, 0.5f, 0}, app.allVertices[9], 0.0001f); // center1

    // The base face is reshaped to the ring of per-side center points.
    assertArrayEquals(new int[]{6, 9, 12, 15}, app.allFaces.nodes[0]);

    // Two new quads for side 0: one from the original corner out to
    // (B0, center0, A0), and one bridging center0 to center1 via B0/A1.
    assertArrayEquals(new int[]{0, 5, 6, 4}, app.allFaces.nodes[1]);
    assertArrayEquals(new int[]{5, 7, 9, 6}, app.allFaces.nodes[2]);

    // Like the corner/edge variants, no appendNewFaceSelection call.
    assertArrayEquals(new int[]{0}, app.Select3D.faceSelection);
  }

  // --- insertRotatedOpenings_Selection (a full integration test) -----
  //
  // One edge point per side (same as insertEdgeOpenings_Selection),
  // then one center point derived from THAT edge point (not directly
  // from the original corner) - each side becomes a single 5-sided
  // face touching the original corner, both its neighboring edge
  // points, and both their derived center points.

  @Test
  void insertRotatedOpenings_buildsAPentagonPerSideFromEdgeThenCenterPoints () {
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.User3D.modifierOpeningDeviation = 0.5f;
    app.User3D.modifierOpeningArea = 0.25f; // sqrt(0.25) = 0.5

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.insertRotatedOpenings_Selection();

    assertEquals(5, app.allFaces.nodes.length); // the reshaped base face + 4 pentagons
    assertEquals(12, app.allVertices.length);   // 4 original + 4 sides x 2 new points (edge, center)

    // Per side s, points are created in the order edge[s], center[s].
    assertArrayEquals(new float[]{0, 1, 0}, app.allVertices[4], 0.0001f);   // edge0 (same as insertEdgeOpenings')
    assertArrayEquals(new float[]{0.5f, 1, 0}, app.allVertices[5], 0.0001f); // center0, derived from edge0
    assertArrayEquals(new float[]{1, 0, 0}, app.allVertices[6], 0.0001f);   // edge1
    assertArrayEquals(new float[]{1, 0.5f, 0}, app.allVertices[7], 0.0001f); // center1

    assertArrayEquals(new int[]{5, 7, 9, 11}, app.allFaces.nodes[0]); // reshaped to the center ring

    // Side 0's pentagon: its own edge point, the original corner,
    // the next side's edge point, then back through both center points.
    assertArrayEquals(new int[]{4, 0, 6, 7, 5}, app.allFaces.nodes[1]);

    assertArrayEquals(new int[]{0}, app.Select3D.faceSelection);
  }

  // --- tessellateRowsColumns_Selection (a full integration test) ------
  //
  // Requires exactly a 4-node face (unlike the other tessellate*/
  // insert* functions, which work on any n-gon), subdividing it into a
  // Columns x Rows grid of quads via bilinear interpolation - the 4
  // corner grid points are reused as the ORIGINAL corner node ids
  // rather than newly created points, which is what this test is
  // specifically checking.

  @Test
  void tessellateRowsColumns_subdividesAQuadIntoAGridReusingItsOwnCorners () {
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.User3D.modifierTessellateColumns = 2;
    app.User3D.modifierTessellateRows = 2;

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.tessellateRowsColumns_Selection();

    assertEquals(4, app.allFaces.nodes.length); // 2x2 = 4 sub-quads (the original face becomes the first one)
    assertEquals(9, app.allVertices.length);    // 4 original corners (reused) + 5 new interior/edge points

    // The 4 interior/edge-midpoint grid points that aren't one of the
    // original 4 corners, in creation order.
    assertArrayEquals(new float[]{0, 1, 0}, app.allVertices[4], 0.0001f); // left edge midpoint
    assertArrayEquals(new float[]{1, 0, 0}, app.allVertices[5], 0.0001f); // bottom edge midpoint
    assertArrayEquals(new float[]{1, 1, 0}, app.allVertices[6], 0.0001f); // center
    assertArrayEquals(new float[]{1, 2, 0}, app.allVertices[7], 0.0001f); // top edge midpoint
    assertArrayEquals(new float[]{2, 1, 0}, app.allVertices[8], 0.0001f); // right edge midpoint

    assertArrayEquals(new int[]{0, 5, 6, 4}, app.allFaces.nodes[0]); // bottom-left, reusing corner 0
    assertArrayEquals(new int[]{4, 6, 7, 3}, app.allFaces.nodes[1]); // top-left, reusing corner 3
    assertArrayEquals(new int[]{5, 1, 8, 6}, app.allFaces.nodes[2]); // bottom-right, reusing corner 1
    assertArrayEquals(new int[]{6, 8, 2, 7}, app.allFaces.nodes[3]); // top-right, reusing corner 2

    assertArrayEquals(new int[]{0, 3}, app.allGroups.Faces[0]); // grew by netShift = nNewFaces-1 = 3
    assertArrayEquals(new int[]{0, 1, 2, 3}, app.Select3D.faceSelection);
  }

  // Same bug class as tessellateRectangular_Selection(): two separately-
  // selected, edge-adjacent quads tessellated in the SAME call must
  // share their new grid point along that common edge instead of each
  // creating its own duplicate sitting at the same position.
  // getOrCreateVertex_atPosition() (used in the "else" branch above, for
  // every grid point that isn't one of the face's own 4 original
  // corners) is the fix.
  @Test
  void tessellateRowsColumns_twoAdjacentFacesInOneCall_shareTheirCommonEdgesGridPoints () {
    // Two unit quads sharing the edge between vertex 1 and vertex 2 -
    // same layout as tessellateRectangular_twoAdjacentFacesInOneCall_
    // shareTheirCommonEdgesMidpoint() above.
    app.allVertices = new float[][]{
      {0, 0, 0}, {1, 0, 0}, {1, 1, 0}, {0, 1, 0}, // face 0
      {2, 0, 0}, {2, 1, 0}                        // face 1's own other two corners
    };
    app.allFaces.nodes = new int[][]{
      {0, 1, 2, 3},
      {1, 4, 5, 2}
    };
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}};
    app.User3D.modifierTessellateColumns = 2;
    app.User3D.modifierTessellateRows = 2;

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 1};

    app.Select3D.faceSelection = new int[]{0, 1};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.tessellateRowsColumns_Selection();

    // No two vertices should ever occupy the exact same position - that
    // would mean a position got duplicated instead of reused.
    for (int i = 0; i < app.allVertices.length; i++) {
      for (int j = i + 1; j < app.allVertices.length; j++) {
        boolean samePosition = (app.allVertices[i][0] == app.allVertices[j][0])
          && (app.allVertices[i][1] == app.allVertices[j][1])
          && (app.allVertices[i][2] == app.allVertices[j][2]);
        assertFalse(samePosition, "vertex " + i + " and vertex " + j + " sit at the same position " + java.util.Arrays.toString(app.allVertices[i]) + " - should be ONE shared vertex, not two");
      }
    }

    // The shared edge's midpoint grid point, (1, 0.5, 0), must be
    // exactly ONE vertex, used by a face belonging to each original
    // side - not two coincident vertices, one per side.
    int sharedMidpointVertex = -1;
    for (int v = 0; v < app.allVertices.length; v++) {
      if ((app.allVertices[v][0] == 1) && (app.allVertices[v][1] == 0.5f) && (app.allVertices[v][2] == 0)) {
        assertEquals(-1, sharedMidpointVertex, "the shared edge's midpoint must exist as exactly one vertex, not be duplicated");
        sharedMidpointVertex = v;
      }
    }
    assertTrue(sharedMidpointVertex >= 0, "expected to find the shared edge's midpoint vertex at all");

    // Each original face's own center grid point (face 0's at
    // (0.5,0.5,0), face 1's at (1.5,0.5,0)) is a reliable per-side
    // marker - every one of that face's own sub-pieces touching the
    // shared edge also touches its own center.
    int centerFace0Vertex = -1;
    int centerFace1Vertex = -1;
    for (int v = 0; v < app.allVertices.length; v++) {
      if ((app.allVertices[v][0] == 0.5f) && (app.allVertices[v][1] == 0.5f) && (app.allVertices[v][2] == 0)) centerFace0Vertex = v;
      if ((app.allVertices[v][0] == 1.5f) && (app.allVertices[v][1] == 0.5f) && (app.allVertices[v][2] == 0)) centerFace1Vertex = v;
    }
    assertTrue(centerFace0Vertex >= 0);
    assertTrue(centerFace1Vertex >= 0);

    boolean usedOnFace0Side = false;
    boolean usedOnFace1Side = false;
    for (int[] face : app.allFaces.nodes) {
      boolean hasSharedMidpoint = false;
      boolean hasCenterFace0 = false;
      boolean hasCenterFace1 = false;
      for (int v : face) {
        if (v == sharedMidpointVertex) hasSharedMidpoint = true;
        if (v == centerFace0Vertex) hasCenterFace0 = true;
        if (v == centerFace1Vertex) hasCenterFace1 = true;
      }
      if (hasSharedMidpoint && hasCenterFace0) usedOnFace0Side = true;
      if (hasSharedMidpoint && hasCenterFace1) usedOnFace1Side = true;
    }
    assertTrue(usedOnFace0Side, "the shared midpoint should be used by one of face 0's own tessellated pieces");
    assertTrue(usedOnFace1Side, "the shared midpoint should be used by one of face 1's own tessellated pieces");
  }

  // --- extrudeFaceEdges_Selection (a full integration test) -----------
  //
  // Unlike every other function tested above, this one is purely
  // additive: the original face is left completely untouched, and the
  // new side walls + cap are appended to the end of allFaces.nodes
  // rather than spliced in at the source face's position. It also
  // creates a brand-new group per processed group (allGroups.
  // beginNewGroup) rather than growing the existing one, and - worth
  // calling out specifically - only the CAP face's index ends up in
  // Select3D.faceSelection afterward, not the side walls.

  @Test
  void extrudeFaceEdges_appendsWallsAndACapWithoutTouchingTheOriginalFace () {
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {0, 2, 0}}; // a flat triangle, facing +Z
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.User3D.modifierOpeningDepth = 1f;

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.extrudeFaceEdges_Selection();

    assertEquals(5, app.allFaces.nodes.length); // original + 3 side walls + 1 cap
    assertEquals(9, app.allVertices.length);    // 3 original + 3 duplicated base points + 3 top points

    // The original face is untouched.
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);

    // Points are created per corner, interleaved: base[s] then top[s].
    assertArrayEquals(new float[]{0, 0, 1}, app.allVertices[4], 0.0001f); // top0 = corner0 pushed up by the +Z normal
    assertArrayEquals(new float[]{2, 0, 1}, app.allVertices[6], 0.0001f); // top1
    assertArrayEquals(new float[]{0, 2, 1}, app.allVertices[8], 0.0001f); // top2

    assertArrayEquals(new int[]{3, 5, 6, 4}, app.allFaces.nodes[1]); // side wall 0-1
    assertArrayEquals(new int[]{5, 7, 8, 6}, app.allFaces.nodes[2]); // side wall 1-2
    assertArrayEquals(new int[]{7, 3, 4, 8}, app.allFaces.nodes[3]); // side wall 2-0
    assertArrayEquals(new int[]{4, 6, 8}, app.allFaces.nodes[4]);    // the cap, from the top points

    // A brand-new group was created (not an extension of group 0),
    // spanning just the 4 new faces (indices 1-4) - the original
    // face's group membership is untouched.
    assertEquals(2, app.allGroups.num);
    assertArrayEquals(new int[]{1, 4}, app.allGroups.Faces[1]);

    // Only the cap's index ends up selected - not the 3 side walls.
    assertArrayEquals(new int[]{4}, app.Select3D.faceSelection);
  }

  // --- flattenTerrainVertices ------------------------------------------

  @Test
  void flattenTerrainVertices_zerosOutElevationOnlyAtTheSelectedGridCells () {
    app.Terrain.columnCount = 3;
    app.Terrain.Mesh = new float[2][3][3];
    for (float[][] row : app.Terrain.Mesh) {
      for (float[] cell : row) cell[2] = 99f; // give every cell a distinctive, nonzero elevation
    }

    // Flat index 1 -> row 0, col 1. Flat index 4 -> row 1, col 1.
    app.Select3D.terrainVertexSelection = new int[]{1, 4};

    app.Modify3D.flattenTerrainVertices();

    assertEquals(0f, app.Terrain.Mesh[0][1][2], 0.0001f);
    assertEquals(0f, app.Terrain.Mesh[1][1][2], 0.0001f);
    // Untouched cells keep their original elevation.
    assertEquals(99f, app.Terrain.Mesh[0][0][2], 0.0001f);
    assertEquals(99f, app.Terrain.Mesh[1][2][2], 0.0001f);
  }

  // --- autoNormalFaces_Selection: the flip-on-hit case ----------------

  @Test
  void autoNormalFaces_reversesAFaceWhoseNormalPointsIntoAnotherFace () {
    // A small triangle at z=0 whose normal (computed from the centroid
    // outward through its own first two corners) points straight up
    // (+Z), toward a large triangle sitting at z=5 directly above it.
    // Verified numerically beforehand, including that neither face's
    // ray registers a spurious hit against ITSELF (dist2intersect for a
    // ray starting exactly on its own face's plane comes out at/under
    // FLOAT_tiny, correctly rejected) and that the large triangle's own
    // ray - which points further away in +Z, not back down toward z=0 -
    // never reaches the small triangle either.
    app.allVertices = new float[][]{
      {0, 0, 0}, {1, 0, 0}, {0, 1, 0},        // face 1 (index 0 is an unused placeholder below)
      {-10, -10, 5}, {10, -10, 5}, {0, 10, 5} // face 2
    };
    app.allFaces.nodes = new int[][]{
      {0, 1, 2}, // index 0: placeholder, never selected/touched
      {0, 1, 2}, // index 1: the small triangle - should get reversed
      {3, 4, 5}  // index 2: the large triangle - should stay unchanged
    };
    app.allFaces.options = new int[][]{
      {0, 0, 0, 1, 0, 0}, {0, 0, 0, 1, 0, 0}, {0, 0, 0, 1, 0, 0}
    };

    app.Select3D.faceSelection = new int[]{1, 2};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.autoNormalFaces_Selection();

    assertArrayEquals(new int[]{2, 1, 0}, app.allFaces.nodes[1]); // fully reversed
    assertArrayEquals(new int[]{3, 4, 5}, app.allFaces.nodes[2]); // unchanged - its own ray hit nothing
  }

  // --- findOwningGroupId, spliceFaceWithNewFaces, appendNewFaceSelection ---
  //
  // These three are exercised indirectly by nearly every integration
  // test above, but hadn't been checked in isolation - direct tests
  // pin down their own specific contracts more precisely.

  @Test
  void findOwningGroupId_onlySearchesWithinGroupIdsNotEveryGroup () {
    app.allGroups.makeEmpty(3);
    app.allGroups.Faces[0] = new int[]{0, 1};
    app.allGroups.Faces[1] = new int[]{2, 3}; // deliberately excluded from groupSelection below
    app.allGroups.Faces[2] = new int[]{4, 5};

    app.Select3D.groupSelection = new int[]{0, 2}; // group 1 is not searchable, even though it exists

    assertEquals(0, app.Modify3D.findOwningGroupId(0));
    assertEquals(2, app.Modify3D.findOwningGroupId(5));
    assertEquals(-1, app.Modify3D.findOwningGroupId(3)); // owned by group 1, which isn't in groupSelection
  }

  @Test
  void spliceFaceWithNewFaces_replacesOneFaceWithSeveralInPlace () {
    app.allFaces.nodes = new int[][]{{0}, {1}, {2}};
    app.allFaces.options = new int[][]{{100}, {101}, {102}};

    ArrayList<int[]> midNodes = new ArrayList<int[]>();
    midNodes.add(new int[]{10});
    midNodes.add(new int[]{11});
    ArrayList<int[]> midOptions = new ArrayList<int[]>();
    midOptions.add(new int[]{110});
    midOptions.add(new int[]{111});

    app.Modify3D.spliceFaceWithNewFaces(1, midNodes, midOptions);

    assertEquals(4, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0}, app.allFaces.nodes[0]);   // face before the splice point, untouched
    assertArrayEquals(new int[]{10}, app.allFaces.nodes[1]);  // the two new faces...
    assertArrayEquals(new int[]{11}, app.allFaces.nodes[2]);  // ...replacing the original face 1
    assertArrayEquals(new int[]{2}, app.allFaces.nodes[3]);   // face after the splice point, untouched

    assertArrayEquals(new int[]{110}, app.allFaces.options[1]);
    assertArrayEquals(new int[]{111}, app.allFaces.options[2]);
  }

  @Test
  void appendNewFaceSelection_concatenatesOntoTheExistingSelection () {
    app.Select3D.faceSelection = new int[]{5};

    ArrayList<Integer> newIndices = new ArrayList<Integer>();
    newIndices.add(7);
    newIndices.add(8);
    app.Modify3D.appendNewFaceSelection(newIndices);

    assertArrayEquals(new int[]{5, 7, 8}, app.Select3D.faceSelection);
  }

  @Test
  void appendNewFaceSelection_isANoOpForAnEmptyList () {
    app.Select3D.faceSelection = new int[]{5};
    app.Modify3D.appendNewFaceSelection(new ArrayList<Integer>());
    assertArrayEquals(new int[]{5}, app.Select3D.faceSelection);
  }

  // --- faceNormalUnit --------------------------------------------------

  @Test
  void faceNormalUnit_ofAFlatSquare_pointsStraightUp () {
    // CCW-from-above square in the XY plane - same +Z-outward winding
    // convention as the extrude test above.
    float[][] square = {{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    float[] normal = app.Modify3D.faceNormalUnit(square);
    assertArrayEquals(new float[]{0, 0, 1}, normal, 0.0001f);
  }

  // --- thickenFaces_Selection (a full integration test) ----------------
  //
  // Driven with the exact same single-triangle scene as the extrude
  // test above, specifically to show how the two differ: this one does
  // NOT duplicate the base corners (the walls reuse the original face's
  // own vertex indices for their base edge), so the same selection
  // produces fewer new points - only the offset ("back") copy is new.

  @Test
  void thickenFaces_singleTriangle_addsOnlyTheOffsetCopyNotDuplicateBasePoints () {
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {0, 2, 0}}; // flat triangle, facing +Z
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.User3D.modifierOpeningDepth = 1f;

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.thickenFaces_Selection();

    // original (untouched) + 3 walls + 1 back face; only 3 new points
    // (the offset copy of each of the 3 original corners), not 6.
    assertEquals(5, app.allFaces.nodes.length);
    assertEquals(6, app.allVertices.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);

    // The 3 new points are each the matching original corner pushed up
    // by the +Z normal - same positions the extrude test's top points
    // land on, just not duplicated per-wall.
    float[][] expectedOffsets = {{0, 0, 1}, {2, 0, 1}, {0, 2, 1}};
    for (float[] expected : expectedOffsets) {
      boolean found = false;
      for (int v = 3; v < app.allVertices.length; v++) {
        if (dist(expected, app.allVertices[v]) < 0.0001f) found = true;
      }
      assertTrue(found, "missing offset point for " + expected[0] + "," + expected[1] + "," + expected[2]);
    }

    // The back face is added first (index 1, right after the untouched
    // original), followed by its 3 walls (indices 2-4) - a triangle
    // built entirely from the 3 new (offset) points.
    int[] backFace = app.allFaces.nodes[1];
    assertEquals(3, backFace.length);
    for (int v : backFace) assertTrue(v >= 3, "back face should only reference new offset points");

    // The 3 side walls are quads, each mixing 2 original and 2 offset points.
    for (int f = 2; f <= 4; f++) {
      assertEquals(4, app.allFaces.nodes[f].length);
    }

    // A brand-new group was created, spanning the 4 new faces.
    assertEquals(2, app.allGroups.num);
    assertArrayEquals(new int[]{1, 4}, app.allGroups.Faces[1]);

    // Every new face (back face + all 3 walls) ends up selected.
    assertArrayEquals(new int[]{1, 2, 3, 4}, app.Select3D.faceSelection);
  }

  private float dist (float[] a, float[] b) {
    float dx = a[0] - b[0], dy = a[1] - b[1], dz = a[2] - b[2];
    return (float) Math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  @Test
  void thickenFaces_twoAdjacentQuads_shareOneOffsetVertexAndSkipTheSharedWall () {
    // Two coplanar unit squares sharing the edge between vertex 1 and
    // vertex 2 (vertex indices, not just matching positions - this is
    // what lets thickenFaces_Selection recognize them as connected).
    app.allVertices = new float[][]{
      {0, 0, 0}, {1, 0, 0}, {1, 1, 0}, {0, 1, 0}, // square A's own corners (0-3)
      {2, 0, 0}, {2, 1, 0}                         // square B's own extra corners (4-5)
    };
    app.allFaces.nodes = new int[][]{
      {0, 1, 2, 3}, // square A
      {1, 4, 5, 2}  // square B - shares the 1-2 edge with square A
    };
    app.allFaces.options = new int[][]{
      {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}
    };
    app.User3D.modifierOpeningDepth = 1f;

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 1}; // one group spanning both faces

    app.Select3D.faceSelection = new int[]{0, 1};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.thickenFaces_Selection();

    // 6 unique original vertices -> exactly 6 new offset points, not 8
    // (which duplicating per-face, the way Extrude Face Edges would if
    // simply run twice, would have produced).
    assertEquals(12, app.allVertices.length);

    // 2 original faces + 2 back faces + 6 walls (3 boundary edges per
    // square; the shared 1-2 edge is excluded from both, so NOT 4+4=8).
    assertEquals(10, app.allFaces.nodes.length);
  }

  // --- capHoles_Selection (a full integration test) --------------------

  @Test
  void capHoles_capsTheOneMissingFaceOfAnOpenToppedBox () {
    // An axis-aligned unit box with all 4 side faces but no top (the
    // top face, at z=1, is the "hole"). Bottom is left off too - this
    // object has two holes, top and bottom, confirming capHoles_Selection
    // finds and fills both from a single call, not just the first one.
    app.allVertices = new float[][]{
      {0, 0, 0}, {1, 0, 0}, {1, 1, 0}, {0, 1, 0}, // bottom corners 0-3
      {0, 0, 1}, {1, 0, 1}, {1, 1, 1}, {0, 1, 1}  // top corners 4-7
    };
    app.allFaces.nodes = new int[][]{
      {0, 1, 5, 4}, // y=0 side, facing -Y outward
      {1, 2, 6, 5}, // x=1 side, facing +X outward
      {2, 3, 7, 6}, // y=1 side, facing +Y outward
      {3, 0, 4, 7}  // x=0 side, facing -X outward
    };
    app.allFaces.options = new int[][]{
      {7, 0, 0, 0, 0, 0}, {7, 0, 0, 0, 0, 0}, {7, 0, 0, 0, 0, 0}, {7, 0, 0, 0, 0, 0}
    };

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 3};

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.capHoles_Selection();

    // One new cap for the top hole, one for the bottom hole.
    assertEquals(6, app.allFaces.nodes.length);

    boolean sawTopCap = false, sawBottomCap = false;
    for (int f = 4; f < app.allFaces.nodes.length; f++) {
      int[] nodes = app.allFaces.nodes[f];
      assertEquals(4, nodes.length);

      // Every node is one of the 4 top points, or one of the 4 bottom
      // points, with none repeated - a clean, non-degenerate quad.
      java.util.HashSet<Integer> unique = new java.util.HashSet<Integer>();
      for (int v : nodes) unique.add(v);
      assertEquals(4, unique.size());

      boolean allTop = true, allBottom = true;
      for (int v : nodes) {
        if (v < 4) allTop = false;
        if (v >= 4) allBottom = false;
      }
      assertTrue(allTop || allBottom, "cap should be entirely top points or entirely bottom points");

      float[] normal = app.Modify3D.faceNormalUnit(app.Modify3D.faceBaseVertices(f));
      if (allTop) {
        sawTopCap = true;
        assertArrayEquals(new float[]{0, 0, 1}, normal, 0.0001f); // outward = up, matching the side faces' convention
        assertEquals(7, app.allFaces.getMaterial(f)); // inherited from a neighboring side face
      } else {
        sawBottomCap = true;
        assertArrayEquals(new float[]{0, 0, -1}, normal, 0.0001f); // outward = down
      }
    }
    assertTrue(sawTopCap, "should have filled the top hole");
    assertTrue(sawBottomCap, "should have filled the bottom hole");
  }

  @Test
  void capHoles_doesNothingToAnAlreadyClosedSolid () {
    // A tetrahedron: every one of its 6 edges is shared by exactly 2 of
    // its 4 faces, so there's no naked edge anywhere to fill.
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {0, 1, 0}, {0, 0, 1}};
    app.allFaces.nodes = new int[][]{
      {0, 1, 2}, {0, 1, 3}, {0, 2, 3}, {1, 2, 3}
    };
    app.allFaces.options = new int[][]{
      {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}
    };

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 3};

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.capHoles_Selection();

    assertEquals(4, app.allFaces.nodes.length); // unchanged
    assertEquals(4, app.allVertices.length);    // unchanged
  }

  @Test
  void capHoles_isANoOpWhenNothingIsSelected () {
    app.currentObjectCategory = app.ObjectCategory.SOLID; // neither GROUP nor FACE
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};

    app.Modify3D.capHoles_Selection();

    assertEquals(1, app.allFaces.nodes.length); // isGroupOrFaceCategorySelected() guard short-circuited before any work
  }

  // --- isCoplanarFace ---------------------------------------------------

  @Test
  void isCoplanarFace_trueOnlyForSameFacingPointsOnTheSamePlane () {
    app.allVertices = new float[][]{
      {0, 0, 0}, {1, 0, 0}, {0, 1, 0}, // face 0: flat at z=0, facing +Z
      {0, 0, 0}, {0, 1, 0}, {1, 0, 0}, // face 1: same plane, OPPOSITE winding (facing -Z)
      {0, 0, 5}, {1, 0, 5}, {0, 1, 5}  // face 2: parallel plane, offset to z=5
    };
    app.allFaces.nodes = new int[][]{{0, 1, 2}, {3, 4, 5}, {6, 7, 8}};

    float[] refNormal = {0, 0, 1};
    float[] refPoint = {0, 0, 0};

    assertTrue(app.Modify3D.isCoplanarFace(0, refNormal, refPoint));
    assertFalse(app.Modify3D.isCoplanarFace(1, refNormal, refPoint), "opposite-facing - not the same surface to merge");
    assertFalse(app.Modify3D.isCoplanarFace(2, refNormal, refPoint), "parallel but on a different plane");
  }

  // --- corrugateFaces_Selection (a full integration test) ------------------
  //
  // A flat 2x2 grid of quads (a 3x3 grid of vertices, facing +Z), index
  // layout v(p,q) = p*3+q for p,q in 0..2:
  //
  //   2---5---8
  //   |   |   |
  //   1---4---7
  //   |   |   |
  //   0---3---6
  //
  // face0={0,3,4,1}, face1={3,6,7,4}, face2={1,4,5,2}, face3={4,7,8,5} -
  // this is the exact "2x2 grid" case the feature's own design was
  // confirmed against. The diagonal choice comes from a checkerboard
  // 2-coloring of the mesh's own VERTICES (not of the quads - see
  // corrugateFaces_Selection()'s own comment for why coloring the quads
  // directly isn't rotation-safe once a selection nests Quad
  // Tessellate's own pinwheel output inside itself): each quad connects
  // its own A-C pair whenever A's vertex color is 0, otherwise its own
  // B-D pair. For this plain, non-rotated grid that colors the 4 true
  // corners (0, 6, 2, 8) and the shared center (4) one way and the 4
  // edge-midpoints (1, 3, 5, 7) the other, and every quad ends up
  // connecting one true-corner-or-center vertex to the OTHER
  // true-corner-or-center vertex it shares a diagonal with - which
  // means the corners and center are the diagonals' own endpoints
  // (hubs, left in place) and the 4 edge-midpoints are the untouched
  // ones that actually get bumped. Each processed quad's own UNUSED
  // diagonal still links its two untouched (edge-midpoint) corners -
  // (1,3) from face0, (3,7) from face1, (1,5) from face2, (5,7) from
  // face3 - a 4-cycle whose own 2-coloring puts 1 and 7 in one half and
  // 3 and 5 in the other, so those two pairs bump in opposite
  // directions from each other.
  @Test
  void corrugate_2x2FlatGrid_bumpsCornersAndCenter_leavesEdgeMidpointsAsHubsInPlace () {
    app.allVertices = new float[][]{
      {0, 0, 0}, {0, 1, 0}, {0, 2, 0},
      {1, 0, 0}, {1, 1, 0}, {1, 2, 0},
      {2, 0, 0}, {2, 1, 0}, {2, 2, 0}
    };
    app.allFaces.nodes = new int[][]{{0, 3, 4, 1}, {3, 6, 7, 4}, {1, 4, 5, 2}, {4, 7, 8, 5}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}};
    app.User3D.modifierCorrugateBumpAmount = 0.25f;

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 3};

    app.Select3D.faceSelection = new int[]{0, 1, 2, 3};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.corrugateFaces_Selection();

    // 4 quads -> 8 triangles, no new vertices (every bump moves an
    // EXISTING point, it never creates one).
    assertEquals(8, app.allFaces.nodes.length);
    assertEquals(9, app.allVertices.length);

    // Each original quad is replaced in place (spliceFaceWithNewFaces()
    // keeps the first new face at the replaced face's own old index),
    // so face0's pair lands at [0,1], face1's at [2,3], face2's at
    // [4,5], face3's at [6,7] - each one shifted up by however many
    // OTHER, smaller-original-id quads were also replaced ahead of it.
    assertArrayEquals(new int[]{0, 3, 4}, app.allFaces.nodes[0]);
    assertArrayEquals(new int[]{4, 1, 0}, app.allFaces.nodes[1]);
    assertArrayEquals(new int[]{6, 7, 4}, app.allFaces.nodes[2]);
    assertArrayEquals(new int[]{4, 3, 6}, app.allFaces.nodes[3]);
    assertArrayEquals(new int[]{4, 5, 2}, app.allFaces.nodes[4]);
    assertArrayEquals(new int[]{2, 1, 4}, app.allFaces.nodes[5]);
    assertArrayEquals(new int[]{4, 7, 8}, app.allFaces.nodes[6]);
    assertArrayEquals(new int[]{8, 5, 4}, app.allFaces.nodes[7]);

    // The one group's own face range grew by 4 (one net extra face per
    // replaced quad).
    assertArrayEquals(new int[]{0, 7}, app.allGroups.Faces[0]);

    // Every new triangle ends up selected.
    assertArrayEquals(new int[]{0, 1, 2, 3, 4, 5, 6, 7}, app.Select3D.faceSelection);

    // The 4 true corners and the shared center vertex each end up an
    // endpoint of some chosen diagonal (a "hub" - see this test's own
    // header comment above) and so are left exactly where they started.
    for (int v : new int[]{0, 2, 6, 8, 4}) {
      assertEquals(0f, app.allVertices[v][2], 0.0001f, "vertex " + v + " should NOT have been bumped");
    }

    // The 4 edge-midpoints never end up a diagonal's endpoint, so all 4
    // get bumped along their averaged (flat, +Z) normal - but the
    // 4-cycle's own 2-coloring (see header comment) puts 1 and 7 in the
    // opposite half from 3 and 5, so those two pairs bump oppositely.
    for (int v : new int[]{1, 7}) {
      assertEquals(0.25f, app.allVertices[v][2], 0.0001f, "edge-midpoint " + v + " should have been bumped +0.25");
    }
    for (int v : new int[]{3, 5}) {
      assertEquals(-0.25f, app.allVertices[v][2], 0.0001f, "edge-midpoint " + v + " should have been bumped the OTHER way, -0.25");
    }

    // The X/Y of every vertex is untouched either way - only Z (the
    // flat grid's own normal direction) ever moves.
    float[][] expectedXY = {{0, 0}, {0, 1}, {0, 2}, {1, 0}, {1, 1}, {1, 2}, {2, 0}, {2, 1}, {2, 2}};
    for (int v = 0; v < 9; v++) {
      assertEquals(expectedXY[v][0], app.allVertices[v][0], 0.0001f);
      assertEquals(expectedXY[v][1], app.allVertices[v][1], 0.0001f);
    }
  }

  @Test
  void corrugate_negativeBumpAmount_movesTheUntouchedVertexTheOtherWay () {
    // A single flat quad, facing +Z - a lone quad is its own,
    // single-cell "cluster," so its own vertex-coloring BFS always
    // starts on one of its 4 corners (see corrugateFaces_Selection()'s own
    // comment on why the checkerboard is colored on vertices, not
    // quads) - for this exact vertex order that colors A and C one way
    // and B and D the other, and the quad connects its own A-C pair
    // whenever A's own color is 0, which it is here - leaving corners B
    // and D untouched.
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {1, 1, 0}, {0, 1, 0}}; // A, B, C, D
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.User3D.modifierCorrugateBumpAmount = -0.4f;

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.corrugateFaces_Selection();

    assertEquals(2, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]); // A,B,C - the A-C diagonal
    assertArrayEquals(new int[]{2, 3, 0}, app.allFaces.nodes[1]); // C,D,A

    // B (vertex 1) and D (vertex 3) are untouched by the A-C diagonal,
    // so they're the ones bumped - but they're also each other's only
    // "other diagonal" partner (the unused B-D diagonal links exactly
    // them), so they land in opposite halves and get opposite signs:
    // B gets the plain (negative) bump amount, D gets it inverted.
    assertEquals(-0.4f, app.allVertices[1][2], 0.0001f);
    assertEquals(0.4f, app.allVertices[3][2], 0.0001f);

    // A (0) and C (2), the diagonal's own endpoints, are left in place.
    assertEquals(0f, app.allVertices[0][2], 0.0001f);
    assertEquals(0f, app.allVertices[2][2], 0.0001f);
  }

  @Test
  void corrugate_bumpScalesWithLocalQuadSize_notAFlatWorldUnitOffset () {
    // The exact same single flat quad as the negative-bump test above,
    // just scaled down to a tiny 0.01-unit square - a fixed, flat
    // world-unit bump (the ORIGINAL behavior) would have displaced
    // vertices by a whole 25x the quad's own size, folding/overlapping
    // the surface into what reads as disconnected pieces rather than a
    // gentle corrugate relief. The move must come out proportional to the
    // quad's own edge length instead.
    float s = 0.01f;
    app.allVertices = new float[][]{{0, 0, 0}, {s, 0, 0}, {s, s, 0}, {0, s, 0}}; // A, B, C, D
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.User3D.modifierCorrugateBumpAmount = 0.25f;

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.corrugateFaces_Selection();

    // B and D (the untouched corners, with this same vertex-coloring -
    // see the negative-bump test above) move by 0.25 * (this quad's
    // own edge length, s) - not by a flat 0.25 world units.
    assertEquals(0.25f * s, app.allVertices[1][2], 0.0001f * s);
    assertEquals(-0.25f * s, app.allVertices[3][2], 0.0001f * s);
  }

  @Test
  void corrugate_nonQuadFaceInSelection_isLeftCompletelyUntouched () {
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {0, 1, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}}; // a triangle, not a quad
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.User3D.modifierCorrugateBumpAmount = 0.25f;

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.corrugateFaces_Selection();

    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
    for (float[] p : app.allVertices) assertEquals(0f, p[2], 0.0001f, "a triangle isn't a quad - corrugate must leave it alone");
  }

  @Test
  void corrugate_unweldedGrid_movesEveryDuplicateOfASharedCornerTogether () {
    // The same flat 2x2 grid as corrugate_2x2FlatGrid_... above, but built
    // the way every shape generator in this app actually builds one
    // (add_ParametricSurface, for one): each of the 4 quads gets its
    // OWN private 4 vertices via its own allPoints.create() calls, so
    // two quads that are geometric neighbors never actually share a
    // raw vertex index, even though their matching corners sit at the
    // exact same position. This is the real "completely fragmented on
    // a Hyperboloid of Revolution" bug - a position-unaware version of
    // this modifier bumps only ONE of a shared corner's several raw
    // copies, leaving its neighbors' copies behind and tearing the
    // surface open at every quad boundary. Grid layout and expected
    // phase/inversion choice are identical to the welded test above;
    // only the vertex-sharing differs.
    app.allVertices = new float[][]{
      {0, 0, 0}, {1, 0, 0}, {1, 1, 0}, {0, 1, 0}, // Q0: A,B,C,D = v0..v3
      {1, 0, 0}, {2, 0, 0}, {2, 1, 0}, {1, 1, 0}, // Q1: A,B,C,D = v4..v7
      {0, 1, 0}, {1, 1, 0}, {1, 2, 0}, {0, 2, 0}, // Q2: A,B,C,D = v8..v11
      {1, 1, 0}, {2, 1, 0}, {2, 2, 0}, {1, 2, 0}, // Q3: A,B,C,D = v12..v15
    };
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}, {4, 5, 6, 7}, {8, 9, 10, 11}, {12, 13, 14, 15}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}};
    app.User3D.modifierCorrugateBumpAmount = 0.25f;

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 3};

    app.Select3D.faceSelection = new int[]{0, 1, 2, 3};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.corrugateFaces_Selection();

    assertEquals(8, app.allFaces.nodes.length, "4 quads, each split into 2 triangles");

    // The 4 outer corners - each a "true corner" owned by only one
    // quad - end up a diagonal's own endpoint (a "hub", see the welded
    // test's own header comment for why this grid's vertex-coloring
    // puts the true corners and the center on the "hub" side and the
    // edge-midpoints on the "bumped" side), so each is left at z=0.
    assertEquals(0f, app.allVertices[0][2], 0.0001f, "Q0's own copy of corner (0,0)");
    assertEquals(0f, app.allVertices[5][2], 0.0001f, "Q1's own copy of corner (2,0)");
    assertEquals(0f, app.allVertices[11][2], 0.0001f, "Q2's own copy of corner (0,2)");
    assertEquals(0f, app.allVertices[14][2], 0.0001f, "Q3's own copy of corner (2,2)");

    // The shared center position (1,1) is duplicated 4 times - once
    // per quad (v2, v7, v9, v12) - and is also a hub, left at z=0. This
    // is still the actual regression check: every one of its 4 raw
    // copies must move IDENTICALLY (here, not at all), or the 4 quads
    // pull apart at that corner instead of staying welded in
    // appearance.
    float[] centerCopies = { app.allVertices[2][2], app.allVertices[7][2], app.allVertices[9][2], app.allVertices[12][2] };
    for (float z : centerCopies) assertEquals(0f, z, 0.0001f, "every one of the center position's 4 unwelded copies must move identically");

    // The 4 edge-midpoint positions - each shared by exactly 2 quads -
    // are the ones actually bumped here (unit grid, so the
    // local-edge-length scale factor is exactly 1), and that holds
    // identically for BOTH of each one's duplicate copies. The
    // 4-midpoint cycle's own 2-coloring (see the welded test's header
    // comment) puts (1,0)&(1,2) in one half and (0,1)&(2,1) in the
    // other, so those two pairs bump oppositely.
    float[] pos10 = { app.allVertices[1][2], app.allVertices[4][2] }; // position (1,0): Q0's B, Q1's A
    float[] pos01 = { app.allVertices[3][2], app.allVertices[8][2] }; // position (0,1): Q0's D, Q2's A
    float[] pos21 = { app.allVertices[6][2], app.allVertices[13][2] }; // position (2,1): Q1's C, Q3's B
    float[] pos12 = { app.allVertices[10][2], app.allVertices[15][2] }; // position (1,2): Q2's C, Q3's D
    for (float z : pos10) assertEquals(0.25f, z, 0.0001f, "both unwelded copies of position (1,0) must move identically");
    for (float z : pos12) assertEquals(0.25f, z, 0.0001f, "both unwelded copies of position (1,2) must move identically");
    for (float z : pos01) assertEquals(-0.25f, z, 0.0001f, "both unwelded copies of position (0,1) must move identically, the other way");
    for (float z : pos21) assertEquals(-0.25f, z, 0.0001f, "both unwelded copies of position (2,1) must move identically, the other way");
  }

  @Test
  void corrugate_tessellatedPlanePinwheel_alternatesTheDiagonalAroundTheSharedCenter () {
    // The exact real-world repro that exposed the "no real alternation"
    // bug: add a plane (one quad) and apply Quad Tessellate once -
    // tessellateRectangular_Selection() replaces it with 4 welded
    // sub-quads fanned around one shared center, one per original
    // corner:
    //
    //   D--7--C
    //   |  |  |
    //   0--3--5
    //   |  |  |
    //   A--2--B
    //
    // face0 (near A) = {0,1,2,3}, face1 (near B) = {2,4,5,3},
    // face2 (near C) = {5,6,7,3}, face3 (near D) = {7,8,0,3} - a
    // 4-cycle (each face shares an edge with exactly 2 others, all
    // through the center, vertex 3). Each sector's own stored corner
    // order is rotated relative to its neighbors' (sector-near-A's own
    // "A" sits at its own sector's edge-midpoint-of-D-A; sector-near-B's
    // own "A" sits at ITS sector's edge-midpoint-of-A-B, one quarter-
    // turn further around), which is exactly why a rule that compares
    // one quad's own A/B/C/D labels against its NEIGHBOR's (whether by
    // a 2-way vote over "true corners left untouched" or by a fixed
    // quad-level BFS color) can end up choosing the SAME geometric
    // diagonal for every quad here instead of alternating. Coloring the
    // mesh's own VERTICES instead - and picking each quad's own A-C vs
    // B-D purely from its own A's resulting color (see
    // corrugateFaces_Selection()'s own comment) - never compares one
    // quad's labels against another's, so this rotation can't throw it
    // off: every one of this pinwheel's 4 edge-midpoints (0, 2, 5, 7)
    // ends up one color, and the center (3) and all 4 real corners (1,
    // 4, 6, 8) end up the other, regardless of each quad's own
    // rotation.
    app.allVertices = new float[][]{
      {0, 0.5f, 0}, // 0: midpoint of D-A
      {0, 0, 0},    // 1: A
      {0.5f, 0, 0}, // 2: midpoint of A-B
      {0.5f, 0.5f, 0}, // 3: center
      {1, 0, 0},    // 4: B
      {1, 0.5f, 0}, // 5: midpoint of B-C
      {1, 1, 0},    // 6: C
      {0.5f, 1, 0}, // 7: midpoint of C-D
      {0, 1, 0},    // 8: D
    };
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}, {2, 4, 5, 3}, {5, 6, 7, 3}, {7, 8, 0, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}};
    app.User3D.modifierCorrugateBumpAmount = 0.25f;

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 3};

    app.Select3D.faceSelection = new int[]{0, 1, 2, 3};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.corrugateFaces_Selection();

    assertEquals(8, app.allFaces.nodes.length, "4 quads, each split into 2 triangles");

    // Every face's own "A" corner lands on the edge-midpoint color, so
    // every face connects its own A-C pair: ABC then CDA, each time.
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
    assertArrayEquals(new int[]{2, 3, 0}, app.allFaces.nodes[1]);
    assertArrayEquals(new int[]{2, 4, 5}, app.allFaces.nodes[2]);
    assertArrayEquals(new int[]{5, 3, 2}, app.allFaces.nodes[3]);
    assertArrayEquals(new int[]{5, 6, 7}, app.allFaces.nodes[4]);
    assertArrayEquals(new int[]{7, 3, 5}, app.allFaces.nodes[5]);
    assertArrayEquals(new int[]{7, 8, 0}, app.allFaces.nodes[6]);
    assertArrayEquals(new int[]{0, 3, 7}, app.allFaces.nodes[7]);

    // Every face's own A-C pair is a pair of edge-midpoints, so the 4
    // edge-midpoints (0, 2, 5, 7) are the diagonals' own endpoints -
    // hubs, left exactly in place.
    for (int v : new int[]{0, 2, 5, 7}) {
      assertEquals(0f, app.allVertices[v][2], 0.0001f, "edge-midpoint " + v + " is a hub, left in place");
    }

    // Every face's own UNTOUCHED B-D pair is the center plus one real
    // corner, so the center (3) and all 4 real corners (1, 4, 6, 8) are
    // the ones actually bumped - each by 0.25 * 0.5 (this pinwheel's
    // own local edge length, half the original plane's own unit size,
    // since Quad Tessellate halves it). Each quad's own unused B-D
    // diagonal links the center to exactly one real corner (never two
    // real corners to each other), so the center ends up alone in one
    // half of that graph's own 2-coloring and all 4 real corners
    // together in the other, bumping oppositely.
    assertEquals(-0.125f, app.allVertices[3][2], 0.0001f, "the shared center is bumped");
    for (int v : new int[]{1, 4, 6, 8}) {
      assertEquals(0.125f, app.allVertices[v][2], 0.0001f, "real corner " + v + " is bumped the other way from the center");
    }
  }

  @Test
  void corrugate_nestedQuadTessellateTwice_stillFormsAGenuineCheckerboard () {
    // The exact real-world repro reported against this feature: start
    // with one plane, apply Quad Tessellate (replacing it with a
    // 4-quad pinwheel), then apply Quad Tessellate AGAIN to all 4 of
    // those sub-quads (nesting a further pinwheel inside each sector) -
    // the actual workflow confirmed when this was reported as "all the
    // diagonals are in one direction" rather than the expected 45-
    // degree checkerboard. Each of the resulting 16 sub-quads is a
    // true axis-aligned unit square (Quad Tessellate's own pinwheel
    // sectors are always axis-aligned squares when the parent is one -
    // see corrugateFaces_Selection()'s own comment on why that still
    // doesn't make every sector's own stored corner order line up with
    // its neighbors'), tiling a clean 4x4 grid over the original 4x4
    // plane - so this checks the diagonal choice is a genuine
    // checkerboard (alternating in BOTH grid directions, diagonal
    // neighbors sharing the same choice) across that full 4x4 grid,
    // not just within a single pinwheel's own 4 sectors.
    app.allVertices = new float[][]{{0, 0, 0}, {4, 0, 0}, {4, 4, 0}, {0, 4, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};
    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.tessellateRectangular_Selection();
    app.Select3D.faceSelection = new int[]{0, 1, 2, 3};
    app.Modify3D.tessellateRectangular_Selection();

    app.User3D.modifierCorrugateBumpAmount = 0.25f;
    app.Modify3D.corrugateFaces_Selection();

    assertEquals(32, app.allFaces.nodes.length, "16 unit-square sub-quads, each split into 2 triangles");

    // "/" means this unit cell's own diagonal connects its bottom-left
    // corner to its top-right (so its own (col+row) parity determines
    // which of the two diagonal types it should be, for a genuine
    // checkerboard); "\" means bottom-right to top-left.
    boolean[][] isSlashByColRow = new boolean[4][4]; // [col][row]
    boolean[][] seen = new boolean[4][4];

    for (int i = 0; i < app.allFaces.nodes.length; i += 2) {
      int[] t1 = app.allFaces.nodes[i];
      int[] t2 = app.allFaces.nodes[i + 1];

      // this unit cell's own 4 corners/bounds, from every vertex across
      // both of its triangles.
      float minX = Float.MAX_VALUE, maxX = -Float.MAX_VALUE, minY = Float.MAX_VALUE, maxY = -Float.MAX_VALUE;
      for (int[] tri : new int[][]{t1, t2}) {
        for (int idx : tri) {
          float[] p = app.allVertices[idx];
          minX = Math.min(minX, p[0]); maxX = Math.max(maxX, p[0]);
          minY = Math.min(minY, p[1]); maxY = Math.max(maxY, p[1]);
        }
      }
      int col = Math.round((minX + maxX) / 2 - 0.5f);
      int row = Math.round((minY + maxY) / 2 - 0.5f);

      // the chosen diagonal is whichever 2 vertices t1 and t2 share.
      ArrayList<Integer> shared = new ArrayList<Integer>();
      for (int a : t1) for (int b : t2) if (a == b) shared.add(a);
      assertEquals(2, shared.size(), "the two triangles from one split quad must share exactly one edge (the diagonal)");
      float[] d0 = app.allVertices[shared.get(0)];
      float[] d1 = app.allVertices[shared.get(1)];

      // "/" (bottom-left to top-right) iff the diagonal's two endpoints
      // don't have matching min/max X with matching min/max Y - i.e.
      // one endpoint is at (minX,minY) and the other at (maxX,maxY).
      boolean isSlash = (d0[0] < d1[0]) == (d0[1] < d1[1]);

      isSlashByColRow[col][row] = isSlash;
      seen[col][row] = true;
    }

    for (int col = 0; col < 4; col++) {
      for (int row = 0; row < 4; row++) {
        assertTrue(seen[col][row], "every one of the 16 unit cells (col=" + col + ",row=" + row + ") should have been found");
        boolean expectedSlash = ((col + row) % 2 == 0);
        assertEquals(expectedSlash, isSlashByColRow[col][row],
          "cell (col=" + col + ",row=" + row + ") should use the '" + (expectedSlash ? "/" : "\\") + "' diagonal to form a genuine checkerboard");
      }
    }
  }

  // --- mergeCoplanarFaces_Selection (a full integration test) -----------

  @Test
  void mergeCoplanar_recombinesTwoTrianglesSplitFromAQuadBackIntoOneFace () {
    // The same 2x2 square used by the tessellate tests above, but
    // already split along its 0-2 diagonal into 2 triangles - exactly
    // what tessellateTriangular_Selection (or an import) might leave
    // behind, and exactly what this operation should undo.
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{
      {0, 1, 2}, // triangle A
      {0, 2, 3}  // triangle B - shares the 0-2 diagonal with A
    };
    app.allFaces.options = new int[][]{
      {3, 0, 0, 0, 0, 0}, {3, 0, 0, 0, 0, 0} // same material on both, so the merged face's own material is unambiguous either way
    };

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 1};

    app.Select3D.faceSelection = new int[]{0, 1};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.mergeCoplanarFaces_Selection();

    // The 2 triangles become 1 face - no new vertices, since the merge
    // only ever reuses the existing boundary's own vertices.
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(4, app.allVertices.length);
    assertArrayEquals(new int[]{0, 0}, app.allGroups.Faces[0]);
    assertArrayEquals(new int[]{3, 0, 0, 0, 0, 0}, app.allFaces.options[0]);

    // The walk can start at any of the 4 boundary vertices depending on
    // HashMap iteration order, so the result is only guaranteed to be
    // SOME cyclic rotation of the original quad {0,1,2,3} - check this
    // via its edge set and winding (outward normal) instead of a single
    // fixed vertex order.
    int[] merged = app.allFaces.nodes[0];
    assertEquals(4, merged.length);
    java.util.HashSet<String> edges = new java.util.HashSet<String>();
    for (int s = 0; s < merged.length; s++) {
      int a = merged[s], b = merged[(s + 1) % merged.length];
      edges.add(Math.min(a, b) + "_" + Math.max(a, b));
    }
    assertEquals(new java.util.HashSet<String>(java.util.Arrays.asList("0_1", "1_2", "2_3", "0_3")), edges);

    float[] normal = app.Modify3D.faceNormalUnit(app.Modify3D.faceBaseVertices(0));
    assertArrayEquals(new float[]{0, 0, 1}, normal, 0.0001f); // same outward winding as the 2 originals, not reversed

    assertArrayEquals(new int[]{0}, app.Select3D.faceSelection);
  }

  @Test
  void mergeCoplanar_leavesATiltedNeighborAloneAndKeepsItSelected () {
    // Face 0 is flat at z=0. Face 1 shares face 0's 1-2 edge but tilts
    // upward (like a shed roof meeting a flat base) - edge-connected,
    // but not coplanar, so nothing should merge.
    app.allVertices = new float[][]{
      {0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}, // face 0's own corners
      {2, 4, 3}, {0, 4, 3}                         // face 1's own extra corners, well above the z=0 plane
    };
    app.allFaces.nodes = new int[][]{
      {0, 1, 2, 3}, // flat base
      {1, 4, 5, 2}  // tilted - shares the 1-2 edge, but not coplanar with face 0
    };
    app.allFaces.options = new int[][]{
      {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}
    };

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 1};

    app.Select3D.faceSelection = new int[]{0, 1};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.mergeCoplanarFaces_Selection();

    // Nothing merged - both faces, and the vertex count, are unchanged.
    assertEquals(2, app.allFaces.nodes.length);
    assertEquals(6, app.allVertices.length);
    assertArrayEquals(new int[]{0, 1, 2, 3}, app.allFaces.nodes[0]);
    assertArrayEquals(new int[]{1, 4, 5, 2}, app.allFaces.nodes[1]);

    // Both faces stay selected, exactly as the user had them.
    assertArrayEquals(new int[]{0, 1}, app.Select3D.faceSelection);
  }

  @Test
  void mergeCoplanar_mergesOnlyTheCoplanarPairAndKeepsAnUnrelatedSelectedFaceSelected () {
    // 2 coplanar triangles (A, B - same diagonal split as the first test
    // above) plus a 3rd, entirely separate flat face (C) elsewhere in
    // the same object, also selected but not touching A or B at all.
    app.allVertices = new float[][]{
      {0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}, // A, B's corners
      {10, 10, 0}, {11, 10, 0}, {10, 11, 0}        // C's own corners, unconnected
    };
    app.allFaces.nodes = new int[][]{
      {0, 1, 2}, // A
      {0, 2, 3}, // B
      {4, 5, 6}  // C - disconnected from A/B, should be left alone
    };
    app.allFaces.options = new int[][]{
      {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}
    };

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 2};

    app.Select3D.faceSelection = new int[]{0, 1, 2};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.mergeCoplanarFaces_Selection();

    // A+B merge into 1 new face; C survives untouched. 3 faces -> 2.
    assertEquals(2, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1}, app.allGroups.Faces[0]);

    // C (originally index 2) shifts down to index 0, since both faces
    // deleted ahead of it (A=0, B=1) were smaller indices; the new
    // merged face lands at index 1 (appended at index 3, minus the 2
    // deletions, both of which are smaller indices).
    assertArrayEquals(new int[]{4, 5, 6}, app.allFaces.nodes[0]);
    assertEquals(4, app.allFaces.nodes[1].length);

    assertArrayEquals(new int[]{0, 1}, app.Select3D.faceSelection);
  }

  @Test
  void mergeCoplanar_isANoOpWhenNothingIsSelected () {
    app.currentObjectCategory = app.ObjectCategory.SOLID; // neither GROUP nor FACE
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};

    app.Modify3D.mergeCoplanarFaces_Selection();

    assertEquals(1, app.allFaces.nodes.length);
  }

  // --- lineIntersection3D ------------------------------------------------

  @Test
  void lineIntersection3D_findsTheCrossingOfTwoNonParallelCoplanarLines () {
    // Line 1: through (0.5, 3, 0), running in -Y. Line 2: through
    // (0, 0.5, 0), running in +X. They cross at (0.5, 0.5, 0).
    float[] result = app.Modify3D.lineIntersection3D(
      new float[]{0.5f, 3, 0}, new float[]{0, -1, 0},
      new float[]{0, 0.5f, 0}, new float[]{1, 0, 0}
    );
    assertArrayEquals(new float[]{0.5f, 0.5f, 0}, result, 0.0001f);
  }

  @Test
  void lineIntersection3D_returnsNullForParallelLines () {
    float[] result = app.Modify3D.lineIntersection3D(
      new float[]{0, 0, 0}, new float[]{1, 0, 0},
      new float[]{0, 1, 0}, new float[]{1, 0, 0}
    );
    assertNull(result);
  }

  // --- insetFaces_Selection (a full integration test) --------------------

  @Test
  void insetFaces_squareInsetByAPlainDistance_shrinksSymmetricallyAndRingsTheEdges () {
    // Same 2x2 square used by insertCornerOpenings' own test - a
    // distance inset of 0.5 happens to land on the exact same inner
    // corners that tool's area-ratio shrink (sqrt(0.25) = 0.5) does for
    // this particular symmetric square, which is a handy independent
    // cross-check of the new math.
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.User3D.modifierInsetDepth = 0.5f;

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.insetFaces_Selection();

    assertEquals(5, app.allFaces.nodes.length); // the inset base face + 4 new ring quads
    assertEquals(8, app.allVertices.length);    // 4 original + 4 new inset corners

    assertArrayEquals(new float[]{0.5f, 0.5f, 0}, app.allVertices[4], 0.0001f);
    assertArrayEquals(new float[]{1.5f, 0.5f, 0}, app.allVertices[5], 0.0001f);
    assertArrayEquals(new float[]{1.5f, 1.5f, 0}, app.allVertices[6], 0.0001f);
    assertArrayEquals(new float[]{0.5f, 1.5f, 0}, app.allVertices[7], 0.0001f);

    assertArrayEquals(new int[]{4, 5, 6, 7}, app.allFaces.nodes[0]); // the inset base face

    // One clean quad per original edge - not Insert Parallel Openings'
    // own 2-quads-per-edge bevel ring - each pairing that edge's 2
    // ORIGINAL corners with the matching 2 new inset corners.
    assertArrayEquals(new int[]{0, 1, 5, 4}, app.allFaces.nodes[1]);
    assertArrayEquals(new int[]{1, 2, 6, 5}, app.allFaces.nodes[2]);
    assertArrayEquals(new int[]{2, 3, 7, 6}, app.allFaces.nodes[3]);
    assertArrayEquals(new int[]{3, 0, 4, 7}, app.allFaces.nodes[4]);

    assertArrayEquals(new int[]{0, 4}, app.allGroups.Faces[0]);
    assertArrayEquals(new int[]{0}, app.Select3D.faceSelection); // left untouched, same as the Insert ...Openings family
  }

  @Test
  void insetFaces_rightTriangle_preservesEachEdgesOwnDirection () {
    // A 3-4-5 right triangle - unlike the square above, its 3 edges
    // aren't symmetric, so this exercises the general line-intersection
    // path (not just the lucky square case). Figures hand-derived: a
    // uniform inward offset keeps every edge's direction unchanged, just
    // moved inward, which is exactly what's checked below.
    app.allVertices = new float[][]{{0, 0, 0}, {4, 0, 0}, {0, 3, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.User3D.modifierInsetDepth = 0.5f;

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.insetFaces_Selection();

    assertEquals(4, app.allFaces.nodes.length); // the inset base face + 3 new ring quads
    assertEquals(6, app.allVertices.length);    // 3 original + 3 new inset corners

    assertArrayEquals(new float[]{0.5f, 0.5f, 0}, app.allVertices[3], 0.0001f);
    assertArrayEquals(new float[]{2.5f, 0.5f, 0}, app.allVertices[4], 0.0001f);
    assertArrayEquals(new float[]{0.5f, 2.0f, 0}, app.allVertices[5], 0.0001f);
  }

  // insetFaces_Selection() itself always calls this with insetStep=0 -
  // this is the piece it never exercises: a nonzero insetStep, shared
  // with (and actually used by) passiveSolarInsetFaces_Selection()
  // below. Called directly here since neither this helper nor
  // passiveSolarInsetFaces_Selection()'s own geometry depends on
  // calculate_VertexSolar_array() - only that function's SOLAR DECISION
  // half does (see faceSolarAverage()'s own tests, and the no-op-guard-
  // only tests further down, for why the full function can't be).
  @Test
  void insetAndRecedeFace_nonzeroStep_shrinksInPlaneThenRecedesTheInnerFaceAlongTheNegatedNormal () {
    // Same square as insetFaces_squareInsetByAPlainDistance_... above.
    // Its vertices wind counter-clockwise when viewed from +Z, so
    // faceNormalUnit() gives it an outward normal of (0,0,1) - receding
    // means the new inner face's Z becomes negative.
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    app.Modify3D.insetAndRecedeFace(0, 0, 0.5f, 0.3f);

    assertEquals(5, app.allFaces.nodes.length); // the receded inner face + 4 new ring quads
    assertEquals(8, app.allVertices.length);    // 4 original + 4 new inner corners

    // Same in-plane (X, Y) positions as the insetDepth=0.5, step=0 case
    // above, but every one of the 4 new inner corners is now ALSO
    // pushed to Z = -0.3, opposite the +Z outward normal.
    assertArrayEquals(new float[]{0.5f, 0.5f, -0.3f}, app.allVertices[4], 0.0001f);
    assertArrayEquals(new float[]{1.5f, 0.5f, -0.3f}, app.allVertices[5], 0.0001f);
    assertArrayEquals(new float[]{1.5f, 1.5f, -0.3f}, app.allVertices[6], 0.0001f);
    assertArrayEquals(new float[]{0.5f, 1.5f, -0.3f}, app.allVertices[7], 0.0001f);

    assertArrayEquals(new int[]{4, 5, 6, 7}, app.allFaces.nodes[0]); // the receded inner face

    // The ring quads still connect each ORIGINAL (Z=0) edge to the
    // matching new (Z=-0.3) inner edge - genuinely slanted "reveal"
    // walls now, not flat ring quads.
    assertArrayEquals(new int[]{0, 1, 5, 4}, app.allFaces.nodes[1]);
    assertArrayEquals(new int[]{1, 2, 6, 5}, app.allFaces.nodes[2]);
    assertArrayEquals(new int[]{2, 3, 7, 6}, app.allFaces.nodes[3]);
    assertArrayEquals(new int[]{3, 0, 4, 7}, app.allFaces.nodes[4]);

    assertArrayEquals(new int[]{0, 4}, app.allGroups.Faces[0]);
  }

  // The receded inner face keeps the EXACT same corner order as the
  // original face, so its own winding - and so its normal - must stay
  // identical, not flip, just because it's been pushed inward. The 4
  // ring/reveal walls, which DO tilt once insetStep is nonzero, must
  // still face consistently "up and toward the recess's own center
  // axis" - the same way the inside of a bowl or crater faces (concave,
  // normals converging toward the opening) - not flipped to face down
  // into the solid they themselves bound.
  @Test
  void insetAndRecedeFace_nonzeroStep_keepsTheInnerFacesNormalUnchanged_andTheRingWallsTiltTowardTheRecessWithoutFlipping () {
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    float[] originalNormal = app.Modify3D.faceNormalUnit(app.Modify3D.faceBaseVertices(0));
    assertArrayEquals(new float[]{0, 0, 1}, originalNormal, 0.0001f);

    app.Modify3D.insetAndRecedeFace(0, 0, 0.5f, 0.3f);

    // Face 0 is the receded inner face - same winding as the original,
    // so the exact same normal.
    assertArrayEquals(originalNormal, app.Modify3D.faceNormalUnit(app.Modify3D.faceBaseVertices(0)), 0.0001f);

    // Faces 1-4 are the 4 ring walls. None of them has flipped to face
    // away from the recess (which a sign error in the push direction
    // would produce, pointing the walls down into the solid instead):
    // each one's normal still has a strictly positive dot product with
    // the original face's own normal - still facing generally the same
    // way, just tilted - and its own in-plane (X, Y) component points
    // toward the recess's center axis, not away from it.
    float[][] expectedInwardXY = { {0, 1}, {-1, 0}, {0, -1}, {1, 0} }; // south, east, north, west walls
    for (int f = 1; f <= 4; f++) {
      float[] n = app.Modify3D.faceNormalUnit(app.Modify3D.faceBaseVertices(f));
      float dot = n[0] * originalNormal[0] + n[1] * originalNormal[1] + n[2] * originalNormal[2];
      assertTrue(dot > 0, "ring wall " + f + "'s normal " + java.util.Arrays.toString(n) + " must not flip away from the original face's own normal direction");

      float[] expected = expectedInwardXY[f - 1];
      assertTrue(n[0] * expected[0] + n[1] * expected[1] > 0,
        "ring wall " + f + "'s normal " + java.util.Arrays.toString(n) + " must tilt toward the recess's own center axis, not away from it");
    }
  }

  @Test
  void insetFaces_isANoOpWhenNothingIsSelected () {
    app.currentObjectCategory = app.ObjectCategory.SOLID; // neither GROUP nor FACE
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};

    app.Modify3D.insetFaces_Selection();

    assertEquals(1, app.allFaces.nodes.length);
  }

  // --- accumulateRelaxFromRing (given a hand-built ring face) ---------

  @Test
  void accumulateRelaxFromRing_triangle_sumsTheOtherTwoVertexPositions () {
    // vNo=0's one ring is the whole triangle, so its two ring-neighbors
    // are simply vertices 1 and 2 - this just confirms their positions
    // get summed, once each, with count=2.
    app.allVertices = new float[][]{{0, 0, 0}, {10, 0, 0}, {0, 10, 0}};
    int[][] ringNodes = {{0, 1, 2}};

    float[][] relaxSum = new float[1][3];
    int[] relaxNum = new int[1];

    app.Modify3D.accumulateRelaxFromRing(ringNodes, 0, 0, relaxSum, relaxNum);

    assertArrayEquals(new float[]{10, 10, 0}, relaxSum[0], 0.0001f);
    assertEquals(2, relaxNum[0]);
  }

  @Test
  void accumulateRelaxFromRing_twoPointEdge_countsItsOneRealNeighborOnlyOnce () {
    // A degenerate 2-vertex ring: "next" and "prev" of vNo are both the
    // SAME other vertex, so without the nbrPrev!=nbrNext guard this
    // would double-count it. count must come out 1, not 2.
    app.allVertices = new float[][]{{0, 0, 0}, {10, 0, 0}};
    int[][] ringNodes = {{0, 1}};

    float[][] relaxSum = new float[1][3];
    int[] relaxNum = new int[1];

    app.Modify3D.accumulateRelaxFromRing(ringNodes, 0, 0, relaxSum, relaxNum);

    assertArrayEquals(new float[]{10, 0, 0}, relaxSum[0], 0.0001f);
    assertEquals(1, relaxNum[0]);
  }

  @Test
  void accumulateRelaxFromRing_ringNotContainingVNo_contributesNothing () {
    app.allVertices = new float[][]{{0, 0, 0}, {10, 0, 0}, {0, 10, 0}};
    int[][] ringNodes = {{1, 2}}; // vNo=0 isn't in this ring at all

    float[][] relaxSum = new float[1][3];
    int[] relaxNum = new int[1];

    app.Modify3D.accumulateRelaxFromRing(ringNodes, 0, 0, relaxSum, relaxNum);

    assertArrayEquals(new float[]{0, 0, 0}, relaxSum[0], 0.0001f);
    assertEquals(0, relaxNum[0]);
  }

  // --- relaxVertices_Selection (a full integration test) ---------------
  //
  // Combines accumulateRelaxFromRing (already unit-tested above) with
  // averaging by contribution count and the actual point-move step -
  // reusing the same triangle, where accumulateRelaxFromRing's own test
  // already established the raw accumulated total is (10,10,0) with 2
  // contributions, so the average is (5,5,0).

  @Test
  void relaxVertices_fullAmount_movesTheVertexAllTheWayToTheNeighborAverage () {
    app.allVertices = new float[][]{{0, 0, 0}, {10, 0, 0}, {0, 10, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0};
    app.User3D.modifierRelaxAmount = 1.0f;

    app.Modify3D.relaxVertices_Selection();

    assertArrayEquals(new float[]{5, 5, 0}, app.allVertices[0], 0.0001f);
    // Untouched neighbors - relax only ever moves the SELECTED vertices.
    assertArrayEquals(new float[]{10, 0, 0}, app.allVertices[1], 0.0001f);
    assertArrayEquals(new float[]{0, 10, 0}, app.allVertices[2], 0.0001f);
  }

  @Test
  void relaxVertices_partialAmount_movesOnlyThatFractionOfTheWay () {
    app.allVertices = new float[][]{{0, 0, 0}, {10, 0, 0}, {0, 10, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0};
    app.User3D.modifierRelaxAmount = 0.5f;

    app.Modify3D.relaxVertices_Selection();

    // Average is (5,5,0); starting from (0,0,0), half way there is (2.5,2.5,0).
    assertArrayEquals(new float[]{2.5f, 2.5f, 0}, app.allVertices[0], 0.0001f);
  }

  @Test
  void relaxVertices_vertexWithNoEdgesAtAll_isLeftExactlyWhereItIs () {
    // Vertex 0 isn't referenced by any face or polyline, so it has no
    // ring-neighbors to relax toward at all.
    app.allVertices = new float[][]{{3, 4, 5}, {10, 0, 0}, {0, 10, 0}};
    app.allFaces.nodes = new int[][]{{1, 2}}; // doesn't mention vertex 0
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0};
    app.User3D.modifierRelaxAmount = 1.0f;

    app.Modify3D.relaxVertices_Selection();

    assertArrayEquals(new float[]{3, 4, 5}, app.allVertices[0], 0.0001f);
  }

  @Test
  void relaxVertices_isANoOpWhenNothingIsSelected () {
    app.currentObjectCategory = app.ObjectCategory.SOLID; // not a polymesh category
    app.allVertices = new float[][]{{0, 0, 0}, {10, 0, 0}, {0, 10, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.Select3D.vertexSelection = new int[]{0};
    app.User3D.modifierRelaxAmount = 1.0f;

    app.Modify3D.relaxVertices_Selection();

    assertArrayEquals(new float[]{0, 0, 0}, app.allVertices[0], 0.0001f);
  }

  // --- skewVertices_Selection -------------------------------------------
  //
  // Shears each selected vertex by its OWN y/z offset from the selection's
  // bounding-box center (found in a read-only pass first, so moving one
  // vertex never changes another's pivot): dx = kXY*(y-cy) + kXZ*(z-cz),
  // dy = kYZ*(z-cz). No modifier touches the z coordinate itself.

  @Test
  void skewVertices_allThreeFactorsCombine_perTheFormula () {
    // 3 selected points spanning y in [0,10] and z in [0,10] -> pivot
    // (cy, cz) = (5, 5). Each point isolates a different axis offset.
    app.allVertices = new float[][]{{0, 0, 0}, {0, 10, 0}, {0, 0, 10}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1, 2};
    app.User3D.modifierSkewXY = 0.5f;
    app.User3D.modifierSkewXZ = 0.2f;
    app.User3D.modifierSkewYZ = 0.3f;

    app.Modify3D.skewVertices_Selection();

    // v0 (0,0,0): dx = 0.5*(0-5) + 0.2*(0-5) = -3.5; dy = 0.3*(0-5) = -1.5
    assertArrayEquals(new float[]{-3.5f, -1.5f, 0}, app.allVertices[0], 0.0001f);
    // v1 (0,10,0): dx = 0.5*(10-5) + 0.2*(0-5) = 1.5; dy = 0.3*(0-5) = -1.5
    assertArrayEquals(new float[]{1.5f, 8.5f, 0}, app.allVertices[1], 0.0001f);
    // v2 (0,0,10): dx = 0.5*(0-5) + 0.2*(10-5) = -1.5; dy = 0.3*(10-5) = 1.5
    assertArrayEquals(new float[]{-1.5f, 1.5f, 10}, app.allVertices[2], 0.0001f);
  }

  @Test
  void skewVertices_zeroFactors_isANoOp () {
    app.allVertices = new float[][]{{1, 2, 3}, {4, 5, 6}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierSkewXY = 0;
    app.User3D.modifierSkewXZ = 0;
    app.User3D.modifierSkewYZ = 0;

    app.Modify3D.skewVertices_Selection();

    assertArrayEquals(new float[]{1, 2, 3}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{4, 5, 6}, app.allVertices[1], 0.0001f);
  }

  @Test
  void skewVertices_singleSelectedVertex_isItsOwnPivot_soNothingMoves () {
    // min == max on both y and z for a single point, so (y-cy) and
    // (z-cz) are both exactly 0 regardless of the skew factors.
    app.allVertices = new float[][]{{3, 7, 9}};
    app.allFaces.nodes = new int[0][];
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0};
    app.User3D.modifierSkewXY = 2f;
    app.User3D.modifierSkewXZ = 2f;
    app.User3D.modifierSkewYZ = 2f;

    app.Modify3D.skewVertices_Selection();

    assertArrayEquals(new float[]{3, 7, 9}, app.allVertices[0], 0.0001f);
  }

  @Test
  void skewVertices_isANoOpWhenCategoryIsNotAPolymeshOne () {
    app.currentObjectCategory = app.ObjectCategory.SOLID; // not a polymesh category
    app.allVertices = new float[][]{{0, 0, 0}, {0, 10, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierSkewXY = 1f;

    app.Modify3D.skewVertices_Selection();

    assertArrayEquals(new float[]{0, 0, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{0, 10, 0}, app.allVertices[1], 0.0001f);
  }

  // --- skewVertices_Selection(int direction) ------------------------------
  // The Skew tool's own Shift+Up ("Increase Tool Parameter", direction
  // +1, identical to the no-arg method above)/Shift+Down ("Decrease
  // Tool Parameter", direction -1) nudge - see WIN3D.incrementParameter()
  // and WIN3DActionsTest.java's own keyShiftUp/Down-with-Skew-tool tests
  // for the end-to-end path. direction -1 negates all 3 factors; Skew
  // has no internal step order to also reverse (unlike Twist below), so
  // that alone is the whole difference from the forward (direction +1)
  // case.

  @Test
  void skewVertices_backwardDirection_negatesAllThreeFactors () {
    // Same setup/factors as skewVertices_allThreeFactorsCombine_
    // perTheFormula above - same per-point deltas, just negated.
    app.allVertices = new float[][]{{0, 0, 0}, {0, 10, 0}, {0, 0, 10}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1, 2};
    app.User3D.modifierSkewXY = 0.5f;
    app.User3D.modifierSkewXZ = 0.2f;
    app.User3D.modifierSkewYZ = 0.3f;

    app.Modify3D.skewVertices_Selection(-1);

    assertArrayEquals(new float[]{3.5f, 1.5f, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{-1.5f, 11.5f, 0}, app.allVertices[1], 0.0001f);
    assertArrayEquals(new float[]{1.5f, -1.5f, 10}, app.allVertices[2], 0.0001f);
  }

  // --- twistVertices_Selection -------------------------------------------
  //
  // Each axis's own rotation amount (degrees per meter) is driven by each
  // vertex's ORIGINAL offset along that same axis from the selection's
  // bounding-box center, applied via Rotate3D.rotateAroundVector() in a
  // fixed X -> Y -> Z order (same composition order as Select3D's own
  // object-level rotX/rotY/rotZ triple). These isolate one axis at a
  // time (the other two factors at 0, so those steps are the identity),
  // with offsets of +/-5m and 18 deg/m chosen so the angle works out to
  // a clean +/-90 degrees.

  @Test
  void twistVertices_aroundZOnly_rotatesTheXYPlaneByAngleProportionalToZOffset () {
    app.allVertices = new float[][]{{-1, 0, 0}, {1, 0, 10}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierTwistZ = 18; // cz=5 -> offsets -5/+5 -> +/-90 degrees

    app.Modify3D.twistVertices_Selection();

    assertArrayEquals(new float[]{0, 1, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{0, 1, 10}, app.allVertices[1], 0.0001f);
  }

  @Test
  void twistVertices_aroundXOnly_rotatesTheYZPlaneByAngleProportionalToXOffset () {
    app.allVertices = new float[][]{{0, -1, 0}, {10, 1, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierTwistX = 18; // cx=5 -> offsets -5/+5 -> +/-90 degrees

    app.Modify3D.twistVertices_Selection();

    assertArrayEquals(new float[]{0, 0, 1}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{10, 0, 1}, app.allVertices[1], 0.0001f);
  }

  @Test
  void twistVertices_aroundYOnly_rotatesTheXZPlaneByAngleProportionalToYOffset () {
    app.allVertices = new float[][]{{5, -5, 0}, {-5, 5, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierTwistY = 18; // cy=0 -> offsets -5/+5 -> +/-90 degrees

    app.Modify3D.twistVertices_Selection();

    assertArrayEquals(new float[]{0, -5, 5}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{0, 5, 5}, app.allVertices[1], 0.0001f);
  }

  @Test
  void twistVertices_zeroFactors_isANoOp () {
    app.allVertices = new float[][]{{1, 2, 3}, {4, 5, 6}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierTwistX = 0;
    app.User3D.modifierTwistY = 0;
    app.User3D.modifierTwistZ = 0;

    app.Modify3D.twistVertices_Selection();

    assertArrayEquals(new float[]{1, 2, 3}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{4, 5, 6}, app.allVertices[1], 0.0001f);
  }

  @Test
  void twistVertices_singleSelectedVertex_isItsOwnPivot_soNothingMoves () {
    // min == max on every axis for a single point, so every offset from
    // the pivot is exactly 0 - every rotation angle is 0 regardless of
    // the twist factors.
    app.allVertices = new float[][]{{3, 7, 9}};
    app.allFaces.nodes = new int[0][];
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0};
    app.User3D.modifierTwistX = 45f;
    app.User3D.modifierTwistY = 45f;
    app.User3D.modifierTwistZ = 45f;

    app.Modify3D.twistVertices_Selection();

    assertArrayEquals(new float[]{3, 7, 9}, app.allVertices[0], 0.0001f);
  }

  @Test
  void twistVertices_isANoOpWhenCategoryIsNotAPolymeshOne () {
    app.currentObjectCategory = app.ObjectCategory.SOLID; // not a polymesh category
    app.allVertices = new float[][]{{-1, 0, 0}, {1, 0, 10}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierTwistZ = 18;

    app.Modify3D.twistVertices_Selection();

    assertArrayEquals(new float[]{-1, 0, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{1, 0, 10}, app.allVertices[1], 0.0001f);
  }

  // --- twistVertices_Selection(int direction) -----------------------------
  // The Twist tool's own Shift+Up (direction +1)/Shift+Down (direction
  // -1) nudge. Unlike Skew/Bend, Twist's forward pass applies 3
  // sequential rotations (X, then Y, then Z) whose angles are each
  // recomputed from the point's CURRENT position - so simply negating
  // the 3 angles does NOT invert the forward pass when 2+ axes are
  // active at once; the backward pass must also apply them in REVERSED
  // order (Z, then Y, then X) for the composition to actually invert.
  // The two tests below prove both halves of that: an exact round-trip
  // for a single active axis (where order doesn't matter, since the
  // other two steps are no-ops), and a case with 2 simultaneously
  // active axes where only the reversed-order implementation is
  // correct - a naive same-order-but-negated version would land
  // somewhere else entirely.

  @Test
  void twistedPoint_forwardThenBackward_isAnExactRoundTrip_forASingleActiveAxis () {
    // Exercises twistedPoint() directly rather than through
    // twistVertices_Selection(): the latter re-reads the selection's
    // bounding-box center fresh on EVERY call (Select3D.
    // vertexIdsExtents(), shared with Skew and the overlay gizmo), so a
    // forward call followed by a backward call on the same selection
    // generally uses two DIFFERENT pivots - the forward twist moves the
    // vertices, which moves their own bounding-box center, so the
    // "round trip" claim below only holds at the single-point,
    // fixed-pivot level twistedPoint() itself operates at, which is
    // what this test isolates. Same single-active-axis setup (only
    // modifierTwistZ nonzero) as twistVertices_aroundZOnly_... above,
    // using that test's own v0 pivot-relative offset directly.
    app.User3D.modifierTwistX = 0;
    app.User3D.modifierTwistY = 0;
    app.User3D.modifierTwistZ = 18;

    float[] forward = app.Modify3D.twistedPoint(1, -1, 0, -5);
    float[] back = app.Modify3D.twistedPoint(-1, forward[0], forward[1], forward[2]);

    assertArrayEquals(new float[]{-1, 0, -5}, back, 0.0001f);
  }

  @Test
  void twistVertices_backwardDirection_reversesOrder_notJustNegatesAngles () {
    // Pivot at the origin (bounding box is symmetric), TwistX=TwistY=
    // 22.5 deg/m chosen so each vertex's own +/-4m offset on the active
    // axis produces a clean +/-90 degree angle at each of the two
    // active steps. Hand-derived via Rotate3D.rotateAroundVector()'s
    // formulas for direction=-1 (reversed order Z->Y->X, negated
    // angles - Z is a no-op here since modifierTwistZ=0):
    //   v0 (-4,-4,0): Y-step (-90deg, using original y=-4) sends
    //     (-4,-4,0) -> (0,-4,-4); then X-step (-90deg, using the
    //     ORIGINAL x=-4, not the post-Y-step x) sends (0,-4,-4) ->
    //     (0,-4,-4) unchanged (rotation around X leaves x alone, and
    //     the y/z here happen to land back on themselves for -90 at
    //     this offset) -> final (0,-4,-4).
    //   v1 (4,4,0): by symmetry, Y-step (+90deg) sends (4,4,0) ->
    //     (0,4,4); X-step (+90deg) sends (0,4,4) -> (0,4,-4).
    // A naive same-order (X then Y), negated-angles-only version would
    // instead give v0->(-4,0,4), v1->(4,0,-4) - a different, wrong
    // result - so this test is load-bearing for the order reversal,
    // not just the angle negation.
    app.allVertices = new float[][]{{-4, -4, 0}, {4, 4, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierTwistX = 22.5f;
    app.User3D.modifierTwistY = 22.5f;

    app.Modify3D.twistVertices_Selection(-1);

    assertArrayEquals(new float[]{0, -4, -4}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{0, 4, -4}, app.allVertices[1], 0.0001f);
  }

  // --- bendOffset / bendVertices_Selection --------------------------------
  //
  // The third of the Twist/Skew/Bend trio: a true circular-arc sagitta,
  // r*(1-cos(k*offset)) with k = radians(degPerMeter), r = 1/k - the
  // perpendicular distance a point at `offset` along the rod's own
  // original straight length lands from that original straight line once
  // the rod is curved into an arc of radius r. Unlike skewVertices_
  // Selection()'s linear k*offset (sign-preserving, asymmetric either
  // side of the pivot), cos() is an even function: bendOffset(rate, +d)
  // and bendOffset(rate, -d) are IDENTICAL - both sides of the pivot
  // bulge toward the same side, the same shape a real ruler takes when
  // bent into a shallow arc (a smile, not an S), not a sign-dependent
  // shear. 18 deg/m and a +/-5m offset are chosen the same way as
  // twistVertices' own tests - they resolve to a clean k*offset = 90
  // degrees, so r*(1-cos(90deg)) = r*(1-0) = r = 1/radians(18) = 10/PI.

  @Test
  void bendOffset_matchesTheArcSagittaFormula_andIsEvenInOffsetSign () {
    float r = (float) (10 / Math.PI); // 1 / radians(18)

    assertEquals(r, app.Modify3D.bendOffset(18, 5), 0.0001f);
    assertEquals(r, app.Modify3D.bendOffset(18, -5), 0.0001f, "same magnitude on either side of the pivot - a bend bulges one way, it doesn't shear");
  }

  @Test
  void bendOffset_zeroDegPerMeter_isZeroRegardlessOfOffset_noDivideByZero () {
    assertEquals(0, app.Modify3D.bendOffset(0, 5), 0.0001f);
    assertEquals(0, app.Modify3D.bendOffset(0, -5), 0.0001f);
    assertEquals(0, app.Modify3D.bendOffset(0, 0), 0.0001f);
  }

  @Test
  void bendVertices_xyOnly_curvesXByArcProportionalToYOffset () {
    app.allVertices = new float[][]{{0, 0, 0}, {0, 10, 0}}; // cy=5, cz=0 (trivial)
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierBendXY = 18; // cy=5 -> offsets -5/+5 -> 90 degrees each

    app.Modify3D.bendVertices_Selection();

    float r = (float) (10 / Math.PI);
    assertArrayEquals(new float[]{r, 0, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{r, 10, 0}, app.allVertices[1], 0.0001f);
  }

  @Test
  void bendVertices_xzOnly_curvesXByArcProportionalToZOffset () {
    app.allVertices = new float[][]{{0, 0, 0}, {0, 0, 10}}; // cz=5, cy=0 (trivial)
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierBendXZ = 18;

    app.Modify3D.bendVertices_Selection();

    float r = (float) (10 / Math.PI);
    assertArrayEquals(new float[]{r, 0, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{r, 0, 10}, app.allVertices[1], 0.0001f);
  }

  @Test
  void bendVertices_yzOnly_curvesYByArcProportionalToZOffset () {
    app.allVertices = new float[][]{{0, 0, 0}, {0, 0, 10}}; // cz=5, cy=0 (trivial)
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierBendYZ = 18;

    app.Modify3D.bendVertices_Selection();

    float r = (float) (10 / Math.PI);
    assertArrayEquals(new float[]{0, r, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{0, r, 10}, app.allVertices[1], 0.0001f);
  }

  @Test
  void bendVertices_zeroFactors_isANoOp () {
    app.allVertices = new float[][]{{1, 2, 3}, {4, 5, 6}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierBendXY = 0;
    app.User3D.modifierBendXZ = 0;
    app.User3D.modifierBendYZ = 0;

    app.Modify3D.bendVertices_Selection();

    assertArrayEquals(new float[]{1, 2, 3}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{4, 5, 6}, app.allVertices[1], 0.0001f);
  }

  @Test
  void bendVertices_singleSelectedVertex_isItsOwnPivot_soNothingMoves () {
    // min == max on both y and z for a single point, so (y-cy) and
    // (z-cz) are both exactly 0 - k*0 = 0 regardless of the bend factors.
    app.allVertices = new float[][]{{3, 7, 9}};
    app.allFaces.nodes = new int[0][];
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0};
    app.User3D.modifierBendXY = 45f;
    app.User3D.modifierBendXZ = 45f;
    app.User3D.modifierBendYZ = 45f;

    app.Modify3D.bendVertices_Selection();

    assertArrayEquals(new float[]{3, 7, 9}, app.allVertices[0], 0.0001f);
  }

  @Test
  void bendVertices_isANoOpWhenCategoryIsNotAPolymeshOne () {
    app.currentObjectCategory = app.ObjectCategory.SOLID; // not a polymesh category
    app.allVertices = new float[][]{{0, 0, 0}, {0, 10, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierBendXY = 18;

    app.Modify3D.bendVertices_Selection();

    assertArrayEquals(new float[]{0, 0, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{0, 10, 0}, app.allVertices[1], 0.0001f);
  }

  // --- bendVertices_Selection(int direction) ------------------------------
  // The Bend tool's own Shift+Up (direction +1)/Shift+Down (direction
  // -1) nudge. bendOffset()'s r*(1-cos(k*offset)) is even in k's sign
  // (cos is an even function), so negating the 3 bend factors simply
  // negates the arc's sagitta - no step-order reversal needed the way
  // Twist's sequential rotations require.

  @Test
  void bendVertices_backwardDirection_negatesAllThreeFactors () {
    // Same setup as bendVertices_xyOnly_curvesXByArcProportionalToYOffset
    // above, just negated direction -> negated sagitta.
    app.allVertices = new float[][]{{0, 0, 0}, {0, 10, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierBendXY = 18;

    app.Modify3D.bendVertices_Selection(-1);

    float r = (float) (10 / Math.PI);
    assertArrayEquals(new float[]{-r, 0, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{-r, 10, 0}, app.allVertices[1], 0.0001f);
  }

  // --- previewModifierDeformation -----------------------------------------
  //
  // The overlay gizmo's deformed-preview cage (Overlay3D.draw()) calls
  // this directly on each of its 12 edges' sample points - it's never
  // reached through a vertex-selection loop the way skewVertices_
  // Selection()/twistVertices_Selection()/bendVertices_Selection() are,
  // so it needs its own direct tests. It composes Skew, then Twist,
  // then Bend using the SAME skewDelta()/twistedPoint()/bendDelta()
  // helpers those three methods were refactored to call (a pure
  // extraction - see each helper's own comment), so what these tests
  // guard against is the WIRING here (right order, right intermediate
  // values passed through), not the formulas themselves - those are
  // already covered by skewVertices_Selection's/twistVertices_
  // Selection's/bendVertices_Selection's own tests above.

  @Test
  void previewModifierDeformation_allNineFieldsZero_isIdentity () {
    float[] result = app.Modify3D.previewModifierDeformation(2, -3, 4);

    assertArrayEquals(new float[]{2, -3, 4}, result, 0.0001f);
  }

  @Test
  void previewModifierDeformation_composesSkewThenTwistThenBend_inThatFixedOrder () {
    app.User3D.modifierSkewXY = 1.1f;
    app.User3D.modifierSkewXZ = -2.2f;
    app.User3D.modifierSkewYZ = 3.3f;
    app.User3D.modifierTwistX = 5f;
    app.User3D.modifierTwistY = -10f;
    app.User3D.modifierTwistZ = 15f;
    app.User3D.modifierBendXY = 4f;
    app.User3D.modifierBendXZ = -6f;
    app.User3D.modifierBendYZ = 8f;

    float x0 = 2, y0 = -3, z0 = 4;

    // Independently re-derive the expected result from the same three
    // shared helpers, composed by hand here rather than inside the
    // method under test - this is what pins down the ORDER and the
    // hand-off between stages (Twist's own "original" must be the
    // post-skew point; Bend's own "original" must be the post-twist
    // point), not the formulas themselves.
    float[] skew = app.Modify3D.skewDelta(y0, z0);
    float x1 = x0 + skew[0];
    float y1 = y0 + skew[1];
    float z1 = z0;

    float[] twisted = app.Modify3D.twistedPoint(x1, y1, z1);
    float x2 = twisted[0];
    float y2 = twisted[1];
    float z2 = twisted[2];

    float[] bend = app.Modify3D.bendDelta(y2, z2);
    float expectedX = x2 + bend[0];
    float expectedY = y2 + bend[1];
    float expectedZ = z2;

    float[] result = app.Modify3D.previewModifierDeformation(x0, y0, z0);

    assertArrayEquals(new float[]{expectedX, expectedY, expectedZ}, result, 0.0001f);
  }

  @Test
  void previewModifierDeformation_onlyBendSet_leavesXZeroOffsetUnaffected () {
    // A sanity cross-check independent of the helper re-derivation
    // above: with Skew and Twist both entirely zero, the point passed
    // in should flow through untouched until Bend's own additive
    // dx/dy - i.e. this should equal x0 plus bendDelta(y0,z0) exactly,
    // with no rotation or shear contribution sneaking in from a wiring
    // mistake (e.g. accidentally rotating around the wrong vector, or
    // reading Twist's fields instead of Bend's in the final stage).
    app.User3D.modifierBendXY = 18f;

    float[] result = app.Modify3D.previewModifierDeformation(0, 5, 0); // cy-relative offset of 5, matching the 18deg/m -> r=10/PI tests above

    float r = (float) (10 / Math.PI);
    assertArrayEquals(new float[]{r, 5, 0}, result, 0.0001f);
  }

  // --- "Relax/Skew/Twist/Bend Selected Group" actions ---------------------
  //
  // actions.pde wires each of these to the existing "Groups >> Vertices"
  // conversion (Select3D.convert_Groups_to_Vertices(), already covered by
  // Select3DTest's own convertGroupsToVertices_* tests) immediately
  // followed by the matching real vertex modifier - so a GROUP-category
  // selection can be relaxed/skewed/twisted/bent directly, without first
  // running "Groups >> Vertices" by hand. These exercise that wiring
  // end-to-end through runScriptLine() (the same entry point the menu
  // bar's own click handling uses), reusing each modifier's own
  // already-proven vertex math (see skewVertices_Selection's/
  // twistVertices_Selection's/bendVertices_Selection's tests above) by
  // picking a single-face group whose face's own node list matches that
  // test's vertexSelection exactly - so the expected numbers are identical
  // to those tests, with the group-to-vertex conversion as the only new
  // step being verified.

  @Test
  void twistSelectedGroup_convertsToVerticesThenTwists_aroundZ () {
    app.allVertices = new float[][]{{-1, 0, 0}, {1, 0, 10}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.allPolylines.nodes = new int[0][];
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};
    app.allGroups.Polylines[0] = new int[]{0, -1}; // empty
    app.Select3D.groupSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.User3D.modifierTwistZ = 18; // same 18deg/m as twistVertices_aroundZOnly_... above

    app.build_allActions();
    String hint = app.runScriptLine("Twist Selected Group");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(app.ObjectCategory.VERTEX, app.currentObjectCategory, "selection should end up at VERTEX category, same as a plain Groups >> Vertices");
    assertArrayEquals(new int[]{0, 1}, app.Select3D.vertexSelection, "the group's own face should have been expanded to its vertices first");
    assertArrayEquals(new float[]{0, 1, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{0, 1, 10}, app.allVertices[1], 0.0001f);
  }

  @Test
  void skewSelectedGroup_convertsToVerticesThenSkews_allThreeFactors () {
    app.allVertices = new float[][]{{0, 0, 0}, {0, 10, 0}, {0, 0, 10}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allPolylines.nodes = new int[0][];
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};
    app.allGroups.Polylines[0] = new int[]{0, -1};
    app.Select3D.groupSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.User3D.modifierSkewXY = 0.5f;
    app.User3D.modifierSkewXZ = 0.2f;
    app.User3D.modifierSkewYZ = 0.3f;

    app.build_allActions();
    String hint = app.runScriptLine("Skew Selected Group");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(app.ObjectCategory.VERTEX, app.currentObjectCategory);
    assertArrayEquals(new int[]{0, 1, 2}, app.Select3D.vertexSelection);
    // Same expected values as skewVertices_allThreeFactorsCombine_perTheFormula above.
    assertArrayEquals(new float[]{-3.5f, -1.5f, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{1.5f, 8.5f, 0}, app.allVertices[1], 0.0001f);
    assertArrayEquals(new float[]{-1.5f, 1.5f, 10}, app.allVertices[2], 0.0001f);
  }

  @Test
  void bendSelectedGroup_convertsToVerticesThenBends_xyOnly () {
    app.allVertices = new float[][]{{0, 0, 0}, {0, 10, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.allPolylines.nodes = new int[0][];
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};
    app.allGroups.Polylines[0] = new int[]{0, -1};
    app.Select3D.groupSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.User3D.modifierBendXY = 18;

    app.build_allActions();
    String hint = app.runScriptLine("Bend Selected Group");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(app.ObjectCategory.VERTEX, app.currentObjectCategory);
    assertArrayEquals(new int[]{0, 1}, app.Select3D.vertexSelection);
    float r = (float) (10 / Math.PI);
    assertArrayEquals(new float[]{r, 0, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{r, 10, 0}, app.allVertices[1], 0.0001f);
  }

  @Test
  void relaxSelectedGroup_convertsToVerticesThenRelaxes () {
    app.allVertices = new float[][]{{0, 0, 0}, {10, 0, 0}, {0, 10, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allPolylines.nodes = new int[0][];
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};
    app.allGroups.Polylines[0] = new int[]{0, -1};
    app.Select3D.groupSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.User3D.modifierRelaxAmount = 1.0f;

    app.build_allActions();
    String hint = app.runScriptLine("Relax Selected Group");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(app.ObjectCategory.VERTEX, app.currentObjectCategory);
    assertArrayEquals(new int[]{0, 1, 2}, app.Select3D.vertexSelection, "the whole face's vertices, not just one, should have been carried into the vertex selection");
    // Not re-deriving relaxVertices_Selection's own math here (already
    // covered by relaxVertices_fullAmount_... above) - just confirming
    // the wiring actually ran it: vertex 0 must have moved off its
    // original (0,0,0).
    assertNotEquals(0f, app.allVertices[0][0], "vertex should have moved toward its neighbors' average, not been left in place");
  }

  // --- collectNeighborDirections_fromRing -------------------------------
  //
  // Same ring-walking shape as accumulateRelaxFromRing (already
  // unit-tested above), but collecting a unit DIRECTION per ring
  // occurrence instead of summing raw positions - these reuse the same
  // hand-built rings/positions for an easy side-by-side comparison.

  @Test
  void collectNeighborDirections_triangle_collectsBothUnitDirections () {
    app.allVertices = new float[][]{{0, 0, 0}, {10, 0, 0}, {0, 10, 0}};
    int[][] ringNodes = {{0, 1, 2}};

    FloatList dirX = new FloatList();
    FloatList dirY = new FloatList();
    FloatList dirZ = new FloatList();
    app.Modify3D.collectNeighborDirections_fromRing(ringNodes, 0, 0, 0, 0, dirX, dirY, dirZ);

    assertEquals(2, dirX.size());
    assertEquals(1f, dirX.get(0), 0.0001f);
    assertEquals(0f, dirY.get(0), 0.0001f);
    assertEquals(0f, dirX.get(1), 0.0001f);
    assertEquals(1f, dirY.get(1), 0.0001f);
  }

  @Test
  void collectNeighborDirections_twoPointEdge_collectsItsOneRealNeighborOnlyOnce () {
    app.allVertices = new float[][]{{0, 0, 0}, {10, 0, 0}};
    int[][] ringNodes = {{0, 1}};

    FloatList dirX = new FloatList();
    FloatList dirY = new FloatList();
    FloatList dirZ = new FloatList();
    app.Modify3D.collectNeighborDirections_fromRing(ringNodes, 0, 0, 0, 0, dirX, dirY, dirZ);

    assertEquals(1, dirX.size(), "the degenerate 2-point ring's single real neighbor must not be double-counted");
    assertArrayEquals(new float[]{1, 0, 0}, new float[]{dirX.get(0), dirY.get(0), dirZ.get(0)}, 0.0001f);
  }

  @Test
  void collectNeighborDirections_ringNotContainingVNo_collectsNothing () {
    app.allVertices = new float[][]{{0, 0, 0}, {10, 0, 0}, {0, 10, 0}};
    int[][] ringNodes = {{1, 2}}; // vNo=0 isn't in this ring at all

    FloatList dirX = new FloatList();
    app.Modify3D.collectNeighborDirections_fromRing(ringNodes, 0, 0, 0, 0, dirX, new FloatList(), new FloatList());

    assertEquals(0, dirX.size());
  }

  @Test
  void collectNeighborDirections_coincidentNeighbor_isSkipped () {
    // vertex 1 sits exactly on top of vNo (a degenerate zero-length
    // edge) - appendUnitDirection's own len<0.00001 guard must drop it
    // rather than dividing by ~0, while vertex 2's real direction still
    // comes through.
    app.allVertices = new float[][]{{0, 0, 0}, {0, 0, 0}, {0, 10, 0}};
    int[][] ringNodes = {{0, 1, 2}};

    FloatList dirX = new FloatList();
    FloatList dirY = new FloatList();
    FloatList dirZ = new FloatList();
    app.Modify3D.collectNeighborDirections_fromRing(ringNodes, 0, 0, 0, 0, dirX, dirY, dirZ);

    assertEquals(1, dirX.size());
    assertArrayEquals(new float[]{0, 1, 0}, new float[]{dirX.get(0), dirY.get(0), dirZ.get(0)}, 0.0001f);
  }

  // --- collectFaceNormals_atVertex ----------------------------------------
  //
  // This is the fix for a real bug: an earlier version of
  // passiveSolarTouchVertices_Selection() froze a vertex based on the
  // spread of its ring-NEIGHBOR directions (collectNeighborDirections_
  // fromRing, tested above) rather than its surrounding FACE normals -
  // but opposite ring-neighbors are always ~180 degrees apart on any
  // ordinary flat grid (e.g. a box face after "Quad Tessellate"),
  // so that check froze nearly every interior vertex of any tessellated
  // face, not just real edges/corners. The first test below reproduces
  // exactly that flat-grid shape and confirms the face-NORMAL spread
  // correctly comes out near 0 there (so the vertex is free to move),
  // where the old neighbor-direction check would have measured ~180.

  @Test
  void collectFaceNormals_flatGridInteriorVertex_allFourFaceNormalsPointTheSameWay () {
    // A 3x3 patch of unit quads in the XY plane - the same shape
    // "Quad Tessellate" produces on a box face - with vertex 4
    // at the center, shared by all four quads.
    app.allVertices = new float[][]{
      {0, 0, 0}, {1, 0, 0}, {2, 0, 0},
      {0, 1, 0}, {1, 1, 0}, {2, 1, 0},
      {0, 2, 0}, {1, 2, 0}, {2, 2, 0}
    };
    app.allFaces.nodes = new int[][]{
      {0, 1, 4, 3},
      {1, 2, 5, 4},
      {4, 5, 8, 7},
      {3, 4, 7, 6}
    };

    FloatList nX = new FloatList();
    FloatList nY = new FloatList();
    FloatList nZ = new FloatList();
    app.Modify3D.collectFaceNormals_atVertex(app.allFaces.nodes, 4, nX, nY, nZ);

    assertEquals(4, nX.size(), "all four surrounding quads should each contribute their own corner normal");
    assertEquals(0f, app.Modify3D.maxPairwiseAngle(nX, nY, nZ), 0.001f,
      "a flat interior grid vertex's surrounding faces are all coplanar - this must NOT read as an edge/corner");
  }

  @Test
  void collectFaceNormals_rightAngleCorner_detectsTheNinetyDegreeCrease () {
    // Two unit quads meeting at vertex 0 at a right angle, like a real
    // box edge: one in the XY plane, one in the XZ plane - a genuine
    // crease, unlike the flat-grid case above. They share real vertex
    // INDICES (0 and 1) along their common edge, not just coincident
    // positions under different indices - a shared vertex in this app
    // is a shared index, same as everywhere else in this file.
    app.allVertices = new float[][]{
      {0, 0, 0}, {1, 0, 0}, {1, 1, 0}, {0, 1, 0}, {1, 0, 1}, {0, 0, 1}
    };
    app.allFaces.nodes = new int[][]{
      {0, 1, 2, 3}, // XY-plane quad
      {1, 0, 5, 4}  // XZ-plane quad, sharing the 0-1 edge
    };

    FloatList nX = new FloatList();
    FloatList nY = new FloatList();
    FloatList nZ = new FloatList();
    app.Modify3D.collectFaceNormals_atVertex(app.allFaces.nodes, 0, nX, nY, nZ);

    assertEquals(2, nX.size());
    assertEquals((float) (Math.PI / 2), app.Modify3D.maxPairwiseAngle(nX, nY, nZ), 0.01f,
      "two faces meeting at a real right-angle edge must read as a 90-degree crease");
  }

  @Test
  void collectFaceNormals_fewerThanTwoFaces_contributesNothingToCompare () {
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {1, 1, 0}, {0, 1, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}}; // vertex 0 touched by only one face

    FloatList nX = new FloatList();
    FloatList nY = new FloatList();
    FloatList nZ = new FloatList();
    app.Modify3D.collectFaceNormals_atVertex(app.allFaces.nodes, 0, nX, nY, nZ);

    assertEquals(1, nX.size());
    assertEquals(0f, app.Modify3D.maxPairwiseAngle(nX, nY, nZ), 0.0001f, "nothing to diverge from with only one face");
  }

  @Test
  void collectFaceNormals_degenerateCollinearCorner_isSkipped () {
    // Vertex 0's own two ring-neighbors within this triangle (1, its
    // "next", and 2, its "prev") sit exactly on the same line through
    // it, so the cross product - and the normal - is exactly zero
    // there; appendUnitDirection's sibling guard here must drop it
    // rather than dividing by ~0.
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {2, 0, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};

    FloatList nX = new FloatList();
    FloatList nY = new FloatList();
    FloatList nZ = new FloatList();
    app.Modify3D.collectFaceNormals_atVertex(app.allFaces.nodes, 0, nX, nY, nZ);

    assertEquals(0, nX.size());
  }

  // --- maxPairwiseAngle --------------------------------------------------

  @Test
  void maxPairwiseAngle_fewerThanTwoVectors_isZero () {
    assertEquals(0f, app.Modify3D.maxPairwiseAngle(new FloatList(), new FloatList(), new FloatList()), 0.0001f);

    FloatList oneX = new FloatList();
    oneX.append(1);
    FloatList oneY = new FloatList();
    oneY.append(0);
    FloatList oneZ = new FloatList();
    oneZ.append(0);
    assertEquals(0f, app.Modify3D.maxPairwiseAngle(oneX, oneY, oneZ), 0.0001f, "nothing to diverge from with only one direction");
  }

  @Test
  void maxPairwiseAngle_sameDirectionTwice_isZero () {
    FloatList dirX = new FloatList();
    dirX.append(1);
    dirX.append(1);
    FloatList dirY = new FloatList();
    dirY.append(0);
    dirY.append(0);
    FloatList dirZ = new FloatList();
    dirZ.append(0);
    dirZ.append(0);

    assertEquals(0f, app.Modify3D.maxPairwiseAngle(dirX, dirY, dirZ), 0.0001f);
  }

  @Test
  void maxPairwiseAngle_perpendicularVectors_isNinetyDegrees () {
    FloatList dirX = new FloatList();
    dirX.append(1);
    dirX.append(0);
    FloatList dirY = new FloatList();
    dirY.append(0);
    dirY.append(1);
    FloatList dirZ = new FloatList();
    dirZ.append(0);
    dirZ.append(0);

    assertEquals((float) (Math.PI / 2), app.Modify3D.maxPairwiseAngle(dirX, dirY, dirZ), 0.0001f);
  }

  @Test
  void maxPairwiseAngle_oppositeVectors_isOneHundredEightyDegrees () {
    FloatList dirX = new FloatList();
    dirX.append(1);
    dirX.append(-1);
    FloatList dirY = new FloatList();
    dirY.append(0);
    dirY.append(0);
    FloatList dirZ = new FloatList();
    dirZ.append(0);
    dirZ.append(0);

    assertEquals((float) Math.PI, app.Modify3D.maxPairwiseAngle(dirX, dirY, dirZ), 0.0001f);
  }

  @Test
  void maxPairwiseAngle_pickedAcrossNonAdjacentPair_notJustConsecutiveOnes () {
    // a (0deg) -> b (45deg) -> c (90deg from a, 45deg from b): the
    // widest gap is between a and c, the FIRST and LAST entries, not
    // between any two consecutive ones - this only passes if every
    // pair is actually checked, not just neighboring list entries.
    float h = (float) (Math.sqrt(2) / 2);
    FloatList dirX = new FloatList();
    dirX.append(1);
    dirX.append(h);
    dirX.append(0);
    FloatList dirY = new FloatList();
    dirY.append(0);
    dirY.append(h);
    dirY.append(1);
    FloatList dirZ = new FloatList();
    dirZ.append(0);
    dirZ.append(0);
    dirZ.append(0);

    assertEquals((float) (Math.PI / 2), app.Modify3D.maxPairwiseAngle(dirX, dirY, dirZ), 0.0001f);
  }

  // --- averageNormalizedDirection ------------------------------------------
  //
  // Pulled out of passiveSolarTouchVertices_Selection() so this piece of
  // its math - averaging a set of vectors (its own face normals, in
  // practice) and normalizing the result - can be unit-tested directly,
  // since that function's own real call to calculate_VertexSolar_array()
  // needs a live PGraphics surface and so can never be exercised through
  // the full function in a bare test instance (see the "no-op guard
  // paths only" section below).

  @Test
  void averageNormalizedDirection_singleVector_isJustItsOwnNormalizedCopy () {
    FloatList dx = new FloatList(); dx.append(0);
    FloatList dy = new FloatList(); dy.append(0);
    FloatList dz = new FloatList(); dz.append(5);

    float[] outDir = new float[3];
    assertTrue(app.Modify3D.averageNormalizedDirection(dx, dy, dz, outDir));
    assertArrayEquals(new float[]{0, 0, 1}, outDir, 0.0001f);
  }

  @Test
  void averageNormalizedDirection_multipleVectors_averagesThenNormalizes () {
    // Three copies of (1,0,0) and one of (0,1,0): sums to (3,1,0),
    // length sqrt(10) - the average is NOT just a simple per-axis mean
    // of already-unit vectors re-normalized by count, it's the sum
    // normalized, so a 3-to-1 majority direction dominates accordingly.
    FloatList dx = new FloatList(); dx.append(1); dx.append(1); dx.append(1); dx.append(0);
    FloatList dy = new FloatList(); dy.append(0); dy.append(0); dy.append(0); dy.append(1);
    FloatList dz = new FloatList(); dz.append(0); dz.append(0); dz.append(0); dz.append(0);

    float[] outDir = new float[3];
    assertTrue(app.Modify3D.averageNormalizedDirection(dx, dy, dz, outDir));

    float len = (float) Math.sqrt(10);
    assertArrayEquals(new float[]{3 / len, 1 / len, 0}, outDir, 0.0001f);
  }

  @Test
  void averageNormalizedDirection_oppositeVectorsCancelOut_returnsFalse () {
    FloatList dx = new FloatList(); dx.append(1); dx.append(-1);
    FloatList dy = new FloatList(); dy.append(0); dy.append(0);
    FloatList dz = new FloatList(); dz.append(0); dz.append(0);

    float[] outDir = new float[]{9, 9, 9}; // sentinel - must be left untouched
    assertFalse(app.Modify3D.averageNormalizedDirection(dx, dy, dz, outDir));
    assertArrayEquals(new float[]{9, 9, 9}, outDir, 0.0001f, "no stable direction - outDir must be left untouched, not zeroed or garbage");
  }

  @Test
  void averageNormalizedDirection_emptyLists_returnsFalse () {
    float[] outDir = new float[]{9, 9, 9};
    assertFalse(app.Modify3D.averageNormalizedDirection(new FloatList(), new FloatList(), new FloatList(), outDir));
    assertArrayEquals(new float[]{9, 9, 9}, outDir, 0.0001f);
  }

  // --- passiveSolarTouchMoveFor --------------------------------------------
  //
  // Pulled out of passiveSolarTouchVertices_Selection() for the same
  // testability reason as averageNormalizedDirection() above - this is
  // the per-vertex move decision itself: only step IN (opposite the
  // averaged outward face normal) when solar exposure is harmful
  // (solarValue <= 0); a beneficial vertex (solarValue > 0) is left
  // untouched for now rather than stepping OUT - that may come back
  // later as a separate option, but harmful-only step-in is the better
  // default confirmed for this app.

  @Test
  void passiveSolarTouchMoveFor_harmfulValue_stepsOppositeTheNormal_scaledByStep () {
    float[] moveBy = new float[3];
    // Outward normal points straight up; harmful exposure should step
    // the vertex DOWN (opposite the normal), by exactly `step`.
    assertTrue(app.Modify3D.passiveSolarTouchMoveFor(0, 0, 1, -5f, 0.25f, moveBy));
    assertArrayEquals(new float[]{0, 0, -0.25f}, moveBy, 0.0001f);
  }

  @Test
  void passiveSolarTouchMoveFor_beneficialValue_leavesVertexUntouched () {
    float[] moveBy = new float[]{9, 9, 9}; // sentinel - must be left untouched
    assertFalse(app.Modify3D.passiveSolarTouchMoveFor(0, 0, 1, 5f, 0.25f, moveBy));
    assertArrayEquals(new float[]{9, 9, 9}, moveBy, 0.0001f, "beneficial vertices get no step-out for now - moveBy must be left untouched");
  }

  @Test
  void passiveSolarTouchMoveFor_zeroSolarValue_isNoSignal_leavesVertexUntouched () {
    float[] moveBy = new float[]{9, 9, 9};
    assertFalse(app.Modify3D.passiveSolarTouchMoveFor(0, 0, 1, 0f, 0.25f, moveBy));
    assertArrayEquals(new float[]{9, 9, 9}, moveBy, 0.0001f);
  }

  @Test
  void passiveSolarTouchMoveFor_undefinedSolarValue_leavesVertexUntouched () {
    float[] moveBy = new float[]{9, 9, 9};
    assertFalse(app.Modify3D.passiveSolarTouchMoveFor(0, 0, 1, app.FLOAT_undefined, 0.25f, moveBy));
    assertArrayEquals(new float[]{9, 9, 9}, moveBy, 0.0001f);
  }

  // --- vertexSolar_TotalComparisonAt --------------------------------------
  //
  // Reads directly off hand-set VertexSolar_XYZ/VertexSolar_amounts
  // arrays rather than running calculate_VertexSolar_array() itself -
  // that function needs a live PGraphics surface to run at all (see
  // SolarArraySmokeTest.java's own comment on why it can't be smoke
  // tested here), so this isolates just the lookup/averaging logic that
  // reads its output.

  @Test
  void vertexSolar_TotalComparisonAt_singleMatch_returnsItsValue () {
    app.VertexSolar_XYZ = new float[][]{{1, 2, 3, 0, 0, 0, 0, 0, 0}};
    app.VertexSolar_amounts = new float[2][1][];
    app.VertexSolar_amounts[app.Impact_PASSIVE][0] = new float[]{7.5f};

    assertEquals(7.5f, app.Modify3D.vertexSolar_TotalComparisonAt(1, 2, 3), 0.0001f);
  }

  @Test
  void vertexSolar_TotalComparisonAt_multipleMatches_averagesThem () {
    // Positions (1,2,3) repeats across rows 0 and 1 (one real vertex
    // shared by two faces, each contributing its own sample point, per
    // VertexSolar_forceNoTessellation's own comment) - row 2 is a
    // different position and must not be pulled into the average.
    app.VertexSolar_XYZ = new float[][]{
      {1, 2, 3, 0, 0, 0, 0, 0, 0},
      {1, 2, 3, 9, 9, 9, 0, 0, 0},
      {5, 5, 5, 0, 0, 0, 0, 0, 0}
    };
    app.VertexSolar_amounts = new float[2][1][];
    app.VertexSolar_amounts[app.Impact_PASSIVE][0] = new float[]{4.0f, 8.0f, 100f};

    assertEquals(6.0f, app.Modify3D.vertexSolar_TotalComparisonAt(1, 2, 3), 0.0001f);
  }

  @Test
  void vertexSolar_TotalComparisonAt_noMatch_isUndefined () {
    app.VertexSolar_XYZ = new float[][]{{9, 9, 9, 0, 0, 0, 0, 0, 0}};
    app.VertexSolar_amounts = new float[2][1][];
    app.VertexSolar_amounts[app.Impact_PASSIVE][0] = new float[]{1f};

    assertEquals(app.FLOAT_undefined, app.Modify3D.vertexSolar_TotalComparisonAt(1, 2, 3), 0.0001f);
  }

  @Test
  void vertexSolar_TotalComparisonAt_arrayNeverBuilt_isUndefined () {
    // A fresh app instance: VertexSolar_XYZ/VertexSolar_amounts are
    // both still null, exactly as they are before calculate_
    // VertexSolar_array() has ever run once.
    assertEquals(app.FLOAT_undefined, app.Modify3D.vertexSolar_TotalComparisonAt(1, 2, 3), 0.0001f);
  }

  @Test
  void vertexSolar_TotalComparisonAt_mismatchedArrayLengths_isUndefined () {
    // Defensive guard against a stale/inconsistent pair of arrays -
    // shouldn't normally happen (both are always rebuilt together by
    // calculate_VertexSolar_array()), but reading past comparisons'
    // own length would be a real bug if it ever did.
    app.VertexSolar_XYZ = new float[][]{{1, 2, 3, 0, 0, 0, 0, 0, 0}};
    app.VertexSolar_amounts = new float[2][1][];
    app.VertexSolar_amounts[app.Impact_PASSIVE][0] = new float[]{1f, 2f};

    assertEquals(app.FLOAT_undefined, app.Modify3D.vertexSolar_TotalComparisonAt(1, 2, 3), 0.0001f);
  }

  @Test
  void vertexSolar_TotalComparisonAt_skipsUndefinedMatches_inTheAverage () {
    app.VertexSolar_XYZ = new float[][]{
      {1, 2, 3, 0, 0, 0, 0, 0, 0},
      {1, 2, 3, 0, 0, 0, 0, 0, 0}
    };
    app.VertexSolar_amounts = new float[2][1][];
    app.VertexSolar_amounts[app.Impact_PASSIVE][0] = new float[]{app.FLOAT_undefined, 5f};

    assertEquals(5f, app.Modify3D.vertexSolar_TotalComparisonAt(1, 2, 3), 0.0001f);
  }

  // --- faceSolarAverage ----------------------------------------------------
  //
  // Same hand-set VertexSolar_XYZ/VertexSolar_amounts approach as
  // vertexSolar_TotalComparisonAt above, for the same reason -
  // calculate_VertexSolar_array() needs a live PGraphics surface to run
  // at all. passiveSolarInsetFaces_Selection() below uses this to
  // decide whether a face reads as harmful ON AVERAGE across its own
  // vertices, with one single undefined vertex disqualifying the whole
  // face outright (not just quietly dropped from the average, the way
  // vertexSolar_TotalComparisonAt's own per-position duplicates are).

  @Test
  void faceSolarAverage_everyVertexDefined_averagesThem () {
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {1, 1, 0}, {0, 1, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};

    app.VertexSolar_XYZ = new float[][]{
      {0, 0, 0, 0, 0, 0, 0, 0, 0},
      {1, 0, 0, 0, 0, 0, 0, 0, 0},
      {1, 1, 0, 0, 0, 0, 0, 0, 0},
      {0, 1, 0, 0, 0, 0, 0, 0, 0}
    };
    app.VertexSolar_amounts = new float[2][1][];
    app.VertexSolar_amounts[app.Impact_PASSIVE][0] = new float[]{-4f, -2f, 2f, 0f};

    assertEquals(-1f, app.Modify3D.faceSolarAverage(0), 0.0001f); // (-4-2+2+0)/4 = -1
  }

  @Test
  void faceSolarAverage_anyUndefinedVertex_disqualifiesTheWholeFace () {
    // Vertex 2 (at (9,9,9)) has no matching VertexSolar_XYZ row at all -
    // even though the other two vertices both read strongly harmful,
    // the whole face must come back undefined, not an average over just
    // the two defined ones.
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {9, 9, 9}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};

    app.VertexSolar_XYZ = new float[][]{
      {0, 0, 0, 0, 0, 0, 0, 0, 0},
      {1, 0, 0, 0, 0, 0, 0, 0, 0}
    };
    app.VertexSolar_amounts = new float[2][1][];
    app.VertexSolar_amounts[app.Impact_PASSIVE][0] = new float[]{-5f, -5f};

    assertEquals(app.FLOAT_undefined, app.Modify3D.faceSolarAverage(0), 0.0001f);
  }

  // --- passiveSolarTouchVertices_Selection (no-op guard paths only) ---------
  //
  // The real call it makes to calculate_VertexSolar_array() needs a
  // live PGraphics surface to run at all (see SolarArraySmokeTest.java's
  // own comment) - a bare test instance throws a NullPointerException
  // reaching it, same as that file documents for calculate_
  // VertexSolar_array() itself. So only the two early-return guards
  // that sit BEFORE that call are exercised here; the step/direction/
  // freeze math itself is covered above, isolated from that call, via
  // collectNeighborDirections_fromRing, maxPairwiseAngle and
  // vertexSolar_TotalComparisonAt directly.

  @Test
  void passiveSolarTouch_isANoOpWhenCategoryIsNotPolymesh () {
    app.currentObjectCategory = app.ObjectCategory.SOLID;
    app.allVertices = new float[][]{{1, 2, 3}};
    app.Select3D.vertexSelection = new int[]{0};

    assertDoesNotThrow(() -> app.Modify3D.passiveSolarTouchVertices_Selection());

    assertArrayEquals(new float[]{1, 2, 3}, app.allVertices[0], 0.0001f);
  }

  @Test
  void passiveSolarTouch_isANoOpWhenNothingIsSelected () {
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.allVertices = new float[][]{{1, 2, 3}};
    app.Select3D.vertexSelection = new int[]{};

    assertDoesNotThrow(() -> app.Modify3D.passiveSolarTouchVertices_Selection());

    assertArrayEquals(new float[]{1, 2, 3}, app.allVertices[0], 0.0001f);
  }

  // --- "Passive Solar Touch Selected Vertices"/"...Group" (wiring only) -----
  //
  // Same NullPointerException constraint as above rules out a full
  // integration test through runScriptLine() once real vertices would
  // actually be selected - these two only confirm the command is
  // registered and reaches/respects the same early-return guards,
  // staying on their safe side.

  @Test
  void passiveSolarTouchSelectedVertices_commandIsRegistered_andSafeWhenNothingIsSelected () {
    app.currentObjectCategory = app.ObjectCategory.SOLID; // not a polymesh category
    app.allVertices = new float[0][3];

    app.build_allActions();
    String hint = app.runScriptLine("Passive Solar Touch Selected Vertices");

    assertNotEquals(app.UnrecognizedCommand, hint);
  }

  @Test
  void passiveSolarTouchSelectedGroup_commandIsRegistered_andSwitchesToVertexCategory () {
    app.allVertices = new float[0][3];
    app.allFaces.nodes = new int[0][];
    app.allPolylines.nodes = new int[0][];
    app.allGroups.makeEmpty(0);
    app.Select3D.groupSelection = new int[]{};
    app.currentObjectCategory = app.ObjectCategory.GROUP;

    app.build_allActions();
    String hint = app.runScriptLine("Passive Solar Touch Selected Group");

    assertNotEquals(app.UnrecognizedCommand, hint);
    // No groups selected -> convert_Groups_to_Vertices() yields an
    // empty vertex selection, which is passiveSolarTouchVertices_
    // Selection()'s own second early-return guard - so this stays
    // safely clear of the calculate_VertexSolar_array() call while
    // still proving the group-to-vertex conversion half of the wiring
    // ran (same category-switch check relaxSelectedGroup_... above
    // uses).
    assertEquals(app.ObjectCategory.VERTEX, app.currentObjectCategory);
  }

  // --- passiveSolarInsetFaces_Selection (no-op guard paths only) -----------
  //
  // Same NullPointerException constraint as passiveSolarTouchVertices_
  // Selection() above: its own real call to calculate_VertexSolar_array()
  // needs a live PGraphics surface to run at all, so only the two early-
  // return guards that sit BEFORE that call are exercised here. The
  // per-face decision and geometry themselves are covered in isolation
  // above, via faceSolarAverage() and insetAndRecedeFace() directly.

  @Test
  void passiveSolarInsetFaces_isANoOpWhenCategoryIsNeitherGroupNorFace () {
    app.currentObjectCategory = app.ObjectCategory.SOLID;
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};

    assertDoesNotThrow(() -> app.Modify3D.passiveSolarInsetFaces_Selection());

    assertEquals(1, app.allFaces.nodes.length);
  }

  @Test
  void passiveSolarInsetFaces_isANoOpWhenNothingIsSelected () {
    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.Select3D.faceSelection = new int[]{};

    assertDoesNotThrow(() -> app.Modify3D.passiveSolarInsetFaces_Selection());

    assertEquals(1, app.allFaces.nodes.length);
  }

  // --- "Passive Solar Inset" (wiring only) ---------------------------------
  //
  // Same NullPointerException constraint rules out a full integration
  // test through runScriptLine() once real faces would actually be
  // selected - this only confirms the command is registered and
  // respects the same early-return guard, staying on its safe side.

  @Test
  void passiveSolarInsetSelectedFaces_commandIsRegistered_andSafeWhenNothingIsSelected () {
    app.currentObjectCategory = app.ObjectCategory.SOLID; // not a Group/Face category
    app.allFaces.nodes = new int[0][];

    app.build_allActions();
    String hint = app.runScriptLine("Passive Solar Inset");

    assertNotEquals(app.UnrecognizedCommand, hint);
  }
}
