// Minimal, dependency-free importer for a DXF file - the same "hand-roll
// the parser, no external library" choice importObj.pde/
// importIfc.pde/importGlb.pde/importStl.pde
// already make for their own formats. DXF's own spec is proprietary but
// openly published by Autodesk (same status IFC's own STEP format has),
// so this is as feasible to hand-roll as those.
//
// DXF's whole file is a flat sequence of "group code" / "value" pairs,
// each on its own line - this parser pairs those lines up once up front
// (import_objects_DXF()'s own codes[]/values[] arrays, below), then
// walks the result with a single cursor, collecting each "0"-prefixed
// entity's own fields (everything up to
// the next "0") into a pair of small lists and handing them to
// dxfHandleEntity() - the same shape whether that block is a real
// ENTITIES-section entity, a TABLES-section table entry, or a BLOCKS-
// section block definition; only entities actually seen while inside
// the ENTITIES section are dispatched (see the main loop's own
// inEntities tracking) - skipping TABLES/BLOCKS/HEADER/CLASSES/OBJECTS
// entirely, including BLOCKS' own geometry (unplaced block *definitions*,
// not actually placed in the drawing - importing those too would import
// duplicate, wrongly-positioned geometry for anything placed via INSERT).
//
// v1 scope, deliberately kept simple - only entities that actually
// carry solid 3D face geometry:
//   - 3DFACE: a 3- or 4-cornered flat face (DXF's own oldest, simplest
//     way to represent one) - a face with only 3 distinct corners is
//     written either by omitting its 4th point's own group codes
//     (13/23/33) entirely, or - the more common convention - by
//     repeating the 3rd point's coordinates as the 4th; either way
//     becomes a true 3-point face here, not a degenerate quad.
//   - POLYLINE flagged as a "polyface mesh" (group 70, bit 64) followed
//     by a run of VERTEX entities (a mesh's own shared point list, then
//     its own face list - see dxfHandleVertex()'s own comment for how
//     those two kinds of VERTEX record are told apart) and a closing
//     SEQEND - DXF's older, AutoCAD-native equivalent of an indexed
//     mesh (its own MESH entity, introduced far later/ AutoCAD 2010+,
//     isn't read in this version). A plain/2D POLYLINE (the 64 bit not
//     set) is read as a line/arc/curve instead - see the next bullet.
//   - LINE, LWPOLYLINE, a plain/2D POLYLINE (bit 64 NOT set - the one
//     exception to the previous bullet), CIRCLE and ARC - while
//     dxfImportCurves (below) is true, off by default: this is drafting
//     geometry (dimension lines, centerlines, a site-boundary sketch,
//     ...), not solid building fabric, the same reasoning import
//     Ifc.pde's own IFC_IMPORT_CURVES gives for its own, directly
//     analogous toggle. Each imports as one of this app's own native
//     Polylines (polylines.pde) - straight segments for LINE/
//     LWPOLYLINE/POLYLINE (an LWPOLYLINE's own per-vertex bulge, group
//     42 - an arc bulging that one segment - is read nowhere in this
//     version: every LWPOLYLINE segment comes in straight, bulge or
//     not), a tessellated true circle/arc for CIRCLE/ARC (see
//     dxfArcPoints() below - DXF's own always-counterclockwise-from-
//     start-to-end angle convention, same as this app's own funcs.
//     cos_ang()/add_Arc()). LWPOLYLINE/POLYLINE's own "closed" flag
//     (group 70, bit 1) decides whether the resulting Polyline is
//     closed; LINE/ARC always come in open, CIRCLE always closed.
// Every other entity type - SPLINE, MESH, TEXT/MTEXT, DIMENSION, HATCH,
// SOLID, POINT, ELLIPSE, INSERT (block references), ... - is
// intentionally skipped, with or without dxfImportCurves: not solid 3D
// face geometry (or, for INSERT/MESH, a kind this version doesn't
// build), and, for SPLINE/ELLIPSE specifically, a curve shape this
// importer doesn't evaluate even as a line/arc (same "not approximated"
// stance importIfc.pde's own curve reader takes for a B-spline/
// ellipse).
//
// Each entity's own layer (group code 8, "0" if absent) becomes this
// importer's own group/material-cycling boundary - the natural DXF
// equivalent of importObj.pde's own "g" tag/importStl.
// pde's own "solid" block, since CAD users already organize a drawing's
// own geometry by layer far more consistently than by any other
// grouping DXF offers. Applies to LINE/LWPOLYLINE/POLYLINE/CIRCLE/ARC
// the same way it already does to 3DFACE/POLYLINE, while
// dxfImportCurves is true (a layer change those entities can't
// actually produce while it's false - there's no geometry to attach a
// new group to yet).

