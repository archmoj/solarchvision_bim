import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers the arbitrary (sectionType 0) section feature: previously type 0
// meant "off"/not drawn; it's now a fully general orientation, described
// by 3 Euler angles (rotX - stored in the section's existing R slot,
// reused rather than duplicated - rotY, rotZ) composed in the same X-then-
// Y-then-Z order Solids' own getCorners() (solids.pde) already uses for
// Solid_rotX/Y/Z, so an arbitrary section's 3 angles mean exactly what a
// solid's already do elsewhere in this app.
class ArbitrarySectionTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= arbitrarySection_rotateLocalToWorld =================

  @Test
  void rotateLocalToWorld_isTheIdentityAtZeroRotation () {
    float[] r = app.arbitrarySection_rotateLocalToWorld(3, 4, 5, 0, 0, 0);
    assertArrayEquals(new float[]{3, 4, 5}, r, 0.0001f);
  }

  @Test
  void rotateLocalToWorld_rotX90_rotatesYIntoZ () {
    // Standard active rotation about X: Y -> Z at +90 degrees.
    float[] r = app.arbitrarySection_rotateLocalToWorld(0, 1, 0, 90, 0, 0);
    assertArrayEquals(new float[]{0, 0, 1}, r, 0.0001f);
  }

  @Test
  void rotateLocalToWorld_rotY90_rotatesZIntoX () {
    float[] r = app.arbitrarySection_rotateLocalToWorld(0, 0, 1, 0, 90, 0);
    assertArrayEquals(new float[]{1, 0, 0}, r, 0.0001f);
  }

  @Test
  void rotateLocalToWorld_rotZ90_rotatesXIntoY () {
    float[] r = app.arbitrarySection_rotateLocalToWorld(1, 0, 0, 0, 0, 90);
    assertArrayEquals(new float[]{0, 1, 0}, r, 0.0001f);
  }

  @Test
  void rotateLocalToWorld_preservesVectorLength_forAnArbitraryRotation () {
    float[] r = app.arbitrarySection_rotateLocalToWorld(1, 2, 3, 37, -58, 142);
    float before = mag(1, 2, 3);
    float after = mag(r[0], r[1], r[2]);
    assertEquals(before, after, 0.0001f, "a pure rotation must preserve vector length");
  }

  private float mag (float x, float y, float z) {
    return (float) Math.sqrt(x * x + y * y + z * z);
  }

  // ================= arbitrarySection_rotateWorldToLocal =================
  // The exact inverse of rotateLocalToWorld() above.

  @Test
  void rotateWorldToLocal_isTheIdentityAtZeroRotation () {
    float[] r = app.arbitrarySection_rotateWorldToLocal(3, 4, 5, 0, 0, 0);
    assertArrayEquals(new float[]{3, 4, 5}, r, 0.0001f);
  }

  @Test
  void rotateWorldToLocal_undoesRotateLocalToWorld_forAKnownCase () {
    float[] world = app.arbitrarySection_rotateLocalToWorld(0, 1, 0, 90, 0, 0); // -> (0,0,1)
    float[] backToLocal = app.arbitrarySection_rotateWorldToLocal(world[0], world[1], world[2], 90, 0, 0);
    assertArrayEquals(new float[]{0, 1, 0}, backToLocal, 0.0001f);
  }

  @Test
  void rotateWorldToLocal_roundTrips_forSeveralArbitraryAnglesAndPoints () {
    float[][] angles = {
      {0, 0, 0}, {90, 0, 0}, {0, 90, 0}, {0, 0, 90},
      {30, -45, 60}, {-15, 200, 350}, {17, 83, -229}
    };
    float[][] points = {
      {1, 0, 0}, {0, 1, 0}, {0, 0, 1}, {2, -3, 5}, {-7, 11, -13}
    };

    for (float[] ang : angles) {
      for (float[] p : points) {
        float[] local = app.arbitrarySection_rotateWorldToLocal(p[0], p[1], p[2], ang[0], ang[1], ang[2]);
        float[] backToWorld = app.arbitrarySection_rotateLocalToWorld(local[0], local[1], local[2], ang[0], ang[1], ang[2]);
        assertArrayEquals(p, backToWorld, 0.001f,
            "round trip failed for angles=" + java.util.Arrays.toString(ang) + " point=" + java.util.Arrays.toString(p));
      }
    }
  }

  // ================= point wrappers (translation folded in) ==============

  @Test
  void pointLocalToWorld_addsThePositionAfterRotating () {
    float[] r = app.arbitrarySection_pointLocalToWorld(0, 0, 0, 40, 50, 60, 100, 200, 300);
    // local (0,0,0) rotates to (0,0,0) regardless of angle, so only the
    // translation should show up.
    assertArrayEquals(new float[]{100, 200, 300}, r, 0.0001f);
  }

  @Test
  void pointWorldToLocal_isTheExactInverseOfPointLocalToWorld () {
    float[] world = app.arbitrarySection_pointLocalToWorld(5, -2, 7, 22, -33, 128, 10, -20, 30);
    float[] backToLocal = app.arbitrarySection_pointWorldToLocal(world[0], world[1], world[2], 22, -33, 128, 10, -20, 30);
    assertArrayEquals(new float[]{5, -2, 7}, backToLocal, 0.001f);
  }

  // ================= Sections.getCorners() - type 0 ======================

  @Test
  void getCorners_type0_centerIsExactlyXYZ_regardlessOfRotation () {
    float[][] corners = app.allSections.getCorners(0, 10, 20, 30, 15, 25, 35, 40, 50, 100, 100);
    // Index 0 is the center point (CORNER_LOCAL's own row 0, sections.pde).
    assertArrayEquals(new float[]{10, 20, 30}, java.util.Arrays.copyOf(corners[0], 3), 0.0001f);
  }

  @Test
  void getCorners_type0_atZeroRotation_matchesType1AtZeroR () {
    // Sanity cross-check: an arbitrary section with every angle at 0 must
    // draw the exact same rectangle a type-1 (horizontal) section at R=0
    // already does - same CORNER_LOCAL grid, same flat-in-XY-then-translate
    // shape, just reached via 2 different code paths (getCorners()'s type-0
    // branch vs. rotateSectionCorner()'s type-1 branch, sections.pde).
    float[][] type0 = app.allSections.getCorners(0, 10, 20, 30, 0, 0, 0, 40, 50, 100, 100);
    float[][] type1 = app.allSections.getCorners(1, 10, 20, 30, 0, 0, 0, 40, 50, 100, 100);

    for (int q = 0; q < 5; q++) {
      assertArrayEquals(type1[q], type0[q], 0.0001f, "corner " + q + " differs");
    }
  }

  @Test
  void getCorners_type0_rotZ90_spinsTheRectangleInItsOwnPlane () {
    // U != V so a 90-degree roll (rotZ) is actually detectable: the wide
    // axis becomes the tall one. CORNER_LOCAL row 1 is local (-U/2, -V/2);
    // with U=40, V=20 that's local (-20, -10, 0), hand-rotated by rotZ=90
    // (funcs.cos_ang(90)=0, funcs.sin_ang(90)=1) through
    // arbitrarySection_rotateLocalToWorld()'s own Z step: x = a*0 - b*1 =
    // -b = 10; y = a*1 + b*0 = a = -20; z = c = 0.
    float[][] corners = app.allSections.getCorners(0, 0, 0, 0, 0, 0, 90, 40, 20, 100, 100);

    assertArrayEquals(new float[]{10, -20, 0}, java.util.Arrays.copyOf(corners[1], 3), 0.001f);
  }

  // ================= Sections.RotateX/Y/Z =================================
  // Already covered in depth in SectionsTest.java - just the cross-file
  // Rotate3D wiring is covered here.

  // ================= Rotate3D.Sections() ===================================

  @Test
  void rotate3DSections_type0_dispatchesByTheVector_withoutTouchingR_whenNotVectorX () {
    app.allSections.f_data = new float[][]{new float[8]};
    app.allSections.i_data = new int[][]{{0, 100, 100}}; // type 0
    app.allSections.num = 1;
    app.allSections.SolidImpact = new processing.core.PImage[]{app.createImage(100, 100, processing.core.PConstants.RGB)};
    app.Select3D.sectionSelection = new int[]{0};

    app.Rotate3D.Sections((float) Math.toRadians(45), 2); // the_Vector 2 = Z

    assertEquals(0f, app.allSections.getR(0), 0.0001f);     // untouched (rotX)
    assertEquals(0f, app.allSections.getRotY(0), 0.0001f);  // untouched
    assertEquals(45f, app.allSections.getRotZ(0), 0.01f);
  }

  @Test
  void rotate3DSections_type0_vectorX_accumulatesIntoR () {
    app.allSections.f_data = new float[][]{new float[8]};
    app.allSections.i_data = new int[][]{{0, 100, 100}};
    app.allSections.num = 1;
    app.allSections.SolidImpact = new processing.core.PImage[]{app.createImage(100, 100, processing.core.PConstants.RGB)};
    app.Select3D.sectionSelection = new int[]{0};

    app.Rotate3D.Sections((float) Math.toRadians(30), 0); // the_Vector 0 = X

    assertEquals(30f, app.allSections.getR(0), 0.01f);
    assertEquals(0f, app.allSections.getRotY(0), 0.0001f);
    assertEquals(0f, app.allSections.getRotZ(0), 0.0001f);
  }

  @Test
  void rotate3DSections_type1_ignoresTheVector_rotatesROnly () {
    // Regression: types 1/2/3 must keep their pre-existing behavior -
    // one single angle (R), unaffected by which axis handle was dragged -
    // exactly as before the_Vector was threaded through at all.
    app.allSections.f_data = new float[][]{{0, 0, 0, 10, 1, 1, 0, 0}};
    app.allSections.i_data = new int[][]{{1, 100, 100}}; // type 1
    app.allSections.num = 1;
    app.allSections.SolidImpact = new processing.core.PImage[]{app.createImage(100, 100, processing.core.PConstants.RGB)};
    app.Select3D.sectionSelection = new int[]{0};

    app.Rotate3D.Sections((float) Math.toRadians(5), 1); // the_Vector 1 = Y - irrelevant for type 1

    assertEquals(15f, app.allSections.getR(0), 0.01f);
    assertEquals(0f, app.allSections.getRotY(0), 0.0001f);
    assertEquals(0f, app.allSections.getRotZ(0), 0.0001f);
  }
}
