class Overlay3D {

  final DrawStyle TERRAIN_STYLE      = new DrawStyle(4, color(255, 0, 255, 127));
  final DrawStyle CAMERA_STYLE         = new DrawStyle(2, color(255, 127, 0), color(0, 31));
  final DrawStyle SECTION_STYLE        = new DrawStyle(2, color(255, 127, 0), color(0, 31));
  final DrawStyle SOLID_STYLE          = new DrawStyle(4, color(255, 127, 0), color(0, 31));
  final DrawStyle MODEL2D_STYLE        = new DrawStyle(2, color(255, 127, 0), color(0, 31));
  final DrawStyle MODEL1D_STYLE        = new DrawStyle(2, color(255, 127, 0), color(0, 31));
  final DrawStyle FACE_EDGE_STYLE      = new DrawStyle(2, color(127, 0, 255), color(0, 31));
  final DrawStyle FACE_LABEL_STYLE     = new DrawStyle(2, color(0), color(0));
  final DrawStyle POLYLINE_LABEL_STYLE = new DrawStyle(2, color(0), color(0));
  final DrawStyle VERTEX_STYLE         = new DrawStyle(2, color(255, 0, 255, 127));
  final DrawStyle SOFTVERTEX_STYLE     = new DrawStyle(4, color(0));
  final DrawStyle GROUP_EDGE_STYLE     = new DrawStyle(2, color(127), color(0, 15));
  final DrawStyle GROUP_BOX_STYLE      = new DrawStyle(4, color(0, 127, 0, 127), color(0, 15));
  final DrawStyle GROUP_PIVOT_STYLE    = new DrawStyle(2, color(255, 127, 0, 127));
  final DrawStyle MODIFIER_BOX_STYLE   = new DrawStyle(4, color(0, 191, 255, 127), color(0, 15));
  final DrawStyle AXIS_X_STYLE         = new DrawStyle(2, color(255, 0, 0));
  final DrawStyle AXIS_Y_STYLE         = new DrawStyle(2, color(0, 0, 255));
  final DrawStyle AXIS_Z_STYLE         = new DrawStyle(2, color(0, 255, 0));

  class DrawStyle {
    int strokeWeight;
    color strokeColor;
    color fillColor;

    float innerWinX1, innerWinY1, innerWinX2, innerWinY2;

    // Stroke-only convenience constructor: fill defaults to fully
    // transparent, which applyStyle() treats as "no fill".
    DrawStyle (int strokeWeight, color strokeColor) {
      this(strokeWeight, strokeColor, color(0, 0, 0, 0));
    }

    DrawStyle (int strokeWeight, color strokeColor, color fillColor) {
      this.strokeWeight = strokeWeight;
      this.strokeColor = strokeColor;
      this.fillColor = fillColor;
    }

    void applyStyle () {
      strokeWeight(this.strokeWeight);
      stroke(strokeColor);
      if (alpha(fillColor) == 0) {
        noFill();
      } else {
        fill(fillColor);
      }

      float[] innerWindow = computeInnerWindow(this.strokeWeight);
      innerWinX1 = innerWindow[0];
      innerWinY1 = innerWindow[1];
      innerWinX2 = innerWindow[2];
      innerWinY2 = innerWindow[3];
    }
  }

  // Pulled out of DrawStyle.applyStyle() above so it's callable without
  // the graphics calls the rest of that method makes (strokeWeight()/
  // stroke()/fill() all need a real PGraphics - this doesn't), the same
  // reason computeFaceTessellation()/computePivotAxisVertices()/
  // computeGroupBoxVertices() below were each pulled out of draw().
  //
  // Returns {innerWinX1, innerWinY1, innerWinX2, innerWinY2}: the window
  // a stroked path is itself clipped/clamped to stay within
  // (clipPolygon_toWindow(), called via clipAndProject()/
  // drawClosedShape() for every style here) or checked against before
  // an unclipped line/ellipse is drawn at all (isInside(), for the
  // pivot/axis/vertex/terrain markers). Either way, the PATH stays
  // inside this inner rect, but Processing's own stroke rendering
  // (round caps/joins by default) then draws strokeWeight/2 further out
  // from that path in every direction, plus a little more still for
  // antialiasing's own blur at the stroke's edge. 1px of margin for
  // that was enough for the thin (strokeWeight 2) styles this
  // originally shipped with, but TERRAIN_STYLE/SOLID_STYLE/
  // GROUP_BOX_STYLE's strokeWeight 4 leaves only that same flat 1px
  // beyond its own (now twice as wide) half-stroke - not enough room
  // for the thicker line's own antialiasing to stay inside WIN3D too.
  // Scaling the margin itself with strokeWeight, rather than leaving it
  // flat, keeps pace with that: margin beyond the stroke's outer edge
  // is strokeWeight + 2 - 0.5*strokeWeight = 0.5*strokeWeight + 2, up
  // from a flat 1px, so a thicker stroke gets more room, not the same
  // fixed sliver a thin one gets.
  float[] computeInnerWindow (int strokeWeight) {
    float pad = strokeWeight + 2;

    return new float[]{
      -0.5 * WIN3D.dX + pad,
      -0.5 * WIN3D.dY + pad,
      0.5 * WIN3D.dX - pad,
      0.5 * WIN3D.dY - pad
    };
  }


  // How far in front of the camera plane a point must be to count as
  // visible - just above zero, so the projection never divides by zero.
  final float NEAR_Z = 0.0001;

  // Result of computeFaceTessellation below: how many tessellated
  // sub-faces face `f` should be split into for drawing, the effective
  // tessellation level used to compute that count, and the face's own
  // untessellated vertex loop (each sub-face is derived from this via
  // funcs.getSubFace(base_Vertices, tessellation, n)).
  class FaceTessellation {
    int tessellation;
    int totalNumberOfSubs;
    float[][] base_Vertices;
  }

