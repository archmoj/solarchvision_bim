// Shared m/tes/lyr/vsb/wgt/clz argument prefix every Create3D-backed
// command (HOUSE1/2/3, MESH3/MESH4, and any later addition) takes the
// same way - factored out since houseCommandArgs() below and the
// Pyramid/Plane mesh calls in the UITASK.Create branch both need it
// verbatim.
String creatorCommandArgs() {
  return " m=" + User3D.creatorMaterial +
         " tes=" + User3D.creatorTessellation +
         " lyr=" + User3D.creatorLayer +
         " vsb=" + User3D.creatorVisibility +
         " wgt=" + User3D.creatorWeight +
         " clz=" + User3D.creatorClosed;
}

// x/y/z/dx/dy/dz/h/r argument string for the House1/House2/House3
// commands (runScript.pde's HOUSE1/HOUSE2/HOUSE3 cases) - used by the
// UITASK.Create House1/2/3 branches below instead of calling
// Create3D.add_HouseN_Core(...) directly, so a mouse-click creation
// goes through the exact same public command a typed "House1 ..." line
// (or a future UI/logging/testing layer) would, per the broader
// "develop the public API via actions instead of internal calls" goal
// this is part of.
//
// dx/dy/dz here are 2*rx/2*ry/2*rz, not rx/ry/rz directly: the House1/2/3
// command cases treat dx/dy/dz as full widths and halve them internally
// (0.5 * dx) before calling Create3D.add_HouseN_Core, while rx/ry/rz
// here are already half-widths - passing them unchanged would silently
// halve the object's size a second time.
String houseCommandArgs(float x, float y, float z, float rx, float ry, float rz, float h, float rot) {
  return creatorCommandArgs() +
         " x=" + x + " y=" + y + " z=" + z +
         " dx=" + (2 * rx) + " dy=" + (2 * ry) + " dz=" + (2 * rz) +
         " h=" + h + " r=" + rot;
}

// x/y/z/dx/dy/dz/r argument string shared by Box, Octahedron, Cylinder
// and Parametric - the same shape as houseCommandArgs() above minus the
// extra h/dh height parameter only the houses have.
String boxLikeCommandArgs(float x, float y, float z, float rx, float ry, float rz, float rot) {
  return creatorCommandArgs() +
         " x=" + x + " y=" + y + " z=" + z +
         " dx=" + (2 * rx) + " dy=" + (2 * ry) + " dz=" + (2 * rz) +
         " r=" + rot;
}

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

