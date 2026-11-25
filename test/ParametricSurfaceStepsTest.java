import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers the generic u/v grid-resolution control added on top of
// create3D.pde's add_ParametricSurface() (n=0..7, Torus included): its
// former hardcoded step sizes (0.1 for n=1,2,3; 0.05 for n=0,4,5,6,7 -
// see that function's own former stp_u/stp_v comment) are gone, replaced
// by two explicit stepsU/stepsV parameters the caller now controls - and
// User3D.creatorParametricStepsU/V, the new shared fields that carry
// them from the Create menu's own Form panel through to there, same
// pipeline as creatorTorusRatio (see TorusTest.java's own XML round-trip
// tests for that field - these mirror them for the two fields here).
// Deliberately NOT torus-specific: n=1 (Dome) is used below precisely
// because it's one of the "every other n" shapes, to confirm the
// resolution control isn't somehow tied to Torus alone.
class ParametricSurfaceStepsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // --- add_ParametricSurface actually honors stepsU/stepsV ---------------

  @Test
  void stepsUAndStepsV_controlTheExactFaceCount_forAWideDomainShape () {
    // n=1 (Dome): start_u = start_v = -1, both the full -1..1 (width 2)
    // domain - so stepsU * stepsV quads should result, exactly. Counts
    // chosen so each step size is an exact power-of-two fraction (2/8 =
    // 0.25, 2/4 = 0.5), avoiding the floating-point loop-increment drift
    // Create3DTest.java's own header comment warns add_ParametricSurface
    // is otherwise subject to (e.g. 1/6 isn't exactly representable).
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 8, 4);

    assertEquals(32, app.allFaces.nodes.length);
    for (int[] face : app.allFaces.nodes) assertEquals(4, face.length);
  }

  @Test
  void stepsUAndStepsV_controlTheExactFaceCount_forAHalfWidthUDomainShape () {
    // n=0 (Cushion): start_u = 0 (half-width u domain, width 1, -1..1
    // for v still, width 2) - stepsU divides whatever domain width u
    // actually has, so the resulting face count is still exactly
    // stepsU * stepsV regardless. Again power-of-two step sizes (1/8 =
    // 0.125, 2/4 = 0.5) to sidestep floating-point loop drift.
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 8, 4);

    assertEquals(32, app.allFaces.nodes.length);
  }

  @Test
  void stepsUAndStepsV_clampToAtLeastOne_soZeroOrNegativeNeverDividesByZero () {
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, -3);

    assertEquals(1, app.allFaces.nodes.length, "0 and -3 should both clamp up to 1 step, not crash or produce nothing");
  }

  // --- wiring: User3D fields, XML persistence -----------------------------

  @Test
  void creatorParametricStepsUAndV_roundTripThroughXML () {
    app.User3D.creatorParametricStepsU = 12;
    app.User3D.creatorParametricStepsV = 48;

    processing.data.XML root = new processing.data.XML("root");
    app.User3D.to_XML(root);

    solarchvision_bim.User3D fresh = app.new User3D();
    fresh.from_XML(root);

    assertEquals(12, fresh.creatorParametricStepsU);
    assertEquals(48, fresh.creatorParametricStepsV);
  }

  @Test
  void creatorParametricStepsUAndV_fallBackToThirtySixForAnOlderSaveFileMissingTheFields () {
    // Same "bare child, no attributes" simulation of an older save file
    // as TorusTest.java's own creatorTorusRatio_fallsBackToPointThree...
    processing.data.XML root = new processing.data.XML("root");
    root.addChild(app.User3D.CLASS_STAMP);

    solarchvision_bim.User3D fresh = app.new User3D();
    fresh.from_XML(root);

    assertEquals(36, fresh.creatorParametricStepsU);
    assertEquals(36, fresh.creatorParametricStepsV);
  }
}
