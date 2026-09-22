void selectFile_New () {
  selectInput("Specify project name:", "_fileSelected_New", new File(Folder_Project + "/_.xml"));
}

void selectFile_Open () {
  selectInput("Select a file to open:", "_fileSelected_Open", new File(Folder_Project + "/_.xml"));
}

void selectFile_SaveAs () {
  selectOutput("Select a file to write to:", "_fileSelected_SaveAs", new File(Folder_Project + "/_.xml"));
}

void selectFile_ImportObj () {
  selectInput("Select OBJ file to import:", "_fileSelected_ImportObj", new File(Folder_Import + "/_.obj"));
}

void selectFile_RunScript () {
  selectInput("Select TXT file to execute:", "_fileSelected_RunScript", new File(Folder_Command + "/_.txt"));
}


void update_project_info (File selectedFile) {

  ProjectName = selectedFile.getName().replace(".xml", "").replace(".XML", ""); // should work most of the times!
  Folder_Project =  selectedFile.getAbsolutePath().replace(char(92), '/').replace("/" + selectedFile.getName(), "");

  println("New ProjectName:", ProjectName);
  println("New Folder_Project:", Folder_Project);

  update_project_folders();
}

void _fileSelected_New (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
  } else {
    Filename = _getSelectedFile(selectedFile);

    println("New project:", Filename);

    update_project_info(selectedFile);
  }
}

void _fileSelected_Open (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
  } else {
    Filename = _getSelectedFile(selectedFile);

    println("Loading:", Filename);

    noLoop();

    load_project(Filename);

    update_project_info(selectedFile);

    loop();
  }
}

void _fileSelected_SaveAs (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
  } else {
    Filename = _getSelectedFile(selectedFile);

    println("Saving to:", Filename);

    update_project_info(selectedFile);

    saveProject(Filename);
  }
}

void _fileSelected_ImportObj (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
  } else {
    Filename = _getSelectedFile(selectedFile);

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("Importing:", Filename);

    int number_of_allGroups_before = allGroups.num;

    //import_objects_OBJ(Filename, -1,0,0,1,0,0, 0,0,0, 1,1,1); // different objects: different materials
    import_objects_OBJ(Filename, User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, 0, 0, 0, 1, 1, 1); // apply default material

    int number_of_allGroups_after = allGroups.num;

    Select3D.Group_ids = new int [1 + number_of_allGroups_after - number_of_allGroups_before];
    for (int i = 0; i < Select3D.Group_ids.length - 1; i++) {
      Select3D.Group_ids[i] = i + number_of_allGroups_before;
      //println(Select3D.Group_ids[i]);
    }

    switch_category(ObjectCategory.GROUP);
  }
}

void _fileSelected_RunScript (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
  } else {
    Filename = _getSelectedFile(selectedFile);

    println("Executing:", Filename);

    runScriptFile(Filename);
  }
}

String _getSelectedFile(File selectedFile) {
  return selectedFile.getAbsolutePath().replace(char(92), '/');
}
