// Minimal, dependency-free importer for a GLB (binary glTF 2.0) file -
// the same "hand-roll the parser, no external library" choice
// import_objects_IFC.pde already makes for its own, very different,
// format (see that file's own header comment: "Minimal, dependency-free
// parser/importer for a STEP (ISO-10303-21) '.ifc' file").
//
// v1 scope, deliberately kept simple:
//   - Geometry only: positions and triangle indices. No normals, UVs,
//     materials/textures, animation, skins, or cameras/lights - every
//     imported face gets the same single material (the m parameter
//     below), the same way a "different objects: different materials"
//     commented-out alternative sits unused in import_objects_OBJ.pde.
//   - Each primitive must be an indexed triangle list (mode 4, glTF's
//     own default - the overwhelmingly common case; every other
//     primitive mode is skipped with a console message) with a POSITION
//     accessor of type VEC3/FLOAT and an indices accessor of type
//     SCALAR/UNSIGNED_BYTE/UNSIGNED_SHORT/UNSIGNED_INT - covers the
//     large majority of real-world exports.
//   - Only the embedded, self-contained binary buffer (buffer 0, the BIN
//     chunk every "single .glb file" carries) is read - no external or
//     data-URI buffers, no sparse accessors.
//   - Draco-compressed meshes (KHR_draco_mesh_compression) are detected
//     and the whole import is cancelled with a clear message rather than
//     silently importing nothing: Draco needs a dedicated decoder this
//     importer doesn't have in v1.
//   - Node hierarchies (including nested children) ARE walked and their
//     transforms (either a raw matrix, or separate translation/rotation/
//     scale) composed via PMatrix3D - already used the same way for
//     composing a transform chain in Model1Ds.pde's own tree-branch
//     code. Skipping this would misplace or entirely drop geometry in
//     any file that groups objects under parent nodes, which real
//     exporters (Blender's default among them) do routinely.
//
// glTF itself has no fixed JSON-parsing dependency concern here: Processing's
// own JSONObject/JSONArray already handle it (Land3D.pde's own elevation-
// API call already uses the same classes), so this stays as dependency-free
// as import_objects_OBJ.pde/import_objects_IFC.pde already are.

// Transform parameters for the CURRENT import_objects_GLB() call, read by
// glbWalkNode()/glbEmitMesh() below without threading them through every
// recursive call - the same "a few fields shared across one whole import,
// rather than passed through every call" shape current_Material/
// current_Tessellation/... (globals.pde) already use for every importer,
// here just scoped to this file specifically since cx/cy/cz/sx/sy/sz
// aren't needed anywhere outside a GLB import.
float glb_cx, glb_cy, glb_cz, glb_sx, glb_sy, glb_sz;
boolean glb_cycleMaterial; // true when the caller passed m == -1 - see import_objects_OBJ.pde's own identical "g" tag handling

int glb_meshCount = 0;
int glb_meshesProcessed = 0;
float glb_printedProgress = 0;
ProgressWindow glb_progressWindow = null;

// glTF accessor componentType constants - only the subset this importer
// actually reads (POSITION is always FLOAT; indices are always one of
// the three unsigned integer types).
final int GLB_COMPONENT_UNSIGNED_BYTE  = 5121;
final int GLB_COMPONENT_UNSIGNED_SHORT = 5123;
final int GLB_COMPONENT_UNSIGNED_INT   = 5125;
final int GLB_COMPONENT_FLOAT          = 5126;

