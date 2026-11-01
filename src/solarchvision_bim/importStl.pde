// Minimal, dependency-free importer for an STL file - both the plain-
// text ASCII variant and the binary one - the same "hand-roll the
// parser, no external library" choice import_objects_OBJ.pde/
// import_objects_IFC.pde/import_objects_GLB.pde already make for their
// own formats.
//
// STL has no material/texture/group concept of its own at all - every
// triangle in the file just gets the single material the m parameter
// (below) names, the same "whole import, one material unless cycled per
// sub-object" shape import_objects_OBJ.pde's own "g" tag already uses.
// The one place STL DOES have its own natural sub-object boundary is
// ASCII STL's optional multiple "solid ... endsolid" blocks in a single
// file (uncommon, but real - some tools write one per separate part) -
// each one becomes its own group here, cycling material the same way a
// new OBJ "g" tag does. Binary STL has no such boundary (always exactly
// one implicit solid), so a binary file is always a single group.
//
// Binary vs ASCII detection: the standard heuristic every real-world STL
// reader uses, since a binary file's own 80-byte header is free-form
// text and can (deliberately, by some exporters, to fool a naive reader)
// start with "solid " too - read the triangle count a binary STL always
// stores as a little-endian uint32 right after that header (byte offset
// 80), and check whether the file's own total size exactly matches what
// that many binary triangles would occupy (84 + 50 * count: a 12-byte
// normal, three 12-byte vertices, and a 2-byte "attribute byte count"
// per triangle). If it does, read it as binary; if not (including any
// file too short to even hold that header), read it as ASCII.
//
// Per-vertex/face normals are read from a binary file (12 bytes right
// before each triangle's own 3 vertices) but not used - this app derives
// its own face normals rather than trusting a file's possibly-stale
// ones, the same way import_objects_OBJ.pde's own parser already skips
// every "vn" line without reading it.

boolean stlImportShowOptionsDialog = false;

// Transform parameters and the material-cycling flag for the CURRENT
// import_objects_STL() call - same "a few fields shared across one
// whole import" shape glb_cx/glb_cycleMaterial/... (import_objects_GLB.
// pde) already use, for the same reason: stlCreatePoint()/the ASCII
// "solid" handling below need them without threading extra parameters
// through every call.
float stl_cx, stl_cy, stl_cz, stl_sx, stl_sy, stl_sz;
boolean stlCycleMaterial;

void import_objects_STL (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  // Same shape as import_objects_OBJ()'s/import_objects_GLB()'s own
  // identical blocks - see either one's own comment, or
  // ifcImportShowOptionsDialog's (import_objects_IFC.pde), for why this
  // sits here rather than earlier, and what a cancelled dialog does.
  if (stlImportShowOptionsDialog) {
    stlImportShowOptionsDialog = false;
    if (!axisSwapShowImportOptionsDialog("STL import options")) return;
  }

  println("Importing STL. Please wait...");
  showWaitCursor();

  stlCycleMaterial = (m == -1);
  if (m == -1) current_Material = 0;
  else current_Material = m;

  current_Tessellation = tes;
  current_Layer = lyr;
  current_Visibility = vsb;
  current_Weight = wgt;
  current_Closed = clz;

  stl_cx = cx; stl_cy = cy; stl_cz = cz;
  stl_sx = sx; stl_sy = sy; stl_sz = sz;

  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  byte[] raw = loadBytes(FileName);
  if ((raw == null) || (raw.length == 0)) {
    println("\nSTL import: could not read '" + FileName + "'");
    showArrowCursor();
    return;
  }

  boolean binary = false;
  if (raw.length >= 84) {
    int triangleCount = binReadU32LE(raw, 80);
    long expectedBinarySize = 84L + 50L * (triangleCount & 0xFFFFFFFFL); // masked: triangleCount read as unsigned
    if (expectedBinarySize == raw.length) binary = true;
  }

  progressBarHeader();

  if (binary) {
    stlImportBinary(raw);
  } else {
    stlImportAscii(FileName);
  }

  showArrowCursor();
}

// One point, carried through cx/cy/cz/sx/sy/sz and importSwapAxisYZ
// (fileSelected.pde, shared with import_objects_OBJ.pde/import_objects_
// GLB.pde) the same way those two importers' own per-vertex code
// already does.
int stlCreatePoint (float x, float y, float z) {
  float finalX, finalY, finalZ;
  if (importSwapAxisYZ) {
    finalX = stl_cx + stl_sx * x;
    finalY = stl_cy + stl_sy * (-z);
    finalZ = stl_cz + stl_sz * y;
  } else {
    finalX = stl_cx + stl_sx * x;
    finalY = stl_cy + stl_sy * y;
    finalZ = stl_cz + stl_sz * z;
  }
  return allPoints.create(finalX, finalY, finalZ);
}

