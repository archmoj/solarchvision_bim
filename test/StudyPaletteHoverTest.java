import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers studyPaletteHover.pde's pure logic: studyPaletteHover_hitTest()
// (plain rect containment over whatever swatches happen to be recorded).
// This single hit-test now serves seven different legend-drawing sites
// (Skin/Pose Potential, Hourly Sun, Sun Path, drawProbs, drawSorted,
// plotImpact_wind's passive mode) - all of them record into the same
// STUDY.paletteSwatchHoverInfo list via the same recordPaletteSwatchHover
// () helper, so the hit-test itself has no per-graph logic to vary; these
// tests exercise it directly against hand-built swatch rects rather than
// against any one specific graph. drawPaletteSwatchHoverBox() itself
// touches real graphics and isn't independently testable here, consistent
// with everything else this session that draws to a live PGraphics
// context.
class StudyPaletteHoverTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  private solarchvision_bim.PaletteSwatchHoverInfo makeSwatch (float x1, float y1, float x2, float y2, String label) {
    solarchvision_bim.PaletteSwatchHoverInfo info = app.new PaletteSwatchHoverInfo();
    info.screenX1 = x1;
    info.screenY1 = y1;
    info.screenX2 = x2;
    info.screenY2 = y2;
    info.label = label;
    info.col = new float[]{ 255, 100, 150, 200 }; // {alpha, r, g, b}
    return info;
  }

  @Test
  void hitTest_findsTheSwatchUnderTheMouse () {
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.paletteSwatchHoverInfo = new java.util.ArrayList<>();
    app.STUDY.paletteSwatchHoverInfo.add(makeSwatch(100, 100, 150, 120, "5.0 kWh/m\u00B2"));

    solarchvision_bim.PaletteSwatchHoverInfo hit = app.studyPaletteHover_hitTest(120, 110);

    assertNotNull(hit);
    assertEquals("5.0 kWh/m\u00B2", hit.label);
  }

  @Test
  void hitTest_isNull_outsideEverySwatch () {
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.paletteSwatchHoverInfo = new java.util.ArrayList<>();
    app.STUDY.paletteSwatchHoverInfo.add(makeSwatch(100, 100, 150, 120, "5.0 kWh/m\u00B2"));

    assertNull(app.studyPaletteHover_hitTest(300, 300));
  }

  @Test
  void hitTest_picksTheCorrectSwatchAmongSeveralAdjacentOnes () {
    // Mirrors how a real 11-swatch legend lays out: equal-width rects
    // sitting side by side with no gaps.
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.paletteSwatchHoverInfo = new java.util.ArrayList<>();
    app.STUDY.paletteSwatchHoverInfo.add(makeSwatch(0, 100, 50, 120, "A"));
    app.STUDY.paletteSwatchHoverInfo.add(makeSwatch(50, 100, 100, 120, "B"));
    app.STUDY.paletteSwatchHoverInfo.add(makeSwatch(100, 100, 150, 120, "C"));

    solarchvision_bim.PaletteSwatchHoverInfo hit = app.studyPaletteHover_hitTest(75, 110);

    assertNotNull(hit);
    assertEquals("B", hit.label);
  }

  @Test
  void hitTest_isNull_whenNothingHasBeenRecordedYet () {
    app.STUDY.paletteSwatchHoverInfo = null;
    assertDoesNotThrow(() -> assertNull(app.studyPaletteHover_hitTest(100, 100)));
  }

  @Test
  void hitTest_doesNotAssumeTheRectsOwnCornerOrdering () {
    // screenX1 > screenX2 and screenY1 > screenY2 (reversed from the
    // "usual" order) must still work, since the hit-test uses min()/max()
    // rather than assuming which corner comes first.
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.paletteSwatchHoverInfo = new java.util.ArrayList<>();
    app.STUDY.paletteSwatchHoverInfo.add(makeSwatch(150, 120, 100, 100, "Reversed"));

    solarchvision_bim.PaletteSwatchHoverInfo hit = app.studyPaletteHover_hitTest(120, 110);

    assertNotNull(hit);
    assertEquals("Reversed", hit.label);
  }

  @Test
  void hitTest_worksTheSameRegardlessOfWhichLegendRecordedTheSwatch () {
    // The hit-test has no awareness of which of the seven sites
    // (drawProbs, drawSorted, plotImpact_wind, Skin/Pose Potential,
    // Hourly Sun, Sun Path) produced a given entry - a drawSorted-style
    // category label and a numeric-plus-unit label from a different
    // legend coexist in the same list and hit-test identically.
    app.STUDY.cX = 0;
    app.STUDY.cY = 0;
    app.STUDY.ImageScale = 1;
    app.STUDY.paletteSwatchHoverInfo = new java.util.ArrayList<>();
    app.STUDY.paletteSwatchHoverInfo.add(makeSwatch(0, 0, 50, 20, "MIN"));          // drawSorted-style category label
    app.STUDY.paletteSwatchHoverInfo.add(makeSwatch(50, 0, 100, 20, "30 %"));       // drawProbs-style percentage
    app.STUDY.paletteSwatchHoverInfo.add(makeSwatch(100, 0, 150, 20, "1.5 \u00B0C")); // plotImpact_wind-style temperature

    assertEquals("MIN", app.studyPaletteHover_hitTest(25, 10).label);
    assertEquals("30 %", app.studyPaletteHover_hitTest(75, 10).label);
    assertEquals("1.5 \u00B0C", app.studyPaletteHover_hitTest(125, 10).label);
  }
}
