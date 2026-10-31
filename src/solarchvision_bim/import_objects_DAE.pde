// Minimal, dependency-free importer for a DAE (COLLADA) file - the same
// "hand-roll the parser, no external library" choice import_objects_OBJ.
// pde/import_objects_IFC.pde/import_objects_GLB.pde/import_objects_STL.
// pde/import_objects_DXF.pde/import_objects_PLY.pde already make for
// their own formats. COLLADA is plain XML, openly published by the
// Khronos Group (the same body behind glTF), so "dependency-free" here
// just means Processing's own built-in XML class - already used
// elsewhere in this project for its own save/load-project format (see
// xml_helpers.pde/save_project.pde/load_project.pde) - rather than any
// new parsing machinery of its own.
//
// A COLLADA document separates WHAT geometry exists (<library_geometries>,
// each a <mesh> of vertex positions plus <triangles>/<polylist>
// primitives referencing them by index - see daeProcessGeometry()'s own
// comment) from WHERE it's actually placed (<library_visual_scenes>'s
// own <node> hierarchy, each node transformed by some combination of
// <translate>/<rotate>/<scale>/<matrix> and instancing zero or more
// geometries via <instance_geometry url="#id">) - the same two-part
// shape import_objects_GLB.pde's own node-hierarchy walk already
// handles for glTF, and reused here the same way (daeWalkNode()
// composing each node's own PMatrix3D, same as glbWalkNode()).
//
// v1 scope, deliberately kept simple:
//   - Only <triangles> and <polylist> primitives are read (the two
//     common ways a COLLADA mesh represents polygon faces) - any other
//     primitive type (<polygons>, <lines>, <linestrips>, <trifans>,
//     <tristrips>) is skipped. Each polygon becomes one app-native face
//     with however many corners it declares (<polylist>'s own <vcount>,
//     or always 3 for <triangles>) - the same "whatever n-gon the file
//     itself declares" choice import_objects_IFC.pde's/import_objects_
//     DXF.pde's/import_objects_PLY.pde's own faces already make.
//   - Only a primitive's own VERTEX-semantic <input> (the position
//     index) is read; any other input a primitive carries (NORMAL,
//     TEXCOORD, COLOR, ...) only affects how its own interleaved index
//     list is strided over - see daePrimitiveStride()'s own comment -
//     not what's actually built.
//   - <library_geometries> entries whose own <mesh> this version can't
//     make sense of (a <spline>/<convex_mesh> instead of straight
//     polygon data, or no <vertices>/POSITION source at all) are
//     skipped entirely, the same way an unsupported primitive type is.
//   - Materials are intentionally not read at all - every imported face
//     gets the single material the m parameter (below) names, the same
//     "whole import, one material unless cycled per sub-object" shape
//     import_objects_GLB.pde's own per-mesh handling already uses -
//     cycled here once per <instance_geometry> reference actually
//     processed (daeWalkNode()'s own call to it), the natural COLLADA
//     equivalent of a new OBJ "g" tag/GLB node-with-a-mesh.
//   - <asset><up_axis> (COLLADA's own declared Y_UP/Z_UP/X_UP) is read
//     nowhere in this version - the shared importSwapAxisYZ option
//     (fileSelected.pde) already lets the person importing choose this
//     explicitly, the same way for every format this importer suite
//     supports, which matters more here than auto-detecting it per file
//     - see importSwapAxisYZ's own comment for why.

boolean daeImportShowOptionsDialog = false;

// Transform parameters and the material-cycling flag for the CURRENT
// import_objects_DAE() call - same "a few fields shared across one whole
// import" shape glb_cx/glb_cycleMaterial/... (import_objects_GLB.pde)
// already use.
float dae_cx, dae_cy, dae_cz, dae_sx, dae_sy, dae_sz;
boolean daeCycleMaterial;

int daeFacesImported = 0;

int dae_totalGeometryInstances = 0;
int dae_processedGeometryInstances = 0;
float dae_printedProgress = 0;
ProgressWindow dae_progressWindow = null;

