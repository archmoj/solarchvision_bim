import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// A further 12 of extraCommands.pde's single-word view commands -
// DISTZ/DISTC/DISTP, SIZEALL/SIZESKY/SIZE3D, TRUCKZ/TRUCKX/TRUCKY,
// LOOKORG/LOOKDIR/LOOKSEL - each a thin runScriptLine() dispatch straight
// to one of uiSetTo.pde's UI_setTo_View_* helpers. Per UiSetToModifyAndViewTest.java's
// own header comment, these are "the same kind of pure tool-mode switch"
// as the Create family: User3D.currentTool plus a small handful of int
// fields, not real camera math - confirmed headlessly safe there already
// for LookAtSelection/LookAtOrigin specifically. All 12 commands below
// were at 0% coverage (the UI_setTo_View_* helpers themselves were
// already covered via UiSetToModifyAndViewTest.java's direct calls - this
// file is about the thin runScriptLine() dispatch wrappers on top).
//
// Deliberately NOT covered here: ALLVIEWPORTS/ENLARGE3D (UI_setTo_
// Viewport(n)), which call update_frame_layout() -> createGraphics() - a
// known NullPointerException without a real sketch surface, the same one
// LoadProjectTest.java/UiSetToModifyAndViewTest.java's own comments
// document throughout this suite.
class ViewToolCommandsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
  }

  // ================= DISTZ / TRUCKZ (both call UI_setTo_View_Truck(0)) ======
  // Pinned as a pair deliberately: as written, __DISTZ__ and __TRUCKZ__
  // are literally identical (both call UI_setTo_View_Truck(0)) - real,
  // current behavior, not an assumption this test papers over.

  @Test
  void distZ_setsCurrentToolToPlainZoomOrbitPan () {
    app.User3D.currentTool = -999;

    assertEquals("", app.runScriptLine("DISTZ"));

    assertEquals(app.UITASK.zoom_Orbit_Pan, app.User3D.currentTool);
  }

  @Test
  void truckZ_behavesIdenticallyToDistZ () {
    app.User3D.currentTool = -999;

    assertEquals("", app.runScriptLine("TRUCKZ"));

    assertEquals(app.UITASK.zoom_Orbit_Pan, app.User3D.currentTool);
  }

  // ================= TRUCKX / TRUCKY ========================================

  @Test
  void truckX_setsCurrentToolAndTargetAxisZero () {
    app.User3D.currentTool = -999;
    app.User3D.toolParameterModifier = -999;
    app.User3D.targetAxisIndex = -999;

    assertEquals("", app.runScriptLine("TRUCKX"));

    assertEquals(app.UITASK.Truck_Orbit, app.User3D.currentTool);
    assertEquals(0, app.User3D.toolParameterModifier);
    assertEquals(0, app.User3D.targetAxisIndex);
  }

  @Test
  void truckY_setsCurrentToolAndTargetAxisOne () {
    app.User3D.currentTool = -999;
    app.User3D.toolParameterModifier = -999;
    app.User3D.targetAxisIndex = -999;

    assertEquals("", app.runScriptLine("TRUCKY"));

    assertEquals(app.UITASK.Truck_Orbit, app.User3D.currentTool);
    assertEquals(0, app.User3D.toolParameterModifier);
    assertEquals(1, app.User3D.targetAxisIndex);
  }

  // ================= DISTC / DISTP ==========================================

  @Test
  void distC_setsCurrentToolToCameraDistanceMode () {
    app.User3D.currentTool = -999;

    assertEquals("", app.runScriptLine("DISTC"));

    assertEquals(app.UITASK.CameraDistance_TargetRollXY_TargetRollZ, app.User3D.currentTool);
  }

  @Test
  void distP_setsCurrentToolToDistMouseXYMode () {
    app.User3D.currentTool = -999;

    assertEquals("", app.runScriptLine("DISTP"));

    assertEquals(app.UITASK.DistMouseXY_TargetRollXY_TargetRollZ, app.User3D.currentTool);
  }

  // ================= SIZEALL / SIZESKY / SIZE3D =============================

  @Test
  void sizeAll_setsCurrentToolToAllModelSize () {
    app.User3D.currentTool = -999;

    assertEquals("", app.runScriptLine("SIZEALL"));

    assertEquals(app.UITASK.AllModelSize, app.User3D.currentTool);
  }

  @Test
  void sizeSky_setsCurrentToolToSkydomeSize () {
    app.User3D.currentTool = -999;

    assertEquals("", app.runScriptLine("SIZESKY"));

    assertEquals(app.UITASK.SkydomeSize, app.User3D.currentTool);
  }

  @Test
  void size3D_setsCurrentToolToModelSizePanTargetRoll () {
    app.User3D.currentTool = -999;

    assertEquals("", app.runScriptLine("SIZE3D"));

    assertEquals(app.UITASK.ModelSize_Pan_TargetRoll, app.User3D.currentTool);
  }

  // ================= LOOKDIR ================================================

  @Test
  void lookDir_setsCurrentToolToLookAtDirection () {
    app.User3D.currentTool = -999;

    assertEquals("", app.runScriptLine("LOOKDIR"));

    assertEquals(app.UITASK.LookAtDirection, app.User3D.currentTool);
  }

  // ================= LOOKORG ================================================
  // UI_setTo_View_LookAtOrigin() zeroes WIN3D's position, then - "automatically
  // set another choice of interest" (its own comment) - delegates to
  // UI_setTo_View_Truck(0), the exact same tool DISTZ/TRUCKZ land on above.

  @Test
  void lookOrg_zeroesWIN3DPositionAndSetsCurrentToolViaTruck () {
    app.WIN3D.positionX = 11;
    app.WIN3D.positionY = 22;
    app.WIN3D.positionZ = 33;
    app.User3D.currentTool = -999;

    assertEquals("", app.runScriptLine("LOOKORG"));

    assertEquals(0f, app.WIN3D.positionX, 0.0001f);
    assertEquals(0f, app.WIN3D.positionY, 0.0001f);
    assertEquals(0f, app.WIN3D.positionZ, 0.0001f);
    assertEquals(app.UITASK.zoom_Orbit_Pan, app.User3D.currentTool);
  }

  // ================= LOOKSEL ================================================
  // UI_setTo_View_LookAtSelection() also runs real rotation math
  // (WIN3D.look_3DViewport_towards_Selection(), confirmed headlessly safe
  // by UiSetToModifyAndViewTest.java) before - same "automatically set
  // another choice of interest" pattern as LOOKORG above - delegating to
  // UI_setTo_View_CameraDistance(0). Only that final, deterministic
  // delegation is asserted on here; the rotation math itself is exercised
  // as a side effect but not re-verified (UiSetToModifyAndViewTest.java's
  // own job).

  @Test
  void lookSel_setsCurrentToolToCameraDistanceModeViaItsOwnDelegation () {
    app.User3D.currentTool = -999;

    assertEquals("", app.runScriptLine("LOOKSEL"));

    assertEquals(app.UITASK.CameraDistance_TargetRollXY_TargetRollZ, app.User3D.currentTool);
  }
}
