class Sections {

  final static String CLASS_STAMP = "section";

  Sections () {
    makeEmpty(0);
  }

  boolean displayAll = true;

  int num;
  // Columns: 0:X 1:Y 2:Z 3:rotX 4:rotY 5:rotZ 6:p1x 7:p1y 8:p2x 9:p2y
  // 10:p3x 11:p3y 12:p4x 13:p4y. Every section is the same single shape
  // now - a flat quad in its own local X-Y plane (local Z is its
  // normal), oriented by 3 Euler angles (rotX/rotY/rotZ, kept contiguous
  // here the way Solids' own f_data groups posX/Y/Z, powX/Y/Z, scaleX/
  // Y/Z and rotX/Y/Z - composed in that X-then-Y-then-Z order - see
  // arbitrarySection.pde) and then translated to X/Y/Z. There used to
  // be 3 other "types" with their own single-angle rotation and
  // translate-before-rotate math (rotateSectionCorner(), removed) -
  // dropped as part of collapsing every section onto this one (former
  // "type 0") representation.
  //
  // p1..p4 used to be a single symmetric sizeX/sizeY pair (a rectangle
  // centered on the local origin). They're now 4 independent local
  // (x,y) corners - p4 closing back to p1 makes a triangle (see
  // __SECTION__, extraCommands.pde) - used for two different things:
  // the axis-aligned BOUNDING BOX of these 4 points is what every
  // existing bake/render/shadow-cast/pick path still works with (see
  // sectionBoundingBox() below) - that's unchanged math, just no longer
  // assumed centered on the local origin - while the 4 points
  // themselves double as a mask polygon (sectionInsideMask() below)
  // that crops that bounding rectangle's own baked texture (alpha) and
  // picking test down to the section's real shape. A non-rectangular
  // section's true silhouette therefore only exists in its texture's
  // alpha channel and in picking - its exported/rendered GEOMETRY is
  // still the plain bounding rectangle.
  float[][] f_data = new float[0][14];
  int[][] i_data = new int[0][2];

  void makeEmpty (int n) {
    beginScene3DChange();

    this.f_data = new float[n][14];
    this.i_data = new int[n][2];
    this.SolidImpact = new PImage[n];
    this.SolarImpact = new PImage[n][(1 + STUDY.endDay - STUDY.startDay)][numberOfImpactVariations];
    this.num = n;

    if (Select3D != null) {
      Select3D.deselect_Sections();
    }
    endScene3DChange();
  }

  // Legacy convenience overloads - a plain symmetric rectangle (today's
  // only shape, before corners existed), expanded into the 4-corner
  // form below. Every existing caller that only ever wanted a rectangle
  // (clone3D.pde's own sibling that clones the real corners is the one
  // exception - see its own comment) keeps working unchanged through
  // these.
  void create (float x, float y, float z, float rotX, float sizeX, float sizeY, int resX, int resY) {
    this.create(x, y, z, rotX, 0, 0, sizeX, sizeY, resX, resY);
  }

  void create (float x, float y, float z, float rotX, float rotY, float rotZ, float sizeX, float sizeY, int resX, int resY) {
    float hx = 0.5 * sizeX;
    float hy = 0.5 * sizeY;
    this.create(x, y, z, rotX, rotY, rotZ, -hx, -hy, hx, -hy, hx, hy, -hx, hy, resX, resY);
  }

  void create (float x, float y, float z, float rotX, float rotY, float rotZ, float p1x, float p1y, float p2x, float p2y, float p3x, float p3y, float p4x, float p4y, int resX, int resY) {
    int[][] Temp_i_data = { { resX, resY } };
    this.i_data = (int[][]) concat(this.i_data, Temp_i_data);

    float[][] Temp_f_data = { { x, y, z, rotX, rotY, rotZ, p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y } };
    this.f_data = (float[][]) concat(this.f_data, Temp_f_data);

    PImage[] Temp_SolidImpact = { createImage(resX, resY, ARGB) };
    this.SolidImpact = (PImage[]) concat(this.SolidImpact, Temp_SolidImpact);

    PImage[][][] Temp_SolarImpact = new PImage[1][(1 + STUDY.endDay - STUDY.startDay)][numberOfImpactVariations];
    for (int j = STUDY.startDay; j <= STUDY.endDay; j++) {
      for (int q = 0; q < numberOfImpactVariations; q++) {
        Temp_SolarImpact[0][j][q] = createImage(2, 2, ARGB); // empty and small
      }
    }
    this.SolarImpact = (PImage[][][]) concat(this.SolarImpact, Temp_SolarImpact);

    this.num += 1;
  }

