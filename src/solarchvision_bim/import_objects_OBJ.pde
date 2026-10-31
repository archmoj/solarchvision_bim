// One-shot: whether the very next import_objects_OBJ() call should open
// objGlbShowImportOptionsDialog() (fileSelected.pde) before doing
// anything else - armed only by selectFile_ImportObj(), the real,
// interactive "pick a file from the menu" path, same shape as
// ifcImportShowOptionsDialog (import_objects_IFC.pde) for IFC's own
// options. Defaults to (and, every other way import_objects_OBJ() can be
// reached - a script's own IMPORT_OBJ command, or a test calling
// import_objects_OBJ() directly - stays) false, so none of those paths
// ever see a dialog pop up.
boolean objImportShowOptionsDialog = false;

void import_objects_OBJ (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  // Consumed (reset) here regardless of whether the dialog is shown or
  // how the person answers it - see ifcImportShowOptionsDialog's own
  // comment (import_objects_IFC.pde) for why this sits after FileName is
  // already a real path on disk, not back when selectFile_ImportObj()
  // first asked for one. A cancelled dialog aborts the whole import
  // immediately, before touching allPoints/allFaces or printing anything
  // below - as if import_objects_OBJ() had never been called at all.
  if (objImportShowOptionsDialog) {
    objImportShowOptionsDialog = false;
    if (!objGlbShowImportOptionsDialog("OBJ import options")) return;
  }

  println("Importing OBJ. Please wait...");
  showWaitCursor();

  if (m == -1) current_Material = 0;
  else current_Material = m;

  current_Tessellation = tes;
  current_Layer = lyr;
  current_Visibility = vsb;
  current_Weight = wgt;
  current_Closed = clz;

  // OBJ vertex indices are 1-based, so index 0 is an unused placeholder,

  IntList importVerticeNumber = new IntList();
  importVerticeNumber.append(0);

  String[] FileALL = loadStrings(FileName);
  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  float totalLines = FileALL.length; // computed once, not every iteration
  float Progress = 0;
  float printed_Progress = 0;
  StringBuilder barBuffer = new StringBuilder();

  progressBarHeader();

  // showImportProgress (globals.pde's own comment) - ProgressWindow
  // (preBakeViewport.pde), updated inline alongside the existing console
  // bar's own delta >= 1 throttle, same shape as calculate_VertexSolar_
  // array.pde's own. Wrapped in try/finally (this loop is short enough
  // that doing so safely doesn't mean re-indenting hundreds of lines,
  // unlike SolarImpacts.pde's own calculate_Impact_CurrentPreBaked(),
  // which left its own cleanup as a bare statement instead for exactly
  // that reason).
  ProgressWindow importProgressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("Importing OBJ") : null;
  if (importProgressWindow != null) importProgressWindow.setVisible(true);

  try {
    for (int f = 0; f < FileALL.length; f++) {
      if (control != USER_AUTO) {
        Progress = 100 * f / totalLines;
        int delta = (int) floor(Progress - printed_Progress);
        if (delta >= 1) {
          barBuffer.setLength(0);
          for (int c = 0; c < delta; c++) {
            barBuffer.append('█');
          }
          print(barBuffer.toString()); // one print() call instead of `delta` calls
          printed_Progress = floor(Progress);
          if (importProgressWindow != null) importProgressWindow.updateFraction(Progress / 100.0f);
        }
      }

      String lineSTR = FileALL[f];

    String[] parts = splitTokens(lineSTR);
    if (parts == null || parts.length == 0) continue; // skip blank lines

    String tag = parts[0];

    if (tag.equalsIgnoreCase("g")) {
      if (m == -1) current_Material = 1 + (current_Material % 8);
      if (addToLastGroup == false) allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    } else if (tag.equalsIgnoreCase("v")) {
      float x = cx + sx * float(parts[1]);
      float y = cy + sy * float(parts[2]);
      float z = cz + sz * float(parts[3]);
      // importSwapAxisYZ (fileSelected.pde) - off by default, so this
      // stays the plain passthrough it already was.
      if (importSwapAxisYZ) {
        importVerticeNumber.append(allPoints.create(x, -z, y));
      } else {
        importVerticeNumber.append(allPoints.create(x, y, z));
      }
    } else if (tag.equalsIgnoreCase("f")) {
      int FaceDegree = parts.length - 1;
      int[] newFace = new int[FaceDegree];
      for (int n = 0; n < newFace.length; n++) {
        String[] the_numbers = split(parts[n + 1], '/');
        int vertexNumber = int(the_numbers[0]);
        if (vertexNumber > 0) {
          newFace[n] = importVerticeNumber.get(vertexNumber);
        } else if (vertexNumber < 0) { // negative (relative) indexing
          newFace[n] = allPoints.getLength() - abs(vertexNumber);
        } // vertexNumber == 0: leave as default (0)
      }
      allFaces.create(newFace);
    }
    // any other tag (vt, vn, usemtl, mtllib, #comment, ...) is intentionally
    // ignored.
    }
  } finally {
    if (importProgressWindow != null) importProgressWindow.dispose();
  }

  int remaining = (int) floor(100 - printed_Progress);
  barBuffer.setLength(0);
  for (int c = 0; c < remaining; c++) {
    barBuffer.append('█');
  }
  print(barBuffer.toString());
  println();

  showArrowCursor();
}
