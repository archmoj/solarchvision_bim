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
  // Arms objImportShowOptionsDialog (importObj.pde) the same
  // way selectFile_ImportIfc() below arms ifcImportShowOptionsDialog for
  // its own five options.
  objImportShowOptionsDialog = true;
  selectInput("Select OBJ file to import:", "_fileSelected_ImportObj", new File(Folder_Import + "/_.obj"));
}

void selectFile_ImportGlb () {
  // Arms glbImportShowOptionsDialog (importGlb.pde) the same way.
  glbImportShowOptionsDialog = true;
  selectInput("Select GLB file to import:", "_fileSelected_ImportGlb", new File(Folder_Import + "/_.glb"));
}

void selectFile_ImportStl () {
  // Arms stlImportShowOptionsDialog (importStl.pde) the same way.
  stlImportShowOptionsDialog = true;
  selectInput("Select STL file to import:", "_fileSelected_ImportStl", new File(Folder_Import + "/_.stl"));
}

void selectFile_ImportDxf () {
  // Arms dxfImportShowOptionsDialog (importDxf.pde) the same way.
  dxfImportShowOptionsDialog = true;
  selectInput("Select DXF file to import:", "_fileSelected_ImportDxf", new File(Folder_Import + "/_.dxf"));
}

void selectFile_ImportPly () {
  // Arms plyImportShowOptionsDialog (importPly.pde) the same way.
  plyImportShowOptionsDialog = true;
  selectInput("Select PLY file to import:", "_fileSelected_ImportPly", new File(Folder_Import + "/_.ply"));
}

void selectFile_ImportDae () {
  // Arms daeImportShowOptionsDialog (importDae.pde) the same way.
  daeImportShowOptionsDialog = true;
  selectInput("Select DAE file to import:", "_fileSelected_ImportDae", new File(Folder_Import + "/_.dae"));
}

// Whether to rotate the file's own Y-up axis convention into this app's
// own (commonly Z-up) one - see importObj.pde's own
// "allPoints.create(x, -z, y)" vs "allPoints.create(x, y, z)" comment,
// and importGlb.pde's/importStl.pde's/import
// Dxf.pde's/importPly.pde's/importDae.pde's matching
// ones, for why this is off by default and shared across all six
// formats: none of OBJ/STL/DXF/PLY/DAE has a single, reliably-declared
// up-axis of its own (DAE's <up_axis> is read nowhere in this version -
// see importDae.pde's own header comment for why), and keeping
// every importer's axis treatment consistent with the others matters
// more than any one of them being "correct" in isolation - this one
// checkbox lets the PERSON importing decide, per import, rather than any
// importer silently guessing.
boolean importSwapAxisYZ = false;

// Shared by OBJ/GLB/STL/DXF/PLY/DAE (one option, one checkbox) since
// that's exactly the axis convention they already agree to share - see
// importObj.pde's/importGlb.pde's/importStl.
// pde's/importDxf.pde's/importPly.pde's/import_
// objects_DAE.pde's own objImportShowOptionsDialog/
// glbImportShowOptionsDialog/stlImportShowOptionsDialog/
// dxfImportShowOptionsDialog/plyImportShowOptionsDialog/
// daeImportShowOptionsDialog for how each arms this the same way
// ifcImportShowOptionsDialog (below) arms IFC's own five-option version
// of the same dialog.
boolean axisSwapShowImportOptionsDialog (String title) {

  javax.swing.JCheckBox swapAxisBox = new javax.swing.JCheckBox("Rotate Y-up to Z-up (swap Y/Z axes)", importSwapAxisYZ);

  javax.swing.JPanel panel = new javax.swing.JPanel(new java.awt.GridLayout(0, 1));
  panel.add(swapAxisBox);

  int result = javax.swing.JOptionPane.showConfirmDialog(
    null, panel, title, javax.swing.JOptionPane.OK_CANCEL_OPTION, javax.swing.JOptionPane.PLAIN_MESSAGE);

  if (result != javax.swing.JOptionPane.OK_OPTION) return false;

  // Left exactly where it was unless this dialog's own OK button is
  // actually pressed - a cancelled dialog must never half-apply a choice
  // (same reasoning as ifcShowImportOptionsDialog's own comment below).
  importSwapAxisYZ = swapAxisBox.isSelected();

  return true;
}

