// Minimal, dependency-free importer for a TopoJSON file (https://github.com/
// topojson/topojson-specification) - built directly on top of importGeojson.
// pde's own shared core (geojsonEmitPointFromXYZ()/
// geojsonEmitLineStringFromPoints()/geojsonEmitPolygonFromRings()/
// geojsonLonLatAltToXYZ(), plus geojsonHeightProperty/geojsonGroupProperty/
// geojsonApplyGrouping()/geojsonResolveHeight()/geojsonStripClosingDuplicate()
// /geojsonGetObjectOrNull()/geojsonNoteSkipped() and this same import's own
// running point/line/face/solid/skipped counters - every one of those is
// reused exactly as GeoJSON import already uses it, not duplicated), per the
// build order agreed before Phase 1 (GeoJSON) started: "GeoJSON, then
// TopoJSON, then KML."
//
// What TopoJSON adds over plain GeoJSON is topology: instead of every
// LineString/Polygon ring carrying its own full [lon,lat] coordinate list,
// a TopoJSON file's own "arcs" array holds each distinct line segment once,
// and every LineString/Polygon references the arcs it's built from by
// index - the same segment shared by two neighboring polygons (a shared
// parcel boundary, a shared coastline) is stored, and read, only once. A
// TopoJSON file's own "objects" are also usually quantized: every arc
// position (after its own first) is stored as a delta from the previous
// position in that SAME arc, as integers, decoded back to real lon/lat via
// the file's own "transform" (scale + translate) - topojsonDecodeArc()'s
// own comment below has the exact accumulate-then-scale-then-translate
// steps. A file with no "transform" at all simply isn't quantized - its
// arc/Point coordinates are already plain, final lon/lat/alt numbers, no
// decoding needed.
//
// v1 scope - every TopoJSON geometry type the spec defines, each handled
// the same way its own GeoJSON equivalent already is (importGeojson.pde's
// own header comment goes through each one), with one difference: a
// TopoJSON LineString/MultiLineString/Polygon/MultiPolygon's own geometry
// comes from resolving one or more "arcs" (by index, each index possibly
// negative to mean "this arc, reversed" - topojsonResolveArcIndexes()'s own
// comment) rather than a GeoJSON "coordinates" array directly; Point/
// MultiPoint still carry "coordinates" directly, exactly as GeoJSON does
// (per the spec, point geometries are never built from arcs) - these are
// independently dequantized (no delta-encoding between one point and the
// next, unlike an arc's own points - topojsonHandlePoint()'s own comment).
//
// A TopoJSON geometry object (whether a top-level entry under "objects" or
// one nested inside a "GeometryCollection") may carry its own "properties"
// member directly, the same meaning as a GeoJSON Feature's "properties" -
// there's no separate Feature wrapper in TopoJSON. This import applies
// geojsonGroupProperty's own grouping decision once per TOP-LEVEL named
// object (mirroring GeoJSON's own once-per-Feature granularity - a
// GeometryCollection's own nested geometries share their enclosing object's
// "properties" for this, exactly as importGeojson.pde's own
// geojsonHandleGeometry() GeometryCollection branch already does, rather
// than re-deriving a grouping key per nested geometry).
//
// An unrecognized/missing root "type" (expected "Topology"), an
// unrecognized/missing geometry "type", a null/non-object entry in
// "objects", or an out-of-range arc index are all skipped the same way
// importGeojson.pde's own malformed-input cases already are, via this
// same shared geojsonNoteSkipped()/geojsonImportSkippedReasons running
// tally.

boolean topojsonImportShowOptionsDialog = false;

// This import's own quantization state, reset at the start of every
// import_objects_TOPOJSON() call from the file's own (optional)
// "transform" member - see topojsonDecodeArc()'s own comment for how
// these are actually applied. topojsonScale/topojsonTranslate may each
// carry more than 2 dimensions (the spec allows it, though 2 - lon/lat
// only - is by far the common case); a dimension beyond what either array
// provides is passed through unscaled/untranslated, same tolerance this
// whole importer already follows for anything the file doesn't actually
// carry.
boolean topojsonHasTransform = false;
double[] topojsonScale = new double[]{1, 1};
double[] topojsonTranslate = new double[]{0, 0};

