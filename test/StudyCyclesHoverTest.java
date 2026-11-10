import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers hoverOnStudyCycles.pde's own pure logic: studyCyclesHover_
// hitTest(), a nearest-mesh-vertex search gated by each vertex's own
// hitRadius - same shape as StudySunpathHoverTest.java's own
// studySunpathHover_hitTest() (hoverOnStudySunpath.pde), which that
// file's own header comment explicitly calls out as the structural
// sibling here (though hoverOnStudyCycles.pde's own header comment adds
// the nuance that this one's hitRadius exists to behave like a
// continuous, gapless surface, not a sparse scatter). placeCyclesHoverBox()
// itself touches real graphics (queueHover()) and isn't independently
// testable here, consistent with drawSunpathHoverBox()'s own exclusion
// in that sibling file.
//
// Naming reminder, same as that sibling file's own: this is the UI's
// "Sun Path" entry (plotImpact_cycles() internally), not "Hourly Sun"
// (plotImpact_sunpath(), StudySunpathHoverTest.java's own target).
class StudyCyclesHoverTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  private solarchvision_bim.CyclesHoverPoint makePoint (float screenX, float screenY, float hitRadius, float valuesSUM, int impactTypeIndex) {
    solarchvision_bim.CyclesHoverPoint p = app.new CyclesHoverPoint();
    p.screenX = screenX;
    p.screenY = screenY;
    p.hitRadius = hitRadius;
    p.Alpha = 45;
    p.Beta = 0;
    p.valuesSUM = valuesSUM;
    p.impactTypeIndex = impactTypeIndex;
    p.hour = 12;
    p.calendarDay = 100;
    p.daysMergedHalf = 0;
    return p;
  }

  @Test
  void hitTest_findsAVertexWithinItsOwnRadius () {
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.cyclesHoverPoints = new java.util.ArrayList<>();
    app.STUDY.cyclesHoverPoints.add(makePoint(100, 100, 10, 5f, app.Impact_ACTIVE));

    solarchvision_bim.CyclesHoverPoint hit = app.studyCyclesHover_hitTest(103, 100); // 3px away, within radius 10

    assertNotNull(hit);
    assertEquals(5f, hit.valuesSUM, 0.0001f);
  }

  @Test
  void hitTest_isNull_outsideThatVertexsOwnRadius () {
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.cyclesHoverPoints = new java.util.ArrayList<>();
    app.STUDY.cyclesHoverPoints.add(makePoint(100, 100, 10, 5f, app.Impact_ACTIVE));

    assertNull(app.studyCyclesHover_hitTest(200, 200));
  }

  @Test
  void hitTest_isNull_whenNothingHasBeenRecordedYet () {
    app.STUDY.cyclesHoverPoints = null;

    assertDoesNotThrow(() -> assertNull(app.studyCyclesHover_hitTest(100, 100)));
  }

  @Test
  void hitTest_picksTheNearestOfMultipleVertices () {
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.cyclesHoverPoints = new java.util.ArrayList<>();
    app.STUDY.cyclesHoverPoints.add(makePoint(0, 0, 50, 1f, app.Impact_ACTIVE));     // far from the mouse, but a loose enough radius to still match on its own
    app.STUDY.cyclesHoverPoints.add(makePoint(100, 100, 50, 2f, app.Impact_ACTIVE)); // actually nearest to the mouse below

    solarchvision_bim.CyclesHoverPoint hit = app.studyCyclesHover_hitTest(105, 100);

    assertNotNull(hit);
    assertEquals(2f, hit.valuesSUM, 0.0001f, "must match the nearer vertex (100,100), not the farther one that also happens to be within its own radius");
  }

  @Test
  void hitTest_nearestVertexsOwnRadiusGoverns_evenIfAFartherVertexsRadiusWouldCover () {
    // Same caution as the sibling sunpath test's own identical scenario:
    // the hit-test always finds the geometrically nearest vertex first,
    // then checks only that vertex's own radius - no fallback to a
    // farther vertex even if that farther one's larger radius would
    // have covered the mouse.
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.cyclesHoverPoints = new java.util.ArrayList<>();
    app.STUDY.cyclesHoverPoints.add(makePoint(0, 0, 5, 1f, app.Impact_ACTIVE));    // nearest to the mouse, but too small a radius to reach it
    app.STUDY.cyclesHoverPoints.add(makePoint(50, 0, 200, 2f, app.Impact_ACTIVE)); // farther, but a radius easily large enough to cover the mouse too

    // Mouse at (8,0): distance 8 from (0,0) - outside its own radius 5 -
    // and distance 42 from (50,0) - well within its own radius 200.
    solarchvision_bim.CyclesHoverPoint hit = app.studyCyclesHover_hitTest(8, 0);

    assertNull(hit, "the nearest vertex's own radius (5) excludes this mouse position, and there's no fallback to the farther vertex's larger radius");
  }

  @Test
  void hitTest_readsEveryFieldFromTheMatchedVertex_notJustValuesSUM () {
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.cyclesHoverPoints = new java.util.ArrayList<>();
    solarchvision_bim.CyclesHoverPoint expected = makePoint(0, 0, 10, 1f, app.Impact_PASSIVE);
    expected.hour = 7;
    expected.calendarDay = 42;
    expected.daysMergedHalf = 3;
    app.STUDY.cyclesHoverPoints.add(expected);

    solarchvision_bim.CyclesHoverPoint hit = app.studyCyclesHover_hitTest(0, 0);

    assertNotNull(hit);
    assertEquals(app.Impact_PASSIVE, hit.impactTypeIndex);
    assertEquals(7, hit.hour);
    assertEquals(42, hit.calendarDay);
    assertEquals(3, hit.daysMergedHalf);
  }

  @Test
  void hitTest_respectsSTUDYsOwnCXAndCYOffset_andImageScale () {
    // The mouse position is converted into the same local graphics space
    // the recorded vertex's own screenX/screenY are in - (xMouse - cX) *
    // ImageScale, (yMouse - cY) * ImageScale - before the nearest-
    // neighbor search ever runs.
    app.STUDY.cX = 50;
    app.STUDY.cY = 20;
    app.STUDY.ImageScale = 2;
    app.STUDY.cyclesHoverPoints = new java.util.ArrayList<>();
    app.STUDY.cyclesHoverPoints.add(makePoint(100, 100, 10, 9f, app.Impact_ACTIVE));

    // (xMouse - 50) * 2 == 100 -> xMouse == 100; same for y.
    solarchvision_bim.CyclesHoverPoint hit = app.studyCyclesHover_hitTest(100, 70);

    assertNotNull(hit);
    assertEquals(9f, hit.valuesSUM, 0.0001f);
  }
}
