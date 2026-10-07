final String UnrecognizedCommand = "Unrecognized command!";

String runScriptFile (String FileName) {
  // Queued, not run synchronously - see pendingScriptLines's own comment
  // below. Called from the live command line (RUN.SCRIPT) or the "File >
  // Run Script..." dialog, both well after initialization and well
  // outside any draw() frame's own dispatch: running even just the part
  // before the file's first "=" right here, immediately, would apply
  // that section's state (camera, REC.png's filename, ...) without ever
  // giving it a draw() frame of its own to actually render and save -
  // the very next frame's dispatch of whatever follows (deferred into
  // the same queue) would overwrite it first. Queuing the whole file
  // here instead means its first section gets its own frame exactly the
  // same way every section after it already does (see runScriptLines).
  queuePendingScriptLines(loadStrings(FileName));
  return "";
}

// Lines waiting to run on a later draw() frame - fed wholesale by
// runScriptFile (below) and by parseArgs.pde's own RUN=<file> startup
// handling, and incrementally by runScriptLines itself whenever it hits
// a "=" section-divider line partway through what it was just given
// (see below). Drained once per frame by runPendingScriptLines(),
// called from draw() in solarchvision_bim.pde. Together, this is what
// makes a "=" divider act as "go to the next frame before continuing"
// consistently - the startup RUN=<file> script, a RUN.SCRIPT run from
// the live command line well after initialization, and anything queued
// recursively from within an already-running script, are all the exact
// same mechanism, not several separate ones with their own timing.
ArrayList<String> pendingScriptLines = new ArrayList<String>();

void queuePendingScriptLines (String[] lines) {
  for (String line : lines) pendingScriptLines.add(line);
}

// Called once per frame from draw(): runs whatever is currently queued,
// which may itself re-queue part of what it just ran (if it hits
// another "=") to continue on a later frame still.
void runPendingScriptLines () {
  if (pendingScriptLines.isEmpty()) return;
  String[] lines = pendingScriptLines.toArray(new String[0]);
  pendingScriptLines.clear();
  runScriptLines(lines);
}

String runScriptLines (String[] FileALL) {
  String hint = "";
  for (int f = 0; f < FileALL.length; f++) {
    String lineSTR = FileALL[f];

    // A line starting with "=" is a section divider: defer every line
    // after it to a later draw() frame, instead of running it in this
    // same call. Needed for real, not just pacing - draw_WIN3D_layers()
    // and the FRAME_record_IMG/RecordFrame() check in draw() each run
    // once per frame, so running several "switch view, then REC.png"
    // sections back to back in one call would only ever render and save
    // the *last* one (see command/test/views.svs, which relies on
    // exactly this to capture one screenshot per view).
    if (lineSTR.stripLeading().startsWith("=")) {
      if (f + 1 < FileALL.length) {
        queuePendingScriptLines(Arrays.copyOfRange(FileALL, f + 1, FileALL.length));
      }
      return hint;
    }

    boolean shouldDrawDirective = false;
    hint = _runScriptLine(lineSTR, shouldDrawDirective);
    if(hint.equals(UnrecognizedCommand)) return UnrecognizedCommand;
  }
  return hint;
}

String runScriptLine (String lineSTR) {
  boolean shouldDrawDirective = true;
  return _runScriptLine(lineSTR, shouldDrawDirective);
}

String _runScriptLine (String lineSTR, boolean shouldDrawDirective) {
  String hint = "";
  if(!lineSTR.equals("")) {

    lineSTR = lineSTR.stripLeading();

    // Skip section line
    if (lineSTR.startsWith("=")) return hint;

    // Skip comment line
    if (lineSTR.startsWith("#")) return hint;

    lineSTR = lineSTR.stripTrailing();

    if (lineSTR.equals("")) return hint;

    String name = lineSTR.toLowerCase();
    if(allActions.get(name) != null && !bypassAllActionsFor.contains(name)) {
      callAction(lineSTR);
    } else {

      displayDirective(COMMAND_HEAD + lineSTR);

      hint = ___executeScriptLine___(lineSTR);

      if(!hint.equals("")) {
        if(shouldDrawDirective) UI_consoleBar.drawDirective(hint, false);

        boolean isUnrecognizedCommand = hint.equals(UnrecognizedCommand);
        printFeedback(hint, isUnrecognizedCommand);

        // interrupt in case of error
        if(isUnrecognizedCommand) return UnrecognizedCommand;
      }
    }
  }
  return hint;
}


