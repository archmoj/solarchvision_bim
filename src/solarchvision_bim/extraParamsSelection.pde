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
