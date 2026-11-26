// Minimal, dependency-free exporter for a GeoJSON (RFC 7946) file - the
// write-side counterpart to importGeojson.pde, and (per the same build
// order already agreed for every GIS format on the way in) the shared
// "GIS export core" every future GIS exporter (KML, TopoJSON, Shapefile,
// CityGML) is meant to build on, exactly the way importGeojson.pde's own
// geojsonEmit*()/geojsonLonLatAltToXYZ() already serve every GIS
// *importer* in this app.
//
// Scope - the mirror image of importGeojson.pde's own "every Polygon/
// MultiPolygon -> one flat n-gon Face" etc., but necessarily narrower on
// the way back out, since this app's own Face/Polyline storage keeps
// strictly less structure than a source GeoJSON file can carry:
//   - every allFaces entry -> one Polygon Feature, its one ring exactly
//     as stored. A Face with a bridged hole (PolygonHoles.
//     mergeHolesIntoOuterLoop(), used by this app's own importer-side
//     geojsonEmitPolygonFromRings() on the way in) is already just one
//     simple/self-touching loop by the time it reaches allFaces, with no
//     separate "this was really a hole" bookkeeping kept anywhere - so
//     holes are never reconstructed here, the ring is exported exactly
//     as stored. Likewise, an extruded solid (geojsonEmitExtrudedSolid())
//     becomes several independent allFaces entries (one bottom cap, one
//     top cap, one quad per wall) with no "these N faces were really one
//     building's footprint+height" link kept either - each becomes its
//     own independent Polygon Feature, not a single extruded Feature
//     with a height property. Reconstructing either of those would mean
//     guessing at geometry this app's own data model has already thrown
//     away, rather than exporting what is actually there - the same
//     restraint importShapefile.pde's own "no hole-within-hole" scope
//     note and every other importer's own "don't invent data the file
//     doesn't carry" stance already take, just facing the opposite
//     direction here.
//   - every allPolylines entry -> one LineString Feature, closed (first
//     coordinate repeated at the end) only when getClose() says so -
//     GeoJSON's own LineString has no separate notion of "closed", unlike
//     its LinearRing special case (always implicitly closed), so this is
//     the one place a closed/open distinction is preserved explicitly
//     rather than assumed either way.
//   - no standalone Point Features at all - this app has no dedicated
//     point/marker object (importGeojson.pde's own header comment makes
//     the same observation on the way in), and allPoints is an append-
//     only pool of every vertex any Face/Polyline/point-cloud/etc. has
//     ever used (see exportLas.pde's own header comment) - no "this one
//     is really a standalone point, not just some face's corner"
//     bookkeeping exists to export from.
//   - a Face/Polyline whose own getVisibility() is 0 (hidden) is skipped
//     - the same "only ever see what's actually visible" filter faces.
//     pde's/polylines.pde's own draw() already applies before deciding
//     what reaches the screen or exportObj.pde's own TypeWindow.OBJ3D
//     pass.
//
// Coordinates: every vertex is reverse-projected from this app's own
// local XY meters back to real [longitude, latitude, altitude] via
// Functions.convert_XY2lonlat() (functions.pde) - the exact inverse of
// convert_lonlat2XY(), which importGeojson.pde's own
// geojsonLonLatAltToXYZ() already uses on the way in - around the same
// project site location (locationLongitude/locationLatitude,
// globalVariables.pde). Unlike CityGML/Shapefile import's own planar-vs-
// lonlat toggle, this exporter always writes real WGS84 lon/lat: RFC 7946
// section 4 requires that datum for valid GeoJSON, so there is no valid
// "local planar passthrough" variant to offer on the way out.
//
// Winding: RFC 7946 section 3.1.6 calls for a right-hand-rule winding
// where an exterior ring is counterclockwise (an errata thread disputes
// the RFC's own prose description of "right-hand rule", but not this
// worked convention itself, which is what every real-world GeoJSON writer
// actually follows). Every exported ring is checked with the same
// shoelace signed-area test importShapefile.pde's own
// shpSignedRingArea() already uses for the opposite-wound Shapefile
// convention, and reversed if it comes out clockwise -
// exportGeojsonSignedRingArea() below works in already-reverse-projected
// lon/lat space rather than the Shapefile importer's own planar XY, so
// it's its own small function rather than a shared one, but the
// technique is the same.
//
// Properties: every Feature carries its own source Face's/Polyline's
// material and layer as "material"/"layer" integer properties - the
// reverse purpose of geojsonGroupProperty (importGeojson.pde): typing
// "material" or "layer" back into that option when re-importing this
// exact file regroups it exactly the way it was grouped here. Every
// other key that source's own extraParams holds (if any, and unless the
// exportExtraParams toggle, fileSelected.pde, is off) is merged in
// alongside them - see exportBuildProperties()'s own comment, further
// down, for exactly how, including which one wins if extraParams itself
// uses "material"/"layer" as one of its own keys.
//
// Written with Processing's own saveJSONObject() - the write side of the
// same built-in loadJSONObject() importGeojson.pde already reads with -
// no hand-rolled JSON writer, the same "don't invent infrastructure a
// built-in already provides" choice every binary exporter's own
// binWrite*() helpers already make for their own, lower-level format.

