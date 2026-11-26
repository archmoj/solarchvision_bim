void selectFile_New () {
  // See isFileOperationInProgress's own comment (globalFunctions.pde)
  // for why - set here too, not just inside _fileSelected_New() itself,
  // so the UI is disabled for the native dialog's own open/pick/cancel
  // window as well, not only once it has already resolved; whichever
  // branch _fileSelected_New() takes clears it again.
  isFileOperationInProgress = true;
  // selectOutput(), not selectInput(): this prompts for the NEW
  // project's own name/location (see the dialog's own "Specify project
  // name:" prompt, and _fileSelected_New() below, which never reads the
  // picked file - it only takes its name/folder, same as
  // selectFile_SaveAs()'s own selectOutput() call just below). An open-
  // style selectInput() dialog only lets picking an already-existing
  // file/folder, with no field to type a new name into - exactly the
  // capability this needs.
  selectOutput("Specify project name:", "_fileSelected_New", new File(Folder_Project + "/_.xml"));
}

void selectFile_Open () {
  // Same reasoning as selectFile_New()'s own identical line above.
  isFileOperationInProgress = true;
  selectInput("Select a file to open:", "_fileSelected_Open", new File(Folder_Project + "/_.xml"));
}

void selectFile_SaveAs () {
  // Same reasoning as selectFile_New()'s own identical line above.
  isFileOperationInProgress = true;
  selectOutput("Select a file to write to:", "_fileSelected_SaveAs", new File(Folder_Project + "/_.xml"));
}

void selectFile_ImportObj () {
  // Arms objImportShowOptionsDialog (importObj.pde) the same
  // way selectFile_ImportIfc() below arms ifcImportShowOptionsDialog for
  // its own five options.
  objImportShowOptionsDialog = true;
  // See isImportingInProgress's own comment (globalFunctions.pde) for
  // why - set here too, not just inside import_objects_OBJ() itself, so
  // the UI is disabled for the native dialog's own open/pick/cancel
  // window as well, not only once a file has already been picked and
  // import_objects_OBJ() has actually started; _fileSelected_ImportObj()
  // clears it again on every outcome (a file picked or the dialog
  // cancelled).
  isImportingInProgress = true;
  selectInput("Select OBJ file to import:", "_fileSelected_ImportObj", new File(Folder_Import + "/_.obj"));
}

void selectFile_ImportGlb () {
  // Arms glbImportShowOptionsDialog (importGlb.pde) the same way.
  glbImportShowOptionsDialog = true;
  // Same reasoning as selectFile_ImportObj()'s own identical line above.
  isImportingInProgress = true;
  selectInput("Select GLB file to import:", "_fileSelected_ImportGlb", new File(Folder_Import + "/_.glb"));
}

void selectFile_ImportStl () {
  // Arms stlImportShowOptionsDialog (importStl.pde) the same way.
  stlImportShowOptionsDialog = true;
  // Same reasoning as selectFile_ImportObj()'s own identical line above.
  isImportingInProgress = true;
  selectInput("Select STL file to import:", "_fileSelected_ImportStl", new File(Folder_Import + "/_.stl"));
}

void selectFile_ImportDxf () {
  // Arms dxfImportShowOptionsDialog (importDxf.pde) the same way.
  dxfImportShowOptionsDialog = true;
  // Same reasoning as selectFile_ImportObj()'s own identical line above.
  isImportingInProgress = true;
  selectInput("Select DXF file to import:", "_fileSelected_ImportDxf", new File(Folder_Import + "/_.dxf"));
}

void selectFile_ImportPly () {
  // Arms plyImportShowOptionsDialog (importPly.pde) the same way.
  plyImportShowOptionsDialog = true;
  // Same reasoning as selectFile_ImportObj()'s own identical line above.
  isImportingInProgress = true;
  selectInput("Select PLY file to import:", "_fileSelected_ImportPly", new File(Folder_Import + "/_.ply"));
}

void selectFile_ImportDae () {
  // Arms daeImportShowOptionsDialog (importDae.pde) the same way.
  daeImportShowOptionsDialog = true;
  // Same reasoning as selectFile_ImportObj()'s own identical line above.
  isImportingInProgress = true;
  selectInput("Select DAE file to import:", "_fileSelected_ImportDae", new File(Folder_Import + "/_.dae"));
}

void selectFile_ImportGeojson () {
  // Arms geojsonImportShowOptionsDialog (importGeojson.pde) the same way.
  geojsonImportShowOptionsDialog = true;
  // Same reasoning as selectFile_ImportObj()'s own identical line above.
  isImportingInProgress = true;
  selectInput("Select GeoJSON file to import:", "_fileSelected_ImportGeojson", new File(Folder_Import + "/_.geojson"));
}

void selectFile_ImportTopojson () {
  // Arms topojsonImportShowOptionsDialog (importTopojson.pde) the same way.
  topojsonImportShowOptionsDialog = true;
  // Same reasoning as selectFile_ImportObj()'s own identical line above.
  isImportingInProgress = true;
  selectInput("Select TopoJSON file to import:", "_fileSelected_ImportTopojson", new File(Folder_Import + "/_.topojson"));
}

void selectFile_ImportKml () {
  // Arms kmlImportShowOptionsDialog (importKml.pde) the same way.
  kmlImportShowOptionsDialog = true;
  // Same reasoning as selectFile_ImportObj()'s own identical line above.
  isImportingInProgress = true;
  selectInput("Select KML file to import:", "_fileSelected_ImportKml", new File(Folder_Import + "/_.kml"));
}

void selectFile_ImportCitygml () {
  // Arms citygmlImportShowOptionsDialog (importCitygml.pde) the same way.
  citygmlImportShowOptionsDialog = true;
  // Same reasoning as selectFile_ImportObj()'s own identical line above.
  isImportingInProgress = true;
  selectInput("Select CityGML file to import:", "_fileSelected_ImportCitygml", new File(Folder_Import + "/_.gml"));
}

void selectFile_ImportShapefile () {
  // Arms shpImportShowOptionsDialog (importShapefile.pde) the same way.
  shpImportShowOptionsDialog = true;
  // Same reasoning as selectFile_ImportObj()'s own identical line above.
  isImportingInProgress = true;
  selectInput("Select Shapefile (.shp) to import:", "_fileSelected_ImportShapefile", new File(Folder_Import + "/_.shp"));
}

