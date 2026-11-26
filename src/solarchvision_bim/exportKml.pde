// Minimal, dependency-free exporter for a KML (https://developers.google.
// com/kml/documentation/kmlreference) file - built directly on top of
// exportGeojson.pde's own shared "GIS export core"
// (exportGeojsonPointToLonLatAlt()/exportGeojsonBuildClosedWoundRing(),
// reused exactly as-is, not duplicated), the write-side mirror of
// importKml.pde's own build order ("built directly on top of
// importGeojson.pde's own shared core").
//
// Scope - the mirror image of importKml.pde's own "Polygon -> one flat
// n-gon Face" etc., narrowed the exact same way exportGeojson.pde's own
// header comment already explains for GeoJSON export (holes and extruded
// solids are never reconstructed, no standalone Point Placemarks are ever
// written, a hidden Face/Polyline is skipped) - every one of those
// reasons applies here unchanged, since the source data (allFaces/
// allPolylines/allPoints) is the exact same app-side storage either way:
//   - every allFaces entry -> one Placemark with a Polygon geometry, its
//     ring written as a single <outerBoundaryIs>/<LinearRing> (no
//     <innerBoundaryIs> is ever written - see exportGeojson.pde's own
//     "Scope" comment on why holes aren't reconstructed).
//   - every allPolylines entry -> one Placemark with a LineString
//     geometry, closed (first coordinate repeated at the end) only when
//     getClose() says so.
//   - no standalone Point Placemarks.
//
// Coordinates: reverse-projected through the same Functions.
// convert_XY2lonlat() exportGeojson.pde's own exportGeojsonPointToLonLatAlt()
// already calls - reused here as-is, not reimplemented. A KML
// <coordinates> element's own text content is whitespace-separated
// "lon,lat,alt" tuples (the reverse punctuation of GeoJSON's own nested-
// array shape, but the same numbers) - see importKml.pde's own
// kmlParseCoordinateTuples() comment for that convention on the way in;
// kmlFormatCoordinates() below is its exact write-side mirror.
//
// Winding: every Polygon ring reuses exportGeojson.pde's own
// exportGeojsonBuildClosedWoundRing() unchanged, so it is rewound
// counterclockwise under the exact same RFC 7946 section 3.1.6
// convention GeoJSON export already follows - KML itself (unlike
// GeoJSON) has no winding requirement of its own, but there is no reason
// to wind a shared ring two different ways for two sibling exporters
// built from the same geometry.
//
// Properties: every Placemark carries its own source Face's/Polyline's
// material and layer as <ExtendedData><Data name="material">/
// <Data name="layer"> entries - the exact shape importKml.pde's own
// kmlReadProperties() already reads back (a <Data name="..."><value>...
// </value></Data> child), so re-importing this same file and typing
// "material" or "layer" into IMPORT.KML's own group-property option
// regroups it exactly the way it was grouped here - the same round trip
// exportGeojson.pde's own "Properties" comment already documents for
// GeoJSON, reused unchanged. Every other key that source's own
// extraParams holds (unless User3D.exporterExtraParams, user3D.pde, is off)
// becomes its own <Data> entry alongside them - see
// exportKmlAddExtendedData()'s own comment, further down.
//
// Written with Processing's own XML class and saveXML() - the same
// "parseXML() an empty root, then setName()/addChild() it into shape"
// convention saveProject.pde's own buildProjectSnapshot() already uses
// for this app's own project file, and XML_setContent()/XML_setString()
// (xmlHelpers.pde) for attributes/text content, not a hand-rolled XML
// writer - no new infrastructure, the same restraint exportGeojson.pde's
// own "don't invent infrastructure a built-in already provides" choice
// already takes for JSON.

