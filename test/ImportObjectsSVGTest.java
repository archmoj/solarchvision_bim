import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// import_objects_SVG() is a plain loadXML()-based parser plus calls to
// allPoints.create()/allFaces.create()/allPolylines.add_Polyline()/
// allGroups.beginNewGroup() - no WIN3D.graphics, no PImage, so like
// ImportObjectsGEOJSONTest.java's/ImportObjectsDXFTest.java's own tests,
// this is directly testable from a bare, never-setup()'d instance with
// no extra seeding.
//
// See importSvg.pde's own file-header comment for exactly which
// elements/path-data commands are supported (and which, like elliptical
// arcs, are explicitly out of v1 scope), and for the fill-vs-stroke ->
// Face-vs-Polyline routing/hole/transform/Y-flip rules each test below
// exercises.
class ImportObjectsSVGTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
  }

  private Path svgFile (String name, String body) throws IOException {
    Path f = Files.createTempFile(name, ".svg");
    Files.writeString(f, body);
    return f;
  }

  // ================= filled <path> -> Face =======================

  @Test
  void importObjectsSVG_filledPath_importsAFace () throws IOException {
    // A plain filled square (SVG's own default fill is black/filled,
    // so no explicit "fill" attribute at all is needed here) - closed
    // with "Z". SVG's own Y-down axis means a path going (0,0)->(1,0)->
    // (1,1)->(0,1) is clockwise on screen but becomes counter-clockwise
    // once this importer's own mandatory Y-flip is applied - either way
    // this is just a single flat quad, winding direction isn't asserted.
    Path f = svgFile("svg-filled-path-test",
        "<svg><path d=\"M0,0 L1,0 L1,1 L0,1 Z\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(4, app.allPoints.getLength());
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(4, app.allFaces.nodes[0].length);
    assertEquals(0, app.allPolylines.nodes.length);
  }

  @Test
  void importObjectsSVG_fillNone_importsAPolylineInstead () throws IOException {
    Path f = svgFile("svg-fill-none-test",
        "<svg><path d=\"M0,0 L1,0 L1,1 L0,1 Z\" fill=\"none\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(4, app.allPolylines.nodes[0].length);
    assertEquals(1, app.allPolylines.getClose(0), "closed with its own 'Z' command");
  }

  @Test
  void importObjectsSVG_styleFillNone_isReadTheSameAsTheFillAttribute () throws IOException {
    Path f = svgFile("svg-style-fill-none-test",
        "<svg><path d=\"M0,0 L1,0 L1,1 L0,1 Z\" style=\"stroke:black;fill:none;stroke-width:1\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(1, app.allPolylines.nodes.length);
  }

  @Test
  void importObjectsSVG_lineElement_isAlwaysUnfilledRegardlessOfItsOwnFill () throws IOException {
    // The spec itself gives "fill" no effect on <line> - this file's
    // own header comment.
    Path f = svgFile("svg-line-test",
        "<svg><line x1=\"0\" y1=\"0\" x2=\"1\" y2=\"0\" fill=\"black\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(2, app.allPolylines.nodes[0].length);
    assertEquals(0, app.allPolylines.getClose(0));
  }

  // ================= multi-subpath holes ==========================

  @Test
  void importObjectsSVG_filledPathWithASecondSubpath_treatsItAsAHole () throws IOException {
    // Outer 10x10 square, inner 2x2 square "hole" subpath -
    // PolygonHoles.mergeHolesIntoOuterLoop() bridges them into one ring,
    // the same technique importGeojson.pde's/importCitygml.pde's own
    // hole handling already uses - so this comes in as exactly ONE face
    // with more nodes than either ring alone (outer 4 + hole 4 + 2
    // bridge-duplicate vertices = 10, this file's own header comment).
    Path f = svgFile("svg-hole-test",
        "<svg><path d=\"M0,0 L10,0 L10,10 L0,10 Z M4,4 L6,4 L6,6 L4,6 Z\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertTrue(app.allFaces.nodes[0].length > 4, "a bridged outer+hole ring has more nodes than the outer ring alone");
  }

  @Test
  void importObjectsSVG_unfilledPathWithMultipleSubpaths_importsEachAsItsOwnPolyline () throws IOException {
    Path f = svgFile("svg-multi-subpath-polyline-test",
        "<svg><path d=\"M0,0 L1,0 M2,2 L3,2 L3,3\" fill=\"none\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allPolylines.nodes.length);
    assertEquals(2, app.allPolylines.nodes[0].length);
    assertEquals(3, app.allPolylines.nodes[1].length);
  }

  // ================= Bezier curves ================================

  @Test
  void importObjectsSVG_cubicBezier_isTessellatedIntoMultipleSegments () throws IOException {
    Path f = svgFile("svg-cubic-bezier-test",
        "<svg><path d=\"M0,0 C1,1 2,1 3,0\" fill=\"none\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPolylines.nodes.length);
    assertTrue(app.allPolylines.nodes[0].length > 2, "a curve should be tessellated into more than its 2 endpoints");
  }

  @Test
  void importObjectsSVG_quadraticBezier_isTessellatedIntoMultipleSegments () throws IOException {
    Path f = svgFile("svg-quadratic-bezier-test",
        "<svg><path d=\"M0,0 Q1,1 2,0\" fill=\"none\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPolylines.nodes.length);
    assertTrue(app.allPolylines.nodes[0].length > 2);
  }

  // ================= primitive shapes =============================

  @Test
  void importObjectsSVG_rect_importsAFourPointFace () throws IOException {
    Path f = svgFile("svg-rect-test",
        "<svg><rect x=\"0\" y=\"0\" width=\"2\" height=\"3\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(4, app.allFaces.nodes[0].length);
  }

  @Test
  void importObjectsSVG_circle_isTessellatedIntoAManySidedFace () throws IOException {
    Path f = svgFile("svg-circle-test",
        "<svg><circle cx=\"0\" cy=\"0\" r=\"5\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertTrue(app.allFaces.nodes[0].length > 8, "a tessellated circle has many more than 8 nodes");
  }

  @Test
  void importObjectsSVG_polygon_importsAClosedFace () throws IOException {
    Path f = svgFile("svg-polygon-test",
        "<svg><polygon points=\"0,0 1,0 1,1\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(3, app.allFaces.nodes[0].length);
  }

  @Test
  void importObjectsSVG_polyline_importsAnOpenPolyline () throws IOException {
    Path f = svgFile("svg-polyline-test",
        "<svg><polyline points=\"0,0 1,0 1,1\" fill=\"none\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(3, app.allPolylines.nodes[0].length);
    assertEquals(0, app.allPolylines.getClose(0));
  }

  // ================= <g transform> inheritance ====================

  @Test
  void importObjectsSVG_groupTranslate_isAppliedToChildGeometry () throws IOException {
    Path f = svgFile("svg-group-translate-test",
        "<svg><g transform=\"translate(10,0)\"><path d=\"M0,0 L1,0 L1,1 Z\"/></g></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    int[] nodes = app.allFaces.nodes[0];
    float minX = Float.MAX_VALUE;
    for (int n : nodes) minX = Math.min(minX, app.allPoints.getX(n));
    assertTrue(minX >= 9.9f, "the group's own translate(10,0) should shift every vertex by +10 in X");
  }

  @Test
  void importObjectsSVG_nestedGroupTransforms_composeInOrder () throws IOException {
    // translate(10,0) then, nested inside, scale(2) - SVG's own nesting-
    // equivalence rule (this file's own header comment, "SVG transform-
    // matrix composition"): the inner shape's own local (0,0) should end
    // up at world (10,0), and a local (1,0) should end up at (12,0) -
    // scale applied first (in the child's own local space), then the
    // outer translate.
    Path f = svgFile("svg-nested-transform-test",
        "<svg><g transform=\"translate(10,0)\"><g transform=\"scale(2)\"><path d=\"M0,0 L1,0 L1,1 Z\"/></g></g></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    int[] nodes = app.allFaces.nodes[0];
    float minX = Float.MAX_VALUE, maxX = -Float.MAX_VALUE;
    for (int n : nodes) {
      minX = Math.min(minX, app.allPoints.getX(n));
      maxX = Math.max(maxX, app.allPoints.getX(n));
    }
    assertEquals(10.0f, minX, 0.01f);
    assertEquals(12.0f, maxX, 0.01f);
  }

  // ================= coordinate / transform application ============

  @Test
  void importObjectsSVG_appliesTheMandatoryYFlip () throws IOException {
    // SVG's own Y-down axis vs. this app's own Y-up plane - a local
    // point at (0,1) should land at world Y = -1 (before cy/sy, both
    // left at their identity default here).
    Path f = svgFile("svg-yflip-test",
        "<svg><polyline points=\"0,0 0,1\" fill=\"none\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    int[] nodes = app.allPolylines.nodes[0];
    float maxAbsY = 0;
    for (int n : nodes) maxAbsY = Math.max(maxAbsY, Math.abs(app.allPoints.getY(n)));
    assertEquals(1.0f, maxAbsY, 0.01f);
    boolean sawNegativeY = false;
    for (int n : nodes) if (app.allPoints.getY(n) < -0.5f) sawNegativeY = true;
    assertTrue(sawNegativeY, "local Y=1 should become world Y=-1 after the mandatory Y-flip");
  }

  @Test
  void importObjectsSVG_appliesTheOffsetAndScaleToEveryVertex () throws IOException {
    Path f = svgFile("svg-offset-scale-test",
        "<svg><path d=\"M0,0 L1,0 L1,1 Z\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 100, 200, 5, 2, 2, 2);

    int[] nodes = app.allFaces.nodes[0];
    boolean sawOffsetX = false;
    for (int n : nodes) if (app.allPoints.getX(n) >= 99) sawOffsetX = true;
    assertTrue(sawOffsetX, "cx/sx should be applied to every vertex");
    for (int n : nodes) assertEquals(5.0f, app.allPoints.getZ(n), 0.01f, "Z always comes in flat at cz before any extrusion");
  }

  // ================= material/layer grouping (off by default) ======

  @Test
  void importObjectsSVG_groupByIdOffByDefault_startsNoGroupAtAll () throws IOException {
    // Mirrors ImportObjectsGEOJSONTest.java's own identical-shape test
    // for a blank geojsonGroupProperty: calling import_objects_SVG()
    // directly (bypassing fileSelected.pde's own "if (allGroups.num ==
    // 0) allGroups.beginNewGroup(...)" seed, which only the real UI/
    // console entry points perform) means that with grouping off, no
    // group-start signal fires at all - allGroups.num stays exactly what
    // it was before this call.
    Path f = svgFile("svg-no-grouping-test",
        "<svg><path id=\"a\" d=\"M0,0 L1,0 L1,1 Z\"/><path id=\"b\" d=\"M2,0 L3,0 L3,1 Z\"/></svg>");

    assertFalse(app.svgGroupById, "off by default - this file's own header comment");
    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allFaces.nodes.length);
    assertEquals(0, app.allGroups.num, "with svgGroupById off, differing ids should be ignored entirely - no group-start signal at all");
  }

  @Test
  void importObjectsSVG_groupByIdOn_differingIdsStartNewGroups () throws IOException {
    Path f = svgFile("svg-grouping-test",
        "<svg><path id=\"a\" d=\"M0,0 L1,0 L1,1 Z\"/><path id=\"b\" d=\"M2,0 L3,0 L3,1 Z\"/></svg>");

    app.svgGroupById = true;
    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allFaces.nodes.length);
    assertEquals(2, app.allGroups.num, "two differing ids should each start their own group");
  }

  @Test
  void importObjectsSVG_groupByIdOn_sameIdAcrossShapes_staysInOneGroup () throws IOException {
    Path f = svgFile("svg-grouping-same-id-test",
        "<svg><g id=\"shared\"><path d=\"M0,0 L1,0 L1,1 Z\"/><path d=\"M2,0 L3,0 L3,1 Z\"/></g></svg>");

    app.svgGroupById = true;
    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allFaces.nodes.length);
    assertEquals(1, app.allGroups.num, "both shapes inherit the same ancestor <g>'s own id, so neither should start a new group after the first");
  }

  // ================= elliptical arc (explicitly unsupported) ========

  @Test
  void importObjectsSVG_ellipticalArcCommand_stopsThatSubpathButKeepsWhatWasAlreadyCollected () throws IOException {
    // A/a is explicitly out of v1 scope (this file's own header
    // comment) - the two straight-line segments before it should still
    // come through as an open 3-point polyline, the arc itself simply
    // absent.
    Path f = svgFile("svg-arc-unsupported-test",
        "<svg><path d=\"M0,0 L1,0 L1,1 A5,5 0 0 1 10,10\" fill=\"none\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(3, app.allPolylines.nodes[0].length);
  }

  // ================= <defs> is never walked directly ================

  @Test
  void importObjectsSVG_defsContent_isNeverImportedDirectly () throws IOException {
    Path f = svgFile("svg-defs-test",
        "<svg><defs><path d=\"M0,0 L1,0 L1,1 Z\"/></defs></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(0, app.allPolylines.nodes.length);
  }

  // ================= empty / no-geometry document ===================

  @Test
  void importObjectsSVG_noGeometryElements_importsNothingWithoutThrowing () throws IOException {
    Path f = svgFile("svg-empty-test", "<svg><title>Untitled</title></svg>");

    assertDoesNotThrow(() -> {
      app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(0, app.allPolylines.nodes.length);
  }

  // ================= progress window headless-safety ================
  // Same guarantee ImportObjectsDXFTest.java's own identical test already
  // makes explicit for import_objects_DXF() - see that file's own
  // comment.

  @Test
  void importObjectsSVG_neverThrowsHeadlessExceptionEvenWithShowImportProgressOn () throws IOException {
    Path f = svgFile("svg-headless-test",
        "<svg><path d=\"M0,0 L1,0 L1,1 Z\"/></svg>");

    app.showImportProgress = true;

    assertDoesNotThrow(() -> {
      app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });
  }

  // ================= malformed input ================================

  @Test
  void importObjectsSVG_malformedXml_doesNotThrow () throws IOException {
    Path f = svgFile("svg-malformed-test", "<svg><path d=\"M0,0 L1,0");

    assertDoesNotThrow(() -> {
      app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(0, app.allFaces.nodes.length);
  }

  // ================= Step 4: extraParams captured from "id" =========

  @Test
  void importObjectsSVG_filledPathWithId_capturesItsOwnIdAsExtraParams () throws IOException {
    Path f = svgFile("svg-face-extraparams-test", "<svg><path id=\"panel-1\" d=\"M0,0 L1,0 L1,1 L0,1 Z\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals("{\"id\": \"panel-1\"}", app.allFaces.getExtraParams(0));
  }

  @Test
  void importObjectsSVG_strokeOnlyPathWithId_capturesItsOwnIdAsExtraParams () throws IOException {
    Path f = svgFile("svg-line-extraparams-test", "<svg><path id=\"wire-1\" fill=\"none\" d=\"M0,0 L1,0 L1,1\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals("{\"id\": \"wire-1\"}", app.allPolylines.getExtraParams(0));
  }

  @Test
  void importObjectsSVG_shapeWithNoId_hasNoExtraParams () throws IOException {
    Path f = svgFile("svg-no-id-extraparams-test", "<svg><path d=\"M0,0 L1,0 L1,1 L0,1 Z\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals("", app.allFaces.getExtraParams(0));
  }

  @Test
  void importObjectsSVG_importExtraParamsFalse_suppressesCaptureEvenWithARealId () throws IOException {
    app.importExtraParams = false;

    Path f = svgFile("svg-extraparams-off-test", "<svg><path id=\"panel-1\" d=\"M0,0 L1,0 L1,1 L0,1 Z\"/></svg>");

    app.import_objects_SVG(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals("", app.allFaces.getExtraParams(0), "unchecking the shared importExtraParams option (fileSelected.pde) opts out of extraParams capture for a simplified import");
  }
}
