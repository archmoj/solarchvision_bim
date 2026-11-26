// Minimal, dependency-free exporter for an IFC4 STEP (ISO-10303-21) file -
// the write-side counterpart to importIfc.pde, scoped (per explicit user
// direction) PURELY to export fidelity: making a model round-trip out of
// this app as something other than one flat, undifferentiated mesh, not a
// general in-app parametric-solid feature (no modifiers, no editable walls
// here or anywhere else - that would be a different feature).
//
// Coordinates: every point is written as this app's own raw, local XY(Z)
// meters, exactly the same already-local-planar posture exportDxf.pde's own
// header comment documents and exportObj.pde's OBJprintVertex() does NOT
// share - User3D.exporterScale/exporterYaxisUp are an OBJ-family-only
// convention (that helper's own comment, globalFunctions.pde) for rescaling
// a DISPLAY mesh for external viewers; IFC, like DXF, is a CAD/BIM
// interchange format expected to carry the model's own real-world units
// verbatim, so neither is applied here. User3D.exporterPrecisionVertex IS
// reused for number formatting, the one formatting choice every raw-
// coordinate exporter in this app already shares (exportDxf.pde's own
// exportDxfWritePoint()) - see ifcReal()'s own comment for why a STEP REAL
// literal needs at least 1 decimal digit regardless of that setting's own
// value.
//
// Scope (faces only): only allFaces is written - this app's own IFC
// importer never creates anything but Faces from IFC geometry (every
// ifcEmitFace() call lands in Faces.create()), so Polylines/Model1Ds/
// Model2Ds/Solids/Cameras/Sections have no IFC-product counterpart to round-
// trip through in the first place; writing them here would just be
// discarding information into a format that was never going to read it
// back as anything recognizable.
//
// Material/layer: NOT carried at all, unlike every GIS exporter's own
// "Properties"/DBF-column mechanism or exportDxf.pde's own composite
// layer-name encoding - an IFC element has no natural per-product
// material/layer channel the way a DXF entity's own group-code 8 is, and
// this app's own IFC importer never writes material/layer onto a Face from
// anything it reads back (every IFC-sourced Face's material/layer instead
// comes from the import dialog's own m/lyr cycling parameters, exactly
// like every other IFC-imported Face already works) - so there would be
// nothing on the read side to actually round-trip this through even if it
// were written.
//
// Grouping heuristic (one IFC element per "product", without allGroups):
// allGroups was considered and rejected - a Groups() starts with num=0
// (zero groups) until beginNewGroup() is ever called, so any ungrouped or
// test-created content (including every pre-IFC-import fixture) has NO
// group coverage at all, which would silently export nothing for it.
// Instead, this file chunks CONSECUTIVE allFaces entries that share an
// IDENTICAL NON-EMPTY extraParams string into one exported
// IfcBuildingElementProxy (ifcChunkFaces() below) - an empty-extraParams
// Face is always its own, unmerged element. ifcProductToExtraParams()/
// ifcCaptureExtrudedAreaSolidShape() (importIfc.pde) already stamp one
// shared, contiguous, non-empty extraParams string across every face of one
// imported IFC product (GlobalId/Name/Description/ObjectType, plus
// "ifcShape" for an extrusion's every cap/side face), so this self-
// contained rule reproduces "one element per product" for IFC-originated
// content with no dependency on allGroups' own bookkeeping, and degrades
// gracefully to "one element per Face" for anything else (hand-authored
// content, geometry from another importer, ...). A real limitation this
// accepts: two UNRELATED faces a user manually gave identical extraParams
// JSON (including a hand-typed "ifcShape" key that doesn't actually
// describe their geometry) would be merged/misread the same lossy way - an
// explicit v1 trust boundary, the same spirit as this app's extraParams
// system already trusting whatever JSON a caller sets elsewhere.
//
// Geometry per element - two paths, chosen per chunk:
//   - TRUE EXTRUSION (IfcExtrudedAreaSolid): only when the chunk's own
//     (shared) extraParams carries an "ifcShape" key (written only by
//     ifcCaptureExtrudedAreaSolidShape(), so only ever present for an
//     imported IfcExtrudedAreaSolid) AND that shape's own uAxis/vAxis/
//     extrusion vectors pass ifcValidateShapeForExport()'s own orthogonal/
//     equal-magnitude/perpendicular-extrusion check (see that function's
//     own comment for exactly why this check is necessary, not paranoia -
//     an anisotropic (sx,sy,sz) IFC import scale can turn an originally
//     orthogonal, uniform placement into a skewed one on its own). When it
//     passes, the chunk's own raw per-face mesh is NOT written at all - the
//     4 captured reference points plus the original profile2D fully and
//     exactly reconstruct the same world geometry (the affine-linearity
//     proof behind ifcCaptureExtrudedAreaSolidShape()'s own comment), so
//     writing both would be redundant, not safer.
//   - FLAT MESH (IfcPolygonalFaceSet) - the fallback, used whenever
//     "ifcShape" is absent or fails that validity check: every Face in the
//     chunk, written as its own face loop into one shared
//     IfcCartesianPointList3D (IFC4's own simplest native way to carry
//     exactly this - no IfcFacetedBrep/IfcPolyLoop boilerplate needed).
// Either path is skipped (element exported as a flat mesh carrying no
// extraParams-derived metadata, fabricated GlobalId) when
// User3D.exporterExtraParams is off - the same toggle every other exporter
// in this app already gates extraParams writing behind.
//
// GlobalId/Name/Description/ObjectType: read back from the chunk's own
// (shared) extraParams ("globalId"/"name"/"description"/"objectType" keys -
// ifcProductToExtraParams()'s own comment, importIfc.pde) when present;
// a chunk with no captured GlobalId gets a fabricated one
// (ifcGenerateGlobalId() below) - NOT the official 22-character IFC GUID-
// compression algorithm, just a same-alphabet, plausible-looking opaque
// string, since this app's own importer (ifcAttrString()) treats GlobalId
// as nothing more than an opaque string already.
//
// Spatial structure: a minimal but valid IfcProject -> IfcSite ->
// IfcBuilding -> IfcBuildingStorey skeleton (via IfcRelAggregates), with
// every exported element wrapped in one IfcRelContainedInSpatialStructure
// under that one storey. This app's own importer explicitly excludes
// IFCPROJECT/IFCBUILDING/IFCBUILDINGSTOREY from product detection and
// walks DATA-section entities directly regardless of any relationship
// graph, so none of this skeleton is actually needed for THIS app's own
// round trip - it exists so a file this exporter writes isn't an orphan
// collection of elements when opened in real-world IFC tooling, which
// generally does expect valid spatial containment.
//
// Target schema: IFC4 (declared in FILE_SCHEMA) - this app's own importer
// reads every entity purely by type-name/attribute-position, never by
// declared schema version, so nothing here is schema-version-locked in
// that sense; IFC4 is simply the newest widely-supported schema and the
// one IfcPolygonalFaceSet (the flat-mesh fallback) belongs to.
//
// v1 limitations (explicit, matching the scope agreed in discussion before
// writing this file): extrusions only (no IfcFacetedBrep/B-rep geometry
// ever gets a true parametric path - it's already in its truest importable
// form as a mesh, nothing more parametric to recover); no curved profiles,
// no booleans/openings/voids; a single IfcBuildingStorey for the whole
// model (no multi-story placement); perpendicular, uniformly-scaled
// extrusions only (an oblique or anisotropically-scaled one falls back to
// the flat-mesh path rather than emitting geometrically-wrong IFC).

