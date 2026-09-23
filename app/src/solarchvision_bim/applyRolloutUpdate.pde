void applyRolloutUpdate() {
  if (!UI_rollout.include || !UI_rollout.update) return;

  UI_rollout.updated();

  pre_SampleYear_Start = SampleYear_Start;
  pre_SampleYear_End = SampleYear_End;
  pre_SampleMember_Start = SampleMember_Start;
  pre_SampleMember_End = SampleMember_End;
  pre_SampleStation_Start = SampleStation_Start;
  pre_SampleStation_End = SampleStation_End;
  pre_STUDY_joinDays = STUDY.joinDays;
  pre_STUDY_i_Start = STUDY.i_Start;
  pre_STUDY_i_End = STUDY.i_End;
  pre_STUDY_j_End = STUDY.j_End;
  pre_IMPACTS_displayDay = IMPACTS_displayDay;
  pre_STUDY_Setup = STUDY.plotSetup;
  pre_CurrentDataSource = CurrentDataSource;
  pre_TIME_Year = TIME.year;
  pre_TIME_Month = TIME.month;
  pre_TIME_Day = TIME.day;
  pre_TIME_Date = TIME.date;
  pre_TIME_Hour = TIME.hour;
  pre_CLIMATIC_SolarForecast = CLIMATIC_SolarForecast;
  pre_CLIMATIC_WeatherForecast = CLIMATIC_WeatherForecast;

  pre_CLIMATE_TMYEPW_load = CLIMATE_TMYEPW_load;
  pre_CLIMATE_CWEEDS_load = CLIMATE_CWEEDS_load;
  pre_CLIMATE_CLMREC_load = CLIMATE_CLMREC_load;
  pre_ENSEMBLE_FORECAST_load = ENSEMBLE_FORECAST_load;
  pre_ENSEMBLE_OBSERVED_load = ENSEMBLE_OBSERVED_load;

  pre_LocationLAT = LocationLAT;
  pre_LocationLON = LocationLON;

  pre_WORLD_autoView = WORLD.autoView;

  pre_Land3D_loadMesh = Land3D.loadMesh;
  pre_Land3D_loadTextures = Land3D.loadTextures;

  pre_allSolids_palette_CLR = allSolids.palette_CLR;
  pre_allSolids_palette_DIR = allSolids.palette_DIR;
  pre_allSolids_palette_MLT = allSolids.palette_MLT;

  pre_USER_create_powAll = User3D.create_powAll;

  pre_allSolidImpacts_U_scale = allSolidImpacts.U;
  pre_allSolidImpacts_V_scale = allSolidImpacts.V;

  pre_allSolidImpacts_sU_offset = allSolidImpacts.X;
  pre_allSolidImpacts_sV_offset = allSolidImpacts.Y;

  pre_allSolidImpacts_Grade = allSolidImpacts.Grade;
  pre_allSolidImpacts_Power = allSolidImpacts.Power;
  pre_allSolidImpacts_Rotation[allSolidImpacts.sectionType] = allSolidImpacts.R[allSolidImpacts.sectionType];
  pre_allSolidImpacts_Elevation[allSolidImpacts.sectionType] = allSolidImpacts.Z[allSolidImpacts.sectionType];

  pre_allSolidImpacts_Wspd = allSolidImpacts.WindSpeed;
  pre_allSolidImpacts_Wdir = allSolidImpacts.WindDirection;

  pre_allSolidImpacts_Process_subDivisions = allSolidImpacts.Process_subDivisions;

  pre_allSolidImpacts_displayPoints = allSolidImpacts.displayPoints;
  pre_allSolidImpacts_displayLines = allSolidImpacts.displayLines;

  pre_WindFlow_display = allWindFlows.displayAll;

  pre_Selection_Solid_displayEdges = Select3D.Solid_displayEdges;

  pre_Selection_Section_displayEdges = Select3D.Section_displayEdges;

  pre_Selection_Camera_displayEdges = Select3D.Camera_displayEdges;

  pre_Selection_LandPoint_displayPoints = Select3D.LandPoint_displayPoints;

  pre_Selection_Model1D_displayEdges = Select3D.Model1D_displayEdges;
  pre_Selection_Model2D_displayEdges = Select3D.Model2D_displayEdges;
  pre_allPoints_displayAll = allPoints.displayAll;
  pre_allFaces_displayEdges = allFaces.displayEdges;
  pre_allFaces_displayNormals = allFaces.displayNormals;

  pre_Selection_softPower = Select3D.softPower;
  pre_Selection_softRadius = Select3D.softRadius;

  pre_Selection_posValue = Select3D.posValue;
  pre_Selection_rotValue = Select3D.rotValue;
  pre_Selection_scaleValue = Select3D.scaleValue;

  pre_Selection_alignX = Select3D.alignX;
  pre_Selection_alignY = Select3D.alignY;
  pre_Selection_alignZ = Select3D.alignZ;

  pre_Selection_displayReferencePivot = Select3D.displayReferencePivot;

  pre_Selection_Group_displayPivot = Select3D.Group_displayPivot;
  pre_Selection_Group_displayEdges = Select3D.Group_displayEdges;
  pre_Selection_Group_displayBox = Select3D.Group_displayBox;

  pre_Selection_Face_displayEdges = Select3D.Face_displayEdges;
  pre_Selection_Face_displayVertexCount = Select3D.Face_displayVertexCount;
  pre_Selection_Polyline_displayVertexCount = Select3D.Polyline_displayVertexCount;
  pre_Selection_Vertex_displayVertices = Select3D.Vertex_displayVertices;
  pre_Selection_Polyline_displayVertices = Select3D.Polyline_displayVertices;

  pre_WIN3D_currentCamera = WIN3D.currentCamera;

  pre_WIN3D_FacesShade = WIN3D.FacesShade;

  pre_Create3D_Tessellation = allFaces.displayTessellation;

  pre_STUDY_ImpactLayer = STUDY.ImpactLayer;

  pre_Develop_Option = Develop_Option;

  pre_STUDY_CurrentLayer_id = CurrentLayer_id;

  pre_STUDY_SkyScenario = STUDY.skyScenario;

  pre_STUDY_PlotImpacts = STUDY.PlotImpacts;

  UI_rollout.draw();

  if (pre_STUDY_PlotImpacts != STUDY.PlotImpacts) {
    STUDY.revise();

    view_changed();
  }

  if (pre_SampleYear_Start != SampleYear_Start) {
    UI_caseBar.revise();
  }
  if (pre_SampleYear_End != SampleYear_End) {
    UI_caseBar.revise();
  }

  if (pre_SampleMember_Start != SampleMember_Start) {
    UI_caseBar.revise();
  }

  if (pre_SampleMember_End != SampleMember_End) {
    UI_caseBar.revise();
  }

  if (pre_SampleStation_Start != SampleStation_Start) {
    UI_caseBar.revise();
  }

  if (pre_SampleStation_End != SampleStation_End) {
    UI_caseBar.revise();
  }

  if (pre_STUDY_joinDays != STUDY.joinDays) {
    UI_caseBar.revise();
  }

  if (pre_STUDY_i_Start != STUDY.i_Start) {
    UI_caseBar.revise();
  }

  if (pre_STUDY_i_End != STUDY.i_End) {
    UI_caseBar.revise();
  }

  if (pre_STUDY_j_End != STUDY.j_End) {
    UI_caseBar.revise();

    if (WIN3D.FacesShade == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;
    if (WIN3D.FacesShade == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
    allSolarImpacts.rebuild_Image_array = true;
    allWindRoses.rebuild_Image_array = true;

    allSections.resize_solarImpact_array();
  }

  if (pre_IMPACTS_displayDay != IMPACTS_displayDay) {
    UI_caseBar.revise();
  }

  if (pre_TIME_Date != TIME.date) {
    UI_caseBar.revise();

    TIME.updateDate();
    UI_rollout.draw();
  }

  if ((pre_TIME_Year != TIME.year) ||
      (pre_TIME_Month != TIME.month) ||
      (pre_TIME_Day != TIME.day) ||
      (pre_TIME_Hour != TIME.hour) ||
      (pre_CLIMATIC_SolarForecast != CLIMATIC_SolarForecast) ||
      (pre_CLIMATIC_WeatherForecast != CLIMATIC_WeatherForecast)) {

    UI_caseBar.revise();

    TIME.beginDay = TIME.convert2Date(TIME.month, TIME.day);
    TIME.hour = int(24 * (TIME.date - int(TIME.date)));
    TIME.date = (TIME.hour / 24.0) + (286 + TIME.convert2Date(TIME.month, TIME.day)) % 365;
    println("DATE:", TIME.date, "\tHOUR:", TIME.hour);
    update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);

    UI_rollout.draw();
  }

  if (pre_CLIMATE_TMYEPW_load != CLIMATE_TMYEPW_load) update_CLIMATE_TMYEPW();
  if (pre_CLIMATE_CWEEDS_load != CLIMATE_CWEEDS_load) update_CLIMATE_CWEEDS();
  if (pre_CLIMATE_CLMREC_load != CLIMATE_CLMREC_load) update_CLIMATE_CLMREC();
  if (pre_ENSEMBLE_OBSERVED_load != ENSEMBLE_OBSERVED_load) update_ENSEMBLE_OBSERVED(TIME.year, TIME.month, TIME.day, TIME.hour);
  if (pre_ENSEMBLE_FORECAST_load != ENSEMBLE_FORECAST_load) update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);

  if (pre_WORLD_autoView != WORLD.autoView) {
    WORLD.VIEW_id = WORLD.FindGoodViewport(LocationLON, LocationLAT);
  }

  if ((pre_LocationLAT != LocationLAT) ||
      (pre_LocationLON != LocationLON)) {

    WORLD.VIEW_id = WORLD.FindGoodViewport(LocationLON, LocationLAT);
    WORLD.revise();
  }

  if (pre_Land3D_loadMesh != Land3D.loadMesh) {
    Land3D.update_mesh();
    model_changed();
  }

  if (pre_Land3D_loadTextures != Land3D.loadTextures) {
    Land3D.update_textures();
    model_changed();
  }

  if (pre_Selection_Camera_displayEdges != Select3D.Camera_displayEdges) {
    view_changed();
  }

  if (pre_Selection_Section_displayEdges != Select3D.Section_displayEdges) {
    view_changed();
  }

  if (pre_Selection_Solid_displayEdges != Select3D.Solid_displayEdges) {
    view_changed();
  }

  if (pre_Selection_LandPoint_displayPoints != Select3D.LandPoint_displayPoints) {
    view_changed();
  }

  if (pre_Selection_Model1D_displayEdges != Select3D.Model1D_displayEdges) {
    view_changed();
  }

  if (pre_Selection_Model2D_displayEdges != Select3D.Model2D_displayEdges) {
    view_changed();
  }

  if (pre_Selection_softPower != Select3D.softPower) {
    Select3D.convert_Vertex_to_softSelection();
  }

  if (pre_Selection_softRadius != Select3D.softRadius) {
    Select3D.convert_Vertex_to_softSelection();
  }

  if (pre_Selection_alignX != Select3D.alignX) {
    selection_changed();
  }

  if (pre_Selection_alignY != Select3D.alignY) {
    selection_changed();
  }

  if (pre_Selection_alignZ != Select3D.alignZ) {
    selection_changed();
  }

  if (pre_Selection_posValue != Select3D.posValue) {

    float d = Select3D.posValue - pre_Selection_posValue;

    float dx = d;
    float dy = d;
    float dz = d;

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

    Move3D.selection(dx, dy, dz);

    model_changed();
  }
  if (pre_Selection_rotValue != Select3D.rotValue) {

    float[] P = Select3D.getPivot();

    float x0 = P[0];
    float y0 = P[1];
    float z0 = P[2];

    float r = Select3D.rotValue - pre_Selection_rotValue;

    int the_Vector = Select3D.rotVector;

    Rotate3D.selection(x0, y0, z0, r, the_Vector);

    model_changed();
  }
  if (pre_Selection_scaleValue != Select3D.scaleValue) {

    float[] P = Select3D.getPivot();

    float x0 = P[0];
    float y0 = P[1];
    float z0 = P[2];

    float s = pow(2.0, Select3D.scaleValue - pre_Selection_scaleValue);

    float sx = s;
    float sy = s;
    float sz = s;

    int the_Vector = Select3D.scaleVector;

    if (the_Vector == 0) {
      sy = 1;
      sz = 1;
    }
    if (the_Vector == 1) {
      sz = 1;
      sx = 1;
    }
    if (the_Vector == 2) {
      sx = 1;
      sy = 1;
    }

    Scale3D.selection(x0, y0, z0, sx, sy, sz);

    model_changed();
  }

  if (pre_Selection_displayReferencePivot != Select3D.displayReferencePivot) {
    view_changed();
  }

  if (pre_Selection_Group_displayPivot != Select3D.Group_displayPivot) {
    view_changed();
  }

  if (pre_Selection_Group_displayEdges != Select3D.Group_displayEdges) {
    view_changed();
  }

  if (pre_Selection_Group_displayBox != Select3D.Group_displayBox) {
    view_changed();
  }

  if (pre_Selection_Face_displayEdges != Select3D.Face_displayEdges) {
    view_changed();
  }

  if (pre_Selection_Face_displayVertexCount != Select3D.Face_displayVertexCount) {
    view_changed();
  }

  if (pre_Selection_Polyline_displayVertexCount != Select3D.Polyline_displayVertexCount) {
    view_changed();
  }

  if (pre_Selection_Vertex_displayVertices != Select3D.Vertex_displayVertices) {
    view_changed();
  }

  if (pre_Selection_Polyline_displayVertices != Select3D.Polyline_displayVertices) {
    view_changed();
  }

  if (pre_WIN3D_currentCamera != WIN3D.currentCamera) {
    WIN3D.apply_currentCamera();

    modify_Viewport_Title();

    view_changed();
  }

  if (pre_WIN3D_FacesShade != WIN3D.FacesShade) {
    view_changed();
  }

  if (pre_Create3D_Tessellation != allFaces.displayTessellation) {
    view_changed();
  }

  if (pre_USER_create_powAll != User3D.create_powAll) {
    User3D.create_powX = User3D.create_powAll;
    User3D.create_powY = User3D.create_powAll;
    User3D.create_powZ = User3D.create_powAll;

    UI_rollout.revise();
  }

  if (pre_allSolids_palette_CLR != allSolids.palette_CLR) {
    allSolidImpacts.calculate_Impact_selectedSections();

    view_changed();
  }
  if (pre_allSolids_palette_DIR != allSolids.palette_DIR) {
    allSolidImpacts.calculate_Impact_selectedSections();

    view_changed();
  }
  if (pre_allSolids_palette_MLT != allSolids.palette_MLT) {
    allSolidImpacts.calculate_Impact_selectedSections();

    view_changed();
  }

  if (pre_allSolidImpacts_Grade != allSolidImpacts.Grade) {
    allSolidImpacts.calculate_Impact_selectedSections();

    view_changed();
  }
  if (pre_allSolidImpacts_Power != allSolidImpacts.Power) {
    allSolidImpacts.calculate_Impact_selectedSections();

    view_changed();
  }
  if (pre_allSolidImpacts_Rotation[allSolidImpacts.sectionType] != allSolidImpacts.R[allSolidImpacts.sectionType]) {
    allSolidImpacts.calculate_Impact_selectedSections();

    view_changed();
  }
  if (pre_allSolidImpacts_Elevation[allSolidImpacts.sectionType] != allSolidImpacts.Z[allSolidImpacts.sectionType]) {
    allSolidImpacts.calculate_Impact_selectedSections();

    view_changed();
  }

  if (pre_allSolidImpacts_U_scale[allSolidImpacts.sectionType] != allSolidImpacts.U[allSolidImpacts.sectionType]) {
    allSolidImpacts.calculate_Impact_selectedSections();

    view_changed();
  }

  if (pre_allSolidImpacts_V_scale[allSolidImpacts.sectionType] != allSolidImpacts.V[allSolidImpacts.sectionType]) {
    allSolidImpacts.calculate_Impact_selectedSections();

    view_changed();
  }

  if (pre_allSolidImpacts_sU_offset[allSolidImpacts.sectionType] != allSolidImpacts.X[allSolidImpacts.sectionType]) {
    allSolidImpacts.calculate_Impact_selectedSections();

    view_changed();
  }
  if (pre_allSolidImpacts_sV_offset[allSolidImpacts.sectionType] != allSolidImpacts.Y[allSolidImpacts.sectionType]) {
    allSolidImpacts.calculate_Impact_selectedSections();

    view_changed();
  }

  if (pre_allSolidImpacts_Wspd != allSolidImpacts.WindSpeed) {
    allSolidImpacts.calculate_Impact_selectedSections();

    view_changed();
  }
  if (pre_allSolidImpacts_Wdir != allSolidImpacts.WindDirection) {
    allSolidImpacts.calculate_Impact_selectedSections();

    view_changed();
  }

  if (pre_allSolidImpacts_Process_subDivisions != allSolidImpacts.Process_subDivisions) {
    allSolidImpacts.calculate_Impact_selectedSections();

    view_changed();
  }

  if (pre_allSolidImpacts_displayPoints != allSolidImpacts.displayPoints) {
    view_changed();
  }

  if (pre_allSolidImpacts_displayLines != allSolidImpacts.displayLines) {
    view_changed();
  }

  if (pre_allPoints_displayAll != allPoints.displayAll) {
    view_changed();
  }

  if (pre_allFaces_displayEdges != allFaces.displayEdges) {
    view_changed();
  }

  if (pre_allFaces_displayNormals != allFaces.displayNormals) {
    view_changed();
  }

  if (pre_WindFlow_display != allWindFlows.displayAll) {
    view_changed();
  }

  if (STUDY.plotSetup != pre_STUDY_Setup) {
    STUDY.Impacts_update = true;
    UI_caseBar.updated();
  }

  if (CurrentDataSource != pre_CurrentDataSource) {
    STUDY.Impacts_update = true;
    UI_caseBar.updated();
  }
}

