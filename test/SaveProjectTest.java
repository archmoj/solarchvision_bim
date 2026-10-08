import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// saveProject() itself is already covered via _fileSelected_SaveAs's own
// tests (see FileSelectedTest.java) - this is specifically holdProject()/
// fetchProject(), the "stash the current project to a throwaway temp file,
// then reload it later" pair built on top of it (and, for fetchProject(),
// on load_project() - see FileSelectedTest.java's own notes on that one's
// WIN3D.graphics limits here).
class SaveProjectTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    app.allModel2Ds.ImagePath = new String[]{""}; // see FileSelectedTest.java
    app.Terrain.Mesh = new float[app.Terrain.rowCount][app.Terrain.columnCount][3];
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
    app.update_project_folders(); // Folder_Project is null until this runs
  }

  // ================= holdProject() ====================================================

  @Test
  void holdProject_writesARealFile_atTheExpectedPathAndUpdatesHoldStamp () {
    String holdStampBefore = app.HoldStamp;

    app.holdProject();

    assertNotEquals(holdStampBefore, app.HoldStamp, "a fresh millis()-based stamp should be set");
    Path expected = Path.of(app.Folder_Project, "Temp", app.ProjectName + "_tmp" + app.HoldStamp + ".xml");
    assertTrue(Files.exists(expected), "expected " + expected + " to exist");
    assertDoesNotThrow(() -> assertTrue(Files.size(expected) > 0));
  }

  // ================= fetchProject() ====================================================

  @Test
  void fetchProject_withNoPriorHold_doesNotThrow_andLeavesTheModelUntouched () {
    // HoldStamp defaults to "" (see globals.pde), so this points at a file
    // that was never written - genuinely missing, the case its own
    // catch (Exception e) / "Cannot find the hold file" message is
    // actually meant for.
    assertEquals("", app.HoldStamp, "sanity check: no holdProject() call yet");

    assertDoesNotThrow(() -> app.fetchProject());

    assertEquals(0, app.allGroups.num);
    assertEquals(0, app.allFaces.nodes.length);
  }

  @Test
  void fetchProject_afterHoldProject_restoresTheHeldGeometry () throws IOException {
    // Build some real geometry the same way FileSelectedTest.java's own
    // ImportObj/Open-round-trip tests do.
    Path objFile = Files.createTempFile("save-project-holdfetch-test", ".obj");
    Files.writeString(objFile, "g triangle\nv 0 0 0\nv 1 0 0\nv 1 1 0\nf 1 2 3\n");
    app.import_objects_OBJ(objFile.toString(), 5, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);
    assertEquals(1, app.allGroups.num, "setup check, not the point of this test");
    assertEquals(1, app.allFaces.nodes.length, "setup check, not the point of this test");

    app.holdProject();

    // Wipe the in-memory geometry before fetching it back, so a pass here
    // can only mean fetchProject() actually restored it from the file -
    // same reasoning as FileSelectedTest.java's own Open-round-trip test.
    app.allFaces.nodes = new int[0][];
    app.allVertices = new float[0][3];
    app.allGroups.makeEmpty(0);

    // Unlike _fileSelected_Open (which lets load_project()'s own
    // update_frame_layout()/createGraphics() NullPointerException
    // propagate - confirmed in FileSelectedTest.java), fetchProject()
    // wraps load_project() in its own try/catch (Exception e), so this
    // never throws regardless of whether the file was genuinely missing
    // or - as here - found and mostly restored before that same later,
    // unrelated limitation fires. Confirmed by hand against the real
    // compiled app before writing this: the "Cannot find the hold file"
    // message still prints in this case too, despite the file actually
    // having been found - that broad catch doesn't distinguish the two.
    assertDoesNotThrow(() -> app.fetchProject());

    assertEquals(1, app.allGroups.num);
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(3, app.allPoints.getLength());
  }
}
