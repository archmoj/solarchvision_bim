void SOLARCHVISION_update_project_info (File selectedFile) {

  ProjectName = selectedFile.getName().replace(".xml", "").replace(".XML", ""); // should work most of the times!
  Folder_Project =  selectedFile.getAbsolutePath().replace(char(92), '/').replace("/" + selectedFile.getName(), "");

  println("New ProjectName:", ProjectName);
  println("New Folder_Project:", Folder_Project);

  SOLARCHVISION_update_project_folders();
}

void SOLARCHVISION_fileSelected_New (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
  } else {
    Filename = _getSelectedFile(selectedFile);

    println("New project:", Filename);

    SOLARCHVISION_update_project_info(selectedFile);
  }
}

void SOLARCHVISION_fileSelected_Open (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
  } else {
    Filename = _getSelectedFile(selectedFile);

    println("Loading:", Filename);

    noLoop();

    SOLARCHVISION_load_project(Filename);

    SOLARCHVISION_update_project_info(selectedFile);

    loop();
  }
}

void SOLARCHVISION_fileSelected_SaveAs (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
  } else {
    Filename = _getSelectedFile(selectedFile);

    println("Saving to:", Filename);

    SOLARCHVISION_update_project_info(selectedFile);

    SOLARCHVISION_save_project(Filename);
  }
}

void SOLARCHVISION_SelectFile_Import_3DModel (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
  } else {
    Filename = _getSelectedFile(selectedFile);

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("Importing:", Filename);

    int number_of_allGroups_before = allGroups.num;

    //SOLARCHVISION_import_objects_OBJ(Filename, -1,0,0,1,0,0, 0,0,0, 1,1,1); // different objects: different materials
    SOLARCHVISION_import_objects_OBJ(Filename, User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, 0, 0, 0, 1, 1, 1); // apply default material

    int number_of_allGroups_after = allGroups.num;

    Select3D.Group_ids = new int [1 + number_of_allGroups_after - number_of_allGroups_before];
    for (int i = 0; i < Select3D.Group_ids.length - 1; i++) {
      Select3D.Group_ids[i] = i + number_of_allGroups_before;
      //println(Select3D.Group_ids[i]);
    }

    SOLARCHVISION_switch_category(ObjectCategory.GROUP);
  }
}

void SOLARCHVISION_SelectFile_Execute_CommandFile (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
  } else {
    Filename = _getSelectedFile(selectedFile);

    println("Executing:", Filename);

    SOLARCHVISION_execute_commands_TXT(Filename);
  }
}

String _getSelectedFile(File selectedFile) {
  return selectedFile.getAbsolutePath().replace(char(92), '/');
}
