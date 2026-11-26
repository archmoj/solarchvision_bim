// Minimal, dependency-free importer for an ESRI Shapefile (the ESRI
// Shapefile Technical Description, An ESRI White Paper - July 1998,
// J-7855) - built directly on top of importGeojson.pde's own shared core
// (geojsonEmitPointFromXYZ()/geojsonEmitLineStringFromPoints()/
// geojsonEmitPolygonFromRings()/geojsonLonLatAltToXYZ()/
// geojsonApplyGrouping()/geojsonResolveHeight()/geojsonStripClosingDuplicate()
// /geojsonNoteSkipped() and this same import's own running point/line/
// face/solid/skipped counters, reused exactly as GeoJSON/TopoJSON/KML/
// CityGML import already use it, not duplicated) - the fifth format of
// the GIS-import run, after the discussion that followed CityGML
// ("Any other interesting format to support?").
//
// UNLIKE every GIS format this app already imports (all plain text -
// JSON or XML), a shapefile's own main file (.shp) is BINARY, so this
// reads it the same way importStl.pde's own binary-STL path/importLas.
// pde's own LAS reading already do: loadBytes() plus this app's own
// shared binReadU32LE()/binReadU16LE()/binReadFloatLE()/binReadLongLE()/
// binReadDoubleLE() byte-assembly helpers (importGlb.pde) for every
// little-endian field - the shapefile format's own numbers and
// doubles; shpReadInt32BE() below (this file's own, since nothing
// else in this app needs a big-endian 32-bit int) is added for the
// handful of big-endian fields the spec itself calls out (the main
// file header's own file-length field, and each record header's own
// record-number/content-length pair) - see "Byte order" in the spec:
// everything else (shape type, coordinates, counts) is little-endian.
//
// A shapefile is actually up to three separate files sharing one base
// name: the main file (.shp, geometry - the only one actually required
// to import SOME geometry), an attribute table (.dbf, dBASE III format -
// this importer reads it for the same reason importKml.pde's own
// <ExtendedData>/importCitygml.pde's own generic attributes are read:
// to build a synthetic "properties" JSONObject so geojsonApplyGrouping()/
// geojsonResolveHeight() both work completely unmodified), and a
// projection file (.prj, a WKT-encoded coordinate reference system -
// read only far enough to guess geographic vs. projected, see
// "Coordinate system" below). This importer finds the sibling .dbf/.prj
// files itself (shpSiblingFile() below, same base name as the selected
// .shp, case-insensitive extension) - the person only ever picks the one
// .shp file, same as picking one .kml/.gml file already works for the
// other formats. The index file (.shx) is never read - this importer
// walks the main file's own record-length chain directly (same "no
// index needed for a single sequential pass" approach a point cloud/
// mesh importer already takes), and there is no .shz (zipped shapefile)
// support in this version, the same "no KMZ" limitation importKml.pde's
// own header comment already documents for KML.
//
// v1 scope - the shape types the spec defines (Shapefile Technical
// Description, "Shape Types" table), minus MultiPatch:
//   - Point/PointZ/PointM (codes 1/11/21) -> a bare vertex, the same
//     treatment every other format's own Point/MultiPoint already gets
//     in this shared core.
//   - MultiPoint/MultiPointZ/MultiPointM (codes 8/18/28) -> one bare
//     vertex per point, all sharing the one record's own properties/
//     grouping (applied once per record, not once per point - the same
//     granularity geojsonApplyGrouping() already uses once per GeoJSON
//     Feature/KML Placemark/CityGML Building).
//   - PolyLine/PolyLineZ/PolyLineM (codes 3/13/23) -> one Polyline per
//     "part" (a shapefile PolyLine/Polygon record can carry more than one
//     part - several disjoint lines, or several rings, in one record),
//     closed automatically when a part's own points already loop back to
//     their start, same auto-detect convention the whole shared core
//     already uses.
//   - Polygon/PolygonZ/PolygonM (codes 5/15/25) -> one flat n-gon Face
//     per OUTER ring (holes bridged into their own outer ring via the
//     same shared PolygonHoles.mergeHolesIntoOuterLoop()/
//     geojsonEmitPolygonFromRings() every other format's own Polygon
//     handling already uses) - or, when geojsonHeightProperty names a
//     .dbf field this record's own row actually carries a positive
//     numeric value for, an extruded solid instead, exactly the same
//     option GeoJSON/TopoJSON/KML/CityGML already share. A shapefile
//     record does not explicitly say which of its own rings are outer
//     boundaries and which are holes - per the spec ("Note: The order of
//     rings in the points array is not significant" is true of READING
//     order, but their own winding direction IS significant: "Vertices
//     of rings defining holes in polygons are in a counterclockwise
//     direction... polygons with only one, enclosing ring are specified
//     with clockwise vertices"), rings are grouped into polygons by
//     shpEmitPolygonRings() below: a ring with a NEGATIVE signed area
//     (clockwise, by the standard shoelace formula/Cartesian convention)
//     starts a new outer boundary; any following ring with a POSITIVE
//     signed area (counterclockwise) is a hole belonging to that most
//     recent outer ring, until the next clockwise ring starts the next
//     polygon - the same simple, sequential ring-to-polygon assignment
//     widely used shapefile readers already take (a file with several
//     NESTED levels of hole-within-hole-within-outer rings, each
//     correctly alternating winding direction at every level, is a real
//     edge case this simple v1 algorithm does not specially handle -
//     documented, not silently "fixed").
//   - MultiPatch (code 31) is NOT supported in this version - skipped
//     (geojsonNoteSkipped()), not an error - the same deliberately
//     narrow-scope choice importCitygml.pde's own header comment already
//     makes for CityGML's own out-of-scope feature types. A null shape
//     (code 0, a legitimate placeholder the spec explicitly allows) is
//     likewise skipped, not an error.
//
// Attributes: a .dbf row has a strict one-to-one positional
// correspondence with its own .shp record (the spec's own words: "Each
// attribute record has a one-to-one relationship with the associated
// shape record") - shpReadDbfProperties() below reads every field of
// every row into a synthetic "properties" JSONObject per row, every
// value stored as a String (trimmed of the fixed-width field's own
// space-padding - this shared core's own geojsonResolveHeight() already
// falls back to parsing a String value when a direct numeric read
// fails, so this costs nothing). A row marked deleted (the dBASE
// "deletion flag" byte) still occupies its own position (so every later
// row's own position still lines up with its own .shp record) but
// contributes null properties instead - its own shape is still
// imported, just without any attributes (a shapefile's own deletion
// flag means "deleted from the attribute table", not "this shape itself
// is gone" - the .shp file carries no deletion marker of its own at
// all). A shapefile with no sibling .dbf file at all imports every
// shape with null properties, exactly like a GeoJSON Feature with no
// "properties" member already does.
//
// Coordinate system: like CityGML (importCitygml.pde's own header
// comment's "Coordinate system" paragraph) and UNLIKE GeoJSON/TopoJSON/
// KML (always longitude/latitude degrees per their own specs), a
// shapefile's own X/Y/Z values could be either - there is nothing in the
// .shp/.dbf format itself to say which. When a sibling .prj file is
// present, its own WKT text is read just far enough to tell a geographic
// CRS ("GEOGCS[...]" at the top level - plain longitude/latitude
// degrees) from a projected one ("PROJCS[...]", or anything else -
// already real, local-planar-meters-ish coordinates, the same as
// importDxf.pde's/importObj.pde's own planar-CAD coordinates) -
// shpDetectLonLatFromPrj() below - and shpCoordinatesAreLonLat is set
// from that guess automatically, every import, before this importer's
// own options dialog is ever shown; its own checkbox still lets the
// person looking at the result override that guess by hand (a WKT
// string this simple substring check reads wrong, or a shapefile with no
// .prj file at all - defaulting to already-local-planar-meters, the
// same default importCitygml.pde's own identical checkbox already uses,
// for the same "most real-world files are already projected" reason).

