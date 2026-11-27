// Scene Explorer (PARENT_SCENE_EXPLORER/CHILD_SCENE_EXPLORER_NAVIGATE,
// uiRollout.pde) - a read/select tree over every entity in the project,
// grouped the way the project itself groups them (allGroups' own index
// ranges, groups.pde), plus an "Ungrouped" bucket for whatever falls
// outside every group's range, with Cameras/Sections listed flat at the
// top since Groups has no range for either of them at all
// (ungroupedIndicesForCategory()'s own comment, groups.pde, explains
// why).
//
// buildSceneExplorerRows() below is pure data - no drawing, no mouse/
// keyboard state - so it's directly testable (SceneExplorerTest.java)
// independent of uiRollout.pde's own draw method, which just walks
// whatever this returns and draws each row. The caller passes in which
// category-rows are currently expanded (expandedKeys, keyed by each
// row's own expandKey below); expanding a category-row is the only
// thing that adds individual-entity rows - a Cameras/Sections/
// Ungrouped/Group header and its own category-count rows are always
// present, never themselves collapsible (see the plan this implements:
// "Depth should be on level 1 by default").

// EXTRAPARAMS_CATEGORIES (extraParamsSelection.pde) minus camera/
// section/group - the five categories a group's own range can actually
// cover (groups.pde's own Faces/Polylines/Solids/Model1Ds/Model2Ds int[][]
// fields).
String[] SCENE_EXPLORER_GROUPABLE_CATEGORIES = { "face", "polyline", "model1d", "model2d", "solid" };

// depth 0: a Cameras/Sections/Ungrouped/Group header row (never itself
//   collapsible - always shows its own category-count rows).
// depth 1: a category-count row under one of those headers ("2 Faces") -
//   the only row with its own expand toggle (hasToggle).
// depth 2: one individual-entity row, present only while its parent
//   category-row (depth 1) is expanded.
class SceneExplorerRow {
  String label;
  int depth;
  ArrayList<ExtraParamsSelectionTarget> targets; // every entity this row represents, for selection/highlight and for what a click on it selects
  boolean hasToggle;
  String expandKey; // unique key into the caller's expanded-state map; only meaningful when hasToggle
  boolean expanded; // this row's own current expand state, echoed back for the caller's drawing convenience

  SceneExplorerRow (String label, int depth, ArrayList<ExtraParamsSelectionTarget> targets, boolean hasToggle, String expandKey, boolean expanded) {
    this.label = label;
    this.depth = depth;
    this.targets = targets;
    this.hasToggle = hasToggle;
    this.expandKey = expandKey;
    this.expanded = expanded;
  }
}

ArrayList<ExtraParamsSelectionTarget> sceneExplorerTargetsForIds (String category, int[] ids) {
  ArrayList<ExtraParamsSelectionTarget> targets = new ArrayList<ExtraParamsSelectionTarget>();
  for (int id : ids) targets.add(new ExtraParamsSelectionTarget(category, id));
  return targets;
}

// "name" in extraParams is already this codebase's own established
// display-name convention for an entity (exportIfc.pde/importGlb.pde
// both already read it the same way) - reused here, rather than
// invented fresh, for a Group's or an individual entity's own row
// label. Falls back to fallback when there's no non-empty "name" to
// show.
String sceneExplorerDisplayName (String category, int index, String fallback) {
  JSONObject obj = getExtraParamsObjectForSelection(new ExtraParamsSelectionTarget(category, index));
  if (obj.hasKey("name")) {
    Object v = obj.get("name");
    if (v instanceof String && ((String) v).length() > 0) return (String) v;
  }
  return fallback;
}

String sceneExplorerCategorySingular (String category) {
  if (category.equals("face")) return "Face";
  if (category.equals("polyline")) return "Polyline";
  if (category.equals("solid")) return "Solid";
  if (category.equals("model1d")) return "Model 1D";
  if (category.equals("model2d")) return "Model 2D";
  if (category.equals("camera")) return "Camera";
  if (category.equals("section")) return "Section";
  return category;
}

String sceneExplorerCategoryCountLabel (String category, int count) {
  String singular = sceneExplorerCategorySingular(category);
  return count + " " + singular + (count == 1 ? "" : "s");
}

