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
  // ---- Value modifiers ------------------------------------------------
  // One function per this.Spinner(...) call in draw(), so its caption, min,
  // max, step and update1/update2/update3 flags are written exactly once
  // rather than once here and again in registerSpinnerActions(). Call with
  // created == 0 once, at registration time, to register the matching
  // command-line action; call with created == 1 from draw() to actually
  // render the spinner and get back its (possibly new) value. The two
  // branches stay independent - created == 1 never calls putValueAction,
  // and created == 0 never calls this.Spinner(...) - since calling
  // putValueAction's onChanged callback from inside this.Spinner(...)
  // itself would fire it before the caller applies the returned value to
  // the field, which is exactly the bug that had to be undone earlier.

  int valueModifier_Number_of_days_to_plot (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 365; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Number of days to plot",
        () -> (float) STUDY.j_End,
        (v) -> { STUDY.j_End = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyStudyJEnd);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Number of days to plot", STUDY.j_End, s1, s2, s3);
    }
    return out;
  }

  float valueModifier_Day_step (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1.0; //start
    float s2 = 182.5; //stop
    float s3 = 0.5; //step

    float out = 0;
    if (created == 0) {
      putValueAction("Day step",
        () -> STUDY.perDays,
        (v) -> { STUDY.perDays = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Day step", STUDY.perDays, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_Join_days (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 182; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Join days",
        () -> (float) STUDY.joinDays,
        (v) -> { STUDY.joinDays = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Join days", STUDY.joinDays, s1, s2, s3);
    }
    return out;
  }

  float valueModifier_Days_past_March_equinox (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 364; //stop
    float s3 = 1; //step

    float out = 0;
    if (created == 0) {
      putValueAction("Days past March equinox",
        () -> TIME.date,
        (v) -> { TIME.date = v; },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeDate);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Days past March equinox", TIME.date, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_Begin_day (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 31; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Begin day",
        () -> (float) TIME.day,
        (v) -> { TIME.day = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeChange);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Begin day", TIME.day, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_Begin_month (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 12; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Begin month",
        () -> (float) TIME.month,
        (v) -> { TIME.month = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeChange);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Begin month", TIME.month, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_Begin_year (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1953; //start
    int s2 = 2100; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Begin year",
        () -> (float) TIME.year,
        (v) -> { TIME.year = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeChange);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Begin year", TIME.year, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_Start_hour (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 23; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Start hour",
        () -> (float) STUDY.i_Start,
        (v) -> { STUDY.i_Start = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Start hour", STUDY.i_Start, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_End_hour (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 23; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("End hour",
        () -> (float) STUDY.i_End,
        (v) -> { STUDY.i_End = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "End hour", STUDY.i_End, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_Start_year (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Start year",
        () -> (float) SampleYear_Start,
        (v) -> { SampleYear_Start = int(v); },
        () -> (float) (CLIMATE_CWEEDS_start), () -> (float) (CLIMATE_CLMREC_end), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Start year", SampleYear_Start, CLIMATE_CWEEDS_start, CLIMATE_CLMREC_end, 1);
    }
    return out;
  }

  int valueModifier_End_year (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("End year",
        () -> (float) SampleYear_End,
        (v) -> { SampleYear_End = int(v); },
        () -> (float) (CLIMATE_CWEEDS_start), () -> (float) (CLIMATE_CLMREC_end), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "End year", SampleYear_End, CLIMATE_CWEEDS_start, CLIMATE_CLMREC_end, 1);
    }
    return out;
  }

  int valueModifier_Start_member (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Start member",
        () -> (float) SampleMember_Start,
        (v) -> { SampleMember_Start = int(v); },
        () -> (float) (ENSEMBLE_FORECAST_start), () -> (float) (ENSEMBLE_FORECAST_end), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Start member", SampleMember_Start, ENSEMBLE_FORECAST_start, ENSEMBLE_FORECAST_end, 1);
    }
    return out;
  }

  int valueModifier_End_member (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("End member",
        () -> (float) SampleMember_End,
        (v) -> { SampleMember_End = int(v); },
        () -> (float) (ENSEMBLE_FORECAST_start), () -> (float) (ENSEMBLE_FORECAST_end), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "End member", SampleMember_End, ENSEMBLE_FORECAST_start, ENSEMBLE_FORECAST_end, 1);
    }
    return out;
  }

  int valueModifier_Start_station (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Start station",
        () -> (float) SampleStation_Start,
        (v) -> { SampleStation_Start = int(v); },
        () -> (float) (ENSEMBLE_OBSERVED_start), () -> (float) (ENSEMBLE_OBSERVED_end), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Start station", SampleStation_Start, ENSEMBLE_OBSERVED_start, ENSEMBLE_OBSERVED_end, 1);
    }
    return out;
  }

  int valueModifier_End_station (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("End station",
        () -> (float) SampleStation_End,
        (v) -> { SampleStation_End = int(v); },
        () -> (float) (ENSEMBLE_OBSERVED_start), () -> (float) (ENSEMBLE_OBSERVED_end), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "End station", SampleStation_End, ENSEMBLE_OBSERVED_start, ENSEMBLE_OBSERVED_end, 1);
    }
    return out;
  }

  int valueModifier_Forecast_Obs_maxDays (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    int s1 = 0; //start
    int s2 = 31; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Forecast/Obs_maxDays",
        () -> (float) ENSEMBLE_OBSERVED_maxDays,
        (v) -> { ENSEMBLE_OBSERVED_maxDays = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Forecast/Obs_maxDays", ENSEMBLE_OBSERVED_maxDays, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_Sky_status (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 4; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Sky status",
        () -> (float) STUDY.skyScenario,
        (v) -> { STUDY.skyScenario = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sky status", STUDY.skyScenario, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_Hourly_daily_filter (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Hourly/daily filter",
        () -> (float) STUDY.filter,
        (v) -> { STUDY.filter = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Hourly/daily filter", STUDY.filter, s1, s2, s3);
    }
    return out;
  }

  float valueModifier_Latitude (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    float s1 = -85; //start
    float s2 = 85; //stop
    float s3 = 0.01; //step

    float out = 0;
    if (created == 0) {
      putValueAction("Latitude",
        () -> LocationLAT,
        (v) -> { LocationLAT = v; },
        s1, s2, s3,
        u1, u2, u3,
        react.applyLocationChange);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Latitude", LocationLAT, s1, s2, s3);
    }
    return out;
  }

  float valueModifier_Longitude (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    float s1 = -180; //start
    float s2 = 180; //stop
    float s3 = 0.01; //step

    float out = 0;
    if (created == 0) {
      putValueAction("Longitude",
        () -> LocationLON,
        (v) -> { LocationLON = v; },
        s1, s2, s3,
        u1, u2, u3,
        react.applyLocationChange);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Longitude", LocationLON, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_displayAll_TMYEPW (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    int s1 = 0; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("displayAll_TMYEPW",
        () -> (float) WORLD.displayAll_TMYEPW,
        (v) -> { WORLD.displayAll_TMYEPW = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "displayAll_TMYEPW", WORLD.displayAll_TMYEPW, s1, s2, s3);
    }
    return out;
  }

  boolean valueModifier_displayNear_TMYEPW (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("displayNear_TMYEPW",
        () -> (WORLD.displayNear_TMYEPW ? 1f : 0f),
        (v) -> { WORLD.displayNear_TMYEPW = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "displayNear_TMYEPW", WORLD.displayNear_TMYEPW);
    }
    return out;
  }

  int valueModifier_displayAll_CWEEDS (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    int s1 = 0; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("displayAll_CWEEDS",
        () -> (float) WORLD.displayAll_CWEEDS,
        (v) -> { WORLD.displayAll_CWEEDS = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "displayAll_CWEEDS", WORLD.displayAll_CWEEDS, s1, s2, s3);
    }
    return out;
  }

  boolean valueModifier_displayNear_CWEEDS (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("displayNear_CWEEDS",
        () -> (WORLD.displayNear_CWEEDS ? 1f : 0f),
        (v) -> { WORLD.displayNear_CWEEDS = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "displayNear_CWEEDS", WORLD.displayNear_CWEEDS);
    }
    return out;
  }

  int valueModifier_displayAll_CLMREC (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    int s1 = 0; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("displayAll_CLMREC",
        () -> (float) WORLD.displayAll_CLMREC,
        (v) -> { WORLD.displayAll_CLMREC = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "displayAll_CLMREC", WORLD.displayAll_CLMREC, s1, s2, s3);
    }
    return out;
  }

  boolean valueModifier_displayNear_CLMREC (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("displayNear_CLMREC",
        () -> (WORLD.displayNear_CLMREC ? 1f : 0f),
        (v) -> { WORLD.displayNear_CLMREC = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "displayNear_CLMREC", WORLD.displayNear_CLMREC);
    }
    return out;
  }

  int valueModifier_displayAll_SWOB (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    int s1 = 0; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("displayAll_SWOB",
        () -> (float) WORLD.displayAll_SWOB,
        (v) -> { WORLD.displayAll_SWOB = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "displayAll_SWOB", WORLD.displayAll_SWOB, s1, s2, s3);
    }
    return out;
  }

  boolean valueModifier_displayNear_SWOB (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("displayNear_SWOB",
        () -> (WORLD.displayNear_SWOB ? 1f : 0f),
        (v) -> { WORLD.displayNear_SWOB = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "displayNear_SWOB", WORLD.displayNear_SWOB);
    }
    return out;
  }

  int valueModifier_displayAll_NAEFS (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    int s1 = 0; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("displayAll_NAEFS",
        () -> (float) WORLD.displayAll_NAEFS,
        (v) -> { WORLD.displayAll_NAEFS = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "displayAll_NAEFS", WORLD.displayAll_NAEFS, s1, s2, s3);
    }
    return out;
  }

  boolean valueModifier_displayNear_NAEFS (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("displayNear_NAEFS",
        () -> (WORLD.displayNear_NAEFS ? 1f : 0f),
        (v) -> { WORLD.displayNear_NAEFS = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "displayNear_NAEFS", WORLD.displayNear_NAEFS);
    }
    return out;
  }

  boolean valueModifier_addToLastGroup (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("addToLastGroup",
        () -> (addToLastGroup ? 1f : 0f),
        (v) -> { addToLastGroup = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "addToLastGroup", addToLastGroup);
    }
    return out;
  }

  int valueModifier__3D_create_Material (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 8; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-create.Material",
        () -> (float) User3D.default_Material,
        (v) -> { User3D.default_Material = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Material", User3D.default_Material, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_create_Tessellation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 6; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-create.Tessellation",
        () -> (float) User3D.default_Tessellation,
        (v) -> { User3D.default_Tessellation = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Tessellation", User3D.default_Tessellation, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_create_Layer (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 16; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-create.Layer",
        () -> (float) User3D.default_Layer,
        (v) -> { User3D.default_Layer = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Layer", User3D.default_Layer, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_create_Visibility (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-create.Visibility",
        () -> (float) User3D.default_Visibility,
        (v) -> { User3D.default_Visibility = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Visibility", User3D.default_Visibility, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_create_Weight (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -20; //start
    int s2 = 20; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-create.Weight",
        () -> (float) User3D.default_Weight,
        (v) -> { User3D.default_Weight = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Weight", User3D.default_Weight, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_create_Closed (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-create.Closed",
        () -> (float) User3D.default_Closed,
        (v) -> { User3D.default_Closed = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Closed", User3D.default_Closed, s1, s2, s3);
    }
    return out;
  }

  float valueModifier__3D_create_Orientation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 360; //stop
    float s3 = 1; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("3D-create.Orientation",
        () -> User3D.create_Orientation,
        (v) -> { User3D.create_Orientation = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Orientation", User3D.create_Orientation, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier__3D_create_Length_rand_negative (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -100.0; //start
    float s2 = 1000.0; //stop
    float s3 = 1.0; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("3D-create.Length (rand negative)",
        () -> User3D.create_Length,
        (v) -> { User3D.create_Length = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Length (rand negative)", User3D.create_Length, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier__3D_create_Width_rand_negative (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -100.0; //start
    float s2 = 1000.0; //stop
    float s3 = 1.0; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("3D-create.Width (rand negative)",
        () -> User3D.create_Width,
        (v) -> { User3D.create_Width = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Width (rand negative)", User3D.create_Width, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier__3D_create_Height_rand_negative (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -100.0; //start
    float s2 = 1000.0; //stop
    float s3 = 1.0; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("3D-create.Height (rand negative)",
        () -> User3D.create_Height,
        (v) -> { User3D.create_Height = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Height (rand negative)", User3D.create_Height, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier__3D_create_Volume (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 1000000000; //stop
    float s3 = 1; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("3D-create.Volume",
        () -> User3D.create_Volume,
        (v) -> { User3D.create_Volume = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Volume", User3D.create_Volume, s1, s2, s3, s4);
    }
    return out;
  }

  int valueModifier__3D_create_Snap (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-create.Snap",
        () -> (float) User3D.create_Snap,
        (v) -> { User3D.create_Snap = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Snap", User3D.create_Snap, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_create_SphereDegree (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 5; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-create.SphereDegree",
        () -> (float) User3D.create_SphereDegree,
        (v) -> { User3D.create_SphereDegree = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.SphereDegree", User3D.create_SphereDegree, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_create_CylinderDegree (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 3; //start
    int s2 = 36; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-create.CylinderDegree",
        () -> (float) User3D.create_CylinderDegree,
        (v) -> { User3D.create_CylinderDegree = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.CylinderDegree", User3D.create_CylinderDegree, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_create_PolyDegree (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 3; //start
    int s2 = 36; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-create.PolyDegree",
        () -> (float) User3D.create_PolyDegree,
        (v) -> { User3D.create_PolyDegree = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.PolyDegree", User3D.create_PolyDegree, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_create_Parametric_Type (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 6; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-create.Parametric_Type",
        () -> (float) User3D.create_Parametric_Type,
        (v) -> { User3D.create_Parametric_Type = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Parametric_Type", User3D.create_Parametric_Type, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_create_Person_Type (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("3D-create.Person_Type",
        () -> (float) User3D.create_Person_Type,
        (v) -> { User3D.create_Person_Type = int(v); },
        () -> (float) (0), () -> (float) (allModel2Ds.num_files_PEOPLE), 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Person_Type", User3D.create_Person_Type, 0, allModel2Ds.num_files_PEOPLE, 1);
    }
    return out;
  }

  int valueModifier__3D_create_Plant_Type (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("3D-create.Plant_Type",
        () -> (float) User3D.create_Plant_Type,
        (v) -> { User3D.create_Plant_Type = int(v); },
        () -> (float) (0), () -> (float) (allModel2Ds.num_files_TREES), 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Plant_Type", User3D.create_Plant_Type, 0, allModel2Ds.num_files_TREES, 1);
    }
    return out;
  }

  float valueModifier__3D_modify_OpenningDepth (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -10; //start
    float s2 = 10; //stop
    float s3 = 0.1; //step

    float out = 0;
    if (created == 0) {
      putValueAction("3D-modify.OpenningDepth",
        () -> User3D.modify_OpenningDepth,
        (v) -> { User3D.modify_OpenningDepth = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-modify.OpenningDepth", User3D.modify_OpenningDepth, s1, s2, s3);
    }
    return out;
  }

  float valueModifier__3D_modify_OpenningArea (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 1; //stop
    float s3 = 0.05; //step

    float out = 0;
    if (created == 0) {
      putValueAction("3D-modify.OpenningArea",
        () -> User3D.modify_OpenningArea,
        (v) -> { User3D.modify_OpenningArea = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-modify.OpenningArea", User3D.modify_OpenningArea, s1, s2, s3);
    }
    return out;
  }

  float valueModifier__3D_modify_OpenningDeviation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 1; //stop
    float s3 = 0.05; //step

    float out = 0;
    if (created == 0) {
      putValueAction("3D-modify.OpenningDeviation",
        () -> User3D.modify_OpenningDeviation,
        (v) -> { User3D.modify_OpenningDeviation = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-modify.OpenningDeviation", User3D.modify_OpenningDeviation, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_modify_TessellateRows (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 100; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-modify.TessellateRows",
        () -> (float) User3D.modify_TessellateRows,
        (v) -> { User3D.modify_TessellateRows = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-modify.TessellateRows", User3D.modify_TessellateRows, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_modify_TessellateColumns (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 100; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-modify.TessellateColumns",
        () -> (float) User3D.modify_TessellateColumns,
        (v) -> { User3D.modify_TessellateColumns = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-modify.TessellateColumns", User3D.modify_TessellateColumns, s1, s2, s3);
    }
    return out;
  }

  float valueModifier__3D_modify_OffsetAmount (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 25; //stop
    float s3 = 0.001; //step

    float out = 0;
    if (created == 0) {
      putValueAction("3D-modify.OffsetAmount",
        () -> User3D.modify_OffsetAmount,
        (v) -> { User3D.modify_OffsetAmount = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-modify.OffsetAmount", User3D.modify_OffsetAmount, s1, s2, s3);
    }
    return out;
  }

  float valueModifier__3D_modify_WeldTreshold (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 10; //stop
    float s3 = 0.001; //step

    float out = 0;
    if (created == 0) {
      putValueAction("3D-modify.WeldTreshold",
        () -> User3D.modify_WeldTreshold,
        (v) -> { User3D.modify_WeldTreshold = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-modify.WeldTreshold", User3D.modify_WeldTreshold, s1, s2, s3);
    }
    return out;
  }

  float valueModifier__3D_select_softPower (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8.0; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("3D-select.softPower",
        () -> Select3D.softPower,
        (v) -> { Select3D.softPower = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.softSelectionChanged);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.softPower", Select3D.softPower, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier__3D_select_softRadius (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.01; //start
    float s2 = 100; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("3D-select.softRadius",
        () -> Select3D.softRadius,
        (v) -> { Select3D.softRadius = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.softSelectionChanged);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.softRadius", Select3D.softRadius, s1, s2, s3, s4);
    }
    return out;
  }

  int valueModifier__3D_select_posVector (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 3; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-select.posVector",
        () -> (float) Select3D.posVector,
        (v) -> { Select3D.posVector = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.posVector", Select3D.posVector, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_select_rotVector (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-select.rotVector",
        () -> (float) Select3D.rotVector,
        (v) -> { Select3D.rotVector = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.rotVector", Select3D.rotVector, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_select_scaleVector (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 3; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-select.scaleVector",
        () -> (float) Select3D.scaleVector,
        (v) -> { Select3D.scaleVector = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.scaleVector", Select3D.scaleVector, s1, s2, s3);
    }
    return out;
  }

  float valueModifier__3D_select_posValue (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -50.0; //start
    float s2 = 50.0; //stop
    float s3 = 1.0; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("3D-select.posValue",
        () -> Select3D.posValue,
        (v) -> { Select3D.posValue = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.applyPosValue);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.posValue", Select3D.posValue, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier__3D_select_rotValue (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -180.0; //start
    float s2 = 180.0; //stop
    float s3 = 1.0; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("3D-select.rotValue",
        () -> Select3D.rotValue,
        (v) -> { Select3D.rotValue = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.applyRotValue);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.rotValue", Select3D.rotValue, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier__3D_select_scaleValue (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -8.0; //start
    float s2 = 8.0; //stop
    float s3 = 1.0; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("3D-select.scaleValue",
        () -> Select3D.scaleValue,
        (v) -> { Select3D.scaleValue = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.applyScaleValue);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.scaleValue", Select3D.scaleValue, s1, s2, s3, s4);
    }
    return out;
  }

  int valueModifier__3D_select_alignX (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-select.alignX",
        () -> (float) Select3D.alignX,
        (v) -> { Select3D.alignX = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.selectionChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.alignX", Select3D.alignX, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_select_alignY (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-select.alignY",
        () -> (float) Select3D.alignY,
        (v) -> { Select3D.alignY = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.selectionChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.alignY", Select3D.alignY, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_select_alignZ (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-select.alignZ",
        () -> (float) Select3D.alignZ,
        (v) -> { Select3D.alignZ = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.selectionChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.alignZ", Select3D.alignZ, s1, s2, s3);
    }
    return out;
  }

  float valueModifier__3D_create_powAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float out = 0;
    if (created == 0) {
      putValueAction("3D-create.powAll",
        () -> User3D.create_powAll,
        (v) -> { User3D.create_powAll = v; },
        () -> (float) (0.5), () -> (float) (CubePower), 0.001,
        u1, u2, u3,
        react.applyCreatePowAll);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.powAll", User3D.create_powAll, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }

  float valueModifier__3D_create_powX (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float out = 0;
    if (created == 0) {
      putValueAction("3D-create.powX",
        () -> User3D.create_powX,
        (v) -> { User3D.create_powX = v; },
        () -> (float) (0.5), () -> (float) (CubePower), 0.001,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.powX", User3D.create_powX, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }

  float valueModifier__3D_create_powY (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float out = 0;
    if (created == 0) {
      putValueAction("3D-create.powY",
        () -> User3D.create_powY,
        (v) -> { User3D.create_powY = v; },
        () -> (float) (0.5), () -> (float) (CubePower), 0.001,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.powY", User3D.create_powY, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }

  float valueModifier__3D_create_powZ (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float out = 0;
    if (created == 0) {
      putValueAction("3D-create.powZ",
        () -> User3D.create_powZ,
        (v) -> { User3D.create_powZ = v; },
        () -> (float) (0.5), () -> (float) (CubePower), 0.001,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.powZ", User3D.create_powZ, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }

  int valueModifier__3D_create_Type (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 0; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-create.Type",
        () -> (float) User3D.create_Model1D_Type,
        (v) -> { User3D.create_Model1D_Type = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Type", User3D.create_Model1D_Type, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_create_DegreeMax (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 12; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-create.DegreeMax",
        () -> (float) User3D.create_Model1D_DegreeMax,
        (v) -> { User3D.create_Model1D_DegreeMax = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.DegreeMax", User3D.create_Model1D_DegreeMax, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_create_Seed (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 32767; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-create.Seed",
        () -> (float) User3D.create_Model1D_Seed,
        (v) -> { User3D.create_Model1D_Seed = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Seed", User3D.create_Model1D_Seed, s1, s2, s3);
    }
    return out;
  }

  float valueModifier__3D_create_TrunkSize (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 10; //stop
    float s3 = 0.1; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.1; //round

    float out = 0;
    if (created == 0) {
      putValueAction("3D-create.TrunkSize",
        () -> User3D.create_Model1D_TrunkSize,
        (v) -> { User3D.create_Model1D_TrunkSize = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.TrunkSize", User3D.create_Model1D_TrunkSize, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier__3D_create_LeafSize (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 1; //stop
    float s3 = 0.01; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.1; //round

    float out = 0;
    if (created == 0) {
      putValueAction("3D-create.LeafSize",
        () -> User3D.create_Model1D_LeafSize,
        (v) -> { User3D.create_Model1D_LeafSize = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.LeafSize", User3D.create_Model1D_LeafSize, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier__3D_create_BranchTilt (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 360; //stop
    float s3 = 5; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.1; //round

    float out = 0;
    if (created == 0) {
      putValueAction("3D-create.BranchTilt",
        () -> User3D.create_Model1D_BranchTilt,
        (v) -> { User3D.create_Model1D_BranchTilt = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.BranchTilt", User3D.create_Model1D_BranchTilt, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier__3D_create_BranchTwist (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 360; //stop
    float s3 = 5; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.1; //round

    float out = 0;
    if (created == 0) {
      putValueAction("3D-create.BranchTwist",
        () -> User3D.create_Model1D_BranchTwist,
        (v) -> { User3D.create_Model1D_BranchTwist = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.BranchTwist", User3D.create_Model1D_BranchTwist, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier__3D_create_BranchRatio (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.05; //start
    float s2 = 1; //stop
    float s3 = 0.05; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.01; //round

    float out = 0;
    if (created == 0) {
      putValueAction("3D-create.BranchRatio",
        () -> User3D.create_Model1D_BranchRatio,
        (v) -> { User3D.create_Model1D_BranchRatio = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.BranchRatio", User3D.create_Model1D_BranchRatio, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier__3D_create_TreeBase (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 4; //stop
    float s3 = 0.1; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.01; //round

    float out = 0;
    if (created == 0) {
      putValueAction("3D-create.TreeBase",
        () -> User3D.create_Model1D_TreeBase,
        (v) -> { User3D.create_Model1D_TreeBase = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.TreeBase", User3D.create_Model1D_TreeBase, s1, s2, s3, s4);
    }
    return out;
  }

  boolean valueModifier_Land3D_loadTextures (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Land3D.loadTextures",
        () -> (Land3D.loadTextures ? 1f : 0f),
        (v) -> { Land3D.loadTextures = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.applyLandLoadTextures);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.loadTextures", Land3D.loadTextures);
    }
    return out;
  }

  boolean valueModifier_Land3D_loadMesh (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Land3D.loadMesh",
        () -> (Land3D.loadMesh ? 1f : 0f),
        (v) -> { Land3D.loadMesh = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.applyLandLoadMesh);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.loadMesh", Land3D.loadMesh);
    }
    return out;
  }

  int valueModifier_Land3D_skipStart (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Land3D.skipStart",
        () -> (float) Land3D.skipStart,
        (v) -> { Land3D.skipStart = int(v); },
        () -> (float) (0), () -> (float) (Land3D.num_rows - 1), 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.skipStart", Land3D.skipStart, 0, Land3D.num_rows - 1, 1);
    }
    return out;
  }

  int valueModifier_Land3D_skipEnd (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Land3D.skipEnd",
        () -> (float) Land3D.skipEnd,
        (v) -> { Land3D.skipEnd = int(v); },
        () -> (float) (0), () -> (float) (Land3D.num_rows - 1), 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.skipEnd", Land3D.skipEnd, 0, Land3D.num_rows - 1, 1);
    }
    return out;
  }

  boolean valueModifier_Land3D_displaySurface (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Land3D.displaySurface",
        () -> (Land3D.displaySurface ? 1f : 0f),
        (v) -> { Land3D.displaySurface = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.displaySurface", Land3D.displaySurface);
    }
    return out;
  }

  boolean valueModifier_Land3D_displayTexture (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Land3D.displayTexture",
        () -> (Land3D.displayTexture ? 1f : 0f),
        (v) -> { Land3D.displayTexture = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.displayTexture", Land3D.displayTexture);
    }
    return out;
  }

  boolean valueModifier_Land3D_displayPoints (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Land3D.displayPoints",
        () -> (Land3D.displayPoints ? 1f : 0f),
        (v) -> { Land3D.displayPoints = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.displayPoints", Land3D.displayPoints);
    }
    return out;
  }

  boolean valueModifier_Land3D_displayDepth (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Land3D.displayDepth",
        () -> (Land3D.displayDepth ? 1f : 0f),
        (v) -> { Land3D.displayDepth = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.displayDepth", Land3D.displayDepth);
    }
    return out;
  }

  boolean valueModifier_model2Ds_displayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("model2Ds.displayAll",
        () -> (allModel2Ds.displayAll ? 1f : 0f),
        (v) -> { allModel2Ds.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "model2Ds.displayAll", allModel2Ds.displayAll);
    }
    return out;
  }

  boolean valueModifier_model1Ds_displayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("model1Ds.displayAll",
        () -> (allModel1Ds.displayAll ? 1f : 0f),
        (v) -> { allModel1Ds.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "model1Ds.displayAll", allModel1Ds.displayAll);
    }
    return out;
  }

  boolean valueModifier_model1Ds_displayLeaves (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("model1Ds.displayLeaves",
        () -> (allModel1Ds.displayLeaves ? 1f : 0f),
        (v) -> { allModel1Ds.displayLeaves = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "model1Ds.displayLeaves", allModel1Ds.displayLeaves);
    }
    return out;
  }

  boolean valueModifier_polylines_displayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("polylines.displayAll",
        () -> (allPolylines.displayAll ? 1f : 0f),
        (v) -> { allPolylines.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "polylines.displayAll", allPolylines.displayAll);
    }
    return out;
  }

  boolean valueModifier_faces_displayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("faces.displayAll",
        () -> (allFaces.displayAll ? 1f : 0f),
        (v) -> { allFaces.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "faces.displayAll", allFaces.displayAll);
    }
    return out;
  }

  boolean valueModifier_solids_displayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("solids.displayAll",
        () -> (allSolids.displayAll ? 1f : 0f),
        (v) -> { allSolids.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solids.displayAll", allSolids.displayAll);
    }
    return out;
  }

  boolean valueModifier_sections_displayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("sections.displayAll",
        () -> (allSections.displayAll ? 1f : 0f),
        (v) -> { allSections.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "sections.displayAll", allSections.displayAll);
    }
    return out;
  }

  boolean valueModifier_windRoses_displayImage (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("windRoses.displayImage",
        () -> (allWindRoses.displayImage ? 1f : 0f),
        (v) -> { allWindRoses.displayImage = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "windRoses.displayImage", allWindRoses.displayImage);
    }
    return out;
  }

  float valueModifier_windRoses_scale (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 50; //start
    float s2 = 3200; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("windRoses.scale",
        () -> allWindRoses.scale,
        (v) -> { allWindRoses.scale = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "windRoses.scale", allWindRoses.scale, s1, s2, s3, s4);
    }
    return out;
  }

  boolean valueModifier_Sky3D_displaySurface (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Sky3D.displaySurface",
        () -> (Sky3D.displaySurface ? 1f : 0f),
        (v) -> { Sky3D.displaySurface = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D.displaySurface", Sky3D.displaySurface);
    }
    return out;
  }

  boolean valueModifier_Sun3D_displayPath (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Sun3D.displayPath",
        () -> (Sun3D.displayPath ? 1f : 0f),
        (v) -> { Sun3D.displayPath = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.displayPath", Sun3D.displayPath);
    }
    return out;
  }

  boolean valueModifier_Sun3D_displayPattern (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Sun3D.displayPattern",
        () -> (Sun3D.displayPattern ? 1f : 0f),
        (v) -> { Sun3D.displayPattern = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.displayPattern", Sun3D.displayPattern);
    }
    return out;
  }

  int valueModifier_currentCamera (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("currentCamera",
        () -> (float) WIN3D.currentCamera,
        (v) -> { WIN3D.currentCamera = int(v); },
        () -> (float) (0), () -> (float) (allCameras.num), 1,
        u1, u2, u3,
        react.applyCurrentCamera);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "currentCamera", WIN3D.currentCamera, 0, allCameras.num, 1);
    }
    return out;
  }

  float valueModifier_Camera_clipNear (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.01; //start
    float s2 = 100; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Camera_clipNear",
        () -> WIN3D.CAM_clipNear,
        (v) -> { WIN3D.CAM_clipNear = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Camera_clipNear", WIN3D.CAM_clipNear, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_Camera_clipFar (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1000; //start
    float s2 = 2000000000; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Camera_clipFar",
        () -> WIN3D.CAM_clipFar,
        (v) -> { WIN3D.CAM_clipFar = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Camera_clipFar", WIN3D.CAM_clipFar, s1, s2, s3, s4);
    }
    return out;
  }

  boolean valueModifier_Create3D_displayVertices (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Create3D.displayVertices",
        () -> (allPoints.displayAll ? 1f : 0f),
        (v) -> { allPoints.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Create3D.displayVertices", allPoints.displayAll);
    }
    return out;
  }

  boolean valueModifier_Create3D_displayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Create3D.displayEdges",
        () -> (allFaces.displayEdges ? 1f : 0f),
        (v) -> { allFaces.displayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Create3D.displayEdges", allFaces.displayEdges);
    }
    return out;
  }

  boolean valueModifier_Create3D_displayNormals (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Create3D.displayNormals",
        () -> (allFaces.displayNormals ? 1f : 0f),
        (v) -> { allFaces.displayNormals = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Create3D.displayNormals", allFaces.displayNormals);
    }
    return out;
  }

  boolean valueModifier_cameras_displayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("cameras.displayAll",
        () -> (allCameras.displayAll ? 1f : 0f),
        (v) -> { allCameras.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "cameras.displayAll", allCameras.displayAll);
    }
    return out;
  }

  int valueModifier_IMPACTS_displayDay (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("IMPACTS_displayDay",
        () -> (float) IMPACTS_displayDay,
        (v) -> { IMPACTS_displayDay = int(v); },
        () -> (float) (0), () -> (float) (STUDY.j_End - STUDY.j_Start), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "IMPACTS_displayDay", IMPACTS_displayDay, 0, STUDY.j_End - STUDY.j_Start, 1);
    }
    return out;
  }

  boolean valueModifier_solarImpacts_displayImage (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("solarImpacts.displayImage",
        () -> (allSolarImpacts.displayImage ? 1f : 0f),
        (v) -> { allSolarImpacts.displayImage = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solarImpacts.displayImage", allSolarImpacts.displayImage);
    }
    return out;
  }

  boolean valueModifier_solidImpacts_displayImage (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("solidImpacts.displayImage",
        () -> (allSolidImpacts.displayImage ? 1f : 0f),
        (v) -> { allSolidImpacts.displayImage = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.displayImage", allSolidImpacts.displayImage);
    }
    return out;
  }

  int valueModifier_solarImpacts_sectionType (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 3; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("solarImpacts.sectionType",
        () -> (float) allSolarImpacts.sectionType,
        (v) -> { allSolarImpacts.sectionType = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solarImpacts.sectionType", allSolarImpacts.sectionType, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_solidImpacts_sectionType (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 3; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("solidImpacts.sectionType",
        () -> (float) allSolidImpacts.sectionType,
        (v) -> { allSolidImpacts.sectionType = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.sectionType", allSolidImpacts.sectionType, s1, s2, s3);
    }
    return out;
  }

  float valueModifier_solidImpacts_Grade (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.0001; //start
    float s2 = 64.0; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("solidImpacts.Grade",
        () -> allSolidImpacts.Grade,
        (v) -> { allSolidImpacts.Grade = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.Grade", allSolidImpacts.Grade, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_solidImpacts_Power (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.0001; //start
    float s2 = 64.0; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("solidImpacts.Power",
        () -> allSolidImpacts.Power,
        (v) -> { allSolidImpacts.Power = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.Power", allSolidImpacts.Power, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_solidImpacts_R (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -360; //start
    float s2 = 360; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("solidImpacts.R",
        () -> allSolidImpacts.R[allSolidImpacts.sectionType],
        (v) -> { allSolidImpacts.R[allSolidImpacts.sectionType] = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.R[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.R[allSolidImpacts.sectionType], s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_solidImpacts_Z (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -1000; //start
    float s2 = 1000; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("solidImpacts.Z",
        () -> allSolidImpacts.Z[allSolidImpacts.sectionType],
        (v) -> { allSolidImpacts.Z[allSolidImpacts.sectionType] = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.Z[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.Z[allSolidImpacts.sectionType], s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_solidImpacts_positionStep (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 5; //start
    float s2 = 80; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("solidImpacts.positionStep",
        () -> allSolidImpacts.positionStep,
        (v) -> { allSolidImpacts.positionStep = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.positionStep", allSolidImpacts.positionStep, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_solidImpacts_U (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 3200; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("solidImpacts.U",
        () -> allSolidImpacts.U[allSolidImpacts.sectionType],
        (v) -> { allSolidImpacts.U[allSolidImpacts.sectionType] = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.U[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.U[allSolidImpacts.sectionType], s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_solidImpacts_V (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 3200; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("solidImpacts.V",
        () -> allSolidImpacts.V[allSolidImpacts.sectionType],
        (v) -> { allSolidImpacts.V[allSolidImpacts.sectionType] = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.V[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.V[allSolidImpacts.sectionType], s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_solidImpacts_X (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -10000; //start
    float s2 = 10000; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("solidImpacts.X",
        () -> allSolidImpacts.X[allSolidImpacts.sectionType],
        (v) -> { allSolidImpacts.X[allSolidImpacts.sectionType] = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.X[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.X[allSolidImpacts.sectionType], s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_solidImpacts_Y (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -10000; //start
    float s2 = 10000; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("solidImpacts.Y",
        () -> allSolidImpacts.Y[allSolidImpacts.sectionType],
        (v) -> { allSolidImpacts.Y[allSolidImpacts.sectionType] = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.Y[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.Y[allSolidImpacts.sectionType], s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_solidImpacts_WindSpeed_m_s (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1; //start
    float s2 = 16; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("solidImpacts.WindSpeed (m/s)",
        () -> allSolidImpacts.WindSpeed,
        (v) -> { allSolidImpacts.WindSpeed = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.WindSpeed (m/s)", allSolidImpacts.WindSpeed, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_solidImpacts_WindDirection (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 360; //stop
    float s3 = 15; //step

    float out = 0;
    if (created == 0) {
      putValueAction("solidImpacts.WindDirection",
        () -> allSolidImpacts.WindDirection,
        (v) -> { allSolidImpacts.WindDirection = v; },
        s1, s2, s3,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.WindDirection", allSolidImpacts.WindDirection, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_solidImpacts_Process_subDivisions (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 3; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("solidImpacts.Process_subDivisions",
        () -> (float) allSolidImpacts.Process_subDivisions,
        (v) -> { allSolidImpacts.Process_subDivisions = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.Process_subDivisions", allSolidImpacts.Process_subDivisions, s1, s2, s3);
    }
    return out;
  }

  boolean valueModifier_solidImpacts_displayPoints (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("solidImpacts.displayPoints",
        () -> (allSolidImpacts.displayPoints ? 1f : 0f),
        (v) -> { allSolidImpacts.displayPoints = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.displayPoints", allSolidImpacts.displayPoints);
    }
    return out;
  }

  boolean valueModifier_solidImpacts_displayLines (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("solidImpacts.displayLines",
        () -> (allSolidImpacts.displayLines ? 1f : 0f),
        (v) -> { allSolidImpacts.displayLines = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.displayLines", allSolidImpacts.displayLines);
    }
    return out;
  }

  boolean valueModifier_windFlows_displayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("windFlows.displayAll",
        () -> (allWindFlows.displayAll ? 1f : 0f),
        (v) -> { allWindFlows.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "windFlows.displayAll", allWindFlows.displayAll);
    }
    return out;
  }

  int valueModifier__3D_create_displayTessellation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 4; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-create.displayTessellation",
        () -> (float) allFaces.displayTessellation,
        (v) -> { allFaces.displayTessellation = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.displayTessellation", allFaces.displayTessellation, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_Land_displayTessellation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 4; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Land.displayTessellation",
        () -> (float) Land3D.displayTessellation,
        (v) -> { Land3D.displayTessellation = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Land.displayTessellation", Land3D.displayTessellation, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_Sky_displayTessellation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 4; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Sky.displayTessellation",
        () -> (float) Sky3D.displayTessellation,
        (v) -> { Sky3D.displayTessellation = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sky.displayTessellation", Sky3D.displayTessellation, s1, s2, s3);
    }
    return out;
  }

  float valueModifier_Sky_scale (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1; //start
    float s2 = 4000000; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Sky.scale",
        () -> Sky3D.radius,
        (v) -> { Sky3D.radius = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sky.scale", Sky3D.radius, s1, s2, s3, s4);
    }
    return out;
  }

  boolean valueModifier_Tropo3D_displaySurface (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Tropo3D.displaySurface",
        () -> (Tropo3D.displaySurface ? 1f : 0f),
        (v) -> { Tropo3D.displaySurface = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Tropo3D.displaySurface", Tropo3D.displaySurface);
    }
    return out;
  }

  boolean valueModifier_Tropo3D_displayTexture (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Tropo3D.displayTexture",
        () -> (Tropo3D.displayTexture ? 1f : 0f),
        (v) -> { Tropo3D.displayTexture = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Tropo3D.displayTexture", Tropo3D.displayTexture);
    }
    return out;
  }

  boolean valueModifier_Earth3D_displaySurface (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Earth3D.displaySurface",
        () -> (Earth3D.displaySurface ? 1f : 0f),
        (v) -> { Earth3D.displaySurface = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Earth3D.displaySurface", Earth3D.displaySurface);
    }
    return out;
  }

  boolean valueModifier_Earth3D_displayTexture (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Earth3D.displayTexture",
        () -> (Earth3D.displayTexture ? 1f : 0f),
        (v) -> { Earth3D.displayTexture = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Earth3D.displayTexture", Earth3D.displayTexture);
    }
    return out;
  }

  float valueModifier_Earth3D_levelOfDetail (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1.0 / 16.0; //start
    float s2 = 16.0; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Earth3D.levelOfDetail",
        () -> Earth3D.levelOfDetail,
        (v) -> { Earth3D.levelOfDetail = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Earth3D.levelOfDetail", Earth3D.levelOfDetail, s1, s2, s3, s4);
    }
    return out;
  }

  boolean valueModifier_Moon3D_displaySurface (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Moon3D.displaySurface",
        () -> (Moon3D.displaySurface ? 1f : 0f),
        (v) -> { Moon3D.displaySurface = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Moon3D.displaySurface", Moon3D.displaySurface);
    }
    return out;
  }

  boolean valueModifier_Moon3D_displayTexture (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Moon3D.displayTexture",
        () -> (Moon3D.displayTexture ? 1f : 0f),
        (v) -> { Moon3D.displayTexture = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Moon3D.displayTexture", Moon3D.displayTexture);
    }
    return out;
  }

  boolean valueModifier_Moon3D_fitInSkyDome (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Moon3D.fitInSkyDome",
        () -> (Moon3D.fitInSkyDome ? 1f : 0f),
        (v) -> { Moon3D.fitInSkyDome = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Moon3D.fitInSkyDome", Moon3D.fitInSkyDome);
    }
    return out;
  }

  boolean valueModifier_Sun3D_displaySurface (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Sun3D.displaySurface",
        () -> (Sun3D.displaySurface ? 1f : 0f),
        (v) -> { Sun3D.displaySurface = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.displaySurface", Sun3D.displaySurface);
    }
    return out;
  }

  boolean valueModifier_Sun3D_displayTexture (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Sun3D.displayTexture",
        () -> (Sun3D.displayTexture ? 1f : 0f),
        (v) -> { Sun3D.displayTexture = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.displayTexture", Sun3D.displayTexture);
    }
    return out;
  }

  boolean valueModifier_Sun3D_fitInSkyDome (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Sun3D.fitInSkyDome",
        () -> (Sun3D.fitInSkyDome ? 1f : 0f),
        (v) -> { Sun3D.fitInSkyDome = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.fitInSkyDome", Sun3D.fitInSkyDome);
    }
    return out;
  }

  float valueModifier_Planetary_Magnification (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1; //start
    float s2 = 64; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)

    float out = 0;
    if (created == 0) {
      putValueAction("Planetary_Magnification",
        () -> Planetary_Magnification,
        (v) -> { Planetary_Magnification = v; },
        s1, s2, Math.abs(s3),
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Planetary_Magnification", Planetary_Magnification, s1, s2, s3);
    }
    return out;
  }

  float valueModifier_Objects_scale (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.0000001; //start
    float s2 = 1000000; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.000001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Objects_scale",
        () -> OBJECTS_scale,
        (v) -> { OBJECTS_scale = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Objects_scale", OBJECTS_scale, s1, s2, s3, s4);
    }
    return out;
  }

  int valueModifier_Diagram_setup (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 8; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Diagram setup",
        () -> (float) STUDY.plotSetup,
        (v) -> { STUDY.plotSetup = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.impactsUpdateFlag);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Diagram setup", STUDY.plotSetup, s1, s2, s3);
    }
    return out;
  }

  float valueModifier_Scale (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.0001; //start
    float s2 = 10000; //stop
    float s3 = -pow(2.0, (1.0 / 2.0)); //step (negative = geometric multiply/divide on +/- click)

    float out = 0;
    if (created == 0) {
      putValueAction("Scale",
        () -> STUDY.V_scale,
        (v) -> { STUDY.V_scale = v; },
        s1, s2, Math.abs(s3),
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Scale (" + allLayers[CurrentLayer_id].descriptions[Language_EN] + ")", STUDY.V_scale, s1, s2, s3);
    }
    return out;
  }

  boolean valueModifier_Draw_data (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Draw data",
        () -> (STUDY.displayRaws ? 1f : 0f),
        (v) -> { STUDY.displayRaws = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Draw data", STUDY.displayRaws);
    }
    return out;
  }

  boolean valueModifier_Draw_sorted (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Draw sorted",
        () -> (STUDY.displaySorted ? 1f : 0f),
        (v) -> { STUDY.displaySorted = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Draw sorted", STUDY.displaySorted);
    }
    return out;
  }

  boolean valueModifier_Draw_statistics (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Draw statistics",
        () -> (STUDY.displayNormals ? 1f : 0f),
        (v) -> { STUDY.displayNormals = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Draw statistics", STUDY.displayNormals);
    }
    return out;
  }

  boolean valueModifier_Draw_probabilities (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Draw probabilities",
        () -> (STUDY.displayProbs ? 1f : 0f),
        (v) -> { STUDY.displayProbs = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Draw probabilities", STUDY.displayProbs);
    }
    return out;
  }

  int valueModifier_Probabilities_interval (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 24; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Probabilities interval",
        () -> (float) STUDY.sumInterval,
        (v) -> { STUDY.sumInterval = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Probabilities interval", STUDY.sumInterval, s1, s2, s3);
    }
    return out;
  }

  float valueModifier_Probabilities_range (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 2; //start
    float s2 = 32; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 1; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Probabilities range",
        () -> STUDY.LevelPix,
        (v) -> { STUDY.LevelPix = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Probabilities range", STUDY.LevelPix, s1, s2, s3, s4);
    }
    return out;
  }

  int valueModifier_STUDY_ACTIVE_palette_CLR (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("STUDY.ACTIVE_palette_CLR",
        () -> (float) STUDY.ACTIVE_palette_CLR,
        (v) -> { STUDY.ACTIVE_palette_CLR = int(v); },
        () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.ACTIVE_palette_CLR", STUDY.ACTIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }

  int valueModifier_STUDY_ACTIVE_palette_DIR (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("STUDY.ACTIVE_palette_DIR",
        () -> (float) STUDY.ACTIVE_palette_DIR,
        (v) -> { STUDY.ACTIVE_palette_DIR = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.ACTIVE_palette_DIR", STUDY.ACTIVE_palette_DIR, s1, s2, s3);
    }
    return out;
  }

  float valueModifier_STUDY_ACTIVE_palette_MLT (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("STUDY.ACTIVE_palette_MLT",
        () -> STUDY.ACTIVE_palette_MLT,
        (v) -> { STUDY.ACTIVE_palette_MLT = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.ACTIVE_palette_MLT", STUDY.ACTIVE_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }

  int valueModifier_STUDY_PASSIVE_palette_CLR (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("STUDY.PASSIVE_palette_CLR",
        () -> (float) STUDY.PASSIVE_palette_CLR,
        (v) -> { STUDY.PASSIVE_palette_CLR = int(v); },
        () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.PASSIVE_palette_CLR", STUDY.PASSIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }

  int valueModifier_STUDY_PASSIVE_palette_DIR (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("STUDY.PASSIVE_palette_DIR",
        () -> (float) STUDY.PASSIVE_palette_DIR,
        (v) -> { STUDY.PASSIVE_palette_DIR = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.PASSIVE_palette_DIR", STUDY.PASSIVE_palette_DIR, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_STUDY_PASSIVE_palette_MLT (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("STUDY.PASSIVE_palette_MLT",
        () -> STUDY.PASSIVE_palette_MLT,
        (v) -> { STUDY.PASSIVE_palette_MLT = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.PASSIVE_palette_MLT", STUDY.PASSIVE_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }

  int valueModifier_STUDY_SORT_palette_CLR (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("STUDY.SORT_palette_CLR",
        () -> (float) STUDY.SORT_palette_CLR,
        (v) -> { STUDY.SORT_palette_CLR = int(v); },
        () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.SORT_palette_CLR", STUDY.SORT_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }

  int valueModifier_STUDY_SORT_palette_DIR (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("STUDY.SORT_palette_DIR",
        () -> (float) STUDY.SORT_palette_DIR,
        (v) -> { STUDY.SORT_palette_DIR = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.SORT_palette_DIR", STUDY.SORT_palette_DIR, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_STUDY_SORT_palette_MLT (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("STUDY.SORT_palette_MLT",
        () -> STUDY.SORT_palette_MLT,
        (v) -> { STUDY.SORT_palette_MLT = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.SORT_palette_MLT", STUDY.SORT_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }

  int valueModifier_STUDY_PROB_palette_CLR (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("STUDY.PROB_palette_CLR",
        () -> (float) STUDY.PROB_palette_CLR,
        (v) -> { STUDY.PROB_palette_CLR = int(v); },
        () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.PROB_palette_CLR", STUDY.PROB_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }

  int valueModifier_STUDY_PROB_palette_DIR (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("STUDY.PROB_palette_DIR",
        () -> (float) STUDY.PROB_palette_DIR,
        (v) -> { STUDY.PROB_palette_DIR = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.PROB_palette_DIR", STUDY.PROB_palette_DIR, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_STUDY_PROB_palette_MLT (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("STUDY.PROB_palette_MLT",
        () -> STUDY.PROB_palette_MLT,
        (v) -> { STUDY.PROB_palette_MLT = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.PROB_palette_MLT", STUDY.PROB_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_Windose_opacity_scale (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1; //start
    float s2 = 100; //stop
    float s3 = -pow(2.0, (1.0 / 4.0)); //step (negative = geometric multiply/divide on +/- click)

    float out = 0;
    if (created == 0) {
      putValueAction("Windose opacity scale",
        () -> STUDY.O_scale,
        (v) -> { STUDY.O_scale = v; },
        s1, s2, Math.abs(s3),
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Windose opacity scale", STUDY.O_scale, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_faces_ACTIVE_palette_CLR (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("faces.ACTIVE_palette_CLR",
        () -> (float) allFaces.ACTIVE_palette_CLR,
        (v) -> { allFaces.ACTIVE_palette_CLR = int(v); },
        () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "faces.ACTIVE_palette_CLR", allFaces.ACTIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }

  int valueModifier_faces_ACTIVE_palette_DIR (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("faces.ACTIVE_palette_DIR",
        () -> (float) allFaces.ACTIVE_palette_DIR,
        (v) -> { allFaces.ACTIVE_palette_DIR = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "faces.ACTIVE_palette_DIR", allFaces.ACTIVE_palette_DIR, s1, s2, s3);
    }
    return out;
  }

  float valueModifier_faces_ACTIVE_palette_MLT (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("faces.ACTIVE_palette_MLT",
        () -> allFaces.ACTIVE_palette_MLT,
        (v) -> { allFaces.ACTIVE_palette_MLT = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "faces.ACTIVE_palette_MLT", allFaces.ACTIVE_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }

  int valueModifier_faces_PASSIVE_palette_CLR (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("faces.PASSIVE_palette_CLR",
        () -> (float) allFaces.PASSIVE_palette_CLR,
        (v) -> { allFaces.PASSIVE_palette_CLR = int(v); },
        () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "faces.PASSIVE_palette_CLR", allFaces.PASSIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }

  int valueModifier_faces_PASSIVE_palette_DIR (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("faces.PASSIVE_palette_DIR",
        () -> (float) allFaces.PASSIVE_palette_DIR,
        (v) -> { allFaces.PASSIVE_palette_DIR = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "faces.PASSIVE_palette_DIR", allFaces.PASSIVE_palette_DIR, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_faces_PASSIVE_palette_MLT (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("faces.PASSIVE_palette_MLT",
        () -> allFaces.PASSIVE_palette_MLT,
        (v) -> { allFaces.PASSIVE_palette_MLT = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "faces.PASSIVE_palette_MLT", allFaces.PASSIVE_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }

  int valueModifier_Sky3D_ACTIVE_palette_CLR (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Sky3D.ACTIVE_palette_CLR",
        () -> (float) Sky3D.ACTIVE_palette_CLR,
        (v) -> { Sky3D.ACTIVE_palette_CLR = int(v); },
        () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D.ACTIVE_palette_CLR", Sky3D.ACTIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }

  int valueModifier_Sky3D_ACTIVE_palette_DIR (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Sky3D.ACTIVE_palette_DIR",
        () -> (float) Sky3D.ACTIVE_palette_DIR,
        (v) -> { Sky3D.ACTIVE_palette_DIR = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D.ACTIVE_palette_DIR", Sky3D.ACTIVE_palette_DIR, s1, s2, s3);
    }
    return out;
  }

  float valueModifier_Sky3D_ACTIVE_palette_MLT (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Sky3D.ACTIVE_palette_MLT",
        () -> Sky3D.ACTIVE_palette_MLT,
        (v) -> { Sky3D.ACTIVE_palette_MLT = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D.ACTIVE_palette_MLT", Sky3D.ACTIVE_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }

  int valueModifier_Sky3D_PASSIVE_palette_CLR (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Sky3D.PASSIVE_palette_CLR",
        () -> (float) Sky3D.PASSIVE_palette_CLR,
        (v) -> { Sky3D.PASSIVE_palette_CLR = int(v); },
        () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D.PASSIVE_palette_CLR", Sky3D.PASSIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }

  int valueModifier_Sky3D_PASSIVE_palette_DIR (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("Sky3D.PASSIVE_palette_DIR",
        () -> (float) Sky3D.PASSIVE_palette_DIR,
        (v) -> { Sky3D.PASSIVE_palette_DIR = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D.PASSIVE_palette_DIR", Sky3D.PASSIVE_palette_DIR, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_Sky3D_PASSIVE_palette_MLT (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Sky3D.PASSIVE_palette_MLT",
        () -> Sky3D.PASSIVE_palette_MLT,
        (v) -> { Sky3D.PASSIVE_palette_MLT = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D.PASSIVE_palette_MLT", Sky3D.PASSIVE_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }

  int valueModifier_Sun3D_ACTIVE_palette_CLR (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Sun3D.ACTIVE_palette_CLR",
        () -> (float) Sun3D.ACTIVE_palette_CLR,
        (v) -> { Sun3D.ACTIVE_palette_CLR = int(v); },
        () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.ACTIVE_palette_CLR", Sun3D.ACTIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }

  int valueModifier_Sun3D_ACTIVE_palette_DIR (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Sun3D.ACTIVE_palette_DIR",
        () -> (float) Sun3D.ACTIVE_palette_DIR,
        (v) -> { Sun3D.ACTIVE_palette_DIR = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.ACTIVE_palette_DIR", Sun3D.ACTIVE_palette_DIR, s1, s2, s3);
    }
    return out;
  }

  float valueModifier_Sun3D_ACTIVE_palette_MLT (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Sun3D.ACTIVE_palette_MLT",
        () -> Sun3D.ACTIVE_palette_MLT,
        (v) -> { Sun3D.ACTIVE_palette_MLT = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.ACTIVE_palette_MLT", Sun3D.ACTIVE_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }

  int valueModifier_Sun3D_PASSIVE_palette_CLR (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Sun3D.PASSIVE_palette_CLR",
        () -> (float) Sun3D.PASSIVE_palette_CLR,
        (v) -> { Sun3D.PASSIVE_palette_CLR = int(v); },
        () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.PASSIVE_palette_CLR", Sun3D.PASSIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }

  int valueModifier_Sun3D_PASSIVE_palette_DIR (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("Sun3D.PASSIVE_palette_DIR",
        () -> (float) Sun3D.PASSIVE_palette_DIR,
        (v) -> { Sun3D.PASSIVE_palette_DIR = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.PASSIVE_palette_DIR", Sun3D.PASSIVE_palette_DIR, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_Sun3D_PASSIVE_palette_MLT (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Sun3D.PASSIVE_palette_MLT",
        () -> Sun3D.PASSIVE_palette_MLT,
        (v) -> { Sun3D.PASSIVE_palette_MLT = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.PASSIVE_palette_MLT", Sun3D.PASSIVE_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }

  int valueModifier_solids_palette_CLR (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("solids.palette_CLR",
        () -> (float) allSolids.palette_CLR,
        (v) -> { allSolids.palette_CLR = int(v); },
        () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solids.palette_CLR", allSolids.palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }

  int valueModifier_solids_palette_DIR (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("solids.palette_DIR",
        () -> (float) allSolids.palette_DIR,
        (v) -> { allSolids.palette_DIR = int(v); },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solids.palette_DIR", allSolids.palette_DIR, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_solids_palette_MLT (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.0001; //start
    float s2 = 64; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("solids.palette_MLT",
        () -> allSolids.palette_MLT,
        (v) -> { allSolids.palette_MLT = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "solids.palette_MLT", allSolids.palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }

  int valueModifier_Land3D_palette_CLR (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Land3D.palette_CLR",
        () -> (float) Land3D.palette_CLR,
        (v) -> { Land3D.palette_CLR = int(v); },
        () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.palette_CLR", Land3D.palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }

  int valueModifier_Land3D_palette_DIR (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("Land3D.palette_DIR",
        () -> (float) Land3D.palette_DIR,
        (v) -> { Land3D.palette_DIR = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.palette_DIR", Land3D.palette_DIR, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_Land3D_palette_MLT (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.001; //start
    float s2 = 0.5; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Land3D.palette_MLT",
        () -> Land3D.palette_MLT,
        (v) -> { Land3D.palette_MLT = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.palette_MLT", Land3D.palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }

  int valueModifier_windFlows_palette_CLR (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("windFlows.palette_CLR",
        () -> (float) allWindFlows.palette_CLR,
        (v) -> { allWindFlows.palette_CLR = int(v); },
        () -> (float) (-1), () -> (float) ((COLOR_STYLE_Number - 1)), 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "windFlows.palette_CLR", allWindFlows.palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }

  int valueModifier_windFlows_palette_DIR (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("windFlows.palette_DIR",
        () -> (float) allWindFlows.palette_DIR,
        (v) -> { allWindFlows.palette_DIR = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "windFlows.palette_DIR", allWindFlows.palette_DIR, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_windFlows_palette_MLT (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.01; //start
    float s2 = 1.0; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("windFlows.palette_MLT",
        () -> allWindFlows.palette_MLT,
        (v) -> { allWindFlows.palette_MLT = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "windFlows.palette_MLT", allWindFlows.palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }

  boolean valueModifier__3D_select_Group_displayPivot (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("3D-select.Group_displayPivot",
        () -> (Select3D.Group_displayPivot ? 1f : 0f),
        (v) -> { Select3D.Group_displayPivot = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Group_displayPivot", Select3D.Group_displayPivot);
    }
    return out;
  }

  boolean valueModifier__3D_select_displayReferencePivot (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("3D-select.displayReferencePivot",
        () -> (Select3D.displayReferencePivot ? 1f : 0f),
        (v) -> { Select3D.displayReferencePivot = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.displayReferencePivot", Select3D.displayReferencePivot);
    }
    return out;
  }

  boolean valueModifier__3D_select_Group_displayBox (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("3D-select.Group_displayBox",
        () -> (Select3D.Group_displayBox ? 1f : 0f),
        (v) -> { Select3D.Group_displayBox = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Group_displayBox", Select3D.Group_displayBox);
    }
    return out;
  }

  boolean valueModifier__3D_select_Group_displayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("3D-select.Group_displayEdges",
        () -> (Select3D.Group_displayEdges ? 1f : 0f),
        (v) -> { Select3D.Group_displayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Group_displayEdges", Select3D.Group_displayEdges);
    }
    return out;
  }

  boolean valueModifier__3D_select_Face_displayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("3D-select.Face_displayEdges",
        () -> (Select3D.Face_displayEdges ? 1f : 0f),
        (v) -> { Select3D.Face_displayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Face_displayEdges", Select3D.Face_displayEdges);
    }
    return out;
  }

  boolean valueModifier__3D_select_Face_displayVertexCount (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("3D-select.Face_displayVertexCount",
        () -> (Select3D.Face_displayVertexCount ? 1f : 0f),
        (v) -> { Select3D.Face_displayVertexCount = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Face_displayVertexCount", Select3D.Face_displayVertexCount);
    }
    return out;
  }

  boolean valueModifier__3D_select_Polyline_displayVertexCount (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("3D-select.Polyline_displayVertexCount",
        () -> (Select3D.Polyline_displayVertexCount ? 1f : 0f),
        (v) -> { Select3D.Polyline_displayVertexCount = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Polyline_displayVertexCount", Select3D.Polyline_displayVertexCount);
    }
    return out;
  }

  boolean valueModifier__3D_select_Vertex_displayVertices (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("3D-select.Vertex_displayVertices",
        () -> (Select3D.Vertex_displayVertices ? 1f : 0f),
        (v) -> { Select3D.Vertex_displayVertices = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Vertex_displayVertices", Select3D.Vertex_displayVertices);
    }
    return out;
  }

  boolean valueModifier__3D_select_Polyline_displayVertices (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("3D-select.Polyline_displayVertices",
        () -> (Select3D.Polyline_displayVertices ? 1f : 0f),
        (v) -> { Select3D.Polyline_displayVertices = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Polyline_displayVertices", Select3D.Polyline_displayVertices);
    }
    return out;
  }

  boolean valueModifier__3D_select_Model2D_displayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("3D-select.Model2D_displayEdges",
        () -> (Select3D.Model2D_displayEdges ? 1f : 0f),
        (v) -> { Select3D.Model2D_displayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Model2D_displayEdges", Select3D.Model2D_displayEdges);
    }
    return out;
  }

  boolean valueModifier__3D_select_Model1D_displayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("3D-select.Model1D_displayEdges",
        () -> (Select3D.Model1D_displayEdges ? 1f : 0f),
        (v) -> { Select3D.Model1D_displayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Model1D_displayEdges", Select3D.Model1D_displayEdges);
    }
    return out;
  }

  boolean valueModifier__3D_select_Solid_displayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("3D-select.Solid_displayEdges",
        () -> (Select3D.Solid_displayEdges ? 1f : 0f),
        (v) -> { Select3D.Solid_displayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Solid_displayEdges", Select3D.Solid_displayEdges);
    }
    return out;
  }

  boolean valueModifier__3D_select_Section_displayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("3D-select.Section_displayEdges",
        () -> (Select3D.Section_displayEdges ? 1f : 0f),
        (v) -> { Select3D.Section_displayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Section_displayEdges", Select3D.Section_displayEdges);
    }
    return out;
  }

  boolean valueModifier__3D_select_Camera_displayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("3D-select.Camera_displayEdges",
        () -> (Select3D.Camera_displayEdges ? 1f : 0f),
        (v) -> { Select3D.Camera_displayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Camera_displayEdges", Select3D.Camera_displayEdges);
    }
    return out;
  }

  boolean valueModifier__3D_select_LandPoint_displayPoints (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("3D-select.LandPoint_displayPoints",
        () -> (Select3D.LandPoint_displayPoints ? 1f : 0f),
        (v) -> { Select3D.LandPoint_displayPoints = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.LandPoint_displayPoints", Select3D.LandPoint_displayPoints);
    }
    return out;
  }

  float valueModifier_Interpolation_Weight (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 5; //stop
    float s3 = 0.5; //step

    float out = 0;
    if (created == 0) {
      putValueAction("Interpolation_Weight",
        () -> Interpolation_Weight,
        (v) -> { Interpolation_Weight = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Interpolation_Weight", Interpolation_Weight, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_Climate_based_solar_forecast (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Climate-based solar forecast",
        () -> (float) CLIMATIC_SolarForecast,
        (v) -> { CLIMATIC_SolarForecast = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeChange);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Climate-based solar forecast", CLIMATIC_SolarForecast, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_Climate_based_temperature_forecast (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Climate-based temperature forecast",
        () -> (float) CLIMATIC_WeatherForecast,
        (v) -> { CLIMATIC_WeatherForecast = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeChange);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Climate-based temperature forecast", CLIMATIC_WeatherForecast, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_Develop_Option (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 11; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Develop_Option",
        () -> (float) Develop_Option,
        (v) -> { Develop_Option = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Develop_Option", Develop_Option, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_Develop_DayHour (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 3; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Develop_DayHour",
        () -> (float) Develop_DayHour,
        (v) -> { Develop_DayHour = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Develop_DayHour", Develop_DayHour, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_Trend_period_hours (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 24 * 16; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Trend period hours",
        () -> (float) STUDY.TrendJoinHours,
        (v) -> { STUDY.TrendJoinHours = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Trend period hours", STUDY.TrendJoinHours, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_Weighted_equal_trend (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 1; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("Weighted/equal trend",
        () -> (float) STUDY.TrendJoinType,
        (v) -> { STUDY.TrendJoinType = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Weighted/equal trend", STUDY.TrendJoinType, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_Inclination_angle (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 90; //stop
    float s3 = 5; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 1; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Inclination angle",
        () -> Develop_AngleInclination,
        (v) -> { Develop_AngleInclination = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Inclination angle", Develop_AngleInclination, s1, s2, s3, s4);
    }
    return out;
  }

  float valueModifier_Orientation_angle (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 360; //stop
    float s3 = 15; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 1; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Orientation angle",
        () -> Develop_AngleOrientation,
        (v) -> { Develop_AngleOrientation = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Orientation angle", Develop_AngleOrientation, s1, s2, s3, s4);
    }
    return out;
  }

  int valueModifier_Impact_Source (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Impact Source",
        () -> (float) CurrentDataSource,
        (v) -> { CurrentDataSource = int(v); },
        () -> (float) (0), () -> (float) (MAXIMUM_dataID), 1,
        u1, u2, u3,
        react.impactsUpdateFlag);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Impact Source", CurrentDataSource, 0, MAXIMUM_dataID, 1);
    }
    return out;
  }

  int valueModifier_Impact_Min_50_Max (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 8; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Impact Min/50%/Max",
        () -> (float) STUDY.ImpactLayer,
        (v) -> { STUDY.ImpactLayer = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Impact Min/50%/Max", STUDY.ImpactLayer, s1, s2, s3);
    }
    return out;
  }

  boolean valueModifier_Export_ASCII_data (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Export ASCII data",
        () -> (STUDY.export_info_node ? 1f : 0f),
        (v) -> { STUDY.export_info_node = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Export ASCII data", STUDY.export_info_node);
    }
    return out;
  }

  boolean valueModifier_Export_ASCII_statistics (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Export ASCII statistics",
        () -> (STUDY.export_info_norm ? 1f : 0f),
        (v) -> { STUDY.export_info_norm = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Export ASCII statistics", STUDY.export_info_norm);
    }
    return out;
  }

  boolean valueModifier_Export_ASCII_probabilities (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Export ASCII probabilities",
        () -> (STUDY.export_info_prob ? 1f : 0f),
        (v) -> { STUDY.export_info_prob = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Export ASCII probabilities", STUDY.export_info_prob);
    }
    return out;
  }

  float valueModifier__3D_export_Scale (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = .001; //start
    float s2 = 1000; //stop
    float s3 = -0.1; //step (negative = geometric multiply/divide on +/- click)

    float out = 0;
    if (created == 0) {
      putValueAction("3D-export.Scale",
        () -> User3D.export_Scale,
        (v) -> { User3D.export_Scale = v; },
        s1, s2, Math.abs(s3),
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-export.Scale", User3D.export_Scale, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_export_FlipZYaxis (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-export.FlipZYaxis",
        () -> (float) User3D.export_FlipZYaxis,
        (v) -> { User3D.export_FlipZYaxis = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-export.FlipZYaxis", User3D.export_FlipZYaxis, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_export_PrecisionVertex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 6; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-export.PrecisionVertex",
        () -> (float) User3D.export_PrecisionVertex,
        (v) -> { User3D.export_PrecisionVertex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-export.PrecisionVertex", User3D.export_PrecisionVertex, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_export_PrecisionVtexture (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 6; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-export.PrecisionVtexture",
        () -> (float) User3D.export_PrecisionVtexture,
        (v) -> { User3D.export_PrecisionVtexture = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-export.PrecisionVtexture", User3D.export_PrecisionVtexture, s1, s2, s3);
    }
    return out;
  }

  int valueModifier__3D_export_PolyToPoly (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("3D-export.PolyToPoly",
        () -> (float) User3D.export_PolyToPoly,
        (v) -> { User3D.export_PolyToPoly = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-export.PolyToPoly", User3D.export_PolyToPoly, s1, s2, s3);
    }
    return out;
  }

  boolean valueModifier__3D_export_MaterialLibrary (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("3D-export.MaterialLibrary",
        () -> (User3D.export_MaterialLibrary ? 1f : 0f),
        (v) -> { User3D.export_MaterialLibrary = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-export.MaterialLibrary", User3D.export_MaterialLibrary);
    }
    return out;
  }

  boolean valueModifier__3D_export_BackSides (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("3D-export.BackSides",
        () -> (User3D.export_BackSides ? 1f : 0f),
        (v) -> { User3D.export_BackSides = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-export.BackSides", User3D.export_BackSides);
    }
    return out;
  }

  int valueModifier__3D_export_PaletteResolution (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 32; //start
    int s2 = 2048; //stop
    int s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("3D-export.PaletteResolution",
        () -> (float) User3D.export_PaletteResolution,
        (v) -> { User3D.export_PaletteResolution = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "3D-export.PaletteResolution", User3D.export_PaletteResolution, s1, s2, s3, s4);
    }
    return out;
  }

  int valueModifier_Record_SolidImpact_in_JPG (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Record SolidImpact in JPG",
        () -> (float) allSolidImpacts.record_IMG,
        (v) -> { allSolidImpacts.record_IMG = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Record SolidImpact in JPG", allSolidImpacts.record_IMG, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_Record_SolidImpact_in_PDF (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Record SolidImpact in PDF",
        () -> (float) allSolidImpacts.record_PDF,
        (v) -> { allSolidImpacts.record_PDF = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Record SolidImpact in PDF", allSolidImpacts.record_PDF, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_Record_Solar_Analysis_in_JPG (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Record Solar Analysis in JPG",
        () -> (float) allSolarImpacts.record_IMG,
        (v) -> { allSolarImpacts.record_IMG = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = this.Spinner(X_control, Y_control, u1, u2, u3, "Record Solar Analysis in JPG", allSolarImpacts.record_IMG, s1, s2, s3);
    }
    return out;
  }

  int valueModifier_windRoses_resolution (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 200; //start
    int s2 = 600; //stop
    int s3 = 100; //step

    int out = 0;
    if (created == 0) {
      putValueAction("windRoses.resolution",
        () -> (float) allWindRoses.RES,
        (v) -> { allWindRoses.RES = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = int(this.Spinner(X_control, Y_control, u1, u2, u3, "windRoses.resolution", allWindRoses.RES, s1, s2, s3));
    }
    return out;
  }
  void registerSpinnerActions () {

    // One valueModifier_...(0) call per this.Spinner(...) in draw() - see
    // the value modifiers section above for each one's caption, bounds,
    // update flags and (where relevant) OnChange follow-up.

    valueModifier_Number_of_days_to_plot(0);
    valueModifier_Day_step(0);
    valueModifier_Join_days(0);
    valueModifier_Days_past_March_equinox(0);
    valueModifier_Begin_day(0);
    valueModifier_Begin_month(0);
    valueModifier_Begin_year(0);
    valueModifier_Start_hour(0);
    valueModifier_End_hour(0);
    valueModifier_Start_year(0);
    valueModifier_End_year(0);
    valueModifier_Start_member(0);
    valueModifier_End_member(0);
    valueModifier_Start_station(0);
    valueModifier_End_station(0);
    valueModifier_Forecast_Obs_maxDays(0);
    valueModifier_Sky_status(0);
    valueModifier_Hourly_daily_filter(0);
    valueModifier_Latitude(0);
    valueModifier_Longitude(0);
    valueModifier_displayAll_TMYEPW(0);
    valueModifier_displayNear_TMYEPW(0);
    valueModifier_displayAll_CWEEDS(0);
    valueModifier_displayNear_CWEEDS(0);
    valueModifier_displayAll_CLMREC(0);
    valueModifier_displayNear_CLMREC(0);
    valueModifier_displayAll_SWOB(0);
    valueModifier_displayNear_SWOB(0);
    valueModifier_displayAll_NAEFS(0);
    valueModifier_displayNear_NAEFS(0);
    valueModifier_addToLastGroup(0);
    valueModifier__3D_create_Material(0);
    valueModifier__3D_create_Tessellation(0);
    valueModifier__3D_create_Layer(0);
    valueModifier__3D_create_Visibility(0);
    valueModifier__3D_create_Weight(0);
    valueModifier__3D_create_Closed(0);
    valueModifier__3D_create_Orientation(0);
    valueModifier__3D_create_Length_rand_negative(0);
    valueModifier__3D_create_Width_rand_negative(0);
    valueModifier__3D_create_Height_rand_negative(0);
    valueModifier__3D_create_Volume(0);
    valueModifier__3D_create_Snap(0);
    valueModifier__3D_create_SphereDegree(0);
    valueModifier__3D_create_CylinderDegree(0);
    valueModifier__3D_create_PolyDegree(0);
    valueModifier__3D_create_Parametric_Type(0);
    valueModifier__3D_create_Person_Type(0);
    valueModifier__3D_create_Plant_Type(0);
    valueModifier__3D_modify_OpenningDepth(0);
    valueModifier__3D_modify_OpenningArea(0);
    valueModifier__3D_modify_OpenningDeviation(0);
    valueModifier__3D_modify_TessellateRows(0);
    valueModifier__3D_modify_TessellateColumns(0);
    valueModifier__3D_modify_OffsetAmount(0);
    valueModifier__3D_modify_WeldTreshold(0);
    valueModifier__3D_select_softPower(0);
    valueModifier__3D_select_softRadius(0);
    valueModifier__3D_select_posVector(0);
    valueModifier__3D_select_rotVector(0);
    valueModifier__3D_select_scaleVector(0);
    valueModifier__3D_select_posValue(0);
    valueModifier__3D_select_rotValue(0);
    valueModifier__3D_select_scaleValue(0);
    valueModifier__3D_select_alignX(0);
    valueModifier__3D_select_alignY(0);
    valueModifier__3D_select_alignZ(0);
    valueModifier__3D_create_powAll(0);
    valueModifier__3D_create_powX(0);
    valueModifier__3D_create_powY(0);
    valueModifier__3D_create_powZ(0);
    valueModifier__3D_create_Type(0);
    valueModifier__3D_create_DegreeMax(0);
    valueModifier__3D_create_Seed(0);
    valueModifier__3D_create_TrunkSize(0);
    valueModifier__3D_create_LeafSize(0);
    valueModifier__3D_create_BranchTilt(0);
    valueModifier__3D_create_BranchTwist(0);
    valueModifier__3D_create_BranchRatio(0);
    valueModifier__3D_create_TreeBase(0);
    valueModifier_Land3D_loadTextures(0);
    valueModifier_Land3D_loadMesh(0);
    valueModifier_Land3D_skipStart(0);
    valueModifier_Land3D_skipEnd(0);
    valueModifier_Land3D_displaySurface(0);
    valueModifier_Land3D_displayTexture(0);
    valueModifier_Land3D_displayPoints(0);
    valueModifier_Land3D_displayDepth(0);
    valueModifier_model2Ds_displayAll(0);
    valueModifier_model1Ds_displayAll(0);
    valueModifier_model1Ds_displayLeaves(0);
    valueModifier_polylines_displayAll(0);
    valueModifier_faces_displayAll(0);
    valueModifier_solids_displayAll(0);
    valueModifier_sections_displayAll(0);
    valueModifier_windRoses_displayImage(0);
    valueModifier_windRoses_scale(0);
    valueModifier_Sky3D_displaySurface(0);
    valueModifier_Sun3D_displayPath(0);
    valueModifier_Sun3D_displayPattern(0);
    valueModifier_currentCamera(0);
    valueModifier_Camera_clipNear(0);
    valueModifier_Camera_clipFar(0);
    valueModifier_Create3D_displayVertices(0);
    valueModifier_Create3D_displayEdges(0);
    valueModifier_Create3D_displayNormals(0);
    valueModifier_cameras_displayAll(0);
    valueModifier_IMPACTS_displayDay(0);
    valueModifier_solarImpacts_displayImage(0);
    valueModifier_solidImpacts_displayImage(0);
    valueModifier_solarImpacts_sectionType(0);
    valueModifier_solidImpacts_sectionType(0);
    valueModifier_solidImpacts_Grade(0);
    valueModifier_solidImpacts_Power(0);
    valueModifier_solidImpacts_R(0);
    valueModifier_solidImpacts_Z(0);
    valueModifier_solidImpacts_positionStep(0);
    valueModifier_solidImpacts_U(0);
    valueModifier_solidImpacts_V(0);
    valueModifier_solidImpacts_X(0);
    valueModifier_solidImpacts_Y(0);
    valueModifier_solidImpacts_WindSpeed_m_s(0);
    valueModifier_solidImpacts_WindDirection(0);
    valueModifier_solidImpacts_Process_subDivisions(0);
    valueModifier_solidImpacts_displayPoints(0);
    valueModifier_solidImpacts_displayLines(0);
    valueModifier_windFlows_displayAll(0);
    valueModifier__3D_create_displayTessellation(0);
    valueModifier_Land_displayTessellation(0);
    valueModifier_Sky_displayTessellation(0);
    valueModifier_Sky_scale(0);
    valueModifier_Tropo3D_displaySurface(0);
    valueModifier_Tropo3D_displayTexture(0);
    valueModifier_Earth3D_displaySurface(0);
    valueModifier_Earth3D_displayTexture(0);
    valueModifier_Earth3D_levelOfDetail(0);
    valueModifier_Moon3D_displaySurface(0);
    valueModifier_Moon3D_displayTexture(0);
    valueModifier_Moon3D_fitInSkyDome(0);
    valueModifier_Sun3D_displaySurface(0);
    valueModifier_Sun3D_displayTexture(0);
    valueModifier_Sun3D_fitInSkyDome(0);
    valueModifier_Planetary_Magnification(0);
    valueModifier_Objects_scale(0);
    valueModifier_Diagram_setup(0);
    valueModifier_Scale(0);
    valueModifier_Draw_data(0);
    valueModifier_Draw_sorted(0);
    valueModifier_Draw_statistics(0);
    valueModifier_Draw_probabilities(0);
    valueModifier_Probabilities_interval(0);
    valueModifier_Probabilities_range(0);
    valueModifier_STUDY_ACTIVE_palette_CLR(0);
    valueModifier_STUDY_ACTIVE_palette_DIR(0);
    valueModifier_STUDY_ACTIVE_palette_MLT(0);
    valueModifier_STUDY_PASSIVE_palette_CLR(0);
    valueModifier_STUDY_PASSIVE_palette_DIR(0);
    valueModifier_STUDY_PASSIVE_palette_MLT(0);
    valueModifier_STUDY_SORT_palette_CLR(0);
    valueModifier_STUDY_SORT_palette_DIR(0);
    valueModifier_STUDY_SORT_palette_MLT(0);
    valueModifier_STUDY_PROB_palette_CLR(0);
    valueModifier_STUDY_PROB_palette_DIR(0);
    valueModifier_STUDY_PROB_palette_MLT(0);
    valueModifier_Windose_opacity_scale(0);
    valueModifier_faces_ACTIVE_palette_CLR(0);
    valueModifier_faces_ACTIVE_palette_DIR(0);
    valueModifier_faces_ACTIVE_palette_MLT(0);
    valueModifier_faces_PASSIVE_palette_CLR(0);
    valueModifier_faces_PASSIVE_palette_DIR(0);
    valueModifier_faces_PASSIVE_palette_MLT(0);
    valueModifier_Sky3D_ACTIVE_palette_CLR(0);
    valueModifier_Sky3D_ACTIVE_palette_DIR(0);
    valueModifier_Sky3D_ACTIVE_palette_MLT(0);
    valueModifier_Sky3D_PASSIVE_palette_CLR(0);
    valueModifier_Sky3D_PASSIVE_palette_DIR(0);
    valueModifier_Sky3D_PASSIVE_palette_MLT(0);
    valueModifier_Sun3D_ACTIVE_palette_CLR(0);
    valueModifier_Sun3D_ACTIVE_palette_DIR(0);
    valueModifier_Sun3D_ACTIVE_palette_MLT(0);
    valueModifier_Sun3D_PASSIVE_palette_CLR(0);
    valueModifier_Sun3D_PASSIVE_palette_DIR(0);
    valueModifier_Sun3D_PASSIVE_palette_MLT(0);
    valueModifier_solids_palette_CLR(0);
    valueModifier_solids_palette_DIR(0);
    valueModifier_solids_palette_MLT(0);
    valueModifier_Land3D_palette_CLR(0);
    valueModifier_Land3D_palette_DIR(0);
    valueModifier_Land3D_palette_MLT(0);
    valueModifier_windFlows_palette_CLR(0);
    valueModifier_windFlows_palette_DIR(0);
    valueModifier_windFlows_palette_MLT(0);
    valueModifier__3D_select_Group_displayPivot(0);
    valueModifier__3D_select_displayReferencePivot(0);
    valueModifier__3D_select_Group_displayBox(0);
    valueModifier__3D_select_Group_displayEdges(0);
    valueModifier__3D_select_Face_displayEdges(0);
    valueModifier__3D_select_Face_displayVertexCount(0);
    valueModifier__3D_select_Polyline_displayVertexCount(0);
    valueModifier__3D_select_Vertex_displayVertices(0);
    valueModifier__3D_select_Polyline_displayVertices(0);
    valueModifier__3D_select_Model2D_displayEdges(0);
    valueModifier__3D_select_Model1D_displayEdges(0);
    valueModifier__3D_select_Solid_displayEdges(0);
    valueModifier__3D_select_Section_displayEdges(0);
    valueModifier__3D_select_Camera_displayEdges(0);
    valueModifier__3D_select_LandPoint_displayPoints(0);
    valueModifier_Interpolation_Weight(0);
    valueModifier_Climate_based_solar_forecast(0);
    valueModifier_Climate_based_temperature_forecast(0);
    valueModifier_Develop_Option(0);
    valueModifier_Develop_DayHour(0);
    valueModifier_Trend_period_hours(0);
    valueModifier_Weighted_equal_trend(0);
    valueModifier_Inclination_angle(0);
    valueModifier_Orientation_angle(0);
    valueModifier_Impact_Source(0);
    valueModifier_Impact_Min_50_Max(0);
    valueModifier_Export_ASCII_data(0);
    valueModifier_Export_ASCII_statistics(0);
    valueModifier_Export_ASCII_probabilities(0);
    valueModifier__3D_export_Scale(0);
    valueModifier__3D_export_FlipZYaxis(0);
    valueModifier__3D_export_PrecisionVertex(0);
    valueModifier__3D_export_PrecisionVtexture(0);
    valueModifier__3D_export_PolyToPoly(0);
    valueModifier__3D_export_MaterialLibrary(0);
    valueModifier__3D_export_BackSides(0);
    valueModifier__3D_export_PaletteResolution(0);
    valueModifier_Record_SolidImpact_in_JPG(0);
    valueModifier_Record_SolidImpact_in_PDF(0);
    valueModifier_Record_Solar_Analysis_in_JPG(0);
    valueModifier_windRoses_resolution(0);
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
        STUDY.j_End = valueModifier_Number_of_days_to_plot(1);
        STUDY.perDays = valueModifier_Day_step(1);
        STUDY.joinDays = valueModifier_Join_days(1);
        TIME.date = valueModifier_Days_past_March_equinox(1);
        //TIME.beginDay = this.Spinner(X_control, Y_control, 1, 1, 0, "Day of year (0-364)", TIME.beginDay, 0, 364, 1);

        TIME.day = valueModifier_Begin_day(1);
        TIME.month = valueModifier_Begin_month(1);
        TIME.year = valueModifier_Begin_year(1);
      }

      if (this.child == CHILD_PERIOD_RANGES) {
        STUDY.i_Start = valueModifier_Start_hour(1);
        STUDY.i_End = valueModifier_End_hour(1);
        SampleYear_Start = valueModifier_Start_year(1);
        SampleYear_End = valueModifier_End_year(1);
        SampleMember_Start = valueModifier_Start_member(1);
        SampleMember_End = valueModifier_End_member(1);
        SampleStation_Start = valueModifier_Start_station(1);
        SampleStation_End = valueModifier_End_station(1);
        ENSEMBLE_OBSERVED_maxDays = valueModifier_Forecast_Obs_maxDays(1);
      }

      if (this.child == CHILD_PERIOD_FILTERS) {

        STUDY.skyScenario = valueModifier_Sky_status(1);
        STUDY.filter = valueModifier_Hourly_daily_filter(1);
      }
    } else if (this.parent == PARENT_LOCATION) {


      if (this.child == CHILD_LOCATION_POINT) {
        LocationLAT = valueModifier_Latitude(1);
        LocationLON = valueModifier_Longitude(1);
        //LocationELE = this.Spinner(X_control, Y_control, 0, 0, 1, "Elevation", LocationELE, -100, 8000, 1);
      }

      if (this.child == CHILD_LOCATION_STATIONS) {

        WORLD.displayAll_TMYEPW = valueModifier_displayAll_TMYEPW(1);
        WORLD.displayNear_TMYEPW = valueModifier_displayNear_TMYEPW(1);
        WORLD.displayAll_CWEEDS = valueModifier_displayAll_CWEEDS(1);
        WORLD.displayNear_CWEEDS = valueModifier_displayNear_CWEEDS(1);
        WORLD.displayAll_CLMREC = valueModifier_displayAll_CLMREC(1);
        WORLD.displayNear_CLMREC = valueModifier_displayNear_CLMREC(1);
        WORLD.displayAll_SWOB = valueModifier_displayAll_SWOB(1);
        WORLD.displayNear_SWOB = valueModifier_displayNear_SWOB(1);
        WORLD.displayAll_NAEFS = valueModifier_displayAll_NAEFS(1);
        WORLD.displayNear_NAEFS = valueModifier_displayNear_NAEFS(1);
      }
    } else if (this.parent == PARENT_GEOMETRY) {
      if (this.child == CHILD_GEOMETRY_CREATE) {

        addToLastGroup = valueModifier_addToLastGroup(1);
        User3D.default_Material = valueModifier__3D_create_Material(1);
        User3D.default_Tessellation = valueModifier__3D_create_Tessellation(1);
        User3D.default_Layer = valueModifier__3D_create_Layer(1);
        User3D.default_Visibility = valueModifier__3D_create_Visibility(1);
        User3D.default_Weight = valueModifier__3D_create_Weight(1);
        User3D.default_Closed = valueModifier__3D_create_Closed(1);
        User3D.create_Orientation = valueModifier__3D_create_Orientation(1);
        User3D.create_Length = valueModifier__3D_create_Length_rand_negative(1);
        User3D.create_Width = valueModifier__3D_create_Width_rand_negative(1);
        User3D.create_Height = valueModifier__3D_create_Height_rand_negative(1);
        User3D.create_Volume = valueModifier__3D_create_Volume(1);
        User3D.create_Snap = valueModifier__3D_create_Snap(1);
        User3D.create_SphereDegree = valueModifier__3D_create_SphereDegree(1);
        User3D.create_CylinderDegree = valueModifier__3D_create_CylinderDegree(1);
        User3D.create_PolyDegree = valueModifier__3D_create_PolyDegree(1);
        User3D.create_Parametric_Type = valueModifier__3D_create_Parametric_Type(1);
        User3D.create_Person_Type = valueModifier__3D_create_Person_Type(1);
        User3D.create_Plant_Type = valueModifier__3D_create_Plant_Type(1);
      }

      if (this.child == CHILD_GEOMETRY_MODIFY) {

        User3D.modify_OpenningDepth = valueModifier__3D_modify_OpenningDepth(1);
        User3D.modify_OpenningArea = valueModifier__3D_modify_OpenningArea(1);
        User3D.modify_OpenningDeviation = valueModifier__3D_modify_OpenningDeviation(1);
        User3D.modify_TessellateRows = valueModifier__3D_modify_TessellateRows(1);
        User3D.modify_TessellateColumns = valueModifier__3D_modify_TessellateColumns(1);
        User3D.modify_OffsetAmount = valueModifier__3D_modify_OffsetAmount(1);
        User3D.modify_WeldTreshold = valueModifier__3D_modify_WeldTreshold(1);
        Select3D.softPower = valueModifier__3D_select_softPower(1);
        Select3D.softRadius = valueModifier__3D_select_softRadius(1);
        Select3D.posVector = valueModifier__3D_select_posVector(1);
        Select3D.rotVector = valueModifier__3D_select_rotVector(1);
        Select3D.scaleVector = valueModifier__3D_select_scaleVector(1);
        Select3D.posValue = valueModifier__3D_select_posValue(1);
        Select3D.rotValue = valueModifier__3D_select_rotValue(1);
        Select3D.scaleValue = valueModifier__3D_select_scaleValue(1);
        Select3D.alignX = valueModifier__3D_select_alignX(1);
        Select3D.alignY = valueModifier__3D_select_alignY(1);
        Select3D.alignZ = valueModifier__3D_select_alignZ(1);
      }

      if (this.child == CHILD_GEOMETRY_SOLID) {
        User3D.create_powAll = valueModifier__3D_create_powAll(1);
        User3D.create_powX = valueModifier__3D_create_powX(1);
        User3D.create_powY = valueModifier__3D_create_powY(1);
        User3D.create_powZ = valueModifier__3D_create_powZ(1);
      }


      if (this.child == CHILD_GEOMETRY_FRACTAL_TREE) {

        User3D.create_Model1D_Type = valueModifier__3D_create_Type(1);
        User3D.create_Model1D_DegreeMax = valueModifier__3D_create_DegreeMax(1);
        User3D.create_Model1D_Seed = valueModifier__3D_create_Seed(1);
        User3D.create_Model1D_TrunkSize = valueModifier__3D_create_TrunkSize(1);
        User3D.create_Model1D_LeafSize = valueModifier__3D_create_LeafSize(1);
        User3D.create_Model1D_BranchTilt = valueModifier__3D_create_BranchTilt(1);
        User3D.create_Model1D_BranchTwist = valueModifier__3D_create_BranchTwist(1);
        User3D.create_Model1D_BranchRatio = valueModifier__3D_create_BranchRatio(1);
        User3D.create_Model1D_TreeBase = valueModifier__3D_create_TreeBase(1);
      }

      if (this.child == CHILD_GEOMETRY_ENVIRONMENT) {

        Land3D.loadTextures = valueModifier_Land3D_loadTextures(1);
        Land3D.loadMesh = valueModifier_Land3D_loadMesh(1);
        Land3D.skipStart = valueModifier_Land3D_skipStart(1);
        Land3D.skipEnd = valueModifier_Land3D_skipEnd(1);
        Land3D.displaySurface = valueModifier_Land3D_displaySurface(1);
        Land3D.displayTexture = valueModifier_Land3D_displayTexture(1);
        Land3D.displayPoints = valueModifier_Land3D_displayPoints(1);
        Land3D.displayDepth = valueModifier_Land3D_displayDepth(1);
        allModel2Ds.displayAll = valueModifier_model2Ds_displayAll(1);
        allModel1Ds.displayAll = valueModifier_model1Ds_displayAll(1);
        allModel1Ds.displayLeaves = valueModifier_model1Ds_displayLeaves(1);
        allPolylines.displayAll = valueModifier_polylines_displayAll(1);
        allFaces.displayAll = valueModifier_faces_displayAll(1);
        allSolids.displayAll = valueModifier_solids_displayAll(1);
        allSections.displayAll = valueModifier_sections_displayAll(1);
        allWindRoses.displayImage = valueModifier_windRoses_displayImage(1);
        allWindRoses.scale = valueModifier_windRoses_scale(1);
        allWindRoses.RES = valueModifier_windRoses_resolution(1);



        Sky3D.displaySurface = valueModifier_Sky3D_displaySurface(1);
        Sun3D.displayPath = valueModifier_Sun3D_displayPath(1);
        Sun3D.displayPattern = valueModifier_Sun3D_displayPattern(1);
      }


      if (this.child == CHILD_GEOMETRY_VIEWPORT) {

        WIN3D.currentCamera = valueModifier_currentCamera(1);
        WIN3D.CAM_clipNear = valueModifier_Camera_clipNear(1);
        WIN3D.CAM_clipFar = valueModifier_Camera_clipFar(1);
        allPoints.displayAll = valueModifier_Create3D_displayVertices(1);
        allFaces.displayEdges = valueModifier_Create3D_displayEdges(1);
        allFaces.displayNormals = valueModifier_Create3D_displayNormals(1);
        allCameras.displayAll = valueModifier_cameras_displayAll(1);
      }


      if (this.child == CHILD_GEOMETRY_SIMULATION) {

        IMPACTS_displayDay = valueModifier_IMPACTS_displayDay(1);
        allSolarImpacts.displayImage = valueModifier_solarImpacts_displayImage(1);
        allSolidImpacts.displayImage = valueModifier_solidImpacts_displayImage(1);
        allSolarImpacts.sectionType = valueModifier_solarImpacts_sectionType(1);
        allSolidImpacts.sectionType = valueModifier_solidImpacts_sectionType(1);
        allSolidImpacts.Grade = valueModifier_solidImpacts_Grade(1);
        allSolidImpacts.Power = valueModifier_solidImpacts_Power(1);
        allSolidImpacts.R[allSolidImpacts.sectionType] = valueModifier_solidImpacts_R(1);
        allSolidImpacts.Z[allSolidImpacts.sectionType] = valueModifier_solidImpacts_Z(1);
        allSolidImpacts.positionStep = valueModifier_solidImpacts_positionStep(1);
        allSolidImpacts.U[allSolidImpacts.sectionType] = valueModifier_solidImpacts_U(1);
        allSolidImpacts.V[allSolidImpacts.sectionType] = valueModifier_solidImpacts_V(1);
        allSolidImpacts.X[allSolidImpacts.sectionType] = valueModifier_solidImpacts_X(1);
        allSolidImpacts.Y[allSolidImpacts.sectionType] = valueModifier_solidImpacts_Y(1);
        allSolidImpacts.WindSpeed = valueModifier_solidImpacts_WindSpeed_m_s(1);
        allSolidImpacts.WindDirection = valueModifier_solidImpacts_WindDirection(1);
        allSolidImpacts.Process_subDivisions = valueModifier_solidImpacts_Process_subDivisions(1);
        allSolidImpacts.displayPoints = valueModifier_solidImpacts_displayPoints(1);
        allSolidImpacts.displayLines = valueModifier_solidImpacts_displayLines(1);
        allWindFlows.displayAll = valueModifier_windFlows_displayAll(1);
      }

      if (this.child == CHILD_GEOMETRY_OTHER) {

        allFaces.displayTessellation = valueModifier__3D_create_displayTessellation(1);
        Land3D.displayTessellation = valueModifier_Land_displayTessellation(1);
        Sky3D.displayTessellation = valueModifier_Sky_displayTessellation(1);
          Sky3D.radius = valueModifier_Sky_scale(1);
        Tropo3D.displaySurface = valueModifier_Tropo3D_displaySurface(1);
        Tropo3D.displayTexture = valueModifier_Tropo3D_displayTexture(1);
        Earth3D.displaySurface = valueModifier_Earth3D_displaySurface(1);
        Earth3D.displayTexture = valueModifier_Earth3D_displayTexture(1);
        Earth3D.levelOfDetail = valueModifier_Earth3D_levelOfDetail(1);
        Earth3D.recomputeLevelOfDetailDependents();

        Moon3D.displaySurface = valueModifier_Moon3D_displaySurface(1);
        Moon3D.displayTexture = valueModifier_Moon3D_displayTexture(1);
        Moon3D.fitInSkyDome = valueModifier_Moon3D_fitInSkyDome(1);
        Sun3D.displaySurface = valueModifier_Sun3D_displaySurface(1);
        Sun3D.displayTexture = valueModifier_Sun3D_displayTexture(1);
        Sun3D.fitInSkyDome = valueModifier_Sun3D_fitInSkyDome(1);
        Planetary_Magnification = valueModifier_Planetary_Magnification(1);
        OBJECTS_scale = valueModifier_Objects_scale(1);
      }

    } else if (this.parent == PARENT_ILLUSTRATION) {

      if (this.child == CHILD_ILLUSTRATION_2D_LAYERS) {
        STUDY.plotSetup = valueModifier_Diagram_setup(1);
        STUDY.V_scale = valueModifier_Scale(1);
        STUDY.displayRaws = valueModifier_Draw_data(1);
        STUDY.displaySorted = valueModifier_Draw_sorted(1);
        STUDY.displayNormals = valueModifier_Draw_statistics(1);
        STUDY.displayProbs = valueModifier_Draw_probabilities(1);
        STUDY.sumInterval = valueModifier_Probabilities_interval(1);
        STUDY.LevelPix = valueModifier_Probabilities_range(1);
      }

      if (this.child == CHILD_ILLUSTRATION_2D_COLORS) {

        STUDY.ACTIVE_palette_CLR = valueModifier_STUDY_ACTIVE_palette_CLR(1);
        STUDY.ACTIVE_palette_DIR = valueModifier_STUDY_ACTIVE_palette_DIR(1);
        STUDY.ACTIVE_palette_MLT = valueModifier_STUDY_ACTIVE_palette_MLT(1);
        STUDY.PASSIVE_palette_CLR = valueModifier_STUDY_PASSIVE_palette_CLR(1);
        STUDY.PASSIVE_palette_DIR = valueModifier_STUDY_PASSIVE_palette_DIR(1);
        STUDY.PASSIVE_palette_MLT = valueModifier_STUDY_PASSIVE_palette_MLT(1);
        STUDY.SORT_palette_CLR = valueModifier_STUDY_SORT_palette_CLR(1);
        STUDY.SORT_palette_DIR = valueModifier_STUDY_SORT_palette_DIR(1);
        STUDY.SORT_palette_MLT = valueModifier_STUDY_SORT_palette_MLT(1);
        STUDY.PROB_palette_CLR = valueModifier_STUDY_PROB_palette_CLR(1);
        STUDY.PROB_palette_DIR = valueModifier_STUDY_PROB_palette_DIR(1);
        STUDY.PROB_palette_MLT = valueModifier_STUDY_PROB_palette_MLT(1);
        STUDY.O_scale = valueModifier_Windose_opacity_scale(1);
      }

      if (this.child == CHILD_ILLUSTRATION_3D_SOLAR) {

        allFaces.ACTIVE_palette_CLR = valueModifier_faces_ACTIVE_palette_CLR(1);
        allFaces.ACTIVE_palette_DIR = valueModifier_faces_ACTIVE_palette_DIR(1);
        allFaces.ACTIVE_palette_MLT = valueModifier_faces_ACTIVE_palette_MLT(1);
        allFaces.PASSIVE_palette_CLR = valueModifier_faces_PASSIVE_palette_CLR(1);
        allFaces.PASSIVE_palette_DIR = valueModifier_faces_PASSIVE_palette_DIR(1);
        allFaces.PASSIVE_palette_MLT = valueModifier_faces_PASSIVE_palette_MLT(1);
        Sky3D.ACTIVE_palette_CLR = valueModifier_Sky3D_ACTIVE_palette_CLR(1);
        Sky3D.ACTIVE_palette_DIR = valueModifier_Sky3D_ACTIVE_palette_DIR(1);
        Sky3D.ACTIVE_palette_MLT = valueModifier_Sky3D_ACTIVE_palette_MLT(1);
        Sky3D.PASSIVE_palette_CLR = valueModifier_Sky3D_PASSIVE_palette_CLR(1);
        Sky3D.PASSIVE_palette_DIR = valueModifier_Sky3D_PASSIVE_palette_DIR(1);
        Sky3D.PASSIVE_palette_MLT = valueModifier_Sky3D_PASSIVE_palette_MLT(1);
        Sun3D.ACTIVE_palette_CLR = valueModifier_Sun3D_ACTIVE_palette_CLR(1);
        Sun3D.ACTIVE_palette_DIR = valueModifier_Sun3D_ACTIVE_palette_DIR(1);
        Sun3D.ACTIVE_palette_MLT = valueModifier_Sun3D_ACTIVE_palette_MLT(1);
        Sun3D.PASSIVE_palette_CLR = valueModifier_Sun3D_PASSIVE_palette_CLR(1);
        Sun3D.PASSIVE_palette_DIR = valueModifier_Sun3D_PASSIVE_palette_DIR(1);
        Sun3D.PASSIVE_palette_MLT = valueModifier_Sun3D_PASSIVE_palette_MLT(1);
      }




      if (this.child == CHILD_ILLUSTRATION_3D_SPATIAL) {

        allSolids.palette_CLR = valueModifier_solids_palette_CLR(1);
        allSolids.palette_DIR = valueModifier_solids_palette_DIR(1);
        allSolids.palette_MLT = valueModifier_solids_palette_MLT(1);
        Land3D.palette_CLR = valueModifier_Land3D_palette_CLR(1);
        Land3D.palette_DIR = valueModifier_Land3D_palette_DIR(1);
        Land3D.palette_MLT = valueModifier_Land3D_palette_MLT(1);
        allWindFlows.palette_CLR = valueModifier_windFlows_palette_CLR(1);
        allWindFlows.palette_DIR = valueModifier_windFlows_palette_DIR(1);
        allWindFlows.palette_MLT = valueModifier_windFlows_palette_MLT(1);
      }


      if (this.child == CHILD_ILLUSTRATION_SELECTION) {

        Select3D.Group_displayPivot = valueModifier__3D_select_Group_displayPivot(1);
        Select3D.displayReferencePivot = valueModifier__3D_select_displayReferencePivot(1);
        Select3D.Group_displayBox = valueModifier__3D_select_Group_displayBox(1);
        Select3D.Group_displayEdges = valueModifier__3D_select_Group_displayEdges(1);
        Select3D.Face_displayEdges = valueModifier__3D_select_Face_displayEdges(1);
        Select3D.Face_displayVertexCount = valueModifier__3D_select_Face_displayVertexCount(1);
        Select3D.Polyline_displayVertexCount = valueModifier__3D_select_Polyline_displayVertexCount(1);
        Select3D.Vertex_displayVertices = valueModifier__3D_select_Vertex_displayVertices(1);
        Select3D.Polyline_displayVertices = valueModifier__3D_select_Polyline_displayVertices(1);
        Select3D.Model2D_displayEdges = valueModifier__3D_select_Model2D_displayEdges(1);
        Select3D.Model1D_displayEdges = valueModifier__3D_select_Model1D_displayEdges(1);
        Select3D.Solid_displayEdges = valueModifier__3D_select_Solid_displayEdges(1);
        Select3D.Section_displayEdges = valueModifier__3D_select_Section_displayEdges(1);
        Select3D.Camera_displayEdges = valueModifier__3D_select_Camera_displayEdges(1);
        Select3D.LandPoint_displayPoints = valueModifier__3D_select_LandPoint_displayPoints(1);
      }
    } else if (this.parent == PARENT_POSTPROCESS) {

      if (this.child == CHILD_POSTPROCESS_INTERPOLATION) {

        Interpolation_Weight = valueModifier_Interpolation_Weight(1);
        CLIMATIC_SolarForecast = valueModifier_Climate_based_solar_forecast(1);
        CLIMATIC_WeatherForecast = valueModifier_Climate_based_temperature_forecast(1);
      }
      if (this.child == CHILD_POSTPROCESS_DEVELOPED) {
        Develop_Option = valueModifier_Develop_Option(1);
        Develop_DayHour = valueModifier_Develop_DayHour(1);
        STUDY.TrendJoinHours = valueModifier_Trend_period_hours(1);
        STUDY.TrendJoinType = valueModifier_Weighted_equal_trend(1);
        Develop_AngleInclination = valueModifier_Inclination_angle(1);
        Develop_AngleOrientation = valueModifier_Orientation_angle(1);
      }
      if (this.child == CHILD_POSTPROCESS_IMPACTS) {
        CurrentDataSource = valueModifier_Impact_Source(1);
        STUDY.ImpactLayer = valueModifier_Impact_Min_50_Max(1);
      }
    } else if (this.parent == PARENT_EXPORT) {

      if (this.child == CHILD_EXPORT_DATA) {

        STUDY.export_info_node = valueModifier_Export_ASCII_data(1);
        STUDY.export_info_norm = valueModifier_Export_ASCII_statistics(1);
        STUDY.export_info_prob = valueModifier_Export_ASCII_probabilities(1);
        User3D.export_Scale = valueModifier__3D_export_Scale(1);
        User3D.export_FlipZYaxis = valueModifier__3D_export_FlipZYaxis(1);
        User3D.export_PrecisionVertex = valueModifier__3D_export_PrecisionVertex(1);
        User3D.export_PrecisionVtexture = valueModifier__3D_export_PrecisionVtexture(1);
        User3D.export_PolyToPoly = valueModifier__3D_export_PolyToPoly(1);
        User3D.export_MaterialLibrary = valueModifier__3D_export_MaterialLibrary(1);
        User3D.export_BackSides = valueModifier__3D_export_BackSides(1);
        User3D.export_PaletteResolution = valueModifier__3D_export_PaletteResolution(1);
      }

      if (this.child == CHILD_EXPORT_MEDIA) {

        allSolidImpacts.record_IMG = valueModifier_Record_SolidImpact_in_JPG(1);
        allSolidImpacts.record_PDF = valueModifier_Record_SolidImpact_in_PDF(1);
        allSolarImpacts.record_IMG = valueModifier_Record_Solar_Analysis_in_JPG(1);
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