boolean dxfImportShowOptionsDialog = false;

// Whether to import standalone line/arc/curve ("drafting") geometry at
// all - off by default. See this file's own header comment, just
// above, for exactly which entity types this covers (LINE, LWPOLYLINE,
// a plain/2D POLYLINE, CIRCLE, ARC) and how each one is read; directly
// analogous to importIfc.pde's own IFC_IMPORT_CURVES/ifcImportCurves -
// same "a constant for the starting value, a variable for what's
// actually checked at import time" shape, and the same reasoning for
// starting off (drafting geometry, not building fabric). User-facing
// via dxfShowImportOptionsDialog() (fileSelected.pde), the same way
// IFC's own toggle is.
final boolean DXF_IMPORT_CURVES = false;

boolean dxfImportCurves = DXF_IMPORT_CURVES;

// Transform parameters, the material-cycling flag, and the running
// polyface-mesh/layer state for the CURRENT import_objects_DXF() call -
// same "a few fields shared across one whole import" shape glb_cx/
// glb_cycleMaterial/... (importGlb.pde) already use.
float dxf_cx, dxf_cy, dxf_cz, dxf_sx, dxf_sy, dxf_sz;
boolean dxfCycleMaterial;
String dxfCurrentLayer = null;
boolean dxfPolyfaceActive = false;
IntList dxfPolyfaceLocalPoints = new IntList(); // allPoints indices, in the order this polyface mesh's own coordinate VERTEX records declared them
// A plain/2D POLYLINE's own running VERTEX collection - the "curve"
// counterpart of dxfPolyfaceActive/dxfPolyfaceLocalPoints just above,
// and mutually exclusive with them (see dxfHandlePolylineStart()'s own
// comment): already-transformed WORLD points (not allPoints indices -
// this is only ever turned into a real Polyline by dxfEmitPolyline(),
// at SEQEND, which itself creates the points, the same "world-space
// point list in, allPolylines.add_Polyline() creates the points" shape
// importIfc.pde's own ifcPendingCurvePoints uses), since a plain
// POLYLINE is only ever read at all while dxfImportCurves is true.
boolean dxfPlainPolylineActive = false;
boolean dxfPlainPolylineClosed = false;
ArrayList<float[]> dxfPlainPolylinePoints = new ArrayList<float[]>();
int dxfEntitiesImported = 0;

