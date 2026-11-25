// Minimal, dependency-free importer for a GeoJSON (RFC 7946) file - the
// same "hand-roll the parser, no external library" choice importObj.pde/
// importDxf.pde/importIfc.pde/importGlb.pde/importStl.pde/importPly.pde/
// importDae.pde/importGbxml.pde already make for their own formats.
// GeoJSON is plain JSON, so Processing's own built-in JSONObject/
// JSONArray (already used elsewhere in this app - land3D.pde's own
// elevation-API call and texture-overlay metadata, importGlb.pde's own
// glTF JSON chunk) read it with no new dependency at all.
//
// Every coordinate GeoJSON carries is [longitude, latitude(, altitude)]
// (RFC 7946 section 3.1.1) - there is no separate up-axis question the
// way OBJ/GLB/STL/DXF/PLY/DAE each have (importSwapAxisYZ, fileSelected.
// pde): longitude/latitude are always horizontal and altitude (when
// present) is always vertical, matching this app's own Z-up convention
// directly, so this importer offers no axis-swap option at all.
//
// Every coordinate is projected into this app's own local XY meters
// around the PROJECT's own site location (locationLatitude/
// locationLongitude, globalVariables.pde - the same lat/lon this app
// already uses for its weather station and sun position) via Functions.
// convert_lonlat2XY() (functions.pde) - the same simple equirectangular
// local-meters convention land3D.pde's own texture/station placement
// already uses, not a true geodetic projection (UTM or otherwise) - good
// enough at the building/site scale these imports are meant for, and
// consistent with the rest of this app rather than introducing a second,
// competing notion of "local meters."
//
// v1 scope - every geometry type RFC 7946 defines:
//   - Point/MultiPoint -> a bare vertex (allPoints.create()) per point -
//     this app has no dedicated standalone-point/marker object (neither
//     does OBJ/PLY/DXF import), the same "just the vertex, referenced by
//     nothing else" treatment importLas.pde's own un-meshed point cloud
//     already falls back to when meshing is off or fails.
//   - LineString/MultiLineString -> one open (or, if the file's own
//     coordinates already close the loop, closed) Polyline (polylines.
//     pde) per line - unlike OBJ's "l"/DXF's LINE/DXF's curves (each
//     gated behind an off-by-default toggle, since those formats treat
//     lines as optional drafting geometry), GeoJSON's LineString is
//     primary, first-class geometry, so it's always imported, no toggle.
//   - Polygon/MultiPolygon -> one flat n-gon Face per polygon (its first
//     ring is the outer boundary, every ring after it a hole, merged
//     into one single bridged "keyhole" boundary loop via PolygonHoles.
//     mergeHolesIntoOuterLoop() - the same technique importIfc.pde's own
//     ifcEmitFace() already uses for an IfcFace with voids, rather than
//     actually triangulating the hole away) - or, when geojsonHeight
//     Property names a Feature property this polygon's own feature
//     actually carries a positive numeric value for, an extruded solid
//     instead (see geojsonEmitExtrudedSolid()'s own comment). This
//     mirrors, in-app, what the external OSM/Overture import scripts
//     (../import/'s own solarch_3d_common.py/lib/geometry.js) already do
//     for OSM/Overture GeoJSON specifically, but works for ANY GeoJSON
//     source carrying a numeric height-like property, not just those two.
//   - GeometryCollection -> every geometry inside it, recursively, same
//     treatment as a bare top-level geometry of that type, with the
//     enclosing Feature's own properties still applying to each one.
// A Feature's own "geometry" may be null (RFC 7946 allows this, for a
// Feature that intentionally carries no geometry) - skipped, not an
// error. An unrecognized/missing "type" anywhere is skipped the same
// way DXF/IFC/PLY silently skip an entity/element type they don't
// handle, with a running skipped-count/reasons map the same shape
// ifcImportSkippedCount/ifcImportSkippedReasons (importIfc.pde) and
// gbxmlImportSkippedCount/gbxmlImportSkippedReasons (importGbxml.pde)
// already use.
//
// The root GeoJSON object itself may be a FeatureCollection, a bare
// Feature, or (RFC 7946 section 3) a bare Geometry object directly -
// all three are handled; a bare Geometry has no "properties" of its own,
// so geojsonHeightProperty/geojsonGroupProperty never apply to one.

