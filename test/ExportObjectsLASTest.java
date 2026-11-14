import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.file.Files;
import java.nio.file.Path;

// exportLas(suffix) only ever reads allPoints (see exportLas.pde's own
// file-header comment on scope) and writes plain bytes via saveBytes() -
// no WIN3D.graphics, no PImage, no TypeWindow.OBJ3D-style draw() pass
// across the rest of the scene the way exportObj() needs (see
// ExportObjectsOBJTest.java's own comment on that) - so this is directly
// callable from a bare instance with just the same Folder_Export3D setup
// that file's own setUp() already needs, no Terrain.Mesh seeding. allPoints'
// own index 0 is exported like any other point - see exportLas.pde's own
// "Scope" comment.
//
// Test-side byte reading uses plain java.nio.ByteBuffer (LITTLE_ENDIAN)
// rather than hand-rolled readers, unlike this app's own production code
// (which avoids that kind of standard-library convenience throughout,
// e.g. importLas.pde's own binReadU32LE()) - that avoidance is about
// keeping the shipped app's own dependency-free parsing honest, not
// about test code, which has no such constraint.
class ExportObjectsLASTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
    app.reset_project_folder_to_default(); // Folder_Project is null until this runs - update_project_folders() itself no longer sets it (updateFolders.pde's own fix)
    app.update_project_folders(); // Folder_Export3D is null until this runs - see ExportObjectsOBJTest.java's own identical comment
  }

  private ByteBuffer readLE (Path f) throws IOException {
    return ByteBuffer.wrap(Files.readAllBytes(f)).order(ByteOrder.LITTLE_ENDIAN);
  }

  @Test
  void exportLas_createsARealLasFileAtTheExpectedPath () throws IOException {
    app.allPoints.create(1, 2, 3);

    app.exportLas("_test");

    Path expected = Path.of(app.Folder_Export3D, app.ProjectName + "_test.las");
    assertTrue(Files.exists(expected), "expected " + expected + " to exist");

    byte[] signature = new byte[4];
    readLE(expected).get(signature);
    assertEquals("LASF", new String(signature, java.nio.charset.StandardCharsets.US_ASCII));
  }

  @Test
  void exportLas_writesTheCorrectHeaderFields () throws IOException {
    app.allPoints.create(0, 0, 0);
    app.allPoints.create(1, 1, 1);
    app.allPoints.create(2, 2, 2);

    app.exportLas("_header");

    ByteBuffer b = readLE(Path.of(app.Folder_Export3D, app.ProjectName + "_header.las"));

    assertEquals(1, b.get(24), "Version Major");
    assertEquals(2, b.get(25), "Version Minor");
    assertEquals(227, b.getShort(94) & 0xFFFF, "Header Size");
    assertEquals(227, b.getInt(96), "Offset to point data - no VLRs are ever written");
    assertEquals(0, b.get(104), "Point Data Record Format 0");
    assertEquals(20, b.getShort(105) & 0xFFFF, "Point Data Record Length - format 0's own fixed 20 bytes");
    assertEquals(3, b.getInt(107), "Legacy Number of point records");
    assertEquals(227 + 3 * 20, Files.size(Path.of(app.Folder_Export3D, app.ProjectName + "_header.las")), "file size should be exactly header + 3 point records, nothing more");
  }

  @Test
  void exportLas_withNoPoints_stillWritesAValidEmptyFile () throws IOException {
    app.exportLas("_empty");

    Path expected = Path.of(app.Folder_Export3D, app.ProjectName + "_empty.las");
    assertEquals(227, Files.size(expected), "just the header, no point records - see exportLas.pde's own comment on why this isn't special-cased into writing nothing at all");

    ByteBuffer b = readLE(expected);
    assertEquals(0, b.getInt(107), "Legacy Number of point records");
  }

  @Test
  void exportLas_roundTripsCoordinatesThroughImport () throws IOException {
    // The real end-to-end check: feed exportLas()'s own output straight
    // into import_objects_LAS() (a SEPARATE app instance, so this can't
    // pass by accident just because allPoints already happens to hold the
    // right values from before the export) and confirm every coordinate
    // survives - within 0.001's own default scale (exportLas.pde's own
    // "Scale/offset" comment), never exact float equality, since LAS
    // itself only ever stores a scaled integer.
    //
    // import_objects_LAS() now deliberately centers around the header's
    // own offset rather than reapplying it (see importLas.pde's own
    // "Centered by default" header comment), and exportLas() writes that
    // offset as this project's own bounding-box minimum (exportLas.pde's
    // own "Scale/offset" comment) - so what comes back out isn't the
    // original coordinate, it's that coordinate relative to the
    // exported set's own minimum on each axis. minX/minY/minZ below are
    // exactly exportLas()'s own offsetX/Y/Z for these 3 points.
    app.allPoints.create(1.5f, -2.25f, 100.125f);
    app.allPoints.create(0, 0, 0);
    app.allPoints.create(-10, 20, -30);

    app.exportLas("_roundtrip");
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + "_roundtrip.las");

    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();
    reader.lasImportMeshPointCloud = false; // isolate point-reading for this test
    reader.lasImportRelocate = false; // same reasoning as app.lasImportRelocate in setUp() - avoid update_station() in a bare, never-setup()'d instance

    reader.import_objects_LAS(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    float minX = -10, minY = -2.25f, minZ = -30; // the 3 points' own bounding-box minimum on each axis - see this test's own comment above

    assertEquals(3, reader.allPoints.getLength());
    assertEquals(1.5f - minX, reader.allPoints.getX(0), 0.001f);
    assertEquals(-2.25f - minY, reader.allPoints.getY(0), 0.001f);
    assertEquals(100.125f - minZ, reader.allPoints.getZ(0), 0.001f);
    assertEquals(0f - minX, reader.allPoints.getX(1), 0.001f);
    assertEquals(-10f - minX, reader.allPoints.getX(2), 0.001f);
    assertEquals(20f - minY, reader.allPoints.getY(2), 0.001f);
    assertEquals(-30f - minZ, reader.allPoints.getZ(2), 0.001f);
  }

  @Test
  void exportLas_exportATriangle_thenImportIt_roundTripsItsVertices () throws IOException {
    // Real face geometry (not just loose points) exported to LAS and
    // read back. LAS itself has no face/topology concept at all (see
    // exportLas.pde's own "Scope" comment) - only geometry, point by
    // point - so only the triangle's own 3 vertex POSITIONS are expected
    // to survive the round trip, not a reconstructed face connecting
    // them (import_objects_LAS() would only rebuild a face at all if
    // lasImportMeshPointCloud triangulated these 3 points back into one,
    // which this test deliberately turns off to isolate point-reading,
    // the same way the round-trip test just above does).
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(0, 10, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    app.exportLas("_triangle");
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + "_triangle.las");

    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();
    reader.lasImportMeshPointCloud = false;
    reader.lasImportRelocate = false; // same reasoning as app.lasImportRelocate in setUp() - avoid update_station() in a bare, never-setup()'d instance

    reader.import_objects_LAS(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(3, reader.allPoints.getLength());
    assertEquals(0f, reader.allPoints.getX(0), 0.001f);
    assertEquals(0f, reader.allPoints.getY(0), 0.001f);
    assertEquals(10f, reader.allPoints.getX(1), 0.001f);
    assertEquals(0f, reader.allPoints.getY(1), 0.001f);
    assertEquals(0f, reader.allPoints.getX(2), 0.001f);
    assertEquals(10f, reader.allPoints.getY(2), 0.001f);
  }

  @Test
  void exportLas_veryLargeBoundingBox_coarsensScaleRatherThanOverflowing () throws IOException {
    // A span far beyond what 0.001 scale could keep inside signed 32-bit
    // range (see exportLasComputeScale(), exportLas.pde) - the written
    // scale should have been automatically coarsened well past the plain
    // 0.001 default, and the round trip should still land within THAT
    // coarser scale's own tolerance rather than silently wrapping/
    // corrupting via integer overflow.
    app.allPoints.create(0, 0, 0);
    app.allPoints.create(50_000_000f, 0, 0);

    app.exportLas("_huge");
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + "_huge.las");

    ByteBuffer b = readLE(exported);
    double writtenScale = b.getDouble(131);
    assertTrue(writtenScale > 0.001, "scale should have been coarsened for a 50,000,000-unit span, was " + writtenScale);

    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();
    reader.lasImportMeshPointCloud = false;
    reader.lasImportRelocate = false; // same reasoning as app.lasImportRelocate in setUp() - avoid update_station() in a bare, never-setup()'d instance

    reader.import_objects_LAS(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, reader.allPoints.getLength());
    assertEquals(50_000_000f, reader.allPoints.getX(1), (float) writtenScale);
  }
}
