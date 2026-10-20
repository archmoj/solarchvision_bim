import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers studyImpactHover.pde's pure logic: deepClone4D() (the
// independence guarantee the whole multi-row fix depends on),
// win3DOverlay_rawValuesAt_fromSnapshot() (the snapshot-based mirror of
// SolarImpacts.pde's own live-data lookup), studyUrbanHover_hitTest()
// (including the exact multi-row scenario that motivated this feature -
// viewLayout==2's three stacked percentile rows), and the (q, raw)
// overload of solarImpactHover_lines(). draw_STUDY_hover() and
// drawStudyUrbanHoverBox() themselves touch real graphics (get()/image()/
// text()/fill()) and aren't independently testable here, consistent with
// everything else this session that draws to a live PGraphics context.
class StudyImpactHoverTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= deepClone4D ============================================

  @Test
  void deepClone4D_copiesEveryValueCorrectly () {
    float[][][][] src = new float[2][4][3][3];
    src[0][0][1][1] = 5f;
    src[1][3][2][0] = -7.5f;

    float[][][][] clone = app.deepClone4D(src);

    assertEquals(5f, clone[0][0][1][1], 0.0001f);
    assertEquals(-7.5f, clone[1][3][2][0], 0.0001f);
  }

  @Test
  void deepClone4D_isActuallyIndependent_notASharedReference () {
    // This is the exact property the whole multi-row fix depends on - if
    // this were a shallow copy (or no copy at all), a later row's own
    // calculate_Impact_CurrentPreBaked() call would silently corrupt an
    // earlier row's already-captured snapshot, right back to the
    // original bug.
    float[][][][] src = new float[2][4][3][3];
    src[0][0][0][0] = 1f;

    float[][][][] clone = app.deepClone4D(src);
    clone[0][0][0][0] = 999f;
    src[0][0][0][0] = -999f;

    assertEquals(999f, clone[0][0][0][0], 0.0001f, "the clone must not change when the source does");
    assertEquals(-999f, src[0][0][0][0], 0.0001f, "the source must not change when the clone does");
  }

  // ================= win3DOverlay_rawValuesAt_fromSnapshot =================

  private float[][][][] buildSnapshot () {
    float[][][][] snap = new float[2][4][5][5];
    for (float[][][] q : snap) for (float[][] c : q) for (float[] row : c) java.util.Arrays.fill(row, app.FLOAT_undefined);
    return snap;
  }

  @Test
  void fromSnapshot_appliesTheMultiplierToAllFourChannels () {
    float[][][][] snap = buildSnapshot();
    snap[app.Impact_ACTIVE][0][2][3] = 2f;  // A
    snap[app.Impact_ACTIVE][1][2][3] = 1f;  // R
    snap[app.Impact_ACTIVE][2][2][3] = 3f;  // G
    snap[app.Impact_ACTIVE][3][2][3] = 4f;  // B

    float[] raw = app.win3DOverlay_rawValuesAt_fromSnapshot(app.Impact_ACTIVE, snap, 2.5f, 2, 3);

    assertNotNull(raw);
    assertEquals(5f, raw[0], 0.0001f);  // 2*2.5
    assertEquals(2.5f, raw[1], 0.0001f); // 1*2.5
    assertEquals(7.5f, raw[2], 0.0001f); // 3*2.5
    assertEquals(10f, raw[3], 0.0001f);  // 4*2.5
  }

  @Test
  void fromSnapshot_isNull_forAnUndefinedPixel () {
    float[][][][] snap = buildSnapshot(); // every pixel still FLOAT_undefined
    assertNull(app.win3DOverlay_rawValuesAt_fromSnapshot(app.Impact_ACTIVE, snap, 1f, 0, 0));
  }

  @Test
  void fromSnapshot_isNull_whenTheFinalAIsExactlyZero () {
    float[][][][] snap = buildSnapshot();
    snap[app.Impact_ACTIVE][0][0][0] = 0f; // defined, but multiplies to exactly 0
    assertNull(app.win3DOverlay_rawValuesAt_fromSnapshot(app.Impact_ACTIVE, snap, 5f, 0, 0));
  }

  @Test
  void fromSnapshot_readsTheRequestedQIndexOnly () {
    float[][][][] snap = buildSnapshot();
    snap[app.Impact_PASSIVE][0][1][1] = 1f;
    snap[app.Impact_PASSIVE][3][1][1] = 9f; // B

    // Impact_ACTIVE's own slice is still all FLOAT_undefined at this pixel
    assertNull(app.win3DOverlay_rawValuesAt_fromSnapshot(app.Impact_ACTIVE, snap, 1f, 1, 1));

    float[] raw = app.win3DOverlay_rawValuesAt_fromSnapshot(app.Impact_PASSIVE, snap, 1f, 1, 1);
    assertNotNull(raw);
    assertEquals(9f, raw[3], 0.0001f);
  }

  // ================= solarImpactHover_lines(q, raw) overload ===============

  @Test
  void linesOverload_isNull_whenRawIsNull () {
    assertNull(app.solarImpactHover_lines(app.Impact_ACTIVE, (float[]) null));
  }

  @Test
  void linesOverload_formatsActiveTheSameWayAsTheLiveLookupDoes () {
    app.showARGB_inHover = false;
    float[] raw = { 1f, 0f, 15f, 0f }; // A, R, G(=received), B
    String[] lines = app.solarImpactHover_lines(app.Impact_ACTIVE, raw);

    assertNotNull(lines);
    assertEquals(1, lines.length);
    assertTrue(lines[0].contains("15.00"));
  }

  @Test
  void linesOverload_formatsPassiveTheSameWayAsTheLiveLookupDoes () {
    app.showARGB_inHover = false;
    float[] raw = { 1f, 4f, 0f, 10f }; // A, R(=N), G, B(=P)
    String[] lines = app.solarImpactHover_lines(app.Impact_PASSIVE, raw);

    assertNotNull(lines);
    assertEquals(3, lines.length);
    assertTrue(lines[0].contains("10.00")); // P
    assertTrue(lines[1].contains("4.00"));  // N
  }

  // ================= studyUrbanHover_hitTest ================================

  private solarchvision_bim.UrbanThumbnailHoverInfo makeEntry (float centerX, float centerY, int impactTypeIndex, float a) {
    solarchvision_bim.UrbanThumbnailHoverInfo info = app.new UrbanThumbnailHoverInfo();
    info.centerX = centerX;
    info.centerY = centerY;
    info.impactTypeIndex = impactTypeIndex;
    info.mul = 1f;
    float[][][][] snap = new float[2][4][10][10];
    for (int x = 0; x < 10; x++) {
      for (int y = 0; y < 10; y++) {
        snap[impactTypeIndex][0][x][y] = a;
        snap[impactTypeIndex][2][x][y] = a; // put the same value in G too, so Active's "Received" line is checkable
      }
    }
    info.daySnapshot = snap;
    return info;
  }

  @Test
  void hitTest_findsTheEntryUnderTheMouse () {
    app.STUDY.cX = 100;
    app.STUDY.cY = 100;
    app.STUDY.ImageScale = 1;
    app.STUDY.urbanThumbnail_sizeX = 80;
    app.STUDY.urbanThumbnail_sizeY = 80;
    app.STUDY.urbanThumbnailHoverInfo = new java.util.ArrayList<>();
    app.STUDY.urbanThumbnailHoverInfo.add(makeEntry(0, 0, app.Impact_ACTIVE, 7f));

    solarchvision_bim.UrbanHoverHit hit = app.studyUrbanHover_hitTest(100, 100);

    assertNotNull(hit);
    float[] raw = app.win3DOverlay_rawValuesAt_fromSnapshot(hit.info.impactTypeIndex, hit.info.daySnapshot, hit.info.mul, hit.ix, hit.iy);
    assertNotNull(raw);
    assertEquals(7f, raw[0], 0.0001f);
  }

  @Test
  void hitTest_isNull_whenTheMouseIsOutsideEveryThumbnail () {
    app.STUDY.cX = 100;
    app.STUDY.cY = 100;
    app.STUDY.ImageScale = 1;
    app.STUDY.urbanThumbnail_sizeX = 80;
    app.STUDY.urbanThumbnail_sizeY = 80;
    app.STUDY.urbanThumbnailHoverInfo = new java.util.ArrayList<>();
    app.STUDY.urbanThumbnailHoverInfo.add(makeEntry(0, 0, app.Impact_ACTIVE, 7f));

    assertNull(app.studyUrbanHover_hitTest(0, 0));
  }

  @Test
  void hitTest_isNull_whenNothingHasBeenRecordedYet () {
    app.STUDY.urbanThumbnailHoverInfo = null;
    assertDoesNotThrow(() -> assertNull(app.studyUrbanHover_hitTest(100, 100)));
  }

  @Test
  void hitTest_accountsForImageScale () {
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 2; // e.g. mid high-resolution export
    app.STUDY.urbanThumbnail_sizeX = 80;
    app.STUDY.urbanThumbnail_sizeY = 80;
    app.STUDY.urbanThumbnailHoverInfo = new java.util.ArrayList<>();
    app.STUDY.urbanThumbnailHoverInfo.add(makeEntry(100, 100, app.Impact_ACTIVE, 3f));

    // Screen coordinate 50,50 -> graphics-space (50*2, 50*2) = (100,100), the entry's own center.
    solarchvision_bim.UrbanHoverHit hit = app.studyUrbanHover_hitTest(50, 50);
    assertNotNull(hit, "mouse at screen (50,50) with ImageScale=2 should map to graphics-space (100,100), hitting the entry centered there");
  }

  @Test
  void hitTest_threeStackedPercentileRows_eachShowsItsOwnData_noCrossContamination () {
    // The exact scenario the multi-row fix was for: viewLayout==2's
    // setupPlot_0() calls plotImpact_urban() three times in one render
    // pass (25th/50th/75th percentile), each a different screen row,
    // each its own calculate_Impact_CurrentPreBaked() result. Before the
    // fix, only the last row's positions (and, separately, only the last
    // row's underlying data) survived.
    app.STUDY.cX = 100;
    app.STUDY.cY = 100;
    app.STUDY.ImageScale = 1;
    app.STUDY.urbanThumbnail_sizeX = 80;
    app.STUDY.urbanThumbnail_sizeY = 80;
    app.STUDY.urbanThumbnailHoverInfo = new java.util.ArrayList<>();
    app.STUDY.urbanThumbnailHoverInfo.add(makeEntry(0, -150, app.Impact_ACTIVE, 10f)); // 25th percentile row
    app.STUDY.urbanThumbnailHoverInfo.add(makeEntry(0, 150, app.Impact_ACTIVE, 20f));  // 50th percentile row
    app.STUDY.urbanThumbnailHoverInfo.add(makeEntry(0, 450, app.Impact_ACTIVE, 30f));  // 75th percentile row

    solarchvision_bim.UrbanHoverHit hit25 = app.studyUrbanHover_hitTest(100, 100 - 150);
    solarchvision_bim.UrbanHoverHit hit50 = app.studyUrbanHover_hitTest(100, 100 + 150);
    solarchvision_bim.UrbanHoverHit hit75 = app.studyUrbanHover_hitTest(100, 100 + 450);

    assertNotNull(hit25);
    assertNotNull(hit50);
    assertNotNull(hit75);

    float a25 = app.win3DOverlay_rawValuesAt_fromSnapshot(hit25.info.impactTypeIndex, hit25.info.daySnapshot, hit25.info.mul, hit25.ix, hit25.iy)[0];
    float a50 = app.win3DOverlay_rawValuesAt_fromSnapshot(hit50.info.impactTypeIndex, hit50.info.daySnapshot, hit50.info.mul, hit50.ix, hit50.iy)[0];
    float a75 = app.win3DOverlay_rawValuesAt_fromSnapshot(hit75.info.impactTypeIndex, hit75.info.daySnapshot, hit75.info.mul, hit75.ix, hit75.iy)[0];

    assertEquals(10f, a25, 0.0001f, "the 25th-percentile row must show its own data");
    assertEquals(20f, a50, 0.0001f, "the 50th-percentile row must show its own data");
    assertEquals(30f, a75, 0.0001f, "the 75th-percentile row must show its own data");
  }
}
