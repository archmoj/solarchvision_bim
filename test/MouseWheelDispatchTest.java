import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import processing.event.MouseEvent;

// mouseWheel(MouseEvent) itself - as opposed to the handler functions it
// calls, most of which were already separately covered by
// MouseWheelTest.java's own direct calls - was at 0% coverage: its own
// 4 early-return guards (frameCount vs Last_initializationStep,
// UI_menuBar.selected_parent, the "wheel events arrive in pairs on some
// platforms; only act on every second one" mouseWheelConsume logic,
// control != USER_GUI) and its full dispatch to handleCaseBarWheel()/
// handlePickListWheel()/handleWorldZoomWheel()/handleWin3DWheel().
//
// handleCaseBarWheel() itself was also at 0% coverage (never called from
// MouseWheelTest.java's own tests, which go straight to its own
// per-case-bar-item handlers instead) - confirmed safe here too: it only
// compares X_clicked/Y_clicked (-1/-1 by bare-construction default)
// against isInside() checks over UI_caseBar.Items, a literal, non-null
// array - never matching, so no sub-handler ever fires on a fresh app.
//
// Builds a real processing.event.MouseEvent via its own public
// constructor (nativeObject, millis, action, modifiers, x, y, button,
// count) - the same class/constructor Processing itself uses to build
// the event this method receives; WHEEL is MouseEvent's own action
// constant.
class MouseWheelDispatchTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
  }

  private MouseEvent wheelEvent (int count) {
    return new MouseEvent(null, 0, MouseEvent.WHEEL, 0, 0, 0, 0, count);
  }

  @Test
  void beforeInitializationHasFinished_returnsImmediately () {
    // frameCount's own bare-construction default (0) is already <=
    // Last_initializationStep's default (25) - left untouched here to
    // double as that case, same reasoning as the mouseReleased()/
    // mouseDragged() dispatch tests use. This guard is the very first
    // line of the function, before mouseWheelConsume is ever touched -
    // unlike the "menu is open" guard right after it, which also comes
    // before the increment.
    app.mouseWheelConsume = 0;

    assertDoesNotThrow(() -> app.mouseWheel(wheelEvent(1)));

    assertEquals(0, app.mouseWheelConsume, "unchanged - this is the first guard, before mouseWheelConsume is ever touched");
  }

  @Test
  void whenAMenuIsOpen_returnsImmediately () {
    app.frameCount = 100;
    app.UI_menuBar.selected_parent = 0; // any menu index other than -1
    app.mouseWheelConsume = 0;

    assertDoesNotThrow(() -> app.mouseWheel(wheelEvent(1)));

    assertEquals(0, app.mouseWheelConsume, "unchanged - this guard comes before the increment");
  }

  @Test
  void theFirstOfEachPairedWheelEvent_isConsumedWithoutDispatching () {
    app.frameCount = 100;
    app.UI_menuBar.selected_parent = -1;
    app.mouseWheelConsume = 0; // about to become 1 (odd) - "eaten"
    app.control = app.USER_GUI;

    assertDoesNotThrow(() -> app.mouseWheel(wheelEvent(1)));

    assertEquals(1, app.mouseWheelConsume, "left at 1 (odd) - the reset to 0 only happens on the second, dispatching call");
  }

  @Test
  void whenControlIsNotUserGui_returnsImmediately () {
    app.frameCount = 100;
    app.UI_menuBar.selected_parent = -1;
    app.mouseWheelConsume = 1; // about to become 2 (even) - passes the pairing guard
    app.control = app.USER_AUTO;

    assertDoesNotThrow(() -> app.mouseWheel(wheelEvent(1)));

    assertEquals(0, app.mouseWheelConsume, "reset to 0 still happens - it's unconditional once the pairing guard itself passes");
  }

  @Test
  void aFullSecondOfThePair_dispatchesThroughToHandleWin3DWheel () {
    app.frameCount = 100;
    app.UI_menuBar.selected_parent = -1;
    app.mouseWheelConsume = 1; // -> 2 (even) -> resets to 0, passes
    app.control = app.USER_GUI;
    app.mouseX = 3; // strictly inside WIN3D's own rectangle - see HandleWin3DWheelTest.java
    app.mouseY = 1;
    app.WIN3D.include = true;

    // Same property-edit probe HandleWin3DWheelTest.java uses, to prove
    // handleWin3DWheel() was actually reached by the end of this call.
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{3, 0, 0, 1, 0, 0}};
    app.Select3D.faceSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.User3D.currentTool = app.UITASK.Seed_Material;
    app.User3D.toolParameterModifier = 0;

    app.mouseWheel(wheelEvent(1));

    assertEquals(0, app.mouseWheelConsume);
    assertEquals(2, app.allFaces.getMaterial(0), "handleWin3DWheel() -> handleObjectEditWheel()'s own property-edit branch must have fired");
  }
}