void import_objects_DXF (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  // Same shape as import_objects_OBJ()'s/import_objects_GLB()'s/
  // import_objects_STL()'s own identical blocks - see any one's own
  // comment, or ifcImportShowOptionsDialog's (importIfc.pde),
  // for why this sits here rather than earlier, and what a cancelled
  // dialog does.
  if (dxfImportShowOptionsDialog) {
    dxfImportShowOptionsDialog = false;
    if (!dxfShowImportOptionsDialog()) return;
  }

  println("\nImporting DXF. Please wait...");
  showWaitCursor();
  isImportingInProgress = true; // see this flag's own comment (globalFunctions.pde) for why - bare statement (this function has only the one exit point below, so nothing further to guard); cleared alongside showArrowCursor() at this function's own end

  dxfCycleMaterial = (m == -1);
  if (m == -1) current_Material = 0;
  else current_Material = m;

  current_Tessellation = tes;
  current_Layer = lyr;
  current_Visibility = vsb;
  current_Weight = wgt;
  current_Closed = clz;

  dxf_cx = cx; dxf_cy = cy; dxf_cz = cz;
  dxf_sx = sx; dxf_sy = sy; dxf_sz = sz;

  dxfCurrentLayer = null;
  dxfPolyfaceActive = false;
  dxfPolyfaceLocalPoints.clear();
  dxfPlainPolylineActive = false;
  dxfPlainPolylineClosed = false;
  dxfPlainPolylinePoints.clear();
  dxfEntitiesImported = 0;

  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  String[] FileALL = loadStrings(FileName);
  if (FileALL == null) FileALL = new String[0];

  // DXF's own group-code/value lines strictly alternate - pair them up
  // once, rather than re-deriving "is this an even or odd line" logic
  // throughout the rest of this file. A trailing, unpaired last line (an
  // odd total count - a truncated/malformed file) is silently dropped
  // here rather than read past the end.
  int pairCount = FileALL.length / 2;
  int[] codes = new int[pairCount];
  String[] values = new String[pairCount];
  for (int i = 0; i < pairCount; i++) {
    codes[i] = int(trim(FileALL[i * 2]));       // int(String) on a malformed line returns 0 rather than throwing - Processing's own documented behavior
    values[i] = trim(FileALL[i * 2 + 1]);
  }

  float totalPairs = pairCount; // computed once, not every iteration - same as importObj.pde's own totalLines
  float Progress = 0;
  float printed_Progress = 0;
  boolean aborted = false;

  progressBarHeader();

  ProgressWindow importProgressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("\nImporting DXF") : null;
  if (importProgressWindow != null) importProgressWindow.setVisible(true);

  try {
    int idx = 0;
    boolean inEntities = false;

    while (idx < pairCount) {
      // Esc, caught by importProgressWindow's own Toolkit-level listener
      // (progressWindow.pde) regardless of which window has focus. No
      // rollback on abort - whatever entities were already handled are
      // kept, same as any other partial import.
      if ((importProgressWindow != null) && importProgressWindow.abortRequested) {
        echoAbortProgress();
        aborted = true;
        break;
      }

      if (control != USER_AUTO) {
        Progress = 100 * idx / totalPairs;
        int delta = (int) floor(Progress - printed_Progress);
        if (delta >= 1) {
          printProgressBarChunk(delta);
          printed_Progress = floor(Progress);
          if (importProgressWindow != null) importProgressWindow.updateFraction(Progress / 100.0f);
        }
      }

      int code = codes[idx];
      String value = values[idx];

      if (code != 0) { idx += 1; continue; } // a stray non-"0" line at this level (HEADER's own "9"-coded variables, XDATA, ...) - skip past it one pair at a time

      if (value.equals("EOF")) break;

      if (value.equals("SECTION")) {
        idx += 1;
        String sectionName = "";
        if ((idx < pairCount) && (codes[idx] == 2)) {
          sectionName = values[idx];
          idx += 1;
        }
        inEntities = sectionName.equals("ENTITIES");
        continue;
      }

      if (value.equals("ENDSEC")) {
        inEntities = false;
        idx += 1;
        continue;
      }

      // Any other "0"-coded value here is an entity-shaped block -
      // TABLES/BLOCKS use this exact same "0, TYPE, ...own fields...,
      // next 0" shape too, which is why this reads the same way
      // regardless of section; only inEntities (above) decides whether
      // it's actually acted on below.
      String entityType = value;
      idx += 1;

      IntList eCodes = new IntList();
      StringList eValues = new StringList();
      while ((idx < pairCount) && (codes[idx] != 0)) {
        eCodes.append(codes[idx]);
        eValues.append(values[idx]);
        idx += 1;
      }

      if (inEntities) {
        dxfHandleEntity(entityType, eCodes, eValues);
      }
    }
  } finally {
    if (importProgressWindow != null) importProgressWindow.dispose();
  }

  if (!aborted && (dxfEntitiesImported == 0)) {
    if (dxfImportCurves) {
      println("\nDXF import: no 3DFACE/polyface-mesh POLYLINE geometry or LINE/LWPOLYLINE/POLYLINE/CIRCLE/ARC curve geometry found - this version doesn't read any other entity type's geometry (SPLINE, MESH, block/INSERT references, ...)");
    } else {
      println("\nDXF import: no 3DFACE or polyface-mesh POLYLINE entities found - this version doesn't read any other entity type's geometry (LWPOLYLINE, MESH, block/INSERT references, ...), and importing lines/arcs/curves is currently disabled");
    }
  }

  if (!aborted) {
    int remaining = (int) floor(100 - printed_Progress);
    printProgressBarChunk(remaining);
    println();
  }

  isImportingInProgress = false;
  showArrowCursor();
}

