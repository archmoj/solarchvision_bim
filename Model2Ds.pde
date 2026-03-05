class solarchvision_Model2Ds {

  private final static String CLASS_STAMP = "Model2Ds";

  solarchvision_Model2Ds () { // constructor
    makeEmpty(0);
  }

  boolean displayAll = true;

  int num;
  float[][] XYZS;

  void makeEmpty (int n) {

    this.num = n;
    this.XYZS = new float [n][4];
    this.MAP = new int [n];

    if (allGroups != null) {
      for (int q = 0; q < allGroups.num; q++) {
        allGroups.Model2Ds[q][0] = 0;
        allGroups.Model2Ds[q][1] = -1;
      }
    }

    if (Select3D != null) {
      Select3D.deselect_Groups();
      Select3D.deselect_Model2Ds();
    }

    SOLARCHVISION_model_changed();
  }

  void create (String t, int m, float x, float y, float z, float s) {

    int n1 = this.num_files_PEOPLE;
    int n2 = this.num_files_PEOPLE + this.num_files_TREES;

    int n = m;

    if (n == 0) {
      if (t.equals("PEOPLE")) n = int(random(1, 1 + n1));
      else if (t.equals("TREES")) n = int(random(1 + n1, 1 + n2));
    }

    int d = 1;
    int r = int(random(2));
    if (r == 0) d = -1;

    int[] Temp_MAP = {
      d * n
    };
    this.MAP = concat(this.MAP, Temp_MAP);

    float[][] Temp_XYZS = {
      {
        x, y, z, s
      }
    };
    this.XYZS = (float[][]) concat(this.XYZS, Temp_XYZS);

    this.num += 1;

    if (this.isTree(n)) {

      if (User3D.create_MeshOrSolid != 0) {

        float x0 = x;
        float y0 = y;
        float z0 = 0.5 * s + z;
        float r0 = 0.4 * s; // <<<<<<< approximate

        allSolids.create(x0, y0, z0, 2, 2, 2, r0, r0, r0, 0, 0, 0, User3D.create_MeshOrSolid);
      }
    }

    if (allGroups.num > 0) allGroups.Model2Ds[allGroups.num - 1][1] = this.num - 1;
  }


  float getX (int n) {
    return this.XYZS[n][0];
  }

  float getY (int n) {
    return this.XYZS[n][1];
  }

  float getZ (int n) {
    return this.XYZS[n][2];
  }

  float getS (int n) {
    return this.XYZS[n][3];
  }

  void setX (int n, float f) {
    this.XYZS[n][0] = f;
  }

  void setY (int n, float f) {
    this.XYZS[n][1] = f;
  }

  void setZ (int n, float f) {
    this.XYZS[n][2] = f;
  }

  void setS (int n, float f) {
    this.XYZS[n][3] = f;
  }

  void move (int n, float dx, float dy, float dz) {
    this.XYZS[n][0] += dx;
    this.XYZS[n][1] += dy;
    this.XYZS[n][2] += dz;
  }

  void magS (int n, float f) {
    this.XYZS[n][3] *= f;
  }

  int[] MAP = new int[0];

  String[] ImagePath;
  int num_files_PEOPLE = 0;
  int num_files_TREES = 0;

  int num_visualFaces = 3; // internal - number of faces: Vertical, Horizontal Front, Horizontal Back

  String[] Filenames_PEOPLE;
  String[] Filenames_TREES;

  PImage[] Images;
  float[] ImageRatios;

  float[][] Vertices;
  int[][] Faces;

  boolean isTree (int n) {
    if (abs(n) > this.num_files_PEOPLE) {
      return true;
    }
    return false;
  }

  void load_images () {

    this.ImagePath = new String [1];
    this.ImagePath[0] = "";

    this.Filenames_PEOPLE = sort(OPESYS.getFiles(Folder_People));
    this.Filenames_TREES = sort(OPESYS.getFiles(Folder_Trees));

    this.ImagePath = concat(this.ImagePath, this.Filenames_PEOPLE);
    this.ImagePath = concat(this.ImagePath, this.Filenames_TREES);

    this.num_files_PEOPLE = this.Filenames_PEOPLE.length;
    this.num_files_TREES = this.Filenames_TREES.length;


    int n = this.ImagePath.length;

    this.Images = new PImage [n + 1];
    this.ImageRatios = new float [n + 1];

    for (int i = 1; i < n; i++) { // leaving [0] null

      if (i <= this.num_files_PEOPLE) {
        this.ImagePath[i] = Folder_People + "/" + this.ImagePath[i];
      } else {
        this.ImagePath[i] = Folder_Trees + "/" + this.ImagePath[i];
      }
    }

    for (int i = 1; i < n; i++) {
      //println(this.ImagePath[i]);
      this.Images[i] = loadImage(this.ImagePath[i]);

      if (this.Images[i].height != 0) {
        this.ImageRatios[i] = float(this.Images[i].width) / float(this.Images[i].height);
      } else {
        this.ImageRatios[i] = 1;
      }
    }
  }


  void draw (int target_window) {

    this.Faces = new int [this.num * this.num_visualFaces][4];
    this.Vertices = new float [4 * this.num * this.num_visualFaces][5]; // note we are keeping u & v at 3rd and 4th members

    boolean proceed = true;

    if (this.displayAll == false) {
      proceed = false;
    }

    if ((target_window == TypeWindow.STUDY) ||
        (target_window == TypeWindow.WORLD)) {

      proceed = false;
    }

    if (proceed) {

      if (User3D.export_MaterialLibrary) {

        if ((target_window == TypeWindow.HTML) ||
            (target_window == TypeWindow.OBJ3D)) {

          int[] ImageUsed = new int [this.ImagePath.length];

          for (int i = 0; i < ImageUsed.length; i++) {
            ImageUsed[i] = 0;
          }

          for (int f = 0; f < this.num; f++) {

            int n = abs(this.MAP[f]);

            ImageUsed[n] += 1;
          }

          for (int i = 1; i < this.ImagePath.length; i++) {

            if (ImageUsed[i] != 0) {

              String old_Texture_path = this.ImagePath[i];

              String new_Texture_path = "";

              String opacity_Texture_path = "";

              String the_filename = "";

              if (this.ImagePath[i].equals("")) {
              } else {

                the_filename = old_Texture_path.substring(old_Texture_path.lastIndexOf("/") + 1); // image name

                new_Texture_path = Folder_Export3D + "/" + Subfolder_exportMaps + the_filename;
                opacity_Texture_path = Folder_Export3D + "/" + Subfolder_exportMaps + "opacity_" + the_filename;

                println("Copying texture:", old_Texture_path, ">", new_Texture_path);
                saveBytes(new_Texture_path, loadBytes(old_Texture_path));

                println("Making opacity texture:", new_Texture_path);

                int RES1 = this.Images[i].width;
                int RES2 = this.Images[i].height;

                PImage Opacity_Texture = createImage(RES1, RES2, ARGB);

                Opacity_Texture.loadPixels();

                for (int np = 0; np < (RES1 * RES2); np++) {
                  int Image_X = np % RES1;
                  int Image_Y = np / RES1;

                  color COL = this.Images[i].get(Image_X, Image_Y);
                  //alpha: COL >> 24 & 0xFF; red: COL >> 16 & 0xFF; green: COL >>8 & 0xFF; blue: COL & 0xFF;

                  float COL_V = (COL >> 24 & 0xFF);

                  Opacity_Texture.pixels[np] = color(COL_V, COL_V, COL_V, COL_V);
                }

                Opacity_Texture.updatePixels();

                Opacity_Texture.save(opacity_Texture_path);

                if (target_window == TypeWindow.HTML) {
                  htmlOutput.println("\t\t\t\t<Appearance DEF='this." + the_filename + "'>");
                  htmlOutput.println("\t\t\t\t\t<ImageTexture url='"+ Subfolder_exportMaps + the_filename + "'><ImageTexture/>");
                  htmlOutput.println("\t\t\t\t</Appearance>");
                }

                if (target_window == TypeWindow.OBJ3D) {

                  mtlOutput.println("newmtl " + CLASS_STAMP + the_filename);
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
                  mtlOutput.println("\tmap_d " + Subfolder_exportMaps + "opacity_" + the_filename); // diffuse map
                }
              }
            }
          }
        }
      }





      float[] DistZ = new float [this.num];

      for (int f = 0; f < this.num; f++) {
        float x = this.getX(f) * OBJECTS_scale;
        float y = this.getY(f) * OBJECTS_scale;
        float z = this.getZ(f) * OBJECTS_scale;

        DistZ[f] = dist(x, y, z, WIN3D.CAM_x, WIN3D.CAM_y, WIN3D.CAM_z);
      }

      for (int g = 0; g < this.num; g++) {

        int f = -1;
        float max_dist = -1;

        for (int q = 0; q < this.num; q++) {
          if (max_dist < DistZ[q]) {
            max_dist = DistZ[q];
            f = q;
          }
        }

        DistZ[f] = -1;



        if (f != -1) {

          int n = abs(this.MAP[f]);

          int w = this.Images[n].width;
          int h = this.Images[n].height;

          float x = this.getX(f) * OBJECTS_scale;
          float y = this.getY(f) * OBJECTS_scale;
          float z = this.getZ(f) * OBJECTS_scale;

          float rh = this.getS(f) * 0.5 * OBJECTS_scale;
          float rw = rh * this.ImageRatios[n];

          float t = PI + WIN3D.rotation_Z * PI / 180.0;
          if (WIN3D.ViewType == 1) t = atan2(y - WIN3D.CAM_y, x - WIN3D.CAM_x) + 0.5 * PI;

          if ((target_window == TypeWindow.HTML) ||
              (target_window == TypeWindow.OBJ3D)) {

            t = 0;
          }

          if (this.MAP[f] < 0) t += PI;


          float dx = rw * cos(t);
          float dy = rw * sin(t);

          float x1 = x - dx;
          float y1 = y - dy;

          float x2 = x + dx;
          float y2 = y + dy;

          if (target_window == TypeWindow.OBJ3D) {

            if (User3D.export_PolyToPoly == 1) {
              obj_lastGroupNumber += 1;
              objOutput.println("g this." + nf(f, 0) + "_type" + nf(n, 0));
            }

            if (User3D.export_MaterialLibrary) {
              objOutput.println("usemtl this." + this.ImagePath[n].substring(this.ImagePath[n].lastIndexOf("/") + 1).replace('.', '_'));
            }
          }

          num_vertices_added = 0;

          int end_turn = 1;
          if (target_window == TypeWindow.OBJ3D) end_turn = 3;
          for (int _turn = 1; _turn <= end_turn; _turn++) {
            for (int back_front = -1; back_front <= 1; back_front++) {
              if (back_front == 0) {

                if (target_window == TypeWindow.WIN3D) {

                  WIN3D.graphics.beginShape();

                  WIN3D.graphics.texture(this.Images[n]);
                  WIN3D.graphics.stroke(255, 255, 255, 0);
                  WIN3D.graphics.fill(255, 255, 255, 0);

                  WIN3D.graphics.vertex(x1 * WIN3D.scale, -y1 * WIN3D.scale, z * WIN3D.scale, 0, h);
                  WIN3D.graphics.vertex(x2 * WIN3D.scale, -y2 * WIN3D.scale, z * WIN3D.scale, w, h);
                  WIN3D.graphics.vertex(x2 * WIN3D.scale, -y2 * WIN3D.scale, (z + 2 * rh) * WIN3D.scale, w, 0);
                  WIN3D.graphics.vertex(x1 * WIN3D.scale, -y1 * WIN3D.scale, (z + 2 * rh) * WIN3D.scale, 0, 0);

                  WIN3D.graphics.endShape(CLOSE);
                }

                if (target_window == TypeWindow.OBJ3D) {

                  if (_turn == 1) {

                    SOLARCHVISION_OBJprintVertex(x1, y1, z);
                    SOLARCHVISION_OBJprintVertex(x2, y2, z);
                    SOLARCHVISION_OBJprintVertex(x2, y2, (z + 2 * rh));
                    SOLARCHVISION_OBJprintVertex(x1, y1, (z + 2 * rh));

                    num_vertices_added += 4;

                  }

                  if (_turn == 2) {
                      SOLARCHVISION_OBJprintVtexture(1, 0, 0);
                      SOLARCHVISION_OBJprintVtexture(0, 0, 0);
                      SOLARCHVISION_OBJprintVtexture(0, 1, 0);
                      SOLARCHVISION_OBJprintVtexture(1, 1, 0);
                  }

                  if (_turn == 3) {
                    obj_lastVertexNumber += num_vertices_added;
                    obj_lastVtextureNumber += num_vertices_added;

                    String n1_txt = nf(obj_lastVertexNumber - num_vertices_added + 1, 0);
                    String n2_txt = nf(obj_lastVertexNumber - num_vertices_added + 2, 0);
                    String n3_txt = nf(obj_lastVertexNumber - num_vertices_added + 3, 0);
                    String n4_txt = nf(obj_lastVertexNumber - num_vertices_added + 4, 0);

                    String m1_txt = nf(obj_lastVtextureNumber - num_vertices_added + 1, 0);
                    String m2_txt = nf(obj_lastVtextureNumber - num_vertices_added + 2, 0);
                    String m3_txt = nf(obj_lastVtextureNumber - num_vertices_added + 3, 0);
                    String m4_txt = nf(obj_lastVtextureNumber - num_vertices_added + 4, 0);

                    if (User3D.export_PolyToPoly == 0) {
                      obj_lastGroupNumber += 1;
                      objOutput.println("g this." + nf(f, 0) + "_ver");
                    }

                    obj_lastFaceNumber += 1;
                    objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n2_txt + "/" + m2_txt + " " + n3_txt + "/" + m3_txt + " " + n4_txt + "/" + m4_txt);
                    if (User3D.export_BackSides) {
                      obj_lastFaceNumber += 1;
                      objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n4_txt + "/" + m4_txt + " " + n3_txt + "/" + m3_txt + " " + n2_txt + "/" + m2_txt);
                    }
                  }
                }


                if (target_window == TypeWindow.HTML) {

                  htmlOutput.println("\t\t\t\t<shape>");

                  htmlOutput.println("\t\t\t\t\t<Appearance USE='this." + this.ImagePath[n].substring(this.ImagePath[n].lastIndexOf("/") + 1) + "'></Appearance>");

                  htmlOutput.println("\t\t\t\t\t<IndexedFaceSet solid='false' coordIndex='0 1 2 3 -1'>"); // force two-sided

                  htmlOutput.print  ("\t\t\t\t\t\t<Coordinate point='");
                  htmlOutput.print  (      nf(x1, 0, User3D.export_PrecisionVertex) + " " + nf(y1, 0, User3D.export_PrecisionVertex) + " " + nf(z, 0, User3D.export_PrecisionVertex));
                  htmlOutput.print  ("," + nf(x2, 0, User3D.export_PrecisionVertex) + " " + nf(y2, 0, User3D.export_PrecisionVertex) + " " + nf(z, 0, User3D.export_PrecisionVertex));
                  htmlOutput.print  ("," + nf(x2, 0, User3D.export_PrecisionVertex) + " " + nf(y2, 0, User3D.export_PrecisionVertex) + " " + nf((z + 2 * rh), 0, User3D.export_PrecisionVertex));
                  htmlOutput.print  ("," + nf(x1, 0, User3D.export_PrecisionVertex) + " " + nf(y1, 0, User3D.export_PrecisionVertex) + " " + nf((z + 2 * rh), 0, User3D.export_PrecisionVertex));
                  htmlOutput.println("'></Coordinate>");

                  htmlOutput.println("\t\t\t\t\t\t<TextureCoordinate point='1 0,0 0,0 1,1 1'></TextureCoordinate>");

                  htmlOutput.println("\t\t\t\t\t</IndexedFaceSet>");

                  htmlOutput.println("\t\t\t\t</shape>");
                }

                int nv = f * this.num_visualFaces * 4;
                int nf = f * this.num_visualFaces;

                this.Vertices[nv + 0][0] = x1 / OBJECTS_scale;
                this.Vertices[nv + 0][1] = y1 / OBJECTS_scale;
                this.Vertices[nv + 0][2] = (z) / OBJECTS_scale;
                this.Vertices[nv + 0][3] = 0;
                this.Vertices[nv + 0][4] = 1;

                this.Vertices[nv + 1][0] = x2 / OBJECTS_scale;
                this.Vertices[nv + 1][1] = y2 / OBJECTS_scale;
                this.Vertices[nv + 1][2] = (z) / OBJECTS_scale;
                this.Vertices[nv + 1][3] = 1;
                this.Vertices[nv + 1][4] = 1;

                this.Vertices[nv + 2][0] = x2 / OBJECTS_scale;
                this.Vertices[nv + 2][1] = y2 / OBJECTS_scale;
                this.Vertices[nv + 2][2] = (z + 2 * rh) / OBJECTS_scale;
                this.Vertices[nv + 2][3] = 1;
                this.Vertices[nv + 2][4] = 0;

                this.Vertices[nv + 3][0] = x1 / OBJECTS_scale;
                this.Vertices[nv + 3][1] = y1 / OBJECTS_scale;
                this.Vertices[nv + 3][2] = (z + 2 * rh) / OBJECTS_scale;
                this.Vertices[nv + 3][3] = 0;
                this.Vertices[nv + 3][4] = 0;

                this.Faces[nf][0] = nv + 0;
                this.Faces[nf][1] = nv + 1;
                this.Faces[nf][2] = nv + 2;
                this.Faces[nf][3] = nv + 3;
              }
              else {

                int nv = f * this.num_visualFaces * 4;
                int nf = f * this.num_visualFaces;

                if (back_front == -1) {
                  nv += 4;
                  nf += 1;
                }
                else {
                  nv += 8;
                  nf += 2;
                }

                if (this.isTree(n)) { // case: trees

                  float ratio = 0.5;

                  float rot = back_front * PI / 2 + t;

                  dx = rw * cos(rot);
                  dy = rw * sin(rot);

                  float x3 = x2 + dx;
                  float y3 = y2 + dy;

                  float x4 = x1 + dx;
                  float y4 = y1 + dy;

                  if (target_window == TypeWindow.WIN3D) {

                    WIN3D.graphics.beginShape();

                    WIN3D.graphics.texture(this.Images[n]);
                    WIN3D.graphics.stroke(255, 255, 255, 0);
                    WIN3D.graphics.fill(255, 255, 255, 0);

                    WIN3D.graphics.vertex(x1 * WIN3D.scale, -y1 * WIN3D.scale, (z + 2 * rh * ratio) * WIN3D.scale, 0, h * ratio);
                    WIN3D.graphics.vertex(x2 * WIN3D.scale, -y2 * WIN3D.scale, (z + 2 * rh * ratio) * WIN3D.scale, w, h * ratio);
                    WIN3D.graphics.vertex(x3 * WIN3D.scale, -y3 * WIN3D.scale, (z + 2 * rh * ratio) * WIN3D.scale, w, 0);
                    WIN3D.graphics.vertex(x4 * WIN3D.scale, -y4 * WIN3D.scale, (z + 2 * rh * ratio) * WIN3D.scale, 0, 0);

                    WIN3D.graphics.endShape(CLOSE);
                  }

                  if (target_window == TypeWindow.OBJ3D) {
                    if (_turn == 1) {

                      SOLARCHVISION_OBJprintVertex(x1, y1, (z + 2 * rh * ratio));
                      SOLARCHVISION_OBJprintVertex(x2, y2, (z + 2 * rh * ratio));
                      SOLARCHVISION_OBJprintVertex(x3, y3, (z + 2 * rh * ratio));
                      SOLARCHVISION_OBJprintVertex(x4, y4, (z + 2 * rh * ratio));

                      num_vertices_added += 4;
                    }

                    if (_turn == 2) {

                      SOLARCHVISION_OBJprintVtexture(1, 1 - ratio, 0);
                      SOLARCHVISION_OBJprintVtexture(0, 1 - ratio, 0);
                      SOLARCHVISION_OBJprintVtexture(0, 1, 0);
                      SOLARCHVISION_OBJprintVtexture(1, 1, 0);
                    }

                    if (_turn == 3) {

                      int q = (back_front + 1) / 2;

                      String n1_txt = nf(obj_lastVertexNumber - num_vertices_added + 4 * (q + 1) + 1, 0);
                      String n2_txt = nf(obj_lastVertexNumber - num_vertices_added + 4 * (q + 1) + 2, 0);
                      String n3_txt = nf(obj_lastVertexNumber - num_vertices_added + 4 * (q + 1) + 3, 0);
                      String n4_txt = nf(obj_lastVertexNumber - num_vertices_added + 4 * (q + 1) + 4, 0);

                      String m1_txt = nf(obj_lastVtextureNumber - num_vertices_added + 4 * (q + 1) + 1, 0);
                      String m2_txt = nf(obj_lastVtextureNumber - num_vertices_added + 4 * (q + 1) + 2, 0);
                      String m3_txt = nf(obj_lastVtextureNumber - num_vertices_added + 4 * (q + 1) + 3, 0);
                      String m4_txt = nf(obj_lastVtextureNumber - num_vertices_added + 4 * (q + 1) + 4, 0);

                      if (User3D.export_PolyToPoly == 0) {
                        obj_lastGroupNumber += 1;
                        objOutput.println("g this." + nf(f, 0) + "_hor" + nf(q, 0));
                      }

                      obj_lastFaceNumber += 1;
                      objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n2_txt + "/" + m2_txt + " " + n3_txt + "/" + m3_txt + " " + n4_txt + "/" + m4_txt);
                      if (User3D.export_BackSides) {
                        obj_lastFaceNumber += 1;
                        objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n4_txt + "/" + m4_txt + " " + n3_txt + "/" + m3_txt + " " + n2_txt + "/" + m2_txt);
                      }
                    }
                  }

                  if (target_window == TypeWindow.HTML) {

                    htmlOutput.println("\t\t\t\t<shape>");

                    htmlOutput.println("\t\t\t\t\t<Appearance USE='this." + this.ImagePath[n].substring(this.ImagePath[n].lastIndexOf("/") + 1) + "'></Appearance>");

                    htmlOutput.println("\t\t\t\t\t<IndexedFaceSet solid='false' coordIndex='0 1 2 3 -1'>"); // force two-sided

                    htmlOutput.print  ("\t\t\t\t\t\t<Coordinate point='");
                    htmlOutput.print  (      nf(x1, 0, User3D.export_PrecisionVertex) + " " + nf(y1, 0, User3D.export_PrecisionVertex) + " " + nf((z + 2 * rh * ratio), 0, User3D.export_PrecisionVertex));
                    htmlOutput.print  ("," + nf(x2, 0, User3D.export_PrecisionVertex) + " " + nf(y2, 0, User3D.export_PrecisionVertex) + " " + nf((z + 2 * rh * ratio), 0, User3D.export_PrecisionVertex));
                    htmlOutput.print  ("," + nf(x3, 0, User3D.export_PrecisionVertex) + " " + nf(y3, 0, User3D.export_PrecisionVertex) + " " + nf((z + 2 * rh * ratio), 0, User3D.export_PrecisionVertex));
                    htmlOutput.print  ("," + nf(x4, 0, User3D.export_PrecisionVertex) + " " + nf(y4, 0, User3D.export_PrecisionVertex) + " " + nf((z + 2 * rh * ratio), 0, User3D.export_PrecisionVertex));
                    htmlOutput.println("'></Coordinate>");

                    htmlOutput.print ("\t\t\t\t\t\t<TextureCoordinate point='");

                    SOLARCHVISION_HTMLprintVtexture(1, 1 - ratio);
                    htmlOutput.print (",");
                    SOLARCHVISION_HTMLprintVtexture(0, 1 - ratio);
                    htmlOutput.print (",");
                    SOLARCHVISION_HTMLprintVtexture(0, 1);
                    htmlOutput.print (",");
                    SOLARCHVISION_HTMLprintVtexture(1, 1);
                    htmlOutput.println("'></TextureCoordinate>");

                    htmlOutput.println("\t\t\t\t\t</IndexedFaceSet>");

                    htmlOutput.println("\t\t\t\t</shape>");
                  }

                  this.Vertices[nv + 0][0] = x1 / OBJECTS_scale;
                  this.Vertices[nv + 0][1] = y1 / OBJECTS_scale;
                  this.Vertices[nv + 0][2] = (z + 2 * rh * ratio) / OBJECTS_scale;
                  this.Vertices[nv + 0][3] = 0;
                  this.Vertices[nv + 0][4] = ratio;

                  this.Vertices[nv + 1][0] = x2 / OBJECTS_scale;
                  this.Vertices[nv + 1][1] = y2 / OBJECTS_scale;
                  this.Vertices[nv + 1][2] = (z + 2 * rh * ratio) / OBJECTS_scale;
                  this.Vertices[nv + 1][3] = 1;
                  this.Vertices[nv + 1][4] = ratio;

                  this.Vertices[nv + 2][0] = x3 / OBJECTS_scale;
                  this.Vertices[nv + 2][1] = y3 / OBJECTS_scale;
                  this.Vertices[nv + 2][2] = (z + 2 * rh * ratio) / OBJECTS_scale;
                  this.Vertices[nv + 2][3] = 1;
                  this.Vertices[nv + 2][4] = 0;

                  this.Vertices[nv + 3][0] = x4 / OBJECTS_scale;
                  this.Vertices[nv + 3][1] = y4 / OBJECTS_scale;
                  this.Vertices[nv + 3][2] = (z + 2 * rh * ratio) / OBJECTS_scale;
                  this.Vertices[nv + 3][3] = 0;
                  this.Vertices[nv + 3][4] = 0;

                  this.Faces[nf][0] = nv + 0;
                  this.Faces[nf][1] = nv + 1;
                  this.Faces[nf][2] = nv + 2;
                  this.Faces[nf][3] = nv + 3;
                }
                else { // case: people
                  this.Vertices[nv + 0][0] = x1 / OBJECTS_scale;
                  this.Vertices[nv + 0][1] = y1 / OBJECTS_scale;
                  this.Vertices[nv + 0][2] = (z) / OBJECTS_scale;
                  this.Vertices[nv + 0][3] = 0;
                  this.Vertices[nv + 0][4] = 1;

                  this.Vertices[nv + 1][0] = x2 / OBJECTS_scale;
                  this.Vertices[nv + 1][1] = y2 / OBJECTS_scale;
                  this.Vertices[nv + 1][2] = (z) / OBJECTS_scale;
                  this.Vertices[nv + 1][3] = 1;
                  this.Vertices[nv + 1][4] = 1;

                  this.Vertices[nv + 2][0] = x2 / OBJECTS_scale;
                  this.Vertices[nv + 2][1] = y2 / OBJECTS_scale;
                  this.Vertices[nv + 2][2] = (z + 2 * rh) / OBJECTS_scale;
                  this.Vertices[nv + 2][3] = 1;
                  this.Vertices[nv + 2][4] = 0;

                  this.Vertices[nv + 3][0] = x1 / OBJECTS_scale;
                  this.Vertices[nv + 3][1] = y1 / OBJECTS_scale;
                  this.Vertices[nv + 3][2] = (z + 2 * rh) / OBJECTS_scale;
                  this.Vertices[nv + 3][3] = 0;
                  this.Vertices[nv + 3][4] = 0;

                  this.Faces[nf][0] = nv + 0;
                  this.Faces[nf][1] = nv + 1;
                  this.Faces[nf][2] = nv + 2;
                  this.Faces[nf][3] = nv + 3;
                }
              }
            }
          }
        }
      }
    }
  }


  float[] intersect (float[] ray_pnt, float[] ray_dir) {

    float[] ray_normal = funcs.vec3_unit(ray_dir);

    float[][] hitPoint = new float [this.Faces.length][6];

    for (int f = 0; f < this.Faces.length; f++) {
      hitPoint[f][0] = FLOAT_undefined;
      hitPoint[f][1] = FLOAT_undefined;
      hitPoint[f][2] = FLOAT_undefined;
      hitPoint[f][3] = FLOAT_undefined;
      hitPoint[f][4] = FLOAT_undefined;
      hitPoint[f][5] = FLOAT_undefined;
    }

    for (int f = 0; f < this.Faces.length; f++) {

      int n = this.Faces[f].length;

      float X_intersect = FLOAT_undefined;
      float Y_intersect = FLOAT_undefined;
      float Z_intersect = FLOAT_undefined;
      float dist2intersect = FLOAT_undefined;

      //boolean InPoly = false;
      float[] UV = {FLOAT_undefined, FLOAT_undefined};

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

          UV = funcs.uvInside_Rectangle(P, A, B, C);
        }
      }

      float u = UV[0];
      float v = UV[1];

      if ((u >= 0) && (v >= 0) && (u <= 1) && (v <= 1)) {

        hitPoint[f][0] = X_intersect;
        hitPoint[f][1] = Y_intersect;
        hitPoint[f][2] = Z_intersect;
        hitPoint[f][3] = dist2intersect;
        // converting rom face UV to image UV
        hitPoint[f][4] = (1 - u) * B[3] + u * A[3];
        hitPoint[f][5] = (1 - v) * B[4] + v * C[4];

      }
    }


    float[] return_point = {-1, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined};

    float pre_dist = FLOAT_undefined;

    for (int f = 0; f < this.Faces.length; f++) {

      int OBJ_ID = f / this.num_visualFaces;

      if (pre_dist > hitPoint[f][3]) {

        float u = hitPoint[f][4];
        float v = hitPoint[f][5];

        int n = abs(this.MAP[OBJ_ID]);

        int RES1 = this.Images[n].width;
        int RES2 = this.Images[n].height;

        this.Images[n].loadPixels();

        if (n < 0) u = 1 - u;

        //println("uv,n", u, v, n);

        int Image_X = int(u * RES1);
        int Image_Y = int(v * RES2);

        color COL = this.Images[n].get(Image_X, Image_Y);
        //alpha: COL >> 24 & 0xFF; red: COL >> 16 & 0xFF; green: COL >>8 & 0xFF; blue: COL & 0xFF;

        float COL_V = (COL >> 24 & 0xFF);

        if (COL_V > 0) {

          pre_dist = hitPoint[f][3];

          return_point[0] = OBJ_ID;
          return_point[1] = hitPoint[f][0];
          return_point[2] = hitPoint[f][1];
          return_point[3] = hitPoint[f][2];
          return_point[4] = hitPoint[f][3];
        }
      }

    }

    return return_point;
  }









  void castShadows (float[] SunR) {

    for (int f = 0; f < this.num; f++) {

      int n = abs(this.MAP[f]);

      int w = this.Images[n].width;
      int h = this.Images[n].height;

      float r = this.getS(f) * 0.5;

      float t = atan2(SunR[2], SunR[1]) + 0.5 * PI;

      if (this.MAP[f] < 0) t += PI;

      if (r > 2.5) { // to select only trees!

        float x = this.getX(f);
        float y = this.getY(f);
        float z = this.getZ(f);

        { // Vertical mask
          TREES_graphics.beginShape();

          TREES_graphics.texture(this.Images[n]);

          x = this.getX(f);
          y = this.getY(f);
          z = this.getZ(f);

          float[] TX = {
            0, 0, 0, 0
          };
          float[] TY = {
            0, 0, 0, 0
          };
          float[] TZ = {
            0, 0, 0, 0
          };
          float[] TU = {
            0, 0, 0, 0
          };
          float[] TV = {
            0, 0, 0, 0
          };

          TX[0] = x - r * cos(t);
          TY[0] = y - r * sin(t);
          TZ[0] = z;
          TX[1] = x + r * cos(t);
          TY[1] = y + r * sin(t);
          TZ[1] = z;
          TX[2] = x + r * cos(t);
          TY[2] = y + r * sin(t);
          TZ[2] = z + 2 * r;
          TX[3] = x - r * cos(t);
          TY[3] = y - r * sin(t);
          TZ[3] = z + 2 * r;

          TU[0] = 0;
          TV[0] = h;
          TU[1] = w;
          TV[1] = h;
          TU[2] = w;
          TV[2] = 0;
          TU[3] = 0;
          TV[3] = 0;

          if (allSolarImpacts.sectionType == 2) {
            {
              for (int q = 0; q < 4; q++) {
                float a = TX[q];
                float b = -TY[q];
                float c = TZ[q];

                TX[q] = a * funcs.cos_ang(-allSolarImpacts.R) - b * funcs.sin_ang(-allSolarImpacts.R);
                TY[q] = c;
                TZ[q] = a * funcs.sin_ang(-allSolarImpacts.R) + b * funcs.cos_ang(-allSolarImpacts.R);
              }
            }
            { // now that we rotated 2D we could rotate x,y,z
              float a = x;
              float b = -y;
              float c = z;

              x = a * funcs.cos_ang(-allSolarImpacts.R) - b * funcs.sin_ang(-allSolarImpacts.R);
              y = c;
              z = a * funcs.sin_ang(-allSolarImpacts.R) + b * funcs.cos_ang(-allSolarImpacts.R);
            }
          } else if (allSolarImpacts.sectionType == 3) {
          }

          if ((TZ[0] < allSolarImpacts.Z) && (allSolarImpacts.Z < TZ[2])) {

            float ratio = (allSolarImpacts.Z - TZ[0]) / (TZ[2] - TZ[0]);

            TZ[0] = (TZ[0] * (1 - ratio) + TZ[2] * ratio);
            TZ[1] = (TZ[1] * (1 - ratio) + TZ[3] * ratio);

            if (allSolarImpacts.sectionType == 1) {

              TV[0] = (TV[0] * (1 - ratio) + TV[2] * ratio);
              TV[1] = (TV[1] * (1 - ratio) + TV[3] * ratio);
            } else if (allSolarImpacts.sectionType == 2) {

              TU[1] = (TU[1] * (1 - ratio) + TU[3] * ratio);
              TU[2] = (TU[2] * (1 - ratio) + TU[0] * ratio);
            } else if (allSolarImpacts.sectionType == 3) {
            }
          }

          if (TZ[2] > allSolarImpacts.Z) {

            for (int q = 0; q < 4; q++) {

              TZ[q] = TZ[q] - allSolarImpacts.Z;
              TX[q] = (TX[q] - TZ[q] * SunR_Rotated[1] / SunR_Rotated[3]);
              TY[q] = (TY[q] - TZ[q] * SunR_Rotated[2] / SunR_Rotated[3]);

              if (allSolarImpacts.sectionType == 1) {
                float px = TX[q];
                float py = TY[q];

                TX[q] = px * funcs.cos_ang(-allSolarImpacts.R) - py * funcs.sin_ang(-allSolarImpacts.R);
                TY[q] = px * funcs.sin_ang(-allSolarImpacts.R) + py * funcs.cos_ang(-allSolarImpacts.R);
              }

              TREES_graphics.vertex((TX[q] - Shades_offsetX) * Shades_scaleX, -(TY[q] - Shades_offsetY) * Shades_scaleY, TU[q], TV[q]);
            }
          }

          TREES_graphics.endShape(CLOSE);
        }

        { // Horizontal mask
          float ratio = 0.5; // put the mask at half of the height of the tree

          for (int back_front = -1; back_front <= 1; back_front += 2) {

            float rot = back_front * PI / 2 + t;

            TREES_graphics.beginShape();

            TREES_graphics.texture(this.Images[n]);

            float[] TX = {
              0, 0, 0, 0
            };
            float[] TY = {
              0, 0, 0, 0
            };
            float[] TZ = {
              0, 0, 0, 0
            };
            float[] TU = {
              0, 0, 0, 0
            };
            float[] TV = {
              0, 0, 0, 0
            };

            TX[0] = x - r * cos(t);
            TY[0] = y - r * sin(t);
            TZ[0] = z + 2 * r * ratio;
            TX[1] = x + r * cos(t);
            TY[1] = y + r * sin(t);
            TZ[1] = z + 2 * r * ratio;
            TX[2] = x + r * cos(t) + r * cos(rot);
            TY[2] = y + r * sin(t) + r * sin(rot);
            TZ[2] = z + 2 * r * ratio;
            TX[3] = x - r * cos(t) + r * cos(rot);
            TY[3] = y - r * sin(t) + r * sin(rot);
            TZ[3] = z + 2 * r * ratio;

            TU[0] = 0;
            TV[0] = h * ratio;
            TU[1] = w;
            TV[1] = h * ratio;
            TU[2] = w;
            TV[2] = 0;
            TU[3] = 0;
            TV[3] = 0;

            if (allSolarImpacts.sectionType == 1) {
              if (z + 2 * r * ratio > allSolarImpacts.Z) {

                for (int q = 0; q < 4; q++) {

                  TZ[q] = TZ[q] - allSolarImpacts.Z;
                  TX[q] = (TX[q] - TZ[q] * SunR_Rotated[1] / SunR_Rotated[3]);
                  TY[q] = (TY[q] - TZ[q] * SunR_Rotated[2] / SunR_Rotated[3]);

                  if (allSolarImpacts.sectionType == 1) {
                    float px = TX[q];
                    float py = TY[q];

                    TX[q] = px * funcs.cos_ang(-allSolarImpacts.R) - py * funcs.sin_ang(-allSolarImpacts.R);
                    TY[q] = px * funcs.sin_ang(-allSolarImpacts.R) + py * funcs.cos_ang(-allSolarImpacts.R);
                  }

                  TREES_graphics.vertex((TX[q] - Shades_offsetX) * Shades_scaleX, -(TY[q] - Shades_offsetY) * Shades_scaleY, TU[q], TV[q]);
                }
              }
            }

            TREES_graphics.endShape(CLOSE);
          }
        }
      }
    }
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
        txt += nf(this.getS(i), 0, 4).replace(",", "."); // <<<<
        txt += ",";
        txt += this.MAP[i];

        XML_setContent(child, txt);
      }

      XML_setBoolean(parent, "displayAll", this.displayAll);
      XML_setInt(parent, "num_files_PEOPLE", this.num_files_PEOPLE);
      XML_setInt(parent, "num_files_TREES", this.num_files_TREES);
    }

    {
      XML parent = xml.addChild(this.CLASS_STAMP + ".Textures");
      int ni = this.ImagePath.length;
      XML_setInt(parent, "ni", ni);
      for (int i = 0; i < ni; i++) {

        boolean TEXTURE_copied = false;

        String the_dir = save_folder;

        String the_filename = "";
        if (this.ImagePath[i].equals("")) {
        } else {
          the_filename = this.ImagePath[i].substring(this.ImagePath[i].lastIndexOf("/") + 1); // image name


          String new_Texture_path = the_dir + "/Textures/" + the_filename;

          if (this.ImagePath[i].toUpperCase().equals(new_Texture_path.toUpperCase())) {
            TEXTURE_copied = false;
          } else {
            if (this.ImagePath[i].equals("")) {
            } else {
              println("Copying texture:", this.ImagePath[i], ">", new_Texture_path);
              saveBytes(new_Texture_path, loadBytes(this.ImagePath[i]));
              this.ImagePath[i] = new_Texture_path;

              TEXTURE_copied = true;
            }
          }

          //if (TEXTURE_copied == false) {
          //  println("Saving texture from the scene.");
          //  this.Images[i].save(new_Texture_path);
          //}
        }

        XML child = parent.addChild("item");
        XML_setInt(child, "id", i);
        XML_setContent(child, this.ImagePath[i]);
      }
    }
  }


  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP);

    {
      XML parent = xml.getChild(this.CLASS_STAMP);

      int ni = XML_getInt(parent, "ni");

      this.makeEmpty(ni);

      XML[] children = parent.getChildren("item");
      for (int i = 0; i < ni; i++) {
        String txt = XML_getContent(children[i]);
        String[] parts = split(txt, ",");
        this.setX(i, float(parts[0]));
        this.setY(i, float(parts[1]));
        this.setZ(i, float(parts[2]));
        this.setS(i, float(parts[3]));
        this.MAP[i] = int(parts[4]);
      }

      this.displayAll = XML_getBoolean(parent, "displayAll");
      this.num_files_PEOPLE = XML_getInt(parent, "num_files_PEOPLE");
      this.num_files_TREES = XML_getInt(parent, "num_files_TREES");
    }

    {
      XML parent = xml.getChild(this.CLASS_STAMP + ".Textures");

      int ni = XML_getInt(parent, "ni");

      int reload_All_textures = 0;

      if (this.ImagePath.length != ni) {
        this.Images = new PImage [ni];
        this.ImageRatios = new float [ni];

        reload_All_textures = 1;
      }

      XML[] children = parent.getChildren("item");
      for (int i = 0; i < ni; i++) {

        String new_Texture_path = XML_getContent(children[i]);
        if ((reload_All_textures == 0) && (this.ImagePath[i].toUpperCase().equals(new_Texture_path.toUpperCase()))) {
        } else {
          this.ImagePath[i] = new_Texture_path;
          this.Images[i] = createImage(2, 2, RGB); // empty and small
          if (this.ImagePath[i].equals("")) {
          } else {
            println("Loading texture(" + i + "):", this.ImagePath[i]);
            this.Images[i] = loadImage(this.ImagePath[i]);
            println("loaded!");

            if (this.Images[i].height != 0) {
              this.ImageRatios[i] = float(this.Images[i].width) / float(this.Images[i].height);
            } else {
              this.ImageRatios[i] = 1;
            }
          }
        }
      }
    }
  }
}
