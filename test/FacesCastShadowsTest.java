import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Faces.castShadows() (faces.pde) was untested - 830 instructions, one
// of the largest shadow-casting functions in the codebase. Its real
// per-sub-face shadow projection calls SHADOW_graphics.beginShape()/
// .vertex() - SHADOW_graphics is a PGraphics assigned via createGraphics()
// elsewhere (castShadowsCurrentSection.pde), the same createGraphics()
// NullPointerException documented throughout this suite without a real
// sketch surface - so it stays null here, and any face that reaches
// that call would throw.
//
// Each test below is deliberately built to stop just short of it, while
// still exercising real logic rather than an empty no-op:
//
// - displayAll == false skips the whole function before even computing
//   its own depthOffset - tested here with a face that WOULD otherwise
//   be risky (real geometry, visible, a material whose alpha passes the
//   later check), so a doesNotThrow here is actual proof the guard
//   works, not just an absence of anything to go wrong.
// - A visible face (vsb > 0) with a low-alpha material - index 8's own
//   real color, {63, 63, 63, 63} (materials.pde's own "Indoor space"
//   entry, alpha 63) - passes the per-face loop and its own visibility
//   check, then fails "allMaterials.Color[mt][0] > 127" (63 is not),
//   skipping before SHADOW_graphics is ever touched.
// - An invisible face (vsb == 0) - skips earlier still, right at its
//   own visibility check.
//
// Material 1's own real color ({255, 255, 0, 0}, alpha 255) - used
// throughout this suite's other Create/Move/PickSelect tests for an
// ordinary "visible" face - was checked here specifically BECAUSE its
// alpha passes 127, which is exactly why it's deliberately NOT reused
// for this file's own tests: it's the one combination (visible + alpha
// > 127) that would actually reach SHADOW_graphics.
class FacesCastShadowsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void onAnEmptyScene_doesNotThrow () {
    // allFaces.nodes' own bare-construction default (length 0) - the
    // per-face loop never iterates at all.
    assertDoesNotThrow(() -> app.allFaces.castShadows());
  }

  @Test
  void displayAllFalse_skipsEntirely_evenWithARealVisibleFace () {
    app.allFaces.displayAll = false;
    app.allVertices = new float[][]{{-5, -5, 0}, {5, -5, 0}, {0, 5, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{1, 0, 0, 1, 0, 0}}; // material 1 (alpha 255), visibility 1 - would reach SHADOW_graphics if displayAll didn't skip it first

    assertDoesNotThrow(() -> app.allFaces.castShadows());
  }

  @Test
  void aVisibleFaceWithALowAlphaMaterial_isSkippedBeforeShadowGraphics () {
    app.allVertices = new float[][]{{-5, -5, 0}, {5, -5, 0}, {0, 5, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{8, 0, 0, 1, 0, 0}}; // material 8 (alpha 63, Materials.Color's own real value), visible

    assertDoesNotThrow(() -> app.allFaces.castShadows());
  }

  @Test
  void anInvisibleFace_isSkippedBeforeTheMaterialCheck () {
    app.allVertices = new float[][]{{-5, -5, 0}, {5, -5, 0}, {0, 5, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{1, 0, 0, 0, 0, 0}}; // material 1 (alpha 255, would otherwise pass), visibility 0

    assertDoesNotThrow(() -> app.allFaces.castShadows());
  }
}
