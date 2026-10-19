import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import processing.core.PImage;

class SolarImpactsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= resize_Image_array ==================================

  @Test
  void resizeImageArray_buildsTwoRowsOnePlaceholderPerDayColumn () {
    app.STUDY.startDay = 0;
    app.STUDY.endDay = 3;
    app.allSolarImpacts.rebuild_Image_array = true;

    app.allSolarImpacts.resize_Image_array();

    assertEquals(2, app.allSolarImpacts.Image.length);
    assertEquals(4, app.allSolarImpacts.Image[0].length); // 1 + endDay - startDay
    assertNotNull(app.allSolarImpacts.Image[0][1]);
    assertEquals(2, app.allSolarImpacts.Image[0][1].width); // small placeholder
    assertFalse(app.allSolarImpacts.rebuild_Image_array);
  }

  // ================= calculate_Impact_selectedSections ===================

  @Test
  void calculateImpactSelectedSections_isANoOpWhenNothingIsSelected () {
    app.Select3D.sectionSelection = new int[]{};
    // If this reached calculate_Impact_CurrentPreBaked() it would throw
    // on cursor()/loadImage() - reaching the end of this call without an
    // exception IS the assertion here.
    app.allSolarImpacts.calculate_Impact_selectedSections();
  }

  // ================= to_XML / from_XML round trip ========================

  @Test
  void toXMLThenFromXML_roundTripsEveryField () {
    app.allSolarImpacts.displayImage = true;
    app.allSolarImpacts.X = 1;
    app.allSolarImpacts.Y = 2;
    app.allSolarImpacts.Z = 3;
    app.allSolarImpacts.R = 45;
    app.allSolarImpacts.U = 100;
    app.allSolarImpacts.V = 200;
    app.allSolarImpacts.RES1 = 50;
    app.allSolarImpacts.RES2 = 60;
    app.allSolarImpacts.sectionType = 2;

    processing.data.XML root = new processing.data.XML("root");
    app.allSolarImpacts.to_XML(root);

    solarchvision_bim.SolarImpacts fresh = app.new SolarImpacts();
    fresh.from_XML(root);

    assertTrue(fresh.displayImage);
    assertEquals(1f, fresh.X, 0.0001f);
    assertEquals(2f, fresh.Y, 0.0001f);
    assertEquals(3f, fresh.Z, 0.0001f);
    assertEquals(45f, fresh.R, 0.0001f);
    assertEquals(100f, fresh.U, 0.0001f);
    assertEquals(200f, fresh.V, 0.0001f);
    assertEquals(50, fresh.RES1);
    assertEquals(60, fresh.RES2);
    assertEquals(2, fresh.sectionType);
  }

  // ================= win3DOverlay_recordCameraState / win3DOverlay_cameraMatches ======
  // win3DOverlay_recordCameraState() just copies whatever WIN3D's live
  // camera fields currently are, so calling it on a bare app - without
  // first hand-setting every field it reads - already produces a
  // self-consistent "fresh" baseline to compare against below, the same
  // way the real preBakeViewport.pde call site does.

  @Test
  void cameraMatches_isFalse_beforeAnyCameraHasEverBeenRecorded () {
    assertFalse(app.allSolarImpacts.win3DOverlay_cameraMatches());
  }

  @Test
  void cameraMatches_isTrue_rightAfterRecordingTheLiveCamera () {
    app.allSolarImpacts.win3DOverlay_recordCameraState();
    assertTrue(app.allSolarImpacts.win3DOverlay_cameraMatches());
  }

  @Test
  void cameraMatches_toleratesDriftWithinTolerance () {
    app.allSolarImpacts.win3DOverlay_recordCameraState();
    app.WIN3D.cameraX += 0.005f; // < win3DOverlay_cameraPositionTolerance (0.01)

    assertTrue(app.allSolarImpacts.win3DOverlay_cameraMatches());
  }

  @Test
  void cameraMatches_rejectsDriftBeyondTolerance () {
    app.allSolarImpacts.win3DOverlay_recordCameraState();
    app.WIN3D.cameraX += 0.02f; // > win3DOverlay_cameraPositionTolerance (0.01)

    assertFalse(app.allSolarImpacts.win3DOverlay_cameraMatches());
  }

  @Test
  void cameraMatches_rejectsADifferentProjectionType_evenWithNoOtherDrift () {
    app.allSolarImpacts.win3DOverlay_recordCameraState();
    app.WIN3D.projectionTypeIndex = (app.WIN3D.projectionTypeIndex == 0) ? 1 : 0;

    assertFalse(app.allSolarImpacts.win3DOverlay_cameraMatches());
  }

  // ================= win3DOverlay_recordAnalysisState / win3DOverlay_dataFresh ========
  // Same self-consistent-baseline reasoning as above: win3DOverlay_
  // recordAnalysisState() copies the live STUDY/TIME/STATION/colorscale
  // fields (and the model generation counters) it reads.

  @Test
  void dataFresh_isFalse_beforeAnyAnalysisHasEverBeenRecorded () {
    assertFalse(app.allSolarImpacts.win3DOverlay_dataFresh());
  }

  @Test
  void dataFresh_isTrue_rightAfterRecordingTheLiveState () {
    app.allSolarImpacts.win3DOverlay_recordAnalysisState();
    assertTrue(app.allSolarImpacts.win3DOverlay_dataFresh());
  }

  @Test
  void dataFresh_goesFalse_whenAnAnalysisTimeSettingChangesAfterward () {
    app.allSolarImpacts.win3DOverlay_recordAnalysisState();
    app.STUDY.startDay += 1;

    assertFalse(app.allSolarImpacts.win3DOverlay_dataFresh());
  }

  @Test
  void dataFresh_goesFalse_whenTheModelChanges () {
    app.allSolarImpacts.win3DOverlay_recordAnalysisState();
    app.model_changed(); // bumps allFaces/allModel1Ds/Terrain.winCacheGeneration

    assertFalse(app.allSolarImpacts.win3DOverlay_dataFresh());
  }

  // ================= win3DOverlay_resyncGenerationAfterResize ===========================
  // Regression coverage for the "Enlarge 3D Viewport hides the solar-impact
  // overlay" bug: update_frame_layout.pde calls model_changed() purely to
  // invalidate WIN3D's retained-mode caches for its freshly-recreated
  // graphics context (see that file's own comment) - not because the
  // model's geometry actually changed - which bumps the exact
  // winCacheGeneration counters win3DOverlay_dataFresh() reads as its "has
  // the model changed" signal. update_frame_layout() itself isn't directly
  // testable here (its createGraphics() call needs a real sketch surface -
  // see FileSelectedTest.java's own comment on the identical limitation),
  // so this exercises the fix at the level it actually operates: the
  // generation counters the resize path bumps, and the resync call that
  // immediately follows it there.

  @Test
  void resyncGenerationAfterResize_catchesUpTheRecordedCountersToTheCurrentOnes () {
    app.allFaces.winCacheGeneration = 5;
    app.allModel1Ds.winCacheGeneration = 7;
    app.Terrain.winCacheGeneration = 3;

    app.allSolarImpacts.win3DOverlay_resyncGenerationAfterResize();

    assertEquals(5, app.allSolarImpacts.win3DOverlay_facesGeneration);
    assertEquals(7, app.allSolarImpacts.win3DOverlay_model1DsGeneration);
    assertEquals(3, app.allSolarImpacts.win3DOverlay_terrainGeneration);
  }

  @Test
  void dataFresh_survivesAResizeTriggeredModelChanged_onceResynced () {
    app.allSolarImpacts.win3DOverlay_recordAnalysisState();
    assertTrue(app.allSolarImpacts.win3DOverlay_dataFresh(), "sanity: freshly recorded state must be fresh");

    app.model_changed(); // what update_frame_layout.pde calls for its graphics-context reason, not a real edit
    assertFalse(app.allSolarImpacts.win3DOverlay_dataFresh(), "a generation bump alone looks exactly like a real edit without the fix");

    app.allSolarImpacts.win3DOverlay_resyncGenerationAfterResize();
    assertTrue(app.allSolarImpacts.win3DOverlay_dataFresh(), "resync must restore freshness after a pure resize-triggered bump");
  }

  // ================= win3DOverlay_isFresh =================================================

  @Test
  void isFresh_requiresBothTheDataAndTheCameraToMatch () {
    assertFalse(app.allSolarImpacts.win3DOverlay_isFresh()); // neither recorded yet

    app.allSolarImpacts.win3DOverlay_recordAnalysisState();
    assertFalse(app.allSolarImpacts.win3DOverlay_isFresh(), "data fresh, but camera never recorded");

    app.allSolarImpacts.win3DOverlay_recordCameraState();
    assertTrue(app.allSolarImpacts.win3DOverlay_isFresh(), "now both match");
  }

  // ================= win3DOverlay_needsClearRect ===========================================

  @Test
  void needsClearRect_isFalse_whenNoOverrideHasBeenRequested () {
    app.allSolarImpacts.win3DOverlay_recordAnalysisState();
    app.WIN3D.showSolarImpactOverride = false;

    assertFalse(app.allSolarImpacts.win3DOverlay_needsClearRect());
  }

  @Test
  void needsClearRect_isTrue_whenDataIsFreshCameraMismatchedAndOverrideRequested () {
    app.allSolarImpacts.win3DOverlay_recordAnalysisState();
    app.allSolarImpacts.Image = new PImage[2][5];
    app.WIN3D.impactTypeIndex = 0;
    app.impactDisplayDay = 2;
    app.WIN3D.showSolarImpactOverride = true;
    // Camera deliberately left un-recorded, so win3DOverlay_cameraMatches()
    // is false - the exact "explicit cycling request, but the camera
    // doesn't match" case this is meant to catch.

    assertTrue(app.allSolarImpacts.win3DOverlay_needsClearRect());
  }

  @Test
  void needsClearRect_isFalse_whenTheCameraActuallyMatches_evenWithAnOverrideRequested () {
    app.allSolarImpacts.win3DOverlay_recordAnalysisState();
    app.allSolarImpacts.win3DOverlay_recordCameraState();
    app.allSolarImpacts.Image = new PImage[2][5];
    app.WIN3D.showSolarImpactOverride = true;

    assertFalse(app.allSolarImpacts.win3DOverlay_needsClearRect(), "a matching camera never needs the clearing rect");
  }

  @Test
  void needsClearRect_isFalse_whenTheRequestedDayIsOutOfBounds () {
    app.allSolarImpacts.win3DOverlay_recordAnalysisState();
    app.allSolarImpacts.Image = new PImage[2][5];
    app.WIN3D.impactTypeIndex = 0;
    app.impactDisplayDay = 99; // out of bounds for a 5-long row
    app.WIN3D.showSolarImpactOverride = true;

    assertFalse(app.allSolarImpacts.win3DOverlay_needsClearRect());
  }

  // ================= win3DOverlay_rawValuesAt ==============================
  // Matrix_ARGB/dayValuesMUL/total_Matrix_ARGB are normally only filled by
  // calculate_Impact_CurrentPreBaked() itself, which needs a full climate-
  // data/geometry setup this test doesn't have - so these build the same
  // shapes that function builds by hand instead, matching the day-index
  // convention it uses (dayIndex 0 is the summary/total slot, "j = -1" per
  // that function's own comment; dayIndex j + 1 for day j).

  private void putDay (int dayIndex, int q, int x, int y, float a, float r, float g, float b, float valuesMUL) {
    if (app.allSolarImpacts.Matrix_ARGB == null) {
      app.allSolarImpacts.Matrix_ARGB = new float[dayIndex + 1][][][][];
      app.allSolarImpacts.dayValuesMUL = new float[dayIndex + 1];
    }
    if (app.allSolarImpacts.Matrix_ARGB[dayIndex] == null) {
      float[][][][] day = new float[2][4][10][10];
      for (float[][][] qq : day) for (float[][] c : qq) for (float[] row : c) java.util.Arrays.fill(row, app.FLOAT_undefined);
      app.allSolarImpacts.Matrix_ARGB[dayIndex] = day;
    }
    app.allSolarImpacts.Matrix_ARGB[dayIndex][q][0][x][y] = a;
    app.allSolarImpacts.Matrix_ARGB[dayIndex][q][1][x][y] = r;
    app.allSolarImpacts.Matrix_ARGB[dayIndex][q][2][x][y] = g;
    app.allSolarImpacts.Matrix_ARGB[dayIndex][q][3][x][y] = b;
    app.allSolarImpacts.dayValuesMUL[dayIndex] = valuesMUL;
  }

  @Test
  void rawValuesAt_appliesThatDaysOwnValuesMUL_forASpecificDay () {
    putDay(1, 0, 3, 4, 5f, 1f, 2f, 3f, 2f);

    float[] v = app.allSolarImpacts.win3DOverlay_rawValuesAt(0, 1, 3, 4);

    assertNotNull(v);
    assertEquals(10f, v[0], 0.0001f); // A: 5*2
    assertEquals(2f, v[1], 0.0001f);  // R: 1*2
    assertEquals(4f, v[2], 0.0001f);  // G: 2*2
    assertEquals(6f, v[3], 0.0001f);  // B: 3*2
  }

  @Test
  void rawValuesAt_isNull_forAPixelTheHourlyLoopNeverTouched () {
    putDay(1, 0, 3, 4, 5f, 1f, 2f, 3f, 2f); // only (3,4) was ever set

    assertNull(app.allSolarImpacts.win3DOverlay_rawValuesAt(0, 1, 0, 0));
  }

  @Test
  void rawValuesAt_isNull_whenAnotherImpactTypeWasNeverSetThatDay () {
    putDay(1, 0, 3, 4, 5f, 1f, 2f, 3f, 2f); // only Impact_ACTIVE (q=0) was set

    assertNull(app.allSolarImpacts.win3DOverlay_rawValuesAt(1, 1, 3, 4));
  }

  @Test
  void rawValuesAt_dividesByTheDayCount_forTheSummaryImage () {
    app.allSolarImpacts.total_Matrix_ARGB = new float[2][4][10][10];
    app.allSolarImpacts.total_Matrix_ARGB[0][0][3][4] = 20f;
    app.allSolarImpacts.total_Matrix_ARGB[0][1][3][4] = 4f;
    app.allSolarImpacts.total_Matrix_ARGB[0][2][3][4] = 8f;
    app.allSolarImpacts.total_Matrix_ARGB[0][3][3][4] = 12f;
    app.STUDY.startDay = 0;
    app.STUDY.endDay = 4;

    float[] v = app.allSolarImpacts.win3DOverlay_rawValuesAt(0, 0, 3, 4);

    assertNotNull(v);
    assertEquals(5f, v[0], 0.0001f);  // 20/4
    assertEquals(1f, v[1], 0.0001f);  // 4/4
    assertEquals(2f, v[2], 0.0001f);  // 8/4
    assertEquals(3f, v[3], 0.0001f);  // 12/4
  }

  @Test
  void rawValuesAt_isNull_whenTheSummaryPixelSumsToExactlyZero () {
    // A pixel the hourly loop touched every day (so A isn't FLOAT_undefined)
    // but whose net total comes out to exactly 0 - the same "no real data,
    // show the gray fallback" case calculate_Impact_CurrentPreBaked() itself
    // tests for with Image_A != 0.
    app.allSolarImpacts.total_Matrix_ARGB = new float[2][4][10][10];
    app.allSolarImpacts.total_Matrix_ARGB[0][0][0][0] = 0f;
    app.STUDY.startDay = 0;
    app.STUDY.endDay = 4;

    assertNull(app.allSolarImpacts.win3DOverlay_rawValuesAt(0, 0, 0, 0));
  }

  @Test
  void rawValuesAt_isNull_forADayThatWasNeverComputedThisRun () {
    app.allSolarImpacts.Matrix_ARGB = new float[3][][][][]; // slots 1, 2 both left null

    assertNull(app.allSolarImpacts.win3DOverlay_rawValuesAt(0, 1, 3, 4));
  }

  @Test
  void rawValuesAt_isNull_forAnOutOfRangeDayIndex_ratherThanThrowing () {
    putDay(1, 0, 3, 4, 5f, 1f, 2f, 3f, 2f);

    assertDoesNotThrow(() -> assertNull(app.allSolarImpacts.win3DOverlay_rawValuesAt(0, 99, 3, 4)));
  }

  @Test
  void rawValuesAt_isNull_beforeAnythingHasEverBeenComputed () {
    assertNull(app.allSolarImpacts.win3DOverlay_rawValuesAt(0, 1, 0, 0));
    assertNull(app.allSolarImpacts.win3DOverlay_rawValuesAt(0, 0, 0, 0));
  }
}