void import_objects_GLB (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  println("Importing GLB. Please wait...");
  showWaitCursor();

  glb_cycleMaterial = (m == -1);
  if (m == -1) current_Material = 0;
  else current_Material = m;

  current_Tessellation = tes;
  current_Layer = lyr;
  current_Visibility = vsb;
  current_Weight = wgt;
  current_Closed = clz;

  glb_cx = cx; glb_cy = cy; glb_cz = cz;
  glb_sx = sx; glb_sy = sy; glb_sz = sz;

  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  byte[] raw = loadBytes(FileName);
  if ((raw == null) || (raw.length < 12)) {
    println("\nGLB import: could not read '" + FileName + "' (file missing, unreadable, or too short to be a .glb)");
    showArrowCursor();
    return;
  }

  // 12-byte header: magic "glTF" (4 ASCII bytes), version (uint32 LE,
  // not otherwise checked - this importer doesn't depend on which 2.x
  // minor revision wrote the file), total length (uint32 LE).
  if (!((raw[0] == 'g') && (raw[1] == 'l') && (raw[2] == 'T') && (raw[3] == 'F'))) {
    println("\nGLB import: '" + FileName + "' is not a .glb file (missing the 'glTF' magic bytes)");
    showArrowCursor();
    return;
  }

  int totalLength = glbReadU32LE(raw, 8);
  if (totalLength > raw.length) totalLength = raw.length; // tolerate a slightly short/truncated trailing pad

  // Chunk loop: the JSON chunk always comes first (required by spec); the
  // BIN chunk, if present, always comes second - but this reads either
  // order and just keeps whichever JSON/BIN chunk it sees first of each,
  // since nothing here depends on strict ordering beyond "JSON exists".
  String jsonText = null;
  int binStart = -1;
  int binLength = 0;

  int pos = 12;
  while (pos + 8 <= totalLength) {
    int chunkLength = glbReadU32LE(raw, pos);
    boolean isJSON = (raw[pos + 4] == 'J') && (raw[pos + 5] == 'S') && (raw[pos + 6] == 'O') && (raw[pos + 7] == 'N');
    boolean isBIN  = (raw[pos + 4] == 'B') && (raw[pos + 5] == 'I') && (raw[pos + 6] == 'N') && (raw[pos + 7] == 0);
    int chunkDataStart = pos + 8;

    if (chunkDataStart + chunkLength > totalLength) break; // malformed/truncated - stop reading chunks rather than read past the end

    if (isJSON && (jsonText == null)) {
      jsonText = new String(raw, chunkDataStart, chunkLength, java.nio.charset.StandardCharsets.UTF_8);
    } else if (isBIN && (binStart == -1)) {
      binStart = chunkDataStart;
      binLength = chunkLength;
    }

    pos = chunkDataStart + chunkLength;
  }

  if (jsonText == null) {
    println("\nGLB import: no JSON chunk found in '" + FileName + "'");
    showArrowCursor();
    return;
  }

  JSONObject json = null;
  try {
    json = JSONObject.parse(jsonText);
  } catch (RuntimeException e) {
    println("\nGLB import: could not parse the JSON chunk (" + e.getMessage() + ")");
  }
  if (json == null) {
    showArrowCursor();
    return;
  }

  // The embedded binary buffer (glTF's own buffer 0, with no "uri" - the
  // standard shape for a self-contained .glb). v1 only reads from this
  // one in-memory slice - see this file's own header comment for why.
  byte[] bin = (binStart >= 0) ? java.util.Arrays.copyOfRange(raw, binStart, binStart + binLength) : new byte[0];

  if (json.hasKey("extensionsRequired")) {
    JSONArray required = json.getJSONArray("extensionsRequired");
    for (int i = 0; i < required.size(); i++) {
      if (required.getString(i).equals("KHR_draco_mesh_compression")) {
        println("\nGLB import: '" + FileName + "' requires Draco mesh compression (KHR_draco_mesh_compression), which this importer does not support yet - import cancelled.");
        showArrowCursor();
        return;
      }
    }
  }

  if (!json.hasKey("nodes") || !json.hasKey("scenes")) {
    println("\nGLB import: no scene/node data found in '" + FileName + "'");
    showArrowCursor();
    return;
  }

  JSONArray scenes = json.getJSONArray("scenes");
  int sceneIndex = json.hasKey("scene") ? json.getInt("scene") : 0;
  if ((sceneIndex < 0) || (sceneIndex >= scenes.size())) {
    println("\nGLB import: no valid default scene found in '" + FileName + "'");
    showArrowCursor();
    return;
  }

  JSONObject sceneObj = scenes.getJSONObject(sceneIndex);
  JSONArray rootNodeIndices = sceneObj.hasKey("nodes") ? sceneObj.getJSONArray("nodes") : new JSONArray();

  glb_meshCount = json.hasKey("meshes") ? json.getJSONArray("meshes").size() : 0;
  glb_meshesProcessed = 0;
  glb_printedProgress = 0;

  progressBarHeader();

  // Same showImportProgress/ProgressWindow pattern import_objects_OBJ.pde
  // already uses - see that file's own comment on it.
  glb_progressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("Importing GLB") : null;
  if (glb_progressWindow != null) glb_progressWindow.setVisible(true);

  try {
    PMatrix3D identity = new PMatrix3D();
    for (int i = 0; i < rootNodeIndices.size(); i++) {
      glbWalkNode(json, bin, rootNodeIndices.getInt(i), identity);
    }
  } finally {
    if (glb_progressWindow != null) glb_progressWindow.dispose();
    glb_progressWindow = null;
  }

  int remaining = (int) floor(100 - glb_printedProgress);
  StringBuilder barBuffer = new StringBuilder();
  for (int c = 0; c < remaining; c++) barBuffer.append('█');
  print(barBuffer.toString());
  println();

  showArrowCursor();
}