// The allActions dispatch this leans on first (bypassAllActionsFor,
// sanitizeScriptLine, tokenizeScriptLine, the three match tiers, and
// resolveAction that ties them together) lives in runScriptDispatch.pde.
String ___executeScriptLine___ (String lineSTR) {
  String hint = "";

  lineSTR = sanitizeScriptLine(lineSTR);
  if (lineSTR == null) return hint;

  String[] parts = tokenizeScriptLine(lineSTR);

  ActionMatch match = resolveAction(lineSTR, parts);
  if (match != null) {
    match.action.run(match.args);
    return "";
  }

  String Command_CAPITAL = parts[0].toUpperCase();
  switch (Command_CAPITAL) {

  // list the ones that we want to check faster here:
    case "RECTSELECT": return  __RECTSELECT__(parts);
    case "LEFTCLICK": return  __LEFTCLICK__(parts);
    case "RIGHTCLICK": return  __RIGHTCLICK__(parts);
    case "MAPLEFTCLICK": return  __MAPLEFTCLICK__(parts);
    case "MAPRIGHTCLICK": return  __MAPRIGHTCLICK__(parts);

  // list others below from shortest in character length to higher then by alphabet
    case "ARC": return  __ARC__(parts);
    case "BOX": return  __BOX__(parts);
    case "CLS": return  __CLS__(parts);
    case "N.E.": return  __NE__(parts);
    case "N.W.": return  __NW__(parts);
    case "NEW": return  __NEW__(parts);
    case "PAN": return  __PAN__(parts);
    case "S.E.": return  __SE__(parts);
    case "S.W.": return  __SW__(parts);
    case "TOP": return  __TOP__(parts);
    case "BACK": return  __BACK__(parts);
    case "CONE": return  __CONE__(parts);
    case "COPY": return  __COPY__(parts);
    case "EXIT": return  __EXIT__(parts);
    case "HOLD": return  __HOLD__(parts);
    case "LEFT": return  __LEFT__(parts);
    case "MESH": return  __MESH__(parts);
    case "MOVE": return  __MOVE__(parts);
    case "OPEN": return  __OPEN__(parts);
    case "PANX": return  __PANX__(parts);
    case "PANY": return  __PANY__(parts);
    case "QUIT": return  __QUIT__(parts);
    case "SAVE": return  __SAVE__(parts);
    case "ZOOM": return  __ZOOM__(parts);
    case "TREE": return  __TREE1__(parts);
    case "+DAYS": return  __$DAYS__(parts);
    case "+ZOOM": return  __$ZOOM__(parts);
    case "BOX2P": return  __BOX2P__(parts);
    case "DISTC": return  __DISTC__(parts);
    case "DISTP": return  __DISTP__(parts);
    case "DISTZ": return  __DISTZ__(parts);
    case "FETCH": return  __FETCH__(parts);
    case "FRONT": return  __FRONT__(parts);
    case "MESH2": return  __MESH2__(parts);
    case "MESH3": return  __MESH3__(parts);
    case "MESH4": return  __MESH4__(parts);
    case "MESH5": return  __MESH5__(parts);
    case "MESH6": return  __MESH6__(parts);
    case "ORBIT": return  __ORBIT__(parts);
    case "PIVOT": return  __PIVOT__(parts);
    case "RIGHT": return  __RIGHT__(parts);
    case "SCALE": return  __SCALE__(parts);
    case "SOLID": return  __SOLID__(parts);
    case "TREE1": return  __TREE1__(parts);
    case "TREE2": return  __TREE2__(parts);
    case "+HOURS": return  __$HOURS__(parts);
    case "BOTTOM": return  __BOTTOM__(parts);
    case "CAMERA": return  __CAMERA__(parts);
    case "DELETE": return  __DELETE__(parts);
    case "HOUSE1": return  __HOUSE1__(parts);
    case "HOUSE2": return  __HOUSE2__(parts);
    case "HOUSE3": return  __HOUSE3__(parts);
    case "ORBITZ": return  __ORBITZ__(parts);
    case "PERSON": return  __PERSON__(parts);
    case "ROTATE": return  __ROTATE__(parts);
    case "SELECT": return  __SELECT__(parts);
    case "SETLAT": return  __SETLAT__(parts);
    case "SETLON": return  __SETLON__(parts);
    case "SIZE3D": return  __SIZE3D__(parts);
    case "SPHERE": return  __SPHERE__(parts);
    case "TRUCKX": return  __TRUCKX__(parts);
    case "TRUCKY": return  __TRUCKY__(parts);
    case "TRUCKZ": return  __TRUCKZ__(parts);
    case "ROTATEX": return  __ROTATE__(parts);
    case "ROTATEY": return  __ROTATE__(parts);
    case "ROTATEZ": return  __ROTATE__(parts);
    case "CUSHION": return  __CUSHION__(parts);
    case "H_SHADE": return  __H_SHADE__(parts);
    case "LOOKDIR": return  __LOOKDIR__(parts);
    case "LOOKORG": return  __LOOKORG__(parts);
    case "LOOKSEL": return  __LOOKSEL__(parts);
    case "ORBITXY": return  __ORBITXY__(parts);
    case "PYRAMID": return  __PYRAMID__(parts);
    case "REC.BMP": return  __REC_BMP__(parts);
    case "REC.JPG": return  __REC_JPG__(parts);
    case "REC.PNG": return  __REC_PNG__(parts);
    case "REC.TIF": return  __REC_TIF__(parts);
    case "SAVE.AS": return  __SAVE_AS__(parts);
    case "SECTION": return  __SECTION__(parts);
    case "SIZEALL": return  __SIZEALL__(parts);
    case "SIZESKY": return  __SIZESKY__(parts);
    case "V_SHADE": return  __V_SHADE__(parts);
    case "+MAPZOOM": return  __$MAPZOOM__(parts);
    case "+PANVIEW": return  __$PANVIEW__(parts);
    case "1D>GROUP": return  __1D$GROUP__(parts);
    case "2D>GROUP": return  __2D$GROUP__(parts);
    case "CYLINDER": return  __CYLINDER__(parts);
    case "GROUP>1D": return  __GROUP$1D__(parts);
    case "GROUP>2D": return  __GROUP$2D__(parts);
    case "POLYLINE": return  __POLYLINE__(parts);
    case "+PANVIEWX": return  __$PANVIEWX__(parts);
    case "+PANVIEWY": return  __$PANVIEWY__(parts);
    case "+SCENARIO": return  __$SCENARIO__(parts);
    case "+TURNVIEW": return  __$TURNVIEW__(parts);
    case "ENLARGE3D": return  __ENLARGE3D__(parts);
    case "GETLENGTH": return  __GETLENGTH__(parts);
    case "LANDORBIT": return  __LANDORBIT__(parts);
    case "SETLATLON": return  __SETLATLON__(parts);
    case "SETLONLAT": return  __SETLONLAT__(parts);
    case "+ELEVATION": return  __$ELEVATION__(parts);
    case "+ORBITLAND": return  __$ORBITLAND__(parts);
    case "+POSITIONX": return  __$POSITIONX__(parts);
    case "+POSITIONY": return  __$POSITIONY__(parts);
    case "+ROTATIONX": return  __$ROTATIONX__(parts);
    case "+ROTATIONZ": return  __$ROTATIONZ__(parts);
    case "+TURNVIEWX": return  __$TURNVIEWX__(parts);
    case "+TURNVIEWZ": return  __$TURNVIEWZ__(parts);
    case "CAMERAROLL": return  __CAMERAROLL__(parts);
    case "EXPORT.OBJ": return  __EXPORT_OBJ__(parts);
    case "EXPORT.RAD": return  __EXPORT_RAD__(parts);
    case "EXPORT.SCR": return  __EXPORT_SCR__(parts);
    case "FACE>GROUP": return  __FACE$GROUP__(parts);
    case "GROUP>FACE": return  __GROUP$FACE__(parts);
    case "IMPORT.OBJ": return  __IMPORT_OBJ__(parts);
    case "NORMALZOOM": return  __NORMALZOOM__(parts);
    case "OCTAHEDRON": return  __OCTAHEDRON__(parts);
    case "PARAMETRIC": return  __PARAMETRIC__(parts);
    case "RUN.SCRIPT": return  __RUN_SCRIPT__(parts);
    case "SHADE.BASE": return  __SHADE_BASE__(parts);
    case "SHADE.REAL": return  __SHADE_REAL__(parts);
    case "SHADE.WIRE": return  __SHADE_WIRE__(parts);
    case "TARGETROLL": return  __TARGETROLL__(parts);
    case "+TURNTARGET": return  __$TURNTARGET__(parts);
    case "CAMERAROLLZ": return  __CAMERAROLLZ__(parts);
    case "FACE>VERTEX": return  __FACE$VERTEX__(parts);
    case "GROUP>SOLID": return  __GROUP$SOLID__(parts);
    case "ICOSAHEDRON": return  __ICOSAHEDRON__(parts);
    case "PERSPECTIVE": return  __PERSPECTIVE__(parts);
    case "POLYGONMESH": return  __POLYGONMESH__(parts);
    case "SHADE.SOLID": return  __SHADE_SOLID__(parts);
    case "SHADE.WHITE": return  __SHADE_WHITE__(parts);
    case "SOLID>GROUP": return  __SOLID$GROUP__(parts);
    case "SUPERSPHERE": return  __SUPERSPHERE__(parts);
    case "TARGETROLLZ": return  __TARGETROLLZ__(parts);
    case "VERTEX>FACE": return  __VERTEX$FACE__(parts);
    case "+TURNTARGETX": return  __$TURNTARGETX__(parts);
    case "+TURNTARGETZ": return  __$TURNTARGETZ__(parts);
    case "ALLVIEWPORTS": return  __ALLVIEWPORTS__(parts);
    case "CAMERAROLLXY": return  __CAMERAROLLXY__(parts);
    case "GROUP>VERTEX": return  __GROUP$VERTEX__(parts);
    case "ORTHOGRAPHIC": return  __ORTHOGRAPHIC__(parts);
    case "POLYGONHYPER": return  __POLYGONHYPER__(parts);
    case "SHADE.GLOBAL": return  __SHADE_GLOBAL__(parts);
    case "TARGETROLLXY": return  __TARGETROLLXY__(parts);
    case "VERTEX>GROUP": return  __VERTEX$GROUP__(parts);
    case "+SCALEOBJECTS": return  __$SCALEOBJECTS__(parts);
    case "+SCALESKYDOME": return  __$SCALESKYDOME__(parts);
    case "BEGINNEWGROUP": return  __BEGINNEWGROUP__(parts);
    case "+CAMERAROLLXYZ": return  __$CAMERAROLLXYZ__(parts);
    case "+EDITSELECTION": return  __$EDITSELECTION__(parts);
    case "+SCALEALLMODEL": return  __$SCALEALLMODEL__(parts);
    case "+TARGETROLLXYZ": return  __$TARGETROLLXYZ__(parts);
    case "GROUP>POLYLINE": return  __GROUP$POLYLINE__(parts);
    case "POLYGONEXTRUDE": return  __POLYGONEXTRUDE__(parts);
    case "POLYLINE>GROUP": return  __POLYLINE$GROUP__(parts);
    case "SHADE.VIEWPORT": return  __SHADE_VIEWPORT__(parts);
    case "+ORBITSELECTION": return  __$ORBITSELECTION__(parts);
    case "+SCALESELECTION": return  __$SCALESELECTION__(parts);
    case "POLYLINE>VERTEX": return  __POLYLINE$VERTEX__(parts);
    case "SHADE.ELEVATION": return  __SHADE_ELEVATION__(parts);
    case "SHADE.MATERIALS": return  __SHADE_MATERIALS__(parts);
    case "VERTEX>POLYLINE": return  __VERTEX$POLYLINE__(parts);
    case "+ORBITSELECTIONZ": return  __$ORBITSELECTIONZ__(parts);
    case "+ROTATESELECTION": return  __$ROTATESELECTION__(parts);
    case "PREBAKE.VIEWPORT": return  __PREBAKE_VIEWPORT__(parts);
    case "+MOVETOWARDSMOUSE": return  __$MOVETOWARDSMOUSE__(parts);
    case "+ORBITSELECTIONXY": return  __$ORBITSELECTIONXY__(parts);
    case "+MOVETOWARDSSELECTION": return  __$MOVETOWARDSSELECTION__(parts);
    case "EXPORT.OBJ.DATESERIES": return  __EXPORT_OBJ_DATESERIES__(parts);
    case "EXPORT.OBJ.TIMESERIES": return  __EXPORT_OBJ_TIMESERIES__(parts);
  }

  return UnrecognizedCommand;
}