void exportGeojson () {

  // See isFileOperationInProgress's own comment (globalFunctions.pde)
  // for why - bare statement (this function has only the one exit point
  // below, so nothing further to guard); cleared at this function's own
  // end.
  isFileOperationInProgress = true;

  String geojsonFilename = Folder_Export3D + "/" + ProjectName + ".geojson";

  JSONArray features = new JSONArray();

  for (int f = 0; f < allFaces.nodes.length; f++) {

    if (allFaces.getVisibility(f) <= 0) continue;
    if (allFaces.nodes[f].length < 3) continue;

    features.append(exportGeojsonBuildPolygonFeature(allFaces.nodes[f], allFaces.getMaterial(f), allFaces.getLayer(f), allFaces.getExtraParams(f)));
  }

  for (int p = 0; p < allPolylines.nodes.length; p++) {

    if (allPolylines.getVisibility(p) <= 0) continue;
    if (allPolylines.nodes[p].length < 2) continue;

    features.append(exportGeojsonBuildLineStringFeature(allPolylines.nodes[p], allPolylines.getClose(p), allPolylines.getMaterial(p), allPolylines.getLayer(p), allPolylines.getExtraParams(p)));
  }

  JSONObject root = new JSONObject();
  root.setString("type", "FeatureCollection");
  root.setJSONArray("features", features);

  saveJSONObject(root, geojsonFilename);

  println("\nFile created:" + geojsonFilename);

  isFileOperationInProgress = false;
}

// One allFaces node loop -> one GeoJSON Polygon Feature (a single ring -
// see this file's own header comment, "Scope", on why holes/extruded-
// solid reconstruction is out of scope).
JSONObject exportGeojsonBuildPolygonFeature (int[] faceNodes, int material, int layer, String extraParams) {

  ArrayList<float[]> ring = exportGeojsonBuildClosedWoundRing(faceNodes);

  JSONArray outerRing = new JSONArray();
  for (float[] lla : ring) {
    outerRing.append(exportGeojsonLonLatAltToJSONArray(lla));
  }

  JSONArray coordinates = new JSONArray();
  coordinates.append(outerRing);

  JSONObject geometry = new JSONObject();
  geometry.setString("type", "Polygon");
  geometry.setJSONArray("coordinates", coordinates);

  return exportGeojsonWrapFeature(geometry, material, layer, extraParams);
}

// One allPolylines node list -> one GeoJSON LineString Feature, closed
// (first coordinate repeated at the end) only when close==1 - see this
// file's own header comment, "Scope".
JSONObject exportGeojsonBuildLineStringFeature (int[] polylineNodes, int close, int material, int layer, String extraParams) {

  JSONArray lineCoordinates = new JSONArray();
  for (int i = 0; i < polylineNodes.length; i++) {
    lineCoordinates.append(exportGeojsonLonLatAltToJSONArray(exportGeojsonPointToLonLatAlt(polylineNodes[i])));
  }
  if (close == 1) {
    lineCoordinates.append(exportGeojsonLonLatAltToJSONArray(exportGeojsonPointToLonLatAlt(polylineNodes[0])));
  }

  JSONObject geometry = new JSONObject();
  geometry.setString("type", "LineString");
  geometry.setJSONArray("coordinates", lineCoordinates);

  return exportGeojsonWrapFeature(geometry, material, layer, extraParams);
}

// Shared "Feature" envelope (type/geometry/properties) - the "material"/
// "layer" properties are this file's own header comment's "Properties"
// section; extraParams is this feature's own additional, opaque
// metadata - see exportBuildProperties()'s own comment below for how the
// two are merged.
JSONObject exportGeojsonWrapFeature (JSONObject geometry, int material, int layer, String extraParams) {

  JSONObject feature = new JSONObject();
  feature.setString("type", "Feature");
  feature.setJSONObject("geometry", geometry);
  feature.setJSONObject("properties", exportBuildProperties(material, layer, extraParams));
  return feature;
}

// ---------------------------------------------------------------------
// Shared GIS export "properties" core - the write-side mirror of
// geojsonPropertiesToExtraParams()/geojsonApplyGrouping() (importGeojson.
// pde): builds the one properties/attribute bag every GIS exporter in
// this app writes, reused as-is by exportTopojson.pde (a native JSON
// properties object, like GeoJSON itself) and, via
// exportJsonValueToDisplayString() below, by exportKml.pde/
// exportCitygml.pde (each of which writes the exact same key/value set
// as its own flat per-key XML element instead of a nested JSON object -
// see either file's own "ExtendedData"/"generic attribute" comment).
// exportShapefile.pde/exportDxf.pde do NOT reuse this - DBF's fixed
// columns and DXF's XDATA have no natural "properties object" shape to
// merge into, so each writes its own source Face's/Polyline's extraParams
// as a single raw-JSON blob instead (that file's own comment explains).
// ---------------------------------------------------------------------