// This import's own decoded arcs - each arc a list of already-dequantized
// {lon, lat, alt} triples (alt is 0 when an arc's own positions carry only
// 2 dimensions), reset and filled once per import_objects_TOPOJSON() call
// by topojsonDecodeArcs() before any "objects" are read, since every
// geometry a TopoJSON file carries may reference any of them by index.
ArrayList<ArrayList<float[]>> topojsonArcs = new ArrayList<ArrayList<float[]>>();

void import_objects_TOPOJSON (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  // Same shape as import_objects_GEOJSON()'s own identical block - see
  // that one's own comment for why this sits here rather than earlier,
  // and what a cancelled dialog does. The dialog itself (geojsonShowImport
  // OptionsDialog(), fileSelected.pde) is shared as-is with GeoJSON import
  // - same two "properties" key options, same meaning, either format.
  if (topojsonImportShowOptionsDialog) {
    topojsonImportShowOptionsDialog = false;
    if (!geojsonShowImportOptionsDialog()) return;
  }

  println("\nImporting TopoJSON. Please wait...");
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
  // as-is (this file's own header comment) rather than kept separately per
  // format - GeoJSON and TopoJSON import never run concurrently with each
  // other, so sharing costs nothing and keeps one single end-of-import
  // summary shape for both.
  geojsonCurrentGroupKey = null;
  geojsonPointsImported = 0;
  geojsonLinesImported = 0;
  geojsonFlatFacesImported = 0;
  geojsonSolidsImported = 0;
  geojsonImportSkippedCount = 0;
  geojsonImportSkippedReasons = new HashMap<String, Integer>();

  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  // See import_objects_GEOJSON()'s own identical try/catch for why a
  // parse-error exception (not just a null return) must be caught here.
  JSONObject root = null;
  try {
    root = loadJSONObject(FileName);
  }
  catch (Exception e) {
    root = null;
  }
  if (root == null) {
    println("\nTopoJSON import: could not read or parse " + FileName);
    isImportingInProgress = false;
    showArrowCursor();
    return;
  }

  String rootType = root.hasKey("type") ? root.getString("type") : "";
  if (!rootType.equals("Topology")) {
    println("\nTopoJSON import: root \"type\" is not \"Topology\" in " + FileName);
    isImportingInProgress = false;
    showArrowCursor();
    return;
  }

  topojsonReadTransform(geojsonGetObjectOrNull(root, "transform"));

  JSONArray arcsJson = root.hasKey("arcs") ? root.getJSONArray("arcs") : null;
  topojsonDecodeArcs(arcsJson);

  JSONObject objects = geojsonGetObjectOrNull(root, "objects");

  progressBarHeader();
  float printed_Progress = 0;
  boolean aborted = false;

  if (objects != null) {
    java.util.Set<?> keys = objects.keys();
    int totalObjects = keys.size();
    float totalObjectsF = max(1, totalObjects); // avoid /0 below for an empty "objects"

    ProgressWindow importProgressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("\nImporting TopoJSON") : null;
    if (importProgressWindow != null) importProgressWindow.setVisible(true);

    try {
      int f = 0;
      for (Object keyObj : keys) {
        // Esc, caught by importProgressWindow's own Toolkit-level
        // listener (progressWindow.pde) regardless of which window has
        // focus - same as import_objects_GEOJSON()'s identical check. No
        // rollback on abort - whatever points/faces/polylines were
        // already created from the objects read so far are kept, same as
        // any other partial import.
        if ((importProgressWindow != null) && importProgressWindow.abortRequested) {
          echoAbortProgress();
          aborted = true;
          break;
        }

        if (control != USER_AUTO) {
          float Progress = 100 * f / totalObjectsF;
          int delta = (int) floor(Progress - printed_Progress);
          if (delta >= 1) {
            printProgressBarChunk(delta); // one print() call instead of `delta` calls
            printed_Progress = floor(Progress);
            if (importProgressWindow != null) importProgressWindow.updateFraction(Progress / 100.0f);
          }
        }

        String key = (String) keyObj;
        JSONObject namedObject = geojsonGetObjectOrNull(objects, key);
        if (namedObject == null) { geojsonNoteSkipped("null/non-object entry in \"objects\""); f++; continue; }
        topojsonHandleNamedObject(namedObject, clz, cx, cy, cz, sx, sy, sz);
        f++;
      }
    } finally {
      if (importProgressWindow != null) importProgressWindow.dispose();
    }
  }

  if (!aborted) {
    int remaining = (int) floor(100 - printed_Progress);
    printProgressBarChunk(remaining);
    println();

    String summary = "TopoJSON import complete: " + geojsonPointsImported + " point(s), " + geojsonLinesImported + " line(s), " + geojsonFlatFacesImported + " flat face(s), " + geojsonSolidsImported + " extruded solid(s) imported";
    if (geojsonImportSkippedCount > 0) summary += ", " + geojsonImportSkippedCount + " unsupported/malformed item(s) skipped";
    summary += ".";
    println();
    println(summary);
  }

  isImportingInProgress = false;
  showArrowCursor();
}

