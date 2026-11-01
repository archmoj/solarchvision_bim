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


void deleteAll () {

  allModel1Ds.makeEmpty(0);
  allModel2Ds.makeEmpty(0);

  allPolylines.makeEmpty(0);
  allFaces.makeEmpty(0);

  allPoints.makeEmpty(0);

  allSolids.makeEmpty(0);
  allSections.makeEmpty(0);
  allCameras.makeEmpty(0);

  allGroups.makeEmpty(0);
}

void model_added () {

  Select3D.selectLast();

  selection_changed();
}

volatile boolean should_rebuildFaceGrid = true;

// Centralizes every "is some multi-threaded bake currently reading
// shared state that draw()/keyPressed()/keyReleased() etc. must not
// touch right now" check into one place, rather than each guard site
// listing every bake's own flag by hand - ShadeViewport.pde's own
// isShadingViewport was the first of these, found the hard way, one
// missed call site at a time; calculate_Impact_CurrentPreBaked()'s own
// allSolarImpacts.isCalculatingImpact (SolarImpacts.pde) was added
// proactively alongside its own parallelization instead. Any future
// bake that spawns its own worker threads over shared state should add
// its own flag here too, rather than inventing a new guard pattern.
boolean isBakingInProgress () {
  return isShadingViewport || allSolarImpacts.isCalculatingImpact;
}

void model_changed () {
  should_rebuildFaceGrid = true;

  // Any structural/material edit invalidates the WIN3D retained-mode
  // caches (see Faces.pde's / Model1Ds.pde's / Land3D.pde's "WIN3D
  // retained-mode cache" blocks) - this piggybacks on model_changed()
  // rather than adding a new hook, since it's already called from every
  // create/edit/move/delete/import site for all three classes - including
  // Move3D.pde/Scale3D.pde/Rotate3D.pde's TerrainVertices() functions,
  // which edit Terrain.Mesh directly through the normal selection/move
  // system (separately from Terrain.update_mesh()'s own full-reload bump).
  if (allFaces != null) allFaces.winCacheGeneration++;
  if (allModel1Ds != null) allModel1Ds.winCacheGeneration++;
  if (Terrain != null) Terrain.winCacheGeneration++;

  view_changed();
}

void view_changed () {
  WIN3D.revise();

  // model_changed() (above) always calls this at its own end, so this one
  // check covers both triggers the sticky shaded-viewport overlay needs
  // to refresh for - a camera move (view_changed() called directly, e.g.
  // from a drag/rotate) and a model edit (model_changed() -> here) alike.
  // Only worth flagging while that overlay is actually showing -
  // WIN3D.shadingNeedsRebuild's own comment (WIN3D.pde) covers where this
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
