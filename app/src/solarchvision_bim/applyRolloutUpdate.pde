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

  pre_Terrain_loadMesh = Terrain.loadMesh;
  pre_Terrain_loadTextures = Terrain.loadTextures;

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

  pre_Selection_solidDisplayEdges = Select3D.solidDisplayEdges;

  pre_Selection_sectionDisplayEdges = Select3D.sectionDisplayEdges;

  pre_Selection_cameraDisplayFrustum = Select3D.cameraDisplayFrustum;

  pre_Selection_terrainDisplayVertices = Select3D.terrainDisplayVertices;

  pre_Selection_model1DDisplayBounds = Select3D.model1DDisplayBounds;
  pre_Selection_model2DDisplayBounds = Select3D.model2DDisplayBounds;
  pre_allPoints_displayAll = allPoints.displayAll;
  pre_allFaces_displayEdges = allFaces.displayEdges;
  pre_allFaces_displayNormals = allFaces.displayNormals;

  pre_Selection_softSelectionFalloffPower = Select3D.softSelectionFalloffPower;
  pre_Selection_softSelectionFalloffRadius = Select3D.softSelectionFalloffRadius;

  pre_Selection_position = Select3D.position;
  pre_Selection_rotation = Select3D.rotation;
  pre_Selection_scale = Select3D.scale;

  pre_Selection_pivotAlignmentX = Select3D.pivotAlignmentX;
  pre_Selection_pivotAlignmentY = Select3D.pivotAlignmentY;
  pre_Selection_pivotAlignmentZ = Select3D.pivotAlignmentZ;

  pre_Selection_pivotDisplayReference = Select3D.pivotDisplayReference;

  pre_Selection_groupDisplayPivot = Select3D.groupDisplayPivot;
  pre_Selection_groupDisplayEdges = Select3D.groupDisplayEdges;
  pre_Selection_groupDisplayBox = Select3D.groupDisplayBox;

  pre_Selection_faceDisplayEdges = Select3D.faceDisplayEdges;
  pre_Selection_faceDisplayVertexIndices = Select3D.faceDisplayVertexIndices;
  pre_Selection_polylineDisplayVertexIndices = Select3D.polylineDisplayVertexIndices;
  pre_Selection_vertexDisplayMarkers = Select3D.vertexDisplayMarkers;
  pre_Selection_polylineDisplayVertices = Select3D.polylineDisplayVertices;

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

  react.applyLandLoadMesh.run(pre_Terrain_loadMesh ? 1 : 0, Terrain.loadMesh ? 1 : 0);

  react.applyLandLoadTextures.run(pre_Terrain_loadTextures ? 1 : 0, Terrain.loadTextures ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_cameraDisplayFrustum ? 1 : 0, Select3D.cameraDisplayFrustum ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_sectionDisplayEdges ? 1 : 0, Select3D.sectionDisplayEdges ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_solidDisplayEdges ? 1 : 0, Select3D.solidDisplayEdges ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_terrainDisplayVertices ? 1 : 0, Select3D.terrainDisplayVertices ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_model1DDisplayBounds ? 1 : 0, Select3D.model1DDisplayBounds ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_model2DDisplayBounds ? 1 : 0, Select3D.model2DDisplayBounds ? 1 : 0);

  react.softSelectionChanged.run(pre_Selection_softSelectionFalloffPower, Select3D.softSelectionFalloffPower);

  react.softSelectionChanged.run(pre_Selection_softSelectionFalloffRadius, Select3D.softSelectionFalloffRadius);

  react.selectionChangedOnly.run(pre_Selection_pivotAlignmentX, Select3D.pivotAlignmentX);

  react.selectionChangedOnly.run(pre_Selection_pivotAlignmentY, Select3D.pivotAlignmentY);

  react.selectionChangedOnly.run(pre_Selection_pivotAlignmentZ, Select3D.pivotAlignmentZ);

  react.applyPosValue.run(pre_Selection_position, Select3D.position);
  react.applyRotValue.run(pre_Selection_rotation, Select3D.rotation);
  react.applyScaleValue.run(pre_Selection_scale, Select3D.scale);

  react.viewChangedOnly.run(pre_Selection_pivotDisplayReference ? 1 : 0, Select3D.pivotDisplayReference ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_groupDisplayPivot ? 1 : 0, Select3D.groupDisplayPivot ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_groupDisplayEdges ? 1 : 0, Select3D.groupDisplayEdges ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_groupDisplayBox ? 1 : 0, Select3D.groupDisplayBox ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_faceDisplayEdges ? 1 : 0, Select3D.faceDisplayEdges ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_faceDisplayVertexIndices ? 1 : 0, Select3D.faceDisplayVertexIndices ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_polylineDisplayVertexIndices ? 1 : 0, Select3D.polylineDisplayVertexIndices ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_vertexDisplayMarkers ? 1 : 0, Select3D.vertexDisplayMarkers ? 1 : 0);

  react.viewChangedOnly.run(pre_Selection_polylineDisplayVertices ? 1 : 0, Select3D.polylineDisplayVertices ? 1 : 0);

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

boolean pre_Terrain_loadMesh;
boolean pre_Terrain_loadTextures;

float pre_LocationLAT;
float pre_LocationLON;

boolean pre_WORLD_autoView;

boolean pre_Selection_model1DDisplayBounds;
boolean pre_Selection_model2DDisplayBounds;

boolean pre_Selection_solidDisplayEdges;
boolean pre_Selection_sectionDisplayEdges;
boolean pre_Selection_cameraDisplayFrustum;

boolean pre_Selection_terrainDisplayVertices;

float pre_Selection_softSelectionFalloffPower;
float pre_Selection_softSelectionFalloffRadius;

float pre_Selection_position;
float pre_Selection_rotation;
float pre_Selection_scale;

int pre_Selection_pivotAlignmentX;
int pre_Selection_pivotAlignmentY;
int pre_Selection_pivotAlignmentZ;

boolean pre_Selection_pivotDisplayReference;

boolean pre_Selection_groupDisplayPivot;
boolean pre_Selection_groupDisplayEdges;
boolean pre_Selection_groupDisplayBox;

boolean pre_Selection_faceDisplayEdges;
boolean pre_Selection_faceDisplayVertexIndices;
boolean pre_Selection_polylineDisplayVertexIndices;
boolean pre_Selection_vertexDisplayMarkers;
boolean pre_Selection_polylineDisplayVertices;

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
