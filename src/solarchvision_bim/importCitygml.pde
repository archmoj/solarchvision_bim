// Minimal, dependency-free importer for a CityGML (https://www.ogc.org/
// standard/citygml/) file - built directly on top of importGeojson.pde's
// own shared core (geojsonEmitPolygonFromRings()/geojsonApplyGrouping()/
// geojsonResolveHeight()/geojsonStripClosingDuplicate()/geojsonNoteSkipped()
// and this same import's own running point/line/face/solid/skipped
// counters - every one of those is reused exactly as GeoJSON/TopoJSON/KML
// import already uses it, not duplicated), the fourth and last format of
// the GIS-import run discussed and agreed after KML shipped ("Any other
// interesting format to support?").
//
// CityGML is plain XML, so this uses Processing's own built-in XML class
// (xmlHelpers.pde/loadXML(), same as importKml.pde/importDae.pde already
// do) - no separate GML-schema/CityGML-schema validation, and, like the
// KML importer, no zipped-archive support (a plain, already-unzipped
// .gml/.xml file only).
//
// UNLIKE KML/DAE (which this app's existing importers already read with a
// single default namespace, so a bare unprefixed tag name - "Placemark",
// "geometry" - already matches via XML.getChild(String)/XML.getName()),
// every real-world CityGML document uses EXPLICIT namespace prefixes
// throughout - "bldg:Building", "gml:Polygon", "gml:posList" - and the
// exact prefix string each file's own author chose for "the building
// module"/"the geometry module" is NOT fixed by the spec (just
// conventional - "bldg"/"gml" are overwhelmingly common, but a file is
// free to declare "xmlns:b=\"...\"" and use "b:Building" instead).
// Processing's own processing.data.XML class was verified (empirically,
// via small standalone test programs against this app's own dist/lib/
// core-4.5.2.jar, outside this app's own test suite) to require an EXACT
// prefixed string for XML.getChild(name)/XML.getString(name) - "bldg:
// Building" matches, "Building" alone does not - and its own
// XML.getLocalName() - which looked like it might return a prefix-
// stripped local name for exactly this situation - was confirmed to
// return null for every element tried, so it isn't usable either. This
// importer therefore never calls getChild(String)/getChildren(String)/
// getString(String) with an assumed prefix at all; every element/attribute
// lookup below goes through citygmlLocalName()/citygmlChild()/
// citygmlChildren()/citygmlAttr() instead, each of which strips everything
// up to and including an element or attribute's own LAST ":" off
// XML.getName()/one of XML.listAttributes()'s own entries before
// comparing - prefix-agnostic, so "bldg:Building"/"b:Building"/a bare
// "Building" (a file with no namespace prefix at all, however unlikely in
// practice) are all recognized as the same thing. XML.listAttributes()
// was also confirmed to mix real semantic attributes (gml:id) in with
// namespace-DECLARATION attributes (xmlns:bldg, xmlns:core, xmlns:gml) -
// citygmlAttr() explicitly skips any attribute whose own name is "xmlns"
// or starts with "xmlns:", so those never get mistaken for a real
// attribute value.
//
// v1 scope, deliberately narrow (the building-stock/solar-shading use
// case this format was originally recommended for, not full CityGML
// coverage - vegetation/transportation/water-body/land-use/bridge/tunnel
// features and anything else this version doesn't look for are simply
// never visited, not even counted as "skipped", the same as this
// importer's own top-level Building/BuildingPart search already only
// looks for those two tag names and nothing else):
//   - Every <bldg:Building> (or <bldg:BuildingPart>, for the unusual case
//     of one appearing with no enclosing Building at all - see
//     citygmlCollectBuildingLikeElements()'s own comment) anywhere in the
//     document is one "named object" - geojsonApplyGrouping() is applied
//     once per Building/BuildingPart found, exactly the same per-object
//     granularity GeoJSON's own per-Feature/KML's own per-Placemark
//     grouping already uses. A BuildingPart NESTED inside an already-
//     found Building is never visited separately - its own geometry is
//     simply included as part of its parent Building's own geometry scan
//     (citygmlHandleBuildingLike()'s own comment) - a real limitation (no
//     separate per-part grouping in this version), documented rather than
//     silently assumed away.
//   - Within one Building/BuildingPart, this importer does NOT attempt to
//     understand CityGML's own Solid/CompositeSurface/MultiSurface/
//     boundedBy/_BoundarySurface wrapping at all (lod1Solid vs lod2Solid
//     vs lod2MultiSurface vs boundedBy>WallSurface>lod2MultiSurface are
//     all, ultimately, just different ways of nesting one or more
//     <gml:Polygon> elements) - it instead recursively collects every
//     <gml:Polygon> found, regardless of how deeply or variously nested,
//     and imports each one directly (citygmlEmitPolygon()'s own comment
//     on hole handling, identical to GeoJSON/KML's own outer+holes
//     bridging via the same shared geojsonEmitPolygonFromRings()).
//   - The one real decision this importer DOES make is extrusion
//     eligibility - whether a flat 2D footprint polygon should become an
//     extruded solid the same way GeoJSON/TopoJSON/KML's own flat
//     polygons already can - and that decision is made PER BUILDING, by
//     container tag name, not per polygon: any lod1/lod2/lod3/lod4 Solid/
//     MultiSurface, or any boundedBy (each _BoundarySurface already
//     carries real, already-3D wall/roof/ground Polygon geometry, never
//     meant to be extruded again on top of itself) found anywhere in a
//     Building/BuildingPart wins outright over a flat LOD0 footprint
//     (lod0FootPrint/lod0RoofEdge/a bare lod0MultiSurface) found
//     alongside it - every Polygon under such a "volumetric" container is
//     imported as a flat face exactly as given (never extruded, since the
//     real 3D shape is already there), and a Building/BuildingPart's own
//     LOD0 footprint is simply ignored once that happens (importing both
//     would double the geometry - one real volumetric building plus an
//     extruded flat box duplicate of the same footprint). Only when NO
//     volumetric/boundedBy container is found at all does this importer
//     fall back to the LOD0 footprint, which IS then extrusion-eligible
//     via this shared core's own geojsonHeightProperty option - and
//     CityGML's own standard <bldg:measuredHeight uom="...">...</bldg:
//     measuredHeight> element is exposed as a synthetic "measuredHeight"
//     property specifically so that option already works out of the box
//     for exactly this LOD0-only case, no new mechanism needed (this
//     file's own citygmlReadProperties() comment).
//   - Degenerate/malformed geometry (a Polygon with no exterior ring, a
//     ring left with fewer than 3 distinct points after closing-duplicate
//     stripping, a posList/pos that doesn't parse) is skipped via this
//     same shared geojsonNoteSkipped()/geojsonImportSkippedReasons running
//     tally, not an error - the same tolerance every other format's own
//     importer in this app already follows.
//
// Coordinate system: unlike GeoJSON/TopoJSON/KML, which are ALWAYS
// longitude/latitude degrees per their own specs (RFC 7946 et al.), a
// real-world CityGML dataset's own <gml:posList>/<gml:pos> values are
// typically ALREADY a local/national PROJECTED coordinate reference system
// in METERS (e.g. a German open-data city model in ETRS89/UTM, values like
// "456789.12 5678901.34 123.45" - not "-8.123 51.456"), not geographic
// WGS84 degrees - the opposite default from the other three formats. So,
// unlike importGeojson.pde's own geojsonLonLatAltToXYZ() (which this
// importer still reuses for the minority case, see below),
// citygmlCoordinatesAreLonLat defaults FALSE: by default, every X/Y/Z
// triple is treated as already-local-planar-meters and just offset/scaled
// by this import's own cx/cy/cz/sx/sy/sz exactly the way importDxf.pde's/
// importObj.pde's own planar-CAD-coordinate imports already do (axis
// order assumed easting-then-northing - "x,y" - the same simple
// convention this app's other planar imports already assume, documented
// rather than chasing per-file axis-order metadata this version doesn't
// read). citygmlShowImportOptionsDialog() (fileSelected.pde) offers a
// checkbox - off by default - to instead route every coordinate through
// the shared geojsonLonLatAltToXYZ() (the same equirectangular local-
// meters projection around this project's own site location GeoJSON/
// TopoJSON/KML already use), for the minority of CityGML files that
// really do carry raw WGS84 lon/lat degrees.

