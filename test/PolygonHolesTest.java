import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

import java.util.ArrayList;
import processing.core.PVector;

class PolygonHolesTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // --- helpers -----------------------------------------------------------

  private static ArrayList<PVector> loop (float[]... xyz) {
    ArrayList<PVector> result = new ArrayList<PVector>();
    for (float[] p : xyz) result.add(new PVector(p[0], p[1], p.length > 2 ? p[2] : 0));
    return result;
  }

  private static void assertPoint (PVector p, float x, float y, float z, String label) {
    assertEquals(x, p.x, 0.0001f, label + " x");
    assertEquals(y, p.y, 0.0001f, label + " y");
    assertEquals(z, p.z, 0.0001f, label + " z");
  }

  // 4x4 square, (0,0)->(4,0)->(4,4)->(0,4): counterclockwise.
  private static ArrayList<PVector> outerSquare () {
    return loop(new float[]{0, 0, 0}, new float[]{4, 0, 0}, new float[]{4, 4, 0}, new float[]{0, 4, 0});
  }

  // 1x1 square inside it, (1,1)->(2,1)->(2,2)->(1,2): also counterclockwise
  // (same winding as outerSquare()) - PolygonHoles is expected to flip this.
  private static ArrayList<PVector> holeSquareSameWinding () {
    return loop(new float[]{1, 1, 0}, new float[]{2, 1, 0}, new float[]{2, 2, 0}, new float[]{1, 2, 0});
  }

  // The same 1x1 hole, but already wound opposite outerSquare() -
  // (1,1)->(1,2)->(2,2)->(2,1), clockwise - PolygonHoles should leave this
  // one's own point order untouched.
  private static ArrayList<PVector> holeSquareOppositeWinding () {
    return loop(new float[]{1, 1, 0}, new float[]{1, 2, 0}, new float[]{2, 2, 0}, new float[]{2, 1, 0});
  }

  // --- no holes ------------------------------------------------------------

  @Test
  void mergeHolesIntoOuterLoop_noHoles_returnsACopyOfOuter_notTheSameInstance () {
    ArrayList<PVector> outer = outerSquare();

    ArrayList<PVector> resultNull = app.PolygonHoles.mergeHolesIntoOuterLoop(outer, null);
    ArrayList<PVector> resultEmpty = app.PolygonHoles.mergeHolesIntoOuterLoop(outer, new ArrayList<ArrayList<PVector>>());

    assertEquals(4, resultNull.size());
    assertEquals(4, resultEmpty.size());
    assertNotSame(outer, resultNull, "must be a fresh list, not the caller's own");
    assertNotSame(outer, resultEmpty);
    for (int i = 0; i < 4; i++) assertPoint(resultNull.get(i), outer.get(i).x, outer.get(i).y, outer.get(i).z, "point " + i);
  }

  // --- a single hole, both winding directions -------------------------------

  @Test
  void mergeHolesIntoOuterLoop_holeWithSameWindingAsOuter_getsReversedBeforeBridging () {
    ArrayList<PVector> outer = outerSquare();
    ArrayList<ArrayList<PVector>> holes = new ArrayList<ArrayList<PVector>>();
    holes.add(holeSquareSameWinding());

    ArrayList<PVector> result = app.PolygonHoles.mergeHolesIntoOuterLoop(outer, holes);

    // outer(4) + hole(4) + 2 duplicated bridge endpoints = 10.
    assertEquals(10, result.size());

    // The nearest outer-to-hole vertex pair is corner (0,0) to hole-vertex
    // (1,1); since the hole was wound the same way as the outer loop, it
    // must have been reversed first, so the bridge walks the hole in the
    // order (1,1) -> (1,2) -> (2,2) -> (2,1) -> back to (1,1).
    float[][] expected = {
      {0, 0, 0}, {1, 1, 0}, {1, 2, 0}, {2, 2, 0}, {2, 1, 0}, {1, 1, 0}, {0, 0, 0}, {4, 0, 0}, {4, 4, 0}, {0, 4, 0}
    };
    for (int i = 0; i < expected.length; i++) {
      assertPoint(result.get(i), expected[i][0], expected[i][1], expected[i][2], "point " + i);
    }
  }

  @Test
  void mergeHolesIntoOuterLoop_holeAlreadyWoundOppositeToOuter_isNotReversed () {
    ArrayList<PVector> outer = outerSquare();
    ArrayList<ArrayList<PVector>> holes = new ArrayList<ArrayList<PVector>>();
    holes.add(holeSquareOppositeWinding());

    ArrayList<PVector> result = app.PolygonHoles.mergeHolesIntoOuterLoop(outer, holes);

    // Same physical cut, arrived at from a hole that didn't need
    // reversing this time - the result should come out identical to the
    // same-winding case above (just reached by a different path
    // internally), confirming the winding fix-up isn't applied
    // unconditionally regardless of what the input already was.
    assertEquals(10, result.size());
    float[][] expected = {
      {0, 0, 0}, {1, 1, 0}, {1, 2, 0}, {2, 2, 0}, {2, 1, 0}, {1, 1, 0}, {0, 0, 0}, {4, 0, 0}, {4, 4, 0}, {0, 4, 0}
    };
    for (int i = 0; i < expected.length; i++) {
      assertPoint(result.get(i), expected[i][0], expected[i][1], expected[i][2], "point " + i);
    }
  }

  // --- doesn't mutate its inputs --------------------------------------------

  @Test
  void mergeHolesIntoOuterLoop_doesNotMutateOuterOrHoles () {
    ArrayList<PVector> outer = outerSquare();
    ArrayList<PVector> hole = holeSquareSameWinding();
    ArrayList<ArrayList<PVector>> holes = new ArrayList<ArrayList<PVector>>();
    holes.add(hole);

    ArrayList<PVector> outerSnapshot = new ArrayList<PVector>(outer);
    ArrayList<PVector> holeSnapshot = new ArrayList<PVector>(hole);

    app.PolygonHoles.mergeHolesIntoOuterLoop(outer, holes);

    assertEquals(outerSnapshot.size(), outer.size());
    for (int i = 0; i < outer.size(); i++) assertPoint(outer.get(i), outerSnapshot.get(i).x, outerSnapshot.get(i).y, outerSnapshot.get(i).z, "outer " + i);

    assertEquals(holeSnapshot.size(), hole.size());
    for (int i = 0; i < hole.size(); i++) assertPoint(hole.get(i), holeSnapshot.get(i).x, holeSnapshot.get(i).y, holeSnapshot.get(i).z, "hole " + i);
  }

  // --- multiple holes --------------------------------------------------------

  @Test
  void mergeHolesIntoOuterLoop_multipleHoles_allGetBridgedIn () {
    // A wide 10x4 rectangle with two separate 1x1 holes, well apart, each
    // wound the same way as the outer loop - closer to the real shape of a
    // wall with two window openings than a single centered hole is.
    ArrayList<PVector> outer = loop(
      new float[]{0, 0, 0}, new float[]{10, 0, 0}, new float[]{10, 4, 0}, new float[]{0, 4, 0}
    );
    ArrayList<PVector> holeA = loop(
      new float[]{1, 1, 0}, new float[]{2, 1, 0}, new float[]{2, 2, 0}, new float[]{1, 2, 0}
    );
    ArrayList<PVector> holeB = loop(
      new float[]{7, 1, 0}, new float[]{8, 1, 0}, new float[]{8, 2, 0}, new float[]{7, 2, 0}
    );
    ArrayList<ArrayList<PVector>> holes = new ArrayList<ArrayList<PVector>>();
    holes.add(holeA);
    holes.add(holeB);

    ArrayList<PVector> result = app.PolygonHoles.mergeHolesIntoOuterLoop(outer, holes);

    // outer(4) + holeA(4) + 2 + holeB(4) + 2 = 16.
    assertEquals(16, result.size());

    // Every original corner of the outer rectangle, and every original
    // corner of both holes, should still be present somewhere in the
    // result (nothing dropped) - checked as a set, since which vertex the
    // bridges attach to is an implementation detail of findBridge().
    float[][] mustContain = {
      {0, 0, 0}, {10, 0, 0}, {10, 4, 0}, {0, 4, 0},
      {1, 1, 0}, {2, 1, 0}, {2, 2, 0}, {1, 2, 0},
      {7, 1, 0}, {8, 1, 0}, {8, 2, 0}, {7, 2, 0}
    };
    for (float[] expectedPoint : mustContain) {
      boolean found = false;
      for (PVector p : result) {
        if (Math.abs(p.x - expectedPoint[0]) < 0.0001f && Math.abs(p.y - expectedPoint[1]) < 0.0001f) {
          found = true;
          break;
        }
      }
      assertTrue(found, "expected (" + expectedPoint[0] + "," + expectedPoint[1] + ") to survive in the merged loop");
    }
  }

  // --- a hole whose nearest bridge would cut through another hole ------------

  @Test
  void mergeHolesIntoOuterLoop_avoidsBridgingThroughAnotherHole () {
    // A tall 10x4 rectangle; holeFar sits in the middle, holeNear sits
    // directly between holeFar and the left edge of the outer rectangle -
    // the straight line from holeFar's own nearest point to the outer
    // boundary's nearest point would cut straight through holeNear unless
    // findBridge() actually avoids it.
    ArrayList<PVector> outer = loop(
      new float[]{0, 0, 0}, new float[]{10, 0, 0}, new float[]{10, 4, 0}, new float[]{0, 4, 0}
    );
    ArrayList<PVector> holeNear = loop(
      new float[]{1, 1, 0}, new float[]{2, 1, 0}, new float[]{2, 3, 0}, new float[]{1, 3, 0}
    );
    ArrayList<PVector> holeFar = loop(
      new float[]{4, 1, 0}, new float[]{5, 1, 0}, new float[]{5, 3, 0}, new float[]{4, 3, 0}
    );
    ArrayList<ArrayList<PVector>> holes = new ArrayList<ArrayList<PVector>>();
    holes.add(holeNear);
    holes.add(holeFar);

    ArrayList<PVector> result = app.PolygonHoles.mergeHolesIntoOuterLoop(outer, holes);

    assertEquals(16, result.size());

    // Walk every edge of the resulting loop and confirm none of them
    // properly crosses any edge of holeNear's own original boundary -
    // the one thing a naive "just connect the nearest pair" bridge for
    // holeFar could get wrong here.
    for (int i = 0; i < result.size(); i++) {
      PVector a = result.get(i);
      PVector b = result.get((i + 1) % result.size());
      for (int k = 0; k < holeNear.size(); k++) {
        PVector p1 = holeNear.get(k);
        PVector p2 = holeNear.get((k + 1) % holeNear.size());
        assertFalse(segmentsProperlyCross(a, b, p1, p2), "edge " + i + " of the merged loop should not cut through holeNear");
      }
    }
  }

  // Local, independent re-implementation of the same strict 2D
  // segment-crossing test PolygonHoles itself uses internally - kept
  // separate (not calling into PolygonHoles' own private helpers) so this
  // test's own pass/fail doesn't depend on trusting the very code it's
  // meant to be checking.
  private static boolean segmentsProperlyCross (PVector a1, PVector a2, PVector b1, PVector b2) {
    float d1 = cross(b1, b2, a1);
    float d2 = cross(b1, b2, a2);
    float d3 = cross(a1, a2, b1);
    float d4 = cross(a1, a2, b2);
    boolean straddlesB = (d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0);
    boolean straddlesA = (d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0);
    return straddlesB && straddlesA;
  }

  private static float cross (PVector p, PVector q, PVector r) {
    return (q.x - p.x) * (r.y - p.y) - (q.y - p.y) * (r.x - p.x);
  }

  // --- a face off the XY plane ------------------------------------------------

  @Test
  void mergeHolesIntoOuterLoop_faceInAVerticalPlane_stillBridgesCorrectly () {
    // The same 4x4-square-with-a-1x1-hole shape as the very first test,
    // but standing in the XZ plane (y=0 throughout) instead of lying in
    // the XY plane - e.g. a wall face - to confirm this doesn't assume
    // z=0 anywhere.
    ArrayList<PVector> outer = loop(
      new float[]{0, 0, 0}, new float[]{4, 0, 0}, new float[]{4, 0, 4}, new float[]{0, 0, 4}
    );
    ArrayList<PVector> hole = loop(
      new float[]{1, 0, 1}, new float[]{2, 0, 1}, new float[]{2, 0, 2}, new float[]{1, 0, 2}
    );
    ArrayList<ArrayList<PVector>> holes = new ArrayList<ArrayList<PVector>>();
    holes.add(hole);

    ArrayList<PVector> result = app.PolygonHoles.mergeHolesIntoOuterLoop(outer, holes);

    assertEquals(10, result.size());
    // Every point in the result must still lie exactly on y=0 - nothing
    // here should ever introduce an out-of-plane coordinate.
    for (PVector p : result) assertEquals(0f, p.y, 0.0001f, "should stay in the y=0 plane");

    // And every original corner (outer and hole both) must still be
    // present somewhere in the result.
    float[][] mustContain = {
      {0, 0, 0}, {4, 0, 0}, {4, 0, 4}, {0, 0, 4}, {1, 0, 1}, {2, 0, 1}, {2, 0, 2}, {1, 0, 2}
    };
    for (float[] expectedPoint : mustContain) {
      boolean found = false;
      for (PVector p : result) {
        if (Math.abs(p.x - expectedPoint[0]) < 0.0001f && Math.abs(p.z - expectedPoint[2]) < 0.0001f) {
          found = true;
          break;
        }
      }
      assertTrue(found, "expected (" + expectedPoint[0] + ",0," + expectedPoint[2] + ") to survive in the merged loop");
    }
  }

  // --- a triangular hole (not just quads) -------------------------------------

  @Test
  void mergeHolesIntoOuterLoop_triangularHole_bridgesAThreeVertexLoopToo () {
    ArrayList<PVector> outer = outerSquare();
    ArrayList<PVector> hole = loop(new float[]{1, 1, 0}, new float[]{2, 1, 0}, new float[]{1.5f, 2, 0});
    ArrayList<ArrayList<PVector>> holes = new ArrayList<ArrayList<PVector>>();
    holes.add(hole);

    ArrayList<PVector> result = app.PolygonHoles.mergeHolesIntoOuterLoop(outer, holes);

    // outer(4) + hole(3) + 2 = 9.
    assertEquals(9, result.size());
  }

  // --- a hole with fewer than 3 points is simply skipped ----------------------

  @Test
  void mergeHolesIntoOuterLoop_degenerateHoleWithTooFewPoints_isSkipped () {
    ArrayList<PVector> outer = outerSquare();
    ArrayList<PVector> degenerateHole = loop(new float[]{1, 1, 0}, new float[]{2, 1, 0}); // only 2 points
    ArrayList<ArrayList<PVector>> holes = new ArrayList<ArrayList<PVector>>();
    holes.add(degenerateHole);

    ArrayList<PVector> result = app.PolygonHoles.mergeHolesIntoOuterLoop(outer, holes);

    assertEquals(4, result.size(), "a <3-point hole has nothing to bridge, so the outer loop should come back untouched");
  }

  // --- triangulate() -----------------------------------------------------

  private static float triangleArea (PVector a, PVector b, PVector c) {
    PVector ab = PVector.sub(b, a);
    PVector ac = PVector.sub(c, a);
    return 0.5f * ab.cross(ac).mag();
  }

  private static float totalArea (ArrayList<PVector> loop, ArrayList<int[]> triangles) {
    float sum = 0;
    for (int[] t : triangles) {
      sum += triangleArea(loop.get(t[0]), loop.get(t[1]), loop.get(t[2]));
    }
    return sum;
  }

  @Test
  void triangulate_tooFewPoints_returnsNoTriangles () {
    assertEquals(0, app.PolygonHoles.triangulate(loop()).size());
    assertEquals(0, app.PolygonHoles.triangulate(loop(new float[]{0, 0, 0})).size());
    assertEquals(0, app.PolygonHoles.triangulate(loop(new float[]{0, 0, 0}, new float[]{1, 0, 0})).size());
  }

  @Test
  void triangulate_aTriangle_returnsItselfUnchanged_withoutRunningEarClipping () {
    ArrayList<PVector> triangleLoop = loop(new float[]{0, 0, 0}, new float[]{1, 0, 0}, new float[]{0, 1, 0});
    ArrayList<int[]> triangles = app.PolygonHoles.triangulate(triangleLoop);

    assertEquals(1, triangles.size());
    assertArrayEquals(new int[]{0, 1, 2}, triangles.get(0));
  }

  @Test
  void triangulate_aSquare_producesTwoTrianglesCoveringTheFullArea () {
    ArrayList<PVector> square = outerSquare(); // 4x4, area 16
    ArrayList<int[]> triangles = app.PolygonHoles.triangulate(square);

    assertEquals(2, triangles.size());
    assertEquals(16f, totalArea(square, triangles), 0.0001f);
  }

  @Test
  void triangulate_concaveLShape_coversExactlyTheLsOwnArea_notItsBoundingSquare () {
    // An L-shape: the top-right 2x2 corner of a 4x4 square is missing -
    // true area 12, not 16, the way a naive convex-assuming triangulator
    // (or a fan from a point outside the L's own notch) might produce.
    ArrayList<PVector> lShape = loop(
      new float[]{0, 0, 0}, new float[]{4, 0, 0}, new float[]{4, 2, 0},
      new float[]{2, 2, 0}, new float[]{2, 4, 0}, new float[]{0, 4, 0}
    );
    ArrayList<int[]> triangles = app.PolygonHoles.triangulate(lShape);

    assertEquals(4, triangles.size(), "an n-vertex simple polygon always triangulates into n-2 triangles");
    assertEquals(12f, totalArea(lShape, triangles), 0.0001f);
  }

  @Test
  void triangulate_everyTriangleIndexIsValidAndDistinctWithinItsOwnTriangle () {
    ArrayList<PVector> lShape = loop(
      new float[]{0, 0, 0}, new float[]{4, 0, 0}, new float[]{4, 2, 0},
      new float[]{2, 2, 0}, new float[]{2, 4, 0}, new float[]{0, 4, 0}
    );
    ArrayList<int[]> triangles = app.PolygonHoles.triangulate(lShape);

    for (int[] t : triangles) {
      assertEquals(3, t.length);
      for (int idx : t) assertTrue(idx >= 0 && idx < lShape.size());
      assertNotEquals(t[0], t[1]);
      assertNotEquals(t[1], t[2]);
      assertNotEquals(t[0], t[2]);
    }
  }

  @Test
  void triangulate_aKeyholeBridgedSquareWithAHole_excludesTheHolesOwnArea () {
    // The exact bug this was written to fix: a hole bridged into its
    // outer loop via mergeHolesIntoOuterLoop() is never convex, so a
    // naive fan from some arbitrary interior point (this app's own
    // previous raycasting-grid behavior) can cover part of the hole's
    // own, supposedly-empty area with phantom triangles. True
    // triangulation must not: a 4x4 square (area 16) with a 1x1 hole
    // (area 1) bridged in should triangulate to exactly area 15, not 16.
    ArrayList<PVector> outer = outerSquare();
    ArrayList<ArrayList<PVector>> holes = new ArrayList<ArrayList<PVector>>();
    holes.add(holeSquareSameWinding());

    ArrayList<PVector> merged = app.PolygonHoles.mergeHolesIntoOuterLoop(outer, holes);
    ArrayList<int[]> triangles = app.PolygonHoles.triangulate(merged);

    assertEquals(15f, totalArea(merged, triangles), 0.0001f, "16 (outer) - 1 (hole) = 15 - the hole's own area must not be covered");

    // Belt and braces: no triangle's own centroid should fall inside the
    // original 1x1 hole (1,1)-(2,1)-(2,2)-(1,2) at all - a direct,
    // geometric check of the same thing the area total above already
    // implies.
    for (int[] t : triangles) {
      PVector a = merged.get(t[0]);
      PVector b = merged.get(t[1]);
      PVector c = merged.get(t[2]);
      float cx = (a.x + b.x + c.x) / 3;
      float cy = (a.y + b.y + c.y) / 3;
      boolean centroidInsideHole = cx > 1 && cx < 2 && cy > 1 && cy < 2;
      assertFalse(centroidInsideHole, "a triangle's own centroid landed inside the hole - exactly the reported bug");
    }
  }

  @Test
  void triangulate_doesNotMutateItsInput () {
    ArrayList<PVector> square = outerSquare();
    ArrayList<PVector> snapshot = new ArrayList<PVector>(square);

    app.PolygonHoles.triangulate(square);

    assertEquals(snapshot.size(), square.size());
    for (int i = 0; i < square.size(); i++) {
      assertEquals(snapshot.get(i).x, square.get(i).x, 0.0001f);
      assertEquals(snapshot.get(i).y, square.get(i).y, 0.0001f);
      assertEquals(snapshot.get(i).z, square.get(i).z, 0.0001f);
    }
  }
}
