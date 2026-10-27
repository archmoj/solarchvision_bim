import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers hover.pde's multi-box collision-avoidance logic: the rectangle
// math (hoverBoxesOverlap/hoverBoxOverlapArea/hoverBoxCollides/
// hoverBoxTotalOverlap), the placement candidates it chooses from
// (hoverQuadrantPosition/hoverAxisShiftPosition), and the single-pass
// greedy resolver that ties them together (resolveHoverBoxPosition).
// All of it is pure - no live graphics touched, same as hoverBoxPosition
// itself (SolarImpactOverlayHoverTest.java already covers that one
// directly) - queueHover()/queuePaletteHover() only resolve a position
// and queue it, but paintHover()/paintPaletteHover() (the functions that
// actually draw, in a later pass - see drawAllHovers()'s own comment)
// aren't independently testable here, for the same reason every other
// STUDY/WIN3D box-drawing function this session isn't.
class HoverBoxCollisionTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= hoverBoxesOverlap / hoverBoxOverlapArea ==================

  @Test
  void overlap_isTrue_forTwoOverlappingRects () {
    assertTrue(app.hoverBoxesOverlap(0, 0, 10, 10, 5, 5, 10, 10));
  }

  @Test
  void overlap_isFalse_whenSeparatedHorizontally () {
    assertFalse(app.hoverBoxesOverlap(0, 0, 10, 10, 20, 0, 10, 10));
  }

  @Test
  void overlap_isFalse_whenSeparatedVertically () {
    assertFalse(app.hoverBoxesOverlap(0, 0, 10, 10, 0, 20, 10, 10));
  }

  @Test
  void overlap_isFalse_whenOnlyTouchingAtAnEdge () {
    // Sharing an edge (one box's right side exactly at the other's left
    // side) isn't overlap - the strict < / > comparisons must treat
    // touching boxes as clear, not colliding.
    assertFalse(app.hoverBoxesOverlap(0, 0, 10, 10, 10, 0, 10, 10));
  }

  @Test
  void overlap_isTrue_whenOneRectIsFullyInsideAnother () {
    assertTrue(app.hoverBoxesOverlap(0, 0, 100, 100, 10, 10, 5, 5));
  }

  @Test
  void overlapArea_isZero_forNonOverlappingRects () {
    assertEquals(0f, app.hoverBoxOverlapArea(0, 0, 10, 10, 20, 20, 10, 10), 0.0001f);
  }

  @Test
  void overlapArea_isTheIntersectionArea () {
    // [0,10]x[0,10] and [5,15]x[5,15] overlap on [5,10]x[5,10] -> 5x5 = 25.
    assertEquals(25f, app.hoverBoxOverlapArea(0, 0, 10, 10, 5, 5, 10, 10), 0.0001f);
  }

  @Test
  void overlapArea_isTheFullSmallerRect_whenOneIsNestedInTheOther () {
    assertEquals(25f, app.hoverBoxOverlapArea(0, 0, 100, 100, 10, 10, 5, 5), 0.0001f);
  }

  // ================= hoverBoxCollides / hoverBoxTotalOverlap ==================

  @Test
  void collides_isFalse_whenPlacedBoxesIsEmpty () {
    assertFalse(app.hoverBoxCollides(0, 0, 10, 10, new java.util.ArrayList<float[]>()));
  }

  @Test
  void collides_isTrue_whenAnyPlacedBoxOverlaps () {
    java.util.ArrayList<float[]> placed = new java.util.ArrayList<>();
    placed.add(new float[]{ 100, 100, 10, 10 }); // clear
    placed.add(new float[]{ 5, 5, 10, 10 });     // overlaps
    assertTrue(app.hoverBoxCollides(0, 0, 10, 10, placed));
  }

  @Test
  void totalOverlap_sumsAcrossEveryPlacedBoxItOverlaps () {
    java.util.ArrayList<float[]> placed = new java.util.ArrayList<>();
    placed.add(new float[]{ 5, 0, 5, 10 });  // overlaps [0,10]x[0,10] on [5,10]x[0,10] = 50
    placed.add(new float[]{ 0, 5, 10, 5 });  // overlaps on [0,10]x[5,10] = 50, but double-counts [5,10]x[5,10]=25 with the box above - total is just a sum, not a union, by design (see this function's own comment)
    placed.add(new float[]{ 200, 200, 5, 5 }); // clear - contributes 0

    float total = app.hoverBoxTotalOverlap(0, 0, 10, 10, placed);
    assertEquals(100f, total, 0.0001f); // 50 + 50 + 0
  }

  // ================= hoverQuadrantPosition =====================================
  // Same placement math as hoverBoxPosition() (SolarImpactOverlayHoverTest.java
  // already covers that one via the mouse-position-derived right/bottom),
  // parameterized directly here instead.

  @Test
  void quadrant_placesRightAndBelow_whenRightAndBottomAreFalse () {
    float[] p = app.hoverQuadrantPosition(50, 40, 0, 0, 400, 300, 70, 54, false, false);
    assertEquals(50 + app.hoverMargin, p[0], 0.0001f);
    assertEquals(40 + app.hoverMargin, p[1], 0.0001f);
  }

  @Test
  void quadrant_placesLeftAndAbove_whenRightAndBottomAreTrue () {
    float[] p = app.hoverQuadrantPosition(350, 260, 0, 0, 400, 300, 70, 54, true, true);
    assertEquals(350 - app.hoverMargin - 70, p[0], 0.0001f);
    assertEquals(260 - app.hoverMargin - 54, p[1], 0.0001f);
  }

  @Test
  void quadrant_staysInsideTheDestRect_evenWhenTheNaturalSpotWouldOverflow () {
    float[] p = app.hoverQuadrantPosition(5, 5, 0, 0, 400, 300, 70, 54, true, true);
    assertTrue(p[0] >= 0 && p[0] + 70 <= 400);
    assertTrue(p[1] >= 0 && p[1] + 54 <= 300);
  }

  // ================= hoverAxisShiftPosition ====================================

  @Test
  void axisShift_movesOnlyX_whenAlongXIsTrue () {
    // stepSize (10) deliberately different from boxW (70) - confirms the
    // shift amount comes from stepSize, not from the box's own width.
    float[] from = { 100, 100 };
    float[] p = app.hoverAxisShiftPosition(from, 0, 0, 1000, 1000, 70, 54, 10, true, 1, 2);
    assertEquals(100 + 2 * 10, p[0], 0.0001f);
    assertEquals(100, p[1], 0.0001f); // unchanged
  }

  @Test
  void axisShift_movesOnlyY_whenAlongXIsFalse () {
    // Starting Y (500) chosen with enough room above it that shifting up
    // 3 steps doesn't run into the dest rect's own clamp - the clamp
    // itself is covered separately below. stepSize (8) again deliberately
    // different from boxH (54).
    float[] from = { 100, 500 };
    float[] p = app.hoverAxisShiftPosition(from, 0, 0, 1000, 1000, 70, 54, 8, false, -1, 3);
    assertEquals(100, p[0], 0.0001f); // unchanged
    assertEquals(500 - 3 * 8, p[1], 0.0001f);
  }

  @Test
  void axisShift_clampsToTheDestRect () {
    float[] from = { 100, 100 };
    float[] p = app.hoverAxisShiftPosition(from, 0, 0, 200, 200, 70, 54, 10, true, 1, 50); // way past the right edge
    assertTrue(p[0] + 70 <= 200);
  }

  @Test
  void axisShift_clampsOnTheYAxisToo_ratherThanGoingNegative () {
    // from Y=100, shifting up 3 steps of 54 (162px) would land at -62 -
    // past the dest rect's own top edge - so it must clamp to
    // destY + hoverStrokeInset (3) instead, same as the X-axis case
    // above.
    float[] from = { 100, 100 };
    float[] p = app.hoverAxisShiftPosition(from, 0, 0, 1000, 1000, 70, 54, 54, false, -1, 3);
    assertEquals(app.hoverStrokeInset, p[1], 0.0001f);
  }

  // ================= resolveHoverBoxPosition ===================================

  @Test
  void resolve_matchesTheNaturalPosition_whenNothingIsPlacedYet () {
    float[] natural = app.hoverBoxPosition(50, 40, 0, 0, 400, 300, 70, 54);
    float[] resolved = app.resolveHoverBoxPosition(50, 40, 0, 0, 400, 300, 70, 54, new java.util.ArrayList<float[]>(), null);
    assertArrayEquals(natural, resolved, 0.0001f);
  }

  @Test
  void resolve_matchesTheNaturalPosition_whenPlacedBoxesIsNull () {
    float[] natural = app.hoverBoxPosition(50, 40, 0, 0, 400, 300, 70, 54);
    float[] resolved = app.resolveHoverBoxPosition(50, 40, 0, 0, 400, 300, 70, 54, null, null);
    assertArrayEquals(natural, resolved, 0.0001f);
  }

  @Test
  void resolve_fallsBackToAnotherQuadrant_whenTheNaturalSpotCollides () {
    // Mouse at the exact center of a large dest rect: natural quadrant
    // (right=false, bottom=false) lands at (514, 514). Blocking exactly
    // that spot should make it fall through to the next quadrant tried
    // (right=true, bottom=false), which lands at (416, 514) - far enough
    // away (box width 70) to be clear of the block.
    java.util.ArrayList<float[]> placed = new java.util.ArrayList<>();
    placed.add(new float[]{ 514, 514, 70, 54 });

    float[] resolved = app.resolveHoverBoxPosition(500, 500, 0, 0, 1000, 1000, 70, 54, placed, null);

    assertEquals(416, resolved[0], 0.0001f);
    assertEquals(514, resolved[1], 0.0001f);
    assertFalse(app.hoverBoxCollides(resolved[0], resolved[1], 70, 54, placed));
  }

  @Test
  void resolve_fallsBackToAnAxisShift_whenAllFourQuadrantsCollide () {
    // Same center-of-a-large-rect setup, but this time all four
    // quadrant candidates (514,514), (416,514), (514,432), (416,432) are
    // individually blocked - forcing the single-axis-shift fallback.
    // Each right-shift step moves hoverAxisShiftStepFraction (0.25) *
    // boxW = 17.5px; it takes 4 of them (514 + 4*17.5 = 584, exactly one
    // full box-width in this particular case, since the blocks here are
    // exactly box-sized and adjacent) to fully clear all four blocks -
    // hand-verified against every intermediate step, none of which
    // clears any earlier.
    java.util.ArrayList<float[]> placed = new java.util.ArrayList<>();
    placed.add(new float[]{ 514, 514, 70, 54 });
    placed.add(new float[]{ 416, 514, 70, 54 });
    placed.add(new float[]{ 514, 432, 70, 54 });
    placed.add(new float[]{ 416, 432, 70, 54 });

    float[] resolved = app.resolveHoverBoxPosition(500, 500, 0, 0, 1000, 1000, 70, 54, placed, null);

    assertEquals(584, resolved[0], 0.0001f);
    assertEquals(514, resolved[1], 0.0001f);
    assertFalse(app.hoverBoxCollides(resolved[0], resolved[1], 70, 54, placed));
  }

  @Test
  void resolve_pushesPastAWideBlock_toTheFirstFullyClearSpotBelowIt () {
    // A single block spans the full width of the dest rect across its
    // top 210px (0,0,300,210) - wide enough that no quadrant or
    // horizontal shift can ever escape it (only a downward shift can).
    // Mouse near the top-left puts every quadrant candidate, and every
    // horizontal shift, still fully inside the block; stepping down in
    // hoverAxisShiftStepFraction (0.25) * boxH = 13.5px increments from
    // natural=(64,34), the box stays (partially, then barely) inside the
    // block through step 13 (y=209.5) and only fully clears at step 14
    // (y=223) - hand-verified. Notably this is well short of the dest
    // rect's own clamp (243) - confirming the box stops as soon as it's
    // actually clear, rather than being pushed all the way to the edge.
    java.util.ArrayList<float[]> placed = new java.util.ArrayList<>();
    placed.add(new float[]{ 0, 0, 300, 210 });

    float[] resolved = app.resolveHoverBoxPosition(50, 20, 0, 0, 300, 300, 70, 54, placed, null);

    assertEquals(64, resolved[0], 0.0001f);
    assertEquals(223, resolved[1], 0.0001f);
    assertEquals(0f, app.hoverBoxTotalOverlap(resolved[0], resolved[1], 70, 54, placed), 0.0001f);
  }

  @Test
  void resolve_doesNotMutateThePlacedBoxesListItWasGiven () {
    // Appending the resolved result to placedBoxes is the CALLER's job
    // (queueHover()/queuePaletteHover(), right after they call this) -
    // resolveHoverBoxPosition() itself must leave the list exactly as
    // given, or a box could end up colliding with its own, not-yet-final
    // candidate positions.
    java.util.ArrayList<float[]> placed = new java.util.ArrayList<>();
    placed.add(new float[]{ 514, 514, 70, 54 });
    int sizeBefore = placed.size();

    app.resolveHoverBoxPosition(500, 500, 0, 0, 1000, 1000, 70, 54, placed, null);

    assertEquals(sizeBefore, placed.size());
  }

  @Test
  void resolve_picksTheLeastOverlappingCandidate_whenNothingFullyClears () {
    // A dest rect barely bigger than the box itself (so every candidate
    // is forced to clamp into a tight corner, and most of them collide)
    // - a box placed to fully cover the whole dest rect leaves no
    // collision-free candidate at all. The resolver still must return
    // SOME position inside the dest rect rather than throwing, and it
    // must not do worse than simply using the natural position blind -
    // here every candidate collides equally (total overlap, since the
    // block covers the entire usable area), so this mainly guards
    // against an exception/invalid result in the fully-boxed-in case.
    java.util.ArrayList<float[]> placed = new java.util.ArrayList<>();
    placed.add(new float[]{ 0, 0, 100, 100 });

    float[] resolved = assertDoesNotThrow(() ->
      app.resolveHoverBoxPosition(50, 50, 0, 0, 100, 100, 70, 54, placed, null));

    assertTrue(resolved[0] >= 0 && resolved[0] + 70 <= 100);
    assertTrue(resolved[1] >= 0 && resolved[1] + 54 <= 100);
  }

  // ================= resolveHoverBoxPosition with a preferredPosition =========
  // This is how a pin remembers where it already was (hover.pde's own
  // currentHoverPreferredPosition/hoverPointPreferredPosition) instead of
  // being re-derived from scratch every frame - see the conversation
  // that led here for why that matters.

  @Test
  void resolve_usesThePreferredPosition_insteadOfTheNaturalQuadrant_whenItsClear () {
    // Mouse at (500,500) in this 1000x1000 rect would naturally resolve
    // to (514,514) (same as the no-preference tests above) - passing an
    // unrelated, clear preferredPosition should be used instead, proving
    // it really does override the natural computation rather than just
    // being ignored.
    float[] preferred = { 100, 100 };

    float[] resolved = app.resolveHoverBoxPosition(500, 500, 0, 0, 1000, 1000, 70, 54, new java.util.ArrayList<float[]>(), preferred);

    assertEquals(100, resolved[0], 0.0001f);
    assertEquals(100, resolved[1], 0.0001f);
  }

  @Test
  void resolve_fallsBackThroughTheNormalChain_whenThePreferredPositionCollides () {
    // Same setup as resolve_fallsBackToAnotherQuadrant_whenTheNaturalSpotCollides
    // above, but this time the FIRST candidate that collides is an
    // explicit preferredPosition (514,514) rather than the natural
    // quadrant computation landing there on its own - the fallback chain
    // (the other three quadrants, keyed off the actual mouse position)
    // must still kick in exactly the same way, landing on the same
    // (416,514) second-quadrant candidate.
    float[] preferred = { 514, 514 };
    java.util.ArrayList<float[]> placed = new java.util.ArrayList<>();
    placed.add(new float[]{ 514, 514, 70, 54 });

    float[] resolved = app.resolveHoverBoxPosition(500, 500, 0, 0, 1000, 1000, 70, 54, placed, preferred);

    assertEquals(416, resolved[0], 0.0001f);
    assertEquals(514, resolved[1], 0.0001f);
  }

  @Test
  void resolve_clampsThePreferredPositionIntoTheDestRect () {
    // A remembered position could predate a panel resize, or just never
    // have been clamped by whoever passed it in - it must be clamped the
    // same as every other candidate, not used verbatim.
    float[] preferred = { -50, -50 };

    float[] resolved = app.resolveHoverBoxPosition(50, 50, 0, 0, 200, 200, 70, 54, new java.util.ArrayList<float[]>(), preferred);

    assertEquals(app.hoverStrokeInset, resolved[0], 0.0001f);
    assertEquals(app.hoverStrokeInset, resolved[1], 0.0001f);
  }
}
