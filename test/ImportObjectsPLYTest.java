import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

// import_objects_PLY() is a plain PLY(.ply)-format parser (both its ASCII
// and binary DATA variants share the same plain-text header) plus calls
// to allPoints.create()/allFaces.create()/allGroups.beginNewGroup() - no
// WIN3D.graphics, no PImage, so like ImportObjectsOBJTest.java's own
// import_objects_OBJ() tests, this is directly testable from a bare,
// never-setup()'d instance with no extra seeding.
//
// Each test below writes the smallest PLY file that exercises one path -
// see import_objects_PLY.pde's own file-header comment for exactly which
// elements/properties each path corresponds to, and for the documented
// v1-scope limitation (only "vertex"'s own x/y/z and "face"'s own first
// list property are read; every other element/property is still walked,
// to stay in sync, but not interpreted).
class ImportObjectsPLYTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
  }

  private Path plyFile (String name, String body) throws IOException {
    Path f = Files.createTempFile(name, ".ply");
    Files.writeString(f, body);
    return f;
  }

  private Path plyBinaryFile (String name, byte[] body) throws IOException {
    Path f = Files.createTempFile(name, ".ply");
    Files.write(f, body);
    return f;
  }

  // ================= ASCII ======================================================

  @Test
  void importObjectsPLY_ascii_importsATriangleFace () throws IOException {
    Path f = plyFile("ply-ascii-triangle-test", """
        ply
        format ascii 1.0
        element vertex 3
        property float x
        property float y
        property float z
        element face 1
        property list uchar int vertex_indices
        end_header
        0 0 0
        1 0 0
        1 1 0
        3 0 1 2
        """
    );

    app.import_objects_PLY(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(3, app.allPoints.getLength());
    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
  }

  @Test
  void importObjectsPLY_ascii_faceWithMoreThanThreeIndices_staysAnNgon () throws IOException {
    Path f = plyFile("ply-ascii-quad-test", """
        ply
        format ascii 1.0
        element vertex 4
        property float x
        property float y
        property float z
        element face 1
        property list uchar int vertex_indices
        end_header
        0 0 0
        1 0 0
        1 1 0
        0 1 0
        4 0 1 2 3
        """
    );

    app.import_objects_PLY(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2, 3}, app.allFaces.nodes[0]);
  }

  @Test
  void importObjectsPLY_ascii_appliesTheOffsetAndScaleToEveryVertex () throws IOException {
    Path f = plyFile("ply-ascii-transform-test", """
        ply
        format ascii 1.0
        element vertex 1
        property float x
        property float y
        property float z
        end_header
        1 2 3
        """
    );

    app.import_objects_PLY(f.toString(), 0, 0, 0, 1, 0, 0, /*cx,cy,cz*/ 10, 20, 30, /*sx,sy,sz*/ 2, 2, 2);

    assertEquals(12f, app.allPoints.getX(0), 0.0001f);
    assertEquals(24f, app.allPoints.getY(0), 0.0001f);
    assertEquals(36f, app.allPoints.getZ(0), 0.0001f);
  }

  @Test
  void importObjectsPLY_ascii_skipsUninterpretedVertexAndFaceProperties () throws IOException {
    // nx/ny/nz (a per-vertex normal) and a per-face red/green/blue after
    // the index list - neither is x/y/z or the face's own first list
    // property, so both should be correctly walked past without being
    // read as geometry - see this file's own header comment.
    Path f = plyFile("ply-ascii-extra-properties-test", """
        ply
        format ascii 1.0
        element vertex 3
        property float x
        property float y
        property float z
        property float nx
        property float ny
        property float nz
        element face 1
        property list uchar int vertex_indices
        property uchar red
        property uchar green
        property uchar blue
        end_header
        0 0 0 0 0 1
        1 0 0 0 0 1
        1 1 0 0 0 1
        3 0 1 2 255 0 0
        """
    );

    app.import_objects_PLY(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(3, app.allPoints.getLength());
    assertEquals(0f, app.allPoints.getX(0), 0.0001f);
    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
  }

  @Test
  void importObjectsPLY_ascii_unrecognizedElementType_isSkippedWithoutThrowing () throws IOException {
    Path f = plyFile("ply-ascii-unknown-element-test", """
        ply
        format ascii 1.0
        element edge 1
        property int vertex1
        property int vertex2
        element vertex 2
        property float x
        property float y
        property float z
        end_header
        0 1
        0 0 0
        1 0 0
        """
    );

    assertDoesNotThrow(() -> {
      app.import_objects_PLY(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(2, app.allPoints.getLength(), "the edge element should have been skipped, not thrown, and the vertex cursor stayed in sync");
  }

  // ================= binary (little-endian) ====================================

  private void writeU32LE (ByteArrayOutputStream out, int v) {
    out.write(v & 0xFF);
    out.write((v >> 8) & 0xFF);
    out.write((v >> 16) & 0xFF);
    out.write((v >> 24) & 0xFF);
  }

  private void writeFloatLE (ByteArrayOutputStream out, float v) {
    writeU32LE(out, Float.floatToIntBits(v));
  }

  @Test
  void importObjectsPLY_binaryLittleEndian_importsATriangleFace () throws IOException {
    String header = """
        ply
        format binary_little_endian 1.0
        element vertex 3
        property float x
        property float y
        property float z
        element face 1
        property list uchar int vertex_indices
        end_header
        """;

    ByteArrayOutputStream out = new ByteArrayOutputStream();
    out.writeBytes(header.getBytes(StandardCharsets.UTF_8));

    // 3 vertices, x/y/z as float32 each.
    float[][] verts = {{0, 0, 0}, {1, 0, 0}, {1, 1, 0}};
    for (float[] v : verts) {
      writeFloatLE(out, v[0]);
      writeFloatLE(out, v[1]);
      writeFloatLE(out, v[2]);
    }

    // 1 face: list count (uchar) = 3, then 3 int32 indices.
    out.write(3);
    writeU32LE(out, 0);
    writeU32LE(out, 1);
    writeU32LE(out, 2);

    Path f = plyBinaryFile("ply-binary-triangle-test", out.toByteArray());

    app.import_objects_PLY(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(3, app.allPoints.getLength());
    assertEquals(1f, app.allPoints.getX(1), 0.0001f);
    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
  }

  @Test
  void importObjectsPLY_binaryLittleEndian_truncatedData_stopsWithoutThrowing () throws IOException {
    String header = """
        ply
        format binary_little_endian 1.0
        element vertex 2
        property float x
        property float y
        property float z
        end_header
        """;

    ByteArrayOutputStream out = new ByteArrayOutputStream();
    out.writeBytes(header.getBytes(StandardCharsets.UTF_8));
    // Only one vertex's worth of bytes (12), header promised 2 vertices.
    writeFloatLE(out, 1);
    writeFloatLE(out, 2);
    writeFloatLE(out, 3);

    Path f = plyBinaryFile("ply-binary-truncated-test", out.toByteArray());

    assertDoesNotThrow(() -> {
      app.import_objects_PLY(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(1, app.allPoints.getLength(), "the one complete vertex should have been read before the truncation was noticed");
  }

  // ================= malformed files ============================================

  @Test
  void importObjectsPLY_missingPlyMagicLine_doesNotThrow () throws IOException {
    Path f = plyFile("ply-missing-magic-test", "not a ply file\nat all\n");

    assertDoesNotThrow(() -> {
      app.import_objects_PLY(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(0, app.allPoints.getLength());
    assertEquals(0, app.allFaces.nodes.length);
  }

  // ================= grouping: PLY has no sub-object boundary of its own =======

  @Test
  void importObjectsPLY_wholeFileIsAlwaysASingleGroup () throws IOException {
    Path f = plyFile("ply-single-group-test", """
        ply
        format ascii 1.0
        element vertex 3
        property float x
        property float y
        property float z
        element face 1
        property list uchar int vertex_indices
        end_header
        0 0 0
        1 0 0
        1 1 0
        3 0 1 2
        """
    );

    app.import_objects_PLY(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allGroups.num, "PLY has no OBJ-'g'/STL-'solid'-style sub-object boundary - see this file's own header comment");
  }

  // ================= progress window headless-safety ===========================
  // Same guarantee ImportObjectsOBJTest.java's own identical test already
  // makes explicit for import_objects_OBJ() - see that file's own comment.

  @Test
  void importObjectsPLY_neverThrowsHeadlessExceptionEvenWithShowImportProgressOn () throws IOException {
    Path f = plyFile("ply-headless-test", """
        ply
        format ascii 1.0
        element vertex 1
        property float x
        property float y
        property float z
        end_header
        1 2 3
        """
    );

    app.showImportProgress = true;

    assertDoesNotThrow(() -> {
      app.import_objects_PLY(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });
  }
}
