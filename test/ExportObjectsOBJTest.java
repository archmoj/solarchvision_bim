import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// exportObj(suffix) drives .draw(TypeWindow.OBJ3D) across many classes
// (Earth3D, Terrain, Tropo3D, allSections, allModel1Ds, allModel2Ds,
// allFaces, allWindFlows, Sky3D, and conditionally Sun3D) - unlike most
// *.draw() calls in this app (WIN3D's own target_window), the OBJ3D branch
// of each just writes plain text to objOutput/mtlOutput, with no
// WIN3D.graphics/PImage involved, so - confirmed by hand against the real
// compiled app before writing this - it's directly callable from a bare,
// never-setup()'d instance the same way saveProject() is (see
// FileSelectedTest.java's SaveAs tests, which this file's setUp() mirrors).
//
// These tests only exercise allFaces' own contribution - the one class
// whose OBJ3D output is both simple to predict and actually interesting
// (the material==0 case below). Terrain/Sky3D/etc. are left alone here:
// Terrain.shouldDraw() returns false by default (displaySurface is false),
// so it contributes nothing to a fresh instance's export regardless of
// the Terrain.Mesh seeding below (that seeding is for saveProject(), not
// this file); the rest default to producing nothing for an otherwise-empty
// scene, confirmed by inspecting a real export's output directly.
class ExportObjectsOBJTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allModel2Ds.ImagePath = new String[]{""}; // see FileSelectedTest.java
    app.Terrain.Mesh = new float[app.Terrain.rowCount][app.Terrain.columnCount][3];
    app.locateBaseFolder();
    app.update_project_folders(); // Folder_Export3D is null until this runs
  }

  private void importOneTriangle (int material) throws IOException {
    Path objFile = Files.createTempFile("export-test-source", ".obj");
    Files.writeString(objFile, "g triangle\nv 0 0 0\nv 1 0 0\nv 1 1 0\nf 1 2 3\n");
    app.import_objects_OBJ(objFile.toString(), material, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);
  }

  @Test
  void exportObj_createsARealObjFileAtTheExpectedPath () throws IOException {
    importOneTriangle(5);

    app.exportObj("_test");

    Path expected = Path.of(app.Folder_Export3D, app.ProjectName + "_test.obj");
    assertTrue(Files.exists(expected), "expected " + expected + " to exist");
    assertTrue(Files.size(expected) > 0);

    String content = Files.readString(expected);
    assertTrue(content.startsWith("#SOLARCHVISION"), content);
    // exporterMaterialLibrary defaults to true, so a .mtl sits alongside it.
    assertTrue(content.contains("mtllib " + app.ProjectName + "_test.mtl"), content);
    assertTrue(Files.exists(Path.of(app.Folder_Export3D, app.ProjectName + "_test.mtl")));
  }

  @Test
  void exportObj_writesOneFacePerSide_forANonZeroMaterialTriangle () throws IOException {
    // material != 0 and tessellation == 0 (the import default) means no
    // export-time subdivision (see the material == 0 test below for the
    // case where there is) - User3D.exporterDoubleSided defaults to true,
    // so a double-sided export of one triangle is exactly 2 output faces,
    // one per side, not 1.
    importOneTriangle(5);

    app.exportObj("_oneface");

    String content = Files.readString(Path.of(app.Folder_Export3D, app.ProjectName + "_oneface.obj"));
    long fLines = content.lines().filter(l -> l.startsWith("f ")).count();
    long gLines = content.lines().filter(l -> l.startsWith("g ")).count();

    assertEquals(2, fLines, "one face per side: " + content);
    assertEquals(2, gLines, "one g Object3D_..._side group per side: " + content);
    assertTrue(content.contains("usemtl SurfaceMaterial5"), content);
  }

  @Test
  void exportObj_appliesExtraSubdivision_whenTheFacesMaterialIsZero () throws IOException {
    // Faces.pde's own OBJ3D export branch: "if (this.getMaterial(f) == 0)
    // tessellation += this.displayTessellation;" - material 0 specifically
    // (not any other material) gets Faces.displayTessellation (2 by
    // default) added to its export tessellation, regardless of the face's
    // own (here: 0). totalNumberOfSubs then becomes
    // nodes[f].length * 4^(tessellation-1) = 3 * 4^1 = 12 per side - so a
    // single triangle becomes 12 output faces per side, 24 total. This
    // looks surprising out of context, so it's worth pinning down
    // explicitly: confirmed by hand against the real compiled app, and
    // genuinely intentional (Faces.displayTessellation is a real,
    // deliberately-read field, not a stray global) rather than another
    // instance of the tes/lyr/vsb/wgt/clz bug in ImportObjectsOBJTest.java -
    // material 0 is the one case this file's import helper doesn't use
    // elsewhere, specifically to keep those other tests' output simple
    // and predictable.
    importOneTriangle(0);

    app.exportObj("_material0");

    String content = Files.readString(Path.of(app.Folder_Export3D, app.ProjectName + "_material0.obj"));
    long fLines = content.lines().filter(l -> l.startsWith("f ")).count();

    assertEquals(24, fLines, content);
  }

  @Test
  void exportObj_withMaterialLibraryDisabled_omitsMtllibAndUsemtlLines () throws IOException {
    app.User3D.exporterMaterialLibrary = false;
    importOneTriangle(5);

    app.exportObj("_nomtl");

    String content = Files.readString(Path.of(app.Folder_Export3D, app.ProjectName + "_nomtl.obj"));
    assertFalse(content.contains("mtllib"), content);
    assertFalse(content.contains("usemtl"), content);
    assertFalse(Files.exists(Path.of(app.Folder_Export3D, app.ProjectName + "_nomtl.mtl")),
        "no .mtl file should be written at all when the material library is disabled");
  }
}