void exportKml () {

  // See isFileOperationInProgress's own comment (globalFunctions.pde)
  // for why - bare statement (this function has only the one exit point
  // below, so nothing further to guard); cleared at this function's own
  // end.
  isFileOperationInProgress = true;

  String kmlFilename = Folder_Export3D + "/" + ProjectName + ".kml";

  XML kml = parseXML("<?xml version='1.0' encoding='UTF-8'?>" + char(13) + "<empty>" + char(13) + "</empty>");
  kml.setName("kml");
  XML_setString(kml, "xmlns", "http://www.opengis.net/kml/2.2");

  XML document = kml.addChild("Document");

  for (int f = 0; f < allFaces.nodes.length; f++) {

    if (allFaces.getVisibility(f) <= 0) continue;
    if (allFaces.nodes[f].length < 3) continue;

    XML placemark = document.addChild("Placemark");
    exportKmlAddExtendedData(placemark, allFaces.getMaterial(f), allFaces.getLayer(f), allFaces.getExtraParams(f));

    ArrayList<float[]> ring = exportGeojsonBuildClosedWoundRing(allFaces.nodes[f]);

    XML polygon = placemark.addChild("Polygon");
    XML outerBoundary = polygon.addChild("outerBoundaryIs");
    XML linearRing = outerBoundary.addChild("LinearRing");
    XML coordinates = linearRing.addChild("coordinates");
    XML_setContent(coordinates, exportKmlFormatCoordinates(ring));
  }

  for (int p = 0; p < allPolylines.nodes.length; p++) {

    if (allPolylines.getVisibility(p) <= 0) continue;
    if (allPolylines.nodes[p].length < 2) continue;

    XML placemark = document.addChild("Placemark");
    exportKmlAddExtendedData(placemark, allPolylines.getMaterial(p), allPolylines.getLayer(p), allPolylines.getExtraParams(p));

    ArrayList<float[]> pts = new ArrayList<float[]>();
    for (int node : allPolylines.nodes[p]) {
      pts.add(exportGeojsonPointToLonLatAlt(node));
    }
    if (allPolylines.getClose(p) == 1) {
      pts.add(pts.get(0));
    }

    XML lineString = placemark.addChild("LineString");
    XML coordinates = lineString.addChild("coordinates");
    XML_setContent(coordinates, exportKmlFormatCoordinates(pts));
  }

  saveXML(kml, kmlFilename);

  println("\nFile created:" + kmlFilename);

  isFileOperationInProgress = false;
}

// <ExtendedData><Data name="material"><value>N</value></Data>
// <Data name="layer"><value>N</value></Data>...</ExtendedData> - the
// exact shape importKml.pde's own kmlReadProperties() already reads back
// (see this file's own header comment, "Properties"). One <Data> entry
// per key of the SAME merged material/layer/extraParams bag
// exportGeojson.pde's own exportBuildProperties() already builds for
// GeoJSON/TopoJSON - reused directly here rather than duplicated, so
// material/layer and a source Face's/Polyline's own extraParams (if any)
// are merged, and a key collision between them resolved, exactly the
// same way for every GIS export format in this app. kmlReadProperties()
// always reads a <Data> entry's own value back as a plain String
// regardless of what it looks like, so every value here is written via
// exportJsonValueToDisplayString() (exportGeojson.pde) rather than a
// per-type writer.
void exportKmlAddExtendedData (XML placemark, int material, int layer, String extraParams) {
  JSONObject properties = exportBuildProperties(material, layer, extraParams);
  XML extendedData = placemark.addChild("ExtendedData");
  for (Object keyObj : properties.keys()) {
    String key = (String) keyObj;
    exportKmlAddDataEntry(extendedData, key, exportJsonValueToDisplayString(properties, key));
  }
}

void exportKmlAddDataEntry (XML extendedData, String name, String value) {
  XML data = extendedData.addChild("Data");
  XML_setString(data, "name", name);
  XML valueEl = data.addChild("value");
  XML_setContent(valueEl, value);
}

// [lon, lat, alt] points -> one whitespace-separated "lon,lat,alt ..."
// string - the exact write-side mirror of importKml.pde's own
// kmlParseCoordinateTuples() (see this file's own header comment,
// "Coordinates").
String exportKmlFormatCoordinates (ArrayList<float[]> points) {
  StringBuilder sb = new StringBuilder();
  for (int i = 0; i < points.size(); i++) {
    if (i > 0) sb.append(" ");
    float[] p = points.get(i);
    sb.append(p[0]).append(",").append(p[1]).append(",").append(p[2]);
  }
  return sb.toString();
}