boolean shpImportShowOptionsDialog = false;

// See this file's own header comment, "Coordinate system" paragraph -
// auto-detected (best-effort) from a sibling .prj file at the start of
// every import, before this value is ever shown in this importer's own
// options dialog; defaults false (already-local-planar-meters) the same
// way importCitygml.pde's own identical citygmlCoordinatesAreLonLat does
// when no .prj is found or its own WKT doesn't parse as recognizably
// geographic.
boolean shpCoordinatesAreLonLat = false;

void import_objects_SHP (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  // Best-effort .prj auto-detection happens BEFORE the options dialog
  // check below (this file's own header comment) - unconditionally, on
  // every import, whether or not the dialog ever actually shows (a
  // script-driven IMPORT.SHAPEFILE with a path already given, same as
  // extraCommands.pde's own __IMPORT_SHAPEFILE__, bypasses the dialog
  // entirely but should still benefit from this guess).
  String prjPath = shpSiblingFile(FileName, "prj");
  if (prjPath != null) {
    String prjText = shpReadTextFile(prjPath);
    if (prjText != null) shpCoordinatesAreLonLat = shpDetectLonLatFromPrj(prjText);
  }

  // Same shape as import_objects_GEOJSON()'s/import_objects_CITYGML()'s
  // own identical blocks - see either one's own comment for why this
  // sits here rather than earlier, and what a cancelled dialog does.
  if (shpImportShowOptionsDialog) {
    shpImportShowOptionsDialog = false;
    if (!shpShowImportOptionsDialog()) return;
  }

  println("\nImporting Shapefile. Please wait...");
  showWaitCursor();
  isImportingInProgress = true; // see this flag's own comment (globalFunctions.pde) for why - cleared alongside showArrowCursor() at every exit

  geojsonCycleMaterial = (m == -1);
  if (m == -1) current_Material = 0;
  else current_Material = m;

  current_Tessellation = tes;
  current_Layer = lyr;
  current_Visibility = vsb;
  current_Weight = wgt;
  current_Closed = clz;

  // Every one of these is importGeojson.pde's own running state, reused
  // as-is (this file's own header comment) rather than kept separately
  // per format.
  geojsonCurrentGroupKey = null;
  geojsonPointsImported = 0;
  geojsonLinesImported = 0;
  geojsonFlatFacesImported = 0;
  geojsonSolidsImported = 0;
  geojsonImportSkippedCount = 0;
  geojsonImportSkippedReasons = new HashMap<String, Integer>();

  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  byte[] raw = loadBytes(FileName);
  if (raw == null || raw.length < 100) {
    println("\nShapefile import: could not read '" + FileName + "' (missing, unreadable, or shorter than a 100-byte header)");
    isImportingInProgress = false;
    showArrowCursor();
    return;
  }

  String dbfPath = shpSiblingFile(FileName, "dbf");
  JSONObject[] dbfProperties = (dbfPath != null) ? shpReadDbfProperties(dbfPath) : null;

  // A first, lightweight pass over the record-header chain (record
  // number/content length only, never the geometry itself) - same reason
  // importKml.pde's own kmlCollectPlacemarks()/importCitygml.pde's own
  // citygmlCollectBuildingLikeElements() both collect their own "named
  // object" list before the real import loop: so the progress bar/
  // abort-check loop below knows its own total up front, the same
  // convention every other format's own import loop already follows.
  // Tolerant of a file that runs out before its own file-length header
  // field says it should (same "stopping early" tolerance importStl.
  // pde's own binary-STL path already documents for a truncated file).
  ArrayList<int[]> records = shpCollectRecordBodies(raw); // each entry: {bodyOffset, bodyLength}

  progressBarHeader();
  float printed_Progress = 0;
  boolean aborted = false;
  int totalRecords = records.size();
  float totalRecordsF = max(1, totalRecords); // avoid /0 below for a file with no records at all

  ProgressWindow importProgressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("\nImporting Shapefile") : null;
  if (importProgressWindow != null) importProgressWindow.setVisible(true);

  try {
    for (int r = 0; r < totalRecords; r++) {
      // Esc, caught by importProgressWindow's own Toolkit-level listener
      // (progressWindow.pde) regardless of which window has focus - same
      // as import_objects_GEOJSON()'s identical check. No rollback on
      // abort - whatever points/faces/polylines were already created
      // from the records read so far are kept, same as any other partial
      // import.
      if ((importProgressWindow != null) && importProgressWindow.abortRequested) {
        echoAbortProgress();
        aborted = true;
        break;
      }

      if (control != USER_AUTO) {
        float Progress = 100 * r / totalRecordsF;
        int delta = (int) floor(Progress - printed_Progress);
        if (delta >= 1) {
          printProgressBarChunk(delta); // one print() call instead of `delta` calls
          printed_Progress = floor(Progress);
          if (importProgressWindow != null) importProgressWindow.updateFraction(Progress / 100.0f);
        }
      }

      int[] rec = records.get(r);
      JSONObject properties = (dbfProperties != null && r < dbfProperties.length) ? dbfProperties[r] : null;
      shpHandleRecord(raw, rec[0], rec[1], properties, clz, cx, cy, cz, sx, sy, sz);
    }
  } finally {
    if (importProgressWindow != null) importProgressWindow.dispose();
  }

  if (!aborted) {
    int remaining = (int) floor(100 - printed_Progress);
    printProgressBarChunk(remaining);
    println();

    String summary = "Shapefile import complete: " + geojsonPointsImported + " point(s), " + geojsonLinesImported + " line(s), " + geojsonFlatFacesImported + " flat face(s), " + geojsonSolidsImported + " extruded solid(s) imported";
    if (geojsonImportSkippedCount > 0) summary += ", " + geojsonImportSkippedCount + " unsupported/malformed item(s) skipped";
    summary += ".";
    println();
    println(summary);
  }

  isImportingInProgress = false;
  showArrowCursor();
}

