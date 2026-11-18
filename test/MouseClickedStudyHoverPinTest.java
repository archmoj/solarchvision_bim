import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Confirms mouseClicked()'s own STUDY left-click branch (mouseClicked.pde)
// actually registers a new STUDY pin's studyHoverPointLocalFrac entry
// (hoverOnStudyImpact.pde) - not just that addHoverPoint() itself works
// (already covered elsewhere, e.g. HoverPointsTest.java), but that the
// real click path reaches studyLocalFracXFromScreen()/
// studyLocalFracYFromScreen() and stores the result against the exact
// row it just created. Mirrors
// MouseClickedCreateMoveTest.java's own "confirm the real click path
// reaches the thing under test" approach, and its same bare-construction
// pixel_A/pixel_B/pixel_C/pixel_D/pixel_H defaults (all effectively empty
// ranges except pixel_H=2) for why every earlier UI-panel guard in
// mouseClicked() provably can't match the click point chosen here.
class MouseClickedStudyHoverPinTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>();
    app.build_allActions();

    app.frameCount = 100;
    app.control = app.USER_GUI;
    app.UI_menuBar.selected_parent = -1;

    // Sidestep WORLD's/WIN3D's own click handling entirely - this file's
    // own concern is STUDY's branch specifically.
    app.WORLD.include = false;
    app.WIN3D.include = false;

    app.STUDY.include = true;
    app.STUDY.cX = 990;
    app.STUDY.cY = 490;
    app.STUDY.dX = 50;
    app.STUDY.dY = 50;
    app.STUDY.ImageScale = 1;
    app.STUDY.userZoom = 1;
    app.STUDY.userPanX = 0;
    app.STUDY.userPanY = 0;

    // Far outside the menu bar/toolbar/case bar/console bar/rollout -
    // all empty or near-origin ranges under bare construction (see this
    // file's own header comment) - and inside STUDY's rect above.
    app.mouseX = 1000;
    app.mouseY = 500;
    app.mouseButton = app.LEFT;
  }

  @Test
  void leftClickInsideStudy_pinsANewPoint_andRegistersItsOwnLocalBasePosition () {
    assertNull(app.allHoverPoints);

    app.mouseClicked();

    assertNotNull(app.allHoverPoints);
    assertEquals(1, app.allHoverPoints.length);
    assertArrayEquals(new int[]{ 1000, 500 }, app.allHoverPoints[0]);

    int[] row = app.allHoverPoints[0];
    float[] local = app.studyHoverPointLocalFrac.get(row);
    assertNotNull(local, "a real STUDY click must register a studyHoverPointLocalFrac entry, not leave the pin screen-fixed");
    assertEquals(app.studyLocalFracXFromScreen(1000), local[0], 0.0001f);
    assertEquals(app.studyLocalFracYFromScreen(500), local[1], 0.0001f);
  }

  @Test
  void pinnedPoint_thenZoomedIn_trackedPositionMovesAccordingly () {
    app.mouseClicked(); // pins at (1000, 500) under userZoom=1

    int[] row = app.allHoverPoints[0];

    app.STUDY.userZoom = 2; // zoom in since the pin was placed
    app.syncStudyHoverPointPositions();

    // (1000, 500) relative to STUDY's own cX/cY (990, 490) is (10, 10)
    // in graphics-buffer space (ImageScale=1) - doubling userZoom doubles
    // that offset to (20, 20), landing back at (990+20, 490+20).
    assertEquals(1010, row[0]);
    assertEquals(510, row[1]);
  }

  // ================= right click - "Reset Study View" ===================

  @Test
  void rightClickInsideStudy_resetsZoomAndPan () {
    app.STUDY.userZoom = 5.5f;
    app.STUDY.userPanX = 123;
    app.STUDY.userPanY = -45;
    app.mouseButton = app.RIGHT;

    app.mouseClicked();

    assertEquals(1f, app.STUDY.userZoom, 0.0001f);
    assertEquals(0f, app.STUDY.userPanX, 0.0001f);
    assertEquals(0f, app.STUDY.userPanY, 0.0001f);
  }

  @Test
  void rightClickInsideStudy_doesNotPinAHoverPoint () {
    app.mouseButton = app.RIGHT;

    app.mouseClicked();

    // Unlike a left click, a right click inside STUDY resets the view
    // instead of pinning a new point - nothing should land in
    // allHoverPoints.
    assertNull(app.allHoverPoints);
  }

  @Test
  void rightClickOutsideStudy_doesNothing () {
    app.STUDY.userZoom = 5.5f;
    app.STUDY.userPanX = 123;
    app.STUDY.userPanY = -45;
    app.mouseX = 9999; // outside STUDY's own rect (cX=990, cY=490, dX=dY=50)
    app.mouseY = 9999;
    app.mouseButton = app.RIGHT;

    app.mouseClicked();

    assertEquals(5.5f, app.STUDY.userZoom, 0.0001f);
    assertEquals(123f, app.STUDY.userPanX, 0.0001f);
    assertEquals(-45f, app.STUDY.userPanY, 0.0001f);
  }
}