  int get_resX (int n) { return this.i_data[n][0]; }
  int get_resY (int n) { return this.i_data[n][1]; }
  void set_resX (int n, int t) { this.i_data[n][0] = t; }
  void set_resY (int n, int t) { this.i_data[n][1] = t; }

  float getX (int n) { return this.f_data[n][0]; } // offsetX
  float getY (int n) { return this.f_data[n][1]; } // offsetY
  float getZ (int n) { return this.f_data[n][2]; } // elevation
  float getRotX (int n) { return this.f_data[n][3]; }
  float getRotY (int n) { return this.f_data[n][4]; }
  float getRotZ (int n) { return this.f_data[n][5]; }
  float getP1X (int n) { return this.f_data[n][6]; }
  float getP1Y (int n) { return this.f_data[n][7]; }
  float getP2X (int n) { return this.f_data[n][8]; }
  float getP2Y (int n) { return this.f_data[n][9]; }
  float getP3X (int n) { return this.f_data[n][10]; }
  float getP3Y (int n) { return this.f_data[n][11]; }
  float getP4X (int n) { return this.f_data[n][12]; }
  float getP4Y (int n) { return this.f_data[n][13]; }
  void setX (int n, float f) { this.f_data[n][0] = f; }
  void setY (int n, float f) { this.f_data[n][1] = f; }
  void setZ (int n, float f) { this.f_data[n][2] = f; }
  void setRotX (int n, float f) { this.f_data[n][3] = f; }
  void setRotY (int n, float f) { this.f_data[n][4] = f; }
  void setRotZ (int n, float f) { this.f_data[n][5] = f; }
  void setP1X (int n, float f) { this.f_data[n][6] = f; }
  void setP1Y (int n, float f) { this.f_data[n][7] = f; }
  void setP2X (int n, float f) { this.f_data[n][8] = f; }
  void setP2Y (int n, float f) { this.f_data[n][9] = f; }
  void setP3X (int n, float f) { this.f_data[n][10] = f; }
  void setP3Y (int n, float f) { this.f_data[n][11] = f; }
  void setP4X (int n, float f) { this.f_data[n][12] = f; }
  void setP4Y (int n, float f) { this.f_data[n][13] = f; }

  // Derived (not stored) - the axis-aligned bounding box of this
  // section's own 4 local corners, read through getP1X.../getP4Y so
  // these always reflect whatever's actually stored. Any caller that
  // just wants "how big is this section" (scale3D.pde used to read a
  // stored sizeX/sizeY field directly; it now gets this instead).
  float getSizeX (int n) { return sectionBoundingBox(getP1X(n), getP1Y(n), getP2X(n), getP2Y(n), getP3X(n), getP3Y(n), getP4X(n), getP4Y(n))[2]; }
  float getSizeY (int n) { return sectionBoundingBox(getP1X(n), getP1Y(n), getP2X(n), getP2Y(n), getP3X(n), getP3Y(n), getP4X(n), getP4Y(n))[3]; }

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
          this.SolarImpact[i][j][q] = createImage(2, 2, ARGB); // empty and small
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
    int Section_ResX = this.get_resX(f);
    int Section_ResY = this.get_resY(f);

    String the_filename = "Impact_" + nf(f, 0) + ".bmp";

    boolean materialTarget = (target_window == TypeWindow.HTML) || (target_window == TypeWindow.OBJ3D);
    if (User3D.exporterMaterialLibrary && materialTarget) {
      writeSectionMaterial(f, target_window, the_filename);
    }
    if (target_window == TypeWindow.OBJ3D) {
      writeSectionGroupHeader(f, the_filename);
    }

    float[][] subFace = getCorners(Section_X, Section_Y, Section_Z, Section_RotX, Section_RotY, Section_RotZ,
      this.getP1X(f), this.getP1Y(f), this.getP2X(f), this.getP2Y(f), this.getP3X(f), this.getP3Y(f), this.getP4X(f), this.getP4Y(f),
      Section_ResX, Section_ResY);

