class Sky3D {

  final static String CLASS_STAMP = "Sky3D";

  boolean displaySurface = true;

  int displayTessellation = 3;

  float radius = 50000; //10km:Troposphere 25km:Ozone layer 100km:Karman line.
  final float scale = 1.1; // to avoid the low res inset mesh intersect with other objects

  int activeColorscaleIndex = 18; //-1; //7; //8;
  int activeColorscaleDirection = 1; //-1;
  float activeColorscaleFactor = 0.5; //1; //0.25;
  int passiveColorscaleIndex = 18;
  int passiveColorscaleDirection = -1;
  float passiveColorscaleFactor = 0.25;

  // --- WIN3D retained-mode cache -------------------------------------------
  // The existing cachedSubFacesByFace below already avoids re-subdividing
  // the dome's geometry every frame, but drawWIN3D() still re-issued every
  // face/subFace to WIN3D.graphics as a fresh beginShape()/vertex()/
  // endShape() on every redraw - including every pure camera move, which
  // changes nothing here (position, tessellation, shading and palette are
  // all camera-independent). Same fix as Faces.pde/Model1Ds.pde: build a
  // PShape once and reuse it. winCacheGeneration is bumped at the end of
  // calculate_GlobalSolar_array.pde, since that's what actually changes
  // the per-vertex colors in shaded mode (SHADE.vertexRender_Global_Solar)
  // without going through any of the scalar knobs tracked below - the
  // same reason Faces.pde's own cache bumps the same kind of counter
  // there. Palette/shading-mode knobs are scattered across ValueModifier.
  // pde/UI_rollout.pde the same way Faces.pde's were, so PAL_type/
  // direction/multiplier (already resolved by activePalette() before
  // drawWIN3D() is even called) are compared directly instead of chasing
  // every place impactTypeIndex or the colorscale fields above can change.
  int winCacheGeneration = 0;

  PShape win3DCache = null;
  int win3DCache_builtGeneration = -1;
  int win3DCache_shadingMode = -1;
  int win3DCache_displayTessellation = -1;
  float win3DCache_radius = Float.NaN;
  int win3DCache_PAL_type = -1;
  int win3DCache_PAL_direction = 0;
  float win3DCache_PAL_multiplier = -1;
  int win3DCache_impactDisplayDay = Integer.MIN_VALUE;

  // Only matters for cacheWriteDomeFlat() (below) - the shaded branch
  // (SHADE.vertexRender_Global_Solar) already derives its per-vertex
  // colors from the actual sun position via calculate_GlobalSolar_array.
  // pde's own recompute, which bumps winCacheGeneration above. The flat
  // branch has no such trigger of its own, so sunIsBelowHorizon() (below)
  // has to be part of this cache's own key too, or switching from day to
  // night (or back) via Alt+arrow/the command line would leave the dome
  // showing the wrong flat color until something else happened to
  // invalidate the cache for an unrelated reason.
  boolean win3DCache_sunIsBelowHorizon = false;

  boolean win3DCache_isValid (int PAL_type, int PAL_direction, float PAL_multiplier) {
    return this.win3DCache != null &&
      this.win3DCache_builtGeneration     == this.winCacheGeneration &&
      this.win3DCache_shadingMode         == WIN3D.shadingMode &&
      this.win3DCache_displayTessellation == this.displayTessellation &&
      this.win3DCache_radius              == this.radius &&
      this.win3DCache_PAL_type            == PAL_type &&
      this.win3DCache_PAL_direction       == PAL_direction &&
      this.win3DCache_PAL_multiplier      == PAL_multiplier &&
      this.win3DCache_impactDisplayDay    == impactDisplayDay &&
      this.win3DCache_sunIsBelowHorizon   == this.sunIsBelowHorizon();
  }

  void win3DCache_recordState (int PAL_type, int PAL_direction, float PAL_multiplier) {
    this.win3DCache_builtGeneration     = this.winCacheGeneration;
    this.win3DCache_shadingMode         = WIN3D.shadingMode;
    this.win3DCache_displayTessellation = this.displayTessellation;
    this.win3DCache_radius              = this.radius;
    this.win3DCache_PAL_type            = PAL_type;
    this.win3DCache_PAL_direction       = PAL_direction;
    this.win3DCache_PAL_multiplier      = PAL_multiplier;
    this.win3DCache_impactDisplayDay    = impactDisplayDay;
    this.win3DCache_sunIsBelowHorizon   = this.sunIsBelowHorizon();
  }