// The transform cx/cy/cz/sx/sy/sz and importSwapAxisYZ (fileSelected.pde,
// shared with importObj.pde/importGlb.pde/importStl.pde) apply to every
// coordinate this importer reads, as a plain {x,y,z} array rather than
// an already-created Point - dxfCreatePoint() below is this, immediately
// turned into one, for 3DFACE/polyface-mesh geometry; dxfEmitPolyline()
// (further down) instead collects several of these and hands them, as
// a whole float[][], to allPolylines.add_Polyline() - which creates
// every one of ITS OWN points itself - for line/arc/curve geometry, the
// same "world-space point list in, the Polylines/Faces class itself
// creates the actual Points" split importIfc.pde's own ifcEmitFace()/
// ifcEmitCurve() already make.
float[] dxfTransformPoint (float x, float y, float z) {
  if (importSwapAxisYZ) {
    return new float[]{ dxf_cx + dxf_sx * x, dxf_cy + dxf_sy * (-z), dxf_cz + dxf_sz * y };
  } else {
    return new float[]{ dxf_cx + dxf_sx * x, dxf_cy + dxf_sy * y, dxf_cz + dxf_sz * z };
  }
}

int dxfCreatePoint (float x, float y, float z) {
  float[] p = dxfTransformPoint(x, y, z);
  return allPoints.create(p[0], p[1], p[2]);
}

// The value for group code `code` within one entity's own collected
// fields, or `defaultValue` if that code never appeared. A linear scan
// rather than a map: every entity this importer reads has only a
// handful of fields, so this stays cheap, and it keeps dxfCreatePoint()/
// the handlers below reading directly off the same eCodes/eValues pair
// the main loop already built, with no extra per-entity data structure.
String dxfFind (IntList eCodes, StringList eValues, int code, String defaultValue) {
  for (int i = 0; i < eCodes.size(); i++) {
    if (eCodes.get(i) == code) return eValues.get(i);
  }
  return defaultValue;
}

float dxfFindFloat (IntList eCodes, StringList eValues, int code, float defaultValue) {
  String v = dxfFind(eCodes, eValues, code, null);
  if (v == null) return defaultValue;
  return float(v);
}

