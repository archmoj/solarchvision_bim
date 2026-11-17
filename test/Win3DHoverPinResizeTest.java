import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers hoverOnSolarImpactOverlay.pde's own WIN3D-pin viewport-resize
// tracking: syncWin3DHoverPointPositions() - the WIN3D-side counterpart
// of WorldStationHoverTest.java's own syncWorldHoverPointPositions()
// tests and StudyHoverPinZoomPanTest.java's own syncStudyHoverPointPositions()
// tests, keyed to a plain offset from WIN3D's own panel center instead
// of a map projection or a zoom/pan transform.
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
    // A STUDY/WORLD-style pin - never registered in win3DHoverPointOffset
    // - even though its raw (x, y) happens to be inside WIN3D's own
    // current panel rect.
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
    // (-50, -50).
    int[] row = app.addHoverPoint(150, 100);
    app.win3DHoverPointOffset.put(row, new float[]{ -50, -50 });

    // Simulate "Enlarge 3D Viewport" (update_frame_layout(),
    // updateFrameLayout.pde) recentering/resizing the panel - cX stays 0
    // here (as it already is in the all-viewports layout's own 3D
    // panel), only dX/dY grow.
    app.WIN3D.dX = 800;
    app.WIN3D.dY = 600;

    app.syncWin3DHoverPointPositions();

    // New center is (400, 300); same (-50, -50) offset lands at (350, 250).
    assertEquals(350, app.allHoverPoints[0][0]);
    assertEquals(250, app.allHoverPoints[0][1]);
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
    app.win3DHoverPointOffset.put(row, new float[]{ 20, -50 });

    app.WIN3D.cX = 0;
    app.WIN3D.dX = 400; // new center x = 0 + 200 = 200 (unchanged this time)

    app.syncWin3DHoverPointPositions();

    assertEquals(220, app.allHoverPoints[0][0]); // 200 + 20, same as before - center happened to land in the same place
    assertEquals(100, app.allHoverPoints[0][1]); // y untouched, dY/cY didn't change
  }

  @Test
  void sync_shiftsAnAlreadyPlacedBoxByTheSameDeltaAsItsPin () {
    int[] row = app.addHoverPoint(150, 100, new float[]{ 300, 120 }); // box placed down-right of the pin
    app.win3DHoverPointOffset.put(row, new float[]{ -50, -50 });

    app.WIN3D.dX = 800;
    app.WIN3D.dY = 600; // pin moves from (150,100) to (350,250): +200,+150

    app.syncWin3DHoverPointPositions();

    float[] preferred = app.hoverPointPreferredPosition.get(row);
    assertEquals(500, preferred[0], 0.0001f); // 300 + 200 - rode along with the pin
    assertEquals(270, preferred[1], 0.0001f); // 120 + 150 - rode along with the pin
  }

  @Test
  void sync_dropsAWin3DPin_onceResizingMovesItOutsideThePanelRect () {
    int[] row = app.addHoverPoint(150, 100);
    app.win3DHoverPointOffset.put(row, new float[]{ -50, -50 });

    // Shrink the viewport instead - new center (50, 37.5), offset still
    // (-50,-50) lands at (0, -12.5), outside the panel's own rect.
    app.WIN3D.dX = 100;
    app.WIN3D.dY = 75;

    app.syncWin3DHoverPointPositions();

    assertNull(app.allHoverPoints);
    assertTrue(app.win3DHoverPointOffset.isEmpty());
    assertTrue(app.hoverPointPreferredPosition.isEmpty());
  }

  @Test
  void sync_onlyDropsTheOneWin3DPinThatWentOutOfView_leavingOthersInPlace () {
    int[] staysInView = app.addHoverPoint(200, 150); // dead center - offset (0,0)
    app.win3DHoverPointOffset.put(staysInView, new float[]{ 0, 0 });

    int[] goesOutOfView = app.addHoverPoint(390, 290); // near the far corner - offset (190, 140)
    app.win3DHoverPointOffset.put(goesOutOfView, new float[]{ 190, 140 });

    int[] plainScreenPin = app.addHoverPoint(10, 10); // never registered as WIN3D-tracked

    app.WIN3D.dX = 100;
    app.WIN3D.dY = 75; // new center (50, 37.5): staysInView lands at (50,37.5) - inside; goesOutOfView at (240,177.5) - outside

    app.syncWin3DHoverPointPositions();

    assertEquals(2, app.allHoverPoints.length);
    assertArrayEquals(new int[]{ 50, 38 }, app.allHoverPoints[0]); // round(37.5) == 38
    assertArrayEquals(new int[]{ 10, 10 }, app.allHoverPoints[1]); // the plain pin, untouched and still present
    assertFalse(app.win3DHoverPointOffset.containsKey(goesOutOfView));
  }

  @Test
  void sync_doesNothingAtAll_whenTheViewportHasNotActuallyResized () {
    int[] row = app.addHoverPoint(150, 100, new float[]{ 300, 120 });
    app.win3DHoverPointOffset.put(row, new float[]{ -50, -50 });

    app.syncWin3DHoverPointPositions(); // nothing resized since the pin was placed

    assertArrayEquals(new int[]{ 150, 100 }, app.allHoverPoints[0]);
    float[] preferred = app.hoverPointPreferredPosition.get(row);
    assertEquals(300, preferred[0], 0.0001f);
    assertEquals(120, preferred[1], 0.0001f);
  }

  @Test
  void sync_doesNothing_whenWin3DIsNotIncluded () {
    int[] row = app.addHoverPoint(150, 100);
    app.win3DHoverPointOffset.put(row, new float[]{ -50, -50 });

    app.WIN3D.include = false;
    app.WIN3D.dX = 800; // would otherwise move the pin

    app.syncWin3DHoverPointPositions();

    assertArrayEquals(new int[]{ 150, 100 }, app.allHoverPoints[0]); // left untouched while WIN3D isn't shown
  }
}
