HashMap<String, Runnable> menuActions;

void selectNewlyCreated(int countBefore, int countAfter, Runnable deselect, java.util.function.IntConsumer selectIndex) {
  if (countBefore == countAfter) return; // nothing created this click

  deselect.run();

  for (int o = countBefore; o < countAfter; o++) {
    selectIndex.accept(o);
  }

  Select3D.calculate_BoundingBox();
}

void stopAllRecording() {
  STUDY.record_AUTO = false;
  STUDY.record_IMG = false;
  STUDY.record_PDF = false;
  WORLD.record_AUTO = false;
  WORLD.record_IMG = false;
  WORLD.record_PDF = false;
  WIN3D.record_AUTO = false;
  WIN3D.record_IMG = false;
  FRAME_record_AUTO = false;
  FRAME_record_IMG = false;
  FRAME_click_IMG = false;
  FRAME_drag_IMG = false;
}

void setPlotImpacts(int impacts, boolean showWindRoses) {
  STUDY.PlotImpacts = impacts;
  STUDY.plotSetup = 0;
  STUDY.revise();
  allWindRoses.displayImage = showWindRoses;
  UI_rollout.revise();
}

void selectAllOfCategory(int category) {
  switch_category(category);
  Select3D.selectAll();
}

void convertAndSwitch(Runnable convert, int newCategory) {
  convert.run();
  switch_category(newCategory);
}

// Pulled out of mouseClicked()'s UITASK.Pick/Assign(sub)/Assign(all)
// handling for a clicked FACE (also reached via GROUP/POLYLINE, which
// resolve to a face index the same way): for whichever of the five
// per-face properties (Seed_Material/Tessellation/Layer/Visibility/
// Weight) WIN3D.UI_CurrentTask currently is, either reads face f's
// current value into the matching User3D.default_* (Pick,
// UI_TaskModifyParameter==1), writes User3D.default_* onto face f alone
// (Assign(sub), ==2), or writes it onto every face in f's group
// (Assign(all), ==3, via allGroups.findGroupContainingFace/
// getStart_Face/getStop_Face - already covered directly in
// GroupsTest.java). Preserved exactly as found, including one existing
// quirk: Assign(all)'s Weight case calls allFaces.setClose(...) rather
// than setWeight(...), unlike the identical-looking Pick and
// Assign(sub) cases just above it - kept as-is since this refactor
// changes structure, not behavior.
void pickOrAssignFaceProperty (int f) {
  if ((WIN3D.UI_CurrentTask != UITASK.Seed_Material) &&
      (WIN3D.UI_CurrentTask != UITASK.Tessellation) &&
      (WIN3D.UI_CurrentTask != UITASK.Layer) &&
      (WIN3D.UI_CurrentTask != UITASK.Visibility) &&
      (WIN3D.UI_CurrentTask != UITASK.Weight)) return;

  if (WIN3D.UI_TaskModifyParameter == 1) { // Pick
    if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) User3D.default_Material     = allFaces.getMaterial(f);
    else if (WIN3D.UI_CurrentTask == UITASK.Tessellation)  User3D.default_Tessellation = allFaces.getTessellation(f);
    else if (WIN3D.UI_CurrentTask == UITASK.Layer)         User3D.default_Layer        = allFaces.getLayer(f);
    else if (WIN3D.UI_CurrentTask == UITASK.Visibility)    User3D.default_Visibility   = allFaces.getVisibility(f);
    else if (WIN3D.UI_CurrentTask == UITASK.Weight)        User3D.default_Weight       = allFaces.getWeight(f);
  }
  if (WIN3D.UI_TaskModifyParameter == 2) { // Assign(sub)
    if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) allFaces.setMaterial    (f, User3D.default_Material);
    else if (WIN3D.UI_CurrentTask == UITASK.Tessellation)  allFaces.setTessellation(f, User3D.default_Tessellation);
    else if (WIN3D.UI_CurrentTask == UITASK.Layer)         allFaces.setLayer       (f, User3D.default_Layer);
    else if (WIN3D.UI_CurrentTask == UITASK.Visibility)    allFaces.setVisibility  (f, User3D.default_Visibility);
    else if (WIN3D.UI_CurrentTask == UITASK.Weight)        allFaces.setWeight      (f, User3D.default_Weight);
  }
  if (WIN3D.UI_TaskModifyParameter == 3) { // Assign(all)
    int OBJ_ID = allGroups.findGroupContainingFace(f);

    for (int q = allGroups.getStart_Face(OBJ_ID); q <= allGroups.getStop_Face(OBJ_ID); q++) {
      if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) allFaces.setMaterial    (q, User3D.default_Material);
      else if (WIN3D.UI_CurrentTask == UITASK.Tessellation)  allFaces.setTessellation(q, User3D.default_Tessellation);
      else if (WIN3D.UI_CurrentTask == UITASK.Layer)         allFaces.setLayer       (q, User3D.default_Layer);
      else if (WIN3D.UI_CurrentTask == UITASK.Visibility)    allFaces.setVisibility  (q, User3D.default_Visibility);
      else if (WIN3D.UI_CurrentTask == UITASK.Weight)        allFaces.setClose       (q, User3D.default_Weight);
    }
  }
}

// Pulled out of mouseClicked()'s UITASK.Seed_Material handling for a
// clicked MODEL2D instance: MODEL2D's own MAP[] encodes both which
// PEOPLE/TREES filename an instance uses (abs(MAP[OBJ_ID])) and a
// left/right-facing flip (its sign) in one int. Pick
// (UI_TaskModifyParameter==1) reads the clicked instance's own type
// into User3D.create_Plant_Type or create_Person_Type depending on
// allModel2Ds.isTree(); Assign (==2 or ==3 - both treated identically
// here, unlike the FACE property case above) writes the current
// create_Plant_Type/create_Person_Type back onto MAP[OBJ_ID], carrying
// that instance's own sign (its flip) forward unchanged.
void pickOrAssignModel2DSeedMaterial (int OBJ_ID) {
  if (WIN3D.UI_CurrentTask != UITASK.Seed_Material) return;

  int n = allModel2Ds.MAP[OBJ_ID];
  int sign_n = 1;
  if (n < 0) sign_n = -1;
  n = abs(n);
  int n1 = allModel2Ds.num_files_PEOPLE;

  if (WIN3D.UI_TaskModifyParameter == 1) { // Pick
    if (allModel2Ds.isTree(n)) { // case: trees
      User3D.create_Plant_Type = n - n1;
    }
    else { // case: people
      User3D.create_Person_Type = n;
    }
  }
  if ((WIN3D.UI_TaskModifyParameter == 2) || (WIN3D.UI_TaskModifyParameter == 3)) { // Assign
    if (allModel2Ds.isTree(n)) { // case: trees
      allModel2Ds.MAP[OBJ_ID] = sign_n * (User3D.create_Plant_Type + n1);
    }
    else { // case: people
      allModel2Ds.MAP[OBJ_ID] = sign_n * User3D.create_Person_Type;
    }
  }
}

// Pulled out of mouseClicked()'s handling for a clicked MODEL1D
// instance: for whichever of the seven per-tree properties
// (DegreeMax/BranchTilt/BranchTwist/BranchRatio/TreeBase/TrunkSize/
// LeafSize) WIN3D.UI_CurrentTask currently is - or all of them at once,
// for UITASK.Model1DsProps - either reads OBJ_ID's current value(s)
// into the matching User3D.create_Model1D_* (Pick,
// UI_TaskModifyParameter==1) or writes the matching User3D.create_
// Model1D_* value(s) back onto OBJ_ID (Assign, ==2).
void pickOrAssignModel1DProperty (int OBJ_ID) {
  if (WIN3D.UI_TaskModifyParameter == 1) { // Pick
    if (WIN3D.UI_CurrentTask == UITASK.DegreeMax) User3D.create_Model1D_DegreeMax = allModel1Ds.getDegreeMax(OBJ_ID);
    else if (WIN3D.UI_CurrentTask == UITASK.BranchTilt) User3D.create_Model1D_BranchTilt = allModel1Ds.getBranchTilt(OBJ_ID);
    else if (WIN3D.UI_CurrentTask == UITASK.BranchTwist) User3D.create_Model1D_BranchTwist = allModel1Ds.getBranchTwist(OBJ_ID);
    else if (WIN3D.UI_CurrentTask == UITASK.BranchRatio) User3D.create_Model1D_BranchRatio = allModel1Ds.getBranchRatio(OBJ_ID);
    else if (WIN3D.UI_CurrentTask == UITASK.TreeBase) User3D.create_Model1D_TreeBase = allModel1Ds.getTreeBase(OBJ_ID);

    else if (WIN3D.UI_CurrentTask == UITASK.TrunkSize) User3D.create_Model1D_TrunkSize = allModel1Ds.getTrunkSize(OBJ_ID);
    else if (WIN3D.UI_CurrentTask == UITASK.LeafSize) User3D.create_Model1D_LeafSize = allModel1Ds.getLeafSize(OBJ_ID);
    else if (WIN3D.UI_CurrentTask == UITASK.Model1DsProps) { // all properties
      User3D.create_Model1D_DegreeMax = allModel1Ds.getDegreeMax(OBJ_ID);
      User3D.create_Model1D_TrunkSize = allModel1Ds.getTrunkSize(OBJ_ID);
      User3D.create_Model1D_LeafSize = allModel1Ds.getLeafSize(OBJ_ID);
    }
  }
  if (WIN3D.UI_TaskModifyParameter == 2) { // Assign
    if (WIN3D.UI_CurrentTask == UITASK.DegreeMax) allModel1Ds.setDegreeMax(OBJ_ID, User3D.create_Model1D_DegreeMax);
    else if (WIN3D.UI_CurrentTask == UITASK.BranchTilt) allModel1Ds.setBranchTilt(OBJ_ID, User3D.create_Model1D_BranchTilt);
    else if (WIN3D.UI_CurrentTask == UITASK.BranchTwist) allModel1Ds.setBranchTwist(OBJ_ID, User3D.create_Model1D_BranchTwist);
    else if (WIN3D.UI_CurrentTask == UITASK.BranchRatio) allModel1Ds.setBranchRatio(OBJ_ID, User3D.create_Model1D_BranchRatio);
    else if (WIN3D.UI_CurrentTask == UITASK.TreeBase) allModel1Ds.setTreeBase(OBJ_ID, User3D.create_Model1D_TreeBase);

    else if (WIN3D.UI_CurrentTask == UITASK.TrunkSize) allModel1Ds.setTrunkSize(OBJ_ID, User3D.create_Model1D_TrunkSize);
    else if (WIN3D.UI_CurrentTask == UITASK.LeafSize) allModel1Ds.setLeafSize(OBJ_ID, User3D.create_Model1D_LeafSize);
    else if (WIN3D.UI_CurrentTask == UITASK.Model1DsProps) { // all properties
      allModel1Ds.setDegreeMax(OBJ_ID, User3D.create_Model1D_DegreeMax);
      allModel1Ds.setTrunkSize(OBJ_ID, User3D.create_Model1D_TrunkSize);
      allModel1Ds.setLeafSize(OBJ_ID, User3D.create_Model1D_LeafSize);
    }
  }
}

// Pulled out of mouseClicked()'s UITASK.Move handling: for whichever
// object category is currently selected, finds the single reference
// point a move should be measured from - the selection's own pivot for
// a GROUP (via Select3D.getPivot(), already covered directly in
// Select3DTest.java), or the position of the LAST selected id for
// MODEL2D/MODEL1D/SOLID/VERTEX (matching the original: only ever the
// last one, even for a multi-object selection). Returns
// {FLOAT_undefined, FLOAT_undefined, FLOAT_undefined} for any other
// category (POLYLINE, FACE, CAMERA, SECTION, LANDPOINT), same as the
// original inline code left x1/y1/z1 unset (and therefore "undefined")
// for those.
float[] getMoveOriginPoint () {
  float x1 = FLOAT_undefined;
  float y1 = FLOAT_undefined;
  float z1 = FLOAT_undefined;

  if (current_ObjectCategory == ObjectCategory.GROUP) {

    float[] P = Select3D.getPivot();

    x1 = P[0];
    y1 = P[1];
    z1 = P[2];
  } else if (current_ObjectCategory == ObjectCategory.MODEL2D) {

    x1 = allModel2Ds.getX(Select3D.Model2D_ids[Select3D.Model2D_ids.length - 1]);
    y1 = allModel2Ds.getY(Select3D.Model2D_ids[Select3D.Model2D_ids.length - 1]);
    z1 = allModel2Ds.getZ(Select3D.Model2D_ids[Select3D.Model2D_ids.length - 1]);
  } else if (current_ObjectCategory == ObjectCategory.MODEL1D) {

    x1 = allModel1Ds.getX(Select3D.Model1D_ids[Select3D.Model1D_ids.length - 1]);
    y1 = allModel1Ds.getY(Select3D.Model1D_ids[Select3D.Model1D_ids.length - 1]);
    z1 = allModel1Ds.getZ(Select3D.Model1D_ids[Select3D.Model1D_ids.length - 1]);
  } else if (current_ObjectCategory == ObjectCategory.SOLID) {

    x1 = allSolids.get_posX(Select3D.Solid_ids[Select3D.Solid_ids.length - 1]);
    y1 = allSolids.get_posY(Select3D.Solid_ids[Select3D.Solid_ids.length - 1]);
    z1 = allSolids.get_posZ(Select3D.Solid_ids[Select3D.Solid_ids.length - 1]);
  } else if (current_ObjectCategory == ObjectCategory.VERTEX) {

    x1 = allPoints.getX(Select3D.Vertex_ids[Select3D.Vertex_ids.length - 1]);
    y1 = allPoints.getY(Select3D.Vertex_ids[Select3D.Vertex_ids.length - 1]);
    z1 = allPoints.getZ(Select3D.Vertex_ids[Select3D.Vertex_ids.length - 1]);
  }

  return new float[]{x1, y1, z1};
}

// Pulled out of mouseClicked()'s UITASK.Move handling: the move vector
// from (x1,y1,z1) to (x2,y2,z2), then zeroed down to a single axis
// according to Select3D.posVector - 0 keeps only X, 1 keeps only Y, 2
// keeps only Z (posVector's own default), and any other value
// (typically 3, meaning "All") leaves all three components as-is.
float[] computeMoveDelta (float x1, float y1, float z1, float x2, float y2, float z2) {
  float dx = x2 - x1;
  float dy = y2 - y1;
  float dz = z2 - z1;

  int the_Vector = Select3D.posVector;

  if (the_Vector == 0) {
    dy = 0;
    dz = 0;
  }
  if (the_Vector == 1) {
    dz = 0;
    dx = 0;
  }
  if (the_Vector == 2) {
    dx = 0;
    dy = 0;
  }

  return new float[]{dx, dy, dz};
}

// Which of add_ParametricSurface/add_SuperCylinder/add_Box_Core/
// add_Octahedron/add_SuperSphere a SuperOBJ create should call -
// returned by classifySuperOBJShape below.
final int SUPEROBJ_SHAPE_PARAMETRIC = 0;
final int SUPEROBJ_SHAPE_SUPERCYLINDER = 1;
final int SUPEROBJ_SHAPE_BOX = 2;
final int SUPEROBJ_SHAPE_OCTAHEDRON = 3;
final int SUPEROBJ_SHAPE_SUPERSPHERE = 4; // the fallback: anything not matching one of the other four

// Pulled out of mouseClicked()'s CREATE.SuperOBJ handling: SuperOBJ's
// px/py/pz power-exponents double as a shape picker - certain exact
// combinations (checked in this order, first match wins) mean "this is
// really a parametric surface / cylinder / box / octahedron in
// disguise", and Create3D has a dedicated, more efficient add_X() for
// each of those instead of going through the general (and heavier)
// add_SuperSphere() every other combination falls through to. Purely
// the classification, not the actual creation - so it's testable
// without touching the scene at all.
int classifySuperOBJShape (float px, float py, float pz) {
  if ((px == CubePower) && (py == CubePower) && (pz == 2)) {
    return SUPEROBJ_SHAPE_PARAMETRIC;
  } else if ((px == 2) && (py == 2) && (pz == CubePower)) {
    return SUPEROBJ_SHAPE_SUPERCYLINDER;
  } else if ((px == CubePower) && (py == CubePower) && (pz == CubePower)) {
    return SUPEROBJ_SHAPE_BOX;
  } else if ((px == 1) && (py == 1) && (pz == 1)) {
    return SUPEROBJ_SHAPE_OCTAHEDRON;
  } else {
    return SUPEROBJ_SHAPE_SUPERSPHERE;
  }
}

// Result of computeClickRay below: a 3D ray (a start
// point plus a direction) corresponding to a click at 3D-viewport-local
// coordinates (Image_X, Image_Y) - i.e. mouseX/mouseY already offset by
// the viewport's own center, as WIN3D.calculate_Click3D expects.
class ClickRay {
  float[] start;
  float[] direction = new float [3];
}