void import_objects_DAE (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  // Same shape as import_objects_OBJ()'s/import_objects_GLB()'s/import_
  // objects_STL()'s/import_objects_DXF()'s/import_objects_PLY()'s own
  // identical blocks - see any one's own comment, or ifcImportShow
  // OptionsDialog's (import_objects_IFC.pde), for why this sits here
  // rather than earlier, and what a cancelled dialog does.
  if (daeImportShowOptionsDialog) {
    daeImportShowOptionsDialog = false;
    if (!axisSwapShowImportOptionsDialog("DAE import options")) return;
  }

  println("Importing DAE. Please wait...");
  showWaitCursor();

  daeCycleMaterial = (m == -1);
  if (m == -1) current_Material = 0;
  else current_Material = m;

  current_Tessellation = tes;
  current_Layer = lyr;
  current_Visibility = vsb;
  current_Weight = wgt;
  current_Closed = clz;

  dae_cx = cx; dae_cy = cy; dae_cz = cz;
  dae_sx = sx; dae_sy = sy; dae_sz = sz;

  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  XML collada = null;
  try {
    collada = loadXML(FileName);
  } catch (RuntimeException e) {
    println("\nDAE import: could not parse '" + FileName + "' (" + e.getMessage() + ")");
  }
  if (collada == null) {
    println("\nDAE import: could not read '" + FileName + "'");
    showArrowCursor();
    return;
  }

  XML libraryVisualScenes = collada.getChild("library_visual_scenes");
  if (libraryVisualScenes == null) {
    println("\nDAE import: no library_visual_scenes found in '" + FileName + "'");
    showArrowCursor();
    return;
  }

  // The file can declare several visual scenes but only actually display
  // one, named by <scene><instance_visual_scene url="#id"/> - that's the
  // one read here. A missing/unresolved <scene> falls back to the first
  // declared visual_scene instead of giving up outright, best-effort,
  // same spirit as this file's own other fallbacks.
  XML visualScene = null;
  XML sceneEl = collada.getChild("scene");
  if (sceneEl != null) {
    XML instVS = sceneEl.getChild("instance_visual_scene");
    if (instVS != null) {
      String vsId = daeRefId(daeAttr(instVS, "url"));
      visualScene = daeFindById(collada, vsId);
    }
  }
  if (visualScene == null) {
    XML[] scenes = libraryVisualScenes.getChildren("visual_scene");
    if (scenes.length > 0) visualScene = scenes[0];
  }
  if (visualScene == null) {
    println("\nDAE import: no visual scene found in '" + FileName + "'");
    showArrowCursor();
    return;
  }

  if (addToLastGroup == false) {
    // No group created here directly - see daeWalkNode()'s own comment
    // on why that happens once per <instance_geometry> instead, the
    // same granularity import_objects_GLB.pde's own node walk already
    // uses.
  }

  progressBarHeader();

  dae_totalGeometryInstances = 0;
  for (XML node : visualScene.getChildren("node")) {
    dae_totalGeometryInstances += daeCountGeometryInstances(node);
  }
  dae_processedGeometryInstances = 0;
  dae_printedProgress = 0;
  daeFacesImported = 0;

  dae_progressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("Importing DAE") : null;
  if (dae_progressWindow != null) dae_progressWindow.setVisible(true);

  try {
    PMatrix3D identity = new PMatrix3D();
    for (XML node : visualScene.getChildren("node")) {
      daeWalkNode(collada, node, identity);
    }
  } finally {
    if (dae_progressWindow != null) dae_progressWindow.dispose();
    dae_progressWindow = null;
  }

  if (daeFacesImported == 0) {
    println("\nDAE import: no faces were imported - this version only reads <triangles>/<polylist> primitives reachable from the scene's own node hierarchy");
  }

  int remaining = (int) floor(100 - dae_printedProgress);
  StringBuilder barBuffer = new StringBuilder();
  for (int c = 0; c < remaining; c++) barBuffer.append('█');
  print(barBuffer.toString());
  println();

  showArrowCursor();
}

// this.getString(name) itself, without a default value, isn't confirmed
// to return "" rather than null when the attribute is absent - so every
// attribute read in this file goes through this wrapper instead of
// calling .getString() directly, to stay safe regardless.
String daeAttr (XML el, String name) {
  String v = el.getString(name);
  return (v == null) ? "" : v;
}

// Strips a COLLADA "#id" reference down to the bare id daeFindById()
// below looks up - COLLADA always writes these with the leading "#"
// (a URI fragment), never a bare id on its own.
String daeRefId (String url) {
  if ((url != null) && url.startsWith("#")) return url.substring(1);
  return url;
}