void exportIfc () {

  // See isFileOperationInProgress's own comment (globalFunctions.pde).
  isFileOperationInProgress = true;

  String ifcFilename = Folder_Export3D + "/" + ProjectName + ".ifc";

  IfcStepWriter w = new IfcStepWriter();

  // --- Minimal valid spatial-structure skeleton (this file's own header
  // comment, "Spatial structure") ---------------------------------------
  int originPoint = w.emit("IFCCARTESIANPOINT", "(0.,0.,0.)");
  int worldPlacement = w.emit("IFCAXIS2PLACEMENT3D", w.ref(originPoint) + ",$,$");
  int geomContext = w.emit("IFCGEOMETRICREPRESENTATIONCONTEXT", "$,'Model',3,1.E-5," + w.ref(worldPlacement) + ",$");
  int lengthUnit = w.emit("IFCSIUNIT", "*,.LENGTHUNIT.,$,.METRE.");
  int units = w.emit("IFCUNITASSIGNMENT", "(" + w.ref(lengthUnit) + ")");

  int project = w.emit("IFCPROJECT", ifcStr(ifcGenerateGlobalId()) + ",$," + ifcStr(ProjectName) + ",$,$,$,$,(" + w.ref(geomContext) + ")," + w.ref(units));
  int site = w.emit("IFCSITE", ifcStr(ifcGenerateGlobalId()) + ",$,'Site',$,$,$,$,$,.ELEMENT.,$,$,$,$,$");
  int building = w.emit("IFCBUILDING", ifcStr(ifcGenerateGlobalId()) + ",$,'Building',$,$,$,$,$,.ELEMENT.,$,$,$");
  int storey = w.emit("IFCBUILDINGSTOREY", ifcStr(ifcGenerateGlobalId()) + ",$,'Storey',$,$,$,$,$,.ELEMENT.,0.");

  w.emit("IFCRELAGGREGATES", ifcStr(ifcGenerateGlobalId()) + ",$,$,$," + w.ref(project) + ",(" + w.ref(site) + ")");
  w.emit("IFCRELAGGREGATES", ifcStr(ifcGenerateGlobalId()) + ",$,$,$," + w.ref(site) + ",(" + w.ref(building) + ")");
  w.emit("IFCRELAGGREGATES", ifcStr(ifcGenerateGlobalId()) + ",$,$,$," + w.ref(building) + ",(" + w.ref(storey) + ")");

  // --- One IfcBuildingElementProxy per chunk ----------------------------
  ArrayList<int[]> chunks = ifcChunkFaces();
  ArrayList<Integer> elementIds = new ArrayList<Integer>();

  for (int[] chunk : chunks) {
    int elementId = ifcWriteElement(w, geomContext, chunk[0], chunk[1]);
    if (elementId >= 0) elementIds.add(elementId);
  }

  if (elementIds.size() > 0) {
    StringBuilder refs = new StringBuilder();
    for (int i = 0; i < elementIds.size(); i++) {
      if (i > 0) refs.append(",");
      refs.append(w.ref(elementIds.get(i)));
    }
    w.emit("IFCRELCONTAINEDINSPATIALSTRUCTURE", ifcStr(ifcGenerateGlobalId()) + ",$,$,$,(" + refs.toString() + ")," + w.ref(storey));
  }

  // --- Write the physical file ------------------------------------------
  PrintWriter ifcOutput = createWriter(ifcFilename);

  ifcOutput.println("ISO-10303-21;");
  ifcOutput.println("HEADER;");
  ifcOutput.println("FILE_DESCRIPTION((''),'2;1');");
  ifcOutput.println("FILE_NAME('" + ProjectName + ".ifc','" + RunStamp + "',(''),(''),'solarchvision_bim','solarchvision_bim','');");
  ifcOutput.println("FILE_SCHEMA(('IFC4'));");
  ifcOutput.println("ENDSEC;");
  ifcOutput.println("DATA;");
  for (String line : w.lines) ifcOutput.println(line);
  ifcOutput.println("ENDSEC;");
  ifcOutput.println("END-ISO-10303-21;");

  ifcOutput.flush();
  ifcOutput.close();

  println("\nFile created:" + ifcFilename);

  isFileOperationInProgress = false;
}

