import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Create3D.add_ParametricSurface() (create3D.pde) only had n=1 covered
// (Create3DTest.java's own addParametricSurface_... test) of its 19
// surface types (n=0 Cushion, 1, 2, 3, 4, 5, 6 LOGO, 7 Torus, 8
// Hyperbolic Disc, 9 Paraboloid Dome, 10 Hyperboloid of Revolution, 11
// Helicoid, 12 Catenoid, 13 Conoid, 14 Tractricoid, 15 Monkey Saddle, 16
// Scherk's Surface, 17 Dini's Surface, 18 Seashell) - the remaining 18 are covered here, following that same existing
// test's own reasoning exactly (see its header comment): this function
// has no validity guard at all, and its exact face count depends on
// floating-point loop-increment behavior this suite doesn't try to
// replicate - so each test checks for a substantial, non-trivial amount
// of quad geometry, and the deterministic position of the very first
// grid corner (u = start_u, v = start_v = -1 always; start_u is 0 for
// n == 0, 6, 8, or 9, -1 otherwise - read directly from the function's
// own "if ((n == 0) || (n == 6) || (n == 8) || (n == 9)) start_u = 0;"
// line), computed from each n's own x/y/z formula.
//
// Expected first-corner positions were cross-checked against a
// standalone Python re-implementation of each formula, not just hand-
// arithmetic - n=0 and n=6 land on the same point here (their own x0/y0/
// z0 happens to already have length 1 at this particular corner, making
// n=6's own LOGO normalization step a no-op there), and likewise n=4/n=5.
class AddParametricSurfaceRemainingTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  private void assertSubstantialQuadGrid () {
    assertTrue(app.allFaces.nodes.length > 100);
    for (int[] face : app.allFaces.nodes) assertEquals(4, face.length);
  }

  @Test
  void n0_cushion_buildsAGrid_firstCornerAtUZeroVMinusOne () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 20, 20);

    assertSubstantialQuadGrid();
    // start_u = 0 (n == 0), start_v = -1 always.
    // x = cos(0*PI) = 1; y = sin(-PI) ~= 0; z = -sin(0*PI)*cos(-PI) = 0.
    assertArrayEquals(new float[]{1, 0, 0}, app.allVertices[0], 0.01f);
  }

  @Test
  void n2_buildsAGrid_firstCornerAtUMinusOneVMinusOne () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 2, 0, 0, 20, 20);

    assertSubstantialQuadGrid();
    // x=u=-1; y=v=-1; z=0.5*sin(-PI)*sin(-PI) ~= 0.
    assertArrayEquals(new float[]{-1, -1, 0}, app.allVertices[0], 0.01f);
  }

  @Test
  void n3_buildsAGrid_firstCornerAtUMinusOneVMinusOne () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 3, 0, 0, 20, 20);

    assertSubstantialQuadGrid();
    // x=u=-1; y=v=-1; z=u*v=1.
    assertArrayEquals(new float[]{-1, -1, 1}, app.allVertices[0], 0.01f);
  }

  @Test
  void n4_buildsAGrid_firstCornerAtUMinusOneVMinusOne () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 4, 0, 0, 20, 20);

    assertSubstantialQuadGrid();
    // x=sin(-PI)~=0; y=sin(-PI)~=0; z=cos(-2*PI)=1.
    assertArrayEquals(new float[]{0, 0, 1}, app.allVertices[0], 0.01f);
  }

  @Test
  void n5_buildsAGrid_firstCornerAtUMinusOneVMinusOne () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 5, 0, 0, 20, 20);

    assertSubstantialQuadGrid();
    // Same x0/y0/z0 as n=4 at this corner (~0,~0,1), already length 1,
    // so the normalization step here is a no-op.
    assertArrayEquals(new float[]{0, 0, 1}, app.allVertices[0], 0.01f);
  }

  @Test
  void n6_logo_buildsAGrid_firstCornerAtUZeroVMinusOne () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 6, 0, 0, 20, 20);

    assertSubstantialQuadGrid();
    // Same x0/y0/z0 as n=0 at this corner (1,~0,0), already length 1,
    // so the normalization step here is a no-op too.
    assertArrayEquals(new float[]{1, 0, 0}, app.allVertices[0], 0.01f);
  }

  @Test
  void n7_torus_buildsAGrid_firstCornerAtUMinusOneVMinusOne () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 7, 0, 0.3f, 20, 20);

    assertSubstantialQuadGrid();
    // start_u = start_v = -1 (n==7 isn't in the "start_u = 0" list).
    // cos(v*PI) = cos(-PI) = -1, so x = (1 + k*-1)*cos(-PI) = (1-k)*-1 = k-1;
    // y = (1-k)*sin(-PI) ~= 0; z = k*sin(-PI) ~= 0.
    assertArrayEquals(new float[]{-0.7f, 0, 0}, app.allVertices[0], 0.01f);
  }

  @Test
  void n8_hyperbolicDisc_buildsAGrid_firstCornerAtTheCenter () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 8, 0, 0, 20, 20);

    assertSubstantialQuadGrid();
    // start_u = 0 (n==8 IS in the "start_u = 0" list - it's a radius,
    // not a Cartesian coordinate) - so the very first corner sits at the
    // disc's own center (r=0), regardless of angle: x=y=z=0.
    assertArrayEquals(new float[]{0, 0, 0}, app.allVertices[0], 0.01f);
  }

  @Test
  void n8_hyperbolicDisc_isTheSameSaddleShapeAsN3_onACircularFootprint () {
    // Both n=3 (Saddle, z=u*v) and n=8 (Hyperbolic Disc) are the same
    // hyperbolic paraboloid height field, z = x*y - this test confirms
    // every vertex n=8 actually produces satisfies that same surface
    // equation (not some other, coincidentally similar-looking formula),
    // the one thing the first-corner check above can't tell apart since
    // z = x*y is trivially 0 right at the disc's own center regardless.
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 8, 0, 0, 20, 20);

    boolean foundNonTrivialPoint = false;
    for (float[] v : app.allVertices) {
      assertEquals(v[0] * v[1], v[2], 0.0001f, "every vertex must satisfy z = x*y");
      if ((Math.abs(v[0]) > 0.1f) && (Math.abs(v[1]) > 0.1f)) foundNonTrivialPoint = true;
    }
    assertTrue(foundNonTrivialPoint, "setup check - this grid should contain at least one point well away from either the center or an axis");
  }

  @Test
  void n8_hyperbolicDisc_everyVertexStaysWithinTheUnitDisc () {
    // Unlike n=3 Saddle's own square footprint, every n=8 vertex's own
    // (x, y) distance from the Z axis should never exceed the disc's own
    // radius (1, before rx/ry/rz scale it) - r = u is in [0, 1] by
    // construction, and clipping/magnitude can only ever shrink that via
    // cos/sin, never grow it.
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 8, 0, 0, 20, 20);

    for (float[] v : app.allVertices) {
      float dist = (float) Math.sqrt(v[0] * v[0] + v[1] * v[1]);
      assertTrue(dist <= 1.001f, "every vertex must stay within the unit disc, found distance " + dist);
    }
  }

  @Test
  void n9_paraboloidDome_buildsAGrid_firstCornerAtTheApex () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 9, 0, 0, 20, 20);

    assertSubstantialQuadGrid();
    // start_u = 0 (n==9 IS in the "start_u = 0" list, same as n==8 - a
    // radius) - so the very first corner sits at the dome's own apex
    // (r=0): x=y=0, z = PARABOLOID_DOME_APEX_HEIGHT - PARABOLOID_DOME_
    // DEPTH_SCALE*0 = 2.
    assertArrayEquals(new float[]{0, 0, 2}, app.allVertices[0], 0.01f);
  }

  @Test
  void n9_paraboloidDome_everyVertexSatisfiesZEqualsTwoMinusTwoRSquared_andStaysWithinTheUnitDisc () {
    // z = PARABOLOID_DOME_APEX_HEIGHT - PARABOLOID_DOME_DEPTH_SCALE * r^2
    // = 2 - 2 * (x^2+y^2) - flipped (negated r^2 term, so the apex at
    // r=0 is the highest point, not the lowest) and doubled (so the rim
    // at r=1 sits 2 units below the apex, not 1) from the dish's own
    // former z = r^2, with PARABOLOID_DOME_APEX_HEIGHT set equal to
    // PARABOLOID_DOME_DEPTH_SCALE so the rim (z=2-2=0) lands at exactly
    // z=0 - that's what sits the dome on the ground by default once rz
    // scales it, regardless of what rz actually is.
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 9, 0, 0, 20, 20);

    boolean foundNonApexPoint = false;
    for (float[] v : app.allVertices) {
      float distSq = v[0] * v[0] + v[1] * v[1];
      assertEquals(2 - 2 * distSq, v[2], 0.0001f, "every vertex must satisfy z = 2 - 2 * (x^2 + y^2)");
      assertTrue(v[2] >= -0.0001f, "every vertex must stay at or above z=0, found z=" + v[2]);
      assertTrue(Math.sqrt(distSq) <= 1.001f, "every vertex must stay within the unit disc");
      if (distSq > 0.01f) foundNonApexPoint = true;
    }
    assertTrue(foundNonApexPoint, "setup check - this grid should contain at least one point away from the apex");
  }

  @Test
  void n10_hyperboloidOfRevolution_buildsAGrid_firstCornerAtTheExpectedHyperbolaPoint () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 10, 0, 0, 20, 20);

    assertSubstantialQuadGrid();
    // start_u = start_v = -1 (n==10 isn't in the "start_u = 0" list - u
    // is a full angle sweep, same as n==7 Torus's own u, not a radius).
    // height = v * REVOLUTION_HEIGHT_SCALE = -1*2 = -2; theta = -PI;
    // r = sqrt(1 + (-2)^2) = sqrt(5);
    // x = sqrt(5)*cos(-PI) = -sqrt(5); y = sqrt(5)*sin(-PI) ~= 0; z = -2.
    assertArrayEquals(new float[]{-2.2361f, 0, -2}, app.allVertices[0], 0.01f);
  }

  @Test
  void n10_hyperboloidOfRevolution_everyVertexSatisfiesTheHyperbolaEquation () {
    // x^2 + y^2 = r^2 = 1 + height^2 = 1 + z^2 (since z = height exactly,
    // whatever REVOLUTION_HEIGHT_SCALE is set to) - the defining equation
    // of a single-sheet hyperboloid of revolution.
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 10, 0, 0, 20, 20);

    float minDistFromAxis = Float.MAX_VALUE;
    for (float[] v : app.allVertices) {
      float distSq = v[0] * v[0] + v[1] * v[1];
      assertEquals(1 + v[2] * v[2], distSq, 0.001f, "every vertex must satisfy x^2 + y^2 = 1 + z^2");
      minDistFromAxis = Math.min(minDistFromAxis, (float) Math.sqrt(distSq));
    }
    // The waist (z=0, the narrowest ring) should actually appear in this
    // grid - same "the sampled grid actually reaches the shape's own
    // extreme" reasoning as TorusTest.java's own ring-thickness test.
    assertEquals(1f, minDistFromAxis, 0.01f, "the waist's own radius should be exactly 1, and the grid should include it");
  }

  @Test
  void n11_helicoid_buildsAGrid_firstCornerAtTheExpectedRampPoint () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 11, 0, 0, 20, 20);

    assertSubstantialQuadGrid();
    // start_u = start_v = -1 (n==11 isn't in the "start_u = 0" list - u is
    // a radius, both signs, same -1..1 convention as n==3 Saddle's own u,
    // not the 0..1 radius n==8/9 use). theta = v * HELICOID_TURNS * PI =
    // -1*2*PI = -2*PI; r = u = -1; x = -1*cos(-2*PI) = -1;
    // y = -1*sin(-2*PI) ~= 0; z = v = -1.
    assertArrayEquals(new float[]{-1, 0, -1}, app.allVertices[0], 0.01f);
  }

  @Test
  void n11_helicoid_everyVertexLiesOnItsOwnRadialRampLine_withinUnitRadiusAndHeight () {
    // z = v exactly, and theta = z * HELICOID_TURNS * PI (HELICOID_TURNS
    // = 2, create3D.pde) - so every vertex (x, y, z) must lie on the
    // line through the axis at that angle, whichever sign r = u itself
    // had (a negative r just lands on the same line, opposite side):
    // x*sin(theta) = r*cos(theta)*sin(theta) = y*cos(theta) always.
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 11, 0, 0, 20, 20);

    boolean foundOffAxisPoint = false;
    for (float[] v : app.allVertices) {
      float theta = (float) (v[2] * 2 * Math.PI);
      float lhs = (float) (v[0] * Math.sin(theta));
      float rhs = (float) (v[1] * Math.cos(theta));
      assertEquals(lhs, rhs, 0.01f, "every vertex must lie on the ramp's own radial line at its height's winding angle");

      float dist = (float) Math.sqrt(v[0] * v[0] + v[1] * v[1]);
      assertTrue(dist <= 1.001f, "every vertex must stay within unit radius of the axis, found distance " + dist);
      assertTrue(Math.abs(v[2]) <= 1.001f, "every vertex must stay within unit height");
      if (dist > 0.01f) foundOffAxisPoint = true;
    }
    assertTrue(foundOffAxisPoint, "setup check - this grid should contain at least one point away from the axis");
  }

  @Test
  void n12_catenoid_buildsAGrid_firstCornerAtTheExpectedCatenaryPoint () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 12, 0, 0, 20, 20);

    assertSubstantialQuadGrid();
    // start_u = start_v = -1 (n==12 isn't in the "start_u = 0" list - u
    // is a full angle sweep, same as n==7 Torus/n==10 Hyperboloid's own
    // u). height = v * REVOLUTION_HEIGHT_SCALE = -1*2 = -2; theta = -PI;
    // r = cosh(-2) = (e^2 + e^-2)/2 ~= 3.7622;
    // x = 3.7622*cos(-PI) = -3.7622; y = 3.7622*sin(-PI) ~= 0; z = -2.
    assertArrayEquals(new float[]{-3.7622f, 0, -2}, app.allVertices[0], 0.01f);
  }

  @Test
  void n12_catenoid_everyVertexSatisfiesTheCatenaryEquation () {
    // x^2 + y^2 = r^2 = cosh(height)^2 = cosh(z)^2 (since z = height
    // exactly, whatever REVOLUTION_HEIGHT_SCALE is set to) - the
    // defining equation of a catenoid.
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 12, 0, 0, 20, 20);

    float minDistFromAxis = Float.MAX_VALUE;
    for (float[] v : app.allVertices) {
      float distSq = v[0] * v[0] + v[1] * v[1];
      float cosh = (float) ((Math.exp(v[2]) + Math.exp(-v[2])) / 2.0);
      assertEquals(cosh * cosh, distSq, 0.001f, "every vertex must satisfy x^2 + y^2 = cosh(z)^2");
      minDistFromAxis = Math.min(minDistFromAxis, (float) Math.sqrt(distSq));
    }
    // The waist (z=0, the narrowest ring) should actually appear in this
    // grid - same reasoning as n==10 Hyperboloid of Revolution's own
    // ring-thickness test above.
    assertEquals(1f, minDistFromAxis, 0.01f, "the waist's own radius should be exactly 1, and the grid should include it");
  }

  @Test
  void n13_conoid_buildsAGrid_firstCornerAtTheSouthRailsLeftEnd () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 13, 0, 0, 20, 20);

    assertSubstantialQuadGrid();
    // start_u = start_v = -1 (n==13 isn't in the "start_u = 0" list).
    // v=-1 -> t=0 -> the point sits exactly on the straight, flat-on-the-
    // ground rail: (x, y, z) = (lineX, lineY, 0) = (-1, -1, 0).
    assertArrayEquals(new float[]{-1, -1, 0}, app.allVertices[0], 0.01f);
  }

  @Test
  void n13_conoid_theSouthEdgeIsAFlatLine_andTheNorthEdgeIsAVerticalHalfCircle () {
    // y = lineY + t*(archY-lineY) = -1 + t*2 exactly (lineY=-1, archY=1,
    // both constants independent of u), so t is recoverable from y alone
    // (t = (y+1)/2) without needing the original u/v - t=0 (y=-1) is the
    // flat south rail, t=1 (y=1) is the vertical north half-circle.
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 13, 0, 0, 20, 20);

    boolean foundSouthEdgePoint = false;
    boolean foundNorthEdgePoint = false;
    for (float[] v : app.allVertices) {
      float t = (v[1] + 1) / 2;
      if (t < 0.01f) { // south rail (v==-1): flat on the ground, z=0 regardless of x
        assertEquals(0f, v[2], 0.01f, "the south edge must be flat on the ground, z=0");
        foundSouthEdgePoint = true;
      } else if (t > 0.99f) { // north arc (v==+1): a VERTICAL half-circle, x^2+z^2=1, z on the upward (>=0) side only
        float distSq = v[0] * v[0] + v[2] * v[2];
        assertEquals(1f, distSq, 0.01f, "the north edge must be a vertical unit half-circle, x^2+z^2=1");
        assertTrue(v[2] >= -0.01f, "the north edge's half-circle must stay on the upward (z>=0) side, found z=" + v[2]);
        foundNorthEdgePoint = true;
      }
    }
    assertTrue(foundSouthEdgePoint, "setup check - this grid should sample the south rail (v=-1)");
    assertTrue(foundNorthEdgePoint, "setup check - this grid should sample the north arc (v=+1)");
  }

  @Test
  void n13_conoid_theNorthArchTouchesTheGround_onlyAtItsOwnTwoEndpoints () {
    // The vertical arch's own apex (u=0, angle=PI/2) reaches z=1 at its
    // north edge (v=1) - the midpoint of the arch, well away from the
    // ground, distinguishing this from a flat-footprint arc (which would
    // keep z=0 everywhere along that same edge).
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 13, 0, 0, 20, 20);

    float maxZAtNorthEdge = 0;
    for (float[] v : app.allVertices) {
      float t = (v[1] + 1) / 2;
      if (t > 0.99f) maxZAtNorthEdge = Math.max(maxZAtNorthEdge, v[2]);
    }
    assertEquals(1f, maxZAtNorthEdge, 0.01f, "the vertical arch's own apex should reach exactly z=1");
  }

  @Test
  void n14_tractricoid_buildsAGrid_firstCornerAtTheRim () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 14, 0, 0, 20, 20);

    assertSubstantialQuadGrid();
    // start_u/start_v are both left at their ordinary -1 default (n==14
    // is NOT in the "start_u = 0" list - u is a full-circle angle here,
    // same as n==10/12/13, not a radius) - so the very first corner is
    // u=-1, v=-1: theta = -PI, t = (v+1)/2*TRACTRICOID_T_MAX = 0 (the
    // rim itself), so r = sech(0) = 1, z = 0 - t - tanh(t) = 0 at t=0.
    // x = r*cos(-PI) = -1, y = r*sin(-PI) = 0.
    assertArrayEquals(new float[]{-1, 0, 0}, app.allVertices[0], 0.01f);
  }

  @Test
  void n14_tractricoid_everyVertexSatisfiesTheTractrixEquation_andStaysAtOrAboveZero () {
    // The classic tractrix equation, re-derived independently from r
    // alone (not from t or v): z = ln((1 + sqrt(1-r^2)) / r) - sqrt(1-
    // r^2), where r = sqrt(x^2+y^2). This is the standard closed-form
    // height-as-a-function-of-radius formula for the pseudosphere,
    // distinct from the function's own forward t-based computation, so
    // matching it confirms the shape independently rather than just
    // replaying the same steps.
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 14, 0, 0, 20, 20);

    boolean foundNonRimPoint = false;
    for (float[] v : app.allVertices) {
      double r = Math.sqrt(v[0] * v[0] + v[1] * v[1]);
      double oneMinusRSq = Math.max(0, 1 - r * r);
      double expectedZ = Math.log((1 + Math.sqrt(oneMinusRSq)) / r) - Math.sqrt(oneMinusRSq);
      assertEquals(expectedZ, v[2], 0.001, "every vertex must satisfy the tractrix equation z = ln((1+sqrt(1-r^2))/r) - sqrt(1-r^2)");
      assertTrue(v[2] >= -0.0001f, "every vertex must stay at or above z=0, found z=" + v[2]);
      if (r < 0.99) foundNonRimPoint = true;
    }
    assertTrue(foundNonRimPoint, "setup check - this grid should contain at least one point away from the rim");
  }

  @Test
  void n15_monkeySaddle_buildsAGrid_firstCornerMatchesTheFormula () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 15, 0, 0, 20, 20);

    assertSubstantialQuadGrid();
    // start_u/start_v are both left at their ordinary -1 default (n==15
    // is NOT in the "start_u = 0" list - same flat square x=u/y=v
    // footprint as n==3 Saddle Surface) - so the very first corner is
    // u=-1, v=-1: x=-1, y=-1, z = u^3 - 3uv^2 = -1 - 3*(-1)*1 = 2.
    assertArrayEquals(new float[]{-1, -1, 2}, app.allVertices[0], 0.01f);
  }

  @Test
  void n15_monkeySaddle_everyVertexSatisfiesZEqualsXCubedMinusThreeXYSquared () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 15, 0, 0, 20, 20);

    boolean foundOffAxisPoint = false;
    for (float[] v : app.allVertices) {
      float x = v[0];
      float y = v[1];
      assertEquals(x * x * x - 3 * x * y * y, v[2], 0.0001f, "every vertex must satisfy z = x^3 - 3*x*y^2");
      if (x != 0 && y != 0) foundOffAxisPoint = true;
    }
    assertTrue(foundOffAxisPoint, "setup check - this grid should contain at least one point off both axes");
  }

  @Test
  void n16_scherksSurface_buildsAGrid_firstCornerIsAtTheOriginOfTheSaddle () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 16, 0, 0, 20, 20);

    assertSubstantialQuadGrid();
    // start_u/start_v are both left at their ordinary -1 default (n==16
    // is NOT in the "start_u = 0" list - same flat square x=u/y=v
    // footprint as n==3/15) - so the very first corner is u=-1, v=-1:
    // angleX = angleY = -SCHERK_DOMAIN_HALF_WIDTH, and since cos() is an
    // even function, cos(angleY)/cos(angleX) = 1, so z = ln(1) = 0.
    assertArrayEquals(new float[]{-1, -1, 0}, app.allVertices[0], 0.01f);
  }

  @Test
  void n16_scherksSurface_everyVertexSatisfiesZEqualsLogOfCosRatio_andFlaresNearTheEdges () {
    // The classic Scherk's-surface equation, re-derived independently
    // from x and y alone (not from u/v or the function's own
    // SCHERK_DOMAIN_HALF_WIDTH constant - that same 0.45*PI value is
    // simply inlined here, since x==u and y==v exactly for this preset):
    // z = ln(cos(y * 0.45*PI) / cos(x * 0.45*PI)).
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 16, 0, 0, 20, 20);

    double domainHalfWidth = 0.45 * Math.PI;
    boolean foundSteepFlarePoint = false;
    for (float[] v : app.allVertices) {
      double x = v[0];
      double y = v[1];
      double expectedZ = Math.log(Math.cos(y * domainHalfWidth) / Math.cos(x * domainHalfWidth));
      assertEquals(expectedZ, v[2], 0.001, "every vertex must satisfy z = ln(cos(y*0.45*PI) / cos(x*0.45*PI))");
      if (Math.abs(v[2]) > 1) foundSteepFlarePoint = true;
    }
    assertTrue(foundSteepFlarePoint, "setup check - this grid should reach at least one steeply-flared point (|z| > 1) near its own edges");
  }

  @Test
  void n17_dinisSurface_buildsAGrid_firstCornerIsAtTheRim_twistedByTheta () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 17, 0, 0, 20, 20);

    assertSubstantialQuadGrid();
    // Same first corner as n==14 Tractricoid (u=-1, v=-1 -> theta=-PI,
    // t=0, r=1, x=-1, y=0, untwisted height=0), plus the twist term:
    // z = 0 + DINI_TWIST_PITCH * (-PI) = -0.2*PI =~ -0.6283.
    assertArrayEquals(new float[]{-1, 0, -0.6283f}, app.allVertices[0], 0.01f);
  }

  @Test
  void n17_dinisSurface_everyVertexSatisfiesTheTwistedTractrixEquation () {
    // Same independent re-derivation as n==14 Tractricoid's own test (z =
    // ln((1+sqrt(1-r^2))/r) - sqrt(1-r^2), using r = sqrt(x^2+y^2) alone),
    // plus the twist term added back in using theta = atan2(y, x) - also
    // independent of the function's own forward u-based theta, and safe
    // from wraparound ambiguity here since theta = u*PI never reaches all
    // the way to +-PI (u's own loop is exclusive of its end) and atan2's
    // own principal range is (-PI, PI].
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 17, 0, 0, 20, 20);

    double DINI_TWIST_PITCH = 0.2;
    double twoPiPitch = DINI_TWIST_PITCH * 2 * Math.PI;
    boolean foundTwistedPoint = false;
    for (float[] v : app.allVertices) {
      double x = v[0];
      double y = v[1];
      double r = Math.sqrt(x * x + y * y);
      double theta = Math.atan2(y, x);
      double oneMinusRSq = Math.max(0, 1 - r * r);
      double expectedUntwistedZ = Math.log((1 + Math.sqrt(oneMinusRSq)) / r) - Math.sqrt(oneMinusRSq);
      double expectedZ = expectedUntwistedZ + DINI_TWIST_PITCH * theta;
      // atan2's own branch cut sits exactly at theta=+-PI, which is also
      // this surface's own documented seam (see the n==17 formula's own
      // comment) - right at that single boundary, a sign-of-zero
      // difference in sin(-PI) can flip atan2's recovered theta by a
      // full 2*PI, which (after DINI_TWIST_PITCH) shows up here as a
      // twoPiPitch-sized jump; resolve it by picking whichever candidate
      // (as-is, or shifted by one twoPiPitch either way) actually lands
      // closest to the real z, rather than failing on an ambiguity this
      // test's own atan2-based reconstruction can't otherwise resolve.
      double diff = expectedZ - v[2];
      if (Math.abs(diff - twoPiPitch) < Math.abs(diff)) diff -= twoPiPitch;
      if (Math.abs(diff + twoPiPitch) < Math.abs(diff)) diff += twoPiPitch;
      assertEquals(0, diff, 0.001, "every vertex must satisfy the twisted tractrix equation");
      if (Math.abs(theta) > 0.5) foundTwistedPoint = true;
    }
    assertTrue(foundTwistedPoint, "setup check - this grid should contain at least one point where the twist term clearly matters");
  }

  @Test
  void n18_seashell_buildsAGrid_firstCornerAtTheInnermostCoil () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 18, 0, 0, 20, 20);

    assertSubstantialQuadGrid();
    // start_u/start_v are both left at their ordinary -1 default (n==18
    // is NOT in the "start_u = 0" list) - so the very first corner is
    // u=-1, v=-1: growthFraction=0, R=pow(4,0)=1, tubeRadius=0.3,
    // centerZ=0, spiralAngle=-1*2.5*PI=-2.5*PI (which, being a quarter-
    // turn past a half-turn, lands exactly on the y-axis: cos=0, sin=-1)
    // - ringR = 1 + 0.3*cos(-PI) = 1 - 0.3 = 0.7, so x = 0.7*0 = 0, y =
    // 0.7*(-1) = -0.7, z = 0 + 0.3*sin(-PI) = 0.
    assertArrayEquals(new float[]{0, -0.7f, 0}, app.allVertices[0], 0.01f);
  }

  @Test
  void n18_seashell_spiralsOutwardAndUpward_fromInnerToOuterCoil () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 18, 0, 0, 20, 20);

    float minRingR = Float.MAX_VALUE;
    float maxRingR = -Float.MAX_VALUE;
    float minZ = Float.MAX_VALUE;
    float maxZ = -Float.MAX_VALUE;
    for (float[] v : app.allVertices) {
      float ringR = (float) Math.sqrt(v[0] * v[0] + v[1] * v[1]);
      minRingR = Math.min(minRingR, ringR);
      maxRingR = Math.max(maxRingR, ringR);
      minZ = Math.min(minZ, v[2]);
      maxZ = Math.max(maxZ, v[2]);
    }
    // Innermost coil (R=1, tubeRadius=0.3) keeps the ring within
    // 0.7..1.3 of the axis and its own tube within -0.3..0.3 of the
    // ground; the outermost coil (R=SEASHELL_GROWTH=4, tubeRadius=1.2)
    // swells out to roughly 2.8..5.2 from the axis and climbs to
    // roughly 3.3..5.7 up - so a substantial, clearly-spiraling shell
    // should reach noticeably past the innermost coil's own bounds in
    // both radius and height, while still keeping its own innermost
    // coil close to the ground.
    assertTrue(minRingR < 1.0f, "innermost coil should come within 1.0 of the axis, found min=" + minRingR);
    assertTrue(maxRingR > 4.0f, "outermost coil should swell out past 4.0 from the axis, found max=" + maxRingR);
    assertTrue(minZ > -0.5f && minZ < 0.1f, "the innermost coil's own tube should keep the lowest point near ground level, found min z=" + minZ);
    assertTrue(maxZ > 5.0f, "the outermost coil should climb well above the innermost coil, found max z=" + maxZ);
  }
}
