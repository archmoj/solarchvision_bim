import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// computeFrame()/buildSubFace() are plain trig/vector math - no
// WIN3D.graphics, no PImage - so, like import_objects_OBJ() (see
// ImportObjectsOBJTest.java), they're directly callable from a bare,
// never-setup()'d instance. Both are package-private (no modifier), and
// since none of these test files declare a package either, they're
// callable directly here with no reflection needed.
//
// draw()'s own displaySurface guard isn't exercised at all - these tests
// call computeFrame()/buildSubFace() directly, bypassing it, the same way
// a WIN3D.graphics-touching draw() couldn't be tested here regardless.
class Sun3DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.STATION.setLatitude(43.7f); // an arbitrary non-degenerate latitude -
                                    // avoids the lat=0 default, which isn't
                                    // wrong, just not representative.
  }

  // ================= computeFrame(): orthonormality ===========================
  // The tidal-locking fix depends entirely on (F, Rup, Rright) actually
  // being an orthonormal frame - if it ever stopped being one (e.g. a
  // future edit reintroducing the earlier, insufficient plain-shift
  // approach), the texture would silently warp rather than throw. Checked
  // at a few different hours/dates, not just one, since the construction
  // itself (cross products off the celestial pole) depends on tA/tB.

  private void assertOrthonormalFrame (solarchvision_bim.Sun3D.SkyFrame frame) {
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
        assertOrthonormalFrame(app.Sun3D.computeFrame());
      }
    }
  }

  @Test
  void computeFrame_withDisplayTextureOff_skipsRupAndRrightButStillSetsF () {
    app.Sun3D.displayTexture = false;
    app.SHADE_HOUR_ANGLE = 12;
    app.SHADE_DATE_ANGLE = 0;

    solarchvision_bim.Sun3D.SkyFrame frame = app.Sun3D.computeFrame();

    // F is needed for the translation step regardless of displayTexture
    // (see buildSubFace's own comment on reusing -d*F there), so it's
    // always computed; Rup/Rright are only ever used for texture lookup,
    // so they're left at Java's default 0 when there's no texture to lock.
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

  @Test
  void buildSubFace_positionChangesWithHour () {
    app.SHADE_DATE_ANGLE = 0;

    app.SHADE_HOUR_ANGLE = 6;
    solarchvision_bim.Sun3D.FaceVertex[] morning = app.Sun3D.buildSubFace(0, 0, 1, 10, 0, 0, 1, 1, app.Sun3D.computeFrame());

    app.SHADE_HOUR_ANGLE = 18;
    solarchvision_bim.Sun3D.FaceVertex[] evening = app.Sun3D.buildSubFace(0, 0, 1, 10, 0, 0, 1, 1, app.Sun3D.computeFrame());

    // Any one coordinate differing is enough to prove the sphere actually
    // moved - not pinning down exact numbers here, just that it's not
    // permanently fixed (the bug this replaced).
    boolean moved = morning[0].x != evening[0].x || morning[0].y != evening[0].y || morning[0].z != evening[0].z;
    assertTrue(moved, "the sun's position should differ between morning and evening");
  }

  @Test
  void buildSubFace_positionChangesWithDate () {
    app.SHADE_HOUR_ANGLE = 12;

    app.SHADE_DATE_ANGLE = 0;
    solarchvision_bim.Sun3D.FaceVertex[] winter = app.Sun3D.buildSubFace(0, 0, 1, 10, 0, 0, 1, 1, app.Sun3D.computeFrame());

    app.SHADE_DATE_ANGLE = 180;
    solarchvision_bim.Sun3D.FaceVertex[] summer = app.Sun3D.buildSubFace(0, 0, 1, 10, 0, 0, 1, 1, app.Sun3D.computeFrame());

    boolean moved = winter[0].x != summer[0].x || winter[0].y != summer[0].y || winter[0].z != summer[0].z;
    assertTrue(moved, "the sun's position should differ between the two dates (seasonal altitude change)");
  }

  // ================= buildSubFace(): tidal-locked texture =====================
  // The real guarantee this whole fix is for: a fixed offset from the
  // station-facing point shows the same texture regardless of hour, and
  // genuinely different texture across dates (i.e. not just permanently
  // frozen either).

  // Inverts computeFrame()'s own F/ta construction to recover the body-
  // frame (Alpha, Beta) that's currently station-facing - the same
  // derivation used (and verified) while writing the fix itself.
  private float[] stationFacingAlphaBeta (solarchvision_bim.Sun3D.SkyFrame frame) {
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
      solarchvision_bim.Sun3D.SkyFrame frame = app.Sun3D.computeFrame();
      float[] ab = stationFacingAlphaBeta(frame);

      // A fixed, arbitrary feature 20deg off the station-facing center.
      solarchvision_bim.Sun3D.FaceVertex[] subFace =
          app.Sun3D.buildSubFace(ab[0] + 20, ab[1] + 30, 1, 10, 0, 0, 1, 1, frame);

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

    // The two solstices (declination at its extremes, ±23.45) rather than
    // the two equinoxes (DATE_ANGLE 0 and 180, both declination 0 under
    // 23.45*sin(DateAngle-180) - a pair that would show no real drift at
    // all, caught by hand before settling on 90/270 here instead).
    app.SHADE_DATE_ANGLE = 90;
    solarchvision_bim.Sun3D.SkyFrame winterFrame = app.Sun3D.computeFrame();
    float[] winterAB = stationFacingAlphaBeta(winterFrame);
    solarchvision_bim.Sun3D.FaceVertex[] winter =
        app.Sun3D.buildSubFace(winterAB[0] + 20, winterAB[1] + 30, 1, 10, 0, 0, 1, 1, winterFrame);

    app.SHADE_DATE_ANGLE = 270;
    solarchvision_bim.Sun3D.SkyFrame summerFrame = app.Sun3D.computeFrame();
    float[] summerAB = stationFacingAlphaBeta(summerFrame);
    solarchvision_bim.Sun3D.FaceVertex[] summer =
        app.Sun3D.buildSubFace(summerAB[0] + 20, summerAB[1] + 30, 1, 10, 0, 0, 1, 1, summerFrame);

    boolean differs = Math.abs(winter[0].u - summer[0].u) > 0.01f || Math.abs(winter[0].v - summer[0].v) > 0.01f;
    assertTrue(differs, "the same offset-from-center feature should show different texture across dates "
        + "(winter u=" + winter[0].u + " v=" + winter[0].v + ", summer u=" + summer[0].u + " v=" + summer[0].v + ")");
  }

  @Test
  void buildSubFace_withDisplayTextureOff_leavesUVAtZero () {
    app.Sun3D.displayTexture = false;
    app.SHADE_HOUR_ANGLE = 12;
    app.SHADE_DATE_ANGLE = 0;

    solarchvision_bim.Sun3D.FaceVertex[] subFace =
        app.Sun3D.buildSubFace(0, 0, 1, 10, 0, 0, 1, 1, app.Sun3D.computeFrame());

    assertEquals(0f, subFace[0].u);
    assertEquals(0f, subFace[0].v);
  }
}
