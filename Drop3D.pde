class solarchvision_Drop3D {

  private final static String CLASS_STAMP = "Drop3D";

  void selection () {

    if (current_ObjectCategory == ObjectCategory.MODEL1D) {
      this.Model1Ds();
    }

    if (current_ObjectCategory == ObjectCategory.MODEL2D) {
      this.Model2Ds();
    }

  }





  void Model1Ds () {

    for (int o = Select3D.Model1D_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = Select3D.Model1D_ids[o];

      float x = allModel1Ds.getX(OBJ_ID);
      float y = allModel1Ds.getY(OBJ_ID);
      float z = allModel1Ds.getZ(OBJ_ID);

      float[] ray_start = {
        x, y, z
      };

      float[] ray_direction = {
        0, 0, -1
      };

      float[] RxP = new float [8];

      if (WIN3D.UI_TaskModifyParameter == 0) {
        RxP = Land3D.intersect(ray_start, ray_direction);
      } else if (WIN3D.UI_TaskModifyParameter == 1) {
        RxP = allFaces.intersect(ray_start, ray_direction);
      } else {
        RxP[0] = -1; // undefined
      }

      if (RxP[0] >= 0) {
        allModel1Ds.setX(OBJ_ID, RxP[1]);
        allModel1Ds.setY(OBJ_ID, RxP[2]);
        allModel1Ds.setZ(OBJ_ID, RxP[3]);
      } else {
        ray_direction[2] = 1; // <<<< going upwards

        if (WIN3D.UI_TaskModifyParameter == 0) {
          RxP = Land3D.intersect(ray_start, ray_direction);
        } else if (WIN3D.UI_TaskModifyParameter == 2) {
          RxP = allFaces.intersect(ray_start, ray_direction);
        } else {
          RxP[0] = -1; // undefined
        }

        if (RxP[0] >= 0) {
          allModel1Ds.setX(OBJ_ID, RxP[1]);
          allModel1Ds.setY(OBJ_ID, RxP[2]);
          allModel1Ds.setZ(OBJ_ID, RxP[3]);
        }
      }
    }

    SOLARCHVISION_model_changed();
  }



  void Model2Ds () {

    for (int o = Select3D.Model2D_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = Select3D.Model2D_ids[o];

      float x = allModel2Ds.getX(OBJ_ID);
      float y = allModel2Ds.getY(OBJ_ID);
      float z = allModel2Ds.getZ(OBJ_ID);

      float[] ray_start = {
        x, y, z
      };

      float[] ray_direction = {
        0, 0, -1
      };

      float[] RxP = new float [8];

      if (WIN3D.UI_TaskModifyParameter == 0) {
        RxP = Land3D.intersect(ray_start, ray_direction);
      } else if (WIN3D.UI_TaskModifyParameter == 1) {
        RxP = allFaces.intersect(ray_start, ray_direction);
      } else {
        RxP[0] = -1; // undefined
      }

      if (RxP[0] >= 0) {
        allModel2Ds.setX(OBJ_ID, RxP[1]);
        allModel2Ds.setY(OBJ_ID, RxP[2]);
        allModel2Ds.setZ(OBJ_ID, RxP[3]);
      } else {
        ray_direction[2] = 1; // <<<< going upwards

        if (WIN3D.UI_TaskModifyParameter == 0) {
          RxP = Land3D.intersect(ray_start, ray_direction);
        } else if (WIN3D.UI_TaskModifyParameter == 2) {
          RxP = allFaces.intersect(ray_start, ray_direction);
        } else {
          RxP[0] = -1; // undefined
        }

        if (RxP[0] >= 0) {
          allModel2Ds.setX(OBJ_ID, RxP[1]);
          allModel2Ds.setY(OBJ_ID, RxP[2]);
          allModel2Ds.setZ(OBJ_ID, RxP[3]);
        }
      }
    }

    SOLARCHVISION_model_changed();
  }


}
