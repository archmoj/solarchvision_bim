// Minimal, dependency-free parser/importer for a STEP (ISO-10303-21)
// ".ifc" file - the plain-text exchange format BIM software (Revit,
// ArchiCAD, Blender BIM, ...) writes when a user exports "IFC".
//
// Unlike import_objects_OBJ.pde, which only ever sees raw triangles
// (most OBJ exporters triangulate everything on the way out), IFC's own
// geometry is genuinely n-gon: a wall face is a quad, not two triangles
// glued together. So every face found here is built as one n-gon - the
// same point-list-to-single-face shape Create3D.add_Mesh() (the routine
// behind the "Mesh"/"Mesh2".."Mesh6" command-line commands) builds for a
// single call - so a quad wall panel stays one 4-sided face instead of
// being split into two triangles. See ifcEmitFace()'s own comment for
// why the point/face data this builds is queued and bulk-flushed into
// allPoints/allFaces rather than calling Create3D.add_Mesh(), or even
// allPoints.create()/allFaces.create(), directly.
//
// Supported geometry (a practical subset, not the full EXPRESS schema):
//   - IfcFacetedBrep / IfcShellBasedSurfaceModel: (Open|Closed)Shell ->
//     IfcFace -> IfcFaceOuterBound -> IfcPolyLoop -> IfcCartesianPoint.
//     This is IFC2X3's and IFC4's most common straight-edged B-rep path.
//   - IfcPolygonalFaceSet / IfcTriangulatedFaceSet / IfcTriangulatedIrregularNetwork
//     (IFC4 tessellated geometry - the last one's a TIN, the usual
//     shape of a site's own topography/terrain surface) backed by a
//     shared IfcCartesianPointList3D.
//   - IfcExtrudedAreaSolid over IfcRectangleProfileDef or
//     IfcArbitraryClosedProfileDef(IfcPolyline or IfcIndexedPolyCurve) -
//     very common for walls, slabs, roofs and curtain-wall panels
//     modelled parametrically instead of as an explicit Brep.
//     IfcIndexedPolyCurve - a shared point list plus an OPTIONAL
//     Segments list of straight/arc runs through it - is read as a
//     straight-edged profile when Segments is omitted (an implicit
//     polyline through every point in order; the overwhelmingly common
//     case checked against a real export) or made up entirely of
//     IfcLineIndex segments; an IfcArcIndex segment (an actual circular
//     arc) still isn't evaluated, same as any other curved profile. See
//     ifcIndexedPolyCurvePoints() below. Each side panel is built as a
//     single 4-point face (the same shape Create3D.add_Mesh4()/"Mesh4"
//     would build by hand), plus two n-gon end caps.
//   - IfcLocalPlacement chains (including IfcAxis2Placement3D's
//     Axis/RefDirection) are walked and composed into one world
//     placement per product.
//   - IfcWindow is always drawn with Materials.pde's translucent "glass"
//     material (9), independently of whatever m was passed in - see
//     ifcGlassProductTypes below. Every other product's own associated
//     IfcMaterial (IfcRelAssociatesMaterial, by way of
//     IfcMaterialLayerSetUsage, IfcMaterialProfileSetUsage,
//     IfcMaterialConstituentSet or a plain IfcMaterial) is read and its
//     name matched, keyword-style, against Materials.pde's concrete/
//     steel/timber/masonry/insulation/MEP/earth colors (the
//     IFC_MATERIAL_* constants below); a product with no match falls
//     back to m/the normal 1-8 cycle, same as before this existed.
//   - Every length read from the file (point/direction coordinates,
//     profile dimensions, extrusion depth) is converted into metres
//     using the project's own declared length unit
//     (IfcProject.UnitsInContext), so a file authored in millimetres,
//     centimetres, feet, inches, etc. still imports at the right real-
//     world scale - see ifcDetectLengthUnitScale() below. A file with no
//     declared length unit at all is read as-is, assumed already metric.
//   - IfcSite imports its own topography/terrain surface, if it has one,
//     the same way as any other product - unlike IfcProject/IfcBuilding/
//     IfcBuildingStorey, it's not excluded just for being a spatial-
//     structure type (see ifcNonGeometryProductTypes below). It also
//     defaults to IFC_MATERIAL_EARTH when the file names no material for
//     it (see ifcTopographyProductTypes below) - geometry is imported as
//     ordinary Faces, the same as a wall or slab, not resampled onto the
//     app's own regular-grid Terrain.Mesh.
//   - A product whose Name or ObjectType names it as a tree (IFC has no
//     single dedicated entity for one) is placed as one of the app's own
//     native 2D billboard trees (allModel2Ds, "Add 2D-Trees on Land"'s
//     own kind) at that product's placement origin, with a height
//     parsed from that same Name/ObjectType text when one is written
//     there (e.g. "Tree - Deciduous - Generic : 30'"), or a fixed
//     default otherwise - rather than importing whatever (often just a
//     low-detail box or cylinder) geometry the product itself carries.
//     See ifcLooksLikeATree() below.
//   - A human/entourage/scale-figure reference model - IfcActor, an
//     IfcBuildingElementProxy with ObjectType "Human"/"Entourage"/
//     "Scale Figure", a Name/ObjectType word match, an Archvision RPC
//     ("Rich Photorealistic Content") human figure - Name/ObjectType
//     "RPC Male:..."/"RPC Female:...", a common Revit entourage plugin
//     - or a product on an IfcPresentationLayerAssignment named
//     A-PROP-HUMN/A-PROP-ENTS (the AIA layer-naming standard) - is
//     placed the same way, as one of the app's own native 2D people
//     (allModel2Ds, "PEOPLE") at a fixed height (2.5), instead of
//     importing whatever detailed mesh it carries (typically through an
//     IfcMappedItem). See ifcLooksLikeAPerson() below.
//   - A PV panel, solar collector or solar hybrid panel - whether the
//     file models it as IfcSolarDevice (IFC4.3) or, like a tree, as a
//     generic product whose Name/ObjectType just says so - imports its
//     own real geometry as Faces, same as any other product, but always
//     with material 0 (IFC_MATERIAL_SOLAR; see that constant's own
//     comment), regardless of m or any material the file associates
//     with it. See ifcLooksLikeASolarDevice() below.
//   - A fixed sun-shading element - a louver, brise-soleil, shutter,
//     jalousie or awning - whether the file models it as
//     IfcShadingDevice (IFC4) or, like a tree, as a generic product
//     whose Name/ObjectType just says so, imports its own real geometry
//     as Faces, same as any other product, and is never excluded the
//     way furniture/small objects can be, regardless of
//     ifcImportFurniture: unlike most of what this importer treats
//     specially, a shading device's geometry is directly relevant to
//     this app's own purpose (it exists to cast a shadow), not just
//     cosmetic. Defaults to IFC_MATERIAL_STEEL (most are aluminum or
//     painted steel) only when the file names no material of its own -
//     see ifcLooksLikeAShadingDevice() below.
//   - A green roof, green wall or garden/lawn - again, no single
//     dedicated IFC entity for any of these, so caught the same way as
//     a tree, by a Name/ObjectType word match ("green", "garden",
//     "grass", "lawn", "vegetation") - imports its own real geometry as
//     Faces and defaults to IFC_MATERIAL_VEGETATION, a natural grass
//     green, when the file names no material for it. See
//     ifcLooksLikeVegetation() below.
//   - A floor (an IfcSlab whose PredefinedType is .FLOOR., or a
//     Name/ObjectType word match for files that don't set that
//     attribute) and an exposed structural member - IfcColumn, IfcBeam,
//     IfcMember - default to IFC_MATERIAL_CONCRETE when the file names
//     no material for them, since a coordination-stage model very often
//     doesn't have one assigned yet. See ifcStructuralProductTypes and
//     ifcLooksLikeAFloor() below.
//   - A swimming pool's own water surface - a Name/ObjectType word
//     match again ("pool", "pools", "swimming") - defaults to
//     IFC_MATERIAL_WATER, a translucent pool blue, when the file names
//     no material for it. A pool is commonly modeled as an IfcSpace (a
//     water volume) rather than a solid element, so this is the one
//     case besides a tree where a product is imported without needing
//     ifcLooksLikeImportableProduct()'s own Representation requirement
//     - see ifcLooksLikeAPool() below and its own use in
//     import_objects_IFC()'s product-collection loop.
//   - IfcMappedItem - a "family/type" instance, the same shared geometry
//     reused, positioned and scaled differently at every place it's
//     used; commonly how a door, window or piece of furniture is
//     exported - resolves its MappingSource's own geometry through its
//     MappingTarget transform (see ifcCartesianTransformToFrame() and
//     ifcProcessMappedItem() below), assuming the IfcRepresentationMap's
//     own MappingOrigin is the identity placement; see that function's
//     own comment, and the limitation below, for the (uncommon) case
//     where that assumption doesn't hold.
//   - IfcBooleanResult/IfcBooleanClippingResult - typically how a door/
//     window opening is cut into a wall or slab - imports only
//     FirstOperand (almost always the wall/slab's own solid), not a
//     true boolean evaluation of the cut itself (see the limitation
//     below): the element still shows up as real geometry instead of
//     being skipped outright, just without its opening. Counted in
//     ifcImportUncutOpeningCount, separately from
//     ifcImportSkippedCount, since this is real, imported geometry,
//     not something left out of the import.
//
// Known, deliberate limitations - noted here rather than silently
// guessed around, and surfaced to the person importing via the
// post-import summary line / ifcImportSkippedReasons:
//   - Inner face/profile boundaries ("holes" - IfcFaceBound,
//     IfcIndexedPolygonalFaceWithVoids) ARE cut out, via PolygonHoles'
//     own mergeHolesIntoOuterLoop() (see PolygonHoles.pde) bridging each
//     hole into its own face's outer boundary - but only when a face's
//     own geometry already carries the hole explicitly, as a named
//     inner loop in the source file, the way a Tessellation body
//     usually does. This is NOT the same thing as evaluating a true
//     Boolean cut (see the next bullet): a wall whose only opening
//     geometry is an IfcBooleanClippingResult subtracting an
//     IfcOpeningElement's own solid still imports uncut, counted in
//     ifcImportUncutOpeningCount - there is no inner loop anywhere in
//     that representation for this to find and bridge.
//   - Curved edges/surfaces (IfcCircleProfileDef, IfcBSplineCurve,
//     IfcAdvancedBrep's curved faces, swept/revolved solids other than
//     a straight extrusion) are not evaluated; items that need them are
//     skipped and counted, not approximated.
//   - Boolean operations are not truly evaluated (see the bullet above):
//     computing a robust, general 3D solid difference is a serious
//     computational-geometry undertaking in its own right, well out of
//     scope for an importer like this one. Only the uncut FirstOperand
//     is imported, so a wall or slab with a window/door opening shows
//     up solid, without the opening cut out as a hole.
//   - Furniture (IfcFurnishingElement, IfcFurniture,
//     IfcSystemFurnitureElement), a sanitary/MEP-terminal fixture
//     (IfcFlowTerminal, IfcSanitaryTerminal - a toilet, sink, bathtub,
//     ...) and a Name/ObjectType-matched kitchen appliance or cabinet/
//     storage item isn't imported at all while ifcImportFurniture
//     (below) is false, its default - deliberate, not a gap, and
//     user-facing via the IFC import options dialog (see
//     ifcShowImportOptionsDialog() in fileSelected.pde); see
//     IFC_IMPORT_FURNITURE's own comment for more. The
//     same toggle also excludes a small (under
//     IFC_SMALL_OBJECT_MAX_DIMENSION on every axis) IfcBuildingElementProxy
//     - a book, a cup, a vase, other loose tabletop decor - while
//     leaving a larger one (an elevator, a parked-car entourage prop,
//     ...) alone, since that type is IFC's own catch-all and isn't
//     reliably "small" (or kitchen/cabinet-named) on its own; see that
//     constant's own and ifcApplianceOrCabinetNameWords's own comments
//     for how both were checked against a real export.
//   - An IfcMappedItem's IfcRepresentationMap.MappingOrigin is assumed
//     to be the identity placement rather than inverted and composed in
//     (see that bullet above) - true for the large majority of real-
//     world exporters, but a file whose MappingOrigin genuinely isn't
//     identity will see that block's instances offset by whatever that
//     placement was, not flagged or counted as skipped (there's no way
//     to tell from the result alone that this assumption didn't hold).
//   - A conversion-based length unit (e.g. 'foot', 'inch') is assumed
//     to be defined directly against the bare SI metre, rather than
//     having its own UnitComponent resolved recursively - true for the
//     large majority of real-world files. IfcDerivedUnit (a length unit
//     expressed as a formula over other units, rare in practice) isn't
//     resolved at all.
//   - Only the plain-text STEP exchange format is read - not ifcXML or
//     zipped ifcZIP.
//   - IfcSpace, IfcOpeningElement and IfcVirtualElement are skipped on
//     purpose even when they carry geometry: they represent voids/
//     program area, not building fabric.

// ---------------------------------------------------------------------
// One parsed STEP entity instance: "#id=TYPE(attr0,attr1,...);"
// ---------------------------------------------------------------------
class StepEntity {
  int id;
  String type; // always upper-cased
  String[] attrs; // raw, still-encoded attribute tokens (top-level split only)
}

// A right-handed orthonormal placement: world = origin + lx*xAxis +
// ly*yAxis + lz*zAxis. Mirrors what an IfcAxis2Placement3D establishes,
// and what composing an IfcLocalPlacement chain produces.
class IfcFrame {
  PVector origin, xAxis, yAxis, zAxis;
  IfcFrame (PVector o, PVector x, PVector y, PVector z) {
    origin = o; xAxis = x; yAxis = y; zAxis = z;
  }
  PVector toWorldPoint (float lx, float ly, float lz) {
    return PVector.add(origin, toWorldVector(lx, ly, lz));
  }
  PVector toWorldPoint (PVector local) {
    return toWorldPoint(local.x, local.y, local.z);
  }
  PVector toWorldVector (float lx, float ly, float lz) {
    PVector v = PVector.mult(xAxis, lx);
    v.add(PVector.mult(yAxis, ly));
    v.add(PVector.mult(zAxis, lz));
    return v;
  }
  PVector toWorldVector (PVector local) {
    return toWorldVector(local.x, local.y, local.z);
  }
}

IfcFrame ifcIdentityFrame () {
  return new IfcFrame(new PVector(0, 0, 0), new PVector(1, 0, 0), new PVector(0, 1, 0), new PVector(0, 0, 1));
}

IfcFrame ifcComposeFrame (IfcFrame parent, IfcFrame child) {
  return new IfcFrame(
    parent.toWorldPoint(child.origin),
    parent.toWorldVector(child.xAxis),
    parent.toWorldVector(child.yAxis),
    parent.toWorldVector(child.zAxis)
    );
}

// Product types that are intentionally never imported as geometry, even
// when they carry a Representation: spatial-structure containers (no
// building fabric of their own) and voids/program area (see the file
// header's "Known limitations"). IfcSite is deliberately NOT in this
// set - unlike IfcProject/IfcBuilding/IfcBuildingStorey, a real IFC
// site often does carry its own topography/terrain surface as its
// Representation (a toposurface, typically an IfcTriangulatedFaceSet
// or IfcTriangulatedIrregularNetwork - see
// ifcProcessRepresentationItem()); an IfcSite with no Representation at
// all is already skipped for the ordinary reason
// (ifcLooksLikeImportableProduct() requires one), so there's nothing
// extra to guard against by excluding the type outright.
HashSet<String> ifcNonGeometryProductTypes = new HashSet<String>(Arrays.asList(
  "IFCPROJECT", "IFCBUILDING", "IFCBUILDINGSTOREY",
  "IFCSPACE", "IFCOPENINGELEMENT", "IFCVIRTUALELEMENT"
  ));

// Whether to import furniture at all - off by default. Tables, chairs,
// desks and the like add clutter and import time without adding much to
// what's primarily an architectural/solar study tool.
//
// Trees, solar devices, a pool's water and planted surfaces are
// commonly modeled using one of these same entity types too (e.g. a
// tree as an IfcFurnishingElement - see every ifcLooksLike*() function
// above), and are NOT affected by this toggle regardless of its value:
// import_objects_IFC()'s own product-collection loop excludes anything
// those functions already recognize from the furniture skip, since
// they're each handled as their own, deliberate feature independent of
// the underlying entity type.
//
// The same toggle also excludes small tabletop objects (books, coffee
// cups, vases, loose decor) - see IFC_SMALL_OBJECT_MAX_DIMENSION's own
// comment for how those get recognized, which is a different mechanism
// from ifcFurnitureProductTypes below: a real check against a sample
// Revit export (a hotel/residential model, "White Porcelain Plate",
// "Water Glass", "aalto vase", "Wine Bottles" among its contents)
// confirmed small objects like these are exported as
// IfcBuildingElementProxy, not IfcFurnishingElement/IfcFurniture - but
// that same model's IfcBuildingElementProxy instances also included a
// washing machine, an oven, a dishwasher and a parked-car entourage
// prop, none of which belong in a blanket "it's a proxy, exclude it"
// rule - IfcBuildingElementProxy is IFC's and most authoring tools'
// catch-all for "doesn't fit a more specific class", used for
// everything from dinner plates to elevators and escalators, so size,
// not type, is the signal that actually distinguishes a small object
// from a significant one modeled the same way.
//
// This constant is only ever this toggle's own starting value - what
// import_objects_IFC() actually checks at import time is
// ifcImportFurniture below, a plain (non-final) variable the person
// importing can flip per import, from the IFC import options dialog
// (see ifcShowImportOptionsDialog() in fileSelected.pde) - the same
// relationship IFC_IMPORT_NORTH/ifcImportOrient and
// IFC_IMPORT_GOTO_LATLON/ifcImportRelocate below have.
final boolean IFC_IMPORT_FURNITURE = false;

// The actual, per-session, user-toggleable switch - see this constant's
// own comment just above for what it does and why it starts this way.
boolean ifcImportFurniture = IFC_IMPORT_FURNITURE;

