class Sections {

  final static String CLASS_STAMP = "section";

  Sections () {
    makeEmpty(0);
  }

  boolean displayAll = true;

  int num;
  // Columns: 0:X 1:Y 2:Z 3:rotX 4:rotY 5:rotZ 6:U 7:V. Every section is
  // the same single shape now - a flat quad in its own local X-Y plane
  // (local Z is its normal), oriented by 3 Euler angles (rotX/rotY/rotZ,
  // kept contiguous here the way Solids' own f_data groups posX/Y/Z,
  // powX/Y/Z, scaleX/Y/Z and rotX/Y/Z - composed in that X-then-Y-
  // then-Z order - see arbitrarySection.pde) and then translated to
  // X/Y/Z. There used to be 3 other "types" with their own single-angle
  // rotation and translate-before-rotate math (rotateSectionCorner(),
  // removed) - dropped as part of collapsing every section onto this
  // one (former "type 0") representation.
  float[][] f_data = new float[0][8];
  int[][] i_data = new int[0][2];

  void makeEmpty (int n) {
    beginScene3DChange();

    this.f_data = new float[n][8];
    this.i_data = new int[n][2];
    this.SolidImpact = new PImage[n];
    this.SolarImpact = new PImage[n][(1 + STUDY.endDay - STUDY.startDay)][numberOfImpactVariations];
    this.num = n;

    if (Select3D != null) {
      Select3D.deselect_Sections();
    }
    endScene3DChange();
  }

  void create (float x, float y, float z, float rotX, float u, float v, int RES1, int RES2) {
    this.create(x, y, z, rotX, 0, 0, u, v, RES1, RES2);
  }

  void create (float x, float y, float z, float rotX, float rotY, float rotZ, float u, float v, int RES1, int RES2) {
    int[][] Temp_i_data = { { RES1, RES2 } };
    this.i_data = (int[][]) concat(this.i_data, Temp_i_data);

    float[][] Temp_f_data = { { x, y, z, rotX, rotY, rotZ, u, v } };
    this.f_data = (float[][]) concat(this.f_data, Temp_f_data);

    PImage[] Temp_SolidImpact = { createImage(RES1, RES2, RGB) };
    this.SolidImpact = (PImage[]) concat(this.SolidImpact, Temp_SolidImpact);

    PImage[][][] Temp_SolarImpact = new PImage[1][(1 + STUDY.endDay - STUDY.startDay)][numberOfImpactVariations];
    for (int j = STUDY.startDay; j <= STUDY.endDay; j++) {
      for (int q = 0; q < numberOfImpactVariations; q++) {
        Temp_SolarImpact[0][j][q] = createImage(2, 2, RGB); // empty and small
      }
    }
    this.SolarImpact = (PImage[][][]) concat(this.SolarImpact, Temp_SolarImpact);

    this.num += 1;
  }

  int get_res1 (int n) { return this.i_data[n][0]; }
  int get_res2 (int n) { return this.i_data[n][1]; }
  void set_res1 (int n, int t) { this.i_data[n][0] = t; }
  void set_res2 (int n, int t) { this.i_data[n][1] = t; }

  float getX (int n) { return this.f_data[n][0]; } // offsetX
  float getY (int n) { return this.f_data[n][1]; } // offsetY
  float getZ (int n) { return this.f_data[n][2]; } // elevation
  float getRotX (int n) { return this.f_data[n][3]; }
  float getRotY (int n) { return this.f_data[n][4]; }
  float getRotZ (int n) { return this.f_data[n][5]; }
  float getU (int n) { return this.f_data[n][6]; } // scaleU
  float getV (int n) { return this.f_data[n][7]; } // scaleV
  void setX (int n, float f) { this.f_data[n][0] = f; }
  void setY (int n, float f) { this.f_data[n][1] = f; }
  void setZ (int n, float f) { this.f_data[n][2] = f; }
  void setRotX (int n, float f) { this.f_data[n][3] = f; }
  void setRotY (int n, float f) { this.f_data[n][4] = f; }
  void setRotZ (int n, float f) { this.f_data[n][5] = f; }
  void setU (int n, float f) { this.f_data[n][6] = f; }
  void setV (int n, float f) { this.f_data[n][7] = f; }

