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

// Lets the person importing check/uncheck ifcImportFurniture/
// ifcImportOrient/ifcImportRelocate/ifcImportIndoorSpace/
// ifcImportOutdoorSpace (see import_objects_IFC.pde's own
// IFC_IMPORT_FURNITURE/IFC_IMPORT_NORTH/IFC_IMPORT_GOTO_LATLON/
// IFC_IMPORT_INDOOR_SPACE/IFC_IMPORT_OUTDOOR_SPACE - these five
// variables are what actually gets checked at import time, those
// constants are only their starting values). Called from
// import_objects_IFC() itself, not from here - see
// ifcImportShowOptionsDialog's own comment in import_objects_IFC.pde
// for exactly when, and why that's after a file's already been picked
// rather than before. A plain Swing dialog (JCheckBox in a JOptionPane)
// rather than one of this app's own custom-drawn rollouts: selectInput()
// below already shows a native/Swing file chooser the exact same way,
// so this fits right in as "one more standard system dialog in the same
// flow", and - unlike a rollout - needs nothing from WIN3D's own render
// loop. Returns false on Cancel/the dialog's own close button -
// import_objects_IFC() treats that as "don't import, at all", the same
// as cancelling the file chooser itself would have.
boolean ifcShowImportOptionsDialog () {

  javax.swing.JCheckBox furnitureBox = new javax.swing.JCheckBox("Import furniture", ifcImportFurniture);
  javax.swing.JCheckBox orientBox = new javax.swing.JCheckBox("Rotate to the project's true north", ifcImportOrient);
  javax.swing.JCheckBox relocateBox = new javax.swing.JCheckBox("Navigate to the file's own location (latitude/longitude)", ifcImportRelocate);
  javax.swing.JCheckBox indoorSpaceBox = new javax.swing.JCheckBox("Import indoor spaces (rooms/zones)", ifcImportIndoorSpace);
  javax.swing.JCheckBox outdoorSpaceBox = new javax.swing.JCheckBox("Import outdoor spaces (courtyards, terraces)", ifcImportOutdoorSpace);

  javax.swing.JPanel panel = new javax.swing.JPanel(new java.awt.GridLayout(0, 1));
  panel.add(furnitureBox);
  panel.add(orientBox);
  panel.add(relocateBox);
  panel.add(indoorSpaceBox);
  panel.add(outdoorSpaceBox);

  int result = javax.swing.JOptionPane.showConfirmDialog(
    null, panel, "IFC import options", javax.swing.JOptionPane.OK_CANCEL_OPTION, javax.swing.JOptionPane.PLAIN_MESSAGE);

  if (result != javax.swing.JOptionPane.OK_OPTION) return false;

  // Each one left exactly where it was (ifcImportFurniture's own
  // current value, etc.) unless this dialog's own OK button is actually
  // pressed - a cancelled dialog must never half-apply a choice.
  ifcImportFurniture = furnitureBox.isSelected();
  ifcImportOrient = orientBox.isSelected();
  ifcImportRelocate = relocateBox.isSelected();
  ifcImportIndoorSpace = indoorSpaceBox.isSelected();
  ifcImportOutdoorSpace = outdoorSpaceBox.isSelected();

  return true;
}

void selectFile_ImportIfc () {
  // Arms ifcImportShowOptionsDialog (import_objects_IFC.pde) so the
  // options dialog shows once the file this picks is actually about to
  // be imported, not here - see that variable's own comment for why.
  ifcImportShowOptionsDialog = true;
  selectInput("Select IFC file to import:", "_fileSelected_ImportIfc", new File(Folder_Import + "/_.ifc"));
}

void selectFile_RunScript () {
  selectInput("Select SVS file to execute:", "_fileSelected_RunScript", new File(Folder_Import + "/_.svs"));
}


void update_project_info (File selectedFile) {

  ProjectName = selectedFile.getName().replace(".xml", "").replace(".XML", ""); // should work most of the times!
  Folder_Project =  selectedFile.getAbsolutePath().replace(char(92), '/').replace("/" + selectedFile.getName(), "");

  println("\nNew ProjectName:", ProjectName);
  println("New Folder_Project:", Folder_Project);

  update_project_folders();
}

void _fileSelected_New (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
  } else {
    Filename = _getSelectedFile(selectedFile);

    println("\nNew project:", Filename);

    update_project_info(selectedFile);
  }
}

void _fileSelected_Open (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
  } else {
    Filename = _getSelectedFile(selectedFile);

    //println("\nLoading:", Filename);

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

    println("\nSaving to:", Filename);

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

    println("\nImporting:", Filename);

    int number_of_allGroups_before = allGroups.num;

    //import_objects_OBJ(Filename, -1,0,0,1,0,0, 0,0,0, 1,1,1); // different objects: different materials
    import_objects_OBJ(Filename, User3D.creatorMaterial, User3D.creatorTessellation, User3D.creatorLayer, User3D.creatorVisibility, User3D.creatorWeight, User3D.creatorClosed, 0, 0, 0, 1, 1, 1); // apply default material

    // import_objects_OBJ() adds faces straight into allFaces without ever
    // calling model_changed() itself - without this, the imported geometry
    // would never bump allFaces.winCacheGeneration (see Faces.pde's WIN3D
    // retained-mode cache) and so would never actually appear in WIN3D:
    // switch_category() below still triggers a redraw via its own
    // view_changed(), but that redraw would just replay the stale,
    // pre-import cached PShape.
    model_changed();

    int number_of_allGroups_after = allGroups.num;

    Select3D.groupSelection = new int [1 + number_of_allGroups_after - number_of_allGroups_before];
    for (int i = 0; i < Select3D.groupSelection.length - 1; i++) {
      Select3D.groupSelection[i] = i + number_of_allGroups_before;
    }

    switch_category(ObjectCategory.GROUP);
  }
}

void _fileSelected_ImportIfc (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
    // Cancelling the native file chooser itself never reaches
    // import_objects_IFC(), which is otherwise what consumes
    // ifcImportShowOptionsDialog (see that variable's own comment) -
    // without this, it would stay armed and pop the options dialog up
    // on the next import_objects_IFC() call regardless of how that one
    // was started, including a later non-interactive one (a script's
    // own IMPORT_IFC command with a path already given).
    ifcImportShowOptionsDialog = false;
  } else {
    Filename = _getSelectedFile(selectedFile);

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("\nImporting:", Filename);

    int number_of_allGroups_before = allGroups.num;

    // Like import_objects_OBJ() above, import_objects_IFC() adds faces
    // straight into allFaces (see ifcEmitFace()'s own comment for why)
    // and calls model_changed() itself exactly once, at the very end of
    // the whole import - so no extra call is needed here either.
    import_objects_IFC(Filename, User3D.creatorMaterial, User3D.creatorTessellation, User3D.creatorLayer, User3D.creatorVisibility, User3D.creatorWeight, User3D.creatorClosed, 0, 0, 0, 1, 1, 1); // apply default material

    int number_of_allGroups_after = allGroups.num;

    Select3D.groupSelection = new int [1 + number_of_allGroups_after - number_of_allGroups_before];
    for (int i = 0; i < Select3D.groupSelection.length - 1; i++) {
      Select3D.groupSelection[i] = i + number_of_allGroups_before;
    }

    switch_category(ObjectCategory.GROUP);
  }
}

void _fileSelected_RunScript (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
  } else {
    Filename = _getSelectedFile(selectedFile);

    println("\nExecuting:", Filename);

    runScriptFile(Filename);
  }
}

String _getSelectedFile(File selectedFile) {
  return selectedFile.getAbsolutePath().replace(char(92), '/');
}
