int calcRolloutWidth () {
  return int(27 * MessageSize);
}

class UI_rollout {

  final static String CLASS_STAMP = "uiRollout";

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

  // Which keys keyPressed()'s own '-'/default cases (below) accept while
  // editActive: false for the numeric Spinner()/_Spinner() family
  // (digits and a single '.', '-' only as the first character), true for
  // the text-row _SpinnerText() family (PARENT_EXTRA_PARAMS, below) -
  // any printable character, since a text row's commit takes editText
  // verbatim rather than Float.parseFloat()'ing it. Set by
  // beginSpinnerEdit()/beginSpinnerTextEdit() respectively - every
  // edit-entry point in this file goes through one of those two, so
  // there's nowhere else this needs setting.
  boolean editIsText = false;

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
    CHILD_LOCATION_POINT = pushChild("Station");
    CHILD_LOCATION_STATIONS = pushChild("Data Points");

    PARENT_ILLUSTRATION = pushParent("Visualization Options");
    CHILD_ILLUSTRATION_2D_LAYERS = pushChild("2D Layout");
    CHILD_ILLUSTRATION_VISIBILITY = pushChild("Visibility");
    CHILD_ILLUSTRATION_SELECTION = pushChild("Selection");
    CHILD_ILLUSTRATION_2D_COLORS = pushChild("2D Palette");
    CHILD_ILLUSTRATION_3D_SPATIAL = pushChild("Spatial Palette");
    CHILD_ILLUSTRATION_3D_SOLAR = pushChild("Solar Palette");


    PARENT_PERIOD_SCENARIOS = pushParent("Time & Scenarios");
    CHILD_PERIOD_TIME = pushChild("Time");
    CHILD_PERIOD_RANGES = pushChild("Ranges");
    CHILD_PERIOD_FILTERS = pushChild("Filters");

    PARENT_POSTPROCESS = pushParent("Assessment Options");
    CHILD_POSTPROCESS_INTERPOLATION = pushChild("Interpolation");
    CHILD_POSTPROCESS_DEVELOPED = pushChild("Derived Data");
    CHILD_POSTPROCESS_SIMULATION = pushChild("Simulation");


    PARENT_GEOMETRY = pushParent("Geometry & Space");
    CHILD_GEOMETRY_FORM = pushChild("Form");
    CHILD_GEOMETRY_FIGURE = pushChild("Figure");
    CHILD_GEOMETRY_ENTOURAGE = pushChild("Entourage");

    CHILD_GEOMETRY_REFORM = pushChild("Reform");
    CHILD_GEOMETRY_DEFORM = pushChild("Deform");
    CHILD_GEOMETRY_TRANSFORM = pushChild("Transform");

    CHILD_GEOMETRY_LAND = pushChild("Land");
    CHILD_GEOMETRY_SKY = pushChild("Sky");
    CHILD_GEOMETRY_SOLARSYSTEM = pushChild("Solar System");

    CHILD_GEOMETRY_VIEWPORT = pushChild("View");
    CHILD_GEOMETRY_SOLIDS = pushChild("Solids");
    CHILD_GEOMETRY_WINDROSE = pushChild("Windrose");

    PARENT_EXPORT = pushParent("Export Options");
    CHILD_EXPORT_MODEL = pushChild("Model");
    CHILD_EXPORT_DATA = pushChild("Data");
    CHILD_EXPORT_CONTENT = pushChild("Content");

