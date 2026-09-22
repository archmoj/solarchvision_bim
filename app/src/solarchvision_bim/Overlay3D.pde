class Overlay3D {

  final DrawStyle LANDPOINT_STYLE      = new DrawStyle(4, color(255, 0, 255, 127));
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

      float pad = 0.5 * strokeWeight + 1;

      innerWinX1 = -0.5 * WIN3D.dX + pad;
      innerWinY1 = -0.5 * WIN3D.dY + pad;
      innerWinX2 = 0.5 * WIN3D.dX - pad;
      innerWinY2 = 0.5 * WIN3D.dY - pad;
    }
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
  // Pulled out of draw()'s Group_displayBox handling: this was the
  // purely computational front half of that block (temporarily forcing
  // Select3D's alignX/Y/Z to 0 so the box is measured from its own
  // centre, deriving the 8 corners from Select3D.BoundingBox's min/max
  // rows, transforming each through translateInside_ReferencePivot,
  // then checking whether they're all still coincident) - the drawing
  // loop that follows it, and the alignX/Y/Z save/restore around the
  // whole thing, are preserved here too since restoring Select3D's
  // align fields is this function's responsibility, not the caller's.
  class GroupBoxVertices {
    float[][] vertices; // 8 corners, transformed per the box's own rotation (see above)
    boolean isEmpty;
  }

  GroupBoxVertices computeGroupBoxVertices () {
    int keep_selection_alignX = Select3D.alignX;
    int keep_selection_alignY = Select3D.alignY;
    int keep_selection_alignZ = Select3D.alignZ;

    Select3D.alignX = 0; // apply the centre
    Select3D.alignY = 0; // apply the centre
    Select3D.alignZ = 0; // apply the centre

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

    Select3D.alignX = keep_selection_alignX;
    Select3D.alignY = keep_selection_alignY;
    Select3D.alignZ = keep_selection_alignZ;

    GroupBoxVertices r = new GroupBoxVertices();
    r.vertices = BoundingBox_Vertices;
    r.isEmpty = isEmpty;
    return r;
  }

  void draw () {
    pushMatrix();

    translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

    if (current_ObjectCategory == ObjectCategory.LANDPOINT) {

      if (Select3D.LandPoint_displayPoints) {

        LANDPOINT_STYLE.applyStyle();

        ellipseMode(CENTER);

        float R = 10;

        for (int o = Select3D.LandPoint_ids.length - 1; o >= 0; o--) {

          int OBJ_ID = Select3D.LandPoint_ids[o];


          int i = OBJ_ID / Land3D.num_columns;
          int j = OBJ_ID % Land3D.num_columns;

          float x = Land3D.Mesh[i][j][0] * OBJECTS_scale;
          float y = Land3D.Mesh[i][j][1] * OBJECTS_scale;
          float z = Land3D.Mesh[i][j][2] * OBJECTS_scale;

          float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

          if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
            if (isInside(Image_XYZ[0], Image_XYZ[1], LANDPOINT_STYLE.innerWinX1 + R, LANDPOINT_STYLE.innerWinY1 + R, LANDPOINT_STYLE.innerWinX2 - R, LANDPOINT_STYLE.innerWinY2 - R)) ellipse(Image_XYZ[0], Image_XYZ[1], R, R);
          }

        }

      }
    }

    else if (current_ObjectCategory == ObjectCategory.CAMERA) {

      if (Select3D.Camera_displayEdges) {

        CAMERA_STYLE.applyStyle();

        ArrayList<float[][]> edgeBatch = new ArrayList<float[][]>();

        {
          for (int o = Select3D.Camera_ids.length - 1; o >= 0; o--) {

            int f = Select3D.Camera_ids[o];

            ArrayList<float[]> camVertices = new ArrayList<float[]>();

            for (int j = 0; j < allCameras.Faces[f].length; j++) {

              int vNo = allCameras.Faces[f][j];

              float x = allCameras.Vertices[vNo][0] * OBJECTS_scale;
              float y = allCameras.Vertices[vNo][1] * OBJECTS_scale;
              float z = allCameras.Vertices[vNo][2] * OBJECTS_scale;

              camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
            }

            drawClosedShape(camVertices, CAMERA_STYLE, edgeBatch);
          }
        }

        drawEdgeBatch(edgeBatch, CAMERA_STYLE);
      }
    }

    else if (current_ObjectCategory == ObjectCategory.SECTION) {

      if (Select3D.Section_displayEdges) {

        SECTION_STYLE.applyStyle();

        ArrayList<float[][]> edgeBatch = new ArrayList<float[][]>();

        for (int o = Select3D.Section_ids.length - 1; o >= 0; o--) {

          int f = Select3D.Section_ids[o];

          ArrayList<float[]> camVertices = new ArrayList<float[]>();

          for (int j = 0; j < allSections.Faces[f].length; j++) {

            int vNo = allSections.Faces[f][j];

            float x = allSections.Vertices[vNo][0] * OBJECTS_scale;
            float y = allSections.Vertices[vNo][1] * OBJECTS_scale;
            float z = allSections.Vertices[vNo][2] * OBJECTS_scale;

            camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
          }

          drawClosedShape(camVertices, SECTION_STYLE, edgeBatch);
        }

        drawEdgeBatch(edgeBatch, SECTION_STYLE);
      }
    }

    else if (current_ObjectCategory == ObjectCategory.SOLID) {

      if (Select3D.Solid_displayEdges) {

        SOLID_STYLE.applyStyle();

        ArrayList<float[][]> edgeBatch = new ArrayList<float[][]>();

        for (int o = Select3D.Solid_ids.length - 1; o >= 0; o--) {

          int OBJ_ID = Select3D.Solid_ids[o];

          for (int plane_type = 0; plane_type < allSolids.num_visualFaces; plane_type++) {

            int f = OBJ_ID * allSolids.num_visualFaces + plane_type;

            ArrayList<float[]> camVertices = new ArrayList<float[]>();

            for (int j = 0; j < allSolids.Faces[f].length; j++) {

              int vNo = allSolids.Faces[f][j];

              float x = allSolids.Vertices[vNo][0] * OBJECTS_scale;
              float y = allSolids.Vertices[vNo][1] * OBJECTS_scale;
              float z = allSolids.Vertices[vNo][2] * OBJECTS_scale;

              camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
            }

            drawClosedShape(camVertices, SOLID_STYLE, edgeBatch);
          }
        }

        drawEdgeBatch(edgeBatch, SOLID_STYLE);
      }
    }

    else if (current_ObjectCategory == ObjectCategory.MODEL2D) {

      if (Select3D.Model2D_displayEdges) {

        MODEL2D_STYLE.applyStyle();

        ArrayList<float[][]> edgeBatch = new ArrayList<float[][]>();

        for (int o = Select3D.Model2D_ids.length - 1; o >= 0; o--) {

          int OBJ_ID = Select3D.Model2D_ids[o];

          for (int plane_type = 0; plane_type < allModel2Ds.num_visualFaces; plane_type++) {

            int f = OBJ_ID * allModel2Ds.num_visualFaces + plane_type;

            ArrayList<float[]> camVertices = new ArrayList<float[]>();

            for (int j = 0; j < allModel2Ds.Faces[f].length; j++) {

              int vNo = allModel2Ds.Faces[f][j];

              float x = allModel2Ds.Vertices[vNo][0] * OBJECTS_scale;
              float y = allModel2Ds.Vertices[vNo][1] * OBJECTS_scale;
              float z = allModel2Ds.Vertices[vNo][2] * OBJECTS_scale;

              camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
            }

            drawClosedShape(camVertices, MODEL2D_STYLE, edgeBatch);
          }
        }

        drawEdgeBatch(edgeBatch, MODEL2D_STYLE);
      }
    }

    else if (current_ObjectCategory == ObjectCategory.MODEL1D) {

      if (Select3D.Model1D_displayEdges) {

        MODEL1D_STYLE.applyStyle();

        ArrayList<float[][]> edgeBatch = new ArrayList<float[][]>();

        for (int o = Select3D.Model1D_ids.length - 1; o >= 0; o--) {

          int f = Select3D.Model1D_ids[o];

          ArrayList<float[]> camVertices = new ArrayList<float[]>();

          for (int j = 0; j < allModel1Ds.Faces[f].length; j++) {

            int vNo = allModel1Ds.Faces[f][j];

            float x = allModel1Ds.Vertices[vNo][0] * OBJECTS_scale;
            float y = allModel1Ds.Vertices[vNo][1] * OBJECTS_scale;
            float z = allModel1Ds.Vertices[vNo][2] * OBJECTS_scale;

            camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
          }

          drawClosedShape(camVertices, MODEL1D_STYLE, edgeBatch);

        }

        drawEdgeBatch(edgeBatch, MODEL1D_STYLE);
      }
    }

    else if (current_ObjectCategory == ObjectCategory.FACE) {

      if (Select3D.Face_displayEdges) {

        FACE_EDGE_STYLE.applyStyle();

        ArrayList<float[][]> edgeBatch = new ArrayList<float[][]>();

        for (int o = Select3D.Face_ids.length - 1; o >= 0; o--) {

          int f = Select3D.Face_ids[o];

          FaceTessellation ft = computeFaceTessellation(f);
          int tessellation = ft.tessellation;
          int totalNumberOfSubs = ft.totalNumberOfSubs;
          float[][] base_Vertices = ft.base_Vertices;

          for (int n = 0; n < totalNumberOfSubs; n++) {

            float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

            ArrayList<float[]> camVertices = new ArrayList<float[]>();

            for (int s = 0; s < subFace.length; s++) {

              float x = subFace[s][0] * OBJECTS_scale;
              float y = subFace[s][1] * OBJECTS_scale;
              float z = subFace[s][2] * OBJECTS_scale;

              camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
            }

            drawClosedShape(camVertices, FACE_EDGE_STYLE, edgeBatch);
          }
        }

        drawEdgeBatch(edgeBatch, FACE_EDGE_STYLE);
      }


      if (Select3D.Face_displayVertexCount) {

        FACE_LABEL_STYLE.applyStyle();

        textSize(1.5 * MessageSize);
        textAlign(CENTER, BOTTOM);

        for (int o = Select3D.Face_ids.length - 1; o >= 0; o--) {

          int f = Select3D.Face_ids[o];

          for (int j = 0; j < allFaces.nodes[f].length; j++) {
            int vNo = allFaces.nodes[f][j];

            float x = allPoints.getX(vNo) * OBJECTS_scale;
            float y = allPoints.getY(vNo) * OBJECTS_scale;
            float z = allPoints.getZ(vNo) * OBJECTS_scale;

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


    else if (current_ObjectCategory == ObjectCategory.POLYLINE) {

      if (Select3D.Polyline_displayVertexCount) {

        POLYLINE_LABEL_STYLE.applyStyle();

        textSize(1.5 * MessageSize);
        textAlign(CENTER, BOTTOM);

        for (int o = Select3D.Polyline_ids.length - 1; o >= 0; o--) {

          int f = Select3D.Polyline_ids[o];

          for (int j = 0; j < allPolylines.nodes[f].length; j++) {
            int vNo = allPolylines.nodes[f][j];

            float x = allPoints.getX(vNo) * OBJECTS_scale;
            float y = allPoints.getY(vNo) * OBJECTS_scale;
            float z = allPoints.getZ(vNo) * OBJECTS_scale;

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


    else if (current_ObjectCategory == ObjectCategory.VERTEX) {

      if (Select3D.Vertex_displayVertices) {

        VERTEX_STYLE.applyStyle();

        ellipseMode(CENTER);

        float R = 10;

        for (int o = Select3D.Vertex_ids.length - 1; o >= 0; o--) {

          int vNo = Select3D.Vertex_ids[o];

          float x = allPoints.getX(vNo) * OBJECTS_scale;
          float y = allPoints.getY(vNo) * OBJECTS_scale;
          float z = allPoints.getZ(vNo) * OBJECTS_scale;

          float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

          if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
            if (isInside(Image_XYZ[0], Image_XYZ[1], VERTEX_STYLE.innerWinX1 + R, VERTEX_STYLE.innerWinY1 + R, VERTEX_STYLE.innerWinX2 - R, VERTEX_STYLE.innerWinY2 - R)) ellipse(Image_XYZ[0], Image_XYZ[1], R, R);
          }
        }

      }
    }



    else if (current_ObjectCategory == ObjectCategory.SOFTVERTEX) {

      if (Select3D.Vertex_displayVertices) {

        SOFTVERTEX_STYLE.applyStyle();

        ellipseMode(CENTER);

        float R = 5;

        for (int q = 0; q < Select3D.softSelection_ids.length; q++) {

          int vNo = Select3D.softSelection_ids[q];

          float _u = Select3D.softSelection_values[q];

          float x = allPoints.getX(vNo) * OBJECTS_scale;
          float y = allPoints.getY(vNo) * OBJECTS_scale;
          float z = allPoints.getZ(vNo) * OBJECTS_scale;

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



    else if (current_ObjectCategory == ObjectCategory.GROUP) {

      if (Select3D.Group_displayEdges) {

        GROUP_EDGE_STYLE.applyStyle();

        ArrayList<float[][]> edgeBatch = new ArrayList<float[][]>();

        for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

          int OBJ_ID = Select3D.Group_ids[o];


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

                  float x = subFace[s][0] * OBJECTS_scale;
                  float y = subFace[s][1] * OBJECTS_scale;
                  float z = subFace[s][2] * OBJECTS_scale;

                  camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
                }

                drawClosedShape(camVertices, GROUP_EDGE_STYLE, edgeBatch);
              }
            }
          }


          for (int f = allGroups.getStart_Polyline(OBJ_ID); f <= allGroups.getStop_Polyline(OBJ_ID); f++) {
            if ((0 <= f) && (f < allPolylines.nodes.length)) {

              ArrayList<float[]> camVertices = new ArrayList<float[]>();

              for (int vNo = 0; vNo < allPolylines.nodes[f].length; vNo++) {

                float x = allPoints.getX(vNo) * OBJECTS_scale;
                float y = allPoints.getY(vNo) * OBJECTS_scale;
                float z = allPoints.getZ(vNo) * OBJECTS_scale;

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

                float x = allModel1Ds.Vertices[vNo][0] * OBJECTS_scale;
                float y = allModel1Ds.Vertices[vNo][1] * OBJECTS_scale;
                float z = allModel1Ds.Vertices[vNo][2] * OBJECTS_scale;

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

                float x = allModel2Ds.Vertices[vNo][0] * OBJECTS_scale;
                float y = allModel2Ds.Vertices[vNo][1] * OBJECTS_scale;
                float z = allModel2Ds.Vertices[vNo][2] * OBJECTS_scale;

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

                    float x = allSolids.Vertices[vNo][0] * OBJECTS_scale;
                    float y = allSolids.Vertices[vNo][1] * OBJECTS_scale;
                    float z = allSolids.Vertices[vNo][2] * OBJECTS_scale;

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


      if (Select3D.Group_displayBox) {

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

              float x = BoundingBox_Vertices[vNo][0] * OBJECTS_scale;
              float y = BoundingBox_Vertices[vNo][1] * OBJECTS_scale;
              float z = BoundingBox_Vertices[vNo][2] * OBJECTS_scale;

              camVertices.add(WIN3D.calculate_CameraSpace_Internally(x, y, z));
            }

            drawClosedShape(camVertices, GROUP_BOX_STYLE, boxEdgeBatch);
          }
        }

        drawEdgeBatch(boxEdgeBatch, GROUP_BOX_STYLE);
      }




      if (Select3D.Group_displayPivot) {

        GROUP_PIVOT_STYLE.applyStyle();

        if(allGroups.Pivots.length > 0) {
          for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

            int OBJ_ID = Select3D.Group_ids[o];

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

              float x1 = Pivot_Vertices[a][0] * OBJECTS_scale;
              float y1 = Pivot_Vertices[a][1] * OBJECTS_scale;
              float z1 = Pivot_Vertices[a][2] * OBJECTS_scale;

              float x2 = Pivot_Vertices[b][0] * OBJECTS_scale;
              float y2 = Pivot_Vertices[b][1] * OBJECTS_scale;
              float z2 = Pivot_Vertices[b][2] * OBJECTS_scale;

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



    if (Select3D.displayReferencePivot) {

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

        float x1 = Pivot_Vertices[a][0] * OBJECTS_scale;
        float y1 = Pivot_Vertices[a][1] * OBJECTS_scale;
        float z1 = Pivot_Vertices[a][2] * OBJECTS_scale;

        float x2 = Pivot_Vertices[b][0] * OBJECTS_scale;
        float y2 = Pivot_Vertices[b][1] * OBJECTS_scale;
        float z2 = Pivot_Vertices[b][2] * OBJECTS_scale;

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
