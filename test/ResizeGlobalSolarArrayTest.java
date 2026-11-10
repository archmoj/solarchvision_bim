import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// GlobalSolar_resize_array() - previously untested - (re)allocates the
// global sky's own irradiance cache (GlobalSolar) to match Sky3D's
// current resolution and STUDY's current day range, filling every cell
// with FLOAT_undefined. Pure array math, no graphics.
class ResizeGlobalSolarArrayTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void resize_copiesCalculatedResolution_intoBothStepFields () {
    app.Sky3D.calculatedResolution = 2.5f;

    app.GlobalSolar_resize_array();

    assertEquals(2.5f, app.Sky3D.inclinationStep, 0.0001f);
    assertEquals(2.5f, app.Sky3D.orientationStep, 0.0001f);
  }

  @Test
  void resize_computesInclinationAndOrientationCounts_fromTheResolution () {
    // inclinationCount spans the full 180° range PLUS one (both 0° and
    // 180° themselves are included, not just the steps between them) -
    // orientationCount does not, since 360° wraps back onto 0°.
    app.Sky3D.calculatedResolution = 2.5f;

    app.GlobalSolar_resize_array();

    assertEquals(73, app.Sky3D.inclinationCount, "180 / 2.5 + 1");
    assertEquals(144, app.Sky3D.orientationCount, "360 / 2.5, no +1");
  }

  @Test
  void resize_withADifferentResolution_recomputesBothCountsToMatch () {
    app.Sky3D.calculatedResolution = 5f;

    app.GlobalSolar_resize_array();

    assertEquals(37, app.Sky3D.inclinationCount, "180 / 5 + 1");
    assertEquals(72, app.Sky3D.orientationCount, "360 / 5");
  }

  @Test
  void resize_allocatesGlobalSolar_sizedByDayRangeAndTheComputedCounts_andFillsItWithFloatUndefined () {
    app.Sky3D.calculatedResolution = 5f; // keeps the array small for this test
    app.STUDY.startDay = 0;
    app.STUDY.endDay = 2; // jCount == 3

    app.GlobalSolar_resize_array();

    assertEquals(2, app.GlobalSolar.length, "fixed outer dimension - Active and Passive");
    assertEquals(3, app.GlobalSolar[0].length, "1 + endDay - startDay");
    assertEquals(37, app.GlobalSolar[0][0].length);
    assertEquals(72, app.GlobalSolar[0][0][0].length);

    for (int i = 0; i < app.GlobalSolar.length; i++) {
      for (int j = 0; j < app.GlobalSolar[i].length; j++) {
        for (int a = 0; a < app.GlobalSolar[i][j].length; a++) {
          for (int o = 0; o < app.GlobalSolar[i][j][a].length; o++) {
            assertTrue(app.is_undefined(app.GlobalSolar[i][j][a][o]), "[" + i + "][" + j + "][" + a + "][" + o + "] should start undefined");
          }
        }
      }
    }
  }

  @Test
  void resize_clearsTheRebuildFlag () {
    app.GlobalSolar_rebuild_array = true;

    app.GlobalSolar_resize_array();

    assertFalse(app.GlobalSolar_rebuild_array);
  }
}
