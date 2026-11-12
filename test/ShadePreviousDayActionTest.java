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
    app.impactDisplayDay = 0; // its own bare-construction default
    app.SHADE_HOUR_ANGLE = app.SHADE_FIRST_HOUR;
    app.SHADE_DATE_ANGLE = 0;

    String hint = app.runScriptLine("Shade Previous Day");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(app.STUDY.endDay, app.impactDisplayDay, "0 - 1 = -1, which wraps to STUDY.endDay (its own \"< 0\" branch)");
    // SHADE_HOUR_ANGLE is left untouched - "Shade Previous Day" only
    // ever drives impactDisplayDay, not the hour.
    assertEquals(app.SHADE_FIRST_HOUR, app.SHADE_HOUR_ANGLE);
    // sync_SHADE_DATE_ANGLE() via impactDayToDayOfYear(STUDY.endDay=12),
    // TIME.beginDay=0, STUDY.dayIncrement=30.5:
    //   j = 12 - 1 = 11
    //   now_j = (11 * 30 + 0 + 365) % 365 = 695 % 365 = 330
    //   angle = (int) (360 * ((286 + 330) % 365) / 365.0)
    //         = (int) (360 * 251 / 365.0) = 247
    assertEquals(247, app.SHADE_DATE_ANGLE);
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