    PARENT_EXTRA_PARAMS = pushParent("Extra Params");
    CHILD_EXTRA_PARAMS_SELECTED_ENTITY = pushChild("Selected Entity");
    CHILD_EXTRA_PARAMS_BULK_EDIT = pushChild("Bulk Edit");
    CHILD_EXTRA_PARAMS_ASSIGN_MISSING = pushChild("Assign Missing");
  }

  int PARENT_PERIOD_SCENARIOS;
  int CHILD_PERIOD_TIME;
  int CHILD_PERIOD_RANGES;
  int CHILD_PERIOD_FILTERS;

  int PARENT_LOCATION;
  int CHILD_LOCATION_POINT;
  int CHILD_LOCATION_STATIONS;

  int PARENT_GEOMETRY;
  int CHILD_GEOMETRY_FORM;
  int CHILD_GEOMETRY_FIGURE;
  int CHILD_GEOMETRY_REFORM;
  int CHILD_GEOMETRY_DEFORM;
  int CHILD_GEOMETRY_TRANSFORM;
  int CHILD_GEOMETRY_SOLIDS;
  int CHILD_GEOMETRY_ENTOURAGE;
  int CHILD_GEOMETRY_VIEWPORT;
  int CHILD_GEOMETRY_WINDROSE;
  int CHILD_GEOMETRY_SKY;
  int CHILD_GEOMETRY_LAND;
  int CHILD_GEOMETRY_SOLARSYSTEM;

  int PARENT_ILLUSTRATION;
  int CHILD_ILLUSTRATION_2D_LAYERS;
  int CHILD_ILLUSTRATION_2D_COLORS;
  int CHILD_ILLUSTRATION_3D_SOLAR;
  int CHILD_ILLUSTRATION_3D_SPATIAL;
  int CHILD_ILLUSTRATION_SELECTION;
  int CHILD_ILLUSTRATION_VISIBILITY;

  int PARENT_POSTPROCESS;
  int CHILD_POSTPROCESS_INTERPOLATION;
  int CHILD_POSTPROCESS_DEVELOPED;
  int CHILD_POSTPROCESS_SIMULATION;

  int PARENT_EXPORT;
  int CHILD_EXPORT_MODEL;
  int CHILD_EXPORT_DATA;
  int CHILD_EXPORT_CONTENT;

  int PARENT_EXTRA_PARAMS;
  int CHILD_EXTRA_PARAMS_SELECTED_ENTITY;
  int CHILD_EXTRA_PARAMS_BULK_EDIT;
  int CHILD_EXTRA_PARAMS_ASSIGN_MISSING;

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

    // One vm.<name>(0) call per valueModifier.pde method - see that file
    // for each one's caption, bounds, update flags and (where relevant)
    // OnChange follow-up.

    vm.endDay(0);
    vm.dayIncrement(0);
    vm.daysMergedCount(0);
    vm.date(0);
    vm.beginDay(0);
    vm.day(0);
    vm.month(0);
    vm.year(0);
    vm.hour(0);
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
    vm.creatorTorusRatio(0);
    vm.creatorParametricStepsU(0);
    vm.creatorParametricStepsV(0);
    vm.creatorPersonTypeIndex(0);
    vm.creatorPlantTypeIndex(0);
    vm.modifierOpeningDepth(0);
    vm.modifierOpeningArea(0);
    vm.modifierOpeningDeviation(0);
    vm.modifierTessellateRows(0);
    vm.modifierTessellateColumns(0);
    vm.tileEdgeSize(0);
    vm.tileRotation(0);
    vm.tileStarSpikeAngle(0);
    vm.modifierOffsetAmount(0);
    vm.modifierInsetDepth(0);
    vm.modifierRelaxAmount(0);
    vm.modifierSkewXY(0);
    vm.modifierSkewXZ(0);
    vm.modifierSkewYZ(0);
    vm.modifierTwistX(0);
    vm.modifierTwistY(0);
    vm.modifierTwistZ(0);
    vm.modifierBendXY(0);
    vm.modifierBendXZ(0);
    vm.modifierBendYZ(0);
    vm.modifierPassiveSolarTouchStep(0);
    vm.modifierPassiveSolarTouchAngle(0);
    vm.modifierPassiveSolarInsetDepth(0);
    vm.modifierPassiveSolarInsetStep(0);
    vm.modifierWeldThreshold(0);
    vm.modifierCorrugateBumpAmount(0);
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
    vm.SolidImpacts_rotX(0);
    vm.SolidImpacts_z(0);
    vm.SolidImpacts_positionStep(0);
    vm.SolidImpacts_sizeX(0);
    vm.SolidImpacts_sizeY(0);
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
    vm.faceToSectionLift(0);
    vm.plotLayoutIndex(0);
    vm.verticalUnitScale(0);
    vm.showRawLines(0);
    vm.showStatisticalRanges(0);
    vm.showStatistics(0);
    vm.showProbabilities(0);
    vm.probabilityWidthInterval(0);
    vm.probabilityHeightInterval(0);
    vm.Study_activeColorScaleIndex(0);
    vm.Study_activeColorScaleDirection(0);
    vm.Study_activeColorScaleFactor(0);
    vm.Study_passiveColorScaleIndex(0);
    vm.Study_passiveColorScaleDirection(0);
    vm.Study_passiveColorScaleFactor(0);
    vm.statisticalRangesColorScaleIndex(0);
    vm.statisticalRangesColorScaleDirection(0);
    vm.statisticalRangesColorScaleFactor(0);
    vm.probabilitiesColorScaleIndex(0);
    vm.probabilitiesColorScaleDirection(0);
    vm.probabilitiesColorScaleFactor(0);
    vm.opacityPercentage(0);
    vm.Faces_activeColorScaleIndex(0);
    vm.Faces_activeColorScaleDirection(0);
    vm.Faces_activeColorScaleFactor(0);
    vm.Faces_passiveColorScaleIndex(0);
    vm.Faces_passiveColorScaleDirection(0);
    vm.Faces_passiveColorScaleFactor(0);
    vm.Sky3D_activeColorScaleIndex(0);
    vm.Sky3D_activeColorScaleDirection(0);
    vm.Sky3D_activeColorScaleFactor(0);
    vm.Sky3D_passiveColorScaleIndex(0);
    vm.Sky3D_passiveColorScaleDirection(0);
    vm.Sky3D_passiveColorScaleFactor(0);
    vm.Sun3D_activeColorScaleIndex(0);
    vm.Sun3D_activeColorScaleDirection(0);
    vm.Sun3D_activeColorScaleFactor(0);
    vm.Sun3D_passiveColorScaleIndex(0);
    vm.Sun3D_passiveColorScaleDirection(0);
    vm.Sun3D_passiveColorScaleFactor(0);
    vm.SolidsColorScaleIndex(0);
    vm.SolidsColorScaleDirection(0);
    vm.SolidsColorScaleFactor(0);
    vm.TerrainColorScaleIndex(0);
    vm.TerrainColorScaleDirection(0);
    vm.TerrainColorScaleFactor(0);
    vm.WindFlowsColorScaleIndex(0);
    vm.WindFlowsColorScaleDirection(0);
    vm.WindFlowsColorScaleFactor(0);
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
    vm.exporterExtraParams(0);
    vm.exporterColorScaleResolution(0);
    vm.Record_SolidImpact_in_JPG(0);
    vm.Record_SolidImpact_in_PDF(0);
    vm.Record_Solar_Analysis_in_JPG(0);
    vm.WindRoseImageResolution(0);
  }

  void draw () {

    this.editStateChanged = false;
    this.spinnerOrderThisPass.clear();
    this.textEditJustCommitted = false;

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

        text(allRollouts.get(i).get(0), cx, cy);

        if (i % 2 == 1) Y_control += 15 * this.view_S;
      }

      // The loop above only bumps Y_control once a ROW of 2 is complete
      // (i % 2 == 1) - fine while allRollouts.size() was always even (8
      // parents, 4 full rows), but with PARENT_EXTRA_PARAMS added as a
      // 9th, the last row holds a single, lone tab (i = 8, i % 2 == 0),
      // whose row the loop never accounts for. Without this, the child-
      // tab background/grid below would start drawing at that same row's
      // own y, overlapping the 9th parent tab instead of landing below
      // it. Same odd/incomplete-last-row correction the child grid below
      // already does for its own count via "% 3 != 1" - this is that
      // same fix, just for the parent grid's "% 2" instead.
      if (allRollouts.size() % 2 == 1) Y_control += 15 * this.view_S;

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

        text(" " + allRollouts.get(this.parent).get(i), cx, cy);

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
        currentDataSource = vm.currentDataSource(1);
      }
    } else if (this.parent == PARENT_GEOMETRY) {
      // Create's original single panel mixed two different kinds of
      // default: parameters that define the new object's own shape
      // (its dimensions, segment counts, orientation, open/closed
      // state) versus parameters about how it then sits in the scene
      // (material, tessellation quality, layer, visibility, weight,
      // grouping) - same "everything piled into one place" pattern
      // already split for Modify (Reform/Deform/Transform) and
      // Environment (Sky/Land). Form keeps the shape/geometry fields;
      // Figure keeps the object/scene-appearance fields.
      if (this.child == CHILD_GEOMETRY_FORM) {

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
        User3D.creatorTorusRatio = vm.creatorTorusRatio(1);
        User3D.creatorParametricStepsU = vm.creatorParametricStepsU(1);
        User3D.creatorParametricStepsV = vm.creatorParametricStepsV(1);
      }

      if (this.child == CHILD_GEOMETRY_FIGURE) {

        addToLastGroup = vm.addToLastGroup(1);
        User3D.creatorMaterial = vm.creatorMaterial(1);
        User3D.creatorTessellation = vm.creatorTessellation(1);
        User3D.creatorLayer = vm.creatorLayer(1);
        User3D.creatorVisibility = vm.creatorVisibility(1);
        User3D.creatorWeight = vm.creatorWeight(1);

        // Face-to-section turns a selected face into a new arbitrary-
        // section object (see faceToSection.pde) - that's creating a new
        // object, not reforming an existing one, so this lift amount
        // (how far the new section is nudged off the source face's
        // plane, to avoid z-fighting) belongs here with Figure's other
        // scene-appearance defaults for newly created objects, rather
        // than Reform's face/mesh-editing tools.
        FACE_TO_SECTION_LIFT = vm.faceToSectionLift(1);
      }

      if (this.child == CHILD_GEOMETRY_REFORM) {

        User3D.modifierOpeningDepth = vm.modifierOpeningDepth(1);
        User3D.modifierOpeningArea = vm.modifierOpeningArea(1);
        User3D.modifierOpeningDeviation = vm.modifierOpeningDeviation(1);
        User3D.modifierTessellateRows = vm.modifierTessellateRows(1);
        User3D.modifierTessellateColumns = vm.modifierTessellateColumns(1);
        User3D.tileEdgeSize = vm.tileEdgeSize(1);
        User3D.tileRotation = vm.tileRotation(1);
        User3D.tileStarSpikeAngle = vm.tileStarSpikeAngle(1);
        User3D.modifierOffsetAmount = vm.modifierOffsetAmount(1);
        User3D.modifierInsetDepth = vm.modifierInsetDepth(1);
        User3D.modifierWeldThreshold = vm.modifierWeldThreshold(1);
        User3D.modifierCorrugateBumpAmount = vm.modifierCorrugateBumpAmount(1);
      }

      // Split out of CHILD_GEOMETRY_REFORM above: the Relax/Skew/Twist/
      // Bend vertex-deformer trio (9 fields) grew into its own cohesive
      // feature set (see modify3D.pde's relaxVertices_Selection()/
      // skewVertices_Selection()/twistVertices_Selection()/
      // bendVertices_Selection()) and was crowding that one column
      // alongside unrelated face/mesh-editing and selection-transform
      // tools - same "everything piled into one place" pattern already
      // fixed for the Modify *menu* (see uiMenuBar.pde's own Visibility
      // split). Registration (the vm.xxx(0) calls above) is flat and
      // child-agnostic, so only this draw/read-back half needed to move.
      // Soft-selection falloff (power/radius) is drawn FIRST here, ahead
      // of the four deformers themselves - it's a setting that decides
      // how far each one's effect spreads from the pivot before any of
      // them runs, not a deformation in its own right, so it reads as
      // "set the spread, then deform" rather than one more item in the
      // Relax/Skew/Twist/Bend list.
      if (this.child == CHILD_GEOMETRY_DEFORM) {

        Select3D.softSelectionFalloffPower = vm.softSelectionFalloffPower(1);
        Select3D.softSelectionFalloffRadius = vm.softSelectionFalloffRadius(1);
        User3D.modifierRelaxAmount = vm.modifierRelaxAmount(1);
        User3D.modifierSkewXY = vm.modifierSkewXY(1);
        User3D.modifierSkewXZ = vm.modifierSkewXZ(1);
        User3D.modifierSkewYZ = vm.modifierSkewYZ(1);
        User3D.modifierTwistX = vm.modifierTwistX(1);
        User3D.modifierTwistY = vm.modifierTwistY(1);
        User3D.modifierTwistZ = vm.modifierTwistZ(1);
        User3D.modifierBendXY = vm.modifierBendXY(1);
        User3D.modifierBendXZ = vm.modifierBendXZ(1);
        User3D.modifierBendYZ = vm.modifierBendYZ(1);
        User3D.modifierPassiveSolarTouchStep = vm.modifierPassiveSolarTouchStep(1);
        User3D.modifierPassiveSolarTouchAngle = vm.modifierPassiveSolarTouchAngle(1);
        User3D.modifierPassiveSolarInsetDepth = vm.modifierPassiveSolarInsetDepth(1);
        User3D.modifierPassiveSolarInsetStep = vm.modifierPassiveSolarInsetStep(1);
      }

      // The other half of Reform's original (pre-split) content: these
      // are all Select3D fields driving the current selection's own
      // pivot and its position/rotation/scale (command/README.md
      // already documents them separately, under "Selection tools
      // (3D-select)", not "Modify tools (3D-modify)") - they never
      // belonged alongside the face/mesh-editing tools Reform keeps,
      // they just ended up there historically. Pivot alignment is drawn
      // first, since it decides the point position/rotation/scale
      // themselves pivot around - a setting the other three read, the
      // same reasoning that put falloff first in Deform above. Each of
      // position/rotation/scale is then its own pair: the axis picker
      // immediately followed by the matching delta field it feeds,
      // rather than all three pickers grouped before all three deltas.
      if (this.child == CHILD_GEOMETRY_TRANSFORM) {

        Select3D.pivotAlignmentX = vm.pivotAlignmentX(1);
        Select3D.pivotAlignmentY = vm.pivotAlignmentY(1);
        Select3D.pivotAlignmentZ = vm.pivotAlignmentZ(1);
        Select3D.positionVectorIndex = vm.positionVectorIndex(1);
        Select3D.position = vm.positionSelection(1);
        Select3D.rotationVectorIndex = vm.rotationVectorIndex(1);
        Select3D.rotation = vm.rotationSelection(1);
        Select3D.scaleVectorIndex = vm.scaleVectorIndex(1);
        Select3D.scale = vm.scaleSelection(1);
      }

      if (this.child == CHILD_GEOMETRY_SOLIDS) {
        User3D.creatorUniformSuperellipsoidPower = vm.creatorUniformSuperellipsoidPower(1);
        User3D.creatorSuperellipsoidPowerX = vm.creatorSuperellipsoidPowerX(1);
        User3D.creatorSuperellipsoidPowerY = vm.creatorSuperellipsoidPowerY(1);
        User3D.creatorSuperellipsoidPowerZ = vm.creatorSuperellipsoidPowerZ(1);
      }


      if (this.child == CHILD_GEOMETRY_ENTOURAGE) {
        User3D.creatorPersonTypeIndex = vm.creatorPersonTypeIndex(1);
        User3D.creatorPlantTypeIndex = vm.creatorPlantTypeIndex(1);

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

      if (this.child == CHILD_GEOMETRY_VIEWPORT) {

        WIN3D.currentCameraIndex = vm.currentCameraIndex(1);
        WIN3D.cameraClipNear = vm.cameraClipNear(1);
        WIN3D.cameraClipFar = vm.cameraClipFar(1);
        overallScale = vm.overallScale(1);
      }


      if (this.child == CHILD_GEOMETRY_WINDROSE) {
        allWindRoses.displayImage = vm.WindRoseDisplayImage(1);
        allWindRoses.planeSize = vm.WindRosePlaneSize(1);
        allWindRoses.imageResolution = vm.WindRoseImageResolution(1);
      }

      if (this.child == CHILD_GEOMETRY_SOLARSYSTEM) {
        celestialMagnification = vm.celestialMagnification(1);
        Sun3D.displayPath = vm.Sun3DDisplayPath(1);
        Sun3D.displayPattern = vm.Sun3DDisplayPattern(1);
        Sun3D.displaySurface = vm.Sun3DDisplaySurface(1);
        Sun3D.displayTexture = vm.Sun3DDisplayTexture(1);
        Sun3D.fitInSkyDome = vm.Sun3DFitInSkyDome(1);
        Moon3D.displaySurface = vm.Moon3DDisplaySurface(1);
        Moon3D.displayTexture = vm.Moon3DDisplayTexture(1);
        Moon3D.fitInSkyDome = vm.Moon3DFitInSkyDome(1);
      }

      // Split out of the old CHILD_GEOMETRY_ENVIRONMENT: that one panel
      // mixed the sky/atmosphere trio (Sky3D + Tropo3D) with the
      // ground/terrain trio (Earth3D + Terrain) under a single
      // "Environment" label that didn't distinguish them - same
      // "everything piled into one place" pattern already split for
      // Modify (now Reform/Deform/Transform). Sky3D and Tropo3D are
      // both things overhead; Earth3D and Terrain are both the ground
      // plane, so each now gets its own tab.
      if (this.child == CHILD_GEOMETRY_SKY) {
        Sky3D.displaySurface = vm.Sky3DDisplaySurface(1);
        Sky3D.displayTessellation = vm.Sky3DDisplayTessellation(1);
        Sky3D.radius = vm.Sky3DRadius(1);
        Tropo3D.displaySurface = vm.Tropo3DDisplaySurface(1);
        Tropo3D.displayTexture = vm.Tropo3DDisplayTexture(1);
      }

      if (this.child == CHILD_GEOMETRY_LAND) {
        Earth3D.displaySurface = vm.Earth3DDisplaySurface(1);
        Earth3D.displayTexture = vm.Earth3DDisplayTexture(1);
        Earth3D.levelOfDetail = vm.Earth3DLevelOfDetail(1);
        Earth3D.recomputeLevelOfDetailDependents();

        Terrain.loadMesh = vm.TerrainLoadMesh(1);
        Terrain.loadTexture = vm.TerrainLoadTextures(1);
        Terrain.displaySurface = vm.TerrainDisplaySurface(1);
        Terrain.displayTexture = vm.TerrainDisplayTexture(1);
        Terrain.displayTessellation = vm.TerrainDisplayTessellation(1);
        Terrain.displayPoints = vm.TerrainDisplayPoints(1);
        Terrain.skipStart = vm.TerrainSkipStart(1);
        Terrain.skipEnd = vm.TerrainSkipEnd(1);
        Terrain.displayDepth = vm.TerrainDisplayDepth(1);
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

        STUDY.activeColorScaleIndex = vm.Study_activeColorScaleIndex(1);
        STUDY.activeColorScaleDirection = vm.Study_activeColorScaleDirection(1);
        STUDY.activeColorScaleFactor = vm.Study_activeColorScaleFactor(1);
        STUDY.passiveColorScaleIndex = vm.Study_passiveColorScaleIndex(1);
        STUDY.passiveColorScaleDirection = vm.Study_passiveColorScaleDirection(1);
        STUDY.passiveColorScaleFactor = vm.Study_passiveColorScaleFactor(1);
        STUDY.statisticalRangesColorScaleIndex = vm.statisticalRangesColorScaleIndex(1);
        STUDY.statisticalRangesColorScaleDirection = vm.statisticalRangesColorScaleDirection(1);
        STUDY.statisticalRangesColorScaleFactor = vm.statisticalRangesColorScaleFactor(1);
        STUDY.probabilitiesColorScaleIndex = vm.probabilitiesColorScaleIndex(1);
        STUDY.probabilitiesColorScaleDirection = vm.probabilitiesColorScaleDirection(1);
        STUDY.probabilitiesColorScaleFactor = vm.probabilitiesColorScaleFactor(1);
        STUDY.opacityPercentage = vm.opacityPercentage(1);
      }

      if (this.child == CHILD_ILLUSTRATION_3D_SOLAR) {

        allFaces.activeColorScaleIndex = vm.Faces_activeColorScaleIndex(1);
        allFaces.activeColorScaleDirection = vm.Faces_activeColorScaleDirection(1);
        allFaces.activeColorScaleFactor = vm.Faces_activeColorScaleFactor(1);
        allFaces.passiveColorScaleIndex = vm.Faces_passiveColorScaleIndex(1);
        allFaces.passiveColorScaleDirection = vm.Faces_passiveColorScaleDirection(1);
        allFaces.passiveColorScaleFactor = vm.Faces_passiveColorScaleFactor(1);
        Sky3D.activeColorScaleIndex = vm.Sky3D_activeColorScaleIndex(1);
        Sky3D.activeColorScaleDirection = vm.Sky3D_activeColorScaleDirection(1);
        Sky3D.activeColorScaleFactor = vm.Sky3D_activeColorScaleFactor(1);
        Sky3D.passiveColorScaleIndex = vm.Sky3D_passiveColorScaleIndex(1);
        Sky3D.passiveColorScaleDirection = vm.Sky3D_passiveColorScaleDirection(1);
        Sky3D.passiveColorScaleFactor = vm.Sky3D_passiveColorScaleFactor(1);
        Sun3D.activeColorScaleIndex = vm.Sun3D_activeColorScaleIndex(1);
        Sun3D.activeColorScaleDirection = vm.Sun3D_activeColorScaleDirection(1);
        Sun3D.activeColorScaleFactor = vm.Sun3D_activeColorScaleFactor(1);
        Sun3D.passiveColorScaleIndex = vm.Sun3D_passiveColorScaleIndex(1);
        Sun3D.passiveColorScaleDirection = vm.Sun3D_passiveColorScaleDirection(1);
        Sun3D.passiveColorScaleFactor = vm.Sun3D_passiveColorScaleFactor(1);
      }




      if (this.child == CHILD_ILLUSTRATION_3D_SPATIAL) {

        allSolids.colorScaleIndex = vm.SolidsColorScaleIndex(1);
        allSolids.colorScaleDirection = vm.SolidsColorScaleDirection(1);
        allSolids.colorScaleFactor = vm.SolidsColorScaleFactor(1);
        Terrain.colorScaleIndex = vm.TerrainColorScaleIndex(1);
        Terrain.colorScaleDirection = vm.TerrainColorScaleDirection(1);
        Terrain.colorScaleFactor = vm.TerrainColorScaleFactor(1);
        allWindFlows.colorScaleIndex = vm.WindFlowsColorScaleIndex(1);
        allWindFlows.colorScaleDirection = vm.WindFlowsColorScaleDirection(1);
        allWindFlows.colorScaleFactor = vm.WindFlowsColorScaleFactor(1);
      }


      if (this.child == CHILD_ILLUSTRATION_SELECTION) {

        Select3D.groupDisplayPivot = vm.groupDisplayPivot(1);
        Select3D.pivotDisplayReference = vm.pivotDisplayReference(1);
        Select3D.groupDisplayBox = vm.groupDisplayBox(1);
        Select3D.groupDisplayEdges = vm.groupDisplayEdges(1);
        Select3D.faceDisplayEdges = vm.faceDisplayEdges(1);
        Select3D.faceDisplayVertexSelection = vm.faceDisplayVertexSelection(1);
        Select3D.polylineDisplayVertexSelection = vm.polylineDisplayVertexSelection(1);
        Select3D.vertexDisplayMarkers = vm.vertexDisplayMarkers(1);
        Select3D.polylineDisplayVertices = vm.polylineDisplayVertices(1);
        Select3D.model2DDisplayBounds = vm.model2DDisplayBounds(1);
        Select3D.model1DDisplayBounds = vm.model1DDisplayBounds(1);
        Select3D.solidDisplayEdges = vm.solidDisplayEdges(1);
        Select3D.sectionDisplayEdges = vm.sectionDisplayEdges(1);
        Select3D.cameraDisplayFrustum = vm.cameraDisplayFrustum(1);
        Select3D.terrainDisplayVertices = vm.terrainDisplayVertices(1);
      }

      if (this.child == CHILD_ILLUSTRATION_VISIBILITY) {

        // Every plain "show/hide this category of object" toggle that has
        // no other configuration of its own (a setting that comes WITH other
        // related settings - e.g. SolidImpacts.displayPoints, which lives
        // alongside that simulation's many other parameters, or WindRose's
        // displayImage, which lives alongside its planeSize/imageResolution -
        // stays with those siblings instead of being pulled in here).
        allModel2Ds.displayAll = vm.Model2DsDisplayAll(1);
        allModel1Ds.displayAll = vm.Model1DsDisplayAll(1);
        allModel1Ds.displayLeaves = vm.Model1DsDisplayLeaves(1);
        allPolylines.displayAll = vm.PolylinesDisplayAll(1);
        allFaces.displayAll = vm.FacesDisplayAll(1);
        allSolids.displayAll = vm.SolidsDisplayAll(1);
        allSections.displayAll = vm.SectionsDisplayAll(1);
        allPoints.displayAll = vm.Create3DDisplayVertices(1);
        allFaces.displayEdges = vm.Create3DDisplayEdges(1);
        allFaces.showNormalLines = vm.Create3DDisplayNormals(1);
        allFaces.displayTessellation = vm.Create3DDisplayTessellation(1);
        allCameras.displayAll = vm.CamerasDisplayAll(1);
        allWindFlows.displayAll = vm.WindFlowsDisplayAll(1);
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
      if (this.child == CHILD_POSTPROCESS_SIMULATION) {

        STUDY.impactLayerIndex = vm.impactLayerIndex(1);
        impactDisplayDay = vm.impactDisplayDay(1);
        allSolarImpacts.displayImage = vm.SolarImpactsDisplayImage(1);
        allSolidImpacts.displayImage = vm.SolidImpactsDisplayImage(1);
        allSolarImpacts.sectionType = vm.SolarImpacts_sectionType(1);
        allSolidImpacts.sectionType = vm.SolidImpacts_sectionType(1);
        allSolidImpacts.Grade = vm.SolidImpacts_grade(1);
        allSolidImpacts.Power = vm.SolidImpacts_power(1);
        allSolidImpacts.rotX = vm.SolidImpacts_rotX(1);
        allSolidImpacts.Z = vm.SolidImpacts_z(1);
        allSolidImpacts.positionStep = vm.SolidImpacts_positionStep(1);
        allSolidImpacts.setSizeX(vm.SolidImpacts_sizeX(1));
        allSolidImpacts.setSizeY(vm.SolidImpacts_sizeY(1));
        allSolidImpacts.X = vm.SolidImpacts_x(1);
        allSolidImpacts.Y = vm.SolidImpacts_y(1);
        allSolidImpacts.WindSpeed = vm.SolidImpacts_windSpeed(1);
        allSolidImpacts.WindDirection = vm.SolidImpacts_windDirection(1);
        allSolidImpacts.Process_subDivisions = vm.SolidImpacts_processSubDivisions(1);
        allSolidImpacts.displayPoints = vm.SolidImpactsDisplayPoints(1);
        allSolidImpacts.displayLines = vm.SolidImpactsDisplayLines(1);
      }
    } else if (this.parent == PARENT_EXPORT) {

      if (this.child == CHILD_EXPORT_DATA) {

        STUDY.rawLinesExporter = vm.rawLinesExporter(1);
        STUDY.normalLinesExporter = vm.normalLinesExporter(1);
        STUDY.probabilitiesExporter = vm.probabilitiesExporter(1);
      }

      if (this.child == CHILD_EXPORT_MODEL) {

        User3D.exporterScale = vm.exporterScale(1);
        User3D.exporterYaxisUp = vm.exporterYaxisUp(1);
        User3D.exporterPrecisionVertex = vm.exporterPrecisionVertex(1);
        User3D.exporterPrecisionVertexTexture = vm.exporterPrecisionVertexTexture(1);
        User3D.exporterMaintainPolygons = vm.exporterMaintainPolygons(1);
        User3D.exporterMaterialLibrary = vm.exporterMaterialLibrary(1);
        User3D.exporterDoubleSided = vm.exporterDoubleSided(1);
        User3D.exporterExtraParams = vm.exporterExtraParams(1);
        User3D.exporterColorScaleResolution = vm.exporterColorScaleResolution(1);
      }

      if (this.child == CHILD_EXPORT_CONTENT) {

        allSolidImpacts.record_IMG = vm.Record_SolidImpact_in_JPG(1);
        allSolidImpacts.record_PDF = vm.Record_SolidImpact_in_PDF(1);
        allSolarImpacts.record_IMG = vm.Record_Solar_Analysis_in_JPG(1);
      }

    } else if (this.parent == PARENT_EXTRA_PARAMS) {

      if (this.child == CHILD_EXTRA_PARAMS_SELECTED_ENTITY) {
        this.drawExtraParamsSelectedEntityTab();
      } else if (this.child == CHILD_EXTRA_PARAMS_BULK_EDIT) {
        this.drawExtraParamsBulkEditTab();
      } else if (this.child == CHILD_EXTRA_PARAMS_ASSIGN_MISSING) {
        this.drawExtraParamsAssignMissingTab();
      }
    }

    if (this.include) {
      this.drawRenderSectionsButton();
      this.drawRenderViewportButton();

      if (isInside(X_clicked, Y_clicked, this.cX, this.cY, this.cX + this.dX, this.cY + this.dY)) {
        X_clicked = -1;
        Y_clicked = -1;
      }
    }

    if (this.editStateChanged) {
      this.draw();
    }
  }

  // "SOLARCHVISION current viewport": one persistent button pinned to the
  // bottom of the rollout panel (this.cY + this.dY, bottom-anchored so it
  // stays put regardless of how much content the current parent/child
  // page above it has), drawn and click-checked on every page rather
  // than being part of any one PARENT_*/CHILD_* branch above - a
  // one-click "prep and show the render" shortcut, not a per-page
  // setting.
  //
  // renderViewportButtonBounds()/handleRenderViewportButtonClick() are split out of
  // drawRenderViewportButton() itself, rather than inlined together the way the
  // tab-selector loop earlier in draw() mixes its own hit-testing and
  // drawing - this way the click logic (the part actually worth testing)
  // stays free of any rect()/fill()/text() graphics calls, directly
  // callable headless, the same separation uiCaseBar.pde's own
  // handleImpactControlsClicks()/renderImpactControlsGrid() already keep.
  float[] renderViewportButtonBounds () {
    float x1 = this.cX + 5 * this.view_S;
    float x2 = this.cX + this.dX - 5 * this.view_S;
    float y2 = this.cY + this.dY - 5 * this.view_S;
    float y1 = y2 - 25 * this.view_S;
    return new float[]{x1, x2, y1, y2};
  }

  void handleRenderViewportButtonClick () {
    if (this.editActive) return;

    float[] b = renderViewportButtonBounds();
    if (!isInside(X_clicked, Y_clicked, b[0], b[2], b[1], b[3])) return;

    // Bake first (so the viewport has something fresh to show)...
    callAction("Prebake Viewport");
    // ...drop the sticky shaded-viewport preview if it's currently on top
    // (WIN3D.showShading - see its own comment, viewport3D.pde) - a render
    // should show the actual model, not a leftover grayscale shading
    // overlay sitting over it...
    if (WIN3D.showShading) callAction("Unshade Viewport");
    // ...then jump straight to the Skin Potential graph matching
    // whichever impact type (Active/Passive) is currently selected,
    // rather than always picking one regardless of the study's own
    // current setting.
    callAction(STUDY.impactTypeIndex == Impact_ACTIVE ? "Skin Potential (Active)" : "Skin Potential (Passive)");

    // Consumes its own click, same as the generic rollout-wide catch-all
    // right after this call in draw() - checked first, so a click here
    // never also falls through to that catch-all.
    X_clicked = -1;
    Y_clicked = -1;
  }

  void drawRenderViewportButton () {
    this.handleRenderViewportButtonClick();

    float[] b = renderViewportButtonBounds();

    strokeWeight(2);
    stroke(0);
    fill(255, 204, 0); // bold amber/gold - deliberately stands out against the panel's own plain white/gray
    rect(b[0], b[2], b[1] - b[0], b[3] - b[2]);
    strokeWeight(0);

    fill(0);
    textAlign(CENTER, CENTER);
    textSize(14 * this.view_S);
    text("SOLARCHVISION current viewport", 0.5 * (b[0] + b[1]), 0.5 * (b[2] + b[3]));
  }

  // "SOLARCHVISION all sections": a second persistent button, stacked
  // directly above "SOLARCHVISION current viewport" (same pinned-to-the-
  // bottom reasoning as that button's own comment above, just offset up
  // by its own height plus the same 5 * view_S margin that button uses
  // against the panel's own bottom edge) - a one-click "bake and process
  // every section" shortcut, regardless of whatever subset (if any) of
  // allSections is actually selected right now.
  //
  // render_ShadowsOnSections()/calculate_ImpactOnSections()
  // (solarImpacts.pde) both now take their section ids as an explicit
  // argument, rather than always reading Select3D.sectionSelection
  // directly - so this just builds "every section" (Select3D.
  // rangeIds(allSections.num)) and passes it straight in, with no need
  // to touch the real selection (Select3D.sectionSelection), let alone
  // selectAllOfCategory()/switch_category() and its currentObjectCategory
  // side effect, at all. A genuine one-shot, scope-contained "render
  // everything" action, not a selection change of any kind.
  float[] renderSectionsButtonBounds () {
    float[] viewportButton = renderViewportButtonBounds();
    float x1 = viewportButton[0];
    float x2 = viewportButton[1];
    float y2 = viewportButton[2] - 5 * this.view_S; // same margin renderViewportButtonBounds() itself uses against cY + dY, just stacked against that button's own y1 instead
    float y1 = y2 - 25 * this.view_S;
    return new float[]{x1, x2, y1, y2};
  }

  void handleRenderSectionsButtonClick () {
    if (this.editActive) return;

    float[] b = renderSectionsButtonBounds();
    if (!isInside(X_clicked, Y_clicked, b[0], b[2], b[1], b[3])) return;

    // Every section, built directly - Select3D.sectionSelection itself
    // is never read or written here, so whatever's actually selected
    // right now (if anything) is completely unaffected by this click.
    int[] everySection = Select3D.rangeIds(allSections.num);

    allSolarImpacts.render_ShadowsOnSections(everySection);

    boolean active = STUDY.impactTypeIndex == Impact_ACTIVE;
    STUDY.impactGraphIndex = active ? impactGraphIndex_URBAN_ACTIVE : impactGraphIndex_URBAN_PASSIVE;
    allSolarImpacts.calculate_ImpactOnSections(everySection);

    // Consumes its own click, same as handleRenderViewportButtonClick()'s own
    // identical reasoning above.
    X_clicked = -1;
    Y_clicked = -1;
  }

  void drawRenderSectionsButton () {
    this.handleRenderSectionsButtonClick();

    float[] b = renderSectionsButtonBounds();

    strokeWeight(2);
    stroke(0);
    fill(191);
    rect(b[0], b[2], b[1] - b[0], b[3] - b[2]);
    strokeWeight(0);

    fill(0);
    textAlign(CENTER, CENTER);
    textSize(14 * this.view_S);
    text("SOLARCHVISION all sections", 0.5 * (b[0] + b[1]), 0.5 * (b[2] + b[3]));
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
    this.editIsText = false; // numeric - keyPressed()'s default/'-' cases restrict typed characters accordingly
    this.editStateChanged = true;
  }

  // Text-row counterpart of beginSpinnerEdit() above, used by
  // _SpinnerText() (below) instead - the only difference keyPressed()
  // actually cares about is editIsText, which is what lets it accept
  // letters/spaces/punctuation for a text row while keeping the numeric
  // Spinner()/_Spinner() family above digits-and-one-decimal-point-only.
  void beginSpinnerTextEdit (String caption, String value) {
    this.editActive = true;
    this.editCaption = caption;
    this.editText = value;
    this.editCursor = this.editText.length();
    this.editCommit = false;
    this.editIsText = true;
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

  // ===================================================================
  // PARENT_EXTRA_PARAMS - view/edit the single currently-selected
  // entity's extraParams (extraParamsHelpers.pde/extraParamsPath.pde/
  // extraParamsSelection.pde). See that planning discussion for the
  // locked shape of this: single-entity scope, one row per top-level key,
  // a per-row level control (reusing the plain int Spinner() below
  // unmodified) that reveals an object-valued key's own children as
  // further rows capped at that one extra level, and a remove button per
  // row styled like hover.pde's own pinned-hover-box close button.
  // Every edit is dispatched as EXTRAPARAMS.SET/EXTRAPARAMS.REMOVE
  // through runScriptLine() - the same command a user could type by hand
  // - rather than writing into extraParams directly from here, so the
  // console log/history always shows a faithful record of every edit
  // made through this panel too.
  // ===================================================================

  // Text-edit commit flag for _SpinnerText() below - set at most once
  // per draw() pass (reset at its top, alongside editStateChanged/
  // spinnerOrderThisPass), read and cleared immediately by whichever
  // drawExtraParams*() call just drew the row that committed. Carries
  // the committed text itself, verbatim - no float parsing, unlike
  // _Spinner()'s own editCommit handling.
  boolean textEditJustCommitted = false;
  String textEditCommittedValue = "";

  // Wraps text into however many lines fit within maxWidth, appending
  // each line's text to outLines and that line's own start offset
  // (within the ORIGINAL, unwrapped string) to outStarts in lockstep -
  // the offsets are what let _SpinnerText() below place its "|" cursor
  // marker on the right wrapped line while editing, not just at the end.
  // A real embedded newline (a decoded JSON "\n") always starts a fresh
  // line of its own first; within each such segment, text is then
  // character-wrapped (not word-wrapped) to fit maxWidth, since a
  // compact JSON blob - this widget's single longest-running case,
  // PARENT_EXTRA_PARAMS's own object-valued rows - has no spaces at all
  // for a word-wrap to ever break on.
  void wrapTextLines (String text, float maxWidth, ArrayList<String> outLines, ArrayList<Integer> outStarts) {
    String[] rawLines = text.split("\n", -1);
    int globalOffset = 0;
    for (String raw : rawLines) {
      if (raw.length() == 0) {
        outLines.add("");
        outStarts.add(globalOffset);
      } else {
        int start = 0;
        while (start < raw.length()) {
          int end = start + 1;
          while (end <= raw.length() && textWidth(raw.substring(start, end)) <= maxWidth) end++;
          end--; // step back to the last length that still fit
          if (end <= start) end = start + 1; // always make progress, even if a single character alone is wider than maxWidth
          if (end > raw.length()) end = raw.length();
          outLines.add(raw.substring(start, end));
          outStarts.add(globalOffset + start);
          start = end;
        }
      }
      globalOffset += raw.length() + 1; // +1 for the "\n" this rawLine was split off of (harmless once past the real string's own length - nothing reads an offset that far)
    }
    if (outLines.size() == 0) { outLines.add(""); outStarts.add(0); }
  }

  // Finds which wrapped line a character offset (an editCursor position
  // into the ORIGINAL unwrapped string) falls on, given that line's own
  // wrapTextLines() output - shared by _SpinnerText() (to place the "|"
  // marker) and dispatchEditKey()'s Up/Down handling (to know which line
  // the cursor is leaving and compute its column within it).
  //
  // Every line's own end position matches inclusively (cursor <= lineEnd),
  // not just the overall-last line's. wrapTextLines() consumes each real
  // "\n" as a 1-character gap between two lines - it belongs to neither
  // line's own text, so a cursor sitting exactly on it (reachable by
  // ordinary Left/Right movement, not just Up/Down, any time the value
  // has an embedded newline) falls in the gap between lineEnd of the
  // line before it and lineStart of the line after, which is 1 higher.
  // Matching only the LAST line inclusively left every such gap
  // unmatched, falling through to the wrong line entirely and handing
  // back a column that could be deeply negative - the direct cause of a
  // StringIndexOutOfBoundsException two frames down this function's
  // callers. Matching every line inclusively closes every gap (a cursor
  // on a wrap boundary between two sub-lines of the same source line,
  // where lineEnd(i) == lineStart(i+1), now simply resolves to the
  // earlier of the two - an ordinary, harmless rendering choice, not a
  // second gap, since that boundary carries no consumed character).
  int spinnerTextLineIndexForCursor (ArrayList<Integer> lineStarts, ArrayList<String> lines, int cursor) {
    int idx = lines.size() - 1;
    for (int li = 0; li < lines.size(); li++) {
      int lineStart = lineStarts.get(li);
      int lineEnd = lineStart + lines.get(li).length();
      if (cursor >= lineStart && cursor <= lineEnd) {
        idx = li;
        break;
      }
    }
    return idx;
  }

  // At most this many wrapped lines are ever drawn for one _SpinnerText()
  // row at once; a longer value scrolls within that window instead of
  // growing the row without bound. 3 keeps a handful of rows, and their
  // remove buttons and level controls, all visible together on one
  // screen even when several hold long JSON blobs.
  int spinnerTextMaxVisibleLines = 3;

  // Per-row (keyed by caption, same key _SpinnerText()'s caller already
  // uses for extraParamsRowLevel) first-visible-wrapped-line index, so
  // each row remembers its own scroll position across frames
  // independently of whichever row is currently being edited.
  HashMap<String,Integer> spinnerTextScroll = new HashMap<String,Integer>();

  // _SpinnerText()'s own fixed line height and the pixel width its value
  // text wraps within - factored out so dispatchEditKey()'s Up/Down
  // handling (below) can re-wrap this.editText itself, from scratch,
  // every time it needs to know which line the cursor is on. An earlier
  // version instead cached _SpinnerText()'s own wrap for dispatchEditKey
  // to reuse, but that cache was only refreshed when a row actually drew
  // itself in edit mode - stale for the rest of the very frame a click
  // first put a (possibly much shorter) row into edit mode, since the
  // click is handled further down in the same _SpinnerText() call than
  // where the wrap/cache used to be computed. An Up/Down press in that
  // window reused a previous row's offsets against the new row's text
  // and could send editCursor miles outside it. Recomputing fresh here
  // is a little more work per keypress, but it can never disagree with
  // the text it's actually moving a cursor through.
  float spinnerTextLineHeight () {
    return 13 * UI_rollout.view_S;
  }

  float spinnerTextWrapWidth () {
    float w1 = 100 * UI_rollout.view_S;
    float lineH = spinnerTextLineHeight();
    float t_oW = lineH * UI_rollout.view_S / 8.0;
    return w1 - 2 * t_oW;
  }

  // The first wrapped line's own vertical center, for whichever row
  // _SpinnerText() (below) just drew - read by drawExtraParamsSelectedEntityTab()/
  // drawExtraParamsBulkEditPanel() right after each call to align that row's remove button (and, for
  // an object-valued row, the level-control Spinner right after it)
  // with the row's TOP line, regardless of how many further lines a
  // long value wrapped into beneath it. Same single-flag-per-call shape
  // textEditJustCommitted already uses, just read unconditionally
  // instead of only on a commit.
  float lastSpinnerTextRowFirstLineY = 0;

  // The "text" sibling to the numeric Spinner()/_Spinner() family above:
  // same shared click-to-edit state (editActive/editCaption/editText/
  // editCursor/editCommit), so Tab/Shift+Tab/Esc/Enter (keyPressed(),
  // above) already work on it unmodified - but none of _Spinner()'s
  // numeric-only machinery (no min/max clamping, no DecimalFormat, no
  // Float.parseFloat on commit), and, unlike _Spinner(), a variable
  // number of wrapped display lines capped at spinnerTextMaxVisibleLines
  // and scrollable (mouse-wheel-style up/down arrows, reusing _Spinner's
  // own triangle-button look) rather than a single fixed-height one - a
  // long value (a compact JSON blob especially) would otherwise run off
  // the edge of the box, or grow the row without bound and push every
  // row below it off-screen. caption doubles as both the Tab-order key
  // and, for every PARENT_EXTRA_PARAMS row, the exact dotted path
  // EXTRAPARAMS.SET/REMOVE would also take for that same row - so what's
  // shown here is always what could be typed on the command line too.
  String _SpinnerText (float x, float topY, String caption, String v) {
    return this._SpinnerText(x, topY, caption, v, false);
  }

  // darker: true for a row drawn as one of an expanded PARENT_EXTRA_PARAMS
  // key's own children - same gray as extraParamsLevelToggle()'s own row
  // above them, so the toggle and the child rows it reveals read as one
  // visually grouped cluster rather than each blending into the plain
  // top-level rows around them.
  String _SpinnerText (float x, float topY, String caption, String v, boolean darker) {
    return this._SpinnerText(x, topY, caption, v, darker, null);
  }

  // placeholder: shown in place of the (otherwise blank) value box, in
  // gray rather than this row's usual black text, whenever the row is
  // both empty and not currently being edited - a hint at the format to
  // type, same idea as an HTML input's own placeholder text. Clicking in
  // to edit still starts from the real (empty) v, same as always, not
  // from this text - it is purely a display-time stand-in, never part of
  // the actual value or of what beginSpinnerTextEdit() starts editing
  // from.
  String _SpinnerText (float x, float topY, String caption, String v, boolean darker, String placeholder) {
    return this._SpinnerText(x, topY, caption, v, darker, false, placeholder);
  }

  // green: this row's own caption/value background uses the same light
  // green (191, 255, 191) extraParamsLevelToggle()'s own value-fill bar
  // does, instead of the plain 191/140 gray every other row gets - for
  // the "+ Add" row specifically, to set it apart as the one row here
  // that creates something rather than showing/editing an existing key.
  String _SpinnerText (float x, float topY, String caption, String v, boolean darker, boolean green, String placeholder) {

    float w1 = 100 * UI_rollout.view_S;
    float w2 = 200 * UI_rollout.view_S;
    float lineH = this.spinnerTextLineHeight();
    float lineGap = 2 * UI_rollout.view_S;
    float o = 2 * UI_rollout.view_S;
    float t_oW = lineH * UI_rollout.view_S / 8.0;
    float t_oH = t_oW - 3;
    float wrapWidth = this.spinnerTextWrapWidth();

    this.spinnerOrderThisPass.add(caption);

    boolean editingThis = this.editActive && this.editCaption.equals(caption);
    String displayValue = v;

    if (editingThis && this.editCommit) {

      this.textEditJustCommitted = true;
      this.textEditCommittedValue = this.editText;

      this.editActive = false;
      this.editCaption = "";
      this.editText = "";
      this.editCursor = 0;
      this.editCommit = false;

      editingThis = false;
      this.editStateChanged = true;

      UI_rollout.revise();
    }

    if ((this.editPendingCaption != null) && this.editPendingCaption.equals(caption) && !editingThis) {
      this.beginSpinnerTextEdit(caption, v);
      this.editPendingCaption = null;
      editingThis = true;
    }

    String liveText = editingThis ? this.editText : v;

    textSize(1.0 * lineH); // textWidth() below measures against whatever size is currently set - match the size actually drawn further down
    ArrayList<String> lines = new ArrayList<String>();
    ArrayList<Integer> lineStarts = new ArrayList<Integer>();
    wrapTextLines(liveText, wrapWidth, lines, lineStarts);
    int totalLines = lines.size();

    // Which wrapped line the cursor currently falls in, and at what
    // offset within that line's own text, so the "|" marker lands in
    // the right place once the value wraps across more than one line -
    // not just always at the end.
    int cursorLineIndex = totalLines - 1;
    int cursorLocalOffset = lines.get(cursorLineIndex).length();
    if (editingThis) {
      cursorLineIndex = spinnerTextLineIndexForCursor(lineStarts, lines, this.editCursor);
      cursorLocalOffset = this.editCursor - lineStarts.get(cursorLineIndex);
    }

    // Cap the drawn window to spinnerTextMaxVisibleLines, scrolling
    // instead of growing the row without bound. A row currently being
    // edited auto-scrolls to keep the cursor's own line in view; any row
    // (editing or not) also remembers a scroll position a person set
    // with the up/down arrow buttons below.
    int maxScroll = max(0, totalLines - this.spinnerTextMaxVisibleLines);
    int scrollOffset = this.spinnerTextScroll.containsKey(caption) ? this.spinnerTextScroll.get(caption) : 0;
    if (scrollOffset > maxScroll) scrollOffset = maxScroll;
    if (scrollOffset < 0) scrollOffset = 0;
    if (editingThis) {
      if (cursorLineIndex < scrollOffset) scrollOffset = cursorLineIndex;
      else if (cursorLineIndex > scrollOffset + this.spinnerTextMaxVisibleLines - 1) scrollOffset = cursorLineIndex - this.spinnerTextMaxVisibleLines + 1;
    }

    int visibleCount = min(totalLines, this.spinnerTextMaxVisibleLines);
    float boxHeight = visibleCount * lineH + (visibleCount - 1) * lineGap;
    this.lastSpinnerTextRowFirstLineY = topY + o + lineH / 2.0;

    Y_control = topY + boxHeight + 2 * o + 7 * UI_rollout.view_S; // the 7*view_S breathing-room term matches the old fixed single-line pitch (20*view_S total) when there's exactly one visible line

    if ((!this.editActive || editingThis) && (
      isInside(X_clicked, Y_clicked, x - w1 - w2 - o, topY, x - w1, topY + boxHeight + 2 * o) ||
      isInside(X_clicked, Y_clicked, x - w1,          topY, x,     topY + boxHeight + 2 * o)
    )) {
      if (mouseButton == LEFT) {
        if (!editingThis) {
          this.beginSpinnerTextEdit(caption, v);
          editingThis = true;
        }
        X_clicked = -1;
        Y_clicked = -1;
      }
    }

    strokeWeight(0);
    if (editingThis) {
      stroke(255, 127, 0);
      fill(255, 127, 0);
    } else if (green) {
      stroke(191, 255, 191);
      fill(191, 255, 191);
    } else if (darker) {
      stroke(140);
      fill(140);
    } else {
      stroke(191);
      fill(191);
    }
    rect(x - (w1 + w2) - o, topY, (w1 + w2) + 2 * o, boxHeight + 2 * o);

    stroke(255);
    fill(255);
    rect(x - w1, topY + o, w1, boxHeight);

    strokeWeight(2);
    stroke(0);
    noFill();
    rect(x - w1, topY + o, w1, boxHeight);

    // Up/down scroll arrow buttons, drawn and hit-tested exactly like
    // _Spinner()'s own value-stepper arrows (same stacked-square-plus-
    // triangle look, same position just right of the value box at
    // x+o), only shown once the value actually has more wrapped lines
    // than fit in the window. Sized to one line's own height - same
    // scale _Spinner() uses regardless of how many lines are showing -
    // not the whole (up to spinnerTextMaxVisibleLines-tall) box, which
    // would blow the buttons up to several times that size. Centered on
    // the box's own middle line rather than pinned to its top: the
    // remove "x" button (drawExtraParamsRemoveButton(), called by the
    // caller right after this) is itself centered on the row's FIRST
    // line, so a top-anchored pair of arrows would sit right on top of
    // it; the middle line is clear of that.
    if (totalLines > this.spinnerTextMaxVisibleLines) {
      float arrSize = lineH + 2 * o;
      float ax = x + o;
      float ay = topY + o + (boxHeight / 2.0) - (arrSize / 2.0);

      strokeWeight(0);
      stroke(0);
      fill(0);
      rect(ax, ay, 0.5 * arrSize, 0.5 * arrSize);
      rect(ax, ay + 0.5 * arrSize, 0.5 * arrSize, 0.5 * arrSize);

      stroke(255);
      fill(255);
      float acx = ax + 0.25 * arrSize;
      float acyUp = ay + 0.25 * arrSize;
      float acr = 0.25 * arrSize;
      triangle(acx + acr * funcs.cos_ang(270), acyUp + 0.75 * acr * funcs.sin_ang(270), acx + 0.75 * acr * funcs.cos_ang(30), acyUp + 0.75 * acr * funcs.sin_ang(30), acx + 0.75 * acr * funcs.cos_ang(150), acyUp + 0.75 * acr * funcs.sin_ang(150));

      float acyDown = acyUp + 0.5 * arrSize;
      triangle(acx + acr * funcs.cos_ang(90), acyDown + 0.75 * acr * funcs.sin_ang(90), acx + 0.75 * acr * funcs.cos_ang(210), acyDown + 0.75 * acr * funcs.sin_ang(210), acx + 0.75 * acr * funcs.cos_ang(330), acyDown + 0.75 * acr * funcs.sin_ang(330));

      if (isInside(X_clicked, Y_clicked, ax, ay, ax + 0.5 * arrSize, ay + 0.5 * arrSize) && (mouseButton == LEFT)) {
        if (scrollOffset > 0) scrollOffset--;
        X_clicked = -1;
        Y_clicked = -1;
      } else if (isInside(X_clicked, Y_clicked, ax, ay + 0.5 * arrSize, ax + 0.5 * arrSize, ay + arrSize) && (mouseButton == LEFT)) {
        if (scrollOffset < maxScroll) scrollOffset++;
        X_clicked = -1;
        Y_clicked = -1;
      }
    }

    this.spinnerTextScroll.put(caption, scrollOffset);

    strokeWeight(0);
    stroke(0);
    fill(0);
    textSize(1.0 * lineH);
    textAlign(LEFT, CENTER);

    for (int vi = 0; vi < visibleCount; vi++) {
      int li = scrollOffset + vi;
      float lineCenterY = topY + o + vi * (lineH + lineGap) + lineH / 2.0;
      String lineText = lines.get(li);
      if (editingThis && li == cursorLineIndex) {
        lineText = lineText.substring(0, cursorLocalOffset) + "|" + lineText.substring(cursorLocalOffset);
      }
      text(lineText, x - w1 + t_oW, lineCenterY - t_oH);
    }

    // v is empty (so the loop above drew nothing) and this row isn't
    // being edited - show the placeholder, in gray rather than this
    // row's usual black, as a hint at what to type rather than an
    // actual value. v itself - what editing would actually start
    // from - is untouched.
    if (!editingThis && v.equals("") && placeholder != null && !placeholder.equals("")) {
      strokeWeight(0);
      stroke(127);
      fill(127);
      textSize(1.0 * lineH);
      textAlign(LEFT, CENTER);
      text(placeholder, x - w1 + t_oW, this.lastSpinnerTextRowFirstLineY - t_oH);
    }

    if (editingThis) displayValue = this.editText;

    strokeWeight(0);
    stroke(0);
    fill(0);
    textSize(0.85 * lineH);
    textAlign(LEFT, CENTER);
    text(caption + ":", x - w1 - w2 + t_oW, this.lastSpinnerTextRowFirstLineY - t_oH);

    return displayValue;
  }

  // {x,y,w,h} of a row's remove ("x") button - same look hover.pde's own
  // pinned-hover-box close button uses (drawHoverCloseButton(), and that
  // file's own hoverCloseButtonSize/hoverCloseButtonGap constants). x is
  // the row's own left-anchor x (the same value passed as _SpinnerText()'s
  // own x parameter), so the button lands in the SAME column as that
  // row's up/down scroll arrows (just right of the value box, at x+o,
  // _SpinnerText()'s own arrow placement) rather than off on the panel's
  // far right edge - stacked directly above them instead of nowhere near
  // them. One function for both drawing and hit-testing, same reasoning
  // as hover.pde's own hoverCloseButtonRect(): the drawn button and the
  // clickable area can never drift apart.
  float[] extraParamsRemoveButtonRect (float x, float y) {
    float size = hoverCloseButtonSize;
    float o = 2 * this.view_S; // matches _SpinnerText()'s own "o" - the gap its scroll arrows sit at (x+o) too
    float bx = x + o;
    float yy = y - size / 2;
    return new float[]{ bx, yy, size, size };
  }

  void drawExtraParamsRemoveButton (float x, float y) {
    float[] btn = extraParamsRemoveButtonRect(x, y);
    float bx = btn[0], by = btn[1], bw = btn[2], bh = btn[3];

    stroke(0);
    strokeWeight(1);
    fill(63, 191, 63); // same green hover.pde's drawHoverCloseButton() uses
    rect(bx, by, bw, bh);

    float pad = bw * 0.25;
    strokeWeight(3);
    stroke(255); // white "x", same as hover.pde's own close button
    line(bx + pad, by + pad, bx + bw - pad, by + bh - pad);
    line(bx + bw - pad, by + pad, bx + pad, by + bh - pad);
  }

  // Checked by drawExtraParamsSelectedEntityTab()/drawExtraParamsBulkEditPanel()
  // BEFORE handing that row's click to
  // _SpinnerText() - same ordering mouseClicked.pde's own check against
  // hover.pde's hoverPointAtCloseButton() keeps ahead of placing a new
  // hover pin, so a click meant to remove a row can never be misread as
  // a click into the text field sitting right behind it.
  boolean extraParamsRemoveButtonClicked (float x, float y) {
    float[] btn = extraParamsRemoveButtonRect(x, y);
    return isInside(X_clicked, Y_clicked, btn[0], btn[1], btn[0] + btn[2], btn[1] + btn[3]);
  }

  // A lightweight 0/1 toggle for PARENT_EXTRA_PARAMS's own per-row
  // expand/collapse control (extraParamsRowLevel, below) - same
  // caption/value-box look _Spinner() uses (and, like it, Tab/Shift+Tab/
  // Esc/Enter-editable and typeable via the shared numeric keyPressed()
  // path - beginSpinnerEdit() leaves editIsText false), but with only
  // ONE arrow button, at the exact size and position of _Spinner()'s own
  // down arrow (the bottom half of its usual stacked up/down pair) -
  // nothing is drawn where the up arrow would otherwise go, above it. A
  // control that only ever holds two values doesn't need separate
  // increment/decrement buttons, since there's nowhere else for either
  // one to go but the other value; a right-click, like _Spinner()'s own
  // down arrow, also just flips it - there's no separate "jump to
  // minimum" distinct from that here.
  int extraParamsLevelToggle (float x, float y, String caption, int level) {

    float w1 = 100 * UI_rollout.view_S;
    float w2 = 200 * UI_rollout.view_S;
    float h = 13 * UI_rollout.view_S;
    float o = 2 * UI_rollout.view_S;
    float t_oW = h * UI_rollout.view_S / 8.0;
    float t_oH = t_oW - 3;

    Y_control += 20 * UI_rollout.view_S;

    this.spinnerOrderThisPass.add(caption);

    int newLevel = level;

    boolean editingThis = this.editActive && this.editCaption.equals(caption);

    if (editingThis && this.editCommit) {

      int typedValue = level;
      try {
        typedValue = Math.round(Float.parseFloat(this.editText));
      } catch (Exception ex) {
        typedValue = level;
      }
      newLevel = typedValue;

      this.editActive = false;
      this.editCaption = "";
      this.editText = "";
      this.editCursor = 0;
      this.editCommit = false;

      editingThis = false;
      this.editStateChanged = true;

      UI_rollout.revise();
    }

    if ((this.editPendingCaption != null) && this.editPendingCaption.equals(caption) && !editingThis) {
      this.beginSpinnerEdit(caption, level);
      this.editPendingCaption = null;
      editingThis = true;
    }

    if ((!this.editActive || editingThis) && (
      isInside(X_clicked, Y_clicked, x - w1 - w2 - o, y - (h / 2) - o, x - w1, y + (h / 2) + o) ||
      isInside(X_clicked, Y_clicked, x - w1,          y - (h / 2), x,          y + (h / 2))
    )) {
      if (mouseButton == LEFT) {
        if (!editingThis) {
          this.beginSpinnerEdit(caption, level);
          editingThis = true;
        }
        X_clicked = -1;
        Y_clicked = -1;
      }
    }

    // _Spinner()'s own value bar accepts a right click anywhere over it,
    // not just on its arrows ("change value by right click over the
    // bar"), landing on whatever value the click's own position along
    // the bar works out to (q = fraction across the bar, 0 at the left
    // edge to 1 at the right) - this mirrors that for the value box
    // here, since "right click on the right half of the level spinner"
    // (the original ask) reads as this box, the control's visually
    // obvious right side, not the much smaller arrow button further
    // right still. This toggle only has the two states 0/1 rather than
    // a continuous range, so instead of _Spinner()'s own proportional
    // q * (max_v - min_v) it just splits the box at its own midpoint:
    // right click on the left half sets 0, right click on the right
    // half sets 1 - same two-way split q itself would land on here.
    if (!this.editActive && isInside(X_clicked, Y_clicked, x - w1, y - (h / 2), x, y + (h / 2))) {
      if (mouseButton == RIGHT) {
        newLevel = (X_clicked < x - w1 / 2.0) ? 0 : 1;
        X_clicked = -1;
        Y_clicked = -1;
      }
    }

    // Same size and position as _Spinner()'s own down arrow (the bottom
    // half of its stacked up/down pair, below) - just that one square,
    // with nothing drawn above it where the up arrow would otherwise go.
    strokeWeight(0);
    stroke(0);
    fill(0);
    rect(x + o, y - (h / 2) - o + 0.5 * (h + 2 * o), 0.5 * (h + 2 * o), 0.5 * (h + 2 * o));

    stroke(255);
    fill(255);
    float cx = x + o + 0.25 * (h + 2 * o);
    float cy = y - (h / 2) - o + 0.75 * (h + 2 * o);
    float cr = 0.25 * (h + 2 * o);
    triangle(cx + cr * funcs.cos_ang(90), cy + 0.75 * cr * funcs.sin_ang(90), cx + 0.75 * cr * funcs.cos_ang(210), cy + 0.75 * cr * funcs.sin_ang(210), cx + 0.75 * cr * funcs.cos_ang(330), cy + 0.75 * cr * funcs.sin_ang(330));

    if (!this.editActive && isInside(X_clicked, Y_clicked, x + o, y - (h / 2) - o + 0.5 * (h + 2 * o), x + o + 0.5 * (h + 2 * o), y - (h / 2) - o + (h + 2 * o))) {
      if (mouseButton == LEFT) {
        newLevel = (level == 0) ? 1 : 0;
      } else if (mouseButton == RIGHT) {
        // Same convention _Spinner()'s own arrows use - right-click jumps
        // straight to an extreme (there, max_v/min_v) rather than
        // stepping - here the only "extreme" a right-click on this
        // single button sets is 1, expanding the row outright regardless
        // of its current level.
        newLevel = 1;
      }
      X_clicked = -1;
      Y_clicked = -1;
    }

    if (newLevel < 0) newLevel = 0;
    if (newLevel > 1) newLevel = 1;

    // Same darker gray _SpinnerText() now uses for this key's own
    // children (when they're showing) rather than the plain 191 every
    // other spinner's own caption/value background uses - so this row
    // and the child rows it reveals below read as one grouped cluster.
    strokeWeight(0);
    if (editingThis) {
      stroke(255, 127, 0);
      fill(255, 127, 0);
    } else {
      stroke(140);
      fill(140);
    }
    rect(x - (w1 + w2) - o, y - (h / 2) - o, (w1 + w2) + 2 * o, h + 2 * o);

    stroke(255);
    fill(255);
    rect(x - w1, y - (h / 2), w1, h);

    // _Spinner()'s own light-green fill bar ("q * w1" wide, q being how
    // far the value sits between min_v and max_v) drawn over the white
    // box before the border goes on - this toggle's own q is just
    // newLevel itself (0 or 1), so the bar is either empty (level 0) or
    // fills the whole box (level 1), same look every other spinner's
    // value box has.
    strokeWeight(0);
    stroke(191, 255, 191);
    fill(191, 255, 191);
    rect(x - w1, y - (h / 2), newLevel * w1, h);

    strokeWeight(2);
    stroke(0);
    noFill();
    rect(x - w1, y - (h / 2), w1, h);

    strokeWeight(0);
    stroke(0);
    fill(0);
    textSize(1.0 * h);
    textAlign(LEFT, CENTER);
    if (editingThis) {
      String textWithCursor = this.editText.substring(0, this.editCursor) + "|" + this.editText.substring(this.editCursor);
      text(textWithCursor, x - w1 + t_oW, y - t_oH);
    } else {
      text(str(newLevel), x - w1 + t_oW, y - t_oH);
    }

    strokeWeight(0);
    stroke(0);
    fill(0);
    textSize(0.85 * h);
    textAlign(LEFT, CENTER);
    text(caption + ":", x - w1 - w2 + t_oW, y - t_oH);

    if (level != newLevel) displayDirective(ACTION_HEAD + caption + " " + newLevel);

    return newLevel;
  }

  // Ephemeral per-row expand/collapse state - key name to level (0 or
  // 1), one entry per top-level JSONObject-valued key only (a level-1
  // child never gets its own level control - see the file-header
  // comment above). Deliberately never written into extraParams itself
  // (would corrupt every exporter's own round-trip and this app's
  // existing tests - see extraParamsPath.pde), and cleared whenever the
  // single-entity selection changes (drawExtraParamsSelectedEntityTab(), below), so
  // selecting a different entity never shows a stale expand state left
  // over from a previous one.
  HashMap<String,Integer> extraParamsRowLevel = new HashMap<String,Integer>();
  String extraParamsLastSelectionSignature = "";

  // CHILD_EXTRA_PARAMS_SELECTED_ENTITY - the single-entity view/edit tab.
  // Bulk editing is the separate CHILD_EXTRA_PARAMS_BULK_EDIT tab
  // (drawExtraParamsBulkEditTab(), below, which also works down to one
  // entity) rather than something this tab auto-switches into - picking
  // which to look at is the person's own choice of tab, not inferred
  // from however many entities happen to be selected right now.
  void drawExtraParamsSelectedEntityTab () {

    ExtraParamsSelectionTarget target = currentExtraParamsSelection();

    String signature = (target == null) ? "" : (target.category + ":" + target.index);
    if (!signature.equals(this.extraParamsLastSelectionSignature)) {
      this.extraParamsRowLevel.clear();
      this.spinnerTextScroll.clear();
      this.extraParamsLastSelectionSignature = signature;
    }

    if (target == null) {
      fill(127);
      textAlign(LEFT, CENTER);
      textSize(12 * this.view_S);
      text(
        "Select exactly one entity\nto view/edit its extra parameters.",
        this.cX + 10 * this.view_S, Y_control + 20 * this.view_S
      );
      Y_control += 50 * this.view_S;
      return;
    }

    JSONObject obj = getExtraParamsObjectForSelection(target);
    boolean changed = false;

    ArrayList<String> topKeys = new ArrayList<String>(obj.keys());
    java.util.Collections.sort(topKeys); // deterministic row order - JSONObject.keys() itself makes no ordering promise

    for (String key : topKeys) {

      Object value = obj.get(key);
      boolean isObject = (value instanceof JSONObject);
      String shownValue = isObject ? ((JSONObject) value).toString() : String.valueOf(value);

      this._SpinnerText(X_control, Y_control, key, shownValue);
      float rowY = this.lastSpinnerTextRowFirstLineY; // where _SpinnerText just landed this row's TOP line - read back after the call since a wrapped multi-line value makes the row's own height variable, so this row's remove button lands on its first line, not wherever a fixed single-line guess would have put it

      if (extraParamsRemoveButtonClicked(X_control, rowY)) {
        X_clicked = -1;
        Y_clicked = -1;
        extraParamsRemoveAtPath(obj, key);
        this.extraParamsRowLevel.remove(key);
        changed = true;
      } else {
        this.drawExtraParamsRemoveButton(X_control, rowY);
      }

      if (this.textEditJustCommitted) {
        extraParamsSetAtPath(obj, key, this.textEditCommittedValue);
        this.textEditJustCommitted = false;
        changed = true;
      }

      if (isObject) {
        int level = this.extraParamsRowLevel.containsKey(key) ? this.extraParamsRowLevel.get(key) : 0;
        int newLevel = this.extraParamsLevelToggle(X_control, Y_control, key + " > Level", level);
        this.extraParamsRowLevel.put(key, newLevel);

        if (newLevel >= 1) {
          JSONObject child = (JSONObject) value;
          ArrayList<String> childKeys = new ArrayList<String>(child.keys());
          java.util.Collections.sort(childKeys);

          for (String childKey : childKeys) {
            String path = key + "." + childKey;
            Object childValue = child.get(childKey);
            String childShown = (childValue instanceof JSONObject) ? ((JSONObject) childValue).toString() : String.valueOf(childValue);
            // A level-1 child is always shown as a leaf row, whatever its
            // own value is - no further level control, even if childValue
            // is itself a JSONObject (extraParamsLevelToggle()'s own fixed
            // 0/1 range is the locked cap).

            this._SpinnerText(X_control, Y_control, path, childShown, true);
            float childRowY = this.lastSpinnerTextRowFirstLineY;

            if (extraParamsRemoveButtonClicked(X_control, childRowY)) {
              X_clicked = -1;
              Y_clicked = -1;
              extraParamsRemoveAtPath(obj, path);
              changed = true;
            } else {
              this.drawExtraParamsRemoveButton(X_control, childRowY);
            }

            if (this.textEditJustCommitted) {
              extraParamsSetAtPath(obj, path, this.textEditCommittedValue);
              this.textEditJustCommitted = false;
              changed = true;
            }
          }
        }
      }
    }

    // Blank "add a new key" row - typing "key": "value" (or bare
    // key: value) and committing. Split on the first ":" here, UI-side,
    // rather than on the first whitespace the way EXTRAPARAMS.SET's own
    // raw command line is split (extraParamsFirstToken/
    // extraParamsRestAfterFirstToken, extraCommands.pde) - a JSON value
    // is frequently going to contain its own spaces, where it'd never
    // contain the ":" this box asks for instead. The key side's own
    // quotes, if typed, are purely cosmetic (matching ordinary JSON
    // object-literal look, per the placeholder below) and are stripped
    // here before use - unlike the value, a key is never run through
    // extraParamsParseCommandValue()'s own JSON decoding, so a key typed
    // AS "ifcShape" with its quotes left in would otherwise become the
    // literal 9-character key `"ifcShape"`, quote marks and all, not
    // the 8-character key ifcShape. Once split and unquoted, the pieces
    // are passed on as that same space-separated
    // "EXTRAPARAMS.SET <key> <value>" command line regardless - key
    // still can't itself contain whitespace, same as it never could, and
    // extraParamsRestAfterFirstToken happily takes a multi-word value
    // from after the first space exactly as before.
    this._SpinnerText(X_control, Y_control, "+ Add", "", false, true, "\"key\": \"value\"");
    if (this.textEditJustCommitted) {
      this.textEditJustCommitted = false;
      String typed = this.textEditCommittedValue;
      int colonIndex = typed.indexOf(':');
      if (colonIndex >= 0) {
        String newKey = typed.substring(0, colonIndex).strip();
        String newValue = typed.substring(colonIndex + 1).strip();
        if (newKey.length() >= 2 && newKey.startsWith("\"") && newKey.endsWith("\"")) {
          newKey = newKey.substring(1, newKey.length() - 1);
        }
        if (!newKey.equals("")) {
          runScriptLine("EXTRAPARAMS.SET " + newKey + " " + newValue);
          // runScriptLine() already wrote the change straight through
          // getExtraParamsObjectForSelection()/setExtraParamsObjectForSelection() -
          // obj (read before this call) is now stale, so this does NOT
          // also set changed=true/write obj back below, which would
          // otherwise clobber the add with whatever obj looked like before it.
        }
      }
    }

    if (changed) {
      // One shared "changed" flag for every row this frame (top-level
      // remove/edit and, for an expanded key, its own children), so
      // wrapping just this one write-back - rather than each row's own
      // extraParamsSetAtPath()/extraParamsRemoveAtPath() call above -
      // already records whatever changed this frame as a single undo
      // step, same reasoning globalFunctions.pde's own beginScene3DChange()
      // comment gives for a composite operation.
      beginScene3DChange();
      setExtraParamsObjectForSelection(target, obj);
      endScene3DChange();
      UI_rollout.revise();
    }
  }

  // CHILD_EXTRA_PARAMS_BULK_EDIT - the bulk-edit tab's own entry point,
  // parallel to drawExtraParamsSelectedEntityTab() above. Works down to
  // a single selected entity too (there's then nothing to disagree with,
  // so every one of that entity's own keys is trivially "common") -
  // the Selected Entity tab stays the one with the Level toggle/child-row
  // expansion, so this is still the simpler, flat alternative even for
  // one entity. Only keys common to every selected entity are shown (an
  // intersection, not a union) - simpler to reason about than a per-
  // entity presence/absence distinction, and matches how other
  // applications already handle a multi-selection's shared properties.
  // No Level toggle/child-row expansion here even for an object-valued
  // common key - v1 scope is flat, top-level keys only; an object value
  // still shows (and is still editable) as its own flat JSON text, same
  // as any top-level row already does before it's expanded in the
  // Selected Entity tab.
  void drawExtraParamsBulkEditTab () {

    ArrayList<ExtraParamsSelectionTarget> list = currentExtraParamsSelectionList();

    StringBuilder sigBuilder = new StringBuilder();
    for (ExtraParamsSelectionTarget t : list) {
      if (sigBuilder.length() > 0) sigBuilder.append(",");
      sigBuilder.append(t.category).append(":").append(t.index);
    }
    String signature = sigBuilder.toString();
    if (!signature.equals(this.extraParamsLastSelectionSignature)) {
      this.extraParamsRowLevel.clear();
      this.spinnerTextScroll.clear();
      this.extraParamsLastSelectionSignature = signature;
    }

    if (list.size() < 1) {
      fill(127);
      textAlign(LEFT, CENTER);
      textSize(12 * this.view_S);
      text(
        "Select one or more entities\nto bulk edit their extra parameters.",
        this.cX + 10 * this.view_S, Y_control + 20 * this.view_S
      );
      Y_control += 50 * this.view_S;
      return;
    }

    this.drawExtraParamsBulkEditPanel(list);
  }

  void drawExtraParamsBulkEditPanel (ArrayList<ExtraParamsSelectionTarget> list) {

    fill(127);
    textAlign(LEFT, CENTER);
    textSize(12 * this.view_S);
    text(
      list.size() + " entit" + (list.size() == 1 ? "y" : "ies") + " selected",
      this.cX + 10 * this.view_S, Y_control + 10 * this.view_S
    );
    Y_control += 30 * this.view_S;

    ArrayList<JSONObject> objs = new ArrayList<JSONObject>();
    for (ExtraParamsSelectionTarget t : list) objs.add(getExtraParamsObjectForSelection(t));

    ArrayList<String> commonKeys = new ArrayList<String>(objs.get(0).keys());
    for (int i = 1; i < objs.size(); i++) {
      commonKeys.retainAll(objs.get(i).keys());
    }
    java.util.Collections.sort(commonKeys); // deterministic row order, same reasoning as the Selected Entity path's own topKeys sort

    for (String key : commonKeys) {

      // "various", placeholder-styled exactly like the "+ Add" row's own
      // "\"key\": \"value\"" hint below - gray, not part of the real
      // value, and editing starts from a blank box rather than any one
      // entity's own value, so a typed edit is never mistaken for "this is
      // what entity N already had".
      String firstShown = null;
      boolean uniform = true;
      for (JSONObject o : objs) {
        Object v = o.get(key);
        String shown = (v instanceof JSONObject) ? ((JSONObject) v).toString() : String.valueOf(v);
        if (firstShown == null) firstShown = shown;
        else if (!firstShown.equals(shown)) uniform = false;
      }

      this._SpinnerText(X_control, Y_control, key, uniform ? firstShown : "", false, uniform ? null : "various");
      float rowY = this.lastSpinnerTextRowFirstLineY;

      if (extraParamsRemoveButtonClicked(X_control, rowY)) {
        X_clicked = -1;
        Y_clicked = -1;
        beginScene3DChange(); // one click, one undo step, however many entities this common-key row updates
        for (int i = 0; i < list.size(); i++) {
          extraParamsRemoveAtPath(objs.get(i), key);
          setExtraParamsObjectForSelection(list.get(i), objs.get(i));
        }
        endScene3DChange();
        UI_rollout.revise();
      } else {
        this.drawExtraParamsRemoveButton(X_control, rowY);
      }

      if (this.textEditJustCommitted) {
        String typedValue = this.textEditCommittedValue;
        this.textEditJustCommitted = false;
        beginScene3DChange(); // one commit, one undo step, however many entities this common-key row updates
        for (int i = 0; i < list.size(); i++) {
          extraParamsSetAtPath(objs.get(i), key, typedValue);
          setExtraParamsObjectForSelection(list.get(i), objs.get(i));
        }
        endScene3DChange();
        UI_rollout.revise();
      }
    }

    // Same "+ Add" row/placeholder/colon-split convention as the
    // Selected Entity path, except its commit applies the new key/value
    // to every selected entity rather than just one.
    // EXTRAPARAMS.SET's own command dispatch only ever resolves a single
    // current selection (deliberately - see
    // extraparamsSet_multipleSelected_isTreatedAsNoSelection,
    // test/ExtraParamsCommandTest.java), so this writes each entity's own
    // JSONObject directly rather than going through runScriptLine(). Re-
    // fetches each entity's object fresh here rather than reusing objs[]:
    // only one of this row's own commit or a commonKeys row's own
    // commit/remove above can ever fire in the same frame (one shared
    // textEditJustCommitted flag, one click), so this is never strictly
    // needed to avoid clobbering a same-frame edit - it's just as cheap
    // as reusing objs[] and one less thing to reason about if that ever
    // changes.
    this._SpinnerText(X_control, Y_control, "+ Add", "", false, true, "\"key\": \"value\"");
    if (this.textEditJustCommitted) {
      this.textEditJustCommitted = false;
      String typed = this.textEditCommittedValue;
      int colonIndex = typed.indexOf(':');
      if (colonIndex >= 0) {
        String newKey = typed.substring(0, colonIndex).strip();
        String newValue = typed.substring(colonIndex + 1).strip();
        if (newKey.length() >= 2 && newKey.startsWith("\"") && newKey.endsWith("\"")) {
          newKey = newKey.substring(1, newKey.length() - 1);
        }
        if (!newKey.equals("")) {
          beginScene3DChange(); // one commit, one undo step, for every selected entity this "+ Add" writes to
          for (ExtraParamsSelectionTarget t : list) {
            JSONObject o = getExtraParamsObjectForSelection(t);
            extraParamsSetAtPath(o, newKey, newValue);
            setExtraParamsObjectForSelection(t, o);
          }
          endScene3DChange();
          UI_rollout.revise();
        }
      }
    }
  }

  // CHILD_EXTRA_PARAMS_ASSIGN_MISSING - the third PARENT_EXTRA_PARAMS
  // tab, for topping up a key that most but not every selected entity
  // already carries, without touching the entities that already have
  // it (that's what sets this apart from Bulk Edit's own "+ Add" row,
  // which always writes to every selected entity). Shows every key
  // present on at least one selected entity but absent from at least
  // one other - the complement of Bulk Edit's own common-keys
  // intersection, so a key lands on exactly one of the two tabs (or
  // neither, if it's on none of the selection) - with a running count
  // of how many of the selection are missing it, and commits a typed
  // value only to the entities currently missing that key. Same v1
  // scope as Bulk Edit: flat top-level keys only, no Level toggle/
  // child-row expansion, and no remove button - removing isn't really
  // "filling a gap", so it's left to the Bulk Edit/Selected Entity tabs
  // if it's ever needed here. "Missing" means the key isn't in
  // obj.keys() at all; a key present with a JSON null value already has
  // the key, so it isn't "missing" by this tab's own definition, same
  // as commonKeys' own intersection above never distinguishes "absent"
  // from "present but null" either.
  void drawExtraParamsAssignMissingTab () {

    ArrayList<ExtraParamsSelectionTarget> list = currentExtraParamsSelectionList();

    StringBuilder sigBuilder = new StringBuilder();
    for (ExtraParamsSelectionTarget t : list) {
      if (sigBuilder.length() > 0) sigBuilder.append(",");
      sigBuilder.append(t.category).append(":").append(t.index);
    }
    String signature = sigBuilder.toString();
    if (!signature.equals(this.extraParamsLastSelectionSignature)) {
      this.extraParamsRowLevel.clear();
      this.spinnerTextScroll.clear();
      this.extraParamsLastSelectionSignature = signature;
    }

    if (list.size() < 2) {
      fill(127);
      textAlign(LEFT, CENTER);
      textSize(12 * this.view_S);
      text(
        "Select two or more entities\nto see which properties are missing\nfrom some but not all of them.",
        this.cX + 10 * this.view_S, Y_control + 28 * this.view_S
      );
      Y_control += 70 * this.view_S;
      return;
    }

    ArrayList<JSONObject> objs = new ArrayList<JSONObject>();
    for (ExtraParamsSelectionTarget t : list) objs.add(getExtraParamsObjectForSelection(t));

    // Union of every key present on at least one selected entity, minus
    // the ones present on every selected entity (the same intersection
    // drawExtraParamsBulkEditPanel() computes as commonKeys) - what's
    // left is "present on some, absent from others". A LinkedHashSet
    // just to build the union without duplicates; sorted into an
    // ArrayList right after for the same deterministic row order every
    // other tab's own key list already uses.
    java.util.LinkedHashSet<String> unionKeys = new java.util.LinkedHashSet<String>();
    for (JSONObject o : objs) unionKeys.addAll(o.keys());

    ArrayList<String> partialKeys = new ArrayList<String>();
    for (String key : unionKeys) {
      int presentCount = 0;
      for (JSONObject o : objs) if (o.keys().contains(key)) presentCount++;
      if (presentCount > 0 && presentCount < objs.size()) partialKeys.add(key);
    }
    java.util.Collections.sort(partialKeys);

    if (partialKeys.size() == 0) {
      fill(127);
      textAlign(LEFT, CENTER);
      textSize(12 * this.view_S);
      text(
        "Every key is either on all or none of the\n" + list.size() + " selected entities.",
        this.cX + 10 * this.view_S, Y_control + 20 * this.view_S
      );
      Y_control += 50 * this.view_S;
      return;
    }

    for (String key : partialKeys) {

      int missingCount = 0;
      for (JSONObject o : objs) if (!o.keys().contains(key)) missingCount++;

      // The row's own caption doubles as _SpinnerText()'s per-row
      // identity key (editCaption/spinnerTextScroll, uiRollout.pde
      // above) - safe to fold the live "missing N/M" count into it here
      // because that count can only change right after THIS row's own
      // commit below, by which point _SpinnerText() has already cleared
      // editActive/editCaption for it, so there's no frame where a
      // still-being-typed row's identity shifts out from under it.
      this._SpinnerText(
        X_control, Y_control,
        key + " (missing " + missingCount + "/" + list.size() + ")",
        "", false, "value to assign"
      );

      if (this.textEditJustCommitted) {
        String typedValue = this.textEditCommittedValue;
        this.textEditJustCommitted = false;
        beginScene3DChange(); // one commit, one undo step, for however many entities were missing this key
        for (int i = 0; i < objs.size(); i++) {
          if (!objs.get(i).keys().contains(key)) {
            extraParamsSetAtPath(objs.get(i), key, typedValue);
            setExtraParamsObjectForSelection(list.get(i), objs.get(i));
          }
        }
        endScene3DChange();
        UI_rollout.revise();
      }
    }
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

  // --- Continuous key-hold repeat (see viewport3D.pde) -----------------------
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

    boolean isRepeatableArrow = isCoded && ((code == LEFT) || (code == RIGHT) || (code == UP) || (code == DOWN));
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
        if (this.editIsText) {
          // A text row has no numeric sign to restrict - '-' is just an
          // ordinary character here, same as any letter below.
          this.editText = this.editText.substring(0, this.editCursor) + key + this.editText.substring(this.editCursor);
          this.editCursor++;
          this.revise();
        } else if ((this.editCursor == 0) && ((this.editText.length() == 0) || (this.editText.charAt(0) != '-'))) {
          // A minus sign is only meaningful as the very first character.
          this.editText = "-" + this.editText;
          this.editCursor++;
          this.revise();
        }
        break;

      default:
        if (this.editIsText) {
          // Any printable character is valid JSON-value text (letters,
          // spaces, punctuation, quotes, braces, ...) - unlike the
          // numeric spinners below, a text row's own commit
          // (_SpinnerText()'s editCommit handling) takes editText
          // verbatim rather than Float.parseFloat()'ing it, so nothing
          // here needs restricting beyond excluding control characters.
          if (!Character.isISOControl(key)) {
            this.editText = this.editText.substring(0, this.editCursor) + key + this.editText.substring(this.editCursor);
            this.editCursor++;
            this.revise();
          }
        } else if ((key >= '0') && (key <= '9')) {
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

  // Applies one Left/Right/Up/Down cursor move or Backspace/Delete edit.
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

        case UP:
        case DOWN:
          // Only a text row's value can wrap across multiple lines in
          // the first place, so only there does Up/Down mean anything.
          // The wrap is re-derived here from this.editText itself, not
          // read from anything _SpinnerText() cached on an earlier
          // frame: this runs from a raw key event, which can land
          // between frames (most obviously, the very frame a click
          // first puts a row into edit mode - _SpinnerText() handles
          // that click after it would otherwise have cached the wrap,
          // so nothing valid exists yet for the row now being edited).
          // Recomputing here instead means Up/Down can never move the
          // cursor using another row's, or no row's, offsets.
          if (this.editIsText) {
            textSize(1.0 * spinnerTextLineHeight());
            ArrayList<String> lines = new ArrayList<String>();
            ArrayList<Integer> lineStarts = new ArrayList<Integer>();
            wrapTextLines(this.editText, spinnerTextWrapWidth(), lines, lineStarts);

            int li = spinnerTextLineIndexForCursor(lineStarts, lines, this.editCursor);
            int col = this.editCursor - lineStarts.get(li);
            int targetLi = (code == UP) ? (li - 1) : (li + 1);

            if ((targetLi >= 0) && (targetLi < lines.size())) {
              int targetStart = lineStarts.get(targetLi);
              int targetLen = lines.get(targetLi).length();
              this.editCursor = targetStart + min(col, targetLen);
              this.revise();
            }
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
