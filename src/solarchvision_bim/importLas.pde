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
// each a plain signed 32-bit integer, which LAS's own spec always
// scales (header.scaleX/Y/Z) and offsets (header.offsetX/Y/Z) into real-
// world coordinates - though this importer only ever applies the scale,
// not the offset (see this file's own "Centered by default" comment for
// why) - and reads only those first 12 bytes of every record,
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
// straight to meshPointCloud_gridXY() (meshPointCloudGrid.pde) and turns
// the quads it returns into real app-native faces - see that file's own
// header comment for exactly what kind of surface this does (and
// doesn't) produce, and lasMeshPointCloud() below for how its plain
// index-array result gets turned into allFaces entries, and for how
// lasImportMeshAlgorithm picks one of 2 alternatives instead when set:
// meshPointCloud_delaunayXY() (meshPointCloud.pde - the slower, exact
// alternative) or meshPointCloud_boxGridXY() (meshPointCloudBoxGrid.
// pde - a stepped, bar-chart-like "grid of boxes" instead of a smooth
// surface, built very differently - see lasCreateBoxGridFaces(), below,
// for how). lasImportMeshPointCloud lets the person importing turn
// meshing off entirely (points only, no surface, no algorithm run at
// all) via lasShowImportOptionsDialog() (fileSelected.pde) - the same
// per-import, persists-across-imports shape ifcImportFurniture/...
// (importIfc.pde) already use for their own options.
//
// Testing with only part of a file: a real LAS tile can be huge (easily
// into the millions of points), slow to even read, let alone mesh - so
// lasImportMaxPoints (below) lets the person importing cap this import
// to only the FIRST N points the file's own point data holds (file
// order, not a random/spatial sample - simplest to reason about, and
// enough to sanity-check a parser/mesher change quickly), via either
// lasShowImportOptionsDialog()'s own text field or IMPORT.LAS's own
// optional 3rd script argument - see lasImportMaxPoints's own comment
// for exactly where this is applied.
//
// Centered by default: a real-world LAS file's own header.offsetX/Y/Z
// (lasParseHeader(), below) is normally a large absolute coordinate -
// a UTM easting/northing, say, in the hundreds of thousands to low
// millions - chosen by whatever tool wrote the file so that scaleX/Y/Z
// * the point data's own raw integers stay in a small, file-LOCAL range
// relative to it. This importer drops that absolute offset entirely
// (every point's own localX/Y/Z, in the main read loop below, is just
// scaleX/Y/Z * the raw integer - see that comment's own) rather than
// adding it back in, so the imported cloud lands centered on roughly
// (0, 0, 0) - near this app's own scene origin, and everything else it
// already holds - by default, not out at the file's own real-world
// coordinate. allVertices (points.pde) is a 32-bit float array, not a
// double one, so this isn't just convenience: a float has roughly 7
// significant decimal digits, which a raw UTM-scale coordinate like
// 4,512,345.678 already exhausts before even reaching the sub-meter
// precision real LAS scale factors (commonly 0.001) are meant to
// preserve - keeping every point's own magnitude small (its file-local
// extent only, not its absolute position on Earth) is what actually
// keeps that precision intact. The file's own absolute location is NOT
// preserved anywhere by this - printed to the console once per import
// instead (see import_objects_LAS()'s own println near the end), so a
// person who genuinely needs it (aligning several separate tiles to
// each other, say) at least has it to work from, even though nothing
// in this version re-applies it automatically.
//
// Region of interest: lasImportMinX/MaxX/MinY/MaxY/MinZ/MaxZ (below)
// each independently either hold a real bound or are null ("no bound on
// this side at all") - the person importing can set anywhere from none
// of the 6 to all 6, via lasShowImportOptionsDialog()'s own 6 checkbox+
// field rows (fileSelected.pde). A point outside any bound that IS set
// is skipped entirely - never passed to lasCreatePoint() at all, so it
// never becomes a real allPoints entry, is never counted in
// lasPointsImported, and costs nothing further (no meshing, no
// progress-bar time) once skipped - see the main read loop's own
// comment, below, for exactly where this check sits. These bounds are
// checked against localX/Y/Z (the main read loop's own, below) - the
// file's own LOCAL coordinate, after "Centered by default" (above) has
// already dropped header.offsetX/Y/Z, but BEFORE las_cx/cy/cz/sx/sy/sz
// or importSwapAxisYZ (lasCreatePoint(), below) place/reorient the
// result in the scene - a deliberate choice, not the only one that
// could have been made: filtering in this one fixed space, rather than
// the file's own real-world one or the app's own final scene one, means
// the SAME 3 numbers mean the same thing regardless of how a given
// import happens to be placed or axis-swapped, at the cost of a person
// who actually wants to filter by real-world (UTM, say) coordinates
// needing to account for the dropped offset themselves (see "Centered
// by default," above, for where that offset is printed).

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

