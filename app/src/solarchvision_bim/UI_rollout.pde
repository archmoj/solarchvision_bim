int calcRolloutWidth () {
  return int(27 * MessageSize);
}

class UI_rollout {

  final static String CLASS_STAMP = "UI_rollout";

  int cX = 2 * pixel_W;
  int cY = pixel_A + pixel_B + 0;
  int dX = calcRolloutWidth();
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
    vm.dailyStep(0);
    vm.daysMergedCount(0);
    vm.date(0);
    vm.beginDay(0);
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
    vm.locationLatitude(0);
    vm.locationLongitude(0);
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
    vm.creatorMaterial(0);
    vm.creatorTessellation(0);
    vm.creatorLayer(0);
    vm.creatorVisibility(0);
    vm.creatorWeight(0);
    vm.creatorClosed(0);
    vm.creatorOrientation(0);
    vm.creatorLength(0);
    vm.creatorWidth(0);
    vm.creatorHeight(0);
    vm.creatorVolume(0);
    vm.creatorSnapModeIndex(0);
    vm.creatorSphereDegree(0);
    vm.creatorCylinderDegree(0);
    vm.creatorConeDegree(0);
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
    vm.creatorModel1DBranchTilt(0);
    vm.creatorModel1DBranchTwist(0);
    vm.creatorModel1DBranchRatio(0);
    vm.creatorModel1DTreeBase(0);
    vm.TerrainLoadTextures(0);
    vm.TerrainLoadMesh(0);
    vm.TerrainSkipStart(0);
    vm.TerrainSkipEnd(0);
    vm.TerrainDisplaySurface(0);
    vm.TerrainDisplayTexture(0);
    vm.TerrainDisplayPoints(0);
    vm.TerrainDisplayDepth(0);
    vm.Model2DsDisplayAll(0);
    vm.Model1DsDisplayAll(0);
    vm.Model1DsDisplayLeaves(0);
    vm.PolylinesDisplayAll(0);
    vm.FacesDisplayAll(0);
    vm.SolidsDisplayAll(0);
    vm.SectionsDisplayAll(0);
    vm.WindRoseDisplayImage(0);
    vm.WindRosePlaneSize(0);
    vm.Sky3DDisplaySurface(0);
    vm.Sun3DDisplayPath(0);
    vm.Sun3DDisplayPattern(0);
    vm.currentCameraIndex(0);
    vm.cameraClipNear(0);
    vm.cameraClipFar(0);
    vm.Create3DDisplayVertices(0);
    vm.Create3DDisplayEdges(0);
    vm.Create3DDisplayNormals(0);
    vm.CamerasDisplayAll(0);
    vm.impactDisplayDay(0);
    vm.SolarImpactsDisplayImage(0);
    vm.SolidImpactsDisplayImage(0);
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
    vm.SolidImpactsDisplayPoints(0);
    vm.SolidImpactsDisplayLines(0);
    vm.WindFlowsDisplayAll(0);
    vm.Create3DDisplayTessellation(0);
    vm.TerrainDisplayTessellation(0);
    vm.Sky3DDisplayTessellation(0);
    vm.Sky3DRadius(0);
    vm.Tropo3DDisplaySurface(0);
    vm.Tropo3DDisplayTexture(0);
    vm.Earth3DDisplaySurface(0);
    vm.Earth3DDisplayTexture(0);
    vm.Earth3DLevelOfDetail(0);
    vm.Moon3DDisplaySurface(0);
    vm.Moon3DDisplayTexture(0);
    vm.Moon3DFitInSkyDome(0);
    vm.Sun3DDisplaySurface(0);
    vm.Sun3DDisplayTexture(0);
    vm.Sun3DFitInSkyDome(0);
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
    vm.Study_activeColorscaleIndex(0);
    vm.Study_activeColorscaleDirection(0);
    vm.Study_activeColorscaleFactor(0);
    vm.Study_passiveColorscaleIndex(0);
    vm.Study_passiveColorscaleDirection(0);
    vm.Study_passiveColorscaleFactor(0);
    vm.statisticalRangesColorscaleIndex(0);
    vm.statisticalRangesColorscaleDirection(0);
    vm.statisticalRangesColorscaleFactor(0);
    vm.probabilitiesColorscaleIndex(0);
    vm.probabilitiesColorscaleDirection(0);
    vm.probabilitiesColorscaleFactor(0);
    vm.opacityPercentage(0);
    vm.Faces_activeColorscaleIndex(0);
    vm.Faces_activeColorscaleDirection(0);
    vm.Faces_activeColorscaleFactor(0);
    vm.Faces_passiveColorscaleIndex(0);
    vm.Faces_passiveColorscaleDirection(0);
    vm.Faces_passiveColorscaleFactor(0);
    vm.Sky3D_activeColorscaleIndex(0);
    vm.Sky3D_activeColorscaleDirection(0);
    vm.Sky3D_activeColorscaleFactor(0);
    vm.Sky3D_passiveColorscaleIndex(0);
    vm.Sky3D_passiveColorscaleDirection(0);
    vm.Sky3D_passiveColorscaleFactor(0);
    vm.Sun3D_activeColorscaleIndex(0);
    vm.Sun3D_activeColorscaleDirection(0);
    vm.Sun3D_activeColorscaleFactor(0);
    vm.Sun3D_passiveColorscaleIndex(0);
    vm.Sun3D_passiveColorscaleDirection(0);
    vm.Sun3D_passiveColorscaleFactor(0);
    vm.SolidsColorscaleIndex(0);
    vm.SolidsColorscaleDirection(0);
    vm.SolidsColorscaleFactor(0);
    vm.TerrainColorscaleIndex(0);
    vm.TerrainColorscaleDirection(0);
    vm.TerrainColorscaleFactor(0);
    vm.WindFlowsColorscaleIndex(0);
    vm.WindFlowsColorscaleDirection(0);
    vm.WindFlowsColorscaleFactor(0);
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
    vm.exporterColorscaleResolution(0);
    vm.Record_SolidImpact_in_JPG(0);
    vm.Record_SolidImpact_in_PDF(0);
    vm.Record_Solar_Analysis_in_JPG(0);
    vm.WindRoseImageResolution(0);
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
          rect(
            cx - 2.5 * this.view_S, cy - 5 * this.view_S - 1,
            150 * this.view_S, 2 * 7.5 * this.view_S
          );
          strokeWeight(0);

