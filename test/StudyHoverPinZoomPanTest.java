import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers hoverOnStudyImpact.pde's own STUDY-pin zoom/pan (and panel-size)
// tracking: studyLocalXFromScreen()/studyLocalYFromScreen(),
// studyScreenXFromLocal()/studyScreenYFromLocal(), their panel-size-
// independent studyLocalFracX/YFromScreen()/studyScreenX/YFromLocalFrac()
// wrappers, and syncStudyHoverPointPositions() - the STUDY-side
// counterpart of WorldStationHoverTest.java's own
// syncWorldHoverPointPositions() tests, keyed to STUDY.userZoom/userPanX/
// userPanY (and STUDY.dX/dY) instead of a map projection.
class StudyHoverPinZoomPanTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();

    // A simple, exactly-invertible identity mapping at the default zoom/
    // pan: cX=0, cY=0, ImageScale=1 makes the screen <-> this.graphics
    // device-pixel conversion a no-op, so screen coordinates can be
    // reasoned about directly; individual tests override userZoom/
    // userPanX/userPanY to simulate zooming/panning after a pin was
    // placed.
    app.STUDY.include = true;
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.dX = 400;
    app.STUDY.dY = 300;
    app.STUDY.ImageScale = 1;
    app.STUDY.userZoom = 1;
    app.STUDY.userPanX = 0;
    app.STUDY.userPanY = 0;
  }

  // ================= studyLocalXFromScreen / studyScreenXFromLocal ======
  // The two conversions must be exact inverses of each other, under
  // whatever cX/cY/ImageScale/userZoom/userPanX/userPanY happen to be
  // active at the time - not just the identity setUp() above.

  @Test
  void screenToLocalAndBack_roundTrips_underTheIdentitySetup () {
    float localX = app.studyLocalXFromScreen(123);
    float localY = app.studyLocalYFromScreen(77);

    assertEquals(123, localX, 0.0001f);
    assertEquals(77, localY, 0.0001f);
    assertEquals(123, app.studyScreenXFromLocal(localX), 0.0001f);
    assertEquals(77, app.studyScreenYFromLocal(localY), 0.0001f);
  }

  @Test
  void screenToLocalAndBack_roundTrips_underANonTrivialZoomPanAndOffset () {
    app.STUDY.cX = 20;
    app.STUDY.cY = 10;
    app.STUDY.ImageScale = 2;
    app.STUDY.userZoom = 1.5f;
    app.STUDY.userPanX = 30;
    app.STUDY.userPanY = -5;

    float screenX = 164;
    float screenY = 48;

    float localX = app.studyLocalXFromScreen(screenX);
    float localY = app.studyLocalYFromScreen(screenY);

    assertEquals(screenX, app.studyScreenXFromLocal(localX), 0.001f);
    assertEquals(screenY, app.studyScreenYFromLocal(localY), 0.001f);
  }

  // ========= studyLocalFracXFromScreen / studyScreenXFromLocalFrac ======
  // The panel-size-independent wrappers: dividing/multiplying by STUDY's
  // own CURRENT dX/dY on top of the same zoom/pan math above - still
  // exact inverses of each other, and still consistent with the raw
  // (non-fraction) functions once a stored fraction is scaled back up by
  // the panel's own current dX/dY.

  @Test
  void localFracRoundTrips_underTheIdentitySetup () {
    float fracX = app.studyLocalFracXFromScreen(100); // dX=400 -> 100/400
    float fracY = app.studyLocalFracYFromScreen(60); // dY=300 -> 60/300

    assertEquals(0.25f, fracX, 0.0001f);
    assertEquals(0.2f, fracY, 0.0001f);
    assertEquals(100, app.studyScreenXFromLocalFrac(fracX), 0.0001f);
    assertEquals(60, app.studyScreenYFromLocalFrac(fracY), 0.0001f);
  }

  @Test
  void localFrac_reconstructsTheSameScreenPosition_afterThePanelSizeChanges () {
    // Pin captured while STUDY's own panel is 400x300 (setUp()'s own
    // dimensions, standing in for "the device the project was saved
    // on").
    float fracX = app.studyLocalFracXFromScreen(100);
    float fracY = app.studyLocalFracYFromScreen(60);

    // Reopened on a different device, where STUDY's own panel happens to
    // be 800x600 instead (double in both dimensions) - the stored
    // fraction should still land on the same PROPORTIONAL spot, not the
    // same absolute pixel.
    app.STUDY.dX = 800;
    app.STUDY.dY = 600;

    assertEquals(200, app.studyScreenXFromLocalFrac(fracX), 0.0001f);
    assertEquals(120, app.studyScreenYFromLocalFrac(fracY), 0.0001f);
  }

  // ================= syncStudyHoverPointPositions =======================
  // Keeps a STUDY-sourced pin (studyHoverPointLocalFrac) tracking the same
  // spot on the graph as STUDY itself is zoomed/panned, dropping it once
  // that spot pans/zooms outside STUDY's own current panel rect. A plain
  // WIN3D/WORLD-style pin (no studyHoverPointLocalFrac entry) is left
  // completely alone.

  @Test
  void sync_doesNothing_whenThereAreNoHoverPointsAtAll () {
    assertNull(app.allHoverPoints);

    app.syncStudyHoverPointPositions(); // must not throw

    assertNull(app.allHoverPoints);
  }

  @Test
  void sync_leavesAPlainScreenPin_completelyUntouched () {
    // A WIN3D/WORLD-style pin - never registered in studyHoverPointLocalFrac
    // - even though its raw (x, y) happens to be inside STUDY's own
    // current panel rect.
    int[] row = app.addHoverPoint(100, 50);

    app.STUDY.userZoom = 3; // zoomed since the pin was placed

    app.syncStudyHoverPointPositions();

    assertArrayEquals(new int[]{ 100, 50 }, app.allHoverPoints[0]);
    assertSame(row, app.allHoverPoints[0]); // not replaced, not touched
  }

  @Test
  void sync_updatesAStudyPinsScreenPosition_whenZoomedInSinceItWasPinned () {
    // Pinned at screen (100, 50) while userZoom=1/userPanX=userPanY=0 -
    // its own local position (studyLocalXFromScreen()/
    // studyLocalYFromScreen()) is therefore (100, 50) too.
    int[] row = app.addHoverPoint(100, 50);
    float localFracX = app.studyLocalFracXFromScreen(100);
    float localFracY = app.studyLocalFracYFromScreen(50);
    app.studyHoverPointLocalFrac.put(row, new float[]{ localFracX, localFracY });

    // Simulate zooming in 2x, as Ctrl+Q/the mouse wheel would have
    // already applied before drawAllHovers() runs this same frame (see
    // syncStudyHoverPointPositions()'s own comment on that ordering).
    app.STUDY.userZoom = 2;

    app.syncStudyHoverPointPositions();

    // studyScreenXFromLocal(100) with the new userZoom=2: 0 + 2*100 = 200.
    assertEquals(200, app.allHoverPoints[0][0]);
    assertEquals(100, app.allHoverPoints[0][1]);
  }

  @Test
  void sync_shiftsAnAlreadyPlacedBoxByTheSameDeltaAsItsPin () {
    int[] row = app.addHoverPoint(100, 50, new float[]{ 250, 60 }); // box placed down-right of the pin
    float localFracX = app.studyLocalFracXFromScreen(100);
    float localFracY = app.studyLocalFracYFromScreen(50);
    app.studyHoverPointLocalFrac.put(row, new float[]{ localFracX, localFracY });

    // Zoom scales BOTH axes around STUDY's own graphics-buffer origin:
    // x moves 100 -> 200 (+100px), y moves 50 -> 100 (+50px).
    app.STUDY.userZoom = 2;

    app.syncStudyHoverPointPositions();

    float[] preferred = app.hoverPointPreferredPosition.get(row);
    assertEquals(350, preferred[0], 0.0001f); // 250 + 100 - rode along with the pin
    assertEquals(110, preferred[1], 0.0001f); // 60 + 50 - rode along with the pin
  }

  @Test
  void sync_dropsAStudyPin_onceZoomingMovesItOutsideThePanelRect () {
    int[] row = app.addHoverPoint(100, 50);
    float localFracX = app.studyLocalFracXFromScreen(100);
    float localFracY = app.studyLocalFracYFromScreen(50);
    app.studyHoverPointLocalFrac.put(row, new float[]{ localFracX, localFracY });

    // dX=400, so a 5x zoom pushes screen x from 100 to 500 - past the
    // panel's own right edge.
    app.STUDY.userZoom = 5;

    app.syncStudyHoverPointPositions();

    assertNull(app.allHoverPoints);
    assertTrue(app.studyHoverPointLocalFrac.isEmpty());
    assertTrue(app.hoverPointPreferredPosition.isEmpty());
  }

  @Test
  void sync_onlyDropsTheOneStudyPinThatWentOutOfView_leavingOthersInPlace () {
    int[] staysInView = app.addHoverPoint(50, 50);
    app.studyHoverPointLocalFrac.put(staysInView, new float[]{ app.studyLocalFracXFromScreen(50), app.studyLocalFracYFromScreen(50) });

    int[] goesOutOfView = app.addHoverPoint(350, 50);
    app.studyHoverPointLocalFrac.put(goesOutOfView, new float[]{ app.studyLocalFracXFromScreen(350), app.studyLocalFracYFromScreen(50) });

    int[] plainScreenPin = app.addHoverPoint(300, 200); // never registered as STUDY-tracked

    app.STUDY.userZoom = 2; // 50*2=100 (still inside 400); 350*2=700 (outside)

    app.syncStudyHoverPointPositions();

    assertEquals(2, app.allHoverPoints.length);
    assertArrayEquals(new int[]{ 100, 100 }, app.allHoverPoints[0]);
    assertArrayEquals(new int[]{ 300, 200 }, app.allHoverPoints[1]); // the plain pin, untouched and still present
    assertFalse(app.studyHoverPointLocalFrac.containsKey(goesOutOfView));
  }

  @Test
  void sync_doesNothingAtAll_whenZoomAndPanHaveNotActuallyChanged () {
    int[] row = app.addHoverPoint(100, 50, new float[]{ 250, 60 });
    app.studyHoverPointLocalFrac.put(row, new float[]{ app.studyLocalFracXFromScreen(100), app.studyLocalFracYFromScreen(50) });

    app.syncStudyHoverPointPositions(); // nothing zoomed/panned since the pin was placed

    assertArrayEquals(new int[]{ 100, 50 }, app.allHoverPoints[0]);
    float[] preferred = app.hoverPointPreferredPosition.get(row);
    assertEquals(250, preferred[0], 0.0001f);
    assertEquals(60, preferred[1], 0.0001f);
  }

  @Test
  void sync_doesNothing_whenStudyIsNotIncluded () {
    int[] row = app.addHoverPoint(100, 50);
    app.studyHoverPointLocalFrac.put(row, new float[]{ app.studyLocalFracXFromScreen(100), app.studyLocalFracYFromScreen(50) });

    app.STUDY.include = false;
    app.STUDY.userZoom = 2; // would otherwise move the pin to x=200

    app.syncStudyHoverPointPositions();

    assertArrayEquals(new int[]{ 100, 50 }, app.allHoverPoints[0]); // left untouched while STUDY isn't shown
  }
}
