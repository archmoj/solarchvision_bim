import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Completes handleWin3DClickAt()'s own remaining branches, past
// HandleWin3DClickAtTest.java (PickSelect)/HandleWin3DClickAtCreateMoveTest.java
// (Move + one Create example)/HandleWin3DClickAtCreateDispatchTest.java
// (the rest of Create's dispatch):
//
// - SuperOBJ's own 4 shape sub-classifications (classifySuperOBJShape()).
//   The earlier Create-dispatch test already exercised CreateObject.SuperOBJ
//   once, with every User3D creator* field left at its own bare-
//   construction default - which, traced through classifySuperOBJShape()'s
//   own thresholds against those exact defaults (creatorSuperellipsoidPowerX/
//   Y/Z all default to CubePower), turns out to already be the Box
//   sub-shape, without that test realizing it. This covers the other 3:
//   Parametric, SuperCylinder, Octahedron - plus SuperSphere (the "else"
//   branch, forced via a power triple matching none of the other 3
//   explicit checks) for completeness.
//
// The Pivot/Normal/FirstVertex property-pick sub-branches (User3D.
// toolParameterModifier != 0 && currentTool >= UITASK.Seed_Material) are
// NOT covered here, on purpose, not as an oversight: an earlier version
// of this file assumed they were reachable the same way Seed_Material's
// own wheel-based path is (WheelHandlersTest.java/HandleObjectEditWheelTest.java)
// and all 3 of its tests failed against the real build. Reading the
// actual brace nesting around that code explains why - it sits inside
// "else if (RxP[0] >= 0)", the ELSE of "if (currentTool != Create &&
// currentTool != Move)" - so it only ever runs when currentTool IS
// Create or Move. But UITASK's own declaration order (uiTask.pde) gives
// Create index 19, Move index 20, and Seed_Material index 23 - so
// "currentTool >= UITASK.Seed_Material" can never be true at the same
// time code can only be reached by currentTool being Create or Move,
// both below that threshold. This block is unreachable through
// handleWin3DClickAt() as currently written, for any currentTool value
// at all - not a coverage gap, a real latent dead-code path (or a bug,
// if it was meant to be reachable some other way) worth flagging on its
// own, separate from this test suite's own job of exercising what
// actually runs.
class HandleWin3DClickAtRemainingTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment

    app.WIN3D.projectionTypeIndex = 1;
    app.WIN3D.scale = 1;
    app.WIN3D.cameraFieldOfView = (float) Math.toRadians(60);
    app.WIN3D.rotationX = 0;
    app.WIN3D.rotationZ = 0;
    app.WIN3D.cameraX = 0;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = 10;
    app.overallScale = 1;

    armOneTriangleFace();
    app.mouseButton = app.LEFT;
  }

  // Same triangle every Create/Move/PickSelect test in this suite uses -
  // hit at (0,0,0) by this exact camera setup.
  private void armOneTriangleFace () {
    app.allVertices = new float[][]{{-5, -5, 0}, {5, -5, 0}, {0, 5, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{1, 0, 0, 1, 0, 0}};
  }

  // ================= SuperOBJ shape classification ============================

  @Test
  void create_group_superOBJ_parametric_doesNotThrow_andBeginsANewGroup () {
    app.User3D.creatorSuperellipsoidPowerX = app.CubePower;
    app.User3D.creatorSuperellipsoidPowerY = app.CubePower;
    app.User3D.creatorSuperellipsoidPowerZ = 2;
    app.User3D.currentTool = app.UITASK.Create;
    app.CreateObject = app.CREATE.SuperOBJ;
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    int groupsBefore = app.allGroups.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(groupsBefore + 1, app.allGroups.num);
  }

  @Test
  void create_group_superOBJ_superCylinder_doesNotThrow_andBeginsANewGroup () {
    app.User3D.creatorSuperellipsoidPowerX = 2;
    app.User3D.creatorSuperellipsoidPowerY = 2;
    app.User3D.creatorSuperellipsoidPowerZ = app.CubePower;
    app.User3D.currentTool = app.UITASK.Create;
    app.CreateObject = app.CREATE.SuperOBJ;
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    int groupsBefore = app.allGroups.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(groupsBefore + 1, app.allGroups.num);
  }

  @Test
  void create_group_superOBJ_octahedron_doesNotThrow_andBeginsANewGroup () {
    app.User3D.creatorSuperellipsoidPowerX = 1;
    app.User3D.creatorSuperellipsoidPowerY = 1;
    app.User3D.creatorSuperellipsoidPowerZ = 1;
    app.User3D.currentTool = app.UITASK.Create;
    app.CreateObject = app.CREATE.SuperOBJ;
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    int groupsBefore = app.allGroups.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(groupsBefore + 1, app.allGroups.num);
  }

  @Test
  void create_group_superOBJ_superSphere_doesNotThrow_andBeginsANewGroup () {
    // A power triple matching none of PARAMETRIC/SUPERCYLINDER/BOX/
    // OCTAHEDRON's own exact checks - classifySuperOBJShape()'s own
    // "else" (SuperSphere) branch.
    app.User3D.creatorSuperellipsoidPowerX = 5;
    app.User3D.creatorSuperellipsoidPowerY = 5;
    app.User3D.creatorSuperellipsoidPowerZ = 5;
    app.User3D.currentTool = app.UITASK.Create;
    app.CreateObject = app.CREATE.SuperOBJ;
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    int groupsBefore = app.allGroups.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(groupsBefore + 1, app.allGroups.num);
  }
}
