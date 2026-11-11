import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// SaveProjectTest.java already covers holdProject()/fetchProject() (built
// on saveProject()/load_project()) for faces/groups/points, and
// FileSelectedTest.java covers the same round trip through
// _fileSelected_SaveAs()/_fileSelected_Open(). This file calls
// saveProject()/load_project() directly instead, to cover the rest of
// what buildProjectSnapshot() actually writes - polylines, STATION, and
// a handful of the flat "variable" scalars - plus a few load_project()/
// saveProject() behaviors neither of those files touches at all: a
// missing/corrupt file on load, and saveProject()'s own backslash-path
// handling.
//
// Every load_project() call below hits the exact same known
// update_frame_layout() -> createGraphics() NullPointerException
// FileSelectedTest.java's own class comment documents (a real sketch
// surface is needed only past that point) - confirmed by hand, same as
// that file, that everything load_project() does first (XML parsing,
// every from_XML(), all four update_station() calls) completes before
// it, so each test here catches that same exception and asserts what
// had already happened by then.
class LoadProjectTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    app.Terrain.Mesh = new float[app.Terrain.rowCount][app.Terrain.columnCount][3];
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
    app.update_project_folders(); // Folder_Project is null until this runs
    // See SaveProjectTest.java's own identical comment: load_project()'s
    // own update_station(1..4) needs Folder_climateTypicalYear/.../
    // Folder_ensembleObservation, which only update_input_folders() ever
    // sets.
    app.update_input_folders();
  }

  private Path saveToTempFile (String prefix) throws IOException {
    Path saved = Files.createTempFile(prefix, ".xml");
    Files.delete(saved); // only the containing directory needs to pre-exist - see
                          // FileSelectedTest.java's own identical reasoning.
    app.saveProject(saved.toString());
    return saved;
  }

  private void loadExpectingTheKnownFrameLayoutNPE (Path file) {
    Throwable thrown = null;
    try {
      app.load_project(file.toString());
    } catch (Throwable t) {
      thrown = t;
    }
    assertNotNull(thrown, "update_frame_layout()'s createGraphics() call is expected to still throw here");
    assertInstanceOf(NullPointerException.class, thrown);
  }

  // ================= saveProject() / load_project() round trip =========

  @Test
  void loadProject_roundTripsAPolyline_includingItsMaterialAndCloseFlag () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(5, 0, 0);
    int p2 = app.allPoints.create(5, 5, 0);
    int line = app.allPolylines.create(new int[]{ p0, p1, p2 });
    app.allPolylines.setMaterial(line, 3);
    app.allPolylines.setClose(line, 1);

    Path saved = saveToTempFile("load-project-polyline-test");

    // Wipe the in-memory geometry first, so a pass below can only mean
    // load_project() actually restored it from the file - same
    // reasoning as SaveProjectTest.java's own
    // fetchProject_afterHoldProject_restoresTheHeldGeometry().
    app.allPolylines.makeEmpty(0);
    app.allPoints.makeEmpty(0);

    loadExpectingTheKnownFrameLayoutNPE(saved);

    assertEquals(1, app.allPolylines.nodes.length);
    assertArrayEquals(new int[]{ 0, 1, 2 }, app.allPolylines.nodes[0]);
    assertEquals(3, app.allPolylines.getMaterial(0));
    assertEquals(1, app.allPolylines.getClose(0));
    assertEquals(3, app.allPoints.getLength());
    assertEquals(5f, app.allPoints.getX(1), 0.001f);
    assertEquals(5f, app.allPoints.getY(2), 0.001f);
  }

  @Test
  void loadProject_roundTripsStationLatitudeAndLongitude () throws IOException {
    app.STATION.setLatitude(45.5f);
    app.STATION.setLongitude(-73.6f);

    Path saved = saveToTempFile("load-project-station-test");

    app.STATION.setLatitude(0);
    app.STATION.setLongitude(0);

    loadExpectingTheKnownFrameLayoutNPE(saved);

    assertEquals(45.5f, app.STATION.getLatitude(), 0.001f);
    assertEquals(-73.6f, app.STATION.getLongitude(), 0.001f);
  }

  @Test
  void loadProject_roundTripsTopLevelScalarProjectVariables () throws IOException {
    // A handful of the flat "variable" children buildProjectSnapshot()
    // writes directly (not through any class's own to_XML()) - picked
    // because each has an easy-to-check, non-default value and none of
    // them is touched by update_station(1..4) (the only production code
    // that runs between parse_XML_variables() and the known NPE above).
    app.SceneName = "My Test Scene";
    app.globalAlbedo = 42.5f;
    app.impactDisplayDay = 7;

    Path saved = saveToTempFile("load-project-scalars-test");

    app.SceneName = "";
    app.globalAlbedo = 0;
    app.impactDisplayDay = 0;

    loadExpectingTheKnownFrameLayoutNPE(saved);

    assertEquals("My Test Scene", app.SceneName);
    assertEquals(42.5f, app.globalAlbedo, 0.001f);
    assertEquals(7, app.impactDisplayDay);
  }

  // ================= load_project() with a missing/unreadable file =====

  @Test
  void loadProject_withAMissingFile_doesNotThrow_andLeavesTheModelUntouched () {
    // Previously: a file that's simply not there made Processing's own
    // loadXML() log its "missing or inaccessible" warning and return
    // null without throwing - so load_project()'s own try/catch around
    // loadXML() never fired, continue_process stayed true, and xml was
    // null going into parse_XML_variables(). That threw its own
    // NullPointerException, which the retry (parse_XML_variables(xml,
    // true, true), inside the catch block) hit again with xml still
    // null - uncaught this time, since it's thrown from inside the
    // catch rather than another try - so it escaped load_project()
    // entirely, skipping System.exit(1) and every bit of code after it,
    // including the "isFileOperationInProgress = false" at this
    // function's own very end.
    //
    // load_project() now treats a null loadXML() result the same as a
    // thrown exception (see loadProject.pde's own comment on this), so
    // a missing file behaves just like the corrupt-file case below:
    // continue_process is set to false up front, the whole restore
    // block is skipped, and load_project() reaches its own normal
    // closing reset. fetchProject() is additionally unaffected because
    // it checks File.isFile() itself first and never reaches
    // load_project() at all for this exact case (see fetchProject()'s
    // own comment) - but any OTHER caller of load_project() with a
    // missing path (the console's own "open" command, in particular)
    // goes through this same fixed path now.
    Path missing = Path.of(app.BaseFolder, "this-file-does-not-exist.xml");
    assertFalse(Files.exists(missing), "sanity check, not the point of this test");
    assertFalse(app.isFileOperationInProgress, "sanity check, not the point of this test");

    assertDoesNotThrow(() -> app.load_project(missing.toString()));

    assertEquals(0, app.allGroups.num, "the model itself is untouched - nothing got as far as restoring it");
    assertEquals(0, app.allFaces.nodes.length);
    assertFalse(app.isFileOperationInProgress, "this path now reaches the normal closing reset, same as the corrupt-file case below");
  }

  @Test
  void loadProject_withACorruptXmlFile_doesNotThrow_andLeavesTheModelUntouched () throws IOException {
    // Unlike the missing-file case just above: genuinely malformed
    // content makes loadXML() itself throw ("Content is not allowed in
    // prolog"), which load_project()'s own try/catch around loadXML()
    // DOES catch, setting continue_process = false - so the entire
    // restore block (parse_XML_variables(), every update_station() call,
    // and the update_frame_layout() NPE every round-trip test in this
    // file hits) is skipped outright, and load_project() reaches its own
    // final "isFileOperationInProgress = false" normally.
    Path corrupt = Files.createTempFile("load-project-corrupt-test", ".xml");
    Files.writeString(corrupt, "this is not XML at all <<<");

    assertDoesNotThrow(() -> app.load_project(corrupt.toString()));

    assertEquals(0, app.allGroups.num);
    assertEquals(0, app.allFaces.nodes.length);
    assertFalse(app.isFileOperationInProgress, "this path DOES reach the normal closing reset, unlike the missing-file case above");
  }

  // ================= saveProject() path handling =========================

  @Test
  void saveProject_convertsBackslashesInTheGivenPath_beforeComputingSaveFolder () throws IOException {
    // saveProject() runs myFile.replace(char(92), '/') before deriving
    // save_folder from it (myFile.substring(0, myFile.lastIndexOf("/")))
    // - a path given with backslashes (as Processing's own native file
    // dialog would hand back on Windows) should still end up with a
    // forward-slash save_folder, not one still containing a literal
    // backslash or - worse - lastIndexOf("/") finding none at all.
    Path dir = Files.createTempDirectory("save-project-backslash-test");
    String backslashPath = dir.toString().replace('/', '\\') + "\\project.xml";

    app.saveProject(backslashPath);

    assertEquals(dir.toString().replace('\\', '/'), app.save_folder);
    assertTrue(Files.exists(dir.resolve("project.xml")), "the file should still have been written, despite the backslash path");
  }

  @Test
  void saveProject_clearsIsFileOperationInProgress_afterWriting () throws IOException {
    Path target = Files.createTempFile("save-project-flag-test", ".xml");
    Files.delete(target);

    app.saveProject(target.toString());

    assertFalse(app.isFileOperationInProgress);
  }

  // ================= buildProjectSnapshot() (in-memory, no disk I/O) =====

  @Test
  void buildProjectSnapshot_returnsXmlNamedWithTheCurrentVersion () {
    // saveProject() itself is just "build the snapshot, then write it" -
    // this confirms the in-memory snapshot buildProjectSnapshot() hands
    // back (also used, unwritten, by anything that only needs an
    // in-memory diff/comparison rather than a real file) carries the
    // same root element name saveXML() would otherwise persist.
    processing.data.XML xml = app.buildProjectSnapshot(true);

    assertEquals("solarchvisionV" + app.version, xml.getName());
    assertNotNull(xml.getChild(app.allFaces.CLASS_STAMP));
    assertNotNull(xml.getChild(app.allPolylines.CLASS_STAMP));
  }
}