  // Whether the Sun is at or below the horizon right now - same
  // SHADE_DATE_ANGLE/SHADE_HOUR_ANGLE this class's own sibling Sun3D.pde
  // already uses for the live view's actual sun position (its own SunR),
  // and the same <= 0 threshold ShadeViewport.pde's own sunIsBelowHorizon
  // uses for the shaded-viewport preview. A small, cheap call (funcs.
  // SunPosition, not the heavier SunPositionRadiation) - fine to call
  // from all three of its own call sites below rather than caching the
  // result in a local, since none of them share a parameter chain simple
  // enough to just pass it through.
  boolean sunIsBelowHorizon () {
    float[] SunR = funcs.SunPosition(STATION.getLatitude(), SHADE_DATE_ANGLE, SHADE_HOUR_ANGLE);
    return SunR[3] <= 0;
  }

  float inclinationStep;
  float orientationStep;
  int inclinationCount;
  int orientationCount;

  float calculatedResolution = 2.5; //1, 2.5, 5

  boolean shouldDraw (int target_window) {
    if (!this.displaySurface) return false;
    if (target_window == TypeWindow.STUDY) return false;
    if (target_window == TypeWindow.WORLD) return false;
    return true;
  }

  float[] activePalette () {
    int type = 0;
    int direction = 1;
    float multiplier = 1;
    if (WIN3D.impactTypeIndex == Impact_ACTIVE) {
      type = this.activeColorscaleIndex;
      direction = this.activeColorscaleDirection;
      multiplier = this.activeColorscaleFactor;
    }
    if (WIN3D.impactTypeIndex == Impact_PASSIVE) {
      type = this.passiveColorscaleIndex;
      direction = this.passiveColorscaleDirection;
      multiplier = this.passiveColorscaleFactor;
    }
    return new float[] { type, direction, multiplier };
  }

  void draw (int target_window) {
    if (!shouldDraw(target_window)) return;

    float[] palette = activePalette();
    int PAL_type = int(palette[0]);
    int PAL_direction = int(palette[1]);
    float PAL_multiplier = palette[2];

    if (target_window == TypeWindow.OBJ3D) {
      drawOBJ(PAL_type, PAL_direction, PAL_multiplier);
    }
    if (target_window == TypeWindow.WIN3D) {
      drawWIN3D(PAL_type, PAL_direction, PAL_multiplier);
    }
  }

  void drawOBJ (int PAL_type, int PAL_direction, float PAL_multiplier) {
    boolean shaded = (WIN3D.shadingMode == SHADE.Global_Solar) || (WIN3D.shadingMode == SHADE.Vertex_Solar);
    if (!shaded) return; // sky isn't exported to OBJ except under solar shading

    String the_filename = "";
    if (User3D.exporterMaterialLibrary) {
      the_filename = "skyPatternPalette.bmp";
      String texturePath = Folder_Export3D + "/" + Subfolder_exportMaps + the_filename;
      writeSkyPatternMaterial(PAL_type, the_filename, texturePath);
    }

    obj_lastGroupNumber += 1;
    objOutput.println("g skyPattern");
    if (User3D.exporterMaterialLibrary) {
      objOutput.println("usemtl " + the_filename.replace('.', '_'));
    }

    num_vertices_added = 0;

    for (int _turn = 1; _turn < 4; _turn++) {
      for (int f = 0; f < skyFaces.length; f++) {
        float[][][] subFaces = getTessellatedSubFaces(f, this.displayTessellation);
        for (int n = 0; n < subFaces.length; n++) {
          writeFaceOBJ(subFaces[n], _turn, PAL_type, PAL_direction, PAL_multiplier);
        }
      }
    }

    obj_lastVertexNumber += num_vertices_added;
    obj_lastVtextureNumber += num_vertices_added;
  }

