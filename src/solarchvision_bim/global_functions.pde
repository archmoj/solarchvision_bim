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

boolean should_rebuildFaceGrid = true;

void model_changed () {
  should_rebuildFaceGrid = true;

  view_changed();
}

void view_changed () {
  WIN3D.revise();
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
  }
  if (allSolarImpacts.displayImage) {
    allSolarImpacts.rebuild_Image_array = true;
  }
  if (allWindRoses.displayImage) {
    allWindRoses.rebuild_Image_array = true;
  }
}

void regenerate_desired_bakings () {

  if (VertexSolar_rebuild_array) {
    calculate_VertexSolar_array();
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
