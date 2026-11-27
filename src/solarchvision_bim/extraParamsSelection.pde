// Resolves "the one entity PARENT_EXTRA_PARAMS (uiRollout.pde) and
// EXTRAPARAMS.SET/EXTRAPARAMS.REMOVE (extraCommands.pde) operate on"
// against Select3D's own per-category selection arrays (select3D.pde).
// Each category's own selection array holds one slot per selectable
// entity - a selected group is one such slot too, with its own single
// extraParams object, same as a face or a solid, whatever else that
// group's own selection may additionally pull into other categories'
// arrays at the same time. v1 scope for the Selected Entity tab (below)
// is exactly one selected entity, in exactly one category - 0 or more
// than 1, in any combination across categories, resolves to "nothing to
// show/act on" rather than a per-category error; the Bulk Edit tab
// (currentExtraParamsSelectionList(), below) is the counterpart that
// works across however many entities end up selected at once.
//
// vertexSelection/softSelection/terrainVertexSelection are sub-
// selections *within* an already-selected object, not objects of their
// own, and are left out on purpose - extraParams lives on the object,
// not on one of its vertices.
class ExtraParamsSelectionTarget {
  String category;
  int index;
  ExtraParamsSelectionTarget (String category, int index) {
    this.category = category;
    this.index = index;
  }
}

// Every category whose class carries its own getExtraParamsObject()/
// setExtraParamsObject() (extraParamsHelpers.pde's own convenience
// wrappers, implemented identically on each of Faces/Polylines/
// Model1Ds/Model2Ds/Solids/Groups/Cameras/Sections).
String[] EXTRAPARAMS_CATEGORIES = { "face", "polyline", "model1d", "model2d", "solid", "group", "camera", "section" };

int[] extraParamsSelectionArrayFor (String category) {
  if (category.equals("face")) return Select3D.faceSelection;
  if (category.equals("polyline")) return Select3D.polylineSelection;
  if (category.equals("model1d")) return Select3D.model1DSelection;
  if (category.equals("model2d")) return Select3D.model2DSelection;
  if (category.equals("solid")) return Select3D.solidSelection;
  if (category.equals("group")) return Select3D.groupSelection;
  if (category.equals("camera")) return Select3D.cameraSelection;
  if (category.equals("section")) return Select3D.sectionSelection;
  return new int[0];
}

// The write-side counterpart of extraParamsSelectionArrayFor() above -
// nothing needed one before now (every prior caller only ever read the
// current selection), but Scene Explorer's own row clicks (uiRollout.pde)
// need to drive the selection FROM a row's own target list, across
// whichever category that row happens to be, without a per-category
// if/else at every call site. Replaces that category's own selection
// array outright - callers that want to add to (rather than replace)
// the current selection build the union themselves first.
void setExtraParamsSelectionArrayFor (String category, int[] ids) {
  if (category.equals("face")) { Select3D.faceSelection = ids; return; }
  if (category.equals("polyline")) { Select3D.polylineSelection = ids; return; }
  if (category.equals("model1d")) { Select3D.model1DSelection = ids; return; }
  if (category.equals("model2d")) { Select3D.model2DSelection = ids; return; }
  if (category.equals("solid")) { Select3D.solidSelection = ids; return; }
  if (category.equals("group")) { Select3D.groupSelection = ids; return; }
  if (category.equals("camera")) { Select3D.cameraSelection = ids; return; }
  if (category.equals("section")) { Select3D.sectionSelection = ids; return; }
}

