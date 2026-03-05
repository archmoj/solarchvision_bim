class solarchvision_Scale3D {

  private final static String CLASS_STAMP = "Scale3D";

  void selection (float x0, float y0, float z0, float sx, float sy, float sz) {

    float[] O = Select3D.translateOutside_ReferencePivot(x0, y0, z0);

    x0 = O[0];
    y0 = O[1];
    z0 = O[2];

    if (current_ObjectCategory == ObjectCategory.LANDPOINT) {
      this.LandPoints(x0, y0, z0, sx, sy, sz);
    }

    if (current_ObjectCategory == ObjectCategory.SOFTVERTEX) {
      this.softSelection(x0, y0, z0, sx, sy, sz);
    }

    if (current_ObjectCategory == ObjectCategory.VERTEX) {
      this.Vertices(x0, y0, z0, sx, sy, sz);
    }

    if (current_ObjectCategory == ObjectCategory.POLYLINE) {
      this.Polylines(x0, y0, z0, sx, sy, sz);
    }

    if (current_ObjectCategory == ObjectCategory.FACE) {
      this.Faces(x0, y0, z0, sx, sy, sz);
    }

    if (current_ObjectCategory == ObjectCategory.GROUP) {
      this.Groups(x0, y0, z0, sx, sy, sz);
    }

    if (current_ObjectCategory == ObjectCategory.MODEL2D) {
      this.Model2Ds(x0, y0, z0, sx, sy, sz);
    }

    if (current_ObjectCategory == ObjectCategory.MODEL1D) {
      this.Model1Ds(x0, y0, z0, sx, sy, sz);
    }

    if (current_ObjectCategory == ObjectCategory.SOLID) {
      this.Solids(x0, y0, z0, sx, sy, sz);
    }

    if (current_ObjectCategory == ObjectCategory.CAMERA) {
      this.Cameras(x0, y0, z0, sx, sy, sz);
    }

    if (current_ObjectCategory == ObjectCategory.SECTION) {
      this.Sections(sx, sy);
    }

  }


  void LandPoints (float x0, float y0, float z0, float sx, float sy, float sz) {

    for (int q = 0; q < Select3D.LandPoint_ids.length; q++) {

      int f = Select3D.LandPoint_ids[q];

      int i = f / Land3D.num_columns;
      int j = f % Land3D.num_columns;

      float x = Land3D.Mesh[i][j][0];
      float y = Land3D.Mesh[i][j][1];
      float z = Land3D.Mesh[i][j][2];

      float[] A = Select3D.translateOutside_ReferencePivot(x, y, z);

      x = sx * (A[0] - x0) + x0;
      y = sy * (A[1] - y0) + y0;
      z = sz * (A[2] - z0) + z0;

      float[] B = Select3D.translateInside_ReferencePivot(x, y, z);

      x = B[0];
      y = B[1];
      z = B[2];

      Land3D.Mesh[i][j][0] = x;
      Land3D.Mesh[i][j][1] = y;
      Land3D.Mesh[i][j][2] = z;

    }

    SOLARCHVISION_model_changed();
  }


  void softSelection (float x0, float y0, float z0, float sx, float sy, float sz) {

    for (int q = 0; q < Select3D.softSelection_ids.length; q++) {

      int f = Select3D.softSelection_ids[q];

      float v = Select3D.softSelection_values[q];

      float x = allPoints.getX(f) - x0;
      float y = allPoints.getY(f) - y0;
      float z = allPoints.getZ(f) - z0;

      allPoints.setX(f, (x0 + sx * x) * v + (x0 + x) * (1 - v));
      allPoints.setY(f, (y0 + sy * y) * v + (y0 + y) * (1 - v));
      allPoints.setZ(f, (z0 + sz * z) * v + (z0 + z) * (1 - v));
    }

    SOLARCHVISION_model_changed();
  }


  void Vertices (float x0, float y0, float z0, float sx, float sy, float sz) {

    for (int q = 0; q < Select3D.Vertex_ids.length; q++) {

      int f = Select3D.Vertex_ids[q];

      float x = allPoints.getX(f);
      float y = allPoints.getY(f);
      float z = allPoints.getZ(f);

      float[] A = Select3D.translateOutside_ReferencePivot(x, y, z);

      x = sx * (A[0] - x0) + x0;
      y = sy * (A[1] - y0) + y0;
      z = sz * (A[2] - z0) + z0;

      float[] B = Select3D.translateInside_ReferencePivot(x, y, z);

      x = B[0];
      y = B[1];
      z = B[2];

      allPoints.setX(f, x);
      allPoints.setY(f, y);
      allPoints.setZ(f, z);
    }

    SOLARCHVISION_model_changed();
  }



  void Polylines (float x0, float y0, float z0, float sx, float sy, float sz) {

    int[] PolylineVertices = Select3D.get_Polyline_Vertices();

    for (int q = 0; q < PolylineVertices.length; q++) {

      int f = PolylineVertices[q];

      float x = allPoints.getX(f);
      float y = allPoints.getY(f);
      float z = allPoints.getZ(f);

      float[] A = Select3D.translateOutside_ReferencePivot(x, y, z);

      x = sx * (A[0] - x0) + x0;
      y = sy * (A[1] - y0) + y0;
      z = sz * (A[2] - z0) + z0;

      float[] B = Select3D.translateInside_ReferencePivot(x, y, z);

      x = B[0];
      y = B[1];
      z = B[2];

      allPoints.setX(f, x);
      allPoints.setY(f, y);
      allPoints.setZ(f, z);
    }

    SOLARCHVISION_model_changed();
  }


  void Faces (float x0, float y0, float z0, float sx, float sy, float sz) {

    int[] FaceVertices = Select3D.get_Face_Vertices();

    for (int q = 0; q < FaceVertices.length; q++) {

      int f = FaceVertices[q];

      float x = allPoints.getX(f);
      float y = allPoints.getY(f);
      float z = allPoints.getZ(f);

      float[] A = Select3D.translateOutside_ReferencePivot(x, y, z);

      x = sx * (A[0] - x0) + x0;
      y = sy * (A[1] - y0) + y0;
      z = sz * (A[2] - z0) + z0;

      float[] B = Select3D.translateInside_ReferencePivot(x, y, z);

      x = B[0];
      y = B[1];
      z = B[2];

      allPoints.setX(f, x);
      allPoints.setY(f, y);
      allPoints.setZ(f, z);
    }

    SOLARCHVISION_model_changed();
  }


  void Solids (float x0, float y0, float z0, float sx, float sy, float sz) {

    boolean allSolids_updated = false;

    for (int q = 0; q < Select3D.Solid_ids.length; q++) {

      int f = Select3D.Solid_ids[q];

      float x = allSolids.get_posX(f);
      float y = allSolids.get_posY(f);
      float z = allSolids.get_posZ(f);

      float[] A = Select3D.translateOutside_ReferencePivot(x, y, z);

      x = sx * (A[0] - x0) + x0;
      y = sy * (A[1] - y0) + y0;
      z = sz * (A[2] - z0) + z0;

      float[] B = Select3D.translateInside_ReferencePivot(x, y, z);

      x = B[0];
      y = B[1];
      z = B[2];

      allSolids.updatePosition(f, x, y, z);

      allSolids.Scale(f, sx, sy, sz);

      allSolids_updated = true;
    }

    if (allSolids_updated) allSolidImpacts.calculate_Impact_selectedSections();

    SOLARCHVISION_model_changed();
  }


  void Sections (float sx, float sy) {

    for (int q = 0; q < Select3D.Section_ids.length; q++) {

      int f = Select3D.Section_ids[q];

      allSections.setU(f, allSections.getU(f) * sx);
      allSections.setV(f, allSections.getV(f) * sy);
    }

    allSolidImpacts.calculate_Impact_selectedSections();

    SOLARCHVISION_model_changed();
  }


  void Cameras (float x0, float y0, float z0, float sx, float sy, float sz) {

    // swapping y and z vectors to match camera's local coordinate
    float tmp = sz;
    sz = sy;
    sy = tmp;

    for (int q = 0; q < Select3D.Camera_ids.length; q++) {

      int f = Select3D.Camera_ids[q];

      float x = allCameras.get_posX(f) - x0;
      float y = allCameras.get_posY(f) - y0;
      float z = allCameras.get_posZ(f) - z0;

      allCameras.set_posX(f, x0 + sx * x);
      allCameras.set_posY(f, y0 + sy * y);
      allCameras.set_posZ(f, z0 + sz * z);

      if (f == WIN3D.currentCamera) WIN3D.apply_currentCamera();
    }

    SOLARCHVISION_model_changed();
  }


  void Model1Ds (float x0, float y0, float z0, float sx, float sy, float sz) {

    for (int o = Select3D.Model1D_ids.length - 1; o >= 0; o--) {

      int f = Select3D.Model1D_ids[o];

      float x = allModel1Ds.getX(f);
      float y = allModel1Ds.getY(f);
      float z = allModel1Ds.getZ(f);

      float[] A = Select3D.translateOutside_ReferencePivot(x, y, z);

      x = sx * (A[0] - x0) + x0;
      y = sy * (A[1] - y0) + y0;
      z = sz * (A[2] - z0) + z0;

      float[] B = Select3D.translateInside_ReferencePivot(x, y, z);

      x = B[0];
      y = B[1];
      z = B[2];

      allModel1Ds.setX(f, x);
      allModel1Ds.setY(f, y);
      allModel1Ds.setZ(f, z);

      allModel1Ds.magS(f, sz);
    }

    SOLARCHVISION_model_changed();
  }


  void Model2Ds (float x0, float y0, float z0, float sx, float sy, float sz) {

    int n1 = allModel2Ds.num_files_PEOPLE;

    for (int o = Select3D.Model2D_ids.length - 1; o >= 0; o--) {

      int f = Select3D.Model2D_ids[o];

      float x = allModel2Ds.getX(f);
      float y = allModel2Ds.getY(f);
      float z = allModel2Ds.getZ(f);

      float[] A = Select3D.translateOutside_ReferencePivot(x, y, z);

      x = sx * (A[0] - x0) + x0;
      y = sy * (A[1] - y0) + y0;
      z = sz * (A[2] - z0) + z0;

      float[] B = Select3D.translateInside_ReferencePivot(x, y, z);

      x = B[0];
      y = B[1];
      z = B[2];

      allModel2Ds.setX(f, x);
      allModel2Ds.setY(f, y);
      allModel2Ds.setZ(f, z);


      int n = allModel2Ds.MAP[f];

      if (allModel2Ds.isTree(n)) { // does not scale poeple!
        allModel2Ds.magS(f, sz);
      }
    }

    SOLARCHVISION_model_changed();
  }


  void Groups (float x0, float y0, float z0, float sx, float sy, float sz) {

    int[] PolymeshVertices = Select3D.get_Group_Vertices();

    for (int q = 0; q < PolymeshVertices.length; q++) {

      int n = PolymeshVertices[q];

      float x = allPoints.getX(n);
      float y = allPoints.getY(n);
      float z = allPoints.getZ(n);

      float[] A = Select3D.translateOutside_ReferencePivot(x, y, z);

      x = sx * (A[0] - x0) + x0;
      y = sy * (A[1] - y0) + y0;
      z = sz * (A[2] - z0) + z0;

      float[] B = Select3D.translateInside_ReferencePivot(x, y, z);

      x = B[0];
      y = B[1];
      z = B[2];

      allPoints.setX(n, x);
      allPoints.setY(n, y);
      allPoints.setZ(n, z);
    }

    boolean allSolids_updated = false;

    for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = Select3D.Group_ids[o];

      {
        float x = allGroups.Pivots[OBJ_ID][0];
        float y = allGroups.Pivots[OBJ_ID][1];
        float z = allGroups.Pivots[OBJ_ID][2];

        float[] A = Select3D.translateOutside_ReferencePivot(x, y, z);

        x = sx * (A[0] - x0) + x0;
        y = sy * (A[1] - y0) + y0;
        z = sz * (A[2] - z0) + z0;

        float[] B = Select3D.translateInside_ReferencePivot(x, y, z);

        x = B[0];
        y = B[1];
        z = B[2];

        allGroups.Pivots[OBJ_ID][0] = x;
        allGroups.Pivots[OBJ_ID][1] = y;
        allGroups.Pivots[OBJ_ID][2] = z;

        // ???????
        //allGroups.Pivots[OBJ_ID][3] *= sx;
        //allGroups.Pivots[OBJ_ID][4] *= sy;
        //allGroups.Pivots[OBJ_ID][5] *= sz;
        // ???????
      }


      for (int f = allGroups.getStart_Model1D(OBJ_ID); f <= allGroups.getStop_Model1D(OBJ_ID); f++) {
        if ((0 <= f) && (f < allModel1Ds.num)) {

          float x = allModel1Ds.getX(f);
          float y = allModel1Ds.getY(f);
          float z = allModel1Ds.getZ(f);

          float[] A = Select3D.translateOutside_ReferencePivot(x, y, z);

          x = sx * (A[0] - x0) + x0;
          y = sy * (A[1] - y0) + y0;
          z = sz * (A[2] - z0) + z0;

          float[] B = Select3D.translateInside_ReferencePivot(x, y, z);

          x = B[0];
          y = B[1];
          z = B[2];

          allModel1Ds.setX(f, x);
          allModel1Ds.setY(f, y);
          allModel1Ds.setZ(f, z);

          allModel1Ds.magS(f, sz);
        }
      }


      for (int f = allGroups.getStart_Model2D(OBJ_ID); f <= allGroups.getStop_Model2D(OBJ_ID); f++) {
        if ((0 <= f) && (f < allModel2Ds.num)) {

          float x = allModel2Ds.getX(f);
          float y = allModel2Ds.getY(f);
          float z = allModel2Ds.getZ(f);

          float[] A = Select3D.translateOutside_ReferencePivot(x, y, z);

          x = sx * (A[0] - x0) + x0;
          y = sy * (A[1] - y0) + y0;
          z = sz * (A[2] - z0) + z0;

          float[] B = Select3D.translateInside_ReferencePivot(x, y, z);

          x = B[0];
          y = B[1];
          z = B[2];

          allModel2Ds.setX(f, x);
          allModel2Ds.setY(f, y);
          allModel2Ds.setZ(f, z);

          int n = allModel2Ds.MAP[f];

          if (allModel2Ds.isTree(n)) { // does not scale poeple!
            allModel2Ds.magS(f, sz);
          }
        }
      }

      for (int f = allGroups.getStart_Solid(OBJ_ID); f <= allGroups.getStop_Solid(OBJ_ID); f++) {
        if ((0 <= f) && (f < allSolids.DEF.length)) {

          float x = allSolids.get_posX(f);
          float y = allSolids.get_posY(f);
          float z = allSolids.get_posZ(f);

          float[] A = Select3D.translateOutside_ReferencePivot(x, y, z);

          x = sx * (A[0] - x0) + x0;
          y = sy * (A[1] - y0) + y0;
          z = sz * (A[2] - z0) + z0;

          float[] B = Select3D.translateInside_ReferencePivot(x, y, z);

          x = B[0];
          y = B[1];
          z = B[2];

          allSolids.updatePosition(f, x, y, z);

          allSolids.Scale(f, sx, sy, sz);

          allSolids_updated = true;
        }
      }
    }

    if (allSolids_updated) allSolidImpacts.calculate_Impact_selectedSections();

    SOLARCHVISION_model_changed();
  }

}
