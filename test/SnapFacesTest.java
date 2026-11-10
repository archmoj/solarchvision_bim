import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// snap_Faces()'s own real feature - snapping to a face's nearest vertex,
// User3D.creatorSnapModeIndex == 1 - calls WIN3D.graphics.beginShape()
// unconditionally inside its own per-sub-face loop (confirmed directly
// against the real compiled app, not assumed) despite never calling
// endShape() or anything else on it afterward - nothing in that loop
// actually draws anything, so this looks like a leftover from an
// earlier, copy-pasted implementation rather than something load-bearing.
// Flagging this rather than quietly working around it: WIN3D.graphics is
// null on a bare, never-setup() instance (same as every other
// WIN3D.graphics-touching codepath this suite has run into), so this
// specific line is what stands between that one real branch and being
// headlessly testable at all - confirmed below, not worked around.
//
// What IS safely, headlessly testable are the two branches that never
// reach that line in the first place: a miss (RxP[0] < 0, no face under
// the cursor) and creatorSnapModeIndex at anything other than 1 (0 is
// the default - nearest-endpoint snapping is opt-in).
class SnapFacesTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
  }

  @Test
  void snapFaces_withNoFaceUnderTheCursor_returnsRxPUnchanged () {
    // RxP[0] < 0 is this function's own "no face hit" convention (see
    // its own leading "if (RxP[0] >= 0)" guard) - the exact same array
    // instance comes back, untouched.
    float[] RxP = { -1, 10, 20, 30 };

    float[] result = app.snap_Faces(RxP);

    assertSame(RxP, result);
    assertArrayEquals(new float[]{ -1, 10, 20, 30 }, result, 0.0001f);
  }

  @Test
  void snapFaces_withCreatorSnapModeAtItsDefault_leavesRxPUnchanged () {
    // creatorSnapModeIndex defaults to 0 (user3D.pde) - nearest-endpoint
    // snapping only ever happens at == 1, so a hit face under the
    // cursor is otherwise passed straight through.
    assertEquals(0, app.User3D.creatorSnapModeIndex, "sanity check, not the point of this test");
    float[] RxP = { 0, 10, 20, 30 }; // face 0 hit, at (10, 20, 30)

    float[] result = app.snap_Faces(RxP);

    assertArrayEquals(new float[]{ 0, 10, 20, 30 }, result, 0.0001f);
  }

  @Test
  void snapFaces_withAnyOtherCreatorSnapMode_alsoLeavesRxPUnchanged () {
    app.User3D.creatorSnapModeIndex = 2;
    float[] RxP = { 0, 10, 20, 30 };

    float[] result = app.snap_Faces(RxP);

    assertArrayEquals(new float[]{ 0, 10, 20, 30 }, result, 0.0001f);
  }

  @Test
  void snapFaces_nearestEndpointMode_onABareInstance_throwsOnItsOwnUnusedBeginShapeCall () {
    // Pinned down, not worked around - see this class's own header
    // comment. If this ever starts passing instead of throwing, that
    // almost certainly means the dead beginShape()/endShape() pair was
    // cleaned up, which would be the moment to replace this test with a
    // real one for the nearest-endpoint behavior itself.
    app.User3D.creatorSnapModeIndex = 1;
    float[] RxP = { 0, 10, 20, 30 };

    NullPointerException thrown = assertThrows(NullPointerException.class, () -> app.snap_Faces(RxP));
    assertTrue(thrown.getMessage().contains("WIN3D.graphics"), thrown.getMessage());
  }
}
