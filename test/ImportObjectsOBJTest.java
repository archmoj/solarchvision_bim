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

  // ================= tes/lyr/vsb/wgt/clz: confirmed dead parameters ===========

  @Test
  void importObjectsOBJ_ignoresItsOwnTessellationLayerVisibilityWeightAndClosedParameters () throws IOException {
    // allFaces.create() (see Faces.pde) pulls a new face's tessellation,
    // layer, visibility, weight and "closed" from the current_Tessellation/
    // current_Layer/current_Visibility/current_Weight/current_Closed
    // globals - which every primitive-creation function in Create3D.pde
    // sets from its own matching tes/lyr/vsb/wgt/clz parameters before
    // creating geometry (e.g. add_Octahedron()). import_objects_OBJ() has
    // the exact same five parameters, declared with the exact same names,
    // but its body never assigns any of them to those globals - only
    // current_Material (from m) is ever set. So these five arguments are
    // silently ignored: an imported face's tessellation/layer/visibility/
    // weight/closed end up being whatever was already set by the previous
    // unrelated operation, not what the caller passed in here. Confirmed
    // by hand against the real compiled app before writing this - this
    // documents the actual, observed behavior, not a presumed-intentional
    // design, and is worth a fix (match Create3D.pde's own pattern) if
    // it isn't deliberate.
    app.current_Tessellation = 111;
    app.current_Layer = 222;
    app.current_Visibility = 333;
    app.current_Weight = 444;
    app.current_Closed = 555;

    Path objFile = Files.createTempFile("import-dead-params-test", ".obj");
    Files.writeString(objFile, "g g1\nv 0 0 0\nv 1 0 0\nv 1 1 0\nf 1 2 3\n");

    app.import_objects_OBJ(objFile.toString(), 9 /*m*/, 1 /*tes*/, 2 /*lyr*/, 3 /*vsb*/, 4 /*wgt*/, 5 /*clz*/, 0, 0, 0, 1, 1, 1);

    // options = [material, tessellation, layer, visibility, weight, closed] - see Faces.create()
    assertEquals(9, app.allFaces.options[0][0], "material (m) IS applied");
    assertEquals(111, app.allFaces.options[0][1], "tessellation (tes=1) is NOT applied - stays at the stale global");
    assertEquals(222, app.allFaces.options[0][2], "layer (lyr=2) is NOT applied - stays at the stale global");
    assertEquals(333, app.allFaces.options[0][3], "visibility (vsb=3) is NOT applied - stays at the stale global");
    assertEquals(444, app.allFaces.options[0][4], "weight (wgt=4) is NOT applied - stays at the stale global");
    assertEquals(555, app.allFaces.options[0][5], "closed (clz=5) is NOT applied - stays at the stale global");
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
}