// Reads this file's own (optional) "transform" member - its own absence
// (rather than an empty/malformed one) is the normal, documented "this
// topology isn't quantized at all" case (this file's own header comment),
// so topojsonHasTransform only turns on when BOTH "scale" and "translate"
// are actually present and well-formed.
void topojsonReadTransform (JSONObject transform) {
  topojsonHasTransform = false;
  topojsonScale = new double[]{1, 1};
  topojsonTranslate = new double[]{0, 0};
  if (transform == null) return;

  JSONArray scaleArr = transform.hasKey("scale") ? transform.getJSONArray("scale") : null;
  JSONArray translateArr = transform.hasKey("translate") ? transform.getJSONArray("translate") : null;
  if (scaleArr == null || translateArr == null) return;

  topojsonScale = new double[scaleArr.size()];
  for (int i = 0; i < scaleArr.size(); i++) topojsonScale[i] = scaleArr.getDouble(i);

  topojsonTranslate = new double[translateArr.size()];
  for (int i = 0; i < translateArr.size(); i++) topojsonTranslate[i] = translateArr.getDouble(i);

  topojsonHasTransform = true;
}

// Decodes every arc in this file's own top-level "arcs" array - the
// shared pool every LineString/Polygon's own "arcs" member indexes into -
// into topojsonArcs, in file order, so topojsonResolveArcIndexes() below
// can resolve any index against it in O(1).
void topojsonDecodeArcs (JSONArray arcsJson) {
  topojsonArcs = new ArrayList<ArrayList<float[]>>();
  if (arcsJson == null) return;
  for (int a = 0; a < arcsJson.size(); a++) {
    topojsonArcs.add(topojsonDecodeArc(arcsJson.getJSONArray(a)));
  }
}

