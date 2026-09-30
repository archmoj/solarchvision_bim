void UI_setTo_Create_Nothing () {

  CreateObject = CREATE.Nothing;

  WIN3D.currentTool = UITASK.Create;

  UI_rollout.revise();
}


void UI_setTo_Create_allModel1Ds () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.Model1Ds;
  switch_category(ObjectCategory.MODEL1D);
}


void UI_setTo_Create_Tree () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.Plant;
  switch_category(ObjectCategory.MODEL2D);
}

void UI_setTo_Create_Person () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.Person;
  switch_category(ObjectCategory.MODEL2D);
}

void UI_setTo_Create_Vertex () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.Vertex;
  switch_category(ObjectCategory.VERTEX);
}

void UI_setTo_Create_Face () {
  UI_setTo_Create_Nothing();

  current_Material = User3D.defaultMaterial;
  current_Tessellation = User3D.defaultTessellation;
  current_Layer = User3D.defaultLayer;
  current_Visibility = User3D.defaultVisibility;
  current_Weight = User3D.defaultWeight;
  current_Closed = User3D.defaultClosed;

  allFaces.beginNewFace();

  CreateObject = CREATE.Face;
  switch_category(ObjectCategory.FACE);
}

void UI_setTo_Create_Polyline () {
  UI_setTo_Create_Nothing();

  current_Material = User3D.defaultMaterial;
  current_Tessellation = User3D.defaultTessellation;
  current_Layer = User3D.defaultLayer;
  current_Visibility = User3D.defaultVisibility;
  current_Weight = User3D.defaultWeight;
  current_Closed = User3D.defaultClosed;

  allPolylines.beginNewPolyline();

  CreateObject = CREATE.Polyline;
  switch_category(ObjectCategory.POLYLINE);
}

void UI_setTo_Create_Solid () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.Solid;
  switch_category(ObjectCategory.SOLID);
}

void UI_setTo_Create_Section () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.Section;
  switch_category(ObjectCategory.SECTION);
}


void UI_setTo_Create_Camera () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.Camera;
  switch_category(ObjectCategory.CAMERA);
}






void UI_setTo_Create_Parametric (int n) {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.Parametric;
  User3D.creatorParametricTypeIndex = n;

  switch_category(ObjectCategory.GROUP);
}

void UI_setTo_Create_Pyramid () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.Pyramid;
  switch_category(ObjectCategory.GROUP);
}

void UI_setTo_Create_Plane () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.Plane;
  switch_category(ObjectCategory.GROUP);
}

void UI_setTo_Create_Polygon () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.Polygon;
  switch_category(ObjectCategory.GROUP);
}

void UI_setTo_Create_Extrude () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.Extrude;
  switch_category(ObjectCategory.GROUP);
}

void UI_setTo_Create_Hyper () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.Hyper;
  switch_category(ObjectCategory.GROUP);
}

void UI_setTo_Create_House3 () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.House3;
  switch_category(ObjectCategory.GROUP);
}

void UI_setTo_Create_House2 () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.House2;
  switch_category(ObjectCategory.GROUP);
}

void UI_setTo_Create_House1 () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.House1;
  switch_category(ObjectCategory.GROUP);
}

void UI_setTo_Create_Box () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.SuperOBJ;

  User3D.creatorSuperellipsoidPowerX = CubePower;
  User3D.creatorSuperellipsoidPowerY = CubePower;
  User3D.creatorSuperellipsoidPowerZ = CubePower;

  switch_category(ObjectCategory.GROUP);
}


void UI_setTo_Create_Icosahedron () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.SuperOBJ;

  User3D.creatorSuperellipsoidPowerX = 1;
  User3D.creatorSuperellipsoidPowerY = 1;
  User3D.creatorSuperellipsoidPowerZ = 1;

  switch_category(ObjectCategory.GROUP);
}

void UI_setTo_Create_Octahedron () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.SuperOBJ;

  User3D.creatorSuperellipsoidPowerX = 1;
  User3D.creatorSuperellipsoidPowerY = 1;
  User3D.creatorSuperellipsoidPowerZ = 1;

  switch_category(ObjectCategory.GROUP);
}

void UI_setTo_Create_Sphere () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.SuperOBJ;

  User3D.creatorSuperellipsoidPowerX = 2;
  User3D.creatorSuperellipsoidPowerY = 2;
  User3D.creatorSuperellipsoidPowerZ = 2;

  switch_category(ObjectCategory.GROUP);
}

void UI_setTo_Create_Cylinder () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.SuperOBJ;

  User3D.creatorSuperellipsoidPowerX = 2;
  User3D.creatorSuperellipsoidPowerY = 2;
  User3D.creatorSuperellipsoidPowerZ = CubePower;

  switch_category(ObjectCategory.GROUP);
}