  // Pulled out of draw()'s FACE and GROUP-of-faces handling: both ran
  // an identical block computing face f's effective tessellation level
  // (bumped up by allFaces.displayTessellation whenever the face has no
  // material assigned, i.e. material==0) and the resulting sub-face
  // count, plus the face's own base vertex loop that
  // funcs.getSubFace(base_Vertices, tessellation, n) later splits -
  // confirmed character-for-character identical (modulo indentation)
  // before extracting; both call sites now call this instead.
  FaceTessellation computeFaceTessellation (int f) {
    FaceTessellation r = new FaceTessellation();

    r.tessellation = allFaces.getTessellation(f);

    r.totalNumberOfSubs = 1;
    if (allFaces.getMaterial(f) == 0) {
      r.tessellation += allFaces.displayTessellation;
    }
    if (r.tessellation > 0) r.totalNumberOfSubs = allFaces.nodes[f].length * int(funcs.roundTo(pow(4, r.tessellation - 1), 1));

    r.base_Vertices = new float [allFaces.nodes[f].length][3];
    for (int j = 0; j < allFaces.nodes[f].length; j++) {
      int vNo = allFaces.nodes[f][j];
      r.base_Vertices[j][0] = allPoints.getX(vNo);
      r.base_Vertices[j][1] = allPoints.getY(vNo);
      r.base_Vertices[j][2] = allPoints.getZ(vNo);
    }

    return r;
  }

  // Result of computePivotAxisVertices below: the 4 vertices (the
  // origin, plus one endpoint per X/Y/Z axis) of a small 3-axis
  // reference triad centered at (x0,y0,z0), scaled by r, and oriented
  // per Select3D's current alignment/rotation (via
  // translateInside_ReferencePivot, already covered directly in
  // Select3DTest.java).
  //
  // Pulled out of draw()'s two pivot-triad displays - a selected
  // GROUP's own stored pivot (allGroups.Pivots[OBJ_ID], r=10) and the
  // general reference pivot (Select3D.getPivot(), r=5) - which ran an
  // identical block apart from those two inputs; confirmed character-
  // for-character identical (modulo r/x0/y0/z0) before extracting.
  float[][] computePivotAxisVertices (float x0, float y0, float z0, float r) {
    float[][] vertices = {
      { 0, 0, 0 },
      { 1, 0, 0 },
      { 0, 1, 0 },
      { 0, 0, 1 }
    };

    for (int i = 0; i < vertices.length; i++) {

      float x = vertices[i][0] * r;
      float y = vertices[i][1] * r;
      float z = vertices[i][2] * r;

      float[] O = Select3D.translateInside_ReferencePivot(0, 0, 0);
      float[] A = Select3D.translateInside_ReferencePivot(x, y, z);

      vertices[i][0] = x0 + (A[0] - O[0]);
      vertices[i][1] = y0 + (A[1] - O[1]);
      vertices[i][2] = z0 + (A[2] - O[2]);
    }

    return vertices;
  }

  // Result of computeGroupBoxVertices below: the 8 corners of a
  // selected GROUP's bounding box, passed through
  // Select3D.translateInside_ReferencePivot() (already covered directly
  // in Select3DTest.java) so a box with its own local rotation set (via
  // Select3D.BoundingBox's rotX/Y/Z columns) is drawn matching that
  // orientation - under the common case of an axis-aligned, unit-scale
  // box this transform is an exact round trip back to the original
  // corner (translateInside_ReferencePivot re-adds the box's own
  // reference position after rotating/scaling, so a zero rotation and
  // unit scale cancel out to the identity). Also reports whether the
  // box is degenerate (every corner coincides, e.g. an empty or
  // single-point selection) - in which case draw() skips drawing it
  // entirely.
  //
  // Pulled out of draw()'s groupDisplayBox handling: this was the
  // purely computational front half of that block (temporarily forcing
  // Select3D's pivotAlignmentX/Y/Z to 0 so the box is measured from its own
  // centre, deriving the 8 corners from Select3D.BoundingBox's min/max
  // rows, transforming each through translateInside_ReferencePivot,
  // then checking whether they're all still coincident) - the drawing
  // loop that follows it, and the pivotAlignmentX/Y/Z save/restore around the
  // whole thing, are preserved here too since restoring Select3D's
  // align fields is this function's responsibility, not the caller's.
  class GroupBoxVertices {
    float[][] vertices; // 8 corners, transformed per the box's own rotation (see above)
    boolean isEmpty;
  }

  GroupBoxVertices computeGroupBoxVertices () {
    int keep_selection_pivotAlignmentX = Select3D.pivotAlignmentX;
    int keep_selection_pivotAlignmentY = Select3D.pivotAlignmentY;
    int keep_selection_pivotAlignmentZ = Select3D.pivotAlignmentZ;

    Select3D.pivotAlignmentX = 0; // apply the centre
    Select3D.pivotAlignmentY = 0; // apply the centre
    Select3D.pivotAlignmentZ = 0; // apply the centre

    float[] P = Select3D.getPivot();

    float posX = P[0];
    float posY = P[1];
    float posZ = P[2];

    float posX_min = Select3D.BoundingBox[0][0];
    float posY_min = Select3D.BoundingBox[0][1];
    float posZ_min = Select3D.BoundingBox[0][2];

    float posX_max = Select3D.BoundingBox[2][0];
    float posY_max = Select3D.BoundingBox[2][1];
    float posZ_max = Select3D.BoundingBox[2][2];

    float[][] BoundingBox_Vertices = {
      { posX_min, posY_min, posZ_min },
      { posX_max, posY_min, posZ_min },
      { posX_max, posY_max, posZ_min },
      { posX_min, posY_max, posZ_min },
      { posX_min, posY_min, posZ_max },
      { posX_max, posY_min, posZ_max },
      { posX_max, posY_max, posZ_max },
      { posX_min, posY_max, posZ_max }
    };

    for (int i = 0; i < BoundingBox_Vertices.length; i++) {

      float x = BoundingBox_Vertices[i][0] - posX;
      float y = BoundingBox_Vertices[i][1] - posY;
      float z = BoundingBox_Vertices[i][2] - posZ;

      float[] A = Select3D.translateInside_ReferencePivot(x, y, z);

      BoundingBox_Vertices[i][0] = A[0];
      BoundingBox_Vertices[i][1] = A[1];
      BoundingBox_Vertices[i][2] = A[2];
    }

    boolean isEmpty = true;
    for (int i = 1; i < BoundingBox_Vertices.length; i++) {
      if (
        BoundingBox_Vertices[0][0] != BoundingBox_Vertices[i][0] ||
        BoundingBox_Vertices[0][1] != BoundingBox_Vertices[i][1] ||
        BoundingBox_Vertices[0][2] != BoundingBox_Vertices[i][2]
      ) {
        isEmpty = false;
      }
    }

    Select3D.pivotAlignmentX = keep_selection_pivotAlignmentX;
    Select3D.pivotAlignmentY = keep_selection_pivotAlignmentY;
    Select3D.pivotAlignmentZ = keep_selection_pivotAlignmentZ;

    GroupBoxVertices r = new GroupBoxVertices();
    r.vertices = BoundingBox_Vertices;
    r.isEmpty = isEmpty;
    return r;
  }

