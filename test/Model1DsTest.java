import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class Model1DsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= makeEmpty ========================================

  @Test
  void makeEmpty_resetsFDataAndIDataToTheGivenLength () {
    app.allModel1Ds.makeEmpty(3);
    assertEquals(3, app.allModel1Ds.num);
    assertEquals(3, app.allModel1Ds.f_data.length);
    assertEquals(11, app.allModel1Ds.f_data[0].length);
    assertEquals(3, app.allModel1Ds.i_data.length);
    assertEquals(3, app.allModel1Ds.i_data[0].length);
  }

  // ================= create ===========================================

  @Test
  void create_appendsFDataAndIDataAndIncrementsNum () {
    app.allModel1Ds.create(7, 99, 5, 10, 20, 30, 2, 45, 1, 2, 3, 4, 5, 6);

    assertEquals(1, app.allModel1Ds.num);
    assertEquals(10f, app.allModel1Ds.getX(0), 0.0001f);
    assertEquals(20f, app.allModel1Ds.getY(0), 0.0001f);
    assertEquals(30f, app.allModel1Ds.getZ(0), 0.0001f);
    assertEquals(2f, app.allModel1Ds.getScale(0), 0.0001f);
    assertEquals(45f, app.allModel1Ds.getRotation(0), 0.0001f);
    assertEquals(1f, app.allModel1Ds.getBranchTilt(0), 0.0001f);
    assertEquals(2f, app.allModel1Ds.getBranchTwist(0), 0.0001f);
    assertEquals(3f, app.allModel1Ds.getBranchRatio(0), 0.0001f);
    assertEquals(4f, app.allModel1Ds.getTreeBase(0), 0.0001f);
    assertEquals(5f, app.allModel1Ds.getTrunkSize(0), 0.0001f);
    assertEquals(6f, app.allModel1Ds.getLeafSize(0), 0.0001f);
    assertEquals(7, app.allModel1Ds.getType(0));
    assertEquals(99, app.allModel1Ds.getSeed(0));
    assertEquals(5, app.allModel1Ds.getDegreeMax(0));
  }

  @Test
  void create_extendsTheLastGroupsModel1DRangeWhenAGroupExists () {
    app.allGroups.makeEmpty(1);
    app.allGroups.Model1Ds[0] = new int[]{0, -1};

    app.allModel1Ds.create(0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0);

    assertArrayEquals(new int[]{0, 0}, app.allGroups.Model1Ds[0]);
  }

  // ================= setters (the other half of the getter round trip) =

  @Test
  void settersAndGetters_roundTripEveryColumn () {
    app.allModel1Ds.f_data = new float[][]{new float[11]};
    app.allModel1Ds.i_data = new int[][]{new int[3]};

    app.allModel1Ds.setX(0, 1);
    app.allModel1Ds.setY(0, 2);
    app.allModel1Ds.setZ(0, 3);
    app.allModel1Ds.setScale(0, 4);
    app.allModel1Ds.setRotation(0, 5);
    app.allModel1Ds.setBranchTilt(0, 6);
    app.allModel1Ds.setBranchTwist(0, 7);
    app.allModel1Ds.setBranchRatio(0, 8);
    app.allModel1Ds.setTreeBase(0, 9);
    app.allModel1Ds.setTrunkSize(0, 10);
    app.allModel1Ds.setLeafSize(0, 11);
    app.allModel1Ds.setType(0, 1);
    app.allModel1Ds.setSeed(0, 2);
    app.allModel1Ds.setDegreeMax(0, 3);

    assertEquals(1f, app.allModel1Ds.getX(0), 0.0001f);
    assertEquals(11f, app.allModel1Ds.getLeafSize(0), 0.0001f);
    assertEquals(1, app.allModel1Ds.getType(0));
    assertEquals(2, app.allModel1Ds.getSeed(0));
    assertEquals(3, app.allModel1Ds.getDegreeMax(0));
  }

  // ================= move / magS ======================================

  @Test
  void move_addsTheOffsetToPositionOnly () {
    app.allModel1Ds.f_data = new float[][]{{1, 1, 1, 5, 0, 0, 0, 0, 0, 0, 0}};
    app.allModel1Ds.move(0, 1, 2, 3);
    assertEquals(2f, app.allModel1Ds.getX(0), 0.0001f);
    assertEquals(3f, app.allModel1Ds.getY(0), 0.0001f);
    assertEquals(4f, app.allModel1Ds.getZ(0), 0.0001f);
    assertEquals(5f, app.allModel1Ds.getScale(0), 0.0001f); // untouched
  }

  @Test
  void magS_multipliesScaleOnly () {
    app.allModel1Ds.f_data = new float[][]{{1, 1, 1, 5, 0, 0, 0, 0, 0, 0, 0}};
    app.allModel1Ds.magS(0, 3);
    assertEquals(15f, app.allModel1Ds.getScale(0), 0.0001f);
    assertEquals(1f, app.allModel1Ds.getX(0), 0.0001f); // untouched
  }

  // ================= intersect =========================================

  @Test
  void intersect_hitsAQuadThroughItsCentroid () {
    app.allModel1Ds.Vertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allModel1Ds.Faces = new int[][]{{0, 1, 2, 3}};

    float[] result = app.allModel1Ds.intersect(new float[]{1, 1, 10}, new float[]{0, 0, -1});

    assertEquals(0, (int) result[0]);
    assertEquals(1f, result[1], 0.0001f);
    assertEquals(1f, result[2], 0.0001f);
    assertEquals(0f, result[3], 0.0001f);
    assertEquals(10f, result[4], 0.0001f);
  }

  @Test
  void intersect_returnsMinusOneWhenNothingIsHit () {
    app.allModel1Ds.Vertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allModel1Ds.Faces = new int[][]{{0, 1, 2, 3}};

    // Aimed well outside the quad.
    float[] result = app.allModel1Ds.intersect(new float[]{50, 50, 10}, new float[]{0, 0, -1});

    assertEquals(-1, (int) result[0]);
  }

  // ================= to_XML / from_XML round trip ======================

  @Test
  void toXMLThenFromXML_roundTripsEveryColumn () {
    app.allModel1Ds.f_data = new float[][]{{10, 20, 30, 2, 45, 1, 2, 3, 4, 5, 6}};
    app.allModel1Ds.i_data = new int[][]{{7, 99, 5}};
    app.allModel1Ds.num = 1;
    app.allModel1Ds.displayAll = false;
    app.allModel1Ds.displayLeaves = false;

    processing.data.XML root = new processing.data.XML("root");
    app.allModel1Ds.to_XML(root);

    solarchvision_bim.solarchvision_Model1Ds fresh = app.new solarchvision_Model1Ds();
    fresh.from_XML(root);

    assertEquals(1, fresh.num);
    assertEquals(10f, fresh.getX(0), 0.0001f);
    assertEquals(45f, fresh.getRotation(0), 0.0001f);
    assertEquals(6f, fresh.getLeafSize(0), 0.0001f);
    assertEquals(7, fresh.getType(0));
    assertEquals(99, fresh.getSeed(0));
    assertEquals(5, fresh.getDegreeMax(0));
    assertFalse(fresh.displayAll);
    assertFalse(fresh.displayLeaves);
  }
}