boolean citygmlImportShowOptionsDialog = false;

// See this file's own header comment, "Coordinate system" paragraph, for
// why this defaults false (unlike GeoJSON/TopoJSON/KML, which have no
// equivalent option at all - every one of those is always lon/lat).
boolean citygmlCoordinatesAreLonLat = false;

void import_objects_CITYGML (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  // Same shape as import_objects_GEOJSON()'s/import_objects_KML()'s own
  // identical blocks - see either one's own comment for why this sits
  // here rather than earlier, and what a cancelled dialog does. This one
  // format gets its own dialog (citygmlShowImportOptionsDialog(),
  // fileSelected.pde), not the shared geojsonShowImportOptionsDialog()
  // GeoJSON/TopoJSON/KML all reuse as-is, purely because it has the one
  // extra citygmlCoordinatesAreLonLat checkbox beside the same two shared
  // text fields - the same "one extra option" reason dxfShowImportOptions
  // Dialog()/objShowImportOptionsDialog()/... (fileSelected.pde) each
  // already have their own dialog for too.
  if (citygmlImportShowOptionsDialog) {
    citygmlImportShowOptionsDialog = false;
    if (!citygmlShowImportOptionsDialog()) return;
  }

  println("\nImporting CityGML. Please wait...");
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

  // Same reasoning as importKml.pde's/importDae.pde's own identical
  // try/catch around their own loadXML() calls - a malformed XML document
  // throws straight out of Processing's own XML parser rather than
  // returning null, unlike a missing/unreadable file (which does return
  // null on its own).
  XML root = null;
  try {
    root = loadXML(FileName);
  }
  catch (RuntimeException e) {
    root = null;
  }
  if (root == null) {
    println("\nCityGML import: could not read or parse " + FileName);
    isImportingInProgress = false;
    showArrowCursor();
    return;
  }

  ArrayList<XML> buildings = new ArrayList<XML>();
  citygmlCollectBuildingLikeElements(root, buildings);

  progressBarHeader();
  float printed_Progress = 0;
  boolean aborted = false;
  int totalBuildings = buildings.size();
  float totalBuildingsF = max(1, totalBuildings); // avoid /0 below for a document with no Building/BuildingPart at all

  ProgressWindow importProgressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("\nImporting CityGML") : null;
  if (importProgressWindow != null) importProgressWindow.setVisible(true);

  try {
    for (int f = 0; f < totalBuildings; f++) {
      // Esc, caught by importProgressWindow's own Toolkit-level listener
      // (progressWindow.pde) regardless of which window has focus - same
      // as import_objects_GEOJSON()'s identical check. No rollback on
      // abort - whatever faces were already created from the Buildings
      // read so far are kept, same as any other partial import.
      if ((importProgressWindow != null) && importProgressWindow.abortRequested) {
        echoAbortProgress();
        aborted = true;
        break;
      }

      if (control != USER_AUTO) {
        float Progress = 100 * f / totalBuildingsF;
        int delta = (int) floor(Progress - printed_Progress);
        if (delta >= 1) {
          printProgressBarChunk(delta); // one print() call instead of `delta` calls
          printed_Progress = floor(Progress);
          if (importProgressWindow != null) importProgressWindow.updateFraction(Progress / 100.0f);
        }
      }

      citygmlHandleBuildingLike(buildings.get(f), cx, cy, cz, sx, sy, sz);
    }
  } finally {
    if (importProgressWindow != null) importProgressWindow.dispose();
  }

  if (!aborted) {
    int remaining = (int) floor(100 - printed_Progress);
    printProgressBarChunk(remaining);
    println();

    String summary = "CityGML import complete: " + geojsonFlatFacesImported + " flat face(s), " + geojsonSolidsImported + " extruded solid(s) imported";
    if (geojsonImportSkippedCount > 0) summary += ", " + geojsonImportSkippedCount + " unsupported/malformed item(s) skipped";
    summary += ".";
    println();
    println(summary);
  }

  isImportingInProgress = false;
  showArrowCursor();
}