// Finds a sibling file next to `shpPath` - the same base name, a
// different extension - tried both lower-case and the case `shpPath`'s
// own extension itself uses (a shapefile's own three files don't always
// agree on case, especially coming from an older/case-sensitive
// filesystem), lower-case tried first since it's by far the common
// case. Returns the first one that actually exists and is a (regular)
// file, or null when neither does - every caller above already treats
// null as "no such sibling file, carry on without it", not an error.
String shpSiblingFile (String shpPath, String ext) {
  int dot = shpPath.lastIndexOf('.');
  String base = (dot >= 0) ? shpPath.substring(0, dot) : shpPath;

  String lower = base + "." + ext.toLowerCase();
  if (new File(lower).isFile()) return lower;

  String upper = base + "." + ext.toUpperCase();
  if (new File(upper).isFile()) return upper;

  return null;
}

// Reads a small text file (the .prj file's own WKT text - never large)
// as a plain String, tolerating any read failure by returning null - the
// same "a bad/missing file quietly falls back rather than crashing"
// tolerance this whole shared core already follows.
String shpReadTextFile (String path) {
  try {
    String[] lines = loadStrings(path);
    if (lines == null) return null;
    StringBuilder sb = new StringBuilder();
    for (String line : lines) sb.append(line).append('\n');
    return sb.toString();
  }
  catch (Exception e) {
    return null;
  }
}

