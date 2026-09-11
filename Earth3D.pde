class solarchvision_Earth3D {

  private final static String CLASS_STAMP = "Earth3D";

  private final static float LONGITUDE_SPAN = 360.0;
  private final static float LATITUDE_SPAN  = 180.0;
  private final static float BOUNDARY_SCALE = 0.001; // filenames encode boundaries in millidegrees

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

  void draw (int target_window) {
    if (!shouldDraw(target_window)) return;

    int n_Map = currentMapIndex();

    float ScaleX  = (this.BoundariesX[n_Map][1] - this.BoundariesX[n_Map][0]) / LONGITUDE_SPAN;
    float ScaleY  = (this.BoundariesY[n_Map][1] - this.BoundariesY[n_Map][0]) / LATITUDE_SPAN;
    float CEN_lon = 0.5 * (this.BoundariesX[n_Map][0] + this.BoundariesX[n_Map][1]);
    float CEN_lat = 0.5 * (this.BoundariesY[n_Map][0] + this.BoundariesY[n_Map][1]);

    float delta_Alpha = -BIOSPHERE_drawResolution;
    float delta_Beta  = -BIOSPHERE_drawResolution;
    float r = FLOAT_r_Earth;

    if (target_window == TypeWindow.HTML || target_window == TypeWindow.OBJ3D) {
      writeMaterial(target_window, n_Map);
    }

    num_vertices_added = 0;

    int end_turn = (target_window == TypeWindow.OBJ3D) ? 3 : 1;

    for (int _turn = 1; _turn <= end_turn; _turn++) {
      int f = 0;
      for (float Alpha = 90; Alpha > -90; Alpha += delta_Alpha) {
        for (float Beta = 180; Beta > -180; Beta += delta_Beta) {
          f += 1;
          FaceVertex[] subFace = buildSubFace(Alpha, Beta, delta_Alpha, delta_Beta, r, CEN_lon, CEN_lat, ScaleX, ScaleY);
          drawFace(target_window, subFace, n_Map, f, _turn);
        }
      }
    }
  }

  private void writeMaterial (int target_window, int n_Map) {
    if (User3D.export_MaterialLibrary) {
      if (target_window == TypeWindow.HTML) {
        htmlOutput.println("\t\t\t\t<Appearance DEF='EarthSphere" + nf(n_Map, 0) + "'>");
      }
      if (target_window == TypeWindow.OBJ3D) {
        writeMTLHeader();
      }
      if (this.displayTexture) {
        writeTextureMap(target_window, n_Map);
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

  private void writeTextureMap (int target_window, int n_Map) {
    String old_Texture_path = this.Path + "/" + this.Filenames[n_Map];
    String the_filename = old_Texture_path.substring(old_Texture_path.lastIndexOf("/") + 1);
    String new_Texture_path = Folder_Export3D + "/" + Subfolder_exportMaps + the_filename;

    println("Copying texture:", old_Texture_path, ">", new_Texture_path);
    saveBytes(new_Texture_path, loadBytes(old_Texture_path));

    if (target_window == TypeWindow.OBJ3D) {
      mtlOutput.println("\tmap_Kd " + Subfolder_exportMaps + the_filename); // diffuse map
      mtlOutput.println("\tmap_d " + Subfolder_exportMaps + the_filename);  // alpha map
    }
    if (target_window == TypeWindow.HTML) {
      htmlOutput.println("\t\t\t\t\t<ImageTexture url='" + Subfolder_exportMaps + the_filename + "'><ImageTexture/>");
    }
  }

  private FaceVertex[] buildSubFace (float Alpha, float Beta, float delta_Alpha, float delta_Beta,
                                      float r, float CEN_lon, float CEN_lat, float ScaleX, float ScaleY) {
    FaceVertex[] subFace = new FaceVertex[4];

    float tb = -STATION.getLongitude();
    float ta = 90 - STATION.getLatitude();

    for (int s = 0; s < 4; s++) {
      FaceVertex vtx = new FaceVertex();

      float a = Alpha;
      float b = Beta;
      if (s == 2 || s == 3) a += delta_Alpha;
      if (s == 1 || s == 2) b += delta_Beta;

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


  private void drawFace (int target_window, FaceVertex[] subFace, int n_Map, int f, int _turn) {
    if (target_window == TypeWindow.HTML) {
      writeFaceHTML(subFace, n_Map);
      return;
    }
    if (target_window == TypeWindow.WIN3D) {
      writeFaceWIN3D(subFace, n_Map);
      return;
    }
    if (target_window == TypeWindow.OBJ3D) {
      writeFaceOBJ(subFace, f, _turn);
    }
  }

  private void writeFaceHTML (FaceVertex[] subFace, int n_Map) {
    htmlOutput.println("\t\t\t\t<shape>");
    if (n_Map != -1) {
      htmlOutput.println("\t\t\t\t\t<Appearance USE='EarthSphere" + nf(n_Map, 0) + "'></Appearance>");
    }

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

    if (n_Map != -1) {
      htmlOutput.print("\t\t\t\t\t\t<TextureCoordinate point='");
      for (int s = 0; s < subFace.length; s++) {
        if (s > 0) htmlOutput.print(",");
        float u = clamp01(subFace[s].u);
        float v = 1 - clamp01(subFace[s].v); // mirroring the image
        SOLARCHVISION_HTMLprintVtexture(u, v);
      }
      htmlOutput.println("'></TextureCoordinate>");
    }

    htmlOutput.println("\t\t\t\t\t</IndexedFaceSet>");
    htmlOutput.println("\t\t\t\t</shape>");
  }

  private void writeFaceWIN3D (FaceVertex[] subFace, int n_Map) {
    WIN3D.graphics.strokeWeight(1);
    WIN3D.graphics.beginShape();
    WIN3D.graphics.noStroke();
    if (this.displayTexture) {
      WIN3D.graphics.texture(this.Map[n_Map]);
    }

    for (int s = 0; s < subFace.length; s++) {
      float u = clamp01(subFace[s].u);
      float v = clamp01(subFace[s].v);
      WIN3D.graphics.vertex(
        subFace[s].x * OBJECTS_scale * WIN3D.scale,
        -subFace[s].y * OBJECTS_scale * WIN3D.scale,
        subFace[s].z * OBJECTS_scale * WIN3D.scale,
        u * this.Map[n_Map].width,
        v * this.Map[n_Map].height
      );
    }

    WIN3D.graphics.endShape(CLOSE);
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