// Which of the 3 algorithms meshPointCloud.pde/meshPointCloudGrid.pde/
// meshPointCloudBoxGrid.pde offer actually does the meshing above, when
// lasImportMeshPointCloud is on - see lasMeshPointCloud()'s own comment,
// below, for exactly where this is read. Plain int constants rather
// than a Java enum, matching this app's own existing style for a small,
// fixed set of named choices (e.g. TypeWindow's own WIN3D/OBJ3D/...).
// LAS_MESH_ALGORITHM_GRID (this toggle's own starting value) by
// default: see meshPointCloudGrid.pde's own header comment for why it's
// the faster choice and what it gives up to get there - the other 2
// stay available as alternatives (lasShowImportOptionsDialog(),
// fileSelected.pde) for whoever specifically wants one of them instead.
final int LAS_MESH_ALGORITHM_GRID = 0;
final int LAS_MESH_ALGORITHM_DELAUNAY = 1;
final int LAS_MESH_ALGORITHM_BOX_GRID = 2;
int lasImportMeshAlgorithm = LAS_MESH_ALGORITHM_GRID;

// How many of the file's own points to actually read, at most - 0 (this
// toggle's own starting value) means no limit, every point the header/
// file itself hold (countThatFits, further down) is read, same as
// before this option existed. Set > 0 (via lasShowImportOptionsDialog()'s
// own checkbox+field, fileSelected.pde, or IMPORT.LAS's own optional 3rd
// script argument, extraCommands.pde) to read only the file's own FIRST
// this-many points instead - meant for quickly testing against a huge
// real file without waiting on (or meshing) all of it, not for a normal
// import. Persists across imports the same way lasImportMeshPointCloud
// does (see its own comment) - import_objects_LAS() below always prints
// a console line whenever a limit is actually in effect, specifically so
// a limit left on from an earlier test is never silently applied to a
// later, real import.
final int LAS_IMPORT_MAX_POINTS = 0;
int lasImportMaxPoints = LAS_IMPORT_MAX_POINTS;

// Region-of-interest bounds - see this file's own "Region of interest"
// header comment for exactly what these mean and where they're checked.
// null (every one of these own starting value) means no bound on that
// side at all, same meaning as lasImportMaxPoints' own 0 just above,
// just via Java's own null rather than a sentinel number, since 0 is
// itself a perfectly real coordinate a person might actually want to
// filter by (unlike a point count, which 0 could never meaningfully
// mean as a real limit). Persist across imports the same way every
// other LAS import option already does.
Float lasImportMinX = null;
Float lasImportMaxX = null;
Float lasImportMinY = null;
Float lasImportMaxY = null;
Float lasImportMinZ = null;
Float lasImportMaxZ = null;

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
  // The file's own declared overall bounding box - a required field in
  // every valid LAS header (unlike everything else in this class, never
  // used to read a single point's own geometry - this importer trusts
  // each point's own raw X/Y/Z regardless of whether it falls inside
  // what the header claims). The ONE use this importer has for it:
  // lasShowImportOptionsDialog()'s (fileSelected.pde) own region-of-
  // interest fields default to these, in LOCAL coordinates (minX -
  // offsetX, same as every point's own localX - see this file's own
  // "Centered by default" comment), so a person narrowing the import
  // down starts from the file's own real extent instead of a
  // meaningless "0".
  double minX, maxX, minY, maxY, minZ, maxZ;
}

