import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Confirms mouseClicked()'s own WIN3D solar-impact-overlay left-click
// branch (mouseClicked.pde) actually registers a new WIN3D pin's
// win3DHoverPointOffsetFrac entry (hoverOnSolarImpactOverlay.pde) - not
// just that addHoverPoint() itself works (already covered elsewhere),
// but that the real click path computes the offset from WIN3D's own
// panel center, AS A FRACTION of WIN3D's own current dX/dY, and stores
// it against the exact row it just created. Mirrors
// MouseClickedStudyHoverPinTest.java's own approach and its same bare-
// construction pixel_A/pixel_B/pixel_C/pixel_D/pixel_H defaults for why
// every earlier UI-panel guard in mouseClicked() provably can't match
// the click point chosen here.
class MouseClickedWin3DHoverPinTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>();
    app.build_allActions();

    app.frameCount = 100;
    app.control = app.USER_GUI;
    app.UI_menuBar.selected_parent = -1;

    // Sidestep WORLD's/STUDY's own click handling entirely - this file's
    // own concern is WIN3D's overlay-pin branch specifically.
    app.WORLD.include = false;
    app.STUDY.include = false;

    app.WIN3D.include = true;
    app.WIN3D.cX = 990;
    app.WIN3D.cY = 490;
    app.WIN3D.dX = 50;
    app.WIN3D.dY = 50;

    // The overlay must actually be showing, with real fit/image data, or
    // mouseClicked()'s own WIN3D branch falls through to the ordinary
    // click-to-act path (runScriptLine("LeftClick ...")) instead of
    // pinning anything.
    app.showSolarImpactOverlay = true;
    app.WIN3D_layers_img = new processing.core.PImage(10, 10, processing.core.PConstants.ARGB);
    app.WIN3D_layers_fit = new float[]{ app.WIN3D.cX, app.WIN3D.cY, app.WIN3D.dX, app.WIN3D.dY, 0, 0, 10, 10 };

    // Inside WIN3D's rect (990..1040, 490..540) and WIN3D_layers_fit's
    // own dest rect above.
    app.mouseX = 1010;
    app.mouseY = 500;
    app.mouseButton = app.LEFT;
  }

  @Test
  void leftClickOnTheOverlay_pinsANewPoint_andRegistersItsOwnOffsetFromCenter () {
    assertNull(app.allHoverPoints);

    app.mouseClicked();

    assertNotNull(app.allHoverPoints);
    assertEquals(1, app.allHoverPoints.length);
    assertArrayEquals(new int[]{ 1010, 500 }, app.allHoverPoints[0]);

    int[] row = app.allHoverPoints[0];
    float[] offset = app.win3DHoverPointOffsetFrac.get(row);
    assertNotNull(offset, "a real WIN3D overlay click must register a win3DHoverPointOffsetFrac entry, not leave the pin screen-fixed");

    // Center is (990+25, 490+25) = (1015, 515); click was (1010, 500) -
    // a raw offset of (-5, -15), expressed as a fraction of dX=dY=50:
    // -5/50 = -0.1, -15/50 = -0.3.
    assertEquals(-0.1f, offset[0], 0.0001f);
    assertEquals(-0.3f, offset[1], 0.0001f);
  }

  @Test
  void pinnedPoint_thenViewportEnlarged_trackedPositionMovesAccordingly () {
    app.mouseClicked(); // pins at (1010, 500), fraction offset (-0.1, -0.3) from center (1015, 515)

    int[] row = app.allHoverPoints[0];

    // Simulate the panel being enlarged in place (center stays put, the
    // panel doubles in size) - the fraction-based offset scales UP with
    // it, unlike a plain absolute-pixel offset, which is the whole point
    // of tracking a fraction of dX/dY rather than raw pixels.
    app.WIN3D.cX = 965;
    app.WIN3D.cY = 465;
    app.WIN3D.dX = 100;
    app.WIN3D.dY = 100;

    app.syncWin3DHoverPointPositions();

    // New center (965+50, 465+50) = (1015, 515). The stored fraction
    // (-0.1, -0.3) applied to the NEW dX/dY=100: offset (-10, -30),
    // landing at (1015-10, 515-30) = (1005, 485).
    assertEquals(1005, row[0]);
    assertEquals(485, row[1]);
  }
}