    num_vertices_added = 0;
    int end_turn = (target_window == TypeWindow.OBJ3D) ? 3 : 1;
    for (int _turn = 1; _turn <= end_turn; _turn++) {
      renderSectionFace(f, subFace, target_window, Section_ResX, Section_ResY, _turn);
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

  void renderSectionFace (int f, float[][] subFace, int target_window, int Section_ResX, int Section_ResY, int _turn) {
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
        WIN3D.graphics.vertex(x * overallScale * WIN3D.scale, -y * overallScale * WIN3D.scale, z * overallScale * WIN3D.scale, u * Section_ResX, v * Section_ResY);
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
  float[][] getCorners (float Section_X, float Section_Y, float Section_Z, float Section_RotX, float Section_RotY, float Section_RotZ, float Section_P1X, float Section_P1Y, float Section_P2X, float Section_P2Y, float Section_P3X, float Section_P3Y, float Section_P4X, float Section_P4Y, int Section_ResX, int Section_ResY) {
    float[] box = sectionBoundingBox(Section_P1X, Section_P1Y, Section_P2X, Section_P2Y, Section_P3X, Section_P3Y, Section_P4X, Section_P4Y);
    float centerX = box[0];
    float centerY = box[1];
    float sizeX = box[2];
    float sizeY = box[3];

    float[][] ImageVertex = new float[5][5];

    for (int q = 0; q < 5; q++) {
      float qx = CORNER_LOCAL[q][0];
      float qy = CORNER_LOCAL[q][1];
      float u  = CORNER_LOCAL[q][2];
      float v  = CORNER_LOCAL[q][3];

      float localX = centerX + qx * 0.5 * sizeX;
      float localY = centerY + qy * 0.5 * sizeY;
      float[] xyz = arbitrarySection_pointLocalToWorld(localX, localY, 0, Section_RotX, Section_RotY, Section_RotZ, Section_X, Section_Y, Section_Z);

      ImageVertex[q][0] = xyz[0];
      ImageVertex[q][1] = xyz[1];
      ImageVertex[q][2] = xyz[2];
      ImageVertex[q][3] = u;
      ImageVertex[q][4] = v;
    }

    return ImageVertex;
  }

  // Legacy convenience overload - same symmetric-rectangle expansion as
  // the matching create() overload above, for callers (select3D.pde,
  // mouseClicked.pde's computeSectionParams) that only ever build or
  // query a plain rectangle and have no mask/crop of their own to
  // express.
  float[][] getCorners (float Section_X, float Section_Y, float Section_Z, float Section_RotX, float Section_RotY, float Section_RotZ, float Section_SizeX, float Section_SizeY, int Section_ResX, int Section_ResY) {
    float hx = 0.5 * Section_SizeX;
    float hy = 0.5 * Section_SizeY;
    return getCorners(Section_X, Section_Y, Section_Z, Section_RotX, Section_RotY, Section_RotZ, -hx, -hy, hx, -hy, hx, hy, -hx, hy, Section_ResX, Section_ResY);
  }

  // Axis-aligned bounding box of 4 local (x,y) corners - {centerX,
  // centerY, sizeX, sizeY}. This is the rectangle getCorners() above,
  // and every existing bake/render/shadow-cast/pick path that calls it,
  // actually builds - see f_data's own comment above for why that's a
  // different thing from the 4 points themselves.
  float[] sectionBoundingBox (float p1x, float p1y, float p2x, float p2y, float p3x, float p3y, float p4x, float p4y) {
    float minX = min(min(p1x, p2x), min(p3x, p4x));
    float maxX = max(max(p1x, p2x), max(p3x, p4x));
    float minY = min(min(p1y, p2y), min(p3y, p4y));
    float maxY = max(max(p1y, p2y), max(p3y, p4y));
    return new float[] { 0.5 * (minX + maxX), 0.5 * (minY + maxY), maxX - minX, maxY - minY };
  }

  // Standard even-odd ray-casting point-in-polygon test against this
  // section's own 4 local corners (p4==p1 - the default when a command
  // omits p4x/p4y, see __SECTION__ - closes a triangle back to its
  // first point; a zero-length edge like that contributes no crossing,
  // so it needs no special case here). localX/localY must already be
  // in the section's own local, unrotated, untranslated plane - the
  // same frame sectionBoundingBox()/getCorners() build their rectangle
  // in.
  boolean sectionInsideMask (float localX, float localY, float p1x, float p1y, float p2x, float p2y, float p3x, float p3y, float p4x, float p4y) {
    float[] xs = { p1x, p2x, p3x, p4x };
    float[] ys = { p1y, p2y, p3y, p4y };
    boolean inside = false;
    for (int i = 0, j = xs.length - 1; i < xs.length; j = i++) {
      if (((ys[i] > localY) != (ys[j] > localY)) &&
          (localX < (xs[j] - xs[i]) * (localY - ys[i]) / (ys[j] - ys[i]) + xs[i])) {
        inside = !inside;
      }
    }
    return inside;
  }

  // Zeroes alpha on every pixel of img (an ARGB section-texture image,
  // ResX x ResY) that falls outside the mask polygon p1..p4 - a single
  // post-process pass over the already-fully-baked image, reusing the
  // same 4 points sectionBoundingBox()/sectionInsideMask() use.
  // Deliberately NOT applied per-vertex inside castShadowsCurrentSection
  // .pde's own hot loop (that stays rasterizing the plain bounding
  // rectangle, unchanged, for performance - see f_data's own comment
  // above) - this is the one place the crop actually happens, called
  // once per baked image from solidImpacts.pde/solarImpacts.pde.
  //
  // (i/w - 0.5)*sizeX and -(j/h - 0.5)*sizeY mirror the exact same u/v
  // convention the baking loops' own funcs.bilinear(A, B, C, D, i /
  // ResX, 1 - j / ResY) calls use against this same axis-aligned
  // rectangle (CORNER_LOCAL's own u/v columns) - i increasing with
  // local X, j increasing as local Y DEcreases.
  void applySectionMask (PImage img, float p1x, float p1y, float p2x, float p2y, float p3x, float p3y, float p4x, float p4y) {
    float[] box = sectionBoundingBox(p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y);
    float centerX = box[0];
    float centerY = box[1];
    float sizeX = box[2];
    float sizeY = box[3];

    if ((sizeX <= 0) || (sizeY <= 0)) return; // degenerate box - nothing to crop

    int w = img.width;
    int h = img.height;
    img.loadPixels();
    for (int j = 0; j < h; j++) {
      float localY = centerY - sizeY * (j / float(h) - 0.5);
      for (int i = 0; i < w; i++) {
        float localX = centerX + sizeX * (i / float(w) - 0.5);
        if (!sectionInsideMask(localX, localY, p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y)) {
          img.pixels[i + j * w] = img.pixels[i + j * w] & 0x00FFFFFF; // alpha -> 0
        }
      }
    }
    img.updatePixels();
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

    // P lies within the section's own baked RECTANGLE (just checked
    // above) but may still be outside its real mask polygon - a
    // non-rectangular section's rectangle is bigger than its visible/
    // selectable shape (f_data's own comment above). Convert the hit
    // back into the section's own local plane and re-test there, the
    // same way the mask crop in solidImpacts.pde's/solarImpacts.pde's
    // baking loops does.
    // f_data has no row for f when Vertices/Faces were populated some
    // other way than the usual draw() pass (a few unit tests do this
    // directly) - nothing to mask against then, so just keep today's
    // plain-rectangle hit.
    if (f < this.f_data.length) {
      float[] local = arbitrarySection_pointWorldToLocal(X, Y, Z, this.getRotX(f), this.getRotY(f), this.getRotZ(f), this.getX(f), this.getY(f), this.getZ(f));
      if (!sectionInsideMask(local[0], local[1], this.getP1X(f), this.getP1Y(f), this.getP2X(f), this.getP2Y(f), this.getP3X(f), this.getP3Y(f), this.getP4X(f), this.getP4Y(f))) return miss;
    }

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
        txt += nf(this.getP1X(i), 0, 4).replace(",", ".");
        txt += ",";
        txt += nf(this.getP1Y(i), 0, 4).replace(",", ".");
        txt += ",";
        txt += nf(this.getP2X(i), 0, 4).replace(",", ".");
        txt += ",";
        txt += nf(this.getP2Y(i), 0, 4).replace(",", ".");
        txt += ",";
        txt += nf(this.getP3X(i), 0, 4).replace(",", ".");
        txt += ",";
        txt += nf(this.getP3Y(i), 0, 4).replace(",", ".");
        txt += ",";
        txt += nf(this.getP4X(i), 0, 4).replace(",", ".");
        txt += ",";
        txt += nf(this.getP4Y(i), 0, 4).replace(",", ".");
        txt += ",";
        txt += nf(this.get_resX(i), 0);
        txt += ",";
        txt += nf(this.get_resY(i), 0);
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
      this.f_data = new float[ni][14];
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
        this.setP1X(i, float(parts[6]));
        this.setP1Y(i, float(parts[7]));
        this.setP2X(i, float(parts[8]));
        this.setP2Y(i, float(parts[9]));
        this.setP3X(i, float(parts[10]));
        this.setP3Y(i, float(parts[11]));
        this.setP4X(i, float(parts[12]));
        this.setP4Y(i, float(parts[13]));
        this.set_resX(i, int(parts[14]));
        this.set_resY(i, int(parts[15]));
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
        this.SolidImpact[i] = createImage(2, 2, ARGB); // empty and small
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
            this.SolarImpact[i][j][k] = createImage(2, 2, ARGB); // empty and small
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
