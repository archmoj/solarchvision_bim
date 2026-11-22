import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// "Shade Previous Day" (actions.pde) -> previousShadeDay()
// (shadeViewport3D.pde) -> callAction("Previous Impact Day") was at 0%
// coverage - its "Shade Next Day"/nextShadeDay() sibling is already
// covered by WIN3DActionsTest.java's own
// shadeNextDay_advancesImpactDisplayDayAndResyncsTheDateAngle test, but
// nothing exercised the Previous direction, including its own "wrap
// backward past 0 to STUDY.endDay" branch (impactDisplayDay -= 1; if
// (impactDisplayDay < 0) impactDisplayDay = STUDY.endDay;). Same style
// as that existing test: confirm the hint isn't UnrecognizedCommand
// (the action name itself is registered) and hand-compute the resulting
// SHADE_DATE_ANGLE via impactDayToDayOfYear()/sync_SHADE_DATE_ANGLE()'s
// own real formula (see ImpactDayToDayOfYearTest.java) rather than
// asserting a number with no derivation.
class ShadePreviousDayActionTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see WIN3DActionsTest.java's own setUp comment
    app.build_allActions();
  }

  @Test
  void shadePreviousDay_fromDayZero_wrapsBackwardToStudyEndDay () {
    // sync_SHADE_DATE_ANGLE() derives SHADE_DATE_ANGLE from
    // TIME's own (year, month, day) anchor, not TIME.beginDay - pinned
    // to a fixed date here (rather than TIME's bare-construction,
    // wall-clock default) so this test's own expected angle doesn't
    // depend on what day it happens to run.
    app.TIME.year = 2025;
    app.TIME.month = 3;
    app.TIME.day = 21;
    app.impactDisplayDay = 0; // its own bare-construction default
    app.SHADE_HOUR_ANGLE = app.SHADE_FIRST_HOUR;
    app.SHADE_DATE_ANGLE = 0;

    String hint = app.runScriptLine("Shade Previous Day");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(app.STUDY.endDay, app.impactDisplayDay, "0 - 1 = -1, which wraps to STUDY.endDay (its own \"< 0\" branch)");
    // SHADE_HOUR_ANGLE is left untouched - "Shade Previous Day" only
    // ever drives impactDisplayDay, not the hour.
    assertEquals(app.SHADE_FIRST_HOUR, app.SHADE_HOUR_ANGLE);
    // sync_SHADE_DATE_ANGLE() via impactDayToRealDate(STUDY.endDay=12),
    // off the 2025-03-21 anchor above, STUDY.dayIncrement=30.5:
    //   j = 12 - 1 = 11
    //   rawDayOffset = 11 * (long) 30.5 = 11 * 30 = 330
    //   realDate = 2025-03-21 + 330 real days = 2026-02-14
    //   angle = dateAngleFromRealDate(2026, 2, 14) = 325
    // (cross-checked against a Python simulation of dateAngleFromRealDate)
    assertEquals(325, app.SHADE_DATE_ANGLE);
  }

  @Test
  void shadePreviousDay_fromALaterDay_justStepsBackByOne_noWrap () {
    app.impactDisplayDay = 5;

    app.runScriptLine("Shade Previous Day");

    assertEquals(4, app.impactDisplayDay, "an ordinary step back - the wrap-at-0 branch doesn't apply here");
  }

  @Test
  void shadePreviousDay_setsShowSolarImpactOverride () {
    app.WIN3D.showSolarImpactOverride = false;

    app.runScriptLine("Shade Previous Day");

    assertTrue(app.WIN3D.showSolarImpactOverride);
  }
}