float pre_TIME_Date;
int pre_TIME_Hour;
int pre_TIME_Day;
int pre_TIME_Month;
int pre_TIME_Year;

int pre_SampleYear_Start;
int pre_SampleYear_End;
int pre_SampleMember_Start;
int pre_SampleMember_End;
int pre_SampleStation_Start;
int pre_SampleStation_End;

int pre_STUDY_joinDays;
int pre_STUDY_i_Start;
int pre_STUDY_i_End;
int pre_STUDY_j_End;
int pre_STUDY_Setup;

int pre_IMPACTS_displayDay;
int pre_CurrentDataSource;

int pre_CLIMATIC_SolarForecast;
int pre_CLIMATIC_WeatherForecast;

boolean pre_CLIMATE_TMYEPW_load;
boolean pre_CLIMATE_CWEEDS_load;
boolean pre_CLIMATE_CLMREC_load;
boolean pre_ENSEMBLE_FORECAST_load;
boolean pre_ENSEMBLE_OBSERVED_load;

boolean pre_Land3D_loadMesh;
boolean pre_Land3D_loadTextures;

float pre_LocationLAT;
float pre_LocationLON;

boolean pre_WORLD_autoView;

boolean pre_Selection_Model1D_displayEdges;
boolean pre_Selection_Model2D_displayEdges;

