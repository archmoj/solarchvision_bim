import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

class FunctionsTest {

  private static solarchvision_bim app;
  private static solarchvision_bim.solarchvision_Functions funcs;
  private static final float EPS = 0.001f;

  @BeforeAll
  static void setUp () {
    app = new solarchvision_bim();
    funcs = app.funcs;
  }

  // --- degree-based trig ------------------------------------------------

  @Test
  void angTrig_matchesKnownValues () {
    assertEquals(1f, funcs.cos_ang(0), EPS);
    assertEquals(0f, funcs.cos_ang(90), EPS);
    assertEquals(1f, funcs.sin_ang(90), EPS);
    assertEquals(0.5f, funcs.sin_ang(30), EPS);
    assertEquals(1f, funcs.tan_ang(45), EPS);
  }

  @Test
  void inverseAngTrig_matchesKnownValues () {
    assertEquals(30f, funcs.asin_ang(0.5f), EPS);
    assertEquals(60f, funcs.acos_ang(0.5f), EPS);
    assertEquals(45f, funcs.atan_ang(1), EPS);
    assertEquals(45f, funcs.atan2_ang(1, 1), EPS);
    assertEquals(90f, funcs.atan2_ang(1, 0), EPS);
  }

  // --- roundTo ------------------------------------------------------

  @Test
  void roundTo_roundsToTheNearerMultiple () {
    assertEquals(10f, funcs.roundTo(12, 10), EPS);  // 12 is closer to 10 than to 20
    assertEquals(20f, funcs.roundTo(17, 10), EPS);  // 17 is closer to 20 than to 10
  }

  // --- coordinate conversion / distance --------------------------------

  @Test
  void convert_lonlat2XY_isOriginAtTheReferencePoint () {
    float[] xy = funcs.convert_lonlat2XY(0, 0, 0, 0);
    assertEquals(0f, xy[0], EPS);
    assertEquals(0f, xy[1], EPS);
  }

  @Test
  void convert_lonlat2XY_yScalesWithDOUBLE_r_Earth () {
    // y ignores longitude entirely: dv = (dLat/180) * (PI * DOUBLE_r_Earth).
    float[] xy = funcs.convert_lonlat2XY(0, 0, 0, 1);
    float expectedY = (float) ((1.0 / 180.0) * (Math.PI * app.DOUBLE_r_Earth));
    assertEquals(expectedY, xy[1], 1f); // 1m tolerance for the float/double round-trip
  }

  @Test
  void lon_lat_dist_isZeroForTheSamePoint () {
    assertEquals(0f, funcs.lon_lat_dist(0, 0, 0, 0), EPS);
  }

  @Test
  void lon_lat_dist_ofOneDegreeOfLatitudeMatchesTheGreatCircleArc () {
    // With no longitude difference, the haversine formula reduces exactly
    // to the great-circle arc length along a meridian: r * deltaLatRadians.
    float expected = app.FLOAT_r_Earth * (float) Math.toRadians(1.0);
    assertEquals(expected, funcs.lon_lat_dist(0, 0, 0, 1), 50f); // 50m tolerance
  }

  // --- vector operations -----------------------------------------------

  @Test
  void vec3_cross_ofUnitAxesGivesTheThirdAxis () {
    float[] result = funcs.vec3_cross(new float[]{1, 0, 0}, new float[]{0, 1, 0});
    assertArrayEquals(new float[]{0, 0, 1}, result, EPS);
  }

  @Test
  void vec3_dot_ofOrthogonalVectorsIsZero () {
    assertEquals(0f, funcs.vec3_dot(new float[]{1, 0, 0}, new float[]{0, 1, 0}), EPS);
  }

  @Test
  void vec3_mag_matchesPythagoras () {
    assertEquals(5f, funcs.vec3_mag(new float[]{3, 4, 0}), EPS);
  }

  @Test
  void vec3_unit_preservesDirectionAtUnitLength () {
    float[] unit = funcs.vec3_unit(new float[]{5, 0, 0});
    assertArrayEquals(new float[]{1, 0, 0}, unit, EPS);
  }

