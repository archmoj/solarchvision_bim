import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// handleWin3DWheel() (mouseWheel.pde) has 2 of its own early-return
// guards - WIN3D.include, and whether (X_clicked, Y_clicked) falls
// inside WIN3D's own screen rectangle (cX/cY to cX+dX/cY+dY) - in front
// of Select3D.getPivot() + handleObjectEditWheel()/handleViewportWheel().
// Both guards, and the dispatch past them, were at 0% coverage on this
// function itself, even though handleObjectEditWheel() is separately
// covered (HandleObjectEditWheelTest.java) and handleViewportWheel() was
// already partially covered elsewhere.
//
// On a bare app, X_clicked defaults to -1 (globalVariables.pde) - always
// outside WIN3D's own rectangle (cX=2..cX+dX=4 at bare-construction
// pixel_W/pixel_A/pixel_B/pixel_H defaults), which is why the "inside"
// test below sets X_clicked/Y_clicked explicitly into that rectangle
// rather than relying on any default position.
class HandleWin3DWheelTest {

  private solarchvision_bim app;

  // Shared "is the property-edit branch reached" probe, reused from
  // WheelHandlersTest.java/HandleObjectEditWheelTest.java's own setup:
  // a single selected face, Seed_Material tool, toolParameterModifier 0 -
  // handleObjectEditWheel()'s own property branch flips its material by
  // -wheelValue (clamped) if, and only if, handleWin3DWheel() actually
  // reaches it.
  private void armPropertyEditProbe () {
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{3, 0, 0, 1, 0, 0}};
    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.User3D.currentTool = app.UITASK.Seed_Material;
    app.User3D.toolParameterModifier = 0;
  }

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
  }

  @Test
  void whenWin3DIsNotIncluded_returnsImmediately_dispatchingToNothing () {
    app.WIN3D.include = false;
    app.X_clicked = 3;
    app.Y_clicked = 1; // inside the rectangle - would otherwise dispatch
    armPropertyEditProbe();

    assertDoesNotThrow(() -> app.handleWin3DWheel(1));

    assertEquals(3, app.allFaces.getMaterial(0), "unchanged - must return before ever reaching the property-edit branch");
  }

  @Test
  void whenTheClickIsOutsideWIN3DsOwnRectangle_returnsImmediately () {
    app.WIN3D.include = true;
    // X_clicked's own bare-construction default (-1) is already outside
    // WIN3D's rectangle - left untouched here to double as that case.
    armPropertyEditProbe();

    assertDoesNotThrow(() -> app.handleWin3DWheel(1));

    assertEquals(3, app.allFaces.getMaterial(0));
  }

  @Test
  void whenIncludedAndInsideTheRectangle_dispatchesThroughToObjectEdit () {
    app.WIN3D.include = true;
    app.X_clicked = 3; // strictly between WIN3D.cX (2) and cX+dX (4)
    app.Y_clicked = 1; // strictly between WIN3D.cY (0) and cY+dY (2)
    armPropertyEditProbe();

    app.handleWin3DWheel(1);

    assertEquals(2, app.allFaces.getMaterial(0), "the property-edit branch must have been reached and applied its -1 delta");
  }
}