// This file's own header comment, "Coordinate system" paragraph - a
// deliberately simple substring check, not a real WKT parser: true only
// when the WKT text's own FIRST recognizable keyword is "GEOGCS"
// (plain longitude/latitude degrees), false for "PROJCS" (already
// projected, real planar coordinates) or anything else this simple
// check doesn't recognize (a compound/local/unknown CRS, or malformed
// WKT) - the same conservative "default to already-local-planar-meters
// unless there's a clear, specific reason to think otherwise" stance
// importCitygml.pde's own identical option already takes.
boolean shpDetectLonLatFromPrj (String wkt) {
  if (wkt == null) return false;
  String trimmed = wkt.trim();
  return trimmed.regionMatches(true, 0, "GEOGCS", 0, 6);
}

// Walks the main file's own record-header chain (Record Header: Byte 0
// record number (int32 BE), Byte 4 content length (int32 BE, in 16-bit
// words) - Shapefile Technical Description's own "Main File Record
// Contents" section), from right after the 100-byte file header to the
// end of `raw`, collecting each record's own (bodyOffset, bodyLength)
// pair - `bodyOffset` points at that record's own shape-type field (the
// first 4 bytes of "Record Contents"), `bodyLength` is that record's own
// content length converted from 16-bit words to bytes. Stops (without
// throwing) the moment a record header or body would run past the end
// of `raw` - the same "stopping early" tolerance importStl.pde's own
// binary-STL path already documents for a truncated file, rather than
// trusting the file header's own file-length field blindly.
ArrayList<int[]> shpCollectRecordBodies (byte[] raw) {
  ArrayList<int[]> result = new ArrayList<int[]>();
  int pos = 100; // right after the 100-byte main file header
  while (pos + 8 <= raw.length) {
    int contentLengthWords = shpReadInt32BE(raw, pos + 4);
    int bodyLength = contentLengthWords * 2;
    int bodyOffset = pos + 8;
    if (bodyLength < 0 || bodyOffset + bodyLength > raw.length) break; // truncated/malformed - stop rather than read past the end of the file
    result.add(new int[]{bodyOffset, bodyLength});
    pos = bodyOffset + bodyLength;
  }
  return result;
}

