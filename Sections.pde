class solarchvision_Sections {

  private final static String CLASS_STAMP = "Sections";

  solarchvision_Sections () { // constructor
    makeEmpty(0);
  }

  boolean displayAll = true;

  int num;
  float[][] f_data = new float[0][6];
  int  [][] i_data = new int  [0][3];

  void makeEmpty (int n) {
    this.f_data = new float [n][6];
    this.i_data = new int   [n][3];

    this.SolidImpact = new PImage [n];

    this.SolarImpact = new PImage [n][(1 + STUDY.j_End - STUDY.j_Start)][numberOfImpactVariations];

    this.num = n;

    if (Select3D != null) {
      Select3D.deselect_Sections();
    }

    SOLARCHVISION_model_changed();
  }


  void create (float x, float y, float z, float r, float u, float v, int t, int RES1, int RES2) {

    int[][] Temp_i_data = {
      {
        t, RES1, RES2
      }
    };
    this.i_data = (int[][]) concat(this.i_data, Temp_i_data);

    float[][] Temp_f_data = {
      {
        x, y, z, r, u, v
      }
    };
    this.f_data = (float[][]) concat(this.f_data, Temp_f_data);

    PImage[] Temp_SolidImpact = {
      createImage(RES1, RES2, RGB)
    };
    this.SolidImpact = (PImage[]) concat(this.SolidImpact, Temp_SolidImpact);

    PImage[][][] Temp_SolarImpact = new PImage [1][(1 + STUDY.j_End - STUDY.j_Start)][numberOfImpactVariations];
    {
      int i = 0;
      for (int j = STUDY.j_Start; j <= STUDY.j_End; j++) {
        for (int q = 0; q < numberOfImpactVariations; q++) {
          Temp_SolarImpact[i][j][q] = createImage(2, 2, RGB); // empty and small
        }
      }
    }
    this.SolarImpact = (PImage[][][]) concat(this.SolarImpact, Temp_SolarImpact);

    this.num += 1;
  }




  int get_type (int n) { // Type
    return this.i_data[n][0];
  }

  int get_res1 (int n) { // RES1
    return this.i_data[n][1];
  }

  int get_res2 (int n) { // RES1
    return this.i_data[n][2];
  }

  void set_type (int n, int t) {
    this.i_data[n][0] = t;
  }

  void set_res1 (int n, int t) {
    this.i_data[n][1] = t;
  }

  void set_res2 (int n, int t) {
    this.i_data[n][2] = t;
  }



  float getX (int n) { // offsetX
    return this.f_data[n][0];
  }

  float getY (int n) { // offsetY
    return this.f_data[n][1];
  }

  float getZ (int n) { // elevation
    return this.f_data[n][2];
  }

  float getR (int n) { // rotation
    return this.f_data[n][3];
  }

  float getU (int n) { // scaleU
    return this.f_data[n][4];
  }

  float getV (int n) { //scaleV
    return this.f_data[n][5];
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

  void setR (int n, float f) {
    this.f_data[n][3] = f;
  }

  void setU (int n, float f) {
    this.f_data[n][4] = f;
  }

  void setV (int n, float f) {
    this.f_data[n][5] = f;
  }

  void move (int n, float dx, float dy, float dz) {
    this.f_data[n][0] += dx;
    this.f_data[n][1] += dy;
    this.f_data[n][2] += dz;
  }



  PImage[] SolidImpact = new PImage[0];
  PImage[][][] SolarImpact = new PImage [0][(1 + STUDY.j_End - STUDY.j_Start)][numberOfImpactVariations];

  void resize_solarImpact_array () { // called when STUDY.j_End changes

    allSections.SolarImpact = new PImage [allSections.num][(1 + STUDY.j_End - STUDY.j_Start)][numberOfImpactVariations];
    {
      for (int i = 0; i < allSections.num; i++) {
        for (int j = STUDY.j_Start; j <= STUDY.j_End; j++) {
          for (int q = 0; q < numberOfImpactVariations; q++) {
            allSections.SolarImpact[i][j][q] = createImage(2, 2, RGB); // empty and small
          }
        }
      }
    }

  }









  private float[][] Vertices;
  private int[][] Faces;




  void draw (int target_window) {

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

      for (int f = 0; f < this.num; f++) {

        float Section_X = this.getX(f);
        float Section_Y = this.getY(f);
        float Section_Z = this.getZ(f);
        float Section_R = this.getR(f);
        float Section_U = this.getU(f);
        float Section_V = this.getV(f);

        int Section_Type = this.get_type(f);
        int Section_RES1 = this.get_res1(f);
        int Section_RES2 = this.get_res2(f);

        if (Section_Type != 0) {

          String the_filename = "Impact_" + nf(f, 0) + ".bmp";

          if (User3D.export_MaterialLibrary) {

            String TEXTURE_path = Folder_Export3D + "/" + Subfolder_exportMaps + the_filename;

            if ((target_window == TypeWindow.HTML) ||
                (target_window == TypeWindow.OBJ3D)) {

              if (allSolarImpacts.displayImage) {
                println("Saving texture:", TEXTURE_path);
                this.SolarImpact[f][IMPACTS_displayDay][WIN3D.Impact_TYPE].save(TEXTURE_path);
              } else if (allSolidImpacts.displayImage) {
                println("Saving texture:", TEXTURE_path);
                this.SolidImpact[f].save(TEXTURE_path);
              }

              if (target_window == TypeWindow.HTML) {
                htmlOutput.println("\t\t\t\t<Appearance DEF='" + the_filename + "'>");
                htmlOutput.println("\t\t\t\t\t<ImageTexture url='"+ Subfolder_exportMaps + the_filename + "'><ImageTexture/>");
                htmlOutput.println("\t\t\t\t</Appearance>");
              }

              if (target_window == TypeWindow.OBJ3D) {

                mtlOutput.println("newmtl " + the_filename.replace('.', '_'));
                mtlOutput.println("\tilum 2"); // 0:Color on and Ambient off, 1:Color on and Ambient on, 2:Highlight on, etc.
                mtlOutput.println("\tKa 1.000 1.000 1.000"); // ambient
                mtlOutput.println("\tKd 1.000 1.000 1.000"); // diffuse
                mtlOutput.println("\tKs 0.000 0.000 0.000"); // specular
                mtlOutput.println("\tNs 10.00"); // 0-1000 specular exponent
                mtlOutput.println("\tNi 1.500"); // 0.001-10 (glass:1.5) optical_density (index of refraction)

                mtlOutput.println("\td 1.000"); //  0-1 transparency  d = Tr, or maybe d = 1 - Tr
                mtlOutput.println("\tTr 1.000"); //  0-1 transparency
                mtlOutput.println("\tTf 1.000 1.000 1.000"); //  transmission filter

                //mtlOutput.println("\tmap_Ka " + Subfolder_exportMaps + the_filename); // ambient map
                mtlOutput.println("\tmap_Kd " + Subfolder_exportMaps + the_filename); // diffuse map
              }
            }
          }


          if (target_window == TypeWindow.OBJ3D) {

            if (User3D.export_PolyToPoly == 1) {
              obj_lastGroupNumber += 1;
              objOutput.println("g Impact_" + nf(f, 0));
            }

            if (User3D.export_MaterialLibrary) {
              objOutput.println("usemtl " + the_filename.replace('.', '_'));
            }
          }


          float[][] subFace = getCorners(Section_Type, Section_X, Section_Y, Section_Z, Section_R, Section_U, Section_V, Section_RES1, Section_RES2);


          num_vertices_added = 0;

          int end_turn = 1;
          if (target_window == TypeWindow.OBJ3D) end_turn = 3;
          for (int _turn = 1; _turn <= end_turn; _turn++) {

            boolean display_image = false;

            if (target_window == TypeWindow.WIN3D) {

              WIN3D.graphics.beginShape();

              WIN3D.graphics.noStroke();
              WIN3D.graphics.noFill();

              if (allSolarImpacts.displayImage) {

                WIN3D.graphics.texture(this.SolarImpact[f][IMPACTS_displayDay][WIN3D.Impact_TYPE]);

              } else if (allSolidImpacts.displayImage) {

                WIN3D.graphics.texture(this.SolidImpact[f]);
              }

            }


            for (int q = 1; q <= 4; q++) {

              float x = subFace[q][0];
              float y = subFace[q][1];
              float z = subFace[q][2];
              float u = subFace[q][3];
              float v = subFace[q][4];

              if (target_window == TypeWindow.WIN3D) {

                WIN3D.graphics.vertex(x * OBJECTS_scale * WIN3D.scale, -y * OBJECTS_scale * WIN3D.scale, z * OBJECTS_scale * WIN3D.scale, u * Section_RES1, v * Section_RES2);
              }


              if (target_window == TypeWindow.OBJ3D) {

                v = 1 - v; // mirroring the image <<<<<<<<<<<<<<<<<<

                if (_turn == 1) {
                  SOLARCHVISION_OBJprintVertex(x, y, z);
                }

                if (_turn == 2) {
                  SOLARCHVISION_OBJprintVtexture(u, v, 0);
                }

                if (_turn == 3) {
                  obj_lastVertexNumber += 1;
                  obj_lastVtextureNumber += 1;
                }
              }

              this.Vertices[f * 4 + q - 1][0] = x;
              this.Vertices[f * 4 + q - 1][1] = y;
              this.Vertices[f * 4 + q - 1][2] = z;
            }

            if (target_window == TypeWindow.WIN3D) {
              WIN3D.graphics.endShape(CLOSE);
            }

            this.Faces[f][0] = f * 4 + 0;
            this.Faces[f][1] = f * 4 + 1;
            this.Faces[f][2] = f * 4 + 2;
            this.Faces[f][3] = f * 4 + 3;
          }

          if (target_window == TypeWindow.OBJ3D) {

            String n1_txt = nf(obj_lastVertexNumber - 3, 0);
            String n2_txt = nf(obj_lastVertexNumber - 2, 0);
            String n3_txt = nf(obj_lastVertexNumber - 1, 0);
            String n4_txt = nf(obj_lastVertexNumber - 0, 0);

            String m1_txt = nf(obj_lastVtextureNumber - 3, 0);
            String m2_txt = nf(obj_lastVtextureNumber - 2, 0);
            String m3_txt = nf(obj_lastVtextureNumber - 1, 0);
            String m4_txt = nf(obj_lastVtextureNumber - 0, 0);

            obj_lastFaceNumber += 1;
            objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n2_txt + "/" + m2_txt + " " + n3_txt + "/" + m3_txt + " " + n4_txt + "/" + m4_txt);
            if (User3D.export_BackSides) {
              obj_lastFaceNumber += 1;
              objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n4_txt + "/" + m4_txt + " " + n3_txt + "/" + m3_txt + " " + n2_txt + "/" + m2_txt);
            }

          }


          if (target_window == TypeWindow.HTML) {

            htmlOutput.println("\t\t\t\t<shape>");

            htmlOutput.println("\t\t\t\t\t<Appearance USE='" + the_filename + "'></Appearance>");


            htmlOutput.println("\t\t\t\t\t<IndexedFaceSet solid='false' coordIndex='0 1 2 3 -1'>"); // force two-sided

            htmlOutput.print  ("\t\t\t\t\t\t<Coordinate point='");
            for (int s = 1; s < subFace.length; s++) {
              if (s > 1) {
                htmlOutput.print(",");
              }

              htmlOutput.print(nf(subFace[s][0], 0, User3D.export_PrecisionVertex) + " " + nf(subFace[s][1], 0, User3D.export_PrecisionVertex) + " " + nf(subFace[s][2], 0, User3D.export_PrecisionVertex));
            }
            htmlOutput.println("'></Coordinate>");


            for (int s = 1; s < subFace.length; s++) {

              float u = subFace[s][3];
              float v = subFace[s][4];

              if (s == 1) {
                htmlOutput.print  ("\t\t\t\t\t\t<TextureCoordinate point='");
              }
              if (s > 1) {
                htmlOutput.print(",");
              }

              v = 1 - v; // mirroring the image <<<<<<<<<<<<<<<<<<
              SOLARCHVISION_HTMLprintVtexture(u, v);

              if (s == subFace.length - 1) {
                htmlOutput.println("'></TextureCoordinate>");
              }
            }



            htmlOutput.println("\t\t\t\t\t</IndexedFaceSet>");

            htmlOutput.println("\t\t\t\t</shape>");
          }

        }
      }

    }

  }


  float[][] getCorners (int Section_Type, float Section_X, float Section_Y, float Section_Z, float Section_R, float Section_U, float Section_V, int Section_RES1, int Section_RES2) {

    float[][] ImageVertex = new float [5][5];

    for (int q = 0; q < 5; q++) {

      float qx = 0, qy = 0, u = 0, v = 0;

      if (q == 0) {
        qx = 0;
        qy = 0;
        u = 0.5;
        v = 0.5;
      } // center
      else if (q == 1) {
        qx = -1;
        qy = -1;
        u = 0;
        v = 1;
      } else if (q == 2) {
        qx = 1;
        qy = -1;
        u = 1;
        v = 1;
      } else if (q == 3) {
        qx = 1;
        qy = 1;
        u = 1;
        v = 0;
      } else if (q == 4) {
        qx = -1;
        qy = 1;
        u = 0;
        v = 0;
      }

      float a = qx * 0.5 * Section_U + Section_X;
      float b = qy * 0.5 * Section_V + Section_Y;
      float c = Section_Z;

      float x = 0, y = 0, z = 0;

      if (Section_Type == 1) {
        x = a * funcs.cos_ang(Section_R) - b * funcs.sin_ang(Section_R);
        y = a * funcs.sin_ang(Section_R) + b * funcs.cos_ang(Section_R);
        z = c;
      } else if (Section_Type == 2) {
        x = a * funcs.cos_ang(Section_R) - c * funcs.sin_ang(Section_R);
        y = -(a * funcs.sin_ang(Section_R) + c * funcs.cos_ang(Section_R));
        z = b;
      } else if (Section_Type == 3) {
        x = a * funcs.cos_ang(90 - Section_R) - c * funcs.sin_ang(90 - Section_R); // ????????????
        y = -(a * funcs.sin_ang(90 - Section_R) + c * funcs.cos_ang(90 - Section_R)); // ????????????
        z = b;
      }

      ImageVertex[q][0] = x;
      ImageVertex[q][1] = y;
      ImageVertex[q][2] = z;
      ImageVertex[q][3] = u;
      ImageVertex[q][4] = v;
    }

    return ImageVertex;
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

    {
      XML parent = xml.addChild(this.CLASS_STAMP);

      int ni = this.num;
      XML_setInt(parent, "ni", ni);
      for (int i = 0; i < ni; i++) {
        XML child = parent.addChild("item");
        XML_setInt(child, "id", i);
        String txt = "";

        txt += nf(this.getX(i), 0, 4).replace(",", "."); // <<<<
        txt += ",";
        txt += nf(this.getY(i), 0, 4).replace(",", "."); // <<<<
        txt += ",";
        txt += nf(this.getZ(i), 0, 4).replace(",", "."); // <<<<
        txt += ",";
        txt += nf(this.getR(i), 0, 4).replace(",", "."); // <<<<
        txt += ",";
        txt += nf(this.getU(i), 0, 4).replace(",", "."); // <<<<
        txt += ",";
        txt += nf(this.getV(i), 0, 4).replace(",", "."); // <<<<
        txt += ",";

        txt += nf(this.get_type(i), 0);
        txt += ",";
        txt += nf(this.get_res1(i), 0);
        txt += ",";
        txt += nf(this.get_res2(i), 0);

        XML_setContent(child, txt);
      }

      XML_setBoolean(parent, "displayAll", this.displayAll);
    }

    {
      XML parent = xml.addChild(this.CLASS_STAMP + ".SolidImpact");
      int ni = this.SolidImpact.length;
      XML_setInt(parent, "ni", ni);
      for (int i = 0; i < ni; i++) {

        String the_filename = "SolidImpact_" + nf(i, 0) + ".bmp";

        String TEXTURE_path = Folder_Project + "/Textures/" + the_filename;

        println("Saving texture:", TEXTURE_path);
        this.SolidImpact[i].save(TEXTURE_path);

        XML child = parent.addChild("item");
        XML_setInt(child, "id", i);
        XML_setContent(child, TEXTURE_path);
      }
    }

    {
      XML parent = xml.addChild(this.CLASS_STAMP + ".SolarImpacts");
      int ni = 0, nj = 0, nk = 0;

      ni = this.SolarImpact.length;
      if (ni > 0) {
        nj = this.SolarImpact[0].length;
        if (nj > 0) {
          nk = this.SolarImpact[0][0].length;
        }
      }

      XML_setInt(parent, "ni", ni);
      XML_setInt(parent, "nj", nj);
      XML_setInt(parent, "nk", nk);

      for (int i = 0; i < ni; i++) {
        for (int j = 0; j < nj; j++) {
          for (int k = 0; k < nk; k++) {

            String the_filename = "allSolarImpacts." + nf((i * nj + j) * nk + k, 0) + ".bmp";

            String TEXTURE_path = Folder_Project + "/Textures/" + the_filename;

            println("Saving texture:", TEXTURE_path);
            this.SolarImpact[i][j][k].save(TEXTURE_path);

            XML child = parent.addChild("item");
            XML_setInt(child, "id", (i * nj + j) * nk + k);
            XML_setContent(child, TEXTURE_path);
          }
        }
      }
    }
  }


  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP);

    {
      XML parent = xml.getChild(this.CLASS_STAMP);

      int ni = XML_getInt(parent, "ni");

      this.f_data = new float [ni][6];
      this.i_data = new int   [ni][3];
      this.num = ni;

      XML[] children = parent.getChildren("item");
      for (int i = 0; i < ni; i++) {

        String txt = XML_getContent(children[i]);
        String[] parts = split(txt, ",");

        this.setX(i, float(parts[0]));
        this.setY(i, float(parts[1]));
        this.setZ(i, float(parts[2]));
        this.setR(i, float(parts[3]));
        this.setU(i, float(parts[4]));
        this.setV(i, float(parts[5]));

        this.set_type(i, int(parts[6]));
        this.set_res1(i, int(parts[7]));
        this.set_res2(i, int(parts[8]));
      }

      this.displayAll = XML_getBoolean(parent, "displayAll");
    }

    {
      XML parent = xml.getChild(this.CLASS_STAMP + ".SolidImpact");

      int ni = XML_getInt(parent, "ni");

      this.SolidImpact = new PImage [ni];

      XML[] children = parent.getChildren("item");
      for (int i = 0; i < ni; i++) {

        String TEXTURE_path = XML_getContent(children[i]);

        this.SolidImpact[i] = createImage(2, 2, RGB); // empty and small

        println("Loading texture(" + i + "):", TEXTURE_path);
        this.SolidImpact[i] = loadImage(TEXTURE_path);
        println("loaded!");
      }
    }

    {
      XML parent = xml.getChild(this.CLASS_STAMP + ".SolarImpacts");

      int ni = XML_getInt(parent, "ni");
      int nj = XML_getInt(parent, "nj");
      int nk = XML_getInt(parent, "nk");

      this.SolarImpact = new PImage [ni][nj][nk];

      XML[] children = parent.getChildren("item");
      for (int i = 0; i < ni; i++) {
        for (int j = 0; j < nj; j++) {
          for (int k = 0; k < nk; k++) {

            String TEXTURE_path = XML_getContent(children[(i * nj + j) * nk + k]);

            this.SolarImpact[i][j][k] = createImage(2, 2, RGB); // empty and small

            println("Loading texture(" + i + "," + j + "," + k + "):", TEXTURE_path);
            this.SolarImpact[i][j][k] = loadImage(TEXTURE_path);
            println("loaded!");
          }
        }
      }
    }
  }

}
