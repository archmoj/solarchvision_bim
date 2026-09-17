import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

// Exercises solarchvision_OperatingSystem.getFilenameFromPath
// (OperatingSystem.pde) - it builds a java.io.File from the given path
// and takes the text before the first "." in its name, but never
// actually touches the filesystem (File's constructor doesn't require
// the path to exist), so it's safe to call on made-up paths. Reached
// through the pre-constructed `app.OPESYS` field.
//
// getFiles(), the other method in this file, does real directory
// listing (File.list()) and isn't covered here - that's an integration
// concern, not a pure-logic one.
class OperatingSystemTest {

  private static solarchvision_bim app;

  @BeforeAll
  static void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void getFilenameFromPath_stripsTheDirectoryAndExtension () {
    assertEquals("c", app.OPESYS.getFilenameFromPath("/a/b/c.txt"));
  }

  @Test
  void getFilenameFromPath_takesOnlyTheTextBeforeTheFirstDot () {
    // split() on '.' and taking [0] means a multi-dot name like
    // "archive.tar.gz" stops at the first dot, not the last.
    assertEquals("archive", app.OPESYS.getFilenameFromPath("/a/b/archive.tar.gz"));
  }

  @Test
  void getFilenameFromPath_returnsTheWholeNameWhenThereIsNoDot () {
    assertEquals("README", app.OPESYS.getFilenameFromPath("/a/b/README"));
  }

  @Test
  void getFilenameFromPath_worksOnABarePathWithNoDirectory () {
    assertEquals("notes", app.OPESYS.getFilenameFromPath("notes.md"));
  }
}