// One console/ProgressWindow update, called once per mesh processed -
// same delta >= 1 throttle and '█' console bar import_objects_OBJ.pde's
// own per-line loop already uses, just keyed off glb_meshesProcessed/
// glb_meshCount (a mesh, not a line, is the natural unit of progress for
// a GLB file) instead.
void glbReportProgress () {
  if (control == USER_AUTO) return;

  float Progress = (glb_meshCount > 0) ? (100 * glb_meshesProcessed / float(glb_meshCount)) : 100;
  int delta = (int) floor(Progress - glb_printedProgress);
  if (delta >= 1) {
    StringBuilder barBuffer = new StringBuilder();
    for (int c = 0; c < delta; c++) barBuffer.append('█');
    print(barBuffer.toString());
    glb_printedProgress = floor(Progress);
    if (glb_progressWindow != null) glb_progressWindow.updateFraction(Progress / 100.0f);
  }
}

// Visits node `nodeIndex` and every one of its descendants, composing
// each one's own local transform (glbNodeMatrix(), below) onto its
// parent's already-composed world matrix - the same "clone, then apply
// on top of the clone" shape Model1Ds.pde's own cacheBranch()/
// cacheElement() use for their own PMatrix3D chains (see that file's own
// comment: "mirrors pushMatrix()").
void glbWalkNode (JSONObject json, byte[] bin, int nodeIndex, PMatrix3D parentMatrix) {
  JSONArray nodes = json.getJSONArray("nodes");
  if ((nodeIndex < 0) || (nodeIndex >= nodes.size())) return;

  JSONObject node = nodes.getJSONObject(nodeIndex);

  PMatrix3D worldMatrix = parentMatrix.get(); // clone - mirrors pushMatrix()
  worldMatrix.apply(glbNodeMatrix(node));

  if (node.hasKey("mesh")) {
    glbEmitMesh(json, bin, node.getInt("mesh"), worldMatrix);
  }

  if (node.hasKey("children")) {
    JSONArray children = node.getJSONArray("children");
    for (int i = 0; i < children.size(); i++) {
      glbWalkNode(json, bin, children.getInt(i), worldMatrix);
    }
  }
}

