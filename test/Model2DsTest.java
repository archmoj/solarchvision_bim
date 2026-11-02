import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class Model2DsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= makeEmpty ========================================

  @Test
  void makeEmpty_resetsXYZSAndIdentityArraysToTheGivenLength () {
    app.allModel2Ds.makeEmpty(3);
    assertEquals(3, app.allModel2Ds.num);
    assertEquals(3, app.allModel2Ds.XYZS.length);
    assertEquals(4, app.allModel2Ds.XYZS[0].length);
    assertEquals(3, app.allModel2Ds.Kind.length);
    assertEquals(3, app.allModel2Ds.FileIndex.length);
    assertEquals(3, app.allModel2Ds.Mirror.length);
  }

  // ================= create ===========================================

  @Test
  void create_appendsPositionAndScaleAndPreservesTheGivenKindAndLocalIndex () {
    // Unlike the old flat-array scheme, a kind's own fileCount is all
    // that bounds its own magnitude now - no cross-kind n1/n2 math.
    app.TREES_KIND.fileCount = 10;

    app.allModel2Ds.create("TREES", 5, 10, 20, 30, 2);

    assertEquals(1, app.allModel2Ds.num);
    assertEquals(10f, app.allModel2Ds.getX(0), 0.0001f);
    assertEquals(20f, app.allModel2Ds.getY(0), 0.0001f);
    assertEquals(30f, app.allModel2Ds.getZ(0), 0.0001f);
    assertEquals(2f, app.allModel2Ds.getS(0), 0.0001f);
    assertSame(app.TREES_KIND, app.allModel2Ds.Kind[0]);
    assertEquals(5, app.allModel2Ds.FileIndex[0]);
    assertFalse(app.allModel2Ds.Mirror[0]); // m=5 is positive -> not mirrored
  }

  @Test
  void create_negativeMagnitudeMirrorsAndKeepsTheSameLocalIndex () {
    app.PEOPLE_KIND.fileCount = 10;

    app.allModel2Ds.create("PEOPLE", -3, 0, 0, 0, 1);

    assertEquals(3, app.allModel2Ds.FileIndex[0]);
    assertTrue(app.allModel2Ds.Mirror[0]);
  }

  @Test
  void create_clampsAMagnitudePastTheKindsOwnFileCountInsteadOfRunningPastTheArray () {
    // The old scheme had no upper clamp for TREES (only PEOPLE), so a
    // too-large magnitude could index past the end of the flat array.
    // Every kind is bounds-checked the same way now.
    app.TREES_KIND.fileCount = 4;

    app.allModel2Ds.create("TREES", 99, 0, 0, 0, 1);

    assertEquals(4, app.allModel2Ds.FileIndex[0]);
  }

  @Test
  void create_zeroMagnitudeWithNoFilesLoadedPicksLocalIndexZero () {
    // fileCount defaults to 0 when loadImages() hasn't run (as in this
    // test environment) - "pick a random variant" degrades gracefully
    // to index 0 rather than calling random() with an empty range.
    app.allModel2Ds.create("TREES", 0, 0, 0, 0, 1);

    assertEquals(0, app.allModel2Ds.FileIndex[0]);
  }

  @Test
  void create_extendsTheLastGroupsModel2DRangeWhenAGroupExists () {
    app.allGroups.makeEmpty(1);
    app.allGroups.Model2Ds[0] = new int[]{0, -1};

    app.allModel2Ds.create("PEOPLE", 1, 0, 0, 0, 1);

    assertArrayEquals(new int[]{0, 0}, app.allGroups.Model2Ds[0]);
  }

  @Test
  void create_alsoCreatesAMatchingSolidWhenBuildingATreeAndExportModeIsSolid () {
    app.User3D.creatorMeshOrSolidMode = 1; // 0=Mesh (default, skips this branch), 1=Solid
    app.allSolids.DEF = new float[0][13];
    app.TREES_KIND.fileCount = 10;

    app.allModel2Ds.create("TREES", 3, 10, 20, 30, 2);

    assertEquals(1, app.allSolids.DEF.length); // the cascade fired
    assertEquals(10f, app.allSolids.DEF[0][0], 0.0001f); // posX
    assertEquals(20f, app.allSolids.DEF[0][1], 0.0001f); // posY
    assertEquals(31f, app.allSolids.DEF[0][2], 0.0001f); // posZ = 0.5*s + z = 0.5*2 + 30
  }

  @Test
  void create_doesNotCreateASolidForAPerson () {
    app.User3D.creatorMeshOrSolidMode = 1;
    app.allSolids.DEF = new float[0][13];
    // No peopleFileCount-vs-treesFileCount setup needed any more - a
    // kind's own isTree() is just a fixed property of PEOPLE_KIND, not
    // something derived from where its magnitude happens to fall.
    app.PEOPLE_KIND.fileCount = 5;

    app.allModel2Ds.create("PEOPLE", 1, 10, 20, 30, 2);

    assertEquals(0, app.allSolids.DEF.length); // no solid cascade for people
  }

  // ================= getters / setters =================================

  @Test
  void gettersAndSetters_roundTripEveryColumn () {
    app.allModel2Ds.XYZS = new float[][]{new float[4]};
    app.allModel2Ds.setX(0, 1);
    app.allModel2Ds.setY(0, 2);
    app.allModel2Ds.setZ(0, 3);
    app.allModel2Ds.setS(0, 4);

    assertEquals(1f, app.allModel2Ds.getX(0), 0.0001f);
    assertEquals(2f, app.allModel2Ds.getY(0), 0.0001f);
    assertEquals(3f, app.allModel2Ds.getZ(0), 0.0001f);
    assertEquals(4f, app.allModel2Ds.getS(0), 0.0001f);
  }

  // ================= move / magS ========================================

  @Test
  void move_addsTheOffsetToPositionOnly () {
    app.allModel2Ds.XYZS = new float[][]{{1, 1, 1, 5}};
    app.allModel2Ds.move(0, 1, 2, 3);
    assertArrayEquals(new float[]{2, 3, 4, 5}, app.allModel2Ds.XYZS[0], 0.0001f);
  }

  @Test
  void magS_multipliesScaleOnly () {
    app.allModel2Ds.XYZS = new float[][]{{1, 1, 1, 5}};
    app.allModel2Ds.magS(0, 3);
    assertArrayEquals(new float[]{1, 1, 1, 15}, app.allModel2Ds.XYZS[0], 0.0001f);
  }

  // ================= isTree / isScalable ================================

  @Test
  void isTree_reflectsEachInstancesOwnKindRatherThanAMagnitudeBoundary () {
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.PEOPLE_KIND, app.TREES_KIND};
    assertFalse(app.allModel2Ds.isTree(0));
    assertTrue(app.allModel2Ds.isTree(1));
  }

  @Test
  void isScalable_isFalseForPeopleAndTrueForTrees () {
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.PEOPLE_KIND, app.TREES_KIND};
    assertFalse(app.allModel2Ds.isScalable(0)); // "does not scale people!"
    assertTrue(app.allModel2Ds.isScalable(1));
  }

  // ================= intersect =========================================

  @Test
  void intersect_hitsAnOpaquePixelThroughTheCentroid () {
    app.allModel2Ds.Vertices = new float[][]{
      {0, 0, 0, 0, 0}, {2, 0, 0, 1, 0}, {2, 2, 0, 1, 1}, {0, 2, 0, 0, 1}
    };
    app.allModel2Ds.Faces = new int[][]{{0, 1, 2, 3}};
    app.allModel2Ds.num_visualFaces = 1; // so OBJ_ID = f directly, one face per object
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.TREES_KIND};
    app.allModel2Ds.FileIndex = new int[]{1};

    app.TREES_KIND.Images = new processing.core.PImage[2]; // index 0 left null, by convention
    processing.core.PImage img = app.createImage(4, 4, processing.core.PConstants.ARGB);
    img.loadPixels();
    for (int i = 0; i < img.pixels.length; i++) img.pixels[i] = app.color(255, 255, 255, 255); // fully opaque
    img.updatePixels();
    app.TREES_KIND.Images[1] = img;

    float[] result = app.allModel2Ds.intersect(new float[]{1, 1, 10}, new float[]{0, 0, -1});

    assertEquals(0, (int) result[0]);
    assertEquals(1f, result[1], 0.0001f);
    assertEquals(1f, result[2], 0.0001f);
    assertEquals(0f, result[3], 0.0001f);
    assertEquals(10f, result[4], 0.0001f);
  }

  @Test
  void intersect_missesAGeometricHitOnAFullyTransparentPixel () {
    app.allModel2Ds.Vertices = new float[][]{
      {0, 0, 0, 0, 0}, {2, 0, 0, 1, 0}, {2, 2, 0, 1, 1}, {0, 2, 0, 0, 1}
    };
    app.allModel2Ds.Faces = new int[][]{{0, 1, 2, 3}};
    app.allModel2Ds.num_visualFaces = 1;
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.TREES_KIND};
    app.allModel2Ds.FileIndex = new int[]{1};

    app.TREES_KIND.Images = new processing.core.PImage[2];
    // createImage() starts fully transparent (alpha=0) by default - left untouched here.
    app.TREES_KIND.Images[1] = app.createImage(4, 4, processing.core.PConstants.ARGB);

    float[] result = app.allModel2Ds.intersect(new float[]{1, 1, 10}, new float[]{0, 0, -1});

    assertEquals(-1, (int) result[0]); // geometrically hit, but the pixel there is transparent
  }

  @Test
  void intersect_missesWhenTheRayEntirelyMissesTheGeometry () {
    app.allModel2Ds.Vertices = new float[][]{
      {0, 0, 0, 0, 0}, {2, 0, 0, 1, 0}, {2, 2, 0, 1, 1}, {0, 2, 0, 0, 1}
    };
    app.allModel2Ds.Faces = new int[][]{{0, 1, 2, 3}};
    app.allModel2Ds.num_visualFaces = 1;
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.TREES_KIND};
    app.allModel2Ds.FileIndex = new int[]{1};
    app.TREES_KIND.Images = new processing.core.PImage[2];
    app.TREES_KIND.Images[1] = app.createImage(4, 4, processing.core.PConstants.ARGB);

    float[] result = app.allModel2Ds.intersect(new float[]{50, 50, 10}, new float[]{0, 0, -1});

    assertEquals(-1, (int) result[0]);
  }

  // ================= addToFaceGrid ======================================

  // addToFaceGrid() reads entirePointsX/Y/Z/entireFaces/entireFaceAlphaTexture/
  // entireFaceUVBasis/entireFaceCastsShadow directly (the same globals
  // buildFaceGrid() would normally own - see isIntersectedFaces.pde) and
  // WIN3D.rotationZ/cameraX/Y/projectionTypeIndex for its camera-facing t0.
  // Orthographic with rotationZ=0 is used throughout so t0 is an exact,
  // easy-to-hand-check PI (cos=-1, sin=0), independent of any camera
  // position setup the perspective branch would otherwise need.
  private void initEmptyFaceGrid () {
    app.entirePointsX = new java.util.ArrayList<Float>();
    app.entirePointsY = new java.util.ArrayList<Float>();
    app.entirePointsZ = new java.util.ArrayList<Float>();
    app.entireFaces = new java.util.ArrayList<int[]>();
    app.entireFaceAlphaTexture = new java.util.ArrayList<processing.core.PImage>();
    app.entireFaceUVBasis = new java.util.ArrayList<float[]>();
    app.entireFaceCastsShadow = new java.util.ArrayList<Boolean>();

    app.WIN3D.projectionTypeIndex = 0; // orthographic: t0 = PI + rotationZ*PI/180, no camera position needed
    app.WIN3D.rotationZ = 0; // so t0 = PI exactly
  }

  private processing.core.PImage makeImage (int w, int h, boolean opaque) {
    processing.core.PImage img = app.createImage(w, h, processing.core.PConstants.ARGB);
    if (opaque) {
      img.loadPixels();
      for (int i = 0; i < img.pixels.length; i++) img.pixels[i] = app.color(255, 255, 255, 255);
      img.updatePixels();
    } // else: createImage() already starts fully transparent
    return img;
  }

  @Test
  void addToFaceGrid_treeWithOneVerticalSection_addsOneQuadPlusTwoShadowCastingCaps () {
    initEmptyFaceGrid();
    app.allModel2Ds.verticalShadingSections = 1;
    app.allModel2Ds.num = 1;
    app.allModel2Ds.XYZS = new float[][]{{0, 0, 0, 2}}; // x,y,z,s -> rh = 0.5*s = 1
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.TREES_KIND};
    app.allModel2Ds.FileIndex = new int[]{1};
    app.allModel2Ds.Mirror = new boolean[]{false};
    app.TREES_KIND.Images = new processing.core.PImage[]{null, makeImage(4, 4, true)};

    app.allModel2Ds.addToFaceGrid();

    assertEquals(3, app.entireFaces.size()); // 1 vertical quad + 2 canopy cap quads
    for (int f = 0; f < 3; f++) {
      assertTrue(app.entireFaceCastsShadow.get(f)); // a tree always casts shadows
      assertSame(app.TREES_KIND.Images[1], app.entireFaceAlphaTexture.get(f));
    }

    // t0 = PI -> dx = rh*cos(PI) = -1, dy = rh*sin(PI) = 0
    // x1 = x-dx = 1, x2 = x+dx = -1, zBottom = 0, zTop = 2*rh = 2
    assertArrayEquals(new int[]{0, 1, 2, 3}, app.entireFaces.get(0));
    assertEquals(1f, app.entirePointsX.get(0), 0.0001f);
    assertEquals(0f, app.entirePointsY.get(0), 0.0001f);
    assertEquals(0f, app.entirePointsZ.get(0), 0.0001f);
    assertEquals(-1f, app.entirePointsX.get(1), 0.0001f);
    assertEquals(0f, app.entirePointsZ.get(1), 0.0001f);
    assertEquals(-1f, app.entirePointsX.get(2), 0.0001f);
    assertEquals(2f, app.entirePointsZ.get(2), 0.0001f);
    assertEquals(1f, app.entirePointsX.get(3), 0.0001f);
    assertEquals(2f, app.entirePointsZ.get(3), 0.0001f);

    // {originX,originY,originZ, widthDirX,widthDirY,widthLen, heightDirX,heightDirY,heightDirZ,heightLen, vPixelNear,vPixelFar}
    assertArrayEquals(
      new float[]{1, 0, 0, -1, 0, 2, 0, 0, 1, 2, 4, 0},
      app.entireFaceUVBasis.get(0), 0.0001f
    );
  }

  @Test
  void addToFaceGrid_treeWithTwoVerticalSections_addsTwoQuadsPlusTwoCaps () {
    initEmptyFaceGrid();
    app.allModel2Ds.verticalShadingSections = 2;
    app.allModel2Ds.num = 1;
    app.allModel2Ds.XYZS = new float[][]{{0, 0, 0, 2}};
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.TREES_KIND};
    app.allModel2Ds.FileIndex = new int[]{1};
    app.allModel2Ds.Mirror = new boolean[]{false};
    app.TREES_KIND.Images = new processing.core.PImage[]{null, makeImage(4, 4, true)};

    app.allModel2Ds.addToFaceGrid();

    assertEquals(4, app.entireFaces.size()); // 2 vertical quads + 2 canopy cap quads
  }

  @Test
  void addToFaceGrid_treeWithFourVerticalSections_addsFourQuadsPlusTwoCaps () {
    initEmptyFaceGrid();
    app.allModel2Ds.verticalShadingSections = 4;
    app.allModel2Ds.num = 1;
    app.allModel2Ds.XYZS = new float[][]{{0, 0, 0, 2}};
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.TREES_KIND};
    app.allModel2Ds.FileIndex = new int[]{1};
    app.allModel2Ds.Mirror = new boolean[]{false};
    app.TREES_KIND.Images = new processing.core.PImage[]{null, makeImage(4, 4, true)};

    app.allModel2Ds.addToFaceGrid();

    assertEquals(6, app.entireFaces.size()); // 4 vertical quads + 2 canopy cap quads
  }

  @Test
  void addToFaceGrid_person_addsExactlyOneNonShadowCastingQuadUsingImageRatio () {
    initEmptyFaceGrid();
    app.allModel2Ds.showPeopleInShade = true;
    app.allModel2Ds.verticalShadingSections = 4; // should be ignored entirely for a person
    app.allModel2Ds.num = 1;
    app.allModel2Ds.XYZS = new float[][]{{0, 0, 0, 2}}; // rh = 1
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.PEOPLE_KIND};
    app.allModel2Ds.FileIndex = new int[]{2};
    app.allModel2Ds.Mirror = new boolean[]{false};
    app.PEOPLE_KIND.Images = new processing.core.PImage[]{null, null, makeImage(4, 4, true)};
    app.PEOPLE_KIND.ImageRatios = new float[]{0, 0, 0.5f}; // rw = rh * 0.5 = 0.5, distinct from rh

    app.allModel2Ds.addToFaceGrid();

    assertEquals(1, app.entireFaces.size()); // no cap, no extra angles
    assertFalse(app.entireFaceCastsShadow.get(0)); // the whole point of showPeopleInShade

    // t0 = PI -> dx = rw*cos(PI) = -0.5, dy = 0
    assertEquals(0.5f, app.entirePointsX.get(0), 0.0001f);
    assertEquals(-0.5f, app.entirePointsX.get(1), 0.0001f);
  }

  @Test
  void addToFaceGrid_personWithShowPeopleInShadeOff_addsNothing () {
    initEmptyFaceGrid();
    app.allModel2Ds.showPeopleInShade = false;
    app.allModel2Ds.num = 1;
    app.allModel2Ds.XYZS = new float[][]{{0, 0, 0, 2}};
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.PEOPLE_KIND};
    app.allModel2Ds.FileIndex = new int[]{2};
    app.allModel2Ds.Mirror = new boolean[]{false};
    app.PEOPLE_KIND.Images = new processing.core.PImage[]{null, null, makeImage(4, 4, true)};
    app.PEOPLE_KIND.ImageRatios = new float[]{0, 0, 0.5f};

    app.allModel2Ds.addToFaceGrid();

    assertEquals(0, app.entireFaces.size());
    assertEquals(0, app.entirePointsX.size());
  }

  @Test
  void addToFaceGrid_whenDisplayAllIsFalse_addsNothingEvenForATree () {
    initEmptyFaceGrid();
    app.allModel2Ds.displayAll = false;
    app.allModel2Ds.num = 1;
    app.allModel2Ds.XYZS = new float[][]{{0, 0, 0, 2}};
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.TREES_KIND};
    app.allModel2Ds.FileIndex = new int[]{1};
    app.allModel2Ds.Mirror = new boolean[]{false};
    app.TREES_KIND.Images = new processing.core.PImage[]{null, makeImage(4, 4, true)};

    app.allModel2Ds.addToFaceGrid();

    assertEquals(0, app.entireFaces.size());
  }

  // ================= hasShadingContribution =============================

  @Test
  void hasShadingContribution_falseForAnEmptyModel () {
    app.allModel2Ds.displayAll = true;
    app.allModel2Ds.num = 0;
    assertFalse(app.allModel2Ds.hasShadingContribution());
  }

  @Test
  void hasShadingContribution_falseWhenDisplayAllIsFalseEvenWithATree () {
    app.allModel2Ds.displayAll = false;
    app.allModel2Ds.num = 1;
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.TREES_KIND}; // a tree

    assertFalse(app.allModel2Ds.hasShadingContribution());
  }

  @Test
  void hasShadingContribution_trueWhenATreeIsPresent () {
    app.allModel2Ds.displayAll = true;
    app.allModel2Ds.num = 1;
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.TREES_KIND};

    assertTrue(app.allModel2Ds.hasShadingContribution());
  }

  @Test
  void hasShadingContribution_falseForAPersonOnlySceneWithShowPeopleInShadeOff () {
    app.allModel2Ds.displayAll = true;
    app.allModel2Ds.showPeopleInShade = false;
    app.allModel2Ds.num = 1;
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.PEOPLE_KIND}; // a person

    assertFalse(app.allModel2Ds.hasShadingContribution());
  }

  @Test
  void hasShadingContribution_trueForAPersonOnlySceneWithShowPeopleInShadeOn () {
    app.allModel2Ds.displayAll = true;
    app.allModel2Ds.showPeopleInShade = true;
    app.allModel2Ds.num = 1;
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.PEOPLE_KIND};

    assertTrue(app.allModel2Ds.hasShadingContribution());
  }

  // ================= to_XML / from_XML round trip ======================

  @Test
  void toXMLThenFromXML_roundTripsPositionScaleKindFileIndexAndMirror () {
    // Filenames is set directly (rather than going through the real
    // input/images/trees folder via loadImages()) so to_XML/from_XML's
    // filename lookups are exercised without any real file I/O.
    app.TREES_KIND.Filenames = new String[]{"a.png", "b.png", "c.png", "d.png", "e.png"};
    app.TREES_KIND.fileCount = 5;

    app.allModel2Ds.XYZS = new float[][]{{10, 20, 30, 2}};
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.TREES_KIND};
    app.allModel2Ds.FileIndex = new int[]{5}; // "e.png"
    app.allModel2Ds.Mirror = new boolean[]{true};
    app.allModel2Ds.num = 1;
    app.allModel2Ds.displayAll = false;

    processing.data.XML root = new processing.data.XML("root");
    app.allModel2Ds.to_XML(root);

    solarchvision_bim.Model2Ds fresh = app.new Model2Ds();
    fresh.from_XML(root);

    assertEquals(1, fresh.num);
    assertEquals(10f, fresh.getX(0), 0.0001f);
    assertEquals(20f, fresh.getY(0), 0.0001f);
    assertEquals(30f, fresh.getZ(0), 0.0001f);
    assertEquals(2f, fresh.getS(0), 0.0001f);
    assertSame(app.TREES_KIND, fresh.Kind[0]); // resolved from the saved "TREES" tag
    assertEquals(5, fresh.FileIndex[0]); // resolved from the saved "e.png" filename
    assertTrue(fresh.Mirror[0]);
    assertFalse(fresh.displayAll);
  }

  @Test
  void fromXML_fallsBackToTheKindsFirstFileWhenTheSavedTextureNoLongerExists () {
    // The actual bug this refactor fixes: a project saved before a file
    // was renamed/removed should degrade gracefully on load instead of
    // silently resolving to a different, unrelated texture (or crashing).
    app.TREES_KIND.Filenames = new String[]{"oak.png", "pine.png"};
    app.TREES_KIND.fileCount = 2;

    app.allModel2Ds.XYZS = new float[][]{{0, 0, 0, 1}};
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.TREES_KIND};
    app.allModel2Ds.FileIndex = new int[]{1}; // "oak.png"
    app.allModel2Ds.Mirror = new boolean[]{false};
    app.allModel2Ds.num = 1;
    app.allModel2Ds.displayAll = true;

    processing.data.XML root = new processing.data.XML("root");
    app.allModel2Ds.to_XML(root);

    // Simulate "oak.png" having since been removed from
    // input/images/trees, the way a real stale save would see it.
    processing.data.XML item = root.getChild("model2D").getChildren("item")[0];
    item.setContent(item.getContent().replace("oak.png", "removed_file.png"));

    solarchvision_bim.Model2Ds fresh = app.new Model2Ds();
    fresh.from_XML(root);

    assertSame(app.TREES_KIND, fresh.Kind[0]); // stays a TREES instance - never silently drifts to PEOPLE
    assertEquals(1, fresh.FileIndex[0]); // falls back to the kind's first available file
  }

  @Test
  void toXMLThenFromXML_resolvesTheSameFilenameToTheSameLocalIndexRegardlessOfTheOtherKindsFileCount () {
    // The actual bug report: adding/removing files from ONE folder used
    // to renumber every already-placed object of the OTHER kind. Here,
    // changing PEOPLE_KIND's file count between save and load must have
    // no effect at all on a previously-saved TREES instance.
    app.TREES_KIND.Filenames = new String[]{"oak.png", "pine.png", "birch.png"};
    app.TREES_KIND.fileCount = 3;
    app.PEOPLE_KIND.fileCount = 2; // at save time

    app.allModel2Ds.XYZS = new float[][]{{0, 0, 0, 1}};
    app.allModel2Ds.Kind = new solarchvision_bim.Model2DKind[]{app.TREES_KIND};
    app.allModel2Ds.FileIndex = new int[]{2}; // "pine.png"
    app.allModel2Ds.Mirror = new boolean[]{false};
    app.allModel2Ds.num = 1;
    app.allModel2Ds.displayAll = true;

    processing.data.XML root = new processing.data.XML("root");
    app.allModel2Ds.to_XML(root);

    app.PEOPLE_KIND.fileCount = 40; // simulate many PEOPLE files added before the next load

    solarchvision_bim.Model2Ds fresh = app.new Model2Ds();
    fresh.from_XML(root);

    assertSame(app.TREES_KIND, fresh.Kind[0]);
    assertEquals(2, fresh.FileIndex[0]); // still "pine.png" - unaffected by PEOPLE_KIND's file count
  }
}
