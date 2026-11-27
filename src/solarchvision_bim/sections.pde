class Sections {

  final static String CLASS_STAMP = "section";

  Sections () {
    makeEmpty(0);
  }

  boolean displayAll = true;

  int num;
  // Columns: 0:X 1:Y 2:Z 3:rotX 4:rotY 5:rotZ. Every section is the
  // same single shape now - a flat n-gon in its own local X-Y plane
  // (local Z is its normal), oriented by 3 Euler angles (rotX/rotY/
  // rotZ, kept contiguous here the way Solids' own f_data groups
  // posX/Y/Z, powX/Y/Z, scaleX/Y/Z and rotX/Y/Z - composed in that
  // X-then-Y-then-Z order - see arbitrarySection.pde) and then
  // translated to X/Y/Z. There used to be 3 other "types" with their
  // own single-angle rotation and translate-before-rotate math
  // (rotateSectionCorner(), removed) - dropped as part of collapsing
  // every section onto this one (former "type 0") representation.
  float[][] f_data = new float[0][6];
  int[][] i_data = new int[0][2];

  // Each section's own n local (x,y) corners, flattened: {x0,y0,x1,y1,
  // ...,x(n-1),y(n-1)}, n>=3 - a variable-length row per section,
  // parallel to f_data/i_data the same way Faces.nodes (faces.pde) or
  // Polylines.nodes (polylines.pde) hold a variable-length array per
  // row instead of a fixed-width column range. These used to be a
  // single symmetric sizeX/sizeY pair (a rectangle centered on the
  // local origin), then a fixed 4-corner p1..p4 (with p4 closing back
  // to p1 to make a triangle). Now there's no fixed slot count at all -
  // any n>=3 is a genuine, exact n-gon, not an approximation. Used for
  // three things: the axis-aligned BOUNDING BOX of these n points still
  // drives the baking grid (sectionBoundingBox() below, unchanged math,
  // just no longer capped at exactly 4 points) - used by
  // castShadowsCurrentSection.pde to rasterize the SolidImpact/
  // SolarImpact texture over this section; the n points themselves
  // double as a mask polygon (sectionInsideMask() below) that crops
  // that baked texture's own alpha down to the section's real shape;
  // and, since getCorners() below now returns these n points directly
  // (not a 4-corner bounding-rectangle approximation), they're also the
  // section's actual rendered/exported/picked GEOMETRY - draw()'s own
  // Faces[f]/Vertices, the OBJ/HTML export, and intersectFace()'s own
  // picking all trace the real polygon, not its bounding box.
  float[][] corners = new float[0][];

  // Opaque, caller-defined JSON metadata, one entry per section - "" is
  // the canonical "nothing here" value (see extraParamsHelpers.pde's own
  // comment, shared with faces.pde/polylines.pde/groups.pde/model1Ds.pde/
  // model2Ds.pde/solids.pde/cameras.pde). Parsed lazily, only via
  // getExtraParamsObject()/setExtraParamsObject() below, never during
  // to_XML/from_XML or any structural resize.
  String[] extraParams = new String[0];

  void makeEmpty (int n) {
    beginScene3DChange();

    this.f_data = new float[n][6];
    this.i_data = new int[n][2];
    this.corners = new float[n][];
    this.extraParams = new String[n];
    java.util.Arrays.fill(this.extraParams, "");
    this.SolidImpact = new PImage[n];
    this.SolarImpact = new PImage[n][(1 + STUDY.endDay - STUDY.startDay)][numberOfImpactVariations];
    this.num = n;

    if (Select3D != null) {
      Select3D.deselect_Sections();
    }
    endScene3DChange();
  }

  // Legacy convenience overloads - a plain symmetric rectangle (today's
  // simplest shape), expanded into the 4-corner form below. Every
  // existing caller that only ever wanted a rectangle (clone3D.pde's
  // own sibling that clones the real corners is the one exception - see
  // its own comment) keeps working unchanged through these.
  void create (float x, float y, float z, float rotX, float sizeX, float sizeY, int resX, int resY) {
    this.create(x, y, z, rotX, 0, 0, sizeX, sizeY, resX, resY);
  }

  void create (float x, float y, float z, float rotX, float rotY, float rotZ, float sizeX, float sizeY, int resX, int resY) {
    float hx = 0.5 * sizeX;
    float hy = 0.5 * sizeY;
    this.create(x, y, z, rotX, rotY, rotZ, new float[] { -hx, -hy, hx, -hy, hx, hy, -hx, hy }, resX, resY);
  }

  // Primary create() - cornersXY is a flat {x0,y0,x1,y1,...} list of
  // n>=3 local corners (2*n values), in whatever winding order the
  // caller already has them (sectionInsideMask()'s point-in-polygon
  // test below doesn't care whether that's CW or CCW). A caller
  // building a triangle just passes 3 points (6 values) directly - no
  // more closing back to p1 needed (the old fixed-4-slot p1..p4 model's
  // "p4 defaults to p1" convention no longer applies - there's no fixed
  // slot to default).
  // New-from-scratch section - no source to inherit extraParams from, so
  // it gets this field's own "nothing here" default (""). Delegates to
  // the explicit-extraParams overload below.
  void create (float x, float y, float z, float rotX, float rotY, float rotZ, float[] cornersXY, int resX, int resY) {
    this.create(x, y, z, rotX, rotY, rotZ, cornersXY, resX, resY, "");
  }

  // Same as the no-extraParams overload above, but lets the caller supply
  // the new section's extraParams directly - e.g. clone3D.pde's
  // Sections() passes its source section's own extraParams straight
  // through here, instead of this blind-append default plus a later
  // setExtraParams() fixup. Still a blind append and does NOT self-heal/
  // guard itself against extraParams already being out of sync with
  // f_data/i_data/corners/num. A caller about to index extraParams at
  // [this.num] right after this call must call ensureExtraParamsLength()
  // itself first.
  void create (float x, float y, float z, float rotX, float rotY, float rotZ, float[] cornersXY, int resX, int resY, String extraParams) {
    int[][] Temp_i_data = { { resX, resY } };
    this.i_data = (int[][]) concat(this.i_data, Temp_i_data);

    float[][] Temp_f_data = { { x, y, z, rotX, rotY, rotZ } };
    this.f_data = (float[][]) concat(this.f_data, Temp_f_data);

    float[][] Temp_corners = { cornersXY };
    this.corners = (float[][]) concat(this.corners, Temp_corners);

    PImage[] Temp_SolidImpact = { createImage(resX, resY, ARGB) };
    this.SolidImpact = (PImage[]) concat(this.SolidImpact, Temp_SolidImpact);

    PImage[][][] Temp_SolarImpact = new PImage[1][(1 + STUDY.endDay - STUDY.startDay)][numberOfImpactVariations];
    for (int j = STUDY.startDay; j <= STUDY.endDay; j++) {
      for (int q = 0; q < numberOfImpactVariations; q++) {
        Temp_SolarImpact[0][j][q] = createImage(2, 2, ARGB); // empty and small
      }
    }
    this.SolarImpact = (PImage[][][]) concat(this.SolarImpact, Temp_SolarImpact);

    this.extraParams = (String[]) concat(this.extraParams, new String[]{ extraParams });

    this.num += 1;
  }

  String getExtraParams (int n) {
    if (this.extraParams == null || n < 0 || n >= this.extraParams.length) return "";
    return this.extraParams[n];
  }

  void setExtraParams (int n, String json) {
    this.extraParams[n] = json;
  }

  void ensureExtraParamsLength () {
    if (this.extraParams != null && this.extraParams.length == this.num) return;
    String[] resized = new String[this.num];
    int copyLen = (this.extraParams == null) ? 0 : min(this.extraParams.length, resized.length);
    for (int i = 0; i < copyLen; i++) resized[i] = this.extraParams[i];
    for (int i = copyLen; i < resized.length; i++) resized[i] = "";
    this.extraParams = resized;
  }

  JSONObject getExtraParamsObject (int n) {
    return extraParamsToJSONObject(this.getExtraParams(n));
  }

  void setExtraParamsObject (int n, JSONObject obj) {
    this.setExtraParams(n, extraParamsFromJSONObject(obj));
  }

  // Resets every section's own extraParams back to "" (its documented
  // default, above) regardless of selection - see faces.pde's own
  // identical method for the full reasoning.
  void stripAllExtraParams () {
    this.ensureExtraParamsLength();
    for (int n = 0; n < this.extraParams.length; n++) this.extraParams[n] = "";
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
  void setX (int n, float f) { this.f_data[n][0] = f; }
  void setY (int n, float f) { this.f_data[n][1] = f; }
  void setZ (int n, float f) { this.f_data[n][2] = f; }
  void setRotX (int n, float f) { this.f_data[n][3] = f; }
  void setRotY (int n, float f) { this.f_data[n][4] = f; }
  void setRotZ (int n, float f) { this.f_data[n][5] = f; }

  // Generic n-gon corner access - the only accessors that work for a
  // section with more than 4 corners. getCorners(n) returns the raw
  // flat {x0,y0,x1,y1,...} row directly (not a copy) for a caller that
  // wants the whole polygon at once (sectionBoundingBox()/
  // sectionInsideMask()/applySectionMask() below, clone3D.pde, scale3D
  // .pde, solidImpacts.pde/solarImpacts.pde's own per-section cache).
  int getNumCorners (int n) { return this.corners[n].length / 2; }
  float getCornerX (int n, int k) { return this.corners[n][2 * k]; }
  float getCornerY (int n, int k) { return this.corners[n][2 * k + 1]; }
  void setCornerX (int n, int k, float f) { this.corners[n][2 * k] = f; }
  void setCornerY (int n, int k, float f) { this.corners[n][2 * k + 1] = f; }
  float[] getCornersXY (int n) { return this.corners[n]; }
  void setCornersXY (int n, float[] cornersXY) { this.corners[n] = cornersXY; }

  // Derived (not stored) - the axis-aligned bounding box of this
  // section's own n local corners, read through getCornersXY() so this
  // always reflects whatever's actually stored. Any caller that just
  // wants "how big is this section" (scale3D.pde used to read a stored
  // sizeX/sizeY field directly; it now gets this instead).
  float getSizeX (int n) { return sectionBoundingBox(getCornersXY(n))[2]; }
  float getSizeY (int n) { return sectionBoundingBox(getCornersXY(n))[3]; }

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

  // Faces[f] is now a variable-length row of n real corner indices (n =
  // getNumCorners(f)), the same pattern Faces.nodes/Polylines.nodes
  // already use - not a fixed 4-wide quad row. This is what actually
  // makes a section's rendered/exported/picked GEOMETRY the real n-gon
  // (corners' own comment above): Vertices is sized to exactly the sum
  // of every section's own corner count, and each section's own slice
  // of it is found through vertexOffsetOf below, computed once here so
  // drawSection()/renderSectionFace() never need to re-derive it from
  // a stale f*4-style formula.
  void draw (int target_window) {
    this.Faces = new int[this.num][];
    int[] vertexOffsetOf = new int[this.num];
    int totalVerts = 0;
    for (int f = 0; f < this.num; f++) {
      int n = this.getNumCorners(f);
      this.Faces[f] = new int[n];
      vertexOffsetOf[f] = totalVerts;
      totalVerts += n;
    }
    this.Vertices = new float[totalVerts][3];

    if (!shouldDraw(target_window)) return;

    for (int f = 0; f < this.num; f++) {
      drawSection(f, target_window, vertexOffsetOf[f]);
    }
  }

  void drawSection (int f, int target_window, int vertexOffset) {
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
      this.getCornersXY(f), Section_ResX, Section_ResY);
    int n = subFace.length;

    num_vertices_added = 0;
    int end_turn = (target_window == TypeWindow.OBJ3D) ? 3 : 1;
    for (int _turn = 1; _turn <= end_turn; _turn++) {
      renderSectionFace(f, subFace, target_window, Section_ResX, Section_ResY, _turn, vertexOffset);
    }

    for (int k = 0; k < n; k++) {
      this.Faces[f][k] = vertexOffset + k;
    }

    if (target_window == TypeWindow.OBJ3D) {
      writeSectionObjFace(n);
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

  // q now runs over subFace's own n real corners (0..n-1) - no more
  // fixed q=1..4 - and this.Vertices is indexed through vertexOffset
  // (this section's own slice of the shared Vertices array, computed
  // once in draw() above) rather than a stale f*4-style formula.
  void renderSectionFace (int f, float[][] subFace, int target_window, int Section_ResX, int Section_ResY, int _turn, int vertexOffset) {
    int n = subFace.length;

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

    for (int q = 0; q < n; q++) {
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

      this.Vertices[vertexOffset + q][0] = x;
      this.Vertices[vertexOffset + q][1] = y;
      this.Vertices[vertexOffset + q][2] = z;
    }

    if (target_window == TypeWindow.WIN3D) {
      WIN3D.graphics.endShape(CLOSE);
    }
  }

  // Generalizes the old fixed 4-vertex "f n1/m1 n2/m2 n3/m3 n4/m4" line
  // to any n (mirrors the n-vertex OBJ face-writing pattern faces.pde's
  // own exporter already uses for Faces' own variable-length polygons).
  // By the time this runs, renderSectionFace()'s own _turn==3 pass has
  // already advanced obj_lastVertexNumber/obj_lastVtextureNumber by
  // exactly n (one per corner, in the same order subFace/this.Vertices
  // use) - so this section's own n vertex/texture-coordinate indices
  // are the last n numbers handed out, oldest first.
  void writeSectionObjFace (int n) {
    String[] n_txt = new String[n];
    String[] m_txt = new String[n];
    for (int s = 0; s < n; s++) {
      n_txt[s] = nf(obj_lastVertexNumber - (n - 1) + s, 0);
      m_txt[s] = nf(obj_lastVtextureNumber - (n - 1) + s, 0);
    }

    obj_lastFaceNumber += 1;
    String front = "f ";
    for (int s = 0; s < n; s++) {
      if (s > 0) front += " ";
      front += n_txt[s] + "/" + m_txt[s];
    }
    objOutput.println(front);

    if (User3D.exporterDoubleSided) {
      obj_lastFaceNumber += 1;
      // Same starting vertex, winding reversed - the n=4 case (v1 v4 v3
      // v2) this replaces was already this pattern, just hardcoded.
      String back = "f " + n_txt[0] + "/" + m_txt[0];
      for (int s = n - 1; s >= 1; s--) {
        back += " " + n_txt[s] + "/" + m_txt[s];
      }
      objOutput.println(back);
    }
  }

  // subFace now holds exactly n real corners (no more wasted center row
  // at index 0 - getCorners()'s own comment below) - coordIndex is
  // built to match, "0 1 ... n-1 -1", instead of the old hardcoded
  // 4-corner "0 1 2 3 -1".
  void writeSectionHTML (float[][] subFace, String the_filename) {
    int n = subFace.length;

    String coordIndex = "";
    for (int s = 0; s < n; s++) {
      if (s > 0) coordIndex += " ";
      coordIndex += nf(s, 0);
    }
    coordIndex += " -1";

    htmlOutput.println("\t\t\t\t<shape>");
    htmlOutput.println("\t\t\t\t\t<Appearance USE='" + the_filename + "'></Appearance>");
    htmlOutput.println("\t\t\t\t\t<IndexedFaceSet solid='false' coordIndex='" + coordIndex + "'>"); // force two-sided

    htmlOutput.print("\t\t\t\t\t\t<Coordinate point='");
    for (int s = 0; s < n; s++) {
      if (s > 0) htmlOutput.print(",");
      htmlOutput.print(nf(subFace[s][0], 0, User3D.exporterPrecisionVertex) + " " +
                        nf(subFace[s][1], 0, User3D.exporterPrecisionVertex) + " " +
                        nf(subFace[s][2], 0, User3D.exporterPrecisionVertex));
    }
    htmlOutput.println("'></Coordinate>");

    htmlOutput.print("\t\t\t\t\t\t<TextureCoordinate point='");
    for (int s = 0; s < n; s++) {
      if (s > 0) htmlOutput.print(",");
      float u = subFace[s][3];
      float v = 1 - subFace[s][4]; // mirroring the image
      HTMLprintVtexture(u, v);
    }
    htmlOutput.println("'></TextureCoordinate>");

    htmlOutput.println("\t\t\t\t\t</IndexedFaceSet>");
    htmlOutput.println("\t\t\t\t</shape>");
  }

  // Every section is a flat n-gon in its own local X-Y plane (local Z
  // is its normal), rotated about its OWN center by Section_RotX/RotY/
  // RotZ (Euler angles, X-then-Y-then-Z - see arbitrarySection.pde),
  // THEN translated by Section_X/Y/Z. This used to be just the "type 0"
  // branch here, with 3 other hand-rolled single-angle types (each
  // folding Section_X/Y into the point BEFORE rotating, so they rotated
  // around the world origin rather than the section's own center
  // whenever X or Y wasn't 0) - those 3 are gone; every section is this
  // one shape now.
  //
  // Returns exactly the n real corners of Section_CornersXY, one row
  // per corner, each {worldX, worldY, worldZ, u, v} - no more wasted
  // center row at index 0 (the old fixed-4-corner version returned 5
  // rows; draw()/the exporters never actually read that row). u/v are
  // normalized against the section's own bounding box - the same box
  // the baked SolidImpact/SolarImpact texture (ResX x ResY) is
  // rasterized over (castShadowsCurrentSection.pde) - using the exact
  // same (qx+1)/2, (1-qy)/2-style mapping the old CORNER_LOCAL table
  // hardcoded for a rectangle's own 4 corners, just generalized to any
  // local point. This is also what makes the section's rendered/
  // exported/picked GEOMETRY the real n-gon rather than its bounding
  // rectangle (corners' own comment above no longer applies - that
  // limitation is gone): every real corner gets its own vertex, so
  // WIN3D's beginShape()/endShape(CLOSE), the OBJ "f ..." line and the
  // HTML IndexedFaceSet all trace the polygon itself.
  float[][] getCorners (float Section_X, float Section_Y, float Section_Z, float Section_RotX, float Section_RotY, float Section_RotZ, float[] Section_CornersXY, int Section_ResX, int Section_ResY) {
    float[] box = sectionBoundingBox(Section_CornersXY);
    float centerX = box[0];
    float centerY = box[1];
    float sizeX = box[2];
    float sizeY = box[3];

    int n = Section_CornersXY.length / 2;
    float[][] WorldVertex = new float[n][5];

    for (int k = 0; k < n; k++) {
      float localX = Section_CornersXY[2 * k];
      float localY = Section_CornersXY[2 * k + 1];

      float u = (sizeX > 0) ? 0.5 + (localX - centerX) / sizeX : 0.5;
      float v = (sizeY > 0) ? 0.5 - (localY - centerY) / sizeY : 0.5;

      float[] xyz = arbitrarySection_pointLocalToWorld(localX, localY, 0, Section_RotX, Section_RotY, Section_RotZ, Section_X, Section_Y, Section_Z);

      WorldVertex[k][0] = xyz[0];
      WorldVertex[k][1] = xyz[1];
      WorldVertex[k][2] = xyz[2];
      WorldVertex[k][3] = u;
      WorldVertex[k][4] = v;
    }

    return WorldVertex;
  }

  // Legacy convenience overload - same symmetric-rectangle expansion as
  // the matching create() overload above, for callers (select3D.pde,
  // mouseClicked.pde's computeSectionParams) that only ever build or
  // query a plain rectangle and have no mask/crop of their own to
  // express.
  float[][] getCorners (float Section_X, float Section_Y, float Section_Z, float Section_RotX, float Section_RotY, float Section_RotZ, float Section_SizeX, float Section_SizeY, int Section_ResX, int Section_ResY) {
    float hx = 0.5 * Section_SizeX;
    float hy = 0.5 * Section_SizeY;
    return getCorners(Section_X, Section_Y, Section_Z, Section_RotX, Section_RotY, Section_RotZ, new float[] { -hx, -hy, hx, -hy, hx, hy, -hx, hy }, Section_ResX, Section_ResY);
  }

  // Always exactly the 4 corners of a section's own axis-aligned
  // bounding rectangle (sectionBoundingBox() below), regardless of how
  // many real corners Section_CornersXY actually has - the "axis-
  // aligned BOUNDING BOX... still drives the baking grid" case corners'
  // own comment above describes. solidImpacts.pde's own
  // calculate_Impact_CurrentSection() bilinear-interpolates its bake
  // across exactly these 4 corners (A,B,C,D order: -x-y, +x-y, +x+y,
  // -x+y), the same rectangle applySectionMask() then crops down to the
  // real n-gon afterward - unlike getCorners() above, which now returns
  // the n REAL corners themselves, for rendering/exporting/picking the
  // actual polygon rather than this rectangle.
  float[][] getBoundingRectangleCorners (float Section_X, float Section_Y, float Section_Z, float Section_RotX, float Section_RotY, float Section_RotZ, float[] Section_CornersXY, int Section_ResX, int Section_ResY) {
    float[] box = sectionBoundingBox(Section_CornersXY);
    float cx = box[0];
    float cy = box[1];
    float hx = 0.5 * box[2];
    float hy = 0.5 * box[3];
    // Centered on the bounding box's own center (cx, cy) - NOT the
    // local origin - so an asymmetric n-gon (its local origin need not
    // be its bounding box's center) still gets the right rectangle.
    return getCorners(Section_X, Section_Y, Section_Z, Section_RotX, Section_RotY, Section_RotZ,
      new float[] { cx - hx, cy - hy, cx + hx, cy - hy, cx + hx, cy + hy, cx - hx, cy + hy }, Section_ResX, Section_ResY);
  }

  // Axis-aligned bounding box of n local (x,y) corners (a flat
  // {x0,y0,x1,y1,...} array, n>=3) - {centerX, centerY, sizeX, sizeY}.
  // This is the rectangle getCorners() above, and every existing bake/
  // render/shadow-cast/pick path that calls it, actually builds - see
  // f_data's/corners' own comment above for why that's a different
  // thing from the n points themselves.
  float[] sectionBoundingBox (float[] cornersXY) {
    float minX = FLOAT_undefined;
    float maxX = -FLOAT_undefined;
    float minY = FLOAT_undefined;
    float maxY = -FLOAT_undefined;
    for (int k = 0; k < cornersXY.length / 2; k++) {
      float x = cornersXY[2 * k];
      float y = cornersXY[2 * k + 1];
      if (minX > x) minX = x;
      if (maxX < x) maxX = x;
      if (minY > y) minY = y;
      if (maxY < y) maxY = y;
    }
    return new float[] { 0.5 * (minX + maxX), 0.5 * (minY + maxY), maxX - minX, maxY - minY };
  }

  // Standard even-odd ray-casting point-in-polygon test against this
  // section's own n local corners (a flat {x0,y0,x1,y1,...} array,
  // n>=3 - any n, not just a triangle/quad). localX/localY must already
  // be in the section's own local, unrotated, untranslated plane - the
  // same frame sectionBoundingBox()/getCorners() build their rectangle
  // in.
  boolean sectionInsideMask (float localX, float localY, float[] cornersXY) {
    int n = cornersXY.length / 2;
    boolean inside = false;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      float xi = cornersXY[2 * i];
      float yi = cornersXY[2 * i + 1];
      float xj = cornersXY[2 * j];
      float yj = cornersXY[2 * j + 1];
      if (((yi > localY) != (yj > localY)) &&
          (localX < (xj - xi) * (localY - yi) / (yj - yi) + xi)) {
        inside = !inside;
      }
    }
    return inside;
  }

  // Zeroes alpha on every pixel of img (an ARGB section-texture image,
  // ResX x ResY) that falls outside the mask polygon (a flat
  // {x0,y0,x1,y1,...} array, n>=3) - a single post-process pass over
  // the already-fully-baked image, reusing the same points
  // sectionBoundingBox()/sectionInsideMask() use. Deliberately NOT
  // applied per-vertex inside castShadowsCurrentSection.pde's own hot
  // loop (that stays rasterizing the plain bounding rectangle,
  // unchanged, for performance - see f_data's/corners' own comment
  // above) - this is the one place the crop actually happens, called
  // once per baked image from solidImpacts.pde/solarImpacts.pde.
  //
  // (i/w - 0.5)*sizeX and -(j/h - 0.5)*sizeY mirror the exact same u/v
  // convention the baking loops' own funcs.bilinear(A, B, C, D, i /
  // ResX, 1 - j / ResY) calls use against this same axis-aligned
  // rectangle (CORNER_LOCAL's own u/v columns) - i increasing with
  // local X, j increasing as local Y DEcreases.
  void applySectionMask (PImage img, float[] cornersXY) {
    float[] box = sectionBoundingBox(cornersXY);
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
        if (!sectionInsideMask(localX, localY, cornersXY)) {
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

    // Faces[f]/Vertices now ARE the section's real n-gon (getCorners()'s
    // own comment above - this used to be a bounding-rectangle
    // approximation, checked with funcs.isInside_Rectangle(P, A, B, C)
    // and then re-tested against the real mask polygon in the section's
    // own local plane via f_data/corners). A single general point-in-
    // polygon test against the actual face vertices is now both
    // necessary and sufficient, and - unlike the old f_data-based mask
    // re-test - it works even when a caller builds Faces/Vertices
    // directly without an f_data/corners row of its own (a few unit
    // tests do this).
    if (!pointInsideFacePolygon(f, P, face_norm)) return miss;

    return new float[] { X, Y, Z, dist2intersect };
  }

  // General point-in-polygon test for section face f, done within the
  // face's own plane (face_norm is that plane's already-computed
  // normal). Builds a 2D (u, v) basis in the plane from the face's own
  // first edge, projects every one of the face's n real vertices (and
  // P, already known to lie on this same plane) into that basis, then
  // runs the same even-odd ray-cast sectionInsideMask() uses in a
  // section's own local frame - just generalized to the actual
  // Vertices/Faces ring instead of a stored corners row, so this works
  // for any n and needs no f_data/corners at all.
  boolean pointInsideFacePolygon (int f, float[] P, float[] face_norm) {
    int n = this.Faces[f].length;
    float[] origin = this.Vertices[this.Faces[f][0]];
    float[] u = funcs.vec3_diff(this.Vertices[this.Faces[f][1]], origin);
    float[] v = funcs.vec3_cross(face_norm, u);

    float[] projX = new float[n];
    float[] projY = new float[n];
    for (int k = 0; k < n; k++) {
      float[] rel = funcs.vec3_diff(this.Vertices[this.Faces[f][k]], origin);
      projX[k] = funcs.vec3_dot(rel, u);
      projY[k] = funcs.vec3_dot(rel, v);
    }

    float[] relP = funcs.vec3_diff(P, origin);
    float px = funcs.vec3_dot(relP, u);
    float py = funcs.vec3_dot(relP, v);

    boolean inside = false;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      if (((projY[i] > py) != (projY[j] > py)) &&
          (px < (projX[j] - projX[i]) * (py - projY[i]) / (projY[j] - projY[i]) + projX[i])) {
        inside = !inside;
      }
    }
    return inside;
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
        txt += nf(this.get_resX(i), 0);
        txt += ",";
        txt += nf(this.get_resY(i), 0);
        // n local corners (a flat {x0,y0,x1,y1,...} list, n>=3) - count
        // prefixed since, unlike every fixed field above, this one's
        // own length varies per section (f_data's/corners' own comment
        // above).
        int numCorners = this.getNumCorners(i);
        txt += ",";
        txt += nf(numCorners, 0);
        for (int k = 0; k < numCorners; k++) {
          txt += ",";
          txt += nf(this.getCornerX(i, k), 0, 4).replace(",", ".");
          txt += ",";
          txt += nf(this.getCornerY(i, k), 0, 4).replace(",", ".");
        }
        XML_setContent(child, txt);

        XML_setString(child, "extraParams", this.getExtraParams(i));
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
      this.f_data = new float[ni][6];
      this.i_data = new int[ni][2];
      this.corners = new float[ni][];
      this.extraParams = new String[ni];
      java.util.Arrays.fill(this.extraParams, "");
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
        this.set_resX(i, int(parts[6]));
        this.set_resY(i, int(parts[7]));

        int numCorners = int(parts[8]);
        float[] cornersXY = new float[2 * numCorners];
        for (int k = 0; k < numCorners; k++) {
          cornersXY[2 * k] = float(parts[9 + 2 * k]);
          cornersXY[2 * k + 1] = float(parts[9 + 2 * k + 1]);
        }
        this.corners[i] = cornersXY;

        // Falls back to "" (this field's own "nothing here" default) for
        // a save file written before extraParams existed at all - see
        // the 3-arg XML_getString() overload's own comment
        // (xmlHelpers.pde).
        this.setExtraParams(i, XML_getString(children[i], "extraParams", ""));
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
