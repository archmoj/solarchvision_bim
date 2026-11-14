import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// _fileSelected_ImportStl() (fileSelected.pde) was untested - 121
// instructions. It's the real callback Processing's native file chooser
// invokes once the user picks a file (or cancels): it wraps
// import_objects_STL() - already directly, thoroughly tested in
// ImportObjectsSTLTest.java - with the group-tracking/selection/
// isImportingInProgress bookkeeping every one of the 6 _fileSelected_
// Import*() siblings shares (confirmed by reading _fileSelected_ImportGlb()
// too - identical shape, just a different importer function). What's
// new here is confirming this wrapper drives that whole sequence
// correctly, including its own "the user cancelled the dialog"
// (selectedFile == null) branch - not re-verifying import_objects_STL()
// itself, which is this file's own ASCII-STL construction pattern,
// reused directly rather than reinvented.
class FileSelectedImportStlTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws IOException {
    app = new solarchvision_bim();
    // See Earth3DTest.java's/ImportObjectsSTLTest.java's own comment on
    // why this isn't app.locateBaseFolder().
    app.BaseFolder = Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath();
  }

  private Path stlFile (String name, String body) throws IOException {
    Path f = Files.createTempFile(name, ".stl");
    Files.writeString(f, body);
    return f;
  }

  @Test
  void aRealFile_importsIt_andLeavesTheNewGroupSelected () throws IOException {
    Path f = stlFile("fileselected-stl-triangle-test", """
        solid test
        facet normal 0 0 1
          outer loop
            vertex 0 0 0
            vertex 1 0 0
            vertex 1 1 0
          endloop
        endfacet
        endsolid test
        """
    );

    app._fileSelected_ImportStl(f.toFile());

    assertEquals(3, app.allPoints.getLength());
    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
    // Two, not one: _fileSelected_ImportStl()'s own "if (allGroups.num
    // == 0) beginNewGroup(...)" guard fires first (the scene starts
    // empty), and import_objects_STL() itself unconditionally calls
    // allGroups.beginNewGroup() again (addToLastGroup's own bare-
    // construction default is false) - confirmed by reading
    // importStl.pde directly, not assumed.
    assertEquals(2, app.allGroups.num);
    // number_of_allGroups_before is captured AFTER the outer guard's own
    // beginNewGroup (so 1, not 0), and the fill loop's own bound is
    // "length - 1", not "length" - for this 2-element array only index
    // 0 ever gets written (0 + number_of_allGroups_before = 1); index 1
    // is left at Java's own int array default, 0. Read directly from
    // fileSelected.pde, not assumed.
    assertArrayEquals(new int[]{1, 0}, app.Select3D.groupSelection);
    assertEquals(app.ObjectCategory.GROUP, app.currentObjectCategory);
    assertFalse(app.isImportingInProgress, "must be reset once the whole import finishes");
  }

  @Test
  void aCancelledDialog_doesNothing () {
    app.stlImportShowOptionsDialog = true; // sentinel - must be cleared
    app.isImportingInProgress = true; // sentinel - must be cleared

    assertDoesNotThrow(() -> app._fileSelected_ImportStl(null));

    assertFalse(app.stlImportShowOptionsDialog);
    assertFalse(app.isImportingInProgress);
    assertEquals(0, app.allFaces.nodes.length, "nothing must have been imported");
  }
}
