import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.util.ArrayList;

// Covers this session's "close button on each hover box" feature
// (hover.pde/mouseClicked.pde): removeHoverPoint(int[]) (removal by
// identity, for a close button rather than Esc's always-most-recent
// removeLastHoverPoint()), hoverCloseButtonRect() (the one place the
// button's own geometry is computed - pure, no live graphics needed,
// same reasoning as hoverBoxPosition()/resolveHoverBoxPosition()
// elsewhere in this file), queueHoverBox()'s widening of a pinned box to
// make room for that button and the box.sourceHoverPoint tagging that
// goes with it, and hoverPointAtCloseButton()/hoverPointAtCloseButtonIn()
// (the hit-test counterpart mouseClicked.pde calls). drawHover()/
// drawPaletteHover()'s own drawing of the button, and mouseClicked()'s
// own end-to-end dispatch, both touch live graphics/mouse state and
// aren't covered here - same boundary PlaceHoversAtTest.java/
// ClearHoverTest.java already draw for the rest of this file.
class HoverCloseButtonTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  private solarchvision_bim.PendingHoverBox pinnedBox (float x, float y, float w, float h, int[] sourceRow) {
    solarchvision_bim.PendingHoverBox box = app.new PendingHoverBox();
    box.x = x;
    box.y = y;
    box.w = w;
    box.h = h;
    box.sourceHoverPoint = sourceRow;
    return box;
  }

  // ================= removeHoverPoint (by identity) =======================

  @Test
  void removeHoverPoint_returnsFalse_whenThereAreNoPointsAtAll () {
    assertNull(app.allHoverPoints);
    assertFalse(app.removeHoverPoint(new int[]{1, 1}));
  }

  @Test
  void removeHoverPoint_returnsFalse_forANullRow () {
    app.addHoverPoint(1, 1);
    assertFalse(app.removeHoverPoint(null));
    assertEquals(1, app.allHoverPoints.length); // untouched
  }

  @Test
  void removeHoverPoint_returnsFalse_forAnEqualValuedButDistinctRow () {
    // Object identity, not value equality - a row with the same x,y that
    // was never actually returned by addHoverPoint() for THIS point must
    // not match (same reasoning as HoverPointsTest.java's own
    // add_distinguishesTwoPinsAtTheSameCoordinates_byRowIdentityNotValue).
    app.addHoverPoint(5, 5);

    assertFalse(app.removeHoverPoint(new int[]{5, 5}));
    assertEquals(1, app.allHoverPoints.length);
  }

  @Test
  void removeHoverPoint_removesTheMatchingRow_leavingOthersInOrder () {
    app.addHoverPoint(1, 1);
    int[] middle = app.addHoverPoint(2, 2);
    app.addHoverPoint(3, 3);

    assertTrue(app.removeHoverPoint(middle));

    assertEquals(2, app.allHoverPoints.length);
    assertArrayEquals(new int[]{1, 1}, app.allHoverPoints[0]);
    assertArrayEquals(new int[]{3, 3}, app.allHoverPoints[1]);
  }

  @Test
  void removeHoverPoint_worksRegardlessOfPositionInTheList_notJustTheLast () {
    int[] first = app.addHoverPoint(1, 1);
    app.addHoverPoint(2, 2);
    app.addHoverPoint(3, 3);

    assertTrue(app.removeHoverPoint(first));

    assertEquals(2, app.allHoverPoints.length);
    assertArrayEquals(new int[]{2, 2}, app.allHoverPoints[0]);
    assertArrayEquals(new int[]{3, 3}, app.allHoverPoints[1]);
  }

  @Test
  void removeHoverPoint_setsTheListBackToNull_onceTheOnlyPointIsRemoved () {
    int[] row = app.addHoverPoint(5, 5);

    assertTrue(app.removeHoverPoint(row));

    assertNull(app.allHoverPoints);
  }

  @Test
  void removeHoverPoint_cleansUpThePreferredPositionOfTheRowItRemoves () {
    int[] row = app.addHoverPoint(10, 20, new float[]{5, 5});

    app.removeHoverPoint(row);

    assertFalse(app.hoverPointPreferredPosition.containsKey(row));
  }

  @Test
  void removeHoverPoint_cleansUpTheWorldGeoEntryOfTheRowItRemoves () {
    int[] row = app.addHoverPoint(10, 20);
    app.worldHoverPointGeo.put(row, new float[]{-79, 43});

    app.removeHoverPoint(row);

    assertFalse(app.worldHoverPointGeo.containsKey(row));
  }

  // ================= hoverCloseButtonRect ==================================
  // Pure geometry, hand-computed from hover.pde's own constants
  // (hoverCloseButtonSize=14, hoverStrokeInset=ceil(0.5*hoverStrokeWeight(4)+1)=3) -
  // the one place this is computed, shared by the draw side (drawHover()/
  // drawPaletteHover(), not covered here) and the hit-test side
  // (hoverPointAtCloseButton(), below). box.w here is the box's own
  // RESERVED width (queueHoverBox()'s own effectiveBoxW, which already
  // includes room for this button) - flush with its right edge, so the
  // button lands just past the box's own (narrower) drawn content border,
  // outside it rather than inside.

  @Test
  void hoverCloseButtonRect_isFlushWithTheBoxsOwnReservedRightEdge () {
    solarchvision_bim.PendingHoverBox box = pinnedBox(100, 200, 80, 40, new int[]{1, 1});

    float[] rect = app.hoverCloseButtonRect(box);

    float expectedX = 100 + 80 - app.hoverCloseButtonSize; // 100+80-14 = 166
    float expectedY = 200 + app.hoverStrokeInset + 1; // 200+3+1 = 204
    assertEquals(expectedX, rect[0], 0.001f);
    assertEquals(expectedY, rect[1], 0.001f);
    assertEquals((float) app.hoverCloseButtonSize, rect[2], 0.001f);
    assertEquals((float) app.hoverCloseButtonSize, rect[3], 0.001f);
  }

  @Test
  void hoverCloseButtonRect_sitsOutsideTheBoxsOwnDrawnContentBorder () {
    // drawHover()'s own boxW (not box.w) is the content width actually
    // drawn - box.w minus the reserved gap+button column. The button's
    // own left edge must fall at or past that narrower content border's
    // right edge, with the gap between them, never inside it.
    solarchvision_bim.PendingHoverBox box = pinnedBox(100, 200, 80, 40, new int[]{1, 1});
    float contentW = box.w - app.hoverCloseButtonGap - app.hoverCloseButtonSize;
    float contentRightEdge = box.x + contentW;

    float[] rect = app.hoverCloseButtonRect(box);

    assertEquals(contentRightEdge + app.hoverCloseButtonGap, rect[0], 0.001f);
  }

  @Test
  void hoverCloseButtonRect_tracksTheBoxsOwnPosition () {
    solarchvision_bim.PendingHoverBox boxA = pinnedBox(0, 0, 50, 20, new int[]{1, 1});
    solarchvision_bim.PendingHoverBox boxB = pinnedBox(500, 500, 50, 20, new int[]{1, 1});

    float[] rectA = app.hoverCloseButtonRect(boxA);
    float[] rectB = app.hoverCloseButtonRect(boxB);

    assertEquals(500f, rectB[0] - rectA[0], 0.001f);
    assertEquals(500f, rectB[1] - rectA[1], 0.001f);
  }

  // ================= queueHoverBox: widening + sourceHoverPoint tagging ===

  @Test
  void queueHoverBox_withNoCurrentSourceRow_leavesTheBoxAtItsTextWidth () {
    ArrayList<float[]> placedBoxes = new ArrayList<float[]>();
    ArrayList<solarchvision_bim.PendingHoverBox> pendingBoxes = new ArrayList<solarchvision_bim.PendingHoverBox>();
    assertNull(app.currentHoverSourceRow, "test precondition: the bare default");

    app.queueHoverBox(10, 10, new String[]{"a"}, 50, 20, 0, 0, 1000, 1000, placedBoxes, pendingBoxes);

    assertEquals(50f, pendingBoxes.get(0).w, 0.001f); // unwidened
    assertNull(pendingBoxes.get(0).sourceHoverPoint);
  }

  @Test
  void queueHoverBox_withACurrentSourceRow_widensTheBoxAndTagsIt () {
    ArrayList<float[]> placedBoxes = new ArrayList<float[]>();
    ArrayList<solarchvision_bim.PendingHoverBox> pendingBoxes = new ArrayList<solarchvision_bim.PendingHoverBox>();
    int[] row = {42, 42};
    app.currentHoverSourceRow = row;

    app.queueHoverBox(10, 10, new String[]{"a"}, 50, 20, 0, 0, 1000, 1000, placedBoxes, pendingBoxes);

    float expectedW = 50 + app.hoverCloseButtonGap + app.hoverCloseButtonSize;
    assertEquals(expectedW, pendingBoxes.get(0).w, 0.001f);
    assertSame(row, pendingBoxes.get(0).sourceHoverPoint);
  }

  @Test
  void queueHoverBox_widenedWidthIsAlsoWhatsRecordedInPlacedBoxes () {
    // placedBoxes feeds collision-avoidance for every box resolved after
    // this one in the same pass - if it recorded the UNwidened width,
    // a later box could be placed close enough to overlap this one's
    // close button.
    ArrayList<float[]> placedBoxes = new ArrayList<float[]>();
    ArrayList<solarchvision_bim.PendingHoverBox> pendingBoxes = new ArrayList<solarchvision_bim.PendingHoverBox>();
    app.currentHoverSourceRow = new int[]{1, 1};

    app.queueHoverBox(10, 10, new String[]{"a"}, 50, 20, 0, 0, 1000, 1000, placedBoxes, pendingBoxes);

    float expectedW = 50 + app.hoverCloseButtonGap + app.hoverCloseButtonSize;
    assertEquals(expectedW, placedBoxes.get(0)[2], 0.001f);
  }

  // ================= drawHoverPinAt: currentHoverSourceRow bracket ========

  @Test
  void drawHoverPinAt_clearsCurrentHoverSourceRowAfterward () {
    // On a bare app every placeHoversAt() sub-dispatcher's own guard
    // fires immediately (PlaceHoversAtTest.java's own
    // placeHoversAt_onABareApp_doesNotThrow), so nothing is actually
    // queued here - this only checks the set/clear bracket itself
    // doesn't leak the global past the call that set it, the same
    // currentHoverPreferredPosition already does.
    int[] row = {7, 7};

    assertDoesNotThrow(() -> app.drawHoverPinAt(row));

    assertNull(app.currentHoverSourceRow);
    assertNull(app.currentHoverPreferredPosition);
  }

  // ================= hoverPointAtCloseButton / hoverPointAtCloseButtonIn ==

  @Test
  void hoverPointAtCloseButtonIn_returnsNull_forANullQueue () {
    assertNull(app.hoverPointAtCloseButtonIn(null, 10, 10));
  }

  @Test
  void hoverPointAtCloseButtonIn_returnsNull_whenNoBoxHasACloseButton () {
    // A live box (sourceHoverPoint == null) is never clickable this way,
    // even if the click would otherwise land inside its own would-be
    // button rect.
    ArrayList<solarchvision_bim.PendingHoverBox> queue = new ArrayList<solarchvision_bim.PendingHoverBox>();
    solarchvision_bim.PendingHoverBox liveBox = pinnedBox(100, 100, 80, 40, null);
    queue.add(liveBox);

    float[] btn = app.hoverCloseButtonRect(liveBox);
    int mx = (int) (btn[0] + btn[2] / 2);
    int my = (int) (btn[1] + btn[3] / 2);

    assertNull(app.hoverPointAtCloseButtonIn(queue, mx, my));
  }

  @Test
  void hoverPointAtCloseButtonIn_returnsNull_whenTheClickMissesTheButton () {
    int[] row = {1, 1};
    ArrayList<solarchvision_bim.PendingHoverBox> queue = new ArrayList<solarchvision_bim.PendingHoverBox>();
    queue.add(pinnedBox(100, 100, 80, 40, row));

    // Well inside the box overall, but nowhere near its own close button
    // (top-right corner) - e.g. the box's own bottom-left corner.
    assertNull(app.hoverPointAtCloseButtonIn(queue, 101, 139));
  }

  @Test
  void hoverPointAtCloseButtonIn_returnsTheRow_whenTheClickLandsInsideTheButton () {
    int[] row = {1, 1};
    solarchvision_bim.PendingHoverBox box = pinnedBox(100, 100, 80, 40, row);
    ArrayList<solarchvision_bim.PendingHoverBox> queue = new ArrayList<solarchvision_bim.PendingHoverBox>();
    queue.add(box);

    float[] btn = app.hoverCloseButtonRect(box);
    int mx = (int) (btn[0] + btn[2] / 2);
    int my = (int) (btn[1] + btn[3] / 2);

    assertSame(row, app.hoverPointAtCloseButtonIn(queue, mx, my));
  }

  @Test
  void hoverPointAtCloseButton_checksStudyThenWin3DThenWorld_andFindsAMatchInAnyOfThem () {
    int[] worldRow = {9, 9};
    solarchvision_bim.PendingHoverBox worldBox = pinnedBox(300, 300, 80, 40, worldRow);
    app.worldPendingHoverBoxes = new ArrayList<solarchvision_bim.PendingHoverBox>();
    app.worldPendingHoverBoxes.add(worldBox);

    app.studyPendingHoverBoxes = new ArrayList<solarchvision_bim.PendingHoverBox>(); // empty
    app.win3DPendingHoverBoxes = new ArrayList<solarchvision_bim.PendingHoverBox>(); // empty

    float[] btn = app.hoverCloseButtonRect(worldBox);
    int mx = (int) (btn[0] + btn[2] / 2);
    int my = (int) (btn[1] + btn[3] / 2);

    assertSame(worldRow, app.hoverPointAtCloseButton(mx, my));
  }

  @Test
  void hoverPointAtCloseButton_returnsNull_whenNothingMatchesInAnyQueue () {
    app.studyPendingHoverBoxes = new ArrayList<solarchvision_bim.PendingHoverBox>();
    app.win3DPendingHoverBoxes = new ArrayList<solarchvision_bim.PendingHoverBox>();
    app.worldPendingHoverBoxes = new ArrayList<solarchvision_bim.PendingHoverBox>();

    assertNull(app.hoverPointAtCloseButton(10, 10));
  }
}
