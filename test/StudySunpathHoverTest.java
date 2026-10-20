import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers studySunpathHover.pde's pure logic: formatAzimuthAndAltitude()
// (Beta/Alpha as azimuth/altitude, no snapping) and studySunpathHover_
// hitTest() (nearest-neighbor search over a scatter of individual points,
// not a grid or a set of rects). drawSunpathHoverBox() itself touches
// real graphics and isn't independently testable here, consistent with
// everything else this session that draws to a live PGraphics context.
//
// Reminder on the naming mismatch (see studySunpathHover.pde's own
// comment): this file is for the UI's "Hourly Sun" entry, which is
// plotImpact_sunpath() internally - not the UI's "Sun Path" entry, which
// is the separate, not-yet-attempted plotImpact_cycles().
class StudySunpathHoverTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= formatAzimuthAndAltitude ===============================

  @Test
  void format_convertsBetaToStandardCompassBearing () {
    // Beta=0 (south, this app's own convention) -> compassBearing=180
    assertEquals("Azimuth 180\u00B0, Altitude 34\u00B0", app.formatAzimuthAndAltitude(0f, 33.7f));
  }

  @Test
  void format_showsAltitudeExactly_noSnapping () {
    // Unlike Pose Potential's inclination, altitude near 0 or 90 must NOT
    // snap to a round value or a special label - it's shown exactly as
    // the sun's own position actually is.
    assertEquals("Azimuth 180\u00B0, Altitude 2\u00B0", app.formatAzimuthAndAltitude(0f, 2f));
    assertEquals("Azimuth 180\u00B0, Altitude 88\u00B0", app.formatAzimuthAndAltitude(0f, 88f));
  }

  @Test
  void format_roundsNonIntegerValues () {
    // nf(value, 1, 0) does not round on its own - it only guarantees a
    // minimum of 0 decimal digits, so nf(12.857, 1, 0) would print
    // "12.857", not "13", without an explicit round() first. The sun's
    // own continuous position essentially never lands on a whole number,
    // so this is the normal case here, not an edge case.
    assertEquals("Azimuth 77\u00B0, Altitude 13\u00B0", app.formatAzimuthAndAltitude(102.857f, 12.6f));
  }

  // ================= studySunpathHover_hitTest ===============================

  private solarchvision_bim.SunpathHoverPoint makePoint (float screenX, float screenY, float hitRadius, float valuesSUM, int impactTypeIndex) {
    solarchvision_bim.SunpathHoverPoint p = app.new SunpathHoverPoint();
    p.screenX = screenX;
    p.screenY = screenY;
    p.hitRadius = hitRadius;
    p.Alpha = 45;
    p.Beta = 0;
    p.valuesSUM = valuesSUM;
    p.impactTypeIndex = impactTypeIndex;
    return p;
  }

  @Test
  void hitTest_findsAPointWithinItsOwnRadius () {
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.sunpathHoverPoints = new java.util.ArrayList<>();
    app.STUDY.sunpathHoverPoints.add(makePoint(100, 100, 10, 5f, app.Impact_ACTIVE));

    solarchvision_bim.SunpathHoverPoint hit = app.studySunpathHover_hitTest(103, 100); // 3px away, within radius 10

    assertNotNull(hit);
    assertEquals(5f, hit.valuesSUM, 0.0001f);
  }

  @Test
  void hitTest_isNull_outsideThatPointsOwnRadius () {
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.sunpathHoverPoints = new java.util.ArrayList<>();
    app.STUDY.sunpathHoverPoints.add(makePoint(100, 100, 10, 5f, app.Impact_ACTIVE));

    assertNull(app.studySunpathHover_hitTest(200, 200));
  }

  @Test
  void hitTest_isNull_whenNothingHasBeenRecordedYet () {
    app.STUDY.sunpathHoverPoints = null;
    assertDoesNotThrow(() -> assertNull(app.studySunpathHover_hitTest(100, 100)));
  }

  @Test
  void hitTest_picksTheNearestOfMultiplePoints () {
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.sunpathHoverPoints = new java.util.ArrayList<>();
    app.STUDY.sunpathHoverPoints.add(makePoint(0, 0, 50, 1f, app.Impact_ACTIVE));     // far from the mouse, but a loose enough radius to still match on its own
    app.STUDY.sunpathHoverPoints.add(makePoint(100, 100, 50, 2f, app.Impact_ACTIVE)); // actually nearest to the mouse below

    solarchvision_bim.SunpathHoverPoint hit = app.studySunpathHover_hitTest(105, 100);

    assertNotNull(hit);
    assertEquals(2f, hit.valuesSUM, 0.0001f, "must match the nearer point (100,100), not the farther one that also happens to be within its own radius");
  }

  @Test
  void hitTest_nearestPointsOwnRadiusGoverns_evenIfAFartherPointsRadiusWouldCover () {
    // Points are recorded with their own hitRadius rather than a single
    // shared field, since (unlike this particular graph, which is only
    // ever shown once per render pass) nothing here should assume only
    // one call happens per pass - the same caution Skin Potential's and
    // Pose Potential's own hover needed for their actual multi-call
    // scenarios. The hit-test always finds the geometrically nearest
    // point first, then checks only that point's own radius - it doesn't
    // fall back to a farther point even if that farther point's own
    // (larger) radius would have covered the mouse.
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.sunpathHoverPoints = new java.util.ArrayList<>();
    app.STUDY.sunpathHoverPoints.add(makePoint(0, 0, 5, 1f, app.Impact_ACTIVE));    // nearest to the mouse, but too small a radius to reach it
    app.STUDY.sunpathHoverPoints.add(makePoint(50, 0, 200, 2f, app.Impact_ACTIVE)); // farther, but a radius easily large enough to cover the mouse too

    // Mouse at (8,0): distance 8 from (0,0) - outside its own radius 5 -
    // and distance 42 from (50,0) - well within its own radius 200.
    solarchvision_bim.SunpathHoverPoint hit = app.studySunpathHover_hitTest(8, 0);

    assertNull(hit, "the nearest point's own radius (5) excludes this mouse position, and there's no fallback to the farther point's larger radius");
  }

  @Test
  void hitTest_readsImpactTypeFromTheMatchedPoint () {
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.sunpathHoverPoints = new java.util.ArrayList<>();
    app.STUDY.sunpathHoverPoints.add(makePoint(0, 0, 10, 1f, app.Impact_PASSIVE));

    solarchvision_bim.SunpathHoverPoint hit = app.studySunpathHover_hitTest(0, 0);

    assertNotNull(hit);
    assertEquals(app.Impact_PASSIVE, hit.impactTypeIndex);
  }
}
