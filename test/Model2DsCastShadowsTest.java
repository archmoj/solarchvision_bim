import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

// Model2Ds.castShadows(SunR) (model2Ds.pde) was untested - 1372
// instructions, the largest of the shadow-casting functions surveyed
// this round. Same confirmed createGraphics() risk as Faces.castShadows()
// (FacesCastShadowsTest.java): TREES_graphics is a PGraphics assigned
// via createGraphics() elsewhere (castShadowsCurrentSection.pde), stays
// null headlessly.
//
// Unlike Faces.castShadows(), there was no safe way found here to
// exercise a real entry without reaching it: TREES_graphics.beginShape()
// sits right at the top of the function's one real branch (kind.isTree()),
// with no per-entry visibility/material-alpha guard in front of it the
// way Faces.castShadows() had - and even just reaching that isTree()
// check requires a real, already-loaded PImage per entry (kind.Images[n]
// .width is read unconditionally, before the isTree() check, for every
// entry regardless of kind), which this suite has no established way to
// construct without real bundled texture files and a load_images() call
// of its own. So only the empty-scene case (no Model2Ds at all - the
// per-entry loop body, including that first Images[n].width read, never
// runs) is covered here.
//
// castShadows_CurrentSection()/renderShadowFrame() (the same tab) were
// also surveyed and are NOT covered at all: both call createGraphics()/
// TREES_graphics.beginDraw() completely unconditionally, at their own
// very first line - unlike every other shadow-casting function checked
// this session, there's no guard or empty-scene path that avoids it;
// calling either throws immediately regardless of scene content, the
// same confirmed-unreachable category as calculate_VertexSolar_array().
class Model2DsCastShadowsTest {

  @Test
  void onAnEmptyScene_doesNotThrow () {
    solarchvision_bim app = new solarchvision_bim();

    // allModel2Ds.num's own bare-construction default (0) - the
    // per-entry loop never iterates, so kind.Images[n] is never read
    // and TREES_graphics is never touched.
    assertDoesNotThrow(() -> app.allModel2Ds.castShadows(new float[]{0, 0, 0, 1}));
  }
}
