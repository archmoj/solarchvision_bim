// Minimal, dependency-free importer for a gbXML (Green Building XML)
// file - the open, XML-based schema most energy-modeling tools (Revit's
// own "Export gbXML", OpenStudio, Trane TRACE, IES-VE, cove.tool, ...)
// read and write for a building's envelope geometry. Like import_objects_
// IFC.pde, this is a BIM interchange format importer that plugs into the
// same File > Import menu, the same IMPORT.* script-command family, and
// the same shared Materials.pde palette - see that file's own header
// comment for the fuller "why hand-roll this instead of a library"
// story, which applies here too: gbXML is plain, openly published XML
// (http://www.gbxml.org), read here with Processing's own built-in XML
// class the same way import_objects_DAE.pde already reads COLLADA.
//
// gbXML's own geometry model is far simpler than IFC's: every
// <CartesianPoint> a Surface's own geometry uses is already an absolute
// WORLD coordinate - there's no IfcLocalPlacement-style chain of nested,
// relative placements to walk and compose first. That's what lets this
// importer skip IFC's own IfcFrame/placement machinery entirely and go
// straight from parsed points to a face.
//
// Supported geometry:
//   - <Surface surfaceType="..."><PlanarGeometry><PolyLoop><CartesianPoint>...:
//     the general case - an arbitrary n-gon read straight off the file's
//     own point list, one app-native face per Surface, the same "keep
//     the file's own n-gon, don't triangulate" choice import_objects_
//     IFC.pde's own IfcFace/IfcPolyLoop reading makes (see
//     gbxmlPlanarGeometryPoints() below).
//   - <Surface surfaceType="..."><RectangularGeometry>: a Surface
//     described by its own Azimuth/Tilt/Width/Height plus one
//     CartesianPoint (its lower-left corner), read whenever a Surface
//     has no (or too few) PlanarGeometry points - common in early-stage/
//     simplified gbXML exports that skip the full polygon. See
//     gbxmlRectangularGeometryPoints() below for exactly how Azimuth/
//     Tilt are turned into the rectangle's own plane.
//   - <Surface>'s own child <Opening windowType="..."> elements - a
//     window, skylight or door cut into that Surface - each imported as
//     its own separate face (not subtracted from the host Surface's
//     own face - see the known-limitation note below), the same
//     PlanarGeometry/PolyLoop reading as a Surface's own geometry.
//   - <Campus><Location><CADModelAzimuth>/<Latitude>/<Longitude>: this
//     file's own analogues of import_objects_IFC.pde's TrueNorth
//     rotation and RefLatitude/RefLongitude station relocation - see
//     gbxmlImportOrient/gbxmlImportRelocate below, and
//     ifcRotateImportedModelToTrueNorth() (import_objects_IFC.pde),
//     reused as-is here rather than reimplemented, since that function
//     never actually depended on anything IFC-specific (just an angle
//     and two "where did this import's own geometry start" counts).
//   - <gbXML lengthUnit="..."> - Meters (assumed when absent, same
//     "undeclared unit, assume already metric" fallback import_objects_
//     IFC.pde's own ifcDetectLengthUnitScale() makes), Feet, Inches,
//     Centimeters or Millimeters - converted to metres the same way
//     every other importer in this app works, applied to every
//     coordinate/Width/Height this importer reads. See
//     gbxmlUnitScale() below.
//   - surfaceType/windowType -> material: a handful of gbXML's own
//     enumerated values are matched against the exact same shared
//     Materials.pde palette import_objects_IFC.pde's own IFC_MATERIAL_*
//     constants already index into (these constants, like every other
//     top-level .pde declaration in this sketch, are visible here too -
//     Processing merges every tab into one class) - see
//     gbxmlMaterialForSurfaceType()/gbxmlMaterialForWindowType() below.
//     A Surface/Opening whose type doesn't match anything falls back to
//     the caller's own m/1-8 cycling choice, exactly the priority order
//     import_objects_IFC.pde's own material-choice block already uses.
//
// Known, deliberate limitations - the same "note it here, surface it in
// the post-import summary, don't silently guess" philosophy import_
// objects_IFC.pde's own header comment follows:
//   - An Opening is imported as its own, separate, overlapping face -
//     not actually subtracted from its host Surface's own face. Same
//     practical result as import_objects_IFC.pde's own uncut-opening
//     handling (IfcBooleanResult/IfcBooleanClippingResult - see that
//     file's header): the wall/roof still shows up solid, window and
//     all, rather than with a true hole cut for it. A general polygon
//     boolean is out of scope for this importer too.
//   - <Opening><RectangularGeometry>'s own <CartesianPoint> is, per the
//     gbXML schema, in the HOST SURFACE's own local 2D (Width/Height)
//     plane coordinates - not the same absolute world coordinates a
//     Surface's own RectangularGeometry/PlanarGeometry use. Resolving
//     that correctly would mean re-deriving the host Surface's own
//     Width/Height basis vectors (see gbxmlRectangularGeometryPoints()
//     below) and offsetting into them - not attempted in this version;
//     an Opening with only this kind of geometry is counted as skipped
//     rather than placed in the wrong spot.
//   - A Surface whose own surfaceType is "Air" - a modeled boundary
//     between two spaces with no physical construction of its own, the
//     closest gbXML equivalent to IFC's own IfcVirtualElement - is
//     skipped on purpose, the same reasoning import_objects_IFC.pde's
//     own ifcNonGeometryProductTypes gives for IfcVirtualElement/
//     IfcOpeningElement. An Opening whose own windowType is "Air" (an
//     interior doorway modeled with no actual door) is skipped the same
//     way.
//   - <Space> geometry (a room/zone's own 2D footprint, used for area/
//     volume calculations) is not imported - gbXML's own Surfaces
//     already carry every piece of real building-envelope geometry a
//     Space's own footprint would just duplicate, the same role IFC's
//     own walls/slabs/roofs play relative to IfcSpace; unlike
//     import_objects_IFC.pde, which does import an interior IfcSpace's
//     own room volume by default (see that file's own IFC_MATERIAL_
//     INDOOR_SPACE), gbXML's own <Space> is a flat footprint, not a
//     volume, so there's no equivalent "room boundary" geometry here
//     worth drawing.
//   - gbXML's own <CADModelAzimuth> is read and applied exactly the way
//     import_objects_IFC.pde's own ifcTrueNorthAngleDegrees() documents
//     its own TrueNorth reading: taken directly as a clockwise-about-Z
//     rotation (Rotate3D.selection's own the_Vector=2 convention, same
//     as that function), which is the gbXML schema's own documented
//     meaning ("the number of degrees clockwise from true north that
//     the model's own +Y axis is situated") - not independently
//     verified against a real gbXML export the way several of import_
//     objects_IFC.pde's own assumptions are noted as being, so flagged
//     here with the same honesty.
//   - Every length this importer reads assumes a single, file-wide
//     lengthUnit (the gbXML root element's own declared one) - gbXML
//     has no per-value unit override the way some formats do, so
//     there's nothing more granular to read here regardless.

