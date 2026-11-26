// Minimal, dependency-free importer for a KML (https://developers.google.
// com/kml/documentation/kmlreference) file - built directly on top of
// importGeojson.pde's own shared core (geojsonEmitPointFromXYZ()/
// geojsonEmitLineStringFromPoints()/geojsonEmitPolygonFromRings()/
// geojsonLonLatAltToXYZ(), plus geojsonHeightProperty/geojsonGroupProperty/
// geojsonApplyGrouping()/geojsonResolveHeight()/geojsonStripClosingDuplicate()
// /geojsonGetObjectOrNull()/geojsonNoteSkipped() and this same import's own
// running point/line/face/solid/skipped counters - every one of those is
// reused exactly as GeoJSON/TopoJSON import already uses it, not
// duplicated), completing the build order agreed before Phase 1 (GeoJSON)
// started: "GeoJSON, then TopoJSON, then KML."
//
// KML is plain XML, so this uses Processing's own built-in XML class
// (xmlHelpers.pde/loadXML() - already used elsewhere in this app for its
// own save/load-project format and for importDae.pde's own COLLADA
// parsing), the same "hand-roll the parser, no external library" choice
// every other importer in this app already makes - no separate KMZ (zipped
// KML) support in this version; only a plain, already-unzipped .kml file.
//
// A KML document's own <Placemark> elements may sit anywhere in the tree -
// nested inside any number of <Document>/<Folder> levels, or even several
// of either - so this import recursively collects every <Placemark> it can
// find anywhere under the root (kmlCollectPlacemarks()'s own comment),
// rather than assuming any particular nesting depth.
//
// v1 scope - the geometry types KML's own Placemark can directly carry:
//   - Point -> a bare vertex, the same treatment every other format's own
//     Point/MultiPoint already gets in this shared core (importGeojson.
//     pde's own header comment).
//   - LineString -> one open (or, if its own <coordinates> already loop
//     back to their own start, closed) Polyline, the same auto-detect
//     convention the whole shared core already uses. A bare <LinearRing>
//     directly under a Placemark (rare - KML normally only uses LinearRing
//     INSIDE a Polygon's own boundaries, see below) is read the exact same
//     way, since it's geometrically just a closed line.
//   - Polygon -> one flat n-gon Face (its own <outerBoundaryIs>, with every
//     <innerBoundaryIs> a hole, bridged into a single boundary loop via
//     the same PolygonHoles.mergeHolesIntoOuterLoop() this whole shared
//     core already uses) - or, when geojsonHeightProperty names an
//     ExtendedData/SchemaData key this Placemark actually carries a
//     positive numeric value for, an extruded solid instead - exactly
//     mirroring GeoJSON/TopoJSON's own identical height-property option.
//   - MultiGeometry -> every geometry nested inside it, recursively, same
//     treatment as a bare geometry of that type directly under a
//     Placemark, with the enclosing Placemark's own properties still
//     applying to each one (mirroring GeoJSON's own GeometryCollection
//     precedent and TopoJSON's own identical one).
// A Placemark with none of the above as a direct child (no geometry at
// all, or a KML construct this version doesn't read - e.g. a bare
// <Model>, <Track>, <gx:Track>, a <NetworkLink>, a <Style>-only entry) is
// skipped via this same shared geojsonNoteSkipped()/
// geojsonImportSkippedReasons running tally, not an error.
//
// KML has no single "properties" object the way a GeoJSON Feature or a
// TopoJSON geometry object already does - the nearest equivalent is a
// Placemark's own <ExtendedData>, whose <Data name="..."><value>...</
// value></Data> children (and/or <SchemaData>'s own <SimpleData
// name="...">...</SimpleData> children) are each a named key/value pair.
// kmlReadProperties() below reads every one of these into a synthetic
// JSONObject carrying the exact same shape a GeoJSON Feature's own
// "properties" already has (every value stored as a String - this shared
// core's own geojsonResolveHeight() already falls back to parsing a
// String value when a direct numeric read fails, so this costs nothing),
// so geojsonApplyGrouping()/geojsonResolveHeight() both work completely
// unmodified. A Placemark with no <ExtendedData> at all (or one with none
// of these recognized children) carries null properties, exactly like a
// GeoJSON Feature with no "properties" member.

boolean kmlImportShowOptionsDialog = false;

