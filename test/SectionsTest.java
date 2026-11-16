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
    assertEquals(14, app.allSections.f_data[0].length); // X,Y,Z,rotX,rotY,rotZ,p1x,p1y,p2x,p2y,p3x,p3y,p4x,p4y
    assertEquals(2, app.allSections.i_data.length);
    assertEquals(2, app.allSections.SolidImpact.length);
    assertEquals(2, app.allSections.SolarImpact.length);
  }

  // ================= create ===========================================

  @Test
  void create_appendsPositionDataAndGrowsTheImpactArrays () {
    app.allSections.create(10, 20, 30, 45, 2, 3, 4, 4);

    assertEquals(1, app.allSections.num);
    assertEquals(10f, app.allSections.getX(0), 0.0001f);
    assertEquals(20f, app.allSections.getY(0), 0.0001f);
    assertEquals(30f, app.allSections.getZ(0), 0.0001f);
    assertEquals(45f, app.allSections.getRotX(0), 0.0001f);
    assertEquals(2f, app.allSections.getSizeX(0), 0.0001f);
    assertEquals(3f, app.allSections.getSizeY(0), 0.0001f);
    assertEquals(4, app.allSections.get_resX(0));
    assertEquals(4, app.allSections.get_resY(0));

    assertEquals(1, app.allSections.SolidImpact.length);
    assertEquals(4, app.allSections.SolidImpact[0].width);
    assertEquals(4, app.allSections.SolidImpact[0].height);
    assertEquals(1, app.allSections.SolarImpact.length);
  }

  // ================= getters / setters ================================

  @Test
  void gettersAndSetters_roundTripEveryColumn () {
    app.allSections.f_data = new float[][]{new float[14]};
    app.allSections.i_data = new int[][]{new int[2]};

    app.allSections.setX(0, 1);
    app.allSections.setY(0, 2);
    app.allSections.setZ(0, 3);
    app.allSections.setRotX(0, 4);
    app.allSections.setRotY(0, 7);
    app.allSections.setRotZ(0, 8);
    app.allSections.setP1X(0, 11);
    app.allSections.setP1Y(0, 12);
    app.allSections.setP2X(0, 13);
    app.allSections.setP2Y(0, 14);
    app.allSections.setP3X(0, 15);
    app.allSections.setP3Y(0, 16);
    app.allSections.setP4X(0, 17);
    app.allSections.setP4Y(0, 18);
    app.allSections.set_resX(0, 8);
    app.allSections.set_resY(0, 9);

    assertEquals(1f, app.allSections.getX(0), 0.0001f);
    assertEquals(2f, app.allSections.getY(0), 0.0001f);
    assertEquals(3f, app.allSections.getZ(0), 0.0001f);
    assertEquals(4f, app.allSections.getRotX(0), 0.0001f);
    assertEquals(7f, app.allSections.getRotY(0), 0.0001f);
    assertEquals(8f, app.allSections.getRotZ(0), 0.0001f);
    assertEquals(11f, app.allSections.getP1X(0), 0.0001f);
    assertEquals(12f, app.allSections.getP1Y(0), 0.0001f);
    assertEquals(13f, app.allSections.getP2X(0), 0.0001f);
    assertEquals(14f, app.allSections.getP2Y(0), 0.0001f);
    assertEquals(15f, app.allSections.getP3X(0), 0.0001f);
    assertEquals(16f, app.allSections.getP3Y(0), 0.0001f);
    assertEquals(17f, app.allSections.getP4X(0), 0.0001f);
    assertEquals(18f, app.allSections.getP4Y(0), 0.0001f);
    assertEquals(8, app.allSections.get_resX(0));
    assertEquals(9, app.allSections.get_resY(0));
  }

  // ================= RotateX / RotateY / RotateZ ========================
  // Mirrors Solids' own RotateX/RotateY/RotateZ (solids.pde) - plain
  // accumulation. RotateX shares R with types 1/2/3 (see f_data's own
  // comment, sections.pde); RotateY/RotateZ are new columns, meaningful
  // only for a type-0 (arbitrary) section.

  @Test
  void rotateXYZ_eachAccumulateIntoTheirOwnColumnOnly () {
    app.allSections.f_data = new float[][]{new float[14]};

    app.allSections.RotateX(0, 10);
    app.allSections.RotateY(0, 20);
    app.allSections.RotateZ(0, 30);
    app.allSections.RotateX(0, 5);

    assertEquals(15f, app.allSections.getRotX(0), 0.0001f);    // RotateX == RotX
    assertEquals(20f, app.allSections.getRotY(0), 0.0001f);
    assertEquals(30f, app.allSections.getRotZ(0), 0.0001f);
  }

  // ================= move =============================================

  @Test
  void move_addsTheOffsetToPositionOnly () {
    app.allSections.f_data = new float[][]{{1, 1, 1, 45, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0}};
    app.allSections.move(0, 1, 2, 3);
    assertEquals(2f, app.allSections.getX(0), 0.0001f);
    assertEquals(3f, app.allSections.getY(0), 0.0001f);
    assertEquals(4f, app.allSections.getZ(0), 0.0001f);
    assertEquals(45f, app.allSections.getRotX(0), 0.0001f); // untouched
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
    app.allSections.f_data = new float[][]{new float[14]};
    app.allSections.i_data = new int[][]{new int[2]};
    app.allSections.num = 1;

    app.allSections.resize_solarImpact_array();

    assertEquals(1, app.allSections.SolarImpact.length);
  }

  // ================= to_XML / from_XML round trip ======================

  @Test
  void toXMLThenFromXML_roundTripsPositionData () {
    // SolidImpact/SolarImpact are deliberately left at length 0 here,
    // decoupled from f_data/i_data/num (which normally stay in sync via
    // create()/makeEmpty()) - to_XML's 3 blocks each derive their own
    // "ni" from a different source (this.num vs this.SolidImpact.length
    // vs this.SolarImpact.length), so this keeps those 2 blocks' loops
    // at zero iterations and avoids the real PImage.save()/loadImage()
    // calls they'd otherwise make - there's no way to exercise those
    // safely against a hand-built scene with no real files on disk.
    app.allSections.f_data = new float[][]{{10, 20, 30, 45, 15, 25, -1, -1, 1, -1, 1, 1, -1, 1}};
    app.allSections.i_data = new int[][]{{4, 4}};
    app.allSections.num = 1;
    app.allSections.SolidImpact = new processing.core.PImage[0];
    app.allSections.SolarImpact = new processing.core.PImage[0][0][0];
    app.allSections.displayAll = false;

    processing.data.XML root = new processing.data.XML("root");
    app.allSections.to_XML(root);

    solarchvision_bim.Sections fresh = app.new Sections();
    fresh.from_XML(root);

    assertEquals(1, fresh.num);
    assertEquals(10f, fresh.getX(0), 0.0001f);
    assertEquals(45f, fresh.getRotX(0), 0.0001f);
    assertEquals(15f, fresh.getRotY(0), 0.0001f);
    assertEquals(25f, fresh.getRotZ(0), 0.0001f);
    assertEquals(4, fresh.get_resX(0));
    assertFalse(fresh.displayAll);
  }
}
