final String UnrecognizedCommand = "Unrecognized command!";

void runScriptFile (String FileName) {
  String[] FileALL = loadStrings(FileName);

  runScriptLines(FileALL);
}

void runScriptLines (String[] FileALL) {
  for (int f = 0; f < FileALL.length; f++) {
    String lineSTR = FileALL[f];

    if(!lineSTR.equals("")) {
      println("cmd:", lineSTR);

      String hint = runScriptLine(lineSTR);

      if(!hint.equals("")) {
        println("out:", hint);
      }
    }
  }
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
  "move",
  "box", "sphere", "cylinder", "person", "house1", "house2", "house3",
  "octahedron", "icosahedron", "cushion",
  "rotate", "rotatex", "rotatey", "rotatez",
  "scale"
));

String runScriptLine (String lineSTR) {
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
    .replace(",", " ")      // replace commas with spaces
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
    case "CLS": {
      allCommands = new String[1];
      allMessages = new String[1];

      allCommands[0] = "";
      allMessages[0] = "";
      return hint;
    }

    case "QUIT":
    case "EXIT": {
      exit();
      return hint;
    }

    case "HOLD": {
      holdProject();
      return hint;
    }

    case "FETCH": {
      fetchProject();
      return hint;
    }

    case "NEW": {
      if (parts.length > 1) _fileSelected_New(new File(parts[1]));
      else selectFile_New();
      return hint;
    }

    case "OPEN": {
      if (parts.length > 1) _fileSelected_Open(new File(parts[1]));
      else selectFile_Open();
      return hint;
    }

    case "SAVE.AS": {
      if (parts.length > 1) _fileSelected_SaveAs(new File(parts[1]));
      else selectFile_SaveAs();
      return hint;
    }

    case "SAVE": {
      if (parts.length > 1) saveProject(parts[1]);
      else saveProject(Folder_Project + "/" + ProjectName + ".xml");
      return hint;
    }

    case "IMPORT.OBJ": {
      if (parts.length > 1) _fileSelected_ImportObj(new File(parts[1]));
      else selectFile_ImportObj();
      return hint;
    }

    case "RUN.SCRIPT": {
      if (parts.length > 1) _fileSelected_RunScript(new File(Folder_Command + "/" + parts[1]));
      else selectFile_RunScript();
      return hint;
    }

    case "EXPORT.OBJ.TIMESERIES": {
      exportObj_timeSeries();
      return hint;
    }

    case "EXPORT.OBJ.DATESERIES": {
      exportObj_dateSeries();
      return hint;
    }

    case "EXPORT.OBJ": {
      exportObj("");
      return hint;
    }

    case "EXPORT.RAD": {
      exportRadiance();
      return hint;
    }

    case "EXPORT.SCR": {
      exportAutocadScript();
      return hint;
    }

    case "REC.PNG": {
      if (parts.length > 1) {
        screenShot(".png", parts[1]);
      } else {
        screenShot(".png");
      }
      return hint;
    }

    case "REC.JPG": {
      if (parts.length > 1) {
        screenShot(".jpg", parts[1]);
      } else {
        screenShot(".jpg");
      }
      return hint;
    }

    case "REC.TIF": {
      if (parts.length > 1) {
        screenShot(".tif", parts[1]);
      } else {
        screenShot(".tif");
      }
      return hint;
    }

    case "REC.BMP": {
      if (parts.length > 1) {
        screenShot(".bmp", parts[1]);
      } else {
        screenShot(".bmp");
      }
      return hint;
    }

    case "MOVE": {
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
        view_changed();
      }
      else {
        hint = "Move dx=? dy=? dz=?";
      }
      return hint;
    }

    case "ROTATE":
    case "ROTATEX":
    case "ROTATEY":
    case "ROTATEZ": {
      if (parts.length > 1) {
        int v = 2;
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
        view_changed();
      }
      else {
        hint = "Rotate[X|Y|Z] r=? x=? y=? z=?";
        UI_setTo_Modify_Rotate(2);
        UI_toolBar.revise();
      }
      return hint;
    }

    case "SCALE": {
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
        view_changed();
      }
      else {
        hint = "Scale s=? sx=? sy=? sz=? x=? y=? z=?";
      }
      return hint;
    }

    case "DELETE": {
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
        view_changed();
      }
      else {
        hint = "Delete all/selection/groups/model2ds/model1ds/vertices/faces/solids/sections/cameras";
      }
      return hint;
    }

    case "COPY": {
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

        view_changed();
      }
      else {
        hint = "Copy n=? dx=? dy=? dz=? rx=? ry=? rz=?";
      }
      return hint;
    }

    case "SELECT": {
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
          else if (low_case.equals("landpoints")) switch_category(ObjectCategory.LANDPOINT);
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
        hint = "Select all/last/nothing/invert/groups/model2ds/model1ds/vertices/faces/solids/sections/cameras/landpoint";
      }
      return hint;
    }

    case "PERSON": {
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

    case "TREE2": {
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
          view_changed();
        }
      }
      else {
        hint = "Tree2 m=? x=? y=? z=? h=?";
        UI_setTo_Create_Tree();
      }
      return hint;
    }

    case "TREE1": {
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
          view_changed();
        }
      }
      else {
        hint = "Tree1 m=? seed=? degree=? x=? y=? z=? h=? r=? tilt=? twist=? ratio=? base=? trunk=? leaf=?";
        UI_setTo_Create_allModel1Ds();
      }
      return hint;
    }

    case "BOX2P": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", -1);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
        float x1 = getF(p, "x1", 0);
        float y1 = getF(p, "y1", 0);
        float z1 = getF(p, "z1", 0);
        float x2 = getF(p, "x2", 0);
        float y2 = getF(p, "y2", 0);
        float z2 = getF(p, "z2", 0);
        if ((x2 - x1 != 0) && (y2 - y1 != 0) && (z2 - z1 != 0)) {
          Create3D.add_Box_Corners(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2);
          view_changed();
        }
      }
      else {
        hint = "Box2P m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=?";
        UI_setTo_Create_Box();
      }
      return hint;
    }

    case "BOX": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", -1);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
        float x = getF(p, "x", 0);
        float y = getF(p, "y", 0);
        float z = getF(p, "z", 0);
        float dx = getF(p, "dx", 6);
        float dy = getF(p, "dy", 6);
        float dz = getF(p, "dz", 6);
        float r = getF(p, "r", 0);
        if ((dx != 0) && (dy != 0) && (dz != 0)) {
          Create3D.add_Box_Core(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, r);
          view_changed();
        }
      }
      else {
        hint = "Box m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?";
        UI_setTo_Create_Box();
      }
      return hint;
    }

    case "HOUSE3": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", -1);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
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
          view_changed();
        }
      }
      else {
        hint = "House3 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?";
        UI_setTo_Create_House3();
      }
      return hint;
    }

    case "HOUSE2": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", -1);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
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
          view_changed();
        }
      }
      else {
        hint = "House2 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?";
        UI_setTo_Create_House2();
      }
      return hint;
    }

    case "HOUSE1": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", -1);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
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
          view_changed();
        }
      }
      else {
        hint = "House1 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?";
        UI_setTo_Create_House1();
      }
      return hint;
    }

    case "CYLINDER": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", 7);
        int deg = getI(p, "deg", 16);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
        float x = getF(p, "x", 0);
        float y = getF(p, "y", 0);
        float z = getF(p, "z", 0);
        float d = getF(p, "d", 6);
        float h = getF(p, "h", 6);
        float r = getF(p, "r", 0);
        if ((d != 0) && (h != 0)) {
          Create3D.add_SuperCylinder(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, 0.5 * d, 0.5 * h, deg, r);
          view_changed();
        }
      }
      else {
        hint = "Cylinder m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?";
        UI_setTo_Create_Cylinder();
      }
      return hint;
    }

    case "SPHERE": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", 7);
        int deg = getI(p, "deg", 3);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
        float x = getF(p, "x", 0);
        float y = getF(p, "y", 0);
        float z = getF(p, "z", 0);
        float d = getF(p, "d", 6);
        float r = getF(p, "r", 0);
        if (d != 0) {
          Create3D.add_CrystalSphere(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, deg, 0, 90 + r); // passing with isSky:0
          view_changed();
        }
      }
      else {
        hint = "Sphere m=? tes=? lyr=? x=? y=? z=? d=? deg=? r=?";
        UI_setTo_Create_Sphere();
      }
      return hint;
    }

    case "SUPERSPHERE": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", 7);
        int deg = getI(p, "deg", 3);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
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
          view_changed();
        }
      }
      else {
        hint = "SuperSphere m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? px=? py=? pz=? deg=? r=?";
        UI_setTo_Create_Sphere();
      }
      return hint;
    }

    case "CUSHION": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", 7);
        int deg = getI(p, "deg", 3);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
        float x = getF(p, "x", 0);
        float y = getF(p, "y", 0);
        float z = getF(p, "z", 0);
        float dx = getF(p, "dx", 6);
        float dy = getF(p, "dy", 6);
        float dz = getF(p, "dz", 6);
        float r = getF(p, "r", 0);
        if ((dx != 0) && (dy != 0) && (dz != 0)) {
          Create3D.add_SuperSphere(m, tes, lyr, vsb, wgt, clz, x, y, z, CubePower, CubePower, 2, 0.5 * dx, 0.5 * dy, 0.5 * dz, deg, r);
          view_changed();
        }
      }
      else {
        hint = "Cushion m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?";
        UI_setTo_Create_Cushion();
      }
      return hint;
    }

    case "OCTAHEDRON": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", 7);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
        float x = getF(p, "x", 0);
        float y = getF(p, "y", 0);
        float z = getF(p, "z", 0);
        float dx = getF(p, "dx", 6);
        float dy = getF(p, "dy", 6);
        float dz = getF(p, "dz", 6);
        float r = getF(p, "r", 0);
        if ((dx != 0) && (dy != 0) && (dz != 0)) {
          Create3D.add_Octahedron(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, r);
          view_changed();
        }
      }
      else {
        hint = "Octahedron m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?";
        UI_setTo_Create_Octahedron();
      }
      return hint;
    }

    case "ICOSAHEDRON": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", 7);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
        float x = getF(p, "x", 0);
        float y = getF(p, "y", 0);
        float z = getF(p, "z", 0);
        float d = getF(p, "d", 6);
        float r = getF(p, "r", 0);
        if (d != 0) {
          Create3D.add_Icosahedron(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, r);
          view_changed();
        }
      }
      else {
        hint = "Icosahedron m=? tes=? lyr=? x=? y=? z=? d=? r=?";
        UI_setTo_Create_Icosahedron();
      }
      return hint;
    }

    case "POLYGONEXTRUDE": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", 7);
        int deg = getI(p, "deg", 6);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
        float x = getF(p, "x", 0);
        float y = getF(p, "y", 0);
        float z = getF(p, "z", 0);
        float d = getF(p, "d", 6);
        float h = getF(p, "h", 6);
        float r = getF(p, "r", 0);
        if ((d != 0) && (h != 0)) {
          Create3D.add_PolygonExtrude(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, h, deg, r);
          view_changed();
        }
      }
      else {
        hint = "PolygonExtrude m=? tes=? lyr=? x=? y=? z=? d=? h=? deg=? r=?";
        UI_setTo_Create_Extrude();
      }
      return hint;
    }

    case "POLYGONHYPER": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", 7);
        int deg = getI(p, "deg", 6);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
        float x = getF(p, "x", 0);
        float y = getF(p, "y", 0);
        float z = getF(p, "z", 0);
        float d = getF(p, "d", 6);
        float h = getF(p, "h", 6);
        float r = getF(p, "r", 0);
        if ((d != 0) && (h != 0)) {
          Create3D.add_PolygonHyper(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, h, deg, r);
          view_changed();
        }
      }
      else {
        hint = "PolygonHyper m=? tes=? lyr=? x=? y=? z=? d=? h=? deg=? r=?";
        UI_setTo_Create_Hyper();
      }
      return hint;
    }

    case "POLYGONMESH": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", 7);
        int deg = getI(p, "deg", 6);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
        float x = getF(p, "x", 0);
        float y = getF(p, "y", 0);
        float z = getF(p, "z", 0);
        float d = getF(p, "d", 6);
        float r = getF(p, "r", 0);
        if (d != 0) {
          Create3D.add_PolygonMesh(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, deg, r);
          view_changed();
        }
      }
      else {
        hint = "PolygonMesh m=? tes=? lyr=? x=? y=? z=? d=? deg=? r=?";
        UI_setTo_Create_Plane();
      }
      return hint;
    }

    case "MESH2": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", 7);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
        float x1 = getF(p, "x1", 0);
        float y1 = getF(p, "y1", 0);
        float z1 = getF(p, "z1", 0);
        float x2 = getF(p, "x2", 0);
        float y2 = getF(p, "y2", 0);
        float z2 = getF(p, "z2", 0);
        if ((x1 == x2) || (y1 == y2) || (z1 == z2)) {
          Create3D.add_Mesh2(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2);
          view_changed();
        }
      }
      else {
        hint = "Mesh2 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=?";
      }
      return hint;
    }

    case "MESH3": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", 7);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
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
          view_changed();
        }
      }
      else {
        hint = "Mesh3 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=?";
      }
      return hint;
    }

    case "MESH4": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", 7);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
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
          view_changed();
        }
      }
      else {
        hint = "Mesh4 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=? x4=? y4=? z4=?";
      }
      return hint;
    }

    case "MESH5": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", 7);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
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
          view_changed();
        }
      }
      else {
        hint = "Mesh5 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=? x4=? y4=? z4=? x5=? y5=? z5=?";
      }
      return hint;
    }

    case "MESH6": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", 7);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
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
          view_changed();
        }
      }
      else {
        hint = "Mesh6 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=? x4=? y4=? z4=? x5=? y5=? z5=? x6=? y6=? z6=?";
      }
      return hint;
    }

    case "H_SHADE": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", 7);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
        float x = getF(p, "x", 0);
        float y = getF(p, "y", 0);
        float z = getF(p, "z", 0);
        float d = getF(p, "d", 0);
        float w = getF(p, "w", 0);
        float a = getF(p, "a", 0);
        float b = getF(p, "b", 0);
        if ((d != 0) && (w != 0)) {
          Create3D.add_H_shade(m, tes, lyr, vsb, wgt, clz, x, y, z, d, w, a, b);
          view_changed();
        }
      }
      else {
        hint = "H_Shade m=? tes=? lyr=? x=? y=? z=? d=? w=? a=? b=?";
      }
      return hint;
    }

    case "V_SHADE": {
      if (parts.length > 1) {
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", 7);
        int tes = getI(p, "tes", 0);
        int lyr = getI(p, "lyr", 0);
        int vsb = 1;
        int wgt = 0;
        int clz = 0;
        float x = getF(p, "x", 0);
        float y = getF(p, "y", 0);
        float z = getF(p, "z", 0);
        float d = getF(p, "d", 0);
        float h = getF(p, "h", 0);
        float a = getF(p, "a", 0);
        float b = getF(p, "b", 0);
        if ((d != 0) && (h != 0)) {
          Create3D.add_V_shade(m, tes, lyr, vsb, wgt, clz, x, y, z, h, d, a, b);
          view_changed();
        }
      }
      else {
        hint = "V_Shade m=? tes=? lyr=? x=? y=? z=? d=? h=? a=? b=?";
      }
      return hint;
    }

    case "SOLID": {
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
          view_changed();
        }
      }
      else {
        hint = "Solid x=? y=? z=? px=? py=? pz=? sx=? sy=? sz=? rx=? ry=? rz=? v=?";
        UI_setTo_Create_Solid();
      }
      return hint;
    }

    case "SECTION": {
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

    case "CAMERA": {
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

    case "PLOYLINE": {
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

    case "ARC": {
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

    case "PIVOT": {
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

    case "VERTEX>GROUP": {
      Select3D.convert_Vertices_to_Groups();
      view_changed();
      return hint;
    }

    case "FACE>GROUP": {
      Select3D.convert_Faces_to_Groups();
      view_changed();
      return hint;
    }

    case "GROUP>FACE": {
      Select3D.convert_Groups_to_Faces();
      view_changed();
      return hint;
    }

    case "POLYLINE>GROUP": {
      Select3D.convert_Polylines_to_Groups();
      view_changed();
      return hint;
    }

    case "GROUP>POLYLINE": {
      Select3D.convert_Groups_to_Polylines();
      view_changed();
      return hint;
    }

    case "POLYLINE>VERTEX": {
      Select3D.convert_Polylines_to_Vertices();
      view_changed();
      return hint;
    }

    case "VERTEX>POLYLINE": {
      Select3D.convert_Vertices_to_Polylines();
      view_changed();
      return hint;
    }

    case "GROUP>VERTEX": {
      Select3D.convert_Groups_to_Vertices();
      view_changed();
      return hint;
    }

    case "FACE>VERTEX": {
      Select3D.convert_Faces_to_Vertices();
      view_changed();
      return hint;
    }

    case "VERTEX>FACE": {
      Select3D.convert_Vertices_to_Faces();
      view_changed();
      return hint;
    }

    case "SOLID>GROUP": {
      Select3D.convert_Solids_to_Groups();
      view_changed();
      return hint;
    }

    case "GROUP>SOLID": {
      Select3D.convert_Groups_to_Solids();
      view_changed();
      return hint;
    }

    case "2D>GROUP": {
      Select3D.convert_Model2Ds_to_Groups();
      view_changed();
      return hint;
    }

    case "GROUP>2D": {
      Select3D.convert_Groups_to_Model2Ds();
      view_changed();
      return hint;
    }

    case "1D>GROUP": {
      Select3D.convert_Model1Ds_to_Groups();
      view_changed();
      return hint;
    }

    case "GROUP>1D": {
      Select3D.convert_Groups_to_Model1Ds();
      view_changed();
      return hint;
    }

    case "DISTZ": {
      UI_setTo_View_Truck(0);
      return hint;
    }

    case "DISTC": {
      UI_setTo_View_CameraDistance(0);
      return hint;
    }

    case "DISTP": {
      UI_setTo_View_DistMouseXY(0);
      return hint;
    }

    case "SIZEALL": {
      UI_setTo_View_AllModelSize();
      return hint;
    }

    case "SIZESKY": {
      UI_setTo_View_SkydomeSize();
      return hint;
    }

    case "SIZE3D": {
      UI_setTo_View_3DModelSize();
      return hint;
    }

    case "ALLVIEWPORTS": {
      UI_setTo_Viewport(0);
      return hint;
    }

    case "ENLARGE3D": {
      UI_setTo_Viewport(1);
      return hint;
    }

    case "LOOKORG": {
      UI_setTo_View_LookAtOrigin(0);
      return hint;
    }

    case "LOOKDIR": {
      UI_setTo_View_LookAtDirection(0);
      return hint;
    }

    case "LOOKSEL": {
      UI_setTo_View_LookAtSelection(0);
      return hint;
    }

    case "TRUCKZ": {
      UI_setTo_View_Truck(0);
      return hint;
    }

    case "TRUCKX": {
      UI_setTo_View_Truck(1);
      return hint;
    }

    case "TRUCKY": {
      UI_setTo_View_Truck(2);
      return hint;
    }

    case "TARGETROLL": {
      UI_setTo_View_TargetRoll(0);
      return hint;
    }

    case "TARGETROLLZ": {
      UI_setTo_View_TargetRoll(1);
      return hint;
    }

    case "TARGETROLLXY": {
      UI_setTo_View_TargetRoll(2);
      return hint;
    }

    case "CAMERAROLL": {
      UI_setTo_View_CameraRoll(0);
      return hint;
    }

    case "CAMERAROLLZ": {
      UI_setTo_View_CameraRoll(1);
      return hint;
    }

    case "CAMERAROLLXY": {
      UI_setTo_View_CameraRoll(2);
      return hint;
    }

    case "ORBIT": {
      UI_setTo_View_Orbit(0);
      return hint;
    }

    case "ORBITZ": {
      UI_setTo_View_Orbit(1);
      return hint;
    }

    case "ORBITXY": {
      UI_setTo_View_Orbit(2);
      return hint;
    }

    case "LANDORBIT": {
      UI_setTo_View_LandOrbit(0);
      return hint;
    }

    case "PAN": {
      UI_setTo_View_Pan(0);
      return hint;
    }

    case "PANX": {
      UI_setTo_View_Pan(1);
      return hint;
    }

    case "PANY": {
      UI_setTo_View_Pan(2);
      return hint;
    }

    case "ZOOM": {
      UI_setTo_View_ZOOM(0);
      return hint;
    }

    case "NORMALZOOM": {
      UI_setTo_View_ZOOM(1);
      return hint;
    }

    case "ORTHOGRAPHIC": {
      UI_setTo_View_ProjectionType(0);
      return hint;
    }

    case "PERSPECTIVE": {
      UI_setTo_View_ProjectionType(1);
      return hint;
    }

    case "TOP": {
      UI_setTo_View_3DViewPoint(0);
      return hint;
    }

    case "FRONT": {
      UI_setTo_View_3DViewPoint(1);
      return hint;
    }

    case "LEFT": {
      UI_setTo_View_3DViewPoint(2);
      return hint;
    }

    case "BACK": {
      UI_setTo_View_3DViewPoint(3);
      return hint;
    }

    case "RIGHT": {
      UI_setTo_View_3DViewPoint(4);
      return hint;
    }

    case "BOTTOM": {
      UI_setTo_View_3DViewPoint(5);
      return hint;
    }

    case "S.W.": {
      UI_setTo_View_3DViewPoint(6);
      return hint;
    }

    case "S.E.": {
      UI_setTo_View_3DViewPoint(7);
      return hint;
    }

    case "N.E.": {
      UI_setTo_View_3DViewPoint(8);
      return hint;
    }

    case "N.W.": {
      UI_setTo_View_3DViewPoint(9);
      return hint;
    }

    case "SHADE.WIRE": {
      WIN3D.FacesShade = SHADE.Surface_Wire;
      allFaces.displayEdges = true; //<<<<<<<<<<<<<<<
      view_changed();
      return hint;
    }

    case "SHADE.BASE": {
      WIN3D.FacesShade = SHADE.Surface_Base;
      view_changed();
      return hint;
    }

    case "SHADE.WHITE": {
      WIN3D.FacesShade = SHADE.Surface_White;
      view_changed();
      return hint;
    }

    case "SHADE.MATERIALS": {
      WIN3D.FacesShade = SHADE.Surface_Materials;
      view_changed();
      return hint;
    }

    case "SHADE.GLOBAL": {
      WIN3D.FacesShade = SHADE.Global_Solar;
      GlobalSolar_rebuild_array = true;
      regenerate_desired_bakings();
      view_changed();
      return hint;
    }

    case "SHADE.REAL": {
      WIN3D.FacesShade = SHADE.Vertex_Solar;
      VertexSolar_rebuild_array = true;
      regenerate_desired_bakings();
      view_changed();
      return hint;
    }

    case "SHADE.SOLID": {
      WIN3D.FacesShade = SHADE.Vertex_Solid;
      view_changed();
      return hint;
    }

    case "SHADE.ELEVATION": {
      WIN3D.FacesShade = SHADE.Vertex_Elevation;
      view_changed();
      return hint;
    }

    case "SHADE.VIEWPORT": {
      ShadeViewport();
      return hint;
    }

    case "PREBAKE.VIEWPORT": {
      preBakeViewport();
      return hint;
    }

    case "SETLONLAT": {
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

    case "SETLON": {
      if (parts.length > 1) {
        STATION.setLongitude(float(parts[1]));
        update_station(0);
      }
      else {
        hint = "SetLon ?";
      }
      return hint;
    }

    case "SETLAT": {
      if (parts.length > 1) {
        STATION.setLatitude(float(parts[1]));
        update_station(0);
      }
      else {
        hint = "SetLat ?";
      }
      return hint;
    }

    default:
      hint = UnrecognizedCommand;
  }

  return hint;
}

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