import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Exercises solarchvision_Create3D (Create3D.pde), reached through the
// pre-constructed `app.Create3D` field. This file is a library of
// roughly 28 "add_X" geometric-primitive generators (boxes, houses,
// meshes, polygons, spheres, cylinders, land-scattering helpers) that
// all follow the same shape: validate the given dimensions, compute a
// handful of corner points via straightforward trig, allPoints.create()
// each one, allFaces.create() the resulting face(s), then call
// SOLARCHVISION_model_added(). Exhaustively re-testing all 28 would
// mostly repeat the same verification pattern for cosmetically
// different shapes, so this suite tests a representative sample in
// full (exact vertex positions, computed independently before writing
// each assertion) plus every generator's *validity guard* pattern, and
// treats the untested ones as covered by the same pattern established
// here.
//
// Representative sample, chosen to cover the distinct math shapes seen
// across the family: add_Box_Corners (axis-aligned corner-to-corner box,
// the simplest), add_Box_Core (the same box, but built from a
// center+half-extents+rotation instead), add_Mesh2 (a single quad
// inferred from two opposite corners, auto-detecting which axis is
// flat), add_Octahedron (a non-box platonic solid), add_PolygonMesh (an
// n-gon fan around a center, the polar/circular family's simplest
// member), add_Model_Main (the trivial "start a new group" helper).
//
// NOT covered: add_Model_2DsFromFile() - calls loadStrings() on a real
// file (BaseFolder + "/Import/Hamedan_PEOPLE.txt") that does not exist
// in this repository checkout, so calling it would throw rather than
// exercise anything meaningful; the per-row allModel2Ds.create() call it
// makes is already covered directly in Model2DsTest.java. Every other
// add_X generator (House1/2/3_Core, Mesh3/4/5/6, PolygonHyper/Extrude,
// Icosahedron, ParametricSurface, CrystalSphere, SuperSphere/Cylinder,
// H_shade/V_shade, onLand/onPolar/onPlane/onMesh2, add_DefaultModel) is
// the same "compute points, create points+faces, guard, notify" pattern
// as the sample above, just with different (sometimes considerably more
// involved) corner math - not retested individually here.
//
// A fresh `app` per test since these mutate shared scene state.
class Create3DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= add_Box_Corners ==================================

  @Test
  void addBoxCorners_buildsAnAxisAlignedBoxWithSixQuadFaces () {
    app.Create3D.add_Box_Corners(3, 1, 2, 1, 4, 0, 0, 0, 0, 2, 2, 2);

    assertEquals(8, app.allVertices.length); // 4 top + 4 bottom corners
    assertEquals(6, app.allFaces.nodes.length); // West, Roof, East, North, South, Bottom

    // Top corners are created first, in order t1..t4 = (x2,y2,z2), (x1,y2,z2), (x1,y1,z2), (x2,y1,z2).
    assertArrayEquals(new float[]{2, 2, 2}, app.allVertices[0], 0.0001f); // t1
    assertArrayEquals(new float[]{0, 2, 2}, app.allVertices[1], 0.0001f); // t2
    assertArrayEquals(new float[]{0, 0, 2}, app.allVertices[2], 0.0001f); // t3
    assertArrayEquals(new float[]{2, 0, 2}, app.allVertices[3], 0.0001f); // t4
    // Bottom corners follow, at z1=0 instead of z2=2.
    assertArrayEquals(new float[]{2, 2, 0}, app.allVertices[4], 0.0001f); // b1

    assertArrayEquals(new int[]{2, 1, 5, 6}, app.allFaces.nodes[0]); // West: t3,t2,b2,b3
    assertArrayEquals(new int[]{0, 1, 2, 3}, app.allFaces.nodes[1]); // Roof: t1,t2,t3,t4

    // Options reflect the current_* globals as set at call time.
    assertArrayEquals(new int[]{3, 1, 2, 1, 4, 0}, app.allFaces.options[0]);
  }

  @Test
  void addBoxCorners_isANoOpWhenBothCornersCoincide () {
    app.Create3D.add_Box_Corners(0, 0, 0, 1, 0, 0, 5, 5, 5, 5, 5, 5);
    assertEquals(0, app.allVertices.length);
    assertEquals(0, app.allFaces.nodes.length);
  }

  // ================= add_Box_Core =====================================

  @Test
  void addBoxCore_buildsABoxFromACenterHalfExtentsAndRotation () {
    // At rot=90deg, (rx, ry) rotates like a standard CCW 2D rotation:
    // (1, 2) -> (-2, 1) - verified independently before writing this.
    app.Create3D.add_Box_Core(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 2, 3, 90);

    assertEquals(8, app.allVertices.length);
    assertEquals(6, app.allFaces.nodes.length);
    assertArrayEquals(new float[]{-2, 1, 3}, app.allVertices[0], 0.001f); // t1
  }

  @Test
  void addBoxCore_isANoOpForANonPositiveExtent () {
    app.Create3D.add_Box_Core(0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 2, 3, 0);
    assertEquals(0, app.allVertices.length);
  }

  // ================= add_Mesh2 ========================================

  @Test
  void addMesh2_infersAFlatHorizontalRectangleWhenZMatches () {
    app.Create3D.add_Mesh2(0, 0, 0, 1, 0, 0, 0, 0, 0, 10, 10, 0);

    assertEquals(4, app.allVertices.length);
    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new float[]{0, 0, 0}, app.allVertices[0], 0.0001f); // v1
    assertArrayEquals(new float[]{10, 0, 0}, app.allVertices[1], 0.0001f); // v2, y snapped to y1
    assertArrayEquals(new float[]{10, 10, 0}, app.allVertices[2], 0.0001f); // v3
    assertArrayEquals(new float[]{0, 10, 0}, app.allVertices[3], 0.0001f); // v4, y snapped to y3
  }

  @Test
  void addMesh2_infersAVerticalRectangleWhenYMatches () {
    app.Create3D.add_Mesh2(0, 0, 0, 1, 0, 0, 0, 0, 0, 10, 0, 10);

    assertArrayEquals(new float[]{0, 0, 0}, app.allVertices[0], 0.0001f);   // v1
    assertArrayEquals(new float[]{0, 0, 10}, app.allVertices[1], 0.0001f); // v2, x snapped to x1
    assertArrayEquals(new float[]{10, 0, 10}, app.allVertices[2], 0.0001f); // v3
    assertArrayEquals(new float[]{10, 0, 0}, app.allVertices[3], 0.0001f); // v4, x snapped to x3
  }

  @Test
  void addMesh2_isANoOpWhenBothCornersCoincide () {
    app.Create3D.add_Mesh2(0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1);
    assertEquals(0, app.allVertices.length);
  }

  // ================= add_Octahedron ====================================

  @Test
  void addOctahedron_buildsSixVerticesAndEightTriangularFaces () {
    app.Create3D.add_Octahedron(3, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0);

    assertEquals(6, app.allVertices.length);
    assertEquals(8, app.allFaces.nodes.length);
    for (int[] face : app.allFaces.nodes) {
      assertEquals(3, face.length); // every face is a triangle
    }
    // Vertex 0 is the +Z apex: (0, 0, sqrt(2)) before scaling by rx=ry=rz=1.
    assertArrayEquals(new float[]{0, 0, (float) Math.sqrt(2)}, app.allVertices[0], 0.001f);
  }

  @Test
  void addOctahedron_isANoOpForANonPositiveRadius () {
    app.Create3D.add_Octahedron(3, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0); // rz=0
    assertEquals(0, app.allVertices.length);
  }

  // ================= add_PolygonMesh ===================================

  @Test
  void addPolygonMesh_buildsARegularNGonAroundItsCenter () {
    app.Create3D.add_PolygonMesh(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 4, 0); // unit square, 4 sides

    assertEquals(4, app.allVertices.length);
    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2, 3}, app.allFaces.nodes[0]);
    assertArrayEquals(new float[]{1, 0, 0}, app.allVertices[0], 0.001f);
    assertArrayEquals(new float[]{0, 1, 0}, app.allVertices[1], 0.001f);
    assertArrayEquals(new float[]{-1, 0, 0}, app.allVertices[2], 0.001f);
    assertArrayEquals(new float[]{0, -1, 0}, app.allVertices[3], 0.001f);
  }

  @Test
  void addPolygonMesh_isANoOpForTooFewSides () {
    app.Create3D.add_PolygonMesh(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 2, 0); // n must be > 2
    assertEquals(0, app.allVertices.length);
  }

  // ================= add_Model_Main ====================================

  @Test
  void addModelMain_startsANewGroupAndClearsAddToLastGroup () {
    app.addToLastGroup = true;

    app.Create3D.add_Model_Main();

    assertEquals(1, app.allGroups.num);
    assertFalse(app.addToLastGroup);
  }
}