          stroke(0);
          fill(0);
          textSize(12.5 * this.view_S);
        } else {
          stroke(127);
          fill(127);
          textSize(12.5 * this.view_S);
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
          textSize(12.5 * this.view_S);
        } else {
          stroke(255);
          fill(255);
          textSize(11 * this.view_S);
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
        STUDY.dailyStep = vm.dailyStep(1);
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
        locationLatitude = vm.locationLatitude(1);
        locationLongitude = vm.locationLongitude(1);
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
        User3D.creatorMaterial = vm.creatorMaterial(1);
        User3D.creatorTessellation = vm.creatorTessellation(1);
        User3D.creatorLayer = vm.creatorLayer(1);
        User3D.creatorVisibility = vm.creatorVisibility(1);
        User3D.creatorWeight = vm.creatorWeight(1);
        User3D.creatorClosed = vm.creatorClosed(1);
        User3D.creatorOrientation = vm.creatorOrientation(1);
        User3D.creatorLength = vm.creatorLength(1);
        User3D.creatorWidth = vm.creatorWidth(1);
        User3D.creatorHeight = vm.creatorHeight(1);
        User3D.creatorVolume = vm.creatorVolume(1);
        User3D.creatorSnapModeIndex = vm.creatorSnapModeIndex(1);
        User3D.creatorSphereDegree = vm.creatorSphereDegree(1);
        User3D.creatorCylinderDegree = vm.creatorCylinderDegree(1);
        User3D.creatorConeDegree = vm.creatorConeDegree(1);
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
        User3D.creatorModel1DBranchTilt = vm.creatorModel1DBranchTilt(1);
        User3D.creatorModel1DBranchTwist = vm.creatorModel1DBranchTwist(1);
        User3D.creatorModel1DBranchRatio = vm.creatorModel1DBranchRatio(1);
        User3D.creatorModel1DTreeBase = vm.creatorModel1DTreeBase(1);
      }

      if (this.child == CHILD_GEOMETRY_ENVIRONMENT) {

        Terrain.loadTextures = vm.TerrainLoadTextures(1);
        Terrain.loadMesh = vm.TerrainLoadMesh(1);
        Terrain.skipStart = vm.TerrainSkipStart(1);
        Terrain.skipEnd = vm.TerrainSkipEnd(1);
        Terrain.displaySurface = vm.TerrainDisplaySurface(1);
        Terrain.displayTexture = vm.TerrainDisplayTexture(1);
        Terrain.displayPoints = vm.TerrainDisplayPoints(1);
        Terrain.displayDepth = vm.TerrainDisplayDepth(1);
        allModel2Ds.displayAll = vm.Model2DsDisplayAll(1);
        allModel1Ds.displayAll = vm.Model1DsDisplayAll(1);
        allModel1Ds.displayLeaves = vm.Model1DsDisplayLeaves(1);
        allPolylines.displayAll = vm.PolylinesDisplayAll(1);
        allFaces.displayAll = vm.FacesDisplayAll(1);
        allSolids.displayAll = vm.SolidsDisplayAll(1);
        allSections.displayAll = vm.SectionsDisplayAll(1);
        allWindRoses.displayImage = vm.WindRoseDisplayImage(1);
        allWindRoses.planeSize = vm.WindRosePlaneSize(1);
        allWindRoses.imageResolution = vm.WindRoseImageResolution(1);



        Sky3D.displaySurface = vm.Sky3DDisplaySurface(1);
        Sun3D.displayPath = vm.Sun3DDisplayPath(1);
        Sun3D.displayPattern = vm.Sun3DDisplayPattern(1);
      }


      if (this.child == CHILD_GEOMETRY_VIEWPORT) {

        WIN3D.currentCameraIndex = vm.currentCameraIndex(1);
        WIN3D.cameraClipNear = vm.cameraClipNear(1);
        WIN3D.cameraClipFar = vm.cameraClipFar(1);
        allPoints.displayAll = vm.Create3DDisplayVertices(1);
        allFaces.displayEdges = vm.Create3DDisplayEdges(1);
        allFaces.showNormalLines = vm.Create3DDisplayNormals(1);
        allCameras.displayAll = vm.CamerasDisplayAll(1);
      }


      if (this.child == CHILD_GEOMETRY_SIMULATION) {

        impactDisplayDay = vm.impactDisplayDay(1);
        allSolarImpacts.displayImage = vm.SolarImpactsDisplayImage(1);
        allSolidImpacts.displayImage = vm.SolidImpactsDisplayImage(1);
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
        allSolidImpacts.displayPoints = vm.SolidImpactsDisplayPoints(1);
        allSolidImpacts.displayLines = vm.SolidImpactsDisplayLines(1);
        allWindFlows.displayAll = vm.WindFlowsDisplayAll(1);
      }

      if (this.child == CHILD_GEOMETRY_OTHER) {

        allFaces.displayTessellation = vm.Create3DDisplayTessellation(1);
        Terrain.displayTessellation = vm.TerrainDisplayTessellation(1);
        Sky3D.displayTessellation = vm.Sky3DDisplayTessellation(1);
        Sky3D.radius = vm.Sky3DRadius(1);
        Tropo3D.displaySurface = vm.Tropo3DDisplaySurface(1);
        Tropo3D.displayTexture = vm.Tropo3DDisplayTexture(1);
        Earth3D.displaySurface = vm.Earth3DDisplaySurface(1);
        Earth3D.displayTexture = vm.Earth3DDisplayTexture(1);
        Earth3D.levelOfDetail = vm.Earth3DLevelOfDetail(1);
        Earth3D.recomputeLevelOfDetailDependents();

        Moon3D.displaySurface = vm.Moon3DDisplaySurface(1);
        Moon3D.displayTexture = vm.Moon3DDisplayTexture(1);
        Moon3D.fitInSkyDome = vm.Moon3DFitInSkyDome(1);
        Sun3D.displaySurface = vm.Sun3DDisplaySurface(1);
        Sun3D.displayTexture = vm.Sun3DDisplayTexture(1);
        Sun3D.fitInSkyDome = vm.Sun3DFitInSkyDome(1);
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

        STUDY.activeColorscaleIndex = vm.Study_activeColorscaleIndex(1);
        STUDY.activeColorscaleDirection = vm.Study_activeColorscaleDirection(1);
        STUDY.activeColorscaleFactor = vm.Study_activeColorscaleFactor(1);
        STUDY.passiveColorscaleIndex = vm.Study_passiveColorscaleIndex(1);
        STUDY.passiveColorscaleDirection = vm.Study_passiveColorscaleDirection(1);
        STUDY.passiveColorscaleFactor = vm.Study_passiveColorscaleFactor(1);
        STUDY.statisticalRangesColorscaleIndex = vm.statisticalRangesColorscaleIndex(1);
        STUDY.statisticalRangesColorscaleDirection = vm.statisticalRangesColorscaleDirection(1);
        STUDY.statisticalRangesColorscaleFactor = vm.statisticalRangesColorscaleFactor(1);
        STUDY.probabilitiesColorscaleIndex = vm.probabilitiesColorscaleIndex(1);
        STUDY.probabilitiesColorscaleDirection = vm.probabilitiesColorscaleDirection(1);
        STUDY.probabilitiesColorscaleFactor = vm.probabilitiesColorscaleFactor(1);
        STUDY.opacityPercentage = vm.opacityPercentage(1);
      }

      if (this.child == CHILD_ILLUSTRATION_3D_SOLAR) {

        allFaces.activeColorscaleIndex = vm.Faces_activeColorscaleIndex(1);
        allFaces.activeColorscaleDirection = vm.Faces_activeColorscaleDirection(1);
        allFaces.activeColorscaleFactor = vm.Faces_activeColorscaleFactor(1);
        allFaces.passiveColorscaleIndex = vm.Faces_passiveColorscaleIndex(1);
        allFaces.passiveColorscaleDirection = vm.Faces_passiveColorscaleDirection(1);
        allFaces.passiveColorscaleFactor = vm.Faces_passiveColorscaleFactor(1);
        Sky3D.activeColorscaleIndex = vm.Sky3D_activeColorscaleIndex(1);
        Sky3D.activeColorscaleDirection = vm.Sky3D_activeColorscaleDirection(1);
        Sky3D.activeColorscaleFactor = vm.Sky3D_activeColorscaleFactor(1);
        Sky3D.passiveColorscaleIndex = vm.Sky3D_passiveColorscaleIndex(1);
        Sky3D.passiveColorscaleDirection = vm.Sky3D_passiveColorscaleDirection(1);
        Sky3D.passiveColorscaleFactor = vm.Sky3D_passiveColorscaleFactor(1);
        Sun3D.activeColorscaleIndex = vm.Sun3D_activeColorscaleIndex(1);
        Sun3D.activeColorscaleDirection = vm.Sun3D_activeColorscaleDirection(1);
        Sun3D.activeColorscaleFactor = vm.Sun3D_activeColorscaleFactor(1);
        Sun3D.passiveColorscaleIndex = vm.Sun3D_passiveColorscaleIndex(1);
        Sun3D.passiveColorscaleDirection = vm.Sun3D_passiveColorscaleDirection(1);
        Sun3D.passiveColorscaleFactor = vm.Sun3D_passiveColorscaleFactor(1);
      }




      if (this.child == CHILD_ILLUSTRATION_3D_SPATIAL) {

        allSolids.colorScaleIndex = vm.SolidsColorscaleIndex(1);
        allSolids.colorScaleDirection = vm.SolidsColorscaleDirection(1);
        allSolids.colorScaleFactor = vm.SolidsColorscaleFactor(1);
        Terrain.colorScaleIndex = vm.TerrainColorscaleIndex(1);
        Terrain.colorScaleDirection = vm.TerrainColorscaleDirection(1);
        Terrain.colorScaleFactor = vm.TerrainColorscaleFactor(1);
        allWindFlows.colorScaleIndex = vm.WindFlowsColorscaleIndex(1);
        allWindFlows.colorScaleDirection = vm.WindFlowsColorscaleDirection(1);
        allWindFlows.colorScaleFactor = vm.WindFlowsColorscaleFactor(1);
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
        User3D.exporterColorscaleResolution = vm.exporterColorscaleResolution(1);
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
    float newValue = (
      funcs.roundTo(
        this._Spinner(x, y, update1, update2, update3, caption, v ? 1.0 : 0.0, (float) min_v, (float) max_v, (float) stp_v),
        roundStep
      )
    );
    if(v != (newValue > 0.5)) displayDirective(ACTION_HEAD + caption + " " + newValue);
    return newValue > 0.5;
  }

  int Spinner (float x, float y, int update1, int update2, int update3, String caption, int v) {
    int min_v = 0;
    int max_v = 1;
    int stp_v = 1;
    int roundStep = Math.abs(stp_v);
    int newValue = int(
      funcs.roundTo(
        this._Spinner(x, y, update1, update2, update3, caption, (float) v, (float) min_v, (float) max_v, (float) stp_v),
        roundStep
      )
    );
    if(v != newValue) displayDirective(ACTION_HEAD + caption + " " + newValue);
    return newValue;
  }

  int Spinner (float x, float y, int update1, int update2, int update3, String caption, int v, int min_v, int max_v, int stp_v) {
    int roundStep = Math.abs(stp_v);
    int newValue = int(
      funcs.roundTo(
        this._Spinner(x, y, update1, update2, update3, caption, (float) v, (float) min_v, (float) max_v, (float) stp_v),
        roundStep
      )
    );
    if(v != newValue) displayDirective(ACTION_HEAD + caption + " " + newValue);
    return newValue;
  }

  int Spinner (float x, float y, int update1, int update2, int update3, String caption, int v, int min_v, int max_v, int stp_v, int roundStep) {
    int newValue = int(
      funcs.roundTo(
        this._Spinner(x, y, update1, update2, update3, caption, (float) v, (float) min_v, (float) max_v, (float) stp_v),
        roundStep
      )
    );
    if(v != newValue) displayDirective(ACTION_HEAD + caption + " " + newValue);
    return newValue;
  }

  int Spinner (float x, float y, int update1, int update2, int update3, String caption, float v, int min_v, int max_v, int stp_v, int roundStep) {
    int newValue = int(
      funcs.roundTo(
        this._Spinner(x, y, update1, update2, update3, caption, v, (float) min_v, (float) max_v, (float) stp_v),
        roundStep
      )
    );
    if(v != newValue) displayDirective(ACTION_HEAD + caption + " " + newValue);
    return newValue;
  }

  float Spinner (float x, float y, int update1, int update2, int update3, String caption, float v, float min_v, float max_v, float stp_v, float roundStep) {
    float newValue = (
      funcs.roundTo(
        this._Spinner(x, y, update1, update2, update3, caption, v, min_v, max_v, stp_v),
        roundStep
      )
    );
    if(v != newValue) displayDirective(ACTION_HEAD + caption + " " + newValue);
    return newValue;
  }

  float Spinner (float x, float y, int update1, int update2, int update3, String caption, float v, float min_v, float max_v, float stp_v) {
    float roundStep = Math.abs(stp_v);
    float newValue = (
      funcs.roundTo(
        this._Spinner(x, y, update1, update2, update3, caption, v, min_v, max_v, stp_v),
        roundStep
      )
    );
    if(v != newValue) displayDirective(ACTION_HEAD + caption + " " + newValue);
    return newValue;
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

    h = 13 * UI_rollout.view_S;
    o = 2 * UI_rollout.view_S;
    t_oW = h * UI_rollout.view_S / 8.0;
    t_oH = t_oW - 3; // move text 3 pixels down to display nicely

    Y_control += 20 * UI_rollout.view_S; //(h + 2 * o) * 1.25;

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
