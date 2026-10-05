HashMap<String,String> parseParams(String[] parts) {
  HashMap<String,String> p = new HashMap<String,String>();
  for (int q = 1; q < parts.length; q++) {
    String[] kv = split(parts[q], ':');
    if (kv.length > 1) {
      p.put(kv[0].toLowerCase(), kv[1]);
    }
  }
  return p;
}

float getF(HashMap<String,String> p, String key, float def) {
  return p.containsKey(key) ? float(p.get(key)) : def;
}

int getI(HashMap<String,String> p, String key, int def) {
  return p.containsKey(key) ? int(p.get(key)) : def;
}

String __CLS__ (String[] parts) {
    String hint = "";
    UI_consoleBar.emptyCommands();
    return hint;
}

String __QUIT__ (String[] parts) {
    String hint = "";
    println();
    exit();
    return hint;
}

String __EXIT__ (String[] parts) {
    String hint = "";
    typeUserCommand = 0;
    UI_consoleBar.revise();
    return hint;
}

String __HOLD__ (String[] parts) {
    String hint = "";
    holdProject();
    return hint;
}

String __FETCH__ (String[] parts) {
    String hint = "";
    fetchProject();
    return hint;
}

String __NEW__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) _fileSelected_New(new File(parts[1]));
    else selectFile_New();
    return hint;
}

String __OPEN__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) _fileSelected_Open(new File(parts[1]));
    else selectFile_Open();
    return hint;
}

String __SAVE_AS__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) _fileSelected_SaveAs(new File(parts[1]));
    else selectFile_SaveAs();
    return hint;
}

String __SAVE__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) saveProject(parts[1]);
    else saveProject(Folder_Project + "/" + ProjectName + ".xml");
    return hint;
}

String __IMPORT_OBJ__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) _fileSelected_ImportObj(new File(parts[1]));
    else selectFile_ImportObj();
    return hint;
}

String __RUN_SCRIPT__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) _fileSelected_RunScript(new File(Folder_Import + "/" + parts[1]));
    else selectFile_RunScript();
    return hint;
}

String __EXPORT_OBJ_TIMESERIES__ (String[] parts) {
    String hint = "";
    exportObj_timeSeries();
    return hint;
}

String __EXPORT_OBJ_DATESERIES__ (String[] parts) {
    String hint = "";
    exportObj_dateSeries();
    return hint;
}

String __EXPORT_OBJ__ (String[] parts) {
    String hint = "";
    exportObj("");
    return hint;
}

String __EXPORT_RAD__ (String[] parts) {
    String hint = "";
    exportRadiance();
    return hint;
}

String __EXPORT_SCR__ (String[] parts) {
    String hint = "";
    exportAutocadScript();
    return hint;
}

String __REC_PNG__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    screenShot(".png", parts[1]);
    } else {
    screenShot(".png");
    }
    return hint;
}

String __REC_JPG__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    screenShot(".jpg", parts[1]);
    } else {
    screenShot(".jpg");
    }
    return hint;
}

String __REC_TIF__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    screenShot(".tif", parts[1]);
    } else {
    screenShot(".tif");
    }
    return hint;
}

String __REC_BMP__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    screenShot(".bmp", parts[1]);
    } else {
    screenShot(".bmp");
    }
    return hint;
}

String __MOVE__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float dx = 0;
    float dy = 0;
    float dz = 0;
    for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], ':');
        if (parameters.length > 1) {
        String low_case = parameters[0].toLowerCase();
                if (low_case.equals("dx")) dx = float(parameters[1]);
        else if (low_case.equals("dy")) dy = float(parameters[1]);
        else if (low_case.equals("dz")) dz = float(parameters[1]);
        }
        else {
            if (q == 1) dx = float(parameters[0]);
        else if (q == 2) dy = float(parameters[0]);
        else if (q == 3) dz = float(parameters[0]);
        }
    }
    Move3D.selection(dx, dy, dz);
    model_changed();
    }
    else {
    hint = "Move dx=? dy=? dz=?";
    }
    return hint;
}

// The following thirteen cases are mouseDragged.pde's own
// drag-response helpers (panBothAxes, panXAxis, etc.), routed through
// here the same way MOVE above already was - same "develop the
// public API, not the internal calls" reasoning as mouseClicked.pde's
// own UITASK.Create block. Each fires continuously with a varying
// per-call delta during a drag gesture (unlike every other command
// here, which a person would type once), so "+" prefixed throughout -
// same convention as mouseWheel.pde's own +* commands below, since
// both fire many times in quick succession from a continuous input
// gesture rather than once per keystroke/click - and also to keep
// them clearly distinct from key3D's similarly-named but differently-
// mechanised actions - e.g. "Turn View Left" calls
// WIN3D.reverseTransform_3DViewport(); +TurnView below does not,
// different code paths despite both adjusting rotationZ/rotationX.
// Single-value ones (dx only or dy only) take that value bare
// (parts[1]), the same simplification and for the same reason the
// mouseWheel.pde commands below already went through - typing
// "+PanViewX 0.5" instead of "+PanViewX dx=0.5" for a command with
// only one possible parameter.
//
// These are switch cases, not allActions/putAction entries, for a
// concrete reason found while first attempting the latter: allActions'
// own lookup only supports a zero-argument full-line match or a
// single-token first-word match (parts[0]) for a registered name
// followed by parameters (e.g. "start_day 15") - a multi-word name
// with parameters appended (e.g. "Drag Pan View dx=0.5 dy=-0.5")
// matches neither: the full line never equals the registered key once
// parameters are appended, and parts[0] alone ("drag") was never
// registered as its own key. Confirmed directly (a prior version of
// this registered under putAction silently no-opped on every call,
// caught by MouseDraggedTest.java's own state-checking assertions,
// not just a thrown exception) rather than assumed. Every other
// parameterized, key=value command in this file (House1, Box, Solid,
// Pyramid, Move above, ...) is a switch case for this same reason -
// single-token names are the only ones allActions' own lookup
// actually supports for anything beyond a bare, zero-argument action.
//
// Single-word (CamelCase) names, not space-separated, for the same
// reason: the switch itself matches only parts[0] (Command_CAPITAL),
// so a space-separated name would never reach its own case either -
// parts[0] alone would be compared against "+PANVIEW" whole, never
// matching. Checked against allActions directly (not assumed safe
// from the name alone) before being used; none collide, so no
// bypassAllActionsFor entry was needed here the way Solid/Camera/
// Section/Pyramid needed one.

String __$PANVIEW__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    float dx = getF(p, "dx", 0);
    float dy = getF(p, "dy", 0);
    WIN3D.positionX += 100 * dx * WIN3D.positionStep * overallScale;
    WIN3D.positionY += 100 * dy * WIN3D.positionStep * overallScale;
    view_changed();
    }
    else {
    hint = "+PanView dx=? dy=?";
    }
    return hint;
}

String __$PANVIEWX__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float dx = float(parts[1]);
    WIN3D.positionX += 100 * dx * WIN3D.positionStep * overallScale;
    view_changed();
    }
    else {
    hint = "+PanViewX ?";
    }
    return hint;
}

String __$PANVIEWY__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float dy = float(parts[1]);
    WIN3D.positionY += 100 * dy * WIN3D.positionStep * overallScale;
    view_changed();
    }
    else {
    hint = "+PanViewY ?";
    }
    return hint;
}

String __$TURNTARGET__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    float dx = getF(p, "dx", 0);
    float dy = getF(p, "dy", 0);
    WIN3D.rotationZ += 10 * dx * WIN3D.rotationStep;
    WIN3D.rotationX += 10 * dy * WIN3D.rotationStep;
    WIN3D.reverseTransform_3DViewport();
    view_changed();
    }
    else {
    hint = "+TurnTarget dx=? dy=?";
    }
    return hint;
}

String __$TURNTARGETZ__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float dx = float(parts[1]);
    WIN3D.rotationZ += 10 * dx * WIN3D.rotationStep;
    WIN3D.reverseTransform_3DViewport();
    view_changed();
    }
    else {
    hint = "+TurnTargetZ ?";
    }
    return hint;
}

String __$TURNTARGETX__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float dy = float(parts[1]);
    WIN3D.rotationX += 10 * dy * WIN3D.rotationStep;
    WIN3D.reverseTransform_3DViewport();
    view_changed();
    }
    else {
    hint = "+TurnTargetX ?";
    }
    return hint;
}

String __$ORBITSELECTIONXY__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float dx = float(parts[1]);
    WIN3D.rotateXY_3DViewport_around_Selection(-10 * dx * WIN3D.rotationStep);
    view_changed();
    }
    else {
    hint = "+OrbitSelectionXY ?";
    }
    return hint;
}

String __$ORBITSELECTIONZ__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float dy = float(parts[1]);
    WIN3D.rotateZ_3DViewport_around_Selection(-10 * dy * WIN3D.rotationStep);
    view_changed();
    }
    else {
    hint = "+OrbitSelectionZ ?";
    }
    return hint;
}