void selectFile_ImportSvg () {
  // Arms svgImportShowOptionsDialog (importSvg.pde) the same way.
  svgImportShowOptionsDialog = true;
  // Same reasoning as selectFile_ImportObj()'s own identical line above.
  isImportingInProgress = true;
  selectInput("Select SVG file to import:", "_fileSelected_ImportSvg", new File(Folder_Import + "/_.svg"));
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

// Lets the person importing skip capturing extraParams (see faces.pde's/
// current_ExtraParams's own comment, globalVariables.pde) for a
// simplified import - on by default (capture whatever source metadata
// each importer finds), same shared-global shape as importSwapAxisYZ
// just above, surfaced as the same kind of checkbox in every import
// dialog that has one (dxfShowImportOptionsDialog()/
// svgShowImportOptionsDialog()/geojsonShowImportOptionsDialog()/
// citygmlShowImportOptionsDialog()/shpShowImportOptionsDialog()/
// objShowImportOptionsDialog()/glbShowImportOptionsDialog()/
// daeShowImportOptionsDialog()/ifcShowImportOptionsDialog()/
// gbxmlShowImportOptionsDialog() below) - checked by each importer
// itself right where it would otherwise set current_ExtraParams.
boolean importExtraParams = true;

// The write-side mirror of importExtraParams just above now lives as
// User3D.exporterExtraParams (user3D.pde) - the same persisted-setting
// shape every other exporter option in this app already takes
// (exporterScale/exporterYaxisUp/exporterMaterialLibrary/
// exporterDoubleSided/... alongside it), with its own Spinner in the
// Export > Model rollout (uiRollout.pde's own CHILD_EXPORT_MODEL block,
// wired through valueModifier.pde's own exporterExtraParams()) rather
// than the plain unexposed global this started as. Checked by every GIS
// exporter that writes a "properties"-shaped bag at all (exportGeojson.
// pde's own exportBuildProperties(), reused as-is by exportTopojson.pde/
// exportKml.pde/exportCitygml.pde) right where it would otherwise merge
// a Face's/Polyline's own extraParams into that bag, and by
// exportShapefile.pde/exportDxf.pde for their own, non-JSON-properties-
// shaped equivalents (a DBF column, DXF XDATA).

// Shared by STL alone now (one option, one checkbox) since that's
// exactly the axis convention it already agrees to share - see
// importStl.pde's own stlImportShowOptionsDialog for how it arms this
// the same way ifcImportShowOptionsDialog (below) arms IFC's own
// five-option version of the same dialog. OBJ, DXF, GLB, DAE and PLY
// each reuse this same checkbox too, but through their own
// objShowImportOptionsDialog()/dxfShowImportOptionsDialog()/
// glbShowImportOptionsDialog()/daeShowImportOptionsDialog()/
// plyShowImportOptionsDialog() further down instead of this shared
// function directly - the same "one extra option beside the swap
// checkbox" reason lasShowImportOptionsDialog()'s own comment gives
// for why LAS isn't here either.
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

// Lets the person importing check/uncheck the same importSwapAxisYZ
// checkbox axisSwapShowImportOptionsDialog() above offers OBJ/GLB/STL/
// PLY/DAE, alongside dxfImportCurves (see importDxf.pde's own
// DXF_IMPORT_CURVES/dxfImportCurves - a constant for the starting
// value, a variable for what's actually checked at import time, the
// same shape IFC_IMPORT_FURNITURE/ifcImportFurniture above already
// use). DXF needs its own dialog (not that shared one) purely because
// it has this one extra option beside the swap checkbox - the same
// reason lasShowImportOptionsDialog()'s own comment gives for why LAS
// isn't there either. Called from import_objects_DXF() itself
// (importDxf.pde), not from here - same reasoning, and the same "a
// cancelled dialog must never half-apply a choice" behavior, as
// ifcShowImportOptionsDialog()'s own comment below.
boolean dxfShowImportOptionsDialog () {

  javax.swing.JCheckBox swapAxisBox = new javax.swing.JCheckBox("Rotate Y-up to Z-up (swap Y/Z axes)", importSwapAxisYZ);
  javax.swing.JCheckBox curvesBox = new javax.swing.JCheckBox("Import lines, arcs and curves", dxfImportCurves);
  javax.swing.JCheckBox extraParamsBox = new javax.swing.JCheckBox("Import extra metadata (layer name) as extraParams", importExtraParams);

  javax.swing.JPanel panel = new javax.swing.JPanel(new java.awt.GridLayout(0, 1));
  panel.add(swapAxisBox);
  panel.add(curvesBox);
  panel.add(extraParamsBox);

  int result = javax.swing.JOptionPane.showConfirmDialog(
    null, panel, "DXF import options", javax.swing.JOptionPane.OK_CANCEL_OPTION, javax.swing.JOptionPane.PLAIN_MESSAGE);

  if (result != javax.swing.JOptionPane.OK_OPTION) return false;

  // Left exactly where they were unless this dialog's own OK button is
  // actually pressed - a cancelled dialog must never half-apply a
  // choice.
  importSwapAxisYZ = swapAxisBox.isSelected();
  dxfImportCurves = curvesBox.isSelected();
  importExtraParams = extraParamsBox.isSelected();

  return true;
}

// SVG's own dialog - no axis-swap checkbox (unlike
// dxfShowImportOptionsDialog()/objShowImportOptionsDialog()/...): an SVG
// document's own Y-down convention is unambiguous, not a genuine up-axis
// question the person needs to resolve per file (importSvg.pde's own
// header comment), so this importer always flips it on its own rather
// than asking. The one option offered is whether to treat each shape's
// own (or nearest ancestor `<g>`'s own) "id" attribute as a grouping/
// material-cycling boundary - off by default, since an arbitrary SVG's
// own ids are far less reliably a meaningful grouping signal than a DXF
// layer is (importSvg.pde's own header comment).
boolean svgShowImportOptionsDialog () {

  javax.swing.JCheckBox groupByIdBox = new javax.swing.JCheckBox("Group/cycle material by each shape's own id", svgGroupById);
  javax.swing.JCheckBox extraParamsBox = new javax.swing.JCheckBox("Import extra metadata (shape id) as extraParams", importExtraParams);

  javax.swing.JPanel panel = new javax.swing.JPanel(new java.awt.GridLayout(0, 1));
  panel.add(groupByIdBox);
  panel.add(extraParamsBox);

  int result = javax.swing.JOptionPane.showConfirmDialog(
    null, panel, "SVG import options", javax.swing.JOptionPane.OK_CANCEL_OPTION, javax.swing.JOptionPane.PLAIN_MESSAGE);

  if (result != javax.swing.JOptionPane.OK_OPTION) return false;

  // Left exactly where it was unless this dialog's own OK button is
  // actually pressed - same reasoning as every dialog above.
  svgGroupById = groupByIdBox.isSelected();
  importExtraParams = extraParamsBox.isSelected();

  return true;
}

// Lets the person importing type the two "properties" keys
// geojsonHeightProperty/geojsonGroupProperty (importGeojson.pde) read -
// shared as-is across GeoJSON, TopoJSON, and KML import (importTopojson.
// pde's/importKml.pde's own header comments on why the whole GeoJSON core,
// this option state included, is reused rather than duplicated), since a
// TopoJSON geometry object's own "properties" member - and a KML
// Placemark's own <ExtendedData>, read into the same shape by
// kmlReadProperties() (importKml.pde) - both mean exactly the same thing a
// GeoJSON Feature's own "properties" does. None of the three formats has
// an up-axis question at all (see importGeojson.pde's own header comment
// for why), so unlike dxfShowImportOptionsDialog()/
// objShowImportOptionsDialog()/... above, this dialog has no axis-swap
// checkbox; two plain text fields instead of checkboxes, since both
// options are open-ended property NAMES, not on/off toggles. Called from
// import_objects_GEOJSON()/import_objects_TOPOJSON()/import_objects_KML()
// themselves (importGeojson.pde/importTopojson.pde/importKml.pde), not
// from here - same reasoning, and the same "a cancelled dialog must never
// half-apply a choice" behavior, as dxfShowImportOptionsDialog()'s own
// comment above.
boolean geojsonShowImportOptionsDialog () {

  javax.swing.JTextField heightField = new javax.swing.JTextField(geojsonHeightProperty, 20);
  javax.swing.JTextField groupField = new javax.swing.JTextField(geojsonGroupProperty, 20);
  javax.swing.JCheckBox extraParamsBox = new javax.swing.JCheckBox("Import extra metadata (the feature's own properties) as extraParams", importExtraParams);

  javax.swing.JPanel heightRow = new javax.swing.JPanel(new java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 0, 0));
  heightRow.add(new javax.swing.JLabel("Extrude polygons using height property:"));
  heightRow.add(heightField);

  javax.swing.JPanel groupRow = new javax.swing.JPanel(new java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 0, 0));
  groupRow.add(new javax.swing.JLabel("Group/cycle material by property:"));
  groupRow.add(groupField);

  javax.swing.JPanel panel = new javax.swing.JPanel(new java.awt.GridLayout(0, 1));
  panel.add(new javax.swing.JLabel("Leave either field blank to skip that option."));
  panel.add(heightRow);
  panel.add(groupRow);
  panel.add(extraParamsBox);

  int result = javax.swing.JOptionPane.showConfirmDialog(
    null, panel, "GeoJSON/TopoJSON/KML import options", javax.swing.JOptionPane.OK_CANCEL_OPTION, javax.swing.JOptionPane.PLAIN_MESSAGE);

  if (result != javax.swing.JOptionPane.OK_OPTION) return false;

  // Left exactly where they were unless this dialog's own OK button is
  // actually pressed - same reasoning as every dialog above.
  geojsonHeightProperty = heightField.getText().trim();
  geojsonGroupProperty = groupField.getText().trim();
  importExtraParams = extraParamsBox.isSelected();

  return true;
}

