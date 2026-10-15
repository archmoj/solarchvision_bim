import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

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
    app.allFaces.showNormalLines = true;
    app.allFaces.displayEdges = false;
    app.allFaces.displayTessellation = 3;
    app.allFaces.activeColorscaleIndex = 9;
    app.allFaces.activeColorscaleDirection = -1;
    app.allFaces.activeColorscaleFactor = 0.5f;
    app.allFaces.passiveColorscaleIndex = 2;
    app.allFaces.passiveColorscaleDirection = 2;
    app.allFaces.passiveColorscaleFactor = 0.75f;

    processing.data.XML root = new processing.data.XML("root");
    app.allFaces.to_XML(root);

    solarchvision_bim.Faces fresh = app.new Faces();
    fresh.from_XML(root);

    assertEquals(1, fresh.nodes.length);
    assertArrayEquals(new int[]{5, 6, 7}, fresh.nodes[0]);
    assertArrayEquals(new int[]{3, 2, 1, 1, 4, 1}, fresh.options[0]);

    assertFalse(fresh.displayAll);
    assertTrue(fresh.showNormalLines);
    assertFalse(fresh.displayEdges);
    assertEquals(3, fresh.displayTessellation);
    assertEquals(9, fresh.activeColorscaleIndex);
    assertEquals(-1, fresh.activeColorscaleDirection);
    assertEquals(0.5f, fresh.activeColorscaleFactor, 0.0001f);
    assertEquals(2, fresh.passiveColorscaleIndex);
    assertEquals(2, fresh.passiveColorscaleDirection);
    assertEquals(0.75f, fresh.passiveColorscaleFactor, 0.0001f);
  }

  // ================= excludedFromFaceGrid / isPointInsideAnySpaceBoundingBox ==
  //
  // build_win3DCache() itself - the only place either of these is
  // actually read, and what populates the raycasting grid
  // (win3DCache_gridPoints*/win3DCache_gridFaces, then
  // entirePointsX/Y/Z/entireFaces once addToFaceGrid() copies them in) -
  // calls createShape(GROUP), which needs a real graphics context and
  // isn't unit-testable as-is in this headless environment (see
  // test/README.md's own "Extending this" section, and
  // UI_toolBarTest.java's viewLayout_allFourSubOptions() for the same
  // kind of createGraphics()-needs-a-real-surface issue elsewhere in
  // this suite). excludedFromFaceGrid() and
  // isPointInsideAnySpaceBoundingBox() are the actual per-face/per-build
  // decisions build_win3DCache() makes, pulled out into their own small,
  // pure methods for exactly that reason - this is what's actually
  // tested here, not the grid-building integration around them.

  @Test
  void excludedFromFaceGrid_true_forIFC_MATERIAL_SPACE_regardlessOfCameraPosition () {
    assertTrue(app.allFaces.excludedFromFaceGrid(app.IFC_MATERIAL_SPACE, false));
    assertTrue(app.allFaces.excludedFromFaceGrid(app.IFC_MATERIAL_SPACE, true));
  }

  @Test
  void excludedFromFaceGrid_glass_onlyWhenTheCameraIsInsideASpace () {
    assertFalse(app.allFaces.excludedFromFaceGrid(app.IFC_MATERIAL_GLASS, false), "camera outside every space: glass should still cast/receive a shadow");
    assertTrue(app.allFaces.excludedFromFaceGrid(app.IFC_MATERIAL_GLASS, true), "camera inside a space: glass shouldn't block a ray out through it");
  }

  @Test
  void excludedFromFaceGrid_false_forOrdinaryMaterials_regardlessOfCameraPosition () {
    // 0 is IFC_MATERIAL_SOLAR, included on purpose - a solar panel
    // should still cast/receive shadows, unlike a room/zone volume.
    for (boolean cameraInsideASpace : new boolean[]{false, true}) {
      assertFalse(app.allFaces.excludedFromFaceGrid(0, cameraInsideASpace));
      assertFalse(app.allFaces.excludedFromFaceGrid(1, cameraInsideASpace));
      assertFalse(app.allFaces.excludedFromFaceGrid(app.IFC_MATERIAL_CONCRETE, cameraInsideASpace));
      assertFalse(app.allFaces.excludedFromFaceGrid(app.IFC_MATERIAL_WATER, cameraInsideASpace));
    }
  }

  // A 2x2x2 room centred on the origin - faces 0-5 (a box's 6 sides),
  // all IFC_MATERIAL_SPACE - used by every isPointInsideAnySpaceBoundingBox
  // test below.
  private void buildOneSpaceBox () {
    app.allPoints.makeEmpty(0);
    float[][] corners = {
      {-1, -1, -1}, {1, -1, -1}, {1, 1, -1}, {-1, 1, -1},
      {-1, -1, 1}, {1, -1, 1}, {1, 1, 1}, {-1, 1, 1}
    };
    for (float[] c : corners) app.allPoints.create(c[0], c[1], c[2]);

    int[][] faceNodes = {
      {0, 1, 2, 3}, {4, 5, 6, 7}, {0, 1, 5, 4},
      {1, 2, 6, 5}, {2, 3, 7, 6}, {3, 0, 4, 7}
    };
    app.allFaces.makeEmpty(6);
    for (int f = 0; f < 6; f++) {
      app.allFaces.nodes[f] = faceNodes[f];
      app.allFaces.setMaterial(f, app.IFC_MATERIAL_SPACE);
    }
  }

  @Test
  void isPointInsideAnySpaceBoundingBox_pointInsideTheBox_isTrue () {
    buildOneSpaceBox();
    assertTrue(app.allFaces.isPointInsideAnySpaceBoundingBox(0, 0, 0), "dead centre");
    assertTrue(app.allFaces.isPointInsideAnySpaceBoundingBox(0.9f, 0.9f, 0.9f), "near a corner, still inside");
    assertTrue(app.allFaces.isPointInsideAnySpaceBoundingBox(1, 1, 1), "exactly on a corner - inclusive bounds");
  }

  @Test
  void isPointInsideAnySpaceBoundingBox_pointOutsideTheBox_isFalse () {
    buildOneSpaceBox();
    assertFalse(app.allFaces.isPointInsideAnySpaceBoundingBox(5, 0, 0));
    assertFalse(app.allFaces.isPointInsideAnySpaceBoundingBox(0, 0, 1.1f));
  }

  @Test
  void isPointInsideAnySpaceBoundingBox_noSpaceFacesAtAll_isAlwaysFalse () {
    app.allPoints.makeEmpty(0);
    app.allPoints.create(0, 0, 0);
    app.allPoints.create(1, 0, 0);
    app.allPoints.create(1, 1, 0);
    app.allFaces.makeEmpty(1);
    app.allFaces.nodes[0] = new int[]{0, 1, 2};
    app.allFaces.setMaterial(0, app.IFC_MATERIAL_CONCRETE); // not a space

    assertFalse(app.allFaces.isPointInsideAnySpaceBoundingBox(0.5f, 0.3f, 0));
  }

  @Test
  void isPointInsideAnySpaceBoundingBox_pointInsideASecondSeparateSpace_isTrue () {
    // Two separate rooms: the 2x2x2 box above at the origin, plus a
    // second, non-space face (a "wall", breaking the run - without it,
    // two space faces placed back to back with nothing non-space
    // between them are indistinguishable from one bigger room, which is
    // exactly the bug this fixture used to have), then a second small
    // room far away - a point between them (inside neither) should read
    // false, and a point inside the second room should still read true,
    // proving this checks every contiguous run of space faces
    // separately, not just merging everything into one.
    buildOneSpaceBox();

    app.allPoints.create(0, 0, 5);
    app.allPoints.create(1, 0, 5);
    app.allPoints.create(1, 1, 5);
    app.allPoints.create(19, 19, 19);
    app.allPoints.create(21, 19, 19);
    app.allPoints.create(21, 21, 19);
    app.allPoints.create(19, 21, 19);

    int before = app.allFaces.nodes.length;
    int[][] newNodes = new int[before + 2][];
    int[][] newOptions = new int[before + 2][6];
    for (int f = 0; f < before; f++) {
      newNodes[f] = app.allFaces.nodes[f];
      newOptions[f] = app.allFaces.options[f];
    }
    newNodes[before] = new int[]{8, 9, 10}; // the wall, non-space
    newNodes[before + 1] = new int[]{11, 12, 13, 14}; // the second room
    app.allFaces.nodes = newNodes;
    app.allFaces.options = newOptions;
    app.allFaces.setMaterial(before, app.IFC_MATERIAL_CONCRETE);
    app.allFaces.setMaterial(before + 1, app.IFC_MATERIAL_SPACE);

    assertFalse(app.allFaces.isPointInsideAnySpaceBoundingBox(10, 10, 10), "between the two rooms, inside neither");
    assertTrue(app.allFaces.isPointInsideAnySpaceBoundingBox(20, 20, 19), "inside the second, far-away room");
  }
}
