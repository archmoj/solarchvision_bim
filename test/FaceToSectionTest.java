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
  void triangleFace_becomesAnExactTriangleSection () {
    app.allVertices = new float[][]{{0, 0, 5}, {4, 0, 5}, {0, 3, 5}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.Select3D.faceSelection = new int[]{0};

    app.convertSelectedFacesToSections();

    assertEquals(1, app.allSections.num);

    // Lifted FACE_TO_SECTION_LIFT along the (horizontal, +Z) normal.
    assertEquals(5f + app.FACE_TO_SECTION_LIFT, app.allSections.getZ(0), 0.0001f);

    // Sections now store an exact n-gon (sections.pde's own corners
    // field) - a triangular face becomes exactly 3 stored corners, not
    // a padded-to-4 quad.
    assertEquals(3, app.allSections.getNumCorners(0));

    // The mask polygon (the 3 real corners) must actually be the 4x3
    // right triangle the 3 source vertices describe, not its 4x3
    // bounding rectangle - check via sectionBoundingBox() (the
    // rectangle every bake/render path still uses) plus an explicit
    // inside/outside probe of sectionInsideMask() at a point that's
    // inside the bounding rectangle but outside the actual triangle.
    float[] cornersXY = app.allSections.getCornersXY(0);
    float[] box = app.allSections.sectionBoundingBox(cornersXY);
    assertEquals(4f, box[2], 0.0001f); // sizeX
    assertEquals(3f, box[3], 0.0001f); // sizeY

    // (1.9, 1.4) in local coords sits in the bounding rectangle's far
    // corner (near (hx, hy) = (2, 1.5)) but well outside the triangle's
    // hypotenuse - outside the mask.
    boolean farCornerInside = app.allSections.sectionInsideMask(1.9f, 1.4f, cornersXY);
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
    assertEquals(4, app.allSections.getNumCorners(0));
    assertEquals(1f, app.allSections.getX(0), 0.0001f);
    assertEquals(1f, app.allSections.getY(0), 0.0001f);
    assertEquals(2f, app.allSections.getSizeX(0), 0.0001f);
    assertEquals(2f, app.allSections.getSizeY(0), 0.0001f);
  }

  // A 5-sided face now becomes an EXACT pentagon section - Sections no
  // longer cap out at 4 corners (sections.pde's own corners field is a
  // genuine variable-length n-gon), so there's no bounding-rectangle
  // approximation needed anymore for a face with more than 4 sides.
  // This checks the stored corners are exactly the face's own 5
  // vertices (projected into the section's own local plane, in the
  // same order), not a 4-corner approximation of them.
  @Test
  void pentagonFace_becomesAnExactPentagonSection () {
    app.allVertices = new float[][]{
      {0, 0, 5}, {4, 0, 5}, {4, 3, 5}, {2, 5, 5}, {0, 3, 5}
      };
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3, 4}};
    app.Select3D.faceSelection = new int[]{0};

    app.convertSelectedFacesToSections();

    assertEquals(1, app.allSections.num);
    assertEquals(5, app.allSections.getNumCorners(0));

    // Every one of the pentagon's own 5 source vertices, projected into
    // the section's own local plane, must be a genuine polygon vertex -
    // i.e. strictly outside the mask only just past it. Cheap,
    // rotation-agnostic check: the mask must contain its own centroid
    // (a non-degenerate polygon always does for this convex pentagon),
    // and must NOT contain a point far outside the bounding box.
    float[] cornersXY = app.allSections.getCornersXY(0);
    float[] box = app.allSections.sectionBoundingBox(cornersXY);
    float centerX = box[0];
    float centerY = box[1];
    assertTrue(app.allSections.sectionInsideMask(centerX, centerY, cornersXY));

    float farX = centerX + box[2];
    float farY = centerY + box[3];
    assertFalse(app.allSections.sectionInsideMask(farX, farY, cornersXY));
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

  // Bug B regression test (original form): an asymmetric n>4 polygon
  // (pentagon) whose simple vertex-average centroid is provably NOT at
  // its bounding box's geometric center. This used to matter because
  // the OLD code approximated anything above 4 sides with a bounding
  // rectangle assumed centered on the vertex centroid - wrong for an
  // asymmetric shape like this gable wall. Sections now store an EXACT
  // n-gon, so there's no bounding-rectangle approximation left to get
  // wrong; this test instead locks in that the exact stored pentagon
  // still covers the asymmetric peak correctly (the far peak vertex is
  // on the mask boundary, and a point just beyond it - still inside the
  // old bounding rectangle - is correctly outside the real mask).
  //
  // Vertices (world Y, Z), all at world X=0:
  //   (0,0) -> (4,0) -> (4,3) -> (1,7) -> (0,3) -> close
  // This is a wall rectangle (Y in [0,4], Z in [0,3]) topped by a
  // triangular peak at (Y=1, Z=7) - shifted well off the Y-midpoint
  // (Y=2).
  @Test
  void pentagonFace_withOffCenterPeak_getsAnExactMaskNotABoundingRectangle () {
    app.allVertices = new float[][]{
      {0, 0, 0}, {0, 4, 0}, {0, 4, 3}, {0, 1, 7}, {0, 0, 3}
      };
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3, 4}};
    app.Select3D.faceSelection = new int[]{0};

    app.convertSelectedFacesToSections();

    assertEquals(1, app.allSections.num);
    assertEquals(5, app.allSections.getNumCorners(0));

    float[] cornersXY = app.allSections.getCornersXY(0);
    float[] box = app.allSections.sectionBoundingBox(cornersXY);

    // The bounding box itself is still asymmetric around the vertex
    // centroid (which sits at local (0,0) - see this function's own
    // earlier comment history) - i.e. the box's own center is
    // measurably away from (0,0), confirming the peak really is
    // off-center.
    float centerDist = (float) Math.sqrt(box[0] * box[0] + box[1] * box[1]);
    assertTrue(centerDist > 0.1f,
      "Expected the bounding rectangle's center to be measurably off the vertex centroid, but it was within 0.1 of it: (" + box[0] + ", " + box[1] + ")");

    // In world terms the bounding box spans Y in [0,4] and Z in [0,7],
    // but the pentagon only reaches Z=7 at a single point (Y=1) - so
    // the box's own 2 "high" corners (Y=0,Z=7) and (Y=4,Z=7) are both
    // genuinely outside the pentagon, while its 2 "low" corners
    // (Y=0,Z=0) and (Y=4,Z=0) sit exactly on the pentagon's own
    // boundary. A rotation/reflection into the section's own local
    // frame renames which corner is which (local axes don't
    // necessarily line up with world Y/Z the same way every time this
    // runs) but never changes which POINTS are inside or outside the
    // polygon - so at least one of the local box's own 4 corners must
    // still be outside the real mask, even though all 4 are (trivially)
    // inside the bounding rectangle every bake path still rasterizes
    // against.
    float[] cx = { box[0] - 0.49f * box[2], box[0] + 0.49f * box[2] };
    float[] cy = { box[1] - 0.49f * box[3], box[1] + 0.49f * box[3] };
    boolean anyCornerOutside = false;
    for (float x : cx) {
      for (float y : cy) {
        if (!app.allSections.sectionInsideMask(x, y, cornersXY)) anyCornerOutside = true;
      }
    }
    assertTrue(anyCornerOutside, "Expected at least one bounding-box corner to fall outside the exact pentagon mask");
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
