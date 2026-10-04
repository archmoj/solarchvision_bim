import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// WIN3DTest.java already covers each key handler (handleCommandKey,
// handleArrowKeys, etc.) dispatching correctly to these actions by
// name - this instead covers the actions themselves, invoked directly
// via runScriptLine (as command/*.txt scripts, or anything else
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

  // ================= WIN3D Shift+Tab (impact type cycling) ===============

  @Test
  void keyShiftTab_cyclesImpactTypeAndWrapsAround () {
    app.WIN3D.impactTypeIndex = app.numberOfImpactVariations - 1; // at the last one

    String hint = app.runScriptLine("Toggle Impact Type");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(0, app.WIN3D.impactTypeIndex);
  }

  @Test
  void keyShiftTab_flagsGlobalSolarForRebuildWhenThatShadeModeIsActive () {
    app.WIN3D.shadingMode = app.SHADE.Global_Solar;
    app.GlobalSolar_rebuild_array = false;
    app.VertexSolar_rebuild_array = false;

    app.runScriptLine("Toggle Impact Type");

    assertTrue(app.GlobalSolar_rebuild_array);
    assertFalse(app.VertexSolar_rebuild_array);
  }

  @Test
  void keyShiftTab_flagsVertexSolarForRebuildWhenThatShadeModeIsActive () {
    app.WIN3D.shadingMode = app.SHADE.Vertex_Solar;
    app.GlobalSolar_rebuild_array = false;
    app.VertexSolar_rebuild_array = false;

    app.runScriptLine("Toggle Impact Type");

    assertFalse(app.GlobalSolar_rebuild_array);
    assertTrue(app.VertexSolar_rebuild_array);
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

  // "Wraps" here means the step gets reverted right back to the boundary
  // it started from (Tropo3D.i_Map += delta; if over endHour, -= delta
  // again), not a jump to the opposite end - staying at endHour is the
  // actual, correct behavior, confirmed by reading the action's own body
  // rather than assumed.
  @Test
  void keyT_atEndHour_revertsBackToEndHourInsteadOfGoingPastIt () {
    app.STUDY.startHour = 0;
    app.STUDY.endHour = 23;
    app.Tropo3D.i_Map = app.STUDY.endHour;

    String hint = app.runScriptLine("Advance Troposphere Time");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(app.STUDY.endHour, app.Tropo3D.i_Map, 0.0001f);
  }

  @Test
  void keyT_belowEndHour_advancesByTropoDeltaTime () {
    app.STUDY.startHour = 0;
    app.STUDY.endHour = 23;
    app.Tropo3D.i_Map = app.STUDY.startHour;

    app.runScriptLine("Advance Troposphere Time");

    assertEquals(app.STUDY.startHour + app.TROPO_deltaTime, app.Tropo3D.i_Map, 0.0001f);
  }

  @Test
  void keyShiftT_atStartHour_revertsBackToStartHourInsteadOfGoingPastIt () {
    app.STUDY.startHour = 0;
    app.STUDY.endHour = 23;
    app.Tropo3D.i_Map = app.STUDY.startHour;

    String hint = app.runScriptLine("Rewind Troposphere Time");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(app.STUDY.startHour, app.Tropo3D.i_Map, 0.0001f);
  }

  @Test
  void keyShiftT_aboveStartHour_rewindsByTropoDeltaTime () {
    app.STUDY.startHour = 0;
    app.STUDY.endHour = 23;
    app.Tropo3D.i_Map = app.STUDY.endHour;

    app.runScriptLine("Rewind Troposphere Time");

    assertEquals(app.STUDY.endHour - app.TROPO_deltaTime, app.Tropo3D.i_Map, 0.0001f);
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
  void keyShiftD_rewindsDisplayDayAndWrapsAtZero () {
    app.STUDY.endDay = 5;
    app.impactDisplayDay = 0;

    String hint = app.runScriptLine("Previous Impact Day");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(5, app.impactDisplayDay);
  }

  // ================= WIN3D Enter ==========================================

  @Test
  void keyEnter_flagsGlobalSolarForRebuildWhenThatShadeModeIsActive () {
    app.WIN3D.shadingMode = app.SHADE.Global_Solar;
    app.GlobalSolar_rebuild_array = false;
    app.VertexSolar_rebuild_array = false;

    String hint = app.runScriptLine("Recalculate Solar Impact");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.GlobalSolar_rebuild_array);
    assertFalse(app.VertexSolar_rebuild_array);
  }

  @Test
  void keyEnter_doesNotFlagEitherRebuildWhenShadeModeIsUnrelated () {
    app.WIN3D.shadingMode = app.SHADE.Surface_White;
    app.GlobalSolar_rebuild_array = false;
    app.VertexSolar_rebuild_array = false;

    app.runScriptLine("Recalculate Solar Impact");

    assertFalse(app.GlobalSolar_rebuild_array);
    assertFalse(app.VertexSolar_rebuild_array);
  }

  // ================= WIN3D ShadeTime+1/-1/+Day/-Day ========================

  @Test
  void keyShadeTimePlus1_stepsForwardByOneHour () {
    app.SHADE_HOUR_ANGLE = 0;
    app.SHADE_DATE_ANGLE = 0;

    String hint = app.runScriptLine("Shade Time +1 Hour");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(1, app.SHADE_HOUR_ANGLE);
  }

  @Test
  void keyShadeTimeMinus1_stepsBackwardByOneHour () {
    app.SHADE_HOUR_ANGLE = app.SHADE_LAST_HOUR;
    app.SHADE_DATE_ANGLE = 0;

    String hint = app.runScriptLine("Shade Time -1 Hour");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(app.SHADE_LAST_HOUR - 1, app.SHADE_HOUR_ANGLE);
  }

  @Test
  void keyShadeTimePlusDay_stepsForwardByAFullDay () {
    app.SHADE_HOUR_ANGLE = app.SHADE_FIRST_HOUR;
    app.SHADE_DATE_ANGLE = 0;

    String hint = app.runScriptLine("Shade Time +1 Day");

    assertNotEquals(app.UnrecognizedCommand, hint);
    // A full day's worth of hourly steps (SHADE_HOURS_PER_DAY + 1) wraps
    // the hour back to FIRST_HOUR and advances the date by one step.
    assertEquals(app.SHADE_FIRST_HOUR, app.SHADE_HOUR_ANGLE);
    assertEquals(app.SHADE_STEP_DAYS, app.SHADE_DATE_ANGLE);
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
    app.WIN3D.currentTool = app.UITASK.Rotate;

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
    app.WIN3D.currentTool = app.UITASK.Move;

    String hint = app.runScriptLine("Decrease Tool Parameter");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(0f, app.allVertices[0][0], 0.0001f);
    assertEquals(0f, app.allVertices[0][1], 0.0001f);
    assertEquals(-0.5f, app.allVertices[0][2], 0.0001f);
  }
}