// Pulled out of mouseClicked()'s WIN3D-picking handling. Confirmed
// character-for-character identical (modulo `this.` vs `WIN3D.` on the
// fields it reads, since one copy lived inside the WIN3D class itself)
// to WIN3D.rotateXY_3DViewport_around_LandIntersection()'s own inline
// ray setup before extracting - both replaced with a call to this. A
// third, near-identical copy in mouseReleased.pde's castClickToWorld()
// was later pointed at this too.
// Turns a click point into a ray in WORLD (unscaled, i.e. /
// OBJECTS_scale) space: starts at the current camera position, aimed
// through WIN3D.calculate_Click3D(Image_X, Image_Y) (already covered
// directly in WIN3DTest.java) - except in orthographic view (ViewType
// == 0), where there's no real camera point to start from, so the
// start point is instead offset from the camera position by however far
// calculate_Click3D(Image_X, Image_Y) itself differs from
// calculate_Click3D(0, 0), keeping parallel rays parallel.
ClickRay computeClickRay (float Image_X, float Image_Y) {
  ClickRay ray = new ClickRay();

  float[] ray_start = {
    WIN3D.CAM_x, WIN3D.CAM_y, WIN3D.CAM_z
  };

  float[] ray_end = WIN3D.calculate_Click3D(Image_X, Image_Y);

  ray_start[0] /= OBJECTS_scale;
  ray_start[1] /= OBJECTS_scale;
  ray_start[2] /= OBJECTS_scale;

  ray_end[0] /= OBJECTS_scale;
  ray_end[1] /= OBJECTS_scale;
  ray_end[2] /= OBJECTS_scale;

  if (WIN3D.ViewType == 0) {
    float[] ray_center = WIN3D.calculate_Click3D(0, 0);

    ray_center[0] /= OBJECTS_scale;
    ray_center[1] /= OBJECTS_scale;
    ray_center[2] /= OBJECTS_scale;

    ray_start[0] += ray_end[0] - ray_center[0];
    ray_start[1] += ray_end[1] - ray_center[1];
    ray_start[2] += ray_end[2] - ray_center[2];
  }

  ray.start = ray_start;
  ray.direction[0] = ray_end[0] - ray_start[0];
  ray.direction[1] = ray_end[1] - ray_start[1];
  ray.direction[2] = ray_end[2] - ray_start[2];

  return ray;
}

// Result of computeCreateParams below: the concrete
// position/rotation/half-extents/power-exponents a click should create
// an object with, derived from the click point (RxP) and the user's
// current create_* preferences.
class CreateParams {
  float x, y, z, rot, rx, ry, rz, px, py, pz;
}

// Pulled out of mouseClicked()'s UITASK.Create handling: turns a click's
// hit point (RxP) plus User3D's create_* preferences into the concrete
// x/y/z/rot/rx/ry/rz/px/py/pz values every CREATE.* branch downstream
// then reads (but never further recomputes) to actually build the new
// object via Create3D.add_X()/allModel1Ds.create()/etc. Those add_X()
// calls are already covered directly in Create3DTest.java, so this
// extraction focuses purely on the parameter derivation that used to sit
// in front of them, previously untested on its own. Note this can call
// random() in two places (when create_Length/Width/Height is negative,
// meaning "randomize within this range", and when create_powRnd is on) -
// callers that want a fully deterministic result should use non-negative
// lengths and turn create_powRnd off.
CreateParams computeCreateParams (float[] RxP) {
  CreateParams p = new CreateParams();

  p.x = RxP[1];
  p.y = RxP[2];
  p.z = RxP[3];

  p.rot = User3D.create_Orientation;
  if (p.rot == 360) p.rot = WIN3D.rotation_Z;

  p.rx = 0.5 * User3D.create_Length;
  if (p.rx < 0) p.rx = random(0.25 * abs(p.rx), abs(p.rx));

  p.ry = 0.5 * User3D.create_Width;
  if (p.ry < 0) p.ry = random(0.25 * abs(p.ry), abs(p.ry));

  p.rz = 0.5 * User3D.create_Height;
  if (p.rz < 0) p.rz = random(0.25 * abs(p.rz), abs(p.rz));

  p.px = User3D.create_powX;
  p.py = User3D.create_powY;
  p.pz = User3D.create_powZ;

  if (User3D.create_powRnd == 1) {
    p.px = pow(2, int(random(5)) - 1);
    p.py = p.px;
    p.pz = p.px;
  }

  if (User3D.create_Volume != 0) {

    if ((p.rx != 0) && (p.ry != 0)) {
      p.rz = User3D.create_Volume / (8 * p.rx * p.ry);
    }

    //---------------------------------------------------
    float A = 1;
    // cube volume: 8*r^3, sphere volume: 4*r^3, so maybe:
    if (p.pz >= 8) A = 1;
    else if (p.pz == 4) A = 0.75;
    else if (p.pz == 2) A = 0.5;
    else if (p.pz == 1) A = 0.25;
    else if (p.pz == 0.5) A = 0.125;
    else if (p.pz == 0.25) A = 0.0625;

    p.rx /= pow(A, (1.0 / 3.0));
    p.ry /= pow(A, (1.0 / 3.0));
    p.rz /= pow(A, (1.0 / 3.0));
    //---------------------------------------------------
  }

  if ((current_ObjectCategory != ObjectCategory.MODEL1D) &&
      (current_ObjectCategory != ObjectCategory.MODEL2D) &&
      (current_ObjectCategory != ObjectCategory.LANDPOINT) &&
      (current_ObjectCategory != ObjectCategory.CAMERA) &&
      (current_ObjectCategory != ObjectCategory.SECTION)) {

    p.x -= p.rx * Select3D.alignX;
    p.y -= p.ry * Select3D.alignY;
    p.z -= p.rz * Select3D.alignZ;
  }

  return p;
}

// Result of computeCameraParamsAtPoint below: the camera
// transform (position/rotation/zoom/type) that would put a camera's eye
// at a given 3D point, looking the same direction as the current
// viewport.
class CameraParams {
  float pX, pY, pZ, pT, rX, rY, rZ, rT, zoom;
  int type;
}

// Pulled out of mouseClicked()'s "create a camera" handling: computes
// what a new camera's own position_X/Y/Z/T and rotation_X/Y/Z/T would be
// if its eye sat at (x, y, z + EyeLevel), by temporarily overwriting
// WIN3D's own CAM_x/y/z and calling its (already directly tested in
// WIN3DTest.java) reverseTransform_3DViewport(), then restoring every
// WIN3D field it touched back to what it was - this function's caller
// used to do that save/compute/restore dance inline, right before
// allCameras.create(); now it just calls this and passes the result
// straight through.
CameraParams computeCameraParamsAtPoint (float x, float y, float z) {
  float keep_CAM_x = WIN3D.CAM_x;
  float keep_CAM_y = WIN3D.CAM_y;
  float keep_CAM_z = WIN3D.CAM_z;
  float keep_position_X = WIN3D.position_X;
  float keep_position_Y = WIN3D.position_Y;
  float keep_position_Z = WIN3D.position_Z;
  float keep_position_T = WIN3D.position_T;
  float keep_rotation_X = WIN3D.rotation_X;
  float keep_rotation_Y = WIN3D.rotation_Y;
  float keep_rotation_Z = WIN3D.rotation_Z;
  float keep_rotation_T = WIN3D.rotation_T;
  float keep_Zoom = WIN3D.Zoom;

  WIN3D.CAM_x = x;
  WIN3D.CAM_y = y;
  WIN3D.CAM_z = z + EyeLevel;

  WIN3D.reverseTransform_3DViewport();

  CameraParams cp = new CameraParams();
  cp.pX = WIN3D.position_X;
  cp.pY = WIN3D.position_Y;
  cp.pZ = WIN3D.position_Z;
  cp.pT = WIN3D.position_T;
  cp.rX = WIN3D.rotation_X;
  cp.rY = WIN3D.rotation_Y;
  cp.rZ = WIN3D.rotation_Z;
  cp.rT = WIN3D.rotation_T;
  cp.zoom = WIN3D.Zoom;
  cp.type = WIN3D.ViewType;

  WIN3D.CAM_x = keep_CAM_x;
  WIN3D.CAM_y = keep_CAM_y;
  WIN3D.CAM_z = keep_CAM_z;
  WIN3D.position_X = keep_position_X;
  WIN3D.position_Y = keep_position_Y;
  WIN3D.position_Z = keep_position_Z;
  WIN3D.position_T = keep_position_T;
  WIN3D.rotation_X = keep_rotation_X;
  WIN3D.rotation_Y = keep_rotation_Y;
  WIN3D.rotation_Z = keep_rotation_Z;
  WIN3D.rotation_T = keep_rotation_T;
  WIN3D.Zoom = keep_Zoom;

  return cp;
}

// Result of computeSectionParams below: the plane
// parameters (position, rotation, extents, and which of horizontal/
// vertical it is) for a new section, plus whether one should actually
// be created at all.
class SectionParams {
  float X, Y, Z, R, U, V;
  int Type, RES1, RES2;
  boolean createNew = false;
}

// Pulled out of mouseClicked()'s "create a section" handling. Two very
// different cases, both preserved exactly as they were:
//  - Right-click: always creates a horizontal (Type 1) section centered
//    exactly at the click point, at allSolidImpacts' current resolution.
//  - Left-click on a face with more than 2 nodes: derives the section's
//    own plane from the FACE's geometry instead - rotates the face flat
//    to find its own minimum bounding rectangle (via each edge's own
//    angle, "min_Beta"), decides horizontal vs. vertical based on
//    whichever axis is thinnest, then does a second pass (rebuilding the
//    face's centroid/normal and comparing it against the resulting
//    section plane's own normal via allSections.getCorners(), already
//    covered directly in SectionsTest.java) to detect and correct a
//    section built "backwards" relative to the face it came from.
//  - Left-click on a face with 2 or fewer nodes, or when neither mouse
//    button matches: createNew stays false and every other field is left
//    at allSolidImpacts' current defaults, matching the original code's
//    "nothing happens" outcome for that case.
SectionParams computeSectionParams (int f, float[] RxP) {
  SectionParams sp = new SectionParams();

  sp.X = allSolidImpacts.X[allSolidImpacts.sectionType];
  sp.Y = allSolidImpacts.Y[allSolidImpacts.sectionType];
  sp.Z = allSolidImpacts.Z[allSolidImpacts.sectionType];
  sp.R = allSolidImpacts.R[allSolidImpacts.sectionType];
  sp.U = allSolidImpacts.U[allSolidImpacts.sectionType];
  sp.V = allSolidImpacts.V[allSolidImpacts.sectionType];

  sp.Type = allSolidImpacts.sectionType;
  sp.RES1 = allSolidImpacts.RES1;
  sp.RES2 = allSolidImpacts.RES2;

  if (mouseButton == LEFT) {

    int n = allFaces.nodes[f].length;

    if (n > 2) {

      float min_Beta = 360;

      for (int j = 0; j < n; j++) {

        int j_next = (j + 1) % n;

        float x1 = allPoints.getX(allFaces.nodes[f][j]);
        float y1 = allPoints.getY(allFaces.nodes[f][j]);

        float x2 = allPoints.getX(allFaces.nodes[f][j_next]);
        float y2 = allPoints.getY(allFaces.nodes[f][j_next]);

        float Beta = funcs.atan2_ang(y2 - y1, x2 - x1) + 90;

        if (min_Beta > Beta) min_Beta = Beta;
      }

      float[][] tmpVertices = new float[n][3];

      for (int j = 0; j < n; j++) {

        float x1 = allPoints.getX(allFaces.nodes[f][j]);
        float y1 = allPoints.getY(allFaces.nodes[f][j]);
        float z1 = allPoints.getZ(allFaces.nodes[f][j]);

        float x2 = x1 * funcs.cos_ang(-min_Beta) - y1 * funcs.sin_ang(-min_Beta);
        float y2 = x1 * funcs.sin_ang(-min_Beta) + y1 * funcs.cos_ang(-min_Beta);
        float z2 = z1;

        tmpVertices[j][0] = x2;
        tmpVertices[j][1] = y2;
        tmpVertices[j][2] = z2;
      }

      float min_x = FLOAT_undefined;
      float max_x = -FLOAT_undefined;
      float min_y = FLOAT_undefined;
      float max_y = -FLOAT_undefined;
      float min_z = FLOAT_undefined;
      float max_z = -FLOAT_undefined;

      float[] G = {
        0, 0, 0
      };
      for (int j = 0; j < n; j++) {
        float the_x = tmpVertices[j][0];
        float the_y = tmpVertices[j][1];
        float the_z = tmpVertices[j][2];

        G[0] += the_x / float(n);
        G[1] += the_y / float(n);
        G[2] += the_z / float(n);

        if (min_x > the_x) min_x = the_x;
        if (max_x < the_x) max_x = the_x;
        if (min_y > the_y) min_y = the_y;
        if (max_y < the_y) max_y = the_y;
        if (min_z > the_z) min_z = the_z;
        if (max_z < the_z) max_z = the_z;
      }

      if ((max_z - min_z < max_x - min_x) && (max_z - min_z < max_y - min_y)) {
        sp.Type = 1;

        sp.U = max_x - min_x;
        sp.V = max_y - min_y;

        sp.X = G[0];
        sp.Y = G[1];

        sp.Z = G[2];

        sp.R = min_Beta;
      } else {
        sp.Type = 2;

        sp.U = max_y - min_y;
        sp.V = max_z - min_z;

        sp.X = -G[1];
        sp.Y = G[2];

        sp.Z = -G[0];

        sp.R = 90 - min_Beta;
      }

      // recalculating G...
      G[0] = 0;
      G[1] = 0;
      G[2] = 0;
      for (int j = 0; j < n; j++) {
        float the_x = allPoints.getX(allFaces.nodes[f][j]);
        float the_y = allPoints.getY(allFaces.nodes[f][j]);
        float the_z = allPoints.getZ(allFaces.nodes[f][j]);

        G[0] += the_x / float(n);
        G[1] += the_y / float(n);
        G[2] += the_z / float(n);
      }

      PVector AG = new PVector(allPoints.getX(allFaces.nodes[f][0]) - G[0], allPoints.getY(allFaces.nodes[f][0]) - G[1], allPoints.getZ(allFaces.nodes[f][0]) - G[2]);
      PVector BG = new PVector(allPoints.getX(allFaces.nodes[f][1]) - G[0], allPoints.getY(allFaces.nodes[f][1]) - G[1], allPoints.getZ(allFaces.nodes[f][1]) - G[2]);

      PVector GAxGB = AG.cross(BG);

      float[][] ImageVertex = allSections.getCorners(sp.Type, sp.X, sp.Y, sp.Z, sp.R, sp.U, sp.V, sp.RES1, sp.RES2);

      float[] SectionCorner_A = ImageVertex[1];
      float[] SectionCorner_B = ImageVertex[2];
      float[] SectionCorner_C = ImageVertex[3];
      float[] SectionCorner_D = ImageVertex[4];

      float[] ImageCenter = {
        0, 0, 0
      };
      for (int j = 0; j < 3; j++) {
        ImageCenter[j] = 0.25 * (SectionCorner_A[j] + SectionCorner_B[j] + SectionCorner_C[j] + SectionCorner_D[j]);
      }

      PVector AG_other = new PVector(SectionCorner_A[0] - ImageCenter[0], SectionCorner_A[1] - ImageCenter[1], SectionCorner_A[2] - ImageCenter[2]);
      PVector BG_other = new PVector(SectionCorner_B[0] - ImageCenter[0], SectionCorner_B[1] - ImageCenter[1], SectionCorner_B[2] - ImageCenter[2]);

      PVector GAxGB_other = AG_other.cross(BG_other);

      float V = GAxGB_other.dot(GAxGB);

      if (V < 0) {
        //println("flip face!");

        sp.R = 180 + sp.R;
        sp.Z *= -1;
        sp.X *= -1;
      } else {
        //println("face OK!");
      }

      sp.createNew = true;
    }
  }

  if (mouseButton == RIGHT) {

    sp.Type = 1;

    sp.X = RxP[1];
    sp.Y = RxP[2];
    sp.Z = RxP[3];

    sp.createNew = true;
  }

  return sp;
}

// Decides whether face `f`'s node order should be reversed (to flip
// which way it faces) and applies that reversal if so - pulled out of
// mouseClicked()'s UITASK.Normal handling, which ran this exact 40-line
// block twice in a row: once for a single clicked face (using `f`
// directly) and once in a loop over every face `q` owned by the clicked
// face's group (confirmed identical modulo the face-index variable name
// before extracting). UI_TaskModifyParameter selects the mode: 1 always
// flips; 2 flips only if the pivot sits on the positive side of the
// face's own (first-corner, second-corner, centroid) winding plane; 3
// flips only if it sits on the negative side.
void flipFaceOrientationIfNeeded (int f) {
  int n = allFaces.nodes[f].length;
  if (n <= 2) return;

  int[] tmpFace = new int[n];
  float[] G = {
    0, 0, 0
  };
  for (int j = 0; j < n; j++) {
    tmpFace[j] = allFaces.nodes[f][j];
    G[0] += allPoints.getX(tmpFace[j]) / float(n);
    G[1] += allPoints.getY(tmpFace[j]) / float(n);
    G[2] += allPoints.getZ(tmpFace[j]) / float(n);
  }

  int flip_face = 0;
  if (WIN3D.UI_TaskModifyParameter == 1) flip_face = 1;
  else {
    PVector AG = new PVector(allPoints.getX(tmpFace[0]) - G[0], allPoints.getY(tmpFace[0]) - G[1], allPoints.getZ(tmpFace[0]) - G[2]);
    PVector BG = new PVector(allPoints.getX(tmpFace[1]) - G[0], allPoints.getY(tmpFace[1]) - G[1], allPoints.getZ(tmpFace[1]) - G[2]);

    PVector GAxGB = AG.cross(BG);

    float[] P = Select3D.getPivot();

    float x0 = P[0];
    float y0 = P[1];
    float z0 = P[2];

    PVector PG = new PVector(x0 - G[0], y0 - G[1], z0 - G[2]);

    float V = PG.dot(GAxGB);

    if (WIN3D.UI_TaskModifyParameter == 2) {
      if (V > 0) flip_face = 1;
    }
    if (WIN3D.UI_TaskModifyParameter == 3) {
      if (V < 0) flip_face = 1;
    }
  }

  if (flip_face == 1) {
    for (int j = 0; j < n; j++) {
      allFaces.nodes[f][j] = tmpFace[n - j - 1];
    }
  }
}