// One main-file record's own "Record Contents" - `bodyOffset`/
// `bodyLength` from shpCollectRecordBodies() above. Reads this record's
// own shape type (the first 4 bytes, little-endian - Byte Order,
// Shapefile Technical Description) and dispatches it; applies this
// import's own grouping option once per record (mirroring GeoJSON's own
// once-per-Feature/KML's own once-per-Placemark/CityGML's own once-per-
// Building granularity), even for a record carrying several points/parts
// (MultiPoint, or a multi-part PolyLine/Polygon) - every one of those
// shares the one record's own properties/group.
void shpHandleRecord (byte[] raw, int bodyOffset, int bodyLength, JSONObject properties, int clzParam, float cx, float cy, float cz, float sx, float sy, float sz) {
  if (bodyLength < 4) { geojsonNoteSkipped("record with no shape type (null/empty content)"); return; } // a true Null Shape (type 0) has zero content length - caught here, not worth a separate "type == 0" branch
  int shapeType = binReadU32LE(raw, bodyOffset);

  geojsonApplyGrouping(properties);

  if (shapeType == 0) {
    geojsonNoteSkipped("Null shape");
  } else if (shapeType == 1 || shapeType == 11 || shapeType == 21) {
    shpHandlePoint(raw, bodyOffset, shapeType, cx, cy, cz, sx, sy, sz);
  } else if (shapeType == 8 || shapeType == 18 || shapeType == 28) {
    shpHandleMultiPoint(raw, bodyOffset, shapeType, cx, cy, cz, sx, sy, sz);
  } else if (shapeType == 3 || shapeType == 13 || shapeType == 23) {
    shpHandlePolyLine(raw, bodyOffset, shapeType, properties, clzParam, cx, cy, cz, sx, sy, sz);
  } else if (shapeType == 5 || shapeType == 15 || shapeType == 25) {
    shpHandlePolygon(raw, bodyOffset, shapeType, properties, cx, cy, cz, sx, sy, sz);
  } else if (shapeType == 31) {
    geojsonNoteSkipped("MultiPatch (unsupported in this version)");
  } else {
    geojsonNoteSkipped("unsupported/unrecognized shape type: " + shapeType);
  }
}

// Point (1)/PointZ (11)/PointM (21) - X, Y, then Z for the Z variant
// only (Byte Order/"Point" in the spec); an M variant's own M value (and
// a Z variant's own, after Z) is never read at all - this importer has
// no use for it, and skipping it costs nothing since the NEXT record is
// always found via this record's own content length
// (shpCollectRecordBodies() above), never by how many bytes this
// function itself consumed.
void shpHandlePoint (byte[] raw, int bodyOffset, int shapeType, float cx, float cy, float cz, float sx, float sy, float sz) {
  int pos = bodyOffset + 4;
  double x = binReadDoubleLE(raw, pos);
  double y = binReadDoubleLE(raw, pos + 8);
  double z = (shapeType == 11) ? binReadDoubleLE(raw, pos + 16) : 0;
  float[] xyz = shpCoordToXYZ(x, y, z, cx, cy, cz, sx, sy, sz);
  geojsonEmitPointFromXYZ(xyz);
}

