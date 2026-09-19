import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

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
  void negativeAlphaBranchIsNowReachableAndUsesTheDownwardVector () {
    // Regression test for a fixed bug: the source used to read
    //   if (abs(Alpha) > 89.99) { VECT = (0,0,1); }
    //   else if (Alpha < -89.99) { VECT = (0,0,-1); }
    // Since Alpha < -89.99 always implied abs(Alpha) > 89.99, the second
    // branch could never execute for any value of Alpha - even at
    // Alpha=-90 the surface's reference vector was always (0,0,1). The
    // first condition is now Alpha > 89.99 (not abs(Alpha) > 89.99), so
    // each extreme tilt gets its own vector.
    //
    // At Alpha=-90 with a sun vector aligned to the now-correct (0,0,-1):
    // SunMask=1, SkyMask=0 (0.5*(1+(-90/90))), so the result is driven
    // entirely by the direct term.
    float aligned = app.SOLARCHVISION_SolarAtSurface(0, 0, -1, 800, 100, -90, 0, 0);
    assertEquals(800f, aligned, EPS); // 800*1 + 100*0

    // And a sun pointing the opposite way (up) is now correctly treated
    // as a backing face for a downward-facing surface, clamping SunMask
    // to 0 - before the fix this combination was indistinguishable from
    // the aligned case above (both used VECT=(0,0,1)).
    float opposite = app.SOLARCHVISION_SolarAtSurface(0, 0, 1, 800, 100, -90, 0, 0);
    assertEquals(0f, opposite, EPS); // 800*0 + 100*0
  }

  @Test
  void positiveAlphaBranchIsUnaffectedByTheFix () {
    // Alpha=90 behaves exactly as before: Alpha > 89.99 is still true
    // for positive Alpha, so this branch's condition change (from
    // abs(Alpha) > 89.99) doesn't alter this case at all.
    float result = app.SOLARCHVISION_SolarAtSurface(0, 0, 1, 800, 100, 90, 0, 0);
    assertEquals(900f, result, EPS); // 800*1 + 100*1
  }
}