// Each node's own local transform as a PMatrix3D - either a raw 4x4
// matrix (glTF's own column-major float[16], reordered here into
// PMatrix3D's row-major set()/apply() argument order - element (row r,
// col c) sits at a[c*4 + r] in glTF's array) or composed from separate
// translation/rotation(quaternion)/scale, glTF's other allowed shape
// (defaults when a node omits one: translation {0,0,0}, rotation
// {0,0,0,1} (identity), scale {1,1,1}).
PMatrix3D glbNodeMatrix (JSONObject node) {
  PMatrix3D m = new PMatrix3D(); // identity

  if (node.hasKey("matrix")) {
    JSONArray a = node.getJSONArray("matrix");
    m.set(
      a.getFloat(0), a.getFloat(4), a.getFloat(8),  a.getFloat(12),
      a.getFloat(1), a.getFloat(5), a.getFloat(9),  a.getFloat(13),
      a.getFloat(2), a.getFloat(6), a.getFloat(10), a.getFloat(14),
      a.getFloat(3), a.getFloat(7), a.getFloat(11), a.getFloat(15)
    );
    return m;
  }

  float tx = 0, ty = 0, tz = 0;
  if (node.hasKey("translation")) {
    JSONArray t = node.getJSONArray("translation");
    tx = t.getFloat(0); ty = t.getFloat(1); tz = t.getFloat(2);
  }

  float qx = 0, qy = 0, qz = 0, qw = 1;
  if (node.hasKey("rotation")) {
    JSONArray q = node.getJSONArray("rotation");
    qx = q.getFloat(0); qy = q.getFloat(1); qz = q.getFloat(2); qw = q.getFloat(3);
  }

  float sx = 1, sy = 1, sz = 1;
  if (node.hasKey("scale")) {
    JSONArray s = node.getJSONArray("scale");
    sx = s.getFloat(0); sy = s.getFloat(1); sz = s.getFloat(2);
  }

  m.translate(tx, ty, tz);

  // Standard quaternion -> 3x3 rotation matrix, embedded in a 4x4
  // (bottom row/right column left as identity).
  float xx = qx * qx, yy = qy * qy, zz = qz * qz;
  float xy = qx * qy, xz = qx * qz, yz = qy * qz;
  float wx = qw * qx, wy = qw * qy, wz = qw * qz;

  m.apply(
    1 - 2 * (yy + zz),     2 * (xy - wz),     2 * (xz + wy), 0,
        2 * (xy + wz), 1 - 2 * (xx + zz),     2 * (yz - wx), 0,
        2 * (xz - wy),     2 * (yz + wx), 1 - 2 * (xx + yy), 0,
                    0,                 0,                 0, 1
  );

  m.scale(sx, sy, sz);

  return m;
}

// Every supported primitive of mesh `meshIndex`, with every vertex
// carried through worldMatrix (that node's own fully-composed transform)
// before being handed to allPoints.create() - see this file's own header
// comment for exactly which primitive shapes are (and aren't) supported.
void glbEmitMesh (JSONObject json, byte[] bin, int meshIndex, PMatrix3D worldMatrix) {
  glb_meshesProcessed += 1;
  glbReportProgress();

  JSONArray meshes = json.getJSONArray("meshes");
  if ((meshIndex < 0) || (meshIndex >= meshes.size())) return;

  JSONArray primitives = meshes.getJSONObject(meshIndex).getJSONArray("primitives");

  for (int p = 0; p < primitives.size(); p++) {
    JSONObject prim = primitives.getJSONObject(p);

    int mode = prim.hasKey("mode") ? prim.getInt("mode") : 4; // glTF's own default: 4 = TRIANGLES
    if (mode != 4) {
      println("\nGLB import: skipping a primitive with mode " + mode + " (only triangle lists are supported in this version)");
      continue;
    }

    if (prim.hasKey("extensions") && prim.getJSONObject("extensions").hasKey("KHR_draco_mesh_compression")) {
      println("\nGLB import: skipping a Draco-compressed primitive (not supported in this version)");
      continue;
    }

    if (!prim.hasKey("attributes") || !prim.hasKey("indices")) {
      println("\nGLB import: skipping a primitive missing POSITION or indices");
      continue;
    }

    JSONObject attributes = prim.getJSONObject("attributes");
    if (!attributes.hasKey("POSITION")) {
      println("\nGLB import: skipping a primitive with no POSITION attribute");
      continue;
    }

    float[] positions = glbReadVec3FloatAccessor(json, bin, attributes.getInt("POSITION"));
    int[] indices = glbReadIndexAccessor(json, bin, prim.getInt("indices"));
    if ((positions == null) || (indices == null)) continue;

    if (glb_cycleMaterial) current_Material = 1 + (current_Material % 8); // same "g" tag cycling import_objects_OBJ.pde's own does
    if (addToLastGroup == false) allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);

    int vertCount = positions.length / 3;
    int[] pointIndex = new int[vertCount];

    PVector local = new PVector();
    PVector world = new PVector();

    for (int i = 0; i < vertCount; i++) {
      local.x = positions[i * 3];
      local.y = positions[i * 3 + 1];
      local.z = positions[i * 3 + 2];

      worldMatrix.mult(local, world);

      // glTF is always Y-up (right-handed); this app is Z-up - swap Y
      // and Z, negating the new Y, to convert. This is the same mapping
      // import_objects_OBJ.pde's own commented-out
      // "allPoints.create(x, -z, y)" line already spells out, left
      // disabled there only because plain OBJ has no spec-mandated
      // up-axis to convert FROM - glTF's is fixed, so this conversion is
      // unambiguous here.
      float finalX = glb_cx + glb_sx * world.x;
      float finalY = glb_cy + glb_sy * (-world.z);
      float finalZ = glb_cz + glb_sz * world.y;

      pointIndex[i] = allPoints.create(finalX, finalY, finalZ);
    }

    for (int i = 0; i + 2 < indices.length; i += 3) {
      int[] newFace = {
        pointIndex[indices[i]],
        pointIndex[indices[i + 1]],
        pointIndex[indices[i + 2]]
      };
      allFaces.create(newFace);
    }
  }
}