// Every index currently in range [start, lastValidIndex] for category -
// the group-relative counterpart to ungroupedIndicesForCategory()
// (groups.pde). Shared by every real Group below; Ungrouped's own ids
// come from ungroupedIndicesForCategory() directly instead, since its
// own "membership" is already the complement, not a single range.
int[] sceneExplorerIdsInRange (String category, int start, int stop) {
  int count = extraParamsEntityCountForCategory(category);
  int lo = max(0, start);
  int hi = min(stop, count - 1);
  if (hi < lo) return new int[0];

  int[] ids = new int[hi - lo + 1];
  for (int i = 0; i < ids.length; i++) ids[i] = lo + i;
  return ids;
}

// The "show only visible" filter itself - kept separate from
// sceneExplorerIdsInRange()/sceneExplorerIdsInGroupRange() below since
// every id list this file builds (grouped, ungrouped, and the flat
// Cameras/Sections lists alike) passes through here the same way,
// right before it becomes a row. onlyVisible=false is a no-op (the
// array is returned as-is) so every existing call site keeps its old
// behavior unless it opts in.
int[] sceneExplorerFilterVisible (String category, int[] ids, boolean onlyVisible) {
  if (!onlyVisible) return ids;

  IntList kept = new IntList();
  for (int id : ids) {
    if (extraParamsIsVisible(category, id)) kept.append(id);
  }
  return kept.array();
}

int[] sceneExplorerIdsInGroupRange (String category, int g) {
  if (category.equals("face")) return sceneExplorerIdsInRange(category, allGroups.getStart_Face(g), allGroups.getStop_Face(g));
  if (category.equals("polyline")) return sceneExplorerIdsInRange(category, allGroups.getStart_Polyline(g), allGroups.getStop_Polyline(g));
  if (category.equals("solid")) return sceneExplorerIdsInRange(category, allGroups.getStart_Solid(g), allGroups.getStop_Solid(g));
  if (category.equals("model1d")) return sceneExplorerIdsInRange(category, allGroups.getStart_Model1D(g), allGroups.getStop_Model1D(g));
  if (category.equals("model2d")) return sceneExplorerIdsInRange(category, allGroups.getStart_Model2D(g), allGroups.getStop_Model2D(g));
  return new int[0];
}

// One header (depth 0) + its own category-count rows (depth 1, each
// with its own expand toggle) + (for an expanded category) one leaf row
// per entity (depth 2) - shared by the "Ungrouped" bucket and every real
// Group below, which are identical in shape, just fed a different
// per-category id lookup and a different expandKey prefix.
// showEvenIfEmpty keeps a genuinely empty Group's own header visible
// (an empty group is a recognized, deletable state already - see
// "Delete Scene Empty Groups", actions.pde - so hiding it here would be
// inconsistent), while "Ungrouped" itself (showEvenIfEmpty = false) is
// simply left out of the tree entirely when there's nothing left
// outside every group's own range, rather than showing an empty bucket
// with nothing to expand.
void sceneExplorerAppendGroupLikeRows (
  ArrayList<SceneExplorerRow> rows, String headerLabel,
  java.util.function.Function<String,int[]> idsForCategory,
  String expandKeyPrefix, java.util.HashSet<String> expandedKeys, boolean showEvenIfEmpty,
  boolean onlyVisible
) {
  ArrayList<ExtraParamsSelectionTarget> headerTargets = new ArrayList<ExtraParamsSelectionTarget>();
  ArrayList<SceneExplorerRow> categoryRows = new ArrayList<SceneExplorerRow>();

  for (String category : SCENE_EXPLORER_GROUPABLE_CATEGORIES) {
    int[] ids = sceneExplorerFilterVisible(category, idsForCategory.apply(category), onlyVisible);
    if (ids.length == 0) continue;

    ArrayList<ExtraParamsSelectionTarget> categoryTargets = sceneExplorerTargetsForIds(category, ids);
    headerTargets.addAll(categoryTargets);

    String expandKey = expandKeyPrefix + ":" + category;
    boolean expanded = expandedKeys.contains(expandKey);

    categoryRows.add(new SceneExplorerRow(
      sceneExplorerCategoryCountLabel(category, ids.length), 1, categoryTargets, true, expandKey, expanded
    ));

    if (expanded) {
      String singular = sceneExplorerCategorySingular(category);
      for (int id : ids) {
        ArrayList<ExtraParamsSelectionTarget> leafTargets = new ArrayList<ExtraParamsSelectionTarget>();
        leafTargets.add(new ExtraParamsSelectionTarget(category, id));
        String leafLabel = sceneExplorerDisplayName(category, id, singular + " " + id);
        categoryRows.add(new SceneExplorerRow(leafLabel, 2, leafTargets, false, null, false));
      }
    }
  }

  if (headerTargets.size() == 0 && !showEvenIfEmpty) return;

  rows.add(new SceneExplorerRow(headerLabel, 0, headerTargets, false, null, false));
  rows.addAll(categoryRows);
}

