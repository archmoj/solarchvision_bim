import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

// import_objects_GLB() is a plain binary-glTF-container parser (12-byte
// header, then JSON + BIN chunks) plus calls to allPoints.create()/
// allFaces.create()/allGroups.beginNewGroup() - no WIN3D.graphics, no
// PImage, so like ImportObjectsOBJTest.java's own import_objects_OBJ()
// tests, this is directly testable from a bare, never-setup()'d instance
// with no extra seeding.
//
// Each test below builds the smallest valid .glb byte stream that
// exercises one path - see import_objects_GLB.pde's own file-header
// comment for exactly which glTF shapes each path corresponds to, and
// for the documented v1-scope limitations (indexed TRIANGLES only, a
// VEC3/FLOAT POSITION accessor, an unsigned-integer indices accessor,
// only the embedded buffer 0, no Draco).
class ImportObjectsGLBTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
  }

  // ---------------------------------------------------------------------
  // Minimal .glb byte-stream builder - every number a .glb container
  // itself (as opposed to the JSON text it carries) uses is little-
  // endian per spec, regardless of the platform running this test - see
  // import_objects_GLB.pde's own binReadU32LE()/binReadFloatLE() comment.
  // ---------------------------------------------------------------------

  private void writeU32LE (ByteArrayOutputStream out, int v) {
    out.write(v & 0xFF);
    out.write((v >> 8) & 0xFF);
    out.write((v >> 16) & 0xFF);
    out.write((v >> 24) & 0xFF);
  }

  private void writeU16LE (ByteArrayOutputStream out, int v) {
    out.write(v & 0xFF);
    out.write((v >> 8) & 0xFF);
  }

  private void writeFloatLE (ByteArrayOutputStream out, float v) {
    writeU32LE(out, Float.floatToIntBits(v));
  }

  // Assembles a complete .glb file from a JSON chunk's own text and a BIN
  // chunk's own raw bytes - padding each to a 4-byte boundary the way the
  // spec requires (JSON padded with spaces, BIN padded with zero bytes),
  // and writing the 12-byte header (magic, version, total length) and
  // both chunks' own 8-byte headers (length + type) around them.
  private byte[] glb (String json, byte[] bin) {
    byte[] jsonBytes = json.getBytes(StandardCharsets.UTF_8);
    int jsonPad = (4 - (jsonBytes.length % 4)) % 4;
    int binPad = (4 - (bin.length % 4)) % 4;

    int jsonChunkLength = jsonBytes.length + jsonPad;
    int binChunkLength = bin.length + binPad;
    int totalLength = 12 + 8 + jsonChunkLength + 8 + binChunkLength;

    ByteArrayOutputStream out = new ByteArrayOutputStream();
    out.writeBytes("glTF".getBytes(StandardCharsets.US_ASCII));
    writeU32LE(out, 2); // version
    writeU32LE(out, totalLength);

    writeU32LE(out, jsonChunkLength);
    out.writeBytes("JSON".getBytes(StandardCharsets.US_ASCII));
    out.writeBytes(jsonBytes);
    for (int i = 0; i < jsonPad; i++) out.write(' ');

    writeU32LE(out, binChunkLength);
    out.write('B'); out.write('I'); out.write('N'); out.write(0);
    out.writeBytes(bin);
    for (int i = 0; i < binPad; i++) out.write(0);

    return out.toByteArray();
  }

  // One triangle's worth of POSITION data (3 vertices, VEC3/FLOAT) plus
  // its own 3-index UNSIGNED_SHORT index buffer, laid out back to back -
  // the bufferViews below point at the two halves by byte offset.
  private byte[] triangleBin (float[][] verts, int[] indices) {
    ByteArrayOutputStream out = new ByteArrayOutputStream();
    for (float[] v : verts) {
      writeFloatLE(out, v[0]);
      writeFloatLE(out, v[1]);
      writeFloatLE(out, v[2]);
    }
    for (int i : indices) writeU16LE(out, i);
    return out.toByteArray();
  }

  // The glTF JSON for one scene/node/mesh/primitive, reading POSITION
  // from bufferView 0 and indices (UNSIGNED_SHORT = componentType 5123)
  // from bufferView 1 - see this file's own header comment for why those
  // two types are what this importer actually supports.
  private String oneTriangleJson (int vertexCount, int indexCount, int positionsByteLength, int indicesByteOffset, int indicesByteLength) {
    return """
        {
          "asset": {"version": "2.0"},
          "scene": 0,
          "scenes": [{"nodes": [0]}],
          "nodes": [{"mesh": 0}],
          "meshes": [{"primitives": [{"attributes": {"POSITION": 0}, "indices": 1, "mode": 4}]}],
          "accessors": [
            {"bufferView": 0, "componentType": 5126, "count": %d, "type": "VEC3"},
            {"bufferView": 1, "componentType": 5123, "count": %d, "type": "SCALAR"}
          ],
          "bufferViews": [
            {"buffer": 0, "byteOffset": 0, "byteLength": %d},
            {"buffer": 0, "byteOffset": %d, "byteLength": %d}
          ],
          "buffers": [{"byteLength": %d}]
        }
        """.formatted(vertexCount, indexCount, positionsByteLength, indicesByteOffset, indicesByteLength, positionsByteLength + indicesByteLength);
  }

  private Path glbFile (String name, byte[] body) throws IOException {
    Path f = Files.createTempFile(name, ".glb");
    Files.write(f, body);
    return f;
  }

  // ================= basic import ===============================================

  @Test
  void importObjectsGLB_oneTriangleMesh_importsOneFace () throws IOException {
    float[][] verts = { {0, 0, 0}, {1, 0, 0}, {1, 1, 0} };
    int[] indices = { 0, 1, 2 };
    byte[] bin = triangleBin(verts, indices);
    String json = oneTriangleJson(3, 3, 36, 36, 6);

    Path f = glbFile("glb-triangle-test", glb(json, bin));

    app.import_objects_GLB(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(3, app.allPoints.getLength());
    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
  }

  @Test
  void importObjectsGLB_appliesTheOffsetAndScaleToEveryVertex () throws IOException {
    float[][] verts = { {1, 2, 3}, {1, 2, 3}, {1, 2, 3} };
    int[] indices = { 0, 1, 2 };
    byte[] bin = triangleBin(verts, indices);
    String json = oneTriangleJson(3, 3, 36, 36, 6);

    Path f = glbFile("glb-transform-test", glb(json, bin));

    app.import_objects_GLB(f.toString(), 0, 0, 0, 1, 0, 0, /*cx,cy,cz*/ 10, 20, 30, /*sx,sy,sz*/ 2, 2, 2);

    assertEquals(12f, app.allPoints.getX(0), 0.0001f);
    assertEquals(24f, app.allPoints.getY(0), 0.0001f);
    assertEquals(36f, app.allPoints.getZ(0), 0.0001f);
  }

  @Test
  void importObjectsGLB_unsignedByteIndices_areRead () throws IOException {
    float[][] verts = { {0, 0, 0}, {1, 0, 0}, {1, 1, 0} };

    ByteArrayOutputStream binOut = new ByteArrayOutputStream();
    for (float[] v : verts) {
      writeFloatLE(binOut, v[0]);
      writeFloatLE(binOut, v[1]);
      writeFloatLE(binOut, v[2]);
    }
    binOut.write(0); binOut.write(1); binOut.write(2); // UNSIGNED_BYTE indices
    byte[] bin = binOut.toByteArray();

    String json = """
        {
          "asset": {"version": "2.0"},
          "scene": 0,
          "scenes": [{"nodes": [0]}],
          "nodes": [{"mesh": 0}],
          "meshes": [{"primitives": [{"attributes": {"POSITION": 0}, "indices": 1, "mode": 4}]}],
          "accessors": [
            {"bufferView": 0, "componentType": 5126, "count": 3, "type": "VEC3"},
            {"bufferView": 1, "componentType": 5121, "count": 3, "type": "SCALAR"}
          ],
          "bufferViews": [
            {"buffer": 0, "byteOffset": 0, "byteLength": 36},
            {"buffer": 0, "byteOffset": 36, "byteLength": 3}
          ],
          "buffers": [{"byteLength": 39}]
        }
        """;

    Path f = glbFile("glb-ubyte-indices-test", glb(json, bin));

    app.import_objects_GLB(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
  }

  // ================= node hierarchy and transforms ==============================

  @Test
  void importObjectsGLB_nodeTranslation_isAppliedToThatNodesOwnMesh () throws IOException {
    float[][] verts = { {0, 0, 0}, {0, 0, 0}, {0, 0, 0} };
    int[] indices = { 0, 1, 2 };
    byte[] bin = triangleBin(verts, indices);

    String json = """
        {
          "asset": {"version": "2.0"},
          "scene": 0,
          "scenes": [{"nodes": [0]}],
          "nodes": [{"mesh": 0, "translation": [5, 6, 7]}],
          "meshes": [{"primitives": [{"attributes": {"POSITION": 0}, "indices": 1, "mode": 4}]}],
          "accessors": [
            {"bufferView": 0, "componentType": 5126, "count": 3, "type": "VEC3"},
            {"bufferView": 1, "componentType": 5123, "count": 3, "type": "SCALAR"}
          ],
          "bufferViews": [
            {"buffer": 0, "byteOffset": 0, "byteLength": 36},
            {"buffer": 0, "byteOffset": 36, "byteLength": 6}
          ],
          "buffers": [{"byteLength": 42}]
        }
        """;

    Path f = glbFile("glb-node-translation-test", glb(json, bin));

    app.import_objects_GLB(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(5f, app.allPoints.getX(0), 0.0001f);
    assertEquals(6f, app.allPoints.getY(0), 0.0001f);
    assertEquals(7f, app.allPoints.getZ(0), 0.0001f);
  }

  @Test
  void importObjectsGLB_nestedNode_composesItsOwnTransformOntoItsParentsOwn () throws IOException {
    float[][] verts = { {0, 0, 0}, {0, 0, 0}, {0, 0, 0} };
    int[] indices = { 0, 1, 2 };
    byte[] bin = triangleBin(verts, indices);

    String json = """
        {
          "asset": {"version": "2.0"},
          "scene": 0,
          "scenes": [{"nodes": [0]}],
          "nodes": [
            {"translation": [10, 0, 0], "children": [1]},
            {"mesh": 0, "translation": [0, 1, 0]}
          ],
          "meshes": [{"primitives": [{"attributes": {"POSITION": 0}, "indices": 1, "mode": 4}]}],
          "accessors": [
            {"bufferView": 0, "componentType": 5126, "count": 3, "type": "VEC3"},
            {"bufferView": 1, "componentType": 5123, "count": 3, "type": "SCALAR"}
          ],
          "bufferViews": [
            {"buffer": 0, "byteOffset": 0, "byteLength": 36},
            {"buffer": 0, "byteOffset": 36, "byteLength": 6}
          ],
          "buffers": [{"byteLength": 42}]
        }
        """;

    Path f = glbFile("glb-nested-node-test", glb(json, bin));

    app.import_objects_GLB(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(10f, app.allPoints.getX(0), 0.0001f, "parent's own translation");
    assertEquals(1f, app.allPoints.getY(0), 0.0001f, "composed with the child's own translation");
  }

  // ================= grouping / material cycling ================================

  @Test
  void importObjectsGLB_oneGroupPerMeshInstance_cyclesMaterial () throws IOException {
    float[][] verts = { {0, 0, 0}, {1, 0, 0}, {1, 1, 0} };
    int[] indices = { 0, 1, 2 };
    byte[] bin = triangleBin(verts, indices);

    String json = """
        {
          "asset": {"version": "2.0"},
          "scene": 0,
          "scenes": [{"nodes": [0, 1]}],
          "nodes": [{"mesh": 0}, {"mesh": 0}],
          "meshes": [{"primitives": [{"attributes": {"POSITION": 0}, "indices": 1, "mode": 4}]}],
          "accessors": [
            {"bufferView": 0, "componentType": 5126, "count": 3, "type": "VEC3"},
            {"bufferView": 1, "componentType": 5123, "count": 3, "type": "SCALAR"}
          ],
          "bufferViews": [
            {"buffer": 0, "byteOffset": 0, "byteLength": 36},
            {"buffer": 0, "byteOffset": 36, "byteLength": 6}
          ],
          "buffers": [{"byteLength": 42}]
        }
        """;

    Path f = glbFile("glb-groups-test", glb(json, bin));

    app.import_objects_GLB(f.toString(), -1 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allGroups.num);
    assertEquals(1, app.allFaces.options[0][0], "m == -1 cycles once per node with a mesh, starting at 1");
    assertEquals(2, app.allFaces.options[1][0]);
  }

  @Test
  void importObjectsGLB_doesNotStartNewGroups_whenAddingToLastGroup () throws IOException {
    app.addToLastGroup = true;
    app.allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0); // the "last group" to add into

    float[][] verts = { {0, 0, 0}, {1, 0, 0}, {1, 1, 0} };
    int[] indices = { 0, 1, 2 };
    byte[] bin = triangleBin(verts, indices);
    String json = oneTriangleJson(3, 3, 36, 36, 6);

    Path f = glbFile("glb-addtolastgroup-test", glb(json, bin));

    app.import_objects_GLB(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allGroups.num);
  }

  // ================= unsupported/skipped shapes ==================================

  @Test
  void importObjectsGLB_nonTriangleListPrimitive_isSkippedWithoutThrowing () throws IOException {
    float[][] verts = { {0, 0, 0}, {1, 0, 0}, {1, 1, 0} };
    int[] indices = { 0, 1, 2 };
    byte[] bin = triangleBin(verts, indices);

    String json = """
        {
          "asset": {"version": "2.0"},
          "scene": 0,
          "scenes": [{"nodes": [0]}],
          "nodes": [{"mesh": 0}],
          "meshes": [{"primitives": [{"attributes": {"POSITION": 0}, "indices": 1, "mode": 1}]}],
          "accessors": [
            {"bufferView": 0, "componentType": 5126, "count": 3, "type": "VEC3"},
            {"bufferView": 1, "componentType": 5123, "count": 3, "type": "SCALAR"}
          ],
          "bufferViews": [
            {"buffer": 0, "byteOffset": 0, "byteLength": 36},
            {"buffer": 0, "byteOffset": 36, "byteLength": 6}
          ],
          "buffers": [{"byteLength": 42}]
        }
        """; // mode 1 = LINES, not the TRIANGLES (4) this importer supports

    Path f = glbFile("glb-non-triangles-test", glb(json, bin));

    assertDoesNotThrow(() -> {
      app.import_objects_GLB(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(0, app.allFaces.nodes.length);
  }

  @Test
  void importObjectsGLB_dracoRequiredExtension_cancelsTheWholeImport () throws IOException {
    float[][] verts = { {0, 0, 0}, {1, 0, 0}, {1, 1, 0} };
    int[] indices = { 0, 1, 2 };
    byte[] bin = triangleBin(verts, indices);

    String json = """
        {
          "asset": {"version": "2.0"},
          "extensionsRequired": ["KHR_draco_mesh_compression"],
          "scene": 0,
          "scenes": [{"nodes": [0]}],
          "nodes": [{"mesh": 0}],
          "meshes": [{"primitives": [{"attributes": {"POSITION": 0}, "indices": 1, "mode": 4}]}],
          "accessors": [
            {"bufferView": 0, "componentType": 5126, "count": 3, "type": "VEC3"},
            {"bufferView": 1, "componentType": 5123, "count": 3, "type": "SCALAR"}
          ],
          "bufferViews": [
            {"buffer": 0, "byteOffset": 0, "byteLength": 36},
            {"buffer": 0, "byteOffset": 36, "byteLength": 6}
          ],
          "buffers": [{"byteLength": 42}]
        }
        """;

    Path f = glbFile("glb-draco-required-test", glb(json, bin));

    app.import_objects_GLB(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length, "the whole import should be cancelled, not just the Draco primitive skipped - see this file's own header comment");
  }

  // ================= malformed files =============================================

  @Test
  void importObjectsGLB_missingMagicBytes_doesNotThrow () throws IOException {
    byte[] notAGlb = "this is not a glb file at all, just some bytes".getBytes(StandardCharsets.UTF_8);
    Path f = glbFile("glb-bad-magic-test", notAGlb);

    assertDoesNotThrow(() -> {
      app.import_objects_GLB(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(0, app.allFaces.nodes.length);
  }

  @Test
  void importObjectsGLB_tooShortToHaveAHeader_doesNotThrow () throws IOException {
    Path f = glbFile("glb-too-short-test", new byte[]{'g', 'l'});

    assertDoesNotThrow(() -> {
      app.import_objects_GLB(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(0, app.allFaces.nodes.length);
  }

  // ================= progress window headless-safety ===========================
  // Same guarantee ImportObjectsOBJTest.java's own identical test already
  // makes explicit for import_objects_OBJ() - see that file's own comment.

  @Test
  void importObjectsGLB_neverThrowsHeadlessExceptionEvenWithShowImportProgressOn () throws IOException {
    float[][] verts = { {0, 0, 0}, {1, 0, 0}, {1, 1, 0} };
    int[] indices = { 0, 1, 2 };
    byte[] bin = triangleBin(verts, indices);
    String json = oneTriangleJson(3, 3, 36, 36, 6);

    Path f = glbFile("glb-headless-test", glb(json, bin));

    app.showImportProgress = true;

    assertDoesNotThrow(() -> {
      app.import_objects_GLB(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });
  }
}