// Finds the element anywhere in the document whose own "id" attribute
// matches - COLLADA has no single central lookup table of its own, so
// every #id reference (a primitive's own <input source="#..."/>, a
// node's own <instance_geometry url="#..."/>, ...) is resolved this way.
// A plain recursive scan rather than a prebuilt index: real COLLADA
// files are small enough (dozens to a few hundred elements, not
// millions) that this stays cheap, matching the "keep it simple" spirit
// of this importer's other choices over an optimization v1 doesn't need.
XML daeFindById (XML el, String id) {
  if ((id == null) || (id.length() == 0)) return null;
  if (daeAttr(el, "id").equals(id)) return el;
  for (XML child : el.getChildren()) {
    XML found = daeFindById(child, id);
    if (found != null) return found;
  }
  return null;
}

// The first `expectedCount` whitespace-separated numbers in `text` (a
// <translate>/<rotate>/<scale>/<matrix> element's own content, or a
// <float_array>'s), or null if there aren't that many - used instead of
// letting a malformed/truncated element throw partway through building a
// transform or a point.
float[] daeFloats (String text, int expectedCount) {
  if (text == null) return null;
  String[] tokens = splitTokens(text);
  if ((tokens == null) || (tokens.length < expectedCount)) return null;
  float[] out = new float[expectedCount];
  for (int i = 0; i < expectedCount; i++) out[i] = float(tokens[i]);
  return out;
}

int daeCountGeometryInstances (XML nodeEl) {
  int count = nodeEl.getChildren("instance_geometry").length;
  for (XML child : nodeEl.getChildren("node")) count += daeCountGeometryInstances(child);
  return count;
}

// One console/ProgressWindow update, called once per <instance_geometry>
// actually processed (daeWalkNode(), below) - the same per-mesh
// granularity glbReportProgress() (import_objects_GLB.pde) already uses,
// for the same reason: counting actual faces/vertices up front would
// need its own full pre-pass this version doesn't do.
void daeReportProgress () {
  if (control == USER_AUTO) return;

  dae_processedGeometryInstances += 1;

  float Progress = (dae_totalGeometryInstances > 0) ? (100 * dae_processedGeometryInstances / (float) dae_totalGeometryInstances) : 100;
  int delta = (int) floor(Progress - dae_printedProgress);
  if (delta >= 1) {
    StringBuilder barBuffer = new StringBuilder();
    for (int c = 0; c < delta; c++) barBuffer.append('█');
    print(barBuffer.toString());
    dae_printedProgress = floor(Progress);
    if (dae_progressWindow != null) dae_progressWindow.updateFraction(Progress / 100.0f);
  }
}

// One point, already in world space (the caller has already applied the
// owning node's own transform), carried through cx/cy/cz/sx/sy/sz and
// importSwapAxisYZ (fileSelected.pde, shared with every other importer)
// the same way those already do.
int daeCreatePoint (float x, float y, float z) {
  float finalX, finalY, finalZ;
  if (importSwapAxisYZ) {
    finalX = dae_cx + dae_sx * x;
    finalY = dae_cy + dae_sy * (-z);
    finalZ = dae_cz + dae_sz * y;
  } else {
    finalX = dae_cx + dae_sx * x;
    finalY = dae_cy + dae_sy * y;
    finalZ = dae_cz + dae_sz * z;
  }
  return allPoints.create(finalX, finalY, finalZ);
}

// Visits node `nodeEl` and every one of its descendants, composing each
// one's own local transform (daeNodeLocalMatrix(), below) onto its
// parent's already-composed world matrix - the same "clone, then apply
// on top of the clone" shape glbWalkNode() (import_objects_GLB.pde)
// already uses (that function's own comment has the fuller "mirrors
// pushMatrix()" story).
void daeWalkNode (XML collada, XML nodeEl, PMatrix3D parentMatrix) {
  PMatrix3D worldMatrix = parentMatrix.get(); // clone - mirrors pushMatrix()
  worldMatrix.apply(daeNodeLocalMatrix(nodeEl));

  for (XML instGeom : nodeEl.getChildren("instance_geometry")) {
    daeReportProgress();

    String geomId = daeRefId(daeAttr(instGeom, "url"));
    XML geometryEl = daeFindById(collada, geomId);
    if (geometryEl == null) continue;

    // One group per <instance_geometry> reference actually processed -
    // see this file's own header comment on grouping/material cycling.
    if (daeCycleMaterial) current_Material = 1 + (current_Material % 8);
    if (addToLastGroup == false) allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);

    daeProcessGeometry(collada, geometryEl, worldMatrix);
  }

  for (XML child : nodeEl.getChildren("node")) {
    daeWalkNode(collada, child, worldMatrix);
  }
}

