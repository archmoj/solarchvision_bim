class solarchvision_Rotate3D {

  private final static String CLASS_STAMP = "Rotate3D";

  void selection (float x0, float y0, float z0, float r, int the_Vector) {
    r *= PI / 180; // <<<<<<<<

    float[] A = Select3D.translateInside_ReferencePivot(0, 0, 0);
    float[] B = Select3D.translateInside_ReferencePivot(x0, y0, z0);

    x0 = B[0] - A[0];
    y0 = B[1] - A[1];
    z0 = B[2] - A[2];

    if (current_ObjectCategory == ObjectCategory.LANDPOINT)       this.LandPoints(x0, y0, z0, r, the_Vector);
    else if (current_ObjectCategory == ObjectCategory.SOFTVERTEX) this.softSelection(x0, y0, z0, r, the_Vector);
    else if (current_ObjectCategory == ObjectCategory.VERTEX)     this.Vertices(x0, y0, z0, r, the_Vector);
    else if (current_ObjectCategory == ObjectCategory.POLYLINE)   this.Polylines(x0, y0, z0, r, the_Vector);
    else if (current_ObjectCategory == ObjectCategory.FACE)       this.Faces(x0, y0, z0, r, the_Vector);
    else if (current_ObjectCategory == ObjectCategory.MODEL1D)    this.Model1Ds(x0, y0, z0, r, the_Vector);
    else if (current_ObjectCategory == ObjectCategory.MODEL2D)    this.Model2Ds(x0, y0, z0, r, the_Vector);
    else if (current_ObjectCategory == ObjectCategory.SOLID)      this.Solids(x0, y0, z0, r, the_Vector);
    else if (current_ObjectCategory == ObjectCategory.CAMERA)     this.Cameras(x0, y0, z0, r, the_Vector);
    else if (current_ObjectCategory == ObjectCategory.SECTION)    this.Sections(r);
    else if (current_ObjectCategory == ObjectCategory.GROUP)      this.Groups(r, the_Vector);
  }

  private float[] rotateAroundVector (float x, float y, float z, float r, int the_Vector) {
    if (the_Vector == 2) return new float[] { x * cos(r) - y * sin(r), x * sin(r) + y * cos(r), z };
    if (the_Vector == 1) return new float[] { z * sin(r) + x * cos(r), y, z * cos(r) - x * sin(r) };
    if (the_Vector == 0) return new float[] { x, y * cos(r) - z * sin(r), y * sin(r) + z * cos(r) };
    return new float[] { x, y, z };
  }

  private float[] rotatePointAroundReferencePivot (float x, float y, float z, float r, int the_Vector) {
    float[] A = Select3D.translateOutside_ReferencePivot(x, y, z);
    float[] R = rotateAroundVector(A[0], A[1], A[2], r, the_Vector);
    return Select3D.translateInside_ReferencePivot(R[0], R[1], R[2]);
  }

  void softSelection (float x0, float y0, float z0, float r, int the_Vector) {
    for (int q = 0; q < Select3D.softSelection_ids.length; q++) {
      int f = Select3D.softSelection_ids[q];
      float v = Select3D.softSelection_values[q];

      float[] R = rotateAroundVector(allPoints.getX(f) - x0, allPoints.getY(f) - y0, allPoints.getZ(f) - z0, r * v, the_Vector);

      allPoints.setX(f, x0 + R[0]);
      allPoints.setY(f, y0 + R[1]);
      allPoints.setZ(f, z0 + R[2]);
    }

    SOLARCHVISION_model_changed();
  }

  void LandPoints (float x0, float y0, float z0, float r, int the_Vector) {
    for (int q = 0; q < Select3D.LandPoint_ids.length; q++) {
      int f = Select3D.LandPoint_ids[q];
      int i = f / Land3D.num_columns;
      int j = f % Land3D.num_columns;

      float[] R = rotateAroundVector(Land3D.Mesh[i][j][0] - x0, Land3D.Mesh[i][j][1] - y0, Land3D.Mesh[i][j][2] - z0, r, the_Vector);

      Land3D.Mesh[i][j][0] = x0 + R[0];
      Land3D.Mesh[i][j][1] = y0 + R[1];
      Land3D.Mesh[i][j][2] = z0 + R[2];
    }

    SOLARCHVISION_model_changed();
  }

  void Vertices (float x0, float y0, float z0, float r, int the_Vector) {
    for (int q = 0; q < Select3D.Vertex_ids.length; q++) {
      int f = Select3D.Vertex_ids[q];
      float[] R = rotateAroundVector(allPoints.getX(f) - x0, allPoints.getY(f) - y0, allPoints.getZ(f) - z0, r, the_Vector);

      allPoints.setX(f, x0 + R[0]);
      allPoints.setY(f, y0 + R[1]);
      allPoints.setZ(f, z0 + R[2]);
    }

    SOLARCHVISION_model_changed();
  }

  void Polylines (float x0, float y0, float z0, float r, int the_Vector) {
    int[] PolylineVertices = Select3D.get_Polyline_Vertices();

    for (int q = 0; q < PolylineVertices.length; q++) {
      int f = PolylineVertices[q];
      float[] R = rotateAroundVector(allPoints.getX(f) - x0, allPoints.getY(f) - y0, allPoints.getZ(f) - z0, r, the_Vector);

      allPoints.setX(f, x0 + R[0]);
      allPoints.setY(f, y0 + R[1]);
      allPoints.setZ(f, z0 + R[2]);
    }

    SOLARCHVISION_model_changed();
  }

  void Faces (float x0, float y0, float z0, float r, int the_Vector) {
    int[] FaceVertices = Select3D.get_Face_Vertices();

    for (int q = 0; q < FaceVertices.length; q++) {
      int f = FaceVertices[q];
      float[] R = rotateAroundVector(allPoints.getX(f) - x0, allPoints.getY(f) - y0, allPoints.getZ(f) - z0, r, the_Vector);

      allPoints.setX(f, x0 + R[0]);
      allPoints.setY(f, y0 + R[1]);
      allPoints.setZ(f, z0 + R[2]);
    }

    SOLARCHVISION_model_changed();
  }

  void Solids (float x0, float y0, float z0, float r, int the_Vector) {
    boolean allSolids_updated = false;

    for (int q = 0; q < Select3D.Solid_ids.length; q++) {
      int f = Select3D.Solid_ids[q];
      float[] R = rotateAroundVector(allSolids.get_posX(f) - x0, allSolids.get_posY(f) - y0, allSolids.get_posZ(f) - z0, r, the_Vector);

      allSolids.updatePosition(f, x0 + R[0], y0 + R[1], z0 + R[2]);

      if (the_Vector == 2) allSolids.RotateZ(f, r * 180 / PI);
      else if (the_Vector == 1) allSolids.RotateY(f, r * 180 / PI);
      else if (the_Vector == 0) allSolids.RotateX(f, r * 180 / PI);

      allSolids_updated = true;
    }

    if (allSolids_updated) allSolidImpacts.calculate_Impact_selectedSections();

    SOLARCHVISION_model_changed();
  }

  void Sections (float r) {
    for (int q = 0; q < Select3D.Section_ids.length; q++) {
      int f = Select3D.Section_ids[q];
      allSections.setR(f, allSections.getR(f) + r * 180.0 / PI);
    }

    allSolidImpacts.calculate_Impact_selectedSections();
    SOLARCHVISION_model_changed();
  }

  void Cameras (float x0, float y0, float z0, float r, int the_Vector) {
    // swapping y and z vectors to match camera's local coordinate
    if (the_Vector == 2) the_Vector = 1;
    else if (the_Vector == 1) the_Vector = 2;

    for (int q = 0; q < Select3D.Camera_ids.length; q++) {
      int f = Select3D.Camera_ids[q];
      float[] R = rotateAroundVector(allCameras.get_posX(f) - x0, allCameras.get_posY(f) - y0, allCameras.get_posZ(f) - z0, r, the_Vector);

      allCameras.set_posX(f, x0 + R[0]);
      allCameras.set_posY(f, y0 + R[1]);
      allCameras.set_posZ(f, z0 + R[2]);

      if (f == WIN3D.currentCamera) WIN3D.apply_currentCamera();
    }

    SOLARCHVISION_model_changed();
  }

  void Model1Ds (float x0, float y0, float z0, float r, int the_Vector) {
    for (int q = 0; q < Select3D.Model1D_ids.length; q++) {
      int f = Select3D.Model1D_ids[q];
      float[] R = rotateAroundVector(allModel1Ds.getX(f) - x0, allModel1Ds.getY(f) - y0, allModel1Ds.getZ(f) - z0, r, the_Vector);

      allModel1Ds.setX(f, x0 + R[0]);
      allModel1Ds.setY(f, y0 + R[1]);
      allModel1Ds.setZ(f, z0 + R[2]);

      if (the_Vector == 2) {
        allModel1Ds.setRotation(f, allModel1Ds.getRotation(f) - r); // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      }
    }

    SOLARCHVISION_model_changed();
  }

  void Model2Ds (float x0, float y0, float z0, float r, int the_Vector) {
    for (int q = 0; q < Select3D.Model2D_ids.length; q++) {
      int f = Select3D.Model2D_ids[q];
      float[] R = rotateAroundVector(allModel2Ds.getX(f) - x0, allModel2Ds.getY(f) - y0, allModel2Ds.getZ(f) - z0, r, the_Vector);

      allModel2Ds.setX(f, x0 + R[0]);
      allModel2Ds.setY(f, y0 + R[1]);
      allModel2Ds.setZ(f, z0 + R[2]);
    }

    SOLARCHVISION_model_changed();
  }

  void Groups (float r, int the_Vector) {
    int[] PolymeshVertices = Select3D.get_Group_Vertices();

    for (int q = 0; q < PolymeshVertices.length; q++) {
      int n = PolymeshVertices[q];
      float[] P = rotatePointAroundReferencePivot(allPoints.getX(n), allPoints.getY(n), allPoints.getZ(n), r, the_Vector);

      allPoints.setX(n, P[0]);
      allPoints.setY(n, P[1]);
      allPoints.setZ(n, P[2]);
    }

    boolean allSolids_updated = false;

    for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.Group_ids[o];

      float[] Ppivot = rotatePointAroundReferencePivot(allGroups.Pivots[OBJ_ID][0], allGroups.Pivots[OBJ_ID][1], allGroups.Pivots[OBJ_ID][2], r, the_Vector);
      allGroups.Pivots[OBJ_ID][0] = Ppivot[0];
      allGroups.Pivots[OBJ_ID][1] = Ppivot[1];
      allGroups.Pivots[OBJ_ID][2] = Ppivot[2];

      if (the_Vector == 2) allGroups.Pivots[OBJ_ID][8] += r * 180.0 / PI;
      else if (the_Vector == 1) allGroups.Pivots[OBJ_ID][7] += r * 180.0 / PI;
      else if (the_Vector == 0) allGroups.Pivots[OBJ_ID][6] += r * 180.0 / PI;

      for (int f = allGroups.getStart_Model1D(OBJ_ID); f <= allGroups.getStop_Model1D(OBJ_ID); f++) {
        if ((0 <= f) && (f < allModel1Ds.num)) {
          float[] P = rotatePointAroundReferencePivot(allModel1Ds.getX(f), allModel1Ds.getY(f), allModel1Ds.getZ(f), r, the_Vector);

          allModel1Ds.setX(f, P[0]);
          allModel1Ds.setY(f, P[1]);
          allModel1Ds.setZ(f, P[2]);

          if (the_Vector == 2) {
            //allModel1Ds.setRotation(f, allModel1Ds.getRotation(f) + r); // <<<<<<<<<
          } else if (the_Vector == 1) {
          } else if (the_Vector == 0) {
          }
        }
      }

      for (int f = allGroups.getStart_Model2D(OBJ_ID); f <= allGroups.getStop_Model2D(OBJ_ID); f++) {
        if ((0 <= f) && (f < allModel2Ds.num)) {
          float[] P = rotatePointAroundReferencePivot(allModel2Ds.getX(f), allModel2Ds.getY(f), allModel2Ds.getZ(f), r, the_Vector);

          allModel2Ds.setX(f, P[0]);
          allModel2Ds.setY(f, P[1]);
          allModel2Ds.setZ(f, P[2]);
        }
      }

      for (int f = allGroups.getStart_Solid(OBJ_ID); f <= allGroups.getStop_Solid(OBJ_ID); f++) {
        if ((0 <= f) && (f < allSolids.DEF.length)) {
          float[] P = rotatePointAroundReferencePivot(allSolids.get_posX(f), allSolids.get_posY(f), allSolids.get_posZ(f), r, the_Vector);

          allSolids.updatePosition(f, P[0], P[1], P[2]);

          // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Note: these rotations could be translated to locals to avoid problems!
          if (the_Vector == 2) allSolids.RotateZ(f, r * 180 / PI);
          else if (the_Vector == 1) allSolids.RotateY(f, r * 180 / PI);
          else if (the_Vector == 0) allSolids.RotateX(f, r * 180 / PI);

          allSolids_updated = true;
        }
      }
    }

    if (allSolids_updated) allSolidImpacts.calculate_Impact_selectedSections();

    SOLARCHVISION_model_changed();
  }
}