  void draw () {
    pushMatrix();

    translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

    if (currentObjectCategory == ObjectCategory.TERRAIN) {

      if (Select3D.terrainDisplayVertices) {

        TERRAIN_STYLE.applyStyle();

        ellipseMode(CENTER);

        float R = 10;

        for (int o = Select3D.terrainVertexSelection.length - 1; o >= 0; o--) {

          int OBJ_ID = Select3D.terrainVertexSelection[o];


          int i = OBJ_ID / Terrain.columnCount;
          int j = OBJ_ID % Terrain.columnCount;

          float x = Terrain.Mesh[i][j][0] * overallScale;
          float y = Terrain.Mesh[i][j][1] * overallScale;
          float z = Terrain.Mesh[i][j][2] * overallScale;

          float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

          if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
            if (isInside(Image_XYZ[0], Image_XYZ[1], TERRAIN_STYLE.innerWinX1 + R, TERRAIN_STYLE.innerWinY1 + R, TERRAIN_STYLE.innerWinX2 - R, TERRAIN_STYLE.innerWinY2 - R)) ellipse(Image_XYZ[0], Image_XYZ[1], R, R);
          }

        }

      }
    }

    else if (currentObjectCategory == ObjectCategory.CAMERA) {

      if (Select3D.cameraDisplayFrustum) {

        CAMERA_STYLE.applyStyle();

        ArrayList<float[][]> edgeBatch = new ArrayList<float[][]>();

        {
          for (int o = Select3D.cameraSelection.length - 1; o >= 0; o--) {

            int f = Select3D.cameraSelection[o];

            ArrayList<float[]> camVertices = new ArrayList<float[]>();

            for (int j = 0; j < allCameras.Faces[f].length; j++) {

              int vNo = allCameras.Faces[f][j];

              float x = allCameras.Vertices[vNo][0] * overallScale;
              float y = allCameras.Vertices[vNo][1] * overallScale;
              float z = allCameras.Vertices[vNo][2] * overallScale;

              camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
            }

            drawClosedShape(camVertices, CAMERA_STYLE, edgeBatch);
          }
        }

        drawEdgeBatch(edgeBatch, CAMERA_STYLE);
      }
    }

    else if (currentObjectCategory == ObjectCategory.SECTION) {

      if (Select3D.sectionDisplayEdges) {

        SECTION_STYLE.applyStyle();

        ArrayList<float[][]> edgeBatch = new ArrayList<float[][]>();

        for (int o = Select3D.sectionSelection.length - 1; o >= 0; o--) {

          int f = Select3D.sectionSelection[o];

          ArrayList<float[]> camVertices = new ArrayList<float[]>();

          for (int j = 0; j < allSections.Faces[f].length; j++) {

            int vNo = allSections.Faces[f][j];

            float x = allSections.Vertices[vNo][0] * overallScale;
            float y = allSections.Vertices[vNo][1] * overallScale;
            float z = allSections.Vertices[vNo][2] * overallScale;

            camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
          }

          drawClosedShape(camVertices, SECTION_STYLE, edgeBatch);
        }

        drawEdgeBatch(edgeBatch, SECTION_STYLE);
      }
    }

    else if (currentObjectCategory == ObjectCategory.SOLID) {

      if (Select3D.solidDisplayEdges) {

        SOLID_STYLE.applyStyle();

        ArrayList<float[][]> edgeBatch = new ArrayList<float[][]>();

        for (int o = Select3D.solidSelection.length - 1; o >= 0; o--) {

          int OBJ_ID = Select3D.solidSelection[o];

          for (int plane_type = 0; plane_type < allSolids.num_visualFaces; plane_type++) {

            int f = OBJ_ID * allSolids.num_visualFaces + plane_type;

            ArrayList<float[]> camVertices = new ArrayList<float[]>();

            for (int j = 0; j < allSolids.Faces[f].length; j++) {

              int vNo = allSolids.Faces[f][j];

              float x = allSolids.Vertices[vNo][0] * overallScale;
              float y = allSolids.Vertices[vNo][1] * overallScale;
              float z = allSolids.Vertices[vNo][2] * overallScale;

              camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
            }

            drawClosedShape(camVertices, SOLID_STYLE, edgeBatch);
          }
        }

        drawEdgeBatch(edgeBatch, SOLID_STYLE);
      }
    }

    else if (currentObjectCategory == ObjectCategory.MODEL2D) {

      if (Select3D.model2DDisplayBounds) {

        MODEL2D_STYLE.applyStyle();

        ArrayList<float[][]> edgeBatch = new ArrayList<float[][]>();

        for (int o = Select3D.model2DSelection.length - 1; o >= 0; o--) {

          int OBJ_ID = Select3D.model2DSelection[o];

          for (int plane_type = 0; plane_type < allModel2Ds.num_visualFaces; plane_type++) {

            int f = OBJ_ID * allModel2Ds.num_visualFaces + plane_type;

            ArrayList<float[]> camVertices = new ArrayList<float[]>();

            for (int j = 0; j < allModel2Ds.Faces[f].length; j++) {

              int vNo = allModel2Ds.Faces[f][j];

              float x = allModel2Ds.Vertices[vNo][0] * overallScale;
              float y = allModel2Ds.Vertices[vNo][1] * overallScale;
              float z = allModel2Ds.Vertices[vNo][2] * overallScale;

              camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
            }

            drawClosedShape(camVertices, MODEL2D_STYLE, edgeBatch);
          }
        }

        drawEdgeBatch(edgeBatch, MODEL2D_STYLE);
      }
    }

    else if (currentObjectCategory == ObjectCategory.MODEL1D) {

      if (Select3D.model1DDisplayBounds) {

        MODEL1D_STYLE.applyStyle();

        ArrayList<float[][]> edgeBatch = new ArrayList<float[][]>();

        for (int o = Select3D.model1DSelection.length - 1; o >= 0; o--) {

          int f = Select3D.model1DSelection[o];

          ArrayList<float[]> camVertices = new ArrayList<float[]>();

          for (int j = 0; j < allModel1Ds.Faces[f].length; j++) {

            int vNo = allModel1Ds.Faces[f][j];

            float x = allModel1Ds.Vertices[vNo][0] * overallScale;
            float y = allModel1Ds.Vertices[vNo][1] * overallScale;
            float z = allModel1Ds.Vertices[vNo][2] * overallScale;

            camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
          }

          drawClosedShape(camVertices, MODEL1D_STYLE, edgeBatch);

        }

        drawEdgeBatch(edgeBatch, MODEL1D_STYLE);
      }
    }