// Starts from material/layer - this app's own two reserved, always-
// present properties, the same two every GIS exporter already wrote
// before this feature existed - then, when exportExtraParams is on and
// extraParams itself parses to a non-empty object, merges every one of
// ITS keys in on top. Each value is copied via get()/put() rather than
// through a single typed getter/setter pair, so a String, int, float,
// boolean, nested JSONObject or JSONArray value all survive with their
// own original type intact, not just coerced to a string.
//
// extraParams wins a key collision: a Face/Polyline that itself still
// carries extraParams literally named "material" or "layer" (e.g. one
// captured, on import, from an external file whose own properties
// already used those names - importGeojson.pde's own
// geojsonPropertiesToExtraParams() keeps a source Feature's ENTIRE
// properties object verbatim, whatever keys it happened to use) has its
// own value take precedence over this app's generated material/layer,
// simply by being written second, overwriting whatever setInt() above
// already put there.
JSONObject exportBuildProperties (int material, int layer, String extraParams) {
  JSONObject properties = new JSONObject();
  properties.setInt("material", material);
  properties.setInt("layer", layer);

  if (exportExtraParams) {
    JSONObject extra = extraParamsToJSONObject(extraParams);
    for (Object keyObj : extra.keys()) {
      String key = (String) keyObj;
      properties.put(key, extra.get(key));
    }
  }

  return properties;
}

// A properties object's own key, rendered as plain display text - for
// KML's <value>/CityGML's <gen:value>, which (like every other property
// value this app's own GIS importers read back - kmlReadProperties()'s/
// citygmlReadProperties()'s own comments) are always read back as a
// plain String regardless of which XML element wrote them, so there is
// no round-trip reason to pick a different element/type per Java value.
// A nested JSONObject/JSONArray value (extraParams holding an object or
// array under one of its own keys, not just flat scalars) is rendered as
// its own raw JSON text via toString() - lossy for a true structural
// round trip through KML/CityGML's own flat per-key attribute model, but
// still fully inspectable, the same "best-effort, not lossless" stance
// exportShapefile.pde's/exportDxf.pde's own blob-field approach already
// takes for these two formats' own, even flatter metadata mechanisms.
String exportJsonValueToDisplayString (JSONObject obj, String key) {
  if (!obj.hasKey(key) || obj.isNull(key)) return "";
  return String.valueOf(obj.get(key));
}

// One allFaces node loop -> one closed, correctly-wound ring of
// [lon, lat, alt] points - the shared geometry step behind
// exportGeojsonBuildPolygonFeature() above and exportKml.pde's own
// Polygon writer, which needs the exact same ring (reverse-projected,
// rewound counterclockwise, closed) but wrapped in KML's own
// <coordinates> text rather than a GeoJSON JSONArray.
ArrayList<float[]> exportGeojsonBuildClosedWoundRing (int[] faceNodes) {

  ArrayList<float[]> ring = new ArrayList<float[]>();
  for (int i = 0; i < faceNodes.length; i++) {
    ring.add(exportGeojsonPointToLonLatAlt(faceNodes[i]));
  }

  if (exportGeojsonSignedRingArea(ring) < 0) {
    java.util.Collections.reverse(ring);
  }

  // Close the ring - RFC 7946 section 3.1.6 requires the first and last
  // positions to be equivalent, and a KML LinearRing conventionally does
  // the exact same thing (see importKml.pde's own
  // "geojsonStripClosingDuplicate(outer)" comment on reading one back).
  ring.add(ring.get(0));

  return ring;
}

// allPoints vertex index -> [lon, lat, alt] (a plain 3-element float[],
// not yet a JSONArray - exportGeojsonSignedRingArea() below needs the
// raw lon/lat values to compute an area with, so the JSONArray
// conversion is a separate, later step; see
// exportGeojsonLonLatAltToJSONArray()).
float[] exportGeojsonPointToLonLatAlt (int vertexIndex) {
  float x = allPoints.getX(vertexIndex);
  float y = allPoints.getY(vertexIndex);
  float z = allPoints.getZ(vertexIndex);
  float[] lonLat = funcs.convert_XY2lonlat(locationLongitude, locationLatitude, x, y);
  return new float[]{lonLat[0], lonLat[1], z};
}

JSONArray exportGeojsonLonLatAltToJSONArray (float[] lonLatAlt) {
  JSONArray coord = new JSONArray();
  coord.append(lonLatAlt[0]);
  coord.append(lonLatAlt[1]);
  coord.append(lonLatAlt[2]);
  return coord;
}

// Shoelace signed-area test over a ring already in [lon, lat, alt] form
// (altitude ignored - winding is a purely 2D/lon-lat question) - see
// this file's own header comment, "Winding", for why this isn't shared
// with importShapefile.pde's own shpSignedRingArea(), which works in a
// different coordinate space for the opposite convention.
float exportGeojsonSignedRingArea (ArrayList<float[]> ring) {
  int n = ring.size();
  float area = 0;
  for (int i = 0; i < n; i++) {
    float[] p0 = ring.get(i);
    float[] p1 = ring.get((i + 1) % n);
    area += p0[0] * p1[1] - p1[0] * p0[1];
  }
  return area / 2.0;
}
