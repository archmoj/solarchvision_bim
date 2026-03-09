class solarchvision_ROLLOUT {

  private final String[][] allRollouts = {
    {
      "Period & Scenarios", "Time", "Ranges", "Filters"
    }
    ,
    {
      "Location & Data", "Point", "Stations"
    }
    ,
    {
      "Geometries & Space", "Create", "Modify", "Solid", "Fractal Tree", "Environment", "Viewport", "Simulation", "Other"
    }
    ,
    {
      "Illustration Options", "2D-Layers", "2D-Colors", "3D-Solar", "3D-Spatial", "Selection"
    }
    ,
    {
      "Post-Processing", "Interpolation", "Developed", "Impacts"
    }
    ,
    {
      "Export Products", "Data", "Media"
    }
  };


  private final static String CLASS_STAMP = "ROLLOUT";

  int cX = 2 * SOLARCHVISION_pixel_W;
  int cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 0;
  int dX = 1 * SOLARCHVISION_pixel_H;
  int dY = 2 * SOLARCHVISION_pixel_H;
  float view_R = float(dY) / float(dX);
  float view_S = SOLARCHVISION_pixel_H / 325.0; //1; //0.75; // ?????

  boolean update = true;
  boolean include = true;

  int parent = 0; // 0: Time, 1: Location, 2: Geometry, etc.
  int child = 1; // number of the category inside e.g. 1, 2, ...


  void drawView () {

    stroke(255);
    fill(255);
    strokeWeight(0);
    rect(this.cX, this.cY, this.dX, this.dY);


    float h = 20 * this.view_S;

    X_control = this.cX;
    Y_control = this.cY;

    X_control += 307.5 * this.view_S;
    Y_control += 7.5 * this.view_S;

    if (this.parent >= allRollouts.length) {
      this.parent = allRollouts.length - 1;
    }

    if (this.child >= allRollouts[this.parent].length) {
      this.child = allRollouts[this.parent].length - 1;
    }

    if (this.parent < allRollouts.length) {

      for (int i = 0; i < allRollouts.length; i++) {

        float cx = this.cX + (150 * (i % 2) + 5) * this.view_S;
        float cy = Y_control;
        float cr = 6.75 * this.view_S;

        textAlign(LEFT, CENTER);

        if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, cx, cy - cr, cx + 150 * this.view_S, cy + cr)) {
          this.parent = i;
          this.child = 1; // <<<<<

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

        text(nf(i + 1, 0) + ":" + allRollouts[i][0], cx, cy);

        if (i % 2 == 1) Y_control += 15 * this.view_S;
      }

      noStroke();
      fill(127);
      rect(this.cX, Y_control, this.dX, 17.5 * ceil((allRollouts[this.parent].length - 1) / 3.0) * this.view_S);

      Y_control += 5 * this.view_S;

      for (int i = 1; i < allRollouts[this.parent].length; i++) {

        float cr = 6.75 * this.view_S;
        float cx = this.cX + (100 * ((i - 1) % 3) + 10) * this.view_S;
        float cy = Y_control + 0.5 * cr;

        textAlign(LEFT, CENTER);

        if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, cx, cy - cr, cx + 100 * this.view_S, cy + cr)) {
          this.child = i;

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

        text("[" + nf(i, 0) + "]" + allRollouts[this.parent][i], cx, cy);

        if (i % 3 == 0) Y_control += 15 * this.view_S;
      }

      if (allRollouts[this.parent].length % 3 != 1) Y_control += 15 * this.view_S;

      Y_control += 15 * this.view_S;
    }



    if (this.parent == 0) { // Period & Scenarios

      if (this.child == 1) { // Time
        STUDY.j_End = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 1, 0, "Number of days to plot", STUDY.j_End, 1, 365, 1), 1));

        STUDY.perDays = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 1, 0, "Day step", STUDY.perDays, 1, 182, 1), 1));

        STUDY.joinDays = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 1, 0, "Join days", STUDY.joinDays, 1, 182, 1), 1));

        TIME.date = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 1, 0, "Days past March equinox", TIME.date, 0, 364, 1), 1));

        //TIME.beginDay = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 1, 0, "Day of year (0-364)", TIME.beginDay, 0, 364, 1), 1));

        TIME.day = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 1, 0, "Start day", TIME.day, 1, 31, 1), 1));
        TIME.month = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 1, 0, "Start month", TIME.month, 1, 12, 1), 1));
        TIME.year = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 1, 0, "Start year", TIME.year, 1953, 2100, 1), 1));
      }

      if (this.child == 2) { // Ranges
        STUDY.i_Start = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Start hour", STUDY.i_Start, 0, 23, 1), 1));
        STUDY.i_End = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "End hour", STUDY.i_End, 0, 23, 1), 1));

        SampleYear_Start = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Start year", SampleYear_Start, CLIMATE_CWEEDS_start, CLIMATE_CLMREC_end, 1), 1));
        SampleYear_End = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "End year", SampleYear_End, CLIMATE_CWEEDS_start, CLIMATE_CLMREC_end, 1), 1));

        SampleMember_Start = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Start member", SampleMember_Start, ENSEMBLE_FORECAST_start, ENSEMBLE_FORECAST_end, 1), 1));
        SampleMember_End = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "End member", SampleMember_End, ENSEMBLE_FORECAST_start, ENSEMBLE_FORECAST_end, 1), 1));

        SampleStation_Start = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Start station", SampleStation_Start, ENSEMBLE_OBSERVED_start, ENSEMBLE_OBSERVED_end, 1), 1));
        SampleStation_End = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "End station", SampleStation_End, ENSEMBLE_OBSERVED_start, ENSEMBLE_OBSERVED_end, 1), 1));

        ENSEMBLE_OBSERVED_maxDays = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 1, "Forecast/Obs_maxDays", ENSEMBLE_OBSERVED_maxDays, 0, 31, 1), 1));
      }

      if (this.child == 3) { // Filters

        STUDY.skyScenario = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Sky status", STUDY.skyScenario, 1, 4, 1), 1));
        STUDY.filter = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Hourly/daily filter", STUDY.filter, 0, 1, 1), 1));
      }
    } else if (this.parent == 1) { // Location & data


      if (this.child == 1) { // Point

        //WORLD.autoView = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0,0,1, "Map Auto Fit", WORLD.autoView, 0, 1, 1), 1));
        //WORLD.VIEW_id = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0,0,1, "Map Viewport", WORLD.VIEW_id, 0, WORLD.numMaps - 1, 1), 1));

        LocationLAT = this.Spinner(X_control, Y_control, 0, 0, 1, "Latitude", LocationLAT, -85, 85, 0.01);
        LocationLON = this.Spinner(X_control, Y_control, 0, 0, 1, "Longitude", LocationLON, -180, 180, 0.01);
        //LocationELE = this.Spinner(X_control, Y_control, 0, 0, 1, "Elevation", LocationELE, -100, 8000, 1);
      }

      if (this.child == 2) { // Stations

        WORLD.displayAll_TMYEPW = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 1, "displayAll_TMYEPW", WORLD.displayAll_TMYEPW, 0, 2, 1), 1));
        //WORLD.displayNear_TMYEPW = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 1, "WORLD.displayNear_TMYEPW", WORLD.displayNear_TMYEPW, 0, 1, 1), 1));

        WORLD.displayAll_CWEEDS = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 1, "displayAll_CWEEDS", WORLD.displayAll_CWEEDS, 0, 2, 1), 1));
        //WORLD.displayNear_CWEEDS = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 1, "WORLD.displayNear_CWEEDS", WORLD.displayNear_CWEEDS, 0, 1, 1), 1));

        WORLD.displayAll_CLMREC = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 1, "displayAll_CLMREC", WORLD.displayAll_CLMREC, 0, 2, 1), 1));
        //WORLD.displayNear_CLMREC = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 1, "WORLD.displayNear_CLMREC", WORLD.displayNear_CLMREC, 0, 1, 1), 1));

        WORLD.displayAll_SWOB = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 1, "displayAll_SWOB", WORLD.displayAll_SWOB, 0, 2, 1), 1));
        //WORLD.displayNear_SWOB = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 1, "WORLD.displayNear_SWOB", WORLD.displayNear_SWOB, 0, 1, 1), 1));

        WORLD.displayAll_NAEFS = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 1, "displayAll_NAEFS", WORLD.displayAll_NAEFS, 0, 2, 1), 1));
        //WORLD.displayNear_NAEFS = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 1, "WORLD.displayNear_NAEFS", WORLD.displayNear_NAEFS, 0, 1, 1), 1));
      }
    } else if (this.parent == 2) { // Geometries & Space
      if (this.child == 1) { // Create

        //addToLastGroup = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "addToLastGroup", addToLastGroup, 0, 1, 1), 1));

        User3D.default_Material = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Material", User3D.default_Material, -1, 8, 1), 1));
        User3D.default_Tessellation = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Tessellation", User3D.default_Tessellation, 0, 6, 1), 1));
        User3D.default_Layer = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Layer", User3D.default_Layer, 0, 16, 1), 1));
        User3D.default_Visibility = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Visibility", User3D.default_Visibility, -1, 1, 1), 1));
        User3D.default_Weight = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0,0,0, "3D-create.Weight" , User3D.default_Weight, -20, 20, 1), 1));
        User3D.default_Closed = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0,0,0, "3D-create.Closed" , User3D.default_Closed, 0, 1, 1), 1));

        User3D.create_Orientation = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Orientation", User3D.create_Orientation, 0, 360, 15);

        User3D.create_Length = funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Length", User3D.create_Length, -50, 150, -2), 0.5);
        User3D.create_Width = funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Width", User3D.create_Width, -50, 150, -2), 0.5);
        User3D.create_Height = funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Height", User3D.create_Height, -50, 150, -2), 0.5);

        User3D.create_Volume = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Volume", User3D.create_Volume, 0, 25000, 1000);

        User3D.create_Snap = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Snap", User3D.create_Snap, 0, 1, 1), 1));

        User3D.create_SphereDegree = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.SphereDegree", User3D.create_SphereDegree, 0, 5, 1), 1));

        User3D.create_CylinderDegree = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.CylinderDegree", User3D.create_CylinderDegree, 3, 36, 1), 1));

        User3D.create_PolyDegree = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.PolyDegree", User3D.create_PolyDegree, 3, 36, 1), 1));

        User3D.create_Parametric_Type = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Parametric_Type", User3D.create_Parametric_Type, 1, 7, 1), 1));
        User3D.create_Person_Type = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Person_Type", User3D.create_Person_Type, 0, allModel2Ds.num_files_PEOPLE, 1), 1));
        User3D.create_Plant_Type = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Plant_Type", User3D.create_Plant_Type, 0, allModel2Ds.num_files_TREES, 1), 1));

      }

      if (this.child == 2) { // Modify

        User3D.modify_OpenningDepth = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-modify.OpenningDepth", User3D.modify_OpenningDepth, -10, 10, 0.1);
        User3D.modify_OpenningArea = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-modify.OpenningArea", User3D.modify_OpenningArea, 0, 1, 0.05);
        User3D.modify_OpenningDeviation = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-modify.OpenningDeviation", User3D.modify_OpenningDeviation, 0, 1, 0.05);

        User3D.modify_TessellateRows = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-modify.TessellateRows", User3D.modify_TessellateRows, 1, 100, 1), 1));
        User3D.modify_TessellateColumns = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-modify.TessellateColumns", User3D.modify_TessellateColumns, 1, 100, 1), 1));

        User3D.modify_OffsetAmount = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-modify.OffsetAmount", User3D.modify_OffsetAmount, 0, 25, 0.001);

        User3D.modify_WeldTreshold = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-modify.WeldTreshold", User3D.modify_WeldTreshold, 0, 10, 0.001);

        Select3D.softPower = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.softPower", Select3D.softPower, 0.125, 8, -2);
        Select3D.softRadius = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.softRadius", Select3D.softRadius, 0.01, 100, -2);

        Select3D.posVector = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.posVector", Select3D.posVector, 0, 3, 1), 1));
        Select3D.rotVector =  int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.rotVector", Select3D.rotVector, 0, 2, 1), 1));
        Select3D.scaleVector =  int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.scaleVector", Select3D.scaleVector, 0, 3, 1), 1));

        Select3D.posValue = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.posValue", Select3D.posValue, -50, 50, 1), 1));
        Select3D.rotValue = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.rotValue", Select3D.rotValue, -180, 180, 5), 5));
        Select3D.scaleValue = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.scaleValue", Select3D.scaleValue, -8, 8, 0.5), 0.5));

        Select3D.alignX = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.alignX", Select3D.alignX, -1, 1, 1), 1));
        Select3D.alignY = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.alignY", Select3D.alignY, -1, 1, 1), 1));
        Select3D.alignZ = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.alignZ", Select3D.alignZ, -1, 1, 1), 1));
      }

      if (this.child == 3) { // Solid

        //User3D.create_powRnd = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0,0,0, "powRnd" , User3D.create_powRnd, 0, 1, 1), 1));
        User3D.create_powAll = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.powAll", User3D.create_powAll, 0.5, CubePower, -2);
        User3D.create_powX = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.powX", User3D.create_powX, 0.5, CubePower, -2);
        User3D.create_powY = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.powY", User3D.create_powY, 0.5, CubePower, -2);
        User3D.create_powZ = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.powZ", User3D.create_powZ, 0.5, CubePower, -2);
      }


      if (this.child == 4) { // Fractal Tree

        User3D.create_Model1D_Type = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Type", User3D.create_Model1D_Type, 0, 0, 1), 1));
        User3D.create_Model1D_DegreeMax = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.DegreeMax", User3D.create_Model1D_DegreeMax, 0, 12, 1), 1));
        User3D.create_Model1D_Seed = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.Seed", User3D.create_Model1D_Seed, -1, 32767, 1), 1));
        User3D.create_Model1D_TrunkSize = funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.TrunkSize", User3D.create_Model1D_TrunkSize, 0, 10, 0.1), 0.1);
        User3D.create_Model1D_LeafSize = funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.LeafSize", User3D.create_Model1D_LeafSize, 0, 1, 0.01), 0.1);

        User3D.create_Model1D_BranchTilt = funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.BranchTilt", User3D.create_Model1D_BranchTilt, 0, 360, 5), 0.1);
        User3D.create_Model1D_BranchTwist = funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.BranchTwist", User3D.create_Model1D_BranchTwist, 0, 360, 5), 0.1);
        User3D.create_Model1D_BranchRatio = funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.BranchRatio", User3D.create_Model1D_BranchRatio, 0.05, 1, 0.05), 0.01);
        User3D.create_Model1D_TreeBase = funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-create.TreeBase", User3D.create_Model1D_TreeBase, 0, 4, 0.1), 0.01);
      }

      if (this.child == 5) { // Environment

        //Land3D.loadTextures = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.loadTextures", Land3D.loadTextures, 0, 1, 1), 1));
        //Land3D.loadMesh = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.loadMesh", Land3D.loadMesh, 0, 1, 1), 1));
        //Land3D.skipStart = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.skipStart", Land3D.skipStart, 0, Land3D.num_rows - 1, 1), 1));
        //Land3D.skipEnd = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.skipEnd", Land3D.skipEnd, 0, Land3D.num_rows - 1, 1), 1));
        //Land3D.displaySurface = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.displaySurface", Land3D.displaySurface, 0, 1, 1), 1));
        //Land3D.displayTexture = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.displayTexture", Land3D.displayTexture, 0, 1, 1), 1));
        //Land3D.displayPoints = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.displayPoints", Land3D.displayPoints, 0, 1, 1), 1));
        //Land3D.displayDepth = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.displayDepth", Land3D.displayDepth, 0, 1, 1), 1));

        //allModel2Ds.displayAll = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allModel2Ds.displayAll", allModel2Ds.displayAll, 0, 1, 1), 1));
        //allModel1Ds.displayAll = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allModel1Ds.displayAll", allModel1Ds.displayAll, 0, 1, 1), 1));
        //allModel1Ds.displayLeaves = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allModel1Ds.displayLeaves", allModel1Ds.displayLeaves, 0, 1, 1), 1));
        //allPolylines.displayAll = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allPolylines.displayAll", allPolylines.displayAll, 0, 1, 1), 1));
        //allFaces.displayAll = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allFaces.displayAll", allFaces.displayAll, 0, 1, 1), 1));

        //allSolids.displayAll = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allSolids.displayAll", allSolids.displayAll, 0, 1, 1), 1));

        //allSections.displayAll = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allSections.displayAll", allSections.displayAll, 0, 1, 1), 1));




        //allWindRoses.displayImage = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allWindRoses.displayImage", allWindRoses.displayImage, 0, 1, 1), 1));

        allWindRoses.scale = this.Spinner(X_control, Y_control, 0, 1, 0, "allWindRoses.scale", allWindRoses.scale, 50, 3200, -2);
        allWindRoses.RES = int(this.Spinner(X_control, Y_control, 0, 1, 0, "allWindRoses.resolution", allWindRoses.RES, 200, 600, 100));



        //Sky3D.displaySurface = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Sky3D.displaySurface", Sky3D.displaySurface, 0, 1, 1), 1));

        //Sun3D.displayPath = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.displayPath", Sun3D.displayPath, 0, 1, 1), 1));
        //Sun3D.displayPattern = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.displayPattern", Sun3D.displayPattern, 0, 1, 1), 1));
      }


      if (this.child == 6) { // Viewport

        WIN3D.currentCamera = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "currentCamera", WIN3D.currentCamera, 0, allCameras.num, 1), 1));

        WIN3D.CAM_clipNear = this.Spinner(X_control, Y_control, 0, 1, 0, "Camera_clipNear", WIN3D.CAM_clipNear, 0.01, 100, -2);
        WIN3D.CAM_clipFar = this.Spinner(X_control, Y_control, 0, 1, 0, "Camera_clipFar", WIN3D.CAM_clipFar, 1000, 2000000000, -2);

        //WIN3D.FacesShade = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0,1,0, "FacesShade", WIN3D.FacesShade, 0, SHADE.Options_num - 1, 1), 1));

        //allPoints.displayAll = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Create3D.displayVertices", allPoints.displayAll, 0, 1, 1), 1));
        //allFaces.displayEdges = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Create3D.displayEdges", allFaces.displayEdges, 0, 1, 1), 1));
        //allFaces.displayNormals = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Create3D.displayNormals", allFaces.displayNormals, 0, 1, 1), 1));

        //allCameras.displayAll = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allCameras.displayAll", allCameras.displayAll, 0, 1, 1), 1));
      }


      if (this.child == 7) { // Simulation

        IMPACTS_displayDay = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "IMPACTS_displayDay", IMPACTS_displayDay, 0, STUDY.j_End - STUDY.j_Start, 1), 1));

        //allSolarImpacts.displayImage = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allSolarImpacts.displayImage", allSolarImpacts.displayImage, 0, 1, 1), 1));
        //allSolidImpacts.displayImage = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allSolidImpacts.displayImage", allSolidImpacts.displayImage, 0, 1, 1), 1));

        allSolarImpacts.sectionType = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allSolarImpacts.sectionType", allSolarImpacts.sectionType, 0, 3, 1), 1));
        allSolidImpacts.sectionType = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allSolidImpacts.sectionType", allSolidImpacts.sectionType, 0, 3, 1), 1));


        allSolidImpacts.Grade = this.Spinner(X_control, Y_control, 0, 1, 0, "allSolidImpacts.Grade", allSolidImpacts.Grade, 0.0001, 64.0, -2);
        allSolidImpacts.Power = this.Spinner(X_control, Y_control, 0, 1, 0, "allSolidImpacts.Power", allSolidImpacts.Power, 0.0001, 64.0, -2);
        allSolidImpacts.R[allSolidImpacts.sectionType] = this.Spinner(X_control, Y_control, 0, 1, 0, "allSolidImpacts.R[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.R[allSolidImpacts.sectionType], -360, 360, -2);
        allSolidImpacts.Z[allSolidImpacts.sectionType] = this.Spinner(X_control, Y_control, 0, 1, 0, "allSolidImpacts.Z[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.Z[allSolidImpacts.sectionType], -1000, 1000, -2);
        allSolidImpacts.positionStep = this.Spinner(X_control, Y_control, 0, 1, 0, "allSolidImpacts.positionStep", allSolidImpacts.positionStep, 5, 80, -2);

        allSolidImpacts.U[allSolidImpacts.sectionType] = this.Spinner(X_control, Y_control, 0, 1, 0, "allSolidImpacts.U[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.U[allSolidImpacts.sectionType], 0.125, 3200, -2);
        allSolidImpacts.V[allSolidImpacts.sectionType] = this.Spinner(X_control, Y_control, 0, 1, 0, "allSolidImpacts.V[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.V[allSolidImpacts.sectionType], 0.125, 3200, -2);
        allSolidImpacts.X[allSolidImpacts.sectionType] = this.Spinner(X_control, Y_control, 0, 1, 0, "allSolidImpacts.X[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.X[allSolidImpacts.sectionType], -10000, 10000, -2);
        allSolidImpacts.Y[allSolidImpacts.sectionType] = this.Spinner(X_control, Y_control, 0, 1, 0, "allSolidImpacts.Y[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.Y[allSolidImpacts.sectionType], -10000, 10000, -2);


        allSolidImpacts.WindSpeed = this.Spinner(X_control, Y_control, 0, 1, 0, "allSolidImpacts.WindSpeed (m/s)", allSolidImpacts.WindSpeed, 1, 16, -2);
        allSolidImpacts.WindDirection = this.Spinner(X_control, Y_control, 0, 1, 0, "allSolidImpacts.WindDirection", allSolidImpacts.WindDirection, 0, 360, 15);


        allSolidImpacts.Process_subDivisions = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "allSolidImpacts.Process_subDivisions", allSolidImpacts.Process_subDivisions, 0, 3, 1), 1));

        //allSolidImpacts.displayPoints = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "allSolidImpacts.displayPoints", allSolidImpacts.displayPoints, 0, 1, 1), 1));
        //allSolidImpacts.displayLines = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "allSolidImpacts.displayLines", allSolidImpacts.displayLines, 0, 1, 1), 1));

        //allWindFlows.displayAll = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "allWindFlows.displayAll", allWindFlows.displayAll, 0, 1, 1), 1));
      }

      if (this.child == 8) { // Other

        allFaces.displayTessellation = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "3D-create.displayTessellation", allFaces.displayTessellation, 0, 4, 1), 1));

        Land3D.displayTessellation = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Land.displayTessellation", Land3D.displayTessellation, 0, 4, 1), 1));

        Sky3D.displayTessellation = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Sky.displayTessellation", Sky3D.displayTessellation, 0, 4, 1), 1));
        Sky3D.scale = this.Spinner(X_control, Y_control, 0, 1, 0, "Sky.scale", Sky3D.scale, 1, 4000000, -2);

        BIOSPHERE_drawResolution = funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "Biosphere_drawResolution", BIOSPHERE_drawResolution, 1, 10, 1), 1);

        //Tropo3D.displaySurface = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Tropo3D.displaySurface", Tropo3D.displaySurface, 0, 1, 1), 1));
        //Tropo3D.displayTexture = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Tropo3D.displayTexture", Tropo3D.displayTexture, 0, 1, 1), 1));

        //Earth3D.displaySurface = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Earth3D.displaySurface", Earth3D.displaySurface, 0, 1, 1), 1));
        //Earth3D.displayTexture = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Earth3D.displayTexture", Earth3D.displayTexture, 0, 1, 1), 1));

        //Moon3D.displaySurface = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Moon3D.displaySurface", Moon3D.displaySurface, 0, 1, 1), 1));
        //Moon3D.displayTexture = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Moon3D.displayTexture", Moon3D.displayTexture, 0, 1, 1), 1));

        //Sun3D.displaySurface = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.displaySurface", Sun3D.displaySurface, 0, 1, 1), 1));
        //Sun3D.displayTexture = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.displayTexture", Sun3D.displayTexture, 0, 1, 1), 1));

        Planetary_Magnification = this.Spinner(X_control, Y_control, 0, 1, 0, "Planetary_Magnification", Planetary_Magnification, 1, 100, 1.0);

        OBJECTS_scale = this.Spinner(X_control, Y_control, 0, 1, 0, "Objects_scale", OBJECTS_scale, 0.0000001, 1000000, -2);
      }

    } else if (this.parent == 3) { // Display Options

      if (this.child == 1) { // 2D-Layers
        STUDY.plotSetup = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Diagram setup", STUDY.plotSetup, -2, 8, 1), 1));

        //STUDY.update = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Redraw scene", STUDY.update, 0, 1, 1), 1));

        //STUDY.V_scale = this.Spinner(X_control, Y_control, 1, 0, 0, "V_scale[" + nf(CurrentLayer_id, 2) + "]", STUDY.V_scale, 0.0001, 10000, -pow(2.0, (1.0 / 2.0)));
        STUDY.V_scale = this.Spinner(X_control, Y_control, 1, 0, 0, "Scale (" + allLayers[CurrentLayer_id].descriptions[Language_EN] + ")", STUDY.V_scale, 0.0001, 10000, -pow(2.0, (1.0 / 2.0)));

        //STUDY.displayRaws = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Draw data", STUDY.displayRaws, 0, 1, 1), 1));
        //STUDY.displaySorted = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Draw sorted", STUDY.displaySorted, 0, 1, 1), 1));
        //STUDY.displayNormals = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Draw statistics", STUDY.displayNormals, 0, 1, 1), 1));
        //STUDY.displayProbs = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Draw probabilities", STUDY.displayProbs, 0, 1, 1), 1));
        STUDY.sumInterval = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Probabilities interval", STUDY.sumInterval, 1, 24, 1), 1));
        STUDY.LevelPix = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Probabilities range", STUDY.LevelPix, 2, 32, -2), 1));
      }

      if (this.child == 2) { // 2D-Colors

        //COLOR_STYLE_Current = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1,0,0, "Hourly color scheme", COLOR_STYLE_Current, -1, (COLOR_STYLE_Number - 1), 1), 1));

        STUDY.ACTIVE_pallet_CLR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.ACTIVE_pallet_CLR", STUDY.ACTIVE_pallet_CLR, -1, (COLOR_STYLE_Number - 1), 1), 1));
        STUDY.ACTIVE_pallet_DIR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.ACTIVE_pallet_DIR", STUDY.ACTIVE_pallet_DIR, -2, 2, 1), 1));
        STUDY.ACTIVE_pallet_MLT = this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.ACTIVE_pallet_MLT", STUDY.ACTIVE_pallet_MLT, 0.125, 8, -2);

        STUDY.PASSIVE_pallet_CLR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.PASSIVE_pallet_CLR", STUDY.PASSIVE_pallet_CLR, -1, (COLOR_STYLE_Number - 1), 1), 1));
        STUDY.PASSIVE_pallet_DIR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.PASSIVE_pallet_DIR", STUDY.PASSIVE_pallet_DIR, -2, 2, 2), 1));
        STUDY.PASSIVE_pallet_MLT = this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.PASSIVE_pallet_MLT", STUDY.PASSIVE_pallet_MLT, 0.125, 8, -2);

        STUDY.SORT_pallet_CLR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.SORT_pallet_CLR", STUDY.SORT_pallet_CLR, -1, (COLOR_STYLE_Number - 1), 1), 1));
        STUDY.SORT_pallet_DIR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.SORT_pallet_DIR", STUDY.SORT_pallet_DIR, -2, 2, 2), 1));
        STUDY.SORT_pallet_MLT = this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.SORT_pallet_MLT", STUDY.SORT_pallet_MLT, 0.125, 8, -2);

        STUDY.PROB_pallet_CLR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.PROB_pallet_CLR", STUDY.PROB_pallet_CLR, -1, (COLOR_STYLE_Number - 1), 1), 1));
        STUDY.PROB_pallet_DIR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.PROB_pallet_DIR", STUDY.PROB_pallet_DIR, -2, 2, 2), 1));
        STUDY.PROB_pallet_MLT = this.Spinner(X_control, Y_control, 1, 0, 0, "STUDY.PROB_pallet_MLT", STUDY.PROB_pallet_MLT, 0.125, 8, -2);

        STUDY.O_scale = this.Spinner(X_control, Y_control, 1, 0, 0, "Windose opacity scale", STUDY.O_scale, 1, 100, -pow(2.0, (1.0 / 4.0)));
      }

      if (this.child == 3) { // 3D-Solar

        allFaces.ACTIVE_pallet_CLR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allFaces.ACTIVE_pallet_CLR", allFaces.ACTIVE_pallet_CLR, -1, (COLOR_STYLE_Number - 1), 1), 1));
        allFaces.ACTIVE_pallet_DIR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allFaces.ACTIVE_pallet_DIR", allFaces.ACTIVE_pallet_DIR, -2, 2, 1), 1));
        allFaces.ACTIVE_pallet_MLT = this.Spinner(X_control, Y_control, 0, 1, 0, "allFaces.ACTIVE_pallet_MLT", allFaces.ACTIVE_pallet_MLT, 0.125, 8, -2);

        allFaces.PASSIVE_pallet_CLR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allFaces.PASSIVE_pallet_CLR", allFaces.PASSIVE_pallet_CLR, -1, (COLOR_STYLE_Number - 1), 1), 1));
        allFaces.PASSIVE_pallet_DIR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allFaces.PASSIVE_pallet_DIR", allFaces.PASSIVE_pallet_DIR, -2, 2, 2), 1));
        allFaces.PASSIVE_pallet_MLT = this.Spinner(X_control, Y_control, 0, 1, 0, "allFaces.PASSIVE_pallet_MLT", allFaces.PASSIVE_pallet_MLT, 0.125, 8, -2);

        Sky3D.ACTIVE_pallet_CLR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Sky3D.ACTIVE_pallet_CLR", Sky3D.ACTIVE_pallet_CLR, -1, (COLOR_STYLE_Number - 1), 1), 1));
        Sky3D.ACTIVE_pallet_DIR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Sky3D.ACTIVE_pallet_DIR", Sky3D.ACTIVE_pallet_DIR, -2, 2, 1), 1));
        Sky3D.ACTIVE_pallet_MLT = this.Spinner(X_control, Y_control, 0, 1, 0, "Sky3D.ACTIVE_pallet_MLT", Sky3D.ACTIVE_pallet_MLT, 0.125, 8, -2);

        Sky3D.PASSIVE_pallet_CLR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Sky3D.PASSIVE_pallet_CLR", Sky3D.PASSIVE_pallet_CLR, -1, (COLOR_STYLE_Number - 1), 1), 1));
        Sky3D.PASSIVE_pallet_DIR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Sky3D.PASSIVE_pallet_DIR", Sky3D.PASSIVE_pallet_DIR, -2, 2, 2), 1));
        Sky3D.PASSIVE_pallet_MLT = this.Spinner(X_control, Y_control, 0, 1, 0, "Sky3D.PASSIVE_pallet_MLT", Sky3D.PASSIVE_pallet_MLT, 0.125, 8, -2);

        Sun3D.ACTIVE_pallet_CLR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.ACTIVE_pallet_CLR", Sun3D.ACTIVE_pallet_CLR, -1, (COLOR_STYLE_Number - 1), 1), 1));
        Sun3D.ACTIVE_pallet_DIR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.ACTIVE_pallet_DIR", Sun3D.ACTIVE_pallet_DIR, -2, 2, 1), 1));
        Sun3D.ACTIVE_pallet_MLT = this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.ACTIVE_pallet_MLT", Sun3D.ACTIVE_pallet_MLT, 0.125, 8, -2);

        Sun3D.PASSIVE_pallet_CLR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.PASSIVE_pallet_CLR", Sun3D.PASSIVE_pallet_CLR, -1, (COLOR_STYLE_Number - 1), 1), 1));
        Sun3D.PASSIVE_pallet_DIR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.PASSIVE_pallet_DIR", Sun3D.PASSIVE_pallet_DIR, -2, 2, 2), 1));
        Sun3D.PASSIVE_pallet_MLT = this.Spinner(X_control, Y_control, 0, 1, 0, "Sun3D.PASSIVE_pallet_MLT", Sun3D.PASSIVE_pallet_MLT, 0.125, 8, -2);
      }




      if (this.child == 4) { // 3D-Solid

        allSolids.pallet_CLR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allSolids.pallet_CLR", allSolids.pallet_CLR, -1, (COLOR_STYLE_Number - 1), 1), 1));
        allSolids.pallet_DIR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allSolids.pallet_DIR", allSolids.pallet_DIR, -2, 2, 2), 1));
        allSolids.pallet_MLT = this.Spinner(X_control, Y_control, 0, 1, 0, "allSolids.pallet_MLT", allSolids.pallet_MLT, 0.0001, 64, -2);

        Land3D.pallet_CLR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.pallet_CLR", Land3D.pallet_CLR, -1, (COLOR_STYLE_Number - 1), 1), 1));
        Land3D.pallet_DIR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.pallet_DIR", Land3D.pallet_DIR, -2, 2, 2), 1));
        Land3D.pallet_MLT = this.Spinner(X_control, Y_control, 0, 1, 0, "Land3D.pallet_MLT", Land3D.pallet_MLT, 0.001, 0.5, -2);

        allWindFlows.pallet_CLR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allWindFlows.pallet_CLR", allWindFlows.pallet_CLR, -1, (COLOR_STYLE_Number - 1), 1), 1));
        allWindFlows.pallet_DIR = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 1, 0, "allWindFlows.pallet_DIR", allWindFlows.pallet_DIR, -2, 2, 2), 1));
        allWindFlows.pallet_MLT = this.Spinner(X_control, Y_control, 0, 1, 0, "allWindFlows.pallet_MLT", allWindFlows.pallet_MLT, 0.01, 1.0, -2);
      }


      if (this.child == 5) { // Selection

        //Select3D.Group_displayPivot = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Group_displayPivot", Select3D.Group_displayPivot, 0, 1, 1), 1));
        //Select3D.displayReferencePivot = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.displayReferencePivot", Select3D.displayReferencePivot, 0, 1, 1), 1));
        //Select3D.Group_displayBox = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Group_displayBox", Select3D.Group_displayBox, 0, 1, 1), 1));
        //Select3D.Group_displayEdges = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Group_displayEdges", Select3D.Group_displayEdges, 0, 1, 1), 1));

        //Select3D.Face_displayEdges = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Face_displayEdges", Select3D.Face_displayEdges, 0, 1, 1), 1));
        //Select3D.Face_displayVertexCount = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Face_displayVertexCount", Select3D.Face_displayVertexCount, 0, 1, 1), 1));
        //Select3D.Polyline_displayVertexCount = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Polyline_displayVertexCount", Select3D.Polyline_displayVertexCount, 0, 1, 1), 1));
        //Select3D.Vertex_displayVertices = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Vertex_displayVertices", Select3D.Vertex_displayVertices, 0, 1, 1), 1));
        //Select3D.Polyline_displayVertices = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Polyline_displayVertices", Select3D.Polyline_displayVertices, 0, 1, 1), 1));

        //Select3D.Model2D_displayEdges = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Model2D_displayEdges", Select3D.Model2D_displayEdges, 0, 1, 1), 1));
        //Select3D.Model1D_displayEdges = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Model1D_displayEdges", Select3D.Model1D_displayEdges, 0, 1, 1), 1));

        //Select3D.Solid_displayEdges = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Solid_displayEdges", Select3D.Solid_displayEdges, 0, 1, 1), 1));

        //Select3D.Section_displayEdges = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Section_displayEdges", Select3D.Section_displayEdges, 0, 1, 1), 1));

        //Select3D.Camera_displayEdges = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.Camera_displayEdges", Select3D.Camera_displayEdges, 0, 1, 1), 1));

        //Select3D.LandPoint_displayPoints = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-select.LandPoint_displayPoints", Select3D.LandPoint_displayPoints, 0, 1, 1), 1));
      }
    } else if (this.parent == 4) { // Post-Processing

      if (this.child == 1) { // Interpolation

        Interpolation_Weight = this.Spinner(X_control, Y_control, 1, 0, 0, "Interpolation_Weight", Interpolation_Weight, 0, 5, 0.5);
        CLIMATIC_SolarForecast = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Climate-based solar forecast", CLIMATIC_SolarForecast, 0, 1, 1), 1));
        CLIMATIC_WeatherForecast = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Climate-based temperature forecast", CLIMATIC_WeatherForecast, 0, 2, 1), 1));
      }
      if (this.child == 2) { // Developed
        Develop_Option = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Develop_Option", Develop_Option, 0, 11, 1), 1));
        Develop_DayHour = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Develop_DayHour", Develop_DayHour, 0, 3, 1), 1));

        STUDY.TrendJoinHours = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Trend period hours", STUDY.TrendJoinHours, 1, 24 * 16, 1), 1));
        STUDY.TrendJoinType = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Weighted/equal trend", STUDY.TrendJoinType, -1, 1, 2), 1));

        Develop_AngleInclination = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Inclination angle", Develop_AngleInclination, 0, 90, 5), 1));
        Develop_AngleOrientation = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Orientation angle", Develop_AngleOrientation, 0, 360, 15), 1));
      }
      if (this.child == 3) { // Impacts
        CurrentDataSource = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Impact Source", CurrentDataSource, 0, MAXIMUM_dataID, 1), 1));
        STUDY.ImpactLayer = int(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Impact Min/50%/Max", STUDY.ImpactLayer, 0, 8, 1), 1));
        //STUDY.Impacts_update = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "update impacts", STUDY.Impacts_update, 0, 1, 1), 1));
      }
    } else if (this.parent == 5) { // Export Products

      if (this.child == 1) { // Data

        //STUDY.export_info_node = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Export ASCII data", STUDY.export_info_node, 0, 1, 1), 1));
        //STUDY.export_info_norm = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Export ASCII statistics", STUDY.export_info_norm, 0, 1, 1), 1));
        //STUDY.export_info_prob = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 1, 0, 0, "Export ASCII probabilities", STUDY.export_info_prob, 0, 1, 1), 1));


        User3D.export_Scale = this.Spinner(X_control, Y_control, 0, 0, 0, "3D-export.Scale", User3D.export_Scale, .001, 1000, -0.1);
        User3D.export_FlipZYaxis = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-export.FlipZYaxis", User3D.export_FlipZYaxis, 0, 1, 1), 1));

        User3D.export_PrecisionVertex = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-export.PrecisionVertex", User3D.export_PrecisionVertex, 0, 6, 1), 1));
        User3D.export_PrecisionVtexture = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-export.PrecisionVtexture", User3D.export_PrecisionVtexture, 0, 6, 1), 1));
        User3D.export_PolyToPoly = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-export.PolyToPoly", User3D.export_PolyToPoly, 0, 1, 1), 1));

        //User3D.export_MaterialLibrary = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-export.MaterialLibrary", User3D.export_MaterialLibrary, 0, 1, 1), 1));
        //User3D.export_BackSides = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-export.BackSides", User3D.export_BackSides, 0, 1, 1), 1));
        //User3D.export_PalletResolution = boolean(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "3D-export.PalletResolution", User3D.export_PalletResolution, 32, 2048, -2), 1));
      }

      if (this.child == 2) { // Media

        allSolidImpacts.record_IMG = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "Record SolidImpact in JPG", allSolidImpacts.record_IMG, 0, 1, 1), 1));
        allSolidImpacts.record_PDF = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "Record SolidImpact in PDF", allSolidImpacts.record_PDF, 0, 1, 1), 1));

        allSolarImpacts.record_IMG = int(funcs.roundTo(this.Spinner(X_control, Y_control, 0, 0, 0, "Record Solar Analysis in JPG", allSolarImpacts.record_IMG, 0, 1, 1), 1));
      }

    }

    if (this.include) {
      if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, this.cX, this.cY, this.cX + this.dX, this.cY + this.dY)) {
        SOLARCHVISION_X_clicked = -1;
        SOLARCHVISION_Y_clicked = -1;
      }
    }
  }


  float Spinner (float x, float y, int update1, int update2, int update3, String caption, float v, float min_v, float max_v, float stp_v) {

    float new_value = v;

    if (new_value < min_v) new_value = min_v;
    if (new_value > max_v) new_value = max_v;

    float cx, cy, cr;
    float w1, w2, h, o, t_o;

    //w1 = 32.5 * ROLLOUT.view_S;
    //w2 = 142.5 * ROLLOUT.view_S;

    w1 = 100 * ROLLOUT.view_S;
    w2 = 200 * ROLLOUT.view_S;

    h = 16 * ROLLOUT.view_S;
    o = 2 * ROLLOUT.view_S;
    t_o = h * ROLLOUT.view_S / 8.0;

    Y_control += 25 * ROLLOUT.view_S; //(h + 2 * o) * 1.25;

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

    if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, cx - cr, cy - cr, cx + cr, cy + cr)) {
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

    if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, cx - cr, cy - cr, cx + cr, cy + cr)) {

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
    stroke(191);
    fill(191);
    rect(x - (w1 + w2) - o, y - (h / 2) - o, (w1 + w2) + 2 * o, h + 2 * o);

    stroke(255);
    fill(255);
    rect(x - w1, y - (h / 2), w1, h);

    float q = 0;

    if (max_v - min_v > 0.001) {
      q = (new_value - min_v) / (max_v - min_v);
    }

    if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, x - w1, y - (h / 2), x, y + (h / 2))) {

      q = 1;

      if (max_v - min_v > 0.001) {
        q = (SOLARCHVISION_X_clicked - (x - w1)) / w1;
      }

      new_value = min_v + q * (max_v - min_v);

      if (new_value < min_v) new_value = max_v;
      if (new_value > max_v) new_value = min_v;

      ROLLOUT.revise();
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
    textAlign(RIGHT, CENTER);
    if ((new_value == int(new_value)) || (new_value >= 100)) {
      text(String.valueOf(int(new_value)), x - t_o, y - t_o);
    } else {
      text(nf(new_value, 0, 0), x - t_o, y - t_o);
    }


    strokeWeight(0);
    stroke(0);
    fill(0);
    //textSize(1.0 * h);
    textSize(0.85 * h);
    //textAlign(RIGHT, CENTER); text(caption + ":", x - w1 - t_o, y - t_o);
    textAlign(LEFT, CENTER);
    text(caption + ":", x - w1 - w2 + t_o, y - t_o);

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
}
