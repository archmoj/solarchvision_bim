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
    String command = "End Day";
    if (created == 0) {
      putValueAction(command,
        () -> (float) STUDY.endDay,
        (v) -> { STUDY.endDay = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyStudyJEnd);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.endDay, s1, s2, s3);
    }
    return out;
  }
  float dailyStep (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1.0; //start
    float s2 = 182.5; //stop
    float s3 = 0.5; //step

    float out = 0;
    String command = "Daily Step";
    if (created == 0) {
      putValueAction(command,
        () -> STUDY.dailyStep,
        (v) -> { STUDY.dailyStep = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.dailyStep, s1, s2, s3);
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
    String command = "Days Merged Count";
    if (created == 0) {
      putValueAction(command,
        () -> (float) STUDY.daysMergedCount,
        (v) -> { STUDY.daysMergedCount = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.daysMergedCount, s1, s2, s3);
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
    String command = "Date";
    if (created == 0) {
      putValueAction(command,
        () -> TIME.date,
        (v) -> { TIME.date = v; },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeDate);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, TIME.date, s1, s2, s3);
    }
    return out;
  }
  // The day-of-year offset applied throughout the solar/shadow math (see
  // STUDY.pde, Sun3D.pde, WIN3D.pde, calculate_*Solar_array.pde, ...) -
  // distinct from Day/Month/Year below, which describe the calendar date
  // itself. Normally kept in sync with month/day via react.applyTimeChange,
  // but UI_caseBar's "Days" tab also nudges it directly by a delta (see
  // handleDaysClick), independently of month/day - hence its own command.
  int beginDay (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 364; //stop
    int s3 = 1; //step

    int out = 0;
    String command = "Begin Day";
    if (created == 0) {
      putValueAction(command,
        () -> (float) TIME.beginDay,
        (v) -> { TIME.beginDay = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyBeginDayChange);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, TIME.beginDay, s1, s2, s3);
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
    String command = "Day";
    if (created == 0) {
      putValueAction(command,
        () -> (float) TIME.day,
        (v) -> { TIME.day = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeChange);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, TIME.day, s1, s2, s3);
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
    String command = "Month";
    if (created == 0) {
      putValueAction(command,
        () -> (float) TIME.month,
        (v) -> { TIME.month = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeChange);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, TIME.month, s1, s2, s3);
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
    String command = "Year";
    if (created == 0) {
      putValueAction(command,
        () -> (float) TIME.year,
        (v) -> { TIME.year = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeChange);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, TIME.year, s1, s2, s3);
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
    String command = "Start Hour";
    if (created == 0) {
      putValueAction(command,
        () -> (float) STUDY.startHour,
        (v) -> { STUDY.startHour = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.startHour, s1, s2, s3);
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
    String command = "End Hour";
    if (created == 0) {
      putValueAction(command,
        () -> (float) STUDY.endHour,
        (v) -> { STUDY.endHour = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.endHour, s1, s2, s3);
    }
    return out;
  }
  int sampleYearStart (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Sample Year Start";
    if (created == 0) {
      putValueAction(command,
        () -> (float) sampleYearStart,
        (v) -> { sampleYearStart = int(v); },
        () -> (float) (climateEngineeringStart), () -> (float) (climateArchiveEnd), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, sampleYearStart, climateEngineeringStart, climateArchiveEnd, 1);
    }
    return out;
  }
  int sampleYearEnd (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Sample Year End";
    if (created == 0) {
      putValueAction(command,
        () -> (float) sampleYearEnd,
        (v) -> { sampleYearEnd = int(v); },
        () -> (float) (climateEngineeringStart), () -> (float) (climateArchiveEnd), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, sampleYearEnd, climateEngineeringStart, climateArchiveEnd, 1);
    }
    return out;
  }
  int sampleMemberStart (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Sample Member Start";
    if (created == 0) {
      putValueAction(command,
        () -> (float) sampleMemberStart,
        (v) -> { sampleMemberStart = int(v); },
        () -> (float) (ensembleForecastStart), () -> (float) (ensembleForecastEnd), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, sampleMemberStart, ensembleForecastStart, ensembleForecastEnd, 1);
    }
    return out;
  }
  int sampleMemberEnd (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Sample Member End";
    if (created == 0) {
      putValueAction(command,
        () -> (float) sampleMemberEnd,
        (v) -> { sampleMemberEnd = int(v); },
        () -> (float) (ensembleForecastStart), () -> (float) (ensembleForecastEnd), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, sampleMemberEnd, ensembleForecastStart, ensembleForecastEnd, 1);
    }
    return out;
  }
  int sampleStationStart (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Sample Station Start";
    if (created == 0) {
      putValueAction(command,
        () -> (float) sampleStationStart,
        (v) -> { sampleStationStart = int(v); },
        () -> (float) (ensembleObservationStart), () -> (float) (ensembleObservationEnd), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, sampleStationStart, ensembleObservationStart, ensembleObservationEnd, 1);
    }
    return out;
  }
  int sampleStationEnd (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Sample Station End";
    if (created == 0) {
      putValueAction(command,
        () -> (float) sampleStationEnd,
        (v) -> { sampleStationEnd = int(v); },
        () -> (float) (ensembleObservationStart), () -> (float) (ensembleObservationEnd), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, sampleStationEnd, ensembleObservationStart, ensembleObservationEnd, 1);
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
    String command = "Ensemble Observation Max Days";
    if (created == 0) {
      putValueAction(command,
        () -> (float) ensembleObservationMaxDays,
        (v) -> { ensembleObservationMaxDays = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, ensembleObservationMaxDays, s1, s2, s3);
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
    String command = "Sky Scenario Setting";
    if (created == 0) {
      putValueAction(command,
        () -> (float) STUDY.skyScenarioSetting,
        (v) -> { STUDY.skyScenarioSetting = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.skyScenarioSetting, s1, s2, s3);
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
    String command = "Temporal Filter Setting";
    if (created == 0) {
      putValueAction(command,
        () -> (float) STUDY.temporalFilterSetting,
        (v) -> { STUDY.temporalFilterSetting = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.temporalFilterSetting, s1, s2, s3);
    }
    return out;
  }
  float locationLatitude (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    float s1 = -85; //start
    float s2 = 85; //stop
    float s3 = 0.0001; //step
    float s4 = 0.00001; //round

    float out = 0;
    String command = "Location Latitude";
    if (created == 0) {
      putValueAction(command,
        () -> locationLatitude,
        (v) -> { STATION.setLatitude(v); update_station(0); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, locationLatitude, s1, s2, s3, s4);
    }
    return out;
  }
  float locationLongitude (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    float s1 = -180; //start
    float s2 = 180; //stop
    float s3 = 0.0001; //step
    float s4 = 0.00001; //round

    float out = 0;
    String command = "Location Longitude";
    if (created == 0) {
      putValueAction(command,
        () -> locationLongitude,
        (v) -> { STATION.setLongitude(v); update_station(0); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, locationLongitude, s1, s2, s3, s4);
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
    String command = "Climate Typical Year Display All";
    if (created == 0) {
      putValueAction(command,
        () -> (float) WORLD.climateTypicalYearDisplayAll,
        (v) -> { WORLD.climateTypicalYearDisplayAll = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, WORLD.climateTypicalYearDisplayAll, s1, s2, s3);
    }
    return out;
  }
  boolean climateTypicalYearDisplayNear (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    boolean out = false;
    String command = "Climate Typical Year Display Near";
    if (created == 0) {
      putValueAction(command,
        () -> (WORLD.climateTypicalYearDisplayNear ? 1f : 0f),
        (v) -> { WORLD.climateTypicalYearDisplayNear = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, WORLD.climateTypicalYearDisplayNear);
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
    String command = "Climate Engineering Display All";
    if (created == 0) {
      putValueAction(command,
        () -> (float) WORLD.climateEngineeringDisplayAll,
        (v) -> { WORLD.climateEngineeringDisplayAll = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, WORLD.climateEngineeringDisplayAll, s1, s2, s3);
    }
    return out;
  }
  boolean climateEngineeringDisplayNear (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    boolean out = false;
    String command = "Climate Engineering Display Near";
    if (created == 0) {
      putValueAction(command,
        () -> (WORLD.climateEngineeringDisplayNear ? 1f : 0f),
        (v) -> { WORLD.climateEngineeringDisplayNear = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, WORLD.climateEngineeringDisplayNear);
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
    String command = "Climate Archive Display All";
    if (created == 0) {
      putValueAction(command,
        () -> (float) WORLD.climateArchiveDisplayAll,
        (v) -> { WORLD.climateArchiveDisplayAll = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, WORLD.climateArchiveDisplayAll, s1, s2, s3);
    }
    return out;
  }
  boolean climateArchiveDisplayNear (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    boolean out = false;
    String command = "Climate Archive Display Near";
    if (created == 0) {
      putValueAction(command,
        () -> (WORLD.climateArchiveDisplayNear ? 1f : 0f),
        (v) -> { WORLD.climateArchiveDisplayNear = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, WORLD.climateArchiveDisplayNear);
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
    String command = "Ensemble Observation Display All";
    if (created == 0) {
      putValueAction(command,
        () -> (float) WORLD.ensembleObservationDisplayAll,
        (v) -> { WORLD.ensembleObservationDisplayAll = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, WORLD.ensembleObservationDisplayAll, s1, s2, s3);
    }
    return out;
  }
  boolean ensembleObservationDisplayNear (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    boolean out = false;
    String command = "Ensemble Observation Display Near";
    if (created == 0) {
      putValueAction(command,
        () -> (WORLD.ensembleObservationDisplayNear ? 1f : 0f),
        (v) -> { WORLD.ensembleObservationDisplayNear = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, WORLD.ensembleObservationDisplayNear);
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
    String command = "Ensemble Forecast Display All";
    if (created == 0) {
      putValueAction(command,
        () -> (float) WORLD.ensembleForecastDisplayAll,
        (v) -> { WORLD.ensembleForecastDisplayAll = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, WORLD.ensembleForecastDisplayAll, s1, s2, s3);
    }
    return out;
  }
  boolean ensembleForecastDisplayNear (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 1; // updateWORLD

    boolean out = false;
    String command = "Ensemble Forecast Display Near";
    if (created == 0) {
      putValueAction(command,
        () -> (WORLD.ensembleForecastDisplayNear ? 1f : 0f),
        (v) -> { WORLD.ensembleForecastDisplayNear = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, WORLD.ensembleForecastDisplayNear);
    }
    return out;
  }
  boolean addToLastGroup (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Add To Last Group";
    if (created == 0) {
      putValueAction(command,
        () -> (addToLastGroup ? 1f : 0f),
        (v) -> { addToLastGroup = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, addToLastGroup);
    }
    return out;
  }
  int creatorMaterial (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 8; //stop
    int s3 = 1; //step

    int out = 0;
    String command = "Creator Material";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.creatorMaterial,
        (v) -> { User3D.creatorMaterial = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorMaterial, s1, s2, s3);
    }
    return out;
  }
  int creatorTessellation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 6; //stop
    int s3 = 1; //step

    int out = 0;
    String command = "Creator Tessellation";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.creatorTessellation,
        (v) -> { User3D.creatorTessellation = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorTessellation, s1, s2, s3);
    }
    return out;
  }
  int creatorLayer (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 16; //stop
    int s3 = 1; //step

    int out = 0;
    String command = "Creator Layer";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.creatorLayer,
        (v) -> { User3D.creatorLayer = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorLayer, s1, s2, s3);
    }
    return out;
  }
  int creatorVisibility (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -1; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    String command = "Creator Visibility";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.creatorVisibility,
        (v) -> { User3D.creatorVisibility = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorVisibility, s1, s2, s3);
    }
    return out;
  }
  int creatorWeight (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -20; //start
    int s2 = 20; //stop
    int s3 = 1; //step

    int out = 0;
    String command = "Creator Weight";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.creatorWeight,
        (v) -> { User3D.creatorWeight = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorWeight, s1, s2, s3);
    }
    return out;
  }
  int creatorClosed (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 1; //stop
    int s3 = 1; //step

    int out = 0;
    String command = "Creator Closed";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.creatorClosed,
        (v) -> { User3D.creatorClosed = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorClosed, s1, s2, s3);
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
    String command = "Creator Orientation";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.creatorOrientation,
        (v) -> { User3D.creatorOrientation = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorOrientation, s1, s2, s3, s4);
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
    String command = "Creator Length";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.creatorLength,
        (v) -> { User3D.creatorLength = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorLength, s1, s2, s3, s4);
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
    String command = "Creator Width";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.creatorWidth,
        (v) -> { User3D.creatorWidth = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorWidth, s1, s2, s3, s4);
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
    String command = "Creator Height";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.creatorHeight,
        (v) -> { User3D.creatorHeight = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorHeight, s1, s2, s3, s4);
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
    String command = "Creator Volume";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.creatorVolume,
        (v) -> { User3D.creatorVolume = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorVolume, s1, s2, s3, s4);
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
    String command = "Creator Snap Mode Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.creatorSnapModeIndex,
        (v) -> { User3D.creatorSnapModeIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorSnapModeIndex, s1, s2, s3);
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
    String command = "Creator Sphere Degree";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.creatorSphereDegree,
        (v) -> { User3D.creatorSphereDegree = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorSphereDegree, s1, s2, s3);
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
    String command = "Creator Cylinder Degree";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.creatorCylinderDegree,
        (v) -> { User3D.creatorCylinderDegree = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorCylinderDegree, s1, s2, s3);
    }
    return out;
  }
  int creatorConeDegree (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 3; //start
    int s2 = 36; //stop
    int s3 = 1; //step

    int out = 0;
    String command = "Creator Cone Degree";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.creatorConeDegree,
        (v) -> { User3D.creatorConeDegree = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorConeDegree, s1, s2, s3);
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
    String command = "Creator Polygon Degree";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.creatorPolygonDegree,
        (v) -> { User3D.creatorPolygonDegree = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorPolygonDegree, s1, s2, s3);
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
    String command = "Creator Parametric Type Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.creatorParametricTypeIndex,
        (v) -> { User3D.creatorParametricTypeIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorParametricTypeIndex, s1, s2, s3);
    }
    return out;
  }
  int creatorPersonTypeIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Creator Person Type Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.creatorPersonTypeIndex,
        (v) -> { User3D.creatorPersonTypeIndex = int(v); },
        () -> (float) (0), () -> (float) (allModel2Ds.peopleFileCount), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorPersonTypeIndex, 0, allModel2Ds.peopleFileCount, 1);
    }
    return out;
  }
  int creatorPlantTypeIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Creator Plant Type Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.creatorPlantTypeIndex,
        (v) -> { User3D.creatorPlantTypeIndex = int(v); },
        () -> (float) (0), () -> (float) (allModel2Ds.treesFileCount), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorPlantTypeIndex, 0, allModel2Ds.treesFileCount, 1);
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
    String command = "Modifier Opening Depth";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.modifierOpeningDepth,
        (v) -> { User3D.modifierOpeningDepth = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.modifierOpeningDepth, s1, s2, s3);
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
    String command = "Modifier Opening Area";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.modifierOpeningArea,
        (v) -> { User3D.modifierOpeningArea = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.modifierOpeningArea, s1, s2, s3);
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
    String command = "Modifier Opening Deviation";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.modifierOpeningDeviation,
        (v) -> { User3D.modifierOpeningDeviation = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.modifierOpeningDeviation, s1, s2, s3);
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
    String command = "Modifier Tessellate Rows";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.modifierTessellateRows,
        (v) -> { User3D.modifierTessellateRows = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.modifierTessellateRows, s1, s2, s3);
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
    String command = "Modifier Tessellate Columns";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.modifierTessellateColumns,
        (v) -> { User3D.modifierTessellateColumns = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.modifierTessellateColumns, s1, s2, s3);
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
    String command = "Modifier Offset Amount";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.modifierOffsetAmount,
        (v) -> { User3D.modifierOffsetAmount = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.modifierOffsetAmount, s1, s2, s3);
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
    String command = "Modifier Weld Threshold";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.modifierWeldThreshold,
        (v) -> { User3D.modifierWeldThreshold = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.modifierWeldThreshold, s1, s2, s3);
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
    String command = "Soft Selection Falloff Power";
    if (created == 0) {
      putValueAction(command,
        () -> Select3D.softSelectionFalloffPower,
        (v) -> { Select3D.softSelectionFalloffPower = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.softSelectionChanged);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.softSelectionFalloffPower, s1, s2, s3, s4);
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
    String command = "Soft Selection Falloff Radius";
    if (created == 0) {
      putValueAction(command,
        () -> Select3D.softSelectionFalloffRadius,
        (v) -> { Select3D.softSelectionFalloffRadius = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.softSelectionChanged);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.softSelectionFalloffRadius, s1, s2, s3, s4);
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
    String command = "Position Vector Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Select3D.positionVectorIndex,
        (v) -> { Select3D.positionVectorIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.positionVectorIndex, s1, s2, s3);
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
    String command = "Rotation Vector Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Select3D.rotationVectorIndex,
        (v) -> { Select3D.rotationVectorIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.rotationVectorIndex, s1, s2, s3);
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
    String command = "Scale Vector Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Select3D.scaleVectorIndex,
        (v) -> { Select3D.scaleVectorIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.scaleVectorIndex, s1, s2, s3);
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
    String command = "Position Selection";
    if (created == 0) {
      putValueAction(command,
        () -> Select3D.position,
        (v) -> { Select3D.position = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.applyPosValue);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.position, s1, s2, s3, s4);
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
    String command = "Rotation Selection";
    if (created == 0) {
      putValueAction(command,
        () -> Select3D.rotation,
        (v) -> { Select3D.rotation = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.applyRotValue);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.rotation, s1, s2, s3, s4);
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
    String command = "Scale Selection";
    if (created == 0) {
      putValueAction(command,
        () -> Select3D.scale,
        (v) -> { Select3D.scale = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.applyScaleValue);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.scale, s1, s2, s3, s4);
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
    String command = "Pivot Alignment X";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Select3D.pivotAlignmentX,
        (v) -> { Select3D.pivotAlignmentX = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.selectionChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.pivotAlignmentX, s1, s2, s3);
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
    String command = "Pivot Alignment Y";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Select3D.pivotAlignmentY,
        (v) -> { Select3D.pivotAlignmentY = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.selectionChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.pivotAlignmentY, s1, s2, s3);
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
    String command = "Pivot Alignment Z";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Select3D.pivotAlignmentZ,
        (v) -> { Select3D.pivotAlignmentZ = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.selectionChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.pivotAlignmentZ, s1, s2, s3);
    }
    return out;
  }
  float creatorUniformSuperellipsoidPower (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float out = 0;
    String command = "Creator Uniform Superellipsoid Power";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.creatorUniformSuperellipsoidPower,
        (v) -> { User3D.creatorUniformSuperellipsoidPower = v; },
        () -> (float) (0.5), () -> (float) (CubePower), 0.001,
        u1, u2, u3,
        react.applyCreatePowAll);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorUniformSuperellipsoidPower, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }
  float creatorSuperellipsoidPowerX (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float out = 0;
    String command = "Creator Superellipsoid Power X";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.creatorSuperellipsoidPowerX,
        (v) -> { User3D.creatorSuperellipsoidPowerX = v; },
        () -> (float) (0.5), () -> (float) (CubePower), 0.001,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorSuperellipsoidPowerX, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }
  float creatorSuperellipsoidPowerY (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float out = 0;
    String command = "Creator Superellipsoid Power Y";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.creatorSuperellipsoidPowerY,
        (v) -> { User3D.creatorSuperellipsoidPowerY = v; },
        () -> (float) (0.5), () -> (float) (CubePower), 0.001,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorSuperellipsoidPowerY, 0.5, CubePower, -2, 0.001);
    }
    return out;
  }
  float creatorSuperellipsoidPowerZ (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float out = 0;
    String command = "Creator Superellipsoid Power Z";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.creatorSuperellipsoidPowerZ,
        (v) -> { User3D.creatorSuperellipsoidPowerZ = v; },
        () -> (float) (0.5), () -> (float) (CubePower), 0.001,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorSuperellipsoidPowerZ, 0.5, CubePower, -2, 0.001);
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
    String command = "Creator Model1D Type Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.creatorModel1DTypeIndex,
        (v) -> { User3D.creatorModel1DTypeIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorModel1DTypeIndex, s1, s2, s3);
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
    String command = "Creator Model1D Degree Max";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.creatorModel1DDegreeMax,
        (v) -> { User3D.creatorModel1DDegreeMax = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorModel1DDegreeMax, s1, s2, s3);
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
    String command = "Creator Model1D Seed";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.creatorModel1DSeed,
        (v) -> { User3D.creatorModel1DSeed = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorModel1DSeed, s1, s2, s3);
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
    String command = "Creator Model1D Trunk Size";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.creatorModel1DTrunkSize,
        (v) -> { User3D.creatorModel1DTrunkSize = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorModel1DTrunkSize, s1, s2, s3, s4);
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
    String command = "Creator Model1D Leaf Size";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.creatorModel1DLeafSize,
        (v) -> { User3D.creatorModel1DLeafSize = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorModel1DLeafSize, s1, s2, s3, s4);
    }
    return out;
  }
  float creatorModel1DBranchTilt (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 360; //stop
    float s3 = 5; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.1; //round

    float out = 0;
    String command = "Creator Model1D Branch Tilt";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.creatorModel1DBranchTilt,
        (v) -> { User3D.creatorModel1DBranchTilt = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorModel1DBranchTilt, s1, s2, s3, s4);
    }
    return out;
  }
  float creatorModel1DBranchTwist (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 360; //stop
    float s3 = 5; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.1; //round

    float out = 0;
    String command = "Creator Model1D Branch Twist";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.creatorModel1DBranchTwist,
        (v) -> { User3D.creatorModel1DBranchTwist = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorModel1DBranchTwist, s1, s2, s3, s4);
    }
    return out;
  }
  float creatorModel1DBranchRatio (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.05; //start
    float s2 = 1; //stop
    float s3 = 0.05; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.01; //round

    float out = 0;
    String command = "Creator Model1D Branch Ratio";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.creatorModel1DBranchRatio,
        (v) -> { User3D.creatorModel1DBranchRatio = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorModel1DBranchRatio, s1, s2, s3, s4);
    }
    return out;
  }
  float creatorModel1DTreeBase (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0; //start
    float s2 = 4; //stop
    float s3 = 0.1; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.01; //round

    float out = 0;
    String command = "Creator Model1D Tree Base";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.creatorModel1DTreeBase,
        (v) -> { User3D.creatorModel1DTreeBase = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.creatorModel1DTreeBase, s1, s2, s3, s4);
    }
    return out;
  }
  boolean TerrainLoadTextures (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Terrain Load Textures";
    if (created == 0) {
      putValueAction(command,
        () -> (Terrain.loadTextures ? 1f : 0f),
        (v) -> { Terrain.loadTextures = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.applyLandLoadTextures);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Terrain.loadTextures);
    }
    return out;
  }
  boolean TerrainLoadMesh (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Terrain Load Mesh";
    if (created == 0) {
      putValueAction(command,
        () -> (Terrain.loadMesh ? 1f : 0f),
        (v) -> { Terrain.loadMesh = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.applyLandLoadMesh);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Terrain.loadMesh);
    }
    return out;
  }
  int TerrainSkipStart (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Terrain Skip Start";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Terrain.skipStart,
        (v) -> { Terrain.skipStart = int(v); },
        () -> (float) (0), () -> (float) (Terrain.rowCount - 1), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Terrain.skipStart, 0, Terrain.rowCount - 1, 1);
    }
    return out;
  }
  int TerrainSkipEnd (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Terrain Skip End";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Terrain.skipEnd,
        (v) -> { Terrain.skipEnd = int(v); },
        () -> (float) (0), () -> (float) (Terrain.rowCount - 1), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Terrain.skipEnd, 0, Terrain.rowCount - 1, 1);
    }
    return out;
  }
  boolean TerrainDisplaySurface (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Terrain Display Surface";
    if (created == 0) {
      putValueAction(command,
        () -> (Terrain.displaySurface ? 1f : 0f),
        (v) -> { Terrain.displaySurface = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Terrain.displaySurface);
    }
    return out;
  }
  boolean TerrainDisplayTexture (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Terrain Display Texture";
    if (created == 0) {
      putValueAction(command,
        () -> (Terrain.displayTexture ? 1f : 0f),
        (v) -> { Terrain.displayTexture = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Terrain.displayTexture);
    }
    return out;
  }
  boolean TerrainDisplayPoints (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Terrain Display Points";
    if (created == 0) {
      putValueAction(command,
        () -> (Terrain.displayPoints ? 1f : 0f),
        (v) -> { Terrain.displayPoints = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Terrain.displayPoints);
    }
    return out;
  }
  boolean TerrainDisplayDepth (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Display Depth";
    if (created == 0) {
      putValueAction(command,
        () -> (Terrain.displayDepth ? 1f : 0f),
        (v) -> { Terrain.displayDepth = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Terrain.displayDepth);
    }
    return out;
  }
  boolean Model2DsDisplayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Model2Ds Display All";
    if (created == 0) {
      putValueAction(command,
        () -> (allModel2Ds.displayAll ? 1f : 0f),
        (v) -> { allModel2Ds.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allModel2Ds.displayAll);
    }
    return out;
  }
  boolean Model1DsDisplayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Model1Ds Display All";
    if (created == 0) {
      putValueAction(command,
        () -> (allModel1Ds.displayAll ? 1f : 0f),
        (v) -> { allModel1Ds.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allModel1Ds.displayAll);
    }
    return out;
  }
  boolean Model1DsDisplayLeaves (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Model1Ds Display Leaves";
    if (created == 0) {
      putValueAction(command,
        () -> (allModel1Ds.displayLeaves ? 1f : 0f),
        (v) -> { allModel1Ds.displayLeaves = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allModel1Ds.displayLeaves);
    }
    return out;
  }
  boolean PolylinesDisplayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Polylines Display All";
    if (created == 0) {
      putValueAction(command,
        () -> (allPolylines.displayAll ? 1f : 0f),
        (v) -> { allPolylines.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allPolylines.displayAll);
    }
    return out;
  }
  boolean FacesDisplayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Faces Display All";
    if (created == 0) {
      putValueAction(command,
        () -> (allFaces.displayAll ? 1f : 0f),
        (v) -> { allFaces.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allFaces.displayAll);
    }
    return out;
  }
  boolean SolidsDisplayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Solids Display All";
    if (created == 0) {
      putValueAction(command,
        () -> (allSolids.displayAll ? 1f : 0f),
        (v) -> { allSolids.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolids.displayAll);
    }
    return out;
  }
  boolean SectionsDisplayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Sections Display All";
    if (created == 0) {
      putValueAction(command,
        () -> (allSections.displayAll ? 1f : 0f),
        (v) -> { allSections.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSections.displayAll);
    }
    return out;
  }
  boolean WindRoseDisplayImage (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "WindRoses displayImage";
    if (created == 0) {
      putValueAction(command,
        () -> (allWindRoses.displayImage ? 1f : 0f),
        (v) -> { allWindRoses.displayImage = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allWindRoses.displayImage);
    }
    return out;
  }
  float WindRosePlaneSize (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 50; //start
    float s2 = 3200; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    String command = "Wind Roses Plane Size";
    if (created == 0) {
      putValueAction(command,
        () -> allWindRoses.planeSize,
        (v) -> { allWindRoses.planeSize = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allWindRoses.planeSize, s1, s2, s3, s4);
    }
    return out;
  }
  boolean Sky3DDisplaySurface (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Sky3D Display Surface";
    if (created == 0) {
      putValueAction(command,
        () -> (Sky3D.displaySurface ? 1f : 0f),
        (v) -> { Sky3D.displaySurface = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sky3D.displaySurface);
    }
    return out;
  }
  boolean Sun3DDisplayPath (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Sun3D Display Path";
    if (created == 0) {
      putValueAction(command,
        () -> (Sun3D.displayPath ? 1f : 0f),
        (v) -> { Sun3D.displayPath = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sun3D.displayPath);
    }
    return out;
  }
  boolean Sun3DDisplayPattern (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Sun3D Display Pattern";
    if (created == 0) {
      putValueAction(command,
        () -> (Sun3D.displayPattern ? 1f : 0f),
        (v) -> { Sun3D.displayPattern = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sun3D.displayPattern);
    }
    return out;
  }
  int currentCameraIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Current Camera Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) WIN3D.currentCameraIndex,
        (v) -> { WIN3D.currentCameraIndex = int(v); },
        () -> (float) (0), () -> (float) (allCameras.num), 1,
        u1, u2, u3,
        react.applyCurrentCamera);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, WIN3D.currentCameraIndex, 0, allCameras.num, 1);
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
    String command = "Camera Clip Near";
    if (created == 0) {
      putValueAction(command,
        () -> WIN3D.cameraClipNear,
        (v) -> { WIN3D.cameraClipNear = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, WIN3D.cameraClipNear, s1, s2, s3, s4);
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
    String command = "Camera Clip Far";
    if (created == 0) {
      putValueAction(command,
        () -> WIN3D.cameraClipFar,
        (v) -> { WIN3D.cameraClipFar = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, WIN3D.cameraClipFar, s1, s2, s3, s4);
    }
    return out;
  }
  boolean Create3DDisplayVertices (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Create3D Display Vertices";
    if (created == 0) {
      putValueAction(command,
        () -> (allPoints.displayAll ? 1f : 0f),
        (v) -> { allPoints.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allPoints.displayAll);
    }
    return out;
  }
  boolean Create3DDisplayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Create3D Display Edges";
    if (created == 0) {
      putValueAction(command,
        () -> (allFaces.displayEdges ? 1f : 0f),
        (v) -> { allFaces.displayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allFaces.displayEdges);
    }
    return out;
  }
  boolean Create3DDisplayNormals (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Create3D Display Normals";
    if (created == 0) {
      putValueAction(command,
        () -> (allFaces.showNormalLines ? 1f : 0f),
        (v) -> { allFaces.showNormalLines = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allFaces.showNormalLines);
    }
    return out;
  }
  boolean CamerasDisplayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Cameras Display All";
    if (created == 0) {
      putValueAction(command,
        () -> (allCameras.displayAll ? 1f : 0f),
        (v) -> { allCameras.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allCameras.displayAll);
    }
    return out;
  }
  int impactDisplayDay (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Impact Display Day";
    if (created == 0) {
      putValueAction(command,
        () -> (float) impactDisplayDay,
        (v) -> { impactDisplayDay = int(v); },
        () -> (float) (0), () -> (float) (STUDY.endDay - STUDY.startDay), 1,
        u1, u2, u3,
        react.caseBarOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, impactDisplayDay, 0, STUDY.endDay - STUDY.startDay, 1);
    }
    return out;
  }
  boolean SolarImpactsDisplayImage (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "SolarImpacts displayImage";
    if (created == 0) {
      putValueAction(command,
        () -> (allSolarImpacts.displayImage ? 1f : 0f),
        (v) -> { allSolarImpacts.displayImage = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolarImpacts.displayImage);
    }
    return out;
  }
  boolean SolidImpactsDisplayImage (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "SolidImpacts displayImage";
    if (created == 0) {
      putValueAction(command,
        () -> (allSolidImpacts.displayImage ? 1f : 0f),
        (v) -> { allSolidImpacts.displayImage = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolidImpacts.displayImage);
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
    String command = "SolarImpacts sectionType";
    if (created == 0) {
      putValueAction(command,
        () -> (float) allSolarImpacts.sectionType,
        (v) -> { allSolarImpacts.sectionType = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolarImpacts.sectionType, s1, s2, s3);
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
    String command = "SolidImpacts sectionType";
    if (created == 0) {
      putValueAction(command,
        () -> (float) allSolidImpacts.sectionType,
        (v) -> { allSolidImpacts.sectionType = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolidImpacts.sectionType, s1, s2, s3);
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
    String command = "Solid Impacts Grade";
    if (created == 0) {
      putValueAction(command,
        () -> allSolidImpacts.Grade,
        (v) -> { allSolidImpacts.Grade = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolidImpacts.Grade, s1, s2, s3, s4);
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
    String command = "Solid Impacts Power";
    if (created == 0) {
      putValueAction(command,
        () -> allSolidImpacts.Power,
        (v) -> { allSolidImpacts.Power = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolidImpacts.Power, s1, s2, s3, s4);
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
    String command = "Solid Impacts R";
    if (created == 0) {
      putValueAction(command,
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
    String command = "Solid Impacts Z";
    if (created == 0) {
      putValueAction(command,
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
    String command = "Solid Impacts Position Step";
    if (created == 0) {
      putValueAction(command,
        () -> allSolidImpacts.positionStep,
        (v) -> { allSolidImpacts.positionStep = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolidImpacts.positionStep, s1, s2, s3, s4);
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
    String command = "Solid Impacts U";
    if (created == 0) {
      putValueAction(command,
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
    String command = "Solid Impacts V";
    if (created == 0) {
      putValueAction(command,
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
    String command = "Solid Impacts X";
    if (created == 0) {
      putValueAction(command,
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
    String command = "Solid Impacts Y";
    if (created == 0) {
      putValueAction(command,
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
    String command = "Solid Impacts Wind Speed";
    if (created == 0) {
      putValueAction(command,
        () -> allSolidImpacts.WindSpeed,
        (v) -> { allSolidImpacts.WindSpeed = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolidImpacts.WindSpeed, s1, s2, s3, s4);
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
    String command = "Solid Impacts Wind Direction";
    if (created == 0) {
      putValueAction(command,
        () -> allSolidImpacts.WindDirection,
        (v) -> { allSolidImpacts.WindDirection = v; },
        s1, s2, s3,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolidImpacts.WindDirection, s1, s2, s3);
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
    String command = "Solid Impacts Process Sub Divisions";
    if (created == 0) {
      putValueAction(command,
        () -> (float) allSolidImpacts.Process_subDivisions,
        (v) -> { allSolidImpacts.Process_subDivisions = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolidImpacts.Process_subDivisions, s1, s2, s3);
    }
    return out;
  }
  boolean SolidImpactsDisplayPoints (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "SolidImpacts displayPoints";
    if (created == 0) {
      putValueAction(command,
        () -> (allSolidImpacts.displayPoints ? 1f : 0f),
        (v) -> { allSolidImpacts.displayPoints = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolidImpacts.displayPoints);
    }
    return out;
  }
  boolean SolidImpactsDisplayLines (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Solid Impacts Display Lines";
    if (created == 0) {
      putValueAction(command,
        () -> (allSolidImpacts.displayLines ? 1f : 0f),
        (v) -> { allSolidImpacts.displayLines = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolidImpacts.displayLines);
    }
    return out;
  }
  boolean WindFlowsDisplayAll (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "WindFlows Display All";
    if (created == 0) {
      putValueAction(command,
        () -> (allWindFlows.displayAll ? 1f : 0f),
        (v) -> { allWindFlows.displayAll = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allWindFlows.displayAll);
    }
    return out;
  }
  int Create3DDisplayTessellation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 4; //stop
    int s3 = 1; //step

    int out = 0;
    String command = "Create3D Display Tessellation";
    if (created == 0) {
      putValueAction(command,
        () -> (float) allFaces.displayTessellation,
        (v) -> { allFaces.displayTessellation = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allFaces.displayTessellation, s1, s2, s3);
    }
    return out;
  }
  int TerrainDisplayTessellation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 4; //stop
    int s3 = 1; //step

    int out = 0;
    String command = "Terrain displayTessellation";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Terrain.displayTessellation,
        (v) -> { Terrain.displayTessellation = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Terrain.displayTessellation, s1, s2, s3);
    }
    return out;
  }
  int Sky3DDisplayTessellation (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 4; //stop
    int s3 = 1; //step

    int out = 0;
    String command = "Sky3D displayTessellation";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Sky3D.displayTessellation,
        (v) -> { Sky3D.displayTessellation = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sky3D.displayTessellation, s1, s2, s3);
    }
    return out;
  }
  float Sky3DRadius (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1; //start
    float s2 = 4000000; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    String command = "Sky3D Radius";
    if (created == 0) {
      putValueAction(command,
        () -> Sky3D.radius,
        (v) -> { Sky3D.radius = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sky3D.radius, s1, s2, s3, s4);
    }
    return out;
  }
  boolean Tropo3DDisplaySurface (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Tropo3D Display Surface";
    if (created == 0) {
      putValueAction(command,
        () -> (Tropo3D.displaySurface ? 1f : 0f),
        (v) -> { Tropo3D.displaySurface = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Tropo3D.displaySurface);
    }
    return out;
  }
  boolean Tropo3DDisplayTexture (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Tropo3D Display Texture";
    if (created == 0) {
      putValueAction(command,
        () -> (Tropo3D.displayTexture ? 1f : 0f),
        (v) -> { Tropo3D.displayTexture = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Tropo3D.displayTexture);
    }
    return out;
  }
  boolean Earth3DDisplaySurface (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Earth3D Display Surface";
    if (created == 0) {
      putValueAction(command,
        () -> (Earth3D.displaySurface ? 1f : 0f),
        (v) -> { Earth3D.displaySurface = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Earth3D.displaySurface);
    }
    return out;
  }
  boolean Earth3DDisplayTexture (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Earth3D Display Texture";
    if (created == 0) {
      putValueAction(command,
        () -> (Earth3D.displayTexture ? 1f : 0f),
        (v) -> { Earth3D.displayTexture = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Earth3D.displayTexture);
    }
    return out;
  }
  float Earth3DLevelOfDetail (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 1.0 / 16.0; //start
    float s2 = 16.0; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    String command = "Earth3D Level Of Detail";
    if (created == 0) {
      putValueAction(command,
        () -> Earth3D.levelOfDetail,
        (v) -> { Earth3D.levelOfDetail = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Earth3D.levelOfDetail, s1, s2, s3, s4);
    }
    return out;
  }
  boolean Moon3DDisplaySurface (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Moon3D Display Surface";
    if (created == 0) {
      putValueAction(command,
        () -> (Moon3D.displaySurface ? 1f : 0f),
        (v) -> { Moon3D.displaySurface = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Moon3D.displaySurface);
    }
    return out;
  }
  boolean Moon3DDisplayTexture (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Moon3D Display Texture";
    if (created == 0) {
      putValueAction(command,
        () -> (Moon3D.displayTexture ? 1f : 0f),
        (v) -> { Moon3D.displayTexture = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Moon3D.displayTexture);
    }
    return out;
  }
  boolean Moon3DFitInSkyDome (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Moon3D Fit In Sky Dome";
    if (created == 0) {
      putValueAction(command,
        () -> (Moon3D.fitInSkyDome ? 1f : 0f),
        (v) -> { Moon3D.fitInSkyDome = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Moon3D.fitInSkyDome);
    }
    return out;
  }
  boolean Sun3DDisplaySurface (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Sun3D Display Surface";
    if (created == 0) {
      putValueAction(command,
        () -> (Sun3D.displaySurface ? 1f : 0f),
        (v) -> { Sun3D.displaySurface = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sun3D.displaySurface);
    }
    return out;
  }
  boolean Sun3DDisplayTexture (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Sun3D Display Texture";
    if (created == 0) {
      putValueAction(command,
        () -> (Sun3D.displayTexture ? 1f : 0f),
        (v) -> { Sun3D.displayTexture = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sun3D.displayTexture);
    }
    return out;
  }
  boolean Sun3DFitInSkyDome (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Sun3D Fit In Sky Dome";
    if (created == 0) {
      putValueAction(command,
        () -> (Sun3D.fitInSkyDome ? 1f : 0f),
        (v) -> { Sun3D.fitInSkyDome = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sun3D.fitInSkyDome);
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
    String command = "Celestial Magnification";
    if (created == 0) {
      putValueAction(command,
        () -> celestialMagnification,
        (v) -> { celestialMagnification = v; },
        s1, s2, Math.abs(s3),
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, celestialMagnification, s1, s2, s3);
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
    String command = "Overall Scale";
    if (created == 0) {
      putValueAction(command,
        () -> overallScale,
        (v) -> { overallScale = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, overallScale, s1, s2, s3, s4);
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
    String command = "Plot Layout Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) STUDY.plotLayoutIndex,
        (v) -> { STUDY.plotLayoutIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.impactsUpdateFlag);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.plotLayoutIndex, s1, s2, s3);
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
    String command = "Vertical Unit Scale";
    if (created == 0) {
      putValueAction(command,
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
    String command = "Show Raw Lines";
    if (created == 0) {
      putValueAction(command,
        () -> (STUDY.showRawLines ? 1f : 0f),
        (v) -> { STUDY.showRawLines = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.showRawLines);
    }
    return out;
  }
  boolean showStatisticalRanges (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Show Statistical Ranges";
    if (created == 0) {
      putValueAction(command,
        () -> (STUDY.showStatisticalRanges ? 1f : 0f),
        (v) -> { STUDY.showStatisticalRanges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.showStatisticalRanges);
    }
    return out;
  }
  boolean showStatistics (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Show Statistics";
    if (created == 0) {
      putValueAction(command,
        () -> (STUDY.showNormalLines ? 1f : 0f),
        (v) -> { STUDY.showNormalLines = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.showNormalLines);
    }
    return out;
  }
  boolean showProbabilities (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Show Probabilities";
    if (created == 0) {
      putValueAction(command,
        () -> (STUDY.showProbabilities ? 1f : 0f),
        (v) -> { STUDY.showProbabilities = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.showProbabilities);
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
    String command = "Probability Width Interval";
    if (created == 0) {
      putValueAction(command,
        () -> (float) STUDY.probabilityWidthInterval,
        (v) -> { STUDY.probabilityWidthInterval = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.probabilityWidthInterval, s1, s2, s3);
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
    String command = "Probability Height Interval";
    if (created == 0) {
      putValueAction(command,
        () -> STUDY.probabilityHeightInterval,
        (v) -> { STUDY.probabilityHeightInterval = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.probabilityHeightInterval, s1, s2, s3, s4);
    }
    return out;
  }
  int Study_activeColorscaleIndex (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Study Active Colorscale Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) STUDY.activeColorscaleIndex,
        (v) -> { STUDY.activeColorscaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.activeColorscaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Study_activeColorscaleDirection (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    String command = "Study Active Colorscale Direction";
    if (created == 0) {
      putValueAction(command,
        () -> (float) STUDY.activeColorscaleDirection,
        (v) -> { STUDY.activeColorscaleDirection = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.activeColorscaleDirection, s1, s2, s3);
    }
    return out;
  }
  float Study_activeColorscaleFactor (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    String command = "Study Active Colorscale Factor";
    if (created == 0) {
      putValueAction(command,
        () -> STUDY.activeColorscaleFactor,
        (v) -> { STUDY.activeColorscaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.activeColorscaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int Study_passiveColorscaleIndex (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Study Passive Colorscale Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) STUDY.passiveColorscaleIndex,
        (v) -> { STUDY.passiveColorscaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.passiveColorscaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Study_passiveColorscaleDirection (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    String command = "Study Passive Colorscale Direction";
    if (created == 0) {
      putValueAction(command,
        () -> (float) STUDY.passiveColorscaleDirection,
        (v) -> { STUDY.passiveColorscaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.passiveColorscaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float Study_passiveColorscaleFactor (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    String command = "Study Passive Colorscale Factor";
    if (created == 0) {
      putValueAction(command,
        () -> STUDY.passiveColorscaleFactor,
        (v) -> { STUDY.passiveColorscaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.passiveColorscaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int statisticalRangesColorscaleIndex (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Statistical Ranges Colorscale Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) STUDY.statisticalRangesColorscaleIndex,
        (v) -> { STUDY.statisticalRangesColorscaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.statisticalRangesColorscaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int statisticalRangesColorscaleDirection (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    String command = "Statistical Ranges Colorscale Direction";
    if (created == 0) {
      putValueAction(command,
        () -> (float) STUDY.statisticalRangesColorscaleDirection,
        (v) -> { STUDY.statisticalRangesColorscaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.statisticalRangesColorscaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float statisticalRangesColorscaleFactor (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    String command = "Statistical Ranges Colorscale Factor";
    if (created == 0) {
      putValueAction(command,
        () -> STUDY.statisticalRangesColorscaleFactor,
        (v) -> { STUDY.statisticalRangesColorscaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.statisticalRangesColorscaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int probabilitiesColorscaleIndex (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Probabilities Colorscale Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) STUDY.probabilitiesColorscaleIndex,
        (v) -> { STUDY.probabilitiesColorscaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.probabilitiesColorscaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int probabilitiesColorscaleDirection (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    String command = "Probabilities Colorscale Direction";
    if (created == 0) {
      putValueAction(command,
        () -> (float) STUDY.probabilitiesColorscaleDirection,
        (v) -> { STUDY.probabilitiesColorscaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.probabilitiesColorscaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float probabilitiesColorscaleFactor (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    String command = "Probabilities Colorscale Factor";
    if (created == 0) {
      putValueAction(command,
        () -> STUDY.probabilitiesColorscaleFactor,
        (v) -> { STUDY.probabilitiesColorscaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.probabilitiesColorscaleFactor, s1, s2, s3, s4);
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
    String command = "Opacity Percentage";
    if (created == 0) {
      putValueAction(command,
        () -> STUDY.opacityPercentage,
        (v) -> { STUDY.opacityPercentage = v; },
        s1, s2, Math.abs(s3),
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.opacityPercentage, s1, s2, s3);
    }
    return out;
  }
  int Faces_activeColorscaleIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Faces Active Colorscale Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) allFaces.activeColorscaleIndex,
        (v) -> { allFaces.activeColorscaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allFaces.activeColorscaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Faces_activeColorscaleDirection (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    String command = "Faces Active Colorscale Direction";
    if (created == 0) {
      putValueAction(command,
        () -> (float) allFaces.activeColorscaleDirection,
        (v) -> { allFaces.activeColorscaleDirection = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allFaces.activeColorscaleDirection, s1, s2, s3);
    }
    return out;
  }
  float Faces_activeColorscaleFactor (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    String command = "Faces Active Colorscale Factor";
    if (created == 0) {
      putValueAction(command,
        () -> allFaces.activeColorscaleFactor,
        (v) -> { allFaces.activeColorscaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allFaces.activeColorscaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int Faces_passiveColorscaleIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Faces Passive Colorscale Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) allFaces.passiveColorscaleIndex,
        (v) -> { allFaces.passiveColorscaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allFaces.passiveColorscaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Faces_passiveColorscaleDirection (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    String command = "Faces Passive Colorscale Direction";
    if (created == 0) {
      putValueAction(command,
        () -> (float) allFaces.passiveColorscaleDirection,
        (v) -> { allFaces.passiveColorscaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allFaces.passiveColorscaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float Faces_passiveColorscaleFactor (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    String command = "Faces Passive Colorscale Factor";
    if (created == 0) {
      putValueAction(command,
        () -> allFaces.passiveColorscaleFactor,
        (v) -> { allFaces.passiveColorscaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allFaces.passiveColorscaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int Sky3D_activeColorscaleIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Sky3D Active Colorscale Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Sky3D.activeColorscaleIndex,
        (v) -> { Sky3D.activeColorscaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sky3D.activeColorscaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Sky3D_activeColorscaleDirection (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    String command = "Sky3D Active Colorscale Direction";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Sky3D.activeColorscaleDirection,
        (v) -> { Sky3D.activeColorscaleDirection = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sky3D.activeColorscaleDirection, s1, s2, s3);
    }
    return out;
  }
  float Sky3D_activeColorscaleFactor (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    String command = "Sky3D Active Colorscale Factor";
    if (created == 0) {
      putValueAction(command,
        () -> Sky3D.activeColorscaleFactor,
        (v) -> { Sky3D.activeColorscaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sky3D.activeColorscaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int Sky3D_passiveColorscaleIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Sky3D Passive Colorscale Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Sky3D.passiveColorscaleIndex,
        (v) -> { Sky3D.passiveColorscaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sky3D.passiveColorscaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Sky3D_passiveColorscaleDirection (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    String command = "Sky3D Passive Colorscale Direction";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Sky3D.passiveColorscaleDirection,
        (v) -> { Sky3D.passiveColorscaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sky3D.passiveColorscaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float Sky3D_passiveColorscaleFactor (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    String command = "Sky3D Passive Colorscale Factor";
    if (created == 0) {
      putValueAction(command,
        () -> Sky3D.passiveColorscaleFactor,
        (v) -> { Sky3D.passiveColorscaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sky3D.passiveColorscaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int Sun3D_activeColorscaleIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Sun3D Active Colorscale Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Sun3D.activeColorscaleIndex,
        (v) -> { Sun3D.activeColorscaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sun3D.activeColorscaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Sun3D_activeColorscaleDirection (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 1; //step

    int out = 0;
    String command = "Sun3D Active Colorscale Direction";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Sun3D.activeColorscaleDirection,
        (v) -> { Sun3D.activeColorscaleDirection = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sun3D.activeColorscaleDirection, s1, s2, s3);
    }
    return out;
  }
  float Sun3D_activeColorscaleFactor (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    String command = "Sun3D Active Colorscale Factor";
    if (created == 0) {
      putValueAction(command,
        () -> Sun3D.activeColorscaleFactor,
        (v) -> { Sun3D.activeColorscaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sun3D.activeColorscaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int Sun3D_passiveColorscaleIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Sun3D Passive Colorscale Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Sun3D.passiveColorscaleIndex,
        (v) -> { Sun3D.passiveColorscaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sun3D.passiveColorscaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int Sun3D_passiveColorscaleDirection (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    String command = "Sun3D Passive Colorscale Direction";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Sun3D.passiveColorscaleDirection,
        (v) -> { Sun3D.passiveColorscaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sun3D.passiveColorscaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float Sun3D_passiveColorscaleFactor (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.125; //start
    float s2 = 8; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    String command = "Sun3D Passive Colorscale Factor";
    if (created == 0) {
      putValueAction(command,
        () -> Sun3D.passiveColorscaleFactor,
        (v) -> { Sun3D.passiveColorscaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Sun3D.passiveColorscaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int SolidsColorscaleIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Solids Colorscale Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) allSolids.colorScaleIndex,
        (v) -> { allSolids.colorScaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolids.colorScaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int SolidsColorscaleDirection (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    String command = "Solids Colorscale Direction";
    if (created == 0) {
      putValueAction(command,
        () -> (float) allSolids.colorScaleDirection,
        (v) -> { allSolids.colorScaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolids.colorScaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float SolidsColorscaleFactor (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.0001; //start
    float s2 = 64; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    String command = "Solids Colorscale Factor";
    if (created == 0) {
      putValueAction(command,
        () -> allSolids.colorScaleFactor,
        (v) -> { allSolids.colorScaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3,
        react.recalcImpact);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolids.colorScaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int TerrainColorscaleIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Terrain Colorscale Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Terrain.colorScaleIndex,
        (v) -> { Terrain.colorScaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Terrain.colorScaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int TerrainColorscaleDirection (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    String command = "Terrain Colorscale Direction";
    if (created == 0) {
      putValueAction(command,
        () -> (float) Terrain.colorScaleDirection,
        (v) -> { Terrain.colorScaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Terrain.colorScaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float TerrainColorscaleFactor (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.001; //start
    float s2 = 0.5; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    String command = "Terrain Colorscale Factor";
    if (created == 0) {
      putValueAction(command,
        () -> Terrain.colorScaleFactor,
        (v) -> { Terrain.colorScaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Terrain.colorScaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  int WindFlowsColorscaleIndex (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "WindFlows Colorscale Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) allWindFlows.colorScaleIndex,
        (v) -> { allWindFlows.colorScaleIndex = int(v); },
        () -> (float) (-1), () -> (float) ((colorStyleCount - 1)), 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allWindFlows.colorScaleIndex, -1, (colorStyleCount - 1), 1);
    }
    return out;
  }
  int WindFlowsColorscaleDirection (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = -2; //start
    int s2 = 2; //stop
    int s3 = 2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    String command = "WindFlows Colorscale Direction";
    if (created == 0) {
      putValueAction(command,
        () -> (float) allWindFlows.colorScaleDirection,
        (v) -> { allWindFlows.colorScaleDirection = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allWindFlows.colorScaleDirection, s1, s2, s3, s4);
    }
    return out;
  }
  float WindFlowsColorscaleFactor (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    float s1 = 0.01; //start
    float s2 = 1.0; //stop
    float s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    float s4 = 0.001; //round

    float out = 0;
    String command = "WindFlows Colorscale Factor";
    if (created == 0) {
      putValueAction(command,
        () -> allWindFlows.colorScaleFactor,
        (v) -> { allWindFlows.colorScaleFactor = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allWindFlows.colorScaleFactor, s1, s2, s3, s4);
    }
    return out;
  }
  boolean groupDisplayPivot (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Group Display Pivot";
    if (created == 0) {
      putValueAction(command,
        () -> (Select3D.groupDisplayPivot ? 1f : 0f),
        (v) -> { Select3D.groupDisplayPivot = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.groupDisplayPivot);
    }
    return out;
  }
  boolean pivotDisplayReference (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Pivot Display Reference";
    if (created == 0) {
      putValueAction(command,
        () -> (Select3D.pivotDisplayReference ? 1f : 0f),
        (v) -> { Select3D.pivotDisplayReference = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.pivotDisplayReference);
    }
    return out;
  }
  boolean groupDisplayBox (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Group Display Box";
    if (created == 0) {
      putValueAction(command,
        () -> (Select3D.groupDisplayBox ? 1f : 0f),
        (v) -> { Select3D.groupDisplayBox = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.groupDisplayBox);
    }
    return out;
  }
  boolean groupDisplayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Group Display Edges";
    if (created == 0) {
      putValueAction(command,
        () -> (Select3D.groupDisplayEdges ? 1f : 0f),
        (v) -> { Select3D.groupDisplayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.groupDisplayEdges);
    }
    return out;
  }
  boolean faceDisplayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Face Display Edges";
    if (created == 0) {
      putValueAction(command,
        () -> (Select3D.faceDisplayEdges ? 1f : 0f),
        (v) -> { Select3D.faceDisplayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.faceDisplayEdges);
    }
    return out;
  }
  boolean faceDisplayVertexSelection (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Face Display Vertex Selection";
    if (created == 0) {
      putValueAction(command,
        () -> (Select3D.faceDisplayvertexSelection ? 1f : 0f),
        (v) -> { Select3D.faceDisplayvertexSelection = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.faceDisplayvertexSelection);
    }
    return out;
  }
  boolean polylineDisplayVertexSelection (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Polyline Display Vertex Selection";
    if (created == 0) {
      putValueAction(command,
        () -> (Select3D.polylineDisplayvertexSelection ? 1f : 0f),
        (v) -> { Select3D.polylineDisplayvertexSelection = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.polylineDisplayvertexSelection);
    }
    return out;
  }
  boolean vertexDisplayMarkers (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Vertex Display Markers";
    if (created == 0) {
      putValueAction(command,
        () -> (Select3D.vertexDisplayMarkers ? 1f : 0f),
        (v) -> { Select3D.vertexDisplayMarkers = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.vertexDisplayMarkers);
    }
    return out;
  }
  boolean polylineDisplayVertices (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Polyline Display Vertices";
    if (created == 0) {
      putValueAction(command,
        () -> (Select3D.polylineDisplayVertices ? 1f : 0f),
        (v) -> { Select3D.polylineDisplayVertices = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.polylineDisplayVertices);
    }
    return out;
  }
  boolean model2DDisplayBounds (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Model2DDisplay Bounds";
    if (created == 0) {
      putValueAction(command,
        () -> (Select3D.model2DDisplayBounds ? 1f : 0f),
        (v) -> { Select3D.model2DDisplayBounds = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.model2DDisplayBounds);
    }
    return out;
  }
  boolean model1DDisplayBounds (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Model1DDisplay Bounds";
    if (created == 0) {
      putValueAction(command,
        () -> (Select3D.model1DDisplayBounds ? 1f : 0f),
        (v) -> { Select3D.model1DDisplayBounds = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.model1DDisplayBounds);
    }
    return out;
  }
  boolean solidDisplayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Solid Display Edges";
    if (created == 0) {
      putValueAction(command,
        () -> (Select3D.solidDisplayEdges ? 1f : 0f),
        (v) -> { Select3D.solidDisplayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.solidDisplayEdges);
    }
    return out;
  }
  boolean sectionDisplayEdges (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Section Display Edges";
    if (created == 0) {
      putValueAction(command,
        () -> (Select3D.sectionDisplayEdges ? 1f : 0f),
        (v) -> { Select3D.sectionDisplayEdges = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.sectionDisplayEdges);
    }
    return out;
  }
  boolean cameraDisplayFrustum (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Camera Display Frustum";
    if (created == 0) {
      putValueAction(command,
        () -> (Select3D.cameraDisplayFrustum ? 1f : 0f),
        (v) -> { Select3D.cameraDisplayFrustum = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.cameraDisplayFrustum);
    }
    return out;
  }
  boolean terrainDisplayVertices (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Terrain Display Vertices";
    if (created == 0) {
      putValueAction(command,
        () -> (Select3D.terrainDisplayVertices ? 1f : 0f),
        (v) -> { Select3D.terrainDisplayVertices = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3,
        react.viewChangedOnly);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, Select3D.terrainDisplayVertices);
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
    String command = "Interpolation Weight";
    if (created == 0) {
      putValueAction(command,
        () -> interpolationWeight,
        (v) -> { interpolationWeight = v; },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, interpolationWeight, s1, s2, s3);
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
    String command = "Climate Based Solar Forecast";
    if (created == 0) {
      putValueAction(command,
        () -> (float) climateBasedSolarForecast,
        (v) -> { climateBasedSolarForecast = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeChange);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, climateBasedSolarForecast, s1, s2, s3);
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
    String command = "Climate Based Weather Forecast";
    if (created == 0) {
      putValueAction(command,
        () -> (float) climateBasedWeatherForecast,
        (v) -> { climateBasedWeatherForecast = int(v); },
        s1, s2, s3,
        u1, u2, u3,
        react.applyTimeChange);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, climateBasedWeatherForecast, s1, s2, s3);
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
    String command = "Develop Layer Option";
    if (created == 0) {
      putValueAction(command,
        () -> (float) developLayerOption,
        (v) -> { developLayerOption = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, developLayerOption, s1, s2, s3);
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
    String command = "Develop Layer Interval";
    if (created == 0) {
      putValueAction(command,
        () -> (float) developLayerInterval,
        (v) -> { developLayerInterval = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, developLayerInterval, s1, s2, s3);
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
    String command = "Develop Layer Angle Inclination";
    if (created == 0) {
      putValueAction(command,
        () -> developLayerAngleInclination,
        (v) -> { developLayerAngleInclination = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, developLayerAngleInclination, s1, s2, s3, s4);
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
    String command = "Develop Layer Angle Orientation";
    if (created == 0) {
      putValueAction(command,
        () -> developLayerAngleOrientation,
        (v) -> { developLayerAngleOrientation = v; },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, developLayerAngleOrientation, s1, s2, s3, s4);
    }
    return out;
  }
  int currentDataSource (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int out = 0;
    String command = "Current Data Source";
    if (created == 0) {
      putValueAction(command,
        () -> (float) currentDataSource,
        (v) -> { currentDataSource = int(v); },
        () -> (float) (0), () -> (float) (MAXIMUM_dataID), 1,
        u1, u2, u3,
        react.impactsUpdateFlag);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, currentDataSource, 0, MAXIMUM_dataID, 1);
    }
    return out;
  }
  int impactLayerIndex (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 0; //start
    int s2 = 8; //stop
    int s3 = 1; //step

    int out = 0;
    String command = "Impact Layer Index";
    if (created == 0) {
      putValueAction(command,
        () -> (float) STUDY.impactLayerIndex,
        (v) -> { STUDY.impactLayerIndex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.impactLayerIndex, s1, s2, s3);
    }
    return out;
  }
  boolean rawLinesExporter (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Raw Lines Exporter";
    if (created == 0) {
      putValueAction(command,
        () -> (STUDY.rawLinesExporter ? 1f : 0f),
        (v) -> { STUDY.rawLinesExporter = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.rawLinesExporter);
    }
    return out;
  }
  boolean normalLinesExporter (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Normal Lines Exporter";
    if (created == 0) {
      putValueAction(command,
        () -> (STUDY.normalLinesExporter ? 1f : 0f),
        (v) -> { STUDY.normalLinesExporter = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.normalLinesExporter);
    }
    return out;
  }
  boolean probabilitiesExporter (int created) {
    int u1 = 1; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Probabilities Exporter";
    if (created == 0) {
      putValueAction(command,
        () -> (STUDY.probabilitiesExporter ? 1f : 0f),
        (v) -> { STUDY.probabilitiesExporter = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, STUDY.probabilitiesExporter);
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
    String command = "Exporter Scale";
    if (created == 0) {
      putValueAction(command,
        () -> User3D.exporterScale,
        (v) -> { User3D.exporterScale = v; },
        s1, s2, Math.abs(s3),
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.exporterScale, s1, s2, s3);
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
    String command = "Exporter Yaxis Up";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.exporterYaxisUp,
        (v) -> { User3D.exporterYaxisUp = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.exporterYaxisUp, s1, s2, s3);
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
    String command = "Exporter Precision Vertex";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.exporterPrecisionVertex,
        (v) -> { User3D.exporterPrecisionVertex = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.exporterPrecisionVertex, s1, s2, s3);
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
    String command = "Exporter Precision Vertex Texture";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.exporterPrecisionVertexTexture,
        (v) -> { User3D.exporterPrecisionVertexTexture = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.exporterPrecisionVertexTexture, s1, s2, s3);
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
    String command = "Exporter Maintain Polygons";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.exporterMaintainPolygons,
        (v) -> { User3D.exporterMaintainPolygons = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.exporterMaintainPolygons, s1, s2, s3);
    }
    return out;
  }
  boolean exporterMaterialLibrary (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Exporter Material Library";
    if (created == 0) {
      putValueAction(command,
        () -> (User3D.exporterMaterialLibrary ? 1f : 0f),
        (v) -> { User3D.exporterMaterialLibrary = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.exporterMaterialLibrary);
    }
    return out;
  }
  boolean exporterDoubleSided (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Exporter Double Sided";
    if (created == 0) {
      putValueAction(command,
        () -> (User3D.exporterDoubleSided ? 1f : 0f),
        (v) -> { User3D.exporterDoubleSided = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.exporterDoubleSided);
    }
    return out;
  }
  int exporterColorscaleResolution (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 32; //start
    int s2 = 2048; //stop
    int s3 = -2; //step (negative = geometric multiply/divide on +/- click)
    int s4 = 1; //round

    int out = 0;
    String command = "Exporter Colorscale Resolution";
    if (created == 0) {
      putValueAction(command,
        () -> (float) User3D.exporterColorscaleResolution,
        (v) -> { User3D.exporterColorscaleResolution = int(v); },
        s1, s2, s4,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, User3D.exporterColorscaleResolution, s1, s2, s3, s4);
    }
    return out;
  }
  boolean Record_SolidImpact_in_JPG (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Record SolidImpact in JPG";
    if (created == 0) {
      putValueAction(command,
        () -> (allSolidImpacts.record_IMG ? 1f : 0f),
        (v) -> { allSolidImpacts.record_IMG = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolidImpacts.record_IMG);
    }
    return out;
  }
  boolean Record_SolidImpact_in_PDF (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Record Solid Impact In PDF";
    if (created == 0) {
      putValueAction(command,
        () -> (allSolidImpacts.record_PDF ? 1f : 0f),
        (v) -> { allSolidImpacts.record_PDF = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolidImpacts.record_PDF);
    }
    return out;
  }
  boolean Record_Solar_Analysis_in_JPG (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 0; // updateWIN3D
    int u3 = 0; // updateWORLD

    boolean out = false;
    String command = "Record Solar Analysis in JPG";
    if (created == 0) {
      putValueAction(command,
        () -> (allSolarImpacts.record_IMG ? 1f : 0f),
        (v) -> { allSolarImpacts.record_IMG = (v >= 0.5f); },
        0, 1, 1,
        u1, u2, u3);
    } else {
      out = UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allSolarImpacts.record_IMG);
    }
    return out;
  }
  int WindRoseImageResolution (int created) {
    int u1 = 0; // updateSTUDY
    int u2 = 1; // updateWIN3D
    int u3 = 0; // updateWORLD

    int s1 = 200; //start
    int s2 = 600; //stop
    int s3 = 100; //step

    int out = 0;
    String command = "Wind Roses Image Resolution";
    if (created == 0) {
      putValueAction(command,
        () -> (float) allWindRoses.imageResolution,
        (v) -> { allWindRoses.imageResolution = int(v); },
        s1, s2, s3,
        u1, u2, u3);
    } else {
      out = int(UI_rollout.Spinner(X_control, Y_control, u1, u2, u3, command, allWindRoses.imageResolution, s1, s2, s3));
    }
    return out;
  }
}
