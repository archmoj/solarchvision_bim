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
// why this calls allPoints.create()/allFaces.create() directly rather
// than literally calling Create3D.add_Mesh() itself.
//
// Supported geometry (a practical subset, not the full EXPRESS schema):
//   - IfcFacetedBrep / IfcShellBasedSurfaceModel: (Open|Closed)Shell ->
//     IfcFace -> IfcFaceOuterBound -> IfcPolyLoop -> IfcCartesianPoint.
//     This is IFC2X3's and IFC4's most common straight-edged B-rep path.
//   - IfcPolygonalFaceSet / IfcTriangulatedFaceSet (IFC4 tessellated
//     geometry) backed by a shared IfcCartesianPointList3D.
//   - IfcExtrudedAreaSolid over IfcRectangleProfileDef or
//     IfcArbitraryClosedProfileDef(IfcPolyline) - very common for
//     walls, slabs, columns and beams modelled parametrically instead
//     of as an explicit Brep. Each side panel is built as a single
//     4-point face (the same shape Create3D.add_Mesh4()/"Mesh4" would
//     build by hand), plus two n-gon end caps.
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
//
// Known, deliberate limitations - noted here rather than silently
// guessed around, and surfaced to the person importing via the
// post-import summary line / ifcImportSkippedReasons:
//   - Inner face/profile boundaries ("holes" - IfcFaceBound,
//     IfcIndexedPolygonalFaceWithVoids) are ignored: a wall face with a
//     window-sized hole in it imports as a solid face, hole and all.
//   - Curved edges/surfaces (IfcCircleProfileDef, IfcBSplineCurve,
//     IfcAdvancedBrep's curved faces, swept/revolved solids other than
//     a straight extrusion) are not evaluated; items that need them are
//     skipped and counted, not approximated.
//   - Boolean operations (IfcBooleanClippingResult/IfcBooleanResult,
//     typically how a door/window opening is cut into a wall or slab)
//     are not evaluated.
//   - IfcMappedItem (family/type "block" instances - commonly how
//     doors, windows and furniture are placed) is not supported in this
//     first pass; such items are skipped and counted.
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
// header's "Known limitations").
HashSet<String> ifcNonGeometryProductTypes = new HashSet<String>(Arrays.asList(
  "IFCPROJECT", "IFCSITE", "IFCBUILDING", "IFCBUILDINGSTOREY",
  "IFCSPACE", "IFCOPENINGELEMENT", "IFCVIRTUALELEMENT"
  ));

