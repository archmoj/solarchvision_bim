import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// exportPly() only ever reads allFaces/allPolylines/allPoints (see
// exportPly.pde's own file-header comment) and writes plain ASCII PLY
// text directly - like ExportObjectsDXFTest.java's/
// ExportObjectsSTLTest.java's own approach, correctness here is checked
// both by simple substring/line checks on the raw written text and by a
// real round trip straight back through import_objects_PLY() into a
// SEPARATE app instance.
class ExportObjectsPLYTest {

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
    Path f = Path.of(app.Folder_Export3D, app.ProjectName + ".ply");
    return Files.readString(f);
  }

  private solarchvision_bim newReader () throws IOException {
    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();
    return reader;
  }

  @Test
  void exportPly_withNoGeometryAtAll_writesAHeaderWithZeroCounts () throws IOException {
    app.exportPly();

    String text = readExported();
    assertTrue(text.contains("ply"));
    assertTrue(text.contains("format ascii 1.0"));
    assertTrue(text.contains("element vertex 0"));
    assertTrue(text.contains("element face 0"));
    assertTrue(text.contains("element edge 0"));
    assertTrue(text.contains("end_header"));
  }

  @Test
  void exportPly_aQuadFace_roundTripsThroughImportAsOneQuad_notTriangulated () throws IOException {
    // Unlike exportDxf.pde's 4-corner ceiling and exportStl.pde's
    // 3-corner one, PLY's own "face" element carries an arbitrary-
    // length index list directly, so a Face with more than 4 corners
    // still round-trips as ONE Face, not several triangles - this test
    // uses a pentagon specifically to prove that.
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(15, 5, 0);
    int p3 = app.allPoints.create(5, 10, 0);
    int p4 = app.allPoints.create(-5, 5, 0);
    app.allFaces.create(new int[]{ p0, p1, p2, p3, p4 });

    app.exportPly();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".ply");

    solarchvision_bim reader = newReader();
    reader.import_objects_PLY(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, reader.allFaces.nodes.length, "an arbitrary n-gon round-trips as one single Face through PLY, no fan-triangulation needed");
    assertEquals(5, reader.allFaces.nodes[0].length);
  }

  @Test
  void exportPly_sharedVertexBetweenTwoFaces_isWrittenOnlyOnce () throws IOException {
    // This file's own header comment, "builds an actual index remap" -
    // two Faces that genuinely share one allPoints index should be
    // written with exactly 5 distinct vertex lines (4 + 4 corners, 3
    // shared), not 8.
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(10, 10, 0);
    int p3 = app.allPoints.create(0, 10, 0);
    app.allFaces.create(new int[]{ p0, p1, p2, p3 });

    int p4 = app.allPoints.create(20, 10, 0);
    app.allFaces.create(new int[]{ p1, p4, p2 }); // shares p1/p2 with the first Face

    app.exportPly();

    assertTrue(readExported().contains("element vertex 5"), "3 shared corners + 2 new ones = 5 distinct vertices, not 8");
  }

  @Test
  void exportPly_anOpenPolyline_roundTripsAsSeparateTwoPointEdges () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(5, 0, 0);
    int p2 = app.allPoints.create(5, 5, 0);
    app.allPolylines.create(new int[]{ p0, p1, p2 });

    app.exportPly();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".ply");

    solarchvision_bim reader = newReader();
    reader.plyImportCurves = true;
    reader.import_objects_PLY(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, reader.allPolylines.nodes.length, "a 3-point open Polyline becomes 2 separate edges, each its own 2-point Polyline on reimport - see exportPly.pde's own header comment");
    for (int[] nodes : reader.allPolylines.nodes) {
      assertEquals(2, nodes.length);
    }
  }

  @Test
  void exportPly_aClosedPolyline_writesOneExtraClosingEdge () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(5, 0, 0);
    int p2 = app.allPoints.create(5, 5, 0);
    app.allPolylines.create(new int[]{ p0, p1, p2 });
    app.allPolylines.setClose(0, 1);

    app.exportPly();

    assertTrue(readExported().contains("element edge 3"), "3 points, closed: 2 consecutive edges + 1 closing edge back to the first point");
  }

  @Test
  void exportPly_aClosedTwoPointPolyline_writesOnlyOneEdge_noRedundantClosingEdge () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(5, 0, 0);
    app.allPolylines.create(new int[]{ p0, p1 });
    app.allPolylines.setClose(0, 1);

    app.exportPly();

    assertTrue(readExported().contains("element edge 1"), "only one distinct segment exists between 2 points - no redundant reversed duplicate");
  }

  @Test
  void exportPly_withoutCurvesEnabledOnTheReader_edgesAreNotReadBack () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(5, 0, 0);
    app.allPolylines.create(new int[]{ p0, p1 });

    app.exportPly();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".ply");

    solarchvision_bim reader = newReader();
    assertFalse(reader.plyImportCurves, "off by default - importPly.pde's own header comment");
    reader.import_objects_PLY(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, reader.allPolylines.nodes.length);
  }

  @Test
  void exportPly_hiddenFaceAndPolyline_areBothSkipped () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setVisibility(0, 0);

    int p3 = app.allPoints.create(5, 5, 0);
    int p4 = app.allPoints.create(6, 5, 0);
    app.allPolylines.create(new int[]{ p3, p4 });
    app.allPolylines.setVisibility(0, 0);

    app.exportPly();

    String text = readExported();
    assertTrue(text.contains("element vertex 0"), "both the Face's and the Polyline's own points are hidden, so neither is ever referenced");
    assertTrue(text.contains("element face 0"));
    assertTrue(text.contains("element edge 0"));
  }
}