// Lets the person importing check/uncheck ifcImportFurniture/
// ifcImportOrient/ifcImportRelocate/ifcImportIndoorSpace/
// ifcImportOutdoorSpace (see importIfc.pde's own
// IFC_IMPORT_FURNITURE/IFC_IMPORT_NORTH/IFC_IMPORT_GOTO_LATLON/
// IFC_IMPORT_INDOOR_SPACE/IFC_IMPORT_OUTDOOR_SPACE - these five
// variables are what actually gets checked at import time, those
// constants are only their starting values). Called from
// import_objects_IFC() itself, not from here - see
// ifcImportShowOptionsDialog's own comment in importIfc.pde
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
  // Arms ifcImportShowOptionsDialog (importIfc.pde) so the
  // options dialog shows once the file this picks is actually about to
  // be imported, not here - see that variable's own comment for why.
  ifcImportShowOptionsDialog = true;
  selectInput("Select IFC file to import:", "_fileSelected_ImportIfc", new File(Folder_Import + "/_.ifc"));
}

// Lets the person importing check/uncheck gbxmlImportOrient/
// gbxmlImportRelocate (see importGbxml.pde's own
// GBXML_IMPORT_NORTH/GBXML_IMPORT_GOTO_LATLON - these two variables are
// what actually gets checked at import time, those constants are only
// their starting values). Called from import_objects_GBXML() itself,
// not from here - same reasoning, and the same "a cancelled dialog
// must never half-apply a choice" behavior, as ifcShowImportOptionsDialog()'s
// own comment just above.
boolean gbxmlShowImportOptionsDialog () {

  javax.swing.JCheckBox orientBox = new javax.swing.JCheckBox("Rotate to the project's true north", gbxmlImportOrient);
  javax.swing.JCheckBox relocateBox = new javax.swing.JCheckBox("Navigate to the file's own location (latitude/longitude)", gbxmlImportRelocate);

  javax.swing.JPanel panel = new javax.swing.JPanel(new java.awt.GridLayout(0, 1));
  panel.add(orientBox);
  panel.add(relocateBox);

  int result = javax.swing.JOptionPane.showConfirmDialog(
    null, panel, "gbXML import options", javax.swing.JOptionPane.OK_CANCEL_OPTION, javax.swing.JOptionPane.PLAIN_MESSAGE);

  if (result != javax.swing.JOptionPane.OK_OPTION) return false;

  gbxmlImportOrient = orientBox.isSelected();
  gbxmlImportRelocate = relocateBox.isSelected();

  return true;
}

void selectFile_ImportGbxml () {
  // Arms gbxmlImportShowOptionsDialog (importGbxml.pde) the
  // same way selectFile_ImportIfc() above arms ifcImportShowOptionsDialog
  // for its own options.
  gbxmlImportShowOptionsDialog = true;
  selectInput("Select gbXML file to import:", "_fileSelected_ImportGbxml", new File(Folder_Import + "/_.xml"));
}

// Lets the person importing check/uncheck lasImportMeshPointCloud (see
// importLas.pde's own LAS_IMPORT_MESH_POINT_CLOUD/lasImportMeshPointCloud -
// same "a constant for the starting value, a variable for what's
// actually checked at import time" shape IFC_IMPORT_FURNITURE/
// ifcImportFurniture already use), alongside the same Y/Z-swap checkbox
// axisSwapShowImportOptionsDialog() above already offers OBJ/GLB/STL/
// DXF/PLY/DAE - LAS needs its own dialog (not that shared one) purely
// because it has this one extra option beside the swap checkbox, the
// same reason ifcShowImportOptionsDialog()'s/gbxmlShowImportOptionsDialog()'s
// own dialogs just above are each their own function instead of reusing
// it. Called from import_objects_LAS() itself (importLas.pde), not
// from here - same reasoning, and the same "a cancelled dialog must
// never half-apply a choice" behavior, as ifcShowImportOptionsDialog()'s
// own comment above.

// One "[ ] Min X [_____]" style checkbox+field row for lasShowImport
// OptionsDialog()'s own 6-row "Region of interest" section, below -
// backs lasImportMinX/MaxX/MinY/MaxY/MinZ/MaxZ (importLas.pde), each of
// which is a nullable Float (null = no bound on that side - see that
// file's own "Region of interest" header comment). A small class (not
// 6 one-off inline blocks, and not a 2-element Object[] a caller would
// need to cast back out of) specifically because these 6 rows are
// otherwise identical apart from their own label/current value, and
// resolvedValue() below needs real field access, not just construction -
// matches the shape LasMeshProgressReporter/MeshTriangle/LasHeader
// (importLas.pde's own, and meshPointCloud.pde's own) already use for
// the same reason.
class LasBoundsField {
  javax.swing.JCheckBox box;
  javax.swing.JTextField field;

  // fallbackValue is what the field itself shows (box left UNCHECKED
  // either way) when currentValue is null - i.e. no value persisted
  // from an earlier import yet - so the field never starts out on a
  // meaningless "0" unless that's genuinely what the caller wants shown
  // (see lasShowImportOptionsDialog()'s own use of this, below, where
  // fallbackValue is always the file's own real bounding box).
  LasBoundsField (String label, Float currentValue, float fallbackValue) {
    box = new javax.swing.JCheckBox(label, currentValue != null);
    field = new javax.swing.JTextField((currentValue != null) ? str(currentValue) : str(fallbackValue), 8);
  }