String __$ORBITSELECTION__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    float dx = getF(p, "dx", 0);
    float dy = getF(p, "dy", 0);
    WIN3D.rotateXY_3DViewport_around_Selection(-10 * dx * WIN3D.rotationStep);
    WIN3D.rotateZ_3DViewport_around_Selection(-10 * dy * WIN3D.rotationStep);
    view_changed();
    }
    else {
    hint = "+OrbitSelection dx=? dy=?";
    }
    return hint;
}

String __$ORBITLAND__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float dx = float(parts[1]);
    WIN3D.rotateXY_3DViewport_around_LandIntersection(10 * dx * WIN3D.rotationStep);
    view_changed();
    }
    else {
    hint = "+OrbitLand ?";
    }
    return hint;
}

String __$TURNVIEW__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    float dx = getF(p, "dx", 0);
    float dy = getF(p, "dy", 0);
    WIN3D.rotationZ -= 10 * dx * WIN3D.rotationStep;
    WIN3D.rotationX -= 10 * dy * WIN3D.rotationStep;
    view_changed();
    }
    else {
    hint = "+TurnView dx=? dy=?";
    }
    return hint;
}

String __$TURNVIEWX__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float dy = float(parts[1]);
    WIN3D.rotationX -= 10 * dy * WIN3D.rotationStep;
    view_changed();
    }
    else {
    hint = "+TurnViewX ?";
    }
    return hint;
}

String __$TURNVIEWZ__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float dx = float(parts[1]);
    WIN3D.rotationZ -= 10 * dx * WIN3D.rotationStep;
    view_changed();
    }
    else {
    hint = "+TurnViewZ ?";
    }
    return hint;
}

// mouseWheel.pde's own leaf handlers, the wheel-event counterpart of
// the thirteen DRAG* cases above - same reasoning (switch cases, not
// allActions, for the same single-token-only-lookup reason explained
// there; "+" prefixed instead of "Drag" to keep the two event
// sources distinct in the command list). One, handleMoveWheel, isn't
// here at all: it already builds the exact same delta MOVE's own
// Move3D.selection(dx,dy,dz) call expects, so it now calls MOVE
// directly instead of getting its own case - see mouseWheel.pde's own
// comment on it. Every name below checked against allActions directly
// before being used; none collide.

String __$HOURS__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float wheelValue = float(parts[1]);
    int oldStart = STUDY.startHour;
    int oldEnd = STUDY.endHour;
    if (wheelValue > 0) {
        STUDY.startHour += 1;
        STUDY.endHour += 1;
    }
    if (wheelValue < 0) {
        STUDY.startHour -= 1;
        STUDY.endHour -= 1;
    }
    if (STUDY.startHour < 0) STUDY.startHour = 23;
    if (STUDY.startHour > 23) STUDY.startHour = 0;
    if (STUDY.endHour < 0) STUDY.endHour = 23;
    if (STUDY.endHour > 23) STUDY.endHour = 0;
    if (oldStart != STUDY.startHour || oldEnd != STUDY.endHour) {
        reviseStudyAndRegenerate(true);
    }
    }
    else {
    hint = "+Hours ?";
    }
    return hint;
}

String __$DAYS__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float wheelValue = float(parts[1]);
    int oldJoinDays = STUDY.daysMergedCount;
    if (wheelValue > 0) STUDY.daysMergedCount += 2;
    if (wheelValue < 0) STUDY.daysMergedCount -= 2;
    if (STUDY.daysMergedCount > 365 / STUDY.endDay) STUDY.daysMergedCount = 365 / STUDY.endDay;
    if (STUDY.daysMergedCount < 1) STUDY.daysMergedCount = 1;
    if (oldJoinDays != STUDY.daysMergedCount) {
        reviseStudyAndRegenerate(false);
    }
    }
    else {
    hint = "+Days ?";
    }
    return hint;
}

// Dispatches by currentDataSource internally, same as the direct
// call it replaces - which of sampleYearStart/End,
// sampleMemberStart/End or sampleStationStart/End actually moves
// depends on state this command reads itself, not something a
// caller could usefully pass in as a parameter.
String __$SCENARIO__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float wheelValue = float(parts[1]);
    if (currentDataSource == dataID_climateEngineering) {
        int[] r = shiftAndClampRange(sampleYearStart, sampleYearEnd, wheelValue, climateEngineeringStart, climateEngineeringEnd);
        if (r[0] != sampleYearStart || r[1] != sampleYearEnd) {
        sampleYearStart = r[0];
        sampleYearEnd = r[1];
        reviseStudyAndRegenerate(false);
        }
    }
    if (currentDataSource == dataID_climateArchive) {
        int[] r = shiftAndClampRange(sampleYearStart, sampleYearEnd, wheelValue, climateArchiveStart, climateArchiveEnd);
        if (r[0] != sampleYearStart || r[1] != sampleYearEnd) {
        sampleYearStart = r[0];
        sampleYearEnd = r[1];
        reviseStudyAndRegenerate(false);
        }
    }
    if (currentDataSource == dataID_ensembleForecast) {
        int[] r = shiftAndClampRange(sampleMemberStart, sampleMemberEnd, wheelValue, ensembleForecastStart, ensembleForecastEnd);
        if (r[0] != sampleMemberStart || r[1] != sampleMemberEnd) {
        sampleMemberStart = r[0];
        sampleMemberEnd = r[1];
        reviseStudyAndRegenerate(false);
        }
    }
    if (currentDataSource == dataID_ensembleObservation) {
        int[] r = shiftAndClampRange(sampleStationStart, sampleStationEnd, wheelValue, ensembleObservationStart, ensembleObservationEnd);
        if (r[0] != sampleStationStart || r[1] != sampleStationEnd) {
        sampleStationStart = r[0];
        sampleStationEnd = r[1];
        reviseStudyAndRegenerate(false);
        }
    }
    }
    else {
    hint = "+Scenario ?";
    }
    return hint;
}

String __$MAPZOOM__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float wheelValue = float(parts[1]);
    int oldZoom = WORLD.zoom;
    if (wheelValue < 0) WORLD.zoom += 1;
    if (wheelValue > 0) WORLD.zoom -= 1;
    if (WORLD.zoom < 1) WORLD.zoom = 1;
    if (WORLD.zoom > 9) WORLD.zoom = 9;
    if (oldZoom != WORLD.zoom) {
        WORLD.VIEW_id = WORLD.FindGoodViewport(locationLongitude, locationLatitude);
        WORLD.revise();
    }
    }
    else {
    hint = "+MapZoom ?";
    }
    return hint;
}

String __$ROTATESELECTION__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    float wheelValue = getF(p, "v", 0);
    float x0 = getF(p, "x0", 0);
    float y0 = getF(p, "y0", 0);
    float z0 = getF(p, "z0", 0);
    float r = 5 * -wheelValue;
    int theVector = Select3D.rotationVectorIndex;
    Rotate3D.selection(x0, y0, z0, r, theVector);
    model_changed();
    }
    else {
    hint = "+RotateSelection v=? x0=? y0=? z0=?";
    }
    return hint;
}

String __$SCALESELECTION__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    float wheelValue = getF(p, "v", 0);
    float x0 = getF(p, "x0", 0);
    float y0 = getF(p, "y0", 0);
    float z0 = getF(p, "z0", 0);
    float s = pow(pow(2.0, 0.25), -wheelValue);
    float sx = s;
    float sy = s;
    float sz = s;
    int theVector = Select3D.scaleVectorIndex;
    if (theVector == 0) { sy = 1; sz = 1; }
    if (theVector == 1) { sz = 1; sx = 1; }
    if (theVector == 2) { sx = 1; sy = 1; }
    Scale3D.selection(x0, y0, z0, sx, sy, sz);
    model_changed();
    }
    else {
    hint = "+ScaleSelection v=? x0=? y0=? z0=?";
    }
    return hint;
}

String __$EDITSELECTION__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float wheelValue = float(parts[1]);
    int pEdit = int(-wheelValue);
    Edit3D.selection(pEdit);
    model_changed();
    }
    else {
    hint = "+EditSelection ?";
    }
    return hint;
}

String __$ZOOM__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float wheelValue = float(parts[1]);
    if (WIN3D.projectionTypeIndex == 1) {
        WIN3D.positionZ -= wheelValue * WIN3D.positionStep * overallScale;
    } else {
        WIN3D.zoom *= pow(2.0, wheelValue);
    }
    view_changed();
    }
    else {
    hint = "+Zoom ?";
    }
    return hint;
}