void UI_setTo_Create_Cushion () {
  UI_setTo_Create_Nothing();

  CreateObject = CREATE.SuperOBJ;

  User3D.creatorSuperellipsoidPowerX = CubePower;
  User3D.creatorSuperellipsoidPowerY = CubePower;
  User3D.creatorSuperellipsoidPowerZ = 2;

  switch_category(ObjectCategory.GROUP);
}




void UI_setTo_Modify_Move (int n) {
  WIN3D.currentTool = UITASK.Move;

  Select3D.positionVectorIndex = n;

  UI_rollout.revise();
}

void UI_setTo_Modify_Scale (int n) {
  WIN3D.currentTool = UITASK.Scale;

  Select3D.scaleVectorIndex = n;

  UI_rollout.revise();
}


void UI_setTo_Modify_Rotate (int n) {
  WIN3D.currentTool = UITASK.Rotate;

  Select3D.rotationVectorIndex = n;

  UI_rollout.revise();
}

void UI_setTo_Modify_Seed (int n) {
  WIN3D.currentTool = UITASK.Seed_Material;
  WIN3D.toolParameterModifier = n; // 0:change selection 1:pick from 2:assign to

  UI_rollout.revise();
}

void UI_setTo_Modify_Tessellation (int n) {
  WIN3D.currentTool = UITASK.Tessellation;
  WIN3D.toolParameterModifier = n; // 0:change selection 1:pick from 2:assign to

  UI_rollout.revise();
}

void UI_setTo_Modify_Layer (int n) {
  WIN3D.currentTool = UITASK.Layer;
  WIN3D.toolParameterModifier = n; // 0:change selection 1:pick from 2:assign to

  UI_rollout.revise();
}

void UI_setTo_Modify_Visibility (int n) {
  WIN3D.currentTool = UITASK.Visibility;
  WIN3D.toolParameterModifier = n; // 0:change selection 1:pick from 2:assign to

  UI_rollout.revise();
}

void UI_setTo_Modify_Weight (int n) {
  WIN3D.currentTool = UITASK.Weight;
  WIN3D.toolParameterModifier = n; // 0:change selection 1:pick from 2:assign to

  UI_rollout.revise();
}

void UI_setTo_Modify_DegreeMax (int n) {
  WIN3D.currentTool = UITASK.DegreeMax;
  WIN3D.toolParameterModifier = n; // 0:change selection 1:pick from 2:assign to

  UI_rollout.revise();
}

void UI_setTo_Modify_BranchTilt (int n) {
  WIN3D.currentTool = UITASK.BranchTilt;
  WIN3D.toolParameterModifier = n; // 0:change selection 1:pick from 2:assign to

  UI_rollout.revise();
}

void UI_setTo_Modify_BranchTwist (int n) {
  WIN3D.currentTool = UITASK.BranchTwist;
  WIN3D.toolParameterModifier = n; // 0:change selection 1:pick from 2:assign to

  UI_rollout.revise();
}

void UI_setTo_Modify_BranchRatio (int n) {
  WIN3D.currentTool = UITASK.BranchRatio;
  WIN3D.toolParameterModifier = n; // 0:change selection 1:pick from 2:assign to

  UI_rollout.revise();
}

void UI_setTo_Modify_TreeBase (int n) {
  WIN3D.currentTool = UITASK.TreeBase;
  WIN3D.toolParameterModifier = n; // 0:change selection 1:pick from 2:assign to

  UI_rollout.revise();
}


void UI_setTo_Modify_TrunkSize (int n) {
  WIN3D.currentTool = UITASK.TrunkSize;
  WIN3D.toolParameterModifier = n; // 0:change selection 1:pick from 2:assign to

  UI_rollout.revise();
}

void UI_setTo_Modify_LeafSize (int n) {
  WIN3D.currentTool = UITASK.LeafSize;
  WIN3D.toolParameterModifier = n; // 0:change selection 1:pick from 2:assign to

  UI_rollout.revise();
}

void UI_setTo_Modify_Model1DsProps (int n) {
  WIN3D.currentTool = UITASK.Model1DsProps;
  WIN3D.toolParameterModifier = n; // 0:change selection 1:pick from 2:assign to

  UI_rollout.revise();
}

void UI_setTo_Modify_Pivot (int n) {
  WIN3D.currentTool = UITASK.Pivot;
  WIN3D.toolParameterModifier = n; // 0:change selection 1:pick from 2:assign to

  UI_rollout.revise();
}

void UI_setTo_Modify_Normal (int n) {
  WIN3D.currentTool = UITASK.Normal;
  WIN3D.toolParameterModifier = n; // 1:flip normal, 2:set out from pivot, 3:set in from pivot

  UI_rollout.revise();
}