// Returns the [startFaceIndex, endFaceIndexExclusive) chunks this file's
// own header comment, "Grouping heuristic", describes - consecutive,
// visible, non-degenerate (>=3 point) allFaces entries sharing an
// identical non-empty extraParams string become one chunk; every other
// visible/non-degenerate Face (empty extraParams, or
// User3D.exporterExtraParams off - same "metadata export fully off" stance
// every call site of User3D.exporterExtraParams in this app's other
// exporters already takes) is its own, single-Face chunk. Invisible/
// degenerate Faces are skipped entirely, never starting or extending a
// chunk - the same "only ever export what's actually visible" filter every
// other exporter in this app already applies (exportGeojson.pde's own
// header comment).
ArrayList<int[]> ifcChunkFaces () {
  ArrayList<int[]> chunks = new ArrayList<int[]>();
  int n = allFaces.nodes.length;
  int i = 0;

  while (i < n) {
    if (allFaces.getVisibility(i) <= 0 || allFaces.nodes[i].length < 3) {
      i++;
      continue;
    }

    String ep = User3D.exporterExtraParams ? allFaces.getExtraParams(i) : "";
    int j = i + 1;

    if (ep != null && ep.length() > 0) {
      while (j < n && allFaces.getVisibility(j) > 0 && allFaces.nodes[j].length >= 3
        && ep.equals(User3D.exporterExtraParams ? allFaces.getExtraParams(j) : "")) {
        j++;
      }
    }

    chunks.add(new int[]{i, j});
    i = j;
  }

  return chunks;
}