// Whether to rotate the whole imported model, around the world origin,
// to correct for the project's own true-north rotation - on by default.
// IFC's own, schema-defined place for this is NOT an IfcSite attribute -
// it's IfcGeometricRepresentationContext.TrueNorth (referenced from
// IfcProject.RepresentationContexts): a 2D direction, in the project's
// own XY plane, that points toward real/geographic north (see
// ifcTrueNorthAngleDegrees() below). Per the IFC documentation, this
// attribute should be set whenever WorldCoordinateSystem's own Y axis
// does NOT already point to true north, and defaults to (0,1) - i.e.
// "already does" - when omitted. (An IfcSite's own ObjectPlacement
// rotation is a similar-looking but different, tool-specific thing -
// Autodesk's own documentation notes Revit does this only "in some
// circumstances", and that the rotation it writes there doesn't drive
// any object's actual coordinates - so this importer doesn't treat it
// as true north at all, to avoid reading a real rotation where the file
// never actually asked for one.) Left on, every face and every placed
// tree/person this import produces (see
// ifcRotateImportedModelToTrueNorth() below) ends up rotated by that
// angle around Z, about the origin, so "north" in this app's own sense
// (R=0, i.e. +Y - see SolarImpacts.R's own comment) lines up with the
// real, geographic north the file's author actually meant, instead of
// whatever the file's own project axes happened to be drawn in. A file
// with no TrueNorth at all - the common case - naturally produces a
// zero angle, so this is a no-op for those regardless of the toggle's
// value - see "Don't rotate if the angle is zero" in
// ifcRotateImportedModelToTrueNorth()'s own comment.
//
// Just this toggle's own starting value - see IFC_IMPORT_FURNITURE's
// own comment above for why, and ifcImportOrient below for what's
// actually checked at import time.
final boolean IFC_IMPORT_NORTH = true;

boolean ifcImportOrient = IFC_IMPORT_NORTH;

// Whether to navigate the app's own "station" (STATION.latitude/
// longitude - see STATION.pde) to wherever the file's own IfcSite says
// the project actually is, once loading finishes - on by default. Most
// of what this app computes (sun position, solar yield, the satellite/
// terrain imagery WORLD.FindGoodViewport() picks, ...) depends on the
// station's own lat/lon, so an IFC import that leaves it wherever it
// happened to be before - typically nowhere near the file's own site -
// silently makes all of that wrong for the model that was just loaded.
// See ifcSiteLatLonDecimalDegrees() below for exactly where the lat/lon
// itself comes from (IfcSite's own RefLatitude/RefLongitude, or, failing
// that, an IfcMapConversion's Eastings/Northings); a file with neither
// naturally leaves the station untouched regardless of this toggle's
// value, same as ifcImportOrient already does for an unrotated/missing
// IfcSite.
//
// Just this toggle's own starting value - see IFC_IMPORT_FURNITURE's
// own comment above for why, and ifcImportRelocate below for what's
// actually checked at import time.
final boolean IFC_IMPORT_GOTO_LATLON = true;

boolean ifcImportRelocate = IFC_IMPORT_GOTO_LATLON;

// One-shot: whether the very next import_objects_IFC() call should open
// ifcShowImportOptionsDialog() (fileSelected.pde) before doing anything
// else - set true only by selectFile_ImportIfc(), right before it asks
// Processing's own native file chooser (selectInput()) for a file, and
// consumed (reset back to false) by import_objects_IFC() itself the
// moment it checks it, whether or not that import actually happens.
// Defaults to (and, every other way import_objects_IFC() can be
// reached - a script's own IMPORT_IFC command with a path already
// given, a direct call from a test, ...  - stays) false, so none of
// those other paths ever pops up a dialog: showing one there would mean
// a file path given non-interactively (by a script, or by a test
// calling import_objects_IFC()/_fileSelected_ImportIfc() directly)
// could still block waiting on a person who was never going to see it.
boolean ifcImportShowOptionsDialog = false;

// IfcSanitaryTerminal is IFC4's own dedicated entity for toilet/
// bathroom fixtures (a IfcFlowTerminal subtype: WCs, sinks, bathtubs,
// showers, urinals, bidets, ...) - included for files from tools that
// use it. IfcFlowTerminal itself is included too, and checked first in
// this list's own real-export validation below for a reason: it's IFC's
// generic "endpoint of an MEP distribution system" entity, and turns
// out to be where Revit's own IFC export actually puts sanitary
// fixtures in practice rather than the more specific entity - checked
// against a real export, every one of its own IfcFlowTerminal instances
// was a sink, faucet, bathtub or lavatory, none an air terminal/
// diffuser or anything else the "flow terminal" name could in principle
// also cover. Excluding the type wholesale, the same as furniture
// itself, accepts that same small breadth-of-scope risk other files
// might expose, on the same reasoning: an MEP terminal device is
// inherently a fixture, not core architecture, squarely in
// "non-essential for a solar/architectural study" territory the same
// way furniture already is.
HashSet<String> ifcFurnitureProductTypes = new HashSet<String>(Arrays.asList(
  "IFCFURNISHINGELEMENT", "IFCFURNITURE", "IFCSYSTEMFURNITUREELEMENT",
  "IFCFLOWTERMINAL", "IFCSANITARYTERMINAL"
  ));

// Kitchen appliances (gas or otherwise) and cabinets/storage fixtures
// have no entity of their own the way a sanitary fixture does - checked
// against a real export, every one of its kitchen appliances (a washing
// machine, dryer, oven, induction cooktop, rangehood, dishwasher,
// fridge/freezer, microwave - all branded "Miele") came through as
// IfcBuildingElementProxy, the same catch-all small decor objects use
// (see IFC_SMALL_OBJECT_MAX_DIMENSION above) - but these are large
// enough that the size filter alone would never catch them, so this is
// a Name/ObjectType word match instead, the same mechanism trees/solar/
// vegetation/pools/people already use, scoped to IfcBuildingElementProxy
// for the same reason the size filter is: that type is IFC's and most
// authoring tools' catch-all for "doesn't fit a more specific class",
// so only a name that actually says so should be excluded, not the type
// as a whole. Deliberately excludes bare "range"/"washer"/"hood" - each
// too likely to mean something else entirely out of context (a value
// range, a mechanical fastener, a car's hood) - requiring either a more
// specific single word ("rangehood", "dishwasher", "cooktop") or an
// explicit two-word conjunction ("washing"+"machine", "range"+"hood")
// instead.
HashSet<String> ifcApplianceOrCabinetNameWords = new HashSet<String>(Arrays.asList(
  "oven", "cooktop", "stovetop", "stove", "rangehood", "dishwasher",
  "fridge", "refrigerator", "freezer", "microwave", "dryer",
  "cabinet", "cabinetry", "cupboard", "pantry", "wardrobe", "closet", "shelving"
  ));

ArrayList<HashSet<String>> ifcApplianceOrCabinetWordGroups = new ArrayList<HashSet<String>>(Arrays.asList(
  new HashSet<String>(Arrays.asList("washing", "machine")),
  new HashSet<String>(Arrays.asList("range", "hood"))
  ));

boolean ifcLooksLikeExcludedApplianceOrCabinet (StepEntity e) {
  if (!e.type.equals("IFCBUILDINGELEMENTPROXY")) return false;
  if (e.attrs.length > 2 && ifcNameHasWord(e.attrs[2], ifcApplianceOrCabinetNameWords)) return true; // Name
  if (e.attrs.length > 4 && ifcNameHasWord(e.attrs[4], ifcApplianceOrCabinetNameWords)) return true; // ObjectType
  for (HashSet<String> words : ifcApplianceOrCabinetWordGroups) {
    if (e.attrs.length > 2 && ifcNameHasAllWords(e.attrs[2], words)) return true;
    if (e.attrs.length > 4 && ifcNameHasAllWords(e.attrs[4], words)) return true;
  }
  return false;
}

// An IfcBuildingElementProxy whose own geometry fits within a cube of
// this size (metres, after unit conversion - see ifcLengthUnitScale)
// on every axis is treated as a small tabletop object and excluded the
// same way furniture is, while ifcImportFurniture is false. 0.5m
// comfortably covers plates, cups, vases, books and other loose decor
// (all well under it in every dimension) while staying well below
// anything closer to furniture-sized (even a narrow side table or
// pedestal is taller than this) - deliberately conservative, since the
// cost of wrongly keeping a small object is low (mild clutter) but the
// cost of wrongly excluding a real one is a silently incomplete model.
final float IFC_SMALL_OBJECT_MAX_DIMENSION = 0.5;

// Product types drawn as glass (IFC_MATERIAL_GLASS below) instead of
// whatever opaque material the rest of the import is using. Only
// IfcWindow by default; IfcPlate and IfcCurtainWall (curtain-wall
// glazing panels, in files that model them as separate elements) are
// easy to add to this set the same way if that's ever wanted too.
HashSet<String> ifcGlassProductTypes = new HashSet<String>(Arrays.asList(
  "IFCWINDOW"
  ));

// Product types that default to IFC_MATERIAL_EARTH when nothing more
// specific applies - just IfcSite's own topography/terrain surface.
// Lower priority than an actual associated IfcMaterial name match (see
// the material-choice block in import_objects_IFC() below): a site
// whose file-authored material happens to say e.g. "Grass" or "Asphalt"
// still gets that color instead, same as any other product.
HashSet<String> ifcTopographyProductTypes = new HashSet<String>(Arrays.asList(
  "IFCSITE"
  ));

// Exposed structural members - columns, beams, and the more general
// IfcMember (bracing, struts, purlins, ...) - that default to
// IFC_MATERIAL_CONCRETE when nothing more specific applies, the same
// way IfcSite defaults to earth: a coordination-stage file very often
// has no IfcMaterial assigned to its structure yet, and an unmatched
// column or beam just cycling through 1-8 like a wall or a window reads
// as arbitrary, not structural. Unlike glass/solar, this is a cosmetic
// default only - an actual associated material name (e.g. "Steel")
// still wins, same priority tier as vegetation/earth below. Pure
// entity-type matching here, no Name/ObjectType word check needed:
// unlike a tree or a solar device, IFC already gives these their own
// unambiguous entity types.
HashSet<String> ifcStructuralProductTypes = new HashSet<String>(Arrays.asList(
  "IFCCOLUMN", "IFCBEAM", "IFCMEMBER"
  ));

// A floor - an IfcSlab whose own PredefinedType says .FLOOR. (IfcSlab
// also covers roofs, landings, base slabs, paving, ... - only the
// floor case gets this default) or, for files that don't set that
// attribute, a Name/ObjectType word match - also defaults to
// IFC_MATERIAL_CONCRETE, same reasoning and priority as
// ifcStructuralProductTypes above. IfcSlab's own attribute order:
// ...Representation(6), Tag(7), PredefinedType(8).
HashSet<String> ifcFloorNameWords = new HashSet<String>(Arrays.asList(
  "floor", "floors", "flooring"
  ));

boolean ifcLooksLikeAFloor (StepEntity e) {
  if (e.type.equals("IFCSLAB") && e.attrs.length > 8 && e.attrs[8].trim().equals(".FLOOR.")) return true;
  if (e.attrs.length > 2 && ifcNameHasWord(e.attrs[2], ifcFloorNameWords)) return true; // Name
  if (e.attrs.length > 4 && ifcNameHasWord(e.attrs[4], ifcFloorNameWords)) return true; // ObjectType
  return false;
}

// Words that mark a product as a planted/vegetated surface - a green
// roof (an IfcRoof build-up), a green wall (an IfcWall or
// IfcCurtainWall), or a garden/lawn (often just IfcSite's own
// Name/ObjectType, same as how a site's topography is caught
// generally - see ifcTopographyProductTypes above) - IFC has no single
// dedicated entity for any of these any more than it does for a tree or
// a solar device, so this is a Name/ObjectType word match too (see
// ifcLooksLikeVegetation() below, which reuses ifcNameHasWord() the
// same way trees and solar devices do). Checked only after an explicit
// associated IfcMaterial name match fails (see the material-choice
// block in import_objects_IFC() below) - purely a cosmetic default, not
// a functional override like glass or solar, so a file-authored
// material name (e.g. "Sedum Mat", "Topsoil") still wins over it.
HashSet<String> ifcVegetationNameWords = new HashSet<String>(Arrays.asList(
  "green", "garden", "grass", "lawn", "vegetation"
  ));

boolean ifcLooksLikeVegetation (StepEntity e) {
  if (e.attrs.length > 2 && ifcNameHasWord(e.attrs[2], ifcVegetationNameWords)) return true; // Name
  if (e.attrs.length > 4 && ifcNameHasWord(e.attrs[4], ifcVegetationNameWords)) return true; // ObjectType
  return false;
}

// Words that mark a product as a swimming pool's own water surface -
// also no single dedicated IFC entity, same reasoning as above.
// Deliberately not a bare "water" (too broad on its own - "Water
// Heater", "Water Closet", "Water Tank", "Watermain" and plenty of
// other MEP-ish names would all false-match it); "pool"/"pools"/
// "swimming" alone stay specific to an actual swimming pool. A pool is
// commonly modeled as an IfcSpace (a water volume) rather than a solid
// building element, so ifcLooksLikeAPool() gets its own, narrow
// exception in import_objects_IFC()'s own product-collection loop
// (every other IfcSpace is still excluded, same as always - this
// doesn't reopen that for anything but a pool).
HashSet<String> ifcPoolNameWords = new HashSet<String>(Arrays.asList(
  "pool", "pools", "swimming"
  ));

boolean ifcLooksLikeAPool (StepEntity e) {
  if (e.attrs.length > 2 && ifcNameHasWord(e.attrs[2], ifcPoolNameWords)) return true; // Name
  if (e.attrs.length > 4 && ifcNameHasWord(e.attrs[4], ifcPoolNameWords)) return true; // ObjectType
  return false;
}

// Product types always drawn with IFC_MATERIAL_SOLAR (material 0),
// overriding any associated IfcMaterial name the same way windows
// override theirs - IfcSolarDevice (IFC4.3's own entity for a PV panel,
// solar collector or solar hybrid panel) if the file uses it. A file
// that doesn't - most don't yet - is still covered by
// ifcLooksLikeASolarDevice()'s own Name/ObjectType word match below
// ("solar", "photovoltaic", "pv"), which catches a solar panel/
// collector/hybrid panel modeled as a generic proxy element instead,
// so this set alone isn't the whole story - see that function.
HashSet<String> ifcSolarProductTypes = new HashSet<String>(Arrays.asList(
  "IFCSOLARDEVICE"
  ));

// Materials.pde indices for the colors an IFC import can pick by name/
// product type instead of cycling through materials 1-8. Keep these in
// sync with Materials.pde's own "fixed" color table and its comments.
// IFC_MATERIAL_GLASS is material 9, one of the three translucent grays
// (alpha 63/127/191 for 8/9/10; everything else is fully opaque) - and,
// as a side effect worth knowing about, Faces.castShadows() only casts
// a shadow for a material whose alpha is > 127, so material 9 (and
// IFC_MATERIAL_INSULATION below, which shares its 50% alpha) don't cast
// one; material 10 would, which is part of why windows no longer cycle
// into it.
//
// IFC_MATERIAL_SOLAR is material 0, Materials.pde's orange - not a
// separate convention invented for this importer, but the app's own
// existing one: Faces.pde (castShadows() and several others),
// calculate_VertexSolar_array.pde, Overlay3D.pde, ViewFromTheSky.pde
// and snap_Faces.pde all single out "getMaterial(f) == 0" for finer,
// boosted tessellation (current tessellation + displayTessellation)
// specifically because that extra resolution matters for a face's own
// solar/shading calculation - exactly what a PV panel or solar
// collector needs for an accurate yield estimate. There's no material
// index -1 to assign (Materials.pde has no such entry, and storing one
// on a face would crash the very rendering/calculation code just
// described) - 0 is the real, load-bearing value underneath that
// mental shorthand, not an approximation of it.
final int IFC_MATERIAL_SOLAR      = 0;
final int IFC_MATERIAL_GLASS      = 9;
final int IFC_MATERIAL_CONCRETE   = 11;
final int IFC_MATERIAL_STEEL      = 12;
final int IFC_MATERIAL_TIMBER     = 13;
final int IFC_MATERIAL_MASONRY    = 14;
final int IFC_MATERIAL_INSULATION = 15;
final int IFC_MATERIAL_MEP        = 16;
final int IFC_MATERIAL_EARTH      = 17;
final int IFC_MATERIAL_VEGETATION = 18;
final int IFC_MATERIAL_WATER      = 19;

// Running counters for the post-import summary (and for tests - reset
// at the top of every import_objects_IFC() call).
int ifcImportSkippedCount = 0;
// How many inner face/profile boundaries (IfcFaceBound,
// IfcIndexedPolygonalFaceWithVoids' own voids) have actually been cut
// out of their own outer face so far - see PolygonHoles.pde's own
// comment for how. No longer "ignored": this used to count holes the
// importer left in place (hole and all); now it counts holes it
// actually bridged out, kept for the same post-import summary line
// under a name that matches what happens now.
int ifcImportHolesCutCount = 0;
int ifcImportTreeCount = 0;
int ifcImportPersonCount = 0;
// IfcBooleanResult/IfcBooleanClippingResult items that imported only
// their FirstOperand - see ifcProcessRepresentationItem()'s own
// comment on that - counted separately from ifcImportSkippedCount:
// this is real, imported geometry, just without its opening cut out,
// not something left out of the import entirely.
int ifcImportUncutOpeningCount = 0;
// Furniture excluded by ifcImportFurniture == false - counted
// separately from ifcImportSkippedCount, since this isn't something
// unsupported being skipped, it's a deliberate choice.
int ifcImportFurnitureExcludedCount = 0;
// Small IfcBuildingElementProxy objects excluded the same way, while
// the same toggle is false - see IFC_SMALL_OBJECT_MAX_DIMENSION's own
// comment.
int ifcImportSmallObjectExcludedCount = 0;
// The true-north angle (degrees, signed, about Z) the import actually
// rotated the model by - see ifcImportOrient and
// ifcRotateImportedModelToTrueNorth() below. Stays 0 whenever nothing
// was rotated: ifcImportOrient is off, the file has no IfcSite, or
// that IfcSite's own placement isn't rotated at all.
float ifcImportNorthRotationAngle = 0;
// {latitude, longitude} the import navigated the station to - see
// ifcImportRelocate and ifcSiteLatLonDecimalDegrees() below. Stays
// null whenever nothing was navigated to: ifcImportRelocate is
// off, or the file gives no usable reference point at all (see that
// function's own comment for the two sources it tries).
float[] ifcImportGotoLatLon = null;
HashMap<String, Integer> ifcImportSkippedReasons = new HashMap<String, Integer>();

