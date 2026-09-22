import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class PolylinesTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= makeEmpty / getters / setters ====================

  @Test
  void makeEmpty_resetsNodesAndOptionsToTheGivenLength () {
    app.allPolylines.makeEmpty(3);
    assertEquals(3, app.allPolylines.nodes.length);
    assertEquals(0, app.allPolylines.nodes[0].length);
    assertEquals(3, app.allPolylines.options.length);
    assertEquals(6, app.allPolylines.options[0].length);
  }

  @Test
  void gettersAndSetters_roundTripEveryOptionColumn () {
    app.allPolylines.makeEmpty(1);
    app.allPolylines.setMaterial(0, 3);
    app.allPolylines.setTessellation(0, 2);
    app.allPolylines.setLayer(0, 5);
    app.allPolylines.setVisibility(0, 1);
    app.allPolylines.setWeight(0, 4);
    app.allPolylines.setClose(0, 1);

    assertEquals(3, app.allPolylines.getMaterial(0));
    assertEquals(2, app.allPolylines.getTessellation(0));
    assertEquals(5, app.allPolylines.getLayer(0));
    assertEquals(1, app.allPolylines.getVisibility(0));
    assertEquals(4, app.allPolylines.getWeight(0));
    assertEquals(1, app.allPolylines.getClose(0));
  }

  // ================= create ===========================================

  @Test
  void create_appendsNodesAndOptionsFromTheCurrentGlobalsAndReturnsTheNewIndex () {
    app.current_Material = 3;
    app.current_Tessellation = 2;
    app.current_Layer = 1;
    app.current_Visibility = 1;
    app.current_Weight = 5;
    app.current_Closed = 1;

    int newId = app.allPolylines.create(new int[]{0, 1});

    assertEquals(0, newId);
    assertArrayEquals(new int[]{0, 1}, app.allPolylines.nodes[0]);
    assertArrayEquals(new int[]{3, 2, 1, 1, 5, 1}, app.allPolylines.options[0]);
  }

  @Test
  void create_extendsTheLastGroupsPolylineRangeWhenAGroupExists () {
    app.allGroups.makeEmpty(1);
    app.allGroups.Polylines[0] = new int[]{0, -1};

    app.allPolylines.create(new int[]{0});

    assertArrayEquals(new int[]{0, 0}, app.allGroups.Polylines[0]);
  }

  // ================= beginNewPolyline / add_VertexToLastPolyline ======

  @Test
  void beginNewPolylineThenAddVertex_buildsUpAPolylineIncrementally () {
    app.allVertices = new float[0][3];

    app.allPolylines.beginNewPolyline();
    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(0, app.allPolylines.nodes[0].length);

    app.allPolylines.add_VertexToLastPolyline(1, 2, 3);
    app.allPolylines.add_VertexToLastPolyline(4, 5, 6);

    assertArrayEquals(new int[]{0, 1}, app.allPolylines.nodes[0]);
    assertEquals(2, app.allVertices.length);
    assertArrayEquals(new float[]{1, 2, 3}, app.allVertices[0], 0.0001f);
  }

  // ================= add_Polyline =====================================

  @Test
  void addPolyline_createsPointsForEveryGivenCoordinateAndOneNewPolyline () {
    app.allVertices = new float[0][3];

    app.allPolylines.add_Polyline(3, 1, 2, 1, 4, 0,
      new float[][]{{0, 0, 0}, {1, 0, 0}, {1, 1, 0}});

    assertEquals(1, app.allPolylines.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allPolylines.nodes[0]);
    assertEquals(3, app.allVertices.length);
    assertArrayEquals(new float[]{1, 1, 0}, app.allVertices[2], 0.0001f);
    assertArrayEquals(new int[]{3, 1, 2, 1, 4, 0}, app.allPolylines.options[0]);
  }

  // ================= add_Arc ==========================================

  @Test
  void addArc_buildsAClosedRegularPolygonApproximatingAFullCircle () {
    app.allVertices = new float[0][3];

    // A full 360deg circle of radius 1 around the origin, in 4 segments.
    app.allPolylines.add_Arc(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 4, 0, 360);

    assertEquals(4, app.allVertices.length); // the 360deg wraparound point is NOT duplicated
    assertArrayEquals(new float[]{1, 0, 0}, app.allVertices[0], 0.001f);
    assertArrayEquals(new float[]{0, 1, 0}, app.allVertices[1], 0.001f);
    assertArrayEquals(new float[]{-1, 0, 0}, app.allVertices[2], 0.001f);
    assertArrayEquals(new float[]{0, -1, 0}, app.allVertices[3], 0.001f);
    assertEquals(1, app.allPolylines.getClose(0)); // full circles close automatically
  }

  @Test
  void addArc_doesNotAutoCloseAPartialArc () {
    app.allVertices = new float[0][3];

    app.allPolylines.add_Arc(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 2, 0, 180); // a half-circle

    assertEquals(3, app.allVertices.length); // start, midpoint, end - all kept
    assertEquals(0, app.allPolylines.getClose(0));
  }

  // ================= intersect =========================================

  @Test
  void intersect_hitsATriangleShapedPolyline () {
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {0, 2, 0}};
    app.allPolylines.nodes = new int[][]{{0, 1, 2}};
    app.allPolylines.options = new int[][]{{0, 0, 0, 1, 0, 0}};

    float[] result = app.allPolylines.intersect(new float[]{0.5f, 0.5f, 10}, new float[]{0, 0, -1});

    assertEquals(0, (int) result[0]);
    assertEquals(0.5f, result[1], 0.0001f);
    assertEquals(0.5f, result[2], 0.0001f);
    assertEquals(10f, result[4], 0.0001f);
  }

  @Test
  void intersect_fansAQuadShapedPolylineAroundItsCentroid () {
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allPolylines.nodes = new int[][]{{0, 1, 2, 3}};
    app.allPolylines.options = new int[][]{{0, 0, 0, 1, 0, 0}};

    float[] result = app.allPolylines.intersect(new float[]{1, 1, 10}, new float[]{0, 0, -1});

    assertEquals(0, (int) result[0]);
    assertEquals(1f, result[1], 0.0001f);
    assertEquals(1f, result[2], 0.0001f);
    assertEquals(10f, result[4], 0.0001f);
  }

  @Test
  void intersect_skipsAnOpenTwoPointPolylineEntirely () {
    // n > 2 is required (a bare line segment has no interior to hit).
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}};
    app.allPolylines.nodes = new int[][]{{0, 1}};
    app.allPolylines.options = new int[][]{{0, 0, 0, 1, 0, 0}};

    float[] result = app.allPolylines.intersect(new float[]{1, 0, 10}, new float[]{0, 0, -1});

    assertEquals(-1, (int) result[0]);
  }

  @Test
  void intersect_skipsInvisiblePolylines () {
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {0, 2, 0}};
    app.allPolylines.nodes = new int[][]{{0, 1, 2}};
    app.allPolylines.options = new int[][]{{0, 0, 0, 0, 0, 0}}; // visibility=0

    float[] result = app.allPolylines.intersect(new float[]{0.5f, 0.5f, 10}, new float[]{0, 0, -1});

    assertEquals(-1, (int) result[0]);
  }

  // ================= to_XML / from_XML round trip ======================

  @Test
  void toXMLThenFromXML_roundTripsNodesOptionsAndDisplayAll () {
    app.allPolylines.nodes = new int[][]{{5, 6, 7}};
    app.allPolylines.options = new int[][]{{3, 2, 1, 1, 4, 1}};
    app.allPolylines.displayAll = false;

    processing.data.XML root = new processing.data.XML("root");
    app.allPolylines.to_XML(root);

    solarchvision_bim.Polylines fresh = app.new Polylines();
    fresh.from_XML(root);

    assertEquals(1, fresh.nodes.length);
    assertArrayEquals(new int[]{5, 6, 7}, fresh.nodes[0]);
    assertArrayEquals(new int[]{3, 2, 1, 1, 4, 1}, fresh.options[0]);
    assertFalse(fresh.displayAll);
  }
}