// Writes one chunk as one IfcBuildingElementProxy (GlobalId/Name/
// Description/ObjectType from the chunk's own shared extraParams, or
// fabricated/omitted when absent or User3D.exporterExtraParams is off) plus
// its own IfcProductDefinitionShape - either a true IfcExtrudedAreaSolid
// (ifcWriteExtrusionShape()) when the chunk's "ifcShape" passes validity,
// or a flat IfcPolygonalFaceSet of every Face in the chunk
// (ifcWriteFlatMeshShape()) otherwise. Returns the new element's own id, or
// -1 if the chunk produced no usable geometry at all (every Face in it
// turned out degenerate once re-checked here).
int ifcWriteElement (IfcStepWriter w, int geomContext, int startFace, int endFaceExclusive) {

  JSONObject obj = new JSONObject();
  if (User3D.exporterExtraParams) {
    obj = allFaces.getExtraParamsObject(startFace);
  }

  String globalId = obj.hasKey("globalId") ? obj.getString("globalId") : ifcGenerateGlobalId();
  String name = obj.hasKey("name") ? obj.getString("name") : null;
  String description = obj.hasKey("description") ? obj.getString("description") : null;
  String objectType = obj.hasKey("objectType") ? obj.getString("objectType") : null;

  IfcExtrusionPlan plan = obj.hasKey("ifcShape") ? ifcValidateShapeForExport(obj.getJSONObject("ifcShape")) : null;

  int shapeRepItemId = (plan != null)
    ? ifcWriteExtrusionShape(w, plan)
    : ifcWriteFlatMeshShape(w, startFace, endFaceExclusive);

  if (shapeRepItemId < 0) return -1;

  String repType = (plan != null) ? "SweptSolid" : "Tessellation";
  int shapeRep = w.emit("IFCSHAPEREPRESENTATION", w.ref(geomContext) + ",'Body','" + repType + "',(" + w.ref(shapeRepItemId) + ")");
  int productShape = w.emit("IFCPRODUCTDEFINITIONSHAPE", "$,$,(" + w.ref(shapeRep) + ")");

  // ObjectPlacement left as "$" (STEP null) on every element - matches
  // this app's own importer's own fallback: an unresolved/absent
  // ObjectPlacement attribute (anything not starting with "#") reads back
  // as an identity productFrame (import_objects_IFC()'s own placementTok
  // check, importIfc.pde) - so every written coordinate (shape-local
  // world-space points for the flat-mesh path, or the fully world-space
  // Position this element's own IfcExtrudedAreaSolid already carries) is
  // read back completely unchanged by any further per-element placement.
  return w.emit("IFCBUILDINGELEMENTPROXY", ifcStr(globalId) + ",$," + ifcStr(name) + "," + ifcStr(description) + "," + ifcStr(objectType) + ",$," + w.ref(productShape) + ",$,$");
}

