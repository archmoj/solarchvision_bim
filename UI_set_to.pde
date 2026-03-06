void UI_set_to_Create_Nothing () {

  CreateObject = CREATE.Nothing;

  WIN3D.UI_CurrentTask = UITASK.Create;

  ROLLOUT.revise();
}


void UI_set_to_Create_allModel1Ds () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Model1Ds;
  SOLARCHVISION_switch_category(ObjectCategory.MODEL1D);
}


void UI_set_to_Create_Tree () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Plant;
  SOLARCHVISION_switch_category(ObjectCategory.MODEL2D);
}

void UI_set_to_Create_Person () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Person;
  SOLARCHVISION_switch_category(ObjectCategory.MODEL2D);
}

void UI_set_to_Create_Vertex () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Vertex;
  SOLARCHVISION_switch_category(ObjectCategory.VERTEX);
}

void UI_set_to_Create_Face () {
  UI_set_to_Create_Nothing();

  current_Material = User3D.default_Material;
  current_Tessellation = User3D.default_Tessellation;
  current_Layer = User3D.default_Layer;
  current_Visibility = User3D.default_Visibility;
  current_Weight = User3D.default_Weight;
  current_Closed = User3D.default_Closed;

  allFaces.beginNewFace();

  CreateObject = CREATE.Face;
  SOLARCHVISION_switch_category(ObjectCategory.FACE);
}

void UI_set_to_Create_Polyline () {
  UI_set_to_Create_Nothing();

  current_Material = User3D.default_Material;
  current_Tessellation = User3D.default_Tessellation;
  current_Layer = User3D.default_Layer;
  current_Visibility = User3D.default_Visibility;
  current_Weight = User3D.default_Weight;
  current_Closed = User3D.default_Closed;

  allPolylines.beginNewPolyline();

  CreateObject = CREATE.Polyline;
  SOLARCHVISION_switch_category(ObjectCategory.POLYLINE);
}

void UI_set_to_Create_Solid () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Solid;
  SOLARCHVISION_switch_category(ObjectCategory.SOLID);
}

void UI_set_to_Create_Section () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Section;
  SOLARCHVISION_switch_category(ObjectCategory.SECTION);
}


void UI_set_to_Create_Camera () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Camera;
  SOLARCHVISION_switch_category(ObjectCategory.CAMERA);
}






void UI_set_to_Create_Parametric (int n) {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Parametric;
  User3D.create_Parametric_Type = n;

  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Pyramid () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Pyramid;
  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Plane () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Plane;
  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Polygon () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Polygon;
  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Extrude () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Extrude;
  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Hyper () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Hyper;
  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_House3 () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.House3;
  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_House2 () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.House2;
  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_House1 () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.House1;
  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Box () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.SuperOBJ;

  User3D.create_powX = CubePower;
  User3D.create_powY = CubePower;
  User3D.create_powZ = CubePower;

  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}


void UI_set_to_Create_Icosahedron () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.SuperOBJ;

  User3D.create_powX = 1;
  User3D.create_powY = 1;
  User3D.create_powZ = 1;

  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Octahedron () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.SuperOBJ;

  User3D.create_powX = 1;
  User3D.create_powY = 1;
  User3D.create_powZ = 1;

  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Sphere () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.SuperOBJ;

  User3D.create_powX = 2;
  User3D.create_powY = 2;
  User3D.create_powZ = 2;

  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Cylinder () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.SuperOBJ;

  User3D.create_powX = 2;
  User3D.create_powY = 2;
  User3D.create_powZ = CubePower;

  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Cushion () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.SuperOBJ;

  User3D.create_powX = CubePower;
  User3D.create_powY = CubePower;
  User3D.create_powZ = 2;

  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}




void UI_set_to_Modify_Move (int n) {
  WIN3D.UI_CurrentTask = UITASK.Move;

  Select3D.posVector = n;

  ROLLOUT.revise();
}

void UI_set_to_Modify_Scale (int n) {
  WIN3D.UI_CurrentTask = UITASK.Scale;

  Select3D.scaleVector = n;

  ROLLOUT.revise();
}


void UI_set_to_Modify_Rotate (int n) {
  WIN3D.UI_CurrentTask = UITASK.Rotate;

  Select3D.rotVector = n;

  ROLLOUT.revise();
}

