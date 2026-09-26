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
  boolean spinnerEditActive = false;
  String spinnerEditCaption = "";
  String spinnerEditText = "";
  int spinnerEditCursor = 0;
  boolean spinnerEditCommit = false;
  boolean spinnerEditStateChanged = false;

  // Captions of every spinner drawn on the current page, in on-screen
  // order, rebuilt each drawView() pass. Used by Tab / Shift+Tab to know
  // which spinner comes next/previous.
  ArrayList<String> spinnerOrderThisPass = new ArrayList<String>();

  // Set by Tab / Shift+Tab to request that a specific spinner (identified
  // by caption) become the new edit target. The actual switch happens once
  // that spinner's own _Spinner() call is reached, since only there is its
  // live value known (needed to seed the typed text).
  String spinnerEditPendingCaption = null;

  void buildAllRollouts () {

    PARENT_PERIOD_SCENARIOS = pushParent("Period & Scenarios");
    CHILD_PERIOD_TIME = pushChild("Time");
    CHILD_PERIOD_RANGES = pushChild("Ranges");
    CHILD_PERIOD_FILTERS = pushChild("Filters");

    PARENT_LOCATION = pushParent("Location & Data");
    CHILD_LOCATION_POINT = pushChild("Point");
    CHILD_LOCATION_STATIONS = pushChild("Stations");

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

    PARENT_POSTPROCESS = pushParent("Post-Processing");
    CHILD_POSTPROCESS_INTERPOLATION = pushChild("Interpolation");
    CHILD_POSTPROCESS_DEVELOPED = pushChild("Developed");
    CHILD_POSTPROCESS_IMPACTS = pushChild("Impacts");

    PARENT_EXPORT = pushParent("Export Products");
    CHILD_EXPORT_DATA = pushChild("Data");
    CHILD_EXPORT_MEDIA = pushChild("Media");
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
    parent = PARENT_PERIOD_SCENARIOS; // default parent
    child = CHILD_PERIOD_TIME; // default child

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

    vm.Number_of_days_to_plot(0);
    vm.Day_step(0);
    vm.Join_days(0);
    vm.Days_past_March_equinox(0);
    vm.Begin_day(0);
    vm.Begin_month(0);
    vm.Begin_year(0);
    vm.Start_hour(0);
    vm.End_hour(0);
    vm.Start_year(0);
    vm.End_year(0);
    vm.Start_member(0);
    vm.End_member(0);
    vm.Start_station(0);
    vm.End_station(0);
    vm.Forecast_Obs_maxDays(0);
    vm.Sky_status(0);
    vm.Hourly_daily_filter(0);
    vm.Latitude(0);
    vm.Longitude(0);
    vm.TMYEPW_displayAll(0);
    vm.TMYEPW_displayNear(0);
    vm.CWEEDS_displayAll(0);
    vm.CWEEDS_displayNear(0);
    vm.CLMREC_displayAll(0);
    vm.CLMREC_displayNear(0);
    vm.SWOB_displayAll(0);
    vm.SWOB_displayNear(0);
    vm.NAEFS_displayAll(0);
    vm.NAEFS_displayNear(0);
    vm.AddToLastGroup(0);
    vm.Create3D_material(0);
    vm.Create3D_tessellation(0);
    vm.Create3D_layer(0);
    vm.Create3D_visibility(0);
    vm.Create3D_weight(0);
    vm.Create3D_closed(0);
    vm.Create3D_orientation(0);
    vm.Create3D_length(0);
    vm.Create3D_width(0);
    vm.Create3D_height(0);
    vm.Create3D_volume(0);
    vm.Create3D_snap(0);
    vm.Create3D_sphereDegree(0);
    vm.Create3D_cylinderDegree(0);
    vm.Create3D_polyDegree(0);
    vm.Create3D_parametricType(0);
    vm.Create3D_personType(0);
    vm.Create3D_plantType(0);
    vm.Modify3D_openningDepth(0);
    vm.Modify3D_openningArea(0);
    vm.Modify3D_openningDeviation(0);
    vm.Modify3D_tessellateRows(0);
    vm.Modify3D_tessellateColumns(0);
    vm.Modify3D_offsetAmount(0);
    vm.Modify3D_weldTreshold(0);
    vm.Select3D_softPower(0);
    vm.Select3D_softRadius(0);
    vm.Select3D_posVector(0);
    vm.Select3D_rotVector(0);
    vm.Select3D_scaleVector(0);
    vm.Select3D_posValue(0);
    vm.Select3D_rotValue(0);
    vm.Select3D_scaleValue(0);
    vm.Select3D_alignX(0);
    vm.Select3D_alignY(0);
    vm.Select3D_alignZ(0);
    vm.Create3D_powAll(0);
    vm.Create3D_powX(0);
    vm.Create3D_powY(0);
    vm.Create3D_powZ(0);
    vm.Create3D_type(0);
    vm.Create3D_degreeMax(0);
    vm.Create3D_seed(0);
    vm.Create3D_trunkSize(0);
    vm.Create3D_leafSize(0);
    vm.Create3D_branchTilt(0);
    vm.Create3D_branchTwist(0);
    vm.Create3D_branchRatio(0);
    vm.Create3D_treeBase(0);
    vm.Land3D_loadTextures(0);
    vm.Land3D_loadMesh(0);
    vm.Land3D_skipStart(0);
    vm.Land3D_skipEnd(0);
    vm.Land3D_displaySurface(0);
    vm.Land3D_displayTexture(0);
    vm.Land3D_displayPoints(0);
    vm.Land3D_displayDepth(0);
    vm.Model2Ds_displayAll(0);
    vm.Model1Ds_displayAll(0);
    vm.Model1Ds_displayLeaves(0);
    vm.Polylines_displayAll(0);
    vm.Faces_displayAll(0);
    vm.Solids_displayAll(0);
    vm.Sections_displayAll(0);
    vm.WindRoses_displayImage(0);
    vm.WindRoses_scale(0);
    vm.Sky3D_displaySurface(0);
    vm.Sun3D_displayPath(0);
    vm.Sun3D_displayPattern(0);
    vm.Camera_current(0);
    vm.Camera_clipNear(0);
    vm.Camera_clipFar(0);
    vm.Create3D_displayVertices(0);
    vm.Create3D_displayEdges(0);
    vm.Create3D_displayNormals(0);
    vm.Cameras_displayAll(0);
    vm.Impacts_displayDay(0);
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
    vm.SolidImpacts_windSpeedMps(0);
    vm.SolidImpacts_windDirection(0);
    vm.SolidImpacts_processSubDivisions(0);
    vm.SolidImpacts_displayPoints(0);
    vm.SolidImpacts_displayLines(0);
    vm.WindFlows_displayAll(0);
    vm.Create3D_displayTessellation(0);
    vm.Land3D_displayTessellation(0);
    vm.Sky3D_displayTessellation(0);
    vm.Sky3D_scale(0);
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
    vm.Planetary_magnification(0);
    vm.Objects_scale(0);
    vm.Diagram_setup(0);
    vm.Scale(0);
    vm.Draw_data(0);
    vm.Draw_sorted(0);
    vm.Draw_statistics(0);
    vm.Draw_probabilities(0);
    vm.Probabilities_interval(0);
    vm.Probabilities_range(0);
    vm.Study_activePaletteClr(0);
    vm.Study_activePaletteDir(0);
    vm.Study_activePaletteMlt(0);
    vm.Study_passivePaletteClr(0);
    vm.Study_passivePaletteDir(0);
    vm.Study_passivePaletteMlt(0);
    vm.Study_sortPaletteClr(0);
    vm.Study_sortPaletteDir(0);
    vm.Study_sortPaletteMlt(0);
    vm.Study_probPaletteClr(0);
    vm.Study_probPaletteDir(0);
    vm.Study_probPaletteMlt(0);
    vm.WindRose_opacityScale(0);
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
    vm.Land3D_paletteClr(0);
    vm.Land3D_paletteDir(0);
    vm.Land3D_paletteMlt(0);
    vm.WindFlows_paletteClr(0);
    vm.WindFlows_paletteDir(0);
    vm.WindFlows_paletteMlt(0);
    vm.Select3D_groupDisplayPivot(0);
    vm.Select3D_displayReferencePivot(0);
    vm.Select3D_groupDisplayBox(0);
    vm.Select3D_groupDisplayEdges(0);
    vm.Select3D_faceDisplayEdges(0);
    vm.Select3D_faceDisplayVertexCount(0);
    vm.Select3D_polylineDisplayVertexCount(0);
    vm.Select3D_vertexDisplayVertices(0);
    vm.Select3D_polylineDisplayVertices(0);
    vm.Select3D_model2DDisplayEdges(0);
    vm.Select3D_model1DDisplayEdges(0);
    vm.Select3D_solidDisplayEdges(0);
    vm.Select3D_sectionDisplayEdges(0);
    vm.Select3D_cameraDisplayEdges(0);
    vm.Select3D_landPointDisplayPoints(0);
    vm.Interpolation_weight(0);
    vm.Climate_based_solar_forecast(0);
    vm.Climate_based_temperature_forecast(0);
    vm.Develop_option(0);
    vm.Develop_dayHour(0);
    vm.Trend_periodHours(0);
    vm.Weighted_equal_trend(0);
    vm.Inclination_angle(0);
    vm.Orientation_angle(0);
    vm.Impact_source(0);
    vm.Impact_min_50_max(0);
    vm.Export_ASCII_data(0);
    vm.Export_ASCII_statistics(0);
    vm.Export_ASCII_probabilities(0);
    vm.Export3D_scale(0);
    vm.Export3D_flipZYaxis(0);
    vm.Export3D_precisionVertex(0);
    vm.Export3D_precisionVtexture(0);
    vm.Export3D_polyToPoly(0);
    vm.Export3D_materialLibrary(0);
    vm.Export3D_backSides(0);
    vm.Export3D_paletteResolution(0);
    vm.Record_SolidImpact_in_JPG(0);
    vm.Record_SolidImpact_in_PDF(0);
    vm.Record_Solar_Analysis_in_JPG(0);
    vm.WindRoses_resolution(0);
  }

  void draw () {

    this.spinnerEditStateChanged = false;
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

        if (!this.spinnerEditActive && isInside(X_clicked, Y_clicked, cx, cy - cr, cx + 150 * this.view_S, cy + cr)) {
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

        if (!this.spinnerEditActive && isInside(X_clicked, Y_clicked, cx, cy - cr, cx + 100 * this.view_S, cy + cr)) {
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
        STUDY.j_End = vm.Number_of_days_to_plot(1);
        STUDY.perDays = vm.Day_step(1);
        STUDY.joinDays = vm.Join_days(1);
        TIME.date = vm.Days_past_March_equinox(1);

        TIME.day = vm.Begin_day(1);
        TIME.month = vm.Begin_month(1);
        TIME.year = vm.Begin_year(1);
      }

      if (this.child == CHILD_PERIOD_RANGES) {
        STUDY.i_Start = vm.Start_hour(1);
        STUDY.i_End = vm.End_hour(1);
        SampleYear_Start = vm.Start_year(1);
        SampleYear_End = vm.End_year(1);
        SampleMember_Start = vm.Start_member(1);
        SampleMember_End = vm.End_member(1);
        SampleStation_Start = vm.Start_station(1);
        SampleStation_End = vm.End_station(1);
        ENSEMBLE_OBSERVED_maxDays = vm.Forecast_Obs_maxDays(1);
      }

      if (this.child == CHILD_PERIOD_FILTERS) {

        STUDY.skyScenario = vm.Sky_status(1);
        STUDY.filter = vm.Hourly_daily_filter(1);
      }
    } else if (this.parent == PARENT_LOCATION) {


      if (this.child == CHILD_LOCATION_POINT) {
        LocationLAT = vm.Latitude(1);
        LocationLON = vm.Longitude(1);
      }

      if (this.child == CHILD_LOCATION_STATIONS) {

        WORLD.displayAll_TMYEPW = vm.TMYEPW_displayAll(1);
        WORLD.displayNear_TMYEPW = vm.TMYEPW_displayNear(1);
        WORLD.displayAll_CWEEDS = vm.CWEEDS_displayAll(1);
        WORLD.displayNear_CWEEDS = vm.CWEEDS_displayNear(1);
        WORLD.displayAll_CLMREC = vm.CLMREC_displayAll(1);
        WORLD.displayNear_CLMREC = vm.CLMREC_displayNear(1);
        WORLD.displayAll_SWOB = vm.SWOB_displayAll(1);
        WORLD.displayNear_SWOB = vm.SWOB_displayNear(1);
        WORLD.displayAll_NAEFS = vm.NAEFS_displayAll(1);
        WORLD.displayNear_NAEFS = vm.NAEFS_displayNear(1);
      }
    } else if (this.parent == PARENT_GEOMETRY) {
      if (this.child == CHILD_GEOMETRY_CREATE) {

        addToLastGroup = vm.AddToLastGroup(1);
        User3D.default_Material = vm.Create3D_material(1);
        User3D.default_Tessellation = vm.Create3D_tessellation(1);
        User3D.default_Layer = vm.Create3D_layer(1);
        User3D.default_Visibility = vm.Create3D_visibility(1);
        User3D.default_Weight = vm.Create3D_weight(1);
        User3D.default_Closed = vm.Create3D_closed(1);
        User3D.create_Orientation = vm.Create3D_orientation(1);
        User3D.create_Length = vm.Create3D_length(1);
        User3D.create_Width = vm.Create3D_width(1);
        User3D.create_Height = vm.Create3D_height(1);
        User3D.create_Volume = vm.Create3D_volume(1);
        User3D.create_Snap = vm.Create3D_snap(1);
        User3D.create_SphereDegree = vm.Create3D_sphereDegree(1);
        User3D.create_CylinderDegree = vm.Create3D_cylinderDegree(1);
        User3D.create_PolyDegree = vm.Create3D_polyDegree(1);
        User3D.create_Parametric_Type = vm.Create3D_parametricType(1);
        User3D.create_Person_Type = vm.Create3D_personType(1);
        User3D.create_Plant_Type = vm.Create3D_plantType(1);
      }

      if (this.child == CHILD_GEOMETRY_MODIFY) {

        User3D.modify_OpenningDepth = vm.Modify3D_openningDepth(1);
        User3D.modify_OpenningArea = vm.Modify3D_openningArea(1);
        User3D.modify_OpenningDeviation = vm.Modify3D_openningDeviation(1);
        User3D.modify_TessellateRows = vm.Modify3D_tessellateRows(1);
        User3D.modify_TessellateColumns = vm.Modify3D_tessellateColumns(1);
        User3D.modify_OffsetAmount = vm.Modify3D_offsetAmount(1);
        User3D.modify_WeldTreshold = vm.Modify3D_weldTreshold(1);
        Select3D.softPower = vm.Select3D_softPower(1);
        Select3D.softRadius = vm.Select3D_softRadius(1);
        Select3D.posVector = vm.Select3D_posVector(1);
        Select3D.rotVector = vm.Select3D_rotVector(1);
        Select3D.scaleVector = vm.Select3D_scaleVector(1);
        Select3D.posValue = vm.Select3D_posValue(1);
        Select3D.rotValue = vm.Select3D_rotValue(1);
        Select3D.scaleValue = vm.Select3D_scaleValue(1);
        Select3D.alignX = vm.Select3D_alignX(1);
        Select3D.alignY = vm.Select3D_alignY(1);
        Select3D.alignZ = vm.Select3D_alignZ(1);
      }

      if (this.child == CHILD_GEOMETRY_SOLID) {
        User3D.create_powAll = vm.Create3D_powAll(1);
        User3D.create_powX = vm.Create3D_powX(1);
        User3D.create_powY = vm.Create3D_powY(1);
        User3D.create_powZ = vm.Create3D_powZ(1);
      }


      if (this.child == CHILD_GEOMETRY_FRACTAL_TREE) {

        User3D.create_Model1D_Type = vm.Create3D_type(1);
        User3D.create_Model1D_DegreeMax = vm.Create3D_degreeMax(1);
        User3D.create_Model1D_Seed = vm.Create3D_seed(1);
        User3D.create_Model1D_TrunkSize = vm.Create3D_trunkSize(1);
        User3D.create_Model1D_LeafSize = vm.Create3D_leafSize(1);
        User3D.create_Model1D_BranchTilt = vm.Create3D_branchTilt(1);
        User3D.create_Model1D_BranchTwist = vm.Create3D_branchTwist(1);
        User3D.create_Model1D_BranchRatio = vm.Create3D_branchRatio(1);
        User3D.create_Model1D_TreeBase = vm.Create3D_treeBase(1);
      }

      if (this.child == CHILD_GEOMETRY_ENVIRONMENT) {

        Land3D.loadTextures = vm.Land3D_loadTextures(1);
        Land3D.loadMesh = vm.Land3D_loadMesh(1);
        Land3D.skipStart = vm.Land3D_skipStart(1);
        Land3D.skipEnd = vm.Land3D_skipEnd(1);
        Land3D.displaySurface = vm.Land3D_displaySurface(1);
        Land3D.displayTexture = vm.Land3D_displayTexture(1);
        Land3D.displayPoints = vm.Land3D_displayPoints(1);
        Land3D.displayDepth = vm.Land3D_displayDepth(1);
        allModel2Ds.displayAll = vm.Model2Ds_displayAll(1);
        allModel1Ds.displayAll = vm.Model1Ds_displayAll(1);
        allModel1Ds.displayLeaves = vm.Model1Ds_displayLeaves(1);
        allPolylines.displayAll = vm.Polylines_displayAll(1);
        allFaces.displayAll = vm.Faces_displayAll(1);
        allSolids.displayAll = vm.Solids_displayAll(1);
        allSections.displayAll = vm.Sections_displayAll(1);
        allWindRoses.displayImage = vm.WindRoses_displayImage(1);
        allWindRoses.scale = vm.WindRoses_scale(1);
        allWindRoses.RES = vm.WindRoses_resolution(1);



        Sky3D.displaySurface = vm.Sky3D_displaySurface(1);
        Sun3D.displayPath = vm.Sun3D_displayPath(1);
        Sun3D.displayPattern = vm.Sun3D_displayPattern(1);
      }


      if (this.child == CHILD_GEOMETRY_VIEWPORT) {

        WIN3D.currentCamera = vm.Camera_current(1);
        WIN3D.CAM_clipNear = vm.Camera_clipNear(1);
        WIN3D.CAM_clipFar = vm.Camera_clipFar(1);
        allPoints.displayAll = vm.Create3D_displayVertices(1);
        allFaces.displayEdges = vm.Create3D_displayEdges(1);
        allFaces.displayNormals = vm.Create3D_displayNormals(1);
        allCameras.displayAll = vm.Cameras_displayAll(1);
      }


      if (this.child == CHILD_GEOMETRY_SIMULATION) {

        IMPACTS_displayDay = vm.Impacts_displayDay(1);
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
        allSolidImpacts.WindSpeed = vm.SolidImpacts_windSpeedMps(1);
        allSolidImpacts.WindDirection = vm.SolidImpacts_windDirection(1);
        allSolidImpacts.Process_subDivisions = vm.SolidImpacts_processSubDivisions(1);
        allSolidImpacts.displayPoints = vm.SolidImpacts_displayPoints(1);
        allSolidImpacts.displayLines = vm.SolidImpacts_displayLines(1);
        allWindFlows.displayAll = vm.WindFlows_displayAll(1);
      }

      if (this.child == CHILD_GEOMETRY_OTHER) {

        allFaces.displayTessellation = vm.Create3D_displayTessellation(1);
        Land3D.displayTessellation = vm.Land3D_displayTessellation(1);
        Sky3D.displayTessellation = vm.Sky3D_displayTessellation(1);
          Sky3D.radius = vm.Sky3D_scale(1);
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
        Planetary_Magnification = vm.Planetary_magnification(1);
        OBJECTS_scale = vm.Objects_scale(1);
      }

    } else if (this.parent == PARENT_ILLUSTRATION) {

      if (this.child == CHILD_ILLUSTRATION_2D_LAYERS) {
        STUDY.plotSetup = vm.Diagram_setup(1);
        STUDY.V_scale = vm.Scale(1);
        STUDY.displayRaws = vm.Draw_data(1);
        STUDY.displaySorted = vm.Draw_sorted(1);
        STUDY.displayNormals = vm.Draw_statistics(1);
        STUDY.displayProbs = vm.Draw_probabilities(1);
        STUDY.sumInterval = vm.Probabilities_interval(1);
        STUDY.LevelPix = vm.Probabilities_range(1);
      }

      if (this.child == CHILD_ILLUSTRATION_2D_COLORS) {

        STUDY.ACTIVE_palette_CLR = vm.Study_activePaletteClr(1);
        STUDY.ACTIVE_palette_DIR = vm.Study_activePaletteDir(1);
        STUDY.ACTIVE_palette_MLT = vm.Study_activePaletteMlt(1);
        STUDY.PASSIVE_palette_CLR = vm.Study_passivePaletteClr(1);
        STUDY.PASSIVE_palette_DIR = vm.Study_passivePaletteDir(1);
        STUDY.PASSIVE_palette_MLT = vm.Study_passivePaletteMlt(1);
        STUDY.SORT_palette_CLR = vm.Study_sortPaletteClr(1);
        STUDY.SORT_palette_DIR = vm.Study_sortPaletteDir(1);
        STUDY.SORT_palette_MLT = vm.Study_sortPaletteMlt(1);
        STUDY.PROB_palette_CLR = vm.Study_probPaletteClr(1);
        STUDY.PROB_palette_DIR = vm.Study_probPaletteDir(1);
        STUDY.PROB_palette_MLT = vm.Study_probPaletteMlt(1);
        STUDY.O_scale = vm.WindRose_opacityScale(1);
      }

      if (this.child == CHILD_ILLUSTRATION_3D_SOLAR) {

        allFaces.ACTIVE_palette_CLR = vm.Faces_activePaletteClr(1);
        allFaces.ACTIVE_palette_DIR = vm.Faces_activePaletteDir(1);
        allFaces.ACTIVE_palette_MLT = vm.Faces_activePaletteMlt(1);
        allFaces.PASSIVE_palette_CLR = vm.Faces_passivePaletteClr(1);
        allFaces.PASSIVE_palette_DIR = vm.Faces_passivePaletteDir(1);
        allFaces.PASSIVE_palette_MLT = vm.Faces_passivePaletteMlt(1);
        Sky3D.ACTIVE_palette_CLR = vm.Sky3D_activePaletteClr(1);
        Sky3D.ACTIVE_palette_DIR = vm.Sky3D_activePaletteDir(1);
        Sky3D.ACTIVE_palette_MLT = vm.Sky3D_activePaletteMlt(1);
        Sky3D.PASSIVE_palette_CLR = vm.Sky3D_passivePaletteClr(1);
        Sky3D.PASSIVE_palette_DIR = vm.Sky3D_passivePaletteDir(1);
        Sky3D.PASSIVE_palette_MLT = vm.Sky3D_passivePaletteMlt(1);
        Sun3D.ACTIVE_palette_CLR = vm.Sun3D_activePaletteClr(1);
        Sun3D.ACTIVE_palette_DIR = vm.Sun3D_activePaletteDir(1);
        Sun3D.ACTIVE_palette_MLT = vm.Sun3D_activePaletteMlt(1);
        Sun3D.PASSIVE_palette_CLR = vm.Sun3D_passivePaletteClr(1);
        Sun3D.PASSIVE_palette_DIR = vm.Sun3D_passivePaletteDir(1);
        Sun3D.PASSIVE_palette_MLT = vm.Sun3D_passivePaletteMlt(1);
      }




      if (this.child == CHILD_ILLUSTRATION_3D_SPATIAL) {

        allSolids.palette_CLR = vm.Solids_paletteClr(1);
        allSolids.palette_DIR = vm.Solids_paletteDir(1);
        allSolids.palette_MLT = vm.Solids_paletteMlt(1);
        Land3D.palette_CLR = vm.Land3D_paletteClr(1);
        Land3D.palette_DIR = vm.Land3D_paletteDir(1);
        Land3D.palette_MLT = vm.Land3D_paletteMlt(1);
        allWindFlows.palette_CLR = vm.WindFlows_paletteClr(1);
        allWindFlows.palette_DIR = vm.WindFlows_paletteDir(1);
        allWindFlows.palette_MLT = vm.WindFlows_paletteMlt(1);
      }


      if (this.child == CHILD_ILLUSTRATION_SELECTION) {

        Select3D.Group_displayPivot = vm.Select3D_groupDisplayPivot(1);
        Select3D.displayReferencePivot = vm.Select3D_displayReferencePivot(1);
        Select3D.Group_displayBox = vm.Select3D_groupDisplayBox(1);
        Select3D.Group_displayEdges = vm.Select3D_groupDisplayEdges(1);
        Select3D.Face_displayEdges = vm.Select3D_faceDisplayEdges(1);
        Select3D.Face_displayVertexCount = vm.Select3D_faceDisplayVertexCount(1);
        Select3D.Polyline_displayVertexCount = vm.Select3D_polylineDisplayVertexCount(1);
        Select3D.Vertex_displayVertices = vm.Select3D_vertexDisplayVertices(1);
        Select3D.Polyline_displayVertices = vm.Select3D_polylineDisplayVertices(1);
        Select3D.Model2D_displayEdges = vm.Select3D_model2DDisplayEdges(1);
        Select3D.Model1D_displayEdges = vm.Select3D_model1DDisplayEdges(1);
        Select3D.Solid_displayEdges = vm.Select3D_solidDisplayEdges(1);
        Select3D.Section_displayEdges = vm.Select3D_sectionDisplayEdges(1);
        Select3D.Camera_displayEdges = vm.Select3D_cameraDisplayEdges(1);
        Select3D.LandPoint_displayPoints = vm.Select3D_landPointDisplayPoints(1);
      }
    } else if (this.parent == PARENT_POSTPROCESS) {

      if (this.child == CHILD_POSTPROCESS_INTERPOLATION) {

        Interpolation_Weight = vm.Interpolation_weight(1);
        CLIMATIC_SolarForecast = vm.Climate_based_solar_forecast(1);
        CLIMATIC_WeatherForecast = vm.Climate_based_temperature_forecast(1);
      }
      if (this.child == CHILD_POSTPROCESS_DEVELOPED) {
        Develop_Option = vm.Develop_option(1);
        Develop_DayHour = vm.Develop_dayHour(1);
        STUDY.TrendJoinHours = vm.Trend_periodHours(1);
        STUDY.TrendJoinType = vm.Weighted_equal_trend(1);
        Develop_AngleInclination = vm.Inclination_angle(1);
        Develop_AngleOrientation = vm.Orientation_angle(1);
      }
      if (this.child == CHILD_POSTPROCESS_IMPACTS) {
        CurrentDataSource = vm.Impact_source(1);
        STUDY.ImpactLayer = vm.Impact_min_50_max(1);
      }
    } else if (this.parent == PARENT_EXPORT) {

      if (this.child == CHILD_EXPORT_DATA) {

        STUDY.export_info_node = vm.Export_ASCII_data(1);
        STUDY.export_info_norm = vm.Export_ASCII_statistics(1);
        STUDY.export_info_prob = vm.Export_ASCII_probabilities(1);
        User3D.export_Scale = vm.Export3D_scale(1);
        User3D.export_FlipZYaxis = vm.Export3D_flipZYaxis(1);
        User3D.export_PrecisionVertex = vm.Export3D_precisionVertex(1);
        User3D.export_PrecisionVtexture = vm.Export3D_precisionVtexture(1);
        User3D.export_PolyToPoly = vm.Export3D_polyToPoly(1);
        User3D.export_MaterialLibrary = vm.Export3D_materialLibrary(1);
        User3D.export_BackSides = vm.Export3D_backSides(1);
        User3D.export_PaletteResolution = vm.Export3D_paletteResolution(1);
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

    if (this.spinnerEditStateChanged) {
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
    this.spinnerEditActive = true;
    this.spinnerEditCaption = caption;
    this.spinnerEditText = this.formatSpinnerValue(value);
    this.spinnerEditCursor = this.spinnerEditText.length();
    this.spinnerEditCommit = false;
    this.spinnerEditStateChanged = true;
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
    boolean editingThis = this.spinnerEditActive && this.spinnerEditCaption.equals(caption);

    if (editingThis && this.spinnerEditCommit) {

      float typed_value = v;
      try {
        typed_value = Float.parseFloat(this.spinnerEditText);
      }
      catch (Exception ex) {
        typed_value = v;
      }

      new_value = typed_value;
      if (new_value < min_v) new_value = min_v;
      if (new_value > max_v) new_value = max_v;

      this.spinnerEditActive = false;
      this.spinnerEditCaption = "";
      this.spinnerEditText = "";
      this.spinnerEditCursor = 0;
      this.spinnerEditCommit = false;

      editingThis = false;

      this.spinnerEditStateChanged = true;

      UI_rollout.revise();
    }

    // Tab / Shift+Tab requested this spinner become the new edit target.
    if ((this.spinnerEditPendingCaption != null) && this.spinnerEditPendingCaption.equals(caption) && !editingThis) {

      this.beginSpinnerEdit(caption, new_value);
      this.spinnerEditPendingCaption = null;

      editingThis = true;
    }

    if ((!this.spinnerEditActive || editingThis) && (
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

    if (!this.spinnerEditActive && isInside(X_clicked, Y_clicked, cx - cr, cy - cr, cx + cr, cy + cr)) {
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

    if (!this.spinnerEditActive && isInside(X_clicked, Y_clicked, cx - cr, cy - cr, cx + cr, cy + cr)) {

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

    if (!this.spinnerEditActive && isInside(X_clicked, Y_clicked, x - w1, y - (h / 2), x, y + (h / 2))) {
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
      String textWithCursor = this.spinnerEditText.substring(0, this.spinnerEditCursor) + "|" + this.spinnerEditText.substring(this.spinnerEditCursor);
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
    return this.spinnerEditActive;
  }

  void keyPressed (KeyEvent e) {

    if (!this.spinnerEditActive) return;
    if (e.isAltDown() || e.isControlDown()) return;

    if (key == CODED) {
      switch (keyCode) {

        case LEFT:
          if (this.spinnerEditCursor > 0) this.spinnerEditCursor--;
          break;

        case RIGHT:
          if (this.spinnerEditCursor < this.spinnerEditText.length()) this.spinnerEditCursor++;
          break;
      }

      this.revise();
      return;
    }

    switch (key) {

      case ENTER:
        this.spinnerEditCommit = true;
        break;

      case ESC:
        // Cancel editing: drop the typed text and leave the spinner's
        // actual value untouched (it was never applied during editing).
        this.spinnerEditActive = false;
        this.spinnerEditCaption = "";
        this.spinnerEditText = "";
        this.spinnerEditCursor = 0;
        this.spinnerEditCommit = false;
        this.spinnerEditPendingCaption = null;
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
            int idx = this.spinnerOrderThisPass.indexOf(this.spinnerEditCaption);
            if (idx == -1) idx = 0;

            int nextIdx = e.isShiftDown() ? ((idx - 1 + n) % n) : ((idx + 1) % n);

            this.spinnerEditPendingCaption = this.spinnerOrderThisPass.get(nextIdx);
          }
        }
        break;

      case BACKSPACE:
        if (this.spinnerEditCursor > 0) {
          this.spinnerEditText = this.spinnerEditText.substring(0, this.spinnerEditCursor - 1) + this.spinnerEditText.substring(this.spinnerEditCursor);
          this.spinnerEditCursor--;
        }
        break;

      case DELETE:
        if (this.spinnerEditCursor < this.spinnerEditText.length()) {
          this.spinnerEditText = this.spinnerEditText.substring(0, this.spinnerEditCursor) + this.spinnerEditText.substring(this.spinnerEditCursor + 1);
        }
        break;

      case '-':
        // A minus sign is only meaningful as the very first character.
        if ((this.spinnerEditCursor == 0) && ((this.spinnerEditText.length() == 0) || (this.spinnerEditText.charAt(0) != '-'))) {
          this.spinnerEditText = "-" + this.spinnerEditText;
          this.spinnerEditCursor++;
        }
        break;

      default:
        if ((key >= '0') && (key <= '9')) {
          this.spinnerEditText = this.spinnerEditText.substring(0, this.spinnerEditCursor) + key + this.spinnerEditText.substring(this.spinnerEditCursor);
          this.spinnerEditCursor++;
        } else if ((key == '.') && (this.spinnerEditText.indexOf('.') == -1)) {
          this.spinnerEditText = this.spinnerEditText.substring(0, this.spinnerEditCursor) + key + this.spinnerEditText.substring(this.spinnerEditCursor);
          this.spinnerEditCursor++;
        }
        break;
    }

    this.revise();
  }
}