// The flat-mesh fallback path - one IfcPolygonalFaceSet carrying every
// Face in [startFace, endFaceExclusive) as its own IfcIndexedPolygonalFace,
// all sharing one IfcCartesianPointList3D scoped to just this element's own
// points (this file's own header comment, "FLAT MESH"). Returns the new
// IfcPolygonalFaceSet's own id, or -1 if every Face in the range turned out
// to have fewer than 3 points once re-checked here (shouldn't happen -
// ifcChunkFaces() already filtered on this - but matched defensively the
// same way every other exporter in this app checks node-count again at the
// point it's actually used, not just where it was first filtered).
int ifcWriteFlatMeshShape (IfcStepWriter w, int startFace, int endFaceExclusive) {

  StringBuilder coordRows = new StringBuilder();
  ArrayList<String> faceIndexLists = new ArrayList<String>();
  int pointCount = 0;
  boolean any = false;

  for (int f = startFace; f < endFaceExclusive; f++) {
    int[] faceNodes = allFaces.nodes[f];
    if (faceNodes.length < 3) continue;

    StringBuilder idxList = new StringBuilder();
    for (int k = 0; k < faceNodes.length; k++) {
      float x = allPoints.getX(faceNodes[k]);
      float y = allPoints.getY(faceNodes[k]);
      float z = allPoints.getZ(faceNodes[k]);

      if (any || coordRows.length() > 0) coordRows.append(",");
      coordRows.append("(" + ifcReal(x) + "," + ifcReal(y) + "," + ifcReal(z) + ")");
      any = true;
      pointCount++;

      if (k > 0) idxList.append(",");
      idxList.append(pointCount); // 1-based index into the shared point list
    }

    faceIndexLists.add("(" + idxList.toString() + ")");
  }

  if (!any) return -1;

  int pointList = w.emit("IFCCARTESIANPOINTLIST3D", "(" + coordRows.toString() + ")");

  StringBuilder faceRefs = new StringBuilder();
  for (int i = 0; i < faceIndexLists.size(); i++) {
    int faceEntity = w.emit("IFCINDEXEDPOLYGONALFACE", faceIndexLists.get(i));
    if (i > 0) faceRefs.append(",");
    faceRefs.append(w.ref(faceEntity));
  }

  return w.emit("IFCPOLYGONALFACESET", w.ref(pointList) + ",$,(" + faceRefs.toString() + "),$");
}

// The true-extrusion path - one IfcExtrudedAreaSolid built directly from an
// already-validated IfcExtrusionPlan (this file's own header comment,
// "TRUE EXTRUSION"). The written IfcAxis2Placement3D's own
// Axis=plan.axisUnit/RefDirection=plan.refDirUnit is exactly what makes
// this app's OWN importer's own ifcAxis2Placement3DToFrame() reconstruct
// plan.vAxis's own direction byte-for-byte via the vector triple-product
// identity (A x B) x A = B for unit orthogonal A, B - see
// ifcValidateShapeForExport()'s own comment for the full derivation this
// write side relies on.
int ifcWriteExtrusionShape (IfcStepWriter w, IfcExtrusionPlan plan) {

  int originId = w.emit("IFCCARTESIANPOINT", ifcPointTuple(plan.origin));
  int axisId = w.emit("IFCDIRECTION", ifcPointTuple(plan.axisUnit));
  int refDirId = w.emit("IFCDIRECTION", ifcPointTuple(plan.refDirUnit));
  int position = w.emit("IFCAXIS2PLACEMENT3D", w.ref(originId) + "," + w.ref(axisId) + "," + w.ref(refDirId));

  ArrayList<Integer> profilePointIds = new ArrayList<Integer>();
  for (float[] p : plan.profile2D) {
    float sx = p[0] * plan.profileScale;
    float sy = p[1] * plan.profileScale;
    profilePointIds.add(w.emit("IFCCARTESIANPOINT", "(" + ifcReal(sx) + "," + ifcReal(sy) + ")"));
  }

  StringBuilder ptRefs = new StringBuilder();
  for (int i = 0; i < profilePointIds.size(); i++) {
    if (i > 0) ptRefs.append(",");
    ptRefs.append(w.ref(profilePointIds.get(i)));
  }
  // IFCPOLYLINE's own own first point repeated at the end - a profile
  // curve, unlike a Face's own point list, is conventionally written
  // explicitly closed; ifcProfilePoints() (importIfc.pde) reads it back
  // through ifcClosePolygon2D() either way, so this is a belt-and-braces
  // choice, not a strict requirement of the read side.
  if (profilePointIds.size() > 0) ptRefs.append("," + w.ref(profilePointIds.get(0)));

  int polyline = w.emit("IFCPOLYLINE", "(" + ptRefs.toString() + ")");
  int profile = w.emit("IFCARBITRARYCLOSEDPROFILEDEF", ".AREA.,$," + w.ref(polyline));

  int extrudedDirection = w.emit("IFCDIRECTION", "(0.,0.," + ifcReal(plan.localDirectionSign) + ")");

  return w.emit("IFCEXTRUDEDAREASOLID", w.ref(profile) + "," + w.ref(position) + "," + w.ref(extrudedDirection) + "," + ifcReal(plan.depth));
}