String __$ELEVATION__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float wheelValue = float(parts[1]);
    if (wheelValue > 0) WIN3D.zoom = 2 * funcs.atan_ang((1.1 / 1.0) * funcs.tan_ang(0.5 * WIN3D.zoom));
    if (wheelValue < 0) WIN3D.zoom = 2 * funcs.atan_ang((1.0 / 1.1) * funcs.tan_ang(0.5 * WIN3D.zoom));
    view_changed();
    }
    else {
    hint = "+Elevation ?";
    }
    return hint;
}

String __$SCALEOBJECTS__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float wheelValue = float(parts[1]);
    if (wheelValue > 0) overallScale /= pow(2.0, 0.25);
    if (wheelValue < 0) overallScale *= pow(2.0, 0.25);
    view_changed();
    }
    else {
    hint = "+ScaleObjects ?";
    }
    return hint;
}

String __$SCALESKYDOME__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float wheelValue = float(parts[1]);
    if (wheelValue > 0) Sky3D.radius *= pow(2.0, 0.25);
    if (wheelValue < 0) Sky3D.radius /= pow(2.0, 0.25);
    view_changed();
    }
    else {
    hint = "+ScaleSkydome ?";
    }
    return hint;
}

String __$SCALEALLMODEL__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float wheelValue = float(parts[1]);
    if (wheelValue > 0) {
        overallScale /= pow(2.0, 0.25);
        Sky3D.radius /= pow(2.0, 0.25);
    }
    if (wheelValue < 0) {
        overallScale *= pow(2.0, 0.25);
        Sky3D.radius *= pow(2.0, 0.25);
    }
    view_changed();
    }
    else {
    hint = "+ScaleAllModel ?";
    }
    return hint;
}

// Which of rotationX/rotationZ moves depends on WIN3D.targetAxisIndex,
// read internally - same as WHEELSCENARIO above, this is state the
// command reads itself rather than something a caller passes in.
String __$TARGETROLLXYZ__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float wheelValue = float(parts[1]);
    if (WIN3D.targetAxisIndex == 0) {
        WIN3D.rotationX += wheelValue * WIN3D.rotationStep;
        WIN3D.reverseTransform_3DViewport();
    }
    if (WIN3D.targetAxisIndex == 1) {
        WIN3D.rotationZ += wheelValue * WIN3D.rotationStep;
        WIN3D.reverseTransform_3DViewport();
    }
    view_changed();
    }
    else {
    hint = "+TargetRollXYZ ?";
    }
    return hint;
}

String __$CAMERAROLLXYZ__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float wheelValue = float(parts[1]);
    if (WIN3D.targetAxisIndex == 0) {
        WIN3D.rotateZ_3DViewport_around_Selection(wheelValue * WIN3D.rotationStep);
    }
    if (WIN3D.targetAxisIndex == 1) {
        WIN3D.rotateXY_3DViewport_around_Selection(wheelValue * WIN3D.rotationStep);
    }
    view_changed();
    }
    else {
    hint = "+CameraRollXYZ ?";
    }
    return hint;
}

String __$MOVETOWARDSSELECTION__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float wheelValue = float(parts[1]);
    WIN3D.move_3DViewport_towards_Selection(pow(2, 0.5 * wheelValue));
    view_changed();
    }
    else {
    hint = "+MoveTowardsSelection ?";
    }
    return hint;
}

String __$MOVETOWARDSMOUSE__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float wheelValue = float(parts[1]);
    WIN3D.move_3DViewport_towards_Mouse(pow(2, 0.5 * wheelValue));
    view_changed();
    }
    else {
    hint = "+MoveTowardsMouse ?";
    }
    return hint;
}

String __$POSITIONX__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float wheelValue = float(parts[1]);
    WIN3D.positionX += wheelValue * WIN3D.positionStep * overallScale;
    view_changed();
    }
    else {
    hint = "+PositionX ?";
    }
    return hint;
}

String __$POSITIONY__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float wheelValue = float(parts[1]);
    WIN3D.positionY += wheelValue * WIN3D.positionStep * overallScale;
    view_changed();
    }
    else {
    hint = "+PositionY ?";
    }
    return hint;
}

String __$ROTATIONX__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float wheelValue = float(parts[1]);
    WIN3D.rotationX += wheelValue * WIN3D.rotationStep;
    view_changed();
    }
    else {
    hint = "+RotationX ?";
    }
    return hint;
}

String __$ROTATIONZ__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float wheelValue = float(parts[1]);
    WIN3D.rotationZ += wheelValue * WIN3D.rotationStep;
    view_changed();
    }
    else {
    hint = "+RotationZ ?";
    }
    return hint;
}

String __ROTATE__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    int v = 2;
    String Command_CAPITAL = parts[0].toUpperCase();
    if (Command_CAPITAL.equals("ROTATEX")) v = 0;
    if (Command_CAPITAL.equals("ROTATEY")) v = 1;
    if (Command_CAPITAL.equals("ROTATEZ")) v = 2;
    float x = 0;
    float y = 0;
    float z = 0;
    float r = 0;
    for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], ':');
        if (parameters.length > 1) {
        String low_case = parameters[0].toLowerCase();
                if (low_case.equals("r")) r = float(parameters[1]);
        else if (low_case.equals("x")) x = float(parameters[1]);
        else if (low_case.equals("y")) y = float(parameters[1]);
        else if (low_case.equals("z")) z = float(parameters[1]);
        }
        else {
        if (q == 1) r = float(parameters[0]);
        }
    }
    Rotate3D.selection(x, y, z, r, v);
    model_changed();
    }
    else {
    hint = "Rotate[X|Y|Z] r=? x=? y=? z=?";
    UI_setTo_Modify_Rotate(2);
    UI_toolBar.revise();
    }
    return hint;
}

String __SCALE__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    float sx = 1;
    float sy = 1;
    float sz = 1;
    float x = 0;
    float y = 0;
    float z = 0;
    for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], ':');
        if (parameters.length > 1) {
        String low_case = parameters[0].toLowerCase();
                if (low_case.equals("s")) {sx = float(parameters[1]); sy = sx; sz = sx;}
        else if (low_case.equals("sxy")) {sx = float(parameters[1]); sy = sx;}
        else if (low_case.equals("syz")) {sy = float(parameters[1]); sz = sy;}
        else if (low_case.equals("szx")) {sz = float(parameters[1]); sx = sz;}
        else if (low_case.equals("sx")) sx = float(parameters[1]);
        else if (low_case.equals("sy")) sy = float(parameters[1]);
        else if (low_case.equals("sz")) sz = float(parameters[1]);
        else if (low_case.equals("x")) x = float(parameters[1]);
        else if (low_case.equals("y")) y = float(parameters[1]);
        else if (low_case.equals("z")) z = float(parameters[1]);
        }
        else {
        if (q == 1) {sx = float(parameters[0]); sy = sx; sz = sx;}
        }
    }
    Scale3D.selection(x, y, z, sx, sy, sz);
    model_changed();
    }
    else {
    hint = "Scale s=? sx=? sy=? sz=? x=? y=? z=?";
    }
    return hint;
}

String __DELETE__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    for (int q = 1; q < parts.length; q++) {
        String low_case = parts[q].toLowerCase();
            if (low_case.equals("all")) deleteAll();
        else if (low_case.equals("groups")) allGroups.makeEmpty(0);
        else if (low_case.equals("model2ds")) allModel2Ds.makeEmpty(0);
        else if (low_case.equals("model1ds")) allModel1Ds.makeEmpty(0);
        else if (low_case.equals("faces")) allFaces.makeEmpty(0);
        else if (low_case.equals("lines")) allPolylines.makeEmpty(0);
        else if (low_case.equals("solids")) allSolids.makeEmpty(0);
        else if (low_case.equals("sections")) allSections.makeEmpty(0);
        else if (low_case.equals("cameras")) allCameras.makeEmpty(0);
        else if (low_case.equals("vertices")) Delete3D.isolatedVertices_Selection();
        else if (low_case.equals("selection")) Delete3D.selection();
    }
    model_changed();
    }
    else {
    hint = "Delete all/selection/groups/model2ds/model1ds/vertices/faces/solids/sections/cameras";
    }
    return hint;
}

String __COPY__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int n = getI(p, "n", 1);
    float dx = getF(p, "dx", 0);
    float dy = getF(p, "dy", 0);
    float dz = getF(p, "dz", 0);
    float rx = getF(p, "rx", 0);
    float ry = getF(p, "ry", 0);
    float rz = getF(p, "rz", 0);


    for (int q = 0; q < n; q++) {
        Clone3D.selection(true);
        if ((dx != 0) || (dy != 0) || (dz != 0)) Move3D.selection(dx, dy, dz);
        if (rx != 0) Rotate3D.selection(0, 0, 0, rx, 0);
        if (ry != 0) Rotate3D.selection(0, 0, 0, ry, 1);
        if (rz != 0) Rotate3D.selection(0, 0, 0, rz, 2);
    }

    model_changed();
    }
    else {
    hint = "Copy n=? dx=? dy=? dz=? rx=? ry=? rz=?";
    }
    return hint;
}