void import_objects_LAS (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {

  // Consumed here, once, regardless of what happens below - a one-shot
  // "show the dialog on the NEXT call" flag, same as before (see either
  // import_objects_PLY()'s/import_objects_STL()'s own identical blocks,
  // or ifcImportShowOptionsDialog's, importIfc.pde) - just read into a
  // local up front now, rather than consumed at the point the dialog is
  // actually shown further down, because the header needs parsing
  // FIRST (see lasShowImportOptionsDialog()'s own new header parameter,
  // fileSelected.pde, for why: its own region-of-interest fields now
  // default to the file's own real bounding box, which obviously isn't
  // known yet before the file itself has even been opened).
  boolean showDialog = lasImportShowOptionsDialog;
  lasImportShowOptionsDialog = false;

  // Opened and the header parsed/validated BEFORE the dialog (if shown
  // at all) and before showWaitCursor() - deliberately outside the try/
  // finally below, the same reasoning as this same block's own earlier
  // position (before showWaitCursor()) already had: the cursor is never
  // set to WAIT this early, so there's nothing yet to restore if any of
  // this throws.
  byte[] raw = loadBytes(FileName);
  if ((raw == null) || (raw.length == 0)) {
    println("\nLAS import: could not read '" + FileName + "'");
    return;
  }

  LasHeader header = lasParseHeader(raw);
  if (header == null) {
    println("\nLAS import: '" + FileName + "' doesn't look like a valid LAS file (missing the 'LASF' file signature, or shorter than a LAS header)");
    return;
  }

  if (header.isCompressed) {
    println("\nLAS import: '" + FileName + "' is LASzip-compressed (a .laz file, or a .las file saved with LAZ compression) - this version only reads plain, uncompressed LAS point data (see this file's own header comment for why) - re-export it as uncompressed LAS first");
    return;
  }

  if (header.pointDataRecordLength < 12) {
    println("\nLAS import: '" + FileName + "' declares a point record length of only " + header.pointDataRecordLength + " byte(s) - too short to even hold X/Y/Z, so this doesn't look like a valid LAS file");
    return;
  }

  if (showDialog) {
    if (!lasShowImportOptionsDialog(header)) return;
  }

  println("Importing LAS. Please wait...");
  showWaitCursor();

  // Everything below runs inside this one try/finally so showArrowCursor()
  // (in the finally, right at the bottom of this function) ALWAYS runs
  // before this function returns - on every early "this file is no
  // good" return below, AND if anything further down (reading a
  // corrupted point record, or lasMeshPointCloud()'s own call into
  // meshPointCloud.pde) throws - rather than only on the ordinary,
  // nothing-went-wrong path. Without this, any such exception would
  // leave showArrowCursor() unreached and the wait cursor stuck forever
  // (not just for however long the operation that threw actually took) -
  // a real bug this shape fixes, on top of just making a slow import
  // easier to tell apart from a genuinely stuck one (see lasMesh
  // PointCloud()'s own progress reporting, below, for that part).
  try {

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

    // Reported against header.numberOfPointRecords BEFORE lasImportMax
    // Points (below) can shrink pointCount any further - this message is
    // specifically about the FILE not holding what it claims to, never
    // about lasImportMaxPoints' own deliberate, unrelated limit (that one
    // gets its own, separate message just below).
    if (pointCount < header.numberOfPointRecords) {
      println("\nLAS import: '" + FileName + "' is shorter than its own header's point count claims - only reading the " + pointCount + " point(s) that actually fit");
    }

    // See lasImportMaxPoints's own comment above for what this is and
    // where it comes from - applied AFTER the file-truncation check just
    // above (never past what the file genuinely holds either way), so the
    // two messages never read as the same thing: one says "the file
    // itself doesn't have what it claims", this one says "deliberately
    // only reading part of what it has".
    if ((lasImportMaxPoints > 0) && (pointCount > lasImportMaxPoints)) {
      println("\nLAS import: lasImportMaxPoints is set - only reading the first " + lasImportMaxPoints + " of " + pointCount + " point(s) this file actually holds (testing option; see lasShowImportOptionsDialog()'s own checkbox, or IMPORT.LAS's own optional 3rd argument)");
      pointCount = lasImportMaxPoints;
    }

    // See this file's own header comment ("Centered by default") for
    // why header.offsetX/Y/Z is dropped rather than applied - printed
    // here (once, regardless of how many points this ends up reading)
    // so the file's own real-world location is still on record
    // somewhere, for the one person who actually needs it, even though
    // nothing in this version re-applies it automatically. Skipped
    // entirely for a (0, 0, 0) header offset (a file that was already
    // local/centered to begin with) - nothing was actually dropped,
    // so there's nothing worth telling anyone about.
    if ((pointCount > 0) && ((header.offsetX != 0) || (header.offsetY != 0) || (header.offsetZ != 0))) {
      println("\nLAS import: centered around (0, 0, 0) - the file's own real-world offset (" + header.offsetX + ", " + header.offsetY + ", " + header.offsetZ + ") was not applied");
    }

    lasPointsImported = 0;
    lasFacesImported = 0;

    progressBarHeader();

    ProgressWindow lasProgressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("Importing LAS") : null;
    if (lasProgressWindow != null) lasProgressWindow.setVisible(true);

    // Every KEPT point's own allPoints index (lasPointIndex[...]) and
    // final, already-transformed (x, y, z) (lasFinalX[...]/lasFinalY
    // [...]/lasFinalZ[...]), kept alongside each other in file order -
    // lasMeshPointCloud() (below) hands these straight to whichever
    // meshing algorithm is in use (the grid and Delaunay algorithms
    // only ever need x/y - see lasFinalZ's own comment just below for
    // why it exists at all) and then translates ITS OWN plain local
    // indices back into real allPoints indices via lasPointIndex - the
    // same "collect a global-index table while importing, resolve
    // through it afterward" shape plyImportAscii()'s/plyImportBinary()'s
    // own vertexGlobalIndex (importPly.pde) already uses for face
    // corners. Sized at pointCount (the most this could ever hold - one
    // slot per record the file itself declares, before any region-of-
    // interest filtering below might skip some of them) and trimmed
    // down to keptCount - the real, possibly smaller, number of points
    // actually kept - right after the read loop, via Arrays.copyOf().
    int[] lasPointIndex = new int[(int) pointCount];
    float[] lasFinalX = new float[(int) pointCount];
    float[] lasFinalY = new float[(int) pointCount];
    // The box-grid algorithm (meshPointCloud_boxGridXY(),
    // meshPointCloudBoxGrid.pde) is the one consumer of this - unlike
    // the grid/Delaunay algorithms (which only ever triangulate the
    // app's own horizontal (x, y) plane, carrying z through purely via
    // each result index's own allPoints lookup), a box's own flat TOP
    // needs an actual height value up front, before any allPoints
    // index even exists for it - see meshPointCloud_boxGridXY()'s own
    // header comment.
    float[] lasFinalZ = new float[(int) pointCount];
    int keptCount = 0;

    // Hoisted out of the per-point loop below, once per import rather
    // than up to 6 times per point - avoids repeatedly re-checking
    // "is this bound even set" (a null check plus a Float-to-float
    // unboxing, each of lasImportMinX/.../MaxZ, every single point)
    // inside what can be a very hot loop on a real file. Pure
    // bookkeeping - changes nothing about which points pass or fail,
    // only how cheaply that gets decided.
    boolean checkMinX = (lasImportMinX != null); float boundMinX = checkMinX ? lasImportMinX : 0;
    boolean checkMaxX = (lasImportMaxX != null); float boundMaxX = checkMaxX ? lasImportMaxX : 0;
    boolean checkMinY = (lasImportMinY != null); float boundMinY = checkMinY ? lasImportMinY : 0;
    boolean checkMaxY = (lasImportMaxY != null); float boundMaxY = checkMaxY ? lasImportMaxY : 0;
    boolean checkMinZ = (lasImportMinZ != null); float boundMinZ = checkMinZ ? lasImportMinZ : 0;
    boolean checkMaxZ = (lasImportMaxZ != null); float boundMaxZ = checkMaxZ ? lasImportMaxZ : 0;

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

        // Raw X/Y/Z are plain signed 32-bit integers, always scaled by
        // header.scaleX/Y/Z - true for every point data format alike
        // (0-10 - see this file's own header comment for why only these
        // first 12 bytes of each record are ever read here).
        // binReadU32LE() (importGlb.pde) returns the exact 32-bit bit
        // pattern read, which is already the correct signed value here -
        // X/Y/Z are commonly negative (relative to the header's own
        // offsetX/Y/Z). Deliberately NOT adding header.offsetX/Y/Z back
        // in - see this file's own header comment ("Centered by
        // default") for why: this is the file's own local coordinate,
        // relative to that offset, not its absolute real-world one, and
        // that's exactly what keeps the imported cloud centered near
        // this app's own scene origin by default.
        //
        // recordStart is kept separately from pos specifically so pos
        // itself can advance to the NEXT record right away, below,
        // before the region-of-interest checks that follow each of
        // X/Y/Z can ever "continue" past the rest of this loop's own
        // body - a filtered-out record must still be skipped OVER in
        // the file, or every following record would be read from the
        // wrong byte position for the rest of this import.
        int recordStart = pos;
        pos += header.pointDataRecordLength;

        // X, then its own region-of-interest check, before Y is ever
        // decoded at all - and the same for Y before Z - rather than
        // decoding all 3 of X/Y/Z up front and only checking bounds
        // after: for a real region-of-interest filter (which typically
        // rejects most of a file's own points), a point that already
        // fails on X alone never pays for decoding Y or Z at all. See
        // this file's own "Region of interest" header comment for what
        // these bounds mean; checkMinX/.../boundMaxZ (above) are this
        // same check, just with the "is this bound even set" part
        // already resolved once per import rather than per point.
        double localX = header.scaleX * binReadU32LE(raw, recordStart);
        if (checkMinX && (localX < boundMinX)) continue;
        if (checkMaxX && (localX > boundMaxX)) continue;

        double localY = header.scaleY * binReadU32LE(raw, recordStart + 4);
        if (checkMinY && (localY < boundMinY)) continue;
        if (checkMaxY && (localY > boundMaxY)) continue;

        double localZ = header.scaleZ * binReadU32LE(raw, recordStart + 8);
        if (checkMinZ && (localZ < boundMinZ)) continue;
        if (checkMaxZ && (localZ > boundMaxZ)) continue;

        int pointIndex = lasCreatePoint((float) localX, (float) localY, (float) localZ);

        lasPointIndex[keptCount] = pointIndex;
        // Always the app's own (finalX, finalY) - i.e. allPoints' own
        // getX()/getY() - regardless of importSwapAxisYZ: that flag's
        // whole job is to make the app's own Z axis consistently "up"
        // either way (see lasCreatePoint()'s own comment just below), so
        // (finalX, finalY) is always the app's own horizontal plane, and
        // triangulating it always means meshing the file's real ground/
        // horizontal surface - never a vertical cross-section of it.
        lasFinalX[keptCount] = allPoints.getX(pointIndex);
        lasFinalY[keptCount] = allPoints.getY(pointIndex);
        lasFinalZ[keptCount] = allPoints.getZ(pointIndex);
        keptCount += 1;

        lasPointsImported += 1;
      }
    } finally {
      if (lasProgressWindow != null) lasProgressWindow.dispose();
    }

    // Trimmed down to the real, kept count - see lasPointIndex's own
    // comment above for why these were sized at pointCount to begin
    // with. A no-op slice (same length back out) when no region-of-
    // interest bound actually removed anything.
    lasPointIndex = Arrays.copyOf(lasPointIndex, keptCount);
    lasFinalX = Arrays.copyOf(lasFinalX, keptCount);
    lasFinalY = Arrays.copyOf(lasFinalY, keptCount);
    lasFinalZ = Arrays.copyOf(lasFinalZ, keptCount);

    // See this file's own "Region of interest" header comment for what
    // this is - reported whenever at least one of the 6 bounds is
    // actually set AND it actually removed at least 1 point, so a
    // bound left on from an earlier import (these persist the same way
    // every other LAS import option does) is never silently applied to
    // a later one without at least a console line to notice it by.
    boolean regionOfInterestActive = (lasImportMinX != null) || (lasImportMaxX != null) || (lasImportMinY != null) || (lasImportMaxY != null) || (lasImportMinZ != null) || (lasImportMaxZ != null);
    if (regionOfInterestActive && (keptCount < pointCount)) {
      println("\nLAS import: region-of-interest filter kept " + keptCount + " of " + pointCount + " point(s) read");
    }

    int remaining = (int) floor(100 - printedProgress);
    StringBuilder barBuffer = new StringBuilder();
    for (int c = 0; c < remaining; c++) barBuffer.append('█');
    print(barBuffer.toString());
    println();

    if (lasImportMeshPointCloud) {
      lasMeshPointCloud(lasPointIndex, lasFinalX, lasFinalY, lasFinalZ);
    }

    if (lasPointsImported == 0) {
      println("\nLAS import: no points were imported");
    } else if (lasImportMeshPointCloud && (lasFacesImported == 0)) {
      String meshingFunctionName;
      if (lasImportMeshAlgorithm == LAS_MESH_ALGORITHM_DELAUNAY) meshingFunctionName = "meshPointCloud.pde's own meshPointCloud_delaunayXY()";
      else if (lasImportMeshAlgorithm == LAS_MESH_ALGORITHM_BOX_GRID) meshingFunctionName = "meshPointCloudBoxGrid.pde's own meshPointCloud_boxGridXY()";
      else meshingFunctionName = "meshPointCloudGrid.pde's own meshPointCloud_gridXY()";
      println("\nLAS import: " + lasPointsImported + " point(s) were imported but not meshed into a surface - see " + meshingFunctionName + " for when it returns nothing (too few points, over its own point cap, or every cell/block ended up empty even after its own fill pass)");
    }

  } finally {
    showArrowCursor();
  }
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