  // The field's own typed value if the checkbox is checked and the
  // field holds a real number, null (no bound) otherwise - a blank or
  // non-numeric field left checked is treated the same as leaving the
  // checkbox unchecked, never a dialog-breaking exception from a stray
  // keystroke, matching the rest of this app's own "a bad value quietly
  // falls back rather than crashing" tolerance (e.g. plySizeOf()'s own
  // -1-for-unrecognized return, importPly.pde).
  Float resolvedValue () {
    if (!box.isSelected()) return null;
    try {
      return Float.parseFloat(field.getText().trim());
    }
    catch (NumberFormatException e) {
      return null;
    }
  }
}

// The same shape as LasBoundsField just above, for an Integer bound
// instead of a Float one - lasShowImportOptionsDialog()'s own 2-row
// "Point range" section, below, backs lasImportMinPointIndex/
// MaxPointIndex (importLas.pde) with this instead of LasBoundsField
// itself specifically because a point INDEX needs to stay an exact
// whole number (see that file's own "Point range" header comment for
// why Integer, not Float) - a separate, parallel class rather than
// somehow sharing one, since Java generics can't parameterize over
// int/Integer vs float/Float with real primitive fields the way a
// class written out twice, this plainly, can.
class LasIndexBoundsField {
  javax.swing.JCheckBox box;
  javax.swing.JTextField field;

  // Same fallbackValue reasoning as LasBoundsField's own identical
  // parameter - what the field shows (box left unchecked) when nothing
  // is persisted yet.
  LasIndexBoundsField (String label, Integer currentValue, int fallbackValue) {
    box = new javax.swing.JCheckBox(label, currentValue != null);
    field = new javax.swing.JTextField((currentValue != null) ? str(currentValue) : str(fallbackValue), 10);
  }

  // Same "a bad value quietly falls back to no bound at all, never a
  // dialog-breaking exception from a stray keystroke" tolerance as
  // LasBoundsField's own identical method.
  Integer resolvedValue () {
    if (!box.isSelected()) return null;
    try {
      return Integer.parseInt(field.getText().trim());
    }
    catch (NumberFormatException e) {
      return null;
    }
  }
}

