import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Exercises solarchvision_Select3D (Select3D.pde), reached through the
// pre-constructed `app.Select3D` field. This is the largest source file
// tested so far (2282 lines), so coverage here is organized into
// sections mirroring the source's own order.
//
// NOT covered: rectTest_vertex and selectRect. Both depend on
// WIN3D.calculate_Perspective_Internally (live 3D-to-screen camera
// projection) and the real mouseButton state - genuine
// rendering/input-dependent integration territory that a hand-built
// scene can't exercise without a real camera/projection setup.
// selectPick, by contrast, takes an already-computed hit result as its
// argument and never touches projection itself, so it IS covered below.
//
// Also not given their own direct tests: appendIndicesInRange,
// appendGroupsContaining, appendGroupsContainingVertex,
// appendNodesOfRange - these take a raw `IntList buf` parameter (an
// internal accumulator type), and are fully exercised indirectly
// through their public-facing callers (rangeUnion, groupsContaining,
// convert_Vertices_to_Groups, convert_Groups_to_Vertices), which are
// tested directly below and take/return plain int[] instead.
//
// A fresh `app` per test since nearly everything here mutates shared
// selection/scene state.
class Select3DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= pure id-list utilities ==========================

  @Test
  void appendId_addsToTheEnd () {
    assertArrayEquals(new int[]{1, 2, 5}, app.Select3D.appendId(new int[]{1, 2}, 5));
  }

  @Test
  void removeIdAt_dropsThatPositionPreservingOrder () {
    assertArrayEquals(new int[]{1, 3}, app.Select3D.removeIdAt(new int[]{1, 2, 3}, 1));
  }

  @Test
  void toggleSelection_replaceModeAlwaysAppendsRegardlessOfPriorContent () {
    // Mode 0 ("replace") skips the search loop entirely and always
    // appends - this only produces correct "replace" semantics because
    // every caller (e.g. selectPick) clears the whole selection first;
    // called directly on a non-empty list, it can even duplicate an
    // already-present id. Documenting the actual mechanism, not an
    // idealized one.
    app.addNewSelectionToPreviousSelection = 0;
    assertArrayEquals(new int[]{1, 2, 5}, app.Select3D.toggleSelection(new int[]{1, 2}, 5));
    assertArrayEquals(new int[]{1, 2, 2}, app.Select3D.toggleSelection(new int[]{1, 2}, 2));
  }

  @Test
  void toggleSelection_addModeAppendsIfAbsentAndIsANoOpIfAlreadyPresent () {
    app.addNewSelectionToPreviousSelection = 1;
    assertArrayEquals(new int[]{1, 2, 5}, app.Select3D.toggleSelection(new int[]{1, 2}, 5));
    assertArrayEquals(new int[]{1, 2}, app.Select3D.toggleSelection(new int[]{1, 2}, 2)); // already there
  }

  @Test
  void toggleSelection_subtractModeRemovesIfPresentAndIsANoOpIfAbsent () {
    app.addNewSelectionToPreviousSelection = -1;
    assertArrayEquals(new int[]{1}, app.Select3D.toggleSelection(new int[]{1, 2}, 2));
    assertArrayEquals(new int[]{1, 2}, app.Select3D.toggleSelection(new int[]{1, 2}, 5)); // nothing to remove
  }

  @Test
  void rangeIds_buildsZeroToNMinusOne () {
    assertArrayEquals(new int[]{0, 1, 2, 3, 4}, app.Select3D.rangeIds(5));
  }

  @Test
  void rangeIds_isEmptyForZeroOrNegative () {
    assertArrayEquals(new int[]{}, app.Select3D.rangeIds(0));
    assertArrayEquals(new int[]{}, app.Select3D.rangeIds(-3));
  }

  @Test
  void invertedIds_returnsEverythingNotInTheSelection () {
    assertArrayEquals(new int[]{0, 2, 4}, app.Select3D.invertedIds(new int[]{1, 3}, 5));
  }

  @Test
  void lastId_isTheFinalIndexOrEmptyIfNoneExist () {
    assertArrayEquals(new int[]{4}, app.Select3D.lastId(5));
    assertArrayEquals(new int[]{}, app.Select3D.lastId(0));
  }

  @Test
  void idsToXMLAndBack_roundTrips () {
    int[] ids = {1, 2, 3};
    String xml = app.Select3D.idsToXML(ids);
    assertEquals("1|2|3", xml);
    assertArrayEquals(ids, app.Select3D.idsFromXML(xml));
    assertArrayEquals(new int[]{}, app.Select3D.idsFromXML(""));
  }

  @Test
  void floatsToXMLAndBack_roundTrips () {
    float[] values = {1.5f, 2.25f};
    String xml = app.Select3D.floatsToXML(values);
    assertArrayEquals(values, app.Select3D.floatsFromXML(xml), 0.0001f);
    assertArrayEquals(new float[]{}, app.Select3D.floatsFromXML(""), 0.0001f);
  }

  // ============ range/group/vertex lookup helpers =====================

  @Test
  void rangeUnion_expandsEachGroupsRangeAndDedupes () {
    int[] result = app.Select3D.rangeUnion(new int[][]{{0, 1}, {2, 3}}, new int[]{0, 1}, 4);
    assertArrayEquals(new int[]{0, 1, 2, 3}, result);
  }

  @Test
  void groupsContaining_findsWhichRangeAFaceFallsIn () {
    app.allGroups.makeEmpty(2); // appendGroupsContaining loops by allGroups.num, not rangeTable.length
    int[] result = app.Select3D.groupsContaining(new int[][]{{0, 1}, {2, 3}}, new int[]{3});
    assertArrayEquals(new int[]{1}, result);
  }

  @Test
  void nodesOf_collectsAndDedupesInFirstSeenOrder () {
    app.allVertices = new float[3][3]; // nodesOf sizes its `seen` array by allPoints.getLength()
    int[] result = app.Select3D.nodesOf(new int[][]{{2, 0, 1}}, new int[]{0});
    assertArrayEquals(new int[]{2, 0, 1}, result); // preserves the face's own node order, not sorted
  }

  @Test
  void objectsContainingVertices_findsEveryObjectTouchingAnyOfTheGivenVertices () {
    int[] result = app.Select3D.objectsContainingVertices(new int[][]{{0}, {1}, {2}}, new int[]{2, 0});
    assertArrayEquals(new int[]{2, 0}, result); // in the order the source vertices were given
  }

  // ============ softSelectionFunction ==============================

  @Test
  void softSelectionFunction_fallsOffFromOneAtZeroToZeroAtTheRadius () {
    // Defaults: softRadius=2, softPower=1.
    assertEquals(1f, app.Select3D.softSelectionFunction(0), 0.0001f);
    assertEquals((float) Math.cos(Math.toRadians(45)), app.Select3D.softSelectionFunction(1), 0.0001f);
    assertEquals(0f, app.Select3D.softSelectionFunction(2), 0.0001f);   // exactly at the radius
    assertEquals(0f, app.Select3D.softSelectionFunction(5), 0.0001f);   // well past it
  }

  // ============ deselect_* / deselectAll ============================

  @Test
  void deselectAll_clearsEveryCategorysSelection () {
    app.Select3D.LandPoint_ids = new int[]{1};
    app.Select3D.Camera_ids = new int[]{1};
    app.Select3D.Section_ids = new int[]{1};
    app.Select3D.Solid_ids = new int[]{1};
    app.Select3D.Model1D_ids = new int[]{1};
    app.Select3D.Model2D_ids = new int[]{1};
    app.Select3D.Face_ids = new int[]{1};
    app.Select3D.Polyline_ids = new int[]{1};
    app.Select3D.Vertex_ids = new int[]{1};
    app.Select3D.Group_ids = new int[]{1};
    app.Select3D.softSelection_ids = new int[]{1};
    app.Select3D.softSelection_values = new float[]{1};

    app.Select3D.deselectAll();

    assertEquals(0, app.Select3D.LandPoint_ids.length);
    assertEquals(0, app.Select3D.Camera_ids.length);
    assertEquals(0, app.Select3D.Section_ids.length);
    assertEquals(0, app.Select3D.Solid_ids.length);
    assertEquals(0, app.Select3D.Model1D_ids.length);
    assertEquals(0, app.Select3D.Model2D_ids.length);
    assertEquals(0, app.Select3D.Face_ids.length);
    assertEquals(0, app.Select3D.Polyline_ids.length);
    assertEquals(0, app.Select3D.Vertex_ids.length);
    assertEquals(0, app.Select3D.Group_ids.length);
    assertEquals(0, app.Select3D.softSelection_ids.length); // deselect_Vertices cascades into this too
    assertEquals(0, app.Select3D.softSelection_values.length);
  }

  // ============ selectAll / invertSelection / selectLast ===============
  //
  // All three dispatch identically on current_ObjectCategory; FACE and
  // VERTEX are checked directly as representative samples of the
  // pattern (every other category just swaps in a different backing
  // count), plus GROUP for selectLast to vary which field gets touched.

  @Test
  void selectAll_populatesTheCurrentCategorysFullRange () {
    app.allFaces.nodes = new int[][]{{0}, {0}, {0}};
    app.current_ObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.selectAll();
    assertArrayEquals(new int[]{0, 1, 2}, app.Select3D.Face_ids);
  }

  @Test
  void invertSelection_flipsTheCurrentCategorysSelection () {
    app.allFaces.nodes = new int[][]{{0}, {0}, {0}};
    app.current_ObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.Face_ids = new int[]{1};
    app.Select3D.invertSelection();
    assertArrayEquals(new int[]{0, 2}, app.Select3D.Face_ids);
  }

  @Test
  void selectLast_picksTheHighestIndexOfTheCurrentCategory () {
    app.allGroups.makeEmpty(3);
    app.current_ObjectCategory = app.ObjectCategory.GROUP;
    app.Select3D.selectLast();
    assertArrayEquals(new int[]{2}, app.Select3D.Group_ids);
  }

  // ============ convert_* family =====================================

  @Test
  void convertModel1DsToGroups_findsOwningGroups () {
    app.allGroups.makeEmpty(2);
    app.allGroups.Model1Ds[0] = new int[]{0, 1};
    app.allGroups.Model1Ds[1] = new int[]{2, 3};
    app.Select3D.Model1D_ids = new int[]{3};
    app.Select3D.convert_Model1Ds_to_Groups();
    assertArrayEquals(new int[]{1}, app.Select3D.Group_ids);
  }

  @Test
  void convertModel2DsToGroups_findsOwningGroups () {
    app.allGroups.makeEmpty(2);
    app.allGroups.Model2Ds[0] = new int[]{0, 1};
    app.allGroups.Model2Ds[1] = new int[]{2, 3};
    app.Select3D.Model2D_ids = new int[]{3};
    app.Select3D.convert_Model2Ds_to_Groups();
    assertArrayEquals(new int[]{1}, app.Select3D.Group_ids);
  }

  @Test
  void convertSolidsToGroups_findsOwningGroups () {
    app.allGroups.makeEmpty(2);
    app.allGroups.Solids[0] = new int[]{0, 1};
    app.allGroups.Solids[1] = new int[]{2, 3};
    app.Select3D.Solid_ids = new int[]{3};
    app.Select3D.convert_Solids_to_Groups();
    assertArrayEquals(new int[]{1}, app.Select3D.Group_ids);
  }

  @Test
  void convertFacesToGroups_findsOwningGroups () {
    app.allGroups.makeEmpty(2);
    app.allGroups.Faces[0] = new int[]{0, 1};
    app.allGroups.Faces[1] = new int[]{2, 3};
    app.Select3D.Face_ids = new int[]{3};
    app.Select3D.convert_Faces_to_Groups();
    assertArrayEquals(new int[]{1}, app.Select3D.Group_ids);
  }

  @Test
  void convertPolylinesToGroups_findsOwningGroups () {
    app.allGroups.makeEmpty(2);
    app.allGroups.Polylines[0] = new int[]{0, 1};
    app.allGroups.Polylines[1] = new int[]{2, 3};
    app.Select3D.Polyline_ids = new int[]{3};
    app.Select3D.convert_Polylines_to_Groups();
    assertArrayEquals(new int[]{1}, app.Select3D.Group_ids);
  }

  @Test
  void convertVerticesToGroups_findsGroupsWhoseFacesOrPolylinesTouchTheVertex () {
    app.allVertices = new float[6][3];
    app.allFaces.nodes = new int[][]{{5}};
    app.allPolylines.nodes = new int[0][];
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};
    app.allGroups.Polylines[0] = new int[]{0, -1}; // empty range - avoids indexing an empty allPolylines.nodes

    app.Select3D.Vertex_ids = new int[]{5};
    app.Select3D.convert_Vertices_to_Groups();

    assertArrayEquals(new int[]{0}, app.Select3D.Group_ids);
  }

  @Test
  void convertVerticesToFaces_findsFacesTouchingTheVertex () {
    app.allFaces.nodes = new int[][]{{0, 1}, {2}};
    app.Select3D.Vertex_ids = new int[]{2};
    app.Select3D.convert_Vertices_to_Faces();
    assertArrayEquals(new int[]{1}, app.Select3D.Face_ids);
  }

  @Test
  void convertVerticesToPolylines_findsPolylinesTouchingTheVertex () {
    app.allPolylines.nodes = new int[][]{{0, 1}, {2}};
    app.Select3D.Vertex_ids = new int[]{2};
    app.Select3D.convert_Vertices_to_Polylines();
    assertArrayEquals(new int[]{1}, app.Select3D.Polyline_ids);
  }

  @Test
  void convertGroupsToModel1Ds_expandsTheGroupsOwnRange () {
    app.allModel1Ds.f_data = new float[2][11]; // rangeUnion sizes its `seen` array by allModel1Ds.num
    app.allModel1Ds.num = 2;
    app.allGroups.makeEmpty(1);
    app.allGroups.Model1Ds[0] = new int[]{0, 1};
    app.Select3D.Group_ids = new int[]{0};
    app.Select3D.convert_Groups_to_Model1Ds();
    assertArrayEquals(new int[]{0, 1}, app.Select3D.Model1D_ids);
  }

  @Test
  void convertGroupsToModel2Ds_expandsTheGroupsOwnRange () {
    app.allModel2Ds.XYZS = new float[2][4]; // rangeUnion sizes its `seen` array by allModel2Ds.num
    app.allModel2Ds.num = 2;
    app.allGroups.makeEmpty(1);
    app.allGroups.Model2Ds[0] = new int[]{0, 1};
    app.Select3D.Group_ids = new int[]{0};
    app.Select3D.convert_Groups_to_Model2Ds();
    assertArrayEquals(new int[]{0, 1}, app.Select3D.Model2D_ids);
  }

  @Test
  void convertGroupsToSolids_expandsTheGroupsOwnRange () {
    app.allSolids.DEF = new float[2][13]; // rangeUnion sizes its `seen` array by allSolids.DEF.length (no num field)
    app.allGroups.makeEmpty(1);
    app.allGroups.Solids[0] = new int[]{0, 1};
    app.Select3D.Group_ids = new int[]{0};
    app.Select3D.convert_Groups_to_Solids();
    assertArrayEquals(new int[]{0, 1}, app.Select3D.Solid_ids);
  }

  @Test
  void convertGroupsToFaces_expandsTheGroupsOwnRange () {
    app.allFaces.nodes = new int[2][0]; // rangeUnion sizes its `seen` array by allFaces.nodes.length
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 1};
    app.Select3D.Group_ids = new int[]{0};
    app.Select3D.convert_Groups_to_Faces();
    assertArrayEquals(new int[]{0, 1}, app.Select3D.Face_ids);
  }

  @Test
  void convertGroupsToPolylines_expandsTheGroupsOwnRange () {
    app.allPolylines.nodes = new int[2][0]; // rangeUnion sizes its `seen` array by allPolylines.nodes.length
    app.allGroups.makeEmpty(1);
    app.allGroups.Polylines[0] = new int[]{0, 1};
    app.Select3D.Group_ids = new int[]{0};
    app.Select3D.convert_Groups_to_Polylines();
    assertArrayEquals(new int[]{0, 1}, app.Select3D.Polyline_ids);
  }

  @Test
  void convertGroupsToVertices_collectsFromBothTheGroupsFacesAndPolylines () {
    app.allVertices = new float[8][3];
    app.allFaces.nodes = new int[][]{{7}};
    app.allPolylines.nodes = new int[0][];
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};
    app.allGroups.Polylines[0] = new int[]{0, -1}; // empty

    app.Select3D.Group_ids = new int[]{0};
    app.Select3D.convert_Groups_to_Vertices();

    assertArrayEquals(new int[]{7}, app.Select3D.Vertex_ids);
  }

  // convert_Faces_to_Vertices and convert_Polylines_to_Vertices are also
  // exercised as side effects in DeleteGeometryTest.java and
  // ModifyGeometryTest.java, but get their own direct checks here too.

  @Test
  void convertFacesToVertices_collectsTheFacesOwnNodes () {
    app.allVertices = new float[3][3]; // nodesOf sizes its `seen` array by allPoints.getLength()
    app.allFaces.nodes = new int[][]{{2, 0, 1}};
    app.Select3D.Face_ids = new int[]{0};
    app.Select3D.convert_Faces_to_Vertices();
    assertArrayEquals(new int[]{2, 0, 1}, app.Select3D.Vertex_ids);
  }

  @Test
  void convertPolylinesToVertices_collectsThePolylinesOwnNodes () {
    app.allVertices = new float[3][3];
    app.allPolylines.nodes = new int[][]{{2, 0, 1}};
    app.Select3D.Polyline_ids = new int[]{0};
    app.Select3D.convert_Polylines_to_Vertices();
    assertArrayEquals(new int[]{2, 0, 1}, app.Select3D.Vertex_ids);
  }

  @Test
  void convertVertexToSoftSelection_expandsToTheOwningGroupWithDistanceFalloff () {
    // 3 collinear points, increasing distance from the selected one.
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {3, 0, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allPolylines.nodes = new int[0][];
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};
    app.allGroups.Polylines[0] = new int[]{0, -1};

    app.Select3D.Vertex_ids = new int[]{0}; // only point 0 is hard-selected

    app.Select3D.convert_Vertex_to_softSelection();

    // The hard selection is restored to exactly what it was...
    assertArrayEquals(new int[]{0}, app.Select3D.Vertex_ids);

    // ...but the soft selection expanded to the whole owning group (all
    // 3 points), each weighted by softSelectionFunction of its distance
    // to the nearest ORIGINALLY-selected point.
    assertArrayEquals(new int[]{0, 1, 2}, app.Select3D.softSelection_ids);
    assertEquals(1f, app.Select3D.softSelection_values[0], 0.0001f);                          // distance 0
    assertEquals((float) Math.cos(Math.toRadians(45)), app.Select3D.softSelection_values[1], 0.0001f); // distance 1
    assertEquals(0f, app.Select3D.softSelection_values[2], 0.0001f);                           // distance 3, past softRadius=2
  }

  // ============ isolatedVertices_Scene (Select3D's own version) ========
  //
  // Unlike Delete3D.isolatedVertices_Scene (which removes the unused
  // vertices outright), this one only SELECTS them - for the user to
  // review - and does not touch allVertices at all.

  @Test
  void isolatedVerticesScene_selectsUnusedVerticesWithoutDeletingThem () {
    app.allVertices = new float[][]{{0, 0, 0}, {1, 1, 1}, {2, 2, 2}};
    app.allFaces.nodes = new int[][]{{0}}; // only point 0 is used
    app.allPolylines.nodes = new int[0][];

    app.Select3D.isolatedVertices_Scene();

    assertArrayEquals(new int[]{2, 1}, app.Select3D.Vertex_ids); // descending scan order
    assertEquals(3, app.allVertices.length); // nothing was actually removed
  }

  // ============ selectNearVertices ===================================

  @Test
  void selectNearVertices_growsTheSelectionToIncludeNearbyUnselectedVertices () {
    app.allVertices = new float[][]{{0, 0, 0}, {0.05f, 0, 0}, {5, 0, 0}};
    app.User3D.modify_WeldTreshold = 0.1f;
    app.current_ObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.Vertex_ids = new int[]{0}; // only point 0 selected initially

    app.Select3D.selectNearVertices();

    // Point 1 is within the weld threshold of point 0 and gets pulled
    // in; point 2 is far away and is left out.
    int[] result = app.Select3D.Vertex_ids;
    java.util.Arrays.sort(result);
    assertArrayEquals(new int[]{0, 1}, result);
  }

  // ============ selectPick ===========================================

  @Test
  void selectPick_missReturnsEarlyAfterClearingTheSelectionInReplaceMode () {
    app.addNewSelectionToPreviousSelection = 0; // replace mode: clears first
    app.Select3D.Face_ids = new int[]{5};
    app.Select3D.selectPick(new float[]{-1, 0, 0, 0});
    assertEquals(0, app.Select3D.Face_ids.length);
  }

  @Test
  void selectPick_landPointCategoryTogglesTheHitIndexDirectly () {
    app.addNewSelectionToPreviousSelection = 1;
    app.current_ObjectCategory = app.ObjectCategory.LANDPOINT;
    app.Select3D.selectPick(new float[]{7, 0, 0, 0});
    assertArrayEquals(new int[]{7}, app.Select3D.LandPoint_ids);
  }

  @Test
  void selectPick_groupCategoryLooksUpWhichGroupOwnsTheHitFace () {
    app.allGroups.makeEmpty(2);
    app.allGroups.Faces[0] = new int[]{0, 1};
    app.allGroups.Faces[1] = new int[]{2, 3};

    app.addNewSelectionToPreviousSelection = 1;
    app.current_ObjectCategory = app.ObjectCategory.GROUP;
    app.Select3D.selectPick(new float[]{2, 0, 0, 0}); // hit face 2, owned by group 1

    assertArrayEquals(new int[]{1}, app.Select3D.Group_ids);
  }

  @Test
  void selectPick_vertexCategoryPicksTheClosestNodeOfTheHitFace () {
    app.allVertices = new float[][]{{0, 0, 0}, {5, 0, 0}, {10, 0, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};

    app.addNewSelectionToPreviousSelection = 1;
    app.current_ObjectCategory = app.ObjectCategory.VERTEX;
    // Hit face 0 at a point close to vertex 1 (5,0,0).
    app.Select3D.selectPick(new float[]{0, 4.5f, 0, 0});

    assertArrayEquals(new int[]{1}, app.Select3D.Vertex_ids);
  }

  // ============ calculate_BoundingBox ================================

  @Test
  void calculateBoundingBox_computesMinMidMaxForTheSelectedVertices () {
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {10, 0, 0}};
    app.current_ObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.Vertex_ids = new int[]{0, 1, 2};

    app.Select3D.calculate_BoundingBox();

    assertEquals(0f, app.Select3D.BoundingBox[0][0], 0.0001f);  // min
    assertEquals(5f, app.Select3D.BoundingBox[1][0], 0.0001f);  // mid
    assertEquals(10f, app.Select3D.BoundingBox[2][0], 0.0001f); // max
  }

  // ============ saved-bounding-box / origin-reference-box ==============

  @Test
  void saveThenApplySavedBoundingBox_restoresAPreviouslySavedState () {
    // saved_BoundingBox starts out as the SAME array object as
    // Select3D.BoundingBox (see solarchvision_bim.pde's field
    // initializers) - reassigning BoundingBox to a fresh array here
    // breaks that aliasing, which is what makes "save now, mutate
    // later, restore" a meaningful round trip instead of a no-op.
    app.Select3D.BoundingBox = new float[][]{
      {0, 0, 0, 1, 1, 1, 0, 0, 0},
      {5, 5, 5, 1, 1, 1, 0, 0, 0},
      {10, 10, 10, 1, 1, 1, 0, 0, 0}
    };
    app.Select3D.alignX = 1;

    app.Select3D.save_current_BoundingBox();

    app.Select3D.BoundingBox[1][0] = 999; // mutate after saving
    app.Select3D.alignX = 0;

    app.Select3D.apply_saved_BoundingBox();

    assertEquals(5f, app.Select3D.BoundingBox[1][0], 0.0001f); // restored, not 999
    assertEquals(1, app.Select3D.alignX); // alignment restored too
  }

  @Test
  void applyOriginReferenceBox_resetsToAnIdentityBoxAtTheOrigin () {
    app.Select3D.BoundingBox = new float[][]{
      {1, 2, 3, 4, 5, 6, 7, 8, 9},
      {1, 2, 3, 4, 5, 6, 7, 8, 9},
      {1, 2, 3, 4, 5, 6, 7, 8, 9}
    };

    app.Select3D.apply_origin_ReferenceBox();

    for (float[] row : app.Select3D.BoundingBox) {
      assertArrayEquals(new float[]{0, 0, 0, 1, 1, 1, 0, 0, 0}, row, 0.0001f);
    }
  }

  @Test
  void resetSelectedRefValues_zeroesThePosRotScaleValues () {
    app.Select3D.posValue = 5;
    app.Select3D.rotValue = 10;
    app.Select3D.scaleValue = 2;
    app.Select3D.reset_selectedRefValues();
    assertEquals(0f, app.Select3D.posValue, 0.0001f);
    assertEquals(0f, app.Select3D.rotValue, 0.0001f);
    assertEquals(0f, app.Select3D.scaleValue, 0.0001f);
  }

  // ============ translateInside / translateOutside ReferencePivot =====

  @Test
  void translateOutsideThenInside_roundTripsBackToTheOriginalPoint () {
    app.Select3D.BoundingBox[1] = new float[]{5, 10, 15, 2, 3, 4, 30, 45, 60};

    float[] outside = app.Select3D.translateOutside_ReferencePivot(1, 2, 3);
    float[] back = app.Select3D.translateInside_ReferencePivot(outside[0], outside[1], outside[2]);

    assertArrayEquals(new float[]{1, 2, 3}, back, 0.001f);
  }

  // ============ getPivot ============================================

  @Test
  void getPivot_returnsTheWorldSpacePositionOfTheAlignedCorner () {
    // With no rotation and unit scale, aligning to the max corner
    // should give back exactly that corner's own world coordinates.
    app.Select3D.BoundingBox = new float[][]{
      {0, 0, 0, 1, 1, 1, 0, 0, 0},   // min
      {5, 5, 5, 1, 1, 1, 0, 0, 0},   // mid
      {10, 10, 10, 1, 1, 1, 0, 0, 0} // max
    };
    app.Select3D.alignX = 1;
    app.Select3D.alignY = 1;
    app.Select3D.alignZ = 1;

    float[] pivot = app.Select3D.getPivot();

    assertArrayEquals(new float[]{10, 10, 10}, pivot, 0.001f);
  }

  // ============ get_Face_Vertices / get_Polyline_Vertices / get_Group_Vertices ====

  @Test
  void getFaceVertices_collectsAndDedupesFromEverySelectedFace () {
    app.allVertices = new float[3][3]; // this function sizes `seen` by allPoints.getLength()
    app.allFaces.nodes = new int[][]{{0, 1}, {1, 2}};
    app.Select3D.Face_ids = new int[]{0, 1};
    int[] result = app.Select3D.get_Face_Vertices();
    java.util.Arrays.sort(result);
    assertArrayEquals(new int[]{0, 1, 2}, result);
  }

  @Test
  void getPolylineVertices_collectsAndDedupesFromEverySelectedPolyline () {
    app.allVertices = new float[3][3];
    app.allPolylines.nodes = new int[][]{{0, 1}, {1, 2}};
    app.Select3D.Polyline_ids = new int[]{0, 1};
    int[] result = app.Select3D.get_Polyline_Vertices();
    java.util.Arrays.sort(result);
    assertArrayEquals(new int[]{0, 1, 2}, result);
  }

  @Test
  void getGroupVertices_collectsFromBothTheGroupsFacesAndPolylines () {
    app.allVertices = new float[2][3];
    app.allFaces.nodes = new int[][]{{0}};
    app.allPolylines.nodes = new int[][]{{1}};
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};
    app.allGroups.Polylines[0] = new int[]{0, 0};

    app.Select3D.Group_ids = new int[]{0};
    int[] result = app.Select3D.get_Group_Vertices();
    java.util.Arrays.sort(result);

    assertArrayEquals(new int[]{0, 1}, result);
  }
}
