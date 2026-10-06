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

  private float[] stationFacingAlphaBeta (solarchvision_bim.Moon3D.SkyFrame frame) {
    float dy1 = frame.Fy * app.funcs.cos_ang(frame.ta) - frame.Fz * app.funcs.sin_ang(frame.ta);
    float dz1 = frame.Fy * app.funcs.sin_ang(frame.ta) + frame.Fz * app.funcs.cos_ang(frame.ta);
    float lat = app.funcs.asin_ang(Math.max(-1f, Math.min(1f, dz1))); // constrain() is a
                                    // PApplet/Processing built-in, in scope inside the
                                    // .pde sketch classes via inheritance but not here -
                                    // this test file is a plain standalone Java class.
    float lon = app.funcs.atan2_ang(dy1, frame.Fx) + 90;
    return new float[]{lat, lon};
  }

  @Test
  void buildSubFace_textureStaysLocked_acrossHours_atAFixedDate () {
    app.SHADE_DATE_ANGLE = 0;
    Float firstU = null, firstV = null;

    for (int hour : new int[]{6, 9, 12, 15, 18}) {
      app.SHADE_HOUR_ANGLE = hour;
      solarchvision_bim.Moon3D.SkyFrame frame = app.Moon3D.computeFrame();
      float[] ab = stationFacingAlphaBeta(frame);

      solarchvision_bim.Moon3D.FaceVertex[] subFace =
          app.Moon3D.buildSubFace(ab[0] + 20, ab[1] + 30, 1, 10, 0, 0, 1, 1, frame);

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
  void buildSubFace_textureDrifts_acrossDates_atAFixedHour () {
    app.SHADE_HOUR_ANGLE = 12;

    // Unlike the Sun (see Sun3DTest.java's own note on why it specifically
    // avoids DATE_ANGLE 0/180), the Moon's declination cycles roughly 13.4
    // times as fast via its own ~27.3-day period (funcs.MoonPosition), so
    // 0 vs 90 is already enough to land on meaningfully different points
    // of that faster cycle - checked by hand before settling on this pair.
    app.SHADE_DATE_ANGLE = 0;
    solarchvision_bim.Moon3D.SkyFrame frame0 = app.Moon3D.computeFrame();
    float[] ab0 = stationFacingAlphaBeta(frame0);
    solarchvision_bim.Moon3D.FaceVertex[] date0 =
        app.Moon3D.buildSubFace(ab0[0] + 20, ab0[1] + 30, 1, 10, 0, 0, 1, 1, frame0);

    app.SHADE_DATE_ANGLE = 90;
    solarchvision_bim.Moon3D.SkyFrame frame90 = app.Moon3D.computeFrame();
    float[] ab90 = stationFacingAlphaBeta(frame90);
    solarchvision_bim.Moon3D.FaceVertex[] date90 =
        app.Moon3D.buildSubFace(ab90[0] + 20, ab90[1] + 30, 1, 10, 0, 0, 1, 1, frame90);

    boolean differs = Math.abs(date0[0].u - date90[0].u) > 0.01f || Math.abs(date0[0].v - date90[0].v) > 0.01f;
    assertTrue(differs, "the same offset-from-center feature should show different texture across dates "
        + "(date=0 u=" + date0[0].u + " v=" + date0[0].v + ", date=90 u=" + date90[0].u + " v=" + date90[0].v + ")");
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

  // ================= draw(): the one part of this file that's off-limits =========
  // writeFaceWIN3D() (and so draw() itself, past its own displaySurface
  // guard) touches WIN3D.graphics directly - confirmed by hand against
  // the real compiled app to throw a NullPointerException here, same
  // WIN3D.graphics boundary as everywhere else in this app (see
  // test/README.md). The only part of draw() safely reachable from a
  // bare instance is the guard itself, which is what's tested below.

  @Test
  void draw_withDisplaySurfaceOff_isANoOp () {
    assertFalse(app.Moon3D.displaySurface, "default");

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