// CityGML's own dialog - reuses the exact same geojsonHeightProperty/
// geojsonGroupProperty shared state/fields as geojsonShowImportOptionsDialog()
// just above (same meaning: a synthetic "properties" key this format's own
// importCitygml.pde builds per Building - "measuredHeight"/"gmlId" among
// others, see that file's own citygmlReadProperties() comment), but needs
// its own separate dialog (not that shared one) for the same "one extra
// option beside the shared two" reason dxfShowImportOptionsDialog()/
// objShowImportOptionsDialog()/... above each do - here that extra option is
// citygmlCoordinatesAreLonLat (importCitygml.pde's own header comment on why
// CityGML, unlike GeoJSON/TopoJSON/KML, actually needs this choice at all).
boolean citygmlShowImportOptionsDialog () {

  javax.swing.JTextField heightField = new javax.swing.JTextField(geojsonHeightProperty, 20);
  javax.swing.JTextField groupField = new javax.swing.JTextField(geojsonGroupProperty, 20);
  javax.swing.JCheckBox lonLatBox = new javax.swing.JCheckBox("Coordinates are longitude/latitude (project around site location)", citygmlCoordinatesAreLonLat);
  javax.swing.JCheckBox extraParamsBox = new javax.swing.JCheckBox("Import extra metadata (gml:id, measuredHeight, generic attributes, ...) as extraParams", importExtraParams);

  javax.swing.JPanel heightRow = new javax.swing.JPanel(new java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 0, 0));
  heightRow.add(new javax.swing.JLabel("Extrude LOD0-footprint-only buildings using height property (e.g. \"measuredHeight\"):"));
  heightRow.add(heightField);

  javax.swing.JPanel groupRow = new javax.swing.JPanel(new java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 0, 0));
  groupRow.add(new javax.swing.JLabel("Group/cycle material by property (e.g. \"gmlId\" for one group per building):"));
  groupRow.add(groupField);

  javax.swing.JPanel panel = new javax.swing.JPanel(new java.awt.GridLayout(0, 1));
  panel.add(new javax.swing.JLabel("Leave either field blank to skip that option."));
  panel.add(heightRow);
  panel.add(groupRow);
  panel.add(lonLatBox);
  panel.add(extraParamsBox);

  int result = javax.swing.JOptionPane.showConfirmDialog(
    null, panel, "CityGML import options", javax.swing.JOptionPane.OK_CANCEL_OPTION, javax.swing.JOptionPane.PLAIN_MESSAGE);

  if (result != javax.swing.JOptionPane.OK_OPTION) return false;

  // Left exactly where they were unless this dialog's own OK button is
  // actually pressed - same reasoning as every dialog above.
  geojsonHeightProperty = heightField.getText().trim();
  geojsonGroupProperty = groupField.getText().trim();
  citygmlCoordinatesAreLonLat = lonLatBox.isSelected();
  importExtraParams = extraParamsBox.isSelected();

  return true;
}