String __SELECT__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    for (int q = 1; q < parts.length; q++) {
        String low_case = parts[q].toLowerCase();
            if (low_case.equals("groups")) switch_category(ObjectCategory.GROUP);
        else if (low_case.equals("model2ds")) switch_category(ObjectCategory.MODEL2D);
        else if (low_case.equals("model1ds")) switch_category(ObjectCategory.MODEL1D);
        else if (low_case.equals("vertices")) switch_category(ObjectCategory.VERTEX);
        else if (low_case.equals("faces")) switch_category(ObjectCategory.FACE);
        else if (low_case.equals("lines")) switch_category(ObjectCategory.POLYLINE);
        else if (low_case.equals("solids")) switch_category(ObjectCategory.SOLID);
        else if (low_case.equals("sections")) switch_category(ObjectCategory.SECTION);
        else if (low_case.equals("cameras")) switch_category(ObjectCategory.CAMERA);
        else if (low_case.equals("landpoints")) switch_category(ObjectCategory.TERRAIN);
    }

    for (int q = 1; q < parts.length; q++) {
        String low_case = parts[q].toLowerCase();
            if (low_case.equals("all")) Select3D.selectAll();
        else if (low_case.equals("invert")) Select3D.invertSelection();
        else if (low_case.equals("nothing")) Select3D.deselectAll();
        else if (low_case.equals("last")) Select3D.selectLast();
    }

    view_changed();
    }
    else {
    hint = "Select all/last/nothing/invert/groups/model2ds/model1ds/vertices/faces/solids/sections/cameras/terrainpoint";
    }
    return hint;
}

// mouseReleased.pde's own performGetLengthMeasurement() - the ray
// casting that turns the two click points into (x1,y1,z1)/(x2,y2,z2)
// world coordinates stays in mouseReleased.pde (castClickToWorld()
// is state-dependent on the current mouse button and viewport, the
// same reason mouseClicked.pde's own computeCreateParams() stays
// local rather than being recomputed inside a command). This command
// picks up from there: the straightDist/dxRot/dyRot/dzRot math and
// which of User3D.creatorLength/Width/Height actually gets written
// depends on WIN3D.toolParameterModifier, read internally the same
// way +SCENARIO/+TARGETROLLXYZ read their own dispatch state above.
String __GETLENGTH__ (String[] parts) {
    String hint = "";
    if (parts.length > 6) {
    HashMap<String,String> p = parseParams(parts);
    float x1 = getF(p, "x1", 0);
    float y1 = getF(p, "y1", 0);
    float z1 = getF(p, "z1", 0);
    float x2 = getF(p, "x2", 0);
    float y2 = getF(p, "y2", 0);
    float z2 = getF(p, "z2", 0);

    float dx = x2 - x1;
    float dy = y2 - y1;
    float dz = z2 - z1;

    float dxRot = dx * funcs.cos_ang(-WIN3D.rotationZ) - dy * funcs.sin_ang(-WIN3D.rotationZ);
    float dyRot = dx * funcs.sin_ang(-WIN3D.rotationZ) + dy * funcs.cos_ang(-WIN3D.rotationZ);
    float dzRot = dz;

    float straightDist = dist(x1, y1, z1, x2, y2, z2);

    switch (WIN3D.toolParameterModifier) {
        case 0:
        User3D.creatorLength = straightDist;
        break;
        case 1:
        User3D.creatorWidth = straightDist;
        break;
        case 2:
        User3D.creatorHeight = straightDist;
        break;
        case 3:
        User3D.creatorLength = abs(dxRot);
        User3D.creatorWidth = abs(dyRot);
        User3D.creatorHeight = abs(dzRot);
        break;
        case 4:
        User3D.creatorLength = abs(dxRot);
        User3D.creatorWidth = abs(dyRot);
        break;
    }

    UI_rollout.revise();
    }
    else {
    hint = "GetLength x1=? y1=? z1=? x2=? y2=? z2=?";
    }
    return hint;
}


// mouseReleased.pde's own performRectSelect() - the corner1x/y,
// corner2x/y it passes are already in WIN3D's local viewport
// coordinates (screen position minus the viewport's own center),
// computed from the drag rectangle; this command just takes those
// four numbers and calls Select3D.selectRect(...) with them
// unchanged. The rectangle's own on-screen outline (drawn once more
// right before this fires) stays in mouseReleased.pde: that's a
// rendering side effect, not a selection-data change, the same
// distinction RecordFrame() calls elsewhere in this codebase are
// left direct for.
String __RECTSELECT__ (String[] parts) {
    String hint = "";
    if (parts.length > 3) {
    HashMap<String,String> p = parseParams(parts);
    float x1 = getF(p, "x1", 0);
    float y1 = getF(p, "y1", 0);
    float x2 = getF(p, "x2", 0);
    float y2 = getF(p, "y2", 0);
    Select3D.selectRect(x1, y1, x2, y2);
    view_changed();
    }
    else {
    hint = "RectSelect x1=? y1=? x2=? y2=?";
    }
    return hint;
}


// Simulate a left/right click at a given point in the 3D viewport
// (x/y are viewport-local, the same Image_X/Image_Y
// mouseClicked.pde's own WIN3D.include block computes from the real
// click position) - mouseClicked.pde's handleWin3DClickAt(...) does
// everything else (ray casting, LookAtDirection, Pick/Assign, Move,
// Create). mouseButton is temporarily overridden for the duration of
// the call and restored after, since handleWin3DClickAt checks the
// real global directly in three places rather than taking it as a
// parameter - the same way a real mouse event would have already
// left it set.
String __LEFTCLICK__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    int savedButton = mouseButton;
    mouseButton = LEFT;
    handleWin3DClickAt(x, y);
    mouseButton = savedButton;
    }
    else {
    hint = "LeftClick x=? y=?";
    }
    return hint;
}

String __RIGHTCLICK__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    int savedButton = mouseButton;
    mouseButton = RIGHT;
    handleWin3DClickAt(x, y);
    mouseButton = savedButton;
    }
    else {
    hint = "RightClick x=? y=?";
    }
    return hint;
}

String __MAPLEFTCLICK__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    int savedButton = mouseButton;
    mouseButton = LEFT;
    handleWorldClickAt(x, y);
    mouseButton = savedButton;
    }
    else {
    hint = "MapLeftClick x=? y=?";
    }
    return hint;
}

String __MAPRIGHTCLICK__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    int savedButton = mouseButton;
    mouseButton = RIGHT;
    handleWorldClickAt(x, y);
    mouseButton = savedButton;
    }
    else {
    hint = "MapRightClick x=? y=?";
    }
    return hint;
}

String __PERSON__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    String t = "PEOPLE";
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    allModel2Ds.create(t, m, x, y, z, 2.5);
    view_changed();
    }
    else {
    hint = "Person m=? x=? y=? z=?";
    UI_setTo_Create_Person();
    }
    return hint;
}

String __TREE2__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    String t = "TREES";
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float h = getF(p, "h", 10.0);
    if (h != 0) {
        allModel2Ds.create(t, m, x, y, z, h);
        model_changed();
    }
    }
    else {
    hint = "Tree2 m=? x=? y=? z=? h=?";
    UI_setTo_Create_Tree();
    }
    return hint;
}

String __TREE1__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {

    int m = 0;
    int seed = -1;
    int degree = 8;
    float x = 0;
    float y = 0;
    float z = 0;
    float h = 10;
    float r = 0;
    float tilt = 60;
    float twist = 137.5;
    float ratio = 0.8;
    float base = 2.0;
    float trunk = 1.0;
    float leaf = 0.1;

    for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], ':');
        if (parameters.length > 1) {
        String low_case = parameters[0].toLowerCase();
                if (low_case.equals("m")) m = int(parameters[1]);
        else if (low_case.equals("seed")) seed = int(parameters[1]);
        else if (low_case.equals("degree")) degree = int(parameters[1]);
        else if (low_case.equals("x")) x = float(parameters[1]);
        else if (low_case.equals("y")) y = float(parameters[1]);
        else if (low_case.equals("z")) z = float(parameters[1]);
        else if (low_case.equals("h")) h = float(parameters[1]);
        else if (low_case.equals("r")) r = float(parameters[1]);
        else if (low_case.equals("tilt")) tilt = float(parameters[1]);
        else if (low_case.equals("twist")) twist = float(parameters[1]);
        else if (low_case.equals("ratio")) ratio = float(parameters[1]);
        else if (low_case.equals("base")) base = float(parameters[1]);
        else if (low_case.equals("trunk")) trunk = float(parameters[1]);
        else if (low_case.equals("leaf")) leaf = float(parameters[1]);
        }
    }
    if (h != 0) {
        allModel1Ds.create(m, seed, degree, x, y, z, h, r, tilt, twist, ratio, base, trunk, leaf);
        model_changed();
    }
    }
    else {
    hint = "Tree1 m=? seed=? degree=? x=? y=? z=? h=? r=? tilt=? twist=? ratio=? base=? trunk=? leaf=?";
    UI_setTo_Create_allModel1Ds();
    }
    return hint;
}

