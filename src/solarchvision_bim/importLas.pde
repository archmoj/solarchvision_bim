// Minimal, dependency-free importer for a LAS (the ASPRS "LASer" format,
// the standard uncompressed LiDAR/point-cloud file format every point-
// cloud workflow eventually touches) file - the same "hand-roll the
// parser, no external library" choice importObj.pde/importIfc.
// pde/importGlb.pde/importStl.pde/importDxf.pde/
// importPly.pde already make for their own formats. LAS's own spec
// is fully public (ASPRS), no licensing question at all.
//
// LAZ - Dr. Martin Isenburg's own LASzip compression, a near-universal
// companion to LAS in the real world - is deliberately NOT read here:
// unlike every other format this app imports, LAZ's own data isn't a
// plain fixed-stride array at all, it's arithmetic-coded, and correctly
// decoding that needs a real codec implementation (effectively
// reimplementing LASzip itself), not just more parsing - real, separate
// work this version doesn't attempt. lasParseHeader() below still reads
// a LAZ file's own header far enough to detect this (the point-data-
// format byte's own top bit - see LasHeader.isCompressed's own comment)
// and import_objects_LAS() stops with a clear message instead of
// misreading the compressed bytes as if they were plain point records.
//
// Header: LAS's own Public Header Block has grown (1.0 through 1.4) by
// appending new fields after byte 227, never moving the earlier ones -
// so every field this importer actually reads (through byte 227) sits
// at the exact same fixed byte offset in every version, and
// lasParseHeader() reads the header's own declared "Header Size"/
// "Offset to point data" fields (rather than assuming either) to find
// where the point data itself begins - the same "trust the file's own
// declared structure, don't hand-parse everything else in between"
// choice importPly.pde's own plyParseHeader() already makes for PLY's
// text header. No VLR (Variable Length Record) is ever read at all -
// "Offset to point data" already says exactly where they end, which is
// all this importer needs from them.
//
// Point data - geometry only, same "only what solid/point geometry
// needs" scope importPly.pde's own vertex-property handling already
// documents: every LAS point data record format (0 through 10, legacy
// and LAS-1.4-extended alike) starts with the same 3 fields - X, Y, Z,
// each a plain signed 32-bit integer, always scaled and offset by the
// header's own scaleX/Y/Z + offsetX/Y/Z into real-world coordinates -
// and this importer reads only those first 12 bytes of every record,
// then advances to the next one by the header's own declared "Point
// Data Record Length" field, whatever else that record format packs in
// after them (intensity, classification, return number, scan angle, GPS
// time, RGB, ...). That one simplification is what lets this version
// support every uncompressed point data format (0-10) without needing
// to know any of their own individual, differing layouts beyond those
// first 12 bytes - the same role plySizeOf()/the property-skipping loop
// in plyImportAscii()/plyImportBinary() play for PLY's own unread
// properties, just via a per-record stride instead of a per-property
// one.
//
// No OBJ "g"/STL "solid"/DXF "layer"-style natural sub-object boundary
// exists in LAS at all - the whole imported file is always a single
// group, same reasoning as binary STL's/PLY's own single-group handling.
//
// Meshing: by default, this importer hands its own just-imported points
// straight to meshPointCloud_delaunayXY() (meshPointCloud.pde) and turns
// the triangles it returns into real app-native faces - see that file's
// own header comment for exactly what kind of surface this does (and
// doesn't) produce, and lasMeshPointCloud() below for how its plain
// index-array result gets turned into allFaces entries. lasImportMesh
// PointCloud lets the person importing turn this off (points only, no
// surface) via lasShowImportOptionsDialog() (fileSelected.pde) - the
// same per-import, persists-across-imports shape ifcImportFurniture/...
// (importIfc.pde) already use for their own options.

boolean lasImportShowOptionsDialog = false;

// Just this toggle's own starting value - see ifcImportFurniture's own
// comment (importIfc.pde) for why a constant exists separately
// from the variable actually checked at import time (lasImportMesh
// PointCloud, just below). On by default: meshing is the whole point of
// this app wanting point-cloud import at all (turning a point cloud into
// a usable surface, not just a dense cluster of unconnected points), so
// the person importing has to deliberately opt OUT (via lasShowImport
// OptionsDialog(), fileSelected.pde) rather than opt in.
final boolean LAS_IMPORT_MESH_POINT_CLOUD = true;
boolean lasImportMeshPointCloud = LAS_IMPORT_MESH_POINT_CLOUD;