void UI_setTo_Modify_FirstVertex (int n) {
  WIN3D.currentTool = UITASK.FirstVertex;
  WIN3D.toolParameterModifier = n; // 1:default

  UI_rollout.revise();
}




void UI_setTo_Modify_Drop (int n) {
  WIN3D.currentTool = UITASK.Drop;

  WIN3D.toolParameterModifier = n; // 0:LandSurface± 1:ModelSurface- 2:ModelSurface+

  UI_rollout.revise();
}


void UI_setTo_Modify_GetLength (int n) {
  WIN3D.currentTool = UITASK.GetLength;

  WIN3D.toolParameterModifier = n; // 0:x 1:y 2:z 3:xyz 4:xy 5:angle(on XY plane)

  UI_rollout.revise();
}

void UI_setTo_Modify_Power (int n) {

  if (n == 0) WIN3D.currentTool = UITASK.PowerX; // x
  if (n == 1) WIN3D.currentTool = UITASK.PowerY; // y
  if (n == 2) WIN3D.currentTool = UITASK.PowerZ; // z
  if (n == 3) WIN3D.currentTool = UITASK.PowerAll; // xyz

  WIN3D.toolParameterModifier = 0; // 0:change

  UI_rollout.revise();
}










void UI_setTo_View_ProjectionType (int n) {
  WIN3D.projectionTypeIndex = n;

  UI_rollout.revise();

  view_changed();
}

void UI_setTo_View_PickSelect (int n) {

  WIN3D.currentTool = UITASK.PickSelect;

  addNewSelectionToPreviousSelection = 0;

  if (n == 1) {
    addNewSelectionToPreviousSelection = 1;
  }

  if (n == 2) {
    addNewSelectionToPreviousSelection = -1;
  }

  UI_rollout.revise();
}

void UI_setTo_View_WindowSelect (int n) {
  WIN3D.currentTool = UITASK.RectSelect;

  addNewSelectionToPreviousSelection = 0;

  if (n == 1) {
    addNewSelectionToPreviousSelection = 1;
  }

  if (n == 2) {
    addNewSelectionToPreviousSelection = -1;
  }

  UI_rollout.revise();
}

void UI_setTo_View_PivotX (int n) {

  Select3D.alignX = n;

  UI_rollout.revise();

  view_changed();
}

void UI_setTo_View_PivotY (int n) {

  Select3D.alignY = n;

  UI_rollout.revise();

  view_changed();
}

void UI_setTo_View_PivotZ (int n) {

  Select3D.alignZ = n;

  UI_rollout.revise();

  view_changed();
}


void UI_setTo_View_Truck (int n) {

  if (n == 0) {
    WIN3D.currentTool = UITASK.zoom_Orbit_Pan;
  }

  if (n == 1) {
    WIN3D.currentTool = UITASK.Truck_Orbit;
    WIN3D.toolParameterModifier = 0;
    WIN3D.targetAxisIndex = 0;
  }

  if (n == 2) {
    WIN3D.currentTool = UITASK.Truck_Orbit;
    WIN3D.toolParameterModifier = 0;
    WIN3D.targetAxisIndex = 1;
  }

  UI_rollout.revise();
}


void UI_setTo_View_DistMouseXY (int n) {

  if (n == 0) {
    WIN3D.currentTool = UITASK.DistMouseXY_TargetRollXY_TargetRollZ;
  }

  UI_rollout.revise();
}



void UI_setTo_View_CameraDistance (int n) {

  if (n == 0) {
    WIN3D.currentTool = UITASK.CameraDistance_TargetRollXY_TargetRollZ;
  }

  UI_rollout.revise();
}



void UI_setTo_View_CameraRoll (int n) {

  if (n == 0) {
    WIN3D.currentTool = UITASK.CameraRoll_Pan;
  }

  if (n == 1) {
    WIN3D.currentTool = UITASK.CameraRollXY_CameraRollZ;
    WIN3D.toolParameterModifier = 0;
    WIN3D.targetAxisIndex = 0;
  }

  if (n == 2) {
    WIN3D.currentTool = UITASK.CameraRollXY_CameraRollZ;
    WIN3D.toolParameterModifier = 0;
    WIN3D.targetAxisIndex = 1;
  }

  UI_rollout.revise();
}



void UI_setTo_View_TargetRoll (int n) {

  if (n == 0) {
    WIN3D.currentTool = UITASK.TargetRoll_Pan;
  }

  if (n == 1) {
    WIN3D.currentTool = UITASK.TargetRollXY_TargetRollZ;
    WIN3D.toolParameterModifier = 0;
    WIN3D.targetAxisIndex = 0;
  }

  if (n == 2) {
    WIN3D.currentTool = UITASK.TargetRollXY_TargetRollZ;
    WIN3D.toolParameterModifier = 0;
    WIN3D.targetAxisIndex = 1;
  }

  UI_rollout.revise();
}