String __BOX2P__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", -1);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x1 = getF(p, "x1", 0);
    float y1 = getF(p, "y1", 0);
    float z1 = getF(p, "z1", 0);
    float x2 = getF(p, "x2", 0);
    float y2 = getF(p, "y2", 0);
    float z2 = getF(p, "z2", 0);
    if ((x2 - x1 != 0) && (y2 - y1 != 0) && (z2 - z1 != 0)) {
        Create3D.add_Box_Corners(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2);
        model_changed();
    }
    }
    else {
    hint = "Box2P m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=?";
    UI_setTo_Create_Box();
    }
    return hint;
}

String __BOX__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", -1);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float dx = getF(p, "dx", 6);
    float dy = getF(p, "dy", 6);
    float dz = getF(p, "dz", 6);
    float r = getF(p, "r", 0);
    if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_Box_Core(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, r);
        model_changed();
    }
    }
    else {
    hint = "Box m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?";
    UI_setTo_Create_Box();
    }
    return hint;
}

String __PYRAMID__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", -1);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float dx = getF(p, "dx", 6);
    float dy = getF(p, "dy", 6);
    float dz = getF(p, "dz", 6);
    float r = getF(p, "r", 0);
    if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_Pyramid_Core(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, r);
        model_changed();
    }
    }
    else {
    hint = "Pyramid m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?";
    UI_setTo_Create_Pyramid();
    }
    return hint;
}

String __HOUSE3__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", -1);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float dx = getF(p, "dx", 6);
    float dy = getF(p, "dy", 6);
    float dz = getF(p, "dz", 6);
    float h = getF(p, "h", 3);
    float r = getF(p, "r", 0);
    if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_House3_Core(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, h, r);
        model_changed();
    }
    }
    else {
    hint = "House3 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?";
    UI_setTo_Create_House3();
    }
    return hint;
}

String __HOUSE2__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", -1);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float dx = getF(p, "dx", 6);
    float dy = getF(p, "dy", 6);
    float dz = getF(p, "dz", 6);
    float h = getF(p, "h", 3);
    float r = getF(p, "r", 0);
    if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_House2_Core(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, h, r);
        model_changed();
    }
    }
    else {
    hint = "House2 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?";
    UI_setTo_Create_House2();
    }
    return hint;
}

String __HOUSE1__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", -1);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float dx = getF(p, "dx", 6);
    float dy = getF(p, "dy", 6);
    float dz = getF(p, "dz", 6);
    float h = getF(p, "h", 3);
    float r = getF(p, "r", 0);
    if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_House1_Core(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, h, r);
        model_changed();
    }
    }
    else {
    hint = "House1 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?";
    UI_setTo_Create_House1();
    }
    return hint;
}

String __CYLINDER__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 7);
    int deg = getI(p, "deg", 16);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    // The hint below has always documented dx/dy/dz (independent
    // widths, matching add_SuperCylinder's own rx/ry/rz - an
    // elliptical, not just circular, cross-section), but this case
    // only ever read a single uniform d and h - found while routing
    // mouseClicked.pde's own SUPERCYLINDER case (which does pass
    // independent rx/ry/rz) through this command, where a uniform-only
    // d would have silently collapsed any non-circular cylinder back
    // to circular. d/h are kept as fallback defaults for dx/dy/dz
    // rather than removed, so any existing "Cylinder d=... h=..."
    // caller keeps working unchanged.
    float d = getF(p, "d", 6);
    float h = getF(p, "h", 6);
    float dx = getF(p, "dx", d);
    float dy = getF(p, "dy", d);
    float dz = getF(p, "dz", h);
    float r = getF(p, "r", 0);
    if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_SuperCylinder(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, deg, r);
        model_changed();
    }
    }
    else {
    hint = "Cylinder m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?";
    UI_setTo_Create_Cylinder();
    }
    return hint;
}

String __CONE__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 7);
    int deg = getI(p, "deg", 16);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float d = getF(p, "d", 6);
    float h = getF(p, "h", 6);
    float dx = getF(p, "dx", d);
    float dy = getF(p, "dy", d);
    float dz = getF(p, "dz", h);
    float r = getF(p, "r", 0);
    if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_Cone(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, deg, r);
        model_changed();
    }
    }
    else {
    hint = "Cone m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?";
    UI_setTo_Create_Cone();
    }
    return hint;
}

// Never had a case here at all - found while routing
// mouseClicked.pde's own UITASK.Create Parametric branch (GROUP
// category) through the public commands, the same way House1/2/3
// just were: UI_setTo_Create_Parametric(int n) already existed
// (n is the parametric surface type index, matching
// User3D.creatorParametricTypeIndex, the same value
// add_ParametricSurface's own n parameter expects), so the
// supporting pieces were already there - just never wired into this
// switch. dx/dy/dz halved the same way as every other shape command
// here (full widths in, half-widths to Create3D.add_ParametricSurface).
String __PARAMETRIC__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 7);
    int n = getI(p, "n", 0);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float dx = getF(p, "dx", 6);
    float dy = getF(p, "dy", 6);
    float dz = getF(p, "dz", 6);
    float r = getF(p, "r", 0);
    if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_ParametricSurface(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, n, r);
        model_changed();
    }
    }
    else {
    hint = "Parametric m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? n=? r=?";
    UI_setTo_Create_Parametric(0);
    }
    return hint;
}

String __SPHERE__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 7);
    int deg = getI(p, "deg", 3);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float d = getF(p, "d", 6);
    float r = getF(p, "r", 0);
    if (d != 0) {
        Create3D.add_CrystalSphere(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, deg, 0, 90 + r); // passing with isSky:0
        model_changed();
    }
    }
    else {
    hint = "Sphere m=? tes=? lyr=? x=? y=? z=? d=? deg=? r=?";
    UI_setTo_Create_Sphere();
    }
    return hint;
}

String __SUPERSPHERE__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 7);
    int deg = getI(p, "deg", 3);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float dx = getF(p, "dx", 6);
    float dy = getF(p, "dy", 6);
    float dz = getF(p, "dz", 6);
    float px = getF(p, "px", 2);
    float py = getF(p, "py", 2);
    float pz = getF(p, "pz", 2);
    float r = getF(p, "r", 0);
    if ((dx != 0) && (dy != 0) && (dz != 0) && (px > 0) && (py > 0) && (pz > 0)) {
        Create3D.add_SuperSphere(m, tes, lyr, vsb, wgt, clz, x, y, z, px, py, pz, 0.5 * dx, 0.5 * dy, 0.5 * dz, deg, r);
        model_changed();
    }
    }
    else {
    hint = "SuperSphere m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? px=? py=? pz=? deg=? r=?";
    UI_setTo_Create_Sphere();
    }
    return hint;
}

String __CUSHION__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 7);
    int deg = getI(p, "deg", 3);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float dx = getF(p, "dx", 6);
    float dy = getF(p, "dy", 6);
    float dz = getF(p, "dz", 6);
    float r = getF(p, "r", 0);
    if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_SuperSphere(m, tes, lyr, vsb, wgt, clz, x, y, z, CubePower, CubePower, 2, 0.5 * dx, 0.5 * dy, 0.5 * dz, deg, r);
        model_changed();
    }
    }
    else {
    hint = "Cushion m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?";
    UI_setTo_Create_Cushion();
    }
    return hint;
}

String __OCTAHEDRON__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 7);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float dx = getF(p, "dx", 6);
    float dy = getF(p, "dy", 6);
    float dz = getF(p, "dz", 6);
    float r = getF(p, "r", 0);
    if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_Octahedron(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, r);
        model_changed();
    }
    }
    else {
    hint = "Octahedron m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?";
    UI_setTo_Create_Octahedron();
    }
    return hint;
}

String __ICOSAHEDRON__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 7);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float d = getF(p, "d", 6);
    float r = getF(p, "r", 0);
    if (d != 0) {
        Create3D.add_Icosahedron(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, r);
        model_changed();
    }
    }
    else {
    hint = "Icosahedron m=? tes=? lyr=? x=? y=? z=? d=? r=?";
    UI_setTo_Create_Icosahedron();
    }
    return hint;
}

String __POLYGONEXTRUDE__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 7);
    int deg = getI(p, "deg", 6);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float d = getF(p, "d", 6);
    float h = getF(p, "h", 6);
    float r = getF(p, "r", 0);
    if ((d != 0) && (h != 0)) {
        Create3D.add_PolygonExtrude(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, h, deg, r);
        model_changed();
    }
    }
    else {
    hint = "PolygonExtrude m=? tes=? lyr=? x=? y=? z=? d=? h=? deg=? r=?";
    UI_setTo_Create_Extrude();
    }
    return hint;
}

