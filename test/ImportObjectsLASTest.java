import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

// import_objects_LAS() is a plain binary LAS-format reader plus calls to
// allPoints.create()/allFaces.create()/allGroups.beginNewGroup()/
// meshPointCloud_delaunayXY() - no WIN3D.graphics, no PImage, so like
// ImportObjectsSTLTest.java's own import_objects_STL() tests, this is
// directly testable from a bare, never-setup()'d instance with no extra
// seeding.
//
// Each test below builds the smallest LAS file that exercises one path -
// see importLas.pde's own file-header comment for exactly which header
// fields are read, why only a point record's own first 12 bytes (X/Y/Z)
// are ever read regardless of point data format, and for the documented
// v1-scope limitations (LASzip/.laz compression rejected, not read;
// geometry only, no intensity/classification/color/GPS time).
//
// There is no dedicated test here for the showWaitCursor()/
// showArrowCursor() try/finally fix (import_objects_LAS(), importLas.
// pde): showWaitCursor()/showArrowCursor() (globalFunctions.pde) are
// already no-ops whenever this.surface is null, which it always is for
// a bare, never-setup()'d instance like app below - there is no
// observable cursor state in this test harness to assert on at all, the
// same reason this whole suite runs headless in the first place.
class ImportObjectsLASTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
  }

  private Path lasBinaryFile (String name, byte[] body) throws IOException {
    Path f = Files.createTempFile(name, ".las");
    Files.write(f, body);
    return f;
  }

  private void writeU16LE (ByteArrayOutputStream out, int v) {
    out.write(v & 0xFF);
    out.write((v >> 8) & 0xFF);
  }

  private void writeU32LE (ByteArrayOutputStream out, int v) {
    out.write(v & 0xFF);
    out.write((v >> 8) & 0xFF);
    out.write((v >> 16) & 0xFF);
    out.write((v >> 24) & 0xFF);
  }

  private void writeDoubleLE (ByteArrayOutputStream out, double v) {
    long bits = Double.doubleToLongBits(v);
    for (int i = 0; i < 8; i++) out.write((int) ((bits >> (8 * i)) & 0xFF));
  }

  // Builds a minimal, valid LAS 1.2 Public Header Block (227 bytes - see
  // importLas.pde's own lasParseHeader() for exactly this field layout)
  // followed by one point record per (x, y, z) in points, each a plain
  // 12-byte X/Y/Z (scaled/offset by scale/offsetX/Y/Z, the same formula
  // import_objects_LAS() itself applies on the way back in) padded out to
  // recordLengthBytes with zero bytes after it - mirroring a real point
  // data format 1+ (GPS time, RGB, ...), which import_objects_LAS() is
  // specifically meant to skip over via the header's own declared record
  // length rather than needing to understand (see that file's own header
  // comment on why).
  private byte[] lasFile (double[][] points, int pointDataFormat, int recordLengthBytes, double scale, double offsetX, double offsetY, double offsetZ, boolean compressed) {
    ByteArrayOutputStream out = new ByteArrayOutputStream();

    out.writeBytes("LASF".getBytes(StandardCharsets.US_ASCII));
    writeU16LE(out, 0); // File Source ID
    writeU16LE(out, 0); // Global Encoding
    out.writeBytes(new byte[16]); // Project ID GUID
    out.write(1); out.write(2); // Version 1.2
    out.writeBytes(new byte[32]); // System Identifier
    out.writeBytes(new byte[32]); // Generating Software
    writeU16LE(out, 1); // File Creation Day of Year
    writeU16LE(out, 2024); // File Creation Year
    writeU16LE(out, 227); // Header Size
    writeU32LE(out, 227); // Offset to point data - right after this 227-byte header, no VLRs
    writeU32LE(out, 0); // Number of Variable Length Records
    out.write(compressed ? (pointDataFormat | 0x80) : pointDataFormat); // Point Data Record Format (+ LASzip's own top-bit compression flag - see LasHeader.isCompressed's own comment, importLas.pde)
    writeU16LE(out, recordLengthBytes); // Point Data Record Length
    writeU32LE(out, points.length); // Legacy Number of point records
    out.writeBytes(new byte[20]); // Legacy Number of points by return (5 x u32) - never read by import_objects_LAS()

    writeDoubleLE(out, scale); writeDoubleLE(out, scale); writeDoubleLE(out, scale); // X/Y/Z scale factor
    writeDoubleLE(out, offsetX); writeDoubleLE(out, offsetY); writeDoubleLE(out, offsetZ); // X/Y/Z offset
    writeDoubleLE(out, 0); writeDoubleLE(out, 0); // Max X / Min X - never read by import_objects_LAS()
    writeDoubleLE(out, 0); writeDoubleLE(out, 0); // Max Y / Min Y
    writeDoubleLE(out, 0); writeDoubleLE(out, 0); // Max Z / Min Z

    for (double[] p : points) {
      int rawX = (int) Math.round((p[0] - offsetX) / scale);
      int rawY = (int) Math.round((p[1] - offsetY) / scale);
      int rawZ = (int) Math.round((p[2] - offsetZ) / scale);
      writeU32LE(out, rawX);
      writeU32LE(out, rawY);
      writeU32LE(out, rawZ);
      out.writeBytes(new byte[recordLengthBytes - 12]); // whatever else this record format packs in - never read, see this method's own comment
    }

    return out.toByteArray();
  }

  // The common case - plain point data format 0, the smallest real LAS
  // point record (20 bytes), 0.001 scale, (0, 0, 0) offset.
  private byte[] lasFile (double[][] points) {
    return lasFile(points, 0, 20, 0.001, 0, 0, 0, false);
  }

  // ================= basic reading ======================================================

  @Test
  void importObjectsLAS_importsPointsWithCorrectCoordinates () throws IOException {
    byte[] data = lasFile(new double[][]{ {1, 2, 3}, {4, 5, 6} });
    Path f = lasBinaryFile("las-basic-test", data);

    app.lasImportMeshPointCloud = false; // isolate point-reading from meshing for this test
    app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allPoints.getLength());
    assertEquals(1f, app.allPoints.getX(0), 0.001f);
    assertEquals(2f, app.allPoints.getY(0), 0.001f);
    assertEquals(3f, app.allPoints.getZ(0), 0.001f);
    assertEquals(4f, app.allPoints.getX(1), 0.001f);
    assertEquals(5f, app.allPoints.getY(1), 0.001f);
    assertEquals(6f, app.allPoints.getZ(1), 0.001f);
  }

  @Test
  void importObjectsLAS_appliesTheOffsetAndScaleToEveryVertex () throws IOException {
    byte[] data = lasFile(new double[][]{ {1, 2, 3} });
    Path f = lasBinaryFile("las-transform-test", data);

    app.lasImportMeshPointCloud = false;
    app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, /*cx,cy,cz*/ 10, 20, 30, /*sx,sy,sz*/ 2, 2, 2);

    assertEquals(12f, app.allPoints.getX(0), 0.001f);
    assertEquals(24f, app.allPoints.getY(0), 0.001f);
    assertEquals(36f, app.allPoints.getZ(0), 0.001f);
  }

  @Test
  void importObjectsLAS_ignoresTheHeaderOffset_centeringAroundOrigin () throws IOException {
    // A real-world LAS file's own header.offsetX/Y/Z is typically a
    // large absolute coordinate (a UTM easting/northing, say) -
    // import_objects_LAS() deliberately drops it rather than adding it
    // back in (see importLas.pde's own "Centered by default" header
    // comment), so the imported point lands at just scale * raw (its
    // position relative to that offset), not offset + scale * raw (its
    // absolute real-world one).
    byte[] data = lasFile(new double[][]{ {500123.456, 4512345.789, 123.456} }, 0, 20, 0.001, 500000, 4500000, 0, false);
    Path f = lasBinaryFile("las-centering-test", data);

    app.lasImportMeshPointCloud = false;
    app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPoints.getLength());
    // 500123.456 - 500000 = 123.456; 4512345.789 - 4500000 = 12345.789;
    // 123.456 - 0 = 123.456 (unchanged, since offsetZ here is already 0).
    assertEquals(123.456f, app.allPoints.getX(0), 0.01f);
    assertEquals(12345.789f, app.allPoints.getY(0), 0.01f);
    assertEquals(123.456f, app.allPoints.getZ(0), 0.01f);
  }

  @Test
  void importObjectsLAS_widerPointDataFormat_stillReadsXYZCorrectly () throws IOException {
    // Simulates point data format 3 (34 bytes/record: X/Y/Z + GPS time +
    // RGB, none of which this test bothers to fill in) - import_objects_
    // LAS() only ever reads a record's own first 12 bytes and skips the
    // rest via the header's own declared record length (see lasFile()'s
    // own comment), so this should read identically to a plain 20-byte
    // format-0 file with the same points.
    byte[] data = lasFile(new double[][]{ {1, 2, 3}, {4, 5, 6} }, 3, 34, 0.001, 0, 0, 0, false);
    Path f = lasBinaryFile("las-wide-format-test", data);

    app.lasImportMeshPointCloud = false;
    app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allPoints.getLength());
    assertEquals(1f, app.allPoints.getX(0), 0.001f);
    assertEquals(6f, app.allPoints.getZ(1), 0.001f);
  }

  // ================= meshing ======================================================

  @Test
  void importObjectsLAS_meshesThePointCloudByDefault () throws IOException {
    // The default meshing algorithm is the grid one (meshPointCloud_
    // gridXY(), meshPointCloudGrid.pde) - for these 4 points (the
    // corners of a unit square, each landing in its own grid cell), that
    // produces exactly 1 quad face, not 2 triangles the way the
    // Delaunay algorithm would - see meshPointCloud_gridXY()'s own
    // comment for why a single quad is what it emits.
    byte[] data = lasFile(new double[][]{ {0, 0, 0}, {1, 0, 0}, {0, 1, 0}, {1, 1, 0} });
    Path f = lasBinaryFile("las-mesh-default-test", data);

    app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(4, app.allPoints.getLength());
    assertEquals(1, app.allFaces.nodes.length, "4 coplanar points forming a square should mesh into exactly 1 quad face by default");
    assertEquals(4, app.allFaces.nodes[0].length, "the default grid algorithm emits a single quad (4 vertices), not 2 triangles");
  }

  @Test
  void importObjectsLAS_meshPointCloudFalse_importsPointsOnlyNoFaces () throws IOException {
    byte[] data = lasFile(new double[][]{ {0, 0, 0}, {1, 0, 0}, {0, 1, 0}, {1, 1, 0} });
    Path f = lasBinaryFile("las-no-mesh-test", data);

    app.lasImportMeshPointCloud = false;
    app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(4, app.allPoints.getLength());
    assertEquals(0, app.allFaces.nodes.length);
  }

  // ================= testing option: point-index range ===========================

  @Test
  void importObjectsLAS_maxPointIndexOption_limitsToTheFilesOwnFirstNPoints () throws IOException {
    byte[] data = lasFile(new double[][]{ {0, 0, 0}, {1, 0, 0}, {2, 0, 0}, {3, 0, 0}, {4, 0, 0} });
    Path f = lasBinaryFile("las-max-point-index-test", data);

    app.lasImportMeshPointCloud = false;
    app.lasImportMaxPointIndex = 2; // half-open [0, 2) - the file's own first 2 points, same as before this option's own range/rename
    app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allPoints.getLength());
    assertEquals(0f, app.allPoints.getX(0), 0.001f);
    assertEquals(1f, app.allPoints.getX(1), 0.001f, "should be the file's own FIRST 2 points, in file order");
  }

  @Test
  void importObjectsLAS_minPointIndexOption_skipsThatManyFromTheStart () throws IOException {
    byte[] data = lasFile(new double[][]{ {0, 0, 0}, {1, 0, 0}, {2, 0, 0}, {3, 0, 0}, {4, 0, 0} });
    Path f = lasBinaryFile("las-min-point-index-test", data);

    app.lasImportMeshPointCloud = false;
    app.lasImportMinPointIndex = 3; // inclusive - skips indices 0, 1, 2
    app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allPoints.getLength());
    assertEquals(3f, app.allPoints.getX(0), 0.001f);
    assertEquals(4f, app.allPoints.getX(1), 0.001f);
  }

  @Test
  void importObjectsLAS_minAndMaxPointIndexTogether_readOnlyThatHalfOpenRange () throws IOException {
    byte[] data = lasFile(new double[][]{ {0, 0, 0}, {1, 0, 0}, {2, 0, 0}, {3, 0, 0}, {4, 0, 0} });
    Path f = lasBinaryFile("las-point-index-range-test", data);

    app.lasImportMeshPointCloud = false;
    app.lasImportMinPointIndex = 1;
    app.lasImportMaxPointIndex = 4; // [1, 4) - indices 1, 2, 3; index 4 excluded
    app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(3, app.allPoints.getLength());
    assertEquals(1f, app.allPoints.getX(0), 0.001f);
    assertEquals(2f, app.allPoints.getX(1), 0.001f);
    assertEquals(3f, app.allPoints.getX(2), 0.001f);
  }

  // ================= malformed/unsupported files ============================================

  @Test
  void importObjectsLAS_lasZipCompressed_isRejectedWithoutThrowing () throws IOException {
    byte[] data = lasFile(new double[][]{ {0, 0, 0} }, 0, 20, 0.001, 0, 0, 0, /*compressed*/ true);
    Path f = lasBinaryFile("las-laz-test", data);

    assertDoesNotThrow(() -> {
      app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(0, app.allPoints.getLength(), "a LASzip-compressed file should be rejected outright, not misread as plain point records");
  }

  @Test
  void importObjectsLAS_missingLasfSignature_doesNotThrow () throws IOException {
    byte[] data = lasFile(new double[][]{ {0, 0, 0} });
    data[0] = 'X'; // corrupt the "LASF" signature

    Path f = lasBinaryFile("las-bad-signature-test", data);

    assertDoesNotThrow(() -> {
      app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(0, app.allPoints.getLength());
  }

  @Test
  void importObjectsLAS_emptyFile_doesNotThrow () throws IOException {
    Path f = lasBinaryFile("las-empty-test", new byte[0]);

    assertDoesNotThrow(() -> {
      app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(0, app.allPoints.getLength());
  }

  @Test
  void importObjectsLAS_fileShorterThanItsOwnDeclaredCount_onlyReadsWhatFits () throws IOException {
    byte[] data = lasFile(new double[][]{ {0, 0, 0}, {1, 0, 0} });
    // Overwrite the header's own declared point count (offset 107, u32 LE)
    // to claim 100 points, though only 2 point records actually follow -
    // same "never trust the file's own count past what it genuinely
    // holds" bounds-checking import_objects_LAS() itself documents.
    data[107] = 100; data[108] = 0; data[109] = 0; data[110] = 0;

    Path f = lasBinaryFile("las-truncated-test", data);

    app.lasImportMeshPointCloud = false;
    assertDoesNotThrow(() -> {
      app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(2, app.allPoints.getLength(), "should only read the 2 point records that actually fit in the file");
  }

  @Test
  void importObjectsLAS_recordLengthTooShortForXYZ_doesNotThrow () throws IOException {
    byte[] data = lasFile(new double[][]{ {0, 0, 0} });
    // Overwrite the header's own declared Point Data Record Length
    // (offset 105, u16 LE) to 8 bytes - too short to even hold X/Y/Z.
    data[105] = 8; data[106] = 0;

    Path f = lasBinaryFile("las-short-record-test", data);

    assertDoesNotThrow(() -> {
      app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(0, app.allPoints.getLength());
  }

  // ================= progress window headless-safety ===========================
  // Same guarantee ImportObjectsSTLTest.java's own identical test already
  // makes explicit for import_objects_STL() - see that file's own comment.
  // Covers BOTH of this importer's own progress phases (point-reading and
  // meshing, importLas.pde) in one pass, since this test's own 4-point
  // cloud is enough to exercise meshing too (lasImportMeshPointCloud
  // defaults true).

  @Test
  void importObjectsLAS_neverThrowsHeadlessExceptionEvenWithShowImportProgressOn () throws IOException {
    byte[] data = lasFile(new double[][]{ {0, 0, 0}, {1, 0, 0}, {0, 1, 0}, {1, 1, 0} });
    Path f = lasBinaryFile("las-headless-test", data);

    app.showImportProgress = true;

    assertDoesNotThrow(() -> {
      app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });
  }
}