// A MeshPointCloudProgressListener (meshPointCloud.pde, shared by both
// meshPointCloud_delaunayXY() there and meshPointCloud_gridXY() in
// meshPointCloudGrid.pde) that throttles and reports progress the exact
// same way the point-reading loop in import_objects_LAS() above already
// does (a console '█' bar, at most once per whole-percent step, plus an
// optional ProgressWindow) - a small class (holding its own
// printedProgress) rather than a lambda specifically so that per-call
// state has somewhere plain to live, matching the shape MeshTriangle/
// LasHeader (this file's own, and meshPointCloud.pde's own) already use
// for the same reason.
class LasMeshProgressReporter implements MeshPointCloudProgressListener {
  ProgressWindow window; // nullable - see import_objects_LAS()'s own "showImportProgress && canShowProgressWindow()" check for when this is null
  float printedProgress = 0;

  LasMeshProgressReporter (ProgressWindow window) {
    this.window = window;
  }

  void onPointInserted (int pointsInserted, int totalPoints) {
    if (control == USER_AUTO) return;

    float Progress = 100 * pointsInserted / (float) totalPoints;
    int delta = (int) floor(Progress - printedProgress);
    if (delta >= 1) {
      StringBuilder barBuffer = new StringBuilder();
      for (int c = 0; c < delta; c++) barBuffer.append('█');
      print(barBuffer.toString());
      printedProgress = floor(Progress);
      if (window != null) window.updateFraction(Progress / 100.0f);
    }
  }
}