// Dispatches one ENTITIES-section entity (eCodes/eValues already holding
// everything between its own leading "0" and the next one) by type - see
// this file's own header comment for exactly which types are handled.
void dxfHandleEntity (String entityType, IntList eCodes, StringList eValues) {
  // A layer change starts a new group here (see this file's own header
  // comment for why) - for 3DFACE/POLYLINE unconditionally, and for
  // LINE/LWPOLYLINE/CIRCLE/ARC too while dxfImportCurves is true (see
  // IFC_IMPORT_CURVES' own comment for the reasoning this toggle
  // mirrors) - the entity types that can actually start new geometry.
  // An individual VERTEX's own layer (if it somehow differs from its
  // POLYLINE header's) isn't meaningful for the polyface mesh/plain
  // curve it's building, so layer tracking is deliberately not applied
  // there either way.
  boolean canStartGeometry = entityType.equals("3DFACE") || entityType.equals("POLYLINE")
    || (dxfImportCurves && (entityType.equals("LINE") || entityType.equals("LWPOLYLINE") || entityType.equals("CIRCLE") || entityType.equals("ARC")));
  if (canStartGeometry) {
    String layer = dxfFind(eCodes, eValues, 8, "0");
    if (!layer.equals(dxfCurrentLayer)) {
      dxfCurrentLayer = layer;
      if (dxfCycleMaterial) current_Material = 1 + (current_Material % 8); // same "g" tag cycling importObj.pde's own does
      if (addToLastGroup == false) allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }
  }

  // Step 4's own DXF capture - every entity dispatched below that goes on
  // to create a Face/Polyline (3DFACE directly; LINE/LWPOLYLINE/CIRCLE/
  // ARC while dxfImportCurves is true; VERTEX/SEQEND for the POLYLINE
  // currently being read) picks up dxfCurrentLayer's own extraParams, set
  // right before dispatch and reset right after - same ambient-global
  // discipline current_ExtraParams's own comment (globalVariables.pde)
  // already requires. VERTEX/SEQEND are deliberately NOT among the types
  // that update dxfCurrentLayer just above (that block's own comment on
  // why), so every face/polyline they go on to create here still picks
  // up the owning POLYLINE's own layer, read once at its own start.
  current_ExtraParams = dxfLayerToExtraParams(dxfCurrentLayer);

  if (entityType.equals("3DFACE")) {
    dxfHandle3DFace(eCodes, eValues);
  } else if (entityType.equals("POLYLINE")) {
    dxfHandlePolylineStart(eCodes, eValues);
  } else if (entityType.equals("VERTEX")) {
    dxfHandleVertex(eCodes, eValues);
  } else if (entityType.equals("SEQEND")) {
    // Finalizes a plain/2D POLYLINE's own run of VERTEX records (the
    // polyface-mesh case has nothing left to do here - every one of
    // its own faces was already created, VERTEX by VERTEX, as it was
    // read) - see dxfHandlePolylineStart()'s/dxfHandleVertex()'s own
    // comments.
    if (dxfPlainPolylineActive && dxfPlainPolylinePoints.size() >= 2) {
      dxfEmitPolyline(dxfPlainPolylinePoints.toArray(new float[0][]), dxfPlainPolylineClosed);
      dxfEntitiesImported += 1;
    }
    dxfPolyfaceActive = false;
    dxfPlainPolylineActive = false;
  } else if (dxfImportCurves && entityType.equals("LINE")) {
    dxfHandleLine(eCodes, eValues);
  } else if (dxfImportCurves && entityType.equals("LWPOLYLINE")) {
    dxfHandleLwPolyline(eCodes, eValues);
  } else if (dxfImportCurves && entityType.equals("CIRCLE")) {
    dxfHandleCircle(eCodes, eValues);
  } else if (dxfImportCurves && entityType.equals("ARC")) {
    dxfHandleArc(eCodes, eValues);
  }
  // every other entity type (SPLINE, TEXT, MTEXT, DIMENSION, INSERT,
  // HATCH, SOLID, POINT, ELLIPSE, MESH, ...) is intentionally skipped,
  // with or without dxfImportCurves - see this file's own header
  // comment.

  current_ExtraParams = "";
}

// Builds this entity's raw extraParams string from dxfCurrentLayer -
// gated by the shared importExtraParams checkbox (fileSelected.pde),
// same "" (this field's own default/"nothing here" value) whenever
// that's unchecked or no layer has been read yet (dxfCurrentLayer starts
// null, import_objects_DXF()'s own reset) that
// geojsonPropertiesToExtraParams()/svgIdToExtraParams() (importGeojson.
// pde/importSvg.pde) already follow for their own formats.
String dxfLayerToExtraParams (String layer) {
  if (!importExtraParams || layer == null || layer.trim().length() == 0) return "";
  JSONObject obj = new JSONObject();
  obj.setString("layer", layer);
  return obj.toString();
}