  // Mirrors Solids' own RotateX/RotateY/RotateZ (solids.pde) - plain
  // accumulation. Rotate3D.pde's own Sections() now always dispatches
  // here (every section is the same arbitrary-orientation shape).
  void RotateX (int n, float f) { this.f_data[n][3] += f; }
  void RotateY (int n, float f) { this.f_data[n][4] += f; }
  void RotateZ (int n, float f) { this.f_data[n][5] += f; }

  void move (int n, float dx, float dy, float dz) {
    this.f_data[n][0] += dx;
    this.f_data[n][1] += dy;
    this.f_data[n][2] += dz;
  }

  PImage[] SolidImpact = new PImage[0];
  PImage[][][] SolarImpact = new PImage[0][(1 + STUDY.endDay - STUDY.startDay)][numberOfImpactVariations];

  void resize_solarImpact_array () { // called when STUDY.endDay changes
    this.SolarImpact = new PImage[this.num][(1 + STUDY.endDay - STUDY.startDay)][numberOfImpactVariations];
    for (int i = 0; i < this.num; i++) {
      for (int j = STUDY.startDay; j <= STUDY.endDay; j++) {
        for (int q = 0; q < numberOfImpactVariations; q++) {
          this.SolarImpact[i][j][q] = createImage(2, 2, RGB); // empty and small
        }
      }
    }
  }

  float[][] Vertices;
  int[][] Faces;