// Transform parameters for the CURRENT import_objects_LAS() call - same
// "a few fields shared across one whole import" shape ply_cx/...
// (importPly.pde)/stl_cx/... (importStl.pde) already use.
float las_cx, las_cy, las_cz, las_sx, las_sy, las_sz;

int lasPointsImported = 0;
int lasFacesImported = 0;

// One LAS Public Header Block's worth of fields this importer actually
// uses - see this file's own header comment for why only these.
class LasHeader {
  int offsetToPointData;
  int pointDataFormat;     // 0-10, with isCompressed's own top bit already stripped out - see its comment
  boolean isCompressed;    // true => LASzip/.laz data - see this file's own header comment for why that's rejected rather than read
  int pointDataRecordLength;
  long numberOfPointRecords;
  double scaleX, scaleY, scaleZ;
  double offsetX, offsetY, offsetZ;
}

void import_objects_LAS (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  // Same shape as import_objects_PLY()'s/import_objects_STL()'s own
  // identical blocks - see either one's own comment, or ifcImportShow
  // OptionsDialog's (importIfc.pde), for why this sits here rather
  // than earlier, and what a cancelled dialog does.
  if (lasImportShowOptionsDialog) {
    lasImportShowOptionsDialog = false;
    if (!lasShowImportOptionsDialog()) return;
  }

  println("Importing LAS. Please wait...");
  showWaitCursor();

  if (m == -1) current_Material = 0;
  else current_Material = m;

  current_Tessellation = tes;
  current_Layer = lyr;
  current_Visibility = vsb;
  current_Weight = wgt;
  current_Closed = clz;

  las_cx = cx; las_cy = cy; las_cz = cz;
  las_sx = sx; las_sy = sy; las_sz = sz;

  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  if (addToLastGroup == false) allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);

  byte[] raw = loadBytes(FileName);
  if ((raw == null) || (raw.length == 0)) {
    println("\nLAS import: could not read '" + FileName + "'");
    showArrowCursor();
    return;
  }

  LasHeader header = lasParseHeader(raw);
  if (header == null) {
    println("\nLAS import: '" + FileName + "' doesn't look like a valid LAS file (missing the 'LASF' file signature, or shorter than a LAS header)");
    showArrowCursor();
    return;
  }

  if (header.isCompressed) {
    println("\nLAS import: '" + FileName + "' is LASzip-compressed (a .laz file, or a .las file saved with LAZ compression) - this version only reads plain, uncompressed LAS point data (see this file's own header comment for why) - re-export it as uncompressed LAS first");
    showArrowCursor();
    return;
  }

  if (header.pointDataRecordLength < 12) {
    println("\nLAS import: '" + FileName + "' declares a point record length of only " + header.pointDataRecordLength + " byte(s) - too short to even hold X/Y/Z, so this doesn't look like a valid LAS file");
    showArrowCursor();
    return;
  }

  // A truncated/corrupted file's own declared point count is never
  // trusted past what the file itself actually holds - same reasoning
  // as plyImportBinary()'s own bounds-checked skipBytes (importPly.pde).
  long availableBytes = raw.length - header.offsetToPointData;
  long countThatFits = (availableBytes >= 0) ? (availableBytes / header.pointDataRecordLength) : 0;
  // Plain conditional rather than min(): Processing's own min() isn't
  // overloaded for "long", and widening either argument to fit one of
  // its overloads (float/double) risks losing precision on a genuinely
  // huge count - not a concern this version needs to accept at all.
  long pointCount = (header.numberOfPointRecords < countThatFits) ? header.numberOfPointRecords : countThatFits;

  if (pointCount < header.numberOfPointRecords) {
    println("\nLAS import: '" + FileName + "' is shorter than its own header's point count claims - only reading the " + pointCount + " point(s) that actually fit");
  }

  lasPointsImported = 0;
  lasFacesImported = 0;

  progressBarHeader();

  ProgressWindow lasProgressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("Importing LAS") : null;
  if (lasProgressWindow != null) lasProgressWindow.setVisible(true);

  // Every point's own allPoints index (lasPointIndex[k]) and final,
  // already-transformed (x, y) (lasFinalX[k]/lasFinalY[k]), kept
  // alongside each other in file order - lasMeshPointCloud() (below)
  // hands the (x, y) arrays straight to meshPointCloud_delaunayXY()
  // (meshPointCloud.pde) and then translates ITS OWN plain 0..
  // pointCount-1 indices back into real allPoints indices via
  // lasPointIndex - the same "collect a global-index table while
  // importing, resolve through it afterward" shape plyImportAscii()'s/
  // plyImportBinary()'s own vertexGlobalIndex (importPly.pde) already
  // uses for face corners.
  int[] lasPointIndex = new int[(int) pointCount];
  float[] lasFinalX = new float[(int) pointCount];
  float[] lasFinalY = new float[(int) pointCount];

  float printedProgress = 0;

  try {
    int pos = header.offsetToPointData;
    for (int k = 0; k < pointCount; k++) {

      if (control != USER_AUTO) {
        float Progress = 100 * k / (float) pointCount;
        int delta = (int) floor(Progress - printedProgress);
        if (delta >= 1) {
          StringBuilder barBuffer = new StringBuilder();
          for (int c = 0; c < delta; c++) barBuffer.append('█');
          print(barBuffer.toString());
          printedProgress = floor(Progress);
          if (lasProgressWindow != null) lasProgressWindow.updateFraction(Progress / 100.0f);
        }
      }

      // Raw X/Y/Z are plain signed 32-bit integers, always scaled
      // (header.scaleX/Y/Z) and offset (header.offsetX/Y/Z) into the
      // file's own real-world coordinates by this exact two-step
      // formula - true for every point data format alike (0-10 - see
      // this file's own header comment for why only these first 12
      // bytes of each record are ever read here). binReadU32LE()
      // (importGlb.pde) returns the exact 32-bit bit pattern read,
      // which is already the correct signed value here - X/Y/Z are
      // commonly negative (relative to the header's own offsetX/Y/Z).
      double realX = header.offsetX + header.scaleX * binReadU32LE(raw, pos);
      double realY = header.offsetY + header.scaleY * binReadU32LE(raw, pos + 4);
      double realZ = header.offsetZ + header.scaleZ * binReadU32LE(raw, pos + 8);

      int pointIndex = lasCreatePoint((float) realX, (float) realY, (float) realZ);

      lasPointIndex[k] = pointIndex;
      // Always the app's own (finalX, finalY) - i.e. allPoints' own
      // getX()/getY() - regardless of importSwapAxisYZ: that flag's
      // whole job is to make the app's own Z axis consistently "up"
      // either way (see lasCreatePoint()'s own comment just below), so
      // (finalX, finalY) is always the app's own horizontal plane, and
      // triangulating it always means meshing the file's real ground/
      // horizontal surface - never a vertical cross-section of it.
      lasFinalX[k] = allPoints.getX(pointIndex);
      lasFinalY[k] = allPoints.getY(pointIndex);

      lasPointsImported += 1;

      pos += header.pointDataRecordLength;
    }
  } finally {
    if (lasProgressWindow != null) lasProgressWindow.dispose();
  }

  int remaining = (int) floor(100 - printedProgress);
  StringBuilder barBuffer = new StringBuilder();
  for (int c = 0; c < remaining; c++) barBuffer.append('█');
  print(barBuffer.toString());
  println();

  if (lasImportMeshPointCloud) {
    lasMeshPointCloud(lasPointIndex, lasFinalX, lasFinalY);
  }

  if (lasPointsImported == 0) {
    println("\nLAS import: no points were imported");
  } else if (lasImportMeshPointCloud && (lasFacesImported == 0)) {
    println("\nLAS import: " + lasPointsImported + " point(s) were imported but not meshed into a surface - see meshPointCloud.pde's own meshPointCloud_delaunayXY() for when it returns no triangles (too few points, or over its own MESH_POINT_CLOUD_MAX_POINTS cap)");
  }

  showArrowCursor();
}

