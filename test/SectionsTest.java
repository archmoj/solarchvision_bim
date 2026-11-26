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
    assertEquals(6, app.allSections.f_data[0].length); // X,Y,Z,rotX,rotY,rotZ
    assertEquals(2, app.allSections.corners.length); // one variable-length row per section
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
    app.allSections.f_data = new float[][]{new float[6]};
    app.allSections.i_data = new int[][]{new int[2]};
    app.allSections.corners = new float[][]{new float[10]}; // 5 corners worth of slots

    app.allSections.setX(0, 1);
    app.allSections.setY(0, 2);
    app.allSections.setZ(0, 3);
    app.allSections.setRotX(0, 4);
    app.allSections.setRotY(0, 7);
    app.allSections.setRotZ(0, 8);
    app.allSections.setCornerX(0, 0, 11);
    app.allSections.setCornerY(0, 0, 12);
    app.allSections.setCornerX(0, 1, 13);
    app.allSections.setCornerY(0, 1, 14);
    app.allSections.setCornerX(0, 2, 15);
    app.allSections.setCornerY(0, 2, 16);
    app.allSections.setCornerX(0, 3, 17);
    app.allSections.setCornerY(0, 3, 18);
    app.allSections.setCornerX(0, 4, 19);
    app.allSections.setCornerY(0, 4, 20);
    app.allSections.set_resX(0, 8);
    app.allSections.set_resY(0, 9);

    assertEquals(1f, app.allSections.getX(0), 0.0001f);
    assertEquals(2f, app.allSections.getY(0), 0.0001f);
    assertEquals(3f, app.allSections.getZ(0), 0.0001f);
    assertEquals(4f, app.allSections.getRotX(0), 0.0001f);
    assertEquals(7f, app.allSections.getRotY(0), 0.0001f);
    assertEquals(8f, app.allSections.getRotZ(0), 0.0001f);
    assertEquals(5, app.allSections.getNumCorners(0));
    assertEquals(11f, app.allSections.getCornerX(0, 0), 0.0001f);
    assertEquals(12f, app.allSections.getCornerY(0, 0), 0.0001f);
    assertEquals(13f, app.allSections.getCornerX(0, 1), 0.0001f);
    assertEquals(14f, app.allSections.getCornerY(0, 1), 0.0001f);
    assertEquals(15f, app.allSections.getCornerX(0, 2), 0.0001f);
    assertEquals(16f, app.allSections.getCornerY(0, 2), 0.0001f);
    assertEquals(17f, app.allSections.getCornerX(0, 3), 0.0001f);
    assertEquals(18f, app.allSections.getCornerY(0, 3), 0.0001f);
    assertEquals(19f, app.allSections.getCornerX(0, 4), 0.0001f);
    assertEquals(20f, app.allSections.getCornerY(0, 4), 0.0001f);
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
    app.allSections.f_data = new float[][]{new float[6]};

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
    app.allSections.f_data = new float[][]{{1, 1, 1, 45, 2, 3}};
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
    app.allSections.f_data = new float[][]{new float[6]};
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
    app.allSections.f_data = new float[][]{{10, 20, 30, 45, 15, 25}};
    app.allSections.i_data = new int[][]{{4, 4}};
    app.allSections.corners = new float[][]{{-1, -1, 1, -1, 1, 1, -1, 1}};
    app.allSections.extraParams = new String[]{"{\"material\":\"glass\"}"};
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
    assertEquals(4, fresh.getNumCorners(0));
    assertEquals(-1f, fresh.getCornerX(0, 0), 0.0001f);
    assertEquals(-1f, fresh.getCornerY(0, 0), 0.0001f);
    assertEquals(1f, fresh.getCornerX(0, 2), 0.0001f);
    assertEquals(1f, fresh.getCornerY(0, 2), 0.0001f);
    assertEquals("{\"material\":\"glass\"}", fresh.getExtraParams(0));
    assertFalse(fresh.displayAll);
  }

  // ================= extraParams ======================================

  @Test
  void makeEmpty_setsExtraParamsToEmptyStringsForEveryEntry () {
    app.allSections.makeEmpty(3);
    assertEquals(3, app.allSections.extraParams.length);
    assertEquals("", app.allSections.getExtraParams(0));
    assertEquals("", app.allSections.getExtraParams(1));
    assertEquals("", app.allSections.getExtraParams(2));
  }

  @Test
  void create_defaultsTheNewSectionsExtraParamsToEmptyString () {
    app.allSections.create(10, 20, 30, 45, 2, 3, 4, 4);
    assertEquals("", app.allSections.getExtraParams(0));
  }

  @Test
  void create_withExplicitExtraParams_setsItDirectlyInsteadOfDefaultingToEmptyString () {
    float[] cornersXY = { -1, -1, 1, -1, 1, 1, -1, 1 };
    app.allSections.create(10, 20, 30, 0, 0, 0, cornersXY, 4, 4, "{\"material\":\"glass\"}");
    assertEquals("{\"material\":\"glass\"}", app.allSections.getExtraParams(0));
  }

  @Test
  void getExtraParams_isDefensiveForNullOrOutOfRangeIndex () {
    assertEquals("", app.allSections.getExtraParams(0));

    app.allSections.makeEmpty(2);
    assertEquals("", app.allSections.getExtraParams(-1));
    assertEquals("", app.allSections.getExtraParams(5));
  }

  @Test
  void setExtraParamsThenGetExtraParams_roundTripsTheRawString () {
    app.allSections.makeEmpty(1);
    app.allSections.setExtraParams(0, "{\"material\":\"steel\"}");
    assertEquals("{\"material\":\"steel\"}", app.allSections.getExtraParams(0));
  }

  @Test
  void ensureExtraParamsLength_padsShortArrayWithEmptyStringsAndPreservesExisting () {
    app.allSections.f_data = new float[][]{new float[6], new float[6]};
    app.allSections.i_data = new int[][]{new int[2], new int[2]};
    app.allSections.corners = new float[][]{new float[6], new float[6]};
    app.allSections.num = 2;
    app.allSections.extraParams = new String[]{"{\"a\":1}"};

    app.allSections.ensureExtraParamsLength();

    assertEquals(2, app.allSections.extraParams.length);
    assertEquals("{\"a\":1}", app.allSections.getExtraParams(0));
    assertEquals("", app.allSections.getExtraParams(1));
  }

  @Test
  void ensureExtraParamsLength_isANoOpWhenAlreadyTheRightLength () {
    app.allSections.makeEmpty(2);
    app.allSections.setExtraParams(0, "{\"a\":1}");
    app.allSections.ensureExtraParamsLength();
    assertEquals("{\"a\":1}", app.allSections.getExtraParams(0));
    assertEquals(2, app.allSections.extraParams.length);
  }

  @Test
  void getExtraParamsObject_parsesValidJSONIntoAJSONObject () {
    app.allSections.makeEmpty(1);
    app.allSections.setExtraParams(0, "{\"material\":\"glass\",\"count\":3}");

    processing.data.JSONObject obj = app.allSections.getExtraParamsObject(0);

    assertEquals("glass", obj.getString("material"));
    assertEquals(3, obj.getInt("count"));
  }

  @Test
  void getExtraParamsObject_collapsesEmptyOrMissingOrBadDataToAnEmptyObject () {
    app.allSections.makeEmpty(3);
    app.allSections.setExtraParams(1, null);
    app.allSections.setExtraParams(2, "not valid json");

    assertEquals(0, app.allSections.getExtraParamsObject(0).keys().size());
    assertEquals(0, app.allSections.getExtraParamsObject(1).keys().size());
    assertEquals(0, app.allSections.getExtraParamsObject(2).keys().size());
  }

  @Test
  void setExtraParamsObject_canonicalizesAnEmptyObjectBackToEmptyString () {
    app.allSections.makeEmpty(1);
    processing.data.JSONObject empty = new processing.data.JSONObject();
    app.allSections.setExtraParamsObject(0, empty);
    assertEquals("", app.allSections.getExtraParams(0));
  }

  @Test
  void setExtraParamsObjectThenGetExtraParamsObject_roundTripsViaJSON () {
    app.allSections.makeEmpty(1);
    processing.data.JSONObject obj = new processing.data.JSONObject();
    obj.setString("material", "wood");
    obj.setInt("count", 7);

    app.allSections.setExtraParamsObject(0, obj);
    processing.data.JSONObject fresh = app.allSections.getExtraParamsObject(0);

    assertEquals("wood", fresh.getString("material"));
    assertEquals(7, fresh.getInt("count"));
  }

  @Test
  void fromXML_defaultsExtraParamsToEmptyString_whenTheAttributeIsMissingEntirely () {
    // Simulates a save file written before extraParams existed at all -
    // no "extraParams" attribute on the <item> element whatsoever, not
    // even an empty one. XML_getString()'s own 3-arg overload
    // (xmlHelpers.pde) is what makes this fall back to "" instead of
    // null.
    processing.data.XML root = new processing.data.XML("root");
    processing.data.XML parent = root.addChild(app.allSections.CLASS_STAMP);
    parent.setInt("ni", 1);
    processing.data.XML child = parent.addChild("item");
    child.setInt("id", 0);
    child.setContent("10,20,30,45,15,25,4,4,3,-1,-1,1,-1,1,1");
    // deliberately no "extraParams" attribute
    parent.setString("displayAll", "true");

    // from_XML() also reads 2 sibling blocks (SolidImpact/SolarImpact) -
    // present but empty here, same as
    // toXMLThenFromXML_roundTripsPositionData's own real to_XML() output
    // with those 2 arrays at length 0.
    processing.data.XML solidImpactParent = root.addChild(app.allSections.CLASS_STAMP + "SolidImpact");
    solidImpactParent.setInt("ni", 0);
    processing.data.XML solarImpactParent = root.addChild(app.allSections.CLASS_STAMP + "SolarImpact");
    solarImpactParent.setInt("ni", 0);
    solarImpactParent.setInt("nj", 0);
    solarImpactParent.setInt("nk", 0);

    solarchvision_bim.Sections fresh = app.new Sections();
    fresh.from_XML(root);

    assertEquals(1, fresh.num);
    assertEquals("", fresh.getExtraParams(0));
  }

  // ================= draw()/intersect() trace the real n-gon, not its
  // bounding rectangle =====================================================
  // A concave L-shaped hexagon (a unit-2 square with its top-right unit
  // quadrant notched out): local corners (0,0) (2,0) (2,1) (1,1) (1,2)
  // (0,2). Its axis-aligned bounding box is the full (0,0)-(2,2) square,
  // but the notch at roughly (1.5,1.5) is NOT part of the shape - the
  // one case a bounding-rectangle approximation could never represent
  // (sections.pde's own corners/getCorners() comments). Built with no
  // rotation/offset (rotX=rotY=rotZ=0, X=Y=Z=0) so local == world,
  // keeping the geometry easy to check directly.

  private void makeLShapedSection () {
    float[] lShapeCorners = { 0, 0, 2, 0, 2, 1, 1, 1, 1, 2, 0, 2 };
    app.allSections.create(0, 0, 0, 0, 0, 0, lShapeCorners, 4, 4);
  }

  @Test
  void draw_buildsOneVertexPerRealCorner_notFourPerSection () {
    makeLShapedSection();

    app.allSections.draw(app.TypeWindow.RAD3D); // no WIN3D graphics/file writers touched at this target

    assertEquals(1, app.allSections.Faces.length);
    assertEquals(6, app.allSections.Faces[0].length, "an L-shaped hexagon has 6 corners, not the old fixed 4");
    assertEquals(6, app.allSections.Vertices.length);

    float[] lShapeCorners = { 0, 0, 2, 0, 2, 1, 1, 1, 1, 2, 0, 2 };
    for (int k = 0; k < 6; k++) {
      int vNo = app.allSections.Faces[0][k];
      assertEquals(lShapeCorners[2 * k], app.allSections.Vertices[vNo][0], 0.0001f);
      assertEquals(lShapeCorners[2 * k + 1], app.allSections.Vertices[vNo][1], 0.0001f);
      assertEquals(0f, app.allSections.Vertices[vNo][2], 0.0001f);
    }
  }

  @Test
  void intersect_missesTheNotchEvenThoughItIsInsideTheBoundingRectangle () {
    makeLShapedSection();
    app.allSections.draw(app.TypeWindow.RAD3D);

    // (1.5, 1.5) sits inside the (0,0)-(2,2) bounding box but squarely
    // inside the notched-out quadrant - a bounding-rectangle pick would
    // have hit here; the real L-shape must not.
    float[] result = app.allSections.intersect(new float[]{1.5f, 1.5f, 10}, new float[]{0, 0, -1});

    assertEquals(-1, (int) result[0], "the notch is cut out of the real shape, so this must miss");
  }

  @Test
  void intersect_hitsASolidPartOfTheLShape () {
    makeLShapedSection();
    app.allSections.draw(app.TypeWindow.RAD3D);

    float[] result = app.allSections.intersect(new float[]{0.5f, 0.5f, 10}, new float[]{0, 0, -1});

    assertEquals(0, (int) result[0]);
    assertEquals(0.5f, result[1], 0.0001f);
    assertEquals(0.5f, result[2], 0.0001f);
    assertEquals(0f, result[3], 0.0001f);
  }

  // ================= getCorners() vs getBoundingRectangleCorners() =======
  // getCorners() now returns the n REAL corners (rendering/export/
  // picking); getBoundingRectangleCorners() always returns exactly 4 -
  // the bounding rectangle solidImpacts.pde's own bake loop still
  // bilinear-interpolates across (sections.pde's own comment on both).

  @Test
  void getCorners_returnsExactlyNRealCorners_forAnLShapedHexagon () {
    float[] lShapeCorners = { 0, 0, 2, 0, 2, 1, 1, 1, 1, 2, 0, 2 };
    float[][] corners = app.allSections.getCorners(0, 0, 0, 0, 0, 0, lShapeCorners, 4, 4);

    assertEquals(6, corners.length);
    for (int k = 0; k < 6; k++) {
      assertEquals(lShapeCorners[2 * k], corners[k][0], 0.0001f);
      assertEquals(lShapeCorners[2 * k + 1], corners[k][1], 0.0001f);
    }
  }

  @Test
  void getBoundingRectangleCorners_alwaysReturnsFourCorners_forAnLShapedHexagon () {
    float[] lShapeCorners = { 0, 0, 2, 0, 2, 1, 1, 1, 1, 2, 0, 2 };
    float[][] corners = app.allSections.getBoundingRectangleCorners(0, 0, 0, 0, 0, 0, lShapeCorners, 4, 4);

    assertEquals(4, corners.length);
    // The bounding box of the L-shape is the full (0,0)-(2,2) square.
    assertArrayEquals(new float[]{0, 0}, new float[]{corners[0][0], corners[0][1]}, 0.0001f);
    assertArrayEquals(new float[]{2, 0}, new float[]{corners[1][0], corners[1][1]}, 0.0001f);
    assertArrayEquals(new float[]{2, 2}, new float[]{corners[2][0], corners[2][1]}, 0.0001f);
    assertArrayEquals(new float[]{0, 2}, new float[]{corners[3][0], corners[3][1]}, 0.0001f);
  }
}