// One arc: a list of positions, each already dequantized into a {lon, lat,
// alt} triple (alt 0 when this arc's own positions carry only 2
// dimensions - the overwhelmingly common case). When topojsonHasTransform
// is on, this is: accumulate each dimension's own value onto a running
// per-dimension total (every position after an arc's own first is a DELTA
// from the previous one, never an absolute value - the spec's own
// "quantized arcs must be delta-encoded" rule), then multiply that running
// total by its own dimension's scale and add its own translate - exactly
// the quantization the TopoJSON spec itself describes, and the inverse of
// what a TopoJSON ENCODER (not read by this importer - only decoding is in
// scope here) would have done to produce these integers in the first
// place. When topojsonHasTransform is off, a position's own values are
// already final, non-delta-encoded lon/lat/alt numbers - passed straight
// through, no accumulation.
ArrayList<float[]> topojsonDecodeArc (JSONArray arcJson) {
  ArrayList<float[]> pts = new ArrayList<float[]>();
  if (arcJson == null || arcJson.size() == 0) return pts;

  int dims = arcJson.getJSONArray(0).size();
  double[] acc = new double[dims];

  for (int p = 0; p < arcJson.size(); p++) {
    JSONArray posJson = arcJson.getJSONArray(p);
    float[] out = new float[3]; // {lon, lat, alt} - alt stays 0 when dims < 3
    int n = min(dims, posJson.size());
    for (int d = 0; d < n; d++) {
      double v = posJson.getDouble(d);
      if (topojsonHasTransform) {
        acc[d] += v;
        double scale = (d < topojsonScale.length) ? topojsonScale[d] : 1.0;
        double translate = (d < topojsonTranslate.length) ? topojsonTranslate[d] : 0.0;
        v = acc[d] * scale + translate;
      }
      if (d < 3) out[d] = (float) v;
    }
    pts.add(out);
  }
  return pts;
}

// Resolves one LineString's own "arcs" member (a plain array of arc
// indexes) or one ring of a Polygon's own "arcs" member (same shape) into
// the single, stitched, still-unprojected {lon,lat,alt} point list those
// arcs actually trace out. A negative index i means "arc ~i (i.e. -i-1),
// reversed" (TopoJSON's own ones'-complement convention, so that -1 means
// "arc 0, reversed", -2 means "arc 1, reversed", and so on - never a
// literal negative array index); walking a reversed arc backwards is what
// "reversed" means here. Consecutive arcs in the SAME index list always
// share an endpoint by construction (one arc's own last position is always
// identical to the next arc's own first, whichever direction either is
// walked in) - so every arc after this list's own first contributes its
// own point list MINUS its own first point, to avoid a duplicate vertex at
// every arc boundary. An out-of-range index is skipped (noted, not
// thrown), the same tolerance this whole shared core already follows for
// any other malformed reference.
ArrayList<float[]> topojsonResolveArcIndexes (JSONArray arcIndexes) {
  ArrayList<float[]> result = new ArrayList<float[]>();
  if (arcIndexes == null) return result;

  for (int k = 0; k < arcIndexes.size(); k++) {
    int idx = arcIndexes.getInt(k);
    boolean reversed = idx < 0;
    int real = reversed ? (-idx - 1) : idx;
    if (real < 0 || real >= topojsonArcs.size()) { geojsonNoteSkipped("arc index out of range"); continue; }

    ArrayList<float[]> arcPts = topojsonArcs.get(real);
    int n = arcPts.size();
    for (int step = 0; step < n; step++) {
      if (k > 0 && step == 0) continue; // shared endpoint with the previous arc in this same list - already added
      int i = reversed ? (n - 1 - step) : step;
      result.add(arcPts.get(i));
    }
  }
  return result;
}

// Same as topojsonResolveArcIndexes(), but projected through this import's
// own geojsonLonLatAltToXYZ() (importGeojson.pde) into this app's own
// local XYZ PVectors, ready for geojsonEmitLineStringFromPoints()/
// geojsonEmitPolygonFromRings() (both importGeojson.pde) to consume
// exactly as they already do for GeoJSON's own coordinate-array-sourced
// points.
ArrayList<PVector> topojsonResolveArcIndexesToPVectors (JSONArray arcIndexes, float cx, float cy, float cz, float sx, float sy, float sz) {
  ArrayList<float[]> raw = topojsonResolveArcIndexes(arcIndexes);
  ArrayList<PVector> pts = new ArrayList<PVector>();
  for (float[] r : raw) {
    float[] xyz = geojsonLonLatAltToXYZ(r[0], r[1], r[2], cx, cy, cz, sx, sy, sz);
    pts.add(new PVector(xyz[0], xyz[1], xyz[2]));
  }
  return pts;
}

