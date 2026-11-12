import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// handleObjectEditWheel() (mouseWheel.pde) picks one of 4 independent
// branches by User3D.currentTool/toolParameterModifier: Rotate ->
// handleRotateWheel() -> +RotateSelection -> Rotate3D.selection();
// Scale -> handleScaleWheel() -> +ScaleSelection -> Scale3D.selection();
// Move -> handleMoveWheel() -> Move (the bare command) -> Move3D.selection();
// and, when toolParameterModifier == 0 and currentTool is one of the
// property tools (>= UITASK.Seed_Material), handlePropertyEditWheel() ->
// +EditSelection -> Edit3D.selection() - already covered directly by
// WheelHandlersTest.java, reused here to exercise handleObjectEditWheel()'s
// OWN dispatch to it. All 4 branches were at 0% coverage on
// handleObjectEditWheel() itself (51 missed instructions), even though
// some of what each one calls was separately covered elsewhere.
//
// Rotate3D.selection()/Scale3D.selection()/Move3D.selection() each
// dispatch further by currentObjectCategory (default: GROUP) to a method
// that loops over the matching Select3D *Selection array - empty by
// default, the same "safe no-op on empty state" shape
// SelectionConversionCommandsTest.java already relies on for Select3D's
// own convert_* methods.
class HandleObjectEditWheelTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
  }

  @Test
  void rotateTool_onAnEmptySelection_doesNotThrow () {
    app.User3D.currentTool = app.UITASK.Rotate;

    assertDoesNotThrow(() -> app.handleObjectEditWheel(1, 0, 0, 0));
  }

  @Test
  void scaleTool_onAnEmptySelection_doesNotThrow () {
    app.User3D.currentTool = app.UITASK.Scale;

    assertDoesNotThrow(() -> app.handleObjectEditWheel(1, 0, 0, 0));
  }

  @Test
  void moveTool_onAnEmptySelection_doesNotThrow () {
    app.User3D.currentTool = app.UITASK.Move;

    assertDoesNotThrow(() -> app.handleObjectEditWheel(1, 0, 0, 0));
  }

  @Test
  void propertyTool_withToolParameterModifierZero_adjustsTheSelectedFacesMaterial () {
    // Exact same setup WheelHandlersTest.java's own
    // handlePropertyEditWheel_negatesTheWheelValueAndAdjustsTheSelectedFacesMaterial
    // test verifies in detail - here exercised through
    // handleObjectEditWheel()'s own "toolParameterModifier == 0 &&
    // currentTool >= Seed_Material" branch instead of calling
    // handlePropertyEditWheel() directly.
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{3, 0, 0, 1, 0, 0}};
    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.User3D.currentTool = app.UITASK.Seed_Material;
    app.User3D.toolParameterModifier = 0;

    app.handleObjectEditWheel(1, 0, 0, 0);

    assertEquals(2, app.allFaces.getMaterial(0));
  }

  @Test
  void propertyTool_withToolParameterModifierNonZero_doesNotDispatchToPropertyEdit () {
    // "toolParameterModifier == 0" is a required part of this branch's
    // own guard (mouseWheel.pde) - a non-zero modifier must leave the
    // selected face's material untouched, even with a property tool
    // selected.
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{3, 0, 0, 1, 0, 0}};
    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.User3D.currentTool = app.UITASK.Seed_Material;
    app.User3D.toolParameterModifier = 1;

    app.handleObjectEditWheel(1, 0, 0, 0);

    assertEquals(3, app.allFaces.getMaterial(0), "unchanged - toolParameterModifier must be 0 for this branch to fire");
  }

  @Test
  void aToolMatchingNoBranch_changesNothing () {
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{3, 0, 0, 1, 0, 0}};
    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.User3D.currentTool = app.UITASK.zoom_Orbit_Pan; // not Rotate/Scale/Move, and below Seed_Material
    app.User3D.toolParameterModifier = 0;

    assertDoesNotThrow(() -> app.handleObjectEditWheel(1, 0, 0, 0));

    assertEquals(3, app.allFaces.getMaterial(0));
  }
}