String __POLYGONHYPER__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 7);
    int deg = getI(p, "deg", 6);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float d = getF(p, "d", 6);
    float h = getF(p, "h", 6);
    float r = getF(p, "r", 0);
    if ((d != 0) && (h != 0)) {
        Create3D.add_PolygonHyper(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, h, deg, r);
        model_changed();
    }
    }
    else {
    hint = "PolygonHyper m=? tes=? lyr=? x=? y=? z=? d=? h=? deg=? r=?";
    UI_setTo_Create_Hyper();
    }
    return hint;
}

String __POLYGONMESH__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 7);
    int deg = getI(p, "deg", 6);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float d = getF(p, "d", 6);
    float r = getF(p, "r", 0);
    if (d != 0) {
        Create3D.add_PolygonMesh(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, deg, r);
        model_changed();
    }
    }
    else {
    hint = "PolygonMesh m=? tes=? lyr=? x=? y=? z=? d=? deg=? r=?";
    UI_setTo_Create_Plane();
    }
    return hint;
}

String __MESH2__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 7);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x1 = getF(p, "x1", 0);
    float y1 = getF(p, "y1", 0);
    float z1 = getF(p, "z1", 0);
    float x2 = getF(p, "x2", 0);
    float y2 = getF(p, "y2", 0);
    float z2 = getF(p, "z2", 0);
    if ((x1 == x2) || (y1 == y2) || (z1 == z2)) {
        Create3D.add_Mesh2(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2);
        model_changed();
    }
    }
    else {
    hint = "Mesh2 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=?";
    }
    return hint;
}

String __MESH3__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 7);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x1 = getF(p, "x1", 0);
    float y1 = getF(p, "y1", 0);
    float z1 = getF(p, "z1", 0);
    float x2 = getF(p, "x2", 0);
    float y2 = getF(p, "y2", 0);
    float z2 = getF(p, "z2", 0);
    float x3 = getF(p, "x3", 0);
    float y3 = getF(p, "y3", 0);
    float z3 = getF(p, "z3", 0);
    {
        Create3D.add_Mesh3(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3);
        model_changed();
    }
    }
    else {
    hint = "Mesh3 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=?";
    }
    return hint;
}

String __MESH4__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 7);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x1 = getF(p, "x1", 0);
    float y1 = getF(p, "y1", 0);
    float z1 = getF(p, "z1", 0);
    float x2 = getF(p, "x2", 0);
    float y2 = getF(p, "y2", 0);
    float z2 = getF(p, "z2", 0);
    float x3 = getF(p, "x3", 0);
    float y3 = getF(p, "y3", 0);
    float z3 = getF(p, "z3", 0);
    float x4 = getF(p, "x4", 0);
    float y4 = getF(p, "y4", 0);
    float z4 = getF(p, "z4", 0);
    {
        Create3D.add_Mesh4(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4);
        model_changed();
    }
    }
    else {
    hint = "Mesh4 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=? x4=? y4=? z4=?";
    }
    return hint;
}

String __MESH5__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 7);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x1 = getF(p, "x1", 0);
    float y1 = getF(p, "y1", 0);
    float z1 = getF(p, "z1", 0);
    float x2 = getF(p, "x2", 0);
    float y2 = getF(p, "y2", 0);
    float z2 = getF(p, "z2", 0);
    float x3 = getF(p, "x3", 0);
    float y3 = getF(p, "y3", 0);
    float z3 = getF(p, "z3", 0);
    float x4 = getF(p, "x4", 0);
    float y4 = getF(p, "y4", 0);
    float z4 = getF(p, "z4", 0);
    float x5 = getF(p, "x5", 0);
    float y5 = getF(p, "y5", 0);
    float z5 = getF(p, "z5", 0);
    {
        Create3D.add_Mesh5(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, x5, y5, z5);
        model_changed();
    }
    }
    else {
    hint = "Mesh5 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=? x4=? y4=? z4=? x5=? y5=? z5=?";
    }
    return hint;
}

String __MESH6__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 7);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x1 = getF(p, "x1", 0);
    float y1 = getF(p, "y1", 0);
    float z1 = getF(p, "z1", 0);
    float x2 = getF(p, "x2", 0);
    float y2 = getF(p, "y2", 0);
    float z2 = getF(p, "z2", 0);
    float x3 = getF(p, "x3", 0);
    float y3 = getF(p, "y3", 0);
    float z3 = getF(p, "z3", 0);
    float x4 = getF(p, "x4", 0);
    float y4 = getF(p, "y4", 0);
    float z4 = getF(p, "z4", 0);
    float x5 = getF(p, "x5", 0);
    float y5 = getF(p, "y5", 0);
    float z5 = getF(p, "z5", 0);
    float x6 = getF(p, "x6", 0);
    float y6 = getF(p, "y6", 0);
    float z6 = getF(p, "z6", 0);
    {
        Create3D.add_Mesh6(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, x5, y5, z5, x6, y6, z6);
        model_changed();
    }
    }
    else {
    hint = "Mesh6 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=? x4=? y4=? z4=? x5=? y5=? z5=? x6=? y6=? z6=?";
    }
    return hint;
}

String __MESH__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    int m = 7;
    int tes = 0;
    int lyr = 0;
    int vsb = 1;
    int wgt = 0;
    int clz = 0;
    float[][] points = new float [0][3];
    for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], ':');
        if (parameters.length > 1) {
        String low_case = parameters[0].toLowerCase();
                if (low_case.equals("m")) m = int(parameters[1]);
        else if (low_case.equals("tes")) tes = int(parameters[1]);
        else if (low_case.equals("lyr")) lyr = int(parameters[1]);
        else if (low_case.equals("vsb")) vsb = int(parameters[1]);
        else if (low_case.equals("wgt")) wgt = int(parameters[1]);
        else if (low_case.equals("clz")) clz = int(parameters[1]);
        }
        else {
        String[] xyz = split(parts[q], ",");
        if (xyz.length > 2) {
            float[][] newPoint = {{float(xyz[0]), float(xyz[1]), float(xyz[2])}};
            points = (float[][]) concat(points, newPoint);
        }
        }
    }
    if (points.length > 2) {
        Create3D.add_Mesh(m, tes, lyr, vsb, wgt, clz, points);
        view_changed();
    }
    }
    else {
    hint = "Mesh m=? tes=? lyr=? x1,y1,z1 x2,y2,z2 etc.";
    UI_setTo_Create_Face();
    }
    return hint;
}

String __H_SHADE__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 7);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float d = getF(p, "d", 0);
    float w = getF(p, "w", 0);
    float a = getF(p, "a", 0);
    float b = getF(p, "b", 0);
    if ((d != 0) && (w != 0)) {
        Create3D.add_H_shade(m, tes, lyr, vsb, wgt, clz, x, y, z, d, w, a, b);
        model_changed();
    }
    }
    else {
    hint = "H_Shade m=? tes=? lyr=? x=? y=? z=? d=? w=? a=? b=?";
    }
    return hint;
}

String __V_SHADE__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    int m = getI(p, "m", 7);
    int tes = getI(p, "tes", 0);
    int lyr = getI(p, "lyr", 0);
    int vsb = getI(p, "vsb", 1);
    int wgt = getI(p, "wgt", 0);
    int clz = getI(p, "clz", 0);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float d = getF(p, "d", 0);
    float h = getF(p, "h", 0);
    float a = getF(p, "a", 0);
    float b = getF(p, "b", 0);
    if ((d != 0) && (h != 0)) {
        Create3D.add_V_shade(m, tes, lyr, vsb, wgt, clz, x, y, z, h, d, a, b);
        model_changed();
    }
    }
    else {
    hint = "V_Shade m=? tes=? lyr=? x=? y=? z=? d=? h=? a=? b=?";
    }
    return hint;
}

String __SOLID__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    float v = getF(p, "v", 1);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float px = getF(p, "px", 2);
    float py = getF(p, "py", 2);
    float pz = getF(p, "pz", 2);
    float sx = getF(p, "sx", 1);
    float sy = getF(p, "sy", 1);
    float sz = getF(p, "sz", 1);
    float rx = getF(p, "rx", 0);
    float ry = getF(p, "ry", 0);
    float rz = getF(p, "rz", 0);
    if ((px != 0) && (py != 0) && (pz != 0) && (sx != 0) && (sy != 0) && (sz != 0) && (v != 0)) {
        allSolids.create(x, y, z, px, py, pz, sx, sy, sz, rx, ry, rz, v);
        model_changed();
    }
    }
    else {
    hint = "Solid x=? y=? z=? px=? py=? pz=? sx=? sy=? sz=? rx=? ry=? rz=? v=?";
    UI_setTo_Create_Solid();
    }
    return hint;
}