boolean geojsonImportShowOptionsDialog = false;

// Feature "properties" key to read as an extrusion height (meters,
// before this import's own sz scale) for a Polygon/MultiPolygon - blank
// (the default) means every polygon stays a flat face, the same
// conservative "don't invent height data the file doesn't actually
// carry" stance DXF/gbXML's in-app importers already take. The external
// OSM/Overture scripts (../import/) do real height-tag-driven extrusion
// too, but outside the app and only for those two specific sources -
// this is the same idea, in-app, for ANY GeoJSON source that happens to
// carry a numeric height-like property, under whatever name its own
// author gave it. A missing property, or one that isn't a positive
// number, leaves that one polygon flat rather than failing the import -
// see geojsonResolveHeight()'s own comment.
String geojsonHeightProperty = "";

// Feature "properties" key used to decide when to start a new group and
// cycle material - the GeoJSON-native equivalent of DXF's own per-entity
// "layer" (group code 8). Blank (the default) means the whole file stays
// one single group, the same default every other format with no native
// sub-object boundary of its own (PLY, binary STL) already falls back to.
String geojsonGroupProperty = "";

// Running per-import state - same shape dxfCycleMaterial/dxfCurrentLayer
// (importDxf.pde) already use for their own format's identical "cycle
// material/start a new group when this changes" logic, just keyed by a
// Feature property's own value instead of a DXF layer name.
boolean geojsonCycleMaterial;
String geojsonCurrentGroupKey = null;

int geojsonPointsImported = 0;
int geojsonLinesImported = 0;
int geojsonFlatFacesImported = 0;
int geojsonSolidsImported = 0;

// Same shape as gbxmlImportSkippedCount/gbxmlImportSkippedReasons
// (importGbxml.pde) - every geometry this importer intentionally leaves
// out (a null/empty/unrecognized geometry, a degenerate ring, ...) adds
// one line to this map instead of silently vanishing with no trace in
// the end-of-import summary.
int geojsonImportSkippedCount = 0;
HashMap<String, Integer> geojsonImportSkippedReasons = new HashMap<String, Integer>();

void geojsonNoteSkipped (String reason) {
  geojsonImportSkippedCount++;
  Integer prior = geojsonImportSkippedReasons.get(reason);
  geojsonImportSkippedReasons.put(reason, (prior == null ? 0 : prior) + 1);
}

