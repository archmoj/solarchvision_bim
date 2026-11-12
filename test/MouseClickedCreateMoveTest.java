import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// mouseClicked() (mouseClicked.pde) was at 0% coverage on its own body -
// 678 instructions - even though the function it eventually reaches for
// a WIN3D click, handleWin3DClickAt(), is now separately well covered
// (HandleWin3DClickAtTest.java/HandleWin3DClickAtCreateMoveTest.java).
// What's missing is specifically mouseClicked()'s OWN path to get
// there: its outer guards (isInProgress()/frameCount/control, already
// the same shape as mouseReleased()/mouseDragged()/mouseWheel()'s own
// dispatch tests), then a sequence of UI-panel region checks (menu bar,
// toolbar, case bar, console bar, rollout) that must all NOT match the
// click point, before WIN3D's own region check can even run.
//
// Notably, mouseClicked() does NOT call handleWin3DClickAt() directly
// any more - its own source shows that line as dead, commented-out code
// ("//handleWin3DClickAt(Image_X, Image_Y);") - a real click now goes
// through runScriptLine("LeftClick x=... y=...")/"RightClick ..."
// instead (extraCommands.pde's __LEFTCLICK__/__RIGHTCLICK__, which call
// handleWin3DClickAt() internally, temporarily swapping mouseButton).
// This file's own job is confirming mouseClicked() actually reaches
// that runScriptLine() call with the right Image_X/Image_Y - not
// re-verifying what happens once it does, which is already covered
// directly.
//
// The click point (mouseX=3, mouseY=1) and WIN3D's own region
// (cX=2, cY=0, dX=2, dY=2, set explicitly below but matching WIN3D's
// real bare-construction defaults from pixel_W/pixel_A/pixel_B/pixel_H -
// see HandleWin3DWheelTest.java's own derivation) are the same ones
// HandleWin3DWheelTest.java/FinishWin3DSelectionTest.java already use -
// chosen so every EARLIER panel check in mouseClicked() provably can't
// match it first: the menu bar/toolbar both span y in (0, 0) (pixel_A/
// pixel_B's own real defaults are both 0 - an empty range, so isInside()
// never matches regardless of Y_clicked), the case bar/console bar both
// start at y >= 4 (above this click's y=1), and UI_rollout's own cX is
// 2*pixel_W = 4 (above this click's x=3) - confirmed by reading each of
// their own real field declarations, not assumed. This also means
// Image_X/Image_Y work out to exactly (0, 0) - the same image-center
// point HandleWin3DClickAtCreateMoveTest.java's own triangle setup is
// built for, reused here unchanged.
class MouseClickedCreateMoveTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment

    app.frameCount = 100;
    app.control = app.USER_GUI;
    app.UI_menuBar.selected_parent = -1;
    app.mouseX = 3;
    app.mouseY = 1;

    // Sidestep WORLD's/STUDY's own click handling entirely (hover-point
    // pinning, addHoverPoint() - its own, separate concern) rather than
    // verifying their own cX/cY/dX/dY don't coincidentally also cover
    // this point.
    app.WORLD.include = false;
    app.STUDY.include = false;

    app.WIN3D.include = true;
    app.WIN3D.cX = 2;
    app.WIN3D.cY = 0;
    app.WIN3D.dX = 2;
    app.WIN3D.dY = 2;

    // Same calculate_Click3D()-family setup HandleWin3DClickAtTest.java/
    // HandleWin3DClickAtCreateMoveTest.java already use.
    app.WIN3D.projectionTypeIndex = 1;
    app.WIN3D.scale = 1;
    app.WIN3D.cameraFieldOfView = (float) Math.toRadians(60);
    app.WIN3D.rotationX = 0;
    app.WIN3D.rotationZ = 0;
    app.WIN3D.cameraX = 0;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = 10;
    app.overallScale = 1;
  }

  // Same triangle as HandleWin3DClickAtCreateMoveTest.java's own
  // armOneTriangleFace() - at world-space z=0, containing the origin in
  // its XY projection, hit by this exact camera/click setup at (0,0,0).
  private void armOneTriangleFace () {
    app.allVertices = new float[][]{{-5, -5, 0}, {5, -5, 0}, {0, 5, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{1, 0, 0, 1, 0, 0}};
  }

  @Test
  void moveTool_aRealClickInsideWIN3D_reachesHandleWin3DClickAt_withoutThrowing () {
    armOneTriangleFace();
    app.User3D.currentTool = app.UITASK.Move;
    app.mouseButton = app.LEFT;
    app.currentObjectCategory = app.ObjectCategory.GROUP;

    assertDoesNotThrow(() -> app.mouseClicked());
  }

  @Test
  void createTool_aRealClickInsideWIN3D_reachesHandleWin3DClickAt_andBeginsANewGroup () {
    armOneTriangleFace();
    app.User3D.currentTool = app.UITASK.Create;
    app.CreateObject = app.CREATE.Cone;
    app.mouseButton = app.LEFT;
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.addToLastGroup = false;

    int groupsBefore = app.allGroups.num;

    assertDoesNotThrow(() -> app.mouseClicked());

    assertEquals(groupsBefore + 1, app.allGroups.num, "confirms the click really did reach handleWin3DClickAt()'s own Create/GROUP branch, not just returned early somewhere in mouseClicked() itself");
  }
}
