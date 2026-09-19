import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

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

  // ================= add_House2_Core (simplest gable roof) =============

  @Test
  void addHouse2Core_buildsTenVerticesAndSevenFaces () {
    app.Create3D.add_House2_Core(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 2, 3, 4, 0);

    assertEquals(10, app.allVertices.length); // b1-4, t1-4, m1, m2
    assertEquals(7, app.allFaces.nodes.length);
    assertArrayEquals(new float[]{1, 2, 0}, app.allVertices[0], 0.0001f); // b1
    assertArrayEquals(new float[]{1, 2, 3}, app.allVertices[4], 0.0001f); // t1
    assertArrayEquals(new float[]{1, 0, 7}, app.allVertices[8], 0.0001f); // m1: ridge apex, z = rz*(1+h2/rz) = 3+4
    assertArrayEquals(new float[]{-1, 0, 7}, app.allVertices[9], 0.0001f); // m2
  }

  @Test
  void addHouse2Core_isANoOpForANonPositiveExtent () {
    app.Create3D.add_House2_Core(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 3, 4, 0); // ry=0
    assertEquals(0, app.allVertices.length);
  }

  // ================= add_House3_Core (same shape family) ===============

  @Test
  void addHouse3Core_alsoBuildsTenVerticesAndSevenFaces () {
    // Same vertex layout as House2_Core, but NOT the same rotation: this
    // one uses teta = (90 + rot) * PI/180 (a +90deg offset House2_Core
    // does not have), so even with an identical rot input the resulting
    // positions differ - re-derived independently rather than assumed
    // shared with House2_Core's own test above.
    app.Create3D.add_House3_Core(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 2, 3, 4, 0);

    assertEquals(10, app.allVertices.length);
    assertEquals(7, app.allFaces.nodes.length);
    assertArrayEquals(new float[]{-2, 1, 0}, app.allVertices[0], 0.001f); // b1, rotated by the extra +90deg
  }

  // ================= add_House1_Core (hip roof, with rx==ry collapse) ==

  @Test
  void addHouse1Core_collapsesTheRidgeToASinglePointWhenRxEqualsRy () {
    // When rx==ry the two ridge points (m1, m2) coincide exactly, so the
    // implementation reuses the same point index for both and swaps in
    // 3-node "collapsed" roof faces instead of 4-node ones - a genuinely
    // distinct code path from House2/3_Core's fixed-shape gable roof.
    app.Create3D.add_House1_Core(0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 2, 3, 4, 0);

    assertEquals(9, app.allVertices.length); // only ONE ridge point, not two
    assertArrayEquals(new float[]{0, 0, 7}, app.allVertices[8], 0.0001f); // the shared ridge apex

    // 9 faces total: West, Roof-West, Roof-South, East, Roof-East,
    // North, South, Roof-North, Bottom. Roof-West and Roof-East are
    // ALWAYS 3-node triangles by design, with no ternary at all; only
    // Roof-South and Roof-North actually depend on the rx==ry collapse
    // (4-node quads otherwise, since m2 would then be a genuinely
    // separate point) - so 4 triangles total here either way.
    assertEquals(9, app.allFaces.nodes.length);
    int triangleCount = 0;
    for (int[] face : app.allFaces.nodes) if (face.length == 3) triangleCount++;
    assertEquals(4, triangleCount);
  }

  // ================= add_H_shade / add_V_shade ==========================

  @Test
  void addHShade_buildsASingleTiltedQuad () {
    app.Create3D.add_H_shade(0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 3, 0, 0);

    assertEquals(4, app.allVertices.length);
    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new float[]{1, 0, 0}, app.allVertices[0], 0.001f);
    assertArrayEquals(new float[]{-1, 0, 0}, app.allVertices[1], 0.001f);
    assertArrayEquals(new float[]{-1, -3, 0}, app.allVertices[2], 0.001f);
    assertArrayEquals(new float[]{1, -3, 0}, app.allVertices[3], 0.001f);
  }

  @Test
  void addHShade_isANoOpForANonPositiveDimension () {
    app.Create3D.add_H_shade(0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 3, 0, 0); // d=0
    assertEquals(0, app.allVertices.length);
  }

  @Test
  void addVShade_buildsASingleVerticalQuad () {
    app.Create3D.add_V_shade(0, 0, 0, 1, 0, 0, 0, 0, 0, 4, 2, 0, 0);

    assertEquals(4, app.allVertices.length);
    assertArrayEquals(new float[]{0, 0, -2}, app.allVertices[0], 0.001f);
    assertArrayEquals(new float[]{0, 0, 2}, app.allVertices[1], 0.001f);
    assertArrayEquals(new float[]{0, -2, 2}, app.allVertices[2], 0.001f);
    assertArrayEquals(new float[]{0, -2, -2}, app.allVertices[3], 0.001f);
  }

  @Test
  void addVShade_isANoOpForANonPositiveDimension () {
    app.Create3D.add_V_shade(0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 2, 0, 0); // h=0
    assertEquals(0, app.allVertices.length);
  }

  // ================= add_Mesh3 / add_Mesh4 (and the collapse chain) ====

  @Test
  void addMesh3_buildsATriangleFromThreeDistinctPoints () {
    app.Create3D.add_Mesh3(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0);
    assertEquals(3, app.allVertices.length);
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(3, app.allFaces.nodes[0].length);
  }

  @Test
  void addMesh3_isANoOpWhenAnyTwoOfTheThreeCornersCoincide () {
    app.Create3D.add_Mesh3(0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0); // corners 1 and 2 coincide
    assertEquals(0, app.allVertices.length);
  }

  @Test
  void addMesh4_buildsAQuadWhenAllFourCornersAreDistinct () {
    app.Create3D.add_Mesh4(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0);
    assertEquals(4, app.allVertices.length);
    assertEquals(4, app.allFaces.nodes[0].length);
  }

  @Test
  void addMesh4_collapsesToATriangleWhenTwoAdjacentCornersCoincide () {
    // Corners 1 and 2 coincide, so this falls back to add_Mesh3 with
    // corners 1, 3, 4 - only 3 points get created, not 4.
    app.Create3D.add_Mesh4(0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0);
    assertEquals(3, app.allVertices.length);
    assertEquals(3, app.allFaces.nodes[0].length);
  }

  // Mesh5/Mesh6 chain down to Mesh4/Mesh5 the same way Mesh4 chains to
  // Mesh3 above - not re-verified node-by-node, but checked for both the
  // full-shape and one-collapse case to confirm the chain itself works.

  @Test
  void addMesh5_buildsAPentagonWhenAllFiveCornersAreDistinct () {
    app.Create3D.add_Mesh5(0, 0, 0, 1, 0, 0,
      0, 0, 0, 2, 0, 0, 2, 2, 0, 1, 3, 0, 0, 2, 0);
    assertEquals(5, app.allVertices.length);
    assertEquals(5, app.allFaces.nodes[0].length);
  }

  @Test
  void addMesh5_collapsesToAQuadWhenTwoAdjacentCornersCoincide () {
    app.Create3D.add_Mesh5(0, 0, 0, 1, 0, 0,
      0, 0, 0, 0, 0, 0, 2, 2, 0, 1, 3, 0, 0, 2, 0); // corners 1,2 coincide
    assertEquals(4, app.allVertices.length);
  }

  @Test
  void addMesh6_buildsAHexagonWhenAllSixCornersAreDistinct () {
    app.Create3D.add_Mesh6(0, 0, 0, 1, 0, 0,
      0, 0, 0, 2, 0, 0, 3, 1, 0, 2, 2, 0, 0, 2, 0, -1, 1, 0);
    assertEquals(6, app.allVertices.length);
    assertEquals(6, app.allFaces.nodes[0].length);
  }

  @Test
  void addMesh6_collapsesToAPentagonWhenTwoAdjacentCornersCoincide () {
    app.Create3D.add_Mesh6(0, 0, 0, 1, 0, 0,
      0, 0, 0, 0, 0, 0, 3, 1, 0, 2, 2, 0, 0, 2, 0, -1, 1, 0); // corners 1,2 coincide
    assertEquals(5, app.allVertices.length);
  }

  // ================= add_PolygonHyper / add_PolygonExtrude ==============

  @Test
  void addPolygonHyper_alternatesHeightAroundTheRing () {
    app.Create3D.add_PolygonHyper(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 2, 4, 0);

    assertEquals(4, app.allVertices.length);
    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new float[]{1, 0, -1}, app.allVertices[0], 0.001f);
    assertArrayEquals(new float[]{0, 1, 1}, app.allVertices[1], 0.001f);
    assertArrayEquals(new float[]{-1, 0, -1}, app.allVertices[2], 0.001f);
    assertArrayEquals(new float[]{0, -1, 1}, app.allVertices[3], 0.001f);
  }

  @Test
  void addPolygonHyper_isANoOpForTooFewSides () {
    app.Create3D.add_PolygonHyper(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 2, 2, 0);
    assertEquals(0, app.allVertices.length);
  }

  @Test
  void addPolygonExtrude_buildsATopRingBottomRingAndSideWalls () {
    // Points are created INTERLEAVED per ring index - vT[0], vB[0],
    // vT[1], vB[1], ... - not all 4 top points followed by all 4 bottom
    // points. Missed this on the first pass and asserted against the
    // wrong indices; recomputed the whole creation order in Python
    // before rewriting these assertions.
    app.Create3D.add_PolygonExtrude(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 2, 4, 0);

    assertEquals(8, app.allVertices.length); // 4 top + 4 bottom, no sharing between them
    assertEquals(6, app.allFaces.nodes.length); // top cap, bottom cap, 4 side walls
    assertArrayEquals(new float[]{1, 0, 1}, app.allVertices[0], 0.001f);  // vT[0]
    assertArrayEquals(new float[]{1, 0, -1}, app.allVertices[1], 0.001f); // vB[0]
    assertArrayEquals(new int[]{0, 2, 4, 6}, app.allFaces.nodes[0]); // top cap: vT[0],vT[1],vT[2],vT[3]
    assertArrayEquals(new int[]{1, 3, 5, 7}, app.allFaces.nodes[1]); // bottom cap: vB[0],vB[1],vB[2],vB[3]
    assertArrayEquals(new int[]{0, 1, 3, 2}, app.allFaces.nodes[2]); // side wall 0: vT[0],vB[0],vB[1],vT[1]
  }

  @Test
  void addPolygonExtrude_isANoOpForANonPositiveHeight () {
    app.Create3D.add_PolygonExtrude(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 4, 0);
    assertEquals(0, app.allVertices.length);
  }

  // ================= add_Icosahedron ===================================

  @Test
  void addIcosahedron_buildsTwelveVerticesAndTwentyTriangularFaces () {
    app.Create3D.add_Icosahedron(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0);

    assertEquals(12, app.allVertices.length); // 2 poles + 5 + 5 ring
    assertEquals(20, app.allFaces.nodes.length);
    for (int[] face : app.allFaces.nodes) assertEquals(3, face.length);

    assertArrayEquals(new float[]{0, 0, 1}, app.allVertices[0], 0.0001f);  // north pole
    assertArrayEquals(new float[]{0, 0, -1}, app.allVertices[1], 0.0001f); // south pole
  }

  @Test
  void addIcosahedron_isANoOpForANonPositiveRadius () {
    app.Create3D.add_Icosahedron(0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0);
    assertEquals(0, app.allVertices.length);
  }

  // ================= add_ParametricSurface ==============================
  //
  // Unlike every other generator here, this one has NO validity guard at
  // all - it always runs, sweeping a (u, v) grid whose exact face count
  // depends on floating-point loop-increment behavior this suite doesn't
  // try to replicate exactly. Checked instead for producing a
  // substantial, non-trivial amount of geometry, and for the very first
  // grid corner's position (deterministic regardless of loop-count
  // edge cases).

  @Test
  void addParametricSurface_buildsAGridOfQuadsFromTheFirstCornerOnward () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0);

    assertTrue(app.allFaces.nodes.length > 100); // a substantial grid, not a handful of faces
    for (int[] face : app.allFaces.nodes) assertEquals(4, face.length);

    // n=1: x=u, y=v, z=cos(0.5*u*PI)*cos(0.5*v*PI); first corner at u=v=start_u=start_v=-1.
    float expectedZ = (float) (Math.cos(0.5 * -1 * Math.PI) * Math.cos(0.5 * -1 * Math.PI));
    assertArrayEquals(new float[]{-1, -1, expectedZ}, app.allVertices[0], 0.01f);
  }

  // ================= add_CrystalSphere ==================================
  //
  // Routes through the temp-object/lozenge-tessellation pipeline rather
  // than directly calling allPoints.create()/allFaces.create() itself -
  // checked as a smoke test (real geometry lands in the scene, or in
  // skyVertices/skyFaces, depending on isSky) rather than exact vertex
  // positions.

  @Test
  void addCrystalSphere_flushesGeometryIntoTheSceneWhenNotBuildingASky () {
    app.Create3D.add_CrystalSphere(0, 0, 0, 1, 0, 0, 0, 0, 0, 5, 1, 0, 0); // isSky=0

    assertTrue(app.allVertices.length > 0);
    assertTrue(app.allFaces.nodes.length > 0);
    // The temp buffers are fully flushed and reset, not left dangling.
    assertEquals(0, app.POINTER_TempObjectVertices);
    assertEquals(0, app.POINTER_TempObjectFaces);
  }

  @Test
  void addCrystalSphere_populatesSkyVerticesInsteadOfTheSceneWhenBuildingASky () {
    app.Create3D.add_CrystalSphere(0, 0, 0, 1, 0, 0, 0, 0, 0, 5, 1, 1, 0); // isSky=1

    assertEquals(0, app.allVertices.length); // nothing added to the ordinary scene
    assertEquals(0, app.allFaces.nodes.length);
    assertTrue(app.skyVertices.length > 0); // it went into the sky buffers instead
    assertTrue(app.skyFaces.length > 0);
  }

  // ================= add_SuperSphere / add_SuperCylinder ================
  //
  // Both build in the same temp-object pipeline as add_CrystalSphere
  // (add_SuperSphere calls it directly, with isSky=-1, then reshapes the
  // temp vertices before flushing) - smoke-tested the same way.

  @Test
  void addSuperSphere_flushesReshapedGeometryIntoTheScene () {
    app.Create3D.add_SuperSphere(0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 2, 2, 1, 1, 1, 1, 0);

    assertTrue(app.allVertices.length > 0);
    assertTrue(app.allFaces.nodes.length > 0);
    assertEquals(0, app.POINTER_TempObjectVertices);
  }

  @Test
  void addSuperCylinder_flushesReshapedGeometryIntoTheScene () {
    app.Create3D.add_SuperCylinder(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 6, 0);

    assertTrue(app.allVertices.length > 0);
    assertTrue(app.allFaces.nodes.length > 0);
    assertEquals(0, app.POINTER_TempObjectVertices);
  }

  // ================= add_onPolar / add_onPlane / add_onMesh2 ============
  //
  // All three scatter a fixed COUNT (n) of randomly-placed people, trees,
  // or Model1Ds - positions are random by design, so only the count and
  // the people/trees/model1D dispatch are checked, not exact placement.

  @Test
  void addOnPolar_createsExactlyNPeopleWhenRequested () {
    app.Create3D.add_onPolar(1, 5, 0, 0, 0, 1, 10);
    assertEquals(5, app.allModel2Ds.num);
  }

  @Test
  void addOnPolar_createsExactlyNModel1DsForAnyOtherValue () {
    app.Create3D.add_onPolar(0, 4, 0, 0, 0, 1, 10);
    assertEquals(4, app.allModel1Ds.num);
  }

  @Test
  void addOnPlane_createsExactlyNTreesWhenRequested () {
    app.Create3D.add_onPlane(2, 3, 0, 0, 0, 20, 20, 0);
    assertEquals(3, app.allModel2Ds.num);
  }

  @Test
  void addOnMesh2_createsExactlyNItemsCenteredBetweenTheTwoCorners () {
    app.Create3D.add_onMesh2(1, 6, -20, -20, 0, 20, 20, 0);
    assertEquals(6, app.allModel2Ds.num);
  }

  // ================= add_DefaultModel ====================================

  @Test
  void addDefaultModel_n1BuildsAMeshAndACrystalSphereInTwoGroups () {
    // loadMesh is set false so this routes through the (no-op)
    // else-branch for the land-scatter portion, instead of add_onLand -
    // which is not exercised directly, per this file's header.
    app.Land3D.loadMesh = false;

    app.Create3D.add_DefaultModel(1);

    assertEquals(2, app.allGroups.num);
    assertTrue(app.allFaces.nodes.length > 0);
    assertEquals(0, app.Select3D.Group_ids.length); // deselectAll() runs at the end
  }

  @Test
  void addDefaultModel_n4BuildsAMeshAndAHouseInTwoGroups () {
    app.Land3D.loadMesh = false;

    app.Create3D.add_DefaultModel(4);

    assertEquals(2, app.allGroups.num);
    assertEquals(1 + 7, app.allFaces.nodes.length); // Mesh2's 1 face + House3_Core's 7 faces
  }
}
