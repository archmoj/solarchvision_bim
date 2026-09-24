import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// The delta-based callbacks (applyPosValue/applyRotValue/applyScaleValue)
// and a few of the one-offs (applyStudyJEnd, applyLandLoadMesh/Textures,
// applyCurrentCamera, applyCreatePowAll) touch WIN3D.graphics/PImage/model
// state beyond what's practical to assert on here - only their o == n
// guard is covered; Move3D/Rotate3D/Scale3D's own test files already cover
// the transforms applyPosValue/applyRotValue/applyScaleValue delegate to.
class ReactTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= applyTimeChange =======================================

  @Test
  void applyTimeChange_recomputesBeginDayFromMonthAndDay () {
    app.TIME.month = 6;
    app.TIME.day = 15;

    app.react.applyTimeChange.run(0, 0); // (oldValue, newValue) aren't used by this callback

    assertEquals(app.TIME.convert2Date(6, 15), app.TIME.beginDay);
  }

  @Test
  void applyTimeChange_recomputesDateFromBeginDayAndHour () {
    app.TIME.month = 3;
    app.TIME.day = 21;
    app.TIME.date = 0; // TIME.hour is derived from the date as it stood *before* this call

    app.react.applyTimeChange.run(0, 0);

    float expectedDate = (app.TIME.hour / 24.0f) + ((286 + app.TIME.convert2Date(3, 21)) % 365);
    assertEquals(expectedDate, app.TIME.date, 0.01f);
  }

  @Test
  void applyTimeChange_revisesTheRolloutAndSetsTheEnsembleSampleRangeFromTheForecastRange () {
    app.UI_rollout.update = false;
    app.SampleMember_Start = -1;
    app.SampleMember_End = -1;

    app.react.applyTimeChange.run(0, 0);

    assertTrue(app.UI_rollout.update);
    assertEquals(app.ENSEMBLE_FORECAST_start, app.SampleMember_Start);
    assertEquals(app.ENSEMBLE_FORECAST_end, app.SampleMember_End);
  }

  // ================= applyLocationChange ====================================
  // Regression coverage for the "Latitude/Longitude spinner didn't update
  // the station" fix: this callback is what the GUI-drag path calls.

  @Test
  void applyLocationChange_pushesLocationIntoStation () {
    app.LocationLAT = 45.5f;
    app.LocationLON = -73.6f;

    app.react.applyLocationChange.run(0, 0);

    assertEquals(45.5f, app.STATION.getLatitude(), 0.001f);
    assertEquals(-73.6f, app.STATION.getLongitude(), 0.001f);
  }

  @Test
  void applyLocationChange_revisesWorld_viaUpdateStation () {
    app.LocationLAT = 10;
    app.LocationLON = 20;
    app.WORLD.update = false;

    app.react.applyLocationChange.run(0, 0);

    assertTrue(app.WORLD.update);
  }

  // ================= simple guarded callbacks ================================

  @Test
  void viewChangedOnly_noOp_whenOldEqualsNew () {
    app.WIN3D.update = false;
    app.react.viewChangedOnly.run(5, 5);
    assertFalse(app.WIN3D.update);
  }

  @Test
  void viewChangedOnly_revisesWIN3D_whenChanged () {
    app.WIN3D.update = false;
    app.react.viewChangedOnly.run(5, 6);
    assertTrue(app.WIN3D.update);
  }

  @Test
  void caseBarOnly_noOp_whenOldEqualsNew () {
    app.UI_caseBar.update = false;
    app.react.caseBarOnly.run(1, 1);
    assertFalse(app.UI_caseBar.update);
  }

  @Test
  void caseBarOnly_revisesTheCaseBar_whenChanged () {
    app.UI_caseBar.update = false;
    app.react.caseBarOnly.run(1, 2);
    assertTrue(app.UI_caseBar.update);
  }

  @Test
  void selectionChangedOnly_noOp_whenOldEqualsNew () {
    app.WIN3D.update = false;
    app.react.selectionChangedOnly.run(0, 0);
    assertFalse(app.WIN3D.update);
  }

  @Test
  void selectionChangedOnly_revisesWIN3D_whenChanged () {
    app.WIN3D.update = false; // selection_changed() ends with view_changed() -> WIN3D.revise()
    app.react.selectionChangedOnly.run(0, 1);
    assertTrue(app.WIN3D.update);
  }

  @Test
  void softSelectionChanged_noOp_whenOldEqualsNew () {
    // Select3D.convert_Vertex_to_softSelection() has no simple observable
    // flag, so this only checks the guard itself doesn't throw and that an
    // actual change doesn't throw either.
    assertDoesNotThrow(() -> app.react.softSelectionChanged.run(1, 1));
    assertDoesNotThrow(() -> app.react.softSelectionChanged.run(1, 2));
  }

  @Test
  void impactsUpdateFlag_noOp_whenOldEqualsNew () {
    app.STUDY.Impacts_update = false;
    app.react.impactsUpdateFlag.run(1, 1);
    assertFalse(app.STUDY.Impacts_update);
  }

  @Test
  void impactsUpdateFlag_setsStudyImpactsUpdate_whenChanged () {
    app.STUDY.Impacts_update = false;
    app.react.impactsUpdateFlag.run(0, 1);
    assertTrue(app.STUDY.Impacts_update);
  }

  @Test
  void recalcImpact_noOp_whenOldEqualsNew () {
    app.WIN3D.update = false;
    app.react.recalcImpact.run(3, 3);
    assertFalse(app.WIN3D.update);
  }

  @Test
  void recalcImpact_revisesTheView_whenChanged () {
    // No sections are selected by default, so calculate_Impact_selectedSections()
    // is a genuine no-op loop here - safe to run for real rather than mocking it.
    app.WIN3D.update = false;
    app.react.recalcImpact.run(3, 4);
    assertTrue(app.WIN3D.update);
  }

  // ================= delta-based callbacks: guard only ======================

  @Test
  void applyPosValue_noOp_whenOldEqualsNew () {
    app.should_rebuildFaceGrid = false;
    app.react.applyPosValue.run(2, 2);
    assertFalse(app.should_rebuildFaceGrid);
  }

  @Test
  void applyRotValue_noOp_whenOldEqualsNew () {
    app.should_rebuildFaceGrid = false;
    app.react.applyRotValue.run(2, 2);
    assertFalse(app.should_rebuildFaceGrid);
  }

  @Test
  void applyScaleValue_noOp_whenOldEqualsNew () {
    app.should_rebuildFaceGrid = false;
    app.react.applyScaleValue.run(2, 2);
    assertFalse(app.should_rebuildFaceGrid);
  }
}
