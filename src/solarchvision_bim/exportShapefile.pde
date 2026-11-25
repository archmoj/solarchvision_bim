// Minimal, dependency-free exporter for an ESRI Shapefile - the write-
// side counterpart to importShapefile.pde. Reuses exportGeojson.pde's own
// shared "GIS export core" for the one piece of geometry math shapefiles
// actually share with GeoJSON/KML (reverse-projecting a vertex to
// [longitude, latitude, altitude] - exportGeojsonPointToLonLatAlt(), and
// the shoelace signed-area test - exportGeojsonSignedRingArea(), both
// reused exactly as-is, not duplicated), but not its JSON/XML writing -
// a shapefile is three to four separate binary/text files, not one
// document, so this file's own binary writers are its own, the same
// "hand-roll it, no external library" choice importShapefile.pde already
// makes for reading, and exportLas.pde already makes for writing (its own
// binWriteU16LE()/binWriteU32LE()/binWriteLongLE()/binWriteDoubleLE()
// little-endian writers are reused here as-is too - no reason to
// duplicate those, only shpWriteInt32BE() below is genuinely new, since
// nothing else in this app writes big-endian).
//
// Coordinates: every vertex is reverse-projected to real longitude/
// latitude exactly like exportGeojson.pde/exportKml.pde (not left as
// local planar meters the way exportCitygml.pde deliberately stays) -
// unlike CityGML, a shapefile's own coordinate system is declared by its
// sibling .prj file, not implied by the format itself, so there is no
// reason to default to a planar passthrough the way CityGML's own common
// real-world usage justifies; writing real longitude/latitude plus a
// WGS84 .prj (see "Sidecar files" below) produces a shapefile usable
// immediately in any GIS tool with no further georeferencing step, the
// same reasoning exportGeojson.pde's own "Coordinates" comment already
// gives for GeoJSON.
//
// Winding: every ring is rewound CLOCKWISE (negative shoelace signed
// area) when necessary - the exact opposite of exportGeojson.pde's own
// counterclockwise rewinding, per this format's own convention
// (importShapefile.pde's own header comment: "exterior/outer rings are
// stored CLOCKWISE, holes stored COUNTERCLOCKWISE... a CLOCKWISE ring has
// NEGATIVE signed area"). No holes are ever written, for the exact same
// "this app keeps no separate outer/hole bookkeeping once a hole has
// been bridged into a Face" reason exportGeojson.pde's own "Scope"
// comment already explains.
//
// One file per geometry type: unlike GeoJSON/KML/CityGML, a single .shp
// file can only ever hold ONE shape type (the 100-byte header's own
// shape_type field applies to the whole file, not per-record) - a real
// structural constraint of this format, not a shortcut. So this exporter
// writes up to two separate file sets:
//   - "<ProjectName>.shp/.shx/.dbf/.prj" - every visible Face, as a
//     PolygonZ (type 15) record each - this is the PRIMARY output,
//     always written (even with zero Faces, producing a valid empty
//     shapefile), the same ".<ext>" naming and "always write, possibly
//     empty" convention every other exporter in this app already uses.
//   - "<ProjectName>_lines.shp/.shx/.dbf/.prj" - every visible Polyline,
//     as a PolyLineZ (type 13) record each - a SECONDARY, optional
//     output, only written when at least one visible Polyline with 2+
//     nodes actually exists, so a scene with no lines at all doesn't
//     grow an always-empty second file set nobody asked for.
// Point/MultiPoint geometry is never written - this app has no
// dedicated point/marker object, the same reasoning every other GIS
// exporter in this tier already gives.
//
// Z vs M: both PolygonZ/PolyLineZ records are written with their own Z
// range/array (altitude) but their OPTIONAL M range/array is omitted
// entirely, following the same real-world precedent GDAL's own ogr2ogr
// already follows for exactly this case (confirmed via a GDAL bug
// tracker discussion on this precise question - a PolygonZ with no M
// data is written as plain XYZ, no M arrays at all, "under the
// assumption that it is legal... and that applications will detect this
// properly") - the record header's own content_length is what locates
// the next record either way (see importShapefile.pde's own
// shpCollectRecordBodies(), which never relies on M presence/absence to
// find record boundaries), so omitting M costs nothing on this app's own
// read side either.
//
// Sidecar files:
//   - .shx: the index file importShapefile.pde's own header comment
//     says this app never NEEDS to read (a sequential walk of the main
//     file's own record-length chain is enough for one pass) - but many
//     other real-world GIS tools do expect a valid one to open a
//     shapefile at all, so one is always written alongside, built from
//     the exact same per-record offsets/lengths the main file's own
//     records already use.
//   - .dbf: one row per .shp record, in the exact same order (the
//     format's own strict 1:1 positional correspondence - see
//     importShapefile.pde's own header comment) - two Numeric ('N')
//     fields, "material" and "layer", holding that record's own source
//     Face's/Polyline's material/layer, the same round-trip purpose
//     exportGeojson.pde's own "Properties" comment already documents.
//   - .prj: a plain WGS84 GEOGCS WKT string - exactly the text
//     shpDetectLonLatFromPrj() (importShapefile.pde) already looks for
//     to auto-detect "this file's own coordinates are longitude/
//     latitude" on the way back in, matching what this exporter actually
//     writes.

