import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Model1Ds()/Model2Ds() ultimately call castDrop() -> castRay(), which for
// WIN3D.toolParameterModifier == 0 hits Terrain.intersect() against real
// (if empty-by-default) grid geometry - too easy to get subtly wrong
// without deeper knowledge of that data shape, so this sticks to the one
// selection ID list being empty (0 iterations, no intersect call at all)
// and to castRay/castDrop's own fallback branch (no Terrain/Faces call
// either, since toolParameterModifier matches neither special value).
class Drop3DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= castRay - fallback branch (no intersect call) =========

  @Test
  void castRay_returnsUndefinedWhenTaskModifyParameterMatchesNeitherSpecialValue () {
    app.WIN3D.toolParameterModifier = 99; // neither 0 (Terrain) nor faceParam

    float[] result = app.Drop3D.castRay(new float[]{0, 0, 10}, new float[]{0, 0, -1}, 1);

    assertEquals(-1f, result[0], 0.0001f);
  }

  @Test
  void castRay_returnsAnEightElementUndefinedArrayOnTheFallbackBranch () {
    app.WIN3D.toolParameterModifier = 99;

    float[] result = app.Drop3D.castRay(new float[]{0, 0, 10}, new float[]{0, 0, -1}, 1);

    assertEquals(8, result.length);
  }

  // ================= castDrop - both directions miss ========================

  @Test
  void castDrop_returnsUndefinedWhenNeitherDirectionHitsAnything () {
    // Neither 1 nor 2 matches, and 0 doesn't either, so both the downward
    // and the upward castRay() calls take the fallback branch above.
    app.WIN3D.toolParameterModifier = 99;

    float[] result = app.Drop3D.castDrop(1, 2, 3);

    assertEquals(-1f, result[0], 0.0001f);
  }

  // ================= selection - routing =====================================

  @Test
  void selection_doesNothingForAnUnrelatedObjectCategory () {
    app.currentObjectCategory = app.ObjectCategory.GROUP; // neither MODEL1D nor MODEL2D
    app.WIN3D.update = false;

    app.Drop3D.selection();

    assertFalse(app.WIN3D.update); // model_changed() -> WIN3D.revise() never ran
  }

  @Test
  void selection_routesToModel1DsAndFlagsTheViewportWhenNothingIsSelected () {
    app.currentObjectCategory = app.ObjectCategory.MODEL1D;
    app.Select3D.model1DSelection = new int[0]; // 0 iterations - castDrop() is never called
    app.WIN3D.update = false;

    assertDoesNotThrow(() -> app.Drop3D.selection());

    assertTrue(app.WIN3D.update); // model_changed() still runs even with nothing selected
  }

  @Test
  void selection_routesToModel2DsAndFlagsTheViewportWhenNothingIsSelected () {
    app.currentObjectCategory = app.ObjectCategory.MODEL2D;
    app.Select3D.model2DSelection = new int[0];
    app.WIN3D.update = false;

    assertDoesNotThrow(() -> app.Drop3D.selection());

    assertTrue(app.WIN3D.update);
  }
}
