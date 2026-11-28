int calcRolloutWidth () {
  return int(27 * MessageSize);
}

// Getter/setter pairs for UI_rollout's own modifySelectedIntField()/
// modifySelectedFloatField() (used by drawPropertiesModifySelectedTab(),
// below) - same FloatGetter/FloatSetter reasoning as actions.pde's own
// pair (an existing field plugged into generic, reusable machinery),
// just indexed by entity rather than bound to one fixed field, and an
// int flavor added alongside since most of the fields below are
// integers, not floats. Declared at file scope (same as actions.pde's
// own interfaces) rather than nested inside the UI_rollout class itself:
// UI_rollout is a non-static inner class of the sketch's own main class,
// and a member interface (implicitly static) can't be declared inside a
// non-static inner class.
interface IntFieldGetter { int get (int index); }
interface IntFieldSetter { void set (int index, int value); }
interface FloatFieldGetter { float get (int index); }
interface FloatFieldSetter { void set (int index, float value); }

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

  // --- Side scroll for the current tab's own content ----------------------
  // Some tabs (a long Scene Explorer tree, Bulk Edit with many keys, ...)
  // draw taller than the space between the parent/child tab-selector grid
  // and the two pinned "SOLARCHVISION ..." buttons at the panel's bottom
  // (draw(), further below, clips and offsets that content by
  // rolloutScrollY so it can be scrolled rather than running under those
  // buttons - see draw()'s own comment at the point it does so). These
  // fields are all set/read there and by the scrollbar's own methods
  // further below (drawRolloutScrollbar() and friends).
  float rolloutScrollY = 0;          // current scroll offset into this tab's content, 0 = top
  float rolloutContentHeight = 0;    // this tab's own unscrolled content height, measured fresh each draw()
  float rolloutContentTopY = 0;      // absolute screen Y where the scrollable area begins, set each draw()
  float rolloutContentBottomY = 0;   // absolute screen Y where the scrollable area ends, set each draw()

  // Which parent/child this.rolloutScrollY was last measured against - a
  // leftover scroll offset from a much taller tab would otherwise
  // misalign (or entirely hide) a much shorter one, so switching tabs
  // resets it back to the top (see draw()'s own check against these).
  int _rolloutScrollParent = -1;
  int _rolloutScrollChild = -1;

  boolean rolloutScrollThumbDragging = false;
  float rolloutScrollDrag_startMouseY = 0;
  float rolloutScrollDrag_startScrollY = 0;

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

    PARENT_PROPERTIES = pushParent("Properties");
    CHILD_PROPERTIES_MODIFY_SELECTED = pushChild("Modify Selected");

    PARENT_EXTRA_PARAMS = pushParent("Extra Params");
    CHILD_EXTRA_PARAMS_SELECTED_ENTITY = pushChild("Selected Entity");
    CHILD_EXTRA_PARAMS_BULK_EDIT = pushChild("Bulk Edit");
    CHILD_EXTRA_PARAMS_ASSIGN_MISSING = pushChild("Assign Missing");

    PARENT_SCENE_EXPLORER = pushParent("Scene Explorer");
    CHILD_SCENE_EXPLORER_SELECT = pushChild("Select");
    CHILD_SCENE_EXPLORER_ISOLATE = pushChild("Isolate");
    CHILD_SCENE_EXPLORER_LOOK_AT = pushChild("Look At");
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

  int PARENT_PROPERTIES;
  int CHILD_PROPERTIES_MODIFY_SELECTED;

  int PARENT_EXTRA_PARAMS;
  int CHILD_EXTRA_PARAMS_SELECTED_ENTITY;
  int CHILD_EXTRA_PARAMS_BULK_EDIT;
  int CHILD_EXTRA_PARAMS_ASSIGN_MISSING;

  int PARENT_SCENE_EXPLORER;
  int CHILD_SCENE_EXPLORER_SELECT;
  int CHILD_SCENE_EXPLORER_ISOLATE;
  int CHILD_SCENE_EXPLORER_LOOK_AT;

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

    // Switching tabs resets the scroll back to the top - see this.
    // rolloutScrollY's own comment, above.
    if ((this.parent != this._rolloutScrollParent) || (this.child != this._rolloutScrollChild)) {
      this.rolloutScrollY = 0;
      this._rolloutScrollParent = this.parent;
      this._rolloutScrollChild = this.child;
    }

    // The scrollable area for whichever tab's content follows: from here
    // (just below the parent/child tab-selector grid above) down to just
    // above the two pinned "SOLARCHVISION ..." buttons
    // (renderSectionsButtonBounds(), further below - the first/topmost of
    // the two, so this never has to care that there's a second one
    // stacked under it). clip() keeps that content from drawing over
    // those buttons once it's scrolled; the Y_control offset is what
    // actually scrolls it. Both are undone (noClip(), Y_control put back)
    // right after the content dispatch below - this.drawRolloutScrollbar()
    // itself must run unclipped and unoffset, since it's the control FOR
    // this offset, not part of the content being offset.
    this.rolloutContentTopY = Y_control;
    this.rolloutContentBottomY = this.renderSectionsButtonBounds()[2] - 3 * this.view_S;

    Y_control -= this.rolloutScrollY;

    clip(this.cX, this.rolloutContentTopY, this.dX, this.rolloutContentBottomY - this.rolloutContentTopY);

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

    } else if (this.parent == PARENT_PROPERTIES) {

      if (this.child == CHILD_PROPERTIES_MODIFY_SELECTED) {
        this.drawPropertiesModifySelectedTab();
      }
    } else if (this.parent == PARENT_EXTRA_PARAMS) {

      if (this.child == CHILD_EXTRA_PARAMS_SELECTED_ENTITY) {
        this.drawExtraParamsSelectedEntityTab();
      } else if (this.child == CHILD_EXTRA_PARAMS_BULK_EDIT) {
        this.drawExtraParamsBulkEditTab();
      } else if (this.child == CHILD_EXTRA_PARAMS_ASSIGN_MISSING) {
        this.drawExtraParamsAssignMissingTab();
      }
    } else if (this.parent == PARENT_SCENE_EXPLORER) {

      if (this.child == CHILD_SCENE_EXPLORER_SELECT) {
        this.drawSceneExplorerSelectTab();
      } else if (this.child == CHILD_SCENE_EXPLORER_ISOLATE) {
        this.drawSceneExplorerIsolateTab();
      } else if (this.child == CHILD_SCENE_EXPLORER_LOOK_AT) {
        this.drawSceneExplorerLookAtTab();
      }
    }

    // End of this tab's own (possibly clipped/offset) content - see this
    // same method's own comment where rolloutContentTopY/
    // rolloutContentBottomY were set, above. Measuring the content's real
    // (unscrolled) height here needs Y_control's offset added back first
    // (it was subtracted, not added, right before the content above) -
    // this is the same "undo scrollY" the Y_control reassignment just
    // below also does, just done once more here first since this line
    // needs the IN-BETWEEN (still-offset) value for nothing else.
    noClip();

    this.rolloutContentHeight = (Y_control + this.rolloutScrollY) - this.rolloutContentTopY;

    float rolloutVisibleHeight = this.rolloutContentBottomY - this.rolloutContentTopY;
    float rolloutMaxScroll = max(0, this.rolloutContentHeight - rolloutVisibleHeight);
    this.rolloutScrollY = constrain(this.rolloutScrollY, 0, rolloutMaxScroll);

    this.drawRolloutScrollbar();

    Y_control += this.rolloutScrollY; // put back to the unoffset value, for whatever (if anything) runs after this

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

  // --- Side scroll for the current tab's own content -----------------------
  // A narrow vertical scrollbar, pinned to the panel's right edge, for
  // whichever tab's content (draw(), above) is currently taller than
  // rolloutContentTopY..rolloutContentBottomY. Drawn as an overlay (on
  // top of, not beside, that content - the same reasoning as a browser's
  // own overlay scrollbars: reworking every tab's own row-width math
  // across this whole file to leave room beside it isn't worth it for a
  // strip this narrow, and this file's own widest rows already leave a
  // few view_S of margin at the panel's right edge for exactly this -
  // see rolloutScrollbarWidth()'s own comment). Same two-tier "arrow vs
  // track vs thumb-drag" click vocabulary as mouseClicked.pde's own
  // StationPicker scrollbar (handleTrackClick()/handleScrollDrag() there),
  // plus the up/down step buttons that one doesn't have.

  // Narrow: the same square _Spinner()'s own up/down arrow buttons use -
  // 0.5 * (h + 2*o) with h = 13*view_S, o = 2*view_S (see _Spinner(),
  // above) - so this sits flush with that same visual scale rather than
  // introducing its own.
  float rolloutScrollbarWidth () {
    return 8.5 * this.view_S;
  }

  // Outer bounds of the whole bar (up button + track + thumb + down
  // button together), right-aligned a small margin in from the panel's
  // own right edge.
  float[] rolloutScrollbarOuterRect () {
    float w = this.rolloutScrollbarWidth();
    float x = this.cX + this.dX - w - 2 * this.view_S;
    float y = this.rolloutContentTopY;
    float h = this.rolloutContentBottomY - this.rolloutContentTopY;
    return new float[]{ x, y, w, h };
  }

  float[] rolloutScrollUpButtonRect () {
    float[] bar = this.rolloutScrollbarOuterRect();
    return new float[]{ bar[0], bar[1], bar[2], bar[2] }; // square: side length == bar width
  }

  float[] rolloutScrollDownButtonRect () {
    float[] bar = this.rolloutScrollbarOuterRect();
    float side = bar[2];
    return new float[]{ bar[0], bar[1] + bar[3] - side, side, side };
  }

  // The draggable/clickable track, i.e. the bar minus the up/down
  // buttons at either end.
  float[] rolloutScrollTrackRect () {
    float[] bar = this.rolloutScrollbarOuterRect();
    float side = bar[2];
    return new float[]{ bar[0], bar[1] + side, bar[2], max(0, bar[3] - 2 * side) };
  }

  float[] rolloutScrollThumbRect () {
    float[] track = this.rolloutScrollTrackRect();

    float visibleH = this.rolloutContentBottomY - this.rolloutContentTopY;
    float maxScroll = max(1, this.rolloutContentHeight - visibleH);

    float thumbH = min(track[3], max(20 * this.view_S, track[3] * (visibleH / this.rolloutContentHeight)));
    float travel = track[3] - thumbH;
    float thumbY = track[1] + travel * (this.rolloutScrollY / maxScroll);

    return new float[]{ track[0], thumbY, track[2], thumbH };
  }

  boolean rolloutNeedsScrollbar () {
    return this.rolloutContentHeight > (this.rolloutContentBottomY - this.rolloutContentTopY) + 0.5;
  }

  // A plain click on either arrow steps by roughly one row's worth - the
  // same 24*view_S pitch most rows in this file use for their own row
  // height (e.g. drawSceneExplorerRow()'s own h, or close to _Spinner()'s
  // own 20*view_S line pitch).
  void handleRolloutScrollButtonClicks (float[] up, float[] down) {
    if (this.editActive) return;

    float step = 24 * this.view_S;
    float visibleH = this.rolloutContentBottomY - this.rolloutContentTopY;
    float maxScroll = max(0, this.rolloutContentHeight - visibleH);

    if (isInside(X_clicked, Y_clicked, up[0], up[1], up[0] + up[2], up[1] + up[3])) {
      this.rolloutScrollY = constrain(this.rolloutScrollY - step, 0, maxScroll);
      X_clicked = -1;
      Y_clicked = -1;
      this.revise();
    } else if (isInside(X_clicked, Y_clicked, down[0], down[1], down[0] + down[2], down[1] + down[3])) {
      this.rolloutScrollY = constrain(this.rolloutScrollY + step, 0, maxScroll);
      X_clicked = -1;
      Y_clicked = -1;
      this.revise();
    }
  }

  // A click on the track above/below the thumb (not directly on it -
  // that's a drag start, left alone here and handled by
  // handleScrollDrag(), below) pages by one screenful - same "track vs
  // thumb" split as the StationPicker scrollbar's own handleTrackClick()
  // (mouseClicked.pde).
  void handleRolloutScrollTrackClick (float[] track, float[] thumb) {
    if (this.editActive) return;
    if (!isInside(X_clicked, Y_clicked, track[0], track[1], track[0] + track[2], track[1] + track[3])) return;
    if ((Y_clicked >= thumb[1]) && (Y_clicked <= thumb[1] + thumb[3])) return; // on the thumb itself

    float visibleH = this.rolloutContentBottomY - this.rolloutContentTopY;
    float maxScroll = max(0, this.rolloutContentHeight - visibleH);
    float page = max(1, visibleH - 24 * this.view_S);

    if (Y_clicked < thumb[1]) {
      this.rolloutScrollY = constrain(this.rolloutScrollY - page, 0, maxScroll);
    } else {
      this.rolloutScrollY = constrain(this.rolloutScrollY + page, 0, maxScroll);
    }

    X_clicked = -1;
    Y_clicked = -1;
    this.revise();
  }

  // Drags the scrollbar thumb - called directly from mouseDragged.pde
  // (mirroring handlePickListScrollDrag()'s own call there for the
  // StationPicker scrollbar's thumb), ahead of WIN3D/WORLD/STUDY's own
  // drag handling, so the same drag gesture is never also read as e.g.
  // panning WORLD underneath. Returns true if this drag is (or just
  // became) a thumb drag.
  boolean handleScrollDrag () {
    if (!this.include) return false;
    if (!this.rolloutNeedsScrollbar()) return false;

    if (!this.rolloutScrollThumbDragging) {
      if (dragging_started != 0) return false; // some other drag already claimed this gesture

      float[] thumb = this.rolloutScrollThumbRect();
      if (!isInside(pmouseX, pmouseY, thumb[0], thumb[1], thumb[0] + thumb[2], thumb[1] + thumb[3])) return false;

      this.rolloutScrollThumbDragging = true;
      dragging_started = 1;
      X_click1 = pmouseX;
      Y_click1 = pmouseY;
      this.rolloutScrollDrag_startMouseY = pmouseY;
      this.rolloutScrollDrag_startScrollY = this.rolloutScrollY;
    }

    float[] track = this.rolloutScrollTrackRect();
    float[] thumb = this.rolloutScrollThumbRect();

    float travel = track[3] - thumb[3];
    if (travel > 0) {
      float visibleH = this.rolloutContentBottomY - this.rolloutContentTopY;
      float maxScroll = max(1, this.rolloutContentHeight - visibleH);
      float scrollPerPixel = maxScroll / travel;

      float deltaY = mouseY - this.rolloutScrollDrag_startMouseY;
      float newScroll = this.rolloutScrollDrag_startScrollY + deltaY * scrollPerPixel;

      this.rolloutScrollY = constrain(newScroll, 0, maxScroll);
    }

    this.revise();
    return true;
  }

  // Scrolls in response to the mouse wheel, if this tab's content
  // actually needs scrolling and the mouse is over the panel - called
  // from mouseWheel.pde's own handleRolloutWheel(). Returns true if it
  // consumed the event, the same "did this claim it" convention as
  // StationPicker.handleWheel() (mouseClicked.pde).
  boolean handleWheel (float wheelValue) {
    if (!this.include) return false;
    if (!this.rolloutNeedsScrollbar()) return false;
    if (!isInside(X_clicked, Y_clicked, this.cX, this.rolloutContentTopY, this.cX + this.dX, this.rolloutContentBottomY)) return false;

    float visibleH = this.rolloutContentBottomY - this.rolloutContentTopY;
    float maxScroll = max(0, this.rolloutContentHeight - visibleH);
    if (maxScroll <= 0) return false;

    float step = 24 * this.view_S;
    this.rolloutScrollY = constrain(this.rolloutScrollY + ((wheelValue > 0) ? step : -step), 0, maxScroll);

    this.revise();
    return true;
  }

  // One arrow button's background + triangle - shared by the up and down
  // buttons (drawRolloutScrollbar(), below), which differ only in which
  // way the triangle points.
  void drawRolloutScrollArrowButton (float[] b, boolean pointingUp) {
    float bx = b[0], by = b[1], bw = b[2], bh = b[3];

    stroke(0);
    strokeWeight(1);
    fill(255);
    rect(bx, by, bw, bh);

    noStroke();
    fill(80);
    float cx = bx + 0.5 * bw;
    float pad = 0.25 * bw;
    if (pointingUp) {
      triangle(cx, by + pad, bx + pad, by + bh - pad, bx + bw - pad, by + bh - pad);
    } else {
      triangle(cx, by + bh - pad, bx + pad, by + pad, bx + bw - pad, by + pad);
    }
  }

  // Draws (and, like drawRenderViewportButton()/drawRenderSectionsButton()
  // just above, does its own click hit-testing inline) the whole
  // scrollbar - a no-op whenever the current tab's content fits without
  // scrolling, so it's simply not there the rest of the time. Must be
  // called unclipped and at Y_control's own unoffset value (draw() calls
  // this right after noClip() and right before undoing its own
  // Y_control -= rolloutScrollY, above) - this bar is the control FOR
  // that clip/offset, not part of the content it applies to.
  void drawRolloutScrollbar () {
    if (!this.rolloutNeedsScrollbar()) return;

    float[] up = this.rolloutScrollUpButtonRect();
    float[] down = this.rolloutScrollDownButtonRect();
    float[] track = this.rolloutScrollTrackRect();

    this.handleRolloutScrollButtonClicks(up, down);
    // Re-fetch the thumb AFTER the button clicks above (if any) have had
    // their chance to move rolloutScrollY, so a track click right below
    // judges "is this on the thumb" against where the thumb actually is
    // this frame, not where it was before those buttons ran.
    float[] thumb = this.rolloutScrollThumbRect();
    this.handleRolloutScrollTrackClick(track, thumb);
    thumb = this.rolloutScrollThumbRect(); // and again, in case the track click just moved it too

    pushStyle();

    this.drawRolloutScrollArrowButton(up, true);
    this.drawRolloutScrollArrowButton(down, false);

    noStroke();
    fill(230, 230);
    rect(track[0], track[1], track[2], track[3]);

    stroke(0);
    strokeWeight(1);
    fill(160);
    rect(thumb[0], thumb[1], thumb[2], thumb[3]);

    popStyle();
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

    ArrayList<String> commonKeys = extraParamsCommonKeys(objs);
    java.util.Collections.sort(commonKeys); // deterministic row order, same reasoning as the Selected Entity path's own topKeys sort

    for (String key : commonKeys) {

      // "various", placeholder-styled exactly like the "+ Add" row's own
      // "\"key\": \"value\"" hint below - gray, not part of the real
      // value, and editing starts from a blank box rather than any one
      // entity's own value, so a typed edit is never mistaken for "this is
      // what entity N already had".
      String uniformValue = extraParamsUniformValueForKey(objs, key);
      boolean uniform = uniformValue != null;

      this._SpinnerText(X_control, Y_control, key, uniform ? uniformValue : "", false, uniform ? null : "various");
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
    ArrayList<String> partialKeys = extraParamsPartialKeys(objs);
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

      int missingCount = extraParamsMissingCount(objs, key);

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

  // CHILD_PROPERTIES_MODIFY_SELECTED - a typed property editor, parallel
  // to drawExtraParamsSelectedEntityTab()/drawExtraParamsBulkEditPanel()
  // (above) but for an entity's own NATIVE typed fields (its own
  // getter/setter pair - Model1D's getDegreeMax()/setDegreeMax(),
  // model1Ds.pde) rather than its extraParams JSON blob - that gap (a
  // proper bounded Spinner, rather than a free-text JSON row, for a
  // value that's already a plain typed field on the entity itself) is
  // PARENT_PROPERTIES' whole reason to be its own top-level parent,
  // ahead of PARENT_EXTRA_PARAMS, rather than one more child tab folded
  // into it. The Spinner itself is the same bounded shape Figure's own
  // creatorModel1DDegreeMax spinner uses for a NEW entity's default
  // (valueModifier.pde); this one just reads/writes the SELECTED
  // entity's own stored value directly instead.
  //
  // Like drawExtraParamsBulkEditTab(), this now works over the WHOLE
  // current selection (currentExtraParamsSelectionList(), any count,
  // including one) rather than requiring exactly one entity - but
  // unlike Bulk Edit's category-agnostic JSON keys, a typed field is
  // inherently category-specific (Model1D's getDegreeMax() doesn't
  // exist on a Camera), so a mixed-category selection has no single set
  // of fields to show at all; it falls back to the same guidance
  // message as an empty selection, just worded for "pick one category"
  // instead of "select something". Model1D, Model2D, Face, Polyline,
  // Camera, Solid, and Section are covered so far; further categories
  // are each their own `category.equals(...)` branch here, below.
  //
  // The one real design problem multi-selection raises: a BOUNDED
  // numeric Spinner (unlike drawExtraParamsBulkEditPanel()'s own
  // free-text _SpinnerText() boxes) has no blank/placeholder render
  // mode to stand in for "the selection doesn't agree on this value" -
  // it always has to show some concrete number. modifySelectedIntField()/
  // modifySelectedFloatField() (just below) resolve this the same way
  // every other per-field branch here already resolves a "which bounds"
  // question: by mirroring an existing precedent instead of inventing a
  // new mechanism - here, drawExtraParamsBulkEditPanel()'s own "always
  // absolute, never a per-entity delta, one shared undo step" semantics.
  // The Spinner shows the FIRST selected entity's own current value (so
  // a single-entity selection looks and behaves exactly as before), and
  // appends " (various)" to the caption whenever the selection doesn't
  // already agree on that field - a plain label with no other parsing
  // significance anywhere in the codebase, so this is a cheap, safe way
  // to signal the mixed state without any new Spinner plumbing. Any
  // value the user actually commits (arrow, drag, or typed entry)
  // overwrites EVERY selected entity with that same new value, all in
  // one beginScene3DChange()/endScene3DChange() undo step - never a
  // relative delta, since a delta has no obvious meaning for a typed
  // exact-value commit, while "set them all to this" is unambiguous and
  // matches what every entity will show afterward.
  //
  // Model1D's own field list/order/bounds mirrors CHILD_GEOMETRY_FORM's
  // own creatorModel1D* spinners exactly (valueModifier.pde) - same
  // captions (minus the "Creator" prefix, since this edits the entity
  // itself, not a creation default), same min/max/step/round per field -
  // just reading/writing each selected entity's own stored value
  // (allModel1Ds.getXxx()/setXxx(), model1Ds.pde) instead of a
  // User3D.creatorModel1DXxx default. X/Y/Z/Scale/Rotation are
  // deliberately left out - those are the generic position/rotation/
  // scale editor's own job (CHILD_GEOMETRY_TRANSFORM), not a species/
  // shape parameter specific to Model1D.
  //
  // Model2D (model2Ds.pde) only has one such field, FileIndex - which
  // file, within this instance's own Kind's folder (PEOPLE_KIND/
  // TREES_KIND, model2DKind.pde), it's pasted from - mirroring
  // creatorPersonTypeIndex()/creatorPlantTypeIndex() (valueModifier.pde,
  // Figure's own equivalent default-for-a-new-instance spinners), bound
  // the same way they are: 0..that Kind's own live fileCount, not a
  // fixed literal (the folder's own file count can change between
  // sessions). Because that bound is itself per-entity (each instance's
  // own Kind, not a single shared constant), a multi-selection only
  // exposes FileIndex when every selected Model2D shares the same Kind -
  // otherwise the bound itself would differ per entity, and a value
  // valid for one could silently be out of range for another; a mixed-
  // Kind selection falls back to the same "nothing to show" message an
  // unsupported category would. X/Y/Z/S(cale) are Transform's job here
  // too. Kind itself (switching a placed tree into a person or vice
  // versa) and Mirror (left/right flip) are deliberately left out for
  // now - neither has a Form/Figure creator-spinner counterpart to
  // mirror the way FileIndex does, and switching Kind on an
  // already-placed instance is a bigger behavioral change (isScalable()
  // differs between the two, and this instance's current Scale may no
  // longer make sense) than a same-kind "pick a different one of these"
  // tweak. Kind/FileIndex/Mirror are plain public fields on Model2Ds
  // (this.Kind[n]/FileIndex[n]/Mirror[n]) - no getter/setter pair to
  // call, unlike every Model1D field above.

  // IntFieldGetter/IntFieldSetter/FloatFieldGetter/FloatFieldSetter
  // (used just below) are declared at file scope, right above this
  // class - see the comment there for why.

  // Whether every entity in `indices` currently reports the same value
  // for a field, as read through `getter` - the "does the selection
  // agree on this one" check modifySelectedIntField()/
  // modifySelectedFloatField() use to decide their caption. Pulled out
  // as its own pure function (same reasoning as every other pulled-out
  // pure helper in this file, e.g. rolloutNeedsScrollbar() above):
  // modifySelectedIntField()/modifySelectedFloatField() themselves call
  // this.Spinner(), which renders, so they're not unit-testable as-is
  // (test/README.md's own documented limitation) - but the actual
  // uniform-or-not logic they rely on doesn't touch a canvas at all, and
  // is worth testing on its own with nothing more than a fake getter
  // over plain ints/floats.
  boolean isUniformIntField (ArrayList<Integer> indices, IntFieldGetter getter) {
    int first = getter.get(indices.get(0));
    for (int idx : indices) { if (getter.get(idx) != first) return false; }
    return true;
  }

  boolean isUniformFloatField (ArrayList<Integer> indices, FloatFieldGetter getter) {
    float first = getter.get(indices.get(0));
    for (int idx : indices) { if (getter.get(idx) != first) return false; }
    return true;
  }

  // One bounded-int Spinner row, shared across however many entities are
  // in `indices` - see the big comment above drawPropertiesModifySelectedTab()
  // for the "first entity's value, ' (various)' caption, always-absolute-
  // overwrite" design this implements. `afterAllWrites`, when non-null,
  // runs once after every entity has been written (not once per entity) -
  // for a side effect like allSolidImpacts.calculate_ImpactOnSections()
  // that recomputes from the whole scene's state rather than per-entity;
  // a PER-entity side effect (like a Camera's WIN3D re-sync) belongs in
  // the setter lambda itself instead, where it naturally has that
  // entity's own index in scope.
  void modifySelectedIntField (
    ArrayList<Integer> indices, String caption, int min_v, int max_v, int stp_v,
    IntFieldGetter getter, IntFieldSetter setter
  ) {
    this.modifySelectedIntField(indices, caption, min_v, max_v, stp_v, getter, setter, null);
  }

  void modifySelectedIntField (
    ArrayList<Integer> indices, String caption, int min_v, int max_v, int stp_v,
    IntFieldGetter getter, IntFieldSetter setter, Runnable afterAllWrites
  ) {
    int first = getter.get(indices.get(0));
    boolean uniform = this.isUniformIntField(indices, getter);
    int updated = this.Spinner(X_control, Y_control, 0, 0, 0, uniform ? caption : caption + " (various)", first, min_v, max_v, stp_v);
    if (updated != first) {
      beginScene3DChange();
      for (int idx : indices) setter.set(idx, updated);
      if (afterAllWrites != null) afterAllWrites.run();
      endScene3DChange();
      UI_rollout.revise();
    }
  }

  // Same as modifySelectedIntField() just above, but for a float field
  // (Spinner's own float overload, with its extra roundStep argument -
  // uiRollout.pde's Spinner() definitions).
  void modifySelectedFloatField (
    ArrayList<Integer> indices, String caption, float min_v, float max_v, float stp_v, float roundStep,
    FloatFieldGetter getter, FloatFieldSetter setter
  ) {
    this.modifySelectedFloatField(indices, caption, min_v, max_v, stp_v, roundStep, getter, setter, null);
  }

  void modifySelectedFloatField (
    ArrayList<Integer> indices, String caption, float min_v, float max_v, float stp_v, float roundStep,
    FloatFieldGetter getter, FloatFieldSetter setter, Runnable afterAllWrites
  ) {
    float first = getter.get(indices.get(0));
    boolean uniform = this.isUniformFloatField(indices, getter);
    float updated = this.Spinner(X_control, Y_control, 0, 0, 0, uniform ? caption : caption + " (various)", first, min_v, max_v, stp_v, roundStep);
    if (updated != first) {
      beginScene3DChange();
      for (int idx : indices) setter.set(idx, updated);
      if (afterAllWrites != null) afterAllWrites.run();
      endScene3DChange();
      UI_rollout.revise();
    }
  }

  // Shared guidance-message renderer for every "nothing to show yet"
  // case below (empty selection, mixed-category selection, mixed-Kind
  // Model2D selection, or an unsupported category) - same fill/align/
  // size every such message already used individually before this was
  // pulled out, just parameterized by the message text and how far it
  // advances Y_control (a short one- or two-line message only needs the
  // original 20/50 advance; a longer wrapped message needs more).
  void modifySelectedMessage (String message, float yAdvance) {
    fill(127);
    textAlign(LEFT, CENTER);
    textSize(12 * this.view_S);
    text(message, this.cX + 10 * this.view_S, Y_control + (yAdvance / 2.5));
    Y_control += yAdvance;
  }

  void drawPropertiesModifySelectedTab () {

    ArrayList<ExtraParamsSelectionTarget> list = currentExtraParamsSelectionList();

    if (list.size() == 0) {
      this.modifySelectedMessage(
        "Select one or more entities, all of\nthe same category (e.g. trees), to\nedit their properties.",
        70 * this.view_S
      );
      return;
    }

    String category = list.get(0).category;
    boolean sameCategory = true;
    ArrayList<Integer> indices = new ArrayList<Integer>();
    for (ExtraParamsSelectionTarget t : list) {
      if (!t.category.equals(category)) { sameCategory = false; }
      indices.add(t.index);
    }

    if (!sameCategory) {
      this.modifySelectedMessage(
        "Select entities of a single category\n(e.g. only trees, not trees and\ncameras together) to edit their\nproperties.",
        90 * this.view_S
      );
      return;
    }

    if (list.size() > 1) {
      fill(127);
      textAlign(LEFT, CENTER);
      textSize(12 * this.view_S);
      text(list.size() + " entities selected", this.cX + 10 * this.view_S, Y_control + 10 * this.view_S);
      Y_control += 30 * this.view_S;
    }

    if (category.equals("face")) {

    // Faces' own creator-spinner precedent (valueModifier.pde's
    // creatorMaterial/creatorTessellation/creatorLayer/creatorWeight)
    // covers four of its six typed fields (options[n][0..4] - see
    // faces.pde's getMaterial/getTessellation/getLayer/getWeight). The
    // bounds below come from adjustFaceProperties() (edit3D.pde)
    // instead of those creator spinners' own start/stop, though: that's
    // the clamp actually enforced on an already-placed face (e.g.
    // Material 0-8, not creatorMaterial's -1-8 - that extra -1 is only
    // ever a "pick a random material at creation time" sentinel, never
    // a valid value for a placed face).
    //
    // The other two typed fields are deliberately excluded:
    //  - Visibility (getVisibility/setVisibility) - unlike every other
    //    category here, Faces' visibility is already a generic,
    //    cross-category concept (extraParamsSelection.pde's own
    //    extraParamsIsVisible()/extraParamsSetVisibility(), the one
    //    Scene Explorer's "show only visible"/isolate mechanism already
    //    drives for every visibility-bearing category - Face, Polyline,
    //    Model1D, Model2D, Solid, Camera, Section alike) - duplicating
    //    it here would just be a second, disconnected way to edit the
    //    same bit.
    //  - Close (getClose/setClose) - has no legitimate edit precedent
    //    to mirror at all: its only existing write site outside
    //    faces.pde itself is mouseClicked.pde's pickOrAssignFaceProperty(),
    //    and that call is documented there as a pre-existing bug (the
    //    Assign(all)/Weight case calls setClose() instead of
    //    setWeight() by mistake), not a real "edit a face's Close flag"
    //    feature to mirror.

    this.modifySelectedIntField(indices, "Material", 0, 8, 1,
      (idx) -> allFaces.getMaterial(idx), (idx, v) -> allFaces.setMaterial(idx, v));
    this.modifySelectedIntField(indices, "Tessellation", 0, 4, 1,
      (idx) -> allFaces.getTessellation(idx), (idx, v) -> allFaces.setTessellation(idx, v));
    this.modifySelectedIntField(indices, "Layer", 0, 16, 1,
      (idx) -> allFaces.getLayer(idx), (idx, v) -> allFaces.setLayer(idx, v));
    this.modifySelectedIntField(indices, "Weight", -20, 20, 1,
      (idx) -> allFaces.getWeight(idx), (idx, v) -> allFaces.setWeight(idx, v));

    } else if (category.equals("polyline")) {

    // Polylines are Faces' own sibling class (polylines.pde mirrors
    // faces.pde's options[] layout field-for-field) - Material/
    // Tessellation/Layer/Weight get the same treatment here, same
    // creator-spinner precedent (creatorMaterial/creatorTessellation/
    // creatorLayer/creatorWeight, valueModifier.pde) and the same
    // already-placed-entity bounds from adjustPolylineProperties()
    // (edit3D.pde), for the same reasons given in the "face" branch
    // just above.
    //
    // Visibility is excluded for the same cross-category reason as
    // there (extraParamsSelection.pde's generic extraParamsIsVisible()/
    // extraParamsSetVisibility(), already covering every
    // visibility-bearing category including this one).
    //
    // Close/CurveType/IsArc/ArcParams are excluded too, kept consistent
    // with Close's exclusion on the "face" branch: User3D.creatorClosed
    // (valueModifier.pde) does exist and does feed a handful of
    // creation paths (land3D.pde's Land tool; most importers instead
    // compute their own current_Closed per-geometry, e.g. importDxf.pde/
    // importStl.pde's "clz"), but nothing anywhere edits Close on an
    // already-placed polyline the way adjustPolylineProperties() does
    // for Material/Tessellation/Layer/Weight - same gap as Faces had,
    // so it's left out here too rather than drawing an inconsistent
    // line between two sibling classes that share this exact field.
    // CurveType/IsArc/ArcParams have no creator-spinner precedent at
    // all - they're derived from the polyline's own points by whichever
    // tool built it (the arc tool, curve fitting, etc.), never a value
    // the user picks directly.

    this.modifySelectedIntField(indices, "Material", 0, 8, 1,
      (idx) -> allPolylines.getMaterial(idx), (idx, v) -> allPolylines.setMaterial(idx, v));
    this.modifySelectedIntField(indices, "Tessellation", 0, 4, 1,
      (idx) -> allPolylines.getTessellation(idx), (idx, v) -> allPolylines.setTessellation(idx, v));
    this.modifySelectedIntField(indices, "Layer", 0, 16, 1,
      (idx) -> allPolylines.getLayer(idx), (idx, v) -> allPolylines.setLayer(idx, v));
    this.modifySelectedIntField(indices, "Weight", -20, 20, 1,
      (idx) -> allPolylines.getWeight(idx), (idx, v) -> allPolylines.setWeight(idx, v));

    } else if (category.equals("model1d")) {

    // Type Index - same degenerate 0..0 range as creatorModel1DTypeIndex()
    // itself (valueModifier.pde) - there's genuinely only the one type
    // right now, so this isn't a bug to fix on this tab's own account.
    this.modifySelectedIntField(indices, "Type Index", 0, 0, 1,
      (idx) -> allModel1Ds.getType(idx), (idx, v) -> allModel1Ds.setType(idx, v));
    this.modifySelectedIntField(indices, "Degree Max", 0, 12, 1,
      (idx) -> allModel1Ds.getDegreeMax(idx), (idx, v) -> allModel1Ds.setDegreeMax(idx, v));
    this.modifySelectedIntField(indices, "Seed", -1, 32767, 1,
      (idx) -> allModel1Ds.getSeed(idx), (idx, v) -> allModel1Ds.setSeed(idx, v));
    this.modifySelectedFloatField(indices, "Trunk Size", 0, 10, 0.1, 0.1,
      (idx) -> allModel1Ds.getTrunkSize(idx), (idx, v) -> allModel1Ds.setTrunkSize(idx, v));
    this.modifySelectedFloatField(indices, "Leaf Size", 0, 1, 0.01, 0.1,
      (idx) -> allModel1Ds.getLeafSize(idx), (idx, v) -> allModel1Ds.setLeafSize(idx, v));
    this.modifySelectedFloatField(indices, "Branch Tilt", 0, 360, 5, 0.1,
      (idx) -> allModel1Ds.getBranchTilt(idx), (idx, v) -> allModel1Ds.setBranchTilt(idx, v));
    this.modifySelectedFloatField(indices, "Branch Twist", 0, 360, 5, 0.1,
      (idx) -> allModel1Ds.getBranchTwist(idx), (idx, v) -> allModel1Ds.setBranchTwist(idx, v));
    this.modifySelectedFloatField(indices, "Branch Ratio", 0.05, 1, 0.05, 0.01,
      (idx) -> allModel1Ds.getBranchRatio(idx), (idx, v) -> allModel1Ds.setBranchRatio(idx, v));
    this.modifySelectedFloatField(indices, "Tree Base", 0, 4, 0.1, 0.01,
      (idx) -> allModel1Ds.getTreeBase(idx), (idx, v) -> allModel1Ds.setTreeBase(idx, v));

    } else if (category.equals("model2d")) {

      // See the big comment above this function for why a mixed-Kind
      // selection has nothing to show: FileIndex's own upper bound is
      // per-entity (each instance's own Kind.fileCount), so it's only
      // safe to expose when every selected entity shares one Kind.
      Model2DKind firstKind = allModel2Ds.Kind[indices.get(0)];
      boolean sameKind = true;
      for (int idx : indices) { if (allModel2Ds.Kind[idx] != firstKind) { sameKind = false; break; } }

      if (sameKind) {
        this.modifySelectedIntField(indices, "File Index", 0, firstKind.fileCount, 1,
          (idx) -> allModel2Ds.FileIndex[idx], (idx, v) -> { allModel2Ds.FileIndex[idx] = v; });
      } else {
        this.modifySelectedMessage(
          "Select Model2D entities of a single\nkind (e.g. only trees, not trees and\npeople together) to edit File Index.",
          90 * this.view_S
        );
      }

    } else if (category.equals("camera")) {

    // Unlike Model1D/Model2D, cameras have no Form/Figure-style creation
    // tool with its own precedent spinners to mirror - "Add Camera"
    // (cameras.pde's add_first()) just snapshots WIN3D's current
    // position/rotation/zoom/step/type, it never lets the user choose
    // starting values via a spinner. So the bounds below come straight
    // from each field's own known valid range instead: Type's 0..1 is
    // the exact clamp edit3D.pde's Seed_Material cycle tool already
    // enforces (there are only two projection types); Zoom/Position
    // Step/Rotation Step have no existing clamp anywhere, so they're
    // given practical ranges around their own declared defaults (zoom
    // 90, positionStep 1.0, rotationStep 5.0 - viewport3D.pde) - X/Y/Z
    // position and generic rotation/scale are excluded, same reasoning
    // as Model1D/Model2D: Transform (CHILD_GEOMETRY_TRANSFORM) already
    // edits those for any selected entity, cameras included (see
    // move3D.pde's/scale3D.pde's own Cameras() methods).
    //
    // Cameras are special in one more way those two categories aren't:
    // WIN3D keeps its own live copy of these same fields for whichever
    // camera is currentCameraIndex (viewport3D.pde's positionX/zoom/
    // projectionTypeIndex/etc., read every frame for rendering). Edit
    // the array here, then re-sync WIN3D's copy the same way move3D.pde/
    // scale3D.pde always do - skip this and record_last3DViewport()
    // would later stomp the edit right back with the stale WIN3D value.
    // This re-sync is a PER-entity side effect (only the one entity that
    // happens to be currentCameraIndex needs it), so it lives in each
    // setter lambda itself, which already has that entity's own idx in
    // scope - not in modifySelectedIntField()/modifySelectedFloatField()'s
    // shared afterAllWrites hook, which only ever runs once per edit.

    this.modifySelectedIntField(indices, "Type", 0, 1, 1,
      (idx) -> allCameras.get_type(idx),
      (idx, v) -> { allCameras.set_type(idx, v); if (idx == WIN3D.currentCameraIndex) WIN3D.apply_currentCameraIndex(); });
    this.modifySelectedFloatField(indices, "Zoom", 1, 170, 1, 0.1,
      (idx) -> allCameras.get_zoom(idx),
      (idx, v) -> { allCameras.set_zoom(idx, v); if (idx == WIN3D.currentCameraIndex) WIN3D.apply_currentCameraIndex(); });
    this.modifySelectedFloatField(indices, "Position Step", 0.01, 100, 0.1, 0.01,
      (idx) -> allCameras.get_posT(idx),
      (idx, v) -> { allCameras.set_posT(idx, v); if (idx == WIN3D.currentCameraIndex) WIN3D.apply_currentCameraIndex(); });
    this.modifySelectedFloatField(indices, "Rotation Step", 0.1, 180, 1, 0.1,
      (idx) -> allCameras.get_rotT(idx),
      (idx, v) -> { allCameras.set_rotT(idx, v); if (idx == WIN3D.currentCameraIndex) WIN3D.apply_currentCameraIndex(); });

    } else if (category.equals("solid")) {

    // Solids' posX/Y/Z, scaleX/Y/Z and rotX/Y/Z (solids.pde's own DEF
    // array) are generic position/scale/rotation - Transform's job,
    // same as every other category above (see move3D.pde's/scale3D.pde's/
    // rotate3D.pde's own Solids() methods). Visibility is the usual
    // cross-category field.
    //
    // "value" (getValue()/setValue(), DEF[n][12]) is excluded too: it
    // has no creator spinner and nothing anywhere edits it on an
    // already-placed solid either - the only places that touch it
    // besides solids.pde itself just read it back (solidImpacts.pde,
    // clone3D.pde, groups.pde's own clone-into-group path) or pass it
    // straight through unchanged when duplicating a solid. Same gap as
    // Close had for Faces/Polylines - no legitimate edit precedent to
    // mirror, so it stays out.
    //
    // What's left is powX/powY/powZ (DEF[n][3..5]) - the superellipsoid
    // exponent along each axis that blends the solid's shape between
    // star/concave and cube-like. No Form/Figure creator spinner here
    // either, but edit3D.pde's own Solids() (the PowerX/PowerY/PowerZ/
    // PowerAll drag-tools) is a direct edit-an-existing-solid
    // precedent: it doubles/halves the value and wraps, not clamps,
    // between StarPower (0.25) and CubePower (16) (globalVariables.pde)
    // - those are the bounds used below. allSolidImpacts.
    // calculate_ImpactOnSections() is the same refresh the drag tool
    // does afterward, since a solid's shape feeds the impact study too -
    // it only needs to run ONCE per edit (it recomputes from the whole
    // scene, not per-entity), so it's passed as afterAllWrites rather
    // than folded into the setter lambda.

    this.modifySelectedFloatField(indices, "Power X", 0.25, 16, 0.25, 0.01,
      (idx) -> allSolids.get_powX(idx), (idx, v) -> allSolids.set_powX(idx, v),
      () -> allSolidImpacts.calculate_ImpactOnSections());
    this.modifySelectedFloatField(indices, "Power Y", 0.25, 16, 0.25, 0.01,
      (idx) -> allSolids.get_powY(idx), (idx, v) -> allSolids.set_powY(idx, v),
      () -> allSolidImpacts.calculate_ImpactOnSections());
    this.modifySelectedFloatField(indices, "Power Z", 0.25, 16, 0.25, 0.01,
      (idx) -> allSolids.get_powZ(idx), (idx, v) -> allSolids.set_powZ(idx, v),
      () -> allSolidImpacts.calculate_ImpactOnSections());

    } else if (category.equals("section")) {

    // Sections have almost nothing left for this tab once the usual
    // exclusions are applied: X/Y/Z/RotX/RotY/RotZ (sections.pde's own
    // f_data) are generic position/rotation, Transform's job just like
    // every other category above; Visibility is the same cross-category
    // field extraParamsSelection.pde already handles for every
    // category; and the section's own corner outline (getCornersXY()/
    // getNumCorners(), corner-by-corner shape data) isn't a bounded
    // scalar param at all, so there's no Spinner to mirror it with.
    //
    // The one field left is resX/resY (sections.pde's i_data) - the
    // raster resolution the solar-impact study renders this section at.
    // There's no Form/Figure-style creator spinner for it (sections
    // aren't built that way - see create3D.pde's own Section tool,
    // which starts every new section at a fixed 200 or 400), but there
    // IS a real edit-an-existing-section precedent: edit3D.pde's own
    // Sections() (the Tessellation drag-tool) doubles/halves resX,
    // mirrors it onto resY right afterward (the two are always kept
    // equal - there's no way to set them independently through any
    // existing tool), clamped to 100-1600, and that's the bounds used
    // below - both writes live in the setter lambda, since they always
    // happen together per-entity. That tool also recalculates the
    // impact data afterward (allSolidImpacts.calculate_ImpactOnSections())
    // since the existing numbers no longer match the new resolution -
    // this does the same, once per edit (afterAllWrites), same
    // reasoning as the "solid" branch just above.

    this.modifySelectedIntField(indices, "Resolution", 100, 1600, 100,
      (idx) -> allSections.get_resX(idx),
      (idx, v) -> { allSections.set_resX(idx, v); allSections.set_resY(idx, v); },
      () -> allSolidImpacts.calculate_ImpactOnSections());

    } else {
      this.modifySelectedMessage("No typed properties yet for this entity's category.", 50 * this.view_S);
    }
  }

  // CHILD_SCENE_EXPLORER_SELECT - the Scene Explorer's own tree view.
  // buildSceneExplorerRows() (sceneExplorer.pde) does all the actual
  // data work (what rows exist, in what order, which entities each one
  // represents) - this just walks its result and draws/clicks each row.
  // Which category-rows are currently expanded persists here, across
  // frames, the same way extraParamsRowLevel does for PARENT_EXTRA_PARAMS,
  // but as a flat set of "currently expanded" keys (a Scene Explorer
  // row's own toggle has only two states, not extraParamsLevelToggle()'s
  // own typeable 0/1 spinner, so a HashSet is all this needs).
  java.util.HashSet<String> sceneExplorerExpandedKeys = new java.util.HashSet<String>();

  // "show only visible" filter state (sceneExplorer.pde's own
  // sceneExplorerFilterVisible()) - persists across frames the same way
  // sceneExplorerExpandedKeys does, and the same way, is purely this
  // tab's own UI state: it narrows which rows buildSceneExplorerRows()
  // returns, it never touches any entity's actual visibility.
  boolean sceneExplorerShowOnlyVisible = false;

  // CHILD_SCENE_EXPLORER_SELECT/_ISOLATE/_LOOK_AT share this one tree
  // view - same rows, same expand/filter state (sceneExplorerExpandedKeys/
  // sceneExplorerShowOnlyVisible just above are deliberately NOT
  // per-tab: it's the same tree, so a Group expanded in one tab stays
  // expanded after switching to another). The three tabs differ only
  // in what a plain row click DOES once it has that row's own targets,
  // which is exactly what onRowClicked (one short lambda per tab,
  // below) decides - same "pass a callback instead of tripling this
  // whole method" shape sceneExplorerAppendGroupLikeRows() already
  // uses for its own idsForCategory (sceneExplorer.pde).
  void drawSceneExplorerTreeTab (java.util.function.Consumer<ArrayList<ExtraParamsSelectionTarget>> onRowClicked) {

    this.drawSceneExplorerShowOnlyVisibleToggle(this.cX + 10 * this.view_S, Y_control);

    ArrayList<SceneExplorerRow> rows = buildSceneExplorerRows(this.sceneExplorerExpandedKeys, this.sceneExplorerShowOnlyVisible);

    if (rows.size() == 0) {
      fill(127);
      textAlign(LEFT, CENTER);
      textSize(12 * this.view_S);
      text(
        this.sceneExplorerShowOnlyVisible ? "Nothing visible to show." : "Nothing in the scene yet.",
        this.cX + 10 * this.view_S, Y_control + 20 * this.view_S
      );
      Y_control += 50 * this.view_S;
      return;
    }

    for (SceneExplorerRow row : rows) {
      int selectionState = extraParamsSelectionStateFor(row.targets);
      boolean clicked = this.drawSceneExplorerRow(
        this.cX + 10 * this.view_S, Y_control, row.label, row.depth, selectionState,
        row.hasToggle, row.expanded, this.sceneExplorerExpandedKeys, row.expandKey
      );
      if (clicked) {
        onRowClicked.accept(row.targets);
      }
    }
  }

  void drawSceneExplorerSelectTab () {
    this.drawSceneExplorerTreeTab((targets) -> {
      this.selectSceneExplorerTargets(targets);
    });
  }

  // Isolate still selects first (same visual feedback as the Select
  // tab - the 3D viewport highlights whatever just got isolated), then
  // calls Modify3D.isolateTargets(targets) - the row-target-direct
  // isolate (modify3D.pde's own comment there explains why this can't
  // just be Modify3D.isolate_Selection() plus a currentObjectCategory
  // left over from selectSceneExplorerTargets()).
  void drawSceneExplorerIsolateTab () {
    this.drawSceneExplorerTreeTab((targets) -> {
      this.selectSceneExplorerTargets(targets);
      Modify3D.isolateTargets(targets);
    });
  }

  // Look At: selects first (same reasoning as Isolate above), then
  // WIN3D.look_3DViewport_towards_Targets(targets) - the
  // row-target-direct look-at (viewport3D.pde's own comment there) -
  // plus the same "automatically set another choice of interest" +
  // view_changed() wrapping UI_setTo_View_LookAtSelection() itself
  // does around WIN3D.look_3DViewport_towards_Selection() (uiSetTo.pde).
  void drawSceneExplorerLookAtTab () {
    this.drawSceneExplorerTreeTab((targets) -> {
      this.selectSceneExplorerTargets(targets);
      WIN3D.look_3DViewport_towards_Targets(targets);
      UI_setTo_View_CameraDistance(0);
      UI_toolBar.revise();
      view_changed();
    });
  }

  // A small checkbox above the tree itself - same box-plus-click shape
  // as drawSceneExplorerRow()'s own expand toggle just below (reused
  // rather than routed through the numeric Spinner() family, which is
  // built for the rollout's model-mutating parameters, not a plain
  // view-only UI flag like this one), but drawn standalone since it
  // isn't a row of the tree and has no selection highlight of its own.
  // Flips this.sceneExplorerShowOnlyVisible directly on click; advances
  // Y_control by its own height so the tree itself starts just below it.
  void drawSceneExplorerShowOnlyVisibleToggle (float x, float y) {
    float boxW = 14 * this.view_S;
    float h = 18 * this.view_S;

    Y_control += h;

    float boxX0 = x;
    float boxY0 = Y_control - h + (h - boxW) / 2.0;

    strokeWeight(1);
    stroke(0);
    fill(this.sceneExplorerShowOnlyVisible ? 150 : 255);
    rect(boxX0, boxY0, boxW, boxW);

    if (this.sceneExplorerShowOnlyVisible) {
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(11 * this.view_S);
      text("✓", boxX0 + boxW / 2.0, boxY0 + boxW / 2.0 + 1);
    }

    fill(0);
    textAlign(LEFT, CENTER);
    textSize(12 * this.view_S);
    text("Show only visible", boxX0 + boxW + 6 * this.view_S, Y_control - h / 2.0);

    float rowX1 = x + (this.dX - 20 * this.view_S);
    if (isInside(X_clicked, Y_clicked, boxX0, Y_control - h, rowX1, Y_control)) {
      this.sceneExplorerShowOnlyVisible = !this.sceneExplorerShowOnlyVisible;
      X_clicked = -1;
      Y_clicked = -1;
      UI_rollout.revise();
    }
  }

  // Lightweight, dedicated row widget for Scene Explorer - unlike every
  // other row in this file (the _Spinner()/_SpinnerText()/
  // extraParamsLevelToggle() family), a Scene Explorer row is never
  // text-edited: it's a label, maybe an expand toggle, and a click
  // target. Reusing that family's own keyboard-edit/Tab-order machinery
  // here would just be unused weight, so this is its own small widget
  // instead. Draws the row's own background (colored by
  // selectionState - green for ALL, yellow for SOME, plain gray
  // otherwise - ExtraParamsSelectionState, extraParamsSelection.pde),
  // the toggle (only when hasToggle) and the label, and returns true
  // exactly once, on the frame a plain click lands anywhere on the row
  // OUTSIDE the toggle's own small hit box - a click on the toggle
  // itself is handled right here, by flipping the caller's own
  // expandedKeys entry directly, since that never also needs to drive
  // selection.
  boolean drawSceneExplorerRow (
    float x, float y, String label, int depth, int selectionState,
    boolean hasToggle, boolean expanded, java.util.HashSet<String> expandedKeys, String expandKey
  ) {

    float rowW = this.dX - 20 * this.view_S;
    float h = 18 * this.view_S;
    float indent = depth * 16 * this.view_S;
    float toggleW = 14 * this.view_S;

    Y_control += h;

    float rowX0 = x;
    float rowY0 = Y_control - h;
    float rowX1 = x + rowW;
    float rowY1 = Y_control;

    strokeWeight(1);
    stroke(120);
    if (selectionState == ExtraParamsSelectionState.ALL) {
      fill(150, 220, 150);
    } else if (selectionState == ExtraParamsSelectionState.SOME) {
      fill(230, 215, 120);
    } else {
      fill(210);
    }
    rect(rowX0, rowY0, rowW, h);

    if (hasToggle) {
      float tX0 = rowX0 + indent;
      float tY0 = rowY0 + (h - toggleW) / 2.0;

      strokeWeight(1);
      stroke(0);
      fill(255);
      rect(tX0, tY0, toggleW, toggleW);

      fill(0);
      textAlign(CENTER, CENTER);
      textSize(11 * this.view_S);
      text(expanded ? "-" : "+", tX0 + toggleW / 2.0, tY0 + toggleW / 2.0 + 1);

      if (isInside(X_clicked, Y_clicked, tX0, tY0, tX0 + toggleW, tY0 + toggleW)) {
        if (expanded) {
          expandedKeys.remove(expandKey);
        } else {
          expandedKeys.add(expandKey);
        }
        X_clicked = -1;
        Y_clicked = -1;
        UI_rollout.revise();
      }
    }

    fill(0);
    textAlign(LEFT, CENTER);
    textSize(12 * this.view_S);
    text(label, rowX0 + indent + toggleW + 6 * this.view_S, rowY0 + h / 2.0);

    boolean rowClicked = false;
    if (isInside(X_clicked, Y_clicked, rowX0, rowY0, rowX1, rowY1)) {
      rowClicked = true;
      X_clicked = -1;
      Y_clicked = -1;
    }

    return rowClicked;
  }

  // A plain click on a Scene Explorer row (drawSceneExplorerSelectTab(),
  // above) replaces the whole current selection with that row's own
  // entity set - this is deliberately v1-scoped to "replace"; there's no
  // Shift/Ctrl-to-add-or-toggle here yet, since nothing elsewhere in this
  // app currently tracks which modifier key is held at the moment a UI
  // widget (as opposed to the 3D viewport itself) is clicked. Builds the
  // replacement per category via setExtraParamsSelectionArrayFor()
  // (extraParamsSelection.pde) - a row's own targets can span more than
  // one category at once (a Group header's targets, say), so every
  // category gets its own fresh array here, empty for any category this
  // row doesn't touch at all (clearing whatever was selected there
  // before).
  void selectSceneExplorerTargets (ArrayList<ExtraParamsSelectionTarget> targets) {

    HashMap<String,ArrayList<Integer>> byCategory = new HashMap<String,ArrayList<Integer>>();
    for (String category : EXTRAPARAMS_CATEGORIES) byCategory.put(category, new ArrayList<Integer>());
    for (ExtraParamsSelectionTarget t : targets) byCategory.get(t.category).add(t.index);

    for (String category : EXTRAPARAMS_CATEGORIES) {
      ArrayList<Integer> list = byCategory.get(category);
      int[] ids = new int[list.size()];
      for (int i = 0; i < ids.length; i++) ids[i] = list.get(i);
      setExtraParamsSelectionArrayFor(category, ids);
    }

    if (targets.size() > 0) {
      // currentObjectCategory is whichever category the 3D viewport's
      // own tools/handles currently act on - a plain 3D click already
      // keeps it in step with whatever got (re)selected via
      // switch_category() (globalFunctions.pde), so a row click follows
      // the same rule: match the LAST entity in this row's own target
      // list (a Group header's targets can span more than one
      // category). switch_category() also covers every other bit of
      // post-selection bookkeeping a direct Select3D array assignment
      // would otherwise need calling by hand here (UI_toolBar.revise(),
      // then selection_changed() -> Select3D.revise_BoundingBox() +
      // view_changed() -> WIN3D.revise() and, since view_changed() now
      // checks for it too, this tab's own row highlighting).
      ExtraParamsSelectionTarget last = targets.get(targets.size() - 1);
      switch_category(extraParamsObjectTypeForCategory(last.category));
    } else {
      selection_changed();
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
