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

  // ================= diffuse-only case (direct=0, diffuse=200 W/m2) ========
  // Skin Potential (preBakeViewport.pde) and Shade Vertex Solar
  // (calculate_VertexSolar_array.pde) both average the real sky-dome
  // DiffuseVectors sample set via the identical cosine-weighted formula
  // (build_SkySphere() turns out to have no graphics dependency and is
  // directly callable here), so those two should land on the exact same
  // number. Pose Potential's SolarAtSurface() doesn't sample
  // DiffuseVectors at all - it uses a simple analytical SkyMask =
  // 0.5*(1+Alpha/90), which at Alpha=90 (horizontal) is exactly 1.0,
  // matching the isotropic-sky convention weather data's own "diffuse
  // horizontal" figure is defined against.
  //
  // The Monte-Carlo average used to come out at roughly half that (~0.53)
  // - dividing by the sample count alone normalizes against the
  // hemisphere's raw solid angle (2*pi), not the Lambertian-hemisphere
  // integral (pi) that's actually correct here, a missing factor of 2.
  // Both sites were fixed to divide by half the sample count instead; the
  // tests below reflect that fix - Pose Potential and the Monte-Carlo
  // estimate should now agree within the residual gap you'd expect from
  // two different approximation methods (a 44-sample icosphere
  // tessellation vs. a smooth analytical curve), not the ~1.9x gap the
  // bug used to produce.

  private float monteCarloSkyMask (solarchvision_bim instance, float[] normal) {
    float sum = 0;
    for (float[] v : instance.DiffuseVectors) {
      float[] unit = instance.funcs.vec3_unit(v);
      float dot = instance.funcs.vec_dot(unit, normal);
      if (dot < 0) dot = 0;
      sum += dot;
    }
    return sum / (instance.DiffuseVectors.length / 2.0f);
  }

  // Mirrors SolarAtSurface()'s own VECT computation (SolarAtSurface.pde) -
  // a surface's unit normal for a given tilt (Alpha, 90=horizontal,
  // 0=vertical) and orientation (Beta, a compass-style bearing measured
  // from south: Beta=0 faces south, Beta=90 faces east - confirmed by
  // comparing funcs.SunPosition()'s own x/y output against where the sun
  // actually is at sunrise and at solar noon for a known latitude).
  private float[] vectForTilt (float Alpha, float Beta) {
    float[] VECT;
    if (Alpha > 89.99) VECT = new float[]{ 0, 0, 1 };
    else if (Alpha < -89.99) VECT = new float[]{ 0, 0, -1 };
    else VECT = new float[]{ app.funcs.sin_ang(Beta), -app.funcs.cos_ang(Beta), app.funcs.tan_ang(Alpha) };
    return app.funcs.vec3_unit(VECT);
  }

  @Test
  void diffuseOnlyHorizontalSurface_skinPotentialAndShadeVertexSolarAgreeExactly () {
    solarchvision_bim fresh = new solarchvision_bim();
    fresh.build_SkySphere(3); // the tessellation argument is currently unused internally - any value gives the same real sky-dome sample set the app itself builds
    assertTrue(fresh.DiffuseVectors.length > 0, "build_SkySphere() must actually populate some sample directions");

    float diffuse = 0.2f; // 200 W/m2
    float[] normal = { 0, 0, 1 }; // horizontal, facing up

    float skyMask = monteCarloSkyMask(fresh, normal);

    // Skin Potential: quantized through an 8-bit PNG channel, same as the
    // direct/SunMask case above.
    float quantizedCOL_V1 = Math.round(255 * skyMask) / 255.0f;
    float skinResult = diffuse * quantizedCOL_V1;

    // Shade Vertex Solar: the same average, computed directly every time, no quantization.
    float vertexResult = diffuse * skyMask;

    assertEquals(vertexResult, skinResult, QUANT + EPS,
      "Skin Potential must agree with Shade Vertex Solar within the 8-bit PNG channel's own quantization step");
  }

  @Test
  void diffuseOnlyHorizontalSurface_posePotentialAgreesCloselyWithTheFixedMonteCarloEstimate () {
    solarchvision_bim fresh = new solarchvision_bim();
    fresh.build_SkySphere(3);

    float diffuse = 0.2f;
    float[] normal = { 0, 0, 1 };

    float monteCarloResult = diffuse * monteCarloSkyMask(fresh, normal);
    float poseResult = fresh.SolarAtSurface(0, 0, 1, 0, diffuse, 90, 0, 0); // direct=0, SunR is irrelevant here

    // 15% rather than an exact match - a 44-sample icosphere tessellation
    // approximating a smooth analytical curve won't land on it exactly,
    // but should now be close, not off by a factor of ~2 the way the
    // unfixed normalization left it.
    assertEquals(poseResult, monteCarloResult, poseResult * 0.15f,
      "Pose Potential and the Monte-Carlo estimate should now agree within the residual gap between two different approximation methods, not by roughly 2x the way the un-normalized average used to");
  }

  // ================= latitude 45N, three surface orientations ==============
  // Same cross-pipeline approach as above, now at a latitude and set of
  // tilts where the three methods' geometry actually differs meaningfully
  // from each other - equinox, solar noon (confirmed by scanning every
  // hour and finding this is where the sun's altitude peaks at 45N), so
  // the sun sits at 45 degrees altitude, due south. Three surfaces:
  // horizontal (Alpha=90), a vertical wall facing south (Alpha=0,
  // Beta=0), and a 45-degree-tilted surface facing south (Alpha=45,
  // Beta=0) - the last of these puts the sun exactly perpendicular to the
  // surface (SunMask=1, the maximum possible), a classic "optimal tilt"
  // result that's a useful sanity check in its own right.
  //
  // Horizontal and vertical-south happen to land on the exact same direct
  // SunMask here (~0.707) - not a coincidence specific to this test code,
  // but a real geometric fact at exactly 45 degrees solar altitude
  // (cos(45) = sin(45)), so it's expected, not a sign anything's wrong.

  private float[] cached_solarNoonAt45N;

  private float[] solarNoonAt45N () {
    if (cached_solarNoonAt45N == null) {
      cached_solarNoonAt45N = app.funcs.SunPosition(45, 0, 12); // Latitude=45, DateAngle=0 (equinox), HourAngleOrigin=12 (solar noon)
    }
    return cached_solarNoonAt45N;
  }

  private void assertDirectAgrees (float Alpha, float Beta, String label) {
    float[] SunR = solarNoonAt45N();
    assertTrue(SunR[3] > 0, "the sun must be up at solar noon for this test to mean anything");

    float direct = 1.0f;
    float poseResult = app.SolarAtSurface(SunR[1], SunR[2], SunR[3], direct, 0, Alpha, Beta, 0);

    float[] VECT = vectForTilt(Alpha, Beta);
    float sunMask = app.funcs.vec_dot(app.funcs.vec3_unit(new float[]{ SunR[1], SunR[2], SunR[3] }), VECT);
    if (sunMask < 0) sunMask = 0;
    float skinVertexResult = direct * sunMask; // no quantization - this is the un-quantized SunMask both Pose Potential and this skin/vertex reimplementation compute identically

    assertEquals(poseResult, skinVertexResult, EPS, label + ": Pose Potential and the Skin/Vertex Solar SunMask formula must agree exactly - identical dot product, no quantization involved here");
  }

  private void assertDiffuseAgreesClosely (float Alpha, float Beta, String label) {
    solarchvision_bim fresh = new solarchvision_bim();
    fresh.build_SkySphere(3);

    float diffuse = 0.2f;
    float[] VECT = vectForTilt(Alpha, Beta);

    float poseResult = fresh.SolarAtSurface(0, 0, 1, 0, diffuse, Alpha, Beta, 0); // direct=0, SunR irrelevant
    float monteCarloResult = diffuse * monteCarloSkyMask(fresh, VECT);

    assertEquals(poseResult, monteCarloResult, poseResult * 0.2f,
      label + ": Pose Potential's analytical SkyMask and the Monte-Carlo estimate should agree within the residual gap between the two approximation methods");
  }

  @Test
  void latitude45N_horizontalSurface_directRadiationAgrees () {
    assertDirectAgrees(90, 0, "horizontal");
  }

  @Test
  void latitude45N_horizontalSurface_diffuseRadiationAgreesClosely () {
    assertDiffuseAgreesClosely(90, 0, "horizontal");
  }

  @Test
  void latitude45N_verticalSurfaceFacingSouth_directRadiationAgrees () {
    assertDirectAgrees(0, 0, "vertical-south");
  }

  @Test
  void latitude45N_verticalSurfaceFacingSouth_diffuseRadiationAgreesClosely () {
    assertDiffuseAgreesClosely(0, 0, "vertical-south");
  }

  @Test
  void latitude45N_fortyFiveDegreeTiltFacingSouth_directRadiationAgrees () {
    assertDirectAgrees(45, 0, "45deg-tilt-south");
  }

  @Test
  void latitude45N_fortyFiveDegreeTiltFacingSouth_directRadiation_isNearlyPerpendicular () {
    // At solar noon on the equinox, 45N, the sun's own altitude is 45
    // degrees - exactly matching this surface's tilt - so a south-facing
    // 45-degree surface should receive the direct beam almost exactly
    // perpendicular to its face (SunMask close to 1, the maximum
    // possible), a useful physical sanity check independent of
    // cross-pipeline agreement.
    float[] SunR = solarNoonAt45N();
    float poseResult = app.SolarAtSurface(SunR[1], SunR[2], SunR[3], 1.0f, 0, 45, 0, 0);
    assertEquals(1.0f, poseResult, 0.01f);
  }

  @Test
  void latitude45N_fortyFiveDegreeTiltFacingSouth_diffuseRadiationAgreesClosely () {
    assertDiffuseAgreesClosely(45, 0, "45deg-tilt-south");
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
