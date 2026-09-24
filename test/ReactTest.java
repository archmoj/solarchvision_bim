import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// The delta-based callbacks (applyPosValue/applyRotValue/applyScaleValue)
// only get their o == n guard covered here - Move3D/Rotate3D/Scale3D's own
// test files already cover the transforms they delegate to for a real
// selection, and building one here would just duplicate that setup.
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

  // ================= one-off callbacks =======================================

  @Test
  void applyStudyJEnd_noOp_whenOldEqualsNew () {
    app.UI_caseBar.update = false;
    app.react.applyStudyJEnd.run(100, 100);
    assertFalse(app.UI_caseBar.update);
  }

  @Test
  void applyStudyJEnd_flagsImpactAndWindRoseImagesForRebuild_whenChanged () {
    app.UI_caseBar.update = false;
    app.allSolarImpacts.rebuild_Image_array = false;
    app.allWindRoses.rebuild_Image_array = false;

    // allSections.resize_solarImpact_array() sizes its array off STUDY.j_End,
    // so this must actually be the field's new value for the call to be safe
    app.STUDY.j_End = 100;

    app.react.applyStudyJEnd.run(90, 100);

    assertTrue(app.UI_caseBar.update);
    assertTrue(app.allSolarImpacts.rebuild_Image_array);
    assertTrue(app.allWindRoses.rebuild_Image_array);
  }

  @Test
  void applyLandLoadMesh_noOp_whenOldEqualsNew () {
    app.should_rebuildFaceGrid = false;
    app.react.applyLandLoadMesh.run(1, 1);
    assertFalse(app.should_rebuildFaceGrid);
  }

  @Test
  void applyLandLoadMesh_rebuildsTheMeshAndFlagsTheModelChanged_whenChanged () {
    // Land3D.update_mesh() falls back to a flat mesh if it can't load real
    // topography files (there are none in a test environment), so this is
    // safe to run for real rather than mocking it.
    app.should_rebuildFaceGrid = false;
    app.react.applyLandLoadMesh.run(0, 1);
    assertTrue(app.should_rebuildFaceGrid);
    assertEquals(app.Land3D.num_rows, app.Land3D.Mesh.length);
  }

  @Test
  void applyLandLoadTextures_noOp_whenOldEqualsNew () {
    app.should_rebuildFaceGrid = false;
    app.react.applyLandLoadTextures.run(1, 1);
    assertFalse(app.should_rebuildFaceGrid);
  }

  @Test
  void applyLandLoadTextures_flagsTheModelChanged_whenChanged () {
    app.should_rebuildFaceGrid = false;
    app.react.applyLandLoadTextures.run(0, 1);
    assertTrue(app.should_rebuildFaceGrid);
  }

  @Test
  void applyCurrentCamera_noOp_whenOldEqualsNew () {
    app.WIN3D.update = false;
    app.react.applyCurrentCamera.run(0, 0);
    assertFalse(app.WIN3D.update);
  }

  @Test
  void applyCurrentCamera_appliesTheCameraAndRevisesTheView_whenChanged () {
    // Cameras() seeds one camera (index 0) via add_first(), so currentCamera
    // == 0 is always valid on a fresh app - safe to call for real.
    app.WIN3D.currentCamera = 0;
    app.WIN3D.position_X = -999;
    app.WIN3D.update = false;

    app.react.applyCurrentCamera.run(-1, 0);

    assertEquals(app.allCameras.get_posX(0), app.WIN3D.position_X, 0.001f);
    assertTrue(app.WIN3D.update);
  }

  @Test
  void applyCreatePowAll_noOp_whenOldEqualsNew () {
    app.UI_rollout.update = false;
    app.react.applyCreatePowAll.run(2, 2);
    assertFalse(app.UI_rollout.update);
  }

  @Test
  void applyCreatePowAll_copiesCreatePowAllIntoXYZ_whenChanged () {
    app.User3D.create_powAll = 3;
    app.User3D.create_powX = 0;
    app.User3D.create_powY = 0;
    app.User3D.create_powZ = 0;
    app.UI_rollout.update = false;

    app.react.applyCreatePowAll.run(1, 3);

    assertEquals(3, app.User3D.create_powX, 0.001f);
    assertEquals(3, app.User3D.create_powY, 0.001f);
    assertEquals(3, app.User3D.create_powZ, 0.001f);
    assertTrue(app.UI_rollout.update);
  }
}