// Shapefile's own dialog - same shape as citygmlShowImportOptionsDialog()
// just above (shared geojsonHeightProperty/geojsonGroupProperty text
// fields, plus its own lon/lat checkbox, for the same "a shapefile's own
// X/Y could be either already-planar or geographic" reason
// importShapefile.pde's own header comment gives), just reading/writing
// shpCoordinatesAreLonLat instead of citygmlCoordinatesAreLonLat.
// import_objects_SHP() (importShapefile.pde) already sets
// shpCoordinatesAreLonLat from a sibling .prj file, best-effort, before
// this dialog is ever shown - so the checkbox the person actually sees
// here reflects that guess, which they can still freely override.
boolean shpShowImportOptionsDialog () {

  javax.swing.JTextField heightField = new javax.swing.JTextField(geojsonHeightProperty, 20);
  javax.swing.JTextField groupField = new javax.swing.JTextField(geojsonGroupProperty, 20);
  javax.swing.JCheckBox lonLatBox = new javax.swing.JCheckBox("Coordinates are longitude/latitude (project around site location)", shpCoordinatesAreLonLat);
  javax.swing.JCheckBox extraParamsBox = new javax.swing.JCheckBox("Import extra metadata (the record's own .dbf attributes) as extraParams", importExtraParams);

  javax.swing.JPanel heightRow = new javax.swing.JPanel(new java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 0, 0));
  heightRow.add(new javax.swing.JLabel("Extrude polygons using height property (a .dbf field name):"));
  heightRow.add(heightField);

  javax.swing.JPanel groupRow = new javax.swing.JPanel(new java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 0, 0));
  groupRow.add(new javax.swing.JLabel("Group/cycle material by property (a .dbf field name):"));
  groupRow.add(groupField);

  javax.swing.JPanel panel = new javax.swing.JPanel(new java.awt.GridLayout(0, 1));
  panel.add(new javax.swing.JLabel("Leave either field blank to skip that option."));
  panel.add(heightRow);
  panel.add(groupRow);
  panel.add(lonLatBox);
  panel.add(extraParamsBox);

  int result = javax.swing.JOptionPane.showConfirmDialog(
    null, panel, "Shapefile import options", javax.swing.JOptionPane.OK_CANCEL_OPTION, javax.swing.JOptionPane.PLAIN_MESSAGE);

  if (result != javax.swing.JOptionPane.OK_OPTION) return false;

  // Left exactly where they were unless this dialog's own OK button is
  // actually pressed - same reasoning as every dialog above.
  geojsonHeightProperty = heightField.getText().trim();
  geojsonGroupProperty = groupField.getText().trim();
  shpCoordinatesAreLonLat = lonLatBox.isSelected();
  importExtraParams = extraParamsBox.isSelected();

  return true;
}

// Lets the person importing check/uncheck the same importSwapAxisYZ
// checkbox axisSwapShowImportOptionsDialog() above offers GLB/STL/PLY/
// DAE, alongside objImportCurves (see importObj.pde's own
// OBJ_IMPORT_CURVES/objImportCurves - same constant-for-the-starting-
// value, variable-for-what's-actually-checked shape as dxfImportCurves
// just above). OBJ needs its own dialog (not that shared one) for the
// same "one extra option beside the swap checkbox" reason
// dxfShowImportOptionsDialog() just above does. Called from
// import_objects_OBJ() itself (importObj.pde), not from here - same
// reasoning, and the same "a cancelled dialog must never half-apply a
// choice" behavior, as dxfShowImportOptionsDialog()'s own comment above.
boolean objShowImportOptionsDialog () {

  javax.swing.JCheckBox swapAxisBox = new javax.swing.JCheckBox("Rotate Y-up to Z-up (swap Y/Z axes)", importSwapAxisYZ);
  javax.swing.JCheckBox curvesBox = new javax.swing.JCheckBox("Import lines", objImportCurves);
  javax.swing.JCheckBox extraParamsBox = new javax.swing.JCheckBox("Import extra metadata (object/group name) as extraParams", importExtraParams);

  javax.swing.JPanel panel = new javax.swing.JPanel(new java.awt.GridLayout(0, 1));
  panel.add(swapAxisBox);
  panel.add(curvesBox);
  panel.add(extraParamsBox);

  int result = javax.swing.JOptionPane.showConfirmDialog(
    null, panel, "OBJ import options", javax.swing.JOptionPane.OK_CANCEL_OPTION, javax.swing.JOptionPane.PLAIN_MESSAGE);

  if (result != javax.swing.JOptionPane.OK_OPTION) return false;

  // Left exactly where they were unless this dialog's own OK button is
  // actually pressed - a cancelled dialog must never half-apply a
  // choice.
  importSwapAxisYZ = swapAxisBox.isSelected();
  objImportCurves = curvesBox.isSelected();
  importExtraParams = extraParamsBox.isSelected();

  return true;
}

// Lets the person importing check/uncheck the same importSwapAxisYZ
// checkbox axisSwapShowImportOptionsDialog() above offers STL/PLY/DAE,
// alongside glbImportCurves (see importGlb.pde's own
// GLB_IMPORT_CURVES/glbImportCurves - same constant-for-the-starting-
// value, variable-for-what's-actually-checked shape as objImportCurves/
// dxfImportCurves just above). GLB needs its own dialog (not that
// shared one) for the same "one extra option beside the swap checkbox"
// reason objShowImportOptionsDialog()/dxfShowImportOptionsDialog() just
// above do. Called from import_objects_GLB() itself (importGlb.pde),
// not from here - same reasoning, and the same "a cancelled dialog
// must never half-apply a choice" behavior, as those two dialogs'
// own comments above.
boolean glbShowImportOptionsDialog () {

  javax.swing.JCheckBox swapAxisBox = new javax.swing.JCheckBox("Rotate Y-up to Z-up (swap Y/Z axes)", importSwapAxisYZ);
  javax.swing.JCheckBox curvesBox = new javax.swing.JCheckBox("Import lines (LINES/LINE_LOOP/LINE_STRIP primitives)", glbImportCurves);
  javax.swing.JCheckBox extraParamsBox = new javax.swing.JCheckBox("Import extra metadata (node/mesh name, extras) as extraParams", importExtraParams);

  javax.swing.JPanel panel = new javax.swing.JPanel(new java.awt.GridLayout(0, 1));
  panel.add(swapAxisBox);
  panel.add(curvesBox);
  panel.add(extraParamsBox);

  int result = javax.swing.JOptionPane.showConfirmDialog(
    null, panel, "GLB import options", javax.swing.JOptionPane.OK_CANCEL_OPTION, javax.swing.JOptionPane.PLAIN_MESSAGE);

  if (result != javax.swing.JOptionPane.OK_OPTION) return false;

  // Left exactly where they were unless this dialog's own OK button is
  // actually pressed - a cancelled dialog must never half-apply a
  // choice.
  importSwapAxisYZ = swapAxisBox.isSelected();
  glbImportCurves = curvesBox.isSelected();
  importExtraParams = extraParamsBox.isSelected();

  return true;
}

