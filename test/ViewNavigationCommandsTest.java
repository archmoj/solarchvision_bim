import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// extraCommands.pde's __PAN__/__ZOOM__/__ORBIT__/__CAMERAROLL__/
// __TARGETROLL__/__ORTHOGRAPHIC__/__PERSPECTIVE__ family (and the siblings
// each shares its name with, like __PANX__/__PANY__) are thin
// runScriptLine() dispatch targets that just set the current tool (and,
// for a couple, a related WIN3D field) via one of the UI_setTo_View_*
// helpers in uiSetTo.pde - no drawing, no file or network access. All 17
// tested here were at 0% coverage, along with the helpers they call.
//
// Deliberately NOT covered: the camera-viewpoint family (TOP/FRONT/LEFT/
// BACK/RIGHT/BOTTOM, and their N.E./N.W./S.E./S.W. corner siblings) -
// those go through WIN3D.apply_currentCameraIndex() and rotateZ_3DViewport_
// around_Selection()/rotateXY_3DViewport_around_Selection(), which (unlike
// everything here) actually move the camera through real geometry, not
// just flip a field - a reasonable next target, but out of scope for this
// pass.
class ViewNavigationCommandsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    // Same reasoning as RunScriptTest.java's own setUp: a fresh app never
    // runs build_allActions() itself (allActions is null until then), and
    // these are exactly the kind of bare, single-word commands that could
    // collide with a same-named menu/toolbar action if allActions were
    // populated (the same hazard class bypassAllActionsFor exists for) -
    // an empty map sidesteps that entirely and always reaches the
    // switch-case dispatch below.
    app.allActions = new java.util.HashMap<>();
  }

  // ================= PAN / PANX / PANY ======================================

  @Test
  void pan_setsCurrentToolToPlainPan () {
    app.User3D.currentTool = -999;

    assertEquals("", app.runScriptLine("PAN"));

    assertEquals(app.UITASK.Pan_TargetRoll, app.User3D.currentTool);
  }

  @Test
  void panX_setsCurrentToolToPanXVariant () {
    app.User3D.currentTool = -999;

    assertEquals("", app.runScriptLine("PANX"));

    assertEquals(app.UITASK.PanX_TargetRoll, app.User3D.currentTool);
  }

  @Test
  void panY_setsCurrentToolToPanYVariant () {
    app.User3D.currentTool = -999;

    assertEquals("", app.runScriptLine("PANY"));

    assertEquals(app.UITASK.PanY_TargetRoll, app.User3D.currentTool);
  }

  // ================= ZOOM / NORMALZOOM ======================================

  @Test
  void zoom_setsCurrentToolButLeavesWIN3DZoomAlone () {
    app.User3D.currentTool = -999;
    app.WIN3D.zoom = 42; // sentinel - ZOOM (n=0) must not touch it

    assertEquals("", app.runScriptLine("ZOOM"));

    assertEquals(app.UITASK.Pan_Height, app.User3D.currentTool);
    assertEquals(42f, app.WIN3D.zoom, 0.0001f);
  }

  @Test
  void normalZoom_setsCurrentToolAndResetsWIN3DZoomTo60 () {
    app.User3D.currentTool = -999;
    app.WIN3D.zoom = 42;

    assertEquals("", app.runScriptLine("NORMALZOOM"));

    assertEquals(app.UITASK.Pan_Height, app.User3D.currentTool);
    assertEquals(60f, app.WIN3D.zoom, 0.0001f);
  }

  // ================= ORBIT / ORBITZ / ORBITXY ===============================

  @Test
  void orbit_setsCurrentToolToPlainOrbit () {
    app.User3D.currentTool = -999;

    assertEquals("", app.runScriptLine("ORBIT"));

    assertEquals(app.UITASK.zoom_Orbit_Pan, app.User3D.currentTool);
  }

  @Test
  void orbitZ_setsCurrentToolAndTargetAxisZero () {
    app.User3D.currentTool = -999;
    app.User3D.toolParameterModifier = -999;
    app.User3D.targetAxisIndex = -999;

    assertEquals("", app.runScriptLine("ORBITZ"));

    assertEquals(app.UITASK.Truck_Orbit, app.User3D.currentTool);
    assertEquals(1, app.User3D.toolParameterModifier);
    assertEquals(0, app.User3D.targetAxisIndex);
  }

  @Test
  void orbitXY_setsCurrentToolAndTargetAxisOne () {
    app.User3D.currentTool = -999;
    app.User3D.toolParameterModifier = -999;
    app.User3D.targetAxisIndex = -999;

    assertEquals("", app.runScriptLine("ORBITXY"));

    assertEquals(app.UITASK.Truck_Orbit, app.User3D.currentTool);
    assertEquals(1, app.User3D.toolParameterModifier);
    assertEquals(1, app.User3D.targetAxisIndex);
  }

  // ================= LANDORBIT ==============================================

  @Test
  void landOrbit_setsCurrentToolToTerrainOrbit () {
    app.User3D.currentTool = -999;

    assertEquals("", app.runScriptLine("LANDORBIT"));

    assertEquals(app.UITASK.TerrainOrbit_Pan_TargetRollZ, app.User3D.currentTool);
  }

  // ================= CAMERAROLL / CAMERAROLLZ / CAMERAROLLXY ================

  @Test
  void cameraRoll_setsCurrentToolToPlainCameraRoll () {
    app.User3D.currentTool = -999;

    assertEquals("", app.runScriptLine("CAMERAROLL"));

    assertEquals(app.UITASK.CameraRoll_Pan, app.User3D.currentTool);
  }

  @Test
  void cameraRollZ_setsCurrentToolAndTargetAxisZero () {
    app.User3D.currentTool = -999;
    app.User3D.toolParameterModifier = -999;
    app.User3D.targetAxisIndex = -999;

    assertEquals("", app.runScriptLine("CAMERAROLLZ"));

    assertEquals(app.UITASK.CameraRollXY_CameraRollZ, app.User3D.currentTool);
    assertEquals(0, app.User3D.toolParameterModifier);
    assertEquals(0, app.User3D.targetAxisIndex);
  }

  @Test
  void cameraRollXY_setsCurrentToolAndTargetAxisOne () {
    app.User3D.currentTool = -999;
    app.User3D.toolParameterModifier = -999;
    app.User3D.targetAxisIndex = -999;

    assertEquals("", app.runScriptLine("CAMERAROLLXY"));

    assertEquals(app.UITASK.CameraRollXY_CameraRollZ, app.User3D.currentTool);
    assertEquals(0, app.User3D.toolParameterModifier);
    assertEquals(1, app.User3D.targetAxisIndex);
  }

  // ================= TARGETROLL / TARGETROLLZ / TARGETROLLXY ================

  @Test
  void targetRoll_setsCurrentToolToPlainTargetRoll () {
    app.User3D.currentTool = -999;

    assertEquals("", app.runScriptLine("TARGETROLL"));

    assertEquals(app.UITASK.TargetRoll_Pan, app.User3D.currentTool);
  }

  @Test
  void targetRollZ_setsCurrentToolAndTargetAxisZero () {
    app.User3D.currentTool = -999;
    app.User3D.toolParameterModifier = -999;
    app.User3D.targetAxisIndex = -999;

    assertEquals("", app.runScriptLine("TARGETROLLZ"));

    assertEquals(app.UITASK.TargetRollXY_TargetRollZ, app.User3D.currentTool);
    assertEquals(0, app.User3D.toolParameterModifier);
    assertEquals(0, app.User3D.targetAxisIndex);
  }

  @Test
  void targetRollXY_setsCurrentToolAndTargetAxisOne () {
    app.User3D.currentTool = -999;
    app.User3D.toolParameterModifier = -999;
    app.User3D.targetAxisIndex = -999;

    assertEquals("", app.runScriptLine("TARGETROLLXY"));

    assertEquals(app.UITASK.TargetRollXY_TargetRollZ, app.User3D.currentTool);
    assertEquals(0, app.User3D.toolParameterModifier);
    assertEquals(1, app.User3D.targetAxisIndex);
  }

  // ================= ORTHOGRAPHIC / PERSPECTIVE =============================

  @Test
  void orthographic_setsWIN3DProjectionTypeIndexToZero () {
    app.WIN3D.projectionTypeIndex = -999;

    assertEquals("", app.runScriptLine("ORTHOGRAPHIC"));

    assertEquals(0, app.WIN3D.projectionTypeIndex);
  }

  @Test
  void perspective_setsWIN3DProjectionTypeIndexToOne () {
    app.WIN3D.projectionTypeIndex = 0; // the opposite of what PERSPECTIVE sets

    assertEquals("", app.runScriptLine("PERSPECTIVE"));

    assertEquals(1, app.WIN3D.projectionTypeIndex);
  }
}