void exportShapefile () {

  // See isFileOperationInProgress's own comment (globalFunctions.pde)
  // for why - bare statement (this function has only the one exit point
  // below, so nothing further to guard); cleared at this function's own
  // end.
  isFileOperationInProgress = true;

  ArrayList<ArrayList<float[]>> faceRings = new ArrayList<ArrayList<float[]>>();
  ArrayList<Integer> faceMaterials = new ArrayList<Integer>();
  ArrayList<Integer> faceLayers = new ArrayList<Integer>();

  for (int f = 0; f < allFaces.nodes.length; f++) {
    if (allFaces.getVisibility(f) <= 0) continue;
    if (allFaces.nodes[f].length < 3) continue;

    ArrayList<float[]> ring = new ArrayList<float[]>();
    for (int i = 0; i < allFaces.nodes[f].length; i++) {
      ring.add(exportGeojsonPointToLonLatAlt(allFaces.nodes[f][i]));
    }
    // Shapefile outer rings are wound CLOCKWISE (negative signed area) -
    // the opposite of exportGeojson.pde's own counterclockwise
    // convention - see this file's own header comment, "Winding".
    if (exportGeojsonSignedRingArea(ring) > 0) {
      java.util.Collections.reverse(ring);
    }
    ring.add(ring.get(0)); // close the ring - this format's own convention, same as GeoJSON/KML/CityGML

    faceRings.add(ring);
    faceMaterials.add(allFaces.getMaterial(f));
    faceLayers.add(allFaces.getLayer(f));
  }

  exportShapefileWriteFileSet(ProjectName, 15 /* PolygonZ */, faceRings, faceMaterials, faceLayers);

  ArrayList<ArrayList<float[]>> lineStrings = new ArrayList<ArrayList<float[]>>();
  ArrayList<Integer> lineMaterials = new ArrayList<Integer>();
  ArrayList<Integer> lineLayers = new ArrayList<Integer>();

  for (int p = 0; p < allPolylines.nodes.length; p++) {
    if (allPolylines.getVisibility(p) <= 0) continue;
    if (allPolylines.nodes[p].length < 2) continue;

    ArrayList<float[]> pts = new ArrayList<float[]>();
    for (int node : allPolylines.nodes[p]) {
      pts.add(exportGeojsonPointToLonLatAlt(node));
    }
    if (allPolylines.getClose(p) == 1) {
      pts.add(pts.get(0));
    }

    lineStrings.add(pts);
    lineMaterials.add(allPolylines.getMaterial(p));
    lineLayers.add(allPolylines.getLayer(p));
  }

  if (lineStrings.size() > 0) {
    exportShapefileWriteFileSet(ProjectName + "_lines", 13 /* PolyLineZ */, lineStrings, lineMaterials, lineLayers);
  }

  println("\nFile created:" + Folder_Export3D + "/" + ProjectName + ".shp");

  isFileOperationInProgress = false;
}

// Writes one complete file set (.shp/.shx/.dbf/.prj) for one geometry
// type - `parts` is one [lon, lat, alt] ring/line per record, already
// closed/wound as needed by the caller (see exportShapefile()'s own two
// call sites, "Winding"/closing comments above).
void exportShapefileWriteFileSet (String baseName, int shapeType, ArrayList<ArrayList<float[]>> parts, ArrayList<Integer> materials, ArrayList<Integer> layers) {

  ArrayList<byte[]> recordBodies = new ArrayList<byte[]>();
  double xmin = Double.MAX_VALUE, ymin = Double.MAX_VALUE, zmin = Double.MAX_VALUE;
  double xmax = -Double.MAX_VALUE, ymax = -Double.MAX_VALUE, zmax = -Double.MAX_VALUE;

  for (ArrayList<float[]> points : parts) {
    recordBodies.add(shpBuildSinglePartBodyZ(shapeType, points));
    for (float[] p : points) {
      xmin = Math.min(xmin, p[0]); xmax = Math.max(xmax, p[0]);
      ymin = Math.min(ymin, p[1]); ymax = Math.max(ymax, p[1]);
      zmin = Math.min(zmin, p[2]); zmax = Math.max(zmax, p[2]);
    }
  }
  if (parts.size() == 0) { xmin = xmax = ymin = ymax = zmin = zmax = 0; } // empty file - header still needs a well-formed (if degenerate) bounding box

  double[] bbox8 = { xmin, ymin, xmax, ymax, zmin, zmax, 0, 0 }; // Mmin/Mmax: 0,0 - no M data is ever written, see this file's own header comment, "Z vs M"

  byte[] shpBytes = shpBuildMainFile(shapeType, bbox8, recordBodies);
  byte[] shxBytes = shpBuildIndexFile(shapeType, bbox8, recordBodies);
  byte[] dbfBytes = shpBuildDbf(materials, layers);

  saveBytes(Folder_Export3D + "/" + baseName + ".shp", shpBytes);
  saveBytes(Folder_Export3D + "/" + baseName + ".shx", shxBytes);
  saveBytes(Folder_Export3D + "/" + baseName + ".dbf", dbfBytes);
  saveStrings(Folder_Export3D + "/" + baseName + ".prj", new String[]{ exportShapefileWgs84Wkt() });
}