// Guards against a pathological/cyclic chain of nested IfcMappedItems
// (a mapped representation that itself contains another mapped item,
// and so on) recursing forever - see ifcProcessMappedItem()'s own
// comment. A plain int rather than a parameter threaded through the
// whole ifcProcessRepresentationItem()/ifcProcessShapeRepresentation()
// call chain, since only this one path can ever recurse that deeply;
// reset to 0 at the top of every import_objects_IFC() call, same as
// the counters above.
int ifcMappedItemDepth = 0;

// Guards against a pathological/cyclic chain of nested
// IfcBooleanResult/IfcBooleanClippingResult items the same way
// ifcMappedItemDepth guards IfcMappedItem - see
// ifcProcessRepresentationItem()'s own comment. Capped higher than the
// mapped-item one (100, not 6): several openings chained one after
// another on the same wall is normal, not pathological.
int ifcBooleanResultDepth = 0;

// The multiplier that converts a raw length value read from the file
// into metres - the app's own working unit, same as every other
// importer/exporter here assumes (see e.g. export_objects_OBJ.pde).
// Detected once per import, from the project's own declared length
// unit (see ifcDetectLengthUnitScale() below); reset to 1 (assume
// metres already) at the top of every import_objects_IFC() call, same
// as the counters above, so a file that doesn't declare one at all -
// most small hand-written or test files - is read as-is rather than
// guessed at.
float ifcLengthUnitScale = 1;

void ifcNoteSkipped (String reason) {
  ifcImportSkippedCount++;
  Integer prior = ifcImportSkippedReasons.get(reason);
  ifcImportSkippedReasons.put(reason, (prior == null ? 0 : prior) + 1);
}

// Small, self-contained ArrayList<PVector> in-place reverse and
// ArrayList<Integer> ascending in-place sort - java.util.Collections
// isn't resolvable unqualified in this sketch (unlike HashMap/ArrayList,
// which Processing's own preprocessor happens to provide; Arrays and
// HashSet needed their own explicit import in solarchvision_bim.pde,
// same story here), so rather than add yet another import to that
// shared tab, both one-off uses below are just written out directly.
void ifcReverseInPlace (ArrayList<PVector> list) {
  int i = 0, j = list.size() - 1;
  while (i < j) {
    PVector tmp = list.get(i);
    list.set(i, list.get(j));
    list.set(j, tmp);
    i++;
    j--;
  }
}

void ifcSortAscending (ArrayList<Integer> list) {
  // Small lists (one entry per IfcProduct) - a plain insertion sort is
  // simple, correct, and fast enough; no need to reach for a library
  // sort just for this.
  for (int i = 1; i < list.size(); i++) {
    int key = list.get(i);
    int j = i - 1;
    while (j >= 0 && list.get(j) > key) {
      list.set(j + 1, list.get(j));
      j--;
    }
    list.set(j + 1, key);
  }
}

// ---------------------------------------------------------------------
// STEP text -> entities
// ---------------------------------------------------------------------

// Splits the whole DATA section's text (and, harmlessly, its HEADER
// section too - those statements just never start with "#" and get
// filtered out downstream) into individual ";"-terminated statements,
// respecting '...' string literals (with '' as an escaped quote inside
// one) and /* ... */ comments, neither of which should ever have their
// ';' or quote characters mistaken for statement syntax.
ArrayList<String> ifcSplitStatements (String text) {
  ArrayList<String> out = new ArrayList<String>();
  StringBuilder cur = new StringBuilder();
  boolean inString = false;
  boolean inComment = false;
  int n = text.length();
  for (int i = 0; i < n; i++) {
    char c = text.charAt(i);
    if (inComment) {
      if (c == '*' && i + 1 < n && text.charAt(i + 1) == '/') {
        inComment = false;
        i++;
      }
      continue;
    }
    if (inString) {
      cur.append(c);
      if (c == '\'') {
        if (i + 1 < n && text.charAt(i + 1) == '\'') {
          cur.append('\'');
          i++;
        } else {
          inString = false;
        }
      }
      continue;
    }
    if (c == '\'') {
      inString = true;
      cur.append(c);
      continue;
    }
    if (c == '/' && i + 1 < n && text.charAt(i + 1) == '*') {
      inComment = true;
      i++;
      continue;
    }
    if (c == ';') {
      out.add(cur.toString());
      cur.setLength(0);
      continue;
    }
    cur.append(c);
  }
  if (cur.toString().trim().length() > 0) out.add(cur.toString());
  return out;
}

// Splits on `delim` at paren-depth 0 only, so a nested list (an
// attribute that's itself a list, e.g. IFCCARTESIANPOINT's coordinate
// triple, or IFCPOLYLOOP's point reference list) is never split apart,
// and a string literal's own contents are never mistaken for syntax.
String[] ifcSplitTopLevel (String s, char delim) {
  ArrayList<String> parts = new ArrayList<String>();
  int depth = 0;
  boolean inStr = false;
  StringBuilder cur = new StringBuilder();
  int n = s.length();
  for (int i = 0; i < n; i++) {
    char c = s.charAt(i);
    if (inStr) {
      cur.append(c);
      if (c == '\'') {
        if (i + 1 < n && s.charAt(i + 1) == '\'') {
          cur.append('\'');
          i++;
        } else {
          inStr = false;
        }
      }
      continue;
    }
    if (c == '\'') {
      inStr = true;
      cur.append(c);
      continue;
    }
    if (c == '(') {
      depth++;
      cur.append(c);
      continue;
    }
    if (c == ')') {
      depth--;
      cur.append(c);
      continue;
    }
    if (c == delim && depth == 0) {
      parts.add(cur.toString().trim());
      cur.setLength(0);
      continue;
    }
    cur.append(c);
  }
  String last = cur.toString().trim();
  if (last.length() > 0) parts.add(last);
  return parts.toArray(new String[0]);
}

// Parses every "#id=TYPE(...)" statement in the file into a lookup by
// entity id. Anything else (HEADER section lines, blank statements,
// malformed ids) is silently skipped - this function never throws on a
// file it can't fully make sense of; whatever it does recognize is
// still imported, and the rest is counted via ifcNoteSkipped() further
// downstream, where the *meaning* of what's missing is still known.
HashMap<Integer, StepEntity> ifcParseEntities (String fullText) {
  HashMap<Integer, StepEntity> ents = new HashMap<Integer, StepEntity>();
  ArrayList<String> statements = ifcSplitStatements(fullText);
  for (String raw : statements) {
    String stmt = raw.trim();
    if (stmt.length() == 0 || stmt.charAt(0) != '#') continue;

    int eq = stmt.indexOf('=');
    if (eq < 0) continue;

    int id;
    try {
      id = Integer.parseInt(stmt.substring(1, eq).trim());
    }
    catch (Exception ex) {
      continue;
    }

    String rest = stmt.substring(eq + 1).trim();
    int paren = rest.indexOf('(');
    int lastParen = rest.lastIndexOf(')');
    if (paren < 0 || lastParen < paren) continue;

    StepEntity e = new StepEntity();
    e.id = id;
    e.type = rest.substring(0, paren).trim().toUpperCase();
    e.attrs = ifcSplitTopLevel(rest.substring(paren + 1, lastParen), ',');
    ents.put(id, e);
  }
  return ents;
}

// ---------------------------------------------------------------------
// Small token helpers
// ---------------------------------------------------------------------

int ifcRefId (String token) {
  if (token == null) return -1;
  token = token.trim();
  if (!token.startsWith("#")) return -1;
  try {
    return Integer.parseInt(token.substring(1).trim());
  }
  catch (Exception ex) {
    return -1;
  }
}

StepEntity ifcResolve (HashMap<Integer, StepEntity> ents, String token) {
  int id = ifcRefId(token);
  if (id < 0) return null;
  return ents.get(id);
}

float ifcFloat (String token) {
  try {
    return Float.parseFloat(token.trim());
  }
  catch (Exception ex) {
    return 0;
  }
}

// Strips one layer of enclosing parentheses, if present - used on an
// attribute token that is itself a list (IFCCARTESIANPOINT's
// coordinates, IFCPOLYLOOP's point refs, IFCCARTESIANPOINTLIST3D's
// point rows, ...).
String ifcStripParens (String s) {
  s = s.trim();
  if (s.startsWith("(") && s.endsWith(")")) return s.substring(1, s.length() - 1);
  return s;
}

String[] ifcListTokens (String listAttr) {
  return ifcSplitTopLevel(ifcStripParens(listAttr), ',');
}

// Every raw coordinate triple in the file - IfcCartesianPoint,
// IfcDirection, and an IfcCartesianPointList3D's own point rows - goes
// through here, so this is also the one place ifcLengthUnitScale (see
// below) needs applying to convert a length from the file's own units
// into metres. Scaling a direction here too is harmless, not just
// convenient: every direction this importer reads gets re-normalized
// (or explicitly divided by its own magnitude) immediately after, so
// any positive scale factor on it cancels out.
PVector ifcPointFromCoords (String coordsListAttr) {
  String[] c = ifcListTokens(coordsListAttr);
  float x = c.length > 0 ? ifcFloat(c[0]) : 0;
  float y = c.length > 1 ? ifcFloat(c[1]) : 0;
  float z = c.length > 2 ? ifcFloat(c[2]) : 0;
  return new PVector(x * ifcLengthUnitScale, y * ifcLengthUnitScale, z * ifcLengthUnitScale);
}

// Resolves a "#ref" token to an IFCCARTESIANPOINT/IFCDIRECTION and
// reads its coordinate list (2D entries come back with z=0).
PVector ifcPoint3 (HashMap<Integer, StepEntity> ents, String token) {
  StepEntity e = ifcResolve(ents, token);
  if (e == null || e.attrs.length == 0) return new PVector(0, 0, 0);
  return ifcPointFromCoords(e.attrs[0]);
}

PVector ifcDirection3 (HashMap<Integer, StepEntity> ents, String token) {
  StepEntity e = ifcResolve(ents, token);
  if (e == null || e.attrs.length == 0) return new PVector(0, 0, 1);
  return ifcPointFromCoords(e.attrs[0]);
}

// ---------------------------------------------------------------------
// Placement: IfcLocalPlacement chain + IfcAxis2Placement3D
// ---------------------------------------------------------------------

IfcFrame ifcAxis2Placement3DToFrame (HashMap<Integer, StepEntity> ents, StepEntity e) {
  if (e == null || e.attrs.length == 0) return ifcIdentityFrame();

  PVector origin = ifcPoint3(ents, e.attrs[0]);

  PVector zAxis = (e.attrs.length > 1 && e.attrs[1].trim().startsWith("#"))
    ? ifcDirection3(ents, e.attrs[1]) : new PVector(0, 0, 1);
  zAxis.normalize();

  PVector refDir = (e.attrs.length > 2 && e.attrs[2].trim().startsWith("#"))
    ? ifcDirection3(ents, e.attrs[2]) : new PVector(1, 0, 0);

  PVector xAxis = PVector.sub(refDir, PVector.mult(zAxis, refDir.dot(zAxis)));
  if (xAxis.mag() < 0.0001) {
    // RefDirection was (nearly) parallel to Axis: fall back to whichever
    // global axis is least parallel to Axis, same "arbitrary axis" fix
    // the IFC spec itself prescribes for this edge case.
    PVector fallback = (abs(zAxis.x) < 0.9) ? new PVector(1, 0, 0) : new PVector(0, 1, 0);
    xAxis = PVector.sub(fallback, PVector.mult(zAxis, fallback.dot(zAxis)));
  }
  xAxis.normalize();

  PVector yAxis = zAxis.cross(xAxis);
  yAxis.normalize();

  return new IfcFrame(origin, xAxis, yAxis, zAxis);
}

// Walks an IfcLocalPlacement's PlacementRelTo chain, composing each
// level's own IfcAxis2Placement3D into one world frame. Falls back to
// the identity frame for anything it doesn't recognize (a missing
// entity, a placement type this importer doesn't resolve) rather than
// failing the whole product's import over one bad reference.
IfcFrame ifcPlacementToFrame (HashMap<Integer, StepEntity> ents, int placementId) {
  if (placementId < 0) return ifcIdentityFrame();
  StepEntity e = ents.get(placementId);
  if (e == null) return ifcIdentityFrame();

  if (e.type.equals("IFCAXIS2PLACEMENT3D")) {
    return ifcAxis2Placement3DToFrame(ents, e);
  }

  if (!e.type.equals("IFCLOCALPLACEMENT") || e.attrs.length < 2) {
    return ifcIdentityFrame();
  }

  String relToTok = e.attrs[0].trim();
  StepEntity relPlacement = ifcResolve(ents, e.attrs[1]);
  IfcFrame childFrame = ifcAxis2Placement3DToFrame(ents, relPlacement);

  if (!relToTok.startsWith("#")) return childFrame;

  IfcFrame parentFrame = ifcPlacementToFrame(ents, ifcRefId(relToTok));
  return ifcComposeFrame(parentFrame, childFrame);
}

// The project's own true-north rotation (degrees, signed, measured in
// the horizontal X/Y plane from world +X toward world +Y - exactly what
// Rotate3D.selection(..., the_Vector=2), rotation about Z, already
// expects), read from IfcGeometricRepresentationContext.TrueNorth - see
// IFC_IMPORT_NORTH's own comment for why that attribute, not an IfcSite
// one, is the schema-correct place to read this from. TrueNorth is
// itself a 2D direction (dx,dy), in the project's own XY plane, that
// points toward real/geographic north; defaults to (0,1) - already
// north, zero rotation - when the context has no TrueNorth of its own,
// read the same way ifcDirection3() already reads any other direction
// (2D entries come back with z=0, which is simply ignored here).
//
// The angle that brings a (dx,dy) vector onto +Y, under this file's own
// the_Vector==2 rotation (x'=x*cosθ-y*sinθ, y'=x*sinθ+y*cosθ - a
// standard counterclockwise rotation matrix), solves
// dx*cosθ - dy*sinθ = 0, i.e. θ = atan2(dx,dy): e.g. TrueNorth=(1,0)
// (north is 90 degrees away, toward the project's own +X) needs a +90
// degree rotation to swing that +X onto +Y, and atan2(1,0) is indeed 90
// degrees.
//
// A file with several IfcGeometricRepresentationContext entities (one
// each for "Model", "Plan", ...) uses the one with the lowest entity id,
// the same ascending-id determinism ifcSortAscending() gives
// import_objects_IFC()'s own product loop. Returns 0 - meaning "don't
// rotate" - when the file has no such context at all, or when it has
// one but no TrueNorth of its own.
float ifcTrueNorthAngleDegrees (HashMap<Integer, StepEntity> ents) {
  ArrayList<Integer> contextIds = new ArrayList<Integer>();
  for (Integer id : ents.keySet()) {
    StepEntity candidate = ents.get(id);
    if (candidate != null && candidate.type.equals("IFCGEOMETRICREPRESENTATIONCONTEXT")) contextIds.add(id);
  }
  if (contextIds.size() == 0) return 0;
  ifcSortAscending(contextIds);

  StepEntity context = ents.get(contextIds.get(0));
  if (context.attrs.length < 6) return 0;

  String trueNorthTok = context.attrs[5].trim();
  if (!trueNorthTok.startsWith("#")) return 0;

  PVector trueNorth = ifcDirection3(ents, trueNorthTok);
  return atan2(trueNorth.x, trueNorth.y) * 180 / PI;
}

// IfcSite's RefLatitude/RefLongitude are IFC's own
// IfcCompoundPlaneAngleMeasure - a plain attribute-level list of
// (degrees, minutes, seconds[, microseconds]), NOT an entity reference
// the way almost everything else this importer reads is - converted
// here into ordinary signed decimal degrees. Only the first (degrees)
// component's own sign is honored - minutes/seconds/microseconds are
// assumed non-negative, same as every real IFC export writes them.
float ifcCompoundAngleToDecimalDegrees (String listAttr) {
  String[] c = ifcListTokens(listAttr);
  if (c.length == 0) return 0;

  float deg = ifcFloat(c[0]);
  float min = c.length > 1 ? ifcFloat(c[1]) : 0;
  float sec = c.length > 2 ? ifcFloat(c[2]) : 0;
  // The optional 4th component is in millionths of a second - not a
  // 4th decimal place - per IfcCompoundPlaneAngleMeasure's own
  // definition.
  float microsec = c.length > 3 ? ifcFloat(c[3]) : 0;

  float sign = (deg < 0) ? -1 : 1;
  float magnitude = abs(deg) + min / 60 + (sec + microsec / 1000000) / 3600;
  return sign * magnitude;
}

// Where IFC_IMPORT_GOTO_LATLON (see its own comment) navigates the
// station to, as {latitude, longitude} in decimal degrees - or null
// when the file gives no usable reference point at all. Two sources,
// tried in this order:
//
//   1. IfcSite's own RefLatitude(9)/RefLongitude(10) - IFC2x3's and
//      IFC4's original way of georeferencing a site directly, and still
//      what most real exports actually set - read from the file's own
//      lowest-entity-id IfcSite (the same ascending-id determinism used
//      throughout this importer). A "$" (unset) RefLatitude/
//      RefLongitude - common even in a file that does set an
//      ObjectPlacement for that same IfcSite - is treated as absent,
//      not as the compound angle (0,0,0): only an attribute that's
//      actually a "(...)" list is read as one.
//
//   2. Failing that, an IfcMapConversion's own Eastings(2)/Northings(3)
//      - IFC4's newer, CRS-based way of georeferencing a project
//      (IfcMapConversion + IfcProjectedCRS), which newer exporters often
//      use instead, typically leaving RefLatitude/RefLongitude unset.
//      Taken only when both numbers already look like plain geographic
//      degrees (|Eastings| <= 180, |Northings| <= 90) rather than a real
//      projected CRS's own metres (a UTM easting, for example, is
//      typically in the hundreds of thousands) - this importer has no
//      map-projection engine of its own to turn a true projected
//      easting/northing into an actual latitude/longitude, so this path
//      only fires for the (common in practice) case of a file whose
//      "projection" is really just WGS84 geographic coordinates passed
//      straight through as Eastings/Northings.
//
// Either way, the result is rounded to 4 decimal places (roughly 11m at
// the equator) - this is only ever meant to get the station to the
// right part of the world, not to survey-grade accuracy.
float[] ifcSiteLatLonDecimalDegrees (HashMap<Integer, StepEntity> ents) {
  ArrayList<Integer> siteIds = new ArrayList<Integer>();
  for (Integer id : ents.keySet()) {
    StepEntity candidate = ents.get(id);
    if (candidate != null && candidate.type.equals("IFCSITE")) siteIds.add(id);
  }
  if (siteIds.size() > 0) {
    ifcSortAscending(siteIds);
    StepEntity site = ents.get(siteIds.get(0));

    if (site.attrs.length > 10) {
      String latTok = site.attrs[9].trim();
      String lonTok = site.attrs[10].trim();
      if (latTok.startsWith("(") && lonTok.startsWith("(")) {
        float lat = ifcCompoundAngleToDecimalDegrees(latTok);
        float lon = ifcCompoundAngleToDecimalDegrees(lonTok);
        return new float[] { round(lat * 10000) / 10000.0f, round(lon * 10000) / 10000.0f };
      }
    }
  }

  ArrayList<Integer> mapConversionIds = new ArrayList<Integer>();
  for (Integer id : ents.keySet()) {
    StepEntity candidate = ents.get(id);
    if (candidate != null && candidate.type.equals("IFCMAPCONVERSION")) mapConversionIds.add(id);
  }
  if (mapConversionIds.size() > 0) {
    ifcSortAscending(mapConversionIds);
    StepEntity mc = ents.get(mapConversionIds.get(0));

    if (mc.attrs.length > 3) {
      float eastings = ifcFloat(mc.attrs[2]);
      float northings = ifcFloat(mc.attrs[3]);
      if (abs(eastings) <= 180 && abs(northings) <= 90) {
        return new float[] { round(northings * 10000) / 10000.0f, round(eastings * 10000) / 10000.0f };
      }
    }
  }

  return null;
}