void dxfHandle3DFace (IntList eCodes, StringList eValues) {
  float x1 = dxfFindFloat(eCodes, eValues, 10, 0);
  float y1 = dxfFindFloat(eCodes, eValues, 20, 0);
  float z1 = dxfFindFloat(eCodes, eValues, 30, 0);

  float x2 = dxfFindFloat(eCodes, eValues, 11, 0);
  float y2 = dxfFindFloat(eCodes, eValues, 21, 0);
  float z2 = dxfFindFloat(eCodes, eValues, 31, 0);

  float x3 = dxfFindFloat(eCodes, eValues, 12, 0);
  float y3 = dxfFindFloat(eCodes, eValues, 22, 0);
  float z3 = dxfFindFloat(eCodes, eValues, 32, 0);

  boolean hasFourth = eCodes.hasValue(13);
  float x4 = dxfFindFloat(eCodes, eValues, 13, x3);
  float y4 = dxfFindFloat(eCodes, eValues, 23, y3);
  float z4 = dxfFindFloat(eCodes, eValues, 33, z3);

  int p1 = dxfCreatePoint(x1, y1, z1);
  int p2 = dxfCreatePoint(x2, y2, z2);
  int p3 = dxfCreatePoint(x3, y3, z3);

  // See this file's own header comment on 3DFACE for why either shape
  // (the 4th point's own group codes missing, or present but numerically
  // the same as the 3rd point's) is read as a true 3-point face.
  boolean isTriangle = !hasFourth || ((abs(x4 - x3) < 0.000001) && (abs(y4 - y3) < 0.000001) && (abs(z4 - z3) < 0.000001));

  if (isTriangle) {
    allFaces.create(new int[]{ p1, p2, p3 });
  } else {
    int p4 = dxfCreatePoint(x4, y4, z4);
    allFaces.create(new int[]{ p1, p2, p3, p4 });
  }

  dxfEntitiesImported += 1;
}

void dxfHandlePolylineStart (IntList eCodes, StringList eValues) {
  int flags = (int) dxfFindFloat(eCodes, eValues, 70, 0);
  dxfPolyfaceActive = ((flags & 64) != 0); // bit 64: "polyface mesh" - see this file's own header comment
  dxfPolyfaceLocalPoints.clear();

  // A plain/2D POLYLINE (bit 64 NOT set) - DXF's older, pre-LWPOLYLINE
  // way of drawing a straight-segment line/curve - only read while
  // dxfImportCurves is true (see that toggle's own comment); mutually
  // exclusive with dxfPolyfaceActive above, since bit 64 alone decides
  // which of the two this POLYLINE actually is. Bit 1 ("closed") is the
  // same flag LWPOLYLINE's own group 70 uses.
  dxfPlainPolylineActive = dxfImportCurves && !dxfPolyfaceActive;
  dxfPlainPolylineClosed = (flags & 1) != 0;
  dxfPlainPolylinePoints.clear();
}

// A VERTEX entity belonging to the POLYLINE currently being read, if
// any - either a polyface mesh's (dxfPolyfaceActive) or a plain/2D
// one's (dxfPlainPolylineActive), the two being mutually exclusive (see
// dxfHandlePolylineStart()'s own comment). A polyface mesh's own vertex
// run is really two different kinds of record sharing the one VERTEX
// entity type: its shared point list comes first (plain x/y/z
// coordinates, groups 10/20/30), then its face list (each one's groups
// 71/72/73/74 holding up to four 1-based indices INTO that point list,
// in the order its own coordinate records appeared - a negative index
// marks that edge invisible, which this importer doesn't track, so
// just the absolute value is used). Telling the two apart by whether
// ANY of 71-74 are present (rather than trying to parse this VERTEX's
// own group-70 flags bit-for-bit) is deliberately the more robust
// signal: real-world exporters are far more consistent about always
// writing 71+ on a face record and never on a coordinate record than
// about which exact flag-70 bit combination they use for either kind.
// A plain/2D POLYLINE's own VERTEX run never carries 71-74 at all - it
// has no face list to speak of - so it's read as a straight run of
// plain x/y/z coordinates, same as the polyface mesh's own point-list
// half, just collected as already-transformed WORLD points
// (dxfPlainPolylinePoints) rather than allPoints indices, for
// SEQEND (dxfHandleEntity()) to hand to dxfEmitPolyline() once the
// whole run is in.
void dxfHandleVertex (IntList eCodes, StringList eValues) {
  if (dxfPlainPolylineActive) {
    float x = dxfFindFloat(eCodes, eValues, 10, 0);
    float y = dxfFindFloat(eCodes, eValues, 20, 0);
    float z = dxfFindFloat(eCodes, eValues, 30, 0);
    dxfPlainPolylinePoints.add(dxfTransformPoint(x, y, z));
    return;
  }

  if (!dxfPolyfaceActive) return;

  boolean isFaceDef = eCodes.hasValue(71) || eCodes.hasValue(72) || eCodes.hasValue(73) || eCodes.hasValue(74);

  if (isFaceDef) {
    IntList faceIndices = new IntList();
    int[] faceGroupCodes = { 71, 72, 73, 74 };
    for (int faceGroupCode : faceGroupCodes) {
      if (eCodes.hasValue(faceGroupCode)) {
        int raw = (int) dxfFindFloat(eCodes, eValues, faceGroupCode, 0);
        int localIndex = abs(raw) - 1;
        if ((raw != 0) && (localIndex >= 0) && (localIndex < dxfPolyfaceLocalPoints.size())) {
          faceIndices.append(dxfPolyfaceLocalPoints.get(localIndex));
        }
      }
    }
    if (faceIndices.size() >= 3) {
      allFaces.create(faceIndices.array());
      dxfEntitiesImported += 1;
    }
  } else {
    float x = dxfFindFloat(eCodes, eValues, 10, 0);
    float y = dxfFindFloat(eCodes, eValues, 20, 0);
    float z = dxfFindFloat(eCodes, eValues, 30, 0);
    dxfPolyfaceLocalPoints.append(dxfCreatePoint(x, y, z));
  }
}

