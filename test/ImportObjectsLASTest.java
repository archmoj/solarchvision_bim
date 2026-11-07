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

    // lasImportRelocate defaults ON, and every test file below's own
    // header bounding box (never set by lasFile(), see that method's own
    // comment) reads as (0, 0) - which passes lasHeaderLatLonDecimalDegrees()'s
    // own "looks like real degrees" check - so without this, EVERY
    // test below would call all the way through to update_station()
    // (importLas.pde's own call site), a real scene/viewport/terrain
    // update that depends on WORLD/STUDY/WIN3D/Terrain state a bare,
    // never-setup()'d instance like app never initializes at all. Off
    // here, for every test; see importObjectsLAS_lasHeaderLatLonDecimalDegrees_...
    // (below) for direct, safe tests of the actual detection LOGIC,
    // which call that one pure function straight, never through a real
    // import at all, specifically to stay well clear of update_station().
    app.lasImportRelocate = false;
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

  // ================= meshing algorithm selection (lasImportMeshAlgorithm) ===========================

  @Test
  void importObjectsLAS_delaunayAlgorithm_producesTrianglesNotQuads () throws IOException {
    byte[] data = lasFile(new double[][]{ {0, 0, 0}, {1, 0, 0}, {0, 1, 0}, {1, 1, 0} });
    Path f = lasBinaryFile("las-algorithm-delaunay-test", data);

    app.lasImportMeshAlgorithm = app.LAS_MESH_ALGORITHM_DELAUNAY;
    app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(4, app.allPoints.getLength());
    assertTrue(app.allFaces.nodes.length >= 2, "a unit square should triangulate into at least 2 triangles under Delaunay");
    for (int[] face : app.allFaces.nodes) {
      assertEquals(3, face.length, "every Delaunay face should be a triangle, never a quad");
    }
  }

  @Test
  void importObjectsLAS_boxGridAlgorithm_producesOneQuadFacePerCell_fiveFacesForASingleCell () throws IOException {
    // 4 points, each landing in its own distinct cell of the minimum 2x2
    // grid (same reasoning as importObjectsLAS_meshesThePointCloudByDefault's
    // own identical setup) - the box-grid algorithm gives each of those
    // 4 cells its own independent box: 1 flat top + 4 vertical sides
    // (lasCreateBoxGridFaces(), importLas.pde), so 4 cells x 5 faces = 20
    // faces total, every single one a quad (4 vertices) - never a
    // triangle, and never one shared face spanning more than 1 cell the
    // way the default grid algorithm's own quad does. All 4 points share
    // z = 0 here, so every "side wall" is geometrically flat (topZ ==
    // baseZ) rather than a real vertical wall - lasCreateMesh2Face()
    // still creates one anyway (its own degenerate guard only catches 2
    // corners that are the exact same point, not merely coplanar), so
    // the face COUNT this test actually checks is unaffected either way.
    byte[] data = lasFile(new double[][]{ {0, 0, 0}, {1, 0, 0}, {0, 1, 0}, {1, 1, 0} });
    Path f = lasBinaryFile("las-algorithm-boxgrid-test", data);

    app.lasImportMeshAlgorithm = app.LAS_MESH_ALGORITHM_BOX_GRID;
    app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // 4 original points (the main read loop's own) + 20 x 4 = 80 more -
    // lasCreateMesh2Face() always creates 4 brand-new points per face, by
    // design (a box's own corners are synthesized grid-aligned
    // coordinates, never deduplicated against each other or against the
    // original scattered points - see that function's own comment,
    // importLas.pde) - so allPoints is NOT just the 4 original points
    // once box-grid meshing has run.
    assertEquals(84, app.allPoints.getLength(), "4 original + 20 faces x 4 new corner points each");
    assertEquals(20, app.allFaces.nodes.length, "4 cells x (1 top + 4 sides) = 20 faces");
    for (int[] face : app.allFaces.nodes) {
      assertEquals(4, face.length, "every box-grid face (top or side) should be a quad");
    }
  }

  // ================= region of interest (X/Y/Z bounds) ===========================

  @Test
  void importObjectsLAS_minX_excludesPointsBelowIt () throws IOException {
    byte[] data = lasFile(new double[][]{ {0, 0, 0}, {1, 0, 0}, {2, 0, 0}, {3, 0, 0} });
    Path f = lasBinaryFile("las-roi-minx-test", data);

    app.lasImportMeshPointCloud = false;
    app.lasImportMinX = 1.5f;
    app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allPoints.getLength(), "only x=2 and x=3 should pass");
    assertEquals(2f, app.allPoints.getX(0), 0.001f);
    assertEquals(3f, app.allPoints.getX(1), 0.001f);
  }

  @Test
  void importObjectsLAS_maxX_excludesPointsAboveIt () throws IOException {
    byte[] data = lasFile(new double[][]{ {0, 0, 0}, {1, 0, 0}, {2, 0, 0}, {3, 0, 0} });
    Path f = lasBinaryFile("las-roi-maxx-test", data);

    app.lasImportMeshPointCloud = false;
    app.lasImportMaxX = 1.5f;
    app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allPoints.getLength(), "only x=0 and x=1 should pass");
    assertEquals(0f, app.allPoints.getX(0), 0.001f);
    assertEquals(1f, app.allPoints.getX(1), 0.001f);
  }

  @Test
  void importObjectsLAS_minYAndMaxY_keepOnlyThatBand () throws IOException {
    byte[] data = lasFile(new double[][]{ {0, 0, 0}, {0, 1, 0}, {0, 2, 0}, {0, 3, 0}, {0, 4, 0} });
    Path f = lasBinaryFile("las-roi-y-band-test", data);

    app.lasImportMeshPointCloud = false;
    app.lasImportMinY = 1.5f;
    app.lasImportMaxY = 3.5f;
    app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allPoints.getLength(), "only y=2 and y=3 should fall in [1.5, 3.5]");
    assertEquals(2f, app.allPoints.getY(0), 0.001f);
    assertEquals(3f, app.allPoints.getY(1), 0.001f);
  }

  @Test
  void importObjectsLAS_minZAndMaxZ_keepOnlyThatBand () throws IOException {
    byte[] data = lasFile(new double[][]{ {0, 0, 0}, {0, 0, 10}, {0, 0, 20}, {0, 0, 30} });
    Path f = lasBinaryFile("las-roi-z-band-test", data);

    app.lasImportMeshPointCloud = false;
    app.lasImportMinZ = 5f;
    app.lasImportMaxZ = 25f;
    app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allPoints.getLength());
    assertEquals(10f, app.allPoints.getZ(0), 0.001f);
    assertEquals(20f, app.allPoints.getZ(1), 0.001f);
  }

  @Test
  void importObjectsLAS_allSixBoundsTogether_onlyPointsInsideTheWholeBox () throws IOException {
    byte[] data = lasFile(new double[][]{
      {5, 5, 5},   // inside every bound - should survive
      {0, 5, 5},   // x too low
      {5, 0, 5},   // y too low
      {5, 5, 0},   // z too low
      {5, 5, 5}    // a second point inside every bound - should also survive
    });
    Path f = lasBinaryFile("las-roi-all-six-test", data);

    app.lasImportMeshPointCloud = false;
    app.lasImportMinX = 1f; app.lasImportMaxX = 9f;
    app.lasImportMinY = 1f; app.lasImportMaxY = 9f;
    app.lasImportMinZ = 1f; app.lasImportMaxZ = 9f;
    app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allPoints.getLength(), "only the 2 points with every one of x/y/z inside [1, 9] should survive");
    for (int i = 0; i < app.allPoints.getLength(); i++) {
      assertEquals(5f, app.allPoints.getX(i), 0.001f);
      assertEquals(5f, app.allPoints.getY(i), 0.001f);
      assertEquals(5f, app.allPoints.getZ(i), 0.001f);
    }
  }

  @Test
  void importObjectsLAS_regionOfInterestExcludesEveryPoint_doesNotThrow () throws IOException {
    byte[] data = lasFile(new double[][]{ {0, 0, 0}, {1, 1, 1} });
    Path f = lasBinaryFile("las-roi-excludes-all-test", data);

    app.lasImportMinX = 1000f; // nothing in this file is anywhere close
    assertDoesNotThrow(() -> {
      app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(0, app.allPoints.getLength());
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

  // ================= lasHeaderLatLonDecimalDegrees() ===========================
  // Tested directly, with a hand-built LasHeader, NEVER through a real
  // import_objects_LAS() call - see setUp()'s own comment for why going
  // through a full import (lasImportRelocate = true) would call all the
  // way through to update_station(), which isn't safe to run against a
  // bare, never-setup()'d instance like app at all. Calling the pure
  // detection function directly sidesteps that entirely while still
  // covering the actual logic these tests care about.

  // LasHeader (importLas.pde) is a non-static inner class of solarchvision_bim
  // (unlike MeshPointCloudProgressListener, an interface - implicitly
  // static regardless of where it's declared, so that one needs no
  // qualification at all) - every bare reference to its own TYPE from
  // out here has to be written solarchvision_bim.LasHeader; only the
  // "new LasHeader()" after app.new itself stays a plain, unqualified
  // name, since a qualified class instance creation expression's own
  // class name is always resolved relative to the instance before the
  // ".new" (app, here), per Java's own qualified-new syntax rules.
  private solarchvision_bim.LasHeader headerWithBounds (double minX, double maxX, double minY, double maxY) {
    solarchvision_bim.LasHeader h = app.new LasHeader();
    h.minX = minX;
    h.maxX = maxX;
    h.minY = minY;
    h.maxY = maxY;
    return h;
  }

  @Test
  void lasHeaderLatLonDecimalDegrees_plainGeographicDegrees_returnsTheBoundingBoxCenter () {
    // A file whose own X/Y already happen to be plain longitude/latitude -
    // center is (10, 20) longitude/(30, 40) latitude -> (15, 35).
    solarchvision_bim.LasHeader header = headerWithBounds(10, 20, 30, 40);

    float[] latLon = app.lasHeaderLatLonDecimalDegrees(header);

    assertNotNull(latLon);
    assertEquals(35f, latLon[0], 0.001f, "latitude should be the Y center");
    assertEquals(15f, latLon[1], 0.001f, "longitude should be the X center");
  }

  @Test
  void lasHeaderLatLonDecimalDegrees_projectedUtmStyleCoordinates_returnsNull () {
    // A realistic UTM easting/northing bounding box (meters, hundreds of
    // thousands to millions) - this importer has no map-projection
    // engine, so this must correctly report "no usable location" rather
    // than misreading a projected coordinate as if it were degrees.
    solarchvision_bim.LasHeader header = headerWithBounds(500000, 500500, 4500000, 4500500);

    assertNull(app.lasHeaderLatLonDecimalDegrees(header));
  }

  @Test
  void lasHeaderLatLonDecimalDegrees_onlyLongitudeOutOfRange_returnsNull () {
    solarchvision_bim.LasHeader header = headerWithBounds(170, 200, 10, 20); // X center = 185, past the +-180 range; Y center = 15, well within +-90
    assertNull(app.lasHeaderLatLonDecimalDegrees(header));
  }

  @Test
  void importObjectsLAS_relocateOff_neverSetsGotoLatLon () throws IOException {
    // The toggle itself, confirmed through a real import - safe here
    // specifically because setUp() already leaves lasImportRelocate
    // false, so this never reaches update_station() at all; it's
    // checking that staying off is really a no-op, not that turning it
    // on works (the 3 tests above already cover the real logic that
    // would run if it were on).
    byte[] data = lasFile(new double[][]{ {0, 0, 0} });
    Path f = lasBinaryFile("las-relocate-off-test", data);

    app.import_objects_LAS(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertNull(app.lasImportGotoLatLon);
  }
}
