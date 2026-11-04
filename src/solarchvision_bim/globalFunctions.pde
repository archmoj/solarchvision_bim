final float FLOAT_huge = 1000000000;
final float FLOAT_tiny = 0.001; // don't use very tiny values that could result is shading problems

final String STRING_undefined = "N/A";
final float FLOAT_undefined = Float.MAX_VALUE; // it must be a positive big number that is not included in any data

boolean is_defined (float a) {
  if (a < FLOAT_undefined) {
    return true;
  }
  return false;
}

boolean is_undefined (float a) {
  return !is_defined(a);
}


boolean isInside (float x, float y, float x1, float y1, float x2, float y2) {
  if ((x1 < x) && (x < x2) && (y1 < y) && (y < y2)) {
    return true;
  }
  return false;
}


// Called from "New" (actions.pde), after holdProject() but before the
// person has even picked the new project's name/location (selectFile_New()
// only arms the async file dialog - this runs synchronously right after,
// not after that dialog resolves). Needs its own beginScene3DChange()/
// endScene3DChange() pair around the whole sequence, the same reasoning as
// Delete3D.selection()'s own comment: each of the nine makeEmpty() calls
// below is now its own complete begin/end pair (see those classes' own
// comments), and without this outer wrapping each would independently
// record its own history entry - nine spurious entries for what's one
// "start a new project" action, rather than one.
void deleteAll () {
  beginScene3DChange();

  allModel1Ds.makeEmpty(0);
  allModel2Ds.makeEmpty(0);

  allPolylines.makeEmpty(0);
  allFaces.makeEmpty(0);

  allPoints.makeEmpty(0);

  allSolids.makeEmpty(0);
  allSections.makeEmpty(0);
  allCameras.makeEmpty(0);

  allGroups.makeEmpty(0);

  endScene3DChange();

  // Resolves undoRedo.pde's own previously-open question for this path
  // too (load_project()'s own comment covers the Open/Fetch side of the
  // same question) - "New" means a genuinely fresh project, so the undo
  // history should start fresh from exactly this emptied-out state, not
  // keep referring to whatever was open before it.
  seedScene3DHistory();

  // Same reasoning, Viewport3D's own side - see
  // undoRedoViewport3D.pde's own comment on seedViewport3DHistory().
  seedViewport3DHistory();
}

void model_added () {

  Select3D.selectLast();

  selection_changed();
}

volatile boolean should_rebuildFaceGrid = true;

// Centralizes every "is some multi-threaded bake currently reading
// shared state that draw()/keyPressed()/keyReleased() etc. must not
// touch right now" check into one place, rather than each guard site
// listing every bake's own flag by hand - shadeViewport3D.pde's own
// isShadingViewport was the first of these, found the hard way, one
// missed call site at a time; calculate_Impact_CurrentPreBaked()'s own
// allSolarImpacts.isCalculatingImpact (solarImpacts.pde) was added
// proactively alongside its own parallelization instead. Any future
// bake that spawns its own worker threads over shared state should add
// its own flag here too, rather than inventing a new guard pattern.
boolean isBakingInProgress () {
  return isShadingViewport || allSolarImpacts.isCalculatingImpact;
}

// Any structural/material edit invalidates the WIN3D retained-mode
// caches (see faces.pde's / model1Ds.pde's / land3D.pde's "WIN3D
// retained-mode cache" blocks). Pulled out of endScene3DChange() into its
// own function so undoRedo.pde's restoreProjectScene3DSnapshot() can call it
// too, without going through the rest of endScene3DChange() (specifically
// commitUndoableScene3DEdit() - a restore isn't a new edit to record, it's
// replaying an old one). Without this, a plain view_changed() redraw
// after writing new face/model1D/terrain data straight into those
// classes' own arrays (which is exactly what parse_XML_variables()'s
// from_XML() calls do, same as import_objects_OBJ() in fileSelected.pde
// does for an OBJ import - see that file's own near-identical comment)
// would just replay the stale, pre-change cached PShape instead of
// rebuilding it - the actual bug behind "undo doesn't remove the house
// I just added": the data was already being reverted correctly, but
// WIN3D kept drawing the old cached geometry over top of it.
void invalidateWin3DRetainedCaches () {
  should_rebuildFaceGrid = true;

  if (allFaces != null) allFaces.winCacheGeneration++;
  if (allModel1Ds != null) allModel1Ds.winCacheGeneration++;
  if (Terrain != null) Terrain.winCacheGeneration++;
}

// Nesting depth for beginScene3DChange()/endScene3DChange() pairs - see
// beginScene3DChange()'s own comment for why this exists at all (it's
// what lets a composite action like Delete3D.selection(), which calls
// several of its own begin/end-wrapped sub-steps, record as ONE undo
// step instead of one per sub-step).
int scene3DChangeDepth = 0;

// Called at the very start of any block that's about to structurally or
// materially edit the model - every create/edit/move/delete/import site
// for Faces/Model1Ds/Model2Ds/Solids/Polylines/Points/Cameras/Sections/
// Groups/Terrain's mesh, paired with a matching endScene3DChange() (below)
// at that same block's end. This is the undo/redo pipeline's own hook
// now (undoRedo.pde's beginUndoableScene3DEdit()), specifically because it's
// guaranteed to run BEFORE the edit it's about to make - unlike
// endScene3DChange() (always after, since model_changed() used to be the
// only hook and could only ever fire post-edit). Nestable: calling this
// while already inside another begin/end pair (scene3DChangeDepth > 0)
// just increments the depth and does nothing else - only the OUTERMOST
// (0 -> 1) transition actually touches the undo history, so a composite
// function that wraps its own call to several already-wrapped sub-steps
// (Delete3D.selection() calling faceSelection() then, separately,
// isolatedVertices_Selection()) correctly records the whole thing as
// one step, as long as the composite itself also calls
// beginScene3DChange()/endScene3DChange() around the full sequence - the
// inner calls alone, without that outer wrapping, would each still
// start and finish their own step.
void beginScene3DChange () {
  if (scene3DChangeDepth == 0) {
    beginUndoableScene3DEdit();
  }
  scene3DChangeDepth++;
}