boolean gbxmlImportShowOptionsDialog = false;

// Whether to rotate the whole imported model, around the world origin,
// to correct for the project's own CADModelAzimuth - on by default, the
// same default import_objects_IFC.pde's own IFC_IMPORT_NORTH gives its
// TrueNorth rotation, and for the same reason (see that constant's own
// comment).
final boolean GBXML_IMPORT_NORTH = true;
boolean gbxmlImportOrient = GBXML_IMPORT_NORTH;

// Whether to navigate the app's own "station" (STATION.latitude/
// longitude) to the file's own <Location><Latitude>/<Longitude> once
// loading finishes - on by default, same reasoning as import_objects_
// IFC.pde's own IFC_IMPORT_GOTO_LATLON.
final boolean GBXML_IMPORT_GOTO_LATLON = true;
boolean gbxmlImportRelocate = GBXML_IMPORT_GOTO_LATLON;

// Running counters for the post-import summary (and for tests) - reset
// at the top of every import_objects_GBXML() call, same shape as
// import_objects_IFC.pde's own ifcImport* counters.
int gbxmlImportSurfaceCount = 0;
int gbxmlImportOpeningCount = 0;
int gbxmlImportFaceCount = 0;
int gbxmlImportSkippedCount = 0;
// Surfaces/Openings excluded because their own surfaceType/windowType is
// "Air" (see this file's own header comment) - counted separately from
// gbxmlImportSkippedCount, since this is a deliberate exclusion (no
// physical construction to import), not something unsupported.
int gbxmlImportAirBoundarySkippedCount = 0;
HashMap<String, Integer> gbxmlImportSkippedReasons = new HashMap<String, Integer>();
float gbxmlImportNorthRotationAngle = 0;
float[] gbxmlImportGotoLatLon = null;

// The multiplier that converts a raw length value read from the file
// into metres - see gbxmlUnitScale() below. Reset to 1 (assume metres)
// at the top of every import_objects_GBXML() call, same as import_
// objects_IFC.pde's own ifcLengthUnitScale.
float gbxmlLengthUnitScale = 1;

