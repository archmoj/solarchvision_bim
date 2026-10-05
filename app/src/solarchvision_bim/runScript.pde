final String UnrecognizedCommand = "Unrecognized command!";

String runScriptFile (String FileName) {
  String[] FileALL = loadStrings(FileName);

  return runScriptLines(FileALL);
}

String runScriptLines (String[] FileALL) {
  String hint = "";
  for (int f = 0; f < FileALL.length; f++) {
    String lineSTR = FileALL[f];

    hint = runScriptLine(lineSTR);
    if(hint.equals(UnrecognizedCommand)) return UnrecognizedCommand;
  }
  return hint;
}

String runScriptLine (String lineSTR) {
  String hint = "";
  if(!lineSTR.equals("")) {

    String name = lineSTR.stripTrailing().toLowerCase();
    if(allActions.get(name) != null && !bypassAllActionsFor.contains(name)) {
      callAction(lineSTR);
    } else {

      showFullCommand(COMMAND_HEAD + lineSTR);

      hint = ___executeScriptLine___(lineSTR);

      if(!hint.equals("")) {
        boolean isUnrecognizedCommand = hint.equals(UnrecognizedCommand);
        showFeedback(hint, isUnrecognizedCommand);

        // interrupt in case of error
        if(isUnrecognizedCommand) return UnrecognizedCommand;
      }
    }
  }
  return hint;
}


// Lowercase command names that must always reach the switch-case in
// runScriptLine below, even though each also has a bare, zero-argument
// menu action of the same name (e.g. "Move" switches the active move
// tool - see UI_setTo_Modify_Move). Without this, the allActions lookup
// there would match that bare action by first token before the
// switch-case ever runs, silently ignoring any parameters typed after
// the command name - or the usage hint it would otherwise print without
// them.
HashSet<String> bypassAllActionsFor = new HashSet<String>(Arrays.asList(
  "box", "camera", "cone", "cushion",
  "cylinder", "house1", "house2", "house3",
  "icosahedron", "mesh", "move", "octahedron",
  "person", "polyline", "pyramid",
  "rotate", "rotatex", "rotatey", "rotatez",
  "scale", "section", "solid", "sphere"
));

String ___executeScriptLine___ (String lineSTR) {
  String hint = "";

  lineSTR = lineSTR.stripLeading();

  // Skip section line
  if (lineSTR.startsWith("=")) return hint;

  // Skip comment line
  if (lineSTR.startsWith("#")) return hint;

  lineSTR = lineSTR.stripTrailing();

  if (lineSTR.equals("")) return hint;

  String transformedLine = lineSTR
    .replace("\"", "")
    .replaceAll(" +", " ")  // replace multiple spaces with a single space
    .replace("=", ":")      // replace equal with colon
    .replaceAll(":+", ":"); // replace multiple colons with a single colon

  String[] parts = split(transformedLine, ' ');

  String key = lineSTR.toLowerCase();

  // A handful of switch-case commands below take real parameters (e.g.
  // MOVE dx:.. dy:.. dz:..) but also happen to share a name with a bare,
  // zero-argument menu action that just switches a tool (e.g. "Move"
  // switches the active move tool - see UI_setTo_Modify_Move). Checking
  // allActions by first token would otherwise match that bare action
  // before ever reaching the switch-case that actually reads the
  // parameters - or prints a usage hint when there are none. Skipping the
  // allActions lookup entirely for these specific names routes them to
  // the switch-case unconditionally, exactly as before allActions was
  // checked first.
  if (!bypassAllActionsFor.contains(parts[0].toLowerCase())) {
    if(!key.equals("")) {
      // Full-line match first (menu captions such as "Save As..." that may
      // contain spaces and take no arguments).
      Action action = allActions.get(key);
      String[] actionArgs = parts;

      // Otherwise fall back to a first-token match, so commands registered
      // with parameters (e.g. "start_day 15") can be reused here.
      if ((action == null) && (parts.length > 0)) {
        action = allActions.get(parts[0].toLowerCase());
      }

      // Otherwise, try the line with its last word removed - a multi-word
      // command name (e.g. "begin day", also registered under its literal
      // caption by putAction's "withSpace" fallback) can then also be typed
      // with a value appended (e.g. "begin day 15"), the trailing word
      // being that value.
      if (action == null) {
        int lastSpace = key.lastIndexOf(' ');
        if (lastSpace > 0) {
          String prefix = key.substring(0, lastSpace);
          action = allActions.get(prefix);
          if (action != null) {
            actionArgs = new String[]{prefix, parts[parts.length - 1]};
          }
        }
      }

      if (action != null) {
        action.run(actionArgs);
        return "";
      }
    }
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