// header is the file's own, already-parsed LasHeader (importLas.pde) -
// passed in specifically so the region-of-interest fields below can
// default to the file's own real bounding box (header.minX/maxX/.../
// maxZ, converted to the same LOCAL coordinate space those fields are
// actually checked against - see importLas.pde's own "Region of
// interest" header comment) rather than a meaningless "0" - see
// import_objects_LAS()'s own restructuring (importLas.pde) for why the
// header is parsed before this dialog is ever shown now. totalPoints is
// that same restructuring's other product: the file's own real,
// already-clamped point count (import_objects_LAS()'s own pointCount,
// computed before this dialog is shown), used the same way below for
// the point-range fields' own default values.
boolean lasShowImportOptionsDialog (LasHeader header, int totalPoints) {

  javax.swing.JCheckBox swapAxisBox = new javax.swing.JCheckBox("Rotate Y-up to Z-up (swap Y/Z axes)", importSwapAxisYZ);
  javax.swing.JCheckBox meshBox = new javax.swing.JCheckBox("Mesh the point cloud into a surface", lasImportMeshPointCloud);
  // lasImportRelocate (importLas.pde) - see its own comment for what
  // this does and its real limits. Same checkbox text importIfc.pde's
  // own identical option already uses.
  javax.swing.JCheckBox relocateBox = new javax.swing.JCheckBox("Navigate to the file's own location (latitude/longitude)", lasImportRelocate);

  // lasImportMeshAlgorithm (importLas.pde) - see its own comment for
  // what this picks between. A mutually-exclusive group of radio
  // buttons (not independent checkboxes, and not reusing meshBox's own
  // checkbox shape) specifically because this is a genuine CHOICE among
  // 3 algorithms, not an independent on/off toggle the way meshBox and
  // every point-range/region-of-interest checkbox below are each their
  // own.
  javax.swing.JRadioButton gridAlgorithmBox = new javax.swing.JRadioButton("Grid (fast, default)", lasImportMeshAlgorithm == LAS_MESH_ALGORITHM_GRID);
  javax.swing.JRadioButton delaunayAlgorithmBox = new javax.swing.JRadioButton("Delaunay (exact, slower)", lasImportMeshAlgorithm == LAS_MESH_ALGORITHM_DELAUNAY);
  javax.swing.JRadioButton boxGridAlgorithmBox = new javax.swing.JRadioButton("Box grid (stepped boxes, not a smooth surface)", lasImportMeshAlgorithm == LAS_MESH_ALGORITHM_BOX_GRID);
  javax.swing.ButtonGroup algorithmGroup = new javax.swing.ButtonGroup();
  algorithmGroup.add(gridAlgorithmBox);
  algorithmGroup.add(delaunayAlgorithmBox);
  algorithmGroup.add(boxGridAlgorithmBox);

  javax.swing.JPanel algorithmPanel = new javax.swing.JPanel(new java.awt.GridLayout(0, 1));
  algorithmPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Meshing algorithm"));
  algorithmPanel.add(gridAlgorithmBox);
  algorithmPanel.add(delaunayAlgorithmBox);
  algorithmPanel.add(boxGridAlgorithmBox);

  // lasImportMinPointIndex/MaxPointIndex (importLas.pde) - see that
  // file's own "Point range" header comment for exactly what these mean
  // (half-open [min, max), min inclusive, max exclusive). totalPoints
  // (this dialog's own parameter, above) is shown as a plain label so
  // the person narrowing the range down actually knows what they're
  // narrowing it FROM, and is minField's own fallback for max (minField's
  // own is always 0) - so "the whole file" needs no typing at all, just
  // ticking a box.
  javax.swing.JLabel totalPointsLabel = new javax.swing.JLabel(totalPoints + " point(s) available in this file");

  LasIndexBoundsField minPointField = new LasIndexBoundsField("Min point index", lasImportMinPointIndex, 0);
  LasIndexBoundsField maxPointField = new LasIndexBoundsField("Max point index (exclusive)", lasImportMaxPointIndex, totalPoints);

  javax.swing.JPanel minPointRow = new javax.swing.JPanel(new java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 0, 0));
  minPointRow.add(minPointField.box);
  minPointRow.add(minPointField.field);

  javax.swing.JPanel maxPointRow = new javax.swing.JPanel(new java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 0, 0));
  maxPointRow.add(maxPointField.box);
  maxPointRow.add(maxPointField.field);

  javax.swing.JPanel pointRangePanel = new javax.swing.JPanel(new java.awt.GridLayout(0, 1));
  pointRangePanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Point range (optional, for testing)"));
  pointRangePanel.add(totalPointsLabel);
  pointRangePanel.add(minPointRow);
  pointRangePanel.add(maxPointRow);

  // lasImportMinX/MaxX/MinY/MaxY/MinZ/MaxZ (importLas.pde) - see that
  // file's own "Region of interest" header comment for exactly what
  // these mean and the coordinate space they're checked against. Any
  // subset of the 6 can be set - each is fully independent of the
  // other 5, so e.g. only a MinX with nothing else is a perfectly
  // normal, supported choice ("everything from here on," with no upper
  // bound on X and no bound on Y/Z at all). Each field's own fallback
  // (shown, box left unchecked, whenever nothing's persisted from an
  // earlier import yet) is the file's OWN real bounding box - header.
  // minX/.../maxZ - converted to the same local (offset-dropped)
  // coordinate space those bounds are actually checked against, so a
  // person narrowing the import down starts from the file's own real
  // extent instead of a meaningless "0".
  LasBoundsField minXField = new LasBoundsField("Min X", lasImportMinX, (float) (header.minX - header.offsetX));
  LasBoundsField maxXField = new LasBoundsField("Max X", lasImportMaxX, (float) (header.maxX - header.offsetX));
  LasBoundsField minYField = new LasBoundsField("Min Y", lasImportMinY, (float) (header.minY - header.offsetY));
  LasBoundsField maxYField = new LasBoundsField("Max Y", lasImportMaxY, (float) (header.maxY - header.offsetY));
  LasBoundsField minZField = new LasBoundsField("Min Z", lasImportMinZ, (float) (header.minZ - header.offsetZ));
  LasBoundsField maxZField = new LasBoundsField("Max Z", lasImportMaxZ, (float) (header.maxZ - header.offsetZ));

  javax.swing.JPanel regionPanel = new javax.swing.JPanel(new java.awt.GridLayout(0, 2));
  regionPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Region of interest (optional)"));
  regionPanel.add(minXField.box); regionPanel.add(minXField.field);
  regionPanel.add(maxXField.box); regionPanel.add(maxXField.field);
  regionPanel.add(minYField.box); regionPanel.add(minYField.field);
  regionPanel.add(maxYField.box); regionPanel.add(maxYField.field);
  regionPanel.add(minZField.box); regionPanel.add(minZField.field);
  regionPanel.add(maxZField.box); regionPanel.add(maxZField.field);

  javax.swing.JPanel panel = new javax.swing.JPanel(new java.awt.GridLayout(0, 1));
  panel.add(swapAxisBox);
  panel.add(meshBox);
  panel.add(relocateBox);
  panel.add(algorithmPanel);
  panel.add(pointRangePanel);
  panel.add(regionPanel);

  int result = javax.swing.JOptionPane.showConfirmDialog(
    null, panel, "LAS import options", javax.swing.JOptionPane.OK_CANCEL_OPTION, javax.swing.JOptionPane.PLAIN_MESSAGE);

  if (result != javax.swing.JOptionPane.OK_OPTION) return false;

  // Left exactly where they were unless this dialog's own OK button is
  // actually pressed - a cancelled dialog must never half-apply a
  // choice.
  importSwapAxisYZ = swapAxisBox.isSelected();
  lasImportMeshPointCloud = meshBox.isSelected();
  lasImportRelocate = relocateBox.isSelected();
  if (delaunayAlgorithmBox.isSelected()) lasImportMeshAlgorithm = LAS_MESH_ALGORITHM_DELAUNAY;
  else if (boxGridAlgorithmBox.isSelected()) lasImportMeshAlgorithm = LAS_MESH_ALGORITHM_BOX_GRID;
  else lasImportMeshAlgorithm = LAS_MESH_ALGORITHM_GRID;

  lasImportMinPointIndex = minPointField.resolvedValue();
  lasImportMaxPointIndex = maxPointField.resolvedValue();

  lasImportMinX = minXField.resolvedValue();
  lasImportMaxX = maxXField.resolvedValue();
  lasImportMinY = minYField.resolvedValue();
  lasImportMaxY = maxYField.resolvedValue();
  lasImportMinZ = minZField.resolvedValue();
  lasImportMaxZ = maxZField.resolvedValue();

  return true;
}