// Hands this import's own points to whichever of the 3 algorithms
// lasImportMeshAlgorithm selects. The box-grid algorithm (meshPoint
// Cloud_boxGridXY(), meshPointCloudBoxGrid.pde) branches off immediately
// into its own dedicated lasMeshPointCloudBoxGrid() (below), since it
// builds its own geometry directly (synthesized box corners, not real
// point indices) rather than returning index-arrays into finalX/finalY
// the way the other 2 do - see meshPointCloud_boxGridXY()'s own header
// comment for why. For the grid/Delaunay algorithms, every face
// returned - always a triangle from Delaunay, always a quad from the
// grid one, see lasCreateFace()'s own comment below - becomes one real
// allFaces entry here, the one place this file ever touches either,
// both of which otherwise know nothing about allPoints/allFaces/
// current_Material/... at all (see each one's own header comment for
// why they're kept that way). Always called with this WHOLE import's
// own points at once (never per-group/per-return/...) - a LAS file has
// no natural sub-object boundary of its own at all (same reasoning as
// this file's own header comment on that), so there is only ever the
// one cloud to mesh.
void lasMeshPointCloud (int[] pointIndex, float[] finalX, float[] finalY, float[] finalZ) {

  if (lasImportMeshAlgorithm == LAS_MESH_ALGORITHM_BOX_GRID) {
    lasMeshPointCloudBoxGrid(finalX, finalY, finalZ);
    return;
  }

  int totalPoints = finalX.length;
  boolean useDelaunay = (lasImportMeshAlgorithm == LAS_MESH_ALGORITHM_DELAUNAY);

  // The 2 algorithms' own minimum point count (meshPointCloud_
  // delaunayXY() needs 3, meshPointCloud_gridXY() needs 4 - see each
  // one's own comment for why) and point cap (MESH_POINT_CLOUD_
  // DELAUNAY_MAX_POINTS, meshPointCloud.pde, vs MESH_POINT_CLOUD_
  // GRID_MAX_POINTS, meshPointCloudGrid.pde - see that file's own
  // comment for why it's so much higher) differ, so which one applies
  // here depends on lasImportMeshAlgorithm the same way the actual
  // meshing call, a few lines down, does.
  int minPointsNeeded = useDelaunay ? 3 : 4;
  int maxPointsAllowed = useDelaunay ? MESH_POINT_CLOUD_DELAUNAY_MAX_POINTS : MESH_POINT_CLOUD_GRID_MAX_POINTS;

  // Either algorithm returns instantly (no real work, nothing to show
  // progress on) once its own point count falls outside what it accepts
  // (which also prints its own message) - so this skips straight to
  // calling it with no progress phase at all, rather than showing a
  // "Meshing..." message/ProgressWindow around a call that's about to
  // do nothing.
  if ((totalPoints < minPointsNeeded) || (totalPoints > maxPointsAllowed)) {
    ArrayList<int[]> faces = useDelaunay
      ? meshPointCloud_delaunayXY(finalX, finalY, null)
      : meshPointCloud_gridXY(finalX, finalY, null);
    for (int[] face : faces) {
      lasCreateFace(pointIndex, face);
    }
    return;
  }

  println("\nMeshing the point cloud into a surface. Please wait...");
  progressBarHeader();

  ProgressWindow meshProgressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("Meshing LAS point cloud") : null;
  if (meshProgressWindow != null) meshProgressWindow.setVisible(true);

  LasMeshProgressReporter reporter = new LasMeshProgressReporter(meshProgressWindow);

  ArrayList<int[]> faces;
  try {
    faces = useDelaunay
      ? meshPointCloud_delaunayXY(finalX, finalY, reporter)
      : meshPointCloud_gridXY(finalX, finalY, reporter);
  } finally {
    if (meshProgressWindow != null) meshProgressWindow.dispose();
  }

  int remaining = (int) floor(100 - reporter.printedProgress);
  StringBuilder barBuffer = new StringBuilder();
  for (int c = 0; c < remaining; c++) barBuffer.append('█');
  print(barBuffer.toString());
  println();

  for (int[] face : faces) {
    lasCreateFace(pointIndex, face);
  }
}

