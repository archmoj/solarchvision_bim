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
// draw() itself only builds/writes the sun disc (same self-contained
// shape as Moon3D.pde's own draw()) - the grid/path/pattern/cycles
// drawing (drawGrid(), drawPath(), drawPattern(), drawCycles()) are
// separate methods WIN3D.pde calls directly, not reached through draw()
// at all, and all of them touch WIN3D.graphics/STUDY.graphics
// unconditionally - confirmed by hand against the real compiled app,
// same WIN3D.graphics boundary as everywhere else in this app (see
// test/README.md) - so only draw()'s own displaySurface guard is
// reachable here, same as Moon3DTest.java's equivalent test.
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
  void computeFrame_RupPointsTowardTheNorthCelestialPole_notSouth () {
    // A real, confirmed bug: Rup used to be built from the SOUTH
    // celestial pole instead of the north one (the pole reference's own
    // sign was backwards), which put the real Moon's north pole visibly
    // at the bottom of its own texture (same construction, shared bug -
    // see Moon3D.pde's buildRightUp()). Checked here against an
    // independently-derived north direction - the difference between
    // funcs.SunPosition() at a genuinely high vs. low declination, not
    // read from the app's own pole variable - so this actually catches a
    // regression rather than re-asserting the same formula against itself.
    app.SHADE_HOUR_ANGLE = 9; // deliberately not noon, so F and north
    app.SHADE_DATE_ANGLE = 30; // aren't forced near-perpendicular by symmetry.
    solarchvision_bim.Sun3D.SkyFrame frame = app.Sun3D.computeFrame();

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

  // ================= wrapDayIndex() ===============================================
  // Plain integer math, no dependencies at all.

  @Test
  void wrapDayIndex_leavesAnInRangeDayUnchanged () {
    assertEquals(10, app.Sun3D.wrapDayIndex(10));
    assertEquals(0, app.Sun3D.wrapDayIndex(0));
  }

  @Test
  void wrapDayIndex_wrapsValuesAtOrAbove365 () {
    assertEquals(0, app.Sun3D.wrapDayIndex(365));
    assertEquals(35, app.Sun3D.wrapDayIndex(400));
  }

  @Test
  void wrapDayIndex_wrapsNegativeValues () {
    assertEquals(364, app.Sun3D.wrapDayIndex(-1));
    // More than a single year below zero - confirmed by hand against the
    // real compiled app rather than just trusting the double-wrap
    // (+365, then a second +365 if still negative) actually covers this:
    // int(-366+365)=-1, then (-1+365)%365=364.
    assertEquals(364, app.Sun3D.wrapDayIndex(-366));
  }

  // ================= activePalette() ===============================================

  @Test
  void activePalette_readsSunsOwnSettings_whenNotUsingStudySettings () {
    app.WIN3D.impactTypeIndex = app.Impact_ACTIVE;
    app.Sun3D.activeColorscaleIndex = 5;
    app.Sun3D.activeColorscaleDirection = 1;
    app.Sun3D.activeColorscaleFactor = 2;

    float[] palette = app.Sun3D.activePalette(false);

    assertEquals(5f, palette[0], 0.0001f);
    assertEquals(1f, palette[1], 0.0001f);
    assertEquals(2f, palette[2], 0.0001f);
  }

  @Test
  void activePalette_readsSTUDYsSettings_whenUsingStudySettings () {
    app.WIN3D.impactTypeIndex = app.Impact_ACTIVE;
    app.STUDY.activeColorscaleIndex = 7;
    app.STUDY.activeColorscaleDirection = -1;
    app.STUDY.activeColorscaleFactor = 3;

    float[] palette = app.Sun3D.activePalette(true);

    assertEquals(7f, palette[0], 0.0001f);
    assertEquals(-1f, palette[1], 0.0001f);
    assertEquals(3f, palette[2], 0.0001f);
  }

  @Test
  void activePalette_readsThePassiveSettings_whenImpactTypeIsPassive () {
    app.WIN3D.impactTypeIndex = app.Impact_PASSIVE;
    app.Sun3D.passiveColorscaleIndex = 9;
    app.Sun3D.passiveColorscaleDirection = -2;
    app.Sun3D.passiveColorscaleFactor = 0.5f;

    float[] palette = app.Sun3D.activePalette(false);

    assertEquals(9f, palette[0], 0.0001f);
    assertEquals(-2f, palette[1], 0.0001f);
    assertEquals(0.5f, palette[2], 0.0001f);
  }

  // ================= paletteValueToColor() =========================================

  @Test
  void paletteValueToColor_returnsAFourComponentColor () {
    app.WIN3D.impactTypeIndex = app.Impact_ACTIVE;

    // Not re-deriving PAINT's own palette math here (out of scope for
    // this file - it's PAINT.pde's own responsibility) - just confirming
    // paletteValueToColor() wires rawValue/palType/palDirection through
    // to it and back correctly, against a result confirmed by hand
    // against the real compiled app.
    float[] col = app.Sun3D.paletteValueToColor(0.5f, 15, 1);

    assertEquals(4, col.length);
    assertEquals(255f, col[0], 0.01f);
    assertEquals(255f, col[1], 0.01f);
    assertEquals(127.5f, col[2], 0.01f);
    assertEquals(0f, col[3], 0.01f);
  }

  // ================= load_images() =================================================

  @Test
  void loadImages_loadsTheRealBundledSunTexture () {
    // Same user.dir-based path override as Moon3DTest.java/Earth3DTest.java.
    app.Sun3D.Filename = System.getProperty("user.dir") + "/input/images/sun/Sun.jpg";

    app.Sun3D.load_images();

    assertEquals(3000, app.Sun3D.Map.width);
    assertEquals(1500, app.Sun3D.Map.height);
  }

  // ================= draw(): the one part of this file that's off-limits ==========

  @Test
  void draw_withDisplaySurfaceOff_isANoOp () {
    app.Sun3D.displaySurface = false;

    assertDoesNotThrow(() -> app.Sun3D.draw());
  }

  // ================= to_XML / from_XML round trip ==================================

  @Test
  void toXMLThenFromXML_roundTripsDisplaySettings () {
    app.Sun3D.displaySurface = false;
    app.Sun3D.displayTexture = false;
    app.Sun3D.displayGrid = false;
    app.Sun3D.displayPath = false;
    app.Sun3D.displayPattern = true;
    app.Sun3D.fitInSkyDome = false;

    processing.data.XML root = new processing.data.XML("root");
    app.Sun3D.to_XML(root);

    solarchvision_bim.Sun3D fresh = app.new Sun3D();
    fresh.from_XML(root);

    assertFalse(fresh.displaySurface);
    assertFalse(fresh.displayTexture);
    assertFalse(fresh.displayGrid);
    assertFalse(fresh.displayPath);
    assertTrue(fresh.displayPattern);
    assertFalse(fresh.fitInSkyDome);
  }

  @Test
  void toXMLThenFromXML_roundTripsThePaletteSettings () {
    app.Sun3D.activeColorscaleIndex = 11;
    app.Sun3D.activeColorscaleDirection = -1;
    app.Sun3D.activeColorscaleFactor = 1.5f;
    app.Sun3D.passiveColorscaleIndex = 13;
    app.Sun3D.passiveColorscaleDirection = 2;
    app.Sun3D.passiveColorscaleFactor = 0.75f;

    processing.data.XML root = new processing.data.XML("root");
    app.Sun3D.to_XML(root);

    solarchvision_bim.Sun3D fresh = app.new Sun3D();
    fresh.from_XML(root);

    assertEquals(11, fresh.activeColorscaleIndex);
    assertEquals(-1, fresh.activeColorscaleDirection);
    assertEquals(1.5f, fresh.activeColorscaleFactor, 0.0001f);
    assertEquals(13, fresh.passiveColorscaleIndex);
    assertEquals(2, fresh.passiveColorscaleDirection);
    assertEquals(0.75f, fresh.passiveColorscaleFactor, 0.0001f);
  }
}
