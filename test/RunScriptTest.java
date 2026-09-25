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

  // ================= Delete All-<Category> regression =======================
  // Previously "Delete All Model2Ds" (now "Delete All-Model2Ds") reached the
  // DELETE switch-case, whose per-token loop treated "all" and "model2ds" as
  // two *independent* instructions - "all" alone triggers deleteAll(), which
  // wipes every category, not just the one named. Registering the full
  // caption as its own action, and checking allActions *before* the switch
  // (see the top of runScriptLine), means the line now matches that one
  // dedicated action directly and never reaches the switch-case's loop at
  // all. Each case below seeds the named category's own count field
  // directly (verified safe: every makeEmpty(0) below only ever *sets*
  // count/array fields, never reads their old value first) and an
  // unrelated category, then checks only the named one actually got
  // cleared.

  @Test
  void deleteAllDashModel2Ds_onlyClearsModel2Ds () {
    app.build_allActions(); // registers "Delete All-Model2Ds" itself - needed to reach it at all
    app.allModel2Ds.num = 1;
    app.allFaces.nodes = new int[1][4]; // unrelated category, seeded independently

    String hint = app.runScriptLine("Delete All-Model2Ds");

    assertNotEquals("Unrecognized command!", hint);
    assertEquals(0, app.allModel2Ds.num, "the named category should actually be cleared");
    assertEquals(1, app.allFaces.nodes.length, "an unrelated category must not be touched");
  }

  @Test
  void deleteAllDashModel1Ds_onlyClearsModel1Ds () {
    app.build_allActions();
    app.allModel1Ds.num = 1;
    app.allFaces.nodes = new int[1][4];

    String hint = app.runScriptLine("Delete All-Model1Ds");

    assertNotEquals("Unrecognized command!", hint);
    assertEquals(0, app.allModel1Ds.num);
    assertEquals(1, app.allFaces.nodes.length);
  }

  @Test
  void deleteAllDashGroups_onlyClearsGroups () {
    app.build_allActions();
    app.allGroups.num = 1;
    app.allFaces.nodes = new int[1][4];

    String hint = app.runScriptLine("Delete All-Groups");

    assertNotEquals("Unrecognized command!", hint);
    assertEquals(0, app.allGroups.num);
    assertEquals(1, app.allFaces.nodes.length);
  }

  @Test
  void deleteAllDashSections_onlyClearsSections () {
    app.build_allActions();
    app.allSections.num = 1;
    app.allFaces.nodes = new int[1][4];

    String hint = app.runScriptLine("Delete All-Sections");

    assertNotEquals("Unrecognized command!", hint);
    assertEquals(0, app.allSections.num);
    assertEquals(1, app.allFaces.nodes.length);
  }

  @Test
  void deleteAllDashFaces_onlyClearsFaces () {
    app.build_allActions();
    app.allFaces.nodes = new int[1][4];
    app.allPolylines.nodes = new int[1][2]; // unrelated category this time

    String hint = app.runScriptLine("Delete All-Faces");

    assertNotEquals("Unrecognized command!", hint);
    assertEquals(0, app.allFaces.nodes.length, "the named category should actually be cleared");
    assertEquals(1, app.allPolylines.nodes.length, "an unrelated category must not be touched");
  }

  @Test
  void deleteAllDashPolylines_onlyClearsPolylines () {
    app.build_allActions();
    app.allPolylines.nodes = new int[1][2];
    app.allFaces.nodes = new int[1][4];

    String hint = app.runScriptLine("Delete All-Polylines");

    assertNotEquals("Unrecognized command!", hint);
    assertEquals(0, app.allPolylines.nodes.length);
    assertEquals(1, app.allFaces.nodes.length);
  }

  @Test
  void deleteAllDashSolids_onlyClearsSolids () {
    app.build_allActions();
    app.allSolids.DEF = new float[1][13];
    app.allFaces.nodes = new int[1][4];

    String hint = app.runScriptLine("Delete All-Solids");

    assertNotEquals("Unrecognized command!", hint);
    assertEquals(0, app.allSolids.DEF.length, "the named category should actually be cleared");
    assertEquals(1, app.allFaces.nodes.length, "an unrelated category must not be touched");
  }

  @Test
  void deleteAllDashCameras_onlyClearsTheAddedCamera () {
    // Cameras.makeEmpty(0) always ends by re-adding the default "Free
    // Viewport" camera (add_first()), so the count can never reach 0 - a
    // fresh app already starts at 1 for that reason. To make this a
    // meaningful check, add one extra camera first and confirm the count
    // goes back down to exactly that unavoidable 1, not stays at 2.
    app.build_allActions();
    app.allCameras.add_first();
    assertEquals(2, app.allCameras.num, "sanity check: the extra camera was actually added");
    app.allFaces.nodes = new int[1][4];

    String hint = app.runScriptLine("Delete All-Cameras");

    assertNotEquals("Unrecognized command!", hint);
    assertEquals(1, app.allCameras.num, "back to just the one camera every Cameras instance always keeps");
    assertEquals(1, app.allFaces.nodes.length, "an unrelated category must not be touched");
  }

  // ================= Select All-<Category> =====================================
  // Less severe than Delete's bug (Select3D.selectAll() only ever acts on
  // whichever category is current, so the old dispatch order happened to
  // still switch to the right category first), but still worth locking in
  // now that these go through their own dedicated action.

  @Test
  void selectAllDashModel2Ds_switchesToTheModel2DCategory () {
    app.build_allActions();
    String hint = app.runScriptLine("Select All-Model2Ds");
    assertNotEquals("Unrecognized command!", hint);
    assertEquals(app.ObjectCategory.MODEL2D, app.current_ObjectCategory);
  }

  @Test
  void selectAllDashSolids_switchesToTheSolidCategory () {
    app.build_allActions();
    String hint = app.runScriptLine("Select All-Solids");
    assertNotEquals("Unrecognized command!", hint);
    assertEquals(app.ObjectCategory.SOLID, app.current_ObjectCategory);
  }

  @Test
  void selectAllDashCameras_switchesToTheCameraCategory () {
    app.build_allActions();
    String hint = app.runScriptLine("Select All-Cameras");
    assertNotEquals("Unrecognized command!", hint);
    assertEquals(app.ObjectCategory.CAMERA, app.current_ObjectCategory);
  }

  // ================= other renamed "All-*" actions ===========================

  @Test
  void hideAllDashFaces_isRecognized () {
    app.build_allActions();
    assertNotEquals("Unrecognized command!", app.runScriptLine("Hide All-Faces"));
  }

  @Test
  void unhideAllDashFaces_isRecognized () {
    app.build_allActions();
    assertNotEquals("Unrecognized command!", app.runScriptLine("Unhide All-Faces"));
  }

  @Test
  void reverseVisibilityOfAllDashFaces_isRecognized () {
    app.build_allActions();
    assertNotEquals("Unrecognized command!", app.runScriptLine("Reverse Visibility of All-Faces"));
  }

  // ================= MOVE / ROTATE / SCALE / creation commands ===============
  // Fixed regression: these switch-case commands take real parameters, but
  // each also has a bare, zero-argument menu action of the same name (e.g.
  // "Move" switches the active move tool - see UI_setTo_Modify_Move). Once
  // build_allActions() has run (as it always has by the time a person can
  // type into the console - see draw_initial_frames.pde), the allActions
  // lookup would otherwise match that bare action by first token before
  // ever reaching the switch-case that reads the parameters or prints a
  // usage hint without them. bypassAllActionsFor (top of runScript.pde)
  // routes these specific names straight to the switch-case, restoring
  // both behaviors.

  @Test
  void move_withArguments_actuallyMovesRatherThanJustSwitchingTheTool () {
    app.build_allActions();
    app.WIN3D.UI_CurrentTask = -1;
    app.WIN3D.update = false;

    String hint = app.runScriptLine("MOVE dx:5 dy:3 dz:1");

    assertEquals("", hint);
    assertEquals(-1, app.WIN3D.UI_CurrentTask, "must not just switch the move tool");
    assertTrue(app.WIN3D.update, "view_changed() should fire for a real move");
  }

  @Test
  void move_withNoArguments_returnsTheUsageHint_notTheBareToolSwitch () {
    app.build_allActions();
    assertEquals("Move dx=? dy=? dz=?", app.runScriptLine("MOVE"));
  }

  @Test
  void rotate_withArguments_actuallyRotatesTheSelection () {
    app.build_allActions();
    app.WIN3D.update = false;

    String hint = app.runScriptLine("ROTATE r:45");

    assertEquals("", hint);
    assertTrue(app.WIN3D.update);
  }

  @Test
  void rotate_withNoArguments_returnsTheUsageHint () {
    app.build_allActions();
    assertEquals("Rotate[X|Y|Z] r=? x=? y=? z=?", app.runScriptLine("ROTATE"));
  }

  @Test
  void rotateX_withNoArguments_returnsTheUsageHint () {
    app.build_allActions();
    assertEquals("Rotate[X|Y|Z] r=? x=? y=? z=?", app.runScriptLine("ROTATEX"));
  }

  @Test
  void scale_withArguments_actuallyScalesTheSelection () {
    app.build_allActions();
    app.WIN3D.update = false;

    String hint = app.runScriptLine("SCALE s:2");

    assertEquals("", hint);
    assertTrue(app.WIN3D.update);
  }

  @Test
  void scale_withNoArguments_returnsTheUsageHint () {
    app.build_allActions();
    assertEquals("Scale s=? sx=? sy=? sz=? x=? y=? z=?", app.runScriptLine("SCALE"));
  }

  // ---- object creation ------------------------------------------------------
  // Each creates real geometry (as faces) when given arguments - even the
  // minimal "x=0 y=0 z=0" below is enough, since every other dimension
  // defaults to a non-zero size - and otherwise returns its usage hint.

  @Test
  void box_withArguments_actuallyCreatesAFace_notJustTheCreateTool () {
    app.build_allActions();
    assertEquals(0, app.allFaces.nodes.length);

    String hint = app.runScriptLine("BOX x=0 y=0 z=0");

    assertEquals("", hint);
    assertTrue(app.allFaces.nodes.length > 0, "a box should actually be created");
  }

  @Test
  void box_withNoArguments_returnsTheUsageHint () {
    app.build_allActions();
    assertEquals("Box m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?", app.runScriptLine("BOX"));
  }

  @Test
  void sphere_withArguments_actuallyCreatesAFace () {
    app.build_allActions();
    String hint = app.runScriptLine("SPHERE x=0 y=0 z=0");
    assertEquals("", hint);
    assertTrue(app.allFaces.nodes.length > 0);
  }

  @Test
  void sphere_withNoArguments_returnsTheUsageHint () {
    app.build_allActions();
    assertEquals("Sphere m=? tes=? lyr=? x=? y=? z=? d=? deg=? r=?", app.runScriptLine("SPHERE"));
  }

  @Test
  void cylinder_withArguments_actuallyCreatesAFace () {
    app.build_allActions();
    String hint = app.runScriptLine("CYLINDER x=0 y=0 z=0");
    assertEquals("", hint);
    assertTrue(app.allFaces.nodes.length > 0);
  }

  @Test
  void cylinder_withNoArguments_returnsTheUsageHint () {
    app.build_allActions();
    assertEquals("Cylinder m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?", app.runScriptLine("CYLINDER"));
  }

  @Test
  void person_withArguments_actuallyCreatesAModel2D_notJustTheCreateTool () {
    app.build_allActions();
    assertEquals(0, app.allModel2Ds.num);

    String hint = app.runScriptLine("PERSON x=0 y=0 z=0");

    assertEquals("", hint);
    assertEquals(1, app.allModel2Ds.num, "a person should actually be created");
  }

  @Test
  void person_withNoArguments_returnsTheUsageHint () {
    app.build_allActions();
    assertEquals("Person m=? x=? y=? z=?", app.runScriptLine("PERSON"));
  }

  @Test
  void house1_withArguments_actuallyCreatesAFace () {
    app.build_allActions();
    String hint = app.runScriptLine("HOUSE1 x=0 y=0 z=0");
    assertEquals("", hint);
    assertTrue(app.allFaces.nodes.length > 0);
  }

  @Test
  void house1_withNoArguments_returnsTheUsageHint () {
    app.build_allActions();
    assertEquals("House1 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?", app.runScriptLine("HOUSE1"));
  }

  @Test
  void house2_withNoArguments_returnsTheUsageHint () {
    app.build_allActions();
    assertEquals("House2 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?", app.runScriptLine("HOUSE2"));
  }

  @Test
  void house3_withNoArguments_returnsTheUsageHint () {
    app.build_allActions();
    assertEquals("House3 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?", app.runScriptLine("HOUSE3"));
  }

  @Test
  void octahedron_withArguments_actuallyCreatesAFace () {
    app.build_allActions();
    String hint = app.runScriptLine("OCTAHEDRON x=0 y=0 z=0");
    assertEquals("", hint);
    assertTrue(app.allFaces.nodes.length > 0);
  }

  @Test
  void octahedron_withNoArguments_returnsTheUsageHint () {
    app.build_allActions();
    assertEquals("Octahedron m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?", app.runScriptLine("OCTAHEDRON"));
  }

  @Test
  void icosahedron_withArguments_actuallyCreatesAFace () {
    app.build_allActions();
    String hint = app.runScriptLine("ICOSAHEDRON x=0 y=0 z=0");
    assertEquals("", hint);
    assertTrue(app.allFaces.nodes.length > 0);
  }

  @Test
  void icosahedron_withNoArguments_returnsTheUsageHint () {
    app.build_allActions();
    assertEquals("Icosahedron m=? tes=? lyr=? x=? y=? z=? d=? r=?", app.runScriptLine("ICOSAHEDRON"));
  }

  @Test
  void cushion_withArguments_actuallyCreatesAFace () {
    app.build_allActions();
    String hint = app.runScriptLine("CUSHION x=0 y=0 z=0");
    assertEquals("", hint);
    assertTrue(app.allFaces.nodes.length > 0);
  }

  @Test
  void cushion_withNoArguments_returnsTheUsageHint () {
    app.build_allActions();
    assertEquals("Cushion m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?", app.runScriptLine("CUSHION"));
  }

  // ---- confirms unrelated commands are unaffected by the bypass list --------

  @Test
  void unrelatedCommand_stillDispatchesThroughAllActionsNormally () {
    app.vm.Begin_day(0);
    app.TIME.day = 1;

    String hint = app.runScriptLine("begin_day 15");

    assertEquals("", hint);
    assertEquals(15, app.TIME.day);
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