// One top-level entry under this file's own "objects" - applies this
// import's own grouping option (if any) off this object's own
// "properties" ONCE (mirroring GeoJSON's own once-per-Feature granularity
// - this file's own header comment), then dispatches it exactly like any
// other geometry object.
void topojsonHandleNamedObject (JSONObject obj, int clzParam, float cx, float cy, float cz, float sx, float sy, float sz) {
  JSONObject properties = geojsonGetObjectOrNull(obj, "properties");
  geojsonApplyGrouping(properties);
  topojsonHandleGeometry(obj, properties, clzParam, cx, cy, cz, sx, sy, sz);
}

// Dispatches one TopoJSON geometry object by its own "type" - called both
// for a top-level named object (via topojsonHandleNamedObject() above) and,
// recursively, for every geometry nested inside a "GeometryCollection"
// (the enclosing object's own `properties` still applies to each one,
// never re-derived per nested geometry - exactly importGeojson.pde's own
// geojsonHandleGeometry() GeometryCollection branch's own precedent).
// Point/MultiPoint still carry "coordinates" directly, same as GeoJSON;
// every other type carries "arcs" instead of "coordinates" - this file's
// own header comment explains why.
void topojsonHandleGeometry (JSONObject geometry, JSONObject properties, int clzParam, float cx, float cy, float cz, float sx, float sy, float sz) {
  if (geometry == null) { geojsonNoteSkipped("null geometry object"); return; }
  String type = geometry.hasKey("type") ? geometry.getString("type") : "";

  if (type.equals("Point")) {
    JSONArray coord = geometry.hasKey("coordinates") ? geometry.getJSONArray("coordinates") : null;
    topojsonHandlePoint(coord, cx, cy, cz, sx, sy, sz);
  } else if (type.equals("MultiPoint")) {
    JSONArray coords = geometry.hasKey("coordinates") ? geometry.getJSONArray("coordinates") : null;
    if (coords == null) { geojsonNoteSkipped("MultiPoint with no coordinates"); return; }
    for (int i = 0; i < coords.size(); i++) topojsonHandlePoint(coords.getJSONArray(i), cx, cy, cz, sx, sy, sz);
  } else if (type.equals("LineString")) {
    JSONArray arcIndexes = geometry.hasKey("arcs") ? geometry.getJSONArray("arcs") : null;
    ArrayList<PVector> pts = topojsonResolveArcIndexesToPVectors(arcIndexes, cx, cy, cz, sx, sy, sz);
    geojsonEmitLineStringFromPoints(pts, clzParam);
  } else if (type.equals("MultiLineString")) {
    JSONArray lines = geometry.hasKey("arcs") ? geometry.getJSONArray("arcs") : null;
    if (lines == null) { geojsonNoteSkipped("MultiLineString with no arcs"); return; }
    for (int i = 0; i < lines.size(); i++) {
      ArrayList<PVector> pts = topojsonResolveArcIndexesToPVectors(lines.getJSONArray(i), cx, cy, cz, sx, sy, sz);
      geojsonEmitLineStringFromPoints(pts, clzParam);
    }
  } else if (type.equals("Polygon")) {
    JSONArray rings = geometry.hasKey("arcs") ? geometry.getJSONArray("arcs") : null;
    topojsonHandlePolygonRingsArcs(rings, properties, cx, cy, cz, sx, sy, sz);
  } else if (type.equals("MultiPolygon")) {
    JSONArray polys = geometry.hasKey("arcs") ? geometry.getJSONArray("arcs") : null;
    if (polys == null) { geojsonNoteSkipped("MultiPolygon with no arcs"); return; }
    for (int i = 0; i < polys.size(); i++) topojsonHandlePolygonRingsArcs(polys.getJSONArray(i), properties, cx, cy, cz, sx, sy, sz);
  } else if (type.equals("GeometryCollection")) {
    JSONArray geometries = geometry.hasKey("geometries") ? geometry.getJSONArray("geometries") : null;
    if (geometries == null) { geojsonNoteSkipped("GeometryCollection with no geometries"); return; }
    for (int i = 0; i < geometries.size(); i++) topojsonHandleGeometry(geometries.getJSONObject(i), properties, clzParam, cx, cy, cz, sx, sy, sz);
  } else {
    geojsonNoteSkipped(type.length() == 0 ? "geometry object with no \"type\"" : ("unrecognized geometry type: " + type));
  }
}