// Reads a VEC3/FLOAT accessor (the shape POSITION always has) into a
// flat {x0,y0,z0, x1,y1,z1, ...} array, or null (with a console message)
// if this accessor isn't that shape, is sparse, or its data isn't in the
// embedded buffer 0 this importer reads from.
float[] glbReadVec3FloatAccessor (JSONObject json, byte[] bin, int accessorIndex) {
  JSONArray accessors = json.getJSONArray("accessors");
  if ((accessorIndex < 0) || (accessorIndex >= accessors.size())) return null;

  JSONObject accessor = accessors.getJSONObject(accessorIndex);
  int componentType = accessor.hasKey("componentType") ? accessor.getInt("componentType") : -1;
  String type = accessor.hasKey("type") ? accessor.getString("type") : "";
  int count = accessor.hasKey("count") ? accessor.getInt("count") : 0;

  if ((componentType != GLB_COMPONENT_FLOAT) || !type.equals("VEC3")) {
    println("\nGLB import: unsupported POSITION accessor (componentType=" + componentType + ", type=" + type + ")");
    return null;
  }

  if (!accessor.hasKey("bufferView")) {
    println("\nGLB import: a POSITION accessor with no bufferView isn't supported (sparse accessors aren't supported in this version)");
    return null;
  }

  JSONArray bufferViews = json.getJSONArray("bufferViews");
  int bufferViewIndex = accessor.getInt("bufferView");
  if ((bufferViewIndex < 0) || (bufferViewIndex >= bufferViews.size())) return null;
  JSONObject bufferView = bufferViews.getJSONObject(bufferViewIndex);

  if (bufferView.hasKey("buffer") && (bufferView.getInt("buffer") != 0)) {
    println("\nGLB import: a bufferView pointing at a buffer other than the embedded one (buffer 0) isn't supported in this version");
    return null;
  }

  int accessorByteOffset = accessor.hasKey("byteOffset") ? accessor.getInt("byteOffset") : 0;
  int bufferViewByteOffset = bufferView.hasKey("byteOffset") ? bufferView.getInt("byteOffset") : 0;
  int byteStride = bufferView.hasKey("byteStride") ? bufferView.getInt("byteStride") : 12; // tightly packed VEC3 FLOAT = 12 bytes
  int base = bufferViewByteOffset + accessorByteOffset;

  float[] out = new float[count * 3];
  for (int i = 0; i < count; i++) {
    int o = base + i * byteStride;
    if (o + 12 > bin.length) {
      println("\nGLB import: POSITION accessor reads past the end of the embedded buffer");
      return null;
    }
    out[i * 3]     = glbReadFloatLE(bin, o);
    out[i * 3 + 1] = glbReadFloatLE(bin, o + 4);
    out[i * 3 + 2] = glbReadFloatLE(bin, o + 8);
  }
  return out;
}

