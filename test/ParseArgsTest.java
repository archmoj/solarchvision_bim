import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// parseArgs.pde's command-line parsing had no dedicated test and sat at
// 0% coverage (parseArgs() and _useArg() together: 233 missed
// instructions, 46 missed branches). _useArg() is a sequence of
// independent "if (CAP_arg.indexOf(KEYWORD) == 0) {...}" blocks (not an
// if/else-if chain), each guarding a plain field assignment - pure and
// directly callable, except the RUN=<file> branch's actual load
// (loadStrings(), inside "if (!input_str.equals(\"\"))"), which isn't
// exercised here since it needs a real file on disk; everything else -
// including RUN's own keyword-detection and empty-argument guard - is.
class ParseArgsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= parseArgs: the --args sentinel / early-outs ===========

  @Test
  void parseArgs_withNullArgs_doesNothingAndDoesNotThrow () {
    assertDoesNotThrow(() -> app.parseArgs(null));
  }

  @Test
  void parseArgs_withNoArgs_doesNothingAndDoesNotThrow () {
    assertDoesNotThrow(() -> app.parseArgs(new String[0]));
  }

  @Test
  void parseArgs_withoutTheArgsSentinel_processesEveryArgumentFromIndexZero () {
    app.parseArgs(new String[]{"user=auto"});

    assertEquals(app.USER_AUTO, app.control);
  }

  @Test
  void parseArgs_withTheLegacyArgsSentinel_skipsItAndProcessesWhatFollows () {
    // Old processing-java packages sketch args behind a literal "--args"
    // marker (parseArgs.pde's own comment) - must be skipped, not treated
    // as an argument itself.
    app.parseArgs(new String[]{"--args", "user=auto"});

    assertEquals(app.USER_AUTO, app.control);
  }

  @Test
  void parseArgs_processesEveryArgumentInOrder_notJustTheFirst () {
    app.parseArgs(new String[]{"user=auto", "loglevel=2"});

    assertEquals(app.USER_AUTO, app.control);
    assertEquals(2, app.logLevel);
  }

  // ================= _useArg: LOGLEVEL ======================================

  @Test
  void useArg_logLevel_setsItFromTheGivenValue () {
    app._useArg("loglevel=2");

    assertEquals(2, app.logLevel);
  }

  @Test
  void useArg_logLevel_withNoEqualsSign_leavesItUnchanged () {
    app._useArg("loglevel");

    assertEquals(app.LOGLEVEL_GUI_AND_PRINT, app.logLevel, "the default - unchanged, since there's nothing after '='");
  }

  @Test
  void useArg_logLevel_isCaseInsensitive () {
    app._useArg("LogLevel=1");

    assertEquals(1, app.logLevel);
  }

  // ================= _useArg: USER ==========================================

  @Test
  void useArg_user_gui_setsControlAndFillsInAnUnsetLogLevel () {
    app.logLevel = app.LOGLEVEL_IS_NOT_SET;

    app._useArg("user=gui");

    assertEquals(app.USER_GUI, app.control);
    assertEquals(app.LOGLEVEL_GUI_ONLY, app.logLevel);
  }

  @Test
  void useArg_user_auto_setsControlAndFillsInAnUnsetLogLevel () {
    app.logLevel = app.LOGLEVEL_IS_NOT_SET;

    app._useArg("User=Auto"); // mixed case, same as the UI/shell might pass it

    assertEquals(app.USER_AUTO, app.control);
    assertEquals(app.LOGLEVEL_PRINT_ONLY, app.logLevel);
  }

  @Test
  void useArg_user_gui_doesNotOverrideAnAlreadySetLogLevel () {
    app.logLevel = 7; // anything other than LOGLEVEL_IS_NOT_SET

    app._useArg("user=gui");

    assertEquals(app.USER_GUI, app.control);
    assertEquals(7, app.logLevel, "an already-set logLevel must be left alone");
  }

  @Test
  void useArg_user_withAnUnrecognizedValue_changesNeitherControlNorLogLevel () {
    app.control = -999; // a sentinel, not a real USER_GUI/USER_AUTO value
    app.logLevel = 7;

    app._useArg("user=something_else");

    assertEquals(-999, app.control);
    assertEquals(7, app.logLevel);
  }

  // ================= _useArg: SCREEN ========================================

  @Test
  void useArg_screen_setsWidthAndHeightFromTheWxHValue () {
    app._useArg("screen=1024x768");

    assertEquals(1024, app.screenWidth);
    assertEquals(768, app.screenHeight);
  }

  // ================= _useArg: FONTSIZE ======================================

  @Test
  void useArg_fontSize_setsUserPointSize () {
    app._useArg("fontsize=12.5");

    assertEquals(12.5f, app.userPointSize, 0.0001f);
  }

  @Test
  void useArg_fontSize_alsoIncidentallyMatchesTheFontBranch () {
    // Regression/documentation test: "FONTSIZE" itself starts with "FONT",
    // and _useArg()'s keyword checks are independent "if" blocks, not an
    // if/else-if chain - so a "fontsize=..." argument fires BOTH the
    // FONTSIZE block above AND the FONT block below, setting currentFont
    // to the same raw digits too. Pinned here so a future refactor into
    // an if/else-if chain (which would silently stop this from
    // happening) is a deliberate choice, not an accident.
    app._useArg("fontsize=12");

    assertEquals(12.0f, app.userPointSize, 0.0001f);
    assertEquals("12", app.currentFont);
  }

  // ================= _useArg: FONT ==========================================

  @Test
  void useArg_font_replacesHyphensAndUnderscoresWithSpaces () {
    app._useArg("font=Open-Sans_Bold");

    assertEquals("Open Sans Bold", app.currentFont);
  }

  @Test
  void useArg_font_preservesTheOriginalCase_unlikeEveryOtherKeyword () {
    // Every other branch above reads its value off CAP_arg (the
    // upper-cased argument) - FONT is the one exception, reading the
    // font name off the original `arg` so casing survives, e.g. for a
    // real font family name like "DejaVu Sans".
    app._useArg("font=Lower-Case_Name");

    assertEquals("Lower Case Name", app.currentFont, "must not be upper-cased, unlike LOGLEVEL/USER/SCREEN/FONTSIZE");
  }

  // ================= _useArg: RUN ===========================================

  @Test
  void useArg_run_withNoEqualsSign_doesNotAttemptToLoadAnything () {
    // "run" alone (no "=") - split() on it yields a single-element array,
    // so the length > 1 guard must keep this from ever reaching
    // queuePendingScriptLines()/loadStrings() at all. Mainly a
    // does-not-throw check, since there's nothing externally observable
    // to assert on here without a real file.
    assertDoesNotThrow(() -> app._useArg("run"));
  }

  // ================= _useArg: no keyword matches at all =====================

  @Test
  void useArg_withAnUnrecognizedKeyword_changesNothing () {
    app.control = -999;
    app.logLevel = 7;
    app.screenWidth = 111;
    app.screenHeight = 222;
    app.userPointSize = 3.5f;
    String fontBefore = app.currentFont;

    app._useArg("notareal=keyword");

    assertEquals(-999, app.control);
    assertEquals(7, app.logLevel);
    assertEquals(111, app.screenWidth);
    assertEquals(222, app.screenHeight);
    assertEquals(3.5f, app.userPointSize, 0.0001f);
    assertEquals(fontBefore, app.currentFont);
  }
}
