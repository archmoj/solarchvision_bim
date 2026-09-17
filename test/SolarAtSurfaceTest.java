import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

// Exercises SOLARCHVISION_SolarAtSurface (SolarAtSurface.pde) - a pure
// function combining a direct-sun mask (dot product against the
// surface's reference vector) with a sky-view mask, given a surface
// orientation (Alpha/Beta) and pre-computed sun radiation components.
//
// Like isIntersected_Faces.pde, this tab has no `class solarchvision_X`
// wrapper, so the function is a plain package-private method directly on
// `app` (`app.SOLARCHVISION_SolarAtSurface(...)`).
class SolarAtSurfaceTest {

  private static solarchvision_bim app;
  private static final float EPS = 0.01f;

  @BeforeAll
  static void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void returnsUndefinedIfAnyInputComponentIsUndefined () {
    float result = app.SOLARCHVISION_SolarAtSurface(
      app.FLOAT_undefined, 0, 1, 800, 100, 90, 0, 0);
    assertEquals(app.FLOAT_undefined, result, EPS);
  }

  @Test
  void sunAlignedWithAnUpwardSurfaceGivesFullDirectPlusFullSky () {
    // Alpha=90 takes the abs(Alpha)>89.99 branch: VECT=(0,0,1). A sun
    // vector pointing the same way gives SunMask=1, and SkyMask is 1 at
    // Alpha=90 (0.5*(1+90/90)).
    float result = app.SOLARCHVISION_SolarAtSurface(0, 0, 1, 800, 100, 90, 0, 0);
    assertEquals(900f, result, EPS); // 800*1 + 100*1
  }

  @Test
  void sunOppositeTheSurfaceIsClampedOutAsABackingFace () {
    // Same surface as above, but the sun is on the far side: SunMask
    // clamps to 0 rather than going negative, leaving only the sky term.
    float result = app.SOLARCHVISION_SolarAtSurface(0, 0, -1, 800, 100, 90, 0, 0);
    assertEquals(100f, result, EPS); // 800*0 + 100*1
  }

  @Test
  void skyMaskIsHalfAtAlphaZeroWithNoDirectContribution () {
    // Alpha=0, Beta=90 takes the "regular" branch: VECT = (sin(90),
    // -cos(90), tan(0)) = (1, 0, 0). A sun vector of (0, 0, 1) is
    // orthogonal to that, so SunMask is 0 and only SkyMask (0.5 at
    // Alpha=0) contributes.
    float result = app.SOLARCHVISION_SolarAtSurface(0, 0, 1, 999, 100, 0, 90, 0);
    assertEquals(50f, result, EPS); // 999*0 + 100*0.5
  }

  @Test
  void regularBranchMatchesTheTrigFormulaAtA45DegreeTilt () {
    // Alpha=45, Beta=0: VECT = (sin(0), -cos(0), tan(45)) = (0, -1, 1),
    // unit length (0, -0.7071, 0.7071). A sun vector along the same
    // direction gives SunMask=1; SkyMask at Alpha=45 is 0.75.
    float result = app.SOLARCHVISION_SolarAtSurface(0, -1, 1, 1000, 200, 45, 0, 0);
    assertEquals(1150f, result, EPS); // 1000*1 + 200*0.75
  }

  @Test
  void negativeAlphaBranchIsUnreachableDeadCode () {
    // Regression/documentation test: the source has
    //   if (abs(Alpha) > 89.99) { VECT = (0,0,1); }
    //   else if (Alpha < -89.99) { VECT = (0,0,-1); }
    // But Alpha < -89.99 implies abs(Alpha) > 89.99, so the first branch
    // always wins first - the second branch can never execute for any
    // value of Alpha. So even at Alpha=-90, the surface's reference
    // vector actually used is (0,0,1), NOT (0,0,-1) as the dead branch
    // would suggest. This test locks in that actual (likely unintended)
    // behavior; see the note flagged alongside this test suite.
    float result = app.SOLARCHVISION_SolarAtSurface(0, 0, -1, 800, 100, -90, 0, 0);
    // With VECT=(0,0,1) (not (0,0,-1)): SunMask = dot((0,0,-1),(0,0,1))
    // = -1 -> clamped to 0. SkyMask at Alpha=-90 is 0. Result: 0, not
    // the 800 you'd get if the dead branch's (0,0,-1) were actually used.
    assertEquals(0f, result, EPS);
  }
}
