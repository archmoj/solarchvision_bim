class solarchvision_Create3D {

  private final static String CLASS_STAMP = "Create3D";

  void add_Octahedron (int m, int tes, int lyr, int vsb, int wgt, int clz, float x, float y, float z, float rx, float ry, float rz, float rot) {

    if ((rx > 0) && (ry > 0) && (rz > 0)) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      float teta = rot * PI / 180.0;

      float[] X_ = new float [6];
      float[] Y_ = new float [6];
      float[] Z_ = new float [6];

      float q = pow(2, 0.5);

      X_[0] = 0;
      Y_[0] = 0;
      Z_[0] = q;
      X_[1] = q;
      Y_[1] = 0;
      Z_[1] = 0;
      X_[2] = 0;
      Y_[2] = q;
      Z_[2] = 0;
      X_[3] = -q;
      Y_[3] = 0;
      Z_[3] = 0;
      X_[4] = 0;
      Y_[4] = -q;
      Z_[4] = 0;
      X_[5] = 0;
      Y_[5] = 0;
      Z_[5] = -q;

      for (int i = 0; i < 6; i++) {
        X_[i] *= rx;
        Y_[i] *= ry;
        Z_[i] *= rz;

        float X_r = X_[i] * cos(teta) - Y_[i] * sin(teta);
        float Y_r = X_[i] * sin(teta) + Y_[i] * cos(teta);
        float Z_r = Z_[i];

        X_[i] = X_r + x;
        Y_[i] = Y_r + y;
        Z_[i] = Z_r + z;
      }

      int[] v = new int [6];

      for (int i = 0; i < 6; i++) {
        v[i] = allPoints.create(X_[i], Y_[i], Z_[i]);
      }

      if (m == -1) current_Material = 0;
      else current_Material = m;

      {
        int[] newFace_nodes = {
          v[1], v[2], v[0]
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }

      {
        int[] newFace_nodes = {
          v[2], v[3], v[0]
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }

      {
        int[] newFace_nodes = {
          v[3], v[4], v[0]
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }

      {
        int[] newFace_nodes = {
          v[4], v[1], v[0]
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }

      {
        int[] newFace_nodes = {
          v[1], v[5], v[2]
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }

      {
        int[] newFace_nodes = {
          v[2], v[5], v[3]
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {
        int[] newFace_nodes = {
          v[3], v[5], v[4]
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }

      {
        int[] newFace_nodes = {
          v[4], v[5], v[1]
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }


    SOLARCHVISION_model_added();
    }
  }


  void add_House3_Core (int m, int tes, int lyr, int vsb, int wgt, int clz, float x, float y, float z, float rx, float ry, float rz, float h2, float rot) {

    if ((rx > 0) && (ry > 0) && (rz > 0)) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      float teta = (90 + rot) * PI / 180.0;

      float x1 = rx;
      float x2 = -rx;
      float x3 = -rx;
      float x4 = rx;

      float y1 = ry;
      float y2 = ry;
      float y3 = -ry;
      float y4 = -ry;

      float z0 = -rz;
      float z1 = rz;
      float z2 = h2;

      float[] vx = {
        1, -1, -1, 1, 1, -1, -1, 1, 1, -1
      };
      float[] vy = {
        1, 1, -1, -1, 1, 1, -1, -1, 0, 0
      };
      float[] vz = {
        0, 0, 0, 0, 1, 1, 1, 1, 1+h2/rz, 1+h2/rz
      };

      for (int i = 0; i < 10; i++) {
        vx[i] *= rx;
        vy[i] *= ry;
        vz[i] *= rz;

        float vx_rot = x + vx[i] * cos(teta) - vy[i] * sin(teta);
        float vy_rot = y + vx[i] * sin(teta) + vy[i] * cos(teta);
        float vz_rot = z + vz[i];

        vx[i] = vx_rot;
        vy[i] = vy_rot;
        vz[i] = vz_rot;
      }

      int b1 = allPoints.create(vx[0], vy[0], vz[0]);
      int b2 = allPoints.create(vx[1], vy[1], vz[1]);
      int b3 = allPoints.create(vx[2], vy[2], vz[2]);
      int b4 = allPoints.create(vx[3], vy[3], vz[3]);

      int t1 = allPoints.create(vx[4], vy[4], vz[4]);
      int t2 = allPoints.create(vx[5], vy[5], vz[5]);
      int t3 = allPoints.create(vx[6], vy[6], vz[6]);
      int t4 = allPoints.create(vx[7], vy[7], vz[7]);

      int m1 = allPoints.create(vx[8], vy[8], vz[8]);
      int m2 = allPoints.create(vx[9], vy[9], vz[9]);


      if (m == -1) current_Material = 0;
      else current_Material = m;


      {//West
        int[] newFace_nodes = {
          t3, m2, t2, b2, b3
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//Roof-South
        int[] newFace_nodes = {
          m1, m2, t3, t4
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//East
        int[] newFace_nodes = {
          t1, m1, t4, b4, b1
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//North
        int[] newFace_nodes = {
          t2, t1, b1, b2
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//South
        int[] newFace_nodes = {
          t4, t3, b3, b4
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//Roof-North
        int[] newFace_nodes = {
          m2, m1, t1, t2
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//Bottom
        int[] newFace_nodes = {
          b4, b3, b2, b1
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }


      SOLARCHVISION_model_added();
    }
  }


  void add_House2_Core (int m, int tes, int lyr, int vsb, int wgt, int clz, float x, float y, float z, float rx, float ry, float rz, float h2, float rot) {

    if ((rx > 0) && (ry > 0) && (rz > 0)) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      float teta = rot * PI / 180.0;

      float x1 = rx;
      float x2 = -rx;
      float x3 = -rx;
      float x4 = rx;

      float y1 = ry;
      float y2 = ry;
      float y3 = -ry;
      float y4 = -ry;

      float z0 = -rz;
      float z1 = rz;
      float z2 = h2;

      float[] vx = {
        1, -1, -1, 1, 1, -1, -1, 1, 1, -1
      };
      float[] vy = {
        1, 1, -1, -1, 1, 1, -1, -1, 0, 0
      };
      float[] vz = {
        0, 0, 0, 0, 1, 1, 1, 1, 1+h2/rz, 1+h2/rz
      };

      for (int i = 0; i < 10; i++) {
        vx[i] *= rx;
        vy[i] *= ry;
        vz[i] *= rz;

        float vx_rot = x + vx[i] * cos(teta) - vy[i] * sin(teta);
        float vy_rot = y + vx[i] * sin(teta) + vy[i] * cos(teta);
        float vz_rot = z + vz[i];

        vx[i] = vx_rot;
        vy[i] = vy_rot;
        vz[i] = vz_rot;
      }

      int b1 = allPoints.create(vx[0], vy[0], vz[0]);
      int b2 = allPoints.create(vx[1], vy[1], vz[1]);
      int b3 = allPoints.create(vx[2], vy[2], vz[2]);
      int b4 = allPoints.create(vx[3], vy[3], vz[3]);

      int t1 = allPoints.create(vx[4], vy[4], vz[4]);
      int t2 = allPoints.create(vx[5], vy[5], vz[5]);
      int t3 = allPoints.create(vx[6], vy[6], vz[6]);
      int t4 = allPoints.create(vx[7], vy[7], vz[7]);

      int m1 = allPoints.create(vx[8], vy[8], vz[8]);
      int m2 = allPoints.create(vx[9], vy[9], vz[9]);


      if (m == -1) current_Material = 0;
      else current_Material = m;


      {//West
        int[] newFace_nodes = {
          t3, m2, t2, b2, b3
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//Roof-South
        int[] newFace_nodes = {
          m1, m2, t3, t4
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//East
        int[] newFace_nodes = {
          t1, m1, t4, b4, b1
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//North
        int[] newFace_nodes = {
          t2, t1, b1, b2
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//South
        int[] newFace_nodes = {
          t4, t3, b3, b4
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//Roof-North
        int[] newFace_nodes = {
          m2, m1, t1, t2
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//Bottom
        int[] newFace_nodes = {
          b4, b3, b2, b1
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }


      SOLARCHVISION_model_added();
    }
  }


  void add_House1_Core (int m, int tes, int lyr, int vsb, int wgt, int clz, float x, float y, float z, float rx, float ry, float rz, float h2, float rot) {

    if ((rx > 0) && (ry > 0) && (rz > 0)) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      if (ry > rx) {

        float tmp = rx;
        rx = ry;
        ry = tmp;

        rot += 90;
      }

      float teta = rot * PI / 180.0;

      float x1 = rx;
      float x2 = -rx;
      float x3 = -rx;
      float x4 = rx;

      float y1 = ry;
      float y2 = ry;
      float y3 = -ry;
      float y4 = -ry;

      float z0 = -rz;
      float z1 = rz;
      float z2 = h2;

      float[] vx = {
        1, -1, -1, 1, 1, -1, -1, 1, 1-ry/rx, -1+ry/rx
      };
      float[] vy = {
        1, 1, -1, -1, 1, 1, -1, -1, 0, 0
      };
      float[] vz = {
        0, 0, 0, 0, 1, 1, 1, 1, 1+h2/rz, 1+h2/rz
      };

      for (int i = 0; i < 10; i++) {
        vx[i] *= rx;
        vy[i] *= ry;
        vz[i] *= rz;

        float vx_rot = x + vx[i] * cos(teta) - vy[i] * sin(teta);
        float vy_rot = y + vx[i] * sin(teta) + vy[i] * cos(teta);
        float vz_rot = z + vz[i];

        vx[i] = vx_rot;
        vy[i] = vy_rot;
        vz[i] = vz_rot;
      }

      int b1 = allPoints.create(vx[0], vy[0], vz[0]);
      int b2 = allPoints.create(vx[1], vy[1], vz[1]);
      int b3 = allPoints.create(vx[2], vy[2], vz[2]);
      int b4 = allPoints.create(vx[3], vy[3], vz[3]);

      int t1 = allPoints.create(vx[4], vy[4], vz[4]);
      int t2 = allPoints.create(vx[5], vy[5], vz[5]);
      int t3 = allPoints.create(vx[6], vy[6], vz[6]);
      int t4 = allPoints.create(vx[7], vy[7], vz[7]);

      int m1 = allPoints.create(vx[8], vy[8], vz[8]);
      int m2 = (rx == ry) ? m1 : allPoints.create(vx[9], vy[9], vz[9]);


      if (m == -1) current_Material = 0;
      else current_Material = m;


      {//West
        int[] newFace_nodes = {
          t3, t2, b2, b3
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//Roof-West
        int[] newFace_nodes = {
          t3, m2, t2
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//Roof-South
        int[] newFace_nodes = {
          m1, m2, t3, t4
        };
        int[] newFace_nodes3 = {
          m1, t3, t4
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(rx == ry ? newFace_nodes3 : newFace_nodes);
      }
      {//East
        int[] newFace_nodes = {
          t1, t4, b4, b1
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//Roof-East
        int[] newFace_nodes = {
          t1, m1, t4
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//North
        int[] newFace_nodes = {
          t2, t1, b1, b2
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//South
        int[] newFace_nodes = {
          t4, t3, b3, b4
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//Roof-North
        int[] newFace_nodes = {
          m2, m1, t1, t2
        };
        int[] newFace_nodes3 = {
          m1, t1, t2
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(rx == ry ? newFace_nodes3 : newFace_nodes);
      }
      {//Bottom
        int[] newFace_nodes = {
          b4, b3, b2, b1
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }


      SOLARCHVISION_model_added();
    }
  }



  void add_Box_Core (int m, int tes, int lyr, int vsb, int wgt, int clz, float x, float y, float z, float rx, float ry, float rz, float rot) {

    if ((rx > 0) && (ry > 0) && (rz > 0)) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      float teta = rot * PI / 180.0;

      int t1 = allPoints.create(x + (rx * cos(teta) - ry * sin(teta)), y + (rx * sin(teta) + ry * cos(teta)), z + rz);
      int t2 = allPoints.create(x + (-rx * cos(teta) - ry * sin(teta)), y + (-rx * sin(teta) + ry * cos(teta)), z + rz);
      int t3 = allPoints.create(x + (-rx * cos(teta) + ry * sin(teta)), y + (-rx * sin(teta) - ry * cos(teta)), z + rz);
      int t4 = allPoints.create(x + (rx * cos(teta) + ry * sin(teta)), y + (rx * sin(teta) - ry * cos(teta)), z + rz);

      int b1 = allPoints.create(x + (rx * cos(teta) - ry * sin(teta)), y + (rx * sin(teta) + ry * cos(teta)), z - rz);
      int b2 = allPoints.create(x + (-rx * cos(teta) - ry * sin(teta)), y + (-rx * sin(teta) + ry * cos(teta)), z - rz);
      int b3 = allPoints.create(x + (-rx * cos(teta) + ry * sin(teta)), y + (-rx * sin(teta) - ry * cos(teta)), z - rz);
      int b4 = allPoints.create(x + (rx * cos(teta) + ry * sin(teta)), y + (rx * sin(teta) - ry * cos(teta)), z - rz);

      if (m == -1) current_Material = 0;
      else current_Material = m;


      {//West
        int[] newFace_nodes = {
          t3, t2, b2, b3
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//Roof
        int[] newFace_nodes = {
          t1, t2, t3, t4
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//East
        int[] newFace_nodes = {
          t1, t4, b4, b1
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//North
        int[] newFace_nodes = {
          t2, t1, b1, b2
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//South
        int[] newFace_nodes = {
          t4, t3, b3, b4
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//Bottom
        int[] newFace_nodes = {
          b4, b3, b2, b1
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }


      SOLARCHVISION_model_added();
    }
  }


  void add_Box_Corners (int m, int tes, int lyr, int vsb, int wgt, int clz, float x1, float y1, float z1, float x2, float y2, float z2) {

    if ((x1 != x2) || (y1 != y2) || (z1 != z2)) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      int t1 = allPoints.create(x2, y2, z2);
      int t2 = allPoints.create(x1, y2, z2);
      int t3 = allPoints.create(x1, y1, z2);
      int t4 = allPoints.create(x2, y1, z2);

      int b1 = allPoints.create(x2, y2, z1);
      int b2 = allPoints.create(x1, y2, z1);
      int b3 = allPoints.create(x1, y1, z1);
      int b4 = allPoints.create(x2, y1, z1);

      if (m == -1) current_Material = 0;
      else current_Material = m;


      {//West
        int[] newFace_nodes = {
          t3, t2, b2, b3
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//Roof
        int[] newFace_nodes = {
          t1, t2, t3, t4
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//East
        int[] newFace_nodes = {
          t1, t4, b4, b1
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//North
        int[] newFace_nodes = {
          t2, t1, b1, b2
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//South
        int[] newFace_nodes = {
          t4, t3, b3, b4
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//Bottom
        int[] newFace_nodes = {
          b4, b3, b2, b1
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }


      SOLARCHVISION_model_added();
    }
  }


  void add_H_shade (int m, int tes, int lyr, int vsb, int wgt, int clz, float x0, float y0, float z0, float d, float w, float Alpha, float Beta) {

    if ((d > 0) && (w > 0)) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      float rx = 0.5 * d * funcs.cos_ang(Beta);
      float ry = 0.5 * d * funcs.sin_ang(Beta);

      float wx = w * funcs.cos_ang(Beta - 90) * funcs.cos_ang(Alpha);
      float wy = w * funcs.sin_ang(Beta - 90) * funcs.cos_ang(Alpha);
      float wz = w * funcs.sin_ang(Alpha);

      float x1 = x0 + rx;
      float y1 = y0 + ry;
      float z1 = z0;

      float x2 = x0 - rx;
      float y2 = y0 - ry;
      float z2 = z0;

      float x3 = wx + x0 - rx;
      float y3 = wy + y0 - ry;
      float z3 = wz + z0;

      float x4 = wx + x0 + rx;
      float y4 = wy + y0 + ry;
      float z4 = wz + z0;

      int v1 = allPoints.create(x1, y1, z1);
      int v2 = allPoints.create(x2, y2, z2);
      int v3 = allPoints.create(x3, y3, z3);
      int v4 = allPoints.create(x4, y4, z4);

      {
        int[] newFace_nodes = {
          v1, v2, v3, v4
        };
        allFaces.create(newFace_nodes);
      }

      SOLARCHVISION_model_added();
    }
  }


  void add_V_shade (int m, int tes, int lyr, int vsb, int wgt, int clz, float x0, float y0, float z0, float h, float d, float t, float t0) {

    if ((d > 0) && (h > 0)) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      float dx = d * funcs.cos_ang(t + t0 - 90);
      float dy = d * funcs.sin_ang(t + t0 - 90);

      float x1 = x0;
      float y1 = y0;
      float z1 = z0 - 0.5 * h;

      float x2 = x0;
      float y2 = y0;
      float z2 = z0 + 0.5 * h;

      float x3 = x0 + dx;
      float y3 = y0 + dy;
      float z3 = z0 + 0.5 * h;

      float x4 = x0 + dx;
      float y4 = y0 + dy;
      float z4 = z0 - 0.5 * h;

      int v1 = allPoints.create(x1, y1, z1);
      int v2 = allPoints.create(x2, y2, z2);
      int v3 = allPoints.create(x3, y3, z3);
      int v4 = allPoints.create(x4, y4, z4);

      {
        int[] newFace_nodes = {
          v1, v2, v3, v4
        };
        allFaces.create(newFace_nodes);
      }

      SOLARCHVISION_model_added();
    }
  }



  void add_Mesh2 (int m, int tes, int lyr, int vsb, int wgt, int clz, float x1, float y1, float z1, float x3, float y3, float z3) {

    if ((x1 != x3) || (y1 != y3) || (z1 != z3)) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      float x2 = x3;
      float y2 = y3;
      float z2 = z3;

      float x4 = x1;
      float y4 = y1;
      float z4 = z1;

      if (z1 == z3) {
        y2 = y1;
        y4 = y3;
      } else if (y1 == y3) {
        x2 = x1;
        x4 = x3;
      } else if (x1 == x3) {
        z2 = z1;
        z4 = z3;
      }

      int v1 = allPoints.create(x1, y1, z1);
      int v2 = allPoints.create(x2, y2, z2);
      int v3 = allPoints.create(x3, y3, z3);
      int v4 = allPoints.create(x4, y4, z4);


      {
        int[] newFace_nodes = {
          v1, v2, v3, v4
        };
        allFaces.create(newFace_nodes);
      }

      SOLARCHVISION_model_added();
    }
  }


  void add_Mesh3 (int m, int tes, int lyr, int vsb, int wgt, int clz, float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3) {

    if ((x1 != x2) || (y1 != y2) || (z1 != z2)) {
      if ((x2 != x3) || (y2 != y3) || (z2 != z3)) {
        if ((x1 != x3) || (y1 != y3) || (z1 != z3)) {

          current_Material = m;
          current_Tessellation = tes;
          current_Layer = lyr;
          current_Visibility = vsb;
          current_Weight = wgt;
          current_Closed = clz;

          int v1 = allPoints.create(x1, y1, z1);
          int v2 = allPoints.create(x2, y2, z2);
          int v3 = allPoints.create(x3, y3, z3);

          {
            int[] newFace_nodes = {
              v1, v2, v3
            };
            allFaces.create(newFace_nodes);
          }


          SOLARCHVISION_model_added();
        }
      }
    }
  }



  void add_Mesh4 (int m, int tes, int lyr, int vsb, int wgt, int clz, float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3, float x4, float y4, float z4) {

    if ((x1 == x2) && (y1 == y2) && (z1 == z2)) {

      this.add_Mesh3 (m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x3, y3, z3, x4, y4, z4);
    }
    else if ((x2 == x3) && (y2 == y3) && (z2 == z3)) {

      this.add_Mesh3 (m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x4, y4, z4);
    }
    else if ((x3 == x4) && (y3 == y4) && (z3 == z4)) {

      this.add_Mesh3 (m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3);
    }
    else if ((x1 == x4) && (y1 == y4) && (z1 == z4)) {

      this.add_Mesh3 (m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3);
    }
    else {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      int v1 = allPoints.create(x1, y1, z1);
      int v2 = allPoints.create(x2, y2, z2);
      int v3 = allPoints.create(x3, y3, z3);
      int v4 = allPoints.create(x4, y4, z4);

      {
        int[] newFace_nodes = {
          v1, v2, v3, v4
        };
        allFaces.create(newFace_nodes);
      }

      SOLARCHVISION_model_added();
    }
  }



  void add_Mesh5 (int m, int tes, int lyr, int vsb, int wgt, int clz, float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3, float x4, float y4, float z4, float x5, float y5, float z5) {

    if ((x1 == x2) && (y1 == y2) && (z1 == z2)) {

      this.add_Mesh4 (m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x3, y3, z3, x4, y4, z4, x5, y5, z5);
    }
    else if ((x2 == x3) && (y2 == y3) && (z2 == z3)) {

      this.add_Mesh4 (m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x4, y4, z4, x5, y5, z5);
    }
    else if ((x3 == x4) && (y3 == y4) && (z3 == z4)) {

      this.add_Mesh4 (m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3, x5, y5, z5);
    }
    else if ((x4 == x5) && (y4 == y5) && (z4 == z5)) {

      this.add_Mesh4 (m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4);
    }
    else if ((x1 == x5) && (y1 == y5) && (z1 == z5)) {

      this.add_Mesh4 (m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4);
    }
    else {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      int v1 = allPoints.create(x1, y1, z1);
      int v2 = allPoints.create(x2, y2, z2);
      int v3 = allPoints.create(x3, y3, z3);
      int v4 = allPoints.create(x4, y4, z4);
      int v5 = allPoints.create(x5, y5, z5);

      {
        int[] newFace_nodes = {
          v1, v2, v3, v4, v5
        };
        allFaces.create(newFace_nodes);
      }

      SOLARCHVISION_model_added();
    }
  }


  void add_Mesh6 (int m, int tes, int lyr, int vsb, int wgt, int clz, float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3, float x4, float y4, float z4, float x5, float y5, float z5, float x6, float y6, float z6) {

    if ((x1 == x2) && (y1 == y2) && (z1 == z2)) {

      this.add_Mesh5 (m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x3, y3, z3, x4, y4, z4, x5, y5, z5, x6, y6, z6);
    }
    else if ((x2 == x3) && (y2 == y3) && (z2 == z3)) {

      this.add_Mesh5 (m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x4, y4, z4, x5, y5, z5, x6, y6, z6);
    }
    else if ((x3 == x4) && (y3 == y4) && (z3 == z4)) {

      this.add_Mesh5 (m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3, x5, y5, z5, x6, y6, z6);
    }
    else if ((x4 == x5) && (y4 == y5) && (z4 == z5)) {

      this.add_Mesh5 (m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, x6, y6, z6);
    }
    else if ((x5 == x6) && (y5 == y6) && (z5 == z6)) {

      this.add_Mesh5 (m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, x5, y5, z5);
    }
    else if ((x1 == x6) && (y1 == y6) && (z1 == z6)) {

      this.add_Mesh5 (m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, x5, y5, z5);
    }
    else {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      int v1 = allPoints.create(x1, y1, z1);
      int v2 = allPoints.create(x2, y2, z2);
      int v3 = allPoints.create(x3, y3, z3);
      int v4 = allPoints.create(x4, y4, z4);
      int v5 = allPoints.create(x5, y5, z5);
      int v6 = allPoints.create(x6, y6, z6);

      {
        int[] newFace_nodes = {
          v1, v2, v3, v4, v5, v6
        };
        allFaces.create(newFace_nodes);
      }

      SOLARCHVISION_model_added();
    }
  }




  void add_PolygonHyper (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float r, float h, int n, float rot) {

    if ((r > 0) && (h > 0) && (n > 2)) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      int[] newFace_nodes = {
        allPoints.create(cx + r * funcs.cos_ang(rot), cy + r * funcs.sin_ang(rot), cz - 0.5 * h)
      };
      for (int i = 1; i < n; i++) {
        float t = i * 360.0 / float(n);
        int[] f = {
          allPoints.create(cx + r * funcs.cos_ang(t + rot), cy + r * funcs.sin_ang(t + rot), cz + (2 * (i % 2) - 1) * 0.5 * h)
        };
        newFace_nodes = concat(newFace_nodes, f);
      }

      allFaces.create(newFace_nodes);

      SOLARCHVISION_model_added();
    }
  }



  void add_PolygonMesh (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float r, int n, float rot) {

    if ((r > 0) && (n > 2)) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      int[] newFace_nodes = {
        allPoints.create(cx + r * funcs.cos_ang(rot), cy + r * funcs.sin_ang(rot), cz)
      };
      for (int i = 1; i < n; i++) {
        float t = i * 360.0 / float(n) + rot;
        int[] f = {
          allPoints.create(cx + r * funcs.cos_ang(t), cy + r * funcs.sin_ang(t), cz)
        };
        newFace_nodes = concat(newFace_nodes, f);
      }

      allFaces.create(newFace_nodes);

      SOLARCHVISION_model_added();
    }
  }



  void add_PolygonExtrude (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float r, float h, int n, float rot) {

    if ((r > 0) && (h > 0) && (n > 2)) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      int[] vT = new int [n];
      int[] vB = new int [n];

      vT[0] = allPoints.create(cx + r * funcs.cos_ang(rot), cy + r * funcs.sin_ang(rot), cz + 0.5 * h);
      vB[0] = allPoints.create(cx + r * funcs.cos_ang(rot), cy + r * funcs.sin_ang(rot), cz - 0.5 * h);

      int[] newFace_nodesT = {
        vT[0]
      };
      int[] newFace_nodesB = {
        vB[0]
      };
      for (int i = 1; i < n; i++) {
        float t = i * 360.0 / float(n);

        vT[i] = allPoints.create(cx + r * funcs.cos_ang(t + rot), cy + r * funcs.sin_ang(t + rot), cz + 0.5 * h);
        vB[i] = allPoints.create(cx + r * funcs.cos_ang(t + rot), cy + r * funcs.sin_ang(t + rot), cz - 0.5 * h);
        int[] fT = {
          vT[i]
        };
        int[] fB = {
          vB[i]
        };

        newFace_nodesT = concat(newFace_nodesT, fT);
        newFace_nodesB = concat(newFace_nodesB, fB);
      }

      if (m == -1) current_Material = 0;
      else current_Material = m;

      allFaces.create(newFace_nodesT);

      if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
      allFaces.create(newFace_nodesB);

      for (int i = 0; i < n; i++) {
        int next_i = (i + 1) % n;

        int[] newFace_nodes = {
          vT[i], vB[i], vB[next_i], vT[next_i]
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }

      SOLARCHVISION_model_added();
    }
  }






  void add_Icosahedron (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float r, float rot) {

    if (r > 0) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      int[] vT = new int [6];
      int[] vB = new int [6];

      vT[0] = allPoints.create(cx, cy, cz + r);
      vB[0] = allPoints.create(cx, cy, cz - r);

      for (int i = 1; i <= 5; i++) {
        float t = i * 72;

        float R_in = r * pow(5.0, 0.5) * 2.0 / 5.0;
        float H_in = r * pow(5.0, 0.5) * 1.0 / 5.0;

        vT[i] = allPoints.create(cx + R_in * funcs.cos_ang(t + rot), cy + R_in * funcs.sin_ang(t + rot), cz + H_in);
        vB[i] = allPoints.create(cx + R_in * funcs.cos_ang(t + 36 + rot), cy + R_in * funcs.sin_ang(t + 36 + rot), cz - H_in);
      }


      if (m == -1) current_Material = 0;
      else current_Material = m;

      for (int i = 1; i <= 5; i++) {

        int next_i = (i % 5) + 1;

        {
          int[] newFace_nodesT = new int [3];
          int[] newFace_nodesB = new int [3];

          newFace_nodesT[0] = vT[i];
          newFace_nodesT[1] = vT[next_i];
          newFace_nodesT[2] = vT[0];

          newFace_nodesB[0] = vB[i];
          newFace_nodesB[1] = vB[next_i];
          newFace_nodesB[2] = vT[next_i];

          if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
          allFaces.create(newFace_nodesT);
          allFaces.create(newFace_nodesB);
        }

        {
          int[] newFace_nodesT = new int [3];
          int[] newFace_nodesB = new int [3];

          newFace_nodesT[0] = vT[next_i];
          newFace_nodesT[1] = vT[i];
          newFace_nodesT[2] = vB[i];

          newFace_nodesB[0] = vB[next_i];
          newFace_nodesB[1] = vB[i];
          newFace_nodesB[2] = vB[0];

          if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
          allFaces.create(newFace_nodesT);
          allFaces.create(newFace_nodesB);
        }
      }

      SOLARCHVISION_model_added();
    }
  }


  void create_Face_afterSphericaltessellation (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float r, int[] f) {

    if (r > 0) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      int A = f[0];
      int B = f[1];
      int C = f[2];
      int D = f[3];

      int M, N;  //
      int MM, NN; // MM: mirror of M based on AB; NN: mirror of N baesd on CD

      float[] G;

      {
        float[][] the_points = {
          {
            allPoints.getX(D) - cx, allPoints.getY(D) - cy, allPoints.getZ(D) - cz
          }
          , {
            allPoints.getX(A) - cx, allPoints.getY(A) - cy, allPoints.getZ(A) - cz
          }
          , {
            allPoints.getX(B) - cx, allPoints.getY(B) - cy, allPoints.getZ(B) - cz
          }
        };

        G = funcs.vec3_unit(funcs.centroid(the_points));
        M = allPoints.create(cx + r * G[0], cy + r * G[1], cz + r * G[2]);

        G[0] = (allPoints.getX(C) - cx) + (allPoints.getX(D) - cx) - (allPoints.getX(M) - cx);
        G[1] = (allPoints.getY(C) - cy) + (allPoints.getY(D) - cy) - (allPoints.getY(M) - cy);
        G[2] = (allPoints.getZ(C) - cz) + (allPoints.getZ(D) - cz) - (allPoints.getZ(M) - cz);
        G = funcs.vec3_unit(G);
        MM = allPoints.create(cx + r * G[0], cy + r * G[1], cz + r * G[2]);
      }


      {
        float[][] the_points = {
          {
            allPoints.getX(B) - cx, allPoints.getY(B) - cy, allPoints.getZ(B) - cz
          }
          , {
            allPoints.getX(C) - cx, allPoints.getY(C) - cy, allPoints.getZ(C) - cz
          }
          , {
            allPoints.getX(D) - cx, allPoints.getY(D) - cy, allPoints.getZ(D) - cz
          }
        };

        G = funcs.vec3_unit(funcs.centroid(the_points));
        N = allPoints.create(cx + r * G[0], cy + r * G[1], cz + r * G[2]);


        G[0] = (allPoints.getX(A) - cx) + (allPoints.getX(B) - cx) - (allPoints.getX(N) - cx);
        G[1] = (allPoints.getY(A) - cy) + (allPoints.getY(B) - cy) - (allPoints.getY(N) - cy);
        G[2] = (allPoints.getZ(A) - cz) + (allPoints.getZ(B) - cz) - (allPoints.getZ(N) - cz);
        G = funcs.vec3_unit(G);
        NN = allPoints.create(cx + r * G[0], cy + r * G[1], cz + r * G[2]);
      }





      {
        int[][] newFace_options = {
          {
            current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed
          }
        };

        allFaces.options = (int[][]) concat(allFaces.options, newFace_options);


        int[][] newFace_nodes = {
          {
            M, B, N, D
          }
        };

        allFaces.nodes = (int[][]) concat(allFaces.nodes, newFace_nodes);
      }

      {
        int[][] newFace_options = {
          {
            current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed
          }
        };

        //allFaces.options = (int[][]) concat(allFaces.options, newFace_options);


        int[][] newFace_nodes = {
          {
            MM, B, M, A
          }
        };

        //allFaces.nodes = (int[][]) concat(allFaces.nodes, newFace_nodes);
      }

      SOLARCHVISION_model_added();
    }
  }







  void add_ParametricSurface (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float rx, float ry, float rz, int n, float rot) {

    current_Material = m;
    current_Tessellation = tes;
    current_Layer = lyr;
    current_Visibility = vsb;
    current_Weight = wgt;
    current_Closed = clz;

    if (m == -1) current_Material = 0;
    else current_Material = m;

    float teta = rot * PI / 180.0;

    float stp_u = 0.1;
    float stp_v = 0.1;

    float start_u = -1;
    float start_v = -1;
    float end_u = 1;
    float end_v = 1;

    if ((n == 0) || (n == 6)) {
      start_u = 0;
    }

    if ((n == 0) || (n == 4) || (n == 5) || (n == 6)) {
      stp_u = 0.05;
      stp_v = 0.05;
    }

    for (float a = start_u; a < end_u; a += stp_u) {
      for (float b = start_v; b < end_v; b += stp_v) {

        int[] newFace_nodes = {
        };

        for (int i = 0; i < 4; i++) {

          float u = a;
          float v = b;

          if ((i == 1) || (i == 2)) u += stp_u;
          if ((i == 2) || (i == 3)) v += stp_v;

          float x = 0;
          float y = 0;
          float z = 0;

          if (n == 6) { // LOGO
            float x0 = cos(u * PI);
            float y0 = sin(v * PI);
            float z0 = -sin(u * PI) * cos(v * PI);

            float d = pow(x0*x0 + y0*y0 + z0*z0, 0.5);
            x = 0;
            y = 0;
            z = 0;
            if (d != 0) {
              x = x0 / d;
              y = y0 / d;
              z = z0 / d;
            }
          } else if (n == 0) { // Cushion
            x = cos(u * PI);
            y = sin(v * PI);
            z = -sin(u * PI) * cos(v * PI);
          } else if (n == 4) {
            x = sin(u * PI);
            y = sin(v * PI);
            z = cos((u + v) * PI);
          } else if (n == 5) {
            float x0 = sin(u * PI);
            float y0 = sin(v * PI);
            float z0 = cos((u + v) * PI);

            float d = pow(x0*x0 + y0*y0 + z0*z0, 0.5);
            x = 0;
            y = 0;
            z = 0;
            if (d != 0) {
              x = x0 / d;
              y = y0 / d;
              z = z0 / d;
            }
          } else if (n == 1) {
            x = u;
            y = v;
            z = cos(0.5 * u * PI) * cos(0.5 * v * PI);
          } else if (n == 2) {
            x = u;
            y = v;
            z = 0.5 * sin(u * PI) * sin(v * PI);
          } else if (n == 3) {
            x = u;
            y = v;
            z = u * v;
          }


          x *= rx;
          y *= ry;
          z *= rz;

          float x_rot = cx + x * cos(teta) - y * sin(teta);
          float y_rot = cy + x * sin(teta) + y * cos(teta);
          float z_rot = cz + z;

          x = x_rot;
          y = y_rot;
          z = z_rot;

          int[] f = {
            allPoints.create(x, y, z)
          };
          newFace_nodes = concat(newFace_nodes, f);
        }

        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));

        allFaces.create(newFace_nodes);
      }
    }

    SOLARCHVISION_model_added();
  }


  void add_CrystalSphere (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float r, int tessellation, int isSky, float t) {

    current_Material = m;
    current_Tessellation = tes;
    current_Layer = lyr;
    current_Visibility = vsb;
    current_Weight = wgt;
    current_Closed = clz;

    int[] vT = new int [6];
    int[] vB = new int [6];

    vT[0] = this.addToTempObjectVertices(0, 0, 1);
    vB[0] = this.addToTempObjectVertices(0, 0, -1);

    for (int i = 1; i <= 5; i++) {
      float q = i * 72 + t;

      float R_in = pow(5.0, 0.5) * 2.0 / 5.0;
      float H_in = pow(5.0, 0.5) * 1.0 / 5.0;

      vT[i] = this.addToTempObjectVertices(R_in * funcs.cos_ang(q), R_in * funcs.sin_ang(q), H_in);
      vB[i] = this.addToTempObjectVertices(R_in * funcs.cos_ang(q + 36), R_in * funcs.sin_ang(q + 36), -H_in);
    }


    int BuildFaces = 0;

    for (int Loop_Tessellation = 1; Loop_Tessellation <= tessellation; Loop_Tessellation++) { // added so that the tree generated from the bottom to the top!

      if (Loop_Tessellation == tessellation) BuildFaces = 1;
      else BuildFaces = 0;

      for (int i = 1; i <= 5; i++) {

        int next_i = (i % 5) + 1;
        int prev_i = ((i + 5 - 2) % 5) + 1;

        {
          createLozenge(
          TempObjectVertices[vT[prev_i]][0], TempObjectVertices[vT[prev_i]][1], TempObjectVertices[vT[prev_i]][2],
          TempObjectVertices[vT[i]][0], TempObjectVertices[vT[i]][1], TempObjectVertices[vT[i]][2],
          TempObjectVertices[vT[next_i]][0], TempObjectVertices[vT[next_i]][1], TempObjectVertices[vT[next_i]][2],
          TempObjectVertices[vT[0]][0], TempObjectVertices[vT[0]][1], TempObjectVertices[vT[0]][2],
          Loop_Tessellation, BuildFaces);
        }

        {
          createLozenge(
          TempObjectVertices[vT[0]][0], TempObjectVertices[vT[0]][1], TempObjectVertices[vT[0]][2],
          TempObjectVertices[vT[i]][0], TempObjectVertices[vT[i]][1], TempObjectVertices[vT[i]][2],
          TempObjectVertices[vB[i]][0], TempObjectVertices[vB[i]][1], TempObjectVertices[vB[i]][2],
          TempObjectVertices[vT[next_i]][0], TempObjectVertices[vT[next_i]][1], TempObjectVertices[vT[next_i]][2],
          Loop_Tessellation, BuildFaces);
        }

        {
          createLozenge(
          TempObjectVertices[vB[i]][0], TempObjectVertices[vB[i]][1], TempObjectVertices[vB[i]][2],
          TempObjectVertices[vT[i]][0], TempObjectVertices[vT[i]][1], TempObjectVertices[vT[i]][2],
          TempObjectVertices[vT[prev_i]][0], TempObjectVertices[vT[prev_i]][1], TempObjectVertices[vT[prev_i]][2],
          TempObjectVertices[vB[prev_i]][0], TempObjectVertices[vB[prev_i]][1], TempObjectVertices[vB[prev_i]][2],
          Loop_Tessellation, BuildFaces);
        }

        {
          createLozenge(

          TempObjectVertices[vT[i]][0], TempObjectVertices[vT[i]][1], TempObjectVertices[vT[i]][2],
          TempObjectVertices[vB[prev_i]][0], TempObjectVertices[vB[prev_i]][1], TempObjectVertices[vB[prev_i]][2],
          TempObjectVertices[vB[0]][0], TempObjectVertices[vB[0]][1], TempObjectVertices[vB[0]][2],
          TempObjectVertices[vB[i]][0], TempObjectVertices[vB[i]][1], TempObjectVertices[vB[i]][2],

          Loop_Tessellation, BuildFaces);
        }

        {
          createLozenge(
          TempObjectVertices[vB[prev_i]][0], TempObjectVertices[vB[prev_i]][1], TempObjectVertices[vB[prev_i]][2],
          TempObjectVertices[vB[0]][0], TempObjectVertices[vB[0]][1], TempObjectVertices[vB[0]][2],
          TempObjectVertices[vB[next_i]][0], TempObjectVertices[vB[next_i]][1], TempObjectVertices[vB[next_i]][2],
          TempObjectVertices[vB[i]][0], TempObjectVertices[vB[i]][1], TempObjectVertices[vB[i]][2],

          Loop_Tessellation, BuildFaces);
        }
      }
    }


    //println("Vertices:", POINTER_TempObjectVertices);
    //println("Faces:", POINTER_TempObjectFaces);

    if (isSky == 0) {
      this.addTempObjectToScene(m, tes, lyr, vsb, wgt, clz, cx, cy, cz, r, r, r, t);
    } else if (isSky == 1) {


      skyVertices = new float [0][3];
      skyFaces = new int [0][1];

      for (int i = 0; i < POINTER_TempObjectVertices; i++) {

        float x = TempObjectVertices[i][0];
        float y = TempObjectVertices[i][1];
        float z = TempObjectVertices[i][2];

        float[][] newVertex = {
          {
            x, y, z
          }
        };

        skyVertices = (float[][]) concat(skyVertices, newVertex);
      }

      for (int i = 0; i < POINTER_TempObjectFaces; i++) {

        int[][] newFace_nodes = {
          {
            TempObjectFaces[i][0], TempObjectFaces[i][1], TempObjectFaces[i][2], TempObjectFaces[i][3]
          }
        };

        skyFaces = (int[][]) concat(skyFaces, newFace_nodes);
      }


      POINTER_TempObjectVertices = 0;
      POINTER_TempObjectFaces = 0;
    } else {
      // Nothing. In this case we should add temp object outside this function. See SuperSphere
    }

    SOLARCHVISION_model_added();
  }



  void add_SuperSphere (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float px, float py, float pz, float sx, float sy, float sz, int tessellation, float t) {

    current_Material = m;
    current_Tessellation = tes;
    current_Layer = lyr;
    current_Visibility = vsb;
    current_Weight = wgt;
    current_Closed = clz;

    this.add_CrystalSphere(m, tes, lyr, vsb, wgt, clz, cx, cy, cz, 1, tessellation, -1, 90); // passing with isSky:-1

    float value, posX, posY, posZ, powX, powY, powZ, scaleX, scaleY, scaleZ, rotZ;
    value = 1;
    posX = 0;
    posY = 0;
    posZ = 0;
    powX = px;
    powY = py;
    powZ = pz;
    scaleX = 1;
    scaleY = 1;
    scaleZ = 1;

    for (int i = 0; i < POINTER_TempObjectVertices; i++) {

      float x = TempObjectVertices[i][0];
      float y = TempObjectVertices[i][1];
      float z = TempObjectVertices[i][2];

      float the_dist = (pow((pow(abs(x - posX) / scaleX, powX) + pow(abs(y - posY) / scaleY, powY) + pow(abs(z - posZ) / scaleZ, powZ)), (3.0 / (powX + powY + powZ))) / value);
      if (the_dist != 0) {
        x /= the_dist;
        y /= the_dist;
        z /= the_dist;
      }

      TempObjectVertices[i][0] = x;
      TempObjectVertices[i][1] = y;
      TempObjectVertices[i][2] = z;
    }

    this.addTempObjectToScene(m, tes, lyr, vsb, wgt, clz, cx, cy, cz, sx, sy, sz, t);

    SOLARCHVISION_model_added();
  }


  void add_SuperCylinder (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz, int n, float t) {

    current_Material = m;
    current_Tessellation = tes;
    current_Layer = lyr;
    current_Visibility = vsb;
    current_Weight = wgt;
    current_Closed = clz;

    int[] vT = new int [n];
    int[] vB = new int [n];

    vT[0] = this.addToTempObjectVertices(1, 0, 1);
    vB[0] = this.addToTempObjectVertices(1, 0, -1);

    int[] newFace_nodesT = {
      vT[0]
    };
    int[] newFace_nodesB = {
      vB[0]
    };
    for (int i = 1; i < n; i++) {
      float rot = i * 360.0 / float(n);

      vT[i] = this.addToTempObjectVertices(funcs.cos_ang(rot), funcs.sin_ang(rot), 1);
      vB[i] = this.addToTempObjectVertices(funcs.cos_ang(rot), funcs.sin_ang(rot), -1);
      int[] fT = {
        vT[i]
      };
      int[] fB = {
        vB[i]
      };

      newFace_nodesT = concat(newFace_nodesT, fT);
      newFace_nodesB = concat(newFace_nodesB, fB);
    }

    this.addToTempObjectFaces(newFace_nodesT, 0); // 0:check_duplicates
    this.addToTempObjectFaces(newFace_nodesB, 0); // 0:check_duplicates

    for (int i = 0; i < n; i++) {
      int next_i = (i + 1) % n;

      int[] newFace_nodes = {
        vT[i], vB[i], vB[next_i], vT[next_i]
      };

      this.addToTempObjectFaces(newFace_nodes, 0); // 0:check_duplicates
    }

    float value, posX, posY, posZ, powX, powY, powZ, scaleX, scaleY, scaleZ, rotZ;
    value = 1;
    posX = 0;
    posY = 0;
    posZ = 0;
    scaleX = 1;
    scaleY = 1;
    scaleZ = 1;

    for (int i = 0; i < POINTER_TempObjectVertices; i++) {

      float x = TempObjectVertices[i][0];
      float y = TempObjectVertices[i][1];
      float z = TempObjectVertices[i][2];

      float the_dist = (pow((pow(abs(x - posX) / scaleX, 2) + pow(abs(y - posY) / scaleY, 2)), 0.5) / value);
      if (the_dist != 0) {
        x /= the_dist;
        y /= the_dist;
      }

      TempObjectVertices[i][0] = x;
      TempObjectVertices[i][1] = y;
      TempObjectVertices[i][2] = z;
    }

    this.addTempObjectToScene(m, tes, lyr, vsb, wgt, clz, cx, cy, cz, sx, sy, sz, t);

    SOLARCHVISION_model_added();
  }


  int addToTempObjectVertices (float x, float y, float z) {

    float[][] newVertex = {
      {
        x, y, z
      }
    };

    int vertex_existed = 0;

    float min_dist = FLOAT_undefined;

    for (int i = 0; i < POINTER_TempObjectVertices; i++) {

      float the_dist = funcs.vec_dist(newVertex[0], TempObjectVertices[i]);

      if (the_dist < 0.1) { // avoid creating duplicate vertices - WELD is necessary for allModel1Ds spheres!

        if (min_dist > the_dist) {
          min_dist = the_dist;
          vertex_existed = i;
        }
      }
    }

    if (vertex_existed == 0) {

      if (POINTER_TempObjectVertices >= TempObjectVertices.length) {
        TempObjectVertices = (float[][]) concat(TempObjectVertices, newVertex);
      } else {
        //TempObjectVertices[POINTER_TempObjectVertices] = new int [3];

        TempObjectVertices[POINTER_TempObjectVertices][0] = x;
        TempObjectVertices[POINTER_TempObjectVertices][1] = y;
        TempObjectVertices[POINTER_TempObjectVertices][2] = z;
      }

      vertex_existed = POINTER_TempObjectVertices;

      POINTER_TempObjectVertices += 1;
    }

    return(vertex_existed);
  }

  int addToTempObjectFaces (int[] f, int check_duplicates) {

    int face_existed = 0;

    if (check_duplicates == 1) {

      for (int i = 0; i < POINTER_TempObjectFaces; i++) {
        if (f.length == TempObjectFaces[i].length) {

          for (int k = 0; k < f.length; k++) { // "k" introduces different variations that two faces could match

            for (int dir = -1; dir <= 1; dir += 2) { // "dir" introduces different diretions that two faces could match

              //println("\ndir=", dir);

              float total_distances = 0;

              for (int j = 0; j < f.length; j++) {

                int q = (j * dir + k + f.length) % f.length;

                //print("q=", q, "; k=" );

                total_distances += funcs.vec_dist(TempObjectVertices[f[q]], TempObjectVertices[TempObjectFaces[i][j]]);
              }

              if (total_distances < 0.0001) { // avoid creating duplicate faces
                //println("A duplicate face detected :", i);

                face_existed = i;
                break;
              }
            }
          }
        }
        if (face_existed != 0) break;
      }
    }

    if (face_existed == 0) {

      if (POINTER_TempObjectFaces >= TempObjectFaces.length) {
        int[][] newFace_nodes = {
          f
        };
        TempObjectFaces = (int[][]) concat(TempObjectFaces, newFace_nodes);
      } else {
        TempObjectFaces[POINTER_TempObjectFaces] = new int [f.length];

        for (int i = 0; i < f.length; i++) {
          TempObjectFaces[POINTER_TempObjectFaces][i] = f[i];
        }
      }

      face_existed = POINTER_TempObjectFaces;

      POINTER_TempObjectFaces += 1;
    }

    return(face_existed);
  }

  void addTempObjectToScene (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz, float t) {

    current_Material = m;
    current_Tessellation = tes;
    current_Layer = lyr;
    current_Visibility = vsb;
    current_Weight = wgt;
    current_Closed = clz;

    if (m == -1) current_Material = 0;
    else current_Material = m;

    for (int i = 0; i < POINTER_TempObjectFaces; i++) {

      int[] new_Vertex_ids = new int [TempObjectFaces[i].length];

      for (int j = 0; j < TempObjectFaces[i].length; j++) {

        float x0 = TempObjectVertices[TempObjectFaces[i][j]][0] * sx;
        float y0 = TempObjectVertices[TempObjectFaces[i][j]][1] * sy;
        float z0 = TempObjectVertices[TempObjectFaces[i][j]][2] * sz;

        float x = x0 * funcs.cos_ang(t) - y0 * funcs.sin_ang(t);
        float y = x0 * funcs.sin_ang(t) + y0 * funcs.cos_ang(t);
        float z = z0;

        new_Vertex_ids[j] = allPoints.create(x + cx, y + cy, z + cz);
      }

      if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
      allFaces.create(new_Vertex_ids);
    }

    TempObjectVertices = new float [0][3];

    TempObjectFaces = new int [0][1];

    POINTER_TempObjectVertices = 0;
    POINTER_TempObjectFaces = 0;

    SOLARCHVISION_model_added();
  }

  void createLozenge (float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3, float x4, float y4, float z4, int tessellation, int BuildFaces) {

    if (tessellation > 0) {

      if (tessellation == 1) {

        int[] newPoly = new int [4];

        newPoly[0] = this.addToTempObjectVertices(x1, y1, z1);
        newPoly[1] = this.addToTempObjectVertices(x2, y2, z2);
        newPoly[2] = this.addToTempObjectVertices(x3, y3, z3);
        newPoly[3] = this.addToTempObjectVertices(x4, y4, z4);

        if (BuildFaces != 0) {
          this.addToTempObjectFaces(newPoly, 1); // 1:check_duplicates
        }

        {
          // because the vertices might be welded to a nearest point:

          x1 = TempObjectVertices[newPoly[0]][0];
          y1 = TempObjectVertices[newPoly[0]][1];
          z1 = TempObjectVertices[newPoly[0]][2];

          x2 = TempObjectVertices[newPoly[1]][0];
          y2 = TempObjectVertices[newPoly[1]][1];
          z2 = TempObjectVertices[newPoly[1]][2];

          x3 = TempObjectVertices[newPoly[2]][0];
          y3 = TempObjectVertices[newPoly[2]][1];
          z3 = TempObjectVertices[newPoly[2]][2];

          x4 = TempObjectVertices[newPoly[3]][0];
          y4 = TempObjectVertices[newPoly[3]][1];
          z4 = TempObjectVertices[newPoly[3]][2];
        }
      }



      tessellation -= 1;

      float[] M = {
        (x1 + x2 + x4) / 3.0, (y1 + y2 + y4) / 3.0, (z1 + z2 + z4) / 3.0
      };
      float[] N = {
        (x3 + x2 + x4) / 3.0, (y3 + y2 + y4) / 3.0, (z3 + z2 + z4) / 3.0
      };

      M = funcs.vec3_unit(M);
      N = funcs.vec3_unit(N);

      createLozenge(x2, y2, z2, N[0], N[1], N[2], x4, y4, z4, M[0], M[1], M[2], tessellation, BuildFaces);


      if (BuildFaces != 0)
      {

        float[] P = M;

        PVector A_vec = new PVector(x1, y1, z1);
        PVector B_vec = new PVector(x2, y2, z2);

        PVector AxB_vec = A_vec.cross(B_vec);
        AxB_vec.normalize();

        float distP_OAB = P[0] * AxB_vec.x + P[1] * AxB_vec.y + P[2] * AxB_vec.z;

        float[] Q = {
          P[0] - 2 * distP_OAB * AxB_vec.x, P[1] - 2 * distP_OAB * AxB_vec.y, P[2] - 2 * distP_OAB * AxB_vec.z
        };

        Q = funcs.vec3_unit(Q);

        createLozenge(x2, y2, z2, P[0], P[1], P[2], x1, y1, z1, Q[0], Q[1], Q[2], tessellation, BuildFaces);
      }


      if (BuildFaces != 0)
      {

        float[] P = N;

        PVector A_vec = new PVector(x3, y3, z3);
        PVector B_vec = new PVector(x4, y4, z4);

        PVector AxB_vec = A_vec.cross(B_vec);
        AxB_vec.normalize();

        float distP_OAB = P[0] * AxB_vec.x + P[1] * AxB_vec.y + P[2] * AxB_vec.z;

        float[] Q = {
          P[0] - 2 * distP_OAB * AxB_vec.x, P[1] - 2 * distP_OAB * AxB_vec.y, P[2] - 2 * distP_OAB * AxB_vec.z
        };

        Q = funcs.vec3_unit(Q);

        createLozenge(x4, y4, z4, P[0], P[1], P[2], x3, y3, z3, Q[0], Q[1], Q[2], tessellation, BuildFaces);
      }
    }

    SOLARCHVISION_model_added();
  }



  void add_onLand (int people_or_trees) {

    //randomSeed(0);

    float[][] treesXYZS = {
      {
        0, 0, 0, 0
      }
    };

    int tessellation = Land3D.displayTessellation;
    if (WIN3D.FacesShade == SHADE.Surface_Base) {
      tessellation = 0;
    }

    int totalNumberOfSubs = 1;
    if (tessellation > 0) totalNumberOfSubs = 4 * int(funcs.roundTo(pow(4, tessellation - 1), 1)); // = 4 * ... because in LAND grid the cell has 4 points.



    if ((Land3D.displayTexture) && (people_or_trees != 1)) { // using another algorithm for people << i.e. no image processing from green colors of the map!

      for (int i = Land3D.skipStart; i < Land3D.num_rows - 1 - Land3D.skipEnd; i++) {
        for (int j = 0; j < Land3D.num_columns - 1; j++) {

          float[][] base_Vertices = new float [4][3];

          base_Vertices[0][0] = Land3D.Mesh[i][j][0];
          base_Vertices[0][1] = Land3D.Mesh[i][j][1];
          base_Vertices[0][2] = Land3D.Mesh[i][j][2];

          base_Vertices[1][0] = Land3D.Mesh[i+1][j][0];
          base_Vertices[1][1] = Land3D.Mesh[i+1][j][1];
          base_Vertices[1][2] = Land3D.Mesh[i+1][j][2];

          base_Vertices[2][0] = Land3D.Mesh[i+1][j+1][0];
          base_Vertices[2][1] = Land3D.Mesh[i+1][j+1][1];
          base_Vertices[2][2] = Land3D.Mesh[i+1][j+1][2];

          base_Vertices[3][0] = Land3D.Mesh[i][j+1][0];
          base_Vertices[3][1] = Land3D.Mesh[i][j+1][1];
          base_Vertices[3][2] = Land3D.Mesh[i][j+1][2];

          for (int n = 0; n < totalNumberOfSubs; n++) {

            float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

            int n_Map = -1;
            for (int q = 0; q < Land3D.Textures_num; q++) { // increase the resolution until all the vertices located inside the appropriate map

              n_Map = q;

              for (int s = 0; s < subFace.length; s++) {

                float u = (subFace[s][0] / Land3D.Textures_U_scale[q] + 0.5);
                float v = (-subFace[s][1] / Land3D.Textures_V_scale[q] + 0.5);

                if ((0 > u) || (u > 1) || (0 > v) || (v > 1)) {

                  n_Map = -1;

                  break;
                }
              }

              if (n_Map == q) break;
            }

            if (n_Map != -1) {

              int max_o = int(10000 / pow(2, Land3D.displayTessellation)); // number of tries to find green points!

              //if (max_o > 100) max_o = 100;

              if (i > 6) max_o = 0; // <<<<<<< do not create at far distances <<<<<<<<<<<<<<<
              //if (i > 10) max_o = 0; // <<<<<<< do not create at far distances <<<<<<<<<<<<<<<

              //if (i < 4) max_o = 0; // <<<<<<< do not create at near distances <<<<<<<<<<<<<<<

              for (int o = 0; o < max_o; o++) {

                float di = random(1);
                float dj = random(1);

                float x = funcs.bilinear(subFace[0][0], subFace[1][0], subFace[2][0], subFace[3][0], di, dj);
                float y = funcs.bilinear(subFace[0][1], subFace[1][1], subFace[2][1], subFace[3][1], di, dj);
                float z = funcs.bilinear(subFace[0][2], subFace[1][2], subFace[2][2], subFace[3][2], di, dj);

                // do not create trees close to each other
/*
                for (int p = 0; p < ?.length; p++) {
                }
????????
                if () {

                  break;
                }
*/

                float u = (x / Land3D.Textures_U_scale[n_Map] + 0.5);
                float v = (-y / Land3D.Textures_V_scale[n_Map] + 0.5);

                int uPixel = int(u * Land3D.Textures_map[n_Map].width);
                int vPixel = int(v * Land3D.Textures_map[n_Map].height);

                color COL = Land3D.Textures_map[n_Map].get(uPixel, vPixel);
                //red: COL >> 16 & 0xFF; green: COL >>8 & 0xFF; blue: COL & 0xFF;
                float r = COL >> 16 & 0xFF;
                float g = COL >> 8 & 0xFF;
                float b = COL & 0xFF;

                //if ((g > r + 8) && (g > b + 16)) { // looks more green
                //if ((g > r - 4) && (g > b + 16)) { // looks more green, slightly red is acceptible
                if ((g > r + 4) && (g > b + 4)) { // looks more green

                  if (g < 56) { // not on grass (light green)

                    //if (z + STATION.getElevation() > 5) { // not in water (below see level)

                    //float s = 5 + random(10);
                    float s = 5 + random(12.5);
                    //float s = 10 + random(20); // bigger trees

                    int foundNearTree = 0;

                    for (int f = 1; f < treesXYZS.length; f++) {

                      float x0 = treesXYZS[f][0];
                      float y0 = treesXYZS[f][1];
                      float z0 = treesXYZS[f][2];
                      float s0 = treesXYZS[f][3];

                      //if (dist(x0, y0, z0, x, y, z) < 0.25 * (s0 + s)) { //avoids creating trees close to each other
                      if (dist(x0, y0, z0, x, y, z) < 0.5 * (s0 + s)) { //avoids creating trees close to each other
                        foundNearTree = 1;

                        break;
                      }
                    }

                    if (foundNearTree == 0) {

                      if (people_or_trees == 2) {
                        allModel2Ds.create("TREES", 0, x, y, z, s);
                      } else {
                        allModel1Ds.create(User3D.create_Model1D_Type, User3D.create_Model1D_Seed,
                                           User3D.create_Model1D_DegreeMax,
                                           x, y, z, s, floor(random(360)),
                                           User3D.create_Model1D_BranchTilt, User3D.create_Model1D_BranchTwist,
                                           User3D.create_Model1D_BranchRatio, User3D.create_Model1D_TreeBase,
                                           User3D.create_Model1D_TrunkSize, User3D.create_Model1D_LeafSize);
                      }


                      float[][] newTree = {
                        {
                          x, y, z, s
                        }
                      };
                      treesXYZS = (float [][]) concat(treesXYZS, newTree);
                    }
                    //}
                  }
                }
              }
            }
          }
        }
      }
    } else {

      for (int i = Land3D.skipStart; i < Land3D.num_rows - 1 - Land3D.skipEnd; i++) {
        for (int j = 0; j < Land3D.num_columns - 1; j++) {

          float[][] base_Vertices = new float [4][3];

          base_Vertices[0][0] = Land3D.Mesh[i][j][0];
          base_Vertices[0][1] = Land3D.Mesh[i][j][1];
          base_Vertices[0][2] = Land3D.Mesh[i][j][2];

          base_Vertices[1][0] = Land3D.Mesh[i+1][j][0];
          base_Vertices[1][1] = Land3D.Mesh[i+1][j][1];
          base_Vertices[1][2] = Land3D.Mesh[i+1][j][2];

          base_Vertices[2][0] = Land3D.Mesh[i+1][j+1][0];
          base_Vertices[2][1] = Land3D.Mesh[i+1][j+1][1];
          base_Vertices[2][2] = Land3D.Mesh[i+1][j+1][2];

          base_Vertices[3][0] = Land3D.Mesh[i][j+1][0];
          base_Vertices[3][1] = Land3D.Mesh[i][j+1][1];
          base_Vertices[3][2] = Land3D.Mesh[i][j+1][2];

          for (int n = 0; n < totalNumberOfSubs; n++) {

            float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

            //int max_o = int((16.0 / pow(2, Land3D.displayTessellation)) * pow(random(1), 8)); // i.e. maximum 3 people in each pixel for tes=2
            int max_o = int(random(10)) == 0 ? 1 : 0;

            if (i > 2) max_o = 0; // <<<<<<< do not create at far distances <<<<<<<<<<<<<<<

            for (int o = 0; o < max_o; o++) {

              float di = random(1);
              float dj = random(1);

              float x = funcs.bilinear(subFace[0][0], subFace[1][0], subFace[2][0], subFace[3][0], di, dj);
              float y = funcs.bilinear(subFace[0][1], subFace[1][1], subFace[2][1], subFace[3][1], di, dj);
              float z = funcs.bilinear(subFace[0][2], subFace[1][2], subFace[2][2], subFace[3][2], di, dj);

              if (z + STATION.getElevation() > 0) { // i.e. above sea level

                if (dist(x, y, 0, 0) > 20.0) { // i.e. No 2D at the center!

                  if (people_or_trees == 1) {
                    allModel2Ds.create("PEOPLE", 0, x, y, z, 2.5);
                  } else if (people_or_trees == 2) {
                    allModel2Ds.create("TREES", 0, x, y, z, 5 + random(10));
                  } else {
                    allModel1Ds.create(User3D.create_Model1D_Type,  User3D.create_Model1D_Seed,
                                       User3D.create_Model1D_DegreeMax,
                                       x, y, z, 5 + random(10), floor(random(360)),
                                       User3D.create_Model1D_BranchTilt, User3D.create_Model1D_BranchTwist,
                                       User3D.create_Model1D_BranchRatio, User3D.create_Model1D_TreeBase,
                                       User3D.create_Model1D_TrunkSize, User3D.create_Model1D_LeafSize);
                  }
                }
              }
            }
          }
        }
      }
    }

    SOLARCHVISION_model_changed();
  }

  void add_onPolar (int people_or_trees, int n, float x0, float y0, float z0, float r1, float r2) {

    for (int i = 0; i < n; i++) {

      float a = floor(random(360));
      float b = pow(random(pow(r1, 2), pow(r2, 2)), 0.5); // to make it uniform on the surface

      float x = x0 + b * funcs.cos_ang(a);
      float y = y0 + b * funcs.sin_ang(a);
      float z = z0;

      if (people_or_trees == 1) {
        allModel2Ds.create("PEOPLE", 0, x, y, z, 2.5);
      } else if (people_or_trees == 2) {
        allModel2Ds.create("TREES", 0, x, y, z, 5 + random(10));
      } else {
        allModel1Ds.create(User3D.create_Model1D_Type, User3D.create_Model1D_Seed,
                           User3D.create_Model1D_DegreeMax,
                           x, y, z, 5 + random(10), floor(random(360)),
                           User3D.create_Model1D_BranchTilt, User3D.create_Model1D_BranchTwist,
                           User3D.create_Model1D_BranchRatio, User3D.create_Model1D_TreeBase,
                           User3D.create_Model1D_TrunkSize, User3D.create_Model1D_LeafSize);
      }
    }

    SOLARCHVISION_model_changed();
  }

  void add_onPlane (int people_or_trees, int n, float x0, float y0, float z0, float rx, float ry, float rot) {

    for (int i = 0; i < n; i++) {

      //float a = random(-rx, rx);
      //float b = random(-ry, ry);

      // 1 meter offset from the edge! <<<<<<<<<<<<<<<<<<<
      float a = random(1-rx, rx-1);
      float b = random(1-ry, ry-1);

      float x = a * funcs.cos_ang(rot) - b * funcs.sin_ang(rot);
      float y = a * funcs.sin_ang(rot) + b * funcs.cos_ang(rot);
      float z = 0;

      x += x0;
      y += y0;
      z += z0;

      if (people_or_trees == 1) {
        allModel2Ds.create("PEOPLE", 0, x, y, z, 2.5);
      } else if (people_or_trees == 2) {
        allModel2Ds.create("TREES", 0, x, y, z, 5 + random(10));
      } else {
        allModel1Ds.create(User3D.create_Model1D_Type, User3D.create_Model1D_Seed,
                           User3D.create_Model1D_DegreeMax,
                           x, y, z, 5 + random(10), floor(random(360)),
                           User3D.create_Model1D_BranchTilt, User3D.create_Model1D_BranchTwist,
                           User3D.create_Model1D_BranchRatio, User3D.create_Model1D_TreeBase,
                           User3D.create_Model1D_TrunkSize, User3D.create_Model1D_LeafSize);
      }
    }

    SOLARCHVISION_model_changed();
  }

  void add_onMesh2 (int people_or_trees, int n, float x1, float y1, float z1, float x2, float y2, float z2) {

    float x0 = 0.5 * (x1 + x2);
    float y0 = 0.5 * (y1 + y2);
    float z0 = 0.5 * (z1 + z2);

    float rx = 0.5 * abs(x2 - x1);
    float ry = 0.5 * abs(y2 - y1);

    for (int i = 0; i < n; i++) {

      //float a = random(-rx, rx);
      //float b = random(-ry, ry);

      // 1 meter offset from the edge! <<<<<<<<<<<<<<<<<<<
      float a = random(1-rx, rx-1);
      float b = random(1-ry, ry-1);

      float x = x0 + a;
      float y = y0 + b;
      float z = z0;

      if (people_or_trees == 1) {
        allModel2Ds.create("PEOPLE", 0, x, y, z, 2.5);
      } else if (people_or_trees == 2) {
        allModel2Ds.create("TREES", 0, x, y, z, 5 + random(10));
      } else {
        allModel1Ds.create(User3D.create_Model1D_Type, User3D.create_Model1D_Seed,
                           User3D.create_Model1D_DegreeMax,
                           x, y, z, 5 + random(10), floor(random(360)),
                           User3D.create_Model1D_BranchTilt, User3D.create_Model1D_BranchTwist,
                           User3D.create_Model1D_BranchRatio, User3D.create_Model1D_TreeBase,
                           User3D.create_Model1D_TrunkSize, User3D.create_Model1D_LeafSize);
      }
    }

    SOLARCHVISION_model_changed();
  }








  void add_DefaultModel (int n) {

    if (WIN3D.FacesShade == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;


    if (Land3D.loadMesh) {

      Create3D.add_onLand(1); // 1 = people

      Create3D.add_onLand(2); // 2 = 2D trees
    } else {
      //allModel2Ds.add_polar(1, 50, 0,0,0, 0,50); // (t, n, x, y, z, r1, r2) // people
      //allModel2Ds.add_polar(2, 50, 0,0,0, 0,50); // (t, n, x, y, z, r1, r2) // trees
    }

    if (n == 1) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
      this.add_Mesh2(7, 5, 0, 1, 0, 0, -50, -50, 0, 50, 50, 0);

      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
      this.add_Box_Corners(-1, 4, 0, 1, 0, 0, -12, -12, 0, 12, 12, 12);

      this.add_Box_Corners(-1, 2, 0, 1, 0, 0, -13, -13, 11.8, 0, 0, 12);
      this.add_Box_Corners(-1, 2, 0, 1, 0, 0, -13, -13, 8.8, 0, 0, 9);
      this.add_Box_Corners(-1, 2, 0, 1, 0, 0, -13, -13, 7.3, 0, 0, 7.5);
      this.add_Box_Corners(-1, 2, 0, 1, 0, 0, -13, -13, 6.55, 0, 0, 6.75);
      this.add_Box_Corners(-1, 2, 0, 1, 0, 0, -13, -13, 5.8, 0, 0, 6);

      this.add_Box_Corners(-1, 2, 0, 1, 0, 0, 13, 13, 11.8, 0, 0, 12);
      this.add_Box_Corners(-1, 2, 0, 1, 0, 0, 13, 13, 8.8, 0, 0, 9);
      this.add_Box_Corners(-1, 2, 0, 1, 0, 0, 13, 13, 7.3, 0, 0, 7.5);
      this.add_Box_Corners(-1, 2, 0, 1, 0, 0, 13, 13, 6.55, 0, 0, 6.75);
      this.add_Box_Corners(-1, 2, 0, 1, 0, 0, 13, 13, 5.8, 0, 0, 6);

      this.add_Box_Corners(-1, 2, 0, 1, 0, 0, 0, -18, 2.9, 18, 0, 3);
      this.add_Box_Corners(-1, 2, 0, 1, 0, 0, -18, 0, 2.9, 0, 18, 3);
    }

    if (n == 2) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
      this.add_Mesh2(7, 6, 0, 1, 0, 0, -32, -32, 0, 32, 32, 0);

      allGroups.beginNewGroup(0, -15, 0, 1, 1, 1, 0, 0, 0);
      this.add_CrystalSphere(7, 0, 0, 1, 0, 0, 0, -15, 0, 5, 4, 0, 0);

      allGroups.beginNewGroup(0, 15, 0, 1, 1, 1, 0, 0, 0);
      this.add_CrystalSphere(7, 0, 0, 1, 0, 0, 0, 15, 0, 5, 4, 0, 0);

      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
      this.add_House2_Core(7, 2, 0, 1, 0, 0, 0, 0, 0, 6, 6, 6, 6, 0);
    }

    if (n == 3) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
      this.add_Mesh2(7, 5, 0, 1, 0, 0, -15, -15, 0, 15, 15, 0);

      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
      this.add_House2_Core(0, 0, 0, 1, 0, 0, 0, 0, 0, 6, 6, 6, 6, 0);
    }

    if (n == 4) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
      this.add_Mesh2(7, 5, 0, 1, 0, 0, -15, -15, 0, 15, 15, 0);

      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
      this.add_House3_Core(0, 0, 0, 1, 0, 0, 0, 0, 0, 6, 6, 6, 6, 0);
    }

    if (n == 5) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
      this.add_Mesh2(7, 5, 0, 1, 0, 0, -15, -15, 0, 15, 15, 0);

      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
      this.add_CrystalSphere(7, 0, 0, 1, 0, 0, 0, 0, 5, 5, 4, 0, 0);
    }

    if (n == 6) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
      this.add_Mesh2(7, 5, 0, 1, 0, 0, -16, -16, 0, 16, 16, 0);

      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
      this.add_Box_Corners(-1, 4, 0, 1, 0, 0, -8, -8, 0, 8, 8, 8);

      this.add_Box_Corners(-1, 3, 0, 1, 0, 0, -8, -10, 4, 8, -8, 8);

      this.add_Box_Corners(-1, 3, 0, 1, 0, 0, -10, -8, 4, -8, 8, 8);

      this.add_Box_Corners(-1, 3, 0, 1, 0, 0, 8, 10, 4, -8, 8, 8);

      this.add_Box_Corners(-1, 3, 0, 1, 0, 0, 10, 8, 4, 8, -8, 8);
    }

    if (n == 7) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
      this.add_Mesh2(7, 6, 0, 1, 0, 0, -50, -50, 0, 50, 50, 0);

      {
        allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
        float x = 0;
        float y = 0;
        float z = 0;
        float r = 10;
        this.add_CrystalSphere(1, 0, 0, 1, 0, 0, x, y, z, r, 5, 0, 90);
        allSolids.create(x, y, z, 2, 2, 2, r, r, r, 0, 0, 0, 1);
      }

      {
        allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
        float x = -20;
        float y = -20;
        float z = 0;
        float r = 8;
        this.add_CrystalSphere(2, 0, 0, 1, 0, 0, x, y, z, r, 4, 0, 90);
        allSolids.create(x, y, z, 2, 2, 2, r, r, r, 0, 0, 0, 1);
      }

      {
        allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
        float x = 0;
        float y = 20;
        float z = 0;
        float r = 6;
        this.add_CrystalSphere(3, 0, 0, 1, 0, 0, x, y, z, r, 3, 0, 90);
        allSolids.create(x, y, z, 2, 2, 2, r, r, r, 0, 0, 0, 1);
      }
    }

    if (n == 8) {
      //Complex used in the YC book:

      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
      this.add_Mesh2(8, 6, 0, 1, 0, 0, -100, -100, 0, 100, 100, 0);

      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
      int t = 2;
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -78, -78, 0, -66, -42, 12);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -78, -78, 12, -66, -66, 24);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -78, -54, 12, -66, -42, 24);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -78, -78, 24, -66, -42, 36);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -54, -78, 0, -6, -30, 6);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, 6, -78, 0, 30, -54, 24);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, 6, -42, 0, 30, -30, 48);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, 42, -78, 0, 78, -66, 12);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, 42, -66, 0, 48, -42, 12);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, 72, -66, 0, 78, -42, 12);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, 42, -42, 0, 78, -30, 12);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -78, -30, 0, -66, 18, 24);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -54, -18, 0, -30, -12, 24);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -54, -12, 0, -48, 12, 24);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -36, -12, 0, -30, 12, 24);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -54, 12, 0, -30, 18, 24);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -18, -18, 0, 18, 18, 12);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, 30, -18, 0, 54, 30, 12);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, 66, -18, 0, 78, 6, 48);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, 66, 18, 0, 78, 30, 96);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -78, 30, 0, -30, 54, 12);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -18, 30, 0, -12, 54, 24);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -12, 30, 0, 12, 36, 24);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -12, 48, 0, 12, 54, 24);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, 12, 30, 0, 18, 54, 24);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -78, 66, 0, -42, 78, 12);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -78, 66, 12, -66, 78, 24);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -54, 66, 12, -42, 78, 24);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -78, 66, 24, -42, 78, 36);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, -30, 66, 0, 18, 78, 24);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, 30, 42, 0, 42, 78, 12);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, 42, 42, 0, 66, 48, 12);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, 42, 72, 0, 66, 78, 12);
      this.add_Box_Corners(-1, t, 0, 1, 0, 0, 66, 42, 0, 78, 78, 12);
    }
  }

  int maximum_default_models = 6;


  void add_Model_2DsFromFile () {

    allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);


    String[] FileALL = loadStrings(BaseFolder + "/Import/Hamedan_PEOPLE.txt");

    String lineSTR;

    for (int f = 1; f < FileALL.length; f++) { // skip the first line.

      lineSTR = FileALL[f];
      //println(lineSTR);

      String[] parts = split(lineSTR, ",");

      float x = float(parts[0]);
      float y = float(parts[1]);
      float z = float(parts[2]);

      allModel2Ds.create("PEOPLE", 0, x, y, z, 2.5);
    }
  }



  void add_Model_Main () {

    allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);

    addToLastGroup = false;
  }

}
