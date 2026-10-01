class UI_rollout {

  final static String CLASS_STAMP = "UI_rollout";

  int cX = 2 * pixel_W;
  int cY = pixel_A + pixel_B + 0;
  int dX = int(27 * MessageSize);
  int dY = 2 * pixel_H;
  float view_R = float(dY) / float(dX);
  float view_S = MessageSize / 12;

  boolean update = true;
  boolean include = true;

  // Spinner text-edit state: which spinner (identified by its caption) is
  // currently accepting keyboard input, and the value being typed so far.
  boolean editActive = false;
  String editCaption = "";
  String editText = "";
  int editCursor = 0;
  boolean editCommit = false;
  boolean editStateChanged = false;

  // Captions of every spinner drawn on the current page, in on-screen
  // order, rebuilt each drawView() pass. Used by Tab / Shift+Tab to know
  // which spinner comes next/previous.
  ArrayList<String> spinnerOrderThisPass = new ArrayList<String>();

  // Set by Tab / Shift+Tab to request that a specific spinner (identified
  // by caption) become the new edit target. The actual switch happens once
  // that spinner's own _Spinner() call is reached, since only there is its
  // live value known (needed to seed the typed text).
  String editPendingCaption = null;

  void buildAllRollouts () {

    PARENT_LOCATION = pushParent("Location & Data");
    CHILD_LOCATION_POINT = pushChild("Point");
    CHILD_LOCATION_STATIONS = pushChild("Stations");

    PARENT_PERIOD_SCENARIOS = pushParent("Period & Scenarios");
    CHILD_PERIOD_TIME = pushChild("Time");
    CHILD_PERIOD_RANGES = pushChild("Ranges");
    CHILD_PERIOD_FILTERS = pushChild("Filters");

    PARENT_GEOMETRY = pushParent("Geometry & Space");
    CHILD_GEOMETRY_CREATE = pushChild("Create");
    CHILD_GEOMETRY_MODIFY = pushChild("Modify");
    CHILD_GEOMETRY_SOLID = pushChild("Solid");
    CHILD_GEOMETRY_FRACTAL_TREE = pushChild("Fractal Tree");
    CHILD_GEOMETRY_ENVIRONMENT = pushChild("Environment");
    CHILD_GEOMETRY_VIEWPORT = pushChild("Viewport");
    CHILD_GEOMETRY_SIMULATION = pushChild("Simulation");
    CHILD_GEOMETRY_OTHER = pushChild("Other");

    PARENT_ILLUSTRATION = pushParent("Illustration Options");
    CHILD_ILLUSTRATION_2D_LAYERS = pushChild("2D-Layers");
    CHILD_ILLUSTRATION_2D_COLORS = pushChild("2D-Colors");
    CHILD_ILLUSTRATION_3D_SOLAR = pushChild("3D-Solar");
    CHILD_ILLUSTRATION_3D_SPATIAL = pushChild("3D-Spatial");
    CHILD_ILLUSTRATION_SELECTION = pushChild("Selection");

    PARENT_EXPORT = pushParent("Export Products");
    CHILD_EXPORT_DATA = pushChild("Data");
    CHILD_EXPORT_MEDIA = pushChild("Media");

    PARENT_POSTPROCESS = pushParent("Post-Processing");
    CHILD_POSTPROCESS_INTERPOLATION = pushChild("Interpolation");
    CHILD_POSTPROCESS_DEVELOPED = pushChild("Developed");
    CHILD_POSTPROCESS_IMPACTS = pushChild("Impacts");
  }

  int PARENT_PERIOD_SCENARIOS;
  int CHILD_PERIOD_TIME;
  int CHILD_PERIOD_RANGES;
  int CHILD_PERIOD_FILTERS;

  int PARENT_LOCATION;
  int CHILD_LOCATION_POINT;
  int CHILD_LOCATION_STATIONS;

  int PARENT_GEOMETRY;
  int CHILD_GEOMETRY_CREATE;
  int CHILD_GEOMETRY_MODIFY;
  int CHILD_GEOMETRY_SOLID;
  int CHILD_GEOMETRY_FRACTAL_TREE;
  int CHILD_GEOMETRY_ENVIRONMENT;
  int CHILD_GEOMETRY_VIEWPORT;
  int CHILD_GEOMETRY_SIMULATION;
  int CHILD_GEOMETRY_OTHER;

  int PARENT_ILLUSTRATION;
  int CHILD_ILLUSTRATION_2D_LAYERS;
  int CHILD_ILLUSTRATION_2D_COLORS;
  int CHILD_ILLUSTRATION_3D_SOLAR;
  int CHILD_ILLUSTRATION_3D_SPATIAL;
  int CHILD_ILLUSTRATION_SELECTION;

  int PARENT_POSTPROCESS;
  int CHILD_POSTPROCESS_INTERPOLATION;
  int CHILD_POSTPROCESS_DEVELOPED;
  int CHILD_POSTPROCESS_IMPACTS;

  int PARENT_EXPORT;
  int CHILD_EXPORT_DATA;
  int CHILD_EXPORT_MEDIA;

  ArrayList<ArrayList<String>> allRollouts = new ArrayList<ArrayList<String>>();
  int _lastParentIndex = -1; // which category pushChild() appends into
  int parent;
  int child;
  int[] selectedChildForParent;
  final static int FIRST_CHILD = 1;

  public UI_rollout () {
    buildAllRollouts();
    parent = PARENT_LOCATION; // default parent
    child = CHILD_LOCATION_POINT; // default child

    selectedChildForParent = new int[allRollouts.size()];
    for (int i = 0; i < selectedChildForParent.length; i++) {
      selectedChildForParent[i] = FIRST_CHILD;
    }
  }

  int pushParent (String label) {
    ArrayList<String> category = new ArrayList<String>();
    category.add(label); // index 0 holds the category's own display label
    allRollouts.add(category);

    _lastParentIndex = allRollouts.size() - 1;
    return _lastParentIndex;
  }

  int pushChild (String label) {
    ArrayList<String> category = allRollouts.get(_lastParentIndex);
    category.add(label);

    return category.size() - 1;
  }

  // Registers command-line equivalents of this rollout's spinners into
  // allActions, so they can be driven from runScript.pde (e.g. "start_day
  // 15") the same way menu items are. This lives outside of draw()'s
  // this.child == ... condition blocks: it is called once, from
  // build_allActions() in actions.pde, after allActions has been created -
  // not once per frame/spinner-draw.
  //
  // Each registration mirrors one this.Spinner(...) call: same min/max/step
  // and the same update1/update2/update3 flags (which of STUDY, WIN3D,
  // WORLD get revised when the value actually changes).
  void registerSpinnerActions () {

    // One vm.<name>(0) call per ValueModifier.pde method - see that file
    // for each one's caption, bounds, update flags and (where relevant)
    // OnChange follow-up.

    vm.endDay(0);
    vm.dayIncrement(0);
    vm.daysMergedCount(0);
    vm.date(0);
    vm.day(0);
    vm.month(0);
    vm.year(0);
    vm.startHour(0);
    vm.endHour(0);
    vm.sampleYearStart(0);
    vm.sampleYearEnd(0);
    vm.sampleMemberStart(0);
    vm.sampleMemberEnd(0);
    vm.sampleStationStart(0);
    vm.sampleStationEnd(0);
    vm.ensembleObservationMaxDays(0);
    vm.skyScenarioSetting(0);
    vm.temporalFilterSetting(0);
    vm.LocationLatitude(0);
    vm.LocationLongitude(0);
    vm.climateTypicalYearDisplayAll(0);
    vm.climateTypicalYearDisplayNear(0);
    vm.climateEngineeringDisplayAll(0);
    vm.climateEngineeringDisplayNear(0);
    vm.climateArchiveDisplayAll(0);
    vm.climateArchiveDisplayNear(0);
    vm.ensembleObservationDisplayAll(0);
    vm.ensembleObservationDisplayNear(0);
    vm.ensembleForecastDisplayAll(0);
    vm.ensembleForecastDisplayNear(0);
    vm.addToLastGroup(0);
    vm.defaultMaterial(0);
    vm.defaultTessellation(0);
    vm.defaultLayer(0);
    vm.defaultVisibility(0);
    vm.defaultWeight(0);
    vm.defaultClosed(0);
    vm.creatorOrientation(0);
    vm.creatorLength(0);
    vm.creatorWidth(0);
    vm.creatorHeight(0);
    vm.creatorVolume(0);
    vm.creatorSnapModeIndex(0);
    vm.creatorSphereDegree(0);
    vm.creatorCylinderDegree(0);
    vm.creatorPolygonDegree(0);
    vm.creatorParametricTypeIndex(0);
    vm.creatorPersonTypeIndex(0);
    vm.creatorPlantTypeIndex(0);
    vm.modifierOpeningDepth(0);
    vm.modifierOpeningArea(0);
    vm.modifierOpeningDeviation(0);
    vm.modifierTessellateRows(0);
    vm.modifierTessellateColumns(0);
    vm.modifierOffsetAmount(0);
    vm.modifierWeldThreshold(0);
    vm.softSelectionFalloffPower(0);
    vm.softSelectionFalloffRadius(0);
    vm.positionVectorIndex(0);
    vm.rotationVectorIndex(0);
    vm.scaleVectorIndex(0);
    vm.positionSelection(0);
    vm.rotationSelection(0);
    vm.scaleSelection(0);
    vm.pivotAlignmentX(0);
    vm.pivotAlignmentY(0);
    vm.pivotAlignmentZ(0);
    vm.creatorUniformSuperellipsoidPower(0);
    vm.creatorSuperellipsoidPowerX(0);
    vm.creatorSuperellipsoidPowerY(0);
    vm.creatorSuperellipsoidPowerZ(0);
    vm.creatorModel1DTypeIndex(0);
    vm.creatorModel1DDegreeMax(0);
    vm.creatorModel1DSeed(0);
    vm.creatorModel1DTrunkSize(0);
    vm.creatorModel1DLeafSize(0);
    vm.creator_Model1D_BranchTilt(0);
    vm.creator_Model1D_BranchTwist(0);
    vm.creator_Model1D_BranchRatio(0);
    vm.creator_Model1D_TreeBase(0);
    vm.Terrain_loadTextures(0);
    vm.Terrain_loadMesh(0);
    vm.Terrain_skipStart(0);
    vm.Terrain_skipEnd(0);
    vm.Terrain_displaySurface(0);
    vm.Terrain_displayTexture(0);
    vm.Terrain_displayPoints(0);
    vm.displayDepth(0);
    vm.Model2Ds_displayAll(0);
    vm.Model1Ds_displayAll(0);
    vm.Model1Ds_displayLeaves(0);
    vm.Polylines_displayAll(0);
    vm.Faces_displayAll(0);
    vm.Solids_displayAll(0);
    vm.Sections_displayAll(0);
    vm.WindRoses_displayImage(0);
    vm.WindRoses_planeSize(0);
    vm.Sky3D_displaySurface(0);
    vm.Sun3D_displayPath(0);
    vm.Sun3D_displayPattern(0);
    vm.currentCameraIndex(0);
    vm.cameraClipNear(0);
    vm.cameraClipFar(0);
    vm.Create3D_displayVertices(0);
    vm.Create3D_displayEdges(0);
    vm.Create3D_showNormalLines(0);
    vm.Cameras_displayAll(0);
    vm.impactDisplayDay(0);
    vm.SolarImpacts_displayImage(0);
    vm.SolidImpacts_displayImage(0);
    vm.SolarImpacts_sectionType(0);
    vm.SolidImpacts_sectionType(0);
    vm.SolidImpacts_grade(0);
    vm.SolidImpacts_power(0);
    vm.SolidImpacts_r(0);
    vm.SolidImpacts_z(0);
    vm.SolidImpacts_positionStep(0);
    vm.SolidImpacts_u(0);
    vm.SolidImpacts_v(0);
    vm.SolidImpacts_x(0);
    vm.SolidImpacts_y(0);
    vm.SolidImpacts_windSpeed(0);
    vm.SolidImpacts_windDirection(0);
    vm.SolidImpacts_processSubDivisions(0);
    vm.SolidImpacts_displayPoints(0);
    vm.SolidImpacts_displayLines(0);
    vm.WindFlows_displayAll(0);
    vm.Create3D_displayTessellation(0);
    vm.Terrain_displayTessellation(0);
    vm.Sky3D_displayTessellation(0);
    vm.Sky3D_radius(0);
    vm.Tropo3D_displaySurface(0);
    vm.Tropo3D_displayTexture(0);
    vm.Earth3D_displaySurface(0);
    vm.Earth3D_displayTexture(0);
    vm.Earth3D_levelOfDetail(0);
    vm.Moon3D_displaySurface(0);
    vm.Moon3D_displayTexture(0);
    vm.Moon3D_fitInSkyDome(0);
    vm.Sun3D_displaySurface(0);
    vm.Sun3D_displayTexture(0);
    vm.Sun3D_fitInSkyDome(0);
    vm.celestialMagnification(0);
    vm.overallScale(0);
    vm.plotLayoutIndex(0);
    vm.verticalUnitScale(0);
    vm.showRawLines(0);
    vm.showStatisticalRanges(0);
    vm.showStatistics(0);
    vm.showProbabilities(0);
    vm.probabilityWidthInterval(0);
    vm.probabilityHeightInterval(0);
    vm.Study_activePaletteClr(0);
    vm.Study_activePaletteDir(0);
    vm.Study_activePaletteMlt(0);
    vm.Study_passivePaletteClr(0);
    vm.Study_passivePaletteDir(0);
    vm.Study_passivePaletteMlt(0);
    vm.statisticalRangesColorScaleIndex(0);
    vm.statisticalRangesColorScaleDirection(0);
    vm.statisticalRangesColorScaleFactor(0);
    vm.probabilitiesColorScaleIndex(0);
    vm.probabilitiesColorScaleDirection(0);
    vm.probabilitiesColorScaleFactor(0);
    vm.opacityPercentage(0);
    vm.Faces_activePaletteClr(0);
    vm.Faces_activePaletteDir(0);
    vm.Faces_activePaletteMlt(0);
    vm.Faces_passivePaletteClr(0);
    vm.Faces_passivePaletteDir(0);
    vm.Faces_passivePaletteMlt(0);
    vm.Sky3D_activePaletteClr(0);
    vm.Sky3D_activePaletteDir(0);
    vm.Sky3D_activePaletteMlt(0);
    vm.Sky3D_passivePaletteClr(0);
    vm.Sky3D_passivePaletteDir(0);
    vm.Sky3D_passivePaletteMlt(0);
    vm.Sun3D_activePaletteClr(0);
    vm.Sun3D_activePaletteDir(0);
    vm.Sun3D_activePaletteMlt(0);
    vm.Sun3D_passivePaletteClr(0);
    vm.Sun3D_passivePaletteDir(0);
    vm.Sun3D_passivePaletteMlt(0);
    vm.Solids_paletteClr(0);
    vm.Solids_paletteDir(0);
    vm.Solids_paletteMlt(0);
    vm.Terrain_paletteClr(0);
    vm.Terrain_paletteDir(0);
    vm.Terrain_paletteMlt(0);
    vm.WindFlows_paletteClr(0);
    vm.WindFlows_paletteDir(0);
    vm.WindFlows_paletteMlt(0);
    vm.groupDisplayPivot(0);
    vm.pivotDisplayReference(0);
    vm.groupDisplayBox(0);
    vm.groupDisplayEdges(0);
    vm.faceDisplayEdges(0);
    vm.faceDisplayVertexSelection(0);
    vm.polylineDisplayVertexSelection(0);
    vm.vertexDisplayMarkers(0);
    vm.polylineDisplayVertices(0);
    vm.model2DDisplayBounds(0);
    vm.model1DDisplayBounds(0);
    vm.solidDisplayEdges(0);
    vm.sectionDisplayEdges(0);
    vm.cameraDisplayFrustum(0);
    vm.terrainDisplayVertices(0);
    vm.interpolationWeight(0);
    vm.climateBasedSolarForecast(0);
    vm.climateBasedWeatherForecast(0);
    vm.developLayerOption(0);
    vm.developLayerInterval(0);
    vm.developLayerAngleInclination(0);
    vm.developLayerAngleOrientation(0);
    vm.currentDataSource(0);
    vm.impactLayerIndex(0);
    vm.rawLinesExporter(0);
    vm.normalLinesExporter(0);
    vm.probabilitiesExporter(0);
    vm.exporterScale(0);
    vm.exporterYaxisUp(0);
    vm.exporterPrecisionVertex(0);
    vm.exporterPrecisionVertexTexture(0);
    vm.exporterMaintainPolygons(0);
    vm.exporterMaterialLibrary(0);
    vm.exporterDoubleSided(0);
    vm.exporterColorScaleResolution(0);
    vm.Record_SolidImpact_in_JPG(0);
    vm.Record_SolidImpact_in_PDF(0);
    vm.Record_Solar_Analysis_in_JPG(0);
    vm.WindRoses_imageResolution(0);
  }

  void draw () {

    this.editStateChanged = false;
    this.spinnerOrderThisPass.clear();

    stroke(255);
    fill(255);
    strokeWeight(0);
    rect(this.cX, this.cY, this.dX, this.dY);


    float h = 20 * this.view_S;

    X_control = this.cX;
    Y_control = this.cY;

    X_control += 307.5 * this.view_S;
    Y_control += 7.5 * this.view_S;

    if (this.parent >= allRollouts.size()) {
      this.parent = allRollouts.size() - 1;
    }

    if (this.child >= allRollouts.get(this.parent).size()) {
      this.child = allRollouts.get(this.parent).size() - 1;
    }

    if (this.parent < allRollouts.size()) {

      for (int i = 0; i < allRollouts.size(); i++) {

        float cx = this.cX + (170 * (i % 2) + 5) * this.view_S;
        float cy = Y_control;
        float cr = 6.75 * this.view_S;

        textAlign(LEFT, CENTER);

        if (!this.editActive && isInside(X_clicked, Y_clicked, cx, cy - cr, cx + 150 * this.view_S, cy + cr)) {
          this.parent = i;
          this.child = selectedChildForParent[i];

          this.revise();
        }

        if (i == this.parent) {
          strokeWeight(2);
          stroke(63);
          fill(191);
          rect(cx - 2.5 * this.view_S, cy - 5 * this.view_S, 150 * this.view_S, 2 * 7.5 * this.view_S);
          strokeWeight(0);

          stroke(0);
          fill(0);
          textSize(15 * this.view_S);
        } else {
          stroke(127);
          fill(127);
          textSize(15 * this.view_S);
        }

        text(nf(i + 1, 0) + ":" + allRollouts.get(i).get(0), cx, cy);

        if (i % 2 == 1) Y_control += 15 * this.view_S;
      }

      noStroke();
      fill(127);
      rect(this.cX, Y_control, this.dX, 17.5 * ceil((allRollouts.get(this.parent).size() - 1) / 3.0) * this.view_S);

      Y_control += 5 * this.view_S;

      for (int i = 1; i < allRollouts.get(this.parent).size(); i++) {

        float cr = 6.75 * this.view_S;
        float cx = this.cX + (100 * ((i - 1) % 3) + 10) * this.view_S;
        float cy = Y_control + 0.5 * cr;

        textAlign(LEFT, CENTER);

        if (!this.editActive && isInside(X_clicked, Y_clicked, cx, cy - cr, cx + 100 * this.view_S, cy + cr)) {
          this.child = i;
          selectedChildForParent[this.parent] = i; // remember this choice for next time this category is opened

          this.revise();
        }

        if (i == this.child) {
          noStroke();
          fill(63);
          rect(cx, cy - cr, 100 * this.view_S, cr * 2);

          stroke(255, 0, 0);
          fill(255, 127, 0);
          textSize(15 * this.view_S);
        } else {
          stroke(255);
          fill(255);
          textSize(12.5 * this.view_S);
        }

        text("[" + nf(i, 0) + "]" + allRollouts.get(this.parent).get(i), cx, cy);

        if (i % 3 == 0) Y_control += 15 * this.view_S;
      }

      if (allRollouts.get(this.parent).size() % 3 != 1) Y_control += 15 * this.view_S;

      Y_control += 15 * this.view_S;
    }



    if (this.parent == PARENT_PERIOD_SCENARIOS) {

      if (this.child == CHILD_PERIOD_TIME) {
        STUDY.endDay = vm.endDay(1);
        STUDY.dayIncrement = vm.dayIncrement(1);
        STUDY.daysMergedCount = vm.daysMergedCount(1);
        TIME.date = vm.date(1);

        TIME.day = vm.day(1);
        TIME.month = vm.month(1);
        TIME.year = vm.year(1);
      }

      if (this.child == CHILD_PERIOD_RANGES) {
        STUDY.startHour = vm.startHour(1);
        STUDY.endHour = vm.endHour(1);
        sampleYearStart = vm.sampleYearStart(1);
        sampleYearEnd = vm.sampleYearEnd(1);
        sampleMemberStart = vm.sampleMemberStart(1);
        sampleMemberEnd = vm.sampleMemberEnd(1);
        sampleStationStart = vm.sampleStationStart(1);
        sampleStationEnd = vm.sampleStationEnd(1);
        ensembleObservationMaxDays = vm.ensembleObservationMaxDays(1);
      }

      if (this.child == CHILD_PERIOD_FILTERS) {

        STUDY.skyScenarioSetting = vm.skyScenarioSetting(1);
        STUDY.temporalFilterSetting = vm.temporalFilterSetting(1);
      }
    } else if (this.parent == PARENT_LOCATION) {


      if (this.child == CHILD_LOCATION_POINT) {
        LocationLAT = vm.LocationLatitude(1);
        LocationLON = vm.LocationLongitude(1);
      }

      if (this.child == CHILD_LOCATION_STATIONS) {

        WORLD.climateTypicalYearDisplayAll = vm.climateTypicalYearDisplayAll(1);
        WORLD.climateTypicalYearDisplayNear = vm.climateTypicalYearDisplayNear(1);
        WORLD.climateEngineeringDisplayAll = vm.climateEngineeringDisplayAll(1);
        WORLD.climateEngineeringDisplayNear = vm.climateEngineeringDisplayNear(1);
        WORLD.climateArchiveDisplayAll = vm.climateArchiveDisplayAll(1);
        WORLD.climateArchiveDisplayNear = vm.climateArchiveDisplayNear(1);
        WORLD.ensembleObservationDisplayAll = vm.ensembleObservationDisplayAll(1);
        WORLD.ensembleObservationDisplayNear = vm.ensembleObservationDisplayNear(1);
        WORLD.ensembleForecastDisplayAll = vm.ensembleForecastDisplayAll(1);
        WORLD.ensembleForecastDisplayNear = vm.ensembleForecastDisplayNear(1);
      }
    } else if (this.parent == PARENT_GEOMETRY) {
      if (this.child == CHILD_GEOMETRY_CREATE) {

        addToLastGroup = vm.addToLastGroup(1);
        User3D.defaultMaterial = vm.defaultMaterial(1);
        User3D.defaultTessellation = vm.defaultTessellation(1);
        User3D.defaultLayer = vm.defaultLayer(1);
        User3D.defaultVisibility = vm.defaultVisibility(1);
        User3D.defaultWeight = vm.defaultWeight(1);
        User3D.defaultClosed = vm.defaultClosed(1);
        User3D.creatorOrientation = vm.creatorOrientation(1);
        User3D.creatorLength = vm.creatorLength(1);
        User3D.creatorWidth = vm.creatorWidth(1);
        User3D.creatorHeight = vm.creatorHeight(1);
        User3D.creatorVolume = vm.creatorVolume(1);
        User3D.creatorSnapModeIndex = vm.creatorSnapModeIndex(1);
        User3D.creatorSphereDegree = vm.creatorSphereDegree(1);
        User3D.creatorCylinderDegree = vm.creatorCylinderDegree(1);
        User3D.creatorPolygonDegree = vm.creatorPolygonDegree(1);
        User3D.creatorParametricTypeIndex = vm.creatorParametricTypeIndex(1);
        User3D.creatorPersonTypeIndex = vm.creatorPersonTypeIndex(1);
        User3D.creatorPlantTypeIndex = vm.creatorPlantTypeIndex(1);
      }

      if (this.child == CHILD_GEOMETRY_MODIFY) {

        User3D.modifierOpeningDepth = vm.modifierOpeningDepth(1);
        User3D.modifierOpeningArea = vm.modifierOpeningArea(1);
        User3D.modifierOpeningDeviation = vm.modifierOpeningDeviation(1);
        User3D.modifierTessellateRows = vm.modifierTessellateRows(1);
        User3D.modifierTessellateColumns = vm.modifierTessellateColumns(1);
        User3D.modifierOffsetAmount = vm.modifierOffsetAmount(1);
        User3D.modifierWeldThreshold = vm.modifierWeldThreshold(1);
        Select3D.softSelectionFalloffPower = vm.softSelectionFalloffPower(1);
        Select3D.softSelectionFalloffRadius = vm.softSelectionFalloffRadius(1);
        Select3D.positionVectorIndex = vm.positionVectorIndex(1);
        Select3D.rotationVectorIndex = vm.rotationVectorIndex(1);
        Select3D.scaleVectorIndex = vm.scaleVectorIndex(1);
        Select3D.position = vm.positionSelection(1);
        Select3D.rotation = vm.rotationSelection(1);
        Select3D.scale = vm.scaleSelection(1);
        Select3D.pivotAlignmentX = vm.pivotAlignmentX(1);
        Select3D.pivotAlignmentY = vm.pivotAlignmentY(1);
        Select3D.pivotAlignmentZ = vm.pivotAlignmentZ(1);
      }

      if (this.child == CHILD_GEOMETRY_SOLID) {
        User3D.creatorUniformSuperellipsoidPower = vm.creatorUniformSuperellipsoidPower(1);
        User3D.creatorSuperellipsoidPowerX = vm.creatorSuperellipsoidPowerX(1);
        User3D.creatorSuperellipsoidPowerY = vm.creatorSuperellipsoidPowerY(1);
        User3D.creatorSuperellipsoidPowerZ = vm.creatorSuperellipsoidPowerZ(1);
      }


      if (this.child == CHILD_GEOMETRY_FRACTAL_TREE) {

        User3D.creatorModel1DTypeIndex = vm.creatorModel1DTypeIndex(1);
        User3D.creatorModel1DDegreeMax = vm.creatorModel1DDegreeMax(1);
        User3D.creatorModel1DSeed = vm.creatorModel1DSeed(1);
        User3D.creatorModel1DTrunkSize = vm.creatorModel1DTrunkSize(1);
        User3D.creatorModel1DLeafSize = vm.creatorModel1DLeafSize(1);
        User3D.creator_Model1D_BranchTilt = vm.creator_Model1D_BranchTilt(1);
        User3D.creator_Model1D_BranchTwist = vm.creator_Model1D_BranchTwist(1);
        User3D.creator_Model1D_BranchRatio = vm.creator_Model1D_BranchRatio(1);
        User3D.creator_Model1D_TreeBase = vm.creator_Model1D_TreeBase(1);
      }

      if (this.child == CHILD_GEOMETRY_ENVIRONMENT) {

        Terrain.loadTextures = vm.Terrain_loadTextures(1);
        Terrain.loadMesh = vm.Terrain_loadMesh(1);
        Terrain.skipStart = vm.Terrain_skipStart(1);
        Terrain.skipEnd = vm.Terrain_skipEnd(1);
        Terrain.displaySurface = vm.Terrain_displaySurface(1);
        Terrain.displayTexture = vm.Terrain_displayTexture(1);
        Terrain.displayPoints = vm.Terrain_displayPoints(1);
        Terrain.displayDepth = vm.displayDepth(1);
        allModel2Ds.displayAll = vm.Model2Ds_displayAll(1);
        allModel1Ds.displayAll = vm.Model1Ds_displayAll(1);
        allModel1Ds.displayLeaves = vm.Model1Ds_displayLeaves(1);
        allPolylines.displayAll = vm.Polylines_displayAll(1);
        allFaces.displayAll = vm.Faces_displayAll(1);
        allSolids.displayAll = vm.Solids_displayAll(1);
        allSections.displayAll = vm.Sections_displayAll(1);
        allWindRoses.displayImage = vm.WindRoses_displayImage(1);
        allWindRoses.planeSize = vm.WindRoses_planeSize(1);
        allWindRoses.imageResolution = vm.WindRoses_imageResolution(1);



        Sky3D.displaySurface = vm.Sky3D_displaySurface(1);
        Sun3D.displayPath = vm.Sun3D_displayPath(1);
        Sun3D.displayPattern = vm.Sun3D_displayPattern(1);
      }


      if (this.child == CHILD_GEOMETRY_VIEWPORT) {

        WIN3D.currentCameraIndex = vm.currentCameraIndex(1);
        WIN3D.cameraClipNear = vm.cameraClipNear(1);
        WIN3D.cameraClipFar = vm.cameraClipFar(1);
        allPoints.displayAll = vm.Create3D_displayVertices(1);
        allFaces.displayEdges = vm.Create3D_displayEdges(1);
        allFaces.showNormalLines = vm.Create3D_showNormalLines(1);
        allCameras.displayAll = vm.Cameras_displayAll(1);
      }


      if (this.child == CHILD_GEOMETRY_SIMULATION) {

        impactDisplayDay = vm.impactDisplayDay(1);
        allSolarImpacts.displayImage = vm.SolarImpacts_displayImage(1);
        allSolidImpacts.displayImage = vm.SolidImpacts_displayImage(1);
        allSolarImpacts.sectionType = vm.SolarImpacts_sectionType(1);
        allSolidImpacts.sectionType = vm.SolidImpacts_sectionType(1);
        allSolidImpacts.Grade = vm.SolidImpacts_grade(1);
        allSolidImpacts.Power = vm.SolidImpacts_power(1);
        allSolidImpacts.R[allSolidImpacts.sectionType] = vm.SolidImpacts_r(1);
        allSolidImpacts.Z[allSolidImpacts.sectionType] = vm.SolidImpacts_z(1);
        allSolidImpacts.positionStep = vm.SolidImpacts_positionStep(1);
        allSolidImpacts.U[allSolidImpacts.sectionType] = vm.SolidImpacts_u(1);
        allSolidImpacts.V[allSolidImpacts.sectionType] = vm.SolidImpacts_v(1);
        allSolidImpacts.X[allSolidImpacts.sectionType] = vm.SolidImpacts_x(1);
        allSolidImpacts.Y[allSolidImpacts.sectionType] = vm.SolidImpacts_y(1);
        allSolidImpacts.WindSpeed = vm.SolidImpacts_windSpeed(1);
        allSolidImpacts.WindDirection = vm.SolidImpacts_windDirection(1);
        allSolidImpacts.Process_subDivisions = vm.SolidImpacts_processSubDivisions(1);
        allSolidImpacts.displayPoints = vm.SolidImpacts_displayPoints(1);
        allSolidImpacts.displayLines = vm.SolidImpacts_displayLines(1);
        allWindFlows.displayAll = vm.WindFlows_displayAll(1);
      }

      if (this.child == CHILD_GEOMETRY_OTHER) {

        allFaces.displayTessellation = vm.Create3D_displayTessellation(1);
        Terrain.displayTessellation = vm.Terrain_displayTessellation(1);
        Sky3D.displayTessellation = vm.Sky3D_displayTessellation(1);
          Sky3D.radius = vm.Sky3D_radius(1);
        Tropo3D.displaySurface = vm.Tropo3D_displaySurface(1);
        Tropo3D.displayTexture = vm.Tropo3D_displayTexture(1);
        Earth3D.displaySurface = vm.Earth3D_displaySurface(1);
        Earth3D.displayTexture = vm.Earth3D_displayTexture(1);
        Earth3D.levelOfDetail = vm.Earth3D_levelOfDetail(1);
        Earth3D.recomputeLevelOfDetailDependents();

        Moon3D.displaySurface = vm.Moon3D_displaySurface(1);
        Moon3D.displayTexture = vm.Moon3D_displayTexture(1);
        Moon3D.fitInSkyDome = vm.Moon3D_fitInSkyDome(1);
        Sun3D.displaySurface = vm.Sun3D_displaySurface(1);
        Sun3D.displayTexture = vm.Sun3D_displayTexture(1);
        Sun3D.fitInSkyDome = vm.Sun3D_fitInSkyDome(1);
        celestialMagnification = vm.celestialMagnification(1);
        overallScale = vm.overallScale(1);
      }

    } else if (this.parent == PARENT_ILLUSTRATION) {

      if (this.child == CHILD_ILLUSTRATION_2D_LAYERS) {
        STUDY.plotLayoutIndex = vm.plotLayoutIndex(1);
        STUDY.verticalUnitScale = vm.verticalUnitScale(1);
        STUDY.showRawLines = vm.showRawLines(1);
        STUDY.showStatisticalRanges = vm.showStatisticalRanges(1);
        STUDY.showNormalLines = vm.showStatistics(1);
        STUDY.showProbabilities = vm.showProbabilities(1);
        STUDY.probabilityWidthInterval = vm.probabilityWidthInterval(1);
        STUDY.probabilityHeightInterval = vm.probabilityHeightInterval(1);
      }

      if (this.child == CHILD_ILLUSTRATION_2D_COLORS) {

        STUDY.activeColorScaleIndex = vm.Study_activePaletteClr(1);
        STUDY.activeColorScaleDirection = vm.Study_activePaletteDir(1);
        STUDY.activeColorScaleFactor = vm.Study_activePaletteMlt(1);
        STUDY.passiveColorScaleIndex = vm.Study_passivePaletteClr(1);
        STUDY.passiveColorScaleDirection = vm.Study_passivePaletteDir(1);
        STUDY.passiveColorScaleFactor = vm.Study_passivePaletteMlt(1);
        STUDY.statisticalRangesColorScaleIndex = vm.statisticalRangesColorScaleIndex(1);
        STUDY.statisticalRangesColorScaleDirection = vm.statisticalRangesColorScaleDirection(1);
        STUDY.statisticalRangesColorScaleFactor = vm.statisticalRangesColorScaleFactor(1);
        STUDY.probabilitiesColorScaleIndex = vm.probabilitiesColorScaleIndex(1);
        STUDY.probabilitiesColorScaleDirection = vm.probabilitiesColorScaleDirection(1);
        STUDY.probabilitiesColorScaleFactor = vm.probabilitiesColorScaleFactor(1);
        STUDY.opacityPercentage = vm.opacityPercentage(1);
      }

      if (this.child == CHILD_ILLUSTRATION_3D_SOLAR) {

        allFaces.activeColorScaleIndex = vm.Faces_activePaletteClr(1);
        allFaces.activeColorScaleDirection = vm.Faces_activePaletteDir(1);
        allFaces.activeColorScaleFactor = vm.Faces_activePaletteMlt(1);
        allFaces.passiveColorScaleIndex = vm.Faces_passivePaletteClr(1);
        allFaces.passiveColorScaleDirection = vm.Faces_passivePaletteDir(1);
        allFaces.passiveColorScaleFactor = vm.Faces_passivePaletteMlt(1);
        Sky3D.activeColorScaleIndex = vm.Sky3D_activePaletteClr(1);
        Sky3D.activeColorScaleDirection = vm.Sky3D_activePaletteDir(1);
        Sky3D.activeColorScaleFactor = vm.Sky3D_activePaletteMlt(1);
        Sky3D.passiveColorScaleIndex = vm.Sky3D_passivePaletteClr(1);
        Sky3D.passiveColorScaleDirection = vm.Sky3D_passivePaletteDir(1);
        Sky3D.passiveColorScaleFactor = vm.Sky3D_passivePaletteMlt(1);
        Sun3D.activeColorScaleIndex = vm.Sun3D_activePaletteClr(1);
        Sun3D.activeColorScaleDirection = vm.Sun3D_activePaletteDir(1);
        Sun3D.activeColorScaleFactor = vm.Sun3D_activePaletteMlt(1);
        Sun3D.passiveColorScaleIndex = vm.Sun3D_passivePaletteClr(1);
        Sun3D.passiveColorScaleDirection = vm.Sun3D_passivePaletteDir(1);
        Sun3D.passiveColorScaleFactor = vm.Sun3D_passivePaletteMlt(1);
      }




      if (this.child == CHILD_ILLUSTRATION_3D_SPATIAL) {

        allSolids.colorScaleIndex = vm.Solids_paletteClr(1);
        allSolids.colorScaleDirection = vm.Solids_paletteDir(1);
        allSolids.colorScaleFactor = vm.Solids_paletteMlt(1);
        Terrain.colorScaleIndex = vm.Terrain_paletteClr(1);
        Terrain.colorScaleDirection = vm.Terrain_paletteDir(1);
        Terrain.colorScaleFactor = vm.Terrain_paletteMlt(1);
        allWindFlows.colorScaleIndex = vm.WindFlows_paletteClr(1);
        allWindFlows.colorScaleDirection = vm.WindFlows_paletteDir(1);
        allWindFlows.colorScaleFactor = vm.WindFlows_paletteMlt(1);
      }


      if (this.child == CHILD_ILLUSTRATION_SELECTION) {

        Select3D.groupDisplayPivot = vm.groupDisplayPivot(1);
        Select3D.pivotDisplayReference = vm.pivotDisplayReference(1);
        Select3D.groupDisplayBox = vm.groupDisplayBox(1);
        Select3D.groupDisplayEdges = vm.groupDisplayEdges(1);
        Select3D.faceDisplayEdges = vm.faceDisplayEdges(1);
        Select3D.faceDisplayvertexSelection = vm.faceDisplayVertexSelection(1);
        Select3D.polylineDisplayvertexSelection = vm.polylineDisplayVertexSelection(1);
        Select3D.vertexDisplayMarkers = vm.vertexDisplayMarkers(1);
        Select3D.polylineDisplayVertices = vm.polylineDisplayVertices(1);
        Select3D.model2DDisplayBounds = vm.model2DDisplayBounds(1);
        Select3D.model1DDisplayBounds = vm.model1DDisplayBounds(1);
        Select3D.solidDisplayEdges = vm.solidDisplayEdges(1);
        Select3D.sectionDisplayEdges = vm.sectionDisplayEdges(1);
        Select3D.cameraDisplayFrustum = vm.cameraDisplayFrustum(1);
        Select3D.terrainDisplayVertices = vm.terrainDisplayVertices(1);
      }
    } else if (this.parent == PARENT_POSTPROCESS) {

      if (this.child == CHILD_POSTPROCESS_INTERPOLATION) {

        interpolationWeight = vm.interpolationWeight(1);
        climateBasedSolarForecast = vm.climateBasedSolarForecast(1);
        climateBasedWeatherForecast = vm.climateBasedWeatherForecast(1);
      }
      if (this.child == CHILD_POSTPROCESS_DEVELOPED) {
        developLayerOption = vm.developLayerOption(1);
        developLayerInterval = vm.developLayerInterval(1);
        developLayerAngleInclination = vm.developLayerAngleInclination(1);
        developLayerAngleOrientation = vm.developLayerAngleOrientation(1);
      }
      if (this.child == CHILD_POSTPROCESS_IMPACTS) {
        currentDataSource = vm.currentDataSource(1);
        STUDY.impactLayerIndex = vm.impactLayerIndex(1);
      }
    } else if (this.parent == PARENT_EXPORT) {

      if (this.child == CHILD_EXPORT_DATA) {

        STUDY.rawLinesExporter = vm.rawLinesExporter(1);
        STUDY.normalLinesExporter = vm.normalLinesExporter(1);
        STUDY.probabilitiesExporter = vm.probabilitiesExporter(1);
        User3D.exporterScale = vm.exporterScale(1);
        User3D.exporterYaxisUp = vm.exporterYaxisUp(1);
        User3D.exporterPrecisionVertex = vm.exporterPrecisionVertex(1);
        User3D.exporterPrecisionVertexTexture = vm.exporterPrecisionVertexTexture(1);
        User3D.exporterMaintainPolygons = vm.exporterMaintainPolygons(1);
        User3D.exporterMaterialLibrary = vm.exporterMaterialLibrary(1);
        User3D.exporterDoubleSided = vm.exporterDoubleSided(1);
        User3D.exporterColorScaleResolution = vm.exporterColorScaleResolution(1);
      }

      if (this.child == CHILD_EXPORT_MEDIA) {

        allSolidImpacts.record_IMG = vm.Record_SolidImpact_in_JPG(1);
        allSolidImpacts.record_PDF = vm.Record_SolidImpact_in_PDF(1);
        allSolarImpacts.record_IMG = vm.Record_Solar_Analysis_in_JPG(1);
      }

    }

    if (this.include) {
      if (isInside(X_clicked, Y_clicked, this.cX, this.cY, this.cX + this.dX, this.cY + this.dY)) {
        X_clicked = -1;
        Y_clicked = -1;
      }
    }

    if (this.editStateChanged) {
      this.draw();
    }
  }

  boolean Spinner (float x, float y, int update1, int update2, int update3, String caption, boolean v) {
    int min_v = 0;
    int max_v = 1;
    int stp_v = 1;
    int roundStep = Math.abs(stp_v);
    return (
      funcs.roundTo(
        this._Spinner(x, y, update1, update2, update3, caption, v ? 1.0 : 0.0, (float) min_v, (float) max_v, (float) stp_v),
        roundStep
      )
    ) > 0.5;
  }

  int Spinner (float x, float y, int update1, int update2, int update3, String caption, int v) {
    int min_v = 0;
    int max_v = 1;
    int stp_v = 1;
    int roundStep = Math.abs(stp_v);
    return int(
      funcs.roundTo(
        this._Spinner(x, y, update1, update2, update3, caption, (float) v, (float) min_v, (float) max_v, (float) stp_v),
        roundStep
      )
    );
  }

  int Spinner (float x, float y, int update1, int update2, int update3, String caption, int v, int min_v, int max_v, int stp_v) {
    int roundStep = Math.abs(stp_v);
    return int(
      funcs.roundTo(
        this._Spinner(x, y, update1, update2, update3, caption, (float) v, (float) min_v, (float) max_v, (float) stp_v),
        roundStep
      )
    );
  }

  int Spinner (float x, float y, int update1, int update2, int update3, String caption, int v, int min_v, int max_v, int stp_v, int roundStep) {
    return int(
      funcs.roundTo(
        this._Spinner(x, y, update1, update2, update3, caption, (float) v, (float) min_v, (float) max_v, (float) stp_v),
        roundStep
      )
    );
  }

  int Spinner (float x, float y, int update1, int update2, int update3, String caption, float v, int min_v, int max_v, int stp_v, int roundStep) {
    return int(
      funcs.roundTo(
        this._Spinner(x, y, update1, update2, update3, caption, v, (float) min_v, (float) max_v, (float) stp_v),
        roundStep
      )
    );
  }

  float Spinner (float x, float y, int update1, int update2, int update3, String caption, float v, float min_v, float max_v, float stp_v, float roundStep) {
    return (
      funcs.roundTo(
        this._Spinner(x, y, update1, update2, update3, caption, v, min_v, max_v, stp_v),
        roundStep
      )
    );
  }

  float Spinner (float x, float y, int update1, int update2, int update3, String caption, float v, float min_v, float max_v, float stp_v) {
    float roundStep = Math.abs(stp_v);
    return (
      funcs.roundTo(
        this._Spinner(x, y, update1, update2, update3, caption, v, min_v, max_v, stp_v),
        roundStep
      )
    );
  }

  DecimalFormat df = new DecimalFormat("0.#####");

  String formatSpinnerValue (float value) {
    return df.format(value);
  }

  void beginSpinnerEdit (String caption, float value) {
    this.editActive = true;
    this.editCaption = caption;
    this.editText = this.formatSpinnerValue(value);
    this.editCursor = this.editText.length();
    this.editCommit = false;
    this.editStateChanged = true;
  }

  float _Spinner (float x, float y, int update1, int update2, int update3, String caption, float v, float min_v, float max_v, float stp_v) {

    float new_value = v;

    if (new_value < min_v) new_value = min_v;
    if (new_value > max_v) new_value = max_v;

    float cx, cy, cr;
    float w1, w2, h, o, t_oW, t_oH;

    //w1 = 32.5 * UI_rollout.view_S;
    //w2 = 142.5 * UI_rollout.view_S;

    w1 = 100 * UI_rollout.view_S;
    w2 = 200 * UI_rollout.view_S;

    h = 16 * UI_rollout.view_S;
    o = 2 * UI_rollout.view_S;
    t_oW = h * UI_rollout.view_S / 8.0;
    t_oH = t_oW - 2; // move text 2 pixels down to display nicely

    Y_control += 25 * UI_rollout.view_S; //(h + 2 * o) * 1.25;

    this.spinnerOrderThisPass.add(caption);

    // --- Spinner text-edit -------------------------------------------------
    // Clicking the gray caption area on the left of the spinner (the part of
    // the control not covered by the white value box) enables direct
    // keyboard entry of this spinner's value. Only one spinner can be in
    // edit mode at a time; it is tracked by its caption string.
    boolean editingThis = this.editActive && this.editCaption.equals(caption);

    if (editingThis && this.editCommit) {

      float typed_value = v;
      try {
        typed_value = Float.parseFloat(this.editText);
      }
      catch (Exception ex) {
        typed_value = v;
      }

      new_value = typed_value;
      if (new_value < min_v) new_value = min_v;
      if (new_value > max_v) new_value = max_v;

      this.editActive = false;
      this.editCaption = "";
      this.editText = "";
      this.editCursor = 0;
      this.editCommit = false;

      editingThis = false;

      this.editStateChanged = true;

      UI_rollout.revise();
    }

    // Tab / Shift+Tab requested this spinner become the new edit target.
    if ((this.editPendingCaption != null) && this.editPendingCaption.equals(caption) && !editingThis) {

      this.beginSpinnerEdit(caption, new_value);
      this.editPendingCaption = null;

      editingThis = true;
    }

    if ((!this.editActive || editingThis) && (
      isInside(X_clicked, Y_clicked, x - w1 - w2 - o, y - (h / 2) - o, x - w1, y + (h / 2) + o) || // gray area
      isInside(X_clicked, Y_clicked, x - w1,          y - (h / 2), x,          y + (h / 2))        // bar area
    )) {
      if (mouseButton == LEFT) {
        if (!editingThis) {
          this.beginSpinnerEdit(caption, new_value);
          editingThis = true;
        }

        X_clicked = -1;
        Y_clicked = -1;
      }
    }
    // -------------------------------------------------------------------

    strokeWeight(0);
    stroke(0);
    fill(0);
    rect(x + o, y - (h / 2) - o, 0.5 * (h + 2 * o), 0.5 * (h + 2 * o));
    rect(x + o, y - (h / 2) - o + 0.5 * (h + 2 * o), 0.5 * (h + 2 * o), 0.5 * (h + 2 * o));
    stroke(255);
    fill(255);
    cx = x + o + 0.25 * (h + 2 * o);
    cy = y - (h / 2) - o + 0.25 * (h + 2 * o);
    cr = 0.25 * (h + 2 * o);
    triangle(cx + cr * funcs.cos_ang(270), cy + 0.75 * cr * funcs.sin_ang(270), cx + 0.75 * cr * funcs.cos_ang(30), cy + 0.75 * cr * funcs.sin_ang(30), cx + 0.75 * cr * funcs.cos_ang(150), cy + 0.75 * cr * funcs.sin_ang(150));

    if (!this.editActive && isInside(X_clicked, Y_clicked, cx - cr, cy - cr, cx + cr, cy + cr)) {
      if (mouseButton == LEFT) {

        if (stp_v < 0) {
          new_value *= abs(stp_v);
        } else {
          new_value += abs(stp_v);
        }
      } else if (mouseButton == RIGHT) {

        new_value = max_v;
      }
    }

    cy += 2 * cr;
    triangle(cx + cr * funcs.cos_ang(90), cy + 0.75 * cr * funcs.sin_ang(90), cx + 0.75 * cr * funcs.cos_ang(210), cy + 0.75 * cr * funcs.sin_ang(210), cx + 0.75 * cr * funcs.cos_ang(330), cy + 0.75 * cr * funcs.sin_ang(330));

    if (!this.editActive && isInside(X_clicked, Y_clicked, cx - cr, cy - cr, cx + cr, cy + cr)) {

      if (mouseButton == LEFT) {

        if (stp_v < 0) {
          new_value /= abs(stp_v);
        } else {
          new_value -= abs(stp_v);
        }
      } else if (mouseButton == RIGHT) {

        new_value = min_v;
      }
    }

    if (new_value < min_v) new_value = min_v;
    if (new_value > max_v) new_value = max_v;



    strokeWeight(0);
    if (editingThis) {
      stroke(255, 127, 0);
      fill(255, 127, 0);
    } else {
      stroke(191);
      fill(191);
    }
    rect(x - (w1 + w2) - o, y - (h / 2) - o, (w1 + w2) + 2 * o, h + 2 * o);

    stroke(255);
    fill(255);
    rect(x - w1, y - (h / 2), w1, h);

    float q = 0;

    if (max_v - min_v > 0.001) {
      q = (new_value - min_v) / (max_v - min_v);
    }

    if (!this.editActive && isInside(X_clicked, Y_clicked, x - w1, y - (h / 2), x, y + (h / 2))) {
      if (mouseButton == RIGHT) { // change value by right click over the bar
        q = 1;

        if (max_v - min_v > 0.001) {
          q = (X_clicked - (x - w1)) / w1;
        }

        new_value = min_v + q * (max_v - min_v);

        if (new_value < min_v) new_value = max_v;
        if (new_value > max_v) new_value = min_v;

        UI_rollout.revise();
      }
    }

    strokeWeight(0);
    stroke(191, 255, 191);
    fill(191, 255, 191);
    rect(x - w1, y - (h / 2), q * w1, h);


    strokeWeight(2);
    stroke(0);
    noFill();
    rect(x - w1, y - (h / 2), w1, h);

    strokeWeight(0);
    stroke(0);
    fill(0);
    textSize(1.0 * h);

    if (editingThis) {

      textAlign(LEFT, CENTER);
      String textWithCursor = this.editText.substring(0, this.editCursor) + "|" + this.editText.substring(this.editCursor);
      text(textWithCursor, x - w1 + t_oW, y - t_oH);
    } else {

      textAlign(RIGHT, CENTER);
      text(this.formatSpinnerValue(new_value), x - t_oW, y - t_oH);
    }


    strokeWeight(0);
    stroke(0);
    fill(0);
    //textSize(1.0 * h);
    textSize(0.85 * h);
    //textAlign(RIGHT, CENTER); text(caption + ":", x - w1 - t_oW, y - t_oH);
    textAlign(LEFT, CENTER);
    text(caption + ":", x - w1 - w2 + t_oW, y - t_oH);

    if (new_value != v) {
      reviseByUpdateFlags(update1, update2, update3);
    }

    return new_value;
  }


  void revise () {
    this.update = true;
  }
  void updated () {
    this.update = false;
  }

  boolean isEditingSpinner () {
    return this.editActive;
  }

  // --- Continuous key-hold repeat (see WIN3D.pde) -----------------------
  // Processing does not forward OS key-repeat events while a key stays
  // held, so Left/Right/Backspace/Delete are re-run from draw(), via
  // processHeldKey(), for as long as they remain held. Delay-then-repeat,
  // like an OS key-repeat setting, at frameRate(24): ~0.25s before the
  // first repeat, then one step every frame (~24/s).
  static final int NAV_KEY_INITIAL_DELAY_FRAMES = 6;
  static final int NAV_KEY_REPEAT_FRAMES = 1;
  boolean navKeyHeld = false;
  boolean navKeyCoded = false;
  char navKeyChar = 0;
  int navKeyCode = 0;
  int navKeyFrameCounter = 0;
  boolean navKeyRepeating = false;

  void keyPressed (KeyEvent e) {

    if (!this.editActive) return;
    if (e.isAltDown() || e.isControlDown()) return;

    boolean isCoded = (key == CODED);
    char keyChar = key;
    int code = keyCode;

    boolean isRepeatableArrow = isCoded && ((code == LEFT) || (code == RIGHT));
    boolean isRepeatableEdit = !isCoded && ((keyChar == BACKSPACE) || (keyChar == DELETE));

    if (isRepeatableArrow || isRepeatableEdit) {
      this.navKeyHeld = true;
      this.navKeyCoded = isCoded;
      this.navKeyChar = keyChar;
      this.navKeyCode = code;
      this.navKeyFrameCounter = 0;
      this.navKeyRepeating = false;

      this.dispatchEditKey(isCoded, code, keyChar);
      return;
    }

    if (isCoded) return;

    switch (key) {

      case ENTER:
        this.editCommit = true;
        this.revise();
        break;

      case ESC:
        // Cancel editing: drop the typed text and leave the spinner's
        // actual value untouched (it was never applied during editing).
        this.editActive = false;
        this.editCaption = "";
        this.editText = "";
        this.editCursor = 0;
        this.editCommit = false;
        this.editPendingCaption = null;
        this.revise();
        break;

      case TAB:
        // Cancel the current edit (typed text is dropped, same as Esc) and
        // move to editing the next (Tab) or previous (Shift+Tab) spinner
        // displayed on this page, wrapping around at the ends. The actual
        // switch is deferred to that spinner's own _Spinner() call, since
        // only there is its live value known to seed the typed text.
        {
          int n = this.spinnerOrderThisPass.size();

          if (n > 1) {
            int idx = this.spinnerOrderThisPass.indexOf(this.editCaption);
            if (idx == -1) idx = 0;

            int nextIdx = e.isShiftDown() ? ((idx - 1 + n) % n) : ((idx + 1) % n);

            this.editPendingCaption = this.spinnerOrderThisPass.get(nextIdx);
            this.revise();
          }
        }
        break;

      case '-':
        // A minus sign is only meaningful as the very first character.
        if ((this.editCursor == 0) && ((this.editText.length() == 0) || (this.editText.charAt(0) != '-'))) {
          this.editText = "-" + this.editText;
          this.editCursor++;
          this.revise();
        }
        break;

      default:
        if ((key >= '0') && (key <= '9')) {
          this.editText = this.editText.substring(0, this.editCursor) + key + this.editText.substring(this.editCursor);
          this.editCursor++;
          this.revise();
        } else if ((key == '.') && (this.editText.indexOf('.') == -1)) {
          this.editText = this.editText.substring(0, this.editCursor) + key + this.editText.substring(this.editCursor);
          this.editCursor++;
          this.revise();
        }
        break;
    }

  }

  // Applies one Left/Right cursor move or Backspace/Delete edit.
  // Shared by keyPressed() (first press) and processHeldKey() (repeat).
  void dispatchEditKey (boolean isCoded, int code, char keyChar) {
    if (isCoded) {
      switch (code) {

        case LEFT:
          if (this.editCursor > 0) {
            this.editCursor--;
            this.revise();
          }
          break;

        case RIGHT:
          if (this.editCursor < this.editText.length()) {
            this.editCursor++;
            this.revise();
          }
          break;
      }
    } else {
      switch (keyChar) {

        case BACKSPACE:
          if (this.editCursor > 0) {
            this.editText = this.editText.substring(0, this.editCursor - 1) + this.editText.substring(this.editCursor);
            this.editCursor--;
            this.revise();
          }
          break;

        case DELETE:
          if (this.editCursor < this.editText.length()) {
            this.editText = this.editText.substring(0, this.editCursor) + this.editText.substring(this.editCursor + 1);
            this.revise();
          }
          break;
      }
    }
  }

  // Called once per frame from the sketch's draw(); re-fires the held
  // key's action for as long as it remains held and the spinner is still
  // being edited.
  void processHeldKey () {
    if (this.navKeyHeld && this.editActive) {
      this.navKeyFrameCounter++;
      int threshold = this.navKeyRepeating ? NAV_KEY_REPEAT_FRAMES : NAV_KEY_INITIAL_DELAY_FRAMES;
      if (this.navKeyFrameCounter >= threshold) {
        this.navKeyFrameCounter = 0;
        this.navKeyRepeating = true;
        this.dispatchEditKey(this.navKeyCoded, this.navKeyCode, this.navKeyChar);
      }
    }
  }

  // Matches the global keyReleased() convention (no KeyEvent overload
  // needed): uses the sketch's global key/keyCode.
  void keyReleased () {
    if (!this.navKeyHeld) return;

    boolean releasedCoded = (key == CODED);
    if (releasedCoded != this.navKeyCoded) return;

    if (releasedCoded) {
      if (keyCode == this.navKeyCode) this.navKeyHeld = false;
    } else {
      if (key == this.navKeyChar) this.navKeyHeld = false;
    }
  }
}