// How many entities category currently has, total - every class behind
// EXTRAPARAMS_CATEGORIES keeps its own extraParams array exactly in
// step with its own entity count once ensureExtraParamsLength() has
// run (stripAllExtraParams(), faces.pde and seven classes alongside it,
// already relies on this same invariant), even though each class
// tracks that count via a different internal field of its own
// (this.nodes.length for Faces, this.num for Groups, etc. - see
// ensureExtraParamsLength()'s own comment in each file). Reading
// extraParams.length after calling it is therefore a uniform count
// accessor across every category, without needing to know any one
// class's own sizing field - Scene Explorer's own row-building
// (sceneExplorer.pde) is the first caller that needs "how many does
// this category have, total" independent of any selection.
int extraParamsEntityCountForCategory (String category) {
  if (category.equals("face")) { allFaces.ensureExtraParamsLength(); return allFaces.extraParams.length; }
  if (category.equals("polyline")) { allPolylines.ensureExtraParamsLength(); return allPolylines.extraParams.length; }
  if (category.equals("model1d")) { allModel1Ds.ensureExtraParamsLength(); return allModel1Ds.extraParams.length; }
  if (category.equals("model2d")) { allModel2Ds.ensureExtraParamsLength(); return allModel2Ds.extraParams.length; }
  if (category.equals("solid")) { allSolids.ensureExtraParamsLength(); return allSolids.extraParams.length; }
  if (category.equals("group")) { allGroups.ensureExtraParamsLength(); return allGroups.extraParams.length; }
  if (category.equals("camera")) { allCameras.ensureExtraParamsLength(); return allCameras.extraParams.length; }
  if (category.equals("section")) { allSections.ensureExtraParamsLength(); return allSections.extraParams.length; }
  return 0;
}

// Whether entity index of category is currently visible, per this
// codebase's own "> 0 is visible" convention (see each getVisibility()
// consumer in the export*.pde family) - every category but "group" now
// carries its own int[] visibility (solids.pde/model1Ds.pde/model2Ds.pde/
// cameras.pde/sections.pde/faces.pde/polylines.pde, all added the same
// way). "group" has no visibility of its own (a group is a grouping of
// other entities' ranges, not a visible thing in its own right - the
// same reasoning isolate_Selection()/modify3D.pde already uses to keep
// Faces/Polylines/Solids/Model1Ds/Model2Ds/Cameras/Sections as the only
// real "visible entity" categories), so it falls back to true (never
// filtered out by a "show only visible" check). Scene Explorer's own
// "show only visible" filter (sceneExplorer.pde) is the first caller.
boolean extraParamsIsVisible (String category, int index) {
  if (category.equals("face")) return allFaces.getVisibility(index) > 0;
  if (category.equals("polyline")) return allPolylines.getVisibility(index) > 0;
  if (category.equals("model1d")) return allModel1Ds.getVisibility(index) > 0;
  if (category.equals("model2d")) return allModel2Ds.getVisibility(index) > 0;
  if (category.equals("solid")) return allSolids.getVisibility(index) > 0;
  if (category.equals("camera")) return allCameras.getVisibility(index) > 0;
  if (category.equals("section")) return allSections.getVisibility(index) > 0;
  return true;
}

// The write-side counterpart of extraParamsIsVisible() above - Scene
// Explorer's own row-target-direct isolate (isolateTargets(),
// modify3D.pde) is the first caller: it reveals entities by their own
// {category, index} pair directly, rather than through
// currentObjectCategory-gated *_Selection() helpers like
// isolate_Selection() itself uses, since a Scene Explorer row's own
// target list can span more than one category at once. "group" is not
// a visibility-bearing category (same reasoning as
// extraParamsIsVisible()'s own comment) - a no-op here rather than an
// error, consistent with that function's own true fallback.
void extraParamsSetVisibility (String category, int index, int visibility) {
  if (category.equals("face")) { allFaces.setVisibility(index, visibility); return; }
  if (category.equals("polyline")) { allPolylines.setVisibility(index, visibility); return; }
  if (category.equals("model1d")) { allModel1Ds.setVisibility(index, visibility); return; }
  if (category.equals("model2d")) { allModel2Ds.setVisibility(index, visibility); return; }
  if (category.equals("solid")) { allSolids.setVisibility(index, visibility); return; }
  if (category.equals("camera")) { allCameras.setVisibility(index, visibility); return; }
  if (category.equals("section")) { allSections.setVisibility(index, visibility); return; }
}