// Lets the person importing check/uncheck the same importSwapAxisYZ
// checkbox axisSwapShowImportOptionsDialog() above offers STL/PLY,
// alongside daeImportCurves (see importDae.pde's own
// DAE_IMPORT_CURVES/daeImportCurves - same constant-for-the-starting-
// value, variable-for-what's-actually-checked shape as objImportCurves/
// dxfImportCurves/glbImportCurves just above). DAE needs its own
// dialog (not that shared one) for the same "one extra option beside
// the swap checkbox" reason
// objShowImportOptionsDialog()/dxfShowImportOptionsDialog()/
// glbShowImportOptionsDialog() just above do. Called from
// import_objects_DAE() itself (importDae.pde), not from here - same
// reasoning, and the same "a cancelled dialog must never half-apply a
// choice" behavior, as those dialogs' own comments above.
boolean daeShowImportOptionsDialog () {

  javax.swing.JCheckBox swapAxisBox = new javax.swing.JCheckBox("Rotate Y-up to Z-up (swap Y/Z axes)", importSwapAxisYZ);
  javax.swing.JCheckBox curvesBox = new javax.swing.JCheckBox("Import lines (<lines>/<linestrips> primitives)", daeImportCurves);
  javax.swing.JCheckBox extraParamsBox = new javax.swing.JCheckBox("Import extra metadata (<extra> blocks, node/geometry name) as extraParams", importExtraParams);

  javax.swing.JPanel panel = new javax.swing.JPanel(new java.awt.GridLayout(0, 1));
  panel.add(swapAxisBox);
  panel.add(curvesBox);
  panel.add(extraParamsBox);

  int result = javax.swing.JOptionPane.showConfirmDialog(
    null, panel, "DAE import options", javax.swing.JOptionPane.OK_CANCEL_OPTION, javax.swing.JOptionPane.PLAIN_MESSAGE);

  if (result != javax.swing.JOptionPane.OK_OPTION) return false;

  // Left exactly where they were unless this dialog's own OK button is
  // actually pressed - a cancelled dialog must never half-apply a
  // choice.
  importSwapAxisYZ = swapAxisBox.isSelected();
  daeImportCurves = curvesBox.isSelected();
  importExtraParams = extraParamsBox.isSelected();

  return true;
}

// Lets the person importing check/uncheck the same importSwapAxisYZ
// checkbox axisSwapShowImportOptionsDialog() above offers STL,
// alongside plyImportCurves (see importPly.pde's own
// PLY_IMPORT_CURVES/plyImportCurves - same constant-for-the-starting-
// value, variable-for-what's-actually-checked shape as objImportCurves/
// dxfImportCurves/glbImportCurves/daeImportCurves just above). PLY
// needs its own dialog (not that shared one) for the same "one extra
// option beside the swap checkbox" reason
// objShowImportOptionsDialog()/dxfShowImportOptionsDialog()/
// glbShowImportOptionsDialog()/daeShowImportOptionsDialog() just above
// do. Called from import_objects_PLY() itself (importPly.pde), not
// from here - same reasoning, and the same "a cancelled dialog must
// never half-apply a choice" behavior, as those dialogs' own comments
// above.
boolean plyShowImportOptionsDialog () {

  javax.swing.JCheckBox swapAxisBox = new javax.swing.JCheckBox("Rotate Y-up to Z-up (swap Y/Z axes)", importSwapAxisYZ);
  javax.swing.JCheckBox curvesBox = new javax.swing.JCheckBox("Import lines ('edge' elements)", plyImportCurves);

  javax.swing.JPanel panel = new javax.swing.JPanel(new java.awt.GridLayout(0, 1));
  panel.add(swapAxisBox);
  panel.add(curvesBox);

  int result = javax.swing.JOptionPane.showConfirmDialog(
    null, panel, "PLY import options", javax.swing.JOptionPane.OK_CANCEL_OPTION, javax.swing.JOptionPane.PLAIN_MESSAGE);

  if (result != javax.swing.JOptionPane.OK_OPTION) return false;

  // Left exactly where they were unless this dialog's own OK button is
  // actually pressed - a cancelled dialog must never half-apply a
  // choice.
  importSwapAxisYZ = swapAxisBox.isSelected();
  plyImportCurves = curvesBox.isSelected();

  return true;
}

// Lets the person importing check/uncheck ifcImportFurniture/
// ifcImportOrient/ifcImportRelocate/ifcImportIndoorSpace/
// ifcImportOutdoorSpace/ifcImportCurves (see importIfc.pde's own
// IFC_IMPORT_FURNITURE/IFC_IMPORT_NORTH/IFC_IMPORT_GOTO_LATLON/
// IFC_IMPORT_INDOOR_SPACE/IFC_IMPORT_OUTDOOR_SPACE/IFC_IMPORT_CURVES -
// these six variables are what actually gets checked at import time,
// those constants are only their starting values). Called from
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
  javax.swing.JCheckBox curvesBox = new javax.swing.JCheckBox("Import lines, arcs and curves (annotation geometry)", ifcImportCurves);
  javax.swing.JCheckBox extraParamsBox = new javax.swing.JCheckBox("Import extra metadata (GlobalId, Name, Description, ObjectType) as extraParams", importExtraParams);

  javax.swing.JPanel panel = new javax.swing.JPanel(new java.awt.GridLayout(0, 1));
  panel.add(furnitureBox);
  panel.add(orientBox);
  panel.add(relocateBox);
  panel.add(indoorSpaceBox);
  panel.add(outdoorSpaceBox);
  panel.add(curvesBox);
  panel.add(extraParamsBox);

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
  ifcImportCurves = curvesBox.isSelected();
  importExtraParams = extraParamsBox.isSelected();

  return true;
}

void selectFile_ImportIfc () {
  // Arms ifcImportShowOptionsDialog (importIfc.pde) so the
  // options dialog shows once the file this picks is actually about to
  // be imported, not here - see that variable's own comment for why.
  ifcImportShowOptionsDialog = true;
  // Same reasoning as selectFile_ImportObj()'s own identical line
  // (fileSelected.pde, above selectFile_ImportGlb()).
  isImportingInProgress = true;
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
  javax.swing.JCheckBox extraParamsBox = new javax.swing.JCheckBox("Import extra metadata (the Surface's own id) as extraParams", importExtraParams);

  javax.swing.JPanel panel = new javax.swing.JPanel(new java.awt.GridLayout(0, 1));
  panel.add(orientBox);
  panel.add(relocateBox);
  panel.add(extraParamsBox);

  int result = javax.swing.JOptionPane.showConfirmDialog(
    null, panel, "gbXML import options", javax.swing.JOptionPane.OK_CANCEL_OPTION, javax.swing.JOptionPane.PLAIN_MESSAGE);

  if (result != javax.swing.JOptionPane.OK_OPTION) return false;

  gbxmlImportOrient = orientBox.isSelected();
  gbxmlImportRelocate = relocateBox.isSelected();
  importExtraParams = extraParamsBox.isSelected();

  return true;
}

void selectFile_ImportGbxml () {
  // Arms gbxmlImportShowOptionsDialog (importGbxml.pde) the
  // same way selectFile_ImportIfc() above arms ifcImportShowOptionsDialog
  // for its own options.
  gbxmlImportShowOptionsDialog = true;
  // Same reasoning as selectFile_ImportObj()'s own identical line
  // (fileSelected.pde, above selectFile_ImportGlb()).
  isImportingInProgress = true;
  selectInput("Select gbXML file to import:", "_fileSelected_ImportGbxml", new File(Folder_Import + "/_.xml"));
}

