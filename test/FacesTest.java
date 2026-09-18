import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Exercises solarchvision_Faces (Faces.pde), reached through the
// pre-constructed `app.allFaces` field.
//
// NOT covered: draw() and castShadows(). Both are pure rendering code -
// draw() dispatches on target_window and issues real WIN3D.graphics/
// SHADOW_graphics calls (beginShape/vertex/endShape, texture export,
// OBJ/HTML/RAD file writing via objOutput/htmlOutput/radOutput), none of
// which this suite has a safe way to exercise against a hand-built
// scene without an actual running sketch/open output file. Every piece
// of GEOMETRY those two functions rely on (getSubFace via funcs,
// tessellation counts, base_Vertices construction) is either already
// covered elsewhere (FunctionsTest.java) or is straightforward array
// indexing not worth a dedicated test.
//
// A fresh `app` per test since these mutate shared scene state.
class FacesTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= makeEmpty ========================================

  @Test
  void makeEmpty_resetsNodesAndOptionsToTheGivenLength () {
    app.allFaces.makeEmpty(3);
    assertEquals(3, app.allFaces.nodes.length);
    assertEquals(0, app.allFaces.nodes[0].length); // each face starts with zero nodes
    assertEquals(3, app.allFaces.options.length);
    assertEquals(6, app.allFaces.options[0].length);
  }

  // ================= getters / setters ================================

  @Test
  void gettersAndSetters_roundTripEveryOptionColumn () {
    app.allFaces.makeEmpty(1);
    app.allFaces.setMaterial(0, 3);
    app.allFaces.setTessellation(0, 2);
    app.allFaces.setLayer(0, 5);
    app.allFaces.setVisibility(0, 1);
    app.allFaces.setWeight(0, 4);
    app.allFaces.setClose(0, 1);

    assertEquals(3, app.allFaces.getMaterial(0));
    assertEquals(2, app.allFaces.getTessellation(0));
    assertEquals(5, app.allFaces.getLayer(0));
    assertEquals(1, app.allFaces.getVisibility(0));
    assertEquals(4, app.allFaces.getWeight(0));
    assertEquals(1, app.allFaces.getClose(0));
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

    int newId = app.allFaces.create(new int[]{0, 1, 2});

    assertEquals(0, newId);
    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
    assertArrayEquals(new int[]{3, 2, 1, 1, 5, 1}, app.allFaces.options[0]);
  }

  @Test
  void create_extendsTheLastGroupsFaceRangeWhenAGroupExists () {
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, -1};

    app.allFaces.create(new int[]{0});

    assertArrayEquals(new int[]{0, 0}, app.allGroups.Faces[0]);
  }

  // ================= beginNewFace / add_VertexToLastFace ===============

  @Test
  void beginNewFaceThenAddVertexToLastFace_buildsUpAFaceIncrementally () {
    app.allVertices = new float[0][3];

    app.allFaces.beginNewFace();
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(0, app.allFaces.nodes[0].length); // starts empty

    app.allFaces.add_VertexToLastFace(1, 2, 3);
    app.allFaces.add_VertexToLastFace(4, 5, 6);

    assertArrayEquals(new int[]{0, 1}, app.allFaces.nodes[0]); // references the 2 new points, in order
    assertEquals(2, app.allVertices.length);
    assertArrayEquals(new float[]{1, 2, 3}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{4, 5, 6}, app.allVertices[1], 0.0001f);
  }

  // ================= intersect =========================================
  //
  // Distinct from Select3D.intersect (already covered via
  // ModifyGeometryTest's autoNormalFaces tests): this one scans ALL
  // faces in the scene (this.nodes), not a selection, has no "skip index
  // 0" quirk, and - worth noting explicitly - returns the RAW,
  // UN-normalized cross product as its normal (face_norm is never passed
  // through funcs.vec3_unit here), unlike some sibling intersect-style
  // functions elsewhere that do normalize.

  @Test
  void intersect_hitsATriangleFaceAtIndexZero () {
    // Confirms index 0 is a reachable hit here - Select3D.intersect()
    // deliberately excludes it, this function does not.
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{0, 0, 0, 1, 0, 0}}; // visible

    float[] result = app.allFaces.intersect(new float[]{0.5f, 0.5f, 10}, new float[]{0, 0, -1});

    assertEquals(0, (int) result[0]); // hit face index 0
    assertEquals(0.5f, result[1], 0.0001f);
    assertEquals(0.5f, result[2], 0.0001f);
    assertEquals(0f, result[3], 0.0001f);
    assertEquals(10f, result[4], 0.0001f);
    assertArrayEquals(new float[]{0, 0, 4}, new float[]{result[5], result[6], result[7]}, 0.0001f); // raw, un-normalized
  }

  @Test
  void intersect_fansAQuadIntoTrianglesAroundItsCentroid () {
    // A ray straight down the exact centroid of a square hits the very
    // first fan triangle (corner 0, corner 1, centroid).
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.allFaces.options = new int[][]{{0, 0, 0, 1, 0, 0}};

    float[] result = app.allFaces.intersect(new float[]{1, 1, 10}, new float[]{0, 0, -1});

    assertEquals(0, (int) result[0]);
    assertEquals(1f, result[1], 0.0001f);
    assertEquals(1f, result[2], 0.0001f);
    assertEquals(0f, result[3], 0.0001f);
    assertEquals(10f, result[4], 0.0001f);
    assertArrayEquals(new float[]{0, 0, 2}, new float[]{result[5], result[6], result[7]}, 0.0001f);
  }

  @Test
  void intersect_returnsMinusOneWhenNothingIsHit () {
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{0, 0, 0, 1, 0, 0}};

    // Aimed well outside the triangle.
    float[] result = app.allFaces.intersect(new float[]{50, 50, 10}, new float[]{0, 0, -1});

    assertEquals(-1, (int) result[0]);
  }

  @Test
  void intersect_skipsInvisibleFacesEvenIfGeometricallyHit () {
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {0, 2, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}}; // visibility=0

    float[] result = app.allFaces.intersect(new float[]{0.5f, 0.5f, 10}, new float[]{0, 0, -1});

    assertEquals(-1, (int) result[0]);
  }

  @Test
  void intersect_picksTheNearerOfTwoStackedFaces () {
    app.allVertices = new float[][]{
      {0, 0, 0}, {2, 0, 0}, {0, 2, 0},     // near triangle, z=0
      {0, 0, -5}, {2, 0, -5}, {0, 2, -5}   // far triangle, z=-5, directly behind it
    };
    app.allFaces.nodes = new int[][]{{0, 1, 2}, {3, 4, 5}};
    app.allFaces.options = new int[][]{{0, 0, 0, 1, 0, 0}, {0, 0, 0, 1, 0, 0}};

    float[] result = app.allFaces.intersect(new float[]{0.5f, 0.5f, 10}, new float[]{0, 0, -1});

    assertEquals(0, (int) result[0]); // the near one, not the far one
    assertEquals(10f, result[4], 0.0001f);
  }

  // ================= to_XML / from_XML round trip ======================

  @Test
  void toXMLThenFromXML_roundTripsNodesOptionsAndDisplaySettings () {
    app.allFaces.nodes = new int[][]{{5, 6, 7}};
    app.allFaces.options = new int[][]{{3, 2, 1, 1, 4, 1}};
    app.allFaces.displayAll = false;
    app.allFaces.displayNormals = true;
    app.allFaces.displayEdges = false;
    app.allFaces.displayTessellation = 3;
    app.allFaces.ACTIVE_palette_CLR = 9;
    app.allFaces.ACTIVE_palette_DIR = -1;
    app.allFaces.ACTIVE_palette_MLT = 0.5f;
    app.allFaces.PASSIVE_palette_CLR = 2;
    app.allFaces.PASSIVE_palette_DIR = 2;
    app.allFaces.PASSIVE_palette_MLT = 0.75f;

    processing.data.XML root = new processing.data.XML("root");
    app.allFaces.to_XML(root);

    solarchvision_bim.solarchvision_Faces fresh = app.new solarchvision_Faces();
    fresh.from_XML(root);

    assertEquals(1, fresh.nodes.length);
    assertArrayEquals(new int[]{5, 6, 7}, fresh.nodes[0]);
    assertArrayEquals(new int[]{3, 2, 1, 1, 4, 1}, fresh.options[0]);

    assertFalse(fresh.displayAll);
    assertTrue(fresh.displayNormals);
    assertFalse(fresh.displayEdges);
    assertEquals(3, fresh.displayTessellation);
    assertEquals(9, fresh.ACTIVE_palette_CLR);
    assertEquals(-1, fresh.ACTIVE_palette_DIR);
    assertEquals(0.5f, fresh.ACTIVE_palette_MLT, 0.0001f);
    assertEquals(2, fresh.PASSIVE_palette_CLR);
    assertEquals(2, fresh.PASSIVE_palette_DIR);
    assertEquals(0.75f, fresh.PASSIVE_palette_MLT, 0.0001f);
  }
}
