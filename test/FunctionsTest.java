import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

class FunctionsTest {

  private static solarchvision_bim app;
  private static solarchvision_bim.Functions funcs;
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
  void vec3_scale_multipliesEveryComponent () {
    assertArrayEquals(new float[]{2, 4, 6}, funcs.vec3_scale(new float[]{1, 2, 3}, 2), EPS);
  }

  @Test
  void vec3_sum_addsComponentwise () {
    assertArrayEquals(new float[]{4, 6, 8}, funcs.vec3_sum(new float[]{1, 2, 3}, new float[]{3, 4, 5}), EPS);
  }

  @Test
  void vec3_diff_subtractsTheFirstArgumentFromTheSecond () {
    // Same convention as vec_diff (see vecDiff_subtractsTheFirstArgumentFromTheSecond below): diff(a, b) == b - a
    assertArrayEquals(new float[]{2, 2, 2}, funcs.vec3_diff(new float[]{1, 1, 1}, new float[]{3, 3, 3}), EPS);
  }

  @Test
  void vec3_dist_isTheMagnitudeOfTheDifference () {
    assertEquals(5f, funcs.vec3_dist(new float[]{0, 0, 0}, new float[]{3, 4, 0}), EPS);
  }

  @Test
  void vec_dot_matchesTheDotProductFormula_anyDimension () {
    assertEquals(0f, funcs.vec_dot(new float[]{1, 0, 0}, new float[]{0, 1, 0}), EPS);
    assertEquals(14f, funcs.vec_dot(new float[]{1, 2, 3, 4}, new float[]{1, 1, 1, 2}), EPS); // 1+2+3+8
  }

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
  void equationOfTime_matchesAKnownValue () {
    // DateAngle=0: 0.01*(9.87*sin(0) - 7.53*cos(0) - 1.5*sin(0)) = 0.01*(-7.53)
    assertEquals(-0.0753f, funcs.EquationOfTime(0), EPS);
  }

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
  void moonPosition_directionVectorIsAlwaysUnitLength () {
    // Same invariant as sunPosition_directionVectorIsAlwaysUnitLength
    // above - MoonPosition shares SunPosition's own rotation formula (see
    // Functions.pde's own comment on MoonPosition), just with phase-
    // shifted inputs, so the same rotation-preserves-length argument holds.
    float[][] cases = {
      {0f, 80f, 2f}, {45f, 180f, -3f}, {-30f, 300f, 6f}, {60f, 10f, 0f}
    };
    for (float[] c : cases) {
      float[] pos = funcs.MoonPosition(c[0], c[1], c[2]);
      float magSq = pos[1] * pos[1] + pos[2] * pos[2] + pos[3] * pos[3];
      assertEquals(1f, magSq, 0.01f, "latitude=" + c[0] + " dateAngle=" + c[1] + " hourAngle=" + c[2]);
    }
  }

  @Test
  void sunPositionRadiation_directionVectorIsAlsoUnitLength () {
    app.STATION.latitude = 43.7f;
    app.STATION.longitude = -79.4f;

    float[] rad = funcs.SunPositionRadiation(90, 12, 0); // near-noon, near-peak declination, no cloud
    float magSq = rad[1] * rad[1] + rad[2] * rad[2] + rad[3] * rad[3];
    assertEquals(1f, magSq, 0.01f);
  }

  @Test
  void sunPositionRadiation_isDaytimeWithPositiveIrradiance () {
    app.STATION.latitude = 43.7f;
    app.STATION.longitude = -79.4f;

    float[] rad = funcs.SunPositionRadiation(90, 12, 0);

    assertTrue(rad[3] > 0.01f, "z (sun above horizon)"); // the z<0.01 threshold below it treats as "down"
    assertTrue(rad[4] > 0f, "Idirect");
    assertTrue(rad[5] > 0f, "Idiffuse");
  }

  @Test
  void sunPositionRadiation_isNightWithZeroIrradiance () {
    app.STATION.latitude = 43.7f;
    app.STATION.longitude = -79.4f;

    float[] rad = funcs.SunPositionRadiation(90, 0, 0); // midnight

    assertTrue(rad[3] < 0.01f, "z (sun below horizon, or within the threshold of it)");
    assertEquals(0f, rad[4], EPS, "Idirect");
    assertEquals(0f, rad[5], EPS, "Idiffuse");
  }

