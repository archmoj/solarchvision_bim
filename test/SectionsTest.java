import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class SectionsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= makeEmpty ========================================

  @Test
  void makeEmpty_resetsEveryArrayToTheGivenLength () {
    app.allSections.makeEmpty(2);
    assertEquals(2, app.allSections.num);
    assertEquals(2, app.allSections.f_data.length);
    assertEquals(6, app.allSections.f_data[0].length);
    assertEquals(2, app.allSections.i_data.length);
    assertEquals(2, app.allSections.SolidImpact.length);
    assertEquals(2, app.allSections.SolarImpact.length);
  }

  // ================= create ===========================================

  @Test
  void create_appendsPositionAndTypeDataAndGrowsTheImpactArrays () {
    app.allSections.create(10, 20, 30, 45, 2, 3, 1, 4, 4);

    assertEquals(1, app.allSections.num);
    assertEquals(10f, app.allSections.getX(0), 0.0001f);
    assertEquals(20f, app.allSections.getY(0), 0.0001f);
    assertEquals(30f, app.allSections.getZ(0), 0.0001f);
    assertEquals(45f, app.allSections.getR(0), 0.0001f);
    assertEquals(2f, app.allSections.getU(0), 0.0001f);
    assertEquals(3f, app.allSections.getV(0), 0.0001f);
    assertEquals(1, app.allSections.get_type(0));
    assertEquals(4, app.allSections.get_res1(0));
    assertEquals(4, app.allSections.get_res2(0));

    assertEquals(1, app.allSections.SolidImpact.length);
    assertEquals(4, app.allSections.SolidImpact[0].width);
    assertEquals(4, app.allSections.SolidImpact[0].height);
    assertEquals(1, app.allSections.SolarImpact.length);
  }

  // ================= getters / setters ================================

  @Test
  void gettersAndSetters_roundTripEveryColumn () {
    app.allSections.f_data = new float[][]{new float[6]};
    app.allSections.i_data = new int[][]{new int[3]};

    app.allSections.setX(0, 1);
    app.allSections.setY(0, 2);
    app.allSections.setZ(0, 3);
    app.allSections.setR(0, 4);
    app.allSections.setU(0, 5);
    app.allSections.setV(0, 6);
    app.allSections.set_type(0, 1);
    app.allSections.set_res1(0, 8);
    app.allSections.set_res2(0, 9);

    assertEquals(1f, app.allSections.getX(0), 0.0001f);
    assertEquals(6f, app.allSections.getV(0), 0.0001f);
    assertEquals(1, app.allSections.get_type(0));
    assertEquals(8, app.allSections.get_res1(0));
    assertEquals(9, app.allSections.get_res2(0));
  }

  // ================= move =============================================

  @Test
  void move_addsTheOffsetToPositionOnly () {
    app.allSections.f_data = new float[][]{{1, 1, 1, 45, 2, 3}};
    app.allSections.move(0, 1, 2, 3);
    assertEquals(2f, app.allSections.getX(0), 0.0001f);
    assertEquals(3f, app.allSections.getY(0), 0.0001f);
    assertEquals(4f, app.allSections.getZ(0), 0.0001f);
    assertEquals(45f, app.allSections.getR(0), 0.0001f); // untouched
  }

  // ================= shouldDraw =======================================

  @Test
  void shouldDraw_isFalseWhenDisplayAllIsOffRegardlessOfWindow () {
    app.allSections.displayAll = false;
    assertFalse(app.allSections.shouldDraw(app.TypeWindow.WIN3D));
  }

  @Test
  void shouldDraw_isFalseForStudyAndWorldWindowsEvenWhenVisible () {
    app.allSections.displayAll = true;
    assertFalse(app.allSections.shouldDraw(app.TypeWindow.STUDY));
    assertFalse(app.allSections.shouldDraw(app.TypeWindow.WORLD));
  }

  @Test
  void shouldDraw_isTrueForAnOrdinaryVisibleWindow () {
    app.allSections.displayAll = true;
    assertTrue(app.allSections.shouldDraw(app.TypeWindow.WIN3D));
  }

  // ================= rotateSectionCorner ================================

  @Test
  void rotateSectionCorner_type1RotatesInThePlaneAndKeepsCUnchanged () {
    float[] result = app.allSections.rotateSectionCorner(1, 1, 0, 5, 90);
    assertArrayEquals(new float[]{0, 1, 5}, result, 0.001f);
  }

  @Test
  void rotateSectionCorner_type3At0DegreesMatchesType2At90Degrees () {
    // Type 3 measures rotation from 90deg instead of 0 - so type 3 at
    // R=0 should produce exactly what type 2 gives at R=90.
    float[] type2 = app.allSections.rotateSectionCorner(2, 1, 7, 5, 90);
    float[] type3 = app.allSections.rotateSectionCorner(3, 1, 7, 5, 0);
    assertArrayEquals(type2, type3, 0.001f);
  }

  @Test
  void rotateSectionCorner_isTheOriginForAnyOtherType () {
    assertArrayEquals(new float[]{0, 0, 0}, app.allSections.rotateSectionCorner(9, 1, 2, 3, 90), 0.0001f);
  }

  // ================= intersect / intersectFace ==========================

  @Test
  void intersect_hitsAQuadThroughItsCentroid () {
    app.allSections.Vertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allSections.Faces = new int[][]{{0, 1, 2, 3}};

    float[] result = app.allSections.intersect(new float[]{1, 1, 10}, new float[]{0, 0, -1});

    assertEquals(0, (int) result[0]);
    assertEquals(1f, result[1], 0.0001f);
    assertEquals(1f, result[2], 0.0001f);
    assertEquals(0f, result[3], 0.0001f);
    assertEquals(10f, result[4], 0.0001f);
  }

  @Test
  void intersect_returnsMinusOneWhenNothingIsHit () {
    app.allSections.Vertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allSections.Faces = new int[][]{{0, 1, 2, 3}};

    float[] result = app.allSections.intersect(new float[]{50, 50, 10}, new float[]{0, 0, -1});

    assertEquals(-1, (int) result[0]);
  }

  // ================= resize_solarImpact_array ============================

  @Test
  void resizeSolarImpactArray_rebuildsToMatchTheCurrentSectionCount () {
    app.allSections.f_data = new float[][]{new float[6]};
    app.allSections.i_data = new int[][]{new int[3]};
    app.allSections.num = 1;

    app.allSections.resize_solarImpact_array();

    assertEquals(1, app.allSections.SolarImpact.length);
  }

  // ================= to_XML / from_XML round trip ======================

  @Test
  void toXMLThenFromXML_roundTripsPositionAndTypeData () {
    // SolidImpact/SolarImpact are deliberately left at length 0 here,
    // decoupled from f_data/i_data/num (which normally stay in sync via
    // create()/makeEmpty()) - to_XML's 3 blocks each derive their own
    // "ni" from a different source (this.num vs this.SolidImpact.length
    // vs this.SolarImpact.length), so this keeps those 2 blocks' loops
    // at zero iterations and avoids the real PImage.save()/loadImage()
    // calls they'd otherwise make - there's no way to exercise those
    // safely against a hand-built scene with no real files on disk.
    app.allSections.f_data = new float[][]{{10, 20, 30, 45, 2, 3}};
    app.allSections.i_data = new int[][]{{1, 4, 4}};
    app.allSections.num = 1;
    app.allSections.SolidImpact = new processing.core.PImage[0];
    app.allSections.SolarImpact = new processing.core.PImage[0][0][0];
    app.allSections.displayAll = false;

    processing.data.XML root = new processing.data.XML("root");
    app.allSections.to_XML(root);

    solarchvision_bim.solarchvision_Sections fresh = app.new solarchvision_Sections();
    fresh.from_XML(root);

    assertEquals(1, fresh.num);
    assertEquals(10f, fresh.getX(0), 0.0001f);
    assertEquals(45f, fresh.getR(0), 0.0001f);
    assertEquals(1, fresh.get_type(0));
    assertEquals(4, fresh.get_res1(0));
    assertFalse(fresh.displayAll);
  }
}