void import_objects_GEOJSON (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  // Same shape as import_objects_OBJ()'s/import_objects_DXF()'s own
  // identical blocks - see either one's own comment for why this sits
  // here rather than earlier, and what a cancelled dialog does.
  if (geojsonImportShowOptionsDialog) {
    geojsonImportShowOptionsDialog = false;
    if (!geojsonShowImportOptionsDialog()) return;
  }

  println("\nImporting GeoJSON. Please wait...");
  showWaitCursor();
  isImportingInProgress = true; // see this flag's own comment (globalFunctions.pde) for why - bare statement (this function has only the one exit point below, so nothing further to guard); cleared alongside showArrowCursor() at every exit

  geojsonCycleMaterial = (m == -1);
  if (m == -1) current_Material = 0;
  else current_Material = m;

  current_Tessellation = tes;
  current_Layer = lyr;
  current_Visibility = vsb;
  current_Weight = wgt;
  current_Closed = clz;

  geojsonCurrentGroupKey = null;
  geojsonPointsImported = 0;
  geojsonLinesImported = 0;
  geojsonFlatFacesImported = 0;
  geojsonSolidsImported = 0;
  geojsonImportSkippedCount = 0;
  geojsonImportSkippedReasons = new HashMap<String, Integer>();

  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  // loadJSONObject() itself only returns null for an I/O problem (file
  // missing/unreadable) - a syntax error in the JSON text itself (an
  // unterminated string, a missing colon, ...) throws straight out of its
  // own JSON parser instead of being caught and turned into a null
  // return, unlike this importer's every other "malformed input" case
  // (geojsonCoordsArrayToPVectors()'s own comment) - caught here so one
  // malformed file behaves the same "skip it, don't crash the whole
  // import" way as any other bad input this importer already tolerates.
  JSONObject root = null;
  try {
    root = loadJSONObject(FileName);
  }
  catch (Exception e) {
    root = null;
  }
  if (root == null) {
    println("\nGeoJSON import: could not read or parse " + FileName);
    isImportingInProgress = false;
    showArrowCursor();
    return;
  }

  String rootType = root.hasKey("type") ? root.getString("type") : "";

  progressBarHeader();
  float printed_Progress = 0;
  boolean aborted = false;

  if (rootType.equals("FeatureCollection")) {
    JSONArray features = root.hasKey("features") ? root.getJSONArray("features") : null;
    int totalFeatures = (features == null) ? 0 : features.size();
    float totalFeaturesF = max(1, totalFeatures); // avoid /0 below for an empty collection

    ProgressWindow importProgressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("\nImporting GeoJSON") : null;
    if (importProgressWindow != null) importProgressWindow.setVisible(true);

    try {
      for (int f = 0; f < totalFeatures; f++) {
        // Esc, caught by importProgressWindow's own Toolkit-level
        // listener (progressWindow.pde) regardless of which window has
        // focus - same as import_objects_OBJ()'s identical check. No
        // rollback on abort - whatever points/faces/polylines were
        // already created from the features read so far are kept, same
        // as any other partial import.
        if ((importProgressWindow != null) && importProgressWindow.abortRequested) {
          echoAbortProgress();
          aborted = true;
          break;
        }

        if (control != USER_AUTO) {
          float Progress = 100 * f / totalFeaturesF;
          int delta = (int) floor(Progress - printed_Progress);
          if (delta >= 1) {
            printProgressBarChunk(delta); // one print() call instead of `delta` calls
            printed_Progress = floor(Progress);
            if (importProgressWindow != null) importProgressWindow.updateFraction(Progress / 100.0f);
          }
        }

        JSONObject feature = features.getJSONObject(f);
        if (feature == null) { geojsonNoteSkipped("null entry in \"features\""); continue; }
        geojsonHandleFeature(feature, clz, cx, cy, cz, sx, sy, sz);
      }
    } finally {
      if (importProgressWindow != null) importProgressWindow.dispose();
    }
  } else if (rootType.equals("Feature")) {
    geojsonHandleFeature(root, clz, cx, cy, cz, sx, sy, sz);
  } else if (rootType.equals("Point") || rootType.equals("MultiPoint") || rootType.equals("LineString")
      || rootType.equals("MultiLineString") || rootType.equals("Polygon") || rootType.equals("MultiPolygon")
      || rootType.equals("GeometryCollection")) {
    // A bare top-level Geometry (RFC 7946 section 3 allows this, not
    // just Feature/FeatureCollection) - there's no "properties" at this
    // level, so geojsonHeightProperty/geojsonGroupProperty never apply
    // here; null is passed through exactly like a Feature whose own
    // "properties" is itself null/absent already would.
    geojsonHandleGeometry(root, null, clz, cx, cy, cz, sx, sy, sz);
  } else {
    println("\nGeoJSON import: no recognizable top-level \"type\" (expected FeatureCollection/Feature/a bare Geometry) in " + FileName);
    geojsonNoteSkipped(rootType.length() == 0 ? "root object with no \"type\"" : ("unrecognized root \"type\": " + rootType));
  }

  if (!aborted) {
    int remaining = (int) floor(100 - printed_Progress);
    printProgressBarChunk(remaining);
    println();

    String summary = "GeoJSON import complete: " + geojsonPointsImported + " point(s), " + geojsonLinesImported + " line(s), " + geojsonFlatFacesImported + " flat face(s), " + geojsonSolidsImported + " extruded solid(s) imported";
    if (geojsonImportSkippedCount > 0) summary += ", " + geojsonImportSkippedCount + " unsupported/malformed item(s) skipped";
    summary += ".";
    println();
    println(summary);
  }

  isImportingInProgress = false;
  showArrowCursor();
}

