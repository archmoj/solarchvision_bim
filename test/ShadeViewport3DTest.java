import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// isFaceEdgeBetween() (shadeViewport3D.pde) decides whether the
// face-edges mask should paint an edge between two neighboring pixels,
// given each side's hit (a Face index >= 0, FACE_EDGE_HIT_BACKGROUND, or
// FACE_EDGE_HIT_OTHER_OBJECT) and, when that side is a Face, its unit
// normal. Its own source comment calls it out as "Pure/no drawing or
// face-grid access, so it's independently checkable without a live
// PGraphics context, unlike the rest of this per-pixel loop" - yet it had
// no dedicated test and sat at 0% coverage. Every test below calls it
// directly on a bare app instance; none of its inputs touch any other
// field, so there's no setup beyond construction.
class ShadeViewport3DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= either side is a non-Face object (Model1D/Model2Ds) ====
  // Takes priority over every other case - checked first in the source,
  // so these also prove it short-circuits before reading any normal.

  @Test
  void otherObjectOnSideA_neverAnEdge_evenAgainstTheBackground () {
    assertFalse(app.isFaceEdgeBetween(
        app.FACE_EDGE_HIT_OTHER_OBJECT, 0, 0, 1,
        app.FACE_EDGE_HIT_BACKGROUND, 0, 0, 0));
  }

  @Test
  void otherObjectOnSideA_neverAnEdge_evenAgainstAFaceWithAnOpposingNormal () {
    // Opposing normals (dot == -1) would read as an edge between two
    // Faces (see the crease test below) - confirming this is still false
    // proves the FACE_EDGE_HIT_OTHER_OBJECT check really does come first.
    assertFalse(app.isFaceEdgeBetween(
        app.FACE_EDGE_HIT_OTHER_OBJECT, 0, 0, 1,
        3, 0, 0, -1));
  }

  @Test
  void otherObjectOnSideB_neverAnEdge () {
    assertFalse(app.isFaceEdgeBetween(
        5, 0, 0, 1,
        app.FACE_EDGE_HIT_OTHER_OBJECT, 0, 0, 0));
  }

  @Test
  void otherObjectOnBothSides_neverAnEdge () {
    assertFalse(app.isFaceEdgeBetween(
        app.FACE_EDGE_HIT_OTHER_OBJECT, 0, 0, 0,
        app.FACE_EDGE_HIT_OTHER_OBJECT, 0, 0, 0));
  }

  // ================= a Face next to the background: silhouette ==============

  @Test
  void faceNextToBackground_isAnEdge () {
    assertTrue(app.isFaceEdgeBetween(
        2, 0, 0, 1,
        app.FACE_EDGE_HIT_BACKGROUND, 0, 0, 0));
  }

  @Test
  void backgroundNextToFace_isAnEdge_regardlessOfWhichSideIsWhich () {
    assertTrue(app.isFaceEdgeBetween(
        app.FACE_EDGE_HIT_BACKGROUND, 0, 0, 0,
        2, 0, 0, 1));
  }

  @Test
  void faceIndexZero_stillCountsAsAFace_notAsBackground () {
    // Index 0 is a legitimate Face index - only -1 is background, so this
    // guards against an off-by-one on the hitA >= 0 / hitB >= 0 checks.
    assertTrue(app.isFaceEdgeBetween(
        0, 0, 0, 1,
        app.FACE_EDGE_HIT_BACKGROUND, 0, 0, 0));
  }

  // ================= background next to background: nothing to outline ======

  @Test
  void backgroundNextToBackground_isNeverAnEdge () {
    assertFalse(app.isFaceEdgeBetween(
        app.FACE_EDGE_HIT_BACKGROUND, 0, 0, 0,
        app.FACE_EDGE_HIT_BACKGROUND, 0, 0, 0));
  }

  // ================= two Faces: same Face index never an edge ===============

  @Test
  void theSameFaceIndexOnBothSides_isNeverAnEdge_evenWithDifferentNormals () {
    // Same Face index (one tessellated piece touching an adjacent pixel
    // of itself) - the identical-index check must short-circuit before
    // ever comparing normals, so even wildly different normals here must
    // not produce an edge.
    assertFalse(app.isFaceEdgeBetween(
        4, 1, 0, 0,
        4, 0, 1, 0));
  }

  // ================= two different Faces: normals decide ====================

  @Test
  void twoDifferentFaces_identicalNormals_isNotAnEdge () {
    // dot == 1.0 - the same flat surface split across two tessellated
    // pieces, must not draw an internal edge.
    assertFalse(app.isFaceEdgeBetween(
        1, 0.6f, 0.8f, 0f,
        2, 0.6f, 0.8f, 0f));
  }

  @Test
  void twoDifferentFaces_opposingNormals_isAnEdge () {
    // dot == -1.0 - a hard fold back on itself.
    assertTrue(app.isFaceEdgeBetween(
        1, 0, 0, 1,
        2, 0, 0, -1));
  }

  @Test
  void twoDifferentFaces_perpendicularNormals_isAnEdge () {
    // dot == 0.0 - a right-angle crease (e.g. a wall meeting the ground).
    assertTrue(app.isFaceEdgeBetween(
        1, 1, 0, 0,
        2, 0, 1, 0));
  }

  @Test
  void twoDifferentFaces_dotJustAboveThreshold_isNotAnEdge () {
    // dot == 0.9995, above FACE_EDGE_NORMAL_DOT_THRESHOLD (0.999) -
    // close enough to be treated as the same flat surface (e.g. two
    // independently-computed normals for what's geometrically one plane).
    assertFalse(app.isFaceEdgeBetween(
        1, 1, 0, 0,
        2, 0.9995f, 0, 0));
  }

  @Test
  void twoDifferentFaces_dotJustBelowThreshold_isAnEdge () {
    // dot == 0.9989, just under the threshold - a genuine (if shallow) crease.
    assertTrue(app.isFaceEdgeBetween(
        1, 1, 0, 0,
        2, 0.9989f, 0, 0));
  }

  @Test
  void twoDifferentFaces_dotExactlyAtThreshold_isNotAnEdge () {
    // dot == exactly FACE_EDGE_NORMAL_DOT_THRESHOLD: the comparison is a
    // strict "<", so an exact match at the boundary must NOT count as an
    // edge - pins which side of the boundary the threshold itself falls on.
    assertFalse(app.isFaceEdgeBetween(
        1, 1, 0, 0,
        2, 0.999f, 0, 0));
  }
}
