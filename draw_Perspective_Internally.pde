void SOLARCHVISION_draw_Perspective_Internally () {

  if (current_ObjectCategory == ObjectCategory.LANDPOINT) {

    if (Select3D.LandPoint_displayPoints) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(255, 0, 255, 127);

      strokeWeight(2);

      ellipseMode(CENTER);

      float R = 10;

      for (int o = Select3D.LandPoint_ids.length - 1; o >= 0; o--) {

        int OBJ_ID = Select3D.LandPoint_ids[o];


        int i = OBJ_ID / Land3D.num_columns;
        int j = OBJ_ID % Land3D.num_columns;

        float x = Land3D.Mesh[i][j][0] * OBJECTS_scale;
        float y = Land3D.Mesh[i][j][1] * OBJECTS_scale;
        float z = -Land3D.Mesh[i][j][2] * OBJECTS_scale;

        float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

        if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
          if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX + R, -0.5 * WIN3D.dY + R, 0.5 * WIN3D.dX - R, 0.5 * WIN3D.dY - R)) ellipse(Image_XYZ[0], Image_XYZ[1], R, R);
        }

      }

      strokeWeight(0);

      popMatrix();
    }
  }

  if (current_ObjectCategory == ObjectCategory.CAMERA) {

    if (Select3D.Camera_displayEdges) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(255, 127, 0);
      strokeWeight(2);

      {
        for (int o = Select3D.Camera_ids.length - 1; o >= 0; o--) {

          int f = Select3D.Camera_ids[o];

          beginShape();

          for (int j = 0; j < allCameras.Faces[f].length; j++) {

            int vNo = allCameras.Faces[f][j];

            float x = allCameras.Vertices[vNo][0] * OBJECTS_scale;
            float y = allCameras.Vertices[vNo][1] * OBJECTS_scale;
            float z = -allCameras.Vertices[vNo][2] * OBJECTS_scale;

            float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

            if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
              if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
            }
          }

          endShape(CLOSE);
        }
      }

      strokeWeight(0);

      popMatrix();
    }
  }

  if (current_ObjectCategory == ObjectCategory.SECTION) {

    if (Select3D.Section_displayEdges) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(255, 127, 0);
      strokeWeight(2);

      {
        for (int o = Select3D.Section_ids.length - 1; o >= 0; o--) {

          int f = Select3D.Section_ids[o];

          beginShape();

          for (int j = 0; j < allSections.Faces[f].length; j++) {

            int vNo = allSections.Faces[f][j];

            float x = allSections.Vertices[vNo][0] * OBJECTS_scale;
            float y = allSections.Vertices[vNo][1] * OBJECTS_scale;
            float z = -allSections.Vertices[vNo][2] * OBJECTS_scale;

            float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

            if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
              if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
            }
          }

          endShape(CLOSE);
        }
      }

      strokeWeight(0);

      popMatrix();
    }
  }

  if (current_ObjectCategory == ObjectCategory.SOLID) {

    if (Select3D.Solid_displayEdges) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(255, 127, 0);
      strokeWeight(2);

      {
        for (int o = Select3D.Solid_ids.length - 1; o >= 0; o--) {

          int OBJ_ID = Select3D.Solid_ids[o];

          for (int plane_type = 0; plane_type < allSolids.num_visualFaces; plane_type++) {

            int f = OBJ_ID * allSolids.num_visualFaces + plane_type;

            beginShape();

            for (int j = 0; j < allSolids.Faces[f].length; j++) {

              int vNo = allSolids.Faces[f][j];

              float x = allSolids.Vertices[vNo][0] * OBJECTS_scale;
              float y = allSolids.Vertices[vNo][1] * OBJECTS_scale;
              float z = -allSolids.Vertices[vNo][2] * OBJECTS_scale;

              float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

              if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
                if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
              }
            }

            endShape(CLOSE);
          }
        }

      }


      strokeWeight(0);

      popMatrix();
    }
  }

  if (current_ObjectCategory == ObjectCategory.MODEL2D) {

    if (Select3D.Model2D_displayEdges) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(255, 127, 0);
      strokeWeight(2);

      {
        for (int o = Select3D.Model2D_ids.length - 1; o >= 0; o--) {

          int OBJ_ID = Select3D.Model2D_ids[o];

          for (int plane_type = 0; plane_type < allModel2Ds.num_visualFaces; plane_type++) {

            int f = OBJ_ID * allModel2Ds.num_visualFaces + plane_type;

            beginShape();

            for (int j = 0; j < allModel2Ds.Faces[f].length; j++) {

              int vNo = allModel2Ds.Faces[f][j];

              float x = allModel2Ds.Vertices[vNo][0] * OBJECTS_scale;
              float y = allModel2Ds.Vertices[vNo][1] * OBJECTS_scale;
              float z = -allModel2Ds.Vertices[vNo][2] * OBJECTS_scale;

              float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

              if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
                if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
              }
            }

            endShape(CLOSE);
          }
        }
      }

      strokeWeight(0);

      popMatrix();
    }
  }

  if (current_ObjectCategory == ObjectCategory.MODEL1D) {

    if (Select3D.Model1D_displayEdges) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(255, 127, 0);
      strokeWeight(2);

      {
        for (int o = Select3D.Model1D_ids.length - 1; o >= 0; o--) {

          int f = Select3D.Model1D_ids[o];

          beginShape();

          for (int j = 0; j < allModel1Ds.Faces[f].length; j++) {

            int vNo = allModel1Ds.Faces[f][j];

            float x = allModel1Ds.Vertices[vNo][0] * OBJECTS_scale;
            float y = allModel1Ds.Vertices[vNo][1] * OBJECTS_scale;
            float z = -allModel1Ds.Vertices[vNo][2] * OBJECTS_scale;

            float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

            if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
              if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
            }
          }

          endShape(CLOSE);

        }
      }

      strokeWeight(0);

      popMatrix();
    }
  }

  if (current_ObjectCategory == ObjectCategory.FACE) {

    if (Select3D.Face_displayEdges) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(127, 0, 255);
      strokeWeight(2);

      for (int o = Select3D.Face_ids.length - 1; o >= 0; o--) {

        int f = Select3D.Face_ids[o];

        int tessellation = allFaces.getTessellation(f);

        int totalNumberOfSubs = 1;
        if (allFaces.getMaterial(f) == 0) {
          tessellation += allFaces.displayTessellation;
        }
        if (tessellation > 0) totalNumberOfSubs = allFaces.nodes[f].length * int(funcs.roundTo(pow(4, tessellation - 1), 1));

        float[][] base_Vertices = new float [allFaces.nodes[f].length][3];
        for (int j = 0; j < allFaces.nodes[f].length; j++) {
          int vNo = allFaces.nodes[f][j];
          base_Vertices[j][0] = allPoints.getX(vNo);
          base_Vertices[j][1] = allPoints.getY(vNo);
          base_Vertices[j][2] = allPoints.getZ(vNo);
        }

        for (int n = 0; n < totalNumberOfSubs; n++) {

          float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

          beginShape();

          for (int s = 0; s < subFace.length; s++) {

            float x = subFace[s][0] * OBJECTS_scale;
            float y = subFace[s][1] * OBJECTS_scale;
            float z = -subFace[s][2] * OBJECTS_scale;

            float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

            if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
              if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
            }
          }

          endShape(CLOSE);
        }

      }

      strokeWeight(0);

      popMatrix();
    }


    if (Select3D.Face_displayVertexCount) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      fill(0);

      stroke(0);
      strokeWeight(0);

      textSize(1.5 * MessageSize);
      textAlign(CENTER, BOTTOM);

      for (int o = Select3D.Face_ids.length - 1; o >= 0; o--) {

        int f = Select3D.Face_ids[o];

        for (int j = 0; j < allFaces.nodes[f].length; j++) {
          int vNo = allFaces.nodes[f][j];

          float x = allPoints.getX(vNo) * OBJECTS_scale;
          float y = allPoints.getY(vNo) * OBJECTS_scale;
          float z = -allPoints.getZ(vNo) * OBJECTS_scale;

          float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

          if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
            if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) {
              text(nf(j + 1, 0), Image_XYZ[0], Image_XYZ[1]);
            }
          }
        }
      }

      strokeWeight(0);

      popMatrix();
    }
  }


  if (current_ObjectCategory == ObjectCategory.POLYLINE) {

    if (Select3D.Polyline_displayVertexCount) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      fill(0);

      stroke(0);
      strokeWeight(0);

      textSize(1.5 * MessageSize);
      textAlign(CENTER, BOTTOM);

      for (int o = Select3D.Polyline_ids.length - 1; o >= 0; o--) {

        int f = Select3D.Polyline_ids[o];

        for (int j = 0; j < allPolylines.nodes[f].length; j++) {
          int vNo = allPolylines.nodes[f][j];

          float x = allPoints.getX(vNo) * OBJECTS_scale;
          float y = allPoints.getY(vNo) * OBJECTS_scale;
          float z = -allPoints.getZ(vNo) * OBJECTS_scale;

          float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

          if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
            if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) {
              text(nf(j + 1, 0), Image_XYZ[0], Image_XYZ[1]);
            }
          }
        }
      }

      strokeWeight(0);

      popMatrix();
    }
  }


  if (current_ObjectCategory == ObjectCategory.VERTEX) {

    if (Select3D.Vertex_displayVertices) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(255, 0, 255, 127);

      strokeWeight(2);

      ellipseMode(CENTER);

      float R = 10;

      for (int o = Select3D.Vertex_ids.length - 1; o >= 0; o--) {

        int vNo = Select3D.Vertex_ids[o];

        float x = allPoints.getX(vNo) * OBJECTS_scale;
        float y = allPoints.getY(vNo) * OBJECTS_scale;
        float z = -allPoints.getZ(vNo) * OBJECTS_scale;

        float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

        if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
          if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX + R, -0.5 * WIN3D.dY + R, 0.5 * WIN3D.dX - R, 0.5 * WIN3D.dY - R)) ellipse(Image_XYZ[0], Image_XYZ[1], R, R);
        }
      }

      strokeWeight(0);

      popMatrix();
    }
  }



  if (current_ObjectCategory == ObjectCategory.SOFTVERTEX) {

    if (Select3D.Vertex_displayVertices) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      strokeWeight(0);

      ellipseMode(CENTER);

      float R = 5;

      for (int q = 0; q < Select3D.softSelection_ids.length; q++) {

        int vNo = Select3D.softSelection_ids[q];

        float _u = Select3D.softSelection_values[q];

        float x = allPoints.getX(vNo) * OBJECTS_scale;
        float y = allPoints.getY(vNo) * OBJECTS_scale;
        float z = -allPoints.getZ(vNo) * OBJECTS_scale;

        float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

        if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
          if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX + R, -0.5 * WIN3D.dY + R, 0.5 * WIN3D.dX - R, 0.5 * WIN3D.dY - R)) {

            float[] COL = PAINT.getColorStyle(14, _u); // <<<<<<<<<<<<<<<<<
            fill(COL[1], COL[2], COL[3], COL[0]);
            stroke(COL[1], COL[2], COL[3], COL[0]);

            ellipse(Image_XYZ[0], Image_XYZ[1], R, R);
          }
        }
      }


      strokeWeight(0);

      popMatrix();
    }
  }



  if (current_ObjectCategory == ObjectCategory.GROUP) {

    if (Select3D.Group_displayEdges) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(127);
      strokeWeight(2);

      for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

        int OBJ_ID = Select3D.Group_ids[o];


        for (int f = allGroups.getStart_Face(OBJ_ID); f <= allGroups.getStop_Face(OBJ_ID); f++) {
          if ((0 <= f) && (f < allFaces.nodes.length)) {

            int tessellation = allFaces.getTessellation(f);

            int totalNumberOfSubs = 1;
            if (allFaces.getMaterial(f) == 0) {
              tessellation += allFaces.displayTessellation;
            }
            if (tessellation > 0) totalNumberOfSubs = allFaces.nodes[f].length * int(funcs.roundTo(pow(4, tessellation - 1), 1));

            float[][] base_Vertices = new float [allFaces.nodes[f].length][3];
            for (int j = 0; j < allFaces.nodes[f].length; j++) {
              int vNo = allFaces.nodes[f][j];
              base_Vertices[j][0] = allPoints.getX(vNo);
              base_Vertices[j][1] = allPoints.getY(vNo);
              base_Vertices[j][2] = allPoints.getZ(vNo);
            }

            for (int n = 0; n < totalNumberOfSubs; n++) {

              float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

              beginShape();

              for (int s = 0; s < subFace.length; s++) {

                float x = subFace[s][0] * OBJECTS_scale;
                float y = subFace[s][1] * OBJECTS_scale;
                float z = -subFace[s][2] * OBJECTS_scale;

                float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

                if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
                  if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
                }
              }

              endShape(CLOSE);
            }
          }
        }


        for (int f = allGroups.getStart_Polyline(OBJ_ID); f <= allGroups.getStop_Polyline(OBJ_ID); f++) {
          if ((0 <= f) && (f < allPolylines.nodes.length)) {

            beginShape();

            for (int vNo = 0; vNo < allPolylines.nodes[f].length; vNo++) {

              float x = allPoints.getX(vNo) * OBJECTS_scale;
              float y = allPoints.getY(vNo) * OBJECTS_scale;
              float z = -allPoints.getZ(vNo) * OBJECTS_scale;

              float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

              if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
                if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
              }
            }

            endShape(CLOSE);
          }
        }


        for (int f = allGroups.getStart_Model1D(OBJ_ID); f <= allGroups.getStop_Model1D(OBJ_ID); f++) {

          if ((0 <= f) && (f < allModel1Ds.Faces.length)) {

            beginShape();

            for (int j = 0; j < allModel1Ds.Faces[f].length; j++) {

              int vNo = allModel1Ds.Faces[f][j];

              float x = allModel1Ds.Vertices[vNo][0] * OBJECTS_scale;
              float y = allModel1Ds.Vertices[vNo][1] * OBJECTS_scale;
              float z = -allModel1Ds.Vertices[vNo][2] * OBJECTS_scale;

              float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

              if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
                if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
              }
            }

            endShape(CLOSE);
          }
        }


        for (int f = allGroups.getStart_Model2D(OBJ_ID); f <= allGroups.getStop_Model2D(OBJ_ID); f++) {

          if ((0 <= f) && (f < allModel2Ds.Faces.length)) {

            beginShape();

            for (int j = 0; j < allModel2Ds.Faces[f].length; j++) {

              int vNo = allModel2Ds.Faces[f][j];

              float x = allModel2Ds.Vertices[vNo][0] * OBJECTS_scale;
              float y = allModel2Ds.Vertices[vNo][1] * OBJECTS_scale;
              float z = -allModel2Ds.Vertices[vNo][2] * OBJECTS_scale;

              float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

              if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
                if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
              }
            }

            endShape(CLOSE);
          }
        }

        for (int q = allGroups.getStart_Solid(OBJ_ID); q <= allGroups.getStop_Solid(OBJ_ID); q++) {

          if ((0 < q) && (q < allSolids.Faces.length)) {

            for (int plane_type = 0; plane_type < allSolids.num_visualFaces; plane_type++) {

              int f = (q - 1) * allSolids.num_visualFaces + plane_type + 1;

              if ((0 <= f) && (f < allSolids.Faces.length)) {

                beginShape();

                for (int j = 0; j < allSolids.Faces[f].length; j++) {

                  int vNo = allSolids.Faces[f][j];

                  float x = allSolids.Vertices[vNo][0] * OBJECTS_scale;
                  float y = allSolids.Vertices[vNo][1] * OBJECTS_scale;
                  float z = -allSolids.Vertices[vNo][2] * OBJECTS_scale;

                  float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

                  if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
                    if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
                  }
                }

                endShape(CLOSE);
              }
            }
          }
        }
      }


      strokeWeight(0);

      popMatrix();
    }


    if (Select3D.Group_displayBox) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(0, 127, 0, 127);
      strokeWeight(2);

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
        {
          posX_min, posY_min, posZ_min
        }
        ,
        {
          posX_max, posY_min, posZ_min
        }
        ,
        {
          posX_max, posY_max, posZ_min
        }
        ,
        {
          posX_min, posY_max, posZ_min
        }
        ,
        {
          posX_min, posY_min, posZ_max
        }
        ,
        {
          posX_max, posY_min, posZ_max
        }
        ,
        {
          posX_max, posY_max, posZ_max
        }
        ,
        {
          posX_min, posY_max, posZ_max
        }
      };

      for (int i = 0; i < BoundingBox_Vertices.length; i++) {

        float x = BoundingBox_Vertices[i][0] - posX;
        float y = BoundingBox_Vertices[i][1] - posY;
        float z = BoundingBox_Vertices[i][2] - posZ;

        float[] A = Select3D.translateInside_ReferencePivot(x, y, z);

        x = A[0];
        y = A[1];
        z = A[2];

        BoundingBox_Vertices[i][0] = x;
        BoundingBox_Vertices[i][1] = y;
        BoundingBox_Vertices[i][2] = z;
      }

      boolean isEmpty = true;
      for (int i = 1; i < BoundingBox_Vertices.length; i++) {
        if(
          BoundingBox_Vertices[0][0] != BoundingBox_Vertices[i][0] ||
          BoundingBox_Vertices[0][1] != BoundingBox_Vertices[i][1] ||
          BoundingBox_Vertices[0][2] != BoundingBox_Vertices[i][2]
        ) {
          isEmpty = false;
        }
      }

      if(!isEmpty) {
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

          beginShape();

          for (int g = 0; g < BoundingBox_Faces[f].length; g++) {

            int vNo = BoundingBox_Faces[f][g];

            float x = BoundingBox_Vertices[vNo][0] * OBJECTS_scale;
            float y = BoundingBox_Vertices[vNo][1] * OBJECTS_scale;
            float z = -BoundingBox_Vertices[vNo][2] * OBJECTS_scale;

            float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

            if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
              if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
            }
          }
          endShape(CLOSE);
        }
      }

      strokeWeight(0);

      popMatrix();


      Select3D.alignX = keep_selection_alignX;
      Select3D.alignY = keep_selection_alignY;
      Select3D.alignZ = keep_selection_alignZ;
    }




    if (Select3D.Group_displayPivot) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(255, 127, 0, 127);

      strokeWeight(5);

      if(allGroups.Pivots.length > 0) {
        for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

          int OBJ_ID = Select3D.Group_ids[o];

          float[][] Pivot_Vertices = {
            {
              0, 0, 0
            }
            ,
            {
              1, 0, 0
            }
            ,
            {
              0, 1, 0
            }
            ,
            {
              0, 0, 1
            }
          };

          float x0 = allGroups.Pivots[OBJ_ID][0];
          float y0 = allGroups.Pivots[OBJ_ID][1];
          float z0 = allGroups.Pivots[OBJ_ID][2];

          for (int i = 0; i < Pivot_Vertices.length; i++) {

            float x = Pivot_Vertices[i][0];
            float y = Pivot_Vertices[i][1];
            float z = Pivot_Vertices[i][2];

            float r = 10; // <<<<<<<<< display size

            x *= r;
            y *= r;
            z *= r;

            float[] O = Select3D.translateInside_ReferencePivot(0, 0, 0);
            float[] A = Select3D.translateInside_ReferencePivot(x, y, z);

            float dx = A[0] - O[0];
            float dy = A[1] - O[1];
            float dz = A[2] - O[2];

            Pivot_Vertices[i][0] = x0 + dx;
            Pivot_Vertices[i][1] = y0 + dy;
            Pivot_Vertices[i][2] = z0 + dz;
          }


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
            float z1 = -Pivot_Vertices[a][2] * OBJECTS_scale;

            float x2 = Pivot_Vertices[b][0] * OBJECTS_scale;
            float y2 = Pivot_Vertices[b][1] * OBJECTS_scale;
            float z2 = -Pivot_Vertices[b][2] * OBJECTS_scale;

            float[] Image_XYZa = WIN3D.calculate_Perspective_Internally(x1, y1, z1);
            float[] Image_XYZb = WIN3D.calculate_Perspective_Internally(x2, y2, z2);

            if ((Image_XYZa[2] > 0) && (Image_XYZb[2] > 0)) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
              if (isInside(Image_XYZa[0], Image_XYZa[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) {
                if (isInside(Image_XYZb[0], Image_XYZb[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) {
                  line(Image_XYZa[0], Image_XYZa[1], Image_XYZb[0], Image_XYZb[1]);
                }
              }
            }
          }
        }
      }


      strokeWeight(0);

      popMatrix();
    }
  }



  if (Select3D.displayReferencePivot) {

    pushMatrix();

    translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

    noFill();

    strokeWeight(2);

    float[][] Pivot_Vertices = {
      {
        0, 0, 0
      }
      ,
      {
        1, 0, 0
      }
      ,
      {
        0, 1, 0
      }
      ,
      {
        0, 0, 1
      }
    };

    float[] P = Select3D.getPivot();

    float x0 = P[0];
    float y0 = P[1];
    float z0 = P[2];

    for (int i = 0; i < Pivot_Vertices.length; i++) {

      float x = Pivot_Vertices[i][0];
      float y = Pivot_Vertices[i][1];
      float z = Pivot_Vertices[i][2];

      float r = 5; // <<<<<<<<< display size

      x *= r;
      y *= r;
      z *= r;

      float[] O = Select3D.translateInside_ReferencePivot(0, 0, 0);
      float[] A = Select3D.translateInside_ReferencePivot(x, y, z);

      float dx = A[0] - O[0];
      float dy = A[1] - O[1];
      float dz = A[2] - O[2];

      Pivot_Vertices[i][0] = x0 + dx;
      Pivot_Vertices[i][1] = y0 + dy;
      Pivot_Vertices[i][2] = z0 + dz;
    }

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

      if (f == 0) stroke(255, 0, 0);
      if (f == 1) stroke(0, 0, 255);
      if (f == 2) stroke(127, 127, 0);

      int a = Pivot_Lines[f][0];
      int b = Pivot_Lines[f][1];

      float x1 = Pivot_Vertices[a][0] * OBJECTS_scale;
      float y1 = Pivot_Vertices[a][1] * OBJECTS_scale;
      float z1 = -Pivot_Vertices[a][2] * OBJECTS_scale;

      float x2 = Pivot_Vertices[b][0] * OBJECTS_scale;
      float y2 = Pivot_Vertices[b][1] * OBJECTS_scale;
      float z2 = -Pivot_Vertices[b][2] * OBJECTS_scale;

      float[] Image_XYZa = WIN3D.calculate_Perspective_Internally(x1, y1, z1);
      float[] Image_XYZb = WIN3D.calculate_Perspective_Internally(x2, y2, z2);

      if ((Image_XYZa[2] > 0) && (Image_XYZb[2] > 0)) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
        if (isInside(Image_XYZa[0], Image_XYZa[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) {
          if (isInside(Image_XYZb[0], Image_XYZb[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) {
            line(Image_XYZa[0], Image_XYZa[1], Image_XYZb[0], Image_XYZb[1]);
          }
        }
      }
    }

    strokeWeight(0);

    popMatrix();
  }
}