// hasKey(key) alone is true for an explicit JSON null value too (the key
// IS present, its value just happens to be null) - getJSONObject() then
// throws, since the stored value isn't actually a JSONObject. A GeoJSON
// Feature's own "geometry"/"properties" are both explicitly allowed to be
// null (RFC 7946 section 3.2), so every JSONObject-valued read in this
// file goes through this helper instead of a bare hasKey() guard.
JSONObject geojsonGetObjectOrNull (JSONObject obj, String key) {
  if (obj == null || !obj.hasKey(key) || obj.isNull(key)) return null;
  return obj.getJSONObject(key);
}

// One Feature: applies this import's own grouping option (if any) off
// its own "properties", then hands its own "geometry" (may be null/
// absent - a Feature is allowed to carry none) to geojsonHandleGeometry().
void geojsonHandleFeature (JSONObject feature, int clzParam, float cx, float cy, float cz, float sx, float sy, float sz) {
  JSONObject properties = geojsonGetObjectOrNull(feature, "properties");
  geojsonApplyGrouping(properties);

  JSONObject geometry = geojsonGetObjectOrNull(feature, "geometry");
  geojsonHandleGeometry(geometry, properties, clzParam, cx, cy, cz, sx, sy, sz);
}

// Starts a new group/cycles material exactly when this Feature's own
// grouping-key value (geojsonGroupProperty read off `properties`, or
// null when that option is blank or this Feature doesn't carry it)
// differs from the PREVIOUS Feature's - same "repetition/change, not a
// per-call flag, decides it" shape dxfHandleEntity()'s own layer-change
// check (importDxf.pde) already uses, just keyed by a Feature property's
// value instead of a DXF layer name. A null-vs-null comparison (grouping
// off, or no Features have carried the key yet) never counts as a
// change, so leaving geojsonGroupProperty blank costs nothing - the
// whole file stays one single group, same as today.
void geojsonApplyGrouping (JSONObject properties) {
  String key = null;
  if (geojsonGroupProperty != null && geojsonGroupProperty.length() > 0 && properties != null && properties.hasKey(geojsonGroupProperty)) {
    key = properties.getString(geojsonGroupProperty);
  }

  boolean changed = (key == null) ? (geojsonCurrentGroupKey != null) : !key.equals(geojsonCurrentGroupKey);
  if (changed) {
    geojsonCurrentGroupKey = key;
    if (geojsonCycleMaterial) current_Material = 1 + (current_Material % 8); // same "g" tag/DXF-layer cycling importObj.pde's/importDxf.pde's own already use
    if (addToLastGroup == false) allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
  }
}

