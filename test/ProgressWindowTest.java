import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

// New this session: ProgressWindow's leading-"\n"-stripping constructor
// behavior, its setFocusableWindowState(false) call, and
// echoAbortProgress()'s own fixed console message (progressWindow.pde -
// see that file's own comments for why each exists). None of this was
// covered by any existing test - confirmed via grep, no existing test
// ever constructs a real ProgressWindow (ImportObjectsOBJTest.java/
// ImportObjectsIFCTest.java only ever check canShowProgressWindow()
// against GraphicsEnvironment.isHeadless() directly, never a real
// instance).
//
// Constructing a real ProgressWindow throws java.awt.HeadlessException
// in a headless CI run (same reasoning as canShowProgressWindow()'s own
// comment) - every test below that needs a real instance guards itself
// with a plain `if (isHeadless()) return;` at the top, the same idiom
// used elsewhere in this suite, rather than Assumptions (not available
// in test/fallback-junit/ - see its own README).
class ProgressWindowTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  private boolean isHeadless () {
    return java.awt.GraphicsEnvironment.isHeadless();
  }

  // ========================= echoAbortProgress() ==========================
  // No display needed for this one - it's a plain println(), same as any
  // other console-only helper in this file. Captures/restores System.out
  // with a plain try/finally rather than @BeforeEach/@AfterEach -
  // test/fallback-junit/ (its own README) doesn't implement @AfterEach at
  // all, despite one existing test file (ConsolePrintHelpersTest.java)
  // already assuming it is; try/finally keeps this new file working
  // under either the real jar or the fallback stub.

  @Test
  void echoAbortProgress_printsTheExactExpectedMessage () {
    PrintStream originalOut = System.out;
    ByteArrayOutputStream capturedOut = new ByteArrayOutputStream();
    System.setOut(new PrintStream(capturedOut));

    try {
      app.echoAbortProgress();
    } finally {
      System.setOut(originalOut);
    }

    assertEquals("Aborted by Esc." + System.lineSeparator(), capturedOut.toString());
  }

  // ===================== Constructor: leading "\n" stripping ==============
  // Every caller passes the same label text it also println()s to the
  // console with a leading "\n" (so the console print starts on a fresh
  // line) - but drawString() (paint(), below in progressWindow.pde) would
  // render that "\n" as a stray glyph instead of a line break, so the
  // constructor strips exactly one leading "\n", once, rather than
  // requiring every call site to maintain two separate label strings.

  @Test
  void constructor_stripsExactlyOneLeadingNewline () {
    if (isHeadless()) return;

    solarchvision_bim.ProgressWindow win = app.new ProgressWindow("\nVertex Solar Potential");
    try {
      assertEquals("Vertex Solar Potential", win.label);
    } finally {
      win.dispose();
    }
  }

  @Test
  void constructor_leavesALabelWithNoLeadingNewlineUnchanged () {
    if (isHeadless()) return;

    solarchvision_bim.ProgressWindow win = app.new ProgressWindow("Vertex Solar Potential");
    try {
      assertEquals("Vertex Solar Potential", win.label);
    } finally {
      win.dispose();
    }
  }

  @Test
  void constructor_stripsOnlyTheOneLeadingNewline_notAnyOthers () {
    if (isHeadless()) return;

    // Only the leading "\n" is special-cased - an embedded one further
    // in has no reason to be stripped (and isn't).
    solarchvision_bim.ProgressWindow win = app.new ProgressWindow("\nLine one\nLine two");
    try {
      assertEquals("Line one\nLine two", win.label);
    } finally {
      win.dispose();
    }
  }

  // ===================== Constructor: non-focusable window ================
  // Re-added this session specifically so a click or Alt+Tab reaching
  // this window can never give it real OS keyboard focus, which would
  // otherwise route real keystrokes (Esc included) away from the main
  // sketch's own NEWT window - see the constructor's own comment.

  @Test
  void constructor_setsFocusableWindowStateToFalse () {
    if (isHeadless()) return;

    solarchvision_bim.ProgressWindow win = app.new ProgressWindow("Test");
    try {
      assertFalse(win.isFocusableWindow());
    } finally {
      win.dispose();
    }
  }
}
