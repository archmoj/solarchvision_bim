class Modify3D {

  final static String CLASS_STAMP = "modify3D";

  void selectVertices_fromCurrentSelection () {
    if (currentObjectCategory == ObjectCategory.GROUP) Select3D.convert_Groups_to_Vertices();
    if (currentObjectCategory == ObjectCategory.FACE) Select3D.convert_Faces_to_Vertices();
    if (currentObjectCategory == ObjectCategory.POLYLINE) Select3D.convert_Polylines_to_Vertices();

    Select3D.vertexSelection = sort(Select3D.vertexSelection);
  }

  void selectFacesAndGroups_fromCurrentSelection () {
    if (currentObjectCategory == ObjectCategory.GROUP) {
      Select3D.groupSelection = sort(Select3D.groupSelection);
      Select3D.convert_Groups_to_Faces();
      Select3D.faceSelection = sort(Select3D.faceSelection);
    }

    if (currentObjectCategory == ObjectCategory.FACE) {
      Select3D.faceSelection = sort(Select3D.faceSelection);
      Select3D.convert_Faces_to_Groups();
      Select3D.groupSelection = sort(Select3D.groupSelection);
    }
  }

  boolean isPolymeshCategorySelected () {
    return (currentObjectCategory == ObjectCategory.GROUP) ||
           (currentObjectCategory == ObjectCategory.FACE) ||
           (currentObjectCategory == ObjectCategory.POLYLINE) ||
           (currentObjectCategory == ObjectCategory.VERTEX);
  }

  boolean isGroupOrFaceCategorySelected () {
    return (currentObjectCategory == ObjectCategory.GROUP) ||
           (currentObjectCategory == ObjectCategory.FACE);
  }

  void repositionVertices_Selection () {
    if (currentObjectCategory != ObjectCategory.VERTEX) return;

    beginScene3DChange();

    Select3D.calculate_BoundingBox();

    for (int o = Select3D.vertexSelection.length - 1; o >= 0; o--) {
      int vNo = Select3D.vertexSelection[o];
      allPoints.setX(vNo, Select3D.BoundingBox[1][0]); // center
      allPoints.setY(vNo, Select3D.BoundingBox[1][1]); // center
      allPoints.setZ(vNo, Select3D.BoundingBox[1][2]); // center
    }

    Select3D.calculate_BoundingBox();

    endScene3DChange();
  }

  void compactRemovedVertices (boolean[] toRemove) {
    int n = allVertices.length;
    int[] remap = new int[n];
    ArrayList<float[]> kept = new ArrayList<float[]>();

    int next = 0;
    for (int i = 0; i < n; i++) {
      if (toRemove[i]) {
        remap[i] = -1; // no longer referenced by anything after relabeling above
      } else {
        remap[i] = next;
        kept.add(allVertices[i]);
        next++;
      }
    }

    allVertices = kept.toArray(new float[0][]);

    for (int i = 0; i < allFaces.nodes.length; i++) {
      for (int j = 0; j < allFaces.nodes[i].length; j++) {
        allFaces.nodes[i][j] = remap[allFaces.nodes[i][j]];
      }
    }

    for (int i = 0; i < allPolylines.nodes.length; i++) {
      for (int j = 0; j < allPolylines.nodes[i].length; j++) {
        allPolylines.nodes[i][j] = remap[allPolylines.nodes[i][j]];
      }
    }
  }

  void weldSceneVertices_Selection (float max_distance) {
    if (!isPolymeshCategorySelected()) return;

    beginScene3DChange();

    this.selectVertices_fromCurrentSelection();

    boolean[] toRemove = new boolean[allVertices.length]; // deferred deletions, compacted once at the end

    for (int o = Select3D.vertexSelection.length - 1; o >= 0; o--) {
      int vNo = Select3D.vertexSelection[o];
      int found = -1;

      for (int i = 0; i < allFaces.nodes.length; i++) {
        for (int j = 0; j < allFaces.nodes[i].length; j++) {
          int q = allFaces.nodes[i][j];
          if (q > vNo) { // it is faster than (q != vNo)
            float d = dist(allPoints.getX(q), allPoints.getY(q), allPoints.getZ(q), allPoints.getX(vNo), allPoints.getY(vNo), allPoints.getZ(vNo));
            if (d <= max_distance) {
              allFaces.nodes[i][j] = vNo;
              found = q;
            }
          }
        }
      }

      for (int i = 0; i < allPolylines.nodes.length; i++) {
        for (int j = 0; j < allPolylines.nodes[i].length; j++) {
          int q = allPolylines.nodes[i][j];
          if (q > vNo) { // it is faster than (q != vNo)
            float d = dist(allPoints.getX(q), allPoints.getY(q), allPoints.getZ(q), allPoints.getX(vNo), allPoints.getY(vNo), allPoints.getZ(vNo));
            if (d <= max_distance) {
              allPolylines.nodes[i][j] = vNo;
              found = q;
            }
          }
        }
      }

      if (found != -1) {
        toRemove[found] = true; // splice + index-shift deferred to a single pass below
      }
    }

    this.compactRemovedVertices(toRemove);
    Select3D.deselect_Vertices();

    endScene3DChange();
  }

  void weldObjectsVertices_Selection (float max_distance) {
    if (!isPolymeshCategorySelected()) return;

    beginScene3DChange();

    this.selectVertices_fromCurrentSelection();

    Select3D.convert_Vertices_to_Faces();
    Select3D.convert_Vertices_to_Polylines();

    boolean[] toRemove = new boolean[allVertices.length]; // deferred deletions, compacted once at the end

    for (int o = Select3D.vertexSelection.length - 1; o >= 0; o--) {
      int vNo = Select3D.vertexSelection[o];
      int found = -1;

      for (int m = o - 1; m >= 0; m--) {
        int q = Select3D.vertexSelection[m];
        float d = dist(allPoints.getX(q), allPoints.getY(q), allPoints.getZ(q), allPoints.getX(vNo), allPoints.getY(vNo), allPoints.getZ(vNo));

        if (d <= max_distance) {
          for (int i = 0; i < Select3D.faceSelection.length; i++) {
            int f = Select3D.faceSelection[i];
            for (int j = 0; j < allFaces.nodes[f].length; j++) {
              if (allFaces.nodes[f][j] == q) {
                allFaces.nodes[f][j] = vNo;
                found = q;
              }
            }
          }

          for (int i = 0; i < Select3D.polylineSelection.length; i++) {
            int f = Select3D.polylineSelection[i];
            for (int j = 0; j < allPolylines.nodes[f].length; j++) {
              if (allPolylines.nodes[f][j] == q) {
                allPolylines.nodes[f][j] = vNo;
                found = q;
              }
            }
          }
        }
      }

      if (found != -1) {
        toRemove[found] = true; // splice + index-shift deferred to a single pass below
      }
    }

    this.compactRemovedVertices(toRemove);
    Select3D.deselect_Vertices();

    endScene3DChange();
  }

  void accumulateOffsetFromRing (int[][] ringNodes, int vNo, int o, int _type, float _amount, float[][] Vertex_offsetValues, int[] Vertex_offsetNum) {
    for (int f = 0; f < ringNodes.length; f++) {
      for (int j = 0; j < ringNodes[f].length; j++) {
        if (ringNodes[f][j] != vNo) continue;

        float[][] base_Vertices = new float[ringNodes[f].length][3];
        for (int s = 0; s < ringNodes[f].length; s++) {
          base_Vertices[s][0] = allPoints.getX(ringNodes[f][s]);
          base_Vertices[s][1] = allPoints.getY(ringNodes[f][s]);
          base_Vertices[s][2] = allPoints.getZ(ringNodes[f][s]);
        }

        for (int s = 0; s < base_Vertices.length; s++) {
          int s_next = (s + 1) % base_Vertices.length;
          int s_prev = (s + base_Vertices.length - 1) % base_Vertices.length;

          PVector U = new PVector(base_Vertices[s_next][0] - base_Vertices[s][0], base_Vertices[s_next][1] - base_Vertices[s][1], base_Vertices[s_next][2] - base_Vertices[s][2]);
          PVector V = new PVector(base_Vertices[s_prev][0] - base_Vertices[s][0], base_Vertices[s_prev][1] - base_Vertices[s][1], base_Vertices[s_prev][2] - base_Vertices[s][2]);
          PVector UV = new PVector(0, 0, 0);

          if (_type == 0) UV = U.cross(V);
          if (_type == 1) UV = PVector.add(U, V);

          float[] W = { UV.x, UV.y, UV.z };
          W = funcs.vec3_unit(W);

          Vertex_offsetValues[o][0] += W[0] * _amount;
          Vertex_offsetValues[o][1] += W[1] * _amount;
          Vertex_offsetValues[o][2] += W[2] * _amount;

          Vertex_offsetNum[o] += 1;
        }
      }
    }
  }

  void offsetVertices_Selection (int _type, float _amount) {
    if (!isPolymeshCategorySelected()) return;

    beginScene3DChange();

    this.selectVertices_fromCurrentSelection();

    float[][] Vertex_offsetValues = new float[Select3D.vertexSelection.length][3];
    int[] Vertex_offsetNum = new int[Select3D.vertexSelection.length];

    for (int o = Select3D.vertexSelection.length - 1; o >= 0; o--) {
      int vNo = Select3D.vertexSelection[o];

      accumulateOffsetFromRing(allFaces.nodes, vNo, o, _type, _amount, Vertex_offsetValues, Vertex_offsetNum);
      accumulateOffsetFromRing(allPolylines.nodes, vNo, o, _type, _amount, Vertex_offsetValues, Vertex_offsetNum);

      if (Vertex_offsetNum[o] != 0) {
        Vertex_offsetValues[o][0] /= float(Vertex_offsetNum[o]);
        Vertex_offsetValues[o][1] /= float(Vertex_offsetNum[o]);
        Vertex_offsetValues[o][2] /= float(Vertex_offsetNum[o]);
      }
    }

    for (int o = Select3D.vertexSelection.length - 1; o >= 0; o--) {
      int vNo = Select3D.vertexSelection[o];
      allPoints.move(vNo, Vertex_offsetValues[o][0], Vertex_offsetValues[o][1], Vertex_offsetValues[o][2]);
    }

    selection_changed();
    endScene3DChange();
  }

  // For one occurrence of vNo within a face's or polyline's own node
  // ring, adds its two immediate ring-neighbors (the vertices one step
  // before and one step after it in that ring) to a running position
  // sum/count - the same "walk every ring vNo appears in, across both
  // allFaces.nodes and allPolylines.nodes" shape as
  // accumulateOffsetFromRing() above, just summing actual neighbor
  // POSITIONS here rather than an offset direction. A vertex shared by
  // several faces naturally gets each of its real mesh neighbors added
  // once per face that edge belongs to (twice, for an interior edge
  // shared by two faces) rather than once per unique neighbor - the
  // same "no separate dedup" simplification accumulateOffsetFromRing()
  // already accepts, and for a normal manifold mesh this still weighs
  // every neighbor around a vertex equally, since every one of its
  // edges is shared the same way. n<2 rings (lone points) and the
  // degenerate n==2 case (where "next" and "prev" are the same single
  // other vertex) are both guarded against, the latter so that one
  // two-point edge doesn't count its one real neighbor twice.
  void accumulateRelaxFromRing (int[][] ringNodes, int vNo, int o, float[][] Vertex_relaxSum, int[] Vertex_relaxNum) {
    for (int f = 0; f < ringNodes.length; f++) {
      int n = ringNodes[f].length;
      if (n < 2) continue;

      for (int j = 0; j < n; j++) {
        if (ringNodes[f][j] != vNo) continue;

        int j_next = (j + 1) % n;
        int j_prev = (j + n - 1) % n;
        int nbrNext = ringNodes[f][j_next];
        int nbrPrev = ringNodes[f][j_prev];

        if (nbrNext != vNo) {
          Vertex_relaxSum[o][0] += allPoints.getX(nbrNext);
          Vertex_relaxSum[o][1] += allPoints.getY(nbrNext);
          Vertex_relaxSum[o][2] += allPoints.getZ(nbrNext);
          Vertex_relaxNum[o] += 1;
        }
        if (nbrPrev != vNo && nbrPrev != nbrNext) {
          Vertex_relaxSum[o][0] += allPoints.getX(nbrPrev);
          Vertex_relaxSum[o][1] += allPoints.getY(nbrPrev);
          Vertex_relaxSum[o][2] += allPoints.getZ(nbrPrev);
          Vertex_relaxNum[o] += 1;
        }
      }
    }
  }

  // Moves every selected vertex a fraction (User3D.modifierRelaxAmount,
  // 0..1) of the way toward the average position of its own real mesh
  // neighbors (from every face and polyline edge touching it anywhere
  // in the scene, not just within the current selection - same "find
  // real adjacency, not just what's selected" reasoning capHoles_
  // Selection() and mergeCoplanarFaces_Selection() already use) -
  // softening blocky/faceted geometry (terrain, a rough mesh) without
  // changing topology at all, purely a per-vertex position blend. All
  // neighbor sums are gathered from a full read-only pass BEFORE any
  // vertex in the selection is actually moved, so relaxing one selected
  // vertex never uses an already-moved neighbor's NEW position within
  // the same pass - the result doesn't depend on vertex iteration
  // order, same "snapshot first, write once" reasoning thickenFaces_
  // Selection()'s own shared-vertex offset pass uses. A vertex with no
  // edges at all (Vertex_relaxNum==0) has nothing to relax toward and
  // is left exactly where it is. Re-running the command applies another
  // pass on top of the last, same "click again for more" idea as any
  // other repeatable modifier in this menu.
  void relaxVertices_Selection () {
    if (!isPolymeshCategorySelected()) return;

    beginScene3DChange();

    this.selectVertices_fromCurrentSelection();

    float amount = User3D.modifierRelaxAmount;

    float[][] Vertex_relaxSum = new float[Select3D.vertexSelection.length][3];
    int[] Vertex_relaxNum = new int[Select3D.vertexSelection.length];

    for (int o = Select3D.vertexSelection.length - 1; o >= 0; o--) {
      int vNo = Select3D.vertexSelection[o];
      accumulateRelaxFromRing(allFaces.nodes, vNo, o, Vertex_relaxSum, Vertex_relaxNum);
      accumulateRelaxFromRing(allPolylines.nodes, vNo, o, Vertex_relaxSum, Vertex_relaxNum);
    }

    for (int o = Select3D.vertexSelection.length - 1; o >= 0; o--) {
      if (Vertex_relaxNum[o] == 0) continue;

      int vNo = Select3D.vertexSelection[o];
      float avgX = Vertex_relaxSum[o][0] / Vertex_relaxNum[o];
      float avgY = Vertex_relaxSum[o][1] / Vertex_relaxNum[o];
      float avgZ = Vertex_relaxSum[o][2] / Vertex_relaxNum[o];

      float oldX = allPoints.getX(vNo);
      float oldY = allPoints.getY(vNo);
      float oldZ = allPoints.getZ(vNo);

      allPoints.move(vNo, (avgX - oldX) * amount, (avgY - oldY) * amount, (avgZ - oldZ) * amount);
    }

    selection_changed();
    endScene3DChange();
  }

  // Passive Solar Touch: a single bounded step (User3D.
  // modifierPassiveSolarTouchStep meters, default 0.25) that pushes
  // each selected vertex out along, or pulls it in against, the average
  // direction to its own real mesh neighbors - the same ring-walking
  // neighbor-gathering relaxVertices_Selection() above uses, just read
  // as a direction to step along rather than a position to blend
  // toward. Which way each vertex goes is decided by its own net solar
  // response (TOTAL_COMPARISON, from solarComparisonScore() -
  // solarComparisonScore.pde): a net-beneficial vertex steps OUT, away
  // from its neighbors, to expose more of what's already working; a
  // net-harmful vertex steps IN, toward its neighbors, to self-shade.
  // This is intentionally just one step forward per call, not a solve
  // for "the" optimal shape - there's no single optimal shape, and how
  // many times to apply this (and when to stop) is left to the
  // architect, same as a repeatable Relax/Skew/Twist/Bend pass. Named
  // for what it actually does today - a touch driven by the PASSIVE
  // solar metric specifically (vertexSolar_TotalComparisonAt(), below,
  // reads VertexSolar_amounts[Impact_PASSIVE], never [Impact_ACTIVE] -
  // the app's other, direct-radiation metric, used elsewhere for
  // "Active Shade"/"Passive Shade") - rather than "form-finding", which
  // is reserved for a possible later, broader process that combines
  // this push/pull with other factors (structural, wind, etc.) rather
  // than solar alone.
  //
  // A vertex is treated as a real edge/corner, and left exactly where
  // it is, when the FACES meeting at it aren't roughly coplanar - their
  // own per-corner normals (collectFaceNormals_atVertex(), below)
  // differ by more than User3D.modifierPassiveSolarTouchAngle degrees
  // (default 45) between any two of them. This is a crease-angle test,
  // not a check on the neighbor-direction vectors themselves: an
  // ordinary INTERIOR vertex of a flat tessellated grid (several quads
  // sharing it, each contributing the same face normal) has neighbor
  // directions that point every which way - opposite ring-neighbors
  // are always ~180 degrees apart on any regular grid, by construction
  // - so comparing those directions against each other (an earlier,
  // now-corrected version of this check did exactly that) flagged
  // nearly every interior grid vertex as an "edge", freezing a whole
  // tessellated face solid. Comparing face NORMALS instead correctly
  // leaves a flat region's own normals all pointing the same way (no
  // crease, moves normally) while still catching a genuine edge or
  // corner, where the faces on either side meet at a real angle. A
  // vertex with fewer than 2 faces has nothing to compare and is never
  // frozen by this check alone. A vertex with no real neighbors at all
  // (ring-wise, across both faces and polylines) is left untouched
  // too, the same way relaxVertices_Selection() leaves one.
  //
  // calculate_VertexSolar_array() (calculateVertexSolarArray.pde) is
  // the app's existing, expensive, ray-traced per-sample-point solar
  // calculation - normally sampled at tessellated sub-face points
  // rather than at real mesh vertices (see overlay3D.pde's
  // computeFaceTessellation() for the same tessellation math).
  // VertexSolar_forceNoTessellation (globalVariables.pde) is set for
  // the one direct call this function makes, so every sample point
  // lands exactly on its own face's real corner vertices, then cleared
  // again immediately after - nothing else observes the override, and
  // it's never left set across frames.
  //
  // Each real vertex can be a corner of several faces, so (with
  // tessellation forced to 0) it can appear as a sample point more than
  // once - vertexSolar_TotalComparisonAt() averages TOTAL_COMPARISON
  // across every occurrence at that exact position, the same "no
  // separate dedup, every occurrence counted" simplification
  // accumulateRelaxFromRing() already accepts for neighbor positions.
  //
  // Because self-shading between vertices goes stale the moment any of
  // them move, VertexSolar_rebuild_array is flagged at the end so the
  // NEXT call (whether this modifier again, or the normal Vertex_Solar
  // shading pass) recomputes against the new geometry - this call's own
  // moves are already based on whatever was baked coming in.
  //
  // Every selected vertex's own step (direction, sign, and whether it's
  // frozen) is worked out from a full read-only pass over the ORIGINAL,
  // pre-move positions first, and only then actually applied, in a
  // second pass - the same "snapshot first, write once" shape
  // relaxVertices_Selection() above uses, and for the same reason: two
  // selected vertices can be real mesh neighbors of each other, and
  // without this, whichever one happened to be processed first would
  // already have moved by the time the second one reads its position
  // for its own direction/freeze decision - making the result depend
  // on selection iteration order, not just on geometry and solar data.
  void passiveSolarTouchVertices_Selection () {
    if (!isPolymeshCategorySelected()) return;

    this.selectVertices_fromCurrentSelection();
    if (Select3D.vertexSelection.length == 0) return;

    VertexSolar_forceNoTessellation = true;
    calculate_VertexSolar_array();
    VertexSolar_forceNoTessellation = false;

    beginScene3DChange();

    float step = User3D.modifierPassiveSolarTouchStep;
    float maxAngle = radians(User3D.modifierPassiveSolarTouchAngle);

    boolean[] Vertex_shouldMove = new boolean[Select3D.vertexSelection.length];
    float[][] Vertex_moveBy = new float[Select3D.vertexSelection.length][3];

    for (int o = Select3D.vertexSelection.length - 1; o >= 0; o--) {
      int vNo = Select3D.vertexSelection[o];

      float oldX = allPoints.getX(vNo);
      float oldY = allPoints.getY(vNo);
      float oldZ = allPoints.getZ(vNo);

      FloatList normX = new FloatList();
      FloatList normY = new FloatList();
      FloatList normZ = new FloatList();
      collectFaceNormals_atVertex(allFaces.nodes, vNo, normX, normY, normZ);

      if (normX.size() == 0) continue; // vertex isn't part of any face - no normal to step along

      if (maxPairwiseAngle(normX, normY, normZ) > maxAngle) continue; // the faces meeting here aren't coplanar enough - a real edge/corner, frozen

      float[] avgNormal = new float[3];
      if (!averageNormalizedDirection(normX, normY, normZ, avgNormal)) continue; // face normals cancel out exactly - no stable direction to step along

      float solarValue = vertexSolar_TotalComparisonAt(oldX, oldY, oldZ);

      float[] moveBy = new float[3];
      if (!passiveSolarTouchMoveFor(avgNormal[0], avgNormal[1], avgNormal[2], solarValue, step, moveBy)) continue;

      Vertex_shouldMove[o] = true;
      Vertex_moveBy[o] = moveBy;
    }

    for (int o = Select3D.vertexSelection.length - 1; o >= 0; o--) {
      if (!Vertex_shouldMove[o]) continue;

      int vNo = Select3D.vertexSelection[o];
      allPoints.move(vNo, Vertex_moveBy[o][0], Vertex_moveBy[o][1], Vertex_moveBy[o][2]);
    }

    VertexSolar_rebuild_array = true;
    selection_changed();
    endScene3DChange();
  }

  // Averages a set of vectors (e.g. the per-face normals collected by
  // collectFaceNormals_atVertex()) and normalizes the result to a unit
  // vector, writing it into outDir[0..2]. Returns false (leaving outDir
  // untouched) when the vectors cancel out exactly - no stable average
  // direction to report. Pulled out of passiveSolarTouchVertices_
  // Selection() so this piece of its math can be unit-tested on its
  // own: that function's own real call to calculate_VertexSolar_array()
  // needs a live PGraphics surface to run at all (see
  // SolarArraySmokeTest.java's own comment), so a bare test instance
  // can never exercise this averaging step through the full function.
  boolean averageNormalizedDirection (FloatList dx, FloatList dy, FloatList dz, float[] outDir) {
    float avgX = 0, avgY = 0, avgZ = 0;
    for (int i = dx.size() - 1; i >= 0; i--) {
      avgX += dx.get(i);
      avgY += dy.get(i);
      avgZ += dz.get(i);
    }
    float avgLen = sqrt(avgX * avgX + avgY * avgY + avgZ * avgZ);
    if (avgLen < 0.00001) return false;

    outDir[0] = avgX / avgLen;
    outDir[1] = avgY / avgLen;
    outDir[2] = avgZ / avgLen;
    return true;
  }

  // Decides whether a vertex should move under Passive Solar Touch, and
  // by how much, given its own solar comparison value and the already-
  // averaged, unit-length outward face normal at that vertex (from
  // averageNormalizedDirection() above). Returns false (leaving moveBy
  // untouched) unless solar exposure here is harmful (solarValue <= 0)
  // - a beneficial vertex is left untouched for now rather than
  // stepping OUT away from it; stepping out may come back later as a
  // separate option, but harmful-only step-IN is the better default.
  // Moving by the NEGATED outward normal is what steps the vertex IN -
  // receding inward, away from the sun. Pulled out for the same
  // testability reason as averageNormalizedDirection() above.
  boolean passiveSolarTouchMoveFor (float normAvgX, float normAvgY, float normAvgZ, float solarValue, float step, float[] moveBy) {
    if (is_undefined(solarValue) || solarValue == 0) return false; // no solar signal at this vertex - nothing to decide a direction from
    if (solarValue > 0) return false; // beneficial - left untouched (no step-out, for now)

    moveBy[0] = -normAvgX * step;
    moveBy[1] = -normAvgY * step;
    moveBy[2] = -normAvgZ * step;
    return true;
  }

  // Same ring-walking traversal accumulateRelaxFromRing() uses, but
  // collects a unit DIRECTION vector (from vNo toward each real
  // neighbor) per ring occurrence instead of summing raw neighbor
  // positions. No longer used by passiveSolarTouchVertices_Selection()
  // itself - it now steps along the averaged FACE NORMAL instead (see
  // collectFaceNormals_atVertex() below and passiveSolarTouchMoveFor()
  // above) - but kept as a standalone, independently tested helper in
  // case a neighbor-direction-based step (e.g. a future "step out"
  // option) wants it again.
  void collectNeighborDirections_fromRing (int[][] ringNodes, int vNo, float oldX, float oldY, float oldZ, FloatList dirX, FloatList dirY, FloatList dirZ) {
    for (int f = 0; f < ringNodes.length; f++) {
      int n = ringNodes[f].length;
      if (n < 2) continue;

      for (int j = 0; j < n; j++) {
        if (ringNodes[f][j] != vNo) continue;

        int j_next = (j + 1) % n;
        int j_prev = (j + n - 1) % n;
        int nbrNext = ringNodes[f][j_next];
        int nbrPrev = ringNodes[f][j_prev];

        if (nbrNext != vNo) appendUnitDirection(oldX, oldY, oldZ, nbrNext, dirX, dirY, dirZ);
        if (nbrPrev != vNo && nbrPrev != nbrNext) appendUnitDirection(oldX, oldY, oldZ, nbrPrev, dirX, dirY, dirZ);
      }
    }
  }

  void appendUnitDirection (float oldX, float oldY, float oldZ, int nbrVNo, FloatList dirX, FloatList dirY, FloatList dirZ) {
    float dx = allPoints.getX(nbrVNo) - oldX;
    float dy = allPoints.getY(nbrVNo) - oldY;
    float dz = allPoints.getZ(nbrVNo) - oldZ;
    float len = sqrt(dx * dx + dy * dy + dz * dz);
    if (len < 0.00001) return; // coincident neighbor - no direction to contribute
    dirX.append(dx / len);
    dirY.append(dy / len);
    dirZ.append(dz / len);
  }

  // For every face in faceNodes that includes vNo (at whatever corner
  // position it occupies there), computes that face's own unit normal
  // AT that corner and appends it to nX/nY/nZ - the same (next-this)
  // cross (prev-this), then normalize, formula already used throughout
  // the app for a per-face-corner normal (faces.pde's own per-vertex
  // normal-line display, and the identical cross-product shape in
  // calculateVertexSolarArray.pde). Polylines have no area and so no
  // normal, so unlike collectNeighborDirections_fromRing above, this
  // only ever looks at allFaces.nodes. passiveSolarTouchVertices_
  // Selection() uses these results TWICE: the SPREAD across them (via
  // maxPairwiseAngle, below) decides whether a vertex sits in a flat
  // region (every face sharing it points the same way) or on a real
  // edge/corner (they don't) - see that function's own comment for why
  // this, and not the ring-neighbor DIRECTIONS collectNeighborDirections_
  // fromRing collects, is the right thing to compare for that; and their
  // AVERAGE (via averageNormalizedDirection(), above) is the outward
  // direction passiveSolarTouchMoveFor() steps the vertex opposite of.
  // A degenerate corner (collinear neighbors, cross product ~0) is
  // skipped rather than appending a meaningless direction.
  void collectFaceNormals_atVertex (int[][] faceNodes, int vNo, FloatList nX, FloatList nY, FloatList nZ) {
    float thisX = allPoints.getX(vNo);
    float thisY = allPoints.getY(vNo);
    float thisZ = allPoints.getZ(vNo);

    for (int f = 0; f < faceNodes.length; f++) {
      int n = faceNodes[f].length;
      if (n < 3) continue; // need a real corner (two distinct edges) to have a normal at all

      for (int j = 0; j < n; j++) {
        if (faceNodes[f][j] != vNo) continue;

        int j_next = (j + 1) % n;
        int j_prev = (j + n - 1) % n;
        int nextVNo = faceNodes[f][j_next];
        int prevVNo = faceNodes[f][j_prev];

        PVector U = new PVector(allPoints.getX(nextVNo) - thisX, allPoints.getY(nextVNo) - thisY, allPoints.getZ(nextVNo) - thisZ);
        PVector V = new PVector(allPoints.getX(prevVNo) - thisX, allPoints.getY(prevVNo) - thisY, allPoints.getZ(prevVNo) - thisZ);
        PVector UV = U.cross(V);

        float len = sqrt((UV.x * UV.x) + (UV.y * UV.y) + (UV.z * UV.z));
        if (len < 0.00001) continue; // collinear corner - no well-defined normal here

        nX.append(UV.x / len);
        nY.append(UV.y / len);
        nZ.append(UV.z / len);
      }
    }
  }

  // Largest angle (radians) between any two of the given unit vectors -
  // used both to detect a vertex sitting at a real edge/corner (via its
  // face normals' own spread, collectFaceNormals_atVertex() above) and,
  // more generally, as a plain "how spread out is this set of unit
  // vectors" measure. 0 or 1 vectors can't diverge from anything, so
  // this returns 0 for those.
  float maxPairwiseAngle (FloatList dirX, FloatList dirY, FloatList dirZ) {
    float maxAngle = 0;
    for (int i = dirX.size() - 1; i >= 0; i--) {
      for (int j = i - 1; j >= 0; j--) {
        float dot = (dirX.get(i) * dirX.get(j)) + (dirY.get(i) * dirY.get(j)) + (dirZ.get(i) * dirZ.get(j));
        dot = constrain(dot, -1, 1);
        float angle = acos(dot);
        if (angle > maxAngle) maxAngle = angle;
      }
    }
    return maxAngle;
  }

  // Looks up the all-days-total solar COMPARISON score (solarComparisonScore.pde)
  // at a given position, by scanning VertexSolar_XYZ for every sample
  // point whose own position (the first of its now/prev/next triple -
  // see calculateVertexSolarArray.pde) exactly matches x/y/z, and
  // averaging VertexSolar_amounts[Impact_PASSIVE][0] (index 0 is the
  // all-days total, per calculate_VertexSolar_array()'s own layout)
  // across every match. With VertexSolar_forceNoTessellation set, each
  // face contributes its own real corner vertices as sample points, so
  // a vertex shared by several faces matches once per face - no
  // separate dedup, same simplification accumulateRelaxFromRing() above
  // already accepts for shared-vertex neighbor positions. Returns
  // FLOAT_undefined if nothing matches or the array hasn't been built.
  float vertexSolar_TotalComparisonAt (float x, float y, float z) {
    if ((VertexSolar_XYZ == null) || (VertexSolar_amounts == null)) return FLOAT_undefined;
    if (VertexSolar_amounts[Impact_PASSIVE].length == 0) return FLOAT_undefined;

    float[] comparisons = VertexSolar_amounts[Impact_PASSIVE][0];
    if ((comparisons == null) || (comparisons.length != VertexSolar_XYZ.length)) return FLOAT_undefined;

    float sum = 0;
    int num = 0;
    for (int q = 0; q < VertexSolar_XYZ.length; q++) {
      float[] row = VertexSolar_XYZ[q];
      if ((row[0] == x) && (row[1] == y) && (row[2] == z)) {
        float v = comparisons[q];
        if (is_defined(v)) {
          sum += v;
          num += 1;
        }
      }
    }
    if (num == 0) return FLOAT_undefined;
    return sum / num;
  }

  void skewVertices_Selection () {
    skewVertices_Selection(1);
  }

  // The "Skew" tool mode's own Shift+Up ("Increase Tool Parameter",
  // direction +1) / Shift+Down ("Decrease Tool Parameter", direction
  // -1) nudge - see WIN3D.incrementParameter(). Negating the 3 factors
  // for direction -1 is enough to make backward the inverse of forward
  // for Skew (unlike Twist below), since dx/dy here are each a plain
  // linear combination of y0/z0 with no sequential, order-dependent
  // sub-steps to also reverse.
  void skewVertices_Selection (int direction) {
    if (!isPolymeshCategorySelected()) return;

    beginScene3DChange();

    this.selectVertices_fromCurrentSelection();

    int n = Select3D.vertexSelection.length;

    // Snapshot-first: the pivot is the selection's own bounding-box
    // center (Select3D.vertexIdsExtents(), shared with twistVertices_
    // Selection() and the Skew/Twist overlay gizmo), found from a
    // read-only pass before anything moves - so the shear is centered
    // on what's selected (and doesn't also translate it), independent
    // of any object-level pivot-alignment setting elsewhere in Select3D.
    float[] extents = Select3D.vertexIdsExtents(Select3D.vertexSelection);
    float cy = (extents[1] + extents[4]) / 2;
    float cz = (extents[2] + extents[5]) / 2;

    for (int o = 0; o < n; o++) {
      int vNo = Select3D.vertexSelection[o];
      float y = allPoints.getY(vNo);
      float z = allPoints.getZ(vNo);

      float[] d = skewDelta(direction, y - cy, z - cz);

      allPoints.move(vNo, d[0], d[1], 0);
    }

    selection_changed();
    endScene3DChange();
  }

  // The {dx,dy} skewVertices_Selection()'s own loop used to compute
  // inline, now shared with the overlay gizmo's own deformed-preview
  // cage (Overlay3D.draw()'s previewModifierDeformation() call) - one
  // source on purpose, so the preview can never silently show a
  // different shear than committing the operation would actually
  // produce (the same reasoning vertexIdsExtents()'s own comment gives
  // for the pivot itself). previewModifierDeformation() always wants
  // the plain forward shear, so it goes through this 2-arg overload,
  // which is just the 3-arg one with direction fixed at +1.
  float[] skewDelta (float y0, float z0) {
    return skewDelta(1, y0, z0);
  }

  float[] skewDelta (int direction, float y0, float z0) {
    float dx = direction * (User3D.modifierSkewXY * y0 + User3D.modifierSkewXZ * z0);
    float dy = direction * (User3D.modifierSkewYZ * z0);
    return new float[]{ dx, dy };
  }

  void twistVertices_Selection () {
    twistVertices_Selection(1);
  }

  // See skewVertices_Selection(int)'s own comment for the Shift+Up/Down
  // direction this feeds. Unlike Skew/Bend, direction -1 here ALSO
  // reverses the 3 rotations' own application order (see twistedPoint()'s
  // own comment for why that's the part that actually makes backward a
  // meaningful inverse of forward, not just negating the angles).
  void twistVertices_Selection (int direction) {
    if (!isPolymeshCategorySelected()) return;

    beginScene3DChange();

    this.selectVertices_fromCurrentSelection();

    int n = Select3D.vertexSelection.length;

    // Pivot: the selection's own bounding-box center
    // (Select3D.vertexIdsExtents(), shared with skewVertices_Selection()
    // and the Skew/Twist overlay gizmo), found in a read-only pass
    // before anything moves - same reasoning as skewVertices_Selection(),
    // and reused here too rather than any object-level pivot-alignment
    // setting.
    float[] extents = Select3D.vertexIdsExtents(Select3D.vertexSelection);
    float cx = (extents[0] + extents[3]) / 2;
    float cy = (extents[1] + extents[4]) / 2;
    float cz = (extents[2] + extents[5]) / 2;

    for (int o = 0; o < n; o++) {
      int vNo = Select3D.vertexSelection[o];
      float oldX = allPoints.getX(vNo);
      float oldY = allPoints.getY(vNo);
      float oldZ = allPoints.getZ(vNo);

      float x = oldX - cx;
      float y = oldY - cy;
      float z = oldZ - cz;

      float[] afterZ = twistedPoint(direction, x, y, z);

      float newX = cx + afterZ[0];
      float newY = cy + afterZ[1];
      float newZ = cz + afterZ[2];

      allPoints.move(vNo, newX - oldX, newY - oldY, newZ - oldZ);
    }

    selection_changed();
    endScene3DChange();
  }

  // The rotation twistVertices_Selection()'s own loop used to compute
  // inline, now shared with the overlay gizmo's own deformed-preview
  // cage - see skewDelta()'s own comment for why. Each axis's own
  // rotation amount comes from the point's ORIGINAL (pre-twist) offset
  // along that same axis, then the three rotations are applied in a
  // fixed X -> Y -> Z order to the evolving point, the same composition
  // order Select3D's own object-level rotX/rotY/rotZ triple uses.
  // Returns the new PIVOT-RELATIVE point (not a delta - a rotation has
  // no additive "delta" the way skew/bend's shear/arc do).
  // previewModifierDeformation() always wants the plain forward twist,
  // so it goes through this 3-arg overload (direction fixed at +1).
  float[] twistedPoint (float x0, float y0, float z0) {
    return twistedPoint(1, x0, y0, z0);
  }

  // direction -1 (the Shift+Down/"backward" nudge) negates all three
  // angles AND applies them in the reverse order (Z, then Y, then X)
  // instead of forward's X, then Y, then Z. Negating alone would not be
  // a meaningful inverse here: rotation composition doesn't commute, so
  // undoing A-then-B-then-C means applying C^-1, then B^-1, then A^-1 -
  // reversing the order is what makes "backward" the rotations' own
  // inverse, the same way it would for any other composed rotation.
  float[] twistedPoint (int direction, float x0, float y0, float z0) {
    float rX = radians(direction * User3D.modifierTwistX * x0);
    float rY = radians(direction * User3D.modifierTwistY * y0);
    float rZ = radians(direction * User3D.modifierTwistZ * z0);

    if (direction < 0) {
      float[] afterZ = Rotate3D.rotateAroundVector(x0, y0, z0, rZ, 2);
      float[] afterY = Rotate3D.rotateAroundVector(afterZ[0], afterZ[1], afterZ[2], rY, 1);
      float[] afterX = Rotate3D.rotateAroundVector(afterY[0], afterY[1], afterY[2], rX, 0);
      return afterX;
    }

    float[] afterX = Rotate3D.rotateAroundVector(x0, y0, z0, rX, 0);
    float[] afterY = Rotate3D.rotateAroundVector(afterX[0], afterX[1], afterX[2], rY, 1);
    float[] afterZ = Rotate3D.rotateAroundVector(afterY[0], afterY[1], afterY[2], rZ, 2);

    return afterZ;
  }

  // The third of the Twist/Skew/Bend trio - a true circular arc rather
  // than Twist's in-place rotation or Skew's linear shear, but kept at
  // the same level of simplicity as both: each of the three factors
  // reads ONLY its own one axis-pair's original offset and writes ONLY
  // its own one axis, independently and additively, the same shape
  // skewVertices_Selection()'s own dx/dy formula already uses (no
  // arc-length foreshortening of the parametrizing axis itself, and no
  // cross-section rotation along the arc's own tangent - both of which
  // a "real" bend modifier would add, but neither of which Skew or
  // Twist attempt either for their own analogous simplifications).
  //
  // bendOffset()'s own r*(1-cos(k*offset)) is the classic circular-arc
  // sagitta formula: treating the bend as a rod curving into a circle
  // of radius r = 1/k (k in radians per meter - degPerMeter converted
  // via radians()), a point at distance `offset` along the rod's own
  // original straight length sweeps arc angle k*offset around that
  // circle's center, and r*(1-cos(...)) is exactly how far it lands
  // from the rod's original straight line, perpendicular to it.
  // degPerMeter == 0 is handled as its own explicit no-op (0 contribution)
  // rather than falling through 1/radians(0) - the same divide-by-zero
  // every other value-modifier here already guards against its own
  // degenerate input.
  float bendOffset (float degPerMeter, float offset) {
    if (degPerMeter == 0) return 0;

    float k = radians(degPerMeter);
    float r = 1 / k;
    return r * (1 - cos(k * offset));
  }

  void bendVertices_Selection () {
    bendVertices_Selection(1);
  }

  // See skewVertices_Selection(int)'s own comment for the Shift+Up/Down
  // direction this feeds, and for why negating the 3 factors (no order
  // to reverse here either, same as Skew) is enough.
  void bendVertices_Selection (int direction) {
    if (!isPolymeshCategorySelected()) return;

    beginScene3DChange();

    this.selectVertices_fromCurrentSelection();

    int n = Select3D.vertexSelection.length;

    // Pivot: the selection's own bounding-box center on Y/Z only - same
    // scope as skewVertices_Selection() (dx/dy below never read x0
    // either), via Select3D.vertexIdsExtents(), shared with Skew/Twist
    // and the overlay gizmo - see skewVertices_Selection()'s own comment
    // for the full reasoning.
    float[] extents = Select3D.vertexIdsExtents(Select3D.vertexSelection);
    float cy = (extents[1] + extents[4]) / 2;
    float cz = (extents[2] + extents[5]) / 2;

    for (int o = 0; o < n; o++) {
      int vNo = Select3D.vertexSelection[o];
      float y = allPoints.getY(vNo);
      float z = allPoints.getZ(vNo);

      float[] d = bendDelta(direction, y - cy, z - cz);

      allPoints.move(vNo, d[0], d[1], 0);
    }

    selection_changed();
    endScene3DChange();
  }

  // The {dx,dy} bendVertices_Selection()'s own loop used to compute
  // inline, now shared with the overlay gizmo's own deformed-preview
  // cage - see skewDelta()'s own comment for why.
  // previewModifierDeformation() always wants the plain forward bend,
  // so it goes through this 2-arg overload (direction fixed at +1).
  float[] bendDelta (float y0, float z0) {
    return bendDelta(1, y0, z0);
  }

  float[] bendDelta (int direction, float y0, float z0) {
    float dx = bendOffset(direction * User3D.modifierBendXY, y0) + bendOffset(direction * User3D.modifierBendXZ, z0);
    float dy = bendOffset(direction * User3D.modifierBendYZ, z0);
    return new float[]{ dx, dy };
  }

  // Previews what Skew, then Twist, then Bend, applied in that order
  // with whatever values currently sit in User3D's nine modifier
  // fields, would do to one pivot-relative point - exactly what three
  // sequential real commits (Skew Selected Vertices, then Twist
  // Selected Vertices, then Bend Selected Vertices) would produce,
  // since each of those three, applied for real, always reads the
  // vertex's then-CURRENT position as its own "original" (none of them
  // remembers an earlier, pre-chain position). Used only by the overlay
  // gizmo's deformed-preview cage - none of the three apply methods
  // above call this themselves, since each of them deliberately applies
  // ONLY its own factor when invoked on its own, ignoring whatever the
  // other two modifiers' fields currently hold.
  float[] previewModifierDeformation (float x0, float y0, float z0) {
    float[] skew = skewDelta(y0, z0);
    float x1 = x0 + skew[0];
    float y1 = y0 + skew[1];
    float z1 = z0;

    float[] twisted = twistedPoint(x1, y1, z1);
    float x2 = twisted[0];
    float y2 = twisted[1];
    float z2 = twisted[2];

    float[] bend = bendDelta(y2, z2);
    float x3 = x2 + bend[0];
    float y3 = y2 + bend[1];
    float z3 = z2;

    return new float[]{ x3, y3, z3 };
  }

  void separateVertices_Selection () {
    if (!isPolymeshCategorySelected()) return;

    beginScene3DChange();

    this.selectVertices_fromCurrentSelection();

    for (int o = Select3D.vertexSelection.length - 1; o >= 0; o--) {
      int vNo = Select3D.vertexSelection[o];

      for (int i = 0; i < allFaces.nodes.length; i++) {
        for (int j = 0; j < allFaces.nodes[i].length; j++) {
          if (allFaces.nodes[i][j] == vNo) {
            allFaces.nodes[i][j] = allPoints.create(allPoints.getX(vNo), allPoints.getY(vNo), allPoints.getZ(vNo));
          }
        }
      }

      for (int i = 0; i < allPolylines.nodes.length; i++) {
        for (int j = 0; j < allPolylines.nodes[i].length; j++) {
          if (allPolylines.nodes[i][j] == vNo) {
            allPolylines.nodes[i][j] = allPoints.create(allPoints.getX(vNo), allPoints.getY(vNo), allPoints.getZ(vNo));
          }
        }
      }
    }

    Select3D.deselect_Vertices();
    endScene3DChange();
  }

  int[] remove_item_from_primary_list (int q, int[] primary_list) {
    // to avoid processing the faces twice they should be deleted from the list.
    int[] result = new int[primary_list.length - 1];
    int w = 0;
    for (int i = 0; i < primary_list.length; i++) {
      if (i == q) continue;
      result[w++] = (i > q) ? (primary_list[i] - 1) : primary_list[i];
    }
    return result;
  }

  boolean isFaceInGroupRange (int f, int OBJ_ID) {
    int startFace = allGroups.getStart_Face(OBJ_ID);
    int endFace = allGroups.getStop_Face(OBJ_ID);
    return (startFace <= f) && (f <= endFace);
  }

  int findOwningGroupId (int f) {
    for (int i = 0; i < Select3D.groupSelection.length; i++) {
      int OBJ_ID = Select3D.groupSelection[i];
      if (isFaceInGroupRange(f, OBJ_ID)) return OBJ_ID;
    }
    return -1;
  }

  float[][] faceBaseVertices (int f) {
    int n = allFaces.nodes[f].length;
    float[][] base_Vertices = new float[n][3];
    for (int i = 0; i < n; i++) {
      base_Vertices[i][0] = allPoints.getX(allFaces.nodes[f][i]);
      base_Vertices[i][1] = allPoints.getY(allFaces.nodes[f][i]);
      base_Vertices[i][2] = allPoints.getZ(allFaces.nodes[f][i]);
    }
    return base_Vertices;
  }

  float[] faceCentroid (float[][] base_Vertices) {
    float[] G = { 0, 0, 0 };
    for (int i = 0; i < base_Vertices.length; i++) {
      for (int j = 0; j < 3; j++) {
        G[j] += base_Vertices[i][j] / float(base_Vertices.length);
      }
    }
    return G;
  }

  void spliceFaceWithNewFaces (int f, ArrayList<int[]> midNodes, ArrayList<int[]> midOptions) {
    int[][] startList_Faces_nodes = (int[][]) subset(allFaces.nodes, 0, f);
    int[][] endList_Faces_nodes = (int[][]) subset(allFaces.nodes, f + 1);

    int[][] startList_Faces_options = (int[][]) subset(allFaces.options, 0, f);
    int[][] endList_Faces_options = (int[][]) subset(allFaces.options, f + 1);

    int[][] midList_Faces_nodes = midNodes.toArray(new int[0][]);
    int[][] midList_Faces_options = midOptions.toArray(new int[0][]);

    startList_Faces_nodes = (int[][]) concat(startList_Faces_nodes, midList_Faces_nodes);
    startList_Faces_options = (int[][]) concat(startList_Faces_options, midList_Faces_options);

    allFaces.nodes = (int[][]) concat(startList_Faces_nodes, endList_Faces_nodes);
    allFaces.options = (int[][]) concat(startList_Faces_options, endList_Faces_options);
  }

  void appendNewFaceSelection (ArrayList<Integer> newfaceSelection_L) {
    if (newfaceSelection_L.size() == 0) return;
    int[] newfaceSelection = new int[newfaceSelection_L.size()];
    for (int i = 0; i < newfaceSelection.length; i++) newfaceSelection[i] = newfaceSelection_L.get(i);
    Select3D.faceSelection = (int[]) concat(Select3D.faceSelection, newfaceSelection);
  }

  void insertCornerOpenings_Selection () {
    if (!isGroupOrFaceCategorySelected()) return;

    beginScene3DChange();

    this.selectFacesAndGroups_fromCurrentSelection();
    int[] primary_list = Select3D.faceSelection;

    for (int o = Select3D.groupSelection.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.groupSelection[o];

      for (int q = primary_list.length - 1; q >= 0; q--) {
        int f = primary_list[q];
        if (!isFaceInGroupRange(f, OBJ_ID)) continue;

        allGroups.inserted_nFaces(OBJ_ID, f, allFaces.nodes[f].length); // because adding the faces also changes the end pointer of the same object

        ArrayList<int[]> midList_Faces_nodes_L = new ArrayList<int[]>();
        midList_Faces_nodes_L.add(allFaces.nodes[f]); // same reference as before - mutated in place below
        ArrayList<int[]> midList_Faces_options_L = new ArrayList<int[]>();
        midList_Faces_options_L.add(allFaces.options[f]);

        float[][] base_Vertices = faceBaseVertices(f);
        float[] G_face = faceCentroid(base_Vertices);

        float[][] new_Vertices = new float[allFaces.nodes[f].length][3];
        for (int i = 0; i < allFaces.nodes[f].length; i++) {
          for (int j = 0; j < 3; j++) {
            new_Vertices[i][j] = pow(User3D.modifierOpeningArea, 0.5) * base_Vertices[i][j] + (1 - pow(User3D.modifierOpeningArea, 0.5)) * G_face[j];
          }
        }

        int[] new_vertexSelection = new int[allFaces.nodes[f].length];
        for (int s = 0; s < allFaces.nodes[f].length; s++) {
          new_vertexSelection[s] = allPoints.create(new_Vertices[s][0], new_Vertices[s][1], new_Vertices[s][2]);
        }

        current_Material = allFaces.getMaterial(f);
        current_Tessellation = allFaces.getTessellation(f);
        current_Layer = allFaces.getLayer(f);
        current_Visibility = allFaces.getVisibility(f);

        for (int s = 0; s < allFaces.nodes[f].length; s++) {
          int s_next = (s + 1) % allFaces.nodes[f].length;

          int[] newFace_nodes = { new_vertexSelection[s], allFaces.nodes[f][s], allFaces.nodes[f][s_next], new_vertexSelection[s_next] };
          int[] newFace_options = { current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed };

          midList_Faces_nodes_L.add(newFace_nodes);
          midList_Faces_options_L.add(newFace_options);
        }

        // modifying the base face to shape the openning
        for (int s = 0; s < allFaces.nodes[f].length; s++) {
          allFaces.nodes[f][s] = new_vertexSelection[s];
        }

        spliceFaceWithNewFaces(f, midList_Faces_nodes_L, midList_Faces_options_L);
        primary_list = this.remove_item_from_primary_list(q, primary_list);
      }
    }

    switch_category(ObjectCategory.FACE);
    endScene3DChange();
  }

  void insertParallelOpenings_Selection () {
    if (!isGroupOrFaceCategorySelected()) return;

    beginScene3DChange();

    this.selectFacesAndGroups_fromCurrentSelection();
    int[] primary_list = Select3D.faceSelection;

    for (int o = Select3D.groupSelection.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.groupSelection[o];

      for (int q = primary_list.length - 1; q >= 0; q--) {
        int f = primary_list[q];
        if (!isFaceInGroupRange(f, OBJ_ID)) continue;

        allGroups.inserted_nFaces(OBJ_ID, f, 2 * allFaces.nodes[f].length); // because adding the faces also changes the end pointer of the same object

        ArrayList<int[]> midList_Faces_nodes_L = new ArrayList<int[]>();
        midList_Faces_nodes_L.add(allFaces.nodes[f]); // same reference as before - mutated in place below
        ArrayList<int[]> midList_Faces_options_L = new ArrayList<int[]>();
        midList_Faces_options_L.add(allFaces.options[f]);

        float[][] base_Vertices = faceBaseVertices(f);
        float[] G_face = faceCentroid(base_Vertices);

        float[][] new_A_EdgeVertices = new float[allFaces.nodes[f].length][3];
        float[][] new_B_EdgeVertices = new float[allFaces.nodes[f].length][3];
        float[][] new_CenterVertices = new float[allFaces.nodes[f].length][3];

        for (int s = 0; s < allFaces.nodes[f].length; s++) {
          int s_prev = (s + allFaces.nodes[f].length - 1) % allFaces.nodes[f].length;
          int s_next = (s + 1) % allFaces.nodes[f].length;

          for (int j = 0; j < 3; j++) {
            new_A_EdgeVertices[s][j] = User3D.modifierOpeningDeviation * base_Vertices[s][j] + (1 - User3D.modifierOpeningDeviation) * 0.5 * (base_Vertices[s_prev][j] + base_Vertices[s][j]);
            new_B_EdgeVertices[s][j] = User3D.modifierOpeningDeviation * base_Vertices[s][j] + (1 - User3D.modifierOpeningDeviation) * 0.5 * (base_Vertices[s_next][j] + base_Vertices[s][j]);
            new_CenterVertices[s][j] = pow(User3D.modifierOpeningArea, 0.5) * base_Vertices[s][j] + (1 - pow(User3D.modifierOpeningArea, 0.5)) * G_face[j];
          }
        }

        int[] new_A_EdgevertexSelection = new int[allFaces.nodes[f].length]; // on the edge (1/3)
        int[] new_B_EdgevertexSelection = new int[allFaces.nodes[f].length]; // on the other edge (2/3)
        int[] new_CentervertexSelection = new int[allFaces.nodes[f].length]; // in the center

        for (int s = 0; s < allFaces.nodes[f].length; s++) {
          new_A_EdgevertexSelection[s] = allPoints.create(new_A_EdgeVertices[s][0], new_A_EdgeVertices[s][1], new_A_EdgeVertices[s][2]);
          new_B_EdgevertexSelection[s] = allPoints.create(new_B_EdgeVertices[s][0], new_B_EdgeVertices[s][1], new_B_EdgeVertices[s][2]);
          new_CentervertexSelection[s] = allPoints.create(new_CenterVertices[s][0], new_CenterVertices[s][1], new_CenterVertices[s][2]);
        }

        current_Material = allFaces.getMaterial(f);
        current_Tessellation = allFaces.getTessellation(f);
        current_Layer = allFaces.getLayer(f);
        current_Visibility = allFaces.getVisibility(f);

        for (int s = 0; s < allFaces.nodes[f].length; s++) {
          int s_next = (s + 1) % allFaces.nodes[f].length;

          int[] newFace1_nodes = { allFaces.nodes[f][s], new_B_EdgevertexSelection[s], new_CentervertexSelection[s], new_A_EdgevertexSelection[s] };
          int[] newFace1_options = { current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed };
          midList_Faces_nodes_L.add(newFace1_nodes);
          midList_Faces_options_L.add(newFace1_options);

          int[] newFace2_nodes = { new_B_EdgevertexSelection[s], new_A_EdgevertexSelection[s_next], new_CentervertexSelection[s_next], new_CentervertexSelection[s] };
          int[] newFace2_options = { current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed };
          midList_Faces_nodes_L.add(newFace2_nodes);
          midList_Faces_options_L.add(newFace2_options);
        }

        // modifying the base face to shape the openning
        for (int s = 0; s < allFaces.nodes[f].length; s++) {
          allFaces.nodes[f][s] = new_CentervertexSelection[s];
        }

        spliceFaceWithNewFaces(f, midList_Faces_nodes_L, midList_Faces_options_L);
        primary_list = this.remove_item_from_primary_list(q, primary_list);
      }
    }

    switch_category(ObjectCategory.FACE);
    endScene3DChange();
  }

  // Where line1 (P1 + t*D1) and line2 (P2 + t*D2) cross, assuming they're
  // coplanar (as any two edges - or their inward offsets - of the same
  // flat face always are) and not parallel. Returns null for parallel/
  // near-collinear lines (no unique crossing point) rather than dividing
  // by ~0. Derived from cross(P1 + t*D1 - P2, D2) = 0 (true exactly when
  // P1 + t*D1 lies on line2): writing Q = P2 - P1, that's
  // cross(t*D1 - Q, D2) = 0, i.e. t*cross(D1, D2) = cross(Q, D2); dotting
  // both sides with cross(D1, D2) turns that into the scalar equation
  // solved for t below.
  float[] lineIntersection3D (float[] P1, float[] D1, float[] P2, float[] D2) {
    PVector pD1 = new PVector(D1[0], D1[1], D1[2]);
    PVector pD2 = new PVector(D2[0], D2[1], D2[2]);
    PVector cross12 = pD1.cross(pD2);
    float denom = cross12.magSq();
    if (denom < FLOAT_tiny * FLOAT_tiny) return null; // parallel / collinear - no unique intersection

    PVector Q = new PVector(P2[0] - P1[0], P2[1] - P1[1], P2[2] - P1[2]);
    PVector crossQD2 = Q.cross(pD2);
    float t = crossQD2.dot(cross12) / denom;

    return new float[] { P1[0] + t * D1[0], P1[1] + t * D1[1], P1[2] + t * D1[2] };
  }

  // Shrinks each selected face inward by User3D.modifierInsetDepth, a
  // plain in-plane distance rather than Insert Parallel Openings' own
  // area-ratio shrink, and walls the gap with one clean quad per edge -
  // not that tool's own 2-quads-per-edge bevel ring. Each new inner
  // corner is found the standard "polygon inset" way: offset every edge
  // inward, in the face's own plane, by modifierInsetDepth, then
  // intersect each pair of edges meeting at a corner to find where that
  // corner's own two offset edges now cross. (A corner where both edges
  // run the same direction - a redundant straight-through vertex - has
  // no such crossing; lineIntersection3D() returns null for it, and the
  // corner is just nudged inward by the averaged offset direction
  // instead.) Like Insert Parallel Openings, the original face becomes
  // the new, smaller inner face in place, and the ring is spliced in
  // around it - so this can self-intersect on a concave face, or on any
  // face asked to inset further than its own narrowest point, the same
  // way a plain straight-edge-offset inset always can; it isn't guarded
  // against here.
  void insetFaces_Selection () {
    if (!isGroupOrFaceCategorySelected()) return;

    beginScene3DChange();

    this.selectFacesAndGroups_fromCurrentSelection();
    int[] primary_list = Select3D.faceSelection;

    for (int o = Select3D.groupSelection.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.groupSelection[o];

      for (int q = primary_list.length - 1; q >= 0; q--) {
        int f = primary_list[q];
        if (!isFaceInGroupRange(f, OBJ_ID)) continue;

        int n = allFaces.nodes[f].length;
        if (n < 3) {
          primary_list = this.remove_item_from_primary_list(q, primary_list);
          continue;
        }

        insetAndRecedeFace(f, OBJ_ID, User3D.modifierInsetDepth, 0); // insetStep=0: flat, coplanar inset - no recede
        primary_list = this.remove_item_from_primary_list(q, primary_list);
      }
    }

    switch_category(ObjectCategory.FACE);
    endScene3DChange();
  }

  // Shrinks face f inward, in its own plane, by insetDepth - exactly
  // insetFaces_Selection()'s own inward-perpendicular-offset-then-
  // intersect math (see that function's own header comment for how and
  // why), unchanged - then, if insetStep is nonzero, additionally
  // RECEDES every one of the resulting inner-ring vertices by insetStep
  // along the face's own NEGATED outward normal, pushing the new inner
  // face into the solid. The untouched original boundary and the now-
  // receded inner face are joined by the same ring of border quads
  // either way; with insetStep=0 those border quads stay flat and
  // coplanar (reproducing insetFaces_Selection()'s own result exactly),
  // and with insetStep>0 they become slanted "reveal" walls - shared by
  // insetFaces_Selection() above and passiveSolarInsetFaces_Selection()
  // below so this ~70 lines of 3D math exists in exactly one place.
  void insetAndRecedeFace (int f, int OBJ_ID, float insetDepth, float insetStep) {
    int n = allFaces.nodes[f].length;

    allGroups.inserted_nFaces(OBJ_ID, f, n); // because adding the faces also changes the end pointer of the same object

    ArrayList<int[]> midList_Faces_nodes_L = new ArrayList<int[]>();
    midList_Faces_nodes_L.add(allFaces.nodes[f]); // same reference as before - mutated in place below
    ArrayList<int[]> midList_Faces_options_L = new ArrayList<int[]>();
    midList_Faces_options_L.add(allFaces.options[f]);

    float[][] base_Vertices = faceBaseVertices(f);
    float[] faceNormal = faceNormalUnit(base_Vertices);

    float[][] edgeDir = new float[n][];
    float[][] inwardPerp = new float[n][];
    for (int s = 0; s < n; s++) {
      int s_next = (s + 1) % n;
      float[] d = { base_Vertices[s_next][0] - base_Vertices[s][0], base_Vertices[s_next][1] - base_Vertices[s][1], base_Vertices[s_next][2] - base_Vertices[s][2] };
      edgeDir[s] = funcs.vec3_unit(d);

      PVector N = new PVector(faceNormal[0], faceNormal[1], faceNormal[2]);
      PVector D = new PVector(edgeDir[s][0], edgeDir[s][1], edgeDir[s][2]);
      PVector perp = N.cross(D); // in-plane, pointing inward - see insetFaces_Selection()'s own comment for why
      inwardPerp[s] = funcs.vec3_unit(new float[] { perp.x, perp.y, perp.z });
    }

    int[] innerVertexSelection = new int[n];
    for (int s = 0; s < n; s++) {
      int s_prev = (s + n - 1) % n;

      float[] P1 = { base_Vertices[s_prev][0] + inwardPerp[s_prev][0] * insetDepth, base_Vertices[s_prev][1] + inwardPerp[s_prev][1] * insetDepth, base_Vertices[s_prev][2] + inwardPerp[s_prev][2] * insetDepth };
      float[] P2 = { base_Vertices[s][0] + inwardPerp[s][0] * insetDepth, base_Vertices[s][1] + inwardPerp[s][1] * insetDepth, base_Vertices[s][2] + inwardPerp[s][2] * insetDepth };

      float[] innerPoint = lineIntersection3D(P1, edgeDir[s_prev], P2, edgeDir[s]);
      if (innerPoint == null) { // a straight-through vertex (both edges run the same direction) - no crossing to find, so just nudge the corner itself inward
        float[] avg = { inwardPerp[s_prev][0] + inwardPerp[s][0], inwardPerp[s_prev][1] + inwardPerp[s][1], inwardPerp[s_prev][2] + inwardPerp[s][2] };
        float[] avgUnit = funcs.vec3_unit(avg);
        innerPoint = new float[] { base_Vertices[s][0] + avgUnit[0] * insetDepth, base_Vertices[s][1] + avgUnit[1] * insetDepth, base_Vertices[s][2] + avgUnit[2] * insetDepth };
      }

      // Recede the new inner-ring point into the solid, away from the
      // sun, by insetStep along the NEGATED outward normal - the same
      // "move opposite the outward normal" convention passiveSolarTouch
      // MoveFor() uses. insetStep=0 is a no-op here, leaving the inset
      // perfectly flat/coplanar.
      innerPoint[0] -= faceNormal[0] * insetStep;
      innerPoint[1] -= faceNormal[1] * insetStep;
      innerPoint[2] -= faceNormal[2] * insetStep;

      innerVertexSelection[s] = allPoints.create(innerPoint[0], innerPoint[1], innerPoint[2]);
    }

    current_Material = allFaces.getMaterial(f);
    current_Tessellation = allFaces.getTessellation(f);
    current_Layer = allFaces.getLayer(f);
    current_Visibility = allFaces.getVisibility(f);

    for (int s = 0; s < n; s++) {
      int s_next = (s + 1) % n;

      int[] ringFace_nodes = { allFaces.nodes[f][s], allFaces.nodes[f][s_next], innerVertexSelection[s_next], innerVertexSelection[s] };
      int[] ringFace_options = { current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed };
      midList_Faces_nodes_L.add(ringFace_nodes);
      midList_Faces_options_L.add(ringFace_options);
    }

    // modifying the base face to shrink it down to the new inner boundary
    for (int s = 0; s < n; s++) {
      allFaces.nodes[f][s] = innerVertexSelection[s];
    }

    spliceFaceWithNewFaces(f, midList_Faces_nodes_L, midList_Faces_options_L);
  }

  // Averages vertexSolar_TotalComparisonAt() across every one of face
  // f's own vertices. Any single undefined vertex disqualifies the
  // whole face outright - returns FLOAT_undefined rather than quietly
  // averaging over just the defined ones - since passiveSolarInsetFaces_
  // Selection() below treats "disqualified" and "beneficial/neutral on
  // average" the same way (left untouched), but the caller still needs
  // to tell the two apart from "harmful on average" (a negative result).
  float faceSolarAverage (int f) {
    int n = allFaces.nodes[f].length;
    float sum = 0;

    for (int s = 0; s < n; s++) {
      int vNo = allFaces.nodes[f][s];
      float v = vertexSolar_TotalComparisonAt(allPoints.getX(vNo), allPoints.getY(vNo), allPoints.getZ(vNo));
      if (is_undefined(v)) return FLOAT_undefined;
      sum += v;
    }

    return sum / n;
  }

  // "Passive Solar Touch"'s own sister function, operating on selected
  // FACES rather than vertices - its root motivation is the same small
  // architectural lever against a building's own contribution to global
  // warming: a face that reads as harmful ON AVERAGE across its own
  // vertices (see faceSolarAverage() above - any single undefined
  // vertex disqualifies the whole face, same as a beneficial/neutral
  // average does) gets recessed away from the sun, lowering its solar
  // heat gain and so the cooling load behind it. Unlike a vertex, which
  // can straddle several faces at different angles, a face has exactly
  // one unambiguous normal - so there's no freeze/edge-angle check here
  // the way Passive Solar Touch needs one. The actual geometry (shrink
  // in-plane, then recede the new inner face along the normal) is
  // insetAndRecedeFace() above, shared with insetFaces_Selection().
  void passiveSolarInsetFaces_Selection () {
    if (!isGroupOrFaceCategorySelected()) return;

    this.selectFacesAndGroups_fromCurrentSelection();
    if (Select3D.faceSelection.length == 0) return;

    VertexSolar_forceNoTessellation = true;
    calculate_VertexSolar_array();
    VertexSolar_forceNoTessellation = false;

    beginScene3DChange();

    int[] primary_list = Select3D.faceSelection;

    for (int o = Select3D.groupSelection.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.groupSelection[o];

      for (int q = primary_list.length - 1; q >= 0; q--) {
        int f = primary_list[q];
        if (!isFaceInGroupRange(f, OBJ_ID)) continue;

        int n = allFaces.nodes[f].length;
        if (n < 3) {
          primary_list = this.remove_item_from_primary_list(q, primary_list);
          continue;
        }

        float avgSolar = faceSolarAverage(f);
        if (is_undefined(avgSolar) || avgSolar >= 0) { // disqualified, or beneficial/neutral on average - left untouched, no step-out
          primary_list = this.remove_item_from_primary_list(q, primary_list);
          continue;
        }

        insetAndRecedeFace(f, OBJ_ID, User3D.modifierPassiveSolarInsetDepth, User3D.modifierPassiveSolarInsetStep);
        primary_list = this.remove_item_from_primary_list(q, primary_list);
      }
    }

    VertexSolar_rebuild_array = true;
    selection_changed();
    switch_category(ObjectCategory.FACE);
    endScene3DChange();
  }

  void insertRotatedOpenings_Selection () {
    if (!isGroupOrFaceCategorySelected()) return;

    beginScene3DChange();

    this.selectFacesAndGroups_fromCurrentSelection();
    int[] primary_list = Select3D.faceSelection;

    for (int o = Select3D.groupSelection.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.groupSelection[o];

      for (int q = primary_list.length - 1; q >= 0; q--) {
        int f = primary_list[q];
        if (!isFaceInGroupRange(f, OBJ_ID)) continue;

        allGroups.inserted_nFaces(OBJ_ID, f, allFaces.nodes[f].length); // because adding the faces also changes the end pointer of the same object

        ArrayList<int[]> midList_Faces_nodes_L = new ArrayList<int[]>();
        midList_Faces_nodes_L.add(allFaces.nodes[f]); // same reference as before - mutated in place below
        ArrayList<int[]> midList_Faces_options_L = new ArrayList<int[]>();
        midList_Faces_options_L.add(allFaces.options[f]);

        float[][] base_Vertices = faceBaseVertices(f);
        float[] G_face = faceCentroid(base_Vertices);

        float[][] new_EdgeVertices = new float[allFaces.nodes[f].length][3];
        float[][] new_CenterVertices = new float[allFaces.nodes[f].length][3];

        for (int s = 0; s < allFaces.nodes[f].length; s++) {
          int s_prev = (s + allFaces.nodes[f].length - 1) % allFaces.nodes[f].length;

          for (int j = 0; j < 3; j++) {
            new_EdgeVertices[s][j] = User3D.modifierOpeningDeviation * base_Vertices[s][j] + (1 - User3D.modifierOpeningDeviation) * base_Vertices[s_prev][j];
            new_CenterVertices[s][j] = pow(User3D.modifierOpeningArea, 0.5) * new_EdgeVertices[s][j] + (1 - pow(User3D.modifierOpeningArea, 0.5)) * G_face[j];
          }
        }

        int[] new_EdgevertexSelection = new int[allFaces.nodes[f].length]; // on the edge
        int[] new_CentervertexSelection = new int[allFaces.nodes[f].length]; // in the center

        for (int s = 0; s < allFaces.nodes[f].length; s++) {
          new_EdgevertexSelection[s] = allPoints.create(new_EdgeVertices[s][0], new_EdgeVertices[s][1], new_EdgeVertices[s][2]);
          new_CentervertexSelection[s] = allPoints.create(new_CenterVertices[s][0], new_CenterVertices[s][1], new_CenterVertices[s][2]);
        }

        current_Material = allFaces.getMaterial(f);
        current_Tessellation = allFaces.getTessellation(f);
        current_Layer = allFaces.getLayer(f);
        current_Visibility = allFaces.getVisibility(f);

        for (int s = 0; s < allFaces.nodes[f].length; s++) {
          int s_next = (s + 1) % allFaces.nodes[f].length;

          int[] newFace_nodes = { new_EdgevertexSelection[s], allFaces.nodes[f][s], new_EdgevertexSelection[s_next], new_CentervertexSelection[s_next], new_CentervertexSelection[s] };
          int[] newFace_options = { current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed };

          midList_Faces_nodes_L.add(newFace_nodes);
          midList_Faces_options_L.add(newFace_options);
        }

        // modifying the base face to match new center face
        for (int s = 0; s < allFaces.nodes[f].length; s++) {
          allFaces.nodes[f][s] = new_CentervertexSelection[s];
        }

        spliceFaceWithNewFaces(f, midList_Faces_nodes_L, midList_Faces_options_L);
        primary_list = this.remove_item_from_primary_list(q, primary_list);
      }
    }

    switch_category(ObjectCategory.FACE);
    endScene3DChange();
  }

  void insertEdgeOpenings_Selection () {
    if (!isGroupOrFaceCategorySelected()) return;

    beginScene3DChange();

    this.selectFacesAndGroups_fromCurrentSelection();
    int[] primary_list = Select3D.faceSelection;

    for (int o = Select3D.groupSelection.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.groupSelection[o];

      for (int q = primary_list.length - 1; q >= 0; q--) {
        int f = primary_list[q];
        if (!isFaceInGroupRange(f, OBJ_ID)) continue;

        allGroups.inserted_nFaces(OBJ_ID, f, allFaces.nodes[f].length); // because adding the faces also changes the end pointer of the same object

        ArrayList<int[]> midList_Faces_nodes_L = new ArrayList<int[]>();
        midList_Faces_nodes_L.add(allFaces.nodes[f]); // same reference as before - mutated in place below
        ArrayList<int[]> midList_Faces_options_L = new ArrayList<int[]>();
        midList_Faces_options_L.add(allFaces.options[f]);

        float[][] base_Vertices = faceBaseVertices(f);

        float[][] new_EdgeVertices = new float[allFaces.nodes[f].length][3];
        for (int s = 0; s < allFaces.nodes[f].length; s++) {
          int s_prev = (s + allFaces.nodes[f].length - 1) % allFaces.nodes[f].length;
          for (int j = 0; j < 3; j++) {
            new_EdgeVertices[s][j] = User3D.modifierOpeningDeviation * base_Vertices[s][j] + (1 - User3D.modifierOpeningDeviation) * base_Vertices[s_prev][j];
          }
        }

        int[] new_EdgevertexSelection = new int[allFaces.nodes[f].length]; // on the edge
        for (int s = 0; s < allFaces.nodes[f].length; s++) {
          new_EdgevertexSelection[s] = allPoints.create(new_EdgeVertices[s][0], new_EdgeVertices[s][1], new_EdgeVertices[s][2]);
        }

        current_Material = allFaces.getMaterial(f);
        current_Tessellation = allFaces.getTessellation(f);
        current_Layer = allFaces.getLayer(f);
        current_Visibility = allFaces.getVisibility(f);

        for (int s = 0; s < allFaces.nodes[f].length; s++) {
          int s_next = (s + 1) % allFaces.nodes[f].length;

          int[] newFace_nodes = { new_EdgevertexSelection[s], allFaces.nodes[f][s], new_EdgevertexSelection[s_next] };
          int[] newFace_options = { current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed };

          midList_Faces_nodes_L.add(newFace_nodes);
          midList_Faces_options_L.add(newFace_options);
        }

        // modifying the base face to match new center face
        for (int s = 0; s < allFaces.nodes[f].length; s++) {
          allFaces.nodes[f][s] = new_EdgevertexSelection[s];
        }

        spliceFaceWithNewFaces(f, midList_Faces_nodes_L, midList_Faces_options_L);
        primary_list = this.remove_item_from_primary_list(q, primary_list);
      }
    }

    switch_category(ObjectCategory.FACE);
    endScene3DChange();
  }

  void tessellateRowsColumns_Selection () {
    if (!isGroupOrFaceCategorySelected()) return;

    beginScene3DChange();

    this.selectFacesAndGroups_fromCurrentSelection();
    ArrayList<Integer> newfaceSelection_L = new ArrayList<Integer>();

    // Walk Select3D.faceSelection itself, largest index first. allGroups.inserted_nFaces() shifts
    // Select3D.faceSelection in place with the correct amount as we go, so (unlike the old detached
    // "primary_list" copy with its hard-coded -1 shift) the indices read here are always
    // up to date. newfaceSelection_L is a separate list, so we shift it ourselves below.
    for (int q = Select3D.faceSelection.length - 1; q >= 0; q--) {
      int f = Select3D.faceSelection[q];
      if (allFaces.nodes[f].length != 4) continue;

      int OBJ_ID = this.findOwningGroupId(f);
      if (OBJ_ID == -1) continue;

      int nNewFaces = User3D.modifierTessellateColumns * User3D.modifierTessellateRows;
      int netShift = nNewFaces - 1;

      allGroups.inserted_nFaces(OBJ_ID, f, netShift); // because adding the faces also changes the end pointer of the same object

      ArrayList<int[]> midList_Faces_nodes_L = new ArrayList<int[]>();
        ArrayList<int[]> midList_Faces_options_L = new ArrayList<int[]>();

        float[][] base_Vertices = faceBaseVertices(f);

        float[][] new_EdgeVertices = new float[(User3D.modifierTessellateColumns + 1) * (User3D.modifierTessellateRows + 1)][3];
        for (int i = 0; i <= User3D.modifierTessellateColumns; i++) {
          for (int j = 0; j <= User3D.modifierTessellateRows; j++) {
            int s = i * (User3D.modifierTessellateRows + 1) + j;
            for (int k = 0; k < 3; k++) {
              float u = i / float(User3D.modifierTessellateColumns);
              float v = j / float(User3D.modifierTessellateRows);
              new_EdgeVertices[s][k] = funcs.bilinear(base_Vertices[0][k], base_Vertices[1][k], base_Vertices[2][k], base_Vertices[3][k], u, v);
            }
          }
        }

        int[] new_EdgevertexSelection = new int[(User3D.modifierTessellateColumns + 1) * (User3D.modifierTessellateRows + 1)]; // on the edge
        for (int i = 0; i <= User3D.modifierTessellateColumns; i++) {
          for (int j = 0; j <= User3D.modifierTessellateRows; j++) {
            int s = i * (User3D.modifierTessellateRows + 1) + j;

            if ((i == 0) && (j == 0)) {
              new_EdgevertexSelection[s] = allFaces.nodes[f][0];
            } else if ((i == User3D.modifierTessellateColumns) && (j == 0)) {
              new_EdgevertexSelection[s] = allFaces.nodes[f][1];
            } else if ((i == User3D.modifierTessellateColumns) && (j == User3D.modifierTessellateRows)) {
              new_EdgevertexSelection[s] = allFaces.nodes[f][2];
            } else if ((i == 0) && (j == User3D.modifierTessellateRows)) {
              new_EdgevertexSelection[s] = allFaces.nodes[f][3];
            } else {
              // getOrCreateVertex_atPosition() (defined alongside
              // tessellateRectangular_Selection() below, for the same
              // reason): every grid point that isn't one of the face's
              // own 4 original corners - including the ones running
              // along its own outer edges, not just interior points -
              // would otherwise get a brand-new, duplicate vertex each
              // time a neighboring face (or a later re-run of this same
              // command) computes that identical position for itself.
              new_EdgevertexSelection[s] = getOrCreateVertex_atPosition(new_EdgeVertices[s][0], new_EdgeVertices[s][1], new_EdgeVertices[s][2]);
            }
          }
        }

        current_Material = allFaces.getMaterial(f);
        current_Tessellation = allFaces.getTessellation(f);
        current_Layer = allFaces.getLayer(f);
        current_Visibility = allFaces.getVisibility(f);

        for (int i = 0; i < User3D.modifierTessellateColumns; i++) {
          for (int j = 0; j < User3D.modifierTessellateRows; j++) {
            int s = i * User3D.modifierTessellateRows + j; // number of face

            int s00 = i * (User3D.modifierTessellateRows + 1) + j;
            int s01 = s00 + 1;
            int s10 = s00 + (User3D.modifierTessellateRows + 1);
            int s11 = s00 + (User3D.modifierTessellateRows + 1) + 1;

            int[] newFace_nodes = { new_EdgevertexSelection[s00], new_EdgevertexSelection[s10], new_EdgevertexSelection[s11], new_EdgevertexSelection[s01] };
            int[] newFace_options = { current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed };

            midList_Faces_nodes_L.add(newFace_nodes);
            midList_Faces_options_L.add(newFace_options);
        }
      }

      spliceFaceWithNewFaces(f, midList_Faces_nodes_L, midList_Faces_options_L);

      // Keep any already-recorded new-face indices from previously processed (larger-index)
      // faces in sync with this splice, then queue up this face's own new pieces.
      for (int i = 0; i < newfaceSelection_L.size(); i++) {
        if (newfaceSelection_L.get(i) > f) newfaceSelection_L.set(i, newfaceSelection_L.get(i) + netShift);
      }
      for (int s = 1; s < nNewFaces; s++) { // the first tessellated face (s == 0) replaces the base face
        newfaceSelection_L.add(f + s);
      }
    }

    appendNewFaceSelection(newfaceSelection_L);
    switch_category(ObjectCategory.FACE);
    endScene3DChange();
  }

  // Returns an existing vertex already sitting exactly at (x, y, z), if
  // there is one, instead of creating a new one - used by
  // tessellateRectangular_Selection() below so a new edge-midpoint (or
  // center) vertex it's about to add gets shared with whichever
  // neighboring face already has - or will have - a vertex at that
  // same spot, rather than silently duplicating it.
  int getOrCreateVertex_atPosition (float x, float y, float z) {
    int existing = findVertex_atPosition(x, y, z);
    if (existing != -1) return existing;
    return allPoints.create(x, y, z);
  }

  // Linear scan for an existing vertex at an EXACT position match - not
  // a within-threshold match (like Modify3D.weldObjectsVertices_
  // Selection()'s own User3D.modifierWeldThreshold check, select3D.pde),
  // because there's nothing approximate to tolerate here: two faces
  // sharing an edge always compute that edge's midpoint the same way,
  // from the SAME two corner vertices' current coordinates (0.5*A +
  // 0.5*B), so the float arithmetic lands on bit-identical results on
  // both sides. Same exact-match-by-linear-scan shape as SHADE.
  // findID_SolarImpact_atXYZ (shade.pde) uses for the same reason.
  // O(vertex count) per call - fine at this app's usual model sizes,
  // worth revisiting only if tessellating a very large mesh gets slow.
  int findVertex_atPosition (float x, float y, float z) {
    for (int v = allPoints.getLength() - 1; v >= 0; v--) {
      if ((allPoints.getX(v) == x) && (allPoints.getY(v) == y) && (allPoints.getZ(v) == z)) return v;
    }
    return -1;
  }

  void tessellateRectangular_Selection () {
    if (!isGroupOrFaceCategorySelected()) return;

    beginScene3DChange();

    this.selectFacesAndGroups_fromCurrentSelection();
    ArrayList<Integer> newfaceSelection_L = new ArrayList<Integer>();

    for (int q = Select3D.faceSelection.length - 1; q >= 0; q--) {
      int f = Select3D.faceSelection[q];
      int OBJ_ID = this.findOwningGroupId(f);
      if (OBJ_ID == -1) continue;

      int n = allFaces.nodes[f].length;
      int netShift = n - 1;

      allGroups.inserted_nFaces(OBJ_ID, f, netShift); // because adding the faces also changes the end pointer of the same object

      ArrayList<int[]> midList_Faces_nodes_L = new ArrayList<int[]>();
      ArrayList<int[]> midList_Faces_options_L = new ArrayList<int[]>();

      float[][] base_Vertices = faceBaseVertices(f);
      float[] G_face = faceCentroid(base_Vertices);

      float[][] new_EdgeVertices = new float[n][3];
      for (int s = 0; s < n; s++) {
        int s_prev = (s + n - 1) % n;
        for (int j = 0; j < 3; j++) {
          new_EdgeVertices[s][j] = 0.5 * base_Vertices[s][j] + 0.5 * base_Vertices[s_prev][j];
        }
      }

      int[] new_EdgevertexSelection = new int[n]; // on the edge
      for (int s = 0; s < n; s++) {
        // getOrCreateVertex_atPosition(), not a bare allPoints.create():
        // this same edge midpoint is about to be computed AGAIN, from
        // the same two corner positions, by whichever neighboring face
        // shares this edge - either already processed earlier in this
        // very call (another currently-selected face), or on some
        // earlier call that already tessellated the other side of this
        // edge (re-running this command on an already-tessellated
        // selection). Without reuse, each side would create its own,
        // separate vertex sitting on the exact same position - visually
        // identical but not actually connected, breaking real mesh
        // connectivity across what looks like one continuous grid.
        new_EdgevertexSelection[s] = getOrCreateVertex_atPosition(new_EdgeVertices[s][0], new_EdgeVertices[s][1], new_EdgeVertices[s][2]);
      }

      int new_CenterVertex_number = getOrCreateVertex_atPosition(G_face[0], G_face[1], G_face[2]); // at the center - reuse is essentially never hit here in practice (two distinct faces' centroids coinciding is a near-impossible coincidence), but kept consistent with the edge-midpoint logic above rather than special-cased away

      current_Material = allFaces.getMaterial(f);
      current_Tessellation = allFaces.getTessellation(f);
      current_Layer = allFaces.getLayer(f);
      current_Visibility = allFaces.getVisibility(f);

      for (int s = 0; s < n; s++) {
        int s_next = (s + 1) % n;

        int[] newFace_nodes = { new_EdgevertexSelection[s], allFaces.nodes[f][s], new_EdgevertexSelection[s_next], new_CenterVertex_number };
        int[] newFace_options = { current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed };

        midList_Faces_nodes_L.add(newFace_nodes);
        midList_Faces_options_L.add(newFace_options);
      }

      spliceFaceWithNewFaces(f, midList_Faces_nodes_L, midList_Faces_options_L);

      // Keep any already-recorded new-face indices from previously processed (larger-index)
      // faces in sync with this splice, then queue up this face's own new pieces.
      for (int i = 0; i < newfaceSelection_L.size(); i++) {
        if (newfaceSelection_L.get(i) > f) newfaceSelection_L.set(i, newfaceSelection_L.get(i) + netShift);
      }
      for (int s = 1; s < n; s++) { // the first tessellated face (s == 0) replaces the base face
        newfaceSelection_L.add(f + s);
      }
    }

    appendNewFaceSelection(newfaceSelection_L);
    switch_category(ObjectCategory.FACE);
    endScene3DChange();
  }

  void tessellateTriangular_Selection () {
    if (!isGroupOrFaceCategorySelected()) return;

    beginScene3DChange();

    this.selectFacesAndGroups_fromCurrentSelection();
    ArrayList<Integer> newfaceSelection_L = new ArrayList<Integer>();

    for (int q = Select3D.faceSelection.length - 1; q >= 0; q--) {
      int f = Select3D.faceSelection[q];
      int OBJ_ID = this.findOwningGroupId(f);
      if (OBJ_ID == -1) continue;

      int n = allFaces.nodes[f].length;
      int netShift = n - 1;

      allGroups.inserted_nFaces(OBJ_ID, f, netShift); // because adding the faces also changes the end pointer of the same object

      ArrayList<int[]> midList_Faces_nodes_L = new ArrayList<int[]>();
      ArrayList<int[]> midList_Faces_options_L = new ArrayList<int[]>();

      float[][] base_Vertices = faceBaseVertices(f);
      float[] G_face = faceCentroid(base_Vertices);
      // getOrCreateVertex_atPosition() (same helper used by
      // tessellateRectangular_Selection() and tessellateRowsColumns_Selection()):
      // two different faces' centroids landing on the exact same position is a
      // near-impossible coincidence in practice, but a bare allPoints.create()
      // here would still duplicate rather than reuse a vertex in that case, so
      // keep this consistent with the other two Tessellate commands.
      int new_CenterVertex_number = getOrCreateVertex_atPosition(G_face[0], G_face[1], G_face[2]); // at the center

      current_Material = allFaces.getMaterial(f);
      current_Tessellation = allFaces.getTessellation(f);
      current_Layer = allFaces.getLayer(f);
      current_Visibility = allFaces.getVisibility(f);

      for (int s = 0; s < n; s++) {
        int s_next = (s + 1) % n;

        int[] newFace_nodes = { allFaces.nodes[f][s], allFaces.nodes[f][s_next], new_CenterVertex_number };
        int[] newFace_options = { current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed };

        midList_Faces_nodes_L.add(newFace_nodes);
        midList_Faces_options_L.add(newFace_options);
      }

      spliceFaceWithNewFaces(f, midList_Faces_nodes_L, midList_Faces_options_L);

      // Keep any already-recorded new-face indices from previously processed (larger-index)
      // faces in sync with this splice, then queue up this face's own new pieces.
      for (int i = 0; i < newfaceSelection_L.size(); i++) {
        if (newfaceSelection_L.get(i) > f) newfaceSelection_L.set(i, newfaceSelection_L.get(i) + netShift);
      }
      for (int s = 1; s < n; s++) { // the first tessellated face (s == 0) replaces the base face
        newfaceSelection_L.add(f + s);
      }
    }

    appendNewFaceSelection(newfaceSelection_L);
    switch_category(ObjectCategory.FACE);
    endScene3DChange();
  }

  // ---- Tiling (Square / Hexagon / Equilateral) -----------------------
  //
  // Same one-shot "replace the selected face with real, editable new Face
  // geometry" shape as Quad/Triangle/Grid Tessellate above (splice via
  // spliceFaceWithNewFaces(), Ctrl+Z undo via beginScene3DChange()/
  // endScene3DChange()) - but instead of subdividing the face's own
  // interior into a grid that exactly fills it, this lays a fixed-size
  // regular tile pattern (User3D.tileEdgeSize, never rescaled to force an
  // exact fit) across the face's plane, centered on the face's own local
  // bounding box, by default aligned to the face's own first edge
  // (User3D.tileRotation adds a rotation on top of that). Every candidate
  // tile - including ones straddling the boundary - is clipped to the
  // face's actual outline with a 3D Sutherland-Hodgman clip (the same
  // inward-normal-per-edge construction insetAndRecedeFace() above already
  // uses: cross(faceNormal, edgeDir)). A clipped boundary tile keeps
  // whatever vertex count results (3, 5, 6, 7+...) rather than being
  // re-triangulated - allFaces already supports arbitrary N-gons elsewhere
  // in the app, so there's nothing to fan.
  final static int TILING_EQUILATERAL = 3;
  final static int TILING_SQUARE = 4;
  final static int TILING_CAIRO = 5;
  final static int TILING_HEXAGON = 6;

  void tilingSquare_Selection () {
    applyTiling_Selection(TILING_SQUARE);
  }

  void tilingHexagon_Selection () {
    applyTiling_Selection(TILING_HEXAGON);
  }

  void tilingEquilateral_Selection () {
    applyTiling_Selection(TILING_EQUILATERAL);
  }

  void tilingCairo_Selection () {
    applyTiling_Selection(TILING_CAIRO);
  }

  void applyTiling_Selection (int patternKind) {
    if (!isGroupOrFaceCategorySelected()) return;

    beginScene3DChange();

    this.selectFacesAndGroups_fromCurrentSelection();
    ArrayList<Integer> newfaceSelection_L = new ArrayList<Integer>();

    for (int q = Select3D.faceSelection.length - 1; q >= 0; q--) {
      int f = Select3D.faceSelection[q];
      int OBJ_ID = this.findOwningGroupId(f);
      if (OBJ_ID == -1) continue;

      float[][] base_Vertices = faceBaseVertices(f);
      float[] faceNormal = faceNormalUnit(base_Vertices);

      float[] U_first = funcs.vec3_unit(new float[] {
        base_Vertices[1][0] - base_Vertices[0][0],
        base_Vertices[1][1] - base_Vertices[0][1],
        base_Vertices[1][2] - base_Vertices[0][2]
      });
      // in-plane, perpendicular to U_first - (U_first, V_first, faceNormal)
      // is a right-handed orthonormal frame matching the face's own CCW
      // winding (same identity faceNormalUnit()'s own cross(U,V) relies on).
      float[] V_first = funcs.vec3_unit(funcs.vec3_cross(faceNormal, U_first));

      // User3D.tileRotation rotates the (U_first, V_first) frame about
      // faceNormal, so the default (0) stays exactly aligned to the
      // face's own first edge.
      float[] U_axis = new float[3];
      float[] V_axis = new float[3];
      for (int k = 0; k < 3; k++) {
        U_axis[k] = funcs.cos_ang(User3D.tileRotation) * U_first[k] + funcs.sin_ang(User3D.tileRotation) * V_first[k];
        V_axis[k] = -funcs.sin_ang(User3D.tileRotation) * U_first[k] + funcs.cos_ang(User3D.tileRotation) * V_first[k];
      }

      // Every face vertex's own position in this (U_axis, V_axis) frame,
      // relative to the face's own first vertex - the local extent the
      // tile grid needs to cover.
      float uMin = FLOAT_huge, uMax = -FLOAT_huge, vMin = FLOAT_huge, vMax = -FLOAT_huge;
      for (int s = 0; s < base_Vertices.length; s++) {
        float dx = base_Vertices[s][0] - base_Vertices[0][0];
        float dy = base_Vertices[s][1] - base_Vertices[0][1];
        float dz = base_Vertices[s][2] - base_Vertices[0][2];
        float u = dx * U_axis[0] + dy * U_axis[1] + dz * U_axis[2];
        float v = dx * V_axis[0] + dy * V_axis[1] + dz * V_axis[2];
        uMin = min(uMin, u);
        uMax = max(uMax, u);
        vMin = min(vMin, v);
        vMax = max(vMax, v);
      }

      ArrayList<float[][]> candidates_UV = buildTilingCandidates_UV(patternKind, User3D.tileEdgeSize, uMin, uMax, vMin, vMax);

      ArrayList<int[]> midList_Faces_nodes_L = new ArrayList<int[]>();
      ArrayList<int[]> midList_Faces_options_L = new ArrayList<int[]>();

      current_Material = allFaces.getMaterial(f);
      current_Tessellation = allFaces.getTessellation(f);
      current_Layer = allFaces.getLayer(f);
      current_Visibility = allFaces.getVisibility(f);

      for (int c = 0; c < candidates_UV.size(); c++) {
        float[][] candidate_UV = candidates_UV.get(c);

        float[][] candidate_3D = new float[candidate_UV.length][3];
        for (int s = 0; s < candidate_UV.length; s++) {
          float u = candidate_UV[s][0];
          float v = candidate_UV[s][1];
          candidate_3D[s][0] = base_Vertices[0][0] + u * U_axis[0] + v * V_axis[0];
          candidate_3D[s][1] = base_Vertices[0][1] + u * U_axis[1] + v * V_axis[1];
          candidate_3D[s][2] = base_Vertices[0][2] + u * U_axis[2] + v * V_axis[2];
        }

        float[][] clipped = clipPolygonToFaceBoundary3D(candidate_3D, base_Vertices, faceNormal);
        // Sutherland-Hodgman legitimately emits a repeated vertex whenever
        // a candidate corner lands exactly on one of the face's own clip
        // boundaries (kept once as that pass's own "curr", then kept
        // again as the next pass's unmodified "curr") - collapsing those
        // immediately matters: faceNormalUnit() (used both to verify
        // area below and, the same way, by this app's own rendering/
        // shading elsewhere) builds its normal from this face's own first
        // two vertices, and a repeated first vertex makes that cross()
        // zero/undefined for the resulting face.
        clipped = dedupeConsecutiveVertices3D(clipped);
        if (clipped.length < 3) continue; // fully outside the face

        // The one extra padding ring buildTilingCandidates_UV() adds
        // around every real tile - there to cover corners under rotation -
        // routinely clips down to a zero-area sliver exactly flush with
        // the face's own boundary (every point collapsed onto the same
        // edge or corner) rather than disappearing outright (clipped.
        // length < 3 above). Skip those too, or every tiled face would
        // pick up a ring of invisible, zero-area faces around its edge.
        float area = polygonArea3D(clipped, faceNormal);
        if (area < FLOAT_tiny * FLOAT_tiny) continue;

        int[] newFace_nodes = new int[clipped.length];
        for (int s = 0; s < clipped.length; s++) {
          newFace_nodes[s] = getOrCreateVertex_atPosition(clipped[s][0], clipped[s][1], clipped[s][2]);
        }
        int[] newFace_options = { current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed };

        midList_Faces_nodes_L.add(newFace_nodes);
        midList_Faces_options_L.add(newFace_options);
      }

      if (midList_Faces_nodes_L.size() == 0) continue; // the pattern missed this face entirely (e.g. tileEdgeSize far bigger than the face) - leave it untouched rather than deleting it with nothing to replace it

      int netShift = midList_Faces_nodes_L.size() - 1;
      allGroups.inserted_nFaces(OBJ_ID, f, netShift); // because adding the faces also changes the end pointer of the same object

      spliceFaceWithNewFaces(f, midList_Faces_nodes_L, midList_Faces_options_L);

      // Keep any already-recorded new-face indices from previously processed (larger-index)
      // faces in sync with this splice, then queue up this face's own new pieces.
      for (int i = 0; i < newfaceSelection_L.size(); i++) {
        if (newfaceSelection_L.get(i) > f) newfaceSelection_L.set(i, newfaceSelection_L.get(i) + netShift);
      }
      for (int s = 1; s < midList_Faces_nodes_L.size(); s++) { // the first tile (s == 0) replaces the base face
        newfaceSelection_L.add(f + s);
      }
    }

    appendNewFaceSelection(newfaceSelection_L);
    switch_category(ObjectCategory.FACE);
    endScene3DChange();
  }

  // Sutherland-Hodgman clip of a 3D polygon (assumed coplanar with the
  // face) against every one of the face's own n edges in turn - same
  // inward-normal construction (cross(faceNormal, edgeDir))
  // insetAndRecedeFace() above already uses for "inward, in this face's
  // own plane". Degenerates to an empty array if the candidate tile falls
  // entirely outside the face.
  float[][] clipPolygonToFaceBoundary3D (float[][] poly, float[][] base_Vertices, float[] faceNormal) {
    float[][] result = poly;
    int n = base_Vertices.length;

    for (int s = 0; s < n && result.length > 0; s++) {
      int s_next = (s + 1) % n;
      float[] edgeStart = base_Vertices[s];
      float[] edgeDir = funcs.vec3_unit(new float[] {
        base_Vertices[s_next][0] - base_Vertices[s][0],
        base_Vertices[s_next][1] - base_Vertices[s][1],
        base_Vertices[s_next][2] - base_Vertices[s][2]
      });
      float[] inward = funcs.vec3_unit(funcs.vec3_cross(faceNormal, edgeDir));

      result = clipPolygon_halfPlane3D(result, edgeStart, inward);
    }

    return result;
  }

  // Same cyclic Sutherland-Hodgman technique as Overlay3D.clipPolygon_
  // halfPlane() (that one works in 2D screen space for rendering; this one
  // stays in 3D since every point here is already coplanar with the face).
  float[][] clipPolygon_halfPlane3D (float[][] poly, float[] planePoint, float[] inwardNormal) {
    int n = poly.length;
    if (n == 0) return poly;

    ArrayList<float[]> out = new ArrayList<float[]>();

    for (int i = 0; i < n; i++) {
      float[] curr = poly[i];
      float[] prev = poly[(i - 1 + n) % n];

      float dCurr = (curr[0] - planePoint[0]) * inwardNormal[0] + (curr[1] - planePoint[1]) * inwardNormal[1] + (curr[2] - planePoint[2]) * inwardNormal[2];
      float dPrev = (prev[0] - planePoint[0]) * inwardNormal[0] + (prev[1] - planePoint[1]) * inwardNormal[1] + (prev[2] - planePoint[2]) * inwardNormal[2];

      boolean currIn = dCurr >= 0;
      boolean prevIn = dPrev >= 0;

      if (currIn != prevIn) {
        float t = dPrev / (dPrev - dCurr);
        out.add(new float[] {
          prev[0] + t * (curr[0] - prev[0]),
          prev[1] + t * (curr[1] - prev[1]),
          prev[2] + t * (curr[2] - prev[2])
        });
      }
      if (currIn) {
        out.add(curr);
      }
    }

    return out.toArray(new float[out.size()][]);
  }

  // Drops any vertex that's an exact repeat of the one immediately
  // before it (cyclically, so a last-equals-first wraparound repeat is
  // caught too) - see clipPolygonToFaceBoundary3D()'s own call site
  // above for why this matters, not just for tidiness.
  float[][] dedupeConsecutiveVertices3D (float[][] poly) {
    int n = poly.length;
    if (n == 0) return poly;

    ArrayList<float[]> out = new ArrayList<float[]>();
    for (int i = 0; i < n; i++) {
      float[] curr = poly[i];
      float[] prev = poly[(i - 1 + n) % n];
      if ((curr[0] == prev[0]) && (curr[1] == prev[1]) && (curr[2] == prev[2])) continue;
      out.add(curr);
    }

    return out.toArray(new float[out.size()][]);
  }

  // Signed-area-vector method (Newell-style: sum of cross(P_i, P_i+1)
  // over the polygon's own vertices, dotted with the face's normal to
  // collapse it to a scalar) for a planar polygon's area - used only to
  // reject degenerate zero-area slivers above, so only the magnitude
  // matters here, not the sign.
  float polygonArea3D (float[][] poly, float[] faceNormal) {
    int n = poly.length;
    if (n < 3) return 0;

    float ax = 0, ay = 0, az = 0;
    for (int i = 0; i < n; i++) {
      float[] a = poly[i];
      float[] b = poly[(i + 1) % n];
      ax += a[1] * b[2] - a[2] * b[1];
      ay += a[2] * b[0] - a[0] * b[2];
      az += a[0] * b[1] - a[1] * b[0];
    }

    float signedArea = 0.5 * (ax * faceNormal[0] + ay * faceNormal[1] + az * faceNormal[2]);
    return abs(signedArea);
  }

  // Builds the candidate tile polygons (each an array of {u, v} corner
  // pairs, in the face's own (U_axis, V_axis) frame) for one of the three
  // regular Tiling patterns, sized by edgeSize and generously overshooting
  // [uMin,uMax] x [vMin,vMax] by roughly one full tile ring on every side
  // so that, after applyTiling_Selection() clips every candidate to the
  // face's actual boundary, the pattern is never short at a corner
  // regardless of User3D.tileRotation. The grid is centered on the
  // (uMin,uMax,vMin,vMax) box's own center - not forced through (0,0) - so
  // a face sized to a whole multiple of edgeSize tiles exactly flush, with
  // zero clipping (e.g. a 2x3 rectangle at edgeSize=1 gives exactly 6
  // whole Square tiles).
  ArrayList<float[][]> buildTilingCandidates_UV (int patternKind, float edgeSize, float uMin, float uMax, float vMin, float vMax) {
    ArrayList<float[][]> result = new ArrayList<float[][]>();
    float uCenter = 0.5 * (uMin + uMax);
    float vCenter = 0.5 * (vMin + vMax);

    if (patternKind == TILING_SQUARE) {
      int nCols = int(ceil((uMax - uMin) / edgeSize - FLOAT_tiny));
      if (nCols < 1) nCols = 1;
      int nRows = int(ceil((vMax - vMin) / edgeSize - FLOAT_tiny));
      if (nRows < 1) nRows = 1;

      float uOrigin = uCenter - 0.5 * nCols * edgeSize - edgeSize; // one extra ring of padding
      float vOrigin = vCenter - 0.5 * nRows * edgeSize - edgeSize;
      nCols += 2;
      nRows += 2;

      for (int i = 0; i < nCols; i++) {
        for (int j = 0; j < nRows; j++) {
          float u0 = uOrigin + i * edgeSize;
          float v0 = vOrigin + j * edgeSize;
          result.add(new float[][] {
            { u0, v0 }, { u0 + edgeSize, v0 }, { u0 + edgeSize, v0 + edgeSize }, { u0, v0 + edgeSize }
          });
        }
      }

    } else if (patternKind == TILING_EQUILATERAL) {
      // Standard triangular-lattice strip construction: each row strip
      // (between v0 and v1) carries a "bottom" line of points at spacing
      // edgeSize and a "top" line offset by half a cell from the bottom
      // one; consecutive bottom/top point pairs each split into one
      // upward- and one downward-pointing triangle, tiling the strip with
      // no gaps or overlaps.
      float rowHeight = edgeSize * sqrt(3) / 2.0;
      int nRows = int(ceil((vMax - vMin) / rowHeight - FLOAT_tiny));
      if (nRows < 1) nRows = 1;
      float vOrigin = vCenter - 0.5 * nRows * rowHeight - rowHeight; // one extra ring of padding
      nRows += 2;

      int nCols = int(ceil((uMax - uMin) / edgeSize - FLOAT_tiny));
      if (nCols < 1) nCols = 1;
      float uOrigin = uCenter - 0.5 * nCols * edgeSize - 1.5 * edgeSize; // padding, plus room for the half-cell row stagger
      nCols += 3;

      for (int j = 0; j < nRows; j++) {
        float v0 = vOrigin + j * rowHeight;
        float v1 = v0 + rowHeight;
        float rowOffsetBottom = (((j % 2) + 2) % 2 == 0) ? 0 : 0.5 * edgeSize;

        for (int i = 0; i < nCols; i++) {
          float bottom_i = uOrigin + rowOffsetBottom + i * edgeSize;
          float bottom_i1 = bottom_i + edgeSize;
          float top_i = bottom_i + 0.5 * edgeSize;
          float top_i1 = top_i + edgeSize;

          result.add(new float[][] { { bottom_i, v0 }, { bottom_i1, v0 }, { top_i, v1 } }); // upward-pointing
          result.add(new float[][] { { bottom_i1, v0 }, { top_i1, v1 }, { top_i, v1 } }); // downward-pointing
        }
      }

    } else if (patternKind == TILING_HEXAGON) { // flat-top; a regular hexagon's own edge length equals its circumradius, so edgeSize doubles as R directly
      float R = edgeSize;
      float colSpacing = 1.5 * R;
      float rowSpacing = sqrt(3) * R;

      int nCols = int(ceil((uMax - uMin) / colSpacing - FLOAT_tiny)) + 2;
      if (nCols < 1) nCols = 1;
      int nRows = int(ceil((vMax - vMin) / rowSpacing - FLOAT_tiny)) + 2;
      if (nRows < 1) nRows = 1;
      int halfCols = nCols / 2 + 1;
      int halfRows = nRows / 2 + 1;

      for (int i = -halfCols; i <= halfCols; i++) {
        float uc = uCenter + i * colSpacing;
        float rowOffsetParity = (((i % 2) + 2) % 2 == 0) ? 0 : 0.5 * rowSpacing;

        for (int j = -halfRows; j <= halfRows; j++) {
          float vc = vCenter + rowOffsetParity + j * rowSpacing;

          float[][] hex = new float[6][2];
          for (int k = 0; k < 6; k++) {
            float ang = k * 60; // flat-top: vertices at 0,60,...,300 give horizontal top/bottom edges
            hex[k][0] = uc + R * funcs.cos_ang(ang);
            hex[k][1] = vc + R * funcs.sin_ang(ang);
          }
          result.add(hex);
        }
      }

    } else { // TILING_CAIRO - dual of the snub-square tiling (angles
      // 90,120,120,90,120; edges a,b,a,a,a with b = (sqrt(3)-1)*a). Unlike
      // the three patterns above, this has no closed-form row/column grid:
      // the two right-angle vertices are 4-fold centers and the one short
      // edge (between the two 120 deg corners that don't touch a right
      // angle) pairs two pentagons by a half-turn, so the tiling is grown
      // outward from one seed pentagon by repeatedly reflecting/rotating
      // onto each neighbor until the padded face bounds are covered.
      float a_len = edgeSize;
      float b_len = (sqrt(3) - 1) * a_len;

      // One seed pentagon, walked edge-by-edge from its own first vertex.
      // Interior angles 90,120,120,90,120 -> exterior turns 60,60,90,60,90,
      // applied AFTER each edge. Starting heading -60 (rather than 0) is
      // what lines the 4-fold vertices up on an axis-aligned square
      // lattice at User3D.tileRotation == 0 - the familiar, architectural-
      // drawing orientation of the Cairo tiling - instead of an arbitrary
      // 60 deg tilt that falls out of starting the walk along U_axis.
      float[] edgeLens = { a_len, b_len, a_len, a_len, a_len };
      float[] turnDegs = { 60, 60, 90, 60, 90 };
      float startHeading = -60;

      float[][] seed = new float[5][2];
      float ux = uCenter, vx = vCenter;
      float heading = startHeading;
      for (int k = 0; k < 5; k++) {
        seed[k][0] = ux;
        seed[k][1] = vx;
        ux += edgeLens[k] * funcs.cos_ang(heading);
        vx += edgeLens[k] * funcs.sin_ang(heading);
        heading += turnDegs[k];
      }

      // Generous padding ring beyond the face's own UV extent, so a
      // boundary pentagon's corner is never short once clipped - the
      // pentagon's own longest reach from its centroid is a couple of
      // edgeSize, so a 2*edgeSize margin comfortably covers it the same
      // way the other three patterns pad by one tile width/ring.
      float pad = 2 * a_len;
      float boundU0 = uMin - pad, boundU1 = uMax + pad;
      float boundV0 = vMin - pad, boundV1 = vMax + pad;

      ArrayList<float[][]> placed = new ArrayList<float[][]>();
      java.util.HashSet<String> seenKeys = new java.util.HashSet<String>();
      placed.add(seed);
      seenKeys.add(cairoPentagonKey(seed));

      ArrayList<float[][]> frontier = new ArrayList<float[][]>();
      frontier.add(seed);

      // Safety caps, not expected geometry limits: a BFS "layer" here is
      // one ring of growth outward, so this comfortably outgrows any
      // reasonably sized face long before either cap is hit; they only
      // guard against runaway growth on a pathological edgeSize/face
      // combination (mirroring the same unchecked-nCols/nRows risk the
      // other three patterns already accept).
      int maxLayers = 64;
      int maxPlaced = 20000;

      for (int layer = 0; layer < maxLayers && frontier.size() > 0 && placed.size() < maxPlaced; layer++) {
        ArrayList<float[][]> nextFrontier = new ArrayList<float[][]>();
        boolean anyFrontierInBounds = false;

        for (int p = 0; p < frontier.size() && placed.size() < maxPlaced; p++) {
          float[][] poly = frontier.get(p);
          if (!cairoPentagonBoundsOverlap(poly, boundU0, boundU1, boundV0, boundV1)) continue;
          anyFrontierInBounds = true;

          // neighbor across the short (b) edge V1-V2: half-turn about its midpoint
          float[] mid = { 0.5 * (poly[1][0] + poly[2][0]), 0.5 * (poly[1][1] + poly[2][1]) };
          float[][] shortEdgeNeighbor = cairoRotatePentagon_UV(poly, mid, 180);
          String shortEdgeKey = cairoPentagonKey(shortEdgeNeighbor);
          if (!seenKeys.contains(shortEdgeKey)) {
            seenKeys.add(shortEdgeKey);
            placed.add(shortEdgeNeighbor);
            nextFrontier.add(shortEdgeNeighbor);
          }

          // the two right-angle vertices (V0, V3) are 4-fold centers -
          // three more copies wrap around each one, 90 deg apart
          int[] rightAngleIdx = { 0, 3 };
          for (int r = 0; r < rightAngleIdx.length; r++) {
            float[] center = poly[rightAngleIdx[r]];
            for (int deg = 90; deg <= 270; deg += 90) {
              float[][] cand = cairoRotatePentagon_UV(poly, center, deg);
              String key = cairoPentagonKey(cand);
              if (!seenKeys.contains(key)) {
                seenKeys.add(key);
                placed.add(cand);
                nextFrontier.add(cand);
              }
            }
          }
        }

        if (!anyFrontierInBounds) break; // every pentagon left to grow from has already cleared the padded box
        frontier = nextFrontier;
      }

      result = placed;
    }

    return result;
  }

  // Half-turn (180 deg) is just the deg==180 case of the general rotation
  // below, but kept as its own call above for clarity at the one BFS rule
  // ("pair across the short edge by a half-turn about its midpoint") that
  // reads more plainly spelled out that way than as "rotate by 180".
  float[][] cairoRotatePentagon_UV (float[][] poly, float[] center, float deg) {
    float[][] out = new float[poly.length][2];
    float c = funcs.cos_ang(deg);
    float s = funcs.sin_ang(deg);
    for (int k = 0; k < poly.length; k++) {
      float dx = poly[k][0] - center[0];
      float dy = poly[k][1] - center[1];
      out[k][0] = center[0] + dx * c - dy * s;
      out[k][1] = center[1] + dx * s + dy * c;
    }
    return out;
  }

  // Rounds every vertex (killing the float noise that accumulates over
  // several chained rotations) and sorts the rounded pairs before joining
  // them into one string key - the Cairo BFS routinely reaches the exact
  // same pentagon by more than one neighbor path, and a plain vertex-order
  // key would treat those as distinct and place the same tile twice.
  String cairoPentagonKey (float[][] poly) {
    String[] parts = new String[poly.length];
    for (int k = 0; k < poly.length; k++) {
      float ru = round(poly[k][0] * 1000) / 1000.0;
      float rv = round(poly[k][1] * 1000) / 1000.0;
      parts[k] = ru + "," + rv;
    }
    java.util.Arrays.sort(parts);
    StringBuilder sb = new StringBuilder();
    for (int k = 0; k < parts.length; k++) {
      sb.append(parts[k]);
      sb.append(";");
    }
    return sb.toString();
  }

  // Whether this pentagon's own bounding box overlaps the padded UV
  // region still left to cover - used only to decide whether a frontier
  // pentagon is still worth growing from, not to decide what's kept
  // (clipPolygonToFaceBoundary3D() and the area filter in
  // applyTiling_Selection() already handle that, the same as for the
  // other three patterns' own one-ring padding).
  boolean cairoPentagonBoundsOverlap (float[][] poly, float u0, float u1, float v0, float v1) {
    float pu0 = FLOAT_huge, pu1 = -FLOAT_huge, pv0 = FLOAT_huge, pv1 = -FLOAT_huge;
    for (int k = 0; k < poly.length; k++) {
      pu0 = min(pu0, poly[k][0]);
      pu1 = max(pu1, poly[k][0]);
      pv0 = min(pv0, poly[k][1]);
      pv1 = max(pv1, poly[k][1]);
    }
    return (pu1 >= u0) && (pu0 <= u1) && (pv1 >= v0) && (pv0 <= v1);
  }

  // --- Semi-Regular (Archimedean) Tiling family -------------------------
  // A separate command family from Square/Hexagon/Equilateral/Cairo above,
  // because of one deliberate behavior difference: every piece still gets
  // created (including clipped boundary fragments of any shape), but only
  // the WHOLE copies of the pattern's own highest-vertex-count polygon end
  // up selected afterward - e.g. for Rhombitrihexagonal (3.4.6.4) that's
  // the hexagons, not the squares, triangles, or any clipped fragment of
  // either - so the user can go straight on to add openings, etc., inside
  // just those. "Highest vertex count" is read straight off each
  // candidate's own pre-clip vertex count, which already uniquely picks
  // out the right shape for every semi-regular pattern (no two of a given
  // pattern's own polygon types ever share a vertex count).

  final static int SEMIREGULAR_RHOMBITRIHEXAGONAL = 0;
  final static int SEMIREGULAR_TRUNCATED_HEXAGONAL = 1;
  final static int SEMIREGULAR_TRIHEXAGONAL = 2;

  void tilingRhombitrihexagon_Selection () {
    applySemiRegularTiling_Selection(SEMIREGULAR_RHOMBITRIHEXAGONAL);
  }

  void tilingTruncatedHexagon_Selection () {
    applySemiRegularTiling_Selection(SEMIREGULAR_TRUNCATED_HEXAGONAL);
  }

  void tilingTrihexagon_Selection () {
    applySemiRegularTiling_Selection(SEMIREGULAR_TRIHEXAGONAL);
  }

  void applySemiRegularTiling_Selection (int patternKind) {
    if (!isGroupOrFaceCategorySelected()) return;

    beginScene3DChange();

    this.selectFacesAndGroups_fromCurrentSelection();
    // Unlike applyTiling_Selection()'s newfaceSelection_L (appended on top
    // of whatever was already selected), this is built as the ENTIRE new
    // selection from scratch - every qualifying whole highest-degree tile
    // across every processed face, and nothing else - since the previously
    // selected face(s) themselves are not meant to stay selected once
    // they've been replaced by this pattern's own pieces.
    ArrayList<Integer> selectedFaceSelection_L = new ArrayList<Integer>();

    for (int q = Select3D.faceSelection.length - 1; q >= 0; q--) {
      int f = Select3D.faceSelection[q];
      int OBJ_ID = this.findOwningGroupId(f);
      if (OBJ_ID == -1) continue;

      float[][] base_Vertices = faceBaseVertices(f);
      float[] faceNormal = faceNormalUnit(base_Vertices);

      float[] U_first = funcs.vec3_unit(new float[] {
        base_Vertices[1][0] - base_Vertices[0][0],
        base_Vertices[1][1] - base_Vertices[0][1],
        base_Vertices[1][2] - base_Vertices[0][2]
      });
      float[] V_first = funcs.vec3_unit(funcs.vec3_cross(faceNormal, U_first));

      float[] U_axis = new float[3];
      float[] V_axis = new float[3];
      for (int k = 0; k < 3; k++) {
        U_axis[k] = funcs.cos_ang(User3D.tileRotation) * U_first[k] + funcs.sin_ang(User3D.tileRotation) * V_first[k];
        V_axis[k] = -funcs.sin_ang(User3D.tileRotation) * U_first[k] + funcs.cos_ang(User3D.tileRotation) * V_first[k];
      }

      float uMin = FLOAT_huge, uMax = -FLOAT_huge, vMin = FLOAT_huge, vMax = -FLOAT_huge;
      for (int s = 0; s < base_Vertices.length; s++) {
        float dx = base_Vertices[s][0] - base_Vertices[0][0];
        float dy = base_Vertices[s][1] - base_Vertices[0][1];
        float dz = base_Vertices[s][2] - base_Vertices[0][2];
        float u = dx * U_axis[0] + dy * U_axis[1] + dz * U_axis[2];
        float v = dx * V_axis[0] + dy * V_axis[1] + dz * V_axis[2];
        uMin = min(uMin, u);
        uMax = max(uMax, u);
        vMin = min(vMin, v);
        vMax = max(vMax, v);
      }

      ArrayList<float[][]> candidates_UV = buildSemiRegularCandidates_UV(patternKind, User3D.tileEdgeSize, uMin, uMax, vMin, vMax);

      int maxDegree = 0;
      for (int c = 0; c < candidates_UV.size(); c++) {
        maxDegree = max(maxDegree, candidates_UV.get(c).length);
      }

      ArrayList<int[]> midList_Faces_nodes_L = new ArrayList<int[]>();
      ArrayList<int[]> midList_Faces_options_L = new ArrayList<int[]>();
      ArrayList<Boolean> midList_Qualifies_L = new ArrayList<Boolean>();

      current_Material = allFaces.getMaterial(f);
      current_Tessellation = allFaces.getTessellation(f);
      current_Layer = allFaces.getLayer(f);
      current_Visibility = allFaces.getVisibility(f);

      for (int c = 0; c < candidates_UV.size(); c++) {
        float[][] candidate_UV = candidates_UV.get(c);
        int originalVertexCount = candidate_UV.length;

        float[][] candidate_3D = new float[candidate_UV.length][3];
        for (int s = 0; s < candidate_UV.length; s++) {
          float u = candidate_UV[s][0];
          float v = candidate_UV[s][1];
          candidate_3D[s][0] = base_Vertices[0][0] + u * U_axis[0] + v * V_axis[0];
          candidate_3D[s][1] = base_Vertices[0][1] + u * U_axis[1] + v * V_axis[1];
          candidate_3D[s][2] = base_Vertices[0][2] + u * U_axis[2] + v * V_axis[2];
        }

        float[][] preDedupeClipped = clipPolygonToFaceBoundary3D(candidate_3D, base_Vertices, faceNormal);
        // Sutherland-Hodgman returns a candidate completely untouched
        // (same vertex count, same values, same order) whenever every one
        // of its corners is already inside every one of the face's own
        // half-planes - so comparing the pre-dedupe clip result against
        // the original candidate, value for value, is an exact (not
        // approximate) test of "did the boundary actually cut this one".
        boolean wasClipped = !polygonsExactlyEqual3D(preDedupeClipped, candidate_3D);

        float[][] clipped = dedupeConsecutiveVertices3D(preDedupeClipped);
        if (clipped.length < 3) continue; // fully outside the face

        float area = polygonArea3D(clipped, faceNormal);
        if (area < FLOAT_tiny * FLOAT_tiny) continue; // degenerate sliver - see applyTiling_Selection()'s own identical check

        int[] newFace_nodes = new int[clipped.length];
        for (int s = 0; s < clipped.length; s++) {
          newFace_nodes[s] = getOrCreateVertex_atPosition(clipped[s][0], clipped[s][1], clipped[s][2]);
        }
        int[] newFace_options = { current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed };

        midList_Faces_nodes_L.add(newFace_nodes);
        midList_Faces_options_L.add(newFace_options);
        midList_Qualifies_L.add(!wasClipped && (originalVertexCount == maxDegree));
      }

      if (midList_Faces_nodes_L.size() == 0) continue; // the pattern missed this face entirely - leave it untouched rather than deleting it with nothing to replace it

      int netShift = midList_Faces_nodes_L.size() - 1;
      allGroups.inserted_nFaces(OBJ_ID, f, netShift);

      spliceFaceWithNewFaces(f, midList_Faces_nodes_L, midList_Faces_options_L);

      // Keep any already-recorded qualifying indices from previously processed
      // (larger-index) faces in sync with this splice, then queue up this
      // face's own qualifying pieces - including slot s == 0 (the face
      // that replaces the original f itself), unlike applyTiling_Selection()'s
      // own newfaceSelection_L, since here the original face's own slot is
      // just as eligible (or not) as any newly appended one.
      for (int i = 0; i < selectedFaceSelection_L.size(); i++) {
        if (selectedFaceSelection_L.get(i) > f) selectedFaceSelection_L.set(i, selectedFaceSelection_L.get(i) + netShift);
      }
      for (int s = 0; s < midList_Faces_nodes_L.size(); s++) {
        if (midList_Qualifies_L.get(s)) selectedFaceSelection_L.add(f + s);
      }
    }

    int[] finalSelection = new int[selectedFaceSelection_L.size()];
    for (int i = 0; i < finalSelection.length; i++) finalSelection[i] = selectedFaceSelection_L.get(i);
    Select3D.faceSelection = finalSelection; // full replace, not appended on top of the pre-command selection - see selectedFaceSelection_L's own comment above

    switch_category(ObjectCategory.FACE);
    endScene3DChange();
  }

  // Exact (not approximate) vertex-for-vertex equality check - used only
  // to detect "this candidate passed through clipPolygonToFaceBoundary3D()
  // completely untouched", which is itself exact (see its own call site's
  // comment above), so an exact comparison is the correct, not merely
  // convenient, test here.
  boolean polygonsExactlyEqual3D (float[][] a, float[][] b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if ((a[i][0] != b[i][0]) || (a[i][1] != b[i][1]) || (a[i][2] != b[i][2])) return false;
    }
    return true;
  }

  // Builds every candidate polygon (as {u, v} corner arrays, same
  // (U_axis, V_axis) frame as the regular Tiling family above) for one of
  // the semi-regular patterns, generously overshooting the face's own UV
  // extent the same way the regular family's buildTilingCandidates_UV()
  // does, for the same reason (never leave a boundary tile short, however
  // User3D.tileRotation sits).
  ArrayList<float[][]> buildSemiRegularCandidates_UV (int patternKind, float edgeSize, float uMin, float uMax, float vMin, float vMax) {
    ArrayList<float[][]> result = new ArrayList<float[][]>();

    if (patternKind == SEMIREGULAR_RHOMBITRIHEXAGONAL) {
      // Hexagons (edge a) sit on a triangular lattice, spaced apart (not
      // edge-to-edge) by D = a*(1+sqrt(3)) in all 6 directions 60 deg
      // apart - one square (edge a) fills the gap along every pair of
      // facing hexagon edges, and one triangle (edge a) fills the gap at
      // every trio of mutually facing hexagon corners. Each hexagon is
      // generated exactly once (one per lattice point), but each square is
      // generated twice (once from each of its 2 neighboring hexagons) and
      // each triangle 3 times (once from each of its 3 neighboring
      // hexagons) by this same per-lattice-point loop - addUniquePolygonUV()
      // below is what collapses those back down to one copy apiece.
      float a_len = edgeSize;
      float D = a_len * (1 + sqrt(3));

      // Lattice basis vectors (60 deg apart, length D) and their inverse,
      // used to work out which (i, j) lattice indices this face's own
      // padded UV extent actually needs.
      float e1x = D, e1y = 0;
      float e2x = D * 0.5, e2y = D * sqrt(3) / 2.0;
      float det = e1x * e2y - e1y * e2x;

      float pad = 2 * D; // generous - one extra ring of hexagon-lattice points on every side
      float[] cornersU = { uMin - pad, uMax + pad, uMin - pad, uMax + pad };
      float[] cornersV = { vMin - pad, vMax + pad, vMax + pad, vMin - pad };

      int iMin = Integer.MAX_VALUE, iMax = Integer.MIN_VALUE, jMin = Integer.MAX_VALUE, jMax = Integer.MIN_VALUE;
      for (int k = 0; k < 4; k++) {
        float cu = cornersU[k], cv = cornersV[k];
        float iF = (cu * e2y - cv * e2x) / det;
        float jF = (cv * e1x - cu * e1y) / det;
        iMin = min(iMin, int(floor(iF)));
        iMax = max(iMax, int(ceil(iF)));
        jMin = min(jMin, int(floor(jF)));
        jMax = max(jMax, int(ceil(jF)));
      }

      // Template for the k == 0 (direction 0 deg) square and triangle,
      // relative to a hexagon centered at the origin - every other
      // direction's square/triangle is this same template rotated by
      // 60*k deg about the hexagon's own center (the tiling's 6-fold
      // symmetry), per the construction worked out while planning this:
      // hexagon vertices at 30+60*m deg (circumradius a); the square
      // toward direction 60*k deg shares the hexagon edge facing that
      // direction (hexagon vertices at 60*k-30 and 60*k+30) and the
      // facing edge of the neighboring hexagon at distance D in that same
      // direction (that hexagon's own vertices at 60*k+150 and 60*k+210);
      // the triangle at hexagon vertex 60*k+30 deg is bounded by that
      // vertex, square_k's far corner (at the neighbor's vertex 60*k+150),
      // and square_(k+1)'s far corner (at the OTHER neighbor's vertex
      // 60*(k+1)+210 deg) - verified to close as an equilateral triangle
      // of edge a (and the square's own free edges to be length a) by the
      // identity D - a*sqrt(3) == a.
      float[] P1rel = { a_len * funcs.cos_ang(-30), a_len * funcs.sin_ang(-30) };
      float[] P2rel = { a_len * funcs.cos_ang(30), a_len * funcs.sin_ang(30) };
      float[] P3rel = { D + a_len * funcs.cos_ang(150), a_len * funcs.sin_ang(150) };
      float[] P4rel = { D + a_len * funcs.cos_ang(210), a_len * funcs.sin_ang(210) };

      java.util.HashSet<String> seenKeys = new java.util.HashSet<String>();

      for (int i = iMin; i <= iMax; i++) {
        for (int j = jMin; j <= jMax; j++) {
          float cx = i * e1x + j * e2x;
          float cy = i * e1y + j * e2y;

          float[][] hex = new float[6][2];
          for (int m = 0; m < 6; m++) {
            float ang = 30 + 60 * m;
            hex[m][0] = cx + a_len * funcs.cos_ang(ang);
            hex[m][1] = cy + a_len * funcs.sin_ang(ang);
          }
          addUniquePolygonUV(result, seenKeys, hex);

          for (int k = 0; k < 6; k++) {
            float[] sq1 = rotate2D(P1rel, 60 * k);
            float[] sq2 = rotate2D(P2rel, 60 * k);
            float[] sq3 = rotate2D(P3rel, 60 * k);
            float[] sq4 = rotate2D(P4rel, 60 * k);
            // P1,P2,P3,P4 in that order traces the square clockwise (P1,P2
            // is the hexagon-shared edge going "up", P2,P3 the free top
            // edge going "right", the opposite winding to the hexagon's
            // and triangle's own CCW vertex order below) - P1,P4,P3,P2
            // retraces the same square counter-clockwise instead, so
            // every piece this pattern creates agrees on which way is
            // "out", same as faceNormalUnit()'s own cross(U,V) convention.
            float[][] square = new float[][] {
              { cx + sq1[0], cy + sq1[1] }, { cx + sq4[0], cy + sq4[1] },
              { cx + sq3[0], cy + sq3[1] }, { cx + sq2[0], cy + sq2[1] }
            };
            addUniquePolygonUV(result, seenKeys, square);

            float[] tri2 = rotate2D(P2rel, 60 * k);
            float[] tri3 = rotate2D(P3rel, 60 * k);
            float[] tri4next = rotate2D(P4rel, 60 * (k + 1));
            float[][] triangle = new float[][] {
              { cx + tri2[0], cy + tri2[1] }, { cx + tri3[0], cy + tri3[1] }, { cx + tri4next[0], cy + tri4next[1] }
            };
            addUniquePolygonUV(result, seenKeys, triangle);
          }
        }
      }

    } else if (patternKind == SEMIREGULAR_TRUNCATED_HEXAGONAL) {
      // Regular dodecagons (12-gons, edge a) sit on the SAME triangular
      // lattice topology as an ordinary edge-to-edge hexagonal tiling
      // (TILING_HEXAGON above) - each one adjacent to 6 neighbors, sharing
      // a direct edge with each - just with a dodecagon's own bigger
      // circumradius/apothem in place of a hexagon's. One small triangle
      // (edge a) fills every original 3-way hexagon-tiling vertex that
      // truncation opened up. Every dodecagon is generated once per
      // lattice point, but (same reasoning as the Rhombitrihexagonal
      // branch above) each triangle gets generated 3 times, once from
      // each of the 3 dodecagons meeting at it - addUniquePolygonUV()
      // collapses those back down to one copy.
      float a_len = edgeSize;
      // Circumradius of a regular 12-gon with edge a; its own apothem is
      // R*cos(15 deg) = (a/2)*cot(15 deg) = a*(2+sqrt(3))/2, so two
      // dodecagons facing each other directly (sharing an edge, like two
      // hexagons in an ordinary honeycomb) sit D = a*(2+sqrt(3)) apart.
      float R = a_len / (2 * funcs.sin_ang(15));
      float D = a_len * (2 + sqrt(3));

      float e1x = D, e1y = 0;
      float e2x = D * 0.5, e2y = D * sqrt(3) / 2.0;
      float det = e1x * e2y - e1y * e2x;

      float pad = 2 * D;
      float[] cornersU = { uMin - pad, uMax + pad, uMin - pad, uMax + pad };
      float[] cornersV = { vMin - pad, vMax + pad, vMax + pad, vMin - pad };

      int iMin = Integer.MAX_VALUE, iMax = Integer.MIN_VALUE, jMin = Integer.MAX_VALUE, jMax = Integer.MIN_VALUE;
      for (int k = 0; k < 4; k++) {
        float cu = cornersU[k], cv = cornersV[k];
        float iF = (cu * e2y - cv * e2x) / det;
        float jF = (cv * e1x - cu * e1y) / det;
        iMin = min(iMin, int(floor(iF)));
        iMax = max(iMax, int(ceil(iF)));
        jMin = min(jMin, int(floor(jF)));
        jMax = max(jMax, int(ceil(jF)));
      }

      java.util.HashSet<String> seenKeys = new java.util.HashSet<String>();

      for (int i = iMin; i <= iMax; i++) {
        for (int j = jMin; j <= jMax; j++) {
          float cx = i * e1x + j * e2x;
          float cy = i * e1y + j * e2y;

          // Dodecagon vertices at 15+30*m deg (circumradius R) - chosen
          // (rather than starting at 0) so its edge midpoints fall on
          // every multiple of 30 deg: the even-m edges (midpoint 60*k deg)
          // are the ones shared directly with the 6 neighboring dodecagons,
          // and the odd-m edges (midpoint 60*k+30 deg) are the ones shared
          // with a small triangle instead - verified by construction below.
          float[][] dodecagon = new float[12][2];
          for (int m = 0; m < 12; m++) {
            float ang = 15 + 30 * m;
            dodecagon[m][0] = cx + R * funcs.cos_ang(ang);
            dodecagon[m][1] = cy + R * funcs.sin_ang(ang);
          }
          addUniquePolygonUV(result, seenKeys, dodecagon);

          // One triangle per pair of adjacent neighbor directions (60*k,
          // 60*(k+1)) - its own base edge is this dodecagon's edge facing
          // 60*k+30 deg (vertices at local angle 15+60*k and 45+60*k), and
          // its apex (shared with the OTHER two dodecagons toward 60*k and
          // 60*(k+1)) sits at radius a*(1+sqrt(3)) in that same 60*k+30 deg
          // direction - derived from (and verified against) the dodecagon's
          // own apothem plus the triangle's own height, and confirmed by
          // the resulting triangle's 3 edges all coming out to length a.
          for (int k = 0; k < 6; k++) {
            float angBase1 = 15 + 60 * k;
            float angBase2 = 45 + 60 * k;
            float angApex = 30 + 60 * k;
            float apexRadius = a_len * (1 + sqrt(3));

            float[] base1 = { cx + R * funcs.cos_ang(angBase1), cy + R * funcs.sin_ang(angBase1) };
            float[] apex = { cx + apexRadius * funcs.cos_ang(angApex), cy + apexRadius * funcs.sin_ang(angApex) };
            float[] base2 = { cx + R * funcs.cos_ang(angBase2), cy + R * funcs.sin_ang(angBase2) };

            // base1, apex, base2 in that order is counter-clockwise (the
            // reverse, base1-base2-apex, traces it clockwise instead) -
            // same convention check as the Rhombitrihexagonal branch's own
            // square fix above.
            float[][] triangle = new float[][] { base1, apex, base2 };
            addUniquePolygonUV(result, seenKeys, triangle);
          }
        }
      }

    } else if (patternKind == SEMIREGULAR_TRIHEXAGONAL) {
      // This is the rectification of the plain hexagonal tiling (TILING_HEXAGON):
      // hexagons (edge a) sit on the same lattice shape as the other two
      // patterns above, spaced D = 2*a apart in all 6 directions - closer
      // together than Rhombitrihexagonal's hexagons, since there's no
      // square to make room for here - and touch their 6 neighbors only at
      // vertices, not edges. One small triangle (edge a) fills every one of
      // the 6 notches around each hexagon, each one shared with the 2
      // neighboring hexagons that meet there (verified algebraically: the
      // triangle's 3 corners land exactly on the 3 mutually facing hexagon
      // vertices, and all 3 of its own edges come out to length a). Every
      // hexagon is generated once per lattice point, but each triangle is
      // generated 3 times (once from each of its 3 neighboring hexagons) -
      // addUniquePolygonUV() collapses those back down to one copy apiece.
      float a_len = edgeSize;
      float D = a_len * 2;

      float e1x = D, e1y = 0;
      float e2x = D * 0.5, e2y = D * sqrt(3) / 2.0;
      float det = e1x * e2y - e1y * e2x;

      float pad = 2 * D;
      float[] cornersU = { uMin - pad, uMax + pad, uMin - pad, uMax + pad };
      float[] cornersV = { vMin - pad, vMax + pad, vMax + pad, vMin - pad };

      int iMin = Integer.MAX_VALUE, iMax = Integer.MIN_VALUE, jMin = Integer.MAX_VALUE, jMax = Integer.MIN_VALUE;
      for (int k = 0; k < 4; k++) {
        float cu = cornersU[k], cv = cornersV[k];
        float iF = (cu * e2y - cv * e2x) / det;
        float jF = (cv * e1x - cu * e1y) / det;
        iMin = min(iMin, int(floor(iF)));
        iMax = max(iMax, int(ceil(iF)));
        jMin = min(jMin, int(floor(jF)));
        jMax = max(jMax, int(ceil(jF)));
      }

      java.util.HashSet<String> seenKeys = new java.util.HashSet<String>();

      for (int i = iMin; i <= iMax; i++) {
        for (int j = jMin; j <= jMax; j++) {
          float cx = i * e1x + j * e2x;
          float cy = i * e1y + j * e2y;

          // Hexagon vertices at 60*m deg (circumradius a) - note the 60*m
          // phase (not 30+60*m like TILING_HEXAGON/Rhombitrihexagonal's own
          // hexagon) so that each vertex points straight at one of the 6
          // neighboring lattice points, letting the hexagon-at-(i,j) and
          // the hexagon-at-its-neighbor share that vertex exactly.
          float[][] hex = new float[6][2];
          for (int m = 0; m < 6; m++) {
            float ang = 60 * m;
            hex[m][0] = cx + a_len * funcs.cos_ang(ang);
            hex[m][1] = cy + a_len * funcs.sin_ang(ang);
          }
          addUniquePolygonUV(result, seenKeys, hex);

          // One triangle per pair of adjacent hexagon vertices (60*k,
          // 60*(k+1)) - its base edge is the hexagon's own edge between
          // those two vertices, and its apex (the point shared by the 2
          // OTHER hexagons that meet at this notch) sits at radius a*sqrt(3)
          // in the bisecting direction 30+60*k - derived from (and verified
          // against) the neighboring hexagons' own vertex positions, and
          // confirmed by the resulting triangle's 3 edges all coming out to
          // length a.
          for (int k = 0; k < 6; k++) {
            float angV1 = 60 * k;
            float angV2 = 60 * (k + 1);
            float angApex = 30 + 60 * k;
            float apexRadius = a_len * sqrt(3);

            float[] v1 = { cx + a_len * funcs.cos_ang(angV1), cy + a_len * funcs.sin_ang(angV1) };
            float[] apex = { cx + apexRadius * funcs.cos_ang(angApex), cy + apexRadius * funcs.sin_ang(angApex) };
            float[] v2 = { cx + a_len * funcs.cos_ang(angV2), cy + a_len * funcs.sin_ang(angV2) };

            // v1, apex, v2 in that order is counter-clockwise (the reverse,
            // v1-v2-apex, traces it clockwise instead) - same convention
            // check as the other two patterns' own triangles/squares above.
            float[][] triangle = new float[][] { v1, apex, v2 };
            addUniquePolygonUV(result, seenKeys, triangle);
          }
        }
      }
    }

    return result;
  }

  // Rotates a single {u, v} point by deg degrees about the UV origin -
  // the semi-regular family's own templates above are built relative to
  // each hexagon's own center, so this only ever needs a rotation about
  // (0, 0), unlike the Cairo family's cairoRotatePentagon_UV() (which
  // rotates whole pentagons about an arbitrary shared vertex/midpoint).
  float[] rotate2D (float[] p, float deg) {
    float c = funcs.cos_ang(deg);
    float s = funcs.sin_ang(deg);
    return new float[] { p[0] * c - p[1] * s, p[0] * s + p[1] * c };
  }

  // Rounds and sorts a polygon's own {u, v} corners into one string key
  // (same technique as the Cairo family's cairoPentagonKey(), generalized
  // here since squares and triangles are each generated more than once -
  // see buildSemiRegularCandidates_UV()'s own comment above for exactly
  // how many times - and need collapsing back down to one copy apiece).
  String semiRegularPolygonKeyUV (float[][] poly) {
    String[] parts = new String[poly.length];
    for (int k = 0; k < poly.length; k++) {
      float ru = round(poly[k][0] * 1000) / 1000.0;
      float rv = round(poly[k][1] * 1000) / 1000.0;
      parts[k] = ru + "," + rv;
    }
    java.util.Arrays.sort(parts);
    StringBuilder sb = new StringBuilder();
    for (int k = 0; k < parts.length; k++) {
      sb.append(parts[k]);
      sb.append(";");
    }
    return sb.toString();
  }

  void addUniquePolygonUV (ArrayList<float[][]> result, java.util.HashSet<String> seenKeys, float[][] poly) {
    String key = semiRegularPolygonKeyUV(poly);
    if (seenKeys.contains(key)) return;
    seenKeys.add(key);
    result.add(poly);
  }

  void forceTriangulateFaces_Selection () {
    if (!isGroupOrFaceCategorySelected()) return;

    beginScene3DChange();

    this.selectFacesAndGroups_fromCurrentSelection();
    int[] primary_list = Select3D.faceSelection;
    ArrayList<Integer> newfaceSelection_L = new ArrayList<Integer>();

    for (int o = Select3D.groupSelection.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.groupSelection[o];

      for (int q = primary_list.length - 1; q >= 0; q--) {
        int f = primary_list[q];

        if ((allFaces.nodes[f].length > 3) && isFaceInGroupRange(f, OBJ_ID)) { // <<<<<<<<<<< the condition to perform the process
          allGroups.inserted_nFaces(OBJ_ID, f, allFaces.nodes[f].length - 1); // because adding the faces also changes the end pointer of the same object

          ArrayList<int[]> midList_Faces_nodes_L = new ArrayList<int[]>();
          ArrayList<int[]> midList_Faces_options_L = new ArrayList<int[]>();

          float[][] base_Vertices = faceBaseVertices(f);
          float[] G_face = faceCentroid(base_Vertices);
          int new_CenterVertex_number = allPoints.create(G_face[0], G_face[1], G_face[2]); // at the center

          current_Material = allFaces.getMaterial(f);
          current_Tessellation = allFaces.getTessellation(f);
          current_Layer = allFaces.getLayer(f);
          current_Visibility = allFaces.getVisibility(f);

          for (int s = 0; s < allFaces.nodes[f].length; s++) {
            int s_next = (s + 1) % allFaces.nodes[f].length;

            int[] newFace_nodes = { allFaces.nodes[f][s], allFaces.nodes[f][s_next], new_CenterVertex_number };
            int[] newFace_options = { current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed };

            midList_Faces_nodes_L.add(newFace_nodes);
            midList_Faces_options_L.add(newFace_options);

            if (s > 0) { // the first tessellated face was replaced by the base face... so only add other items
              newfaceSelection_L.add(f + s);
            }
          }

          spliceFaceWithNewFaces(f, midList_Faces_nodes_L, midList_Faces_options_L);
          primary_list = this.remove_item_from_primary_list(q, primary_list);
        }
      }
    }

    appendNewFaceSelection(newfaceSelection_L);
    switch_category(ObjectCategory.FACE);
    endScene3DChange();
  }

  void optimizeFace_Selection () {
    if (!isGroupOrFaceCategorySelected()) return;

    beginScene3DChange();

    this.selectFacesAndGroups_fromCurrentSelection();
    int[] primary_list = Select3D.faceSelection;

    for (int o = Select3D.groupSelection.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.groupSelection[o];

      for (int q = primary_list.length - 1; q >= 0; q--) {
        int f = primary_list[q];
        if (!isFaceInGroupRange(f, OBJ_ID)) continue;

        float[][] base_Vertices = faceBaseVertices(f);
        float[][] new_Vertices = funcs.optimizeVertices(base_Vertices);

        ArrayList<Integer> newList_L = new ArrayList<Integer>();
        // finding ids of new vertices in old vertices
        for (int k = 0; k < new_Vertices.length; k++) {
          for (int s = 0; s < base_Vertices.length; s++) {
            if (funcs.arePointsClose(new_Vertices[k], base_Vertices[s])) {
              newList_L.add(allFaces.nodes[f][s]);
              break;
            }
          }
        }

        int[] newList = new int[newList_L.size()];
        for (int k = 0; k < newList.length; k++) newList[k] = newList_L.get(k);
        allFaces.nodes[f] = newList;
      }
    }

    selection_changed();
    endScene3DChange();
  }

  // Also calls allGroups.beginNewGroup() itself, further down (for each
  // group in the selection) - beginScene3DChange() here needs to cover
  // that too, not just the face/vertex edits, same reasoning as
  // fileSelected.pde's own import functions covering their own
  // allGroups.beginNewGroup() calls.
  void extrudeFaceEdges_Selection () {
    if (!isGroupOrFaceCategorySelected()) return;

    beginScene3DChange();

    this.selectFacesAndGroups_fromCurrentSelection();
    int[] primary_list = Select3D.faceSelection;

    Select3D.deselect_Faces();

    int baseLen = allFaces.nodes.length;
    int runningCount = 0;
    ArrayList<int[]> newFace_nodes_all = new ArrayList<int[]>();
    ArrayList<int[]> newFace_options_all = new ArrayList<int[]>();
    ArrayList<Integer> newfaceSelection_L = new ArrayList<Integer>();

    for (int o = Select3D.groupSelection.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.groupSelection[o];
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);

      for (int q = primary_list.length - 1; q >= 0; q--) {
        int f = primary_list[q];
        if (!isFaceInGroupRange(f, OBJ_ID)) continue;

        float[][] base_Vertices = faceBaseVertices(f);
        float[][] top_Vertices = new float[base_Vertices.length][3];
        for (int s = 0; s < base_Vertices.length; s++) {
          top_Vertices[s][0] = base_Vertices[s][0];
          top_Vertices[s][1] = base_Vertices[s][1];
          top_Vertices[s][2] = base_Vertices[s][2];
        }

        for (int s = 0; s < allFaces.nodes[f].length; s++) {
          int s_next = (s + 1) % allFaces.nodes[f].length;
          int s_prev = (s + allFaces.nodes[f].length - 1) % allFaces.nodes[f].length;

          PVector U = new PVector(base_Vertices[s_next][0] - base_Vertices[s][0], base_Vertices[s_next][1] - base_Vertices[s][1], base_Vertices[s_next][2] - base_Vertices[s][2]);
          PVector V = new PVector(base_Vertices[s_prev][0] - base_Vertices[s][0], base_Vertices[s_prev][1] - base_Vertices[s][1], base_Vertices[s_prev][2] - base_Vertices[s][2]);
          PVector UV = U.cross(V);
          float[] W = { UV.x, UV.y, UV.z };
          W = funcs.vec3_unit(W);

          top_Vertices[s][0] += W[0] * User3D.modifierOpeningDepth;
          top_Vertices[s][1] += W[1] * User3D.modifierOpeningDepth;
          top_Vertices[s][2] += W[2] * User3D.modifierOpeningDepth;
        }

        int[] base_vertexSelection = new int[allFaces.nodes[f].length];
        int[] top_vertexSelection = new int[allFaces.nodes[f].length];

        for (int s = 0; s < allFaces.nodes[f].length; s++) {
          base_vertexSelection[s] = allPoints.create(base_Vertices[s][0], base_Vertices[s][1], base_Vertices[s][2]);
          top_vertexSelection[s] = allPoints.create(top_Vertices[s][0], top_Vertices[s][1], top_Vertices[s][2]);
        }

        int nSides = allFaces.nodes[f].length;
        int[][] newFace_nodes_batch = new int[nSides + 1][];
        int[][] newFace_options_batch = new int[nSides + 1][];

        int face_Material = allFaces.getMaterial(f);
        int face_Tessellation = allFaces.getTessellation(f);
        int face_Layer = allFaces.getLayer(f);
        int face_Visibility = allFaces.getVisibility(f);
        int face_Weight = allFaces.getWeight(f);
        int face_Close = allFaces.getClose(f);

        for (int s = 0; s < nSides; s++) {
          int s_next = (s + 1) % nSides;

          if (User3D.modifierOpeningDepth < 0) { // reverse direction for negative extrude heights
            newFace_nodes_batch[s] = new int[] { base_vertexSelection[s], top_vertexSelection[s], top_vertexSelection[s_next], base_vertexSelection[s_next] };
          } else {
            newFace_nodes_batch[s] = new int[] { base_vertexSelection[s], base_vertexSelection[s_next], top_vertexSelection[s_next], top_vertexSelection[s] };
          }

          newFace_options_batch[s] = new int[] { face_Material, face_Tessellation, face_Layer, face_Visibility, face_Weight, face_Close };
        }

        newFace_nodes_batch[nSides] = top_vertexSelection; // the cap
        newFace_options_batch[nSides] = new int[] { face_Material, face_Tessellation, face_Layer, face_Visibility, face_Weight, face_Close };

        for (int s = 0; s < newFace_nodes_batch.length; s++) {
          newFace_nodes_all.add(newFace_nodes_batch[s]);
          newFace_options_all.add(newFace_options_batch[s]);
        }
        runningCount += newFace_nodes_batch.length;

        int lastFaceIndex = baseLen + runningCount - 1;
        newfaceSelection_L.add(lastFaceIndex);
        allGroups.Faces[allGroups.num - 1][1] = lastFaceIndex;
      }
    }

    if (newFace_nodes_all.size() > 0) {
      int[][] newFace_nodes_batch_all = newFace_nodes_all.toArray(new int[0][]);
      int[][] newFace_options_batch_all = newFace_options_all.toArray(new int[0][]);

      allFaces.nodes = (int[][]) concat(allFaces.nodes, newFace_nodes_batch_all);
      allFaces.options = (int[][]) concat(allFaces.options, newFace_options_batch_all);

      appendNewFaceSelection(newfaceSelection_L);
    }

    selection_changed();
    endScene3DChange();
  }

  // Same corner-normal estimate extrudeFaceEdges_Selection() computes per
  // vertex (U = next corner - this corner, V = previous corner - this
  // corner, W = unit(U x V)), just evaluated once at corner 0 instead of
  // once per vertex - good enough as a single representative normal for a
  // face, which is all thickenFaces_Selection() below needs it for.
  float[] faceNormalUnit (float[][] base_Vertices) {
    int n = base_Vertices.length;
    PVector U = new PVector(base_Vertices[1][0] - base_Vertices[0][0], base_Vertices[1][1] - base_Vertices[0][1], base_Vertices[1][2] - base_Vertices[0][2]);
    PVector V = new PVector(base_Vertices[n - 1][0] - base_Vertices[0][0], base_Vertices[n - 1][1] - base_Vertices[0][1], base_Vertices[n - 1][2] - base_Vertices[0][2]);
    PVector UV = U.cross(V);
    float[] W = { UV.x, UV.y, UV.z };
    return funcs.vec3_unit(W);
  }

  // Gives every selected face a parallel offset copy (its own averaged
  // per-vertex normal x User3D.modifierOpeningDepth, same signed-depth
  // convention as Extrude Face Edges above) and walls only the naked
  // (boundary) edges of the selection - the edges used by exactly one
  // selected face - so a connected patch of faces thickens into one
  // shared shell instead of each face getting its own disconnected little
  // box the way repeatedly running Extrude Face Edges over the same
  // faces would. Like Extrude Face Edges, the original selected faces are
  // left exactly as they were; only the offset copy and the boundary
  // walls are new. Vertices that aren't shared with any other selected
  // face (an isolated single-face selection) still get a sensible result:
  // every one of that face's own edges is then, correctly, a boundary
  // edge, so it comes out walled on all sides - the same single-face box
  // Extrude Face Edges itself would produce.
  void thickenFaces_Selection () {
    if (!isGroupOrFaceCategorySelected()) return;

    beginScene3DChange();

    this.selectFacesAndGroups_fromCurrentSelection();
    int[] primary_list = Select3D.faceSelection;

    Select3D.deselect_Faces();

    int baseLen = allFaces.nodes.length;
    int runningCount = 0;
    ArrayList<int[]> newFace_nodes_all = new ArrayList<int[]>();
    ArrayList<int[]> newFace_options_all = new ArrayList<int[]>();
    ArrayList<Integer> newfaceSelection_L = new ArrayList<Integer>();

    for (int o = Select3D.groupSelection.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.groupSelection[o];

      ArrayList<Integer> groupFaces_L = new ArrayList<Integer>();
      for (int q = 0; q < primary_list.length; q++) {
        int f = primary_list[q];
        if (isFaceInGroupRange(f, OBJ_ID)) groupFaces_L.add(f);
      }
      if (groupFaces_L.size() == 0) continue;

      int[] groupFaces = new int[groupFaces_L.size()];
      for (int i = 0; i < groupFaces.length; i++) groupFaces[i] = groupFaces_L.get(i);

      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);

      // pass 1: average unit face-normal per unique vertex, across every
      // selected face in this group that uses it - this is what keeps the
      // offset copy a single connected shell rather than one disconnected
      // box per face
      HashMap<Integer, float[]> normalSum = new HashMap<Integer, float[]>();
      for (int fi = 0; fi < groupFaces.length; fi++) {
        int f = groupFaces[fi];
        if (allFaces.nodes[f].length < 3) continue;

        float[] n = faceNormalUnit(faceBaseVertices(f));
        for (int s = 0; s < allFaces.nodes[f].length; s++) {
          int vNo = allFaces.nodes[f][s];
          float[] acc = normalSum.get(vNo);
          if (acc == null) {
            acc = new float[] { 0, 0, 0 };
            normalSum.put(vNo, acc);
          }
          acc[0] += n[0];
          acc[1] += n[1];
          acc[2] += n[2];
        }
      }

      // pass 2: one offset vertex per unique original vertex
      HashMap<Integer, Integer> offsetVertexMap = new HashMap<Integer, Integer>();
      for (Integer vNo : normalSum.keySet()) {
        float[] nUnit = funcs.vec3_unit(normalSum.get(vNo));
        float px = allPoints.getX(vNo) + nUnit[0] * User3D.modifierOpeningDepth;
        float py = allPoints.getY(vNo) + nUnit[1] * User3D.modifierOpeningDepth;
        float pz = allPoints.getZ(vNo) + nUnit[2] * User3D.modifierOpeningDepth;
        offsetVertexMap.put(vNo, allPoints.create(px, py, pz));
      }

      // pass 3: undirected-edge usage count across this group's selected
      // faces only - an edge used by exactly one of them is a boundary
      // edge of the selection and needs a wall; one shared between two
      // selected faces is interior and must stay open
      HashMap<String, Integer> edgeCount = new HashMap<String, Integer>();
      for (int fi = 0; fi < groupFaces.length; fi++) {
        int f = groupFaces[fi];
        int n = allFaces.nodes[f].length;
        if (n < 3) continue; // kept out of normalSum/offsetVertexMap above too - not enough vertices for a normal

        for (int s = 0; s < n; s++) {
          int s_next = (s + 1) % n;
          int a = allFaces.nodes[f][s];
          int b = allFaces.nodes[f][s_next];
          String key = min(a, b) + "_" + max(a, b);
          Integer prevCount = edgeCount.get(key);
          edgeCount.put(key, (prevCount == null ? 0 : prevCount) + 1);
        }
      }

      // pass 4: the offset copy of every selected face (same winding as
      // the original, same convention Extrude Face Edges' own cap uses),
      // plus one wall per boundary edge found above
      for (int fi = 0; fi < groupFaces.length; fi++) {
        int f = groupFaces[fi];
        int n = allFaces.nodes[f].length;
        if (n < 3) continue; // no offset vertices exist for this face's own nodes - see pass 1/3's own guard

        int[] faceOptions = { allFaces.getMaterial(f), allFaces.getTessellation(f), allFaces.getLayer(f), allFaces.getVisibility(f), allFaces.getWeight(f), allFaces.getClose(f) };

        int[] backFace_nodes = new int[n];
        for (int s = 0; s < n; s++) backFace_nodes[s] = offsetVertexMap.get(allFaces.nodes[f][s]);
        newFace_nodes_all.add(backFace_nodes);
        newFace_options_all.add(faceOptions);
        runningCount++;
        int lastFaceIndex = baseLen + runningCount - 1;
        newfaceSelection_L.add(lastFaceIndex);
        allGroups.Faces[allGroups.num - 1][1] = lastFaceIndex;

        for (int s = 0; s < n; s++) {
          int s_next = (s + 1) % n;
          int a = allFaces.nodes[f][s];
          int b = allFaces.nodes[f][s_next];
          String key = min(a, b) + "_" + max(a, b);
          if (edgeCount.get(key) != 1) continue; // interior edge shared with another selected face - no wall

          int aTop = offsetVertexMap.get(a);
          int bTop = offsetVertexMap.get(b);

          int[] wall_nodes;
          if (User3D.modifierOpeningDepth < 0) { // reverse direction for negative thickness, same as Extrude Face Edges
            wall_nodes = new int[] { a, aTop, bTop, b };
          } else {
            wall_nodes = new int[] { a, b, bTop, aTop };
          }

          newFace_nodes_all.add(wall_nodes);
          newFace_options_all.add(faceOptions);
          runningCount++;
          lastFaceIndex = baseLen + runningCount - 1;
          newfaceSelection_L.add(lastFaceIndex);
          allGroups.Faces[allGroups.num - 1][1] = lastFaceIndex;
        }
      }
    }

    if (newFace_nodes_all.size() > 0) {
      int[][] newFace_nodes_batch_all = newFace_nodes_all.toArray(new int[0][]);
      int[][] newFace_options_batch_all = newFace_options_all.toArray(new int[0][]);

      allFaces.nodes = (int[][]) concat(allFaces.nodes, newFace_nodes_batch_all);
      allFaces.options = (int[][]) concat(allFaces.options, newFace_options_batch_all);

      appendNewFaceSelection(newfaceSelection_L);
    }

    selection_changed();
    endScene3DChange();
  }

  // Closes any hole in a selected object's own surface - any boundary
  // loop of edges that are each used by exactly one of the GROUP's faces
  // (not just the selected ones; selecting any face of the object, or the
  // object itself, is enough to find and fill every hole it has) - with
  // one new face per loop.
  //
  // The boundary loop is first walked in the direction its one owning
  // face's own edge already runs in, which is the SAME rotational sense
  // as that face's own winding - but using that order directly for the
  // new cap face would point the cap's normal the wrong way. Worked
  // example: an open-topped unit box missing only its top face has four
  // top boundary edges, one per side face, each directed the way that
  // side face's own winding carries it; chaining them head-to-tail (each
  // edge's "to" vertex is the next edge's "from" vertex) walks the loop
  // in one consistent direction - but a face built from THAT vertex order
  // comes out normal-down (into the box). Reversing the walked order
  // before building the cap gives normal-up (out of the box), matching
  // the side faces' own outward convention - so the loop is reversed
  // below, once walking finds a clean closed loop.
  void capHoles_Selection () {
    if (!isGroupOrFaceCategorySelected()) return;

    beginScene3DChange();

    this.selectFacesAndGroups_fromCurrentSelection();

    Select3D.deselect_Faces();

    int baseLen = allFaces.nodes.length;
    int runningCount = 0;
    ArrayList<int[]> newFace_nodes_all = new ArrayList<int[]>();
    ArrayList<int[]> newFace_options_all = new ArrayList<int[]>();
    ArrayList<Integer> newfaceSelection_L = new ArrayList<Integer>();

    for (int o = Select3D.groupSelection.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.groupSelection[o];
      int startFace = allGroups.getStart_Face(OBJ_ID);
      int endFace = allGroups.getStop_Face(OBJ_ID);
      if (endFace < startFace) continue; // this object currently has no faces at all

      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);

      // undirected-edge usage count across every face this object
      // currently has, remembering one directed occurrence (+ its owning
      // face, for the new cap's material/tessellation/etc) for every edge
      // used exactly once - the boundary of any hole in this object
      HashMap<String, Integer> edgeCount = new HashMap<String, Integer>();
      HashMap<String, int[]> edgeDirected = new HashMap<String, int[]>(); // key -> {fromVertex, toVertex, ownerFace}

      for (int f = startFace; f <= endFace; f++) {
        int n = allFaces.nodes[f].length;
        if (n < 3) continue;
        for (int s = 0; s < n; s++) {
          int s_next = (s + 1) % n;
          int a = allFaces.nodes[f][s];
          int b = allFaces.nodes[f][s_next];
          String key = min(a, b) + "_" + max(a, b);
          Integer prevCount = edgeCount.get(key);
          edgeCount.put(key, (prevCount == null ? 0 : prevCount) + 1);
          edgeDirected.put(key, new int[] { a, b, f });
        }
      }

      // one naked edge, by its "from" vertex, maps to where it leads and
      // which face it came from
      HashMap<Integer, int[]> nextFromVertex = new HashMap<Integer, int[]>(); // fromVertex -> {toVertex, ownerFace}
      for (String key : edgeCount.keySet()) {
        if (edgeCount.get(key) != 1) continue;
        int[] d = edgeDirected.get(key);
        nextFromVertex.put(d[0], new int[] { d[1], d[2] });
      }

      HashSet<Integer> consumedStarts = new HashSet<Integer>();

      for (Integer startVertex : nextFromVertex.keySet()) {
        if (consumedStarts.contains(startVertex)) continue;

        ArrayList<Integer> loop_L = new ArrayList<Integer>();
        int ownerFaceForOptions = -1;
        int current = startVertex;
        boolean closed = false;

        for (int guard = 0; guard <= nextFromVertex.size(); guard++) {
          if (consumedStarts.contains(current) && current != startVertex) break; // walked into another loop already in progress - not a clean boundary, bail

          loop_L.add(current);
          consumedStarts.add(current);

          int[] nxt = nextFromVertex.get(current);
          if (nxt == null) break; // dead end - not a closed loop, bail

          if (ownerFaceForOptions == -1) ownerFaceForOptions = nxt[1];
          current = nxt[0];

          if (current == startVertex) {
            closed = true;
            break;
          }
        }

        if (!closed || loop_L.size() < 3) continue; // not a real, closed hole boundary

        int[] capFace_nodes = new int[loop_L.size()]; // reversed - see this method's own comment above
        for (int i = 0; i < loop_L.size(); i++) capFace_nodes[i] = loop_L.get(loop_L.size() - 1 - i);

        int[] capFace_options;
        if (ownerFaceForOptions >= 0) {
          capFace_options = new int[] { allFaces.getMaterial(ownerFaceForOptions), allFaces.getTessellation(ownerFaceForOptions), allFaces.getLayer(ownerFaceForOptions), allFaces.getVisibility(ownerFaceForOptions), allFaces.getWeight(ownerFaceForOptions), allFaces.getClose(ownerFaceForOptions) };
        } else {
          capFace_options = new int[] { current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed };
        }

        newFace_nodes_all.add(capFace_nodes);
        newFace_options_all.add(capFace_options);
        runningCount++;
        int lastFaceIndex = baseLen + runningCount - 1;
        newfaceSelection_L.add(lastFaceIndex);
        allGroups.Faces[allGroups.num - 1][1] = lastFaceIndex;
      }
    }

    if (newFace_nodes_all.size() > 0) {
      int[][] newFace_nodes_batch_all = newFace_nodes_all.toArray(new int[0][]);
      int[][] newFace_options_batch_all = newFace_options_all.toArray(new int[0][]);

      allFaces.nodes = (int[][]) concat(allFaces.nodes, newFace_nodes_batch_all);
      allFaces.options = (int[][]) concat(allFaces.options, newFace_options_batch_all);

      appendNewFaceSelection(newfaceSelection_L);
    }

    selection_changed();
    endScene3DChange();
  }

  // True when face f's own plane - its normal and its distance from the
  // origin along that normal - matches (refNormal, refPoint) closely
  // enough to be treated as the same plane: same facing direction (not
  // just parallel - two coplanar faces pointing opposite ways are each
  // other's back side, not one surface to merge), within about 2.5
  // degrees, and within FLOAT_tiny of lying on it.
  boolean isCoplanarFace (int f, float[] refNormal, float[] refPoint) {
    float[][] base_Vertices = faceBaseVertices(f);
    float[] n = faceNormalUnit(base_Vertices);

    float dot = n[0] * refNormal[0] + n[1] * refNormal[1] + n[2] * refNormal[2];
    if (dot < 0.999) return false;

    float[] p = base_Vertices[0];
    float distToPlane = (p[0] - refPoint[0]) * refNormal[0] + (p[1] - refPoint[1]) * refNormal[1] + (p[2] - refPoint[2]) * refNormal[2];
    return abs(distToPlane) < FLOAT_tiny;
  }

  // Collapses each edge-connected, mutually coplanar cluster of selected
  // faces into one new face spanning the cluster's own outer boundary -
  // the complement to Force Triangulate/Tessellate, for cleaning up a
  // surface that ended up split into more faces than it needs (after a
  // tessellate, an import, or a Boolean-style edit elsewhere).
  //
  // Unlike every other operation in this file, the faces being merged
  // can't just be left in place the way Extrude/Thicken leave their
  // source faces alone - keeping both the old pieces AND the new merged
  // face would double up the surface. So the new face is appended and
  // folded into its own source faces' existing group (extending that
  // group's own face range, not spinning up a new one - this is a
  // simplification of existing geometry, not new geometry), and the
  // consumed originals are then removed through Delete3D.faceSelection()
  // - the same face-deletion primitive "Delete Selection" itself uses,
  // which already knows how to shrink every group's face range and
  // compact allFaces.nodes/options correctly. Since every newly
  // appended face's index is necessarily higher than every original
  // index being deleted (appending only ever adds to the end), each
  // new face's final index after that compaction is simply its
  // just-appended index minus the total number of faces removed - no
  // need to track the shift any more carefully than that.
  //
  // The cluster's outer boundary is found with the exact same
  // naked-edge walk capHoles_Selection() above uses, but - unlike
  // there - the walked order is used AS WALKED, not reversed: these
  // faces already have their own correct, mutually consistent winding
  // (that's part of what "coplanar AND same-facing" verified above), so
  // retracing their shared boundary in the direction it already runs
  // reproduces that same correct winding directly. (Worked example: a
  // quad {0,1,2,3} split by its 0-2 diagonal into triangles {0,1,2} and
  // {0,2,3} has naked boundary edges 0->1, 1->2 [from the first
  // triangle] and 2->3, 3->0 [from the second] - chaining them head to
  // tail walks 0,1,2,3, exactly the original quad's own order.)
  void mergeCoplanarFaces_Selection () {
    if (!isGroupOrFaceCategorySelected()) return;

    beginScene3DChange();

    this.selectFacesAndGroups_fromCurrentSelection();
    int[] primary_list = Select3D.faceSelection;

    Select3D.deselect_Faces();

    ArrayList<Integer> newFacePreDeleteIndex_L = new ArrayList<Integer>(); // each new face's own index right after it's appended, before any deletion shifts it
    ArrayList<Integer> toDelete_L = new ArrayList<Integer>(); // original faces consumed by some merge, everywhere in the whole selection
    ArrayList<Integer> keptOriginal_L = new ArrayList<Integer>(); // originally-selected faces left untouched - no coplanar neighbor, or a cluster the boundary walk couldn't close

    for (int o = Select3D.groupSelection.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.groupSelection[o];

      ArrayList<Integer> groupFaces_L = new ArrayList<Integer>();
      for (int q = 0; q < primary_list.length; q++) {
        int f = primary_list[q];
        if (isFaceInGroupRange(f, OBJ_ID)) groupFaces_L.add(f);
      }
      if (groupFaces_L.size() == 0) continue;

      int[] groupFaces = new int[groupFaces_L.size()];
      for (int i = 0; i < groupFaces.length; i++) groupFaces[i] = groupFaces_L.get(i);

      HashMap<Integer, Integer> faceToIndex = new HashMap<Integer, Integer>();
      for (int fi = 0; fi < groupFaces.length; fi++) faceToIndex.put(groupFaces[fi], fi);

      // every undirected edge used by this group's selected faces, and
      // which of those faces use it - needed to find each face's
      // selected neighbors (an edge used by exactly 2 of them)
      HashMap<String, ArrayList<Integer>> edgeFaces = new HashMap<String, ArrayList<Integer>>();
      for (int fi = 0; fi < groupFaces.length; fi++) {
        int f = groupFaces[fi];
        int n = allFaces.nodes[f].length;
        if (n < 3) continue;
        for (int s = 0; s < n; s++) {
          int s_next = (s + 1) % n;
          int a = allFaces.nodes[f][s];
          int b = allFaces.nodes[f][s_next];
          String key = min(a, b) + "_" + max(a, b);
          ArrayList<Integer> owners = edgeFaces.get(key);
          if (owners == null) {
            owners = new ArrayList<Integer>();
            edgeFaces.put(key, owners);
          }
          owners.add(f);
        }
      }

      // flood-fill this group's selected faces into clusters of
      // edge-connected faces that are all coplanar with the cluster's
      // own first (reference) face
      boolean[] visited = new boolean[groupFaces.length];

      for (int startFi = 0; startFi < groupFaces.length; startFi++) {
        if (visited[startFi]) continue;

        int startFace = groupFaces[startFi];
        if (allFaces.nodes[startFace].length < 3) {
          visited[startFi] = true;
          continue;
        }

        float[][] startBase_Vertices = faceBaseVertices(startFace);
        float[] refNormal = faceNormalUnit(startBase_Vertices);
        float[] refPoint = startBase_Vertices[0];

        ArrayList<Integer> cluster_L = new ArrayList<Integer>();
        ArrayList<Integer> queue = new ArrayList<Integer>();
        queue.add(startFi);
        visited[startFi] = true;

        while (queue.size() > 0) {
          int curFi = queue.remove(queue.size() - 1);
          int curFace = groupFaces[curFi];
          cluster_L.add(curFace);

          int n = allFaces.nodes[curFace].length;
          for (int s = 0; s < n; s++) {
            int s_next = (s + 1) % n;
            int a = allFaces.nodes[curFace][s];
            int b = allFaces.nodes[curFace][s_next];
            String key = min(a, b) + "_" + max(a, b);
            ArrayList<Integer> owners = edgeFaces.get(key);
            if (owners == null || owners.size() != 2) continue; // not shared with exactly one other selected face

            for (int oF : owners) {
              if (oF == curFace) continue;
              Integer neighborFi = faceToIndex.get(oF);
              if (neighborFi == null || visited[neighborFi]) continue;
              if (allFaces.nodes[oF].length < 3) continue;
              if (!isCoplanarFace(oF, refNormal, refPoint)) continue;

              visited[neighborFi] = true;
              queue.add(neighborFi);
            }
          }
        }

        boolean mergedAny = false;

        if (cluster_L.size() >= 2) {
          // the cluster's own outer boundary: undirected edges used by
          // exactly one face WITHIN this cluster
          HashMap<String, Integer> clusterEdgeCount = new HashMap<String, Integer>();
          HashMap<String, int[]> clusterEdgeDirected = new HashMap<String, int[]>(); // key -> {fromVertex, toVertex, ownerFace}

          for (int cf : cluster_L) {
            int n = allFaces.nodes[cf].length;
            for (int s = 0; s < n; s++) {
              int s_next = (s + 1) % n;
              int a = allFaces.nodes[cf][s];
              int b = allFaces.nodes[cf][s_next];
              String key = min(a, b) + "_" + max(a, b);
              Integer prevCount = clusterEdgeCount.get(key);
              clusterEdgeCount.put(key, (prevCount == null ? 0 : prevCount) + 1);
              clusterEdgeDirected.put(key, new int[] { a, b, cf });
            }
          }

          HashMap<Integer, int[]> nextFromVertex = new HashMap<Integer, int[]>(); // fromVertex -> {toVertex, ownerFace}
          for (String key : clusterEdgeCount.keySet()) {
            if (clusterEdgeCount.get(key) != 1) continue;
            int[] d = clusterEdgeDirected.get(key);
            nextFromVertex.put(d[0], new int[] { d[1], d[2] });
          }

          HashSet<Integer> consumedStarts = new HashSet<Integer>();

          for (Integer startVertex : nextFromVertex.keySet()) {
            if (consumedStarts.contains(startVertex)) continue;

            ArrayList<Integer> loop_L = new ArrayList<Integer>();
            int ownerFaceForOptions = -1;
            int current = startVertex;
            boolean closed = false;

            for (int guard = 0; guard <= nextFromVertex.size(); guard++) {
              if (consumedStarts.contains(current) && current != startVertex) break; // walked into another loop already in progress - not a clean boundary, bail

              loop_L.add(current);
              consumedStarts.add(current);

              int[] nxt = nextFromVertex.get(current);
              if (nxt == null) break; // dead end - not a closed loop, bail

              if (ownerFaceForOptions == -1) ownerFaceForOptions = nxt[1];
              current = nxt[0];

              if (current == startVertex) {
                closed = true;
                break;
              }
            }

            if (!closed || loop_L.size() < 3) continue; // not a real, closed boundary

            int[] mergedFace_nodes = new int[loop_L.size()]; // NOT reversed - see this method's own comment above
            for (int i = 0; i < loop_L.size(); i++) mergedFace_nodes[i] = loop_L.get(i);

            int[] mergedFace_options = { allFaces.getMaterial(ownerFaceForOptions), allFaces.getTessellation(ownerFaceForOptions), allFaces.getLayer(ownerFaceForOptions), allFaces.getVisibility(ownerFaceForOptions), allFaces.getWeight(ownerFaceForOptions), allFaces.getClose(ownerFaceForOptions) };

            allFaces.nodes = (int[][]) concat(allFaces.nodes, new int[][] { mergedFace_nodes });
            allFaces.options = (int[][]) concat(allFaces.options, new int[][] { mergedFace_options });
            int newIndex = allFaces.nodes.length - 1;

            newFacePreDeleteIndex_L.add(newIndex);
            if (allGroups.getStop_Face(OBJ_ID) < newIndex) allGroups.setStop_Face(OBJ_ID, newIndex);

            mergedAny = true;
          }
        }

        // whether this cluster was a lone face, had no coplanar neighbor,
        // or (rare/degenerate) never closed a boundary loop above - every
        // face in it is left exactly as it was, and should stay selected
        if (mergedAny) {
          for (int cf : cluster_L) toDelete_L.add(cf);
        } else {
          for (int cf : cluster_L) keptOriginal_L.add(cf);
        }
      }
    }

    int[] toDelete = new int[toDelete_L.size()];
    for (int i = 0; i < toDelete.length; i++) toDelete[i] = toDelete_L.get(i);
    toDelete = sort(toDelete);

    if (toDelete.length > 0) {
      Select3D.faceSelection = toDelete;
      Delete3D.faceSelection(); // shrinks every group's face range and compacts allFaces.nodes/options
    }

    // every surviving face of interest - new merges and untouched
    // originals alike - shifts down by however many deleted indices
    // came before it; new faces are necessarily appended after every
    // deleted index, but a kept original can sit anywhere relative to
    // them, so each one gets counted individually rather than assuming
    // a single shared shift
    int[] finalSelection = new int[newFacePreDeleteIndex_L.size() + keptOriginal_L.size()];
    int selOut = 0;
    for (int preIdx : newFacePreDeleteIndex_L) finalSelection[selOut++] = preIdx - countLessThan(toDelete, preIdx);
    for (int keptIdx : keptOriginal_L) finalSelection[selOut++] = keptIdx - countLessThan(toDelete, keptIdx);
    Select3D.faceSelection = sort(finalSelection);

    selection_changed();
    endScene3DChange();
  }

  // How many of sortedValues are strictly less than value - used by
  // mergeCoplanarFaces_Selection() above to work out how far a
  // surviving face's own index shifts down once every deleted index is
  // actually removed.
  int countLessThan (int[] sortedValues, int value) {
    int count = 0;
    for (int v : sortedValues) if (v < value) count++;
    return count;
  }

  void autoNormalFaces_Selection () {
    if (!isGroupOrFaceCategorySelected()) return;

    beginScene3DChange();

    this.selectFacesAndGroups_fromCurrentSelection();

    for (int o = 0; o < Select3D.faceSelection.length; o++) {
      int f = Select3D.faceSelection[o];
      int n = allFaces.nodes[f].length;
      if (n <= 2) continue;

      int[] tmpFace = new int[n];
      float[] G = { 0, 0, 0 };
      for (int j = 0; j < n; j++) {
        tmpFace[j] = allFaces.nodes[f][j];
        G[0] += allPoints.getX(tmpFace[j]) / float(n);
        G[1] += allPoints.getY(tmpFace[j]) / float(n);
        G[2] += allPoints.getZ(tmpFace[j]) / float(n);
      }

      PVector AG = new PVector(allPoints.getX(tmpFace[0]) - G[0], allPoints.getY(tmpFace[0]) - G[1], allPoints.getZ(tmpFace[0]) - G[2]);
      PVector BG = new PVector(allPoints.getX(tmpFace[1]) - G[0], allPoints.getY(tmpFace[1]) - G[1], allPoints.getZ(tmpFace[1]) - G[2]);
      PVector GAxGB = AG.cross(BG);

      float[] ray_start = { G[0], G[1], G[2] };
      float[] ray_direction = { GAxGB.x, GAxGB.y, GAxGB.z };

      float[] RxP = Select3D.intersect(ray_start, ray_direction);

      if (RxP[0] >= 0) {
        for (int j = 0; j < n; j++) {
          allFaces.nodes[f][j] = tmpFace[n - j - 1];
        }
      }
    }

    switch_category(ObjectCategory.FACE);
    endScene3DChange();
  }

  void flattenTerrainVertices () {
    beginScene3DChange();

    for (int q = 0; q < Select3D.terrainVertexSelection.length; q++) {
      int f = Select3D.terrainVertexSelection[q];
      int i = f / Terrain.columnCount;
      int j = f % Terrain.columnCount;
      Terrain.Mesh[i][j][2] = 0;
    }

    endScene3DChange();
  }

  void changeVisibilityFaces_Selection (int new_vsb) {
    beginScene3DChange();

    if ((currentObjectCategory == ObjectCategory.GROUP) ||
        (currentObjectCategory == ObjectCategory.FACE) ||
        (currentObjectCategory == ObjectCategory.VERTEX)) {

      if (currentObjectCategory == ObjectCategory.GROUP) Select3D.convert_Groups_to_Faces();
      if (currentObjectCategory == ObjectCategory.VERTEX) Select3D.convert_Vertices_to_Faces();

      for (int o = Select3D.faceSelection.length - 1; o >= 0; o--) {
        int f = Select3D.faceSelection[o];
        allFaces.setVisibility(f, new_vsb);
      }
    }

    endScene3DChange();
  }

  void changeVisibilityFaces_Scene (int new_vsb) {
    beginScene3DChange();

    for (int f = allFaces.nodes.length - 1; f >= 0; f--) {
      allFaces.setVisibility(f, new_vsb);
    }

    endScene3DChange();
  }

  void reverseVisibilityFaces_Scene () {
    beginScene3DChange();

    for (int f = allFaces.nodes.length - 1; f >= 0; f--) {
      int vsb = allFaces.getVisibility(f);
      int new_vsb = vsb;

      if (vsb == 0) new_vsb = 1;
      else if (vsb == 1) new_vsb = 0;

      allFaces.setVisibility(f, new_vsb);
    }

    endScene3DChange();
  }

  void changeVisibilityPolylines_Selection (int new_vsb) {
    beginScene3DChange();

    if ((currentObjectCategory == ObjectCategory.GROUP) ||
        (currentObjectCategory == ObjectCategory.POLYLINE) ||
        (currentObjectCategory == ObjectCategory.VERTEX)) {

      if (currentObjectCategory == ObjectCategory.GROUP) Select3D.convert_Groups_to_Polylines();
      if (currentObjectCategory == ObjectCategory.VERTEX) Select3D.convert_Vertices_to_Polylines();

      for (int o = Select3D.polylineSelection.length - 1; o >= 0; o--) {
        int f = Select3D.polylineSelection[o];
        allPolylines.setVisibility(f, new_vsb);
      }
    }

    endScene3DChange();
  }

  void changeVisibilityPolylines_Scene (int new_vsb) {
    beginScene3DChange();

    for (int f = allPolylines.nodes.length - 1; f >= 0; f--) {
      allPolylines.setVisibility(f, new_vsb);
    }

    endScene3DChange();
  }

  void reverseVisibilityPolylines_Scene () {
    beginScene3DChange();

    for (int f = allPolylines.nodes.length - 1; f >= 0; f--) {
      int vsb = allPolylines.getVisibility(f);
      int new_vsb = vsb;

      if (vsb == 0) new_vsb = 1;
      else if (vsb == 1) new_vsb = 0;

      allPolylines.setVisibility(f, new_vsb);
    }

    endScene3DChange();
  }

  // Composite, same reasoning as Delete3D.selection()'s own comment: the
  // four calls below each already wrap their own beginScene3DChange()/
  // endScene3DChange() pair - without this outer pair too, each would
  // independently record its own step, turning one "Isolate" into four.
  void isolate_Selection () {
    if (!isPolymeshCategorySelected()) return;

    beginScene3DChange();

    this.changeVisibilityFaces_Scene(0);
    this.changeVisibilityFaces_Selection(1);

    this.changeVisibilityPolylines_Scene(0);
    this.changeVisibilityPolylines_Selection(1);

    endScene3DChange();
  }
}
