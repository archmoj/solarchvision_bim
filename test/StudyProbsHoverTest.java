import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers hoverOnStudyProbs.pde's pure logic: probsHoverTimeRangeText()
// (the window's hour-range display text) and studyProbsHover_hitTest()
// (the point-in-rect hit test against each drawn probability box).
// drawProbsHoverBox() itself touches real graphics (queueHover() measures
// text against a live context, and paintHover() actually draws) and
// isn't independently testable here,
// same as drawNormalsHoverBox() in StudyNormalsHoverTest.java - that's
// exactly why probsHoverTimeRangeText() was pulled out as its own pure
// function in the first place, rather than inlined where it's used.
class StudyProbsHoverTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= probsHoverTimeRangeText =================================

  @Test
  void timeRangeText_aFourHourWindow_spansFromItsFirstHourThroughTheEndOfItsLast () {
    // hourEnd=7, hourWidth=4 -> hours 4,5,6,7 -> 04:00 through the end of
    // the 7:00 hour, i.e. 08:00 - not 07:00, which would be only a
    // 3-hour span.
    assertEquals("Time: 04:00 \u2013 08:00", app.probsHoverTimeRangeText(7, 4));
  }

  @Test
  void timeRangeText_aSingleHourWindow_stillShowsAFullHourLongSpan () {
    // hourEnd=7, hourWidth=1 -> just hour 7 -> 07:00 through 08:00, not a
    // single instant "07:00".
    assertEquals("Time: 07:00 \u2013 08:00", app.probsHoverTimeRangeText(7, 1));
  }

  @Test
  void timeRangeText_aWindowStartingAtMidnight () {
    assertEquals("Time: 00:00 \u2013 04:00", app.probsHoverTimeRangeText(3, 4));
  }

  @Test
  void timeRangeText_aWindowEndingAtTheLastHourOfTheDay_showsTwentyFourHundred () {
    // hourEnd=23, hourWidth=1: no day-boundary wraparound into "00:00" of
    // the next day - see probsHoverTimeRangeText()'s own comment on why.
    assertEquals("Time: 23:00 \u2013 24:00", app.probsHoverTimeRangeText(23, 1));
  }

  @Test
  void timeRangeText_padsSingleDigitHoursWithALeadingZero () {
    assertEquals("Time: 00:00 \u2013 01:00", app.probsHoverTimeRangeText(0, 1));
  }

  // ================= studyProbsHover_hitTest ==================================

  private solarchvision_bim.ProbsHoverBox makeBox (float x1, float y1, float x2, float y2, float binLow, float binHigh) {
    solarchvision_bim.ProbsHoverBox box = app.new ProbsHoverBox();
    box.screenX1 = x1;
    box.screenY1 = y1;
    box.screenX2 = x2;
    box.screenY2 = y2;
    box.binLow = binLow;
    box.binHigh = binHigh;
    box.probPercent = 25f;
    box.sampleCount = 10;
    box.totalCount = 40;
    box.targetDate = 100; // arbitrary - the hit-test itself never reads targetDate/daysMergedHalf/hourEnd/hourWidth, only drawProbsHoverBox() (untestable here, see file header) does
    box.daysMergedHalf = 0;
    box.hourEnd = 7;
    box.hourWidth = 4;
    box.layerName = "Surface Wind Speed";
    box.layerUnit = " km/h";
    return box;
  }

  @Test
  void hitTest_findsABoxTheMouseIsOver () {
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.probsHoverBoxes = new java.util.ArrayList<>();
    app.STUDY.probsHoverBoxes.add(makeBox(90, 50, 110, 150, 10, 20));

    solarchvision_bim.ProbsHoverBox hit = app.studyProbsHover_hitTest(100, 100);

    assertNotNull(hit);
    assertEquals(10f, hit.binLow);
    assertEquals(20f, hit.binHigh);
  }

  @Test
  void hitTest_isNull_outsideTheBoxHorizontally () {
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.probsHoverBoxes = new java.util.ArrayList<>();
    app.STUDY.probsHoverBoxes.add(makeBox(90, 50, 110, 150, 10, 20));

    assertNull(app.studyProbsHover_hitTest(200, 100));
  }

  @Test
  void hitTest_isNull_outsideTheBoxVertically () {
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.probsHoverBoxes = new java.util.ArrayList<>();
    app.STUDY.probsHoverBoxes.add(makeBox(90, 50, 110, 150, 10, 20));

    assertNull(app.studyProbsHover_hitTest(100, 1000));
  }

  @Test
  void hitTest_doesNotAssumeTheRectanglesOwnCornerOrdering () {
    // screenX1 (110) > screenX2 (90) and screenY1 (150) > screenY2 (50) -
    // both reversed from the "usual" order - must still work, since the
    // hit-test uses min()/max() rather than assuming which corner is which.
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.probsHoverBoxes = new java.util.ArrayList<>();
    app.STUDY.probsHoverBoxes.add(makeBox(110, 150, 90, 50, 10, 20));

    assertNotNull(app.studyProbsHover_hitTest(100, 100));
  }

  @Test
  void hitTest_picksWhicheverBoxTheMouseActuallyFallsInside_amongSeveral () {
    // Two non-overlapping boxes stacked vertically (as drawProbs() draws
    // adjacent bins) - the hit-test must check every entry, not only the
    // first, to find the one the mouse is actually over.
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.probsHoverBoxes = new java.util.ArrayList<>();
    app.STUDY.probsHoverBoxes.add(makeBox(90, 0, 110, 50, 20, 30));
    app.STUDY.probsHoverBoxes.add(makeBox(90, 50, 110, 100, 10, 20));

    solarchvision_bim.ProbsHoverBox hit = app.studyProbsHover_hitTest(100, 75);

    assertNotNull(hit);
    assertEquals(10f, hit.binLow);
    assertEquals(20f, hit.binHigh);
  }

  @Test
  void hitTest_isNull_whenNothingHasBeenRecordedYet () {
    app.STUDY.probsHoverBoxes = null;
    assertDoesNotThrow(() -> assertNull(app.studyProbsHover_hitTest(100, 100)));
  }

  @Test
  void hitTest_respectsImageScale_scalingMouseCoordinatesIntoGraphicsSpace () {
    // Same inverse-transform convention as studyNormalsHover_hitTest()
    // and every other STUDY hover hit-test this session - screen mouse
    // coordinates get mapped into this.graphics' own device-pixel space
    // via (mouse - cX/cY) * ImageScale before comparing against a box's
    // own screenX/screenY, which are already recorded in that same space.
    app.STUDY.cX = 10;
    app.STUDY.cY = 20;
    app.STUDY.ImageScale = 2;
    app.STUDY.probsHoverBoxes = new java.util.ArrayList<>();
    // A box recorded in graphics space at x=[180,220], y=[160,260].
    app.STUDY.probsHoverBoxes.add(makeBox(180, 160, 220, 260, 10, 20));

    // Screen mouse at (110, 120) -> graphics space: ((110-10)*2, (120-20)*2) = (200, 200), inside the box above.
    assertNotNull(app.studyProbsHover_hitTest(110, 120));
    // Screen mouse at (200, 120) -> graphics space: (380, 200), well outside.
    assertNull(app.studyProbsHover_hitTest(200, 120));
  }
}