void gbxmlNoteSkipped (String reason) {
  gbxmlImportSkippedCount++;
  Integer prior = gbxmlImportSkippedReasons.get(reason);
  gbxmlImportSkippedReasons.put(reason, (prior == null ? 0 : prior) + 1);
}

// ---------------------------------------------------------------------
// Small XML helpers - gbXML's own child-element text content (e.g.
// <Coordinate>12.5</Coordinate>, <Azimuth>180</Azimuth>) is read through
// XML_getContent() (xml_helpers.pde, already shared with import_objects_
// DAE.pde/load_project.pde/...); attribute values (surfaceType,
// windowType, lengthUnit, id, ...) are read through XML.getString(name)
// directly, Processing's own documented "attribute" accessor - the same
// split import_objects_DAE.pde's own daeAttr() already relies on.
// ---------------------------------------------------------------------

// Every descendant of `el` (at any depth, not just direct children)
// named `tagName`, in document order - used instead of assuming a fixed
// nesting (Surface always directly under Campus, Location always
// directly under Campus, ...), since real exports vary and a flat
// recursive scan is simple, correct, and (real gbXML files being
// thousands, not millions, of elements) cheap enough, the same "don't
// over-engineer for a scale this format doesn't reach" choice import_
// objects_DAE.pde's own daeFindById() makes for COLLADA.
void gbxmlFindAll (XML el, String tagName, ArrayList<XML> out) {
  if (el == null) return;
  for (XML child : el.getChildren()) {
    if (tagName.equals(child.getName())) out.add(child);
    gbxmlFindAll(child, tagName, out);
  }
}

// A child element's own text content, parsed as a float - 0 (or `def`,
// for the "Azimuth 0, not 'missing'" cases below) when the child is
// absent or unparsable, rather than throwing partway through a Surface's
// own geometry.
float gbxmlChildFloat (XML parent, String tag, float def) {
  if (parent == null) return def;
  XML child = parent.getChild(tag);
  if (child == null) return def;
  String text = XML_getContent(child);
  if (text == null) return def;
  try {
    return Float.parseFloat(text.trim());
  }
  catch (Exception ex) {
    return def;
  }
}

float gbxmlFloatContent (XML el) {
  if (el == null) return 0;
  String text = XML_getContent(el);
  if (text == null) return 0;
  try {
    return Float.parseFloat(text.trim());
  }
  catch (Exception ex) {
    return 0;
  }
}

// ---------------------------------------------------------------------
// Units
// ---------------------------------------------------------------------

// The multiplier that converts a raw length value in the file's own
// declared lengthUnit into metres. A missing/unrecognized lengthUnit is
// read as-is (scale 1, "assume already metric") rather than guessed at
// further - see this file's own header comment.
float gbxmlUnitScale (String lengthUnit) {
  if (lengthUnit == null) return 1;
  String u = lengthUnit.trim();
  if (u.equalsIgnoreCase("Meters") || u.equalsIgnoreCase("Metres")) return 1;
  if (u.equalsIgnoreCase("Centimeters") || u.equalsIgnoreCase("Centimetres")) return 0.01;
  if (u.equalsIgnoreCase("Millimeters") || u.equalsIgnoreCase("Millimetres")) return 0.001;
  if (u.equalsIgnoreCase("Feet")) return 0.3048;
  if (u.equalsIgnoreCase("Inches")) return 0.0254;
  return 1;
}

// ---------------------------------------------------------------------
// Geometry
// ---------------------------------------------------------------------

// <CartesianPoint><Coordinate>x</Coordinate><Coordinate>y</Coordinate>
// <Coordinate>z</Coordinate></CartesianPoint> - already an absolute
// world point (unlike IFC's own IfcCartesianPoint, which is local to
// whatever IfcLocalPlacement chain its own product carries - see this
// file's own header comment). A 2D point (only two <Coordinate>
// children - gbXML allows this for some 2D-only elements, though not
// the 3D ones this importer actually reads) comes back with z=0.
PVector gbxmlCartesianPoint (XML pointEl) {
  if (pointEl == null) return new PVector(0, 0, 0);
  XML[] coords = pointEl.getChildren("Coordinate");
  float x = coords.length > 0 ? gbxmlFloatContent(coords[0]) : 0;
  float y = coords.length > 1 ? gbxmlFloatContent(coords[1]) : 0;
  float z = coords.length > 2 ? gbxmlFloatContent(coords[2]) : 0;
  return new PVector(x * gbxmlLengthUnitScale, y * gbxmlLengthUnitScale, z * gbxmlLengthUnitScale);
}

