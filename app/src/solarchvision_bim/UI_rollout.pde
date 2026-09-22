class solarchvision_UI_rollout {

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

  public solarchvision_UI_rollout () {
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

  void drawView () {

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
      this.drawView();
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
