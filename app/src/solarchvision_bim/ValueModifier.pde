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

  int endDay (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 365; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("End Day",
        () -> (float) STUDY.endDay,
        (v) -> { STUDY.endDay = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyStudyJEnd);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "End Day", STUDY.endDay, s1, s2, s3);
    }
    return out;
  }
  float dayIncrement (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1.0; //start
    float s2 = 182.5; //stop
    float s3 = 0.5; //step

    float out = 0;
    if (created == 0) {
      putValueAction("Day Increment",
        () -> STUDY.dayIncrement,
        (v) -> { STUDY.dayIncrement = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Day Increment", STUDY.dayIncrement, s1, s2, s3);
    }
    return out;
  }
  int daysMergedCount (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 182; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Days Merged Count",
        () -> (float) STUDY.daysMergedCount,
        (v) -> { STUDY.daysMergedCount = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Days Merged Count", STUDY.daysMergedCount, s1, s2, s3);
    }
    return out;
  }
  float date (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 364; //stop
    float s3 = 1; //step

    float out = 0;
    if (created == 0) {
      putValueAction("Date",
        () -> TIME.date,
        (v) -> { TIME.date = v; },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeDate);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Date", TIME.date, s1, s2, s3);
    }
    return out;
  }
  int day (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 31; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Day",
        () -> (float) TIME.day,
        (v) -> { TIME.day = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeChange);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Day", TIME.day, s1, s2, s3);
    }
    return out;
  }
  int month (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 12; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Month",
        () -> (float) TIME.month,
        (v) -> { TIME.month = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeChange);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Month", TIME.month, s1, s2, s3);
    }
    return out;
  }
  int year (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1953; //start
    int s2 = 2100; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Year",
        () -> (float) TIME.year,
        (v) -> { TIME.year = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeChange);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Year", TIME.year, s1, s2, s3);
    }
    return out;
  }
  int startHour (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 23; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Start Hour",
        () -> (float) STUDY.startHour,
        (v) -> { STUDY.startHour = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Start Hour", STUDY.startHour, s1, s2, s3);
    }
    return out;
  }
  int endHour (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 23; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("End Hour",
        () -> (float) STUDY.endHour,
        (v) -> { STUDY.endHour = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "End Hour", STUDY.endHour, s1, s2, s3);
    }
    return out;
  }
  int sampleYearStart (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Sample Year Start",
        () -> (float) sampleYearStart,
        (v) -> { sampleYearStart = int(v); },
        () -> (float) (climateEngineeringStart), () -> (float) (climateArchiveEnd), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sample Year Start", sampleYearStart, climateEngineeringStart, climateArchiveEnd, 1);
    }
    return out;
  }
  int sampleYearEnd (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Sample Year End",
        () -> (float) sampleYearEnd,
        (v) -> { sampleYearEnd = int(v); },
        () -> (float) (climateEngineeringStart), () -> (float) (climateArchiveEnd), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sample Year End", sampleYearEnd, climateEngineeringStart, climateArchiveEnd, 1);
    }
    return out;
  }
  int sampleMemberStart (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Sample Member Start",
        () -> (float) sampleMemberStart,
        (v) -> { sampleMemberStart = int(v); },
        () -> (float) (ensembleForecastStart), () -> (float) (ensembleForecastEnd), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sample Member Start", sampleMemberStart, ensembleForecastStart, ensembleForecastEnd, 1);
    }
    return out;
  }
  int sampleMemberEnd (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Sample Member End",
        () -> (float) sampleMemberEnd,
        (v) -> { sampleMemberEnd = int(v); },
        () -> (float) (ensembleForecastStart), () -> (float) (ensembleForecastEnd), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sample Member End", sampleMemberEnd, ensembleForecastStart, ensembleForecastEnd, 1);
    }
    return out;
  }
  int sampleStationStart (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Sample Station Start",
        () -> (float) sampleStationStart,
        (v) -> { sampleStationStart = int(v); },
        () -> (float) (ensembleObservationStart), () -> (float) (ensembleObservationEnd), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sample Station Start", sampleStationStart, ensembleObservationStart, ensembleObservationEnd, 1);
    }
    return out;
  }
  int sampleStationEnd (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Sample Station End",
        () -> (float) sampleStationEnd,
        (v) -> { sampleStationEnd = int(v); },
        () -> (float) (ensembleObservationStart), () -> (float) (ensembleObservationEnd), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sample Station End", sampleStationEnd, ensembleObservationStart, ensembleObservationEnd, 1);
    }
    return out;
  }
  int ensembleObservationMaxDays (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    int s1 = 0; //start
    int s2 = 31; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Ensemble Observation Max Days",
        () -> (float) ensembleObservationMaxDays,
        (v) -> { ensembleObservationMaxDays = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Ensemble Observation Max Days", ensembleObservationMaxDays, s1, s2, s3);
    }
    return out;
  }
  int skyScenarioSetting (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 4; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Sky Scenario Setting",
        () -> (float) STUDY.skyScenarioSetting,
        (v) -> { STUDY.skyScenarioSetting = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky Scenario Setting", STUDY.skyScenarioSetting, s1, s2, s3);
    }
    return out;
  }
  int temporalFilterSetting (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Temporal Filter Setting",
        () -> (float) STUDY.temporalFilterSetting,
        (v) -> { STUDY.temporalFilterSetting = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Temporal Filter Setting", STUDY.temporalFilterSetting, s1, s2, s3);
    }
    return out;
  }
  float LocationLatitude (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    float s1 = -85; //start
    float s2 = 85; //stop
    float s3 = 0.0001; //step
    float s4 = 0.00001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Location Latitude",
        () -> LocationLAT,
        (v) -> { STATION.setLatitude(v); update_station(0); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Location Latitude", LocationLAT, s1, s2, s3, s4);
    }
    return out;
  }
  float LocationLongitude (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    float s1 = -180; //start
    float s2 = 180; //stop
    float s3 = 0.0001; //step
    float s4 = 0.00001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Location Longitude",
        () -> LocationLON,
        (v) -> { STATION.setLongitude(v); update_station(0); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Location Longitude", LocationLON, s1, s2, s3, s4);
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
  boolean addToLastGroup (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Add To Last Group",
        () -> (addToLastGroup ? 1f : 0f),
        (v) -> { addToLastGroup = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Add To Last Group", addToLastGroup);
    }
    return out;
  }
  int defaultMaterial (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 8; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Default Material",
        () -> (float) User3D.defaultMaterial,
        (v) -> { User3D.defaultMaterial = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Default Material", User3D.defaultMaterial, s1, s2, s3);
    }
    return out;
  }
  int defaultTessellation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 6; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Default Tessellation",
        () -> (float) User3D.defaultTessellation,
        (v) -> { User3D.defaultTessellation = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Default Tessellation", User3D.defaultTessellation, s1, s2, s3);
    }
    return out;
  }
  int defaultLayer (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 16; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Default Layer",
        () -> (float) User3D.defaultLayer,
        (v) -> { User3D.defaultLayer = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Default Layer", User3D.defaultLayer, s1, s2, s3);
    }
    return out;
  }
  int defaultVisibility (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Default Visibility",
        () -> (float) User3D.defaultVisibility,
        (v) -> { User3D.defaultVisibility = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Default Visibility", User3D.defaultVisibility, s1, s2, s3);
    }
    return out;
  }
  int defaultWeight (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -20; //start
    int s2 = 20; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Default Weight",
        () -> (float) User3D.defaultWeight,
        (v) -> { User3D.defaultWeight = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Default Weight", User3D.defaultWeight, s1, s2, s3);
    }
    return out;
  }
  int defaultClosed (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Default Closed",
        () -> (float) User3D.defaultClosed,
        (v) -> { User3D.defaultClosed = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Default Closed", User3D.defaultClosed, s1, s2, s3);
    }
    return out;
  }
  float creatorOrientation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 360; //stop
    float s3 = 1; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Creator Orientation",
        () -> User3D.creatorOrientation,
        (v) -> { User3D.creatorOrientation = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Orientation", User3D.creatorOrientation, s1, s2, s3, s4);
    }
    return out;
  }
  float creatorLength (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -100.0; //start
    float s2 = 1000.0; //stop
    float s3 = 1.0; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Creator Length",
        () -> User3D.creatorLength,
        (v) -> { User3D.creatorLength = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Length", User3D.creatorLength, s1, s2, s3, s4);
    }
    return out;
  }
  float creatorWidth (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -100.0; //start
    float s2 = 1000.0; //stop
    float s3 = 1.0; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Creator Width",
        () -> User3D.creatorWidth,
        (v) -> { User3D.creatorWidth = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Width", User3D.creatorWidth, s1, s2, s3, s4);
    }
    return out;
  }
  float creatorHeight (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -100.0; //start
    float s2 = 1000.0; //stop
    float s3 = 1.0; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Creator Height",
        () -> User3D.creatorHeight,
        (v) -> { User3D.creatorHeight = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Height", User3D.creatorHeight, s1, s2, s3, s4);
    }
    return out;
  }
  float creatorVolume (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 1000000000; //stop
    float s3 = 1; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Creator Volume",
        () -> User3D.creatorVolume,
        (v) -> { User3D.creatorVolume = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Volume", User3D.creatorVolume, s1, s2, s3, s4);
    }
    return out;
  }
  int creatorSnapModeIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Creator Snap Mode Index",
        () -> (float) User3D.creatorSnapModeIndex,
        (v) -> { User3D.creatorSnapModeIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Snap Mode Index", User3D.creatorSnapModeIndex, s1, s2, s3);
    }
    return out;
  }
  int creatorSphereDegree (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 5; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Creator Sphere Degree",
        () -> (float) User3D.creatorSphereDegree,
        (v) -> { User3D.creatorSphereDegree = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Sphere Degree", User3D.creatorSphereDegree, s1, s2, s3);
    }
    return out;
  }
  int creatorCylinderDegree (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 3; //start
    int s2 = 36; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Creator Cylinder Degree",
        () -> (float) User3D.creatorCylinderDegree,
        (v) -> { User3D.creatorCylinderDegree = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Cylinder Degree", User3D.creatorCylinderDegree, s1, s2, s3);
    }
    return out;
  }
  int creatorPolygonDegree (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 3; //start
    int s2 = 36; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Creator Polygon Degree",
        () -> (float) User3D.creatorPolygonDegree,
        (v) -> { User3D.creatorPolygonDegree = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Polygon Degree", User3D.creatorPolygonDegree, s1, s2, s3);
    }
    return out;
  }
  int creatorParametricTypeIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 6; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Creator Parametric Type Index",
        () -> (float) User3D.creatorParametricTypeIndex,
        (v) -> { User3D.creatorParametricTypeIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Parametric Type Index", User3D.creatorParametricTypeIndex, s1, s2, s3);
    }
    return out;
  }
  int creatorPersonTypeIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Creator Person Type Index",
        () -> (float) User3D.creatorPersonTypeIndex,
        (v) -> { User3D.creatorPersonTypeIndex = int(v); },
        () -> (float) (0), () -> (float) (allModel2Ds.peopleFileCount), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Person Type Index", User3D.creatorPersonTypeIndex, 0, allModel2Ds.peopleFileCount, 1);
    }
    return out;
  }
  int creatorPlantTypeIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Creator Plant Type Index",
        () -> (float) User3D.creatorPlantTypeIndex,
        (v) -> { User3D.creatorPlantTypeIndex = int(v); },
        () -> (float) (0), () -> (float) (allModel2Ds.treesFileCount), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Plant Type Index", User3D.creatorPlantTypeIndex, 0, allModel2Ds.treesFileCount, 1);
    }
    return out;
  }
  float modifierOpeningDepth (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -10; //start
    float s2 = 10; //stop
    float s3 = 0.1; //step

    float out = 0;
    if (created == 0) {
      putValueAction("Modifier Opening Depth",
        () -> User3D.modifierOpeningDepth,
        (v) -> { User3D.modifierOpeningDepth = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Modifier Opening Depth", User3D.modifierOpeningDepth, s1, s2, s3);
    }
    return out;
  }
  float modifierOpeningArea (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 1; //stop
    float s3 = 0.05; //step

    float out = 0;
    if (created == 0) {
      putValueAction("Modifier Opening Area",
        () -> User3D.modifierOpeningArea,
        (v) -> { User3D.modifierOpeningArea = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Modifier Opening Area", User3D.modifierOpeningArea, s1, s2, s3);
    }
    return out;
  }
  float modifierOpeningDeviation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 1; //stop
    float s3 = 0.05; //step

    float out = 0;
    if (created == 0) {
      putValueAction("Modifier Opening Deviation",
        () -> User3D.modifierOpeningDeviation,
        (v) -> { User3D.modifierOpeningDeviation = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Modifier Opening Deviation", User3D.modifierOpeningDeviation, s1, s2, s3);
    }
    return out;
  }
  int modifierTessellateRows (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 100; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Modifier Tessellate Rows",
        () -> (float) User3D.modifierTessellateRows,
        (v) -> { User3D.modifierTessellateRows = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Modifier Tessellate Rows", User3D.modifierTessellateRows, s1, s2, s3);
    }
    return out;
  }
  int modifierTessellateColumns (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 100; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Modifier Tessellate Columns",
        () -> (float) User3D.modifierTessellateColumns,
        (v) -> { User3D.modifierTessellateColumns = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Modifier Tessellate Columns", User3D.modifierTessellateColumns, s1, s2, s3);
    }
    return out;
  }
  float modifierOffsetAmount (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 25; //stop
    float s3 = 0.001; //step

    float out = 0;
    if (created == 0) {
      putValueAction("Modifier Offset Amount",
        () -> User3D.modifierOffsetAmount,
        (v) -> { User3D.modifierOffsetAmount = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Modifier Offset Amount", User3D.modifierOffsetAmount, s1, s2, s3);
    }
    return out;
  }
  float modifierWeldThreshold (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 10; //stop
    float s3 = 0.001; //step

    float out = 0;
    if (created == 0) {
      putValueAction("Modifier Weld Threshold",
        () -> User3D.modifierWeldThreshold,
        (v) -> { User3D.modifierWeldThreshold = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Modifier Weld Threshold", User3D.modifierWeldThreshold, s1, s2, s3);
    }
    return out;
  }
  float softSelectionFalloffPower (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8.0; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Soft Selection Falloff Power",
        () -> Select3D.softSelectionFalloffPower,
        (v) -> { Select3D.softSelectionFalloffPower = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.softSelectionChanged);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Soft Selection Falloff Power", Select3D.softSelectionFalloffPower, s1, s2, s3, s4);
    }
    return out;
  }
  float softSelectionFalloffRadius (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.01; //start
    float s2 = 100; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Soft Selection Falloff Radius",
        () -> Select3D.softSelectionFalloffRadius,
        (v) -> { Select3D.softSelectionFalloffRadius = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.softSelectionChanged);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Soft Selection Falloff Radius", Select3D.softSelectionFalloffRadius, s1, s2, s3, s4);
    }
    return out;
  }
  int positionVectorIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 3; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Position Vector Index",
        () -> (float) Select3D.positionVectorIndex,
        (v) -> { Select3D.positionVectorIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Position Vector Index", Select3D.positionVectorIndex, s1, s2, s3);
    }
    return out;
  }
  int rotationVectorIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Rotation Vector Index",
        () -> (float) Select3D.rotationVectorIndex,
        (v) -> { Select3D.rotationVectorIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Rotation Vector Index", Select3D.rotationVectorIndex, s1, s2, s3);
    }
    return out;
  }
  int scaleVectorIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 3; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Scale Vector Index",
        () -> (float) Select3D.scaleVectorIndex,
        (v) -> { Select3D.scaleVectorIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Scale Vector Index", Select3D.scaleVectorIndex, s1, s2, s3);
    }
    return out;
  }
  float positionSelection (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -50.0; //start
    float s2 = 50.0; //stop
    float s3 = 1.0; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Position Selection",
        () -> Select3D.position,
        (v) -> { Select3D.position = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.applyPosValue);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Position Selection", Select3D.position, s1, s2, s3, s4);
    }
    return out;
  }
  float rotationSelection (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -180.0; //start
    float s2 = 180.0; //stop
    float s3 = 1.0; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Rotation Selection",
        () -> Select3D.rotation,
        (v) -> { Select3D.rotation = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.applyRotValue);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Rotation Selection", Select3D.rotation, s1, s2, s3, s4);
    }
    return out;
  }
  float scaleSelection (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = -8.0; //start
    float s2 = 8.0; //stop
    float s3 = 1.0; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Scale Selection",
        () -> Select3D.scale,
        (v) -> { Select3D.scale = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.applyScaleValue);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Scale Selection", Select3D.scale, s1, s2, s3, s4);
    }
    return out;
  }
  int pivotAlignmentX (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Pivot Alignment X",
        () -> (float) Select3D.pivotAlignmentX,
        (v) -> { Select3D.pivotAlignmentX = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.selectionChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Pivot Alignment X", Select3D.pivotAlignmentX, s1, s2, s3);
    }
    return out;
  }
  int pivotAlignmentY (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Pivot Alignment Y",
        () -> (float) Select3D.pivotAlignmentY,
        (v) -> { Select3D.pivotAlignmentY = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.selectionChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Pivot Alignment Y", Select3D.pivotAlignmentY, s1, s2, s3);
    }
    return out;
  }
  int pivotAlignmentZ (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Pivot Alignment Z",
        () -> (float) Select3D.pivotAlignmentZ,
        (v) -> { Select3D.pivotAlignmentZ = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.selectionChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Pivot Alignment Z", Select3D.pivotAlignmentZ, s1, s2, s3);
    }
    return out;
  }
  float creatorUniformSuperellipsoidPower (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float out = 0;
    if (created == 0) {
      putValueAction("Creator Uniform Superellipsoid Power",
        () -> User3D.creatorUniformSuperellipsoidPower,
        (v) -> { User3D.creatorUniformSuperellipsoidPower = v; },
        () -> (float) (0.5), () -> (float) (CubePower), 0.001,
        u1, u2, u3,
        react.applyCreatePowAll);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Uniform Superellipsoid Power", User3D.creatorUniformSuperellipsoidPower, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }
  float creatorSuperellipsoidPowerX (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float out = 0;
    if (created == 0) {
      putValueAction("Creator Superellipsoid Power X",
        () -> User3D.creatorSuperellipsoidPowerX,
        (v) -> { User3D.creatorSuperellipsoidPowerX = v; },
        () -> (float) (0.5), () -> (float) (CubePower), 0.001,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Superellipsoid Power X", User3D.creatorSuperellipsoidPowerX, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }
  float creatorSuperellipsoidPowerY (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float out = 0;
    if (created == 0) {
      putValueAction("Creator Superellipsoid Power Y",
        () -> User3D.creatorSuperellipsoidPowerY,
        (v) -> { User3D.creatorSuperellipsoidPowerY = v; },
        () -> (float) (0.5), () -> (float) (CubePower), 0.001,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Superellipsoid Power Y", User3D.creatorSuperellipsoidPowerY, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }
  float creatorSuperellipsoidPowerZ (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float out = 0;
    if (created == 0) {
      putValueAction("Creator Superellipsoid Power Z",
        () -> User3D.creatorSuperellipsoidPowerZ,
        (v) -> { User3D.creatorSuperellipsoidPowerZ = v; },
        () -> (float) (0.5), () -> (float) (CubePower), 0.001,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Superellipsoid Power Z", User3D.creatorSuperellipsoidPowerZ, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }
  int creatorModel1DTypeIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 0; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Creator Model1D Type Index",
        () -> (float) User3D.creatorModel1DTypeIndex,
        (v) -> { User3D.creatorModel1DTypeIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Model1D Type Index", User3D.creatorModel1DTypeIndex, s1, s2, s3);
    }
    return out;
  }
  int creatorModel1DDegreeMax (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 12; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Creator Model1D Degree Max",
        () -> (float) User3D.creatorModel1DDegreeMax,
        (v) -> { User3D.creatorModel1DDegreeMax = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Model1D Degree Max", User3D.creatorModel1DDegreeMax, s1, s2, s3);
    }
    return out;
  }
  int creatorModel1DSeed (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 32767; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Creator Model1D Seed",
        () -> (float) User3D.creatorModel1DSeed,
        (v) -> { User3D.creatorModel1DSeed = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Model1D Seed", User3D.creatorModel1DSeed, s1, s2, s3);
    }
    return out;
  }
  float creatorModel1DTrunkSize (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 10; //stop
    float s3 = 0.1; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.1; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Creator Model1D Trunk Size",
        () -> User3D.creatorModel1DTrunkSize,
        (v) -> { User3D.creatorModel1DTrunkSize = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Model1D Trunk Size", User3D.creatorModel1DTrunkSize, s1, s2, s3, s4);
    }
    return out;
  }
  float creatorModel1DLeafSize (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 1; //stop
    float s3 = 0.01; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.1; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Creator Model1D Leaf Size",
        () -> User3D.creatorModel1DLeafSize,
        (v) -> { User3D.creatorModel1DLeafSize = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Model1D Leaf Size", User3D.creatorModel1DLeafSize, s1, s2, s3, s4);
    }
    return out;
  }
  float creator_Model1D_BranchTilt (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 360; //stop
    float s3 = 5; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.1; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Creator Model1D Branch Tilt",
        () -> User3D.creator_Model1D_BranchTilt,
        (v) -> { User3D.creator_Model1D_BranchTilt = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Model1D Branch Tilt", User3D.creator_Model1D_BranchTilt, s1, s2, s3, s4);
    }
    return out;
  }
  float creator_Model1D_BranchTwist (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 360; //stop
    float s3 = 5; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.1; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Creator Model1D Branch Twist",
        () -> User3D.creator_Model1D_BranchTwist,
        (v) -> { User3D.creator_Model1D_BranchTwist = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Model1D Branch Twist", User3D.creator_Model1D_BranchTwist, s1, s2, s3, s4);
    }
    return out;
  }
  float creator_Model1D_BranchRatio (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.05; //start
    float s2 = 1; //stop
    float s3 = 0.05; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.01; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Creator Model1D Branch Ratio",
        () -> User3D.creator_Model1D_BranchRatio,
        (v) -> { User3D.creator_Model1D_BranchRatio = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Model1D Branch Ratio", User3D.creator_Model1D_BranchRatio, s1, s2, s3, s4);
    }
    return out;
  }
  float creator_Model1D_TreeBase (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 4; //stop
    float s3 = 0.1; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.01; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Creator Model1D Tree Base",
        () -> User3D.creator_Model1D_TreeBase,
        (v) -> { User3D.creator_Model1D_TreeBase = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Creator Model1D Tree Base", User3D.creator_Model1D_TreeBase, s1, s2, s3, s4);
    }
    return out;
  }
  boolean Terrain_loadTextures (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Terrain Load Textures",
        () -> (Terrain.loadTextures ? 1f : 0f),
        (v) -> { Terrain.loadTextures = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.applyLandLoadTextures);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Terrain Load Textures", Terrain.loadTextures);
    }
    return out;
  }
  boolean Terrain_loadMesh (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Terrain Load Mesh",
        () -> (Terrain.loadMesh ? 1f : 0f),
        (v) -> { Terrain.loadMesh = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.applyLandLoadMesh);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Terrain Load Mesh", Terrain.loadMesh);
    }
    return out;
  }
  int Terrain_skipStart (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Terrain Skip Start",
        () -> (float) Terrain.skipStart,
        (v) -> { Terrain.skipStart = int(v); },
        () -> (float) (0), () -> (float) (Terrain.rowCount - 1), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Terrain Skip Start", Terrain.skipStart, 0, Terrain.rowCount - 1, 1);
    }
    return out;
  }
  int Terrain_skipEnd (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Terrain Skip End",
        () -> (float) Terrain.skipEnd,
        (v) -> { Terrain.skipEnd = int(v); },
        () -> (float) (0), () -> (float) (Terrain.rowCount - 1), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Terrain Skip End", Terrain.skipEnd, 0, Terrain.rowCount - 1, 1);
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
  boolean displayDepth (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Display Depth",
        () -> (Terrain.displayDepth ? 1f : 0f),
        (v) -> { Terrain.displayDepth = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Display Depth", Terrain.displayDepth);
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
      putValueAction("Model1Ds Display Leaves",
        () -> (allModel1Ds.displayLeaves ? 1f : 0f),
        (v) -> { allModel1Ds.displayLeaves = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Model1Ds Display Leaves", allModel1Ds.displayLeaves);
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
  float WindRoses_planeSize (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 50; //start
    float s2 = 3200; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Wind Roses Plane Size",
        () -> allWindRoses.planeSize,
        (v) -> { allWindRoses.planeSize = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Wind Roses Plane Size", allWindRoses.planeSize, s1, s2, s3, s4);
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
      putValueAction("Sun3D Display Path",
        () -> (Sun3D.displayPath ? 1f : 0f),
        (v) -> { Sun3D.displayPath = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D Display Path", Sun3D.displayPath);
    }
    return out;
  }
  boolean Sun3D_displayPattern (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Sun3D Display Pattern",
        () -> (Sun3D.displayPattern ? 1f : 0f),
        (v) -> { Sun3D.displayPattern = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sun3D Display Pattern", Sun3D.displayPattern);
    }
    return out;
  }
  int currentCameraIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Current Camera Index",
        () -> (float) WIN3D.currentCameraIndex,
        (v) -> { WIN3D.currentCameraIndex = int(v); },
        () -> (float) (0), () -> (float) (allCameras.num), 1,
        u1, u2, u3,
        react.applyCurrentCamera);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Current Camera Index", WIN3D.currentCameraIndex, 0, allCameras.num, 1);
    }
    return out;
  }
  float cameraClipNear (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.01; //start
    float s2 = 100; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Camera Clip Near",
        () -> WIN3D.cameraClipNear,
        (v) -> { WIN3D.cameraClipNear = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Camera Clip Near", WIN3D.cameraClipNear, s1, s2, s3, s4);
    }
    return out;
  }
  float cameraClipFar (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1000; //start
    float s2 = 2000000000; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Camera Clip Far",
        () -> WIN3D.cameraClipFar,
        (v) -> { WIN3D.cameraClipFar = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Camera Clip Far", WIN3D.cameraClipFar, s1, s2, s3, s4);
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
      putValueAction("Create3D Display Edges",
        () -> (allFaces.displayEdges ? 1f : 0f),
        (v) -> { allFaces.displayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Create3D Display Edges", allFaces.displayEdges);
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
      putValueAction("Impact Display Day",
        () -> (float) impactDisplayDay,
        (v) -> { impactDisplayDay = int(v); },
        () -> (float) (0), () -> (float) (STUDY.endDay - STUDY.startDay), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Impact Display Day", impactDisplayDay, 0, STUDY.endDay - STUDY.startDay, 1);
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
      putValueAction("Solid Impacts Grade",
        () -> allSolidImpacts.Grade,
        (v) -> { allSolidImpacts.Grade = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Solid Impacts Grade", allSolidImpacts.Grade, s1, s2, s3, s4);
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
      putValueAction("Solid Impacts Power",
        () -> allSolidImpacts.Power,
        (v) -> { allSolidImpacts.Power = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Solid Impacts Power", allSolidImpacts.Power, s1, s2, s3, s4);
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
      putValueAction("Solid Impacts R",
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
      putValueAction("Solid Impacts Z",
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
      putValueAction("Solid Impacts Position Step",
        () -> allSolidImpacts.positionStep,
        (v) -> { allSolidImpacts.positionStep = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Solid Impacts Position Step", allSolidImpacts.positionStep, s1, s2, s3, s4);
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
      putValueAction("Solid Impacts U",
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
      putValueAction("Solid Impacts V",
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
      putValueAction("Solid Impacts X",
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
      putValueAction("Solid Impacts Y",
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
  float SolidImpacts_windSpeed (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1; //start
    float s2 = 16; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Solid Impacts Wind Speed",
        () -> allSolidImpacts.WindSpeed,
        (v) -> { allSolidImpacts.WindSpeed = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Solid Impacts Wind Speed", allSolidImpacts.WindSpeed, s1, s2, s3, s4);
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
      putValueAction("Solid Impacts Wind Direction",
        () -> allSolidImpacts.WindDirection,
        (v) -> { allSolidImpacts.WindDirection = v; },
        s1, s2, s3,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Solid Impacts Wind Direction", allSolidImpacts.WindDirection, s1, s2, s3);
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
      putValueAction("Solid Impacts Process Sub Divisions",
        () -> (float) allSolidImpacts.Process_subDivisions,
        (v) -> { allSolidImpacts.Process_subDivisions = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Solid Impacts Process Sub Divisions", allSolidImpacts.Process_subDivisions, s1, s2, s3);
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
      putValueAction("Solid Impacts Display Lines",
        () -> (allSolidImpacts.displayLines ? 1f : 0f),
        (v) -> { allSolidImpacts.displayLines = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Solid Impacts Display Lines", allSolidImpacts.displayLines);
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
  float Sky3D_radius (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1; //start
    float s2 = 4000000; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Sky3D Radius",
        () -> Sky3D.radius,
        (v) -> { Sky3D.radius = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Sky3D Radius", Sky3D.radius, s1, s2, s3, s4);
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
      putValueAction("Earth3D Level Of Detail",
        () -> Earth3D.levelOfDetail,
        (v) -> { Earth3D.levelOfDetail = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Earth3D Level Of Detail", Earth3D.levelOfDetail, s1, s2, s3, s4);
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
      putValueAction("Celestial Magnification",
        () -> celestialMagnification,
        (v) -> { celestialMagnification = v; },
        s1, s2, Math.abs(s3),
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Celestial Magnification", celestialMagnification, s1, s2, s3);
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
      putValueAction("Overall Scale",
        () -> overallScale,
        (v) -> { overallScale = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Overall Scale", overallScale, s1, s2, s3, s4);
    }
    return out;
  }
  int plotLayoutIndex (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 8; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Plot Layout Index",
        () -> (float) STUDY.plotLayoutIndex,
        (v) -> { STUDY.plotLayoutIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.impactsUpdateFlag);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Plot Layout Index", STUDY.plotLayoutIndex, s1, s2, s3);
    }
    return out;
  }
  float verticalUnitScale (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.0001; //start
    float s2 = 10000; //stop
    float s3 = -pow(2.0, (1.0 / 2.0)); //step (negative = geometric multiply/divide on +/- click)

    float out = 0;
    if (created == 0) {
      putValueAction("Vertical Unit Scale",
        () -> STUDY.verticalUnitScale,
        (v) -> { STUDY.verticalUnitScale = v; },
        s1, s2, Math.abs(s3),
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Scale (" + allLayers[currentLayerId].descriptions[Language_EN] + ")", STUDY.verticalUnitScale, s1, s2, s3);
    }
    return out;
  }
  boolean showRawLines (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Show Raw Lines",
        () -> (STUDY.showRawLines ? 1f : 0f),
        (v) -> { STUDY.showRawLines = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Show Raw Lines", STUDY.showRawLines);
    }
    return out;
  }
  boolean showStatisticalRanges (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Show Statistical Ranges",
        () -> (STUDY.showStatisticalRanges ? 1f : 0f),
        (v) -> { STUDY.showStatisticalRanges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Show Statistical Ranges", STUDY.showStatisticalRanges);
    }
    return out;
  }
  boolean showStatistics (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Show Statistics",
        () -> (STUDY.showNormalLines ? 1f : 0f),
        (v) -> { STUDY.showNormalLines = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Show Statistics", STUDY.showNormalLines);
    }
    return out;
  }
  boolean showProbabilities (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Show Probabilities",
        () -> (STUDY.showProbabilities ? 1f : 0f),
        (v) -> { STUDY.showProbabilities = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Show Probabilities", STUDY.showProbabilities);
    }
    return out;
  }
  int probabilityWidthInterval (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 1; //start
    int s2 = 24; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Probability Width Interval",
        () -> (float) STUDY.probabilityWidthInterval,
        (v) -> { STUDY.probabilityWidthInterval = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Probability Width Interval", STUDY.probabilityWidthInterval, s1, s2, s3);
    }
    return out;
  }
  float probabilityHeightInterval (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 2; //start
    float s2 = 32; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 1; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Probability Height Interval",
        () -> STUDY.probabilityHeightInterval,
        (v) -> { STUDY.probabilityHeightInterval = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Probability Height Interval", STUDY.probabilityHeightInterval, s1, s2, s3, s4);
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
  int statisticalRangesColorScaleIndex (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Statistical Ranges Color Scale Index",
        () -> (float) STUDY.statisticalRangesColorScaleIndex,
        (v) -> { STUDY.statisticalRangesColorScaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Statistical Ranges Color Scale Index", STUDY.statisticalRangesColorScaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int statisticalRangesColorScaleDirection (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("Statistical Ranges Color Scale Direction",
        () -> (float) STUDY.statisticalRangesColorScaleDirection,
        (v) -> { STUDY.statisticalRangesColorScaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Statistical Ranges Color Scale Direction", STUDY.statisticalRangesColorScaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float statisticalRangesColorScaleFactor (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Statistical Ranges Color Scale Factor",
        () -> STUDY.statisticalRangesColorScaleFactor,
        (v) -> { STUDY.statisticalRangesColorScaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Statistical Ranges Color Scale Factor", STUDY.statisticalRangesColorScaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int probabilitiesColorScaleIndex (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Probabilities Color Scale Index",
        () -> (float) STUDY.probabilitiesColorScaleIndex,
        (v) -> { STUDY.probabilitiesColorScaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Probabilities Color Scale Index", STUDY.probabilitiesColorScaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int probabilitiesColorScaleDirection (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("Probabilities Color Scale Direction",
        () -> (float) STUDY.probabilitiesColorScaleDirection,
        (v) -> { STUDY.probabilitiesColorScaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Probabilities Color Scale Direction", STUDY.probabilitiesColorScaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float probabilitiesColorScaleFactor (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Probabilities Color Scale Factor",
        () -> STUDY.probabilitiesColorScaleFactor,
        (v) -> { STUDY.probabilitiesColorScaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Probabilities Color Scale Factor", STUDY.probabilitiesColorScaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  float opacityPercentage (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1; //start
    float s2 = 100; //stop
    float s3 = -pow(2.0, (1.0 / 4.0)); //step (negative = geometric multiply/divide on +/- click)

    float out = 0;
    if (created == 0) {
      putValueAction("Opacity Percentage",
        () -> STUDY.opacityPercentage,
        (v) -> { STUDY.opacityPercentage = v; },
        s1, s2, Math.abs(s3),
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Opacity Percentage", STUDY.opacityPercentage, s1, s2, s3);
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
  boolean groupDisplayPivot (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Group Display Pivot",
        () -> (Select3D.groupDisplayPivot ? 1f : 0f),
        (v) -> { Select3D.groupDisplayPivot = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Group Display Pivot", Select3D.groupDisplayPivot);
    }
    return out;
  }
  boolean pivotDisplayReference (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Pivot Display Reference",
        () -> (Select3D.pivotDisplayReference ? 1f : 0f),
        (v) -> { Select3D.pivotDisplayReference = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Pivot Display Reference", Select3D.pivotDisplayReference);
    }
    return out;
  }
  boolean groupDisplayBox (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Group Display Box",
        () -> (Select3D.groupDisplayBox ? 1f : 0f),
        (v) -> { Select3D.groupDisplayBox = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Group Display Box", Select3D.groupDisplayBox);
    }
    return out;
  }
  boolean groupDisplayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Group Display Edges",
        () -> (Select3D.groupDisplayEdges ? 1f : 0f),
        (v) -> { Select3D.groupDisplayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Group Display Edges", Select3D.groupDisplayEdges);
    }
    return out;
  }
  boolean faceDisplayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Face Display Edges",
        () -> (Select3D.faceDisplayEdges ? 1f : 0f),
        (v) -> { Select3D.faceDisplayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Face Display Edges", Select3D.faceDisplayEdges);
    }
    return out;
  }
  boolean faceDisplayVertexSelection (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Face Display Vertex Selection",
        () -> (Select3D.faceDisplayvertexSelection ? 1f : 0f),
        (v) -> { Select3D.faceDisplayvertexSelection = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Face Display Vertex Selection", Select3D.faceDisplayvertexSelection);
    }
    return out;
  }
  boolean polylineDisplayVertexSelection (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Polyline Display Vertex Selection",
        () -> (Select3D.polylineDisplayvertexSelection ? 1f : 0f),
        (v) -> { Select3D.polylineDisplayvertexSelection = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Polyline Display Vertex Selection", Select3D.polylineDisplayvertexSelection);
    }
    return out;
  }
  boolean vertexDisplayMarkers (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Vertex Display Markers",
        () -> (Select3D.vertexDisplayMarkers ? 1f : 0f),
        (v) -> { Select3D.vertexDisplayMarkers = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Vertex Display Markers", Select3D.vertexDisplayMarkers);
    }
    return out;
  }
  boolean polylineDisplayVertices (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Polyline Display Vertices",
        () -> (Select3D.polylineDisplayVertices ? 1f : 0f),
        (v) -> { Select3D.polylineDisplayVertices = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Polyline Display Vertices", Select3D.polylineDisplayVertices);
    }
    return out;
  }
  boolean model2DDisplayBounds (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Model2DDisplay Bounds",
        () -> (Select3D.model2DDisplayBounds ? 1f : 0f),
        (v) -> { Select3D.model2DDisplayBounds = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Model2DDisplay Bounds", Select3D.model2DDisplayBounds);
    }
    return out;
  }
  boolean model1DDisplayBounds (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Model1DDisplay Bounds",
        () -> (Select3D.model1DDisplayBounds ? 1f : 0f),
        (v) -> { Select3D.model1DDisplayBounds = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Model1DDisplay Bounds", Select3D.model1DDisplayBounds);
    }
    return out;
  }
  boolean solidDisplayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Solid Display Edges",
        () -> (Select3D.solidDisplayEdges ? 1f : 0f),
        (v) -> { Select3D.solidDisplayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Solid Display Edges", Select3D.solidDisplayEdges);
    }
    return out;
  }
  boolean sectionDisplayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Section Display Edges",
        () -> (Select3D.sectionDisplayEdges ? 1f : 0f),
        (v) -> { Select3D.sectionDisplayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Section Display Edges", Select3D.sectionDisplayEdges);
    }
    return out;
  }
  boolean cameraDisplayFrustum (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Camera Display Frustum",
        () -> (Select3D.cameraDisplayFrustum ? 1f : 0f),
        (v) -> { Select3D.cameraDisplayFrustum = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Camera Display Frustum", Select3D.cameraDisplayFrustum);
    }
    return out;
  }
  boolean terrainDisplayVertices (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Terrain Display Vertices",
        () -> (Select3D.terrainDisplayVertices ? 1f : 0f),
        (v) -> { Select3D.terrainDisplayVertices = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Terrain Display Vertices", Select3D.terrainDisplayVertices);
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
      putValueAction("Interpolation Weight",
        () -> interpolationWeight,
        (v) -> { interpolationWeight = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Interpolation Weight", interpolationWeight, s1, s2, s3);
    }
    return out;
  }
  int climateBasedSolarForecast (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Climate Based Solar Forecast",
        () -> (float) climateBasedSolarForecast,
        (v) -> { climateBasedSolarForecast = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeChange);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Climate Based Solar Forecast", climateBasedSolarForecast, s1, s2, s3);
    }
    return out;
  }
  int climateBasedWeatherForecast (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Climate Based Weather Forecast",
        () -> (float) climateBasedWeatherForecast,
        (v) -> { climateBasedWeatherForecast = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeChange);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Climate Based Weather Forecast", climateBasedWeatherForecast, s1, s2, s3);
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
      putValueAction("Develop Layer Option",
        () -> (float) developLayerOption,
        (v) -> { developLayerOption = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Develop Layer Option", developLayerOption, s1, s2, s3);
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
      putValueAction("Develop Layer Interval",
        () -> (float) developLayerInterval,
        (v) -> { developLayerInterval = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Develop Layer Interval", developLayerInterval, s1, s2, s3);
    }
    return out;
  }
  float developLayerAngleInclination (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 90; //stop
    float s3 = 5; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 1; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Develop Layer Angle Inclination",
        () -> developLayerAngleInclination,
        (v) -> { developLayerAngleInclination = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Develop Layer Angle Inclination", developLayerAngleInclination, s1, s2, s3, s4);
    }
    return out;
  }
  float developLayerAngleOrientation (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 360; //stop
    float s3 = 15; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 1; //round

    float out = 0;
    if (created == 0) {
      putValueAction("Develop Layer Angle Orientation",
        () -> developLayerAngleOrientation,
        (v) -> { developLayerAngleOrientation = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Develop Layer Angle Orientation", developLayerAngleOrientation, s1, s2, s3, s4);
    }
    return out;
  }
  int currentDataSource (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    if (created == 0) {
      putValueAction("Current Data Source",
        () -> (float) currentDataSource,
        (v) -> { currentDataSource = int(v); },
        () -> (float) (0), () -> (float) (MAXIMUM_dataID), 1,
        u1, u2, u3,
        react.impactsUpdateFlag);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Current Data Source", currentDataSource, 0, MAXIMUM_dataID, 1);
    }
    return out;
  }
  int impactLayerIndex (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 8; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Impact Layer Index",
        () -> (float) STUDY.impactLayerIndex,
        (v) -> { STUDY.impactLayerIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Impact Layer Index", STUDY.impactLayerIndex, s1, s2, s3);
    }
    return out;
  }
  boolean rawLinesExporter (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Raw Lines Exporter",
        () -> (STUDY.rawLinesExporter ? 1f : 0f),
        (v) -> { STUDY.rawLinesExporter = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Raw Lines Exporter", STUDY.rawLinesExporter);
    }
    return out;
  }
  boolean normalLinesExporter (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Normal Lines Exporter",
        () -> (STUDY.normalLinesExporter ? 1f : 0f),
        (v) -> { STUDY.normalLinesExporter = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Normal Lines Exporter", STUDY.normalLinesExporter);
    }
    return out;
  }
  boolean probabilitiesExporter (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Probabilities Exporter",
        () -> (STUDY.probabilitiesExporter ? 1f : 0f),
        (v) -> { STUDY.probabilitiesExporter = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Probabilities Exporter", STUDY.probabilitiesExporter);
    }
    return out;
  }
  float exporterScale (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = .001; //start
    float s2 = 1000; //stop
    float s3 = -0.1; //step (negative = geometric multiply/divide on +/- click)

    float out = 0;
    if (created == 0) {
      putValueAction("Exporter Scale",
        () -> User3D.exporterScale,
        (v) -> { User3D.exporterScale = v; },
        s1, s2, Math.abs(s3),
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Exporter Scale", User3D.exporterScale, s1, s2, s3);
    }
    return out;
  }
  int exporterYaxisUp (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Exporter Yaxis Up",
        () -> (float) User3D.exporterYaxisUp,
        (v) -> { User3D.exporterYaxisUp = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Exporter Yaxis Up", User3D.exporterYaxisUp, s1, s2, s3);
    }
    return out;
  }
  int exporterPrecisionVertex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 6; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Exporter Precision Vertex",
        () -> (float) User3D.exporterPrecisionVertex,
        (v) -> { User3D.exporterPrecisionVertex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Exporter Precision Vertex", User3D.exporterPrecisionVertex, s1, s2, s3);
    }
    return out;
  }
  int exporterPrecisionVertexTexture (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 6; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Exporter Precision Vertex Texture",
        () -> (float) User3D.exporterPrecisionVertexTexture,
        (v) -> { User3D.exporterPrecisionVertexTexture = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Exporter Precision Vertex Texture", User3D.exporterPrecisionVertexTexture, s1, s2, s3);
    }
    return out;
  }
  int exporterMaintainPolygons (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Exporter Maintain Polygons",
        () -> (float) User3D.exporterMaintainPolygons,
        (v) -> { User3D.exporterMaintainPolygons = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Exporter Maintain Polygons", User3D.exporterMaintainPolygons, s1, s2, s3);
    }
    return out;
  }
  boolean exporterMaterialLibrary (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Exporter Material Library",
        () -> (User3D.exporterMaterialLibrary ? 1f : 0f),
        (v) -> { User3D.exporterMaterialLibrary = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Exporter Material Library", User3D.exporterMaterialLibrary);
    }
    return out;
  }
  boolean exporterDoubleSided (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    if (created == 0) {
      putValueAction("Exporter Double Sided",
        () -> (User3D.exporterDoubleSided ? 1f : 0f),
        (v) -> { User3D.exporterDoubleSided = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Exporter Double Sided", User3D.exporterDoubleSided);
    }
    return out;
  }
  int exporterColorScaleResolution (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 32; //start
    int s2 = 2048; //stop
    int s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    if (created == 0) {
      putValueAction("Exporter Color Scale Resolution",
        () -> (float) User3D.exporterColorScaleResolution,
        (v) -> { User3D.exporterColorScaleResolution = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Exporter Color Scale Resolution", User3D.exporterColorScaleResolution, s1, s2, s3, s4);
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
      putValueAction("Record Solid Impact In PDF",
        () -> (float) allSolidImpacts.record_PDF,
        (v) -> { allSolidImpacts.record_PDF = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Record Solid Impact In PDF", allSolidImpacts.record_PDF, s1, s2, s3);
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
  int WindRoses_imageResolution (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 200; //start
    int s2 = 600; //stop
    int s3 = 100; //step

    int out = 0;
    if (created == 0) {
      putValueAction("Wind Roses Image Resolution",
        () -> (float) allWindRoses.imageResolution,
        (v) -> { allWindRoses.imageResolution = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = int(UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, "Wind Roses Image Resolution", allWindRoses.imageResolution, s1, s2, s3));
    }
    return out;
  }
}