// Holds exactly the values ifcWriteExtrusionShape() needs once a captured
// "ifcShape" has passed ifcValidateShapeForExport()'s own checks - origin/
// axisUnit/refDirUnit are already-final world-space values to write
// straight into an IfcAxis2Placement3D; profileScale/profile2D/depth/
// localDirectionSign are exactly the values this file's own header
// comment's "TRUE EXTRUSION" math already works out.
class IfcExtrusionPlan {
  PVector origin;
  PVector axisUnit;
  PVector refDirUnit;
  float profileScale;
  float depth;
  float localDirectionSign;
  ArrayList<float[]> profile2D;
}

// How far uAxis/vAxis/extrusion may deviate from perfectly orthogonal,
// perfectly equal-magnitude, perfectly axis-perpendicular before this
// exporter gives up on a true IfcExtrudedAreaSolid and falls back to the
// flat mesh instead - expressed as a fraction (0.001 = 0.1%), not an
// absolute length, so it scales with the model's own size.
float IFC_SHAPE_EXPORT_TOLERANCE = 0.001;

// Validates one captured "ifcShape" JSONObject (ifcCaptureExtrudedArea
// SolidShape()'s own comment, importIfc.pde, for exactly what each key
// holds) for re-export as a true IfcExtrudedAreaSolid, returning null if it
// fails. This check exists because it CAN genuinely fail, not as unneeded
// defensiveness: uAxis/vAxis/extrusion were captured as already-fully-
// world-space-transformed vectors (the affine-linearity proof behind
// ifcCaptureExtrudedAreaSolidShape()'s own comment), and that transform
// includes this app's own IFC import dialog's (cx,cy,cz,sx,sy,sz) - an
// axis-aligned, generally ANISOTROPIC world-space scale. Such a scale
// preserves affine-ness (so the captured reference points are still
// exactly reconstructable via plain vector arithmetic - the read side,
// importIfc.pde's own test coverage, already proves this) but does NOT in
// general preserve angles or relative lengths between two vectors that
// weren't axis-aligned - an originally orthogonal, equal-length,
// perpendicular-to-the-profile placement can come out skewed. Writing a
// true IfcExtrudedAreaSolid for a skewed case anyway would silently emit
// WRONG geometry (a real IFC viewer would render a shape this app's own
// Faces never actually had) - this check is what keeps that from
// happening, falling back to the always-correct flat mesh instead whenever
// it fails.
IfcExtrusionPlan ifcValidateShapeForExport (JSONObject shape) {
  if (!"extrudedAreaSolid".equals(shape.getString("type", ""))) return null;

  PVector origin = ifcShapeVector(shape.getJSONArray("origin"));
  PVector uAxis = ifcShapeVector(shape.getJSONArray("uAxis"));
  PVector vAxis = ifcShapeVector(shape.getJSONArray("vAxis"));
  PVector extrusion = ifcShapeVector(shape.getJSONArray("extrusion"));

  float uLen = uAxis.mag();
  float vLen = vAxis.mag();
  float extrusionLen = extrusion.mag();

  float epsilon = 0.0000001;
  if (uLen < epsilon || vLen < epsilon || extrusionLen < epsilon) return null;

  // Equal magnitude (within tolerance): a uniform, not anisotropic, scale.
  if (abs(uLen - vLen) > IFC_SHAPE_EXPORT_TOLERANCE * max(uLen, vLen)) return null;

  // Orthogonal (within tolerance): an unskewed placement.
  if (abs(uAxis.dot(vAxis)) > IFC_SHAPE_EXPORT_TOLERANCE * uLen * vLen) return null;

  // Computed by hand (rather than PVector's own .cross()) to make it
  // unambiguous at a glance that uAxis/vAxis themselves are never mutated
  // by this call - both are still needed, unmodified, afterward (vAxis for
  // the dot-product check above already ran, but uAxis still feeds
  // plan.refDirUnit below).
  PVector normal = new PVector(
    uAxis.y * vAxis.z - uAxis.z * vAxis.y,
    uAxis.z * vAxis.x - uAxis.x * vAxis.z,
    uAxis.x * vAxis.y - uAxis.y * vAxis.x
  );
  float normalLen = normal.mag();
  if (normalLen < epsilon) return null; // uAxis/vAxis parallel - degenerate
  normal.normalize();

  // Extrusion perpendicular to the profile (within tolerance): no oblique
  // extrusions in v1 (this file's own header comment).
  float cosAngle = abs(extrusion.dot(normal)) / extrusionLen;
  if (1 - cosAngle > IFC_SHAPE_EXPORT_TOLERANCE) return null;

  IfcExtrusionPlan plan = new IfcExtrusionPlan();
  plan.origin = origin;
  plan.axisUnit = normal;
  plan.refDirUnit = PVector.div(uAxis, uLen);
  plan.profileScale = uLen;
  plan.depth = extrusionLen;
  plan.localDirectionSign = (extrusion.dot(normal) >= 0) ? 1 : -1;
  plan.profile2D = ifcShapeProfile(shape.getJSONArray("profile"));
  return plan;
}