// One node's own local transform as a PMatrix3D, composed from however
// many <translate>/<rotate>/<scale>/<matrix> children it has, applied IN
// THE ORDER THEY APPEAR - COLLADA explicitly allows any number of these,
// in any order, each one composing onto whatever came before it (unlike
// glTF's own node transform, which is always exactly one of "a single
// matrix" or "a single TRS triple" - see glbNodeMatrix()'s own comment,
// import_objects_GLB.pde).
PMatrix3D daeNodeLocalMatrix (XML nodeEl) {
  PMatrix3D m = new PMatrix3D(); // identity

  for (XML child : nodeEl.getChildren()) {
    String tag = child.getName();
    if (tag == null) continue;

    if (tag.equals("translate")) {
      float[] v = daeFloats(XML_getContent(child), 3);
      if (v != null) m.translate(v[0], v[1], v[2]);
    } else if (tag.equals("rotate")) {
      // COLLADA's own <rotate> is axis-angle, angle in DEGREES - radians()
      // converts to what PMatrix3D.rotate() itself expects.
      float[] v = daeFloats(XML_getContent(child), 4);
      if (v != null) m.rotate(radians(v[3]), v[0], v[1], v[2]);
    } else if (tag.equals("scale")) {
      float[] v = daeFloats(XML_getContent(child), 3);
      if (v != null) m.scale(v[0], v[1], v[2]);
    } else if (tag.equals("matrix")) {
      // COLLADA's own <matrix> is already row-major - the same argument
      // order PMatrix3D's own 16-float constructor/apply() expect,
      // unlike glTF's column-major node matrices (glbNodeMatrix(),
      // import_objects_GLB.pde, has to reorder those - this doesn't).
      float[] v = daeFloats(XML_getContent(child), 16);
      if (v != null) {
        m.apply(new PMatrix3D(
          v[0],  v[1],  v[2],  v[3],
          v[4],  v[5],  v[6],  v[7],
          v[8],  v[9],  v[10], v[11],
          v[12], v[13], v[14], v[15]
        ));
      }
    }
    // "instance_geometry" (handled by the caller, daeWalkNode()), "extra",
    // a nested "node" (also handled by the caller), or anything else: not
    // a transform element, skipped here.
  }

  return m;
}

// Reads geometryEl's own <mesh> - its position source (found through the
// standard COLLADA indirection: <mesh>'s own <vertices> element has a
// POSITION-semantic <input> naming the actual <source>, since a
// primitive's own <input semantic="VERTEX"> points at <vertices>, not
// straight at <source> - see this file's own header comment) - then its
// own <triangles>/<polylist> primitives, each built against that same,
// once-built point list.
void daeProcessGeometry (XML collada, XML geometryEl, PMatrix3D worldMatrix) {
  XML mesh = geometryEl.getChild("mesh");
  if (mesh == null) return; // not polygon geometry (e.g. <spline>/<convex_mesh>) - not supported in this version

  XML verticesEl = mesh.getChild("vertices");
  if (verticesEl == null) return;

  String positionSourceId = null;
  for (XML input : verticesEl.getChildren("input")) {
    if (daeAttr(input, "semantic").equals("POSITION")) {
      positionSourceId = daeRefId(daeAttr(input, "source"));
      break;
    }
  }
  if (positionSourceId == null) return;

  XML positionSource = daeFindById(collada, positionSourceId);
  if (positionSource == null) return;

  XML floatArray = positionSource.getChild("float_array");
  if (floatArray == null) return;

  String[] floatTokens = splitTokens(XML_getContent(floatArray));
  if (floatTokens == null) return;

  // Built once per <mesh> - every <triangles>/<polylist> primitive
  // inside it shares this exact same vertex-position array, referencing
  // it by plain 0-based index.
  int vertexCount = floatTokens.length / 3;
  int[] pointIndex = new int[vertexCount];
  PVector local = new PVector();
  PVector world = new PVector();
  for (int i = 0; i < vertexCount; i++) {
    local.x = float(floatTokens[i * 3]);
    local.y = float(floatTokens[i * 3 + 1]);
    local.z = float(floatTokens[i * 3 + 2]);
    worldMatrix.mult(local, world);
    pointIndex[i] = daeCreatePoint(world.x, world.y, world.z);
  }

  for (XML prim : mesh.getChildren()) {
    String tag = prim.getName();
    if (tag == null) continue;

    if (tag.equals("triangles")) {
      daePrimitiveFixed(prim, pointIndex, 3);
    } else if (tag.equals("polylist")) {
      daePrimitiveVariable(prim, pointIndex);
    }
    // "polygons"/"lines"/"linestrips"/"trifans"/"tristrips" and anything
    // else (including "source"/"vertices" themselves): not supported in
    // this version - see this file's own header comment.
  }
}

