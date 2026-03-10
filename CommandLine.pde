void COMIN_keyPressed (KeyEvent e) {

  if ((e.isAltDown() != true) && (e.isControlDown() != true) && (e.isShiftDown() != true)) {

    if (key == CODED) {
      switch(keyCode) {
      }
    }
  }

  if ((e.isAltDown() != true) && (e.isControlDown() != true)) {

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

  if (Command_CAPITAL.equals("CLS")) {
    allCommands = new String[1];
    allMessages = new String[1];

    allCommands[0] = "";
    allMessages[0] = "";
  }

  else if (Command_CAPITAL.equals("OPEN")) {
    selectInput("Select a file to open:", "SOLARCHVISION_fileSelected_Open");
  }

  else if (Command_CAPITAL.equals("SAVE.AS")) {
    selectOutput("Select a file to write to:", "SOLARCHVISION_fileSelected_SaveAs");
  }

  else if (Command_CAPITAL.equals("SAVE")) {
    SOLARCHVISION_save_project(Folder_Project + "/" + ProjectName + ".xml");
  }

  else if (Command_CAPITAL.equals("HOLD")) {
    SOLARCHVISION_hold_project();
  }

  else if (Command_CAPITAL.equals("FETCH")) {
    SOLARCHVISION_fetch_project();
  }

  else if (Command_CAPITAL.equals("IMPORT")) {
    selectInput("Select OBJ file to import:", "SOLARCHVISION_SelectFile_Import_3DModel");
  }

  else if (Command_CAPITAL.equals("EXECUTE")) {
    selectInput("Select TXT file to execute:", "SOLARCHVISION_SelectFile_Execute_CommandFile");
  }

  else if (Command_CAPITAL.equals("EXPORT.OBJ.TIMESERIES")) {
    SOLARCHVISION_export_objects_OBJ_timeSeries();
  }

  else if (Command_CAPITAL.equals("EXPORT.OBJ.DATESERIES")) {
    SOLARCHVISION_export_objects_OBJ_dateSeries();
  }

  else if (Command_CAPITAL.equals("EXPORT.OBJ")) {
    SOLARCHVISION_export_objects_OBJ("");
  }

  else if (Command_CAPITAL.equals("EXPORT.RAD")) {
    SOLARCHVISION_export_objects_RAD();
  }

  else if (Command_CAPITAL.equals("EXPORT.SCR")) {
    SOLARCHVISION_export_objects_SCR();
  }

  else if (Command_CAPITAL.equals("QUIT")) {
    exit();
  }





  else if (Command_CAPITAL.equals("MOVE")) {
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
  }

  else if ((Command_CAPITAL.equals("ROTATE")) ||
          (Command_CAPITAL.equals("ROTATEX")) ||
          (Command_CAPITAL.equals("ROTATEY")) ||
          (Command_CAPITAL.equals("ROTATEZ"))) {
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
  }

  else if (Command_CAPITAL.equals("SCALE")) {
    if (parts.length > 1) {
      float sx = 1;
      float sy = 1;
      float sz = 1;

      float x = 0;
      float y = 0;
      float z = 0;
      float r = 0;
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
  }

  else if (Command_CAPITAL.equals("DELETE")) {
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
  }

  else if (Command_CAPITAL.equals("COPY")) {
    if (parts.length > 1) {
      int n = 1;
      float dx = 0;
      float dy = 0;
      float dz = 0;
      float rx = 0;
      float ry = 0;
      float rz = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("n")) n = int(parameters[1]);
          else if (low_case.equals("dx")) dx = float(parameters[1]);
          else if (low_case.equals("dy")) dy = float(parameters[1]);
          else if (low_case.equals("dz")) dz = float(parameters[1]);
          else if (low_case.equals("rx")) rx = float(parameters[1]);
          else if (low_case.equals("ry")) ry = float(parameters[1]);
          else if (low_case.equals("rz")) rz = float(parameters[1]);
        }
      }

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
  }

  else if (Command_CAPITAL.equals("SELECT")) {
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
  }






  else if (Command_CAPITAL.equals("PERSON")) {
    if (parts.length > 1) {
      String t = "PEOPLE";
      int m = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
        }
      }
      allModel2Ds.create(t, m, x, y, z, 2.5);
      SOLARCHVISION_view_changed();
    }
    else {
      return_message = "2Dman m=? x=? y=? z=?";

      UI_set_to_Create_Person();
    }
  }

  else if (Command_CAPITAL.equals("TREE")) {
    if (parts.length > 1) {
      String t = "TREES";
      int m = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float h = 5.0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("h")) h = float(parameters[1]);
        }
      }
      if (h != 0) {
        allModel2Ds.create(t, m, x, y, z, h);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "2Dtree m=? x=? y=? z=? h=?";

      UI_set_to_Create_Tree();
    }
  }

  else if (Command_CAPITAL.equals("FRACTALTREE")) {
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
      return_message = "3Dtree m=? degree=? seed=? x=? y=? z=? h=? r=? tilt=? twist=? ratio=? base=? Tk=? Lf=?";

      UI_set_to_Create_allModel1Ds();
    }
  }

  else if (Command_CAPITAL.equals("BOX2P")) {
    if (parts.length > 1) {
      int m = -1;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x1 = 0;
      float y1 = 0;
      float z1 = 0;
      float x2 = 0;
      float y2 = 0;
      float z2 = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x1")) x1 = float(parameters[1]);
          else if (low_case.equals("y1")) y1 = float(parameters[1]);
          else if (low_case.equals("z1")) z1 = float(parameters[1]);
          else if (low_case.equals("x2")) x2 = float(parameters[1]);
          else if (low_case.equals("y2")) y2 = float(parameters[1]);
          else if (low_case.equals("z2")) z2 = float(parameters[1]);
        }
      }
      if ((x2 - x1 != 0) && (y2 - y1 != 0) && (z2 - z1 != 0)) {
        Create3D.add_Box_Corners(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Box2P m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=?";

      UI_set_to_Create_Box();
    }
  }

  else if (Command_CAPITAL.equals("BOX")) {
    if (parts.length > 1) {
      int m = -1;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float dx = 6;
      float dy = 6;
      float dz = 6;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("dx")) dx = float(parameters[1]);
          else if (low_case.equals("dy")) dy = float(parameters[1]);
          else if (low_case.equals("dz")) dz = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
        }
      }
      if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_Box_Core(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Box m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?";

      UI_set_to_Create_Box();
    }
  }

  else if (Command_CAPITAL.equals("HOUSE3")) {
    if (parts.length > 1) {
      int m = -1;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float dx = 6;
      float dy = 6;
      float dz = 6;
      float h = 3;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("dx")) dx = float(parameters[1]);
          else if (low_case.equals("dy")) dy = float(parameters[1]);
          else if (low_case.equals("dz")) dz = float(parameters[1]);
          else if (low_case.equals("h")) h = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
        }
      }
      if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_House3_Core(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, h, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "House3 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?";

      UI_set_to_Create_House3();
    }
  }

  else if (Command_CAPITAL.equals("HOUSE2")) {
    if (parts.length > 1) {
      int m = -1;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float dx = 6;
      float dy = 6;
      float dz = 6;
      float h = 3;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("dx")) dx = float(parameters[1]);
          else if (low_case.equals("dy")) dy = float(parameters[1]);
          else if (low_case.equals("dz")) dz = float(parameters[1]);
          else if (low_case.equals("h")) h = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
        }
      }
      if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_House2_Core(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, h, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "House2 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?";

      UI_set_to_Create_House2();
    }
  }

  else if (Command_CAPITAL.equals("HOUSE1")) {
    if (parts.length > 1) {
      int m = -1;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float dx = 6;
      float dy = 6;
      float dz = 6;
      float h = 3;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("dx")) dx = float(parameters[1]);
          else if (low_case.equals("dy")) dy = float(parameters[1]);
          else if (low_case.equals("dz")) dz = float(parameters[1]);
          else if (low_case.equals("h")) h = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
        }
      }
      if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_House1_Core(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, h, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "House1 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?";

      UI_set_to_Create_House2();
    }
  }

  else if (Command_CAPITAL.equals("CYLINDER")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 16;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float d = 6;
      float h = 6;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("d")) d = float(parameters[1]);
          else if (low_case.equals("h")) h = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
          else if (low_case.equals("deg")) deg = int(parameters[1]);
        }
      }
      if ((d != 0) && (h != 0)) {
        Create3D.add_SuperCylinder(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, 0.5 * d, 0.5 * h, deg, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Cylinder m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?";

      UI_set_to_Create_Cylinder();
    }
  }

  else if (Command_CAPITAL.equals("SPHERE")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 3;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float d = 6;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("d")) d = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
          else if (low_case.equals("deg")) deg = int(parameters[1]);
        }
      }
      if (d != 0) {
        Create3D.add_CrystalSphere(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, deg, 0, 90 + r); // passing with isSky:0
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Sphere m=? tes=? lyr=? x=? y=? z=? d=? deg=? r=?";

      UI_set_to_Create_Sphere();
    }
  }


  else if (Command_CAPITAL.equals("SUPERSPHERE")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 3;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float dx = 6;
      float dy = 6;
      float dz = 6;
      float px = 2;
      float py = 2;
      float pz = 2;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("dx")) dx = float(parameters[1]);
          else if (low_case.equals("dy")) dy = float(parameters[1]);
          else if (low_case.equals("dz")) dz = float(parameters[1]);
          else if (low_case.equals("px")) px = float(parameters[1]);
          else if (low_case.equals("py")) py = float(parameters[1]);
          else if (low_case.equals("pz")) pz = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
          else if (low_case.equals("deg")) deg = int(parameters[1]);
        }
      }
      if ((dx != 0) && (dy != 0) && (dz != 0) && (px > 0) && (py > 0) && (pz > 0)) {
        Create3D.add_SuperSphere(m, tes, lyr, vsb, wgt, clz, x, y, z, px, py, pz, 0.5 * dx, 0.5 * dy, 0.5 * dz, deg, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "SuperSphere m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? px=? py=? pz=? deg=? r=?";

      UI_set_to_Create_Sphere();
    }
  }

  else if (Command_CAPITAL.equals("CUSHION")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 3;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float dx = 6;
      float dy = 6;
      float dz = 6;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("dx")) dx = float(parameters[1]);
          else if (low_case.equals("dy")) dy = float(parameters[1]);
          else if (low_case.equals("dz")) dz = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
          else if (low_case.equals("deg")) deg = int(parameters[1]);
        }
      }
      if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_SuperSphere(m, tes, lyr, vsb, wgt, clz, x, y, z, CubePower, CubePower, 2, 0.5 * dx, 0.5 * dy, 0.5 * dz, deg, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Cushion m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?";

      UI_set_to_Create_Cushion();
    }
  }


  else if (Command_CAPITAL.equals("OCTAHEDRON")) {
    if (parts.length > 1) {
      int m = 7;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float dx = 6;
      float dy = 6;
      float dz = 6;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("dx")) dx = float(parameters[1]);
          else if (low_case.equals("dy")) dy = float(parameters[1]);
          else if (low_case.equals("dz")) dz = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
        }
      }
      if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_Octahedron(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Octahedron m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?";

      UI_set_to_Create_Octahedron();
    }
  }

  else if (Command_CAPITAL.equals("ICOSAHEDRON")) {
    if (parts.length > 1) {
      int m = 7;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float d = 6;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("d")) d = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
        }
      }
      if (d != 0) {
        Create3D.add_Icosahedron(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Icosahedron m=? tes=? lyr=? x=? y=? z=? d=? r=?";

      UI_set_to_Create_Icosahedron();
    }
  }

  else if (Command_CAPITAL.equals("POLYGONEXTRUDE")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float d = 6;
      float h = 6;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("d")) d = float(parameters[1]);
          else if (low_case.equals("h")) h = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
          else if (low_case.equals("deg")) deg = int(parameters[1]);
        }
      }
      if ((d != 0) && (h != 0)) {
        Create3D.add_PolygonExtrude(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, h, deg, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "PolygonExtrude m=? tes=? lyr=? x=? y=? z=? d=? h=? deg=? r=?";

      UI_set_to_Create_Extrude();
    }
  }

  else if (Command_CAPITAL.equals("POLYGONHYPER")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float d = 6;
      float h = 6;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("d")) d = float(parameters[1]);
          else if (low_case.equals("h")) h = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
          else if (low_case.equals("deg")) deg = int(parameters[1]);
        }
      }
      if ((d != 0) && (h != 0)) {
        Create3D.add_PolygonHyper(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, h, deg, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "PolygonHyper m=? tes=? lyr=? x=? y=? z=? d=? h=? deg=? r=?";

      UI_set_to_Create_Hyper();
    }
  }

  else if (Command_CAPITAL.equals("POLYGONMESH")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float d = 6;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("d")) d = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
          else if (low_case.equals("deg")) deg = int(parameters[1]);
        }
      }
      if (d != 0) {
        Create3D.add_PolygonMesh(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, deg, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "PolygonMesh m=? tes=? lyr=? x=? y=? z=? d=? deg=? r=?";

      UI_set_to_Create_Plane();
    }
  }

  else if (Command_CAPITAL.equals("MESH2")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x1 = 0;
      float y1 = 0;
      float z1 = 0;
      float x2 = 0;
      float y2 = 0;
      float z2 = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x1")) x1 = float(parameters[1]);
          else if (low_case.equals("y1")) y1 = float(parameters[1]);
          else if (low_case.equals("z1")) z1 = float(parameters[1]);
          else if (low_case.equals("x2")) x2 = float(parameters[1]);
          else if (low_case.equals("y2")) y2 = float(parameters[1]);
          else if (low_case.equals("z2")) z2 = float(parameters[1]);
        }
      }
      if ((x1 == x2) || (y1 == y2) || (z1 == z2)) {
        Create3D.add_Mesh2(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Mesh2 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=?";
    }
  }

  else if (Command_CAPITAL.equals("MESH3")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x1 = 0;
      float y1 = 0;
      float z1 = 0;
      float x2 = 0;
      float y2 = 0;
      float z2 = 0;
      float x3 = 0;
      float y3 = 0;
      float z3 = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x1")) x1 = float(parameters[1]);
          else if (low_case.equals("y1")) y1 = float(parameters[1]);
          else if (low_case.equals("z1")) z1 = float(parameters[1]);
          else if (low_case.equals("x2")) x2 = float(parameters[1]);
          else if (low_case.equals("y2")) y2 = float(parameters[1]);
          else if (low_case.equals("z2")) z2 = float(parameters[1]);
          else if (low_case.equals("x3")) x3 = float(parameters[1]);
          else if (low_case.equals("y3")) y3 = float(parameters[1]);
          else if (low_case.equals("z3")) z3 = float(parameters[1]);
        }
      }
      {
        Create3D.add_Mesh3(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Mesh3 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=?";
    }
  }

  else if (Command_CAPITAL.equals("MESH4")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x1 = 0;
      float y1 = 0;
      float z1 = 0;
      float x2 = 0;
      float y2 = 0;
      float z2 = 0;
      float x3 = 0;
      float y3 = 0;
      float z3 = 0;
      float x4 = 0;
      float y4 = 0;
      float z4 = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x1")) x1 = float(parameters[1]);
          else if (low_case.equals("y1")) y1 = float(parameters[1]);
          else if (low_case.equals("z1")) z1 = float(parameters[1]);
          else if (low_case.equals("x2")) x2 = float(parameters[1]);
          else if (low_case.equals("y2")) y2 = float(parameters[1]);
          else if (low_case.equals("z2")) z2 = float(parameters[1]);
          else if (low_case.equals("x3")) x3 = float(parameters[1]);
          else if (low_case.equals("y3")) y3 = float(parameters[1]);
          else if (low_case.equals("z3")) z3 = float(parameters[1]);
          else if (low_case.equals("x4")) x4 = float(parameters[1]);
          else if (low_case.equals("y4")) y4 = float(parameters[1]);
          else if (low_case.equals("z4")) z4 = float(parameters[1]);
        }
      }
      {
        Create3D.add_Mesh4(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Mesh4 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=? x4=? y4=? z4=?";
    }
  }

  else if (Command_CAPITAL.equals("MESH5")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x1 = 0;
      float y1 = 0;
      float z1 = 0;
      float x2 = 0;
      float y2 = 0;
      float z2 = 0;
      float x3 = 0;
      float y3 = 0;
      float z3 = 0;
      float x4 = 0;
      float y4 = 0;
      float z4 = 0;
      float x5 = 0;
      float y5 = 0;
      float z5 = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x1")) x1 = float(parameters[1]);
          else if (low_case.equals("y1")) y1 = float(parameters[1]);
          else if (low_case.equals("z1")) z1 = float(parameters[1]);
          else if (low_case.equals("x2")) x2 = float(parameters[1]);
          else if (low_case.equals("y2")) y2 = float(parameters[1]);
          else if (low_case.equals("z2")) z2 = float(parameters[1]);
          else if (low_case.equals("x3")) x3 = float(parameters[1]);
          else if (low_case.equals("y3")) y3 = float(parameters[1]);
          else if (low_case.equals("z3")) z3 = float(parameters[1]);
          else if (low_case.equals("x4")) x4 = float(parameters[1]);
          else if (low_case.equals("y4")) y4 = float(parameters[1]);
          else if (low_case.equals("z4")) z4 = float(parameters[1]);
          else if (low_case.equals("x5")) x5 = float(parameters[1]);
          else if (low_case.equals("y5")) y5 = float(parameters[1]);
          else if (low_case.equals("z5")) z5 = float(parameters[1]);
        }
      }
      {
        Create3D.add_Mesh5(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, x5, y5, z5);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Mesh5 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=? x4=? y4=? z4=? x5=? y5=? z5=?";
    }
  }

  else if (Command_CAPITAL.equals("MESH6")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x1 = 0;
      float y1 = 0;
      float z1 = 0;
      float x2 = 0;
      float y2 = 0;
      float z2 = 0;
      float x3 = 0;
      float y3 = 0;
      float z3 = 0;
      float x4 = 0;
      float y4 = 0;
      float z4 = 0;
      float x5 = 0;
      float y5 = 0;
      float z5 = 0;
      float x6 = 0;
      float y6 = 0;
      float z6 = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x1")) x1 = float(parameters[1]);
          else if (low_case.equals("y1")) y1 = float(parameters[1]);
          else if (low_case.equals("z1")) z1 = float(parameters[1]);
          else if (low_case.equals("x2")) x2 = float(parameters[1]);
          else if (low_case.equals("y2")) y2 = float(parameters[1]);
          else if (low_case.equals("z2")) z2 = float(parameters[1]);
          else if (low_case.equals("x3")) x3 = float(parameters[1]);
          else if (low_case.equals("y3")) y3 = float(parameters[1]);
          else if (low_case.equals("z3")) z3 = float(parameters[1]);
          else if (low_case.equals("x4")) x4 = float(parameters[1]);
          else if (low_case.equals("y4")) y4 = float(parameters[1]);
          else if (low_case.equals("z4")) z4 = float(parameters[1]);
          else if (low_case.equals("x5")) x5 = float(parameters[1]);
          else if (low_case.equals("y5")) y5 = float(parameters[1]);
          else if (low_case.equals("z5")) z5 = float(parameters[1]);
          else if (low_case.equals("x6")) x6 = float(parameters[1]);
          else if (low_case.equals("y6")) y6 = float(parameters[1]);
          else if (low_case.equals("z6")) z6 = float(parameters[1]);
        }
      }
      {
        Create3D.add_Mesh6(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, x5, y5, z5, x6, y6, z6);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Mesh6 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=? x4=? y4=? z4=? x5=? y5=? z5=? x6=? y6=? z6=?";
    }
  }

  else if (Command_CAPITAL.equals("H_SHADE")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float d = 0;
      float w = 0;
      float a = 0;
      float b = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("d")) d = float(parameters[1]);
          else if (low_case.equals("w")) w = float(parameters[1]);
          else if (low_case.equals("a")) a = float(parameters[1]);
          else if (low_case.equals("b")) b = float(parameters[1]);
        }
      }
      if ((d != 0) && (w != 0)) {
        Create3D.add_H_shade(m, tes, lyr, vsb, wgt, clz, x, y, z, d, w, a, b);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "H_Shade m=? tes=? lyr=? x=? y=? z=? d=? w=? a=? b=?";
    }
  }

  else if (Command_CAPITAL.equals("V_SHADE")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float d = 0;
      float h = 0;
      float a = 0;
      float b = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("d")) d = float(parameters[1]);
          else if (low_case.equals("h")) h = float(parameters[1]);
          else if (low_case.equals("a")) a = float(parameters[1]);
          else if (low_case.equals("b")) b = float(parameters[1]);
        }
      }
      if ((d != 0) && (h != 0)) {
        Create3D.add_V_shade(m, tes, lyr, vsb, wgt, clz, x, y, z, h, d, a, b);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "V_Shade m=? tes=? lyr=? x=? y=? z=? d=? h=? a=? b=?";
    }
  }

  else if (Command_CAPITAL.equals("SOLID")) {
    if (parts.length > 1) {
      float v = 1;
      float x = 0;
      float y = 0;
      float z = 0;
      float px = 2;
      float py = 2;
      float pz = 2;
      float sx = 1;
      float sy = 1;
      float sz = 1;
      float rx = 0;
      float ry = 0;
      float rz = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("v")) v = float(parameters[1]);
          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("px")) px = float(parameters[1]);
          else if (low_case.equals("py")) py = float(parameters[1]);
          else if (low_case.equals("pz")) pz = float(parameters[1]);
          else if (low_case.equals("sx")) sx = float(parameters[1]);
          else if (low_case.equals("sy")) sy = float(parameters[1]);
          else if (low_case.equals("sz")) sz = float(parameters[1]);
          else if (low_case.equals("rx")) rx = float(parameters[1]);
          else if (low_case.equals("ry")) ry = float(parameters[1]);
          else if (low_case.equals("rz")) rz = float(parameters[1]);
        }
      }
      if ((px != 0) && (py != 0) && (pz != 0) && (sx != 0) && (sy != 0) && (sz != 0) && (v != 0)) {
        allSolids.create(x, y, z, px, py, pz, sx, sy, sz, rx, ry, rz, v);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Solid x=? y=? z=? px=? py=? pz=? sx=? sy=? sz=? rx=? ry=? rz=? v=?";

      UI_set_to_Create_Solid();
    }
  }

  else if (Command_CAPITAL.equals("SECTION")) {
    if (parts.length > 1) {

      float x = 0;
      float y = 0;
      float z = 0;
      float r = 0;
      float u = 20;
      float v = 20;

      int t = 1;
      int i = 200;
      int j = 200;

      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
          else if (low_case.equals("u")) u = float(parameters[1]);
          else if (low_case.equals("v")) v = float(parameters[1]);
          else if (low_case.equals("t")) t = int(parameters[1]);
          else if (low_case.equals("i")) i = int(parameters[1]);
          else if (low_case.equals("j")) j = int(parameters[1]);

        }
      }
      if ((t > 0) && (i > 0) && (j > 0) && (u > 0) && (v > 0)) {
        allSections.create(x, y, z, r, u, v, t, i, j);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Section x=? y=? z=? r=? u=? v=? t=? i=? j=?";

      UI_set_to_Create_Section();
    }
  }

  else if (Command_CAPITAL.equals("CAMERA")) {
    if (parts.length > 1) {

      float px = 0;
      float py = 0;
      float pz = 0;
      float pt = 1;
      float rx = 0;
      float ry = 0;
      float rz = 0;
      float rt = 5;
      float a = 60;
      int t = 1;

      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("px")) px = float(parameters[1]);
          else if (low_case.equals("py")) py = float(parameters[1]);
          else if (low_case.equals("pz")) pz = float(parameters[1]);
          else if (low_case.equals("pt")) pt = float(parameters[1]);
          else if (low_case.equals("rx")) rx = float(parameters[1]);
          else if (low_case.equals("ry")) ry = float(parameters[1]);
          else if (low_case.equals("rz")) rz = float(parameters[1]);
          else if (low_case.equals("rt")) rt = float(parameters[1]);
          else if (low_case.equals("a")) a = float(parameters[1]);
          else if (low_case.equals("t")) t = int(parameters[1]);
        }
      }
      if (a != 0) {
        allCameras.create(px, py, pz, pt, rx, ry, rz, rt, a, t);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Camera px=? py=? pz=? pt=? rx=? ry=? rz=? rt=? a=? t=?";

      UI_set_to_Create_Camera();
    }
  }

  else if (Command_CAPITAL.equals("PLOYLINE")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
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
  }

  else if (Command_CAPITAL.equals("ARC")) {
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
  }

  else if (Command_CAPITAL.equals("PIVOT")) {
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
  }

  else if (Command_CAPITAL.equals("VERTEX>GROUP")) {
    Select3D.convert_Vertices_to_Groups();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("FACE>GROUP")) {
    Select3D.convert_Faces_to_Groups();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("GROUP>FACE")) {
    Select3D.convert_Groups_to_Faces();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("POLYLINE>GROUP")) {
    Select3D.convert_Polylines_to_Groups();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("GROUP>POLYLINE")) {
    Select3D.convert_Groups_to_Polylines();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("POLYLINE>VERTEX")) {
    Select3D.convert_Polylines_to_Vertices();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("VERTEX>POLYLINE")) {
    Select3D.convert_Vertices_to_Polylines();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("GROUP>VERTEX")) {
    Select3D.convert_Groups_to_Vertices();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("FACE>VERTEX")) {
    Select3D.convert_Faces_to_Vertices();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("VERTEX>FACE")) {
    Select3D.convert_Vertices_to_Faces();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("SOLID>GROUP")) {
    Select3D.convert_Solids_to_Groups();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("GROUP>SOLID")) {
    Select3D.convert_Groups_to_Solids();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("2D>GROUP")) {
    Select3D.convert_Model2Ds_to_Groups();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("GROUP>2D")) {
    Select3D.convert_Groups_to_Model2Ds();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("1D>GROUP")) {
    Select3D.convert_Model1Ds_to_Groups();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("GROUP>1D")) {
    Select3D.convert_Groups_to_Model1Ds();
    SOLARCHVISION_view_changed();
  }

  else if (Command_CAPITAL.equals("DISTZ")) {
    UI_set_to_View_Truck(0);
  }
  else if (Command_CAPITAL.equals("DISTC")) {
    UI_set_to_View_CameraDistance(0);
  }
  else if (Command_CAPITAL.equals("DISTP")) {
    UI_set_to_View_DistMouseXY(0);
  }


  else if (Command_CAPITAL.equals("SIZEALL")) {
    UI_set_to_View_AllModelSize();
  }
  else if (Command_CAPITAL.equals("SIZESKY")) {
    UI_set_to_View_SkydomeSize();
  }
  else if (Command_CAPITAL.equals("SIZE3D")) {
    UI_set_to_View_3DModelSize();
  }

  else if (Command_CAPITAL.equals("ALLVIEWPORTS")) {
    UI_set_to_Viewport(0);
  }
  else if (Command_CAPITAL.equals("ENLARGE3D")) {
    UI_set_to_Viewport(1);
  }

  else if (Command_CAPITAL.equals("LOOKORG")) {
    UI_set_to_View_LookAtOrigin(0);
  }
  else if (Command_CAPITAL.equals("LOOKDIR")) {
    UI_set_to_View_LookAtDirection(0);
  }
  else if (Command_CAPITAL.equals("LOOKSEL")) {
    UI_set_to_View_LookAtSelection(0);
  }

  else if (Command_CAPITAL.equals("TRUCKZ")) {
    UI_set_to_View_Truck(0);
  }
  else if (Command_CAPITAL.equals("TRUCKX")) {
    UI_set_to_View_Truck(1);
  }
  else if (Command_CAPITAL.equals("TRUCKY")) {
    UI_set_to_View_Truck(2);
  }

  else if (Command_CAPITAL.equals("TARGETROLL")) {
    UI_set_to_View_TargetRoll(0);
  }
  else if (Command_CAPITAL.equals("TARGETROLLZ")) {
    UI_set_to_View_TargetRoll(1);
  }
  else if (Command_CAPITAL.equals("TARGETROLLXY")) {
    UI_set_to_View_TargetRoll(2);
  }

  else if (Command_CAPITAL.equals("CAMERAROLL")) {
    UI_set_to_View_CameraRoll(0);
  }
  else if (Command_CAPITAL.equals("CAMERAROLLZ")) {
    UI_set_to_View_CameraRoll(1);
  }
  else if (Command_CAPITAL.equals("CAMERAROLLXY")) {
    UI_set_to_View_CameraRoll(2);
  }


  else if (Command_CAPITAL.equals("ORBIT")) {
    UI_set_to_View_Orbit(0);
  }
  else if (Command_CAPITAL.equals("ORBITZ")) {
    UI_set_to_View_Orbit(1);
  }
  else if (Command_CAPITAL.equals("ORBITXY")) {
    UI_set_to_View_Orbit(2);
  }

  else if (Command_CAPITAL.equals("LANDORBIT")) {
    UI_set_to_View_LandOrbit(0);
  }

  else if (Command_CAPITAL.equals("PAN")) {
    UI_set_to_View_Pan(0);
  }
  else if (Command_CAPITAL.equals("PANX")) {
    UI_set_to_View_Pan(1);
  }
  else if (Command_CAPITAL.equals("PANY")) {
    UI_set_to_View_Pan(2);
  }

  else if (Command_CAPITAL.equals("ZOOM")) {
    UI_set_to_View_ZOOM(0);
  }
  else if (Command_CAPITAL.equals("NORMALZOOM")) {
    UI_set_to_View_ZOOM(1);
  }
  else if (Command_CAPITAL.equals("ORTHOGRAPHIC")) {
    UI_set_to_View_ProjectionType(0);
  }
  else if (Command_CAPITAL.equals("PERSPECTIVE")) {
    UI_set_to_View_ProjectionType(1);
  }
  else if (Command_CAPITAL.equals("TOP")) {
    UI_set_to_View_3DViewPoint(0);
  }
  else if (Command_CAPITAL.equals("FRONT")) {
    UI_set_to_View_3DViewPoint(1);
  }
  else if (Command_CAPITAL.equals("LEFT")) {
    UI_set_to_View_3DViewPoint(2);
  }
  else if (Command_CAPITAL.equals("BACK")) {
    UI_set_to_View_3DViewPoint(3);
  }
  else if (Command_CAPITAL.equals("RIGHT")) {
    UI_set_to_View_3DViewPoint(4);
  }
  else if (Command_CAPITAL.equals("BOTTOM")) {
    UI_set_to_View_3DViewPoint(5);
  }
  else if (Command_CAPITAL.equals("S.W.")) {
    UI_set_to_View_3DViewPoint(6);
  }
  else if (Command_CAPITAL.equals("S.E.")) {
    UI_set_to_View_3DViewPoint(7);
  }
  else if (Command_CAPITAL.equals("N.E.")) {
    UI_set_to_View_3DViewPoint(8);
  }
  else if (Command_CAPITAL.equals("N.W.")) {
    UI_set_to_View_3DViewPoint(9);
  }


  else if (Command_CAPITAL.equals("SHADE.WIRE")) {
    WIN3D.FacesShade = SHADE.Surface_Wire;
    allFaces.displayEdges = true; //<<<<<<<<<<<<<<<
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("SHADE.BASE")) {
    WIN3D.FacesShade = SHADE.Surface_Base;
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("SHADE.WHITE")) {
    WIN3D.FacesShade = SHADE.Surface_White;
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("SHADE.MATERIALS")) {
    WIN3D.FacesShade = SHADE.Surface_Materials;
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("SHADE.GLOBAL")) {
    WIN3D.FacesShade = SHADE.Global_Solar;
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("SHADE.REAL")) {
    WIN3D.FacesShade = SHADE.Vertex_Solar;
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("SHADE.SOLID")) {
    WIN3D.FacesShade = SHADE.Vertex_Solid;
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("SHADE.ELEVATION")) {
    WIN3D.FacesShade = SHADE.Vertex_Elevation;
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("RENDER.VIEWPORT")) {
    SOLARCHVISION_RenderViewport();
  }
  else if (Command_CAPITAL.equals("PREBAKE.VIEWPORT")) {
    SOLARCHVISION_preBakeViewport();
  }


  else if (Command_CAPITAL.equals("LONLAT")) {
    if (parts.length > 2) {

      STATION.setLatitude(float(parts[2]));
      STATION.setLongitude(float(parts[1]));

      SOLARCHVISION_update_station(1);
    }
    else {
      return_message = "LonLat ? ?";
    }
  }


  return return_message;
}
