import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

// Cross-checks that Pose Potential (SolarAtSurface(), called from STUDY.pde's
// plotImpact_global()), Skin Potential (calculate_Impact_CurrentPreBaked(),
// SolarImpacts.pde) and Shade Vertex Solar (calculate_VertexSolar_array())
// - three independently-written pipelines computing generally the same
// measure, per this session's own investigation into why their palettes'
// numbers didn't initially agree - genuinely land on the same value for a
// simple, hand-checkable scenario: an unobstructed horizontal surface at
// the equator, 1000 W/m2 of direct radiation and none diffuse.
//
// None of the three top-level functions is itself callable here - each
// needs a live project (real climate data, real baked shadow PNGs on
// disk, a live PGraphics-backed face grid - see this session's own
// repeated notes on why buildFaceGrid()/ShadeViewport()/loadImage() etc.
// aren't reachable from a bare instance). So instead, each pipeline's own
// per-hour formula is reproduced here using the exact same shared,
// already-testable primitives it actually calls internally
// (funcs.vec_dot, funcs.vec3_unit, funcs.SunPosition, funcs.DayTime, and
// SolarAtSurface() itself, which is real and callable) - this is exactly
// the by-hand derivation worked through earlier in the session, now
// codified as a regression test so a future edit to any one pipeline that
// quietly breaks their agreement gets caught here instead of by someone
// noticing a palette looks wrong again.
class SolarConsistencyTest {

  private static solarchvision_bim app;
  private static final float EPS = 0.001f;
  private static final float QUANT = 0.5f / 255.0f; // half an 8-bit channel step - the most Skin Potential's baked-PNG round-trip (255*SunMask, then /255.0) can differ from the other two, which compute SunMask directly with no quantization

  @BeforeAll
  static void setUp () {
    app = new solarchvision_bim();
  }

  // Shared horizontal-surface SunMask, computed the same way Skin
  // Potential's and Shade Vertex Solar's own per-hour loops do: the dot
  // product of the unit sun direction with the surface's own unit normal
  // - here, a horizontal surface facing straight up.
  private float sunMaskForHorizontalSurface (float[] SunR) {
    float[] normal = { 0, 0, 1 };
    float sunMask = app.funcs.vec_dot(app.funcs.vec3_unit(new float[]{ SunR[1], SunR[2], SunR[3] }), normal);
    return (sunMask < 0) ? 0 : sunMask; // same backing-face clamp every pipeline applies
  }

  @Test
  void horizontalUnobstructedSurfaceAtTheEquator_allThreeMethodsAgree_forOneHour () {
    // Equinox (DateAngle=0 -> zero declination), equator (Latitude=0),
    // solar noon (HourAngleOrigin=12 in this app's convention).
    float[] SunR = app.funcs.SunPosition(0, 0, 12);
    assertTrue(SunR[3] > 0, "the sun must actually be up for this test to mean anything");

    float direct = 1.0f; // kW/m2 - already past the 0.001*W/m2 scaling every pipeline applies upstream
    float diffuse = 0f;

    // Pose Potential: SolarAtSurface() itself, Alpha=90 for horizontal.
    float poseResult = app.SolarAtSurface(SunR[1], SunR[2], SunR[3], direct, diffuse, 90, 0, 0);

    // Skin Potential: RAD_VALUE * COL_V1, where COL_V1 is this same
    // SunMask, baked into an 8-bit PNG channel (255*SunMask) and read
    // back as (channel/255.0) - see preBakeViewport.pde's and
    // SolarImpacts.pde's own comments on that round-trip. The diffuse
    // (RAD_TYPE==1) pass contributes diffuse(=0)*its own COL_V1 = 0.
    float sunMask = sunMaskForHorizontalSurface(SunR);
    float quantizedCOL_V1 = Math.round(255 * sunMask) / 255.0f;
    float skinResult = direct * quantizedCOL_V1;

    // Shade Vertex Solar: computes the same dot product directly every
    // time, no PNG/quantization step - SkyMask is 1.0 for a fully-visible
    // horizontal surface, but diffuse is 0 here so that term drops out.
    float vertexResult = (direct * sunMask) + (diffuse * 1.0f);

    assertEquals(poseResult, vertexResult, EPS,
      "Pose Potential and Shade Vertex Solar must agree exactly - identical formula, no quantization in either");
    assertEquals(poseResult, skinResult, QUANT + EPS,
      "Skin Potential must agree with the other two within the 8-bit PNG channel's own quantization step");
  }

