// One method per this.Spinner(...) call in UI_rollout.draw(), so its
// caption, bounds, update flags and (where relevant) OnChange follow-up
// are written exactly once rather than once in draw() and again in
// UI_rollout.registerSpinnerActions(). Call with created == 0 once, at
// registration time, to register the matching command-line action; call
// with created == 1 from UI_rollout.draw() to actually render the
// spinner and get back its (possibly new) value.
//
// The two branches stay independent on purpose: created == 1 never calls
// putValueAction, and created == 0 never calls UI_rollout.Spinner(...).
// Threading OnChange through Spinner(...) itself was tried and reverted:
// onChanged would fire before the caller applies the returned value to
// the field, so a callback re-reading that same field would see the old
// value. Keeping registration and rendering as separate calls avoids
// reintroducing that bug.
class ValueModifier {

  int Number_of_days_to_plot (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Number of days to plot", STUDY.j_End, s1, s2, s3);
    }
    return out;
  }
  float Day_step (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Day step", STUDY.perDays, s1, s2, s3);
    }
    return out;
  }
  int Join_days (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Join days", STUDY.joinDays, s1, s2, s3);
    }
    return out;
  }
  float Days_past_March_equinox (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Days past March equinox", TIME.date, s1, s2, s3);
    }
    return out;
  }
  int Begin_day (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Begin day", TIME.day, s1, s2, s3);
    }
    return out;
  }
  int Begin_month (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Begin month", TIME.month, s1, s2, s3);
    }
    return out;
  }
  int Begin_year (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Begin year", TIME.year, s1, s2, s3);
    }
    return out;
  }
  int Start_hour (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Start hour", STUDY.i_Start, s1, s2, s3);
    }
    return out;
  }
  int End_hour (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "End hour", STUDY.i_End, s1, s2, s3);
    }
    return out;
  }
  int Start_year (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Start year", SampleYear_Start, CLIMATE_CWEEDS_start, CLIMATE_CLMREC_end, 1);
    }
    return out;
  }
  int End_year (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "End year", SampleYear_End, CLIMATE_CWEEDS_start, CLIMATE_CLMREC_end, 1);
    }
    return out;
  }
  int Start_member (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Start member", SampleMember_Start, ENSEMBLE_FORECAST_start, ENSEMBLE_FORECAST_end, 1);
    }
    return out;
  }
  int End_member (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "End member", SampleMember_End, ENSEMBLE_FORECAST_start, ENSEMBLE_FORECAST_end, 1);
    }
    return out;
  }
  int Start_station (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Start station", SampleStation_Start, ENSEMBLE_OBSERVED_start, ENSEMBLE_OBSERVED_end, 1);
    }
    return out;
  }
  int End_station (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "End station", SampleStation_End, ENSEMBLE_OBSERVED_start, ENSEMBLE_OBSERVED_end, 1);
    }
    return out;
  }
  int Forecast_Obs_maxDays (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Forecast/Obs_maxDays", ENSEMBLE_OBSERVED_maxDays, s1, s2, s3);
    }
    return out;
  }
  int Sky_status (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky status", STUDY.skyScenario, s1, s2, s3);
    }
    return out;
  }
  int Hourly_daily_filter (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Hourly/daily filter", STUDY.filter, s1, s2, s3);
    }
    return out;
  }
  float Latitude (int created) {
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
        (v) -> { STATION.setLatitude(v); update_station(0); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Latitude", LocationLAT, s1, s2, s3);
    }
    return out;
  }
  float Longitude (int created) {
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
        (v) -> { STATION.setLongitude(v); update_station(0); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Longitude", LocationLON, s1, s2, s3);
    }
    return out;
  }
  int displayAll_TMYEPW (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "displayAll_TMYEPW", WORLD.displayAll_TMYEPW, s1, s2, s3);
    }
    return out;
  }
  boolean displayNear_TMYEPW (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "displayNear_TMYEPW", WORLD.displayNear_TMYEPW);
    }
    return out;
  }
  int displayAll_CWEEDS (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "displayAll_CWEEDS", WORLD.displayAll_CWEEDS, s1, s2, s3);
    }
    return out;
  }
  boolean displayNear_CWEEDS (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "displayNear_CWEEDS", WORLD.displayNear_CWEEDS);
    }
    return out;
  }
  int displayAll_CLMREC (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "displayAll_CLMREC", WORLD.displayAll_CLMREC, s1, s2, s3);
    }
    return out;
  }
  boolean displayNear_CLMREC (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "displayNear_CLMREC", WORLD.displayNear_CLMREC);
    }
    return out;
  }
  int displayAll_SWOB (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "displayAll_SWOB", WORLD.displayAll_SWOB, s1, s2, s3);
    }
    return out;
  }
  boolean displayNear_SWOB (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "displayNear_SWOB", WORLD.displayNear_SWOB);
    }
    return out;
  }
  int displayAll_NAEFS (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "displayAll_NAEFS", WORLD.displayAll_NAEFS, s1, s2, s3);
    }
    return out;
  }
  boolean displayNear_NAEFS (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "displayNear_NAEFS", WORLD.displayNear_NAEFS);
    }
    return out;
  }
  boolean addToLastGroup (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "addToLastGroup", addToLastGroup);
    }
    return out;
  }
  int _3D_create_Material (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Material", User3D.default_Material, s1, s2, s3);
    }
    return out;
  }
  int _3D_create_Tessellation (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Tessellation", User3D.default_Tessellation, s1, s2, s3);
    }
    return out;
  }
  int _3D_create_Layer (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Layer", User3D.default_Layer, s1, s2, s3);
    }
    return out;
  }
  int _3D_create_Visibility (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Visibility", User3D.default_Visibility, s1, s2, s3);
    }
    return out;
  }
  int _3D_create_Weight (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Weight", User3D.default_Weight, s1, s2, s3);
    }
    return out;
  }
  int _3D_create_Closed (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Closed", User3D.default_Closed, s1, s2, s3);
    }
    return out;
  }
  float _3D_create_Orientation (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Orientation", User3D.create_Orientation, s1, s2, s3, s4);
    }
    return out;
  }
  float _3D_create_Length_rand_negative (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Length (rand negative)", User3D.create_Length, s1, s2, s3, s4);
    }
    return out;
  }
  float _3D_create_Width_rand_negative (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Width (rand negative)", User3D.create_Width, s1, s2, s3, s4);
    }
    return out;
  }
  float _3D_create_Height_rand_negative (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Height (rand negative)", User3D.create_Height, s1, s2, s3, s4);
    }
    return out;
  }
  float _3D_create_Volume (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Volume", User3D.create_Volume, s1, s2, s3, s4);
    }
    return out;
  }
  int _3D_create_Snap (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Snap", User3D.create_Snap, s1, s2, s3);
    }
    return out;
  }
  int _3D_create_SphereDegree (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.SphereDegree", User3D.create_SphereDegree, s1, s2, s3);
    }
    return out;
  }
  int _3D_create_CylinderDegree (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.CylinderDegree", User3D.create_CylinderDegree, s1, s2, s3);
    }
    return out;
  }
  int _3D_create_PolyDegree (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.PolyDegree", User3D.create_PolyDegree, s1, s2, s3);
    }
    return out;
  }
  int _3D_create_Parametric_Type (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Parametric_Type", User3D.create_Parametric_Type, s1, s2, s3);
    }
    return out;
  }
  int _3D_create_Person_Type (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Person_Type", User3D.create_Person_Type, 0, allModel2Ds.num_files_PEOPLE, 1);
    }
    return out;
  }
  int _3D_create_Plant_Type (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Plant_Type", User3D.create_Plant_Type, 0, allModel2Ds.num_files_TREES, 1);
    }
    return out;
  }
  float _3D_modify_OpenningDepth (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-modify.OpenningDepth", User3D.modify_OpenningDepth, s1, s2, s3);
    }
    return out;
  }
  float _3D_modify_OpenningArea (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-modify.OpenningArea", User3D.modify_OpenningArea, s1, s2, s3);
    }
    return out;
  }
  float _3D_modify_OpenningDeviation (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-modify.OpenningDeviation", User3D.modify_OpenningDeviation, s1, s2, s3);
    }
    return out;
  }
  int _3D_modify_TessellateRows (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-modify.TessellateRows", User3D.modify_TessellateRows, s1, s2, s3);
    }
    return out;
  }
  int _3D_modify_TessellateColumns (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-modify.TessellateColumns", User3D.modify_TessellateColumns, s1, s2, s3);
    }
    return out;
  }
  float _3D_modify_OffsetAmount (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-modify.OffsetAmount", User3D.modify_OffsetAmount, s1, s2, s3);
    }
    return out;
  }
  float _3D_modify_WeldTreshold (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-modify.WeldTreshold", User3D.modify_WeldTreshold, s1, s2, s3);
    }
    return out;
  }
  float _3D_select_softPower (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.softPower", Select3D.softPower, s1, s2, s3, s4);
    }
    return out;
  }
  float _3D_select_softRadius (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.softRadius", Select3D.softRadius, s1, s2, s3, s4);
    }
    return out;
  }
  int _3D_select_posVector (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.posVector", Select3D.posVector, s1, s2, s3);
    }
    return out;
  }
  int _3D_select_rotVector (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.rotVector", Select3D.rotVector, s1, s2, s3);
    }
    return out;
  }
  int _3D_select_scaleVector (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.scaleVector", Select3D.scaleVector, s1, s2, s3);
    }
    return out;
  }
  float _3D_select_posValue (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.posValue", Select3D.posValue, s1, s2, s3, s4);
    }
    return out;
  }
  float _3D_select_rotValue (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.rotValue", Select3D.rotValue, s1, s2, s3, s4);
    }
    return out;
  }
  float _3D_select_scaleValue (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.scaleValue", Select3D.scaleValue, s1, s2, s3, s4);
    }
    return out;
  }
  int _3D_select_alignX (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.alignX", Select3D.alignX, s1, s2, s3);
    }
    return out;
  }
  int _3D_select_alignY (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.alignY", Select3D.alignY, s1, s2, s3);
    }
    return out;
  }
  int _3D_select_alignZ (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.alignZ", Select3D.alignZ, s1, s2, s3);
    }
    return out;
  }
  float _3D_create_powAll (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.powAll", User3D.create_powAll, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }
  float _3D_create_powX (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.powX", User3D.create_powX, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }
  float _3D_create_powY (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.powY", User3D.create_powY, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }
  float _3D_create_powZ (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.powZ", User3D.create_powZ, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }
  int _3D_create_Type (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Type", User3D.create_Model1D_Type, s1, s2, s3);
    }
    return out;
  }
  int _3D_create_DegreeMax (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.DegreeMax", User3D.create_Model1D_DegreeMax, s1, s2, s3);
    }
    return out;
  }
  int _3D_create_Seed (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.Seed", User3D.create_Model1D_Seed, s1, s2, s3);
    }
    return out;
  }
  float _3D_create_TrunkSize (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.TrunkSize", User3D.create_Model1D_TrunkSize, s1, s2, s3, s4);
    }
    return out;
  }
  float _3D_create_LeafSize (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.LeafSize", User3D.create_Model1D_LeafSize, s1, s2, s3, s4);
    }
    return out;
  }
  float _3D_create_BranchTilt (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.BranchTilt", User3D.create_Model1D_BranchTilt, s1, s2, s3, s4);
    }
    return out;
  }
  float _3D_create_BranchTwist (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.BranchTwist", User3D.create_Model1D_BranchTwist, s1, s2, s3, s4);
    }
    return out;
  }
  float _3D_create_BranchRatio (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.BranchRatio", User3D.create_Model1D_BranchRatio, s1, s2, s3, s4);
    }
    return out;
  }
  float _3D_create_TreeBase (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.TreeBase", User3D.create_Model1D_TreeBase, s1, s2, s3, s4);
    }
    return out;
  }
  boolean Land3D_loadTextures (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.loadTextures", Land3D.loadTextures);
    }
    return out;
  }
  boolean Land3D_loadMesh (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.loadMesh", Land3D.loadMesh);
    }
    return out;
  }
  int Land3D_skipStart (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.skipStart", Land3D.skipStart, 0, Land3D.num_rows - 1, 1);
    }
    return out;
  }
  int Land3D_skipEnd (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.skipEnd", Land3D.skipEnd, 0, Land3D.num_rows - 1, 1);
    }
    return out;
  }
  boolean Land3D_displaySurface (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.displaySurface", Land3D.displaySurface);
    }
    return out;
  }
  boolean Land3D_displayTexture (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.displayTexture", Land3D.displayTexture);
    }
    return out;
  }
  boolean Land3D_displayPoints (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.displayPoints", Land3D.displayPoints);
    }
    return out;
  }
  boolean Land3D_displayDepth (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.displayDepth", Land3D.displayDepth);
    }
    return out;
  }
  boolean model2Ds_displayAll (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "model2Ds.displayAll", allModel2Ds.displayAll);
    }
    return out;
  }
  boolean model1Ds_displayAll (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "model1Ds.displayAll", allModel1Ds.displayAll);
    }
    return out;
  }
  boolean model1Ds_displayLeaves (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "model1Ds.displayLeaves", allModel1Ds.displayLeaves);
    }
    return out;
  }
  boolean polylines_displayAll (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "polylines.displayAll", allPolylines.displayAll);
    }
    return out;
  }
  boolean faces_displayAll (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "faces.displayAll", allFaces.displayAll);
    }
    return out;
  }
  boolean solids_displayAll (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solids.displayAll", allSolids.displayAll);
    }
    return out;
  }
  boolean sections_displayAll (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "sections.displayAll", allSections.displayAll);
    }
    return out;
  }
  boolean windRoses_displayImage (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "windRoses.displayImage", allWindRoses.displayImage);
    }
    return out;
  }
  float windRoses_scale (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "windRoses.scale", allWindRoses.scale, s1, s2, s3, s4);
    }
    return out;
  }
  boolean Sky3D_displaySurface (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D.displaySurface", Sky3D.displaySurface);
    }
    return out;
  }
  boolean Sun3D_displayPath (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.displayPath", Sun3D.displayPath);
    }
    return out;
  }
  boolean Sun3D_displayPattern (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.displayPattern", Sun3D.displayPattern);
    }
    return out;
  }
  int currentCamera (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "currentCamera", WIN3D.currentCamera, 0, allCameras.num, 1);
    }
    return out;
  }
  float Camera_clipNear (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Camera_clipNear", WIN3D.CAM_clipNear, s1, s2, s3, s4);
    }
    return out;
  }
  float Camera_clipFar (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Camera_clipFar", WIN3D.CAM_clipFar, s1, s2, s3, s4);
    }
    return out;
  }
  boolean Create3D_displayVertices (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D.displayVertices", allPoints.displayAll);
    }
    return out;
  }
  boolean Create3D_displayEdges (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D.displayEdges", allFaces.displayEdges);
    }
    return out;
  }
  boolean Create3D_displayNormals (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D.displayNormals", allFaces.displayNormals);
    }
    return out;
  }
  boolean cameras_displayAll (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "cameras.displayAll", allCameras.displayAll);
    }
    return out;
  }
  int IMPACTS_displayDay (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "IMPACTS_displayDay", IMPACTS_displayDay, 0, STUDY.j_End - STUDY.j_Start, 1);
    }
    return out;
  }
  boolean solarImpacts_displayImage (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solarImpacts.displayImage", allSolarImpacts.displayImage);
    }
    return out;
  }
  boolean solidImpacts_displayImage (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.displayImage", allSolidImpacts.displayImage);
    }
    return out;
  }
  int solarImpacts_sectionType (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solarImpacts.sectionType", allSolarImpacts.sectionType, s1, s2, s3);
    }
    return out;
  }
  int solidImpacts_sectionType (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.sectionType", allSolidImpacts.sectionType, s1, s2, s3);
    }
    return out;
  }
  float solidImpacts_Grade (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.Grade", allSolidImpacts.Grade, s1, s2, s3, s4);
    }
    return out;
  }
  float solidImpacts_Power (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.Power", allSolidImpacts.Power, s1, s2, s3, s4);
    }
    return out;
  }
  float solidImpacts_R (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.R[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.R[allSolidImpacts.sectionType], s1, s2, s3, s4);
    }
    return out;
  }
  float solidImpacts_Z (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.Z[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.Z[allSolidImpacts.sectionType], s1, s2, s3, s4);
    }
    return out;
  }
  float solidImpacts_positionStep (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.positionStep", allSolidImpacts.positionStep, s1, s2, s3, s4);
    }
    return out;
  }
  float solidImpacts_U (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.U[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.U[allSolidImpacts.sectionType], s1, s2, s3, s4);
    }
    return out;
  }
  float solidImpacts_V (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.V[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.V[allSolidImpacts.sectionType], s1, s2, s3, s4);
    }
    return out;
  }
  float solidImpacts_X (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.X[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.X[allSolidImpacts.sectionType], s1, s2, s3, s4);
    }
    return out;
  }
  float solidImpacts_Y (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.Y[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.Y[allSolidImpacts.sectionType], s1, s2, s3, s4);
    }
    return out;
  }
  float solidImpacts_WindSpeed_m_s (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.WindSpeed (m/s)", allSolidImpacts.WindSpeed, s1, s2, s3, s4);
    }
    return out;
  }
  float solidImpacts_WindDirection (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.WindDirection", allSolidImpacts.WindDirection, s1, s2, s3);
    }
    return out;
  }
  int solidImpacts_Process_subDivisions (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.Process_subDivisions", allSolidImpacts.Process_subDivisions, s1, s2, s3);
    }
    return out;
  }
  boolean solidImpacts_displayPoints (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.displayPoints", allSolidImpacts.displayPoints);
    }
    return out;
  }
  boolean solidImpacts_displayLines (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solidImpacts.displayLines", allSolidImpacts.displayLines);
    }
    return out;
  }
  boolean windFlows_displayAll (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "windFlows.displayAll", allWindFlows.displayAll);
    }
    return out;
  }
  int _3D_create_displayTessellation (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-create.displayTessellation", allFaces.displayTessellation, s1, s2, s3);
    }
    return out;
  }
  int Land_displayTessellation (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Land.displayTessellation", Land3D.displayTessellation, s1, s2, s3);
    }
    return out;
  }
  int Sky_displayTessellation (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky.displayTessellation", Sky3D.displayTessellation, s1, s2, s3);
    }
    return out;
  }
  float Sky_scale (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky.scale", Sky3D.radius, s1, s2, s3, s4);
    }
    return out;
  }
  boolean Tropo3D_displaySurface (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Tropo3D.displaySurface", Tropo3D.displaySurface);
    }
    return out;
  }
  boolean Tropo3D_displayTexture (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Tropo3D.displayTexture", Tropo3D.displayTexture);
    }
    return out;
  }
  boolean Earth3D_displaySurface (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Earth3D.displaySurface", Earth3D.displaySurface);
    }
    return out;
  }
  boolean Earth3D_displayTexture (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Earth3D.displayTexture", Earth3D.displayTexture);
    }
    return out;
  }
  float Earth3D_levelOfDetail (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Earth3D.levelOfDetail", Earth3D.levelOfDetail, s1, s2, s3, s4);
    }
    return out;
  }
  boolean Moon3D_displaySurface (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Moon3D.displaySurface", Moon3D.displaySurface);
    }
    return out;
  }
  boolean Moon3D_displayTexture (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Moon3D.displayTexture", Moon3D.displayTexture);
    }
    return out;
  }
  boolean Moon3D_fitInSkyDome (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Moon3D.fitInSkyDome", Moon3D.fitInSkyDome);
    }
    return out;
  }
  boolean Sun3D_displaySurface (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.displaySurface", Sun3D.displaySurface);
    }
    return out;
  }
  boolean Sun3D_displayTexture (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.displayTexture", Sun3D.displayTexture);
    }
    return out;
  }
  boolean Sun3D_fitInSkyDome (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.fitInSkyDome", Sun3D.fitInSkyDome);
    }
    return out;
  }
  float Planetary_Magnification (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Planetary_Magnification", Planetary_Magnification, s1, s2, s3);
    }
    return out;
  }
  float Objects_scale (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Objects_scale", OBJECTS_scale, s1, s2, s3, s4);
    }
    return out;
  }
  int Diagram_setup (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Diagram setup", STUDY.plotSetup, s1, s2, s3);
    }
    return out;
  }
  float Scale (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Scale (" + allLayers[CurrentLayer_id].descriptions[Language_EN] + ")", STUDY.V_scale, s1, s2, s3);
    }
    return out;
  }
  boolean Draw_data (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Draw data", STUDY.displayRaws);
    }
    return out;
  }
  boolean Draw_sorted (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Draw sorted", STUDY.displaySorted);
    }
    return out;
  }
  boolean Draw_statistics (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Draw statistics", STUDY.displayNormals);
    }
    return out;
  }
  boolean Draw_probabilities (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Draw probabilities", STUDY.displayProbs);
    }
    return out;
  }
  int Probabilities_interval (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Probabilities interval", STUDY.sumInterval, s1, s2, s3);
    }
    return out;
  }
  float Probabilities_range (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Probabilities range", STUDY.LevelPix, s1, s2, s3, s4);
    }
    return out;
  }
  int STUDY_ACTIVE_palette_CLR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.ACTIVE_palette_CLR", STUDY.ACTIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }
  int STUDY_ACTIVE_palette_DIR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.ACTIVE_palette_DIR", STUDY.ACTIVE_palette_DIR, s1, s2, s3);
    }
    return out;
  }
  float STUDY_ACTIVE_palette_MLT (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.ACTIVE_palette_MLT", STUDY.ACTIVE_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }
  int STUDY_PASSIVE_palette_CLR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.PASSIVE_palette_CLR", STUDY.PASSIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }
  int STUDY_PASSIVE_palette_DIR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.PASSIVE_palette_DIR", STUDY.PASSIVE_palette_DIR, s1, s2, s3, s4);
    }
    return out;
  }
  float STUDY_PASSIVE_palette_MLT (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.PASSIVE_palette_MLT", STUDY.PASSIVE_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }
  int STUDY_SORT_palette_CLR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.SORT_palette_CLR", STUDY.SORT_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }
  int STUDY_SORT_palette_DIR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.SORT_palette_DIR", STUDY.SORT_palette_DIR, s1, s2, s3, s4);
    }
    return out;
  }
  float STUDY_SORT_palette_MLT (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.SORT_palette_MLT", STUDY.SORT_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }
  int STUDY_PROB_palette_CLR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.PROB_palette_CLR", STUDY.PROB_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }
  int STUDY_PROB_palette_DIR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.PROB_palette_DIR", STUDY.PROB_palette_DIR, s1, s2, s3, s4);
    }
    return out;
  }
  float STUDY_PROB_palette_MLT (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "STUDY.PROB_palette_MLT", STUDY.PROB_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }
  float Windose_opacity_scale (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Windose opacity scale", STUDY.O_scale, s1, s2, s3);
    }
    return out;
  }
  int faces_ACTIVE_palette_CLR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "faces.ACTIVE_palette_CLR", allFaces.ACTIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }
  int faces_ACTIVE_palette_DIR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "faces.ACTIVE_palette_DIR", allFaces.ACTIVE_palette_DIR, s1, s2, s3);
    }
    return out;
  }
  float faces_ACTIVE_palette_MLT (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "faces.ACTIVE_palette_MLT", allFaces.ACTIVE_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }
  int faces_PASSIVE_palette_CLR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "faces.PASSIVE_palette_CLR", allFaces.PASSIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }
  int faces_PASSIVE_palette_DIR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "faces.PASSIVE_palette_DIR", allFaces.PASSIVE_palette_DIR, s1, s2, s3, s4);
    }
    return out;
  }
  float faces_PASSIVE_palette_MLT (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "faces.PASSIVE_palette_MLT", allFaces.PASSIVE_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }
  int Sky3D_ACTIVE_palette_CLR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D.ACTIVE_palette_CLR", Sky3D.ACTIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }
  int Sky3D_ACTIVE_palette_DIR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D.ACTIVE_palette_DIR", Sky3D.ACTIVE_palette_DIR, s1, s2, s3);
    }
    return out;
  }
  float Sky3D_ACTIVE_palette_MLT (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D.ACTIVE_palette_MLT", Sky3D.ACTIVE_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }
  int Sky3D_PASSIVE_palette_CLR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D.PASSIVE_palette_CLR", Sky3D.PASSIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }
  int Sky3D_PASSIVE_palette_DIR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D.PASSIVE_palette_DIR", Sky3D.PASSIVE_palette_DIR, s1, s2, s3, s4);
    }
    return out;
  }
  float Sky3D_PASSIVE_palette_MLT (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D.PASSIVE_palette_MLT", Sky3D.PASSIVE_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }
  int Sun3D_ACTIVE_palette_CLR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.ACTIVE_palette_CLR", Sun3D.ACTIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }
  int Sun3D_ACTIVE_palette_DIR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.ACTIVE_palette_DIR", Sun3D.ACTIVE_palette_DIR, s1, s2, s3);
    }
    return out;
  }
  float Sun3D_ACTIVE_palette_MLT (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.ACTIVE_palette_MLT", Sun3D.ACTIVE_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }
  int Sun3D_PASSIVE_palette_CLR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.PASSIVE_palette_CLR", Sun3D.PASSIVE_palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }
  int Sun3D_PASSIVE_palette_DIR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.PASSIVE_palette_DIR", Sun3D.PASSIVE_palette_DIR, s1, s2, s3, s4);
    }
    return out;
  }
  float Sun3D_PASSIVE_palette_MLT (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D.PASSIVE_palette_MLT", Sun3D.PASSIVE_palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }
  int solids_palette_CLR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solids.palette_CLR", allSolids.palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }
  int solids_palette_DIR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solids.palette_DIR", allSolids.palette_DIR, s1, s2, s3, s4);
    }
    return out;
  }
  float solids_palette_MLT (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "solids.palette_MLT", allSolids.palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }
  int Land3D_palette_CLR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.palette_CLR", Land3D.palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }
  int Land3D_palette_DIR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.palette_DIR", Land3D.palette_DIR, s1, s2, s3, s4);
    }
    return out;
  }
  float Land3D_palette_MLT (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Land3D.palette_MLT", Land3D.palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }
  int windFlows_palette_CLR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "windFlows.palette_CLR", allWindFlows.palette_CLR, -1, (COLOR_STYLE_Number - 1), 1);
    }
    return out;
  }
  int windFlows_palette_DIR (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "windFlows.palette_DIR", allWindFlows.palette_DIR, s1, s2, s3, s4);
    }
    return out;
  }
  float windFlows_palette_MLT (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "windFlows.palette_MLT", allWindFlows.palette_MLT, s1, s2, s3, s4);
    }
    return out;
  }
  boolean _3D_select_Group_displayPivot (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Group_displayPivot", Select3D.Group_displayPivot);
    }
    return out;
  }
  boolean _3D_select_displayReferencePivot (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.displayReferencePivot", Select3D.displayReferencePivot);
    }
    return out;
  }
  boolean _3D_select_Group_displayBox (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Group_displayBox", Select3D.Group_displayBox);
    }
    return out;
  }
  boolean _3D_select_Group_displayEdges (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Group_displayEdges", Select3D.Group_displayEdges);
    }
    return out;
  }
  boolean _3D_select_Face_displayEdges (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Face_displayEdges", Select3D.Face_displayEdges);
    }
    return out;
  }
  boolean _3D_select_Face_displayVertexCount (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Face_displayVertexCount", Select3D.Face_displayVertexCount);
    }
    return out;
  }
  boolean _3D_select_Polyline_displayVertexCount (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Polyline_displayVertexCount", Select3D.Polyline_displayVertexCount);
    }
    return out;
  }
  boolean _3D_select_Vertex_displayVertices (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Vertex_displayVertices", Select3D.Vertex_displayVertices);
    }
    return out;
  }
  boolean _3D_select_Polyline_displayVertices (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Polyline_displayVertices", Select3D.Polyline_displayVertices);
    }
    return out;
  }
  boolean _3D_select_Model2D_displayEdges (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Model2D_displayEdges", Select3D.Model2D_displayEdges);
    }
    return out;
  }
  boolean _3D_select_Model1D_displayEdges (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Model1D_displayEdges", Select3D.Model1D_displayEdges);
    }
    return out;
  }
  boolean _3D_select_Solid_displayEdges (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Solid_displayEdges", Select3D.Solid_displayEdges);
    }
    return out;
  }
  boolean _3D_select_Section_displayEdges (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Section_displayEdges", Select3D.Section_displayEdges);
    }
    return out;
  }
  boolean _3D_select_Camera_displayEdges (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.Camera_displayEdges", Select3D.Camera_displayEdges);
    }
    return out;
  }
  boolean _3D_select_LandPoint_displayPoints (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-select.LandPoint_displayPoints", Select3D.LandPoint_displayPoints);
    }
    return out;
  }
  float Interpolation_Weight (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Interpolation_Weight", Interpolation_Weight, s1, s2, s3);
    }
    return out;
  }
  int Climate_based_solar_forecast (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Climate-based solar forecast", CLIMATIC_SolarForecast, s1, s2, s3);
    }
    return out;
  }
  int Climate_based_temperature_forecast (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Climate-based temperature forecast", CLIMATIC_WeatherForecast, s1, s2, s3);
    }
    return out;
  }
  int Develop_Option (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Develop_Option", Develop_Option, s1, s2, s3);
    }
    return out;
  }
  int Develop_DayHour (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Develop_DayHour", Develop_DayHour, s1, s2, s3);
    }
    return out;
  }
  int Trend_period_hours (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Trend period hours", STUDY.TrendJoinHours, s1, s2, s3);
    }
    return out;
  }
  int Weighted_equal_trend (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Weighted/equal trend", STUDY.TrendJoinType, s1, s2, s3, s4);
    }
    return out;
  }
  float Inclination_angle (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Inclination angle", Develop_AngleInclination, s1, s2, s3, s4);
    }
    return out;
  }
  float Orientation_angle (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Orientation angle", Develop_AngleOrientation, s1, s2, s3, s4);
    }
    return out;
  }
  int Impact_Source (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Impact Source", CurrentDataSource, 0, MAXIMUM_dataID, 1);
    }
    return out;
  }
  int Impact_Min_50_Max (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Impact Min/50%/Max", STUDY.ImpactLayer, s1, s2, s3);
    }
    return out;
  }
  boolean Export_ASCII_data (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Export ASCII data", STUDY.export_info_node);
    }
    return out;
  }
  boolean Export_ASCII_statistics (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Export ASCII statistics", STUDY.export_info_norm);
    }
    return out;
  }
  boolean Export_ASCII_probabilities (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Export ASCII probabilities", STUDY.export_info_prob);
    }
    return out;
  }
  float _3D_export_Scale (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-export.Scale", User3D.export_Scale, s1, s2, s3);
    }
    return out;
  }
  int _3D_export_FlipZYaxis (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-export.FlipZYaxis", User3D.export_FlipZYaxis, s1, s2, s3);
    }
    return out;
  }
  int _3D_export_PrecisionVertex (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-export.PrecisionVertex", User3D.export_PrecisionVertex, s1, s2, s3);
    }
    return out;
  }
  int _3D_export_PrecisionVtexture (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-export.PrecisionVtexture", User3D.export_PrecisionVtexture, s1, s2, s3);
    }
    return out;
  }
  int _3D_export_PolyToPoly (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-export.PolyToPoly", User3D.export_PolyToPoly, s1, s2, s3);
    }
    return out;
  }
  boolean _3D_export_MaterialLibrary (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-export.MaterialLibrary", User3D.export_MaterialLibrary);
    }
    return out;
  }
  boolean _3D_export_BackSides (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-export.BackSides", User3D.export_BackSides);
    }
    return out;
  }
  int _3D_export_PaletteResolution (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "3D-export.PaletteResolution", User3D.export_PaletteResolution, s1, s2, s3, s4);
    }
    return out;
  }
  int Record_SolidImpact_in_JPG (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Record SolidImpact in JPG", allSolidImpacts.record_IMG, s1, s2, s3);
    }
    return out;
  }
  int Record_SolidImpact_in_PDF (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Record SolidImpact in PDF", allSolidImpacts.record_PDF, s1, s2, s3);
    }
    return out;
  }
  int Record_Solar_Analysis_in_JPG (int created) {
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
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Record Solar Analysis in JPG", allSolarImpacts.record_IMG, s1, s2, s3);
    }
    return out;
  }
  int windRoses_resolution (int created) {
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
      out = int(UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "windRoses.resolution", allWindRoses.RES, s1, s2, s3));
    }
    return out;
  }
}
