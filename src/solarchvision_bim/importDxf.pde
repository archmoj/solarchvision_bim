// Minimal, dependency-free importer for a DXF file - the same "hand-roll
// the parser, no external library" choice import_objects_OBJ.pde/
// import_objects_IFC.pde/import_objects_GLB.pde/import_objects_STL.pde
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
//     set) is skipped instead - its own VERTEX/SEQEND run is still
//     consumed so the main loop's own cursor stays in sync, just
//     without building anything from it.
// Every other entity type - LINE, LWPOLYLINE, CIRCLE, ARC, SPLINE, MESH,
// TEXT/MTEXT, DIMENSION, HATCH, SOLID, POINT, INSERT (block references),
// ... - is intentionally skipped: not solid 3D face geometry (or, for
// INSERT/MESH, a kind this version doesn't build).
//
// Each entity's own layer (group code 8, "0" if absent) becomes this
// importer's own group/material-cycling boundary - the natural DXF
// equivalent of import_objects_OBJ.pde's own "g" tag/import_objects_STL.
// pde's own "solid" block, since CAD users already organize a drawing's
// own geometry by layer far more consistently than by any other
// grouping DXF offers.

boolean dxfImportShowOptionsDialog = false;

// Transform parameters, the material-cycling flag, and the running
// polyface-mesh/layer state for the CURRENT import_objects_DXF() call -
// same "a few fields shared across one whole import" shape glb_cx/
// glb_cycleMaterial/... (import_objects_GLB.pde) already use.
float dxf_cx, dxf_cy, dxf_cz, dxf_sx, dxf_sy, dxf_sz;
boolean dxfCycleMaterial;
String dxfCurrentLayer = null;
boolean dxfPolyfaceActive = false;
IntList dxfPolyfaceLocalPoints = new IntList(); // allPoints indices, in the order this polyface mesh's own coordinate VERTEX records declared them
int dxfEntitiesImported = 0;

void import_objects_DXF (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  // Same shape as import_objects_OBJ()'s/import_objects_GLB()'s/
  // import_objects_STL()'s own identical blocks - see any one's own
  // comment, or ifcImportShowOptionsDialog's (import_objects_IFC.pde),
  // for why this sits here rather than earlier, and what a cancelled
  // dialog does.
  if (dxfImportShowOptionsDialog) {
    dxfImportShowOptionsDialog = false;
    if (!axisSwapShowImportOptionsDialog("DXF import options")) return;
  }

  println("Importing DXF. Please wait...");
  showWaitCursor();

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

  float totalPairs = pairCount; // computed once, not every iteration - same as import_objects_OBJ.pde's own totalLines
  float Progress = 0;
  float printed_Progress = 0;
  StringBuilder barBuffer = new StringBuilder();

  progressBarHeader();

  ProgressWindow importProgressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("Importing DXF") : null;
  if (importProgressWindow != null) importProgressWindow.setVisible(true);

  try {
    int idx = 0;
    boolean inEntities = false;

    while (idx < pairCount) {
      if (control != USER_AUTO) {
        Progress = 100 * idx / totalPairs;
        int delta = (int) floor(Progress - printed_Progress);
        if (delta >= 1) {
          barBuffer.setLength(0);
          for (int c = 0; c < delta; c++) {
            barBuffer.append('█');
          }
          print(barBuffer.toString());
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

  if (dxfEntitiesImported == 0) {
    println("\nDXF import: no 3DFACE or polyface-mesh POLYLINE entities found - this version doesn't read any other entity type's geometry (LWPOLYLINE, MESH, block/INSERT references, ...)");
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

// One point, carried through cx/cy/cz/sx/sy/sz and importSwapAxisYZ
// (fileSelected.pde, shared with import_objects_OBJ.pde/import_objects_
// GLB.pde/import_objects_STL.pde) the same way those three importers'
// own per-vertex code already does.
int dxfCreatePoint (float x, float y, float z) {
  float finalX, finalY, finalZ;
  if (importSwapAxisYZ) {
    finalX = dxf_cx + dxf_sx * x;
    finalY = dxf_cy + dxf_sy * (-z);
    finalZ = dxf_cz + dxf_sz * y;
  } else {
    finalX = dxf_cx + dxf_sx * x;
    finalY = dxf_cy + dxf_sy * y;
    finalZ = dxf_cz + dxf_sz * z;
  }
  return allPoints.create(finalX, finalY, finalZ);
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
  // comment for why) - only for the two entity types that can actually
  // start new geometry: an individual VERTEX's own layer (if it somehow
  // differs from its POLYLINE header's) isn't meaningful for the
  // polyface mesh it's building, so layer tracking is deliberately not
  // applied there.
  if (entityType.equals("3DFACE") || entityType.equals("POLYLINE")) {
    String layer = dxfFind(eCodes, eValues, 8, "0");
    if (!layer.equals(dxfCurrentLayer)) {
      dxfCurrentLayer = layer;
      if (dxfCycleMaterial) current_Material = 1 + (current_Material % 8); // same "g" tag cycling import_objects_OBJ.pde's own does
      if (addToLastGroup == false) allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }
  }

  if (entityType.equals("3DFACE")) {
    dxfHandle3DFace(eCodes, eValues);
  } else if (entityType.equals("POLYLINE")) {
    dxfHandlePolylineStart(eCodes, eValues);
  } else if (entityType.equals("VERTEX")) {
    dxfHandleVertex(eCodes, eValues);
  } else if (entityType.equals("SEQEND")) {
    dxfPolyfaceActive = false;
  }
  // every other entity type (LINE, LWPOLYLINE, CIRCLE, ARC, SPLINE,
  // TEXT, MTEXT, DIMENSION, INSERT, HATCH, SOLID, POINT, ELLIPSE,
  // MESH, ...) is intentionally skipped - see this file's own header
  // comment.
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
}

// A VERTEX entity belonging to the POLYLINE currently being read (if
// any - dxfPolyfaceActive). A polyface mesh's own vertex run is really
// two different kinds of record sharing the one VERTEX entity type: its
// shared point list comes first (plain x/y/z coordinates, groups
// 10/20/30), then its face list (each one's groups 71/72/73/74 holding
// up to four 1-based indices INTO that point list, in the order its own
// coordinate records appeared - a negative index marks that edge
// invisible, which this importer doesn't track, so just the absolute
// value is used). Telling the two apart by whether ANY of 71-74 are
// present (rather than trying to parse this VERTEX's own group-70 flags
// bit-for-bit) is deliberately the more robust signal: real-world
// exporters are far more consistent about always writing 71+ on a face
// record and never on a coordinate record than about which exact flag-
// 70 bit combination they use for either kind.
void dxfHandleVertex (IntList eCodes, StringList eValues) {
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
