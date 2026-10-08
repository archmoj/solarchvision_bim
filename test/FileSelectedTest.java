import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// Every selectFile_X() in fileSelected.pde is a one-line call straight into
// Processing's own native file dialog (selectInput()/selectOutput()) - live
// UI state, not unit-testable as-is (see test/README.md). What's actually
// worth covering is the _fileSelected_X(File) callback each one wires up:
// those take a File directly, so they're exercised here the same way
// selectInput()/selectOutput() would eventually call them - including the
// null case, which is exactly what a cancelled dialog passes.
//
// _fileSelected_Open is covered only partway: it calls load_project(),
// which calls update_frame_layout(), which calls Processing's own
// createGraphics() - confirmed, here and elsewhere (see
// UI_toolBarTest.java's viewLayout_allFourSubOptions()), to throw a
// NullPointerException in this headless test environment, since that needs
// a real sketch surface only available after setup()/size() actually run.
// Checked by hand against a real save/load round trip before writing the
// test below: everything load_project() does before that point - XML
// parsing, every from_XML(), all four update_station() calls - completes
// first, so the test catches the known exception and asserts what already
// happened by then, the same pattern UI_toolBarTest.java uses.
class FileSelectedTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.locateBaseFolder();
    app.allActions = new java.util.HashMap<>(); // fresh app never runs build_allActions() itself
    // allModel2Ds.ImagePath is normally populated by load_images() during
    // real app startup - a fresh instance never runs that (it touches
    // loadImage()/PImage, so it isn't something a test should call either -
    // see test/README.md), but allModel2Ds.to_XML() (reached through
    // saveProject() below) assumes it's at least non-null. This is
    // load_images()'s own first two lines, with no actual image loading.
    app.allModel2Ds.ImagePath = new String[]{""};
    // Same reasoning, but shaped [rowCount][columnCount][3] - matching
    // Terrain's own default row/column counts - rather than empty: an
    // empty Mesh still satisfies to_XML() (it just writes zero <item>s),
    // but desyncs from rowCount/columnCount in the saved file, and
    // from_XML() always expects exactly rowCount*columnCount items back
    // on load, throwing ArrayIndexOutOfBoundsException otherwise. Confirmed
    // by hand against a real save/load round trip before settling on this -
    // see fileSelectedOpen_restoresGeometry... below, which depends on it.
    app.Terrain.Mesh = new float[app.Terrain.rowCount][app.Terrain.columnCount][3];
  }

  // ================= _getSelectedFile ========================================

  @Test
  void getSelectedFile_convertsBackslashesToForwardSlashes () {
    // Windows' own File.getAbsolutePath() comes back backslash-separated;
    // every _fileSelected_* callback below runs its File through this
    // first so the rest of the app (which builds paths with plain string
    // concatenation, not java.nio.file.Path) only ever sees forward
    // slashes, regardless of OS.
    File selected = new File("some\\backslash\\path.xml");

    String result = app._getSelectedFile(selected);

    assertFalse(result.contains("\\"), "backslashes should be converted: " + result);
    assertTrue(result.endsWith("/some/backslash/path.xml"), result);
  }

  // ================= _fileSelected_RunScript =================================

  @Test
  void fileSelectedRunScript_withNull_isANoOp () {
    // selectInput()'s callback is invoked with null when the user cancels
    // the dialog - must not throw, and must not touch STATION or anything
    // else.
    float latitudeBefore = app.STATION.getLatitude();

    assertDoesNotThrow(() -> app._fileSelected_RunScript(null));

    assertEquals(latitudeBefore, app.STATION.getLatitude(), 0.001f);
  }

  @Test
  void fileSelectedRunScript_withAFile_runsEveryLineThroughRunScriptFile () throws IOException {
    // An absolute path, not one relative to Folder_Import/sketchPath - this
    // app instance was never run as a sketch, so sketchPath()/dataPath()
    // resolution isn't available the way it is when selectInput() hands a
    // real, running sketch a selected File (same reasoning as
    // OperatingSystemTest.java's getFiles_* tests, which use a real temp
    // directory for the same reason).
    //
    // Two SETxxx commands on their own lines - rather than one SETLONLAT -
    // so this is actually exercising runScriptFile()/runScriptLines()
    // looping over every line of the file (see runScript.pde), not just
    // confirming a single line's own parameter parsing (already covered by
    // RunScriptTest.java).
    Path scriptFile = Files.createTempFile("fileSelected-RunScript-test", ".svs");
    Files.writeString(scriptFile, """
        SETLAT 45.5
        SETLON -73.6
        """
    );

    app._fileSelected_RunScript(scriptFile.toFile());

    // runScriptFile only queues the file's lines now (see its own
    // comment in runScript.pde) - a real draw() frame is what actually
    // runs them; runPendingScriptLines() stands in for that here.
    app.runPendingScriptLines();

    assertEquals(45.5f, app.STATION.getLatitude(), 0.001f);
    assertEquals(-73.6f, app.STATION.getLongitude(), 0.001f);
  }

  // ================= _fileSelected_New ========================================
  // update_project_info() (shared with _fileSelected_SaveAs below) only ever
  // reads the File's own name/path - it never touches disk - so, unlike
  // RunScript's fixture above, these Files don't need to actually exist.

  @Test
  void fileSelectedNew_withNull_isANoOp () {
    String projectNameBefore = app.ProjectName;

    assertDoesNotThrow(() -> app._fileSelected_New(null));

    assertEquals(projectNameBefore, app.ProjectName);
  }

  @Test
  void fileSelectedNew_withAFile_setsProjectNameFromTheFilesBaseName () {
    app._fileSelected_New(new File("/some/path/MyProject.xml"));

    assertEquals("MyProject", app.ProjectName);
  }

  @Test
  void fileSelectedNew_isCaseInsensitiveAboutTheXmlExtension () {
    // update_project_info() strips ".xml" and ".XML" as two separate
    // .replace() calls (see fileSelected.pde) rather than one
    // case-insensitive match - this confirms the second call actually
    // covers the upper-case case, not just the lower-case one above.
    app._fileSelected_New(new File("/some/path/MyProject.XML"));

    assertEquals("MyProject", app.ProjectName);
  }

  @Test
  void fileSelectedNew_setsFolderProjectToTheFixedModelFolder_notTheFilesDirectory () {
    // update_project_info() computes Folder_Project from the selected
    // File's own directory first - but then immediately calls
    // update_project_folders(), whose first line unconditionally
    // overwrites Folder_Project with BaseFolder + "/projects/model-01"
    // (see update_folders.pde). So the directory the file was actually
    // opened from never survives - this looks surprising enough to be
    // worth pinning down explicitly, whether or not it's intentional.
    app._fileSelected_New(new File("/some/other/directory/MyProject.xml"));

    assertEquals(app.BaseFolder + "/projects/model-01", app.Folder_Project);
  }

  // ================= _fileSelected_SaveAs ======================================

  @Test
  void fileSelectedSaveAs_withNull_isANoOp () {
    assertDoesNotThrow(() -> app._fileSelected_SaveAs(null));
  }

  @Test
  void fileSelectedSaveAs_withAFile_writesARealNonEmptyXmlFile () throws IOException {
    Path target = Files.createTempFile("fileSelected-SaveAs-test", ".xml");
    Files.delete(target); // only the containing directory needs to pre-exist -
                           // deleting the file itself first confirms saveProject()
                           // actually creates it, not just reuses what was there.

    app._fileSelected_SaveAs(target.toFile());

    assertTrue(Files.exists(target), "saveProject() should have written the file");
    assertTrue(Files.size(target) > 0, "the XML file should not be empty");
  }

  @Test
  void fileSelectedSaveAs_withAFile_alsoUpdatesProjectInfoFirst () throws IOException {
    // _fileSelected_SaveAs calls update_project_info() before saveProject()
    // - same ProjectName behavior as _fileSelected_New above, just reached
    // through the other callback.
    Path target = Files.createTempFile("fileSelected-SaveAs-projectname-test", ".xml");
    Files.delete(target);

    app._fileSelected_SaveAs(target.toFile());

    String expectedName = target.getFileName().toString().replace(".xml", "");
    assertEquals(expectedName, app.ProjectName);
  }

  // ================= _fileSelected_ImportObj ===================================

  @Test
  void fileSelectedImportObj_withNull_isANoOp () {
    int groupCountBefore = app.allGroups.num;

    assertDoesNotThrow(() -> app._fileSelected_ImportObj(null));

    assertEquals(groupCountBefore, app.allGroups.num);
  }

  @Test
  void fileSelectedImportObj_withAFile_importsOneGroupAndSelectsIt () throws IOException {
    // A minimal, valid OBJ: one "g" line (one new group), a triangle's
    // worth of vertices and one face referencing them by OBJ's 1-based
    // indices.
    Path objFile = Files.createTempFile("fileSelected-ImportObj-test", ".obj");
    Files.writeString(objFile, """
        g triangle
        v 0 0 0
        v 1 0 0
        v 1 1 0
        f 1 2 3
        """
    );

    app._fileSelected_ImportObj(objFile.toFile());

    // allGroups starts empty, so _fileSelected_ImportObj first seeds one
    // placeholder group of its own (see fileSelected.pde's
    // "if (allGroups.num == 0)" guard) before importing - then the "g"
    // line above adds a second, real one.
    assertEquals(2, app.allGroups.num);
    assertEquals(3, app.allPoints.getLength(), "all 3 vertices should have been created"); // sanity check, not the focus of this test
    assertEquals(1, app.allFaces.nodes.length, "the one face should have been created");

    // Select3D.groupSelection is sized 1 + (groups added by this import),
    // i.e. 2 here - but the loop that fills it only ever writes
    // length-1 entries (see fileSelected.pde), so its very last slot is
    // left at Java's default int value (0) rather than ever being
    // assigned. That means it always points at group 0 - whatever group
    // happens to be first overall - not necessarily anything related to
    // this import. Documenting the actual behavior here, not endorsing
    // it as obviously intentional.
    assertArrayEquals(new int[]{1, 0}, app.Select3D.groupSelection);

    assertEquals(app.ObjectCategory.GROUP, app.currentObjectCategory);
  }

  // ================= _fileSelected_Open (partial - see the class comment) ====

  @Test
  void fileSelectedOpen_restoresGeometrySavedBySaveAs_beforeHittingTheKnownUpdateFrameLayoutNPE () throws IOException {
    // Build some real geometry the same way fileSelectedImportObj_withAFile_
    // importsOneGroupAndSelectsIt above does, so this test isn't also on
    // the hook for proving import works - just that save/open round-trip
    // whatever geometry already exists.
    Path objFile = Files.createTempFile("fileSelected-Open-roundtrip-test", ".obj");
    Files.writeString(objFile, """
        g triangle
        v 0 0 0
        v 1 0 0
        v 1 1 0
        f 1 2 3
        """
    );
    app._fileSelected_ImportObj(objFile.toFile());
    assertEquals(2, app.allGroups.num, "setup check, not the point of this test");
    assertEquals(1, app.allFaces.nodes.length, "setup check, not the point of this test");
    assertEquals(3, app.allPoints.getLength(), "setup check, not the point of this test");

    Path saved = Files.createTempFile("fileSelected-Open-roundtrip-test", ".xml");
    Files.delete(saved);
    app._fileSelected_SaveAs(saved.toFile());

    // Wipe the in-memory geometry before loading it back, so a pass here
    // can only mean _fileSelected_Open actually restored it from the file -
    // not that it was simply never cleared (confirmed separately: a bare
    // _fileSelected_New does NOT clear existing geometry, so that alone
    // wouldn't prove anything).
    app.allFaces.nodes = new int[0][];
    app.allVertices = new float[0][3]; // allVertices backs allPoints.getLength() -
                                        // a top-level field of solarchvision_bim
                                        // itself, not of Points.
    app.allGroups.makeEmpty(0);

    Throwable thrown = null;
    try {
      app._fileSelected_Open(saved.toFile());
    } catch (Throwable t) {
      thrown = t;
    }

    assertNotNull(thrown, "update_frame_layout()'s createGraphics() call is expected to still throw here");
    assertInstanceOf(NullPointerException.class, thrown);

    // The actual point of this test: despite that later throw, everything
    // load_project() does first - XML parsing and every from_XML(),
    // including allFaces/allGroups/allPoints - already ran to completion.
    assertEquals(2, app.allGroups.num);
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(3, app.allPoints.getLength());
  }
}
