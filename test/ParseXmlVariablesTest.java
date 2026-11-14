import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// parse_XML_variables() itself is already exercised heavily and
// indirectly, every time, by this suite's own save/load round trips
// (LoadProjectTest.java, SaveLoadSectionTexturesTest.java) - but always
// through load_project(), which only ever calls it with
// restoreViewport == true (loadProject.pde's own two call sites, both
// literally "..., true)"). This file calls it directly instead (no
// load_project(), no disk I/O, no eventual update_frame_layout() NPE to
// work around - see LoadProjectTest.java's own header comment on that)
// specifically to cover what restoreViewport == false actually skips.
//
// restoreViewport's own doc comment (this file's own source) describes
// false as the undo/redo case - but undoRedoScene3D.pde's own comments
// say undo/redo deliberately does NOT go through parse_XML_variables()
// at all. Confirmed by searching every call site in this codebase: both
// of them pass true. So the false branch below is currently
// unreachable in production, not merely under-tested - worth locking
// down directly all the same, since nothing else in this suite ever
// exercises it, and it's exactly the kind of branch a future undo/redo
// rewrite might reach for.
class ParseXmlVariablesTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    app.Terrain.Mesh = new float[app.Terrain.rowCount][app.Terrain.columnCount][3];
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath();
    app.reset_project_folder_to_default(); // Folder_Project is null until this runs - update_project_folders() itself no longer sets it (updateFolders.pde's own fix)
    app.update_project_folders();
    app.update_input_folders();
  }

  @Test
  void restoreViewportFalse_leavesWIN3DUntouched_butStillRestoresEverythingElse () {
    app.WIN3D.cameraX = 100;
    app.SceneName = "Original Scene";

    processing.data.XML snapshot = app.buildProjectSnapshot(false); // no disk texture copying needed for this

    // Simulate state moving on after the snapshot was taken - a camera
    // drag, and some other unrelated edit.
    app.WIN3D.cameraX = 200;
    app.SceneName = "Changed Scene";

    app.parse_XML_variables(snapshot, false, false);

    assertEquals(200f, app.WIN3D.cameraX, 0.0001f, "WIN3D.from_XML() must NOT have run");
    assertEquals("Original Scene", app.SceneName, "a flat \"variable\" field restores regardless of restoreViewport");
  }

  @Test
  void restoreViewportTrue_alsoRestoresWIN3D () {
    app.WIN3D.cameraX = 100;

    processing.data.XML snapshot = app.buildProjectSnapshot(false);

    app.WIN3D.cameraX = 200;

    app.parse_XML_variables(snapshot, false, true);

    assertEquals(100f, app.WIN3D.cameraX, 0.0001f);
  }

  // ================= currentFont ==========================================
  // The one branch in parse_XML_variables() that's conditional on
  // something other than restoreViewport: loadCurrentFontStyle() (font.
  // pde) only runs when the snapshot's own currentFont actually differs
  // from what's currently set - and that function needs a real,
  // running sketch (createFont() itself refuses to run before setup(),
  // confirmed directly - not the WIN3D.graphics null check this
  // session's other quirks have run into, though ResetFontStyle() right
  // after it would have hit that too had createFont() not failed
  // first). Every other test in this class leaves currentFont alone for
  // exactly this reason.

  @Test
  void unchangedCurrentFont_skipsLoadCurrentFontStyle_soThisStaysHeadlesslySafe () {
    processing.data.XML snapshot = app.buildProjectSnapshot(false);

    assertDoesNotThrow(() -> app.parse_XML_variables(snapshot, false, true));
  }

  @Test
  void aDifferentCurrentFont_triggersLoadCurrentFontStyle_whichThrowsOutsideARealSketch () {
    processing.data.XML snapshot = app.buildProjectSnapshot(false); // captures the real, current currentFont

    app.currentFont = "SomeOtherFont-Bold-12"; // now differs from the snapshot's own value

    RuntimeException thrown = assertThrows(RuntimeException.class, () -> app.parse_XML_variables(snapshot, false, true));
    assertTrue(thrown.getMessage().contains("setup()"), thrown.getMessage());
  }
}
