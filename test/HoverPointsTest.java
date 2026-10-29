import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers hover.pde's addHoverPoint()/removeLastHoverPoint()/removeHoverPointAt() -
// the pure state management behind "click to pin a hover point, Esc to
// drop the most recently pinned one" (mouseClicked.pde's STUDY/WIN3D/WORLD
// click handling, solarchvision_bim.pde's keyPressed()) - and, further
// below, addHoverPoint()'s 3-argument overload and the
// hoverPointPreferredPosition map it writes to, which is how a newly
// pinned point can remember where its own live preview was. None of this
// touches live graphics - it only reads/writes the allHoverPoints field
// and the preferred-position map itself - so all of it is testable here,
// unlike drawAllHovers()/placeHoversAt() which actually draw.
// syncWorldHoverPointPositions() (hoverOnWorldStations.pde), which calls
// removeHoverPointAt() to drop a WORLD-sourced pin whose own geography has
// panned/zoomed out of view, is covered separately in WorldStationHoverTest.java
// alongside the rest of that file's own WORLD-specific logic.
class HoverPointsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= addHoverPoint ============================================

  @Test
  void add_createsAOnePointListFromNull () {
    assertNull(app.allHoverPoints);

    app.addHoverPoint(10, 20);

    assertNotNull(app.allHoverPoints);
    assertEquals(1, app.allHoverPoints.length);
    assertArrayEquals(new int[]{ 10, 20 }, app.allHoverPoints[0]);
  }

  @Test
  void add_appendsToAnExistingList_withoutDisturbingEarlierPoints () {
    app.addHoverPoint(1, 2);
    app.addHoverPoint(3, 4);

    assertEquals(2, app.allHoverPoints.length);
    assertArrayEquals(new int[]{ 1, 2 }, app.allHoverPoints[0]);
    assertArrayEquals(new int[]{ 3, 4 }, app.allHoverPoints[1]);
  }

  @Test
  void add_keepsEveryPoint_acrossSeveralCalls () {
    app.addHoverPoint(1, 1);
    app.addHoverPoint(2, 2);
    app.addHoverPoint(3, 3);

    assertEquals(3, app.allHoverPoints.length);
    assertArrayEquals(new int[]{ 3, 3 }, app.allHoverPoints[2]);
  }

  @Test
  void add_returnsTheExactRowItJustAppended () {
    // mouseClicked.pde's own WORLD left-click handling needs this row
    // back to register it in worldHoverPointGeo (hoverOnWorldStations.pde)
    // against the SAME object identity addHoverPoint() itself used, not
    // just an equal-valued copy.
    int[] row = app.addHoverPoint(7, 8);

    assertSame(app.allHoverPoints[0], row);
  }

  @Test
  void add_withAPreferredPosition_alsoReturnsTheExactRow () {
    int[] row = app.addHoverPoint(7, 8, new float[]{ 1, 1 });

    assertSame(app.allHoverPoints[0], row);
  }

  // ================= removeLastHoverPoint ======================================

  @Test
  void remove_returnsFalse_andDoesNotThrow_whenTheresNothingToRemove () {
    assertNull(app.allHoverPoints);

    assertFalse(app.removeLastHoverPoint());
    assertNull(app.allHoverPoints);
  }

  @Test
  void remove_returnsFalse_onAnExplicitlyEmptyArray () {
    // Not a state addHoverPoint()/removeLastHoverPoint() themselves
    // ever produce (empty always collapses back to null - see below),
    // but __HOVER__ (extraCommands.pde) writes allHoverPoints directly
    // from outside, so an empty-but-non-null array is worth covering
    // too.
    app.allHoverPoints = new int[0][2];

    assertFalse(app.removeLastHoverPoint());
  }

  @Test
  void remove_dropsTheMostRecentlyAddedPoint_leavingTheOthersInOrder () {
    // Most recent first, not oldest: a pinned point now remembers where
    // it actually landed (addHoverPoint()'s own preferredPosition
    // overload), so Esc undoing the just-added pin is "undo the last
    // thing I did" - the same thing Esc means everywhere else in this
    // app - rather than cleaning up the stalest pin lying around.
    app.addHoverPoint(1, 1);
    app.addHoverPoint(2, 2);
    app.addHoverPoint(3, 3);

    assertTrue(app.removeLastHoverPoint());

    assertEquals(2, app.allHoverPoints.length);
    assertArrayEquals(new int[]{ 1, 1 }, app.allHoverPoints[0]);
    assertArrayEquals(new int[]{ 2, 2 }, app.allHoverPoints[1]);
  }

  @Test
  void remove_setsTheListBackToNull_onceTheLastPointIsRemoved () {
    app.addHoverPoint(5, 5);

    assertTrue(app.removeLastHoverPoint());

    assertNull(app.allHoverPoints);
  }

  @Test
  void remove_eachCallDropsOneMorePoint_mostRecentFirst_untilNoneAreLeft () {
    app.addHoverPoint(1, 1);
    app.addHoverPoint(2, 2);

    assertTrue(app.removeLastHoverPoint());
    assertEquals(1, app.allHoverPoints.length);
    assertArrayEquals(new int[]{ 1, 1 }, app.allHoverPoints[0]); // (2,2) was most recent, now gone

    assertTrue(app.removeLastHoverPoint());
    assertNull(app.allHoverPoints);

    assertFalse(app.removeLastHoverPoint());
    assertNull(app.allHoverPoints);
  }

  @Test
  void addThenRemove_newPointsStillAppendAfterARemoval () {
    app.addHoverPoint(1, 1);
    app.addHoverPoint(2, 2);
    app.addHoverPoint(3, 3);

    app.removeLastHoverPoint(); // drops (3,3)

    app.addHoverPoint(9, 9);

    assertEquals(3, app.allHoverPoints.length);
    assertArrayEquals(new int[]{ 1, 1 }, app.allHoverPoints[0]);
    assertArrayEquals(new int[]{ 2, 2 }, app.allHoverPoints[1]);
    assertArrayEquals(new int[]{ 9, 9 }, app.allHoverPoints[2]);
  }

  // ================= addHoverPoint with a preferredPosition ===================
  // The 3-argument overload - how a newly pinned point remembers where
  // its own live preview was (hover.pde's own currentHoverPreferredPosition,
  // read by resolveHoverBoxPosition() - see HoverBoxCollisionTest.java's
  // own "resolveHoverBoxPosition with a preferredPosition" section for
  // how that's actually used during resolution).

  @Test
  void add_withAPreferredPosition_stillAddsTheRowTheSameWay () {
    app.addHoverPoint(10, 20, new float[]{ 5, 5 });

    assertEquals(1, app.allHoverPoints.length);
    assertArrayEquals(new int[]{ 10, 20 }, app.allHoverPoints[0]);
  }

  @Test
  void add_withAPreferredPosition_remembersItForThatExactRow () {
    app.addHoverPoint(10, 20, new float[]{ 5, 5 });

    float[] remembered = app.hoverPointPreferredPosition.get(app.allHoverPoints[0]);

    assertNotNull(remembered);
    assertEquals(5f, remembered[0], 0.0001f);
    assertEquals(5f, remembered[1], 0.0001f);
  }

  @Test
  void add_withANullPreferredPosition_remembersNothing () {
    // The 2-argument overload delegates to this one with null - a click
    // with no live box to inherit from (findLiveHoverBox() found
    // nothing) ends up here too, and must behave exactly like a plain
    // addHoverPoint(x, y) call, not accidentally remember an empty/zero
    // position.
    app.addHoverPoint(10, 20, null);

    assertTrue(app.hoverPointPreferredPosition.isEmpty());
  }

  @Test
  void add_withoutAPreferredPosition_neverTouchesTheMapAtAll () {
    app.addHoverPoint(10, 20);

    assertTrue(app.hoverPointPreferredPosition.isEmpty());
  }

  @Test
  void add_distinguishesTwoPinsAtTheSameCoordinates_byRowIdentityNotValue () {
    // Two separate clicks that happen to land on the exact same pixel
    // must still be tracked as two distinct rows, each with its own
    // (possibly different) remembered position - not merged into one
    // entry just because their x,y values match.
    app.addHoverPoint(10, 20, new float[]{ 1, 1 });
    app.addHoverPoint(10, 20, new float[]{ 2, 2 });

    assertEquals(2, app.allHoverPoints.length);
    assertEquals(2, app.hoverPointPreferredPosition.size());

    float[] first = app.hoverPointPreferredPosition.get(app.allHoverPoints[0]);
    float[] second = app.hoverPointPreferredPosition.get(app.allHoverPoints[1]);
    assertEquals(1f, first[0], 0.0001f);
    assertEquals(2f, second[0], 0.0001f);
  }

  @Test
  void remove_cleansUpThePreferredPositionOfTheRowItRemoves () {
    app.addHoverPoint(10, 20, new float[]{ 5, 5 });
    app.addHoverPoint(30, 40, new float[]{ 6, 6 });
    int[] mostRecentRow = app.allHoverPoints[1];

    app.removeLastHoverPoint();

    assertFalse(app.hoverPointPreferredPosition.containsKey(mostRecentRow));
    assertEquals(1, app.hoverPointPreferredPosition.size()); // the remaining pin's own entry is untouched
  }

  @Test
  void remove_leavesTheMapEmpty_whenTheRemovedPointHadNoPreference () {
    app.addHoverPoint(10, 20); // no preference

    assertTrue(app.removeLastHoverPoint());
    assertTrue(app.hoverPointPreferredPosition.isEmpty());
  }

  // ================= removeHoverPointAt ========================================
  // removeLastHoverPoint() above is just removeHoverPointAt(length-1) now
  // (confirmed indirectly by every test above still passing unchanged),
  // but this is the only way to drop a pin that ISN'T the most recent one -
  // what syncWorldHoverPointPositions() (hoverOnWorldStations.pde) needs
  // when a WORLD-sourced pin's own geography pans/zooms out of view,
  // regardless of where in allHoverPoints it happens to sit.

  @Test
  void removeAt_dropsTheRowAtThatIndex_leavingTheOthersInOrder () {
    app.addHoverPoint(1, 1);
    app.addHoverPoint(2, 2); // removed below - the MIDDLE one, not the last
    app.addHoverPoint(3, 3);

    app.removeHoverPointAt(1);

    assertEquals(2, app.allHoverPoints.length);
    assertArrayEquals(new int[]{ 1, 1 }, app.allHoverPoints[0]);
    assertArrayEquals(new int[]{ 3, 3 }, app.allHoverPoints[1]);
  }

  @Test
  void removeAt_setsTheListBackToNull_onceTheOnlyPointIsRemoved () {
    app.addHoverPoint(5, 5);

    app.removeHoverPointAt(0);

    assertNull(app.allHoverPoints);
  }

  @Test
  void removeAt_cleansUpThePreferredPositionOfTheRowItRemoves () {
    app.addHoverPoint(10, 20, new float[]{ 5, 5 });
    app.addHoverPoint(30, 40, new float[]{ 6, 6 });
    int[] firstRow = app.allHoverPoints[0];

    app.removeHoverPointAt(0);

    assertFalse(app.hoverPointPreferredPosition.containsKey(firstRow));
    assertEquals(1, app.hoverPointPreferredPosition.size()); // the remaining pin's own entry is untouched
  }

  @Test
  void removeAt_cleansUpTheWorldGeoEntryOfTheRowItRemoves () {
    int[] row = app.addHoverPoint(10, 20);
    app.worldHoverPointGeo.put(row, new float[]{ -79, 43 });

    app.removeHoverPointAt(0);

    assertFalse(app.worldHoverPointGeo.containsKey(row));
  }

  @Test
  void removeAt_isANoOp_forAnOutOfRangeIndex () {
    app.addHoverPoint(1, 1);

    app.removeHoverPointAt(5); // past the end
    app.removeHoverPointAt(-1); // before the start

    assertEquals(1, app.allHoverPoints.length); // untouched either way
  }

  @Test
  void removeAt_isANoOp_whenThereAreNoPointsAtAll () {
    assertNull(app.allHoverPoints);

    app.removeHoverPointAt(0); // must not throw

    assertNull(app.allHoverPoints);
  }
}