// Lets the person importing check/uncheck lasImportMeshPointCloud (see
// importLas.pde's own LAS_IMPORT_MESH_POINT_CLOUD/lasImportMeshPointCloud -
// same "a constant for the starting value, a variable for what's
// actually checked at import time" shape IFC_IMPORT_FURNITURE/
// ifcImportFurniture already use), alongside the same Y/Z-swap checkbox
// axisSwapShowImportOptionsDialog() above already offers STL
// (OBJ, DXF, GLB, DAE and PLY each have their own dialog for the same
// reason, see objShowImportOptionsDialog()'s/dxfShowImportOptionsDialog()'s/
// glbShowImportOptionsDialog()'s/daeShowImportOptionsDialog()'s/
// plyShowImportOptionsDialog()'s own comments above) - LAS needs its
// own dialog (not that shared one)
// purely because it has this one extra option beside the swap
// checkbox, the same reason ifcShowImportOptionsDialog()'s/
// gbxmlShowImportOptionsDialog()'s own dialogs just above are each
// their own function instead of reusing it. Called from
// import_objects_LAS() itself (importLas.pde), not
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
  // Same reasoning as selectFile_ImportObj()'s own identical line
  // (fileSelected.pde, above selectFile_ImportGlb()).
  isImportingInProgress = true;
  selectInput("Select LAS file to import:", "_fileSelected_ImportLas", new File(Folder_Import + "/_.las"));
}

void selectFile_RunScript () {
  // See isFileOperationInProgress's own comment (globalFunctions.pde)
  // for why - set here too, not just inside _fileSelected_RunScript()
  // itself, so the UI is disabled for the native dialog's own open/
  // pick/cancel window as well; _fileSelected_RunScript() clears it
  // again on every outcome.
  isFileOperationInProgress = true;
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

    deleteAll();

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

  // See isImportingInProgress's own comment (globalFunctions.pde) for
  // why - set here too (not just in selectFile_ImportObj(), above),
  // since extraCommands.pde's own console IMPORT_OBJ command can reach
  // this function directly, with a path already given, bypassing
  // selectFile_ImportObj() and its own dialog entirely. Cleared at each
  // of this function's own 2 exit points below.
  isImportingInProgress = true;

  String Filename = "";

  if (selectedFile == null) {
    // Same reasoning as _fileSelected_ImportIfc()'s own identical line
    // below: cancelling the native file chooser itself never reaches
    // import_objects_OBJ(), which is otherwise what consumes
    // objImportShowOptionsDialog - without this, it would stay armed and
    // pop the options dialog up on the next import_objects_OBJ() call
    // regardless of how that one was started.
    objImportShowOptionsDialog = false;
    isImportingInProgress = false;
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

    isImportingInProgress = false;
  }
}

void _fileSelected_ImportGlb (File selectedFile) {

  // See isImportingInProgress's own comment (globalFunctions.pde) for
  // why - set here too (not just in selectFile_ImportGlb(), above),
  // since extraCommands.pde's own console IMPORT_GLB command can reach
  // this function directly, with a path already given, bypassing
  // selectFile_ImportGlb() and its own dialog entirely. Cleared at each
  // of this function's own 2 exit points below.
  isImportingInProgress = true;

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
    isImportingInProgress = false;
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

    isImportingInProgress = false;
  }
}

void _fileSelected_ImportStl (File selectedFile) {

  // See isImportingInProgress's own comment (globalFunctions.pde) for
  // why - set here too (not just in selectFile_ImportStl(), above),
  // since extraCommands.pde's own console IMPORT_STL command can reach
  // this function directly, with a path already given, bypassing
  // selectFile_ImportStl() and its own dialog entirely. Cleared at each
  // of this function's own 2 exit points below.
  isImportingInProgress = true;

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
    isImportingInProgress = false;
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

    isImportingInProgress = false;
  }
}

void _fileSelected_ImportDxf (File selectedFile) {

  // See isImportingInProgress's own comment (globalFunctions.pde) for
  // why - set here too (not just in selectFile_ImportDxf(), above),
  // since extraCommands.pde's own console IMPORT_DXF command can reach
  // this function directly, with a path already given, bypassing
  // selectFile_ImportDxf() and its own dialog entirely. Cleared at each
  // of this function's own 2 exit points below.
  isImportingInProgress = true;

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
    isImportingInProgress = false;
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

    isImportingInProgress = false;
  }
}

void _fileSelected_ImportGeojson (File selectedFile) {

  // See isImportingInProgress's own comment (globalFunctions.pde) for
  // why - set here too (not just in selectFile_ImportGeojson(), above),
  // since extraCommands.pde's own console IMPORT.GEOJSON command can
  // reach this function directly, with a path already given, bypassing
  // selectFile_ImportGeojson() and its own dialog entirely. Cleared at
  // each of this function's own 2 exit points below.
  isImportingInProgress = true;

  String Filename = "";

  if (selectedFile == null) {
    // Same reasoning as _fileSelected_ImportDxf()'s own identical lines
    // above: cancelling the native file chooser itself never reaches
    // import_objects_GEOJSON(), which is otherwise what consumes
    // geojsonImportShowOptionsDialog - without this, it would stay
    // armed and pop the options dialog up on the next
    // import_objects_GEOJSON() call regardless of how that one was
    // started.
    geojsonImportShowOptionsDialog = false;
    isImportingInProgress = false;
  } else {
    Filename = _getSelectedFile(selectedFile);
    beginScene3DChange();

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("\nImporting:", Filename);

    int number_of_allGroups_before = allGroups.num;

    import_objects_GEOJSON(Filename, User3D.creatorMaterial, User3D.creatorTessellation, User3D.creatorLayer, User3D.creatorVisibility, User3D.creatorWeight, User3D.creatorClosed, 0, 0, 0, 1, 1, 1); // apply default material

    // Same reason as import_objects_OBJ()'s/import_objects_DXF()'s own
    // calls just above this one's siblings - import_objects_GEOJSON()
    // adds points/faces/polylines straight into allPoints/allFaces/
    // allPolylines without ever calling endScene3DChange() itself.
    endScene3DChange();

    int number_of_allGroups_after = allGroups.num;

    Select3D.groupSelection = new int [1 + number_of_allGroups_after - number_of_allGroups_before];
    for (int i = 0; i < Select3D.groupSelection.length - 1; i++) {
      Select3D.groupSelection[i] = i + number_of_allGroups_before;
    }

    switch_category(ObjectCategory.GROUP);

    isImportingInProgress = false;
  }
}

