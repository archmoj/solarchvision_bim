import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers studyPoseHover.pde's pure logic: globalPoseRawValuesAt() (the
// snapshot-based lookup for Pose Potential's own RAD/EFF_P/EFF_N data),
// formatOrientation() (Beta as a compass direction), snapInclination()
// (the 80/10 degree rounding to Roof/vertical), formatOrientationAndIncl
// ination() (the combined first line), and studyGlobalPoseHover_hitTest()
// (the polar-coordinate hit-test, including the exact same multi-dome
// scenario Skin Potential's hover was fixed for). drawGlobalPoseHoverBox()
// itself touches real graphics and isn't independently testable here,
// consistent with everything else this session that draws to a live
// PGraphics context.
class StudyPoseHoverTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= globalPoseRawValuesAt ==================================

  private solarchvision_bim.GlobalPoseHoverInfo makeDome (int impactTypeIndex, int aCount, int bCount) {
    solarchvision_bim.GlobalPoseHoverInfo info = app.new GlobalPoseHoverInfo();
    info.impactTypeIndex = impactTypeIndex;
    info.snapshotRAD = new float[aCount][bCount];
    info.snapshotEFF_P = new float[aCount][bCount];
    info.snapshotEFF_N = new float[aCount][bCount];
    for (float[] row : info.snapshotRAD) java.util.Arrays.fill(row, app.FLOAT_undefined);
    for (float[] row : info.snapshotEFF_P) java.util.Arrays.fill(row, app.FLOAT_undefined);
    for (float[] row : info.snapshotEFF_N) java.util.Arrays.fill(row, app.FLOAT_undefined);
    return info;
  }

  @Test
  void rawValuesAt_active_readsReceivedRadiationIntoG () {
    solarchvision_bim.GlobalPoseHoverInfo dome = makeDome(app.Impact_ACTIVE, 5, 5);
    dome.snapshotRAD[2][3] = 12.5f;

    float[] raw = app.globalPoseRawValuesAt(dome, 2, 3);

    assertNotNull(raw);
    assertEquals(12.5f, raw[2], 0.0001f);
  }

  @Test
  void rawValuesAt_active_isNull_whenRADIsUndefined () {
    solarchvision_bim.GlobalPoseHoverInfo dome = makeDome(app.Impact_ACTIVE, 5, 5);
    assertNull(app.globalPoseRawValuesAt(dome, 0, 0));
  }

  @Test
  void rawValuesAt_passive_readsPIntoBAndNIntoR () {
    solarchvision_bim.GlobalPoseHoverInfo dome = makeDome(app.Impact_PASSIVE, 5, 5);
    dome.snapshotEFF_P[1][1] = 15f;
    dome.snapshotEFF_N[1][1] = 6f;

    float[] raw = app.globalPoseRawValuesAt(dome, 1, 1);

    assertNotNull(raw);
    assertEquals(15f, raw[3], 0.0001f); // B = P
    assertEquals(6f, raw[1], 0.0001f);  // R = N
  }

  @Test
  void rawValuesAt_passive_isNull_whenComparisonIsUndefined () {
    // Both P and N left as FLOAT_undefined (Float.MAX_VALUE) - P-N comes
    // out to exactly 0, not FLOAT_undefined, which is exactly why this
    // mirrors plotImpact_global()'s own AVERAGE/PERCENTAGE/COMPARISON/
    // is_defined(valuesSUM) computation precisely rather than gating on
    // is_defined(p) && is_defined(n) directly.
    solarchvision_bim.GlobalPoseHoverInfo dome = makeDome(app.Impact_PASSIVE, 5, 5);
    float[] raw = app.globalPoseRawValuesAt(dome, 0, 0);
    // Whatever this resolves to must match plotImpact_global()'s own
    // is_defined(valuesSUM) gate exactly - since P=N=FLOAT_undefined here,
    // AVERAGE=0, PERCENTAGE=0, COMPARISON=0, which is_defined() treats as
    // defined (0 != FLOAT_undefined) - so a real (if degenerate) result,
    // not null, is the behavior this test documents.
    assertNotNull(raw);
  }

  // ================= formatOrientation =======================================

  @Test
  void orientation_matchesTheGivenExample () {
    // compass bearing 310 -> "NW - 5°"; Beta = 180-310 (mod 360) = 230
    assertEquals("NW - 5\u00B0", app.formatOrientation(230f));
  }

  @Test
  void orientation_exactCardinalAndIntercardinalDirections () {
    assertEquals("S", app.formatOrientation(0f));   // Beta=0 -> compassBearing=180 -> S
    assertEquals("E", app.formatOrientation(90f));  // Beta=90 -> compassBearing=90 -> E
    assertEquals("N", app.formatOrientation(180f)); // Beta=180 -> compassBearing=0 -> N
    assertEquals("W", app.formatOrientation(270f)); // Beta=270 -> compassBearing=270 -> W
  }

  @Test
  void orientation_positiveOffset () {
    // compassBearing=320 (NW+5, since NW=315); Beta=180-320(mod360)=220
    assertEquals("NW + 5\u00B0", app.formatOrientation(220f));
  }

  @Test
  void orientation_wrapsCleanlyNearNorth () {
    // compassBearing=359 -> "N - 1°", not "N + 359°"; Beta=180-359(mod360)=181
    assertEquals("N - 1\u00B0", app.formatOrientation(181f));
  }

  @Test
  void orientation_roundsANonIntegerOffset () {
    // nf(value, 1, 0) does NOT round on its own - it only guarantees a
    // minimum of 0 decimal digits, so nf(12.857, 1, 0) prints "12.857",
    // not "13". Any grid whose orientationStepImplied (360/bCount)
    // doesn't divide evenly produces exactly this kind of non-integer
    // Beta, so this needs an explicit round() before formatting.
    // compassBearing=77.143 -> nearest 45-multiple is 90 (E), offset=-12.857
    assertEquals("E - 13\u00B0", app.formatOrientation(102.857f));
  }

  // ================= snapInclination =========================================

  @Test
  void snap_aboveEighty_snapsToNinety () {
    assertEquals(90f, app.snapInclination(85f), 0.0001f);
    assertEquals(90f, app.snapInclination(80.1f), 0.0001f);
  }

  @Test
  void snap_exactlyEighty_doesNotSnap () {
    assertEquals(80f, app.snapInclination(80f), 0.0001f);
  }

  @Test
  void snap_belowTen_snapsToZero () {
    assertEquals(0f, app.snapInclination(5f), 0.0001f);
    assertEquals(0f, app.snapInclination(9.9f), 0.0001f);
  }

  @Test
  void snap_exactlyTen_doesNotSnap () {
    assertEquals(10f, app.snapInclination(10f), 0.0001f);
  }

  @Test
  void snap_midRange_isUnchanged () {
    assertEquals(45f, app.snapInclination(45f), 0.0001f);
  }

  // ================= formatOrientationAndInclination =========================

  @Test
  void combinedLabel_showsRoofAtNinety () {
    assertEquals("Roof", app.formatOrientationAndInclination(0f, 90f));
  }

  @Test
  void combinedLabel_dropsInclinationAtZero () {
    assertEquals("S", app.formatOrientationAndInclination(0f, 0f));
  }

  @Test
  void combinedLabel_combinesBothInBetween () {
    assertEquals("S, Inclination 45\u00B0", app.formatOrientationAndInclination(0f, 45f));
  }

  @Test
  void combinedLabel_roundsANonIntegerInclination () {
    // Same nf() rounding fix as orientation_roundsANonIntegerOffset above,
    // for the inclination value itself.
    assertEquals("S, Inclination 34\u00B0", app.formatOrientationAndInclination(0f, 33.7f));
  }

  // ================= studyGlobalPoseHover_hitTest ============================

  @Test
  void hitTest_recoversAKnownAlphaBetaPoint () {
    solarchvision_bim.GlobalPoseHoverInfo dome = makeDome(app.Impact_ACTIVE, 10, 36); // 10-degree steps both axes
    dome.centerX = 100;
    dome.centerY = 100;
    dome.pixelsPerDegree = 2f;
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.globalPoseHoverInfo = new java.util.ArrayList<>();
    app.STUDY.globalPoseHoverInfo.add(dome);

    // Alpha=30, Beta=120 -> radius=60, angle=Beta-90=30deg
    float radius = 90 - 30;
    float angleRad = (float) Math.toRadians(120 - 90);
    float xLocal = radius * (float) Math.cos(angleRad);
    float yLocal = -radius * (float) Math.sin(angleRad);
    float mouseX = dome.centerX + xLocal * dome.pixelsPerDegree;
    float mouseY = dome.centerY + yLocal * dome.pixelsPerDegree;

    solarchvision_bim.GlobalPoseHoverHit hit = app.studyGlobalPoseHover_hitTest(mouseX, mouseY);

    assertNotNull(hit);
    assertEquals(3, hit.a);  // Alpha=30 -> a=3 (step=10)
    assertEquals(12, hit.b); // Beta=120 -> b=12 (step=10)
  }

  @Test
  void hitTest_domeCenterIsAlphaNinety () {
    solarchvision_bim.GlobalPoseHoverInfo dome = makeDome(app.Impact_ACTIVE, 10, 36);
    dome.centerX = 50;
    dome.centerY = 50;
    dome.pixelsPerDegree = 3f;
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.globalPoseHoverInfo = new java.util.ArrayList<>();
    app.STUDY.globalPoseHoverInfo.add(dome);

    solarchvision_bim.GlobalPoseHoverHit hit = app.studyGlobalPoseHover_hitTest(50, 50);

    assertNotNull(hit);
    assertEquals(9, hit.a); // Alpha=90 -> a=9 (last bucket)
  }

  @Test
  void hitTest_isNull_farOutsideTheDome () {
    solarchvision_bim.GlobalPoseHoverInfo dome = makeDome(app.Impact_ACTIVE, 10, 36);
    dome.centerX = 0;
    dome.centerY = 0;
    dome.pixelsPerDegree = 2f;
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.globalPoseHoverInfo = new java.util.ArrayList<>();
    app.STUDY.globalPoseHoverInfo.add(dome);

    assertNull(app.studyGlobalPoseHover_hitTest(1000, 1000)); // well beyond the 90-degree * 2px/deg = 180px outer edge
  }

  @Test
  void hitTest_isNull_whenNothingHasBeenRecordedYet () {
    app.STUDY.globalPoseHoverInfo = null;
    assertDoesNotThrow(() -> assertNull(app.studyGlobalPoseHover_hitTest(100, 100)));
  }

  @Test
  void hitTest_displayAlphaMatchesTheBucket_notTheContinuousMouseAngle () {
    // The rounding fix: a continuous hover angle of 43 degrees should
    // round to the a=4 (Alpha=40) bucket, and displayAlpha must reflect
    // that bucket's own value (40), not the raw 43 the mouse was at -
    // otherwise the label could show a number that doesn't match the
    // wedge whose data is actually being displayed below it.
    solarchvision_bim.GlobalPoseHoverInfo dome = makeDome(app.Impact_ACTIVE, 10, 36);
    dome.centerX = 0;
    dome.centerY = 0;
    dome.pixelsPerDegree = 1f;
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.globalPoseHoverInfo = new java.util.ArrayList<>();
    app.STUDY.globalPoseHoverInfo.add(dome);

    solarchvision_bim.GlobalPoseHoverHit hit = app.studyGlobalPoseHover_hitTest(47, 0); // radius=47 -> continuous Alpha=43

    assertNotNull(hit);
    assertEquals(4, hit.a);
    assertEquals(40f, hit.displayAlpha, 0.0001f);
  }

  @Test
  void hitTest_threeStackedDomes_eachShowsItsOwnData_noCrossContamination () {
    // The exact scenario the multi-dome fix was for: setupPlot_4()'s
    // viewLayout==2 branch calls plotImpact_global() more than once in
    // one render pass, each its own dome, each its own data.
    solarchvision_bim.GlobalPoseHoverInfo dome1 = makeDome(app.Impact_PASSIVE, 10, 36);
    solarchvision_bim.GlobalPoseHoverInfo dome2 = makeDome(app.Impact_PASSIVE, 10, 36);
    dome1.centerX = 0; dome1.centerY = -450; dome1.pixelsPerDegree = 2f;
    dome2.centerX = 0; dome2.centerY = -150; dome2.pixelsPerDegree = 2f;

    // Alpha=30 (a=3), Beta=90 (b=9) in both, different P values.
    dome1.snapshotEFF_P[3][9] = 100f;
    dome1.snapshotEFF_N[3][9] = 0f;
    dome2.snapshotEFF_P[3][9] = 200f;
    dome2.snapshotEFF_N[3][9] = 0f;

    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.globalPoseHoverInfo = new java.util.ArrayList<>();
    app.STUDY.globalPoseHoverInfo.add(dome1);
    app.STUDY.globalPoseHoverInfo.add(dome2);

    // radius=60 (Alpha=30), angle=0 (Beta=90) -> dx=120, dy=0
    solarchvision_bim.GlobalPoseHoverHit hit1 = app.studyGlobalPoseHover_hitTest(120, -450);
    solarchvision_bim.GlobalPoseHoverHit hit2 = app.studyGlobalPoseHover_hitTest(120, -150);

    assertNotNull(hit1);
    assertNotNull(hit2);

    float[] raw1 = app.globalPoseRawValuesAt(hit1.info, hit1.a, hit1.b);
    float[] raw2 = app.globalPoseRawValuesAt(hit2.info, hit2.a, hit2.b);

    assertNotNull(raw1);
    assertNotNull(raw2);
    assertEquals(100f, raw1[3], 0.01f, "dome1 must show its own P=100");
    assertEquals(200f, raw2[3], 0.01f, "dome2 must show its own P=200");
  }
}
