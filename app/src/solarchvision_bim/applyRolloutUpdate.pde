void applyRolloutUpdate() {
  if (!UI_rollout.include || !UI_rollout.update) return;

  UI_rollout.updated();

  pre_sampleYearStart = sampleYearStart;
  pre_sampleYearEnd = sampleYearEnd;
  pre_sampleMemberStart = sampleMemberStart;
  pre_sampleMemberEnd = sampleMemberEnd;
  pre_sampleStationStart = sampleStationStart;
  pre_sampleStationEnd = sampleStationEnd;
  pre_STUDY_joinDays = STUDY.joinDays;
  pre_STUDY_i_Start = STUDY.i_Start;
  pre_STUDY_i_End = STUDY.i_End;
  pre_STUDY_j_End = STUDY.j_End;
  pre_impactDisplayDay = impactDisplayDay;
  pre_STUDY_Setup = STUDY.plotSetup;
  pre_currentDataSource = currentDataSource;
  pre_TIME_Year = TIME.year;
  pre_TIME_Month = TIME.month;
  pre_TIME_Day = TIME.day;
  pre_TIME_Date = TIME.date;
  pre_TIME_Hour = TIME.hour;
  pre_climateBasedSolarForecast = climateBasedSolarForecast;
  pre_climateBasedWeatherForecast = climateBasedWeatherForecast;

  pre_climateTypicalYearShouldLoad = climateTypicalYearShouldLoad;
  pre_climateEngineeringShouldLoad = climateEngineeringShouldLoad;
  pre_climateArchiveShouldLoad = climateArchiveShouldLoad;
  pre_ensembleForecastShouldLoad = ensembleForecastShouldLoad;
  pre_ensembleObservationShouldLoad = ensembleObservationShouldLoad;

  pre_LocationLAT = LocationLAT;
  pre_LocationLON = LocationLON;

  pre_WORLD_autoView = WORLD.autoView;

  pre_Land3D_loadMesh = Land3D.loadMesh;
  pre_Land3D_loadTextures = Land3D.loadTextures;

  pre_allSolids_ColorScaleIndex = allSolids.colorScaleIndex;
  pre_allSolids_ColorScaleDirection = allSolids.colorScaleDirection;
  pre_allSolids_ColorScaleFactor = allSolids.colorScaleFactor;

  pre_USER_createUniformSuperellipsoidPower = User3D.creatorUniformSuperellipsoidPower;

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

  pre_WIN3D_currentCameraIndex = WIN3D.currentCameraIndex;

  pre_WIN3D_shadingMode = WIN3D.shadingMode;

  pre_Create3D_Tessellation = allFaces.displayTessellation;

  pre_STUDY_ImpactLayer = STUDY.ImpactLayer;

  pre_developLayerOption = developLayerOption;

  pre_STUDY_currentLayerId = currentLayerId;

  pre_STUDY_SkyScenario = STUDY.skyScenario;

  pre_STUDY_PlotImpacts = STUDY.PlotImpacts;

  UI_rollout.draw();

  if (pre_STUDY_PlotImpacts != STUDY.PlotImpacts) {
    STUDY.revise();

    view_changed();
  }

  react.caseBarOnly.run(pre_sampleYearStart, sampleYearStart);
  react.caseBarOnly.run(pre_sampleYearEnd, sampleYearEnd);

  react.caseBarOnly.run(pre_sampleMemberStart, sampleMemberStart);

  react.caseBarOnly.run(pre_sampleMemberEnd, sampleMemberEnd);

  react.caseBarOnly.run(pre_sampleStationStart, sampleStationStart);

  react.caseBarOnly.run(pre_sampleStationEnd, sampleStationEnd);

  react.caseBarOnly.run(pre_STUDY_joinDays, STUDY.joinDays);

  react.caseBarOnly.run(pre_STUDY_i_Start, STUDY.i_Start);

  react.caseBarOnly.run(pre_STUDY_i_End, STUDY.i_End);

  react.applyStudyJEnd.run(pre_STUDY_j_End, STUDY.j_End);

  react.caseBarOnly.run(pre_impactDisplayDay, impactDisplayDay);

  if (pre_TIME_Date != TIME.date) {
    UI_caseBar.revise();

    react.applyTimeDate.run(pre_TIME_Date, TIME.date);
    UI_rollout.draw();
  }

  if ((pre_TIME_Year != TIME.year) ||
      (pre_TIME_Month != TIME.month) ||
      (pre_TIME_Day != TIME.day) ||
      (pre_TIME_Hour != TIME.hour) ||
      (pre_climateBasedSolarForecast != climateBasedSolarForecast) ||
      (pre_climateBasedWeatherForecast != climateBasedWeatherForecast)) {

    UI_caseBar.revise();

    react.applyTimeChange.run(pre_TIME_Year, TIME.year);
    UI_rollout.draw();
  }

  if (pre_climateTypicalYearShouldLoad != climateTypicalYearShouldLoad) update_climateTypicalYear();
  if (pre_climateEngineeringShouldLoad != climateEngineeringShouldLoad) update_climateEngineering();
  if (pre_climateArchiveShouldLoad != climateArchiveShouldLoad) updateClimateArchive();
  if (pre_ensembleObservationShouldLoad != ensembleObservationShouldLoad) update_ensembleObservation(TIME.year, TIME.month, TIME.day, TIME.hour);
  if (pre_ensembleForecastShouldLoad != ensembleForecastShouldLoad) update_ensembleForecast(TIME.year, TIME.month, TIME.day, TIME.hour);

  if (pre_WORLD_autoView != WORLD.autoView) {
    WORLD.VIEW_id = WORLD.FindGoodViewport(LocationLON, LocationLAT);
  }

  if ((pre_LocationLAT != LocationLAT) ||
      (pre_LocationLON != LocationLON)) {

    react.applyLocationChange.run(pre_LocationLAT, LocationLAT);
  }

  react.applyLandLoadMesh.run(pre_Land3D_loadMesh ? 1 : 0, Land3D.loadMesh ? 1 : 0);

  react.applyLandLoadTextures.run(pre_Land3D_loadTextures ? 1 : 0, Land3D.loadTextures ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_Camera_displayEdges ? 1 : 0, Select3D.Camera_displayEdges ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_Section_displayEdges ? 1 : 0, Select3D.Section_displayEdges ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_Solid_displayEdges ? 1 : 0, Select3D.Solid_displayEdges ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_LandPoint_displayPoints ? 1 : 0, Select3D.LandPoint_displayPoints ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_Model1D_displayEdges ? 1 : 0, Select3D.Model1D_displayEdges ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_Model2D_displayEdges ? 1 : 0, Select3D.Model2D_displayEdges ? 1 : 0);

  react.softSelectionChanged.run(pre_Selection_softPower, Select3D.softPower);

  react.softSelectionChanged.run(pre_Selection_softRadius, Select3D.softRadius);

  react.selectionChangedOnly.run(pre_Selection_alignX, Select3D.alignX);

  react.selectionChangedOnly.run(pre_Selection_alignY, Select3D.alignY);

  react.selectionChangedOnly.run(pre_Selection_alignZ, Select3D.alignZ);

  react.applyPosValue.run(pre_Selection_posValue, Select3D.posValue);
  react.applyRotValue.run(pre_Selection_rotValue, Select3D.rotValue);
  react.applyScaleValue.run(pre_Selection_scaleValue, Select3D.scaleValue);

  react.viewChangedOnly.run(pre_Selection_displayReferencePivot ? 1 : 0, Select3D.displayReferencePivot ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_Group_displayPivot ? 1 : 0, Select3D.Group_displayPivot ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_Group_displayEdges ? 1 : 0, Select3D.Group_displayEdges ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_Group_displayBox ? 1 : 0, Select3D.Group_displayBox ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_Face_displayEdges ? 1 : 0, Select3D.Face_displayEdges ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_Face_displayVertexCount ? 1 : 0, Select3D.Face_displayVertexCount ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_Polyline_displayVertexCount ? 1 : 0, Select3D.Polyline_displayVertexCount ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_Vertex_displayVertices ? 1 : 0, Select3D.Vertex_displayVertices ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_Polyline_displayVertices ? 1 : 0, Select3D.Polyline_displayVertices ? 1 : 0);

  react.applyCurrentCamera.run(pre_WIN3D_currentCameraIndex, WIN3D.currentCameraIndex);

  if (pre_WIN3D_shadingMode != WIN3D.shadingMode) {
    view_changed();
  }

  react.viewChangedOnly.run(pre_Create3D_Tessellation, allFaces.displayTessellation);

  react.applyCreatePowAll.run(pre_USER_createUniformSuperellipsoidPower, User3D.creatorUniformSuperellipsoidPower);

  react.recalcImpact.run(pre_allSolids_ColorScaleIndex, allSolids.colorScaleIndex);
  react.recalcImpact.run(pre_allSolids_ColorScaleDirection, allSolids.colorScaleDirection);
  react.recalcImpact.run(pre_allSolids_ColorScaleFactor, allSolids.colorScaleFactor);

  react.recalcImpact.run(pre_allSolidImpacts_Grade, allSolidImpacts.Grade);
  react.recalcImpact.run(pre_allSolidImpacts_Power, allSolidImpacts.Power);
  react.recalcImpact.run(pre_allSolidImpacts_Rotation[allSolidImpacts.sectionType], allSolidImpacts.R[allSolidImpacts.sectionType]);
  react.recalcImpact.run(pre_allSolidImpacts_Elevation[allSolidImpacts.sectionType], allSolidImpacts.Z[allSolidImpacts.sectionType]);

  react.recalcImpact.run(pre_allSolidImpacts_U_scale[allSolidImpacts.sectionType], allSolidImpacts.U[allSolidImpacts.sectionType]);
  react.recalcImpact.run(pre_allSolidImpacts_V_scale[allSolidImpacts.sectionType], allSolidImpacts.V[allSolidImpacts.sectionType]);
  react.recalcImpact.run(pre_allSolidImpacts_sU_offset[allSolidImpacts.sectionType], allSolidImpacts.X[allSolidImpacts.sectionType]);
  react.recalcImpact.run(pre_allSolidImpacts_sV_offset[allSolidImpacts.sectionType], allSolidImpacts.Y[allSolidImpacts.sectionType]);

  react.recalcImpact.run(pre_allSolidImpacts_Wspd, allSolidImpacts.WindSpeed);
  react.recalcImpact.run(pre_allSolidImpacts_Wdir, allSolidImpacts.WindDirection);

  react.recalcImpact.run(pre_allSolidImpacts_Process_subDivisions, allSolidImpacts.Process_subDivisions);

  react.viewChangedOnly.run(pre_allSolidImpacts_displayPoints ? 1 : 0, allSolidImpacts.displayPoints ? 1 : 0);

  react.viewChangedOnly.run(pre_allSolidImpacts_displayLines ? 1 : 0, allSolidImpacts.displayLines ? 1 : 0);

  react.viewChangedOnly.run(pre_allPoints_displayAll ? 1 : 0, allPoints.displayAll ? 1 : 0);

  react.viewChangedOnly.run(pre_allFaces_displayEdges ? 1 : 0, allFaces.displayEdges ? 1 : 0);

  react.viewChangedOnly.run(pre_allFaces_displayNormals ? 1 : 0, allFaces.displayNormals ? 1 : 0);

  react.viewChangedOnly.run(pre_WindFlow_display ? 1 : 0, allWindFlows.displayAll ? 1 : 0);

  react.impactsUpdateFlag.run(pre_STUDY_Setup, STUDY.plotSetup);

  react.impactsUpdateFlag.run(pre_currentDataSource, currentDataSource);
}