// One point, carried through cx/cy/cz/sx/sy/sz and importSwapAxisYZ
// (fileSelected.pde, shared with every other importer) exactly the
// same way plyCreatePoint()'s (importPly.pde)/stlCreatePoint()'s
// (importStl.pde) own identical functions already do.
int lasCreatePoint (float x, float y, float z) {
  float finalX, finalY, finalZ;
  if (importSwapAxisYZ) {
    finalX = las_cx + las_sx * x;
    finalY = las_cy + las_sy * (-z);
    finalZ = las_cz + las_sz * y;
  } else {
    finalX = las_cx + las_sx * x;
    finalY = las_cy + las_sy * y;
    finalZ = las_cz + las_sz * z;
  }
  return allPoints.create(finalX, finalY, finalZ);
}

// Hands this import's own points to meshPointCloud_delaunayXY()
// (meshPointCloud.pde) and turns every triangle it returns into one
// app-native face - the one place this file ever touches meshPointCloud.
// pde, which otherwise knows nothing about allPoints/allFaces/current_
// Material/... at all (see that file's own header comment for why it's
// kept that way). Always called with this WHOLE import's own points at
// once (never per-group/per-return/...) - a LAS file has no natural
// sub-object boundary of its own at all (same reasoning as this file's
// own header comment on that), so there is only ever the one cloud to
// mesh.
void lasMeshPointCloud (int[] pointIndex, float[] finalX, float[] finalY) {
  ArrayList<int[]> triangles = meshPointCloud_delaunayXY(finalX, finalY);

  for (int[] tri : triangles) {
    allFaces.create(new int[]{ pointIndex[tri[0]], pointIndex[tri[1]], pointIndex[tri[2]] });
    lasFacesImported += 1;
  }
}

