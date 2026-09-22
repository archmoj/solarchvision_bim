import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class Overlay3DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= computeFaceTessellation (extracted) ==================

  @Test
  void computeFaceTessellation_bumpsTessellationByDisplayTessellationWhenNoMaterialIsAssigned () {
    app.allFaces.displayTessellation = 2;
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{0, 1, 0, 0, 0, 0}}; // material=0, stored tessellation=1
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {0, 1, 0}};

    solarchvision_bim.Overlay3D.FaceTessellation ft = app.Overlay3D.computeFaceTessellation(0);

    assertEquals(3, ft.tessellation); // 1 + displayTessellation(2)
    // totalNumberOfSubs = nodes.length(3) * roundTo(4^(3-1), 1) = 3*16
    assertEquals(48, ft.totalNumberOfSubs);
  }

  @Test
  void computeFaceTessellation_doesNotBumpTessellationWhenAMaterialIsAssigned () {
    app.allFaces.displayTessellation = 2;
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{5, 2, 0, 0, 0, 0}}; // material=5 (nonzero), stored tessellation=2
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {0, 1, 0}};

    solarchvision_bim.Overlay3D.FaceTessellation ft = app.Overlay3D.computeFaceTessellation(0);

    assertEquals(2, ft.tessellation); // untouched: not bumped
    // totalNumberOfSubs = 3 * roundTo(4^(2-1), 1) = 3*4
    assertEquals(12, ft.totalNumberOfSubs);
  }

  @Test
  void computeFaceTessellation_leavesTotalNumberOfSubsAtOneForANonPositiveTessellation () {
    app.allFaces.displayTessellation = 0;
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{5, 0, 0, 0, 0, 0}}; // material nonzero, stored tessellation=0
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {0, 1, 0}};

    solarchvision_bim.Overlay3D.FaceTessellation ft = app.Overlay3D.computeFaceTessellation(0);

    assertEquals(0, ft.tessellation);
    assertEquals(1, ft.totalNumberOfSubs); // the ">0" guard is never satisfied
  }

  @Test
  void computeFaceTessellation_baseVerticesMatchTheFacesOwnNodesInOrder () {
    app.allFaces.displayTessellation = 0;
    app.allFaces.nodes = new int[][]{{2, 0, 1}}; // deliberately out of numeric order
    app.allFaces.options = new int[][]{{5, 0, 0, 0, 0, 0}};
    app.allVertices = new float[][]{{10, 11, 12}, {20, 21, 22}, {30, 31, 32}};

    solarchvision_bim.Overlay3D.FaceTessellation ft = app.Overlay3D.computeFaceTessellation(0);

    assertArrayEquals(new float[]{30, 31, 32}, ft.base_Vertices[0], 0.0001f); // node 2
    assertArrayEquals(new float[]{10, 11, 12}, ft.base_Vertices[1], 0.0001f); // node 0
    assertArrayEquals(new float[]{20, 21, 22}, ft.base_Vertices[2], 0.0001f); // node 1
  }

  // ================= clipPolygon_nearPlane (pure; not extracted) =========

  @Test
  void clipPolygonNearPlane_returnsEmptyForEmptyInput () {
    float[][] result = app.Overlay3D.clipPolygon_nearPlane(new float[0][]);
    assertEquals(0, result.length);
  }

  @Test
  void clipPolygonNearPlane_passesThroughUnchangedWhenEveryPointIsInFront () {
    float[][] poly = {{0, 0, 1}, {1, 0, 1}, {1, 1, 1}};
    float[][] result = app.Overlay3D.clipPolygon_nearPlane(poly);

    assertEquals(3, result.length);
    assertArrayEquals(poly[0], result[0], 0.0001f);
    assertArrayEquals(poly[1], result[1], 0.0001f);
    assertArrayEquals(poly[2], result[2], 0.0001f);
  }

  @Test
  void clipPolygonNearPlane_returnsEmptyWhenEveryPointIsBehind () {
    float[][] poly = {{0, 0, -1}, {1, 0, -1}, {1, 1, -1}};
    float[][] result = app.Overlay3D.clipPolygon_nearPlane(poly);
    assertEquals(0, result.length);
  }

  @Test
  void clipPolygonNearPlane_insertsIntersectionPointsAtTheNearPlaneCrossings () {
    // Verified independently by hand: a triangle with two vertices in
    // front (z=1) and one behind (z=-1) clips to a 4-vertex quad, each
    // new vertex sitting exactly at z=NEAR_Z on the edge it replaces.
    float[][] poly = {{0, 0, 1}, {10, 0, 1}, {10, 0, -1}};
    float[][] result = app.Overlay3D.clipPolygon_nearPlane(poly);

    assertEquals(4, result.length);
    assertArrayEquals(new float[]{4.9995f, 0, 0.0001f}, result[0], 0.001f);
    assertArrayEquals(new float[]{0, 0, 1}, result[1], 0.001f);
    assertArrayEquals(new float[]{10, 0, 1}, result[2], 0.001f);
    assertArrayEquals(new float[]{10, 0, 0.0001f}, result[3], 0.001f);
  }

  // ================= clipPolygon_halfPlane (pure; not extracted) =========

  @Test
  void clipPolygonHalfPlane_cutsASquareDownToTheHalfSatisfyingTheConstraint () {
    // Unit square (-1,-1)-(1,1), clipped against x >= 0.
    float[][] square = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}};
    float[][] result = app.Overlay3D.clipPolygon_halfPlane(square, 1, 0, 0);

    assertEquals(4, result.length);
    assertArrayEquals(new float[]{0, -1}, result[0], 0.0001f);
    assertArrayEquals(new float[]{1, -1}, result[1], 0.0001f);
    assertArrayEquals(new float[]{1, 1}, result[2], 0.0001f);
    assertArrayEquals(new float[]{0, 1}, result[3], 0.0001f);
  }

  @Test
  void clipPolygonHalfPlane_returnsEmptyWhenTheWholePolygonFailsTheConstraint () {
    float[][] square = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}};
    // x >= 100 - the whole square fails this
    float[][] result = app.Overlay3D.clipPolygon_halfPlane(square, 1, 0, 100);
    assertEquals(0, result.length);
  }

  // ================= clipPolygon_toWindow (pure; not extracted) ==========

  @Test
  void clipPolygonToWindow_matchesASingleHalfPlaneClipWhenOnlyOneSideActuallyConstrains () {
    float[][] square = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}};
    // Only xmin=0 actually cuts into the square; the other three sides
    // are loose enough to be no-ops.
    float[][] result = app.Overlay3D.clipPolygon_toWindow(square, 0, -100, 100, 100);

    assertEquals(4, result.length);
    assertArrayEquals(new float[]{0, -1}, result[0], 0.0001f);
    assertArrayEquals(new float[]{1, -1}, result[1], 0.0001f);
    assertArrayEquals(new float[]{1, 1}, result[2], 0.0001f);
    assertArrayEquals(new float[]{0, 1}, result[3], 0.0001f);
  }

  @Test
  void clipPolygonToWindow_returnsEmptyWhenTheWindowDoesNotOverlapTheShapeAtAll () {
    float[][] square = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}};
    float[][] result = app.Overlay3D.clipPolygon_toWindow(square, 5, 5, 6, 6);
    assertEquals(0, result.length);
  }

  // ================= clipPolygon_intersect (pure; not extracted) =========

  @Test
  void clipPolygonIntersect_findsWhereAnEdgeCrossesTheGivenLine () {
    // Same edge and half-plane as the halfPlane test above - both should
    // agree on where it crosses x=0.
    float[] result = app.Overlay3D.clipPolygon_intersect(new float[]{-1, -1}, new float[]{1, -1}, 1, 0, 0);
    assertArrayEquals(new float[]{0, -1}, result, 0.0001f);
  }

  // ================= computePivotAxisVertices (extracted) =================

  @Test
  void computePivotAxisVertices_placesTheOriginAtTheGivenCenterRegardlessOfR () {
    // vertices[0] is always (0,0,0)*r, so both the pivot-relative offset
    // O and A end up identical - the origin vertex is exactly (x0,y0,z0)
    // no matter what r is.
    float[][] v = app.Overlay3D.computePivotAxisVertices(100, 200, 300, 10);
    assertArrayEquals(new float[]{100, 200, 300}, v[0], 0.0001f);

    float[][] v2 = app.Overlay3D.computePivotAxisVertices(100, 200, 300, 999);
    assertArrayEquals(new float[]{100, 200, 300}, v2[0], 0.0001f);
  }

  @Test
  void computePivotAxisVertices_scalesEachAxisEndpointByRUnderIdentityAlignment () {
    // Default Select3D state (alignX/Y/Z=0) with the default identity
    // BoundingBox (zero rotation, unit scale) makes
    // translateInside_ReferencePivot a pass-through, so each endpoint is
    // simply the center plus r along its own axis.
    float[][] v = app.Overlay3D.computePivotAxisVertices(100, 200, 300, 10);

    assertArrayEquals(new float[]{110, 200, 300}, v[1], 0.0001f); // +X
    assertArrayEquals(new float[]{100, 210, 300}, v[2], 0.0001f); // +Y
    assertArrayEquals(new float[]{100, 200, 310}, v[3], 0.0001f); // +Z
  }

  // ================= computeGroupBoxVertices (extracted) ==================

  @Test
  void computeGroupBoxVertices_isAnIdentityRoundTripForAnAxisAlignedUnitScaleBox () {
    // translateInside_ReferencePivot rotates/scales relative to the
    // box's own centre, then re-adds that centre position - so with
    // zero rotation and unit scale (this BoundingBox's rotX/Y/Z and
    // scale columns), it round-trips each corner back to itself
    // exactly, unchanged from Select3D.BoundingBox's own min/max rows.
    app.Select3D.BoundingBox = new float[][]{
      {0, 0, 0, 1, 1, 1, 0, 0, 0},    // min
      {5, 5, 5, 1, 1, 1, 0, 0, 0},    // mid
      {10, 10, 10, 1, 1, 1, 0, 0, 0}  // max
    };

    solarchvision_bim.Overlay3D.GroupBoxVertices gbv = app.Overlay3D.computeGroupBoxVertices();

    assertFalse(gbv.isEmpty);
    assertArrayEquals(new float[]{0, 0, 0}, gbv.vertices[0], 0.0001f);
    assertArrayEquals(new float[]{10, 0, 0}, gbv.vertices[1], 0.0001f);
    assertArrayEquals(new float[]{10, 10, 0}, gbv.vertices[2], 0.0001f);
    assertArrayEquals(new float[]{0, 10, 0}, gbv.vertices[3], 0.0001f);
    assertArrayEquals(new float[]{0, 0, 10}, gbv.vertices[4], 0.0001f);
    assertArrayEquals(new float[]{10, 0, 10}, gbv.vertices[5], 0.0001f);
    assertArrayEquals(new float[]{10, 10, 10}, gbv.vertices[6], 0.0001f);
    assertArrayEquals(new float[]{0, 10, 10}, gbv.vertices[7], 0.0001f);
  }

  @Test
  void computeGroupBoxVertices_rotatesCornersAroundZWhenTheBoxHasItsOwnRotation () {
    // Verified independently by hand: with rotZ=90 on the mid row (the
    // row used once alignX/Y/Z are forced to 0), each corner's local
    // offset from the centre (5,5,5) - e.g. (-5,-5,-5) for the min
    // corner - gets rotated 90 degrees around Z ((x,y) -> (-y,x)) before
    // the centre is re-added.
    app.Select3D.BoundingBox = new float[][]{
      {0, 0, 0, 1, 1, 1, 0, 0, 0},     // min
      {5, 5, 5, 1, 1, 1, 0, 0, 90},    // mid - rotZ=90
      {10, 10, 10, 1, 1, 1, 0, 0, 0}   // max
    };

    solarchvision_bim.Overlay3D.GroupBoxVertices gbv = app.Overlay3D.computeGroupBoxVertices();

    // min corner: local (-5,-5,-5) -> rotated (5,-5,-5) -> +centre = (10,0,0)
    assertArrayEquals(new float[]{10, 0, 0}, gbv.vertices[0], 0.001f);
    // max corner: local (5,5,5) -> rotated (-5,5,5) -> +centre = (0,10,10)
    assertArrayEquals(new float[]{0, 10, 10}, gbv.vertices[6], 0.001f);
  }

  @Test
  void computeGroupBoxVertices_isEmptyWhenEveryCornerCoincides () {
    app.Select3D.BoundingBox = new float[][]{
      {0, 0, 0, 1, 1, 1, 0, 0, 0},
      {0, 0, 0, 1, 1, 1, 0, 0, 0},
      {0, 0, 0, 1, 1, 1, 0, 0, 0}
    };

    solarchvision_bim.Overlay3D.GroupBoxVertices gbv = app.Overlay3D.computeGroupBoxVertices();

    assertTrue(gbv.isEmpty);
  }

  @Test
  void computeGroupBoxVertices_restoresSelect3DsAlignFieldsAfterwards () {
    app.Select3D.BoundingBox = new float[][]{
      {0, 0, 0, 1, 1, 1, 0, 0, 0},
      {5, 5, 5, 1, 1, 1, 0, 0, 0},
      {10, 10, 10, 1, 1, 1, 0, 0, 0}
    };
    app.Select3D.alignX = 1;
    app.Select3D.alignY = -1;
    app.Select3D.alignZ = 1;

    app.Overlay3D.computeGroupBoxVertices();

    assertEquals(1, app.Select3D.alignX);
    assertEquals(-1, app.Select3D.alignY);
    assertEquals(1, app.Select3D.alignZ);
  }

  // ================= clipAndProject (pure; not extracted) ================

  private solarchvision_bim.Overlay3D.DrawStyle hugeWindowStyle () {
    solarchvision_bim.Overlay3D.DrawStyle style = app.Overlay3D.new DrawStyle(2, 0);
    style.innerWinX1 = -1000;
    style.innerWinY1 = -1000;
    style.innerWinX2 = 1000;
    style.innerWinY2 = 1000;
    return style;
  }

  @Test
  void clipAndProject_projectsCameraSpacePointsMatchingCalculatePerspectiveFromCameraSpace () {
    app.WIN3D.ViewType = 1; // perspective
    app.WIN3D.scale = 1;
    app.WIN3D.CAM_fov = (float) Math.toRadians(60);
    app.WIN3D.refScale = 1;

    java.util.ArrayList<float[]> camVertices = new java.util.ArrayList<float[]>();
    camVertices.add(new float[]{0, 0, 10});
    camVertices.add(new float[]{5, 0, 10});
    camVertices.add(new float[]{0, 5, 10});

    float[][] result = app.Overlay3D.clipAndProject(camVertices, hugeWindowStyle());

    float factor = (float) (0.5 / Math.tan(0.5 * Math.toRadians(60)));
    assertEquals(3, result.length);
    assertArrayEquals(new float[]{0, 0}, result[0], 0.001f);
    assertArrayEquals(new float[]{0.5f * factor, 0}, result[1], 0.001f);
    assertArrayEquals(new float[]{0, -0.5f * factor}, result[2], 0.001f);
  }

  @Test
  void clipAndProject_returnsEmptyWhenEveryPointIsBehindTheCamera () {
    app.WIN3D.ViewType = 1;
    app.WIN3D.scale = 1;
    app.WIN3D.CAM_fov = (float) Math.toRadians(60);
    app.WIN3D.refScale = 1;

    java.util.ArrayList<float[]> camVertices = new java.util.ArrayList<float[]>();
    camVertices.add(new float[]{0, 0, -10});
    camVertices.add(new float[]{5, 0, -10});
    camVertices.add(new float[]{0, 5, -10});

    float[][] result = app.Overlay3D.clipAndProject(camVertices, hugeWindowStyle());

    assertEquals(0, result.length);
  }

  @Test
  void clipAndProject_returnsEmptyWhenTheProjectedShapeFallsEntirelyOutsideTheStylesWindow () {
    app.WIN3D.ViewType = 1;
    app.WIN3D.scale = 1;
    app.WIN3D.CAM_fov = (float) Math.toRadians(60);
    app.WIN3D.refScale = 1;

    java.util.ArrayList<float[]> camVertices = new java.util.ArrayList<float[]>();
    camVertices.add(new float[]{0, 0, 10});
    camVertices.add(new float[]{5, 0, 10});
    camVertices.add(new float[]{0, 5, 10});

    solarchvision_bim.Overlay3D.DrawStyle tinyFarAwayWindow = app.Overlay3D.new DrawStyle(2, 0);
    tinyFarAwayWindow.innerWinX1 = 100;
    tinyFarAwayWindow.innerWinY1 = 100;
    tinyFarAwayWindow.innerWinX2 = 200;
    tinyFarAwayWindow.innerWinY2 = 200;

    float[][] result = app.Overlay3D.clipAndProject(camVertices, tinyFarAwayWindow);

    assertEquals(0, result.length);
  }
}
