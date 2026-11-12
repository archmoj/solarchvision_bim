import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// impactDayToDayOfYear(day) (shadeViewport3D.pde) is pure arithmetic -
// no STUDY/TIME mutation, just reads STUDY.dayIncrement and TIME.beginDay.
// It's already reached indirectly by other tests (Tropo3DTest.java/
// WIN3DTest.java, via sync_SHADE_DATE_ANGLE()/selectedDayHasForecastAvailable()),
// but always with an ordinary, already-non-negative day - never anything
// that drives its own "now_j < 0" wraparound branch, which stayed
// uncovered as a result.
//
// Its sibling branch, "now_j >= 365", is deliberately NOT exercised here:
// now_j comes from "... % 365" (a positive divisor), and Java's %
// operator never returns a value whose absolute value reaches the
// divisor for any int dividend - so that branch is unreachable by
// construction, not just untested by coincidence.
class ImpactDayToDayOfYearTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void dayOne_mapsDirectlyToBeginDay () {
    app.TIME.beginDay = 100;

    assertEquals(100, app.impactDayToDayOfYear(1));
  }

  @Test
  void dayZero_theTotalCase_behavesExactlyLikeDayOne () {
    // Its own comment: "use beginDay for the case of total" - day 0 maps
    // through the identical j == 0 path day 1 does, not a separate rule.
    app.TIME.beginDay = 100;

    assertEquals(app.impactDayToDayOfYear(1), app.impactDayToDayOfYear(0));
  }

  @Test
  void anOrdinaryLaterDay_advancesByWholeDayIncrementStepsFromBeginDay () {
    app.TIME.beginDay = 0;
    // STUDY.dayIncrement defaults to 30.5, truncated to 30 by int(...)
    // inside the function itself - day 5 (j=4): (4*30 + 0 + 365) % 365
    // = 485 % 365 = 120.
    assertEquals(120, app.impactDayToDayOfYear(5));
  }

  @Test
  void aNegativeDay_wrapsForwardIntoAPositiveDayOfYear () {
    app.TIME.beginDay = 0;
    // day -50 (j=-51): (-51*30 + 0 + 365) % 365 = -1165 % 365 = -70
    // (Java's % keeps the dividend's sign) -> the "now_j < 0" branch then
    // wraps it forward: (-70 + 365) % 365 = 295.
    assertEquals(295, app.impactDayToDayOfYear(-50));
  }
}
