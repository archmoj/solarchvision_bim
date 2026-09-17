import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

// Exercises a sample of the pure color/opacity functions in PAINT.pde:
// getOpacity (a simple scale-and-clamp), BGR (one of several piecewise
// color ramps), and getColorStyle's dispatch to one of those ramps.
// Reached through the pre-constructed `app.PAINT` field.
//
// PAINT.pde has ~10 different named color ramps (WBGRW, BGR, DBGR,
// DWBGR, DWYR, VDWBGR, DRYWCBD, DBCW, DRYW, WYRD) that getColorStyle
// dispatches between by an integer style id - only BGR and DRYW are
// covered here as representative samples of the pattern (a 4-6 segment
// piecewise-linear ramp over [0,1], each with its own breakpoints).
// Covering the rest would mostly repeat the same kind of test.
class PaintTest {

  private static solarchvision_bim app;
  private static final float EPS = 0.5f; // ramps land on whole 0-255 color values

  @BeforeAll
  static void setUp () {
    app = new solarchvision_bim();
  }

  // --- getOpacity --------------------------------------------------

  @Test
  void getOpacity_scalesAPercentIntoA0to255Range () {
    assertEquals(0, app.PAINT.getOpacity(0));
    assertEquals(128, app.PAINT.getOpacity(50));
  }

  @Test
  void getOpacity_clampsOutOfRangeInputs () {
    assertEquals(255, app.PAINT.getOpacity(100));  // exactly 256 before clamping
    assertEquals(255, app.PAINT.getOpacity(1000)); // far over
    assertEquals(0, app.PAINT.getOpacity(-10));    // negative
  }

  // --- BGR (a representative color ramp) ------------------------

  @Test
  void bgr_walksBlueCyanGreenYellowRedAcrossItsRange () {
    // BGR scales its input by 400 and steps through 4 segments of 100
    // each; COL is [alpha, R, G, B].
    assertArrayEquals(new float[]{255, 0, 0, 255}, app.PAINT.BGR(0f), EPS);    // blue
    assertArrayEquals(new float[]{255, 0, 255, 255}, app.PAINT.BGR(0.25f), EPS); // cyan
    assertArrayEquals(new float[]{255, 0, 255, 0}, app.PAINT.BGR(0.5f), EPS);  // green
    assertArrayEquals(new float[]{255, 255, 255, 0}, app.PAINT.BGR(0.75f), EPS); // yellow
    assertArrayEquals(new float[]{255, 255, 0, 0}, app.PAINT.BGR(1.0f), EPS);  // red
  }

  @Test
  void bgr_clampsOutOfRangeInputsToTheNearestEnd () {
    assertArrayEquals(new float[]{255, 0, 0, 255}, app.PAINT.BGR(-0.1f), EPS); // below range: still blue
    assertArrayEquals(new float[]{255, 255, 0, 0}, app.PAINT.BGR(1.5f), EPS);  // above range: still red
  }

  // --- getColorStyle dispatch ------------------------------------

  @Test
  void getColorStyle_dispatchesToDRYWWithoutSwappingChannels () {
    // COLOR_STYLE_Current == 15 maps straight through to DRYW's COL[1..3]
    // as c[1..3] (no reordering) - this is exactly the kind of dispatch
    // where an index mix-up (like the one found and fixed in
    // SOLARCHVISION_SolarAtSurface) could hide, so it's checked directly
    // against calling DRYW itself rather than just trusting the wiring.
    float[] direct0 = app.PAINT.DRYW(0f);
    float[] dispatched0 = app.PAINT.getColorStyle(15, 0f);
    assertArrayEquals(direct0, dispatched0, EPS);
    assertArrayEquals(new float[]{255, 0, 0, 0}, dispatched0, EPS); // DRYW(0) is black

    float[] direct1 = app.PAINT.DRYW(1f);
    float[] dispatched1 = app.PAINT.getColorStyle(15, 1f);
    assertArrayEquals(direct1, dispatched1, EPS);
    assertArrayEquals(new float[]{255, 255, 255, 255}, dispatched1, EPS); // DRYW(1) is white
  }
}