// <PlanarGeometry><PolyLoop><CartesianPoint>...</PolyLoop></PlanarGeometry> -
// the general case, an arbitrary n-gon read straight off the file's own
// point list. Returns an empty list (not null) when `planarGeometryEl`
// itself is null or carries no usable PolyLoop, so callers can check
// `.size() < 3` uniformly rather than null-checking first.
ArrayList<PVector> gbxmlPlanarGeometryPoints (XML planarGeometryEl) {
  ArrayList<PVector> pts = new ArrayList<PVector>();
  if (planarGeometryEl == null) return pts;
  XML polyLoop = planarGeometryEl.getChild("PolyLoop");
  if (polyLoop == null) return pts;
  for (XML pointEl : polyLoop.getChildren("CartesianPoint")) {
    pts.add(gbxmlCartesianPoint(pointEl));
  }
  return pts;
}

// <RectangularGeometry><Azimuth/><CartesianPoint/><Tilt/><Width/><Height/></RectangularGeometry> -
// a Surface described by its own plane (Azimuth/Tilt) and size (Width/
// Height) rather than an explicit point list; `CartesianPoint` is the
// rectangle's own lower-left corner, in absolute world coordinates (the
// same "already absolute" story as gbxmlCartesianPoint() above - this
// is the SURFACE-level RectangularGeometry; Opening's own, different,
// host-plane-local version is NOT read by this function - see this
// file's own header comment on that limitation).
//
// Azimuth is a compass bearing in degrees (0=north, measured clockwise -
// the same convention this app's own SolarImpacts.R uses, and the same
// one import_objects_IFC.pde's own ifcTrueNorthAngleDegrees() reads
// TrueNorth against); Tilt is degrees from horizontal (0 = facing
// straight up, as a flat roof's own outward normal does; 90 = vertical,
// a wall facing its own Azimuth direction; 180 = facing straight down).
// From these: the surface's own outward normal, "Width" direction
// (horizontal, perpendicular to the vertical plane containing the
// normal) and "Height" direction (the remaining in-plane axis,
// perpendicular to both) are built as an orthonormal triple, then the
// rectangle's own four corners are walked out from the origin corner
// along Width then Height - counterclockwise seen from outside the
// surface, matching PolyLoop's own winding convention elsewhere in this
// app. Returns null (not a guess) when there's no CartesianPoint to
// anchor the rectangle to, or Width/Height is missing or non-positive.
ArrayList<PVector> gbxmlRectangularGeometryPoints (XML rectEl) {
  if (rectEl == null) return null;

  XML cartesianPointEl = rectEl.getChild("CartesianPoint");
  if (cartesianPointEl == null) return null;

  float width = gbxmlChildFloat(rectEl, "Width", 0) * gbxmlLengthUnitScale;
  float height = gbxmlChildFloat(rectEl, "Height", 0) * gbxmlLengthUnitScale;
  if (width <= 0 || height <= 0) return null;

  float azimuthDeg = gbxmlChildFloat(rectEl, "Azimuth", 0);
  float tiltDeg = gbxmlChildFloat(rectEl, "Tilt", 90);

  float az = radians(azimuthDeg);
  float t = radians(tiltDeg);

  PVector normal = new PVector(sin(t) * sin(az), sin(t) * cos(az), cos(t));
  PVector widthDir = new PVector(cos(az), -sin(az), 0);
  PVector heightDir = widthDir.cross(normal);
  if (heightDir.mag() < 0.0001) {
    // Degenerate (Width/Height direction colinear with the normal) -
    // fall back to world +Z, the same "arbitrary axis" fix import_
    // objects_IFC.pde's own ifcAxis2Placement3DToFrame() uses for its
    // own equivalent degeneracy.
    heightDir = new PVector(0, 0, 1);
  }
  heightDir.normalize();

  PVector origin = gbxmlCartesianPoint(cartesianPointEl);
  PVector alongWidth = PVector.add(origin, PVector.mult(widthDir, width));
  PVector farCorner = PVector.add(alongWidth, PVector.mult(heightDir, height));
  PVector alongHeight = PVector.add(origin, PVector.mult(heightDir, height));

  ArrayList<PVector> pts = new ArrayList<PVector>();
  pts.add(origin);
  pts.add(alongWidth);
  pts.add(farCorner);
  pts.add(alongHeight);
  return pts;
}