  @Test
  void centroid_ofATriangleIsTheAverageOfItsVertices () {
    float[] c = funcs.centroid(new float[][]{{0, 0, 0}, {3, 0, 0}, {0, 3, 0}});
    assertEquals(1f, c[0], EPS);
    assertEquals(1f, c[1], EPS);
    assertEquals(0f, c[2], EPS);
  }

  // --- bilinear / geometry predicates -----------------------------------

  @Test
  void bilinear_reducesToEachCornerAtTheCorners () {
    assertEquals(1f, funcs.bilinear(1, 2, 3, 4, 0, 0), EPS); // f_00
    assertEquals(2f, funcs.bilinear(1, 2, 3, 4, 1, 0), EPS); // f_10
    assertEquals(3f, funcs.bilinear(1, 2, 3, 4, 1, 1), EPS); // f_11
    assertEquals(4f, funcs.bilinear(1, 2, 3, 4, 0, 1), EPS); // f_01
  }

  @Test
  void isInside_Triangle_acceptsInteriorAndRejectsExteriorPoints () {
    float[] A = {0, 0, 0};
    float[] B = {1, 0, 0};
    float[] C = {0, 1, 0};
    assertTrue(funcs.isInside_Triangle(new float[]{0.25f, 0.25f, 0}, A, B, C));
    assertFalse(funcs.isInside_Triangle(new float[]{2, 2, 0}, A, B, C));
  }

  @Test
  void is_zero_usesEPSILON_POSITIONAsTheDefaultTolerance () {
    assertTrue(funcs.is_zero(0.00001f));
    assertFalse(funcs.is_zero(0.001f));
    assertTrue(funcs.is_zero(5f, 10f));  // explicit tolerance overload
    assertFalse(funcs.is_zero(15f, 10f));
  }

  @Test
  void arePointsClose_usesEPSILON_POSITION () {
    float[] p1 = {0, 0, 0};
    assertTrue(funcs.arePointsClose(p1, new float[]{0.00001f, 0, 0}));
    assertFalse(funcs.arePointsClose(p1, new float[]{1, 0, 0}));
  }

  @Test
  void are3PointsIn1Line_detectsCollinearityRegardlessOfSpacing () {
    assertTrue(funcs.are3PointsIn1Line(
      new float[]{0, 0, 0}, new float[]{1, 0, 0}, new float[]{5, 0, 0}));
    assertFalse(funcs.are3PointsIn1Line(
      new float[]{0, 0, 0}, new float[]{1, 0, 0}, new float[]{0, 1, 0}));
  }

  @Test
  void isPointOnSegment_acceptsMidpointAndRejectsOffLinePoints () {
    float[] start = {0, 0, 0};
    float[] end = {2, 0, 0};
    assertTrue(funcs.isPointOnSegment(new float[]{1, 0, 0}, start, end));
    assertFalse(funcs.isPointOnSegment(new float[]{1, 1, 0}, start, end));
  }

  @Test
  void getBetween_atRatioOneAndZeroReturnsEachEndpoint () {
    float[] point1 = {0, 0, 0};
    float[] point2 = {10, 0, 0};
    // getBetween's ratio is inverted from what the name suggests: ratio=1
    // returns point1 itself, ratio=0 returns point2 - documenting the
    // actual (slightly surprising) convention rather than the intuitive one.
    assertArrayEquals(point1, funcs.getBetween(point1, point2, 1f), EPS);
    assertArrayEquals(point2, funcs.getBetween(point1, point2, 0f), EPS);
    assertArrayEquals(new float[]{5, 0, 0}, funcs.getBetween(point1, point2, 0.5f), EPS);
  }