void selectFile_ImportLas () {
  // Arms lasImportShowOptionsDialog (importLas.pde) the same
  // way selectFile_ImportIfc() above arms ifcImportShowOptionsDialog for
  // its own options.
  lasImportShowOptionsDialog = true;
  selectInput("Select LAS file to import:", "_fileSelected_ImportLas", new File(Folder_Import + "/_.las"));
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

  // See isFileOperationInProgress's own comment (globalFunctions.pde)
  // for why - bare statement, cleared at each of this function's own 2
  // exit points below, same convention every importer's own
  // isImportingInProgress already follows.
  isFileOperationInProgress = true;

  String Filename = "";

  if (selectedFile == null) {
    isFileOperationInProgress = false;
  } else {
    Filename = _getSelectedFile(selectedFile);

    println("\nNew project:", Filename);

    update_project_info(selectedFile);

    isFileOperationInProgress = false;
  }
}

void _fileSelected_Open (File selectedFile) {

  // See isFileOperationInProgress's own comment (globalFunctions.pde)
  // for why - bare statement, cleared at each of this function's own 2
  // exit points below. load_project() (loadProject.pde) also sets/
  // clears this same flag around its own work, which nests harmlessly -
  // see that comment for why.
  isFileOperationInProgress = true;

  String Filename = "";

  if (selectedFile == null) {
    isFileOperationInProgress = false;
  } else {
    Filename = _getSelectedFile(selectedFile);

    //println("\nLoading:", Filename);

    noLoop();

    load_project(Filename);

    update_project_info(selectedFile);

    loop();

    isFileOperationInProgress = false;
  }
}

void _fileSelected_SaveAs (File selectedFile) {

  // See isFileOperationInProgress's own comment (globalFunctions.pde)
  // for why - bare statement, cleared at each of this function's own 2
  // exit points below. saveProject() (saveProject.pde) also sets/
  // clears this same flag around its own work, which nests harmlessly -
  // see that comment for why.
  isFileOperationInProgress = true;

  String Filename = "";

  if (selectedFile == null) {
    isFileOperationInProgress = false;
  } else {
    Filename = _getSelectedFile(selectedFile);

    println("\nSaving to:", Filename);

    update_project_info(selectedFile);

    saveProject(Filename);

    isFileOperationInProgress = false;
  }
}

