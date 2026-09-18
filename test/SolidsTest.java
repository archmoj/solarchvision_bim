import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Exercises solarchvision_Solids (Solids.pde), reached through the
// pre-constructed `app.allSolids` field.
//
// NOT covered: draw() and getCorners() (real WIN3D.graphics rendering of
// the superellipsoid wireframe) - same reasoning as Cameras' skipped
// getCorners(). get_Distance() and intersect() ARE covered: both are
// pure math against public fields, and intersect() is a genuinely
// distinct shape from every other intersect() in this codebase - it
// uses a SUM-OF-SUBTENDED-ANGLES point-in-polygon test (AnglesAll > 359)
// rather than isInside_Triangle/Rectangle.
//
// A fresh `app` per test since these mutate shared scene state.
class SolidsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= makeEmpty ========================================

  @Test
  void makeEmpty_resetsDEFToTheGivenLength () {
    app.allSolids.makeEmpty(3);
    assertEquals(3, app.allSolids.DEF.length);
    assertEquals(13, app.allSolids.DEF[0].length);
  }

  // ================= create ===========================================

  @Test
  void create_appendsAllThirteenFieldsAndReturnsTheNewIndex () {
    int newId = app.allSolids.create(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13);

    assertEquals(0, newId);
    assertEquals(1, app.allSolids.DEF.length);
    assertEquals(1f, app.allSolids.get_posX(0), 0.0001f);
    assertEquals(2f, app.allSolids.get_posY(0), 0.0001f);
    assertEquals(3f, app.allSolids.get_posZ(0), 0.0001f);
    assertEquals(4f, app.allSolids.get_powX(0), 0.0001f);
    assertEquals(5f, app.allSolids.get_powY(0), 0.0001f);
    assertEquals(6f, app.allSolids.get_powZ(0), 0.0001f);
    assertEquals(7f, app.allSolids.get_scaleX(0), 0.0001f);
    assertEquals(8f, app.allSolids.get_scaleY(0), 0.0001f);
    assertEquals(9f, app.allSolids.get_scaleZ(0), 0.0001f);
    assertEquals(10f, app.allSolids.get_rotX(0), 0.0001f);
    assertEquals(11f, app.allSolids.get_rotY(0), 0.0001f);
    assertEquals(12f, app.allSolids.get_rotZ(0), 0.0001f);
    assertEquals(13f, app.allSolids.get_value(0), 0.0001f);
  }

  @Test
  void create_extendsTheLastGroupsSolidRangeWhenAGroupExists () {
    app.allGroups.makeEmpty(1);
    app.allGroups.Solids[0] = new int[]{0, -1};

    app.allSolids.create(0, 0, 0, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0);

    assertArrayEquals(new int[]{0, 0}, app.allGroups.Solids[0]);
  }

  // ================= setters (getters already exercised above) ========

  @Test
  void settersAndGetters_roundTripEveryColumn () {
    app.allSolids.DEF = new float[][]{new float[13]};

    app.allSolids.set_posX(0, 1);
    app.allSolids.set_posY(0, 2);
    app.allSolids.set_posZ(0, 3);
    app.allSolids.set_powX(0, 4);
    app.allSolids.set_powY(0, 5);
    app.allSolids.set_powZ(0, 6);
    app.allSolids.set_scaleX(0, 7);
    app.allSolids.set_scaleY(0, 8);
    app.allSolids.set_scaleZ(0, 9);
    app.allSolids.set_rotX(0, 10);
    app.allSolids.set_rotY(0, 11);
    app.allSolids.set_rotZ(0, 12);
    app.allSolids.set_value(0, 13);

    assertEquals(1f, app.allSolids.get_posX(0), 0.0001f);
    assertEquals(13f, app.allSolids.get_value(0), 0.0001f);
  }

  // ================= updatePosition / updatePowers / Scale / RotateXYZ =

  @Test
  void updatePosition_overwritesAllThreePositionColumns () {
    app.allSolids.DEF = new float[][]{{9, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}};
    app.allSolids.updatePosition(0, 1, 2, 3);
    assertEquals(1f, app.allSolids.get_posX(0), 0.0001f);
    assertEquals(2f, app.allSolids.get_posY(0), 0.0001f);
    assertEquals(3f, app.allSolids.get_posZ(0), 0.0001f);
  }

  @Test
  void updatePowers_overwritesAllThreePowerColumns () {
    app.allSolids.DEF = new float[][]{{0, 0, 0, 9, 9, 9, 0, 0, 0, 0, 0, 0, 0}};
    app.allSolids.updatePowers(0, 1, 2, 3);
    assertEquals(1f, app.allSolids.get_powX(0), 0.0001f);
    assertEquals(2f, app.allSolids.get_powY(0), 0.0001f);
    assertEquals(3f, app.allSolids.get_powZ(0), 0.0001f);
  }

  @Test
  void scale_multipliesTheExistingScaleRatherThanReplacingIt () {
    app.allSolids.DEF = new float[][]{{0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0}};
    app.allSolids.Scale(0, 2, 3, 4);
    assertEquals(4f, app.allSolids.get_scaleX(0), 0.0001f);
    assertEquals(6f, app.allSolids.get_scaleY(0), 0.0001f);
    assertEquals(8f, app.allSolids.get_scaleZ(0), 0.0001f);
  }

  @Test
  void rotateXYZ_addsToTheExistingRotationRatherThanReplacingIt () {
    app.allSolids.DEF = new float[][]{{0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 30, 0}};
    app.allSolids.RotateX(0, 5);
    app.allSolids.RotateY(0, 5);
    app.allSolids.RotateZ(0, 5);
    assertEquals(15f, app.allSolids.get_rotX(0), 0.0001f);
    assertEquals(25f, app.allSolids.get_rotY(0), 0.0001f);
    assertEquals(35f, app.allSolids.get_rotZ(0), 0.0001f);
  }

  // ================= get_Distance ======================================

  @Test
  void getDistance_isOneExactlyOnTheSurfaceOfAUnitSphere () {
    // powX=powY=powZ=2, scale=1,1,1, no rotation: a standard Euclidean
    // unit sphere. A point exactly 1 unit from the center should read
    // distance 1.0; a point at the center reads 0; twice the radius
    // reads 2.0 - a clean, verifiable sanity check for this formula.
    app.allSolids.DEF = new float[][]{{0, 0, 0, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0}};

    assertEquals(1f, app.allSolids.get_Distance(0, 1, 0, 0), 0.001f);
    assertEquals(0f, app.allSolids.get_Distance(0, 0, 0, 0), 0.001f);
    assertEquals(2f, app.allSolids.get_Distance(0, 2, 0, 0), 0.001f);
  }

  // ================= intersect =========================================

  @Test
  void intersect_hitsAQuadUsingTheAngleSumPointInPolygonTest () {
    app.allSolids.Vertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allSolids.Faces = new int[][]{{0, 1, 2, 3}};
    app.allSolids.num_visualFaces = 1; // so OBJ_ID = f directly

    float[] result = app.allSolids.intersect(new float[]{1, 1, 10}, new float[]{0, 0, -1});

    assertEquals(0, (int) result[0]);
    assertEquals(1f, result[1], 0.0001f);
    assertEquals(1f, result[2], 0.0001f);
    assertEquals(0f, result[3], 0.0001f);
    assertEquals(10f, result[4], 0.0001f);
  }

  @Test
  void intersect_missesWhenThePlaneIsHitButThePointFallsOutsideTheQuad () {
    // Distinct from the other intersect()s' geometric-miss case: this
    // ray still hits the INFINITE plane (dist2intersect > 0 either way,
    // since the quad is flat), but the angle-sum at that point comes out
    // well under 360deg, correctly rejecting it - verified independently
    // in Python before writing this assertion.
    app.allSolids.Vertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}};
    app.allSolids.Faces = new int[][]{{0, 1, 2, 3}};
    app.allSolids.num_visualFaces = 1;

    float[] result = app.allSolids.intersect(new float[]{50, 50, 10}, new float[]{0, 0, -1});

    assertEquals(-1, (int) result[0]);
  }

  // ================= to_XML / from_XML round trip ======================

  @Test
  void toXMLThenFromXML_roundTripsPositionPowerScaleAndRotationButNotValue () {
    // Found bug (not fixed here, flagged for confirmation): to_XML
    // writes all 13 DEF columns, INCLUDING get_value(i) as the very last
    // field - but from_XML only ever reads parts[0] through parts[11]
    // (posX/Y/Z, powX/Y/Z, scaleX/Y/Z, rotX/Y/Z), with no matching
    // `this.set_value(i, float(parts[12]))` call anywhere. The `value`
    // column is silently written to disk but never restored on load -
    // it always comes back as 0 (makeEmpty's default) regardless of what
    // was saved. This test locks in that actual (likely unintended)
    // behavior rather than the round trip the file's own writer implies.
    app.allSolids.DEF = new float[][]{{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 99}};
    app.allSolids.displayAll = false;
    app.allSolids.palette_CLR = 5;
    app.allSolids.palette_DIR = -1;
    app.allSolids.palette_MLT = 0.75f;

    processing.data.XML root = new processing.data.XML("root");
    app.allSolids.to_XML(root);

    solarchvision_bim.solarchvision_Solids fresh = app.new solarchvision_Solids();
    fresh.from_XML(root);

    assertEquals(1, fresh.DEF.length);
    assertEquals(1f, fresh.get_posX(0), 0.0001f);
    assertEquals(12f, fresh.get_rotZ(0), 0.0001f);
    assertEquals(0f, fresh.get_value(0), 0.0001f); // NOT 99 - the bug, locked in as current behavior

    assertFalse(fresh.displayAll);
    assertEquals(5, fresh.palette_CLR);
    assertEquals(-1, fresh.palette_DIR);
    assertEquals(0.75f, fresh.palette_MLT, 0.0001f);
  }
}
