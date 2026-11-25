// Minimal, dependency-free exporter for a TopoJSON file (https://github.com/
// topojson/topojson-specification) - the write-side counterpart to
// importTopojson.pde, built directly on top of exportGeojson.pde's own
// shared "GIS export core" (exportGeojsonPointToLonLatAlt()/
// exportGeojsonSignedRingArea()/exportGeojsonBuildClosedWoundRing()/
// exportGeojsonLonLatAltToJSONArray(), reused exactly as exportKml.pde's
// own Polygon/LineString writers already reuse them - same Scope/
// Coordinates/Winding as that file's own header comment: one Polygon per
// Face (no hole/extruded-solid reconstruction), one LineString per
// Polyline (closed only when getClose() says so), no standalone Points,
// hidden geometry skipped, real reverse-projected longitude/latitude, and
// every exterior ring wound counterclockwise.
//
// What TopoJSON adds over plain GeoJSON is topology: every LineString/
// Polygon references one or more "arcs" by index into a single shared
// top-level "arcs" array, rather than carrying its own full coordinate
// list inline (importTopojson.pde's own header comment goes through the
// format in more depth). Sharing an arc between two neighboring
// geometries (so a shared boundary is stored only once) is an
// *optimization* TopoJSON encoders are free to perform, never a
// requirement the format itself imposes - and this app's own Face/
// Polyline storage keeps no "these two Faces share an edge" adjacency
// link to exploit for it anyway (the same "don't invent data the model
// has already discarded" restraint exportGeojson.pde's own header comment
// already takes for holes and extruded solids). So every exported ring/
// line here gets its own distinct arc, never shared with any other
// geometry - still entirely valid, spec-conformant TopoJSON, just without
// that particular optimization.
//
// No "transform" (quantization) is written at all - the same "the file
// simply isn't quantized" case importTopojson.pde's own
// topojsonReadTransform()/topojsonDecodeArc() already treat as the normal,
// documented default when a file carries no "transform" member. Every arc
// position is written as a plain, final [lon, lat, alt] triple, exactly
// like exportGeojson.pde's own coordinates - quantizing would only add
// complexity (an integer delta-encoding pass, plus a scale/translate to
// invert it) for a file this exporter has no need to keep small.
//
// Each visible Face/Polyline becomes its own top-level entry under
// "objects" (a bare Polygon/LineString geometry object, not wrapped in a
// GeometryCollection), named "face_N"/"line_N" - the same generated-id
// convention exportCitygml.pde's own `gml:id="face_N"` already uses, and
// for the same structural reason: importTopojson.pde's own
// topojsonHandleNamedObject() applies this import's material/layer
// grouping option exactly ONCE PER TOP-LEVEL "objects" ENTRY (this file's
// own header comment explains why - a GeometryCollection's own nested
// geometries would otherwise all share one enclosing grouping call,
// losing per-Face material/layer distinctions on the way back in), the
// same once-per-Feature granularity exportGeojson.pde's own Features
// array and exportKml.pde's own one-Placemark-per-Face/Polyline already
// give GeoJSON/KML. Each entry's own "properties" carries its source
// Face's/Polyline's material and layer as "material"/"layer" integers,
// the exact same round-trip exportGeojson.pde's own header comment
// documents: typing "material" or "layer" into IMPORT.TOPOJSON's own
// group-property option regroups it exactly the way it was grouped here.
//
// Written with Processing's own saveJSONObject() - the write side of the
// same built-in loadJSONObject() importTopojson.pde already reads with.

void exportTopojson () {

  isFileOperationInProgress = true;

  String topojsonFilename = Folder_Export3D + "/" + ProjectName + ".topojson";

  JSONArray arcs = new JSONArray();
  JSONObject objects = new JSONObject();

  for (int f = 0; f < allFaces.nodes.length; f++) {

    if (allFaces.getVisibility(f) <= 0) continue;
    if (allFaces.nodes[f].length < 3) continue;

    ArrayList<float[]> ring = exportGeojsonBuildClosedWoundRing(allFaces.nodes[f]);
    int arcIndex = exportTopojsonAppendArc(arcs, ring);

    JSONArray ringOfArcIndexes = new JSONArray();
    ringOfArcIndexes.append(arcIndex);
    JSONArray polygonRings = new JSONArray();
    polygonRings.append(ringOfArcIndexes);

    JSONObject geometry = new JSONObject();
    geometry.setString("type", "Polygon");
    geometry.setJSONArray("arcs", polygonRings);
    geometry.setJSONObject("properties", exportTopojsonBuildProperties(allFaces.getMaterial(f), allFaces.getLayer(f)));

    objects.setJSONObject("face_" + f, geometry);
  }

  for (int p = 0; p < allPolylines.nodes.length; p++) {

    if (allPolylines.getVisibility(p) <= 0) continue;
    if (allPolylines.nodes[p].length < 2) continue;

    ArrayList<float[]> linePoints = new ArrayList<float[]>();
    for (int node : allPolylines.nodes[p]) {
      linePoints.add(exportGeojsonPointToLonLatAlt(node));
    }
    if (allPolylines.getClose(p) == 1) {
      linePoints.add(linePoints.get(0));
    }
    int arcIndex = exportTopojsonAppendArc(arcs, linePoints);

    JSONArray lineArcIndexes = new JSONArray();
    lineArcIndexes.append(arcIndex);

    JSONObject geometry = new JSONObject();
    geometry.setString("type", "LineString");
    geometry.setJSONArray("arcs", lineArcIndexes);
    geometry.setJSONObject("properties", exportTopojsonBuildProperties(allPolylines.getMaterial(p), allPolylines.getLayer(p)));

    objects.setJSONObject("line_" + p, geometry);
  }

  JSONObject root = new JSONObject();
  root.setString("type", "Topology");
  root.setJSONObject("objects", objects);
  root.setJSONArray("arcs", arcs);

  saveJSONObject(root, topojsonFilename);

  println("\nFile created:" + topojsonFilename);

  isFileOperationInProgress = false;
}

// Appends one already-[lon,lat,alt] point list as a brand-new arc onto
// the shared top-level "arcs" array, returning the index it landed at -
// every caller above uses this same index immediately afterward to build
// its own one-element "arcs" reference (this file's own header comment,
// "no sharing attempted").
int exportTopojsonAppendArc (JSONArray arcs, ArrayList<float[]> points) {
  JSONArray arc = new JSONArray();
  for (float[] p : points) {
    arc.append(exportGeojsonLonLatAltToJSONArray(p));
  }
  int index = arcs.size();
  arcs.append(arc);
  return index;
}

// Shared "properties" object - the "material"/"layer" round-trip this
// file's own header comment describes, reused as-is by both the Polygon
// and LineString builders above (same meaning as
// exportGeojsonWrapFeature()'s own identical properties object,
// exportGeojson.pde).
JSONObject exportTopojsonBuildProperties (int material, int layer) {
  JSONObject properties = new JSONObject();
  properties.setInt("material", material);
  properties.setInt("layer", layer);
  return properties;
}
