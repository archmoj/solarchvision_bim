import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Exercises the small, self-contained helpers in Modify3D.pde -
// remove_item_from_primary_list (pure, already package-private),
// isPolymeshCategorySelected/isGroupOrFaceCategorySelected (pure given
// current_ObjectCategory), faceCentroid (pure given a vertex array),
// isFaceInGroupRange/faceBaseVertices (pure given a small hand-built
// mesh, bypassing the real scene-building pipeline entirely),
// compactRemovedVertices (mutates allVertices/allFaces.nodes/
// allPolylines.nodes in place, but only those - no other scene state),
// and accumulateOffsetFromRing (pure given a hand-built ring face and
// output accumulator arrays).
//
// The bulk of Modify3D.pde (weldSceneVertices_Selection,
// insertCornerOpennings_Selection, tessellateRowsColumns_Selection,
// extrudeFaceEdges_Selection, ...) mutates the live scene graph
// (allFaces, allPoints, allGroups, Select3D) through many interdependent
// steps - genuine integration-test territory, not covered here.
//
// isPolymeshCategorySelected/isGroupOrFaceCategorySelected/
// isFaceInGroupRange/faceBaseVertices/faceCentroid/
// accumulateOffsetFromRing were changed from private to package-private
// (see Modify3D.pde) so this test can call them directly without
// reflection - see test/README.md. The ObjectCategory.* constants they
// (and this test) reference were likewise loosened in OBJECTTYPE.pde,
// since a private member is only shared between nested classes of the
// *same* enclosing top-level class, and this test class is a separate
// top-level class, not a nested class of solarchvision_bim.
//
// A fresh `app` per test since several of these tests reassign shared
// mutable fields (allVertices, allFaces.nodes, allGroups.Faces,
// current_ObjectCategory).
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
      app.current_ObjectCategory = category;
      assertTrue(app.Modify3D.isPolymeshCategorySelected(), "category=" + category);
    }
  }

  @Test
  void isPolymeshCategorySelected_isFalseForOtherCategories () {
    app.current_ObjectCategory = app.ObjectCategory.SOLID;
    assertFalse(app.Modify3D.isPolymeshCategorySelected());
  }

  @Test
  void isGroupOrFaceCategorySelected_isTrueOnlyForGroupAndFace () {
    app.current_ObjectCategory = app.ObjectCategory.GROUP;
    assertTrue(app.Modify3D.isGroupOrFaceCategorySelected());

    app.current_ObjectCategory = app.ObjectCategory.FACE;
    assertTrue(app.Modify3D.isGroupOrFaceCategorySelected());

    app.current_ObjectCategory = app.ObjectCategory.POLYLINE;
    assertFalse(app.Modify3D.isGroupOrFaceCategorySelected());

    app.current_ObjectCategory = app.ObjectCategory.VERTEX;
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
  // rest of Modify3D.pde would need than a unit test of one piece.
  //
  // Before writing it, SOLARCHVISION_switch_category/_selection_changed/
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

    app.Select3D.Face_ids = new int[]{0};
    app.current_ObjectCategory = app.ObjectCategory.FACE;

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
    assertArrayEquals(new int[]{0, 1, 2, 3}, app.Select3D.Face_ids);
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

    app.Select3D.Face_ids = new int[]{0};
    app.current_ObjectCategory = app.ObjectCategory.FACE;

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
    assertArrayEquals(new int[]{0, 1, 2, 3}, app.Select3D.Face_ids);
  }

  // --- changeVisibilityFaces_Scene / reverseVisibilityFaces_Scene -----
  //
  // Unlike the *_Selection operations above, these two act on every
  // face in the scene unconditionally - no Select3D or
  // current_ObjectCategory setup needed at all.

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

    app.current_ObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.Vertex_ids = new int[]{0};

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
    // even if Polyline_ids was already populated.
    app.allPolylines.nodes = new int[][]{{0}};
    app.allPolylines.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.Select3D.Polyline_ids = new int[]{0};
    app.current_ObjectCategory = app.ObjectCategory.FACE;

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

    app.Select3D.Group_ids = new int[]{0};
    app.current_ObjectCategory = app.ObjectCategory.GROUP;

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
    app.Select3D.Face_ids = new int[]{0};
    app.current_ObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.selectVertices_fromCurrentSelection();

    // Vertex_ids is deduped/collected in the face's own node order by
    // convert_Faces_to_Vertices, but this function always sorts
    // afterward regardless of that order.
    assertArrayEquals(new int[]{0, 1, 2}, app.Select3D.Vertex_ids);
  }

  // --- selectFacesAndGroups_fromCurrentSelection ----------------------

  @Test
  void selectFacesAndGroupsFromCurrentSelection_sortsBothBeforeAndAfterConversion () {
    // Two groups whose face ranges are deliberately out of numeric order
    // relative to their group ids (group 0 -> faces 5-6, group 1 ->
    // faces 0-1): rangeUnion() walks Group_ids in whatever order it's
    // given, so if Group_ids weren't sorted first, or Face_ids weren't
    // sorted after, the result would come out as [5,6,0,1] instead of
    // ascending - this test is specifically shaped to make both sort
    // calls matter, not just one.
    app.allGroups.makeEmpty(2);
    app.allGroups.Faces[0] = new int[]{5, 6};
    app.allGroups.Faces[1] = new int[]{0, 1};
    app.allFaces.nodes = new int[7][0]; // faces 0-6 need to exist

    app.Select3D.Group_ids = new int[]{1, 0}; // deliberately unsorted input
    app.current_ObjectCategory = app.ObjectCategory.GROUP;

    app.Modify3D.selectFacesAndGroups_fromCurrentSelection();

    assertArrayEquals(new int[]{0, 1}, app.Select3D.Group_ids);
    assertArrayEquals(new int[]{0, 1, 5, 6}, app.Select3D.Face_ids);
  }

  // --- repositionVertices_Selection -------------------------------

  @Test
  void repositionVertices_movesEverySelectedVertexToTheirBoundingBoxCenter () {
    // Deliberately asymmetric points, to distinguish "bounding-box
    // center" (this function's actual behavior: (min+max)/2) from
    // "average position" (which would give a different answer here):
    // min=0, max=10 -> center=5, but the average of {0,1,10} is 3.667.
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {10, 0, 0}};
    app.current_ObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.Vertex_ids = new int[]{0, 1, 2};

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
    app.current_ObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.Vertex_ids = new int[]{0};

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
    app.current_ObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.Vertex_ids = new int[]{0};

    app.Modify3D.separateVertices_Selection();

    assertEquals(5, app.allVertices.length); // 3 original + 2 independent duplicates
    assertArrayEquals(new int[]{3, 1}, app.allFaces.nodes[0]);
    assertArrayEquals(new int[]{4, 2}, app.allFaces.nodes[1]);
    assertArrayEquals(new float[]{0, 0, 0}, app.allVertices[3], 0.0001f);
    assertArrayEquals(new float[]{0, 0, 0}, app.allVertices[4], 0.0001f);
    assertEquals(0, app.Select3D.Vertex_ids.length); // deselected afterward
  }

  // --- weldObjectsVertices_Selection (a full integration test) --------
  //
  // NOTE: this function's sibling, weldSceneVertices_Selection, has a
  // dead-code bug - it declares `int found = -1;` immediately followed
  // by `if (found != -1) { ... }`, so that condition can never be true
  // and the entire welding logic (both the faces and polylines search
  // loops) never runs. weldSceneVertices_Selection is therefore
  // currently a no-op in practice (it selects vertices, builds an
  // all-false toRemove array, and deselects - nothing is ever welded).
  // Flagged separately rather than fixed here; no test is written
  // against that function since testing broken behavior isn't useful,
  // and the correct fix isn't assumed without confirmation. This
  // function does NOT share that bug - its search loop has no such
  // guard - so it's tested normally below.

  @Test
  void weldObjectsVertices_mergesNearbyVerticesAndRedirectsAllReferences () {
    // Points 0 and 1 are 0.001 apart (within max_distance); point 2 is
    // far away and should be left alone.
    app.allVertices = new float[][]{{0, 0, 0}, {0.001f, 0, 0}, {5, 5, 5}};
    app.allFaces.nodes = new int[][]{{0}, {1}}; // face 0 references point 0, face 1 references point 1
    app.allPolylines.nodes = new int[0][];

    app.current_ObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.Vertex_ids = new int[]{0, 1, 2};

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

  // --- insertEdgeOpennings_Selection (a full integration test) --------
  //
  // Unlike the tessellate*_Selection functions, this one does NOT call
  // appendNewFaceSelection - the newly-created triangular faces are
  // never added to Select3D.Face_ids, even though they now exist in the
  // scene. Worth confirming explicitly since it's easy to assume every
  // face-splitting operation updates the selection the same way.

  @Test
  void insertEdgeOpennings_insetsTheBaseFaceAndRingsItWithNewTriangles () {
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};

    app.Select3D.Face_ids = new int[]{0};
    app.current_ObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.insertEdgeOpennings_Selection(); // User3D.modify_OpenningDeviation defaults to 0.5 (edge midpoints)

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
    assertArrayEquals(new int[]{0}, app.Select3D.Face_ids);
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

    app.Select3D.Face_ids = new int[]{0, 1};
    app.current_ObjectCategory = app.ObjectCategory.FACE;

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
    assertArrayEquals(new int[]{0, 1, 2, 3, 4}, app.Select3D.Face_ids);
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

    app.Select3D.Face_ids = new int[]{0};
    app.current_ObjectCategory = app.ObjectCategory.FACE;

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
    // matter which way it's wound. This only confirms the "nothing to
    // compare against" case; the actual flip-on-hit branch needs a
    // second face for the ray to hit, which risks landing exactly on
    // the acceptance boundary of the self-test and wasn't attempted here.
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {0, 1, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{0, 0, 0, 1, 0, 0}}; // visible

    app.Select3D.Face_ids = new int[]{0};
    app.current_ObjectCategory = app.ObjectCategory.FACE;

    app.Modify3D.autoNormalFaces_Selection();

    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
  }
}