void _fileSelected_ImportTopojson (File selectedFile) {

  // See isImportingInProgress's own comment (globalFunctions.pde) for
  // why - set here too (not just in selectFile_ImportTopojson(), above),
  // since extraCommands.pde's own console IMPORT.TOPOJSON command can
  // reach this function directly, with a path already given, bypassing
  // selectFile_ImportTopojson() and its own dialog entirely. Cleared at
  // each of this function's own 2 exit points below.
  isImportingInProgress = true;

  String Filename = "";

  if (selectedFile == null) {
    // Same reasoning as _fileSelected_ImportGeojson()'s own identical
    // lines above: cancelling the native file chooser itself never
    // reaches import_objects_TOPOJSON(), which is otherwise what consumes
    // topojsonImportShowOptionsDialog - without this, it would stay
    // armed and pop the options dialog up on the next
    // import_objects_TOPOJSON() call regardless of how that one was
    // started.
    topojsonImportShowOptionsDialog = false;
    isImportingInProgress = false;
  } else {
    Filename = _getSelectedFile(selectedFile);
    beginScene3DChange();

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("\nImporting:", Filename);

    int number_of_allGroups_before = allGroups.num;

    import_objects_TOPOJSON(Filename, User3D.creatorMaterial, User3D.creatorTessellation, User3D.creatorLayer, User3D.creatorVisibility, User3D.creatorWeight, User3D.creatorClosed, 0, 0, 0, 1, 1, 1); // apply default material

    // Same reason as import_objects_GEOJSON()'s own identical call just
    // above - import_objects_TOPOJSON() adds points/faces/polylines
    // straight into allPoints/allFaces/allPolylines without ever calling
    // endScene3DChange() itself.
    endScene3DChange();

    int number_of_allGroups_after = allGroups.num;

    Select3D.groupSelection = new int [1 + number_of_allGroups_after - number_of_allGroups_before];
    for (int i = 0; i < Select3D.groupSelection.length - 1; i++) {
      Select3D.groupSelection[i] = i + number_of_allGroups_before;
    }

    switch_category(ObjectCategory.GROUP);

    isImportingInProgress = false;
  }
}

void _fileSelected_ImportKml (File selectedFile) {

  // See isImportingInProgress's own comment (globalFunctions.pde) for
  // why - set here too (not just in selectFile_ImportKml(), above), since
  // extraCommands.pde's own console IMPORT.KML command can reach this
  // function directly, with a path already given, bypassing
  // selectFile_ImportKml() and its own dialog entirely. Cleared at each
  // of this function's own 2 exit points below.
  isImportingInProgress = true;

  String Filename = "";

  if (selectedFile == null) {
    // Same reasoning as _fileSelected_ImportGeojson()'s own identical
    // lines above: cancelling the native file chooser itself never
    // reaches import_objects_KML(), which is otherwise what consumes
    // kmlImportShowOptionsDialog - without this, it would stay armed and
    // pop the options dialog up on the next import_objects_KML() call
    // regardless of how that one was started.
    kmlImportShowOptionsDialog = false;
    isImportingInProgress = false;
  } else {
    Filename = _getSelectedFile(selectedFile);
    beginScene3DChange();

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("\nImporting:", Filename);

    int number_of_allGroups_before = allGroups.num;

    import_objects_KML(Filename, User3D.creatorMaterial, User3D.creatorTessellation, User3D.creatorLayer, User3D.creatorVisibility, User3D.creatorWeight, User3D.creatorClosed, 0, 0, 0, 1, 1, 1); // apply default material

    // Same reason as import_objects_GEOJSON()'s own identical call above -
    // import_objects_KML() adds points/faces/polylines straight into
    // allPoints/allFaces/allPolylines without ever calling
    // endScene3DChange() itself.
    endScene3DChange();

    int number_of_allGroups_after = allGroups.num;

    Select3D.groupSelection = new int [1 + number_of_allGroups_after - number_of_allGroups_before];
    for (int i = 0; i < Select3D.groupSelection.length - 1; i++) {
      Select3D.groupSelection[i] = i + number_of_allGroups_before;
    }

    switch_category(ObjectCategory.GROUP);

    isImportingInProgress = false;
  }
}

void _fileSelected_ImportCitygml (File selectedFile) {

  // See isImportingInProgress's own comment (globalFunctions.pde) for why -
  // set here too (not just in selectFile_ImportCitygml(), above), since
  // extraCommands.pde's own console IMPORT.CITYGML command can reach this
  // function directly, with a path already given, bypassing
  // selectFile_ImportCitygml() and its own dialog entirely. Cleared at each
  // of this function's own 2 exit points below.
  isImportingInProgress = true;

  String Filename = "";

  if (selectedFile == null) {
    // Same reasoning as _fileSelected_ImportGeojson()'s own identical
    // lines above: cancelling the native file chooser itself never
    // reaches import_objects_CITYGML(), which is otherwise what consumes
    // citygmlImportShowOptionsDialog - without this, it would stay armed
    // and pop the options dialog up on the next import_objects_CITYGML()
    // call regardless of how that one was started.
    citygmlImportShowOptionsDialog = false;
    isImportingInProgress = false;
  } else {
    Filename = _getSelectedFile(selectedFile);
    beginScene3DChange();

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("\nImporting:", Filename);

    int number_of_allGroups_before = allGroups.num;

    import_objects_CITYGML(Filename, User3D.creatorMaterial, User3D.creatorTessellation, User3D.creatorLayer, User3D.creatorVisibility, User3D.creatorWeight, User3D.creatorClosed, 0, 0, 0, 1, 1, 1); // apply default material

    // Same reason as import_objects_GEOJSON()'s own identical call above -
    // import_objects_CITYGML() adds points/faces/polylines straight into
    // allPoints/allFaces/allPolylines without ever calling
    // endScene3DChange() itself.
    endScene3DChange();

    int number_of_allGroups_after = allGroups.num;

    Select3D.groupSelection = new int [1 + number_of_allGroups_after - number_of_allGroups_before];
    for (int i = 0; i < Select3D.groupSelection.length - 1; i++) {
      Select3D.groupSelection[i] = i + number_of_allGroups_before;
    }

    switch_category(ObjectCategory.GROUP);

    isImportingInProgress = false;
  }
}

