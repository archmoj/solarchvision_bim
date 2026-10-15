// ---------------------------------------------------------------------
// PolygonHoles - turns a planar polygon with one or more holes into a
// single simple loop, by bridging each hole to the outer boundary (or
// to an already-bridged hole) with a pair of coincident "slit" edges.
// This is the standard, well-known technique (sometimes called a
// "keyhole" cut) for handing a polygon-with-holes to any renderer or
// data model - like this app's own allFaces, via ifcEmitFace() in
// import_objects_IFC.pde - that only understands a single boundary loop
// per face, with no native concept of an inner hole.
//
// Not IFC-specific on purpose: the input/output here is plain 3D point
// loops (ArrayList<PVector>), so this is equally usable for any other
// part of the program that ends up with a polygon-with-holes to render
// as ordinary faces - and directly unit-testable on its own, without
// going through a whole IFC file.
//
// Written as a class, instantiated once as the global PolygonHoles (see
// globals.pde), the same convention Select3D/Rotate3D/... already use.
// ---------------------------------------------------------------------

class PolygonHoles {

  final static String CLASS_STAMP = "PolygonHoles";

  // Returns a single loop that is `outer` with every loop in `holes`
  // bridged into it - rendering it as one ordinary (if self-touching)
  // polygon makes the holes visually disappear, exactly the way a
  // "filled with holes" polygon should look when drawn as a single
  // simple face. Always returns a new list - `outer` and every list
  // inside `holes` are read, never mutated, and the result is never the
  // same list instance as `outer` - so the caller can hand this
  // straight to a single-loop face consumer (like ifcEmitFace()) and
  // freely mutate or discard the result afterward.
  //
  // `outer` and every loop in `holes` are assumed to lie in (close to)
  // the same plane - the one plane used for every geometric decision
  // here (via Newell's method on `outer` alone, see faceNormal() below)
  // - which holds for any real IfcIndexedPolygonalFaceWithVoids or
  // IfcFace/IfcFaceBound this is meant to feed from. A hole genuinely
  // off that plane will still get bridged in - this never drops a hole
  // or throws - but the bridge's own straightness is only meaningful
  // within the shared plane.
  //
  // `holes` may be null or empty, in which case this is just a defensive
  // copy of `outer`. A hole with fewer than 3 points is skipped (nothing
  // to bridge).
  ArrayList<PVector> mergeHolesIntoOuterLoop (ArrayList<PVector> outer, ArrayList<ArrayList<PVector>> holes) {
    ArrayList<PVector> merged = new ArrayList<PVector>(outer);
    if (holes == null || holes.size() == 0) return merged;

    PVector normal = faceNormal(outer);
    PVector uAxis = anyPerpendicularUnitVector(normal);
    PVector vAxis = normal.cross(uAxis);
    // Newell's method gives a direction, not a handedness guarantee
    // against uAxis in every degenerate case - re-deriving vAxis from
    // the two vectors we already trust (rather than assuming normal and
    // uAxis are already exactly orthonormal) keeps the 2D basis
    // genuinely orthonormal even when normal's own magnitude is small.
    vAxis.normalize();

    PVector origin = outer.get(0);

    // Every hole's own points, projected once up front alongside
    // `outer`'s own current projection, and kept in lock-step with
    // `merged` as holes are spliced in - see project()/the main loop
    // below for why these three stay parallel throughout.
    ArrayList<PVector> merged2D = project(merged, origin, uAxis, vAxis);
    float outerWinding = signedArea2D(merged2D) >= 0 ? 1 : -1;

    // A hole must wind opposite to the outer loop: once bridged into
    // one simple polygon, filling that polygon under the ordinary
    // nonzero/even-odd rule only leaves the hole empty if its own
    // winding cancels the outer loop's there, rather than reinforcing
    // it. A void loop's own winding, as written in the source file, is
    // exporter-dependent and not something this importer controls, so
    // every hole here is checked and flipped (a defensive copy, not the
    // caller's own list) if it shares the outer loop's winding instead
    // of opposing it.
    ArrayList<ArrayList<PVector>> holes3D = new ArrayList<ArrayList<PVector>>();
    ArrayList<ArrayList<PVector>> holes2D = new ArrayList<ArrayList<PVector>>();
    for (ArrayList<PVector> hole : holes) {
      ArrayList<PVector> hole2D = project(hole, origin, uAxis, vAxis);
      if (hole.size() >= 3 && (signedArea2D(hole2D) >= 0 ? 1 : -1) == outerWinding) {
        hole = reversedCopy(hole);
        reverseInPlace(hole2D);
      }
      holes3D.add(hole);
      holes2D.add(hole2D);
    }

    for (int h = 0; h < holes3D.size(); h++) {
      ArrayList<PVector> hole = holes3D.get(h);
      ArrayList<PVector> hole2D = holes2D.get(h);
      if (hole.size() < 3) continue;

      int[] bridge = findBridge(merged2D, hole2D, holes2D, h);
      int i = bridge[0];
      int j = bridge[1];

      merged = splice(merged, hole, i, j);
      merged2D = splice(merged2D, hole2D, i, j);
    }

    return merged;
  }