// Scans raw for a valid LAS Public Header Block and reads exactly the
// fields this importer needs (see this file's own header comment) -
// returns null if raw is too short to even hold the smallest real LAS
// header (227 bytes, LAS 1.0 through 1.3's own fixed size - 1.4 only
// ever appends further fields after that, never shrinks it) or doesn't
// start with LAS's own "LASF" file signature.
LasHeader lasParseHeader (byte[] raw) {
  if ((raw == null) || (raw.length < 227)) return null;
  if (!((raw[0] == 'L') && (raw[1] == 'A') && (raw[2] == 'S') && (raw[3] == 'F'))) return null;

  LasHeader h = new LasHeader();

  int headerSize = binReadU16LE(raw, 94);
  h.offsetToPointData = binReadU32LE(raw, 96);

  int formatByte = raw[104] & 0xFF;
  h.isCompressed = (formatByte & 0x80) != 0; // LASzip's own "this is really LAZ-compressed point data" flag bit - see this file's own header comment
  h.pointDataFormat = formatByte & 0x7F;

  h.pointDataRecordLength = binReadU16LE(raw, 105);

  long legacyCount = binReadU32LE(raw, 107) & 0xFFFFFFFFL;

  // LAS 1.4 added its own 64-bit point count (at offset 247, inside the
  // header's own 1.4-only extension past byte 227) specifically so a
  // cloud with more than legacyCount's own ~4 billion-point ceiling
  // (2^32) could still declare an exact count - real LAS 1.4 writers
  // leave legacyCount at exactly 0 to signal "read the 64-bit count
  // instead", which is this function's own signal too; every other case
  // (a pre-1.4 header, or a 1.4 header that still wrote its own legacy
  // count anyway, which plenty do for backward compatibility) just uses
  // legacyCount as-is.
  if ((headerSize >= 255) && (raw.length >= 255) && (legacyCount == 0)) {
    h.numberOfPointRecords = binReadLongLE(raw, 247);
  } else {
    h.numberOfPointRecords = legacyCount;
  }

  h.scaleX = binReadDoubleLE(raw, 131);
  h.scaleY = binReadDoubleLE(raw, 139);
  h.scaleZ = binReadDoubleLE(raw, 147);
  h.offsetX = binReadDoubleLE(raw, 155);
  h.offsetY = binReadDoubleLE(raw, 163);
  h.offsetZ = binReadDoubleLE(raw, 171);

  return h;
}

// lasShowImportOptionsDialog() itself - the dialog import_objects_LAS()
// above calls when lasImportShowOptionsDialog is armed - lives in
// fileSelected.pde, alongside ifcShowImportOptionsDialog()/gbxmlShow
// ImportOptionsDialog() and selectFile_ImportLas(), not here: same
// reasoning as those two, it's pure UI, not import logic.