void import_objects_KML (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  // Same shape as import_objects_GEOJSON()'s/import_objects_TOPOJSON()'s
  // own identical blocks - see either one's own comment for why this sits
  // here rather than earlier, and what a cancelled dialog does. The
  // dialog itself (geojsonShowImportOptionsDialog(), fileSelected.pde) is
  // shared as-is across all three formats - same two "properties" key
  // options, same meaning.
  if (kmlImportShowOptionsDialog) {
    kmlImportShowOptionsDialog = false;
    if (!geojsonShowImportOptionsDialog()) return;
  }

  println("\nImporting KML. Please wait...");
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

  // Same reasoning as importDae.pde's own identical try/catch around its
  // own loadXML() call - a malformed XML document throws straight out of
  // Processing's own XML parser rather than returning null, unlike a
  // missing/unreadable file (which does return null on its own).
  XML root = null;
  try {
    root = loadXML(FileName);
  }
  catch (RuntimeException e) {
    root = null;
  }
  if (root == null) {
    println("\nKML import: could not read or parse " + FileName);
    isImportingInProgress = false;
    showArrowCursor();
    return;
  }

  ArrayList<XML> placemarks = new ArrayList<XML>();
  kmlCollectPlacemarks(root, placemarks);

  progressBarHeader();
  float printed_Progress = 0;
  boolean aborted = false;
  int totalPlacemarks = placemarks.size();
  float totalPlacemarksF = max(1, totalPlacemarks); // avoid /0 below for a document with no Placemarks at all

  ProgressWindow importProgressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("\nImporting KML") : null;
  if (importProgressWindow != null) importProgressWindow.setVisible(true);

  try {
    for (int f = 0; f < totalPlacemarks; f++) {
      // Esc, caught by importProgressWindow's own Toolkit-level listener
      // (progressWindow.pde) regardless of which window has focus - same
      // as import_objects_GEOJSON()'s identical check. No rollback on
      // abort - whatever points/faces/polylines were already created
      // from the Placemarks read so far are kept, same as any other
      // partial import.
      if ((importProgressWindow != null) && importProgressWindow.abortRequested) {
        echoAbortProgress();
        aborted = true;
        break;
      }

      if (control != USER_AUTO) {
        float Progress = 100 * f / totalPlacemarksF;
        int delta = (int) floor(Progress - printed_Progress);
        if (delta >= 1) {
          printProgressBarChunk(delta); // one print() call instead of `delta` calls
          printed_Progress = floor(Progress);
          if (importProgressWindow != null) importProgressWindow.updateFraction(Progress / 100.0f);
        }
      }

      kmlHandlePlacemark(placemarks.get(f), clz, cx, cy, cz, sx, sy, sz);
    }
  } finally {
    if (importProgressWindow != null) importProgressWindow.dispose();
  }

  if (!aborted) {
    int remaining = (int) floor(100 - printed_Progress);
    printProgressBarChunk(remaining);
    println();

    String summary = "KML import complete: " + geojsonPointsImported + " point(s), " + geojsonLinesImported + " line(s), " + geojsonFlatFacesImported + " flat face(s), " + geojsonSolidsImported + " extruded solid(s) imported";
    if (geojsonImportSkippedCount > 0) summary += ", " + geojsonImportSkippedCount + " unsupported/malformed item(s) skipped";
    summary += ".";
    println();
    println(summary);
  }

  isImportingInProgress = false;
  showArrowCursor();
}

// Recursively collects every <Placemark> anywhere under `el` (this file's
// own header comment on why nesting depth can't be assumed) into `out`, in
// document order. A found Placemark is never itself searched any further
// (KML never nests a Placemark inside another one).
void kmlCollectPlacemarks (XML el, ArrayList<XML> out) {
  if ("Placemark".equals(el.getName())) { out.add(el); return; }
  for (XML child : el.getChildren()) kmlCollectPlacemarks(child, out);
}

// One Placemark: reads its own ExtendedData into a synthetic "properties"
// JSONObject (kmlReadProperties()'s own comment), applies this import's
// own grouping option (if any) off it ONCE (mirroring GeoJSON's own
// once-per-Feature/TopoJSON's own once-per-named-object granularity), then
// dispatches whichever of Point/LineString/LinearRing/Polygon/
// MultiGeometry it carries as a direct child - KML's own schema allows at
// most one, but every one actually present is still handled, same
// "tolerate more than strictly valid" leniency this importer's own XML
// reading already follows elsewhere.
void kmlHandlePlacemark (XML placemark, int clzParam, float cx, float cy, float cz, float sx, float sy, float sz) {
  JSONObject properties = kmlReadProperties(placemark);
  geojsonApplyGrouping(properties);

  boolean foundAny = false;
  for (String tag : new String[]{"Point", "LineString", "LinearRing", "Polygon", "MultiGeometry"}) {
    XML geomEl = placemark.getChild(tag);
    if (geomEl != null) {
      kmlHandleGeometry(geomEl, properties, clzParam, cx, cy, cz, sx, sy, sz);
      foundAny = true;
    }
  }
  if (!foundAny) geojsonNoteSkipped("Placemark with no recognized geometry");
}

