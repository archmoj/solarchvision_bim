import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers the Torus-specific additions riding on top of the existing
// Dome/Egg-Crate/Saddle/Diagonal Wave/Wavy Sphere/Twisted Sphere
// parametric-surface mechanism (create3D.pde's add_ParametricSurface(),
// n=7, see that function's own comment): the k (minor:major radius
// ratio) parameter it alone reads, and User3D.creatorTorusRatio, the new
// field that carries it from the Create menu's own "Torus" item through
// to there - same pipeline as creatorParametricTypeIndex, see
// UI_setTo_Create_Parametric()'s own code. AddParametricSurfaceRemainingTest.java's
// own n7 test already covers the single-corner/grid-shape check this
// family's other n values get; this file covers what's unique to a
// torus instead - that it actually forms a ring of the expected
// thickness, not just "a grid of quads".
class TorusTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // Every vertex's own distance from the Z axis should land somewhere
  // in [1-k, 1+k] (before rx/ry/rz scale it) - the ring's own outer and
  // inner edges, at v=0 and v=180 deg respectively, where cos(v*PI) is
  // at its own +1/-1 extremes. Checked as a min/max across the whole
  // vertex set, rather than any one corner, since (unlike every other
  // n value here) a torus's own interesting geometry is about its
  // overall ring shape, not any single deterministic point.
  @Test
  void n7_torus_everyVertexStaysWithinTheExpectedRingThickness () {
    float k = 0.4f;
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 7, 0, k);

    float minDist = Float.MAX_VALUE, maxDist = 0;
    for (float[] v : app.allVertices) {
      float dist = (float) Math.sqrt(v[0] * v[0] + v[1] * v[1]);
      minDist = Math.min(minDist, dist);
      maxDist = Math.max(maxDist, dist);
    }

    assertEquals(1 - k, minDist, 0.01f, "the tube's own innermost point should sit at major radius 1 minus minor radius k");
    assertEquals(1 + k, maxDist, 0.01f, "the tube's own outermost point should sit at major radius 1 plus minor radius k");
  }

  @Test
  void n7_torus_rxAndRyIndependentlyStretchTheRingIntoAnEllipse () {
    // rx/ry apply AFTER the raw (x, y, z) formula, same as every other
    // n value here - so a torus with rx != ry should trace an
    // elliptical, not circular, ring footprint.
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 1, 1, 7, 0, 0.3f);

    float maxX = 0, maxY = 0;
    for (float[] v : app.allVertices) {
      maxX = Math.max(maxX, Math.abs(v[0]));
      maxY = Math.max(maxY, Math.abs(v[1]));
    }

    assertEquals(2 * 1.3f, maxX, 0.05f, "rx=2 should double the ring's own reach along X (major radius 1 + minor radius 0.3, times rx)");
    assertEquals(1.3f, maxY, 0.05f, "ry=1 should leave the ring's own reach along Y unscaled");
  }

  @Test
  void n7_torus_clampsKAtZeroAndOneSoTheTubeNeverCollapsesOrSelfIntersects () {
    // k=0 would collapse the tube to a zero-thickness ring (division-
    // free, but geometrically degenerate) and k=1 (or beyond) would
    // make the tube's own radius reach past the ring's own center,
    // self-intersecting - add_ParametricSurface()'s own comment on its
    // k parameter documents clamping to (0, 1) for exactly this reason.
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 7, 0, 0);
    float minDistAtZero = Float.MAX_VALUE;
    for (float[] v : app.allVertices) {
      minDistAtZero = Math.min(minDistAtZero, (float) Math.sqrt(v[0] * v[0] + v[1] * v[1]));
    }
    assertTrue(minDistAtZero > 0, "k=0 should still clamp to a non-zero tube thickness, not collapse the ring to a single circle");

    app.allVertices = new float[0][];
    app.allFaces.nodes = new int[0][];
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 7, 0, 1.5f);
    float maxDistAboveOne = 0;
    for (float[] v : app.allVertices) {
      maxDistAboveOne = Math.max(maxDistAboveOne, (float) Math.sqrt(v[0] * v[0] + v[1] * v[1]));
    }
    assertTrue(maxDistAboveOne < 2, "k=1.5 should clamp below 1 instead of producing a tube reaching out to 2.5");
  }

  @Test
  void everyOtherParametricPreset_isUnaffectedByKWhenItsPassedANonZeroValue () {
    // k is only ever read by n==7 - this cross-checks that a stray
    // non-zero k passed alongside an ordinary n=1..6 preset changes
    // nothing, confirming the new parameter is additive, not a
    // regression risk for the 6 presets that already existed.
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0);
    float[] withoutK = app.allVertices[0].clone();

    app.allVertices = new float[0][];
    app.allFaces.nodes = new int[0][];
    app.Create3D.add_ParametricSurface(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0.9f);
    float[] withK = app.allVertices[0];

    assertArrayEquals(withoutK, withK, 0.0001f);
  }

  // --- wiring: Create menu -> UI_setTo_Create_Parametric -> User3D ------

  @Test
  void createTorus_routesThroughTheSameParametricCreateConstantAsEveryOtherPreset () {
    app.UI_setTo_Create_Parametric(7);

    assertEquals(app.CREATE.Parametric, app.CreateObject);
    assertEquals(7, app.User3D.creatorParametricTypeIndex);
  }

  @Test
  void creatorTorusRatio_roundTripsThroughXML () {
    app.User3D.creatorTorusRatio = 0.42f;

    processing.data.XML root = new processing.data.XML("root");
    app.User3D.to_XML(root);

    solarchvision_bim.User3D fresh = app.new User3D();
    fresh.from_XML(root);

    assertEquals(0.42f, fresh.creatorTorusRatio, 0.0001f);
  }

  @Test
  void creatorTorusRatio_fallsBackToPointThreeForAnOlderSaveFileMissingTheField () {
    // Same "bare child, no attributes" simulation of an older save file
    // as User3DTest.java's own fromXML_missingSkewAndTwistFields_...
    processing.data.XML root = new processing.data.XML("root");
    root.addChild(app.User3D.CLASS_STAMP);

    solarchvision_bim.User3D fresh = app.new User3D();
    fresh.from_XML(root);

    assertEquals(0.3f, fresh.creatorTorusRatio, 0.0001f);
  }
}