void _fileSelected_ImportObj (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
    // Same reasoning as _fileSelected_ImportIfc()'s own identical line
    // below: cancelling the native file chooser itself never reaches
    // import_objects_OBJ(), which is otherwise what consumes
    // objImportShowOptionsDialog - without this, it would stay armed and
    // pop the options dialog up on the next import_objects_OBJ() call
    // regardless of how that one was started.
    objImportShowOptionsDialog = false;
  } else {
    Filename = _getSelectedFile(selectedFile);
    beginScene3DChange();

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("\nImporting:", Filename);

    int number_of_allGroups_before = allGroups.num;

    //import_objects_OBJ(Filename, -1,0,0,1,0,0, 0,0,0, 1,1,1); // different objects: different materials
    import_objects_OBJ(Filename, User3D.creatorMaterial, User3D.creatorTessellation, User3D.creatorLayer, User3D.creatorVisibility, User3D.creatorWeight, User3D.creatorClosed, 0, 0, 0, 1, 1, 1); // apply default material

    // import_objects_OBJ() adds faces straight into allFaces without ever
    // calling endScene3DChange() itself - without this, the imported geometry
    // would never bump allFaces.winCacheGeneration (see faces.pde's WIN3D
    // retained-mode cache) and so would never actually appear in WIN3D:
    // switch_category() below still triggers a redraw via its own
    // view_changed(), but that redraw would just replay the stale,
    // pre-import cached PShape.
    endScene3DChange();

    int number_of_allGroups_after = allGroups.num;

    Select3D.groupSelection = new int [1 + number_of_allGroups_after - number_of_allGroups_before];
    for (int i = 0; i < Select3D.groupSelection.length - 1; i++) {
      Select3D.groupSelection[i] = i + number_of_allGroups_before;
    }

    switch_category(ObjectCategory.GROUP);
  }
}

void _fileSelected_ImportGlb (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
    // Same reasoning as _fileSelected_ImportObj()'s own identical line
    // above (and _fileSelected_ImportIfc()'s below): cancelling the
    // native file chooser itself never reaches import_objects_GLB(),
    // which is otherwise what consumes glbImportShowOptionsDialog -
    // without this, it would stay armed and pop the options dialog up
    // on the next import_objects_GLB() call regardless of how that one
    // was started.
    glbImportShowOptionsDialog = false;
  } else {
    Filename = _getSelectedFile(selectedFile);
    beginScene3DChange();

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("\nImporting:", Filename);

    int number_of_allGroups_before = allGroups.num;

    import_objects_GLB(Filename, User3D.creatorMaterial, User3D.creatorTessellation, User3D.creatorLayer, User3D.creatorVisibility, User3D.creatorWeight, User3D.creatorClosed, 0, 0, 0, 1, 1, 1); // apply default material

    // Same reason as import_objects_OBJ()'s own call just above this
    // one's sibling - import_objects_GLB() adds faces straight into
    // allFaces without ever calling endScene3DChange() itself.
    endScene3DChange();

    int number_of_allGroups_after = allGroups.num;

    Select3D.groupSelection = new int [1 + number_of_allGroups_after - number_of_allGroups_before];
    for (int i = 0; i < Select3D.groupSelection.length - 1; i++) {
      Select3D.groupSelection[i] = i + number_of_allGroups_before;
    }

    switch_category(ObjectCategory.GROUP);
  }
}

void _fileSelected_ImportStl (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
    // Same reasoning as _fileSelected_ImportObj()'s/_fileSelected_
    // ImportGlb()'s own identical lines above (and _fileSelected_
    // ImportIfc()'s below): cancelling the native file chooser itself
    // never reaches import_objects_STL(), which is otherwise what
    // consumes stlImportShowOptionsDialog - without this, it would stay
    // armed and pop the options dialog up on the next
    // import_objects_STL() call regardless of how that one was started.
    stlImportShowOptionsDialog = false;
  } else {
    Filename = _getSelectedFile(selectedFile);
    beginScene3DChange();

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("\nImporting:", Filename);

    int number_of_allGroups_before = allGroups.num;

    import_objects_STL(Filename, User3D.creatorMaterial, User3D.creatorTessellation, User3D.creatorLayer, User3D.creatorVisibility, User3D.creatorWeight, User3D.creatorClosed, 0, 0, 0, 1, 1, 1); // apply default material

    // Same reason as import_objects_OBJ()'s/import_objects_GLB()'s own
    // calls just above this one's siblings - import_objects_STL() adds
    // faces straight into allFaces without ever calling endScene3DChange()
    // itself.
    endScene3DChange();

    int number_of_allGroups_after = allGroups.num;

    Select3D.groupSelection = new int [1 + number_of_allGroups_after - number_of_allGroups_before];
    for (int i = 0; i < Select3D.groupSelection.length - 1; i++) {
      Select3D.groupSelection[i] = i + number_of_allGroups_before;
    }

    switch_category(ObjectCategory.GROUP);
  }
}

