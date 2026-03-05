class solarchvision_Model1Ds {

  private final static String CLASS_STAMP = "Model1Ds";

  solarchvision_Model1Ds () { // constructor
    makeEmpty(0);
  }

  int elementSegments = 5; // number of polygons to create each cone

  boolean displayAll = true;
  boolean displayLeaves = true;

  int num;
  float[][] f_data;
  int[][]   i_data;


  void makeEmpty (int n) {

    this.num = n;
    this.f_data = new float [n][11];
    this.i_data = new int   [n][3];

    if (allGroups != null) {
      for (int q = 0; q < allGroups.num; q++) {
        allGroups.Model1Ds[q][0] = 0;
        allGroups.Model1Ds[q][1] = -1;
      }
    }

    if (Select3D != null) {
      Select3D.deselect_Groups();
      Select3D.deselect_Model1Ds();
    }

    SOLARCHVISION_model_changed();
  }


  void create (int type, int seed, int degreeMax, float x, float y, float z, float s, float rot, float tilt, float twist, float ratio, float base, float trunkSize, float leafSize) {

    int[][] new_i_data = {
      {
        type, seed, degreeMax
      }
    };
    this.i_data = (int[][]) concat(this.i_data, new_i_data);

    float[][] new_f_data = {
      {
        x, y, z, s, rot, tilt, twist, ratio, base, trunkSize, leafSize
      }
    };
    this.f_data = (float[][]) concat(this.f_data, new_f_data);

    this.num += 1;

    if (User3D.create_MeshOrSolid != 0) {

      randomSeed(seed); // ??

//this.branch_add_allSolids();
    }


    if (allGroups.num > 0) allGroups.Model1Ds[allGroups.num - 1][1] = this.num - 1;

  }


  float getX (int n) {
    return this.f_data[n][0];
  }

  float getY (int n) {
    return this.f_data[n][1];
  }

  float getZ (int n) {
    return this.f_data[n][2];
  }

  float getScale (int n) {
    return this.f_data[n][3];
  }

  float getRotation (int n) {
    return this.f_data[n][4];
  }

  float getBranchTilt (int n) {
    return this.f_data[n][5];
  }

  float getBranchTwist (int n) {
    return this.f_data[n][6];
  }

  float getBranchRatio (int n) {
    return this.f_data[n][7];
  }

  float getTreeBase (int n) {
    return this.f_data[n][8];
  }

  float getTrunkSize (int n) {
    return this.f_data[n][9];
  }

  float getLeafSize (int n) {
    return this.f_data[n][10];
  }

  void setX (int n, float f) {
    this.f_data[n][0] = f;
  }

  void setY (int n, float f) {
    this.f_data[n][1] = f;
  }

  void setZ (int n, float f) {
    this.f_data[n][2] = f;
  }

  void setScale (int n, float f) {
    this.f_data[n][3] = f;
  }

  void setRotation (int n, float f) {
    this.f_data[n][4] = f;
  }

  void setBranchTilt (int n, float f) {
    this.f_data[n][5] = f;
  }

  void setBranchTwist (int n, float f) {
    this.f_data[n][6] = f;
  }

  void setBranchRatio (int n, float f) {
    this.f_data[n][7] = f;
  }

  void setTreeBase (int n, float f) {
    this.f_data[n][8] = f;
  }

  void setTrunkSize (int n, float f) {
    this.f_data[n][9] = f;
  }

  void setLeafSize (int n, float f) {
    this.f_data[n][10] = f;
  }


  void move (int n, float dx, float dy, float dz) {
    this.f_data[n][0] += dx;
    this.f_data[n][1] += dy;
    this.f_data[n][2] += dz;
  }

  void magS (int n, float f) {
    this.f_data[n][3] *= f;
  }


  int getType (int n) {
    return this.i_data[n][0];
  }

  int getSeed (int n) {
    return this.i_data[n][1];
  }

  int getDegreeMax (int n) {
    return this.i_data[n][2];
  }



  void setType (int n, int t) {
    this.i_data[n][0] = t;
  }

  void setSeed (int n, int t) {
    this.i_data[n][1] = t;
  }

  void setDegreeMax (int n, int t) {
    this.i_data[n][2] = t;
  }












  int nStart;
  float branchTilt;
  float branchTwist;
  float branchRatio;
  float treeBase;
  float leafSize;

  float[][] Vertices;
  int[][] Faces;

  int tree_id = -1; // internal
  int _turn = -1; // internal
  int target_window; // internal

  void draw (int tar_win) {

    target_window = tar_win;

    this.Faces = new int [this.num][4];
    this.Vertices = new float [4 * this.num][3];

    boolean proceed = true;

    if (this.displayAll == false) {
      proceed = false;
    }

    if ((target_window == TypeWindow.STUDY) ||
        (target_window == TypeWindow.WORLD)) {

      proceed = false;
    }


    if (proceed) {

      if (target_window == TypeWindow.OBJ3D) {
        if (User3D.export_MaterialLibrary) {

          if (this.num != 0) {

            mtlOutput.println("newmtl " + "Tree3D_Trunk");
            mtlOutput.println("\tilum 2"); // 0:Color on and Ambient off, 1:Color on and Ambient on, 2:Highlight on, etc.
            mtlOutput.println("\tKa 1.000 0.750 0.500"); // ambient
            mtlOutput.println("\tKd 1.000 0.750 0.500"); // diffuse
            mtlOutput.println("\tKs 0.000 0.000 0.000"); // specular
            mtlOutput.println("\tNs 10.00"); // 0-1000 specular exponent
            mtlOutput.println("\tNi 1.500"); // 0.001-10 (glass:1.5) optical_density (index of refraction)

            mtlOutput.println("\td 1.000"); //  0-1 transparency  d = Tr, or maybe d = 1 - Tr
            mtlOutput.println("\tTr 1.000"); //  0-1 transparency
            mtlOutput.println("\tTf 1.000 1.000 1.000"); //  transmission filter


            mtlOutput.println("newmtl " + "Tee3D_Leaf");
            mtlOutput.println("\tilum 2"); // 0:Color on and Ambient off, 1:Color on and Ambient on, 2:Highlight on, etc.
            mtlOutput.println("\tKa 0.500 0.750 0.250"); // ambient
            mtlOutput.println("\tKd 0.500 0.750 0.250"); // diffuse
            mtlOutput.println("\tKs 0.000 0.000 0.000"); // specular
            mtlOutput.println("\tNs 10.00"); // 0-1000 specular exponent
            mtlOutput.println("\tNi 1.500"); // 0.001-10 (glass:1.5) optical_density (index of refraction)

            mtlOutput.println("\td 1.000"); //  0-1 transparency  d = Tr, or maybe d = 1 - Tr
            mtlOutput.println("\tTr 1.000"); //  0-1 transparency
            mtlOutput.println("\tTf 1.000 1.000 1.000"); //  transmission filter
          }
        }
      }



      for (int f = 0; f < this.num; f++) {

        tree_id = f;

        float x = this.getX(f);
        float y = this.getY(f);
        float z = this.getZ(f);

        float rad = this.getScale(f) * 0.25;
        float rot = this.getRotation(f);

        int n = this.getType(f);

        int seed = this.getSeed(f);

        float trunkSize = this.getTrunkSize(f);

        leafSize = this.getLeafSize(f);

        branchTilt = this.getBranchTilt(f);
        branchTwist = this.getBranchTwist(f);
        branchRatio = this.getBranchRatio(f);
        treeBase = this.getTreeBase(f);

        nStart = this.getDegreeMax(f);


        if (n == 0) {

          if (target_window == TypeWindow.OBJ3D) {

            num_vertices_added = 0;

            if (User3D.export_PolyToPoly == 1) {
              obj_lastGroupNumber += 1;
              objOutput.println("g Model1Ds_" + nf(f, 0));
            }
          }


          int end_turn = 1;
          if (target_window == TypeWindow.OBJ3D) end_turn = 3;

          for (_turn = 1; _turn <= end_turn; _turn++) {

            WIN3D.graphics.pushMatrix();

            WIN3D.graphics.scale(OBJECTS_scale * WIN3D.scale);
            WIN3D.graphics.translate(x, -y, z);
            WIN3D.graphics.rotateZ(rot);

            float treeHeight0 = rad;
            float treeWidth0 = rad * trunkSize * 0.15;

            randomSeed(seed);

            // Call to draw the tree
            this.makeBranch(treeWidth0, treeHeight0, nStart);

            WIN3D.graphics.popMatrix();





            // ----------------
            x *= OBJECTS_scale;
            y *= OBJECTS_scale;
            z *= OBJECTS_scale;
            rad *= OBJECTS_scale;
            // ----------------

            float t = PI + WIN3D.rotation_Z * PI / 180.0;
            if (WIN3D.ViewType == 1) t = atan2(y - WIN3D.CAM_y, x - WIN3D.CAM_x) + 0.5 * PI;


            this.Vertices[f * 4 + 0][0] = (x - rad * cos(t)) / OBJECTS_scale;
            this.Vertices[f * 4 + 0][1] = (y - rad * sin(t)) / OBJECTS_scale;
            this.Vertices[f * 4 + 0][2] = (z) / OBJECTS_scale;

            this.Vertices[f * 4 + 1][0] = (x + rad * cos(t)) / OBJECTS_scale;
            this.Vertices[f * 4 + 1][1] = (y + rad * sin(t)) / OBJECTS_scale;
            this.Vertices[f * 4 + 1][2] = (z) / OBJECTS_scale;

            this.Vertices[f * 4 + 2][0] = (x + rad * cos(t)) / OBJECTS_scale;
            this.Vertices[f * 4 + 2][1] = (y + rad * sin(t)) / OBJECTS_scale;
            this.Vertices[f * 4 + 2][2] = (z + 2 * rad) / OBJECTS_scale;

            this.Vertices[f * 4 + 3][0] = (x - rad * cos(t)) / OBJECTS_scale;
            this.Vertices[f * 4 + 3][1] = (y - rad * sin(t)) / OBJECTS_scale;
            this.Vertices[f * 4 + 3][2] = (z + 2 * rad) / OBJECTS_scale;

            this.Faces[f][0] = f * 4 + 0;
            this.Faces[f][1] = f * 4 + 1;
            this.Faces[f][2] = f * 4 + 2;
            this.Faces[f][3] = f * 4 + 3;

          }


          if (target_window == TypeWindow.OBJ3D) {
            obj_lastVertexNumber += num_vertices_added;
            obj_lastVtextureNumber += num_vertices_added;
          }


        }
      }
    }
  }


  void makeBranch(float w, float h, int n) {

    // Note: this is a recursive function.

    if (n > 0) {

      WIN3D.graphics.pushMatrix();
      this.twistBranch(this.branchTwist);
      if ((n == this.nStart) && (this.treeBase > 0.0)) {
        this.drawElement(w, h * this.treeBase, n);
      }
      this.makeBranch(w * this.branchRatio, h * this.branchRatio, n - 1);
      WIN3D.graphics.popMatrix();

      if (n != this.nStart) {
        WIN3D.graphics.pushMatrix();
        this.twistBranch(this.branchTwist);
        this.tiltBranch(this.branchTilt);
        this.drawElement(w, h, n);
        this.makeBranch(w * this.branchRatio, h * this.branchRatio, n - 1);
        WIN3D.graphics.popMatrix();
      }

    }
  }




  void twistBranch (float angle) {

    WIN3D.graphics.rotateZ(angle * PI / 180.0);
  }


  void tiltBranch (float angle) {

    WIN3D.graphics.rotateY(angle * PI / 180.0);
  }


  void drawElement(float w, float h, int n) {

    WIN3D.graphics.pushMatrix();
    WIN3D.graphics.translate(0, 0, 0.5 * h);

    this.drawTrunk(w, h);

    WIN3D.graphics.popMatrix();

    WIN3D.graphics.translate(0, 0, h);

    if (n == 1) {
      this.drawLeaf();
    }
  }


  float[][][] leaf_faces = {{{-1,-1,-1}, { 1,-1,-1}, { 1, 1,-1}, {-1, 1,-1}},
                            {{-1,-1, 1}, { 1,-1, 1}, { 1, 1, 1}, {-1, 1, 1}},
                            {{-1,-1,-1}, { 1,-1,-1}, { 1,-1, 1}, {-1,-1, 1}},
                            {{ 1,-1,-1}, { 1, 1,-1}, { 1, 1, 1}, {-1, 1, 1}},
                            {{-1,-1,-1}, {-1, 1,-1}, {-1, 1, 1}, {-1,-1, 1}},
                            {{ 1,-1,-1}, { 1, 1,-1}, { 1, 1, 1}, { 1,-1, 1}}};

  int num_leaf_faces = leaf_faces.length;

  float[][] local_vertices = new float[4][3];

  void drawLeaf() {

    if (leafSize > 0) {

      WIN3D.graphics.fill(63, 127, 0);
      WIN3D.graphics.noStroke();

      for (int i = 0; i < num_leaf_faces; i++) {

        for (int j = 0; j < 4; j++) {

          this.local_vertices[j][0] = this.leaf_faces[i][j][0] * leafSize;
          this.local_vertices[j][1] = this.leaf_faces[i][j][1] * leafSize;
          this.local_vertices[j][2] = this.leaf_faces[i][j][2] * leafSize;
        }

        this.drawLocalFace("Leaf");
      }
    }
  }


  void drawTrunk(float w, float h) {

    WIN3D.graphics.fill(127, 63, 0);
    WIN3D.graphics.noStroke();

    for (int i = 0; i < this.elementSegments; i++) {

      for (int j = 0; j < 4; j++) {

        float u = 0;
        if ((j == 1) || (j == 2)) u = 1;

        float v = 0;
        if ((j == 2) || (j == 3)) v = 1;

        float T = w;
        if ((j == 2) || (j == 3)) T *= this.branchRatio; // for conic trunks

        this.local_vertices[j][0] = T * cos((i + u) * TWO_PI / float(this.elementSegments));
        this.local_vertices[j][1] = T * sin((i + u) * TWO_PI / float(this.elementSegments));
        this.local_vertices[j][2] = h * (v - 0.5);
      }

      this.drawLocalFace("Trunk");
    }
  }


  void drawLocalFace(String whichPart) {

    float[][] subFace = new float[this.local_vertices.length][3];

    if (target_window == TypeWindow.WIN3D) {
      WIN3D.graphics.beginShape();
    }

    for (int j = 0; j < this.local_vertices.length; j++) {

      float u = 0;
      if ((j == 1) || (j == 2)) u = 1;

      float v = 0;
      if ((j == 2) || (j == 3)) v = 1;

      float x = this.local_vertices[j][0];
      float y = this.local_vertices[j][1];
      float z = this.local_vertices[j][2];

      if (target_window == TypeWindow.WIN3D) {
        WIN3D.graphics.vertex(x, -y, z);
      }


      if (target_window == TypeWindow.SHADOW) {
        subFace[j][0] =  WIN3D.graphics.modelX(x,y,z) / (OBJECTS_scale * WIN3D.scale);
        subFace[j][1] = -WIN3D.graphics.modelY(x,y,z) / (OBJECTS_scale * WIN3D.scale);
        subFace[j][2] =  WIN3D.graphics.modelZ(x,y,z) / (OBJECTS_scale * WIN3D.scale);
      }

      if (target_window == TypeWindow.OBJ3D) {

        if (_turn == 1) {

          SOLARCHVISION_OBJprintVertex(WIN3D.graphics.modelX(x,y,z) / (OBJECTS_scale * WIN3D.scale),
                                      -WIN3D.graphics.modelY(x,y,z) / (OBJECTS_scale * WIN3D.scale),
                                       WIN3D.graphics.modelZ(x,y,z) / (OBJECTS_scale * WIN3D.scale));

        }

        if (_turn == 2) {

          SOLARCHVISION_OBJprintVtexture(u, v, 0);
        }

      }
    }

    if (target_window == TypeWindow.OBJ3D) {
      if (_turn == 3) {

        num_vertices_added += 4;

        String n1_txt = nf(obj_lastVertexNumber + num_vertices_added - 3, 0);
        String n2_txt = nf(obj_lastVertexNumber + num_vertices_added - 2, 0);
        String n3_txt = nf(obj_lastVertexNumber + num_vertices_added - 1, 0);
        String n4_txt = nf(obj_lastVertexNumber + num_vertices_added - 0, 0);

        String m1_txt = nf(obj_lastVtextureNumber + num_vertices_added - 3, 0);
        String m2_txt = nf(obj_lastVtextureNumber + num_vertices_added - 2, 0);
        String m3_txt = nf(obj_lastVtextureNumber + num_vertices_added - 1, 0);
        String m4_txt = nf(obj_lastVtextureNumber + num_vertices_added - 0, 0);

        if (User3D.export_PolyToPoly == 0) {
          obj_lastGroupNumber += 1;
          objOutput.println("g Tree3D_" + whichPart + "_" + nf(tree_id, 0));
        }

        if (User3D.export_MaterialLibrary) {
          objOutput.println("usemtl Tree3D_" + whichPart);
        }

        obj_lastFaceNumber += 1;
        objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n2_txt + "/" + m2_txt + " " + n3_txt + "/" + m3_txt + " " + n4_txt + "/" + m4_txt);

      }

    }




    if (target_window == TypeWindow.SHADOW) {

      float[][] subFace_Rotated = subFace;

      for (int s = 0; s < subFace_Rotated.length; s++) {
        if (allSolarImpacts.sectionType == 2) {
          float a = subFace_Rotated[s][0];
          float b = -subFace_Rotated[s][1];
          float c = subFace_Rotated[s][2];

          subFace_Rotated[s][0] = a * funcs.cos_ang(-allSolarImpacts.R) - b * funcs.sin_ang(-allSolarImpacts.R);
          subFace_Rotated[s][1] = c;
          subFace_Rotated[s][2] = a * funcs.sin_ang(-allSolarImpacts.R) + b * funcs.cos_ang(-allSolarImpacts.R);
        } else if (allSolarImpacts.sectionType == 3) {
        }
      }

      SHADOW_graphics.beginShape();

      for (int s = 0; s < subFace_Rotated.length; s++) {

        float z = subFace_Rotated[s][2] - allSolarImpacts.Z;
        float x = subFace_Rotated[s][0] - z * SunR_Rotated[1] / SunR_Rotated[3];
        float y = subFace_Rotated[s][1] - z * SunR_Rotated[2] / SunR_Rotated[3];

        if (z >= 0) {

          if (allSolarImpacts.sectionType == 1) {
            float px = x;
            float py = y;

            x = px * funcs.cos_ang(-allSolarImpacts.R) - py * funcs.sin_ang(-allSolarImpacts.R);
            y = px * funcs.sin_ang(-allSolarImpacts.R) + py * funcs.cos_ang(-allSolarImpacts.R);
          }

          SHADOW_graphics.vertex((x - Shades_offsetX) * Shades_scaleX, -(y - Shades_offsetY) * Shades_scaleY);
        } else {
          int s_next = (s + 1) % subFace_Rotated.length;
          int s_prev = (s + subFace_Rotated.length - 1) % subFace_Rotated.length;

          float z_prev = subFace_Rotated[s_prev][2] - allSolarImpacts.Z;
          float x_prev = subFace_Rotated[s_prev][0] - z_prev * SunR_Rotated[1] / SunR_Rotated[3];
          float y_prev = subFace_Rotated[s_prev][1] - z_prev * SunR_Rotated[2] / SunR_Rotated[3];

          if (z_prev > 0) {
            float ratio = z_prev / (z_prev - z);

            float x_trim = x_prev * (1 - ratio) + x * ratio;
            float y_trim = y_prev * (1 - ratio) + y * ratio;

            if (allSolarImpacts.sectionType == 1) {
              float px = x_trim;
              float py = y_trim;

              x_trim = px * funcs.cos_ang(-allSolarImpacts.R) - py * funcs.sin_ang(-allSolarImpacts.R);
              y_trim = px * funcs.sin_ang(-allSolarImpacts.R) + py * funcs.cos_ang(-allSolarImpacts.R);
            }

            SHADOW_graphics.vertex((x_trim - Shades_offsetX) * Shades_scaleX, -(y_trim - Shades_offsetY) * Shades_scaleY);
          }

          float z_next = subFace_Rotated[s_next][2] - allSolarImpacts.Z;
          float x_next = subFace_Rotated[s_next][0] - z_next * SunR_Rotated[1] / SunR_Rotated[3];
          float y_next = subFace_Rotated[s_next][1] - z_next * SunR_Rotated[2] / SunR_Rotated[3];

          if (z_next > 0) {
            float ratio = z_next / (z_next - z);

            float x_trim = x_next * (1 - ratio) + x * ratio;
            float y_trim = y_next * (1 - ratio) + y * ratio;

            if (allSolarImpacts.sectionType == 1) {
              float px = x_trim;
              float py = y_trim;

              x_trim = px * funcs.cos_ang(-allSolarImpacts.R) - py * funcs.sin_ang(-allSolarImpacts.R);
              y_trim = px * funcs.sin_ang(-allSolarImpacts.R) + py * funcs.cos_ang(-allSolarImpacts.R);
            }

            SHADOW_graphics.vertex((x_trim - Shades_offsetX) * Shades_scaleX, -(y_trim - Shades_offsetY) * Shades_scaleY);
          }
        }
      }

      SHADOW_graphics.endShape(CLOSE);
    }




    if (target_window == TypeWindow.WIN3D) {
      WIN3D.graphics.endShape(CLOSE);
    }
  }






  float[] intersect (float[] ray_pnt, float[] ray_dir) {

    float[] ray_normal = funcs.vec3_unit(ray_dir);

    float[][] hitPoint = new float [this.Faces.length][4];

    for (int f = 0; f < this.Faces.length; f++) {
      hitPoint[f][0] = FLOAT_undefined;
      hitPoint[f][1] = FLOAT_undefined;
      hitPoint[f][2] = FLOAT_undefined;
      hitPoint[f][3] = FLOAT_undefined;
    }

    for (int f = 0; f < this.Faces.length; f++) {

      int n = this.Faces[f].length;

      float X_intersect = FLOAT_undefined;
      float Y_intersect = FLOAT_undefined;
      float Z_intersect = FLOAT_undefined;
      float dist2intersect = FLOAT_undefined;

      boolean InPoly = false;

      float[] A = this.Vertices[this.Faces[f][0]];
      float[] B = this.Vertices[this.Faces[f][1]];
      float[] C = this.Vertices[this.Faces[f][n - 2]];
      float[] D = this.Vertices[this.Faces[f][n - 1]];

      float[] AC = funcs.vec3_diff(A, C);
      float[] BD = funcs.vec3_diff(B, D);

      float[] face_norm = funcs.vec3_cross(AC, BD);

      float face_offset = 0.25 * ((A[0] + B[0] + C[0] + D[0]) * face_norm[0] + (A[1] + B[1] + C[1] + D[1]) * face_norm[1] + (A[2] + B[2] + C[2] + D[2]) * face_norm[2]);

      float R = -funcs.vec3_dot(ray_dir, face_norm);

      if ((R < FLOAT_tiny) && (R > -FLOAT_tiny)) { // the ray is parallel to the plane
        dist2intersect = FLOAT_huge;
      }
      else {
        dist2intersect = (funcs.vec3_dot(ray_pnt, face_norm) - face_offset) / R;

        //if (dist2intersect > 0) {
        if (dist2intersect > FLOAT_tiny) {

          X_intersect = dist2intersect * ray_dir[0] + ray_pnt[0];
          Y_intersect = dist2intersect * ray_dir[1] + ray_pnt[1];
          Z_intersect = dist2intersect * ray_dir[2] + ray_pnt[2];

          float[] P = {X_intersect, Y_intersect, Z_intersect};

          InPoly = funcs.isInside_Rectangle(P, A, B, C);
        }
      }

      if (InPoly) {
        hitPoint[f][0] = X_intersect;
        hitPoint[f][1] = Y_intersect;
        hitPoint[f][2] = Z_intersect;
        hitPoint[f][3] = dist2intersect;
      }

    }

    float[] return_point = {-1, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined};

    float pre_dist = FLOAT_undefined;

    for (int f = 0; f < this.Faces.length; f++) {

      if (pre_dist > hitPoint[f][3]) {

        pre_dist = hitPoint[f][3];

        return_point[0] = f;
        return_point[1] = hitPoint[f][0];
        return_point[2] = hitPoint[f][1];
        return_point[3] = hitPoint[f][2];
        return_point[4] = hitPoint[f][3];
      }

    }

    return return_point;
  }











  public void to_XML (XML xml) {

    println("Saving:" + this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    int ni = this.num;
    XML_setInt(parent, "ni", ni);
    for (int i = 0; i < ni; i++) {
      XML child = parent.addChild("item");
      XML_setInt(child, "id", i);

      XML_setInt(child, "type", getType(i));
      XML_setInt(child, "seed", getSeed(i));
      XML_setInt(child, "degreeMax", getDegreeMax(i));


      String txt = "";
      txt += nf(this.getX(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.getY(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.getZ(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.getScale(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.getRotation(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.getBranchTilt(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.getBranchTwist(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.getBranchRatio(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.getTreeBase(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.getTrunkSize(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.getLeafSize(i), 0, 4).replace(",", "."); // <<<<

      XML_setContent(child, txt);
    }

    XML_setBoolean(parent, "displayAll", this.displayAll);
    XML_setBoolean(parent, "displayLeaves", this.displayLeaves);
  }

  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);

    int ni = XML_getInt(parent, "ni");

    this.makeEmpty(ni);

    XML[] children = parent.getChildren("item");
    for (int i = 0; i < ni; i++) {

      this.setType(i, children[i].getInt("type"));
      this.setSeed(i, children[i].getInt("seed"));
      this.setDegreeMax(i, children[i].getInt("degreeMax"));

      String txt = XML_getContent(children[i]);
      String[] parts = split(txt, ",");

      this.setX(i, float(parts[0]));
      this.setY(i, float(parts[1]));
      this.setZ(i, float(parts[2]));
      this.setScale(i, float(parts[3]));
      this.setRotation(i, float(parts[4]));
      this.setBranchTilt(i, float(parts[5]));
      this.setBranchTwist(i, float(parts[6]));
      this.setBranchRatio(i, float(parts[7]));
      this.setTreeBase(i, float(parts[8]));
      this.setTrunkSize(i, float(parts[9]));
      this.setLeafSize(i, float(parts[10]));

    }

    this.displayAll = XML_getBoolean(parent, "displayAll");
    this.displayLeaves = XML_getBoolean(parent, "displayLeaves");
  }

}
