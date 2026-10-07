import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Same reasoning, and the same tests, as Sun3DTest.java - Moon3D.pde's
// computeFrame()/buildSubFace() share the exact same (forward, up, right)
// construction, just driven by funcs.MoonPosition() instead of
// funcs.SunPosition(). See Sun3DTest.java's own class comment for why
// these are directly callable with no reflection or WIN3D.graphics setup
// needed.
class Moon3DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.STATION.setLatitude(43.7f); // an arbitrary non-degenerate latitude -
                                    // avoids the lat=0 default, which isn't
                                    // wrong, just not representative.
  }

  // ================= computeFrame(): orthonormality ===========================

  private void assertOrthonormalFrame (solarchvision_bim.Moon3D.SkyFrame frame) {
    float Flen2 = frame.Fx*frame.Fx + frame.Fy*frame.Fy + frame.Fz*frame.Fz;
    float Ruplen2 = frame.Rupx*frame.Rupx + frame.Rupy*frame.Rupy + frame.Rupz*frame.Rupz;
    float Rrightlen2 = frame.Rrightx*frame.Rrightx + frame.Rrighty*frame.Rrighty + frame.Rrightz*frame.Rrightz;
    assertEquals(1f, Flen2, 0.001f, "F should be a unit vector");
    assertEquals(1f, Ruplen2, 0.001f, "Rup should be a unit vector");
    assertEquals(1f, Rrightlen2, 0.001f, "Rright should be a unit vector");

    float F_dot_Rup = frame.Fx*frame.Rupx + frame.Fy*frame.Rupy + frame.Fz*frame.Rupz;
    float F_dot_Rright = frame.Fx*frame.Rrightx + frame.Fy*frame.Rrighty + frame.Fz*frame.Rrightz;
    float Rup_dot_Rright = frame.Rupx*frame.Rrightx + frame.Rupy*frame.Rrighty + frame.Rupz*frame.Rrightz;
    assertEquals(0f, F_dot_Rup, 0.001f, "F and Rup should be perpendicular");
    assertEquals(0f, F_dot_Rright, 0.001f, "F and Rright should be perpendicular");
    assertEquals(0f, Rup_dot_Rright, 0.001f, "Rup and Rright should be perpendicular");
  }

  @Test
  void computeFrame_isOrthonormal_atVariousHoursAndDates () {
    for (int hour : new int[]{0, 6, 12, 18, 23}) {
      for (int dateAngle : new int[]{0, 90, 180, 270}) {
        app.SHADE_HOUR_ANGLE = hour;
        app.SHADE_DATE_ANGLE = dateAngle;
        assertOrthonormalFrame(app.Moon3D.computeFrame());
      }
    }
  }

  @Test
  void computeFrame_withDisplayTextureOff_skipsRupAndRrightButStillSetsF () {
    app.Moon3D.displayTexture = false;
    app.SHADE_HOUR_ANGLE = 12;
    app.SHADE_DATE_ANGLE = 0;

    solarchvision_bim.Moon3D.SkyFrame frame = app.Moon3D.computeFrame();

    float Flen2 = frame.Fx*frame.Fx + frame.Fy*frame.Fy + frame.Fz*frame.Fz;
    assertEquals(1f, Flen2, 0.001f);
    assertEquals(0f, frame.Rupx);
    assertEquals(0f, frame.Rupy);
    assertEquals(0f, frame.Rupz);
    assertEquals(0f, frame.Rrightx);
    assertEquals(0f, frame.Rrighty);
    assertEquals(0f, frame.Rrightz);
  }

  @Test
  void computeFrame_gridBasisIsOrthonormal_atVariousHoursAndDates () {
    // (Gright, Gup, S) - the Sun-aligned grid basis buildSubFace() now
    // builds its mesh from (see its own comment) - needs to be a genuine
    // orthonormal frame for exactly the same reason (F, Rup, Rright) does.
    for (int hour : new int[]{0, 6, 12, 18, 23}) {
      for (int dateAngle : new int[]{0, 90, 180, 270}) {
        app.SHADE_HOUR_ANGLE = hour;
        app.SHADE_DATE_ANGLE = dateAngle;
        solarchvision_bim.Moon3D.SkyFrame frame = app.Moon3D.computeFrame();

        float Slen2 = frame.Sx*frame.Sx + frame.Sy*frame.Sy + frame.Sz*frame.Sz;
        float Guplen2 = frame.Gupx*frame.Gupx + frame.Gupy*frame.Gupy + frame.Gupz*frame.Gupz;
        float Grightlen2 = frame.Grightx*frame.Grightx + frame.Grighty*frame.Grighty + frame.Grightz*frame.Grightz;
        assertEquals(1f, Slen2, 0.001f, "S should be a unit vector");
        assertEquals(1f, Guplen2, 0.001f, "Gup should be a unit vector");
        assertEquals(1f, Grightlen2, 0.001f, "Gright should be a unit vector");

        float S_dot_Gup = frame.Sx*frame.Gupx + frame.Sy*frame.Gupy + frame.Sz*frame.Gupz;
        float S_dot_Gright = frame.Sx*frame.Grightx + frame.Sy*frame.Grighty + frame.Sz*frame.Grightz;
        float Gup_dot_Gright = frame.Gupx*frame.Grightx + frame.Gupy*frame.Grighty + frame.Gupz*frame.Grightz;
        assertEquals(0f, S_dot_Gup, 0.001f, "S and Gup should be perpendicular");
        assertEquals(0f, S_dot_Gright, 0.001f, "S and Gright should be perpendicular");
        assertEquals(0f, Gup_dot_Gright, 0.001f, "Gup and Gright should be perpendicular");
      }
    }
  }

  @Test
  void computeFrame_withDisplayShadowOff_skipsTheGridBasisEntirely () {
    app.Moon3D.displayShadow = false;
    app.SHADE_HOUR_ANGLE = 12;
    app.SHADE_DATE_ANGLE = 0;

    solarchvision_bim.Moon3D.SkyFrame frame = app.Moon3D.computeFrame();

    // Not just "equals 0" by coincidence - S itself is never computed
    // either (see computeFrame()'s own guard), so Gright/Gup, built from
    // S, can't be either.
    assertEquals(0f, frame.Sx);
    assertEquals(0f, frame.Sy);
    assertEquals(0f, frame.Sz);
    assertEquals(0f, frame.Grightx);
    assertEquals(0f, frame.Gupx);
  }

  @Test
  void computeFrame_RupAndGupPointTowardTheNorthCelestialPole_notSouth () {
    // A real, confirmed bug: Rup/Gup used to be built from the SOUTH
    // celestial pole instead of the north one (the pole reference's own
    // sign was backwards, in buildRightUp() - see its own comment), which
    // put the real Moon's north pole visibly at the bottom of its own
    // texture. Checked here against an independently-derived north
    // direction - the difference between funcs.SunPosition() at a
    // genuinely high vs. low declination, not read from the app's own
    // pole variable - so this actually catches a regression rather than
    // re-asserting the same formula against itself (same technique as
    // Sun3DTest.java's equivalent test, which shares this exact
    // construction).
    app.SHADE_HOUR_ANGLE = 9; // deliberately not noon, so F and north
    app.SHADE_DATE_ANGLE = 30; // aren't forced near-perpendicular by symmetry.
    solarchvision_bim.Moon3D.SkyFrame frame = app.Moon3D.computeFrame();

    float stationLat = app.STATION.getLatitude();
    float[] northish = app.funcs.SunPosition(stationLat, 90, 12);
    float[] southish = app.funcs.SunPosition(stationLat, 270, 12);
    float nx = northish[1] - southish[1];
    float ny = northish[2] - southish[2];
    float nz = northish[3] - southish[3];
    float len = (float) Math.sqrt(nx*nx + ny*ny + nz*nz);
    nx /= len; ny /= len; nz /= len;

    float dotRupNorth = frame.Rupx*nx + frame.Rupy*ny + frame.Rupz*nz;
    assertTrue(dotRupNorth > 0.5f, "Rup should be strongly aligned with true north, dot=" + dotRupNorth);

    float dotGupNorth = frame.Gupx*nx + frame.Gupy*ny + frame.Gupz*nz;
    assertTrue(dotGupNorth > 0.5f, "Gup should be strongly aligned with true north, dot=" + dotGupNorth);
  }

  // ================= buildSubFace(): position tracks real time ===============
  // Previously the Moon never moved at all - any observable difference
  // here is new, correct behavior, not just a refinement of existing
  // behavior (see Sun3DTest.java, where the Sun already tracked position
  // before this fix and this is more of a regression check there).

  @Test
  void buildSubFace_positionChangesWithHour () {
    app.SHADE_DATE_ANGLE = 0;

    app.SHADE_HOUR_ANGLE = 0;
    solarchvision_bim.Moon3D.FaceVertex[] midnight = app.Moon3D.buildSubFace(0, 0, 1, 10, 0, 0, 1, 1, app.Moon3D.computeFrame());

    app.SHADE_HOUR_ANGLE = 12;
    solarchvision_bim.Moon3D.FaceVertex[] noon = app.Moon3D.buildSubFace(0, 0, 1, 10, 0, 0, 1, 1, app.Moon3D.computeFrame());

    boolean moved = midnight[0].x != noon[0].x || midnight[0].y != noon[0].y || midnight[0].z != noon[0].z;
    assertTrue(moved, "the moon's position should differ between hours - it used to be permanently fixed above the station");
  }

  @Test
  void buildSubFace_positionChangesWithDate () {
    app.SHADE_HOUR_ANGLE = 12;

    app.SHADE_DATE_ANGLE = 0;
    solarchvision_bim.Moon3D.FaceVertex[] day0 = app.Moon3D.buildSubFace(0, 0, 1, 10, 0, 0, 1, 1, app.Moon3D.computeFrame());

    app.SHADE_DATE_ANGLE = 90;
    solarchvision_bim.Moon3D.FaceVertex[] day90 = app.Moon3D.buildSubFace(0, 0, 1, 10, 0, 0, 1, 1, app.Moon3D.computeFrame());

    boolean moved = day0[0].x != day90[0].x || day0[0].y != day90[0].y || day0[0].z != day90[0].z;
    assertTrue(moved, "the moon's position should differ between dates (its own faster phase/declination cycle - see funcs.MoonPosition)");
  }

  // ================= buildSubFace(): tidal-locked texture =====================
  // (Alpha, Beta) no longer parameterizes a body/celestial-pole-fixed grid
  // at all when displayShadow is on (the default, and what every test
  // below runs with) - the mesh itself is now built directly in the
  // Sun-aligned (frame.Gright, frame.Gup, frame.Sx/Sy/Sz) basis instead,
  // so that displayNightSide's cutoff follows an actual grid line instead
  // of cutting diagonally across faces (see Moon3D.pde's own comments on
  // SkyFrame.Gright/Gup and buildSubFace() for the full reasoning).
  // Texture locking is still exactly what it was - these two helpers
  // split that back out: one for "a fixed point in the Earth-locked
  // frame" (unaffected by any of this), one for "which (Alpha, Beta)
  // currently reaches that point through the Sun-aligned grid" (the part
  // that's now hour/date-dependent, since the grid itself rotates with
  // the Sun).

  // A fixed real-world feature, 20deg "up" from the station-facing point
  // within the Earth-locked (F, Rup, Rright) texture frame - not the
  // Sun-aligned grid frame below, which is what makes this direction
  // genuinely fixed across hours/dates in the first place.
  private float[] earthFixedFeatureDirection (solarchvision_bim.Moon3D.SkyFrame frame) {
    float x = frame.Fx * app.funcs.cos_ang(20) + frame.Rupx * app.funcs.sin_ang(20);
    float y = frame.Fy * app.funcs.cos_ang(20) + frame.Rupy * app.funcs.sin_ang(20);
    float z = frame.Fz * app.funcs.cos_ang(20) + frame.Rupz * app.funcs.sin_ang(20);
    return new float[]{x, y, z};
  }

  // Inverts buildSubFace()'s own Sun-aligned grid basis: the (Alpha, Beta)
  // that currently produces the given world direction.
  private float[] alphaBetaForWorldDirection (solarchvision_bim.Moon3D.SkyFrame frame, float[] target) {
    float compRight = target[0] * frame.Grightx + target[1] * frame.Grighty + target[2] * frame.Grightz;
    float compUp = target[0] * frame.Gupx + target[1] * frame.Gupy + target[2] * frame.Gupz;
    float compForward = target[0] * frame.Sx + target[1] * frame.Sy + target[2] * frame.Sz;
    float alpha = app.funcs.asin_ang(Math.max(-1f, Math.min(1f, compForward))); // constrain() is a
                                    // PApplet/Processing built-in, in scope inside the
                                    // .pde sketch classes via inheritance but not here -
                                    // this test file is a plain standalone Java class.
    float beta = app.funcs.atan2_ang(compUp, compRight) + 90;
    return new float[]{alpha, beta};
  }

  @Test
  void buildSubFace_textureStaysLocked_acrossHours_atAFixedDate () {
    app.SHADE_DATE_ANGLE = 0;
    Float firstU = null, firstV = null;

    for (int hour : new int[]{6, 9, 12, 15, 18}) {
      app.SHADE_HOUR_ANGLE = hour;
      solarchvision_bim.Moon3D.SkyFrame frame = app.Moon3D.computeFrame();
      float[] target = earthFixedFeatureDirection(frame);
      float[] ab = alphaBetaForWorldDirection(frame, target);

      solarchvision_bim.Moon3D.FaceVertex[] subFace =
          app.Moon3D.buildSubFace(ab[0], ab[1], 1, 10, 0, 0, 1, 1, frame);

      if (firstU == null) {
        firstU = subFace[0].u;
        firstV = subFace[0].v;
      } else {
        assertEquals(firstU, subFace[0].u, 0.001f, "hour=" + hour);
        assertEquals(firstV, subFace[0].v, 0.001f, "hour=" + hour);
      }
    }
  }

  @Test
  void buildSubFace_textureStaysLocked_acrossDatesToo_notJustHours () {
    // Real tidal locking holds continuously - the same hemisphere faces
    // Earth throughout the Moon's whole orbit, not just within one day -
    // so a correctly-identified Earth-relative feature shouldn't drift
    // across dates any more than it does across hours (the test above).
    // Checked by hand before settling on this: decomposing one TRULY
    // fixed world direction (computed once, reused as-is) against each
    // date's own very differently-oriented F/Rup/Rright does show large
    // apparent "drift" - but that's an artifact of re-measuring a fixed
    // point with a rotated ruler (F itself swings across a large part of
    // the sky between these dates), not a real statement about the
    // texture lock failing. Re-identifying the SAME Earth-relative
    // feature fresh via each date's own current frame (the same
    // technique the hours test above uses) is what actually tests
    // whether tidal locking holds, and it does.
    app.SHADE_HOUR_ANGLE = 12;
    Float firstU = null, firstV = null;

    for (int dateAngle : new int[]{0, 7, 30, 90, 180}) {
      app.SHADE_DATE_ANGLE = dateAngle;
      solarchvision_bim.Moon3D.SkyFrame frame = app.Moon3D.computeFrame();
      float[] target = earthFixedFeatureDirection(frame);
      float[] ab = alphaBetaForWorldDirection(frame, target);

      solarchvision_bim.Moon3D.FaceVertex[] subFace =
          app.Moon3D.buildSubFace(ab[0], ab[1], 1, 10, 0, 0, 1, 1, frame);

      if (firstU == null) {
        firstU = subFace[0].u;
        firstV = subFace[0].v;
      } else {
        assertEquals(firstU, subFace[0].u, 0.001f, "dateAngle=" + dateAngle);
        assertEquals(firstV, subFace[0].v, 0.001f, "dateAngle=" + dateAngle);
      }
    }
  }

  // ================= buildSubFace(): the grid itself tracks the Sun ===========
  // The actual point of the Sun-aligned grid basis: displayNightSide's
  // cutoff (see shouldDrawSubFace()) is a brightness threshold, and these
  // confirm that threshold now falls on an exact grid line (Alpha=0, the
  // "equator" of this basis) rather than cutting across faces at whatever
  // angle the old body-frame grid happened to leave the terminator at.

  @Test
  void buildSubFace_gridPoleIsTheSubSolarPoint_regardlessOfLongitude () {
    app.SHADE_HOUR_ANGLE = 12;
    app.SHADE_DATE_ANGLE = 7; // crescent-ish, so there's an actual terminator to check
    solarchvision_bim.Moon3D.SkyFrame frame = app.Moon3D.computeFrame();

    for (float beta : new float[]{-90, 0, 90, 170}) {
      solarchvision_bim.Moon3D.FaceVertex[] subFace = app.Moon3D.buildSubFace(90, beta, 1, 10, 0, 0, 1, 1, frame);
      assertEquals(1f, subFace[0].brightness, 0.001f, "Beta=" + beta);
    }
  }

  @Test
  void buildSubFace_terminatorSitsExactlyOnTheGridsEquator_regardlessOfLongitude () {
    // illuminateDaySide reshapes this same litAmount->brightness curve
    // (see its own comment) - an orthogonal concern to what this test is
    // actually checking (that the terminator falls exactly on a grid
    // line), so it's turned off here to isolate that claim from it.
    app.Moon3D.illuminateDaySide = false;
    app.SHADE_HOUR_ANGLE = 12;
    app.SHADE_DATE_ANGLE = 7;
    solarchvision_bim.Moon3D.SkyFrame frame = app.Moon3D.computeFrame();

    // Alpha=0 means sunDot=sin(0)=0 exactly, the dead center of the
    // TERMINATOR_SOFTNESS ramp - litAmount=0.5 there, regardless of Beta.
    float expectedMidBrightness = 0.5f + 0.5f * app.Moon3D.DARK_SIDE_AMBIENT; // DARK_SIDE_AMBIENT + (1-DARK_SIDE_AMBIENT)*0.5
    for (float beta : new float[]{-90, 0, 90, 170}) {
      solarchvision_bim.Moon3D.FaceVertex[] subFace = app.Moon3D.buildSubFace(0, beta, 1, 10, 0, 0, 1, 1, frame);
      assertEquals(expectedMidBrightness, subFace[0].brightness, 0.001f, "Beta=" + beta);
    }
  }

  @Test
  void buildSubFace_antisolarPointIsTheDarkestPoint () {
    app.SHADE_HOUR_ANGLE = 12;
    app.SHADE_DATE_ANGLE = 7;
    solarchvision_bim.Moon3D.SkyFrame frame = app.Moon3D.computeFrame();

    solarchvision_bim.Moon3D.FaceVertex[] subFace = app.Moon3D.buildSubFace(-90, 0, 1, 10, 0, 0, 1, 1, frame);

    assertEquals(app.Moon3D.DARK_SIDE_AMBIENT, subFace[0].brightness, 0.001f);
  }

  // ================= illuminateDaySide =================================
  // Brightness is already fully saturated (1.0) everywhere beyond a
  // narrow TERMINATOR_SOFTNESS-wide band around the terminator - these
  // confirm illuminateDaySide only reshapes what's inside that band
  // (brighter, without moving its two endpoints), not the saturated
  // dark/lit regions on either side of it.

  @Test
  void illuminateDaySide_defaultsToOn () {
    assertTrue(app.Moon3D.illuminateDaySide);
  }

  @Test
  void illuminateDaySide_leavesTheFullyLitAndFullyDarkEndpointsUnchanged () {
    app.SHADE_HOUR_ANGLE = 12;
    app.SHADE_DATE_ANGLE = 7;
    solarchvision_bim.Moon3D.SkyFrame frame = app.Moon3D.computeFrame();

    // Well past the TERMINATOR_SOFTNESS band on either side (see
    // buildSubFace_gridPoleIsTheSubSolarPoint/antisolarPointIsTheDarkest
    // Point above for the exact endpoints) - already saturated regardless
    // of illuminateDaySide, since sqrt(0)=0 and sqrt(1)=1.
    app.Moon3D.illuminateDaySide = false;
    solarchvision_bim.Moon3D.FaceVertex[] litOff = app.Moon3D.buildSubFace(90, 0, 1, 10, 0, 0, 1, 1, frame);
    solarchvision_bim.Moon3D.FaceVertex[] darkOff = app.Moon3D.buildSubFace(-90, 0, 1, 10, 0, 0, 1, 1, frame);

    app.Moon3D.illuminateDaySide = true;
    solarchvision_bim.Moon3D.FaceVertex[] litOn = app.Moon3D.buildSubFace(90, 0, 1, 10, 0, 0, 1, 1, frame);
    solarchvision_bim.Moon3D.FaceVertex[] darkOn = app.Moon3D.buildSubFace(-90, 0, 1, 10, 0, 0, 1, 1, frame);

    assertEquals(litOff[0].brightness, litOn[0].brightness, 0.001f);
    assertEquals(darkOff[0].brightness, darkOn[0].brightness, 0.001f);
  }

  @Test
  void illuminateDaySide_brightensTheTerminatorTransitionBand () {
    app.SHADE_HOUR_ANGLE = 12;
    app.SHADE_DATE_ANGLE = 7;
    solarchvision_bim.Moon3D.SkyFrame frame = app.Moon3D.computeFrame();

    for (float alpha : new float[]{-6, -2, 0, 2, 6}) {
      app.Moon3D.illuminateDaySide = false;
      float off = app.Moon3D.buildSubFace(alpha, 0, 1, 10, 0, 0, 1, 1, frame)[0].brightness;

      app.Moon3D.illuminateDaySide = true;
      float on = app.Moon3D.buildSubFace(alpha, 0, 1, 10, 0, 0, 1, 1, frame)[0].brightness;

      assertTrue(on > off, "Alpha=" + alpha + ": expected on (" + on + ") > off (" + off + ")");
    }
  }

  @Test
  void rowIsEntirelyDark_matchesTheTerminatorBoundary () {
    app.SHADE_HOUR_ANGLE = 12;
    app.SHADE_DATE_ANGLE = 7;

    // Confirmed against a real compiled app comparison before extracting
    // this (see Moon3D.pde's own comment on rowIsEntirelyDark()): makes
    // exactly the same skip/draw decisions, row for row, as the old
    // per-face, post-hoc brightness check this replaced.
    assertFalse(app.Moon3D.rowIsEntirelyDark(90), "sub-solar pole - fully lit");
    assertFalse(app.Moon3D.rowIsEntirelyDark(0), "the terminator itself - half lit, not dark");
    assertTrue(app.Moon3D.rowIsEntirelyDark(-90), "antisolar pole - fully dark");

    // The actual boundary: just above vs. just below where sin(Alpha)
    // crosses -TERMINATOR_SOFTNESS.
    float boundary = app.funcs.asin_ang(-app.Moon3D.TERMINATOR_SOFTNESS);
    assertFalse(app.Moon3D.rowIsEntirelyDark(boundary + 1), "just above the boundary - not yet fully dark");
    assertTrue(app.Moon3D.rowIsEntirelyDark(boundary - 1), "just below the boundary - fully dark");
  }

  @Test
  void buildSubFace_withDisplayShadowOff_usesTheOldBodyFrameGrid_notTheSunOne () {
    // No terminator to align a grid with when phase shading itself is
    // off (see rowIsEntirelyDark()'s own reasoning, which draw() never
    // calls in this case) - confirms the grid pole in that case is NOT
    // the sub-solar point, i.e. this really did fall back to the
    // original body-frame construction rather than silently still using
    // a stale/zeroed Sun direction.
    app.Moon3D.displayShadow = false;
    app.SHADE_HOUR_ANGLE = 12;
    app.SHADE_DATE_ANGLE = 7;
    solarchvision_bim.Moon3D.SkyFrame frame = app.Moon3D.computeFrame();

    solarchvision_bim.Moon3D.FaceVertex[] subFace = app.Moon3D.buildSubFace(90, 0, 1, 10, 0, 0, 1, 1, frame);

    assertEquals(1f, subFace[0].brightness, "always fully lit when displayShadow is off");
  }

  @Test
  void buildSubFace_withDisplayTextureOff_leavesUVAtZero () {
    app.Moon3D.displayTexture = false;
    app.SHADE_HOUR_ANGLE = 12;
    app.SHADE_DATE_ANGLE = 0;

    solarchvision_bim.Moon3D.FaceVertex[] subFace =
        app.Moon3D.buildSubFace(0, 0, 1, 10, 0, 0, 1, 1, app.Moon3D.computeFrame());

    assertEquals(0f, subFace[0].u);
    assertEquals(0f, subFace[0].v);
  }

  // ================= load_images() =================================================

  @Test
  void loadImages_loadsTheRealBundledMoonTexture () {
    // BaseFolder/sketchPath() resolves wherever Processing's own CLI build
    // happens to run from, not this checkout - test/run_tests.sh only
    // cd's to the repo root before running (same reasoning as
    // Earth3DTest.java's equivalent note), so user.dir is the reliable
    // way to find the real, bundled Moon texture from here.
    app.Moon3D.Filename = System.getProperty("user.dir") + "/input/images/moon/Moon.jpg";

    app.Moon3D.load_images();

    assertEquals(1024, app.Moon3D.Map.width);
    assertEquals(512, app.Moon3D.Map.height);
  }

  // ================= brightenLevel / brightenTexture() =============================
  // A plain, one-time pixel multiply applied to the loaded texture itself
  // (see Moon3D.pde's own comment on why illuminateDaySide, a per-vertex/
  // per-frame tint, can't substitute for this) - tested here against a
  // small synthetic image, not the real bundled one, so the exact
  // before/after pixel values are known rather than inferred.

  @Test
  void brightenLevel_defaultsToOnePointTwoFive () {
    assertEquals(1.25f, app.Moon3D.brightenLevel, 0.0001f);
  }

  @Test
  void brightenTexture_multipliesEachChannel_clampedAt255_alphaUntouched () {
    // mixWithSkyColor off here, to isolate the plain level-multiply this
    // test is actually about - see its own tests, further down, for what
    // mixWithSkyColor adds on top.
    app.Moon3D.mixWithSkyColor = false;
    processing.core.PImage img = app.createImage(2, 1, processing.core.PConstants.ARGB);
    img.loadPixels();
    img.pixels[0] = 0xFF323232; // (50,50,50) * 2 -> (100,100,100), no clamping
    img.pixels[1] = 0x80808080; // alpha=128, (128,128,128) * 2 -> clamps to (255,255,255)
    img.updatePixels();

    app.Moon3D.brightenTexture(img, 2.0f);

    img.loadPixels();
    assertEquals(0xFF646464, img.pixels[0]);
    assertEquals(0x80FFFFFF, img.pixels[1]);
  }

  @Test
  void brightenTexture_atLevelOne_isATrueNoOp_whenMixWithSkyColorIsAlsoOff () {
    app.Moon3D.mixWithSkyColor = false;
    processing.core.PImage img = app.createImage(1, 1, processing.core.PConstants.ARGB);
    img.loadPixels();
    img.pixels[0] = 0xFF123456;
    img.updatePixels();

    app.Moon3D.brightenTexture(img, 1.0f);

    img.loadPixels();
    assertEquals(0xFF123456, img.pixels[0]);
  }

  // ================= mixWithSkyColor / skyColor =====================================
  // By daylight the real Moon reads as blue-tinted, not gray - see
  // Moon3D.pde's own comment on mixWithSkyColor for the full reasoning,
  // including why this has to be additive rather than a second
  // multiplicative tint.

  @Test
  void mixWithSkyColor_defaultsToOn () {
    assertTrue(app.Moon3D.mixWithSkyColor);
  }

  @Test
  void skyColor_defaultsToADaytimeSkyBlue () {
    assertEquals(app.color(127, 191, 255), app.Sky3D.flatColor);
  }

  @Test
  void halfSkyColor_isExactlyHalf_ofEachChannel () {
    int[] half = app.Moon3D.halfSkyColor();
    assertArrayEquals(new int[]{63, 95, 127}, half); // 127/2, 191/2, 255/2, integer division
  }

  @Test
  void brightenTexture_withMixWithSkyColor_addsHalfSkyColorOnTopOfTheLevelMultiply () {
    app.Moon3D.mixWithSkyColor = true;
    processing.core.PImage img = app.createImage(1, 1, processing.core.PConstants.ARGB);
    img.loadPixels();
    img.pixels[0] = 0xFF646400; // (100,100,0)
    img.updatePixels();

    app.Moon3D.brightenTexture(img, 1.25f);

    img.loadPixels();
    // r: 63 + round(100*1.25) = 63+125 = 188; g: 95+125 = 220; b: 127+round(0*1.25) = 127
    assertEquals(0xFFBCDC7F, img.pixels[0]);
  }

  @Test
  void brightenTexture_withMixWithSkyColor_isNotANoOp_evenAtLevelOne () {
    // Confirms the level==1 short-circuit (see brightenTexture()'s own
    // comment) correctly still runs the loop when mixWithSkyColor alone
    // has something to do, even with no actual brightening requested.
    app.Moon3D.mixWithSkyColor = true;
    processing.core.PImage img = app.createImage(1, 1, processing.core.PConstants.ARGB);
    img.loadPixels();
    img.pixels[0] = 0xFF000000; // pure black
    img.updatePixels();

    app.Moon3D.brightenTexture(img, 1.0f);

    img.loadPixels();
    assertEquals(app.color(63, 95, 127), img.pixels[0]); // half the sky color, not still black
  }

  @Test
  void tintColorForGray_withSky_addsHalfSkyColor_clampedAt255 () {
    int[] sky = app.Moon3D.halfSkyColor();

    int[] darkest = app.Moon3D.tintColorForGray(0, sky);
    assertArrayEquals(new int[]{63, 95, 127}, darkest, "even the darkest shadow should show blue, not black");

    int[] brightest = app.Moon3D.tintColorForGray(255, sky);
    assertArrayEquals(new int[]{255, 255, 255}, brightest, "fully lit should still clamp to white, not overflow blue");
  }

  @Test
  void tintColorForGray_withoutSky_isAPlainGray () {
    int[] result = app.Moon3D.tintColorForGray(100, null);
    assertArrayEquals(new int[]{100, 100, 100}, result);
  }

  // ================= displayNightSide / useSkyColorForNightSide ====================
  // Together, these make a solar eclipse show correctly - the Moon's
  // silhouette actually occluding the Sun's disk (displayNightSide drawing
  // its geometry rather than skipping it) while blending into the sky
  // everywhere else (useSkyColorForNightSide painting it as Sky3D's own
  // flat sky color rather than a dark gray disk) - see both fields' own
  // comments.

  @Test
  void displayNightSide_defaultsToOn () {
    assertTrue(app.Moon3D.displayNightSide);
  }

  @Test
  void useSkyColorForNightSide_defaultsToOn () {
    assertTrue(app.Moon3D.useSkyColorForNightSide);
  }

  @Test
  void vertexColor_atTheDarkFloor_usesSky3DsFlatColorExactly () {
    int[] sky = app.Moon3D.halfSkyColor();

    int[] result = app.Moon3D.vertexColor(app.Moon3D.DARK_SIDE_AMBIENT, sky);

    int[] expected = new int[]{
      (app.Sky3D.flatColor >> 16) & 0xFF,
      (app.Sky3D.flatColor >> 8) & 0xFF,
      app.Sky3D.flatColor & 0xFF
    };
    assertArrayEquals(expected, result);
  }

  @Test
  void vertexColor_justAboveTheDarkFloor_usesTheNormalTint_notSkyColor () {
    int[] sky = app.Moon3D.halfSkyColor();

    int[] result = app.Moon3D.vertexColor(app.Moon3D.DARK_SIDE_AMBIENT + 0.01f, sky);

    assertArrayEquals(app.Moon3D.tintColorForGray(Math.round(255 * (app.Moon3D.DARK_SIDE_AMBIENT + 0.01f)), sky), result);
  }

  @Test
  void vertexColor_fullyLit_isUnaffectedByUseSkyColorForNightSide () {
    int[] sky = app.Moon3D.halfSkyColor();

    assertArrayEquals(app.Moon3D.tintColorForGray(255, sky), app.Moon3D.vertexColor(1.0f, sky));
  }

  @Test
  void vertexColor_atTheDarkFloor_usesTheNormalDarkTint_whenUseSkyColorForNightSideIsOff () {
    app.Moon3D.useSkyColorForNightSide = false;
    int[] sky = app.Moon3D.halfSkyColor();

    int[] result = app.Moon3D.vertexColor(app.Moon3D.DARK_SIDE_AMBIENT, sky);

    assertArrayEquals(app.Moon3D.tintColorForGray(Math.round(255 * app.Moon3D.DARK_SIDE_AMBIENT), sky), result);
  }

  @Test
  void loadImages_appliesTheDefaultBrighteningToTheRealBundledTexture () {
    app.Moon3D.Filename = System.getProperty("user.dir") + "/input/images/moon/Moon.jpg";
    float theDefault = app.Moon3D.brightenLevel; // read, not hardcoded - this test
                                                   // shouldn't need editing every
                                                   // time the default itself changes.

    app.Moon3D.brightenLevel = 1.0f; // effectively raw, for comparison
    app.Moon3D.load_images();
    double rawAvg = averageChannelValue(app.Moon3D.Map);

    app.Moon3D.brightenLevel = theDefault;
    app.Moon3D.load_images();
    double brightAvg = averageChannelValue(app.Moon3D.Map);

    assertTrue(brightAvg > rawAvg, "raw=" + rawAvg + " brightened=" + brightAvg);
  }

  private double averageChannelValue (processing.core.PImage img) {
    img.loadPixels();
    long sum = 0;
    for (int px : img.pixels) sum += ((px >> 16) & 0xFF) + ((px >> 8) & 0xFF) + (px & 0xFF);
    return sum / (double) (img.pixels.length * 3);
  }

  // ================= draw(): the one part of this file that's off-limits =========
  // writeFaceWIN3D() (and so draw() itself, past its own displaySurface
  // guard) touches WIN3D.graphics directly - confirmed by hand against
  // the real compiled app to throw a NullPointerException here, same
  // WIN3D.graphics boundary as everywhere else in this app (see
  // test/README.md). The only part of draw() safely reachable from a
  // bare instance is the guard itself, which is what's tested below.

  @Test
  void draw_withDisplaySurfaceOff_isANoOp () {
    // displaySurface now defaults to true, so this sets it explicitly
    // rather than relying on the default - the test is about the guard
    // itself, not about what displaySurface happens to start as.
    app.Moon3D.displaySurface = false;

    assertDoesNotThrow(() -> app.Moon3D.draw());
  }

  // ================= to_XML / from_XML round trip ==================================

  @Test
  void toXMLThenFromXML_roundTripsDisplaySettings () {
    app.Moon3D.displaySurface = true;
    app.Moon3D.displayTexture = false;
    app.Moon3D.fitInSkyDome = false;

    processing.data.XML root = new processing.data.XML("root");
    app.Moon3D.to_XML(root);

    solarchvision_bim.Moon3D fresh = app.new Moon3D();
    fresh.from_XML(root);

    assertTrue(fresh.displaySurface);
    assertFalse(fresh.displayTexture);
    assertFalse(fresh.fitInSkyDome);
  }
}