  // Twice the signed area of a 2D loop (the shoelace formula, sign only
  // - never divided by 2, since every caller here only ever compares
  // its sign, not its magnitude): positive for a counterclockwise loop,
  // negative for clockwise, in the (x,y) = (u,v) coordinates project()
  // produces.
  float signedArea2D (ArrayList<PVector> loop2D) {
    float sum = 0;
    int len = loop2D.size();
    for (int i = 0; i < len; i++) {
      PVector p = loop2D.get(i);
      PVector q = loop2D.get((i + 1) % len);
      sum += p.x * q.y - q.x * p.y;
    }
    return sum;
  }

  ArrayList<PVector> reversedCopy (ArrayList<PVector> loop) {
    ArrayList<PVector> copy = new ArrayList<PVector>(loop);
    reverseInPlace(copy);
    return copy;
  }

  void reverseInPlace (ArrayList<PVector> loop) {
    int i = 0, j = loop.size() - 1;
    while (i < j) {
      PVector tmp = loop.get(i);
      loop.set(i, loop.get(j));
      loop.set(j, tmp);
      i++;
      j--;
    }
  }

  // The outer-loop vertex index and hole vertex index (into `merged2D`
  // and `hole2D` respectively) of the shortest bridge that doesn't
  // properly cross any edge of `merged2D` itself or any edge of any
  // loop in `holes2D` (including loops not yet merged, at a higher
  // index than `holeIndex` - a later hole's own bridge must not cut
  // through an earlier one's interior either). Falls back to the
  // shortest bridge overall, crossing or not, on the rare input where
  // no crossing-free bridge exists at all (self-intersecting or
  // overlapping input geometry) - still produces a single closed loop
  // rather than dropping the hole outright, just not guaranteed clean.
  int[] findBridge (ArrayList<PVector> merged2D, ArrayList<PVector> hole2D, ArrayList<ArrayList<PVector>> holes2D, int holeIndex) {
    int bestI = 0;
    int bestJ = 0;
    float bestValidDistSq = Float.POSITIVE_INFINITY;
    float bestAnyDistSq = Float.POSITIVE_INFINITY;
    int bestAnyI = 0;
    int bestAnyJ = 0;

    for (int i = 0; i < merged2D.size(); i++) {
      PVector a = merged2D.get(i);
      for (int j = 0; j < hole2D.size(); j++) {
        PVector b = hole2D.get(j);
        float distSq = sq(a.x - b.x) + sq(a.y - b.y);

        if (distSq < bestAnyDistSq) {
          bestAnyDistSq = distSq;
          bestAnyI = i;
          bestAnyJ = j;
        }

        if (distSq < bestValidDistSq && !bridgeCrossesAnything(a, b, merged2D, hole2D, holes2D, holeIndex)) {
          bestValidDistSq = distSq;
          bestI = i;
          bestJ = j;
        }
      }
    }

    if (bestValidDistSq == Float.POSITIVE_INFINITY) {
      bestI = bestAnyI;
      bestJ = bestAnyJ;
    }
    return new int[] { bestI, bestJ };
  }

  // Whether the candidate bridge a-b properly crosses any edge of
  // `merged2D`, any edge of `hole2D` itself, or any edge of another
  // loop in `holes2D` (every loop except the one at holeIndex, which is
  // `hole2D` itself and already covered). A loop's own edges adjacent
  // to the bridge's own endpoint are naturally never flagged - see
  // segmentsCross()'s own comment on touching endpoints.
  boolean bridgeCrossesAnything (PVector a, PVector b, ArrayList<PVector> merged2D, ArrayList<PVector> hole2D, ArrayList<ArrayList<PVector>> holes2D, int holeIndex) {
    if (loopEdgesCrossSegment(merged2D, a, b)) return true;
    if (loopEdgesCrossSegment(hole2D, a, b)) return true;
    for (int k = 0; k < holes2D.size(); k++) {
      if (k == holeIndex) continue;
      if (loopEdgesCrossSegment(holes2D.get(k), a, b)) return true;
    }
    return false;
  }

  boolean loopEdgesCrossSegment (ArrayList<PVector> loop, PVector a, PVector b) {
    int len = loop.size();
    for (int k = 0; k < len; k++) {
      PVector p1 = loop.get(k);
      PVector p2 = loop.get((k + 1) % len);
      if (segmentsCross(a, b, p1, p2)) return true;
    }
    return false;
  }

