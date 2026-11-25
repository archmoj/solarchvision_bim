// Minimal, dependency-free exporter for a CityGML
// (https://www.ogc.org/standards/citygml) file - the write-side
// counterpart to importCitygml.pde. Unlike exportKml.pde (built directly
// on exportGeojson.pde's own shared "GIS export core"), this one shares
// only the general per-feature iteration/visibility-skip pattern and the
// XML-writing helpers (XML_setContent()/XML_setString(), parseXML()+
// setName()+saveXML() - the exact same convention exportKml.pde and
// saveProject.pde's own buildProjectSnapshot() already use) - CityGML's
// own coordinate and scope rules differ from GeoJSON/KML's enough, in
// both directions, that forcing a shared numeric helper onto it would be
// artificial rather than a genuine simplification:
//
//   - Coordinates are NEVER reverse-projected to longitude/latitude -
//     every vertex is written exactly as this app's own allPoints
//     already stores it (plain local XYZ meters), the mirror image of
//     importCitygml.pde's own default (citygmlCoordinatesAreLonLat =
//     false): CityGML is routinely used with a local/projected CRS
//     already, unlike GeoJSON/KML which mandate real longitude/latitude
//     (see exportGeojson.pde's own "Coordinates" comment on why THOSE
//     two have no planar option at all) - so this exporter offers no
//     lon/lat mode either, the same "one correct default, no toggle"
//     choice exportGeojson.pde/exportKml.pde already make, just facing
//     the opposite default.
//   - No ring is ever rewound. exportGeojson.pde's/exportKml.pde's own
//     shoelace-based counterclockwise rewinding is a purely 2D notion
//     (every GeoJSON/KML polygon lies in the horizontal lon/lat plane by
//     definition) - a CityGML Building's own Polygons routinely include
//     vertical wall surfaces and every other orientation a real
//     building's faces can have, where a flat XY-plane signed area is
//     meaningless (often ~0). Every ring is written exactly as stored,
//     the same "no winding assumption" stance importCitygml.pde's own
//     citygmlEmitPolygon() already takes on the way in (see that
//     function's own comment).
//   - Polylines are never exported at all. importCitygml.pde's own v1
//     scope is Polygon geometry only - "finds every <gml:Polygon>...
//     regardless of wrapping" (that file's own header comment) - it has
//     no LineString/Curve reading of any kind, unlike importGeojson.pde/
//     importKml.pde. Writing Polylines here would produce a file
//     IMPORT.CITYGML could never read back, the opposite of every other
//     exporter in this GIS export tier, so this scope is narrowed to
//     match the importer's own exactly, rather than inventing a non-
//     standard CityGML construct for a line this app's own importer
//     would just skip.
//
// Scope - the rest is the same restraint exportGeojson.pde's own "Scope"
// comment already explains, facing CityGML's own vocabulary:
//   - every allFaces entry -> one <bldg:Building>, its one ring written
//     as a single <bldg:lod2MultiSurface>/<gml:MultiSurface>/
//     <gml:surfaceMember>/<gml:Polygon>/<gml:exterior>/<gml:LinearRing>/
//     <gml:posList> - lod2 (not lod1Solid) because this app keeps no
//     "these N faces are really one closed solid" link between faces any
//     more than it keeps one for a hole or an extruded solid's original
//     footprint+height (exportGeojson.pde's own "Scope" comment again) -
//     a single arbitrary Face is exactly the "a set of surfaces with no
//     particular topological relationship" case lod2MultiSurface/
//     boundedBy is meant for, not the fully closed-volume case lod1Solid
//     implies. "lod2" (not "lod1") is an arbitrary but harmless label
//     choice here - citygmlCollectGeometryContainers() classifies ANY
//     lod[1-4]*MultiSurface as "volumetric" (real, already-3D geometry,
//     never re-extruded) identically, so the exact digit makes no
//     difference to the round trip.
//   - a Face whose own getVisibility() is 0 (hidden) is skipped - the
//     same filter exportGeojson.pde/exportKml.pde already apply.
//
// Properties: every <bldg:Building> carries its own source Face's
// material and layer as <gen:intAttribute name="material">/
// <gen:intAttribute name="layer"> generic-attribute entries (each an
// <gen:intAttribute name="..."><gen:value>N</gen:value></gen:intAttribute>
// child) - the exact shape importCitygml.pde's own citygmlReadProperties()
// already reads back (its own "stringAttribute"/"doubleAttribute"/
// "intAttribute" branch), so re-importing this same file and typing
// "material" or "layer" into IMPORT.CITYGML's own group-property option
// regroups it exactly the way it was grouped here - the same round trip
// exportGeojson.pde's own "Properties" comment documents for GeoJSON,
// reused unchanged in spirit if not in code. Each Building's own gml:id
// is a simple generated "face_N" (N = that Face's own index in
// allFaces), which also round-trips back into a synthetic "gmlId"
// property on import (citygmlReadProperties()'s own first branch).