// shape_type(4, LE) + bbox(32: xmin,ymin,xmax,ymax, LE doubles) +
// numParts(4, LE)=1 + numPoints(4, LE)=N + parts[1]={0} (LE) +
// points[N]×(x,y LE doubles) + zRange(16: zmin,zmax LE doubles) +
// zValues[N] (LE doubles) - the one shared body shape a single-ring
// PolygonZ and a single-part PolyLineZ both have (see this file's own
// header comment on why one shared builder covers both record kinds) -
// no M range/array (see "Z vs M" above).
byte[] shpBuildSinglePartBodyZ (int shapeType, ArrayList<float[]> points) {
  int n = points.size();
  int size = 4 + 32 + 4 + 4 + 4 + 16 * n + 16 + 8 * n;
  byte[] b = new byte[size];
  int pos = 0;

  binWriteU32LE(b, pos, shapeType); pos += 4;

  double xmin = Double.MAX_VALUE, ymin = Double.MAX_VALUE;
  double xmax = -Double.MAX_VALUE, ymax = -Double.MAX_VALUE;
  double zmin = Double.MAX_VALUE, zmax = -Double.MAX_VALUE;
  for (float[] p : points) {
    xmin = Math.min(xmin, p[0]); xmax = Math.max(xmax, p[0]);
    ymin = Math.min(ymin, p[1]); ymax = Math.max(ymax, p[1]);
    zmin = Math.min(zmin, p[2]); zmax = Math.max(zmax, p[2]);
  }
  binWriteDoubleLE(b, pos, xmin); pos += 8;
  binWriteDoubleLE(b, pos, ymin); pos += 8;
  binWriteDoubleLE(b, pos, xmax); pos += 8;
  binWriteDoubleLE(b, pos, ymax); pos += 8;

  binWriteU32LE(b, pos, 1); pos += 4; // numParts
  binWriteU32LE(b, pos, n); pos += 4; // numPoints
  binWriteU32LE(b, pos, 0); pos += 4; // parts[0] - the one and only part starts at point index 0

  for (float[] p : points) {
    binWriteDoubleLE(b, pos, p[0]); pos += 8;
    binWriteDoubleLE(b, pos, p[1]); pos += 8;
  }

  binWriteDoubleLE(b, pos, zmin); pos += 8;
  binWriteDoubleLE(b, pos, zmax); pos += 8;
  for (float[] p : points) {
    binWriteDoubleLE(b, pos, p[2]); pos += 8;
  }

  return b;
}

// The 100-byte main/index file header both share - file_code(BE)=9994,
// 5 unused BE int32 zero fields, file_length(BE, 16-bit words),
// version(LE)=1000, shape_type(LE), bbox8 (4 ranges, LE doubles).
void shpWriteHeader (byte[] b, int shapeType, double[] bbox8, int fileLengthWords) {
  shpWriteInt32BE(b, 0, 9994);
  // offsets 4-23: five unused int32 fields - already zero, byte[] starts zeroed
  shpWriteInt32BE(b, 24, fileLengthWords);
  binWriteU32LE(b, 28, 1000); // version
  binWriteU32LE(b, 32, shapeType);
  for (int i = 0; i < 8; i++) {
    binWriteDoubleLE(b, 36 + i * 8, bbox8[i]);
  }
}

byte[] shpBuildMainFile (int shapeType, double[] bbox8, ArrayList<byte[]> recordBodies) {
  int totalBytes = 100;
  for (byte[] body : recordBodies) totalBytes += 8 + body.length;

  byte[] b = new byte[totalBytes];
  shpWriteHeader(b, shapeType, bbox8, totalBytes / 2);

  int pos = 100;
  for (int i = 0; i < recordBodies.size(); i++) {
    byte[] body = recordBodies.get(i);
    shpWriteInt32BE(b, pos, i + 1); // record_number, 1-based per the format's own convention
    shpWriteInt32BE(b, pos + 4, body.length / 2); // content_length, in 16-bit words
    System.arraycopy(body, 0, b, pos + 8, body.length);
    pos += 8 + body.length;
  }
  return b;
}