// A primitive's own stride (how many index numbers each of its own
// vertices occupies in its <p> list) and the VERTEX-semantic <input>'s
// own offset within that stride - every <input> (VERTEX, NORMAL,
// TEXCOORD, COLOR, ...) interleaves its own index at its own declared
// offset, so the stride is one more than the LARGEST offset actually
// used, regardless of how many inputs there are or whether their
// offsets are sequential; only the VERTEX one's own offset is read
// (that's the only property this version actually builds anything
// from), returned as {stride, vertexOffset} - vertexOffset is -1 if no
// VERTEX-semantic input exists at all (not a real face this version can
// read from).
int[] daePrimitiveStride (XML prim) {
  int stride = 1;
  int vertexOffset = -1;
  for (XML input : prim.getChildren("input")) {
    int offset = input.getInt("offset", 0);
    if (offset + 1 > stride) stride = offset + 1;
    if (daeAttr(input, "semantic").equals("VERTEX")) vertexOffset = offset;
  }
  return new int[]{ stride, vertexOffset };
}

// <triangles>: every primitive is exactly `verticesPerPrimitive` (always
// 3) vertices, back to back in the one <p> list - this file's own header
// comment has the fuller "what a stride/offset is" story.
void daePrimitiveFixed (XML prim, int[] pointIndex, int verticesPerPrimitive) {
  int[] strideInfo = daePrimitiveStride(prim);
  int stride = strideInfo[0];
  int vertexOffset = strideInfo[1];
  if (vertexOffset < 0) return;

  XML pEl = prim.getChild("p");
  if (pEl == null) return;

  String[] tokens = splitTokens(XML_getContent(pEl));
  if (tokens == null) return;

  int count = prim.getInt("count", 0);

  for (int f = 0; f < count; f++) {
    int[] face = new int[verticesPerPrimitive];
    boolean ok = true;
    for (int v = 0; v < verticesPerPrimitive; v++) {
      int tokenPos = (f * verticesPerPrimitive + v) * stride + vertexOffset;
      if (tokenPos >= tokens.length) { ok = false; break; }
      int vi = int(tokens[tokenPos]);
      if ((vi < 0) || (vi >= pointIndex.length)) { ok = false; break; }
      face[v] = pointIndex[vi];
    }
    if (ok) {
      allFaces.create(face);
      daeFacesImported += 1;
    }
  }
}

// <polylist>: each primitive's own vertex count comes from its matching
// entry in <vcount> instead of being fixed - otherwise the exact same
// stride/offset reading daePrimitiveFixed() above already does.
void daePrimitiveVariable (XML prim, int[] pointIndex) {
  int[] strideInfo = daePrimitiveStride(prim);
  int stride = strideInfo[0];
  int vertexOffset = strideInfo[1];
  if (vertexOffset < 0) return;

  XML vcountEl = prim.getChild("vcount");
  XML pEl = prim.getChild("p");
  if ((vcountEl == null) || (pEl == null)) return;

  String[] vcountTokens = splitTokens(XML_getContent(vcountEl));
  String[] pTokens = splitTokens(XML_getContent(pEl));
  if ((vcountTokens == null) || (pTokens == null)) return;

  int count = prim.getInt("count", 0);

  int pPos = 0;
  for (int poly = 0; poly < count; poly++) {
    if (poly >= vcountTokens.length) break;
    int n = int(vcountTokens[poly]);

    int[] face = new int[n];
    boolean ok = (n >= 3);
    for (int v = 0; ok && (v < n); v++) {
      int tokenPos = pPos + v * stride + vertexOffset;
      if (tokenPos >= pTokens.length) { ok = false; break; }
      int vi = int(pTokens[tokenPos]);
      if ((vi < 0) || (vi >= pointIndex.length)) { ok = false; break; }
      face[v] = pointIndex[vi];
    }
    if (ok) {
      allFaces.create(face);
      daeFacesImported += 1;
    }

    pPos += n * stride;
  }
}
