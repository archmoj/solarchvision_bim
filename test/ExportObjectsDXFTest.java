import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// exportDxf() only ever reads allFaces/allPolylines/allPoints (see
// exportDxf.pde's own file-header comment) and writes plain group-code/
// value text lines directly - unlike the GeoJSON-family exporters, DXF
// has no handy built-in parser to read the written file back with
// (no org.json/processing.data equivalent for DXF), so correctness here
// is checked the same two ways ExportObjectsTOPOJSONTest.java's own
// header comment describes, just with the "read the written file
// directly" half done as plain substring/line checks on the raw text
// instead of a JSON structure walk, and the real test weight carried by
// round-tripping straight back through import_objects_DXF() into a
// SEPARATE app instance.
class ExportObjectsDXFTest {

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
    Path f = Path.of(app.Folder_Export3D, app.ProjectName + ".dxf");
    return Files.readString(f);
  }

  private solarchvision_bim newReader () throws IOException {
    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();
    return reader;
  }

  // ================= file structure ===============================

  @Test
  void exportDxf_withNoGeometryAtAll_writesAnEmptyEntitiesSection () throws IOException {
    app.exportDxf();

    String text = readExported();
    assertTrue(text.contains("$ACADVER"), "a minimal HEADER section is always written - see this file's own header comment");
    assertTrue(text.contains("AC1009"), "R12, the plainest DXF dialect - see exportDxf.pde's own header comment");
    assertTrue(text.contains("ENTITIES"));
    assertFalse(text.contains("3DFACE"), "no Faces at all - nothing to write");
    assertFalse(text.contains("POLYLINE"), "no Polylines at all - nothing to write");
  }

  @Test
  void exportDxf_aTriangle_writesOne3dFaceEntity () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    app.exportDxf();

    String text = readExported();
    assertEquals(1, text.split("3DFACE", -1).length - 1, "exactly one 3DFACE entity");
  }

  // ================= Face -> 3DFACE / polyface mesh round-trip =====

  @Test
  void exportDxf_aTriangleFace_roundTripsThroughImportAsATriangle () throws IOException {
    int p0 = app.allPoints.create(0, 0, 5);
    int p1 = app.allPoints.create(10, 0, 5);
    int p2 = app.allPoints.create(10, 10, 5);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    app.exportDxf();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".dxf");

    solarchvision_bim reader = newReader();
    reader.import_objects_DXF(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, reader.allFaces.nodes.length);
    assertEquals(3, reader.allFaces.nodes[0].length, "no 4th point group codes read back as anything but a true 3-point face - see exportDxf.pde's own header comment on 3DFACE");
    for (int node : reader.allFaces.nodes[0]) {
      assertEquals(5f, reader.allPoints.getZ(node), 0.01f);
    }
  }

  @Test
  void exportDxf_aQuadFace_roundTripsThroughImportAsAQuad () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(10, 10, 0);
    int p3 = app.allPoints.create(0, 10, 0);
    app.allFaces.create(new int[]{ p0, p1, p2, p3 });

    app.exportDxf();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".dxf");

    solarchvision_bim reader = newReader();
    reader.import_objects_DXF(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, reader.allFaces.nodes.length);
    assertEquals(4, reader.allFaces.nodes[0].length);

    float minX = Float.MAX_VALUE, maxX = -Float.MAX_VALUE;
    float minY = Float.MAX_VALUE, maxY = -Float.MAX_VALUE;
    for (int node : reader.allFaces.nodes[0]) {
      minX = Math.min(minX, reader.allPoints.getX(node));
      maxX = Math.max(maxX, reader.allPoints.getX(node));
      minY = Math.min(minY, reader.allPoints.getY(node));
      maxY = Math.max(maxY, reader.allPoints.getY(node));
    }
    assertEquals(0f, minX, 0.5f);
    assertEquals(10f, maxX, 0.5f);
    assertEquals(0f, minY, 0.5f);
    assertEquals(10f, maxY, 0.5f);
  }

  @Test
  void exportDxf_aPentagonFace_fanTriangulatesIntoThreeTrianglesOnReimport () throws IOException {
    // A 5-point Face can't be written as one DXF 3DFACE/polyface-mesh
    // face record (both are capped at 4 corners) - exportDxf.pde's own
    // header comment documents fan-triangulating from the first point,
    // so this should come back as exactly (5-2)=3 separate triangular
    // Faces, not the original single pentagon.
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(15, 5, 0);
    int p3 = app.allPoints.create(5, 10, 0);
    int p4 = app.allPoints.create(-5, 5, 0);
    app.allFaces.create(new int[]{ p0, p1, p2, p3, p4 });

    app.exportDxf();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".dxf");

    solarchvision_bim reader = newReader();
    reader.import_objects_DXF(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(3, reader.allFaces.nodes.length, "fan-triangulated into (n-2) triangles");
    for (int[] nodes : reader.allFaces.nodes) {
      assertEquals(3, nodes.length, "every fan triangle has exactly 3 corners");
    }
  }

  @Test
  void exportDxf_hiddenFace_isSkipped () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setVisibility(0, 0);

    app.exportDxf();

    assertFalse(readExported().contains("3DFACE"), "a hidden Face should never be written");
  }

  // ================= Polyline round-trip ============================
  // importDxf.pde's own importer only actually reads a plain POLYLINE's
  // own VERTEX run while dxfImportCurves is true (gated the same way
  // LINE/LWPOLYLINE/CIRCLE/ARC already are) - every test below sets
  // that on the READER, mirroring ImportObjectsDXFTest.java's own
  // "curves on" tests.

  @Test
  void exportDxf_anOpenPolyline_roundTripsThroughImport () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(5, 0, 0);
    int p2 = app.allPoints.create(5, 5, 0);
    app.allPolylines.create(new int[]{ p0, p1, p2 });

    app.exportDxf();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".dxf");

    solarchvision_bim reader = newReader();
    reader.dxfImportCurves = true;
    reader.import_objects_DXF(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, reader.allPolylines.nodes.length);
    assertEquals(3, reader.allPolylines.nodes[0].length);
    assertEquals(0, reader.allPolylines.getClose(0));
  }

  @Test
  void exportDxf_aClosedPolyline_roundTripsThroughImport () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(5, 0, 0);
    int p2 = app.allPoints.create(5, 5, 0);
    app.allPolylines.create(new int[]{ p0, p1, p2 });
    app.allPolylines.setClose(0, 1);

    app.exportDxf();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".dxf");

    solarchvision_bim reader = newReader();
    reader.dxfImportCurves = true;
    reader.import_objects_DXF(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, reader.allPolylines.nodes.length);
    assertEquals(3, reader.allPolylines.nodes[0].length, "the written closing duplicate (none, in this case - DXF's own plain-polyline closed flag needs no repeated point) leaves the 3 distinct points");
    assertEquals(1, reader.allPolylines.getClose(0));
  }

  @Test
  void exportDxf_withoutCurvesEnabledOnTheReader_polylinesAreNotReadBack () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(5, 0, 0);
    app.allPolylines.create(new int[]{ p0, p1 });

    app.exportDxf();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".dxf");

    solarchvision_bim reader = newReader();
    assertFalse(reader.dxfImportCurves, "off by default - importDxf.pde's own header comment");
    reader.import_objects_DXF(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, reader.allPolylines.nodes.length);
  }

  // ================= material/layer -> composite DXF layer name =====

  @Test
  void exportDxf_differingMaterialAloneStartsANewGroupOnReimport () throws IOException {
    // Same layer, different material - exportDxf.pde's own header
    // comment ("Layer AND material, both folded into one DXF layer
    // name") explains why this needs to be folded into the one
    // composite layer-name string: DXF's own grouping mechanism only
    // ever reacts to a layer-name change, so writing "layer" alone
    // would have silently merged these two Faces into one group.
    app.current_Material = 1;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    app.current_Material = 2;
    int p3 = app.allPoints.create(5, 5, 0);
    int p4 = app.allPoints.create(6, 5, 0);
    int p5 = app.allPoints.create(6, 6, 0);
    app.allFaces.create(new int[]{ p3, p4, p5 });

    app.exportDxf();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".dxf");

    solarchvision_bim reader = newReader();
    reader.import_objects_DXF(exported.toString(), -1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, reader.allFaces.nodes.length);
    assertNotEquals(reader.allFaces.getMaterial(0), reader.allFaces.getMaterial(1), "two different source materials (same layer) should still have started two different groups/material cycles");
  }

  @Test
  void exportDxf_sameMaterialAndLayer_staysInOneGroupOnReimport () throws IOException {
    app.current_Material = 1;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    int p3 = app.allPoints.create(5, 5, 0);
    int p4 = app.allPoints.create(6, 5, 0);
    int p5 = app.allPoints.create(6, 6, 0);
    app.allFaces.create(new int[]{ p3, p4, p5 }); // same current_Material, same default layer

    app.exportDxf();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".dxf");

    solarchvision_bim reader = newReader();
    int groupsBefore = reader.allGroups.num;
    reader.import_objects_DXF(exported.toString(), -1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, reader.allFaces.nodes.length);
    assertEquals(groupsBefore + 1, reader.allGroups.num, "no (material, layer) change between the two Faces - both land in the one group the first layer-name triggers");
  }
}
