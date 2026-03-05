class solarchvision_Move3D {

  private final static String CLASS_STAMP = "Move3D";

  void selection (float dx, float dy, float dz) {
    /*
    float[] A = Select3D.translateInside_ReferencePivot(0, 0, 0);
    float[] B = Select3D.translateInside_ReferencePivot(dx, dy, dz);

    dx = B[0] - A[0];
    dy = B[1] - A[1];
    dz = B[2] - A[2];
    */


    if (current_ObjectCategory == ObjectCategory.LANDPOINT) {
      this.LandPoints(dx, dy, dz);
    }

    if (current_ObjectCategory == ObjectCategory.SOFTVERTEX) {
      this.softSelection(dx, dy, dz);
    }

    if (current_ObjectCategory == ObjectCategory.VERTEX) {
      this.Vertices(dx, dy, dz);
    }

    if (current_ObjectCategory == ObjectCategory.POLYLINE) {
      this.Polylines(dx, dy, dz);
    }

    if (current_ObjectCategory == ObjectCategory.FACE) {
      this.Faces(dx, dy, dz);
    }

    if (current_ObjectCategory == ObjectCategory.MODEL1D) {
      this.Model1Ds(dx, dy, dz);
    }

    if (current_ObjectCategory == ObjectCategory.MODEL2D) {
      this.Model2Ds(dx, dy, dz);
    }

    if (current_ObjectCategory == ObjectCategory.SOLID) {
      this.Solids(dx, dy, dz);
    }

    if (current_ObjectCategory == ObjectCategory.SECTION) {
      this.Sections(dx, dy, dz);
    }

    if (current_ObjectCategory == ObjectCategory.CAMERA) {
      this.Cameras(dx, dy, dz);
    }

    if (current_ObjectCategory == ObjectCategory.GROUP) {
      this.Groups(dx, dy, dz);
    }
  }



  void LandPoints (float dx, float dy, float dz) {

    for (int q = 0; q < Select3D.LandPoint_ids.length; q++) {

      int f = Select3D.LandPoint_ids[q];

      int i = f / Land3D.num_columns;
      int j = f % Land3D.num_columns;

      Land3D.Mesh[i][j][0] += dx;
      Land3D.Mesh[i][j][1] += dy;
      Land3D.Mesh[i][j][2] += dz;
    }

    SOLARCHVISION_model_changed();
  }


  void softSelection (float dx, float dy, float dz) {

    for (int q = 0; q < Select3D.softSelection_ids.length; q++) {

      int f = Select3D.softSelection_ids[q];

      float v = Select3D.softSelection_values[q];

      allPoints.move(f, dx * v, dy * v, dz * v);
    }

    SOLARCHVISION_model_changed();
  }


  void Vertices (float dx, float dy, float dz) {

    for (int q = 0; q < Select3D.Vertex_ids.length; q++) {

      int f = Select3D.Vertex_ids[q];

      allPoints.move(f, dx, dy, dz);
    }

    SOLARCHVISION_model_changed();
  }


  void Polylines (float dx, float dy, float dz) {

    int[] PolylineVertices = Select3D.get_Polyline_Vertices();

    for (int q = 0; q < PolylineVertices.length; q++) {

      int f = PolylineVertices[q];

      allPoints.move(f, dx, dy, dz);
    }

    SOLARCHVISION_model_changed();
  }


  void Faces (float dx, float dy, float dz) {

    int[] FaceVertices = Select3D.get_Face_Vertices();

    for (int q = 0; q < FaceVertices.length; q++) {

      int f = FaceVertices[q];

      allPoints.move(f, dx, dy, dz);
    }
  }


  void Model1Ds (float dx, float dy, float dz) {

    for (int o = Select3D.Model1D_ids.length - 1; o >= 0; o--) {

      int f = Select3D.Model1D_ids[o];

      allModel1Ds.move(f, dx, dy, dz);
    }

    SOLARCHVISION_model_changed();
  }



  void Model2Ds (float dx, float dy, float dz) {

    for (int o = Select3D.Model2D_ids.length - 1; o >= 0; o--) {

      int f = Select3D.Model2D_ids[o];

      allModel2Ds.move(f, dx, dy, dz);
    }

    SOLARCHVISION_model_changed();
  }


  void Solids (float dx, float dy, float dz) {

    boolean allSolids_updated = false;

    for (int q = 0; q < Select3D.Solid_ids.length; q++) {

      int f = Select3D.Solid_ids[q];

      float Solid_posX = allSolids.get_posX(f);
      float Solid_posY = allSolids.get_posY(f);
      float Solid_posZ = allSolids.get_posZ(f);

      allSolids.updatePosition(f, Solid_posX + dx, Solid_posY + dy, Solid_posZ + dz);

      allSolids_updated = true;
    }

    if (allSolids_updated) allSolidImpacts.calculate_Impact_selectedSections();

    SOLARCHVISION_model_changed();
  }


  void Sections (float dx, float dy, float dz) {

    for (int q = 0; q < Select3D.Section_ids.length; q++) {

      int f = Select3D.Section_ids[q];

      allSections.move(f, dx, dy, dz);
    }

    allSolidImpacts.calculate_Impact_selectedSections();

    SOLARCHVISION_model_changed();
  }


  void Cameras (float dx, float dy, float dz) {

    // swapping y and z vectors to match camera's local coordinate
    float tmp = dz;
    dz = dy;
    dy = tmp;

    for (int q = 0; q < Select3D.Camera_ids.length; q++) {

      int f = Select3D.Camera_ids[q];

      allCameras.move(f, dx, dy, dz);

      if (f == WIN3D.currentCamera) WIN3D.apply_currentCamera();
    }

    SOLARCHVISION_model_changed();
  }

  void Groups (float dx, float dy, float dz) {

    int[] PolymeshVertices = Select3D.get_Group_Vertices();

    for (int q = 0; q < PolymeshVertices.length; q++) {

      int n = PolymeshVertices[q];

      allPoints.move(n, dx, dy, dz);
    }

    boolean allSolids_updated = false;

    for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = Select3D.Group_ids[o];

      {
        allGroups.Pivots[OBJ_ID][0] += dx;
        allGroups.Pivots[OBJ_ID][1] += dy;
        allGroups.Pivots[OBJ_ID][2] += dz;
      }

      for (int f = allGroups.getStart_Model1D(OBJ_ID); f <= allGroups.getStop_Model1D(OBJ_ID); f++) {
        if ((0 <= f) && (f < allModel1Ds.num)) {

          allModel1Ds.move(f, dx, dy, dz);
        }
      }

      for (int f = allGroups.getStart_Model2D(OBJ_ID); f <= allGroups.getStop_Model2D(OBJ_ID); f++) {
        if ((0 <= f) && (f < allModel2Ds.num)) {

          allModel2Ds.move(f, dx, dy, dz);
        }
      }

      for (int f = allGroups.getStart_Solid(OBJ_ID); f <= allGroups.getStop_Solid(OBJ_ID); f++) {
        if ((0 <= f) && (f < allSolids.DEF.length)) {

          float Solid_posX = allSolids.get_posX(f);
          float Solid_posY = allSolids.get_posY(f);
          float Solid_posZ = allSolids.get_posZ(f);

          allSolids.updatePosition(f, Solid_posX + dx, Solid_posY + dy, Solid_posZ + dz);

          allSolids_updated = true;
        }
      }
    }

    if (allSolids_updated) allSolidImpacts.calculate_Impact_selectedSections();

    SOLARCHVISION_model_changed();
  }

}