// The box-grid algorithm's own version of lasMeshPointCloud() just
// above - mirrors its own progress-reporting shape (console bar,
// optional ProgressWindow, LasMeshProgressReporter reused as-is since
// MeshPointCloudProgressListener is shared across all 3 algorithms -
// see that interface's own comment, meshPointCloud.pde), but calls
// meshPointCloud_boxGridXY() (meshPointCloudBoxGrid.pde) instead and
// hands its own BoxGridCell results to lasCreateBoxGridFaces() (below)
// rather than lasCreateFace() - that function builds real geometry
// directly, not index-arrays into finalX/finalY/finalZ, so there's no
// pointIndex table to thread through here at all.
void lasMeshPointCloudBoxGrid (float[] finalX, float[] finalY, float[] finalZ) {

  int totalPoints = finalX.length;

  if ((totalPoints < 1) || (totalPoints > MESH_POINT_CLOUD_GRID_MAX_POINTS)) {
    ArrayList<BoxGridCell> cells = meshPointCloud_boxGridXY(finalX, finalY, finalZ, null);
    lasCreateBoxGridFaces(cells);
    return;
  }

  println("\nMeshing the point cloud into a surface. Please wait...");
  progressBarHeader();

  ProgressWindow meshProgressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("Meshing LAS point cloud") : null;
  if (meshProgressWindow != null) meshProgressWindow.setVisible(true);

  LasMeshProgressReporter reporter = new LasMeshProgressReporter(meshProgressWindow);

  ArrayList<BoxGridCell> cells;
  try {
    cells = meshPointCloud_boxGridXY(finalX, finalY, finalZ, reporter);
  } finally {
    if (meshProgressWindow != null) meshProgressWindow.dispose();
  }

  int remaining = (int) floor(100 - reporter.printedProgress);
  StringBuilder barBuffer = new StringBuilder();
  for (int c = 0; c < remaining; c++) barBuffer.append('█');
  print(barBuffer.toString());
  println();

  lasCreateBoxGridFaces(cells);
}

