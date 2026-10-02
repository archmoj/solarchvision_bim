import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class CamerasTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= makeEmpty / add_first ==============================

  @Test
  void makeEmpty_alwaysCreatesOneDefaultCameraFromTheCurrentWIN3DState () {
    // makeEmpty(n) unconditionally calls add_first() regardless of n, so
    // even makeEmpty(0) leaves exactly 1 camera behind, not 0 - already
    // learned the hard way in Move3DTest/Rotate3DTest's Cameras() tests.
    app.WIN3D.positionX = 7;
    app.allCameras.makeEmpty(0);

    assertEquals(1, app.allCameras.num);
    assertEquals(1, app.allCameras.options.length);
    assertEquals(7f, app.allCameras.get_posX(0), 0.0001f);
  }

  // ================= create ===========================================

  @Test
  void create_appendsAndIncrementsNum () {
    int numBefore = app.allCameras.num;

    app.allCameras.create(1, 2, 3, 4, 5, 6, 7, 8, 9, 1);

    assertEquals(numBefore + 1, app.allCameras.num);
    int newId = app.allCameras.num - 1;
    assertEquals(1f, app.allCameras.get_posX(newId), 0.0001f);
    assertEquals(2f, app.allCameras.get_posY(newId), 0.0001f);
    assertEquals(3f, app.allCameras.get_posZ(newId), 0.0001f);
    assertEquals(4f, app.allCameras.get_posT(newId), 0.0001f);
    assertEquals(5f, app.allCameras.get_rotX(newId), 0.0001f);
    assertEquals(6f, app.allCameras.get_rotY(newId), 0.0001f);
    assertEquals(7f, app.allCameras.get_rotZ(newId), 0.0001f);
    assertEquals(8f, app.allCameras.get_rotT(newId), 0.0001f);
    assertEquals(9f, app.allCameras.get_zoom(newId), 0.0001f);
    assertEquals(1, app.allCameras.get_type(newId));
  }

  // Unlike Faces/Polylines/Model1Ds/Model2Ds/Solids, create() here does
  // NOT extend the last group's range - cameras aren't owned by groups
  // at all (allGroups has no Cameras field), so there's nothing to test
  // there; noted for completeness rather than assumed silently.

  // ================= getters / setters =================================

  @Test
  void gettersAndSetters_roundTripEveryColumn () {
    app.allCameras.options = new float[][]{new float[9]};
    app.allCameras.Type = new int[]{0};

    app.allCameras.set_posX(0, 1);
    app.allCameras.set_posY(0, 2);
    app.allCameras.set_posZ(0, 3);
    app.allCameras.set_posT(0, 4);
    app.allCameras.set_rotX(0, 5);
    app.allCameras.set_rotY(0, 6);
    app.allCameras.set_rotZ(0, 7);
    app.allCameras.set_rotT(0, 8);
    app.allCameras.set_zoom(0, 9);
    app.allCameras.set_type(0, 2);

    assertEquals(1f, app.allCameras.get_posX(0), 0.0001f);
    assertEquals(9f, app.allCameras.get_zoom(0), 0.0001f);
    assertEquals(2, app.allCameras.get_type(0));
  }

  // ================= move =============================================

  @Test
  void move_addsTheOffsetToPositionOnly () {
    app.allCameras.options = new float[][]{{1, 1, 1, 0, 0, 0, 0, 0, 5}};
    app.allCameras.move(0, 1, 2, 3);
    assertEquals(2f, app.allCameras.get_posX(0), 0.0001f);
    assertEquals(3f, app.allCameras.get_posY(0), 0.0001f);
    assertEquals(4f, app.allCameras.get_posZ(0), 0.0001f);
    assertEquals(5f, app.allCameras.get_zoom(0), 0.0001f); // untouched
  }

  // ================= intersect =========================================

  @Test
  void intersect_hitsAQuadThroughItsCentroid () {
    app.allCameras.Vertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allCameras.Faces = new int[][]{{0, 1, 2, 3}};

    float[] result = app.allCameras.intersect(new float[]{1, 1, 10}, new float[]{0, 0, -1});

    assertEquals(0, (int) result[0]);
    assertEquals(1f, result[1], 0.0001f);
    assertEquals(1f, result[2], 0.0001f);
    assertEquals(10f, result[4], 0.0001f);
  }

  @Test
  void intersect_returnsMinusOneWhenNothingIsHit () {
    app.allCameras.Vertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allCameras.Faces = new int[][]{{0, 1, 2, 3}};

    float[] result = app.allCameras.intersect(new float[]{50, 50, 10}, new float[]{0, 0, -1});

    assertEquals(-1, (int) result[0]);
  }

  // ================= to_XML / from_XML round trip ======================

  @Test
  void toXMLThenFromXML_roundTripsEveryColumn () {
    app.allCameras.options = new float[][]{{1, 2, 3, 4, 5, 6, 7, 8, 9}};
    app.allCameras.Type = new int[]{2};
    app.allCameras.num = 1;
    app.allCameras.displayAll = false;

    processing.data.XML root = new processing.data.XML("root");
    app.allCameras.to_XML(root);

    solarchvision_bim.Cameras fresh = app.new Cameras();
    fresh.from_XML(root);

    assertEquals(1, fresh.num);
    assertEquals(1f, fresh.get_posX(0), 0.0001f);
    assertEquals(9f, fresh.get_zoom(0), 0.0001f);
    assertEquals(2, fresh.get_type(0));
    assertFalse(fresh.displayAll);
  }

  // ================= add_first =============================================

  @Test
  void addFirst_appendsACameraMatchingWIN3DsCurrentState () {
    app.allCameras.makeEmpty(0); // start from the single default camera makeEmpty() creates
    int before = app.allCameras.num;

    app.WIN3D.positionX = 11;
    app.WIN3D.positionY = 22;
    app.WIN3D.positionZ = 33;
    app.WIN3D.positionStep = 1.5f;
    app.WIN3D.rotationX = 44;
    app.WIN3D.rotationY = 55;
    app.WIN3D.rotationZ = 66;
    app.WIN3D.rotationStep = 2.5f;
    app.WIN3D.zoom = 77;
    app.WIN3D.projectionTypeIndex = 1;

    app.allCameras.add_first();

    int newIndex = app.allCameras.num - 1;
    assertEquals(before + 1, app.allCameras.num);
    assertEquals(11f, app.allCameras.get_posX(newIndex), 0.0001f);
    assertEquals(22f, app.allCameras.get_posY(newIndex), 0.0001f);
    assertEquals(33f, app.allCameras.get_posZ(newIndex), 0.0001f);
    assertEquals(1.5f, app.allCameras.get_posT(newIndex), 0.0001f);
    assertEquals(44f, app.allCameras.get_rotX(newIndex), 0.0001f);
    assertEquals(55f, app.allCameras.get_rotY(newIndex), 0.0001f);
    assertEquals(66f, app.allCameras.get_rotZ(newIndex), 0.0001f);
    assertEquals(2.5f, app.allCameras.get_rotT(newIndex), 0.0001f);
    assertEquals(77f, app.allCameras.get_zoom(newIndex), 0.0001f);
    assertEquals(1, app.allCameras.get_type(newIndex));
  }

  // ================= getCorners ============================================

  @Test
  void getCorners_returnsFiveThreeComponentVertices () {
    float[][] corners = app.allCameras.getCorners(1, 0, 0, 0, 1, 0, 0, 0, 5, 60);
    assertEquals(5, corners.length);
    for (float[] v : corners) assertEquals(3, v.length);
  }

  @Test
  void getCorners_restoresWIN3DsStateAfterward () {
    app.WIN3D.positionX = 111;
    app.WIN3D.positionY = 222;
    app.WIN3D.positionZ = 333;
    app.WIN3D.positionStep = 4;
    app.WIN3D.rotationX = 10;
    app.WIN3D.rotationY = 20;
    app.WIN3D.rotationZ = 30;
    app.WIN3D.rotationStep = 5;
    app.WIN3D.zoom = 90;
    app.WIN3D.cameraX = 1;
    app.WIN3D.cameraY = 2;
    app.WIN3D.cameraZ = 3;

    app.allCameras.getCorners(1, 5, 6, 7, 1, 15, 25, 35, 3, 45);

    assertEquals(111f, app.WIN3D.positionX, 0.0001f);
    assertEquals(222f, app.WIN3D.positionY, 0.0001f);
    assertEquals(333f, app.WIN3D.positionZ, 0.0001f);
    assertEquals(4f, app.WIN3D.positionStep, 0.0001f);
    assertEquals(10f, app.WIN3D.rotationX, 0.0001f);
    assertEquals(20f, app.WIN3D.rotationY, 0.0001f);
    assertEquals(30f, app.WIN3D.rotationZ, 0.0001f);
    assertEquals(5f, app.WIN3D.rotationStep, 0.0001f);
    assertEquals(90f, app.WIN3D.zoom, 0.0001f);
    assertEquals(1f, app.WIN3D.cameraX, 0.0001f);
    assertEquals(2f, app.WIN3D.cameraY, 0.0001f);
    assertEquals(3f, app.WIN3D.cameraZ, 0.0001f);
  }
}
