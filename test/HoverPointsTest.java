import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers hover.pde's addHoverPoint()/removeOldestHoverPoint() - the pure
// state management behind "click to pin a hover point, Esc to drop the
// oldest one still pinned" (mouseClicked.pde's STUDY/WIN3D click
// handling, solarchvision_bim.pde's keyPressed()). Neither function
// touches live graphics - they only read/write the allHoverPoints field
// itself - so both are fully testable here, unlike drawAllHovers()/
// drawHoversAt() which actually draw.
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

  // ================= removeOldestHoverPoint ====================================

  @Test
  void remove_returnsFalse_andDoesNotThrow_whenTheresNothingToRemove () {
    assertNull(app.allHoverPoints);

    assertFalse(app.removeOldestHoverPoint());
    assertNull(app.allHoverPoints);
  }

  @Test
  void remove_returnsFalse_onAnExplicitlyEmptyArray () {
    // Not a state addHoverPoint()/removeOldestHoverPoint() themselves
    // ever produce (empty always collapses back to null - see below),
    // but __HOVER__ (extraCommands.pde) writes allHoverPoints directly
    // from outside, so an empty-but-non-null array is worth covering
    // too.
    app.allHoverPoints = new int[0][2];

    assertFalse(app.removeOldestHoverPoint());
  }

  @Test
  void remove_dropsTheOldestPoint_leavingTheOthersInOrder () {
    // Oldest first, not most-recently-added: matches drawAllHovers()'s
    // own newest-to-oldest draw order (hover.pde) - the newest pin
    // already has priority placement, so Esc trims the stalest one
    // instead of undoing whatever was just clicked.
    app.addHoverPoint(1, 1);
    app.addHoverPoint(2, 2);
    app.addHoverPoint(3, 3);

    assertTrue(app.removeOldestHoverPoint());

    assertEquals(2, app.allHoverPoints.length);
    assertArrayEquals(new int[]{ 2, 2 }, app.allHoverPoints[0]);
    assertArrayEquals(new int[]{ 3, 3 }, app.allHoverPoints[1]);
  }

  @Test
  void remove_setsTheListBackToNull_onceTheLastPointIsRemoved () {
    app.addHoverPoint(5, 5);

    assertTrue(app.removeOldestHoverPoint());

    assertNull(app.allHoverPoints);
  }

  @Test
  void remove_eachCallDropsOneMorePoint_oldestFirst_untilNoneAreLeft () {
    app.addHoverPoint(1, 1);
    app.addHoverPoint(2, 2);

    assertTrue(app.removeOldestHoverPoint());
    assertEquals(1, app.allHoverPoints.length);
    assertArrayEquals(new int[]{ 2, 2 }, app.allHoverPoints[0]); // (1,1) was oldest, now gone

    assertTrue(app.removeOldestHoverPoint());
    assertNull(app.allHoverPoints);

    assertFalse(app.removeOldestHoverPoint());
    assertNull(app.allHoverPoints);
  }

  @Test
  void addThenRemove_newPointsStillAppendAfterAnOldestRemoval () {
    app.addHoverPoint(1, 1);
    app.addHoverPoint(2, 2);
    app.addHoverPoint(3, 3);

    app.removeOldestHoverPoint(); // drops (1,1)

    app.addHoverPoint(9, 9);

    assertEquals(3, app.allHoverPoints.length);
    assertArrayEquals(new int[]{ 2, 2 }, app.allHoverPoints[0]);
    assertArrayEquals(new int[]{ 3, 3 }, app.allHoverPoints[1]);
    assertArrayEquals(new int[]{ 9, 9 }, app.allHoverPoints[2]);
  }
}