// This Surface's/Opening's own geometry - PlanarGeometry/PolyLoop
// preferred (the precise, explicit polygon some exporters write
// alongside a simplified RectangularGeometry too), falling back to
// RectangularGeometry only when PlanarGeometry gave fewer than 3 usable
// points.
ArrayList<PVector> gbxmlGeometryPoints (XML ownerEl) {
  ArrayList<PVector> pts = gbxmlPlanarGeometryPoints(ownerEl.getChild("PlanarGeometry"));
  if (pts.size() >= 3) return pts;

  ArrayList<PVector> rectPts = gbxmlRectangularGeometryPoints(ownerEl.getChild("RectangularGeometry"));
  if (rectPts != null) return rectPts;

  return pts; // whatever PlanarGeometry gave (possibly empty) - caller decides what "too few" means
}

// One face, built directly from already-world points - unlike import_
// objects_IFC.pde's own ifcEmitFace()/ifcQueuePoint()/ifcQueueFace(),
// which stage everything and bulk-flush at the very end (that file's
// own comment explains why: a single BIM import can mean hundreds of
// thousands of faces, where allPoints.create()/allFaces.create()'s own
// O(1)-amortized-but-still-per-call array growth adds up). A gbXML
// file's own Surfaces/Openings number in the tens to low thousands, not
// hundreds of thousands - building-envelope geometry, not a fully
// tessellated BIM model - so creating straight into allPoints/allFaces
// per face, the same direct way import_objects_DAE.pde's own
// daeCreatePoint()/allFaces.create(face) calls already do, is simple
// and plenty fast here.
void gbxmlEmitFace (ArrayList<PVector> pts, int material, float cx, float cy, float cz, float sx, float sy, float sz) {
  // Drop consecutive duplicate points (zero-length edges), and a
  // trailing point that just repeats the first (an explicitly closed
  // loop), before deciding whether there's still a real polygon left -
  // the exact same cleanup import_objects_IFC.pde's own ifcEmitFace()
  // does for the same reason.
  ArrayList<PVector> cleaned = new ArrayList<PVector>();
  for (PVector p : pts) {
    if (cleaned.size() == 0 || PVector.dist(cleaned.get(cleaned.size() - 1), p) > 0.00001) {
      cleaned.add(p);
    }
  }
  if (cleaned.size() > 1 && PVector.dist(cleaned.get(0), cleaned.get(cleaned.size() - 1)) < 0.00001) {
    cleaned.remove(cleaned.size() - 1);
  }
  if (cleaned.size() < 3) {
    gbxmlNoteSkipped("degenerate polygon (fewer than 3 distinct points)");
    return;
  }

  int[] faceNodes = new int[cleaned.size()];
  for (int i = 0; i < cleaned.size(); i++) {
    PVector p = cleaned.get(i);
    faceNodes[i] = allPoints.create(cx + sx * p.x, cy + sy * p.y, cz + sz * p.z);
  }

  // current_Tessellation/current_Layer/current_Visibility/current_Weight/
  // current_Closed are set once, up front, by import_objects_GBXML()
  // itself (they're constant for the whole import - only the material
  // varies per Surface/Opening); only current_Material is set here,
  // immediately before the one allFaces.create(...) call that actually
  // reads it, the same "current_Material right before create()" shape
  // import_objects_DAE.pde's/import_objects_DXF.pde's own per-primitive
  // material cycling already uses.
  current_Material = material;
  allFaces.create(faceNodes);
  gbxmlImportFaceCount++;
}

// ---------------------------------------------------------------------
// Material assignment: surfaceType/windowType matched, by exact
// (case-insensitive) name, against gbXML's own enumerated values -
// simpler than import_objects_IFC.pde's own free-text IfcMaterial-name
// keyword matching (ifcMaterialNameToConstant()), since surfaceType/
// windowType are themselves a closed, schema-defined enumeration rather
// than free text. Returns null (not a guess) for anything else, so the
// caller falls back to its own m/1-8 cycling choice, the same priority
// import_objects_IFC.pde's own material-choice block already gives an
// unmatched product.
// ---------------------------------------------------------------------