// Strips everything up to and including an element's own LAST ":" off
// XML.getName() - "bldg:Building" -> "Building", "gml:posList" ->
// "posList", a bare "Building" (no prefix at all) -> "Building" unchanged
// - this file's own header comment on why this manual approach is used
// instead of XML.getLocalName() (confirmed, empirically, to always return
// null). Returns "" (never null) for a pseudo "text node" child
// (getChildren() was confirmed to include these alongside real element
// children - this file's own header comment) or any other element whose
// own getName() is itself null, so every caller below can safely compare
// against a real tag name with a plain .equals()/.startsWith() rather than
// null-checking separately.
String citygmlLocalName (XML el) {
  String name = (el == null) ? null : el.getName();
  if (name == null) return "";
  int colon = name.lastIndexOf(':');
  return (colon < 0) ? name : name.substring(colon + 1);
}

// First direct child of `el` whose own local name (citygmlLocalName()
// above) equals `localName`, prefix-agnostic - or null when none match.
XML citygmlChild (XML el, String localName) {
  if (el == null) return null;
  for (XML child : el.getChildren()) {
    if (citygmlLocalName(child).equals(localName)) return child;
  }
  return null;
}

// Every direct child of `el` whose own local name equals `localName` -
// the prefix-agnostic equivalent of XML.getChildren(String), since that
// built-in method requires an exact (prefixed) string match (this file's
// own header comment).
ArrayList<XML> citygmlChildren (XML el, String localName) {
  ArrayList<XML> result = new ArrayList<XML>();
  if (el == null) return result;
  for (XML child : el.getChildren()) {
    if (citygmlLocalName(child).equals(localName)) result.add(child);
  }
  return result;
}

