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

  // ================= standalone line/arc/curve geometry (dxfImportCurves) ======
  // Mirrors ImportObjectsIFCTest.java's own "standalone line/arc/curve
  // ('annotation') geometry" section - see this file's own header
  // comment and importDxf.pde's own header comment for exactly which
  // group codes/entity types each path below corresponds to.

  @Test
  void importObjectsDXF_curvesOffByDefault_lineLwpolylineCircleArcPolyline_areAllSkipped () throws IOException {
    Path f = dxfFile("dxf-curves-off-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "LINE", "8", "0", "10", "0", "20", "0", "30", "0", "11", "1", "21", "0", "31", "0",
        "0", "LWPOLYLINE", "8", "0", "90", "2", "70", "0", "10", "0", "20", "0", "10", "1", "20", "0",
        "0", "CIRCLE", "8", "0", "10", "0", "20", "0", "30", "0", "40", "5",
        "0", "ARC", "8", "0", "10", "0", "20", "0", "30", "0", "40", "5", "50", "0", "51", "90",
        "0", "POLYLINE", "8", "0", "70", "0",
        "0", "VERTEX", "8", "0", "10", "0", "20", "0", "30", "0",
        "0", "VERTEX", "8", "0", "10", "1", "20", "0", "30", "0",
        "0", "SEQEND",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allPolylines.nodes.length, "dxfImportCurves defaults to false: nothing should land in allPolylines");
  }

  @Test
  void importObjectsDXF_line_withCurvesOn_importsAnOpenTwoPointPolyline () throws IOException {
    app.dxfImportCurves = true;

    Path f = dxfFile("dxf-line-curve-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "LINE", "8", "0", "10", "0", "20", "0", "30", "0", "11", "3", "21", "4", "31", "0",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(2, app.allPolylines.nodes[0].length);
    assertEquals(0, app.allPolylines.getClose(0), "a single straight segment is never a closed loop");

    int p0 = app.allPolylines.nodes[0][0];
    int p1 = app.allPolylines.nodes[0][1];
    assertEquals(0, app.allPoints.getX(p0), 0.0001);
    assertEquals(0, app.allPoints.getY(p0), 0.0001);
    assertEquals(3, app.allPoints.getX(p1), 0.0001);
    assertEquals(4, app.allPoints.getY(p1), 0.0001);
  }

  @Test
  void importObjectsDXF_lwPolyline_open_usesTheSharedElevationForEveryVertexZ () throws IOException {
    app.dxfImportCurves = true;

    Path f = dxfFile("dxf-lwpolyline-open-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "LWPOLYLINE", "8", "0", "90", "3", "70", "0", "38", "2",
        "10", "0", "20", "0",
        "10", "2", "20", "0",
        "10", "2", "20", "2",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(3, app.allPolylines.nodes[0].length);
    assertEquals(0, app.allPolylines.getClose(0));

    for (int n : app.allPolylines.nodes[0]) {
      assertEquals(2, app.allPoints.getZ(n), 0.0001, "the shared group-38 elevation should become every vertex's own Z");
    }
  }

  @Test
  void importObjectsDXF_lwPolyline_closedFlag_isReadAsAClosedLoop () throws IOException {
    app.dxfImportCurves = true;

    Path f = dxfFile("dxf-lwpolyline-closed-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "LWPOLYLINE", "8", "0", "90", "3", "70", "1",
        "10", "0", "20", "0",
        "10", "2", "20", "0",
        "10", "2", "20", "2",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(3, app.allPolylines.nodes[0].length, "flag bit 1 (closed) is metadata, not a repeated 4th vertex");
    assertEquals(1, app.allPolylines.getClose(0));
  }

  @Test
  void importObjectsDXF_plainTwoDPolyline_withCurvesOn_isReadAsAnOpenPolyline () throws IOException {
    // Same body as importObjectsDXF_plainTwoDPolyline_withoutTheMeshFlag_isSkipped()
    // above, just with dxfImportCurves turned on - flags 70 = 0 (bit 64
    // clear) is what tells this apart from a polyface mesh either way.
    app.dxfImportCurves = true;

    Path f = dxfFile("dxf-plain-polyline-curve-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "POLYLINE", "8", "0", "70", "0",
        "0", "VERTEX", "8", "0", "10", "0", "20", "0", "30", "0",
        "0", "VERTEX", "8", "0", "10", "1", "20", "0", "30", "0",
        "0", "VERTEX", "8", "0", "10", "1", "20", "1", "30", "0",
        "0", "SEQEND",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length, "still no solid geometry - a plain polyline is a curve, not a face");
    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(3, app.allPolylines.nodes[0].length);
    assertEquals(0, app.allPolylines.getClose(0));
  }

  @Test
  void importObjectsDXF_polyfaceMeshPolyline_withCurvesOn_isStillReadAsAFaceNotACurve () throws IOException {
    // flags 70 = 64 (the polyface-mesh bit) must keep taking priority
    // over dxfImportCurves - this is the same body as
    // importObjectsDXF_polyfaceMeshPolyline_importsAQuadFaceFromItsOwnVertexRecords()
    // above, just with the toggle on, to pin down that it changes nothing here.
    app.dxfImportCurves = true;

    Path f = dxfFile("dxf-polyface-quad-curves-on-test", dxfLines(
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

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(0, app.allPolylines.nodes.length, "a polyface mesh never becomes a Polyline, with or without dxfImportCurves");
  }

  @Test
  void importObjectsDXF_circle_withCurvesOn_importsAClosedLoopThroughItsRadius () throws IOException {
    app.dxfImportCurves = true;

    Path f = dxfFile("dxf-circle-curve-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "CIRCLE", "8", "0", "10", "0", "20", "0", "30", "0", "40", "5",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(1, app.allPolylines.getClose(0), "a full 360-degree sweep should come back as a closed loop");

    int[] nodes = app.allPolylines.nodes[0];
    boolean foundRadiusPoint = false;
    for (int n : nodes) {
      if ((Math.abs(app.allPoints.getX(n) - 5) < 0.01) && (Math.abs(app.allPoints.getY(n)) < 0.01)) foundRadiusPoint = true;
    }
    assertTrue(foundRadiusPoint, "the circle's own start point, at (radius, 0, centerZ), should be among its vertices");
  }

  @Test
  void importObjectsDXF_arc_withCurvesOn_importsAnOpenQuarterCircle () throws IOException {
    app.dxfImportCurves = true;

    Path f = dxfFile("dxf-arc-curve-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "ARC", "8", "0", "10", "0", "20", "0", "30", "0", "40", "5", "50", "0", "51", "90",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(0, app.allPolylines.getClose(0), "a quarter-circle arc is open, not a closed loop");

    int[] nodes = app.allPolylines.nodes[0];
    int first = nodes[0];
    int last = nodes[nodes.length - 1];
    assertEquals(5, app.allPoints.getX(first), 0.01);
    assertEquals(0, app.allPoints.getY(first), 0.01);
    assertEquals(0, app.allPoints.getX(last), 0.01);
    assertEquals(5, app.allPoints.getY(last), 0.01);
  }

  @Test
  void importObjectsDXF_curveEntities_startNewGroupsOnLayerChangeTheSameWayFacesDo () throws IOException {
    app.dxfImportCurves = true;

    Path f = dxfFile("dxf-curve-layer-change-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "LINE", "8", "WALLS", "10", "0", "20", "0", "30", "0", "11", "1", "21", "0", "31", "0",
        "0", "LINE", "8", "ROOF", "10", "0", "20", "0", "30", "1", "11", "1", "21", "0", "31", "1",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), -1 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allGroups.num, "each distinct layer should start its own group, same as 3DFACE entities do");
    assertEquals(1, app.allPolylines.getMaterial(0), "m == -1 cycles once per layer change, starting at 1");
    assertEquals(2, app.allPolylines.getMaterial(1));
  }

  // ================= Step 4: extraParams captured from the entity's own layer ====

  @Test
  void importObjectsDXF_3dFace_capturesItsOwnLayerAsExtraParams () throws IOException {
    Path f = dxfFile("dxf-3dface-extraparams-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "3DFACE", "8", "Walls",
        "10", "0", "20", "0", "30", "0",
        "11", "1", "21", "0", "31", "0",
        "12", "1", "22", "1", "32", "0",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals("{\"layer\": \"Walls\"}", app.allFaces.getExtraParams(0));
  }

  @Test
  void importObjectsDXF_plainPolyline_capturesItsOwnLayerAsExtraParamsOnEveryVertexCreatedSegment () throws IOException {
    // A plain/2D POLYLINE's own VERTEX/SEQEND run deliberately never
    // re-reads a layer of its own (dxfHandleEntity()'s own comment) - the
    // layer read once at POLYLINE's own start should still apply to the
    // Polyline dxfEmitPolyline() creates at SEQEND.
    app.dxfImportCurves = true;

    Path f = dxfFile("dxf-plain-polyline-extraparams-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "POLYLINE", "8", "Roof", "70", "0",
        "0", "VERTEX", "8", "Roof", "10", "0", "20", "0", "30", "0",
        "0", "VERTEX", "8", "Roof", "10", "1", "20", "0", "30", "0",
        "0", "SEQEND",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals("{\"layer\": \"Roof\"}", app.allPolylines.getExtraParams(0));
  }

  @Test
  void importObjectsDXF_3dFace_capturesItsOwnHandleAsExtraParams () throws IOException {
    Path f = dxfFile("dxf-3dface-handle-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "3DFACE", "5", "2A",
        "10", "0", "20", "0", "30", "0",
        "11", "1", "21", "0", "31", "0",
        "12", "1", "22", "1", "32", "0",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    // No layer group (8) on this entity, but dxfHandleEntity()'s own
    // canStartGeometry block (Step 4) still defaults dxfCurrentLayer to
    // "0" - DXF's own default layer - so "layer" is present here too,
    // same as it always has been; "handle" is simply layered on top of
    // it, same split-into-object-then-check-each-key convention the
    // layerAndHandleBothPresent test below uses, since JSONObject's own
    // toString() doesn't preserve insertion order.
    processing.data.JSONObject obj = app.allFaces.getExtraParamsObject(0);
    assertEquals("0", obj.getString("layer"));
    assertEquals("2A", obj.getString("handle"));
  }

  @Test
  void importObjectsDXF_3dFace_layerAndHandleBothPresent_capturesBothInOneObject () throws IOException {
    Path f = dxfFile("dxf-3dface-layer-and-handle-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "3DFACE", "8", "Walls", "5", "2A",
        "10", "0", "20", "0", "30", "0",
        "11", "1", "21", "0", "31", "0",
        "12", "1", "22", "1", "32", "0",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    processing.data.JSONObject obj = app.allFaces.getExtraParamsObject(0);
    assertEquals("Walls", obj.getString("layer"));
    assertEquals("2A", obj.getString("handle"));
  }

  @Test
  void importObjectsDXF_3dFace_capturesItsOwnXDataStringsGroupedByApplicationName () throws IOException {
    Path f = dxfFile("dxf-3dface-xdata-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "3DFACE",
        "10", "0", "20", "0", "30", "0",
        "11", "1", "21", "0", "31", "0",
        "12", "1", "22", "1", "32", "0",
        "1001", "QCAD", "1000", "roomId=101", "1000", "zone=A",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    processing.data.JSONObject obj = app.allFaces.getExtraParamsObject(0);
    processing.data.JSONArray qcad = obj.getJSONObject("xdata").getJSONArray("QCAD");
    assertEquals(2, qcad.size());
    assertEquals("roomId=101", qcad.getString(0));
    assertEquals("zone=A", qcad.getString(1));
  }

  @Test
  void importObjectsDXF_3dFace_xDataFromTwoDifferentApplications_keepsThemSeparate () throws IOException {
    Path f = dxfFile("dxf-3dface-xdata-two-apps-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "3DFACE",
        "10", "0", "20", "0", "30", "0",
        "11", "1", "21", "0", "31", "0",
        "12", "1", "22", "1", "32", "0",
        "1001", "QCAD", "1000", "roomId=101",
        "1001", "REVIT", "1000", "ElementId=99",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    processing.data.JSONObject xdata = app.allFaces.getExtraParamsObject(0).getJSONObject("xdata");
    assertEquals("roomId=101", xdata.getJSONArray("QCAD").getString(0));
    assertEquals("ElementId=99", xdata.getJSONArray("REVIT").getString(0));
  }

  @Test
  void importObjectsDXF_3dFace_xDataNumericGroupsAreIgnored_onlyStringGroup1000IsRead () throws IOException {
    // 1070 (a 16-bit integer) under the same application - deliberately
    // not read (this step's own "optional, best-effort" scope, see
    // dxfEntityToExtraParams()'s own comment) - only the 1000 string
    // survives into the captured xdata.
    Path f = dxfFile("dxf-3dface-xdata-numeric-ignored-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "3DFACE",
        "10", "0", "20", "0", "30", "0",
        "11", "1", "21", "0", "31", "0",
        "12", "1", "22", "1", "32", "0",
        "1001", "QCAD", "1070", "42", "1000", "roomId=101",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    processing.data.JSONArray qcad = app.allFaces.getExtraParamsObject(0).getJSONObject("xdata").getJSONArray("QCAD");
    assertEquals(1, qcad.size());
    assertEquals("roomId=101", qcad.getString(0));
  }

  @Test
  void importObjectsDXF_3dFace_applicationNameWithNoStringValues_isOmittedEntirely () throws IOException {
    // QCAD's own 1001 block here has no 1000 string under it at all (just
    // a 1070 integer) - the whole "QCAD" key, and "xdata" itself, should
    // be absent entirely, not present as an empty array/object. "layer"
    // still defaults to "0" (Step 4's own canStartGeometry default, see
    // the handle-only test above), so the object isn't empty, but it
    // carries no "xdata" key.
    Path f = dxfFile("dxf-3dface-xdata-empty-app-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "3DFACE",
        "10", "0", "20", "0", "30", "0",
        "11", "1", "21", "0", "31", "0",
        "12", "1", "22", "1", "32", "0",
        "1001", "QCAD", "1070", "42",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    processing.data.JSONObject obj = app.allFaces.getExtraParamsObject(0);
    assertEquals("0", obj.getString("layer"));
    assertFalse(obj.hasKey("xdata"));
  }

  @Test
  void importObjectsDXF_polyfaceMeshVertex_capturesItsOwnHandleSeparateFromItsOwningPolylinesHandle () throws IOException {
    // The owning POLYLINE's own handle ("P1") must NOT leak onto the
    // VERTEX-created face below - each VERTEX's own handle (read fresh
    // from THAT entity's own eCodes/eValues, see dxfEntityToExtraParams()'s
    // own comment) is its own, unlike layer (which persists from the
    // owning POLYLINE, by design).
    Path f = dxfFile("dxf-polyface-vertex-handle-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "POLYLINE", "5", "P1", "70", "64",
        "0", "VERTEX", "10", "0", "20", "0", "30", "0",
        "0", "VERTEX", "10", "1", "20", "0", "30", "0",
        "0", "VERTEX", "10", "1", "20", "1", "30", "0",
        "0", "VERTEX", "10", "0", "20", "1", "30", "0",
        "0", "VERTEX", "5", "F1", "71", "1", "72", "2", "73", "3", "74", "4",
        "0", "SEQEND",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    // Same "0" default layer as the handle-only 3DFACE test above - the
    // owning POLYLINE has no "8" group either, so dxfCurrentLayer still
    // defaults to "0" and persists onto the VERTEX-created face; "F1" is
    // that face-definition VERTEX's own handle, NOT the owning
    // POLYLINE's ("P1" - deliberately never used anywhere here).
    processing.data.JSONObject obj = app.allFaces.getExtraParamsObject(0);
    assertEquals("0", obj.getString("layer"));
    assertEquals("F1", obj.getString("handle"));
  }

  @Test
  void importObjectsDXF_importExtraParamsFalse_suppressesHandleAndXDataCaptureToo () throws IOException {
    app.importExtraParams = false;

    Path f = dxfFile("dxf-extraparams-off-handle-xdata-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "3DFACE", "8", "Walls", "5", "2A",
        "10", "0", "20", "0", "30", "0",
        "11", "1", "21", "0", "31", "0",
        "12", "1", "22", "1", "32", "0",
        "1001", "QCAD", "1000", "roomId=101",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals("", app.allFaces.getExtraParams(0), "unchecking the shared importExtraParams option opts out of handle/XDATA capture too, same as layer");
  }

  @Test
  void importObjectsDXF_importExtraParamsFalse_suppressesCaptureEvenWithARealLayer () throws IOException {
    app.importExtraParams = false;

    Path f = dxfFile("dxf-extraparams-off-test", dxfLines(
        "0", "SECTION", "2", "ENTITIES",
        "0", "3DFACE", "8", "Walls",
        "10", "0", "20", "0", "30", "0",
        "11", "1", "21", "0", "31", "0",
        "12", "1", "22", "1", "32", "0",
        "0", "ENDSEC",
        "0", "EOF"
    ));

    app.import_objects_DXF(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals("", app.allFaces.getExtraParams(0), "unchecking the shared importExtraParams option (fileSelected.pde) opts out of extraParams capture for a simplified import");
  }
}
