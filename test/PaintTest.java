import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

// Exercises the pure color/opacity functions in PAINT.pde: getOpacity
// (a simple scale-and-clamp), every one of the piecewise color ramps
// (WBGRW, BGR, DBGR, DWBGR, DWYR, VDWBGR, DRYWCBD, DBCW, DRYW), and a
// handful of getColorStyle's dispatch/remap branches. Reached through
// the pre-constructed `app.PAINT` field.
//
// WYRD is the one ramp left untested - its body is the same shape as
// DRYW/DBCW (a 4-segment ramp built from `_variable *= -3`) with a
// different input transform, so it wouldn't add much beyond what DRYW
// and DBCW already establish about that pattern.
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

  // --- WBGRW (a 6-segment, palindromic ramp) --------------------------

  @Test
  void wbgrw_cyclesThroughWhiteBlueGreenYellowRedAndBackToWhite () {
    // WBGRW scales by 600 across 6 segments of 100 each, and (unlike
    // BGR) both ends land on white - it's a cyclic palette.
    assertArrayEquals(new float[]{255, 255, 255, 255}, app.PAINT.WBGRW(0f), EPS);
    assertArrayEquals(new float[]{255, 0, 0, 255}, app.PAINT.WBGRW(1f / 6), EPS);     // blue
    assertArrayEquals(new float[]{255, 0, 255, 255}, app.PAINT.WBGRW(2f / 6), EPS);   // cyan
    assertArrayEquals(new float[]{255, 0, 255, 0}, app.PAINT.WBGRW(3f / 6), EPS);     // green
    assertArrayEquals(new float[]{255, 255, 255, 0}, app.PAINT.WBGRW(4f / 6), EPS);   // yellow
    assertArrayEquals(new float[]{255, 255, 0, 0}, app.PAINT.WBGRW(5f / 6), EPS);     // red
    assertArrayEquals(new float[]{255, 255, 255, 255}, app.PAINT.WBGRW(1f), EPS);
  }

  // --- DBGR (Dark start, then Blue-Green-Red) ---------------------

  @Test
  void dbgr_startsAtBlackInsteadOfBlue () {
    assertArrayEquals(new float[]{255, 0, 0, 0}, app.PAINT.DBGR(0f), EPS);      // black
    assertArrayEquals(new float[]{255, 0, 0, 255}, app.PAINT.DBGR(0.2f), EPS);  // blue
    assertArrayEquals(new float[]{255, 0, 255, 255}, app.PAINT.DBGR(0.4f), EPS); // cyan
    assertArrayEquals(new float[]{255, 0, 255, 0}, app.PAINT.DBGR(0.6f), EPS);  // green
    assertArrayEquals(new float[]{255, 255, 255, 0}, app.PAINT.DBGR(0.8f), EPS); // yellow
    assertArrayEquals(new float[]{255, 255, 0, 0}, app.PAINT.DBGR(1.0f), EPS);  // red
  }

  // --- DWBGR (Dark, White, then Blue-Green-Red) --------------------

  @Test
  void dwbgr_insertsABlackThenWhiteStageBeforeTheBGRRun () {
    assertArrayEquals(new float[]{255, 0, 0, 0}, app.PAINT.DWBGR(0f), EPS);        // black
    assertArrayEquals(new float[]{255, 255, 255, 255}, app.PAINT.DWBGR(1f / 6), EPS); // white
    assertArrayEquals(new float[]{255, 0, 0, 255}, app.PAINT.DWBGR(2f / 6), EPS);   // blue
    assertArrayEquals(new float[]{255, 0, 255, 255}, app.PAINT.DWBGR(3f / 6), EPS); // cyan
    assertArrayEquals(new float[]{255, 0, 255, 0}, app.PAINT.DWBGR(4f / 6), EPS);   // green
    assertArrayEquals(new float[]{255, 255, 255, 0}, app.PAINT.DWBGR(5f / 6), EPS); // yellow
    assertArrayEquals(new float[]{255, 255, 0, 0}, app.PAINT.DWBGR(1f), EPS);       // red
  }

  // --- DWYR (Dark-White-Yellow-Red, with a half-saturated clamp) -----

  @Test
  void dwyr_clampsToHalfIntensityRedPastTheEndOfItsRange () {
    assertArrayEquals(new float[]{255, 0, 0, 0}, app.PAINT.DWYR(0f), EPS);      // black
    assertArrayEquals(new float[]{255, 255, 255, 255}, app.PAINT.DWYR(0.25f), EPS); // white
    assertArrayEquals(new float[]{255, 255, 255, 0}, app.PAINT.DWYR(0.5f), EPS);  // yellow
    assertArrayEquals(new float[]{255, 255, 0, 0}, app.PAINT.DWYR(0.75f), EPS);  // full red
    // Past the end of the defined range it doesn't clamp to full red
    // like the other ramps do - it clamps to R=127 (half intensity), a
    // deliberate "0.5 * v" in the source, not an oversight.
    assertArrayEquals(new float[]{255, 127, 0, 0}, app.PAINT.DWYR(1.0f), EPS);
  }

  // --- VDWBGR (Very-dark: adds a magenta stage below 0) -------------

  @Test
  void vdwbgr_addsAMagentaStageBelowZeroBeforeTheDWBGRRun () {
    assertArrayEquals(new float[]{255, 255, 0, 255}, app.PAINT.VDWBGR(0f), EPS);       // magenta
    assertArrayEquals(new float[]{255, 0, 0, 0}, app.PAINT.VDWBGR(1f / 7), EPS);       // black
    assertArrayEquals(new float[]{255, 255, 255, 255}, app.PAINT.VDWBGR(2f / 7), EPS); // white
    assertArrayEquals(new float[]{255, 0, 0, 255}, app.PAINT.VDWBGR(3f / 7), EPS);     // blue
    assertArrayEquals(new float[]{255, 0, 255, 255}, app.PAINT.VDWBGR(4f / 7), EPS);   // cyan
    assertArrayEquals(new float[]{255, 0, 255, 0}, app.PAINT.VDWBGR(5f / 7), EPS);     // green
    assertArrayEquals(new float[]{255, 255, 255, 0}, app.PAINT.VDWBGR(6f / 7), EPS);   // yellow
    assertArrayEquals(new float[]{255, 255, 0, 0}, app.PAINT.VDWBGR(1f), EPS);         // red
  }

  // --- DRYWCBD (a full diverging ramp, centered on white at j=0) -----

  @Test
  void drywcbd_isASymmetricDivergingRampCenteredOnWhite () {
    assertArrayEquals(new float[]{255, 255, 255, 255}, app.PAINT.DRYWCBD(0f), EPS); // center: white
    assertArrayEquals(new float[]{255, 255, 0, 0}, app.PAINT.DRYWCBD(-2f / 1.5f), EPS); // negative side: red
    assertArrayEquals(new float[]{255, 0, 0, 255}, app.PAINT.DRYWCBD(2f / 1.5f), EPS);  // positive side: blue
  }

  @Test
  void drywcbd_clampsToDimRedOrDimBluePastItsRange () {
    assertArrayEquals(new float[]{255, 63, 0, 0}, app.PAINT.DRYWCBD(-3f), EPS); // far negative: dim red
    assertArrayEquals(new float[]{255, 0, 0, 63}, app.PAINT.DRYWCBD(3f), EPS);  // far positive: dim blue
  }

  // --- DBCW vs DRYW (same ramp shape, R and B channels swapped) ------

  @Test
  void dbcw_isDRYWWithRedAndBlueChannelsSwapped () {
    // DBCW's body is textually identical to DRYW's, but ends by
    // swapping COL[1] (R) and COL[3] (B) - turning a black-red-
    // yellow-white ramp into a black-blue-cyan-white one.
    float midpoint = 1 - (2.5f / 3f); // lands inside DRYW's "-2 to -1" ramp segment

    float[] dryw = app.PAINT.DRYW(midpoint);
    float[] dbcw = app.PAINT.DBCW(midpoint);

    assertArrayEquals(new float[]{255, 127.5f, 0, 0}, dryw, EPS);   // dim red
    assertArrayEquals(new float[]{255, 0, 0, 127.5f}, dbcw, EPS);   // dim blue - R and B swapped
    assertEquals(dryw[2], dbcw[2], EPS); // the green channel is untouched by the swap
  }

  // --- getColorStyle: a couple more dispatch/remap checks -----------

  @Test
  void getColorStyle_style6_swapsRedAndBlueOfBGR () {
    // COLOR_STYLE_Current == 6 maps c[1]=COL[3], c[3]=COL[1] - BGR(0) is
    // blue (0,0,255); swapped, it should come out red.
    float[] result = app.PAINT.getColorStyle(6, 0f);
    assertArrayEquals(new float[]{255, 255, 0, 0}, result, EPS);
  }

  @Test
  void getColorStyle_style18_reversesDRYWCBDsChannelsWithARemappedInput () {
    // COLOR_STYLE_Current == 18 calls DRYWCBD(2*(j-0.5)) and reverses
    // its channels (c[1]=COL[3], c[3]=COL[1]) - checked against calling
    // DRYWCBD directly with the same remapped input, so both the input
    // transform and the channel reversal are verified at once.
    float j = 0.5f - (1.3333f / 2f); // -> DRYWCBD input of about -1.3333 (its "red" point)

    float[] direct = app.PAINT.DRYWCBD(2f * (j - 0.5f));
    float[] dispatched = app.PAINT.getColorStyle(18, j);

    assertArrayEquals(new float[]{255, 255, 0, 0}, direct, EPS);     // red
    assertArrayEquals(new float[]{255, 0, 0, 255}, dispatched, EPS); // reversed: blue
  }
}
