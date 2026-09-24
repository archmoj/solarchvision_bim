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

    assertEquals(233, methodCount, "expected exactly 233 value-modifier methods");
  }

  // ================= Latitude / Longitude: STATION sync regression ========

  @Test
  void latitude_commandLineAction_updatesStationAndSyncsLocationLATBack () {
    app.vm.Latitude(0);

    app.allActions.get("latitude").run(new String[]{"latitude", "45.5"});

    assertEquals(45.5f, app.STATION.getLatitude(), 0.001f);
    assertEquals(45.5f, app.LocationLAT, 0.001f); // update_station(0) syncs it back
  }

  @Test
  void longitude_commandLineAction_updatesStationAndSyncsLocationLONBack () {
    app.vm.Longitude(0);

    app.allActions.get("longitude").run(new String[]{"longitude", "-73.6"});

    assertEquals(-73.6f, app.STATION.getLongitude(), 0.001f);
    assertEquals(-73.6f, app.LocationLON, 0.001f);
  }

  // ================= plain int field, fixed bounds, with OnChange ==========

  @Test
  void beginDay_commandLineAction_setsTimeDay_androundsAndValidates () {
    app.vm.Begin_day(0);
    app.TIME.day = 1;

    app.allActions.get("begin_day").run(new String[]{"begin_day", "45"}); // out of [1, 31]
    assertEquals(1, app.TIME.day);

    app.allActions.get("begin_day").run(new String[]{"begin_day", "15"});
    assertEquals(15, app.TIME.day);
  }

  @Test
  void beginDay_commandLineAction_triggersApplyTimeChange () {
    app.vm.Begin_day(0);
    app.TIME.month = 6;
    app.TIME.day = 1;

    app.allActions.get("begin_day").run(new String[]{"begin_day", "15"});

    assertEquals(app.TIME.convert2Date(6, 15), app.TIME.beginDay);
  }

  // ================= boolean field ==========================================

  @Test
  void booleanField_commandLineAction_setsTheUnderlyingBoolean () {
    app.vm.displayNear_TMYEPW(0);
    app.WORLD.displayNear_TMYEPW = false;

    app.allActions.get("displaynear_tmyepw").run(new String[]{"displaynear_tmyepw", "1"});
    assertTrue(app.WORLD.displayNear_TMYEPW);

    app.allActions.get("displaynear_tmyepw").run(new String[]{"displaynear_tmyepw", "0"});
    assertFalse(app.WORLD.displayNear_TMYEPW);
  }

  // ================= dynamic bounds =========================================

  @Test
  void startYear_dynamicBounds_rejectsAValueOutsideTheCurrentClimateRange () {
    app.vm.Start_year(0);
    app.SampleYear_Start = 1980;

    app.allActions.get("start_year").run(new String[]{"start_year", "1900"}); // below CLIMATE_CWEEDS_start
    assertEquals(1980, app.SampleYear_Start);

    app.allActions.get("start_year").run(new String[]{"start_year", "1975"}); // within range
    assertEquals(1975, app.SampleYear_Start);
  }

  // ================= negative click-step (Math.abs for the command line) ===

  @Test
  void scale_negativeClickStepField_roundsCommandLineInputByItsAbsoluteValue () {
    app.vm.Scale(0);
    app.STUDY.V_scale = 1;

    float roundingStep = (float) Math.abs(-Math.pow(2.0, 1.0 / 2.0));

    app.allActions.get("scale").run(new String[]{"scale", "5"});

    assertEquals(app.funcs.roundTo(5, roundingStep), app.STUDY.V_scale, 0.001f);
  }

  // ================= array-indexed field (allSolidImpacts.R[sectionType]) ===

  @Test
  void solidImpactsR_commandLineAction_writesTheCurrentSectionTypeSlot () {
    app.vm.solidImpacts_R(0);
    int slot = app.allSolidImpacts.sectionType;
    app.allSolidImpacts.R[slot] = 0;

    app.allActions.get("solidimpacts.r").run(new String[]{"solidimpacts.r", "45"});

    assertEquals(45, app.allSolidImpacts.R[slot], 0.001f);
  }

  @Test
  void solidImpactsR_commandLineAction_triggersRecalcImpact () {
    app.vm.solidImpacts_R(0);
    app.WIN3D.update = false;

    app.allActions.get("solidimpacts.r").run(new String[]{"solidimpacts.r", "45"});

    assertTrue(app.WIN3D.update); // via react.recalcImpact -> view_changed()
  }

  // ================= a different one-off OnChange, via its real command ====

  @Test
  void numberOfDaysToPlot_commandLineAction_triggersApplyStudyJEnd () {
    app.vm.Number_of_days_to_plot(0);
    app.STUDY.j_End = 100;
    app.UI_caseBar.update = false;

    app.allActions.get("number_of_days_to_plot").run(new String[]{"number_of_days_to_plot", "200"});

    assertEquals(200, app.STUDY.j_End);
    assertTrue(app.UI_caseBar.update);
  }
}
