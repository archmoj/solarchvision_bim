import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// postProcess_fillGaps() - previously untested - linearly (actually,
// distance-power-weighted - see interpolationWeight's own comment,
// globalVariables.pde) interpolates undefined hourly values between the
// nearest defined value before and the nearest defined value up to
// MAX_SEARCH (6) hours after, for every layer/day/year-or-member slot of
// whichever data source is given. Pure array math - no graphics, no
// file I/O - every expected value below confirmed by hand against the
// real compiled app before writing these assertions.
class PostProcessFillGapsTest {

  private solarchvision_bim app;
  private int numLayers;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    numLayers = app.allLayers.length;
  }

  // climateTypicalYearStart/End default to 1/1 (globalVariables.pde), so
  // the function's own k-dimension loop ("for k < 1 + DATA_end -
  // DATA_start") only ever touches k == 0 here - the smallest fixture
  // that still exercises the real function, not a special case of it.
  private float[][][][] freshTypicalYearArray () {
    float[][][][] values = new float[24][365][numLayers][1];
    for (int h = 0; h < 24; h++) {
      for (int l = 0; l < numLayers; l++) {
        values[h][0][l][0] = app.FLOAT_undefined;
      }
    }
    return values;
  }

  @Test
  void fillsAGap_withADistanceWeightedInterpolation_betweenTheNearestDefinedValuesOnEachSide () {
    app.climateTypicalYearValues = freshTypicalYearArray();
    int layer = app.LAYER_drybulb.id; // any ordinary, non-wind-direction layer
    app.climateTypicalYearValues[0][0][layer][0] = 10f;
    app.climateTypicalYearValues[4][0][layer][0] = 20f;
    // hours 1, 2, 3 stay undefined - a 3-hour gap, well inside MAX_SEARCH

    app.postProcess_fillGaps(app.dataID_climateTypicalYear);

    float[] hour = new float[5];
    for (int h = 0; h < 5; h++) hour[h] = app.climateTypicalYearValues[h][0][layer][0];

    assertEquals(10f, hour[0], 0.0001f, "the original, already-defined value is left untouched");
    assertEquals(20f, hour[4], 0.0001f);
    // hour 2 sits exactly in the middle (2 hours from each side) - the
    // distance weighting is symmetric there regardless of
    // interpolationWeight's own value, so this is the one point worth
    // pinning to an exact expected number by hand rather than only
    // against the real compiled app's own output.
    assertEquals(15f, hour[2], 0.001f, "the exact midpoint of a symmetric gap");
    // hours 1 and 3 are each closer to one side than the other, so
    // interpolationWeight's own distance-power weighting pulls them
    // toward their nearer neighbor (confirmed against the real compiled
    // app, not hand-derived, given the pow()-based formula involved).
    assertEquals(11.7456f, hour[1], 0.001f, "closer to hour 0's own 10 than to hour 4's own 20");
    assertEquals(18.2544f, hour[3], 0.001f, "the mirror image of hour 1 - closer to hour 4's own 20");
    // And indeed a true mirror: equally far from its own 20 as hour 1 is
    // from its own 10.
    assertEquals(20f - hour[3], hour[1] - 10f, 0.001f);
  }

  @Test
  void anHourTooFarFromEitherSide_isLeftUndefined_butANearerOneStillFills () {
    // MAX_SEARCH is a fixed 6 hours (postProcessFillGaps.pde's own
    // comment on it): hour 4's own forward search needs exactly 6 tries
    // to reach hour 10's defined value, which fails the function's own
    // strict "< MAX_SEARCH" check (confirmed directly, not assumed - a
    // boundary this exact is exactly the kind of thing worth checking
    // rather than guessing at) - hours 1 through 4 all stay undefined
    // for that reason. Hour 5 needs only 5 tries, so unlike its
    // immediate neighbor it DOES get filled - on the strength of
    // reaching forward alone, since pre_num (5, backward to hour 0) is
    // no closer.
    app.climateTypicalYearValues = freshTypicalYearArray();
    int layer = app.LAYER_drybulb.id;
    app.climateTypicalYearValues[0][0][layer][0] = 5f;
    app.climateTypicalYearValues[10][0][layer][0] = 15f;

    app.postProcess_fillGaps(app.dataID_climateTypicalYear);

    assertTrue(app.is_undefined(app.climateTypicalYearValues[1][0][layer][0]));
    assertTrue(app.is_undefined(app.climateTypicalYearValues[4][0][layer][0]), "exactly 6 hours from hour 10 - one past what MAX_SEARCH allows");
    assertFalse(app.is_undefined(app.climateTypicalYearValues[5][0][layer][0]), "exactly 5 hours from hour 10 - within MAX_SEARCH");
    assertEquals(10f, app.climateTypicalYearValues[5][0][layer][0], 0.001f, "symmetric midpoint: 5 hours from each side");
  }

  @Test
  void windDirection_interpolatesTheShortWayAroundThe360DegreeWrap () {
    // LAYER_winddir gets its own special-cased branch: 350 -> 10 is
    // actually only a 20-degree turn (the short way, through 0/360), not
    // the 340-degree the raw numbers would otherwise suggest - handled
    // by adding 360 to the later value before interpolating, then
    // wrapping the final result back into [0, 360) with "% 360".
    app.climateTypicalYearValues = freshTypicalYearArray();
    int windLayer = app.LAYER_winddir.id;
    app.climateTypicalYearValues[0][0][windLayer][0] = 350f;
    app.climateTypicalYearValues[4][0][windLayer][0] = 10f;

    app.postProcess_fillGaps(app.dataID_climateTypicalYear);

    // The symmetric midpoint (hour 2, 2 hours from each side) lands
    // exactly on the wrap itself: 360, which "% 360" brings back to 0 -
    // not 180, the midpoint the raw, un-wrapped numbers (350 and 10)
    // would otherwise average to.
    assertEquals(0f, app.climateTypicalYearValues[2][0][windLayer][0], 0.001f);
    assertEquals(350f, app.climateTypicalYearValues[0][0][windLayer][0], 0.0001f);
    assertEquals(10f, app.climateTypicalYearValues[4][0][windLayer][0], 0.0001f);
    // Confirmed against the real compiled app rather than hand-derived -
    // same asymmetric pull toward the nearer side as the non-wind case
    // above, just expressed in degrees past/before the wrap.
    assertEquals(353.4911f, app.climateTypicalYearValues[1][0][windLayer][0], 0.001f);
    assertEquals(6.50885f, app.climateTypicalYearValues[3][0][windLayer][0], 0.001f);
  }

  @Test
  void leavesCurrentDataSource_exactlyAsItWasBeforeTheCall () {
    // desired_DataSource is only ever a parameter here - the function
    // saves and restores whatever currentDataSource the caller actually
    // had, rather than leaving it pointed at whichever source it was
    // just asked to fill gaps in.
    app.climateTypicalYearValues = freshTypicalYearArray();
    app.currentDataSource = app.dataID_climateArchive;

    app.postProcess_fillGaps(app.dataID_climateTypicalYear);

    assertEquals(app.dataID_climateArchive, app.currentDataSource);
  }
}
