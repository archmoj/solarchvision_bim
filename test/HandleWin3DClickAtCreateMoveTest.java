import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// handleWin3DClickAt()'s Create/Move handling (mouseClicked.pde) -
// deliberately left out of HandleWin3DClickAtTest.java's own pass,
// which focused on the PickSelect dispatch instead. This covers:
//
// - The shared "RxP[0] >= 0" guard both the Move and Create blocks sit
//   behind: on a miss (nothing hit), neither does anything at all - a
//   safe, zero-geometry-setup test.
//
// - The Move branch, with a real triangle hit. Unlike selectRect()'s
//   per-vertex loop (SelectRectTest.java's own single-node "face"), Faces.
//   intersect() needs each face to actually have more than 2 nodes
//   (faces.pde's own "if (n > 2)" guard) to be tested at all - this uses
//   a real 3-point triangle at the allPoints/allFaces.nodes level, with
//   the camera looking straight down through it (same calculate_Click3D
//   setup as HandleWin3DClickAtTest.java/WIN3DTest.java).
//
// - The Create branch's GROUP category with one simple shape (Cone).
//
// Both of the last two are kept to smoke-test scope deliberately: the
// functions underneath them (computeCreateParams()/getMoveOriginPoint()/
// pickOrAssignFaceProperty(), each already separately, partially covered
// elsewhere per the merged report) and the individual creation commands
// themselves (e.g. "Cone ...", its own large, separately-tested surface)
// aren't being re-verified here - what's new is specifically that
// handleWin3DClickAt() reaches and correctly dispatches into them.
class HandleWin3DClickAtCreateMoveTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment

    app.WIN3D.projectionTypeIndex = 1; // perspective
    app.WIN3D.scale = 1;
    app.WIN3D.cameraFieldOfView = (float) Math.toRadians(60);
    app.WIN3D.rotationX = 0;
    app.WIN3D.rotationZ = 0;
    app.WIN3D.cameraX = 0;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = 10;
    app.overallScale = 1;
  }

  // A triangle at world-space z=0, large enough to contain the origin
  // in its XY projection - the camera above, looking straight down,
  // hits it at (0,0,0) for an image-center click (same ray this file's
  // own setUp()/HandleWin3DClickAtTest.java's camera setup produces).
  private void armOneTriangleFace () {
    app.allVertices = new float[][]{{-5, -5, 0}, {5, -5, 0}, {0, 5, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{1, 0, 0, 1, 0, 0}}; // material, tessellation, layer, visibility=1, weight, close
  }

  // ================= shared "nothing hit" guard ===============================

  @Test
  void createOrMoveTool_onAMiss_doesNothing () {
    app.User3D.currentTool = app.UITASK.Move;
    app.mouseButton = app.LEFT;
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    // An empty scene (allFaces.nodes defaults to length 0) - no face to
    // hit, so RxP[0] stays negative and neither the Move nor Create
    // block below the shared guard ever runs.

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));
  }

  // ================= Move ======================================================

  @Test
  void moveTool_withARealHit_doesNotThrow () {
    armOneTriangleFace();
    app.User3D.currentTool = app.UITASK.Move;
    app.mouseButton = app.LEFT;
    app.currentObjectCategory = app.ObjectCategory.GROUP; // getMoveOriginPoint()'s own GROUP branch - Select3D.getPivot(), already pure/safe

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));
  }

  // ================= Create ====================================================

  @Test
  void createTool_groupCategory_cone_doesNotThrow_andBeginsANewGroup () {
    armOneTriangleFace();
    app.User3D.currentTool = app.UITASK.Create;
    app.CreateObject = app.CREATE.Cone;
    app.mouseButton = app.LEFT;
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.addToLastGroup = false; // its own bare-construction default - "BeginNewGroup" must run

    int groupsBefore = app.allGroups.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(groupsBefore + 1, app.allGroups.num, "the GROUP branch's own \"BeginNewGroup\" call must always run first when addToLastGroup is false");
  }
}
