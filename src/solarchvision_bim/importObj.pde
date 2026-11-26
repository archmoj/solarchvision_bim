// One-shot: whether the very next import_objects_OBJ() call should open
// axisSwapShowImportOptionsDialog() (fileSelected.pde) before doing
// anything else - armed only by selectFile_ImportObj(), the real,
// interactive "pick a file from the menu" path, same shape as
// ifcImportShowOptionsDialog (importIfc.pde) for IFC's own
// options. Defaults to (and, every other way import_objects_OBJ() can be
// reached - a script's own IMPORT_OBJ command, or a test calling
// import_objects_OBJ() directly - stays) false, so none of those paths
// ever see a dialog pop up.
boolean objImportShowOptionsDialog = false;

// Whether to also read OBJ's own "l v1 v2 ..." line statement as a
// Polyline (polylines.pde) - off by default, same "a constant for the
// starting value, a variable for what's actually checked at import
// time" shape IFC_IMPORT_CURVES/ifcImportCurves (importIfc.pde) and
// DXF_IMPORT_CURVES/dxfImportCurves (importDxf.pde) already use. OBJ
// has no arc/curve concept of its own at all (unlike DXF's CIRCLE/ARC) -
// just this one line-segment-chain statement, referencing vertices the
// file's own "v" lines already defined - so "lines, arcs, curves" for
// OBJ means exactly this one statement; see objHandleLine()'s own
// comment, below, for exactly what it does with it.
final boolean OBJ_IMPORT_CURVES = false;

boolean objImportCurves = OBJ_IMPORT_CURVES;

void import_objects_OBJ (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  // Consumed (reset) here regardless of whether the dialog is shown or
  // how the person answers it - see ifcImportShowOptionsDialog's own
  // comment (importIfc.pde) for why this sits after FileName is
  // already a real path on disk, not back when selectFile_ImportObj()
  // first asked for one. A cancelled dialog aborts the whole import
  // immediately, before touching allPoints/allFaces or printing anything
  // below - as if import_objects_OBJ() had never been called at all.
  if (objImportShowOptionsDialog) {
    objImportShowOptionsDialog = false;
    if (!objShowImportOptionsDialog()) return;
  }

  println("\nImporting OBJ. Please wait...");
  showWaitCursor();
  isImportingInProgress = true; // see this flag's own comment (globalFunctions.pde) for why - bare statement (this function has only the one exit point below, so nothing further to guard); cleared alongside showArrowCursor() at this function's own end

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

  // Step 5's own OBJ capture - the most recent "g <name>"/"o <name>"
  // statement's own name (null until the file's first one, if any),
  // reapplied as every subsequently-created Face's/Polyline's own
  // extraParams below (objNameToExtraParams()'s own comment) - "g" alone
  // still drives this import's own existing group/material-cycling
  // behavior (unchanged), "o" only ever updates this name.
  String objCurrentGroupName = null;

  String[] FileALL = loadStrings(FileName);
  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  float totalLines = FileALL.length; // computed once, not every iteration
  float Progress = 0;
  float printed_Progress = 0;
  boolean aborted = false;

  progressBarHeader();

  // showImportProgress (globals.pde's own comment) - ProgressWindow
  // (progressWindow.pde), updated inline alongside the existing console
  // bar's own delta >= 1 throttle, same shape as calculate_VertexSolar_
  // array.pde's own. Wrapped in try/finally (this loop is short enough
  // that doing so safely doesn't mean re-indenting hundreds of lines,
  // unlike solarImpacts.pde's own calculate_Impact_CurrentPreBaked(),
  // which left its own cleanup as a bare statement instead for exactly
  // that reason).
  ProgressWindow importProgressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("\nImporting OBJ") : null;
  if (importProgressWindow != null) importProgressWindow.setVisible(true);

  try {
    for (int f = 0; f < FileALL.length; f++) {
      // Esc, caught by importProgressWindow's own Toolkit-level listener
      // (progressWindow.pde) regardless of which window has focus. No
      // rollback on abort - whatever points/faces were already created
      // from the lines read so far are kept, same as any other partial
      // import; the person can undo it themselves if they don't want it.
      if ((importProgressWindow != null) && importProgressWindow.abortRequested) {
        echoAbortProgress();
        aborted = true;
        break;
      }

      if (control != USER_AUTO) {
        Progress = 100 * f / totalLines;
        int delta = (int) floor(Progress - printed_Progress);
        if (delta >= 1) {
          printProgressBarChunk(delta); // one print() call instead of `delta` calls
          printed_Progress = floor(Progress);
          if (importProgressWindow != null) importProgressWindow.updateFraction(Progress / 100.0f);
        }
      }

      String lineSTR = FileALL[f];

    String[] parts = splitTokens(lineSTR);
    if (parts == null || parts.length == 0) continue; // skip blank lines

    String tag = parts[0];

    if (tag.equalsIgnoreCase("g")) {
      objCurrentGroupName = (parts.length > 1) ? parts[1] : null;
      if (m == -1) current_Material = 1 + (current_Material % 8);
      if (addToLastGroup == false) allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    } else if (tag.equalsIgnoreCase("o")) {
      objCurrentGroupName = (parts.length > 1) ? parts[1] : null;
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
      // Set right before, reset right after - current_ExtraParams must
      // never leak into the next, unrelated piece of geometry someone
      // creates (its own comment, globalVariables.pde).
      current_ExtraParams = objNameToExtraParams(objCurrentGroupName);
      allFaces.create(newFace);
      current_ExtraParams = "";
    } else if (objImportCurves && tag.equalsIgnoreCase("l")) {
      objHandleLine(parts, importVerticeNumber, objCurrentGroupName);
    }
    // any other tag (vt, vn, usemtl, mtllib, #comment, ...) is
    // intentionally ignored - and, while objImportCurves is false
    // (the default), "l" is ignored right along with them.
    }
  } finally {
    if (importProgressWindow != null) importProgressWindow.dispose();
  }

  if (!aborted) {
    int remaining = (int) floor(100 - printed_Progress);
    printProgressBarChunk(remaining);
    println();
  }

  isImportingInProgress = false;
  showArrowCursor();
}

