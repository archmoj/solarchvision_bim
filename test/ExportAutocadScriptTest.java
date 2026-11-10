import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// exportAutocadScript() only ever reads allFaces/allPoints/allPolylines
// and writes plain text via createWriter()/println() - no
// WIN3D.graphics, no PImage, no TypeWindow.OBJ3D-style draw() pass
// across the rest of the scene the way exportObj() needs (see
// ExportObjectsOBJTest.java's own comment on that) - so, just like
// exportLas() (see ExportObjectsLASTest.java's own comment), this is
// directly callable from a bare instance with just the same
// Folder_Export3D setup those files' own setUp() already needs.
class ExportAutocadScriptTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
    app.update_project_folders(); // Folder_Export3D is null until this runs - see ExportObjectsOBJTest.java's own identical comment
  }

  private Path export () throws IOException {
    app.exportAutocadScript();
    return Path.of(app.Folder_Export3D, app.ProjectName + ".scr");
  }

  @Test
  void exportAutocadScript_createsARealScrFileAtTheExpectedPath () throws IOException {
    app.exportAutocadScript();

    Path expected = Path.of(app.Folder_Export3D, app.ProjectName + ".scr");
    assertTrue(Files.exists(expected), "expected " + expected + " to exist");
    assertTrue(Files.size(expected) > 0);

    String content = Files.readString(expected);
    assertTrue(content.startsWith("-osnap off"), content);
    assertTrue(content.trim().endsWith("zoom e"), content);
  }

  @Test
  void exportAutocadScript_withNoGeometry_writesJustTheOsnapAndZoomLines () throws IOException {
    String content = Files.readString(export());

    assertEquals("-osnap off\nzoom e\n", content.replace("\r\n", "\n"));
  }

  @Test
  void exportAutocadScript_writesOne3dfaceBlock_perTriangleFace () throws IOException {
    // allFaces.draw()'s OBJ3D branch subdivides/tessellates, but the
    // exportScr.pde branch does not - it's a direct, untessellated
    // walk over allFaces.nodes, emitting exactly one "3dface" per face
    // whose node count is 3 or 4 (see the length check below).
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    String content = Files.readString(export());

    long faceBlocks = content.lines().filter(l -> l.equals("3dface")).count();
    assertEquals(1, faceBlocks, content);
    assertTrue(content.contains("0.000000,0.000000,0.000000"), content);
    assertTrue(content.contains("1.000000,0.000000,0.000000"), content);
    assertTrue(content.contains("1.000000,1.000000,0.000000"), content);
  }

  @Test
  void exportAutocadScript_skipsFaces_withFewerThanThreeOrMoreThanFourNodes () throws IOException {
    // The exportScr.pde loop only emits a "3dface" block when
    // allFaces.nodes[f].length is 3 or 4 - anything else (here: a
    // 2-node degenerate face and a 5-node face) is silently skipped,
    // confirmed directly against exportScr.pde's own condition.
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    int p3 = app.allPoints.create(0, 1, 0);
    int p4 = app.allPoints.create(0, 0, 1);
    app.allFaces.create(new int[]{ p0, p1 }); // 2 nodes: skipped
    app.allFaces.create(new int[]{ p0, p1, p2, p3, p4 }); // 5 nodes: skipped

    String content = Files.readString(export());

    long faceBlocks = content.lines().filter(l -> l.equals("3dface")).count();
    assertEquals(0, faceBlocks, content);
  }

  @Test
  void exportAutocadScript_writesOneLineBlock_perPolyline_withVertexCoordinates () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(5, 0, 0);
    int p2 = app.allPoints.create(5, 5, 0);
    app.allPolylines.create(new int[]{ p0, p1, p2 });

    String content = Files.readString(export());

    long lineBlocks = content.lines().filter(l -> l.equals("line")).count();
    assertEquals(1, lineBlocks, content);
    assertTrue(content.contains("0.000000,0.000000,0.000000"), content);
    assertTrue(content.contains("5.000000,0.000000,0.000000"), content);
    assertTrue(content.contains("5.000000,5.000000,0.000000"), content);
  }

  @Test
  void exportAutocadScript_closedPolyline_isTerminatedWithACLine_openOneWithABlankLine () throws IOException {
    // allPolylines.getMaterial(f) == 1 means "closed" - the Autocad
    // "line" command's own "c" (close) sub-command is appended only in
    // that case; any other material (here: the create() default of 0)
    // ends the vertex list with a bare blank line instead.
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int closed = app.allPolylines.create(new int[]{ p0, p1 });
    app.allPolylines.setMaterial(closed, 1);

    int p2 = app.allPoints.create(0, 0, 0);
    int p3 = app.allPoints.create(1, 0, 0);
    app.allPolylines.create(new int[]{ p2, p3 }); // default material (0): open

    String content = Files.readString(export());
    String[] lines = content.split("\r?\n", -1);

    // lines[0] is the file's own leading "-osnap off" (see the
    // no-geometry test above) - polyline output starts right after it.

    // First polyline: "line", 2 vertices, "c".
    assertEquals("line", lines[1]);
    assertEquals("0.000000,0.000000,0.000000", lines[2]);
    assertEquals("1.000000,0.000000,0.000000", lines[3]);
    assertEquals("c", lines[4]);

    // Second polyline: "line", 2 vertices, blank line (no "c").
    assertEquals("line", lines[5]);
    assertEquals("0.000000,0.000000,0.000000", lines[6]);
    assertEquals("1.000000,0.000000,0.000000", lines[7]);
    assertEquals("", lines[8]);
  }

  @Test
  void exportAutocadScript_respectsExporterPrecisionVertex_whenFormattingCoordinates () throws IOException {
    app.User3D.exporterPrecisionVertex = 2;
    int p0 = app.allPoints.create(1.23456f, -2.5f, 0);
    int p1 = app.allPoints.create(0, 0, 0);
    app.allPolylines.create(new int[]{ p0, p1 });

    String content = Files.readString(export());

    assertTrue(content.contains("1.23,-2.50,0.00"), content);
  }
}
