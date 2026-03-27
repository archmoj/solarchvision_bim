class solarchvision_Sky3D {

  private final static String CLASS_STAMP = "Sky3D";

  boolean displaySurface = true;
  int displayTessellation = 3; //3;
  float scale = 4000000; //25000; //10000; //10km:Troposphere 25km:Ozone layer 100km:Karman line.


  int ACTIVE_pallet_CLR = 18; //-1; //7; //8;
  int ACTIVE_pallet_DIR = 1; //-1;
  float ACTIVE_pallet_MLT = 0.5; //1; //0.25;

  int PASSIVE_pallet_CLR = 18;
  int PASSIVE_pallet_DIR = -1;
  float PASSIVE_pallet_MLT = 0.5;

  float stp_slp;
  float stp_dir;
  int num_slp;
  int num_dir;

  float calculatedResolution = 2.5; //1, 2.5, 5


  void draw (int target_window) {

    boolean proceed = true;

    if (this.displaySurface == false) {
      proceed = false;
    }

    if ((target_window == TypeWindow.STUDY) ||
        (target_window == TypeWindow.WORLD)) {
      proceed = false;
    }


    if (proceed) {

      int PAL_type = 0;
      int PAL_direction = 1;
      float PAL_multiplier = 1;

      if (WIN3D.Impact_TYPE == Impact_ACTIVE) {
        PAL_type = this.ACTIVE_pallet_CLR;
        PAL_direction = this.ACTIVE_pallet_DIR;
        PAL_multiplier = this.ACTIVE_pallet_MLT;
      }
      if (WIN3D.Impact_TYPE == Impact_PASSIVE) {
        PAL_type = this.PASSIVE_pallet_CLR;
        PAL_direction = this.PASSIVE_pallet_DIR;
        PAL_multiplier = this.PASSIVE_pallet_MLT;
      }

      if (target_window == TypeWindow.OBJ3D) {

        if ((WIN3D.FacesShade == SHADE.Global_Solar) ||
            (WIN3D.FacesShade == SHADE.Vertex_Solar)) {

          String the_filename = "";
          String TEXTURE_path = "";

          if (User3D.export_MaterialLibrary) {

            the_filename = "skyPatternPallet.bmp";

            TEXTURE_path = Folder_Export3D + "/" + Subfolder_exportMaps + the_filename;

            println("Saving texture:", TEXTURE_path);

            int RES1 = User3D.export_PalletResolution;
            int RES2 = User3D.export_PalletResolution / 16;

            PImage pallet_Texture = createImage(RES1, RES2, ARGB);


            pallet_Texture.loadPixels();

            for (int np = 0; np < (RES1 * RES2); np++) {
              int Image_X = np % RES1;
              int Image_Y = np / RES1;

              float _val = (Image_X / (0.5 * RES1)) - 1;

              float _u = 0.5 + _val;

              if (WIN3D.Impact_TYPE == Impact_ACTIVE) _u = 0.5 + 0.5 * _val;

              float[] COL = PAINT.getColorStyle(PAL_type, _u);

              pallet_Texture.pixels[np] = color(COL[1], COL[2], COL[3], COL[0]);
            }

            pallet_Texture.updatePixels();

            pallet_Texture.save(TEXTURE_path);


            mtlOutput.println("newmtl " + the_filename.replace('.', '_'));
            mtlOutput.println("\tilum 2"); // 0:Color on and Ambient off, 1:Color on and Ambient on, 2:Highlight on, etc.
            mtlOutput.println("\tKa 1.000 1.000 1.000"); // ambient
            mtlOutput.println("\tKd 1.000 1.000 1.000"); // diffuse
            mtlOutput.println("\tKs 0.000 0.000 0.000"); // specular
            mtlOutput.println("\tNs 10.00"); // 0-1000 specular exponent
            mtlOutput.println("\tNi 1.500"); // 0.001-10 (glass:1.5) optical_density (index of refraction)

            mtlOutput.println("\td 1.000"); //  0-1 transparency  d = Tr, or maybe d = 1 - Tr
            mtlOutput.println("\tTr 1.000"); //  0-1 transparency
            mtlOutput.println("\tTf 1.000 1.000 1.000"); //  transmission filter

            //mtlOutput.println("\tmap_Ka " + Subfolder_exportMaps + the_filename); // ambient map
            mtlOutput.println("\tmap_Kd " + Subfolder_exportMaps + the_filename); // diffuse map
          }

          obj_lastGroupNumber += 1;
          objOutput.println("g skyPattern");

          if (User3D.export_MaterialLibrary) {
            objOutput.println("usemtl " +  the_filename.replace('.', '_'));
          }

          num_vertices_added = 0;

          for (int _turn = 1; _turn < 4; _turn++) {

            for (int f = 0; f < skyFaces.length; f++) {

              int tessellation = 0;

              int totalNumberOfSubs = 1;
              tessellation = Sky3D.displayTessellation;
              if (tessellation > 0) totalNumberOfSubs = skyFaces[f].length * int(funcs.roundTo(pow(4, tessellation - 1), 1));

              float[][] base_Vertices = new float [skyFaces[f].length][3];
              for (int j = 0; j < skyFaces[f].length; j++) {
                int vNo = skyFaces[f][j];
                base_Vertices[j][0] = skyVertices[vNo][0];
                base_Vertices[j][1] = skyVertices[vNo][1];
                base_Vertices[j][2] = skyVertices[vNo][2];
              }

              for (int n = 0; n < totalNumberOfSubs; n++) {

                float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

                for (int j = 0; j < subFace.length; j++) {
                  subFace[j] = funcs.vec3_unit(subFace[j]);
                }



                for (int s = 0; s < subFace.length; s++) {

                  int s_next = (s + 1) % subFace.length;
                  int s_prev = (s + subFace.length - 1) % subFace.length;

                  float x = subFace[s][0] * Sky3D.scale * WIN3D.scale;
                  float y = subFace[s][1] * Sky3D.scale * WIN3D.scale;
                  float z = subFace[s][2] * Sky3D.scale * WIN3D.scale;

                  float _u = SHADE.vertexU_Global_Solar(subFace[s], subFace[s_prev], subFace[s_next], PAL_type, PAL_direction, PAL_multiplier);


                  if (_turn == 1) {

                    SOLARCHVISION_OBJprintVertex(x, y, z);
                  }

                  if (_turn == 2) {
                    float u1 = 0.5 * (_u + 0.5);

                    if ((WIN3D.FacesShade == SHADE.Global_Solar) ||
                        (WIN3D.FacesShade == SHADE.Vertex_Solar)) {

                      if  (WIN3D.Impact_TYPE == Impact_ACTIVE) u1 = _u;
                    }

                    if (u1 > 0.999) u1 = 0.999;
                    if (u1 < 0.001) u1 = 0.001;

                    SOLARCHVISION_OBJprintVtexture(u1, 0.5, 0);
                  }

                  if (_turn == 3) {
                    num_vertices_added += 1;
                  }
                }

                if (_turn == 3) {
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
              }
            }
          }

          obj_lastVertexNumber += num_vertices_added;
          obj_lastVtextureNumber += num_vertices_added;
        }
      }

      if (target_window == TypeWindow.WIN3D) {

        if ((WIN3D.FacesShade == SHADE.Global_Solar) ||
            (WIN3D.FacesShade == SHADE.Vertex_Solar)) {

          for (int f = 0; f < skyFaces.length; f++) {

            int tessellation = 0;

            int totalNumberOfSubs = 1;
            tessellation = this.displayTessellation;
            if (tessellation > 0) totalNumberOfSubs = skyFaces[f].length * int(funcs.roundTo(pow(4, tessellation - 1), 1));

            float[][] base_Vertices = new float [skyFaces[f].length][3];
            for (int j = 0; j < skyFaces[f].length; j++) {
              int vNo = skyFaces[f][j];
              base_Vertices[j][0] = skyVertices[vNo][0];
              base_Vertices[j][1] = skyVertices[vNo][1];
              base_Vertices[j][2] = skyVertices[vNo][2];
            }

            for (int n = 0; n < totalNumberOfSubs; n++) {

              float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

              for (int j = 0; j < subFace.length; j++) {
                subFace[j] = funcs.vec3_unit(subFace[j]);
              }

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
          }
        } else {

          color c = color(191, 191, 255);

          WIN3D.graphics.noStroke();

          if (WIN3D.FacesShade == SHADE.Surface_Materials) {
            WIN3D.graphics.fill(c);
            //WIN3D.graphics.noFill();
          } else {
            WIN3D.graphics.fill(c);
          }

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

      }
    }
  }

  public void to_XML (XML xml) {

    println("Saving:" + this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setBoolean(parent, "displaySurface", this.displaySurface);
    XML_setInt(parent, "displayTessellation", this.displayTessellation);
    XML_setFloat(parent, "scale", this.scale);
    XML_setInt(parent, "ACTIVE_pallet_CLR", this.ACTIVE_pallet_CLR);
    XML_setInt(parent, "ACTIVE_pallet_DIR", this.ACTIVE_pallet_DIR);
    XML_setFloat(parent, "ACTIVE_pallet_MLT", this.ACTIVE_pallet_MLT);
    XML_setInt(parent, "PASSIVE_pallet_CLR", this.PASSIVE_pallet_CLR);
    XML_setInt(parent, "PASSIVE_pallet_DIR", this.PASSIVE_pallet_DIR);
    XML_setFloat(parent, "PASSIVE_pallet_MLT", this.PASSIVE_pallet_MLT);

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
    this.ACTIVE_pallet_CLR = XML_getInt(parent, "ACTIVE_pallet_CLR");
    this.ACTIVE_pallet_DIR = XML_getInt(parent, "ACTIVE_pallet_DIR");
    this.ACTIVE_pallet_MLT = XML_getFloat(parent, "ACTIVE_pallet_MLT");
    this.PASSIVE_pallet_CLR = XML_getInt(parent, "PASSIVE_pallet_CLR");
    this.PASSIVE_pallet_DIR = XML_getInt(parent, "PASSIVE_pallet_DIR");
    this.PASSIVE_pallet_MLT = XML_getFloat(parent, "PASSIVE_pallet_MLT");

    this.stp_slp = XML_getFloat(parent, "stp_slp");
    this.stp_dir = XML_getFloat(parent, "stp_dir");
    this.num_slp = XML_getInt(parent, "num_slp");
    this.num_dir = XML_getInt(parent, "num_dir");

    this.calculatedResolution = XML_getFloat(parent, "calculatedResolution");
  }
}