// MultiPoint (8)/MultiPointZ (18)/MultiPointM (28) - a bare vertex per
// point, all from the one record (this file's own header comment on why
// grouping is still only applied once, by this function's own caller).
void shpHandleMultiPoint (byte[] raw, int bodyOffset, int shapeType, float cx, float cy, float cz, float sx, float sy, float sz) {
  int pos = bodyOffset + 4 + 32; // shape type + bounding box (Byte Order/"MultiPoint")
  int numPoints = binReadU32LE(raw, pos);
  pos += 4;
  if (numPoints < 0) { geojsonNoteSkipped("MultiPoint with a malformed point count"); return; }

  int pointsStart = pos;
  double[] zValues = null;
  if (shapeType == 18) {
    int zStart = pointsStart + numPoints * 16 + 16; // past every (x,y) pair, then past the 16-byte Z range
    zValues = new double[numPoints];
    for (int i = 0; i < numPoints; i++) zValues[i] = binReadDoubleLE(raw, zStart + i * 8);
  }

  for (int i = 0; i < numPoints; i++) {
    double x = binReadDoubleLE(raw, pointsStart + i * 16);
    double y = binReadDoubleLE(raw, pointsStart + i * 16 + 8);
    double z = (zValues != null) ? zValues[i] : 0;
    float[] xyz = shpCoordToXYZ(x, y, z, cx, cy, cz, sx, sy, sz);
    geojsonEmitPointFromXYZ(xyz);
  }
}

// PolyLine (3)/PolyLineZ (13)/PolyLineM (23) - one Polyline per "part"
// (Byte Order/"PolyLine": a record may carry more than one disjoint
// line), via this shared core's own geojsonEmitLineStringFromPoints()
// (importGeojson.pde) - same closing-duplicate auto-detect every other
// format's own LineString/Polyline handling already uses.
void shpHandlePolyLine (byte[] raw, int bodyOffset, int shapeType, JSONObject properties, int clzParam, float cx, float cy, float cz, float sx, float sy, float sz) {
  ArrayList<ArrayList<PVector>> parts = shpReadParts(raw, bodyOffset, shapeType, cx, cy, cz, sx, sy, sz);
  if (parts == null) { geojsonNoteSkipped("PolyLine with a malformed part/point count"); return; }

  for (ArrayList<PVector> part : parts) {
    if (part.size() < 2) { geojsonNoteSkipped("PolyLine part with fewer than 2 points"); continue; }
    geojsonEmitLineStringFromPoints(part, properties, clzParam);
  }
}

// Polygon (5)/PolygonZ (15)/PolygonM (25) - every "part" is a ring (Byte
// Order/"Polygon"); shpEmitPolygonRings() below groups them into one or
// more actual polygons (outer ring + its own holes) by winding direction
// (this file's own header comment's own "v1 scope" paragraph on
// Polygon), then emits each via the same shared
// geojsonEmitPolygonFromRings() every other format's own Polygon
// handling already uses.
void shpHandlePolygon (byte[] raw, int bodyOffset, int shapeType, JSONObject properties, float cx, float cy, float cz, float sx, float sy, float sz) {
  ArrayList<ArrayList<PVector>> rings = shpReadParts(raw, bodyOffset, shapeType, cx, cy, cz, sx, sy, sz);
  if (rings == null) { geojsonNoteSkipped("Polygon with a malformed part/point count"); return; }

  shpEmitPolygonRings(rings, properties, sz);
}

// The shared "read every part's own points" step PolyLine/Polygon both
// use (Byte Order/"PolyLine"+"Polygon" - byte-for-byte identical layout:
// bounding box, number of parts, number of points, parts array, points
// array, then - for the Z variants only - a Z range followed by one Z
// value per point). Returns one ArrayList<PVector> per part, in file
// order - null on a malformed/negative part or point count, so both
// callers above can note it as skipped rather than reading garbage.
ArrayList<ArrayList<PVector>> shpReadParts (byte[] raw, int bodyOffset, int shapeType, float cx, float cy, float cz, float sx, float sy, float sz) {
  int pos = bodyOffset + 4 + 32; // shape type + bounding box
  int numParts = binReadU32LE(raw, pos);
  pos += 4;
  int numPoints = binReadU32LE(raw, pos);
  pos += 4;
  if (numParts < 0 || numPoints < 0) return null;

  int[] partStarts = new int[numParts];
  for (int i = 0; i < numParts; i++) { partStarts[i] = binReadU32LE(raw, pos); pos += 4; }

  int pointsStart = pos;
  boolean hasZ = (shapeType == 13 || shapeType == 15);
  double[] zValues = null;
  if (hasZ) {
    int zStart = pointsStart + numPoints * 16 + 16; // past every (x,y) pair, then past the 16-byte Z range
    zValues = new double[numPoints];
    for (int i = 0; i < numPoints; i++) zValues[i] = binReadDoubleLE(raw, zStart + i * 8);
  }

  ArrayList<ArrayList<PVector>> parts = new ArrayList<ArrayList<PVector>>();
  for (int p = 0; p < numParts; p++) {
    int startIdx = partStarts[p];
    int endIdx = (p + 1 < numParts) ? (partStarts[p + 1] - 1) : (numPoints - 1);
    ArrayList<PVector> pts = new ArrayList<PVector>();
    for (int i = startIdx; i <= endIdx && i >= 0 && i < numPoints; i++) {
      double x = binReadDoubleLE(raw, pointsStart + i * 16);
      double y = binReadDoubleLE(raw, pointsStart + i * 16 + 8);
      double z = (zValues != null) ? zValues[i] : 0;
      float[] xyz = shpCoordToXYZ(x, y, z, cx, cy, cz, sx, sy, sz);
      pts.add(new PVector(xyz[0], xyz[1], xyz[2]));
    }
    parts.add(pts);
  }
  return parts;
}

