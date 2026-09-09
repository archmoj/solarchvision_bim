HashMap<String,String> parseParams(String[] parts) {
  HashMap<String,String> p = new HashMap<String,String>();
  for (int q = 1; q < parts.length; q++) {
    String[] kv = split(parts[q], '=');
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

void COMIN_keyPressed (KeyEvent e) {
  if ((!e.isAltDown()) && (!e.isControlDown())) {

    if (key != CODED) {
      switch(key) {

        case ENTER:
          String[] newCommand = {""};
          String[] newMessage = {""};

          allMessages[allMessages.length - 1] = SOLARCHVISION_executeCommand(allCommands[allCommands.length - 1]);

          allCommands = concat(allCommands, newCommand);
          allMessages = concat(allMessages, newMessage);
          break;

        case BACKSPACE:
            if (allCommands[allCommands.length - 1].length() > 0) {
              allCommands[allCommands.length - 1] = allCommands[allCommands.length - 1].substring(0, allCommands[allCommands.length - 1].length() - 1);
            }
            break;

        default:
          if ((31 < key) && (key < 127)) {
            allCommands[allCommands.length - 1] += key;
          }
          break;
      }
    }
  }
}

void SOLARCHVISION_execute_commands_TXT (String FileName) {

  String[] FileALL = loadStrings(FileName);

  for (int f = 0; f < FileALL.length; f++) {

    String lineSTR = FileALL[f];

    SOLARCHVISION_executeCommand(lineSTR);
  }

}

String SOLARCHVISION_executeCommand (String lineSTR) {

  String return_message = "";

  lineSTR = lineSTR.replace("\"", "");

  String[] parts = split(lineSTR, ' ');

  String Command_CAPITAL = parts[0].toUpperCase();

  switch (Command_CAPITAL) {
    case "CLS": {

      allCommands = new String[1];
      allMessages = new String[1];

      allCommands[0] = "";
      allMessages[0] = "";

      break;
    }

    case "OPEN": {

      selectInput("Select a file to open:", "SOLARCHVISION_fileSelected_Open");

      break;
    }

    case "SAVE.AS": {

      selectOutput("Select a file to write to:", "SOLARCHVISION_fileSelected_SaveAs");

      break;
    }

    case "SAVE": {

      SOLARCHVISION_save_project(Folder_Project + "/" + ProjectName + ".xml");

      break;
    }

    case "HOLD": {

      SOLARCHVISION_hold_project();

      break;
    }

    case "FETCH": {

      SOLARCHVISION_fetch_project();

      break;
    }

    case "IMPORT": {

      selectInput("Select OBJ file to import:", "SOLARCHVISION_SelectFile_Import_3DModel");

      break;
    }

    case "EXECUTE": {

      selectInput("Select TXT file to execute:", "SOLARCHVISION_SelectFile_Execute_CommandFile");

      break;
    }

    case "EXPORT.OBJ.TIMESERIES": {

      SOLARCHVISION_export_objects_OBJ_timeSeries();

      break;
    }

    case "EXPORT.OBJ.DATESERIES": {

      SOLARCHVISION_export_objects_OBJ_dateSeries();

      break;
    }

    case "EXPORT.OBJ": {

      SOLARCHVISION_export_objects_OBJ("");

      break;
    }

    case "EXPORT.RAD": {

      SOLARCHVISION_export_objects_RAD();

      break;
    }

    case "EXPORT.SCR": {

      SOLARCHVISION_export_objects_SCR();

      break;
    }

    case "QUIT": {

      exit();

      break;
    }

    case "MOVE": {

      if (parts.length > 1) {
        float dx = 0;
        float dy = 0;
        float dz = 0;
        for (int q = 1; q < parts.length; q++) {
          String[] parameters = split(parts[q], '=');
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
        SOLARCHVISION_view_changed();
      }
      else {
        return_message = "Move dx=? dy=? dz=?";
      }

      break;
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
          String[] parameters = split(parts[q], '=');
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
        SOLARCHVISION_view_changed();
      }
      else {
        return_message = "Rotate[X|Y|Z] r=? x=? y=? z=?";

        UI_set_to_Modify_Rotate(2);
        UI_toolBar.revise();
      }

      break;
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
          String[] parameters = split(parts[q], '=');
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
        SOLARCHVISION_view_changed();
      }
      else {
        return_message = "Scale s=? sx=? sy=? sz=? x=? y=? z=?";
      }

      break;
    }

    case "DELETE": {

      if (parts.length > 1) {
        for (int q = 1; q < parts.length; q++) {
          String low_case = parts[q].toLowerCase();
               if (low_case.equals("all")) SOLARCHVISION_deleteAll();
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
        SOLARCHVISION_view_changed();
      }
      else {
        return_message = "Delete all/selection/groups/model2ds/model1ds/vertices/faces/solids/sections/cameras";
      }

      break;
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

        SOLARCHVISION_view_changed();
      }
      else {
        return_message = "Copy n=? dx=? dy=? dz=? rx=? ry=? rz=?";
      }

      break;
    }

    case "SELECT": {

      if (parts.length > 1) {
        for (int q = 1; q < parts.length; q++) {
          String low_case = parts[q].toLowerCase();
               if (low_case.equals("groups")) SOLARCHVISION_switch_category(ObjectCategory.GROUP);
          else if (low_case.equals("model2ds")) SOLARCHVISION_switch_category(ObjectCategory.MODEL2D);
          else if (low_case.equals("model1ds")) SOLARCHVISION_switch_category(ObjectCategory.MODEL1D);
          else if (low_case.equals("vertices")) SOLARCHVISION_switch_category(ObjectCategory.VERTEX);
          else if (low_case.equals("faces")) SOLARCHVISION_switch_category(ObjectCategory.FACE);
          else if (low_case.equals("lines")) SOLARCHVISION_switch_category(ObjectCategory.POLYLINE);
          else if (low_case.equals("solids")) SOLARCHVISION_switch_category(ObjectCategory.SOLID);
          else if (low_case.equals("sections")) SOLARCHVISION_switch_category(ObjectCategory.SECTION);
          else if (low_case.equals("cameras")) SOLARCHVISION_switch_category(ObjectCategory.CAMERA);
          else if (low_case.equals("landpoints")) SOLARCHVISION_switch_category(ObjectCategory.LANDPOINT);
        }

        for (int q = 1; q < parts.length; q++) {
          String low_case = parts[q].toLowerCase();
               if (low_case.equals("all")) Select3D.selectAll();
          else if (low_case.equals("invert")) Select3D.invertSelection();
          else if (low_case.equals("nothing")) Select3D.deselectAll();
          else if (low_case.equals("last")) Select3D.selectLast();
        }

        SOLARCHVISION_view_changed();
      }
      else {
        return_message = "Select all/last/nothing/invert/groups/model2ds/model1ds/vertices/faces/solids/sections/cameras/landpoint";
      }

      break;
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
        SOLARCHVISION_view_changed();
      }
      else {
        return_message = "Person m=? x=? y=? z=?";

        UI_set_to_Create_Person();
      }

      break;
    }

    case "TREE2": {

      if (parts.length > 1) {
        String t = "TREES";
        HashMap<String,String> p = parseParams(parts);
        int m = getI(p, "m", 0);
        float x = getF(p, "x", 0);
        float y = getF(p, "y", 0);
        float z = getF(p, "z", 0);
        float h = getF(p, "h", 5.0);

        if (h != 0) {
          allModel2Ds.create(t, m, x, y, z, h);
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Tree2 m=? x=? y=? z=? h=?";

        UI_set_to_Create_Tree();
      }

      break;
    }

    case "TREE1": {

      if (parts.length > 1) {
        int m = 0;
        int seed = 0; //PlantSeed
        int degree = 5; //PlantDegree
        float x = 0;
        float y = 0;
        float z = 0;
        float h = 5.0;
        float r = floor(random(360));
        float tilt = floor(random(90));
        float twist = floor(random(360));
        float ratio = 0.5 + random(0.5);
        float base = 0.0 + random(2.0);
        float Tk = 1.0; //TrunkSize
        float Lf = 0.1; //LeafSize

        for (int q = 1; q < parts.length; q++) {
          String[] parameters = split(parts[q], '=');
          if (parameters.length > 1) {
            String low_case = parameters[0].toLowerCase();
                 if (low_case.equals("m")) m = int(parameters[1]);
            else if (low_case.equals("seed")) seed = int(parameters[1]);
            else if (low_case.equals("degree")) degree = int(parameters[1]);
            else if (low_case.equals("x")) x = float(parameters[1]);
            else if (low_case.equals("y")) y = float(parameters[1]);
            else if (low_case.equals("z")) z = float(parameters[1]);
            else if (low_case.equals("h")) h = float(parameters[1]);
            else if (low_case.equals("r")) r = float(parameters[1]) * PI / 180.0;
            else if (low_case.equals("tilt")) tilt = float(parameters[1]) * PI / 180.0;
            else if (low_case.equals("twist")) twist = float(parameters[1]) * PI / 180.0;
            else if (low_case.equals("ratio")) ratio = float(parameters[1]);
            else if (low_case.equals("base")) base = float(parameters[1]);
            else if (low_case.equals("tk")) Tk = float(parameters[1]);
            else if (low_case.equals("lf")) Lf = float(parameters[1]);
          }
        }
        if (h != 0) {
          allModel1Ds.create(m, seed, degree, x, y, z, h, r, tilt, twist, ratio, base, Tk, Lf);
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Tree1 m=? degree=? seed=? x=? y=? z=? h=? r=? tilt=? twist=? ratio=? base=? Tk=? Lf=?";

        UI_set_to_Create_allModel1Ds();
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Box2P m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=?";

        UI_set_to_Create_Box();
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Box m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?";

        UI_set_to_Create_Box();
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "House3 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?";

        UI_set_to_Create_House3();
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "House2 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?";

        UI_set_to_Create_House2();
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "House1 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?";

        UI_set_to_Create_House1();
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Cylinder m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?";

        UI_set_to_Create_Cylinder();
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Sphere m=? tes=? lyr=? x=? y=? z=? d=? deg=? r=?";

        UI_set_to_Create_Sphere();
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "SuperSphere m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? px=? py=? pz=? deg=? r=?";

        UI_set_to_Create_Sphere();
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Cushion m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?";

        UI_set_to_Create_Cushion();
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Octahedron m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?";

        UI_set_to_Create_Octahedron();
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Icosahedron m=? tes=? lyr=? x=? y=? z=? d=? r=?";

        UI_set_to_Create_Icosahedron();
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "PolygonExtrude m=? tes=? lyr=? x=? y=? z=? d=? h=? deg=? r=?";

        UI_set_to_Create_Extrude();
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "PolygonHyper m=? tes=? lyr=? x=? y=? z=? d=? h=? deg=? r=?";

        UI_set_to_Create_Hyper();
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "PolygonMesh m=? tes=? lyr=? x=? y=? z=? d=? deg=? r=?";

        UI_set_to_Create_Plane();
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Mesh2 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=?";
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Mesh3 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=?";
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Mesh4 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=? x4=? y4=? z4=?";
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Mesh5 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=? x4=? y4=? z4=? x5=? y5=? z5=?";
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Mesh6 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=? x4=? y4=? z4=? x5=? y5=? z5=? x6=? y6=? z6=?";
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "H_Shade m=? tes=? lyr=? x=? y=? z=? d=? w=? a=? b=?";
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "V_Shade m=? tes=? lyr=? x=? y=? z=? d=? h=? a=? b=?";
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Solid x=? y=? z=? px=? py=? pz=? sx=? sy=? sz=? rx=? ry=? rz=? v=?";

        UI_set_to_Create_Solid();
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Section x=? y=? z=? r=? u=? v=? t=? i=? j=?";

        UI_set_to_Create_Section();
      }

      break;
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Camera px=? py=? pz=? pt=? rx=? ry=? rz=? rt=? a=? t=?";

        UI_set_to_Create_Camera();
      }

      break;
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
          String[] parameters = split(parts[q], '=');
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Polyline m=? tes=? lyr=? xtr=? wgt=? clz=? x1,y1,z1 x2,y2,z2 etc.";

        UI_set_to_Create_Polyline();
      }

      break;
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
          String[] parameters = split(parts[q], '=');
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
          SOLARCHVISION_view_changed();
        }
      }
      else {
        return_message = "Arc m=? tes=? lyr=? xtr=? wgt=? clz=? x=? y=? z=? r=? deg=? rot=? ang=?";

        UI_set_to_Create_Polyline();
      }

      break;
    }

    case "PIVOT": {

      if (parts.length > 1) {
        for (int q = 1; q < parts.length; q++) {
          String low_case = parts[q].toLowerCase();
               if (low_case.equals("minx")) UI_set_to_View_PivotX(-1);
          else if (low_case.equals("midx")) UI_set_to_View_PivotX(0);
          else if (low_case.equals("maxx")) UI_set_to_View_PivotX(1);
          else if (low_case.equals("miny")) UI_set_to_View_PivotY(-1);
          else if (low_case.equals("midy")) UI_set_to_View_PivotY(0);
          else if (low_case.equals("maxy")) UI_set_to_View_PivotY(1);
          else if (low_case.equals("minz")) UI_set_to_View_PivotZ(-1);
          else if (low_case.equals("midz")) UI_set_to_View_PivotZ(0);
          else if (low_case.equals("maxz")) UI_set_to_View_PivotZ(1);
        }
        SOLARCHVISION_view_changed();
      }
      else {
        return_message = "PIVOT minX midY maxZ or other variations";
      }

      break;
    }

    case "VERTEX>GROUP": {

      Select3D.convert_Vertices_to_Groups();
      SOLARCHVISION_view_changed();

      break;
    }

    case "FACE>GROUP": {

      Select3D.convert_Faces_to_Groups();
      SOLARCHVISION_view_changed();

      break;
    }

    case "GROUP>FACE": {

      Select3D.convert_Groups_to_Faces();
      SOLARCHVISION_view_changed();

      break;
    }

    case "POLYLINE>GROUP": {

      Select3D.convert_Polylines_to_Groups();
      SOLARCHVISION_view_changed();

      break;
    }

    case "GROUP>POLYLINE": {

      Select3D.convert_Groups_to_Polylines();
      SOLARCHVISION_view_changed();

      break;
    }

    case "POLYLINE>VERTEX": {

      Select3D.convert_Polylines_to_Vertices();
      SOLARCHVISION_view_changed();

      break;
    }

    case "VERTEX>POLYLINE": {

      Select3D.convert_Vertices_to_Polylines();
      SOLARCHVISION_view_changed();

      break;
    }

    case "GROUP>VERTEX": {

      Select3D.convert_Groups_to_Vertices();
      SOLARCHVISION_view_changed();

      break;
    }

    case "FACE>VERTEX": {

      Select3D.convert_Faces_to_Vertices();
      SOLARCHVISION_view_changed();

      break;
    }

    case "VERTEX>FACE": {

      Select3D.convert_Vertices_to_Faces();
      SOLARCHVISION_view_changed();

      break;
    }

    case "SOLID>GROUP": {

      Select3D.convert_Solids_to_Groups();
      SOLARCHVISION_view_changed();

      break;
    }

    case "GROUP>SOLID": {

      Select3D.convert_Groups_to_Solids();
      SOLARCHVISION_view_changed();

      break;
    }

    case "2D>GROUP": {

      Select3D.convert_Model2Ds_to_Groups();
      SOLARCHVISION_view_changed();

      break;
    }

    case "GROUP>2D": {

      Select3D.convert_Groups_to_Model2Ds();
      SOLARCHVISION_view_changed();

      break;
    }

    case "1D>GROUP": {

      Select3D.convert_Model1Ds_to_Groups();
      SOLARCHVISION_view_changed();

      break;
    }

    case "GROUP>1D": {

      Select3D.convert_Groups_to_Model1Ds();
      SOLARCHVISION_view_changed();

      break;
    }

    case "DISTZ": {

      UI_set_to_View_Truck(0);

      break;
    }

    case "DISTC": {

      UI_set_to_View_CameraDistance(0);

      break;
    }

    case "DISTP": {

      UI_set_to_View_DistMouseXY(0);

      break;
    }

    case "SIZEALL": {

      UI_set_to_View_AllModelSize();

      break;
    }

    case "SIZESKY": {

      UI_set_to_View_SkydomeSize();

      break;
    }

    case "SIZE3D": {

      UI_set_to_View_3DModelSize();

      break;
    }

    case "ALLVIEWPORTS": {

      UI_set_to_Viewport(0);

      break;
    }

    case "ENLARGE3D": {

      UI_set_to_Viewport(1);

      break;
    }

    case "LOOKORG": {

      UI_set_to_View_LookAtOrigin(0);

      break;
    }

    case "LOOKDIR": {

      UI_set_to_View_LookAtDirection(0);

      break;
    }

    case "LOOKSEL": {

      UI_set_to_View_LookAtSelection(0);

      break;
    }

    case "TRUCKZ": {

      UI_set_to_View_Truck(0);

      break;
    }

    case "TRUCKX": {

      UI_set_to_View_Truck(1);

      break;
    }

    case "TRUCKY": {

      UI_set_to_View_Truck(2);

      break;
    }

    case "TARGETROLL": {

      UI_set_to_View_TargetRoll(0);

      break;
    }

    case "TARGETROLLZ": {

      UI_set_to_View_TargetRoll(1);

      break;
    }

    case "TARGETROLLXY": {

      UI_set_to_View_TargetRoll(2);

      break;
    }

    case "CAMERAROLL": {

      UI_set_to_View_CameraRoll(0);

      break;
    }

    case "CAMERAROLLZ": {

      UI_set_to_View_CameraRoll(1);

      break;
    }

    case "CAMERAROLLXY": {

      UI_set_to_View_CameraRoll(2);

      break;
    }

    case "ORBIT": {

      UI_set_to_View_Orbit(0);

      break;
    }

    case "ORBITZ": {

      UI_set_to_View_Orbit(1);

      break;
    }

    case "ORBITXY": {

      UI_set_to_View_Orbit(2);

      break;
    }

    case "LANDORBIT": {

      UI_set_to_View_LandOrbit(0);

      break;
    }

    case "PAN": {

      UI_set_to_View_Pan(0);

      break;
    }

    case "PANX": {

      UI_set_to_View_Pan(1);

      break;
    }

    case "PANY": {

      UI_set_to_View_Pan(2);

      break;
    }

    case "ZOOM": {

      UI_set_to_View_ZOOM(0);

      break;
    }

    case "NORMALZOOM": {

      UI_set_to_View_ZOOM(1);

      break;
    }

    case "ORTHOGRAPHIC": {

      UI_set_to_View_ProjectionType(0);

      break;
    }

    case "PERSPECTIVE": {

      UI_set_to_View_ProjectionType(1);

      break;
    }

    case "TOP": {

      UI_set_to_View_3DViewPoint(0);

      break;
    }

    case "FRONT": {

      UI_set_to_View_3DViewPoint(1);

      break;
    }

    case "LEFT": {

      UI_set_to_View_3DViewPoint(2);

      break;
    }

    case "BACK": {

      UI_set_to_View_3DViewPoint(3);

      break;
    }

    case "RIGHT": {

      UI_set_to_View_3DViewPoint(4);

      break;
    }

    case "BOTTOM": {

      UI_set_to_View_3DViewPoint(5);

      break;
    }

    case "S.W.": {

      UI_set_to_View_3DViewPoint(6);

      break;
    }

    case "S.E.": {

      UI_set_to_View_3DViewPoint(7);

      break;
    }

    case "N.E.": {

      UI_set_to_View_3DViewPoint(8);

      break;
    }

    case "N.W.": {

      UI_set_to_View_3DViewPoint(9);

      break;
    }

    case "SHADE.WIRE": {

      WIN3D.FacesShade = SHADE.Surface_Wire;
      allFaces.displayEdges = true; //<<<<<<<<<<<<<<<
      SOLARCHVISION_view_changed();

      break;
    }

    case "SHADE.BASE": {

      WIN3D.FacesShade = SHADE.Surface_Base;
      SOLARCHVISION_view_changed();

      break;
    }

    case "SHADE.WHITE": {

      WIN3D.FacesShade = SHADE.Surface_White;
      SOLARCHVISION_view_changed();

      break;
    }

    case "SHADE.MATERIALS": {

      WIN3D.FacesShade = SHADE.Surface_Materials;
      SOLARCHVISION_view_changed();

      break;
    }

    case "SHADE.GLOBAL": {

      WIN3D.FacesShade = SHADE.Global_Solar;
      SOLARCHVISION_view_changed();

      break;
    }

    case "SHADE.REAL": {

      WIN3D.FacesShade = SHADE.Vertex_Solar;
      SOLARCHVISION_view_changed();

      break;
    }

    case "SHADE.SOLID": {

      WIN3D.FacesShade = SHADE.Vertex_Solid;
      SOLARCHVISION_view_changed();

      break;
    }

    case "SHADE.ELEVATION": {

      WIN3D.FacesShade = SHADE.Vertex_Elevation;
      SOLARCHVISION_view_changed();

      break;
    }

    case "RENDER.VIEWPORT": {

      SOLARCHVISION_RenderViewport();

      break;
    }

    case "PREBAKE.VIEWPORT": {

      SOLARCHVISION_preBakeViewport();

      break;
    }

    case "LONLAT": {

      if (parts.length > 2) {

        STATION.setLatitude(float(parts[2]));
        STATION.setLongitude(float(parts[1]));

        SOLARCHVISION_update_station(1);
      }
      else {
        return_message = "LonLat ? ?";
      }

      break;
    }

    default:
      // Unknown command: silently ignored
      break;
  }

  return return_message;
}