// One Point/MultiPoint member. Unlike an arc's own points, a standalone
// Point geometry's own "coordinates" are NEVER delta-encoded against one
// another (confirmed directly against the TopoJSON specification's own
// Transforms/Point/MultiPoint sections) - each is independently quantized,
// so decoding one is exactly "multiply by scale, add translate", no
// running accumulator (contrast topojsonDecodeArc()'s own comment).
void topojsonHandlePoint (JSONArray coord, float cx, float cy, float cz, float sx, float sy, float sz) {
  if (coord == null || coord.size() < 2) { geojsonNoteSkipped("Point with fewer than 2 coordinate values"); return; }

  double lon = coord.getDouble(0);
  double lat = coord.getDouble(1);
  double alt = (coord.size() > 2) ? coord.getDouble(2) : 0;

  if (topojsonHasTransform) {
    lon = lon * ((topojsonScale.length > 0) ? topojsonScale[0] : 1.0) + ((topojsonTranslate.length > 0) ? topojsonTranslate[0] : 0.0);
    lat = lat * ((topojsonScale.length > 1) ? topojsonScale[1] : 1.0) + ((topojsonTranslate.length > 1) ? topojsonTranslate[1] : 0.0);
    // A 3rd dimension's own scale/translate is rarely defined in practice
    // (the spec is silent on it) - passed through as-is when it isn't,
    // same tolerance every other "the file doesn't define this" case in
    // this shared core already follows.
    if (coord.size() > 2) alt = alt * ((topojsonScale.length > 2) ? topojsonScale[2] : 1.0) + ((topojsonTranslate.length > 2) ? topojsonTranslate[2] : 0.0);
  }

  float[] xyz = geojsonLonLatAltToXYZ((float) lon, (float) lat, (float) alt, cx, cy, cz, sx, sy, sz);
  geojsonEmitPointFromXYZ(xyz);
}

// One Polygon/MultiPolygon member - `rings` is one Polygon's own "arcs":
// its first ring is the outer boundary, every ring after it a hole,
// exactly as GeoJSON's own geojsonHandlePolygonRings() (importGeojson.pde)
// already documents - the only difference here is that each ring's own
// point list comes from resolving arc indexes rather than reading
// coordinates directly. Delegates the actual hole-merge/flat-vs-extrude
// decision to this same shared geojsonEmitPolygonFromRings() core.
void topojsonHandlePolygonRingsArcs (JSONArray rings, JSONObject properties, float cx, float cy, float cz, float sx, float sy, float sz) {
  if (rings == null || rings.size() == 0) { geojsonNoteSkipped("Polygon with no rings"); return; }

  ArrayList<PVector> outer = topojsonResolveArcIndexesToPVectors(rings.getJSONArray(0), cx, cy, cz, sx, sy, sz);
  geojsonStripClosingDuplicate(outer); // an arc-stitched ring loops back to its own start the same way a GeoJSON Polygon ring is always explicitly closed - stripped unconditionally, same as geojsonHandlePolygonRings()'s own identical line
  if (outer.size() < 3) { geojsonNoteSkipped("degenerate polygon ring (fewer than 3 distinct points)"); return; }

  ArrayList<ArrayList<PVector>> holes = new ArrayList<ArrayList<PVector>>();
  for (int i = 1; i < rings.size(); i++) {
    ArrayList<PVector> hole = topojsonResolveArcIndexesToPVectors(rings.getJSONArray(i), cx, cy, cz, sx, sy, sz);
    geojsonStripClosingDuplicate(hole);
    if (hole.size() >= 3) holes.add(hole);
  }

  geojsonEmitPolygonFromRings(outer, holes, properties, sz);
}