// Rotates a face's or polyline's own node array in place so whichever
// vertex is nearest to the click point `RxP` (its own [1],[2],[3] being
// the hit's x,y,z) becomes node 0, preserving winding order otherwise -
// pulled out of mouseClicked()'s UITASK.FirstVertex handling, which ran
// this exact block twice in a row: once against allFaces.nodes[f] (with
// Select3D.Face_ids/Face_displayVertexCount) and once against
// allPolylines.nodes[f] (with Select3D.Polyline_ids/
// Polyline_displayVertexCount), confirmed identical modulo which array
// before extracting. `nodeRow` is mutated directly (Java arrays are
// passed by reference), so the caller doesn't need to reassign anything.
void rotateNodesToStartAtNearestVertex (int[] nodeRow, float[] RxP) {
  int n = nodeRow.length;
  if (n <= 2) return;

  int min_num = 0;
  float min_dist = FLOAT_undefined;

  for (int j = 0; j < n; j++) {
    int vNo = nodeRow[j];
    float d = dist(RxP[1], RxP[2], RxP[3], allPoints.getX(vNo), allPoints.getY(vNo), allPoints.getZ(vNo));

    if (min_dist > d) {
      min_dist = d;
      min_num = j;
    }
  }

  int[] tmpRow = new int[n];
  for (int j = 0; j < n; j++) {
    tmpRow[j] = nodeRow[j];
  }

  for (int j = 0; j < n; j++) {
    nodeRow[j] = tmpRow[(j + min_num + n) % n];
  }
}

// Result of a nearest-station search: which index in the array was closest, and how far (in the
// same units funcs.lon_lat_dist returns) it was from STATION's current position.
class NearestStation {
  int index = -1;
  float dist = FLOAT_undefined;
}

// Shared by the SWOB/NAEFS/CWEEDS/CLMREC/TMYEPW "which station did the user click nearest to"
// lookups in mouseClicked(): scans `coords` and returns the index (and distance) of whichever
// station is closest to STATION's current longitude/latitude.
NearestStation findNearestStation (STATION[] coords) {

  NearestStation nearest = new NearestStation();

  for (int f = 0; f < coords.length; f++) {

    float _lat = coords[f].getLatitude();
    float _lon = coords[f].getLongitude();
    if (_lon > 180) _lon -= 360; // << important!

    float d = funcs.lon_lat_dist(_lon, _lat, STATION.getLongitude(), STATION.getLatitude());

    if (nearest.dist > d) {
      nearest.dist = d;
      nearest.index = f;
    }
  }

  return nearest;
}

// Like findNearestStation, but returns up to `maxCount` indices
// of stations within `maxDist` (same units as funcs.lon_lat_dist) of the
// given (lon, lat), sorted by ascending distance. Used to detect when
// several TMYEPW stations sit close enough together that a click can't
// unambiguously pick one, so they can be offered as a list instead.
int[] findNearbyStations (STATION[] coords, float lon, float lat, float maxDist, int maxCount) {

  IntList indices = new IntList();
  FloatList dists = new FloatList();

  for (int f = 0; f < coords.length; f++) {

    float _lat = coords[f].getLatitude();
    float _lon = coords[f].getLongitude();
    if (_lon > 180) _lon -= 360; // << important!

    float d = funcs.lon_lat_dist(_lon, _lat, lon, lat);

    if (d <= maxDist) {
      indices.append(f);
      dists.append(d);
    }
  }

  // Insertion sort by ascending distance - candidate counts here are tiny.
  for (int i = 1; i < indices.size(); i++) {
    int idx = indices.get(i);
    float dist = dists.get(i);
    int j = i - 1;
    while ((j >= 0) && (dists.get(j) > dist)) {
      indices.set(j + 1, indices.get(j));
      dists.set(j + 1, dists.get(j));
      j--;
    }
    indices.set(j + 1, idx);
    dists.set(j + 1, dist);
  }

  int n = min(indices.size(), maxCount);
  int[] result = new int[n];
  for (int i = 0; i < n; i++) {
    result[i] = indices.get(i);
  }
  return result;
}

// --- "Multiple nearby stations" picker, generalized across datasets ---
//
// When a WORLD click finds more than one station of the *active* dataset
// within that dataset's own distance threshold, we show up to maxCount of
// them as a clickable list inside the WORLD view instead of silently
// guessing one, and wait for a follow-up click on one of the list rows to
// choose it. Since the list can hold more rows than fit in WORLD's
// viewport, it scrolls, with a vertical scrollbar that can be dragged,
// clicked (to page), or operated with the mouse wheel. Originally built
// just for TMYEPW; each dataset gets its own instance below, configured
// with its own distance threshold, row-label text, and selection
// behavior - at most one can ever be showing at a time, since a picker
// only opens while its own dataset is the active CurrentDataSource.

final float PICKLIST_SCROLLBAR_WIDTH = 14;
final float pad = 1.6 * MessageSize;
final float rowHeight = 1.6 * MessageSize;
final float headerHeight = 1.6 * MessageSize;

abstract class StationPicker {

  String name;      // shown in the title bar, e.g. "Pick TMYEPW Station"
  float maxDist;    // metres
  int maxCount;
  int dataSourceID; // only offer the list while CurrentDataSource == this

  boolean active = false;
  int[] indices = new int[0];
  float mouseLon = 0;
  float mouseLat = 0;
  int scrollOffset = 0; // index (into indices) of the first visible row

  boolean scrollThumbDragging = false;
  float scrollDrag_startMouseY = 0;
  int scrollDrag_startOffset = 0;

  StationPicker (String name, float maxDist, int maxCount, int dataSourceID) {
    this.name = name;
    this.maxDist = maxDist;
    this.maxCount = maxCount;
    this.dataSourceID = dataSourceID;
  }

  // Supplied per dataset below. getCoords() reads the dataset's global
  // coordinates array live (e.g. `return TMYEPW_Coordinates;`) rather
  // than this class capturing it once at construction time - these
  // pickers are themselves top-level field initializers, which Processing
  // runs before setup() has populated the actual coordinate arrays (they
  // start out null and are only filled in later by e.g.
  // inputCoordinates_TMYEPW()), so capturing the array in the constructor
  // would have permanently captured null.
  abstract STATION[] getCoords ();
  abstract String getLabel (int f);
  abstract void select (int f, float lon, float lat);

  boolean needsScrollbar () {
    return this.indices.length > this.visibleRowCount();
  }

  int visibleRowCount () {
    return max(1, int((WORLD.dY - 2 * pad - headerHeight) / rowHeight));
  }

  // Title bar above the rows, in absolute screen coordinates - drawn
  // every time this picker draws (including while the scrollbar is being
  // dragged), so it stays put rather than only appearing momentarily.
  float[] headerRect () {
    float x = WORLD.cX + pad;
    float y = WORLD.cY + pad;
    float w = WORLD.dX - 2 * pad;
    float h = headerHeight - 2;
    return new float[]{ x, y, w, h };
  }

  // Shared layout for one *visible* row (0 = topmost row on screen,
  // right below the title bar), in absolute screen coordinates - used by
  // both the drawing code and the click hit-test below so they always
  // agree on where each row is. To get the absolute index into `indices`
  // for a visible row, add `scrollOffset` to it.
  float[] rowRect (int visibleRow) {
    float scrollBarWidth = this.needsScrollbar() ? PICKLIST_SCROLLBAR_WIDTH + 4 : 0;

    float x = WORLD.cX + pad;
    float y = WORLD.cY + pad + headerHeight + visibleRow * rowHeight;
    float w = WORLD.dX - 2 * pad - scrollBarWidth;
    float h = rowHeight - 2;
    return new float[]{ x, y, w, h };
  }

  // Track (full scrollable area) and thumb (draggable handle) rectangles
  // for the scrollbar, in absolute screen coordinates.
  float[] scrollTrackRect () {
    int visibleRowCount = this.visibleRowCount();
    int shownRows = min(visibleRowCount, this.indices.length);

    float x = WORLD.cX + WORLD.dX - pad - PICKLIST_SCROLLBAR_WIDTH;
    float y = WORLD.cY + pad + headerHeight;
    float w = PICKLIST_SCROLLBAR_WIDTH;
    float h = shownRows * rowHeight;
    return new float[]{ x, y, w, h };
  }

  float[] scrollThumbRect () {
    float[] track = this.scrollTrackRect();

    int visibleRowCount = this.visibleRowCount();
    int total = this.indices.length;
    int maxOffset = max(1, total - visibleRowCount);

    float thumbHeight = min(track[3], max(20, track[3] * (float(visibleRowCount) / float(total))));
    float travel = track[3] - thumbHeight;
    float thumbY = track[1] + travel * (float(this.scrollOffset) / float(maxOffset));

    return new float[]{ track[0], thumbY, track[2], thumbHeight };
  }

  // Returns which pick-list row (if any) a screen point falls on, as an
  // absolute index into `indices`, or -1.
  int rowAt (float clickX, float clickY) {
    int visibleRowCount = this.visibleRowCount();
    int maxVisible = min(visibleRowCount, this.indices.length - this.scrollOffset);

    for (int visibleRow = 0; visibleRow < maxVisible; visibleRow++) {
      float[] r = this.rowRect(visibleRow);
      float x = r[0];
      float y = r[1];
      float w = r[2];
      float h = rowHeight; // full row height (not r[3]) so there's no dead zone between rows
      if (isInside(clickX, clickY, x, y, x + w, y + h)) return this.scrollOffset + visibleRow;
    }
    return -1;
  }

  void draw () {
    if (!this.active) return;

    pushStyle();

    textSize(MessageSize);

    // Title bar - drawn every time (not just on the first frame), so it
    // stays in place while the scrollbar is being dragged/scrolled.
    float[] header = this.headerRect();

    noStroke();
    fill(60, 230);
    rect(header[0], header[1], header[2], header[3]);

    stroke(0);
    strokeWeight(1);
    noFill();
    rect(header[0], header[1], header[2], header[3]);

    noStroke();
    fill(255);
    textAlign(CENTER, CENTER);
    text("Pick " + this.name + " Station", header[0] + 0.5 * header[2], header[1] + 0.5 * header[3]);

    textAlign(LEFT, CENTER);

    int visibleRowCount = this.visibleRowCount();
    int maxVisible = min(visibleRowCount, this.indices.length - this.scrollOffset);

    for (int visibleRow = 0; visibleRow < maxVisible; visibleRow++) {
      float[] r = this.rowRect(visibleRow);
      int absIndex = this.scrollOffset + visibleRow;
      int f = this.indices[absIndex];

      String label = nf(absIndex + 1) + ". " + this.getLabel(f);

      noStroke();
      fill(255, 220);
      rect(r[0], r[1], r[2], r[3]);

      stroke(0);
      strokeWeight(1);
      noFill();
      rect(r[0], r[1], r[2], r[3]);

      noStroke();
      fill(0);
      text(label, r[0] + 4, r[1] + 0.5 * r[3]);
    }

    if (this.needsScrollbar()) {
      float[] track = this.scrollTrackRect();
      float[] thumb = this.scrollThumbRect();

      noStroke();
      fill(230, 230);
      rect(track[0], track[1], track[2], track[3]);

      stroke(0);
      strokeWeight(1);
      fill(160);
      rect(thumb[0], thumb[1], thumb[2], thumb[3]);
    }

    popStyle();
  }

  // Handles a click on the scrollbar *track* (paging up/down a page at a
  // time) - a click directly on the thumb is left alone here since that's
  // the start of a drag, handled by handleScrollDrag() below. Returns
  // true if the click was on the track at all (whether or not it actually
  // moved anything), so the caller can skip treating this click as
  // picking a map location.
  boolean handleTrackClick () {
    if (!this.active) return false;
    if (!this.needsScrollbar()) return false;

    float[] track = this.scrollTrackRect();
    if (!isInside(X_clicked, Y_clicked, track[0], track[1], track[0] + track[2], track[1] + track[3])) return false;

    float[] thumb = this.scrollThumbRect();

    if ((Y_clicked < thumb[1]) || (Y_clicked > thumb[1] + thumb[3])) {
      int visibleRowCount = this.visibleRowCount();
      int maxOffset = max(0, this.indices.length - visibleRowCount);
      int page = max(1, visibleRowCount - 1);

      if (Y_clicked < thumb[1]) {
        this.scrollOffset = constrain(this.scrollOffset - page, 0, maxOffset);
      } else {
        this.scrollOffset = constrain(this.scrollOffset + page, 0, maxOffset);
      }
    }
    // else: clicked directly on the thumb - that's a drag start, not a page click.

    return true;
  }

  // Scrolls the picker list in response to the mouse wheel, if it's
  // showing and the mouse is over WORLD. Returns true if it consumed the
  // event (so e.g. WORLD's zoom-on-wheel doesn't also fire).
  boolean handleWheel (float wheelValue) {
    if (!this.active) return false;
    if (!isInside(X_clicked, Y_clicked, WORLD.cX, WORLD.cY, WORLD.cX + WORLD.dX, WORLD.cY + WORLD.dY)) return false;

    int visibleRowCount = this.visibleRowCount();
    int maxOffset = max(0, this.indices.length - visibleRowCount);
    if (maxOffset == 0) return false; // nothing to scroll - let the event fall through (e.g. to zoom)

    this.scrollOffset = constrain(this.scrollOffset + ((wheelValue > 0) ? 1 : -1), 0, maxOffset);

    WORLD.revise();
    return true;
  }

  // Drags the scrollbar thumb. Returns true if this drag is (or just
  // became) a thumb drag, so the caller can skip other drag handling
  // (e.g. panning WORLD) for the same drag gesture.
  boolean handleScrollDrag () {
    if (!this.active) return false;
    if (!this.needsScrollbar()) return false;

    if (!this.scrollThumbDragging) {
      if (dragging_started != 0) return false; // some other drag already claimed this gesture

      float[] thumb = this.scrollThumbRect();
      if (!isInside(pmouseX, pmouseY, thumb[0], thumb[1], thumb[0] + thumb[2], thumb[1] + thumb[3])) return false;

      this.scrollThumbDragging = true;
      dragging_started = 1;
      X_click1 = pmouseX;
      Y_click1 = pmouseY;
      this.scrollDrag_startMouseY = pmouseY;
      this.scrollDrag_startOffset = this.scrollOffset;
    }

    float[] track = this.scrollTrackRect();
    float[] thumb = this.scrollThumbRect();

    float travel = track[3] - thumb[3]; // how far the thumb can move within the track
    if (travel > 0) {
      int visibleRowCount = this.visibleRowCount();
      int maxOffset = max(1, this.indices.length - visibleRowCount);
      float rowsPerPixel = maxOffset / travel;

      float deltaY = mouseY - this.scrollDrag_startMouseY;
      int newOffset = this.scrollDrag_startOffset + round(deltaY * rowsPerPixel);

      this.scrollOffset = constrain(newOffset, 0, maxOffset);
    }

    WORLD.revise();
    return true;
  }

  // Handles a click while the picker list is showing: picks the row it
  // landed on (if any), or just cancels the list if it landed elsewhere.
  // Either way the click is fully consumed - returns true whenever this
  // picker was active, so the caller can skip treating this same click as
  // picking a new map location.
  boolean handleClick () {
    if (!this.active) return false;

    int rowIndex = this.rowAt(X_clicked, Y_clicked);
    if (rowIndex >= 0) {
      int f = this.indices[rowIndex];
      this.select(f, this.mouseLon, this.mouseLat);
    }

    this.active = false;
    this.indices = new int[0];

    return true;
  }

  // Cancels the list without selecting anything (e.g. Esc). No-op if this
  // picker isn't the one currently active. Returns true if it was.
  boolean cancel () {
    if (!this.active) return false;

    this.active = false;
    this.indices = new int[0];

    return true;
  }

  // Called from this dataset's own click handling: finds nearby
  // candidates around (lon, lat); if there's at least one AND this
  // dataset is the active data source, shows the picker (even for a
  // single candidate, so the user can see/confirm it or click away to
  // cancel) instead of silently guessing. Otherwise (0 candidates within
  // range, or a different dataset is active) just quietly selects the
  // single nearest one, same as every dataset did before pickers existed.
  void handleMapClick (float lon, float lat) {
    STATION[] coords = this.getCoords();
    int[] nearby = findNearbyStations(coords, lon, lat, this.maxDist, this.maxCount);

    if ((nearby.length > 0) && (CurrentDataSource == this.dataSourceID)) {
      this.active = true;
      this.indices = nearby;
      this.mouseLon = lon;
      this.mouseLat = lat;
      this.scrollOffset = 0;
    } else {
      int f = (nearby.length > 0) ? nearby[0] : findNearestStation(coords).index;
      this.select(f, lon, lat);
    }
  }
}

StationPicker TMYEPW_PICKER = new StationPicker("TMYEPW", 10000, 50, dataID_CLIMATE_TMYEPW) {
  STATION[] getCoords () { return TMYEPW_Coordinates; }
  String getLabel (int f) { return TMYEPW_Coordinates[f].getFilename_TMYEPW(); }
  void select (int f, float lon, float lat) { selectTMYEPWStation(f, lon, lat); }
};