  void writeSkyPatternMaterial (int PAL_type, String filename, String texturePath) {
    println("Saving texture:", texturePath);

    int RES1 = User3D.exporterColorscaleResolution;
    int RES2 = User3D.exporterColorscaleResolution / 16;
    PImage palette_Texture = createImage(RES1, RES2, ARGB);
    palette_Texture.loadPixels();
    for (int np = 0; np < (RES1 * RES2); np++) {
      int Image_X = np % RES1;
      float val = (Image_X / (0.5 * RES1)) - 1;
      float u = 0.5 + val;
      if (WIN3D.impactTypeIndex == Impact_ACTIVE) u = 0.5 + 0.5 * val;
      float[] COL = PAINT.getColorStyle(PAL_type, u);
      palette_Texture.pixels[np] = color(COL[1], COL[2], COL[3], COL[0]);
    }
    palette_Texture.updatePixels();
    palette_Texture.save(texturePath);

    String matName = filename.replace('.', '_');
    mtlOutput.println("newmtl " + matName);
    mtlOutput.println("\tilum 2");                    // 0:Color+Ambient off, 1:Color+Ambient on, 2:Highlight on, etc.
    mtlOutput.println("\tKa 1.000 1.000 1.000");      // ambient
    mtlOutput.println("\tKd 1.000 1.000 1.000");      // diffuse
    mtlOutput.println("\tKs 0.000 0.000 0.000");      // specular
    mtlOutput.println("\tNs 10.00");                  // 0-1000 specular exponent
    mtlOutput.println("\tNi 1.500");                  // 0.001-10 (glass:1.5) index of refraction
    mtlOutput.println("\td 1.000");                   // 0-1 transparency (d = 1 - Tr)
    mtlOutput.println("\tTr 1.000");                  // 0-1 transparency
    mtlOutput.println("\tTf 1.000 1.000 1.000");      // transmission filter
    mtlOutput.println("\tmap_Kd " + Subfolder_exportMaps + filename); // diffuse map
  }

  void writeFaceOBJ (float[][] subFace, int _turn, int PAL_type, int PAL_direction, float PAL_multiplier) {
    for (int s = 0; s < subFace.length; s++) {
      int s_next = (s + 1) % subFace.length;
      int s_prev = (s + subFace.length - 1) % subFace.length;

      float x = subFace[s][0] * this.radius * this.scale * WIN3D.scale;
      float y = subFace[s][1] * this.radius * this.scale * WIN3D.scale;
      float z = subFace[s][2] * this.radius * this.scale * WIN3D.scale;

      float u = SHADE.vertexU_Global_Solar(subFace[s], subFace[s_prev], subFace[s_next], PAL_type, PAL_direction, PAL_multiplier);

      if (_turn == 1) {
        OBJprintVertex(x, y, z);
      }
      if (_turn == 2) {
        float u1 = 0.5 * (u + 0.5);
        boolean solarShade = (WIN3D.shadingMode == SHADE.Global_Solar) || (WIN3D.shadingMode == SHADE.Vertex_Solar);
        if (solarShade && (WIN3D.impactTypeIndex == Impact_ACTIVE)) u1 = u;
        u1 = constrain(u1, 0.001, 0.999);
        OBJprintVtexture(u1, 0.5, 0);
      }
      if (_turn == 3) {
        num_vertices_added += 1;
      }
    }

    if (_turn == 3) {
      writeSkyPatternObjFace();
    }
  }

  void writeSkyPatternObjFace () {
    String n1_txt = nf(obj_lastVertexNumber + num_vertices_added - 3, 0);
    String n2_txt = nf(obj_lastVertexNumber + num_vertices_added - 2, 0);
    String n3_txt = nf(obj_lastVertexNumber + num_vertices_added - 1, 0);
    String n4_txt = nf(obj_lastVertexNumber + num_vertices_added - 0, 0);

    String m1_txt = nf(obj_lastVtextureNumber + num_vertices_added - 3, 0);
    String m2_txt = nf(obj_lastVtextureNumber + num_vertices_added - 2, 0);
    String m3_txt = nf(obj_lastVtextureNumber + num_vertices_added - 1, 0);
    String m4_txt = nf(obj_lastVtextureNumber + num_vertices_added - 0, 0);

    objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n4_txt + "/" + m4_txt + " " + n3_txt + "/" + m3_txt + " " + n2_txt + "/" + m2_txt);