// Turns every BoxGridCell meshPointCloud_boxGridXY() (meshPointCloud
// BoxGrid.pde) returned into a real box: 1 flat top face plus 4 vertical
// side faces, each built via lasCreateMesh2Face() (below). All of a
// cell's own 4 sides go down to the SAME baseZ - the lowest topZ among
// every cell in this result - a deliberately simple choice (a shared
// "ground" level every box's own sides reach down to, like a bar chart)
// rather than each box's own sides stopping at its own neighbors' own,
// generally different heights, which would need knowing which cells are
// actually adjacent and would leave a gap wherever a cell has no
// neighbor on some side at all (e.g. the whole mesh's own outer edge) -
// a shared base avoids both of those for a real, if simpler, trade-off:
// every box's side walls are visible all the way down to that one base
// level, not just the single "step" between its own height and a
// neighbor's.
void lasCreateBoxGridFaces (ArrayList<BoxGridCell> cells) {
  if (cells.isEmpty()) return;

  float baseZ = cells.get(0).topZ;
  for (BoxGridCell cell : cells) {
    if (cell.topZ < baseZ) baseZ = cell.topZ;
  }

  for (BoxGridCell cell : cells) {
    // Top.
    lasCreateMesh2Face(cell.minX, cell.minY, cell.topZ, cell.maxX, cell.maxY, cell.topZ);
    // The 4 vertical sides, down to the shared baseZ above - each pair
    // of corners here shares exactly one of X/Y already (by construction,
    // a cell's own 2 opposite edges), which is exactly what
    // lasCreateMesh2Face() needs to build an axis-aligned rectangle from
    // them.
    lasCreateMesh2Face(cell.minX, cell.minY, cell.topZ, cell.maxX, cell.minY, baseZ);
    lasCreateMesh2Face(cell.minX, cell.maxY, cell.topZ, cell.maxX, cell.maxY, baseZ);
    lasCreateMesh2Face(cell.minX, cell.minY, cell.topZ, cell.minX, cell.maxY, baseZ);
    lasCreateMesh2Face(cell.maxX, cell.minY, cell.topZ, cell.maxX, cell.maxY, baseZ);
  }
}