// Renamed from model_changed() - everything it already did (WIN3D cache
// invalidation, the redraw signal below) stays here, since both
// genuinely need to run AFTER the edit, once the new state actually
// exists to invalidate/redraw against. Undo/redo recording moved to
// beginScene3DChange() instead - see its own comment on why a pre-edit
// hook is what the history actually needed.
void endScene3DChange () {
  scene3DChangeDepth--;
  if (scene3DChangeDepth < 0) scene3DChangeDepth = 0; // a stray call with no matching begin - don't let it go negative and throw off every later pairing

  // This piggybacks on endScene3DChange() rather than adding a new hook,
  // since it's already called from every create/edit/move/delete/import
  // site for all three classes - including move3D.pde/scale3D.pde/
  // rotate3D.pde's TerrainVertices() functions, which edit Terrain.Mesh
  // directly through the normal selection/move system (separately from
  // Terrain.update_mesh()'s own full-reload bump).
  invalidateWin3DRetainedCaches();

  if (scene3DChangeDepth == 0) {
    commitUndoableScene3DEdit();
  }

  view_changed();
}

void view_changed () {
  WIN3D.revise();

  // endScene3DChange() (above) always calls this at its own end, so this one
  // check covers both triggers the sticky shaded-viewport overlay needs
  // to refresh for - a camera move (view_changed() called directly, e.g.
  // from a drag/rotate) and a model edit (endScene3DChange() -> here) alike.
  // Only worth flagging while that overlay is actually showing -
  // WIN3D.shadingNeedsRebuild's own comment (viewport3D.pde) covers where this
  // gets consumed and cleared again.
  if (WIN3D.showShading) WIN3D.shadingNeedsRebuild = true;
}

void selection_changed () {

  Select3D.reset_selectedRefValues();

  Select3D.revise_BoundingBox();

  view_changed();
}

void switch_category (int a) {

  currentObjectCategory = a;

  UI_toolBar.revise();

  selection_changed();
}

void modify_Viewport_Title () {

  String s = "Cam" + nf(WIN3D.currentCameraIndex, 2);

  UI_toolBar.Items[0][11] = s; // <<<<< Note: 3DViewPoint is the first index on BAR_b
  UI_toolBar.highlight(s);

  UI_toolBar.revise();
}

float applyPalDirection (float u, int PAL_direction) {
  if (PAL_direction == -1) return 1 - u;
  if (PAL_direction == -2) return 0.5 - 0.5 * u;
  if (PAL_direction == 2)  return 0.5 * u;
  return u;
}

void OBJprintVertex (float x, float y, float z) {

  float a = x * User3D.exporterScale;
  float b = y * User3D.exporterScale;
  float c = z * User3D.exporterScale;

  if (User3D.exporterYaxisUp == 0) {

    objOutput.println("v " + nf(a, 0, User3D.exporterPrecisionVertex) + " " +  nf(b, 0, User3D.exporterPrecisionVertex) + " " +  nf(c, 0, User3D.exporterPrecisionVertex));
  } else {

    objOutput.println("v " + nf(-a, 0, User3D.exporterPrecisionVertex) + " " +  nf(c, 0, User3D.exporterPrecisionVertex) + " " +  nf(b, 0, User3D.exporterPrecisionVertex));
  }
}

void OBJprintVtexture (float u, float v, float w) {

  objOutput.println("vt " + nf(u, 0, User3D.exporterPrecisionVertexTexture) + " " + nf(v, 0, User3D.exporterPrecisionVertexTexture) + " " + nf(w, 0, User3D.exporterPrecisionVertexTexture));
}

void HTMLprintVtexture (float u, float v) {

  htmlOutput.print(nf(u, 0, User3D.exporterPrecisionVertexTexture) + " " + nf(v, 0, User3D.exporterPrecisionVertexTexture));
}

void find_which_bakings_to_regenerate () {

  if (WIN3D.shadingMode == SHADE.Global_Solar) {
    GlobalSolar_rebuild_array = true;
  }

  if (WIN3D.shadingMode == SHADE.Vertex_Solar) {
    VertexSolar_rebuild_array = true;
    GlobalSolar_rebuild_array = true; // also update global to render the sky
  }

  allSolarImpacts.rebuild_Image_array = true;
  allWindRoses.rebuild_Image_array = true;
}

void regenerate_desired_bakings () {

  if (VertexSolar_rebuild_array) {
    if (WIN3D.shadingMode == SHADE.Vertex_Solar) {
      calculate_VertexSolar_array();
    }
  }

  if (GlobalSolar_rebuild_array) {
    calculate_GlobalSolar_array();
  }

}

void VertexSolar_resize_array () { // called when STUDY.endDay changes

  VertexSolar_XYZ     = new float [0][3];
  VertexSolar_amounts = new float [2][1 + STUDY.endDay - STUDY.startDay][0];

  VertexSolar_rebuild_array = false;
}

void showWaitCursor () {
  if (this.surface != null) cursor(WAIT);
}

void showArrowCursor () {
  if (this.surface != null) cursor(ARROW);
}
