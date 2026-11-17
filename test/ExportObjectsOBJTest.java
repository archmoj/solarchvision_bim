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
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    // (no allModel2Ds.ImagePath stand-in needed any more - see
    // FileSelectedTest.java's own comment on why.)
    app.Terrain.Mesh = new float[app.Terrain.rowCount][app.Terrain.columnCount][3];
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder() - that walks up from sketchPath() looking
    // for input/, which from a Processing-CLI/test context resolves
    // nowhere near this repo's actual input/ folder, so it calls
    // System.exit(1) and kills the whole test JVM rather than just this
    // test.
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
    app.reset_project_folder_to_default(); // Folder_Project is null until this runs - update_project_folders() itself no longer sets it (updateFolders.pde's own fix)
    app.update_project_folders(); // Folder_Export3D is null until this runs
  }

  private void importOneTriangle (int material) throws IOException {
    Path objFile = Files.createTempFile("export-test-source", ".obj");
    Files.writeString(objFile, "g triangle\nv 0 0 0\nv 1 0 0\nv 1 1 0\nf 1 2 3\n");
    app.import_objects_OBJ(objFile.toString(), material, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);
  }

  // objHandleLine() (importObj.pde) is the simplest way to get a real
  // allPolylines entry into a fresh instance with the exact
  // current_Material/Tessellation/Layer/Visibility/Weight/Closed globals
  // already set the way a real import call would leave them - same
  // reasoning importOneTriangle() above already follows for allFaces.
  private void importOnePolyline (boolean closed) throws IOException {
    app.objImportCurves = true;
    Path objFile = Files.createTempFile("export-test-polyline-source", ".obj");
    String body = closed
      ? "g line1\nv 0 0 0\nv 1 0 0\nv 1 1 0\nl 1 2 3 1\n"
      : "g line1\nv 0 0 0\nv 1 0 0\nv 1 1 0\nl 1 2 3\n";
    Files.writeString(objFile, body);
    // (FileName, m, tes, lyr, vsb, wgt, clz, cx, cy, cz, sx, sy, sz) - vsb=1
    // so this Polyline is actually visible (current_Visibility would
    // otherwise default to 0, and the new OBJ3D export branch skips
    // invisible polylines just like a real one would).
    app.import_objects_OBJ(objFile.toString(), 5, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
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
    // faces.pde's own OBJ3D export branch: "if (this.getMaterial(f) == 0)
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

  // allPolylines was entirely absent from exportObj.pde's own list of
  // .draw(TypeWindow.OBJ3D) calls before this feature, and Polylines.draw()
  // itself only ever had a WIN3D branch - these tests cover the new OBJ3D
  // branch added to polylines.pde alongside it.

  @Test
  void exportObj_writesLLine_forAnOpenImportedPolyline () throws IOException {
    importOnePolyline(false);

    app.exportObj("_polyline_open");

    String content = Files.readString(Path.of(app.Folder_Export3D, app.ProjectName + "_polyline_open.obj"));
    long lLines = content.lines().filter(l -> l.startsWith("l ")).count();
    assertEquals(1, lLines, content);

    // Only 3 vertices exist in the whole file (no faces exported here),
    // so this Polyline's own "v" lines are numbered 1..3 and its "l" line
    // should reference exactly those three, in order, with no repeat.
    String lLine = content.lines().filter(l -> l.startsWith("l ")).findFirst().get();
    assertEquals("l 1 2 3", lLine.strip(), content);
  }

  @Test
  void exportObj_repeatsFirstVertex_forAClosedImportedPolyline () throws IOException {
    importOnePolyline(true);

    app.exportObj("_polyline_closed");

    String content = Files.readString(Path.of(app.Folder_Export3D, app.ProjectName + "_polyline_closed.obj"));
    String lLine = content.lines().filter(l -> l.startsWith("l ")).findFirst().get();

    // Closed loop: the first vertex index (1) is repeated at the end,
    // matching objHandleLine()'s own convention for reading this back in.
    assertEquals("l 1 2 3 1", lLine.strip(), content);
  }

  @Test
  void exportObj_writesLinesGroupTag_whenExporterMaintainPolygonsIsOn () throws IOException {
    // User3D.exporterMaintainPolygons defaults to 1 (user3D.pde), so a
    // fresh instance should produce the "g Object3D_..._lines" tag with
    // no explicit setting needed.
    importOnePolyline(false);

    app.exportObj("_polyline_grouptag");

    String content = Files.readString(Path.of(app.Folder_Export3D, app.ProjectName + "_polyline_grouptag.obj"));
    assertTrue(content.lines().anyMatch(l -> l.startsWith("g Object3D_") && l.endsWith("_lines")), content);
  }

  @Test
  void exportObj_omitsLinesGroupTag_whenExporterMaintainPolygonsIsOff () throws IOException {
    app.User3D.exporterMaintainPolygons = 0;
    importOnePolyline(false);

    app.exportObj("_polyline_nogrouptag");

    String content = Files.readString(Path.of(app.Folder_Export3D, app.ProjectName + "_polyline_nogrouptag.obj"));
    assertFalse(content.lines().anyMatch(l -> l.startsWith("g Object3D_") && l.endsWith("_lines")), content);
    // The line itself should still be written either way.
    assertTrue(content.lines().anyMatch(l -> l.startsWith("l ")), content);
  }

  @Test
  void exportObj_omitsInvisiblePolyline_fromExport () throws IOException {
    importOnePolyline(false);
    // allPolylines.nodes.length - 1 is the just-created polyline's own row.
    app.allPolylines.setVisibility(app.allPolylines.nodes.length - 1, 0);

    app.exportObj("_polyline_invisible");

    String content = Files.readString(Path.of(app.Folder_Export3D, app.ProjectName + "_polyline_invisible.obj"));
    assertFalse(content.lines().anyMatch(l -> l.startsWith("l ")), content);
  }

  @Test
  void exportObj_continuesVertexNumbering_afterAnAlreadyExportedFace () throws IOException {
    // allFaces.draw(TypeWindow.OBJ3D) runs before allPolylines.draw(...)
    // in exportObj.pde, so the running obj_lastVertexNumber counter
    // should already sit at 3 (the triangle's own 3 vertices) by the
    // time the polyline's own "v"/"l" lines are written - this pins that
    // shared-counter interaction down explicitly.
    importOneTriangle(5);
    importOnePolyline(false);

    app.exportObj("_polyline_afterface");

    String content = Files.readString(Path.of(app.Folder_Export3D, app.ProjectName + "_polyline_afterface.obj"));
    String lLine = content.lines().filter(l -> l.startsWith("l ")).findFirst().get();

    // The triangle contributes vertices 1-3 (written once per side, so
    // really 1-3 then 4-6 for the double-sided export) - whichever count
    // it ends at, the polyline's own 3 new vertices should be numbered
    // starting right after it, with no gap or overlap.
    long vLines = content.lines().filter(l -> l.startsWith("v ")).count();
    String expected = "l " + (vLines - 2) + " " + (vLines - 1) + " " + vLines;
    assertEquals(expected, lLine.strip(), content);
  }
}
