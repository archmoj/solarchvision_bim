class solarchvision_Sections {

  private final static String CLASS_STAMP = "Sections";

  solarchvision_Sections () {
    makeEmpty(0);
  }

  boolean displayAll = true;

  int num;
  float[][] f_data = new float[0][6];
  int[][] i_data = new int[0][3];

  void makeEmpty (int n) {
    this.f_data = new float[n][6];
    this.i_data = new int[n][3];
    this.SolidImpact = new PImage[n];
    this.SolarImpact = new PImage[n][(1 + STUDY.j_End - STUDY.j_Start)][numberOfImpactVariations];
    this.num = n;

    if (Select3D != null) {
      Select3D.deselect_Sections();
    }
    SOLARCHVISION_model_changed();
  }

  void create (float x, float y, float z, float r, float u, float v, int t, int RES1, int RES2) {
    int[][] Temp_i_data = { { t, RES1, RES2 } };
    this.i_data = (int[][]) concat(this.i_data, Temp_i_data);

    float[][] Temp_f_data = { { x, y, z, r, u, v } };
    this.f_data = (float[][]) concat(this.f_data, Temp_f_data);

    PImage[] Temp_SolidImpact = { createImage(RES1, RES2, RGB) };
    this.SolidImpact = (PImage[]) concat(this.SolidImpact, Temp_SolidImpact);

    PImage[][][] Temp_SolarImpact = new PImage[1][(1 + STUDY.j_End - STUDY.j_Start)][numberOfImpactVariations];
    for (int j = STUDY.j_Start; j <= STUDY.j_End; j++) {
      for (int q = 0; q < numberOfImpactVariations; q++) {
        Temp_SolarImpact[0][j][q] = createImage(2, 2, RGB); // empty and small
      }
    }
    this.SolarImpact = (PImage[][][]) concat(this.SolarImpact, Temp_SolarImpact);

    this.num += 1;
  }

  int get_type (int n) { return this.i_data[n][0]; }
  int get_res1 (int n) { return this.i_data[n][1]; }
  int get_res2 (int n) { return this.i_data[n][2]; }
  void set_type (int n, int t) { this.i_data[n][0] = t; }
  void set_res1 (int n, int t) { this.i_data[n][1] = t; }
  void set_res2 (int n, int t) { this.i_data[n][2] = t; }

  float getX (int n) { return this.f_data[n][0]; } // offsetX
  float getY (int n) { return this.f_data[n][1]; } // offsetY
  float getZ (int n) { return this.f_data[n][2]; } // elevation
  float getR (int n) { return this.f_data[n][3]; } // rotation
  float getU (int n) { return this.f_data[n][4]; } // scaleU
  float getV (int n) { return this.f_data[n][5]; } // scaleV
  void setX (int n, float f) { this.f_data[n][0] = f; }
  void setY (int n, float f) { this.f_data[n][1] = f; }
  void setZ (int n, float f) { this.f_data[n][2] = f; }
  void setR (int n, float f) { this.f_data[n][3] = f; }
  void setU (int n, float f) { this.f_data[n][4] = f; }
  void setV (int n, float f) { this.f_data[n][5] = f; }

  void move (int n, float dx, float dy, float dz) {
    this.f_data[n][0] += dx;
    this.f_data[n][1] += dy;
    this.f_data[n][2] += dz;
  }

  PImage[] SolidImpact = new PImage[0];
  PImage[][][] SolarImpact = new PImage[0][(1 + STUDY.j_End - STUDY.j_Start)][numberOfImpactVariations];

  void resize_solarImpact_array () { // called when STUDY.j_End changes
    this.SolarImpact = new PImage[this.num][(1 + STUDY.j_End - STUDY.j_Start)][numberOfImpactVariations];
    for (int i = 0; i < this.num; i++) {
      for (int j = STUDY.j_Start; j <= STUDY.j_End; j++) {
        for (int q = 0; q < numberOfImpactVariations; q++) {
          this.SolarImpact[i][j][q] = createImage(2, 2, RGB); // empty and small
        }
      }
    }
  }

  private float[][] Vertices;
  private int[][] Faces;

  private boolean shouldDraw (int target_window) {
    if (!this.displayAll) return false;
    if (target_window == TypeWindow.STUDY) return false;
    if (target_window == TypeWindow.WORLD) return false;
    return true;
  }

  void draw (int target_window) {
    this.Faces = new int[this.num][4];
    this.Vertices = new float[4 * this.num][3];

    if (!shouldDraw(target_window)) return;

    for (int f = 0; f < this.num; f++) {
      drawSection(f, target_window);
    }
  }

  private void drawSection (int f, int target_window) {
    int Section_Type = this.get_type(f);
    if (Section_Type == 0) return;

    float Section_X = this.getX(f);
    float Section_Y = this.getY(f);
    float Section_Z = this.getZ(f);
    float Section_R = this.getR(f);
    float Section_U = this.getU(f);
    float Section_V = this.getV(f);
    int Section_RES1 = this.get_res1(f);
    int Section_RES2 = this.get_res2(f);

    String the_filename = "Impact_" + nf(f, 0) + ".bmp";

    boolean materialTarget = (target_window == TypeWindow.HTML) || (target_window == TypeWindow.OBJ3D);
    if (User3D.export_MaterialLibrary && materialTarget) {
      writeSectionMaterial(f, target_window, the_filename);
    }
    if (target_window == TypeWindow.OBJ3D) {
      writeSectionGroupHeader(f, the_filename);
    }

    float[][] subFace = getCorners(Section_Type, Section_X, Section_Y, Section_Z, Section_R, Section_U, Section_V, Section_RES1, Section_RES2);

    num_vertices_added = 0;
    int end_turn = (target_window == TypeWindow.OBJ3D) ? 3 : 1;
    for (int _turn = 1; _turn <= end_turn; _turn++) {
      renderSectionFace(f, subFace, target_window, Section_RES1, Section_RES2, _turn);
    }

    this.Faces[f][0] = f * 4 + 0;
    this.Faces[f][1] = f * 4 + 1;
    this.Faces[f][2] = f * 4 + 2;
    this.Faces[f][3] = f * 4 + 3;

    if (target_window == TypeWindow.OBJ3D) {
      writeSectionObjFace();
    }
    if (target_window == TypeWindow.HTML) {
      writeSectionHTML(subFace, the_filename);
    }
  }

  private void writeSectionMaterial (int f, int target_window, String the_filename) {
    String TEXTURE_path = Folder_Export3D + "/" + Subfolder_exportMaps + the_filename;

    if (allSolarImpacts.displayImage) {
      println("Saving texture:", TEXTURE_path);
      this.SolarImpact[f][IMPACTS_displayDay][WIN3D.Impact_TYPE].save(TEXTURE_path);
    } else if (allSolidImpacts.displayImage) {
      println("Saving texture:", TEXTURE_path);
      this.SolidImpact[f].save(TEXTURE_path);
    }

    if (target_window == TypeWindow.HTML) {
      htmlOutput.println("\t\t\t\t<Appearance DEF='" + the_filename + "'>");
      htmlOutput.println("\t\t\t\t\t<ImageTexture url='" + Subfolder_exportMaps + the_filename + "'><ImageTexture/>");
      htmlOutput.println("\t\t\t\t</Appearance>");
    }

    if (target_window == TypeWindow.OBJ3D) {
      mtlOutput.println("newmtl " + the_filename.replace('.', '_'));
      mtlOutput.println("\tilum 2");
      mtlOutput.println("\tKa 1.000 1.000 1.000");
      mtlOutput.println("\tKd 1.000 1.000 1.000");
      mtlOutput.println("\tKs 0.000 0.000 0.000");
      mtlOutput.println("\tNs 10.00");
      mtlOutput.println("\tNi 1.500");
      mtlOutput.println("\td 1.000");
      mtlOutput.println("\tTr 1.000");
      mtlOutput.println("\tTf 1.000 1.000 1.000");
      mtlOutput.println("\tmap_Kd " + Subfolder_exportMaps + the_filename);
    }
  }

  private void writeSectionGroupHeader (int f, String the_filename) {
    if (User3D.export_PolyToPoly == 1) {
      obj_lastGroupNumber += 1;
      objOutput.println("g Impact_" + nf(f, 0));
    }
    if (User3D.export_MaterialLibrary) {
      objOutput.println("usemtl " + the_filename.replace('.', '_'));
    }
  }

  private void renderSectionFace (int f, float[][] subFace, int target_window, int Section_RES1, int Section_RES2, int _turn) {
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
        v = 1 - v; // mirroring the image
        if (_turn == 1) SOLARCHVISION_OBJprintVertex(x, y, z);
        if (_turn == 2) SOLARCHVISION_OBJprintVtexture(u, v, 0);
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
  }

  private void writeSectionObjFace () {
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

  private void writeSectionHTML (float[][] subFace, String the_filename) {
    htmlOutput.println("\t\t\t\t<shape>");
    htmlOutput.println("\t\t\t\t\t<Appearance USE='" + the_filename + "'></Appearance>");
    htmlOutput.println("\t\t\t\t\t<IndexedFaceSet solid='false' coordIndex='0 1 2 3 -1'>"); // force two-sided

    htmlOutput.print("\t\t\t\t\t\t<Coordinate point='");
    for (int s = 1; s < subFace.length; s++) {
      if (s > 1) htmlOutput.print(",");
      htmlOutput.print(nf(subFace[s][0], 0, User3D.export_PrecisionVertex) + " " +
                        nf(subFace[s][1], 0, User3D.export_PrecisionVertex) + " " +
                        nf(subFace[s][2], 0, User3D.export_PrecisionVertex));
    }
    htmlOutput.println("'></Coordinate>");

    htmlOutput.print("\t\t\t\t\t\t<TextureCoordinate point='");
    for (int s = 1; s < subFace.length; s++) {
      if (s > 1) htmlOutput.print(",");
      float u = subFace[s][3];
      float v = 1 - subFace[s][4]; // mirroring the image
      SOLARCHVISION_HTMLprintVtexture(u, v);
    }
    htmlOutput.println("'></TextureCoordinate>");

    htmlOutput.println("\t\t\t\t\t</IndexedFaceSet>");
    htmlOutput.println("\t\t\t\t</shape>");
  }

  // Corner layout for a section quad: {localX, localY, u, v}. Index 0 is the (unused
  // by draw()) center point kept for parity with the original 5-row array.
  private final float[][] CORNER_LOCAL = {
    { 0,  0, 0.5, 0.5 },
    {-1, -1, 0, 1 },
    { 1, -1, 1, 1 },
    { 1,  1, 1, 0 },
    {-1,  1, 0, 0 }
  };

  float[][] getCorners (int Section_Type, float Section_X, float Section_Y, float Section_Z, float Section_R, float Section_U, float Section_V, int Section_RES1, int Section_RES2) {
    float[][] ImageVertex = new float[5][5];

    for (int q = 0; q < 5; q++) {
      float qx = CORNER_LOCAL[q][0];
      float qy = CORNER_LOCAL[q][1];
      float u  = CORNER_LOCAL[q][2];
      float v  = CORNER_LOCAL[q][3];

      float a = qx * 0.5 * Section_U + Section_X;
      float b = qy * 0.5 * Section_V + Section_Y;
      float c = Section_Z;

      float[] xyz = rotateSectionCorner(Section_Type, a, b, c, Section_R);

      ImageVertex[q][0] = xyz[0];
      ImageVertex[q][1] = xyz[1];
      ImageVertex[q][2] = xyz[2];
      ImageVertex[q][3] = u;
      ImageVertex[q][4] = v;
    }

    return ImageVertex;
  }

  // Type 1: horizontal (plan) section. Type 2: vertical section. Type 3: vertical
  // section with rotation measured from 90 degrees instead of 0 - preserved as-is.
  private float[] rotateSectionCorner (int Section_Type, float a, float b, float c, float Section_R) {
    if (Section_Type == 1) {
      float x = a * funcs.cos_ang(Section_R) - b * funcs.sin_ang(Section_R);
      float y = a * funcs.sin_ang(Section_R) + b * funcs.cos_ang(Section_R);
      return new float[] { x, y, c };
    }
    if (Section_Type == 2) {
      float x = a * funcs.cos_ang(Section_R) - c * funcs.sin_ang(Section_R);
      float y = -(a * funcs.sin_ang(Section_R) + c * funcs.cos_ang(Section_R));
      return new float[] { x, y, b };
    }
    if (Section_Type == 3) {
      float r = 90 - Section_R;
      float x = a * funcs.cos_ang(r) - c * funcs.sin_ang(r);
      float y = -(a * funcs.sin_ang(r) + c * funcs.cos_ang(r));
      return new float[] { x, y, b };
    }
    return new float[] { 0, 0, 0 };
  }

  float[] intersect (float[] ray_pnt, float[] ray_dir) {
    float[] best = { -1, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined };
    float pre_dist = FLOAT_undefined;

    for (int f = 0; f < this.Faces.length; f++) {
      float[] hit = intersectFace(f, ray_pnt, ray_dir); // {X, Y, Z, dist}, dist == FLOAT_undefined if no hit
      if (pre_dist > hit[3]) {
        pre_dist = hit[3];
        best[0] = f;
        best[1] = hit[0];
        best[2] = hit[1];
        best[3] = hit[2];
        best[4] = hit[3];
      }
    }

    return best;
  }

  private float[] intersectFace (int f, float[] ray_pnt, float[] ray_dir) {
    float[] miss = { FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined };

    int n = this.Faces[f].length;
    float[] A = this.Vertices[this.Faces[f][0]];
    float[] B = this.Vertices[this.Faces[f][1]];
    float[] C = this.Vertices[this.Faces[f][n - 2]];
    float[] D = this.Vertices[this.Faces[f][n - 1]];

    float[] AC = funcs.vec3_diff(A, C);
    float[] BD = funcs.vec3_diff(B, D);
    float[] face_norm = funcs.vec3_cross(AC, BD);
    float face_offset = 0.25 * ((A[0] + B[0] + C[0] + D[0]) * face_norm[0] +
                                 (A[1] + B[1] + C[1] + D[1]) * face_norm[1] +
                                 (A[2] + B[2] + C[2] + D[2]) * face_norm[2]);

    float R = -funcs.vec3_dot(ray_dir, face_norm);
    if ((R < FLOAT_tiny) && (R > -FLOAT_tiny)) return miss; // ray parallel to the plane

    float dist2intersect = (funcs.vec3_dot(ray_pnt, face_norm) - face_offset) / R;
    if (dist2intersect <= FLOAT_tiny) return miss;

    float X = dist2intersect * ray_dir[0] + ray_pnt[0];
    float Y = dist2intersect * ray_dir[1] + ray_pnt[1];
    float Z = dist2intersect * ray_dir[2] + ray_pnt[2];
    float[] P = { X, Y, Z };

    if (!funcs.isInside_Rectangle(P, A, B, C)) return miss;

    return new float[] { X, Y, Z, dist2intersect };
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
        txt += nf(this.getX(i), 0, 4).replace(",", ".");
        txt += ",";
        txt += nf(this.getY(i), 0, 4).replace(",", ".");
        txt += ",";
        txt += nf(this.getZ(i), 0, 4).replace(",", ".");
        txt += ",";
        txt += nf(this.getR(i), 0, 4).replace(",", ".");
        txt += ",";
        txt += nf(this.getU(i), 0, 4).replace(",", ".");
        txt += ",";
        txt += nf(this.getV(i), 0, 4).replace(",", ".");
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
      this.f_data = new float[ni][6];
      this.i_data = new int[ni][3];
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
      this.SolidImpact = new PImage[ni];
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
      this.SolarImpact = new PImage[ni][nj][nk];
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