void setimpactGraphIndex(int impacts, boolean showWindRoses) {
  STUDY.impactGraphIndex = impacts;
  STUDY.plotLayoutIndex = 0;
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
// Weight) WIN3D.currentTool currently is, either reads face f's
// current value into the matching User3D.default_* (Pick,
// toolParameterModifier==1), writes User3D.default_* onto face f alone
// (Assign(sub), ==2), or writes it onto every face in f's group
// (Assign(all), ==3, via allGroups.findGroupContainingFace/
// getStart_Face/getStop_Face - already covered directly in
// GroupsTest.java). Preserved exactly as found, including one existing
// quirk: Assign(all)'s Weight case calls allFaces.setClose(...) rather
// than setWeight(...), unlike the identical-looking Pick and
// Assign(sub) cases just above it - kept as-is since this refactor
// changes structure, not behavior.
void pickOrAssignFaceProperty (int f) {
  if ((WIN3D.currentTool != UITASK.Seed_Material) &&
      (WIN3D.currentTool != UITASK.Tessellation) &&
      (WIN3D.currentTool != UITASK.Layer) &&
      (WIN3D.currentTool != UITASK.Visibility) &&
      (WIN3D.currentTool != UITASK.Weight)) return;

  if (WIN3D.toolParameterModifier == 1) { // Pick
    if (WIN3D.currentTool == UITASK.Seed_Material) User3D.creatorMaterial     = allFaces.getMaterial(f);
    else if (WIN3D.currentTool == UITASK.Tessellation)  User3D.creatorTessellation = allFaces.getTessellation(f);
    else if (WIN3D.currentTool == UITASK.Layer)         User3D.creatorLayer        = allFaces.getLayer(f);
    else if (WIN3D.currentTool == UITASK.Visibility)    User3D.creatorVisibility   = allFaces.getVisibility(f);
    else if (WIN3D.currentTool == UITASK.Weight)        User3D.creatorWeight       = allFaces.getWeight(f);
  }
  if (WIN3D.toolParameterModifier == 2) { // Assign(sub)
    if (WIN3D.currentTool == UITASK.Seed_Material) allFaces.setMaterial    (f, User3D.creatorMaterial);
    else if (WIN3D.currentTool == UITASK.Tessellation)  allFaces.setTessellation(f, User3D.creatorTessellation);
    else if (WIN3D.currentTool == UITASK.Layer)         allFaces.setLayer       (f, User3D.creatorLayer);
    else if (WIN3D.currentTool == UITASK.Visibility)    allFaces.setVisibility  (f, User3D.creatorVisibility);
    else if (WIN3D.currentTool == UITASK.Weight)        allFaces.setWeight      (f, User3D.creatorWeight);
  }
  if (WIN3D.toolParameterModifier == 3) { // Assign(all)
    int OBJ_ID = allGroups.findGroupContainingFace(f);

    for (int q = allGroups.getStart_Face(OBJ_ID); q <= allGroups.getStop_Face(OBJ_ID); q++) {
      if (WIN3D.currentTool == UITASK.Seed_Material) allFaces.setMaterial    (q, User3D.creatorMaterial);
      else if (WIN3D.currentTool == UITASK.Tessellation)  allFaces.setTessellation(q, User3D.creatorTessellation);
      else if (WIN3D.currentTool == UITASK.Layer)         allFaces.setLayer       (q, User3D.creatorLayer);
      else if (WIN3D.currentTool == UITASK.Visibility)    allFaces.setVisibility  (q, User3D.creatorVisibility);
      else if (WIN3D.currentTool == UITASK.Weight)        allFaces.setClose       (q, User3D.creatorWeight);
    }
  }
}

// Pulled out of mouseClicked()'s UITASK.Seed_Material handling for a
// clicked MODEL2D instance: MODEL2D's own MAP[] encodes both which
// PEOPLE/TREES filename an instance uses (abs(MAP[OBJ_ID])) and a
// left/right-facing flip (its sign) in one int. Pick
// (toolParameterModifier==1) reads the clicked instance's own type
// into User3D.creatorPlantTypeIndex or createPersonTypeIndex depending on
// allModel2Ds.isTree(); Assign (==2 or ==3 - both treated identically
// here, unlike the FACE property case above) writes the current
// createPlantTypeIndex/createPersonTypeIndex back onto MAP[OBJ_ID], carrying
// that instance's own sign (its flip) forward unchanged.
void pickOrAssignModel2DSeedMaterial (int OBJ_ID) {
  if (WIN3D.currentTool != UITASK.Seed_Material) return;

  int n = allModel2Ds.MAP[OBJ_ID];
  int sign_n = 1;
  if (n < 0) sign_n = -1;
  n = abs(n);
  int n1 = allModel2Ds.peopleFileCount;

  if (WIN3D.toolParameterModifier == 1) { // Pick
    if (allModel2Ds.isTree(n)) { // case: trees
      User3D.creatorPlantTypeIndex = n - n1;
    }
    else { // case: people
      User3D.creatorPersonTypeIndex = n;
    }
  }
  if ((WIN3D.toolParameterModifier == 2) || (WIN3D.toolParameterModifier == 3)) { // Assign
    if (allModel2Ds.isTree(n)) { // case: trees
      allModel2Ds.MAP[OBJ_ID] = sign_n * (User3D.creatorPlantTypeIndex + n1);
    }
    else { // case: people
      allModel2Ds.MAP[OBJ_ID] = sign_n * User3D.creatorPersonTypeIndex;
    }
  }
}

// Pulled out of mouseClicked()'s handling for a clicked MODEL1D
// instance: for whichever of the seven per-tree properties
// (DegreeMax/BranchTilt/BranchTwist/BranchRatio/TreeBase/TrunkSize/
// LeafSize) WIN3D.currentTool currently is - or all of them at once,
// for UITASK.Model1DsProps - either reads OBJ_ID's current value(s)
// into the matching User3D.creatorModel1D* (Pick,
// toolParameterModifier==1) or writes the matching User3D.creator_
// Model1D_* value(s) back onto OBJ_ID (Assign, ==2).
void pickOrAssignModel1DProperty (int OBJ_ID) {
  if (WIN3D.toolParameterModifier == 1) { // Pick
    if (WIN3D.currentTool == UITASK.DegreeMax) User3D.creatorModel1DDegreeMax = allModel1Ds.getDegreeMax(OBJ_ID);
    else if (WIN3D.currentTool == UITASK.BranchTilt) User3D.creatorModel1DBranchTilt = allModel1Ds.getBranchTilt(OBJ_ID);
    else if (WIN3D.currentTool == UITASK.BranchTwist) User3D.creatorModel1DBranchTwist = allModel1Ds.getBranchTwist(OBJ_ID);
    else if (WIN3D.currentTool == UITASK.BranchRatio) User3D.creatorModel1DBranchRatio = allModel1Ds.getBranchRatio(OBJ_ID);
    else if (WIN3D.currentTool == UITASK.TreeBase) User3D.creatorModel1DTreeBase = allModel1Ds.getTreeBase(OBJ_ID);

    else if (WIN3D.currentTool == UITASK.TrunkSize) User3D.creatorModel1DTrunkSize = allModel1Ds.getTrunkSize(OBJ_ID);
    else if (WIN3D.currentTool == UITASK.LeafSize) User3D.creatorModel1DLeafSize = allModel1Ds.getLeafSize(OBJ_ID);
    else if (WIN3D.currentTool == UITASK.Model1DsProps) { // all properties
      User3D.creatorModel1DDegreeMax = allModel1Ds.getDegreeMax(OBJ_ID);
      User3D.creatorModel1DTrunkSize = allModel1Ds.getTrunkSize(OBJ_ID);
      User3D.creatorModel1DLeafSize = allModel1Ds.getLeafSize(OBJ_ID);
    }
  }
  if (WIN3D.toolParameterModifier == 2) { // Assign
    if (WIN3D.currentTool == UITASK.DegreeMax) allModel1Ds.setDegreeMax(OBJ_ID, User3D.creatorModel1DDegreeMax);
    else if (WIN3D.currentTool == UITASK.BranchTilt) allModel1Ds.setBranchTilt(OBJ_ID, User3D.creatorModel1DBranchTilt);
    else if (WIN3D.currentTool == UITASK.BranchTwist) allModel1Ds.setBranchTwist(OBJ_ID, User3D.creatorModel1DBranchTwist);
    else if (WIN3D.currentTool == UITASK.BranchRatio) allModel1Ds.setBranchRatio(OBJ_ID, User3D.creatorModel1DBranchRatio);
    else if (WIN3D.currentTool == UITASK.TreeBase) allModel1Ds.setTreeBase(OBJ_ID, User3D.creatorModel1DTreeBase);

    else if (WIN3D.currentTool == UITASK.TrunkSize) allModel1Ds.setTrunkSize(OBJ_ID, User3D.creatorModel1DTrunkSize);
    else if (WIN3D.currentTool == UITASK.LeafSize) allModel1Ds.setLeafSize(OBJ_ID, User3D.creatorModel1DLeafSize);
    else if (WIN3D.currentTool == UITASK.Model1DsProps) { // all properties
      allModel1Ds.setDegreeMax(OBJ_ID, User3D.creatorModel1DDegreeMax);
      allModel1Ds.setTrunkSize(OBJ_ID, User3D.creatorModel1DTrunkSize);
      allModel1Ds.setLeafSize(OBJ_ID, User3D.creatorModel1DLeafSize);
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
// category (POLYLINE, FACE, CAMERA, SECTION, TERRAIN), same as the
// original inline code left x1/y1/z1 unset (and therefore "undefined")
// for those.
float[] getMoveOriginPoint () {
  float x1 = FLOAT_undefined;
  float y1 = FLOAT_undefined;
  float z1 = FLOAT_undefined;

  if (currentObjectCategory == ObjectCategory.GROUP) {

    float[] P = Select3D.getPivot();

    x1 = P[0];
    y1 = P[1];
    z1 = P[2];
  } else if (currentObjectCategory == ObjectCategory.MODEL2D) {

    x1 = allModel2Ds.getX(Select3D.model2DSelection[Select3D.model2DSelection.length - 1]);
    y1 = allModel2Ds.getY(Select3D.model2DSelection[Select3D.model2DSelection.length - 1]);
    z1 = allModel2Ds.getZ(Select3D.model2DSelection[Select3D.model2DSelection.length - 1]);
  } else if (currentObjectCategory == ObjectCategory.MODEL1D) {

    x1 = allModel1Ds.getX(Select3D.model1DSelection[Select3D.model1DSelection.length - 1]);
    y1 = allModel1Ds.getY(Select3D.model1DSelection[Select3D.model1DSelection.length - 1]);
    z1 = allModel1Ds.getZ(Select3D.model1DSelection[Select3D.model1DSelection.length - 1]);
  } else if (currentObjectCategory == ObjectCategory.SOLID) {

    x1 = allSolids.get_posX(Select3D.solidSelection[Select3D.solidSelection.length - 1]);
    y1 = allSolids.get_posY(Select3D.solidSelection[Select3D.solidSelection.length - 1]);
    z1 = allSolids.get_posZ(Select3D.solidSelection[Select3D.solidSelection.length - 1]);
  } else if (currentObjectCategory == ObjectCategory.VERTEX) {

    x1 = allPoints.getX(Select3D.vertexSelection[Select3D.vertexSelection.length - 1]);
    y1 = allPoints.getY(Select3D.vertexSelection[Select3D.vertexSelection.length - 1]);
    z1 = allPoints.getZ(Select3D.vertexSelection[Select3D.vertexSelection.length - 1]);
  }

  return new float[]{x1, y1, z1};
}

// Pulled out of mouseClicked()'s UITASK.Move handling: the move vector
// from (x1,y1,z1) to (x2,y2,z2), then zeroed down to a single axis
// according to Select3D.positionVectorIndex - 0 keeps only X, 1 keeps only Y, 2
// keeps only Z (positionVectorIndex's own default), and any other value
// (typically 3, meaning "All") leaves all three components as-is.
float[] computeMoveDelta (float x1, float y1, float z1, float x2, float y2, float z2) {
  float dx = x2 - x1;
  float dy = y2 - y1;
  float dz = z2 - z1;

  int the_Vector = Select3D.positionVectorIndex;

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
// overallScale) space: starts at the current camera position, aimed
// through WIN3D.calculate_Click3D(Image_X, Image_Y) (already covered
// directly in WIN3DTest.java) - except in orthographic view (projectionTypeIndex
// == 0), where there's no real camera point to start from, so the
// start point is instead offset from the camera position by however far
// calculate_Click3D(Image_X, Image_Y) itself differs from
// calculate_Click3D(0, 0), keeping parallel rays parallel.
ClickRay computeClickRay (float Image_X, float Image_Y) {
  ClickRay ray = new ClickRay();

  float[] ray_start = {
    WIN3D.cameraX, WIN3D.cameraY, WIN3D.cameraZ
  };

  float[] ray_end = WIN3D.calculate_Click3D(Image_X, Image_Y);

  ray_start[0] /= overallScale;
  ray_start[1] /= overallScale;
  ray_start[2] /= overallScale;

  ray_end[0] /= overallScale;
  ray_end[1] /= overallScale;
  ray_end[2] /= overallScale;

  if (WIN3D.projectionTypeIndex == 0) {
    float[] ray_center = WIN3D.calculate_Click3D(0, 0);

    ray_center[0] /= overallScale;
    ray_center[1] /= overallScale;
    ray_center[2] /= overallScale;

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
// random() in two places (when createLength/Width/Height is negative,
// meaning "randomize within this range", and when createRandomSuperellipsoidPower is on) -
// callers that want a fully deterministic result should use non-negative
// lengths and turn createRandomSuperellipsoidPower off.
CreateParams computeCreateParams (float[] RxP) {
  CreateParams p = new CreateParams();

  p.x = RxP[1];
  p.y = RxP[2];
  p.z = RxP[3];

  p.rot = User3D.creatorOrientation;
  if (p.rot == 360) p.rot = WIN3D.rotationZ;

  p.rx = 0.5 * User3D.creatorLength;
  if (p.rx < 0) p.rx = random(0.25 * abs(p.rx), abs(p.rx));

  p.ry = 0.5 * User3D.creatorWidth;
  if (p.ry < 0) p.ry = random(0.25 * abs(p.ry), abs(p.ry));

  p.rz = 0.5 * User3D.creatorHeight;
  if (p.rz < 0) p.rz = random(0.25 * abs(p.rz), abs(p.rz));

  p.px = User3D.creatorSuperellipsoidPowerX;
  p.py = User3D.creatorSuperellipsoidPowerY;
  p.pz = User3D.creatorSuperellipsoidPowerZ;

  if (User3D.creatorRandomSuperellipsoidPower == 1) {
    p.px = pow(2, int(random(5)) - 1);
    p.py = p.px;
    p.pz = p.px;
  }

  if (User3D.creatorVolume != 0) {

    if ((p.rx != 0) && (p.ry != 0)) {
      p.rz = User3D.creatorVolume / (8 * p.rx * p.ry);
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

  if ((currentObjectCategory != ObjectCategory.MODEL1D) &&
      (currentObjectCategory != ObjectCategory.MODEL2D) &&
      (currentObjectCategory != ObjectCategory.TERRAIN) &&
      (currentObjectCategory != ObjectCategory.CAMERA) &&
      (currentObjectCategory != ObjectCategory.SECTION)) {

    p.x -= p.rx * Select3D.pivotAlignmentX;
    p.y -= p.ry * Select3D.pivotAlignmentY;
    p.z -= p.rz * Select3D.pivotAlignmentZ;
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
// what a new camera's own positionX/Y/Z/T and rotationX/Y/Z/T would be
// if its eye sat at (x, y, z + EyeLevel), by temporarily overwriting
// WIN3D's own cameraX/y/z and calling its (already directly tested in
// WIN3DTest.java) reverseTransform_3DViewport(), then restoring every
// WIN3D field it touched back to what it was - this function's caller
// used to do that save/compute/restore dance inline, right before
// allCameras.create(); now it just calls this and passes the result
// straight through.
CameraParams computeCameraParamsAtPoint (float x, float y, float z) {
  float keep_cameraX = WIN3D.cameraX;
  float keep_cameraY = WIN3D.cameraY;
  float keep_cameraZ = WIN3D.cameraZ;
  float keep_positionX = WIN3D.positionX;
  float keep_positionY = WIN3D.positionY;
  float keep_positionZ = WIN3D.positionZ;
  float keep_positionStep = WIN3D.positionStep;
  float keep_rotationX = WIN3D.rotationX;
  float keep_rotationY = WIN3D.rotationY;
  float keep_rotationZ = WIN3D.rotationZ;
  float keep_rotationStep = WIN3D.rotationStep;
  float keep_Zoom = WIN3D.zoom;

  WIN3D.cameraX = x;
  WIN3D.cameraY = y;
  WIN3D.cameraZ = z + EyeLevel;

  WIN3D.reverseTransform_3DViewport();

  CameraParams cp = new CameraParams();
  cp.pX = WIN3D.positionX;
  cp.pY = WIN3D.positionY;
  cp.pZ = WIN3D.positionZ;
  cp.pT = WIN3D.positionStep;
  cp.rX = WIN3D.rotationX;
  cp.rY = WIN3D.rotationY;
  cp.rZ = WIN3D.rotationZ;
  cp.rT = WIN3D.rotationStep;
  cp.zoom = WIN3D.zoom;
  cp.type = WIN3D.projectionTypeIndex;

  WIN3D.cameraX = keep_cameraX;
  WIN3D.cameraY = keep_cameraY;
  WIN3D.cameraZ = keep_cameraZ;
  WIN3D.positionX = keep_positionX;
  WIN3D.positionY = keep_positionY;
  WIN3D.positionZ = keep_positionZ;
  WIN3D.positionStep = keep_positionStep;
  WIN3D.rotationX = keep_rotationX;
  WIN3D.rotationY = keep_rotationY;
  WIN3D.rotationZ = keep_rotationZ;
  WIN3D.rotationStep = keep_rotationStep;
  WIN3D.zoom = keep_Zoom;

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
// before extracting). toolParameterModifier selects the mode: 1 always
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
  if (WIN3D.toolParameterModifier == 1) flip_face = 1;
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

    if (WIN3D.toolParameterModifier == 2) {
      if (V > 0) flip_face = 1;
    }
    if (WIN3D.toolParameterModifier == 3) {
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
// Select3D.faceSelection/faceDisplayvertexSelection) and once against
// allPolylines.nodes[f] (with Select3D.polylineSelection/
// polylineDisplayvertexSelection), confirmed identical modulo which array
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
// several Climate Typical Year stations sit close enough together that a click can't
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
// only opens while its own dataset is the active currentDataSource.

final float PICKLIST_SCROLLBAR_WIDTH = 14;
final float pad = 1.6 * MessageSize;
final float rowHeight = 1.6 * MessageSize;
final float headerHeight = 1.6 * MessageSize;

abstract class StationPicker {

  String name;      // shown in the title bar, e.g. "Pick Climate Typical Year Station"
  float maxDist;    // metres
  int maxCount;
  int dataSourceID; // only offer the list while currentDataSource == this

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
  // coordinates array live (e.g. `return climateTypicalYearCoordinates;`) rather
  // than this class capturing it once at construction time - these
  // pickers are themselves top-level field initializers, which Processing
  // runs before setup() has populated the actual coordinate arrays (they
  // start out null and are only filled in later by e.g.
  // loadClimateTypicalYearCoordinates()), so capturing the array in the constructor
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

    if ((nearby.length > 0) && (currentDataSource == this.dataSourceID)) {
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

StationPicker climateTypicalYearPicker = new StationPicker("Climate Typical Year (EPW)", 10000, 50, dataID_climateTypicalYear) {
  STATION[] getCoords () { return climateTypicalYearCoordinates; }
  String getLabel (int f) { return climateTypicalYearCoordinates[f].getClimateTypicalYearFilename(); }
  void select (int f, float lon, float lat) { selectClimateTypicalYearStation(f, lon, lat); }
};

StationPicker climateArchivePicker = new StationPicker("Climate Archive (NCA)", 25000, 50, dataID_climateArchive) {
  STATION[] getCoords () { return climateArchiveCoordinates; }
  String getLabel (int f) { return climateArchiveCoordinates[f].getCity() + ", " + climateArchiveCoordinates[f].getProvince(); }
  void select (int f, float lon, float lat) { selectClimateArchiveStation(f, lon, lat); }
};

StationPicker climateEngineeringPicker = new StationPicker("Climate Engineering (CWEEDS)", 50000, 50, dataID_climateEngineering) {
  STATION[] getCoords () { return climateEngineeringCoordinates; }
  String getLabel (int f) { return climateEngineeringCoordinates[f].getClimateEngineeringFilename(); }
  void select (int f, float lon, float lat) { selectClimateEngineeringStation(f, lon, lat); }
};

StationPicker ensembleForecastPicker = new StationPicker("Ensemble Forecast (NAEFS)", 50000, 50, dataID_ensembleForecast) {
  STATION[] getCoords () { return ensembleForecastCoordinates; }
  String getLabel (int f) { return ensembleForecastCoordinates[f].getEnsembleForecastFilename(); }
  void select (int f, float lon, float lat) { selectEnsembleForecastStation(f, lon, lat); }
};

StationPicker ensembleObservationPicker = new StationPicker("Ensemble Observation (SWOB)", 25000, 50, dataID_ensembleObservation) {
  STATION[] getCoords () { return ensembleObservationCoordinates; }
  String getLabel (int f) { return ensembleObservationCoordinates[f].getCode(); }
  void select (int f, float lon, float lat) { selectEnsembleObservationStation(f, lon, lat); }
};

// At most one of these is ever active at once, since a picker only opens
// while its own dataset is currentDataSource - but each dispatcher below
// still has to check all of them to find out which (if any) that is.
StationPicker[] ALL_PICKERS = { climateTypicalYearPicker, climateArchivePicker, climateEngineeringPicker, ensembleForecastPicker, ensembleObservationPicker };

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

// Assigns Climate Typical Year station `f` to STATION and (if Climate Typical Year is the active data
// source) reloads its data - shared by both the direct single-nearest-hit
// path and the "user picked a row from the list" path.
void selectClimateTypicalYearStation (int f, float mouse_lon, float mouse_lat) {

  if (STATION.getClimateTypicalYearFilename().equals(climateTypicalYearCoordinates[f].getClimateTypicalYearFilename())) return;

  STATION.setLatitude(mouse_lat);
  STATION.setLongitude(mouse_lon);

  STATION.setClimateTypicalYearFilename(climateTypicalYearCoordinates[f].getClimateTypicalYearFilename()); // epw filename
  STATION.setClimateTypicalYearDownload(climateTypicalYearCoordinates[f].getClimateTypicalYearDownload()); // epw filename

  println("nearest epw filename:", climateTypicalYearCoordinates[f].getClimateTypicalYearFilename());

  if (currentDataSource == dataID_climateTypicalYear) {
    STATION.setCity(climateTypicalYearCoordinates[f].getCity());
    STATION.setProvince(climateTypicalYearCoordinates[f].getProvince());
    STATION.setCountry(climateTypicalYearCoordinates[f].getCountry());

    //STATION.setLatitude(climateTypicalYearCoordinates[f].getLatitude());
    //STATION.setLongitude(climateTypicalYearCoordinates[f].getLongitude());
    STATION.setElevation(climateTypicalYearCoordinates[f].getElevation());
    STATION.setTimezoneLongitude(climateTypicalYearCoordinates[f].getTimezoneLongitude());

    UI_rollout.revise();

    update_station(0);

    download_climateTypicalYear();

    boolean keep_climateTypicalYearShouldLoad = climateTypicalYearShouldLoad;
    update_climateTypicalYear();
    climateTypicalYearShouldLoad = keep_climateTypicalYearShouldLoad;
  }
}

// Same shape as selectClimateTypicalYearStation above, for CLMREC.
void selectClimateArchiveStation (int f, float mouse_lon, float mouse_lat) {

  if (STATION.getClimateEngineeringFilename().equals(climateArchiveCoordinates[f].getClimateEngineeringFilename())) return;

  STATION.setLatitude(mouse_lat);
  STATION.setLongitude(mouse_lon);

  STATION.setClimateEngineeringFilename(climateArchiveCoordinates[f].getClimateEngineeringFilename()); // Climate Archive filename

  println("nearest Climate Archive filename:", climateArchiveCoordinates[f].getClimateEngineeringFilename());

  if (currentDataSource == dataID_climateArchive) {

    STATION.setCity(climateArchiveCoordinates[f].getCity());
    STATION.setProvince(climateArchiveCoordinates[f].getProvince());
    STATION.setCountry(climateArchiveCoordinates[f].getCountry());

    //STATION.setLatitude(climateArchiveCoordinates[f].getLatitude());
    //STATION.setLongitude(climateArchiveCoordinates[f].getLongitude());
    STATION.setElevation(climateArchiveCoordinates[f].getElevation());
    STATION.setTimezoneLongitude(climateArchiveCoordinates[f].getTimezoneLongitude());

    UI_rollout.revise();

    update_station(0);
    updateClimateArchive();
  }
}

// Same shape as selectClimateTypicalYearStation above, for CWEEDS.
void selectClimateEngineeringStation (int f, float mouse_lon, float mouse_lat) {

  if (STATION.getClimateEngineeringFilename().equals(climateEngineeringCoordinates[f].getClimateEngineeringFilename())) return;

  STATION.setLatitude(mouse_lat);
  STATION.setLongitude(mouse_lon);

  STATION.setClimateEngineeringFilename(climateEngineeringCoordinates[f].getClimateEngineeringFilename()); // Climate Engineering filename

  println("nearest Climate Engineering filename:", climateEngineeringCoordinates[f].getClimateEngineeringFilename());

  if (currentDataSource == dataID_climateEngineering) {

    STATION.setCity(climateEngineeringCoordinates[f].getCity());
    STATION.setProvince(climateEngineeringCoordinates[f].getProvince());
    STATION.setCountry(climateEngineeringCoordinates[f].getCountry());

    //STATION.setLatitude(climateEngineeringCoordinates[f].getLatitude());
    //STATION.setLongitude(climateEngineeringCoordinates[f].getLongitude());
    STATION.setElevation(climateEngineeringCoordinates[f].getElevation());
    STATION.setTimezoneLongitude(funcs.roundTo(STATION.getLongitude(), 15));

    UI_rollout.revise();

    update_station(0);
    update_climateEngineering();
  }
}

// Same shape as selectClimateTypicalYearStation above, for NAEFS. Also
// preserves the original ">100km => don't load" behavior, using the
// distance from the clicked location to the selected station (matching
// what the original inline code computed via STATION's just-updated
// position before this function existed).
void selectEnsembleForecastStation (int f, float mouse_lon, float mouse_lat) {

  if (STATION.getEnsembleForecastFilename().equals(ensembleForecastCoordinates[f].getEnsembleForecastFilename())) return;

  STATION.setLatitude(mouse_lat);
  STATION.setLongitude(mouse_lon);

  STATION.setEnsembleForecastFilename(ensembleForecastCoordinates[f].getEnsembleForecastFilename());

  println("nearest naefs filename:", ensembleForecastCoordinates[f].getEnsembleForecastFilename());

  if (currentDataSource == dataID_ensembleForecast) {
    STATION.setCity(ensembleForecastCoordinates[f].getCity());
    STATION.setProvince(ensembleForecastCoordinates[f].getProvince());
    STATION.setCountry(ensembleForecastCoordinates[f].getCountry());

    //STATION.setLatitude(ensembleForecastCoordinates[f].getLatitude());
    //STATION.setLongitude(ensembleForecastCoordinates[f].getLongitude());
    STATION.setElevation(ensembleForecastCoordinates[f].getElevation());
    STATION.setTimezoneLongitude(ensembleForecastCoordinates[f].getTimezoneLongitude());

    UI_rollout.revise();

    update_station(0);

    download_ensembleForecast(TIME.year, TIME.month, TIME.day, TIME.hour);

    boolean keep_ensembleForecastShouldLoad = ensembleForecastShouldLoad;

    float _lat = ensembleForecastCoordinates[f].getLatitude();
    float _lon = ensembleForecastCoordinates[f].getLongitude();
    if (_lon > 180) _lon -= 360; // << important!
    float dist = funcs.lon_lat_dist(_lon, _lat, mouse_lon, mouse_lat);

    // do not load data if it is outside 100Km distance
    if (dist > 100000) {
      ensembleForecastShouldLoad = false;
      STATION.setEnsembleForecastFilename("?");
    }
    update_ensembleForecast(TIME.year, TIME.month, TIME.day, TIME.hour);
    ensembleForecastShouldLoad = keep_ensembleForecastShouldLoad;
  }
}

// Same shape as selectClimateTypicalYearStation above, for SWOB. Also
// preserves the original ">100km => don't load" behavior - see the note
// on selectEnsembleForecastStation above.
void selectEnsembleObservationStation (int f, float mouse_lon, float mouse_lat) {

  if (STATION.getEnsembleObservationFilename().equals(ensembleObservationCoordinates[f].getEnsembleObservationFilename())) return;

  STATION.setLatitude(mouse_lat);
  STATION.setLongitude(mouse_lon);

  STATION.setEnsembleObservationFilename(ensembleObservationCoordinates[f].getEnsembleObservationFilename());

  println("nearest swob filename:", ensembleObservationCoordinates[f].getEnsembleObservationFilename());

  if (currentDataSource == dataID_ensembleObservation) {
    STATION.setCity(ensembleObservationCoordinates[f].getCity());
    STATION.setProvince(ensembleObservationCoordinates[f].getProvince());
    STATION.setCountry(ensembleObservationCoordinates[f].getCountry());

    //STATION.setLatitude(ensembleObservationCoordinates[f].getLatitude());
    //STATION.setLongitude(ensembleObservationCoordinates[f].getLongitude());
    STATION.setElevation(ensembleObservationCoordinates[f].getElevation());
    STATION.setTimezoneLongitude(ensembleObservationCoordinates[f].getTimezoneLongitude());

    UI_rollout.revise();

    update_station(0);

    download_ensembleObservation(TIME.year, TIME.month, TIME.day, TIME.hour);

    boolean keep_ensembleObservationShouldLoad = ensembleObservationShouldLoad;

    float _lat = ensembleObservationCoordinates[f].getLatitude();
    float _lon = ensembleObservationCoordinates[f].getLongitude();
    if (_lon > 180) _lon -= 360; // << important!
    float dist = funcs.lon_lat_dist(_lon, _lat, mouse_lon, mouse_lat);

    // do not load data if it is outside 100Km distance
    if (dist > 100000) {
      ensembleObservationShouldLoad = false;
      STATION.setEnsembleObservationFilename("?");
    }
    update_ensembleObservation(TIME.year, TIME.month, TIME.day, TIME.hour);
    ensembleObservationShouldLoad = keep_ensembleObservationShouldLoad;
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

        if (mouseButton == LEFT) {
          UI_menuBar.runSelectedItem();
        }

        UI_menuBar.deselect();

        X_clicked = -1;
        Y_clicked = -1;
      } else {

        X_clicked = mouseX;
        Y_clicked = mouseY;

        if (isInside(X_clicked, Y_clicked, 0, 0, width, pixel_A)) {
          UI_menuBar.revise();
          return; // we must return here so that typeUserCommand is not set to 0
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
        } else if (typeUserCommand == 1){
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


            pre_locationLatitude = locationLatitude;
            pre_locationLongitude = locationLongitude;

            STATION.setLatitude(mouse_lat);
            STATION.setLongitude(mouse_lon);

            if ((pre_locationLatitude != locationLatitude) ||
                (pre_locationLongitude != locationLongitude)) {

              WORLD.VIEW_id = WORLD.FindGoodViewport(locationLongitude, locationLatitude);
            }

            if (mouseButton == LEFT) {
              WORLD.zoom = max(WORLD.zoom, 5); // zoom in to confirm exactly where the click landed
            }
            // Right click keeps the current zoom level instead, for
            // comparing several rough locations across a wider area
            // without the view snapping in on every click.

            // Each picker's handleMapClick() finds nearby candidates of its
            // own dataset around (mouse_lon, mouse_lat); if there's more
            // than one AND that dataset is the active currentDataSource, it
            // shows its own pick list instead of guessing - otherwise it
            // quietly selects the single nearest one, same as every
            // dataset did before pickers existed. A click while any
            // picker's list was showing (row pick, or click-away-to-cancel)
            // is already fully handled upfront by
            // handlePickListClick() above, so no picker can
            // still be active here.
            ensembleObservationPicker.handleMapClick(mouse_lon, mouse_lat);
            ensembleForecastPicker.handleMapClick(mouse_lon, mouse_lat);
            climateEngineeringPicker.handleMapClick(mouse_lon, mouse_lat);
            climateArchivePicker.handleMapClick(mouse_lon, mouse_lat);
            climateTypicalYearPicker.handleMapClick(mouse_lon, mouse_lat);




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

            if (WIN3D.currentTool == UITASK.LookAtDirection) { // viewport:LookAtDirection

              WIN3D.look_3DViewport_towards_Direction(Image_X, Image_Y);

              view_changed();
            }
            else {

              ClickRay ray = computeClickRay(Image_X, Image_Y);
              float[] ray_start = ray.start;
              float[] ray_direction = ray.direction;

              float[] RxP = new float [8];

              if (mouseButton == RIGHT) {
                RxP = Terrain.intersect(ray_start, ray_direction);
              } else if (mouseButton == LEFT) {

                if ((WIN3D.currentTool == UITASK.Create) ||
                    (WIN3D.currentTool == UITASK.Move)) {

                   RxP = snap_Faces(allFaces.intersect(ray_start, ray_direction));

                } else {

                  if (currentObjectCategory == ObjectCategory.POLYLINE) {
                    RxP = allPolylines.intersect(ray_start, ray_direction);
                  } else if (currentObjectCategory == ObjectCategory.CAMERA) {
                    RxP = allCameras.intersect(ray_start, ray_direction);
                  } else if (currentObjectCategory == ObjectCategory.SECTION) {
                    RxP = allSections.intersect(ray_start, ray_direction);
                  } else if (currentObjectCategory == ObjectCategory.SOLID) {
                    RxP = allSolids.intersect(ray_start, ray_direction);
                  } else if (currentObjectCategory == ObjectCategory.MODEL1D) {
                    RxP = allModel1Ds.intersect(ray_start, ray_direction);
                  } else if (currentObjectCategory == ObjectCategory.MODEL2D) {
                    RxP = allModel2Ds.intersect(ray_start, ray_direction);
                  } else {
                    RxP = snap_Faces(allFaces.intersect(ray_start, ray_direction));
                  }
                }



              }


              //println(ray_start[0], ray_start[1], ray_start[2], ">>", ray_end[0], ray_end[1], ray_end[2], ">>", RxP[1], RxP[2], RxP[3], RxP[4], RxP[0]);

              if ((WIN3D.currentTool != UITASK.Create) && (WIN3D.currentTool != UITASK.Move)) { // PickSelect also if scale, rotate, modify, etc. where selected

                Select3D.selectPick(RxP);
              }

              else if (RxP[0] >= 0) {

                if (WIN3D.currentTool == UITASK.Move) { // move

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

                    // No separate model_changed() after, unlike the
                    // direct call this replaces: the "MOVE" command
                    // already calls it itself. "move" is already in
                    // bypassAllActionsFor (it's the literal motivating
                    // example in that set's own comment), so this isn't
                    // at risk of the Solid/Camera/Section-style silent
                    // collision found earlier.
                    runScriptLine("Move dx=" + d[0] + " dy=" + d[1] + " dz=" + d[2]);
                  }
                }




                if (mouseButton == LEFT) { // modify should work only with left click because the right click returns the land info, not objects info

                  if ((WIN3D.toolParameterModifier != 0) && (WIN3D.currentTool >= UITASK.Seed_Material)) { // Pick/Assign properties

                    if ((currentObjectCategory == ObjectCategory.GROUP) ||
                        (currentObjectCategory == ObjectCategory.FACE) || (currentObjectCategory == ObjectCategory.POLYLINE)) {

                      int f = int(RxP[0]);

                      pickOrAssignFaceProperty(f);

                      if (WIN3D.currentTool == UITASK.Pivot) {
                        if (WIN3D.toolParameterModifier == 1) { // Pick
                          //?????????????????????????????????????????????????
                        }
                        if (WIN3D.toolParameterModifier == 2) { // Assign
                          int OBJ_ID = allGroups.findGroupContainingFace(f);


                          float[] P = Select3D.getPivot();

                          allGroups.Pivots[OBJ_ID][0] = P[0];
                          allGroups.Pivots[OBJ_ID][1] = P[1];
                          allGroups.Pivots[OBJ_ID][2] = P[2];

                          //zzzzzzzzzzzzzzzzzzz should add other components?

                        }
                      }

                      if (WIN3D.currentTool == UITASK.Normal) { //Normal

                        if (currentObjectCategory == ObjectCategory.FACE) {

                          Select3D.faceSelection = new int [1];
                          Select3D.faceSelection[0] = f;

                          Select3D.faceDisplayvertexSelection = true;

                          flipFaceOrientationIfNeeded(f);
                        } else if (currentObjectCategory == ObjectCategory.GROUP) {
                          int OBJ_ID = allGroups.findGroupContainingFace(f);

                          for (int q = allGroups.getStart_Face(OBJ_ID); q <= allGroups.getStop_Face(OBJ_ID); q++) {
                            flipFaceOrientationIfNeeded(q);
                          }

                        }
                      }



                      if (WIN3D.currentTool == UITASK.FirstVertex) { //FirstVertex

                        if (currentObjectCategory == ObjectCategory.FACE) {

                          Select3D.faceSelection = new int [1];
                          Select3D.faceSelection[0] = f;

                          Select3D.faceDisplayvertexSelection = true;

                          rotateNodesToStartAtNearestVertex(allFaces.nodes[f], RxP);
                        } else if (currentObjectCategory == ObjectCategory.POLYLINE) {

                          Select3D.polylineSelection = new int [1];
                          Select3D.polylineSelection[0] = f;

                          Select3D.polylineDisplayvertexSelection = true;

                          rotateNodesToStartAtNearestVertex(allPolylines.nodes[f], RxP);
                        }

                      }
                    }










                    if (currentObjectCategory == ObjectCategory.MODEL2D) {

                      pickOrAssignModel2DSeedMaterial(int(RxP[0]));

                    } else if (currentObjectCategory == ObjectCategory.MODEL1D) {

                      pickOrAssignModel1DProperty(int(RxP[0]));
                    }

                    model_changed();

                  }
                }

                if (WIN3D.currentTool == UITASK.Create) { // create

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



                  //if ((currentObjectCategory == ObjectCategory.GROUP) || (currentObjectCategory == ObjectCategory.SOLID) || (currentObjectCategory == ObjectCategory.MODEL1D) || (currentObjectCategory == ObjectCategory.MODEL2D)) {
                  if (currentObjectCategory == ObjectCategory.GROUP) { // begin the group, then create its first mesh/solid

                    if (addToLastGroup == false) {

                      runScriptLine("BeginNewGroup x=" + x + " y=" + y + " z=" + z + " sx=1 sy=1 sz=1 rx=0 ry=0 rz=" + rot);
                    }



                    if (CreateObject == CREATE.SuperOBJ) {

                      int shape = classifySuperOBJShape(px, py, pz);

                      if (shape == SUPEROBJ_SHAPE_PARAMETRIC) {

                        // n=0 here specifically (not
                        // User3D.creatorParametricTypeIndex, unlike the
                        // separate CreateObject == CREATE.Parametric
                        // branch further down) - matching the direct
                        // call's own literal 0 exactly, not changed as
                        // part of this substitution.
                        runScriptLine("Parametric" + boxLikeCommandArgs(x, y, z, rx, ry, rz, rot) + " n=0");
                      } else if (shape == SUPEROBJ_SHAPE_SUPERCYLINDER) {

                        runScriptLine("Cylinder" + boxLikeCommandArgs(x, y, z, rx, ry, rz, rot) + " deg=" + User3D.creatorCylinderDegree);
                      } else if (shape == SUPEROBJ_SHAPE_BOX) {

                        runScriptLine("Box" + boxLikeCommandArgs(x, y, z, rx, ry, rz, rot));
                      } else if (shape == SUPEROBJ_SHAPE_OCTAHEDRON) {

                        runScriptLine("Octahedron" + boxLikeCommandArgs(x, y, z, rx, ry, rz, rot));
                      } else {

                        // px=pz (not px) and pz=pz (not a typo here, a
                        // pre-existing quirk in the direct call this
                        // replaces: px is never actually used, pz is
                        // passed for both the first and third
                        // SuperSphere deformation-exponent arguments) -
                        // preserved exactly rather than corrected, since
                        // that would be a behavior change beyond "use
                        // the public command instead of the internal
                        // call".
                        runScriptLine("SuperSphere" + boxLikeCommandArgs(x, y, z, rx, ry, rz, rot) +
                          " px=" + pz + " py=" + py + " pz=" + pz +
                          " deg=" + User3D.creatorSphereDegree);
                      }

                      if (User3D.creatorMeshOrSolidMode != 0) {

                        // Same sx/sy/sz-vs-rx/ry/rz parameter-name
                        // mapping as the ObjectCategory.SOLID branch
                        // further down (and its own comment there) -
                        // this local rx/ry/rz lands in the command's own
                        // sx/sy/sz, not its rx/ry/rz.
                        runScriptLine("Solid x=" + x + " y=" + y + " z=" + z +
                          " px=" + px + " py=" + py + " pz=" + pz +
                          " sx=" + rx + " sy=" + ry + " sz=" + rz +
                          " rx=0 ry=0 rz=" + rot + " v=1");
                      }
                    } else if (CreateObject == CREATE.Pyramid) {

                      // One "Pyramid" command now, instead of four Mesh3
                      // ones - same x/y/z/dx/dy/dz/r shape as Box/
                      // Octahedron/Cylinder/Parametric, so boxLikeCommandArgs()
                      // applies unchanged. Unlike the Mesh3-based version
                      // this replaces, the base now rotates with rot -
                      // see add_Pyramid_Core's own comment in Create3D.pde.
                      runScriptLine("Pyramid" + boxLikeCommandArgs(x, y, z, rx, ry, rz, rot));
                    } else if (CreateObject == CREATE.Plane) {

                      // One Mesh4 command - same reasoning as Pyramid
                      // above, no dedicated "Plane" command exists.
                      runScriptLine("Mesh4" + creatorCommandArgs() +
                        " x1=" + (x-rx) + " y1=" + (y-ry) + " z1=" + z +
                        " x2=" + (x+rx) + " y2=" + (y-ry) + " z2=" + z +
                        " x3=" + (x+rx) + " y3=" + (y+ry) + " z3=" + z +
                        " x4=" + (x-rx) + " y4=" + (y+ry) + " z4=" + z);
                    } else if (CreateObject == CREATE.Polygon) {

                      // PolygonMesh/Hyper/Extrude's commands take a
                      // single "d" (diameter, halved internally - so
                      // d=2*rx) and, for Hyper/Extrude, "h" passed
                      // through unhalved (matching the direct calls'
                      // own un-halved 2*rz exactly).
                      runScriptLine("PolygonMesh" + creatorCommandArgs() +
                        " x=" + x + " y=" + y + " z=" + z +
                        " d=" + (2 * rx) + " deg=" + User3D.creatorPolygonDegree + " r=" + rot);
                    } else if (CreateObject == CREATE.Hyper) {

                      runScriptLine("PolygonHyper" + creatorCommandArgs() +
                        " x=" + x + " y=" + y + " z=" + z +
                        " d=" + (2 * rx) + " h=" + (2 * rz) +
                        " deg=" + User3D.creatorPolygonDegree + " r=" + rot);
                    } else if (CreateObject == CREATE.Extrude) {

                      runScriptLine("PolygonExtrude" + creatorCommandArgs() +
                        " x=" + x + " y=" + y + " z=" + z +
                        " d=" + (2 * rx) + " h=" + (2 * rz) +
                        " deg=" + User3D.creatorPolygonDegree + " r=" + rot);
                    } else if (CreateObject == CREATE.House3) {

                      float h = ry;

                      runScriptLine("House3" + houseCommandArgs(x, y, z, rx, ry, rz, h, rot));
                    } else if (CreateObject == CREATE.House2) {

                      float h = ry;

                      runScriptLine("House2" + houseCommandArgs(x, y, z, rx, ry, rz, h, rot));
                    } else if (CreateObject == CREATE.House1) {

                      float h = ry;

                      if (ry > rx) h = rx;

                      runScriptLine("House1" + houseCommandArgs(x, y, z, rx, ry, rz, h, rot));
                    } else if (CreateObject == CREATE.Parametric) {

                      runScriptLine("Parametric" + boxLikeCommandArgs(x, y, z, rx, ry, rz, rot) + " n=" + User3D.creatorParametricTypeIndex);
                    }
                  } else if (currentObjectCategory == ObjectCategory.MODEL2D) { // working with model2Ds
                    if (CreateObject == CREATE.Person) {

                      // randomSeed(millis()) stays here, not moved into
                      // the command: neither "PERSON" nor "TREE2"/"TREE1"
                      // below call it themselves, and it needs to run
                      // immediately before whatever in allModel2Ds.create/
                      // allModel1Ds.create actually consumes Processing's
                      // random state, exactly as it did in the direct call.
                      randomSeed(millis());
                      runScriptLine("Person m=" + User3D.creatorPersonTypeIndex + " x=" + x + " y=" + y + " z=" + z);
                    }

                    if (CreateObject == CREATE.Plant) {
                      // n's own computation (not a straight pass-through
                      // of User3D.creatorPlantTypeIndex) stays here too -
                      // it's specific to this click-to-create workflow,
                      // not something "TREE2" itself would know how to
                      // derive.
                      int n = 0;
                      if (User3D.creatorPlantTypeIndex > 0) n = User3D.creatorPlantTypeIndex + allModel2Ds.peopleFileCount;

                      randomSeed(millis());
                      runScriptLine("Tree2 m=" + n + " x=" + x + " y=" + y + " z=" + z + " h=" + (2 * rz));
                    }
                  } else if (currentObjectCategory == ObjectCategory.MODEL1D) { // working with model1Ds
                    if (CreateObject == CREATE.Model1Ds) {

                      // floor(random(360)) is evaluated once, here,
                      // before building the command string - keeping it
                      // a single fresh random value per click, same as
                      // the direct call, rather than something that
                      // could evaluate differently (or more than once)
                      // depending on how the argument string gets built.
                      randomSeed(millis());
                      int r = floor(random(360));
                      runScriptLine("Tree1 m=" + User3D.creatorModel1DTypeIndex +
                        " seed=" + User3D.creatorModel1DSeed +
                        " degree=" + User3D.creatorModel1DDegreeMax +
                        " x=" + x + " y=" + y + " z=" + z +
                        " h=" + (2 * rz) + " r=" + r +
                        " tilt=" + User3D.creatorModel1DBranchTilt +
                        " twist=" + User3D.creatorModel1DBranchTwist +
                        " ratio=" + User3D.creatorModel1DBranchRatio +
                        " base=" + User3D.creatorModel1DTreeBase +
                        " trunk=" + User3D.creatorModel1DTrunkSize +
                        " leaf=" + User3D.creatorModel1DLeafSize);
                    }
                  } else if (currentObjectCategory == ObjectCategory.VERTEX) { // working with vertices
                    if (CreateObject == CREATE.Vertex) {
                      allPoints.create(x, y, z);

                    }
                  } else if (currentObjectCategory == ObjectCategory.FACE) { // working with faces
                    if (CreateObject == CREATE.Face) {
                      allFaces.add_VertexToLastFace(x, y, z);

                      Select3D.faceSelection = new int [1];
                      Select3D.faceSelection[0] = allFaces.nodes.length - 1;

                      Select3D.calculate_BoundingBox();
                    }
                  } else if (currentObjectCategory == ObjectCategory.POLYLINE) { // working with polylines
                    if (CreateObject == CREATE.Polyline) {
                      allPolylines.add_VertexToLastPolyline(x, y, z);

                      Select3D.polylineSelection = new int [1];
                      Select3D.polylineSelection[0] = allPolylines.nodes.length - 1;

                      Select3D.calculate_BoundingBox();
                    }
                  } else if (currentObjectCategory == ObjectCategory.SOLID) { // working with solids
                    if (CreateObject == CREATE.Solid) {
                      // The "SOLID" command's own sx/sy/sz named
                      // parameters are where this rx/ry/rz (this
                      // branch's local half-widths from
                      // computeCreateParams, same as every other shape
                      // here) land positionally in allSolids.create(...)
                      // - the command's own "rx"/"ry"/"rz" names are its
                      // tx/ty/tz (rotation) parameters instead, where the
                      // direct call's literal 0, 0, rot go. Traced
                      // against Solids.pde's own create(...) signature
                      // directly, not assumed from either side's naming.
                      runScriptLine("Solid x=" + x + " y=" + y + " z=" + z +
                        " px=" + px + " py=" + py + " pz=" + pz +
                        " sx=" + rx + " sy=" + ry + " sz=" + rz +
                        " rx=0 ry=0 rz=" + rot + " v=1");
                    }
                  } else if (currentObjectCategory == ObjectCategory.CAMERA) { // working with cameras
                    if (CreateObject == CREATE.Camera) {

                      CameraParams camParams = computeCameraParamsAtPoint(RxP[1], RxP[2], RxP[3]);

                      runScriptLine("Camera px=" + camParams.pX + " py=" + camParams.pY + " pz=" + camParams.pZ +
                        " pt=" + camParams.pT + " rx=" + camParams.rX + " ry=" + camParams.rY + " rz=" + camParams.rZ +
                        " rt=" + camParams.rT + " a=" + camParams.zoom + " t=" + camParams.type);
                    }
                  } else if (currentObjectCategory == ObjectCategory.SECTION) { // working with sections
                    if (CreateObject == CREATE.Section) {

                      SectionParams sp = computeSectionParams(int(RxP[0]), RxP);

                      if (sp.createNew) {

                        // The "SECTION" command's own validity guard
                        // (t>0 && i>0 && j>0 && u>0 && v>0) is slightly
                        // different from this branch's own sp.createNew
                        // check - in the ordinary case where
                        // computeSectionParams() produces sane values
                        // these agree, but it's worth noting this isn't
                        // byte-for-byte the same condition. Everything
                        // after the create call (the allSolidImpacts/
                        // allSolarImpacts bookkeeping below) is specific
                        // to this mouse-click workflow, not part of the
                        // command itself, so it stays here unchanged.
                        runScriptLine("Section x=" + sp.X + " y=" + sp.Y + " z=" + sp.Z +
                          " r=" + sp.R + " u=" + sp.U + " v=" + sp.V +
                          " t=" + sp.Type + " i=" + sp.RES1 + " j=" + sp.RES2);

                        selectNewlyCreated(keep_number_of_allSections, allSections.num,
                          () -> Select3D.deselect_Sections(),
                          (o) -> { Select3D.sectionSelection = concat(Select3D.sectionSelection, new int[] {o}); }
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
                    (o) -> { Select3D.solidSelection = concat(Select3D.solidSelection, new int[] {o}); }
                    );

                  selectNewlyCreated(keep_number_of_allCameras, allCameras.num,
                    () -> Select3D.deselect_Cameras(),
                    (o) -> { Select3D.cameraSelection = concat(Select3D.cameraSelection, new int[] {o}); }
                    );

                  selectNewlyCreated(keep_number_of_allGroups, allGroups.num,
                    () -> Select3D.deselect_Groups(),
                    (o) -> { Select3D.groupSelection = concat(Select3D.groupSelection, new int[] {o}); }
                    );

                  selectNewlyCreated(keep_number_of_allModel2Ds, allModel2Ds.num,
                    () -> Select3D.deselect_Model2Ds(),
                    (o) -> { Select3D.model2DSelection = concat(Select3D.model2DSelection, new int[] {o}); }
                    );

                  selectNewlyCreated(keep_number_of_allModel1Ds, allModel1Ds.num,
                    () -> Select3D.deselect_Model1Ds(),
                    (o) -> { Select3D.model1DSelection = concat(Select3D.model1DSelection, new int[] {o}); }
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
