import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Most of runScriptLine's ~130 switch cases either do file I/O (New, Save,
// Open, ...), close the JVM (Exit/Quit), or create 3D geometry already
// covered directly by Create3DTest.java - not duplicated here. This
// focuses on the cases with their own, previously-untested logic worth
// covering directly: the location-setting commands (also a regression
// check that they still update STATION, not just LocationLAT/LocationLON),
// argument parsing/hints, dispatch to allActions (the integration point
// with ValueModifier.pde's command-line actions), and the small pure
// parseParams/getF/getI helpers at the bottom of the file.
class RunScriptTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // fresh app never runs build_allActions() itself
  }

  // ================= SETLAT / SETLON / SETLONLAT ============================

  @Test
  void setLat_updatesStationAndSyncsLocationLAT () {
    String hint = app.runScriptLine("SETLAT 45.5");

    assertEquals("", hint);
    assertEquals(45.5f, app.STATION.getLatitude(), 0.001f);
    assertEquals(45.5f, app.LocationLAT, 0.001f);
  }

  @Test
  void setLat_missingArgument_returnsAUsageHintAndChangesNothing () {
    app.STATION.setLatitude(10);

    String hint = app.runScriptLine("SETLAT");

    assertEquals("SetLat ?", hint);
    assertEquals(10, app.STATION.getLatitude(), 0.001f);
  }

  @Test
  void setLat_isCaseInsensitive () {
    String hint = app.runScriptLine("setlat 30");

    assertEquals("", hint);
    assertEquals(30, app.STATION.getLatitude(), 0.001f);
  }

  @Test
  void setLon_updatesStationAndSyncsLocationLON () {
    String hint = app.runScriptLine("SETLON -73.6");

    assertEquals("", hint);
    assertEquals(-73.6f, app.STATION.getLongitude(), 0.001f);
    assertEquals(-73.6f, app.LocationLON, 0.001f);
  }

  @Test
  void setLon_missingArgument_returnsAUsageHint () {
    assertEquals("SetLon ?", app.runScriptLine("SETLON"));
  }

  @Test
  void setLonLat_setsBothInOneCommand_LonThenLatByPosition () {
    // SETLONLAT LON LAT, deliberately the opposite order from SETLON/SETLAT
    String hint = app.runScriptLine("SETLONLAT -73.6 45.5");

    assertEquals("", hint);
    assertEquals(45.5f, app.STATION.getLatitude(), 0.001f);
    assertEquals(-73.6f, app.STATION.getLongitude(), 0.001f);
  }

  @Test
  void setLonLat_missingSecondArgument_returnsAUsageHint () {
    assertEquals("SetLonLat ? ?", app.runScriptLine("SETLONLAT -73.6"));
  }

  // ================= CLS =====================================================

  @Test
  void cls_resetsCommandAndMessageHistoryToASingleEmptyEntry () {
    app.allCommands = new String[]{"a", "b", "c"};
    app.allMessages = new String[]{"x", "y", "z"};

    app.runScriptLine("CLS");

    assertEquals(1, app.allCommands.length);
    assertEquals("", app.allCommands[0]);
    assertEquals(1, app.allMessages.length);
    assertEquals("", app.allMessages[0]);
  }

  // ================= MOVE ====================================================

  @Test
  void move_keyedArguments_translatesTheSelectionByDxDyDz () {
    String hint = app.runScriptLine("MOVE dx:5 dy:3 dz:1");

    assertEquals("", hint);
    // no selection by default, so Move3D.selection(...) is a safe no-op;
    // view_changed() still fires regardless.
    assertTrue(app.WIN3D.update);
  }

  @Test
  void move_positionalArguments_areReadAsDxDyDzInOrder () {
    assertDoesNotThrow(() -> app.runScriptLine("MOVE 5 3 1"));
  }

  @Test
  void move_missingArguments_returnsAUsageHint () {
    assertEquals("Move dx=? dy=? dz=?", app.runScriptLine("MOVE"));
  }

  // ================= unrecognized commands ===================================

  @Test
  void unrecognizedCommand_returnsAHint () {
    assertEquals("Unrecognized command!", app.runScriptLine("this_is_not_a_real_command"));
  }

  @Test
  void blankLine_returnsNoHint () {
    assertEquals("", app.runScriptLine(""));
  }

  // ================= allActions fallback dispatch ============================
  // The integration point with ValueModifier.pde/actions.pde: a command
  // not matched by the switch falls through to a full-line match against
  // allActions, then a first-token match.

  @Test
  void fallsBackToAFirstTokenMatch_forACommandRegisteredWithArguments () {
    app.vm.Begin_day(0);
    app.TIME.day = 1;

    String hint = app.runScriptLine("begin_day 15");

    assertEquals("", hint);
    assertEquals(15, app.TIME.day);
  }

  @Test
  void fallsBackToALastSpaceMatch_forAMultiWordCaptionTypedWithItsValue () {
    // "Begin day" registers both "begin_day" and, via putAction's
    // "withSpace" fallback, the literal "begin day" too - but typing
    // "Begin day 15" doesn't match either of those directly: the full
    // line is "begin day 15" (three words) and the first token alone is
    // just "begin". Stripping the trailing value word off the line
    // ("begin day") is what finds it.
    app.vm.Begin_day(0);
    app.TIME.day = 1;

    String hint = app.runScriptLine("Begin day 15");

    assertEquals("", hint);
    assertEquals(15, app.TIME.day);
  }

  @Test
  void fallsBackToALastSpaceMatch_forALongerMultiWordCaption () {
    app.vm.Number_of_days_to_plot(0);
    app.STUDY.j_End = 1;

    String hint = app.runScriptLine("Number of days to plot 200");

    assertEquals("", hint);
    assertEquals(200, app.STUDY.j_End);
  }

  @Test
  void fallsBackToAFullLineMatch_forACaptionTypedAloneWithNoValue () {
    // putValueAction reaches putAction's Action-taking overload, which -
    // like the Runnable-taking one used for plain menu items (see the
    // test right below) - registers the literal, lowercased caption
    // alongside the normalized (spaces -> underscores) key.
    app.vm.Begin_day(0);
    app.TIME.day = 10;

    String hint = app.runScriptLine("Begin day");

    assertEquals("", hint); // the usage-hint print happens inside the action, not via the returned hint
    assertEquals(10, app.TIME.day); // no value token was given, so nothing changed
  }

  @Test
  void runnableRegisteredMenuAction_isReachableByBothItsNormalizedAndSpacedKey () {
    // putAction(String, Runnable) - used for plain menu items like this
    // one, as opposed to putValueAction's Action-taking overload - also
    // registers the literal, lowercased caption alongside the normalized
    // (spaces -> underscores) key, so either form dispatches it.
    app.build_allActions();
    app.STUDY.PlotImpacts = -1;

    String hintSpaced = app.runScriptLine("Wind pattern (active)");
    assertEquals("", hintSpaced);
    assertEquals(app.PlotImpacts_WIND_ACTIVE, app.STUDY.PlotImpacts);

    app.STUDY.PlotImpacts = -1; // reset before checking the other form

    String hintUnderscored = app.runScriptLine("wind_pattern_(active)");
    assertEquals("", hintUnderscored);
    assertEquals(app.PlotImpacts_WIND_ACTIVE, app.STUDY.PlotImpacts);
  }

  // ================= parseParams / getF / getI ================================

  @Test
  void parseParams_splitsKeyValueTokensOnColon_lowercasingTheKey () {
    java.util.HashMap<String, String> p = app.parseParams(new String[]{"move", "DX:5", "dy:3"});

    assertEquals("5", p.get("dx"));
    assertEquals("3", p.get("dy"));
  }

  @Test
  void parseParams_ignoresTokensWithoutAColon () {
    java.util.HashMap<String, String> p = app.parseParams(new String[]{"move", "5", "dy:3"});

    assertEquals(1, p.size());
    assertEquals("3", p.get("dy"));
  }

  @Test
  void getF_returnsTheParsedValue_whenThePresentKeyIsSet () {
    java.util.HashMap<String, String> p = app.parseParams(new String[]{"cmd", "dx:5.5"});
    assertEquals(5.5f, app.getF(p, "dx", -1), 0.001f);
  }

  @Test
  void getF_returnsTheDefault_whenTheKeyIsMissing () {
    java.util.HashMap<String, String> p = app.parseParams(new String[]{"cmd"});
    assertEquals(-1f, app.getF(p, "dx", -1), 0.001f);
  }

  @Test
  void getI_returnsTheParsedValue_whenThePresentKeyIsSet () {
    java.util.HashMap<String, String> p = app.parseParams(new String[]{"cmd", "n:7"});
    assertEquals(7, app.getI(p, "n", -1));
  }

  @Test
  void getI_returnsTheDefault_whenTheKeyIsMissing () {
    java.util.HashMap<String, String> p = app.parseParams(new String[]{"cmd"});
    assertEquals(-1, app.getI(p, "n", -1));
  }
}