// Reads an attribute of `el` by its own local name (everything after a
// last ":", same convention as citygmlLocalName() above) - "id" matches
// both a bare "id" attribute and a namespaced "gml:id" one, prefix-
// agnostic, the same reason citygmlChild()/citygmlChildren() exist rather
// than using XML.getChild(String)/XML.getString(String) directly. Returns
// "" (never null) when no matching attribute is present - every caller
// below can test its own length instead of null-checking separately, the
// same convention importKml.pde's own kmlAttr()/importDae.pde's own
// daeAttr() already follow. XML.listAttributes() was confirmed to mix
// real attributes in with namespace-DECLARATION ones ("xmlns",
// "xmlns:bldg", "xmlns:gml", ...) - those are explicitly skipped here so a
// (very unlikely, but possible) attribute actually named "id" is never
// shadowed by, say, "xmlns:id" - not a real CityGML construct, but cheap
// to guard against regardless.
String citygmlAttr (XML el, String localName) {
  if (el == null) return "";
  for (String attrName : el.listAttributes()) {
    if (attrName.equals("xmlns") || attrName.startsWith("xmlns:")) continue;
    int colon = attrName.lastIndexOf(':');
    String local = (colon < 0) ? attrName : attrName.substring(colon + 1);
    if (local.equals(localName)) {
      String v = el.getString(attrName);
      return (v == null) ? "" : v;
    }
  }
  return "";
}

// Same as citygmlAttr() above, parsed as an int - `defaultValue` on a
// missing attribute or one that doesn't parse as a number, the same
// "a bad/missing value quietly falls back rather than crashing" tolerance
// this whole shared core already follows (importGeojson.pde's own
// geojsonResolveHeight()'s own comment).
int citygmlAttrInt (XML el, String localName, int defaultValue) {
  String v = citygmlAttr(el, localName);
  if (v.length() == 0) return defaultValue;
  try {
    return Integer.parseInt(v.trim());
  }
  catch (Exception e) {
    return defaultValue;
  }
}

