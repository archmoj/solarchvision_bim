import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// import_objects_DXF() is a plain group-code/value DXF-format text parser
// plus calls to allPoints.create()/allFaces.create()/allGroups.beginNewGroup() -
// no WIN3D.graphics, no PImage, so like ImportObjectsOBJTest.java's own
// import_objects_OBJ() tests, this is directly testable from a bare,
// never-setup()'d instance with no extra seeding.
//
// Each test below writes the smallest DXF group-code/value file that
// exercises one path - see importDxf.pde's own file-header
// comment for exactly which entity types/group codes each path
// corresponds to, and for the documented v1-scope limitation (only
// 3DFACE and polyface-mesh POLYLINE carry solid 3D face geometry;
// everything else - LINE, LWPOLYLINE, CIRCLE, INSERT, ... - is skipped).
class ImportObjectsDXFTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
  }

  private Path dxfFile (String name, String body) throws IOException {
    Path f = Files.createTempFile(name, ".dxf");
    Files.writeString(f, body);
    return f;
  }

  // DXF's own group-code/value lines strictly alternate, one token per
  // line - this just makes a test body easier to read/compose than
  // typing every "\n" by hand. `lines` must already come in matched
  // code/value pairs.
  private String dxfLines (String... lines) {
    StringBuilder sb = new StringBuilder();
    for (String line : lines) sb.append(line).append('\n');
    return sb.toString();
  }

  // ================= 3DFACE ====================================================

  @Test
  void importObjectsDXF_3dFace_withoutAFourthPoint_importsATriangle () throws IOException {
    Path f = dxfFile("dxf-3dface-triangle-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "3DFACE", "8", "0",
        "10", "0", "20", "0", "30", "0",
        "11", "1", "21", "0", "31", "0",
        "12", "1", "22", "1", "32", "0",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(3, app.allPoints.getLength());
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(3, app.allFaces.nodes[0].length, "no 4th point group codes at all - a true 3-point face");
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
  }

  @Test
  void importObjectsDXF_3dFace_fourthPointRepeatingTheThird_isStillReadAsATriangle () throws IOException {
    // The more common real-world convention: writers that always emit
    // all four point group codes repeat the 3rd point's own coordinates
    // for the 4th rather than omitting them - see this file's own
    // header comment on 3DFACE.
    Path f = dxfFile("dxf-3dface-repeated-fourth-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "3DFACE", "8", "0",
        "10", "0", "20", "0", "30", "0",
        "11", "1", "21", "0", "31", "0",
        "12", "1", "22", "1", "32", "0",
        "13", "1", "23", "1", "33", "0",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(3, app.allPoints.getLength());
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(3, app.allFaces.nodes[0].length);
  }

  @Test
  void importObjectsDXF_3dFace_fourDistinctPoints_importsAQuad () throws IOException {
    Path f = dxfFile("dxf-3dface-quad-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "3DFACE", "8", "0",
        "10", "0", "20", "0", "30", "0",
        "11", "1", "21", "0", "31", "0",
        "12", "1", "22", "1", "32", "0",
        "13", "0", "23", "1", "33", "0",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(4, app.allPoints.getLength());
    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2, 3}, app.allFaces.nodes[0]);
  }

  @Test
  void importObjectsDXF_appliesTheOffsetAndScaleToEveryVertex () throws IOException {
    Path f = dxfFile("dxf-transform-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "3DFACE", "8", "0",
        "10", "1", "20", "2", "30", "3",
        "11", "1", "21", "2", "31", "3",
        "12", "1", "22", "2", "32", "3",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, /*cx,cy,cz*/ 10, 20, 30, /*sx,sy,sz*/ 2, 2, 2);

    assertEquals(12f, app.allPoints.getX(0), 0.0001f);
    assertEquals(24f, app.allPoints.getY(0), 0.0001f);
    assertEquals(36f, app.allPoints.getZ(0), 0.0001f);
  }

  // ================= POLYLINE polyface mesh ====================================

  @Test
  void importObjectsDXF_polyfaceMeshPolyline_importsAQuadFaceFromItsOwnVertexRecords () throws IOException {
    // flags 70 = 64: the "polyface mesh" bit - see this file's own header
    // comment. The first four VERTEX records (no 71-74) are the mesh's
    // own shared point list; the 5th (71-74, no x/y/z needed) is a face
    // definition indexing back into that point list, 1-based.
    Path f = dxfFile("dxf-polyface-quad-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "POLYLINE", "8", "0", "70", "64",
        "0", "VERTEX", "8", "0", "10", "0", "20", "0", "30", "0",
        "0", "VERTEX", "8", "0", "10", "1", "20", "0", "30", "0",
        "0", "VERTEX", "8", "0", "10", "1", "20", "1", "30", "0",
        "0", "VERTEX", "8", "0", "10", "0", "20", "1", "30", "0",
        "0", "VERTEX", "8", "0", "71", "1", "72", "2", "73", "3", "74", "4",
        "0", "SEQEND",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(4, app.allPoints.getLength());
    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2, 3}, app.allFaces.nodes[0]);
  }

  @Test
  void importObjectsDXF_polyfaceMeshPolyline_negativeIndexMeansInvisibleEdge_stillUsesTheSamePoint () throws IOException {
    // A negative face-vertex index marks that edge invisible - this
    // importer doesn't track visibility, so it should still resolve to
    // the same point (see this file's own header comment on this).
    Path f = dxfFile("dxf-polyface-negative-index-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "POLYLINE", "8", "0", "70", "64",
        "0", "VERTEX", "8", "0", "10", "0", "20", "0", "30", "0",
        "0", "VERTEX", "8", "0", "10", "1", "20", "0", "30", "0",
        "0", "VERTEX", "8", "0", "10", "1", "20", "1", "30", "0",
        "0", "VERTEX", "8", "0", "71", "1", "72", "-2", "73", "3",
        "0", "SEQEND",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
  }

  @Test
  void importObjectsDXF_plainTwoDPolyline_withoutTheMeshFlag_isSkipped () throws IOException {
    // flags 70 without bit 64 set - an ordinary 2D/3D polyline, not a
    // polyface mesh - its own VERTEX run is still consumed to keep the
    // cursor in sync, but nothing is built from it.
    Path f = dxfFile("dxf-plain-polyline-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "POLYLINE", "8", "0", "70", "0",
        "0", "VERTEX", "8", "0", "10", "0", "20", "0", "30", "0",
        "0", "VERTEX", "8", "0", "10", "1", "20", "0", "30", "0",
        "0", "SEQEND",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length);
  }

  // ================= layer changes: grouping and material cycling ==============

  @Test
  void importObjectsDXF_layerChange_startsANewGroupAndCyclesMaterial () throws IOException {
    Path f = dxfFile("dxf-layer-change-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "3DFACE", "8", "WALLS",
        "10", "0", "20", "0", "30", "0",
        "11", "1", "21", "0", "31", "0",
        "12", "1", "22", "1", "32", "0",
        "0", "3DFACE", "8", "ROOF",
        "10", "0", "20", "0", "30", "1",
        "11", "1", "21", "0", "31", "1",
        "12", "1", "22", "1", "32", "1",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), -1 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allGroups.num, "each distinct layer should start its own group");
    assertEquals(1, app.allFaces.options[0][0], "m == -1 cycles once per layer change, starting at 1");
    assertEquals(2, app.allFaces.options[1][0]);
  }

  @Test
  void importObjectsDXF_sameLayerAcrossEntities_staysInOneGroup () throws IOException {
    Path f = dxfFile("dxf-same-layer-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "3DFACE", "8", "WALLS",
        "10", "0", "20", "0", "30", "0",
        "11", "1", "21", "0", "31", "0",
        "12", "1", "22", "1", "32", "0",
        "0", "3DFACE", "8", "WALLS",
        "10", "0", "20", "0", "30", "1",
        "11", "1", "21", "0", "31", "1",
        "12", "1", "22", "1", "32", "1",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allGroups.num);
  }

  @Test
  void importObjectsDXF_doesNotStartNewGroups_whenAddingToLastGroup () throws IOException {
    app.addToLastGroup = true;
    app.allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0); // the "last group" to add into

    Path f = dxfFile("dxf-addtolastgroup-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "3DFACE", "8", "WALLS",
        "10", "0", "20", "0", "30", "0",
        "11", "1", "21", "0", "31", "0",
        "12", "1", "22", "1", "32", "0",
        "0", "3DFACE", "8", "ROOF",
        "10", "0", "20", "0", "30", "1",
        "11", "1", "21", "0", "31", "1",
        "12", "1", "22", "1", "32", "1",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allGroups.num, "both layer changes should have added to the one pre-existing group, not started new ones");
  }

  // ================= entity/section skipping ===================================

  @Test
  void importObjectsDXF_unsupportedEntityTypes_areSkippedWithoutThrowing () throws IOException {
    Path f = dxfFile("dxf-unsupported-entities-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "LINE", "8", "0", "10", "0", "20", "0", "30", "0", "11", "1", "21", "0", "31", "0",
        "0", "CIRCLE", "8", "0", "10", "0", "20", "0", "30", "0", "40", "5",
        "0", "3DFACE", "8", "0",
        "10", "0", "20", "0", "30", "0",
        "11", "1", "21", "0", "31", "0",
        "12", "1", "22", "1", "32", "0",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    assertDoesNotThrow(() -> {
      app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(1, app.allFaces.nodes.length, "only the 3DFACE should have produced geometry");
  }

  @Test
  void importObjectsDXF_entitiesOutsideTheEntitiesSection_areNotImported () throws IOException {
    // BLOCKS holds unplaced block *definitions* - importing those too
    // would duplicate geometry that INSERT would otherwise place -
    // see this file's own header comment.
    Path f = dxfFile("dxf-blocks-section-test", dxfLines(
        "0", "SECTION", "2", "BLOCKS",
        "0", "3DFACE", "8", "0",
        "10", "0", "20", "0", "30", "0",
        "11", "1", "21", "0", "31", "0",
        "12", "1", "22", "1", "32", "0",
        "0", "ENDSEC",
        "0", "SECTION", "2", "ENTITIES",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length, "the 3DFACE sat in BLOCKS, not ENTITIES, so it should not have been imported");
  }

  // ================= progress window headless-safety ===========================
  // Same guarantee ImportObjectsOBJTest.java's own identical test already
  // makes explicit for import_objects_OBJ() - see that file's own comment.

  @Test
  void importObjectsDXF_neverThrowsHeadlessExceptionEvenWithShowImportProgressOn () throws IOException {
    Path f = dxfFile("dxf-headless-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "3DFACE", "8", "0",
        "10", "0", "20", "0", "30", "0",
        "11", "1", "21", "0", "31", "0",
        "12", "1", "22", "1", "32", "0",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.showImportProgress = true;

    assertDoesNotThrow(() -> {
      app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });
  }
}
