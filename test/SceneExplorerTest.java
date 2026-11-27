import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import processing.data.JSONObject;

// PARENT_SCENE_EXPLORER/CHILD_SCENE_EXPLORER_SELECT (uiRollout.pde) -
// its own draw method isn't JUnit-reachable (no canvas under this
// harness, same as every other Processing-drawn rollout page), but all
// of its actual data logic lives in pure, non-drawing functions
// (extraParamsSelection.pde's own extraParamsEntityCountForCategory()/
// setExtraParamsSelectionArrayFor()/extraParamsSelectionStateFor(),
// groups.pde's own ungroupedIndicesForCategory(), and
// sceneExplorer.pde's own buildSceneExplorerRows()), so that's what's
// covered here.
class SceneExplorerTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath();
    app.allActions = new java.util.HashMap<>();
  }

  private int makeFace () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    return app.allFaces.create(new int[]{ p0, p1, p2 });
  }

  // A fresh scene already carries exactly one default camera
  // (Cameras.makeEmpty()'s own unconditional add_first() call,
  // cameras.pde - every app always has at least one camera to view the
  // scene with) - stripped here so tests about the rest of the tree
  // don't have to account for it. rows_camerasAndSections_.../
  // rows_overallOrder_... below test that default row directly instead
  // of using this.
  private java.util.ArrayList<solarchvision_bim.SceneExplorerRow> rowsIgnoringDefaultCamera (java.util.HashSet<String> expandedKeys) {
    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> rows = app.buildSceneExplorerRows(expandedKeys);
    if (rows.size() > 0 && rows.get(0).targets.size() > 0 && rows.get(0).targets.get(0).category.equals("camera")) {
      rows.remove(0);
    }
    return rows;
  }

  // ================= extraParamsEntityCountForCategory =======================
  // Tested through Faces (sizes off this.nodes.length) and Groups (tracks
  // its own this.num directly) - the same two categories step 1/2's own
  // tests already used as representatives of the two different internal
  // sizing conventions (see ensureExtraParamsLength()'s own comment in
  // each file).

  @Test
  void entityCount_face_matchesHowManyWereCreated () {
    makeFace();
    makeFace();
    assertEquals(2, app.extraParamsEntityCountForCategory("face"));
  }

  @Test
  void entityCount_group_matchesMakeEmptyCount () {
    app.allGroups.makeEmpty(3);
    assertEquals(3, app.extraParamsEntityCountForCategory("group"));
  }

  @Test
  void entityCount_unknownCategory_isZero () {
    assertEquals(0, app.extraParamsEntityCountForCategory("not-a-category"));
  }

  // ================= setExtraParamsSelectionArrayFor =========================

  @Test
  void setSelectionArrayFor_face_writesThroughToSelect3D () {
    int f0 = makeFace();
    int f1 = makeFace();

    app.setExtraParamsSelectionArrayFor("face", new int[]{ f0, f1 });

    assertArrayEquals(new int[]{ f0, f1 }, app.Select3D.faceSelection);
  }

  @Test
  void setSelectionArrayFor_group_writesThroughToSelect3D () {
    app.allGroups.makeEmpty(2);

    app.setExtraParamsSelectionArrayFor("group", new int[]{ 1 });

    assertArrayEquals(new int[]{ 1 }, app.Select3D.groupSelection);
  }

  // ================= extraParamsObjectTypeForCategory =========================

  @Test
  void objectTypeForCategory_face_mapsToTheFaceConstant () {
    assertEquals(app.ObjectCategory.FACE, app.extraParamsObjectTypeForCategory("face"));
  }

  @Test
  void objectTypeForCategory_group_mapsToTheGroupConstant () {
    assertEquals(app.ObjectCategory.GROUP, app.extraParamsObjectTypeForCategory("group"));
  }

  @Test
  void objectTypeForCategory_unknownCategory_leavesCurrentObjectCategoryUnchanged () {
    app.currentObjectCategory = app.ObjectCategory.SOLID;
    assertEquals(app.ObjectCategory.SOLID, app.extraParamsObjectTypeForCategory("not-a-category"));
  }

  // ================= selectSceneExplorerTargets ================================
  // The row-click handler behind drawSceneExplorerSelectTab() - not
  // itself drawing, so directly callable here. Covers the two things
  // just added on top of the plain selection-array write: switching
  // currentObjectCategory to match the row's own last entity, and
  // going through switch_category()/selection_changed() (globalFunctions.pde)
  // rather than touching Select3D/WIN3D/UI_rollout by hand.

  @Test
  void selectTargets_switchesCurrentObjectCategory_toTheLastTargetsOwnCategory () {
    int f0 = makeFace();
    app.allGroups.makeEmpty(1);
    app.currentObjectCategory = app.ObjectCategory.CAMERA; // deliberately something else beforehand

    java.util.ArrayList<solarchvision_bim.ExtraParamsSelectionTarget> targets = new java.util.ArrayList<solarchvision_bim.ExtraParamsSelectionTarget>();
    targets.add(app.new ExtraParamsSelectionTarget("face", f0));
    targets.add(app.new ExtraParamsSelectionTarget("group", 0)); // last - should win

    app.UI_rollout.selectSceneExplorerTargets(targets);

    assertEquals(app.ObjectCategory.GROUP, app.currentObjectCategory);
  }

  @Test
  void selectTargets_writesThroughToSelect3D_forEveryCategoryInvolved () {
    int f0 = makeFace();
    app.allGroups.makeEmpty(1);

    java.util.ArrayList<solarchvision_bim.ExtraParamsSelectionTarget> targets = new java.util.ArrayList<solarchvision_bim.ExtraParamsSelectionTarget>();
    targets.add(app.new ExtraParamsSelectionTarget("face", f0));
    targets.add(app.new ExtraParamsSelectionTarget("group", 0));

    app.UI_rollout.selectSceneExplorerTargets(targets);

    assertArrayEquals(new int[]{ f0 }, app.Select3D.faceSelection);
    assertArrayEquals(new int[]{ 0 }, app.Select3D.groupSelection);
  }

  @Test
  void selectTargets_emptyList_leavesCurrentObjectCategoryUnchanged () {
    app.currentObjectCategory = app.ObjectCategory.SOLID;

    app.UI_rollout.selectSceneExplorerTargets(new java.util.ArrayList<solarchvision_bim.ExtraParamsSelectionTarget>());

    assertEquals(app.ObjectCategory.SOLID, app.currentObjectCategory);
  }

  // ================= extraParamsSelectionStateFor =============================

  @Test
  void selectionStateFor_emptyTargetList_isNone () {
    assertEquals(
      solarchvision_bim.ExtraParamsSelectionState.NONE,
      app.extraParamsSelectionStateFor(new java.util.ArrayList<solarchvision_bim.ExtraParamsSelectionTarget>())
    );
  }

  @Test
  void selectionStateFor_noneOfTheTargetsSelected_isNone () {
    int f0 = makeFace();
    app.Select3D.faceSelection = new int[0];

    java.util.ArrayList<solarchvision_bim.ExtraParamsSelectionTarget> targets = new java.util.ArrayList<solarchvision_bim.ExtraParamsSelectionTarget>();
    targets.add(app.new ExtraParamsSelectionTarget("face", f0));

    assertEquals(solarchvision_bim.ExtraParamsSelectionState.NONE, app.extraParamsSelectionStateFor(targets));
  }

  @Test
  void selectionStateFor_everyTargetSelected_isAll () {
    int f0 = makeFace();
    int f1 = makeFace();
    app.Select3D.faceSelection = new int[]{ f0, f1 };

    java.util.ArrayList<solarchvision_bim.ExtraParamsSelectionTarget> targets = new java.util.ArrayList<solarchvision_bim.ExtraParamsSelectionTarget>();
    targets.add(app.new ExtraParamsSelectionTarget("face", f0));
    targets.add(app.new ExtraParamsSelectionTarget("face", f1));

    assertEquals(solarchvision_bim.ExtraParamsSelectionState.ALL, app.extraParamsSelectionStateFor(targets));
  }

  @Test
  void selectionStateFor_onlySomeTargetsSelected_isSome () {
    int f0 = makeFace();
    int f1 = makeFace();
    app.Select3D.faceSelection = new int[]{ f0 }; // f1 left unselected

    java.util.ArrayList<solarchvision_bim.ExtraParamsSelectionTarget> targets = new java.util.ArrayList<solarchvision_bim.ExtraParamsSelectionTarget>();
    targets.add(app.new ExtraParamsSelectionTarget("face", f0));
    targets.add(app.new ExtraParamsSelectionTarget("face", f1));

    assertEquals(solarchvision_bim.ExtraParamsSelectionState.SOME, app.extraParamsSelectionStateFor(targets));
  }

  @Test
  void selectionStateFor_mixedCategories_countsAcrossBoth () {
    int f0 = makeFace();
    app.allGroups.makeEmpty(1);
    app.Select3D.faceSelection = new int[]{ f0 };
    app.Select3D.groupSelection = new int[]{ 0 };

    java.util.ArrayList<solarchvision_bim.ExtraParamsSelectionTarget> targets = new java.util.ArrayList<solarchvision_bim.ExtraParamsSelectionTarget>();
    targets.add(app.new ExtraParamsSelectionTarget("face", f0));
    targets.add(app.new ExtraParamsSelectionTarget("group", 0));

    assertEquals(solarchvision_bim.ExtraParamsSelectionState.ALL, app.extraParamsSelectionStateFor(targets));
  }

  // ================= ungroupedIndicesForCategory ==============================

  @Test
  void ungrouped_face_noGroupsAtAll_everyFaceIsUngrouped () {
    int f0 = makeFace();
    int f1 = makeFace();

    int[] ungrouped = app.allGroups.ungroupedIndicesForCategory("face");

    assertArrayEquals(new int[]{ f0, f1 }, ungrouped);
  }

  @Test
  void ungrouped_face_excludesWhatAGroupsOwnRangeCovers () {
    int f0 = makeFace();
    int f1 = makeFace();
    int f2 = makeFace();
    app.allGroups.makeEmpty(1);
    app.allGroups.setStart_Face(0, f1);
    app.allGroups.setStop_Face(0, f1); // group 0 owns only f1

    int[] ungrouped = app.allGroups.ungroupedIndicesForCategory("face");

    assertArrayEquals(new int[]{ f0, f2 }, ungrouped);
  }

  @Test
  void ungrouped_camera_hasNoGroupRangeAtAll_soEveryCameraStaysUngrouped () {
    // A fresh scene already carries exactly one default camera
    // (Cameras.makeEmpty()'s own unconditional add_first() call,
    // cameras.pde - every app always has at least one camera to view
    // the scene with), so nothing further needs creating here.
    app.allGroups.makeEmpty(1); // a group exists, but Groups has no range for cameras at all

    int[] ungrouped = app.allGroups.ungroupedIndicesForCategory("camera");

    assertArrayEquals(new int[]{ 0 }, ungrouped);
  }

  // ================= buildSceneExplorerRows ====================================

  @Test
  void rows_freshScene_hasOnlyTheDefaultCamera () {
    // Confirms the baseline itself - see rowsIgnoringDefaultCamera()'s
    // own comment above for why every other test strips this row out
    // rather than asserting against it directly.
    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> rows = app.buildSceneExplorerRows(new java.util.HashSet<String>());

    assertEquals(1, rows.size());
    assertEquals("1 Camera", rows.get(0).label);
    assertEquals(0, rows.get(0).depth);
  }

  @Test
  void rows_sections_appearFlatRightAfterCameras_onlyWhenPresent () {
    app.allSections.create(0, 0, 0, 0, 1, 1, 1, 1);

    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> rows = app.buildSceneExplorerRows(new java.util.HashSet<String>());

    assertEquals(2, rows.size()); // the default camera, plus this one section
    assertEquals("1 Camera", rows.get(0).label);
    assertEquals("1 Section", rows.get(1).label);
    assertEquals(0, rows.get(1).depth);
  }

  @Test
  void rows_ungroupedBucket_omittedEntirelyWhenNothingIsUngrouped () {
    // Every face immediately belongs to a group's own range below, so
    // "Ungrouped" has nothing left to show and should not appear at all.
    int f0 = makeFace();
    app.allGroups.makeEmpty(1);
    app.allGroups.setStart_Face(0, f0);
    app.allGroups.setStop_Face(0, f0);

    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> rows = rowsIgnoringDefaultCamera(new java.util.HashSet<String>());

    for (solarchvision_bim.SceneExplorerRow row : rows) assertNotEquals("Ungrouped", row.label);
  }

  @Test
  void rows_ungroupedBucket_showsItsOwnCategoryCountRow () {
    makeFace();
    makeFace(); // no groups at all - both faces are ungrouped

    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> rows = rowsIgnoringDefaultCamera(new java.util.HashSet<String>());

    assertEquals(2, rows.size());
    assertEquals("Ungrouped", rows.get(0).label);
    assertEquals(0, rows.get(0).depth);
    assertEquals("2 Faces", rows.get(1).label);
    assertEquals(1, rows.get(1).depth);
    assertTrue(rows.get(1).hasToggle);
    assertEquals("ungrouped:face", rows.get(1).expandKey);
  }

  @Test
  void rows_groupHeader_usesExtraParamsNameWhenPresent_fallsBackToGroupN () {
    app.allGroups.makeEmpty(2);
    JSONObject named = new JSONObject();
    app.extraParamsSetAtPath(named, "name", "Office Block");
    app.allGroups.setExtraParamsObject(0, named);
    // Group 1 is left with no "name" at all.

    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> rows = rowsIgnoringDefaultCamera(new java.util.HashSet<String>());

    assertEquals("Office Block", rows.get(0).label);
    assertEquals("Group 1", rows.get(1).label);
  }

  @Test
  void rows_emptyGroup_isStillShown () {
    app.allGroups.makeEmpty(1); // empty - no category ranges set at all

    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> rows = rowsIgnoringDefaultCamera(new java.util.HashSet<String>());

    assertEquals(1, rows.size());
    assertEquals("Group 0", rows.get(0).label);
    assertEquals(0, rows.get(0).depth);
    assertTrue(rows.get(0).targets.isEmpty());
  }

  @Test
  void rows_categoryRow_onlyExpandsToEntityLeaves_whenItsOwnKeyIsInTheSet () {
    makeFace();
    makeFace();

    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> collapsedRows = rowsIgnoringDefaultCamera(new java.util.HashSet<String>());
    assertEquals(2, collapsedRows.size()); // "Ungrouped" header + "2 Faces" - no leaf rows yet

    java.util.HashSet<String> expanded = new java.util.HashSet<String>();
    expanded.add("ungrouped:face");
    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> expandedRows = rowsIgnoringDefaultCamera(expanded);

    assertEquals(4, expandedRows.size()); // + one leaf row per face
    assertEquals(2, expandedRows.get(2).depth);
    assertEquals(2, expandedRows.get(3).depth);
    assertTrue(expandedRows.get(1).expanded);
  }

  @Test
  void rows_entityLeaf_usesExtraParamsNameWhenPresent_fallsBackToCategoryAndIndex () {
    int f0 = makeFace();
    JSONObject named = new JSONObject();
    app.extraParamsSetAtPath(named, "name", "North Wall");
    app.allFaces.setExtraParamsObject(f0, named);

    java.util.HashSet<String> expanded = new java.util.HashSet<String>();
    expanded.add("ungrouped:face");
    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> rows = rowsIgnoringDefaultCamera(expanded);

    assertEquals("North Wall", rows.get(2).label);
  }

  @Test
  void rows_overallOrder_camerasThenSectionsThenUngroupedThenGroupsInOrder () {
    // The default camera (see rowsIgnoringDefaultCamera()'s own comment)
    // already covers "Cameras first" - nothing further needs creating.
    app.allSections.create(0, 0, 0, 0, 1, 1, 1, 1);
    makeFace(); // ungrouped
    app.allGroups.makeEmpty(2); // two groups

    // makeEmpty(n) leaves every group's own per-category range at Java's
    // own raw array default, {0,0} - NOT beginNewGroup()'s own "null
    // because start > stop" sentinel (groups.pde's own comment there) -
    // so without this, group 0's default {0,0} Face range would silently
    // claim the one face just created above (index 0), which is exactly
    // the opposite of what "two EMPTY groups" is supposed to set up
    // here. Set explicitly so both groups are genuinely empty, the same
    // way beginNewGroup() itself represents "nothing here yet".
    for (int g = 0; g < 2; g++) {
      app.allGroups.setStart_Face(g, 1);
      app.allGroups.setStop_Face(g, 0);
    }

    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> rows = app.buildSceneExplorerRows(new java.util.HashSet<String>());

    assertEquals("1 Camera", rows.get(0).label);
    assertEquals("1 Section", rows.get(1).label);
    assertEquals("Ungrouped", rows.get(2).label);
    assertEquals("1 Face", rows.get(3).label);
    assertEquals("Group 0", rows.get(4).label);
    assertEquals("Group 1", rows.get(5).label);
  }

  // ================= buildSceneExplorerRows(expandedKeys, onlyVisible) =======

  @Test
  void rows_onlyVisible_false_isIdenticalToTheOlderTwoArgOverload () {
    // The pre-Step-5 overload (used by every test above) must keep
    // behaving exactly like explicitly passing onlyVisible=false - this
    // confirms the delegation in buildSceneExplorerRows(expandedKeys)
    // itself, not just that false is a no-op filter.
    makeFace();
    makeFace();

    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> viaOldOverload =
      app.buildSceneExplorerRows(new java.util.HashSet<String>());
    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> viaExplicitFalse =
      app.buildSceneExplorerRows(new java.util.HashSet<String>(), false);

    assertEquals(viaOldOverload.size(), viaExplicitFalse.size());
    assertEquals(viaOldOverload.get(1).label, viaExplicitFalse.get(1).label); // "2 Faces"
  }

  @Test
  void rows_onlyVisible_true_narrowsACategoryCountRowToOnlyTheVisibleEntities () {
    int f0 = makeFace();
    int f1 = makeFace();
    app.allFaces.setVisibility(f0, 0); // hide the first face only

    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> rows =
      rowsIgnoringDefaultCamera_onlyVisible(new java.util.HashSet<String>());

    assertEquals("Ungrouped", rows.get(0).label);
    assertEquals("1 Face", rows.get(1).label); // not "2 Faces" - f0 is filtered out

    java.util.HashSet<String> expanded = new java.util.HashSet<String>();
    expanded.add("ungrouped:face");
    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> expandedRows =
      rowsIgnoringDefaultCamera_onlyVisible(expanded);

    assertEquals(3, expandedRows.size()); // header + count row + exactly one leaf (f1)
    assertEquals(1, expandedRows.get(2).targets.size());
    assertEquals(f1, expandedRows.get(2).targets.get(0).index);
  }

  @Test
  void rows_onlyVisible_true_omitsABucketEntirelyWhenNothingInItIsVisible () {
    // Mirrors rows_ungroupedBucket_omittedEntirelyWhenNothingIsUngrouped()
    // above, but for visibility instead of group membership - "Ungrouped"
    // has entities, but none of them pass the filter, so it should
    // disappear the same way an actually-empty bucket already does
    // (showEvenIfEmpty=false covers both reasons for ending up with zero
    // headerTargets).
    int f0 = makeFace();
    app.allFaces.setVisibility(f0, 0);

    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> rows =
      rowsIgnoringDefaultCamera_onlyVisible(new java.util.HashSet<String>());

    assertEquals(0, rows.size());
  }

  @Test
  void rows_onlyVisible_true_stillShowsARealGroupHeader_evenWithNothingVisibleInside () {
    // showEvenIfEmpty=true for real Groups (unlike Ungrouped) applies
    // just as much when the group's own members are all hidden as when
    // it's genuinely empty - same reasoning as rows_emptyGroup_isStillShown
    // above: a group with nothing currently shown is still a real,
    // addressable, deletable group.
    int f0 = makeFace();
    app.allFaces.setVisibility(f0, 0);
    app.allGroups.makeEmpty(1);
    app.allGroups.setStart_Face(0, f0);
    app.allGroups.setStop_Face(0, f0);

    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> rows =
      rowsIgnoringDefaultCamera_onlyVisible(new java.util.HashSet<String>());

    assertEquals(1, rows.size());
    assertEquals("Group 0", rows.get(0).label);
    assertTrue(rows.get(0).targets.isEmpty()); // the hidden face doesn't count toward header targets either
  }

  @Test
  void rows_onlyVisible_true_dropsTheCamerasRowEntirely_whenTheOnlyCameraIsHidden () {
    app.allCameras.setVisibility(0, 0); // hide the one default camera

    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> rows =
      app.buildSceneExplorerRows(new java.util.HashSet<String>(), true);

    assertEquals(0, rows.size());
  }

  // Same shape as rowsIgnoringDefaultCamera() above, but threading the
  // onlyVisible flag through to the new three-arg overload instead.
  private java.util.ArrayList<solarchvision_bim.SceneExplorerRow> rowsIgnoringDefaultCamera_onlyVisible (java.util.HashSet<String> expandedKeys) {
    java.util.ArrayList<solarchvision_bim.SceneExplorerRow> rows = app.buildSceneExplorerRows(expandedKeys, true);
    if (rows.size() > 0 && rows.get(0).targets.size() > 0 && rows.get(0).targets.get(0).category.equals("camera")) {
      rows.remove(0);
    }
    return rows;
  }

  // ================= extraParamsSetVisibility ================================
  // The write-side counterpart of extraParamsIsVisible (itself only
  // ever exercised indirectly, through sceneExplorerFilterVisible()/
  // buildSceneExplorerRows() above) - isolateTargets()'s (modify3D.pde)
  // own direct dependency, so covered directly here rather than only
  // through that function's own tests (ModifyGeometryTest.java).

  @Test
  void setVisibility_roundTripsThroughGetVisibility_forEveryRealCategory () {
    int f0 = makeFace();
    app.allSolids.create(0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0);

    app.extraParamsSetVisibility("face", f0, 0);
    app.extraParamsSetVisibility("solid", 0, 0);

    assertEquals(0, app.allFaces.getVisibility(f0));
    assertEquals(0, app.allSolids.getVisibility(0));
    assertFalse(app.extraParamsIsVisible("face", f0));
    assertFalse(app.extraParamsIsVisible("solid", 0));
  }

  @Test
  void setVisibility_onGroupCategory_isANoOp_ratherThanAnError () {
    // "group" carries no visibility of its own (extraParamsIsVisible()'s
    // own comment explains why) - this must not throw or touch anything.
    assertDoesNotThrow(() -> app.extraParamsSetVisibility("group", 0, 0));
  }
}
