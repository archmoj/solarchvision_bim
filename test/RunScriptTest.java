import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.lang.reflect.Method;

// Most of runScriptLine's ~130 switch cases either do file I/O (New, Save,
// Open, ...), close the JVM (Exit/Quit), or create 3D geometry already
// covered directly by Create3DTest.java - not duplicated here. This
// focuses on the cases with their own, previously-untested logic worth
// covering directly: the location-setting commands (also a regression
// check that they still update STATION, not just locationLatitude/locationLongitude),
// argument parsing/hints, dispatch to allActions (the integration point
// with ValueModifier.pde's command-line actions), and the small pure
// parseParams/getF/getI helpers at the bottom of the file.
class RunScriptTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.locateBaseFolder();

    app.allActions = new java.util.HashMap<>(); // fresh app never runs build_allActions() itself
  }

  // ================= SETLAT / SETLON / SETLONLAT ============================

  @Test
  void setLat_updatesStationAndSyncslocationLatitude () {
    String hint = app.runScriptLine("SETLAT 45.5");

    assertEquals("", hint);
    assertEquals(45.5f, app.STATION.getLatitude(), 0.001f);
    assertEquals(45.5f, app.locationLatitude, 0.001f);
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
  void setLon_updatesStationAndSyncslocationLongitude () {
    String hint = app.runScriptLine("SETLON -73.6");

    assertEquals("", hint);
    assertEquals(-73.6f, app.STATION.getLongitude(), 0.001f);
    assertEquals(-73.6f, app.locationLongitude, 0.001f);
  }

  @Test
  void setLon_missingArgument_returnsAUsageHint () {
    assertEquals("SetLon ?", app.runScriptLine("SETLON"));
  }

  @Test
  void setLonLat_setsBothInOneCommand_LonThenLatByPosition () {
    String hint = app.runScriptLine("SETLONLAT -73.6 45.5");

    assertEquals("", hint);
    assertEquals(45.5f, app.STATION.getLatitude(), 0.001f);
    assertEquals(-73.6f, app.STATION.getLongitude(), 0.001f);
  }

  @Test
  void setLatLon_setsBothInOneCommand_LatThenLonByPosition () {
    String hint = app.runScriptLine("SETLATLON 45.5 -73.6");

    assertEquals("", hint);
    assertEquals(45.5f, app.STATION.getLatitude(), 0.001f);
    assertEquals(-73.6f, app.STATION.getLongitude(), 0.001f);
  }

  @Test
  void setLonLat_missingSecondArgument_returnsAUsageHint () {
    assertEquals("SetLonLat ? ?", app.runScriptLine("SETLONLAT -73.6"));
  }

  @Test
  void setLatLon_missingSecondArgument_returnsAUsageHint () {
    assertEquals("SetLatLon ? ?", app.runScriptLine("SETLATLON 45.5"));
  }

  // ================= CLS =====================================================

  @Test
  void cls_resetsCommandHistoryToASingleEmptyEntry () {
    app.UI_consoleBar.allCommands = new ArrayList<String>(Arrays.asList("a", "b", "c"));

    app.runScriptLine("CLS");

    assertEquals(1, app.UI_consoleBar.allCommands.size());
    assertEquals("", app.UI_consoleBar.allCommands.get(0));
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

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(0, app.allModel2Ds.num, "the named category should actually be cleared");
    assertEquals(1, app.allFaces.nodes.length, "an unrelated category must not be touched");
  }

  @Test
  void deleteAllDashModel1Ds_onlyClearsModel1Ds () {
    app.build_allActions();
    app.allModel1Ds.num = 1;
    app.allFaces.nodes = new int[1][4];

    String hint = app.runScriptLine("Delete All-Model1Ds");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(0, app.allModel1Ds.num);
    assertEquals(1, app.allFaces.nodes.length);
  }

  @Test
  void deleteAllDashGroups_onlyClearsGroups () {
    app.build_allActions();
    app.allGroups.num = 1;
    app.allFaces.nodes = new int[1][4];

    String hint = app.runScriptLine("Delete All-Groups");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(0, app.allGroups.num);
    assertEquals(1, app.allFaces.nodes.length);
  }

  @Test
  void deleteAllDashSections_onlyClearsSections () {
    app.build_allActions();
    app.allSections.num = 1;
    app.allFaces.nodes = new int[1][4];

    String hint = app.runScriptLine("Delete All-Sections");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(0, app.allSections.num);
    assertEquals(1, app.allFaces.nodes.length);
  }

  @Test
  void deleteAllDashFaces_onlyClearsFaces () {
    app.build_allActions();
    app.allFaces.nodes = new int[1][4];
    app.allPolylines.nodes = new int[1][2]; // unrelated category this time

    String hint = app.runScriptLine("Delete All-Faces");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(0, app.allFaces.nodes.length, "the named category should actually be cleared");
    assertEquals(1, app.allPolylines.nodes.length, "an unrelated category must not be touched");
  }

  @Test
  void deleteAllDashPolylines_onlyClearsPolylines () {
    app.build_allActions();
    app.allPolylines.nodes = new int[1][2];
    app.allFaces.nodes = new int[1][4];

    String hint = app.runScriptLine("Delete All-Polylines");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(0, app.allPolylines.nodes.length);
    assertEquals(1, app.allFaces.nodes.length);
  }

  @Test
  void deleteAllDashSolids_onlyClearsSolids () {
    app.build_allActions();
    app.allSolids.DEF = new float[1][13];
    app.allFaces.nodes = new int[1][4];

    String hint = app.runScriptLine("Delete All-Solids");

    assertNotEquals(app.UnrecognizedCommand, hint);
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

    assertNotEquals(app.UnrecognizedCommand, hint);
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
    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(app.ObjectCategory.MODEL2D, app.currentObjectCategory);
  }

  @Test
  void selectAllDashSolids_switchesToTheSolidCategory () {
    app.build_allActions();
    String hint = app.runScriptLine("Select All-Solids");
    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(app.ObjectCategory.SOLID, app.currentObjectCategory);
  }

  @Test
  void selectAllDashCameras_switchesToTheCameraCategory () {
    app.build_allActions();
    String hint = app.runScriptLine("Select All-Cameras");
    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(app.ObjectCategory.CAMERA, app.currentObjectCategory);
  }

  // ================= other renamed "All-*" actions ===========================

  @Test
  void hideAllDashFaces_isRecognized () {
    app.build_allActions();
    assertNotEquals(app.UnrecognizedCommand, app.runScriptLine("Hide All-Faces"));
  }

  @Test
  void unhideAllDashFaces_isRecognized () {
    app.build_allActions();
    assertNotEquals(app.UnrecognizedCommand, app.runScriptLine("Unhide All-Faces"));
  }

  @Test
  void reverseVisibilityOfAllDashFaces_isRecognized () {
    app.build_allActions();
    assertNotEquals(app.UnrecognizedCommand, app.runScriptLine("Reverse Visibility of All-Faces"));
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
    app.WIN3D.currentTool = -1;
    app.WIN3D.update = false;

    String hint = app.runScriptLine("MOVE dx:5 dy:3 dz:1");

    assertEquals("", hint);
    assertEquals(-1, app.WIN3D.currentTool, "must not just switch the move tool");
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

  // "pyramid" is in bypassAllActionsFor (it collides with the bare
  // click-to-create tool-switch action of the same name, confirmed
  // directly via allActions.containsKey("pyramid") when this was added -
  // same class of collision as Solid/Camera/Section before it) - this
  // confirms the command is actually reached, not just that
  // runScriptLine returns without error.
  @Test
  void pyramid_withArguments_actuallyCreatesFourTriangularFaces () {
    app.build_allActions();
    String hint = app.runScriptLine("PYRAMID x=0 y=0 z=0 dx=4 dy=4 dz=4");

    assertEquals("", hint);
    assertEquals(5, app.allVertices.length, "4 base corners + 1 shared apex");
    assertEquals(4, app.allFaces.nodes.length);
  }

  @Test
  void pyramid_withNoArguments_returnsTheUsageHint () {
    app.build_allActions();
    assertEquals("Pyramid m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?", app.runScriptLine("PYRAMID"));
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
  void cone_withArguments_actuallyCreatesAFace () {
    app.build_allActions();
    String hint = app.runScriptLine("CONE x=0 y=0 z=0");
    assertEquals("", hint);
    assertTrue(app.allFaces.nodes.length > 0);
  }

  @Test
  void cone_withNoArguments_returnsTheUsageHint () {
    app.build_allActions();
    assertEquals("Cone m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?", app.runScriptLine("CONE"));
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

  // vsb/wgt/clz used to be hardcoded (1/0/0) in every one of these
  // shape-creation cases, regardless of what was passed - found and
  // fixed while making mouseClicked.pde's own Create3D block route
  // through these same commands instead of calling
  // Create3D.add_HouseN_Core(...) directly, since the hardcoded values
  // would have silently discarded the person's actual configured
  // creator defaults (User3D.creatorVisibility/Weight/Closed) on every
  // mouse-click creation. This confirms the fix directly, the same way
  // house1_withArguments_actuallyCreatesAFace above already covers x/y/z
  // actually being applied.
  @Test
  void house1_vsbWgtClz_areNowRespectedInsteadOfHardcoded () {
    app.build_allActions();
    app.runScriptLine("HOUSE1 x=0 y=0 z=0 vsb=0 wgt=3 clz=1");
    assertEquals(0, app.current_Visibility);
    assertEquals(3, app.current_Weight);
    assertEquals(1, app.current_Closed);
  }

  // POLYLINE parses its own arguments by hand (colon-separated, not the
  // parseParams()/getI() "key=value" style the shape commands above
  // use) rather than being generated from a shared helper - wgt/clz were
  // already individually wired into that hand-written parser; vsb was
  // the one left out, fixed the same way as the test above but via a
  // genuinely different code path, worth covering separately rather than
  // assuming the same fix covers both.
  @Test
  void polyline_vsb_isNowRespectedInsteadOfHardcoded () {
    app.build_allActions();
    app.runScriptLine("POLYLINE m:0 vsb:0 wgt:3 clz:1 0,0,0 1,1,1");
    assertEquals(0, app.current_Visibility);
    assertEquals(3, app.current_Weight);
    assertEquals(1, app.current_Closed);
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
    app.vm.day(0);
    app.TIME.day = 1;

    String hint = app.runScriptLine("day 15");

    assertEquals("", hint);
    assertEquals(15, app.TIME.day);
  }

  // ================= unrecognized commands ===================================

  @Test
  void unrecognizedCommandInSequence_interruptAndReturnsAHint () {
    app.vm.day(0);
    app.TIME.day = 1;

    String hint = app.runScriptLines(new String[] {"nonesense!", "day 15"});
    assertEquals(app.UnrecognizedCommand, hint);
    assertNotEquals(15, app.TIME.day);
  }

  @Test
  void unrecognizedCommand_returnsAHint () {
    assertEquals(app.UnrecognizedCommand, app.runScriptLine("this_is_not_a_real_command"));
  }

  @Test
  void blankLine_returnsNoHint () {
    assertEquals("", app.runScriptLine(""));
  }

  @Test
  void dividerLine_returnsNoHint () {
    assertEquals("", app.runScriptLine("="));
    assertEquals("", app.runScriptLine("=== section ==="));
  }

  @Test
  void commentLine_returnsNoHint () {
    assertEquals("", app.runScriptLine("#"));
    assertEquals("", app.runScriptLine("# comment"));
  }

  // ================= allActions fallback dispatch ============================
  // The integration point with ValueModifier.pde/actions.pde: a command
  // not matched by the switch falls through to a full-line match against
  // allActions, then a first-token match.

  @Test
  void fallsBackToAFirstTokenMatch_forACommandRegisteredWithArguments () {
    app.vm.day(0);
    app.TIME.day = 1;

    String hint = app.runScriptLine("day 15");

    assertEquals("", hint);
    assertEquals(15, app.TIME.day);
  }

  @Test
  void fallsBackToALastSpaceMatch_forAMultiWordCaptionTypedWithItsValue () {
    // "Start Hour" registers both "start_hour" and, via putAction's
    // "withSpace" fallback, the literal "start hour" too - but typing
    // "Start Hour 15" doesn't match either of those directly: the full
    // line is "start hour 15" (three words) and the first token alone is
    // just "start", which isn't registered as its own command anywhere.
    // Stripping the trailing value word off the line ("start hour") is
    // what finds it.
    app.vm.startHour(0);
    app.STUDY.startHour = 1;

    String hint = app.runScriptLine("Start Hour 15");

    assertEquals("", hint);
    assertEquals(15, app.STUDY.startHour);
  }

  @Test
  void fallsBackToALastSpaceMatch_forALongerMultiWordCaption () {
    app.vm.endDay(0);
    app.STUDY.endDay = 1;

    String hint = app.runScriptLine("End Day 200");

    assertEquals("", hint);
    assertEquals(200, app.STUDY.endDay);
  }

  @Test
  void fallsBackToAFullLineMatch_forACaptionTypedAloneWithNoValue () {
    // putValueAction reaches putAction's Action-taking overload, which -
    // like the Runnable-taking one used for plain menu items (see the
    // test right below) - registers the literal, lowercased caption
    // alongside the normalized (spaces -> underscores) key.
    app.vm.day(0);
    app.TIME.day = 10;

    String hint = app.runScriptLine("Day");

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
    app.STUDY.impactGraphIndex = -1;

    String hintSpaced = app.runScriptLine("Wind pattern (active)");
    assertEquals("", hintSpaced);
    assertEquals(app.impactGraphIndex_WIND_ACTIVE, app.STUDY.impactGraphIndex);

    app.STUDY.impactGraphIndex = -1; // reset before checking the other form

    String hintUnderscored = app.runScriptLine("wind_pattern_(active)");
    assertEquals("", hintUnderscored);
    assertEquals(app.impactGraphIndex_WIND_ACTIVE, app.STUDY.impactGraphIndex);
  }

  // ================= bypassAllActionsFor: exact-match, not prefix-match ===
  // Regression coverage for the fix below the comprehensive test: each of
  // these three bypass checks (full-line, first-token, trailing-word) now
  // only discards a match when the *matched key itself* is exactly one of
  // bypassAllActionsFor's names, not merely when the line starts with one
  // - these lock in the original, narrower behavior that mechanism is
  // still meant to guarantee (see UI_toolBar.pde's own "Scale"/"Move"
  // case comments), so a future change can't silently widen it back out.

  @Test
  void bareScale_stillReachesScaleSwitchCaseHintBranch_notTheSameNamedMenuAction () {
    app.build_allActions(); // registers the bare "Scale" menu action itself

    String hint = app.runScriptLine("Scale");

    assertEquals("Scale s=? sx=? sy=? sz=? x=? y=? z=?", hint);
  }

  @Test
  void bareMove_stillReachesMoveSwitchCaseHintBranch_notTheSameNamedMenuAction () {
    app.build_allActions(); // registers the bare "Move" menu action itself

    String hint = app.runScriptLine("Move");

    assertEquals("Move dx=? dy=? dz=?", hint);
  }

  @Test
  void scaleShorthandWithOneTrailingValue_stillSkipsTheBareMenuAction () {
    // "Scale 2" (SCALE's own shorthand uniform-scale-factor form) strips
    // down, via the trailing-word-removed fallback, to the bare "scale" -
    // exactly the same bare key a no-args "Scale" would full-line match -
    // so this needs the same bypass exception as the full-line case
    // above, just reached through a different one of the three match
    // attempts.
    app.build_allActions();

    boolean[] bareMenuActionCalled = {false};
    app.allActions.put("scale", (args) -> bareMenuActionCalled[0] = true);

    String hint = app.runScriptLine("Scale 2");

    assertFalse(bareMenuActionCalled[0],
      "runScriptLine(\"Scale 2\") invoked the bare \"scale\" menu action instead of reaching SCALE's switch-case");
    assertEquals("", hint);
  }

  // ================= sanitizeScriptLine / tokenizeScriptLine ===============
  // The two small, pure steps ___executeScriptLine___ runs before any
  // matching happens at all - extracted out of its own body so they (and
  // the match tiers below) can each be exercised directly, with a
  // throwaway line or allActions map, instead of only indirectly through
  // a full runScriptLine(...) call.

  @Test
  void sanitizeScriptLine_stripsLeadingAndTrailingWhitespace () {
    assertEquals("Day 15", app.sanitizeScriptLine("  Day 15  "));
  }

  @Test
  void sanitizeScriptLine_returnsNull_forABlankLine () {
    assertNull(app.sanitizeScriptLine(""));
    assertNull(app.sanitizeScriptLine("   "));
  }

  @Test
  void sanitizeScriptLine_returnsNull_forASectionLine () {
    assertNull(app.sanitizeScriptLine("=Section Name"));
  }

  @Test
  void sanitizeScriptLine_returnsNull_forACommentLine () {
    assertNull(app.sanitizeScriptLine("# a comment"));
  }

  @Test
  void tokenizeScriptLine_splitsOnSpaces () {
    assertArrayEquals(new String[]{"Day", "Increment", "15"}, app.tokenizeScriptLine("Day Increment 15"));
  }

  @Test
  void tokenizeScriptLine_collapsesRepeatedSpaces () {
    assertArrayEquals(new String[]{"SETLAT", "45.5"}, app.tokenizeScriptLine("SETLAT     45.5"));
  }

  @Test
  void tokenizeScriptLine_stripsQuotes () {
    assertArrayEquals(new String[]{"SETLAT", "45.5"}, app.tokenizeScriptLine("SETLAT \"45.5\""));
  }

  @Test
  void tokenizeScriptLine_turnsEqualsIntoAColon_andCollapsesDoubledSigns () {
    assertArrayEquals(new String[]{"BOX", "x:0", "y:0", "z:0"}, app.tokenizeScriptLine("BOX x==0 y=0 z=0"));
  }

  // ================= matchFullLine / matchTrailingWordRemoved / matchFirstToken ===
  // Each of allActions' three match tiers, tested directly against a
  // throwaway allActions map - not the real, 233-command one - so a
  // tier's own behavior (what it matches, what args it builds, which
  // bypass exception it respects) can be pinned down in isolation from
  // the other two, and from everything else actually registered.

  @Test
  void matchFullLine_findsARegisteredKey_andPassesThroughTheGivenParts () {
    app.allActions.put("save as...", (a) -> {});
    String[] parts = {"save", "as..."};

    solarchvision_bim.ActionMatch match = app.matchFullLine("save as...", parts);

    assertNotNull(match);
    assertEquals("save as...", match.key);
    assertSame(parts, match.args);
  }

  @Test
  void matchFullLine_returnsNull_whenTheKeyIsNotRegistered () {
    assertNull(app.matchFullLine("nothing here", new String[]{"nothing", "here"}));
  }

  @Test
  void matchFullLine_returnsNull_whenTheKeyIsBypassed_evenThoughItsRegistered () {
    app.allActions.put("scale", (a) -> {}); // the bare "Scale" menu action

    assertNull(app.matchFullLine("scale", new String[]{"scale"}));
  }

  @Test
  void matchTrailingWordRemoved_findsThePrefix_andBuildsPrefixPlusLastWordArgs () {
    app.allActions.put("day increment", (a) -> {});
    String[] parts = {"day", "increment", "2.5"};

    solarchvision_bim.ActionMatch match = app.matchTrailingWordRemoved("day increment 2.5", parts);

    assertNotNull(match);
    assertEquals("day increment", match.key);
    assertArrayEquals(new String[]{"day increment", "2.5"}, match.args);
  }

  @Test
  void matchTrailingWordRemoved_returnsNull_forASingleWordLine_thereIsNoLastWordToRemove () {
    app.allActions.put("day", (a) -> {});

    assertNull(app.matchTrailingWordRemoved("day", new String[]{"day"}));
  }

  @Test
  void matchTrailingWordRemoved_returnsNull_whenThePrefixIsNotRegistered () {
    assertNull(app.matchTrailingWordRemoved("nothing here 1", new String[]{"nothing", "here", "1"}));
  }

  @Test
  void matchTrailingWordRemoved_returnsNull_whenThePrefixIsBypassed_evenThoughItsRegistered () {
    app.allActions.put("scale", (a) -> {}); // the bare "Scale" menu action

    assertNull(app.matchTrailingWordRemoved("scale 2", new String[]{"scale", "2"}));
  }

  @Test
  void matchFirstToken_findsTheFirstWord_andPassesThroughAllTheParts () {
    app.allActions.put("day", (a) -> {});
    String[] parts = {"day", "15"};

    solarchvision_bim.ActionMatch match = app.matchFirstToken(parts);

    assertNotNull(match);
    assertEquals("day", match.key);
    assertSame(parts, match.args);
  }

  @Test
  void matchFirstToken_returnsNull_whenTheFirstWordIsNotRegistered () {
    assertNull(app.matchFirstToken(new String[]{"nothing", "here"}));
  }

  @Test
  void matchFirstToken_returnsNull_whenTheFirstWordIsBypassed_evenThoughItsRegistered () {
    app.allActions.put("move", (a) -> {}); // the bare "Move" menu action

    assertNull(app.matchFirstToken(new String[]{"move", "dx:1", "dy:2", "dz:3"}));
  }

  // ================= resolveAction: future collision scenarios =============
  // The single place the three tiers above are tried, in order - against
  // synthetic, throwaway allActions entries shaped exactly like the two
  // real collisions that slipped through before ("Day"/"Day Increment",
  // "Pivot"/"Pivot Alignment X"): a short command whose name is a strict
  // prefix of a longer, unrelated command's. A *new* command sharing this
  // same shape in the future needs no new test of its own - it's already
  // covered here, generically, rather than only by scanning the real
  // command set after the fact (that's what the comprehensive test below
  // still does, and remains useful for, but it can only catch a collision
  // that already happened to land among the current 233 commands).

  @Test
  void resolveAction_prefersTheMoreSpecificTrailingWordMatch_overAColliding_shorterFirstToken () {
    // The exact shape that broke "Day Increment" (collided with "Day")
    // and "Pivot Alignment X" (collided with "Pivot"): "foo" and "foo
    // bar" are both real, separately-registered commands; "foo bar 1"
    // must resolve to "foo bar", not stop early at "foo".
    app.allActions.put("foo", (a) -> {});
    app.allActions.put("foo bar", (a) -> {});

    solarchvision_bim.ActionMatch match = app.resolveAction("foo bar 1", app.tokenizeScriptLine("foo bar 1"));

    assertNotNull(match);
    assertEquals("foo bar", match.key);
    assertArrayEquals(new String[]{"foo bar", "1"}, match.args);
  }

  @Test
  void resolveAction_stillFindsTheShortCommand_whenNoLongerCommandCollidesWithIt () {
    app.allActions.put("foo", (a) -> {});

    solarchvision_bim.ActionMatch match = app.resolveAction("foo 1", app.tokenizeScriptLine("foo 1"));

    assertNotNull(match);
    assertEquals("foo", match.key);
  }

  @Test
  void resolveAction_prefersAFullLineMatch_overBothOfTheOtherTwoTiers () {
    // A caption that is itself a prefix of another registered key (so
    // all three tiers *could* match something) must still resolve to
    // its own, most specific, full-line match.
    app.allActions.put("foo", (a) -> {});
    app.allActions.put("foo bar", (a) -> {});

    solarchvision_bim.ActionMatch match = app.resolveAction("foo bar", app.tokenizeScriptLine("foo bar"));

    assertNotNull(match);
    assertEquals("foo bar", match.key);
  }

  @Test
  void resolveAction_fallsAllTheWayThroughToNull_whenNothingMatchesAnyTier () {
    solarchvision_bim.ActionMatch match = app.resolveAction("totally unregistered thing", app.tokenizeScriptLine("totally unregistered thing"));

    assertNull(match);
  }

  @Test
  void resolveAction_respectsTheBypassException_acrossAllThreeTiers_forAFutureBypassedCommand () {
    // A hypothetical future addition to bypassAllActionsFor ("zoom", say)
    // would need this same three-way exception the four already in
    // runScript.pde's set get - confirmed here against a synthetic bare
    // "foo" standing in for it, added to a throwaway copy of the real
    // bypass set for just this one test, rather than mutating the real
    // one other tests rely on.
    app.bypassAllActionsFor.add("foo");
    try {
      app.allActions.put("foo", (a) -> {});

      assertNull(app.resolveAction("foo", app.tokenizeScriptLine("foo")));
      assertNull(app.resolveAction("foo 2", app.tokenizeScriptLine("foo 2")));

      app.allActions.put("foo bar", (a) -> {});
      solarchvision_bim.ActionMatch match = app.resolveAction("foo bar 1", app.tokenizeScriptLine("foo bar 1"));
      assertNotNull(match);
      assertEquals("foo bar", match.key);
    } finally {
      app.bypassAllActionsFor.remove("foo");
    }
  }

  // The few commands above each exercise runScriptLine's dispatch by hand
  // (full-line, first-token, and the multi-word trailing-value fallback).
  // This drives every single ValueModifier.pde command the same way, one
  // parameter appended to its name, through runScriptLine itself - not by
  // calling its allActions entry directly (that's ValueModifierTest's own
  // registration-only smoke test). "1" is used as the probe value for all
  // 233: whatever a command's own min/max happen to be, action.run(...) is
  // still what gets invoked either way (an out-of-range value is rejected
  // *inside* the action - see putValueAction - without ever surfacing as
  // "Unrecognized command!"), so the underscore-key case below only checks
  // that runScriptLine found *some* action rather than falling through to
  // the switch - a command whose normalized key collided with a
  // switch-case name reserved in bypassAllActionsFor (see that set's own
  // comment) would be exactly the kind of regression this catches, coming
  // back as "Unrecognized command!" instead (not one of the ~15 commands
  // the switch itself recognizes). The spaced-key case needs a stronger
  // check than that same empty-hint test: a wrong, shorter-prefix match
  // also returns "" (see the comment at that branch below), so it
  // confirms the *exact* registered action actually ran, not just that
  // something did.
  @Test
  void everyValueModifierCommand_isDispatchableThroughRunScriptLine_withOneParameter () throws Exception {
    Method[] methods = app.vm.getClass().getDeclaredMethods();

    int checkedCount = 0;

    for (Method m : methods) {
      if (m.isSynthetic() || m.isBridge()) continue;
      if (m.getParameterCount() != 1 || m.getParameterTypes()[0] != int.class) continue;

      Set<String> before = new HashSet<>(app.allActions.keySet());

      m.setAccessible(true);
      m.invoke(app.vm, 0);

      Set<String> added = new HashSet<>(app.allActions.keySet());
      added.removeAll(before);

      assertFalse(added.isEmpty(),
        "vm." + m.getName() + "(0) did not add a new command name (possible key collision)");

      // Every key putAction registered for this command (the normalized
      // underscore form, and - when it differs - the literal spaced form)
      // should independently resolve through runScriptLine.
      for (String key : added) {
        if (key.indexOf(' ') >= 0) {
          // A spaced key only ever reaches runScriptLine's dispatch through
          // the trailing-value-stripped fallback (see runScript.pde): the
          // line is "<key> 1", a full-line match on that fails, so it falls
          // back to a first-token match on just the key's first word - if
          // that word happened to collide with another, shorter,
          // separately-registered command, *that* command would run
          // instead, silently, while still returning "" (recognized) just
          // like a correct match would. An empty-hint check alone can't
          // tell the two apart. Swapping in a counting spy under this
          // exact key and asserting it fired can: only the trailing-word
          // fallback reaches this key at all, so the spy firing confirms
          // runScriptLine actually walked all the way to *this* action
          // rather than stopping early on a wrong, shorter one.
          boolean[] called = {false};
          app.allActions.put(key, (args) -> called[0] = true);

          app.runScriptLine(key + " 1");

          assertTrue(called[0],
            "runScriptLine(\"" + key + " 1\") did not invoke the action registered under \"" + key +
            "\" (vm." + m.getName() + "()) - a different, shorter-prefix command matched instead");
        } else {
          String hint = app.runScriptLine(key + " 1");
          assertNotEquals("Unrecognized command!", hint,
            "runScriptLine(\"" + key + " 1\") was not recognized (vm." + m.getName() + "())");
        }
      }

      checkedCount++;
    }

    assertEquals(233, checkedCount, "expected exactly 233 value-modifier methods");
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

  // ================= runScriptFile ================================================
  // Everything above goes through runScriptLine()/runScriptLines() - this
  // is the one entry point among the three (see runScript.pde) not yet
  // exercised directly, rather than only through _fileSelected_RunScript's
  // own tests (see FileSelectedTest.java).

  @Test
  void runScriptFile_queuesItsLines_runOnTheNextDrawFrame () throws java.io.IOException {
    // runScriptFile only queues (see its own comment in runScript.pde) -
    // runPendingScriptLines() stands in for the next draw() frame that
    // would actually drain it.
    java.nio.file.Path script = java.nio.file.Files.createTempFile("runscript-file-test", ".svs");
    java.nio.file.Files.writeString(script, "SETLAT 45.5\n");

    String hint = app.runScriptFile(script.toString());
    assertEquals("", hint);
    assertEquals(java.util.List.of("SETLAT 45.5"), app.pendingScriptLines);

    app.runPendingScriptLines();

    assertEquals(45.5f, app.STATION.getLatitude(), 0.001f);
  }

  // ================= section dividers ("=" lines): deferred to a later frame ====
  // runScriptLines stops at a "=" line and queues everything after it
  // into pendingScriptLines (see runScript.pde) instead of running it in
  // the same call - draw() in solarchvision_bim.pde drains that queue
  // once per frame via runPendingScriptLines(), which is what makes a
  // "=" divider act as "go to the next frame" for ANY runScriptLines
  // call: the RUN=<file> startup script (see parseArgs.pde) and a
  // RUN.SCRIPT run from the live command line after initialization are
  // now the exact same mechanism, not two separate ones.

  @Test
  void runScriptLines_withNoSectionDivider_runsEverythingInOneCall () {
    String hint = app.runScriptLines(new String[]{"SETLAT 10", "SETLON 20"});

    assertEquals("", hint);
    assertEquals(10f, app.STATION.getLatitude(), 0.001f);
    assertEquals(20f, app.STATION.getLongitude(), 0.001f);
    assertTrue(app.pendingScriptLines.isEmpty());
  }

  @Test
  void runScriptLines_stopsAtASectionDivider_andQueuesTheRemainingLines () {
    float defaultLongitude = app.STATION.getLongitude(); // STATION starts at a real default city, not 0,0

    app.runScriptLines(new String[]{"SETLAT 10", "=======", "SETLON 20"});

    // Only the line before "=======" ran...
    assertEquals(10f, app.STATION.getLatitude(), 0.001f);
    // ...the line after it did not, yet:
    assertEquals(defaultLongitude, app.STATION.getLongitude(), 0.001f);
    assertEquals(java.util.List.of("SETLON 20"), app.pendingScriptLines);
  }

  @Test
  void runScriptLines_aSectionDividerAsTheLastLine_queuesNothing () {
    app.runScriptLines(new String[]{"SETLAT 10", "======="});

    assertEquals(10f, app.STATION.getLatitude(), 0.001f);
    assertTrue(app.pendingScriptLines.isEmpty());
  }

  @Test
  void runPendingScriptLines_onAnEmptyQueue_doesNothing () {
    assertDoesNotThrow(() -> app.runPendingScriptLines());
  }

  @Test
  void runPendingScriptLines_drainsOneSectionPerCall_matchingOneDrawFramePerSection () {
    float defaultLongitude = app.STATION.getLongitude(); // STATION starts at a real default city, not 0,0

    // Three "frames" worth of work, queued the way a RUN.SCRIPT'd file
    // with two "=" dividers would be - exactly command/test/views.svs's
    // own shape (several "switch view, then REC.png" sections, one per
    // frame).
    app.queuePendingScriptLines(new String[]{
      "SETLAT 10", "=======", "SETLON 20", "=======", "SETLAT 30"
    });

    app.runPendingScriptLines(); // "frame" 1
    assertEquals(10f, app.STATION.getLatitude(), 0.001f);
    assertEquals(defaultLongitude, app.STATION.getLongitude(), 0.001f); // not yet

    app.runPendingScriptLines(); // "frame" 2
    assertEquals(20f, app.STATION.getLongitude(), 0.001f);
    assertEquals(10f, app.STATION.getLatitude(), 0.001f); // unchanged this frame

    app.runPendingScriptLines(); // "frame" 3
    assertEquals(30f, app.STATION.getLatitude(), 0.001f);
    assertTrue(app.pendingScriptLines.isEmpty());
  }

  @Test
  void runScriptFile_withASectionDivider_runsOneSectionPerSimulatedFrame () throws java.io.IOException {
    // The exact shape RUN.SCRIPT (__RUN_SCRIPT__ -> runScriptFile) hits
    // when run from the live command line *after* initialization has
    // already completed, and the exact bug this guards against: a
    // *synchronous* first section (i.e. anything runScriptFile itself
    // ran immediately, rather than only queuing) would get overwritten
    // by the second section's dispatch on the very next draw() frame
    // before ever getting a frame of its own to render and save - always
    // silently losing exactly the first section. So runScriptFile must
    // run nothing at all synchronously, not even "up to the first
    // divider": every section, including the first, needs its own
    // runPendingScriptLines() call (standing in for a draw() frame) in
    // this test, exactly like every section after it.
    float defaultLatitude = app.STATION.getLatitude();   // STATION starts at a real default city, not 0,0
    float defaultLongitude = app.STATION.getLongitude();

    java.nio.file.Path script = java.nio.file.Files.createTempFile("runscript-sections-test", ".svs");
    java.nio.file.Files.writeString(script, "SETLAT 10\n=======\nSETLON 20\n");

    app.runScriptFile(script.toString());

    // Nothing has run yet - not even the first section:
    assertEquals(defaultLatitude, app.STATION.getLatitude(), 0.001f);
    assertEquals(defaultLongitude, app.STATION.getLongitude(), 0.001f);

    app.runPendingScriptLines(); // "frame" 1
    assertEquals(10f, app.STATION.getLatitude(), 0.001f);
    assertEquals(defaultLongitude, app.STATION.getLongitude(), 0.001f); // still not yet

    app.runPendingScriptLines(); // "frame" 2
    assertEquals(20f, app.STATION.getLongitude(), 0.001f);
  }

  // ================= ___executeScriptLine___'s own text normalization =============
  // Stripped/collapsed before splitting into parts[] (see its own comment
  // block in runScript.pde): quotes removed, runs of spaces collapsed to
  // one, "=" turned into ":", runs of ":" collapsed to one. None of the
  // tests above happen to exercise an actual double space, a quoted
  // value, or a doubled "=" - most already use single spaces and single
  // "="/":" by construction, which wouldn't catch a regression here.

  @Test
  void multipleSpacesBetweenTokens_collapseToOne_soPositionalParsingStillWorks () {
    // Without the " +" -> " " collapsing, split(transformedLine, ' ')
    // would produce empty strings between the real tokens, shifting
    // parts[1] away from where SETLAT (see its own float(parts[1])) expects it.
    String hint = app.runScriptLine("SETLAT     45.5");

    assertEquals("", hint);
    assertEquals(45.5f, app.STATION.getLatitude(), 0.001f);
  }

  @Test
  void quotesAroundAValue_areStrippedBeforeParsing () {
    String hint = app.runScriptLine("SETLAT \"45.5\"");

    assertEquals("", hint);
    assertEquals(45.5f, app.STATION.getLatitude(), 0.001f);
  }

  @Test
  void doubledEqualsSign_stillParsesCorrectly_viaTheColonCollapsing () {
    // "x==0" -> (= -> :) "x::0" -> (collapse +:) "x:0" - two separate
    // normalization steps have to both fire correctly for this one case
    // to come out right, not just either alone.
    app.build_allActions();

    String hint = app.runScriptLine("BOX x==0 y=0 z=0");

    assertEquals("", hint);
    assertTrue(app.allFaces.nodes.length > 0);
  }

  // ================= RUN.SCRIPT: a script invoking another script =================

  @Test
  void runDotScript_withAFilename_runsThatFileFromFolder_Import () throws java.io.IOException {
    java.nio.file.Path nested = java.nio.file.Path.of(app.Folder_Import, "run-dot-script-nested-test.svs");
    java.nio.file.Files.createDirectories(nested.getParent());
    java.nio.file.Files.writeString(nested, "SETLAT 33.3\n");

    String hint = app.runScriptLine("RUN.SCRIPT run-dot-script-nested-test.svs");

    assertEquals("", hint);
    assertEquals(java.util.List.of("SETLAT 33.3"), app.pendingScriptLines); // queued, not run yet - see runScriptFile's own comment

    app.runPendingScriptLines(); // the next draw() frame would supply this

    assertEquals(33.3f, app.STATION.getLatitude(), 0.001f);
  }
}