// Stages a line/arc/curve entity's own already-transformed WORLD points
// as one real Polyline (polylines.pde), via allPolylines.add_Polyline()
// - unlike dxfHandle3DFace()/dxfHandleVertex() above, there's no
// "pending, flushed later" staging layer to worry about here the way
// importIfc.pde's own ifcPendingCurvePoints needs (see that one's own
// comment for why IT has to wait): this importer builds every Face's
// own points immediately, via dxfCreatePoint() -> allPoints.create(),
// the same call add_Polyline() itself makes for a Polyline's own points
// - so there's no "a later bulk-flush will discard this" hazard to
// avoid, and nothing stops a curve's own points from being created the
// same way, right away, as every other point in this importer already
// is. Drops a trailing point that exactly repeats the first - an
// explicitly closed loop (a full CIRCLE's own 360-degree tessellation
// naturally ends exactly where it started) - same reasoning import
// Ifc.pde's own ifcEmitCurve() already applies.
void dxfEmitPolyline (float[][] worldPts, boolean closed) {
  int n = worldPts.length;
  if (closed && (n > 2) && dxfPointsEqual(worldPts[0], worldPts[n - 1])) {
    n -= 1;
  }
  if (n < 2) return;

  float[][] pts = (n == worldPts.length) ? worldPts : java.util.Arrays.copyOf(worldPts, n);
  allPolylines.add_Polyline(current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, closed ? 1 : 0, pts);
}

boolean dxfPointsEqual (float[] a, float[] b) {
  return (abs(a[0] - b[0]) < 0.00001) && (abs(a[1] - b[1]) < 0.00001) && (abs(a[2] - b[2]) < 0.00001);
}

void dxfHandleLine (IntList eCodes, StringList eValues) {
  float x1 = dxfFindFloat(eCodes, eValues, 10, 0);
  float y1 = dxfFindFloat(eCodes, eValues, 20, 0);
  float z1 = dxfFindFloat(eCodes, eValues, 30, 0);
  float x2 = dxfFindFloat(eCodes, eValues, 11, 0);
  float y2 = dxfFindFloat(eCodes, eValues, 21, 0);
  float z2 = dxfFindFloat(eCodes, eValues, 31, 0);

  dxfEmitPolyline(new float[][]{ dxfTransformPoint(x1, y1, z1), dxfTransformPoint(x2, y2, z2) }, false);
  dxfEntitiesImported += 1;
}