// Recursively finds every top-level "building-like" element - a <bldg:
// Building> or a bare <bldg:BuildingPart> (the latter normally only
// appears NESTED inside a Building, via <bldg:consistsOfBuildingPart>,
// never as its own independent top-level feature - but this importer
// tolerates the unusual/malformed case of one appearing with no
// enclosing Building at all, same "tolerate more than strictly valid"
// leniency importKml.pde's own XML reading already follows elsewhere).
// Recursion STOPS once a Building/BuildingPart is found (does not look
// for further building-like elements inside it) - this is deliberate, not
// an oversight: a BuildingPart nested inside an already-found Building is
// picked up automatically as part of that Building's own geometry scan
// (citygmlCollectGeometryContainers()'s own comment on why it, in turn,
// recurses INTO a <bldg:consistsOfBuildingPart> wrapper to reach it) -
// visiting it AGAIN here, as its own separate top-level object, would
// double-count its geometry (once as part of the parent Building, once on
// its own).
void citygmlCollectBuildingLikeElements (XML el, ArrayList<XML> out) {
  String local = citygmlLocalName(el);
  if (local.equals("Building") || local.equals("BuildingPart")) { out.add(el); return; }
  for (XML child : el.getChildren()) citygmlCollectBuildingLikeElements(child, out);
}

// One Building (or BuildingPart, found on its own per
// citygmlCollectBuildingLikeElements()'s own comment): reads its own
// gml:id/measuredHeight/function/generic attributes into a synthetic
// "properties" JSONObject (citygmlReadProperties()'s own comment), applies
// this import's own grouping option off it ONCE (mirroring GeoJSON's own
// once-per-Feature/KML's own once-per-Placemark granularity), then
// classifies its own geometry into "volumetric" (real 3D Solid/
// MultiSurface/boundedBy content, found anywhere in its subtree - BuildingParts
// included, since those are never visited separately, see this file's own
// header comment) vs "footprint" (LOD0-only) containers via
// citygmlCollectGeometryContainers() below, and imports every <gml:Polygon>
// found under whichever set actually has content - volumetric strictly
// wins over footprint when both are present (this file's own header
// comment's own "Within one Building..." paragraph explains why).
void citygmlHandleBuildingLike (XML buildingEl, float cx, float cy, float cz, float sx, float sy, float sz) {
  JSONObject properties = citygmlReadProperties(buildingEl);
  geojsonApplyGrouping(properties);

  ArrayList<XML> volumetricContainers = new ArrayList<XML>();
  ArrayList<XML> footprintContainers = new ArrayList<XML>();
  citygmlCollectGeometryContainers(buildingEl, volumetricContainers, footprintContainers);

  ArrayList<XML> containersToUse;
  JSONObject propertiesForExtrusion; // null => citygmlEmitPolygon() below never extrudes, see its own comment
  if (volumetricContainers.size() > 0) {
    containersToUse = volumetricContainers;
    propertiesForExtrusion = null;
  } else if (footprintContainers.size() > 0) {
    containersToUse = footprintContainers;
    propertiesForExtrusion = properties;
  } else {
    geojsonNoteSkipped("Building/BuildingPart with no recognized LOD geometry");
    return;
  }

  boolean foundAnyPolygon = false;
  for (XML container : containersToUse) {
    ArrayList<XML> polygons = new ArrayList<XML>();
    citygmlCollectPolygonsUnder(container, polygons);
    for (XML polygon : polygons) {
      citygmlEmitPolygon(polygon, propertiesForExtrusion, cx, cy, cz, sx, sy, sz);
      foundAnyPolygon = true;
    }
  }
  if (!foundAnyPolygon) geojsonNoteSkipped("Building/BuildingPart with a recognized LOD container but no gml:Polygon inside it");
}