// IfcCartesianTransformationOperator(3D[NonUniform]) - used only as an
// IfcMappedItem's own MappingTarget (see ifcProcessMappedItem() below).
// Attribute order: Axis1(0, optional direction - default local X),
// Axis2(1, optional - default local Y), LocalOrigin(2, required point),
// Scale(3, optional, default 1), Axis3(4, optional - default local Z;
// present on the 3D variants only). Unlike IfcAxis2Placement3D, Axis1/
// Axis2/Axis3 are used exactly as given, not re-derived via a cross
// product - each one is read, normalized and scaled independently.
// Reads straight through regardless of the uniform/non-uniform variant:
// a non-uniform operator's own extra Scale2/Scale3 (after Axis3) are
// simply never read, so every axis is scaled by the one shared Scale
// instead - a known, minor simplification for the (uncommon) non-
// uniform case.
IfcFrame ifcCartesianTransformToFrame (HashMap<Integer, StepEntity> ents, StepEntity e) {
  if (e == null) return ifcIdentityFrame();

  PVector origin = (e.attrs.length > 2) ? ifcPoint3(ents, e.attrs[2]) : new PVector(0, 0, 0);

  PVector axis1 = (e.attrs.length > 0 && e.attrs[0].trim().startsWith("#")) ? ifcDirection3(ents, e.attrs[0]) : new PVector(1, 0, 0);
  PVector axis2 = (e.attrs.length > 1 && e.attrs[1].trim().startsWith("#")) ? ifcDirection3(ents, e.attrs[1]) : new PVector(0, 1, 0);
  PVector axis3 = (e.attrs.length > 4 && e.attrs[4].trim().startsWith("#")) ? ifcDirection3(ents, e.attrs[4]) : new PVector(0, 0, 1);
  axis1.normalize();
  axis2.normalize();
  axis3.normalize();

  String scaleTok = (e.attrs.length > 3) ? e.attrs[3].trim() : "";
  float scale = (scaleTok.length() > 0 && !scaleTok.equals("$")) ? ifcFloat(scaleTok) : 1;

  axis1.mult(scale);
  axis2.mult(scale);
  axis3.mult(scale);

  return new IfcFrame(origin, axis1, axis2, axis3);
}

// ---------------------------------------------------------------------
// 2D profile placement (IfcAxis2Placement2D), used only by profile defs
// ---------------------------------------------------------------------

// Returns {originX, originY, unitX, unitY} describing the profile's own
// local 2D->2D placement; identity when Position ($) is absent.
float[] ifcAxis2Placement2D (HashMap<Integer, StepEntity> ents, String token) {
  StepEntity e = ifcResolve(ents, token);
  if (e == null || e.attrs.length == 0) return new float[]{0, 0, 1, 0};

  PVector origin = ifcPoint3(ents, e.attrs[0]);
  PVector refDir = (e.attrs.length > 1 && e.attrs[1].trim().startsWith("#"))
    ? ifcDirection3(ents, e.attrs[1]) : new PVector(1, 0);

  float mag = sqrt(refDir.x * refDir.x + refDir.y * refDir.y);
  float ux = mag > 0.0001 ? refDir.x / mag : 1;
  float uy = mag > 0.0001 ? refDir.y / mag : 0;

  return new float[]{origin.x, origin.y, ux, uy};
}

float[] ifcApply2DPlacement (float[] placement, float px, float py) {
  float ox = placement[0], oy = placement[1], ux = placement[2], uy = placement[3];
  return new float[]{ox + px * ux - py * uy, oy + px * uy + py * ux};
}

// ---------------------------------------------------------------------
// Face/geometry import - every face becomes one queued point per
// vertex plus one queued face (see ifcQueuePoint()/ifcQueueFace()
// below), the same conceptual pair of steps Create3D.add_Mesh() itself
// does internally for an n-gon point list - so a quad/pentagon/etc.
// stays exactly that, never split into triangles.
//
// This deliberately does NOT call Create3D.add_Mesh() directly, though:
// that convenience wrapper also calls model_changed()/model_added() on
// every single invocation, and a real building's worth of faces -
// hundreds to thousands - each firing a full selection/bounding-box/
// WIN3D-cache refresh mid-import is both very slow and, in practice,
// capable of reading other selection/model state mid-update and
// crashing (an ArrayIndexOutOfBoundsException was seen here on a real
// IFC file). import_objects_OBJ.pde already avoids exactly this, the
// same way, for exactly this reason - it bypasses Create3D entirely and
// calls model_changed() exactly once, right at the end of the whole
// import, not per face. import_objects_IFC() does the same (see its own
// trailing model_changed() call).
// ---------------------------------------------------------------------

void ifcEmitFace (ArrayList<PVector> localPts, IfcFrame productFrame,
  float cx, float cy, float cz, float sx, float sy, float sz,
  int m, int tes, int lyr, int vsb, int wgt, int clz) {

  // Drop consecutive duplicate points (zero-length edges) before
  // deciding whether there's still a real polygon left.
  ArrayList<PVector> cleaned = new ArrayList<PVector>();
  for (PVector p : localPts) {
    if (cleaned.size() == 0 || PVector.dist(cleaned.get(cleaned.size() - 1), p) > 0.00001) {
      cleaned.add(p);
    }
  }
  if (cleaned.size() > 1 && PVector.dist(cleaned.get(0), cleaned.get(cleaned.size() - 1)) < 0.00001) {
    cleaned.remove(cleaned.size() - 1);
  }
  if (cleaned.size() < 3) return;

  int[] newFace_nodes = new int[cleaned.size()];
  for (int i = 0; i < cleaned.size(); i++) {
    PVector world = productFrame.toWorldPoint(cleaned.get(i));
    newFace_nodes[i] = ifcQueuePoint(cx + sx * world.x, cy + sy * world.y, cz + sz * world.z);
  }
  ifcQueueFace(newFace_nodes, m, tes, lyr, vsb, wgt, clz);
}

// ---------------------------------------------------------------------
// Bulk point/face staging - see the comment above ifcEmitFace() for why
// this doesn't call Create3D.add_Mesh(); this goes a step further and
// doesn't call allPoints.create()/allFaces.create() either, for a
// related but distinct reason. Both grow their backing array by
// exactly one element via concat() on every single call - correct, but
// O(n) of copying per call, so O(n^2) overall across n calls. That's
// invisible for an interactive create (a handful of points/faces at a
// time) but becomes the dominant cost once a single IFC import can mean
// hundreds of thousands of faces: profiling a real ~200,000-face Revit
// export showed import throughput visibly degrading as the import
// progressed (the array getting bigger making each subsequent copy
// bigger too) - the textbook signature of this exact kind of quadratic
// growth, confirmed to account for effectively the entire import time
// (parsing the file and walking the entity graph were each a few
// hundred milliseconds; the point/face creation itself was everything
// else).
//
// So every point/face this importer creates is queued here instead,
// and flushed - one single array of the right size allocated once,
// filled, and swapped in - at the very end of import_objects_IFC(),
// turning that O(n^2) into O(n). ifcBasePointCount/ifcBaseFaceCount
// capture how many points/faces already existed before this import
// started (reset per import, same as the other counters); a "virtual"
// index - what a point/face will actually end up at once flushed - is
// always ifcBase*Count + however many of this import's own have been
// queued so far, which is exactly what the two ifcQueue*() functions
// below hand back and use.
ArrayList<float[]> ifcPendingPoints = new ArrayList<float[]>();
ArrayList<int[]> ifcPendingFaceNodes = new ArrayList<int[]>();
ArrayList<int[]> ifcPendingFaceOptions = new ArrayList<int[]>();
int ifcBasePointCount = 0;
int ifcBaseFaceCount = 0;
// How many allModel2Ds entries (trees, people - see ifcLooksLikeATree()/
// ifcLooksLikeAPerson() above) already existed before this import
// started. Unlike points/faces, model2Ds are written straight into
// allModel2Ds as each product is processed rather than queued and
// flushed - but this is captured the same way and for a similar reason:
// ifcRotateImportedModelToTrueNorth() below needs to know exactly which
// trees/people this import just placed, not any that were already in
// the scene.
int ifcBaseModel2DCount = 0;

// A second, per-product staging layer in front of the one above: every
// point/face a product's own geometry produces lands here first, with
// purely local (0-based within this one product) indices, rather than
// going straight into ifcPendingPoints/ifcPendingFaceNodes/
// ifcPendingFaceOptions - because IFC_IMPORT_FURNITURE's own small-
// object exclusion (see that constant's own comment) needs to know a
// candidate's bounding box before deciding whether to keep its geometry
// at all, and building the geometry first, locally, is the
// straightforward way to get one. import_objects_IFC()'s own per-
// product loop calls ifcBeginProductStaging() before processing a
// product's Representation, then either ifcPromoteProductStaging()
// (append this product's local points/faces onto the real pending
// buffers, remapping local point indices to their final ones) or
// ifcDiscardProductStaging() (small object - drop them) once it knows
// whether to keep them. A product that was never going to produce Faces
// at all (a tree, a person, ...) never touches any of this - those
// branches of the loop return before reaching it.
ArrayList<float[]> ifcProductPendingPoints = new ArrayList<float[]>();
ArrayList<int[]> ifcProductPendingFaceNodes = new ArrayList<int[]>();
ArrayList<int[]> ifcProductPendingFaceOptions = new ArrayList<int[]>();
float ifcProductBBoxMinX, ifcProductBBoxMinY, ifcProductBBoxMinZ;
float ifcProductBBoxMaxX, ifcProductBBoxMaxY, ifcProductBBoxMaxZ;

void ifcBeginProductStaging () {
  ifcProductPendingPoints.clear();
  ifcProductPendingFaceNodes.clear();
  ifcProductPendingFaceOptions.clear();
  ifcProductBBoxMinX = ifcProductBBoxMinY = ifcProductBBoxMinZ = Float.MAX_VALUE;
  ifcProductBBoxMaxX = ifcProductBBoxMaxY = ifcProductBBoxMaxZ = -Float.MAX_VALUE;
}

// The largest extent of this product's own geometry so far, along any
// single axis - 0 if nothing's been queued yet (rather than a bogus
// huge number from the min/max sentinels never having been touched).
float ifcProductBBoxMaxDimension () {
  if (ifcProductPendingPoints.size() == 0) return 0;
  float dx = ifcProductBBoxMaxX - ifcProductBBoxMinX;
  float dy = ifcProductBBoxMaxY - ifcProductBBoxMinY;
  float dz = ifcProductBBoxMaxZ - ifcProductBBoxMinZ;
  return max(dx, max(dy, dz));
}

void ifcDiscardProductStaging () {
  ifcProductPendingPoints.clear();
  ifcProductPendingFaceNodes.clear();
  ifcProductPendingFaceOptions.clear();
}

// Appends this product's own staged points/faces onto the real pending
// buffers - point indices get remapped from local (0-based within the
// product) to their final virtual ones in the process, since every
// other product's own points may have landed in between. Mirrors
// Faces.create()'s own group-stop-index bookkeeping (see
// ifcQueueFace()'s old comment, before this layer existed) once per
// promoted face rather than once per queued one, since that's now only
// known to be real once promotion happens.
void ifcPromoteProductStaging () {
  int pointOffset = ifcBasePointCount + ifcPendingPoints.size();
  for (float[] p : ifcProductPendingPoints) {
    ifcPendingPoints.add(p);
  }
  for (int i = 0; i < ifcProductPendingFaceNodes.size(); i++) {
    int[] localNodes = ifcProductPendingFaceNodes.get(i);
    int[] globalNodes = new int[localNodes.length];
    for (int j = 0; j < localNodes.length; j++) {
      globalNodes[j] = localNodes[j] + pointOffset;
    }
    ifcPendingFaceNodes.add(globalNodes);
    ifcPendingFaceOptions.add(ifcProductPendingFaceOptions.get(i));
    if (allGroups.num > 0) {
      allGroups.Faces[allGroups.num - 1][1] = ifcBaseFaceCount + ifcPendingFaceNodes.size() - 1;
    }
  }
  ifcProductPendingPoints.clear();
  ifcProductPendingFaceNodes.clear();
  ifcProductPendingFaceOptions.clear();
}

int ifcQueuePoint (float x, float y, float z) {
  ifcProductPendingPoints.add(new float[]{x, y, z});
  if (x < ifcProductBBoxMinX) ifcProductBBoxMinX = x;
  if (y < ifcProductBBoxMinY) ifcProductBBoxMinY = y;
  if (z < ifcProductBBoxMinZ) ifcProductBBoxMinZ = z;
  if (x > ifcProductBBoxMaxX) ifcProductBBoxMaxX = x;
  if (y > ifcProductBBoxMaxY) ifcProductBBoxMaxY = y;
  if (z > ifcProductBBoxMaxZ) ifcProductBBoxMaxZ = z;
  return ifcProductPendingPoints.size() - 1; // local to this product - see ifcPromoteProductStaging()
}

void ifcQueueFace (int[] nodes, int m, int tes, int lyr, int vsb, int wgt, int clz) {
  ifcProductPendingFaceNodes.add(nodes);
  ifcProductPendingFaceOptions.add(new int[]{m, tes, lyr, vsb, wgt, clz});
}

// Called right after allGroups.beginNewGroup(): that call itself stamps
// the new group's own start-of-range as allFaces.nodes.length, the
// *real* array's current length - stale while this import's own faces
// are still only queued, not yet flushed into it. Corrects it to the
// virtual index the next *promoted* face will actually land on - safe
// to compute up front even though promotion happens later, since
// nothing else can land in ifcPendingFaceNodes between this group
// starting and this same product's own staging being promoted or
// discarded.
void ifcBeginGroupForPendingFaces () {
  if (allGroups.num > 0) {
    allGroups.Faces[allGroups.num - 1][0] = ifcBaseFaceCount + ifcPendingFaceNodes.size();
  }
}

// The flush itself - one allocation and one fill per array, each
// sized exactly right, rather than growing one element at a time.
void ifcFlushPendingGeometry () {
  // allVertices (allPoints' own backing array) is a top-level global in
  // globals.pde, not a field of the Points class itself - Points' own
  // methods just reference it directly as an enclosing-instance field,
  // the same way this function can.
  if (ifcPendingPoints.size() > 0) {
    float[][] newVertices = new float[ifcBasePointCount + ifcPendingPoints.size()][3];
    System.arraycopy(allVertices, 0, newVertices, 0, ifcBasePointCount);
    for (int i = 0; i < ifcPendingPoints.size(); i++) {
      newVertices[ifcBasePointCount + i] = ifcPendingPoints.get(i);
    }
    allVertices = newVertices;
  }

  if (ifcPendingFaceNodes.size() > 0) {
    int[][] newNodes = new int[ifcBaseFaceCount + ifcPendingFaceNodes.size()][];
    int[][] newOptions = new int[ifcBaseFaceCount + ifcPendingFaceOptions.size()][];
    System.arraycopy(allFaces.nodes, 0, newNodes, 0, ifcBaseFaceCount);
    System.arraycopy(allFaces.options, 0, newOptions, 0, ifcBaseFaceCount);
    for (int i = 0; i < ifcPendingFaceNodes.size(); i++) {
      newNodes[ifcBaseFaceCount + i] = ifcPendingFaceNodes.get(i);
      newOptions[ifcBaseFaceCount + i] = ifcPendingFaceOptions.get(i);
    }
    allFaces.nodes = newNodes;
    allFaces.options = newOptions;
  }

  ifcPendingPoints.clear();
  ifcPendingFaceNodes.clear();
  ifcPendingFaceOptions.clear();
}

ArrayList<PVector> ifcPolyLoopPoints (HashMap<Integer, StepEntity> ents, StepEntity loopEntity) {
  ArrayList<PVector> pts = new ArrayList<PVector>();
  if (loopEntity == null || !loopEntity.type.equals("IFCPOLYLOOP") || loopEntity.attrs.length == 0) {
    return pts;
  }
  for (String ref : ifcListTokens(loopEntity.attrs[0])) {
    pts.add(ifcPoint3(ents, ref));
  }
  return pts;
}

