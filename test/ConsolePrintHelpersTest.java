import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.AfterEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.io.File;

// printlnSaving()/printSameLine() (uiConsoleBar.pde) are pure
// console-output helpers - println()/print() ultimately write to
// System.out, with no drawing or file I/O involved - captured here the
// standard JUnit way (swap System.out for a ByteArrayOutputStream around
// each call, restore it in @AfterEach even if the test fails). Both were
// at 0% coverage.
class ConsolePrintHelpersTest {

  private solarchvision_bim app;
  private final PrintStream realOut = System.out;
  private ByteArrayOutputStream captured;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    captured = new ByteArrayOutputStream();
    System.setOut(new PrintStream(captured));
  }

  @AfterEach
  void tearDown () {
    System.setOut(realOut);
  }

  // ================= printlnSaving ===========================================

  @Test
  void printlnSaving_printsALeadingBlankLineThenTheSavingLabelAndTerminalLinkColorPath () {
    app.control = app.USER_GUI; // terminalLinkColor()'s own OSC 8 branch - see TerminalLinkTest.java

    app.printlnSaving("foo.txt");

    String out = captured.toString();
    String expectedLink = app.terminalLinkColor("foo.txt");

    assertEquals("\nSaving: " + expectedLink + "\n", out);
  }

  @Test
  void printlnSaving_inUserAutoMode_printsThePlainGreenPathForm () {
    app.control = app.USER_AUTO; // terminalLinkColor()'s own plain-path branch

    app.printlnSaving("foo.txt");

    String out = captured.toString();
    String expectedLink = app.terminalLinkColor("foo.txt");

    assertEquals("\nSaving: " + expectedLink + "\n", out);
    assertFalse(out.contains(app.OSC8_START), "USER_AUTO must not include the OSC 8 hyperlink escape at all - see TerminalLinkTest.java");
  }

  // ================= printSameLine ===========================================

  @Test
  void printSameLine_padsShortTextWithSpacesToFillTerminalWidth () {
    app.terminalWidth = 10;

    app.printSameLine("abc");

    assertEquals("\rabc       ", captured.toString()); // "abc" + 7 spaces = 10 chars
  }

  @Test
  void printSameLine_leavesTextAtOrAboveTerminalWidthUnpadded () {
    app.terminalWidth = 3;

    app.printSameLine("abcde");

    assertEquals("\rabcde", captured.toString(), "no padding added when there's no room left");
  }

  @Test
  void printSameLine_withTextExactlyAtTerminalWidth_addsNoPadding () {
    app.terminalWidth = 5;

    app.printSameLine("abcde");

    assertEquals("\rabcde", captured.toString());
  }

  @Test
  void printSameLine_overwritesThePreviousLineViaACarriageReturn_notANewline () {
    app.terminalWidth = 3;

    app.printSameLine("one");
    app.printSameLine("two");

    assertEquals("\rone\rtwo", captured.toString(), "each call starts with \\r, never \\n - that's what makes it overwrite in place");
  }
}
