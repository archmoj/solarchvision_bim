import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers hoverOnSolarImpactOverlay.pde's own WIN3D-pin viewport-resize
// (and panel-size) tracking: syncWin3DHoverPointPositions() - the
// WIN3D-side counterpart of WorldStationHoverTest.java's own
// syncWorldHoverPointPositions() tests and StudyHoverPinZoomPanTest.java's
// own syncStudyHoverPointPositions() tests, keyed to a FRACTION of WIN3D's
// own current dX/dY, offset from WIN3D's own panel center, instead of a
// map projection or a zoom/pan transform.
//
// Storing a FRACTION of dX/dY (rather than an absolute pixel offset, as
// in the pre-fraction version of this file) means a pin that's valid at
// pin time (|fracX|<=0.5, |fracY|<=0.5) stays INSIDE the panel rect
// under any pure resize/recenter of WIN3D - by construction, the
// resolved position is always within [cX, cX+dX] x [cY, cY+dY]. So the
// "goes out of view" tests below can no longer be triggered by resizing
// alone; they instead exercise a stored fraction whose own magnitude
// already puts it outside the panel, the same way a corrupted or
// hand-edited save file might.
class Win3DHoverPinResizeTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();

    app.WIN3D.include = true;
    app.WIN3D.cX = 0;
    app.WIN3D.cY = 0;
    app.WIN3D.dX = 400;
    app.WIN3D.dY = 300;
  }

  @Test
  void sync_doesNothing_whenThereAreNoHoverPointsAtAll () {
    assertNull(app.allHoverPoints);

    app.syncWin3DHoverPointPositions(); // must not throw

    assertNull(app.allHoverPoints);
  }

  @Test
  void sync_leavesAPlainScreenPin_completelyUntouched () {
    // A STUDY/WORLD-style pin - never registered in
    // win3DHoverPointOffsetFrac - even though its raw (x, y) happens to
    // be inside WIN3D's own current panel rect.
    int[] row = app.addHoverPoint(150, 100);

    // Enlarge the viewport since the pin was placed.
    app.WIN3D.dX = 800;
    app.WIN3D.dY = 600;

    app.syncWin3DHoverPointPositions();

    assertArrayEquals(new int[]{ 150, 100 }, app.allHoverPoints[0]);
    assertSame(row, app.allHoverPoints[0]); // not replaced, not touched
  }

  @Test
  void sync_keepsAWin3DPinCenteredTheSameWay_whenTheViewportIsEnlarged () {
    // Pinned at screen (150, 100) - center is (200, 150) under the
    // original dX=400/dY=300, so the pin's own offset from center is
    // (-50, -50), i.e. a fraction of (-50/400, -50/300) = (-0.125,
    // -0.16667).
    int[] row = app.addHoverPoint(150, 100);
    app.win3DHoverPointOffsetFrac.put(row, new float[]{ -0.125f, -50f / 300f });

    // Simulate "Enlarge 3D Viewport" (update_frame_layout(),
    // updateFrameLayout.pde) recentering/resizing the panel - cX stays 0
    // here (as it already is in the all-viewports layout's own 3D
    // panel), only dX/dY grow (doubling, in this case).
    app.WIN3D.dX = 800;
    app.WIN3D.dY = 600;

    app.syncWin3DHoverPointPositions();

    // New center is (400, 300); the stored FRACTION, applied to the new
    // dX/dY=800/600, gives a new offset of (-0.125*800, -0.16667*600) =
    // (-100, -100) - scaling up proportionally with the panel, unlike a
    // fixed pixel offset - landing at (400-100, 300-100) = (300, 200).
    assertEquals(300, app.allHoverPoints[0][0]);
    assertEquals(200, app.allHoverPoints[0][1]);
  }

  @Test
  void sync_followsAPanelThatAlsoShiftsItsOwnTopLeftCorner () {
    // The real "Enlarge 3D Viewport" transition (viewLayout 0 -> 1,
    // updateFrameLayout.pde) moves WIN3D.cX from pixel_W to 0, not just
    // dX/dY - exercised here directly rather than assuming cX never
    // moves.
    app.WIN3D.cX = 100;
    app.WIN3D.dX = 200; // center = 100 + 100 = 200

    int[] row = app.addHoverPoint(220, 100); // offset from center: (20, 100-150) if dY=300 -> center y = 150
    // fracX = 20/200 = 0.1; fracY = -50/300 = -0.16667
    app.win3DHoverPointOffsetFrac.put(row, new float[]{ 0.1f, -50f / 300f });

    app.WIN3D.cX = 0;
    app.WIN3D.dX = 400; // new center x = 0 + 200 = 200 (unchanged this time), but dX itself doubled (200 -> 400)

    app.syncWin3DHoverPointPositions();

    // x: center stayed at 200, but dX doubled (200 -> 400), so the
    // stored fraction (0.1) resolves to a bigger offset too:
    // 0.1*400 = 40, landing at 200+40 = 240 (not 220 - the offset scales
    // with the panel even though the center itself didn't move this
    // time).
    assertEquals(240, app.allHoverPoints[0][0]);
    // y: dY/cY never changed, so the fraction resolves to the exact same
    // offset as before: -0.16667*300 = -50, landing at 150-50 = 100.
    assertEquals(100, app.allHoverPoints[0][1]);
  }

  @Test
  void sync_shiftsAnAlreadyPlacedBoxByTheSameDeltaAsItsPin () {
    int[] row = app.addHoverPoint(150, 100, new float[]{ 300, 120 }); // box placed down-right of the pin
    app.win3DHoverPointOffsetFrac.put(row, new float[]{ -0.125f, -50f / 300f });

    app.WIN3D.dX = 800;
    app.WIN3D.dY = 600;
    // New center (400, 300); new offset (-0.125*800, -50/300*600) =
    // (-100, -100); new position (300, 200) - pin moves from (150,100)
    // to (300,200): +150,+100.

    app.syncWin3DHoverPointPositions();

    float[] preferred = app.hoverPointPreferredPosition.get(row);
    assertEquals(450, preferred[0], 0.0001f); // 300 + 150 - rode along with the pin
    assertEquals(220, preferred[1], 0.0001f); // 120 + 100 - rode along with the pin
  }

  @Test
  void sync_dropsAWin3DPin_whenItsStoredFractionPointsOutsideThePanelRect () {
    int[] row = app.addHoverPoint(150, 100);

    // A fraction whose magnitude exceeds the valid +-0.5 range - points
    // well outside WIN3D's own current panel rect once resolved,
    // regardless of dX/dY. Under the old absolute-pixel-offset design
    // this kind of drop was triggered by shrinking the viewport; under
    // fraction-based tracking a pin that was ever validly pinned can't
    // be pushed out of view by a pure resize, so this instead stands in
    // for a corrupted or hand-edited stored value.
    app.win3DHoverPointOffsetFrac.put(row, new float[]{ 0.9f, 0.9f });

    app.syncWin3DHoverPointPositions();

    assertNull(app.allHoverPoints);
    assertTrue(app.win3DHoverPointOffsetFrac.isEmpty());
    assertTrue(app.hoverPointPreferredPosition.isEmpty());
  }

  @Test
  void sync_onlyDropsTheOneWin3DPinThatHasAnOutOfRangeFraction_leavingOthersInPlace () {
    int[] staysInView = app.addHoverPoint(200, 150); // dead center - fraction (0,0), valid at any panel size
    app.win3DHoverPointOffsetFrac.put(staysInView, new float[]{ 0, 0 });

    int[] goesOutOfView = app.addHoverPoint(390, 290); // an out-of-range fraction, invalid regardless of dX/dY
    app.win3DHoverPointOffsetFrac.put(goesOutOfView, new float[]{ 0.9f, 0.9f });

    int[] plainScreenPin = app.addHoverPoint(10, 10); // never registered as WIN3D-tracked

    app.syncWin3DHoverPointPositions();

    assertEquals(2, app.allHoverPoints.length);
    assertArrayEquals(new int[]{ 200, 150 }, app.allHoverPoints[0]);
    assertArrayEquals(new int[]{ 10, 10 }, app.allHoverPoints[1]); // the plain pin, untouched and still present
    assertFalse(app.win3DHoverPointOffsetFrac.containsKey(goesOutOfView));
  }

  @Test
  void sync_doesNothingAtAll_whenTheViewportHasNotActuallyResized () {
    int[] row = app.addHoverPoint(150, 100, new float[]{ 300, 120 });
    app.win3DHoverPointOffsetFrac.put(row, new float[]{ -0.125f, -50f / 300f });

    app.syncWin3DHoverPointPositions(); // nothing resized since the pin was placed

    assertArrayEquals(new int[]{ 150, 100 }, app.allHoverPoints[0]);
    float[] preferred = app.hoverPointPreferredPosition.get(row);
    assertEquals(300, preferred[0], 0.0001f);
    assertEquals(120, preferred[1], 0.0001f);
  }

  @Test
  void sync_doesNothing_whenWin3DIsNotIncluded () {
    int[] row = app.addHoverPoint(150, 100);
    app.win3DHoverPointOffsetFrac.put(row, new float[]{ -0.125f, -50f / 300f });

    app.WIN3D.include = false;
    app.WIN3D.dX = 800; // would otherwise move the pin

    app.syncWin3DHoverPointPositions();

    assertArrayEquals(new int[]{ 150, 100 }, app.allHoverPoints[0]); // left untouched while WIN3D isn't shown
  }
}