// Reads a SCALAR index accessor - UNSIGNED_BYTE/UNSIGNED_SHORT/
// UNSIGNED_INT, the three types glTF allows for "indices" - into a plain
// int[], widening every value (Java has no unsigned integer types of its
// own). null (with a console message) for anything else unsupported, the
// same reasons as glbReadVec3FloatAccessor() above.
int[] glbReadIndexAccessor (JSONObject json, byte[] bin, int accessorIndex) {
  JSONArray accessors = json.getJSONArray("accessors");
  if ((accessorIndex < 0) || (accessorIndex >= accessors.size())) return null;

  JSONObject accessor = accessors.getJSONObject(accessorIndex);
  int componentType = accessor.hasKey("componentType") ? accessor.getInt("componentType") : -1;
  int count = accessor.hasKey("count") ? accessor.getInt("count") : 0;

  int componentSize;
  if (componentType == GLB_COMPONENT_UNSIGNED_BYTE) componentSize = 1;
  else if (componentType == GLB_COMPONENT_UNSIGNED_SHORT) componentSize = 2;
  else if (componentType == GLB_COMPONENT_UNSIGNED_INT) componentSize = 4;
  else {
    println("\nGLB import: unsupported indices componentType=" + componentType);
    return null;
  }

  if (!accessor.hasKey("bufferView")) {
    println("\nGLB import: an indices accessor with no bufferView isn't supported (sparse accessors aren't supported in this version)");
    return null;
  }

  JSONArray bufferViews = json.getJSONArray("bufferViews");
  int bufferViewIndex = accessor.getInt("bufferView");
  if ((bufferViewIndex < 0) || (bufferViewIndex >= bufferViews.size())) return null;
  JSONObject bufferView = bufferViews.getJSONObject(bufferViewIndex);

  if (bufferView.hasKey("buffer") && (bufferView.getInt("buffer") != 0)) {
    println("\nGLB import: a bufferView pointing at a buffer other than the embedded one (buffer 0) isn't supported in this version");
    return null;
  }

  int accessorByteOffset = accessor.hasKey("byteOffset") ? accessor.getInt("byteOffset") : 0;
  int bufferViewByteOffset = bufferView.hasKey("byteOffset") ? bufferView.getInt("byteOffset") : 0;
  int byteStride = bufferView.hasKey("byteStride") ? bufferView.getInt("byteStride") : componentSize;
  int base = bufferViewByteOffset + accessorByteOffset;

  int[] out = new int[count];
  for (int i = 0; i < count; i++) {
    int o = base + i * byteStride;
    if (o + componentSize > bin.length) {
      println("\nGLB import: indices accessor reads past the end of the embedded buffer");
      return null;
    }
    if (componentSize == 1) out[i] = bin[o] & 0xFF;
    else if (componentSize == 2) out[i] = glbReadU16LE(bin, o);
    else out[i] = glbReadU32LE(bin, o);
  }
  return out;
}

// Little-endian byte readers - every number in a GLB binary chunk (chunk
// headers, and every accessor's own packed data) is little-endian per
// spec, regardless of the platform this importer runs on.
int glbReadU32LE (byte[] b, int off) {
  return (b[off] & 0xFF) | ((b[off + 1] & 0xFF) << 8) | ((b[off + 2] & 0xFF) << 16) | ((b[off + 3] & 0xFF) << 24);
}

int glbReadU16LE (byte[] b, int off) {
  return (b[off] & 0xFF) | ((b[off + 1] & 0xFF) << 8);
}

float glbReadFloatLE (byte[] b, int off) {
  return Float.intBitsToFloat(glbReadU32LE(b, off));
}