  @Test
  void intersect_segmentXsegment_findsAGenuineCrossingPoint () {
    // Regression test for a sign bug in diffB1A1 (see Functions.pde) that
    // made this branch report ordinary crossing segments as
    // non-intersecting for any pair that didn't already return early
    // above (shared endpoint, or one endpoint lying on the other
    // segment). Covers a few different orientations since the bug's
    // effect varied with them.
    assertArrayEquals(new float[]{0, 0, 0}, funcs.intersect_segmentXsegment(
      new float[]{-1, 0, 0}, new float[]{1, 0, 0},
      new float[]{0, -1, 0}, new float[]{0, 1, 0}), EPS);

    assertArrayEquals(new float[]{2, 2, 0}, funcs.intersect_segmentXsegment(
      new float[]{0, 2, 0}, new float[]{4, 2, 0},
      new float[]{2, 0, 0}, new float[]{2, 4, 0}), EPS);

    assertArrayEquals(new float[]{0, 0, 0}, funcs.intersect_segmentXsegment(
      new float[]{-2, -2, 0}, new float[]{2, 2, 0},
      new float[]{-2, 2, 0}, new float[]{2, -2, 0}), EPS);

    assertArrayEquals(new float[]{2, 2, 0}, funcs.intersect_segmentXsegment(
      new float[]{0, 0, 0}, new float[]{4, 4, 0},
      new float[]{0, 4, 0}, new float[]{4, 0, 0}), EPS);
  }

  @Test
  void intersect_segmentXsegment_returnsTheSharedEndpointWhenSegmentsTouch () {
    // A ends exactly where B starts.
    float[] result = funcs.intersect_segmentXsegment(
      new float[]{0, 0, 0}, new float[]{1, 0, 0},
      new float[]{1, 0, 0}, new float[]{1, 1, 0});
    assertArrayEquals(new float[]{1, 0, 0}, result, EPS);
  }

  @Test
  void intersect_segmentXsegment_returnsThePointWhenOneEndpointLiesOnTheOtherSegment () {
    // B1 sits in the interior of segment A (a T-junction).
    float[] result = funcs.intersect_segmentXsegment(
      new float[]{0, 0, 0}, new float[]{4, 0, 0},
      new float[]{2, 0, 0}, new float[]{2, 3, 0});
    assertArrayEquals(new float[]{2, 0, 0}, result, EPS);
  }

  @Test
  void intersect_segmentXsegment_returnsUndefinedForParallelSegments () {
    float[] result = funcs.intersect_segmentXsegment(
      new float[]{0, 0, 0}, new float[]{1, 0, 0},
      new float[]{0, 1, 0}, new float[]{1, 1, 0});
    assertEquals(app.FLOAT_undefined, result[0], EPS);
  }

  // --- solar-position formulas -------------------------------------------

  @Test
  void correctHourAngle_addsEquationOfTimeToTheOrigin () {
    float dateAngle = 45f;
    float hourAngleOrigin = 3f;
    assertEquals(
      funcs.EquationOfTime(dateAngle) + hourAngleOrigin,
      funcs.correctHourAngle(dateAngle, hourAngleOrigin),
      EPS);
  }

  @Test
  void sunPosition_directionVectorIsAlwaysUnitLength () {
    // x/y/z is Declination's unit vector rotated into the station's local
    // frame by Latitude - a rotation preserves length, so x^2+y^2+z^2
    // should be 1 regardless of latitude, date, or hour angle.
    float[][] cases = {
      {0f, 80f, 2f}, {45f, 180f, -3f}, {-30f, 300f, 6f}, {60f, 10f, 0f}
    };
    for (float[] c : cases) {
      float[] pos = funcs.SunPosition(c[0], c[1], c[2]);
      float magSq = pos[1] * pos[1] + pos[2] * pos[2] + pos[3] * pos[3];
      assertEquals(1f, magSq, 0.01f, "latitude=" + c[0] + " dateAngle=" + c[1] + " hourAngle=" + c[2]);
    }
  }

  @Test
  void dayTime_matchesSunsetMinusSunrise () {
    float latitude = 45.47f;
    float dateAngle = 120f;
    float sunrise = funcs.Sunrise(latitude, dateAngle);
    float sunset = funcs.Sunset(latitude, dateAngle);
    float dayTime = funcs.DayTime(latitude, dateAngle);
    assertEquals(Math.abs(sunset - sunrise), dayTime, EPS);
  }

  @Test
  void dayTime_staysWithinA24HourDay () {
    float dayTime = funcs.DayTime(45.47f, 200f);
    assertTrue(dayTime >= 0f && dayTime <= 24f);
  }
}
