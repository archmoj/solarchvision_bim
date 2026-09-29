import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

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

  // ================= getFiles (real filesystem, via a temp directory) ======

  @Test
  void getFiles_listsEntriesOfAnExistingDirectory () throws java.io.IOException {
    java.io.File dir = java.nio.file.Files.createTempDirectory("opesys-test").toFile();
    try {
      new java.io.File(dir, "a.txt").createNewFile();
      new java.io.File(dir, "b.txt").createNewFile();

      String[] files = app.OPESYS.getFiles(dir.getAbsolutePath());

      assertEquals(2, files.length);
      java.util.Arrays.sort(files);
      assertArrayEquals(new String[]{"a.txt", "b.txt"}, files);
    } finally {
      new java.io.File(dir, "a.txt").delete();
      new java.io.File(dir, "b.txt").delete();
      dir.delete();
    }
  }

  @Test
  void getFiles_returnsAnEmptyArrayForAnEmptyDirectory () throws java.io.IOException {
    java.io.File dir = java.nio.file.Files.createTempDirectory("opesys-test-empty").toFile();
    try {
      String[] files = app.OPESYS.getFiles(dir.getAbsolutePath());
      assertEquals(0, files.length);
    } finally {
      dir.delete();
    }
  }

  @Test
  void getFiles_returnsAnEmptyArrayWhenTheDirectoryDoesNotExist () {
    String[] files = app.OPESYS.getFiles("/this/path/should/not/exist/on/any/machine");
    assertEquals(0, files.length);
  }

  @Test
  void getFiles_returnsAnEmptyArrayWhenGivenAFileInsteadOfADirectory () throws java.io.IOException {
    java.io.File file = java.io.File.createTempFile("opesys-test", ".txt");
    try {
      String[] files = app.OPESYS.getFiles(file.getAbsolutePath());
      assertEquals(0, files.length); // isDirectory() is false, so the early guard never runs dir.list()
    } finally {
      file.delete();
    }
  }
}
