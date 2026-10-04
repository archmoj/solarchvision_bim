import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

import java.lang.reflect.Method;

// Every ValueModifier method's created == 1 branch calls
// UI_rollout.Spinner(...), which - like this.Spinner(...)/_Spinner(...)
// themselves - touches live mouse/rendering state and isn't unit-testable
// as-is (see test/README.md). The created == 0 (command-line registration)
// branch is pure putValueAction wiring, and is what's covered here: a
// smoke test over every method via reflection, plus focused tests for a
// representative sample of the distinct patterns they follow (plain
// bounds, boolean, dynamic bounds, a negative click-step, and the
// Latitude/Longitude station-sync fix).
class ValueModifierTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>();
  }

  // ================= smoke test: every method registers cleanly ===========

  @Test
  void everyValueModifierMethod_registersAtLeastOneNewCommandName_withoutThrowing () throws Exception {
    Method[] methods = app.vm.getClass().getDeclaredMethods();

    int methodCount = 0;
    int previousSize = app.allActions.size();

    for (Method m : methods) {
      if (m.isSynthetic() || m.isBridge()) continue;
      if (m.getParameterCount() != 1 || m.getParameterTypes()[0] != int.class) continue;

      m.setAccessible(true);
      try {
        m.invoke(app.vm, 0);
      } catch (Exception e) {
        fail("vm." + m.getName() + "(0) threw: " + e.getCause(), e.getCause());
      }

      int newSize = app.allActions.size();
      assertTrue(newSize > previousSize,
        "vm." + m.getName() + "(0) did not add a new command name (possible key collision)");
      previousSize = newSize;

      methodCount++;
    }

    assertEquals(232, methodCount, "expected exactly 232 value-modifier methods"); // +1: creatorConeDegree, added with Cone
  }

  // ================= Latitude / Longitude: STATION sync regression ========

  @Test
  void latitude_commandLineAction_updatesStationAndSyncslocationLatitudeBack () {
    app.vm.locationLatitude(0);

    app.allActions.get("location_latitude").run(new String[]{"location_latitude", "45.5"});

    assertEquals(45.5f, app.STATION.getLatitude(), 0.001f);
    assertEquals(45.5f, app.locationLatitude, 0.001f); // update_station(0) syncs it back
  }

  @Test
  void longitude_commandLineAction_updatesStationAndSyncslocationLongitudeBack () {
    app.vm.locationLongitude(0);

    app.allActions.get("location_longitude").run(new String[]{"location_longitude", "-73.6"});

    assertEquals(-73.6f, app.STATION.getLongitude(), 0.001f);
    assertEquals(-73.6f, app.locationLongitude, 0.001f);
  }

  // ================= plain int field, fixed bounds, with OnChange ==========

  @Test
  void beginDay_commandLineAction_setsTimeDay_androundsAndValidates () {
    app.vm.day(0);
    app.TIME.day = 1;

    app.allActions.get("day").run(new String[]{"day", "45"}); // out of [1, 31]
    assertEquals(1, app.TIME.day);

    app.allActions.get("day").run(new String[]{"day", "15"});
    assertEquals(15, app.TIME.day);
  }

  @Test
  void beginDay_commandLineAction_triggersApplyTimeChange () {
    app.vm.day(0);
    app.TIME.month = 6;
    app.TIME.day = 1;

    app.allActions.get("day").run(new String[]{"day", "15"});

    assertEquals(app.TIME.convert2Date(6, 15), app.TIME.beginDay);
  }

  // ================= boolean field ==========================================

  @Test
  void booleanField_commandLineAction_setsTheUnderlyingBoolean () {
    app.vm.climateTypicalYearDisplayNear(0);
    app.WORLD.climateTypicalYearDisplayNear = false;

    app.allActions.get("climate_typical_year_display_near").run(new String[]{"climate_typical_year_display_near", "1"});
    assertTrue(app.WORLD.climateTypicalYearDisplayNear);

    app.allActions.get("climate_typical_year_display_near").run(new String[]{"climate_typical_year_display_near", "0"});
    assertFalse(app.WORLD.climateTypicalYearDisplayNear);
  }

  // ================= dynamic bounds =========================================

  @Test
  void startYear_dynamicBounds_rejectsAValueOutsideTheCurrentClimateRange () {
    app.vm.sampleYearStart(0);
    app.sampleYearStart = 1980;

    app.allActions.get("sample_year_start").run(new String[]{"sample_year_start", "1900"}); // below climateEngineeringStart
    assertEquals(1980, app.sampleYearStart);

    app.allActions.get("sample_year_start").run(new String[]{"sample_year_start", "1975"}); // within range
    assertEquals(1975, app.sampleYearStart);
  }

  // ================= negative click-step (Math.abs for the command line) ===

  @Test
  void scale_negativeClickStepField_roundsCommandLineInputByItsAbsoluteValue () {
    app.vm.verticalUnitScale(0);
    app.STUDY.verticalUnitScale = 1;

    float roundingStep = (float) Math.abs(-Math.pow(2.0, 1.0 / 2.0));

    app.allActions.get("vertical_unit_scale").run(new String[]{"vertical_unit_scale", "5"});

    assertEquals(app.funcs.roundTo(5, roundingStep), app.STUDY.verticalUnitScale, 0.001f);
  }

  // ================= array-indexed field (allSolidImpacts.R[sectionType]) ===

  @Test
  void solidImpactsR_commandLineAction_writesTheCurrentSectionTypeSlot () {
    app.vm.SolidImpacts_r(0);
    int slot = app.allSolidImpacts.sectionType;
    app.allSolidImpacts.R[slot] = 0;

    app.allActions.get("solid_impacts_r").run(new String[]{"solid_impacts_r", "45"});

    assertEquals(45, app.allSolidImpacts.R[slot], 0.001f);
  }

  @Test
  void solidImpactsR_commandLineAction_triggersRecalcImpact () {
    app.vm.SolidImpacts_r(0);
    app.WIN3D.update = false;

    app.allActions.get("solid_impacts_r").run(new String[]{"solid_impacts_r", "45"});

    assertTrue(app.WIN3D.update); // via react.recalcImpact -> view_changed()
  }

  // ================= a different one-off OnChange, via its real command ====

  @Test
  void numberOfDaysToPlot_commandLineAction_triggersApplyStudyJEnd () {
    app.vm.endDay(0);
    app.STUDY.endDay = 100;
    app.UI_caseBar.update = false;

    app.allActions.get("end_day").run(new String[]{"end_day", "200"});

    assertEquals(200, app.STUDY.endDay);
    assertTrue(app.UI_caseBar.update);
  }
}