  // --- getSubFace ----------------------------------------------------------
  // The subdivision engine behind the "material 0 on a face gets extra
  // export/solar-sample resolution" feature (see export_objects_OBJ.pde,
  // calculate_VertexSolar_array.pde, and command/README.md's own
  // "Object creation" section) - called once per sub-face index, not all
  // at once, so these tests exercise it the same way its real callers do.

  @Test
  void getSubFace_withTessellationZeroOrBelow_returnsTheBaseVerticesUnchanged () {
    float[][] square = {{0, 0, 0}, {1, 0, 0}, {1, 1, 0}, {0, 1, 0}};

    float[][] result = funcs.getSubFace(square, 0, 0);

    assertEquals(square.length, result.length);
    for (int i = 0; i < square.length; i++) assertArrayEquals(square[i], result[i], EPS);
  }

  @Test
  void getSubFace_withNOutOfRange_alsoReturnsTheBaseVerticesUnchanged () {
    float[][] square = {{0, 0, 0}, {1, 0, 0}, {1, 1, 0}, {0, 1, 0}};

    // totalNumberOfSubs at tessellation=1 for a 4-cornered base is 4 (one
    // quad per corner) - so n=999 is far past the end.
    float[][] result = funcs.getSubFace(square, 1, 999);

    assertEquals(square.length, result.length);
    for (int i = 0; i < square.length; i++) assertArrayEquals(square[i], result[i], EPS);
  }

  @Test
  void getSubFace_atTessellationOne_fansOutOneQuadPerCorner () {
    // n=0: anchored at corner 0, out to the midpoints of its two
    // neighboring edges, in to the overall centroid. Confirmed by hand
    // before writing this: A=corner0, B=midpoint(corner0,corner1),
    // C=centroid, D=midpoint(corner0,corner3).
    float[][] square = {{0, 0, 0}, {1, 0, 0}, {1, 1, 0}, {0, 1, 0}};

    float[][] quad0 = funcs.getSubFace(square, 1, 0);
    assertArrayEquals(new float[]{0, 0, 0}, quad0[0], EPS);
    assertArrayEquals(new float[]{0.5f, 0, 0}, quad0[1], EPS);
    assertArrayEquals(new float[]{0.5f, 0.5f, 0}, quad0[2], EPS);
    assertArrayEquals(new float[]{0, 0.5f, 0}, quad0[3], EPS);

    // n=1: same construction, anchored at corner 1 instead.
    float[][] quad1 = funcs.getSubFace(square, 1, 1);
    assertArrayEquals(new float[]{1, 0, 0}, quad1[0], EPS);
    assertArrayEquals(new float[]{1, 0.5f, 0}, quad1[1], EPS);
    assertArrayEquals(new float[]{0.5f, 0.5f, 0}, quad1[2], EPS);
    assertArrayEquals(new float[]{0.5f, 0, 0}, quad1[3], EPS);
  }

