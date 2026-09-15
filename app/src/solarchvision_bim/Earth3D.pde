class solarchvision_Earth3D {

  private final static String CLASS_STAMP = "Earth3D";

  private final static float LONGITUDE_SPAN = 360.0;
  private final static float LATITUDE_SPAN  = 180.0;
  private final static float BOUNDARY_SCALE = 0.001; // filenames encode boundaries in millidegrees

  float lat_step = 1; //0.1; //in degrees
  float lon_step  = 1; //0.1; //in degrees

  float clipRadiusDegrees = 10;

  boolean displaySurface = true;
  boolean displayTexture = true;

  PImage[] Map;
  float[][] BoundariesX;
  float[][] BoundariesY;

  String Path = BaseFolder + "/input/images/earth";
  String[] Filenames = sort(OPESYS.getFiles(this.Path));

  class FaceVertex {
    float x, y, z;
    float u, v;
  }

  void resize_images () {
    int n = this.Filenames.length;
    this.Map = new PImage [n];
    this.BoundariesX = new float [n][2];
    this.BoundariesY = new float [n][2];
  }

  void load_images () {
    for (int i = 0; i < this.Filenames.length; i++) {
      loadOneImage(i);
    }
  }

  private void loadOneImage (int i) {
    String MapFilename = this.Path + "/" + this.Filenames[i];
    String[] Parts = split(this.Filenames[i], '_');

    this.BoundariesX[i][0] = -float(Parts[1]) * BOUNDARY_SCALE;
    this.BoundariesY[i][0] =  float(Parts[2]) * BOUNDARY_SCALE;
    this.BoundariesX[i][1] = -float(Parts[3]) * BOUNDARY_SCALE;
    this.BoundariesY[i][1] =  float(Parts[4]) * BOUNDARY_SCALE;

    println("Loading:", MapFilename);
    this.Map[i] = loadImage(MapFilename);
  }

  private boolean shouldDraw (int target_window) {
    if (!this.displaySurface || !this.displayTexture) return false;
    if (target_window == TypeWindow.STUDY) return false;
    if (target_window == TypeWindow.WORLD) return false;
    return true;
  }

  private int currentMapIndex () {
    if (IMPACTS_displayDay < this.Map.length) return IMPACTS_displayDay;
    return 0;
  }

  private float clamp01 (float value) {
    if (value > 1) return 1;
    if (value < 0) return 0;
    return value;
  }

  // Prefer high-resolution "E" tiles from WORLD's local tile system
  // (input/images/worldmap) over the low-res whole-globe A/B images below,
  // since draw() only renders a small patch of the globe around the
  // station now (see the clip radius in draw()) - there's no need for
  // whole-globe coverage, and the "E" tiles are much more detailed per
  // degree. Falls back to A/B (see resize_images()/load_images() below)
  // for locations no "E" tile covers.
  //
  // The clip window can straddle more than one "E" tile (the station can
  // sit near a tile edge), so this doesn't just look up a single tile: it
  // uses one directly when it fully contains the clip window (best
  // quality, no resampling), or composites every overlapping tile into one
  // mosaic image otherwise - mirroring the overlap/crop math WORLD.pde's
  // own drawZoomedTiles() uses to composite neighboring tiles on screen.
  //
  // Cached and only rebuilt when the station's location actually changes,
  // since compositing a mosaic is comparatively expensive and draw() can
  // run every frame while navigating.
  private PImage cachedTextureImage = null;
  private float cachedTextureBx1, cachedTextureBx2, cachedTextureBy1, cachedTextureBy2;
  private String cachedTextureLabel = "";
  private String cachedTexturePath = ""; // "" means synthetic/composited - no single file to copy for export
  private String cachedTextureFilename = "";
  private float cachedStationLon = Float.NaN;
  private float cachedStationLat = Float.NaN;

  private void resolveTextureSource () {
    float stationLon = STATION.getLongitude();
    float stationLat = STATION.getLatitude();

    if ((this.cachedTextureImage != null) &&
        (abs(stationLon - this.cachedStationLon) < 0.0001) &&
        (abs(stationLat - this.cachedStationLat) < 0.0001)) {
      return; // still valid - station hasn't moved
    }

    IntList overlapping = new IntList();
    for (int i = 0; i < WORLD.numMaps; i++) {
      if (!WORLD.VIEW_Filenames[i].substring(0, 1).equals("E")) continue;

      float tLon1 = WORLD.VIEW_BoundariesX[i][0];
      float tLon2 = WORLD.VIEW_BoundariesX[i][1];
      float tLat1 = WORLD.VIEW_BoundariesY[i][0];
      float tLat2 = WORLD.VIEW_BoundariesY[i][1];

      boolean overlaps = (tLon2 > stationLon - this.clipRadiusDegrees) && (tLon1 < stationLon + this.clipRadiusDegrees) &&
                          (tLat2 > stationLat - this.clipRadiusDegrees) && (tLat1 < stationLat + this.clipRadiusDegrees);
      if (overlaps) overlapping.append(i);
    }

    if (overlapping.size() == 0) {
      useFallbackABTexture();
    } else if ((overlapping.size() == 1) && worldTileFullyCoversWindow(overlapping.get(0), stationLon, stationLat)) {
      useWorldTileDirectly(overlapping.get(0));
    } else {
      compositeWorldTiles(overlapping, stationLon, stationLat);
    }

    this.cachedStationLon = stationLon;
    this.cachedStationLat = stationLat;
  }

  private boolean worldTileFullyCoversWindow (int tileIndex, float stationLon, float stationLat) {
    return (WORLD.VIEW_BoundariesX[tileIndex][0] <= stationLon - this.clipRadiusDegrees) &&
           (WORLD.VIEW_BoundariesX[tileIndex][1] >= stationLon + this.clipRadiusDegrees) &&
           (WORLD.VIEW_BoundariesY[tileIndex][0] <= stationLat - this.clipRadiusDegrees) &&
           (WORLD.VIEW_BoundariesY[tileIndex][1] >= stationLat + this.clipRadiusDegrees);
  }

  private void useWorldTileDirectly (int tileIndex) {
    this.cachedTextureImage    = WORLD.getTileImage(tileIndex);
    this.cachedTextureBx1      = WORLD.VIEW_BoundariesX[tileIndex][0];
    this.cachedTextureBx2      = WORLD.VIEW_BoundariesX[tileIndex][1];
    this.cachedTextureBy1      = WORLD.VIEW_BoundariesY[tileIndex][0];
    this.cachedTextureBy2      = WORLD.VIEW_BoundariesY[tileIndex][1];
    this.cachedTexturePath     = WORLD.ViewFolder + "/" + WORLD.VIEW_Filenames[tileIndex];
    this.cachedTextureFilename = WORLD.VIEW_Filenames[tileIndex];
    this.cachedTextureLabel    = "EarthSphereE" + nf(tileIndex, 0);
  }

  private void useFallbackABTexture () {
    int n_Map = currentMapIndex();
    this.cachedTextureImage    = this.Map[n_Map];
    this.cachedTextureBx1      = this.BoundariesX[n_Map][0];
    this.cachedTextureBx2      = this.BoundariesX[n_Map][1];
    this.cachedTextureBy1      = this.BoundariesY[n_Map][0];
    this.cachedTextureBy2      = this.BoundariesY[n_Map][1];
    this.cachedTexturePath     = this.Path + "/" + this.Filenames[n_Map];
    this.cachedTextureFilename = this.Filenames[n_Map];
    this.cachedTextureLabel    = "EarthSphere" + nf(n_Map, 0);
  }

  // Composites every tile in `overlapping` into one square mosaic image
  // covering the clip window (clamped to the tiles' own combined extent,
  // same as WORLD.drawZoomedTiles() does, so the mosaic doesn't reserve
  // space for area with no image data at all). Points that still fall
  // outside that combined extent simply sample the mosaic's clamped edge
  // pixel (see clamp01() in buildSubFace()'s callers) rather than showing
  // a hard-edged gap.
  private void compositeWorldTiles (IntList overlapping, float stationLon, float stationLat) {

    float winLon1 = stationLon - this.clipRadiusDegrees;
    float winLon2 = stationLon + this.clipRadiusDegrees;
    float winLat1 = stationLat - this.clipRadiusDegrees;
    float winLat2 = stationLat + this.clipRadiusDegrees;

    float combinedLon1 = FLOAT_undefined;
    float combinedLon2 = -FLOAT_undefined;
    float combinedLat1 = FLOAT_undefined;
    float combinedLat2 = -FLOAT_undefined;

    for (int k = 0; k < overlapping.size(); k++) {
      int i = overlapping.get(k);
      combinedLon1 = min(combinedLon1, WORLD.VIEW_BoundariesX[i][0]);
      combinedLon2 = max(combinedLon2, WORLD.VIEW_BoundariesX[i][1]);
      combinedLat1 = min(combinedLat1, WORLD.VIEW_BoundariesY[i][0]);
      combinedLat2 = max(combinedLat2, WORLD.VIEW_BoundariesY[i][1]);
    }

    winLon1 = max(winLon1, combinedLon1);
    winLon2 = min(winLon2, combinedLon2);
    winLat1 = max(winLat1, combinedLat1);
    winLat2 = min(winLat2, combinedLat2);

    int outputSize = 1024;
    PGraphics buffer = createGraphics(outputSize, outputSize);
    buffer.beginDraw();
    buffer.background(0);

    for (int k = 0; k < overlapping.size(); k++) {
      int i = overlapping.get(k);

      PImage tileImage = WORLD.getTileImage(i);

      float tileLon1 = WORLD.VIEW_BoundariesX[i][0];
      float tileLon2 = WORLD.VIEW_BoundariesX[i][1];
      float tileLat1 = WORLD.VIEW_BoundariesY[i][0];
      float tileLat2 = WORLD.VIEW_BoundariesY[i][1];

      float overlapLon1 = max(tileLon1, winLon1);
      float overlapLon2 = min(tileLon2, winLon2);
      float overlapLat1 = max(tileLat1, winLat1);
      float overlapLat2 = min(tileLat2, winLat2);

      if ((overlapLon1 >= overlapLon2) || (overlapLat1 >= overlapLat2)) continue; // no overlap with this tile

      int u1 = int(tileImage.width  * (overlapLon1 - tileLon1) / (tileLon2 - tileLon1));
      int u2 = min(tileImage.width,  int(ceil(tileImage.width  * (overlapLon2 - tileLon1) / (tileLon2 - tileLon1))));
      int v1 = int(tileImage.height * (tileLat2 - overlapLat2) / (tileLat2 - tileLat1));
      int v2 = min(tileImage.height, int(ceil(tileImage.height * (tileLat2 - overlapLat1) / (tileLat2 - tileLat1))));

      float destX1 = outputSize * (overlapLon1 - winLon1) / (winLon2 - winLon1);
      float destX2 = outputSize * (overlapLon2 - winLon1) / (winLon2 - winLon1);
      float destY1 = outputSize * (winLat2 - overlapLat2) / (winLat2 - winLat1);
      float destY2 = outputSize * (winLat2 - overlapLat1) / (winLat2 - winLat1);

      buffer.image(tileImage, destX1, destY1, destX2 - destX1, destY2 - destY1, u1, v1, u2, v2);
    }

    buffer.endDraw();

    this.cachedTextureImage    = buffer.get();
    this.cachedTextureBx1      = winLon1;
    this.cachedTextureBx2      = winLon2;
    this.cachedTextureBy1      = winLat1;
    this.cachedTextureBy2      = winLat2;
    this.cachedTexturePath     = ""; // synthetic - writeTextureMap() saves cachedTextureImage directly
    this.cachedTextureFilename = "EarthSphereE_mosaic.jpg";
    this.cachedTextureLabel    = "EarthSphereEmosaic";
  }

  void draw (int target_window) {
    if (!shouldDraw(target_window)) return;

    resolveTextureSource();

    PImage textureImage    = this.cachedTextureImage;
    float bx1              = this.cachedTextureBx1;
    float bx2              = this.cachedTextureBx2;
    float by1              = this.cachedTextureBy1;
    float by2              = this.cachedTextureBy2;
    String texturePath     = this.cachedTexturePath;
    String textureFilename = this.cachedTextureFilename;
    String textureLabel    = this.cachedTextureLabel;

    float ScaleX  = (bx2 - bx1) / LONGITUDE_SPAN;
    float ScaleY  = (by2 - by1) / LATITUDE_SPAN;
    float CEN_lon = 0.5 * (bx1 + bx2);
    float CEN_lat = 0.5 * (by1 + by2);

    float r = FLOAT_r_Earth;

    if (target_window == TypeWindow.HTML || target_window == TypeWindow.OBJ3D) {
      writeMaterial(target_window, textureLabel, texturePath, textureFilename);
    }

    num_vertices_added = 0;

    int end_turn = (target_window == TypeWindow.OBJ3D) ? 3 : 1;

    // At the default resolution this grid is 180x360 = 64,800 quads. The
    // WIN3D path used to open a separate beginShape()/texture()/endShape()
    // for every single one of them - i.e. up to 64,800 texture-bind calls
    // per frame. Batch them into one shape instead: the whole sphere uses a
    // single texture image for the whole draw() call, so there's no need
    // to rebind it per quad.
    boolean isWin3D = (target_window == TypeWindow.WIN3D);

    if (isWin3D) beginWIN3DSphere(textureImage);

    float stationLon = STATION.getLongitude();
    float stationLat = STATION.getLatitude();

    for (int _turn = 1; _turn <= end_turn; _turn++) {
      int f = 0;
      for (float Alpha = 90; Alpha > -90; Alpha -= this.lat_step) {
        if(Alpha > stationLat + this.clipRadiusDegrees) continue;
        if(Alpha < stationLat - this.clipRadiusDegrees) continue;

        for (float Beta = 180; Beta > -180; Beta -= this.lon_step) {
          if(Beta > stationLon + this.clipRadiusDegrees) continue;
          if(Beta < stationLon - this.clipRadiusDegrees) continue;

          f += 1;
          FaceVertex[] subFace = buildSubFace(Alpha, Beta, r, CEN_lon, CEN_lat, ScaleX, ScaleY);

          if (isWin3D) {
            addFaceWIN3D(subFace, textureImage);
          } else {
            drawFace(target_window, subFace, textureLabel, f, _turn);
          }
        }
      }
    }

    if (isWin3D) endWIN3DSphere();
  }

  private void beginWIN3DSphere (PImage textureImage) {
    WIN3D.graphics.strokeWeight(1);
    WIN3D.graphics.noStroke();
    WIN3D.graphics.beginShape(QUADS);
    if (this.displayTexture) {
      WIN3D.graphics.texture(textureImage);
    }
  }

  private void addFaceWIN3D (FaceVertex[] subFace, PImage textureImage) {
    for (int s = 0; s < subFace.length; s++) {
      float u = clamp01(subFace[s].u);
      float v = clamp01(subFace[s].v);
      WIN3D.graphics.vertex(
        subFace[s].x * OBJECTS_scale * WIN3D.scale,
        -subFace[s].y * OBJECTS_scale * WIN3D.scale,
        subFace[s].z * OBJECTS_scale * WIN3D.scale,
        u * textureImage.width,
        v * textureImage.height
      );
    }
  }

  private void endWIN3DSphere () {
    WIN3D.graphics.endShape();
  }

  private void writeMaterial (int target_window, String textureLabel, String texturePath, String textureFilename) {
    if (User3D.export_MaterialLibrary) {
      if (target_window == TypeWindow.HTML) {
        htmlOutput.println("\t\t\t\t<Appearance DEF='" + textureLabel + "'>");
      }
      if (target_window == TypeWindow.OBJ3D) {
        writeMTLHeader();
      }
      if (this.displayTexture) {
        writeTextureMap(target_window, texturePath, textureFilename);
      }
    }

    if (target_window == TypeWindow.HTML) {
      htmlOutput.println("\t\t\t\t</Appearance>");
    }

    if (target_window == TypeWindow.OBJ3D) {
      if (User3D.export_PolyToPoly == 1) {
        obj_lastGroupNumber += 1;
        objOutput.println("g EarthSphere");
      }
      if (User3D.export_MaterialLibrary) {
        objOutput.println("usemtl EarthSphere");
      }
    }
  }

  private void writeMTLHeader () {
    mtlOutput.println("newmtl EarthSphere");
    mtlOutput.println("\tilum 2"); // 0: color+ambient off, 1: color+ambient on, 2: highlight on, etc.
    mtlOutput.println("\tKa 1.000 1.000 1.000"); // ambient
    mtlOutput.println("\tKd 1.000 1.000 1.000"); // diffuse
    mtlOutput.println("\tKs 0.000 0.000 0.000"); // specular
    mtlOutput.println("\tNs 10.00");             // 0-1000 specular exponent
    mtlOutput.println("\tNi 1.500");             // 0.001-10 (glass: 1.5) index of refraction
    mtlOutput.println("\td 1.000");              // 0-1 transparency (d = Tr, or d = 1 - Tr)
    mtlOutput.println("\tTr 1.000");             // 0-1 transparency
    mtlOutput.println("\tTf 1.000 1.000 1.000"); // transmission filter
  }

  private void writeTextureMap (int target_window, String texturePath, String textureFilename) {
    String new_Texture_path = Folder_Export3D + "/" + Subfolder_exportMaps + textureFilename;

    if (texturePath.equals("")) {
      // Synthetic/composited mosaic - there's no single source file on
      // disk to copy, so save the in-memory image itself.
      println("Saving composited texture:", new_Texture_path);
      this.cachedTextureImage.save(new_Texture_path);
    } else {
      println("Copying texture:", texturePath, ">", new_Texture_path);
      saveBytes(new_Texture_path, loadBytes(texturePath));
    }

    if (target_window == TypeWindow.OBJ3D) {
      mtlOutput.println("\tmap_Kd " + Subfolder_exportMaps + textureFilename); // diffuse map
      mtlOutput.println("\tmap_d " + Subfolder_exportMaps + textureFilename);  // alpha map
    }
    if (target_window == TypeWindow.HTML) {
      htmlOutput.println("\t\t\t\t\t<ImageTexture url='" + Subfolder_exportMaps + textureFilename + "'><ImageTexture/>");
    }
  }

  private FaceVertex[] buildSubFace (float Alpha, float Beta,
                                      float r, float CEN_lon, float CEN_lat, float ScaleX, float ScaleY) {
    FaceVertex[] subFace = new FaceVertex[4];

    float tb = -STATION.getLongitude();
    float ta = 90 - STATION.getLatitude();

    for (int s = 0; s < 4; s++) {
      FaceVertex vtx = new FaceVertex();

      float a = Alpha;
      float b = Beta;
      if (s == 2 || s == 3) a -= this.lat_step;
      if (s == 1 || s == 2) b -= this.lon_step;

      float x0 = r * funcs.cos_ang(b - 90) * funcs.cos_ang(a);
      float y0 = r * funcs.sin_ang(b - 90) * funcs.cos_ang(a);
      float z0 = r * funcs.sin_ang(a);

      if (this.displayTexture) {
        float lon = b - CEN_lon;
        float lat = a - CEN_lat;
        vtx.u = (lon / ScaleX / LONGITUDE_SPAN + 0.5);
        vtx.v = (-lat / ScaleY / LATITUDE_SPAN + 0.5);
      }

      // rotate so the station's location sits at the model origin/orientation
      float x1 = x0 * funcs.cos_ang(tb) - y0 * funcs.sin_ang(tb);
      float y1 = x0 * funcs.sin_ang(tb) + y0 * funcs.cos_ang(tb);
      float z1 = z0;

      float x2 = x1;
      float y2 = z1 * funcs.sin_ang(ta) + y1 * funcs.cos_ang(ta);
      float z2 = z1 * funcs.cos_ang(ta) - y1 * funcs.sin_ang(ta);

      z2 -= FLOAT_r_Earth; // drop the globe below the station

      vtx.x = x2;
      vtx.y = y2;
      vtx.z = z2;

      subFace[s] = vtx;
    }

    return subFace;
  }


  private void drawFace (int target_window, FaceVertex[] subFace, String textureLabel, int f, int _turn) {
    if (target_window == TypeWindow.HTML) {
      writeFaceHTML(subFace, textureLabel);
      return;
    }
    if (target_window == TypeWindow.OBJ3D) {
      writeFaceOBJ(subFace, f, _turn);
    }
  }

  private void writeFaceHTML (FaceVertex[] subFace, String textureLabel) {
    htmlOutput.println("\t\t\t\t<shape>");
    htmlOutput.println("\t\t\t\t\t<Appearance USE='" + textureLabel + "'></Appearance>");

    htmlOutput.print("\t\t\t\t\t<IndexedFaceSet solid='false'"); // force two-sided
    htmlOutput.print(" coordIndex='");
    for (int s = 0; s < subFace.length; s++) {
      if (s > 0) htmlOutput.print(" ");
      htmlOutput.print(nf(s, 0));
    }
    htmlOutput.println(" -1'>");

    htmlOutput.print("\t\t\t\t\t\t<Coordinate point='");
    for (int s = 0; s < subFace.length; s++) {
      if (s > 0) htmlOutput.print(",");
      htmlOutput.print(nf(subFace[s].x, 0, User3D.export_PrecisionVertex) + " " +
                        nf(subFace[s].y, 0, User3D.export_PrecisionVertex) + " " +
                        nf(subFace[s].z, 0, User3D.export_PrecisionVertex));
    }
    htmlOutput.println("'></Coordinate>");

    htmlOutput.print("\t\t\t\t\t\t<TextureCoordinate point='");
    for (int s = 0; s < subFace.length; s++) {
      if (s > 0) htmlOutput.print(",");
      float u = clamp01(subFace[s].u);
      float v = 1 - clamp01(subFace[s].v); // mirroring the image
      SOLARCHVISION_HTMLprintVtexture(u, v);
    }
    htmlOutput.println("'></TextureCoordinate>");

    htmlOutput.println("\t\t\t\t\t</IndexedFaceSet>");
    htmlOutput.println("\t\t\t\t</shape>");
  }

  private void writeFaceOBJ (FaceVertex[] subFace, int f, int _turn) {
    for (int s = 0; s < subFace.length; s++) {
      float u = clamp01(subFace[s].u);
      float v = clamp01(subFace[s].v);

      if (_turn == 1) {
        SOLARCHVISION_OBJprintVertex(subFace[s].x, subFace[s].y, subFace[s].z);
      }
      if (_turn == 2) {
        v = 1 - v; // mirroring the image
        SOLARCHVISION_OBJprintVtexture(u, v, 0);
      }
      if (_turn == 3) {
        obj_lastVertexNumber += 1;
        obj_lastVtextureNumber += 1;
      }
    }

    if (_turn == 3) {
      writeOBJFaceIndices(f);
    }
  }

  private void writeOBJFaceIndices (int f) {
    String n1_txt = nf(obj_lastVertexNumber - 3, 0);
    String n2_txt = nf(obj_lastVertexNumber - 2, 0);
    String n3_txt = nf(obj_lastVertexNumber - 1, 0);
    String n4_txt = nf(obj_lastVertexNumber - 0, 0);

    String m1_txt = nf(obj_lastVtextureNumber - 3, 0);
    String m2_txt = nf(obj_lastVtextureNumber - 2, 0);
    String m3_txt = nf(obj_lastVtextureNumber - 1, 0);
    String m4_txt = nf(obj_lastVtextureNumber - 0, 0);

    if (User3D.export_PolyToPoly == 0) {
      obj_lastGroupNumber += 1;
      objOutput.println("g EarthSphere_" + nf(f, 0));
    }

    obj_lastFaceNumber += 1;
    objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n2_txt + "/" + m2_txt + " " + n3_txt + "/" + m3_txt + " " + n4_txt + "/" + m4_txt);

    if (User3D.export_BackSides) {
      obj_lastFaceNumber += 1;
      objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n4_txt + "/" + m4_txt + " " + n3_txt + "/" + m3_txt + " " + n2_txt + "/" + m2_txt);
    }
  }


  public void to_XML (XML xml) {
    println("Saving:" + this.CLASS_STAMP);
    XML parent = xml.addChild(this.CLASS_STAMP);
    XML_setBoolean(parent, "displaySurface", this.displaySurface);
    XML_setBoolean(parent, "displayTexture", this.displayTexture);
  }

  public void from_XML (XML xml) {
    println("Loading:" + this.CLASS_STAMP);
    XML parent = xml.getChild(this.CLASS_STAMP);
    this.displaySurface = XML_getBoolean(parent, "displaySurface");
    this.displayTexture = XML_getBoolean(parent, "displayTexture");
  }
}
