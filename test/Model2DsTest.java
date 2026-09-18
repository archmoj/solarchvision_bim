import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Exercises solarchvision_Model2Ds (Model2Ds.pde), reached through the
// pre-constructed `app.allModel2Ds` field.
//
// NOT covered: draw() (real texture-copying, opacity-mask generation,
// and WIN3D.graphics/htmlOutput/objOutput/radOutput calls - genuine
// rendering + file I/O), load_images() (reads real image files from
// disk via OPESYS.getFiles/loadImage), and castShadows() (real
// SHADOW_graphics polygon output). intersect() IS covered - it needs
// the plain Vertices/Faces fields (built by hand, bypassing draw()) plus
// a PImage it samples the alpha channel of, which is buildable entirely
// in memory via createImage()/loadPixels(), no real files needed.
//
// A fresh `app` per test since these mutate shared scene state.
class Model2DsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= makeEmpty ========================================

  @Test
  void makeEmpty_resetsXYZSAndMAPToTheGivenLength () {
    app.allModel2Ds.makeEmpty(3);
    assertEquals(3, app.allModel2Ds.num);
    assertEquals(3, app.allModel2Ds.XYZS.length);
    assertEquals(4, app.allModel2Ds.XYZS[0].length);
    assertEquals(3, app.allModel2Ds.MAP.length);
  }

  // ================= create ===========================================

  @Test
  void create_appendsPositionAndScaleAndPreservesTheGivenFamilyByMagnitude () {
    // create()'s own internal +/-1 sign roll on MAP means only the
    // magnitude (and therefore the tree/person family) is guaranteed
    // preserved when m is nonzero, not the exact signed value - same
    // caveat already established in Clone3DTest's cloneModel2D tests.
    app.allModel2Ds.create("TREES", 5, 10, 20, 30, 2);

    assertEquals(1, app.allModel2Ds.num);
    assertEquals(10f, app.allModel2Ds.getX(0), 0.0001f);
    assertEquals(20f, app.allModel2Ds.getY(0), 0.0001f);
    assertEquals(30f, app.allModel2Ds.getZ(0), 0.0001f);
    assertEquals(2f, app.allModel2Ds.getS(0), 0.0001f);
    assertEquals(5, Math.abs(app.allModel2Ds.MAP[0]));
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
    app.User3D.create_MeshOrSolid = 1; // 0=Mesh (default, skips this branch), 1=Solid
    app.allSolids.DEF = new float[0][13];

    app.allModel2Ds.create("TREES", 3, 10, 20, 30, 2); // MAP=3 -> a tree (num_files_PEOPLE defaults to 0)

    assertEquals(1, app.allSolids.DEF.length); // the cascade fired
    assertEquals(10f, app.allSolids.DEF[0][0], 0.0001f); // posX
    assertEquals(20f, app.allSolids.DEF[0][1], 0.0001f); // posY
    assertEquals(31f, app.allSolids.DEF[0][2], 0.0001f); // posZ = 0.5*s + z = 0.5*2 + 30
  }

  @Test
  void create_doesNotCreateASolidForAPerson () {
    app.User3D.create_MeshOrSolid = 1;
    app.allSolids.DEF = new float[0][13];
    // num_files_PEOPLE must be set above 0 for a nonzero MAP value to
    // actually classify as a person rather than a tree - isTree() is
    // `abs(n) > num_files_PEOPLE`, so with the default num_files_PEOPLE
    // of 0, even MAP=1 would read as a tree.
    app.allModel2Ds.num_files_PEOPLE = 5;

    app.allModel2Ds.create("PEOPLE", 1, 10, 20, 30, 2); // MAP=1, within the people range

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

  // ================= isTree ============================================

  @Test
  void isTree_isDeterminedByMagnitudeAgainstNumFilesPeople () {
    app.allModel2Ds.num_files_PEOPLE = 5;
    assertFalse(app.allModel2Ds.isTree(3));  // within the people range
    assertFalse(app.allModel2Ds.isTree(-3)); // sign doesn't matter
    assertTrue(app.allModel2Ds.isTree(7));   // past the people range -> a tree
  }

  // ================= intersect =========================================

  @Test
  void intersect_hitsAnOpaquePixelThroughTheCentroid () {
    app.allModel2Ds.Vertices = new float[][]{
      {0, 0, 0, 0, 0}, {2, 0, 0, 1, 0}, {2, 2, 0, 1, 1}, {0, 2, 0, 0, 1}
    };
    app.allModel2Ds.Faces = new int[][]{{0, 1, 2, 3}};
    app.allModel2Ds.num_visualFaces = 1; // so OBJ_ID = f directly, one face per object
    app.allModel2Ds.MAP = new int[]{1};

    app.allModel2Ds.Images = new processing.core.PImage[2]; // index 0 left null, by convention
    processing.core.PImage img = app.createImage(4, 4, processing.core.PConstants.ARGB);
    img.loadPixels();
    for (int i = 0; i < img.pixels.length; i++) img.pixels[i] = app.color(255, 255, 255, 255); // fully opaque
    img.updatePixels();
    app.allModel2Ds.Images[1] = img;

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
    app.allModel2Ds.MAP = new int[]{1};

    app.allModel2Ds.Images = new processing.core.PImage[2];
    // createImage() starts fully transparent (alpha=0) by default - left untouched here.
    app.allModel2Ds.Images[1] = app.createImage(4, 4, processing.core.PConstants.ARGB);

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
    app.allModel2Ds.MAP = new int[]{1};
    app.allModel2Ds.Images = new processing.core.PImage[2];
    app.allModel2Ds.Images[1] = app.createImage(4, 4, processing.core.PConstants.ARGB);

    float[] result = app.allModel2Ds.intersect(new float[]{50, 50, 10}, new float[]{0, 0, -1});

    assertEquals(-1, (int) result[0]);
  }

  // ================= to_XML / from_XML round trip ======================

  @Test
  void toXMLThenFromXML_roundTripsPositionScaleAndMAP () {
    // ImagePath is set to an empty array specifically to keep the
    // ".Textures" block of to_XML/from_XML a genuine no-op (zero
    // iterations) - with it left null (its real default), to_XML would
    // throw on ImagePath.length; with real paths in it, both directions
    // would attempt real file I/O (saveBytes/loadBytes/loadImage), which
    // this suite has no safe way to exercise against real files.
    app.allModel2Ds.XYZS = new float[][]{{10, 20, 30, 2}};
    app.allModel2Ds.MAP = new int[]{-5};
    app.allModel2Ds.num = 1;
    app.allModel2Ds.num_files_PEOPLE = 3;
    app.allModel2Ds.num_files_TREES = 4;
    app.allModel2Ds.displayAll = false;
    app.allModel2Ds.ImagePath = new String[0];

    processing.data.XML root = new processing.data.XML("root");
    app.allModel2Ds.to_XML(root);

    solarchvision_bim.solarchvision_Model2Ds fresh = app.new solarchvision_Model2Ds();
    fresh.ImagePath = new String[0];
    fresh.from_XML(root);

    assertEquals(1, fresh.num);
    assertEquals(10f, fresh.getX(0), 0.0001f);
    assertEquals(20f, fresh.getY(0), 0.0001f);
    assertEquals(30f, fresh.getZ(0), 0.0001f);
    assertEquals(2f, fresh.getS(0), 0.0001f);
    assertEquals(-5, fresh.MAP[0]);
    assertEquals(3, fresh.num_files_PEOPLE);
    assertEquals(4, fresh.num_files_TREES);
    assertFalse(fresh.displayAll);
  }
}
