import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class SolarImpactOverlayHoverTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= solarImpactOverlay_fitRect ============================
  // Where the overlay image actually lands on screen (and which part of it)
  // under the three aspect-fit cases draw_WIN3D_layers.pde's own drawing
  // code uses.

  @Test
  void fitRect_coversTheFullViewport_whenAspectRatiosMatch () {
    app.WIN3D.cX = 10; app.WIN3D.cY = 20; app.WIN3D.dX = 200; app.WIN3D.dY = 200;
    processing.core.PImage img = new processing.core.PImage(100, 100, processing.core.PConstants.ARGB);

    float[] fit = app.solarImpactOverlay_fitRect(img);

    assertEquals(10f, fit[0], 0.0001f);
    assertEquals(20f, fit[1], 0.0001f);
    assertEquals(200f, fit[2], 0.0001f);
    assertEquals(200f, fit[3], 0.0001f);
    assertEquals(0f, fit[4], 0.0001f);
    assertEquals(0f, fit[5], 0.0001f);
    assertEquals(100f, fit[6], 0.0001f);
    assertEquals(100f, fit[7], 0.0001f);
  }

  @Test
  void fitRect_pillarboxesACenteredNarrowerImage_whenTheViewportIsWider () {
    app.WIN3D.cX = 0; app.WIN3D.cY = 0; app.WIN3D.dX = 400; app.WIN3D.dY = 200; // aspect2 = 2
    processing.core.PImage img = new processing.core.PImage(100, 100, processing.core.PConstants.ARGB); // aspect1 = 1

    float[] fit = app.solarImpactOverlay_fitRect(img);

    assertEquals(100f, fit[0], 0.0001f); // (400-200)/2
    assertEquals(0f, fit[1], 0.0001f);
    assertEquals(200f, fit[2], 0.0001f); // newWidth
    assertEquals(200f, fit[3], 0.0001f);
    assertEquals(100f, fit[6], 0.0001f); // no crop
    assertEquals(100f, fit[7], 0.0001f);
  }

  @Test
  void fitRect_cropsTheSourceWidthCenteredToTheFullHeight_whenTheViewportIsNarrower () {
    app.WIN3D.cX = 0; app.WIN3D.cY = 0; app.WIN3D.dX = 200; app.WIN3D.dY = 200; // aspect2 = 1
    processing.core.PImage img = new processing.core.PImage(200, 100, processing.core.PConstants.ARGB); // aspect1 = 2

    float[] fit = app.solarImpactOverlay_fitRect(img);

    assertEquals(200f, fit[2], 0.0001f); // fills the full viewport
    assertEquals(200f, fit[3], 0.0001f);
    assertEquals(50f, fit[4], 0.0001f);  // srcX: (200-100)/2
    assertEquals(100f, fit[6], 0.0001f); // croppedWidth: h*aspect2 = 100*1
    assertEquals(100f, fit[7], 0.0001f); // full height, uncropped
  }

  // ================= solarImpactHover_boxPosition ===========================
  // Which side of the cursor the box sits on, and that it always stays
  // inside the given dest rect.

  @Test
  void boxPosition_goesRightAndBelow_whenTheCursorIsInTheTopLeftQuadrant () {
    float[] p = app.solarImpactHover_boxPosition(50, 40, 0, 0, 400, 300, 70, 54);

    assertEquals(50 + app.solarImpactHover_margin, p[0], 0.0001f);
    assertEquals(40 + app.solarImpactHover_margin, p[1], 0.0001f);
  }

  @Test
  void boxPosition_goesLeftAndBelow_whenTheCursorIsInTheTopRightQuadrant () {
    float[] p = app.solarImpactHover_boxPosition(350, 40, 0, 0, 400, 300, 70, 54);

    assertEquals(350 - app.solarImpactHover_margin - 70, p[0], 0.0001f);
    assertEquals(40 + app.solarImpactHover_margin, p[1], 0.0001f);
  }

  @Test
  void boxPosition_goesRightAndAbove_whenTheCursorIsInTheBottomLeftQuadrant () {
    float[] p = app.solarImpactHover_boxPosition(50, 260, 0, 0, 400, 300, 70, 54);

    assertEquals(50 + app.solarImpactHover_margin, p[0], 0.0001f);
    assertEquals(260 - app.solarImpactHover_margin - 54, p[1], 0.0001f);
  }

  @Test
  void boxPosition_goesLeftAndAbove_whenTheCursorIsInTheBottomRightQuadrant () {
    float[] p = app.solarImpactHover_boxPosition(350, 260, 0, 0, 400, 300, 70, 54);

    assertEquals(350 - app.solarImpactHover_margin - 70, p[0], 0.0001f);
    assertEquals(260 - app.solarImpactHover_margin - 54, p[1], 0.0001f);
  }

  @Test
  void boxPosition_treatsExactlyHalf_asTheLeftTopSide () {
    float[] p = app.solarImpactHover_boxPosition(200, 150, 0, 0, 400, 300, 70, 54);

    assertEquals(200 + app.solarImpactHover_margin, p[0], 0.0001f);
    assertEquals(150 + app.solarImpactHover_margin, p[1], 0.0001f);
  }

  @Test
  void boxPosition_alwaysStaysInsideTheDestRect_includingWhenTheRectIsOffsetFromTheOrigin () {
    float destX = 100, destY = 100, destW = 400, destH = 300;
    float boxW = 70, boxH = 54;

    for (float[] mouse : new float[][] { {120, 120}, {480, 120}, {120, 380}, {480, 380}, {250, 250} }) {
      float[] p = app.solarImpactHover_boxPosition(mouse[0], mouse[1], destX, destY, destW, destH, boxW, boxH);
      assertTrue(p[0] >= destX && p[0] + boxW <= destX + destW, "boxX out of bounds for mouse " + java.util.Arrays.toString(mouse) + ": " + p[0]);
      assertTrue(p[1] >= destY && p[1] + boxH <= destY + destH, "boxY out of bounds for mouse " + java.util.Arrays.toString(mouse) + ": " + p[1]);
    }
  }

  // ================= solarImpactHover_lines =================================
  // What actually gets shown - meaningful quantities by default, raw A/R/G/B
  // behind the showARGB_inHover toggle.

  private void putDay (int dayIndex, int q, int x, int y, float a, float r, float g, float b, float valuesMUL) {
    if (app.allSolarImpacts.Matrix_ARGB == null) {
      app.allSolarImpacts.Matrix_ARGB = new float[dayIndex + 1][][][][];
      app.allSolarImpacts.dayValuesMUL = new float[dayIndex + 1];
    }
    if (app.allSolarImpacts.Matrix_ARGB[dayIndex] == null) {
      float[][][][] day = new float[2][4][10][10];
      for (float[][][] qq : day) for (float[][] c : qq) for (float[] row : c) java.util.Arrays.fill(row, app.FLOAT_undefined);
      app.allSolarImpacts.Matrix_ARGB[dayIndex] = day;
    }
    app.allSolarImpacts.Matrix_ARGB[dayIndex][q][0][x][y] = a;
    app.allSolarImpacts.Matrix_ARGB[dayIndex][q][1][x][y] = r;
    app.allSolarImpacts.Matrix_ARGB[dayIndex][q][2][x][y] = g;
    app.allSolarImpacts.Matrix_ARGB[dayIndex][q][3][x][y] = b;
    app.allSolarImpacts.dayValuesMUL[dayIndex] = valuesMUL;
  }

  @Test
  void hoverLines_showsOneLine_withTheReceivedRadiation_forActive () {
    app.showARGB_inHover = false;
    putDay(1, app.Impact_ACTIVE, 1, 1, /*A*/ 1f, /*R*/ 0f, /*G*/ 10f, /*B*/ 0f, /*valuesMUL*/ 1.5f);

    String[] lines = app.solarImpactHover_lines(app.Impact_ACTIVE, 1, 1, 1);

    assertNotNull(lines);
    assertEquals(1, lines.length);
    assertTrue(lines[0].contains("15.00"), "expected G*valuesMUL = 10*1.5 = 15.00 in: " + lines[0]);
  }

  @Test
  void hoverLines_showsThreeLines_withPositiveNegativeAndScore_forPassive () {
    app.showARGB_inHover = false;
    // P (benefit) is kept in B, N (harm) is kept in R - see this method's
    // own comment and the Matrix_ARGB build site for why.
    putDay(1, app.Impact_PASSIVE, 2, 2, /*A*/ 1f, /*R*/ 4f, /*G*/ 0f, /*B*/ 10f, /*valuesMUL*/ 1.5f);

    String[] lines = app.solarImpactHover_lines(app.Impact_PASSIVE, 1, 2, 2);

    assertNotNull(lines);
    assertEquals(3, lines.length);
    assertTrue(lines[0].startsWith("Positive: +") && lines[0].contains("15.00"), "P must be B*valuesMUL = 10*1.5 = 15.00: " + lines[0]);
    assertTrue(lines[1].startsWith("Negative: -") && lines[1].contains("6.00"), "N must be R*valuesMUL = 4*1.5 = 6.00: " + lines[1]);
    // S = (P-N)*|P-N|/(P+N) = (15-6)*9/21 = 81/21 = 3.857...
    assertTrue(lines[2].startsWith("Final Score: ") && lines[2].contains("3.86"), "S must be (P-N)*|P-N|/(P+N) ~= 3.86: " + lines[2]);
  }

  @Test
  void hoverLines_showsFourLabeledRawLines_whenShowARGBIsOn () {
    app.showARGB_inHover = true;
    putDay(1, app.Impact_ACTIVE, 1, 1, 1f, 2f, 3f, 4f, 1f);

    String[] lines = app.solarImpactHover_lines(app.Impact_ACTIVE, 1, 1, 1);

    assertNotNull(lines);
    assertEquals(4, lines.length);
    assertTrue(lines[0].startsWith("A:"));
    assertTrue(lines[1].startsWith("R:"));
    assertTrue(lines[2].startsWith("G:"));
    assertTrue(lines[3].startsWith("B:"));
  }

  @Test
  void hoverLines_isNull_whenThereIsNoRealDataAtThatPixel () {
    app.showARGB_inHover = false;
    putDay(1, app.Impact_ACTIVE, 1, 1, 1f, 0f, 10f, 0f, 1f); // only (1,1) has data

    assertNull(app.solarImpactHover_lines(app.Impact_ACTIVE, 1, 0, 0));
  }
}
