import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class MouseReleasedTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // fresh app never runs build_allActions() itself
    app.build_allActions(); // performRectSelect/performGetLengthMeasurement now dispatch through allActions
  }

  // ================= normalizeClickRegion ==================================

  @Test
  void normalizeClickRegion_leavesAnAlreadyOrderedRegionUnchanged () {
    app.X_click1 = 10;
    app.Y_click1 = 20;
    app.mouseX = 30;
    app.mouseY = 40;

    app.normalizeClickRegion();

    assertEquals(10, app.X_click1);
    assertEquals(20, app.Y_click1);
    assertEquals(30, app.X_click2);
    assertEquals(40, app.Y_click2);
  }

  @Test
  void normalizeClickRegion_swapsXWhenTheReleaseIsLeftOfTheStart () {
    app.X_click1 = 100;
    app.Y_click1 = 20;
    app.mouseX = 30; // released to the left of where the drag started
    app.mouseY = 40;

    app.normalizeClickRegion();

    assertEquals(30, app.X_click1);
    assertEquals(100, app.X_click2);
  }

  @Test
  void normalizeClickRegion_swapsYWhenTheReleaseIsAboveTheStart () {
    app.X_click1 = 10;
    app.Y_click1 = 200;
    app.mouseX = 30;
    app.mouseY = 40; // released above where the drag started

    app.normalizeClickRegion();

    assertEquals(40, app.Y_click1);
    assertEquals(200, app.Y_click2);
  }

  // ================= isRectSelectTask =======================================

  @Test
  void isRectSelectTask_trueForRectSelectItself () {
    app.WIN3D.currentTool = app.UITASK.RectSelect;
    assertTrue(app.isRectSelectTask());
  }

  @Test
  void isRectSelectTask_trueForAnyModifyTaskAfterMove () {
    app.WIN3D.currentTool = app.UITASK.Scale; // comes right after Move
    assertTrue(app.isRectSelectTask());
  }

  @Test
  void isRectSelectTask_falseForMoveItself () {
    app.WIN3D.currentTool = app.UITASK.Move;
    assertFalse(app.isRectSelectTask());
  }

  @Test
  void isRectSelectTask_falseForPickSelect () {
    app.WIN3D.currentTool = app.UITASK.PickSelect; // before Move, not RectSelect
    assertFalse(app.isRectSelectTask());
  }

  // ================= castClickToWorld (now shares computeClickRay)

  @Test
  void castClickToWorld_perspectiveStraightAheadHitsTheLandDirectlyBelowTheCamera () {
    app.WIN3D.projectionTypeIndex = 1; // perspective
    app.WIN3D.scale = 1;
    app.WIN3D.cameraFieldOfView = (float) Math.toRadians(60);
    app.WIN3D.rotationX = 0;
    app.WIN3D.rotationZ = 0;
    app.WIN3D.cameraX = 1;
    app.WIN3D.cameraY = 1;
    app.WIN3D.cameraZ = 10;
    app.overallScale = 1;

    app.WIN3D.cX = 0;
    app.WIN3D.cY = 0;
    app.WIN3D.dX = 200;
    app.WIN3D.dY = 200; // click center = (100, 100)

    app.Terrain.rowCount = 2;
    app.Terrain.columnCount = 2;
    app.Terrain.Mesh = new float[][][]{
      {{0, 0, 0}, {0, 10, 0}},
      {{10, 0, 0}, {10, 10, 0}}
    };

    app.mouseButton = app.RIGHT;

    float[] hit = app.castClickToWorld(100, 100); // dead center -> straight down

    assertArrayEquals(new float[]{1, 1, 0}, hit, 0.05f);
  }

  @Test
  void castClickToWorld_returnsTheOriginOnAMiss () {
    app.WIN3D.projectionTypeIndex = 1;
    app.WIN3D.scale = 1;
    app.WIN3D.cameraFieldOfView = (float) Math.toRadians(60);
    app.WIN3D.cameraX = 1000; // nowhere near the land mesh below
    app.WIN3D.cameraY = 1000;
    app.WIN3D.cameraZ = 10;
    app.overallScale = 1;
    app.WIN3D.cX = 0;
    app.WIN3D.cY = 0;
    app.WIN3D.dX = 200;
    app.WIN3D.dY = 200;

    app.Terrain.rowCount = 2;
    app.Terrain.columnCount = 2;
    app.Terrain.Mesh = new float[][][]{
      {{0, 0, 0}, {0, 10, 0}},
      {{10, 0, 0}, {10, 10, 0}}
    };

    app.mouseButton = app.RIGHT;

    float[] hit = app.castClickToWorld(100, 100);

    assertArrayEquals(new float[]{0, 0, 0}, hit, 0.0001f);
  }

  // ================= performGetLengthMeasurement ===========================
  // Orthographic view chosen so the click -> world-point mapping is a
  // simple closed form, rather than needing to hand-solve a perspective
  // ray/plane intersection: with scale=2 and Orthographic_ZOOM()==1
  // (from referenceScale == the camera's distance from the origin, and Zoom
  // picked so 0.5*Zoom*(PI/180)==1), a click `Image_X/Image_Y` pixels
  // off-center lands exactly `Image_X` world-units right and
  // `Image_Y` world-units up of wherever the camera looks - at
  // Image_X=Image_Y=0 (screen center) this reduces to the same
  // straight-down-from-the-camera case already checked directly above.

  private void setUpOrthographicClickMapping () {
    app.WIN3D.projectionTypeIndex = 0; // orthographic
    app.WIN3D.scale = 2;
    app.WIN3D.rotationX = 0;
    app.WIN3D.rotationZ = 0;
    app.WIN3D.cameraX = 1;
    app.WIN3D.cameraY = 1;
    app.WIN3D.cameraZ = 10;
    app.WIN3D.positionX = 100; // dist(position) == referenceScale below -> ratio 1
    app.WIN3D.positionY = 0;
    app.WIN3D.positionZ = 0;
    app.WIN3D.referenceScale = 100;
    app.WIN3D.zoom = (float) Math.toDegrees(2); // 0.5*Zoom*(PI/180) == 1
    app.overallScale = 1;

    app.WIN3D.cX = 0;
    app.WIN3D.cY = 0;
    app.WIN3D.dX = 200;
    app.WIN3D.dY = 200; // click center = (100, 100)

    app.Terrain.rowCount = 2;
    app.Terrain.columnCount = 2;
    app.Terrain.Mesh = new float[][][]{
      {{0, 0, 0}, {0, 10, 0}},
      {{10, 0, 0}, {10, 10, 0}}
    };

    app.mouseButton = app.RIGHT;

    // click1 at screen center -> world (1, 1, 0); click2 offset +3px
    // right, -2px up on screen -> world (1+3, 1+2, 0) = (4, 3, 0).
    app.X_click1 = 100;
    app.Y_click1 = 100;
    app.X_click2 = 103;
    app.Y_click2 = 98;
  }

  @Test
  void performGetLengthMeasurement_modifyParameterZeroSetsCreateLengthToTheStraightDistance () {
    setUpOrthographicClickMapping();
    app.WIN3D.toolParameterModifier = 0;
    app.User3D.creatorLength = -1;

    app.performGetLengthMeasurement();

    // dx=3, dy=2, dz=0 -> dist = sqrt(13)
    assertEquals(Math.sqrt(13), app.User3D.creatorLength, 0.05f);
  }

  @Test
  void performGetLengthMeasurement_modifyParameterOneSetsCreateWidthToTheStraightDistance () {
    setUpOrthographicClickMapping();
    app.WIN3D.toolParameterModifier = 1;
    app.User3D.creatorWidth = -1;

    app.performGetLengthMeasurement();

    assertEquals(Math.sqrt(13), app.User3D.creatorWidth, 0.05f);
  }

  @Test
  void performGetLengthMeasurement_modifyParameterTwoSetsCreateHeightToTheStraightDistance () {
    setUpOrthographicClickMapping();
    app.WIN3D.toolParameterModifier = 2;
    app.User3D.creatorHeight = -1;

    app.performGetLengthMeasurement();

    assertEquals(Math.sqrt(13), app.User3D.creatorHeight, 0.05f);
  }

  @Test
  void performGetLengthMeasurement_modifyParameterThreeSetsAllThreeAxisAlignedComponents () {
    setUpOrthographicClickMapping();
    app.WIN3D.toolParameterModifier = 3;
    app.User3D.creatorLength = -1;
    app.User3D.creatorWidth = -1;
    app.User3D.creatorHeight = -1;

    app.performGetLengthMeasurement();

    // rotationZ == 0, so dxRot/dyRot/dzRot == dx/dy/dz == 3, 2, 0
    assertEquals(3f, app.User3D.creatorLength, 0.05f);
    assertEquals(2f, app.User3D.creatorWidth, 0.05f);
    assertEquals(0f, app.User3D.creatorHeight, 0.05f);
  }

  @Test
  void performGetLengthMeasurement_modifyParameterFourSetsOnlyLengthAndWidthLeavingHeightAlone () {
    setUpOrthographicClickMapping();
    app.WIN3D.toolParameterModifier = 4;
    app.User3D.creatorLength = -1;
    app.User3D.creatorWidth = -1;
    app.User3D.creatorHeight = 999;

    app.performGetLengthMeasurement();

    assertEquals(3f, app.User3D.creatorLength, 0.05f);
    assertEquals(2f, app.User3D.creatorWidth, 0.05f);
    assertEquals(999f, app.User3D.creatorHeight, 0.0001f); // untouched
  }
}
