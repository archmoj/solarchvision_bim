import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

// import_objects_STL() reads both STL variants - plain-text ASCII and
// binary - plus calls to allPoints.create()/allFaces.create()/
// allGroups.beginNewGroup() - no WIN3D.graphics, no PImage, so like
// ImportObjectsOBJTest.java's own import_objects_OBJ() tests, this is
// directly testable from a bare, never-setup()'d instance with no extra
// seeding.
//
// Each test below writes the smallest STL file that exercises one path -
// see import_objects_STL.pde's own file-header comment for exactly how
// binary-vs-ASCII is detected, and for the documented v1-scope
// limitation (every triangle gets the single material the m parameter
// names - the one real sub-object boundary STL has at all is ASCII's own
// optional multiple "solid ... endsolid" blocks).
class ImportObjectsSTLTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
  }

  private Path stlFile (String name, String body) throws IOException {
    Path f = Files.createTempFile(name, ".stl");
    Files.writeString(f, body);
    return f;
  }

  private Path stlBinaryFile (String name, byte[] body) throws IOException {
    Path f = Files.createTempFile(name, ".stl");
    Files.write(f, body);
    return f;
  }

  // ================= ASCII ======================================================

  @Test
  void importObjectsSTL_ascii_importsOneTriangleFacet () throws IOException {
    Path f = stlFile("stl-ascii-triangle-test", """
        solid test
        facet normal 0 0 1
          outer loop
            vertex 0 0 0
            vertex 1 0 0
            vertex 1 1 0
          endloop
        endfacet
        endsolid test
        """
    );

    app.import_objects_STL(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(3, app.allPoints.getLength());
    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
  }

  @Test
  void importObjectsSTL_ascii_appliesTheOffsetAndScaleToEveryVertex () throws IOException {
    Path f = stlFile("stl-ascii-transform-test", """
        solid test
        facet normal 0 0 1
          outer loop
            vertex 1 2 3
            vertex 1 2 3
            vertex 1 2 3
          endloop
        endfacet
        endsolid test
        """
    );

    app.import_objects_STL(f.toString(), 0, 0, 0, 1, 0, 0, /*cx,cy,cz*/ 10, 20, 30, /*sx,sy,sz*/ 2, 2, 2);

    assertEquals(12f, app.allPoints.getX(0), 0.0001f);
    assertEquals(24f, app.allPoints.getY(0), 0.0001f);
    assertEquals(36f, app.allPoints.getZ(0), 0.0001f);
  }

  @Test
  void importObjectsSTL_ascii_multipleSolidBlocks_oneGroupEach_cyclesMaterial () throws IOException {
    Path f = stlFile("stl-ascii-multi-solid-test", """
        solid first
        facet normal 0 0 1
          outer loop
            vertex 0 0 0
            vertex 1 0 0
            vertex 1 1 0
          endloop
        endfacet
        endsolid first
        solid second
        facet normal 0 0 1
          outer loop
            vertex 0 0 1
            vertex 1 0 1
            vertex 1 1 1
          endloop
        endfacet
        endsolid second
        """
    );

    app.import_objects_STL(f.toString(), -1 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allGroups.num, "each \"solid\" block should start its own group");
    assertEquals(1, app.allFaces.options[0][0], "m == -1 cycles once per \"solid\" line, starting at 1");
    assertEquals(2, app.allFaces.options[1][0]);
  }

  @Test
  void importObjectsSTL_ascii_withAnExplicitMaterial_usesItForEveryFacet () throws IOException {
    Path f = stlFile("stl-ascii-material-test", """
        solid test
        facet normal 0 0 1
          outer loop
            vertex 0 0 0
            vertex 1 0 0
            vertex 1 1 0
          endloop
        endfacet
        facet normal 0 0 1
          outer loop
            vertex 0 0 1
            vertex 1 0 1
            vertex 1 1 1
          endloop
        endfacet
        endsolid test
        """
    );

    app.import_objects_STL(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(5, app.allFaces.options[0][0]);
    assertEquals(5, app.allFaces.options[1][0]);
  }

  @Test
  void importObjectsSTL_ascii_ignoresIncompleteFacets () throws IOException {
    // A facet whose own "outer loop" never actually got 3 vertices
    // (malformed/truncated) shouldn't build a degenerate face - only a
    // facet with exactly 3 pending vertices at "endfacet" does.
    Path f = stlFile("stl-ascii-incomplete-facet-test", """
        solid test
        facet normal 0 0 1
          outer loop
            vertex 0 0 0
            vertex 1 0 0
          endloop
        endfacet
        endsolid test
        """
    );

    app.import_objects_STL(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length);
  }

  // ================= binary ======================================================

  private void writeU32LE (ByteArrayOutputStream out, int v) {
    out.write(v & 0xFF);
    out.write((v >> 8) & 0xFF);
    out.write((v >> 16) & 0xFF);
    out.write((v >> 24) & 0xFF);
  }

  private void writeFloatLE (ByteArrayOutputStream out, float v) {
    writeU32LE(out, Float.floatToIntBits(v));
  }

  // One full binary STL file: an 80-byte header, a uint32 triangle count,
  // then 50 bytes per triangle (a 12-byte normal this importer doesn't
  // read, 3x 12-byte vertices, a 2-byte attribute byte count) - see this
  // file's own header comment for exactly this layout, and for the
  // "expected size == actual size" binary-detection heuristic it relies
  // on, which is why the triangle count here must exactly match how many
  // 50-byte records actually follow.
  private byte[] binarySTL (float[][][] triangles) {
    ByteArrayOutputStream out = new ByteArrayOutputStream();
    byte[] header = new byte[80];
    out.writeBytes(header);
    writeU32LE(out, triangles.length);

    for (float[][] tri : triangles) {
      // normal (unused by this importer, but still has to be present)
      writeFloatLE(out, 0);
      writeFloatLE(out, 0);
      writeFloatLE(out, 1);
      for (float[] v : tri) {
        writeFloatLE(out, v[0]);
        writeFloatLE(out, v[1]);
        writeFloatLE(out, v[2]);
      }
      out.write(0); // attribute byte count (2 bytes)
      out.write(0);
    }

    return out.toByteArray();
  }

  @Test
  void importObjectsSTL_binary_importsOneTriangle () throws IOException {
    byte[] data = binarySTL(new float[][][] {
        { {0, 0, 0}, {1, 0, 0}, {1, 1, 0} }
    });
    Path f = stlBinaryFile("stl-binary-triangle-test", data);

    app.import_objects_STL(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(3, app.allPoints.getLength());
    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
  }

  @Test
  void importObjectsSTL_binary_importsMultipleTrianglesAsOneGroup () throws IOException {
    byte[] data = binarySTL(new float[][][] {
        { {0, 0, 0}, {1, 0, 0}, {1, 1, 0} },
        { {0, 0, 1}, {1, 0, 1}, {1, 1, 1} }
    });
    Path f = stlBinaryFile("stl-binary-multi-triangle-test", data);

    app.import_objects_STL(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(6, app.allPoints.getLength());
    assertEquals(2, app.allFaces.nodes.length);
    assertEquals(1, app.allGroups.num, "binary STL has no \"solid\"-block boundary of its own - always a single group");
  }

  @Test
  void importObjectsSTL_binary_appliesTheOffsetAndScaleToEveryVertex () throws IOException {
    byte[] data = binarySTL(new float[][][] {
        { {1, 2, 3}, {1, 2, 3}, {1, 2, 3} }
    });
    Path f = stlBinaryFile("stl-binary-transform-test", data);

    app.import_objects_STL(f.toString(), 0, 0, 0, 1, 0, 0, /*cx,cy,cz*/ 10, 20, 30, /*sx,sy,sz*/ 2, 2, 2);

    assertEquals(12f, app.allPoints.getX(0), 0.0001f);
    assertEquals(24f, app.allPoints.getY(0), 0.0001f);
    assertEquals(36f, app.allPoints.getZ(0), 0.0001f);
  }

  @Test
  void importObjectsSTL_binary_fileStartingWithSolid_isStillDetectedAsBinary_whenSizeMatches () throws IOException {
    // The standard heuristic (see this file's own header comment): an
    // 80-byte free-form header CAN start with the literal bytes "solid "
    // without the file actually being ASCII - detection has to go by the
    // expected-vs-actual byte count, not by sniffing the first word.
    byte[] data = binarySTL(new float[][][] {
        { {0, 0, 0}, {1, 0, 0}, {1, 1, 0} }
    });
    // Overwrite the first 6 header bytes with "solid " to try to fool a
    // naive reader.
    byte[] fooled = data.clone();
    byte[] prefix = "solid ".getBytes(StandardCharsets.US_ASCII);
    System.arraycopy(prefix, 0, fooled, 0, prefix.length);

    Path f = stlBinaryFile("stl-binary-fooled-header-test", fooled);

    app.import_objects_STL(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length, "should still have been read as binary, not ASCII, and so still produced the one triangle");
  }

  // ================= malformed files ============================================

  @Test
  void importObjectsSTL_emptyFile_doesNotThrow () throws IOException {
    Path f = stlBinaryFile("stl-empty-test", new byte[0]);

    assertDoesNotThrow(() -> {
      app.import_objects_STL(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(0, app.allFaces.nodes.length);
  }

  // ================= progress window headless-safety ===========================
  // Same guarantee ImportObjectsOBJTest.java's own identical test already
  // makes explicit for import_objects_OBJ() - see that file's own comment.

  @Test
  void importObjectsSTL_neverThrowsHeadlessExceptionEvenWithShowImportProgressOn () throws IOException {
    Path f = stlFile("stl-headless-test", """
        solid test
        facet normal 0 0 1
          outer loop
            vertex 0 0 0
            vertex 1 0 0
            vertex 1 1 0
          endloop
        endfacet
        endsolid test
        """
    );

    app.showImportProgress = true;

    assertDoesNotThrow(() -> {
      app.import_objects_STL(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });
  }
}