StationPicker CLMREC_PICKER = new StationPicker("CLMREC", 25000, 50, dataID_CLIMATE_CLMREC) {
  STATION[] getCoords () { return CLMREC_Coordinates; }
  String getLabel (int f) { return CLMREC_Coordinates[f].getCity() + ", " + CLMREC_Coordinates[f].getProvince(); }
  void select (int f, float lon, float lat) { selectCLMRECStation(f, lon, lat); }
};

StationPicker CWEEDS_PICKER = new StationPicker("CWEEDS", 50000, 50, dataID_CLIMATE_CWEEDS) {
  STATION[] getCoords () { return CWEEDS_coordinates; }
  String getLabel (int f) { return CWEEDS_coordinates[f].getFilename_CWEEDS(); }
  void select (int f, float lon, float lat) { selectCWEEDSStation(f, lon, lat); }
};

StationPicker NAEFS_PICKER = new StationPicker("NAEFS", 50000, 50, dataID_ENSEMBLE_FORECAST) {
  STATION[] getCoords () { return NAEFS_Coordinates; }
  String getLabel (int f) { return NAEFS_Coordinates[f].getFilename_NAEFS(); }
  void select (int f, float lon, float lat) { selectNAEFSStation(f, lon, lat); }
};

StationPicker SWOB_PICKER = new StationPicker("SWOB", 25000, 50, dataID_ENSEMBLE_OBSERVED) {
  STATION[] getCoords () { return SWOB_Coordinates; }
  String getLabel (int f) { return SWOB_Coordinates[f].getCode(); }
  void select (int f, float lon, float lat) { selectSWOBStation(f, lon, lat); }
};

// At most one of these is ever active at once, since a picker only opens
// while its own dataset is CurrentDataSource - but each dispatcher below
// still has to check all of them to find out which (if any) that is.
StationPicker[] ALL_PICKERS = { TMYEPW_PICKER, CLMREC_PICKER, CWEEDS_PICKER, NAEFS_PICKER, SWOB_PICKER };

void drawPickLists () {
  for (StationPicker picker : ALL_PICKERS) picker.draw();
}

boolean handlePickListTrackClick () {
  for (StationPicker picker : ALL_PICKERS) if (picker.handleTrackClick()) return true;
  return false;
}

boolean handlePickListClick () {
  for (StationPicker picker : ALL_PICKERS) if (picker.handleClick()) return true;
  return false;
}

boolean handlePickListWheel (float wheelValue) {
  for (StationPicker picker : ALL_PICKERS) if (picker.handleWheel(wheelValue)) return true;
  return false;
}

boolean handlePickListScrollDrag () {
  for (StationPicker picker : ALL_PICKERS) if (picker.handleScrollDrag()) return true;
  return false;
}

void resetPickListDragState () {
  for (StationPicker picker : ALL_PICKERS) picker.scrollThumbDragging = false;
}

// Cancels whichever picker (if any) is currently showing, without
// selecting anything - used by Esc. At most one is ever active, so this
// stops at the first one found.
boolean cancelActivePickList () {
  for (StationPicker picker : ALL_PICKERS) if (picker.cancel()) return true;
  return false;
}

// Assigns TMYEPW station `f` to STATION and (if TMYEPW is the active data
// source) reloads its data - shared by both the direct single-nearest-hit
// path and the "user picked a row from the list" path.
void selectTMYEPWStation (int f, float mouse_lon, float mouse_lat) {

  if (STATION.getFilename_TMYEPW().equals(TMYEPW_Coordinates[f].getFilename_TMYEPW())) return;

  STATION.setLatitude(mouse_lat);
  STATION.setLongitude(mouse_lon);

  STATION.setFilename_TMYEPW(TMYEPW_Coordinates[f].getFilename_TMYEPW()); // epw filename
  STATION.setDownload_TMYEPW(TMYEPW_Coordinates[f].getDownload_TMYEPW()); // epw filename

  println("nearest epw filename:", TMYEPW_Coordinates[f].getFilename_TMYEPW());

  if (CurrentDataSource == dataID_CLIMATE_TMYEPW) {
    STATION.setCity(TMYEPW_Coordinates[f].getCity());
    STATION.setProvince(TMYEPW_Coordinates[f].getProvince());
    STATION.setCountry(TMYEPW_Coordinates[f].getCountry());

    //STATION.setLatitude(TMYEPW_Coordinates[f].getLatitude());
    //STATION.setLongitude(TMYEPW_Coordinates[f].getLongitude());
    STATION.setElevation(TMYEPW_Coordinates[f].getElevation());
    STATION.setTimelong(TMYEPW_Coordinates[f].getTimelong());

    UI_rollout.revise();

    update_station(0);

    download_CLIMATE_TMYEPW();

    boolean keep_CLIMATE_TMYEPW_load = CLIMATE_TMYEPW_load;
    update_CLIMATE_TMYEPW();
    CLIMATE_TMYEPW_load = keep_CLIMATE_TMYEPW_load;
  }
}

// Same shape as selectTMYEPWStation above, for CLMREC.
void selectCLMRECStation (int f, float mouse_lon, float mouse_lat) {

  if (STATION.getFilename_CWEEDS().equals(CLMREC_Coordinates[f].getFilename_CWEEDS())) return;

  STATION.setLatitude(mouse_lat);
  STATION.setLongitude(mouse_lon);

  STATION.setFilename_CWEEDS(CLMREC_Coordinates[f].getFilename_CWEEDS()); // CLMREC filename

  println("nearest CLMREC filename:", CLMREC_Coordinates[f].getFilename_CWEEDS());

  if (CurrentDataSource == dataID_CLIMATE_CLMREC) {

    STATION.setCity(CLMREC_Coordinates[f].getCity());
    STATION.setProvince(CLMREC_Coordinates[f].getProvince());
    STATION.setCountry(CLMREC_Coordinates[f].getCountry());

    //STATION.setLatitude(CLMREC_Coordinates[f].getLatitude());
    //STATION.setLongitude(CLMREC_Coordinates[f].getLongitude());
    STATION.setElevation(CLMREC_Coordinates[f].getElevation());
    STATION.setTimelong(CLMREC_Coordinates[f].getTimelong());

    UI_rollout.revise();

    update_station(0);
    update_CLIMATE_CLMREC();
  }
}

// Same shape as selectTMYEPWStation above, for CWEEDS.
void selectCWEEDSStation (int f, float mouse_lon, float mouse_lat) {

  if (STATION.getFilename_CWEEDS().equals(CWEEDS_coordinates[f].getFilename_CWEEDS())) return;

  STATION.setLatitude(mouse_lat);
  STATION.setLongitude(mouse_lon);

  STATION.setFilename_CWEEDS(CWEEDS_coordinates[f].getFilename_CWEEDS()); // CWEEDS filename

  println("nearest CWEEDS filename:", CWEEDS_coordinates[f].getFilename_CWEEDS());

  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {

    STATION.setCity(CWEEDS_coordinates[f].getCity());
    STATION.setProvince(CWEEDS_coordinates[f].getProvince());
    STATION.setCountry(CWEEDS_coordinates[f].getCountry());

    //STATION.setLatitude(CWEEDS_coordinates[f].getLatitude());
    //STATION.setLongitude(CWEEDS_coordinates[f].getLongitude());
    STATION.setElevation(CWEEDS_coordinates[f].getElevation());
    STATION.setTimelong(funcs.roundTo(STATION.getLongitude(), 15));

    UI_rollout.revise();

    update_station(0);
    update_CLIMATE_CWEEDS();
  }
}

// Same shape as selectTMYEPWStation above, for NAEFS. Also
// preserves the original ">100km => don't load" behavior, using the
// distance from the clicked location to the selected station (matching
// what the original inline code computed via STATION's just-updated
// position before this function existed).
void selectNAEFSStation (int f, float mouse_lon, float mouse_lat) {

  if (STATION.getFilename_NAEFS().equals(NAEFS_Coordinates[f].getFilename_NAEFS())) return;

  STATION.setLatitude(mouse_lat);
  STATION.setLongitude(mouse_lon);

  STATION.setFilename_NAEFS(NAEFS_Coordinates[f].getFilename_NAEFS());

  println("nearest naefs filename:", NAEFS_Coordinates[f].getFilename_NAEFS());

  if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
    STATION.setCity(NAEFS_Coordinates[f].getCity());
    STATION.setProvince(NAEFS_Coordinates[f].getProvince());
    STATION.setCountry(NAEFS_Coordinates[f].getCountry());

    //STATION.setLatitude(NAEFS_Coordinates[f].getLatitude());
    //STATION.setLongitude(NAEFS_Coordinates[f].getLongitude());
    STATION.setElevation(NAEFS_Coordinates[f].getElevation());
    STATION.setTimelong(NAEFS_Coordinates[f].getTimelong());

    UI_rollout.revise();

    update_station(0);

    download_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);

    boolean keep_ENSEMBLE_FORECAST_load = ENSEMBLE_FORECAST_load;

    float _lat = NAEFS_Coordinates[f].getLatitude();
    float _lon = NAEFS_Coordinates[f].getLongitude();
    if (_lon > 180) _lon -= 360; // << important!
    float dist = funcs.lon_lat_dist(_lon, _lat, mouse_lon, mouse_lat);

    // do not load data if it is outside 100Km distance
    if (dist > 100000) {
      ENSEMBLE_FORECAST_load = false;
      STATION.setFilename_NAEFS("?");
    }
    update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);
    ENSEMBLE_FORECAST_load = keep_ENSEMBLE_FORECAST_load;
  }
}

// Same shape as selectTMYEPWStation above, for SWOB. Also
// preserves the original ">100km => don't load" behavior - see the note
// on selectNAEFSStation above.
void selectSWOBStation (int f, float mouse_lon, float mouse_lat) {

  if (STATION.getFilename_SWOB().equals(SWOB_Coordinates[f].getFilename_SWOB())) return;

  STATION.setLatitude(mouse_lat);
  STATION.setLongitude(mouse_lon);

  STATION.setFilename_SWOB(SWOB_Coordinates[f].getFilename_SWOB());

  println("nearest swob filename:", SWOB_Coordinates[f].getFilename_SWOB());

  if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
    STATION.setCity(SWOB_Coordinates[f].getCity());
    STATION.setProvince(SWOB_Coordinates[f].getProvince());
    STATION.setCountry(SWOB_Coordinates[f].getCountry());

    //STATION.setLatitude(SWOB_Coordinates[f].getLatitude());
    //STATION.setLongitude(SWOB_Coordinates[f].getLongitude());
    STATION.setElevation(SWOB_Coordinates[f].getElevation());
    STATION.setTimelong(SWOB_Coordinates[f].getTimelong());

    UI_rollout.revise();

    update_station(0);

    download_ENSEMBLE_OBSERVED(TIME.year, TIME.month, TIME.day, TIME.hour);

    boolean keep_ENSEMBLE_OBSERVED_load = ENSEMBLE_OBSERVED_load;

    float _lat = SWOB_Coordinates[f].getLatitude();
    float _lon = SWOB_Coordinates[f].getLongitude();
    if (_lon > 180) _lon -= 360; // << important!
    float dist = funcs.lon_lat_dist(_lon, _lat, mouse_lon, mouse_lat);

    // do not load data if it is outside 100Km distance
    if (dist > 100000) {
      ENSEMBLE_OBSERVED_load = false;
      STATION.setFilename_SWOB("?");
    }
    update_ENSEMBLE_OBSERVED(TIME.year, TIME.month, TIME.day, TIME.hour);
    ENSEMBLE_OBSERVED_load = keep_ENSEMBLE_OBSERVED_load;
  }
}