void stlImportBinary (byte[] raw) {
  int triangleCount = binReadU32LE(raw, 80);

  ProgressWindow importProgressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("Importing STL") : null;
  if (importProgressWindow != null) importProgressWindow.setVisible(true);

  // No "solid"/"endsolid" boundary of its own in binary STL - the whole
  // file is a single group, matching this file's own header comment.
  if (addToLastGroup == false) allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);

  float printed_Progress = 0;

  try {
    int pos = 84; // right after the 80-byte header + 4-byte triangle count
    for (int t = 0; t < triangleCount; t++) {
      if (pos + 50 > raw.length) {
        println("\nSTL import: file is shorter than its own triangle count claims - stopping early");
        break;
      }

      if (control != USER_AUTO) {
        float Progress = 100 * t / float(triangleCount);
        int delta = (int) floor(Progress - printed_Progress);
        if (delta >= 1) {
          StringBuilder barBuffer = new StringBuilder();
          for (int c = 0; c < delta; c++) barBuffer.append('█');
          print(barBuffer.toString());
          printed_Progress = floor(Progress);
          if (importProgressWindow != null) importProgressWindow.updateFraction(Progress / 100.0f);
        }
      }

      int base = pos + 12; // skip the 12-byte normal - see this file's own header comment

      int p0 = stlCreatePoint(binReadFloatLE(raw, base),      binReadFloatLE(raw, base + 4),  binReadFloatLE(raw, base + 8));
      int p1 = stlCreatePoint(binReadFloatLE(raw, base + 12), binReadFloatLE(raw, base + 16), binReadFloatLE(raw, base + 20));
      int p2 = stlCreatePoint(binReadFloatLE(raw, base + 24), binReadFloatLE(raw, base + 28), binReadFloatLE(raw, base + 32));

      allFaces.create(new int[]{ p0, p1, p2 });

      pos += 50; // 12 (normal) + 36 (3 vertices) + 2 (attribute byte count)
    }
  } finally {
    if (importProgressWindow != null) importProgressWindow.dispose();
  }

  int remaining = (int) floor(100 - printed_Progress);
  StringBuilder barBuffer = new StringBuilder();
  for (int c = 0; c < remaining; c++) barBuffer.append('█');
  print(barBuffer.toString());
  println();
}

void stlImportAscii (String FileName) {
  String[] FileALL = loadStrings(FileName);
  if (FileALL == null) FileALL = new String[0];

  float totalLines = FileALL.length; // computed once, not every iteration - same as import_objects_OBJ.pde's own
  float Progress = 0;
  float printed_Progress = 0;
  StringBuilder barBuffer = new StringBuilder();

  ProgressWindow importProgressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("Importing STL") : null;
  if (importProgressWindow != null) importProgressWindow.setVisible(true);

  // Up to 3 vertices (x,y,z each) for the facet currently being read,
  // between its own "facet normal ..."/"outer loop" and "endloop"/
  // "endfacet" lines.
  float[] pendingVertices = new float[9];
  int pendingVertexCount = 0;

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
          print(barBuffer.toString());
          printed_Progress = floor(Progress);
          if (importProgressWindow != null) importProgressWindow.updateFraction(Progress / 100.0f);
        }
      }

      String lineSTR = FileALL[f];

      String[] parts = splitTokens(lineSTR);
      if (parts == null || parts.length == 0) continue; // skip blank lines

      String tag = parts[0];

      if (tag.equalsIgnoreCase("solid")) {
        if (stlCycleMaterial) current_Material = 1 + (current_Material % 8);
        if (addToLastGroup == false) allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
      } else if (tag.equalsIgnoreCase("vertex") && (parts.length >= 4)) {
        if (pendingVertexCount < 3) {
          pendingVertices[pendingVertexCount * 3]     = float(parts[1]);
          pendingVertices[pendingVertexCount * 3 + 1] = float(parts[2]);
          pendingVertices[pendingVertexCount * 3 + 2] = float(parts[3]);
          pendingVertexCount += 1;
        }
      } else if (tag.equalsIgnoreCase("endfacet")) {
        if (pendingVertexCount == 3) {
          int p0 = stlCreatePoint(pendingVertices[0], pendingVertices[1], pendingVertices[2]);
          int p1 = stlCreatePoint(pendingVertices[3], pendingVertices[4], pendingVertices[5]);
          int p2 = stlCreatePoint(pendingVertices[6], pendingVertices[7], pendingVertices[8]);
          allFaces.create(new int[]{ p0, p1, p2 });
        }
        pendingVertexCount = 0;
      }
      // any other tag ("facet" - "facet normal ..." lines are only
      // matched on this first token, so the normal itself is never
      // read, same as this file's own header comment on that -,
      // "outer", "loop", "endloop", "endsolid", a bare solid name,
      // ...) is intentionally ignored, the same "only the tags that
      // matter are handled, everything else silently skipped" shape
      // import_objects_OBJ.pde's own parser already uses.
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
}