// Walks `el`'s own subtree looking for geometry CONTAINERS - never a bare
// gml:Polygon itself, see citygmlCollectPolygonsUnder() below for that -
// sorting each one found into `volumetricOut` (real, already-3D geometry:
// any lodN Solid/MultiSurface for N in 1..4, or a boundedBy wrapper around
// one or more _BoundarySurface - WallSurface/RoofSurface/GroundSurface/
// ClosureSurface/CeilingSurface/FloorSurface/... - each of which carries
// its own further lodN MultiSurface/Polygon content) or `footprintOut`
// (LOD0-only: lod0FootPrint/lod0RoofEdge/a bare lod0MultiSurface). Once a
// container is classified, this does NOT recurse further INTO it (its own
// Polygon content is collected separately, by citygmlCollectPolygonsUnder()
// once citygmlHandleBuildingLike() has decided which set of containers to
// actually use) - but DOES keep recursing into every OTHER child
// (<bldg:consistsOfBuildingPart><bldg:BuildingPart>... in particular, so a
// nested BuildingPart's own lodN/boundedBy/lod0 containers are found too,
// exactly as if they belonged to the parent Building directly - this
// file's own header comment on why a BuildingPart is never visited as its
// own separate top-level object).
void citygmlCollectGeometryContainers (XML el, ArrayList<XML> volumetricOut, ArrayList<XML> footprintOut) {
  for (XML child : el.getChildren()) {
    String local = citygmlLocalName(child);
    if (local.equals("boundedBy") || (local.startsWith("lod") && local.length() > 3 && Character.isDigit(local.charAt(3)) && !local.startsWith("lod0"))) {
      volumetricOut.add(child);
    } else if (local.startsWith("lod0") && local.length() > 4) {
      footprintOut.add(child);
    } else {
      citygmlCollectGeometryContainers(child, volumetricOut, footprintOut);
    }
  }
}

// Recursively collects every <gml:Polygon> found anywhere under `el`
// (this file's own header comment on why this importer never needs to
// understand Solid/CompositeSurface/MultiSurface/surfaceMember/exterior/
// _BoundarySurface wrapping explicitly - every one of those, however
// nested, ultimately bottoms out in one or more Polygon elements, and
// that's all this importer actually reads). A found Polygon is not
// searched any further (a CityGML Polygon never nests another Polygon
// inside it).
void citygmlCollectPolygonsUnder (XML el, ArrayList<XML> out) {
  for (XML child : el.getChildren()) {
    if (citygmlLocalName(child).equals("Polygon")) { out.add(child); continue; }
    citygmlCollectPolygonsUnder(child, out);
  }
}

// One <gml:Polygon> - its own <gml:exterior><gml:LinearRing> is the outer
// boundary, every <gml:interior><gml:LinearRing> (GML allows more than
// one) a hole, bridged into the outer boundary exactly the same way
// GeoJSON's/TopoJSON's/KML's own Polygon handling already does, via this
// same shared geojsonEmitPolygonFromRings() core. `propertiesOrNull` is
// null for a "volumetric" Polygon (already real 3D geometry - never
// extrude it, since geojsonResolveHeight(null) always returns null,
// exactly the behavior wanted - this file's own header comment on why
// volumetric containers never get extruded again) or the real Building's
// own properties for a "footprint" (LOD0-only) Polygon, where extrusion
// via geojsonHeightProperty/"measuredHeight" IS meant to apply.
void citygmlEmitPolygon (XML polygonEl, JSONObject propertiesOrNull, float cx, float cy, float cz, float sx, float sy, float sz) {
  XML exterior = citygmlChild(polygonEl, "exterior");
  XML outerRing = (exterior != null) ? citygmlChild(exterior, "LinearRing") : null;
  ArrayList<PVector> outer = (outerRing != null) ? citygmlReadRingPoints(outerRing, cx, cy, cz, sx, sy, sz) : null;
  if (outer == null) { geojsonNoteSkipped("Polygon with no exterior/LinearRing"); return; }

  geojsonStripClosingDuplicate(outer); // a GML LinearRing conventionally repeats its own first point as its last, same as a GeoJSON Polygon ring always does
  if (outer.size() < 3) { geojsonNoteSkipped("degenerate polygon ring (fewer than 3 distinct points)"); return; }

  ArrayList<ArrayList<PVector>> holes = new ArrayList<ArrayList<PVector>>();
  for (XML interior : citygmlChildren(polygonEl, "interior")) {
    XML innerRing = citygmlChild(interior, "LinearRing");
    ArrayList<PVector> hole = (innerRing != null) ? citygmlReadRingPoints(innerRing, cx, cy, cz, sx, sy, sz) : null;
    if (hole == null) continue;
    geojsonStripClosingDuplicate(hole);
    if (hole.size() >= 3) holes.add(hole);
  }

  geojsonEmitPolygonFromRings(outer, holes, propertiesOrNull, sz);
}