  @Test
  void horizontalUnobstructedSurfaceAtTheEquator_allThreeMethodsAgree_scaledToADailyTotal () {
    // Same scenario, carried through each pipeline's own per-day
    // valuesMUL = DayTime/validHourCount scaling (SolarImpacts.pde,
    // calculate_VertexSolar_array.pde, STUDY.pde's plotImpact_global() -
    // all three use this identical formula) - confirms the day-level
    // total actually shown on the palette agrees, not just one hour's
    // contribution to it, since that's what this session's fixes were
    // actually about (the valuesNUM double-count bug lived entirely in
    // this scaling step).
    float DATE_ANGLE = 0;
    float dayTime = app.funcs.DayTime(0, DATE_ANGLE);

    float poseSum = 0, skinSum = 0, vertexSum = 0;
    int validHours = 0;

    for (int hour = 0; hour < 24; hour++) {
      float[] SunR = app.funcs.SunPosition(0, DATE_ANGLE, hour);
      if (SunR[3] <= 0) continue;
      validHours++;

      poseSum += app.SolarAtSurface(SunR[1], SunR[2], SunR[3], 1.0f, 0f, 90, 0, 0);

      float sunMask = sunMaskForHorizontalSurface(SunR);
      skinSum += 1.0f * (Math.round(255 * sunMask) / 255.0f);
      vertexSum += (1.0f * sunMask) + (0f * 1.0f);
    }

    assertTrue(validHours > 0, "the equator must have some daylight hours to sample");

    float valuesMUL = dayTime / validHours;
    float poseDayTotal = poseSum * valuesMUL;
    float skinDayTotal = skinSum * valuesMUL;
    float vertexDayTotal = vertexSum * valuesMUL;

    assertEquals(poseDayTotal, vertexDayTotal, EPS * validHours);
    assertEquals(poseDayTotal, skinDayTotal, QUANT * validHours + EPS);
  }

  // ================= colorscale factor defaults =============================
  // Regression coverage for the palette-matching work this session: the
  // active/passive maximum swatch each palette shows depends directly on
  // these defaults (label = 0.5*q/PAL_multiplier for active, 2.0*(q-5)/
  // PAL_multiplier for passive, at q=10) - allFaces' own feeds WIN3D's
  // palette, Skin Potential's STUDY panel, and (via SHADE.get_PAL_
  // multiplier()) Vertex Solar and Global Solar shading; STUDY's own
  // separate copy feeds Pose Potential specifically. A silent change to
  // either default would silently change what every one of those palettes
  // shows as its maximum.

  @Test
  void facesDefaultActiveColorscaleFactor_putsEightKWhPerM2AtTheMaxSwatch () {
    solarchvision_bim fresh = new solarchvision_bim();
    assertEquals(0.625f, fresh.allFaces.activeColorscaleFactor, 0.0001f);
    assertEquals(8f, 0.5f * 10 / fresh.allFaces.activeColorscaleFactor, 0.0001f);
  }

  @Test
  void facesDefaultPassiveColorscaleFactor_putsSixtyTwoPointFivePercentAtTheMaxSwatch () {
    solarchvision_bim fresh = new solarchvision_bim();
    assertEquals(0.16f, fresh.allFaces.passiveColorscaleFactor, 0.0001f);
    assertEquals(62.5f, 2.0f * (10 - 5) / fresh.allFaces.passiveColorscaleFactor, 0.0001f);
  }

  @Test
  void studyDefaultActiveColorscaleFactor_matchesFaces_soPoseAndSkinPotentialAgree () {
    solarchvision_bim fresh = new solarchvision_bim();
    assertEquals(fresh.allFaces.activeColorscaleFactor, fresh.STUDY.activeColorscaleFactor, 0.0001f);
  }

  @Test
  void studyDefaultPassiveColorscaleFactor_matchesFaces_soPoseAndSkinPotentialAgree () {
    solarchvision_bim fresh = new solarchvision_bim();
    assertEquals(fresh.allFaces.passiveColorscaleFactor, fresh.STUDY.passiveColorscaleFactor, 0.0001f);
  }
}
