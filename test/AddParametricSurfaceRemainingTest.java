import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Create3D.add_ParametricSurface() (create3D.pde) only had n=1 covered
// (Create3DTest.java's own addParametricSurface_... test) of its 7
// surface types (n=0 Cushion, 1, 2, 3, 4, 5, 6 LOGO) - the remaining 6
// are covered here, following that same existing test's own reasoning
// exactly (see its header comment): this function has no validity guard
// at all, and its exact face count depends on floating-point loop-
// increment behavior this suite doesn't try to replicate - so each test
// checks for a substantial, non-trivial amount of quad geometry, and the
// deterministic position of the very first grid corner (u = start_u,
// v = start_v = -1 always; start_u is 0 for n == 0 or 6, -1 otherwise -
// read directly from the function's own "if ((n == 0) || (n == 6))
// start_u = 0;" line), computed from each n's own x/y/z formula.
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
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0);

    assertSubstantialQuadGrid();
    // start_u = 0 (n == 0), start_v = -1 always.
    // x = cos(0*PI) = 1; y = sin(-PI) ~= 0; z = -sin(0*PI)*cos(-PI) = 0.
    assertArrayEquals(new float[]{1, 0, 0}, app.allVertices[0], 0.01f);
  }

  @Test
  void n2_buildsAGrid_firstCornerAtUMinusOneVMinusOne () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 2, 0);

    assertSubstantialQuadGrid();
    // x=u=-1; y=v=-1; z=0.5*sin(-PI)*sin(-PI) ~= 0.
    assertArrayEquals(new float[]{-1, -1, 0}, app.allVertices[0], 0.01f);
  }

  @Test
  void n3_buildsAGrid_firstCornerAtUMinusOneVMinusOne () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 3, 0);

    assertSubstantialQuadGrid();
    // x=u=-1; y=v=-1; z=u*v=1.
    assertArrayEquals(new float[]{-1, -1, 1}, app.allVertices[0], 0.01f);
  }

  @Test
  void n4_buildsAGrid_firstCornerAtUMinusOneVMinusOne () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 4, 0);

    assertSubstantialQuadGrid();
    // x=sin(-PI)~=0; y=sin(-PI)~=0; z=cos(-2*PI)=1.
    assertArrayEquals(new float[]{0, 0, 1}, app.allVertices[0], 0.01f);
  }

  @Test
  void n5_buildsAGrid_firstCornerAtUMinusOneVMinusOne () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 5, 0);

    assertSubstantialQuadGrid();
    // Same x0/y0/z0 as n=4 at this corner (~0,~0,1), already length 1,
    // so the normalization step here is a no-op.
    assertArrayEquals(new float[]{0, 0, 1}, app.allVertices[0], 0.01f);
  }

  @Test
  void n6_logo_buildsAGrid_firstCornerAtUZeroVMinusOne () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 6, 0);

    assertSubstantialQuadGrid();
    // Same x0/y0/z0 as n=0 at this corner (1,~0,0), already length 1,
    // so the normalization step here is a no-op too.
    assertArrayEquals(new float[]{1, 0, 0}, app.allVertices[0], 0.01f);
  }
}
