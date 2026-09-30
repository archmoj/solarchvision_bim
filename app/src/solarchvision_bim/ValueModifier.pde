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
        () -> (float) STUDY.endDay,
        (v) -> { STUDY.endDay = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyStudyJEnd);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Number of days to plot", STUDY.endDay, s1, s2, s3);
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
        () -> STUDY.dayIncrement,
        (v) -> { STUDY.dayIncrement = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Day step", STUDY.dayIncrement, s1, s2, s3);
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
        () -> (float) STUDY.daysMergedCount,
        (v) -> { STUDY.daysMergedCount = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Join days", STUDY.daysMergedCount, s1, s2, s3);
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
        () -> (float) STUDY.startHour,
        (v) -> { STUDY.startHour = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Start hour", STUDY.startHour, s1, s2, s3);
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
        () -> (float) STUDY.endHour,
        (v) -> { STUDY.endHour = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "End hour", STUDY.endHour, s1, s2, s3);
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
        () -> (float) sampleYearStart,
        (v) -> { sampleYearStart = int(v); },
        () -> (float) (climateEngineeringStart), () -> (float) (climateArchiveEnd), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Start year", sampleYearStart, climateEngineeringStart, climateArchiveEnd, 1);
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
        () -> (float) sampleYearEnd,
        (v) -> { sampleYearEnd = int(v); },
        () -> (float) (climateEngineeringStart), () -> (float) (climateArchiveEnd), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "End year", sampleYearEnd, climateEngineeringStart, climateArchiveEnd, 1);
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
        () -> (float) sampleMemberStart,
        (v) -> { sampleMemberStart = int(v); },
        () -> (float) (ensembleForecastStart), () -> (float) (ensembleForecastEnd), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Start member", sampleMemberStart, ensembleForecastStart, ensembleForecastEnd, 1);
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
        () -> (float) sampleMemberEnd,
        (v) -> { sampleMemberEnd = int(v); },
        () -> (float) (ensembleForecastStart), () -> (float) (ensembleForecastEnd), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "End member", sampleMemberEnd, ensembleForecastStart, ensembleForecastEnd, 1);
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
        () -> (float) sampleStationStart,
        (v) -> { sampleStationStart = int(v); },
        () -> (float) (ensembleObservationStart), () -> (float) (ensembleObservationEnd), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Start station", sampleStationStart, ensembleObservationStart, ensembleObservationEnd, 1);
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
        () -> (float) sampleStationEnd,
        (v) -> { sampleStationEnd = int(v); },
        () -> (float) (ensembleObservationStart), () -> (float) (ensembleObservationEnd), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "End station", sampleStationEnd, ensembleObservationStart, ensembleObservationEnd, 1);
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
      putValueAction("Forecast/Obs maxDays",
        () -> (float) ensembleObservationMaxDays,
        (v) -> { ensembleObservationMaxDays = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Forecast/Obs maxDays", ensembleObservationMaxDays, s1, s2, s3);
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
        () -> (float) STUDY.skyScenarioSetting,
        (v) -> { STUDY.skyScenarioSetting = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky status", STUDY.skyScenarioSetting, s1, s2, s3);
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
        () -> (float) STUDY.temporalFilterSetting,
        (v) -> { STUDY.temporalFilterSetting = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Hourly/daily filter", STUDY.temporalFilterSetting, s1, s2, s3);
    }
    return out;
  }
  float Latitude (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    float s1 = -85; //start
    float s2 = 85; //stop
    float s3 = 0.0001; //step
    float s4 = 0.00001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Latitude",
        () -> LocationLAT,
        (v) -> { STATION.setLatitude(v); update_station(0); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Latitude", LocationLAT, s1, s2, s3, s4);
    }
    return out;
  }
  float Longitude (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    float s1 = -180; //start
    float s2 = 180; //stop
    float s3 = 0.0001; //step
    float s4 = 0.00001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Longitude",
        () -> LocationLON,
        (v) -> { STATION.setLongitude(v); update_station(0); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Longitude", LocationLON, s1, s2, s3, s4);
    }
    return out;
  }
  int climateTypicalYearDisplayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    int s1 = 0; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Climate Typical Year Display All",
        () -> (float) WORLD.climateTypicalYearDisplayAll,
        (v) -> { WORLD.climateTypicalYearDisplayAll = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Climate Typical Year Display All", WORLD.climateTypicalYearDisplayAll, s1, s2, s3);
    }
    return out;
  }
  boolean climateTypicalYearDisplayNear (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Climate Typical Year Display Near",
        () -> (WORLD.climateTypicalYearDisplayNear ? 1f : 0f),
        (v) -> { WORLD.climateTypicalYearDisplayNear = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Climate Typical Year Display Near", WORLD.climateTypicalYearDisplayNear);
    }
    return out;
  }
  int climateEngineeringDisplayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    int s1 = 0; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Climate Engineering Display All",
        () -> (float) WORLD.climateEngineeringDisplayAll,
        (v) -> { WORLD.climateEngineeringDisplayAll = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Climate Engineering Display All", WORLD.climateEngineeringDisplayAll, s1, s2, s3);
    }
    return out;
  }
  boolean climateEngineeringDisplayNear (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Climate Engineering Display Near",
        () -> (WORLD.climateEngineeringDisplayNear ? 1f : 0f),
        (v) -> { WORLD.climateEngineeringDisplayNear = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Climate Engineering Display Near", WORLD.climateEngineeringDisplayNear);
    }
    return out;
  }
  int climateArchiveDisplayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    int s1 = 0; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Climate Archive Display All",
        () -> (float) WORLD.climateArchiveDisplayAll,
        (v) -> { WORLD.climateArchiveDisplayAll = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Climate Archive Display All", WORLD.climateArchiveDisplayAll, s1, s2, s3);
    }
    return out;
  }
  boolean climateArchiveDisplayNear (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Climate Archive Display Near",
        () -> (WORLD.climateArchiveDisplayNear ? 1f : 0f),
        (v) -> { WORLD.climateArchiveDisplayNear = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Climate Archive Display Near", WORLD.climateArchiveDisplayNear);
    }
    return out;
  }
  int ensembleObservationDisplayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    int s1 = 0; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Ensemble Observation Display All",
        () -> (float) WORLD.ensembleObservationDisplayAll,
        (v) -> { WORLD.ensembleObservationDisplayAll = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Ensemble Observation Display All", WORLD.ensembleObservationDisplayAll, s1, s2, s3);
    }
    return out;
  }
  boolean ensembleObservationDisplayNear (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Ensemble Observation Display Near",
        () -> (WORLD.ensembleObservationDisplayNear ? 1f : 0f),
        (v) -> { WORLD.ensembleObservationDisplayNear = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Ensemble Observation Display Near", WORLD.ensembleObservationDisplayNear);
    }
    return out;
  }
  int ensembleForecastDisplayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    int s1 = 0; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Ensemble Forecast Display All",
        () -> (float) WORLD.ensembleForecastDisplayAll,
        (v) -> { WORLD.ensembleForecastDisplayAll = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Ensemble Forecast Display All", WORLD.ensembleForecastDisplayAll, s1, s2, s3);
    }
    return out;
  }
  boolean ensembleForecastDisplayNear (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Ensemble Forecast Display Near",
        () -> (WORLD.ensembleForecastDisplayNear ? 1f : 0f),
        (v) -> { WORLD.ensembleForecastDisplayNear = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Ensemble Forecast Display Near", WORLD.ensembleForecastDisplayNear);
    }
    return out;
  }
  boolean AddToLastGroup (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("AddToLastGroup",
        () -> (addToLastGroup ? 1f : 0f),
        (v) -> { addToLastGroup = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "AddToLastGroup", addToLastGroup);
    }
    return out;
  }
  int Create3D_material (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 8; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Create3D material",
        () -> (float) User3D.defaultMaterial,
        (v) -> { User3D.defaultMaterial = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D material", User3D.defaultMaterial, s1, s2, s3);
    }
    return out;
  }
  int Create3D_tessellation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 6; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Create3D tessellation",
        () -> (float) User3D.defaultTessellation,
        (v) -> { User3D.defaultTessellation = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D tessellation", User3D.defaultTessellation, s1, s2, s3);
    }
    return out;
  }
  int Create3D_layer (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 16; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Create3D layer",
        () -> (float) User3D.defaultLayer,
        (v) -> { User3D.defaultLayer = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D layer", User3D.defaultLayer, s1, s2, s3);
    }
    return out;
  }
  int Create3D_visibility (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Create3D visibility",
        () -> (float) User3D.defaultVisibility,
        (v) -> { User3D.defaultVisibility = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D visibility", User3D.defaultVisibility, s1, s2, s3);
    }
    return out;
  }
  int Create3D_weight (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -20; //start
    int s2 = 20; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Create3D weight",
        () -> (float) User3D.defaultWeight,
        (v) -> { User3D.defaultWeight = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D weight", User3D.defaultWeight, s1, s2, s3);
    }
    return out;
  }
  int Create3D_closed (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Create3D closed",
        () -> (float) User3D.defaultClosed,
        (v) -> { User3D.defaultClosed = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D closed", User3D.defaultClosed, s1, s2, s3);
    }
    return out;
  }
  float Create3D_orientation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 360; //stop
    float s3 = 1; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Create3D orientation",
        () -> User3D.creatorOrientation,
        (v) -> { User3D.creatorOrientation = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D orientation", User3D.creatorOrientation, s1, s2, s3, s4);
    }
    return out;
  }
  float Create3D_length (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -100.0; //start
    float s2 = 1000.0; //stop
    float s3 = 1.0; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Create3D length",
        () -> User3D.creatorLength,
        (v) -> { User3D.creatorLength = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D length", User3D.creatorLength, s1, s2, s3, s4);
    }
    return out;
  }
  float Create3D_width (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -100.0; //start
    float s2 = 1000.0; //stop
    float s3 = 1.0; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Create3D width",
        () -> User3D.creatorWidth,
        (v) -> { User3D.creatorWidth = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D width", User3D.creatorWidth, s1, s2, s3, s4);
    }
    return out;
  }
  float Create3D_height (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -100.0; //start
    float s2 = 1000.0; //stop
    float s3 = 1.0; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Create3D height",
        () -> User3D.creatorHeight,
        (v) -> { User3D.creatorHeight = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D height", User3D.creatorHeight, s1, s2, s3, s4);
    }
    return out;
  }
  float Create3D_volume (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 1000000000; //stop
    float s3 = 1; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Create3D volume",
        () -> User3D.creatorVolume,
        (v) -> { User3D.creatorVolume = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D volume", User3D.creatorVolume, s1, s2, s3, s4);
    }
    return out;
  }
  int Create3D_snap (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Create3D snap",
        () -> (float) User3D.creatorSnapModeIndex,
        (v) -> { User3D.creatorSnapModeIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D snap", User3D.creatorSnapModeIndex, s1, s2, s3);
    }
    return out;
  }
  int Create3D_sphereDegree (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 5; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Create3D sphereDegree",
        () -> (float) User3D.creatorSphereDegree,
        (v) -> { User3D.creatorSphereDegree = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D sphereDegree", User3D.creatorSphereDegree, s1, s2, s3);
    }
    return out;
  }
  int Create3D_cylinderDegree (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 3; //start
    int s2 = 36; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Create3D cylinderDegree",
        () -> (float) User3D.creatorCylinderDegree,
        (v) -> { User3D.creatorCylinderDegree = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D cylinderDegree", User3D.creatorCylinderDegree, s1, s2, s3);
    }
    return out;
  }
  int Create3D_polyDegree (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 3; //start
    int s2 = 36; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Create3D polyDegree",
        () -> (float) User3D.creatorPolygonDegree,
        (v) -> { User3D.creatorPolygonDegree = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D polyDegree", User3D.creatorPolygonDegree, s1, s2, s3);
    }
    return out;
  }
  int Create3D_parametricType (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 6; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Create3D parametricType",
        () -> (float) User3D.creatorParametricTypeIndex,
        (v) -> { User3D.creatorParametricTypeIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D parametricType", User3D.creatorParametricTypeIndex, s1, s2, s3);
    }
    return out;
  }
  int Create3D_personType (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Create3D personType",
        () -> (float) User3D.creatorPersonTypeIndex,
        (v) -> { User3D.creatorPersonTypeIndex = int(v); },
        () -> (float) (0), () -> (float) (allModel2Ds.peopleFileCount), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D personType", User3D.creatorPersonTypeIndex, 0, allModel2Ds.peopleFileCount, 1);
    }
    return out;
  }
  int Create3D_plantType (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Create3D plantType",
        () -> (float) User3D.creatorPlantTypeIndex,
        (v) -> { User3D.creatorPlantTypeIndex = int(v); },
        () -> (float) (0), () -> (float) (allModel2Ds.treesFileCount), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D plantType", User3D.creatorPlantTypeIndex, 0, allModel2Ds.treesFileCount, 1);
    }
    return out;
  }
  float Modify3D_openningDepth (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -10; //start
    float s2 = 10; //stop
    float s3 = 0.1; //step

    float out = 0;
    if (created == 0) {
      putValueAction("Modify3D openningDepth",
        () -> User3D.modifierOpeningDepth,
        (v) -> { User3D.modifierOpeningDepth = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Modify3D openningDepth", User3D.modifierOpeningDepth, s1, s2, s3);
    }
    return out;
  }
  float Modify3D_openningArea (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 1; //stop
    float s3 = 0.05; //step

    float out = 0;
    if (created == 0) {
      putValueAction("Modify3D openningArea",
        () -> User3D.modifierOpeningArea,
        (v) -> { User3D.modifierOpeningArea = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Modify3D openningArea", User3D.modifierOpeningArea, s1, s2, s3);
    }
    return out;
  }
  float Modify3D_openningDeviation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 1; //stop
    float s3 = 0.05; //step

    float out = 0;
    if (created == 0) {
      putValueAction("Modify3D openningDeviation",
        () -> User3D.modifierOpeningDeviation,
        (v) -> { User3D.modifierOpeningDeviation = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Modify3D openningDeviation", User3D.modifierOpeningDeviation, s1, s2, s3);
    }
    return out;
  }
  int Modify3D_tessellateRows (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 100; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Modify3D tessellateRows",
        () -> (float) User3D.modifierTessellateRows,
        (v) -> { User3D.modifierTessellateRows = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Modify3D tessellateRows", User3D.modifierTessellateRows, s1, s2, s3);
    }
    return out;
  }
  int Modify3D_tessellateColumns (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 100; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Modify3D tessellateColumns",
        () -> (float) User3D.modifierTessellateColumns,
        (v) -> { User3D.modifierTessellateColumns = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Modify3D tessellateColumns", User3D.modifierTessellateColumns, s1, s2, s3);
    }
    return out;
  }
  float Modify3D_offsetAmount (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 25; //stop
    float s3 = 0.001; //step

    float out = 0;
    if (created == 0) {
      putValueAction("Modify3D offsetAmount",
        () -> User3D.modifierOffsetAmount,
        (v) -> { User3D.modifierOffsetAmount = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Modify3D offsetAmount", User3D.modifierOffsetAmount, s1, s2, s3);
    }
    return out;
  }
  float Modify3D_weldThreshold (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 10; //stop
    float s3 = 0.001; //step

    float out = 0;
    if (created == 0) {
      putValueAction("Modify3D weldThreshold",
        () -> User3D.modifierWeldThreshold,
        (v) -> { User3D.modifierWeldThreshold = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Modify3D weldThreshold", User3D.modifierWeldThreshold, s1, s2, s3);
    }
    return out;
  }
  float Select3D_softSelectionFalloffPower (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8.0; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Select3D softSelectionFalloffPower",
        () -> Select3D.softSelectionFalloffPower,
        (v) -> { Select3D.softSelectionFalloffPower = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.softSelectionChanged);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D softSelectionFalloffPower", Select3D.softSelectionFalloffPower, s1, s2, s3, s4);
    }
    return out;
  }
  float Select3D_softSelectionFalloffRadius (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.01; //start
    float s2 = 100; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Select3D softSelectionFalloffRadius",
        () -> Select3D.softSelectionFalloffRadius,
        (v) -> { Select3D.softSelectionFalloffRadius = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.softSelectionChanged);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D softSelectionFalloffRadius", Select3D.softSelectionFalloffRadius, s1, s2, s3, s4);
    }
    return out;
  }
  int Select3D_positionVectorIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 3; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Select3D positionVectorIndex",
        () -> (float) Select3D.positionVectorIndex,
        (v) -> { Select3D.positionVectorIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D positionVectorIndex", Select3D.positionVectorIndex, s1, s2, s3);
    }
    return out;
  }
  int Select3D_rotationVectorIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Select3D rotationVectorIndex",
        () -> (float) Select3D.rotationVectorIndex,
        (v) -> { Select3D.rotationVectorIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D rotationVectorIndex", Select3D.rotationVectorIndex, s1, s2, s3);
    }
    return out;
  }
  int Select3D_scaleVectorIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 3; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Select3D scaleVectorIndex",
        () -> (float) Select3D.scaleVectorIndex,
        (v) -> { Select3D.scaleVectorIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D scaleVectorIndex", Select3D.scaleVectorIndex, s1, s2, s3);
    }
    return out;
  }
  float Select3D_position (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -50.0; //start
    float s2 = 50.0; //stop
    float s3 = 1.0; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Select3D position",
        () -> Select3D.position,
        (v) -> { Select3D.position = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.applyPosValue);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D position", Select3D.position, s1, s2, s3, s4);
    }
    return out;
  }
  float Select3D_rotation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -180.0; //start
    float s2 = 180.0; //stop
    float s3 = 1.0; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Select3D rotation",
        () -> Select3D.rotation,
        (v) -> { Select3D.rotation = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.applyRotValue);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D rotation", Select3D.rotation, s1, s2, s3, s4);
    }
    return out;
  }
  float Select3D_scale (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -8.0; //start
    float s2 = 8.0; //stop
    float s3 = 1.0; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Select3D scale",
        () -> Select3D.scale,
        (v) -> { Select3D.scale = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.applyScaleValue);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D scale", Select3D.scale, s1, s2, s3, s4);
    }
    return out;
  }
  int Select3D_pivotAlignmentX (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Select3D pivotAlignmentX",
        () -> (float) Select3D.pivotAlignmentX,
        (v) -> { Select3D.pivotAlignmentX = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.selectionChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D pivotAlignmentX", Select3D.pivotAlignmentX, s1, s2, s3);
    }
    return out;
  }
  int Select3D_pivotAlignmentY (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Select3D pivotAlignmentY",
        () -> (float) Select3D.pivotAlignmentY,
        (v) -> { Select3D.pivotAlignmentY = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.selectionChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D pivotAlignmentY", Select3D.pivotAlignmentY, s1, s2, s3);
    }
    return out;
  }
  int Select3D_pivotAlignmentZ (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Select3D pivotAlignmentZ",
        () -> (float) Select3D.pivotAlignmentZ,
        (v) -> { Select3D.pivotAlignmentZ = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.selectionChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D pivotAlignmentZ", Select3D.pivotAlignmentZ, s1, s2, s3);
    }
    return out;
  }
  float Create3D_powAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float out = 0;
    if (created == 0) {
      putValueAction("Create3D powAll",
        () -> User3D.creatorUniformSuperellipsoidPower,
        (v) -> { User3D.creatorUniformSuperellipsoidPower = v; },
        () -> (float) (0.5), () -> (float) (CubePower), 0.001,
        u1, u2, u3,
        react.applyCreatePowAll);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D powAll", User3D.creatorUniformSuperellipsoidPower, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }
  float Create3D_powX (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float out = 0;
    if (created == 0) {
      putValueAction("Create3D powX",
        () -> User3D.creatorSuperellipsoidPowerX,
        (v) -> { User3D.creatorSuperellipsoidPowerX = v; },
        () -> (float) (0.5), () -> (float) (CubePower), 0.001,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D powX", User3D.creatorSuperellipsoidPowerX, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }
  float Create3D_powY (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float out = 0;
    if (created == 0) {
      putValueAction("Create3D powY",
        () -> User3D.creatorSuperellipsoidPowerY,
        (v) -> { User3D.creatorSuperellipsoidPowerY = v; },
        () -> (float) (0.5), () -> (float) (CubePower), 0.001,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D powY", User3D.creatorSuperellipsoidPowerY, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }
  float Create3D_powZ (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float out = 0;
    if (created == 0) {
      putValueAction("Create3D powZ",
        () -> User3D.creatorSuperellipsoidPowerZ,
        (v) -> { User3D.creatorSuperellipsoidPowerZ = v; },
        () -> (float) (0.5), () -> (float) (CubePower), 0.001,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D powZ", User3D.creatorSuperellipsoidPowerZ, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }
  int Create3D_type (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 0; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Create3D type",
        () -> (float) User3D.creatorModel1DTypeIndex,
        (v) -> { User3D.creatorModel1DTypeIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D type", User3D.creatorModel1DTypeIndex, s1, s2, s3);
    }
    return out;
  }
  int Create3D_degreeMax (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 12; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Create3D degreeMax",
        () -> (float) User3D.creatorModel1DDegreeMax,
        (v) -> { User3D.creatorModel1DDegreeMax = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D degreeMax", User3D.creatorModel1DDegreeMax, s1, s2, s3);
    }
    return out;
  }
  int Create3D_seed (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 32767; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Create3D seed",
        () -> (float) User3D.creatorModel1DSeed,
        (v) -> { User3D.creatorModel1DSeed = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D seed", User3D.creatorModel1DSeed, s1, s2, s3);
    }
    return out;
  }
  float Create3D_trunkSize (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 10; //stop
    float s3 = 0.1; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.1; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Create3D trunkSize",
        () -> User3D.creatorModel1DTrunkSize,
        (v) -> { User3D.creatorModel1DTrunkSize = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D trunkSize", User3D.creatorModel1DTrunkSize, s1, s2, s3, s4);
    }
    return out;
  }
  float Create3D_leafSize (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 1; //stop
    float s3 = 0.01; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.1; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Create3D leafSize",
        () -> User3D.creatorModel1DLeafSize,
        (v) -> { User3D.creatorModel1DLeafSize = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D leafSize", User3D.creatorModel1DLeafSize, s1, s2, s3, s4);
    }
    return out;
  }
  float Create3D_branchTilt (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 360; //stop
    float s3 = 5; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.1; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Create3D branchTilt",
        () -> User3D.creator_Model1D_BranchTilt,
        (v) -> { User3D.creator_Model1D_BranchTilt = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D branchTilt", User3D.creator_Model1D_BranchTilt, s1, s2, s3, s4);
    }
    return out;
  }
  float Create3D_branchTwist (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 360; //stop
    float s3 = 5; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.1; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Create3D branchTwist",
        () -> User3D.creator_Model1D_BranchTwist,
        (v) -> { User3D.creator_Model1D_BranchTwist = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D branchTwist", User3D.creator_Model1D_BranchTwist, s1, s2, s3, s4);
    }
    return out;
  }
  float Create3D_branchRatio (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.05; //start
    float s2 = 1; //stop
    float s3 = 0.05; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.01; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Create3D branchRatio",
        () -> User3D.creator_Model1D_BranchRatio,
        (v) -> { User3D.creator_Model1D_BranchRatio = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D branchRatio", User3D.creator_Model1D_BranchRatio, s1, s2, s3, s4);
    }
    return out;
  }
  float Create3D_treeBase (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 4; //stop
    float s3 = 0.1; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.01; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Create3D treeBase",
        () -> User3D.creator_Model1D_TreeBase,
        (v) -> { User3D.creator_Model1D_TreeBase = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D treeBase", User3D.creator_Model1D_TreeBase, s1, s2, s3, s4);
    }
    return out;
  }
  boolean Terrain_loadTextures (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Terrain loadTextures",
        () -> (Terrain.loadTextures ? 1f : 0f),
        (v) -> { Terrain.loadTextures = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.applyLandLoadTextures);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Terrain loadTextures", Terrain.loadTextures);
    }
    return out;
  }
  boolean Terrain_loadMesh (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Terrain loadMesh",
        () -> (Terrain.loadMesh ? 1f : 0f),
        (v) -> { Terrain.loadMesh = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.applyLandLoadMesh);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Terrain loadMesh", Terrain.loadMesh);
    }
    return out;
  }
  int Terrain_skipStart (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Terrain skipStart",
        () -> (float) Terrain.skipStart,
        (v) -> { Terrain.skipStart = int(v); },
        () -> (float) (0), () -> (float) (Terrain.rowCount - 1), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Terrain skipStart", Terrain.skipStart, 0, Terrain.rowCount - 1, 1);
    }
    return out;
  }
  int Terrain_skipEnd (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Terrain skipEnd",
        () -> (float) Terrain.skipEnd,
        (v) -> { Terrain.skipEnd = int(v); },
        () -> (float) (0), () -> (float) (Terrain.rowCount - 1), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Terrain skipEnd", Terrain.skipEnd, 0, Terrain.rowCount - 1, 1);
    }
    return out;
  }
  boolean Terrain_displaySurface (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Terrain displaySurface",
        () -> (Terrain.displaySurface ? 1f : 0f),
        (v) -> { Terrain.displaySurface = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Terrain displaySurface", Terrain.displaySurface);
    }
    return out;
  }
  boolean Terrain_displayTexture (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Terrain displayTexture",
        () -> (Terrain.displayTexture ? 1f : 0f),
        (v) -> { Terrain.displayTexture = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Terrain displayTexture", Terrain.displayTexture);
    }
    return out;
  }
  boolean Terrain_displayPoints (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Terrain displayPoints",
        () -> (Terrain.displayPoints ? 1f : 0f),
        (v) -> { Terrain.displayPoints = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Terrain displayPoints", Terrain.displayPoints);
    }
    return out;
  }
  boolean Terrain_displayDepth (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Terrain displayDepth",
        () -> (Terrain.displayDepth ? 1f : 0f),
        (v) -> { Terrain.displayDepth = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Terrain displayDepth", Terrain.displayDepth);
    }
    return out;
  }
  boolean Model2Ds_displayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Model2Ds Display All",
        () -> (allModel2Ds.displayAll ? 1f : 0f),
        (v) -> { allModel2Ds.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Model2Ds Display All", allModel2Ds.displayAll);
    }
    return out;
  }
  boolean Model1Ds_displayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Model1Ds Display All",
        () -> (allModel1Ds.displayAll ? 1f : 0f),
        (v) -> { allModel1Ds.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Model1Ds Display All", allModel1Ds.displayAll);
    }
    return out;
  }
  boolean Model1Ds_displayLeaves (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Model1Ds displayLeaves",
        () -> (allModel1Ds.displayLeaves ? 1f : 0f),
        (v) -> { allModel1Ds.displayLeaves = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Model1Ds displayLeaves", allModel1Ds.displayLeaves);
    }
    return out;
  }
  boolean Polylines_displayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Polylines Display All",
        () -> (allPolylines.displayAll ? 1f : 0f),
        (v) -> { allPolylines.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Polylines Display All", allPolylines.displayAll);
    }
    return out;
  }
  boolean Faces_displayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Faces Display All",
        () -> (allFaces.displayAll ? 1f : 0f),
        (v) -> { allFaces.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Faces Display All", allFaces.displayAll);
    }
    return out;
  }
  boolean Solids_displayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Solids Display All",
        () -> (allSolids.displayAll ? 1f : 0f),
        (v) -> { allSolids.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Solids Display All", allSolids.displayAll);
    }
    return out;
  }
  boolean Sections_displayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Sections Display All",
        () -> (allSections.displayAll ? 1f : 0f),
        (v) -> { allSections.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sections Display All", allSections.displayAll);
    }
    return out;
  }
  boolean WindRoses_displayImage (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("WindRoses displayImage",
        () -> (allWindRoses.displayImage ? 1f : 0f),
        (v) -> { allWindRoses.displayImage = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "WindRoses displayImage", allWindRoses.displayImage);
    }
    return out;
  }
  float WindRoses_scale (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 50; //start
    float s2 = 3200; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("WindRoses scale",
        () -> allWindRoses.planeSize,
        (v) -> { allWindRoses.planeSize = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "WindRoses scale", allWindRoses.planeSize, s1, s2, s3, s4);
    }
    return out;
  }
  boolean Sky3D_displaySurface (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Sky3D displaySurface",
        () -> (Sky3D.displaySurface ? 1f : 0f),
        (v) -> { Sky3D.displaySurface = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D displaySurface", Sky3D.displaySurface);
    }
    return out;
  }
  boolean Sun3D_displayPath (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Sun3D displayPath",
        () -> (Sun3D.displayPath ? 1f : 0f),
        (v) -> { Sun3D.displayPath = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D displayPath", Sun3D.displayPath);
    }
    return out;
  }
  boolean Sun3D_displayPattern (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Sun3D displayPattern",
        () -> (Sun3D.displayPattern ? 1f : 0f),
        (v) -> { Sun3D.displayPattern = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D displayPattern", Sun3D.displayPattern);
    }
    return out;
  }
  int Camera_current (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Camera current",
        () -> (float) WIN3D.currentCameraIndex,
        (v) -> { WIN3D.currentCameraIndex = int(v); },
        () -> (float) (0), () -> (float) (allCameras.num), 1,
        u1, u2, u3,
        react.applyCurrentCamera);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Camera current", WIN3D.currentCameraIndex, 0, allCameras.num, 1);
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
      putValueAction("Camera clipNear",
        () -> WIN3D.cameraClipNear,
        (v) -> { WIN3D.cameraClipNear = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Camera clipNear", WIN3D.cameraClipNear, s1, s2, s3, s4);
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
      putValueAction("Camera clipFar",
        () -> WIN3D.cameraClipFar,
        (v) -> { WIN3D.cameraClipFar = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Camera clipFar", WIN3D.cameraClipFar, s1, s2, s3, s4);
    }
    return out;
  }
  boolean Create3D_displayVertices (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Create3D displayVertices",
        () -> (allPoints.displayAll ? 1f : 0f),
        (v) -> { allPoints.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D displayVertices", allPoints.displayAll);
    }
    return out;
  }
  boolean Create3D_displayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Create3D displayEdges",
        () -> (allFaces.displayEdges ? 1f : 0f),
        (v) -> { allFaces.displayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D displayEdges", allFaces.displayEdges);
    }
    return out;
  }
  boolean Create3D_showNormalLines (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Create3D showNormalLines",
        () -> (allFaces.showNormalLines ? 1f : 0f),
        (v) -> { allFaces.showNormalLines = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D showNormalLines", allFaces.showNormalLines);
    }
    return out;
  }
  boolean Cameras_displayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Cameras Display All",
        () -> (allCameras.displayAll ? 1f : 0f),
        (v) -> { allCameras.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Cameras Display All", allCameras.displayAll);
    }
    return out;
  }
  int impactDisplayDay (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Impacts displayDay",
        () -> (float) impactDisplayDay,
        (v) -> { impactDisplayDay = int(v); },
        () -> (float) (0), () -> (float) (STUDY.endDay - STUDY.startDay), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Impacts displayDay", impactDisplayDay, 0, STUDY.endDay - STUDY.startDay, 1);
    }
    return out;
  }
  boolean SolarImpacts_displayImage (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("SolarImpacts displayImage",
        () -> (allSolarImpacts.displayImage ? 1f : 0f),
        (v) -> { allSolarImpacts.displayImage = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "SolarImpacts displayImage", allSolarImpacts.displayImage);
    }
    return out;
  }
  boolean SolidImpacts_displayImage (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("SolidImpacts displayImage",
        () -> (allSolidImpacts.displayImage ? 1f : 0f),
        (v) -> { allSolidImpacts.displayImage = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "SolidImpacts displayImage", allSolidImpacts.displayImage);
    }
    return out;
  }
  int SolarImpacts_sectionType (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 3; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("SolarImpacts sectionType",
        () -> (float) allSolarImpacts.sectionType,
        (v) -> { allSolarImpacts.sectionType = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "SolarImpacts sectionType", allSolarImpacts.sectionType, s1, s2, s3);
    }
    return out;
  }
  int SolidImpacts_sectionType (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 3; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("SolidImpacts sectionType",
        () -> (float) allSolidImpacts.sectionType,
        (v) -> { allSolidImpacts.sectionType = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "SolidImpacts sectionType", allSolidImpacts.sectionType, s1, s2, s3);
    }
    return out;
  }
  float SolidImpacts_grade (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.0001; //start
    float s2 = 64.0; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("SolidImpacts grade",
        () -> allSolidImpacts.Grade,
        (v) -> { allSolidImpacts.Grade = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "SolidImpacts grade", allSolidImpacts.Grade, s1, s2, s3, s4);
    }
    return out;
  }
  float SolidImpacts_power (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.0001; //start
    float s2 = 64.0; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("SolidImpacts power",
        () -> allSolidImpacts.Power,
        (v) -> { allSolidImpacts.Power = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "SolidImpacts power", allSolidImpacts.Power, s1, s2, s3, s4);
    }
    return out;
  }
  float SolidImpacts_r (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -360; //start
    float s2 = 360; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("SolidImpacts r",
        () -> allSolidImpacts.R[allSolidImpacts.sectionType],
        (v) -> { allSolidImpacts.R[allSolidImpacts.sectionType] = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "SolidImpacts r[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.R[allSolidImpacts.sectionType], s1, s2, s3, s4);
    }
    return out;
  }
  float SolidImpacts_z (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -1000; //start
    float s2 = 1000; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("SolidImpacts z",
        () -> allSolidImpacts.Z[allSolidImpacts.sectionType],
        (v) -> { allSolidImpacts.Z[allSolidImpacts.sectionType] = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "SolidImpacts z[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.Z[allSolidImpacts.sectionType], s1, s2, s3, s4);
    }
    return out;
  }
  float SolidImpacts_positionStep (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 5; //start
    float s2 = 80; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("SolidImpacts positionStep",
        () -> allSolidImpacts.positionStep,
        (v) -> { allSolidImpacts.positionStep = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "SolidImpacts positionStep", allSolidImpacts.positionStep, s1, s2, s3, s4);
    }
    return out;
  }
  float SolidImpacts_u (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 3200; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("SolidImpacts u",
        () -> allSolidImpacts.U[allSolidImpacts.sectionType],
        (v) -> { allSolidImpacts.U[allSolidImpacts.sectionType] = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "SolidImpacts u[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.U[allSolidImpacts.sectionType], s1, s2, s3, s4);
    }
    return out;
  }
  float SolidImpacts_v (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 3200; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("SolidImpacts v",
        () -> allSolidImpacts.V[allSolidImpacts.sectionType],
        (v) -> { allSolidImpacts.V[allSolidImpacts.sectionType] = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "SolidImpacts v[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.V[allSolidImpacts.sectionType], s1, s2, s3, s4);
    }
    return out;
  }
  float SolidImpacts_x (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -10000; //start
    float s2 = 10000; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("SolidImpacts x",
        () -> allSolidImpacts.X[allSolidImpacts.sectionType],
        (v) -> { allSolidImpacts.X[allSolidImpacts.sectionType] = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "SolidImpacts x[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.X[allSolidImpacts.sectionType], s1, s2, s3, s4);
    }
    return out;
  }
  float SolidImpacts_y (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -10000; //start
    float s2 = 10000; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("SolidImpacts y",
        () -> allSolidImpacts.Y[allSolidImpacts.sectionType],
        (v) -> { allSolidImpacts.Y[allSolidImpacts.sectionType] = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "SolidImpacts y[" + nf(allSolidImpacts.sectionType, 0) + "]", allSolidImpacts.Y[allSolidImpacts.sectionType], s1, s2, s3, s4);
    }
    return out;
  }
  float SolidImpacts_windSpeedMps (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1; //start
    float s2 = 16; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("SolidImpacts windSpeedMps",
        () -> allSolidImpacts.WindSpeed,
        (v) -> { allSolidImpacts.WindSpeed = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "SolidImpacts windSpeedMps", allSolidImpacts.WindSpeed, s1, s2, s3, s4);
    }
    return out;
  }
  float SolidImpacts_windDirection (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 360; //stop
    float s3 = 15; //step

    float out = 0;
    if (created == 0) {
      putValueAction("SolidImpacts windDirection",
        () -> allSolidImpacts.WindDirection,
        (v) -> { allSolidImpacts.WindDirection = v; },
        s1, s2, s3,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "SolidImpacts windDirection", allSolidImpacts.WindDirection, s1, s2, s3);
    }
    return out;
  }
  int SolidImpacts_processSubDivisions (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 3; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("SolidImpacts processSubDivisions",
        () -> (float) allSolidImpacts.Process_subDivisions,
        (v) -> { allSolidImpacts.Process_subDivisions = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "SolidImpacts processSubDivisions", allSolidImpacts.Process_subDivisions, s1, s2, s3);
    }
    return out;
  }
  boolean SolidImpacts_displayPoints (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("SolidImpacts displayPoints",
        () -> (allSolidImpacts.displayPoints ? 1f : 0f),
        (v) -> { allSolidImpacts.displayPoints = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "SolidImpacts displayPoints", allSolidImpacts.displayPoints);
    }
    return out;
  }
  boolean SolidImpacts_displayLines (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("SolidImpacts displayLines",
        () -> (allSolidImpacts.displayLines ? 1f : 0f),
        (v) -> { allSolidImpacts.displayLines = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "SolidImpacts displayLines", allSolidImpacts.displayLines);
    }
    return out;
  }
  boolean WindFlows_displayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("WindFlows Display All",
        () -> (allWindFlows.displayAll ? 1f : 0f),
        (v) -> { allWindFlows.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "WindFlows Display All", allWindFlows.displayAll);
    }
    return out;
  }
  int Create3D_displayTessellation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 4; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Create3D displayTessellation",
        () -> (float) allFaces.displayTessellation,
        (v) -> { allFaces.displayTessellation = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D displayTessellation", allFaces.displayTessellation, s1, s2, s3);
    }
    return out;
  }
  int Terrain_displayTessellation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 4; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Terrain displayTessellation",
        () -> (float) Terrain.displayTessellation,
        (v) -> { Terrain.displayTessellation = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Terrain displayTessellation", Terrain.displayTessellation, s1, s2, s3);
    }
    return out;
  }
  int Sky3D_displayTessellation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 4; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Sky3D displayTessellation",
        () -> (float) Sky3D.displayTessellation,
        (v) -> { Sky3D.displayTessellation = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D displayTessellation", Sky3D.displayTessellation, s1, s2, s3);
    }
    return out;
  }
  float Sky3D_scale (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1; //start
    float s2 = 4000000; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Sky3D scale",
        () -> Sky3D.radius,
        (v) -> { Sky3D.radius = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D scale", Sky3D.radius, s1, s2, s3, s4);
    }
    return out;
  }
  boolean Tropo3D_displaySurface (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Tropo3D displaySurface",
        () -> (Tropo3D.displaySurface ? 1f : 0f),
        (v) -> { Tropo3D.displaySurface = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Tropo3D displaySurface", Tropo3D.displaySurface);
    }
    return out;
  }
  boolean Tropo3D_displayTexture (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Tropo3D displayTexture",
        () -> (Tropo3D.displayTexture ? 1f : 0f),
        (v) -> { Tropo3D.displayTexture = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Tropo3D displayTexture", Tropo3D.displayTexture);
    }
    return out;
  }
  boolean Earth3D_displaySurface (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Earth3D displaySurface",
        () -> (Earth3D.displaySurface ? 1f : 0f),
        (v) -> { Earth3D.displaySurface = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Earth3D displaySurface", Earth3D.displaySurface);
    }
    return out;
  }
  boolean Earth3D_displayTexture (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Earth3D displayTexture",
        () -> (Earth3D.displayTexture ? 1f : 0f),
        (v) -> { Earth3D.displayTexture = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Earth3D displayTexture", Earth3D.displayTexture);
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
      putValueAction("Earth3D levelOfDetail",
        () -> Earth3D.levelOfDetail,
        (v) -> { Earth3D.levelOfDetail = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Earth3D levelOfDetail", Earth3D.levelOfDetail, s1, s2, s3, s4);
    }
    return out;
  }
  boolean Moon3D_displaySurface (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Moon3D displaySurface",
        () -> (Moon3D.displaySurface ? 1f : 0f),
        (v) -> { Moon3D.displaySurface = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Moon3D displaySurface", Moon3D.displaySurface);
    }
    return out;
  }
  boolean Moon3D_displayTexture (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Moon3D displayTexture",
        () -> (Moon3D.displayTexture ? 1f : 0f),
        (v) -> { Moon3D.displayTexture = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Moon3D displayTexture", Moon3D.displayTexture);
    }
    return out;
  }
  boolean Moon3D_fitInSkyDome (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Moon3D fitInSkyDome",
        () -> (Moon3D.fitInSkyDome ? 1f : 0f),
        (v) -> { Moon3D.fitInSkyDome = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Moon3D fitInSkyDome", Moon3D.fitInSkyDome);
    }
    return out;
  }
  boolean Sun3D_displaySurface (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Sun3D displaySurface",
        () -> (Sun3D.displaySurface ? 1f : 0f),
        (v) -> { Sun3D.displaySurface = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D displaySurface", Sun3D.displaySurface);
    }
    return out;
  }
  boolean Sun3D_displayTexture (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Sun3D displayTexture",
        () -> (Sun3D.displayTexture ? 1f : 0f),
        (v) -> { Sun3D.displayTexture = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D displayTexture", Sun3D.displayTexture);
    }
    return out;
  }
  boolean Sun3D_fitInSkyDome (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Sun3D fitInSkyDome",
        () -> (Sun3D.fitInSkyDome ? 1f : 0f),
        (v) -> { Sun3D.fitInSkyDome = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D fitInSkyDome", Sun3D.fitInSkyDome);
    }
    return out;
  }
  float celestialMagnification (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1; //start
    float s2 = 64; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)

    float out = 0;
    if (created == 0) {
      putValueAction("Celestial magnification",
        () -> celestialMagnification,
        (v) -> { celestialMagnification = v; },
        s1, s2, Math.abs(s3),
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Celestial magnification", celestialMagnification, s1, s2, s3);
    }
    return out;
  }
  float overallScale (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.0000001; //start
    float s2 = 1000000; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.000001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Objects scale",
        () -> overallScale,
        (v) -> { overallScale = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Objects scale", overallScale, s1, s2, s3, s4);
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
        () -> (float) STUDY.plotLayoutIndex,
        (v) -> { STUDY.plotLayoutIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.impactsUpdateFlag);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Diagram setup", STUDY.plotLayoutIndex, s1, s2, s3);
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
        () -> STUDY.verticalUnitScale,
        (v) -> { STUDY.verticalUnitScale = v; },
        s1, s2, Math.abs(s3),
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Scale (" + allLayers[currentLayerId].descriptions[Language_EN] + ")", STUDY.verticalUnitScale, s1, s2, s3);
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
        () -> (STUDY.showRawLines ? 1f : 0f),
        (v) -> { STUDY.showRawLines = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Draw data", STUDY.showRawLines);
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
        () -> (STUDY.showStatisticalRanges ? 1f : 0f),
        (v) -> { STUDY.showStatisticalRanges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Draw sorted", STUDY.showStatisticalRanges);
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
        () -> (STUDY.showNormalLines ? 1f : 0f),
        (v) -> { STUDY.showNormalLines = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Draw statistics", STUDY.showNormalLines);
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
        () -> (STUDY.showProbabilities ? 1f : 0f),
        (v) -> { STUDY.showProbabilities = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Draw probabilities", STUDY.showProbabilities);
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
        () -> (float) STUDY.probabilityWidthInterval,
        (v) -> { STUDY.probabilityWidthInterval = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Probabilities interval", STUDY.probabilityWidthInterval, s1, s2, s3);
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
        () -> STUDY.probabilityHeightInterval,
        (v) -> { STUDY.probabilityHeightInterval = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Probabilities range", STUDY.probabilityHeightInterval, s1, s2, s3, s4);
    }
    return out;
  }
  int Study_activePaletteClr (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Study activePaletteClr",
        () -> (float) STUDY.activeColorScaleIndex,
        (v) -> { STUDY.activeColorScaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Study activePaletteClr", STUDY.activeColorScaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Study_activePaletteDir (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Study activePaletteDir",
        () -> (float) STUDY.activeColorScaleDirection,
        (v) -> { STUDY.activeColorScaleDirection = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Study activePaletteDir", STUDY.activeColorScaleDirection, s1, s2, s3);
    }
    return out;
  }
  float Study_activePaletteMlt (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Study activePaletteMlt",
        () -> STUDY.activeColorScaleFactor,
        (v) -> { STUDY.activeColorScaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Study activePaletteMlt", STUDY.activeColorScaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int Study_passivePaletteClr (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Study passivePaletteClr",
        () -> (float) STUDY.passiveColorScaleIndex,
        (v) -> { STUDY.passiveColorScaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Study passivePaletteClr", STUDY.passiveColorScaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Study_passivePaletteDir (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("Study passivePaletteDir",
        () -> (float) STUDY.passiveColorScaleDirection,
        (v) -> { STUDY.passiveColorScaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Study passivePaletteDir", STUDY.passiveColorScaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float Study_passivePaletteMlt (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Study passivePaletteMlt",
        () -> STUDY.passiveColorScaleFactor,
        (v) -> { STUDY.passiveColorScaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Study passivePaletteMlt", STUDY.passiveColorScaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int Study_sortPaletteClr (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Study sortPaletteClr",
        () -> (float) STUDY.statisticalRangesColorScaleIndex,
        (v) -> { STUDY.statisticalRangesColorScaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Study sortPaletteClr", STUDY.statisticalRangesColorScaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Study_sortPaletteDir (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("Study sortPaletteDir",
        () -> (float) STUDY.statisticalRangesColorScaleDirection,
        (v) -> { STUDY.statisticalRangesColorScaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Study sortPaletteDir", STUDY.statisticalRangesColorScaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float Study_sortPaletteMlt (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Study sortPaletteMlt",
        () -> STUDY.statisticalRangesColorScaleFactor,
        (v) -> { STUDY.statisticalRangesColorScaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Study sortPaletteMlt", STUDY.statisticalRangesColorScaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int Study_probPaletteClr (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Study probPaletteClr",
        () -> (float) STUDY.probabilitiesColorScaleIndex,
        (v) -> { STUDY.probabilitiesColorScaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Study probPaletteClr", STUDY.probabilitiesColorScaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Study_probPaletteDir (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("Study probPaletteDir",
        () -> (float) STUDY.probabilitiesColorScaleDirection,
        (v) -> { STUDY.probabilitiesColorScaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Study probPaletteDir", STUDY.probabilitiesColorScaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float Study_probPaletteMlt (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Study probPaletteMlt",
        () -> STUDY.probabilitiesColorScaleFactor,
        (v) -> { STUDY.probabilitiesColorScaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Study probPaletteMlt", STUDY.probabilitiesColorScaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  float WindRose_opacityScale (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1; //start
    float s2 = 100; //stop
    float s3 = -pow(2.0, (1.0 / 4.0)); //step (negative = geometric multiply/divide on +/- click)

    float out = 0;
    if (created == 0) {
      putValueAction("WindRose opacityScale",
        () -> STUDY.opacityPercentage,
        (v) -> { STUDY.opacityPercentage = v; },
        s1, s2, Math.abs(s3),
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "WindRose opacityScale", STUDY.opacityPercentage, s1, s2, s3);
    }
    return out;
  }
  int Faces_activePaletteClr (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Faces activePaletteClr",
        () -> (float) allFaces.activeColorScaleIndex,
        (v) -> { allFaces.activeColorScaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Faces activePaletteClr", allFaces.activeColorScaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Faces_activePaletteDir (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Faces activePaletteDir",
        () -> (float) allFaces.activeColorScaleDirection,
        (v) -> { allFaces.activeColorScaleDirection = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Faces activePaletteDir", allFaces.activeColorScaleDirection, s1, s2, s3);
    }
    return out;
  }
  float Faces_activePaletteMlt (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Faces activePaletteMlt",
        () -> allFaces.activeColorScaleFactor,
        (v) -> { allFaces.activeColorScaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Faces activePaletteMlt", allFaces.activeColorScaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int Faces_passivePaletteClr (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Faces passivePaletteClr",
        () -> (float) allFaces.passiveColorScaleIndex,
        (v) -> { allFaces.passiveColorScaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Faces passivePaletteClr", allFaces.passiveColorScaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Faces_passivePaletteDir (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("Faces passivePaletteDir",
        () -> (float) allFaces.passiveColorScaleDirection,
        (v) -> { allFaces.passiveColorScaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Faces passivePaletteDir", allFaces.passiveColorScaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float Faces_passivePaletteMlt (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Faces passivePaletteMlt",
        () -> allFaces.passiveColorScaleFactor,
        (v) -> { allFaces.passiveColorScaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Faces passivePaletteMlt", allFaces.passiveColorScaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int Sky3D_activePaletteClr (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Sky3D activePaletteClr",
        () -> (float) Sky3D.activeColorScaleIndex,
        (v) -> { Sky3D.activeColorScaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D activePaletteClr", Sky3D.activeColorScaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Sky3D_activePaletteDir (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Sky3D activePaletteDir",
        () -> (float) Sky3D.activeColorScaleDirection,
        (v) -> { Sky3D.activeColorScaleDirection = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D activePaletteDir", Sky3D.activeColorScaleDirection, s1, s2, s3);
    }
    return out;
  }
  float Sky3D_activePaletteMlt (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Sky3D activePaletteMlt",
        () -> Sky3D.activeColorScaleFactor,
        (v) -> { Sky3D.activeColorScaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D activePaletteMlt", Sky3D.activeColorScaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int Sky3D_passivePaletteClr (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Sky3D passivePaletteClr",
        () -> (float) Sky3D.passiveColorScaleIndex,
        (v) -> { Sky3D.passiveColorScaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D passivePaletteClr", Sky3D.passiveColorScaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Sky3D_passivePaletteDir (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("Sky3D passivePaletteDir",
        () -> (float) Sky3D.passiveColorScaleDirection,
        (v) -> { Sky3D.passiveColorScaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D passivePaletteDir", Sky3D.passiveColorScaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float Sky3D_passivePaletteMlt (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Sky3D passivePaletteMlt",
        () -> Sky3D.passiveColorScaleFactor,
        (v) -> { Sky3D.passiveColorScaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D passivePaletteMlt", Sky3D.passiveColorScaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int Sun3D_activePaletteClr (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Sun3D activePaletteClr",
        () -> (float) Sun3D.activeColorScaleIndex,
        (v) -> { Sun3D.activeColorScaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D activePaletteClr", Sun3D.activeColorScaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Sun3D_activePaletteDir (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Sun3D activePaletteDir",
        () -> (float) Sun3D.activeColorScaleDirection,
        (v) -> { Sun3D.activeColorScaleDirection = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D activePaletteDir", Sun3D.activeColorScaleDirection, s1, s2, s3);
    }
    return out;
  }
  float Sun3D_activePaletteMlt (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Sun3D activePaletteMlt",
        () -> Sun3D.activeColorScaleFactor,
        (v) -> { Sun3D.activeColorScaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D activePaletteMlt", Sun3D.activeColorScaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int Sun3D_passivePaletteClr (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Sun3D passivePaletteClr",
        () -> (float) Sun3D.passiveColorScaleIndex,
        (v) -> { Sun3D.passiveColorScaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D passivePaletteClr", Sun3D.passiveColorScaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Sun3D_passivePaletteDir (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("Sun3D passivePaletteDir",
        () -> (float) Sun3D.passiveColorScaleDirection,
        (v) -> { Sun3D.passiveColorScaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D passivePaletteDir", Sun3D.passiveColorScaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float Sun3D_passivePaletteMlt (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Sun3D passivePaletteMlt",
        () -> Sun3D.passiveColorScaleFactor,
        (v) -> { Sun3D.passiveColorScaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D passivePaletteMlt", Sun3D.passiveColorScaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int Solids_paletteClr (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Solids paletteClr",
        () -> (float) allSolids.colorScaleIndex,
        (v) -> { allSolids.colorScaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Solids paletteClr", allSolids.colorScaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Solids_paletteDir (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("Solids paletteDir",
        () -> (float) allSolids.colorScaleDirection,
        (v) -> { allSolids.colorScaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Solids paletteDir", allSolids.colorScaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float Solids_paletteMlt (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.0001; //start
    float s2 = 64; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Solids paletteMlt",
        () -> allSolids.colorScaleFactor,
        (v) -> { allSolids.colorScaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Solids paletteMlt", allSolids.colorScaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int Terrain_paletteClr (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Terrain paletteClr",
        () -> (float) Terrain.colorScaleIndex,
        (v) -> { Terrain.colorScaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Terrain paletteClr", Terrain.colorScaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Terrain_paletteDir (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("Terrain paletteDir",
        () -> (float) Terrain.colorScaleDirection,
        (v) -> { Terrain.colorScaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Terrain paletteDir", Terrain.colorScaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float Terrain_paletteMlt (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.001; //start
    float s2 = 0.5; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Terrain paletteMlt",
        () -> Terrain.colorScaleFactor,
        (v) -> { Terrain.colorScaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Terrain paletteMlt", Terrain.colorScaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int WindFlows_paletteClr (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("WindFlows paletteClr",
        () -> (float) allWindFlows.colorScaleIndex,
        (v) -> { allWindFlows.colorScaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "WindFlows paletteClr", allWindFlows.colorScaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int WindFlows_paletteDir (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("WindFlows paletteDir",
        () -> (float) allWindFlows.colorScaleDirection,
        (v) -> { allWindFlows.colorScaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "WindFlows paletteDir", allWindFlows.colorScaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float WindFlows_paletteMlt (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.01; //start
    float s2 = 1.0; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("WindFlows paletteMlt",
        () -> allWindFlows.colorScaleFactor,
        (v) -> { allWindFlows.colorScaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "WindFlows paletteMlt", allWindFlows.colorScaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  boolean Select3D_groupDisplayPivot (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Select3D groupDisplayPivot",
        () -> (Select3D.groupDisplayPivot ? 1f : 0f),
        (v) -> { Select3D.groupDisplayPivot = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D groupDisplayPivot", Select3D.groupDisplayPivot);
    }
    return out;
  }
  boolean Select3D_pivotDisplayReference (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Select3D pivotDisplayReference",
        () -> (Select3D.pivotDisplayReference ? 1f : 0f),
        (v) -> { Select3D.pivotDisplayReference = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D pivotDisplayReference", Select3D.pivotDisplayReference);
    }
    return out;
  }
  boolean Select3D_groupDisplayBox (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Select3D groupDisplayBox",
        () -> (Select3D.groupDisplayBox ? 1f : 0f),
        (v) -> { Select3D.groupDisplayBox = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D groupDisplayBox", Select3D.groupDisplayBox);
    }
    return out;
  }
  boolean Select3D_groupDisplayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Select3D groupDisplayEdges",
        () -> (Select3D.groupDisplayEdges ? 1f : 0f),
        (v) -> { Select3D.groupDisplayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D groupDisplayEdges", Select3D.groupDisplayEdges);
    }
    return out;
  }
  boolean Select3D_faceDisplayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Select3D faceDisplayEdges",
        () -> (Select3D.faceDisplayEdges ? 1f : 0f),
        (v) -> { Select3D.faceDisplayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D faceDisplayEdges", Select3D.faceDisplayEdges);
    }
    return out;
  }
  boolean Select3D_faceDisplayVertexCount (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Select3D faceDisplayVertexCount",
        () -> (Select3D.faceDisplayvertexSelection ? 1f : 0f),
        (v) -> { Select3D.faceDisplayvertexSelection = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D faceDisplayVertexCount", Select3D.faceDisplayvertexSelection);
    }
    return out;
  }
  boolean Select3D_polylineDisplayVertexCount (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Select3D polylineDisplayVertexCount",
        () -> (Select3D.polylineDisplayvertexSelection ? 1f : 0f),
        (v) -> { Select3D.polylineDisplayvertexSelection = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D polylineDisplayVertexCount", Select3D.polylineDisplayvertexSelection);
    }
    return out;
  }
  boolean Select3D_vertexDisplayVertices (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Select3D vertexDisplayVertices",
        () -> (Select3D.vertexDisplayMarkers ? 1f : 0f),
        (v) -> { Select3D.vertexDisplayMarkers = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D vertexDisplayVertices", Select3D.vertexDisplayMarkers);
    }
    return out;
  }
  boolean Select3D_polylineDisplayVertices (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Select3D polylineDisplayVertices",
        () -> (Select3D.polylineDisplayVertices ? 1f : 0f),
        (v) -> { Select3D.polylineDisplayVertices = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D polylineDisplayVertices", Select3D.polylineDisplayVertices);
    }
    return out;
  }
  boolean Select3D_model2DDisplayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Select3D model2DDisplayEdges",
        () -> (Select3D.model2DDisplayBounds ? 1f : 0f),
        (v) -> { Select3D.model2DDisplayBounds = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D model2DDisplayEdges", Select3D.model2DDisplayBounds);
    }
    return out;
  }
  boolean Select3D_model1DDisplayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Select3D model1DDisplayEdges",
        () -> (Select3D.model1DDisplayBounds ? 1f : 0f),
        (v) -> { Select3D.model1DDisplayBounds = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D model1DDisplayEdges", Select3D.model1DDisplayBounds);
    }
    return out;
  }
  boolean Select3D_solidDisplayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Select3D solidDisplayEdges",
        () -> (Select3D.solidDisplayEdges ? 1f : 0f),
        (v) -> { Select3D.solidDisplayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D solidDisplayEdges", Select3D.solidDisplayEdges);
    }
    return out;
  }
  boolean Select3D_sectionDisplayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Select3D sectionDisplayEdges",
        () -> (Select3D.sectionDisplayEdges ? 1f : 0f),
        (v) -> { Select3D.sectionDisplayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D sectionDisplayEdges", Select3D.sectionDisplayEdges);
    }
    return out;
  }
  boolean Select3D_cameraDisplayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Select3D cameraDisplayEdges",
        () -> (Select3D.cameraDisplayFrustum ? 1f : 0f),
        (v) -> { Select3D.cameraDisplayFrustum = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D cameraDisplayEdges", Select3D.cameraDisplayFrustum);
    }
    return out;
  }
  boolean Select3D_landPointDisplayPoints (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Select3D landPointDisplayPoints",
        () -> (Select3D.terrainDisplayVertices ? 1f : 0f),
        (v) -> { Select3D.terrainDisplayVertices = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Select3D landPointDisplayPoints", Select3D.terrainDisplayVertices);
    }
    return out;
  }
  float interpolationWeight (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 5; //stop
    float s3 = 0.5; //step

    float out = 0;
    if (created == 0) {
      putValueAction("Interpolation weight",
        () -> interpolationWeight,
        (v) -> { interpolationWeight = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Interpolation weight", interpolationWeight, s1, s2, s3);
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
      putValueAction("Climate based solar forecast",
        () -> (float) climateBasedSolarForecast,
        (v) -> { climateBasedSolarForecast = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeChange);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Climate based solar forecast", climateBasedSolarForecast, s1, s2, s3);
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
      putValueAction("Climate based temperature forecast",
        () -> (float) climateBasedWeatherForecast,
        (v) -> { climateBasedWeatherForecast = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeChange);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Climate based temperature forecast", climateBasedWeatherForecast, s1, s2, s3);
    }
    return out;
  }
  int developLayerOption (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 11; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Develop option",
        () -> (float) developLayerOption,
        (v) -> { developLayerOption = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Develop option", developLayerOption, s1, s2, s3);
    }
    return out;
  }
  int developLayerInterval (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 3; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Develop interval",
        () -> (float) developLayerInterval,
        (v) -> { developLayerInterval = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Develop interval", developLayerInterval, s1, s2, s3);
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
        () -> developLayerAngleInclination,
        (v) -> { developLayerAngleInclination = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Inclination angle", developLayerAngleInclination, s1, s2, s3, s4);
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
        () -> developLayerAngleOrientation,
        (v) -> { developLayerAngleOrientation = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Orientation angle", developLayerAngleOrientation, s1, s2, s3, s4);
    }
    return out;
  }
  int Impact_source (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Impact source",
        () -> (float) currentDataSource,
        (v) -> { currentDataSource = int(v); },
        () -> (float) (0), () -> (float) (MAXIMUM_dataID), 1,
        u1, u2, u3,
        react.impactsUpdateFlag);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Impact source", currentDataSource, 0, MAXIMUM_dataID, 1);
    }
    return out;
  }
  int Impact_min_50_max (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 8; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Impact min 50 max",
        () -> (float) STUDY.impactLayerIndex,
        (v) -> { STUDY.impactLayerIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Impact min 50 max", STUDY.impactLayerIndex, s1, s2, s3);
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
        () -> (STUDY.rawLinesExporter ? 1f : 0f),
        (v) -> { STUDY.rawLinesExporter = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Export ASCII data", STUDY.rawLinesExporter);
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
        () -> (STUDY.normalLinesExporter ? 1f : 0f),
        (v) -> { STUDY.normalLinesExporter = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Export ASCII statistics", STUDY.normalLinesExporter);
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
        () -> (STUDY.probabilitiesExporter ? 1f : 0f),
        (v) -> { STUDY.probabilitiesExporter = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Export ASCII probabilities", STUDY.probabilitiesExporter);
    }
    return out;
  }
  float Export3D_scale (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = .001; //start
    float s2 = 1000; //stop
    float s3 = -0.1; //step (negative = geometric multiply/divide on +/- click)

    float out = 0;
    if (created == 0) {
      putValueAction("Export3D scale",
        () -> User3D.exporterScale,
        (v) -> { User3D.exporterScale = v; },
        s1, s2, Math.abs(s3),
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Export3D scale", User3D.exporterScale, s1, s2, s3);
    }
    return out;
  }
  int Export3D_flipZYaxis (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Export3D flipZYaxis",
        () -> (float) User3D.exporterYaxisUp,
        (v) -> { User3D.exporterYaxisUp = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Export3D flipZYaxis", User3D.exporterYaxisUp, s1, s2, s3);
    }
    return out;
  }
  int Export3D_precisionVertex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 6; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Export3D precisionVertex",
        () -> (float) User3D.exporterPrecisionVertex,
        (v) -> { User3D.exporterPrecisionVertex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Export3D precisionVertex", User3D.exporterPrecisionVertex, s1, s2, s3);
    }
    return out;
  }
  int Export3D_precisionVtexture (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 6; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Export3D precisionVtexture",
        () -> (float) User3D.exporterPrecisionVertexTexture,
        (v) -> { User3D.exporterPrecisionVertexTexture = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Export3D precisionVtexture", User3D.exporterPrecisionVertexTexture, s1, s2, s3);
    }
    return out;
  }
  int Export3D_polyToPoly (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Export3D polyToPoly",
        () -> (float) User3D.exporterMaintainPolygons,
        (v) -> { User3D.exporterMaintainPolygons = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Export3D polyToPoly", User3D.exporterMaintainPolygons, s1, s2, s3);
    }
    return out;
  }
  boolean Export3D_materialLibrary (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Export3D materialLibrary",
        () -> (User3D.exporterMaterialLibrary ? 1f : 0f),
        (v) -> { User3D.exporterMaterialLibrary = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Export3D materialLibrary", User3D.exporterMaterialLibrary);
    }
    return out;
  }
  boolean Export3D_backSides (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Export3D backSides",
        () -> (User3D.exporterDoubleSided ? 1f : 0f),
        (v) -> { User3D.exporterDoubleSided = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Export3D backSides", User3D.exporterDoubleSided);
    }
    return out;
  }
  int Export3D_paletteResolution (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 32; //start
    int s2 = 2048; //stop
    int s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("Export3D paletteResolution",
        () -> (float) User3D.exporterColorScaleResolution,
        (v) -> { User3D.exporterColorScaleResolution = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Export3D paletteResolution", User3D.exporterColorScaleResolution, s1, s2, s3, s4);
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
  int WindRoses_resolution (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 200; //start
    int s2 = 600; //stop
    int s3 = 100; //step

    int out = 0;
    if (created == 0) {
      putValueAction("WindRoses resolution",
        () -> (float) allWindRoses.imageResolution,
        (v) -> { allWindRoses.imageResolution = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = int(UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "WindRoses resolution", allWindRoses.imageResolution, s1, s2, s3));
    }
    return out;
  }
}
