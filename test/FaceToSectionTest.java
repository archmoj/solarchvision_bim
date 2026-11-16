import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class FaceToSectionTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // A flat, CCW-wound triangle in the XY plane at Z=5 - same winding
  // convention MouseClickedTest's own horizontal-face tests use, so the
  // flip-correction inside computeSectionParamsFromFace() does not fire.
  @Test
  void triangleFace_becomesATriangleSection_withP4DefaultingToP1 () {
    app.allVertices = new float[][]{{0, 0, 5}, {4, 0, 5}, {0, 3, 5}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.Select3D.faceSelection = new int[]{0};

    app.convertSelectedFacesToSections();

    assertEquals(1, app.allSections.num);

    // Lifted FACE_TO_SECTION_LIFT along the (horizontal, +Z) normal.
    assertEquals(5f + app.FACE_TO_SECTION_LIFT, app.allSections.getZ(0), 0.0001f);

    // The 3 real vertices, projected into the section's own local plane,
    // survive as p1..p4 (not just the face's bounding rectangle) - and
    // p4 defaults back to p1, closing the triangle exactly like the
    // __SECTION__ command's own p4x/p4y-omitted default.
    assertEquals(app.allSections.getP1X(0), app.allSections.getP4X(0), 0.0001f);
    assertEquals(app.allSections.getP1Y(0), app.allSections.getP4Y(0), 0.0001f);

    // The mask polygon (p1,p2,p3) must actually be the 4x3 right
    // triangle the 3 source vertices describe, not its 4x3 bounding
    // rectangle - check via sectionBoundingBox() (the rectangle every
    // bake/render path still uses) plus an explicit inside/outside probe
    // of sectionInsideMask() at a point that's inside the bounding
    // rectangle but outside the actual triangle.
    float[] box = app.allSections.sectionBoundingBox(
      app.allSections.getP1X(0), app.allSections.getP1Y(0),
      app.allSections.getP2X(0), app.allSections.getP2Y(0),
      app.allSections.getP3X(0), app.allSections.getP3Y(0),
      app.allSections.getP4X(0), app.allSections.getP4Y(0)
      );
    assertEquals(4f, box[2], 0.0001f); // sizeX
    assertEquals(3f, box[3], 0.0001f); // sizeY

    // (3.5, 2.5) in local coords sits in the bounding rectangle's far
    // corner (near (hx, hy) = (2, 1.5)) but well outside the triangle's
    // hypotenuse - outside the mask.
    boolean farCornerInside = app.allSections.sectionInsideMask(1.9f, 1.4f,
      app.allSections.getP1X(0), app.allSections.getP1Y(0),
      app.allSections.getP2X(0), app.allSections.getP2Y(0),
      app.allSections.getP3X(0), app.allSections.getP3Y(0),
      app.allSections.getP4X(0), app.allSections.getP4Y(0)
      );
    assertFalse(farCornerInside);
  }

  // A flat, CCW-wound, already-rectangular quad - every one of its own 4
  // vertices becomes a real corner, so this should behave exactly like
  // the bounding-rectangle path (for a rectangle, "real corners" and
  // "bounding rectangle" coincide).
  @Test
  void rectangularQuadFace_becomesARectangularSection () {
    app.allVertices = new float[][]{{0, 0, 5}, {2, 0, 5}, {2, 2, 5}, {0, 2, 5}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.Select3D.faceSelection = new int[]{0};

    app.convertSelectedFacesToSections();

    assertEquals(1, app.allSections.num);
    assertEquals(1f, app.allSections.getX(0), 0.0001f);
    assertEquals(1f, app.allSections.getY(0), 0.0001f);
    assertEquals(2f, app.allSections.getSizeX(0), 0.0001f);
    assertEquals(2f, app.allSections.getSizeY(0), 0.0001f);
  }

  // A 5-sided face has no single quad that could represent it exactly,
  // so this falls back to the same (possibly rotated-frame) bounding
  // rectangle a live left-click (computeSectionParamsFromFace()) would
  // have built - p1..p4 are that rectangle's own 4 corners, in its own
  // local frame, by construction: p1-p2 and p1-p4 are always exactly
  // perpendicular, with lengths SizeX and SizeY. That holds regardless
  // of which way computeSectionParamsFromFace()'s own minimum-bounding-
  // box search happened to rotate the frame for this particular
  // pentagon, so it's checked directly instead of hand-deriving that
  // rotation's exact angle.
  @Test
  void pentagonFace_fallsBackToItsBoundingRectangle () {
    app.allVertices = new float[][]{
      {0, 0, 5}, {4, 0, 5}, {4, 3, 5}, {2, 5, 5}, {0, 3, 5}
      };
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3, 4}};
    app.Select3D.faceSelection = new int[]{0};

    app.convertSelectedFacesToSections();

    assertEquals(1, app.allSections.num);

    float p1x = app.allSections.getP1X(0);
    float p1y = app.allSections.getP1Y(0);
    float p2x = app.allSections.getP2X(0);
    float p2y = app.allSections.getP2Y(0);
    float p4x = app.allSections.getP4X(0);
    float p4y = app.allSections.getP4Y(0);

    float side12x = p2x - p1x;
    float side12y = p2y - p1y;
    float side14x = p4x - p1x;
    float side14y = p4y - p1y;

    // Perpendicular sides...
    assertEquals(0f, side12x * side14x + side12y * side14y, 0.001f);
    // ...whose lengths are exactly SizeX and SizeY.
    assertEquals(app.allSections.getSizeX(0), Math.sqrt(side12x * side12x + side12y * side12y), 0.001f);
    assertEquals(app.allSections.getSizeY(0), Math.sqrt(side14x * side14x + side14y * side14y), 0.001f);
  }

  // Degenerate (<= 2 node) faces are skipped, exactly like a live
  // left-click on one is a no-op (MouseClickedTest's own
  // computeSectionParams_isANoOpForATwoNodeFaceOnLeftClick).
  @Test
  void twoNodeFace_isSkipped () {
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.Select3D.faceSelection = new int[]{0};

    app.convertSelectedFacesToSections();

    assertEquals(0, app.allSections.num);
  }

  // Bug A regression test: a genuinely tilted (sloped) quad face - not
  // purely horizontal, not purely vertical - must now produce a real
  // sloped Section plane via computeSectionParamsFromFace()'s new
  // newellNormal()/fitTiltedSectionPlane() path, instead of the old
  // logic's forced choice between RotX=0 (flat) and RotX=90 (vertical).
  //
  // This quad is a planar parallelogram (AB=(4,0,0) and AD=(0,2,1) are
  // perpendicular, so it is in fact a rectangle in 3D) whose plane rises
  // 1 world-Z unit for every 2 world-Y units - i.e. a simple roof slope
  // of slope 0.5 (an incline of atan(0.5) =~ 26.565 degrees off vertical-
  // -drop, equivalently 90-26.565 =~ 63.435 degrees off horizontal).
  @Test
  void tiltedQuadFace_producesAGenuinelySlopedPlane_notFlatOrVertical () {
    app.allVertices = new float[][]{{0, 0, 0}, {4, 0, 0}, {4, 2, 1}, {0, 2, 1}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.Select3D.faceSelection = new int[]{0};

    app.convertSelectedFacesToSections();

    assertEquals(1, app.allSections.num);

    float rotX = app.allSections.getRotX(0);
    // Neither the old "flat" (0) nor "vertical" (90) special case - this
    // is the whole point of the fix: a genuinely intermediate slope.
    assertTrue((rotX > 1f) && (rotX < 89f),
      "Expected a genuinely tilted RotX strictly between 0 and 90, got " + rotX);
    // The analytic slope angle for a plane rising 1 world-Z per 2
    // world-Y is atan(0.5) =~ 26.565 degrees (up to the sign/complement
    // convention computeSectionParamsFromFace()'s flip-correction picks).
    float expectedTilt = funcsAtanDeg(0.5f);
    float tiltFromVertical = Math.min(Math.abs(rotX - expectedTilt), Math.abs(rotX - (180 - expectedTilt)));
    assertTrue(tiltFromVertical < 0.01f,
      "Expected RotX near " + expectedTilt + " or its 180-complement, got " + rotX);

    // Since AB and AD are perpendicular, the face is itself an exact
    // rectangle in 3D - so its own local-frame bounding sizes are just
    // the two edge lengths: 4 (along AB) and sqrt(2^2+1^2)=sqrt(5)
    // (along AD).
    float sizeX = app.allSections.getSizeX(0);
    float sizeY = app.allSections.getSizeY(0);
    float expectedShort = 4f;
    float expectedLong = (float) Math.sqrt(5);
    boolean matchesEither =
      ((Math.abs(sizeX - expectedShort) < 0.01f) && (Math.abs(sizeY - expectedLong) < 0.01f)) ||
      ((Math.abs(sizeX - expectedLong) < 0.01f) && (Math.abs(sizeY - expectedShort) < 0.01f));
    assertTrue(matchesEither, "Expected section size {4, sqrt(5)} in either order, got {" + sizeX + ", " + sizeY + "}");
  }

  // Small local helper - atan in degrees, mirroring the engine's own
  // funcs.atan_ang() convention, without reaching into engine internals.
  private static float funcsAtanDeg (float x) {
    return (float) Math.toDegrees(Math.atan(x));
  }

  // Bug B regression test: an asymmetric n>4 polygon (pentagon) whose
  // simple vertex-average centroid is provably NOT at its bounding box's
  // geometric center. This face is kept purely vertical (all 5 vertices
  // share world X=0) so the new tilted-plane solver (Bug A's fix) does
  // not engage here - this isolates Bug B's fix (the true per-vertex
  // min/max, not a rectangle assumed centered on the vertex centroid).
  //
  // Vertices (world Y, Z), all at world X=0:
  //   (0,0) -> (4,0) -> (4,3) -> (1,7) -> (0,3) -> close
  // This is a wall rectangle (Y in [0,4], Z in [0,3]) topped by a
  // triangular peak at (Y=1, Z=7) - shifted well off the Y-midpoint
  // (Y=2), so the peak drags the vertex-average noticeably off the true
  // bounding box's center:
  //   vertex-average   (Y,Z) = (9/5, 13/5)   = (1.8, 2.6)
  //   bounding-box-center     = ((0+4)/2, (0+7)/2) = (2, 3.5)
  @Test
  void pentagonFace_withOffCenterPeak_boundingRectangleCoversAllVerticesNotJustTheCentroid () {
    app.allVertices = new float[][]{
      {0, 0, 0}, {0, 4, 0}, {0, 4, 3}, {0, 1, 7}, {0, 0, 3}
      };
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3, 4}};
    app.Select3D.faceSelection = new int[]{0};

    app.convertSelectedFacesToSections();

    assertEquals(1, app.allSections.num);

    float p1x = app.allSections.getP1X(0);
    float p1y = app.allSections.getP1Y(0);
    float p3x = app.allSections.getP3X(0);
    float p3y = app.allSections.getP3Y(0);

    // sp.X/Y/Z (the section's world position, pre-lift) is the simple
    // vertex-average - and a pure rotation about that same point maps
    // the vertex average to exactly local (0,0). The OLD, buggy code
    // built its rectangle symmetrically around that same local origin
    // (p1 = -half-size, p3 = +half-size), so its center was always
    // exactly (0,0). The true bounding box of this asymmetric pentagon
    // is NOT centered on the vertex average, so the FIXED rectangle's
    // center must be measurably away from (0,0).
    float centerX = (p1x + p3x) / 2f;
    float centerY = (p1y + p3y) / 2f;
    float centerDist = (float) Math.sqrt(centerX * centerX + centerY * centerY);
    assertTrue(centerDist > 0.1f,
      "Expected the bounding rectangle's center to be measurably off the vertex centroid (old-bug symmetric assumption), but it was within 0.1 of it: (" + centerX + ", " + centerY + ")");

    // And, by construction of a real bounding box: every one of the 5
    // source vertices, projected into the section's own local frame,
    // must fall within [p1..p3]'s rectangle (with a little slack for
    // floating point).
    float minX = Math.min(p1x, p3x) - 0.001f;
    float maxX = Math.max(p1x, p3x) + 0.001f;
    float minY = Math.min(p1y, p3y) - 0.001f;
    float maxY = Math.max(p1y, p3y) + 0.001f;

    float sizeX = app.allSections.getSizeX(0);
    float sizeY = app.allSections.getSizeY(0);
    assertTrue(sizeX > 0.001f);
    assertTrue(sizeY > 0.001f);
    assertTrue((maxX - minX) <= (sizeX + 0.01f));
    assertTrue((maxY - minY) <= (sizeY + 0.01f));
  }

  // Converting several selected faces at once creates one section per
  // valid face and leaves exactly those newly-created sections selected
  // (faces deselected) - the same bookkeeping pattern Clone3D's own
  // batch functions (clone3D.pde) use.
  @Test
  void multipleSelectedFaces_eachBecomeTheirOwnSection_andAreSelectedAfterward () {
    app.allVertices = new float[][]{
      {0, 0, 5}, {2, 0, 5}, {2, 2, 5}, {0, 2, 5}, // face 0: quad
      {0, 0, 9}, {2, 0, 9}, {0, 2, 9}             // face 1: triangle
      };
    app.allFaces.nodes = new int[][]{
      {0, 1, 2, 3},
      {4, 5, 6}
      };
    app.Select3D.faceSelection = new int[]{0, 1};

    app.convertSelectedFacesToSections();

    assertEquals(2, app.allSections.num);
    assertArrayEquals(new int[]{0, 1}, app.Select3D.sectionSelection);
    assertEquals(0, app.Select3D.faceSelection.length);
  }
}