boolean pre_Selection_Solid_displayEdges;
boolean pre_Selection_Section_displayEdges;
boolean pre_Selection_Camera_displayEdges;

boolean pre_Selection_LandPoint_displayPoints;

float pre_Selection_softPower;
float pre_Selection_softRadius;

float pre_Selection_posValue;
float pre_Selection_rotValue;
float pre_Selection_scaleValue;

int pre_Selection_alignX;
int pre_Selection_alignY;
int pre_Selection_alignZ;

boolean pre_Selection_displayReferencePivot;

boolean pre_Selection_Group_displayPivot;
boolean pre_Selection_Group_displayEdges;
boolean pre_Selection_Group_displayBox;

boolean pre_Selection_Face_displayEdges;
boolean pre_Selection_Face_displayVertexCount;
boolean pre_Selection_Polyline_displayVertexCount;
boolean pre_Selection_Vertex_displayVertices;
boolean pre_Selection_Polyline_displayVertices;

int pre_WIN3D_currentCamera;

int pre_WIN3D_FacesShade;

int pre_Create3D_Tessellation;

boolean pre_allPoints_displayAll;
boolean pre_allFaces_displayEdges;
boolean pre_allFaces_displayNormals;

int pre_Develop_Option;

int pre_STUDY_ImpactLayer;
int pre_STUDY_CurrentLayer_id;

int pre_STUDY_SkyScenario;
int pre_STUDY_PlotImpacts;

int pre_allSolids_palette_CLR;
int pre_allSolids_palette_DIR;
float pre_allSolids_palette_MLT;

float pre_allSolidImpacts_Grade;
float pre_allSolidImpacts_Power;
float[] pre_allSolidImpacts_Rotation = {
  0, 0, 0, 0
};
float[] pre_allSolidImpacts_Elevation = {
  0, 0, 0, 0
};
float[] pre_allSolidImpacts_U_scale = {
  0, 0, 0, 0
};
float[] pre_allSolidImpacts_V_scale = {
  0, 0, 0, 0
};
float[] pre_allSolidImpacts_sU_offset = {
  0, 0, 0, 0
};
float[] pre_allSolidImpacts_sV_offset = {
  0, 0, 0, 0
};

float pre_allSolidImpacts_Wspd;
float pre_allSolidImpacts_Wdir;

boolean pre_allSolidImpacts_displayPoints;
boolean pre_allSolidImpacts_displayLines;

int pre_allSolidImpacts_Process_subDivisions;

boolean pre_WindFlow_display;

float pre_USER_create_powAll;

PImage pre_screen;