void UI_set_to_Modify_Seed (int n) {
  WIN3D.UI_CurrentTask = UITASK.Seed_Material;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_Tessellation (int n) {
  WIN3D.UI_CurrentTask = UITASK.Tessellation;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_Layer (int n) {
  WIN3D.UI_CurrentTask = UITASK.Layer;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_Visibility (int n) {
  WIN3D.UI_CurrentTask = UITASK.Visibility;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_Weight (int n) {
  WIN3D.UI_CurrentTask = UITASK.Weight;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_DegreeMax (int n) {
  WIN3D.UI_CurrentTask = UITASK.DegreeMax;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_BranchTilt (int n) {
  WIN3D.UI_CurrentTask = UITASK.BranchTilt;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_BranchTwist (int n) {
  WIN3D.UI_CurrentTask = UITASK.BranchTwist;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_BranchRatio (int n) {
  WIN3D.UI_CurrentTask = UITASK.BranchRatio;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_TreeBase (int n) {
  WIN3D.UI_CurrentTask = UITASK.TreeBase;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}


void UI_set_to_Modify_TrunkSize (int n) {
  WIN3D.UI_CurrentTask = UITASK.TrunkSize;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_LeafSize (int n) {
  WIN3D.UI_CurrentTask = UITASK.LeafSize;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_Model1DsProps (int n) {
  WIN3D.UI_CurrentTask = UITASK.Model1DsProps;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_Pivot (int n) {
  WIN3D.UI_CurrentTask = UITASK.Pivot;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_Normal (int n) {
  WIN3D.UI_CurrentTask = UITASK.Normal;
  WIN3D.UI_TaskModifyParameter = n; // 1:flip normal, 2:set out from pivot, 3:set in from pivot

  ROLLOUT.revise();
}

void UI_set_to_Modify_FirstVertex (int n) {
  WIN3D.UI_CurrentTask = UITASK.FirstVertex;
  WIN3D.UI_TaskModifyParameter = n; // 1:default

  ROLLOUT.revise();
}




void UI_set_to_Modify_Drop (int n) {
  WIN3D.UI_CurrentTask = UITASK.Drop;

  WIN3D.UI_TaskModifyParameter = n; // 0:LandSurface± 1:ModelSurface- 2:ModelSurface+

  ROLLOUT.revise();
}


void UI_set_to_Modify_GetLength (int n) {
  WIN3D.UI_CurrentTask = UITASK.GetLength;

  WIN3D.UI_TaskModifyParameter = n; // 0:x 1:y 2:z 3:xyz 4:xy 5:angle(on XY plane)

  ROLLOUT.revise();
}

void UI_set_to_Modify_Power (int n) {

  if (n == 0) WIN3D.UI_CurrentTask = UITASK.PowerX; // x
  if (n == 1) WIN3D.UI_CurrentTask = UITASK.PowerY; // y
  if (n == 2) WIN3D.UI_CurrentTask = UITASK.PowerZ; // z
  if (n == 3) WIN3D.UI_CurrentTask = UITASK.PowerAll; // xyz

  WIN3D.UI_TaskModifyParameter = 0; // 0:change

  ROLLOUT.revise();
}










void UI_set_to_View_ProjectionType (int n) {
  WIN3D.ViewType = n;

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}

void UI_set_to_View_PickSelect (int n) {

  WIN3D.UI_CurrentTask = UITASK.PickSelect;

  addNewSelectionToPreviousSelection = 0;

  if (n == 1) {
    addNewSelectionToPreviousSelection = 1;
  }

  if (n == 2) {
    addNewSelectionToPreviousSelection = -1;
  }

  ROLLOUT.revise();
}

void UI_set_to_View_WindowSelect (int n) {
  WIN3D.UI_CurrentTask = UITASK.RectSelect;

  addNewSelectionToPreviousSelection = 0;

  if (n == 1) {
    addNewSelectionToPreviousSelection = 1;
  }

  if (n == 2) {
    addNewSelectionToPreviousSelection = -1;
  }

  ROLLOUT.revise();
}

void UI_set_to_View_PivotX (int n) {

  Select3D.alignX = n;

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}

void UI_set_to_View_PivotY (int n) {

  Select3D.alignY = n;

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}

void UI_set_to_View_PivotZ (int n) {

  Select3D.alignZ = n;

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}


void UI_set_to_View_Truck (int n) {

  if (n == 0) {
    WIN3D.UI_CurrentTask = UITASK.Zoom_Orbit_Pan;
  }

  if (n == 1) {
    WIN3D.UI_CurrentTask = UITASK.Truck_Orbit;
    WIN3D.UI_TaskModifyParameter = 0;
    WIN3D.UI_OptionXorY = 0;
  }

  if (n == 2) {
    WIN3D.UI_CurrentTask = UITASK.Truck_Orbit;
    WIN3D.UI_TaskModifyParameter = 0;
    WIN3D.UI_OptionXorY = 1;
  }

  ROLLOUT.revise();
}


void UI_set_to_View_DistMouseXY (int n) {

  if (n == 0) {
    WIN3D.UI_CurrentTask = UITASK.DistMouseXY_TargetRollXY_TargetRollZ;
  }

  ROLLOUT.revise();
}



void UI_set_to_View_CameraDistance (int n) {

  if (n == 0) {
    WIN3D.UI_CurrentTask = UITASK.CameraDistance_TargetRollXY_TargetRollZ;
  }

  ROLLOUT.revise();
}



void UI_set_to_View_CameraRoll (int n) {

  if (n == 0) {
    WIN3D.UI_CurrentTask = UITASK.CameraRoll_Pan;
  }

  if (n == 1) {
    WIN3D.UI_CurrentTask = UITASK.CameraRollXY_CameraRollZ;
    WIN3D.UI_TaskModifyParameter = 0;
    WIN3D.UI_OptionXorY = 0;
  }

  if (n == 2) {
    WIN3D.UI_CurrentTask = UITASK.CameraRollXY_CameraRollZ;
    WIN3D.UI_TaskModifyParameter = 0;
    WIN3D.UI_OptionXorY = 1;
  }

  ROLLOUT.revise();
}



void UI_set_to_View_TargetRoll (int n) {

  if (n == 0) {
    WIN3D.UI_CurrentTask = UITASK.TargetRoll_Pan;
  }

  if (n == 1) {
    WIN3D.UI_CurrentTask = UITASK.TargetRollXY_TargetRollZ;
    WIN3D.UI_TaskModifyParameter = 0;
    WIN3D.UI_OptionXorY = 0;
  }

  if (n == 2) {
    WIN3D.UI_CurrentTask = UITASK.TargetRollXY_TargetRollZ;
    WIN3D.UI_TaskModifyParameter = 0;
    WIN3D.UI_OptionXorY = 1;
  }

  ROLLOUT.revise();
}


void UI_set_to_View_Orbit (int n) {

  if (n == 0) {
    WIN3D.UI_CurrentTask = UITASK.Zoom_Orbit_Pan;
  }

  if (n == 1) {
    WIN3D.UI_CurrentTask = UITASK.Truck_Orbit;
    WIN3D.UI_TaskModifyParameter = 1;
    WIN3D.UI_OptionXorY = 0;
  }

  if (n == 2) {
    WIN3D.UI_CurrentTask = UITASK.Truck_Orbit;
    WIN3D.UI_TaskModifyParameter = 1;
    WIN3D.UI_OptionXorY = 1;
  }

  ROLLOUT.revise();
}



void UI_set_to_View_LandOrbit (int n) {

  WIN3D.UI_CurrentTask = UITASK.LandOrbit_Pan_TargetRollZ;

  ROLLOUT.revise();
}



void UI_set_to_View_LookAtSelection (int n) {

  WIN3D.look_3DViewport_towards_Selection();

  { // automatically set another choice of ineterest
    UI_set_to_View_CameraDistance(0);
    UI_toolBar.highlight("±CDS");
    UI_toolBar.revise();
  }

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}


void UI_set_to_View_LookAtDirection (int n) {

  WIN3D.UI_CurrentTask = UITASK.LookAtDirection;

  ROLLOUT.revise();
}


void UI_set_to_View_LookAtOrigin (int n) {

  WIN3D.position_X = 0;
  WIN3D.position_Y = 0;
  WIN3D.position_Z = 0;

  {
    // automatically set another choice of ineterest

    UI_set_to_View_Truck(0);
    UI_toolBar.highlight("±CDZ");
    UI_toolBar.revise();
  }

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}


void UI_set_to_View_Pan (int n) {

  if (n == 0) {
    WIN3D.UI_CurrentTask = UITASK.Pan_TargetRoll;
  }

  if (n == 1) {
    WIN3D.UI_CurrentTask = UITASK.PanX_TargetRollXY_TargetRollZ;
  }

  if (n == 2) {
    WIN3D.UI_CurrentTask = UITASK.PanY_TargetRollXY_TargetRollZ;
  }


  ROLLOUT.revise();
}

void UI_set_to_View_ZOOM (int n) {
  WIN3D.UI_CurrentTask = UITASK.Pan_Height;

  ROLLOUT.revise();

  if (n == 1) {
    WIN3D.Zoom = 60;

    SOLARCHVISION_view_changed();
  }
}

void UI_set_to_View_3DModelSize () {

  WIN3D.UI_CurrentTask = UITASK.ModelSize_Pan_TargetRoll;

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}

void UI_set_to_View_SkydomeSize () {

  WIN3D.UI_CurrentTask = UITASK.SkydomeSize;

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}

void UI_set_to_View_AllModelSize () {

  WIN3D.UI_CurrentTask = UITASK.AllModelSize;

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}

boolean updateBars = false;

void UI_set_to_Viewport (int n) {

  updateBars = true;

  FrameVariation = n;
  SOLARCHVISION_update_frame_layout();

  ROLLOUT.revise();
}

void UI_set_to_View_3DViewPoint (int n) {

  WIN3D.currentCamera = 0;

  WIN3D.apply_currentCamera();

  if (n == 0) {
    WIN3D.rotateZ_3DViewport_around_Selection(0 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(0 - WIN3D.rotation_Z);
  }

  if (n == 1) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(0 - WIN3D.rotation_Z);
  }

  if (n == 2) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(-90 - WIN3D.rotation_Z);
  }

  if (n == 3) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(180 - WIN3D.rotation_Z);
  }

  if (n == 4) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(90 - WIN3D.rotation_Z);
  }

  if (n == 5) {
    WIN3D.rotateZ_3DViewport_around_Selection(180 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(0 - WIN3D.rotation_Z);
  }

  if (n == 6) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(-45 - WIN3D.rotation_Z);
  }

  if (n == 7) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(45 - WIN3D.rotation_Z);
  }

  if (n == 8) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(135 - WIN3D.rotation_Z);
  }

  if (n == 9) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(-135 - WIN3D.rotation_Z);
  }


  UI_toolBar.revise();

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}