// Groups a Polygon record's own rings into one or more actual polygons
// by winding direction (this file's own header comment's "v1 scope"
// paragraph) and emits each one via the shared
// geojsonEmitPolygonFromRings() (importGeojson.pde). A ring with a
// NEGATIVE signed area (clockwise) starts a new outer boundary; a
// following ring with a POSITIVE signed area (counterclockwise) is a
// hole belonging to that most recent outer ring. A counterclockwise ring
// with no preceding clockwise ring at all (malformed/unusual ring order)
// is defensively treated as its own outer boundary instead of being
// silently dropped - geometry is kept, just not correctly identified as
// a hole, a documented limitation rather than a crash.
void shpEmitPolygonRings (ArrayList<ArrayList<PVector>> rings, JSONObject properties, float sz) {
  ArrayList<PVector> currentOuter = null;
  ArrayList<ArrayList<PVector>> currentHoles = null;

  for (ArrayList<PVector> ring : rings) {
    geojsonStripClosingDuplicate(ring); // a shapefile ring conventionally repeats its own first point as its last, same as a GeoJSON Polygon ring always does
    if (ring.size() < 3) { geojsonNoteSkipped("degenerate polygon ring (fewer than 3 distinct points)"); continue; }

    boolean isOuter = shpSignedRingArea(ring) < 0;
    if (isOuter || currentOuter == null) {
      if (currentOuter != null) geojsonEmitPolygonFromRings(currentOuter, currentHoles, properties, sz);
      currentOuter = ring;
      currentHoles = new ArrayList<ArrayList<PVector>>();
    } else {
      currentHoles.add(ring);
    }
  }
  if (currentOuter != null) geojsonEmitPolygonFromRings(currentOuter, currentHoles, properties, sz);
}

// The standard shoelace/Gauss's-area-formula signed area of a ring's own
// X/Y (Z never affects winding direction) - positive for a
// counterclockwise ring, negative for clockwise, in the ordinary
// Cartesian (X right, Y up) sense the Shapefile Technical Description's
// own "clockwise"/"counterclockwise" language already assumes. `ring`
// must already be closing-duplicate-stripped (shpEmitPolygonRings()'s
// own caller above) - this sums over the ring's own OPEN point list,
// wrapping the last edge back to the first point itself.
double shpSignedRingArea (ArrayList<PVector> ring) {
  double area = 0;
  int n = ring.size();
  for (int i = 0; i < n; i++) {
    PVector p0 = ring.get(i);
    PVector p1 = ring.get((i + 1) % n);
    area += (double) p0.x * p1.y - (double) p1.x * p0.y;
  }
  return area / 2.0;
}

// This file's own header comment, "Coordinate system" paragraph -
// identical planar-by-default/lon-lat-opt-in switch as importCitygml.
// pde's own citygmlCoordToXYZ(), just reading shpCoordinatesAreLonLat
// instead. `x`/`y`/`z` are doubles (every shapefile coordinate is
// IEEE-754 float64) narrowed to float only here, at the very last step,
// same as every other numeric narrowing in this shared core already
// does.
float[] shpCoordToXYZ (double x, double y, double z, float cx, float cy, float cz, float sx, float sy, float sz) {
  if (shpCoordinatesAreLonLat) return geojsonLonLatAltToXYZ((float) x, (float) y, (float) z, cx, cy, cz, sx, sy, sz);
  return new float[]{ cx + sx * (float) x, cy + sy * (float) y, cz + sz * (float) z };
}

