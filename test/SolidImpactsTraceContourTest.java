import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// SolidImpacts.traceContour2D()/trace_U1Line()/trace_V1Line()
// (solidImpacts.pde) were untested - 444/375/311 instructions, the
// largest remaining gap surveyed this round. All three are pure
// numerical contour-marching algorithms (sampling a scalar field around
// a point, picking the sampled angle whose value is closest to a
// target) - no graphics anywhere in any of them, confirmed by reading
// each one fully, not assumed from the name.
//
// On a bare, empty scene (allSolids.DEF.length == 0, its own bare-
// construction default), get_Impact_atXYZ()'s own "simple" calculation
// path (allSolidImpacts.complex defaults to 0, selecting it) loops over
// allSolids.DEF - zero iterations - leaving its own "val = 1;" seed
// untouched, so it returns exactly 1 for every (x, y, z) queried,
// regardless of where. That makes every one of this file's traces fully
// deterministic: the marching loop samples the same constant value at
// every angle, so the "closest to target" search always settles on its
// own very first sample (test_t == -150, the loop's own starting
// value) - not re-derived by hand here beyond confirming the result is
// real, finite, non-undefined output, not re-verifying the full
// trigonometry of exactly where that point lands.
class SolidImpactsTraceContourTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void traceContour2D_onAnEmptyScene_returnsAWellFormedSixElementResult () {
    float[] result = app.allSolidImpacts.traceContour2D(0, 0.1f, 0, 0, 0, 1, 0, 0, 1.0f);

    assertNotNull(result);
    assertEquals(6, result.length);
    for (float v : result) {
      assertTrue(app.is_defined(v), "every component must be a real, finite value - not FLOAT_undefined");
    }
  }

  @Test
  void traceU1Line_onAnEmptyScene_doesNotThrow_andGrowsContoursU1Vertices () {
    int before = app.allSolidImpacts.Contours_U1Vertices.length;

    assertDoesNotThrow(() ->
        app.allSolidImpacts.trace_U1Line(new float[]{0, 0, 0, 0, 1, 0}, 0.02f, 1));

    assertTrue(app.allSolidImpacts.Contours_U1Vertices.length > before, "at least one new contour vertex must have been recorded");
  }

  @Test
  void traceV1Line_onAnEmptyScene_doesNotThrow_andGrowsContoursV1Vertices () {
    int before = app.allSolidImpacts.Contours_V1Vertices.length;

    assertDoesNotThrow(() ->
        app.allSolidImpacts.trace_V1Line(new float[]{0, 0, 0, 0, 1, 0}, 0.02f, 1));

    assertTrue(app.allSolidImpacts.Contours_V1Vertices.length > before, "at least one new contour vertex must have been recorded");
  }
}