float pre_TIME_Date;
int pre_TIME_Hour;
int pre_TIME_Day;
int pre_TIME_Month;
int pre_TIME_Year;

int pre_sampleYearStart;
int pre_sampleYearEnd;
int pre_sampleMemberStart;
int pre_sampleMemberEnd;
int pre_sampleStationStart;
int pre_sampleStationEnd;

int pre_STUDY_joinDays;
int pre_STUDY_i_Start;
int pre_STUDY_i_End;
int pre_STUDY_j_End;
int pre_STUDY_Setup;

int pre_impactDisplayDay;
int pre_currentDataSource;

int pre_climateBasedSolarForecast;
int pre_climateBasedWeatherForecast;

boolean pre_climateTypicalYearShouldLoad;
boolean pre_climateEngineeringShouldLoad;
boolean pre_climateArchiveShouldLoad;
boolean pre_ensembleForecastShouldLoad;
boolean pre_ensembleObservationShouldLoad;

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

int pre_WIN3D_currentCameraIndex;

int pre_WIN3D_shadingMode;

int pre_Create3D_Tessellation;

boolean pre_allPoints_displayAll;
boolean pre_allFaces_displayEdges;
boolean pre_allFaces_displayNormals;

int pre_developLayerOption;

int pre_STUDY_ImpactLayer;
int pre_STUDY_currentLayerId;

int pre_STUDY_SkyScenario;
int pre_STUDY_PlotImpacts;

int pre_allSolids_ColorScaleIndex;
int pre_allSolids_ColorScaleDirection;
float pre_allSolids_ColorScaleFactor;

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

float pre_USER_createUniformSuperellipsoidPower;

PImage pre_screen;
