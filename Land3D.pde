class solarchvision_Land3D {

  private final static String CLASS_STAMP = "Land3D";

  boolean loadMesh = true;
  boolean loadTextures = true;

  boolean displaySurface = true;
  boolean displayPoints = false;
  boolean displayTexture = true;
  boolean displayDepth = false;

  int displayTessellation = 0; //0; //2;

  int pallet_CLR = 1;
  int pallet_DIR = -1;
  float pallet_MLT = 0.05;

  float[][][] Mesh;

  float[] Textures_U_scale;
  float[] Textures_V_scale;
  PImage[] Textures_map;
  String[] Textures_path;
  int Textures_num = 0;


  //Polar
  int num_rows = 12; // 24;
  int num_columns = 24 + 1; // 48 + 1;

  int skipStart = 1;
  int skipEnd = 0;


  void update_textures () {

    this.Textures_U_scale = new float [0];
    this.Textures_V_scale = new float [0];
    this.Textures_map = new PImage [0];
    this.Textures_path = new String [0];
    this.Textures_num = 0;

    this.displayTexture = false;

    if (this.loadTextures) {

      try {

        String[] filenames = sort(OPESYS.getFiles(Folder_Land)); // important to sort

        if (filenames != null) {
          for (int i = 0; i < filenames.length; i++) {
            println(filenames[i]);

            int _L = filenames[i].length();
            String _Extention = filenames[i].substring(_L - 4, _L);
            //println(_Extention);
            if (_Extention.toLowerCase().equals(".jpg")) {

              String[] Parts = split(filenames[i], '_');

              if (Parts[0].toUpperCase().equals("ELEV")) {

                if (Parts.length > 1) {

                  String dir = Folder_Land + "/" + filenames[i];

                  {
                    String[] new_item = {
                      dir
                    };

                    this.Textures_path = (String[]) concat(this.Textures_path, new_item);
                  }

                  float u = float(Parts[1]);
                  float v = u;

                  {
                    PImage[] new_item = {
                      loadImage(dir)
                    };

                    this.Textures_map = (PImage[]) concat(this.Textures_map, new_item);

                    int w = new_item[0].width;
                    int h = new_item[0].height;

                    if (w < h) {
                      if (h != 0) {
                        u *= w / (1.0 * h);
                      }
                    }

                    if (w > h) {
                      if (w != 0) {
                        v *= h / (1.0 * w);
                      }
                    }

                  }



                  {
                    float[] new_item = {
                      u
                    };

                    this.Textures_U_scale = (float[]) concat(this.Textures_U_scale, new_item);
                  }

                  {
                    float[] new_item = {
                      v
                    };

                    this.Textures_V_scale = (float[]) concat(this.Textures_V_scale, new_item);
                  }

                  this.Textures_num += 1;


                  this.displayTexture = true;
                }
              }
            }
          }
        }
      }
      catch (Exception e) {
        println("ERROR loading this.Textures_map!");
      }
    }

    SOLARCHVISION_view_changed();
  }




  void update_mesh () {

    this.Mesh = new float [this.num_rows][this.num_columns][3];

    for (int i = 0; i < this.num_rows; i++) {
      for (int j = 0; j < this.num_columns; j++) {
        this.Mesh[i][j][0] = FLOAT_undefined;
        this.Mesh[i][j][1] = FLOAT_undefined;
        this.Mesh[i][j][2] = FLOAT_undefined;
      }
    }

    Boolean using_default_mesh = false;

    try {

      if (this.loadMesh) {

        for (int i = 0; i < this.num_rows; i++) {

          XML FileALL = loadXML(Folder_Land + "/" + nf(i, 0) + ".xml");

          XML[] children0 = FileALL.getChildren("result");

          for (int j = 0; j < this.num_columns; j++) {

            String txt_elevation = children0[j].getChild("elevation").getContent();

            XML[] children1 = children0[j].getChildren("location");

            String txt_latitude = children1[0].getChild("lat").getContent();
            String txt_longitude = children1[0].getChild("lng").getContent();

            //println(txt_longitude, txt_latitude, txt_elevation);

            double _lon = Double.parseDouble(txt_longitude);
            double _lat = Double.parseDouble(txt_latitude);

            float[] XY = funcs.convert_lonlat2XY(STATION.getLongitude(), STATION.getLatitude(), _lon, _lat);

            float x = XY[0];
            float y = XY[1];
            float z = float(txt_elevation);

            this.Mesh[i][j][0] = x;
            this.Mesh[i][j][1] = y;
            this.Mesh[i][j][2] = z;
          }
        }

        float h = this.Mesh[0][0][2];

        h += HeightAboveGround;

        for (int i = 0; i < this.num_rows; i++) {
          for (int j = 0; j < this.num_columns; j++) {

            this.Mesh[i][j][2] -= h;
          }
        }

        /*
        // this is to modify the surronding ponits and set them at the same elevation of the the central point
        for (int j = 0; j < 2; j++) {
          if (j < this.num_columns) {
            for (int i = 0; i < this.num_rows; i++) {
              this.Mesh[i][j][2] = this.Mesh[0][0][2];
            }
          }
        }
        */

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



  void flat_mesh () {

    this.Mesh = new float [this.num_rows][this.num_columns][3];

    for (int i = 0; i < this.num_rows; i++) {


      for (int j = 0; j < this.num_columns; j++) {


        double[] LON_LAT = getLandGrid(i,j);

        double _lon = LON_LAT[0];
        double _lat = LON_LAT[1];

        float[] XY = funcs.convert_lonlat2XY(STATION.getLongitude(), STATION.getLatitude(), _lon, _lat);

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

    //float q = 2;
    float q = pow(2, 0.5);
    //float q = 1.25;
    //float q = 1.125;

    float t = j * 360.0 / (this.num_columns - 1);

    float r = 0;
    if (i > 0) r = pow(q, i - 1);

    double _lon = STATION.getLongitude() + stp_lon * r * funcs.cos_ang(t);
    double _lat = STATION.getLatitude() + stp_lat * r * funcs.sin_ang(t);

    double[] LON_LAT = {_lon, _lat};

    return LON_LAT;

  }



  void download_mesh () {

    this.Mesh = new float [this.num_rows][this.num_columns][3];

    for (int i = 0; i < this.num_rows; i++) {

      String the_target = Folder_Land + "/" + nf(i, 0) + ".xml";

      File dir = new File(the_target);
      if (!dir.isFile()) {

        String the_link = "";

        for (int j = 0; j < this.num_columns; j++) {

          if (the_link.equals("")) the_link = "https://maps.googleapis.com/maps/api/elevation/xml?locations=";
          else the_link += "%7C"; //"|";

          double[] LON_LAT = getLandGrid(i,j);

          String txt_latitude = nf((float) LON_LAT[1], 0, 5);
          String txt_longitude = nf((float) LON_LAT[0], 0, 5);

          the_link += txt_latitude + "," + txt_longitude;
        }

        println("Try downloading: " + the_link);

        try {
          saveBytes(the_target, loadBytes(the_link));
        }
        catch (Exception e) {
          println("LINK NOT AVAILABLE:", the_link);
        }
      }

    }

    this.loadMesh = true;
    this.update_mesh();

  }


  void download_textures () {

    float[] ratios = {
      1128.497220,
      2256.994440,
      4513.988880,
      9027.977761,
      18055.95552,
      36111.91104,
      72223.82209,
      144447.6442,
      288895.2884,
      577790.5767,
      1155581.153,
      2311162.307,
      4622324.614,
      9244649.227,
      18489298.45,
      36978596.91,
      73957193.82,
      147914387.6,
      295828775.3,
      591657550.5
    };

    for (int i = 0; i <= 15; i++) {

      String the_target = Folder_Land + "/ELEV_" + nf(int(0.05 * ratios[i]), 7) + "_.jpg";

      File dir = new File(the_target);
      if (!dir.isFile()) {

        String the_link = "https://maps.googleapis.com/maps/api/staticmap?center=" + nf(STATION.getLatitude(), 0, 5) + "," + nf(STATION.getLongitude(), 0, 5) + "&zoom=" + nf(20 - i, 0) + "&size=640x640&maptype=satellite&format=jpg";

        println("Try downloading: " + the_link);

        try {
          saveBytes(the_target, loadBytes(the_link));
        }
        catch (Exception e) {
          println("LINK NOT AVAILABLE:", the_link);
        }
      }
    }

    this.loadTextures = true;
    this.update_textures();

  }




  void draw (int target_window) {

    boolean proceed = true;

    if ((this.displaySurface == false) || (this.loadMesh == false)) {
      proceed = false;
    }

    if ((target_window == TypeWindow.STUDY) ||
        (target_window == TypeWindow.WORLD)) {
      proceed = false;
    }
    /*
    if ((target_window == TypeWindow.LandGap) || (target_window == TypeWindow.LandMesh)) {
      proceed = true;
    }
    */
    if (proceed) {

      int PAL_type = SHADE.get_PAL_type();
      int PAL_direction = SHADE.get_PAL_direction();
      float PAL_multiplier = SHADE.get_PAL_multiplier();

      if (User3D.export_MaterialLibrary) {

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
            mtlOutput.println("\tilum 2"); // 0:Color on and Ambient off, 1:Color on and Ambient on, 2:Highlight on, etc.
            mtlOutput.println("\tKa 1.000 1.000 1.000"); // ambient
            mtlOutput.println("\tKd 1.000 1.000 1.000"); // diffuse
            mtlOutput.println("\tKs 0.000 0.000 0.000"); // specular
            mtlOutput.println("\tNs 10.00"); // 0-1000 specular exponent
            mtlOutput.println("\tNi 1.500"); // 0.001-10 (glass:1.5) optical_density (index of refraction)

            mtlOutput.println("\td 1.000"); //  0-1 transparency  d = Tr, or maybe d = 1 - Tr
            mtlOutput.println("\tTr 1.000"); //  0-1 transparency
            mtlOutput.println("\tTf 1.000 1.000 1.000"); //  transmission filter

          }


          if ((target_window == TypeWindow.HTML) ||
              (target_window == TypeWindow.OBJ3D)) {

            if (this.displayTexture) {
              if (n_Map != -1) {

                String old_Texture_path = this.Textures_path[n_Map];

                String the_filename = old_Texture_path.substring(old_Texture_path.lastIndexOf("/") + 1); // image name

                String new_Texture_path = Folder_Export3D + "/" + Subfolder_exportMaps + the_filename;

                println("Copying texture:", old_Texture_path, ">", new_Texture_path);
                saveBytes(new_Texture_path, loadBytes(old_Texture_path));


                if (target_window == TypeWindow.OBJ3D) {

                  //mtlOutput.println("\tmap_Ka " + Subfolder_exportMaps + the_filename); // ambient map
                  mtlOutput.println("\tmap_Kd " + Subfolder_exportMaps + the_filename); // diffuse map
                  mtlOutput.println("\tmap_d " + Subfolder_exportMaps + the_filename); // diffuse map
                }

                if (target_window == TypeWindow.HTML) {
                  htmlOutput.println("\t\t\t\t\t<ImageTexture url='"+ Subfolder_exportMaps + the_filename + "'><ImageTexture/>");
                }

              }
            }
          }


          if (target_window == TypeWindow.HTML) {
            htmlOutput.println("\t\t\t\t</Appearance>");
          }

        }

      }

      if ((target_window == TypeWindow.LandGap) ||
          (target_window == TypeWindow.LandMesh)) {

        current_Material = User3D.default_Material;
        current_Tessellation = User3D.default_Tessellation;
        current_Layer = User3D.default_Layer;
        current_Visibility = User3D.default_Visibility;
        current_Weight = User3D.default_Weight;
        current_Closed = User3D.default_Closed;

        allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);

      }


      num_vertices_added = 0;

      int end_turn = 1;
      if (target_window == TypeWindow.OBJ3D) end_turn = 3;
      for (int _turn = 1; _turn <= end_turn; _turn++) {


        if (target_window == TypeWindow.OBJ3D) {

          if (_turn == 3) {

            if (this.displayTexture) {

              obj_lastGroupNumber += 1;
              objOutput.println("g LandMap");

            }
          }
        }



        int tessellation = this.displayTessellation;
        if (WIN3D.FacesShade == SHADE.Surface_Base) {
          tessellation = 0;
        }

        if ((target_window == TypeWindow.LandGap) ||
            (target_window == TypeWindow.LandMesh)) {
          tessellation = 0;
        }

        int totalNumberOfSubs = 1;
        if (tessellation > 0) totalNumberOfSubs = 4 * int(funcs.roundTo(pow(4, tessellation - 1), 1)); // = 4 * ... because in LAND grid the cell has 4 points.

        int i_start = this.skipStart;
        int i_end = this.num_rows - 1 - this.skipEnd;

        if (target_window == TypeWindow.LandGap) {
          i_start = 0;
          i_end = this.skipStart;

          target_window = TypeWindow.LandMesh; // because the rest is simillar to that
        }


        for (int i = i_start; i < i_end; i++) {

          for (int j = 0; j < this.num_columns - 1; j++) {

            float[][] base_Vertices = new float [4][3];

            base_Vertices[0][0] = this.Mesh[i][j][0];
            base_Vertices[0][1] = this.Mesh[i][j][1];
            base_Vertices[0][2] = this.Mesh[i][j][2];

            base_Vertices[1][0] = this.Mesh[i+1][j][0];
            base_Vertices[1][1] = this.Mesh[i+1][j][1];
            base_Vertices[1][2] = this.Mesh[i+1][j][2];

            base_Vertices[2][0] = this.Mesh[i+1][j+1][0];
            base_Vertices[2][1] = this.Mesh[i+1][j+1][1];
            base_Vertices[2][2] = this.Mesh[i+1][j+1][2];

            base_Vertices[3][0] = this.Mesh[i][j+1][0];
            base_Vertices[3][1] = this.Mesh[i][j+1][1];
            base_Vertices[3][2] = this.Mesh[i][j+1][2];

            for (int n = 0; n < totalNumberOfSubs; n++) {

              float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

              int n_Map = -1;
              if (this.displayTexture) {

                for (int q = 0; q < this.Textures_num; q++) { // increase the resolution until all the vertices located inside the appropriate map

                  n_Map = q;

                  for (int s = 0; s < subFace.length; s++) {

                    float u = (subFace[s][0] / this.Textures_U_scale[q] + 0.5);
                    float v = (-subFace[s][1] / this.Textures_V_scale[q] + 0.5);

                    //if ((0 > u) || (u > 1) || (0 > v) || (v > 1)) {
                    if ((0.05 > u) || (u > 0.95) || (0.05 > v) || (v > 0.95)) { // simply not to include the legends printed at the margin

                      n_Map = -1;

                      break;
                    }
                  }

                  if (n_Map == q) break;
                }
              }

              if (target_window == TypeWindow.SKY2D) {

                SKY2D_graphics.beginShape();
                SKY2D_graphics.fill(255);
                SKY2D_graphics.noStroke();

              }

              if (target_window == TypeWindow.WIN3D) {

                WIN3D.graphics.beginShape();

                WIN3D.graphics.strokeWeight(1);
                WIN3D.graphics.stroke(0, 0, 0);
                if (allFaces.displayEdges == false) WIN3D.graphics.noStroke();
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

              if (target_window == TypeWindow.OBJ3D) {

                if (_turn == 3) {

                  if (this.displayTexture) {

                    if (User3D.export_MaterialLibrary) {
                      if (n_Map != -1) {
                        objOutput.println("usemtl LandMap" + nf(n_Map, 0));
                      }
                    }
                  }
                }
              }

              if (target_window == TypeWindow.HTML) {

                htmlOutput.println("\t\t\t\t<shape>");

                if (n_Map != -1) {
                  htmlOutput.println("\t\t\t\t\t<Appearance USE='LandMap" + nf(n_Map, 0) + "'></Appearance>");
                }

                htmlOutput.print  ("\t\t\t\t\t<IndexedFaceSet solid='false'"); // force two-sided

                htmlOutput.print  (" coordIndex='");
                for (int s = 0; s < subFace.length; s++) {
                  if (s > 0) {
                    htmlOutput.print(" ");
                  }
                  htmlOutput.print(nf(s, 0));
                }
                htmlOutput.println(" -1'>");

                htmlOutput.print  ("\t\t\t\t\t\t<Coordinate point='");
                for (int s = 0; s < subFace.length; s++) {
                  if (s > 0) {
                    htmlOutput.print(",");
                  }

                  htmlOutput.print(nf(subFace[s][0], 0, User3D.export_PrecisionVertex) + " " + nf(subFace[s][1], 0, User3D.export_PrecisionVertex) + " " + nf(subFace[s][2], 0, User3D.export_PrecisionVertex));
                }
                htmlOutput.println("'></Coordinate>");

              }





              for (int s = 0; s < subFace.length; s++) {

                if (target_window == TypeWindow.SKY2D) {
                  SKY2D_graphics.vertex(subFace[s][0], -subFace[s][1], subFace[s][2]);
                }

                if (this.displayTexture == false) {

                  if (WIN3D.FacesShade != SHADE.Surface_Wire) {

                    float[] COL = {
                      255, 255, 255, 255
                    };

                    if (WIN3D.FacesShade == SHADE.Global_Solar) {
                      int s_next = (s + 1) % subFace.length;
                      int s_prev = (s + subFace.length - 1) % subFace.length;

                      COL = SHADE.vertexRender_Global_Solar(subFace[s], subFace[s_prev], subFace[s_next], PAL_type, PAL_direction, PAL_multiplier);
                    }

                    if (WIN3D.FacesShade == SHADE.Vertex_Solar) {

                      COL = SHADE.vertexRender_Vertex_Solar(subFace[s], PAL_type, PAL_direction, PAL_multiplier);
                    }

                    if (WIN3D.FacesShade == SHADE.Vertex_Solid) {

                      COL = SHADE.vertexRender_Vertex_Solid(subFace[s], PAL_type, PAL_direction, PAL_multiplier);
                    }

                    if (WIN3D.FacesShade == SHADE.Vertex_Elevation) {

                      COL = SHADE.vertexRender_Vertex_Elevation(subFace[s], PAL_type, PAL_direction, PAL_multiplier);
                    }

                    if (WIN3D.FacesShade == SHADE.Surface_White) {
                      COL = SHADE.vertexRender_Surface_White(255);
                    }

                    if (WIN3D.FacesShade == SHADE.Surface_Materials) {
                      //COL = SHADE.vertexRender_Surface_Materials(mt);
                      COL = SHADE.vertexRender_Surface_White(223);
                    }




                    if (target_window == TypeWindow.WIN3D) {
                      WIN3D.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
                    }
                  } else {

                    if (target_window == TypeWindow.WIN3D) {
                      WIN3D.graphics.noFill();
                    }
                  }

                  if (target_window == TypeWindow.WIN3D) {
                    WIN3D.graphics.vertex(subFace[s][0] * OBJECTS_scale * WIN3D.scale, -subFace[s][1] * OBJECTS_scale * WIN3D.scale, subFace[s][2] * OBJECTS_scale * WIN3D.scale);
                  }

                  if (target_window == TypeWindow.RAD3D) {

                    if (this.displayTexture) {

                      radOutput.println("LandMesh_0" + " polygon " + "LAND");
                      radOutput.println("0");
                      radOutput.println("0");
                      radOutput.println("9");

                      radOutput.println(" " + nf(subFace[0][0], 0, User3D.export_PrecisionVertex) + " " + nf(subFace[0][1], 0, User3D.export_PrecisionVertex) + " " + nf(subFace[0][2], 0, User3D.export_PrecisionVertex));
                      radOutput.println(" " + nf(subFace[1][0], 0, User3D.export_PrecisionVertex) + " " + nf(subFace[1][1], 0, User3D.export_PrecisionVertex) + " " + nf(subFace[1][2], 0, User3D.export_PrecisionVertex));
                      radOutput.println(" " + nf(subFace[2][0], 0, User3D.export_PrecisionVertex) + " " + nf(subFace[2][1], 0, User3D.export_PrecisionVertex) + " " + nf(subFace[2][2], 0, User3D.export_PrecisionVertex));

                      radOutput.println("LandMesh_0" + " polygon " + "LAND");
                      radOutput.println("0");
                      radOutput.println("0");
                      radOutput.println("9");

                      radOutput.println(" " + nf(subFace[2][0], 0, User3D.export_PrecisionVertex) + " " + nf(subFace[2][1], 0, User3D.export_PrecisionVertex) + " " + nf(subFace[2][2], 0, User3D.export_PrecisionVertex));
                      radOutput.println(" " + nf(subFace[3][0], 0, User3D.export_PrecisionVertex) + " " + nf(subFace[3][1], 0, User3D.export_PrecisionVertex) + " " + nf(subFace[3][2], 0, User3D.export_PrecisionVertex));
                      radOutput.println(" " + nf(subFace[0][0], 0, User3D.export_PrecisionVertex) + " " + nf(subFace[0][1], 0, User3D.export_PrecisionVertex) + " " + nf(subFace[0][2], 0, User3D.export_PrecisionVertex));

                    }
                  }



                } else {

                  float u = 0;
                  float v = 0;
                  if (n_Map != -1) {
                    u = (subFace[s][0] / this.Textures_U_scale[n_Map] + 0.5);
                    v = (-subFace[s][1] / this.Textures_V_scale[n_Map] + 0.5);
                  }

                  if (target_window == TypeWindow.WIN3D) {
                    if (n_Map != -1) {
                      WIN3D.graphics.vertex(subFace[s][0] * OBJECTS_scale * WIN3D.scale, -subFace[s][1] * OBJECTS_scale * WIN3D.scale, subFace[s][2] * OBJECTS_scale * WIN3D.scale, u * this.Textures_map[n_Map].width, v * this.Textures_map[n_Map].height);
                    }
                    else {
                      WIN3D.graphics.vertex(subFace[s][0] * OBJECTS_scale * WIN3D.scale, -subFace[s][1] * OBJECTS_scale * WIN3D.scale, subFace[s][2] * OBJECTS_scale * WIN3D.scale);
                    }
                  }

                  if (target_window == TypeWindow.OBJ3D) {

                    if (this.displayTexture) {

                      if (_turn == 1) {
                        SOLARCHVISION_OBJprintVertex(subFace[s][0], subFace[s][1], subFace[s][2]);
                      }
                      if (_turn == 2) {

                        v = 1 - v; // mirroring the image <<<<<<<<<<<<<<<<<<

                        SOLARCHVISION_OBJprintVtexture(u, v, 0);
                      }
                      if (_turn == 3) {
                        num_vertices_added += 1;
                      }
                    }
                  }

                  if (target_window == TypeWindow.LandMesh) {
                    if (i != 0) { // This is to avoid creation of surfaces with duplicate points at the center
                      allPoints.create(subFace[s][0], subFace[s][1], subFace[s][2]);
                    }
                  }


                  if (target_window == TypeWindow.HTML) {

                    if (n_Map != -1) {

                      if (s == 0) {
                        htmlOutput.print  ("\t\t\t\t\t\t<TextureCoordinate point='");
                      }
                      if (s > 0) {
                        htmlOutput.print(",");
                      }

                      v = 1 - v; // mirroring the image <<<<<<<<<<<<<<<<<<
                      SOLARCHVISION_HTMLprintVtexture(u, v);

                      if (s == subFace.length - 1) {
                        htmlOutput.println("'></TextureCoordinate>");
                      }
                    }

                  }

                }
              }


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

              if (target_window == TypeWindow.OBJ3D) {

                if (_turn == 3) {

                  if (this.displayTexture) {

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
                }
              }

              if (target_window == TypeWindow.LandMesh) {
                if (i != 0) { // This is to avoid creation of surfaces with duplicate points at the center
                  int[] newFace = new int[4];
                  newFace[0] = allPoints.getLength() - 4;
                  newFace[1] = allPoints.getLength() - 3;
                  newFace[2] = allPoints.getLength() - 2;
                  newFace[3] = allPoints.getLength() - 1;
                  allFaces.create(newFace);
                }
              }



              if (this.displayTexture) {

                if (this.displayDepth) {


                  if (target_window == TypeWindow.WIN3D) {
                    WIN3D.graphics.fill(223, 223, 223);
                    WIN3D.graphics.noStroke();
                  }

                  for (int s = 0; s < subFace.length; s++) {

                    int s_next = (s + 1) % subFace.length;

                    float u = 0;
                    float v = 0;
                    if (n_Map != -1) {
                      u = (subFace[s][0] / this.Textures_U_scale[n_Map] + 0.5);
                      v = (-subFace[s][1] / this.Textures_V_scale[n_Map] + 0.5);
                    }

                    float u_next = (subFace[s_next][0] / this.Textures_U_scale[n_Map] + 0.5);
                    float v_next = (-subFace[s_next][1] / this.Textures_V_scale[n_Map] + 0.5);

                    if (target_window == TypeWindow.WIN3D) {

                      WIN3D.graphics.beginShape();

                      if (n_Map != -1) {
                        WIN3D.graphics.texture(this.Textures_map[n_Map]);

                        WIN3D.graphics.vertex(subFace[s][0] * OBJECTS_scale * WIN3D.scale, -subFace[s][1] * OBJECTS_scale * WIN3D.scale, subFace[s][2] * OBJECTS_scale * WIN3D.scale, u * this.Textures_map[n_Map].width, v * this.Textures_map[n_Map].height);
                        WIN3D.graphics.vertex(subFace[s_next][0] * OBJECTS_scale * WIN3D.scale, -subFace[s_next][1] * OBJECTS_scale * WIN3D.scale, subFace[s_next][2] * OBJECTS_scale * WIN3D.scale, u_next * this.Textures_map[n_Map].width, v_next * this.Textures_map[n_Map].height);
                        WIN3D.graphics.vertex(subFace[s_next][0] * OBJECTS_scale * WIN3D.scale, -subFace[s_next][1] * OBJECTS_scale * WIN3D.scale, (subFace[s_next][2] - CrustDepth) * OBJECTS_scale * WIN3D.scale, u_next * this.Textures_map[n_Map].width, v_next * this.Textures_map[n_Map].height);
                        WIN3D.graphics.vertex(subFace[s][0] * OBJECTS_scale * WIN3D.scale, -subFace[s][1] * OBJECTS_scale * WIN3D.scale, (subFace[s][2] - CrustDepth) * OBJECTS_scale * WIN3D.scale, u * this.Textures_map[n_Map].width, v * this.Textures_map[n_Map].height);
                      }
                      else {
                        WIN3D.graphics.vertex(subFace[s][0] * OBJECTS_scale * WIN3D.scale, -subFace[s][1] * OBJECTS_scale * WIN3D.scale, subFace[s][2] * OBJECTS_scale * WIN3D.scale);
                        WIN3D.graphics.vertex(subFace[s_next][0] * OBJECTS_scale * WIN3D.scale, -subFace[s_next][1] * OBJECTS_scale * WIN3D.scale, subFace[s_next][2] * OBJECTS_scale * WIN3D.scale);
                        WIN3D.graphics.vertex(subFace[s_next][0] * OBJECTS_scale * WIN3D.scale, -subFace[s_next][1] * OBJECTS_scale * WIN3D.scale, (subFace[s_next][2] - CrustDepth) * OBJECTS_scale * WIN3D.scale);
                        WIN3D.graphics.vertex(subFace[s][0] * OBJECTS_scale * WIN3D.scale, -subFace[s][1] * OBJECTS_scale * WIN3D.scale, (subFace[s][2] - CrustDepth) * OBJECTS_scale * WIN3D.scale);
                      }

                      WIN3D.graphics.endShape(CLOSE);
                    }
                  }
                }
              }
            }
          }



          if (target_window == TypeWindow.LandMesh) {
            // This is to create a polygon around the center
            if (i == 0) {

              int[] newFace = new int[this.num_columns - 1];
              for (int j = 0; j < newFace.length; j++) {
                newFace[j] = allPoints.create(this.Mesh[i + 1][j][0], this.Mesh[i + 1][j][1], this.Mesh[i + 1][j][2]);
              }
              allFaces.create(newFace);
            }
          }
        }
      }

      if (target_window == TypeWindow.OBJ3D) {
        obj_lastVertexNumber += num_vertices_added;
        obj_lastVtextureNumber += num_vertices_added;
      }

      if (target_window == TypeWindow.WIN3D) {
        if (this.displayPoints) {

          WIN3D.graphics.fill(191, 191, 0);
          WIN3D.graphics.noStroke();

          WIN3D.graphics.sphereDetail(6, 4);

          for (int i = 0; i < this.num_rows; i++) {
            for (int j = 0; j < this.num_columns; j++) {

              float x = this.Mesh[i][j][0];
              float y = this.Mesh[i][j][1];
              float z = this.Mesh[i][j][2];

              float R = 2.0 * OBJECTS_scale; // <<<<<<<<<<

              WIN3D.graphics.pushMatrix();
              WIN3D.graphics.translate(x * OBJECTS_scale * WIN3D.scale, -y * OBJECTS_scale * WIN3D.scale, z * OBJECTS_scale * WIN3D.scale);
              WIN3D.graphics.sphere(R);
              WIN3D.graphics.popMatrix();
            }
          }
        }
      }

      if (target_window == TypeWindow.LandMesh) {
        Select3D.Group_ids = new int [1];
        Select3D.Group_ids[0] = allGroups.num - 1;

        Modify3D.weldObjectsVertices_Selection(0);

      }

    }
  }



  void castShadows () {

    if (this.displaySurface) {

      int tessellation = this.displayTessellation;
      if (WIN3D.FacesShade == SHADE.Surface_Base) {
        tessellation = 0;
      }

      int totalNumberOfSubs = 1;
      if (tessellation > 0) totalNumberOfSubs = 4 * int(funcs.roundTo(pow(4, tessellation - 1), 1)); // = 4 * ... because in LAND grid the cell has 4 points.


      for (int Li = this.skipStart; Li < this.num_rows - 1 - this.skipEnd; Li++) {
        for (int Lj = 0; Lj < this.num_columns - 1; Lj++) {

          float[][] base_Vertices = new float [4][3];

          base_Vertices[0][0] = this.Mesh[Li][Lj][0];
          base_Vertices[0][1] = this.Mesh[Li][Lj][1];
          base_Vertices[0][2] = this.Mesh[Li][Lj][2];

          base_Vertices[1][0] = this.Mesh[Li+1][Lj][0];
          base_Vertices[1][1] = this.Mesh[Li+1][Lj][1];
          base_Vertices[1][2] = this.Mesh[Li+1][Lj][2];

          base_Vertices[2][0] = this.Mesh[Li+1][Lj+1][0];
          base_Vertices[2][1] = this.Mesh[Li+1][Lj+1][1];
          base_Vertices[2][2] = this.Mesh[Li+1][Lj+1][2];

          base_Vertices[3][0] = this.Mesh[Li][Lj+1][0];
          base_Vertices[3][1] = this.Mesh[Li][Lj+1][1];
          base_Vertices[3][2] = this.Mesh[Li][Lj+1][2];

          for (int n = 0; n < totalNumberOfSubs; n++) {

            float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);
            float[][] subFace_Rotated = subFace;

            for (int s = 0; s < subFace_Rotated.length; s++) {
              if (allSolarImpacts.sectionType == 2) {
                float a = subFace_Rotated[s][0];
                float b = -subFace_Rotated[s][1];
                float c = subFace_Rotated[s][2];

                subFace_Rotated[s][0] = a * funcs.cos_ang(-allSolarImpacts.R) - b * funcs.sin_ang(-allSolarImpacts.R);
                subFace_Rotated[s][1] = c;
                subFace_Rotated[s][2] = a * funcs.sin_ang(-allSolarImpacts.R) + b * funcs.cos_ang(-allSolarImpacts.R);
              } else if (allSolarImpacts.sectionType == 3) {
              }
            }

            SHADOW_graphics.beginShape();

            for (int s = 0; s < subFace_Rotated.length; s++) {

              float z = subFace_Rotated[s][2] - allSolarImpacts.Z;
              float x = subFace_Rotated[s][0] - z * SunR_Rotated[1] / SunR_Rotated[3];
              float y = subFace_Rotated[s][1] - z * SunR_Rotated[2] / SunR_Rotated[3];



              if (z >= 0) {

                if (allSolarImpacts.sectionType == 1) {
                  float px = x;
                  float py = y;

                  x = px * funcs.cos_ang(-allSolarImpacts.R) - py * funcs.sin_ang(-allSolarImpacts.R);
                  y = px * funcs.sin_ang(-allSolarImpacts.R) + py * funcs.cos_ang(-allSolarImpacts.R);
                }

                SHADOW_graphics.vertex((x - Shades_offsetX) * Shades_scaleX, -((y - Shades_offsetY) * Shades_scaleY));
              } else {
                int s_next = (s + 1) % subFace_Rotated.length;
                int s_prev = (s + subFace_Rotated.length - 1) % subFace_Rotated.length;

                float z_prev = subFace_Rotated[s_prev][2] - allSolarImpacts.Z;
                float x_prev = subFace_Rotated[s_prev][0] - z_prev * SunR_Rotated[1] / SunR_Rotated[3];
                float y_prev = subFace_Rotated[s_prev][1] - z_prev * SunR_Rotated[2] / SunR_Rotated[3];

                if (z_prev > 0) {
                  float ratio = z_prev / (z_prev - z);

                  float x_trim = x_prev * (1 - ratio) + x * ratio;
                  float y_trim = y_prev * (1 - ratio) + y * ratio;

                  if (allSolarImpacts.sectionType == 1) {
                    float px = x_trim;
                    float py = y_trim;

                    x_trim = px * funcs.cos_ang(-allSolarImpacts.R) - py * funcs.sin_ang(-allSolarImpacts.R);
                    y_trim = px * funcs.sin_ang(-allSolarImpacts.R) + py * funcs.cos_ang(-allSolarImpacts.R);
                  }

                  SHADOW_graphics.vertex((x_trim - Shades_offsetX) * Shades_scaleX, -((y_trim - Shades_offsetY) * Shades_scaleY));
                }

                float z_next = subFace_Rotated[s_next][2] - allSolarImpacts.Z;
                float x_next = subFace_Rotated[s_next][0] - z_next * SunR_Rotated[1] / SunR_Rotated[3];
                float y_next = subFace_Rotated[s_next][1] - z_next * SunR_Rotated[2] / SunR_Rotated[3];

                if (z_next > 0) {
                  float ratio = z_next / (z_next - z);

                  float x_trim = x_next * (1 - ratio) + x * ratio;
                  float y_trim = y_next * (1 - ratio) + y * ratio;

                  if (allSolarImpacts.sectionType == 1) {
                    float px = x_trim;
                    float py = y_trim;

                    x_trim = px * funcs.cos_ang(-allSolarImpacts.R) - py * funcs.sin_ang(-allSolarImpacts.R);
                    y_trim = px * funcs.sin_ang(-allSolarImpacts.R) + py * funcs.cos_ang(-allSolarImpacts.R);
                  }

                  SHADOW_graphics.vertex((x_trim - Shades_offsetX) * Shades_scaleX, -((y_trim - Shades_offsetY) * Shades_scaleY));
                }
              }
            }

            SHADOW_graphics.endShape(CLOSE);
          }
        }
      }
    }
  }



  float[] intersect (float[] ray_pnt, float[] ray_dir) {

    float[] ray_normal = funcs.vec3_unit(ray_dir);

    float[][] hitPoint = new float [(this.num_rows - 1) * (this.num_columns - 1)][4];

    for (int f = 0; f < (this.num_rows - 1) * (this.num_columns - 1); f++) {
      hitPoint[f][0] = FLOAT_undefined;
      hitPoint[f][1] = FLOAT_undefined;
      hitPoint[f][2] = FLOAT_undefined;
      hitPoint[f][3] = FLOAT_undefined;
    }

    for (int f = 0; f < (this.num_rows - 1) * (this.num_columns - 1); f++) {

      float X_intersect = FLOAT_undefined;
      float Y_intersect = FLOAT_undefined;
      float Z_intersect = FLOAT_undefined;
      float dist2intersect = FLOAT_undefined;

      boolean InPoly = false;

      int LAND_i = f / (this.num_columns - 1);
      int LAND_j = f % (this.num_columns - 1);

      float[] A = this.Mesh[LAND_i][LAND_j];
      float[] B = this.Mesh[LAND_i][LAND_j + 1];
      float[] C = this.Mesh[LAND_i + 1][LAND_j + 1];
      float[] D = this.Mesh[LAND_i + 1][LAND_j];
      float[] G = {0.25 * (A[0] + B[0] + C[0] + D[0]), 0.25 * (A[1] + B[1] + C[1] + D[1]), 0.25 * (A[2] + B[2] + C[2] + D[2])};

      for (int i = 0; i < 4; i++) {

        float[] M = {0,0,0};
        float[] N = {0,0,0};

        if (i == 0) {
          M = A;
          N = B;
        } else if (i == 1) {
          M = B;
          N = C;
        } else if (i == 2) {
          M = C;
          N = D;
        } else if (i == 3) {
          M = D;
          N = A;
        }

        float[] NG = funcs.vec3_diff(N, G);
        float[] GM = funcs.vec3_diff(G, M);

        float[] face_norm = funcs.vec3_cross(NG, GM);

        float face_offset = ((G[0] + M[0] + N[0]) * face_norm[0] + (G[1] + M[1] + N[1]) * face_norm[1] + (G[2] + M[2] + N[2]) * face_norm[2]) / 3.0;

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

            InPoly = funcs.isInside_Triangle(P, M, N, G);

          }
        }

        if (InPoly) break;
      }

      if (InPoly) {
        hitPoint[f][0] = X_intersect;
        hitPoint[f][1] = Y_intersect;
        hitPoint[f][2] = Z_intersect;
        hitPoint[f][3] = dist2intersect;
      }

    }

    float[] return_point = {-1, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined};

    float pre_dist = FLOAT_undefined;

    for (int f = 0; f < (this.num_rows - 1) * (this.num_columns - 1); f++) {

      if (pre_dist > hitPoint[f][3]) {

        pre_dist = hitPoint[f][3];

        return_point[0] = f;
        return_point[1] = hitPoint[f][0];
        return_point[2] = hitPoint[f][1];
        return_point[3] = hitPoint[f][2];
        return_point[4] = hitPoint[f][3];
      }

    }

    return return_point;
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
      XML_setInt(parent, "pallet_CLR", this.pallet_CLR);
      XML_setInt(parent, "pallet_DIR", this.pallet_DIR);
      XML_setFloat(parent, "pallet_MLT", this.pallet_MLT);
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
          //for (int k = 0; k < this.Mesh[i][j].length; k++) {
          for (int k = 0; k < 3; k++) { // x, y, z
            txt += nf(this.Mesh[i][j][k], 0, 4).replace(",", "."); // <<<<
            if (k < this.Mesh[i][j].length - 1) txt += ",";
          }
          XML_setContent(child, txt);
          vNo += 1;
        }
      }
    }

    {
      boolean TEXTURE_copied = false;

      String the_dir = save_folder;

      for (int q = 0; q < this.Textures_num; q++) {

        int n_Map = q;

        String the_filename = this.Textures_path[n_Map].substring(this.Textures_path[n_Map].lastIndexOf("/") + 1); // image name

        String new_Texture_path = the_dir + "/Textures/" +  the_filename;

        if (this.Textures_path[n_Map].toUpperCase().equals(new_Texture_path.toUpperCase())) {
          TEXTURE_copied = false;
        } else {

          println("Copying texture:", this.Textures_path[n_Map], ">", new_Texture_path);
          saveBytes(new_Texture_path, loadBytes(this.Textures_path[n_Map]));
          this.Textures_path[n_Map] = new_Texture_path;

          TEXTURE_copied = true;
        }

        //if (TEXTURE_copied == false) {
        //  println("Saving texture from the scene.");
        //  this.Textures_map[n_Map].save(new_Texture_path);
        //}
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
      this.pallet_CLR = XML_getInt(parent, "pallet_CLR");
      this.pallet_DIR = XML_getInt(parent, "pallet_DIR");
      this.pallet_MLT = XML_getFloat(parent, "pallet_MLT");
      this.skipStart = XML_getInt(parent, "skipStart");
      this.skipEnd = XML_getInt(parent, "skipEnd");
      this.num_rows = XML_getInt(parent, "num_rows");
      this.num_columns = XML_getInt(parent, "num_columns");


      this.Mesh = new float [this.num_rows][this.num_columns][3];

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
        this.Textures_path = new String [ni];
        this.Textures_map = new PImage [ni];
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

        if (this.Textures_path[i].toUpperCase().equals(new_Texture_path.toUpperCase())) {
        } else {

          this.Textures_path[i] = new_Texture_path;

          if (this.Textures_path[i].equals("")) {
          } else {
            println("Loading texture:", this.Textures_path[i]);
            this.Textures_map[i] = loadImage(this.Textures_path[i]);
          }
        }
      }
    }


  }


}
