import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Exercises mouseReleased.pde's standalone helper functions, reached
// directly on `app`. Like mouseDragged.pde, this file was already
// broken into small, mostly pure functions - the one exception was
// castClickToWorld(), which had its own inline copy of the same ray
// setup already extracted into SOLARCHVISION_computeClickRay
// (mouseClicked.pde) during an earlier session; it's now pointed at
// that function instead, removing a third copy of that logic.
//
// NOT covered: mouseReleased() itself (the thin top-level dispatcher),
// finishFrameDragSelection() and performRectSelect(), both of which
// draw directly (rect/stroke/fill/pushMatrix) - consistent with this
// test suite's existing policy elsewhere of not exercising drawing
// code, which needs a real graphics context this headless setup
// doesn't have.
//
// A fresh `app` per test since these mutate shared scene/viewport state.
class MouseReleasedTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= normalizeClickRegion ==================================

  @Test
  void normalizeClickRegion_leavesAnAlreadyOrderedRegionUnchanged () {
    app.SOLARCHVISION_X_click1 = 10;
    app.SOLARCHVISION_Y_click1 = 20;
    app.mouseX = 30;
    app.mouseY = 40;

    app.normalizeClickRegion();

    assertEquals(10, app.SOLARCHVISION_X_click1);
    assertEquals(20, app.SOLARCHVISION_Y_click1);
    assertEquals(30, app.SOLARCHVISION_X_click2);
    assertEquals(40, app.SOLARCHVISION_Y_click2);
  }

  @Test
  void normalizeClickRegion_swapsXWhenTheReleaseIsLeftOfTheStart () {
    app.SOLARCHVISION_X_click1 = 100;
    app.SOLARCHVISION_Y_click1 = 20;
    app.mouseX = 30; // released to the left of where the drag started
    app.mouseY = 40;

    app.normalizeClickRegion();

    assertEquals(30, app.SOLARCHVISION_X_click1);
    assertEquals(100, app.SOLARCHVISION_X_click2);
  }

  @Test
  void normalizeClickRegion_swapsYWhenTheReleaseIsAboveTheStart () {
    app.SOLARCHVISION_X_click1 = 10;
    app.SOLARCHVISION_Y_click1 = 200;
    app.mouseX = 30;
    app.mouseY = 40; // released above where the drag started

    app.normalizeClickRegion();

    assertEquals(40, app.SOLARCHVISION_Y_click1);
    assertEquals(200, app.SOLARCHVISION_Y_click2);
  }

  // ================= isRectSelectTask =======================================

  @Test
  void isRectSelectTask_trueForRectSelectItself () {
    app.WIN3D.UI_CurrentTask = app.UITASK.RectSelect;
    assertTrue(app.isRectSelectTask());
  }

  @Test
  void isRectSelectTask_trueForAnyModifyTaskAfterMove () {
    app.WIN3D.UI_CurrentTask = app.UITASK.Scale; // comes right after Move
    assertTrue(app.isRectSelectTask());
  }

  @Test
  void isRectSelectTask_falseForMoveItself () {
    app.WIN3D.UI_CurrentTask = app.UITASK.Move;
    assertFalse(app.isRectSelectTask());
  }

  @Test
  void isRectSelectTask_falseForPickSelect () {
    app.WIN3D.UI_CurrentTask = app.UITASK.PickSelect; // before Move, not RectSelect
    assertFalse(app.isRectSelectTask());
  }

  // ================= castClickToWorld (now shares SOLARCHVISION_computeClickRay)

  @Test
  void castClickToWorld_perspectiveStraightAheadHitsTheLandDirectlyBelowTheCamera () {
    app.WIN3D.ViewType = 1; // perspective
    app.WIN3D.scale = 1;
    app.WIN3D.CAM_fov = (float) Math.toRadians(60);
    app.WIN3D.rotation_X = 0;
    app.WIN3D.rotation_Z = 0;
    app.WIN3D.CAM_x = 1;
    app.WIN3D.CAM_y = 1;
    app.WIN3D.CAM_z = 10;
    app.OBJECTS_scale = 1;

    app.WIN3D.cX = 0;
    app.WIN3D.cY = 0;
    app.WIN3D.dX = 200;
    app.WIN3D.dY = 200; // click center = (100, 100)

    app.Land3D.num_rows = 2;
    app.Land3D.num_columns = 2;
    app.Land3D.Mesh = new float[][][]{
      {{0, 0, 0}, {0, 10, 0}},
      {{10, 0, 0}, {10, 10, 0}}
    };

    app.mouseButton = app.RIGHT;

    float[] hit = app.castClickToWorld(100, 100); // dead center -> straight down

    assertArrayEquals(new float[]{1, 1, 0}, hit, 0.05f);
  }

  @Test
  void castClickToWorld_returnsTheOriginOnAMiss () {
    app.WIN3D.ViewType = 1;
    app.WIN3D.scale = 1;
    app.WIN3D.CAM_fov = (float) Math.toRadians(60);
    app.WIN3D.CAM_x = 1000; // nowhere near the land mesh below
    app.WIN3D.CAM_y = 1000;
    app.WIN3D.CAM_z = 10;
    app.OBJECTS_scale = 1;
    app.WIN3D.cX = 0;
    app.WIN3D.cY = 0;
    app.WIN3D.dX = 200;
    app.WIN3D.dY = 200;

    app.Land3D.num_rows = 2;
    app.Land3D.num_columns = 2;
    app.Land3D.Mesh = new float[][][]{
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
  // (from refScale == the camera's distance from the origin, and Zoom
  // picked so 0.5*Zoom*(PI/180)==1), a click `Image_X/Image_Y` pixels
  // off-center lands exactly `Image_X` world-units right and
  // `Image_Y` world-units up of wherever the camera looks - at
  // Image_X=Image_Y=0 (screen center) this reduces to the same
  // straight-down-from-the-camera case already checked directly above.

  private void setUpOrthographicClickMapping () {
    app.WIN3D.ViewType = 0; // orthographic
    app.WIN3D.scale = 2;
    app.WIN3D.rotation_X = 0;
    app.WIN3D.rotation_Z = 0;
    app.WIN3D.CAM_x = 1;
    app.WIN3D.CAM_y = 1;
    app.WIN3D.CAM_z = 10;
    app.WIN3D.position_X = 100; // dist(position) == refScale below -> ratio 1
    app.WIN3D.position_Y = 0;
    app.WIN3D.position_Z = 0;
    app.WIN3D.refScale = 100;
    app.WIN3D.Zoom = (float) Math.toDegrees(2); // 0.5*Zoom*(PI/180) == 1
    app.OBJECTS_scale = 1;

    app.WIN3D.cX = 0;
    app.WIN3D.cY = 0;
    app.WIN3D.dX = 200;
    app.WIN3D.dY = 200; // click center = (100, 100)

    app.Land3D.num_rows = 2;
    app.Land3D.num_columns = 2;
    app.Land3D.Mesh = new float[][][]{
      {{0, 0, 0}, {0, 10, 0}},
      {{10, 0, 0}, {10, 10, 0}}
    };

    app.mouseButton = app.RIGHT;

    // click1 at screen center -> world (1, 1, 0); click2 offset +3px
    // right, -2px up on screen -> world (1+3, 1+2, 0) = (4, 3, 0).
    app.SOLARCHVISION_X_click1 = 100;
    app.SOLARCHVISION_Y_click1 = 100;
    app.SOLARCHVISION_X_click2 = 103;
    app.SOLARCHVISION_Y_click2 = 98;
  }

  @Test
  void performGetLengthMeasurement_modifyParameterZeroSetsCreateLengthToTheStraightDistance () {
    setUpOrthographicClickMapping();
    app.WIN3D.UI_TaskModifyParameter = 0;
    app.User3D.create_Length = -1;

    app.performGetLengthMeasurement();

    // dx=3, dy=2, dz=0 -> dist = sqrt(13)
    assertEquals(Math.sqrt(13), app.User3D.create_Length, 0.05f);
  }

  @Test
  void performGetLengthMeasurement_modifyParameterOneSetsCreateWidthToTheStraightDistance () {
    setUpOrthographicClickMapping();
    app.WIN3D.UI_TaskModifyParameter = 1;
    app.User3D.create_Width = -1;

    app.performGetLengthMeasurement();

    assertEquals(Math.sqrt(13), app.User3D.create_Width, 0.05f);
  }

  @Test
  void performGetLengthMeasurement_modifyParameterTwoSetsCreateHeightToTheStraightDistance () {
    setUpOrthographicClickMapping();
    app.WIN3D.UI_TaskModifyParameter = 2;
    app.User3D.create_Height = -1;

    app.performGetLengthMeasurement();

    assertEquals(Math.sqrt(13), app.User3D.create_Height, 0.05f);
  }

  @Test
  void performGetLengthMeasurement_modifyParameterThreeSetsAllThreeAxisAlignedComponents () {
    setUpOrthographicClickMapping();
    app.WIN3D.UI_TaskModifyParameter = 3;
    app.User3D.create_Length = -1;
    app.User3D.create_Width = -1;
    app.User3D.create_Height = -1;

    app.performGetLengthMeasurement();

    // rotation_Z == 0, so dxRot/dyRot/dzRot == dx/dy/dz == 3, 2, 0
    assertEquals(3f, app.User3D.create_Length, 0.05f);
    assertEquals(2f, app.User3D.create_Width, 0.05f);
    assertEquals(0f, app.User3D.create_Height, 0.05f);
  }

  @Test
  void performGetLengthMeasurement_modifyParameterFourSetsOnlyLengthAndWidthLeavingHeightAlone () {
    setUpOrthographicClickMapping();
    app.WIN3D.UI_TaskModifyParameter = 4;
    app.User3D.create_Length = -1;
    app.User3D.create_Width = -1;
    app.User3D.create_Height = 999;

    app.performGetLengthMeasurement();

    assertEquals(3f, app.User3D.create_Length, 0.05f);
    assertEquals(2f, app.User3D.create_Width, 0.05f);
    assertEquals(999f, app.User3D.create_Height, 0.0001f); // untouched
  }
}
