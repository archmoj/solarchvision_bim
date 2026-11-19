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

  void skewVertices_Selection () {
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

    float kXY = User3D.modifierSkewXY;
    float kXZ = User3D.modifierSkewXZ;
    float kYZ = User3D.modifierSkewYZ;

    for (int o = 0; o < n; o++) {
      int vNo = Select3D.vertexSelection[o];
      float y = allPoints.getY(vNo);
      float z = allPoints.getZ(vNo);

      float dx = kXY * (y - cy) + kXZ * (z - cz);
      float dy = kYZ * (z - cz);

      allPoints.move(vNo, dx, dy, 0);
    }

    selection_changed();
    endScene3DChange();
  }

  void twistVertices_Selection () {
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

    float degPerMeterX = User3D.modifierTwistX; // rotation around X, driven by each vertex's own X offset from cx
    float degPerMeterY = User3D.modifierTwistY; // rotation around Y, driven by each vertex's own Y offset from cy
    float degPerMeterZ = User3D.modifierTwistZ; // rotation around Z, driven by each vertex's own Z offset from cz

    for (int o = 0; o < n; o++) {
      int vNo = Select3D.vertexSelection[o];
      float oldX = allPoints.getX(vNo);
      float oldY = allPoints.getY(vNo);
      float oldZ = allPoints.getZ(vNo);

      float x = oldX - cx;
      float y = oldY - cy;
      float z = oldZ - cz;

      // Each axis's own rotation amount comes from this vertex's ORIGINAL
      // (pre-twist) offset along that same axis, computed once up front -
      // then the three rotations are applied in a fixed X -> Y -> Z order
      // to the evolving point, the same composition order Select3D's own
      // object-level rotX/rotY/rotZ triple uses.
      float rX = radians(degPerMeterX * x);
      float rY = radians(degPerMeterY * y);
      float rZ = radians(degPerMeterZ * z);

      float[] afterX = Rotate3D.rotateAroundVector(x, y, z, rX, 0);
      float[] afterY = Rotate3D.rotateAroundVector(afterX[0], afterX[1], afterX[2], rY, 1);
      float[] afterZ = Rotate3D.rotateAroundVector(afterY[0], afterY[1], afterY[2], rZ, 2);

      float newX = cx + afterZ[0];
      float newY = cy + afterZ[1];
      float newZ = cz + afterZ[2];

      allPoints.move(vNo, newX - oldX, newY - oldY, newZ - oldZ);
    }

    selection_changed();
    endScene3DChange();
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

    float kXY = User3D.modifierBendXY; // bends X, driven by each vertex's own Y offset from cy
    float kXZ = User3D.modifierBendXZ; // bends X, driven by each vertex's own Z offset from cz
    float kYZ = User3D.modifierBendYZ; // bends Y, driven by each vertex's own Z offset from cz

    for (int o = 0; o < n; o++) {
      int vNo = Select3D.vertexSelection[o];
      float y = allPoints.getY(vNo);
      float z = allPoints.getZ(vNo);

      float dx = bendOffset(kXY, y - cy) + bendOffset(kXZ, z - cz);
      float dy = bendOffset(kYZ, z - cz);

      allPoints.move(vNo, dx, dy, 0);
    }

    selection_changed();
    endScene3DChange();
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
          PVector perp = N.cross(D); // in-plane, pointing inward - see this method's own comment for why
          inwardPerp[s] = funcs.vec3_unit(new float[] { perp.x, perp.y, perp.z });
        }

        int[] innerVertexSelection = new int[n];
        for (int s = 0; s < n; s++) {
          int s_prev = (s + n - 1) % n;

          float[] P1 = { base_Vertices[s_prev][0] + inwardPerp[s_prev][0] * User3D.modifierInsetDepth, base_Vertices[s_prev][1] + inwardPerp[s_prev][1] * User3D.modifierInsetDepth, base_Vertices[s_prev][2] + inwardPerp[s_prev][2] * User3D.modifierInsetDepth };
          float[] P2 = { base_Vertices[s][0] + inwardPerp[s][0] * User3D.modifierInsetDepth, base_Vertices[s][1] + inwardPerp[s][1] * User3D.modifierInsetDepth, base_Vertices[s][2] + inwardPerp[s][2] * User3D.modifierInsetDepth };

          float[] innerPoint = lineIntersection3D(P1, edgeDir[s_prev], P2, edgeDir[s]);
          if (innerPoint == null) { // a straight-through vertex (both edges run the same direction) - no crossing to find, so just nudge the corner itself inward
            float[] avg = { inwardPerp[s_prev][0] + inwardPerp[s][0], inwardPerp[s_prev][1] + inwardPerp[s][1], inwardPerp[s_prev][2] + inwardPerp[s][2] };
            float[] avgUnit = funcs.vec3_unit(avg);
            innerPoint = new float[] { base_Vertices[s][0] + avgUnit[0] * User3D.modifierInsetDepth, base_Vertices[s][1] + avgUnit[1] * User3D.modifierInsetDepth, base_Vertices[s][2] + avgUnit[2] * User3D.modifierInsetDepth };
          }

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
        primary_list = this.remove_item_from_primary_list(q, primary_list);
      }
    }

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
              new_EdgevertexSelection[s] = allPoints.create(new_EdgeVertices[s][0], new_EdgeVertices[s][1], new_EdgeVertices[s][2]);
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
        new_EdgevertexSelection[s] = allPoints.create(new_EdgeVertices[s][0], new_EdgeVertices[s][1], new_EdgeVertices[s][2]);
      }

      int new_CenterVertex_number = allPoints.create(G_face[0], G_face[1], G_face[2]); // at the center

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
      int new_CenterVertex_number = allPoints.create(G_face[0], G_face[1], G_face[2]); // at the center

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