// Dispatches one GeoJSON Geometry object by its own "type" - called both
// for a Feature's own top-level geometry and, recursively, for every
// geometry inside a GeometryCollection (the enclosing Feature's own
// `properties` still applies to each one it contains).
void geojsonHandleGeometry (JSONObject geometry, JSONObject properties, int clzParam, float cx, float cy, float cz, float sx, float sy, float sz) {
  if (geometry == null) { geojsonNoteSkipped("Feature with no geometry"); return; }
  String type = geometry.hasKey("type") ? geometry.getString("type") : "";

  if (type.equals("Point")) {
    JSONArray coord = geometry.hasKey("coordinates") ? geometry.getJSONArray("coordinates") : null;
    geojsonHandlePoint(coord, cx, cy, cz, sx, sy, sz);
  } else if (type.equals("MultiPoint")) {
    JSONArray coords = geometry.hasKey("coordinates") ? geometry.getJSONArray("coordinates") : null;
    if (coords == null) { geojsonNoteSkipped("MultiPoint with no coordinates"); return; }
    for (int i = 0; i < coords.size(); i++) geojsonHandlePoint(coords.getJSONArray(i), cx, cy, cz, sx, sy, sz);
  } else if (type.equals("LineString")) {
    JSONArray coords = geometry.hasKey("coordinates") ? geometry.getJSONArray("coordinates") : null;
    geojsonHandleLineString(coords, clzParam, cx, cy, cz, sx, sy, sz);
  } else if (type.equals("MultiLineString")) {
    JSONArray lines = geometry.hasKey("coordinates") ? geometry.getJSONArray("coordinates") : null;
    if (lines == null) { geojsonNoteSkipped("MultiLineString with no coordinates"); return; }
    for (int i = 0; i < lines.size(); i++) geojsonHandleLineString(lines.getJSONArray(i), clzParam, cx, cy, cz, sx, sy, sz);
  } else if (type.equals("Polygon")) {
    JSONArray rings = geometry.hasKey("coordinates") ? geometry.getJSONArray("coordinates") : null;
    geojsonHandlePolygonRings(rings, properties, cx, cy, cz, sx, sy, sz);
  } else if (type.equals("MultiPolygon")) {
    JSONArray polys = geometry.hasKey("coordinates") ? geometry.getJSONArray("coordinates") : null;
    if (polys == null) { geojsonNoteSkipped("MultiPolygon with no coordinates"); return; }
    for (int i = 0; i < polys.size(); i++) geojsonHandlePolygonRings(polys.getJSONArray(i), properties, cx, cy, cz, sx, sy, sz);
  } else if (type.equals("GeometryCollection")) {
    JSONArray geometries = geometry.hasKey("geometries") ? geometry.getJSONArray("geometries") : null;
    if (geometries == null) { geojsonNoteSkipped("GeometryCollection with no geometries"); return; }
    for (int i = 0; i < geometries.size(); i++) geojsonHandleGeometry(geometries.getJSONObject(i), properties, clzParam, cx, cy, cz, sx, sy, sz);
  } else {
    geojsonNoteSkipped(type.length() == 0 ? "geometry with no \"type\"" : ("unrecognized geometry type: " + type));
  }
}

// One Point/MultiPoint member - a bare vertex, nothing else; see this
// file's own header comment for why.
void geojsonHandlePoint (JSONArray coord, float cx, float cy, float cz, float sx, float sy, float sz) {
  if (coord == null || coord.size() < 2) { geojsonNoteSkipped("Point with fewer than 2 coordinate values"); return; }
  float[] xyz = geojsonCoordToXYZ(coord, cx, cy, cz, sx, sy, sz);
  allPoints.create(xyz[0], xyz[1], xyz[2]);
  geojsonPointsImported++;
}

// One LineString/MultiLineString member, as an open (or, if the file's
// own coordinates already loop back to their own start, closed)
// Polyline - the file's own repetition, not this import's own clz
// parameter, decides closedness for THIS one line, the same auto-detect
// convention importObj.pde's own objHandleLine()/importDxf.pde's own
// dxfEmitPolyline() already use for their own formats' line geometry;
// clzParam only applies when the file itself leaves it open.
void geojsonHandleLineString (JSONArray coordsArray, int clzParam, float cx, float cy, float cz, float sx, float sy, float sz) {
  ArrayList<PVector> pts = geojsonCoordsArrayToPVectors(coordsArray, cx, cy, cz, sx, sy, sz);
  boolean closed = geojsonStripClosingDuplicate(pts);
  if (pts.size() < 2) { geojsonNoteSkipped("LineString with fewer than 2 distinct points"); return; }

  float[][] points = new float[pts.size()][3];
  for (int i = 0; i < pts.size(); i++) {
    PVector p = pts.get(i);
    points[i] = new float[]{p.x, p.y, p.z};
  }

  allPolylines.add_Polyline(current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, closed ? 1 : clzParam, points);
  geojsonLinesImported++;
}