void mouseClicked () {

  if (frameCount > Last_initializationStep) {

    if (control == USER_GUI) {

      if (FRAME_click_IMG) {

        RecordFrame();

        UI_toolBar.drawMouse(1, mouseX, mouseY, 2 * MessageSize);

        RecordFrame();
      }

      if ((UI_menuBar.selected_parent != -1)) {

        String menu_option = UI_menuBar.Items[UI_menuBar.selected_parent][UI_menuBar.selected_child];
        if (mouseButton == LEFT) {
          if (UI_menuBar.selected_child != 0) {

            if (menuActions == null) {
              buildMenuActions();
            }

            Runnable menuAction = menuActions.get(menu_option);
            if (menuAction != null) {
              menuAction.run();
            }

            if (UI_menuBar.Items[UI_menuBar.selected_parent][0].equals("Layer")) {
              if (UI_menuBar.selected_child > 0) {
                if (UI_menuBar.selected_child < allLayers.length) {
                  changeCurrentLayerTo(UI_menuBar.selected_child - 1);
                  DevelopLayer_id = CurrentLayer_id;
                  STUDY.revise();
                } else if (menu_option.charAt(0) != '—') {
                  Develop_Option = UI_menuBar.selected_child - allLayers.length - 1; // -1 for the divider
                  postProcess_developDATA(CurrentDataSource);
                  changeCurrentLayerTo(LAYER_developed.id);
                  STUDY.revise();
                }
              }
            }
          }
        }

        UI_menuBar.selected_parent = -1;
        UI_menuBar.selected_child = 0;

        image(pre_screen, 0, pixel_A);

        X_clicked = -1;
        Y_clicked = -1;
      } else {

        X_clicked = mouseX;
        Y_clicked = mouseY;

        if (isInside(X_clicked, Y_clicked, 0, 0, width, pixel_A)) {
          UI_menuBar.revise();
        }

        if (isInside(X_clicked, Y_clicked, 0, pixel_A, width, pixel_A + pixel_B)) {
          UI_toolBar.revise();
        }

        if (isInside(X_clicked, Y_clicked, 0, pixel_A + pixel_B + 2 * pixel_H, width, pixel_A + pixel_B + 2 * pixel_H + pixel_C)) {
          UI_caseBar.revise();
        }

        if (isInside(X_clicked, Y_clicked, 0, pixel_A + pixel_B + 2 * pixel_H + pixel_C, width, pixel_A + pixel_B + 2 * pixel_H + pixel_C + pixel_D)) {
          typeUserCommand = 1;
          UI_consoleBar.revise();
        } else {
          typeUserCommand = 0;
          UI_consoleBar.revise();
        }

        if (isInside(X_clicked, Y_clicked, UI_rollout.cX, UI_rollout.cY, UI_rollout.cX + UI_rollout.dX, UI_rollout.cY + UI_rollout.dY)) {
          UI_rollout.revise();
        }

        if (WORLD.include) {
          if (isInside(X_clicked, Y_clicked, WORLD.cX, WORLD.cY, WORLD.cX + WORLD.dX, WORLD.cY + WORLD.dY)) {

            // Clicks meant for the picker list (picking a row, or
            // clicking away to cancel it) or its scrollbar track aren't
            // "pick a location on the map" clicks, so handle them here
            // and skip everything below (STATION repositioning,
            // nearest-station lookups, etc.) entirely for this click.
            if (handlePickListTrackClick() || handlePickListClick()) {
              // handled - fall through to the shared revise() calls below
            } else {

            float mouse_lon = 360.0 * ((mouseX - WORLD.cX) * WORLD.sX / WORLD.dX - 0.5) + WORLD.oX;
            float mouse_lat = -180.0 * ((mouseY - WORLD.cY) * WORLD.sY / WORLD.dY - 0.5) + WORLD.oY;
            //float mouse_lon = STATION.getLongitude();
            //float mouse_lat = STATION.getLatitude();


            pre_LocationLAT = LocationLAT;
            pre_LocationLON = LocationLON;

            STATION.setLatitude(mouse_lat);
            STATION.setLongitude(mouse_lon);

            if ((pre_LocationLAT != LocationLAT) ||
                (pre_LocationLON != LocationLON)) {

              WORLD.VIEW_id = WORLD.FindGoodViewport(LocationLON, LocationLAT);
            }

            if (mouseButton == LEFT) {
              WORLD.Zoom = max(WORLD.Zoom, 5); // zoom in to confirm exactly where the click landed
            }
            // Right click keeps the current zoom level instead, for
            // comparing several rough locations across a wider area
            // without the view snapping in on every click.

            // Each picker's handleMapClick() finds nearby candidates of its
            // own dataset around (mouse_lon, mouse_lat); if there's more
            // than one AND that dataset is the active CurrentDataSource, it
            // shows its own pick list instead of guessing - otherwise it
            // quietly selects the single nearest one, same as every
            // dataset did before pickers existed. A click while any
            // picker's list was showing (row pick, or click-away-to-cancel)
            // is already fully handled upfront by
            // handlePickListClick() above, so no picker can
            // still be active here.
            SWOB_PICKER.handleMapClick(mouse_lon, mouse_lat);
            NAEFS_PICKER.handleMapClick(mouse_lon, mouse_lat);
            CWEEDS_PICKER.handleMapClick(mouse_lon, mouse_lat);
            CLMREC_PICKER.handleMapClick(mouse_lon, mouse_lat);
            TMYEPW_PICKER.handleMapClick(mouse_lon, mouse_lat);




            }

            WORLD.revise();
            WIN3D.revise();
          }
        }

        if (WIN3D.include) {
          if (isInside(X_clicked, Y_clicked, WIN3D.cX, WIN3D.cY, WIN3D.cX + WIN3D.dX, WIN3D.cY + WIN3D.dY)) {

            float Image_X = 0;
            float Image_Y = 0;

            Image_X = X_clicked - (WIN3D.cX + 0.5 * WIN3D.dX);
            Image_Y = Y_clicked - (WIN3D.cY + 0.5 * WIN3D.dY);

            if (WIN3D.UI_CurrentTask == UITASK.LookAtDirection) { // viewport:LookAtDirection

              WIN3D.look_3DViewport_towards_Direction(Image_X, Image_Y);

              view_changed();
            }
            else {

              ClickRay ray = computeClickRay(Image_X, Image_Y);
              float[] ray_start = ray.start;
              float[] ray_direction = ray.direction;

              float[] RxP = new float [8];

              if (mouseButton == RIGHT) {
                RxP = Land3D.intersect(ray_start, ray_direction);
              } else if (mouseButton == LEFT) {

                if ((WIN3D.UI_CurrentTask == UITASK.Create) ||
                    (WIN3D.UI_CurrentTask == UITASK.Move)) {

                   RxP = snap_Faces(allFaces.intersect(ray_start, ray_direction));

                } else {

                  if (current_ObjectCategory == ObjectCategory.POLYLINE) {
                    RxP = allPolylines.intersect(ray_start, ray_direction);
                  } else if (current_ObjectCategory == ObjectCategory.CAMERA) {
                    RxP = allCameras.intersect(ray_start, ray_direction);
                  } else if (current_ObjectCategory == ObjectCategory.SECTION) {
                    RxP = allSections.intersect(ray_start, ray_direction);
                  } else if (current_ObjectCategory == ObjectCategory.SOLID) {
                    RxP = allSolids.intersect(ray_start, ray_direction);
                  } else if (current_ObjectCategory == ObjectCategory.MODEL1D) {
                    RxP = allModel1Ds.intersect(ray_start, ray_direction);
                  } else if (current_ObjectCategory == ObjectCategory.MODEL2D) {
                    RxP = allModel2Ds.intersect(ray_start, ray_direction);
                  } else {
                    RxP = snap_Faces(allFaces.intersect(ray_start, ray_direction));
                  }
                }



              }


              //println(ray_start[0], ray_start[1], ray_start[2], ">>", ray_end[0], ray_end[1], ray_end[2], ">>", RxP[1], RxP[2], RxP[3], RxP[4], RxP[0]);

              if ((WIN3D.UI_CurrentTask != UITASK.Create) && (WIN3D.UI_CurrentTask != UITASK.Move)) { // PickSelect also if scale, rotate, modify, etc. where selected

                Select3D.selectPick(RxP);
              }

              else if (RxP[0] >= 0) {

                if (WIN3D.UI_CurrentTask == UITASK.Move) { // move

                  float[] origin = getMoveOriginPoint();
                  float x1 = origin[0];
                  float y1 = origin[1];
                  float z1 = origin[2];

                  if ((is_defined(x1)) &&
                      (is_defined(y1)) &&
                      (is_defined(z1))) {

                    float x2 = RxP[1];
                    float y2 = RxP[2];
                    float z2 = RxP[3];

                    float[] d = computeMoveDelta(x1, y1, z1, x2, y2, z2);

                    Move3D.selection(d[0], d[1], d[2]);

                    model_changed();
                  }
                }




                if (mouseButton == LEFT) { // modify should work only with left click because the right click returns the land info, not objects info

                  if ((WIN3D.UI_TaskModifyParameter != 0) && (WIN3D.UI_CurrentTask >= UITASK.Seed_Material)) { // Pick/Assign properties

                    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
                        (current_ObjectCategory == ObjectCategory.FACE) || (current_ObjectCategory == ObjectCategory.POLYLINE)) {

                      int f = int(RxP[0]);

                      pickOrAssignFaceProperty(f);

                      if (WIN3D.UI_CurrentTask == UITASK.Pivot) {
                        if (WIN3D.UI_TaskModifyParameter == 1) { // Pick
                          //?????????????????????????????????????????????????
                        }
                        if (WIN3D.UI_TaskModifyParameter == 2) { // Assign
                          int OBJ_ID = allGroups.findGroupContainingFace(f);


                          float[] P = Select3D.getPivot();

                          allGroups.Pivots[OBJ_ID][0] = P[0];
                          allGroups.Pivots[OBJ_ID][1] = P[1];
                          allGroups.Pivots[OBJ_ID][2] = P[2];

                          //zzzzzzzzzzzzzzzzzzz should add other components?

                        }
                      }

                      if (WIN3D.UI_CurrentTask == UITASK.Normal) { //Normal

                        if (current_ObjectCategory == ObjectCategory.FACE) {

                          Select3D.Face_ids = new int [1];
                          Select3D.Face_ids[0] = f;

                          Select3D.Face_displayVertexCount = true;

                          flipFaceOrientationIfNeeded(f);
                        } else if (current_ObjectCategory == ObjectCategory.GROUP) {
                          int OBJ_ID = allGroups.findGroupContainingFace(f);

                          for (int q = allGroups.getStart_Face(OBJ_ID); q <= allGroups.getStop_Face(OBJ_ID); q++) {
                            flipFaceOrientationIfNeeded(q);
                          }

                        }
                      }



                      if (WIN3D.UI_CurrentTask == UITASK.FirstVertex) { //FirstVertex

                        if (current_ObjectCategory == ObjectCategory.FACE) {

                          Select3D.Face_ids = new int [1];
                          Select3D.Face_ids[0] = f;

                          Select3D.Face_displayVertexCount = true;

                          rotateNodesToStartAtNearestVertex(allFaces.nodes[f], RxP);
                        } else if (current_ObjectCategory == ObjectCategory.POLYLINE) {

                          Select3D.Polyline_ids = new int [1];
                          Select3D.Polyline_ids[0] = f;

                          Select3D.Polyline_displayVertexCount = true;

                          rotateNodesToStartAtNearestVertex(allPolylines.nodes[f], RxP);
                        }

                      }
                    }










                    if (current_ObjectCategory == ObjectCategory.MODEL2D) {

                      pickOrAssignModel2DSeedMaterial(int(RxP[0]));

                    } else if (current_ObjectCategory == ObjectCategory.MODEL1D) {

                      pickOrAssignModel1DProperty(int(RxP[0]));
                    }

                    model_changed();

                  }
                }

                if (WIN3D.UI_CurrentTask == UITASK.Create) { // create

                  int keep_number_of_allGroups = allGroups.num;
                  int keep_number_of_allModel2Ds = allModel2Ds.num;
                  int keep_number_of_allModel1Ds = allModel1Ds.num;
                  int keep_number_of_allSolids = allSolids.DEF.length;
                  int keep_number_of_allSections = allSections.num;
                  int keep_number_of_allCameras = allCameras.num;

                  CreateParams cp = computeCreateParams(RxP);
                  float x = cp.x, y = cp.y, z = cp.z, rot = cp.rot;
                  float rx = cp.rx, ry = cp.ry, rz = cp.rz;
                  float px = cp.px, py = cp.py, pz = cp.pz;



                  //if ((current_ObjectCategory == ObjectCategory.GROUP) || (current_ObjectCategory == ObjectCategory.SOLID) || (current_ObjectCategory == ObjectCategory.MODEL1D) || (current_ObjectCategory == ObjectCategory.MODEL2D)) {
                  if (current_ObjectCategory == ObjectCategory.GROUP) { // begin the group, then create its first mesh/solid

                    if (addToLastGroup == false) {

                      allGroups.beginNewGroup(x, y, z, 1, 1, 1, 0, 0, rot);
                    }



                    if (CreateObject == CREATE.SuperOBJ) {

                      int shape = classifySuperOBJShape(px, py, pz);

                      if (shape == SUPEROBJ_SHAPE_PARAMETRIC) {

                        Create3D.add_ParametricSurface(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, ry, rz, 0, rot);
                      } else if (shape == SUPEROBJ_SHAPE_SUPERCYLINDER) {

                        Create3D.add_SuperCylinder(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, ry, rz, User3D.create_CylinderDegree, rot);
                      } else if (shape == SUPEROBJ_SHAPE_BOX) {

                        Create3D.add_Box_Core(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, ry, rz, rot);
                      } else if (shape == SUPEROBJ_SHAPE_OCTAHEDRON) {

                        Create3D.add_Octahedron(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, ry, rz, rot);
                      } else {

                        Create3D.add_SuperSphere(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, pz, py, pz, rx, ry, rz, User3D.create_SphereDegree, rot);
                      }

                      if (User3D.create_MeshOrSolid != 0) {

                        allSolids.create(x, y, z, px, py, pz, rx, ry, rz, 0, 0, rot, 1);
                      }
                    } else if (CreateObject == CREATE.Pyramid) {

                      Create3D.add_Mesh3(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x-rx, y-ry, z-rz, x+rx, y-ry, z-rz, x, y, z+rz);
                      Create3D.add_Mesh3(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x+rx, y-ry, z-rz, x+rx, y+ry, z-rz, x, y, z+rz);
                      Create3D.add_Mesh3(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x+rx, y+ry, z-rz, x-rx, y+ry, z-rz, x, y, z+rz);
                      Create3D.add_Mesh3(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x-rx, y+ry, z-rz, x-rx, y-ry, z-rz, x, y, z+rz);
                    } else if (CreateObject == CREATE.Plane) {

                      Create3D.add_Mesh4(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x-rx, y-ry, z, x+rx, y-ry, z, x+rx, y+ry, z, x-rx, y+ry, z);
                    } else if (CreateObject == CREATE.Polygon) {

                      Create3D.add_PolygonMesh(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, User3D.create_PolyDegree, rot);
                    } else if (CreateObject == CREATE.Hyper) {

                      Create3D.add_PolygonHyper(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, 2 * rz, User3D.create_PolyDegree, rot);
                    } else if (CreateObject == CREATE.Extrude) {

                      Create3D.add_PolygonExtrude(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, 2 * rz, User3D.create_PolyDegree, rot);
                    } else if (CreateObject == CREATE.House3) {

                      float h = ry;

                      Create3D.add_House3_Core(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, ry, rz, h, rot);
                    } else if (CreateObject == CREATE.House2) {

                      float h = ry;

                      Create3D.add_House2_Core(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, ry, rz, h, rot);
                    } else if (CreateObject == CREATE.House1) {

                      float h = ry;

                      if (ry > rx) h = rx;

                      Create3D.add_House1_Core(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, ry, rz, h, rot);
                    } else if (CreateObject == CREATE.Parametric) {

                      Create3D.add_ParametricSurface(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, ry, rz, User3D.create_Parametric_Type, rot);
                    }
                  } else if (current_ObjectCategory == ObjectCategory.MODEL2D) { // working with model2Ds
                    if (CreateObject == CREATE.Person) {

                      randomSeed(millis());
                      allModel2Ds.create("PEOPLE", User3D.create_Person_Type, x, y, z, 2.5);
                    }

                    if (CreateObject == CREATE.Plant) {
                      int n = 0;
                      if (User3D.create_Plant_Type > 0) n = User3D.create_Plant_Type + allModel2Ds.num_files_PEOPLE;

                      randomSeed(millis());
                      allModel2Ds.create("TREES", n, x, y, z, 2 * rz);
                    }
                  } else if (current_ObjectCategory == ObjectCategory.MODEL1D) { // working with model1Ds
                    if (CreateObject == CREATE.Model1Ds) {

                      randomSeed(millis());
                      allModel1Ds.create(User3D.create_Model1D_Type, User3D.create_Model1D_Seed,
                                         User3D.create_Model1D_DegreeMax,
                                         x, y, z, 2 * rz, floor(random(360)),
                                         User3D.create_Model1D_BranchTilt, User3D.create_Model1D_BranchTwist,
                                         User3D.create_Model1D_BranchRatio, User3D.create_Model1D_TreeBase,
                                         User3D.create_Model1D_TrunkSize, User3D.create_Model1D_LeafSize);
                    }
                  } else if (current_ObjectCategory == ObjectCategory.VERTEX) { // working with vertices
                    if (CreateObject == CREATE.Vertex) {
                      allPoints.create(x, y, z);

                    }
                  } else if (current_ObjectCategory == ObjectCategory.FACE) { // working with faces
                    if (CreateObject == CREATE.Face) {
                      allFaces.add_VertexToLastFace(x, y, z);

                      Select3D.Face_ids = new int [1];
                      Select3D.Face_ids[0] = allFaces.nodes.length - 1;

                      Select3D.calculate_BoundingBox();
                    }
                  } else if (current_ObjectCategory == ObjectCategory.POLYLINE) { // working with polylines
                    if (CreateObject == CREATE.Polyline) {
                      allPolylines.add_VertexToLastPolyline(x, y, z);

                      Select3D.Polyline_ids = new int [1];
                      Select3D.Polyline_ids[0] = allPolylines.nodes.length - 1;

                      Select3D.calculate_BoundingBox();
                    }
                  } else if (current_ObjectCategory == ObjectCategory.SOLID) { // working with solids
                    if (CreateObject == CREATE.Solid) {
                      allSolids.create(x, y, z, px, py, pz, rx, ry, rz, 0, 0, rot, 1);
                    }
                  } else if (current_ObjectCategory == ObjectCategory.CAMERA) { // working with cameras
                    if (CreateObject == CREATE.Camera) {

                      CameraParams camParams = computeCameraParamsAtPoint(RxP[1], RxP[2], RxP[3]);

                      allCameras.create(camParams.pX, camParams.pY, camParams.pZ, camParams.pT, camParams.rX, camParams.rY, camParams.rZ, camParams.rT, camParams.zoom, camParams.type);
                    }
                  } else if (current_ObjectCategory == ObjectCategory.SECTION) { // working with sections
                    if (CreateObject == CREATE.Section) {

                      SectionParams sp = computeSectionParams(int(RxP[0]), RxP);

                      if (sp.createNew) {

                        allSections.create(sp.X, sp.Y, sp.Z, sp.R, sp.U, sp.V, sp.Type, sp.RES1, sp.RES2);

                        selectNewlyCreated(keep_number_of_allSections, allSections.num,
                          () -> Select3D.deselect_Sections(),
                          (o) -> { Select3D.Section_ids = concat(Select3D.Section_ids, new int[] {o}); }
                          );

                        allSolidImpacts.X[allSolidImpacts.sectionType] = sp.X;
                        allSolidImpacts.Y[allSolidImpacts.sectionType] = sp.Y;
                        allSolidImpacts.Z[allSolidImpacts.sectionType] = sp.Z;
                        allSolidImpacts.R[allSolidImpacts.sectionType] = sp.R;
                        allSolidImpacts.U[allSolidImpacts.sectionType] = sp.U;
                        allSolidImpacts.V[allSolidImpacts.sectionType] = sp.V;

                        allSolidImpacts.sectionType = sp.Type;
                        allSolidImpacts.RES1 = sp.RES1;
                        allSolidImpacts.RES2 = sp.RES2;

                        allSolidImpacts.calculate_Impact_selectedSections();

                        allSolarImpacts.sectionType = sp.Type;
                      }
                    }


                  }




                  selectNewlyCreated(keep_number_of_allSolids, allSolids.DEF.length,
                    () -> Select3D.deselect_Solids(),
                    (o) -> { Select3D.Solid_ids = concat(Select3D.Solid_ids, new int[] {o}); }
                    );

                  selectNewlyCreated(keep_number_of_allCameras, allCameras.num,
                    () -> Select3D.deselect_Cameras(),
                    (o) -> { Select3D.Camera_ids = concat(Select3D.Camera_ids, new int[] {o}); }
                    );

                  selectNewlyCreated(keep_number_of_allGroups, allGroups.num,
                    () -> Select3D.deselect_Groups(),
                    (o) -> { Select3D.Group_ids = concat(Select3D.Group_ids, new int[] {o}); }
                    );

                  selectNewlyCreated(keep_number_of_allModel2Ds, allModel2Ds.num,
                    () -> Select3D.deselect_Model2Ds(),
                    (o) -> { Select3D.Model2D_ids = concat(Select3D.Model2D_ids, new int[] {o}); }
                    );

                  selectNewlyCreated(keep_number_of_allModel1Ds, allModel1Ds.num,
                    () -> Select3D.deselect_Model1Ds(),
                    (o) -> { Select3D.Model1D_ids = concat(Select3D.Model1D_ids, new int[] {o}); }
                    );




                }
              }

              view_changed();
            }
          }
        }

        redraw();
      }
    }
  }
}