// Product types drawn as glass (IFC_MATERIAL_GLASS below) instead of
// whatever opaque material the rest of the import is using. Only
// IfcWindow by default; IfcPlate and IfcCurtainWall (curtain-wall
// glazing panels, in files that model them as separate elements) are
// easy to add to this set the same way if that's ever wanted too.
HashSet<String> ifcGlassProductTypes = new HashSet<String>(Arrays.asList(
  "IFCWINDOW"
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
final int IFC_MATERIAL_GLASS      = 9;
final int IFC_MATERIAL_CONCRETE   = 11;
final int IFC_MATERIAL_STEEL      = 12;
final int IFC_MATERIAL_TIMBER     = 13;
final int IFC_MATERIAL_MASONRY    = 14;
final int IFC_MATERIAL_INSULATION = 15;
final int IFC_MATERIAL_MEP        = 16;
final int IFC_MATERIAL_EARTH      = 17;

// Running counters for the post-import summary (and for tests - reset
// at the top of every import_objects_IFC() call).
int ifcImportSkippedCount = 0;
int ifcImportHolesIgnoredCount = 0;
HashMap<String, Integer> ifcImportSkippedReasons = new HashMap<String, Integer>();

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

PVector ifcPointFromCoords (String coordsListAttr) {
  String[] c = ifcListTokens(coordsListAttr);
  float x = c.length > 0 ? ifcFloat(c[0]) : 0;
  float y = c.length > 1 ? ifcFloat(c[1]) : 0;
  float z = c.length > 2 ? ifcFloat(c[2]) : 0;
  return new PVector(x, y, z);
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
// Face/geometry import - every face becomes one allPoints.create() call
// per vertex plus one allFaces.create() call, the same pair of calls
// Create3D.add_Mesh() itself makes internally for an n-gon point list -
// so a quad/pentagon/etc. stays exactly that, never split into
// triangles.
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

  // Faces.create() (called via allFaces.create() below) reads these as
  // globals, not parameters - exactly what Create3D.add_Mesh() itself
  // sets immediately before doing the same thing.
  current_Material = m;
  current_Tessellation = tes;
  current_Layer = lyr;
  current_Visibility = vsb;
  current_Weight = wgt;
  current_Closed = clz;

  int[] newFace_nodes = new int[cleaned.size()];
  for (int i = 0; i < cleaned.size(); i++) {
    PVector world = productFrame.toWorldPoint(cleaned.get(i));
    newFace_nodes[i] = allPoints.create(cx + sx * world.x, cy + sy * world.y, cz + sz * world.z);
  }
  allFaces.create(newFace_nodes);
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

  boolean emittedOuter = false;
  boolean hasInnerBound = false;

  for (String boundRef : ifcListTokens(face.attrs[0])) {
    StepEntity bound = ifcResolve(ents, boundRef);
    if (bound == null) continue;

    boolean isOuter = bound.type.equals("IFCFACEOUTERBOUND");
    boolean isInner = bound.type.equals("IFCFACEBOUND");
    if (!isOuter && !isInner) continue;
    if (isInner) {
      hasInnerBound = true;
      continue; // holes are not cut out of the face - see file header
    }

    if (bound.attrs.length < 2) continue;
    StepEntity loopEntity = ifcResolve(ents, bound.attrs[0]);
    ArrayList<PVector> loop = ifcPolyLoopPoints(ents, loopEntity);
    if (loop.size() < 3) continue;

    boolean orientation = bound.attrs[1].trim().equals(".T.");
    if (!orientation) ifcReverseInPlace(loop);

    ifcEmitFace(loop, productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
    emittedOuter = true;
  }

  if (hasInnerBound) ifcImportHolesIgnoredCount++;
  if (!emittedOuter) ifcNoteSkipped("IfcFace with no usable outer bound");
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
    if (faceEntity.type.equals("IFCINDEXEDPOLYGONALFACEWITHVOIDS") && faceEntity.attrs.length > 1
      && faceEntity.attrs[1].trim().length() > 0 && !faceEntity.attrs[1].trim().equals("$")) {
      ifcImportHolesIgnoredCount++;
    }

    ArrayList<PVector> loop = new ArrayList<PVector>();
    for (String idxTok : ifcListTokens(faceEntity.attrs[0])) {
      int idx = (int) ifcFloat(idxTok); // 1-based index into pool
      if (idx >= 1 && idx <= pool.length) loop.add(pool[idx - 1]);
    }
    if (loop.size() >= 3) {
      ifcEmitFace(loop, productFrame, cx, cy, cz, sx, sy, sz, m, tes, lyr, vsb, wgt, clz);
    }
  }
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
    float xDim = ifcFloat(profile.attrs[3]);
    float yDim = ifcFloat(profile.attrs[4]);
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
    StepEntity polyline = ifcResolve(ents, profile.attrs[2]);
    if (polyline == null || !polyline.type.equals("IFCPOLYLINE") || polyline.attrs.length == 0) return null;

    ArrayList<float[]> pts = new ArrayList<float[]>();
    for (String ptRef : ifcListTokens(polyline.attrs[0])) {
      PVector p = ifcPoint3(ents, ptRef);
      pts.add(new float[]{p.x, p.y});
    }
    if (pts.size() > 1) {
      float[] first = pts.get(0), lastPt = pts.get(pts.size() - 1);
      if (abs(first[0] - lastPt[0]) < 0.00001 && abs(first[1] - lastPt[1]) < 0.00001) {
        pts.remove(pts.size() - 1);
      }
    }
    return pts.size() >= 3 ? pts : null;
  }

  return null; // circle/I-shape/composite/... profiles: not supported yet
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
  float depth = ifcFloat(e.attrs[3]);

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

  if (e.type.equals("IFCTRIANGULATEDFACESET")) {
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

  ifcNoteSkipped(e.type); // IfcMappedItem, booleans, swept curves, etc. - see file header
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
// IfcSlab/IfcDoor/... subtype name, this recognizes "an importable
// product" structurally: not a relationship (IfcRel...), not one of the
// non-geometry types above, and shaped like an IfcProduct with an
// explicit Representation reference.
boolean ifcLooksLikeImportableProduct (StepEntity e) {
  if (e.attrs.length < 7) return false;
  if (!e.type.startsWith("IFC")) return false;
  if (e.type.startsWith("IFCREL")) return false;
  if (ifcNonGeometryProductTypes.contains(e.type)) return false;
  return e.attrs[6].trim().startsWith("#");
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
// Entry point - mirrors import_objects_OBJ(FileName, m, tes, lyr, vsb,
// wgt, clz, cx, cy, cz, sx, sy, sz)'s own signature, including the
// m == -1 "auto-cycle through 8 materials" convention (there, cycled
// once per OBJ "g" line; here, once per imported IfcProduct).
// ---------------------------------------------------------------------
void import_objects_IFC (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  println("Importing IFC. Please wait...");

  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  ifcImportSkippedCount = 0;
  ifcImportHolesIgnoredCount = 0;
  ifcImportSkippedReasons = new HashMap<String, Integer>();

  String fullText = join(loadStrings(FileName), " ");
  HashMap<Integer, StepEntity> ents = ifcParseEntities(fullText);

  int effectiveMaterial = (m == -1) ? 0 : m;
  int importedFaceCountBefore = allFaces.nodes.length;

  // One pass up front, rather than re-walking the relationship graph
  // per product.
  HashMap<Integer, String> productMaterialNames = ifcBuildProductMaterialNames(ents);

  // Processed in ascending entity-id order (which almost always matches
  // the file's own declaration order) rather than ents.keySet()'s own
  // HashMap<Integer,...> order, which Java never guarantees - without
  // this, two imports of the exact same file could cycle materials
  // through a different product order from one run to the next.
  ArrayList<Integer> productIds = new ArrayList<Integer>();
  for (Integer id : ents.keySet()) {
    if (ifcLooksLikeImportableProduct(ents.get(id))) productIds.add(id);
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
    if (addToLastGroup == false) allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);

    // A window (see ifcGlassProductTypes above) always draws as glass
    // (material 9), regardless of what m says or what material, if any,
    // it's associated with in the file. Otherwise, a product whose own
    // associated IfcMaterial name matches one of Materials.pde's named
    // colors (concrete, steel, timber, ...) gets that color; only a
    // product with no match at all falls back to m/the normal 1-8
    // cycle. Either kind of explicit match is intentionally kept out of
    // that cycle too - same reasoning as for windows, just not
    // hardcoded to one product type - so unmatched walls/slabs/etc.
    // still cycle smoothly through materials 1-8 with no gaps.
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
    } else {
      matchedMaterial = ifcMaterialNameToConstant(productMaterialNames.get(id));
    }
    if (matchedMaterial != null) {
      materialForThisProduct = matchedMaterial;
    } else {
      if (m == -1) effectiveMaterial = 1 + (effectiveMaterial % 8);
      materialForThisProduct = effectiveMaterial;
    }

    String placementTok = e.attrs[5].trim();
    IfcFrame productFrame = placementTok.startsWith("#")
      ? ifcPlacementToFrame(ents, ifcRefId(placementTok)) : ifcIdentityFrame();

    int repId = ifcRefId(e.attrs[6]);
    ifcProcessProductRepresentation(ents, repId, productFrame, cx, cy, cz, sx, sy, sz,
      materialForThisProduct, tes, lyr, vsb, wgt, clz);
  }

  model_changed();

  int importedFaceCount = allFaces.nodes.length - importedFaceCountBefore;
  String summary = "IFC import complete: " + importedFaceCount + " face(s) imported";
  if (ifcImportSkippedCount > 0) summary += ", " + ifcImportSkippedCount + " unsupported geometry item(s) skipped";
  if (ifcImportHolesIgnoredCount > 0) summary += ", " + ifcImportHolesIgnoredCount + " inner boundary/boundaries ignored";
  summary += ".";
  println();
  println(summary);
}