    else if (currentObjectCategory == ObjectCategory.FACE) {

      if (Select3D.faceDisplayEdges) {

        FACE_EDGE_STYLE.applyStyle();

        ArrayList<float[][]> edgeBatch = new ArrayList<float[][]>();

        for (int o = Select3D.faceSelection.length - 1; o >= 0; o--) {

          int f = Select3D.faceSelection[o];

          FaceTessellation ft = computeFaceTessellation(f);
          int tessellation = ft.tessellation;
          int totalNumberOfSubs = ft.totalNumberOfSubs;
          float[][] base_Vertices = ft.base_Vertices;

          for (int n = 0; n < totalNumberOfSubs; n++) {

            float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

            ArrayList<float[]> camVertices = new ArrayList<float[]>();

            for (int s = 0; s < subFace.length; s++) {

              float x = subFace[s][0] * overallScale;
              float y = subFace[s][1] * overallScale;
              float z = subFace[s][2] * overallScale;

              camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
            }

            drawClosedShape(camVertices, FACE_EDGE_STYLE, edgeBatch);
          }
        }

        drawEdgeBatch(edgeBatch, FACE_EDGE_STYLE);
      }


      if (Select3D.faceDisplayVertexSelection) {

        FACE_LABEL_STYLE.applyStyle();

        textSize(1.5 * MessageSize);
        textAlign(CENTER, BOTTOM);

        for (int o = Select3D.faceSelection.length - 1; o >= 0; o--) {

          int f = Select3D.faceSelection[o];

          for (int j = 0; j < allFaces.nodes[f].length; j++) {
            int vNo = allFaces.nodes[f][j];

            float x = allPoints.getX(vNo) * overallScale;
            float y = allPoints.getY(vNo) * overallScale;
            float z = allPoints.getZ(vNo) * overallScale;

            float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

            if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
              if (isInside(Image_XYZ[0], Image_XYZ[1], FACE_LABEL_STYLE.innerWinX1, FACE_LABEL_STYLE.innerWinY1, FACE_LABEL_STYLE.innerWinX2, FACE_LABEL_STYLE.innerWinY2)) {
                text(nf(j + 1, 0), Image_XYZ[0], Image_XYZ[1]);
              }
            }
          }
        }

      }
    }


    else if (currentObjectCategory == ObjectCategory.POLYLINE) {

      if (Select3D.polylineDisplayVertexSelection) {

        POLYLINE_LABEL_STYLE.applyStyle();

        textSize(1.5 * MessageSize);
        textAlign(CENTER, BOTTOM);

        for (int o = Select3D.polylineSelection.length - 1; o >= 0; o--) {

          int f = Select3D.polylineSelection[o];

          for (int j = 0; j < allPolylines.nodes[f].length; j++) {
            int vNo = allPolylines.nodes[f][j];

            float x = allPoints.getX(vNo) * overallScale;
            float y = allPoints.getY(vNo) * overallScale;
            float z = allPoints.getZ(vNo) * overallScale;

            float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

            if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
              if (isInside(Image_XYZ[0], Image_XYZ[1], POLYLINE_LABEL_STYLE.innerWinX1, POLYLINE_LABEL_STYLE.innerWinY1, POLYLINE_LABEL_STYLE.innerWinX2, POLYLINE_LABEL_STYLE.innerWinY2)) {
                text(nf(j + 1, 0), Image_XYZ[0], Image_XYZ[1]);
              }
            }
          }
        }

      }
    }


    else if (currentObjectCategory == ObjectCategory.VERTEX) {

      if (Select3D.vertexDisplayMarkers) {

        VERTEX_STYLE.applyStyle();

        ellipseMode(CENTER);

        float R = 10;

        for (int o = Select3D.vertexSelection.length - 1; o >= 0; o--) {

          int vNo = Select3D.vertexSelection[o];

          float x = allPoints.getX(vNo) * overallScale;
          float y = allPoints.getY(vNo) * overallScale;
          float z = allPoints.getZ(vNo) * overallScale;

          float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

          if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
            if (isInside(Image_XYZ[0], Image_XYZ[1], VERTEX_STYLE.innerWinX1 + R, VERTEX_STYLE.innerWinY1 + R, VERTEX_STYLE.innerWinX2 - R, VERTEX_STYLE.innerWinY2 - R)) ellipse(Image_XYZ[0], Image_XYZ[1], R, R);
          }
        }

      }

      // Skew/Twist's own pivot, shown live while editing: the exact
      // same box - Select3D.vertexIdsExtents(Select3D.vertexSelection) -
      // skewVertices_Selection()/twistVertices_Selection() pivot off
      // of, so this can never silently disagree with what those
      // modifiers actually do (see vertexIdsExtents()'s own comment).
      // Only meaningful with 2+ selected vertices (a single point's
      // box is degenerate - nothing to shear/twist relative to).
      if (Select3D.modifierDisplayBoundingBox && (Select3D.vertexSelection.length >= 2)) {

        float[] extents = Select3D.vertexIdsExtents(Select3D.vertexSelection);
        float minX = extents[0], minY = extents[1], minZ = extents[2];
        float maxX = extents[3], maxY = extents[4], maxZ = extents[5];

        if ((minX != maxX) || (minY != maxY) || (minZ != maxZ)) { // not degenerate on every axis at once

          MODIFIER_BOX_STYLE.applyStyle();

          // The pivot itself - deliberately NOT routed through
          // computePivotAxisVertices()/translateInside_ReferencePivot(),
          // which apply a DIFFERENT selection's rotation/scale (the
          // object-level GROUP pivot-alignment state); this box has no
          // rotation of its own at all, so that transform would be
          // wrong here, not just unnecessary. Hoisted above the box's
          // own drawing below too, since the box now needs it for its
          // own pivot-relative preview math.
          float cx = (minX + maxX) / 2;
          float cy = (minY + maxY) / 2;
          float cz = (minZ + maxZ) / 2;

          float[][] BoundingBox_Vertices = {
            { minX, minY, minZ },
            { maxX, minY, minZ },
            { maxX, maxY, minZ },
            { minX, maxY, minZ },
            { minX, minY, maxZ },
            { maxX, minY, maxZ },
            { maxX, maxY, maxZ },
            { minX, maxY, maxZ }
          };

          // The box's 12 edges, each a plain (corner, corner) pair - no
          // face-fill/shared-edge bookkeeping needed, since each is now
          // walked and drawn exactly once as its own subdivided polyline
          // below, not as a quad's outline.
          int[][] BoundingBox_Edges = {
            { 0, 1 }, { 1, 2 }, { 2, 3 }, { 3, 0 } // bottom face
            , { 4, 5 }, { 5, 6 }, { 6, 7 }, { 7, 4 } // top face
            , { 0, 4 }, { 1, 5 }, { 2, 6 }, { 3, 7 } // the 4 verticals joining them
          };

          // Sample each edge at 12 segments (13 points) along its own
          // straight corner-to-corner line, run each sample through
          // Modify3D.previewModifierDeformation() with the Skew/Twist/
          // Bend fields' CURRENT values, and draw the resulting polyline
          // instead of the original straight edge - a live cage preview
          // of what committing those modifiers (in sequence) would
          // actually do, not just this bounding box's own undeformed
          // shape. When all nine fields are 0, every sample point's
          // deformation is 0 too, so this collapses back to exactly the
          // plain straight-edge box it replaces - no separate "nothing
          // is being edited" case to maintain.
          int SEGMENTS = 12;

          for (int e = 0; e < BoundingBox_Edges.length; e++) {

            float[] A = BoundingBox_Vertices[BoundingBox_Edges[e][0]];
            float[] B = BoundingBox_Vertices[BoundingBox_Edges[e][1]];

            float[] prevImage = null;

            for (int s = 0; s <= SEGMENTS; s++) {

              float t = (float) s / SEGMENTS;

              float x0 = lerp(A[0], B[0], t) - cx;
              float y0 = lerp(A[1], B[1], t) - cy;
              float z0 = lerp(A[2], B[2], t) - cz;

              float[] deformed = Modify3D.previewModifierDeformation(x0, y0, z0);

              float x = (cx + deformed[0]) * overallScale;
              float y = (cy + deformed[1]) * overallScale;
              float z = (cz + deformed[2]) * overallScale;

              float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

              if (Image_XYZ[2] > 0) {
                if (isInside(Image_XYZ[0], Image_XYZ[1], MODIFIER_BOX_STYLE.innerWinX1, MODIFIER_BOX_STYLE.innerWinY1, MODIFIER_BOX_STYLE.innerWinX2, MODIFIER_BOX_STYLE.innerWinY2)) {
                  if (prevImage != null) {
                    line(prevImage[0], prevImage[1], Image_XYZ[0], Image_XYZ[1]);
                  }
                  prevImage = Image_XYZ;
                } else {
                  prevImage = null; // this sample fell outside the clip window - don't bridge across it
                }
              } else {
                prevImage = null;
              }
            }
          }

          float r = 0.1 * max(0.0001, max(maxX - minX, max(maxY - minY, maxZ - minZ))); // never a zero-length triad

          float[][] Triad_Vertices = {
            { cx, cy, cz },
            { cx + r, cy, cz },
            { cx, cy + r, cz },
            { cx, cy, cz + r }
          };

          int[][] Triad_Lines = {
            { 0, 1 }
            , { 0, 2 }
            , { 0, 3 }
          };

          for (int f = 0; f < Triad_Lines.length; f++) {

            DrawStyle axisStyle;
            if (f == 0) axisStyle = AXIS_X_STYLE;
            else if (f == 1) axisStyle = AXIS_Y_STYLE;
            else axisStyle = AXIS_Z_STYLE;

            axisStyle.applyStyle();

            int a = Triad_Lines[f][0];
            int b = Triad_Lines[f][1];

            float x1 = Triad_Vertices[a][0] * overallScale;
            float y1 = Triad_Vertices[a][1] * overallScale;
            float z1 = Triad_Vertices[a][2] * overallScale;

            float x2 = Triad_Vertices[b][0] * overallScale;
            float y2 = Triad_Vertices[b][1] * overallScale;
            float z2 = Triad_Vertices[b][2] * overallScale;

            float[] Image_XYZa = WIN3D.calculate_Perspective_Internally(x1, y1, z1);
            float[] Image_XYZb = WIN3D.calculate_Perspective_Internally(x2, y2, z2);

            if ((Image_XYZa[2] > 0) && (Image_XYZb[2] > 0)) {
              if (isInside(Image_XYZa[0], Image_XYZa[1], axisStyle.innerWinX1, axisStyle.innerWinY1, axisStyle.innerWinX2, axisStyle.innerWinY2)) {
                if (isInside(Image_XYZb[0], Image_XYZb[1], axisStyle.innerWinX1, axisStyle.innerWinY1, axisStyle.innerWinX2, axisStyle.innerWinY2)) {
                  line(Image_XYZa[0], Image_XYZa[1], Image_XYZb[0], Image_XYZb[1]);
                }
              }
            }
          }
        }
      }
    }



    else if (currentObjectCategory == ObjectCategory.SOFTVERTEX) {

      if (Select3D.vertexDisplayMarkers) {

        SOFTVERTEX_STYLE.applyStyle();

        ellipseMode(CENTER);

        float R = 5;

        for (int q = 0; q < Select3D.softSelection.length; q++) {

          int vNo = Select3D.softSelection[q];

          float _u = Select3D.softSelectionFalloff[q];

          float x = allPoints.getX(vNo) * overallScale;
          float y = allPoints.getY(vNo) * overallScale;
          float z = allPoints.getZ(vNo) * overallScale;

          float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

          if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
            if (isInside(Image_XYZ[0], Image_XYZ[1], SOFTVERTEX_STYLE.innerWinX1 + R, SOFTVERTEX_STYLE.innerWinY1 + R, SOFTVERTEX_STYLE.innerWinX2 - R, SOFTVERTEX_STYLE.innerWinY2 - R)) {

              float[] COL = PAINT.getColorStyle(14, _u); // <<<<<<<<<<<<<<<<<
              fill(COL[1], COL[2], COL[3], COL[0]);
              stroke(COL[1], COL[2], COL[3], COL[0]);

              ellipse(Image_XYZ[0], Image_XYZ[1], R, R);
            }
          }
        }


      }
    }



    else if (currentObjectCategory == ObjectCategory.GROUP) {

      if (Select3D.groupDisplayEdges) {

        GROUP_EDGE_STYLE.applyStyle();

        ArrayList<float[][]> edgeBatch = new ArrayList<float[][]>();

        for (int o = Select3D.groupSelection.length - 1; o >= 0; o--) {

          int OBJ_ID = Select3D.groupSelection[o];


          for (int f = allGroups.getStart_Face(OBJ_ID); f <= allGroups.getStop_Face(OBJ_ID); f++) {
            if ((0 <= f) && (f < allFaces.nodes.length)) {

              FaceTessellation ft = computeFaceTessellation(f);
              int tessellation = ft.tessellation;
              int totalNumberOfSubs = ft.totalNumberOfSubs;
              float[][] base_Vertices = ft.base_Vertices;

              for (int n = 0; n < totalNumberOfSubs; n++) {

                float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

                ArrayList<float[]> camVertices = new ArrayList<float[]>();

                for (int s = 0; s < subFace.length; s++) {

                  float x = subFace[s][0] * overallScale;
                  float y = subFace[s][1] * overallScale;
                  float z = subFace[s][2] * overallScale;

                  camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
                }

                drawClosedShape(camVertices, GROUP_EDGE_STYLE, edgeBatch);
              }
            }
          }


          for (int f = allGroups.getStart_Polyline(OBJ_ID); f <= allGroups.getStop_Polyline(OBJ_ID); f++) {
            if ((0 <= f) && (f < allPolylines.nodes.length)) {

              ArrayList<float[]> camVertices = new ArrayList<float[]>();

              // allPolylines.nodes[f][j] is this polyline's own j'th point
              // index into allPoints - every other sub-object loop in
              // this file (allFaces.nodes[f][j], allModel1Ds.Faces[f][j],
              // allModel2Ds.Faces[f][j], allSolids.Faces[f][j], see
              // computeFaceTessellation() and the blocks around this one)
              // goes through that same indirection before indexing its
              // own vertex/point array. This one used to skip it and
              // index allPoints directly by the 0..length-1 loop counter
              // instead - drawing a GROUP's polyline edges by connecting
              // whichever points happen to sit at allPoints' own indices
              // 0..(this polyline's node count - 1), wherever those
              // actually are in the model, rather than this polyline's
              // real points. Since that shape has nothing to do with the
              // polyline's own (typically small, local) geometry, it can
              // span arbitrarily far across the model - exactly the
              // "lines go outside the WIN3D viewport area" symptom,
              // since drawClosedShape()'s window-clip only ever shrinks
              // a shape's visible portion down to the window, it can't
              // make an otherwise-correct shape draw outside it; the
              // shape itself has to be wrong first, as it was here.
              for (int j = 0; j < allPolylines.nodes[f].length; j++) {

                int vNo = allPolylines.nodes[f][j];

                float x = allPoints.getX(vNo) * overallScale;
                float y = allPoints.getY(vNo) * overallScale;
                float z = allPoints.getZ(vNo) * overallScale;

                camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
              }

              drawClosedShape(camVertices, GROUP_EDGE_STYLE, edgeBatch);
            }
          }


          for (int f = allGroups.getStart_Model1D(OBJ_ID); f <= allGroups.getStop_Model1D(OBJ_ID); f++) {

            if ((0 <= f) && (f < allModel1Ds.Faces.length)) {

              ArrayList<float[]> camVertices = new ArrayList<float[]>();

              for (int j = 0; j < allModel1Ds.Faces[f].length; j++) {

                int vNo = allModel1Ds.Faces[f][j];

                float x = allModel1Ds.Vertices[vNo][0] * overallScale;
                float y = allModel1Ds.Vertices[vNo][1] * overallScale;
                float z = allModel1Ds.Vertices[vNo][2] * overallScale;

                camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
              }

              drawClosedShape(camVertices, GROUP_EDGE_STYLE, edgeBatch);
            }
          }


          for (int f = allGroups.getStart_Model2D(OBJ_ID); f <= allGroups.getStop_Model2D(OBJ_ID); f++) {

            if ((0 <= f) && (f < allModel2Ds.Faces.length)) {

              ArrayList<float[]> camVertices = new ArrayList<float[]>();

              for (int j = 0; j < allModel2Ds.Faces[f].length; j++) {

                int vNo = allModel2Ds.Faces[f][j];

                float x = allModel2Ds.Vertices[vNo][0] * overallScale;
                float y = allModel2Ds.Vertices[vNo][1] * overallScale;
                float z = allModel2Ds.Vertices[vNo][2] * overallScale;

                camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
              }

              drawClosedShape(camVertices, GROUP_EDGE_STYLE, edgeBatch);
            }
          }

          for (int q = allGroups.getStart_Solid(OBJ_ID); q <= allGroups.getStop_Solid(OBJ_ID); q++) {

            if ((0 < q) && (q < allSolids.Faces.length)) {

              for (int plane_type = 0; plane_type < allSolids.num_visualFaces; plane_type++) {

                int f = (q - 1) * allSolids.num_visualFaces + plane_type + 1;

                if ((0 <= f) && (f < allSolids.Faces.length)) {

                  ArrayList<float[]> camVertices = new ArrayList<float[]>();

                  for (int j = 0; j < allSolids.Faces[f].length; j++) {

                    int vNo = allSolids.Faces[f][j];

                    float x = allSolids.Vertices[vNo][0] * overallScale;
                    float y = allSolids.Vertices[vNo][1] * overallScale;
                    float z = allSolids.Vertices[vNo][2] * overallScale;

                    camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
                  }

                  drawClosedShape(camVertices, GROUP_EDGE_STYLE, edgeBatch);
                }
              }
            }
          }
        }

        drawEdgeBatch(edgeBatch, GROUP_EDGE_STYLE);
      }


      if (Select3D.groupDisplayBox) {

        GROUP_BOX_STYLE.applyStyle();

        ArrayList<float[][]> boxEdgeBatch = new ArrayList<float[][]>();

        GroupBoxVertices gbv = computeGroupBoxVertices();
        float[][] BoundingBox_Vertices = gbv.vertices;

        if(!gbv.isEmpty) {
          int[][] BoundingBox_Faces = {
            {
              3, 2, 1, 0
            }
            , {
              0, 1, 5, 4
            }
            , {
              1, 2, 6, 5
            }
            , {
              2, 3, 7, 6
            }
            , {
              3, 0, 4, 7
            }
            , {
              4, 5, 6, 7
            }
          };

          for (int f = 0; f < BoundingBox_Faces.length; f++) {

            ArrayList<float[]> camVertices = new ArrayList<float[]>();

            for (int g = 0; g < BoundingBox_Faces[f].length; g++) {

              int vNo = BoundingBox_Faces[f][g];

              float x = BoundingBox_Vertices[vNo][0] * overallScale;
              float y = BoundingBox_Vertices[vNo][1] * overallScale;
              float z = BoundingBox_Vertices[vNo][2] * overallScale;

              camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
            }

            drawClosedShape(camVertices, GROUP_BOX_STYLE, boxEdgeBatch);
          }
        }

        drawEdgeBatch(boxEdgeBatch, GROUP_BOX_STYLE);
      }




      if (Select3D.groupDisplayPivot) {

        GROUP_PIVOT_STYLE.applyStyle();

        if(allGroups.Pivots.length > 0) {
          for (int o = Select3D.groupSelection.length - 1; o >= 0; o--) {

            int OBJ_ID = Select3D.groupSelection[o];

            float x0 = allGroups.Pivots[OBJ_ID][0];
            float y0 = allGroups.Pivots[OBJ_ID][1];
            float z0 = allGroups.Pivots[OBJ_ID][2];

            float[][] Pivot_Vertices = computePivotAxisVertices(x0, y0, z0, 10);


            int[][] Pivot_Lines = {
              {
                0, 1
              }
              , {
                0, 2
              }
              , {
                0, 3
              }
            };

            int f_start = 0;
            int f_end = Pivot_Lines.length - 1;

            for (int f = f_start; f <= f_end; f++) {

              int a = Pivot_Lines[f][0];
              int b = Pivot_Lines[f][1];

              float x1 = Pivot_Vertices[a][0] * overallScale;
              float y1 = Pivot_Vertices[a][1] * overallScale;
              float z1 = Pivot_Vertices[a][2] * overallScale;

              float x2 = Pivot_Vertices[b][0] * overallScale;
              float y2 = Pivot_Vertices[b][1] * overallScale;
              float z2 = Pivot_Vertices[b][2] * overallScale;

              float[] Image_XYZa = WIN3D.calculate_Perspective_Internally(x1, y1, z1);
              float[] Image_XYZb = WIN3D.calculate_Perspective_Internally(x2, y2, z2);

              if ((Image_XYZa[2] > 0) && (Image_XYZb[2] > 0)) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
                if (isInside(Image_XYZa[0], Image_XYZa[1], GROUP_PIVOT_STYLE.innerWinX1, GROUP_PIVOT_STYLE.innerWinY1, GROUP_PIVOT_STYLE.innerWinX2, GROUP_PIVOT_STYLE.innerWinY2)) {
                  if (isInside(Image_XYZb[0], Image_XYZb[1], GROUP_PIVOT_STYLE.innerWinX1, GROUP_PIVOT_STYLE.innerWinY1, GROUP_PIVOT_STYLE.innerWinX2, GROUP_PIVOT_STYLE.innerWinY2)) {
                    line(Image_XYZa[0], Image_XYZa[1], Image_XYZb[0], Image_XYZb[1]);
                  }
                }
              }
            }
          }
        }


      }
    }



    if (Select3D.pivotDisplayReference) {

      float[] P = Select3D.getPivot();

      float x0 = P[0];
      float y0 = P[1];
      float z0 = P[2];

      float[][] Pivot_Vertices = computePivotAxisVertices(x0, y0, z0, 5);

      int[][] Pivot_Lines = {
        {
          0, 1
        }
        , {
          0, 2
        }
        , {
          0, 3
        }
      };


      for (int f = 0; f < Pivot_Lines.length; f++) {

        DrawStyle axisStyle;
        if (f == 0) axisStyle = AXIS_X_STYLE;
        else if (f == 1) axisStyle = AXIS_Y_STYLE;
        else axisStyle = AXIS_Z_STYLE;

        axisStyle.applyStyle();

        int a = Pivot_Lines[f][0];
        int b = Pivot_Lines[f][1];

        float x1 = Pivot_Vertices[a][0] * overallScale;
        float y1 = Pivot_Vertices[a][1] * overallScale;
        float z1 = Pivot_Vertices[a][2] * overallScale;

        float x2 = Pivot_Vertices[b][0] * overallScale;
        float y2 = Pivot_Vertices[b][1] * overallScale;
        float z2 = Pivot_Vertices[b][2] * overallScale;

        float[] Image_XYZa = WIN3D.calculate_Perspective_Internally(x1, y1, z1);
        float[] Image_XYZb = WIN3D.calculate_Perspective_Internally(x2, y2, z2);

        if ((Image_XYZa[2] > 0) && (Image_XYZb[2] > 0)) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
          if (isInside(Image_XYZa[0], Image_XYZa[1], axisStyle.innerWinX1, axisStyle.innerWinY1, axisStyle.innerWinX2, axisStyle.innerWinY2)) {
            if (isInside(Image_XYZb[0], Image_XYZb[1], axisStyle.innerWinX1, axisStyle.innerWinY1, axisStyle.innerWinX2, axisStyle.innerWinY2)) {
              line(Image_XYZa[0], Image_XYZa[1], Image_XYZb[0], Image_XYZb[1]);
            }
          }
        }
      }

    }

    popMatrix();

    strokeWeight(0);
  }




  // Clips a closed polygon of camera-space points ({x, y, z} triples)
  // against the near plane (z > NEAR_Z), using the same cyclic
  // Sutherland-Hodgman technique as clipPolygon_halfPlane below -
  // including the edge that wraps from the last vertex back to the
  // first, so a polygon that starts (or ends) behind the camera still
  // gets a correctly clipped edge there
  float[][] clipPolygon_nearPlane (float[][] poly) {
    int n = poly.length;
    if (n == 0) return poly;

    ArrayList<float[]> out = new ArrayList<float[]>();

    for (int i = 0; i < n; i++) {
      float[] curr = poly[i];
      float[] prev = poly[(i - 1 + n) % n];

      boolean currIn = curr[2] > NEAR_Z;
      boolean prevIn = prev[2] > NEAR_Z;

      if (currIn != prevIn) {
        float t = (NEAR_Z - prev[2]) / (curr[2] - prev[2]);
        out.add(new float[]{
          prev[0] + t * (curr[0] - prev[0]),
          prev[1] + t * (curr[1] - prev[1]),
          NEAR_Z
        });
      }
      if (currIn) {
        out.add(curr);
      }
    }

    return out.toArray(new float[out.size()][]);
  }

  float[][] clipPolygon_toWindow (float[][] poly, float xmin, float ymin, float xmax, float ymax) {
    float[][] result = poly;
    result = clipPolygon_halfPlane(result,  1,  0, xmin);  //  x >= xmin
    result = clipPolygon_halfPlane(result, -1,  0, -xmax); //  x <= xmax
    result = clipPolygon_halfPlane(result,  0,  1, ymin);  //  y >= ymin
    result = clipPolygon_halfPlane(result,  0, -1, -ymax); //  y <= ymax

    // Each clipPolygon_halfPlane() pass only ever keeps a point already
    // satisfying that pass's own constraint, or replaces it with a fresh
    // intersection point computed to lie exactly on that pass's boundary
    // (clipPolygon_intersect()'s "t" below) - with exact arithmetic every
    // surviving point would end up inside [xmin,xmax]x[ymin,ymax] to the
    // float. It isn't exact in practice: rotating a selection/model close
    // to the camera drives some of its camera-space z very close to
    // NEAR_Z, and dividing by a z that small (clipAndProject's own x/z,
    // y/z perspective divide, above) blows the resulting image-space
    // coordinates up to the thousands or millions - at that scale, two
    // of this same edge's endpoints can agree in every significant digit
    // a 32-bit float has room for, so clipPolygon_intersect()'s own
    // "da - db" (the two ends' signed distance from the boundary line)
    // loses most or all of its precision to cancellation, and the "t"
    // it divides by that difference can come out far enough off 0..1
    // that the "intersection" it computes lands outside the window
    // instead of exactly on its edge. A plain clamp here is the
    // reliable fix for that - every point clipPolygon_halfPlane() kept
    // outright was already in range (clamping it is a no-op), and every
    // point it just computed was only ever meant to sit exactly on one
    // of these 4 boundaries anyway, so pinning it there if float
    // precision missed is correcting the intended result, not
    // overriding it.
    for (int i = 0; i < result.length; i++) {
      result[i][0] = constrain(result[i][0], xmin, xmax);
      result[i][1] = constrain(result[i][1], ymin, ymax);
    }

    return result;
  }

  float[][] clipPolygon_halfPlane (float[][] poly, float nx, float ny, float d) {
    int n = poly.length;
    if (n == 0) return poly;

    ArrayList<float[]> out = new ArrayList<float[]>();

    for (int i = 0; i < n; i++) {
      float[] curr = poly[i];
      float[] prev = poly[(i - 1 + n) % n];

      boolean currIn = (nx * curr[0] + ny * curr[1] - d) >= 0;
      boolean prevIn = (nx * prev[0] + ny * prev[1] - d) >= 0;

      if (currIn != prevIn) {
        out.add(clipPolygon_intersect(prev, curr, nx, ny, d));
      }
      if (currIn) {
        out.add(curr);
      }
    }

    return out.toArray(new float[out.size()][]);
  }

  float[] clipPolygon_intersect (float[] a, float[] b, float nx, float ny, float d) {
    float da = nx * a[0] + ny * a[1] - d;
    float db = nx * b[0] + ny * b[1] - d;
    float t = da / (da - db);
    return new float[]{ a[0] + t * (b[0] - a[0]), a[1] + t * (b[1] - a[1]) };
  }

  // Clips camVertices (camera-space {x, y, z} triples, in order around the
  // face/polyline) against the near plane, projects the surviving points
  // to image space, and clips those against the given style's window
  // bounds. Returns the resulting 2D vertex loop (possibly empty).
  float[][] clipAndProject (ArrayList<float[]> camVertices, DrawStyle style) {
    float[][] nearClipped = clipPolygon_nearPlane(
      camVertices.toArray(new float[camVertices.size()][])
    );

    ArrayList<float[]> faceVertices = new ArrayList<float[]>();
    for (int i = 0; i < nearClipped.length; i++) {
      float[] cam = nearClipped[i];
      float[] image = WIN3D.calculate_Perspective_fromCameraSpace(cam[0], cam[1], cam[2]);
      faceVertices.add(new float[]{ image[0], image[1] });
    }

    return clipPolygon_toWindow(
      faceVertices.toArray(new float[faceVertices.size()][]),
      style.innerWinX1, style.innerWinY1, style.innerWinX2, style.innerWinY2
    );
  }

  // Fills the clipped shape immediately if the style has a fill (fill
  // topology varies per shape, so unlike the outline below it isn't safe
  // to batch without triangulating), then records its outline into
  // edgeBatch for drawEdgeBatch() to stroke afterward - every shape drawn
  // for a given style/category shares the exact same stroke color and
  // weight, so there's nothing per-shape lost by drawing all their
  // outlines in one batched pass instead of each shape also stroking its
  // own outline individually as part of its own beginShape()/endShape().
  void drawClosedShape (ArrayList<float[]> camVertices, DrawStyle style, ArrayList<float[][]> edgeBatch) {
    float[][] vertices = clipAndProject(camVertices, style);

    if (vertices.length == 0) return;

    if (alpha(style.fillColor) != 0) {
      noStroke();
      fill(style.fillColor);
      beginShape();
      for (int i = 0; i < vertices.length; i++) {
        vertex(vertices[i][0], vertices[i][1]);
      }
      endShape(CLOSE);
    }

    edgeBatch.add(vertices);
  }

  // Strokes every shape recorded by drawClosedShape() above in one
  // beginShape(LINES) pass.
  void drawEdgeBatch (ArrayList<float[][]> edgeBatch, DrawStyle style) {
    if (edgeBatch.size() == 0) return;

    noFill();
    strokeWeight(style.strokeWeight);
    stroke(style.strokeColor);

    beginShape(LINES);
    for (int p = 0; p < edgeBatch.size(); p++) {
      float[][] vertices = edgeBatch.get(p);
      int n = vertices.length;

      for (int i = 0; i < n; i++) {
        int i_next = (i + 1) % n;
        vertex(vertices[i][0], vertices[i][1]);
        vertex(vertices[i_next][0], vertices[i_next][1]);
      }
    }
    endShape();
  }


}