void buildMenuActions() {
  menuActions = new HashMap<String, Runnable>();

  menuActions.put("SOLARCHVISION-BIM6D", () -> {
    link("https://www.dropbox.com/scl/fi/vyfqllzj7hnb3rhvpnwus/BatimentDurable_MojtabaSamimi_20171123.pdf?rlkey=lzpoqyu59vp8wb4qidqtradaw&e=1");
  });

  menuActions.put("Designed & developed by", () -> {
    link("https://depositonce.tu-berlin.de/items/c091139a-09cf-44c3-99a9-6adf59f7eaf8");
  });

  menuActions.put("Mojtaba Samimi", () -> {
    link("https://www.linkedin.com/in/mojtaba-samimi-06178840/");
  });

  menuActions.put("www.solarchvision.com", () -> {
    link("https://solarchvision.com/");
  });

  menuActions.put("New", () -> {
    /////////////////////////////
    holdProject();
    /////////////////////////////

    selectFile_New();

    deleteAll();

    //update_station(-1);
  });

  menuActions.put("Save", () -> {
    saveProject(Folder_Project + "/" + ProjectName + ".xml");
  });

  menuActions.put("Hold", () -> {
    holdProject();
  });

  menuActions.put("Fetch", () -> {
    fetchProject();
  });

  menuActions.put("Open...", () -> {
    selectFile_Open();
  });

  menuActions.put("Save As...", () -> {
    selectFile_SaveAs();
  });

  menuActions.put("Import 3D-model...", () -> {
    selectFile_ImportObj();
  });

  menuActions.put("Import Command File...", () -> {
    selectFile_RunScript();
  });

  menuActions.put("Export 3D-model > OBJ (time-series)", () -> {
    exportObj_timeSeries();
  });

  menuActions.put("Export 3D-model > OBJ (date-series)", () -> {
    exportObj_dateSeries();
  });

  menuActions.put("Export 3D-model > OBJ", () -> {
    exportObj("");
  });

  menuActions.put("Export 3D-model > HTML", () -> {
    exportHtml();
  });

  menuActions.put("Export 3D-model > RAD", () -> {
    exportRadiance();
  });

  menuActions.put("Export 3D-model > SCR", () -> {
    exportAutocadScript();
  });

  menuActions.put("Quit", () -> {
    exit();
  });

  menuActions.put("Wind pattern (active)", () -> setPlotImpacts(PlotImpacts_WIND_ACTIVE, true));

  menuActions.put("Wind pattern (passive)", () -> setPlotImpacts(PlotImpacts_WIND_PASSIVE, true));

  menuActions.put("Urban solar potential (active)", () -> setPlotImpacts(PlotImpacts_URBAN_ACTIVE, false));

  menuActions.put("Urban solar potential (passive)", () -> setPlotImpacts(PlotImpacts_URBAN_PASSIVE, false));

  menuActions.put("Orientation potential (active)", () -> setPlotImpacts(PlotImpacts_GLOBAL_ACTIVE, false));

  menuActions.put("Orientation potential (passive)", () -> setPlotImpacts(PlotImpacts_GLOBAL_PASSIVE, false));

  menuActions.put("Hourly sun position (active)", () -> setPlotImpacts(PlotImpacts_SUNPATH_ACTIVE, false));

  menuActions.put("Hourly sun position (passive)", () -> setPlotImpacts(PlotImpacts_SUNPATH_PASSIVE, false));

  menuActions.put("Annual cycle sun path (active)", () -> setPlotImpacts(PlotImpacts_CYCLES_ACTIVE, false));

  menuActions.put("Annual cycle sun path (passive)", () -> setPlotImpacts(PlotImpacts_CYCLES_PASSIVE, false));

  menuActions.put("Prebake Selected Sections", () -> {
    allSolarImpacts.render_Shadows_selectedSections();

    view_changed();
  });

  menuActions.put("Process Active Impact", () -> {
    STUDY.PlotImpacts = PlotImpacts_URBAN_ACTIVE;
    allSolarImpacts.calculate_Impact_selectedSections();

    view_changed();
  });

  menuActions.put("Process Passive Impact", () -> {
    STUDY.PlotImpacts = PlotImpacts_URBAN_PASSIVE;
    allSolarImpacts.calculate_Impact_selectedSections();

    view_changed();
  });

  menuActions.put("Process Solid Impact", () -> {
    allSolidImpacts.calculate_Impact_selectedSections();

    view_changed();
  });

  menuActions.put("Run wind 3D-model", () -> {
    allSolidImpacts.calculate_WindFlow();

    view_changed();
  });

  // Each of these 5 menu actions used to reset the same 12 recording
  // flags to false and then flip exactly one of them true. Pulling the
  // reset into stopAllRecording() means each action states
  // only what's actually different: which flag turns on.
  menuActions.put("Stop REC.", () -> {
    stopAllRecording();

    UI_rollout.revise();
  });

  menuActions.put("REC. Time Graph", () -> {
    stopAllRecording();
    STUDY.record_AUTO = true;

    UI_rollout.revise();
  });

  menuActions.put("REC. Location Graph", () -> {
    stopAllRecording();
    WORLD.record_AUTO = true;

    UI_rollout.revise();
  });

  menuActions.put("REC. Solid Graph", () -> {
    stopAllRecording();
    WIN3D.record_AUTO = true;

    UI_rollout.revise();
  });

  menuActions.put("REC. Screenshot", () -> {
    stopAllRecording();
    FRAME_record_AUTO = true;

    UI_rollout.revise();
  });

  menuActions.put("PDF Time Graph", () -> {
    STUDY.record_PDF = true;
    STUDY.revise();
  });

  menuActions.put("JPG Time Graph", () -> {
    STUDY.record_IMG = true;
    STUDY.revise();
  });

  menuActions.put("JPG Location Graph", () -> {
    WORLD.record_IMG = true;
    WORLD.revise();
  });

  menuActions.put("PDF Location Graph", () -> {
    WORLD.record_PDF = true;
    WORLD.revise();
  });

  menuActions.put("JPG 3D Graph", () -> {
    WIN3D.record_IMG = true;

    view_changed();
  });

  menuActions.put("JPG 3D Full-Period", () -> {
    WIN3D.fullPeriod_IMG = true;
    WIN3D.record_IMG = true;

    view_changed();
  });

  menuActions.put("Screenshot", () -> {
    FRAME_record_IMG = true;
  });

  menuActions.put("Screenshot+Click", () -> {
    FRAME_click_IMG = true;
  });

  menuActions.put("Screenshot+Drag", () -> {
    FRAME_drag_IMG = true;
  });

  menuActions.put("Update Station", () -> {
    update_station(-1);
  });

  menuActions.put("Load Land Mesh", () -> {
    Land3D.update_textures();
  });

  menuActions.put("Load Land Texture", () -> {
    Land3D.update_textures();
  });

  menuActions.put("Download Land Mesh", () -> {
    Land3D.download_mesh();
  });

  menuActions.put("Download Land Texture", () -> {
    Land3D.download_textures();
  });

  menuActions.put("Load Toroposphere", () -> {
    Tropo3D.download_images();
    Tropo3D.displaySurface = true;
    WORLD.revise();
    WIN3D.revise();
  });

  menuActions.put("Download SWOB", () -> {
    download_ENSEMBLE_OBSERVED(TIME.year, TIME.month, TIME.day, TIME.hour);;
  });

  menuActions.put("Download NAEFS", () -> {
    download_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);
  });

  menuActions.put("Download CLMREC", () -> {
    download_CLIMATE_CLMREC();
  });

  menuActions.put("Download TMYEPW", () -> {
    download_CLIMATE_TMYEPW();
  });

  menuActions.put("Update TMYEPW", () -> {
    CurrentDataSource = dataID_CLIMATE_TMYEPW;

    CLIMATE_TMYEPW_load = true;
    update_CLIMATE_TMYEPW();
  });

  menuActions.put("Update CWEEDS", () -> {
    CurrentDataSource = dataID_CLIMATE_CWEEDS;

    CLIMATE_CWEEDS_load = true;
    update_CLIMATE_CWEEDS();
  });

  menuActions.put("Update CLMREC", () -> {
    CurrentDataSource = dataID_CLIMATE_CLMREC;

    CLIMATE_CLMREC_load = true;
    update_CLIMATE_CLMREC();
  });

  menuActions.put("Update SWOB", () -> {
    CurrentDataSource = dataID_ENSEMBLE_OBSERVED;

    ENSEMBLE_OBSERVED_load = true;
    update_ENSEMBLE_OBSERVED(TIME.year, TIME.month, TIME.day, TIME.hour);
  });

  menuActions.put("Update NAEFS", () -> {
    CurrentDataSource = dataID_ENSEMBLE_FORECAST;

    ENSEMBLE_FORECAST_load = true;
    update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);
  });



  menuActions.put("Use typical year (TMY)", () -> {
    CurrentDataSource = dataID_CLIMATE_TMYEPW;

    CLIMATE_TMYEPW_load = true;
    update_CLIMATE_TMYEPW();

    view_changed();
    WORLD.revise();
    STUDY.revise();
    UI_rollout.revise();
    UI_caseBar.revise();

    WORLD.hideAllMarkersAndLabels();
    WORLD.displayAll_TMYEPW = 1;
    WORLD.displayNear_TMYEPW = true;
  });

  menuActions.put("Use long-term (CWEEDS)", () -> {
    CurrentDataSource = dataID_CLIMATE_CWEEDS;

    CLIMATE_CWEEDS_load = true;
    update_CLIMATE_CWEEDS();

    view_changed();
    WORLD.revise();
    STUDY.revise();
    UI_rollout.revise();
    UI_caseBar.revise();

    WORLD.hideAllMarkersAndLabels();
    WORLD.displayAll_CWEEDS = 1;
    WORLD.displayNear_CWEEDS = true;
  });

  menuActions.put("Use long-term (CLMREC)", () -> {
    CurrentDataSource = dataID_CLIMATE_CLMREC;

    CLIMATE_CLMREC_load = true;
    update_CLIMATE_CLMREC();

    view_changed();
    WORLD.revise();
    STUDY.revise();
    UI_rollout.revise();
    UI_caseBar.revise();

    WORLD.hideAllMarkersAndLabels();
    WORLD.displayAll_CLMREC = 1;
    WORLD.displayNear_CLMREC = true;
  });

  menuActions.put("Use real-time observed (SWOB)", () -> {
    CurrentDataSource = dataID_ENSEMBLE_OBSERVED;
    STUDY.joinDays = 1;

    ENSEMBLE_OBSERVED_load = true;
    update_ENSEMBLE_OBSERVED(TIME.year, TIME.month, TIME.day, TIME.hour);

    view_changed();
    WORLD.revise();
    STUDY.revise();
    UI_rollout.revise();
    UI_caseBar.revise();

    WORLD.hideAllMarkersAndLabels();
    WORLD.displayAll_SWOB = 1;
    WORLD.displayNear_SWOB = true;
  });

  menuActions.put("Use weather forecast (NAEFS)", () -> {
    CurrentDataSource = dataID_ENSEMBLE_FORECAST;
    STUDY.joinDays = 1;

    ENSEMBLE_FORECAST_load = true;
    update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);

    view_changed();
    WIN3D.revise();
    STUDY.revise();
    UI_rollout.revise();
    UI_caseBar.revise();

    WORLD.hideAllMarkersAndLabels();
    WORLD.displayAll_NAEFS = 1;
    WORLD.displayNear_NAEFS = true;
  });

  menuActions.put("Active Shade", () -> {
    WIN3D.Impact_TYPE = Impact_ACTIVE;

    if (WIN3D.FacesShade == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
    if (WIN3D.FacesShade == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;

    view_changed();
  });

  menuActions.put("Passive Shade", () -> {
    WIN3D.Impact_TYPE = Impact_PASSIVE;

    if (WIN3D.FacesShade == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
    if (WIN3D.FacesShade == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;

    view_changed();
  });

  menuActions.put("Shade Surface Wire", () -> {
    WIN3D.FacesShade = SHADE.Surface_Wire;
    allFaces.displayEdges = true; //<<<<<<<<<<<<<<<

    view_changed();
  });

  menuActions.put("Shade Surface Base", () -> {
    WIN3D.FacesShade = SHADE.Surface_Base;

    view_changed();
  });

  menuActions.put("Shade Surface White", () -> {
    WIN3D.FacesShade = SHADE.Surface_White;

    view_changed();
  });

  menuActions.put("Shade Surface Materials", () -> {
    WIN3D.FacesShade = SHADE.Surface_Materials;

    view_changed();
  });

  menuActions.put("Shade Global Solar", () -> {
    WIN3D.FacesShade = SHADE.Global_Solar;

    GlobalSolar_rebuild_array = true;

    view_changed();
  });

  menuActions.put("Shade Vertex Solar", () -> {
    WIN3D.FacesShade = SHADE.Vertex_Solar;

    VertexSolar_rebuild_array = true;

    view_changed();
  });

  menuActions.put("Shade Vertex Solid", () -> {
    WIN3D.FacesShade = SHADE.Vertex_Solid;

    view_changed();
  });

  menuActions.put("Shade Vertex Elevation", () -> {
    WIN3D.FacesShade = SHADE.Vertex_Elevation;

    view_changed();
  });

  menuActions.put("Shade Viewport", () -> {
    ShadeViewport();
  });

  menuActions.put("Prebake Viewport", () -> {
    preBakeViewport();
  });

  menuActions.put("Show/Hide Land Mesh", () -> {
    Land3D.displaySurface = !Land3D.displaySurface;

    view_changed();
  });

  menuActions.put("Show/Hide Land Texture", () -> {
    Land3D.displayTexture = !Land3D.displayTexture;

    view_changed();
  });

  menuActions.put("Show/Hide Land Points", () -> {
    Land3D.displayPoints = !Land3D.displayPoints;

    view_changed();
  });

  menuActions.put("Show/Hide Land Depth", () -> {
    Land3D.displayDepth = !Land3D.displayDepth;

    view_changed();
  });

  menuActions.put("Show/Hide Vertices", () -> {
    allPoints.displayAll = !allPoints.displayAll;

    view_changed();
  });

  menuActions.put("Show/Hide Edges", () -> {
    allFaces.displayEdges = !allFaces.displayEdges;

    view_changed();
  });

  menuActions.put("Show/Hide Normals", () -> {
    allFaces.displayNormals = !allFaces.displayNormals;

    view_changed();
  });

  menuActions.put("Show/Hide Leaves", () -> {
    allModel1Ds.displayLeaves = !allModel1Ds.displayLeaves;

    view_changed();
  });

  menuActions.put("Show/Hide Model1Ds", () -> {
    allModel1Ds.displayAll = !allModel1Ds.displayAll;
    allModel1Ds.displayLeaves = allModel1Ds.displayAll; // <<<<<<

    view_changed();
  });

  menuActions.put("Show/Hide Model2Ds", () -> {
    allModel2Ds.displayAll = !allModel2Ds.displayAll;

    view_changed();
  });

  menuActions.put("Show/Hide Polylines", () -> {
    allPolylines.displayAll = !allPolylines.displayAll;

    view_changed();
  });

  menuActions.put("Show/Hide Faces", () -> {
    allFaces.displayAll = !allFaces.displayAll;

    view_changed();
  });

  menuActions.put("Show/Hide Solids", () -> {
    allSolids.displayAll = !allSolids.displayAll;

    view_changed();
  });

  menuActions.put("Show/Hide Sections", () -> {
    allSections.displayAll = !allSections.displayAll;

    view_changed();
  });

  menuActions.put("Show/Hide Cameras", () -> {
    allCameras.displayAll = !allCameras.displayAll;

    view_changed();
  });

  menuActions.put("Show/Hide Sky", () -> {
    Sky3D.displaySurface = !Sky3D.displaySurface;

    view_changed();
  });

  menuActions.put("Show/Hide Sun Grid", () -> {
    Sun3D.displayGrid = !Sun3D.displayGrid;

    view_changed();
  });

  menuActions.put("Show/Hide Sun Path", () -> {
    Sun3D.displayPath = !Sun3D.displayPath;

    view_changed();
  });

  menuActions.put("Show/Hide Sun Pattern", () -> {
    Sun3D.displayPattern = !Sun3D.displayPattern;

    view_changed();
  });

  menuActions.put("Show/Hide Sun Surface", () -> {
    Sun3D.displaySurface = !Sun3D.displaySurface;

    view_changed();
  });

  menuActions.put("Show/Hide Moon Surface", () -> {
    Moon3D.displaySurface = !Moon3D.displaySurface;

    view_changed();
  });

  menuActions.put("Show/Hide Earth Surface", () -> {
    Earth3D.displaySurface = !Earth3D.displaySurface;

    view_changed();
  });

  menuActions.put("Show/Hide Troposphere", () -> {
    Tropo3D.displaySurface = !Tropo3D.displaySurface;

    view_changed();
    WORLD.revise();
  });

  menuActions.put("Show/Hide Solar Section", () -> {
    allSolarImpacts.displayImage = !allSolarImpacts.displayImage;

    view_changed();
  });

  menuActions.put("Show/Hide Solid Section", () -> {
    allSolidImpacts.displayImage = !allSolidImpacts.displayImage;

    view_changed();
  });

  menuActions.put("Show/Hide Selected Solids", () -> {
    Select3D.Solid_displayEdges = !Select3D.Solid_displayEdges;

    view_changed();
  });

  menuActions.put("Show/Hide Selected Sections", () -> {
    Select3D.Section_displayEdges = !Select3D.Section_displayEdges;

    view_changed();
  });

  menuActions.put("Show/Hide Selected Cameras", () -> {
    Select3D.Camera_displayEdges = !Select3D.Camera_displayEdges;

    view_changed();
  });

  menuActions.put("Show/Hide Selected LandPoints", () -> {
    Select3D.LandPoint_displayPoints = !Select3D.LandPoint_displayPoints;

    view_changed();
  });

  menuActions.put("Show/Hide Wind Flow", () -> {
    allWindFlows.displayAll = !allWindFlows.displayAll;

    view_changed();
  });

  menuActions.put("Show/Hide Selected Faces", () -> {
    Select3D.Face_displayEdges = !Select3D.Face_displayEdges;

    view_changed();
  });

  menuActions.put("Show/Hide Selected Faces Vertex Count", () -> {
    Select3D.Face_displayVertexCount = !Select3D.Face_displayVertexCount;

    view_changed();
  });

  menuActions.put("Show/Hide Selected Polylines Vertex Count", () -> {
    Select3D.Polyline_displayVertexCount = !Select3D.Polyline_displayVertexCount;

    view_changed();
  });

  menuActions.put("Show/Hide Selected Vertices", () -> {
    Select3D.Vertex_displayVertices = !Select3D.Vertex_displayVertices;

    view_changed();
  });

  menuActions.put("Show/Hide Selected Polylines", () -> {
    Select3D.Polyline_displayVertices = !Select3D.Polyline_displayVertices;

    view_changed();
  });

  menuActions.put("Show/Hide Selected REF Pivot", () -> {
    Select3D.displayReferencePivot = !Select3D.displayReferencePivot;

    view_changed();
  });

  menuActions.put("Show/Hide Selected Group Pivot", () -> {
    Select3D.Group_displayPivot = !Select3D.Group_displayPivot;

    view_changed();
  });

  menuActions.put("Show/Hide Selected Group Edges", () -> {
    Select3D.Group_displayEdges = !Select3D.Group_displayEdges;

    view_changed();
  });

  menuActions.put("Show/Hide Selected Group Box", () -> {
    Select3D.Group_displayBox = !Select3D.Group_displayBox;

    view_changed();;
  });

  menuActions.put("Show/Hide Selected 2D Edges", () -> {
    Select3D.Model2D_displayEdges = !Select3D.Model2D_displayEdges;

    view_changed();
  });

  menuActions.put("Show/Hide Selected 1D Edges", () -> {
    Select3D.Model1D_displayEdges = !Select3D.Model1D_displayEdges;

    view_changed();
  });

  menuActions.put("Show/Hide SWOB stations", () -> {
    WORLD.displayAll_SWOB = (WORLD.displayAll_SWOB + 1) % 2;

    WORLD.revise();
  });

  menuActions.put("Show/Hide SWOB nearest", () -> {
    WORLD.displayNear_SWOB = !WORLD.displayNear_SWOB;

    WORLD.revise();
  });

  menuActions.put("Show/Hide NAEFS stations", () -> {
    WORLD.displayAll_NAEFS = (WORLD.displayAll_NAEFS + 1) % 2;

    WORLD.revise();
  });

  menuActions.put("Show/Hide NAEFS nearest", () -> {
    WORLD.displayNear_NAEFS = !WORLD.displayNear_NAEFS;

    WORLD.revise();
  });

  menuActions.put("Show/Hide CWEEDS stations", () -> {
    WORLD.displayAll_CWEEDS = (WORLD.displayAll_CWEEDS + 1) % 2;

    WORLD.revise();
  });

  menuActions.put("Show/Hide CWEEDS nearest", () -> {
    WORLD.displayNear_CWEEDS = !WORLD.displayNear_CWEEDS;

    WORLD.revise();
  });

  menuActions.put("Show/Hide CLMREC stations", () -> {
    WORLD.displayAll_CLMREC = (WORLD.displayAll_CLMREC + 1) % 2;

    WORLD.revise();
  });

  menuActions.put("Show/Hide CLMREC nearest", () -> {
    WORLD.displayNear_CLMREC = !WORLD.displayNear_CLMREC;

    WORLD.revise();
  });

  menuActions.put("Show/Hide TMYEPW stations", () -> {
    WORLD.displayAll_TMYEPW = (WORLD.displayAll_TMYEPW + 1) % 2;

    WORLD.revise();
  });

  menuActions.put("Show/Hide TMYEPW nearest", () -> {
    WORLD.displayNear_TMYEPW = !WORLD.displayNear_TMYEPW;

    WORLD.revise();
  });

  menuActions.put("1D-Tree", () -> {
    UI_setTo_Create_allModel1Ds();
  });

  menuActions.put("2D-Tree", () -> {
    UI_setTo_Create_Tree();
  });

  menuActions.put("Person", () -> {
    UI_setTo_Create_Person();
  });

  menuActions.put("Point", () -> {
    UI_setTo_Create_Vertex();
  });

  menuActions.put("Polyline", () -> {
    UI_setTo_Create_Polyline();
  });

  menuActions.put("Surface", () -> {
    UI_setTo_Create_Face();
  });

  menuActions.put("Parametric 1", () -> {
    UI_setTo_Create_Parametric(1);
  });

  menuActions.put("Parametric 2", () -> {
    UI_setTo_Create_Parametric(2);
  });

  menuActions.put("Parametric 3", () -> {
    UI_setTo_Create_Parametric(3);
  });

  menuActions.put("Parametric 4", () -> {
    UI_setTo_Create_Parametric(4);
  });

  menuActions.put("Parametric 5", () -> {
    UI_setTo_Create_Parametric(5);
  });

  menuActions.put("Parametric 6", () -> {
    UI_setTo_Create_Parametric(6);
  });

  menuActions.put("Pyramid", () -> {
    UI_setTo_Create_Pyramid();
  });

  menuActions.put("Plane", () -> {
    UI_setTo_Create_Plane();
  });

  menuActions.put("Polygon", () -> {
    UI_setTo_Create_Polygon();
  });

  menuActions.put("Extrude", () -> {
    UI_setTo_Create_Extrude();
  });

  menuActions.put("Hyper", () -> {
    UI_setTo_Create_Hyper();
  });

  menuActions.put("House3", () -> {
    UI_setTo_Create_House3();
  });

  menuActions.put("House2", () -> {
    UI_setTo_Create_House2();
  });

  menuActions.put("House1", () -> {
    UI_setTo_Create_House1();
  });

  menuActions.put("Box", () -> {
    UI_setTo_Create_Box();
  });

  menuActions.put("Icosahedron", () -> {
    UI_setTo_Create_Icosahedron();
  });

  menuActions.put("Octahedron", () -> {
    UI_setTo_Create_Octahedron();
  });

  menuActions.put("Sphere", () -> {
    UI_setTo_Create_Sphere();
  });

  menuActions.put("Cylinder", () -> {
    UI_setTo_Create_Cylinder();
  });

  menuActions.put("Cushion", () -> {
    UI_setTo_Create_Cushion();
  });

  menuActions.put("Drop on LandSurface", () -> {
    UI_setTo_Modify_Drop(0);

    Drop3D.selection();
  });

  menuActions.put("Drop on ModelSurface (Down)", () -> {
    UI_setTo_Modify_Drop(1);

    Drop3D.selection();
  });

  menuActions.put("Drop on ModelSurface (Up)", () -> {
    UI_setTo_Modify_Drop(2);

    Drop3D.selection();
  });

  menuActions.put("Get dX", () -> {
    UI_setTo_Modify_GetLength(0);
  });

  menuActions.put("Get dY", () -> {
    UI_setTo_Modify_GetLength(1);
  });

  menuActions.put("Get dZ", () -> {
    UI_setTo_Modify_GetLength(2);
  });

  menuActions.put("Get dXYZ", () -> {
    UI_setTo_Modify_GetLength(3);
  });

  menuActions.put("Get dXY", () -> {
    UI_setTo_Modify_GetLength(4);
  });

  menuActions.put("MoveX", () -> {
    UI_setTo_Modify_Move(0);
  });

  menuActions.put("MoveY", () -> {
    UI_setTo_Modify_Move(1);
  });

  menuActions.put("MoveZ", () -> {
    UI_setTo_Modify_Move(2);
  });

  menuActions.put("Move", () -> {
    UI_setTo_Modify_Move(3);
  });

  menuActions.put("ScaleX", () -> {
    UI_setTo_Modify_Scale(0);
  });

  menuActions.put("ScaleY", () -> {
    UI_setTo_Modify_Scale(1);
  });

  menuActions.put("ScaleZ", () -> {
    UI_setTo_Modify_Scale(2);
  });

  menuActions.put("Scale", () -> {
    UI_setTo_Modify_Scale(3);
  });

  menuActions.put("PowerX", () -> {
    UI_setTo_Modify_Power(0);
  });

  menuActions.put("PowerY", () -> {
    UI_setTo_Modify_Power(1);
  });

  menuActions.put("PowerZ", () -> {
    UI_setTo_Modify_Power(2);
  });

  menuActions.put("Power", () -> {
    UI_setTo_Modify_Power(3);
  });

  menuActions.put("RotateX", () -> {
    UI_setTo_Modify_Rotate(0);
  });

  menuActions.put("RotateY", () -> {
    UI_setTo_Modify_Rotate(1);
  });

  menuActions.put("RotateZ", () -> {
    UI_setTo_Modify_Rotate(2);
  });

  menuActions.put("Rotate", () -> {
    UI_setTo_Modify_Rotate(2);
  });

  menuActions.put("Pivot", () -> {
    UI_setTo_Modify_Pivot(0);
  });

  menuActions.put("Pick Pivot", () -> {
    UI_setTo_Modify_Pivot(1);
  });

  menuActions.put("Assign Pivot", () -> {
    UI_setTo_Modify_Pivot(2);
  });

  menuActions.put("Save Current ReferenceBox", () -> {
    Select3D.save_current_BoundingBox();
  });

  menuActions.put("Reset Saved ReferenceBox", () -> {
    Select3D.apply_saved_BoundingBox();

    view_changed();
  });

  menuActions.put("Use Selection ReferenceBox", () -> {
    Select3D.calculate_BoundingBox();

    view_changed();
  });

  menuActions.put("Use Origin ReferenceBox", () -> {
    Select3D.apply_origin_ReferenceBox();

    view_changed();
  });

  menuActions.put("Begin New Group at Origin", () -> {
    allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);

    Select3D.Group_ids = new int [1];
    Select3D.Group_ids[0] = allGroups.num - 1;

    model_changed();
  });

  menuActions.put("Begin New Group at Pivot", () -> {
    allGroups.beginNewGroup(Select3D.BoundingBox[1 + Select3D.alignX][0], Select3D.BoundingBox[1 + Select3D.alignX][1], Select3D.BoundingBox[1 + Select3D.alignX][2], Select3D.BoundingBox[1 + Select3D.alignX][3], Select3D.BoundingBox[1 + Select3D.alignX][4], Select3D.BoundingBox[1 + Select3D.alignX][5], Select3D.BoundingBox[1 + Select3D.alignX][6], Select3D.BoundingBox[1 + Select3D.alignX][7], Select3D.BoundingBox[1 + Select3D.alignX][8]);

    Select3D.Group_ids = new int [1];
    Select3D.Group_ids[0] = allGroups.num - 1;

    model_changed();
  });

  menuActions.put("Solid", () -> {
    UI_setTo_Create_Solid();
  });

  menuActions.put("Section", () -> {
    UI_setTo_Create_Section();
  });

  menuActions.put("Camera", () -> {
    UI_setTo_Create_Camera();
  });

  menuActions.put("Viewport >> Camera", () -> {
    float Camera_pX = WIN3D.position_X;
    float Camera_pY = WIN3D.position_Y;
    float Camera_pZ = WIN3D.position_Z;
    float Camera_pT = WIN3D.position_T;
    float Camera_rX = WIN3D.rotation_X;
    float Camera_rY = WIN3D.rotation_Y;
    float Camera_rZ = WIN3D.rotation_Z;
    float Camera_rT = WIN3D.rotation_T;
    float Camera_zoom = WIN3D.Zoom;

    int Camera_type = WIN3D.ViewType;

    allCameras.create(Camera_pX, Camera_pY, Camera_pZ, Camera_pT, Camera_rX, Camera_rY, Camera_rZ, Camera_rT, Camera_zoom, Camera_type);

    WIN3D.currentCamera = allCameras.num - 1;
    WIN3D.apply_currentCamera();
    modify_Viewport_Title();

    view_changed();

    UI_toolBar.revise();
  });

  menuActions.put("Camera >> Viewport", () -> {
    allCameras.set_posX(0, allCameras.get_posX(WIN3D.currentCamera));
    allCameras.set_posY(0, allCameras.get_posY(WIN3D.currentCamera));
    allCameras.set_posZ(0, allCameras.get_posZ(WIN3D.currentCamera));
    allCameras.set_posT(0, allCameras.get_posT(WIN3D.currentCamera));
    allCameras.set_rotX(0, allCameras.get_rotX(WIN3D.currentCamera));
    allCameras.set_rotY(0, allCameras.get_rotY(WIN3D.currentCamera));
    allCameras.set_rotZ(0, allCameras.get_rotZ(WIN3D.currentCamera));
    allCameras.set_rotT(0, allCameras.get_rotT(WIN3D.currentCamera));
    allCameras.set_zoom(0, allCameras.get_zoom(WIN3D.currentCamera));
    allCameras.set_type(0, allCameras.get_type(WIN3D.currentCamera));

    WIN3D.currentCamera = 0;
    modify_Viewport_Title();

    view_changed();

    UI_toolBar.revise();
  });

  menuActions.put("Camera View", () -> {
    if (Select3D.Camera_ids.length > 0) {
      WIN3D.currentCamera = Select3D.Camera_ids[Select3D.Camera_ids.length - 1];
      WIN3D.apply_currentCamera();
      modify_Viewport_Title();

      view_changed();

      UI_toolBar.revise();
    }
  });

  menuActions.put("LandMesh >> Group", () -> {
    Land3D.draw(TypeWindow.LandMesh);

    model_changed();
  });

  menuActions.put("LandGap >> Group", () -> {
    Land3D.draw(TypeWindow.LandGap);

    model_changed();
  });

  menuActions.put("Change Seed/Material", () -> {
    UI_setTo_Modify_Seed(0);
  });

  menuActions.put("Pick Seed/Material", () -> {
    UI_setTo_Modify_Seed(1);
  });

  menuActions.put("Assign Seed/Material", () -> {
    UI_setTo_Modify_Seed(2);
  });

  menuActions.put("Change tessellation", () -> {
    UI_setTo_Modify_Tessellation(0);
  });

  menuActions.put("Pick tessellation", () -> {
    UI_setTo_Modify_Tessellation(1);
  });

  menuActions.put("Assign tessellation", () -> {
    UI_setTo_Modify_Tessellation(2);
  });

  menuActions.put("Change Layer", () -> {
    UI_setTo_Modify_Layer(0);
  });

  menuActions.put("Pick Layer", () -> {
    UI_setTo_Modify_Layer(1);
  });

  menuActions.put("Assign Layer", () -> {
    UI_setTo_Modify_Layer(2);
  });

  menuActions.put("Change Visibility", () -> {
    UI_setTo_Modify_Visibility(0);
  });

  menuActions.put("Pick Visibility", () -> {
    UI_setTo_Modify_Visibility(1);
  });

  menuActions.put("Assign Visibility", () -> {
    UI_setTo_Modify_Visibility(2);
  });

  menuActions.put("Change Weight", () -> {
    UI_setTo_Modify_Weight(0);
  });

  menuActions.put("Pick Weight", () -> {
    UI_setTo_Modify_Weight(1);
  });

  menuActions.put("Assign Weight", () -> {
    UI_setTo_Modify_Weight(2);
  });

  menuActions.put("Flip Normal", () -> {
    UI_setTo_Modify_Normal(1);
  });

  menuActions.put("Set-Out Normal", () -> {
    UI_setTo_Modify_Normal(2);
  });

  menuActions.put("Set-In Normal", () -> {
    UI_setTo_Modify_Normal(3);
  });

  menuActions.put("Get FirstVertex", () -> {
    UI_setTo_Modify_FirstVertex(1);
  });

  menuActions.put("Change DegreeMax", () -> {
    UI_setTo_Modify_DegreeMax(0);
  });

  menuActions.put("Pick DegreeMax", () -> {
    UI_setTo_Modify_DegreeMax(1);
  });

  menuActions.put("Assign DegreeMax", () -> {
    UI_setTo_Modify_DegreeMax(2);
  });

  menuActions.put("Change BranchTilt", () -> {
    UI_setTo_Modify_BranchTilt(0);
  });

  menuActions.put("Pick BranchTilt", () -> {
    UI_setTo_Modify_BranchTilt(1);
  });

  menuActions.put("Assign BranchTilt", () -> {
    UI_setTo_Modify_BranchTilt(2);
  });

  menuActions.put("Change BranchTwist", () -> {
    UI_setTo_Modify_BranchTwist(0);
  });

  menuActions.put("Pick BranchTwist", () -> {
    UI_setTo_Modify_BranchTwist(1);
  });

  menuActions.put("Assign BranchTwist", () -> {
    UI_setTo_Modify_BranchTwist(2);
  });

  menuActions.put("Change BranchRatio", () -> {
    UI_setTo_Modify_BranchRatio(0);
  });

  menuActions.put("Pick BranchRatio", () -> {
    UI_setTo_Modify_BranchRatio(1);
  });

  menuActions.put("Assign BranchRatio", () -> {
    UI_setTo_Modify_BranchRatio(2);
  });

  menuActions.put("Change TreeBase", () -> {
    UI_setTo_Modify_TreeBase(0);
  });

  menuActions.put("Pick TreeBase", () -> {
    UI_setTo_Modify_TreeBase(1);
  });

  menuActions.put("Assign TreeBase", () -> {
    UI_setTo_Modify_TreeBase(2);
  });

  menuActions.put("Change TrunkSize", () -> {
    UI_setTo_Modify_TrunkSize(0);
  });

  menuActions.put("Pick TrunkSize", () -> {
    UI_setTo_Modify_TrunkSize(1);
  });

  menuActions.put("Assign TrunkSize", () -> {
    UI_setTo_Modify_TrunkSize(2);
  });

  menuActions.put("Change LeafSize", () -> {
    UI_setTo_Modify_LeafSize(0);
  });

  menuActions.put("Pick LeafSize", () -> {
    UI_setTo_Modify_LeafSize(1);
  });

  menuActions.put("Assign LeafSize", () -> {
    UI_setTo_Modify_LeafSize(2);
  });

  menuActions.put("Model1DsProps", () -> {
    UI_setTo_Modify_Model1DsProps(0);
  });

  menuActions.put("Pick Model1DsProps", () -> {
    UI_setTo_Modify_Model1DsProps(1);
  });

  menuActions.put("Assign Model1DsProps", () -> {
    UI_setTo_Modify_Model1DsProps(2);
  });

  menuActions.put("Orthographic", () -> {
    UI_setTo_View_ProjectionType(0);
  });

  menuActions.put("Perspective", () -> {
    UI_setTo_View_ProjectionType(1);
  });

  menuActions.put("Invert Selection", () -> {
    Select3D.invertSelection();
  });

  menuActions.put("Deselect All", () -> {
    Select3D.deselectAll();
  });

  menuActions.put("Select All", () -> {
    Select3D.selectAll();
  });

  menuActions.put("Select All Cameras", () -> selectAllOfCategory(ObjectCategory.CAMERA));

  menuActions.put("Select All Sections", () -> selectAllOfCategory(ObjectCategory.SECTION));

  menuActions.put("Select All Solids", () -> selectAllOfCategory(ObjectCategory.SOLID));

  menuActions.put("Select All Faces", () -> selectAllOfCategory(ObjectCategory.FACE));

  menuActions.put("Select All Polylines", () -> selectAllOfCategory(ObjectCategory.POLYLINE));

  menuActions.put("Select All Verices", () -> selectAllOfCategory(ObjectCategory.VERTEX));

  menuActions.put("Select All Groups", () -> selectAllOfCategory(ObjectCategory.GROUP));

  menuActions.put("Select All Model1Ds", () -> selectAllOfCategory(ObjectCategory.MODEL1D));

  menuActions.put("Select All Model2Ds", () -> selectAllOfCategory(ObjectCategory.MODEL2D));

  menuActions.put("Select Solid", () -> switch_category(ObjectCategory.SOLID));

  menuActions.put("Select Section", () -> switch_category(ObjectCategory.SECTION));

  menuActions.put("Select Camera", () -> switch_category(ObjectCategory.CAMERA));

  menuActions.put("Select LandPoint", () -> switch_category(ObjectCategory.LANDPOINT));

  menuActions.put("Select Model1Ds", () -> switch_category(ObjectCategory.MODEL1D));

  menuActions.put("Select Model2Ds", () -> switch_category(ObjectCategory.MODEL2D));

  menuActions.put("Select Group", () -> switch_category(ObjectCategory.GROUP));

  menuActions.put("Select Face", () -> switch_category(ObjectCategory.FACE));

  menuActions.put("Select Polyline", () -> switch_category(ObjectCategory.POLYLINE));

  menuActions.put("Select Vertex", () -> switch_category(ObjectCategory.VERTEX));

  menuActions.put("Soft Selection", () -> {
    Select3D.convert_Vertex_to_softSelection();

    switch_category(ObjectCategory.SOFTVERTEX);
  });

  menuActions.put("Vertices >> Groups", () -> convertAndSwitch(() -> Select3D.convert_Vertices_to_Groups(), ObjectCategory.GROUP));

  menuActions.put("Faces >> Groups", () -> convertAndSwitch(() -> Select3D.convert_Faces_to_Groups(), ObjectCategory.GROUP));

  menuActions.put("Groups >> Faces", () -> convertAndSwitch(() -> Select3D.convert_Groups_to_Faces(), ObjectCategory.FACE));

  menuActions.put("Polylines >> Groups", () -> convertAndSwitch(() -> Select3D.convert_Polylines_to_Groups(), ObjectCategory.GROUP));

  menuActions.put("Groups >> Polylines", () -> convertAndSwitch(() -> Select3D.convert_Groups_to_Polylines(), ObjectCategory.POLYLINE));

  menuActions.put("Polylines >> Vertices", () -> convertAndSwitch(() -> Select3D.convert_Polylines_to_Vertices(), ObjectCategory.VERTEX));

  menuActions.put("Vertices >> Polylines", () -> convertAndSwitch(() -> Select3D.convert_Vertices_to_Polylines(), ObjectCategory.POLYLINE));

  menuActions.put("Groups >> Vertices", () -> convertAndSwitch(() -> Select3D.convert_Groups_to_Vertices(), ObjectCategory.VERTEX));

  menuActions.put("Faces >> Vertices", () -> convertAndSwitch(() -> Select3D.convert_Faces_to_Vertices(), ObjectCategory.VERTEX));

  menuActions.put("Vertices >> Faces", () -> convertAndSwitch(() -> Select3D.convert_Vertices_to_Faces(), ObjectCategory.FACE));

  menuActions.put("Solids >> Groups", () -> convertAndSwitch(() -> Select3D.convert_Solids_to_Groups(), ObjectCategory.GROUP));

  menuActions.put("Groups >> Solids", () -> convertAndSwitch(() -> Select3D.convert_Groups_to_Solids(), ObjectCategory.SOLID));

  menuActions.put("Model2Ds >> Groups", () -> convertAndSwitch(() -> Select3D.convert_Model2Ds_to_Groups(), ObjectCategory.GROUP));

  menuActions.put("Groups >> Model2Ds", () -> convertAndSwitch(() -> Select3D.convert_Groups_to_Model2Ds(), ObjectCategory.MODEL2D));

  menuActions.put("Model1Ds >> Groups", () -> convertAndSwitch(() -> Select3D.convert_Model1Ds_to_Groups(), ObjectCategory.GROUP));

  menuActions.put("Groups >> Model1Ds", () -> convertAndSwitch(() -> Select3D.convert_Groups_to_Model1Ds(), ObjectCategory.MODEL1D));

  menuActions.put("Pick Select", () -> {
    UI_setTo_View_PickSelect(0);
  });

  menuActions.put("Pick Select+", () -> {
    UI_setTo_View_PickSelect(1);
  });

  menuActions.put("Pick Select-", () -> {
    UI_setTo_View_PickSelect(2);
  });

  menuActions.put("Window Select", () -> {
    UI_setTo_View_WindowSelect(0);
  });

  menuActions.put("Window Select+", () -> {
    UI_setTo_View_WindowSelect(1);
  });

  menuActions.put("Window Select-", () -> {
    UI_setTo_View_WindowSelect(2);
  });

  menuActions.put("Select Near Selected Vertices", () -> {
    Select3D.selectNearVertices();
  });

  menuActions.put("Weld Objects Selected Vertices", () -> {
    Modify3D.weldObjectsVertices_Selection(User3D.modify_WeldTreshold);
  });

  menuActions.put("Weld Scene Selected Vertices", () -> {
    Modify3D.weldSceneVertices_Selection(User3D.modify_WeldTreshold);
  });

  menuActions.put("Reposition Selected Vertices", () -> {
    Modify3D.repositionVertices_Selection();
  });

  menuActions.put("Separate Selected Vertices", () -> {
    Modify3D.separateVertices_Selection();
  });

  menuActions.put("Select Scene Isolated Vertices", () -> {
    Select3D.isolatedVertices_Scene();
  });

  menuActions.put("Delete Scene Isolated Vertices", () -> {
    Delete3D.isolatedVertices_Scene();
  });

  menuActions.put("Delete Selection Isolated Vertices", () -> {
    Delete3D.isolatedVertices_Selection();
  });

  menuActions.put("Delete Scene Empty Groups", () -> {
    allGroups.deleteEmptyGroups_Scene();
  });

  menuActions.put("Delete Selection", () -> {
    Delete3D.selection();
  });

  menuActions.put("Dettach from Groups Selection", () -> {
    allGroups.dettachFromGroups_Selection();
  });

  menuActions.put("Ungroup Selection", () -> {
    allGroups.ungroup_Selection();
  });

  menuActions.put("Group Selection", () -> {
    allGroups.group_Selection(1);
  });

  menuActions.put("Attach to Last Group", () -> {
    allGroups.group_Selection(0);
  });

  menuActions.put("Clone Selection (Identical)", () -> {
    Clone3D.selection(true);
  });

  menuActions.put("Clone Selection (Variation)", () -> {
    Clone3D.selection(false);
  });

  menuActions.put("Auto-Normal Selected Faces", () -> {
    Modify3D.autoNormalFaces_Selection();
  });

  menuActions.put("Force Triangulate Selected Faces", () -> {
    Modify3D.forceTriangulateFaces_Selection();
  });

  menuActions.put("Insert Corner Opennings", () -> {
    Modify3D.insertCornerOpennings_Selection();
  });

  menuActions.put("Insert Parallel Opennings", () -> {
    Modify3D.insertParallelOpennings_Selection();
  });

  menuActions.put("Insert Rotated Opennings", () -> {
    Modify3D.insertRotatedOpennings_Selection();
  });

  menuActions.put("Insert Edge Opennings", () -> {
    Modify3D.insertEdgeOpennings_Selection();
  });

  menuActions.put("Optimize Faces", () -> {
    Modify3D.optimizeFace_Selection();
  });

  menuActions.put("Tessellate Rows & Columns", () -> {
    Modify3D.tessellateRowsColumns_Selection();
  });

  menuActions.put("Tessellate Rectangular", () -> {
    Modify3D.tessellateRectangular_Selection();
  });

  menuActions.put("Tessellate Triangular", () -> {
    Modify3D.tessellateTriangular_Selection();
  });

  menuActions.put("Extrude Face Edges", () -> {
    Modify3D.extrudeFaceEdges_Selection();
  });

  menuActions.put("Offset(above) Vertices", () -> {
    Modify3D.offsetVertices_Selection(0, abs(User3D.modify_OffsetAmount));
  });

  menuActions.put("Offset(below) Vertices", () -> {
    Modify3D.offsetVertices_Selection(0, -abs(User3D.modify_OffsetAmount));
  });

  menuActions.put("Offset(expand) Vertices", () -> {
    Modify3D.offsetVertices_Selection(1, abs(User3D.modify_OffsetAmount));
  });

  menuActions.put("Offset(shrink) Vertices", () -> {
    Modify3D.offsetVertices_Selection(1, -abs(User3D.modify_OffsetAmount));
  });

  menuActions.put("Reverse Visibility of All Faces", () -> {
    Modify3D.reverseVisibilityFaces_Scene();
  });

  menuActions.put("Hide All Faces", () -> {
    Modify3D.changeVisibilityFaces_Scene(0);
  });

  menuActions.put("Unhide All Faces", () -> {
    Modify3D.changeVisibilityFaces_Scene(1);
  });

  menuActions.put("Hide Selected Faces", () -> {
    Modify3D.changeVisibilityFaces_Selection(0);
  });

  menuActions.put("Unhide Selected Faces", () -> {
    Modify3D.changeVisibilityFaces_Selection(1);
  });

  menuActions.put("Isolate Selection", () -> {
    Modify3D.isolate_Selection();
  });

  menuActions.put("Flatten Selected LandPoints", () -> {
    Modify3D.flatten_LandPoints();
  });

  menuActions.put("Add People on Land", () -> {
    Create3D.add_onLand(1); // 1 = people
  });

  menuActions.put("Add 2D-Trees on Land", () -> {
    Create3D.add_onLand(2); // 2 = 2D trees
  });

  menuActions.put("Add 1D-Trees on Land", () -> {
    Create3D.add_onLand(3); // 3 = 1D trees
  });

  menuActions.put("Delete All Model1Ds", () -> {
    allModel1Ds.makeEmpty(0);
  });

  menuActions.put("Delete All Model2Ds", () -> {
    allModel2Ds.makeEmpty(0);
  });

  menuActions.put("Delete All Groups", () -> {
    allGroups.makeEmpty(0);
  });

  menuActions.put("Delete All Solids", () -> {
    allSolids.makeEmpty(0);
  });

  menuActions.put("Delete All Sections", () -> {
    allSections.makeEmpty(0);
  });

  menuActions.put("Delete All Cameras", () -> {
    allCameras.makeEmpty(0);
  });

  menuActions.put("Delete All Faces", () -> {
    allFaces.makeEmpty(0);
  });

  menuActions.put("Delete All Polylines", () -> {
    allPolylines.makeEmpty(0);
  });

  menuActions.put("Delete All", () -> {
    deleteAll();
  });

  menuActions.put("TargetRoll", () -> {
    UI_setTo_View_TargetRoll(0);
  });

  menuActions.put("TargetRollZ", () -> {
    UI_setTo_View_TargetRoll(1);
  });

  menuActions.put("TargetRollXY", () -> {
    UI_setTo_View_TargetRoll(2);
  });

  menuActions.put("CameraRoll", () -> {
    UI_setTo_View_CameraRoll(0);
  });

  menuActions.put("CameraRollZ", () -> {
    UI_setTo_View_CameraRoll(1);
  });

  menuActions.put("CameraRollXY", () -> {
    UI_setTo_View_CameraRoll(2);
  });

  menuActions.put("Orbit", () -> {
    UI_setTo_View_Orbit(0);
  });

  menuActions.put("OrbitZ", () -> {
    UI_setTo_View_Orbit(1);
  });

  menuActions.put("OrbitXY", () -> {
    UI_setTo_View_Orbit(2);
  });

  menuActions.put("LandOrbit", () -> {
    UI_setTo_View_LandOrbit(0);
  });

  menuActions.put("Pan", () -> {
    UI_setTo_View_Pan(0);
  });

  menuActions.put("PanX", () -> {
    UI_setTo_View_Pan(1);
  });

  menuActions.put("PanY", () -> {
    UI_setTo_View_Pan(2);
  });

  menuActions.put("Zoom", () -> {
    UI_setTo_View_ZOOM(0);
  });

  menuActions.put("Zoom as default", () -> {
    UI_setTo_View_ZOOM(1);
  });

  menuActions.put("TruckX", () -> {
    UI_setTo_View_Truck(1);
  });

  menuActions.put("TruckY", () -> {
    UI_setTo_View_Truck(2);
  });

  menuActions.put("TruckZ", () -> {
    UI_setTo_View_Truck(0);
  });

  menuActions.put("DistZ", () -> {
    UI_setTo_View_Truck(0);
  });

  menuActions.put("CameraDistance", () -> {
    UI_setTo_View_CameraDistance(0);
  });

  menuActions.put("DistMouseXY", () -> {
    UI_setTo_View_DistMouseXY(0);
  });

  menuActions.put("Look at origin", () -> {
    UI_setTo_View_LookAtOrigin(0);
  });

  menuActions.put("Look at direction", () -> {
    UI_setTo_View_LookAtDirection(0);
  });

  menuActions.put("Look at selection", () -> {
    UI_setTo_View_LookAtSelection(0);
  });

  menuActions.put("3DModelSize", () -> {
    UI_setTo_View_3DModelSize();
  });

  menuActions.put("SkydomeSize", () -> {
    UI_setTo_View_SkydomeSize();
  });

  menuActions.put("AllModelSize", () -> {
    UI_setTo_View_AllModelSize();
  });

  menuActions.put("Display All Viewports", () -> {
    UI_setTo_Viewport(0);
  });

  menuActions.put("Enlarge 3D Viewport", () -> {
    UI_setTo_Viewport(1);
  });

  menuActions.put("Enlarge Time Viewport", () -> {
    UI_setTo_Viewport(2);
  });

  menuActions.put("Enlarge Map Viewport", () -> {
    UI_setTo_Viewport(3);
  });

  menuActions.put("Top", () -> {
    UI_setTo_View_3DViewPoint(0);
  });

  menuActions.put("Front", () -> {
    UI_setTo_View_3DViewPoint(1);
  });

  menuActions.put("Left", () -> {
    UI_setTo_View_3DViewPoint(2);
  });

  menuActions.put("Back", () -> {
    UI_setTo_View_3DViewPoint(3);
  });

  menuActions.put("Right", () -> {
    UI_setTo_View_3DViewPoint(4);
  });

  menuActions.put("Bottom", () -> {
    UI_setTo_View_3DViewPoint(5);
  });

  menuActions.put("S.W.", () -> {
    UI_setTo_View_3DViewPoint(6);
  });

  menuActions.put("S.E.", () -> {
    UI_setTo_View_3DViewPoint(7);
  });

  menuActions.put("N.E.", () -> {
    UI_setTo_View_3DViewPoint(8);
  });

  menuActions.put("N.W.", () -> {
    UI_setTo_View_3DViewPoint(9);
  });

  menuActions.put("PivotX:Minimum", () -> {
    UI_setTo_View_PivotX(-1);
  });

  menuActions.put("PivotX:Center", () -> {
    UI_setTo_View_PivotX(0);
  });

  menuActions.put("PivotX:Maximum", () -> {
    UI_setTo_View_PivotX(1);
  });

  menuActions.put("PivotY:Minimum", () -> {
    UI_setTo_View_PivotY(-1);
  });

  menuActions.put("PivotY:Center", () -> {
    UI_setTo_View_PivotY(0);
  });

  menuActions.put("PivotY:Maximum", () -> {
    UI_setTo_View_PivotY(1);
  });

  menuActions.put("PivotZ:Minimum", () -> {
    UI_setTo_View_PivotZ(-1);
  });

  menuActions.put("PivotZ:Center", () -> {
    UI_setTo_View_PivotZ(0);
  });

  menuActions.put("PivotZ:Maximum", () -> {
    UI_setTo_View_PivotZ(1);
  });

  for (int n = -2; n <= 8; n++) {
    final int layoutIndex = n;
    menuActions.put("Layout " + nf(layoutIndex, 0), () -> {
      STUDY.plotSetup = layoutIndex;
      STUDY.revise();
    });
  }

  for (int n = 1; n <= 11; n++) {
    final int modelIndex = n;
    menuActions.put("3D-model " + nf(modelIndex, 0), () -> {
      deleteAll();
      Create3D.add_DefaultModel(modelIndex);
      allSolidImpacts.calculate_Impact_selectedSections();
      UI_rollout.revise();
      WIN3D.revise();
    });
  }
}