// Big-endian 32-bit signed int - the handful of fields the spec itself
// calls out as big-endian (the main file header's own file-length
// field, Byte 24; each record header's own record-number/content-length
// pair, Bytes 0/4) - everything else in a shapefile is little-endian
// (this file's own header comment's own "Byte order" paragraph), so this
// is this file's own, not shared with importGlb.pde's own binReadU32LE()
// and friends (every one of those is little-endian only).
int shpReadInt32BE (byte[] b, int off) {
  return ((b[off] & 0xFF) << 24) | ((b[off + 1] & 0xFF) << 16) | ((b[off + 2] & 0xFF) << 8) | (b[off + 3] & 0xFF);
}

// Reads a sibling .dbf file's own rows into one synthetic "properties"
// JSONObject per row, in file order - this file's own header comment's
// "Attributes" paragraph. Returns null (not a zero-length array) when
// the file can't be read/parsed at all - every caller above already
// treats that the same as "no .dbf file found".
JSONObject[] shpReadDbfProperties (String dbfPath) {
  byte[] raw = loadBytes(dbfPath);
  if (raw == null || raw.length < 32) return null; // shorter than even one empty header + terminator

  int numRecords = binReadU32LE(raw, 4);
  int headerLen = binReadU16LE(raw, 8);
  int recordLen = binReadU16LE(raw, 10);
  if (numRecords < 0 || headerLen < 32 || recordLen < 1 || headerLen > raw.length) return null;

  // Field descriptors: 32 bytes each, starting right after the 32-byte
  // header proper, until the 0x0D terminator byte (dBASE III file
  // header layout) - name (11 bytes, ASCII, null-padded), type (1 byte,
  // never actually read: every field's own value is kept as a trimmed
  // String regardless of its declared type, same reasoning this file's
  // own header comment gives), 4 reserved bytes, length (1 byte,
  // unsigned), decimal count (1 byte, never read - this importer has no
  // use for it, a trimmed numeric string already parses correctly via
  // geojsonResolveHeight()'s own string fallback), 14 further reserved
  // bytes.
  ArrayList<String> fieldNames = new ArrayList<String>();
  ArrayList<Integer> fieldLengths = new ArrayList<Integer>();
  int pos = 32;
  while (pos < headerLen - 1 && pos + 32 <= raw.length && raw[pos] != 0x0D) {
    String name = shpDbfString(raw, pos, 11);
    int length = raw[pos + 16] & 0xFF;
    fieldNames.add(name);
    fieldLengths.add(length);
    pos += 32;
  }

  int numFields = fieldNames.size();
  JSONObject[] result = new JSONObject[numRecords];
  int recordStart = headerLen;
  for (int r = 0; r < numRecords; r++) {
    if (recordStart + recordLen > raw.length) break; // truncated file - stop rather than read past the end, same tolerance shpCollectRecordBodies() above already follows
    boolean deleted = (raw[recordStart] == 0x2A); // '*' - dBASE's own deletion flag; ' ' (0x20) means not deleted
    if (!deleted) {
      JSONObject row = new JSONObject();
      int fieldOffset = recordStart + 1; // past the one-byte deletion flag
      for (int f = 0; f < numFields; f++) {
        int len = fieldLengths.get(f);
        String value = shpDbfString(raw, fieldOffset, len).trim();
        row.setString(fieldNames.get(f), value);
        fieldOffset += len;
      }
      result[r] = row;
    }
    recordStart += recordLen;
  }
  return result;
}

// Reads `len` bytes starting at `off` as a plain ASCII/Latin-1 string,
// trimming any trailing NUL padding (a .dbf field NAME is NUL-padded;
// a field VALUE is space-padded, trimmed separately by this file's own
// shpReadDbfProperties() above) - no dBASE "language driver"/codepage
// support in this version (a non-ASCII field name or value may come
// through with the wrong characters for a non-Latin-1 codepage file),
// a documented v1 limitation, same spirit as this file's own "no KMZ"/
// "no MultiPatch" ones.
String shpDbfString (byte[] b, int off, int len) {
  int end = off + len;
  int nul = off;
  while (nul < end && b[nul] != 0) nul++;
  return new String(b, off, nul - off, java.nio.charset.StandardCharsets.ISO_8859_1);
}