  @Test
  void getSubFace_atHigherTessellation_subdividesEachCornerQuadFurther () {
    // Not re-deriving the tessellation=2 "rotate tri-grid cells" checker-
    // boarding by hand (see getSubFace's own comment in Functions.pde) -
    // confirmed against the real compiled app before writing this -
    // just confirming it actually subdivides smaller than tessellation=1's
    // own quad (every coordinate half the size), and that the vertex count
    // stays 4 regardless of tessellation level.
    float[][] square = {{0, 0, 0}, {1, 0, 0}, {1, 1, 0}, {0, 1, 0}};

    float[][] result = funcs.getSubFace(square, 2, 0);

    assertEquals(4, result.length);
    assertArrayEquals(new float[]{0.25f, 0, 0}, result[0], EPS);
    assertArrayEquals(new float[]{0.25f, 0.25f, 0}, result[1], EPS);
    assertArrayEquals(new float[]{0, 0.25f, 0}, result[2], EPS);
    assertArrayEquals(new float[]{0, 0, 0}, result[3], EPS);
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

  // --- generic vec_* helpers (N-dimensional, vs. the vec3_* fixed-size ones) --

  @Test
  void vecScale_multipliesEveryComponent () {
    assertArrayEquals(new float[]{2, 4, 6, 8}, funcs.vec_scale(new float[]{1, 2, 3, 4}, 2), EPS);
  }

  @Test
  void vecSum_addsComponentwise () {
    assertArrayEquals(new float[]{4, 6}, funcs.vec_sum(new float[]{1, 2}, new float[]{3, 4}), EPS);
  }

  @Test
  void vecDiff_subtractsTheFirstArgumentFromTheSecond () {
    // matches vec3_diff's own convention: diff(a, b) == b - a
    assertArrayEquals(new float[]{2, 2}, funcs.vec_diff(new float[]{1, 1}, new float[]{3, 3}), EPS);
  }

  @Test
  void vecMag_matchesPythagorasInAnyDimension () {
    assertEquals(5f, funcs.vec_mag(new float[]{3, 4}), EPS);
    assertEquals(5f, funcs.vec_mag(new float[]{0, 3, 4, 0}), EPS);
  }

  @Test
  void vecDist_isTheMagnitudeOfTheDifference () {
    assertEquals(5f, funcs.vec_dist(new float[]{0, 0}, new float[]{3, 4}), EPS);
  }

  @Test
  void vecUnit_preservesDirectionAtUnitLength () {
    float[] u = funcs.vec_unit(new float[]{3, 4});
    assertEquals(1f, funcs.vec_mag(u), EPS);
    assertEquals(0.6f, u[0], EPS);
    assertEquals(0.8f, u[1], EPS);
  }

  @Test
  void vecUnit_returnsAllZerosForAZeroVectorInsteadOfDividingByZero () {
    assertArrayEquals(new float[]{0, 0, 0}, funcs.vec_unit(new float[]{0, 0, 0}), EPS);
  }

  @Test
  void vec2Dot_matchesTheDotProductFormula () {
    assertEquals(11f, funcs.vec2_dot(1, 2, 3, 4), EPS); // 1*3 + 2*4
  }

  // --- isInside_Rectangle / uvInside_Rectangle ---------------------------

  @Test
  void isInsideRectangle_acceptsAPointWellInsideTheUnitSquare () {
    float[] O = {0, 0, 0}, A = {1, 0, 0}, B = {0, 1, 0};
    assertTrue(funcs.isInside_Rectangle(new float[]{0.5f, 0.5f, 0}, A, O, B));
  }

  @Test
  void isInsideRectangle_rejectsAPointOutsideTheUnitSquare () {
    float[] O = {0, 0, 0}, A = {1, 0, 0}, B = {0, 1, 0};
    assertFalse(funcs.isInside_Rectangle(new float[]{1.5f, 0.5f, 0}, A, O, B));
  }

  @Test
  void uvInsideRectangle_returnsTheFractionalCoordinatesWithinTheRectangle () {
    float[] O = {0, 0, 0}, A = {2, 0, 0}, B = {0, 4, 0};
    float[] uv = funcs.uvInside_Rectangle(new float[]{1, 1, 0}, A, O, B);
    assertEquals(0.5f, uv[0], EPS); // halfway along the O->A edge (length 2)
    assertEquals(0.25f, uv[1], EPS); // a quarter along the O->B edge (length 4)
  }

  // --- triangle / polygon normals and area -------------------------------

  @Test
  void calculateTriangleNormal_pointsAlongZForACounterclockwiseXYTriangle () {
    float[] n = funcs.calculateTriangleNormal(
      new float[]{0, 0, 0}, new float[]{1, 0, 0}, new float[]{1, 1, 0}
    );
    assertEquals(1f, funcs.vec_mag(n), EPS); // calculateTriangleNormal always returns a unit vector
    assertEquals(1f, Math.abs(n[2]), EPS);   // purely along Z for a flat XY triangle
  }

  @Test
  void calculatePolygonNormal_skipsCollinearCornersAndUsesTheFirstRealTriangle () {
    // The first three points are collinear along X, so the function must
    // step past them and use points [1],[2],[3] instead.
    float[][] square = {
      {0, 0, 0}, {1, 0, 0}, {2, 0, 0}, {2, 2, 0}
    };
    float[] n = funcs.calculatePolygonNormal(square);
    assertEquals(1f, Math.abs(n[2]), EPS);
  }

  @Test
  void calculatePolygonArea_matchesTheKnownAreaOfAUnitSquare () {
    float[][] square = {
      {0, 0, 0}, {1, 0, 0}, {1, 1, 0}, {0, 1, 0}
    };
    assertEquals(1f, funcs.calculatePolygonArea(square), EPS);
  }

  @Test
  void calculatePolygonArea_scalesWithSize () {
    float[][] square = {
      {0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}
    };
    assertEquals(4f, funcs.calculatePolygonArea(square), EPS);
  }

  // --- cleanShape_* / optimizeVertices ------------------------------------

  @Test
  void cleanShapeRemoveDuplicateVertices_dropsAPointThatCoincidesWithThePrevious () {
    float[][] shape = {
      {0, 0, 0}, {0, 0, 0.0001f}, {1, 0, 0}, {1, 1, 0}
    };
    float[][] result = funcs.cleanShape_removeDuplicateVertices(shape);
    assertEquals(3, result.length); // the near-duplicate second point is dropped
  }

  @Test
  void cleanShapeRemoveDuplicateVertices_keepsDistinctPoints () {
    float[][] shape = {
      {0, 0, 0}, {1, 0, 0}, {1, 1, 0}
    };
    float[][] result = funcs.cleanShape_removeDuplicateVertices(shape);
    assertEquals(3, result.length);
  }

  @Test
  void cleanShapeJoinParallelSegments_dropsACornerThatLiesOnAStraightLine () {
    // (1,0,0) sits exactly on the segment from (0,0,0) to (2,0,0), so it
    // isn't a real corner and should be removed.
    float[][] shape = {
      {0, 0, 0}, {1, 0, 0}, {2, 0, 0}, {2, 2, 0}
    };
    float[][] result = funcs.cleanShape_joinParallelSegments(shape);
    assertEquals(3, result.length);
  }

  @Test
  void optimizeVertices_appliesBothCleanupStepsInSequence () {
    float[][] shape = {
      {0, 0, 0}, {0, 0, 0.0001f}, {1, 0, 0}, {2, 0, 0}, {2, 2, 0}
    };
    float[][] result = funcs.optimizeVertices(shape);
    // the near-duplicate is removed, then (1,0,0) collapses into the
    // straight run from (0,0,0) to (2,0,0), leaving a clean triangle-ish shape
    assertEquals(3, result.length);
  }

  // --- Sunrise / Sunset / sunriseHourAngle_Raw ----------------------------

  @Test
  void sunriseHourAngleRaw_isSixHoursAtTheEquinoxRegardlessOfLatitude () {
    // DateAngle 180 gives zero solar declination, so tan(Declination) is 0
    // and q is 0 for any latitude: acos_ang(0) / 15 = 90 / 15 = 6.
    assertEquals(6f, funcs.sunriseHourAngle_Raw(0, 180), EPS);
    assertEquals(6f, funcs.sunriseHourAngle_Raw(45, 180), EPS);
    assertEquals(6f, funcs.sunriseHourAngle_Raw(-30, 180), EPS);
  }

  @Test
  void sunriseHourAngleRaw_isTwentyFourForPolarDay () {
    // High latitude, high declination, same sign: q < -1 -> polar day (sun never sets)
    assertEquals(24f, funcs.sunriseHourAngle_Raw(80, 270), EPS);
  }

  @Test
  void sunriseHourAngleRaw_isZeroForPolarNight () {
    // Same declination, opposite-sign latitude: q > 1 -> polar night (sun never rises)
    assertEquals(0f, funcs.sunriseHourAngle_Raw(-80, 270), EPS);
  }

  @Test
  void sunsetMinusSunrise_matchesDayTimeForTheSameInputs () {
    float latitude = 45.47f;
    float dateAngle = 200f;
    assertEquals(
      funcs.DayTime(latitude, dateAngle),
      funcs.Sunset(latitude, dateAngle) - funcs.Sunrise(latitude, dateAngle),
      EPS
    );
  }
}
