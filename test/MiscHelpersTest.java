import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

class MiscHelpersTest {

  private static solarchvision_bim app;
  private static final float EPS = 0.0001f;

  @BeforeAll
  static void setUp () {
    app = new solarchvision_bim();
  }

  // --- is_defined ----------------------------------------------------

  @Test
  void is_defined_isTrueBelowTheMaxDefinedThreshold () {
    assertTrue(app.is_defined(0));
    assertTrue(app.is_defined(-1000000)); // negative values are still "defined"
  }

  @Test
  void is_defined_isFalseAtOrAboveFLOAT_undefined () {
    assertFalse(app.is_defined(app.FLOAT_undefined));
    assertFalse(app.is_defined(app.FLOAT_undefined * 2));
  }

  // --- applyPalDirection -----------------------------------------

  @Test
  void applyPalDirection_passesThroughUnknownDirections () {
    assertEquals(0.3f, app.applyPalDirection(0.3f, 1), EPS);
    assertEquals(0.3f, app.applyPalDirection(0.3f, 0), EPS); // falls through to the default return
  }

  @Test
  void applyPalDirection_reversesForDirectionMinusOne () {
    assertEquals(0.7f, app.applyPalDirection(0.3f, -1), EPS);
  }

  @Test
  void applyPalDirection_compressesIntoTheLowerHalfForDirectionMinusTwo () {
    assertEquals(0.35f, app.applyPalDirection(0.3f, -2), EPS); // 0.5 - 0.5*0.3
  }

  @Test
  void applyPalDirection_compressesIntoTheLowerHalfForDirectionTwo () {
    assertEquals(0.15f, app.applyPalDirection(0.3f, 2), EPS); // 0.5*0.3
  }

  // --- Sun3D.wrapDayIndex ------------------------------------------

  @Test
  void wrapDayIndex_isAnIdentityWithinTheYear () {
    assertEquals(0, app.Sun3D.wrapDayIndex(0));
    assertEquals(365, app.Sun3D.wrapDayIndex(365)); // 365 is now a valid in-range index (366-day year)
  }

  @Test
  void wrapDayIndex_wrapsForwardPastTheEndOfTheYear () {
    assertEquals(0, app.Sun3D.wrapDayIndex(366));
    assertEquals(0, app.Sun3D.wrapDayIndex(732));  // two full (366-day) years
    assertEquals(268, app.Sun3D.wrapDayIndex(1000));
  }

  @Test
  void wrapDayIndex_wrapsBackwardForNegativeDays () {
    assertEquals(365, app.Sun3D.wrapDayIndex(-1));
  }

  @Test
  void wrapDayIndex_secondWraparoundClauseHandlesDaysMoreThanAYearNegative () {
    // rawDay + 366 is itself still negative when rawDay < -366, so
    // Java's % (which keeps the sign of the dividend, unlike Python's)
    // leaves `day` negative after the first mod - this is exactly what
    // the function's second `if (day < 0)` clause exists to catch.
    assertEquals(365, app.Sun3D.wrapDayIndex(-367));
    assertEquals(98, app.Sun3D.wrapDayIndex(-1000));
  }
}