// LWPOLYLINE: group 90 (vertex count - informational only, not read
// here), 70 (flags - bit 1 "closed", same as a plain POLYLINE's own),
// then one run of groups per vertex (10/20 - the vertex's own X/Y, a
// shared 38 "elevation" for every vertex's Z, since LWPOLYLINE itself
// has no per-vertex Z - plus optional 40/41 start/end width and 42
// bulge, none of which this importer reads: every segment comes in
// straight, bulge or not - see this file's own header comment). Groups
// 10 and 20 repeat once per vertex, strictly in vertex order per the
// DXF spec, which is what lets this walk eCodes/eValues once and treat
// each new 10 as starting a fresh vertex, rather than needing to know
// the vertex count up front.
void dxfHandleLwPolyline (IntList eCodes, StringList eValues) {
  int flags = (int) dxfFindFloat(eCodes, eValues, 70, 0);
  boolean closed = (flags & 1) != 0;
  float elevation = dxfFindFloat(eCodes, eValues, 38, 0);

  ArrayList<float[]> localPts = new ArrayList<float[]>();
  float curX = 0;
  boolean haveX = false;
  for (int i = 0; i < eCodes.size(); i++) {
    int code = eCodes.get(i);
    if (code == 10) {
      curX = float(eValues.get(i));
      haveX = true;
    } else if ((code == 20) && haveX) {
      float curY = float(eValues.get(i));
      localPts.add(dxfTransformPoint(curX, curY, elevation));
      haveX = false;
    }
  }

  if (localPts.size() < 2) return;
  dxfEmitPolyline(localPts.toArray(new float[0][]), closed);
  dxfEntitiesImported += 1;
}

void dxfHandleCircle (IntList eCodes, StringList eValues) {
  float cx = dxfFindFloat(eCodes, eValues, 10, 0);
  float cy = dxfFindFloat(eCodes, eValues, 20, 0);
  float cz = dxfFindFloat(eCodes, eValues, 30, 0);
  float r = dxfFindFloat(eCodes, eValues, 40, 0);
  if (r <= 0) return;

  dxfEmitPolyline(dxfArcPoints(cx, cy, cz, r, 0, 360), true);
  dxfEntitiesImported += 1;
}

void dxfHandleArc (IntList eCodes, StringList eValues) {
  float cx = dxfFindFloat(eCodes, eValues, 10, 0);
  float cy = dxfFindFloat(eCodes, eValues, 20, 0);
  float cz = dxfFindFloat(eCodes, eValues, 30, 0);
  float r = dxfFindFloat(eCodes, eValues, 40, 0);
  float startDeg = dxfFindFloat(eCodes, eValues, 50, 0);
  float endDeg = dxfFindFloat(eCodes, eValues, 51, 0);
  if (r <= 0) return;

  dxfEmitPolyline(dxfArcPoints(cx, cy, cz, r, startDeg, endDeg), false);
  dxfEntitiesImported += 1;
}

// Tessellates, into already-transformed WORLD points, the run of a
// CIRCLE/ARC's own circle from startDeg to endDeg - DXF's own
// documented convention (group 50/51's own "Start/end angle") is always
// counterclockwise from start to end, wrapping past 360 if needed, the
// same direction-and-degrees convention this app's own funcs.cos_ang()/
// Polylines.add_Arc() already use, and the exact same tessellation
// density (one chord roughly every 6 degrees) importIfc.pde's own
// ifcCircleLocalPoints() uses for the same reason - fine enough to read
// as round without the segment count ballooning for a large-radius
// arc. A CIRCLE (startDeg=0, endDeg=360) is simply the one case where
// the sweep comes out to the full 360.
float[][] dxfArcPoints (float cx, float cy, float cz, float r, float startDeg, float endDeg) {
  float sweep = endDeg - startDeg;
  while (sweep <= 0) sweep += 360;
  while (sweep > 360) sweep -= 360;

  int n = max(3, ceil(sweep / 6));
  float[][] pts = new float[n + 1][];
  for (int i = 0; i <= n; i++) {
    float t = startDeg + sweep * i / float(n);
    pts[i] = dxfTransformPoint(cx + r * cos(radians(t)), cy + r * sin(radians(t)), cz);
  }
  return pts;
}