  boolean shouldDraw (int target_window) {
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

  void drawSection (int f, int target_window) {
    float Section_X = this.getX(f);
    float Section_Y = this.getY(f);
    float Section_Z = this.getZ(f);
    float Section_RotX = this.getRotX(f);
    float Section_RotY = this.getRotY(f);
    float Section_RotZ = this.getRotZ(f);
    float Section_U = this.getU(f);
    float Section_V = this.getV(f);
    int Section_RES1 = this.get_res1(f);
    int Section_RES2 = this.get_res2(f);

    String the_filename = "Impact_" + nf(f, 0) + ".bmp";

    boolean materialTarget = (target_window == TypeWindow.HTML) || (target_window == TypeWindow.OBJ3D);
    if (User3D.exporterMaterialLibrary && materialTarget) {
      writeSectionMaterial(f, target_window, the_filename);
    }
    if (target_window == TypeWindow.OBJ3D) {
      writeSectionGroupHeader(f, the_filename);
    }

    float[][] subFace = getCorners(Section_X, Section_Y, Section_Z, Section_RotX, Section_RotY, Section_RotZ, Section_U, Section_V, Section_RES1, Section_RES2);

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

  void writeSectionMaterial (int f, int target_window, String the_filename) {
    String TEXTURE_path = Folder_Export3D + "/" + Subfolder_exportMaps + the_filename;

    if (allSolarImpacts.displayImage) {
      println("Saving texture:", TEXTURE_path);
      this.SolarImpact[f][impactDisplayDay][WIN3D.impactTypeIndex].save(TEXTURE_path);
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

  void writeSectionGroupHeader (int f, String the_filename) {
    if (User3D.exporterMaintainPolygons == 1) {
      obj_lastGroupNumber += 1;
      objOutput.println("g Impact_" + nf(f, 0));
    }
    if (User3D.exporterMaterialLibrary) {
      objOutput.println("usemtl " + the_filename.replace('.', '_'));
    }
  }

  void renderSectionFace (int f, float[][] subFace, int target_window, int Section_RES1, int Section_RES2, int _turn) {
    if (target_window == TypeWindow.WIN3D) {
      WIN3D.graphics.beginShape();
      WIN3D.graphics.noStroke();
      WIN3D.graphics.noFill();
      if (allSolarImpacts.displayImage) {
        WIN3D.graphics.texture(this.SolarImpact[f][impactDisplayDay][WIN3D.impactTypeIndex]);
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
        WIN3D.graphics.vertex(x * overallScale * WIN3D.scale, -y * overallScale * WIN3D.scale, z * overallScale * WIN3D.scale, u * Section_RES1, v * Section_RES2);
      }

      if (target_window == TypeWindow.OBJ3D) {
        v = 1 - v; // mirroring the image
        if (_turn == 1) OBJprintVertex(x, y, z);
        if (_turn == 2) OBJprintVtexture(u, v, 0);
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

  void writeSectionObjFace () {
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

    if (User3D.exporterDoubleSided) {
      obj_lastFaceNumber += 1;
      objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n4_txt + "/" + m4_txt + " " + n3_txt + "/" + m3_txt + " " + n2_txt + "/" + m2_txt);
    }
  }

  void writeSectionHTML (float[][] subFace, String the_filename) {
    htmlOutput.println("\t\t\t\t<shape>");
    htmlOutput.println("\t\t\t\t\t<Appearance USE='" + the_filename + "'></Appearance>");
    htmlOutput.println("\t\t\t\t\t<IndexedFaceSet solid='false' coordIndex='0 1 2 3 -1'>"); // force two-sided

    htmlOutput.print("\t\t\t\t\t\t<Coordinate point='");
    for (int s = 1; s < subFace.length; s++) {
      if (s > 1) htmlOutput.print(",");
      htmlOutput.print(nf(subFace[s][0], 0, User3D.exporterPrecisionVertex) + " " +
                        nf(subFace[s][1], 0, User3D.exporterPrecisionVertex) + " " +
                        nf(subFace[s][2], 0, User3D.exporterPrecisionVertex));
    }
    htmlOutput.println("'></Coordinate>");

    htmlOutput.print("\t\t\t\t\t\t<TextureCoordinate point='");
    for (int s = 1; s < subFace.length; s++) {
      if (s > 1) htmlOutput.print(",");
      float u = subFace[s][3];
      float v = 1 - subFace[s][4]; // mirroring the image
      HTMLprintVtexture(u, v);
    }
    htmlOutput.println("'></TextureCoordinate>");

    htmlOutput.println("\t\t\t\t\t</IndexedFaceSet>");
    htmlOutput.println("\t\t\t\t</shape>");
  }

  // Corner layout for a section quad: {localX, localY, u, v}. Index 0 is the (unused
  // by draw()) center point kept for parity with the original 5-row array.
  final float[][] CORNER_LOCAL = {
    { 0,  0, 0.5, 0.5 },
    {-1, -1, 0, 1 },
    { 1, -1, 1, 1 },
    { 1,  1, 1, 0 },
    {-1,  1, 0, 0 }
  };

  // Every section is a flat quad in its own local X-Y plane (local Z is
  // its normal), rotated about its OWN center by Section_RotX/RotY/RotZ
  // (Euler angles, X-then-Y-then-Z - see arbitrarySection.pde), THEN
  // translated by Section_X/Y/Z. This used to be just the "type 0"
  // branch here, with 3 other hand-rolled single-angle types (each
  // folding Section_X/Y into the point BEFORE rotating, so they rotated
  // around the world origin rather than the section's own center
  // whenever X or Y wasn't 0) - those 3 are gone; every section is this
  // one shape now.
  float[][] getCorners (float Section_X, float Section_Y, float Section_Z, float Section_RotX, float Section_RotY, float Section_RotZ, float Section_U, float Section_V, int Section_RES1, int Section_RES2) {
    float[][] ImageVertex = new float[5][5];

    for (int q = 0; q < 5; q++) {
      float qx = CORNER_LOCAL[q][0];
      float qy = CORNER_LOCAL[q][1];
      float u  = CORNER_LOCAL[q][2];
      float v  = CORNER_LOCAL[q][3];

      float localX = qx * 0.5 * Section_U;
      float localY = qy * 0.5 * Section_V;
      float[] xyz = arbitrarySection_pointLocalToWorld(localX, localY, 0, Section_RotX, Section_RotY, Section_RotZ, Section_X, Section_Y, Section_Z);

      ImageVertex[q][0] = xyz[0];
      ImageVertex[q][1] = xyz[1];
      ImageVertex[q][2] = xyz[2];
      ImageVertex[q][3] = u;
      ImageVertex[q][4] = v;
    }

    return ImageVertex;
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

  float[] intersectFace (int f, float[] ray_pnt, float[] ray_dir) {
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

  public void to_XML (XML xml) {    {
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
        txt += nf(this.getRotX(i), 0, 4).replace(",", ".");
        txt += ",";
        txt += nf(this.getRotY(i), 0, 4).replace(",", ".");
        txt += ",";
        txt += nf(this.getRotZ(i), 0, 4).replace(",", ".");
        txt += ",";
        txt += nf(this.getU(i), 0, 4).replace(",", ".");
        txt += ",";
        txt += nf(this.getV(i), 0, 4).replace(",", ".");
        txt += ",";
        txt += nf(this.get_res1(i), 0);
        txt += ",";
        txt += nf(this.get_res2(i), 0);
        XML_setContent(child, txt);
      }
      XML_setBoolean(parent, "displayAll", this.displayAll);
    }
    {
      XML parent = xml.addChild(this.CLASS_STAMP + "SolidImpact");
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
      XML parent = xml.addChild(this.CLASS_STAMP + "SolarImpact");
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

  public void from_XML (XML xml) {    {
      XML parent = xml.getChild(this.CLASS_STAMP);
      int ni = XML_getInt(parent, "ni");
      this.f_data = new float[ni][8];
      this.i_data = new int[ni][2];
      this.num = ni;
      XML[] children = parent.getChildren("item");
      for (int i = 0; i < ni; i++) {
        String txt = XML_getContent(children[i]);
        String[] parts = split(txt, ",");
        this.setX(i, float(parts[0]));
        this.setY(i, float(parts[1]));
        this.setZ(i, float(parts[2]));
        this.setRotX(i, float(parts[3]));
        this.setRotY(i, float(parts[4]));
        this.setRotZ(i, float(parts[5]));
        this.setU(i, float(parts[6]));
        this.setV(i, float(parts[7]));
        this.set_res1(i, int(parts[8]));
        this.set_res2(i, int(parts[9]));
      }
      this.displayAll = XML_getBoolean(parent, "displayAll");
    }
    {
      XML parent = xml.getChild(this.CLASS_STAMP + "SolidImpact");
      int ni = XML_getInt(parent, "ni");
      this.SolidImpact = new PImage[ni];
      XML[] children = parent.getChildren("item");
      for (int i = 0; i < ni; i++) {
        String TEXTURE_path = XML_getContent(children[i]);
        this.SolidImpact[i] = createImage(2, 2, RGB); // empty and small
        if (!TEXTURE_path.equals("")) {
          println("Loading texture(" + i + "):", TEXTURE_path);
          // Only overwrites the placeholder above when loadImage() actually
          // returns something - a missing/moved/deleted cached preview PNG
          // (same risk as solarImpacts.pde's own shading PNGs - a project
          // opened somewhere its cache folder isn't, or a cache file since
          // cleaned up) used to silently clobber that placeholder with null
          // instead, which this.draw()'s WIN3D.graphics.texture(this.
          // SolidImpact[f]) a bit further down throws a
          // NullPointerException on the moment this section is drawn.
          PImage loaded = loadImage(TEXTURE_path);
          if (loaded != null) this.SolidImpact[i] = loaded;
          println("loaded!");
        }
      }
    }
    {
      XML parent = xml.getChild(this.CLASS_STAMP + "SolarImpact");
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
            if (!TEXTURE_path.equals("")) {
              println("Loading texture(" + i + "," + j + "," + k + "):", TEXTURE_path);
              // See SolidImpact's own loop above for why this check matters.
              PImage loaded = loadImage(TEXTURE_path);
              if (loaded != null) this.SolarImpact[i][j][k] = loaded;
              println("loaded!");
            }
          }
        }
      }
    }
  }
}