// One "Mesh2"-shaped face (this app's own name - Create3D's own add_
// Mesh2(), create3D.pde - for an axis-aligned rectangle built from just
// 2 diagonal corners, with the other 2 corners computed so one of X/Y/Z
// stays constant across all 4) via DIRECT allPoints.create()/allFaces.
// create() calls - the exact same corner-deduction add_Mesh2() itself
// uses, just called this way rather than through that higher-level
// function: add_Mesh2() also wraps itself in its own beginScene3DChange()/
// endScene3DChange() pair (a real undo-history snapshot on every call
// that isn't already nested inside an outer one) and calls model_added()
// every time, neither of which this importer's own tight per-face loops
// anywhere else ever pay either (lasCreateFace(), below, calls allFaces.
// create() directly for the exact same reason) - calling it up to 5
// times per box, for potentially thousands of boxes (lasCreateBoxGrid
// Faces(), above), would make THAT overhead, not the actual geometry
// work, the real cost of this algorithm.
//
// Silently does nothing for a degenerate (zero-area) rectangle - the 2
// given corners being identical on every axis - the same guard add_
// Mesh2() itself already has.
void lasCreateMesh2Face (float x1, float y1, float z1, float x3, float y3, float z3) {
  if ((x1 == x3) && (y1 == y3) && (z1 == z3)) return;

  float x2 = x3, y2 = y3, z2 = z3;
  float x4 = x1, y4 = y1, z4 = z1;

  if (z1 == z3) {
    y2 = y1;
    y4 = y3;
  } else if (y1 == y3) {
    x2 = x1;
    x4 = x3;
  } else if (x1 == x3) {
    z2 = z1;
    z4 = z3;
  }

  int v1 = allPoints.create(x1, y1, z1);
  int v2 = allPoints.create(x2, y2, z2);
  int v3 = allPoints.create(x3, y3, z3);
  int v4 = allPoints.create(x4, y4, z4);

  allFaces.create(new int[]{ v1, v2, v3, v4 });
  lasFacesImported += 1;
}

// Turns one meshPointCloud_delaunayXY()/meshPointCloud_gridXY() result
// entry - one face's own vertex indices into finalX/finalY (always
// 3-long for the Delaunay algorithm, always 4-long for the grid one -
// see meshPointCloud_gridXY()'s own comment, meshPointCloudGrid.pde,
// for why that one's different) - into one real allFaces entry, mapping
// each index through pointIndex (lasPointIndex, import_objects_LAS()'s
// own local-to-allPoints index table) the same way regardless of how
// many vertices the face actually has - allFaces.create() (faces.pde)
// already accepts a face of any vertex count, the same way Create3D's
// own add_Mesh4()/add_Mesh5() (create3D.pde) already hand it a single
// 4- or 5-long face rather than splitting into triangles themselves.
void lasCreateFace (int[] pointIndex, int[] localIndices) {
  int[] faceNodes = new int[localIndices.length];
  for (int k = 0; k < localIndices.length; k++) faceNodes[k] = pointIndex[localIndices[k]];
  allFaces.create(faceNodes);
  lasFacesImported += 1;
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

  h.maxX = binReadDoubleLE(raw, 179);
  h.minX = binReadDoubleLE(raw, 187);
  h.maxY = binReadDoubleLE(raw, 195);
  h.minY = binReadDoubleLE(raw, 203);
  h.maxZ = binReadDoubleLE(raw, 211);
  h.minZ = binReadDoubleLE(raw, 219);

  return h;
}

// lasShowImportOptionsDialog() itself - the dialog import_objects_LAS()
// above calls when lasImportShowOptionsDialog is armed - lives in
// fileSelected.pde, alongside ifcShowImportOptionsDialog()/gbxmlShow
// ImportOptionsDialog() and selectFile_ImportLas(), not here: same
// reasoning as those two, it's pure UI, not import logic.