  // Standard strict/proper 2D segment-segment crossing test (orientation
  // signs), using each PVector's x/y as the 2D coordinates (z is
  // ignored - callers always pass already-projected points here). Two
  // segments that only touch - sharing an endpoint, or one passing
  // exactly through the other's endpoint - are NOT considered crossing:
  // every bridge candidate necessarily touches its own loop at its own
  // endpoint, and that must never disqualify it.
  boolean segmentsCross (PVector a1, PVector a2, PVector b1, PVector b2) {
    float d1 = cross2(b1, b2, a1);
    float d2 = cross2(b1, b2, a2);
    float d3 = cross2(a1, a2, b1);
    float d4 = cross2(a1, a2, b2);
    boolean straddlesB = (d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0);
    boolean straddlesA = (d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0);
    return straddlesB && straddlesA;
  }

  // 2D cross product of (q-p) and (r-p) - positive when p,q,r turn
  // counterclockwise, negative when clockwise, zero when collinear.
  float cross2 (PVector p, PVector q, PVector r) {
    return (q.x - p.x) * (r.y - p.y) - (q.y - p.y) * (r.x - p.x);
  }

  // Splices `hole`, starting at its own index `holeStart` and going all
  // the way around back to that same point, into `outer` right after
  // index `outerIndex`: outer[0..outerIndex], hole[holeStart..around
  // and back to holeStart], outer[outerIndex] again (closing the return
  // bridge), outer[outerIndex+1..end]. The two bridge edges this
  // produces - outer[outerIndex]->hole[holeStart] and
  // hole[holeStart]->outer[outerIndex] - are exact coincident
  // opposites: a zero-area "slit" that visually disappears once this
  // loop is filled/triangulated as one ordinary polygon.
  ArrayList<PVector> splice (ArrayList<PVector> outer, ArrayList<PVector> hole, int outerIndex, int holeStart) {
    ArrayList<PVector> result = new ArrayList<PVector>();
    for (int k = 0; k <= outerIndex; k++) result.add(outer.get(k));

    int holeLen = hole.size();
    for (int step = 0; step <= holeLen; step++) {
      result.add(hole.get((holeStart + step) % holeLen));
    }

    result.add(outer.get(outerIndex));
    for (int k = outerIndex + 1; k < outer.size(); k++) result.add(outer.get(k));

    return result;
  }

  // The plane normal of a (possibly non-convex, possibly slightly
  // non-planar) polygon loop, via Newell's method - robust to which
  // vertex the loop happens to start at and to mild numerical noise,
  // unlike taking a cross product of just two edges. Returns (0,0,1)
  // for a degenerate loop (fewer than 3 points, or one whose Newell sum
  // is (near) zero, e.g. a straight line) rather than a zero-length
  // vector, so callers always get a usable basis to project into.
  PVector faceNormal (ArrayList<PVector> loop) {
    PVector n = new PVector(0, 0, 0);
    int len = loop.size();
    for (int i = 0; i < len; i++) {
      PVector curr = loop.get(i);
      PVector next = loop.get((i + 1) % len);
      n.x += (curr.y - next.y) * (curr.z + next.z);
      n.y += (curr.z - next.z) * (curr.x + next.x);
      n.z += (curr.x - next.x) * (curr.y + next.y);
    }
    if (n.mag() < 0.00000001) return new PVector(0, 0, 1);
    n.normalize();
    return n;
  }

  // Any one unit vector perpendicular to `normal` - which one, among
  // the full circle of choices, doesn't matter: it only fixes where
  // "u=0" points for the 2D projection below, not the shape of anything
  // projected into it.
  PVector anyPerpendicularUnitVector (PVector normal) {
    PVector reference = (abs(normal.x) < 0.9) ? new PVector(1, 0, 0) : new PVector(0, 1, 0);
    PVector u = PVector.sub(reference, PVector.mult(normal, reference.dot(normal)));
    if (u.mag() < 0.00000001) return new PVector(0, 1, 0); // normal itself was ~reference; any other axis works
    u.normalize();
    return u;
  }

  // `loop`'s own points, projected into the 2D (u,v) coordinates of the
  // plane through `origin` spanned by `uAxis`/`vAxis` - stored as a
  // PVector with x=u, y=v, z=0 (unused) purely so the rest of this
  // class's 2D geometry (segmentsCross(), cross2(), distance) can share
  // the one PVector type rather than needing a separate 2D point class.
  ArrayList<PVector> project (ArrayList<PVector> loop, PVector origin, PVector uAxis, PVector vAxis) {
    ArrayList<PVector> result = new ArrayList<PVector>();
    for (PVector p : loop) {
      PVector rel = PVector.sub(p, origin);
      result.add(new PVector(rel.dot(uAxis), rel.dot(vAxis), 0));
    }
    return result;
  }
}
