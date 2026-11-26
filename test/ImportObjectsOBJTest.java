import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// import_objects_OBJ() is a plain OBJ-format text parser plus calls to
// allPoints.create()/allFaces.create()/allGroups.beginNewGroup() - no
// WIN3D.graphics, no PImage, so unlike most of this app it's directly
// testable from a bare, never-setup()'d instance with no extra seeding.
// fileSelected.pde's _fileSelected_ImportObj(File) (see
// FileSelectedTest.java) is the thin wrapper that's actually reachable from
// the UI; this file tests the parser itself, with scenarios that wrapper's
// own tests don't need (multiple groups, material cycling, relative vertex
// indexing, ignored OBJ directives) and one it can't reach at all (the
// tes/lyr/vsb/wgt/clz bug below, since that wrapper always passes concrete,
// non--1 values there).
class ImportObjectsOBJTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
  }

  // ================= vertex transform (cx, cy, cz, sx, sy, sz) ===============

  @Test
  void importObjectsOBJ_appliesTheOffsetAndScaleToEveryVertex () throws IOException {
    Path objFile = Files.createTempFile("import-transform-test", ".obj");
    Files.writeString(objFile, "g g1\nv 1 2 3\n");

    app.import_objects_OBJ(objFile.toString(), 0, 0, 0, 0, 0, 0, /*cx,cy,cz*/ 10, 20, 30, /*sx,sy,sz*/ 2, 2, 2);

    // (cx + sx*x, cy + sy*y, cz + sz*z) = (10 + 2*1, 20 + 2*2, 30 + 2*3)
    assertEquals(12f, app.allPoints.getX(0), 0.0001f);
    assertEquals(24f, app.allPoints.getY(0), 0.0001f);
    assertEquals(36f, app.allPoints.getZ(0), 0.0001f);
  }

  // ================= "f" face lines: vertex indexing ==========================

  @Test
  void importObjectsOBJ_resolvesPositiveOneBasedFaceIndices () throws IOException {
    Path objFile = Files.createTempFile("import-positive-index-test", ".obj");
    Files.writeString(objFile, "g g1\nv 0 0 0\nv 1 0 0\nv 1 1 0\nf 1 2 3\n");

    app.import_objects_OBJ(objFile.toString(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);

    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
  }

  @Test
  void importObjectsOBJ_resolvesNegativeRelativeFaceIndices () throws IOException {
    // OBJ's relative indexing counts backward from the last vertex that
    // exists AT THE POINT THE FACE LINE IS READ: -1 is the most recently
    // created vertex, -2 the one before it, and so on.
    Path objFile = Files.createTempFile("import-negative-index-test", ".obj");
    Files.writeString(objFile, "g g1\nv 0 0 0\nv 1 0 0\nv 2 0 0\nf -3 -2 -1\n");

    app.import_objects_OBJ(objFile.toString(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);

    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
  }

  @Test
  void importObjectsOBJ_handlesFacesWithMoreThanThreeVertices () throws IOException {
    Path objFile = Files.createTempFile("import-quad-test", ".obj");
    Files.writeString(objFile, "g g1\nv 0 0 0\nv 1 0 0\nv 1 1 0\nv 0 1 0\nf 1 2 3 4\n");

    app.import_objects_OBJ(objFile.toString(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);

    assertArrayEquals(new int[]{0, 1, 2, 3}, app.allFaces.nodes[0]);
  }

  // ================= "g" lines: groups ========================================

  @Test
  void importObjectsOBJ_oneGroupPerGLine_whenNotAddingToLastGroup () throws IOException {
    Path objFile = Files.createTempFile("import-groups-test", ".obj");
    Files.writeString(objFile, """
        g first
        v 0 0 0
        v 1 0 0
        v 1 1 0
        f 1 2 3
        g second
        v 0 0 1
        v 1 0 1
        v 1 1 1
        f 4 5 6
        """
    );

    app.import_objects_OBJ(objFile.toString(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allGroups.num);
  }

  @Test
  void importObjectsOBJ_doesNotStartNewGroups_whenAddingToLastGroup () throws IOException {
    app.addToLastGroup = true;
    app.allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0); // the "last group" to add into

    Path objFile = Files.createTempFile("import-addtolastgroup-test", ".obj");
    Files.writeString(objFile, "g first\nv 0 0 0\nv 1 0 0\nv 1 1 0\nf 1 2 3\ng second\nv 0 0 1\nv 1 0 1\nv 1 1 1\nf 4 5 6\n");

    app.import_objects_OBJ(objFile.toString(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allGroups.num, "both \"g\" lines should have added to the one pre-existing group, not started new ones");
  }

  // ================= material (m) ==============================================

  @Test
  void importObjectsOBJ_withAnExplicitMaterial_usesItForEveryFace () throws IOException {
    Path objFile = Files.createTempFile("import-material-test", ".obj");
    Files.writeString(objFile, "g first\nv 0 0 0\nv 1 0 0\nv 1 1 0\nf 1 2 3\ng second\nv 0 0 1\nv 1 0 1\nv 1 1 1\nf 4 5 6\n");

    app.import_objects_OBJ(objFile.toString(), 5 /*m*/, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(5, app.allFaces.options[0][0]);
    assertEquals(5, app.allFaces.options[1][0]);
  }

  @Test
  void importObjectsOBJ_withMinusOneMaterial_cyclesThroughEightMaterialsOneGLineAtATime () throws IOException {
    // m == -1 means "auto-cycle": reset to 0 at the very start of the
    // import, then 1 + (current % 8) on every "g" line - 1, 2, 3, ... -
    // regardless of whatever current_Material was left at beforehand.
    app.current_Material = 7; // a stale value from something else entirely;
                               // overwritten by the m == -1 reset-to-0
                               // at the top of import_objects_OBJ, so it
                               // should have no bearing on the result below.

    Path objFile = Files.createTempFile("import-material-cycle-test", ".obj");
    Files.writeString(objFile, """
        g g1
        v 0 0 0
        v 1 0 0
        v 1 1 0
        f 1 2 3
        g g2
        v 0 0 1
        v 1 0 1
        v 1 1 1
        f 4 5 6
        g g3
        v 0 0 2
        v 1 0 2
        v 1 1 2
        f 7 8 9
        """
    );

    app.import_objects_OBJ(objFile.toString(), -1 /*m*/, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.options[0][0]);
    assertEquals(2, app.allFaces.options[1][0]);
    assertEquals(3, app.allFaces.options[2][0]);
  }

  // ================= lines that should be skipped =============================

  @Test
  void importObjectsOBJ_ignoresBlankLinesCommentsAndUnhandledDirectives () throws IOException {
    Path objFile = Files.createTempFile("import-ignored-lines-test", ".obj");
    Files.writeString(objFile, """
        # a comment
        mtllib foo.mtl

        g g1
        v 0 0 0
        vt 0.5 0.5
        v 1 0 0
        vn 0 0 1
        v 1 1 0
        usemtl Material1
        f 1 2 3
        """
    );

    app.import_objects_OBJ(objFile.toString(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(3, app.allPoints.getLength());
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(1, app.allGroups.num);
  }

  // ================= progress window headless-safety =======================
  // import_objects_OBJ() now shows a ProgressWindow (preBakeViewport3D.pde) -
  // a real java.awt.Frame - while showImportProgress (globals.pde) is on,
  // which defaults to true. Every test in this file, and every test
  // above this one, already exercises that path and would have thrown
  // java.awt.HeadlessException the moment it tried to construct one, in
  // exactly this environment - canShowProgressWindow()'s own guard
  // (checked before ever constructing one) is what keeps them passing.
  // This test makes that guarantee explicit instead of just incidental.

  @Test
  void canShowProgressWindow_matchesGraphicsEnvironmentsOwnHeadlessState () {
    // Not a hardcoded assertFalse(...): whether this particular machine
    // running the suite actually has a display available (so whether
    // java.awt.GraphicsEnvironment.isHeadless() comes back true or
    // false) isn't something this test should assume either way - a
    // real desktop/Xvfb-backed CI runner reports false here same as a
    // genuinely headless one reports true, and canShowProgressWindow()
    // should track whichever one this environment actually is, not a
    // fixed expectation baked into the test itself.
    assertEquals(!java.awt.GraphicsEnvironment.isHeadless(), app.canShowProgressWindow());
  }

  @Test
  void importObjectsOBJ_neverThrowsHeadlessExceptionEvenWithShowImportProgressOn () throws IOException {
    Path objFile = Files.createTempFile("import-headless-test", ".obj");
    Files.writeString(objFile, "g g1\nv 1 2 3\n");

    app.showImportProgress = true;

    assertDoesNotThrow(() -> {
      app.import_objects_OBJ(objFile.toString(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);
    });
  }

  // ================= "l" line statements (objImportCurves) =====================
  // Mirrors ImportObjectsDXFTest.java's/ImportObjectsIFCTest.java's own
  // "curves" sections - see importObj.pde's own objHandleLine() comment
  // for exactly what this does and why OBJ gets only lines, no arcs/
  // curves (it has no such concept of its own at all, unlike IFC/DXF).

  @Test
  void importObjectsOBJ_curvesOffByDefault_lDirectiveIsSkipped () throws IOException {
    Path objFile = Files.createTempFile("import-l-off-test", ".obj");
    Files.writeString(objFile, "g g1\nv 0 0 0\nv 1 0 0\nv 1 1 0\nl 1 2 3\n");

    app.import_objects_OBJ(objFile.toString(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allPolylines.nodes.length, "objImportCurves defaults to false: nothing should land in allPolylines");
  }

  @Test
  void importObjectsOBJ_lDirective_withCurvesOn_importsAnOpenPolylineThroughExistingVertices () throws IOException {
    app.objImportCurves = true;

    Path objFile = Files.createTempFile("import-l-open-test", ".obj");
    Files.writeString(objFile, "g g1\nv 0 0 0\nv 1 0 0\nv 1 1 0\nl 1 2 3\n");

    app.import_objects_OBJ(objFile.toString(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPolylines.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allPolylines.nodes[0], "l 1 2 3 should reference the same already-imported points f 1 2 3 would, not create new ones");
    assertEquals(0, app.allPolylines.getClose(0), "no repeated first/last vertex - not a closed loop");
    assertEquals(3, app.allPoints.getLength(), "the line should reuse the file's own 3 vertices, not create any new allPoints entries");
  }

  @Test
  void importObjectsOBJ_lDirective_repeatingTheFirstVertexAsTheLast_isReadAsAClosedLoop () throws IOException {
    app.objImportCurves = true;

    Path objFile = Files.createTempFile("import-l-closed-test", ".obj");
    Files.writeString(objFile, "g g1\nv 0 0 0\nv 1 0 0\nv 1 1 0\nl 1 2 3 1\n");

    app.import_objects_OBJ(objFile.toString(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPolylines.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allPolylines.nodes[0], "the repeated closing vertex should be dropped, not kept as a 4th node");
    assertEquals(1, app.allPolylines.getClose(0));
  }

  @Test
  void importObjectsOBJ_lDirective_resolvesNegativeRelativeIndicesTheSameWayFDoes () throws IOException {
    app.objImportCurves = true;

    Path objFile = Files.createTempFile("import-l-negative-index-test", ".obj");
    Files.writeString(objFile, "g g1\nv 0 0 0\nv 1 0 0\nv 1 1 0\nl -3 -2 -1\n");

    app.import_objects_OBJ(objFile.toString(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPolylines.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allPolylines.nodes[0]);
  }

  @Test
  void importObjectsOBJ_lDirective_doesNotInterfereWithFaceImport () throws IOException {
    app.objImportCurves = true;

    Path objFile = Files.createTempFile("import-l-and-f-test", ".obj");
    Files.writeString(objFile, "g g1\nv 0 0 0\nv 1 0 0\nv 1 1 0\nf 1 2 3\nl 1 2\n");

    app.import_objects_OBJ(objFile.toString(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
    assertEquals(1, app.allPolylines.nodes.length);
    assertArrayEquals(new int[]{0, 1}, app.allPolylines.nodes[0]);
  }

  @Test
  void importObjectsOBJ_lDirective_withOnlyOneVertex_isSkipped () throws IOException {
    // Not even one real segment - objHandleLine()'s own "count < 2"
    // guard should bail out before ever calling allPolylines.create().
    app.objImportCurves = true;

    Path objFile = Files.createTempFile("import-l-single-vertex-test", ".obj");
    Files.writeString(objFile, "g g1\nv 0 0 0\nl 1\n");

    app.import_objects_OBJ(objFile.toString(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allPolylines.nodes.length);
  }

  // ================= Step 5: extraParams captured from "g"/"o" name =============

  @Test
  void importObjectsOBJ_face_capturesItsOwnGGroupNameAsExtraParams () throws IOException {
    Path objFile = Files.createTempFile("import-g-extraparams-test", ".obj");
    Files.writeString(objFile, "g Roof\nv 0 0 0\nv 1 0 0\nv 1 1 0\nf 1 2 3\n");

    app.import_objects_OBJ(objFile.toString(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals("{\"name\": \"Roof\"}", app.allFaces.getExtraParams(0));
  }

  @Test
  void importObjectsOBJ_face_capturesItsOwnOObjectNameAsExtraParams () throws IOException {
    Path objFile = Files.createTempFile("import-o-extraparams-test", ".obj");
    Files.writeString(objFile, "o Roof\nv 0 0 0\nv 1 0 0\nv 1 1 0\nf 1 2 3\n");

    app.import_objects_OBJ(objFile.toString(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals("{\"name\": \"Roof\"}", app.allFaces.getExtraParams(0));
  }

  @Test
  void importObjectsOBJ_lDirective_capturesTheCurrentGroupNameAsExtraParams () throws IOException {
    app.objImportCurves = true;

    Path objFile = Files.createTempFile("import-l-extraparams-test", ".obj");
    Files.writeString(objFile, "g Wire\nv 0 0 0\nv 1 0 0\nl 1 2\n");

    app.import_objects_OBJ(objFile.toString(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals("{\"name\": \"Wire\"}", app.allPolylines.getExtraParams(0));
  }

  @Test
  void importObjectsOBJ_importExtraParamsFalse_suppressesCaptureEvenWithARealGroupName () throws IOException {
    app.importExtraParams = false;

    Path objFile = Files.createTempFile("import-extraparams-off-test", ".obj");
    Files.writeString(objFile, "g Roof\nv 0 0 0\nv 1 0 0\nv 1 1 0\nf 1 2 3\n");

    app.import_objects_OBJ(objFile.toString(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals("", app.allFaces.getExtraParams(0), "unchecking the shared importExtraParams option (fileSelected.pde) opts out of extraParams capture for a simplified import");
  }
}
