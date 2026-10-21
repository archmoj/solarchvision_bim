import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers studyNormalsHover.pde's pure logic: sortedDefinedIndicesByValue
// Descending() (the maximum-first/minimum-last ordering for the hover
// box's own lines) and studyNormalsHover_hitTest() (the vertical-
// crosshair hit-test: nearest column by time, but only if the mouse also
// falls within that column's own line envelope - the check that keeps
// vertically-stacked plotHourly() graphs, like setupPlot_3()'s wind
// speed and temperature shown together, from being confused for each
// other). drawNormalsHoverBox() itself touches real graphics and isn't
// independently testable here, consistent with everything else this
// session that draws to a live PGraphics context.
class StudyNormalsHoverTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= sortedDefinedIndicesByValueDescending ==================

  @Test
  void sort_ordersAllNineValuesDescending () {
    float[] values = { 10, 50, 30, 90, 20, 80, 5, 40, 70 };

    int[] sorted = app.sortedDefinedIndicesByValueDescending(values);

    assertArrayEquals(new int[]{ 3, 5, 8, 1, 7, 2, 4, 0, 6 }, sorted);
  }

  @Test
  void sort_skipsUndefinedEntries_preservingRelativeOrderOfTheRest () {
    float[] values = {
      app.FLOAT_undefined, 50, app.FLOAT_undefined, 90, 20,
      app.FLOAT_undefined, app.FLOAT_undefined, app.FLOAT_undefined, app.FLOAT_undefined
    };

    int[] sorted = app.sortedDefinedIndicesByValueDescending(values);

    assertArrayEquals(new int[]{ 3, 1, 4 }, sorted); // 90, 50, 20
  }

  @Test
  void sort_returnsAnEmptyArray_whenNothingIsDefined () {
    float[] values = new float[9];
    java.util.Arrays.fill(values, app.FLOAT_undefined);

    assertEquals(0, app.sortedDefinedIndicesByValueDescending(values).length);
  }

  @Test
  void sort_handlesTiedValuesWithoutThrowing () {
    float[] values = {
      50, 50, 50, app.FLOAT_undefined, app.FLOAT_undefined,
      app.FLOAT_undefined, app.FLOAT_undefined, app.FLOAT_undefined, app.FLOAT_undefined
    };

    int[] sorted = assertDoesNotThrow(() -> app.sortedDefinedIndicesByValueDescending(values));

    assertEquals(3, sorted.length);
  }

  @Test
  void sort_handlesASingleDefinedValue () {
    float[] values = new float[9];
    java.util.Arrays.fill(values, app.FLOAT_undefined);
    values[4] = 99f;

    int[] sorted = app.sortedDefinedIndicesByValueDescending(values);

    assertArrayEquals(new int[]{ 4 }, sorted);
  }

  // ================= studyNormalsHover_hitTest ===============================

  private solarchvision_bim.NormalsHoverColumn makeColumn (float screenX, float hitRadiusX, float y1, float y2, String dayText, int hour, String layerName) {
    solarchvision_bim.NormalsHoverColumn col = app.new NormalsHoverColumn();
    col.screenX = screenX;
    col.hitRadiusX = hitRadiusX;
    col.screenY1 = y1;
    col.screenY2 = y2;
    col.dayText = dayText;
    col.hourIndex = hour;
    col.layerName = layerName;
    col.layerUnit = " unit";
    col.verticalUnitOffset = 0;
    col.normalsValues = new float[9];
    java.util.Arrays.fill(col.normalsValues, app.FLOAT_undefined);
    col.normalsValues[app.STAT_N_Ave] = 20f;
    return col;
  }

  @Test
  void hitTest_findsAColumnWithinItsOwnXAndYEnvelope () {
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.normalsHoverColumns = new java.util.ArrayList<>();
    app.STUDY.normalsHoverColumns.add(makeColumn(100, 10, 50, 150, "Day1", 14, "Temperature"));

    solarchvision_bim.NormalsHoverColumn hit = app.studyNormalsHover_hitTest(105, 100);

    assertNotNull(hit);
    assertEquals("Temperature", hit.layerName);
  }

  @Test
  void hitTest_isNull_outsideTheTimeWindow () {
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.normalsHoverColumns = new java.util.ArrayList<>();
    app.STUDY.normalsHoverColumns.add(makeColumn(100, 10, 50, 150, "Day1", 14, "Temperature"));

    assertNull(app.studyNormalsHover_hitTest(200, 100));
  }

  @Test
  void hitTest_isNull_outsideTheLineEnvelope_evenWithinTheTimeWindow () {
    // Same X as the column (within its own time window), but Y is far
    // outside its line envelope - simulates hovering over a different
    // graph stacked at the same X but a different screen height, which
    // must not falsely match this column.
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.normalsHoverColumns = new java.util.ArrayList<>();
    app.STUDY.normalsHoverColumns.add(makeColumn(100, 10, 50, 150, "Day1", 14, "Temperature"));

    assertNull(app.studyNormalsHover_hitTest(100, 1000));
  }

  @Test
  void hitTest_picksTheNearestColumnByTime () {
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.normalsHoverColumns = new java.util.ArrayList<>();
    app.STUDY.normalsHoverColumns.add(makeColumn(100, 30, 50, 150, "Day1", 14, "FarColumn"));
    app.STUDY.normalsHoverColumns.add(makeColumn(110, 30, 50, 150, "Day1", 15, "NearColumn"));

    solarchvision_bim.NormalsHoverColumn hit = app.studyNormalsHover_hitTest(108, 100);

    assertNotNull(hit);
    assertEquals("NearColumn", hit.layerName);
  }

  @Test
  void hitTest_isNull_whenNothingHasBeenRecordedYet () {
    app.STUDY.normalsHoverColumns = null;
    assertDoesNotThrow(() -> assertNull(app.studyNormalsHover_hitTest(100, 100)));
  }

  @Test
  void hitTest_doesNotAssumeTheEnvelopesOwnOrdering () {
    // screenY1 (150) > screenY2 (50) - reversed from the "usual" order -
    // must still work correctly, since the hit-test uses min()/max()
    // rather than assuming which of the two is smaller.
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.normalsHoverColumns = new java.util.ArrayList<>();
    app.STUDY.normalsHoverColumns.add(makeColumn(100, 10, 150, 50, "Day1", 14, "ReversedEnvelope"));

    assertNotNull(app.studyNormalsHover_hitTest(100, 100));
  }
}