// Reads one "l v1 v2 v3 ..." line statement as a single Polyline
// (polylines.pde) through the file's own already-imported vertices,
// only called while objImportCurves is true (see its own comment
// above). Unlike add_Polyline()/add_Spline() (which each take raw
// float[][] points and create brand-new allPoints entries for them),
// this resolves each reference the exact same way the "f" tag's own
// branch above already does - through importVerticeNumber for a
// positive (1-based) index, or allPoints.getLength() - abs(n) for a
// negative (relative-to-the-current-end-of-file) one - since an "l"
// statement's vertices are never new points of their own, only
// references into the ones "v" already created, so allPolylines.
// create(int[]) (an existing point-index array, no new allPoints
// entries) is the right primitive here, not add_Polyline().
//
// OBJ has no separate "closed" flag anywhere in its own "l" syntax -
// some writers close a loop by simply repeating the first vertex as
// the last one, so that repetition (not current_Closed, the global
// set once for the whole import from this call's own clz parameter)
// is what actually decides it here, the same auto-detect-and-dedup
// convention dxfEmitPolyline() (importDxf.pde) and ifcEmitCurve()
// (importIfc.pde) each already use for their own formats.
// Builds this Face's/Polyline's own raw extraParams string from the
// name of the "g"/"o" statement it fell under (objCurrentGroupName,
// above) - gated by the shared importExtraParams checkbox (fileSelected.
// pde), same "" (this field's own default/"nothing here" value) whenever
// that's unchecked or no name has been read yet that
// geojsonPropertiesToExtraParams()/svgIdToExtraParams()/
// dxfLayerToExtraParams() (importGeojson.pde/importSvg.pde/importDxf.pde)
// already follow for their own formats.
String objNameToExtraParams (String name) {
  if (!importExtraParams || name == null || name.trim().length() == 0) return "";
  JSONObject obj = new JSONObject();
  obj.setString("name", name);
  return obj.toString();
}

void objHandleLine (String[] parts, IntList importVerticeNumber, String groupName) {

  int count = parts.length - 1;
  if (count < 2) return; // not even one real segment

  int[] refs = new int[count];
  for (int n = 0; n < count; n++) {
    String[] the_numbers = split(parts[n + 1], '/');
    int vertexNumber = int(the_numbers[0]);
    if (vertexNumber > 0) {
      refs[n] = importVerticeNumber.get(vertexNumber);
    } else if (vertexNumber < 0) { // negative (relative) indexing
      refs[n] = allPoints.getLength() - abs(vertexNumber);
    } // vertexNumber == 0: leave as default (0), same as the "f" branch above
  }

  boolean closed = (refs.length > 2) && (refs[0] == refs[refs.length - 1]);
  int[] nodes = closed ? java.util.Arrays.copyOf(refs, refs.length - 1) : refs;
  if (nodes.length < 2) return;

  // allPolylines.create(int[]) (polylines.pde) reads current_Material/
  // Tessellation/Layer/Visibility/Weight/Closed/CurveType/IsArc off
  // their own globals at call time - all of them already set, for this
  // whole import, right above this function's own caller (m/tes/lyr/
  // vsb/wgt - current_Closed too, from this call's own clz parameter) -
  // except current_Closed, which this one Polyline's own detected
  // closedness overrides just for this call, then restores, so a later
  // "l" statement (or anything else reading current_Closed) still sees
  // whatever this whole import's own clz parameter actually said.
  int savedClosed = current_Closed;
  current_Closed = closed ? 1 : 0;
  current_ExtraParams = objNameToExtraParams(groupName);
  allPolylines.create(nodes);
  current_ExtraParams = "";
  current_Closed = savedClosed;
}