// Reads one <gml:LinearRing>'s own points, via EITHER a single <gml:
// posList> child (a flat whitespace-separated number list, grouped into
// dims-sized tuples - citygmlParsePosList() below) OR, when no posList is
// present, every <gml:pos> child in order (one tuple's worth of numbers
// each - the less common, but still valid, alternate GML encoding) - or
// null when a LinearRing carries neither. No closing-duplicate handling
// here; see geojsonStripClosingDuplicate() (importGeojson.pde), applied
// by this file's own citygmlEmitPolygon() above.
ArrayList<PVector> citygmlReadRingPoints (XML linearRing, float cx, float cy, float cz, float sx, float sy, float sz) {
  ArrayList<float[]> tuples = new ArrayList<float[]>();

  XML posList = citygmlChild(linearRing, "posList");
  if (posList != null) {
    tuples = citygmlParsePosList(posList);
  } else {
    for (XML posEl : citygmlChildren(linearRing, "pos")) {
      float[] t = citygmlParseOnePos(posEl);
      if (t != null) tuples.add(t);
    }
  }
  if (tuples.size() == 0) return null;

  ArrayList<PVector> pts = new ArrayList<PVector>();
  for (float[] t : tuples) {
    float[] xyz = citygmlCoordToXYZ(t[0], t[1], t[2], cx, cy, cz, sx, sy, sz);
    pts.add(new PVector(xyz[0], xyz[1], xyz[2]));
  }
  return pts;
}

// A <gml:posList>'s own text content is a single flat whitespace/newline-
// separated list of numbers (GML's own convention - no commas at all,
// the reverse of KML's own comma-per-point/whitespace-per-tuple
// convention importKml.pde's own kmlParseCoordinateTuples() reads) -
// grouped into `dims`-sized tuples, `dims` read off this same posList
// element's own "srsDimension" attribute (defaulting to 3 - almost every
// real building dataset is 3D - when absent; this version does not chase
// an ancestor envelope/CRS declaration for it, a documented v1
// limitation, same spirit as this file's own "Coordinate system"
// paragraph above). A trailing partial tuple (token count not a multiple
// of `dims`) is simply dropped rather than guessed at.
ArrayList<float[]> citygmlParsePosList (XML posListEl) {
  ArrayList<float[]> tuples = new ArrayList<float[]>();
  int dims = citygmlAttrInt(posListEl, "srsDimension", 3);
  if (dims < 2) dims = 3; // guard against a malformed/nonsensical srsDimension value

  String content = XML_getContent(posListEl);
  if (content == null) return tuples;

  String[] tokens = splitTokens(content);
  for (int i = 0; i + dims - 1 < tokens.length; i += dims) {
    try {
      float x = Float.parseFloat(tokens[i]);
      float y = Float.parseFloat(tokens[i + 1]);
      float z = (dims > 2) ? Float.parseFloat(tokens[i + 2]) : 0;
      tuples.add(new float[]{x, y, z});
    }
    catch (Exception e) {
      break; // a malformed token misaligns every tuple after it - stop rather than guess
    }
  }
  return tuples;
}

// A single <gml:pos> element's own text content - exactly one tuple's
// worth of whitespace-separated numbers, same srsDimension-driven `dims`
// convention as citygmlParsePosList() above. Returns null on a malformed/
// too-short value rather than throwing.
float[] citygmlParseOnePos (XML posEl) {
  int dims = citygmlAttrInt(posEl, "srsDimension", 3);
  if (dims < 2) dims = 3;

  String content = XML_getContent(posEl);
  if (content == null) return null;

  String[] tokens = splitTokens(content);
  if (tokens.length < dims) return null;
  try {
    float x = Float.parseFloat(tokens[0]);
    float y = Float.parseFloat(tokens[1]);
    float z = (dims > 2) ? Float.parseFloat(tokens[2]) : 0;
    return new float[]{x, y, z};
  }
  catch (Exception e) {
    return null;
  }
}

