import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.util.ArrayList;

// queueHoverBox() (hover.pde) is the pure box-placement/bookkeeping half
// of queueHover()/queuePaletteHover(), split out specifically so it can
// be unit-tested directly: given an already-computed boxW/boxH (instead
// of measuring real text via textSize()/textWidth()/textAscent()/
// textDescent(), none of which work without a live font/graphics
// context), it resolves a position via resolveHoverBoxPosition() -
// already separately covered elsewhere (HoverBoxCollisionTest.java) -
// and records the result into placedBoxes/pendingBoxes. Both overloads
// (with and without a palette color) were new with that split and
// started at 0% coverage.
//
// Every test below uses an EMPTY placedBoxes list and the bare-
// construction default currentHoverPreferredPosition (null), so
// resolveHoverBoxPosition() takes its own simplest path: no collision to
// dodge (an empty placedBoxes list short-circuits that check
// immediately), and no remembered preferred position, so the result is
// exactly hoverBoxPosition()'s own natural placement - hand-computed
// below from hover.pde's own constants (hoverMargin=14, hoverStrokeInset
// = ceil(0.5*hoverStrokeWeight(4)+1) = 3).
class QueueHoverBoxTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // xMouse/yMouse close to destX/destY (top-left quadrant: (xMouse -
  // destX) <= destW/2 and (yMouse - destY) <= destH/2) puts the box
  // below-and-right of the cursor: boxX = xMouse + hoverMargin, boxY =
  // yMouse + hoverMargin - then clamped into the dest rect, which (with
  // these dest dimensions) never actually changes anything: boxX = 10 +
  // 14 = 24 (clamp range [3, 947]); boxY = 24 (clamp range [3, 977]).
  private static final float EXPECTED_X = 24f;
  private static final float EXPECTED_Y = 24f;

  @Test
  void placesTheBoxAtItsNaturalPositionAndRecordsItInPlacedBoxes () {
    ArrayList<float[]> placedBoxes = new ArrayList<float[]>();
    ArrayList<solarchvision_bim.PendingHoverBox> pendingBoxes = new ArrayList<solarchvision_bim.PendingHoverBox>();
    String[] lines = {"a test line"};

    app.queueHoverBox(10, 10, lines, 50, 20, 0, 0, 1000, 1000, placedBoxes, pendingBoxes);

    assertEquals(1, placedBoxes.size());
    assertArrayEquals(new float[]{EXPECTED_X, EXPECTED_Y, 50, 20}, placedBoxes.get(0), 0.001f);
  }

  @Test
  void queuesAPendingBoxWithEveryFieldSetFromItsArguments () {
    ArrayList<float[]> placedBoxes = new ArrayList<float[]>();
    ArrayList<solarchvision_bim.PendingHoverBox> pendingBoxes = new ArrayList<solarchvision_bim.PendingHoverBox>();
    String[] lines = {"a test line"};

    app.queueHoverBox(10, 10, lines, 50, 20, 0, 0, 1000, 1000, placedBoxes, pendingBoxes);

    assertEquals(1, pendingBoxes.size());
    solarchvision_bim.PendingHoverBox box = pendingBoxes.get(0);
    assertEquals(EXPECTED_X, box.x, 0.001f);
    assertEquals(EXPECTED_Y, box.y, 0.001f);
    assertEquals(50f, box.w, 0.001f);
    assertEquals(20f, box.h, 0.001f);
    assertEquals(10, box.xMouse);
    assertEquals(10, box.yMouse);
    assertSame(lines, box.lines);
    assertNull(box.col, "the no-color overload must leave col null");
    assertFalse(box.isLivePoint, "resolvingLiveHoverPoint's own bare-construction default is false");
  }

  @Test
  void theColorOverload_setsColOnThePendingBox () {
    ArrayList<float[]> placedBoxes = new ArrayList<float[]>();
    ArrayList<solarchvision_bim.PendingHoverBox> pendingBoxes = new ArrayList<solarchvision_bim.PendingHoverBox>();
    float[] col = {255, 200, 100, 50}; // {alpha, r, g, b} - PAINT.getColorStyle()'s own order

    app.queueHoverBox(10, 10, new String[]{"swatch"}, 50, 20, 0, 0, 1000, 1000, col, placedBoxes, pendingBoxes);

    assertSame(col, pendingBoxes.get(0).col);
  }

  @Test
  void resolvingLiveHoverPoint_isRecordedOnThePendingBox () {
    ArrayList<float[]> placedBoxes = new ArrayList<float[]>();
    ArrayList<solarchvision_bim.PendingHoverBox> pendingBoxes = new ArrayList<solarchvision_bim.PendingHoverBox>();
    app.resolvingLiveHoverPoint = true;

    app.queueHoverBox(10, 10, new String[]{"a"}, 50, 20, 0, 0, 1000, 1000, placedBoxes, pendingBoxes);

    assertTrue(pendingBoxes.get(0).isLivePoint);
  }

  @Test
  void aNullPlacedBoxesList_isSkippedWithoutError_pendingBoxesStillQueued () {
    ArrayList<solarchvision_bim.PendingHoverBox> pendingBoxes = new ArrayList<solarchvision_bim.PendingHoverBox>();

    assertDoesNotThrow(() ->
        app.queueHoverBox(10, 10, new String[]{"a"}, 50, 20, 0, 0, 1000, 1000, null, pendingBoxes));

    assertEquals(1, pendingBoxes.size());
  }

  @Test
  void aNullPendingBoxesList_isSkippedWithoutError_placedBoxesStillRecorded () {
    ArrayList<float[]> placedBoxes = new ArrayList<float[]>();

    assertDoesNotThrow(() ->
        app.queueHoverBox(10, 10, new String[]{"a"}, 50, 20, 0, 0, 1000, 1000, placedBoxes, null));

    assertEquals(1, placedBoxes.size());
  }

  @Test
  void aPreferredPosition_isUsedInsteadOfTheNaturalPlacement () {
    // hoverClampAxis(100, 0, 1000, 50, 3) = constrain(100, 3, 947) = 100
    // (same, unclamped, for Y with boxH=20) - distinct from the natural
    // (24, 24) every other test above computes, confirming this path -
    // not hoverBoxPosition() - is the one actually used here.
    ArrayList<float[]> placedBoxes = new ArrayList<float[]>();
    ArrayList<solarchvision_bim.PendingHoverBox> pendingBoxes = new ArrayList<solarchvision_bim.PendingHoverBox>();
    app.currentHoverPreferredPosition = new float[]{100, 100};

    app.queueHoverBox(10, 10, new String[]{"a"}, 50, 20, 0, 0, 1000, 1000, placedBoxes, pendingBoxes);

    assertEquals(100f, pendingBoxes.get(0).x, 0.001f);
    assertEquals(100f, pendingBoxes.get(0).y, 0.001f);
  }
}
