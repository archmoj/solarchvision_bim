import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.File;

// terminalLink()/terminalLinkColor() (uiConsoleBar.pde) build an OSC 8
// terminal hyperlink escape sequence for a file path (the clickable
// "Saving: <path>" links printlnSaving() prints to the console),
// optionally ANSI-colored depending on `control`. Pure string
// concatenation - no drawing, no file I/O beyond File.getAbsolutePath()
// itself (which only resolves a path string; it doesn't touch the
// filesystem). Both were at 0% coverage.
//
// terminalLink()'s own expected fileUri is built the exact same way the
// function itself builds it (new File(path).getAbsolutePath()) rather
// than hardcoded, since the absolute path depends on wherever this test
// suite happens to run from - what's actually being checked is the
// escape-sequence structure around it, not a specific path string.
class TerminalLinkTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void terminalLink_wrapsTheAbsolutePathAndDisplayTextInAnOSC8HyperlinkSequence () {
    String fileUri = "file://" + new File("foo.txt").getAbsolutePath();
    String expected = app.OSC8_START + fileUri + app.OSC8_END + "foo.txt" + app.OSC8_CLOSE;

    assertEquals(expected, app.terminalLink("foo.txt"));
  }

  @Test
  void terminalLink_usesTheGivenPathVerbatimAsTheDisplayText_notJustTheFileName () {
    // linkText is the path as given (the commented-out "file.getName()"
    // alternative is NOT what's used) - a nested path must show in full,
    // not get shortened to its last segment.
    String fileUri = "file://" + new File("some/nested/path.txt").getAbsolutePath();
    String expected = app.OSC8_START + fileUri + app.OSC8_END + "some/nested/path.txt" + app.OSC8_CLOSE;

    assertEquals(expected, app.terminalLink("some/nested/path.txt"));
  }

  @Test
  void terminalLinkColor_withUserGui_wrapsTheLinkInBlackOnYellow () {
    app.control = app.USER_GUI;

    String expected = app.ANSI_BLACK + app.ANSI_YELLOW_BG + app.terminalLink("foo.txt") + app.ANSI_RESET;

    assertEquals(expected, app.terminalLinkColor("foo.txt"));
  }

  @Test
  void terminalLinkColor_withUserAuto_fallsBackToPlainGreenPath_noHyperlinkSequence () {
    // Headless/scripted runs (USER_AUTO) skip the OSC 8 sequence
    // entirely - most terminals that would run a script this way don't
    // render OSC 8 links, so this is a deliberately different, simpler
    // format, not just a different color on the same structure.
    app.control = app.USER_AUTO;

    String expected = app.ANSI_GREEN + "foo.txt" + app.ANSI_RESET;

    assertEquals(expected, app.terminalLinkColor("foo.txt"));
    assertFalse(app.terminalLinkColor("foo.txt").contains(app.OSC8_START), "USER_AUTO must not include the OSC 8 hyperlink escape at all");
  }
}
