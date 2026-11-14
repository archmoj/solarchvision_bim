import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// RunScriptTest.java's own header comment explains why it skips most of
// runScriptLine's file-I/O commands (New, Save, Open, ...): many of them
// fall back to a real native file-picker dialog when called with no
// path, which isn't something to trigger in a test. This file covers
// the handful of extraCommands.pde file-I/O wrappers that are safe to
// call directly all the same - either because they never open a dialog
// at all (the EXPORT.* commands always write straight to a known,
// computed path) or because a path is always given as part of the typed
// command (IMPORT.OBJ <path>), which is the one argument form that
// reaches _fileSelected_ImportObj(File) directly instead - plus CLS and
// EXIT, two simple, already-safe commands that just never came up in
// RunScriptTest.java's own file.
//
// Like RunScriptTest.java's own setUp(), every test below but one uses a
// fresh, EMPTY allActions map, not the real, populated one (build_
// allActions() is never called) - this isolates the switch-case wiring
// itself from allActions ever matching first and never reaching it.
//
// The one exception is this file's own "SAVE command collision" section
// at the bottom, which deliberately DOES call the real build_allActions()
// - to confirm a genuine, surprising finding: with the real action set
// loaded, exactly as the production app always has it, "SAVE <path>"
// does NOT write to the given path at all. Confirmed directly against
// the real compiled app, not assumed from reading the dispatch code.
class ScriptCommandFileIOTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    app.Terrain.Mesh = new float[app.Terrain.rowCount][app.Terrain.columnCount][3];
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
    // See SaveProjectTest.java's own comment: Folder_Project is null
    // until reset_project_folder_to_default() runs; update_project_folders()
    // itself no longer sets it (updateFolders.pde's own fix).
    app.reset_project_folder_to_default();
    app.update_project_folders();
    app.update_input_folders();

    app.allActions = new java.util.HashMap<>(); // fresh app never runs build_allActions() itself - same as RunScriptTest.java's own setUp()
  }

  // ================= EXPORT.* ==============================================
  // None of these ever open a dialog - each wraps a function this suite
  // already tests directly and in depth (ExportObjectsOBJTest.java,
  // ExportObjectsLASTest.java, ExportRadianceTest.java,
  // ExportAutocadScriptTest.java), so these only confirm the SCRIPT
  // COMMAND itself reaches that function - not re-testing the export
  // logic a second time.

  @Test
  void exportObjCommand_writesARealObjFile () {
    app.runScriptLine("EXPORT.OBJ");

    Path expected = Path.of(app.Folder_Export3D, app.ProjectName + ".obj");
    assertTrue(Files.exists(expected), "expected " + expected + " to exist");
  }

  @Test
  void exportLasCommand_writesARealLasFile () {
    app.runScriptLine("EXPORT.LAS");

    Path expected = Path.of(app.Folder_Export3D, app.ProjectName + ".las");
    assertTrue(Files.exists(expected), "expected " + expected + " to exist");
  }

  @Test
  void exportRadCommand_writesBothTheRadAndBatFiles () {
    app.runScriptLine("EXPORT.RAD");

    assertTrue(Files.exists(Path.of(app.Folder_Export3D, app.ProjectName + ".rad")));
    assertTrue(Files.exists(Path.of(app.Folder_Export3D, app.ProjectName + ".bat")));
  }

  @Test
  void exportScrCommand_writesARealScrFile () {
    app.runScriptLine("EXPORT.SCR");

    Path expected = Path.of(app.Folder_Export3D, app.ProjectName + ".scr");
    assertTrue(Files.exists(expected), "expected " + expected + " to exist");
  }

  // ================= IMPORT.OBJ <path> ====================================
  // "IMPORT.OBJ" (the switch-case label, a literal dot) and "Import OBJ"
  // (the bare menu action registered in actions.pde, a literal space)
  // are different strings even once both are lowercased - so, unlike
  // SAVE below, there's no collision to worry about here even with a
  // real, populated allActions map. An empty one is used anyway, for
  // consistency with every other test in this file.

  @Test
  void importObjCommand_withAPath_reachesFileSelectedImportObj () throws IOException {
    // Same minimal, valid OBJ fixture as FileSelectedTest.java's own
    // fileSelectedImportObj_withAFile_... test.
    Path objFile = Files.createTempFile("script-command-import-obj-test", ".obj");
    Files.writeString(objFile, """
        g triangle
        v 0 0 0
        v 1 0 0
        v 1 1 0
        f 1 2 3
        """
    );

    app.runScriptLine("IMPORT.OBJ " + objFile);

    assertEquals(2, app.allGroups.num, "one placeholder group, plus the \"g triangle\" one - see FileSelectedTest.java's own identical comment");
    assertEquals(3, app.allPoints.getLength());
    assertEquals(1, app.allFaces.nodes.length);
  }

  // ================= CLS / EXIT ===========================================

  @Test
  void clsCommand_emptiesTheConsoleCommandHistory () {
    app.UI_consoleBar.allCommands.add("something typed earlier");

    app.runScriptLine("CLS");

    assertEquals(1, app.UI_consoleBar.allCommands.size());
    assertEquals("", app.UI_consoleBar.allCommands.get(0));
  }

  @Test
  void exitCommand_resetsTypeUserCommandToZero () {
    app.typeUserCommand = 5;

    app.runScriptLine("EXIT");

    assertEquals(0, app.typeUserCommand);
  }

  // ================= the SAVE command collision (fixed) ====================
  // Was a real, confirmed bug, not a hypothetical: with the real action
  // set loaded (build_allActions(), exactly as the production app always
  // has it by the time anyone can type a command at all), typing
  // "SAVE <path>" used to not write to that path at all - or even reach
  // __SAVE__ in extraCommands.pde.
  //
  // runScriptDispatch.pde's own resolveAction() lowercases the WHOLE
  // typed line first and tries it, with its trailing word stripped off,
  // against allActions before the switch-case ever runs (its own
  // matchTrailingWordRemoved(), tier 2) - actions.pde registers a bare,
  // zero-argument "Save" action (putAction("Save", ...), saving to the
  // project's own default path) that matches that stripped-down line.
  // bypassAllActionsFor (runScriptDispatch.pde's own exception list for
  // exactly this kind of collision) now includes "save" (along with
  // "new"/"open"/"save as"/every "import *" - each has the identical
  // shape: its own menu-caption action ignores any argument, "new"'s/
  // "open"'s/"import *"'s own versions by popping up a real, blocking
  // file dialog instead of merely picking the wrong destination the way
  // "save" did), so "SAVE /some/given/path.xml" now correctly reaches
  // __SAVE__'s own switch-case, which does use the given path.
  @Test
  void saveCommand_withARealActionSet_usesTheGivenPath () {
    app.build_allActions();

    Path customPath = app.BaseFolder != null ? Path.of(app.BaseFolder, "custom-save-target.xml") : null;
    assertNotNull(customPath, "sanity check, not the point of this test");

    app.runScriptLine("SAVE " + customPath);

    assertTrue(Files.exists(customPath), "the explicitly given path must now be written to");
    Path defaultPath = Path.of(app.Folder_Project, app.ProjectName + ".xml");
    assertFalse(Files.exists(defaultPath), "the bare \"Save\" action's own fixed default path must NOT be used when a real path was given");
  }
}