    if (User3D.exporterDoubleSided) {
      obj_lastFaceNumber += 1;
      objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n2_txt + "/" + m2_txt + " " + n3_txt + "/" + m3_txt + " " + n4_txt + "/" + m4_txt);
    }
  }

  void drawWIN3D (int PAL_type, int PAL_direction, float PAL_multiplier) {
    if (!this.win3DCache_isValid(PAL_type, PAL_direction, PAL_multiplier)) {
      this.win3DCache = this.build_win3DCache(PAL_type, PAL_direction, PAL_multiplier);
      this.win3DCache_recordState(PAL_type, PAL_direction, PAL_multiplier);
    }

    WIN3D.graphics.shape(this.win3DCache);
  }

  // Rebuilds the cached dome. Same two branches, same math and same
  // per-vertex SHADE.vertexRender_Global_Solar() calls the old immediate-
  // mode writeFaceWIN3DShaded()/writeDomeFlat() used - just recorded into
  // PShape children of a GROUP instead of issued straight to
  // WIN3D.graphics. Only called from drawWIN3D() when win3DCache_isValid()
  // is false, never on a plain camera move.
  PShape build_win3DCache (int PAL_type, int PAL_direction, float PAL_multiplier) {

    // ONE shape, QUADS mode, for the whole dome - see Model1Ds.pde's own
    // fix for why: plain beginShape() is generic POLYGON mode, GLU-
    // tessellated and retained per shape. skyFaces is always 4-vertex
    // (built as new int[...][4] in Create3D.pde) and the tessellated
    // subfaces below are always exactly 4 vertices too, with no partial
    // quads in either branch, so QUADS mode is always valid.
    PShape shape = createShape();
    shape.beginShape(QUADS);
    shape.noStroke();

    boolean shaded = (WIN3D.shadingMode == SHADE.Global_Solar) || (WIN3D.shadingMode == SHADE.Vertex_Solar);

    if (shaded) {
      for (int f = 0; f < skyFaces.length; f++) {
        float[][][] subFaces = getTessellatedSubFaces(f, this.displayTessellation);
        for (int n = 0; n < subFaces.length; n++) {
          cacheWriteFaceWIN3DShaded(shape, subFaces[n], PAL_type, PAL_direction, PAL_multiplier);
        }
      }
    } else {
      cacheWriteDomeFlat(shape);
    }

    shape.endShape();
    return shape;
  }

  void cacheWriteFaceWIN3DShaded (PShape shape, float[][] subFace, int PAL_type, int PAL_direction, float PAL_multiplier) {
    for (int s = 0; s < subFace.length; s++) {
      int s_next = (s + 1) % subFace.length;
      int s_prev = (s + subFace.length - 1) % subFace.length;

      float[] COL = SHADE.vertexRender_Global_Solar(subFace[s], subFace[s_prev], subFace[s_next], PAL_type, PAL_direction, PAL_multiplier);
      shape.fill(COL[1], COL[2], COL[3], COL[0]);
      shape.vertex(subFace[s][0] * this.radius * this.scale * WIN3D.scale,
                    -subFace[s][1] * this.radius * this.scale * WIN3D.scale,
                    subFace[s][2] * this.radius * this.scale * WIN3D.scale);
    }
  }

  color flatColor = color(127, 191, 255);

  // Used instead of flatColor above whenever sunIsBelowHorizon() is true -
  // plain black, rather than some other shade of blue, since there's no
  // real "flat daytime sky color" left to approximate once direct
  // sunlight is gone.
  final color nightFlatColor = color(0);

  void cacheWriteDomeFlat (PShape shape) {
    color fillColor = this.sunIsBelowHorizon() ? this.nightFlatColor : this.flatColor;
    for (int f = 0; f < skyFaces.length; f++) {
      shape.fill(fillColor); // same flat color regardless of shade mode here
      for (int j = 0; j < skyFaces[f].length; j++) {
        int vNo = skyFaces[f][j];
        shape.vertex(skyVertices[vNo][0] * this.radius * this.scale * WIN3D.scale,
                      -skyVertices[vNo][1] * this.radius * this.scale * WIN3D.scale,
                      skyVertices[vNo][2] * this.radius * this.scale * WIN3D.scale);
      }
    }
  }

  // The tessellated sky-dome geometry (positions only) depends solely on
  // skyFaces/skyVertices/displayTessellation - never on the camera or on
  // sun/impact data. Previously it was rebuilt from scratch on every call
  // (i.e. every single rendered frame, including every frame of a mouse
  // drag or a held navigation key). Cache it per tessellation level instead.
  int cachedTessellationLevel = -1;
  float[][][][] cachedSubFacesByFace = null;

  // Call whenever skyFaces/skyVertices are rebuilt (e.g. re-creating the
  // sky dome geometry), since the cache above is otherwise only keyed on
  // the tessellation level and wouldn't notice the underlying mesh itself
  // changed.
  void invalidateTessellationCache () {
    this.cachedSubFacesByFace = null;
    this.winCacheGeneration++;
  }

  float[][][] getTessellatedSubFaces (int f, int tessellation) {
    if ((this.cachedSubFacesByFace == null) || (this.cachedTessellationLevel != tessellation)) {
      this.rebuildTessellationCache(tessellation);
    }

    return this.cachedSubFacesByFace[f];
  }

  void rebuildTessellationCache (int tessellation) {
    this.cachedSubFacesByFace = new float[skyFaces.length][][][];

    for (int f = 0; f < skyFaces.length; f++) {
      this.cachedSubFacesByFace[f] = computeTessellatedSubFaces(f, tessellation);
    }

    this.cachedTessellationLevel = tessellation;
  }

  float[][][] computeTessellatedSubFaces (int f, int tessellation) {
    int totalNumberOfSubs = 1;
    if (tessellation > 0) {
      totalNumberOfSubs = skyFaces[f].length * int(funcs.roundTo(pow(4, tessellation - 1), 1));
    }

    float[][] base_Vertices = new float[skyFaces[f].length][3];
    for (int j = 0; j < skyFaces[f].length; j++) {
      int vNo = skyFaces[f][j];
      base_Vertices[j][0] = skyVertices[vNo][0];
      base_Vertices[j][1] = skyVertices[vNo][1];
      base_Vertices[j][2] = skyVertices[vNo][2];
    }

    float[][][] subFaces = new float[totalNumberOfSubs][][];
    for (int n = 0; n < totalNumberOfSubs; n++) {
      float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);
      for (int j = 0; j < subFace.length; j++) {
        subFace[j] = funcs.vec3_unit(subFace[j]);
      }
      subFaces[n] = subFace;
    }

    return subFaces;
  }


  public void to_XML (XML xml) {    XML parent = xml.addChild(this.CLASS_STAMP);
    XML_setBoolean(parent, "displaySurface", this.displaySurface);
    XML_setInt(parent, "displayTessellation", this.displayTessellation);
    XML_setFloat(parent, "radius", this.radius);
    XML_setInt(parent, "activeColorscaleIndex", this.activeColorscaleIndex);
    XML_setInt(parent, "activeColorscaleDirection", this.activeColorscaleDirection);
    XML_setFloat(parent, "activeColorscaleFactor", this.activeColorscaleFactor);
    XML_setInt(parent, "passiveColorscaleIndex", this.passiveColorscaleIndex);
    XML_setInt(parent, "passiveColorscaleDirection", this.passiveColorscaleDirection);
    XML_setFloat(parent, "passiveColorscaleFactor", this.passiveColorscaleFactor);
    XML_setFloat(parent, "inclinationStep", this.inclinationStep);
    XML_setFloat(parent, "orientationStep", this.orientationStep);
    XML_setInt(parent, "inclinationCount", this.inclinationCount);
    XML_setInt(parent, "orientationCount", this.orientationCount);
    XML_setFloat(parent, "calculatedResolution", this.calculatedResolution);
  }

  public void from_XML (XML xml) {    XML parent = xml.getChild(this.CLASS_STAMP);
    this.displaySurface = XML_getBoolean(parent, "displaySurface");
    this.displayTessellation = XML_getInt(parent, "displayTessellation");
    this.radius = XML_getFloat(parent, "radius");
    this.activeColorscaleIndex = XML_getInt(parent, "activeColorscaleIndex");
    this.activeColorscaleDirection = XML_getInt(parent, "activeColorscaleDirection");
    this.activeColorscaleFactor = XML_getFloat(parent, "activeColorscaleFactor");
    this.passiveColorscaleIndex = XML_getInt(parent, "passiveColorscaleIndex");
    this.passiveColorscaleDirection = XML_getInt(parent, "passiveColorscaleDirection");
    this.passiveColorscaleFactor = XML_getFloat(parent, "passiveColorscaleFactor");
    this.inclinationStep = XML_getFloat(parent, "inclinationStep");
    this.orientationStep = XML_getFloat(parent, "orientationStep");
    this.inclinationCount = XML_getInt(parent, "inclinationCount");
    this.orientationCount = XML_getInt(parent, "orientationCount");
    this.calculatedResolution = XML_getFloat(parent, "calculatedResolution");
  }
}