// One Polygon/MultiPolygon member - `rings` is one Polygon's own
// "coordinates": its first ring is the outer boundary, every ring after
// it a hole (RFC 7946 section 3.1.6). Holes are bridged into the outer
// boundary as one single loop via PolygonHoles.mergeHolesIntoOuterLoop()
// (the same technique importIfc.pde's own ifcEmitFace() already uses for
// an IfcFace with voids) rather than triangulated away, so a hole-free
// polygon and one with a courtyard both end up as exactly one face/solid
// either way - never split into triangles.
void geojsonHandlePolygonRings (JSONArray rings, JSONObject properties, float cx, float cy, float cz, float sx, float sy, float sz) {
  if (rings == null || rings.size() == 0) { geojsonNoteSkipped("Polygon with no rings"); return; }

  ArrayList<PVector> outer = geojsonCoordsArrayToPVectors(rings.getJSONArray(0), cx, cy, cz, sx, sy, sz);
  geojsonStripClosingDuplicate(outer); // a Polygon ring is always closed by definition (RFC 7946 3.1.6) - stripped unconditionally, unlike a LineString's own optional closing duplicate
  if (outer.size() < 3) { geojsonNoteSkipped("degenerate polygon ring (fewer than 3 distinct points)"); return; }

  ArrayList<ArrayList<PVector>> holes = new ArrayList<ArrayList<PVector>>();
  for (int i = 1; i < rings.size(); i++) {
    ArrayList<PVector> hole = geojsonCoordsArrayToPVectors(rings.getJSONArray(i), cx, cy, cz, sx, sy, sz);
    geojsonStripClosingDuplicate(hole);
    if (hole.size() >= 3) holes.add(hole);
  }

  ArrayList<PVector> ring = (holes.size() > 0) ? PolygonHoles.mergeHolesIntoOuterLoop(outer, holes) : outer;

  Float heightValue = geojsonResolveHeight(properties);
  if (heightValue != null && heightValue > 0) {
    geojsonEmitExtrudedSolid(ring, heightValue, sz);
    geojsonSolidsImported++;
  } else {
    geojsonEmitFlatFace(ring);
    geojsonFlatFacesImported++;
  }
}

// Converts one GeoJSON coordinate-array - "coordinates" for a
// LineString/MultiPoint, or one ring of a Polygon; every one of these is
// just a JSONArray of [lon, lat(, alt)] coordinate arrays - into this
// app's own local XYZ points, in file order. No closing-duplicate
// handling here; see geojsonStripClosingDuplicate() for that, applied
// separately by whichever caller needs it.
ArrayList<PVector> geojsonCoordsArrayToPVectors (JSONArray coordsArray, float cx, float cy, float cz, float sx, float sy, float sz) {
  ArrayList<PVector> pts = new ArrayList<PVector>();
  if (coordsArray == null) return pts;
  for (int i = 0; i < coordsArray.size(); i++) {
    JSONArray coord = coordsArray.getJSONArray(i);
    if (coord == null || coord.size() < 2) continue; // malformed coordinate - skip it rather than throw, same tolerance plySizeOf()'s own -1-for-unrecognized return (importPly.pde) already uses elsewhere in this codebase
    float[] xyz = geojsonCoordToXYZ(coord, cx, cy, cz, sx, sy, sz);
    pts.add(new PVector(xyz[0], xyz[1], xyz[2]));
  }
  return pts;
}

// Detects and removes a trailing point that duplicates the first one
// (within funcs.EPSILON_POSITION) - true for every GeoJSON Polygon ring
// by definition (RFC 7946 section 3.1.6: "the first and last positions
// are equivalent"), and OPTIONALLY true for a LineString that happens to
// close its own loop - the same "repetition, not a separate flag, is
// what decides it" auto-detect convention importObj.pde's own
// objHandleLine()/importDxf.pde's own dxfEmitPolyline() already use for
// their own formats' own line/polyface geometry. Returns whether it
// actually found (and removed) a closing duplicate.
boolean geojsonStripClosingDuplicate (ArrayList<PVector> pts) {
  if (pts.size() < 3) return false; // need at least a real triangle/segment-pair left afterward to call this "closed"
  if (PVector.dist(pts.get(0), pts.get(pts.size() - 1)) >= funcs.EPSILON_POSITION) return false;
  pts.remove(pts.size() - 1);
  return true;
}

