import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// exportStl() only ever reads allFaces/allPoints (see exportStl.pde's
// own file-header comment) and writes plain ASCII STL text directly -
// like ExportObjectsDXFTest.java's own approach, there's no handy
// built-in parser to read an STL file back with structurally, so
// correctness here is checked both by simple substring/line checks on
// the raw written text and by a real round trip straight back through
// import_objects_STL() into a SEPARATE app instance.
class ExportObjectsSTLTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath();
    app.reset_project_folder_to_default();
    app.update_project_folders();
  }

  private String readExported () throws IOException {
    Path f = Path.of(app.Folder_Export3D, app.ProjectName + ".stl");
    return Files.readString(f);
  }

  private solarchvision_bim newReader () throws IOException {
    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();
    return reader;
  }

  @Test
  void exportStl_withNoGeometryAtAll_writesAnEmptySolidBlock () throws IOException {
    app.exportStl();

    String text = readExported();
    assertTrue(text.contains("solid " + app.ProjectName));
    assertTrue(text.contains("endsolid " + app.ProjectName));
    assertFalse(text.contains("facet"), "no Faces at all - nothing to write");
  }

  @Test
  void exportStl_aTriangleFace_roundTripsThroughImportAsATriangle () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(10, 10, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    app.exportStl();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".stl");

    solarchvision_bim reader = newReader();
    reader.import_objects_STL(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, reader.allFaces.nodes.length);
    assertEquals(3, reader.allFaces.nodes[0].length);
  }

  @Test
  void exportStl_aQuadFace_fanTriangulatesIntoTwoTrianglesOnReimport () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(10, 10, 0);
    int p3 = app.allPoints.create(0, 10, 0);
    app.allFaces.create(new int[]{ p0, p1, p2, p3 });

    app.exportStl();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".stl");

    solarchvision_bim reader = newReader();
    reader.import_objects_STL(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, reader.allFaces.nodes.length, "a quad has no direct STL equivalent - fan-triangulated into (4-2)=2 triangles");
    for (int[] nodes : reader.allFaces.nodes) {
      assertEquals(3, nodes.length);
    }
  }

  @Test
  void exportStl_aPentagonFace_fanTriangulatesIntoThreeTrianglesOnReimport () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(15, 5, 0);
    int p3 = app.allPoints.create(5, 10, 0);
    int p4 = app.allPoints.create(-5, 5, 0);
    app.allFaces.create(new int[]{ p0, p1, p2, p3, p4 });

    app.exportStl();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".stl");

    solarchvision_bim reader = newReader();
    reader.import_objects_STL(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(3, reader.allFaces.nodes.length);
  }

  @Test
  void exportStl_hiddenFace_isSkipped () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setVisibility(0, 0);

    app.exportStl();

    assertFalse(readExported().contains("facet"), "a hidden Face should never be written");
  }

  @Test
  void exportStl_polylinesAreNeverWritten_stlHasNoLineElement () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    app.allPolylines.create(new int[]{ p0, p1 });

    app.exportStl();

    String text = readExported();
    assertTrue(text.contains("solid " + app.ProjectName));
    assertFalse(text.contains("facet"), "STL has no line/curve element at all - see exportStl.pde's own header comment");
  }

  @Test
  void exportStl_writesANonDegenerateUnitNormalPerFacet () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    app.exportStl();

    String text = readExported();
    String[] lines = text.split("\n");
    String normalLine = null;
    for (String line : lines) {
      if (line.trim().startsWith("facet normal")) { normalLine = line.trim(); break; }
    }
    assertNotNull(normalLine);
    String[] parts = normalLine.split("\\s+");
    float nx = Float.parseFloat(parts[2]);
    float ny = Float.parseFloat(parts[3]);
    float nz = Float.parseFloat(parts[4]);
    float len = (float) Math.sqrt(nx * nx + ny * ny + nz * nz);
    assertEquals(1.0f, len, 0.01f, "a real, non-degenerate triangle should get a unit normal, not a placeholder 0 0 0");
  }
}
