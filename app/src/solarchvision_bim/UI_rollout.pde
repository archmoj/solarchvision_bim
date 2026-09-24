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

    // ---- Shared follow-up callbacks (see applyRolloutUpdate.pde for the
    // original once-per-frame diff logic each of these replicates) ----

    // TIME.year/month/day (and CLIMATIC_SolarForecast/WeatherForecast, which
    // are diffed together with them) need TIME.beginDay/TIME.date recomputed
    // and the ensemble forecast reloaded for the new date.
    SpinnerApplied applyTimeChange = (o, n) -> {
      TIME.beginDay = TIME.convert2Date(TIME.month, TIME.day);
      TIME.hour = int(24 * (TIME.date - int(TIME.date)));
      TIME.date = (TIME.hour / 24.0) + (286 + TIME.convert2Date(TIME.month, TIME.day)) % 365;
      println("DATE:", TIME.date, "\tHOUR:", TIME.hour);
      update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);
    };

    // Latitude/Longitude also need the matching world viewport looked up.
    SpinnerApplied applyLocationChange = (o, n) -> {
      WORLD.VIEW_id = WORLD.FindGoodViewport(LocationLON, LocationLAT);
      WORLD.revise();
    };

    SpinnerApplied viewChangedOnly = (o, n) -> view_changed();
    SpinnerApplied caseBarOnly = (o, n) -> UI_caseBar.revise();
    SpinnerApplied recalcImpact = (o, n) -> { allSolidImpacts.calculate_Impact_selectedSections(); view_changed(); };
    SpinnerApplied selectionChangedOnly = (o, n) -> selection_changed();
    SpinnerApplied softSelectionChanged = (o, n) -> Select3D.convert_Vertex_to_softSelection();
    SpinnerApplied impactsUpdateFlag = (o, n) -> { STUDY.Impacts_update = true; UI_caseBar.updated(); };

    // Move/Rotate/Scale-by-delta spinners: applyRolloutUpdate.pde applies the
    // *difference* between the old and new spinner reading as a transform on
    // the current selection, rather than treating the field as a plain
    // setting - replicated here using the old/new values SpinnerApplied gets.
    SpinnerApplied applyPosValue = (o, n) -> {
      float d = n - o;
      float dx = d, dy = d, dz = d;
      int the_Vector = Select3D.posVector;
      if (the_Vector == 0) { dy = 0; dz = 0; }
      if (the_Vector == 1) { dz = 0; dx = 0; }
      if (the_Vector == 2) { dx = 0; dy = 0; }
      Move3D.selection(dx, dy, dz);
      model_changed();
    };
    SpinnerApplied applyRotValue = (o, n) -> {
      float[] P = Select3D.getPivot();
      float r = n - o;
      Rotate3D.selection(P[0], P[1], P[2], r, Select3D.rotVector);
      model_changed();
    };
    SpinnerApplied applyScaleValue = (o, n) -> {
      float[] P = Select3D.getPivot();
      float s = pow(2.0, n - o);
      float sx = s, sy = s, sz = s;
      int the_Vector = Select3D.scaleVector;
      if (the_Vector == 0) { sy = 1; sz = 1; }
      if (the_Vector == 1) { sz = 1; sx = 1; }
      if (the_Vector == 2) { sx = 1; sy = 1; }
      Scale3D.selection(P[0], P[1], P[2], sx, sy, sz);
      model_changed();
    };

    // ---- One command per this.Spinner(...) call in draw(), same
    // min/max/step and update1/update2/update3 as that call. ----

    // STUDY.j_End = this.Spinner(..., "Number of days to plot", 1, 365, 1);  [line 348]
    putSpinnerAction("number_of_days_to_plot",
      () -> (float) STUDY.j_End,
      (v) -> { STUDY.j_End = int(v); },
      1, 365, 1,
      1, 1, 0,
      (o, n) -> {
        if (WIN3D.FacesShade == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;
        if (WIN3D.FacesShade == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
        allSolarImpacts.rebuild_Image_array = true;
        allWindRoses.rebuild_Image_array = true;
        allSections.resize_solarImpact_array();
      });

    // STUDY.perDays = this.Spinner(..., "Day step", 1.0, 182.5, 0.5);  [line 350]
    putSpinnerAction("day_step",
      () -> STUDY.perDays,
      (v) -> { STUDY.perDays = v; },
      1.0, 182.5, 0.5,
      1, 1, 0);

    // STUDY.joinDays = this.Spinner(..., "Join days", 1, 182, 1);  [line 352]
    putSpinnerAction("join_days",
      () -> (float) STUDY.joinDays,
      (v) -> { STUDY.joinDays = int(v); },
      1, 182, 1,
      1, 1, 0,
      caseBarOnly);

    // TIME.date = this.Spinner(..., "Days past March equinox", 0, 364, 1);  [line 354]
    putSpinnerAction("days_past_march_equinox",
      () -> TIME.date,
      (v) -> { TIME.date = v; },
      0, 364, 1,
      1, 1, 0,
      (o, n) -> {
        TIME.updateDate();
      });

    // TIME.day = this.Spinner(..., "Start day", 1, 31, 1);  [line 358]
    putSpinnerAction("start_day",
      () -> (float) TIME.day,
      (v) -> { TIME.day = int(v); },
      1, 31, 1,
      1, 1, 0,
      applyTimeChange);

    // TIME.month = this.Spinner(..., "Start month", 1, 12, 1);  [line 359]
    putSpinnerAction("start_month",
      () -> (float) TIME.month,
      (v) -> { TIME.month = int(v); },
      1, 12, 1,
      1, 1, 0,
      applyTimeChange);

    // TIME.year = this.Spinner(..., "Start year", 1953, 2100, 1);  [line 360]
    putSpinnerAction("start_year",
      () -> (float) TIME.year,
      (v) -> { TIME.year = int(v); },
      1953, 2100, 1,
      1, 1, 0,
      applyTimeChange);

    // STUDY.i_Start = this.Spinner(..., "Start hour", 0, 23, 1);  [line 364]
    putSpinnerAction("start_hour",
      () -> (float) STUDY.i_Start,
      (v) -> { STUDY.i_Start = int(v); },
      0, 23, 1,
      1, 0, 0,
      caseBarOnly);

    // STUDY.i_End = this.Spinner(..., "End hour", 0, 23, 1);  [line 365]
    putSpinnerAction("end_hour",
      () -> (float) STUDY.i_End,
      (v) -> { STUDY.i_End = int(v); },
      0, 23, 1,
      1, 0, 0,
      caseBarOnly);

    // SampleYear_Start = this.Spinner(..., "Start year", CLIMATE_CWEEDS_start, CLIMATE_CLMREC_end, 1);  [line 367]
    putSpinnerAction("sample_year_start",
      () -> (float) SampleYear_Start,
      (v) -> { SampleYear_Start = int(v); },
      () -> (float) (CLIMATE_CWEEDS_start), () -> (float) (CLIMATE_CLMREC_end), 1,
      1, 0, 0,
      caseBarOnly);

    // SampleYear_End = this.Spinner(..., "End year", CLIMATE_CWEEDS_start, CLIMATE_CLMREC_end, 1);  [line 368]
    putSpinnerAction("end_year",
      () -> (float) SampleYear_End,
      (v) -> { SampleYear_End = int(v); },
      () -> (float) (CLIMATE_CWEEDS_start), () -> (float) (CLIMATE_CLMREC_end), 1,
      1, 0, 0,
      caseBarOnly);

    // SampleMember_Start = this.Spinner(..., "Start member", ENSEMBLE_FORECAST_start, ENSEMBLE_FORECAST_end, 1);  [line 370]
    putSpinnerAction("start_member",
      () -> (float) SampleMember_Start,
      (v) -> { SampleMember_Start = int(v); },
      () -> (float) (ENSEMBLE_FORECAST_start), () -> (float) (ENSEMBLE_FORECAST_end), 1,
      1, 0, 0,
      caseBarOnly);

    // SampleMember_End = this.Spinner(..., "End member", ENSEMBLE_FORECAST_start, ENSEMBLE_FORECAST_end, 1);  [line 371]
    putSpinnerAction("end_member",
      () -> (float) SampleMember_End,
      (v) -> { SampleMember_End = int(v); },
      () -> (float) (ENSEMBLE_FORECAST_start), () -> (float) (ENSEMBLE_FORECAST_end), 1,
      1, 0, 0,
      caseBarOnly);

    // SampleStation_Start = this.Spinner(..., "Start station", ENSEMBLE_OBSERVED_start, ENSEMBLE_OBSERVED_end, 1);  [line 373]
    putSpinnerAction("start_station",
      () -> (float) SampleStation_Start,
      (v) -> { SampleStation_Start = int(v); },
      () -> (float) (ENSEMBLE_OBSERVED_start), () -> (float) (ENSEMBLE_OBSERVED_end), 1,
      1, 0, 0,
      caseBarOnly);

    // SampleStation_End = this.Spinner(..., "End station", ENSEMBLE_OBSERVED_start, ENSEMBLE_OBSERVED_end, 1);  [line 374]
    putSpinnerAction("end_station",
      () -> (float) SampleStation_End,
      (v) -> { SampleStation_End = int(v); },
      () -> (float) (ENSEMBLE_OBSERVED_start), () -> (float) (ENSEMBLE_OBSERVED_end), 1,
      1, 0, 0,
      caseBarOnly);

    // ENSEMBLE_OBSERVED_maxDays = this.Spinner(..., "Forecast/Obs_maxDays", 0, 31, 1);  [line 376]
    putSpinnerAction("forecast_obs_max_days",
      () -> (float) ENSEMBLE_OBSERVED_maxDays,
      (v) -> { ENSEMBLE_OBSERVED_maxDays = int(v); },
      0, 31, 1,
      0, 0, 1);

    // STUDY.skyScenario = this.Spinner(..., "Sky status", 1, 4, 1);  [line 381]
    putSpinnerAction("sky_status",
      () -> (float) STUDY.skyScenario,
      (v) -> { STUDY.skyScenario = int(v); },
      1, 4, 1,
      1, 0, 0);

    // STUDY.filter = this.Spinner(..., "Hourly/daily filter", 0, 1, 1);  [line 382]
    putSpinnerAction("hourly_daily_filter",
      () -> (float) STUDY.filter,
      (v) -> { STUDY.filter = int(v); },
      0, 1, 1,
      1, 0, 0);

    // LocationLAT = this.Spinner(..., "Latitude", -85, 85, 0.01);  [line 388]
    putSpinnerAction("latitude",
      () -> LocationLAT,
      (v) -> { LocationLAT = v; },
      -85, 85, 0.01,
      0, 0, 1,
      applyLocationChange);

    // LocationLON = this.Spinner(..., "Longitude", -180, 180, 0.01);  [line 389]
    putSpinnerAction("longitude",
      () -> LocationLON,
      (v) -> { LocationLON = v; },
      -180, 180, 0.01,
      0, 0, 1,
      applyLocationChange);

    // WORLD.displayAll_TMYEPW = this.Spinner(..., "displayAll_TMYEPW", 0, 2, 1);  [line 395]
    putSpinnerAction("display_all_tmyepw",
      () -> (float) WORLD.displayAll_TMYEPW,
      (v) -> { WORLD.displayAll_TMYEPW = int(v); },
      0, 2, 1,
      0, 0, 1);

    // WORLD.displayNear_TMYEPW = this.Spinner(..., "displayNear_TMYEPW");  [line 396]
    putSpinnerAction("display_near_tmyepw",
      () -> (WORLD.displayNear_TMYEPW ? 1f : 0f),
      (v) -> { WORLD.displayNear_TMYEPW = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 1);

    // WORLD.displayAll_CWEEDS = this.Spinner(..., "displayAll_CWEEDS", 0, 2, 1);  [line 398]
    putSpinnerAction("display_all_cweeds",
      () -> (float) WORLD.displayAll_CWEEDS,
      (v) -> { WORLD.displayAll_CWEEDS = int(v); },
      0, 2, 1,
      0, 0, 1);

    // WORLD.displayNear_CWEEDS = this.Spinner(..., "displayNear_CWEEDS");  [line 399]
    putSpinnerAction("display_near_cweeds",
      () -> (WORLD.displayNear_CWEEDS ? 1f : 0f),
      (v) -> { WORLD.displayNear_CWEEDS = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 1);

    // WORLD.displayAll_CLMREC = this.Spinner(..., "displayAll_CLMREC", 0, 2, 1);  [line 401]
    putSpinnerAction("display_all_clmrec",
      () -> (float) WORLD.displayAll_CLMREC,
      (v) -> { WORLD.displayAll_CLMREC = int(v); },
      0, 2, 1,
      0, 0, 1);

    // WORLD.displayNear_CLMREC = this.Spinner(..., "displayNear_CLMREC");  [line 402]
    putSpinnerAction("display_near_clmrec",
      () -> (WORLD.displayNear_CLMREC ? 1f : 0f),
      (v) -> { WORLD.displayNear_CLMREC = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 1);

    // WORLD.displayAll_SWOB = this.Spinner(..., "displayAll_SWOB", 0, 2, 1);  [line 404]
    putSpinnerAction("display_all_swob",
      () -> (float) WORLD.displayAll_SWOB,
      (v) -> { WORLD.displayAll_SWOB = int(v); },
      0, 2, 1,
      0, 0, 1);

    // WORLD.displayNear_SWOB = this.Spinner(..., "displayNear_SWOB");  [line 405]
    putSpinnerAction("display_near_swob",
      () -> (WORLD.displayNear_SWOB ? 1f : 0f),
      (v) -> { WORLD.displayNear_SWOB = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 1);

    // WORLD.displayAll_NAEFS = this.Spinner(..., "displayAll_NAEFS", 0, 2, 1);  [line 407]
    putSpinnerAction("display_all_naefs",
      () -> (float) WORLD.displayAll_NAEFS,
      (v) -> { WORLD.displayAll_NAEFS = int(v); },
      0, 2, 1,
      0, 0, 1);

    // WORLD.displayNear_NAEFS = this.Spinner(..., "displayNear_NAEFS");  [line 408]
    putSpinnerAction("display_near_naefs",
      () -> (WORLD.displayNear_NAEFS ? 1f : 0f),
      (v) -> { WORLD.displayNear_NAEFS = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 1);

    // addToLastGroup = this.Spinner(..., "addToLastGroup");  [line 413]
    putSpinnerAction("add_to_last_group",
      () -> (addToLastGroup ? 1f : 0f),
      (v) -> { addToLastGroup = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // User3D.default_Material = this.Spinner(..., "3D-create.Material", -1, 8, 1);  [line 415]
    putSpinnerAction("3_d_create_material",
      () -> (float) User3D.default_Material,
      (v) -> { User3D.default_Material = int(v); },
      -1, 8, 1,
      0, 0, 0);

    // User3D.default_Tessellation = this.Spinner(..., "3D-create.Tessellation", 0, 6, 1);  [line 416]
    putSpinnerAction("3_d_create_tessellation",
      () -> (float) User3D.default_Tessellation,
      (v) -> { User3D.default_Tessellation = int(v); },
      0, 6, 1,
      0, 0, 0);

    // User3D.default_Layer = this.Spinner(..., "3D-create.Layer", 0, 16, 1);  [line 417]
    putSpinnerAction("3_d_create_layer",
      () -> (float) User3D.default_Layer,
      (v) -> { User3D.default_Layer = int(v); },
      0, 16, 1,
      0, 0, 0);

    // User3D.default_Visibility = this.Spinner(..., "3D-create.Visibility", -1, 1, 1);  [line 418]
    putSpinnerAction("3_d_create_visibility",
      () -> (float) User3D.default_Visibility,
      (v) -> { User3D.default_Visibility = int(v); },
      -1, 1, 1,
      0, 0, 0);

    // User3D.default_Weight = this.Spinner(..., "3D-create.Weight", -20, 20, 1);  [line 419]
    putSpinnerAction("3_d_create_weight",
      () -> (float) User3D.default_Weight,
      (v) -> { User3D.default_Weight = int(v); },
      -20, 20, 1,
      0, 0, 0);

    // User3D.default_Closed = this.Spinner(..., "3D-create.Closed", 0, 1, 1);  [line 420]
    putSpinnerAction("3_d_create_closed",
      () -> (float) User3D.default_Closed,
      (v) -> { User3D.default_Closed = int(v); },
      0, 1, 1,
      0, 0, 0);

    // User3D.create_Orientation = this.Spinner(..., "3D-create.Orientation", 0, 360, 1);  [line 422]
    putSpinnerAction("3_d_create_orientation",
      () -> User3D.create_Orientation,
      (v) -> { User3D.create_Orientation = v; },
      0, 360, 0.001,
      0, 0, 0);

    // User3D.create_Length = this.Spinner(..., "3D-create.Length (rand negative)", -100.0, 1000.0, 1.0);  [line 424]
    putSpinnerAction("3_d_create_length_rand_negative",
      () -> User3D.create_Length,
      (v) -> { User3D.create_Length = v; },
      -100.0, 1000.0, 0.001,
      0, 0, 0);

    // User3D.create_Width = this.Spinner(..., "3D-create.Width (rand negative)", -100.0, 1000.0, 1.0);  [line 425]
    putSpinnerAction("3_d_create_width_rand_negative",
      () -> User3D.create_Width,
      (v) -> { User3D.create_Width = v; },
      -100.0, 1000.0, 0.001,
      0, 0, 0);

    // User3D.create_Height = this.Spinner(..., "3D-create.Height (rand negative)", -100.0, 1000.0, 1.0);  [line 426]
    putSpinnerAction("3_d_create_height_rand_negative",
      () -> User3D.create_Height,
      (v) -> { User3D.create_Height = v; },
      -100.0, 1000.0, 0.001,
      0, 0, 0);

    // User3D.create_Volume = this.Spinner(..., "3D-create.Volume", 0, 1000000000, 1);  [line 428]
    putSpinnerAction("3_d_create_volume",
      () -> User3D.create_Volume,
      (v) -> { User3D.create_Volume = v; },
      0, 1000000000, 0.001,
      0, 0, 0);

    // User3D.create_Snap = this.Spinner(..., "3D-create.Snap", 0, 1, 1);  [line 430]
    putSpinnerAction("3_d_create_snap",
      () -> (float) User3D.create_Snap,
      (v) -> { User3D.create_Snap = int(v); },
      0, 1, 1,
      0, 0, 0);

    // User3D.create_SphereDegree = this.Spinner(..., "3D-create.SphereDegree", 0, 5, 1);  [line 432]
    putSpinnerAction("3_d_create_sphere_degree",
      () -> (float) User3D.create_SphereDegree,
      (v) -> { User3D.create_SphereDegree = int(v); },
      0, 5, 1,
      0, 0, 0);

    // User3D.create_CylinderDegree = this.Spinner(..., "3D-create.CylinderDegree", 3, 36, 1);  [line 434]
    putSpinnerAction("3_d_create_cylinder_degree",
      () -> (float) User3D.create_CylinderDegree,
      (v) -> { User3D.create_CylinderDegree = int(v); },
      3, 36, 1,
      0, 0, 0);

    // User3D.create_PolyDegree = this.Spinner(..., "3D-create.PolyDegree", 3, 36, 1);  [line 436]
    putSpinnerAction("3_d_create_poly_degree",
      () -> (float) User3D.create_PolyDegree,
      (v) -> { User3D.create_PolyDegree = int(v); },
      3, 36, 1,
      0, 0, 0);

    // User3D.create_Parametric_Type = this.Spinner(..., "3D-create.Parametric_Type", 1, 6, 1);  [line 438]
    putSpinnerAction("3_d_create_parametric_type",
      () -> (float) User3D.create_Parametric_Type,
      (v) -> { User3D.create_Parametric_Type = int(v); },
      1, 6, 1,
      0, 0, 0);

    // User3D.create_Person_Type = this.Spinner(..., "3D-create.Person_Type", 0, allModel2Ds.num_files_PEOPLE, 1);  [line 439]
    putSpinnerAction("3_d_create_person_type",
      () -> (float) User3D.create_Person_Type,
      (v) -> { User3D.create_Person_Type = int(v); },
      () -> (float) (0), () -> (float) (allModel2Ds.num_files_PEOPLE), 1,
      0, 0, 0);

    // User3D.create_Plant_Type = this.Spinner(..., "3D-create.Plant_Type", 0, allModel2Ds.num_files_TREES, 1);  [line 440]
    putSpinnerAction("3_d_create_plant_type",
      () -> (float) User3D.create_Plant_Type,
      (v) -> { User3D.create_Plant_Type = int(v); },
      () -> (float) (0), () -> (float) (allModel2Ds.num_files_TREES), 1,
      0, 0, 0);

    // User3D.modify_OpenningDepth = this.Spinner(..., "3D-modify.OpenningDepth", -10, 10, 0.1);  [line 446]
    putSpinnerAction("3_d_modify_openning_depth",
      () -> User3D.modify_OpenningDepth,
      (v) -> { User3D.modify_OpenningDepth = v; },
      -10, 10, 0.1,
      0, 0, 0);

    // User3D.modify_OpenningArea = this.Spinner(..., "3D-modify.OpenningArea", 0, 1, 0.05);  [line 447]
    putSpinnerAction("3_d_modify_openning_area",
      () -> User3D.modify_OpenningArea,
      (v) -> { User3D.modify_OpenningArea = v; },
      0, 1, 0.05,
      0, 0, 0);

    // User3D.modify_OpenningDeviation = this.Spinner(..., "3D-modify.OpenningDeviation", 0, 1, 0.05);  [line 448]
    putSpinnerAction("3_d_modify_openning_deviation",
      () -> User3D.modify_OpenningDeviation,
      (v) -> { User3D.modify_OpenningDeviation = v; },
      0, 1, 0.05,
      0, 0, 0);

    // User3D.modify_TessellateRows = this.Spinner(..., "3D-modify.TessellateRows", 1, 100, 1);  [line 450]
    putSpinnerAction("3_d_modify_tessellate_rows",
      () -> (float) User3D.modify_TessellateRows,
      (v) -> { User3D.modify_TessellateRows = int(v); },
      1, 100, 1,
      0, 0, 0);

    // User3D.modify_TessellateColumns = this.Spinner(..., "3D-modify.TessellateColumns", 1, 100, 1);  [line 451]
    putSpinnerAction("3_d_modify_tessellate_columns",
      () -> (float) User3D.modify_TessellateColumns,
      (v) -> { User3D.modify_TessellateColumns = int(v); },
      1, 100, 1,
      0, 0, 0);

    // User3D.modify_OffsetAmount = this.Spinner(..., "3D-modify.OffsetAmount", 0, 25, 0.001);  [line 453]
    putSpinnerAction("3_d_modify_offset_amount",
      () -> User3D.modify_OffsetAmount,
      (v) -> { User3D.modify_OffsetAmount = v; },
      0, 25, 0.001,
      0, 0, 0);

    // User3D.modify_WeldTreshold = this.Spinner(..., "3D-modify.WeldTreshold", 0, 10, 0.001);  [line 455]
    putSpinnerAction("3_d_modify_weld_treshold",
      () -> User3D.modify_WeldTreshold,
      (v) -> { User3D.modify_WeldTreshold = v; },
      0, 10, 0.001,
      0, 0, 0);

    // Select3D.softPower = this.Spinner(..., "3D-select.softPower", 0.125, 8.0, -2);  [line 457]
    putSpinnerAction("3_d_select_soft_power",
      () -> Select3D.softPower,
      (v) -> { Select3D.softPower = v; },
      0.125, 8.0, 0.001,
      0, 0, 0,
      softSelectionChanged);

    // Select3D.softRadius = this.Spinner(..., "3D-select.softRadius", 0.01, 100, -2);  [line 458]
    putSpinnerAction("3_d_select_soft_radius",
      () -> Select3D.softRadius,
      (v) -> { Select3D.softRadius = v; },
      0.01, 100, 0.001,
      0, 0, 0,
      softSelectionChanged);

    // Select3D.posVector = this.Spinner(..., "3D-select.posVector", 0, 3, 1);  [line 460]
    putSpinnerAction("3_d_select_pos_vector",
      () -> (float) Select3D.posVector,
      (v) -> { Select3D.posVector = int(v); },
      0, 3, 1,
      0, 0, 0);

    // Select3D.rotVector = this.Spinner(..., "3D-select.rotVector", 0, 2, 1);  [line 461]
    putSpinnerAction("3_d_select_rot_vector",
      () -> (float) Select3D.rotVector,
      (v) -> { Select3D.rotVector = int(v); },
      0, 2, 1,
      0, 0, 0);

    // Select3D.scaleVector = this.Spinner(..., "3D-select.scaleVector", 0, 3, 1);  [line 462]
    putSpinnerAction("3_d_select_scale_vector",
      () -> (float) Select3D.scaleVector,
      (v) -> { Select3D.scaleVector = int(v); },
      0, 3, 1,
      0, 0, 0);

    // Select3D.posValue = this.Spinner(..., "3D-select.posValue", -50.0, 50.0, 1.0);  [line 464]
    putSpinnerAction("3_d_select_pos_value",
      () -> Select3D.posValue,
      (v) -> { Select3D.posValue = v; },
      -50.0, 50.0, 0.001,
      0, 0, 0,
      applyPosValue);

    // Select3D.rotValue = this.Spinner(..., "3D-select.rotValue", -180.0, 180.0, 1.0);  [line 465]
    putSpinnerAction("3_d_select_rot_value",
      () -> Select3D.rotValue,
      (v) -> { Select3D.rotValue = v; },
      -180.0, 180.0, 0.001,
      0, 0, 0,
      applyRotValue);

    // Select3D.scaleValue = this.Spinner(..., "3D-select.scaleValue", -8.0, 8.0, 1.0);  [line 466]
    putSpinnerAction("3_d_select_scale_value",
      () -> Select3D.scaleValue,
      (v) -> { Select3D.scaleValue = v; },
      -8.0, 8.0, 0.001,
      0, 0, 0,
      applyScaleValue);

    // Select3D.alignX = this.Spinner(..., "3D-select.alignX", -1, 1, 1);  [line 468]
    putSpinnerAction("3_d_select_align_x",
      () -> (float) Select3D.alignX,
      (v) -> { Select3D.alignX = int(v); },
      -1, 1, 1,
      0, 0, 0,
      selectionChangedOnly);

    // Select3D.alignY = this.Spinner(..., "3D-select.alignY", -1, 1, 1);  [line 469]
    putSpinnerAction("3_d_select_align_y",
      () -> (float) Select3D.alignY,
      (v) -> { Select3D.alignY = int(v); },
      -1, 1, 1,
      0, 0, 0,
      selectionChangedOnly);

    // Select3D.alignZ = this.Spinner(..., "3D-select.alignZ", -1, 1, 1);  [line 470]
    putSpinnerAction("3_d_select_align_z",
      () -> (float) Select3D.alignZ,
      (v) -> { Select3D.alignZ = int(v); },
      -1, 1, 1,
      0, 0, 0,
      selectionChangedOnly);

    // User3D.create_powAll = this.Spinner(..., "3D-create.powAll", 0.5, CubePower, -2);  [line 474]
    putSpinnerAction("3_d_create_pow_all",
      () -> User3D.create_powAll,
      (v) -> { User3D.create_powAll = v; },
      () -> (float) (0.5), () -> (float) (CubePower), 0.001,
      0, 0, 0,
      (o, n) -> {
        User3D.create_powX = User3D.create_powAll;
        User3D.create_powY = User3D.create_powAll;
        User3D.create_powZ = User3D.create_powAll;
        UI_rollout.revise();
      });

    // User3D.create_powX = this.Spinner(..., "3D-create.powX", 0.5, CubePower, -2);  [line 475]
    putSpinnerAction("3_d_create_pow_x",
      () -> User3D.create_powX,
      (v) -> { User3D.create_powX = v; },
      () -> (float) (0.5), () -> (float) (CubePower), 0.001,
      0, 0, 0);

    // User3D.create_powY = this.Spinner(..., "3D-create.powY", 0.5, CubePower, -2);  [line 476]
    putSpinnerAction("3_d_create_pow_y",
      () -> User3D.create_powY,
      (v) -> { User3D.create_powY = v; },
      () -> (float) (0.5), () -> (float) (CubePower), 0.001,
      0, 0, 0);

    // User3D.create_powZ = this.Spinner(..., "3D-create.powZ", 0.5, CubePower, -2);  [line 477]
    putSpinnerAction("3_d_create_pow_z",
      () -> User3D.create_powZ,
      (v) -> { User3D.create_powZ = v; },
      () -> (float) (0.5), () -> (float) (CubePower), 0.001,
      0, 0, 0);

    // User3D.create_Model1D_Type = this.Spinner(..., "3D-create.Type", 0, 0, 1);  [line 483]
    putSpinnerAction("3_d_create_type",
      () -> (float) User3D.create_Model1D_Type,
      (v) -> { User3D.create_Model1D_Type = int(v); },
      0, 0, 1,
      0, 0, 0);

    // User3D.create_Model1D_DegreeMax = this.Spinner(..., "3D-create.DegreeMax", 0, 12, 1);  [line 484]
    putSpinnerAction("3_d_create_degree_max",
      () -> (float) User3D.create_Model1D_DegreeMax,
      (v) -> { User3D.create_Model1D_DegreeMax = int(v); },
      0, 12, 1,
      0, 0, 0);

    // User3D.create_Model1D_Seed = this.Spinner(..., "3D-create.Seed", -1, 32767, 1);  [line 485]
    putSpinnerAction("3_d_create_seed",
      () -> (float) User3D.create_Model1D_Seed,
      (v) -> { User3D.create_Model1D_Seed = int(v); },
      -1, 32767, 1,
      0, 0, 0);

    // User3D.create_Model1D_TrunkSize = this.Spinner(..., "3D-create.TrunkSize", 0, 10, 0.1);  [line 486]
    putSpinnerAction("3_d_create_trunk_size",
      () -> User3D.create_Model1D_TrunkSize,
      (v) -> { User3D.create_Model1D_TrunkSize = v; },
      0, 10, 0.1,
      0, 0, 0);

    // User3D.create_Model1D_LeafSize = this.Spinner(..., "3D-create.LeafSize", 0, 1, 0.01);  [line 487]
    putSpinnerAction("3_d_create_leaf_size",
      () -> User3D.create_Model1D_LeafSize,
      (v) -> { User3D.create_Model1D_LeafSize = v; },
      0, 1, 0.1,
      0, 0, 0);

    // User3D.create_Model1D_BranchTilt = this.Spinner(..., "3D-create.BranchTilt", 0, 360, 5);  [line 489]
    putSpinnerAction("3_d_create_branch_tilt",
      () -> User3D.create_Model1D_BranchTilt,
      (v) -> { User3D.create_Model1D_BranchTilt = v; },
      0, 360, 0.1,
      0, 0, 0);

    // User3D.create_Model1D_BranchTwist = this.Spinner(..., "3D-create.BranchTwist", 0, 360, 5);  [line 490]
    putSpinnerAction("3_d_create_branch_twist",
      () -> User3D.create_Model1D_BranchTwist,
      (v) -> { User3D.create_Model1D_BranchTwist = v; },
      0, 360, 0.1,
      0, 0, 0);

    // User3D.create_Model1D_BranchRatio = this.Spinner(..., "3D-create.BranchRatio", 0.05, 1, 0.05);  [line 491]
    putSpinnerAction("3_d_create_branch_ratio",
      () -> User3D.create_Model1D_BranchRatio,
      (v) -> { User3D.create_Model1D_BranchRatio = v; },
      0.05, 1, 0.01,
      0, 0, 0);

    // User3D.create_Model1D_TreeBase = this.Spinner(..., "3D-create.TreeBase", 0, 4, 0.1);  [line 492]
    putSpinnerAction("3_d_create_tree_base",
      () -> User3D.create_Model1D_TreeBase,
      (v) -> { User3D.create_Model1D_TreeBase = v; },
      0, 4, 0.01,
      0, 0, 0);

    // Land3D.loadTextures = this.Spinner(..., "Land3D.loadTextures");  [line 497]
    putSpinnerAction("land3_d_load_textures",
      () -> (Land3D.loadTextures ? 1f : 0f),
      (v) -> { Land3D.loadTextures = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0,
      (o, n) -> {
        Land3D.update_textures();
        model_changed();
      });

    // Land3D.loadMesh = this.Spinner(..., "Land3D.loadMesh");  [line 498]
    putSpinnerAction("land3_d_load_mesh",
      () -> (Land3D.loadMesh ? 1f : 0f),
      (v) -> { Land3D.loadMesh = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0,
      (o, n) -> {
        Land3D.update_mesh();
        model_changed();
      });

    // Land3D.skipStart = this.Spinner(..., "Land3D.skipStart", 0, Land3D.num_rows - 1, 1);  [line 499]
    putSpinnerAction("land3_d_skip_start",
      () -> (float) Land3D.skipStart,
      (v) -> { Land3D.skipStart = int(v); },
      () -> (float) (0), () -> (float) (Land3D.num_rows - 1), 1,
      0, 1, 0);

    // Land3D.skipEnd = this.Spinner(..., "Land3D.skipEnd", 0, Land3D.num_rows - 1, 1);  [line 500]
    putSpinnerAction("land3_d_skip_end",
      () -> (float) Land3D.skipEnd,
      (v) -> { Land3D.skipEnd = int(v); },
      () -> (float) (0), () -> (float) (Land3D.num_rows - 1), 1,
      0, 1, 0);

    // Land3D.displaySurface = this.Spinner(..., "Land3D.displaySurface");  [line 501]
    putSpinnerAction("land3_d_display_surface",
      () -> (Land3D.displaySurface ? 1f : 0f),
      (v) -> { Land3D.displaySurface = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // Land3D.displayTexture = this.Spinner(..., "Land3D.displayTexture");  [line 502]
    putSpinnerAction("land3_d_display_texture",
      () -> (Land3D.displayTexture ? 1f : 0f),
      (v) -> { Land3D.displayTexture = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // Land3D.displayPoints = this.Spinner(..., "Land3D.displayPoints");  [line 503]
    putSpinnerAction("land3_d_display_points",
      () -> (Land3D.displayPoints ? 1f : 0f),
      (v) -> { Land3D.displayPoints = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // Land3D.displayDepth = this.Spinner(..., "Land3D.displayDepth");  [line 504]
    putSpinnerAction("land3_d_display_depth",
      () -> (Land3D.displayDepth ? 1f : 0f),
      (v) -> { Land3D.displayDepth = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // allModel2Ds.displayAll = this.Spinner(..., "model2Ds.displayAll");  [line 506]
    putSpinnerAction("model2_ds_display_all",
      () -> (allModel2Ds.displayAll ? 1f : 0f),
      (v) -> { allModel2Ds.displayAll = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // allModel1Ds.displayAll = this.Spinner(..., "model1Ds.displayAll");  [line 507]
    putSpinnerAction("model1_ds_display_all",
      () -> (allModel1Ds.displayAll ? 1f : 0f),
      (v) -> { allModel1Ds.displayAll = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // allModel1Ds.displayLeaves = this.Spinner(..., "model1Ds.displayLeaves");  [line 508]
    putSpinnerAction("model1_ds_display_leaves",
      () -> (allModel1Ds.displayLeaves ? 1f : 0f),
      (v) -> { allModel1Ds.displayLeaves = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // allPolylines.displayAll = this.Spinner(..., "polylines.displayAll");  [line 509]
    putSpinnerAction("polylines_display_all",
      () -> (allPolylines.displayAll ? 1f : 0f),
      (v) -> { allPolylines.displayAll = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // allFaces.displayAll = this.Spinner(..., "faces.displayAll");  [line 510]
    putSpinnerAction("faces_display_all",
      () -> (allFaces.displayAll ? 1f : 0f),
      (v) -> { allFaces.displayAll = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // allSolids.displayAll = this.Spinner(..., "solids.displayAll");  [line 512]
    putSpinnerAction("solids_display_all",
      () -> (allSolids.displayAll ? 1f : 0f),
      (v) -> { allSolids.displayAll = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // allSections.displayAll = this.Spinner(..., "sections.displayAll");  [line 514]
    putSpinnerAction("sections_display_all",
      () -> (allSections.displayAll ? 1f : 0f),
      (v) -> { allSections.displayAll = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // allWindRoses.displayImage = this.Spinner(..., "windRoses.displayImage");  [line 519]
    putSpinnerAction("wind_roses_display_image",
      () -> (allWindRoses.displayImage ? 1f : 0f),
      (v) -> { allWindRoses.displayImage = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // allWindRoses.scale = this.Spinner(..., "windRoses.scale", 50, 3200, -2);  [line 521]
    putSpinnerAction("wind_roses_scale",
      () -> allWindRoses.scale,
      (v) -> { allWindRoses.scale = v; },
      50, 3200, 0.001,
      0, 1, 0);

    // Sky3D.displaySurface = this.Spinner(..., "Sky3D.displaySurface");  [line 526]
    putSpinnerAction("sky3_d_display_surface",
      () -> (Sky3D.displaySurface ? 1f : 0f),
      (v) -> { Sky3D.displaySurface = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // Sun3D.displayPath = this.Spinner(..., "Sun3D.displayPath");  [line 528]
    putSpinnerAction("sun3_d_display_path",
      () -> (Sun3D.displayPath ? 1f : 0f),
      (v) -> { Sun3D.displayPath = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // Sun3D.displayPattern = this.Spinner(..., "Sun3D.displayPattern");  [line 529]
    putSpinnerAction("sun3_d_display_pattern",
      () -> (Sun3D.displayPattern ? 1f : 0f),
      (v) -> { Sun3D.displayPattern = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // WIN3D.currentCamera = this.Spinner(..., "currentCamera", 0, allCameras.num, 1);  [line 535]
    putSpinnerAction("current_camera",
      () -> (float) WIN3D.currentCamera,
      (v) -> { WIN3D.currentCamera = int(v); },
      () -> (float) (0), () -> (float) (allCameras.num), 1,
      0, 1, 0,
      (o, n) -> {
        WIN3D.apply_currentCamera();
        modify_Viewport_Title();
        view_changed();
      });

    // WIN3D.CAM_clipNear = this.Spinner(..., "Camera_clipNear", 0.01, 100, -2);  [line 537]
    putSpinnerAction("camera_clip_near",
      () -> WIN3D.CAM_clipNear,
      (v) -> { WIN3D.CAM_clipNear = v; },
      0.01, 100, 0.001,
      0, 1, 0);

    // WIN3D.CAM_clipFar = this.Spinner(..., "Camera_clipFar", 1000, 2000000000, -2);  [line 538]
    putSpinnerAction("camera_clip_far",
      () -> WIN3D.CAM_clipFar,
      (v) -> { WIN3D.CAM_clipFar = v; },
      1000, 2000000000, 0.001,
      0, 1, 0);

    // allPoints.displayAll = this.Spinner(..., "Create3D.displayVertices");  [line 541]
    putSpinnerAction("create3_d_display_vertices",
      () -> (allPoints.displayAll ? 1f : 0f),
      (v) -> { allPoints.displayAll = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0,
      viewChangedOnly);

    // allFaces.displayEdges = this.Spinner(..., "Create3D.displayEdges");  [line 542]
    putSpinnerAction("create3_d_display_edges",
      () -> (allFaces.displayEdges ? 1f : 0f),
      (v) -> { allFaces.displayEdges = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0,
      viewChangedOnly);

    // allFaces.displayNormals = this.Spinner(..., "Create3D.displayNormals");  [line 543]
    putSpinnerAction("create3_d_display_normals",
      () -> (allFaces.displayNormals ? 1f : 0f),
      (v) -> { allFaces.displayNormals = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0,
      viewChangedOnly);

    // allCameras.displayAll = this.Spinner(..., "cameras.displayAll");  [line 545]
    putSpinnerAction("cameras_display_all",
      () -> (allCameras.displayAll ? 1f : 0f),
      (v) -> { allCameras.displayAll = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // IMPACTS_displayDay = this.Spinner(..., "IMPACTS_displayDay", 0, STUDY.j_End - STUDY.j_Start, 1);  [line 551]
    putSpinnerAction("impacts_display_day",
      () -> (float) IMPACTS_displayDay,
      (v) -> { IMPACTS_displayDay = int(v); },
      () -> (float) (0), () -> (float) (STUDY.j_End - STUDY.j_Start), 1,
      0, 1, 0,
      caseBarOnly);

    // allSolarImpacts.displayImage = this.Spinner(..., "solarImpacts.displayImage");  [line 553]
    putSpinnerAction("solar_impacts_display_image",
      () -> (allSolarImpacts.displayImage ? 1f : 0f),
      (v) -> { allSolarImpacts.displayImage = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // allSolidImpacts.displayImage = this.Spinner(..., "solidImpacts.displayImage");  [line 554]
    putSpinnerAction("solid_impacts_display_image",
      () -> (allSolidImpacts.displayImage ? 1f : 0f),
      (v) -> { allSolidImpacts.displayImage = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // allSolarImpacts.sectionType = this.Spinner(..., "solarImpacts.sectionType", 0, 3, 1);  [line 556]
    putSpinnerAction("solar_impacts_section_type",
      () -> (float) allSolarImpacts.sectionType,
      (v) -> { allSolarImpacts.sectionType = int(v); },
      0, 3, 1,
      0, 1, 0);

    // allSolidImpacts.sectionType = this.Spinner(..., "solidImpacts.sectionType", 0, 3, 1);  [line 557]
    putSpinnerAction("solid_impacts_section_type",
      () -> (float) allSolidImpacts.sectionType,
      (v) -> { allSolidImpacts.sectionType = int(v); },
      0, 3, 1,
      0, 1, 0);

    // allSolidImpacts.Grade = this.Spinner(..., "solidImpacts.Grade", 0.0001, 64.0, -2);  [line 560]
    putSpinnerAction("solid_impacts_grade",
      () -> allSolidImpacts.Grade,
      (v) -> { allSolidImpacts.Grade = v; },
      0.0001, 64.0, 0.001,
      0, 1, 0,
      recalcImpact);

    // allSolidImpacts.Power = this.Spinner(..., "solidImpacts.Power", 0.0001, 64.0, -2);  [line 561]
    putSpinnerAction("solid_impacts_power",
      () -> allSolidImpacts.Power,
      (v) -> { allSolidImpacts.Power = v; },
      0.0001, 64.0, 0.001,
      0, 1, 0,
      recalcImpact);

    // allSolidImpacts.R[allSolidImpacts.sectionType] = this.Spinner(..., "solidImpacts.R[" + sectionType + "]", -360, 360, -2);  [line 562]
    putSpinnerAction("solid_impacts_r",
      () -> allSolidImpacts.R[allSolidImpacts.sectionType],
      (v) -> { allSolidImpacts.R[allSolidImpacts.sectionType] = v; },
      -360, 360, 0.001,
      0, 1, 0,
      recalcImpact);

    // allSolidImpacts.Z[allSolidImpacts.sectionType] = this.Spinner(..., "solidImpacts.Z[" + sectionType + "]", -1000, 1000, -2);  [line 563]
    putSpinnerAction("solid_impacts_z",
      () -> allSolidImpacts.Z[allSolidImpacts.sectionType],
      (v) -> { allSolidImpacts.Z[allSolidImpacts.sectionType] = v; },
      -1000, 1000, 0.001,
      0, 1, 0,
      recalcImpact);

    // allSolidImpacts.positionStep = this.Spinner(..., "solidImpacts.positionStep", 5, 80, -2);  [line 564]
    putSpinnerAction("solid_impacts_position_step",
      () -> allSolidImpacts.positionStep,
      (v) -> { allSolidImpacts.positionStep = v; },
      5, 80, 0.001,
      0, 1, 0);

    // allSolidImpacts.U[allSolidImpacts.sectionType] = this.Spinner(..., "solidImpacts.U[" + sectionType + "]", 0.125, 3200, -2);  [line 566]
    putSpinnerAction("solid_impacts_u",
      () -> allSolidImpacts.U[allSolidImpacts.sectionType],
      (v) -> { allSolidImpacts.U[allSolidImpacts.sectionType] = v; },
      0.125, 3200, 0.001,
      0, 1, 0);

    // allSolidImpacts.V[allSolidImpacts.sectionType] = this.Spinner(..., "solidImpacts.V[" + sectionType + "]", 0.125, 3200, -2);  [line 567]
    putSpinnerAction("solid_impacts_v",
      () -> allSolidImpacts.V[allSolidImpacts.sectionType],
      (v) -> { allSolidImpacts.V[allSolidImpacts.sectionType] = v; },
      0.125, 3200, 0.001,
      0, 1, 0);

    // allSolidImpacts.X[allSolidImpacts.sectionType] = this.Spinner(..., "solidImpacts.X[" + sectionType + "]", -10000, 10000, -2);  [line 568]
    putSpinnerAction("solid_impacts_x",
      () -> allSolidImpacts.X[allSolidImpacts.sectionType],
      (v) -> { allSolidImpacts.X[allSolidImpacts.sectionType] = v; },
      -10000, 10000, 0.001,
      0, 1, 0);

    // allSolidImpacts.Y[allSolidImpacts.sectionType] = this.Spinner(..., "solidImpacts.Y[" + sectionType + "]", -10000, 10000, -2);  [line 569]
    putSpinnerAction("solid_impacts_y",
      () -> allSolidImpacts.Y[allSolidImpacts.sectionType],
      (v) -> { allSolidImpacts.Y[allSolidImpacts.sectionType] = v; },
      -10000, 10000, 0.001,
      0, 1, 0);

    // allSolidImpacts.WindSpeed = this.Spinner(..., "solidImpacts.WindSpeed (m/s)", 1, 16, -2);  [line 572]
    putSpinnerAction("solid_impacts_wind_speed_m_s",
      () -> allSolidImpacts.WindSpeed,
      (v) -> { allSolidImpacts.WindSpeed = v; },
      1, 16, 0.001,
      0, 1, 0,
      recalcImpact);

    // allSolidImpacts.WindDirection = this.Spinner(..., "solidImpacts.WindDirection", 0, 360, 15);  [line 573]
    putSpinnerAction("solid_impacts_wind_direction",
      () -> allSolidImpacts.WindDirection,
      (v) -> { allSolidImpacts.WindDirection = v; },
      0, 360, 15,
      0, 1, 0,
      recalcImpact);

    // allSolidImpacts.Process_subDivisions = this.Spinner(..., "solidImpacts.Process_subDivisions", 0, 3, 1);  [line 576]
    putSpinnerAction("solid_impacts_process_sub_divisions",
      () -> (float) allSolidImpacts.Process_subDivisions,
      (v) -> { allSolidImpacts.Process_subDivisions = int(v); },
      0, 3, 1,
      0, 0, 0,
      recalcImpact);

    // allSolidImpacts.displayPoints = this.Spinner(..., "solidImpacts.displayPoints");  [line 578]
    putSpinnerAction("solid_impacts_display_points",
      () -> (allSolidImpacts.displayPoints ? 1f : 0f),
      (v) -> { allSolidImpacts.displayPoints = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0,
      viewChangedOnly);

    // allSolidImpacts.displayLines = this.Spinner(..., "solidImpacts.displayLines");  [line 579]
    putSpinnerAction("solid_impacts_display_lines",
      () -> (allSolidImpacts.displayLines ? 1f : 0f),
      (v) -> { allSolidImpacts.displayLines = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0,
      viewChangedOnly);

    // allWindFlows.displayAll = this.Spinner(..., "windFlows.displayAll");  [line 581]
    putSpinnerAction("wind_flows_display_all",
      () -> (allWindFlows.displayAll ? 1f : 0f),
      (v) -> { allWindFlows.displayAll = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0,
      viewChangedOnly);

    // allFaces.displayTessellation = this.Spinner(..., "3D-create.displayTessellation", 0, 4, 1);  [line 586]
    putSpinnerAction("3_d_create_display_tessellation",
      () -> (float) allFaces.displayTessellation,
      (v) -> { allFaces.displayTessellation = int(v); },
      0, 4, 1,
      0, 1, 0,
      viewChangedOnly);

    // Land3D.displayTessellation = this.Spinner(..., "Land.displayTessellation", 0, 4, 1);  [line 588]
    putSpinnerAction("land_display_tessellation",
      () -> (float) Land3D.displayTessellation,
      (v) -> { Land3D.displayTessellation = int(v); },
      0, 4, 1,
      0, 1, 0);

    // Sky3D.displayTessellation = this.Spinner(..., "Sky.displayTessellation", 0, 4, 1);  [line 590]
    putSpinnerAction("sky_display_tessellation",
      () -> (float) Sky3D.displayTessellation,
      (v) -> { Sky3D.displayTessellation = int(v); },
      0, 4, 1,
      0, 1, 0);

    // Sky3D.radius = this.Spinner(..., "Sky.scale", 1, 4000000, -2);  [line 591]
    putSpinnerAction("sky_scale",
      () -> Sky3D.radius,
      (v) -> { Sky3D.radius = v; },
      1, 4000000, 0.001,
      0, 1, 0);

    // Tropo3D.displaySurface = this.Spinner(..., "Tropo3D.displaySurface");  [line 593]
    putSpinnerAction("tropo3_d_display_surface",
      () -> (Tropo3D.displaySurface ? 1f : 0f),
      (v) -> { Tropo3D.displaySurface = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // Tropo3D.displayTexture = this.Spinner(..., "Tropo3D.displayTexture");  [line 594]
    putSpinnerAction("tropo3_d_display_texture",
      () -> (Tropo3D.displayTexture ? 1f : 0f),
      (v) -> { Tropo3D.displayTexture = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // Earth3D.displaySurface = this.Spinner(..., "Earth3D.displaySurface");  [line 596]
    putSpinnerAction("earth3_d_display_surface",
      () -> (Earth3D.displaySurface ? 1f : 0f),
      (v) -> { Earth3D.displaySurface = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // Earth3D.displayTexture = this.Spinner(..., "Earth3D.displayTexture");  [line 597]
    putSpinnerAction("earth3_d_display_texture",
      () -> (Earth3D.displayTexture ? 1f : 0f),
      (v) -> { Earth3D.displayTexture = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // Earth3D.levelOfDetail = this.Spinner(..., "Earth3D.levelOfDetail", 1.0 / 16.0, 16.0, -2);  [line 598]
    putSpinnerAction("earth3_d_level_of_detail",
      () -> Earth3D.levelOfDetail,
      (v) -> { Earth3D.levelOfDetail = v; },
      1.0 / 16.0, 16.0, 0.001,
      0, 1, 0);

    // Moon3D.displaySurface = this.Spinner(..., "Moon3D.displaySurface");  [line 601]
    putSpinnerAction("moon3_d_display_surface",
      () -> (Moon3D.displaySurface ? 1f : 0f),
      (v) -> { Moon3D.displaySurface = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // Moon3D.displayTexture = this.Spinner(..., "Moon3D.displayTexture");  [line 602]
    putSpinnerAction("moon3_d_display_texture",
      () -> (Moon3D.displayTexture ? 1f : 0f),
      (v) -> { Moon3D.displayTexture = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // Moon3D.fitInSkyDome = this.Spinner(..., "Moon3D.fitInSkyDome");  [line 603]
    putSpinnerAction("moon3_d_fit_in_sky_dome",
      () -> (Moon3D.fitInSkyDome ? 1f : 0f),
      (v) -> { Moon3D.fitInSkyDome = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // Sun3D.displaySurface = this.Spinner(..., "Sun3D.displaySurface");  [line 605]
    putSpinnerAction("sun3_d_display_surface",
      () -> (Sun3D.displaySurface ? 1f : 0f),
      (v) -> { Sun3D.displaySurface = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // Sun3D.displayTexture = this.Spinner(..., "Sun3D.displayTexture");  [line 606]
    putSpinnerAction("sun3_d_display_texture",
      () -> (Sun3D.displayTexture ? 1f : 0f),
      (v) -> { Sun3D.displayTexture = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // Sun3D.fitInSkyDome = this.Spinner(..., "Sun3D.fitInSkyDome");  [line 607]
    putSpinnerAction("sun3_d_fit_in_sky_dome",
      () -> (Sun3D.fitInSkyDome ? 1f : 0f),
      (v) -> { Sun3D.fitInSkyDome = (v >= 0.5f); },
      0, 1, 1,
      0, 1, 0);

    // Planetary_Magnification = this.Spinner(..., "Planetary_Magnification", 1, 64, -2);  [line 609]
    putSpinnerAction("planetary_magnification",
      () -> Planetary_Magnification,
      (v) -> { Planetary_Magnification = v; },
      1, 64, 2,
      0, 1, 0);

    // OBJECTS_scale = this.Spinner(..., "Objects_scale", 0.0000001, 1000000, -2);  [line 611]
    putSpinnerAction("objects_scale",
      () -> OBJECTS_scale,
      (v) -> { OBJECTS_scale = v; },
      0.0000001, 1000000, 0.000001,
      0, 1, 0);

    // STUDY.plotSetup = this.Spinner(..., "Diagram setup", -2, 8, 1);  [line 617]
    putSpinnerAction("diagram_setup",
      () -> (float) STUDY.plotSetup,
      (v) -> { STUDY.plotSetup = int(v); },
      -2, 8, 1,
      1, 0, 0,
      impactsUpdateFlag);

    // STUDY.V_scale = this.Spinner(..., "Scale (x)", 0.0001, 10000, -pow(2.0, 1.0 / 2.0));  [line 619]
    putSpinnerAction("scale",
      () -> STUDY.V_scale,
      (v) -> { STUDY.V_scale = v; },
      0.0001, 10000, Math.abs(-pow(2.0, (1.0 / 2.0))),
      1, 0, 0);

    // STUDY.displayRaws = this.Spinner(..., "Draw data");  [line 621]
    putSpinnerAction("draw_data",
      () -> (STUDY.displayRaws ? 1f : 0f),
      (v) -> { STUDY.displayRaws = (v >= 0.5f); },
      0, 1, 1,
      1, 0, 0);

    // STUDY.displaySorted = this.Spinner(..., "Draw sorted");  [line 622]
    putSpinnerAction("draw_sorted",
      () -> (STUDY.displaySorted ? 1f : 0f),
      (v) -> { STUDY.displaySorted = (v >= 0.5f); },
      0, 1, 1,
      1, 0, 0);

    // STUDY.displayNormals = this.Spinner(..., "Draw statistics");  [line 623]
    putSpinnerAction("draw_statistics",
      () -> (STUDY.displayNormals ? 1f : 0f),
      (v) -> { STUDY.displayNormals = (v >= 0.5f); },
      0, 1, 1,
      1, 0, 0);

    // STUDY.displayProbs = this.Spinner(..., "Draw probabilities");  [line 624]
    putSpinnerAction("draw_probabilities",
      () -> (STUDY.displayProbs ? 1f : 0f),
      (v) -> { STUDY.displayProbs = (v >= 0.5f); },
      0, 1, 1,
      1, 0, 0);

    // STUDY.sumInterval = this.Spinner(..., "Probabilities interval", 1, 24, 1);  [line 625]
    putSpinnerAction("probabilities_interval",
      () -> (float) STUDY.sumInterval,
      (v) -> { STUDY.sumInterval = int(v); },
      1, 24, 1,
      1, 0, 0);

    // STUDY.LevelPix = this.Spinner(..., "Probabilities range", 2, 32, -2);  [line 626]
    putSpinnerAction("probabilities_range",
      () -> STUDY.LevelPix,
      (v) -> { STUDY.LevelPix = v; },
      2, 32, 1,
      1, 0, 0);

    // STUDY.ACTIVE_palette_CLR = this.Spinner(..., "STUDY.ACTIVE_palette_CLR", -1, (COLOR_STYLE_Number - 1), 1);  [line 631]
    putSpinnerAction("study_active_palette_clr",
      () -> (float) STUDY.ACTIVE_palette_CLR,
      (v) -> { STUDY.ACTIVE_palette_CLR = int(v); },
      () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
      1, 0, 0);

    // STUDY.ACTIVE_palette_DIR = this.Spinner(..., "STUDY.ACTIVE_palette_DIR", -2, 2, 1);  [line 632]
    putSpinnerAction("study_active_palette_dir",
      () -> (float) STUDY.ACTIVE_palette_DIR,
      (v) -> { STUDY.ACTIVE_palette_DIR = int(v); },
      -2, 2, 1,
      1, 0, 0);

    // STUDY.ACTIVE_palette_MLT = this.Spinner(..., "STUDY.ACTIVE_palette_MLT", 0.125, 8, -2);  [line 633]
    putSpinnerAction("study_active_palette_mlt",
      () -> STUDY.ACTIVE_palette_MLT,
      (v) -> { STUDY.ACTIVE_palette_MLT = v; },
      0.125, 8, 0.001,
      1, 0, 0);

    // STUDY.PASSIVE_palette_CLR = this.Spinner(..., "STUDY.PASSIVE_palette_CLR", -1, (COLOR_STYLE_Number - 1), 1);  [line 635]
    putSpinnerAction("study_passive_palette_clr",
      () -> (float) STUDY.PASSIVE_palette_CLR,
      (v) -> { STUDY.PASSIVE_palette_CLR = int(v); },
      () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
      1, 0, 0);

    // STUDY.PASSIVE_palette_DIR = this.Spinner(..., "STUDY.PASSIVE_palette_DIR", -2, 2, 2);  [line 636]
    putSpinnerAction("study_passive_palette_dir",
      () -> (float) STUDY.PASSIVE_palette_DIR,
      (v) -> { STUDY.PASSIVE_palette_DIR = int(v); },
      -2, 2, 1,
      1, 0, 0);

    // STUDY.PASSIVE_palette_MLT = this.Spinner(..., "STUDY.PASSIVE_palette_MLT", 0.125, 8, -2);  [line 637]
    putSpinnerAction("study_passive_palette_mlt",
      () -> STUDY.PASSIVE_palette_MLT,
      (v) -> { STUDY.PASSIVE_palette_MLT = v; },
      0.125, 8, 0.001,
      1, 0, 0);

    // STUDY.SORT_palette_CLR = this.Spinner(..., "STUDY.SORT_palette_CLR", -1, (COLOR_STYLE_Number - 1), 1);  [line 639]
    putSpinnerAction("study_sort_palette_clr",
      () -> (float) STUDY.SORT_palette_CLR,
      (v) -> { STUDY.SORT_palette_CLR = int(v); },
      () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
      1, 0, 0);

    // STUDY.SORT_palette_DIR = this.Spinner(..., "STUDY.SORT_palette_DIR", -2, 2, 2);  [line 640]
    putSpinnerAction("study_sort_palette_dir",
      () -> (float) STUDY.SORT_palette_DIR,
      (v) -> { STUDY.SORT_palette_DIR = int(v); },
      -2, 2, 1,
      1, 0, 0);

    // STUDY.SORT_palette_MLT = this.Spinner(..., "STUDY.SORT_palette_MLT", 0.125, 8, -2);  [line 641]
    putSpinnerAction("study_sort_palette_mlt",
      () -> STUDY.SORT_palette_MLT,
      (v) -> { STUDY.SORT_palette_MLT = v; },
      0.125, 8, 0.001,
      1, 0, 0);

    // STUDY.PROB_palette_CLR = this.Spinner(..., "STUDY.PROB_palette_CLR", -1, (COLOR_STYLE_Number - 1), 1);  [line 643]
    putSpinnerAction("study_prob_palette_clr",
      () -> (float) STUDY.PROB_palette_CLR,
      (v) -> { STUDY.PROB_palette_CLR = int(v); },
      () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
      1, 0, 0);

    // STUDY.PROB_palette_DIR = this.Spinner(..., "STUDY.PROB_palette_DIR", -2, 2, 2);  [line 644]
    putSpinnerAction("study_prob_palette_dir",
      () -> (float) STUDY.PROB_palette_DIR,
      (v) -> { STUDY.PROB_palette_DIR = int(v); },
      -2, 2, 1,
      1, 0, 0);

    // STUDY.PROB_palette_MLT = this.Spinner(..., "STUDY.PROB_palette_MLT", 0.125, 8, -2);  [line 645]
    putSpinnerAction("study_prob_palette_mlt",
      () -> STUDY.PROB_palette_MLT,
      (v) -> { STUDY.PROB_palette_MLT = v; },
      0.125, 8, 0.001,
      1, 0, 0);

    // STUDY.O_scale = this.Spinner(..., "Windose opacity scale", 1, 100, -pow(2.0, (1.0 / 4.0)));  [line 647]
    putSpinnerAction("windose_opacity_scale",
      () -> STUDY.O_scale,
      (v) -> { STUDY.O_scale = v; },
      1, 100, Math.abs(-pow(2.0, (1.0 / 4.0))),
      1, 0, 0);

    // allFaces.ACTIVE_palette_CLR = this.Spinner(..., "faces.ACTIVE_palette_CLR", -1, (COLOR_STYLE_Number - 1), 1);  [line 652]
    putSpinnerAction("faces_active_palette_clr",
      () -> (float) allFaces.ACTIVE_palette_CLR,
      (v) -> { allFaces.ACTIVE_palette_CLR = int(v); },
      () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
      0, 1, 0);

    // allFaces.ACTIVE_palette_DIR = this.Spinner(..., "faces.ACTIVE_palette_DIR", -2, 2, 1);  [line 653]
    putSpinnerAction("faces_active_palette_dir",
      () -> (float) allFaces.ACTIVE_palette_DIR,
      (v) -> { allFaces.ACTIVE_palette_DIR = int(v); },
      -2, 2, 1,
      0, 1, 0);

    // allFaces.ACTIVE_palette_MLT = this.Spinner(..., "faces.ACTIVE_palette_MLT", 0.125, 8, -2);  [line 654]
    putSpinnerAction("faces_active_palette_mlt",
      () -> allFaces.ACTIVE_palette_MLT,
      (v) -> { allFaces.ACTIVE_palette_MLT = v; },
      0.125, 8, 0.001,
      0, 1, 0);

    // allFaces.PASSIVE_palette_CLR = this.Spinner(..., "faces.PASSIVE_palette_CLR", -1, (COLOR_STYLE_Number - 1), 1);  [line 656]
    putSpinnerAction("faces_passive_palette_clr",
      () -> (float) allFaces.PASSIVE_palette_CLR,
      (v) -> { allFaces.PASSIVE_palette_CLR = int(v); },
      () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
      0, 1, 0);

    // allFaces.PASSIVE_palette_DIR = this.Spinner(..., "faces.PASSIVE_palette_DIR", -2, 2, 2);  [line 657]
    putSpinnerAction("faces_passive_palette_dir",
      () -> (float) allFaces.PASSIVE_palette_DIR,
      (v) -> { allFaces.PASSIVE_palette_DIR = int(v); },
      -2, 2, 1,
      0, 1, 0);

    // allFaces.PASSIVE_palette_MLT = this.Spinner(..., "faces.PASSIVE_palette_MLT", 0.125, 8, -2);  [line 658]
    putSpinnerAction("faces_passive_palette_mlt",
      () -> allFaces.PASSIVE_palette_MLT,
      (v) -> { allFaces.PASSIVE_palette_MLT = v; },
      0.125, 8, 0.001,
      0, 1, 0);

    // Sky3D.ACTIVE_palette_CLR = this.Spinner(..., "Sky3D.ACTIVE_palette_CLR", -1, (COLOR_STYLE_Number - 1), 1);  [line 660]
    putSpinnerAction("sky3_d_active_palette_clr",
      () -> (float) Sky3D.ACTIVE_palette_CLR,
      (v) -> { Sky3D.ACTIVE_palette_CLR = int(v); },
      () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
      0, 1, 0);

    // Sky3D.ACTIVE_palette_DIR = this.Spinner(..., "Sky3D.ACTIVE_palette_DIR", -2, 2, 1);  [line 661]
    putSpinnerAction("sky3_d_active_palette_dir",
      () -> (float) Sky3D.ACTIVE_palette_DIR,
      (v) -> { Sky3D.ACTIVE_palette_DIR = int(v); },
      -2, 2, 1,
      0, 1, 0);

    // Sky3D.ACTIVE_palette_MLT = this.Spinner(..., "Sky3D.ACTIVE_palette_MLT", 0.125, 8, -2);  [line 662]
    putSpinnerAction("sky3_d_active_palette_mlt",
      () -> Sky3D.ACTIVE_palette_MLT,
      (v) -> { Sky3D.ACTIVE_palette_MLT = v; },
      0.125, 8, 0.001,
      0, 1, 0);

    // Sky3D.PASSIVE_palette_CLR = this.Spinner(..., "Sky3D.PASSIVE_palette_CLR", -1, (COLOR_STYLE_Number - 1), 1);  [line 664]
    putSpinnerAction("sky3_d_passive_palette_clr",
      () -> (float) Sky3D.PASSIVE_palette_CLR,
      (v) -> { Sky3D.PASSIVE_palette_CLR = int(v); },
      () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
      0, 1, 0);

    // Sky3D.PASSIVE_palette_DIR = this.Spinner(..., "Sky3D.PASSIVE_palette_DIR", -2, 2, 2);  [line 665]
    putSpinnerAction("sky3_d_passive_palette_dir",
      () -> (float) Sky3D.PASSIVE_palette_DIR,
      (v) -> { Sky3D.PASSIVE_palette_DIR = int(v); },
      -2, 2, 1,
      0, 1, 0);

    // Sky3D.PASSIVE_palette_MLT = this.Spinner(..., "Sky3D.PASSIVE_palette_MLT", 0.125, 8, -2);  [line 666]
    putSpinnerAction("sky3_d_passive_palette_mlt",
      () -> Sky3D.PASSIVE_palette_MLT,
      (v) -> { Sky3D.PASSIVE_palette_MLT = v; },
      0.125, 8, 0.001,
      0, 1, 0);

    // Sun3D.ACTIVE_palette_CLR = this.Spinner(..., "Sun3D.ACTIVE_palette_CLR", -1, (COLOR_STYLE_Number - 1), 1);  [line 668]
    putSpinnerAction("sun3_d_active_palette_clr",
      () -> (float) Sun3D.ACTIVE_palette_CLR,
      (v) -> { Sun3D.ACTIVE_palette_CLR = int(v); },
      () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
      0, 1, 0);

    // Sun3D.ACTIVE_palette_DIR = this.Spinner(..., "Sun3D.ACTIVE_palette_DIR", -2, 2, 1);  [line 669]
    putSpinnerAction("sun3_d_active_palette_dir",
      () -> (float) Sun3D.ACTIVE_palette_DIR,
      (v) -> { Sun3D.ACTIVE_palette_DIR = int(v); },
      -2, 2, 1,
      0, 1, 0);

    // Sun3D.ACTIVE_palette_MLT = this.Spinner(..., "Sun3D.ACTIVE_palette_MLT", 0.125, 8, -2);  [line 670]
    putSpinnerAction("sun3_d_active_palette_mlt",
      () -> Sun3D.ACTIVE_palette_MLT,
      (v) -> { Sun3D.ACTIVE_palette_MLT = v; },
      0.125, 8, 0.001,
      0, 1, 0);

    // Sun3D.PASSIVE_palette_CLR = this.Spinner(..., "Sun3D.PASSIVE_palette_CLR", -1, (COLOR_STYLE_Number - 1), 1);  [line 672]
    putSpinnerAction("sun3_d_passive_palette_clr",
      () -> (float) Sun3D.PASSIVE_palette_CLR,
      (v) -> { Sun3D.PASSIVE_palette_CLR = int(v); },
      () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
      0, 1, 0);

    // Sun3D.PASSIVE_palette_DIR = this.Spinner(..., "Sun3D.PASSIVE_palette_DIR", -2, 2, 2);  [line 673]
    putSpinnerAction("sun3_d_passive_palette_dir",
      () -> (float) Sun3D.PASSIVE_palette_DIR,
      (v) -> { Sun3D.PASSIVE_palette_DIR = int(v); },
      -2, 2, 1,
      0, 1, 0);

    // Sun3D.PASSIVE_palette_MLT = this.Spinner(..., "Sun3D.PASSIVE_palette_MLT", 0.125, 8, -2);  [line 674]
    putSpinnerAction("sun3_d_passive_palette_mlt",
      () -> Sun3D.PASSIVE_palette_MLT,
      (v) -> { Sun3D.PASSIVE_palette_MLT = v; },
      0.125, 8, 0.001,
      0, 1, 0);

    // allSolids.palette_CLR = this.Spinner(..., "solids.palette_CLR", -1, (COLOR_STYLE_Number - 1), 1);  [line 682]
    putSpinnerAction("solids_palette_clr",
      () -> (float) allSolids.palette_CLR,
      (v) -> { allSolids.palette_CLR = int(v); },
      () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
      0, 1, 0,
      recalcImpact);

    // allSolids.palette_DIR = this.Spinner(..., "solids.palette_DIR", -2, 2, 2);  [line 683]
    putSpinnerAction("solids_palette_dir",
      () -> (float) allSolids.palette_DIR,
      (v) -> { allSolids.palette_DIR = int(v); },
      -2, 2, 1,
      0, 1, 0,
      recalcImpact);

    // allSolids.palette_MLT = this.Spinner(..., "solids.palette_MLT", 0.0001, 64, -2);  [line 684]
    putSpinnerAction("solids_palette_mlt",
      () -> allSolids.palette_MLT,
      (v) -> { allSolids.palette_MLT = v; },
      0.0001, 64, 0.001,
      0, 1, 0,
      recalcImpact);

    // Land3D.palette_CLR = this.Spinner(..., "Land3D.palette_CLR", -1, (COLOR_STYLE_Number - 1), 1);  [line 686]
    putSpinnerAction("land3_d_palette_clr",
      () -> (float) Land3D.palette_CLR,
      (v) -> { Land3D.palette_CLR = int(v); },
      () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
      0, 1, 0);

    // Land3D.palette_DIR = this.Spinner(..., "Land3D.palette_DIR", -2, 2, 2);  [line 687]
    putSpinnerAction("land3_d_palette_dir",
      () -> (float) Land3D.palette_DIR,
      (v) -> { Land3D.palette_DIR = int(v); },
      -2, 2, 1,
      0, 1, 0);

    // Land3D.palette_MLT = this.Spinner(..., "Land3D.palette_MLT", 0.001, 0.5, -2);  [line 688]
    putSpinnerAction("land3_d_palette_mlt",
      () -> Land3D.palette_MLT,
      (v) -> { Land3D.palette_MLT = v; },
      0.001, 0.5, 0.001,
      0, 1, 0);

    // allWindFlows.palette_CLR = this.Spinner(..., "windFlows.palette_CLR", -1, (COLOR_STYLE_Number - 1), 1);  [line 690]
    putSpinnerAction("wind_flows_palette_clr",
      () -> (float) allWindFlows.palette_CLR,
      (v) -> { allWindFlows.palette_CLR = int(v); },
      () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
      0, 1, 0);

    // allWindFlows.palette_DIR = this.Spinner(..., "windFlows.palette_DIR", -2, 2, 2);  [line 691]
    putSpinnerAction("wind_flows_palette_dir",
      () -> (float) allWindFlows.palette_DIR,
      (v) -> { allWindFlows.palette_DIR = int(v); },
      -2, 2, 1,
      0, 1, 0);

    // allWindFlows.palette_MLT = this.Spinner(..., "windFlows.palette_MLT", 0.01, 1.0, -2);  [line 692]
    putSpinnerAction("wind_flows_palette_mlt",
      () -> allWindFlows.palette_MLT,
      (v) -> { allWindFlows.palette_MLT = v; },
      0.01, 1.0, 0.001,
      0, 1, 0);

    // Select3D.Group_displayPivot = this.Spinner(..., "3D-select.Group_displayPivot");  [line 698]
    putSpinnerAction("3_d_select_group_display_pivot",
      () -> (Select3D.Group_displayPivot ? 1f : 0f),
      (v) -> { Select3D.Group_displayPivot = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0,
      viewChangedOnly);

    // Select3D.displayReferencePivot = this.Spinner(..., "3D-select.displayReferencePivot");  [line 699]
    putSpinnerAction("3_d_select_display_reference_pivot",
      () -> (Select3D.displayReferencePivot ? 1f : 0f),
      (v) -> { Select3D.displayReferencePivot = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0,
      viewChangedOnly);

    // Select3D.Group_displayBox = this.Spinner(..., "3D-select.Group_displayBox");  [line 700]
    putSpinnerAction("3_d_select_group_display_box",
      () -> (Select3D.Group_displayBox ? 1f : 0f),
      (v) -> { Select3D.Group_displayBox = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0,
      viewChangedOnly);

    // Select3D.Group_displayEdges = this.Spinner(..., "3D-select.Group_displayEdges");  [line 701]
    putSpinnerAction("3_d_select_group_display_edges",
      () -> (Select3D.Group_displayEdges ? 1f : 0f),
      (v) -> { Select3D.Group_displayEdges = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0,
      viewChangedOnly);

    // Select3D.Face_displayEdges = this.Spinner(..., "3D-select.Face_displayEdges");  [line 703]
    putSpinnerAction("3_d_select_face_display_edges",
      () -> (Select3D.Face_displayEdges ? 1f : 0f),
      (v) -> { Select3D.Face_displayEdges = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0,
      viewChangedOnly);

    // Select3D.Face_displayVertexCount = this.Spinner(..., "3D-select.Face_displayVertexCount");  [line 704]
    putSpinnerAction("3_d_select_face_display_vertex_count",
      () -> (Select3D.Face_displayVertexCount ? 1f : 0f),
      (v) -> { Select3D.Face_displayVertexCount = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0,
      viewChangedOnly);

    // Select3D.Polyline_displayVertexCount = this.Spinner(..., "3D-select.Polyline_displayVertexCount");  [line 705]
    putSpinnerAction("3_d_select_polyline_display_vertex_count",
      () -> (Select3D.Polyline_displayVertexCount ? 1f : 0f),
      (v) -> { Select3D.Polyline_displayVertexCount = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0,
      viewChangedOnly);

    // Select3D.Vertex_displayVertices = this.Spinner(..., "3D-select.Vertex_displayVertices");  [line 706]
    putSpinnerAction("3_d_select_vertex_display_vertices",
      () -> (Select3D.Vertex_displayVertices ? 1f : 0f),
      (v) -> { Select3D.Vertex_displayVertices = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0,
      viewChangedOnly);

    // Select3D.Polyline_displayVertices = this.Spinner(..., "3D-select.Polyline_displayVertices");  [line 707]
    putSpinnerAction("3_d_select_polyline_display_vertices",
      () -> (Select3D.Polyline_displayVertices ? 1f : 0f),
      (v) -> { Select3D.Polyline_displayVertices = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0,
      viewChangedOnly);

    // Select3D.Model2D_displayEdges = this.Spinner(..., "3D-select.Model2D_displayEdges");  [line 709]
    putSpinnerAction("3_d_select_model2_d_display_edges",
      () -> (Select3D.Model2D_displayEdges ? 1f : 0f),
      (v) -> { Select3D.Model2D_displayEdges = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0,
      viewChangedOnly);

    // Select3D.Model1D_displayEdges = this.Spinner(..., "3D-select.Model1D_displayEdges");  [line 710]
    putSpinnerAction("3_d_select_model1_d_display_edges",
      () -> (Select3D.Model1D_displayEdges ? 1f : 0f),
      (v) -> { Select3D.Model1D_displayEdges = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0,
      viewChangedOnly);

    // Select3D.Solid_displayEdges = this.Spinner(..., "3D-select.Solid_displayEdges");  [line 712]
    putSpinnerAction("3_d_select_solid_display_edges",
      () -> (Select3D.Solid_displayEdges ? 1f : 0f),
      (v) -> { Select3D.Solid_displayEdges = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0,
      viewChangedOnly);

    // Select3D.Section_displayEdges = this.Spinner(..., "3D-select.Section_displayEdges");  [line 714]
    putSpinnerAction("3_d_select_section_display_edges",
      () -> (Select3D.Section_displayEdges ? 1f : 0f),
      (v) -> { Select3D.Section_displayEdges = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0,
      viewChangedOnly);

    // Select3D.Camera_displayEdges = this.Spinner(..., "3D-select.Camera_displayEdges");  [line 716]
    putSpinnerAction("3_d_select_camera_display_edges",
      () -> (Select3D.Camera_displayEdges ? 1f : 0f),
      (v) -> { Select3D.Camera_displayEdges = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0,
      viewChangedOnly);

    // Select3D.LandPoint_displayPoints = this.Spinner(..., "3D-select.LandPoint_displayPoints");  [line 718]
    putSpinnerAction("3_d_select_land_point_display_points",
      () -> (Select3D.LandPoint_displayPoints ? 1f : 0f),
      (v) -> { Select3D.LandPoint_displayPoints = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0,
      viewChangedOnly);

    // Interpolation_Weight = this.Spinner(..., "Interpolation_Weight", 0, 5, 0.5);  [line 724]
    putSpinnerAction("interpolation_weight",
      () -> Interpolation_Weight,
      (v) -> { Interpolation_Weight = v; },
      0, 5, 0.5,
      1, 0, 0);

    // CLIMATIC_SolarForecast = this.Spinner(..., "Climate-based solar forecast", 0, 1, 1);  [line 725]
    putSpinnerAction("climate_based_solar_forecast",
      () -> (float) CLIMATIC_SolarForecast,
      (v) -> { CLIMATIC_SolarForecast = int(v); },
      0, 1, 1,
      1, 0, 0,
      applyTimeChange);

    // CLIMATIC_WeatherForecast = this.Spinner(..., "Climate-based temperature forecast", 0, 2, 1);  [line 726]
    putSpinnerAction("climate_based_temperature_forecast",
      () -> (float) CLIMATIC_WeatherForecast,
      (v) -> { CLIMATIC_WeatherForecast = int(v); },
      0, 2, 1,
      1, 0, 0,
      applyTimeChange);

    // Develop_Option = this.Spinner(..., "Develop_Option", 0, 11, 1);  [line 729]
    putSpinnerAction("develop_option",
      () -> (float) Develop_Option,
      (v) -> { Develop_Option = int(v); },
      0, 11, 1,
      1, 0, 0);

    // Develop_DayHour = this.Spinner(..., "Develop_DayHour", 0, 3, 1);  [line 730]
    putSpinnerAction("develop_day_hour",
      () -> (float) Develop_DayHour,
      (v) -> { Develop_DayHour = int(v); },
      0, 3, 1,
      1, 0, 0);

    // STUDY.TrendJoinHours = this.Spinner(..., "Trend period hours", 1, 24 * 16, 1);  [line 732]
    putSpinnerAction("trend_period_hours",
      () -> (float) STUDY.TrendJoinHours,
      (v) -> { STUDY.TrendJoinHours = int(v); },
      1, 24 * 16, 1,
      1, 0, 0);

    // STUDY.TrendJoinType = this.Spinner(..., "Weighted/equal trend", -1, 1, 2);  [line 733]
    putSpinnerAction("weighted_equal_trend",
      () -> (float) STUDY.TrendJoinType,
      (v) -> { STUDY.TrendJoinType = int(v); },
      -1, 1, 1,
      1, 0, 0);

    // Develop_AngleInclination = this.Spinner(..., "Inclination angle", 0, 90, 5);  [line 735]
    putSpinnerAction("inclination_angle",
      () -> Develop_AngleInclination,
      (v) -> { Develop_AngleInclination = v; },
      0, 90, 1,
      1, 0, 0);

    // Develop_AngleOrientation = this.Spinner(..., "Orientation angle", 0, 360, 15);  [line 736]
    putSpinnerAction("orientation_angle",
      () -> Develop_AngleOrientation,
      (v) -> { Develop_AngleOrientation = v; },
      0, 360, 1,
      1, 0, 0);

    // CurrentDataSource = this.Spinner(..., "Impact Source", 0, MAXIMUM_dataID, 1);  [line 739]
    putSpinnerAction("impact_source",
      () -> (float) CurrentDataSource,
      (v) -> { CurrentDataSource = int(v); },
      () -> (float) (0), () -> (float) (MAXIMUM_dataID), 1,
      1, 0, 0,
      impactsUpdateFlag);

    // STUDY.ImpactLayer = this.Spinner(..., "Impact Min/50%/Max", 0, 8, 1);  [line 740]
    putSpinnerAction("impact_min_50_max",
      () -> (float) STUDY.ImpactLayer,
      (v) -> { STUDY.ImpactLayer = int(v); },
      0, 8, 1,
      1, 0, 0);

    // STUDY.export_info_node = this.Spinner(..., "Export ASCII data");  [line 746]
    putSpinnerAction("export_ascii_data",
      () -> (STUDY.export_info_node ? 1f : 0f),
      (v) -> { STUDY.export_info_node = (v >= 0.5f); },
      0, 1, 1,
      1, 0, 0);

    // STUDY.export_info_norm = this.Spinner(..., "Export ASCII statistics");  [line 747]
    putSpinnerAction("export_ascii_statistics",
      () -> (STUDY.export_info_norm ? 1f : 0f),
      (v) -> { STUDY.export_info_norm = (v >= 0.5f); },
      0, 1, 1,
      1, 0, 0);

    // STUDY.export_info_prob = this.Spinner(..., "Export ASCII probabilities");  [line 748]
    putSpinnerAction("export_ascii_probabilities",
      () -> (STUDY.export_info_prob ? 1f : 0f),
      (v) -> { STUDY.export_info_prob = (v >= 0.5f); },
      0, 1, 1,
      1, 0, 0);

    // User3D.export_Scale = this.Spinner(..., "3D-export.Scale", .001, 1000, -0.1);  [line 751]
    putSpinnerAction("3_d_export_scale",
      () -> User3D.export_Scale,
      (v) -> { User3D.export_Scale = v; },
      .001, 1000, 0.1,
      0, 0, 0);

    // User3D.export_FlipZYaxis = this.Spinner(..., "3D-export.FlipZYaxis", 0, 1, 1);  [line 752]
    putSpinnerAction("3_d_export_flip_zyaxis",
      () -> (float) User3D.export_FlipZYaxis,
      (v) -> { User3D.export_FlipZYaxis = int(v); },
      0, 1, 1,
      0, 0, 0);

    // User3D.export_PrecisionVertex = this.Spinner(..., "3D-export.PrecisionVertex", 0, 6, 1);  [line 754]
    putSpinnerAction("3_d_export_precision_vertex",
      () -> (float) User3D.export_PrecisionVertex,
      (v) -> { User3D.export_PrecisionVertex = int(v); },
      0, 6, 1,
      0, 0, 0);

    // User3D.export_PrecisionVtexture = this.Spinner(..., "3D-export.PrecisionVtexture", 0, 6, 1);  [line 755]
    putSpinnerAction("3_d_export_precision_vtexture",
      () -> (float) User3D.export_PrecisionVtexture,
      (v) -> { User3D.export_PrecisionVtexture = int(v); },
      0, 6, 1,
      0, 0, 0);

    // User3D.export_PolyToPoly = this.Spinner(..., "3D-export.PolyToPoly", 0, 1, 1);  [line 756]
    putSpinnerAction("3_d_export_poly_to_poly",
      () -> (float) User3D.export_PolyToPoly,
      (v) -> { User3D.export_PolyToPoly = int(v); },
      0, 1, 1,
      0, 0, 0);

    // User3D.export_MaterialLibrary = this.Spinner(..., "3D-export.MaterialLibrary");  [line 758]
    putSpinnerAction("3_d_export_material_library",
      () -> (User3D.export_MaterialLibrary ? 1f : 0f),
      (v) -> { User3D.export_MaterialLibrary = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0);

    // User3D.export_BackSides = this.Spinner(..., "3D-export.BackSides");  [line 759]
    putSpinnerAction("3_d_export_back_sides",
      () -> (User3D.export_BackSides ? 1f : 0f),
      (v) -> { User3D.export_BackSides = (v >= 0.5f); },
      0, 1, 1,
      0, 0, 0);

    // User3D.export_PaletteResolution = this.Spinner(..., "3D-export.PaletteResolution", 32, 2048, -2);  [line 760]
    putSpinnerAction("3_d_export_palette_resolution",
      () -> (float) User3D.export_PaletteResolution,
      (v) -> { User3D.export_PaletteResolution = int(v); },
      32, 2048, 1,
      0, 0, 0);

    // allSolidImpacts.record_IMG = this.Spinner(..., "Record SolidImpact in JPG", 0, 1, 1);  [line 765]
    putSpinnerAction("record_solid_impact_in_jpg",
      () -> (float) allSolidImpacts.record_IMG,
      (v) -> { allSolidImpacts.record_IMG = int(v); },
      0, 1, 1,
      0, 0, 0);

    // allSolidImpacts.record_PDF = this.Spinner(..., "Record SolidImpact in PDF", 0, 1, 1);  [line 766]
    putSpinnerAction("record_solid_impact_in_pdf",
      () -> (float) allSolidImpacts.record_PDF,
      (v) -> { allSolidImpacts.record_PDF = int(v); },
      0, 1, 1,
      0, 0, 0);

    // allSolarImpacts.record_IMG = this.Spinner(..., "Record Solar Analysis in JPG", 0, 1, 1);  [line 768]
    putSpinnerAction("record_solar_analysis_in_jpg",
      () -> (float) allSolarImpacts.record_IMG,
      (v) -> { allSolarImpacts.record_IMG = int(v); },
      0, 1, 1,
      0, 0, 0);

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
        STUDY.j_End = this.Spinner(X_control, Y_control, 1, 1, 0, "Number of days to plot", STUDY.j_End, 1, 365, 1);

        STUDY.perDays = this.Spinner(X_control, Y_control, 1, 1, 0, "Day step", STUDY.perDays, 1.0, 182.5, 0.5);

        STUDY.joinDays = this.Spinner(X_control, Y_control, 1, 1, 0, "Join days", STUDY.joinDays, 1, 182, 1);

        TIME.date = this.Spinner(X_control, Y_control, 1, 1, 0, "Days past March equinox", TIME.date, 0, 364, 1);

        //TIME.beginDay = this.Spinner(X_control, Y_control, 1, 1, 0, "Day of year (0-364)", TIME.beginDay, 0, 364, 1);

        TIME.day = this.Spinner(X_control, Y_control, 1, 1, 0, "Start day", TIME.day, 1, 31, 1);
        TIME.month = this.Spinner(X_control, Y_control, 1, 1, 0, "Start month", TIME.month, 1, 12, 1);
        TIME.year = this.Spinner(X_control, Y_control, 1, 1, 0, "Start year", TIME.year, 1953, 2100, 1);
      }

      if (this.child == CHILD_PERIOD_RANGES) {
        STUDY.i_Start = this.Spinner(X_control, Y_control, 1, 0, 0, "Start hour", STUDY.i_Start, 0, 23, 1);
        STUDY.i_End = this.Spinner(X_control, Y_control, 1, 0, 0, "End hour", STUDY.i_End, 0, 23, 1);

        SampleYear_Start = this.Spinner(X_control, Y_control, 1, 0, 0, "Start year", SampleYear_Start, CLIMATE_CWEEDS_start, CLIMATE_CLMREC_end, 1);
        SampleYear_End = this.Spinner(X_control, Y_control, 1, 0, 0, "End year", SampleYear_End, CLIMATE_CWEEDS_start, CLIMATE_CLMREC_end, 1);

        SampleMember_Start = this.Spinner(X_control, Y_control, 1, 0, 0, "Start member", SampleMember_Start, ENSEMBLE_FORECAST_start, ENSEMBLE_FORECAST_end, 1);
        SampleMember_End = this.Spinner(X_control, Y_control, 1, 0, 0, "End member", SampleMember_End, ENSEMBLE_FORECAST_start, ENSEMBLE_FORECAST_end, 1);

        SampleStation_Start = this.Spinner(X_control, Y_control, 1, 0, 0, "Start station", SampleStation_Start, ENSEMBLE_OBSERVED_start, ENSEMBLE_OBSERVED_end, 1);
        SampleStation_End = this.Spinner(X_control, Y_control, 1, 0, 0, "End station", SampleStation_End, ENSEMBLE_OBSERVED_start, ENSEMBLE_OBSERVED_end, 1);

        ENSEMBLE_OBSERVED_maxDays = this.Spinner(X_control, Y_control, 0, 0, 1, "Forecast/Obs_maxDays", ENSEMBLE_OBSERVED_maxDays, 0, 31, 1);
      }

      if (this.child == CHILD_PERIOD_FILTERS) {

        STUDY.skyScenario = this.Spinner(X_control, Y_control, 1, 0, 0, "Sky status", STUDY.skyScenario, 1, 4, 1);
        STUDY.filter = this.Spinner(X_control, Y_control, 1, 0, 0, "Hourly/daily filter", STUDY.filter, 0, 1, 1);
      }
    } else if (this.parent == PARENT_LOCATION) {


      if (this.child == CHILD_LOCATION_POINT) {
        LocationLAT = this.Spinner(X_control, Y_control, 0, 0, 1, "Latitude", LocationLAT, -85, 85, 0.01);
        LocationLON = this.Spinner(X_control, Y_control, 0, 0, 1, "Longitude", LocationLON, -180, 180, 0.01);
        //LocationELE = this.Spinner(X_control, Y_control, 0, 0, 1, "Elevation", LocationELE, -100, 8000, 1);
      }

      if (this.child == CHILD_LOCATION_STATIONS) {

        WORLD.displayAll_TMYEPW = this.Spinner(X_control, Y_control, 0, 0, 1, "displayAll_TMYEPW", WORLD.displayAll_TMYEPW, 0, 2, 1);
        WORLD.displayNear_TMYEPW = this.Spinner(X_control, Y_control, 0, 0, 1, "displayNear_TMYEPW", WORLD.displayNear_TMYEPW);

        WORLD.displayAll_CWEEDS = this.Spinner(X_control, Y_control, 0, 0, 1, "displayAll_CWEEDS", WORLD.displayAll_CWEEDS, 0, 2, 1);
        WORLD.displayNear_CWEEDS = this.Spinner(X_control, Y_control, 0, 0, 1, "displayNear_CWEEDS", WORLD.displayNear_CWEEDS);

        WORLD.displayAll_CLMREC = this.Spinner(X_control, Y_control, 0, 0, 1, "displayAll_CLMREC", WORLD.displayAll_CLMREC, 0, 2, 1);
        WORLD.displayNear_CLMREC = this.Spinner(X_control, Y_control, 0, 0, 1, "displayNear_CLMREC", WORLD.displayNear_CLMREC);

        WORLD.displayAll_SWOB = this.Spinner(X_control, Y_control, 0, 0, 1, "displayAll_SWOB", WORLD.displayAll_SWOB, 0, 2, 1);
        WORLD.displayNear_SWOB = this.Spinner(X_control, Y_control, 0, 0, 1, "displayNear_SWOB", WORLD.displayNear_SWOB);

        WORLD.displayAll_NAEFS = this.Spinner(X_control, Y_control, 0, 0, 1, "displayAll_NAEFS", WORLD.displayAll_NAEFS, 0, 2, 1);
        WORLD.displayNear_NAEFS = this.Spinner(X_control, Y_control, 0, 0, 1, "displayNear_NAEFS", WORLD.displayNear_NAEFS);
      }
    } else if (this.parent == PARENT_GEOMETRY) {
      if (this.child == CHILD_GEOMETRY_CREATE) {

        addToLastGroup = this.Spinner(X_control, Y_control, 0, 1, 0, "addToLastGroup", addToLastGroup);

        User3D.default_Material = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Material", User3D.default_Material, -1, 8, 1);
        User3D.default_Tessellation = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Tessellation", User3D.default_Tessellation, 0, 6, 1);
        User3D.default_Layer = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Layer", User3D.default_Layer, 0, 16, 1);
        User3D.default_Visibility = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Visibility", User3D.default_Visibility, -1, 1, 1);
        User3D.default_Weight = this.Spinner(X_control, Y_control, 0,0,0, "3D-create.Weight" , User3D.default_Weight, -20, 20, 1);
        User3D.default_Closed = this.Spinner(X_control, Y_control, 0,0,0, "3D-create.Closed" , User3D.default_Closed, 0, 1, 1);

        User3D.create_Orientation = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Orientation", User3D.create_Orientation, 0, 360, 1, 0.001);

        User3D.create_Length = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Length (rand negative)", User3D.create_Length, -100.0, 1000.0, 1.0, 0.001);
        User3D.create_Width = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Width (rand negative)", User3D.create_Width, -100.0, 1000.0, 1.0, 0.001);
        User3D.create_Height = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Height (rand negative)", User3D.create_Height, -100.0, 1000.0, 1.0, 0.001);

        User3D.create_Volume = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Volume", User3D.create_Volume, 0, 1000000000, 1, 0.001);

        User3D.create_Snap = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Snap", User3D.create_Snap, 0, 1, 1);

        User3D.create_SphereDegree = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.SphereDegree", User3D.create_SphereDegree, 0, 5, 1);

        User3D.create_CylinderDegree = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.CylinderDegree", User3D.create_CylinderDegree, 3, 36, 1);

        User3D.create_PolyDegree = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.PolyDegree", User3D.create_PolyDegree, 3, 36, 1);

        User3D.create_Parametric_Type = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Parametric_Type", User3D.create_Parametric_Type, 1, 6, 1);
        User3D.create_Person_Type = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Person_Type", User3D.create_Person_Type, 0, allModel2Ds.num_files_PEOPLE, 1);
        User3D.create_Plant_Type = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Plant_Type", User3D.create_Plant_Type, 0, allModel2Ds.num_files_TREES, 1);

      }

      if (this.child == CHILD_GEOMETRY_MODIFY) {

        User3D.modify_OpenningDepth = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-modify.OpenningDepth", User3D.modify_OpenningDepth, -10, 10, 0.1);
        User3D.modify_OpenningArea = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-modify.OpenningArea", User3D.modify_OpenningArea, 0, 1, 0.05);
        User3D.modify_OpenningDeviation = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-modify.OpenningDeviation", User3D.modify_OpenningDeviation, 0, 1, 0.05);

        User3D.modify_TessellateRows = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-modify.TessellateRows", User3D.modify_TessellateRows, 1, 100, 1);
        User3D.modify_TessellateColumns = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-modify.TessellateColumns", User3D.modify_TessellateColumns, 1, 100, 1);

        User3D.modify_OffsetAmount = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-modify.OffsetAmount", User3D.modify_OffsetAmount, 0, 25, 0.001);

        User3D.modify_WeldTreshold = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-modify.WeldTreshold", User3D.modify_WeldTreshold, 0, 10, 0.001);

        Select3D.softPower = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.softPower", Select3D.softPower, 0.125, 8.0, -2, 0.001);
        Select3D.softRadius = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.softRadius", Select3D.softRadius, 0.01, 100, -2, 0.001);

        Select3D.posVector = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.posVector", Select3D.posVector, 0, 3, 1);
        Select3D.rotVector =  this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.rotVector", Select3D.rotVector, 0, 2, 1);
        Select3D.scaleVector =  this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.scaleVector", Select3D.scaleVector, 0, 3, 1);

        Select3D.posValue = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.posValue", Select3D.posValue, -50.0, 50.0, 1.0, 0.001);
        Select3D.rotValue = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.rotValue", Select3D.rotValue, -180.0, 180.0, 1.0, 0.001);
        Select3D.scaleValue = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.scaleValue", Select3D.scaleValue, -8.0, 8.0, 1.0, 0.001);

        Select3D.alignX = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.alignX", Select3D.alignX, -1, 1, 1);
        Select3D.alignY = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.alignY", Select3D.alignY, -1, 1, 1);
        Select3D.alignZ = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.alignZ", Select3D.alignZ, -1, 1, 1);
      }

      if (this.child == CHILD_GEOMETRY_SOLID) {
        User3D.create_powAll = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.powAll", User3D.create_powAll, 0.5, CubePower, -2, 0.001);
        User3D.create_powX = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.powX", User3D.create_powX, 0.5, CubePower, -2, 0.001);
        User3D.create_powY = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.powY", User3D.create_powY, 0.5, CubePower, -2, 0.001);
        User3D.create_powZ = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.powZ", User3D.create_powZ, 0.5, CubePower, -2, 0.001);
      }


      if (this.child == CHILD_GEOMETRY_FRACTAL_TREE) {

        User3D.create_Model1D_Type = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Type", User3D.create_Model1D_Type, 0, 0, 1);
        User3D.create_Model1D_DegreeMax = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.DegreeMax", User3D.create_Model1D_DegreeMax, 0, 12, 1);
        User3D.create_Model1D_Seed = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Seed", User3D.create_Model1D_Seed, -1, 32767, 1);
        User3D.create_Model1D_TrunkSize = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.TrunkSize", User3D.create_Model1D_TrunkSize, 0, 10, 0.1, 0.1);
        User3D.create_Model1D_LeafSize = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.LeafSize", User3D.create_Model1D_LeafSize, 0, 1, 0.01, 0.1);

        User3D.create_Model1D_BranchTilt = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.BranchTilt", User3D.create_Model1D_BranchTilt, 0, 360, 5, 0.1);
        User3D.create_Model1D_BranchTwist = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.BranchTwist", User3D.create_Model1D_BranchTwist, 0, 360, 5, 0.1);
        User3D.create_Model1D_BranchRatio = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.BranchRatio", User3D.create_Model1D_BranchRatio, 0.05, 1, 0.05, 0.01);
        User3D.create_Model1D_TreeBase = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.TreeBase", User3D.create_Model1D_TreeBase, 0, 4, 0.1, 0.01);
      }

      if (this.child == CHILD_GEOMETRY_ENVIRONMENT) {

        Land3D.loadTextures = this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.loadTextures", Land3D.loadTextures);
        Land3D.loadMesh = this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.loadMesh", Land3D.loadMesh);
        Land3D.skipStart = this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.skipStart", Land3D.skipStart, 0, Land3D.num_rows - 1, 1);
        Land3D.skipEnd = this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.skipEnd", Land3D.skipEnd, 0, Land3D.num_rows - 1, 1);
        Land3D.displaySurface = this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.displaySurface", Land3D.displaySurface);
        Land3D.displayTexture = this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.displayTexture", Land3D.displayTexture);
        Land3D.displayPoints = this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.displayPoints", Land3D.displayPoints);
        Land3D.displayDepth = this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.displayDepth", Land3D.displayDepth);

        allModel2Ds.displayAll = this.Spinner(X_control, Y_control, 0, 1, 0, "model2Ds.displayAll", allModel2Ds.displayAll);
        allModel1Ds.displayAll = this.Spinner(X_control, Y_control, 0, 1, 0, "model1Ds.displayAll", allModel1Ds.displayAll);
        allModel1Ds.displayLeaves = this.Spinner(X_control, Y_control, 0, 1, 0, "model1Ds.displayLeaves", allModel1Ds.displayLeaves);
        allPolylines.displayAll = this.Spinner(X_control, Y_control, 0, 1, 0, "polylines.displayAll", allPolylines.displayAll);
        allFaces.displayAll = this.Spinner(X_control, Y_control, 0, 1, 0, "faces.displayAll", allFaces.displayAll);

        allSolids.displayAll = this.Spinner(X_control, Y_control, 0, 1, 0, "solids.displayAll", allSolids.displayAll);

        allSections.displayAll = this.Spinner(X_control, Y_control, 0, 1, 0, "sections.displayAll", allSections.displayAll);




        allWindRoses.displayImage = this.Spinner(X_control, Y_control, 0, 1, 0, "windRoses.displayImage", allWindRoses.displayImage);

        allWindRoses.scale = this.Spinner(X_control, Y_control, 0, 1, 0, "windRoses.scale", allWindRoses.scale, 50, 3200, -2, 0.001);
        allWindRoses.RES = int(this.Spinner(X_control, Y_control, 0, 1, 0, "windRoses.resolution", allWindRoses.RES, 200, 600, 100));



        Sky3D.displaySurface = this.Spinner(X_control, Y_control, 0, 1, 0, "Sky3D.displaySurface", Sky3D.displaySurface);

        Sun3D.displayPath = this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.displayPath", Sun3D.displayPath);
        Sun3D.displayPattern = this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.displayPattern", Sun3D.displayPattern);
      }


      if (this.child == CHILD_GEOMETRY_VIEWPORT) {

        WIN3D.currentCamera = this.Spinner(X_control, Y_control, 0, 1, 0, "currentCamera", WIN3D.currentCamera, 0, allCameras.num, 1);

        WIN3D.CAM_clipNear = this.Spinner(X_control, Y_control, 0, 1, 0, "Camera_clipNear", WIN3D.CAM_clipNear, 0.01, 100, -2, 0.001);
        WIN3D.CAM_clipFar = this.Spinner(X_control, Y_control, 0, 1, 0, "Camera_clipFar", WIN3D.CAM_clipFar, 1000, 2000000000, -2, 0.001);


        allPoints.displayAll = this.Spinner(X_control, Y_control, 0, 1, 0, "Create3D.displayVertices", allPoints.displayAll);
        allFaces.displayEdges = this.Spinner(X_control, Y_control, 0, 1, 0, "Create3D.displayEdges", allFaces.displayEdges);
        allFaces.displayNormals = this.Spinner(X_control, Y_control, 0, 1, 0, "Create3D.displayNormals", allFaces.displayNormals);

        allCameras.displayAll = this.Spinner(X_control, Y_control, 0, 1, 0, "cameras.displayAll", allCameras.displayAll);
      }


      if (this.child == CHILD_GEOMETRY_SIMULATION) {

        IMPACTS_displayDay = this.Spinner(X_control, Y_control, 0, 1, 0, "IMPACTS_displayDay", IMPACTS_displayDay, 0, STUDY.j_End - STUDY.j_Start, 1);

        allSolarImpacts.displayImage = this.Spinner(X_control, Y_control, 0, 1, 0, "solarImpacts.displayImage", allSolarImpacts.displayImage);
        allSolidImpacts.displayImage = this.Spinner(X_control, Y_control, 0, 1, 0, "solidImpacts.displayImage", allSolidImpacts.displayImage);

        allSolarImpacts.sectionType = this.Spinner(X_control, Y_control, 0, 1, 0, "solarImpacts.sectionType", allSolarImpacts.sectionType, 0, 3, 1);
        allSolidImpacts.sectionType = this.Spinner(X_control, Y_control, 0, 1, 0, "solidImpacts.sectionType", allSolidImpacts.sectionType, 0, 3, 1);


        allSolidImpacts.Grade = this.Spinner(X_control, Y_control, 0, 1, 0, "solidImpacts.Grade", allSolidImpacts.Grade, 0.0001, 64.0, -2, 0.001);
        allSolidImpacts.Power = this.Spinner(X_control, Y_control, 0, 1, 0, "solidImpacts.Power", allSolidImpacts.Power, 0.0001, 64.0, -2, 0.001);
        allSolidImpacts.R[allSolidImpacts.sectionType] = this.Spinner(X_control, Y_control, 0, 1, 0, "solidImpacts.R[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.R[allSolidImpacts.sectionType], -360, 360, -2, 0.001);
        allSolidImpacts.Z[allSolidImpacts.sectionType] = this.Spinner(X_control, Y_control, 0, 1, 0, "solidImpacts.Z[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.Z[allSolidImpacts.sectionType], -1000, 1000, -2, 0.001);
        allSolidImpacts.positionStep = this.Spinner(X_control, Y_control, 0, 1, 0, "solidImpacts.positionStep", allSolidImpacts.positionStep, 5, 80, -2, 0.001);

        allSolidImpacts.U[allSolidImpacts.sectionType] = this.Spinner(X_control, Y_control, 0, 1, 0, "solidImpacts.U[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.U[allSolidImpacts.sectionType], 0.125, 3200, -2, 0.001);
        allSolidImpacts.V[allSolidImpacts.sectionType] = this.Spinner(X_control, Y_control, 0, 1, 0, "solidImpacts.V[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.V[allSolidImpacts.sectionType], 0.125, 3200, -2, 0.001);
        allSolidImpacts.X[allSolidImpacts.sectionType] = this.Spinner(X_control, Y_control, 0, 1, 0, "solidImpacts.X[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.X[allSolidImpacts.sectionType], -10000, 10000, -2, 0.001);
        allSolidImpacts.Y[allSolidImpacts.sectionType] = this.Spinner(X_control, Y_control, 0, 1, 0, "solidImpacts.Y[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.Y[allSolidImpacts.sectionType], -10000, 10000, -2, 0.001);


        allSolidImpacts.WindSpeed = this.Spinner(X_control, Y_control, 0, 1, 0, "solidImpacts.WindSpeed (m/s)", allSolidImpacts.WindSpeed, 1, 16, -2, 0.001);
        allSolidImpacts.WindDirection = this.Spinner(X_control, Y_control, 0, 1, 0, "solidImpacts.WindDirection", allSolidImpacts.WindDirection, 0, 360, 15);


        allSolidImpacts.Process_subDivisions = this.Spinner(X_control, Y_control, 0, 0, 0, "solidImpacts.Process_subDivisions", allSolidImpacts.Process_subDivisions, 0, 3, 1);

        allSolidImpacts.displayPoints = this.Spinner(X_control, Y_control, 0, 0, 0, "solidImpacts.displayPoints", allSolidImpacts.displayPoints);
        allSolidImpacts.displayLines = this.Spinner(X_control, Y_control, 0, 0, 0, "solidImpacts.displayLines", allSolidImpacts.displayLines);

        allWindFlows.displayAll = this.Spinner(X_control, Y_control, 0, 0, 0, "windFlows.displayAll", allWindFlows.displayAll);
      }

      if (this.child == CHILD_GEOMETRY_OTHER) {

        allFaces.displayTessellation = this.Spinner(X_control, Y_control, 0, 1, 0, "3D-create.displayTessellation", allFaces.displayTessellation, 0, 4, 1);

        Land3D.displayTessellation = this.Spinner(X_control, Y_control, 0, 1, 0, "Land.displayTessellation", Land3D.displayTessellation, 0, 4, 1);

        Sky3D.displayTessellation = this.Spinner(X_control, Y_control, 0, 1, 0, "Sky.displayTessellation", Sky3D.displayTessellation, 0, 4, 1);
          Sky3D.radius = this.Spinner(X_control, Y_control, 0, 1, 0, "Sky.scale",   Sky3D.radius, 1, 4000000, -2, 0.001);

        Tropo3D.displaySurface = this.Spinner(X_control, Y_control, 0, 1, 0, "Tropo3D.displaySurface", Tropo3D.displaySurface);
        Tropo3D.displayTexture = this.Spinner(X_control, Y_control, 0, 1, 0, "Tropo3D.displayTexture", Tropo3D.displayTexture);

        Earth3D.displaySurface = this.Spinner(X_control, Y_control, 0, 1, 0, "Earth3D.displaySurface", Earth3D.displaySurface);
        Earth3D.displayTexture = this.Spinner(X_control, Y_control, 0, 1, 0, "Earth3D.displayTexture", Earth3D.displayTexture);
        Earth3D.levelOfDetail = this.Spinner(X_control, Y_control, 0, 1, 0, "Earth3D.levelOfDetail", Earth3D.levelOfDetail, 1.0 / 16.0, 16.0, -2, 0.001);
        Earth3D.recomputeLevelOfDetailDependents();

        Moon3D.displaySurface = this.Spinner(X_control, Y_control, 0, 1, 0, "Moon3D.displaySurface", Moon3D.displaySurface);
        Moon3D.displayTexture = this.Spinner(X_control, Y_control, 0, 1, 0, "Moon3D.displayTexture", Moon3D.displayTexture);
        Moon3D.fitInSkyDome = this.Spinner(X_control, Y_control, 0, 1, 0, "Moon3D.fitInSkyDome", Moon3D.fitInSkyDome);

        Sun3D.displaySurface = this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.displaySurface", Sun3D.displaySurface);
        Sun3D.displayTexture = this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.displayTexture", Sun3D.displayTexture);
        Sun3D.fitInSkyDome = this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.fitInSkyDome", Sun3D.fitInSkyDome);

        Planetary_Magnification = this.Spinner(X_control, Y_control, 0, 1, 0, "Planetary_Magnification", Planetary_Magnification, 1, 64, -2);

        OBJECTS_scale = this.Spinner(X_control, Y_control, 0, 1, 0, "Objects_scale", OBJECTS_scale, 0.0000001, 1000000, -2, 0.000001);
      }

    } else if (this.parent == PARENT_ILLUSTRATION) {

      if (this.child == CHILD_ILLUSTRATION_2D_LAYERS) {
        STUDY.plotSetup = this.Spinner(X_control, Y_control, 1, 0, 0, "Diagram setup", STUDY.plotSetup, -2, 8, 1);

        STUDY.V_scale = this.Spinner(X_control, Y_control, 1, 0, 0, "Scale (" + allLayers[CurrentLayer_id].descriptions[Language_EN] + ")", STUDY.V_scale, 0.0001, 10000, -pow(2.0, (1.0 / 2.0)));

        STUDY.displayRaws = this.Spinner(X_control, Y_control, 1, 0, 0, "Draw data", STUDY.displayRaws);
        STUDY.displaySorted = this.Spinner(X_control, Y_control, 1, 0, 0, "Draw sorted", STUDY.displaySorted);
        STUDY.displayNormals = this.Spinner(X_control, Y_control, 1, 0, 0, "Draw statistics", STUDY.displayNormals);
        STUDY.displayProbs = this.Spinner(X_control, Y_control, 1, 0, 0, "Draw probabilities", STUDY.displayProbs);
        STUDY.sumInterval = this.Spinner(X_control, Y_control, 1, 0, 0, "Probabilities interval", STUDY.sumInterval, 1, 24, 1);
        STUDY.LevelPix = this.Spinner(X_control, Y_control, 1, 0, 0, "Probabilities range", STUDY.LevelPix, 2, 32, -2, 1);
      }

      if (this.child == CHILD_ILLUSTRATION_2D_COLORS) {

        STUDY.ACTIVE_palette_CLR = this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.ACTIVE_palette_CLR", STUDY.ACTIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
        STUDY.ACTIVE_palette_DIR = this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.ACTIVE_palette_DIR", STUDY.ACTIVE_palette_DIR, -2, 2, 1);
        STUDY.ACTIVE_palette_MLT = this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.ACTIVE_palette_MLT", STUDY.ACTIVE_palette_MLT, 0.125, 8, -2, 0.001);

        STUDY.PASSIVE_palette_CLR = this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.PASSIVE_palette_CLR", STUDY.PASSIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
        STUDY.PASSIVE_palette_DIR = this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.PASSIVE_palette_DIR", STUDY.PASSIVE_palette_DIR, -2, 2, 2, 1);
        STUDY.PASSIVE_palette_MLT = this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.PASSIVE_palette_MLT", STUDY.PASSIVE_palette_MLT, 0.125, 8, -2, 0.001);

        STUDY.SORT_palette_CLR = this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.SORT_palette_CLR", STUDY.SORT_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
        STUDY.SORT_palette_DIR = this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.SORT_palette_DIR", STUDY.SORT_palette_DIR, -2, 2, 2, 1);
        STUDY.SORT_palette_MLT = this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.SORT_palette_MLT", STUDY.SORT_palette_MLT, 0.125, 8, -2, 0.001);

        STUDY.PROB_palette_CLR = this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.PROB_palette_CLR", STUDY.PROB_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
        STUDY.PROB_palette_DIR = this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.PROB_palette_DIR", STUDY.PROB_palette_DIR, -2, 2, 2, 1);
        STUDY.PROB_palette_MLT = this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.PROB_palette_MLT", STUDY.PROB_palette_MLT, 0.125, 8, -2, 0.001);

        STUDY.O_scale = this.Spinner(X_control, Y_control, 1, 0, 0, "Windose opacity scale", STUDY.O_scale, 1, 100, -pow(2.0, (1.0 / 4.0)));
      }

      if (this.child == CHILD_ILLUSTRATION_3D_SOLAR) {

        allFaces.ACTIVE_palette_CLR = this.Spinner(X_control, Y_control, 0, 1, 0, "faces.ACTIVE_palette_CLR", allFaces.ACTIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
        allFaces.ACTIVE_palette_DIR = this.Spinner(X_control, Y_control, 0, 1, 0, "faces.ACTIVE_palette_DIR", allFaces.ACTIVE_palette_DIR, -2, 2, 1);
        allFaces.ACTIVE_palette_MLT = this.Spinner(X_control, Y_control, 0, 1, 0, "faces.ACTIVE_palette_MLT", allFaces.ACTIVE_palette_MLT, 0.125, 8, -2, 0.001);

        allFaces.PASSIVE_palette_CLR = this.Spinner(X_control, Y_control, 0, 1, 0, "faces.PASSIVE_palette_CLR", allFaces.PASSIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
        allFaces.PASSIVE_palette_DIR = this.Spinner(X_control, Y_control, 0, 1, 0, "faces.PASSIVE_palette_DIR", allFaces.PASSIVE_palette_DIR, -2, 2, 2, 1);
        allFaces.PASSIVE_palette_MLT = this.Spinner(X_control, Y_control, 0, 1, 0, "faces.PASSIVE_palette_MLT", allFaces.PASSIVE_palette_MLT, 0.125, 8, -2, 0.001);

        Sky3D.ACTIVE_palette_CLR = this.Spinner(X_control, Y_control, 0, 1, 0, "Sky3D.ACTIVE_palette_CLR", Sky3D.ACTIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
        Sky3D.ACTIVE_palette_DIR = this.Spinner(X_control, Y_control, 0, 1, 0, "Sky3D.ACTIVE_palette_DIR", Sky3D.ACTIVE_palette_DIR, -2, 2, 1);
        Sky3D.ACTIVE_palette_MLT = this.Spinner(X_control, Y_control, 0, 1, 0, "Sky3D.ACTIVE_palette_MLT", Sky3D.ACTIVE_palette_MLT, 0.125, 8, -2, 0.001);

        Sky3D.PASSIVE_palette_CLR = this.Spinner(X_control, Y_control, 0, 1, 0, "Sky3D.PASSIVE_palette_CLR", Sky3D.PASSIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
        Sky3D.PASSIVE_palette_DIR = this.Spinner(X_control, Y_control, 0, 1, 0, "Sky3D.PASSIVE_palette_DIR", Sky3D.PASSIVE_palette_DIR, -2, 2, 2, 1);
        Sky3D.PASSIVE_palette_MLT = this.Spinner(X_control, Y_control, 0, 1, 0, "Sky3D.PASSIVE_palette_MLT", Sky3D.PASSIVE_palette_MLT, 0.125, 8, -2, 0.001);

        Sun3D.ACTIVE_palette_CLR = this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.ACTIVE_palette_CLR", Sun3D.ACTIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
        Sun3D.ACTIVE_palette_DIR = this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.ACTIVE_palette_DIR", Sun3D.ACTIVE_palette_DIR, -2, 2, 1);
        Sun3D.ACTIVE_palette_MLT = this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.ACTIVE_palette_MLT", Sun3D.ACTIVE_palette_MLT, 0.125, 8, -2, 0.001);

        Sun3D.PASSIVE_palette_CLR = this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.PASSIVE_palette_CLR", Sun3D.PASSIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
        Sun3D.PASSIVE_palette_DIR = this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.PASSIVE_palette_DIR", Sun3D.PASSIVE_palette_DIR, -2, 2, 2, 1);
        Sun3D.PASSIVE_palette_MLT = this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.PASSIVE_palette_MLT", Sun3D.PASSIVE_palette_MLT, 0.125, 8, -2, 0.001);
      }




      if (this.child == CHILD_ILLUSTRATION_3D_SPATIAL) {

        allSolids.palette_CLR = this.Spinner(X_control, Y_control, 0, 1, 0, "solids.palette_CLR", allSolids.palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
        allSolids.palette_DIR = this.Spinner(X_control, Y_control, 0, 1, 0, "solids.palette_DIR", allSolids.palette_DIR, -2, 2, 2, 1);
        allSolids.palette_MLT = this.Spinner(X_control, Y_control, 0, 1, 0, "solids.palette_MLT", allSolids.palette_MLT, 0.0001, 64, -2, 0.001);

        Land3D.palette_CLR = this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.palette_CLR", Land3D.palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
        Land3D.palette_DIR = this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.palette_DIR", Land3D.palette_DIR, -2, 2, 2, 1);
        Land3D.palette_MLT = this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.palette_MLT", Land3D.palette_MLT, 0.001, 0.5, -2, 0.001);

        allWindFlows.palette_CLR = this.Spinner(X_control, Y_control, 0, 1, 0, "windFlows.palette_CLR", allWindFlows.palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
        allWindFlows.palette_DIR = this.Spinner(X_control, Y_control, 0, 1, 0, "windFlows.palette_DIR", allWindFlows.palette_DIR, -2, 2, 2, 1);
        allWindFlows.palette_MLT = this.Spinner(X_control, Y_control, 0, 1, 0, "windFlows.palette_MLT", allWindFlows.palette_MLT, 0.01, 1.0, -2, 0.001);
      }


      if (this.child == CHILD_ILLUSTRATION_SELECTION) {

        Select3D.Group_displayPivot = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Group_displayPivot", Select3D.Group_displayPivot);
        Select3D.displayReferencePivot = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.displayReferencePivot", Select3D.displayReferencePivot);
        Select3D.Group_displayBox = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Group_displayBox", Select3D.Group_displayBox);
        Select3D.Group_displayEdges = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Group_displayEdges", Select3D.Group_displayEdges);

        Select3D.Face_displayEdges = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Face_displayEdges", Select3D.Face_displayEdges);
        Select3D.Face_displayVertexCount = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Face_displayVertexCount", Select3D.Face_displayVertexCount);
        Select3D.Polyline_displayVertexCount = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Polyline_displayVertexCount", Select3D.Polyline_displayVertexCount);
        Select3D.Vertex_displayVertices = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Vertex_displayVertices", Select3D.Vertex_displayVertices);
        Select3D.Polyline_displayVertices = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Polyline_displayVertices", Select3D.Polyline_displayVertices);

        Select3D.Model2D_displayEdges = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Model2D_displayEdges", Select3D.Model2D_displayEdges);
        Select3D.Model1D_displayEdges = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Model1D_displayEdges", Select3D.Model1D_displayEdges);

        Select3D.Solid_displayEdges = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Solid_displayEdges", Select3D.Solid_displayEdges);

        Select3D.Section_displayEdges = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Section_displayEdges", Select3D.Section_displayEdges);

        Select3D.Camera_displayEdges = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Camera_displayEdges", Select3D.Camera_displayEdges);

        Select3D.LandPoint_displayPoints = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.LandPoint_displayPoints", Select3D.LandPoint_displayPoints);
      }
    } else if (this.parent == PARENT_POSTPROCESS) {

      if (this.child == CHILD_POSTPROCESS_INTERPOLATION) {

        Interpolation_Weight = this.Spinner(X_control, Y_control, 1, 0, 0, "Interpolation_Weight", Interpolation_Weight, 0, 5, 0.5);
        CLIMATIC_SolarForecast = this.Spinner(X_control, Y_control, 1, 0, 0, "Climate-based solar forecast", CLIMATIC_SolarForecast, 0, 1, 1);
        CLIMATIC_WeatherForecast = this.Spinner(X_control, Y_control, 1, 0, 0, "Climate-based temperature forecast", CLIMATIC_WeatherForecast, 0, 2, 1);
      }
      if (this.child == CHILD_POSTPROCESS_DEVELOPED) {
        Develop_Option = this.Spinner(X_control, Y_control, 1, 0, 0, "Develop_Option", Develop_Option, 0, 11, 1);
        Develop_DayHour = this.Spinner(X_control, Y_control, 1, 0, 0, "Develop_DayHour", Develop_DayHour, 0, 3, 1);

        STUDY.TrendJoinHours = this.Spinner(X_control, Y_control, 1, 0, 0, "Trend period hours", STUDY.TrendJoinHours, 1, 24 * 16, 1);
        STUDY.TrendJoinType = this.Spinner(X_control, Y_control, 1, 0, 0, "Weighted/equal trend", STUDY.TrendJoinType, -1, 1, 2, 1);

        Develop_AngleInclination = this.Spinner(X_control, Y_control, 1, 0, 0, "Inclination angle", Develop_AngleInclination, 0, 90, 5, 1);
        Develop_AngleOrientation = this.Spinner(X_control, Y_control, 1, 0, 0, "Orientation angle", Develop_AngleOrientation, 0, 360, 15, 1);
      }
      if (this.child == CHILD_POSTPROCESS_IMPACTS) {
        CurrentDataSource = this.Spinner(X_control, Y_control, 1, 0, 0, "Impact Source", CurrentDataSource, 0, MAXIMUM_dataID, 1);
        STUDY.ImpactLayer = this.Spinner(X_control, Y_control, 1, 0, 0, "Impact Min/50%/Max", STUDY.ImpactLayer, 0, 8, 1);
      }
    } else if (this.parent == PARENT_EXPORT) {

      if (this.child == CHILD_EXPORT_DATA) {

        STUDY.export_info_node = this.Spinner(X_control, Y_control, 1, 0, 0, "Export ASCII data", STUDY.export_info_node);
        STUDY.export_info_norm = this.Spinner(X_control, Y_control, 1, 0, 0, "Export ASCII statistics", STUDY.export_info_norm);
        STUDY.export_info_prob = this.Spinner(X_control, Y_control, 1, 0, 0, "Export ASCII probabilities", STUDY.export_info_prob);


        User3D.export_Scale = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-export.Scale", User3D.export_Scale, .001, 1000, -0.1);
        User3D.export_FlipZYaxis = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-export.FlipZYaxis", User3D.export_FlipZYaxis, 0, 1, 1);

        User3D.export_PrecisionVertex = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-export.PrecisionVertex", User3D.export_PrecisionVertex, 0, 6, 1);
        User3D.export_PrecisionVtexture = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-export.PrecisionVtexture", User3D.export_PrecisionVtexture, 0, 6, 1);
        User3D.export_PolyToPoly = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-export.PolyToPoly", User3D.export_PolyToPoly, 0, 1, 1);

        User3D.export_MaterialLibrary = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-export.MaterialLibrary", User3D.export_MaterialLibrary);
        User3D.export_BackSides = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-export.BackSides", User3D.export_BackSides);
        User3D.export_PaletteResolution = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-export.PaletteResolution", User3D.export_PaletteResolution, 32, 2048, -2, 1);
      }

      if (this.child == CHILD_EXPORT_MEDIA) {

        allSolidImpacts.record_IMG = this.Spinner(X_control, Y_control, 0, 0, 0, "Record SolidImpact in JPG", allSolidImpacts.record_IMG, 0, 1, 1);
        allSolidImpacts.record_PDF = this.Spinner(X_control, Y_control, 0, 0, 0, "Record SolidImpact in PDF", allSolidImpacts.record_PDF, 0, 1, 1);

        allSolarImpacts.record_IMG = this.Spinner(X_control, Y_control, 0, 0, 0, "Record Solar Analysis in JPG", allSolarImpacts.record_IMG, 0, 1, 1);
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

  String formatSpinnerValue (float value) {
    return nf(value, 0, 0);
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
      if (update1 != 0) {
        UI_caseBar.revise();
        STUDY.revise();
      }
      if (update2 != 0) WIN3D.revise();
      if (update3 != 0) WORLD.revise();
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