void _fileSelected_ImportShapefile (File selectedFile) {

  // See isImportingInProgress's own comment (globalFunctions.pde) for why -
  // set here too (not just in selectFile_ImportShapefile(), above), since
  // extraCommands.pde's own console IMPORT.SHAPEFILE command can reach this
  // function directly, with a path already given, bypassing
  // selectFile_ImportShapefile() and its own dialog entirely. Cleared at
  // each of this function's own 2 exit points below.
  isImportingInProgress = true;

  String Filename = "";

  if (selectedFile == null) {
    // Same reasoning as _fileSelected_ImportGeojson()'s own identical
    // lines above: cancelling the native file chooser itself never
    // reaches import_objects_SHP(), which is otherwise what consumes
    // shpImportShowOptionsDialog - without this, it would stay armed and
    // pop the options dialog up on the next import_objects_SHP() call
    // regardless of how that one was started.
    shpImportShowOptionsDialog = false;
    isImportingInProgress = false;
  } else {
    Filename = _getSelectedFile(selectedFile);
    beginScene3DChange();

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("\nImporting:", Filename);

    int number_of_allGroups_before = allGroups.num;

    import_objects_SHP(Filename, User3D.creatorMaterial, User3D.creatorTessellation, User3D.creatorLayer, User3D.creatorVisibility, User3D.creatorWeight, User3D.creatorClosed, 0, 0, 0, 1, 1, 1); // apply default material

    // Same reason as import_objects_GEOJSON()'s own identical call above -
    // import_objects_SHP() adds points/faces/polylines straight into
    // allPoints/allFaces/allPolylines without ever calling
    // endScene3DChange() itself.
    endScene3DChange();

    int number_of_allGroups_after = allGroups.num;

    Select3D.groupSelection = new int [1 + number_of_allGroups_after - number_of_allGroups_before];
    for (int i = 0; i < Select3D.groupSelection.length - 1; i++) {
      Select3D.groupSelection[i] = i + number_of_allGroups_before;
    }

    switch_category(ObjectCategory.GROUP);

    isImportingInProgress = false;
  }
}

void _fileSelected_ImportSvg (File selectedFile) {

  // See isImportingInProgress's own comment (globalFunctions.pde) for why -
  // set here too (not just in selectFile_ImportSvg(), above), since
  // extraCommands.pde's own console IMPORT.SVG command can reach this
  // function directly, with a path already given, bypassing
  // selectFile_ImportSvg() and its own dialog entirely. Cleared at each of
  // this function's own 2 exit points below.
  isImportingInProgress = true;

  String Filename = "";

  if (selectedFile == null) {
    // Same reasoning as _fileSelected_ImportGeojson()'s own identical
    // lines above: cancelling the native file chooser itself never
    // reaches import_objects_SVG(), which is otherwise what consumes
    // svgImportShowOptionsDialog - without this, it would stay armed and
    // pop the options dialog up on the next import_objects_SVG() call
    // regardless of how that one was started.
    svgImportShowOptionsDialog = false;
    isImportingInProgress = false;
  } else {
    Filename = _getSelectedFile(selectedFile);
    beginScene3DChange();

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("\nImporting:", Filename);

    int number_of_allGroups_before = allGroups.num;

    import_objects_SVG(Filename, User3D.creatorMaterial, User3D.creatorTessellation, User3D.creatorLayer, User3D.creatorVisibility, User3D.creatorWeight, User3D.creatorClosed, 0, 0, 0, 1, 1, 1); // apply default material

    // Same reason as import_objects_GEOJSON()'s own identical call above -
    // import_objects_SVG() adds points/faces/polylines straight into
    // allPoints/allFaces/allPolylines without ever calling
    // endScene3DChange() itself.
    endScene3DChange();

    int number_of_allGroups_after = allGroups.num;

    Select3D.groupSelection = new int [1 + number_of_allGroups_after - number_of_allGroups_before];
    for (int i = 0; i < Select3D.groupSelection.length - 1; i++) {
      Select3D.groupSelection[i] = i + number_of_allGroups_before;
    }

    switch_category(ObjectCategory.GROUP);

    isImportingInProgress = false;
  }
}

void _fileSelected_ImportPly (File selectedFile) {

  // See isImportingInProgress's own comment (globalFunctions.pde) for
  // why - set here too (not just in selectFile_ImportPly(), above),
  // since extraCommands.pde's own console IMPORT_PLY command can reach
  // this function directly, with a path already given, bypassing
  // selectFile_ImportPly() and its own dialog entirely. Cleared at each
  // of this function's own 2 exit points below.
  isImportingInProgress = true;

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
    isImportingInProgress = false;
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

    isImportingInProgress = false;
  }
}

void _fileSelected_ImportDae (File selectedFile) {

  // See isImportingInProgress's own comment (globalFunctions.pde) for
  // why - set here too (not just in selectFile_ImportDae(), above),
  // since extraCommands.pde's own console IMPORT_DAE command can reach
  // this function directly, with a path already given, bypassing
  // selectFile_ImportDae() and its own dialog entirely. Cleared at each
  // of this function's own 2 exit points below.
  isImportingInProgress = true;

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
    isImportingInProgress = false;
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

    isImportingInProgress = false;
  }
}

void _fileSelected_ImportIfc (File selectedFile) {

  // See isImportingInProgress's own comment (globalFunctions.pde) for
  // why - set here too (not just in selectFile_ImportIfc(), above),
  // since extraCommands.pde's own console IMPORT_IFC command can reach
  // this function directly, with a path already given, bypassing
  // selectFile_ImportIfc() and its own dialog entirely. Cleared at each
  // of this function's own 2 exit points below.
  isImportingInProgress = true;

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
    isImportingInProgress = false;
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

    isImportingInProgress = false;
  }
}

void _fileSelected_ImportGbxml (File selectedFile) {

  // See isImportingInProgress's own comment (globalFunctions.pde) for
  // why - set here too (not just in selectFile_ImportGbxml(), above),
  // since extraCommands.pde's own console IMPORT_GBXML command can
  // reach this function directly, with a path already given, bypassing
  // selectFile_ImportGbxml() and its own dialog entirely. Cleared at
  // each of this function's own 2 exit points below.
  isImportingInProgress = true;

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
    isImportingInProgress = false;
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

    isImportingInProgress = false;
  }
}

void _fileSelected_ImportLas (File selectedFile) {

  // See isImportingInProgress's own comment (globalFunctions.pde) for
  // why - set here too (not just in selectFile_ImportLas(), above),
  // since extraCommands.pde's own console IMPORT_LAS command can reach
  // this function directly, with a path already given, bypassing
  // selectFile_ImportLas() and its own dialog entirely. Cleared at each
  // of this function's own 2 exit points below.
  isImportingInProgress = true;

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
    isImportingInProgress = false;
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

    isImportingInProgress = false;
  }
}

void _fileSelected_RunScript (File selectedFile) {

  // See isFileOperationInProgress's own comment (globalFunctions.pde)
  // for why - set here too (not just in selectFile_RunScript(), above),
  // since extraCommands.pde's own console RUN command can reach this
  // function directly, with a path already given, bypassing
  // selectFile_RunScript() and its own dialog entirely. Cleared at each
  // of this function's own 2 exit points below.
  isFileOperationInProgress = true;

  String Filename = "";

  if (selectedFile == null) {
    isFileOperationInProgress = false;
  } else {
    Filename = _getSelectedFile(selectedFile);

    println("\nExecuting:", Filename);

    runScriptFile(Filename);

    isFileOperationInProgress = false;
  }
}

String _getSelectedFile(File selectedFile) {
  return selectedFile.getAbsolutePath().replace(char(92), '/');
}