// Dispatches one KML geometry element by its own tag name - called both
// for a Placemark's own direct geometry child (via kmlHandlePlacemark()
// above) and, recursively, for every geometry nested inside a
// MultiGeometry (the enclosing Placemark's own `properties` still applies
// to each one, never re-derived per nested geometry - mirroring GeoJSON's
// own GeometryCollection precedent exactly).
void kmlHandleGeometry (XML geomEl, JSONObject properties, int clzParam, float cx, float cy, float cz, float sx, float sy, float sz) {
  String type = geomEl.getName();

  if (type.equals("Point")) {
    XML coordsEl = geomEl.getChild("coordinates");
    if (coordsEl == null) { geojsonNoteSkipped("Point with no <coordinates>"); return; }
    ArrayList<float[]> tuples = kmlParseCoordinateTuples(XML_getContent(coordsEl));
    if (tuples.size() == 0) { geojsonNoteSkipped("Point with no coordinate values"); return; }
    float[] t = tuples.get(0);
    float[] xyz = geojsonLonLatAltToXYZ(t[0], t[1], t[2], cx, cy, cz, sx, sy, sz);
    geojsonEmitPointFromXYZ(xyz);
  } else if (type.equals("LineString") || type.equals("LinearRing")) {
    // A bare LinearRing directly under a Placemark (not one of a
    // Polygon's own boundaries, handled separately below) is geometrically
    // just a closed line - read it exactly the same way as a LineString;
    // geojsonEmitLineStringFromPoints()'s own closing-duplicate
    // auto-detect (importGeojson.pde) already handles a ring that loops
    // back to its own start.
    ArrayList<PVector> pts = kmlReadPointsFromCoordinatesChild(geomEl, cx, cy, cz, sx, sy, sz);
    if (pts == null) { geojsonNoteSkipped(type + " with no <coordinates>"); return; }
    geojsonEmitLineStringFromPoints(pts, properties, clzParam);
  } else if (type.equals("Polygon")) {
    kmlHandlePolygon(geomEl, properties, cx, cy, cz, sx, sy, sz);
  } else if (type.equals("MultiGeometry")) {
    for (XML child : geomEl.getChildren()) {
      String childTag = child.getName();
      if (childTag.equals("Point") || childTag.equals("LineString") || childTag.equals("LinearRing") || childTag.equals("Polygon") || childTag.equals("MultiGeometry")) {
        kmlHandleGeometry(child, properties, clzParam, cx, cy, cz, sx, sy, sz);
      }
      // Any other child a MultiGeometry happens to carry (a comment node,
      // ...) is simply not a geometry - silently not counted as skipped,
      // same as this whole importer already does for structural XML it
      // isn't looking for.
    }
  } else {
    geojsonNoteSkipped(type == null ? "geometry element with no tag name" : ("unrecognized geometry type: " + type));
  }
}

// One Polygon - `geomEl` is the <Polygon> element itself. Its own
// <outerBoundaryIs><LinearRing><coordinates> is the outer boundary; every
// <innerBoundaryIs><LinearRing><coordinates> (KML allows more than one) is
// a hole, bridged into the outer boundary exactly the same way GeoJSON's
// own geojsonHandlePolygonRings()/TopoJSON's own
// topojsonHandlePolygonRingsArcs() (both importGeojson.pde/importTopojson.
// pde) already do, via this same shared geojsonEmitPolygonFromRings() core.
void kmlHandlePolygon (XML geomEl, JSONObject properties, float cx, float cy, float cz, float sx, float sy, float sz) {
  XML outerBoundary = geomEl.getChild("outerBoundaryIs");
  XML outerRing = (outerBoundary != null) ? outerBoundary.getChild("LinearRing") : null;
  ArrayList<PVector> outer = (outerRing != null) ? kmlReadPointsFromCoordinatesChild(outerRing, cx, cy, cz, sx, sy, sz) : null;
  if (outer == null) { geojsonNoteSkipped("Polygon with no outerBoundaryIs/LinearRing/coordinates"); return; }

  geojsonStripClosingDuplicate(outer); // a KML LinearRing conventionally repeats its own first point as its last, same as a GeoJSON Polygon ring always does
  if (outer.size() < 3) { geojsonNoteSkipped("degenerate polygon ring (fewer than 3 distinct points)"); return; }

  ArrayList<ArrayList<PVector>> holes = new ArrayList<ArrayList<PVector>>();
  for (XML innerBoundary : geomEl.getChildren("innerBoundaryIs")) {
    XML innerRing = innerBoundary.getChild("LinearRing");
    ArrayList<PVector> hole = (innerRing != null) ? kmlReadPointsFromCoordinatesChild(innerRing, cx, cy, cz, sx, sy, sz) : null;
    if (hole == null) continue;
    geojsonStripClosingDuplicate(hole);
    if (hole.size() >= 3) holes.add(hole);
  }

  geojsonEmitPolygonFromRings(outer, holes, properties, sz);
}