// allGroups.beginNewGroup(...) itself has no validity guard at all
// (just appends the 9 values directly - see Groups.pde), so none is
// added here either, unlike SOLID's px/py/pz/sx/sy/sz/v check just
// above - matching the direct call in mouseClicked.pde this replaces,
// which also calls it unconditionally.
String __BEGINNEWGROUP__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float sx = getF(p, "sx", 1);
    float sy = getF(p, "sy", 1);
    float sz = getF(p, "sz", 1);
    float rx = getF(p, "rx", 0);
    float ry = getF(p, "ry", 0);
    float rz = getF(p, "rz", 0);
    allGroups.beginNewGroup(x, y, z, sx, sy, sz, rx, ry, rz);
    }
    else {
    hint = "BeginNewGroup x=? y=? z=? sx=? sy=? sz=? rx=? ry=? rz=?";
    }
    return hint;
}

String __SECTION__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    float x = getF(p, "x", 0);
    float y = getF(p, "y", 0);
    float z = getF(p, "z", 0);
    float r = getF(p, "r", 0);
    float u = getF(p, "u", 20);
    float v = getF(p, "v", 20);
    int t = getI(p, "t", 1);
    int i = getI(p, "i", 200);
    int j = getI(p, "j", 200);
    if ((t > 0) && (i > 0) && (j > 0) && (u > 0) && (v > 0)) {
        allSections.create(x, y, z, r, u, v, t, i, j);
        view_changed();
    }
    }
    else {
    hint = "Section x=? y=? z=? r=? u=? v=? t=? i=? j=?";
    UI_setTo_Create_Section();
    }
    return hint;
}

String __CAMERA__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    HashMap<String,String> p = parseParams(parts);
    float px = getF(p, "px", 0);
    float py = getF(p, "py", 0);
    float pz = getF(p, "pz", 0);
    float pt = getF(p, "pt", 1);
    float rx = getF(p, "rx", 0);
    float ry = getF(p, "ry", 0);
    float rz = getF(p, "rz", 0);
    float rt = getF(p, "rt", 5);
    float a = getF(p, "a", 60);
    int t = getI(p, "t", 1);
    if (a != 0) {
        allCameras.create(px, py, pz, pt, rx, ry, rz, rt, a, t);
        view_changed();
    }
    }
    else {
    hint = "Camera px=? py=? pz=? pt=? rx=? ry=? rz=? rt=? a=? t=?";
    UI_setTo_Create_Camera();
    }
    return hint;
}

String __POLYLINE__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    int m = 7;
    int tes = 0;
    int lyr = 0;
    int vsb = 1;
    int wgt = 0;
    int clz = 0;
    float[][] points = new float [0][3];
    for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], ':');
        if (parameters.length > 1) {
        String low_case = parameters[0].toLowerCase();
                if (low_case.equals("m")) m = int(parameters[1]);
        else if (low_case.equals("tes")) tes = int(parameters[1]);
        else if (low_case.equals("lyr")) lyr = int(parameters[1]);
        else if (low_case.equals("vsb")) vsb = int(parameters[1]);
        else if (low_case.equals("wgt")) wgt = int(parameters[1]);
        else if (low_case.equals("clz")) clz = int(parameters[1]);
        }
        else {
        String[] xyz = split(parts[q], ",");
        if (xyz.length > 2) {
            float[][] newPoint = {{float(xyz[0]), float(xyz[1]), float(xyz[2])}};
            points = (float[][]) concat(points, newPoint);
        }
        }
    }
    if (points.length > 1) {
        allPolylines.add_Polyline(m, tes, lyr, vsb, wgt, clz, points);
        view_changed();
    }
    }
    else {
    hint = "Polyline m=? tes=? lyr=? xtr=? wgt=? clz=? x1,y1,z1 x2,y2,z2 etc.";
    UI_setTo_Create_Polyline();
    }
    return hint;
}

String __ARC__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    int m = 7;
    int deg = 6;
    int tes = 0;
    int lyr = 0;
    int vsb = 1;
    int wgt = 0;
    int clz = 1;
    float x = 0;
    float y = 0;
    float z = 0;
    float r = 0;
    float rot = 0;
    float ang = 360; // complete circle
    for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], ':');
        if (parameters.length > 1) {
        String low_case = parameters[0].toLowerCase();
                if (low_case.equals("m")) m = int(parameters[1]);
        else if (low_case.equals("tes")) tes = int(parameters[1]);
        else if (low_case.equals("lyr")) lyr = int(parameters[1]);
        else if (low_case.equals("vsb")) vsb = int(parameters[1]);
        else if (low_case.equals("wgt")) wgt = int(parameters[1]);
        else if (low_case.equals("clz")) clz = int(parameters[1]);
        else if (low_case.equals("x")) x = float(parameters[1]);
        else if (low_case.equals("y")) y = float(parameters[1]);
        else if (low_case.equals("z")) z = float(parameters[1]);
        else if (low_case.equals("r")) r = float(parameters[1]);
        else if (low_case.equals("rot")) rot = float(parameters[1]);
        else if (low_case.equals("ang")) ang = float(parameters[1]);
        else if (low_case.equals("deg")) deg = int(parameters[1]);
        }
    }
    if ((r != 0) && (deg > 2)) {
        allPolylines.add_Arc(m, tes, lyr, vsb, wgt, clz, x, y, z, r, deg, rot, ang);
        view_changed();
    }
    }
    else {
    hint = "Arc m=? tes=? lyr=? xtr=? wgt=? clz=? x=? y=? z=? r=? deg=? rot=? ang=?";
    UI_setTo_Create_Polyline();
    }
    return hint;
}

String __PIVOT__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    for (int q = 1; q < parts.length; q++) {
        String low_case = parts[q].toLowerCase();
            if (low_case.equals("minx")) UI_setTo_View_PivotX(-1);
        else if (low_case.equals("midx")) UI_setTo_View_PivotX(0);
        else if (low_case.equals("maxx")) UI_setTo_View_PivotX(1);
        else if (low_case.equals("miny")) UI_setTo_View_PivotY(-1);
        else if (low_case.equals("midy")) UI_setTo_View_PivotY(0);
        else if (low_case.equals("maxy")) UI_setTo_View_PivotY(1);
        else if (low_case.equals("minz")) UI_setTo_View_PivotZ(-1);
        else if (low_case.equals("midz")) UI_setTo_View_PivotZ(0);
        else if (low_case.equals("maxz")) UI_setTo_View_PivotZ(1);
    }
    view_changed();
    }
    else {
    hint = "PIVOT minX midY maxZ or other variations";
    }
    return hint;
}

String __VERTEX$GROUP__ (String[] parts) {
    String hint = "";
    Select3D.convert_Vertices_to_Groups();
    view_changed();
    return hint;
}

String __FACE$GROUP__ (String[] parts) {
    String hint = "";
    Select3D.convert_Faces_to_Groups();
    view_changed();
    return hint;
}

String __GROUP$FACE__ (String[] parts) {
    String hint = "";
    Select3D.convert_Groups_to_Faces();
    view_changed();
    return hint;
}

String __POLYLINE$GROUP__ (String[] parts) {
    String hint = "";
    Select3D.convert_Polylines_to_Groups();
    view_changed();
    return hint;
}

String __GROUP$POLYLINE__ (String[] parts) {
    String hint = "";
    Select3D.convert_Groups_to_Polylines();
    view_changed();
    return hint;
}

String __POLYLINE$VERTEX__ (String[] parts) {
    String hint = "";
    Select3D.convert_Polylines_to_Vertices();
    view_changed();
    return hint;
}

String __VERTEX$POLYLINE__ (String[] parts) {
    String hint = "";
    Select3D.convert_Vertices_to_Polylines();
    view_changed();
    return hint;
}

String __GROUP$VERTEX__ (String[] parts) {
    String hint = "";
    Select3D.convert_Groups_to_Vertices();
    view_changed();
    return hint;
}

String __FACE$VERTEX__ (String[] parts) {
    String hint = "";
    Select3D.convert_Faces_to_Vertices();
    view_changed();
    return hint;
}

String __VERTEX$FACE__ (String[] parts) {
    String hint = "";
    Select3D.convert_Vertices_to_Faces();
    view_changed();
    return hint;
}

String __SOLID$GROUP__ (String[] parts) {
    String hint = "";
    Select3D.convert_Solids_to_Groups();
    view_changed();
    return hint;
}

String __GROUP$SOLID__ (String[] parts) {
    String hint = "";
    Select3D.convert_Groups_to_Solids();
    view_changed();
    return hint;
}

String __2D$GROUP__ (String[] parts) {
    String hint = "";
    Select3D.convert_Model2Ds_to_Groups();
    view_changed();
    return hint;
}

String __GROUP$2D__ (String[] parts) {
    String hint = "";
    Select3D.convert_Groups_to_Model2Ds();
    view_changed();
    return hint;
}

