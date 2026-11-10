import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// exportHtml() drives .draw(TypeWindow.HTML) across allSections,
// allModel2Ds and allFaces - like exportObj()'s OBJ3D pass (see
// ExportObjectsOBJTest.java's own comment), each of those just writes
// plain text to htmlOutput, with no WIN3D.graphics/PImage involved as
// long as WIN3D.shadingMode stays at its default (Surface_Materials) -
// anything else (Global_Solar, Vertex_Solar, Vertex_Solid,
// Vertex_Elevation) switches faces.pde's HTML branch into creating a
// real PImage palette texture via createImage()/save(), which isn't
// exercised here.
//
// These tests only exercise allFaces' own contribution, the same scope
// ExportObjectsOBJTest.java uses for the OBJ3D case. allSections and
// allModel2Ds both default to num == 0 (an empty scene), so they
// contribute nothing here regardless.
//
// Unlike allFaces.create() for OBJ3D (which needs no group at all - the
// OBJ3D branch walks this.nodes directly), the HTML branch walks
// allGroups' own face ranges, so a face only shows up in the HTML
// output once it's inside a group - see setUp()'s allGroups.makeEmpty(1)
// below, mirroring FacesTest.java's own pattern for exactly this.
class ExportHtmlTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{ 0, -1 }; // empty group, extended by allFaces.create() below
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
    app.update_project_folders(); // Folder_Export3D is null until this runs - see ExportObjectsOBJTest.java's own identical comment
  }

  private int createOneTriangle (int material) {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.current_Material = material;
    return app.allFaces.create(new int[]{ p0, p1, p2 });
  }

  private String export () throws IOException {
    app.exportHtml();
    return Files.readString(Path.of(app.Folder_Export3D, app.ProjectName + ".html"));
  }

  @Test
  void exportHtml_createsARealHtmlFileAtTheExpectedPath () throws IOException {
    app.exportHtml();

    Path expected = Path.of(app.Folder_Export3D, app.ProjectName + ".html");
    assertTrue(Files.exists(expected), "expected " + expected + " to exist");
    assertTrue(Files.size(expected) > 0);

    String content = Files.readString(expected);
    assertTrue(content.startsWith("<html>"), content);
    assertTrue(content.trim().endsWith("</html>"), content);
    assertTrue(content.contains("<title>" + app.ProjectName + "</title>"), content);
  }

  @Test
  void exportHtml_withNoGroupsOrFaces_stillWritesTheStaticSkeleton () throws IOException {
    // No group at all here (overriding setUp()'s own group), so
    // allFaces.draw()'s HTML branch has nothing to iterate over.
    app.allGroups.makeEmpty(0);

    String content = export();

    assertFalse(content.contains("<shape>"), content);
    assertFalse(content.contains("<group>"), content);
    assertTrue(content.contains("<x3d width='900px' height='600px'>"), content);
    assertTrue(content.contains("<scene>"), content);
  }

  @Test
  void exportHtml_writesOneShapePerSide_forANonZeroMaterialTriangle () throws IOException {
    // material != 0 and tessellation == 0 (the create() default) means
    // no subdivision - User3D.exporterDoubleSided defaults to true, so
    // a double-sided export of one triangle is exactly 2 <shape>
    // blocks, one per side - the same reasoning as
    // ExportObjectsOBJTest.exportObj_writesOneFacePerSide_....
    createOneTriangle(5);

    String content = export();

    long shapeCount = content.lines().filter(l -> l.trim().equals("<shape>")).count();
    long groupCount = content.lines().filter(l -> l.trim().equals("<group>")).count();

    assertEquals(2, shapeCount, content);
    assertEquals(1, groupCount, "one HTML <group> per allGroups entry, not per face: " + content);
    assertTrue(content.contains("<Appearance USE='SurfaceMaterial5'>"), content);
  }

  @Test
  void exportHtml_appliesExtraSubdivision_whenTheFacesMaterialIsZero () throws IOException {
    // Mirrors ExportObjectsOBJTest.exportObj_appliesExtraSubdivision_... -
    // the same "material == 0 adds Faces.displayTessellation" rule
    // applies to the HTML branch too: totalNumberOfSubs becomes
    // nodes[f].length * 4^(tessellation-1) = 3 * 4^1 = 12 per side, 24
    // total <shape> blocks for one triangle.
    createOneTriangle(0);

    String content = export();

    long shapeCount = content.lines().filter(l -> l.trim().equals("<shape>")).count();
    assertEquals(24, shapeCount, content);
  }

  @Test
  void exportHtml_writesTheTrianglesCoordinates_inTheIndexedFaceSet () throws IOException {
    createOneTriangle(5);

    String content = export();

    assertTrue(content.contains("coordIndex='0 1 2 -1'>"), content);
    assertTrue(content.contains("<Coordinate point='0.000000 0.000000 0.000000,1.000000 0.000000 0.000000,1.000000 1.000000 0.000000'></Coordinate>"), content);
  }

  @Test
  void exportHtml_withMaterialLibraryDisabled_omitsAppearanceDefBlocks () throws IOException {
    app.User3D.exporterMaterialLibrary = false;
    createOneTriangle(5);

    String content = export();

    assertFalse(content.contains("<Appearance DEF="), content);
    // The per-shape USE reference is still written either way - only
    // the earlier DEF declaration this depends on is skipped.
    assertTrue(content.contains("<Appearance USE='SurfaceMaterial5'>"), content);
  }
}
