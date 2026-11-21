import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// WIN3DTest.java already covers each key handler (handleCommandKey,
// handleArrowKeys, etc.) dispatching correctly to these actions by
// name - this instead covers the actions themselves, invoked directly
// via runScriptLine (as command/test/*.svs scripts, or anything else
// scripting the sketch, would actually call them), since that's the new
// capability this whole effort adds: before, a key's effect only existed
// inside its own switch-case, unreachable except by an actual keypress.
// Each test here checks two things together - runScriptLine's own hint
// isn't UnrecognizedCommand (confirms the name is registered correctly,
// not just that *some* code happens to run) and the actual state change
// (confirms the registered body does what it's named for) - following
// RunScriptTest.java's own established pattern for exercising allActions
// through runScriptLine rather than poking the map directly.
class WIN3DActionsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // fresh app never runs build_allActions() itself
    app.build_allActions();
  }

  // ================= WIN3D c / WIN3D Shift+C (camera cycling) ============

  @Test
  void keyC_cyclesCameraForwardAndWrapsAtTheEnd () {
    app.allCameras.makeEmpty(0); // camera 0
    app.allCameras.create(0, 0, 0, 1, 0, 0, 0, 5, 60, 1); // camera 1
    app.WIN3D.currentCameraIndex = 1; // at the last camera

    String hint = app.runScriptLine("Next Camera");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(0, app.WIN3D.currentCameraIndex);
  }

  @Test
  void keyShiftC_cyclesCameraBackwardAndWrapsAtTheStart () {
    app.allCameras.makeEmpty(0); // camera 0
    app.allCameras.create(0, 0, 0, 1, 0, 0, 0, 5, 60, 1); // camera 1
    app.WIN3D.currentCameraIndex = 0; // at the first camera

    String hint = app.runScriptLine("Previous Camera");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(1, app.WIN3D.currentCameraIndex);
  }

  // Regression test for the pre-existing bug found (and fixed) while
  // building this: with zero cameras, the un-clamped "allCameras.num - 1"
  // wrap-around used to compute -1 instead of a valid index, which would
  // later crash anything that assumed currentCameraIndex was never
  // negative (confirmed - by hand, against the pristine pre-fix commit -
  // to crash during rendering, not here).
  @Test
  void keyShiftC_withNoCameras_clampsToZeroInsteadOfGoingNegative () {
    app.allCameras.num = 0;
    app.WIN3D.currentCameraIndex = 0;

    String hint = app.runScriptLine("Previous Camera");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(0, app.WIN3D.currentCameraIndex, "must clamp to 0, never go negative");
  }

  // ================= WIN3D A/a (impact type cycling) ===============

  @Test
  void keyShiftTab_cyclesImpactTypeAndWrapsAround () {
    app.WIN3D.impactTypeIndex = app.numberOfImpactVariations - 1; // at the last one

    String hint = app.runScriptLine("Toggle Impact Type");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(0, app.WIN3D.impactTypeIndex);
  }

  @Test
  void keyShiftTab_flagsBothSolarCachesForRebuild_regardlessOfTheActiveShadeMode () {
    // Both caches are now flagged unconditionally, not just the one
    // matching the currently active shading mode - see
    // find_which_bakings_to_regenerate's own test for the rationale.
    app.WIN3D.shadingMode = app.SHADE.Global_Solar;
    app.GlobalSolar_rebuild_array = false;
    app.VertexSolar_rebuild_array = false;

    app.runScriptLine("Toggle Impact Type");

    assertTrue(app.GlobalSolar_rebuild_array);
    assertTrue(app.VertexSolar_rebuild_array);
  }

  @Test
  void keyShiftTab_alsoRequestsTheSolarImpactOverlayOverride () {
    // See SolarImpactsTest.java's win3DOverlay_needsClearRect tests for
    // what this flag actually controls: showing the WIN3D solar-impact
    // overlay even with the camera mismatched.
    app.WIN3D.showSolarImpactOverride = false;

    app.runScriptLine("Toggle Impact Type");

    assertTrue(app.WIN3D.showSolarImpactOverride);
  }

  // ================= WIN3D , / WIN3D . (perspective dolly / zoom) ========

  @Test
  void keyComma_inPerspective_movesPositionZForward () {
    app.WIN3D.projectionTypeIndex = 1; // perspective
    app.WIN3D.positionZ = 0;
    app.WIN3D.positionStep = 1;
    app.overallScale = 1;

    String hint = app.runScriptLine("Zoom Out");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(1f, app.WIN3D.positionZ, 0.0001f);
  }

  @Test
  void keyComma_inOrthographic_zoomsInInstead () {
    app.WIN3D.projectionTypeIndex = 0; // orthographic
    app.WIN3D.positionZ = 0;
    app.WIN3D.zoom = 90;

    app.runScriptLine("Zoom Out");

    assertEquals(0f, app.WIN3D.positionZ, 0.0001f, "orthographic mode must not move positionZ");
    assertTrue(app.WIN3D.zoom < 90);
  }

  @Test
  void keyPeriod_inPerspective_movesPositionZBackward () {
    app.WIN3D.projectionTypeIndex = 1;
    app.WIN3D.positionZ = 0;
    app.WIN3D.positionStep = 1;
    app.overallScale = 1;

    String hint = app.runScriptLine("Zoom In");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(-1f, app.WIN3D.positionZ, 0.0001f);
  }

  @Test
  void keyPeriod_inOrthographic_zoomsOutInstead () {
    app.WIN3D.projectionTypeIndex = 0;
    app.WIN3D.positionZ = 0;
    app.WIN3D.zoom = 90;

    app.runScriptLine("Zoom In");

    assertEquals(0f, app.WIN3D.positionZ, 0.0001f);
    assertTrue(app.WIN3D.zoom > 90);
  }

  // ================= WIN3D 4/6/8/2 (rotation) =============================

  @Test
  void key4_increasesRotationZ () {
    app.WIN3D.rotationZ = 0;
    app.WIN3D.rotationStep = 5;

    String hint = app.runScriptLine("Turn View Left");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(5f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void key6_decreasesRotationZ () {
    app.WIN3D.rotationZ = 0;
    app.WIN3D.rotationStep = 5;

    app.runScriptLine("Turn View Right");

    assertEquals(-5f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void key8_decreasesRotationX () {
    app.WIN3D.rotationX = 0;
    app.WIN3D.rotationStep = 5;

    app.runScriptLine("Turn View Up");

    assertEquals(-5f, app.WIN3D.rotationX, 0.0001f);
  }

  @Test
  void key2_increasesRotationX () {
    app.WIN3D.rotationX = 0;
    app.WIN3D.rotationStep = 5;

    app.runScriptLine("Turn View Down");

    assertEquals(5f, app.WIN3D.rotationX, 0.0001f);
  }

  // ================= WIN3D 1/3/7/9 (pan) ==================================

  @Test
  void key1_increasesPositionX () {
    app.WIN3D.positionX = 0;
    app.WIN3D.positionStep = 1;
    app.overallScale = 1;

    String hint = app.runScriptLine("Pan Left");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(1f, app.WIN3D.positionX, 0.0001f);
  }

  @Test
  void key3_decreasesPositionX () {
    app.WIN3D.positionX = 0;
    app.WIN3D.positionStep = 1;
    app.overallScale = 1;

    app.runScriptLine("Pan Right");

    assertEquals(-1f, app.WIN3D.positionX, 0.0001f);
  }

  @Test
  void key7_increasesPositionY () {
    app.WIN3D.positionY = 0;
    app.WIN3D.positionStep = 1;
    app.overallScale = 1;

    app.runScriptLine("Pan Forward");

    assertEquals(1f, app.WIN3D.positionY, 0.0001f);
  }

  @Test
  void key9_decreasesPositionY () {
    app.WIN3D.positionY = 0;
    app.WIN3D.positionStep = 1;
    app.overallScale = 1;

    app.runScriptLine("Pan Backward");

    assertEquals(-1f, app.WIN3D.positionY, 0.0001f);
  }

  // ================= WIN3D * / WIN3D / (distance to selection) ===========

  // moveCameraTowards() (what move_3DViewport_towards_Selection() calls)
  // sets cameraX/Y/Z, not positionZ - setup copied from WIN3DTest.java's
  // own handleCommandKey_starAndSlash_moveTheCameraInOppositeDirections
  // rather than assumed.
  @Test
  void keyStar_and_keySlash_moveTheCameraInOppositeDirections () {
    app.allVertices = new float[0][3]; // nothing selected - getPivot() falls back to the origin
    app.WIN3D.cameraX = 10;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = 0;
    app.overallScale = 1;

    String starHint = app.runScriptLine("Dolly Away From Selection"); // factor 2.0 - away from the pivot
    assertNotEquals(app.UnrecognizedCommand, starHint);
    assertTrue(app.WIN3D.cameraX > 10);

    float afterStar = app.WIN3D.cameraX;
    String slashHint = app.runScriptLine("Dolly Toward Selection"); // factor 0.5 - back towards it
    assertNotEquals(app.UnrecognizedCommand, slashHint);
    assertTrue(app.WIN3D.cameraX < afterStar);
  }

  // ================= WIN3D + / WIN3D - (field-of-view zoom) ===============

  @Test
  void keyPlus_and_keyMinus_zoomInOppositeDirections () {
    app.WIN3D.zoom = 90;
    String plusHint = app.runScriptLine("Narrow Field of View");
    float afterPlus = app.WIN3D.zoom;

    app.WIN3D.zoom = 90;
    String minusHint = app.runScriptLine("Widen Field of View");
    float afterMinus = app.WIN3D.zoom;

    assertNotEquals(app.UnrecognizedCommand, plusHint);
    assertNotEquals(app.UnrecognizedCommand, minusHint);
    assertTrue(afterPlus < 90, "+ should narrow the field of view");
    assertTrue(afterMinus > 90, "- should widen the field of view");
  }

  // ================= WIN3D t / WIN3D Shift+T (troposphere time) ===========
  // "Advance/Rewind Troposphere Time" are now thin delegates to "Shade
  // Next/Previous Hour" (actions.pde's own comment on why) - Tropo3D.
  // i_Map() (tropo3D.pde) derives straight from SHADE_HOUR_ANGLE, so
  // these tests go through SHADE_HOUR_ANGLE and nextShadeHour()/
  // previousShadeHour()'s own wrap behavior (STUDY.isInHourlyRange(),
  // SHADE_FIRST_HOUR/SHADE_LAST_HOUR) - the same thing the equivalent
  // Alt+Up/Down tests already exercise (handleAltArrowKeys()'s own
  // comment - RIGHT/UP and LEFT/DOWN are swapped there, so it's Up/Down
  // that drive the hour now, not Right/Left) - rather than a
  // troposphere-specific clamp-and-revert that no longer exists.

  @Test
  void keyT_advancesSHADE_HOUR_ANGLEAndTropo3DsIMapTogether () {
    app.STUDY.startHour = 0;
    app.STUDY.endHour = 23;
    app.SHADE_HOUR_ANGLE = 10;

    String hint = app.runScriptLine("Advance Troposphere Time");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(11, app.SHADE_HOUR_ANGLE);
    assertEquals(11, app.Tropo3D.i_Map());
  }

  @Test
  void keyT_wrapsPastTheLastHourBackToTheFirst_sameAsAltUp () {
    app.STUDY.startHour = 0;
    app.STUDY.endHour = 23;
    app.SHADE_HOUR_ANGLE = app.SHADE_LAST_HOUR;

    app.runScriptLine("Advance Troposphere Time");

    assertEquals(app.SHADE_FIRST_HOUR, app.SHADE_HOUR_ANGLE);
    assertEquals(app.SHADE_FIRST_HOUR, app.Tropo3D.i_Map());
  }

  @Test
  void keyShiftT_rewindsSHADE_HOUR_ANGLEAndTropo3DsIMapTogether () {
    app.STUDY.startHour = 0;
    app.STUDY.endHour = 23;
    app.SHADE_HOUR_ANGLE = 10;

    String hint = app.runScriptLine("Rewind Troposphere Time");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(9, app.SHADE_HOUR_ANGLE);
    assertEquals(9, app.Tropo3D.i_Map());
  }

  @Test
  void keyShiftT_wrapsBeforeTheFirstHourBackToTheLastHourInRange_sameAsAltDown () {
    app.STUDY.startHour = 0;
    app.STUDY.endHour = 23;
    app.SHADE_HOUR_ANGLE = app.SHADE_FIRST_HOUR;

    app.runScriptLine("Rewind Troposphere Time");

    // Not SHADE_LAST_HOUR (24) - with this STUDY.startHour/endHour range,
    // hour 24 isn't itself "in range" (STUDY.isInHourlyRange(24) is
    // false: 24 % 24 == 0 is the only hour-24-equivalent value actually
    // in [0, 23]), so previousShadeHour() keeps decrementing past it down
    // to 23, the real last hour in range - the exact same wrap
    // previousShadeHour()'s own existing WIN3DTest.java coverage already
    // establishes for Alt+Down.
    assertEquals(23, app.SHADE_HOUR_ANGLE);
    assertEquals(23, app.Tropo3D.i_Map());
  }

  // ================= WIN3D d / WIN3D Shift+D (impact display day) ========

  @Test
  void keyD_advancesDisplayDayAndWrapsAtEndDay () {
    app.STUDY.endDay = 5;
    app.impactDisplayDay = 5;

    String hint = app.runScriptLine("Next Impact Day");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(0, app.impactDisplayDay);
  }

  @Test
  void keyD_alsoRequestsTheSolarImpactOverlayOverride () {
    // See SolarImpactsTest.java's win3DOverlay_needsClearRect tests for
    // what this flag actually controls: showing the WIN3D solar-impact
    // overlay even with the camera mismatched.
    app.STUDY.endDay = 5;
    app.WIN3D.showSolarImpactOverride = false;

    app.runScriptLine("Next Impact Day");

    assertTrue(app.WIN3D.showSolarImpactOverride);
  }

  @Test
  void keyShiftD_rewindsDisplayDayAndWrapsAtZero () {
    app.STUDY.endDay = 5;
    app.impactDisplayDay = 0;

    String hint = app.runScriptLine("Previous Impact Day");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(5, app.impactDisplayDay);
  }

  @Test
  void keyShiftD_alsoRequestsTheSolarImpactOverlayOverride () {
    app.STUDY.endDay = 5;
    app.WIN3D.showSolarImpactOverride = false;

    app.runScriptLine("Previous Impact Day");

    assertTrue(app.WIN3D.showSolarImpactOverride);
  }

  // ================= WIN3D Enter ==========================================

  @Test
  void keyEnter_flagsBothSolarCachesForRebuild_regardlessOfTheActiveShadeMode () {
    // Both caches are now flagged unconditionally, not just the one
    // matching the currently active shading mode - see
    // find_which_bakings_to_regenerate's own test for the rationale.
    app.WIN3D.shadingMode = app.SHADE.Surface_White;
    app.GlobalSolar_rebuild_array = false;
    app.VertexSolar_rebuild_array = false;

    String hint = app.runScriptLine("Recalculate Solar Impact");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.GlobalSolar_rebuild_array);
    assertTrue(app.VertexSolar_rebuild_array);
  }

  // ================= WIN3D ShadeTime+1/-1/+Day/-Day ========================

  @Test
  void keyShadeTimePlus1_stepsForwardByOneHour () {
    app.SHADE_HOUR_ANGLE = 0;
    app.SHADE_DATE_ANGLE = 0;

    String hint = app.runScriptLine("Shade Next Hour");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(1, app.SHADE_HOUR_ANGLE);
  }

  @Test
  void keyShadeTimeMinus1_stepsBackwardByOneHour () {
    app.SHADE_HOUR_ANGLE = app.SHADE_LAST_HOUR;
    app.SHADE_DATE_ANGLE = 0;

    String hint = app.runScriptLine("Shade Previous Hour");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(app.SHADE_LAST_HOUR - 1, app.SHADE_HOUR_ANGLE);
  }

  @Test
  void keyShadeTimePlusDay_stepsForwardByAFullDay () {
    app.SHADE_HOUR_ANGLE = app.SHADE_FIRST_HOUR;
    app.SHADE_DATE_ANGLE = 0;

    String hint = app.runScriptLine("Shade Next Day");

    assertNotEquals(app.UnrecognizedCommand, hint);
    // "Shade Next Day" now drives impactDisplayDay (via the real "Next
    // Impact Day" action) instead of adding SHADE_HOURS_PER_DAY + 1
    // hourly steps, so SHADE_HOUR_ANGLE is left untouched...
    assertEquals(app.SHADE_FIRST_HOUR, app.SHADE_HOUR_ANGLE);
    // ...and SHADE_DATE_ANGLE is derived from sync_SHADE_DATE_ANGLE()
    // (impactDisplayDay=1, TIME.beginDay=0, STUDY.dayIncrement=30.5)
    // rather than incremented by SHADE_STEP_DAYS:
    //   j = impactDisplayDay - 1 = 0
    //   now_j = (0 * 30 + 0 + 366) % 366 = 0
    //   angle = (int) (360 * ((286 + 0) % 366) / 366.0) = 281
    assertEquals(281, app.SHADE_DATE_ANGLE);
  }

  @Test
  void unshadeViewport_turnsOffTheStickyShadingOverlay () {
    app.WIN3D.showShading = true;

    String hint = app.runScriptLine("Unshade Viewport");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertFalse(app.WIN3D.showShading);
  }

  @Test
  void unshadeViewport_isHarmlessWhenShadingIsAlreadyOff () {
    app.WIN3D.showShading = false;

    String hint = app.runScriptLine("Unshade Viewport");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertFalse(app.WIN3D.showShading);
  }

  // ================= WIN3D Ctrl+, / WIN3D Ctrl+. ==========================

  // moveWin3DTowardsSelection(wheelValue) calls
  // move_3DViewport_towards_Selection(pow(2, 0.5*wheelValue)) - for
  // -0.5 that's pow(2,-0.25)~=0.841 (a positive factor under 1, so
  // CLOSER to the pivot, not "negative/away" as the raw -0.5 might
  // suggest at a glance); +0.5 is the mirror image, pow(2,0.25)~=1.189,
  // farther away. Setup (cameraX/Y/Z, not positionZ) copied from
  // WIN3DTest.java's own moveWin3DTowardsSelectionViaCtrlComma_... test,
  // whose own comment spells this same factor-math point out in more
  // detail.
  @Test
  void keyCtrlComma_and_keyCtrlPeriod_moveTheCameraInOppositeDirections () {
    app.allVertices = new float[0][3]; // pivot falls back to the origin
    app.WIN3D.cameraX = 10;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = 0;
    app.overallScale = 1;

    String commaHint = app.runScriptLine("Nudge Closer to Selection"); // closer to the pivot
    assertNotEquals(app.UnrecognizedCommand, commaHint);
    assertTrue(app.WIN3D.cameraX < 10);

    float afterComma = app.WIN3D.cameraX;
    String periodHint = app.runScriptLine("Nudge Away from Selection"); // farther from it
    assertNotEquals(app.UnrecognizedCommand, periodHint);
    assertTrue(app.WIN3D.cameraX > afterComma);
  }

  // ================= WIN3D Up/Down/Left/Right (orbit around selection) ===

  // rotateZ_3DViewport_around_Selection() actually changes rotationX, not
  // rotationZ, despite the name - confirmed against WIN3DTest.java's own
  // existing handleArrowKeys_downIncreasesRotationX/upDecreasesRotationX,
  // whose exact setup (just rotationStep, no selection needed at all) is
  // reused here rather than the more elaborate one this test started
  // with.
  @Test
  void keyUp_decreasesRotationX () {
    app.WIN3D.rotationStep = 5;
    float before = app.WIN3D.rotationX;

    String hint = app.runScriptLine("Orbit Up Around Selection");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(before - 5, app.WIN3D.rotationX, 0.0001f);
  }

  @Test
  void keyDown_increasesRotationX () {
    app.WIN3D.rotationStep = 5;
    float before = app.WIN3D.rotationX;

    String hint = app.runScriptLine("Orbit Down Around Selection");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(before + 5, app.WIN3D.rotationX, 0.0001f);
  }

  @Test
  void keyLeft_decreasesRotationZ () {
    app.WIN3D.rotationStep = 5;
    float before = app.WIN3D.rotationZ;

    String hint = app.runScriptLine("Orbit Left Around Selection");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(before - 5, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void keyRight_increasesRotationZ () {
    app.WIN3D.rotationStep = 5;
    float before = app.WIN3D.rotationZ;

    String hint = app.runScriptLine("Orbit Right Around Selection");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(before + 5, app.WIN3D.rotationZ, 0.0001f);
  }

  // ================= WIN3D Shift+Up / WIN3D Shift+Down ====================
  // (the shared, tool-dependent WIN3D_ShiftUpDown() body - exercised here
  // only through the Rotate/Move branches already covered directly in
  // WIN3DTest.java's own handleShiftedArrowKeys_* tests; this just
  // confirms the same effect is reachable by name.)

  @Test
  void keyShiftUp_withRotateTool_nudgesSelectionAroundItsPivot () {
    app.allVertices = new float[][]{{1, 0, 0}};
    app.Select3D.vertexSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.rotationVectorIndex = 2; // Z axis
    app.User3D.currentTool = app.UITASK.Rotate;

    String hint = app.runScriptLine("Increase Tool Parameter");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertNotEquals(0f, app.allVertices[0][1], 0.0001f);
  }

  @Test
  void keyShiftDown_withMoveTool_nudgesSelectionAlongThePosVectorOnly () {
    app.allVertices = new float[][]{{0, 0, 0}};
    app.Select3D.vertexSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.positionVectorIndex = 2; // Z only
    app.overallScale = 1;
    app.User3D.currentTool = app.UITASK.Move;

    String hint = app.runScriptLine("Decrease Tool Parameter");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(0f, app.allVertices[0][0], 0.0001f);
    assertEquals(0f, app.allVertices[0][1], 0.0001f);
    assertEquals(-0.5f, app.allVertices[0][2], 0.0001f);
  }

  // ================= Shift+Up/Down with Skew/Twist/Bend tools ============
  // Unlike Move/Rotate above, these 3 tools take no per-axis vector index
  // - each commits all 3 of its own Deform-panel modifier fields together.
  // "Increase"/"Decrease Tool Parameter" just need to reach Modify3D.
  // skewVertices_Selection(direction)/twistVertices_Selection(direction)/
  // bendVertices_Selection(direction) with the matching +1/-1 - the exact
  // math each performs is covered by ModifyGeometryTest.java's own
  // forward/backward tests, so these only check the dispatch wiring.

  @Test
  void keyShiftUp_withSkewTool_commitsForwardSkew () {
    app.allVertices = new float[][]{{0, 0, 0}, {0, 10, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierSkewXY = 18;
    app.User3D.currentTool = app.UITASK.Skew;

    String hint = app.runScriptLine("Increase Tool Parameter");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertNotEquals(0f, app.allVertices[0][0], 0.0001f, "forward Skew should have sheared x by the +direction amount");
  }

  @Test
  void keyShiftDown_withSkewTool_commitsBackwardSkew_negatedFromForward () {
    // v1's own y-offset from the pivot (cy=5) is +5, so its forward
    // shear is positive and its backward shear is negative - using v1
    // (not v0, whose -5 offset makes forward negative already) keeps
    // the "negated from forward" framing intuitive.
    app.allVertices = new float[][]{{0, 0, 0}, {0, 10, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierSkewXY = 18;
    app.User3D.currentTool = app.UITASK.Skew;

    String hint = app.runScriptLine("Decrease Tool Parameter");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.allVertices[1][0] < 0, "backward Skew should shear x the opposite way from forward");
  }

  @Test
  void keyShiftUp_withTwistTool_commitsForwardTwist () {
    app.allVertices = new float[][]{{-1, 0, 0}, {1, 0, 10}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierTwistZ = 18; // same setup as ModifyGeometryTest's own aroundZOnly test
    app.User3D.currentTool = app.UITASK.Twist;

    String hint = app.runScriptLine("Increase Tool Parameter");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertArrayEquals(new float[]{0, 1, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{0, 1, 10}, app.allVertices[1], 0.0001f);
  }

  @Test
  void keyShiftDown_withTwistTool_commitsBackwardTwist_negatedFromForward () {
    // Same single-call setup as keyShiftUp_withTwistTool_
    // commitsForwardTwist above, just direction -1 instead of +1 - NOT
    // a forward-then-backward round trip: a round trip through two
    // separate vertex-selection calls would re-read the selection's
    // bounding-box pivot after the first call has already moved it
    // (see ModifyGeometryTest's own twistedPoint_forwardThenBackward_
    // isAnExactRoundTrip_forASingleActiveAxis for where that claim is
    // actually tested, at the fixed-pivot single-point level). A
    // single backward call from the original, unmoved selection still
    // uses the same pivot the forward call would have, so it's simply
    // the sign-negated result of the forward test above.
    app.allVertices = new float[][]{{-1, 0, 0}, {1, 0, 10}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierTwistZ = 18;
    app.User3D.currentTool = app.UITASK.Twist;

    String hint = app.runScriptLine("Decrease Tool Parameter");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertArrayEquals(new float[]{0, -1, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{0, -1, 10}, app.allVertices[1], 0.0001f);
  }

  @Test
  void keyShiftUp_withBendTool_commitsForwardBend () {
    app.allVertices = new float[][]{{0, 0, 0}, {0, 10, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierBendXY = 18;
    app.User3D.currentTool = app.UITASK.Bend;

    String hint = app.runScriptLine("Increase Tool Parameter");

    assertNotEquals(app.UnrecognizedCommand, hint);
    float r = (float) (10 / Math.PI);
    assertArrayEquals(new float[]{r, 0, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{r, 10, 0}, app.allVertices[1], 0.0001f);
  }

  @Test
  void keyShiftDown_withBendTool_commitsBackwardBend_negatedFromForward () {
    app.allVertices = new float[][]{{0, 0, 0}, {0, 10, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0, 1};
    app.User3D.modifierBendXY = 18;
    app.User3D.currentTool = app.UITASK.Bend;

    String hint = app.runScriptLine("Decrease Tool Parameter");

    assertNotEquals(app.UnrecognizedCommand, hint);
    float r = (float) (10 / Math.PI);
    assertArrayEquals(new float[]{-r, 0, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{-r, 10, 0}, app.allVertices[1], 0.0001f);
  }

  // ================= Save JPG/PNG/TIFF/BMP 3D Graph =======================
  // Each sets only its own one-shot flag (never the other formats'), plus
  // WIN3D.update via view_changed()->WIN3D.revise() - the actual file-
  // extension choice happens later, inside saveRecordedFrame(), which
  // isn't runnable headlessly (real graphics.save() I/O - see test/
  // README.md's "Extending this" section).

  @Test
  void saveJPG3DGraph_setsRecordJPGOnlyAndRevises () {
    String hint = app.runScriptLine("Save JPG 3D Graph");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.WIN3D.record_JPG);
    assertFalse(app.WIN3D.record_PNG);
    assertFalse(app.WIN3D.record_TIFF);
    assertFalse(app.WIN3D.record_BMP);
    assertFalse(app.WIN3D.fullPeriod_IMG);
    assertTrue(app.WIN3D.update);
  }

  @Test
  void savePNG3DGraph_setsRecordPNGOnlyAndRevises () {
    String hint = app.runScriptLine("Save PNG 3D Graph");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.WIN3D.record_PNG);
    assertFalse(app.WIN3D.record_JPG);
    assertFalse(app.WIN3D.record_TIFF);
    assertFalse(app.WIN3D.record_BMP);
    assertFalse(app.WIN3D.fullPeriod_IMG);
    assertTrue(app.WIN3D.update);
  }

  @Test
  void saveTIFF3DGraph_setsRecordTIFFOnlyAndRevises () {
    String hint = app.runScriptLine("Save TIFF 3D Graph");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.WIN3D.record_TIFF);
    assertFalse(app.WIN3D.record_JPG);
    assertFalse(app.WIN3D.record_PNG);
    assertFalse(app.WIN3D.record_BMP);
    assertFalse(app.WIN3D.fullPeriod_IMG);
    assertTrue(app.WIN3D.update);
  }

  @Test
  void saveBMP3DGraph_setsRecordBMPOnlyAndRevises () {
    String hint = app.runScriptLine("Save BMP 3D Graph");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.WIN3D.record_BMP);
    assertFalse(app.WIN3D.record_JPG);
    assertFalse(app.WIN3D.record_PNG);
    assertFalse(app.WIN3D.record_TIFF);
    assertFalse(app.WIN3D.fullPeriod_IMG);
    assertTrue(app.WIN3D.update);
  }

  @Test
  void saveJPG3DGraphFullPeriod_setsRecordJPGAndFullPeriodFlag () {
    String hint = app.runScriptLine("Save JPG 3D Graph (Full-Period)");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.WIN3D.record_JPG);
    assertFalse(app.WIN3D.record_PNG);
    assertFalse(app.WIN3D.record_TIFF);
    assertFalse(app.WIN3D.record_BMP);
    assertTrue(app.WIN3D.fullPeriod_IMG);
    assertTrue(app.WIN3D.update);
  }

  @Test
  void savePNG3DGraphFullPeriod_setsRecordPNGAndFullPeriodFlag () {
    String hint = app.runScriptLine("Save PNG 3D Graph (Full-Period)");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.WIN3D.record_PNG);
    assertFalse(app.WIN3D.record_JPG);
    assertFalse(app.WIN3D.record_TIFF);
    assertFalse(app.WIN3D.record_BMP);
    assertTrue(app.WIN3D.fullPeriod_IMG);
    assertTrue(app.WIN3D.update);
  }

  @Test
  void saveTIFF3DGraphFullPeriod_setsRecordTIFFAndFullPeriodFlag () {
    String hint = app.runScriptLine("Save TIFF 3D Graph (Full-Period)");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.WIN3D.record_TIFF);
    assertFalse(app.WIN3D.record_JPG);
    assertFalse(app.WIN3D.record_PNG);
    assertFalse(app.WIN3D.record_BMP);
    assertTrue(app.WIN3D.fullPeriod_IMG);
    assertTrue(app.WIN3D.update);
  }

  @Test
  void saveBMP3DGraphFullPeriod_setsRecordBMPAndFullPeriodFlag () {
    String hint = app.runScriptLine("Save BMP 3D Graph (Full-Period)");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.WIN3D.record_BMP);
    assertFalse(app.WIN3D.record_JPG);
    assertFalse(app.WIN3D.record_PNG);
    assertFalse(app.WIN3D.record_TIFF);
    assertTrue(app.WIN3D.fullPeriod_IMG);
    assertTrue(app.WIN3D.update);
  }
}
