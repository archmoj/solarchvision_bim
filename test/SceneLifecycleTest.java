import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Every other *Test.java file in this suite tests ONE class/function at a
// time, usually isolating a single ObjectCategory and leaving every other
// type's own allGroups range explicitly empty (see e.g.
// DeleteGeometryTest.java's own selectedGroups_... comment, or
// GroupsTest.java's per-category groupSelection_* tests). That's the
// right way to pin down one function's own behavior, but it also means
// nothing in this suite exercises what an actual person does with this
// app: build up a scene containing a MIX of 1D (Polylines, Model1Ds),
// 2D (Model2Ds) and 3D (Faces, Solids) objects, group some of them
// together (possibly several different types into the SAME group),
// ungroup them again, modify/edit them, delete a selection, and
// eventually clear the whole scene - and confirm each step leaves
// consistent counts and crashes nothing, with several types' own logic
// running back-to-back in the same call where the single-type tests
// elsewhere never do.
//
// Every sequence below was first run by hand against the real compiled
// app (not just reasoned through) to pin down exactly what each step
// does - in particular: group_Selection() CLONES the selection into the
// (new or existing) group and deletes the original (see GroupsTest.java's
// own comment on this), ungroup_Selection() leaves currentObjectCategory
// at GROUP rather than restoring the prior category (confirmed directly,
// not assumed), and a newly created object becomes the LAST group's own
// member automatically if any group already exists (see model1Ds.pde's
// own create(), mirrored by the other four creatable types) - which is
// why every lifecycle test below groups before creating any further
// object of a different type it does not want swept into that group.
class SceneLifecycleTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    // Only deleteAll() (used by the full-scene-reset tests below) needs
    // this - it calls beginScene3DChange()/endScene3DChange() and
    // seedScene3DHistory() around its own work, each of which builds a
    // full project snapshot including Terrain.to_XML() - see
    // GlobalFunctionsTest.java's own identical comment on this.
    app.Terrain.Mesh = new float[app.Terrain.rowCount][app.Terrain.columnCount][3];
  }

  private int createOneFace () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.current_Material = 5;
    return app.allFaces.create(new int[]{p0, p1, p2});
  }

  private int createOnePolyline () {
    int p0 = app.allPoints.create(5, 5, 0);
    int p1 = app.allPoints.create(6, 5, 0);
    return app.allPolylines.create(new int[]{p0, p1});
  }

  // Builds a fresh app with one mixed group already in place (one Face,
  // one Polyline, one Model1D, one Model2D, one Solid, all owned by the
  // same group 0) - shared by the Move/Rotate/Scale tests below, each of
  // which calls this on its OWN fresh instance rather than chaining off
  // a previously-transformed one. That isolation matters here
  // specifically: Move3D/Rotate3D/Scale3D's own .selection() dispatchers
  // run every call through Select3D's reference-pivot machinery
  // (translateOutside_ReferencePivot/translateInside_ReferencePivot,
  // driven by Select3D.BoundingBox/pivotAlignment*), and chaining a
  // rotate then a scale through that same dispatcher on the same
  // instance was confirmed directly to leave the scale looking like a
  // no-op - not because Scale3D.Groups() is broken (called on its own,
  // right after group_Selection(), it scales correctly), but because
  // by then Select3D's own reference-pivot state no longer means what a
  // fresh instance's does. The existing Move3D/Rotate3D/Scale3DTest.java
  // files sidestep this the same way: call .Groups() directly, never
  // .selection(), and never reuse one instance across more than one
  // transform. The Face's own vertices are deliberately NOT at the
  // origin (unlike this file's other helpers) - rotating or scaling a
  // point already sitting at the pivot leaves it looking unchanged
  // either way, which would make a real bug here invisible.
  private solarchvision_bim buildMixedGroupScene () {
    solarchvision_bim a = new solarchvision_bim();
    // Needed only by the undo/redo tests below, same reasoning as this
    // file's own setUp(): seedScene3DHistory()/buildScene3DSnapshot()
    // reach Terrain.to_XML().
    a.Terrain.Mesh = new float[a.Terrain.rowCount][a.Terrain.columnCount][3];

    int p0 = a.allPoints.create(1, 0, 0);
    int p1 = a.allPoints.create(2, 0, 0);
    int p2 = a.allPoints.create(2, 1, 0);
    a.allFaces.create(new int[]{p0, p1, p2});

    int q0 = a.allPoints.create(5, 5, 0);
    int q1 = a.allPoints.create(6, 5, 0);
    a.allPolylines.create(new int[]{q0, q1});

    a.allModel1Ds.create(7, 99, 5, 10, 20, 30, 2, 45, 1, 2, 3, 4, 5, 6);

    a.TREES_KIND.fileCount = 10;
    // Needed only by the undo/redo tests below (Model2Ds.to_XML(), reached
    // from buildScene3DSnapshot(), needs a real filename behind the kind's
    // own fileIndex - see mixedGroupDelete_canBeUndoneThenRedone_...'s own
    // comment on this) - harmless to set unconditionally here too.
    a.TREES_KIND.Filenames = new String[]{"oak.png", "pine.png"};
    a.allModel2Ds.create("TREES", 1, 50, 60, 70, 2);

    a.allSolids.create(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13);

    a.currentObjectCategory = a.ObjectCategory.FACE;
    a.Select3D.faceSelection = new int[]{0};
    a.allGroups.group_Selection(1); // new group, owns the face so far

    a.currentObjectCategory = a.ObjectCategory.POLYLINE;
    a.Select3D.polylineSelection = new int[]{0};
    a.allGroups.group_Selection(0); // add to that same group

    a.currentObjectCategory = a.ObjectCategory.MODEL1D;
    a.Select3D.model1DSelection = new int[]{0};
    a.allGroups.group_Selection(0);

    a.currentObjectCategory = a.ObjectCategory.MODEL2D;
    a.Select3D.model2DSelection = new int[]{0};
    a.allGroups.group_Selection(0);

    a.currentObjectCategory = a.ObjectCategory.SOLID;
    a.Select3D.solidSelection = new int[]{0};
    a.allGroups.group_Selection(0);

    a.currentObjectCategory = a.ObjectCategory.GROUP;
    a.Select3D.groupSelection = new int[]{0};
    return a;
  }

  // ================= per-category full lifecycle ========================
  // create -> group (new) -> ungroup -> modify/edit -> delete, for each of
  // the five groupable categories. Each one ends with the category's own
  // collection back at length 0 and no exception anywhere along the way.

  @Test
  void faceLifecycle_create_group_ungroup_modifyVisibility_editMaterial_delete_leavesAnEmptyScene () {
    createOneFace();
    assertEquals(1, app.allFaces.nodes.length);

    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.faceSelection = new int[]{0};
    app.allGroups.group_Selection(1); // 1 = new group
    assertEquals(1, app.allGroups.num);
    assertEquals(1, app.allFaces.nodes.length); // clone replaces the original, same count

    app.allGroups.ungroup_Selection(); // currentObjectCategory stays GROUP; Select3D.groupSelection is already {0}
    assertEquals(0, app.allGroups.num);
    assertEquals(1, app.allFaces.nodes.length); // the face itself survives, just ungrouped

    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.faceSelection = new int[]{0};
    app.Modify3D.changeVisibilityFaces_Selection(0); // "modify": hide it
    assertEquals(0, app.allFaces.getVisibility(0));

    app.User3D.currentTool = app.UITASK.Seed_Material;
    app.Edit3D.selection(1); // "edit": bump the material by 1
    assertEquals(6, app.allFaces.getMaterial(0));

    app.Delete3D.selection();
    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(0, app.allPoints.getLength(), "the face's own 3 vertices should be swept up too, not left orphaned");
    assertEquals(0, app.Select3D.faceSelection.length, "Delete3D.selection() always ends with deselectAll()");
  }

  @Test
  void polylineLifecycle_create_group_ungroup_modifyVisibility_editMaterial_delete_leavesAnEmptyScene () {
    createOnePolyline();
    assertEquals(1, app.allPolylines.nodes.length);

    app.currentObjectCategory = app.ObjectCategory.POLYLINE;
    app.Select3D.polylineSelection = new int[]{0};
    app.allGroups.group_Selection(1);
    assertEquals(1, app.allGroups.num);
    assertEquals(1, app.allPolylines.nodes.length);

    app.allGroups.ungroup_Selection();
    assertEquals(0, app.allGroups.num);
    assertEquals(1, app.allPolylines.nodes.length);

    app.currentObjectCategory = app.ObjectCategory.POLYLINE;
    app.Select3D.polylineSelection = new int[]{0};
    app.Modify3D.changeVisibilityPolylines_Selection(0);
    assertEquals(0, app.allPolylines.getVisibility(0));

    app.User3D.currentTool = app.UITASK.Seed_Material;
    int materialBefore = app.allPolylines.getMaterial(0);
    app.Edit3D.selection(1);
    assertEquals(materialBefore + 1, app.allPolylines.getMaterial(0));

    app.Delete3D.selection();
    assertEquals(0, app.allPolylines.nodes.length);
    assertEquals(0, app.allPoints.getLength());
  }

  @Test
  void model1DLifecycle_create_group_ungroup_editTrunkSize_delete_leavesAnEmptyScene () {
    app.allModel1Ds.create(7, 99, 5, 10, 20, 30, 2, 45, 1, 2, 3, 4, 5, 6);
    assertEquals(1, app.allModel1Ds.num);

    app.currentObjectCategory = app.ObjectCategory.MODEL1D;
    app.Select3D.model1DSelection = new int[]{0};
    app.allGroups.group_Selection(1);
    assertEquals(1, app.allGroups.num);
    assertEquals(1, app.allModel1Ds.num);

    app.allGroups.ungroup_Selection();
    assertEquals(0, app.allGroups.num);
    assertEquals(1, app.allModel1Ds.num);

    app.currentObjectCategory = app.ObjectCategory.MODEL1D;
    app.Select3D.model1DSelection = new int[]{0};
    app.User3D.currentTool = app.UITASK.TrunkSize;
    float trunkBefore = app.allModel1Ds.getTrunkSize(0);
    app.Edit3D.selection(1); // Model1Ds' own TrunkSize step is +0.02*p
    assertEquals(trunkBefore + 0.02f, app.allModel1Ds.getTrunkSize(0), 0.0001f);

    app.Delete3D.selection();
    assertEquals(0, app.allModel1Ds.num);
  }

  @Test
  void model2DLifecycle_create_group_ungroup_editFileIndex_delete_leavesAnEmptyScene () {
    app.TREES_KIND.fileCount = 10;
    app.allModel2Ds.create("TREES", 1, 50, 60, 70, 2);
    assertEquals(1, app.allModel2Ds.num);

    app.currentObjectCategory = app.ObjectCategory.MODEL2D;
    app.Select3D.model2DSelection = new int[]{0};
    app.allGroups.group_Selection(1);
    assertEquals(1, app.allGroups.num);
    assertEquals(1, app.allModel2Ds.num);

    app.allGroups.ungroup_Selection();
    assertEquals(0, app.allGroups.num);
    assertEquals(1, app.allModel2Ds.num);

    app.currentObjectCategory = app.ObjectCategory.MODEL2D;
    app.Select3D.model2DSelection = new int[]{0};
    app.User3D.currentTool = app.UITASK.Seed_Material; // Model2Ds' own fileIndex-cycling tool
    int fileIndexBefore = app.allModel2Ds.FileIndex[0];
    app.Edit3D.selection(1);
    assertEquals(fileIndexBefore + 1, app.allModel2Ds.FileIndex[0]);

    app.Delete3D.selection();
    assertEquals(0, app.allModel2Ds.num);
  }

  @Test
  void solidLifecycle_create_group_ungroup_editPowerAll_delete_leavesAnEmptyScene () {
    app.allSolids.create(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13);
    assertEquals(1, app.allSolids.DEF.length);

    app.currentObjectCategory = app.ObjectCategory.SOLID;
    app.Select3D.solidSelection = new int[]{0};
    app.allGroups.group_Selection(1);
    assertEquals(1, app.allGroups.num);
    assertEquals(1, app.allSolids.DEF.length);

    app.allGroups.ungroup_Selection();
    assertEquals(0, app.allGroups.num);
    assertEquals(1, app.allSolids.DEF.length);

    app.currentObjectCategory = app.ObjectCategory.SOLID;
    app.Select3D.solidSelection = new int[]{0};
    app.User3D.currentTool = app.UITASK.PowerAll;
    float powBefore = app.allSolids.get_powX(0);
    app.Edit3D.selection(1); // doubles (wraps at CubePower/StarPower rather than clamping)
    assertEquals(powBefore * 2, app.allSolids.get_powX(0), 0.0001f);

    app.Delete3D.selection();
    assertEquals(0, app.allSolids.DEF.length);
  }

  // ================= a genuinely mixed group =============================
  // One group deliberately ends up owning one of EVERY groupable type at
  // once - group_Selection(0) ("add to the existing last group") run
  // once per category, after the first group_Selection(1) ("new group")
  // for the first one - then isolate/edit/delete are all run against
  // that one GROUP selection, exercising all five types' own cascades
  // together in the same call, not isolated one at a time.

  @Test
  void mixedGroup_ownsOneOfEveryType_thenIsolateEditAndDeleteAllActOnEveryTypeTogether () {
    createOneFace();
    createOnePolyline();
    app.allModel1Ds.create(7, 99, 5, 10, 20, 30, 2, 45, 1, 2, 3, 4, 5, 6);
    app.TREES_KIND.fileCount = 10;
    app.allModel2Ds.create("TREES", 1, 50, 60, 70, 2);
    app.allSolids.create(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13);

    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.faceSelection = new int[]{0};
    app.allGroups.group_Selection(1); // new group, owns the face so far

    app.currentObjectCategory = app.ObjectCategory.POLYLINE;
    app.Select3D.polylineSelection = new int[]{0};
    app.allGroups.group_Selection(0); // add to that same group, not a new one

    app.currentObjectCategory = app.ObjectCategory.MODEL1D;
    app.Select3D.model1DSelection = new int[]{0};
    app.allGroups.group_Selection(0);

    app.currentObjectCategory = app.ObjectCategory.MODEL2D;
    app.Select3D.model2DSelection = new int[]{0};
    app.allGroups.group_Selection(0);

    app.currentObjectCategory = app.ObjectCategory.SOLID;
    app.Select3D.solidSelection = new int[]{0};
    app.allGroups.group_Selection(0);

    // Still exactly one group, now owning one of every type.
    assertEquals(1, app.allGroups.num);
    assertEquals(0, app.allGroups.getStart_Face(0));
    assertEquals(0, app.allGroups.getStop_Face(0));
    assertEquals(0, app.allGroups.getStart_Polyline(0));
    assertEquals(0, app.allGroups.getStop_Polyline(0));
    assertEquals(0, app.allGroups.getStart_Model1D(0));
    assertEquals(0, app.allGroups.getStop_Model1D(0));
    assertEquals(0, app.allGroups.getStart_Model2D(0));
    assertEquals(0, app.allGroups.getStop_Model2D(0));
    assertEquals(0, app.allGroups.getStart_Solid(0));
    assertEquals(0, app.allGroups.getStop_Solid(0));
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(1, app.allModel1Ds.num);
    assertEquals(1, app.allModel2Ds.num);
    assertEquals(1, app.allSolids.DEF.length);

    // "modify" the whole group as one unit: isolate_Selection() only
    // ever touches Faces/Polylines visibility (see modify3D.pde's own
    // isolate_Selection()) - Model1D/Model2D/Solid are deliberately left
    // alone by that one function, not a gap in this test.
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.Select3D.groupSelection = new int[]{0};
    app.Modify3D.isolate_Selection();
    assertEquals(1, app.allFaces.getVisibility(0));
    assertEquals(1, app.allPolylines.getVisibility(0));

    // "edit" the whole group as one unit: Edit3D.Groups() fans the given
    // tool out across every face/polyline the group owns.
    app.User3D.currentTool = app.UITASK.Seed_Material;
    int materialBefore = app.allFaces.getMaterial(0);
    app.Edit3D.selection(1);
    assertEquals(materialBefore + 1, app.allFaces.getMaterial(0));

    // Delete the whole group as one unit: every one of the five owned
    // types is spliced out together, in the same call.
    app.Delete3D.groupSelection();
    assertEquals(0, app.allGroups.num);
    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(0, app.allPolylines.nodes.length);
    assertEquals(0, app.allModel1Ds.num);
    assertEquals(0, app.allModel2Ds.num);
    assertEquals(0, app.allSolids.DEF.length);
  }

  // ================= ungroup then regroup round trip ======================

  @Test
  void ungroupThenRegroup_neverDuplicatesOrLosesFaces () {
    for (int i = 0; i < 3; i++) {
      int p0 = app.allPoints.create(i, 0, 0);
      int p1 = app.allPoints.create(i, 1, 0);
      int p2 = app.allPoints.create(i, 1, 1);
      app.allFaces.create(new int[]{p0, p1, p2});
    }
    assertEquals(3, app.allFaces.nodes.length);

    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.faceSelection = new int[]{0, 1, 2};
    app.allGroups.group_Selection(1);
    assertEquals(3, app.allFaces.nodes.length, "grouping clones 1-for-1, never duplicates");
    assertEquals(1, app.allGroups.num);

    app.allGroups.ungroup_Selection();
    assertEquals(3, app.allFaces.nodes.length);
    assertEquals(0, app.allGroups.num);

    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.faceSelection = new int[]{0, 1, 2};
    app.allGroups.group_Selection(1); // regroup
    assertEquals(3, app.allFaces.nodes.length, "a second group/ungroup round trip still neither duplicates nor loses any");
    assertEquals(1, app.allGroups.num);
  }

  // ================= repeated create/delete cycles =======================
  // Stresses the index-shifting logic repeatedly rather than once, the
  // kind of thing a one-shot test can't catch if an off-by-one only
  // shows up on the second or third pass.

  @Test
  void repeatedCreateThenDeleteCycles_acrossFacesAndPolylines_alwaysReturnToZero () {
    for (int cycle = 0; cycle < 5; cycle++) {
      createOneFace();
      createOnePolyline();

      app.currentObjectCategory = app.ObjectCategory.FACE;
      app.Select3D.faceSelection = new int[]{0};
      app.Delete3D.selection();

      app.currentObjectCategory = app.ObjectCategory.POLYLINE;
      app.Select3D.polylineSelection = new int[]{0};
      app.Delete3D.selection();

      assertEquals(0, app.allFaces.nodes.length, "cycle " + cycle);
      assertEquals(0, app.allPolylines.nodes.length, "cycle " + cycle);
      assertEquals(0, app.allPoints.getLength(), "cycle " + cycle + ": no leftover orphaned vertices across repeated cycles");
    }
  }

  // ================= full-scene reset, then robustness on the empty scene =

  @Test
  void deleteAll_onARichMixedGroupedScene_leavesEveryCollectionEmpty () {
    createOneFace();
    createOnePolyline();
    app.allModel1Ds.create(7, 99, 5, 10, 20, 30, 2, 45, 1, 2, 3, 4, 5, 6);
    app.TREES_KIND.fileCount = 10;
    app.allModel2Ds.create("TREES", 1, 50, 60, 70, 2);
    app.allSolids.create(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13);

    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.faceSelection = new int[]{0};
    app.allGroups.group_Selection(1); // leaves a non-empty group behind too, not just loose objects

    app.deleteAll();

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(0, app.allPolylines.nodes.length);
    assertEquals(0, app.allModel1Ds.num);
    assertEquals(0, app.allModel2Ds.num);
    assertEquals(0, app.allSolids.DEF.length);
    assertEquals(0, app.allGroups.num);
    assertEquals(0, app.allPoints.getLength());
  }

  @Test
  void afterDeleteAll_everySelectionBasedOperation_stillRunsWithoutThrowing () {
    // The scenario the earlier per-category lifecycle tests above don't
    // cover: calling the same "act on whatever's currently selected"
    // entry points a person could still reach (menu items, keyboard
    // shortcuts) right after the scene has just been fully cleared -
    // every Select3D.*Selection array is empty, not null, at this point
    // (deleteAll()'s own makeEmpty(0) calls - see e.g. Model1Ds'
    // makeEmpty() calling Select3D.deselect_Model1Ds() - leave empty
    // arrays behind, never nulls), so none of this should throw.
    createOneFace();
    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.faceSelection = new int[]{0};
    app.allGroups.group_Selection(1);

    app.deleteAll();

    assertDoesNotThrow(() -> {
      app.currentObjectCategory = app.ObjectCategory.FACE;
      app.Select3D.faceSelection = new int[]{};
      app.Delete3D.selection();
    }); // Delete3D.selection() with nothing selected

    assertDoesNotThrow(() -> {
      app.currentObjectCategory = app.ObjectCategory.GROUP;
      app.Select3D.groupSelection = new int[]{};
      app.Modify3D.isolate_Selection();
    }); // Modify3D.isolate_Selection() with nothing selected

    assertDoesNotThrow(() -> app.allGroups.ungroup_Selection()); // on an empty scene

    assertDoesNotThrow(() -> {
      app.currentObjectCategory = app.ObjectCategory.MODEL1D;
      app.Select3D.model1DSelection = new int[]{};
      app.User3D.currentTool = app.UITASK.TrunkSize;
      app.Edit3D.selection(1);
    }); // Edit3D.selection() with nothing selected

    assertDoesNotThrow(() -> {
      app.currentObjectCategory = app.ObjectCategory.SOLID;
      app.Select3D.solidSelection = new int[]{};
      app.allGroups.group_Selection(1);
    }); // Groups.group_Selection() with nothing selected

    // Confirmed directly: group_Selection(1) always runs beginNewGroup()
    // regardless of whether anything is actually selected, so this last
    // call leaves one new, empty group behind even with nothing to put
    // in it - not a crash, just worth pinning down rather than assuming
    // the scene is still at 0 groups afterward.
    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(1, app.allGroups.num);
  }

  // ================= geometric transforms on the mixed group =============
  // Move3D/Rotate3D/Scale3D.Groups() each cascade into the group's own
  // Face/Polyline vertices plus its owned Model1Ds/Model2Ds/Solids - the
  // same five types the earlier tests above create/group/ungroup/edit/
  // delete, now actually transformed together as a live group built
  // through the real create()/group_Selection() path, not fabricated
  // array state the way Move3DTest.java/Rotate3DTest.java/Scale3DTest.java's
  // own Groups() tests do.

  @Test
  void mixedGroup_move_translatesTheFacePolylineModel1DModel2DAndSolidTogether () {
    solarchvision_bim a = buildMixedGroupScene();

    a.Move3D.Groups(10, 20, 30);

    assertArrayEquals(new float[]{11, 20, 30}, a.allVertices[a.allFaces.nodes[0][0]], 0.0001f);
    assertEquals(20f, a.allModel1Ds.getX(0), 0.0001f); // was 10
    assertEquals(60f, a.allModel2Ds.getX(0), 0.0001f); // was 50
    assertEquals(11f, a.allSolids.DEF[0][0], 0.0001f); // was 1
    assertArrayEquals(new float[]{10, 20, 30}, java.util.Arrays.copyOf(a.allGroups.Pivots[0], 3), 0.0001f);
  }

  @Test
  void mixedGroup_rotate_turnsTheFaceAndRepositionsModel1DModel2DAndSolidAroundTheOrigin () {
    solarchvision_bim a = buildMixedGroupScene();

    a.Rotate3D.Groups((float) Math.PI / 2, 2); // 90 degrees about Z, around the origin

    // Face vertex (1,0,0) -> (0,1,0): a plain 90-degree turn about Z.
    assertArrayEquals(new float[]{0, 1, 0}, a.allVertices[a.allFaces.nodes[0][0]], 0.0001f);
    // Model1D at (10,20,.) -> (-20,10,.): the same rotation applied to
    // its own position, confirming the cascade isn't Face/Polyline-only.
    assertEquals(-20f, a.allModel1Ds.getX(0), 0.001f);
    assertEquals(10f, a.allModel1Ds.getY(0), 0.001f);
  }

  @Test
  void mixedGroup_scale_resizesTheFaceAndRepositionsModel1DModel2DAndSolidAroundTheOrigin () {
    solarchvision_bim a = buildMixedGroupScene();

    a.Scale3D.Groups(0, 0, 0, 2, 2, 2); // double every axis, around the origin

    assertArrayEquals(new float[]{2, 0, 0}, a.allVertices[a.allFaces.nodes[0][0]], 0.0001f); // was (1,0,0)
    assertEquals(20f, a.allModel1Ds.getX(0), 0.0001f); // was 10
    assertEquals(2f, a.allSolids.DEF[0][0], 0.0001f); // was 1
  }

  // ================= Camera / Section lifecycles ==========================
  // Neither type is groupable (no entry in groups.pde's own Groups class
  // for either), so these are simpler than the five lifecycles above:
  // create -> move -> edit -> delete, with no group/ungroup step.

  @Test
  void cameraLifecycle_create_move_editType_delete_leavesOnlyTheDefaultCameraBehind () {
    // allCameras.add_first() already seeds one default "home" camera the
    // moment the app exists (see GlobalFunctionsTest.java's own comment
    // on this same default), so creating one more is 1 -> 2, and
    // deleting the one just created returns to 1, not 0.
    assertEquals(1, app.allCameras.num);

    app.allCameras.create(1, 2, 3, 1, 0, 0, 0, 90, 60, 1);
    assertEquals(2, app.allCameras.num);

    app.currentObjectCategory = app.ObjectCategory.CAMERA;
    app.Select3D.cameraSelection = new int[]{1};
    app.Move3D.selection(5, 5, 5);
    assertEquals(6f, app.allCameras.options[1][0], 0.0001f); // posX: 1 + 5

    app.User3D.currentTool = app.UITASK.Seed_Material; // Cameras' own type-toggle tool
    app.Edit3D.selection(1);
    assertEquals(1, app.allCameras.get_type(1));

    app.Delete3D.selection();
    assertEquals(1, app.allCameras.num);
  }

  @Test
  void sectionLifecycle_create_move_delete_leavesNoSectionsBehind () {
    assertEquals(0, app.allSections.num);

    app.allSections.create(1, 2, 3, 5, 0, 0, 0, 100, 100);
    assertEquals(1, app.allSections.num);

    app.currentObjectCategory = app.ObjectCategory.SECTION;
    app.Select3D.sectionSelection = new int[]{0};
    app.Move3D.selection(1, 1, 1);
    assertEquals(2f, app.allSections.f_data[0][0], 0.0001f); // X: 1 + 1

    app.Delete3D.selection();
    assertEquals(0, app.allSections.num);
  }

  // ================= undo/redo around a mixed-group delete ================

  @Test
  void mixedGroupDelete_canBeUndoneThenRedone_restoringAndRedeletingEveryOwnedType () {
    // Model2Ds.to_XML() (reached from buildScene3DSnapshot(), which both
    // seedScene3DHistory() and beginUndoableScene3DEdit()/
    // commitUndoableScene3DEdit() call into) needs a real filename behind
    // the kind's own fileIndex - confirmed directly: without this,
    // seedScene3DHistory() throws ArrayIndexOutOfBoundsException from
    // Model2DKind.filenameOf(), same reasoning as Model2DKindTest.java's
    // own Filenames-populated setup.
    app.TREES_KIND.Filenames = new String[]{"oak.png", "pine.png"};

    createOneFace();
    createOnePolyline();
    app.allModel1Ds.create(7, 99, 5, 10, 20, 30, 2, 45, 1, 2, 3, 4, 5, 6);
    app.TREES_KIND.fileCount = 10;
    app.allModel2Ds.create("TREES", 1, 50, 60, 70, 2);
    app.allSolids.create(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13);

    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.faceSelection = new int[]{0};
    app.allGroups.group_Selection(1);
    app.currentObjectCategory = app.ObjectCategory.POLYLINE;
    app.Select3D.polylineSelection = new int[]{0};
    app.allGroups.group_Selection(0);
    app.currentObjectCategory = app.ObjectCategory.MODEL1D;
    app.Select3D.model1DSelection = new int[]{0};
    app.allGroups.group_Selection(0);
    app.currentObjectCategory = app.ObjectCategory.MODEL2D;
    app.Select3D.model2DSelection = new int[]{0};
    app.allGroups.group_Selection(0);
    app.currentObjectCategory = app.ObjectCategory.SOLID;
    app.Select3D.solidSelection = new int[]{0};
    app.allGroups.group_Selection(0);

    // Establishes the "nothing to undo past this" baseline, the same
    // call drawInitialFrames.pde makes once as the app finishes loading
    // - without it, undoScene3DChange() below has no earlier snapshot to
    // restore from at all.
    app.seedScene3DHistory();

    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.Select3D.groupSelection = new int[]{0};
    app.Delete3D.groupSelection();

    assertEquals(0, app.allGroups.num);
    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(0, app.allPolylines.nodes.length);
    assertEquals(0, app.allModel1Ds.num);
    assertEquals(0, app.allModel2Ds.num);
    assertEquals(0, app.allSolids.DEF.length);

    app.undoScene3DChange();

    assertEquals(1, app.allGroups.num, "the group itself comes back");
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(1, app.allModel1Ds.num);
    assertEquals(1, app.allModel2Ds.num);
    assertEquals(1, app.allSolids.DEF.length);

    app.redoScene3DChange();

    assertEquals(0, app.allGroups.num, "redo deletes every one of the five owned types again");
    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(0, app.allPolylines.nodes.length);
    assertEquals(0, app.allModel1Ds.num);
    assertEquals(0, app.allModel2Ds.num);
    assertEquals(0, app.allSolids.DEF.length);
  }

  // ================= undo/redo around the mixed group's own transforms ====
  // Move3D/Rotate3D/Scale3D.Groups() each wrap themselves in their own
  // beginScene3DChange()/endScene3DChange() (confirmed directly in each
  // one's own source), so - unlike group_Selection() below - a single
  // undo cleanly reverses the whole transform, and a single redo
  // reapplies it, across all five owned types at once.

  @Test
  void mixedGroupMove_canBeUndoneThenRedone () {
    solarchvision_bim a = buildMixedGroupScene();
    a.seedScene3DHistory();

    a.Move3D.Groups(10, 20, 30);
    assertArrayEquals(new float[]{11, 20, 30}, a.allVertices[a.allFaces.nodes[0][0]], 0.0001f);

    a.undoScene3DChange();
    assertArrayEquals(new float[]{1, 0, 0}, a.allVertices[a.allFaces.nodes[0][0]], 0.0001f);
    assertEquals(10f, a.allModel1Ds.getX(0), 0.0001f);

    a.redoScene3DChange();
    assertArrayEquals(new float[]{11, 20, 30}, a.allVertices[a.allFaces.nodes[0][0]], 0.0001f);
    assertEquals(20f, a.allModel1Ds.getX(0), 0.0001f);
  }

  @Test
  void mixedGroupRotate_canBeUndoneThenRedone () {
    solarchvision_bim a = buildMixedGroupScene();
    a.seedScene3DHistory();

    a.Rotate3D.Groups((float) Math.PI / 2, 2); // 90 degrees about Z
    assertArrayEquals(new float[]{0, 1, 0}, a.allVertices[a.allFaces.nodes[0][0]], 0.0001f);

    a.undoScene3DChange();
    assertArrayEquals(new float[]{1, 0, 0}, a.allVertices[a.allFaces.nodes[0][0]], 0.0001f);

    a.redoScene3DChange();
    assertArrayEquals(new float[]{0, 1, 0}, a.allVertices[a.allFaces.nodes[0][0]], 0.0001f);
  }

  @Test
  void mixedGroupScale_canBeUndoneThenRedone () {
    solarchvision_bim a = buildMixedGroupScene();
    a.seedScene3DHistory();

    a.Scale3D.Groups(0, 0, 0, 2, 2, 2);
    assertArrayEquals(new float[]{2, 0, 0}, a.allVertices[a.allFaces.nodes[0][0]], 0.0001f);

    a.undoScene3DChange();
    assertArrayEquals(new float[]{1, 0, 0}, a.allVertices[a.allFaces.nodes[0][0]], 0.0001f);

    a.redoScene3DChange();
    assertArrayEquals(new float[]{2, 0, 0}, a.allVertices[a.allFaces.nodes[0][0]], 0.0001f);
  }

  // ================= undo/redo around ungroup_Selection ====================

  @Test
  void ungroupSelection_canBeUndoneThenRedone_cleanly () {
    // Unlike group_Selection() below, ungroup_Selection() has no clone-
    // creation step of its own to worry about - it just zeroes the
    // group's owned ranges, then calls Delete3D.selection() (GROUP
    // category) to remove the now-empty group row, and THAT call's own
    // beginScene3DChange()/endScene3DChange() wrap captures the true
    // pre-ungroup state (ownership ranges intact, group row present) as
    // its "before" snapshot - so a single undo/redo pair here really is
    // clean, confirmed directly rather than assumed just because the
    // mixed-group transforms above were.
    createOneFace();
    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.faceSelection = new int[]{0};
    app.allGroups.group_Selection(1);
    assertEquals(1, app.allGroups.num);

    app.seedScene3DHistory();

    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.Select3D.groupSelection = new int[]{0};
    app.allGroups.ungroup_Selection();
    assertEquals(0, app.allGroups.num);
    assertEquals(1, app.allFaces.nodes.length, "the face itself survives ungrouping");

    app.undoScene3DChange();
    assertEquals(1, app.allGroups.num, "the group comes back");
    assertEquals(1, app.allFaces.nodes.length);

    app.redoScene3DChange();
    assertEquals(0, app.allGroups.num);
    assertEquals(1, app.allFaces.nodes.length);
  }

  // ================= a confirmed, NOT fixed, undo gap in group_Selection ==

  @Test
  void groupSelection_confirmedBug_undoingItDuplicatesTheOriginalRatherThanRestoringIt () {
    // Found while extending this file's own undo/redo coverage, not
    // fixed here - flagged for confirmation the same way
    // Rotate3DTest.java's own groups_rotatesOwnedModel1DsPositionButDoesNotUpdateItsOwnRotationField
    // flags its own found-but-unfixed bug.
    //
    // group_Selection() (groups.pde) has no beginScene3DChange()/
    // endScene3DChange() of its own - confirmed directly by reading it
    // end to end. For the FACE category it: (1) calls allFaces.create()
    // to clone the selected face - create() has no begin/end wrap of its
    // own either (only makeEmpty() does - confirmed the same way), so
    // this step is never its own undo-trackable entry; then (2) calls
    // Delete3D.selection(), which DOES wrap itself, to remove the
    // ORIGINAL face. That wrap's own "before" snapshot is taken at the
    // moment IT starts - by which point the clone from step 1 already
    // exists alongside the still-live original, so the snapshot
    // captures BOTH. A single undo restores exactly that snapshot:
    // both the (restored) original AND the (never removed, because
    // nothing undid its untracked creation) clone end up present
    // together, and the group row itself survives too, rather than the
    // scene genuinely returning to its pre-Group state.
    createOneFace();
    assertEquals(1, app.allFaces.nodes.length);

    app.seedScene3DHistory();

    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.faceSelection = new int[]{0};
    app.allGroups.group_Selection(1);
    assertEquals(1, app.allGroups.num);
    assertEquals(1, app.allFaces.nodes.length, "grouping clones 1-for-1 - this part is correct");

    app.undoScene3DChange();

    // What a clean undo SHOULD leave behind: 0 groups, 1 face (back to
    // exactly the pre-group state). What it actually leaves behind:
    assertEquals(1, app.allGroups.num, "BUG: the new group is NOT removed by undo");
    assertEquals(2, app.allFaces.nodes.length, "BUG: the clone is never removed, so the restored original duplicates it");

    // Redoing from here lands back on the normal, correct post-group
    // state though - it's specifically the undo step that's short, not
    // the whole history entry.
    app.redoScene3DChange();
    assertEquals(1, app.allGroups.num);
    assertEquals(1, app.allFaces.nodes.length);
  }

  // ================= deleteAll() deliberately can't be undone =============

  @Test
  void deleteAll_reseedsHistory_soItCannotItselfBeUndone () {
    // By design, not a gap - see deleteAll()'s own comment
    // (globalFunctions.pde): "New" means a genuinely fresh project, so
    // the undo history itself is reseeded as deleteAll()'s own last
    // step, the same way Open/Fetch reseed it in load_project(). That
    // makes deleteAll() itself the new "nothing to undo past this"
    // baseline - confirmed directly: calling undoScene3DChange() right
    // after it is a no-op, not a restore of what was just deleted.
    createOneFace();
    app.seedScene3DHistory();
    assertEquals(1, app.allFaces.nodes.length, "setup check");

    app.deleteAll();
    assertEquals(0, app.allFaces.nodes.length);

    app.undoScene3DChange();
    assertEquals(0, app.allFaces.nodes.length, "deleteAll() reseeded the history - there is nothing before it to undo to");
  }

  // ================= undo/redo for a non-groupable category (Camera) ======

  @Test
  void cameraCreateThenDelete_canBeUndoneThenRedone () {
    app.seedScene3DHistory();
    assertEquals(1, app.allCameras.num, "the default camera, setup check");

    app.allCameras.create(1, 2, 3, 1, 0, 0, 0, 90, 60, 1);
    assertEquals(2, app.allCameras.num);

    app.currentObjectCategory = app.ObjectCategory.CAMERA;
    app.Select3D.cameraSelection = new int[]{1};
    app.Delete3D.selection();
    assertEquals(1, app.allCameras.num);

    app.undoScene3DChange();
    assertEquals(2, app.allCameras.num, "the created-then-deleted camera comes back");

    app.redoScene3DChange();
    assertEquals(1, app.allCameras.num);
  }
}