Integer gbxmlMaterialForSurfaceType (String surfaceType) {
  if (surfaceType == null) return null;
  String t = surfaceType.trim();

  // Floor/slab-like surfaces, and an underground (foundation) wall - a
  // coordination-stage gbXML file very often has no construction/
  // material of its own assigned yet, and an unmatched one just cycling
  // through 1-8 like an ordinary wall reads as arbitrary, not
  // structural - the same reasoning import_objects_IFC.pde's own
  // ifcStructuralProductTypes/ifcLooksLikeAFloor() default to
  // IFC_MATERIAL_CONCRETE for exactly this reason.
  if (t.equalsIgnoreCase("InteriorFloor") || t.equalsIgnoreCase("ExposedFloor")
    || t.equalsIgnoreCase("SlabOnGrade") || t.equalsIgnoreCase("UndergroundSlab")
    || t.equalsIgnoreCase("RaisedFloor") || t.equalsIgnoreCase("UndergroundWall")) {
    return IFC_MATERIAL_CONCRETE;
  }

  // A shading device (an overhang, fin, louvered canopy, ...) - gbXML's
  // own dedicated surfaceType for this, the same default import_
  // objects_IFC.pde's own ifcLooksLikeAShadingDevice() gives
  // IfcShadingDevice/a Name-matched shading element (most real shading
  // hardware is aluminum or painted steel).
  if (t.equalsIgnoreCase("Shade")) return IFC_MATERIAL_STEEL;

  // Curtain-wall glazing panels - mostly glass by definition, the same
  // "easy to add to this set" case import_objects_IFC.pde's own
  // ifcGlassProductTypes comment names IfcCurtainWall as an example of.
  if (t.equalsIgnoreCase("CurtainWall")) return IFC_MATERIAL_GLASS;

  return null; // ExteriorWall, InteriorWall, Roof, Ceiling, ...: no forced default, same as an ordinary IFC wall/window
}

Integer gbxmlMaterialForWindowType (String windowType) {
  if (windowType == null) return null;
  String t = windowType.trim();

  if (t.equalsIgnoreCase("FixedWindow") || t.equalsIgnoreCase("OperableWindow")
    || t.equalsIgnoreCase("FixedSkylight") || t.equalsIgnoreCase("OperableSkylight")) {
    // Always glass, the same unconditional way import_objects_IFC.pde's
    // own ifcGlassProductTypes always draws an IfcWindow with
    // IFC_MATERIAL_GLASS regardless of m or any other material choice.
    return IFC_MATERIAL_GLASS;
  }

  return null; // SlidingDoor/NonSlidingDoor, or an unrecognized/unlabeled opening: reads as its host Surface's own material instead (see import_objects_GBXML()'s own Opening loop)
}

// ---------------------------------------------------------------------
// Site: <Campus><Location><Latitude>/<Longitude>/<CADModelAzimuth> -
// gbXML's own, much simpler analogues of import_objects_IFC.pde's own
// IfcSite.RefLatitude/RefLongitude (ifcSiteLatLonDecimalDegrees()) and
// IfcGeometricRepresentationContext.TrueNorth
// (ifcTrueNorthAngleDegrees()) - already plain decimal degrees here,
// nothing like IFC's own IfcCompoundPlaneAngleMeasure to convert.
// ---------------------------------------------------------------------

// {latitude, longitude} in decimal degrees, rounded to 4 decimal places
// (roughly 11m at the equator - only ever meant to get the station to
// the right part of the world, the same precision import_objects_
// IFC.pde's own ifcSiteLatLonDecimalDegrees() settles for) - or null
// when the file's own Location has no usable Latitude/Longitude at all.
float[] gbxmlSiteLatLonDecimalDegrees (XML location) {
  if (location == null) return null;
  XML latEl = location.getChild("Latitude");
  XML lonEl = location.getChild("Longitude");
  if (latEl == null || lonEl == null) return null;

  float lat = gbxmlFloatContent(latEl);
  float lon = gbxmlFloatContent(lonEl);
  return new float[] { round(lat * 10000) / 10000.0f, round(lon * 10000) / 10000.0f };
}

