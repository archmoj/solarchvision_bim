class Create3D {

  final static String CLASS_STAMP = "create3D";

  void add_Octahedron (int m, int tes, int lyr, int vsb, int wgt, int clz, float x, float y, float z, float rx, float ry, float rz, float rot) {
    beginScene3DChange();


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


    model_added();
    }

    endScene3DChange();
  }


  void add_House3_Core (int m, int tes, int lyr, int vsb, int wgt, int clz, float x, float y, float z, float rx, float ry, float rz, float h2, float rot) {
    beginScene3DChange();


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


      model_added();
    }

    endScene3DChange();
  }


  void add_House2_Core (int m, int tes, int lyr, int vsb, int wgt, int clz, float x, float y, float z, float rx, float ry, float rz, float h2, float rot) {
    beginScene3DChange();


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


      model_added();
    }

    endScene3DChange();
  }


  void add_House1_Core (int m, int tes, int lyr, int vsb, int wgt, int clz, float x, float y, float z, float rx, float ry, float rz, float h2, float rot) {
    beginScene3DChange();


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


      model_added();
    }

    endScene3DChange();
  }



  void add_Box_Core (int m, int tes, int lyr, int vsb, int wgt, int clz, float x, float y, float z, float rx, float ry, float rz, float rot) {
    beginScene3DChange();


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


      model_added();
    }

    endScene3DChange();
  }


  // Same b1..b4 base-corner formula as add_Box_Core above (confirmed by
  // mapping the Pyramid branch's own four Mesh3 point sets onto it at
  // rot=0: they match exactly, corner for corner), plus a single shared
  // apex point instead of a second ring of four top corners - a pyramid
  // only needs that one apex, not Box's full eight. Unlike the Mesh3-based
  // substitute it replaces, this applies rot - the original direct
  // Create3D.add_Mesh3(...) calls (and the Mesh3 substitution standing in
  // for them since) never rotated the base at all, so a rotated pyramid
  // is new here, not preserved; flagged rather than silently added. Also
  // adds the same (rx>0)&&(ry>0)&&(rz>0) guard every other _Core function
  // has, which the Mesh3 calls never had either - a degenerate call no
  // longer creates zero-area triangles.
  void add_Pyramid_Core (int m, int tes, int lyr, int vsb, int wgt, int clz, float x, float y, float z, float rx, float ry, float rz, float rot) {
    beginScene3DChange();


    if ((rx > 0) && (ry > 0) && (rz > 0)) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      float teta = rot * PI / 180.0;

      int b1 = allPoints.create(x + (rx * cos(teta) - ry * sin(teta)), y + (rx * sin(teta) + ry * cos(teta)), z - rz);
      int b2 = allPoints.create(x + (-rx * cos(teta) - ry * sin(teta)), y + (-rx * sin(teta) + ry * cos(teta)), z - rz);
      int b3 = allPoints.create(x + (-rx * cos(teta) + ry * sin(teta)), y + (-rx * sin(teta) - ry * cos(teta)), z - rz);
      int b4 = allPoints.create(x + (rx * cos(teta) + ry * sin(teta)), y + (rx * sin(teta) - ry * cos(teta)), z - rz);

      int apex = allPoints.create(x, y, z + rz);

      if (m == -1) current_Material = 0;
      else current_Material = m;

      {//Side 1 (was Mesh3 #1: x-rx,y-ry -> x+rx,y-ry -> apex)
        int[] newFace_nodes = {
          b3, b4, apex
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//Side 2 (was Mesh3 #2: x+rx,y-ry -> x+rx,y+ry -> apex)
        int[] newFace_nodes = {
          b4, b1, apex
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//Side 3 (was Mesh3 #3: x+rx,y+ry -> x-rx,y+ry -> apex)
        int[] newFace_nodes = {
          b1, b2, apex
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }
      {//Side 4 (was Mesh3 #4: x-rx,y+ry -> x-rx,y-ry -> apex)
        int[] newFace_nodes = {
          b2, b3, apex
        };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }

      model_added();
    }

    endScene3DChange();
  }


  void add_Box_Corners (int m, int tes, int lyr, int vsb, int wgt, int clz, float x1, float y1, float z1, float x2, float y2, float z2) {
    beginScene3DChange();


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


      model_added();
    }

    endScene3DChange();
  }


  void add_H_shade (int m, int tes, int lyr, int vsb, int wgt, int clz, float x0, float y0, float z0, float d, float w, float Alpha, float Beta) {
    beginScene3DChange();


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

      model_added();
    }

    endScene3DChange();
  }


  void add_V_shade (int m, int tes, int lyr, int vsb, int wgt, int clz, float x0, float y0, float z0, float h, float d, float t, float t0) {
    beginScene3DChange();


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

      model_added();
    }

    endScene3DChange();
  }



  void add_Mesh2 (int m, int tes, int lyr, int vsb, int wgt, int clz, float x1, float y1, float z1, float x3, float y3, float z3) {
    beginScene3DChange();


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

      model_added();
    }

    endScene3DChange();
  }


  void add_Mesh3 (int m, int tes, int lyr, int vsb, int wgt, int clz, float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3) {
    beginScene3DChange();


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


          model_added();
        }
      }
    }

    endScene3DChange();
  }



  void add_Mesh4 (int m, int tes, int lyr, int vsb, int wgt, int clz, float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3, float x4, float y4, float z4) {
    beginScene3DChange();


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

      model_added();
    }

    endScene3DChange();
  }



  void add_Mesh5 (int m, int tes, int lyr, int vsb, int wgt, int clz, float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3, float x4, float y4, float z4, float x5, float y5, float z5) {
    beginScene3DChange();


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

      model_added();
    }

    endScene3DChange();
  }


  void add_Mesh6 (int m, int tes, int lyr, int vsb, int wgt, int clz, float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3, float x4, float y4, float z4, float x5, float y5, float z5, float x6, float y6, float z6) {
    beginScene3DChange();


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

      model_added();
    }

    endScene3DChange();
  }


  void add_Mesh (int m, int tes, int lyr, int vsb, int wgt, int clz, float[][] points) {

    if (points.length < 3) return;

    beginScene3DChange();

    current_Material = m;
    current_Tessellation = tes;
    current_Layer = lyr;
    current_Visibility = vsb;
    current_Weight = wgt;
    current_Closed = clz;

    int[] newFace_nodes = new int[points.length];

    for (int i = 0; i < points.length; i++) {
      newFace_nodes[i] = allPoints.create(points[i][0], points[i][1], points[i][2]);
    }

    allFaces.create(newFace_nodes);

    endScene3DChange();
    model_added();
  }


  void add_PolygonHyper (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float r, float h, int n, float rot) {
    beginScene3DChange();


    if ((r > 0) && (h > 0) && (n > 2)) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      int[] newFace_nodes = new int [n];
      newFace_nodes[0] = allPoints.create(cx + r * funcs.cos_ang(rot), cy + r * funcs.sin_ang(rot), cz - 0.5 * h);
      for (int i = 1; i < n; i++) {
        float t = i * 360.0 / float(n);
        newFace_nodes[i] = allPoints.create(cx + r * funcs.cos_ang(t + rot), cy + r * funcs.sin_ang(t + rot), cz + (2 * (i % 2) - 1) * 0.5 * h);
      }

      allFaces.create(newFace_nodes);

      model_added();
    }

    endScene3DChange();
  }



  void add_PolygonMesh (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float r, int n, float rot) {
    beginScene3DChange();


    if ((r > 0) && (n > 2)) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      int[] newFace_nodes = new int [n];
      newFace_nodes[0] = allPoints.create(cx + r * funcs.cos_ang(rot), cy + r * funcs.sin_ang(rot), cz);
      for (int i = 1; i < n; i++) {
        float t = i * 360.0 / float(n) + rot;
        newFace_nodes[i] = allPoints.create(cx + r * funcs.cos_ang(t), cy + r * funcs.sin_ang(t), cz);
      }

      allFaces.create(newFace_nodes);

      model_added();
    }

    endScene3DChange();
  }



  void add_PolygonExtrude (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float r, float h, int n, float rot) {
    beginScene3DChange();


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

      int[] newFace_nodesT = new int [n];
      int[] newFace_nodesB = new int [n];
      newFace_nodesT[0] = vT[0];
      newFace_nodesB[0] = vB[0];
      for (int i = 1; i < n; i++) {
        float t = i * 360.0 / float(n);

        vT[i] = allPoints.create(cx + r * funcs.cos_ang(t + rot), cy + r * funcs.sin_ang(t + rot), cz + 0.5 * h);
        vB[i] = allPoints.create(cx + r * funcs.cos_ang(t + rot), cy + r * funcs.sin_ang(t + rot), cz - 0.5 * h);

        newFace_nodesT[i] = vT[i];
        newFace_nodesB[i] = vB[i];
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

      model_added();
    }

    endScene3DChange();
  }






  void add_Icosahedron (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float r, float rot) {
    beginScene3DChange();


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

      model_added();
    }

    endScene3DChange();
  }



  // Regular tetrahedron, same (cx, cy, cz, r, rot) signature as
  // add_Icosahedron() above - r is the circumradius (every vertex sits
  // exactly r from the center), not an edge length. Same "one apex on the
  // z-axis, the rest on a ring below it" construction Icosahedron uses,
  // just with a 3-vertex ring instead of a 5-vertex one: for a regular
  // tetrahedron, the angle subtended at the center between any 2 vertices
  // is arccos(-1/3), so with v0 = (0, 0, r), every other vertex has
  // z = r*cos(theta) = -r/3 and a ring radius of r*sin(theta) =
  // r*sqrt(1 - 1/9) = r*2*sqrt(2)/3 (verified numerically: all 4 vertices
  // equidistant from the center, all 6 edges equal length).
  void add_Tetrahedron (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float r, float rot) {
    beginScene3DChange();


    if (r > 0) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      float R_base = r * 2.0 * pow(2.0, 0.5) / 3.0;
      float z_ring = cz - r / 3.0;

      int[] v = new int [4];

      v[0] = allPoints.create(cx, cy, cz + r);

      for (int i = 1; i <= 3; i++) {
        float t = (i - 1) * 120 + rot;
        v[i] = allPoints.create(cx + R_base * funcs.cos_ang(t), cy + R_base * funcs.sin_ang(t), z_ring);
      }

      if (m == -1) current_Material = 0;
      else current_Material = m;

      // Base face first, in reverse ring order (v1, v3, v2) so its own
      // outward normal points down (away from the apex), then the 3
      // side faces (v0, v_i, v_{i+1}), each already CCW-outward by the
      // same cross-product check add_Octahedron()/add_Icosahedron() rely
      // on above.
      {
        int[] newFace_nodes = { v[1], v[3], v[2] };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }

      for (int i = 1; i <= 3; i++) {
        int next_i = (i % 3) + 1;
        int[] newFace_nodes = { v[0], v[i], v[next_i] };
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }

      model_added();
    }

    endScene3DChange();
  }



  // Regular dodecahedron, same (cx, cy, cz, r, rot) signature as
  // add_Icosahedron()/add_Tetrahedron() above - r is the circumradius.
  // Unlike those 2, a dodecahedron has no vertex-plus-ring symmetry to
  // build it from directly, so its 20 vertices are the standard
  // construction instead: the 8 corners of a cube, plus 3 sets of 4
  // vertices each built from the golden ratio phi - every one of those
  // 20 points sits at distance sqrt(3) from the center at unit scale
  // (cube corners (+-1,+-1,+-1) at sqrt(3); e.g. (0, 1/phi, phi) at
  // sqrt(1/phi^2 + phi^2) = sqrt(3) too, since phi^2 = phi+1 and
  // 1/phi^2 = 2-phi), so scaling every coordinate by r/sqrt(3) gives
  // every vertex exactly the requested circumradius. Its 12 pentagonal
  // faces don't need triangulating - the mesh format already supports
  // n-gon faces directly - but unlike a tetrahedron's or icosahedron's
  // faces, their vertex connectivity isn't a simple formula; the 12
  // index lists below were derived (and verified: all 20 vertices
  // equidistant from the center, all 12 faces planar regular pentagons
  // with one shared edge length, all already wound CCW-outward) from
  // this exact vertex ordering via a convex-hull computation, not
  // transcribed by hand.
  void add_Dodecahedron (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float r, float rot) {
    beginScene3DChange();


    if (r > 0) {

      current_Material = m;
      current_Tessellation = tes;
      current_Layer = lyr;
      current_Visibility = vsb;
      current_Weight = wgt;
      current_Closed = clz;

      float s = r / pow(3.0, 0.5);
      float phi = (1.0 + pow(5.0, 0.5)) / 2.0;
      float invPhi = 1.0 / phi;

      float[] X_ = new float [20];
      float[] Y_ = new float [20];
      float[] Z_ = new float [20];

      // Sign order within each group matters: the faceIndices table below
      // was derived against exactly this iteration order (sign +1 before
      // -1, outer-to-inner as written) - see this function's own header
      // comment.
      float[] sign2 = { 1, -1 };

      int idx = 0;
      for (float sx : sign2) {
        for (float sy : sign2) {
          for (float sz : sign2) {
            X_[idx] = sx;
            Y_[idx] = sy;
            Z_[idx] = sz;
            idx++;
          }
        }
      }
      for (float sy : sign2) {
        for (float sz : sign2) {
          X_[idx] = 0;
          Y_[idx] = sy * invPhi;
          Z_[idx] = sz * phi;
          idx++;
        }
      }
      for (float sx : sign2) {
        for (float sy : sign2) {
          X_[idx] = sx * invPhi;
          Y_[idx] = sy * phi;
          Z_[idx] = 0;
          idx++;
        }
      }
      for (float sx : sign2) {
        for (float sz : sign2) {
          X_[idx] = sx * phi;
          Y_[idx] = 0;
          Z_[idx] = sz * invPhi;
          idx++;
        }
      }

      float teta = rot * PI / 180.0;

      int[] v = new int [20];
      for (int i = 0; i < 20; i++) {
        float X_s = X_[i] * s;
        float Y_s = Y_[i] * s;
        float Z_s = Z_[i] * s;

        float X_r = X_s * cos(teta) - Y_s * sin(teta);
        float Y_r = X_s * sin(teta) + Y_s * cos(teta);
        float Z_r = Z_s;

        v[i] = allPoints.create(X_r + cx, Y_r + cy, Z_r + cz);
      }

      if (m == -1) current_Material = 0;
      else current_Material = m;

      // Each row is one pentagon's 5 vertex indices, already in
      // CCW-outward order - see this function's own header comment for
      // how these were derived and verified.
      int[][] faceIndices = {
        {9, 11, 7, 19, 5},
        {12, 1, 9, 5, 14},
        {4, 14, 5, 19, 18},
        {10, 8, 4, 18, 6},
        {13, 2, 10, 6, 15},
        {7, 15, 6, 18, 19},
        {17, 16, 2, 13, 3},
        {1, 17, 3, 11, 9},
        {11, 3, 13, 15, 7},
        {16, 17, 1, 12, 0},
        {2, 16, 0, 8, 10},
        {0, 12, 14, 4, 8}
      };

      for (int[] faceIdx : faceIndices) {
        int[] newFace_nodes = new int [5];
        for (int s2 = 0; s2 < 5; s2++) {
          newFace_nodes[s2] = v[faceIdx[s2]];
        }
        if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
        allFaces.create(newFace_nodes);
      }

      model_added();
    }

    endScene3DChange();
  }



  // One shared surface generator for 8 hardcoded (x(u,v), y(u,v), z(u,v))
  // formulas, picked by n (0..7) - the switch below is the one place
  // that actually defines what each n looks like. n=1..7 are the Create
  // menu's own "Dome Surface" / "Egg-Crate Surface" / "Saddle Surface" /
  // "Tetra Wave Surface" / "Tetra Sphere" / "Grid Sphere" / "Torus"
  // items (uiMenuBar.pde's PARENT_CREATE, wired in actions.pde) -
  // User3D.creatorParametricTypeIndex just carries whichever one was
  // picked through to here, unchanged, so this comment is the map from
  // a menu name back to its own n value and formula. n=0 is NOT exposed
  // in that menu at all (reachable only via the "Parametric n=0 ..."
  // script command's own default) and is NOT the same thing as the
  // menu's separate "Cushion" command (CREATE.SuperOBJ/add_SuperSphere,
  // an unrelated superellipsoid) - see n==0's own comment below for why
  // that distinction matters.
  //
  // k only means anything to n==7 (Torus) - every other n ignores it
  // outright, same as how rx/ry/rz/rot already work on every n uniformly
  // while n itself picks the formula. It's the torus's own minor:major
  // radius ratio (tube thickness relative to the ring's own radius,
  // which is fixed at 1 before rx/ry/rz scale it) - the one shape
  // parameter that can't be expressed as a post-formula axis scale the
  // way every other preset's entire shape already is, since it changes
  // the formula itself rather than stretching its output. Clamped to
  // (0, 1): k==0 collapses the tube to a zero-thickness ring, and k>=1
  // produces a self-intersecting "spindle torus" (the tube's own radius
  // would reach past the ring's own center) - a real shape, just not
  // the one this clamp is meant to hand back by default.
  void add_ParametricSurface (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float rx, float ry, float rz, int n, float rot, float k, int stepsU, int stepsV) {
    beginScene3DChange();


    current_Material = m;
    current_Tessellation = tes;
    current_Layer = lyr;
    current_Visibility = vsb;
    current_Weight = wgt;
    current_Closed = clz;

    if (m == -1) current_Material = 0;
    else current_Material = m;

    float teta = rot * PI / 180.0;

    float start_u = -1;
    float start_v = -1;
    float end_u = 1;
    float end_v = 1;

    if ((n == 0) || (n == 6) || (n == 8) || (n == 9)) {
      start_u = 0; // n==8/9 (Hyperbolic Disc/Paraboloid Dish): u is a radius, 0..1, not -1..1
    }

    final float HELICOID_TURNS = 2; // n==11 Helicoid only - how many full turns the ramp winds through across its own -1..1 height range

    // U/V grid resolution - a shared, generic User3D.creatorParametricStepsU/
    // V pair feeding every preset here (n=0..7, Torus included), replacing
    // this function's own former hardcoded 0.1/0.05 step sizes (which
    // varied by n, not user-controllable). stepsU/stepsV count GRID CELLS,
    // not grid lines, so dividing the domain's own span directly by the
    // count (not count-1) is what makes e.g. stepsU=36 produce exactly 36
    // quads across the u direction. Clamped to at least 1 - a 0 or
    // negative step count would either divide by zero or run the loop
    // below backwards/not at all.
    int clampedStepsU = max(1, stepsU);
    int clampedStepsV = max(1, stepsV);
    float stp_u = (end_u - start_u) / clampedStepsU;
    float stp_v = (end_v - start_v) / clampedStepsV;

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

          if (n == 6) { // "Grid Sphere" in the Create menu (uiMenuBar.pde) -
                         // renamed from "Twisted Sphere", which didn't match
                         // the shape's own regular crossing-grid pattern.
                         // x/y/z driven asymmetrically by u and v (x depends only
                         // on u, y only on v), then normalized onto a unit
                         // sphere - lumpier than the more regular n==5 "Wavy
                         // Sphere" below. Same raw x0/y0/z0 formula as n==0
                         // below, just normalized here and not there.
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
          } else if (n == 0) { // This genuinely IS the Create menu's "Cushion"
                                // command's own shape - correcting an earlier,
                                // wrong claim in this comment that the two were
                                // unrelated. The trace: UI_setTo_Create_Cushion()
                                // (uiSetTo.pde) sets CREATE.SuperOBJ with powers
                                // (CubePower, CubePower, 2); on click,
                                // mouseClicked.pde's classifySuperOBJShape(px,
                                // py, pz) matches exactly that combination to
                                // SUPEROBJ_SHAPE_PARAMETRIC, which runs
                                // "Parametric ... n=0" - landing right here. n=0
                                // isn't reachable through the Create menu's own
                                // "Dome/Egg-Crate/Saddle/.../Grid Sphere"
                                // items (those only ever pass n=1..6), only
                                // through Cushion's own SuperOBJ power preset.
                                // Same raw formula as n==6 above, just not
                                // normalized onto the sphere.
            x = cos(u * PI);
            y = sin(v * PI);
            z = -sin(u * PI) * cos(v * PI);
          } else if (n == 4) { // "Tetra Wave Surface" - renamed from "Diagonal
                                // Wave Surface" - ripples running diagonally
                                // across a flat u/v grid, passing through 4 of
                                // a cube's own alternating (tetrahedral)
                                // vertices along the way: at (u,v) = (0.5,
                                // -0.5)/(-0.5, 0.5)/(0.5, 0.5)/(-0.5, -0.5),
                                // (x, y, z) lands exactly on (1,-1,1)/(-1,1,1)/
                                // (1,1,-1)/(-1,-1,-1) - see n==5's own comment
                                // below for what those same 4 points become
                                // once normalized onto a sphere.
            x = sin(u * PI);
            y = sin(v * PI);
            z = cos((u + v) * PI);
          } else if (n == 5) { // "Tetra Sphere" - renamed from "Wavy Sphere" -
                                // same formula as n==4 above, normalized onto
                                // a unit sphere, which lands n==4's own 4
                                // alternating-cube-vertex points (see n==4's
                                // own comment above) exactly on the 4 vertices
                                // of a regular tetrahedron inscribed in this
                                // sphere - a genuine tetrahedral symmetry, not
                                // just a visual resemblance.
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
          } else if (n == 1) { // "Dome Surface" - bulges up in the middle, pinches to zero along all four edges
            x = u;
            y = v;
            z = cos(0.5 * u * PI) * cos(0.5 * v * PI);
          } else if (n == 2) { // "Egg-Crate Surface" - four alternating bumps/dips, the classic textbook ripple
            x = u;
            y = v;
            z = 0.5 * sin(u * PI) * sin(v * PI);
          } else if (n == 3) { // "Saddle Surface" - a hyperbolic paraboloid
            x = u;
            y = v;
            z = u * v;
          } else if (n == 7) { // "Torus" - u is the ring's own angle (major
                                // circle, radius 1 before rx/ry/rz), v is
                                // the tube's own angle (minor circle,
                                // radius k) - standard torus parametrization,
                                // closing up in both directions for free the
                                // same way n==5/n==6 already do, since u*PI
                                // and v*PI both already span one full period
                                // (-PI..PI) across this function's own fixed
                                // u/v domain.
            float kClamped = constrain(k, FLOAT_tiny, 1 - FLOAT_tiny);
            x = (1 + kClamped * cos(v * PI)) * cos(u * PI);
            y = (1 + kClamped * cos(v * PI)) * sin(u * PI);
            z = kClamped * sin(v * PI);
          } else if (n == 8) { // "Hyperbolic Disc" - the same hyperbolic
                                // paraboloid as n==3 Saddle (z = x*y), but
                                // swept in polar coordinates (u is a 0..1
                                // radius, not -1..1 - see the "start_u = 0"
                                // line above; v is the angle, closing up
                                // for free across its own full -PI..PI
                                // sweep, same as n==7 Torus's own v) instead
                                // of Cartesian x/y - a circular, not square,
                                // footprint around the same saddle shape.
            float r = u;
            float theta = v * PI;
            x = r * cos(theta);
            y = r * sin(theta);
            z = x * y;
          } else if (n == 9) { // "Paraboloid Dish" - a solar-concentrator-
                                // dish shape: z = r^2, the same polar
                                // (u = 0..1 radius, v = angle) domain as
                                // n==8 Hyperbolic Disc above, just a
                                // different height field - a bowl, not a
                                // saddle. rz (applied below, same as every
                                // other preset) controls the dish's own
                                // depth relative to its radius, exactly
                                // the way it already controls bulge height
                                // for n==1 Dome - no separate ratio
                                // parameter needed, unlike n==7 Torus.
            float r = u;
            float theta = v * PI;
            x = r * cos(theta);
            y = r * sin(theta);
            z = r * r;
          } else if (n == 10) { // "Hyperboloid of Revolution" - the
                                 // Shukhov-tower/cooling-tower profile: u
                                 // is the ring's own angle (full circle,
                                 // same -1..1 * PI sweep as n==7 Torus's
                                 // own u, closing up for free), v is a
                                 // literal height (-1..1, NOT an angle -
                                 // unlike every other preset here, so
                                 // start_v is left at its own ordinary
                                 // default, same as start_u). r(v) =
                                 // sqrt(1 + v^2) is the hyperbola traced
                                 // out from the waist (v=0, r=1, the
                                 // narrowest ring) to either open end
                                 // (v=+-1, r=sqrt(2)) - a fixed waist-
                                 // tightness, no separate ratio parameter
                                 // like n==7 Torus's own k (rx/ry/rz,
                                 // applied below same as every preset,
                                 // already give plenty of control over
                                 // the overall proportions).
            float theta = u * PI;
            float r = sqrt(1 + v * v);
            x = r * cos(theta);
            y = r * sin(theta);
            z = v;
          } else if (n == 11) { // "Helicoid" - a spiral ramp/parking-garage
                                 // shape: u is the radius (-1..1, both
                                 // signs - a NEGATIVE u lands on the
                                 // opposite side of the axis at the SAME
                                 // height/turn, same as a positive u would
                                 // at one turn further around, which is
                                 // exactly what makes the ramp pass
                                 // through the central axis rather than
                                 // leaving a hole there), v is both the
                                 // height (z = v directly, same -1..1
                                 // convention rz already scales for every
                                 // other preset) and, scaled by a fixed
                                 // HELICOID_TURNS, the ramp's own
                                 // winding angle - unlike n==7 Torus/n==10
                                 // Hyperboloid, u and v are NOT independent
                                 // angle/radius pairs here: the angle is
                                 // tied to the height, which is what makes
                                 // this a spiral rather than a surface of
                                 // revolution. No separate turns parameter
                                 // (unlike n==7 Torus's own k) - two turns
                                 // reads clearly as a helicoid without the
                                 // default 36x36 grid's quads getting too
                                 // twisted to render as sensible flat-ish
                                 // faces.
            float r = u;
            float theta = v * HELICOID_TURNS * PI;
            x = r * cos(theta);
            y = r * sin(theta);
            z = v;
          } else if (n == 12) { // "Catenoid" - the soap-film-between-two-
                                 // rings minimal surface: same full-circle
                                 // u / literal-height v layout as n==10
                                 // Hyperboloid of Revolution (u is the
                                 // ring's own angle, full -1..1*PI sweep;
                                 // v is a literal height, not an angle, so
                                 // start_v is left at its own ordinary
                                 // default same as start_u), but r(v) =
                                 // cosh(v) instead of sqrt(1+v^2) - the
                                 // catenary curve traced out from the
                                 // waist (v=0, r=1, the narrowest ring,
                                 // same as n==10's own waist) to either
                                 // open end. No exp()/cosh() built in to
                                 // Processing's own API, so cosh(v) is
                                 // spelled out as (e^v + e^-v)/2 directly.
            float theta = u * PI;
            float r = (exp(v) + exp(-v)) / 2.0;
            x = r * cos(theta);
            y = r * sin(theta);
            z = v;
          } else if (n == 13) { // "Conoid" - a true ruled surface (unlike
                                 // every preset above, which all sweep a
                                 // single curve around an axis): a flat
                                 // straight rail on the south side (y=-1,
                                 // z=0 throughout - the ground-level
                                 // ridge beam), ruled straight across to
                                 // a VERTICAL half-circle standing on the
                                 // north side (y=1, in the x/z plane,
                                 // z>=0 - the open end's own archway),
                                 // touching the ground (z=0) only at its
                                 // own two endpoints (u=-1/+1), with its
                                 // own apex (u=0) reaching straight up to
                                 // z=1 - the classic conoidal-shell-roof
                                 // shape, not tilted the way a flat-
                                 // footprint arc would be. u picks the
                                 // matching point on BOTH directrices at
                                 // once (the rail's own x, and the arc's
                                 // own angle, chosen so their x endpoints
                                 // line up exactly: u = -1/+1 both land
                                 // on x = -1/+1 on either directrix), v
                                 // (t = (v+1)/2, 0..1) linearly blends
                                 // between them - a straight generator
                                 // line for every fixed u, which is what
                                 // makes this a conoid rather than
                                 // another bowl/dish.
            float t = (v + 1) / 2.0;
            float angle = (1 - u) / 2.0 * PI; // u=-1 -> PI (arc x=-1), u=+1 -> 0 (arc x=1)
            float archX = cos(angle);
            float archZ = sin(angle); // always >= 0 - the arch's own upward bulge, zero only at its two endpoints
            float lineX = u; // matches archX at both endpoints (u=-1 -> -1, u=+1 -> 1)
            float lineY = -1; // the straight rail's own south side
            float archY = 1; // the vertical arch's own north side - a fixed plane, not swept in y like the rail
            x = lineX + t * (archX - lineX);
            y = lineY + t * (archY - lineY);
            z = t * archZ; // the rail's own z is 0 throughout, so this is the whole blend
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

    endScene3DChange();
    model_added();
  }


  void add_CrystalSphere (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float r, int tessellation, int isSky, float t) {
    beginScene3DChange();


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


    if (isSky == 0) {
      this.addTempObjectToScene(m, tes, lyr, vsb, wgt, clz, cx, cy, cz, r, r, r, t);
    } else if (isSky == 1) {


      skyVertices = new float [POINTER_TempObjectVertices][3];
      skyFaces = new int [POINTER_TempObjectFaces][4];

      for (int i = 0; i < POINTER_TempObjectVertices; i++) {

        skyVertices[i][0] = TempObjectVertices[i][0];
        skyVertices[i][1] = TempObjectVertices[i][1];
        skyVertices[i][2] = TempObjectVertices[i][2];
      }

      for (int i = 0; i < POINTER_TempObjectFaces; i++) {

        skyFaces[i][0] = TempObjectFaces[i][0];
        skyFaces[i][1] = TempObjectFaces[i][1];
        skyFaces[i][2] = TempObjectFaces[i][2];
        skyFaces[i][3] = TempObjectFaces[i][3];
      }


      POINTER_TempObjectVertices = 0;
      POINTER_TempObjectFaces = 0;

      Sky3D.invalidateTessellationCache();
    } else {
      // Nothing. In this case we should add temp object outside this function. See SuperSphere
    }

    endScene3DChange();
    model_added();
  }



  void add_SuperSphere (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float px, float py, float pz, float sx, float sy, float sz, int tessellation, float t) {
    beginScene3DChange();


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

    endScene3DChange();
    model_added();
  }


  void add_SuperCylinder (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz, int n, float t) {
    beginScene3DChange();


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

    int[] newFace_nodesT = new int [n];
    int[] newFace_nodesB = new int [n];
    newFace_nodesT[0] = vT[0];
    newFace_nodesB[0] = vB[0];
    for (int i = 1; i < n; i++) {
      float rot = i * 360.0 / float(n);

      vT[i] = this.addToTempObjectVertices(funcs.cos_ang(rot), funcs.sin_ang(rot), 1);
      vB[i] = this.addToTempObjectVertices(funcs.cos_ang(rot), funcs.sin_ang(rot), -1);

      newFace_nodesT[i] = vT[i];
      newFace_nodesB[i] = vB[i];
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

    endScene3DChange();
    model_added();
  }

  void add_Cone (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz, int n, float t) {
    beginScene3DChange();


    current_Material = m;
    current_Tessellation = tes;
    current_Layer = lyr;
    current_Visibility = vsb;
    current_Weight = wgt;
    current_Closed = clz;

    int vT = this.addToTempObjectVertices(0, 0, 1);

    int[] vB = new int [n];
    vB[0] = this.addToTempObjectVertices(1, 0, -1);

    int[] newFace_nodesB = new int [n];
    newFace_nodesB[0] = vB[0];
    for (int i = 1; i < n; i++) {
      float rot = i * 360.0 / float(n);

      vB[i] = this.addToTempObjectVertices(funcs.cos_ang(rot), funcs.sin_ang(rot), -1);

      newFace_nodesB[i] = vB[i];
    }

    this.addToTempObjectFaces(newFace_nodesB, 0); // 0:check_duplicates

    for (int i = 0; i < n; i++) {
      int next_i = (i + 1) % n;

      int[] newFace_nodes = {
        vT, vB[i], vB[next_i]
      };

      this.addToTempObjectFaces(newFace_nodes, 0); // 0:check_duplicates
    }

    this.addTempObjectToScene(m, tes, lyr, vsb, wgt, clz, cx, cy, cz, sx, sy, sz, t);

    endScene3DChange();
    model_added();
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
        int growBy = max(64, TempObjectVertices.length);
        float[][] extraCapacity = new float [growBy][3];
        TempObjectVertices = (float[][]) concat(TempObjectVertices, extraCapacity);
      }

      TempObjectVertices[POINTER_TempObjectVertices][0] = x;
      TempObjectVertices[POINTER_TempObjectVertices][1] = y;
      TempObjectVertices[POINTER_TempObjectVertices][2] = z;

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

              float total_distances = 0;

              for (int j = 0; j < f.length; j++) {

                int q = (j * dir + k + f.length) % f.length;

                total_distances += funcs.vec_dist(TempObjectVertices[f[q]], TempObjectVertices[TempObjectFaces[i][j]]);
              }

              if (total_distances < 0.0001) { // avoid creating duplicate faces
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
        int growBy = max(64, TempObjectFaces.length);
        int[][] extraCapacity = new int [growBy][1];
        TempObjectFaces = (int[][]) concat(TempObjectFaces, extraCapacity);
      }

      TempObjectFaces[POINTER_TempObjectFaces] = new int [f.length];

      for (int i = 0; i < f.length; i++) {
        TempObjectFaces[POINTER_TempObjectFaces][i] = f[i];
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

      int[] new_vertexSelection = new int [TempObjectFaces[i].length];

      for (int j = 0; j < TempObjectFaces[i].length; j++) {

        float x0 = TempObjectVertices[TempObjectFaces[i][j]][0] * sx;
        float y0 = TempObjectVertices[TempObjectFaces[i][j]][1] * sy;
        float z0 = TempObjectVertices[TempObjectFaces[i][j]][2] * sz;

        float x = x0 * funcs.cos_ang(t) - y0 * funcs.sin_ang(t);
        float y = x0 * funcs.sin_ang(t) + y0 * funcs.cos_ang(t);
        float z = z0;

        new_vertexSelection[j] = allPoints.create(x + cx, y + cy, z + cz);
      }

      if (m == -1) current_Material = 1 + (current_Material % (allMaterials.Number - 1));
      allFaces.create(new_vertexSelection);
    }

    TempObjectVertices = new float [0][3];

    TempObjectFaces = new int [0][1];

    POINTER_TempObjectVertices = 0;
    POINTER_TempObjectFaces = 0;

    model_added();
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

    model_added();
  }



  void add_onTerrain (int people_or_trees) {
    beginScene3DChange();


    //randomSeed(0);

    float[][] treesXYZS = {
      {
        0, 0, 0, 0
      }
    };
    int treesCount = 1; // index 0 is a sentinel row; real trees start at 1

    int tessellation = Terrain.displayTessellation;

    int totalNumberOfSubs = 1;
    if (tessellation > 0) totalNumberOfSubs = 4 * int(funcs.roundTo(pow(4, tessellation - 1), 1)); // = 4 * ... because in LAND grid the cell has 4 points.



    if ((Terrain.displayTexture) && (people_or_trees != 1)) { // using another algorithm for people << i.e. no image processing from green colors of the map!

      for (int i = Terrain.skipStart; i < Terrain.rowCount - 1 - Terrain.skipEnd; i++) {
        for (int j = 0; j < Terrain.columnCount - 1; j++) {

          float[][] base_Vertices = new float [4][3];

          base_Vertices[0][0] = Terrain.Mesh[i][j][0];
          base_Vertices[0][1] = Terrain.Mesh[i][j][1];
          base_Vertices[0][2] = Terrain.Mesh[i][j][2];

          base_Vertices[1][0] = Terrain.Mesh[i+1][j][0];
          base_Vertices[1][1] = Terrain.Mesh[i+1][j][1];
          base_Vertices[1][2] = Terrain.Mesh[i+1][j][2];

          base_Vertices[2][0] = Terrain.Mesh[i+1][j+1][0];
          base_Vertices[2][1] = Terrain.Mesh[i+1][j+1][1];
          base_Vertices[2][2] = Terrain.Mesh[i+1][j+1][2];

          base_Vertices[3][0] = Terrain.Mesh[i][j+1][0];
          base_Vertices[3][1] = Terrain.Mesh[i][j+1][1];
          base_Vertices[3][2] = Terrain.Mesh[i][j+1][2];

          for (int n = 0; n < totalNumberOfSubs; n++) {

            float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

            int n_Map = -1;
            for (int q = 0; q < Terrain.Textures_num; q++) { // increase the resolution until all the vertices located inside the appropriate map

              n_Map = q;

              for (int s = 0; s < subFace.length; s++) {

                float u = Terrain.landTextureU(subFace[s][0], q);
                float v = Terrain.landTextureV(subFace[s][1], q);

                if ((0 > u) || (u > 1) || (0 > v) || (v > 1)) {

                  n_Map = -1;

                  break;
                }
              }

              if (n_Map == q) break;
            }

            if (n_Map != -1) {

              int max_o = int(10000 / pow(2, Terrain.displayTessellation)); // number of tries to find green points!

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

                float u = Terrain.landTextureU(x, n_Map);
                float v = Terrain.landTextureV(y, n_Map);

                int uPixel = int(u * Terrain.Textures_map[n_Map].width);
                int vPixel = int(v * Terrain.Textures_map[n_Map].height);

                color COL = Terrain.Textures_map[n_Map].get(uPixel, vPixel);
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

                    for (int f = 1; f < treesCount; f++) {

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
                        allModel1Ds.create(User3D.creatorModel1DTypeIndex, User3D.creatorModel1DSeed,
                                           User3D.creatorModel1DDegreeMax,
                                           x, y, z, s, floor(random(360)),
                                           User3D.creatorModel1DBranchTilt, User3D.creatorModel1DBranchTwist,
                                           User3D.creatorModel1DBranchRatio, User3D.creatorModel1DTreeBase,
                                           User3D.creatorModel1DTrunkSize, User3D.creatorModel1DLeafSize);
                      }


                      if (treesCount >= treesXYZS.length) {
                        int growBy = max(64, treesXYZS.length);
                        float[][] extraCapacity = new float [growBy][4];
                        treesXYZS = (float[][]) concat(treesXYZS, extraCapacity);
                      }

                      treesXYZS[treesCount][0] = x;
                      treesXYZS[treesCount][1] = y;
                      treesXYZS[treesCount][2] = z;
                      treesXYZS[treesCount][3] = s;
                      treesCount += 1;
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

      for (int i = Terrain.skipStart; i < Terrain.rowCount - 1 - Terrain.skipEnd; i++) {
        for (int j = 0; j < Terrain.columnCount - 1; j++) {

          float[][] base_Vertices = new float [4][3];

          base_Vertices[0][0] = Terrain.Mesh[i][j][0];
          base_Vertices[0][1] = Terrain.Mesh[i][j][1];
          base_Vertices[0][2] = Terrain.Mesh[i][j][2];

          base_Vertices[1][0] = Terrain.Mesh[i+1][j][0];
          base_Vertices[1][1] = Terrain.Mesh[i+1][j][1];
          base_Vertices[1][2] = Terrain.Mesh[i+1][j][2];

          base_Vertices[2][0] = Terrain.Mesh[i+1][j+1][0];
          base_Vertices[2][1] = Terrain.Mesh[i+1][j+1][1];
          base_Vertices[2][2] = Terrain.Mesh[i+1][j+1][2];

          base_Vertices[3][0] = Terrain.Mesh[i][j+1][0];
          base_Vertices[3][1] = Terrain.Mesh[i][j+1][1];
          base_Vertices[3][2] = Terrain.Mesh[i][j+1][2];

          for (int n = 0; n < totalNumberOfSubs; n++) {

            float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

            //int max_o = int((16.0 / pow(2, Terrain.displayTessellation)) * pow(random(1), 8)); // i.e. maximum 3 people in each pixel for tes=2
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
                    allModel1Ds.create(User3D.creatorModel1DTypeIndex,  User3D.creatorModel1DSeed,
                                       User3D.creatorModel1DDegreeMax,
                                       x, y, z, 5 + random(10), floor(random(360)),
                                       User3D.creatorModel1DBranchTilt, User3D.creatorModel1DBranchTwist,
                                       User3D.creatorModel1DBranchRatio, User3D.creatorModel1DTreeBase,
                                       User3D.creatorModel1DTrunkSize, User3D.creatorModel1DLeafSize);
                  }
                }
              }
            }
          }
        }
      }
    }

    endScene3DChange();
  }

  void add_onPolar (int people_or_trees, int n, float x0, float y0, float z0, float r1, float r2) {
    beginScene3DChange();


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
        allModel1Ds.create(User3D.creatorModel1DTypeIndex, User3D.creatorModel1DSeed,
                           User3D.creatorModel1DDegreeMax,
                           x, y, z, 5 + random(10), floor(random(360)),
                           User3D.creatorModel1DBranchTilt, User3D.creatorModel1DBranchTwist,
                           User3D.creatorModel1DBranchRatio, User3D.creatorModel1DTreeBase,
                           User3D.creatorModel1DTrunkSize, User3D.creatorModel1DLeafSize);
      }
    }

    endScene3DChange();
  }

  void add_onPlane (int people_or_trees, int n, float x0, float y0, float z0, float rx, float ry, float rot) {
    beginScene3DChange();


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
        allModel1Ds.create(User3D.creatorModel1DTypeIndex, User3D.creatorModel1DSeed,
                           User3D.creatorModel1DDegreeMax,
                           x, y, z, 5 + random(10), floor(random(360)),
                           User3D.creatorModel1DBranchTilt, User3D.creatorModel1DBranchTwist,
                           User3D.creatorModel1DBranchRatio, User3D.creatorModel1DTreeBase,
                           User3D.creatorModel1DTrunkSize, User3D.creatorModel1DLeafSize);
      }
    }

    endScene3DChange();
  }

  void add_onMesh2 (int people_or_trees, int n, float x1, float y1, float z1, float x2, float y2, float z2) {
    beginScene3DChange();


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
        allModel1Ds.create(User3D.creatorModel1DTypeIndex, User3D.creatorModel1DSeed,
                           User3D.creatorModel1DDegreeMax,
                           x, y, z, 5 + random(10), floor(random(360)),
                           User3D.creatorModel1DBranchTilt, User3D.creatorModel1DBranchTwist,
                           User3D.creatorModel1DBranchRatio, User3D.creatorModel1DTreeBase,
                           User3D.creatorModel1DTrunkSize, User3D.creatorModel1DLeafSize);
      }
    }

    endScene3DChange();
  }








  // Rewritten to call the public runScript.pde commands instead of these
  // Create3D/allGroups/allSolids/allSections methods directly - same
  // "develop the public API, not the internal calls" reasoning as
  // mouseClicked.pde's own UITASK.Create block. Every substitution below
  // was traced against the actual command case in runScript.pde, not
  // assumed from the method/command names matching - several (Sphere's
  // own d=2*radius and r=t-90, House2/3's dx=2*rx) carry the exact same
  // non-obvious parameter transforms already documented where they were
  // first found.
  //
  // Create3D.add_onTerrain(...) is the one call left direct: no matching
  // command exists for it, and creating one wasn't asked for here.
  // Composite, same reasoning as Delete3D.selection()'s own comment:
  // every runScriptLine() call below (BeginNewGroup, Mesh2, Box2P,
  // Section, ...) dispatches to its own already-wrapped create/group
  // function - without this outer pair too, each would independently
  // record its own step, turning one "3D-model N" action into dozens.
  // Called right after deleteAll() (actions.pde), which already reseeds
  // the undo history to a single fresh baseline of its own - so this
  // composite's own step is the first real edit on top of that baseline.
  void add_DefaultModel (int n) {
    beginScene3DChange();

    find_which_bakings_to_regenerate();

    /*
    if (Terrain.loadMesh) {

      Create3D.add_onTerrain(1); // 1 = people

      Create3D.add_onTerrain(2); // 2 = 2D trees
    } else {
      //allModel2Ds.add_polar(1, 50, 0,0,0, 0,50); // (t, n, x, y, z, r1, r2) // people
      //allModel2Ds.add_polar(2, 50, 0,0,0, 0,50); // (t, n, x, y, z, r1, r2) // trees
    }
    */

    if (n == 1) {
      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      runScriptLine("Mesh2 m=7 tes=5 lyr=0 vsb=1 wgt=0 clz=0 x1=-16 y1=-16 z1=0 x2=16 y2=16 z2=0");

      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      // CrystalSphere's own "radius" argument (5 here) is SPHERE's d/2,
      // and its "t" argument (0 here) is SPHERE's own 90+r - so d=10,
      // r=0-90=-90.
      runScriptLine("Sphere m=7 tes=0 lyr=0 vsb=1 wgt=0 clz=0 x=0 y=0 z=5 d=10 deg=4 r=-90");
    }

    if (n == 2) {
      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      runScriptLine("Mesh2 m=7 tes=5 lyr=0 vsb=1 wgt=0 clz=0 x1=-16 y1=-16 z1=0 x2=16 y2=16 z2=0");

      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      runScriptLine("Box2P m=-1 tes=4 lyr=0 vsb=1 wgt=0 clz=0 x1=-8 y1=-8 z1=0 x2=8 y2=8 z2=8");

      runScriptLine("Box2P m=-1 tes=3 lyr=0 vsb=1 wgt=0 clz=0 x1=-8 y1=-10 z1=4 x2=8 y2=-8 z2=8");

      runScriptLine("Box2P m=-1 tes=3 lyr=0 vsb=1 wgt=0 clz=0 x1=-10 y1=-8 z1=4 x2=-8 y2=8 z2=8");

      runScriptLine("Box2P m=-1 tes=3 lyr=0 vsb=1 wgt=0 clz=0 x1=8 y1=10 z1=4 x2=-8 y2=8 z2=8");

      runScriptLine("Box2P m=-1 tes=3 lyr=0 vsb=1 wgt=0 clz=0 x1=10 y1=8 z1=4 x2=8 y2=-8 z2=8");
    }

    if (n == 3) {
      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      runScriptLine("Mesh2 m=7 tes=5 lyr=0 vsb=1 wgt=0 clz=0 x1=-32 y1=-32 z1=0 x2=32 y2=32 z2=0");

      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      runScriptLine("Box2P m=-1 tes=4 lyr=0 vsb=1 wgt=0 clz=0 x1=-12 y1=-12 z1=0 x2=12 y2=12 z2=12");

      runScriptLine("Box2P m=-1 tes=2 lyr=0 vsb=1 wgt=0 clz=0 x1=-13 y1=-13 z1=11.8 x2=0 y2=0 z2=12");
      runScriptLine("Box2P m=-1 tes=2 lyr=0 vsb=1 wgt=0 clz=0 x1=-13 y1=-13 z1=8.8 x2=0 y2=0 z2=9");
      runScriptLine("Box2P m=-1 tes=2 lyr=0 vsb=1 wgt=0 clz=0 x1=-13 y1=-13 z1=7.3 x2=0 y2=0 z2=7.5");
      runScriptLine("Box2P m=-1 tes=2 lyr=0 vsb=1 wgt=0 clz=0 x1=-13 y1=-13 z1=6.55 x2=0 y2=0 z2=6.75");
      runScriptLine("Box2P m=-1 tes=2 lyr=0 vsb=1 wgt=0 clz=0 x1=-13 y1=-13 z1=5.8 x2=0 y2=0 z2=6");

      runScriptLine("Box2P m=-1 tes=2 lyr=0 vsb=1 wgt=0 clz=0 x1=13 y1=13 z1=11.8 x2=0 y2=0 z2=12");
      runScriptLine("Box2P m=-1 tes=2 lyr=0 vsb=1 wgt=0 clz=0 x1=13 y1=13 z1=8.8 x2=0 y2=0 z2=9");
      runScriptLine("Box2P m=-1 tes=2 lyr=0 vsb=1 wgt=0 clz=0 x1=13 y1=13 z1=7.3 x2=0 y2=0 z2=7.5");
      runScriptLine("Box2P m=-1 tes=2 lyr=0 vsb=1 wgt=0 clz=0 x1=13 y1=13 z1=6.55 x2=0 y2=0 z2=6.75");
      runScriptLine("Box2P m=-1 tes=2 lyr=0 vsb=1 wgt=0 clz=0 x1=13 y1=13 z1=5.8 x2=0 y2=0 z2=6");

      runScriptLine("Box2P m=-1 tes=2 lyr=0 vsb=1 wgt=0 clz=0 x1=0 y1=-18 z1=2.9 x2=18 y2=0 z2=3");
      runScriptLine("Box2P m=-1 tes=2 lyr=0 vsb=1 wgt=0 clz=0 x1=-18 y1=0 z1=2.9 x2=0 y2=18 z2=3");
    }

    if (n == 4) {
      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      runScriptLine("Mesh2 m=7 tes=5 lyr=0 vsb=1 wgt=0 clz=0 x1=-16 y1=-16 z1=0 x2=16 y2=16 z2=0");

      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      // House3/2's own rx/ry/rz (6,6,6 here) are House3/2's dx/dy/dz
      // halved - so dx=dy=dz=12; h2 (6) passes straight through as h.
      runScriptLine("House3 m=0 tes=0 lyr=0 vsb=1 wgt=0 clz=0 x=0 y=0 z=0 dx=12 dy=12 dz=12 h=6 r=0");
    }

    if (n == 5) {
      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      runScriptLine("Mesh2 m=7 tes=5 lyr=0 vsb=1 wgt=0 clz=0 x1=-16 y1=-16 z1=0 x2=16 y2=16 z2=0");

      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      runScriptLine("House2 m=0 tes=0 lyr=0 vsb=1 wgt=0 clz=0 x=0 y=0 z=0 dx=12 dy=12 dz=12 h=6 r=0");
    }

    if (n == 6) {
      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      runScriptLine("Mesh2 m=7 tes=6 lyr=0 vsb=1 wgt=0 clz=0 x1=-32 y1=-32 z1=0 x2=32 y2=32 z2=0");

      runScriptLine("BeginNewGroup x=0 y=-15 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      runScriptLine("Sphere m=7 tes=0 lyr=0 vsb=1 wgt=0 clz=0 x=0 y=-15 z=0 d=10 deg=4 r=-90");

      runScriptLine("BeginNewGroup x=0 y=15 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      runScriptLine("Sphere m=7 tes=0 lyr=0 vsb=1 wgt=0 clz=0 x=0 y=15 z=0 d=10 deg=4 r=-90");

      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      runScriptLine("House2 m=7 tes=2 lyr=0 vsb=1 wgt=0 clz=0 x=0 y=0 z=0 dx=12 dy=12 dz=12 h=6 r=0");
    }

    if (n == 7) {
      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      // Point list is bare "x,y" tokens (see __SECTION__'s own parser,
      // extraCommands.pde), not named p1x=/p1y=/... keys - those don't
      // match any of __SECTION__'s recognized keys and get silently
      // dropped, which previously left this section at its hardcoded
      // 20x20 fallback instead of this intended 64x64 square.
      runScriptLine("Section x=0 y=0 z=0.1 rx=0 resX=400 resY=400 -32,-32 32,-32 32,32 -32,32");

      {
        runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
        float x = 0;
        float y = 0;
        float z = 0;
        float r = 10;
        // t=90 here (unlike n==1/6's t=0 above) -> SPHERE's own
        // r=90-90=0.
        runScriptLine("Sphere m=1 tes=0 lyr=0 vsb=1 wgt=0 clz=0 x=" + x + " y=" + y + " z=" + z + " d=" + (2 * r) + " deg=5 r=0");
        // Solid's own sx/sy/sz are this r (the half-widths allSolids.create
        // itself calls sx/sy/sz), not its rx/ry/rz - same mapping as
        // mouseClicked.pde's own ObjectCategory.SOLID branch.
        runScriptLine("Solid x=" + x + " y=" + y + " z=" + z + " px=2 py=2 pz=2 sx=" + r + " sy=" + r + " sz=" + r + " rx=0 ry=0 rz=0 v=1");
      }

      {
        runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
        float x = -20;
        float y = -20;
        float z = 0;
        float r = 8;
        runScriptLine("Sphere m=2 tes=0 lyr=0 vsb=1 wgt=0 clz=0 x=" + x + " y=" + y + " z=" + z + " d=" + (2 * r) + " deg=4 r=0");
        runScriptLine("Solid x=" + x + " y=" + y + " z=" + z + " px=2 py=2 pz=2 sx=" + r + " sy=" + r + " sz=" + r + " rx=0 ry=0 rz=0 v=1");
      }

      {
        runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
        float x = 0;
        float y = 20;
        float z = 0;
        float r = 6;
        runScriptLine("Sphere m=3 tes=0 lyr=0 vsb=1 wgt=0 clz=0 x=" + x + " y=" + y + " z=" + z + " d=" + (2 * r) + " deg=3 r=0");
        runScriptLine("Solid x=" + x + " y=" + y + " z=" + z + " px=2 py=2 pz=2 sx=" + r + " sy=" + r + " sz=" + r + " rx=0 ry=0 rz=0 v=1");
      }
    }

    if (n == 8) {
      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      runScriptLine("Mesh2 m=7 tes=5 lyr=0 vsb=1 wgt=0 clz=0 x1=-32 y1=-32 z1=0 x2=32 y2=32 z2=0");

      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      // Parametric's own rx/ry/rz (20,20,20) are its dx/dy/dz halved -
      // so dx=dy=dz=40.
      runScriptLine("Parametric m=7 tes=0 lyr=0 vsb=1 wgt=0 clz=0 x=0 y=0 z=0 dx=40 dy=40 dz=40 n=1 r=0");
    }

    if (n == 9) {
      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      runScriptLine("Mesh2 m=7 tes=0 lyr=0 vsb=1 wgt=0 clz=0 x1=-32 y1=-32 z1=0 x2=32 y2=32 z2=0");

      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      // PolygonHyper's own "r" (10 here) is its d/2 - so d=20; h (10)
      // passes straight through.
      runScriptLine("PolygonHyper m=0 tes=0 lyr=0 vsb=1 wgt=0 clz=0 x=0 y=0 z=5 d=20 h=10 deg=4 r=0");
    }

    if (n == 10) {
      //Complex used in the YC book:

      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      runScriptLine("Mesh2 m=8 tes=6 lyr=0 vsb=1 wgt=0 clz=0 x1=-96 y1=-96 z1=0 x2=96 y2=96 z2=0");

      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      // Same m=-1/tes=2/lyr=0/vsb=1/wgt=0/clz=0 prefix for all of these,
      // held once rather than repeated 34 times.
      String boxArgs = "Box2P m=-1 tes=2 lyr=0 vsb=1 wgt=0 clz=0 ";
      runScriptLine(boxArgs + "x1=-78 y1=-78 z1=0 x2=-66 y2=-42 z2=12");
      runScriptLine(boxArgs + "x1=-78 y1=-78 z1=12 x2=-66 y2=-66 z2=24");
      runScriptLine(boxArgs + "x1=-78 y1=-54 z1=12 x2=-66 y2=-42 z2=24");
      runScriptLine(boxArgs + "x1=-78 y1=-78 z1=24 x2=-66 y2=-42 z2=36");
      runScriptLine(boxArgs + "x1=-54 y1=-78 z1=0 x2=-6 y2=-30 z2=6");
      runScriptLine(boxArgs + "x1=6 y1=-78 z1=0 x2=30 y2=-54 z2=24");
      runScriptLine(boxArgs + "x1=6 y1=-42 z1=0 x2=30 y2=-30 z2=48");
      runScriptLine(boxArgs + "x1=42 y1=-78 z1=0 x2=78 y2=-66 z2=12");
      runScriptLine(boxArgs + "x1=42 y1=-66 z1=0 x2=48 y2=-42 z2=12");
      runScriptLine(boxArgs + "x1=72 y1=-66 z1=0 x2=78 y2=-42 z2=12");
      runScriptLine(boxArgs + "x1=42 y1=-42 z1=0 x2=78 y2=-30 z2=12");
      runScriptLine(boxArgs + "x1=-78 y1=-30 z1=0 x2=-66 y2=18 z2=24");
      runScriptLine(boxArgs + "x1=-54 y1=-18 z1=0 x2=-30 y2=-12 z2=24");
      runScriptLine(boxArgs + "x1=-54 y1=-12 z1=0 x2=-48 y2=12 z2=24");
      runScriptLine(boxArgs + "x1=-36 y1=-12 z1=0 x2=-30 y2=12 z2=24");
      runScriptLine(boxArgs + "x1=-54 y1=12 z1=0 x2=-30 y2=18 z2=24");
      runScriptLine(boxArgs + "x1=-18 y1=-18 z1=0 x2=18 y2=18 z2=12");
      runScriptLine(boxArgs + "x1=30 y1=-18 z1=0 x2=54 y2=30 z2=12");
      runScriptLine(boxArgs + "x1=66 y1=-18 z1=0 x2=78 y2=6 z2=48");
      runScriptLine(boxArgs + "x1=66 y1=18 z1=0 x2=78 y2=30 z2=96");
      runScriptLine(boxArgs + "x1=-78 y1=30 z1=0 x2=-30 y2=54 z2=12");
      runScriptLine(boxArgs + "x1=-18 y1=30 z1=0 x2=-12 y2=54 z2=24");
      runScriptLine(boxArgs + "x1=-12 y1=30 z1=0 x2=12 y2=36 z2=24");
      runScriptLine(boxArgs + "x1=-12 y1=48 z1=0 x2=12 y2=54 z2=24");
      runScriptLine(boxArgs + "x1=12 y1=30 z1=0 x2=18 y2=54 z2=24");
      runScriptLine(boxArgs + "x1=-78 y1=66 z1=0 x2=-42 y2=78 z2=12");
      runScriptLine(boxArgs + "x1=-78 y1=66 z1=12 x2=-66 y2=78 z2=24");
      runScriptLine(boxArgs + "x1=-54 y1=66 z1=12 x2=-42 y2=78 z2=24");
      runScriptLine(boxArgs + "x1=-78 y1=66 z1=24 x2=-42 y2=78 z2=36");
      runScriptLine(boxArgs + "x1=-30 y1=66 z1=0 x2=18 y2=78 z2=24");
      runScriptLine(boxArgs + "x1=30 y1=42 z1=0 x2=42 y2=78 z2=12");
      runScriptLine(boxArgs + "x1=42 y1=42 z1=0 x2=66 y2=48 z2=12");
      runScriptLine(boxArgs + "x1=42 y1=72 z1=0 x2=66 y2=78 z2=12");
      runScriptLine(boxArgs + "x1=66 y1=42 z1=0 x2=78 y2=78 z2=12");
    }

    if (n == 11) {
      runScriptLine("BeginNewGroup x=0 y=0 z=0 sx=1 sy=1 sz=1 rx=0 ry=0 rz=0");
      // Same fix as n==7's Section line above - bare "x,y" point
      // tokens, not named p1x=/p1y=/... keys.
      runScriptLine("Section x=0 y=0 z=0.1 rx=0 resX=200 resY=200 -25,-25 25,-25 25,25 -25,25");
    }


    Select3D.deselectAll();

    endScene3DChange();
  }
}
