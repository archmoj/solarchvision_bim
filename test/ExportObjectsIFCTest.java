import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// exportIfc() only ever reads allFaces/allPoints (see exportIfc.pde's own
// file-header comment - Polylines/etc. have no IFC-product counterpart to
// round-trip through) and writes plain "#id=TYPE(args);" STEP lines
// directly, the same hand-rolled-text posture exportDxf.pde's own tests
// already take (ExportObjectsDXFTest.java's own header comment) - so,
// like that file, correctness here is checked two ways: plain substring/
// line checks on the raw written text for file-structure assertions, and
// round-tripping straight back through import_objects_IFC() (into a
// SEPARATE app instance, never the one that wrote the file) for geometry/
// metadata assertions.
class ExportObjectsIFCTest {

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
    Path f = Path.of(app.Folder_Export3D, app.ProjectName + ".ifc");
    return Files.readString(f);
  }

  private solarchvision_bim newReader () throws IOException {
    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();
    return reader;
  }

  private solarchvision_bim exportAndReimport () throws IOException {
    app.exportIfc();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".ifc");
    solarchvision_bim reader = newReader();
    reader.import_objects_IFC(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    return reader;
  }

  private boolean pointExistsAt (solarchvision_bim reader, float x, float y, float z) {
    for (int i = 0; i < reader.allPoints.getLength(); i++) {
      if (Math.abs(reader.allPoints.getX(i) - x) < 0.001f
        && Math.abs(reader.allPoints.getY(i) - y) < 0.001f
        && Math.abs(reader.allPoints.getZ(i) - z) < 0.001f) {
        return true;
      }
    }
    return false;
  }

  // ================= file structure ===================================

  @Test
  void exportIfc_withNoGeometryAtAll_writesAValidButEmptySkeleton () throws IOException {
    app.exportIfc();

    String text = readExported();
    assertTrue(text.startsWith("ISO-10303-21;"));
    assertTrue(text.contains("FILE_SCHEMA(('IFC4'));"));
    assertTrue(text.contains("IFCPROJECT("));
    assertTrue(text.contains("IFCSITE("));
    assertTrue(text.contains("IFCBUILDING("));
    assertTrue(text.contains("IFCBUILDINGSTOREY("));
    assertFalse(text.contains("IFCBUILDINGELEMENTPROXY("), "no Faces at all - nothing to write as an element");
    assertFalse(text.contains("IFCRELCONTAINEDINSPATIALSTRUCTURE("), "nothing to contain either");
    assertTrue(text.trim().endsWith("END-ISO-10303-21;"));
  }

  @Test
  void exportIfc_aSingleTriangle_writesExactlyOneBuildingElementProxy () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    app.exportIfc();

    String text = readExported();
    assertEquals(1, text.split("IFCBUILDINGELEMENTPROXY\\(", -1).length - 1, "exactly one element");
    assertEquals(1, text.split("IFCRELCONTAINEDINSPATIALSTRUCTURE\\(", -1).length - 1);
  }

  @Test
  void exportIfc_invisibleFace_isSkippedEntirely () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    int f = app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.options[f][3] = 0; // visibility - see Faces.getVisibility()

    app.exportIfc();

    String text = readExported();
    assertFalse(text.contains("IFCBUILDINGELEMENTPROXY("));
  }

  // ================= flat mesh (no ifcShape) round trip ===============

  @Test
  void exportIfc_aQuadFaceWithNoExtraParams_roundTripsAsAQuad () throws IOException {
    int p0 = app.allPoints.create(0, 0, 3);
    int p1 = app.allPoints.create(10, 0, 3);
    int p2 = app.allPoints.create(10, 10, 3);
    int p3 = app.allPoints.create(0, 10, 3);
    app.allFaces.create(new int[]{ p0, p1, p2, p3 });

    solarchvision_bim reader = exportAndReimport();

    assertEquals(1, reader.allFaces.nodes.length);
    assertEquals(4, reader.allFaces.nodes[0].length, "a flat-mesh IfcIndexedPolygonalFace keeps its own point count - no fan-triangulation needed, unlike exportDxf.pde's own polyface-mesh path");
    assertTrue(pointExistsAt(reader, 0, 0, 3));
    assertTrue(pointExistsAt(reader, 10, 0, 3));
    assertTrue(pointExistsAt(reader, 10, 10, 3));
    assertTrue(pointExistsAt(reader, 0, 10, 3));
  }

  @Test
  void exportIfc_twoFacesWithDifferentExtraParams_becomeTwoSeparateElements () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);

    app.current_ExtraParams = "{\"name\":\"Wall A\"}";
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.current_ExtraParams = "{\"name\":\"Wall B\"}";
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.current_ExtraParams = "";

    app.exportIfc();

    String text = readExported();
    assertEquals(2, text.split("IFCBUILDINGELEMENTPROXY\\(", -1).length - 1, "different extraParams - never merged into one chunk");
    assertTrue(text.contains("'Wall A'"));
    assertTrue(text.contains("'Wall B'"));
  }

  @Test
  void exportIfc_twoFacesWithIdenticalExtraParams_becomeOneElement () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    int p3 = app.allPoints.create(5, 0, 0);
    int p4 = app.allPoints.create(5, 1, 0);
    int p5 = app.allPoints.create(6, 1, 0);

    app.current_ExtraParams = "{\"globalId\":\"shared-guid-1\",\"name\":\"Roof\"}";
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.create(new int[]{ p3, p4, p5 });
    app.current_ExtraParams = "";

    solarchvision_bim reader = exportAndReimport();

    String text = readExported();
    assertEquals(1, text.split("IFCBUILDINGELEMENTPROXY\\(", -1).length - 1, "identical, contiguous, non-empty extraParams - one chunked element");
    assertTrue(text.contains("'shared-guid-1'"));

    assertEquals(2, reader.allFaces.nodes.length, "both of the chunk's own Faces still round-trip back as real geometry - the flat-mesh path carries every Face in the chunk, not just the first");
  }

  // ================= GlobalId/Name/Description/ObjectType round trip ===

  @Test
  void exportIfc_faceWithFullMetadata_roundTripsAllFourFields () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);

    app.current_ExtraParams = "{\"globalId\":\"abc123\",\"name\":\"Door-01\",\"description\":\"Front door\",\"objectType\":\"IfcDoor\"}";
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.current_ExtraParams = "";

    solarchvision_bim reader = exportAndReimport();

    processing.data.JSONObject obj = reader.allFaces.getExtraParamsObject(0);
    assertEquals("abc123", obj.getString("globalId"));
    assertEquals("Door-01", obj.getString("name"));
    assertEquals("Front door", obj.getString("description"));
    assertEquals("IfcDoor", obj.getString("objectType"));
  }

  @Test
  void exportIfc_faceWithNoCapturedGlobalId_getsAFabricatedTwentyTwoCharacterOne () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    solarchvision_bim reader = exportAndReimport();

    processing.data.JSONObject obj = reader.allFaces.getExtraParamsObject(0);
    assertTrue(obj.hasKey("globalId"), "ifcGenerateGlobalId() always fills this in, even with nothing captured on the way in");
    assertEquals(22, obj.getString("globalId").length());
  }

  // ================= true extrusion round trip =========================

  @Test
  void exportIfc_validIfcShape_writesATrueExtrudedAreaSolid_andReconstructsExactWorldGeometry () throws IOException {
    // A clean axis-aligned extrusion: origin (0,0,0), uAxis (2,0,0),
    // vAxis (0,2,0) - orthogonal, equal magnitude - extrusion (0,0,5),
    // exactly perpendicular to normalize(uAxis x vAxis) = (0,0,1). Six
    // faces (2 caps + 4 sides) all share this SAME ifcShape, matching
    // ifcCaptureExtrudedAreaSolidShape()'s own "stamped on every face"
    // behavior on the way in.
    String sharedExtraParams = "{"
      + "\"globalId\":\"extrusion-guid-1\","
      + "\"ifcShape\":{"
      + "\"type\":\"extrudedAreaSolid\","
      + "\"profile\":[[-1,-1],[1,-1],[1,1],[-1,1]],"
      + "\"origin\":[0,0,0],"
      + "\"uAxis\":[2,0,0],"
      + "\"vAxis\":[0,2,0],"
      + "\"extrusion\":[0,0,5]"
      + "}}";

    int q0 = app.allPoints.create(-2, -2, 0);
    int q1 = app.allPoints.create(2, -2, 0);
    int q2 = app.allPoints.create(2, 2, 0);
    int q3 = app.allPoints.create(-2, 2, 0);
    int r0 = app.allPoints.create(-2, -2, 5);
    int r1 = app.allPoints.create(2, -2, 5);
    int r2 = app.allPoints.create(2, 2, 5);
    int r3 = app.allPoints.create(-2, 2, 5);

    app.current_ExtraParams = sharedExtraParams;
    app.allFaces.create(new int[]{ q0, q1, q2, q3 }); // bottom cap
    app.allFaces.create(new int[]{ r3, r2, r1, r0 }); // top cap
    app.allFaces.create(new int[]{ q0, q1, r1, r0 }); // side
    app.allFaces.create(new int[]{ q1, q2, r2, r1 }); // side
    app.allFaces.create(new int[]{ q2, q3, r3, r2 }); // side
    app.allFaces.create(new int[]{ q3, q0, r0, r3 }); // side
    app.current_ExtraParams = "";

    solarchvision_bim reader = exportAndReimport();

    String text = readExported();
    assertTrue(text.contains("IFCEXTRUDEDAREASOLID("), "a valid ifcShape - written as a true parametric solid");
    assertFalse(text.contains("IFCPOLYGONALFACESET("), "the chunk's own raw mesh is redundant once the extrusion is valid - see exportIfc.pde's own header comment, \"TRUE EXTRUSION\"");

    float[][] expectedBottom = {{-2,-2,0},{2,-2,0},{2,2,0},{-2,2,0}};
    for (float[] c : expectedBottom) {
      assertTrue(pointExistsAt(reader, c[0], c[1], c[2]), "bottom corner " + java.util.Arrays.toString(c));
      assertTrue(pointExistsAt(reader, c[0], c[1], c[2] + 5), "top corner " + java.util.Arrays.toString(c));
    }
  }

  @Test
  void exportIfc_ifcShapeWithSkewedNonOrthogonalAxes_fallsBackToFlatMesh () throws IOException {
    // uAxis/vAxis not orthogonal (dot != 0) - an anisotropically-scaled
    // import this exporter must not trust as a true extrusion (exportIfc.
    // pde's own ifcValidateShapeForExport() comment).
    String skewedExtraParams = "{"
      + "\"ifcShape\":{"
      + "\"type\":\"extrudedAreaSolid\","
      + "\"profile\":[[-1,-1],[1,-1],[1,1],[-1,1]],"
      + "\"origin\":[0,0,0],"
      + "\"uAxis\":[2,0,0],"
      + "\"vAxis\":[1,2,0],"
      + "\"extrusion\":[0,0,5]"
      + "}}";

    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    int p3 = app.allPoints.create(0, 1, 0);

    app.current_ExtraParams = skewedExtraParams;
    app.allFaces.create(new int[]{ p0, p1, p2, p3 });
    app.current_ExtraParams = "";

    solarchvision_bim reader = exportAndReimport();

    String text = readExported();
    assertFalse(text.contains("IFCEXTRUDEDAREASOLID("), "invalid ifcShape - must not emit geometrically-wrong parametric IFC");
    assertTrue(text.contains("IFCPOLYGONALFACESET("));

    assertTrue(pointExistsAt(reader, 0, 0, 0));
    assertTrue(pointExistsAt(reader, 1, 0, 0));
    assertTrue(pointExistsAt(reader, 1, 1, 0));
    assertTrue(pointExistsAt(reader, 0, 1, 0));
  }

  // ================= User3D.exporterExtraParams toggle ==================

  @Test
  void exportIfc_exporterExtraParamsOff_suppressesMetadataAndIfcShapeToo () throws IOException {
    String extraParamsWithShape = "{"
      + "\"globalId\":\"should-not-appear\","
      + "\"name\":\"Should Not Appear\","
      + "\"ifcShape\":{"
      + "\"type\":\"extrudedAreaSolid\","
      + "\"profile\":[[-1,-1],[1,-1],[1,1],[-1,1]],"
      + "\"origin\":[0,0,0],\"uAxis\":[2,0,0],\"vAxis\":[0,2,0],\"extrusion\":[0,0,5]"
      + "}}";

    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);

    app.current_ExtraParams = extraParamsWithShape;
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.current_ExtraParams = "";

    app.User3D.exporterExtraParams = false;

    app.exportIfc();

    String text = readExported();
    assertFalse(text.contains("should-not-appear"));
    assertFalse(text.contains("Should Not Appear"));
    assertFalse(text.contains("IFCEXTRUDEDAREASOLID("), "ifcShape must not even be consulted when the toggle is off");
    assertTrue(text.contains("IFCPOLYGONALFACESET("));
  }
}