// ---------------------------------------------------------------------
// Entry point - mirrors import_objects_IFC(FileName, m, tes, lyr, vsb,
// wgt, clz, cx, cy, cz, sx, sy, sz)'s own signature, including the
// m == -1 "auto-cycle through 8 materials" convention (there, once per
// imported IfcProduct; here, once per imported Surface).
//
// Unlike import_objects_IFC(), this does NOT call model_changed() itself
// at the end - it adds faces straight into allFaces/allPoints the same
// direct way import_objects_OBJ()/import_objects_GLB()/import_objects_
// STL()/import_objects_DXF()/import_objects_PLY()/import_objects_DAE()
// already do, every one of which leaves that one call to its own
// fileSelected.pde caller (_fileSelected_ImportGbxml(), below) instead -
// see any of those six's own _fileSelected_Import*() comment for why.
// ---------------------------------------------------------------------
void import_objects_GBXML (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  // Same shape as import_objects_OBJ()'s/import_objects_DAE()'s/...
  // own identical blocks - see any one's own comment, or
  // ifcImportShowOptionsDialog's (import_objects_IFC.pde), for why this
  // sits here rather than earlier, and what a cancelled dialog does.
  if (gbxmlImportShowOptionsDialog) {
    gbxmlImportShowOptionsDialog = false;
    if (!gbxmlShowImportOptionsDialog()) return;
  }

  println("Importing gbXML. Please wait...");
  showWaitCursor();

  progressBarHeader();

  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  gbxmlImportSurfaceCount = 0;
  gbxmlImportOpeningCount = 0;
  gbxmlImportFaceCount = 0;
  gbxmlImportSkippedCount = 0;
  gbxmlImportAirBoundarySkippedCount = 0;
  gbxmlImportSkippedReasons = new HashMap<String, Integer>();
  gbxmlImportNorthRotationAngle = 0;
  gbxmlImportGotoLatLon = null;
  gbxmlLengthUnitScale = 1;

  current_Tessellation = tes;
  current_Layer = lyr;
  current_Visibility = vsb;
  current_Weight = wgt;
  current_Closed = clz;

  XML root = null;
  try {
    root = loadXML(FileName);
  }
  catch (RuntimeException e) {
    println("\ngbXML import: could not parse '" + FileName + "' (" + e.getMessage() + ")");
  }
  if (root == null) {
    println("\ngbXML import: could not read '" + FileName + "'");
    showArrowCursor();
    return;
  }

  gbxmlLengthUnitScale = gbxmlUnitScale(root.getString("lengthUnit"));

  ArrayList<XML> locations = new ArrayList<XML>();
  gbxmlFindAll(root, "Location", locations);
  XML location = locations.size() > 0 ? locations.get(0) : null;

  // Computed up front, same as import_objects_IFC.pde's own
  // ifcImportNorthRotationAngle - left at 0 (meaning "don't rotate"),
  // without even reading the file's own Location, whenever the toggle
  // itself is off.
  gbxmlImportNorthRotationAngle = gbxmlImportOrient ? gbxmlChildFloat(location, "CADModelAzimuth", 0) : 0;

  ArrayList<XML> surfaces = new ArrayList<XML>();
  gbxmlFindAll(root, "Surface", surfaces);

  // Captured before any geometry is added, so
  // ifcRotateImportedModelToTrueNorth() (import_objects_IFC.pde, reused
  // as-is - see this file's own header comment) can later select
  // exactly this import's own faces/model2Ds, not any that were already
  // in the scene.
  int baseFaceCount = allFaces.nodes.length;
  int baseModel2DCount = allModel2Ds.num;

  int effectiveMaterial = (m == -1) ? 0 : m;

  float Progress = 0;
  float printed_Progress = 0;
  StringBuilder barBuffer = new StringBuilder();
  float totalSurfaces = max(surfaces.size(), 1);

  ProgressWindow importProgressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("Importing gbXML") : null;
  if (importProgressWindow != null) importProgressWindow.setVisible(true);

  for (int s = 0; s < surfaces.size(); s++) {
    if (control != USER_AUTO) {
      Progress = 100 * s / totalSurfaces;
      int delta = (int) floor(Progress - printed_Progress);
      if (delta >= 1) {
        barBuffer.setLength(0);
        for (int c = 0; c < delta; c++) {
          barBuffer.append('█');
        }
        print(barBuffer.toString());
        printed_Progress = floor(Progress);
        if (importProgressWindow != null) importProgressWindow.updateFraction(Progress / 100.0f);
      }
    }

    XML surfaceEl = surfaces.get(s);
    String surfaceType = surfaceEl.getString("surfaceType");

    if (surfaceType != null && surfaceType.equalsIgnoreCase("Air")) {
      // A space-to-space boundary with no physical construction of its
      // own - see this file's own header comment.
      gbxmlImportAirBoundarySkippedCount++;
      continue;
    }

    ArrayList<PVector> pts = gbxmlGeometryPoints(surfaceEl);
    if (pts.size() < 3) {
      gbxmlNoteSkipped("Surface with no usable PlanarGeometry/RectangularGeometry");
      continue;
    }

    // The new group has to exist before any face is created into it -
    // Faces.create() stamps every face it creates into allGroups' own
    // current (last) group, the same reasoning import_objects_IFC.pde's
    // own identical block gives.
    if (addToLastGroup == false) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    Integer matchedMaterial = gbxmlMaterialForSurfaceType(surfaceType);
    int nextEffectiveMaterial = effectiveMaterial;
    int materialForThisSurface;
    if (matchedMaterial != null) {
      materialForThisSurface = matchedMaterial;
    } else {
      if (m == -1) nextEffectiveMaterial = 1 + (effectiveMaterial % 8);
      materialForThisSurface = nextEffectiveMaterial;
    }

    gbxmlEmitFace(pts, materialForThisSurface, cx, cy, cz, sx, sy, sz);
    effectiveMaterial = nextEffectiveMaterial;
    gbxmlImportSurfaceCount++;

    for (XML openingEl : surfaceEl.getChildren("Opening")) {
      String windowType = openingEl.getString("windowType");

      if (windowType != null && windowType.equalsIgnoreCase("Air")) {
        // An interior doorway/passage modeled with no actual door - no
        // physical construction to import, same reasoning as a Surface
        // whose own surfaceType is "Air" above.
        gbxmlImportAirBoundarySkippedCount++;
        continue;
      }

      ArrayList<PVector> openingPts = gbxmlPlanarGeometryPoints(openingEl.getChild("PlanarGeometry"));
      if (openingPts.size() < 3) {
        if (openingEl.getChild("RectangularGeometry") != null) {
          gbxmlNoteSkipped("Opening with only a host-plane-local RectangularGeometry (not supported - see this file's header)");
        } else {
          gbxmlNoteSkipped("Opening with no usable PlanarGeometry");
        }
        continue;
      }

      Integer openingMaterial = gbxmlMaterialForWindowType(windowType);
      int materialForThisOpening = (openingMaterial != null) ? openingMaterial : materialForThisSurface;

      gbxmlEmitFace(openingPts, materialForThisOpening, cx, cy, cz, sx, sy, sz);
      gbxmlImportOpeningCount++;
    }
  }

  if (importProgressWindow != null) importProgressWindow.dispose();

  // Only meaningful once the geometry it rotates actually exists in
  // allFaces/allModel2Ds - see import_objects_IFC.pde's own identical
  // ordering/comment on ifcRotateImportedModelToTrueNorth() for why
  // this runs here, after every Surface/Opening has already been
  // created, rather than earlier alongside where
  // gbxmlImportNorthRotationAngle was itself computed.
  if (gbxmlImportNorthRotationAngle != 0) {
    ifcRotateImportedModelToTrueNorth(gbxmlImportNorthRotationAngle, baseFaceCount, baseModel2DCount);
  }

  int remaining = (int) floor(100 - printed_Progress);
  barBuffer.setLength(0);
  for (int c = 0; c < remaining; c++) {
    barBuffer.append('█');
  }
  print(barBuffer.toString());
  println();

  String summary = "gbXML import complete: " + gbxmlImportSurfaceCount + " surface(s), " + gbxmlImportOpeningCount + " opening(s) imported (" + gbxmlImportFaceCount + " face(s) total)";
  if (gbxmlLengthUnitScale != 1) summary += " (converted from the file's own length unit, scale " + gbxmlLengthUnitScale + " to metres)";
  if (gbxmlImportAirBoundarySkippedCount > 0) summary += ", " + gbxmlImportAirBoundarySkippedCount + " air/virtual boundary(ies) not imported (no physical construction)";
  if (gbxmlImportSkippedCount > 0) summary += ", " + gbxmlImportSkippedCount + " unsupported/malformed item(s) skipped";
  if (gbxmlImportNorthRotationAngle != 0) summary += ", rotated " + gbxmlImportNorthRotationAngle + " degree(s) around the origin to match the project's true north";
  summary += ".";
  println();
  println(summary);

  // Last step of loading a gbXML file, after the summary above - see
  // import_objects_IFC.pde's own identical-in-spirit
  // IFC_IMPORT_GOTO_LATLON comment for why this runs at all. Left
  // alone - the station stays wherever it already was - whenever the
  // file gives no usable Latitude/Longitude.
  gbxmlImportGotoLatLon = gbxmlImportRelocate ? gbxmlSiteLatLonDecimalDegrees(location) : null;
  if (gbxmlImportGotoLatLon != null) {
    println();
    println("Now navigating to latitude " + gbxmlImportGotoLatLon[0] + ", longitude " + gbxmlImportGotoLatLon[1] + "...");
    __SETLATLON__(new String[] { "SETLATLON", "" + gbxmlImportGotoLatLon[0], "" + gbxmlImportGotoLatLon[1] });
  }

  showArrowCursor();
}
