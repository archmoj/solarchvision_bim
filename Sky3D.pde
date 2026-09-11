class solarchvision_Sky3D {

  private final static String CLASS_STAMP = "Sky3D";

  boolean displaySurface = true;

  int displayTessellation = 3; //3;

  float scale = 4000000; //25000; //10000; //10km:Troposphere 25km:Ozone layer 100km:Karman line.

  int ACTIVE_palette_CLR = 18; //-1; //7; //8;
  int ACTIVE_palette_DIR = 1; //-1;
  float ACTIVE_palette_MLT = 0.5; //1; //0.25;
  int PASSIVE_palette_CLR = 18;
  int PASSIVE_palette_DIR = -1;
  float PASSIVE_palette_MLT = 0.5;

  float stp_slp;
  float stp_dir;
  int num_slp;
  int num_dir;

  float calculatedResolution = 2.5; //1, 2.5, 5

  private boolean shouldDraw (int target_window) {
    if (!this.displaySurface) return false;
    if (target_window == TypeWindow.STUDY) return false;
    if (target_window == TypeWindow.WORLD) return false;
    return true;
  }

  private float[] activePalette () {
    int type = 0;
    int direction = 1;
    float multiplier = 1;
    if (WIN3D.Impact_TYPE == Impact_ACTIVE) {
      type = this.ACTIVE_palette_CLR;
      direction = this.ACTIVE_palette_DIR;
      multiplier = this.ACTIVE_palette_MLT;
    }
    if (WIN3D.Impact_TYPE == Impact_PASSIVE) {
      type = this.PASSIVE_palette_CLR;
      direction = this.PASSIVE_palette_DIR;
      multiplier = this.PASSIVE_palette_MLT;
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

  private void drawOBJ (int PAL_type, int PAL_direction, float PAL_multiplier) {
    boolean shaded = (WIN3D.FacesShade == SHADE.Global_Solar) || (WIN3D.FacesShade == SHADE.Vertex_Solar);
    if (!shaded) return; // sky isn't exported to OBJ except under solar shading

    String the_filename = "";
    if (User3D.export_MaterialLibrary) {
      the_filename = "skyPatternPalette.bmp";
      String texturePath = Folder_Export3D + "/" + Subfolder_exportMaps + the_filename;
      writeSkyPatternMaterial(PAL_type, the_filename, texturePath);
    }

    obj_lastGroupNumber += 1;
    objOutput.println("g skyPattern");
    if (User3D.export_MaterialLibrary) {
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

  private void writeSkyPatternMaterial (int PAL_type, String filename, String texturePath) {
    println("Saving texture:", texturePath);

    int RES1 = User3D.export_PaletteResolution;
    int RES2 = User3D.export_PaletteResolution / 16;
    PImage palette_Texture = createImage(RES1, RES2, ARGB);
    palette_Texture.loadPixels();
    for (int np = 0; np < (RES1 * RES2); np++) {
      int Image_X = np % RES1;
      float val = (Image_X / (0.5 * RES1)) - 1;
      float u = 0.5 + val;
      if (WIN3D.Impact_TYPE == Impact_ACTIVE) u = 0.5 + 0.5 * val;
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

  private void writeFaceOBJ (float[][] subFace, int _turn, int PAL_type, int PAL_direction, float PAL_multiplier) {
    for (int s = 0; s < subFace.length; s++) {
      int s_next = (s + 1) % subFace.length;
      int s_prev = (s + subFace.length - 1) % subFace.length;

      float x = subFace[s][0] * this.scale * WIN3D.scale;
      float y = subFace[s][1] * this.scale * WIN3D.scale;
      float z = subFace[s][2] * this.scale * WIN3D.scale;

      float u = SHADE.vertexU_Global_Solar(subFace[s], subFace[s_prev], subFace[s_next], PAL_type, PAL_direction, PAL_multiplier);

      if (_turn == 1) {
        SOLARCHVISION_OBJprintVertex(x, y, z);
      }
      if (_turn == 2) {
        float u1 = 0.5 * (u + 0.5);
        boolean solarShade = (WIN3D.FacesShade == SHADE.Global_Solar) || (WIN3D.FacesShade == SHADE.Vertex_Solar);
        if (solarShade && (WIN3D.Impact_TYPE == Impact_ACTIVE)) u1 = u;
        u1 = constrain(u1, 0.001, 0.999);
        SOLARCHVISION_OBJprintVtexture(u1, 0.5, 0);
      }
      if (_turn == 3) {
        num_vertices_added += 1;
      }
    }

    if (_turn == 3) {
      writeSkyPatternObjFace();
    }
  }

  private void writeSkyPatternObjFace () {
    String n1_txt = nf(obj_lastVertexNumber + num_vertices_added - 3, 0);
    String n2_txt = nf(obj_lastVertexNumber + num_vertices_added - 2, 0);
    String n3_txt = nf(obj_lastVertexNumber + num_vertices_added - 1, 0);
    String n4_txt = nf(obj_lastVertexNumber + num_vertices_added - 0, 0);

    String m1_txt = nf(obj_lastVtextureNumber + num_vertices_added - 3, 0);
    String m2_txt = nf(obj_lastVtextureNumber + num_vertices_added - 2, 0);
    String m3_txt = nf(obj_lastVtextureNumber + num_vertices_added - 1, 0);
    String m4_txt = nf(obj_lastVtextureNumber + num_vertices_added - 0, 0);

    objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n4_txt + "/" + m4_txt + " " + n3_txt + "/" + m3_txt + " " + n2_txt + "/" + m2_txt);

    if (User3D.export_BackSides) {
      obj_lastFaceNumber += 1;
      objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n2_txt + "/" + m2_txt + " " + n3_txt + "/" + m3_txt + " " + n4_txt + "/" + m4_txt);
    }
  }

  private void drawWIN3D (int PAL_type, int PAL_direction, float PAL_multiplier) {
    boolean shaded = (WIN3D.FacesShade == SHADE.Global_Solar) || (WIN3D.FacesShade == SHADE.Vertex_Solar);

    if (shaded) {
      for (int f = 0; f < skyFaces.length; f++) {
        float[][][] subFaces = getTessellatedSubFaces(f, this.displayTessellation);
        for (int n = 0; n < subFaces.length; n++) {
          writeFaceWIN3DShaded(subFaces[n], PAL_type, PAL_direction, PAL_multiplier);
        }
      }
    } else {
      writeDomeFlat();
    }
  }

  private void writeFaceWIN3DShaded (float[][] subFace, int PAL_type, int PAL_direction, float PAL_multiplier) {
    WIN3D.graphics.beginShape();
    for (int s = 0; s < subFace.length; s++) {
      int s_next = (s + 1) % subFace.length;
      int s_prev = (s + subFace.length - 1) % subFace.length;

      float[] COL = SHADE.vertexRender_Global_Solar(subFace[s], subFace[s_prev], subFace[s_next], PAL_type, PAL_direction, PAL_multiplier);
      WIN3D.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
      WIN3D.graphics.vertex(subFace[s][0] * this.scale * WIN3D.scale,
                             -subFace[s][1] * this.scale * WIN3D.scale,
                             subFace[s][2] * this.scale * WIN3D.scale);
    }
    WIN3D.graphics.endShape(CLOSE);
  }

  private void writeDomeFlat () {
    color c = color(191, 191, 255);
    WIN3D.graphics.noStroke();
    WIN3D.graphics.fill(c); // same flat color regardless of shade mode here
    //WIN3D.graphics.noFill();

    for (int f = 0; f < skyFaces.length; f++) {
      WIN3D.graphics.beginShape();
      for (int j = 0; j < skyFaces[f].length; j++) {
        int vNo = skyFaces[f][j];
        WIN3D.graphics.vertex(skyVertices[vNo][0] * this.scale * WIN3D.scale,
                               -skyVertices[vNo][1] * this.scale * WIN3D.scale,
                               skyVertices[vNo][2] * this.scale * WIN3D.scale);
      }
      WIN3D.graphics.endShape(CLOSE);
    }
  }

  private float[][][] getTessellatedSubFaces (int f, int tessellation) {
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


  public void to_XML (XML xml) {
    println("Saving:" + this.CLASS_STAMP);
    XML parent = xml.addChild(this.CLASS_STAMP);
    XML_setBoolean(parent, "displaySurface", this.displaySurface);
    XML_setInt(parent, "displayTessellation", this.displayTessellation);
    XML_setFloat(parent, "scale", this.scale);
    XML_setInt(parent, "ACTIVE_palette_CLR", this.ACTIVE_palette_CLR);
    XML_setInt(parent, "ACTIVE_palette_DIR", this.ACTIVE_palette_DIR);
    XML_setFloat(parent, "ACTIVE_palette_MLT", this.ACTIVE_palette_MLT);
    XML_setInt(parent, "PASSIVE_palette_CLR", this.PASSIVE_palette_CLR);
    XML_setInt(parent, "PASSIVE_palette_DIR", this.PASSIVE_palette_DIR);
    XML_setFloat(parent, "PASSIVE_palette_MLT", this.PASSIVE_palette_MLT);
    XML_setFloat(parent, "stp_slp", this.stp_slp);
    XML_setFloat(parent, "stp_dir", this.stp_dir);
    XML_setInt(parent, "num_slp", this.num_slp);
    XML_setInt(parent, "num_dir", this.num_dir);
    XML_setFloat(parent, "calculatedResolution", this.calculatedResolution);
  }

  public void from_XML (XML xml) {
    println("Loading:" + this.CLASS_STAMP);
    XML parent = xml.getChild(this.CLASS_STAMP);
    this.displaySurface = XML_getBoolean(parent, "displaySurface");
    this.displayTessellation = XML_getInt(parent, "displayTessellation");
    this.scale = XML_getFloat(parent, "scale");
    this.ACTIVE_palette_CLR = XML_getInt(parent, "ACTIVE_palette_CLR");
    this.ACTIVE_palette_DIR = XML_getInt(parent, "ACTIVE_palette_DIR");
    this.ACTIVE_palette_MLT = XML_getFloat(parent, "ACTIVE_palette_MLT");
    this.PASSIVE_palette_CLR = XML_getInt(parent, "PASSIVE_palette_CLR");
    this.PASSIVE_palette_DIR = XML_getInt(parent, "PASSIVE_palette_DIR");
    this.PASSIVE_palette_MLT = XML_getFloat(parent, "PASSIVE_palette_MLT");
    this.stp_slp = XML_getFloat(parent, "stp_slp");
    this.stp_dir = XML_getFloat(parent, "stp_dir");
    this.num_slp = XML_getInt(parent, "num_slp");
    this.num_dir = XML_getInt(parent, "num_dir");
    this.calculatedResolution = XML_getFloat(parent, "calculatedResolution");
  }
}
