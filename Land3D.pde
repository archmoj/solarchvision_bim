class solarchvision_Land3D {

  private final static String CLASS_STAMP = "Land3D";

  boolean loadMesh = true;
  boolean loadTextures = true;

  boolean displaySurface = true;
  boolean displayPoints = false;
  boolean displayTexture = true;
  boolean displayDepth = false;

  int displayTessellation = 0; //0; //2;

  int palette_CLR = 1;
  int palette_DIR = -1;
  float palette_MLT = 0.05;

  float[][][] Mesh;

  float[] Textures_U_scale;
  float[] Textures_V_scale;
  PImage[] Textures_map;
  String[] Textures_path;
  int Textures_num = 0;

  // Polar grid
  int num_rows = 12; // 24;
  int num_columns = 24 + 1; // 48 + 1;

  int skipStart = 1;
  int skipEnd = 0;

  void update_textures () {
    this.Textures_U_scale = new float[0];
    this.Textures_V_scale = new float[0];
    this.Textures_map = new PImage[0];
    this.Textures_path = new String[0];
    this.Textures_num = 0;
    this.displayTexture = false;

    if (this.loadTextures) {
      try {
        String[] filenames = sort(OPESYS.getFiles(Folder_Land)); // important to sort
        if (filenames != null) {
          for (int i = 0; i < filenames.length; i++) {
            addLandTextureIfElevationJpg(filenames[i]);
          }
        }
      }
      catch (Exception e) {
        println("ERROR loading this.Textures_map!");
      }
    }

    SOLARCHVISION_view_changed();
  }

  private void addLandTextureIfElevationJpg (String filename) {
    println(filename);

    int L = filename.length();
    String extension = filename.substring(L - 4, L);
    if (!extension.toLowerCase().equals(".jpg")) return;

    String[] Parts = split(filename, '_');
    if (!Parts[0].toUpperCase().equals("ELEV")) return;
    if (Parts.length <= 1) return;

    String dir = Folder_Land + "/" + filename;
    this.Textures_path = (String[]) concat(this.Textures_path, new String[] { dir });

    float u = float(Parts[1]);
    float v = u;

    PImage image = loadImage(dir);
    this.Textures_map = (PImage[]) concat(this.Textures_map, new PImage[] { image });

    int w = image.width;
    int h = image.height;
    if ((w < h) && (h != 0)) u *= w / (1.0 * h);
    if ((w > h) && (w != 0)) v *= h / (1.0 * w);

    this.Textures_U_scale = (float[]) concat(this.Textures_U_scale, new float[] { u });
    this.Textures_V_scale = (float[]) concat(this.Textures_V_scale, new float[] { v });

    this.Textures_num += 1;
    this.displayTexture = true;
  }

  void update_mesh () {
    this.Mesh = new float[this.num_rows][this.num_columns][3];
    for (int i = 0; i < this.num_rows; i++) {
      for (int j = 0; j < this.num_columns; j++) {
        this.Mesh[i][j][0] = FLOAT_undefined;
        this.Mesh[i][j][1] = FLOAT_undefined;
        this.Mesh[i][j][2] = FLOAT_undefined;
      }
    }

    boolean using_default_mesh = false;
    try {
      if (this.loadMesh) {
        loadMeshFromFiles();
        normalizeMeshElevation();
      }
    }
    catch (Exception e) {
      println("Warning: problem in loading topography from file.");
      using_default_mesh = true;
    }

    if (using_default_mesh) {
      println("Using default flat mesh:");
      this.flat_mesh();
    }

    this.update_textures();
  }

  private void loadMeshFromFiles () {
    for (int i = 0; i < this.num_rows; i++) {
      XML FileALL = loadXML(Folder_Land + "/" + nf(i, 0) + ".xml");
      XML[] children0 = FileALL.getChildren("result");

      for (int j = 0; j < this.num_columns; j++) {
        String txt_elevation = children0[j].getChild("elevation").getContent();
        XML[] children1 = children0[j].getChildren("location");
        String txt_latitude = children1[0].getChild("lat").getContent();
        String txt_longitude = children1[0].getChild("lng").getContent();

        double _lon = Double.parseDouble(txt_longitude);
        double _lat = Double.parseDouble(txt_latitude);
        float[] XY = funcs.convert_lonlat2XY(STATION.getLongitude(), STATION.getLatitude(), _lon, _lat);

        this.Mesh[i][j][0] = XY[0];
        this.Mesh[i][j][1] = XY[1];
        this.Mesh[i][j][2] = float(txt_elevation);
      }
    }
  }

  private void normalizeMeshElevation () {
    float h = this.Mesh[0][0][2] + HeightAboveGround;
    for (int i = 0; i < this.num_rows; i++) {
      for (int j = 0; j < this.num_columns; j++) {
        this.Mesh[i][j][2] -= h;
      }
    }
  }

  void flat_mesh () {
    this.Mesh = new float[this.num_rows][this.num_columns][3];
    for (int i = 0; i < this.num_rows; i++) {
      for (int j = 0; j < this.num_columns; j++) {
        double[] LON_LAT = getLandGrid(i, j);
        float[] XY = funcs.convert_lonlat2XY(STATION.getLongitude(), STATION.getLatitude(), LON_LAT[0], LON_LAT[1]);
        this.Mesh[i][j][0] = XY[0];
        this.Mesh[i][j][1] = XY[1];
        this.Mesh[i][j][2] = 0;
      }
    }
    this.loadMesh = true;
  }

  double[] getLandGrid (int i, int j) {
    double stp_lat = 1.0 / 2224.5968; // equals to 50m
    double stp_lon = stp_lat / funcs.cos_ang(STATION.getLatitude());

    float q = pow(2, 0.5);
    float t = j * 360.0 / (this.num_columns - 1);
    float r = (i > 0) ? pow(q, i - 1) : 0;

    double _lon = STATION.getLongitude() + stp_lon * r * funcs.cos_ang(t);
    double _lat = STATION.getLatitude() + stp_lat * r * funcs.sin_ang(t);

    return new double[] { _lon, _lat };
  }

  void download_mesh () {
    this.Mesh = new float[this.num_rows][this.num_columns][3];

    for (int i = 0; i < this.num_rows; i++) {
      String the_target = Folder_Land + "/" + nf(i, 0) + ".xml";
      File dir = new File(the_target);
      if (dir.isFile()) continue;

      String the_link = "";
      for (int j = 0; j < this.num_columns; j++) {
        the_link += the_link.equals("") ? "https://api.terraintap.com/elevation/xml?locations=" : "%7C"; // "|"

        double[] LON_LAT = getLandGrid(i, j);
        String txt_latitude = nf((float) LON_LAT[1], 0, 5);
        String txt_longitude = nf((float) LON_LAT[0], 0, 5);
        the_link += txt_latitude + "," + txt_longitude;
      }

      println("Try downloading: " + the_link); // don't show the API_KEY
      try {
        saveBytes(the_target, loadBytes(the_link + "&key=" + TERRAINTAP_API_KEY));
      }
      catch (Exception e) {
        println("LINK NOT AVAILABLE:", the_link); // don't show the API_KEY
      }
    }

    this.loadMesh = true;
    this.update_mesh();
  }

  void download_textures () {
    float[] ratios = {
      1128.497220, 2256.994440, 4513.988880, 9027.977761, 18055.95552,
      36111.91104, 72223.82209, 144447.6442, 288895.2884, 577790.5767,
      1155581.153, 2311162.307, 4622324.614, 9244649.227, 18489298.45,
      36978596.91, 73957193.82, 147914387.6, 295828775.3, 591657550.5
    };

    for (int i = 0; i <= 15; i++) {
      String the_target = Folder_Land + "/ELEV_" + nf(int(0.05 * ratios[i]), 7) + "_.jpg";
      File dir = new File(the_target);
      if (dir.isFile()) continue;

      String the_link = "https://maps.googleapis.com/maps/api/staticmap?center=" + nf(STATION.getLatitude(), 0, 5) + "," + nf(STATION.getLongitude(), 0, 5) + "&zoom=" + nf(20 - i, 0) + "&size=640x640&maptype=satellite&format=jpg";
      println("Try downloading: " + the_link);
      try {
        saveBytes(the_target, loadBytes(the_link));
      }
      catch (Exception e) {
        println("LINK NOT AVAILABLE:", the_link);
      }
    }

    this.loadTextures = true;
    this.update_textures();
  }

  private boolean shouldDraw (int target_window) {
    if (!this.displaySurface || !this.loadMesh) return false;
    if (target_window == TypeWindow.STUDY) return false;
    if (target_window == TypeWindow.WORLD) return false;
    return true;
  }

  private float[][] landCellBaseVertices (int i, int j) {
    return new float[][] {
      { this.Mesh[i][j][0],     this.Mesh[i][j][1],     this.Mesh[i][j][2] },
      { this.Mesh[i+1][j][0],   this.Mesh[i+1][j][1],   this.Mesh[i+1][j][2] },
      { this.Mesh[i+1][j+1][0], this.Mesh[i+1][j+1][1], this.Mesh[i+1][j+1][2] },
      { this.Mesh[i][j+1][0],   this.Mesh[i][j+1][1],   this.Mesh[i][j+1][2] }
    };
  }

  void draw (int target_window) {
    if (!shouldDraw(target_window)) return;

    int PAL_type = SHADE.get_PAL_type();
    int PAL_direction = SHADE.get_PAL_direction();
    float PAL_multiplier = SHADE.get_PAL_multiplier();

    if (User3D.export_MaterialLibrary) {
      writeLandMaterials(target_window);
    }

    if ((target_window == TypeWindow.LandGap) || (target_window == TypeWindow.LandMesh)) {
      beginLandGroup();
    }

    int i_start = this.skipStart;
    int i_end = this.num_rows - 1 - this.skipEnd;
    if (target_window == TypeWindow.LandGap) {
      i_start = 0;
      i_end = this.skipStart;
      target_window = TypeWindow.LandMesh; // the rest of the logic is the same as LandMesh
    }

    num_vertices_added = 0;
    int end_turn = (target_window == TypeWindow.OBJ3D) ? 3 : 1;

    for (int _turn = 1; _turn <= end_turn; _turn++) {
      if ((target_window == TypeWindow.OBJ3D) && (_turn == 3) && this.displayTexture) {
        obj_lastGroupNumber += 1;
        objOutput.println("g LandMap");
      }

      int tessellation = this.displayTessellation;
      if (WIN3D.FacesShade == SHADE.Surface_Base) tessellation = 0;
      if (target_window == TypeWindow.LandMesh) tessellation = 0;

      int totalNumberOfSubs = 1;
      if (tessellation > 0) totalNumberOfSubs = 4 * int(funcs.roundTo(pow(4, tessellation - 1), 1)); // x4: a LAND cell has 4 points

      for (int i = i_start; i < i_end; i++) {
        drawLandRow(target_window, i, tessellation, totalNumberOfSubs, _turn, PAL_type, PAL_direction, PAL_multiplier);
      }
    }

    if (target_window == TypeWindow.OBJ3D) {
      obj_lastVertexNumber += num_vertices_added;
      obj_lastVtextureNumber += num_vertices_added;
    }

    if (target_window == TypeWindow.WIN3D) {
      drawLandPoints();
    }

    if (target_window == TypeWindow.LandMesh) {
      Select3D.Group_ids = new int[1];
      Select3D.Group_ids[0] = allGroups.num - 1;
      Modify3D.weldObjectsVertices_Selection(0);
    }
  }

  private void writeLandMaterials (int target_window) {
    for (int n_Map = 0; n_Map < this.Textures_num; n_Map++) {
      if (target_window == TypeWindow.RAD3D) {
        radOutput.println("void plastic " + "LandMap" + nf(n_Map, 0));
        radOutput.println("0");
        radOutput.println("0");
        radOutput.println("5 0 0 0 0 0");
      }

      if (target_window == TypeWindow.HTML) {
        htmlOutput.println("\t\t\t\t<Appearance DEF='LandMap" + nf(n_Map, 0) + "'>");
      }

      if (target_window == TypeWindow.OBJ3D) {
        mtlOutput.println("newmtl LandMap" + nf(n_Map, 0));
        mtlOutput.println("\tilum 2");
        mtlOutput.println("\tKa 1.000 1.000 1.000");
        mtlOutput.println("\tKd 1.000 1.000 1.000");
        mtlOutput.println("\tKs 0.000 0.000 0.000");
        mtlOutput.println("\tNs 10.00");
        mtlOutput.println("\tNi 1.500");
        mtlOutput.println("\td 1.000");
        mtlOutput.println("\tTr 1.000");
        mtlOutput.println("\tTf 1.000 1.000 1.000");
      }

      boolean materialTarget = (target_window == TypeWindow.HTML) || (target_window == TypeWindow.OBJ3D);
      if (materialTarget && this.displayTexture) {
        String old_Texture_path = this.Textures_path[n_Map];
        String the_filename = old_Texture_path.substring(old_Texture_path.lastIndexOf("/") + 1);
        String new_Texture_path = Folder_Export3D + "/" + Subfolder_exportMaps + the_filename;

        println("Copying texture:", old_Texture_path, ">", new_Texture_path);
        saveBytes(new_Texture_path, loadBytes(old_Texture_path));

        if (target_window == TypeWindow.OBJ3D) {
          mtlOutput.println("\tmap_Kd " + Subfolder_exportMaps + the_filename);
          mtlOutput.println("\tmap_d " + Subfolder_exportMaps + the_filename);
        }
        if (target_window == TypeWindow.HTML) {
          htmlOutput.println("\t\t\t\t\t<ImageTexture url='" + Subfolder_exportMaps + the_filename + "'><ImageTexture/>");
        }
      }

      if (target_window == TypeWindow.HTML) {
        htmlOutput.println("\t\t\t\t</Appearance>");
      }
    }
  }

  private void beginLandGroup () {
    current_Material = User3D.default_Material;
    current_Tessellation = User3D.default_Tessellation;
    current_Layer = User3D.default_Layer;
    current_Visibility = User3D.default_Visibility;
    current_Weight = User3D.default_Weight;
    current_Closed = User3D.default_Closed;

    allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
  }

  private void drawLandRow (int target_window, int i, int tessellation, int totalNumberOfSubs, int _turn, int PAL_type, int PAL_direction, float PAL_multiplier) {
    for (int j = 0; j < this.num_columns - 1; j++) {
      drawLandCell(target_window, i, j, tessellation, totalNumberOfSubs, _turn, PAL_type, PAL_direction, PAL_multiplier);
    }

    if ((target_window == TypeWindow.LandMesh) && (i == 0)) {
      closeLandCenterGap(i);
    }
  }

  // Creates a polygon around the center to close the gap left by skipStart.
  private void closeLandCenterGap (int i) {
    int[] _face = new int[this.num_columns - 1];
    for (int j = 0; j < _face.length; j++) {
      _face[j] = allPoints.create(this.Mesh[i + 1][j][0], this.Mesh[i + 1][j][1], this.Mesh[i + 1][j][2]);
    }
    allFaces.create(_face);
  }

  private void drawLandCell (int target_window, int i, int j, int tessellation, int totalNumberOfSubs, int _turn, int PAL_type, int PAL_direction, float PAL_multiplier) {
    float[][] base_Vertices = landCellBaseVertices(i, j);

    for (int n = 0; n < totalNumberOfSubs; n++) {
      float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);
      drawLandSubFace(target_window, subFace, i, _turn, PAL_type, PAL_direction, PAL_multiplier);
    }
  }

  private void drawLandSubFace (int target_window, float[][] subFace, int i, int _turn, int PAL_type, int PAL_direction, float PAL_multiplier) {
    int n_Map = selectLandTextureMap(subFace);

    beginLandShape(target_window, subFace, n_Map, _turn);

    int[] newFace = new int[subFace.length]; // used only for target_window == RENDER
    for (int s = 0; s < subFace.length; s++) {
      renderLandVertex(target_window, subFace, newFace, s, i, _turn, n_Map, PAL_type, PAL_direction, PAL_multiplier);
    }

    endLandShape(target_window, i, n_Map, _turn);

    if (this.displayTexture && this.displayDepth) {
      writeLandDepthWalls(target_window, subFace, n_Map);
    }
  }

  private int selectLandTextureMap (float[][] subFace) {
    if (!this.displayTexture) return -1;

    int n_Map = -1;
    for (int q = 0; q < this.Textures_num; q++) { // increase resolution until every corner fits inside a map
      n_Map = q;
      for (int s = 0; s < subFace.length; s++) {
        float u = (subFace[s][0] / this.Textures_U_scale[q] + 0.5);
        float v = (-subFace[s][1] / this.Textures_V_scale[q] + 0.5);
        if ((0.05 > u) || (u > 0.95) || (0.05 > v) || (v > 0.95)) { // exclude margins where the legend is printed
          n_Map = -1;
          break;
        }
      }
      if (n_Map == q) break;
    }
    return n_Map;
  }

  private void beginLandShape (int target_window, float[][] subFace, int n_Map, int _turn) {
    if (target_window == TypeWindow.SKY2D) {
      SKY2D_graphics.beginShape();
      SKY2D_graphics.fill(255);
      SKY2D_graphics.noStroke();
    }

    if (target_window == TypeWindow.WIN3D) {
      WIN3D.graphics.beginShape();
      WIN3D.graphics.strokeWeight(1);
      WIN3D.graphics.stroke(0, 0, 0);
      if (!allFaces.displayEdges) WIN3D.graphics.noStroke();
      if (this.displayTexture) WIN3D.graphics.noStroke();

      if (this.displayTexture) {
        if (n_Map != -1) {
          WIN3D.graphics.texture(this.Textures_map[n_Map]);
        } else {
          WIN3D.graphics.noFill();
          WIN3D.graphics.strokeWeight(1);
          WIN3D.graphics.stroke(0, 0, 0);
        }
      }
    }

    if ((target_window == TypeWindow.OBJ3D) && (_turn == 3) && this.displayTexture && User3D.export_MaterialLibrary && (n_Map != -1)) {
      objOutput.println("usemtl LandMap" + nf(n_Map, 0));
    }

    if (target_window == TypeWindow.HTML) {
      htmlOutput.println("\t\t\t\t<shape>");
      if (n_Map != -1) {
        htmlOutput.println("\t\t\t\t\t<Appearance USE='LandMap" + nf(n_Map, 0) + "'></Appearance>");
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
        htmlOutput.print(nf(subFace[s][0], 0, User3D.export_PrecisionVertex) + " " +
                          nf(subFace[s][1], 0, User3D.export_PrecisionVertex) + " " +
                          nf(subFace[s][2], 0, User3D.export_PrecisionVertex));
      }
      htmlOutput.println("'></Coordinate>");
    }
  }

  private void renderLandVertex (int target_window, float[][] subFace, int[] newFace, int s, int i, int _turn, int n_Map, int PAL_type, int PAL_direction, float PAL_multiplier) {
    if ((target_window == TypeWindow.RENDER) && (i < 5)) { // don't add points farther away
      newFace[s] = entirePointsX.size();
      entirePointsX.add(subFace[s][0]);
      entirePointsY.add(subFace[s][1]);
      entirePointsZ.add(subFace[s][2]);
      if (s == subFace.length - 1) entireFaces.add(newFace);
    }

    if (target_window == TypeWindow.SKY2D) {
      SKY2D_graphics.vertex(subFace[s][0], -subFace[s][1], subFace[s][2]);
    }

    if (!this.displayTexture) {
      renderLandVertexShaded(target_window, subFace, s, PAL_type, PAL_direction, PAL_multiplier);
    } else {
      renderLandVertexTextured(target_window, subFace, s, i, _turn, n_Map);
    }
  }

  private void renderLandVertexShaded (int target_window, float[][] subFace, int s, int PAL_type, int PAL_direction, float PAL_multiplier) {
    if (WIN3D.FacesShade != SHADE.Surface_Wire) {
      float[] COL = { 255, 255, 255, 255 };
      int s_next = (s + 1) % subFace.length;
      int s_prev = (s + subFace.length - 1) % subFace.length;

      if (WIN3D.FacesShade == SHADE.Global_Solar) COL = SHADE.vertexRender_Global_Solar(subFace[s], subFace[s_prev], subFace[s_next], PAL_type, PAL_direction, PAL_multiplier);
      if (WIN3D.FacesShade == SHADE.Vertex_Solar) COL = SHADE.vertexRender_Vertex_Solar(subFace[s], subFace[s_prev], subFace[s_next], PAL_type, PAL_direction, PAL_multiplier);
      if (WIN3D.FacesShade == SHADE.Vertex_Solid) COL = SHADE.vertexRender_Vertex_Solid(subFace[s], PAL_type, PAL_direction, PAL_multiplier);
      if (WIN3D.FacesShade == SHADE.Vertex_Elevation) COL = SHADE.vertexRender_Vertex_Elevation(subFace[s], PAL_type, PAL_direction, PAL_multiplier);
      if (WIN3D.FacesShade == SHADE.Surface_White) COL = SHADE.vertexRender_Surface_White(255);
      if (WIN3D.FacesShade == SHADE.Surface_Materials) COL = SHADE.vertexRender_Surface_White(223);

      if (target_window == TypeWindow.WIN3D) {
        WIN3D.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
      }
    } else if (target_window == TypeWindow.WIN3D) {
      WIN3D.graphics.noFill();
    }

    if (target_window == TypeWindow.WIN3D) {
      WIN3D.graphics.vertex(subFace[s][0] * OBJECTS_scale * WIN3D.scale, -subFace[s][1] * OBJECTS_scale * WIN3D.scale, subFace[s][2] * OBJECTS_scale * WIN3D.scale);
    }

    // Note: RAD3D land export historically produced no output here (see file header) -
    // that hasn't changed, it's just no longer represented by unreachable code.
  }

  private void renderLandVertexTextured (int target_window, float[][] subFace, int s, int i, int _turn, int n_Map) {
    float u = 0;
    float v = 0;
    if (n_Map != -1) {
      u = (subFace[s][0] / this.Textures_U_scale[n_Map] + 0.5);
      v = (-subFace[s][1] / this.Textures_V_scale[n_Map] + 0.5);
    }

    if (target_window == TypeWindow.WIN3D) {
      if (n_Map != -1) {
        WIN3D.graphics.vertex(
          subFace[s][0] * OBJECTS_scale * WIN3D.scale,
          -subFace[s][1] * OBJECTS_scale * WIN3D.scale,
          subFace[s][2] * OBJECTS_scale * WIN3D.scale,
          u * this.Textures_map[n_Map].width,
          v * this.Textures_map[n_Map].height
        );
      } else {
        WIN3D.graphics.vertex(subFace[s][0] * OBJECTS_scale * WIN3D.scale, -subFace[s][1] * OBJECTS_scale * WIN3D.scale, subFace[s][2] * OBJECTS_scale * WIN3D.scale);
      }
    }

    if (target_window == TypeWindow.OBJ3D) {
      if (_turn == 1) SOLARCHVISION_OBJprintVertex(subFace[s][0], subFace[s][1], subFace[s][2]);
      if (_turn == 2) {
        v = 1 - v; // mirroring the image
        SOLARCHVISION_OBJprintVtexture(u, v, 0);
      }
      if (_turn == 3) num_vertices_added += 1;
    }

    if ((target_window == TypeWindow.LandMesh) && (i != 0)) { // avoid duplicate points at the center
      allPoints.create(subFace[s][0], subFace[s][1], subFace[s][2]);
    }

    if ((target_window == TypeWindow.HTML) && (n_Map != -1)) {
      if (s == 0) htmlOutput.print("\t\t\t\t\t\t<TextureCoordinate point='");
      if (s > 0) htmlOutput.print(",");
      v = 1 - v; // mirroring the image
      SOLARCHVISION_HTMLprintVtexture(u, v);
      if (s == subFace.length - 1) htmlOutput.println("'></TextureCoordinate>");
    }
  }

  private void endLandShape (int target_window, int i, int n_Map, int _turn) {
    if (target_window == TypeWindow.HTML) {
      htmlOutput.println("\t\t\t\t\t</IndexedFaceSet>");
      htmlOutput.println("\t\t\t\t</shape>");
    }

    if (target_window == TypeWindow.SKY2D) {
      SKY2D_graphics.endShape(CLOSE);
    }

    if (target_window == TypeWindow.WIN3D) {
      WIN3D.graphics.endShape(CLOSE);
    }

    if ((target_window == TypeWindow.OBJ3D) && (_turn == 3) && this.displayTexture) {
      writeLandObjFace();
    }

    if ((target_window == TypeWindow.LandMesh) && (i != 0)) { // avoid duplicate points at the center
      int len = allPoints.getLength();
      allFaces.create(new int[] { len - 4, len - 3, len - 2, len - 1 });
    }
  }

  private void writeLandObjFace () {
    String n1_txt = nf(obj_lastVertexNumber + num_vertices_added - 3, 0);
    String n2_txt = nf(obj_lastVertexNumber + num_vertices_added - 2, 0);
    String n3_txt = nf(obj_lastVertexNumber + num_vertices_added - 1, 0);
    String n4_txt = nf(obj_lastVertexNumber + num_vertices_added - 0, 0);

    String m1_txt = nf(obj_lastVtextureNumber + num_vertices_added - 3, 0);
    String m2_txt = nf(obj_lastVtextureNumber + num_vertices_added - 2, 0);
    String m3_txt = nf(obj_lastVtextureNumber + num_vertices_added - 1, 0);
    String m4_txt = nf(obj_lastVtextureNumber + num_vertices_added - 0, 0);

    obj_lastFaceNumber += 1;
    objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n2_txt + "/" + m2_txt + " " + n3_txt + "/" + m3_txt + " " + n4_txt + "/" + m4_txt);

    if (User3D.export_BackSides) {
      obj_lastFaceNumber += 1;
      objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n4_txt + "/" + m4_txt + " " + n3_txt + "/" + m3_txt + " " + n2_txt + "/" + m2_txt);
    }
  }

  private void writeLandDepthWalls (int target_window, float[][] subFace, int n_Map) {
    if (target_window != TypeWindow.WIN3D) return;
    WIN3D.graphics.fill(223, 223, 223);
    WIN3D.graphics.noStroke();

    for (int s = 0; s < subFace.length; s++) {
      int s_next = (s + 1) % subFace.length;

      float u = 0;
      float v = 0;
      float u_next = 0;
      float v_next = 0;
      if (n_Map != -1) {
        u = (subFace[s][0] / this.Textures_U_scale[n_Map] + 0.5);
        v = (-subFace[s][1] / this.Textures_V_scale[n_Map] + 0.5);

        u_next = (subFace[s_next][0] / this.Textures_U_scale[n_Map] + 0.5);
        v_next = (-subFace[s_next][1] / this.Textures_V_scale[n_Map] + 0.5);
      }

      WIN3D.graphics.beginShape();
      if (n_Map != -1) {
        WIN3D.graphics.texture(this.Textures_map[n_Map]);
        WIN3D.graphics.vertex(subFace[s][0] * OBJECTS_scale * WIN3D.scale, -subFace[s][1] * OBJECTS_scale * WIN3D.scale, subFace[s][2] * OBJECTS_scale * WIN3D.scale, u * this.Textures_map[n_Map].width, v * this.Textures_map[n_Map].height);
        WIN3D.graphics.vertex(subFace[s_next][0] * OBJECTS_scale * WIN3D.scale, -subFace[s_next][1] * OBJECTS_scale * WIN3D.scale, subFace[s_next][2] * OBJECTS_scale * WIN3D.scale, u_next * this.Textures_map[n_Map].width, v_next * this.Textures_map[n_Map].height);
        WIN3D.graphics.vertex(subFace[s_next][0] * OBJECTS_scale * WIN3D.scale, -subFace[s_next][1] * OBJECTS_scale * WIN3D.scale, (subFace[s_next][2] - CrustDepth) * OBJECTS_scale * WIN3D.scale, u_next * this.Textures_map[n_Map].width, v_next * this.Textures_map[n_Map].height);
        WIN3D.graphics.vertex(subFace[s][0] * OBJECTS_scale * WIN3D.scale, -subFace[s][1] * OBJECTS_scale * WIN3D.scale, (subFace[s][2] - CrustDepth) * OBJECTS_scale * WIN3D.scale, u * this.Textures_map[n_Map].width, v * this.Textures_map[n_Map].height);
      } else {
        WIN3D.graphics.vertex(subFace[s][0] * OBJECTS_scale * WIN3D.scale, -subFace[s][1] * OBJECTS_scale * WIN3D.scale, subFace[s][2] * OBJECTS_scale * WIN3D.scale);
        WIN3D.graphics.vertex(subFace[s_next][0] * OBJECTS_scale * WIN3D.scale, -subFace[s_next][1] * OBJECTS_scale * WIN3D.scale, subFace[s_next][2] * OBJECTS_scale * WIN3D.scale);
        WIN3D.graphics.vertex(subFace[s_next][0] * OBJECTS_scale * WIN3D.scale, -subFace[s_next][1] * OBJECTS_scale * WIN3D.scale, (subFace[s_next][2] - CrustDepth) * OBJECTS_scale * WIN3D.scale);
        WIN3D.graphics.vertex(subFace[s][0] * OBJECTS_scale * WIN3D.scale, -subFace[s][1] * OBJECTS_scale * WIN3D.scale, (subFace[s][2] - CrustDepth) * OBJECTS_scale * WIN3D.scale);
      }
      WIN3D.graphics.endShape(CLOSE);
    }
  }

  private void drawLandPoints () {
    if (!this.displayPoints) return;

    WIN3D.graphics.fill(191, 191, 0);
    WIN3D.graphics.noStroke();
    WIN3D.graphics.sphereDetail(6, 4);

    for (int i = 0; i < this.num_rows; i++) {
      for (int j = 0; j < this.num_columns; j++) {
        float x = this.Mesh[i][j][0];
        float y = this.Mesh[i][j][1];
        float z = this.Mesh[i][j][2];
        float R = 2.0 * OBJECTS_scale;

        WIN3D.graphics.pushMatrix();
        WIN3D.graphics.translate(x * OBJECTS_scale * WIN3D.scale, -y * OBJECTS_scale * WIN3D.scale, z * OBJECTS_scale * WIN3D.scale);
        WIN3D.graphics.sphere(R);
        WIN3D.graphics.popMatrix();
      }
    }
  }

  void castShadows () {
    if (!this.displaySurface) return;

    int tessellation = this.displayTessellation;
    if (WIN3D.FacesShade == SHADE.Surface_Base) tessellation = 0;

    int totalNumberOfSubs = 1;
    if (tessellation > 0) totalNumberOfSubs = 4 * int(funcs.roundTo(pow(4, tessellation - 1), 1)); // x4: a LAND cell has 4 points

    for (int Li = this.skipStart; Li < this.num_rows - 1 - this.skipEnd; Li++) {
      for (int Lj = 0; Lj < this.num_columns - 1; Lj++) {
        float[][] base_Vertices = landCellBaseVertices(Li, Lj);

        for (int n = 0; n < totalNumberOfSubs; n++) {
          float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);
          castLandSubFaceShadow(subFace);
        }
      }
    }
  }

  private void castLandSubFaceShadow (float[][] subFace) {
    for (int s = 0; s < subFace.length; s++) {
      if (allSolarImpacts.sectionType == 2) {
        float a = subFace[s][0];
        float b = -subFace[s][1];
        float c = subFace[s][2];

        subFace[s][0] = a * funcs.cos_ang(-allSolarImpacts.R) - b * funcs.sin_ang(-allSolarImpacts.R);
        subFace[s][1] = c;
        subFace[s][2] = a * funcs.sin_ang(-allSolarImpacts.R) + b * funcs.cos_ang(-allSolarImpacts.R);
      }
      // sectionType == 3: no rotation, kept as in the original
    }

    SHADOW_graphics.beginShape();

    for (int s = 0; s < subFace.length; s++) {
      float z = subFace[s][2] - allSolarImpacts.Z;
      float x = subFace[s][0] - z * SunR_Rotated[1] / SunR_Rotated[3];
      float y = subFace[s][1] - z * SunR_Rotated[2] / SunR_Rotated[3];

      if (z >= 0) {
        if (allSolarImpacts.sectionType == 1) {
          float px = x, py = y;
          x = px * funcs.cos_ang(-allSolarImpacts.R) - py * funcs.sin_ang(-allSolarImpacts.R);
          y = px * funcs.sin_ang(-allSolarImpacts.R) + py * funcs.cos_ang(-allSolarImpacts.R);
        }
        SHADOW_graphics.vertex((x - Shades_offsetX) * Shades_scaleX, -((y - Shades_offsetY) * Shades_scaleY));
      } else {
        castLandShadowClippedEdge(subFace, s, (s + subFace.length - 1) % subFace.length, x, y, z);
        castLandShadowClippedEdge(subFace, s, (s + 1) % subFace.length, x, y, z);
      }
    }

    SHADOW_graphics.endShape(CLOSE);
  }

  // When the current vertex is below the horizon (z < 0) but its neighbor is above it,
  // clip the shadow edge at the horizon and emit that clipped point instead.
  private void castLandShadowClippedEdge (float[][] subFace, int s, int s_neighbor, float x, float y, float z) {
    float z_n = subFace[s_neighbor][2] - allSolarImpacts.Z;
    float x_n = subFace[s_neighbor][0] - z_n * SunR_Rotated[1] / SunR_Rotated[3];
    float y_n = subFace[s_neighbor][1] - z_n * SunR_Rotated[2] / SunR_Rotated[3];

    if (z_n <= 0) return;

    float ratio = z_n / (z_n - z);
    float x_trim = x_n * (1 - ratio) + x * ratio;
    float y_trim = y_n * (1 - ratio) + y * ratio;

    if (allSolarImpacts.sectionType == 1) {
      float px = x_trim, py = y_trim;
      x_trim = px * funcs.cos_ang(-allSolarImpacts.R) - py * funcs.sin_ang(-allSolarImpacts.R);
      y_trim = px * funcs.sin_ang(-allSolarImpacts.R) + py * funcs.cos_ang(-allSolarImpacts.R);
    }

    SHADOW_graphics.vertex((x_trim - Shades_offsetX) * Shades_scaleX, -((y_trim - Shades_offsetY) * Shades_scaleY));
  }


  float[] intersect (float[] ray_pnt, float[] ray_dir) {
    int numCells = (this.num_rows - 1) * (this.num_columns - 1);
    float[] best = { -1, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined };
    float pre_dist = FLOAT_undefined;

    for (int f = 0; f < numCells; f++) {
      float[] hit = intersectLandCell(f, ray_pnt, ray_dir); // {X, Y, Z, dist}, dist == FLOAT_undefined if no hit
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

  // The LAND cell is tested as 4 triangles fanned around its centroid G.
  private float[] intersectLandCell (int f, float[] ray_pnt, float[] ray_dir) {
    float[] miss = { FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined };

    int LAND_i = f / (this.num_columns - 1);
    int LAND_j = f % (this.num_columns - 1);

    float[] A = this.Mesh[LAND_i][LAND_j];
    float[] B = this.Mesh[LAND_i][LAND_j + 1];
    float[] C = this.Mesh[LAND_i + 1][LAND_j + 1];
    float[] D = this.Mesh[LAND_i + 1][LAND_j];
    float[] G = { 0.25 * (A[0] + B[0] + C[0] + D[0]), 0.25 * (A[1] + B[1] + C[1] + D[1]), 0.25 * (A[2] + B[2] + C[2] + D[2]) };

    float X_intersect = FLOAT_undefined;
    float Y_intersect = FLOAT_undefined;
    float Z_intersect = FLOAT_undefined;
    float dist2intersect = FLOAT_undefined;
    boolean InPoly = false;

    for (int i = 0; (i < 4) && !InPoly; i++) {
      float[] M = (i == 0) ? A : (i == 1) ? B : (i == 2) ? C : D;
      float[] N = (i == 0) ? B : (i == 1) ? C : (i == 2) ? D : A;

      float[] NG = funcs.vec3_diff(N, G);
      float[] GM = funcs.vec3_diff(G, M);
      float[] face_norm = funcs.vec3_cross(NG, GM);
      float face_offset = ((G[0] + M[0] + N[0]) * face_norm[0] + (G[1] + M[1] + N[1]) * face_norm[1] + (G[2] + M[2] + N[2]) * face_norm[2]) / 3.0;

      float R = -funcs.vec3_dot(ray_dir, face_norm);
      if ((R < FLOAT_tiny) && (R > -FLOAT_tiny)) continue; // ray parallel to this triangle's plane

      dist2intersect = (funcs.vec3_dot(ray_pnt, face_norm) - face_offset) / R;
      if (dist2intersect <= FLOAT_tiny) continue;

      X_intersect = dist2intersect * ray_dir[0] + ray_pnt[0];
      Y_intersect = dist2intersect * ray_dir[1] + ray_pnt[1];
      Z_intersect = dist2intersect * ray_dir[2] + ray_pnt[2];
      float[] P = { X_intersect, Y_intersect, Z_intersect };

      InPoly = funcs.isInside_Triangle(P, M, N, G);
    }

    if (!InPoly) return miss;
    return new float[] { X_intersect, Y_intersect, Z_intersect, dist2intersect };
  }


  public void to_XML (XML xml) {
    println("Saving:" + this.CLASS_STAMP);
    {
      XML parent = xml.addChild(this.CLASS_STAMP);

      XML_setInt(parent, "displayTessellation", this.displayTessellation);
      XML_setBoolean(parent, "loadTextures", this.loadTextures);
      XML_setBoolean(parent, "loadMesh", this.loadMesh);
      XML_setBoolean(parent, "displaySurface", this.displaySurface);
      XML_setBoolean(parent, "displayPoints", this.displayPoints);
      XML_setBoolean(parent, "displayTexture", this.displayTexture);
      XML_setBoolean(parent, "displayDepth", this.displayDepth);
      XML_setInt(parent, "palette_CLR", this.palette_CLR);
      XML_setInt(parent, "palette_DIR", this.palette_DIR);
      XML_setFloat(parent, "palette_MLT", this.palette_MLT);
      XML_setInt(parent, "skipStart", this.skipStart);
      XML_setInt(parent, "skipEnd", this.skipEnd);
      XML_setInt(parent, "num_rows", this.num_rows);
      XML_setInt(parent, "num_columns", this.num_columns);

      int vNo = 0;
      for (int i = 0; i < this.Mesh.length; i++) {
        for (int j = 0; j < this.Mesh[i].length; j++) {
          XML child = parent.addChild("item");
          XML_setInt(child, "id", vNo);
          String txt = "";
          for (int k = 0; k < 3; k++) { // x, y, z
            txt += nf(this.Mesh[i][j][k], 0, 4).replace(",", ".");
            if (k < this.Mesh[i][j].length - 1) txt += ",";
          }
          XML_setContent(child, txt);
          vNo += 1;
        }
      }
    }

    {
      String the_dir = save_folder;

      for (int q = 0; q < this.Textures_num; q++) {
        int n_Map = q;
        String the_filename = this.Textures_path[n_Map].substring(this.Textures_path[n_Map].lastIndexOf("/") + 1);
        String new_Texture_path = the_dir + "/Textures/" + the_filename;

        if (!this.Textures_path[n_Map].toUpperCase().equals(new_Texture_path.toUpperCase())) {
          println("Copying texture:", this.Textures_path[n_Map], ">", new_Texture_path);
          saveBytes(new_Texture_path, loadBytes(this.Textures_path[n_Map]));
          this.Textures_path[n_Map] = new_Texture_path;
        }
      }

      XML parent = xml.addChild(this.CLASS_STAMP + ".Textures");
      XML_setInt(parent, "ni", this.Textures_num);

      for (int i = 0; i < this.Textures_num; i++) {
        XML child = parent.addChild("item");
        XML_setInt(child, "id", i);
        XML_setFloat(child, "U_scale", this.Textures_U_scale[i]);
        XML_setFloat(child, "V_scale", this.Textures_U_scale[i]);
        XML_setContent(child, this.Textures_path[i]);
      }
    }
  }

  public void from_XML (XML xml) {
    println("Loading:" + this.CLASS_STAMP);
    {
      XML parent = xml.getChild(this.CLASS_STAMP);

      this.displayTessellation = XML_getInt(parent, "displayTessellation");
      this.loadTextures = XML_getBoolean(parent, "loadTextures");
      this.loadMesh = XML_getBoolean(parent, "loadMesh");
      this.displaySurface = XML_getBoolean(parent, "displaySurface");
      this.displayPoints = XML_getBoolean(parent, "displayPoints");
      this.displayTexture = XML_getBoolean(parent, "displayTexture");
      this.displayDepth = XML_getBoolean(parent, "displayDepth");
      this.palette_CLR = XML_getInt(parent, "palette_CLR");
      this.palette_DIR = XML_getInt(parent, "palette_DIR");
      this.palette_MLT = XML_getFloat(parent, "palette_MLT");
      this.skipStart = XML_getInt(parent, "skipStart");
      this.skipEnd = XML_getInt(parent, "skipEnd");
      this.num_rows = XML_getInt(parent, "num_rows");
      this.num_columns = XML_getInt(parent, "num_columns");

      this.Mesh = new float[this.num_rows][this.num_columns][3];

      XML[] children = parent.getChildren("item");
      for (int i = 0; i < this.num_rows * this.num_columns; i++) {
        String txt = XML_getContent(children[i]);
        String[] parts = split(txt, ",");
        for (int j = 0; j < parts.length; j++) {
          this.Mesh[(i / this.num_columns)][(i % this.num_columns)][j] = float(parts[j]);
        }
      }
    }

    {
      XML parent = xml.getChild(this.CLASS_STAMP + ".Textures");

      int pre_Land3D_Textures_num = this.Textures_num;
      this.Textures_num = XML_getInt(parent, "ni");

      if (pre_Land3D_Textures_num != this.Textures_num) {
        int ni = this.Textures_num;
        this.Textures_path = new String[ni];
        this.Textures_map = new PImage[ni];
        for (int i = 0; i < this.Textures_num; i++) {
          this.Textures_path[i] = "";
          this.Textures_map[i] = createImage(2, 2, RGB); // empty and small
        }
      }

      XML[] children = parent.getChildren("item");
      for (int i = 0; i < this.Textures_num; i++) {
        this.Textures_U_scale[i] = children[i].getFloat("U_scale");
        this.Textures_V_scale[i] = children[i].getFloat("V_scale");

        String new_Texture_path = XML_getContent(children[i]);

        if (!this.Textures_path[i].toUpperCase().equals(new_Texture_path.toUpperCase())) {
          this.Textures_path[i] = new_Texture_path;

          if (!this.Textures_path[i].equals("")) {
            println("Loading texture:", this.Textures_path[i]);
            this.Textures_map[i] = loadImage(this.Textures_path[i]);
          }
        }
      }
    }
  }
}