byte[] shpBuildIndexFile (int shapeType, double[] bbox8, ArrayList<byte[]> recordBodies) {
  int totalBytes = 100 + 8 * recordBodies.size();
  byte[] b = new byte[totalBytes];
  shpWriteHeader(b, shapeType, bbox8, totalBytes / 2);

  int shpPos = 100; // mirrors the running byte offset shpBuildMainFile() itself would be at
  int idxPos = 100;
  for (byte[] body : recordBodies) {
    shpWriteInt32BE(b, idxPos, shpPos / 2); // offset, in 16-bit words, to this record's own header
    shpWriteInt32BE(b, idxPos + 4, body.length / 2); // content_length, in 16-bit words
    shpPos += 8 + body.length;
    idxPos += 8;
  }
  return b;
}

void shpWriteInt32BE (byte[] b, int off, int v) {
  b[off] = (byte) ((v >> 24) & 0xFF);
  b[off + 1] = (byte) ((v >> 16) & 0xFF);
  b[off + 2] = (byte) ((v >> 8) & 0xFF);
  b[off + 3] = (byte) (v & 0xFF);
}

// One "material"/"layer" Numeric('N') field each, width 10 - see this
// file's own header comment, "Sidecar files". Field values are kept as
// plain integers (never read as anything but a trimmed String by
// shpReadDbfProperties() on the way back in - see that function's own
// comment), right-justified and space-padded, the conventional dBASE
// Numeric field layout.
byte[] shpBuildDbf (ArrayList<Integer> materials, ArrayList<Integer> layers) {
  int fieldWidth = 10;
  String[] fieldNames = { "material", "layer" };
  int numRecords = materials.size();
  int headerLen = 32 + 32 * fieldNames.length + 1;
  int recordLen = 1 + fieldWidth * fieldNames.length; // 1: deletion-flag byte

  byte[] b = new byte[headerLen + recordLen * numRecords];

  b[0] = 0x03; // version: FoxBase+/dBASE III plus, no memo - the conventional marker, never interpreted by this app's own reader either way
  b[1] = (byte) 124; // last_update_y/m/d - informational only, never read by shpReadDbfProperties()
  b[2] = 1;
  b[3] = 1;
  binWriteU32LE(b, 4, numRecords);
  binWriteU16LE(b, 8, headerLen);
  binWriteU16LE(b, 10, recordLen);
  // offsets 12-31: reserved - already zero

  int pos = 32;
  for (String name : fieldNames) {
    byte[] nameBytes = name.getBytes(java.nio.charset.StandardCharsets.US_ASCII);
    System.arraycopy(nameBytes, 0, b, pos, Math.min(nameBytes.length, 11));
    b[pos + 11] = 'N';
    // offsets 12-15 (data_address): unused, already zero
    b[pos + 16] = (byte) fieldWidth;
    b[pos + 17] = 0; // decimal_count
    // offsets 18-31: reserved, already zero
    pos += 32;
  }
  b[pos] = 0x0D; // field descriptor terminator
  pos = headerLen;

  for (int r = 0; r < numRecords; r++) {
    b[pos] = 0x20; // deletion flag: not deleted
    pos += 1;
    pos = shpWriteDbfNumericField(b, pos, fieldWidth, materials.get(r));
    pos = shpWriteDbfNumericField(b, pos, fieldWidth, layers.get(r));
  }

  return b;
}

int shpWriteDbfNumericField (byte[] b, int pos, int fieldWidth, int value) {
  String text = str(value);
  for (int i = 0; i < fieldWidth; i++) b[pos + i] = ' ';
  int start = pos + Math.max(0, fieldWidth - text.length());
  byte[] textBytes = text.getBytes(java.nio.charset.StandardCharsets.US_ASCII);
  System.arraycopy(textBytes, 0, b, start, Math.min(textBytes.length, fieldWidth));
  return pos + fieldWidth;
}

// A plain WGS84 GEOGCS WKT string - see this file's own header comment,
// "Sidecar files": shpDetectLonLatFromPrj() (importShapefile.pde) only
// ever checks that the trimmed text's first keyword case-insensitively
// matches "GEOGCS", which this satisfies.
String exportShapefileWgs84Wkt () {
  return "GEOGCS[\"GCS_WGS_1984\",DATUM[\"D_WGS_1984\",SPHEROID[\"WGS_1984\",6378137.0,298.257223563]],PRIMEM[\"Greenwich\",0.0],UNIT[\"Degree\",0.0174532925199433]]";
}