// EXTRAPARAMS_CATEGORIES' own lowercase category strings, mapped to
// this codebase's actual int object-type constants (ObjectCategory,
// an OBJECTTYPE instance - objectType.pde - this app's own
// alternative to a real Java enum, predating every extraParams file
// here). Scene Explorer's own row clicks (selectSceneExplorerTargets(),
// uiRollout.pde) are the first caller that needs to go the other way
// across that gap - every other extraParams dispatch function in this
// file only ever needed the string side. Falls back to
// currentObjectCategory itself (i.e. "leave it unchanged") for a
// category this never heard of, rather than guessing.
int extraParamsObjectTypeForCategory (String category) {
  if (category.equals("face")) return ObjectCategory.FACE;
  if (category.equals("polyline")) return ObjectCategory.POLYLINE;
  if (category.equals("model1d")) return ObjectCategory.MODEL1D;
  if (category.equals("model2d")) return ObjectCategory.MODEL2D;
  if (category.equals("solid")) return ObjectCategory.SOLID;
  if (category.equals("group")) return ObjectCategory.GROUP;
  if (category.equals("camera")) return ObjectCategory.CAMERA;
  if (category.equals("section")) return ObjectCategory.SECTION;
  return currentObjectCategory;
}

// Named constants for extraParamsSelectionStateFor()'s own result -
// this codebase's established alternative to a real Java enum
// (objectType.pde's own OBJECTTYPE class, used the same way for
// ObjectCategory, is the precedent this follows).
class ExtraParamsSelectionState {
  final static int NONE = 0; // none of the targets are currently selected
  final static int SOME = 1; // some, but not all
  final static int ALL = 2;  // every one of them
}

// How much of targets (any list of ExtraParamsSelectionTarget, built
// however the caller likes) is currently selected - Scene Explorer's
// own row-highlight logic (green when a row's own entities are ALL
// selected, yellow for SOME, no highlight for NONE - uiRollout.pde).
// Pulled out as its own pure function, same reasoning as every other
// extraParams helper in this file: testable without a canvas, and
// reusable anywhere else "is this whole group selected" ever matters.
int extraParamsSelectionStateFor (ArrayList<ExtraParamsSelectionTarget> targets) {
  if (targets.size() == 0) return ExtraParamsSelectionState.NONE;

  java.util.HashSet<String> selectedKeys = new java.util.HashSet<String>();
  for (ExtraParamsSelectionTarget t : currentExtraParamsSelectionList()) {
    selectedKeys.add(t.category + ":" + t.index);
  }

  int selectedCount = 0;
  for (ExtraParamsSelectionTarget t : targets) {
    if (selectedKeys.contains(t.category + ":" + t.index)) selectedCount++;
  }

  if (selectedCount == 0) return ExtraParamsSelectionState.NONE;
  if (selectedCount == targets.size()) return ExtraParamsSelectionState.ALL;
  return ExtraParamsSelectionState.SOME;
}

// null unless exactly one entity is selected, total, across every
// category above.
ExtraParamsSelectionTarget currentExtraParamsSelection () {
  ExtraParamsSelectionTarget found = null;
  int totalSelected = 0;
  for (String category : EXTRAPARAMS_CATEGORIES) {
    int[] ids = extraParamsSelectionArrayFor(category);
    totalSelected += ids.length;
    if (ids.length == 1 && found == null) found = new ExtraParamsSelectionTarget(category, ids[0]);
  }
  return (totalSelected == 1) ? found : null;
}

// Every currently selected entity, any count (including one), across
// every category above - the PARENT_EXTRA_PARAMS "Bulk Edit" path's own counterpart to
// currentExtraParamsSelection()'s exactly-one resolver. Always in the
// same category order EXTRAPARAMS_CATEGORIES itself lists, then by each
// category's own selection-array order, so the list (and anything
// built from it, like a signature string) is deterministic frame to
// frame for the same underlying selection.
ArrayList<ExtraParamsSelectionTarget> currentExtraParamsSelectionList () {
  ArrayList<ExtraParamsSelectionTarget> found = new ArrayList<ExtraParamsSelectionTarget>();
  for (String category : EXTRAPARAMS_CATEGORIES) {
    int[] ids = extraParamsSelectionArrayFor(category);
    for (int id : ids) {
      found.add(new ExtraParamsSelectionTarget(category, id));
    }
  }
  return found;
}