void ifcProcessFace (HashMap<Integer, StepEntity> ents, int faceId, IfcFrame productFrame,
  float cx, float cy, float cz, float sx, float sy, float sz,
  int m, int tes, int lyr, int vsb, int wgt, int clz) {

  StepEntity face = ents.get(faceId);
  if (face == null || !face.type.equals("IFCFACE") || face.attrs.length == 0) {
    ifcNoteSkipped("missing/unrecognized IfcFace");
    return;
  }

  // Collected first, rather than emitted bound-by-bound as they're
  // encountered: an IfcFaceBound (hole) can appear before its own
  // IfcFaceOuterBound in the file, and every hole needs bridging into
  // whichever outer bound(s) this face turns out to have (see the loop
  // below) - so this face's own holes have to be gathered in full
  // before any of them can actually be cut.
  ArrayList<ArrayList<PVector>> outerLoops = new ArrayList<ArrayList<PVector>>();
  ArrayList<ArrayList<PVector>> innerLoops = new ArrayList<ArrayList<PVector>>();

  for (String boundRef : ifcListTokens(face.attrs[0])) {
    StepEntity bound = ifcResolve(ents, boundRef);
    if (bound == null) continue;

    boolean isOuter = bound.type.equals("IFCFACEOUTERBOUND");
    boolean isInner = bound.type.equals("IFCFACEBOUND");
    if (!isOuter && !isInner) continue;
    if (bound.attrs.length < 2) continue;

    StepEntity loopEntity = ifcResolve(ents, bound.attrs[0]);
    ArrayList<PVector> loop = ifcPolyLoopPoints(ents, loopEntity);
    if (loop.size() < 3) continue;

    boolean orientation = bound.attrs[1].trim().equals(".T.");
    if (!orientation) ifcReverseInPlace(loop);

    if (isInner) innerLoops.add(loop); else outerLoops.add(loop);
  }

  if (innerLoops.size() > 0) ifcImportHolesCutCount += innerLoops.size();

  for (ArrayList<PVector> outer : outerLoops) {
    ArrayList<PVector> withHoles = PolygonHoles.mergeHolesIntoOuterLoop(outer, innerLoops);
    ifcEmitFace(withHoles, productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
  }

  if (outerLoops.size() == 0) ifcNoteSkipped("IfcFace with no usable outer bound");
}

void ifcProcessShell (HashMap<Integer, StepEntity> ents, int shellId, IfcFrame productFrame,
  float cx, float cy, float cz, float sx, float sy, float sz,
  int m, int tes, int lyr, int vsb, int wgt, int clz) {

  StepEntity shell = ents.get(shellId);
  if (shell == null || shell.attrs.length == 0
    || !(shell.type.equals("IFCCLOSEDSHELL") || shell.type.equals("IFCOPENSHELL"))) {
    ifcNoteSkipped("missing/unrecognized IfcShell");
    return;
  }

  for (String faceRef : ifcListTokens(shell.attrs[0])) {
    int faceId = ifcRefId(faceRef);
    if (faceId >= 0) {
      ifcProcessFace(ents, faceId, productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
    }
  }
}

void ifcProcessPolygonalFaceSet (HashMap<Integer, StepEntity> ents, StepEntity e, IfcFrame productFrame,
  float cx, float cy, float cz, float sx, float sy, float sz,
  int m, int tes, int lyr, int vsb, int wgt, int clz) {

  if (e.attrs.length < 3) {
    ifcNoteSkipped("malformed IfcPolygonalFaceSet");
    return;
  }
  StepEntity pointList = ifcResolve(ents, e.attrs[0]);
  if (pointList == null || pointList.attrs.length == 0) {
    ifcNoteSkipped("IfcPolygonalFaceSet with missing point list");
    return;
  }

  String[] rows = ifcListTokens(pointList.attrs[0]);
  PVector[] pool = new PVector[rows.length];
  for (int i = 0; i < rows.length; i++) pool[i] = ifcPointFromCoords(rows[i]);

  for (String faceRef : ifcListTokens(e.attrs[2])) {
    StepEntity faceEntity = ifcResolve(ents, faceRef);
    if (faceEntity == null || !faceEntity.type.startsWith("IFCINDEXEDPOLYGONALFACE") || faceEntity.attrs.length == 0) {
      ifcNoteSkipped("missing/unrecognized IfcIndexedPolygonalFace");
      continue;
    }

    ArrayList<PVector> loop = ifcIndexedFaceLoop(faceEntity.attrs[0], pool);
    if (loop.size() < 3) continue;

    ArrayList<ArrayList<PVector>> voids = new ArrayList<ArrayList<PVector>>();
    if (faceEntity.type.equals("IFCINDEXEDPOLYGONALFACEWITHVOIDS") && faceEntity.attrs.length > 1
      && faceEntity.attrs[1].trim().length() > 0 && !faceEntity.attrs[1].trim().equals("$")) {
      for (String voidTok : ifcListTokens(faceEntity.attrs[1])) {
        ArrayList<PVector> voidLoop = ifcIndexedFaceLoop(voidTok, pool);
        if (voidLoop.size() >= 3) voids.add(voidLoop);
      }
      ifcImportHolesCutCount += voids.size();
    }

    ArrayList<PVector> withVoids = PolygonHoles.mergeHolesIntoOuterLoop(loop, voids);
    ifcEmitFace(withVoids, productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
  }
}

// A face's or void's own list of 1-based indices (e.g. "(16,17,1,2,...)")
// resolved into the actual points they refer to in `pool` - shared
// between an IfcIndexedPolygonalFace(WithVoids)'s own outer index list
// and each of its void index lists above, since both are read exactly
// the same way. An out-of-range index (malformed file) is simply
// skipped rather than failing the whole face.
ArrayList<PVector> ifcIndexedFaceLoop (String idxListAttr, PVector[] pool) {
  ArrayList<PVector> loop = new ArrayList<PVector>();
  for (String idxTok : ifcListTokens(idxListAttr)) {
    int idx = (int) ifcFloat(idxTok); // 1-based index into pool
    if (idx >= 1 && idx <= pool.length) loop.add(pool[idx - 1]);
  }
  return loop;
}

void ifcProcessTriangulatedFaceSet (HashMap<Integer, StepEntity> ents, StepEntity e, IfcFrame productFrame,
  float cx, float cy, float cz, float sx, float sy, float sz,
  int m, int tes, int lyr, int vsb, int wgt, int clz) {

  if (e.attrs.length < 4) {
    ifcNoteSkipped("malformed IfcTriangulatedFaceSet");
    return;
  }
  StepEntity pointList = ifcResolve(ents, e.attrs[0]);
  if (pointList == null || pointList.attrs.length == 0) {
    ifcNoteSkipped("IfcTriangulatedFaceSet with missing point list");
    return;
  }

  String[] rows = ifcListTokens(pointList.attrs[0]);
  PVector[] pool = new PVector[rows.length];
  for (int i = 0; i < rows.length; i++) pool[i] = ifcPointFromCoords(rows[i]);

  for (String triTok : ifcListTokens(e.attrs[3])) {
    String[] idxToks = ifcListTokens(triTok);
    ArrayList<PVector> loop = new ArrayList<PVector>();
    for (String idxTok : idxToks) {
      int idx = (int) ifcFloat(idxTok);
      if (idx >= 1 && idx <= pool.length) loop.add(pool[idx - 1]);
    }
    if (loop.size() >= 3) {
      ifcEmitFace(loop, productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
    }
  }
}

// Builds a 2D profile (local to the profile's own placement, z omitted)
// for the swept-area profile defs this importer supports. Returns null
// - rather than guessing - for anything else (circular/parametric
// profiles, composite curves, ...).
ArrayList<float[]> ifcProfilePoints (HashMap<Integer, StepEntity> ents, String profileRef) {
  StepEntity profile = ifcResolve(ents, profileRef);
  if (profile == null) return null;

  if (profile.type.equals("IFCRECTANGLEPROFILEDEF") && profile.attrs.length >= 5) {
    float xDim = ifcFloat(profile.attrs[3]) * ifcLengthUnitScale;
    float yDim = ifcFloat(profile.attrs[4]) * ifcLengthUnitScale;
    float hx = xDim / 2, hy = yDim / 2;
    float[] placement = (profile.attrs[2].trim().startsWith("#"))
      ? ifcAxis2Placement2D(ents, profile.attrs[2]) : new float[]{0, 0, 1, 0};

    ArrayList<float[]> pts = new ArrayList<float[]>();
    pts.add(ifcApply2DPlacement(placement, -hx, -hy));
    pts.add(ifcApply2DPlacement(placement, hx, -hy));
    pts.add(ifcApply2DPlacement(placement, hx, hy));
    pts.add(ifcApply2DPlacement(placement, -hx, hy));
    return pts;
  }

  if (profile.type.equals("IFCARBITRARYCLOSEDPROFILEDEF") && profile.attrs.length >= 3) {
    StepEntity curve = ifcResolve(ents, profile.attrs[2]);
    if (curve == null) return null;

    if (curve.type.equals("IFCPOLYLINE") && curve.attrs.length > 0) {
      ArrayList<float[]> pts = new ArrayList<float[]>();
      for (String ptRef : ifcListTokens(curve.attrs[0])) {
        PVector p = ifcPoint3(ents, ptRef);
        pts.add(new float[]{p.x, p.y});
      }
      return ifcClosePolygon2D(pts);
    }

    if (curve.type.equals("IFCINDEXEDPOLYCURVE") && curve.attrs.length > 0) {
      return ifcIndexedPolyCurvePoints(ents, curve);
    }

    return null; // circle/B-spline/composite/... curves: not supported
  }

  return null; // circle/I-shape/composite/... profiles: not supported yet
}

// Strips a trailing point that exactly repeats the first (an explicitly
// closed loop, rather than this importer's own implicit "last point
// connects back to the first" convention), then requires at least a
// triangle's worth of points to actually be a profile. Shared between
// the IfcPolyline and IfcIndexedPolyCurve cases above.
ArrayList<float[]> ifcClosePolygon2D (ArrayList<float[]> pts) {
  if (pts.size() > 1) {
    float[] first = pts.get(0), lastPt = pts.get(pts.size() - 1);
    if (abs(first[0] - lastPt[0]) < 0.00001 && abs(first[1] - lastPt[1]) < 0.00001) {
      pts.remove(pts.size() - 1);
    }
  }
  return pts.size() >= 3 ? pts : null;
}

// IfcIndexedPolyCurve: Points(0), a shared IfcCartesianPointList2D/3D
// (z dropped if 3D - a profile curve is always meant to live in its own
// 2D plane), plus an OPTIONAL Segments(1) list of IfcLineIndex/
// IfcArcIndex runs of 1-based indices into that list, each select-typed
// in the raw STEP text as e.g. IFCLINEINDEX((1,2,3)). Checked against a
// real Revit export: every single one of its own 610 IfcIndexedPolyCurve
// instances omits Segments entirely - the overwhelmingly common case in
// practice - which per the IFC4 spec means an implicit polyline through
// every point in the list, in order; that's the case this fix actually
// targets (it was the root cause of several real missing objects - a
// generic floor slab, a roof slab, a curtain-wall panel - that all
// otherwise had perfectly ordinary IfcExtrudedAreaSolid geometry). The
// explicit-Segments case is handled too, for files from other tools:
// consecutive segments share their boundary point per spec, so a
// segment's own first index is skipped when it repeats the last point
// already added. Returns null - not approximated - the moment any
// segment turns out to be an IfcArcIndex (an actual circular arc), same
// as every other curved profile this importer doesn't support.
ArrayList<float[]> ifcIndexedPolyCurvePoints (HashMap<Integer, StepEntity> ents, StepEntity curve) {
  StepEntity pointList = ifcResolve(ents, curve.attrs[0]);
  if (pointList == null || pointList.attrs.length == 0) return null;

  String[] rows = ifcListTokens(pointList.attrs[0]);
  float[][] pool = new float[rows.length][];
  for (int i = 0; i < rows.length; i++) {
    PVector p = ifcPointFromCoords(rows[i]);
    pool[i] = new float[]{p.x, p.y};
  }

  String segmentsAttr = (curve.attrs.length > 1) ? curve.attrs[1].trim() : "";
  if (segmentsAttr.length() == 0 || segmentsAttr.equals("$") || segmentsAttr.equals("()")) {
    ArrayList<float[]> pts = new ArrayList<float[]>();
    for (float[] p : pool) pts.add(p);
    return ifcClosePolygon2D(pts);
  }

  ArrayList<float[]> pts = new ArrayList<float[]>();
  int lastIndex = -1;
  for (String segTok : ifcListTokens(segmentsAttr)) {
    String trimmed = segTok.trim();
    String upper = trimmed.toUpperCase();
    if (upper.startsWith("IFCARCINDEX")) return null; // an actual arc: not supported

    int parenStart = trimmed.indexOf('(');
    if (!upper.startsWith("IFCLINEINDEX") || parenStart < 0) return null; // unrecognized segment type
    for (String idxTok : ifcListTokens(ifcStripParens(trimmed.substring(parenStart)))) {
      int idx = (int) ifcFloat(idxTok) - 1; // 1-based in the file
      if (idx < 0 || idx >= pool.length) continue;
      if (idx == lastIndex) continue; // shared boundary point between consecutive segments
      pts.add(pool[idx]);
      lastIndex = idx;
    }
  }
  return ifcClosePolygon2D(pts);
}

void ifcProcessExtrudedAreaSolid (HashMap<Integer, StepEntity> ents, StepEntity e, IfcFrame productFrame,
  float cx, float cy, float cz, float sx, float sy, float sz,
  int m, int tes, int lyr, int vsb, int wgt, int clz) {

  if (e.attrs.length < 4) {
    ifcNoteSkipped("malformed IfcExtrudedAreaSolid");
    return;
  }

  ArrayList<float[]> profile2D = ifcProfilePoints(ents, e.attrs[0]);
  if (profile2D == null) {
    ifcNoteSkipped("unsupported swept-area profile (circular/composite/...)");
    return;
  }

  IfcFrame solidFrame = (e.attrs[1].trim().startsWith("#"))
    ? ifcAxis2Placement3DToFrame(ents, ifcResolve(ents, e.attrs[1])) : ifcIdentityFrame();

  PVector direction = (e.attrs[2].trim().startsWith("#")) ? ifcDirection3(ents, e.attrs[2]) : new PVector(0, 0, 1);
  direction.normalize();
  float depth = ifcFloat(e.attrs[3]) * ifcLengthUnitScale;

  PVector extrusionOffset = solidFrame.toWorldVector(direction);
  extrusionOffset.mult(depth);

  int n = profile2D.size();
  PVector[] bottom = new PVector[n];
  PVector[] top = new PVector[n];
  for (int i = 0; i < n; i++) {
    float[] p = profile2D.get(i);
    PVector local = solidFrame.toWorldPoint(p[0], p[1], 0); // still local to the product, not world yet
    bottom[i] = local;
    top[i] = PVector.add(local, extrusionOffset);
  }

  // Two end caps, opposite winding so their normals face outward in
  // opposite directions, plus one 4-point side face per profile edge -
  // the same shape Create3D.add_Mesh4()/"Mesh4" would build by hand.
  ArrayList<PVector> topCap = new ArrayList<PVector>();
  for (int i = 0; i < n; i++) topCap.add(top[i]);
  ifcEmitFace(topCap, productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);

  ArrayList<PVector> bottomCap = new ArrayList<PVector>();
  for (int i = n - 1; i >= 0; i--) bottomCap.add(bottom[i]);
  ifcEmitFace(bottomCap, productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);

  for (int i = 0; i < n; i++) {
    int j = (i + 1) % n;
    ArrayList<PVector> side = new ArrayList<PVector>();
    side.add(bottom[i]);
    side.add(bottom[j]);
    side.add(top[j]);
    side.add(top[i]);
    ifcEmitFace(side, productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
  }
}

void ifcProcessRepresentationItem (HashMap<Integer, StepEntity> ents, int itemId, IfcFrame productFrame,
  float cx, float cy, float cz, float sx, float sy, float sz,
  int m, int tes, int lyr, int vsb, int wgt, int clz) {

  StepEntity e = ents.get(itemId);
  if (e == null) {
    ifcNoteSkipped("missing representation item");
    return;
  }

  if (e.type.equals("IFCFACETEDBREP") || e.type.equals("IFCADVANCEDBREP")) {
    if (e.attrs.length > 0) {
      ifcProcessShell(ents, ifcRefId(e.attrs[0]), productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
    }
    return;
  }

  if (e.type.equals("IFCSHELLBASEDSURFACEMODEL")) {
    if (e.attrs.length > 0) {
      for (String shellRef : ifcListTokens(e.attrs[0])) {
        ifcProcessShell(ents, ifcRefId(shellRef), productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
      }
    }
    return;
  }

  if (e.type.equals("IFCPOLYGONALFACESET")) {
    ifcProcessPolygonalFaceSet(ents, e, productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
    return;
  }

  // IfcTriangulatedIrregularNetwork (a TIN - the usual shape of an
  // IfcSite's own topography/terrain surface) is a subtype of
  // IfcTriangulatedFaceSet that only appends one more attribute
  // (Flags, a per-triangle breakline/boundary marker this importer has
  // no use for) after the same Coordinates/Normals/Closed/CoordIndex/
  // PnIndex attributes - so the exact same reader handles both.
  if (e.type.equals("IFCTRIANGULATEDFACESET") || e.type.equals("IFCTRIANGULATEDIRREGULARNETWORK")) {
    ifcProcessTriangulatedFaceSet(ents, e, productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
    return;
  }

  if (e.type.equals("IFCEXTRUDEDAREASOLID")) {
    ifcProcessExtrudedAreaSolid(ents, e, productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
    return;
  }

  // Container items that just wrap/offset one more representation item
  // layer: pass straight through rather than counting them as skipped.
  if (e.type.equals("IFCGEOMETRICSET") || e.type.equals("IFCGEOMETRICCURVESET")) {
    if (e.attrs.length > 0) {
      for (String ref : ifcListTokens(e.attrs[0])) {
        ifcProcessRepresentationItem(ents, ifcRefId(ref), productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
      }
    }
    return;
  }

  if (e.type.equals("IFCMAPPEDITEM")) {
    ifcProcessMappedItem(ents, e, productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
    return;
  }

  // IfcBooleanResult/IfcBooleanClippingResult - how a door/window
  // opening gets cut into a wall or slab (Operator(0) is normally
  // .DIFFERENCE., FirstOperand(1) the wall/slab's own solid,
  // SecondOperand(2) the opening's own void shape, or a half-space for
  // a simpler planar clip). Full CSG evaluation - a general, robust 3D
  // solid difference - is a serious computational-geometry undertaking
  // in its own right and well out of scope for an importer like this
  // one. Instead, only FirstOperand is processed, so the wall/slab
  // still shows up as real geometry rather than being skipped outright
  // (the alternative, before this) - just without its opening actually
  // cut out, counted in ifcImportUncutOpeningCount for transparency
  // rather than silently left looking identical to a wall that was
  // never meant to have one. Recursing back into this same function
  // handles a FirstOperand that's itself another boolean result too -
  // several openings cut one after another, common for a wall with
  // more than one window - up to ifcBooleanResultDepth's own cap,
  // guarding against a pathological/cyclic chain the same way
  // ifcMappedItemDepth does for IfcMappedItem.
  if (e.type.equals("IFCBOOLEANRESULT") || e.type.equals("IFCBOOLEANCLIPPINGRESULT")) {
    if (e.attrs.length >= 2 && ifcBooleanResultDepth <= 100) {
      ifcImportUncutOpeningCount++;
      ifcBooleanResultDepth++;
      ifcProcessRepresentationItem(ents, ifcRefId(e.attrs[1]), productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
      ifcBooleanResultDepth--;
    } else {
      ifcNoteSkipped(e.type);
    }
    return;
  }

  ifcNoteSkipped(e.type); // swept curves, etc. - see file header
}

// IfcMappedItem: a "family/type" instance - the same shared geometry
// (MappingSource -> an IfcRepresentationMap) reused, positioned and
// scaled differently (MappingTarget, a IfcCartesianTransformationOperator3D)
// at every place it's used - commonly how a BIM authoring tool exports a
// repeated block like a door, window or piece of furniture.
//
// Resolving one fully means composing two placements: the mapping
// target (how this particular instance is positioned/scaled) and the
// inverse of the IfcRepresentationMap's own MappingOrigin (the local
// placement the shared geometry was originally authored against). This
// deliberately only applies the first: MappingOrigin is assumed to be
// the identity placement (origin at (0,0,0), default axes) rather than
// inverted and composed in, true for the large majority of real-world
// exporters (Revit/ArchiCAD/Tekla, among others, always emit an
// identity MappingOrigin in practice) - a file whose MappingOrigin
// genuinely isn't identity will see that block's instances offset by
// whatever that placement was.
void ifcProcessMappedItem (HashMap<Integer, StepEntity> ents, StepEntity e, IfcFrame productFrame,
  float cx, float cy, float cz, float sx, float sy, float sz,
  int m, int tes, int lyr, int vsb, int wgt, int clz) {

  if (ifcMappedItemDepth > 6) {
    ifcNoteSkipped("IfcMappedItem nested too deeply");
    return;
  }
  if (e.attrs.length < 2) {
    ifcNoteSkipped("malformed IfcMappedItem");
    return;
  }

  StepEntity repMap = ifcResolve(ents, e.attrs[0]);
  if (repMap == null || !repMap.type.equals("IFCREPRESENTATIONMAP") || repMap.attrs.length < 2) {
    ifcNoteSkipped("IfcMappedItem with missing/unrecognized MappingSource");
    return;
  }

  IfcFrame mapFrame = ifcCartesianTransformToFrame(ents, ifcResolve(ents, e.attrs[1]));
  IfcFrame combinedFrame = ifcComposeFrame(productFrame, mapFrame);

  int mappedShapeRepId = ifcRefId(repMap.attrs[1]);

  ifcMappedItemDepth++;
  ifcProcessShapeRepresentation(ents, mappedShapeRepId, combinedFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
  ifcMappedItemDepth--;
}

void ifcProcessShapeRepresentation (HashMap<Integer, StepEntity> ents, int repId, IfcFrame productFrame,
  float cx, float cy, float cz, float sx, float sy, float sz,
  int m, int tes, int lyr, int vsb, int wgt, int clz) {

  StepEntity rep = ents.get(repId);
  if (rep == null || !rep.type.equals("IFCSHAPEREPRESENTATION") || rep.attrs.length < 4) {
    ifcNoteSkipped("missing/unrecognized IfcShapeRepresentation");
    return;
  }
  for (String itemRef : ifcListTokens(rep.attrs[3])) {
    int itemId = ifcRefId(itemRef);
    if (itemId >= 0) {
      ifcProcessRepresentationItem(ents, itemId, productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
    }
  }
}

void ifcProcessProductRepresentation (HashMap<Integer, StepEntity> ents, int repId, IfcFrame productFrame,
  float cx, float cy, float cz, float sx, float sy, float sz,
  int m, int tes, int lyr, int vsb, int wgt, int clz) {

  StepEntity e = ents.get(repId);
  if (e == null) {
    ifcNoteSkipped("missing product representation");
    return;
  }

  if (e.type.equals("IFCPRODUCTDEFINITIONSHAPE")) {
    if (e.attrs.length < 3) return;
    for (String repRef : ifcListTokens(e.attrs[2])) {
      int shapeRepId = ifcRefId(repRef);
      if (shapeRepId >= 0) {
        ifcProcessShapeRepresentation(ents, shapeRepId, productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
      }
    }
    return;
  }

  if (e.type.equals("IFCSHAPEREPRESENTATION")) { // defensive: not per spec, but harmless if ever seen directly
    ifcProcessShapeRepresentation(ents, repId, productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
    return;
  }

  ifcNoteSkipped("unrecognized product representation (" + e.type + ")");
}

// Every IfcProduct subtype (IfcWall, IfcSlab, IfcDoor, IfcColumn, ...)
// shares the same fixed attribute prefix inherited from IfcRoot/
// IfcObject/IfcProduct: GlobalId(0), OwnerHistory(1), Name(2),
// Description(3), ObjectType(4), ObjectPlacement(5), Representation(6)
// - whatever a particular subtype adds (e.g. IfcWall's own Tag) always
// comes after index 6. So rather than hand-listing every IfcWall/
// IfcSlab/IfcDoor/... subtype name, this recognizes "a product this
// importer could do something with" structurally: not a relationship
// (IfcRel...), not a type definition (IfcXxxType - see below), not one
// of the non-geometry types above, and shaped like an IfcProduct.
//
// IfcXxxType entities (IfcBuildingElementProxyType, IfcFurnitureType,
// IfcWallType, IfcDoorType, ...) are *definitions* a project's own
// placed instances can share - never themselves a placed instance - but
// happen to share IfcRoot's same Name/Description prefix, and are
// numerous enough (attrs.length >= 7 easily) to otherwise pass this
// same structural check. ifcLooksLikeImportableProduct() below was
// already safe from these (a type's own attrs[6], HasPropertySets or
// RepresentationMaps depending on exact subtype, is always a list -
// "(#...)" - never a single reference starting with "#"), but every
// Name/ObjectType-driven exception elsewhere (ifcLooksLikeATree(),
// ifcLooksLikeAPerson(), ...) that checks ifcLooksLikeAProduct() alone,
// without also requiring a real Representation, was not: checked
// against a real Revit export, its own IfcBuildingElementProxyType
// entities for "RPC Female:YinYin" and "RPC Male:Alex" (the type
// definitions, not either's own several placed instances) were being
// counted and placed as two extra, bogus people, and the same file's
// own RPC tree types were inflating ifcImportTreeCount by exactly the
// same mechanism (7 tree types counted alongside 16 real tree
// instances). Excluding every *TYPE entity structurally, right here,
// fixes every one of these at once rather than one Name/ObjectType
// exception function at a time.
boolean ifcLooksLikeAProduct (StepEntity e) {
  if (e.attrs.length < 7) return false;
  if (!e.type.startsWith("IFC")) return false;
  if (e.type.startsWith("IFCREL")) return false;
  if (e.type.endsWith("TYPE")) return false;
  return !ifcNonGeometryProductTypes.contains(e.type);
}

// The further, geometry-specific requirement most products need: an
// explicit Representation reference - everything this importer does
// with Faces/materials needs one. A tree is the one exception (see
// ifcLooksLikeATree() above): it's still placed from just its name and
// placement even with Representation == $, so the product-collection
// loop in import_objects_IFC() checks ifcLooksLikeAProduct() plus
// ifcLooksLikeATree() directly for that case, rather than through this.
boolean ifcLooksLikeImportableProduct (StepEntity e) {
  return ifcLooksLikeAProduct(e) && e.attrs[6].trim().startsWith("#");
}

// ---------------------------------------------------------------------
// Material assignment: a product's actual associated IfcMaterial (an
// IfcRelAssociatesMaterial relationship, usually by way of
// IfcMaterialLayerSetUsage for walls/slabs, IfcMaterialProfileSetUsage
// for beams/columns, or IfcMaterialConstituentSet for anything made of
// several named materials at once) is read and its name matched,
// keyword-style, against the Materials.pde entries above. A product
// with no material association, or one whose name doesn't match any
// known keyword, falls back to the caller's normal m/cycling choice
// instead - this only ever opts a product IN to a specific color, never
// guesses one.
// ---------------------------------------------------------------------

// Strips one layer of STEP '...' string-literal quoting (with '' as an
// escaped quote inside one), e.g. IfcMaterial.Name's own raw token.
String ifcUnquote (String token) {
  token = token.trim();
  if (token.length() >= 2 && token.startsWith("'") && token.endsWith("'")) {
    return token.substring(1, token.length() - 1).replace("''", "'");
  }
  return token;
}

// Takes the first resolvable material name out of a list of refs
// (IfcMaterialLayer/IfcMaterialProfile/IfcMaterialConstituent/IfcMaterial
// refs, however this particular wrapper type names its members) - "the
// first layer/constituent" is a practical stand-in for "the material",
// not a claim about which one visually dominates the surface.
String ifcMaterialNameFromRefList (HashMap<Integer, StepEntity> ents, String listAttr, int depth) {
  for (String ref : ifcListTokens(listAttr)) {
    String name = ifcMaterialName(ents, ifcRefId(ref), depth + 1);
    if (name != null) return name;
  }
  return null;
}

// Resolves a RelatingMaterial reference (or anything it points through)
// down to a plain IfcMaterial's own Name, drilling through the common
// IfcMaterialLayerSetUsage/Set/Layer, IfcMaterialProfileSetUsage/Set/
// Profile, IfcMaterialConstituentSet/Constituent and IfcMaterialList
// wrapper chains - depth-capped against a pathological/cyclic
// reference. Returns null, rather than guessing, for anything else
// (IfcMaterialDefinitionRepresentation and friends - style/rendering
// data this importer has no use for).
String ifcMaterialName (HashMap<Integer, StepEntity> ents, int entityId, int depth) {
  if (depth > 6 || entityId < 0) return null;
  StepEntity e = ents.get(entityId);
  if (e == null) return null;

  if (e.type.equals("IFCMATERIAL")) {
    return e.attrs.length > 0 ? ifcUnquote(e.attrs[0]) : null;
  }
  if (e.type.equals("IFCMATERIALLAYER") || e.type.equals("IFCMATERIALPROFILE")) {
    return e.attrs.length > 0 ? ifcMaterialName(ents, ifcRefId(e.attrs[0]), depth + 1) : null;
  }
  if (e.type.equals("IFCMATERIALCONSTITUENT")) {
    return e.attrs.length > 2 ? ifcMaterialName(ents, ifcRefId(e.attrs[2]), depth + 1) : null;
  }
  if (e.type.equals("IFCMATERIALLAYERSET")) {
    return e.attrs.length > 0 ? ifcMaterialNameFromRefList(ents, e.attrs[0], depth) : null;
  }
  if (e.type.equals("IFCMATERIALPROFILESET") || e.type.equals("IFCMATERIALCONSTITUENTSET")) {
    return e.attrs.length > 2 ? ifcMaterialNameFromRefList(ents, e.attrs[2], depth) : null;
  }
  if (e.type.equals("IFCMATERIALLIST")) {
    return e.attrs.length > 0 ? ifcMaterialNameFromRefList(ents, e.attrs[0], depth) : null;
  }
  if (e.type.equals("IFCMATERIALLAYERSETUSAGE") || e.type.equals("IFCMATERIALPROFILESETUSAGE")) {
    return e.attrs.length > 0 ? ifcMaterialName(ents, ifcRefId(e.attrs[0]), depth + 1) : null;
  }
  return null;
}

// One pass over every IFCRELASSOCIATESMATERIAL in the file, building a
// productId -> material-name lookup - far cheaper than re-walking the
// relationship graph for every product individually. IfcRelAssociates'
// own attribute order: GlobalId(0), OwnerHistory(1), Name(2),
// Description(3), RelatedObjects(4); IfcRelAssociatesMaterial adds
// RelatingMaterial(5).
HashMap<Integer, String> ifcBuildProductMaterialNames (HashMap<Integer, StepEntity> ents) {
  HashMap<Integer, String> result = new HashMap<Integer, String>();
  for (StepEntity e : ents.values()) {
    if (!e.type.equals("IFCRELASSOCIATESMATERIAL") || e.attrs.length < 6) continue;
    String name = ifcMaterialName(ents, ifcRefId(e.attrs[5]), 0);
    if (name == null) continue;
    for (String ref : ifcListTokens(e.attrs[4])) {
      int productId = ifcRefId(ref);
      if (productId >= 0) result.put(productId, name);
    }
  }
  return result;
}

// Keyword match against a resolved material name, ordered so a name
// that happens to match more than one group (e.g. "Steel stud with batt
// insulation") resolves to its first/most specific hit rather than its
// last. Returns null - not a guess - when nothing matches, so the
// caller falls back to its normal material choice.
Integer ifcMaterialNameToConstant (String rawName) {
  if (rawName == null) return null;
  String name = rawName.toLowerCase();

  if (name.contains("concrete")) return IFC_MATERIAL_CONCRETE;
  if (name.contains("steel") || name.contains("metal") || name.contains("rebar")
    || name.contains("aluminium") || name.contains("aluminum") || name.contains("iron")) return IFC_MATERIAL_STEEL;
  if (name.contains("timber") || name.contains("wood") || name.contains("plywood") || name.contains("lumber")) return IFC_MATERIAL_TIMBER;
  if (name.contains("masonry") || name.contains("brick") || name.contains("block")
    || name.contains("cmu") || name.contains("stone")) return IFC_MATERIAL_MASONRY;
  if (name.contains("insulation")) return IFC_MATERIAL_INSULATION;
  if (name.contains("pvc") || name.contains("plastic") || name.contains("conduit") || name.contains("pipe")) return IFC_MATERIAL_MEP;
  if (name.contains("soil") || name.contains("earth") || name.contains("backfill") || name.contains("excavation")) return IFC_MATERIAL_EARTH;
  if (name.contains("glass") || name.contains("glazing")) return IFC_MATERIAL_GLASS;

  return null;
}

// ---------------------------------------------------------------------
// Units: a raw length value in the file is almost never already in
// metres - metric files commonly declare millimetres, and
// US/imperial-authored files declare feet or inches via a conversion-
// based unit - so every length this importer reads needs converting.
// ifcLengthUnitScale (see its own declaration above) is detected here,
// once per import, from IfcProject.UnitsInContext, and applied inside
// ifcPointFromCoords() for every coordinate/direction, plus wherever a
// profile dimension or extrusion depth is read directly as a number
// (see ifcProfilePoints()'s IfcRectangleProfileDef case and
// ifcProcessExtrudedAreaSolid()).
// ---------------------------------------------------------------------

// IfcProject (IFC4's IfcContext base attrs): GlobalId(0), OwnerHistory(1),
// Name(2), Description(3), ObjectType(4), LongName(5), Phase(6),
// RepresentationContexts(7), UnitsInContext(8) - not an IfcProduct
// (no ObjectPlacement/Representation), so ifcLooksLikeImportableProduct
// never matches it; found here by type instead.
float ifcDetectLengthUnitScale (HashMap<Integer, StepEntity> ents) {
  StepEntity project = null;
  for (StepEntity e : ents.values()) {
    if (e.type.equals("IFCPROJECT")) {
      project = e;
      break;
    }
  }
  if (project == null || project.attrs.length < 9) return 1;

  StepEntity unitAssignment = ifcResolve(ents, project.attrs[8]);
  if (unitAssignment == null || !unitAssignment.type.equals("IFCUNITASSIGNMENT") || unitAssignment.attrs.length == 0) return 1;

  for (String unitRef : ifcListTokens(unitAssignment.attrs[0])) {
    Float scale = ifcLengthUnitToMetresScale(ents, ifcResolve(ents, unitRef));
    if (scale != null) return scale;
  }
  return 1; // no declared length unit found - assume the file is already in metres
}

// The to-metres multiplier for one IfcUnitAssignment member, if it's
// the project's length unit - null for anything else (a different
// UnitType such as area/volume/plane angle, or a unit kind this
// importer doesn't resolve, e.g. IfcDerivedUnit).
Float ifcLengthUnitToMetresScale (HashMap<Integer, StepEntity> ents, StepEntity unit) {
  if (unit == null) return null;

  if (unit.type.equals("IFCSIUNIT")) {
    // IfcSIUnit: Dimensions(0), UnitType(1), Prefix(2, optional), Name(3).
    if (unit.attrs.length < 4 || !unit.attrs[1].trim().equals(".LENGTHUNIT.")) return null;
    return ifcSiPrefixScale(unit.attrs[2].trim());
  }

  if (unit.type.equals("IFCCONVERSIONBASEDUNIT") || unit.type.equals("IFCCONVERSIONBASEDUNITWITHOFFSET")) {
    // IfcConversionBasedUnit: Dimensions(0), UnitType(1), Name(2),
    // ConversionFactor(3) - a ref to an IfcMeasureWithUnit. The *WithOffset
    // subtype only adds a ConversionOffset after this, so the index is
    // the same for both. Used for feet/inches/etc.
    if (unit.attrs.length < 4 || !unit.attrs[1].trim().equals(".LENGTHUNIT.")) return null;
    StepEntity measureWithUnit = ifcResolve(ents, unit.attrs[3]);
    if (measureWithUnit == null || !measureWithUnit.type.equals("IFCMEASUREWITHUNIT") || measureWithUnit.attrs.length < 2) return null;
    // ValueComponent(0) is a typed numeric value (e.g. "IFCLENGTHMEASURE(0.3048)"
    // for 'foot'); UnitComponent(1), the unit it's relative to, is assumed
    // to be a plain metre (scale 1) rather than recursively resolved -
    // true for the large majority of real-world files, where a
    // conversion-based unit is defined directly against the SI base unit.
    return ifcTypedValueNumber(measureWithUnit.attrs[0]);
  }

  return null;
}

float ifcSiPrefixScale (String prefixToken) {
  if (!prefixToken.startsWith(".")) return 1; // "$" - no prefix - the bare SI unit (metre)
  switch (prefixToken) {
    case ".EXA.":   return 1e18;
    case ".PETA.":  return 1e15;
    case ".TERA.":  return 1e12;
    case ".GIGA.":  return 1e9;
    case ".MEGA.":  return 1e6;
    case ".KILO.":  return 1e3;
    case ".HECTO.": return 1e2;
    case ".DECA.":  return 1e1;
    case ".DECI.":  return 1e-1;
    case ".CENTI.": return 1e-2;
    case ".MILLI.": return 1e-3;
    case ".MICRO.": return 1e-6;
    case ".NANO.":  return 1e-9;
    case ".PICO.":  return 1e-12;
    case ".FEMTO.": return 1e-15;
    case ".ATTO.":  return 1e-18;
    default:        return 1; // an exponent-only prefix (e.g. .KIBI. etc.) - not length-relevant in practice
  }
}

// Pulls the number out of a typed value token - "IFCLENGTHMEASURE(0.3048)"
// becomes 0.3048 - or parses it directly if it's already a bare number.
float ifcTypedValueNumber (String token) {
  token = token.trim();
  int paren = token.indexOf('(');
  if (paren >= 0 && token.endsWith(")")) {
    return ifcFloat(token.substring(paren + 1, token.length() - 1));
  }
  return ifcFloat(token);
}

// ---------------------------------------------------------------------
// Trees: IFC has no single dedicated entity for a tree (unlike a
// window or a wall) - a tree is typically authored as a generic
// furnishing/proxy/geographic element whose Name or ObjectType just
// says so (e.g. a Revit family instance named "Tree - Deciduous -
// Generic : 30'"). So rather than importing a tree's own (often just a
// low-detail box or cylinder) geometry as Faces, a product whose Name
// or ObjectType names it as a tree is instead placed as one of the
// app's own native 2D billboard trees (allModel2Ds.create("TREES", ...),
// the same thing "Add 2D-Trees on Land"/the "Tree2" command create) at
// that product's own placement origin - a nicer result than a crude
// imported proxy box, and consistent with every other
// product-type-driven choice this importer makes (windows -> glass,
// IfcSite -> earth).
// ---------------------------------------------------------------------

HashSet<String> ifcTreeNameWords = new HashSet<String>(Arrays.asList("tree", "trees"));

// A whole-word match against a product's own Name/ObjectType, not a
// raw substring search - "Street Tree #14" matches ("tree" is its own
// word), "Street Lamp" does not ("street" is never mistaken for
// containing "tree").
boolean ifcNameHasWord (String rawAttr, HashSet<String> words) {
  String text = ifcUnquote(rawAttr);
  if (text == null) return false;
  for (String word : text.toLowerCase().split("[^a-z0-9]+")) {
    if (words.contains(word)) return true;
  }
  return false;
}

// A whole-word match requiring every one of several words to be
// present (in any order), rather than any single one - see
// ifcLooksLikeAPerson()'s own RPC check below for why: "rpc" alone is
// nowhere near specific enough on its own (it also names RPC trees and
// RPC cars, already handled their own ways), but "rpc" together with
// "male"/"female" is - and requiring the conjunction, rather than
// either word alone, avoids "male"/"female" misfiring on an unrelated
// MEP male/female connector/adapter/coupling, a common naming pattern
// that has nothing to do with people.
boolean ifcNameHasAllWords (String rawAttr, HashSet<String> words) {
  String text = ifcUnquote(rawAttr);
  if (text == null) return false;
  HashSet<String> tokens = new HashSet<String>(Arrays.asList(text.toLowerCase().split("[^a-z0-9]+")));
  return tokens.containsAll(words);
}

boolean ifcLooksLikeATree (StepEntity e) {
  if (e.attrs.length > 2 && ifcNameHasWord(e.attrs[2], ifcTreeNameWords)) return true; // Name
  if (e.attrs.length > 4 && ifcNameHasWord(e.attrs[4], ifcTreeNameWords)) return true; // ObjectType
  return false;
}

// Looks for a "<number><unit>" height hint in a tree's own Name/
// ObjectType text - common in furniture-family naming conventions
// (e.g. "Tree - Deciduous - Generic : 30'", "Oak 9m", "Pine 4500mm") -
// recognizing metres, millimetres, centimetres, feet (' or ft). Skips
// over any earlier number in the text that isn't followed by a
// recognized unit (so "Tree 2 - Oak 30'" still finds 30', not 2), and
// returns null - not a guess - when nothing parseable is found; the
// caller falls back to a fixed default height the same way "Tree2"'s
// own h=10 default does.
Float ifcParseHeightHint (String rawAttr) {
  String text = ifcUnquote(rawAttr);
  if (text == null) return null;

  int n = text.length();
  for (int i = 0; i < n; i++) {
    if (!Character.isDigit(text.charAt(i))) continue;

    int start = i;
    while (start > 0 && (Character.isDigit(text.charAt(start - 1)) || text.charAt(start - 1) == '.')) start--;
    int end = i;
    while (end + 1 < n && (Character.isDigit(text.charAt(end + 1)) || text.charAt(end + 1) == '.')) end++;

    float value;
    try {
      value = Float.parseFloat(text.substring(start, end + 1));
    }
    catch (Exception ex) {
      i = end;
      continue;
    }

    int unitStart = end + 1;
    if (unitStart < n && text.charAt(unitStart) == ' ') unitStart++;
    String rest = text.substring(unitStart).toLowerCase();

    if (rest.startsWith("mm")) return value * 0.001f;
    if (rest.startsWith("cm")) return value * 0.01f;
    if (rest.startsWith("m") && !rest.startsWith("mm")) return value;
    if (rest.startsWith("'") || rest.startsWith("ft")) return value * 0.3048f;

    i = end; // no recognized unit right after this number - keep scanning
  }
  return null;
}

// ---------------------------------------------------------------------
// Solar devices: PV panels, solar collectors and solar hybrid panels
// always draw with IFC_MATERIAL_SOLAR (material 0) - see that
// constant's own comment for why. Caught either by entity type
// (IfcSolarDevice, see ifcSolarProductTypes above) or, for the many
// files that don't use that IFC4.3 entity, by a Name/ObjectType word
// match - the same whole-word approach ifcNameHasWord() already does
// for trees, just with a different word set.
// ---------------------------------------------------------------------

HashSet<String> ifcSolarNameWords = new HashSet<String>(Arrays.asList(
  "solar", "photovoltaic", "pv"
  ));

boolean ifcLooksLikeASolarDevice (StepEntity e) {
  if (ifcSolarProductTypes.contains(e.type)) return true;
  if (e.attrs.length > 2 && ifcNameHasWord(e.attrs[2], ifcSolarNameWords)) return true; // Name
  if (e.attrs.length > 4 && ifcNameHasWord(e.attrs[4], ifcSolarNameWords)) return true; // ObjectType
  return false;
}

// ---------------------------------------------------------------------
// Shading devices: louvers, brise-soleil, shutters, jalousies, awnings
// and other fixed sun-shading elements. Caught either by entity type
// (IfcShadingDevice, IFC4's own dedicated entity for this) or, for any
// IFC2x3 file (the entity didn't exist yet) and plenty of IFC4 ones too,
// by a Name/ObjectType word match - the same mechanism solar devices/
// vegetation/... above already use. See IFC_MATERIAL_STEEL's own use in
// import_objects_IFC()'s material-choice block, and the furniture-
// exclusion bypass in its product-collection loop, for what this
// actually changes.
// ---------------------------------------------------------------------

HashSet<String> ifcShadingDeviceProductTypes = new HashSet<String>(Arrays.asList(
  "IFCSHADINGDEVICE"
  ));

HashSet<String> ifcShadingDeviceNameWords = new HashSet<String>(Arrays.asList(
  "louvre", "louvres", "louver", "louvers", "jalousie", "jalousies",
  "shutter", "shutters", "sunshade", "sunshades", "awning", "awnings",
  "brisesoleil"
  ));

// "Brise Soleil"/"brise-soleil" - two separate words/tokens once split
// (see ifcNameHasWord()'s own [^a-z0-9]+ split, which treats a hyphen
// the same as a space) - so neither "brise" nor "soleil" alone is in
// ifcShadingDeviceNameWords above: each is too generic by itself
// ("soleil" is simply French for "sun") to safely match alone the way
// ifcShadingDeviceNameWords's own single words do, but the two together
// are specific enough - the same tradeoff ifcNameHasAllWords() already
// makes for "washing machine"/"range hood" above.
HashSet<String> ifcBriseSoleilWords = new HashSet<String>(Arrays.asList("brise", "soleil"));

boolean ifcLooksLikeAShadingDevice (StepEntity e) {
  if (ifcShadingDeviceProductTypes.contains(e.type)) return true;
  if (e.attrs.length > 2 && ifcNameHasWord(e.attrs[2], ifcShadingDeviceNameWords)) return true; // Name
  if (e.attrs.length > 4 && ifcNameHasWord(e.attrs[4], ifcShadingDeviceNameWords)) return true; // ObjectType
  if (e.attrs.length > 2 && ifcNameHasAllWords(e.attrs[2], ifcBriseSoleilWords)) return true; // Name
  if (e.attrs.length > 4 && ifcNameHasAllWords(e.attrs[4], ifcBriseSoleilWords)) return true; // ObjectType
  return false;
}

// ---------------------------------------------------------------------
// People - human/entourage/scale-figure reference models, usually a
// detailed mesh placed via IfcMappedItem. Caught three ways: IfcActor
// (an unambiguous entity type for this), IfcBuildingElementProxy with
// an ObjectType of "Human", "Entourage" or "Scale Figure" (the common
// Revit convention), or - independently of entity type or ObjectType -
// a product whose own geometry sits on an IfcPresentationLayerAssignment
// named A-PROP-HUMN or A-PROP-ENTS (the AIA CAD layer-naming standard
// for human/entourage props; older, AutoCAD-style exports often tag
// geometry this way instead of, or in addition to, ObjectType). Placed
// as one of the app's own native 2D people (allModel2Ds, the same
// "PEOPLE" kind "Add People on Land"/the "Person" command create) at
// that product's own placement origin - a fixed height (2.5, the same
// constant default "Person" itself always uses, unlike a tree's own
// parsed-or-default height) rather than importing the mapped mesh.
// ---------------------------------------------------------------------

HashSet<String> ifcPersonNameWords = new HashSet<String>(Arrays.asList(
  "human", "entourage"
  ));

// Archvision RPC ("Rich Photorealistic Content") is a widely-used
// Revit/3ds Max plugin for photorealistic entourage - people, cars,
// trees, shrubs - imported into Revit as a generic proxy family and
// named "RPC <Category>:<Specific Name>" (e.g. "RPC Female:YinYin",
// "RPC Male:Alex") on export; the RPC trees already catch via
// ifcTreeNameWords above ("RPC Tree - Deciduous:..." contains "tree"),
// and an RPC car (e.g. "RPC Beetle") is left as real imported geometry
// - just the two human categories need catching here. Checked against
// a real Revit export rather than assumed: that file's own
// IfcBuildingElementProxy instances included exactly these two
// ("RPC Female:YinYin", "RPC Male:Alex"), nothing else RPC-person-like.
// "rpc child"/"rpc person"/"rpc people" are included on the same
// pattern as a reasonable guess at other RPC human categories, not
// themselves confirmed against real export data.
ArrayList<HashSet<String>> ifcRpcPersonWordGroups = new ArrayList<HashSet<String>>(Arrays.asList(
  new HashSet<String>(Arrays.asList("rpc", "male")),
  new HashSet<String>(Arrays.asList("rpc", "female")),
  new HashSet<String>(Arrays.asList("rpc", "child")),
  new HashSet<String>(Arrays.asList("rpc", "person")),
  new HashSet<String>(Arrays.asList("rpc", "people"))
  ));

boolean ifcNameHasRpcPersonPhrase (String rawAttr) {
  for (HashSet<String> words : ifcRpcPersonWordGroups) {
    if (ifcNameHasAllWords(rawAttr, words)) return true;
  }
  return false;
}

HashSet<String> ifcPersonObjectTypeValues = new HashSet<String>(Arrays.asList(
  "human", "entourage", "scale figure"
  ));

HashSet<String> ifcPersonLayerNames = new HashSet<String>(Arrays.asList(
  "a-prop-humn", "a-prop-ents"
  ));

// One pass over every IfcPresentationLayerAssignment in the file,
// collecting the entity id of every item assigned to a human/entourage
// layer (a representation item, or sometimes a whole
// IfcShapeRepresentation) - far cheaper than re-walking every layer
// assignment per product. IfcPresentationLayerAssignment's own
// attribute order: Name(0), Description(1), AssignedItems(2),
// Identifier(3).
HashSet<Integer> ifcBuildPersonLayerItemIds (HashMap<Integer, StepEntity> ents) {
  HashSet<Integer> ids = new HashSet<Integer>();
  for (StepEntity e : ents.values()) {
    if (!e.type.equals("IFCPRESENTATIONLAYERASSIGNMENT") || e.attrs.length < 3) continue;
    String name = ifcUnquote(e.attrs[0]);
    if (name == null || !ifcPersonLayerNames.contains(name.trim().toLowerCase())) continue;
    for (String ref : ifcListTokens(e.attrs[2])) {
      int id = ifcRefId(ref);
      if (id >= 0) ids.add(id);
    }
  }
  return ids;
}

// Whether a product's own Representation - walked the same way
// ifcProcessProductRepresentation()/ifcProcessShapeRepresentation() do,
// just checking membership instead of building geometry - includes
// anything a human/entourage IfcPresentationLayerAssignment claimed
// (see ifcBuildPersonLayerItemIds() above): the IfcShapeRepresentation
// itself, or any one of its own representation items (most often
// exactly the IfcMappedItem the actual mesh comes through).
boolean ifcProductIsOnPersonLayer (HashMap<Integer, StepEntity> ents, int repId, HashSet<Integer> personLayerItemIds) {
  if (personLayerItemIds.isEmpty() || repId < 0) return false;
  StepEntity e = ents.get(repId);
  if (e == null) return false;
  if (personLayerItemIds.contains(repId)) return true;

  if (e.type.equals("IFCPRODUCTDEFINITIONSHAPE") && e.attrs.length >= 3) {
    for (String repRef : ifcListTokens(e.attrs[2])) {
      if (ifcProductIsOnPersonLayer(ents, ifcRefId(repRef), personLayerItemIds)) return true;
    }
    return false;
  }

  if (e.type.equals("IFCSHAPEREPRESENTATION") && e.attrs.length >= 4) {
    for (String itemRef : ifcListTokens(e.attrs[3])) {
      int itemId = ifcRefId(itemRef);
      if (itemId >= 0 && personLayerItemIds.contains(itemId)) return true;
    }
  }

  return false;
}

boolean ifcLooksLikeAPerson (HashMap<Integer, StepEntity> ents, StepEntity e, int repId, HashSet<Integer> personLayerItemIds) {
  if (e.type.equals("IFCACTOR")) return true;

  if (e.type.equals("IFCBUILDINGELEMENTPROXY") && e.attrs.length > 4) {
    String objectType = ifcUnquote(e.attrs[4]);
    if (objectType != null && ifcPersonObjectTypeValues.contains(objectType.trim().toLowerCase())) return true;
  }

  if (e.attrs.length > 2 && ifcNameHasWord(e.attrs[2], ifcPersonNameWords)) return true; // Name
  if (e.attrs.length > 4 && ifcNameHasWord(e.attrs[4], ifcPersonNameWords)) return true; // ObjectType
  if (e.attrs.length > 2 && ifcNameHasRpcPersonPhrase(e.attrs[2])) return true; // Name, e.g. "RPC Female:YinYin"
  if (e.attrs.length > 4 && ifcNameHasRpcPersonPhrase(e.attrs[4])) return true; // ObjectType, same pattern

  return ifcProductIsOnPersonLayer(ents, repId, personLayerItemIds);
}

// {start, start+1, ..., start+count-1} - the same shape Select3D's own
// rangeIds(n) returns ({0, ..., n-1}), just offset to start at an
// arbitrary index instead of always 0, since what needs selecting here
// is a contiguous range somewhere in the middle of allFaces/allModel2Ds
// (everything this import just added), not the whole collection from
// its start the way rangeIds(n) itself assumes.
int[] ifcRangeIdsFrom (int start, int count) {
  int[] ids = new int[max(count, 0)];
  for (int i = 0; i < ids.length; i++) ids[i] = start + i;
  return ids;
}

// Selects everything this one import just produced - every face (and,
// through it, every point a face actually uses - see
// Select3D.get_Face_Vertices()) and every placed tree/person (see
// ifcLooksLikeATree()/ifcLooksLikeAPerson() above) - and rotates that
// selection, as a whole, around the world origin by angleDegrees, about
// Z (Rotate3D.selection's the_Vector=2) - exactly the "select all the
// imported BIM IFC model and rotate them around the origin" IFC_IMPORT_NORTH
// is meant to do. Does nothing - not even touching currentObjectCategory
// or either selection - when angleDegrees is zero: an unrotated IfcSite
// (or no IfcSite at all) means there's nothing to correct for, and a
// zero-degree "rotation" should leave the model and the user's own
// current selection exactly as they were, not just numerically
// equivalent to leaving them alone. Must run after
// ifcFlushPendingGeometry() - baseFaceCount/baseModel2DCount only
// identify this import's own faces/model2Ds once they've actually
// landed in allFaces/allModel2Ds. Temporarily switches
// currentObjectCategory and the FACE/MODEL2D selections to do its own
// rotation, then restores whatever was selected before it ran, so this
// is invisible to the user's own current selection afterward.
void ifcRotateImportedModelToTrueNorth (float angleDegrees, int baseFaceCount, int baseModel2DCount) {
  if (angleDegrees == 0) return; // Don't rotate if the angle is zero.

  int newFaceCount = allFaces.nodes.length - baseFaceCount;
  int newModel2DCount = allModel2Ds.num - baseModel2DCount;
  if (newFaceCount <= 0 && newModel2DCount <= 0) return; // nothing was actually imported

  int savedCategory = currentObjectCategory;
  int[] savedFaceSelection = Select3D.faceSelection;
  int[] savedModel2DSelection = Select3D.model2DSelection;

  if (newFaceCount > 0) {
    currentObjectCategory = ObjectCategory.FACE;
    Select3D.faceSelection = ifcRangeIdsFrom(baseFaceCount, newFaceCount);
    Rotate3D.selection(0, 0, 0, angleDegrees, 2);
  }

  if (newModel2DCount > 0) {
    currentObjectCategory = ObjectCategory.MODEL2D;
    Select3D.model2DSelection = ifcRangeIdsFrom(baseModel2DCount, newModel2DCount);
    Rotate3D.selection(0, 0, 0, angleDegrees, 2);
  }

  currentObjectCategory = savedCategory;
  Select3D.faceSelection = savedFaceSelection;
  Select3D.model2DSelection = savedModel2DSelection;
}

// ---------------------------------------------------------------------
// Entry point - mirrors import_objects_OBJ(FileName, m, tes, lyr, vsb,
// wgt, clz, cx, cy, cz, sx, sy, sz)'s own signature, including the
// m == -1 "auto-cycle through 8 materials" convention (there, cycled
// once per OBJ "g" line; here, once per imported IfcProduct).
// ---------------------------------------------------------------------
void import_objects_IFC (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  // Only when ifcImportShowOptionsDialog (above) was actually set, by
  // selectFile_ImportIfc() - i.e. only on the real, interactive "pick a
  // file from the menu" path - and only once per import, even if this
  // same import is retried: consumed (reset) right here regardless of
  // whether the dialog is shown or how the person answers it. Placed
  // after FileName is already known - a real path on disk - rather than
  // back when selectFile_ImportIfc() first asked for one, so whoever's
  // importing can see the file itself (its size among other things)
  // before deciding, say, whether importing furniture is worth the
  // extra time. A cancelled dialog aborts the whole import immediately,
  // before touching allPoints/allFaces/ifcImport* or printing anything
  // below - as if import_objects_IFC() had never been called at all.
  if (ifcImportShowOptionsDialog) {
    ifcImportShowOptionsDialog = false;
    if (!ifcShowImportOptionsDialog()) return;
  }

  println("Importing IFC. Please wait...");

  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  ifcImportSkippedCount = 0;
  ifcImportHolesCutCount = 0;
  ifcImportTreeCount = 0;
  ifcImportPersonCount = 0;
  ifcImportUncutOpeningCount = 0;
  ifcImportFurnitureExcludedCount = 0;
  ifcImportSmallObjectExcludedCount = 0;
  ifcImportNorthRotationAngle = 0;
  ifcImportGotoLatLon = null;
  ifcImportSkippedReasons = new HashMap<String, Integer>();
  ifcLengthUnitScale = 1;
  ifcMappedItemDepth = 0;
  ifcBooleanResultDepth = 0;
  ifcPendingPoints.clear();
  ifcPendingFaceNodes.clear();
  ifcPendingFaceOptions.clear();
  ifcBasePointCount = allPoints.getLength();
  ifcBaseFaceCount = allFaces.nodes.length;
  ifcBaseModel2DCount = allModel2Ds.num;

  String fullText = join(loadStrings(FileName), " ");
  HashMap<Integer, StepEntity> ents = ifcParseEntities(fullText);

  // Computed up front, alongside the length-unit scale just below, since
  // neither depends on anything the product-collection loop further
  // down does - the actual rotation only happens once the geometry
  // itself exists (see ifcRotateImportedModelToTrueNorth()'s own call,
  // after ifcFlushPendingGeometry(), near the end of this function).
  // Left at 0 - i.e. IFC_IMPORT_NORTH's own "don't rotate" case -
  // without even reading the file's IfcSite, whenever the toggle itself
  // is off.
  ifcImportNorthRotationAngle = ifcImportOrient ? ifcTrueNorthAngleDegrees(ents) : 0;

  // Detected before any geometry is read, since ifcPointFromCoords()
  // and the profile-dimension/extrusion-depth readers below all apply
  // it as they go, rather than importing in the file's own units and
  // rescaling the result afterward.
  ifcLengthUnitScale = ifcDetectLengthUnitScale(ents);

  int effectiveMaterial = (m == -1) ? 0 : m;

  // One pass up front, rather than re-walking the relationship graph
  // per product.
  HashMap<Integer, String> productMaterialNames = ifcBuildProductMaterialNames(ents);
  HashSet<Integer> personLayerItemIds = ifcBuildPersonLayerItemIds(ents);

  // Processed in ascending entity-id order (which almost always matches
  // the file's own declaration order) rather than ents.keySet()'s own
  // HashMap<Integer,...> order, which Java never guarantees - without
  // this, two imports of the exact same file could cycle materials
  // through a different product order from one run to the next.
  ArrayList<Integer> productIds = new ArrayList<Integer>();
  for (Integer id : ents.keySet()) {
    StepEntity candidate = ents.get(id);

    if (!ifcImportFurniture && candidate != null
      && (ifcFurnitureProductTypes.contains(candidate.type) || ifcLooksLikeExcludedApplianceOrCabinet(candidate))
      && !ifcLooksLikeATree(candidate) && !ifcLooksLikeASolarDevice(candidate)
      && !ifcLooksLikeAPool(candidate) && !ifcLooksLikeVegetation(candidate)
      && !ifcLooksLikeAShadingDevice(candidate)) {
      // Ordinary furniture, a sanitary/MEP-terminal fixture, or a
      // Name/ObjectType-matched kitchen appliance or cabinet/storage
      // item (see ifcFurnitureProductTypes and
      // ifcLooksLikeExcludedApplianceOrCabinet() above) - none of them
      // one of the special-cased categories above (tree, solar device,
      // pool, vegetation, shading device), which keep working
      // regardless of this toggle - skipped entirely while
      // ifcImportFurniture is false, counted separately from
      // ifcImportSkippedCount since this is a deliberate exclusion, not
      // an unsupported item.
      ifcImportFurnitureExcludedCount++;
      continue;
    }

    if (ifcLooksLikeImportableProduct(candidate)) {
      productIds.add(id);
    } else if (ifcLooksLikeAProduct(candidate) && ifcLooksLikeATree(candidate)) {
      // A tree is placed from just its name/placement even with no
      // Representation of its own (a lightweight landscape/vegetation
      // placeholder, common in practice) - every other product without
      // one is skipped exactly because it has nothing to import.
      productIds.add(id);
    } else if (candidate != null && candidate.type.equals("IFCSPACE") && candidate.attrs.length >= 7
      && candidate.attrs[6].trim().startsWith("#") && ifcLooksLikeAPool(candidate)) {
      // An IfcSpace specifically named as a pool still imports its own
      // water surface - every other IfcSpace stays excluded above
      // (ifcNonGeometryProductTypes), since a swimming pool is commonly
      // modeled as a space/volume rather than a solid building element.
      // Unlike a tree, water has no native substitute to fall back on,
      // so this still requires an actual Representation.
      productIds.add(id);
    } else if (candidate != null && ifcLooksLikeAProduct(candidate)
      && ifcLooksLikeAPerson(ents, candidate, -1, personLayerItemIds)) {
      // A person/entourage figure is placed from just its name/
      // placement even with no Representation of its own, same
      // reasoning as a tree - passing repId -1 here is exact, not a
      // placeholder: reaching this branch at all already means this
      // candidate has no usable Representation (ifcLooksLikeAProduct()
      // just passed, ifcLooksLikeImportableProduct() didn't), so
      // there's nothing for the layer check to look up regardless.
      productIds.add(id);
    }
  }
  ifcSortAscending(productIds);

  for (Integer id : productIds) {
    StepEntity e = ents.get(id);

    // The new group has to exist *before* any face is created into it:
    // Faces.create() stamps every face it creates into allGroups' own
    // current (last) group, exactly like import_objects_OBJ.pde does on
    // every "g" line - so, unlike the material choice below, this can't
    // be deferred until after we know whether the product actually
    // produced geometry.
    if (addToLastGroup == false) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
      ifcBeginGroupForPendingFaces();
    }

    String placementTok = e.attrs[5].trim();
    IfcFrame productFrame = placementTok.startsWith("#")
      ? ifcPlacementToFrame(ents, ifcRefId(placementTok)) : ifcIdentityFrame();

    // A tree (see ifcLooksLikeATree() above) is placed as one of the
    // app's own native 2D trees at this product's placement origin
    // instead of going through the normal Faces/material pipeline at
    // all below - skipped here are not just the glass/material-name/
    // topography choice, but also the m == -1 cycle (same reasoning as
    // every other product-type-driven choice: it shouldn't leave a gap
    // in the opaque cycle either) and the actual geometry import
    // (ifcProcessProductRepresentation), since a billboard tree has no
    // Faces of its own to speak of.
    if (ifcLooksLikeATree(e)) {
      Float heightHint = (e.attrs.length > 2) ? ifcParseHeightHint(e.attrs[2]) : null;
      if (heightHint == null && e.attrs.length > 4) heightHint = ifcParseHeightHint(e.attrs[4]);
      float height = (heightHint != null ? heightHint : 10) * sz;

      PVector world = productFrame.origin;
      allModel2Ds.create("TREES", 0,
        cx + sx * world.x, cy + sy * world.y, cz + sz * world.z, height);
      ifcImportTreeCount++;
      continue;
    }

    // A person/entourage figure (see ifcLooksLikeAPerson() above) is
    // placed the same way, as one of the app's own native 2D people -
    // the same "Person" command's own fixed height (2.5), not a parsed
    // or per-tree-style default one, since there's no size-bearing
    // naming convention for a human reference figure the way there is
    // for a tree's own catalog name.
    if (ifcLooksLikeAPerson(ents, e, ifcRefId(e.attrs[6].trim()), personLayerItemIds)) {
      PVector world = productFrame.origin;
      allModel2Ds.create("PEOPLE", 0,
        cx + sx * world.x, cy + sy * world.y, cz + sz * world.z, 2.5);
      ifcImportPersonCount++;
      continue;
    }

    // A window (see ifcGlassProductTypes above) always draws as glass
    // (material 9), and a solar panel/collector/hybrid panel (see
    // ifcLooksLikeASolarDevice() above) always draws with
    // IFC_MATERIAL_SOLAR (material 0) - both regardless of what m says
    // or what material, if any, the file associates with the product:
    // the solar material isn't a color choice, it's what gets the face
    // its boosted tessellation for an accurate yield calculation (see
    // IFC_MATERIAL_SOLAR's own comment), so a file-authored material
    // name shouldn't be able to quietly turn that off. Short of either
    // of those, a product whose own associated IfcMaterial name matches
    // one of Materials.pde's named colors (concrete, steel, timber,
    // ...) gets that color - here an explicit match *does* win, same as
    // everywhere else. Failing that, a planted surface (a green roof,
    // green wall, or garden/lawn - see ifcLooksLikeVegetation() above)
    // defaults to IFC_MATERIAL_VEGETATION; a swimming pool's own water
    // surface (see ifcLooksLikeAPool() above) defaults to
    // IFC_MATERIAL_WATER; an exposed structural member (a column, beam
    // or IfcMember) or a floor (see
    // ifcStructuralProductTypes/ifcLooksLikeAFloor() above) defaults to
    // IFC_MATERIAL_CONCRETE; a shading device (see
    // ifcLooksLikeAShadingDevice() above) defaults to IFC_MATERIAL_STEEL;
    // and IfcSite's own topography more generally (see
    // ifcTopographyProductTypes above) defaults to IFC_MATERIAL_EARTH -
    // rather than any of them falling into the
    // generic cycle, since each should read as what it visibly is even
    // when the file names no material for it at all. Only a product
    // matching none of the above falls back to m/the normal 1-8 cycle.
    // Every kind of explicit match here is intentionally kept out of
    // that cycle too - so unmatched walls/windows/etc. still cycle
    // smoothly through materials 1-8 with no gaps.
    int materialForThisProduct;
    // Deliberately not a "cond ? IFC_MATERIAL_GLASS : ifcMaterialNameToConstant(...)"
    // ternary: mixing a primitive int (IFC_MATERIAL_GLASS) with an
    // Integer (the method's return type, often legitimately null) makes
    // Java's conditional operator settle on the primitive int as the
    // whole expression's static type (JLS 15.25) - forcing an unboxing
    // of whichever side is actually chosen, even the null one, which
    // throws a NullPointerException instead of just being null.
    Integer matchedMaterial;
    if (ifcGlassProductTypes.contains(e.type)) {
      matchedMaterial = IFC_MATERIAL_GLASS;
    } else if (ifcLooksLikeASolarDevice(e)) {
      matchedMaterial = IFC_MATERIAL_SOLAR;
    } else {
      matchedMaterial = ifcMaterialNameToConstant(productMaterialNames.get(id));
      if (matchedMaterial == null && ifcLooksLikeVegetation(e)) {
        matchedMaterial = IFC_MATERIAL_VEGETATION;
      }
      if (matchedMaterial == null && ifcLooksLikeAPool(e)) {
        matchedMaterial = IFC_MATERIAL_WATER;
      }
      if (matchedMaterial == null && (ifcStructuralProductTypes.contains(e.type) || ifcLooksLikeAFloor(e))) {
        matchedMaterial = IFC_MATERIAL_CONCRETE;
      }
      if (matchedMaterial == null && ifcLooksLikeAShadingDevice(e)) {
        matchedMaterial = IFC_MATERIAL_STEEL;
      }
      if (matchedMaterial == null && ifcTopographyProductTypes.contains(e.type)) {
        matchedMaterial = IFC_MATERIAL_EARTH;
      }
    }
    // The m == -1 cycle's own advance is tentative, not committed to
    // effectiveMaterial yet - see the small-object-exclusion comment
    // below for why: a product that turns out to be a discarded small
    // object must never consume a cycle slot, the same as it producing
    // no Faces at all would. (When matchedMaterial != null, or m != -1,
    // nextEffectiveMaterial just comes back out equal to
    // effectiveMaterial - so committing it unconditionally below is a
    // harmless no-op in both of those cases; only the actual m == -1 +
    // no-explicit-match case below has anything to roll back.)
    int nextEffectiveMaterial = effectiveMaterial;
    if (matchedMaterial != null) {
      materialForThisProduct = matchedMaterial;
    } else {
      if (m == -1) nextEffectiveMaterial = 1 + (effectiveMaterial % 8);
      materialForThisProduct = nextEffectiveMaterial;
    }

    int repId = ifcRefId(e.attrs[6]);
    ifcBeginProductStaging();
    ifcProcessProductRepresentation(ents, repId, productFrame, cx, cy, cz, sx, sy, sz,
      materialForThisProduct, tes, lyr, vsb, wgt, clz);

    // Small-object exclusion (see IFC_SMALL_OBJECT_MAX_DIMENSION's own
    // comment): only for IfcBuildingElementProxy, IFC's and most
    // authoring tools' catch-all for "doesn't fit a more specific
    // class" - used for everything from dinner plates to elevators, so
    // only a genuinely small one gets excluded here, not the type as a
    // whole. A product that produced no geometry at all has nothing to
    // decide either way - ifcPromoteProductStaging() on an empty
    // staging buffer is already a safe no-op, so it's simplest to
    // always take that branch rather than add a third one.
    if (!ifcImportFurniture && e.type.equals("IFCBUILDINGELEMENTPROXY")
      && ifcProductPendingFaceNodes.size() > 0 && ifcProductBBoxMaxDimension() < IFC_SMALL_OBJECT_MAX_DIMENSION) {
      ifcDiscardProductStaging();
      ifcImportSmallObjectExcludedCount++;
      // effectiveMaterial deliberately left uncommitted - the next real
      // (kept) product picks up exactly where the last one left off, as
      // if this discarded one had never been in the file at all.
    } else {
      ifcPromoteProductStaging();
      effectiveMaterial = nextEffectiveMaterial;
    }
  }

  // Every point/face queued above (see ifcQueuePoint()/ifcQueueFace())
  // only actually lands in allPoints/allFaces here, in one bulk copy -
  // see ifcFlushPendingGeometry()'s own comment for why.
  int importedFaceCount = ifcPendingFaceNodes.size();
  ifcFlushPendingGeometry();

  // Only meaningful once the geometry it rotates actually exists in
  // allFaces/allModel2Ds - see ifcRotateImportedModelToTrueNorth()'s own
  // comment for why this runs here, after the flush, rather than
  // earlier alongside where ifcImportNorthRotationAngle itself was
  // computed. A zero angle (ifcImportOrient off, no IfcSite, or an
  // unrotated one) is a no-op inside that function too, but checked
  // here as well so a zero-angle import never even touches
  // currentObjectCategory/the selection.
  if (ifcImportNorthRotationAngle != 0) {
    ifcRotateImportedModelToTrueNorth(ifcImportNorthRotationAngle, ifcBaseFaceCount, ifcBaseModel2DCount);
  }

  model_changed();
  String summary = "IFC import complete: " + importedFaceCount + " face(s) imported";
  if (ifcLengthUnitScale != 1) summary += " (converted from the file's own length unit, scale " + ifcLengthUnitScale + " to metres)";
  if (ifcImportTreeCount > 0) summary += ", " + ifcImportTreeCount + " tree(s) placed";
  if (ifcImportPersonCount > 0) summary += ", " + ifcImportPersonCount + " people placed";
  if (ifcImportUncutOpeningCount > 0) summary += ", " + ifcImportUncutOpeningCount + " opening(s) not cut (imported as solid)";
  if (ifcImportFurnitureExcludedCount > 0) summary += ", " + ifcImportFurnitureExcludedCount + " furniture item(s) not imported (furniture import is currently disabled)";
  if (ifcImportSmallObjectExcludedCount > 0) summary += ", " + ifcImportSmallObjectExcludedCount + " small object(s) not imported";
  if (ifcImportSkippedCount > 0) summary += ", " + ifcImportSkippedCount + " unsupported geometry item(s) skipped";
  if (ifcImportHolesCutCount > 0) summary += ", " + ifcImportHolesCutCount + " inner boundary/boundaries cut out of their face";
  if (ifcImportNorthRotationAngle != 0) summary += ", rotated " + ifcImportNorthRotationAngle + " degree(s) around the origin to match the project's true north";
  summary += ".";
  println();
  println(summary);

  // Last step of loading an IFC file, after the summary above - see
  // IFC_IMPORT_GOTO_LATLON's own comment for why this runs at all, and
  // ifcSiteLatLonDecimalDegrees()'s own comment for exactly where the
  // lat/lon comes from. Left alone - the station stays wherever it
  // already was - whenever the file gives no usable reference point,
  // same as a file with no (or an unrotated) IfcSite already leaves
  // IFC_IMPORT_NORTH's own rotation a no-op.
  ifcImportGotoLatLon = ifcImportRelocate ? ifcSiteLatLonDecimalDegrees(ents) : null;
  if (ifcImportGotoLatLon != null) {
    println();
    println("Now navigating to latitude " + ifcImportGotoLatLon[0] + ", longitude " + ifcImportGotoLatLon[1] + "...");
    __SETLATLON__(new String[] { "SETLATLON", "" + ifcImportGotoLatLon[0], "" + ifcImportGotoLatLon[1] });
  }
}