// Converts one raw (x, y, z) triple read off a posList/pos into this
// app's own local XYZ, per this file's own header comment's "Coordinate
// system" paragraph: already-local-planar-meters by default (axis order
// assumed easting-then-northing, i.e. straight x/y, same as importDxf.
// pde's/importObj.pde's own planar-CAD coordinate handling), or, when
// citygmlCoordinatesAreLonLat is checked, routed through the exact same
// shared geojsonLonLatAltToXYZ() (importGeojson.pde) GeoJSON/TopoJSON/KML
// already use for their own always-lon/lat coordinates (x=lon, y=lat,
// z=alt in that case).
float[] citygmlCoordToXYZ (float x, float y, float z, float cx, float cy, float cz, float sx, float sy, float sz) {
  if (citygmlCoordinatesAreLonLat) return geojsonLonLatAltToXYZ(x, y, z, cx, cy, cz, sx, sy, sz);
  return new float[]{ cx + sx * x, cy + sy * y, cz + sz * z };
}

// Reads a Building/BuildingPart's own gml:id/measuredHeight/function/
// generic (gen:stringAttribute, gen:doubleAttribute, gen:intAttribute)
// attributes into a synthetic "properties" JSONObject carrying the exact
// same shape a GeoJSON Feature's own "properties" already has (mirroring
// importKml.pde's own kmlReadProperties(), same reasoning: so
// geojsonApplyGrouping()/geojsonResolveHeight() both work completely
// unmodified) - every value stored as a String (this shared core's own
// geojsonResolveHeight() already falls back to parsing a String value
// when a direct numeric read fails, so this costs nothing). "gmlId" is
// the natural key to type into the shared geojsonGroupProperty option for
// one group per building (this file's own header comment); "measuredHeight"
// is CityGML's own standard element for exactly the height value this
// shared core's own geojsonHeightProperty option already knows how to use
// for a flat, LOD0-only footprint (this file's own header comment's
// "Within one Building..." paragraph). Generic attributes are read only
// from `buildingEl`'s own DIRECT children (CityGML's own generic-
// attribute module always attaches them directly to the feature, never
// nested inside its geometry, so a shallow scan is both correct and safe
// from accidentally picking up an unrelated "name"/"value" pair from
// somewhere inside the Building's own geometry). Returns null (not an
// empty JSONObject) when none of gml:id/measuredHeight/function/any
// generic attribute is present at all - geojsonApplyGrouping()/
// geojsonResolveHeight() both already treat null properties as "this
// option never applies here", exactly the GeoJSON-Feature-with-no-
// properties case they're already written for.
JSONObject citygmlReadProperties (XML buildingEl) {
  JSONObject properties = null;

  String gmlId = citygmlAttr(buildingEl, "id");
  if (gmlId.length() > 0) {
    properties = new JSONObject();
    properties.setString("gmlId", gmlId);
  }

  XML measuredHeightEl = citygmlChild(buildingEl, "measuredHeight");
  if (measuredHeightEl != null) {
    String v = XML_getContent(measuredHeightEl);
    if (v != null && v.trim().length() > 0) {
      if (properties == null) properties = new JSONObject();
      properties.setString("measuredHeight", v.trim());
    }
  }

  XML functionEl = citygmlChild(buildingEl, "function");
  if (functionEl != null) {
    String v = XML_getContent(functionEl);
    if (v != null && v.trim().length() > 0) {
      if (properties == null) properties = new JSONObject();
      properties.setString("function", v.trim());
    }
  }

  for (XML child : buildingEl.getChildren()) {
    String local = citygmlLocalName(child);
    if (local.equals("stringAttribute") || local.equals("doubleAttribute") || local.equals("intAttribute")) {
      String name = citygmlAttr(child, "name");
      if (name.length() == 0) continue;
      XML valueEl = citygmlChild(child, "value");
      String value = (valueEl != null) ? XML_getContent(valueEl) : null;
      if (value == null || value.trim().length() == 0) continue;
      if (properties == null) properties = new JSONObject();
      properties.setString(name, value.trim());
    }
  }

  return properties;
}