// "Strip ExtraParams Selection" (actions.pde/uiMenuBar.pde)'s own real
// body - pulled out here, independently callable/testable, rather than
// left inline inside that putAction() lambda, the same reasoning every
// other action in actions.pde already follows (its own lambda is a thin
// wrapper around a real method elsewhere - Delete3D.selection(),
// allGroups.deleteEmptyGroups_Scene(), etc.). Blanks every currently
// selected entity's own extraParams back to "" (via an empty JSONObject,
// same as any other write through setExtraParamsObjectForSelection());
// entities outside the current selection are never touched - that's
// stripExtraParams_Scene()'s own job, below.
void stripExtraParams_Selection () {
  beginScene3DChange();
  for (ExtraParamsSelectionTarget t : currentExtraParamsSelectionList()) {
    setExtraParamsObjectForSelection(t, new JSONObject());
  }
  endScene3DChange();
  UI_rollout.revise();
}

// "Strip ExtraParams Scene" (actions.pde/uiMenuBar.pde)'s own real body -
// see stripExtraParams_Selection()'s own comment just above for why this
// is pulled out the same way. Every entity in the project, regardless of
// selection, across all 8 categories - each one's own stripAllExtraParams()
// (faces.pde and the seven classes alongside it), not
// currentExtraParamsSelectionList(), which only ever covers what's
// currently selected.
void stripExtraParams_Scene () {
  beginScene3DChange();
  allFaces.stripAllExtraParams();
  allPolylines.stripAllExtraParams();
  allModel1Ds.stripAllExtraParams();
  allModel2Ds.stripAllExtraParams();
  allSolids.stripAllExtraParams();
  allGroups.stripAllExtraParams();
  allCameras.stripAllExtraParams();
  allSections.stripAllExtraParams();
  endScene3DChange();
  UI_rollout.revise();
}

JSONObject getExtraParamsObjectForSelection (ExtraParamsSelectionTarget target) {
  if (target.category.equals("face")) return allFaces.getExtraParamsObject(target.index);
  if (target.category.equals("polyline")) return allPolylines.getExtraParamsObject(target.index);
  if (target.category.equals("model1d")) return allModel1Ds.getExtraParamsObject(target.index);
  if (target.category.equals("model2d")) return allModel2Ds.getExtraParamsObject(target.index);
  if (target.category.equals("solid")) return allSolids.getExtraParamsObject(target.index);
  if (target.category.equals("group")) return allGroups.getExtraParamsObject(target.index);
  if (target.category.equals("camera")) return allCameras.getExtraParamsObject(target.index);
  if (target.category.equals("section")) return allSections.getExtraParamsObject(target.index);
  return new JSONObject();
}

void setExtraParamsObjectForSelection (ExtraParamsSelectionTarget target, JSONObject obj) {
  if (target.category.equals("face")) { allFaces.setExtraParamsObject(target.index, obj); return; }
  if (target.category.equals("polyline")) { allPolylines.setExtraParamsObject(target.index, obj); return; }
  if (target.category.equals("model1d")) { allModel1Ds.setExtraParamsObject(target.index, obj); return; }
  if (target.category.equals("model2d")) { allModel2Ds.setExtraParamsObject(target.index, obj); return; }
  if (target.category.equals("solid")) { allSolids.setExtraParamsObject(target.index, obj); return; }
  if (target.category.equals("group")) { allGroups.setExtraParamsObject(target.index, obj); return; }
  if (target.category.equals("camera")) { allCameras.setExtraParamsObject(target.index, obj); return; }
  if (target.category.equals("section")) { allSections.setExtraParamsObject(target.index, obj); return; }
}