void exportCitygml () {

  // See isFileOperationInProgress's own comment (globalFunctions.pde)
  // for why - bare statement (this function has only the one exit point
  // below, so nothing further to guard); cleared at this function's own
  // end.
  isFileOperationInProgress = true;

  String citygmlFilename = Folder_Export3D + "/" + ProjectName + ".gml";

  XML cityModel = parseXML("<?xml version='1.0' encoding='UTF-8'?>" + char(13) + "<empty>" + char(13) + "</empty>");
  cityModel.setName("CityModel");
  XML_setString(cityModel, "xmlns", "http://www.opengis.net/citygml/2.0");
  XML_setString(cityModel, "xmlns:bldg", "http://www.opengis.net/citygml/building/2.0");
  XML_setString(cityModel, "xmlns:gml", "http://www.opengis.net/gml");
  XML_setString(cityModel, "xmlns:gen", "http://www.opengis.net/citygml/generics/2.0");

  for (int f = 0; f < allFaces.nodes.length; f++) {

    if (allFaces.getVisibility(f) <= 0) continue;
    if (allFaces.nodes[f].length < 3) continue;

    XML cityObjectMember = cityModel.addChild("cityObjectMember");
    XML building = cityObjectMember.addChild("bldg:Building");
    XML_setString(building, "gml:id", "face_" + f);

    exportCitygmlAddGenericAttribute(building, "material", allFaces.getMaterial(f));
    exportCitygmlAddGenericAttribute(building, "layer", allFaces.getLayer(f));

    XML multiSurfaceWrapper = building.addChild("bldg:lod2MultiSurface");
    XML multiSurface = multiSurfaceWrapper.addChild("gml:MultiSurface");
    XML surfaceMember = multiSurface.addChild("gml:surfaceMember");
    XML polygon = surfaceMember.addChild("gml:Polygon");
    XML exterior = polygon.addChild("gml:exterior");
    XML linearRing = exterior.addChild("gml:LinearRing");
    XML posList = linearRing.addChild("gml:posList");
    XML_setString(posList, "srsDimension", "3");
    XML_setContent(posList, exportCitygmlFormatPosList(allFaces.nodes[f]));
  }

  saveXML(cityModel, citygmlFilename);

  println("\nFile created:" + citygmlFilename);

  isFileOperationInProgress = false;
}

// <gen:intAttribute name="..."><gen:value>N</gen:value></gen:intAttribute>
// - see this file's own header comment, "Properties".
void exportCitygmlAddGenericAttribute (XML building, String name, int value) {
  XML attr = building.addChild("gen:intAttribute");
  XML_setString(attr, "name", name);
  XML valueEl = attr.addChild("gen:value");
  XML_setContent(valueEl, str(value));
}

// One allFaces node loop -> a whitespace-separated "x y z x y z ..."
// gml:posList string, the ring's own closing duplicate repeated at the
// end (a GML LinearRing conventionally closes its own loop - see
// importCitygml.pde's own citygmlEmitPolygon() comment on reading one
// back with geojsonStripClosingDuplicate()) - no reverse projection, no
// rewinding (see this file's own header comment, "Coordinates"/
// "Winding").
String exportCitygmlFormatPosList (int[] faceNodes) {
  StringBuilder sb = new StringBuilder();
  for (int i = 0; i <= faceNodes.length; i++) { // <= : repeats index 0 at the end, closing the ring
    int node = faceNodes[i % faceNodes.length];
    if (i > 0) sb.append(" ");
    sb.append(allPoints.getX(node)).append(" ").append(allPoints.getY(node)).append(" ").append(allPoints.getZ(node));
  }
  return sb.toString();
}
