import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class FaceIntersectionTest {

  private solarchvision_bim app;
  private static final float EPS = 0.001f;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // --- cellIndexX / cellIndexY / cellIndexZ ---------------------------

  @Test
  void cellIndexX_mapsWorldCoordinatesToCellIndices () {
    app.gridMinX = 0;
    app.gridNx = 5;
    app.cellSizeX = 2; // 5 cells covering [0, 10)

    assertEquals(0, app.cellIndexX(0));
    assertEquals(0, app.cellIndexX(1.9f));
    assertEquals(1, app.cellIndexX(2.0f));
    assertEquals(4, app.cellIndexX(9.999f));
  }

  @Test
  void cellIndexX_clampsOutOfRangeCoordinatesToTheEdgeCell () {
    app.gridMinX = 0;
    app.gridNx = 5;
    app.cellSizeX = 2;

    assertEquals(0, app.cellIndexX(-5));   // below the grid: clamp to the first cell
    assertEquals(4, app.cellIndexX(100));  // beyond the grid: clamp to the last cell
  }

  @Test
  void cellIndexY_and_cellIndexZ_useTheirOwnAxisFields () {
    // Different bounds/resolution per axis, to catch any accidental
    // cross-wiring between the X/Y/Z implementations.
    app.gridMinY = -10;
    app.gridNy = 10;
    app.cellSizeY = 1; // 10 cells covering [-10, 0)

    app.gridMinZ = 100;
    app.gridNz = 2;
    app.cellSizeZ = 5; // 2 cells covering [100, 110)

    assertEquals(0, app.cellIndexY(-10));
    assertEquals(3, app.cellIndexY(-7));
    assertEquals(9, app.cellIndexY(-0.5f));

    assertEquals(0, app.cellIndexZ(100));
    assertEquals(1, app.cellIndexZ(106));
  }

  @Test
  void cellFlatIndex_isUniqueAcrossTheWholeGrid () {
    // Note: cellFlatIndex's formula ((ix * gridNy + iy) * gridNz + iz)
    // doesn't reference gridNx at all - the caller is expected to keep
    // ix < gridNx itself, so it's left unset here.
    app.gridNy = 10;
    app.gridNz = 2;

    assertEquals(0, app.cellFlatIndex(0, 0, 0));
    assertEquals(25, app.cellFlatIndex(1, 2, 1)); // (1*10 + 2) * 2 + 1
    assertEquals(99, app.cellFlatIndex(4, 9, 1)); // (4*10 + 9) * 2 + 1 - last cell of a 5x10x2 grid
  }

  // --- rayHitsGridBounds ------------------------------------------

  private void setUnitCubeBounds () {
    app.gridMinX = app.gridMinY = app.gridMinZ = 0;
    app.gridMaxX = app.gridMaxY = app.gridMaxZ = 10;
  }

  @Test
  void rayHitsGridBounds_findsTheEntryDistanceFromOutside () {
    setUnitCubeBounds();
    float[] tEnter = new float[1];
    boolean hit = app.rayHitsGridBounds(
      new float[]{-5, 5, 5}, new float[]{1, 0, 0}, tEnter);
    assertTrue(hit);
    assertEquals(5f, tEnter[0], EPS);
  }

  @Test
  void rayHitsGridBounds_missesWhenTheBoxIsBehindTheRay () {
    setUnitCubeBounds();
    float[] tEnter = new float[1];
    boolean hit = app.rayHitsGridBounds(
      new float[]{-5, 5, 5}, new float[]{-1, 0, 0}, tEnter);
    assertFalse(hit);
  }

  @Test
  void rayHitsGridBounds_clampsEntryToZeroWhenStartingInsideTheBox () {
    setUnitCubeBounds();
    float[] tEnter = new float[1];
    boolean hit = app.rayHitsGridBounds(
      new float[]{5, 5, 5}, new float[]{1, 0, 0}, tEnter);
    assertTrue(hit);
    assertEquals(0f, tEnter[0], EPS);
  }

  @Test
  void rayHitsGridBounds_missesWhenOffToTheSideOnAParallelAxis () {
    setUnitCubeBounds();
    float[] tEnter = new float[1];
    // Moving parallel to X, but sitting at y=50 - outside [0,10] on an
    // axis the ray never moves along, so it can never enter the box.
    boolean hit = app.rayHitsGridBounds(
      new float[]{-5, 50, 5}, new float[]{1, 0, 0}, tEnter);
    assertFalse(hit);
  }

  // --- testFaceHit (triangle branch) --------------------

  // Builds a single triangle face (A=(0,0,0), B=(2,0,0), C=(0,2,0), in
  // the z=0 plane) as face index 1, bypassing buildFaceGrid
  // entirely - just the raw point/face lists it would otherwise populate
  // from the real scene.
  private void buildSingleTriangleFace () {
    app.entirePointsX = new java.util.ArrayList<Float>();
    app.entirePointsY = new java.util.ArrayList<Float>();
    app.entirePointsZ = new java.util.ArrayList<Float>();
    app.entireFaces = new java.util.ArrayList<int[]>();
    app.entireFaces.add(new int[0]); // index 0 is reserved/empty, as buildFaceGrid does

    float[][] triangle = {{0, 0, 0}, {2, 0, 0}, {0, 2, 0}};
    for (float[] p : triangle) {
      app.entirePointsX.add(p[0]);
      app.entirePointsY.add(p[1]);
      app.entirePointsZ.add(p[2]);
    }
    app.entireFaces.add(new int[]{0, 1, 2});
  }

  @Test
  void testFaceHit_hitsWhenTheRayCrossesTheTriangleInterior () {
    buildSingleTriangleFace();
    float[] P = new float[3];
    float[] N = new float[3];
    float dist = app.testFaceHit(
      1, new float[]{0.5f, 0.5f, 10}, new float[]{0, 0, -1}, P, N);

    assertEquals(10f, dist, EPS);
    assertArrayEquals(new float[]{0.5f, 0.5f, 0}, P, EPS);
    assertArrayEquals(new float[]{0, 0, 1}, N, EPS);
  }

  @Test
  void testFaceHit_missesWhenThePlaneHitLandsOutsideTheTriangle () {
    buildSingleTriangleFace();
    float[] P = new float[3];
    float dist = app.testFaceHit(
      1, new float[]{5, 5, 10}, new float[]{0, 0, -1}, P);
    assertEquals(app.FLOAT_huge, dist, EPS);
  }

  @Test
  void testFaceHit_missesWhenTheIntersectionIsBehindTheRayOrigin () {
    buildSingleTriangleFace();
    float[] P = new float[3];
    // Ray starts below the plane and points further away from it.
    float dist = app.testFaceHit(
      1, new float[]{0.5f, 0.5f, -10}, new float[]{0, 0, -1}, P);
    assertEquals(app.FLOAT_huge, dist, EPS);
  }

  @Test
  void testFaceHit_returnsHugeImmediatelyForADegenerateFace () {
    app.entirePointsX = new java.util.ArrayList<Float>();
    app.entirePointsY = new java.util.ArrayList<Float>();
    app.entirePointsZ = new java.util.ArrayList<Float>();
    app.entireFaces = new java.util.ArrayList<int[]>();
    app.entireFaces.add(new int[0]);
    app.entirePointsX.add(0f); app.entirePointsY.add(0f); app.entirePointsZ.add(0f);
    app.entirePointsX.add(1f); app.entirePointsY.add(0f); app.entirePointsZ.add(0f);
    app.entireFaces.add(new int[]{0, 1}); // only 2 nodes - not a polygon

    float[] P = new float[3];
    float dist = app.testFaceHit(
      1, new float[]{0, 0, 10}, new float[]{0, 0, -1}, P);
    assertEquals(app.FLOAT_huge, dist, EPS);
  }

  // --- passesAlphaTest ---------------------------------------------

  @Test
  void passesAlphaTest_returnsTrueWhenEntireFaceAlphaTextureWasNeverBuilt () {
    // Regression test: entireFaceAlphaTexture/entireFaceUVBasis are only
    // ever allocated inside buildFaceGrid() - a caller that populates
    // entireFaces directly and calls testFaceHit() without ever going
    // through buildFaceGrid() (e.g. buildSingleTriangleFace() above) used
    // to NPE here before this null guard was added.
    assertTrue(app.passesAlphaTest(1, new float[]{0, 0, 0}));
  }

  @Test
  void passesAlphaTest_returnsTrueWhenThisFacesOwnTextureEntryIsNull () {
    app.entireFaceAlphaTexture = new java.util.ArrayList<processing.core.PImage>();
    app.entireFaceAlphaTexture.add(null); // index 0, unused here
    app.entireFaceAlphaTexture.add(null); // face 1: no texture -> opaque everywhere

    assertTrue(app.passesAlphaTest(1, new float[]{0, 0, 0}));
  }

  @Test
  void passesAlphaTest_returnsTrueForAPixelAtOrAboveTheAlphaThreshold () {
    processing.core.PImage tex = app.createImage(4, 4, processing.core.PConstants.ARGB);
    tex.loadPixels();
    for (int i = 0; i < tex.pixels.length; i++) tex.pixels[i] = app.color(0, 0, 0, 255); // fully opaque
    tex.updatePixels();

    app.entireFaceAlphaTexture = new java.util.ArrayList<processing.core.PImage>();
    app.entireFaceAlphaTexture.add(null);
    app.entireFaceAlphaTexture.add(tex);

    app.entireFaceUVBasis = new java.util.ArrayList<float[]>();
    app.entireFaceUVBasis.add(null);
    // origin=(0,0,0), widthDir=(1,0) widthLen=2, heightDir=(0,0,1) heightLen=2, vNear=4, vFar=0
    app.entireFaceUVBasis.add(new float[]{0, 0, 0, 1, 0, 2, 0, 0, 1, 2, 4, 0});

    assertTrue(app.passesAlphaTest(1, new float[]{1, 0, 1})); // middle of the quad
  }

  @Test
  void passesAlphaTest_returnsFalseForAPixelBelowTheAlphaThreshold () {
    // createImage() starts fully transparent (alpha=0) - left untouched.
    processing.core.PImage tex = app.createImage(4, 4, processing.core.PConstants.ARGB);

    app.entireFaceAlphaTexture = new java.util.ArrayList<processing.core.PImage>();
    app.entireFaceAlphaTexture.add(null);
    app.entireFaceAlphaTexture.add(tex);

    app.entireFaceUVBasis = new java.util.ArrayList<float[]>();
    app.entireFaceUVBasis.add(null);
    app.entireFaceUVBasis.add(new float[]{0, 0, 0, 1, 0, 2, 0, 0, 1, 2, 4, 0});

    assertFalse(app.passesAlphaTest(1, new float[]{1, 0, 1}));
  }

  // --- faceTexturePixel ---------------------------------------------

  @Test
  void faceTexturePixel_mapsAHitPointToThePixelItsUVBasisImplies () {
    processing.core.PImage tex = app.createImage(4, 8, processing.core.PConstants.ARGB); // width 4, height 8

    app.entireFaceAlphaTexture = new java.util.ArrayList<processing.core.PImage>();
    app.entireFaceAlphaTexture.add(null);
    app.entireFaceAlphaTexture.add(tex);

    app.entireFaceUVBasis = new java.util.ArrayList<float[]>();
    app.entireFaceUVBasis.add(null);
    // origin=(0,0,0), widthDir=(1,0) widthLen=4, heightDir=(0,0,1) heightLen=2, vNear=8, vFar=0
    app.entireFaceUVBasis.add(new float[]{0, 0, 0, 1, 0, 4, 0, 0, 1, 2, 8, 0});

    // P=(2,0,1): u = 2/4 = 0.5 -> px = 0.5*4 = 2; heightFrac = 1/2 = 0.5 -> py = 8 + 0.5*(0-8) = 4
    int[] texel = app.faceTexturePixel(1, new float[]{2, 0, 1});

    assertEquals(2, texel[0]);
    assertEquals(4, texel[1]);
  }

  // --- faceCastsShadow ------------------------------------------------

  @Test
  void faceCastsShadow_returnsTrueWhenEntireFaceCastsShadowWasNeverBuilt () {
    // Same null-safety reasoning as passesAlphaTest()'s own guard above.
    assertTrue(app.faceCastsShadow(1));
  }

  @Test
  void faceCastsShadow_returnsTheStoredFlagForThatFace () {
    app.entireFaceCastsShadow = new java.util.ArrayList<Boolean>();
    app.entireFaceCastsShadow.add(true);  // index 0, unused here
    app.entireFaceCastsShadow.add(false); // face 1 flagged non-shadow-casting (e.g. a person)

    assertFalse(app.faceCastsShadow(1));
  }

  // --- padEntireFaceExtras ---------------------------------------------

  @Test
  void padEntireFaceExtras_fillsMissingEntriesWithTheirDefaults () {
    app.entireFaces = new java.util.ArrayList<int[]>();
    app.entireFaces.add(new int[0]);
    app.entireFaces.add(new int[]{0, 1, 2});
    app.entireFaces.add(new int[]{0, 1, 2}); // size 3 - ahead of the extras below

    app.entireFaceAlphaTexture = new java.util.ArrayList<processing.core.PImage>();
    app.entireFaceAlphaTexture.add(null); // size 1 - behind
    app.entireFaceUVBasis = new java.util.ArrayList<float[]>();
    app.entireFaceUVBasis.add(null);
    app.entireFaceCastsShadow = new java.util.ArrayList<Boolean>();
    app.entireFaceCastsShadow.add(true);

    app.padEntireFaceExtras();

    assertEquals(3, app.entireFaceAlphaTexture.size());
    assertEquals(3, app.entireFaceUVBasis.size());
    assertEquals(3, app.entireFaceCastsShadow.size());
    assertNull(app.entireFaceAlphaTexture.get(2));
    assertNull(app.entireFaceUVBasis.get(2));
    assertTrue(app.entireFaceCastsShadow.get(2)); // default: casts a shadow
  }

  // --- isIntersected_Faces (grid walk) / ignoreNonShadowCasters --------

  // Wraps buildSingleTriangleFace()'s own triangle in a minimal
  // single-cell grid (gridNx=gridNy=gridNz=1, so the one real face always
  // lands in cell 0) so the full grid-walking isIntersected_Faces() - not
  // just testFaceHit() - can be exercised directly, without going through
  // buildFaceGrid() and its allFaces/allModel1Ds/allModel2Ds dependencies.
  private void buildSingleTriangleGrid (boolean castsShadow) {
    buildSingleTriangleFace();

    app.gridMinX = app.gridMinY = -10;
    app.gridMinZ = -10;
    app.gridMaxX = app.gridMaxY = 10;
    app.gridMaxZ = 20;
    app.gridNx = app.gridNy = app.gridNz = 1;
    app.cellSizeX = (app.gridMaxX - app.gridMinX) / app.gridNx;
    app.cellSizeY = (app.gridMaxY - app.gridMinY) / app.gridNy;
    app.cellSizeZ = (app.gridMaxZ - app.gridMinZ) / app.gridNz;

    app.gridCells = new processing.data.IntList[1];
    app.gridCells[0] = new processing.data.IntList();
    app.gridCells[0].append(1); // our one real face, index 1

    app.faceTestStampSize = 2; // getRayStampState() lazily sizes this thread's own array from this - see that method's own comment

    app.entireFaceCastsShadow = new java.util.ArrayList<Boolean>();
    app.entireFaceCastsShadow.add(true);  // index 0, unused here
    app.entireFaceCastsShadow.add(castsShadow);
  }

  @Test
  void isIntersectedFaces_defaultOverload_hitsAFaceRegardlessOfItsShadowFlag () {
    buildSingleTriangleGrid(false); // flagged non-shadow-casting

    int f = app.isIntersected_Faces(new float[]{0.5f, 0.5f, 10}, new float[]{0, 0, -1}, 0);

    assertEquals(1, f); // the plain 3-arg overload never excludes anyone
  }

  @Test
  void isIntersectedFaces_ignoreNonShadowCastersTrue_skipsAFaceFlaggedFalse () {
    buildSingleTriangleGrid(false);

    int f = app.isIntersected_Faces(new float[]{0.5f, 0.5f, 10}, new float[]{0, 0, -1}, 0, true);

    assertEquals(0, f); // skipped entirely, as if it weren't in the grid at all
  }

  @Test
  void isIntersectedFaces_ignoreNonShadowCastersTrue_stillHitsAFaceFlaggedTrue () {
    buildSingleTriangleGrid(true);

    int f = app.isIntersected_Faces(new float[]{0.5f, 0.5f, 10}, new float[]{0, 0, -1}, 0, true);

    assertEquals(1, f); // a shadow-casting face is never excluded
  }

  // --- cameraHasMovedSinceFaceGridBuild ---------------------------------

  @Test
  void cameraHasMovedSinceFaceGridBuild_trueBeforeAnyRealBuild () {
    // lastFaceGridCameraX/Y default to Float.NaN on a fresh instance.
    assertTrue(app.cameraHasMovedSinceFaceGridBuild());
  }

  @Test
  void cameraHasMovedSinceFaceGridBuild_falseWhenCameraXAndYAreUnchanged () {
    app.lastFaceGridCameraX = 5;
    app.lastFaceGridCameraY = 7;
    app.WIN3D.cameraX = 5;
    app.WIN3D.cameraY = 7;

    assertFalse(app.cameraHasMovedSinceFaceGridBuild());
  }

  @Test
  void cameraHasMovedSinceFaceGridBuild_trueWhenCameraXChanges () {
    app.lastFaceGridCameraX = 5;
    app.lastFaceGridCameraY = 7;
    app.WIN3D.cameraX = 50;
    app.WIN3D.cameraY = 7;

    assertTrue(app.cameraHasMovedSinceFaceGridBuild());
  }

  @Test
  void cameraHasMovedSinceFaceGridBuild_trueWhenCameraYChanges () {
    app.lastFaceGridCameraX = 5;
    app.lastFaceGridCameraY = 7;
    app.WIN3D.cameraX = 5;
    app.WIN3D.cameraY = 70;

    assertTrue(app.cameraHasMovedSinceFaceGridBuild());
  }

  @Test
  void cameraHasMovedSinceFaceGridBuild_ignoresCameraZChangingAlone () {
    // The actual bug being regression-tested: a camera move that only
    // changes Z (zoom, or a tilt-only orbit) must NOT be reported as
    // movement, since Model2Ds.addToFaceGrid()'s t0 never reads cameraZ.
    app.lastFaceGridCameraX = 5;
    app.lastFaceGridCameraY = 7;
    app.WIN3D.cameraX = 5;
    app.WIN3D.cameraY = 7;
    app.WIN3D.cameraZ = 99999;

    assertFalse(app.cameraHasMovedSinceFaceGridBuild());
  }
}