void UI_setTo_View_Orbit (int n) {

  if (n == 0) {
    WIN3D.currentTool = UITASK.zoom_Orbit_Pan;
  }

  if (n == 1) {
    WIN3D.currentTool = UITASK.Truck_Orbit;
    WIN3D.toolParameterModifier = 1;
    WIN3D.targetAxisIndex = 0;
  }

  if (n == 2) {
    WIN3D.currentTool = UITASK.Truck_Orbit;
    WIN3D.toolParameterModifier = 1;
    WIN3D.targetAxisIndex = 1;
  }

  UI_rollout.revise();
}



void UI_setTo_View_LandOrbit (int n) {

  WIN3D.currentTool = UITASK.LandOrbit_Pan_TargetRollZ;

  UI_rollout.revise();
}



void UI_setTo_View_LookAtSelection (int n) {

  WIN3D.look_3DViewport_towards_Selection();

  { // automatically set another choice of ineterest
    UI_setTo_View_CameraDistance(0);
    UI_toolBar.revise();
  }

  UI_rollout.revise();

  view_changed();
}


void UI_setTo_View_LookAtDirection (int n) {

  WIN3D.currentTool = UITASK.LookAtDirection;

  UI_rollout.revise();
}


void UI_setTo_View_LookAtOrigin (int n) {

  WIN3D.positionX = 0;
  WIN3D.positionY = 0;
  WIN3D.positionZ = 0;

  {
    // automatically set another choice of ineterest

    UI_setTo_View_Truck(0);
    UI_toolBar.revise();
  }

  UI_rollout.revise();

  view_changed();
}


void UI_setTo_View_Pan (int n) {

  if (n == 0) {
    WIN3D.currentTool = UITASK.Pan_TargetRoll;
  }

  if (n == 1) {
    WIN3D.currentTool = UITASK.PanX_TargetRoll;
  }

  if (n == 2) {
    WIN3D.currentTool = UITASK.PanY_TargetRoll;
  }


  UI_rollout.revise();
}

void UI_setTo_View_ZOOM (int n) {
  WIN3D.currentTool = UITASK.Pan_Height;

  UI_rollout.revise();

  if (n == 1) {
    WIN3D.zoom = 60;

    view_changed();
  }
}

void UI_setTo_View_3DModelSize () {

  WIN3D.currentTool = UITASK.ModelSize_Pan_TargetRoll;

  UI_rollout.revise();

  view_changed();
}

void UI_setTo_View_SkydomeSize () {

  WIN3D.currentTool = UITASK.SkydomeSize;

  UI_rollout.revise();

  view_changed();
}

void UI_setTo_View_AllModelSize () {

  WIN3D.currentTool = UITASK.AllModelSize;

  UI_rollout.revise();

  view_changed();
}

boolean updateBars = false;

void UI_setTo_Viewport (int n) {

  updateBars = true;

  viewLayout = n;
  update_frame_layout();

  UI_rollout.revise();
}

void UI_setTo_View_3DViewPoint (int n) {

  WIN3D.currentCameraIndex = 0;

  WIN3D.apply_currentCameraIndex();

  if (n == 0) {
    WIN3D.rotateZ_3DViewport_around_Selection(0 - WIN3D.rotationX);
    WIN3D.rotateXY_3DViewport_around_Selection(0 - WIN3D.rotationZ);
  }

  if (n == 1) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotationX);
    WIN3D.rotateXY_3DViewport_around_Selection(0 - WIN3D.rotationZ);
  }

  if (n == 2) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotationX);
    WIN3D.rotateXY_3DViewport_around_Selection(-90 - WIN3D.rotationZ);
  }

  if (n == 3) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotationX);
    WIN3D.rotateXY_3DViewport_around_Selection(180 - WIN3D.rotationZ);
  }

  if (n == 4) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotationX);
    WIN3D.rotateXY_3DViewport_around_Selection(90 - WIN3D.rotationZ);
  }

  if (n == 5) {
    WIN3D.rotateZ_3DViewport_around_Selection(180 - WIN3D.rotationX);
    WIN3D.rotateXY_3DViewport_around_Selection(0 - WIN3D.rotationZ);
  }

  if (n == 6) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotationX);
    WIN3D.rotateXY_3DViewport_around_Selection(-45 - WIN3D.rotationZ);
  }

  if (n == 7) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotationX);
    WIN3D.rotateXY_3DViewport_around_Selection(45 - WIN3D.rotationZ);
  }

  if (n == 8) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotationX);
    WIN3D.rotateXY_3DViewport_around_Selection(135 - WIN3D.rotationZ);
  }

  if (n == 9) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotationX);
    WIN3D.rotateXY_3DViewport_around_Selection(-135 - WIN3D.rotationZ);
  }


  UI_toolBar.revise();

  UI_rollout.revise();

  view_changed();
}