// Reads a Feature's own "properties" for geojsonHeightProperty's current
// value, as a float - null whenever extrusion doesn't apply: the option
// is blank, this Feature doesn't carry that property at all, or its
// value can't be read as a number either directly (JSONObject.getFloat())
// or, failing that, parsed from its own string form - the same "a bad
// value quietly falls back rather than crashing" tolerance this whole
// importer already follows (geojsonCoordsArrayToPVectors()'s own
// comment). A non-positive value is treated the same way by this file's
// one caller (geojsonHandlePolygonRings()) - never an extrusion to a
// zero/negative height, just a flat face instead.
Float geojsonResolveHeight (JSONObject properties) {
  if (geojsonHeightProperty == null || geojsonHeightProperty.length() == 0) return null;
  if (properties == null || !properties.hasKey(geojsonHeightProperty)) return null;
  try {
    return properties.getFloat(geojsonHeightProperty);
  }
  catch (Exception e) {
    try {
      return Float.parseFloat(properties.getString(geojsonHeightProperty).trim());
    }
    catch (Exception e2) {
      return null;
    }
  }
}

// One [lon, lat(, alt)] coordinate -> this app's own local (x, y, z)
// meters: lon/lat through Functions.convert_lonlat2XY() around the
// project's own site location (locationLatitude/locationLongitude - see
// this file's own header comment), alt (0 when absent, same as every
// other coordinate this importer reads) straight into z - then this
// import's own cx/cy/cz offset and sx/sy/sz scale, the same convention
// every other importer's own import_objects_*() signature already
// applies to every point it creates.
float[] geojsonCoordToXYZ (JSONArray coord, float cx, float cy, float cz, float sx, float sy, float sz) {
  float lon = coord.getFloat(0);
  float lat = coord.getFloat(1);
  float alt = (coord.size() > 2) ? coord.getFloat(2) : 0;
  float[] XY = funcs.convert_lonlat2XY(locationLongitude, locationLatitude, lon, lat);
  return new float[]{ cx + sx * XY[0], cy + sy * XY[1], cz + sz * alt };
}

// One hole-free (or already hole-bridged) ring -> one flat n-gon Face,
// exactly as given - never triangulated, same "the file's own n-gon,
// don't triangulate" choice importGbxml.pde's/importIfc.pde's own flat
// faces already make.
boolean geojsonEmitFlatFace (ArrayList<PVector> ring) {
  if (ring.size() < 3) return false;
  int[] nodes = new int[ring.size()];
  for (int i = 0; i < ring.size(); i++) {
    PVector p = ring.get(i);
    nodes[i] = allPoints.create(p.x, p.y, p.z);
  }
  allFaces.create(nodes);
  return true;
}

// The same ring, walled and capped into a closed solid from its own
// current z (the base - already this import's own cz offset, applied
// uniformly to every point of this ring by geojsonCoordToXYZ() above) up
// to that same z plus `height` (scaled by this import's own sz, the same
// way every other z-ish value this importer produces already is).
//
// Bottom cap: reversed winding, so its own outward normal points down.
// Top cap: natural winding, faces up. Walls: one quad per edge, corners
// (b0, b1, t1, t0). This is exactly the convention ../import/'s own
// lib/geometry.js (addExtrudedMesh(), its own buildings.svs writer)/
// solarch_3d_common.py already use for the external OSM/Overture import
// scripts' own extruded buildings - one n-gon face per cap (never
// triangulated; `ring` was already bridged through any holes by
// PolygonHoles.mergeHolesIntoOuterLoop() before this is ever called, the
// same way those scripts' own triangulateFootprint() is only reached
// when a cap actually has holes to begin with), one plain quad per wall.
boolean geojsonEmitExtrudedSolid (ArrayList<PVector> ring, float height, float sz) {
  int n = ring.size();
  if (n < 3) return false;

  int[] bottomNodes = new int[n];
  int[] topNodes = new int[n];
  for (int i = 0; i < n; i++) {
    PVector p = ring.get(i);
    float topZ = p.z + sz * height;
    bottomNodes[i] = allPoints.create(p.x, p.y, p.z);
    topNodes[i] = allPoints.create(p.x, p.y, topZ);
  }

  int[] bottomFace = new int[n];
  for (int i = 0; i < n; i++) bottomFace[i] = bottomNodes[n - 1 - i];
  allFaces.create(bottomFace);

  allFaces.create(topNodes);

  for (int i = 0; i < n; i++) {
    int j = (i + 1) % n;
    allFaces.create(new int[]{bottomNodes[i], bottomNodes[j], topNodes[j], topNodes[i]});
  }

  return true;
}