void _fileSelected_ImportDxf (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
    // Same reasoning as _fileSelected_ImportObj()'s/_fileSelected_
    // ImportGlb()'s/_fileSelected_ImportStl()'s own identical lines
    // above (and _fileSelected_ImportIfc()'s below): cancelling the
    // native file chooser itself never reaches import_objects_DXF(),
    // which is otherwise what consumes dxfImportShowOptionsDialog -
    // without this, it would stay armed and pop the options dialog up
    // on the next import_objects_DXF() call regardless of how that one
    // was started.
    dxfImportShowOptionsDialog = false;
  } else {
    Filename = _getSelectedFile(selectedFile);
    beginScene3DChange();

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("\nImporting:", Filename);

    int number_of_allGroups_before = allGroups.num;

    import_objects_DXF(Filename, User3D.creatorMaterial, User3D.creatorTessellation, User3D.creatorLayer, User3D.creatorVisibility, User3D.creatorWeight, User3D.creatorClosed, 0, 0, 0, 1, 1, 1); // apply default material

    // Same reason as import_objects_OBJ()'s/import_objects_GLB()'s/
    // import_objects_STL()'s own calls just above this one's siblings -
    // import_objects_DXF() adds faces straight into allFaces without
    // ever calling endScene3DChange() itself.
    endScene3DChange();

    int number_of_allGroups_after = allGroups.num;

    Select3D.groupSelection = new int [1 + number_of_allGroups_after - number_of_allGroups_before];
    for (int i = 0; i < Select3D.groupSelection.length - 1; i++) {
      Select3D.groupSelection[i] = i + number_of_allGroups_before;
    }

    switch_category(ObjectCategory.GROUP);
  }
}

void _fileSelected_ImportPly (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
    // Same reasoning as _fileSelected_ImportObj()'s/_fileSelected_
    // ImportGlb()'s/_fileSelected_ImportStl()'s/_fileSelected_
    // ImportDxf()'s own identical lines above (and _fileSelected_
    // ImportIfc()'s below): cancelling the native file chooser itself
    // never reaches import_objects_PLY(), which is otherwise what
    // consumes plyImportShowOptionsDialog - without this, it would stay
    // armed and pop the options dialog up on the next
    // import_objects_PLY() call regardless of how that one was started.
    plyImportShowOptionsDialog = false;
  } else {
    Filename = _getSelectedFile(selectedFile);
    beginScene3DChange();

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("\nImporting:", Filename);

    int number_of_allGroups_before = allGroups.num;

    import_objects_PLY(Filename, User3D.creatorMaterial, User3D.creatorTessellation, User3D.creatorLayer, User3D.creatorVisibility, User3D.creatorWeight, User3D.creatorClosed, 0, 0, 0, 1, 1, 1); // apply default material

    // Same reason as import_objects_OBJ()'s/import_objects_GLB()'s/
    // import_objects_STL()'s/import_objects_DXF()'s own calls just above
    // this one's siblings - import_objects_PLY() adds faces straight
    // into allFaces without ever calling endScene3DChange() itself.
    endScene3DChange();

    int number_of_allGroups_after = allGroups.num;

    Select3D.groupSelection = new int [1 + number_of_allGroups_after - number_of_allGroups_before];
    for (int i = 0; i < Select3D.groupSelection.length - 1; i++) {
      Select3D.groupSelection[i] = i + number_of_allGroups_before;
    }

    switch_category(ObjectCategory.GROUP);
  }
}

void _fileSelected_ImportDae (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
    // Same reasoning as _fileSelected_ImportObj()'s/_fileSelected_
    // ImportGlb()'s/_fileSelected_ImportStl()'s/_fileSelected_
    // ImportDxf()'s/_fileSelected_ImportPly()'s own identical lines
    // above (and _fileSelected_ImportIfc()'s below): cancelling the
    // native file chooser itself never reaches import_objects_DAE(),
    // which is otherwise what consumes daeImportShowOptionsDialog -
    // without this, it would stay armed and pop the options dialog up
    // on the next import_objects_DAE() call regardless of how that one
    // was started.
    daeImportShowOptionsDialog = false;
  } else {
    Filename = _getSelectedFile(selectedFile);
    beginScene3DChange();

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("\nImporting:", Filename);

    int number_of_allGroups_before = allGroups.num;

    import_objects_DAE(Filename, User3D.creatorMaterial, User3D.creatorTessellation, User3D.creatorLayer, User3D.creatorVisibility, User3D.creatorWeight, User3D.creatorClosed, 0, 0, 0, 1, 1, 1); // apply default material

    // Same reason as import_objects_OBJ()'s/import_objects_GLB()'s/
    // import_objects_STL()'s/import_objects_DXF()'s/import_objects_PLY()'s
    // own calls just above this one's siblings - import_objects_DAE()
    // adds faces straight into allFaces without ever calling
    // endScene3DChange() itself.
    endScene3DChange();

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
    beginScene3DChange();

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("\nImporting:", Filename);

    int number_of_allGroups_before = allGroups.num;

    // Like import_objects_OBJ() above, import_objects_IFC() adds faces
    // straight into allFaces (see ifcEmitFace()'s own comment for why)
    // and calls endScene3DChange() itself exactly once, at the very end of
    // the whole import - so no extra endScene3DChange() call is needed
    // here. The beginScene3DChange() added above is still needed, though:
    // it's what makes import_objects_IFC()'s own trailing endScene3DChange()
    // close out THIS function's own beginNewGroup() too (scene3DChangeDepth
    // 1 -> 0, once import_objects_IFC() itself gets its own
    // beginScene3DChange() added later it'll nest instead, 2 -> 1, with no
    // change needed here) - without it, the group creation a few lines
    // above would sit outside any pairing at all until that happened.
    import_objects_IFC(Filename, User3D.creatorMaterial, User3D.creatorTessellation, User3D.creatorLayer, User3D.creatorVisibility, User3D.creatorWeight, User3D.creatorClosed, 0, 0, 0, 1, 1, 1); // apply default material

    int number_of_allGroups_after = allGroups.num;

    Select3D.groupSelection = new int [1 + number_of_allGroups_after - number_of_allGroups_before];
    for (int i = 0; i < Select3D.groupSelection.length - 1; i++) {
      Select3D.groupSelection[i] = i + number_of_allGroups_before;
    }

    switch_category(ObjectCategory.GROUP);
  }
}