PVector ifcShapeVector (JSONArray a) {
  return new PVector(a.getFloat(0), a.getFloat(1), a.getFloat(2));
}

ArrayList<float[]> ifcShapeProfile (JSONArray profile) {
  ArrayList<float[]> pts = new ArrayList<float[]>();
  for (int i = 0; i < profile.size(); i++) {
    JSONArray pt = profile.getJSONArray(i);
    pts.add(new float[]{pt.getFloat(0), pt.getFloat(1)});
  }
  return pts;
}

// A 22-character opaque identifier in IFC's own GlobalId alphabet - NOT the
// official base64-like compressed-GUID algorithm the real IFC spec defines
// (this file's own header comment, "GlobalId/Name/Description/ObjectType").
String IFC_GUID_CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_$";

String ifcGenerateGlobalId () {
  StringBuilder sb = new StringBuilder(22);
  for (int i = 0; i < 22; i++) {
    sb.append(IFC_GUID_CHARS.charAt((int) random(IFC_GUID_CHARS.length())));
  }
  return sb.toString();
}

// One IfcCartesianPoint/IfcDirection's own "(x,y,z)" attribute text.
String ifcPointTuple (PVector v) {
  return "(" + ifcReal(v.x) + "," + ifcReal(v.y) + "," + ifcReal(v.z) + ")";
}

// A STEP REAL literal always needs at least one decimal digit (EXPRESS's
// own REAL lexical grammar requires a decimal point) - User3D.
// exporterPrecisionVertex (the same formatting choice exportDxf.pde's own
// exportDxfWritePoint() already reuses) is honored, but clamped to at least
// 1 so a user setting that to 0 can't write an invalid "3" instead of
// "3.0".
String ifcReal (float f) {
  int precision = max(User3D.exporterPrecisionVertex, 1);
  return nf(f, 0, precision);
}

// A STEP string literal, single-quoted with internal "'" doubled per
// STEP's own escaping convention (ifcUnquote()'s own inverse, importIfc.
// pde) - or the "$" null token when s is null/empty, this field's own
// "nothing captured" case.
String ifcStr (String s) {
  if (s == null || s.length() == 0) return "$";
  return "'" + s.replace("'", "''") + "'";
}

// Tiny STEP physical-file writer: an auto-incrementing #id per emit() call,
// each appended as one "#id=TYPE(args);" line - this file's own equivalent
// of exportDxf.pde's own dxfWritePair(), scaled to this format's own very
// different (id-referenced-entity, not flat group-code-pair) shape.
class IfcStepWriter {
  ArrayList<String> lines = new ArrayList<String>();
  int nextId = 1;

  int emit (String type, String args) {
    int id = nextId;
    nextId++;
    lines.add("#" + id + "=" + type + "(" + args + ");");
    return id;
  }

  String ref (int id) {
    return "#" + id;
  }
}
