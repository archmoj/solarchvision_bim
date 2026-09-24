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

  UI_rollout.applyStudyJEnd.run(pre_STUDY_j_End, STUDY.j_End);

  if (pre_IMPACTS_displayDay != IMPACTS_displayDay) {
    UI_caseBar.revise();
  }

  if (pre_TIME_Date != TIME.date) {
    UI_caseBar.revise();

    UI_rollout.applyTimeDate.run(pre_TIME_Date, TIME.date);
    UI_rollout.draw();
  }

  if ((pre_TIME_Year != TIME.year) ||
      (pre_TIME_Month != TIME.month) ||
      (pre_TIME_Day != TIME.day) ||
      (pre_TIME_Hour != TIME.hour) ||
      (pre_CLIMATIC_SolarForecast != CLIMATIC_SolarForecast) ||
      (pre_CLIMATIC_WeatherForecast != CLIMATIC_WeatherForecast)) {

    UI_caseBar.revise();

    UI_rollout.applyTimeChange.run(pre_TIME_Year, TIME.year);
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

    UI_rollout.applyLocationChange.run(pre_LocationLAT, LocationLAT);
  }

  UI_rollout.applyLandLoadMesh.run(pre_Land3D_loadMesh ? 1 : 0, Land3D.loadMesh ? 1 : 0);

  UI_rollout.applyLandLoadTextures.run(pre_Land3D_loadTextures ? 1 : 0, Land3D.loadTextures ? 1 : 0);

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

  UI_rollout.applyPosValue.run(pre_Selection_posValue, Select3D.posValue);
  UI_rollout.applyRotValue.run(pre_Selection_rotValue, Select3D.rotValue);
  UI_rollout.applyScaleValue.run(pre_Selection_scaleValue, Select3D.scaleValue);

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

  UI_rollout.applyCurrentCamera.run(pre_WIN3D_currentCamera, WIN3D.currentCamera);

  if (pre_WIN3D_FacesShade != WIN3D.FacesShade) {
    view_changed();
  }

  if (pre_Create3D_Tessellation != allFaces.displayTessellation) {
    view_changed();
  }

  UI_rollout.applyCreatePowAll.run(pre_USER_create_powAll, User3D.create_powAll);

  UI_rollout.recalcImpact.run(pre_allSolids_palette_CLR, allSolids.palette_CLR);
  UI_rollout.recalcImpact.run(pre_allSolids_palette_DIR, allSolids.palette_DIR);
  UI_rollout.recalcImpact.run(pre_allSolids_palette_MLT, allSolids.palette_MLT);

  UI_rollout.recalcImpact.run(pre_allSolidImpacts_Grade, allSolidImpacts.Grade);
  UI_rollout.recalcImpact.run(pre_allSolidImpacts_Power, allSolidImpacts.Power);
  UI_rollout.recalcImpact.run(pre_allSolidImpacts_Rotation[allSolidImpacts.sectionType], allSolidImpacts.R[allSolidImpacts.sectionType]);
  UI_rollout.recalcImpact.run(pre_allSolidImpacts_Elevation[allSolidImpacts.sectionType], allSolidImpacts.Z[allSolidImpacts.sectionType]);

  UI_rollout.recalcImpact.run(pre_allSolidImpacts_U_scale[allSolidImpacts.sectionType], allSolidImpacts.U[allSolidImpacts.sectionType]);
  UI_rollout.recalcImpact.run(pre_allSolidImpacts_V_scale[allSolidImpacts.sectionType], allSolidImpacts.V[allSolidImpacts.sectionType]);
  UI_rollout.recalcImpact.run(pre_allSolidImpacts_sU_offset[allSolidImpacts.sectionType], allSolidImpacts.X[allSolidImpacts.sectionType]);
  UI_rollout.recalcImpact.run(pre_allSolidImpacts_sV_offset[allSolidImpacts.sectionType], allSolidImpacts.Y[allSolidImpacts.sectionType]);

  UI_rollout.recalcImpact.run(pre_allSolidImpacts_Wspd, allSolidImpacts.WindSpeed);
  UI_rollout.recalcImpact.run(pre_allSolidImpacts_Wdir, allSolidImpacts.WindDirection);

  UI_rollout.recalcImpact.run(pre_allSolidImpacts_Process_subDivisions, allSolidImpacts.Process_subDivisions);

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

  UI_rollout.impactsUpdateFlag.run(pre_STUDY_Setup, STUDY.plotSetup);

  UI_rollout.impactsUpdateFlag.run(pre_CurrentDataSource, CurrentDataSource);
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
