import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// mouseWheel.pde's handlePropertyEditWheel()/handleCameraRollXYZWheel()
// are thin wrappers that build a "+EditSelection"/"+CameraRollXYZ"
// command string from their own float argument and dispatch it through
// runScriptLine() - the same shape as RotateCameraHelpersTest.java's
// rotateCameraXY() et al. Both were at 0% coverage.
//
// handleCameraRollXYZWheel() reaches +CAMERAROLLXYZ, the exact mechanism
// OrbitSelectionCommandsTest.java already verifies in detail.
//
// handlePropertyEditWheel() reaches +EditSelection -> __$EDITSELECTION__()
// -> beginScene3DChange(); Edit3D.selection(pEdit); endScene3DChange();.
// Edit3D.selection() is pure *Selection-array logic (the same shape as
// SelectionConversionCommandsTest.java's convert_* methods, confirmed
// safe there), and beginScene3DChange()/endScene3DChange()'s own undo-
// history hooks (beginUndoableScene3DEdit()/commitUndoableScene3DEdit())
// both no-op on a bare app - undoRedoScene3D.pde's own comments confirm
// scene3DHistoryIndex stays -1 ("until seedScene3DHistory() runs once at
// startup") until that explicit seeding call, which neither of these
// functions make, and both check it before doing anything consequential
// - the exact scenario UndoRedoTest.java's own
// beginScene3DChange_beforeSeedScene3DHistoryHasRun_recordsNothing test
// documents. No undo-history setup is needed here as a result.
class WheelHandlersTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
  }

  // ================= handleCameraRollXYZWheel ===============================

  @Test
  void handleCameraRollXYZWheel_withTargetAxisZero_addsPlainDeltaToRotationX () {
    app.WIN3D.rotationStep = 1;
    app.User3D.targetAxisIndex = 0;
    app.WIN3D.rotationX = 5;

    app.handleCameraRollXYZWheel(4);

    assertEquals(5 + 4 * 1, app.WIN3D.rotationX, 0.0001f); // 9 - see OrbitSelectionCommandsTest.java for the formula
  }

  @Test
  void handleCameraRollXYZWheel_withTargetAxisOne_addsPlainDeltaToRotationZ () {
    app.WIN3D.rotationStep = 1;
    app.User3D.targetAxisIndex = 1;
    app.WIN3D.rotationZ = 5;

    app.handleCameraRollXYZWheel(4);

    assertEquals(5 + 4 * 1, app.WIN3D.rotationZ, 0.0001f); // 9
  }

  // ================= handlePropertyEditWheel =================================

  @Test
  void handlePropertyEditWheel_onAnEmptySelection_doesNotThrow () {
    assertDoesNotThrow(() -> app.handlePropertyEditWheel(1));
  }

  @Test
  void handlePropertyEditWheel_negatesTheWheelValueAndAdjustsTheSelectedFacesMaterial () {
    // One minimal face (its node ids don't matter here), material 3,
    // selected, with the tool set to Seed_Material (the "m" rollout
    // control - adjustFaceProperties()'s own first branch, faces.pde).
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{3, 0, 0, 1, 0, 0}}; // {material, tessellation, layer, visibility, weight, close}
    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.User3D.currentTool = app.UITASK.Seed_Material;

    // __$EDITSELECTION__'s own "int pEdit = int(-wheelValue);" - a wheel
    // value of 1 becomes a property delta of -1.
    app.handlePropertyEditWheel(1);

    assertEquals(2, app.allFaces.getMaterial(0));
  }

  @Test
  void handlePropertyEditWheel_clampsTheResultRatherThanGoingOutOfRange () {
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{0, 0, 0, 1, 0, 0}}; // material already at its floor, 0
    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.User3D.currentTool = app.UITASK.Seed_Material;

    app.handlePropertyEditWheel(1); // would drive material to -1 unclamped

    assertEquals(0, app.allFaces.getMaterial(0), "adjustFaceProperties()'s own clamp(..., 0, 8) must hold the floor");
  }
}
