import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class GroupsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= makeEmpty ========================================

  @Test
  void makeEmpty_resetsEveryArrayToTheGivenLength () {
    app.allGroups.makeEmpty(3);

    assertEquals(3, app.allGroups.num);
    assertEquals(3, app.allGroups.Faces.length);
    assertEquals(3, app.allGroups.Polylines.length);
    assertEquals(3, app.allGroups.Model1Ds.length);
    assertEquals(3, app.allGroups.Model2Ds.length);
    assertEquals(3, app.allGroups.Solids.length);
    assertEquals(3, app.allGroups.Pivots.length);
    assertEquals(9, app.allGroups.Pivots[0].length);
  }

  // ================= getters' degenerate-empty-array fallback ==========

  @Test
  void getters_fallBackToASafeDefaultWhenTheWholeArrayIsEmpty () {
    // The guard is on the ARRAY's length, not on whether the given index
    // n is valid - it only protects the fully-empty-array case, not an
    // out-of-range n on a non-empty array.
    app.allGroups.Faces = new int[0][2];
    assertEquals(0, app.allGroups.getStart_Face(0));
    assertEquals(-1, app.allGroups.getStop_Face(0));
  }

  @Test
  void gettersAndSetters_roundTripNormally () {
    app.allGroups.makeEmpty(1);
    app.allGroups.setStart_Face(0, 3);
    app.allGroups.setStop_Face(0, 7);
    assertEquals(3, app.allGroups.getStart_Face(0));
    assertEquals(7, app.allGroups.getStop_Face(0));
  }

  // ================= inserted_nFaces ==================================

  @Test
  void insertedNFaces_shiftsLaterGroupsAndGrowsTheOwningGroupsOwnRange () {
    app.allGroups.makeEmpty(2);
    app.allGroups.Faces[0] = new int[]{0, 1};
    app.allGroups.Faces[1] = new int[]{2, 3};
    app.Select3D.Face_ids = new int[]{0, 5};

    app.allGroups.inserted_nFaces(0, 0, 3); // group 0 grew by 3 new faces at/after face 0

    assertArrayEquals(new int[]{0, 4}, app.allGroups.Faces[0]); // its own stop grows by 3
    assertArrayEquals(new int[]{5, 6}, app.allGroups.Faces[1]); // entirely after: both shift by 3

    // Face_ids: 0 is not > fromFace(0), so it's untouched; 5 is, so it shifts.
    assertArrayEquals(new int[]{0, 8}, app.Select3D.Face_ids);
  }

  // ================= beginNewGroup ====================================

  @Test
  void beginNewGroup_appendsARowToEveryArrayUsingCurrentSceneCounts () {
    app.allModel1Ds.num = 2;
    app.allModel2Ds.num = 3;
    app.allSolids.DEF = new float[4][13];
    app.allFaces.nodes = new int[5][0];
    app.allPolylines.nodes = new int[6][0];

    int newId = app.allGroups.beginNewGroup(1, 2, 3, 4, 5, 6, 7, 8, 9);

    assertEquals(0, newId); // first group created
    assertEquals(1, app.allGroups.num);
    assertArrayEquals(new float[]{1, 2, 3, 4, 5, 6, 7, 8, 9}, app.allGroups.Pivots[0], 0.0001f);
    // Every range starts as "empty" (start > stop), anchored at the
    // CURRENT count of its own object type.
    assertArrayEquals(new int[]{2, -1}, app.allGroups.Model1Ds[0]);
    assertArrayEquals(new int[]{3, -1}, app.allGroups.Model2Ds[0]);
    assertArrayEquals(new int[]{4, -1}, app.allGroups.Solids[0]);
    assertArrayEquals(new int[]{5, -1}, app.allGroups.Faces[0]);
    assertArrayEquals(new int[]{6, -1}, app.allGroups.Polylines[0]);
  }

  // ================= findGroupContainingFace ===========================

  @Test
  void findGroupContainingFace_returnsTheOwningGroupsIndex () {
    app.allGroups.makeEmpty(2);
    app.allGroups.Faces[0] = new int[]{0, 1};
    app.allGroups.Faces[1] = new int[]{2, 5};

    assertEquals(0, app.allGroups.findGroupContainingFace(0));
    assertEquals(1, app.allGroups.findGroupContainingFace(3));
  }

  @Test
  void findGroupContainingFace_defaultsToGroupZeroWhenNoGroupOwnsTheFace () {
    // Not a sentinel like -1 - a genuinely unowned face id still reports
    // group 0, since OBJ_ID is only ever updated on an actual match.
    app.allGroups.makeEmpty(2);
    app.allGroups.Faces[0] = new int[]{0, 1};
    app.allGroups.Faces[1] = new int[]{2, 3};

    assertEquals(0, app.allGroups.findGroupContainingFace(99));
  }

  // ================= group_Selection (full integration tests) =========

  @Test
  void groupSelection_faceCategoryClonesVerticesIntoANewGroupAndDeletesTheOriginalFace () {
    // group_Selection doesn't just group the ORIGINAL selected face - it
    // clones it (and its vertices) into the new group, then deletes the
    // original via Delete3D.selection(). That deletion goes further than
    // just removing the face, though: Delete3D.selection() also runs
    // isolatedVertices_Selection() afterward for the FACE category,
    // which sweeps up the now-orphaned ORIGINAL vertices (computed via
    // convert_Faces_to_Vertices() before the delete) and renumbers the
    // surviving clone's node references down accordingly. Net effect:
    // only 2 vertices survive overall (the clones, renumbered to 0/1),
    // not 4 - verified by fully simulating the sequence in Python before
    // writing these assertions, not by hand-tracing alone.
    app.allVertices = new float[][]{{1, 1, 1}, {2, 2, 2}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};

    app.current_ObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.Face_ids = new int[]{0};

    app.allGroups.group_Selection(1); // 1 = create a new group

    assertEquals(1, app.allGroups.num);
    assertEquals(1, app.allFaces.nodes.length); // the original was deleted, only the clone remains

    assertEquals(2, app.allVertices.length); // the orphaned originals were swept up too
    assertArrayEquals(new int[]{0, 1}, app.allFaces.nodes[0]); // renumbered down to the surviving pair
    assertArrayEquals(new float[]{1, 1, 1}, app.allVertices[0], 0.0001f); // same coordinates as the originals
    assertArrayEquals(new float[]{2, 2, 2}, app.allVertices[1], 0.0001f); // (it's a geometry-preserving clone)

    assertArrayEquals(new int[]{0, 0}, app.allGroups.Faces[0]); // shrunk back down after the delete

    assertEquals(app.ObjectCategory.GROUP, app.current_ObjectCategory); // switched category
    assertArrayEquals(new int[]{0}, app.Select3D.Group_ids); // the new group is now selected
  }

  @Test
  void groupSelection_solidCategoryClonesTheSolidIntoANewGroupAndDeletesTheOriginal () {
    app.allSolids.DEF = new float[][]{new float[13]};
    app.allSolids.DEF[0][0] = 5; // posX

    app.current_ObjectCategory = app.ObjectCategory.SOLID;
    app.Select3D.Solid_ids = new int[]{0};

    app.allGroups.group_Selection(1);

    assertEquals(1, app.allGroups.num);
    assertEquals(1, app.allSolids.DEF.length); // original deleted, clone remains
    assertEquals(5f, app.allSolids.DEF[0][0], 0.0001f); // clone carries the same position
    assertArrayEquals(new int[]{0, 0}, app.allGroups.Solids[0]);
    assertEquals(app.ObjectCategory.GROUP, app.current_ObjectCategory);
  }

  // ================= ungroup_Selection ================================

  @Test
  void ungroupSelection_disconnectsOwnershipButLeavesTheObjectsThemselvesIntact () {
    app.allFaces.nodes = new int[][]{{0}, {0}, {0}};

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 2}; // owns all 3 faces

    app.current_ObjectCategory = app.ObjectCategory.GROUP;
    app.Select3D.Group_ids = new int[]{0};

    app.allGroups.ungroup_Selection();

    assertEquals(0, app.allGroups.num); // the group wrapper itself is gone
    assertEquals(3, app.allFaces.nodes.length); // but the 3 faces are untouched
  }

  // ================= dettachFromGroups_Selection ========================

  @Test
  void dettachFromGroupsSelection_replacesTheSelectionWithAnUngroupedClone () {
    // group_Selection(1) then immediately ungroup_Selection(): net effect
    // is the selected solid gets replaced by an identical clone that
    // belongs to no group at all.
    app.allSolids.DEF = new float[][]{new float[13]};
    app.allSolids.DEF[0][0] = 5;

    app.current_ObjectCategory = app.ObjectCategory.SOLID;
    app.Select3D.Solid_ids = new int[]{0};

    app.allGroups.dettachFromGroups_Selection();

    assertEquals(0, app.allGroups.num); // no group survives
    assertEquals(1, app.allSolids.DEF.length); // the clone survives, ungrouped
    assertEquals(5f, app.allSolids.DEF[0][0], 0.0001f);
  }

  // ================= deleteEmptyGroups_Scene ===========================

  @Test
  void deleteEmptyGroupsScene_removesOnlyGroupsWithNoOwnedObjectsAndRestoresTheCategory () {
    app.allFaces.nodes = new int[][]{{0}};

    app.allGroups.makeEmpty(2);
    app.allGroups.Faces[0] = new int[]{0, 0};      // group 0: owns a face - not empty
    app.allGroups.Polylines[0] = new int[]{0, -1}; // explicitly empty otherwise, so the
    app.allGroups.Model1Ds[0] = new int[]{0, -1};  // face ownership above is unambiguously
    app.allGroups.Model2Ds[0] = new int[]{0, -1};  // the only reason group 0 survives
    app.allGroups.Solids[0] = new int[]{0, -1};
    app.allGroups.Faces[1] = new int[]{0, -1};      // group 1: nothing owned at all - empty
    app.allGroups.Polylines[1] = new int[]{0, -1};
    app.allGroups.Model1Ds[1] = new int[]{0, -1};
    app.allGroups.Model2Ds[1] = new int[]{0, -1};
    app.allGroups.Solids[1] = new int[]{0, -1};

    app.current_ObjectCategory = app.ObjectCategory.FACE; // deliberately not GROUP

    app.allGroups.deleteEmptyGroups_Scene();

    assertEquals(1, app.allGroups.num); // only group 0 survives
    assertEquals(app.ObjectCategory.FACE, app.current_ObjectCategory); // restored, not left at GROUP
  }

  // ================= to_XML / from_XML round trip ======================

  @Test
  void toXMLThenFromXML_roundTripsEveryRangeAndThePivot () {
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{1, 2};
    app.allGroups.Polylines[0] = new int[]{3, 4};
    app.allGroups.Model1Ds[0] = new int[]{5, 6};
    app.allGroups.Model2Ds[0] = new int[]{7, 8};
    app.allGroups.Solids[0] = new int[]{9, 10};
    app.allGroups.Pivots[0] = new float[]{1, 2, 3, 4, 5, 6, 7, 8, 9};

    processing.data.XML root = new processing.data.XML("root");
    app.allGroups.to_XML(root);

    solarchvision_bim.solarchvision_Groups fresh = app.new solarchvision_Groups();
    fresh.from_XML(root);

    assertEquals(1, fresh.num);
    assertArrayEquals(new int[]{1, 2}, fresh.Faces[0]);
    assertArrayEquals(new int[]{3, 4}, fresh.Polylines[0]);
    assertArrayEquals(new int[]{5, 6}, fresh.Model1Ds[0]);
    assertArrayEquals(new int[]{7, 8}, fresh.Model2Ds[0]);
    assertArrayEquals(new int[]{9, 10}, fresh.Solids[0]);
    assertArrayEquals(new float[]{1, 2, 3, 4, 5, 6, 7, 8, 9}, fresh.Pivots[0], 0.0001f);
  }

  // ================= more getter/setter round trips ====================

  @Test
  void gettersAndSetters_roundTripForPolylineAndModel1D () {
    app.allGroups.makeEmpty(1);
    app.allGroups.setStart_Polyline(0, 2);
    app.allGroups.setStop_Polyline(0, 6);
    assertEquals(2, app.allGroups.getStart_Polyline(0));
    assertEquals(6, app.allGroups.getStop_Polyline(0));

    app.allGroups.setStart_Model1D(0, 1);
    app.allGroups.setStop_Model1D(0, 9);
    assertEquals(1, app.allGroups.getStart_Model1D(0));
    assertEquals(9, app.allGroups.getStop_Model1D(0));
  }

  // ================= group_Selection: more categories ==================

  @Test
  void groupSelection_polylineCategoryClonesVerticesTheSameWayFacesDoes () {
    app.allVertices = new float[][]{{1, 1, 1}, {2, 2, 2}};
    app.allPolylines.nodes = new int[][]{{0, 1}};
    app.allPolylines.options = new int[][]{{0, 0, 0, 0, 0, 0}};

    app.current_ObjectCategory = app.ObjectCategory.POLYLINE;
    app.Select3D.Polyline_ids = new int[]{0};

    app.allGroups.group_Selection(1);

    assertEquals(1, app.allGroups.num);
    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(2, app.allVertices.length); // orphaned originals swept up, same as the Faces case
    assertArrayEquals(new int[]{0, 1}, app.allPolylines.nodes[0]);
    assertArrayEquals(new int[]{0, 0}, app.allGroups.Polylines[0]);
  }

  @Test
  void groupSelection_model1DCategoryClonesAttributesWithNoVertexInvolvement () {
    app.allModel1Ds.f_data = new float[][]{{5, 0, 0, 2, 10, 0, 0, 0, 0, 0, 0}};
    app.allModel1Ds.i_data = new int[][]{{1, 2, 3}};
    app.allModel1Ds.num = 1;

    app.current_ObjectCategory = app.ObjectCategory.MODEL1D;
    app.Select3D.Model1D_ids = new int[]{0};

    app.allGroups.group_Selection(1);

    assertEquals(1, app.allGroups.num);
    assertEquals(1, app.allModel1Ds.num); // original deleted, clone remains
    assertEquals(5f, app.allModel1Ds.getX(0), 0.0001f);
    assertEquals(10f, app.allModel1Ds.getRotation(0), 0.0001f);
    assertArrayEquals(new int[]{0, 0}, app.allGroups.Model1Ds[0]);
  }

  @Test
  void groupSelection_model2DCategoryClonesPositionAndPreservesTreeFamily () {
    app.allModel2Ds.XYZS = new float[][]{{5, 0, 0, 2}};
    app.allModel2Ds.MAP = new int[]{3}; // abs(3) > num_files_PEOPLE(0) -> a tree
    app.allModel2Ds.num = 1;

    app.current_ObjectCategory = app.ObjectCategory.MODEL2D;
    app.Select3D.Model2D_ids = new int[]{0};

    app.allGroups.group_Selection(1);

    assertEquals(1, app.allGroups.num);
    assertEquals(1, app.allModel2Ds.num);
    assertEquals(5f, app.allModel2Ds.getX(0), 0.0001f);
    // create()'s own internal +/-1 sign roll on MAP means only the
    // magnitude (and therefore the tree/person family) is guaranteed,
    // same caveat as Clone3DTest's cloneModel2D tests.
    assertTrue(app.allModel2Ds.isTree(app.allModel2Ds.MAP[0]));
    assertArrayEquals(new int[]{0, 0}, app.allGroups.Model2Ds[0]);
  }

  @Test
  void groupSelection_createNewGroupZeroAddsToTheExistingLastGroupInstead () {
    // With createNewGroup=0, beginNewGroup() is skipped entirely - the
    // clone gets auto-extended into whatever the CURRENT last group is,
    // rather than a fresh one being created. Verified by allGroups.num
    // staying at 1 throughout, not growing to 2.
    app.allSolids.DEF = new float[][]{new float[13]};
    app.allSolids.DEF[0][0] = 5;

    app.allGroups.makeEmpty(1); // a pre-existing group, with nothing owned yet
    app.allGroups.Solids[0] = new int[]{0, -1};

    app.current_ObjectCategory = app.ObjectCategory.SOLID;
    app.Select3D.Solid_ids = new int[]{0};

    app.allGroups.group_Selection(0); // 0 = add to the last group, don't create a new one

    assertEquals(1, app.allGroups.num); // unchanged - no new group
    assertEquals(1, app.allSolids.DEF.length);
    assertEquals(5f, app.allSolids.DEF[0][0], 0.0001f);
    assertArrayEquals(new int[]{0, 0}, app.allGroups.Solids[0]); // the pre-existing group now owns the clone
  }

  @Test
  void groupSelection_isANoOpForACategoryWithNoGroupingBehaviorAtAll () {
    // VERTEX (and LANDPOINT/GROUP/POLYLINE... only SOLID/FACE/POLYLINE/
    // MODEL1D/MODEL2D actually run_process) - VERTEX specifically has no
    // clone-into-group branch at all.
    app.current_ObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.Vertex_ids = new int[]{0};

    app.allGroups.group_Selection(1);

    assertEquals(0, app.allGroups.num); // nothing created
    assertEquals(app.ObjectCategory.VERTEX, app.current_ObjectCategory); // never switched to GROUP
  }

  // ================= ungroup_Selection: no-op case =====================

  @Test
  void ungroupSelection_isANoOpWhenTheCurrentCategoryIsNotGroup () {
    app.allFaces.nodes = new int[][]{{0}, {0}, {0}};
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 2};

    app.current_ObjectCategory = app.ObjectCategory.FACE; // not GROUP
    app.Select3D.Group_ids = new int[]{0};

    app.allGroups.ungroup_Selection();

    assertEquals(1, app.allGroups.num); // untouched
    assertArrayEquals(new int[]{0, 2}, app.allGroups.Faces[0]); // untouched
  }

  // ================= deleteEmptyGroups_Scene: edge cases ===============

  @Test
  void deleteEmptyGroupsScene_deletesEveryGroupWhenAllAreEmpty () {
    app.allGroups.makeEmpty(2);
    for (int g = 0; g < 2; g++) {
      app.allGroups.Faces[g] = new int[]{0, -1};
      app.allGroups.Polylines[g] = new int[]{0, -1};
      app.allGroups.Model1Ds[g] = new int[]{0, -1};
      app.allGroups.Model2Ds[g] = new int[]{0, -1};
      app.allGroups.Solids[g] = new int[]{0, -1};
    }

    app.allGroups.deleteEmptyGroups_Scene();

    assertEquals(0, app.allGroups.num);
  }

  @Test
  void deleteEmptyGroupsScene_keepsEveryGroupWhenNoneAreEmpty () {
    app.allFaces.nodes = new int[][]{{0}, {0}};
    app.allGroups.makeEmpty(2);
    app.allGroups.Faces[0] = new int[]{0, 0};
    app.allGroups.Faces[1] = new int[]{1, 1};
    for (int g = 0; g < 2; g++) {
      app.allGroups.Polylines[g] = new int[]{0, -1};
      app.allGroups.Model1Ds[g] = new int[]{0, -1};
      app.allGroups.Model2Ds[g] = new int[]{0, -1};
      app.allGroups.Solids[g] = new int[]{0, -1};
    }

    app.allGroups.deleteEmptyGroups_Scene();

    assertEquals(2, app.allGroups.num);
  }

  // ================= remaining getter/setter pairs (Solid, Model2D) =====

  @Test
  void gettersAndSetters_roundTripForSolidAndModel2D () {
    app.allGroups.makeEmpty(1);
    app.allGroups.setStart_Solid(0, 4);
    app.allGroups.setStop_Solid(0, 8);
    assertEquals(4, app.allGroups.getStart_Solid(0));
    assertEquals(8, app.allGroups.getStop_Solid(0));

    app.allGroups.setStart_Model2D(0, 3);
    app.allGroups.setStop_Model2D(0, 11);
    assertEquals(3, app.allGroups.getStart_Model2D(0));
    assertEquals(11, app.allGroups.getStop_Model2D(0));
  }

  // ================= degenerate-empty-array fallback: every type =======
  //
  // The Face case is covered above; these confirm the other 4 getter
  // pairs share the exact same guard (on the ARRAY's own length, not on
  // whether the given index is valid) rather than assuming it from the
  // Face case alone.

  @Test
  void getters_fallBackToASafeDefaultForEveryRemainingType () {
    app.allGroups.Polylines = new int[0][2];
    assertEquals(0, app.allGroups.getStart_Polyline(0));
    assertEquals(-1, app.allGroups.getStop_Polyline(0));

    app.allGroups.Solids = new int[0][2];
    assertEquals(0, app.allGroups.getStart_Solid(0));
    assertEquals(-1, app.allGroups.getStop_Solid(0));

    app.allGroups.Model1Ds = new int[0][2];
    assertEquals(0, app.allGroups.getStart_Model1D(0));
    assertEquals(-1, app.allGroups.getStop_Model1D(0));

    app.allGroups.Model2Ds = new int[0][2];
    assertEquals(0, app.allGroups.getStart_Model2D(0));
    assertEquals(-1, app.allGroups.getStop_Model2D(0));
  }

  // ================= dettachFromGroups_Selection: a second category =====

  @Test
  void dettachFromGroupsSelection_faceCategoryLeavesAnUngroupedClonedFaceBehind () {
    // Combines group_Selection(1)'s clone-then-cleanup behavior (already
    // verified above) with ungroup_Selection's ownership-only reset: the
    // cloned, renumbered face and its 2 vertices survive, but end up
    // owned by no group at all.
    app.allVertices = new float[][]{{1, 1, 1}, {2, 2, 2}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};

    app.current_ObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.Face_ids = new int[]{0};

    app.allGroups.dettachFromGroups_Selection();

    assertEquals(0, app.allGroups.num); // no group survives
    assertEquals(1, app.allFaces.nodes.length); // the cloned face survives
    assertArrayEquals(new int[]{0, 1}, app.allFaces.nodes[0]);
    assertEquals(2, app.allVertices.length);
    assertArrayEquals(new float[]{1, 1, 1}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{2, 2, 2}, app.allVertices[1], 0.0001f);
  }
}
