import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class FilterTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  private boolean filterWithSkyValue (float skyValue, int scenarioOfSky) {
    app.CLIMATE_TMYEPW_values = new float[1][1][1][1];
    app.CLIMATE_TMYEPW_values[0][0][0][0] = skyValue;
    // type_of_filter=0 (not filter_DAILY) keeps the internal scan to
    // just now_i=0, matching the array's single populated slot.
    return app.filter(app.dataID_CLIMATE_TMYEPW, 0, 0, scenarioOfSky, 0, 0, 0);
  }

  @Test
  void scenario4_matchesLowSkyCover () {
    // scenario 4: total_sky <= 3.33
    assertTrue(filterWithSkyValue(2.0f, 4));
    assertFalse(filterWithSkyValue(5.0f, 4));
    assertFalse(filterWithSkyValue(8.0f, 4));
  }

  @Test
  void scenario3_matchesMidRangeSkyCover () {
    // scenario 3: 3.33 < total_sky <= 6.66
    assertFalse(filterWithSkyValue(2.0f, 3));
    assertTrue(filterWithSkyValue(5.0f, 3));
    assertFalse(filterWithSkyValue(8.0f, 3));
  }

  @Test
  void scenario2_matchesHighSkyCover () {
    // scenario 2: total_sky > 6.66
    assertFalse(filterWithSkyValue(2.0f, 2));
    assertFalse(filterWithSkyValue(5.0f, 2));
    assertTrue(filterWithSkyValue(8.0f, 2));
  }

  @Test
  void scenario1_isTrueForAnyDefinedValueRegardlessOfMagnitude () {
    assertTrue(filterWithSkyValue(0f, 1));
    assertTrue(filterWithSkyValue(999f, 1));
  }

  @Test
  void anyScenario_isFalseWhenTheOnlyValueIsUndefined () {
    // The "num_sky != 0" guard wraps every scenario check, including
    // scenario 1's otherwise-unconditional "return true" - so even
    // scenario 1 comes back false when nothing in range is defined.
    app.CLIMATE_TMYEPW_values = new float[1][1][1][1];
    app.CLIMATE_TMYEPW_values[0][0][0][0] = app.FLOAT_undefined;

    assertFalse(app.filter(app.dataID_CLIMATE_TMYEPW, 0, 0, 1, 0, 0, 0));
    assertFalse(app.filter(app.dataID_CLIMATE_TMYEPW, 0, 0, 4, 0, 0, 0));
  }
}
