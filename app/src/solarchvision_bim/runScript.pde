final String UnrecognizedCommand = "Unrecognized command!";

String runScriptFile (String FileName) {
  String[] FileALL = loadStrings(FileName);

  return runScriptLines(FileALL);
}

String runScriptLines (String[] FileALL) {
  String hint = "";
  boolean shouldDrawDirective = false;
  for (int f = 0; f < FileALL.length; f++) {
    String lineSTR = FileALL[f];

    hint = _runScriptLine(lineSTR, false);
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


// Lowercase command names that must always reach the switch-case in
// runScriptLine below, even though each also has a bare, zero-argument
// menu action of the same name (e.g. "Move" switches the active move
// tool - see UI_setTo_Modify_Move). Without this, the allActions lookup
// there would match that bare action - by a full-line match on the bare
// name alone, or by first token when real parameters follow it - before
// the switch-case ever runs, silently ignoring those parameters, or
// printing that bare action's own hint instead of the switch-case
// command's. Checked below against each of allActions' three match
// attempts individually, against the exact key *that* attempt would
// look up (the full line, the first token, or the line with its last
// word removed) - not merely against the line's first word - so a
// different, longer command that only *starts* with one of these names
// (e.g. "Scale Vector Index", starting with "scale") is unaffected and
// still dispatches normally.
HashSet<String> bypassAllActionsFor = new HashSet<String>(Arrays.asList(
  "box", "camera", "cone", "cushion",
  "cylinder", "house1", "house2", "house3",
  "icosahedron", "mesh", "move", "octahedron",
  "person", "polyline", "pyramid",
  "rotate", "rotatex", "rotatey", "rotatez",
  "scale", "section", "solid", "sphere"
));

// One resolved allActions match: which key resolved it, the Action
// itself (so a caller/test never needs a second allActions.get(key)
// lookup), and the args to invoke it with - not always the full typed
// line, see matchTrailingWordRemoved below.
class ActionMatch {
  String key;
  Action action;
  String[] args;
  ActionMatch (String key, Action action, String[] args) {
    this.key = key;
    this.action = action;
    this.args = args;
  }
}

// Strips a script line down to something ___executeScriptLine___ can
// use, or signals it should be skipped entirely - blank, a "=" section
// marker, or a "#" comment line (each ignored the same way by
// _runScriptLine's own, separate copy of this same check, upstream of
// here). Returns null for skip.
String sanitizeScriptLine (String lineSTR) {
  lineSTR = lineSTR.stripLeading();
  if (lineSTR.startsWith("=")) return null;
  if (lineSTR.startsWith("#")) return null;
  lineSTR = lineSTR.stripTrailing();
  if (lineSTR.equals("")) return null;
  return lineSTR;
}

// Splits a sanitized line into the space-separated tokens the
// switch-case below (and allActions' first-token/trailing-word matches)
// both key off: drops quotes, collapses repeated spaces, turns "="
// into ":" and collapses repeated colons (so a command's key:value
// pairs tolerate either separator plus any extra whitespace), then
// splits on spaces.
String[] tokenizeScriptLine (String lineSTR) {
  String transformedLine = lineSTR
    .replace("\"", "")
    .replaceAll(" +", " ")  // replace multiple spaces with a single space
    .replace("=", ":")      // replace equal with colon
    .replaceAll(":+", ":"); // replace multiple colons with a single colon

  return split(transformedLine, ' ');
}

// Tier 1: full-line match - menu captions such as "Save As..." that may
// contain spaces and take no arguments. Skipped when the full line is
// exactly one of bypassAllActionsFor's bare, switch-case-reserved names
// (see that set's own comment): that bare caption also has its own,
// same-named menu action registered, and the switch-case's own no-args
// branch must win over it (e.g. runScriptLine("Scale") needs to reach
// SCALE's hint branch, not UI_setTo_Modify_Scale(3)).
ActionMatch matchFullLine (String key, String[] parts) {
  if (key.equals("") || bypassAllActionsFor.contains(key)) return null;
  Action action = allActions.get(key);
  if (action == null) return null;
  return new ActionMatch(key, action, parts);
}

// Tier 2: the line with its last word removed - a multi-word command
// name (e.g. "days merged count", also registered under its literal
// caption by putAction's "withSpace" fallback) can then also be typed
// with a value appended (e.g. "days merged count 15"), the trailing
// word being that value. Tried before matchFirstToken below on purpose:
// this prefix is always at least as long as (and, whenever the line has
// more than two words, strictly longer than) the bare first token
// alone, so it's the more specific of the two whenever both would match
// - e.g. "Day Increment 2.5" must resolve to "day increment" (this
// match), not fall - as it would if matchFirstToken ran first - to
// "day" (TIME.day, a completely different, separately-registered
// command that first token also happens to name on its own), which
// would then try and fail to parse "Increment" as Day's numeric value
// instead. Same bypass exception as matchFullLine: a two-word line like
// "Scale 2" (SCALE's own shorthand uniform-factor form) strips down to
// the bare "scale" here too.
ActionMatch matchTrailingWordRemoved (String key, String[] parts) {
  int lastSpace = key.lastIndexOf(' ');
  if (lastSpace <= 0) return null;
  String prefix = key.substring(0, lastSpace);
  if (bypassAllActionsFor.contains(prefix)) return null;
  Action action = allActions.get(prefix);
  if (action == null) return null;
  return new ActionMatch(prefix, action, new String[]{prefix, parts[parts.length - 1]});
}

// Tier 3: a first-token match, so commands registered with parameters
// (e.g. "start_day 15") can be reused here - same bypass exception as
// the other two tiers, now checked against just the first token (e.g.
// "Move dx:1 dy:2 dz:3" must still reach MOVE's switch-case, not the
// bare "Move" menu action a first-token-only match would otherwise
// find). The least specific of the three tiers, and tried last: see
// matchTrailingWordRemoved's own comment for why.
ActionMatch matchFirstToken (String[] parts) {
  if (parts.length == 0) return null;
  String firstToken = parts[0].toLowerCase();
  if (bypassAllActionsFor.contains(firstToken)) return null;
  Action action = allActions.get(firstToken);
  if (action == null) return null;
  return new ActionMatch(firstToken, action, parts);
}

// Tries all three allActions match tiers above, in order, returning the
// first (most specific) hit, or null if none match - the single place
// that order is decided, so a collision scenario (two separately-
// registered commands where one's full name is a prefix of the
// other's, as "Day"/"Day Increment" and "Pivot"/"Pivot Alignment X"
// both were) can be tested directly against it, with a throwaway
// allActions map, instead of only via the real app's full command set.
ActionMatch resolveAction (String lineSTR, String[] parts) {
  String key = lineSTR.toLowerCase();
  ActionMatch match = matchFullLine(key, parts);
  if (match == null) match = matchTrailingWordRemoved(key, parts);
  if (match == null) match = matchFirstToken(parts);
  return match;
}

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