// Reads `el`'s own <coordinates> child (a LineString, LinearRing, or the
// LinearRing inside one of a Polygon's own boundaries all share this same
// shape) into this app's own local XYZ PVectors, in file order - or null
// when `el` carries no <coordinates> child at all. No closing-duplicate
// handling here; see geojsonStripClosingDuplicate() (importGeojson.pde)
// for that, applied separately by whichever caller needs it.
ArrayList<PVector> kmlReadPointsFromCoordinatesChild (XML el, float cx, float cy, float cz, float sx, float sy, float sz) {
  XML coordsEl = el.getChild("coordinates");
  if (coordsEl == null) return null;

  ArrayList<float[]> tuples = kmlParseCoordinateTuples(XML_getContent(coordsEl));
  ArrayList<PVector> pts = new ArrayList<PVector>();
  for (float[] t : tuples) {
    float[] xyz = geojsonLonLatAltToXYZ(t[0], t[1], t[2], cx, cy, cz, sx, sy, sz);
    pts.add(new PVector(xyz[0], xyz[1], xyz[2]));
  }
  return pts;
}

// A KML <coordinates> element's own text content is whitespace-separated
// "lon,lat(,alt)" tuples (KML's own comma-separated-per-point, whitespace-
// or-newline-separated-between-points convention - deliberately the
// reverse punctuation of GeoJSON's own nested-array shape, but the same
// [lon, lat(, alt)] order and the same "altitude defaults to 0 when
// omitted" rule, RFC 7946 section 3.1.1's own convention this whole shared
// core already follows). splitTokens() (Processing's own default
// whitespace/newline delimiter set) breaks the text into one token per
// tuple; each token is then split on its own commas. A malformed tuple
// (fewer than 2 comma-separated values, or a value that doesn't parse as
// a number) is skipped rather than thrown, the same tolerance this whole
// shared core already follows for any other malformed coordinate.
ArrayList<float[]> kmlParseCoordinateTuples (String text) {
  ArrayList<float[]> result = new ArrayList<float[]>();
  if (text == null) return result;

  String[] tokens = splitTokens(text);
  for (String token : tokens) {
    String[] parts = split(token, ',');
    if (parts.length < 2) continue;
    try {
      float lon = Float.parseFloat(parts[0].trim());
      float lat = Float.parseFloat(parts[1].trim());
      float alt = (parts.length > 2) ? Float.parseFloat(parts[2].trim()) : 0;
      result.add(new float[]{lon, lat, alt});
    }
    catch (Exception e) {
      continue;
    }
  }
  return result;
}

// Reads a Placemark's own <ExtendedData> (if any) into a synthetic
// "properties" JSONObject - see this file's own header comment for why,
// and for the exact <Data>/<SchemaData><SimpleData> shapes read. Returns
// null (not an empty JSONObject) when this Placemark carries no
// <ExtendedData> at all, or one with none of these recognized children -
// geojsonApplyGrouping()/geojsonResolveHeight() (importGeojson.pde) both
// already treat null properties as "this option never applies here",
// exactly the GeoJSON-Feature-with-no-properties case they're already
// written for.
JSONObject kmlReadProperties (XML placemark) {
  XML extendedData = placemark.getChild("ExtendedData");
  if (extendedData == null) return null;

  JSONObject properties = null;
  for (XML child : extendedData.getChildren()) {
    String tag = child.getName();
    if (tag.equals("Data")) {
      String name = kmlAttr(child, "name");
      if (name.length() == 0) continue;
      XML valueEl = child.getChild("value");
      String value = (valueEl != null) ? XML_getContent(valueEl) : "";
      if (properties == null) properties = new JSONObject();
      properties.setString(name, (value == null) ? "" : value);
    } else if (tag.equals("SchemaData")) {
      for (XML simpleData : child.getChildren("SimpleData")) {
        String name = kmlAttr(simpleData, "name");
        if (name.length() == 0) continue;
        String value = XML_getContent(simpleData);
        if (properties == null) properties = new JSONObject();
        properties.setString(name, (value == null) ? "" : value);
      }
    }
  }
  return properties;
}

// Same as importDae.pde's own daeAttr() - a missing XML attribute reads as
// "" rather than null, so every caller above can test its own length
// instead of null-checking separately.
String kmlAttr (XML el, String name) {
  String v = el.getString(name);
  return (v == null) ? "" : v;
}
