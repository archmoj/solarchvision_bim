import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// The plain shading-mode commands (extraCommands.pde's __SHADE_WIRE__/
// __SHADE_WHITE__/__SHADE_MATERIALS__/__SHADE_SOLID__/__SHADE_ELEVATION__)
// just set WIN3D.shadingMode to one of SHADE's own constants (plus, for
// WIRE, allFaces.displayEdges) and call view_changed() (a flag-only no-op
// headlessly, like the view-navigation commands in
// ViewNavigationCommandsTest.java) - no drawing. All 5 were at 0% coverage.
// Note the runScriptLine() command strings themselves use a dot, not an
// underscore (e.g. "SHADE.WIRE", runScript.pde's own case label) - only
// the Processing function names (__SHADE_WIRE__ etc.) use underscores.
//
// Deliberately NOT covered here: __SHADE_GLOBAL__ and __SHADE_REAL__,
// which each set a rebuild flag (GlobalSolar_rebuild_array / VertexSolar_
// rebuild_array) before calling regenerate_desired_bakings() - that then
// acts on the flag by calling calculate_GlobalSolar_array()/calculate_
// VertexSolar_array(), two of the heaviest functions in the codebase
// (964/1459 missed instructions on their own, per the coverage report),
// not safe to trigger headlessly in a unit test. __SHADE_VIEWPORT__/
// __PREBAKE_VIEWPORT__ (which call ShadeViewport()/preBakeViewport()
// directly) are excluded for the same reason.
class ShadeModeCommandsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
  }

  @Test
  void shadeWire_setsShadingModeAndForcesDisplayEdgesOn () {
    app.WIN3D.shadingMode = -999;
    app.allFaces.displayEdges = false; // sentinel - SHADE_WIRE must force this back to true

    assertEquals("", app.runScriptLine("SHADE.WIRE"));

    assertEquals(app.SHADE.Surface_Wire, app.WIN3D.shadingMode);
    assertTrue(app.allFaces.displayEdges);
  }

  @Test
  void shadeWhite_setsShadingModeOnly () {
    app.WIN3D.shadingMode = -999;
    app.allFaces.displayEdges = false;

    assertEquals("", app.runScriptLine("SHADE.WHITE"));

    assertEquals(app.SHADE.Surface_White, app.WIN3D.shadingMode);
    assertFalse(app.allFaces.displayEdges, "unlike SHADE_WIRE, this must not touch displayEdges");
  }

  @Test
  void shadeMaterials_setsShadingMode () {
    app.WIN3D.shadingMode = -999;

    assertEquals("", app.runScriptLine("SHADE.MATERIALS"));

    assertEquals(app.SHADE.Surface_Materials, app.WIN3D.shadingMode);
  }

  @Test
  void shadeSolid_setsShadingMode () {
    app.WIN3D.shadingMode = -999;

    assertEquals("", app.runScriptLine("SHADE.SOLID"));

    assertEquals(app.SHADE.Vertex_Solid, app.WIN3D.shadingMode);
  }

  @Test
  void shadeElevation_setsShadingMode () {
    app.WIN3D.shadingMode = -999;

    assertEquals("", app.runScriptLine("SHADE.ELEVATION"));

    assertEquals(app.SHADE.Vertex_Elevation, app.WIN3D.shadingMode);
  }
}