// The whole tree, top to bottom, in the order the plan settled on:
// Cameras, Sections (both flat - never grouped at all), then
// "Ungrouped", then every real Group in creation order.
//
// onlyVisible: the "show only visible" filter - when true, every id
// list below (Cameras/Sections' own flat lists, and every category
// inside every Ungrouped/Group bucket) is narrowed to entities whose
// own getVisibility() > 0 first (sceneExplorerFilterVisible() above),
// exactly like SCENE_EXPLORER_GROUPABLE_CATEGORIES narrows which
// categories can ever appear under a group - a row for a category/
// bucket with nothing left after that narrowing simply isn't added,
// the same "nothing to show" handling idsForCategory already gets when
// a category or group is empty outright. false is the existing
// behavior, unchanged.
// Pre-Step-5 signature, kept so every existing caller/test that never
// cared about the visibility filter keeps compiling unchanged - same
// as this file's own idsForCategory lambdas being reused unmodified by
// sceneExplorerAppendGroupLikeRows() just above. onlyVisible=false here
// is the same "no-op" default sceneExplorerFilterVisible() itself uses.
ArrayList<SceneExplorerRow> buildSceneExplorerRows (java.util.HashSet<String> expandedKeys) {
  return buildSceneExplorerRows(expandedKeys, false);
}

ArrayList<SceneExplorerRow> buildSceneExplorerRows (java.util.HashSet<String> expandedKeys, boolean onlyVisible) {
  ArrayList<SceneExplorerRow> rows = new ArrayList<SceneExplorerRow>();

  int cameraCount = extraParamsEntityCountForCategory("camera");
  if (cameraCount > 0) {
    int[] allIds = new int[cameraCount];
    for (int i = 0; i < cameraCount; i++) allIds[i] = i;
    int[] ids = sceneExplorerFilterVisible("camera", allIds, onlyVisible);
    if (ids.length > 0) {
      rows.add(new SceneExplorerRow(
        sceneExplorerCategoryCountLabel("camera", ids.length), 0,
        sceneExplorerTargetsForIds("camera", ids), false, null, false
      ));
    }
  }

  int sectionCount = extraParamsEntityCountForCategory("section");
  if (sectionCount > 0) {
    int[] allIds = new int[sectionCount];
    for (int i = 0; i < sectionCount; i++) allIds[i] = i;
    int[] ids = sceneExplorerFilterVisible("section", allIds, onlyVisible);
    if (ids.length > 0) {
      rows.add(new SceneExplorerRow(
        sceneExplorerCategoryCountLabel("section", ids.length), 0,
        sceneExplorerTargetsForIds("section", ids), false, null, false
      ));
    }
  }

  sceneExplorerAppendGroupLikeRows(
    rows, "Ungrouped",
    (category) -> allGroups.ungroupedIndicesForCategory(category),
    "ungrouped", expandedKeys, false, onlyVisible
  );

  for (int g = 0; g < allGroups.num; g++) {
    final int groupIndex = g; // captured by the lambda just below - Java requires this effectively final
    sceneExplorerAppendGroupLikeRows(
      rows, sceneExplorerDisplayName("group", g, "Group " + g),
      (category) -> sceneExplorerIdsInGroupRange(category, groupIndex),
      "group:" + g, expandedKeys, true, onlyVisible
    );
  }

  return rows;
}