void _fileSelected_ImportGbxml (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
    // Same reasoning as _fileSelected_ImportObj()'s/_fileSelected_
    // ImportGlb()'s/_fileSelected_ImportStl()'s/_fileSelected_
    // ImportDxf()'s/_fileSelected_ImportPly()'s/_fileSelected_
    // ImportDae()'s own identical lines above: cancelling the native
    // file chooser itself never reaches import_objects_GBXML(), which
    // is otherwise what consumes gbxmlImportShowOptionsDialog - without
    // this, it would stay armed and pop the options dialog up on the
    // next import_objects_GBXML() call regardless of how that one was
    // started.
    gbxmlImportShowOptionsDialog = false;
  } else {
    Filename = _getSelectedFile(selectedFile);
    beginScene3DChange();

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("\nImporting:", Filename);

    int number_of_allGroups_before = allGroups.num;

    import_objects_GBXML(Filename, User3D.creatorMaterial, User3D.creatorTessellation, User3D.creatorLayer, User3D.creatorVisibility, User3D.creatorWeight, User3D.creatorClosed, 0, 0, 0, 1, 1, 1); // apply default material

    // Same reason as import_objects_OBJ()'s/import_objects_GLB()'s/
    // import_objects_STL()'s/import_objects_DXF()'s/import_objects_PLY()'s/
    // import_objects_DAE()'s own calls just above this one's siblings -
    // import_objects_GBXML() adds faces straight into allFaces without
    // ever calling endScene3DChange() itself.
    endScene3DChange();

    int number_of_allGroups_after = allGroups.num;

    Select3D.groupSelection = new int [1 + number_of_allGroups_after - number_of_allGroups_before];
    for (int i = 0; i < Select3D.groupSelection.length - 1; i++) {
      Select3D.groupSelection[i] = i + number_of_allGroups_before;
    }

    switch_category(ObjectCategory.GROUP);
  }
}

void _fileSelected_ImportLas (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
    // Same reasoning as _fileSelected_ImportObj()'s/_fileSelected_
    // ImportGlb()'s/_fileSelected_ImportStl()'s/_fileSelected_
    // ImportDxf()'s/_fileSelected_ImportPly()'s/_fileSelected_
    // ImportDae()'s/_fileSelected_ImportGbxml()'s own identical lines
    // above: cancelling the native file chooser itself never reaches
    // import_objects_LAS(), which is otherwise what consumes
    // lasImportShowOptionsDialog - without this, it would stay armed
    // and pop the options dialog up on the next import_objects_LAS()
    // call regardless of how that one was started.
    lasImportShowOptionsDialog = false;
  } else {
    Filename = _getSelectedFile(selectedFile);
    beginScene3DChange();

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("\nImporting:", Filename);

    int number_of_allGroups_before = allGroups.num;

    import_objects_LAS(Filename, User3D.creatorMaterial, User3D.creatorTessellation, User3D.creatorLayer, User3D.creatorVisibility, User3D.creatorWeight, User3D.creatorClosed, 0, 0, 0, 1, 1, 1); // apply default material

    // Same reason as import_objects_OBJ()'s/import_objects_GLB()'s/
    // import_objects_STL()'s/import_objects_DXF()'s/import_objects_PLY()'s/
    // import_objects_DAE()'s/import_objects_GBXML()'s own calls just
    // above this one's siblings - import_objects_LAS() adds points/
    // faces straight into allPoints/allFaces without ever calling
    // endScene3DChange() itself.
    endScene3DChange();

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
