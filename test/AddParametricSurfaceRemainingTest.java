import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Create3D.add_ParametricSurface() (create3D.pde) only had n=1 covered
// (Create3DTest.java's own addParametricSurface_... test) of its 9
// surface types (n=0 Cushion, 1, 2, 3, 4, 5, 6 LOGO, 7 Torus, 8
// Hyperbolic Disc) - the remaining 8 are covered here, following that
// same existing test's own reasoning exactly (see its header comment):
// this function has no validity guard at all, and its exact face count
// depends on floating-point loop-increment behavior this suite doesn't
// try to replicate - so each test checks for a substantial, non-trivial
// amount of quad geometry, and the deterministic position of the very
// first grid corner (u = start_u, v = start_v = -1 always; start_u is 0
// for n == 0, 6, or 8, -1 otherwise - read directly from the function's
// own "if ((n == 0) || (n == 6) || (n == 8)) start_u = 0;" line),
// computed from each n's own x/y/z formula.
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
}