String __1D$GROUP__ (String[] parts) {
    String hint = "";
    Select3D.convert_Model1Ds_to_Groups();
    view_changed();
    return hint;
}

String __GROUP$1D__ (String[] parts) {
    String hint = "";
    Select3D.convert_Groups_to_Model1Ds();
    view_changed();
    return hint;
}

String __DISTZ__ (String[] parts) {
    String hint = "";
    UI_setTo_View_Truck(0);
    return hint;
}

String __DISTC__ (String[] parts) {
    String hint = "";
    UI_setTo_View_CameraDistance(0);
    return hint;
}

String __DISTP__ (String[] parts) {
    String hint = "";
    UI_setTo_View_DistMouseXY(0);
    return hint;
}

String __SIZEALL__ (String[] parts) {
    String hint = "";
    UI_setTo_View_AllModelSize();
    return hint;
}

String __SIZESKY__ (String[] parts) {
    String hint = "";
    UI_setTo_View_SkydomeSize();
    return hint;
}

String __SIZE3D__ (String[] parts) {
    String hint = "";
    UI_setTo_View_3DModelSize();
    return hint;
}

String __ALLVIEWPORTS__ (String[] parts) {
    String hint = "";
    UI_setTo_Viewport(0);
    return hint;
}

String __ENLARGE3D__ (String[] parts) {
    String hint = "";
    UI_setTo_Viewport(1);
    return hint;
}

String __LOOKORG__ (String[] parts) {
    String hint = "";
    UI_setTo_View_LookAtOrigin(0);
    return hint;
}

String __LOOKDIR__ (String[] parts) {
    String hint = "";
    UI_setTo_View_LookAtDirection(0);
    return hint;
}

String __LOOKSEL__ (String[] parts) {
    String hint = "";
    UI_setTo_View_LookAtSelection(0);
    return hint;
}

String __TRUCKZ__ (String[] parts) {
    String hint = "";
    UI_setTo_View_Truck(0);
    return hint;
}

String __TRUCKX__ (String[] parts) {
    String hint = "";
    UI_setTo_View_Truck(1);
    return hint;
}

String __TRUCKY__ (String[] parts) {
    String hint = "";
    UI_setTo_View_Truck(2);
    return hint;
}

String __TARGETROLL__ (String[] parts) {
    String hint = "";
    UI_setTo_View_TargetRoll(0);
    return hint;
}

String __TARGETROLLZ__ (String[] parts) {
    String hint = "";
    UI_setTo_View_TargetRoll(1);
    return hint;
}

String __TARGETROLLXY__ (String[] parts) {
    String hint = "";
    UI_setTo_View_TargetRoll(2);
    return hint;
}

String __CAMERAROLL__ (String[] parts) {
    String hint = "";
    UI_setTo_View_CameraRoll(0);
    return hint;
}

String __CAMERAROLLZ__ (String[] parts) {
    String hint = "";
    UI_setTo_View_CameraRoll(1);
    return hint;
}

String __CAMERAROLLXY__ (String[] parts) {
    String hint = "";
    UI_setTo_View_CameraRoll(2);
    return hint;
}

String __ORBIT__ (String[] parts) {
    String hint = "";
    UI_setTo_View_Orbit(0);
    return hint;
}

String __ORBITZ__ (String[] parts) {
    String hint = "";
    UI_setTo_View_Orbit(1);
    return hint;
}

String __ORBITXY__ (String[] parts) {
    String hint = "";
    UI_setTo_View_Orbit(2);
    return hint;
}

String __LANDORBIT__ (String[] parts) {
    String hint = "";
    UI_setTo_View_TerrainOrbit(0);
    return hint;
}

String __PAN__ (String[] parts) {
    String hint = "";
    UI_setTo_View_Pan(0);
    return hint;
}

String __PANX__ (String[] parts) {
    String hint = "";
    UI_setTo_View_Pan(1);
    return hint;
}

String __PANY__ (String[] parts) {
    String hint = "";
    UI_setTo_View_Pan(2);
    return hint;
}

String __ZOOM__ (String[] parts) {
    String hint = "";
    UI_setTo_View_ZOOM(0);
    return hint;
}

String __NORMALZOOM__ (String[] parts) {
    String hint = "";
    UI_setTo_View_ZOOM(1);
    return hint;
}

String __ORTHOGRAPHIC__ (String[] parts) {
    String hint = "";
    UI_setTo_View_ProjectionType(0);
    return hint;
}

String __PERSPECTIVE__ (String[] parts) {
    String hint = "";
    UI_setTo_View_ProjectionType(1);
    return hint;
}

String __TOP__ (String[] parts) {
    String hint = "";
    UI_setTo_View_3DViewPoint(0);
    return hint;
}

String __FRONT__ (String[] parts) {
    String hint = "";
    UI_setTo_View_3DViewPoint(1);
    return hint;
}

String __LEFT__ (String[] parts) {
    String hint = "";
    UI_setTo_View_3DViewPoint(2);
    return hint;
}

String __BACK__ (String[] parts) {
    String hint = "";
    UI_setTo_View_3DViewPoint(3);
    return hint;
}

String __RIGHT__ (String[] parts) {
    String hint = "";
    UI_setTo_View_3DViewPoint(4);
    return hint;
}

String __BOTTOM__ (String[] parts) {
    String hint = "";
    UI_setTo_View_3DViewPoint(5);
    return hint;
}

String __SW__ (String[] parts) {
    String hint = "";
    UI_setTo_View_3DViewPoint(6);
    return hint;
}

String __SE__ (String[] parts) {
    String hint = "";
    UI_setTo_View_3DViewPoint(7);
    return hint;
}

String __NE__ (String[] parts) {
    String hint = "";
    UI_setTo_View_3DViewPoint(8);
    return hint;
}

String __NW__ (String[] parts) {
    String hint = "";
    UI_setTo_View_3DViewPoint(9);
    return hint;
}

String __SHADE_WIRE__ (String[] parts) {
    String hint = "";
    WIN3D.shadingMode = SHADE.Surface_Wire;
    allFaces.displayEdges = true; //<<<<<<<<<<<<<<<
    view_changed();
    return hint;
}

String __SHADE_BASE__ (String[] parts) {
    String hint = "";
    WIN3D.shadingMode = SHADE.Surface_Base;
    view_changed();
    return hint;
}

String __SHADE_WHITE__ (String[] parts) {
    String hint = "";
    WIN3D.shadingMode = SHADE.Surface_White;
    view_changed();
    return hint;
}

String __SHADE_MATERIALS__ (String[] parts) {
    String hint = "";
    WIN3D.shadingMode = SHADE.Surface_Materials;
    view_changed();
    return hint;
}

String __SHADE_GLOBAL__ (String[] parts) {
    String hint = "";
    WIN3D.shadingMode = SHADE.Global_Solar;
    GlobalSolar_rebuild_array = true;
    regenerate_desired_bakings();
    view_changed();
    return hint;
}

String __SHADE_REAL__ (String[] parts) {
    String hint = "";
    WIN3D.shadingMode = SHADE.Vertex_Solar;
    VertexSolar_rebuild_array = true;
    regenerate_desired_bakings();
    view_changed();
    return hint;
}

String __SHADE_SOLID__ (String[] parts) {
    String hint = "";
    WIN3D.shadingMode = SHADE.Vertex_Solid;
    view_changed();
    return hint;
}

String __SHADE_ELEVATION__ (String[] parts) {
    String hint = "";
    WIN3D.shadingMode = SHADE.Vertex_Elevation;
    view_changed();
    return hint;
}

String __SHADE_VIEWPORT__ (String[] parts) {
    String hint = "";
    ShadeViewport();
    return hint;
}

String __PREBAKE_VIEWPORT__ (String[] parts) {
    String hint = "";
    preBakeViewport();
    return hint;
}

String __SETLONLAT__ (String[] parts) {
    String hint = "";
    if (parts.length > 2) {
    STATION.setLatitude(float(parts[2]));
    STATION.setLongitude(float(parts[1]));
    update_station(0);
    }
    else {
    hint = "SetLonLat ? ?";
    }
    return hint;
}

String __SETLATLON__ (String[] parts) {
    String hint = "";
    if (parts.length > 2) {
    STATION.setLatitude(float(parts[1]));
    STATION.setLongitude(float(parts[2]));
    update_station(0);
    }
    else {
    hint = "SetLatLon ? ?";
    }
    return hint;
}

String __SETLON__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    STATION.setLongitude(float(parts[1]));
    update_station(0);
    }
    else {
    hint = "SetLon ?";
    }
    return hint;
}

String __SETLAT__ (String[] parts) {
    String hint = "";
    if (parts.length > 1) {
    STATION.setLatitude(float(parts[1]));
    update_station(0);
    }
    else {
    hint = "SetLat ?";
    }
    return hint;
}
