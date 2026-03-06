class solarchvision_Faces {

  private final static String CLASS_STAMP = "Faces";

  solarchvision_Faces () { // constructor
    makeEmpty(0);
  }

  boolean displayAll = true;
  boolean displayNormals = false;
  boolean displayEdges = true;

  int displayTessellation = 2;

  int ACTIVE_pallet_CLR = 19; //15; //14;
  int ACTIVE_pallet_DIR = 1;
  float ACTIVE_pallet_MLT = 1;

  int PASSIVE_pallet_CLR = 1;
  int PASSIVE_pallet_DIR = 1;
  float PASSIVE_pallet_MLT = 0.2;


  int[][] nodes;
  int[][] options;

  void makeEmpty (int n) {

    this.nodes = new int [n][0];
    this.options = new int [n][6];

    if (allGroups != null) {
      for (int q = 0; q < allGroups.num; q++) {
        allGroups.Faces[q][0] = 0;
        allGroups.Faces[q][1] = -1;
      }
    }

    if (Select3D != null) {
      Select3D.deselect_Groups();
      Select3D.deselect_Faces();
    }

    SOLARCHVISION_model_changed();
  }


  int getMaterial (int n) {
    return this.options[n][0];
  }

  int getTessellation (int n) {
    return this.options[n][1];
  }

  int getLayer (int n) {
    return this.options[n][2];
  }

  int getVisibility (int n) {
    return this.options[n][3];
  }

  int getWeight (int n) {
    return this.options[n][4];
  }

  int getClose (int n) {
    return this.options[n][5];
  }

  void setMaterial (int n, int material) {
    this.options[n][0] = material;
  }

  void setTessellation (int n, int tessellation) {
    this.options[n][1] = tessellation;
  }

  void setLayer (int n, int layer) {
    this.options[n][2] = layer;
  }

  void setVisibility (int n, int visibility) {
    this.options[n][3] = visibility;
  }

  void setWeight (int n, int weight) {
    this.options[n][4] = weight;
  }

  void setClose (int n, int close) {
    this.options[n][5] = close;
  }


  void beginNewFace () {

    int[] newFace_nodes = {};

    this.create(newFace_nodes);

  }

  void add_VertexToLastFace (float x, float y, float z) {

    int n = this.nodes.length - 1;

    int[] newVertex = {
      allPoints.create(x, y, z)
    };

    this.nodes[n] = (int[]) concat(this.nodes[n], newVertex);

  }




  int create (int[] f) {

    int[][] newFace_options = {
      {
        current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed
      }
    };

    this.options =  (int[][]) concat(this.options, newFace_options);

    int[][] newFace_nodes = {
      f
    };

    this.nodes = (int[][]) concat(this.nodes, newFace_nodes);


    if (allGroups.num > 0) allGroups.Faces[allGroups.num - 1][1] = this.nodes.length - 1;

    return(this.nodes.length - 1);
  }










  void draw (int target_window) {

    if (this.displayAll) {

      if (target_window == TypeWindow.WIN3D) {

        if (this.displayNormals) {

          for (int f = 0; f < this.nodes.length; f++) {

            int vsb = this.getVisibility(f);

            if (vsb > 0) {

              float[][] base_Vertices = new float [this.nodes[f].length][3];
              for (int j = 0; j < this.nodes[f].length; j++) {
                int vNo = this.nodes[f][j];
                base_Vertices[j][0] = allPoints.getX(vNo);
                base_Vertices[j][1] = allPoints.getY(vNo);
                base_Vertices[j][2] = allPoints.getZ(vNo);
              }

              float G_x0 = 0;
              float G_y0 = 0;
              float G_z0 = 0;

              float G_x1 = 0;
              float G_y1 = 0;
              float G_z1 = 0;

              float n = float(base_Vertices.length);

              for (int s = 0; s < base_Vertices.length; s++) {

                int s_next = (s + 1) % base_Vertices.length;
                int s_prev = (s + base_Vertices.length - 1) % base_Vertices.length;

                PVector U = new PVector(base_Vertices[s_next][0] - base_Vertices[s][0], base_Vertices[s_next][1] - base_Vertices[s][1], base_Vertices[s_next][2] - base_Vertices[s][2]);
                PVector V = new PVector(base_Vertices[s_prev][0] - base_Vertices[s][0], base_Vertices[s_prev][1] - base_Vertices[s][1], base_Vertices[s_prev][2] - base_Vertices[s][2]);
                PVector UV = U.cross(V);
                float[] W = {
                  UV.x, UV.y, UV.z
                };
                W = funcs.vec3_unit(W);

                float x0 = base_Vertices[s][0] * OBJECTS_scale * WIN3D.scale;
                float y0 = base_Vertices[s][1] * OBJECTS_scale * WIN3D.scale;
                float z0 = base_Vertices[s][2] * OBJECTS_scale * WIN3D.scale;

                float x1 = (base_Vertices[s][0] + W[0]) * OBJECTS_scale * WIN3D.scale;
                float y1 = (base_Vertices[s][1] + W[1]) * OBJECTS_scale * WIN3D.scale;
                float z1 = (base_Vertices[s][2] + W[2]) * OBJECTS_scale * WIN3D.scale;

                G_x0 += x0 / n;
                G_y0 += y0 / n;
                G_z0 += z0 / n;

                G_x1 += x1 / n;
                G_y1 += y1 / n;
                G_z1 += z1 / n;
              }

              WIN3D.graphics.strokeWeight(3);
              WIN3D.graphics.stroke(127, 255, 127);
              WIN3D.graphics.line(G_x0, -G_y0, G_z0, G_x1, -G_y1, G_z1);

              WIN3D.graphics.strokeWeight(1);
              WIN3D.graphics.stroke(0, 127, 0);

              for (int s = 0; s < base_Vertices.length; s++) {

                float x0 = base_Vertices[s][0] * OBJECTS_scale * WIN3D.scale;
                float y0 = base_Vertices[s][1] * OBJECTS_scale * WIN3D.scale;
                float z0 = base_Vertices[s][2] * OBJECTS_scale * WIN3D.scale;

                WIN3D.graphics.line(x0, -y0, z0, G_x1, -G_y1, G_z1);
              }
            }
          }
        }

        WIN3D.graphics.strokeWeight(1);
        WIN3D.graphics.stroke(0, 0, 0);
        if (this.displayEdges == false) WIN3D.graphics.noStroke();

        int PAL_type = SHADE.get_PAL_type();
        int PAL_direction = SHADE.get_PAL_direction();
        float PAL_multiplier = SHADE.get_PAL_multiplier();

        for (int f = 0; f < this.nodes.length; f++) {

          int vsb = this.getVisibility(f);

          if (vsb > 0) {

            if (WIN3D.FacesShade == SHADE.Surface_Base) {

              WIN3D.graphics.fill(255, 255, 255);

              WIN3D.graphics.beginShape();

              for (int j = 0; j < this.nodes[f].length; j++) {
                int vNo = this.nodes[f][j];

                WIN3D.graphics.vertex(allPoints.getX(vNo) * OBJECTS_scale * WIN3D.scale,
                                     -allPoints.getY(vNo) * OBJECTS_scale * WIN3D.scale,
                                      allPoints.getZ(vNo) * OBJECTS_scale * WIN3D.scale);
              }

              WIN3D.graphics.endShape(CLOSE);
            } else {

              int mt = this.getMaterial(f);

              int tessellation = this.getTessellation(f);

              int totalNumberOfSubs = 1;
              if (this.getMaterial(f) == 0) {
                tessellation += this.displayTessellation;
              }
              if (tessellation > 0) totalNumberOfSubs = this.nodes[f].length * int(funcs.roundTo(pow(4, tessellation - 1), 1));

              float[][] base_Vertices = new float [this.nodes[f].length][3];
              for (int j = 0; j < this.nodes[f].length; j++) {
                int vNo = this.nodes[f][j];
                base_Vertices[j][0] = allPoints.getX(vNo);
                base_Vertices[j][1] = allPoints.getY(vNo);
                base_Vertices[j][2] = allPoints.getZ(vNo);
              }

              for (int n = 0; n < totalNumberOfSubs; n++) {

                float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

                WIN3D.graphics.beginShape();

                for (int s = 0; s < subFace.length; s++) {

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

                    if (WIN3D.FacesShade == SHADE.Surface_Materials) {
                      COL = SHADE.vertexRender_Surface_Materials(mt);
                    }

                    if (WIN3D.FacesShade == SHADE.Surface_White) {
                      COL = SHADE.vertexRender_Surface_White(255);
                    }

                    WIN3D.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
                  } else {
                    WIN3D.graphics.noFill();
                  }

                  WIN3D.graphics.vertex(subFace[s][0] * OBJECTS_scale * WIN3D.scale,
                                       -subFace[s][1] * OBJECTS_scale * WIN3D.scale,
                                        subFace[s][2] * OBJECTS_scale * WIN3D.scale);
                }

                WIN3D.graphics.endShape(CLOSE);
              }
            }
          }
        }
      }


      if (target_window == TypeWindow.OBJ3D) {

        int Create_Face_Texture = 0;

        if ((WIN3D.FacesShade == SHADE.Global_Solar) ||
            (WIN3D.FacesShade == SHADE.Vertex_Solar) ||
            (WIN3D.FacesShade == SHADE.Vertex_Solid) ||
            (WIN3D.FacesShade == SHADE.Vertex_Elevation)) {
          Create_Face_Texture = 1;
        }

        if (Create_Face_Texture == 0) {

          if (User3D.export_MaterialLibrary) {

            int[] used_Materials = new int [allMaterials.Number];

            for (int i = 0; i < used_Materials.length; i++) {
              used_Materials[i] = 0;
            }

            for (int f = 0; f < this.nodes.length; f++) {

              int mt = this.getMaterial(f);

              used_Materials[mt] += 1;
            }

            for (int mt = 0; mt < allMaterials.Number; mt++) {

              if (used_Materials[mt] != 0) {

                float a = allMaterials.Color[mt][0] / 255.0;
                float r = allMaterials.Color[mt][1] / 255.0;
                float g = allMaterials.Color[mt][2] / 255.0;
                float b = allMaterials.Color[mt][3] / 255.0;

                mtlOutput.println("newmtl SurfaceMaterial" + nf(mt, 0));
                mtlOutput.println("\tilum 2"); // 0:Color on and Ambient off, 1:Color on and Ambient on, 2:Highlight on, etc.
                mtlOutput.println("\tKa " + nf(r, 0, 3) + " " + nf(g, 0, 3) + " " + nf(b, 0, 3)); // ambient
                mtlOutput.println("\tKd " + nf(r, 0, 3) + " " + nf(g, 0, 3) + " " + nf(b, 0, 3)); // diffuse
                mtlOutput.println("\tKs 0.000 0.000 0.000"); // specular
                mtlOutput.println("\tNs 10.00"); // 0-1000 specular exponent
                mtlOutput.println("\tNi 1.500"); // 0.001-10 (glass:1.5) optical_density (index of refraction)

                mtlOutput.println("\td " + nf(a, 0, 3)); //  0-1 transparency  d = Tr, or maybe d = 1 - Tr
                mtlOutput.println("\tTr " + nf(a, 0, 3)); //  0-1 transparency
                mtlOutput.println("\tTf 1.000 1.000 1.000"); //  transmission filter
              }
            }
          }


          for (int OBJ_ID = 0; OBJ_ID < allGroups.num; OBJ_ID++) {

            if (allGroups.getStart_Face(OBJ_ID) <= allGroups.getStop_Face(OBJ_ID)) {

              for (int back_or_front = 1 - int(User3D.export_BackSides); back_or_front <= 1; back_or_front++) {

                num_vertices_added = 0;

                for (int _turn = 1; _turn < 4; _turn++) {

                  if (_turn == 3) {
                    if (User3D.export_PolyToPoly == 1) {
                      obj_lastGroupNumber += 1;
                      objOutput.println("g Object3D_" + nf(OBJ_ID, 0) + "_side" + nf(back_or_front, 0));
                    }
                  }

                  int prev_mt = -1;

                  for (int f = allGroups.getStart_Face(OBJ_ID); f <= allGroups.getStop_Face(OBJ_ID); f++) {

                    if (_turn == 3) {
                      if (User3D.export_MaterialLibrary) {
                        int mt = this.getMaterial(f);
                        if (prev_mt != mt) {
                          objOutput.println("usemtl SurfaceMaterial" + nf(mt, 0));
                          prev_mt = mt;
                        }
                      }
                    }

                    int tessellation = this.getTessellation(f);

                    int totalNumberOfSubs = 1;
                    if (this.getMaterial(f) == 0) {
                      tessellation += this.displayTessellation;
                    }

                    if (tessellation > 0) totalNumberOfSubs = this.nodes[f].length * int(funcs.roundTo(pow(4, tessellation - 1), 1));

                    float[][] base_Vertices = new float [this.nodes[f].length][3];
                    for (int j = 0; j < this.nodes[f].length; j++) {
                      int vNo = this.nodes[f][j];
                      base_Vertices[j][0] = allPoints.getX(vNo);
                      base_Vertices[j][1] = allPoints.getY(vNo);
                      base_Vertices[j][2] = allPoints.getZ(vNo);
                    }

                    for (int n = 0; n < totalNumberOfSubs; n++) {

                      float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

                      for (int s = 0; s < subFace.length; s++) {

                        if (_turn == 1) {
                          SOLARCHVISION_OBJprintVertex(subFace[s][0], subFace[s][1], subFace[s][2]);
                        }

                        if (_turn == 2) {

                          float t = PI / float(subFace.length);

                          float u = 0.5 * cos((2 * s + 1) * t) / cos(t) + 0.5;
                          float v = 0.5 * sin((2 * s + 1) * t) / cos(t) + 0.5;

                          SOLARCHVISION_OBJprintVtexture(u, v, 0);
                        }
                      }


                      if (_turn == 3) {

                        num_vertices_added += subFace.length;

                        if (User3D.export_PolyToPoly == 0) {
                          obj_lastGroupNumber += 1;
                          objOutput.println("g Object3D_" + nf(OBJ_ID, 0) + "_side" + nf(back_or_front, 0) + "_face" + nf(f, 0) + "_sub" + nf(n, 0));
                        }

                        obj_lastFaceNumber += 1;

                        objOutput.print("f ");
                        if (back_or_front == 1) {
                          for (int s = 0; s < subFace.length; s++) {
                            String n_txt = nf(obj_lastVertexNumber + num_vertices_added - s, 0);
                            String m_txt = nf(obj_lastVtextureNumber + num_vertices_added - s, 0);
                            objOutput.print(n_txt + "/" + m_txt);
                            if (s < subFace.length - 1) {
                              objOutput.print(" ");
                            }
                          }
                        } else {
                          for (int s = subFace.length - 1; s >= 0; s--) {
                            String n_txt = nf(obj_lastVertexNumber + num_vertices_added - s, 0);
                            String m_txt = nf(obj_lastVtextureNumber + num_vertices_added - s, 0);
                            objOutput.print(n_txt + "/" + m_txt);
                            if (s > 0) {
                              objOutput.print(" ");
                            }
                          }
                        }
                        objOutput.println("");
                      }
                    }
                  }
                }

                obj_lastVertexNumber += num_vertices_added;
                obj_lastVtextureNumber += num_vertices_added;
              }
            }
          }
        } else {

          int PAL_type = SHADE.get_PAL_type();
          int PAL_direction = SHADE.get_PAL_direction();
          float PAL_multiplier = SHADE.get_PAL_multiplier();

          String the_filename = "";
          String TEXTURE_path = "";

          if (User3D.export_MaterialLibrary) {

            the_filename = "shadePallet.bmp";

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

              if ((WIN3D.FacesShade == SHADE.Global_Solar) ||
                  (WIN3D.FacesShade == SHADE.Vertex_Solar)) {
                if (WIN3D.Impact_TYPE == Impact_ACTIVE) _u = 0.5 + 0.5 * _val;
              }

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


          for (int OBJ_ID = 0; OBJ_ID < allGroups.num; OBJ_ID++) {

            if (allGroups.getStart_Face(OBJ_ID) <= allGroups.getStop_Face(OBJ_ID)) {

              for (int back_or_front = 1 - int(User3D.export_BackSides); back_or_front <= 1; back_or_front++) {

                num_vertices_added = 0;

                for (int _turn = 1; _turn < 4; _turn++) {

                  int CurrentFaceTextureNumber = -1;

                  if (_turn == 3) {

                    if (User3D.export_PolyToPoly == 1) {
                      obj_lastGroupNumber += 1;
                      objOutput.println("g Object3D_" + nf(OBJ_ID, 0) + "_side" + nf(back_or_front, 0));
                    }

                    if (User3D.export_MaterialLibrary) {

                      objOutput.println("usemtl " +  the_filename.replace('.', '_'));

                    }
                  }

                  for (int f = allGroups.getStart_Face(OBJ_ID); f <= allGroups.getStop_Face(OBJ_ID); f++) {

                    int tessellation = this.getTessellation(f);

                    int totalNumberOfSubs = 1;
                    if (this.getMaterial(f) == 0) {
                      tessellation += this.displayTessellation;
                    }

                    if (tessellation > 0) totalNumberOfSubs = this.nodes[f].length * int(funcs.roundTo(pow(4, tessellation - 1), 1));

                    float x1 = 0;
                    float y1 = 0;
                    float z1 = 0;

                    float x2 = 0;
                    float y2 = 0;
                    float z2 = 0;

                    float x3 = 0;
                    float y3 = 0;
                    float z3 = 0;

                    float x4 = 0;
                    float y4 = 0;
                    float z4 = 0;

                    float[][] base_Vertices = new float [this.nodes[f].length][3];
                    for (int j = 0; j < this.nodes[f].length; j++) {
                      int vNo = this.nodes[f][j];
                      base_Vertices[j][0] = allPoints.getX(vNo);
                      base_Vertices[j][1] = allPoints.getY(vNo);
                      base_Vertices[j][2] = allPoints.getZ(vNo);
                    }

                    for (int n = 0; n < totalNumberOfSubs; n++) {

                      float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

                      CurrentFaceTextureNumber += 1;

                      if (_turn == 1) {

                        if (User3D.export_MaterialLibrary) {

                          for (int s = 0; s < subFace.length; s++) {

                            float[] COL = {
                              255, 255, 255, 255
                            };

                            if (s == 0) {
                              x1 = subFace[s][0];
                              y1 = subFace[s][1];
                              z1 = subFace[s][2];
                            }
                            if (s == 1) {
                              x2 = subFace[s][0];
                              y2 = subFace[s][1];
                              z2 = subFace[s][2];
                            }
                            if (s == 2) {
                              x3 = subFace[s][0];
                              y3 = subFace[s][1];
                              z3 = subFace[s][2];
                            }
                            if (s == 3) {
                              x4 = subFace[s][0];
                              y4 = subFace[s][1];
                              z4 = subFace[s][2];
                            }
                          }

                        }

                        SOLARCHVISION_OBJprintVertex(x1, y1, z1);
                        SOLARCHVISION_OBJprintVertex(x2, y2, z2);
                        SOLARCHVISION_OBJprintVertex(x3, y3, z3);
                        SOLARCHVISION_OBJprintVertex(x4, y4, z4);
                      }

                      if (_turn == 2) {

                        for (int s = 0; s < subFace.length; s++) {

                          float _u = 0;

                          if (WIN3D.FacesShade == SHADE.Global_Solar) {
                            int s_next = (s + 1) % subFace.length;
                            int s_prev = (s + subFace.length - 1) % subFace.length;

                            if (back_or_front == 0) {
                              int s_temp = s_next;
                              s_next = s_prev;
                              s_prev = s_temp;
                            }

                            _u = SHADE.vertexU_Global_Solar(subFace[s], subFace[s_prev], subFace[s_next], PAL_type, PAL_direction, PAL_multiplier);
                          }

                          if (WIN3D.FacesShade == SHADE.Vertex_Solar) {

                            _u = SHADE.vertexU_Vertex_Solar(subFace[s], PAL_type, PAL_direction, PAL_multiplier);
                          }

                          if (WIN3D.FacesShade == SHADE.Vertex_Solid) {

                            _u = SHADE.vertexU_Vertex_Solid(subFace[s], PAL_type, PAL_direction, PAL_multiplier);
                          }

                          if (WIN3D.FacesShade == SHADE.Vertex_Elevation) {

                            _u = SHADE.vertexU_Vertex_Elevation(subFace[s], PAL_type, PAL_direction, PAL_multiplier);
                          }


                          float u0 = 0.5 * (_u + 0.5);

                          if ((WIN3D.FacesShade == SHADE.Global_Solar) ||
                              (WIN3D.FacesShade == SHADE.Vertex_Solar)) {

                            if (WIN3D.Impact_TYPE == Impact_ACTIVE) {
                              u0 = _u;
                            }
                          }

                          if (u0 > 1) u0 = 1;
                          if (u0 < 0) u0 = 0;

                          SOLARCHVISION_OBJprintVtexture(u0, 0.5, 0);
                        }


                      }

                      if (_turn == 3) {

                        num_vertices_added += 4;

                        if (User3D.export_PolyToPoly == 0) {
                          obj_lastGroupNumber += 1;
                          objOutput.println("g Object3D_" + nf(OBJ_ID, 0) + "_side" + nf(back_or_front, 0) + "_face" + nf(f, 0) + "_sub" + nf(n, 0));
                        }

                        String n1_txt = nf(obj_lastVertexNumber + num_vertices_added - 3, 0);
                        String n2_txt = nf(obj_lastVertexNumber + num_vertices_added - 2, 0);
                        String n3_txt = nf(obj_lastVertexNumber + num_vertices_added - 1, 0);
                        String n4_txt = nf(obj_lastVertexNumber + num_vertices_added - 0, 0);

                        String m1_txt = nf(obj_lastVtextureNumber + num_vertices_added - 3, 0);
                        String m2_txt = nf(obj_lastVtextureNumber + num_vertices_added - 2, 0);
                        String m3_txt = nf(obj_lastVtextureNumber + num_vertices_added - 1, 0);
                        String m4_txt = nf(obj_lastVtextureNumber + num_vertices_added - 0, 0);

                        obj_lastFaceNumber += 1;
                        if (back_or_front == 1) {
                          objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n2_txt + "/" + m2_txt + " " + n3_txt + "/" + m3_txt + " " + n4_txt + "/" + m4_txt);
                        } else {
                          objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n4_txt + "/" + m4_txt + " " + n3_txt + "/" + m3_txt + " " + n2_txt + "/" + m2_txt);
                        }
                      }
                    }
                  }
                }

                obj_lastVertexNumber += num_vertices_added;
                obj_lastVtextureNumber += num_vertices_added;
              }
            }
          }
        }
      }

      if (target_window == TypeWindow.HTML) {

        int Create_Face_Texture = 0;

        if ((WIN3D.FacesShade == SHADE.Global_Solar) ||
            (WIN3D.FacesShade == SHADE.Vertex_Solar) ||
            (WIN3D.FacesShade == SHADE.Vertex_Solid) ||
            (WIN3D.FacesShade == SHADE.Vertex_Elevation)) {

          Create_Face_Texture = 1;
        }

        int PAL_type = SHADE.get_PAL_type();
        int PAL_direction = SHADE.get_PAL_direction();
        float PAL_multiplier = SHADE.get_PAL_multiplier();

        String the_filename = "";
        String TEXTURE_path = "";

        if (User3D.export_MaterialLibrary) {

          if (Create_Face_Texture == 0) {

            int[] used_Materials = new int [allMaterials.Number];

            for (int i = 0; i < used_Materials.length; i++) {
              used_Materials[i] = 0;
            }

            for (int f = 0; f < this.nodes.length; f++) {

              int mt = this.getMaterial(f);

              used_Materials[mt] += 1;
            }

            for (int mt = 0; mt < allMaterials.Number; mt++) {

              if (used_Materials[mt] != 0) {

                htmlOutput.println("\t\t\t\t<Appearance DEF='SurfaceMaterial" + nf(mt, 0) + "'>");
                htmlOutput.print  ("\t\t\t\t\t<Material");
                htmlOutput.print  (" transparency='" + nf(1 - allMaterials.Color[mt][0] / 255.0, 0, 3) + "'");
                htmlOutput.print  (" diffuseColor='" + nf(allMaterials.Color[mt][1] / 255.0, 0, 3) + " " +
                                                       nf(allMaterials.Color[mt][2] / 255.0, 0, 3) + " " +
                                                       nf(allMaterials.Color[mt][3] / 255.0, 0, 3) + "'");
                htmlOutput.println("></Material>");
                htmlOutput.println("\t\t\t\t</Appearance>");

              }
            }

          } else {

            the_filename = "shadePallet.bmp";

            TEXTURE_path = Folder_Export3D + "/" + Subfolder_exportMaps + the_filename;

            htmlOutput.println("\t\t\t\t<Appearance DEF='" + the_filename + "'>");
            htmlOutput.println("\t\t\t\t\t<ImageTexture url='"+ Subfolder_exportMaps + the_filename + "'><ImageTexture/>");
            htmlOutput.println("\t\t\t\t</Appearance>");

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

              if ((WIN3D.FacesShade == SHADE.Global_Solar) ||
                  (WIN3D.FacesShade == SHADE.Vertex_Solar)) {

                if (WIN3D.Impact_TYPE == Impact_ACTIVE) _u = 0.5 + 0.5 * _val;
              }

              float[] COL = PAINT.getColorStyle(PAL_type, _u);

              pallet_Texture.pixels[np] = color(COL[1], COL[2], COL[3], COL[0]);
            }

            pallet_Texture.updatePixels();

            pallet_Texture.save(TEXTURE_path);

          }
        }


        for (int OBJ_ID = 0; OBJ_ID < allGroups.num; OBJ_ID++) {

          if (allGroups.getStart_Face(OBJ_ID) <= allGroups.getStop_Face(OBJ_ID)) {

            htmlOutput.println("\t\t\t\t<group>");

            for (int f = allGroups.getStart_Face(OBJ_ID); f <= allGroups.getStop_Face(OBJ_ID); f++) {

              if (this.nodes[f].length > 2) {

                int mt = this.getMaterial(f);

                int tessellation = this.getTessellation(f);

                int totalNumberOfSubs = 1;
                if (this.getMaterial(f) == 0) {
                  tessellation += this.displayTessellation;
                }

                if (tessellation > 0) totalNumberOfSubs = this.nodes[f].length * int(funcs.roundTo(pow(4, tessellation - 1), 1));

                float[][] base_Vertices = new float [this.nodes[f].length][3];
                for (int j = 0; j < this.nodes[f].length; j++) {
                  int vNo = this.nodes[f][j];
                  base_Vertices[j][0] = allPoints.getX(vNo);
                  base_Vertices[j][1] = allPoints.getY(vNo);
                  base_Vertices[j][2] = allPoints.getZ(vNo);
                }

                for (int n = 0; n < totalNumberOfSubs; n++) {

                  float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

                  for (int back_or_front = 1 - int(User3D.export_BackSides); back_or_front <= 1; back_or_front++) {

                    htmlOutput.println("\t\t\t\t\t<shape>");

                    if (Create_Face_Texture == 0) {
                      htmlOutput.println("\t\t\t\t\t\t<Appearance USE='SurfaceMaterial" + nf(mt, 0) + "'></Appearance>");
                    }
                    else {
                      htmlOutput.println("\t\t\t\t\t\t<Appearance USE='" + the_filename + "'></Appearance>");
                    }


                    htmlOutput.print  ("\t\t\t\t\t\t<IndexedFaceSet");

                    htmlOutput.print  (" coordIndex='");
                    for (int q = 0; q < subFace.length; q++) {
                      if (q > 0) {
                        htmlOutput.print(" ");
                      }
                      htmlOutput.print(nf(q, 0));
                    }
                    htmlOutput.println(" -1'>");

                    htmlOutput.print  ("\t\t\t\t\t\t\t<Coordinate point='");
                    for (int q = 0; q < subFace.length; q++) {
                      if (q > 0) {
                        htmlOutput.print(",");
                      }
                      int s = q;
                      if (back_or_front == 0) {
                        s = subFace.length - 1 - q;
                      }

                      htmlOutput.print(nf(subFace[s][0], 0, User3D.export_PrecisionVertex) + " " +
                                       nf(subFace[s][1], 0, User3D.export_PrecisionVertex) + " " +
                                       nf(subFace[s][2], 0, User3D.export_PrecisionVertex));
                    }
                    htmlOutput.println("'></Coordinate>");






                    if (Create_Face_Texture == 1) {

                      htmlOutput.print  ("\t\t\t\t\t\t\t<TextureCoordinate point='");
                      for (int q = 0; q < subFace.length; q++) {
                        if (q > 0) {
                          htmlOutput.print(",");
                        }
                        int s = q;
                        if (back_or_front == 0) {
                          s = subFace.length - 1 - q;
                        }

                        float _u = 0;


                        if (WIN3D.FacesShade == SHADE.Global_Solar) {
                          int s_next = (s + 1) % subFace.length;
                          int s_prev = (s + subFace.length - 1) % subFace.length;

                          if (back_or_front == 0) {
                            int s_temp = s_next;
                            s_next = s_prev;
                            s_prev = s_temp;
                          }

                          _u = SHADE.vertexU_Global_Solar(subFace[s], subFace[s_prev], subFace[s_next], PAL_type, PAL_direction, PAL_multiplier);
                        }

                        if (WIN3D.FacesShade == SHADE.Vertex_Solar) {

                          _u = SHADE.vertexU_Vertex_Solar(subFace[s], PAL_type, PAL_direction, PAL_multiplier);
                        }

                        if (WIN3D.FacesShade == SHADE.Vertex_Solid) {

                          _u = SHADE.vertexU_Vertex_Solid(subFace[s], PAL_type, PAL_direction, PAL_multiplier);
                        }

                        if (WIN3D.FacesShade == SHADE.Vertex_Elevation) {

                          _u = SHADE.vertexU_Vertex_Elevation(subFace[s], PAL_type, PAL_direction, PAL_multiplier);
                        }


                        float u0 = 0.5 * (_u + 0.5);

                        if ((WIN3D.FacesShade == SHADE.Global_Solar) ||
                            (WIN3D.FacesShade == SHADE.Vertex_Solar)) {

                          if (WIN3D.Impact_TYPE == Impact_ACTIVE) {
                            u0 = _u;
                          }
                        }

                        if (u0 > 1) u0 = 1;
                        if (u0 < 0) u0 = 0;

                        SOLARCHVISION_HTMLprintVtexture(u0, 0.5);
                      }

                      htmlOutput.println("'></TextureCoordinate>");
                    }


                    htmlOutput.println("\t\t\t\t\t\t</IndexedFaceSet>");

                    htmlOutput.println("\t\t\t\t\t</shape>");

                  }
                }
              }
            }
            htmlOutput.println("\t\t\t\t</group>");
          }
        }
      }


      if (target_window == TypeWindow.RAD3D) {

        int[] used_Materials = new int [allMaterials.Number];

        for (int i = 0; i < used_Materials.length; i++) {
          used_Materials[i] = 0;
        }

        for (int f = 0; f < this.nodes.length; f++) {

          int mt = this.getMaterial(f);

          used_Materials[mt] += 1;
        }

        for (int mt = 0; mt < allMaterials.Number; mt++) {

          if (used_Materials[mt] != 0) {

            float a = allMaterials.Color[mt][0] / 255.0;
            float r = allMaterials.Color[mt][1] / 255.0;
            float g = allMaterials.Color[mt][2] / 255.0;
            float b = allMaterials.Color[mt][3] / 255.0;

            radOutput.println("void plastic " + "SurfaceMaterial" + nf(mt, 0));
            radOutput.println("0");
            radOutput.println("0");
            radOutput.println("5 " + nf(r, 0, User3D.export_PrecisionVtexture) + " " +
                                     nf(g, 0, User3D.export_PrecisionVtexture) + " " +
                                     nf(b, 0, User3D.export_PrecisionVtexture) + " 0 0");

          }
        }

        for (int f = 0; f < this.nodes.length; f++) {

          if (this.nodes[f].length > 2) {

            int mt = this.getMaterial(f);

            int tessellation = this.getTessellation(f);

            int totalNumberOfSubs = 1;
            if (this.getMaterial(f) == 0) {
              tessellation += this.displayTessellation;
            }

            if ((this.nodes[f].length > 4) && (tessellation == 0)) { // don't need it for triangles
              tessellation = 1; // <<<<<<<<<< to enforce all polygons having four vertices during baking process
            }

            if (tessellation > 0) totalNumberOfSubs = this.nodes[f].length * int(funcs.roundTo(pow(4, tessellation - 1), 1));

            float[][] base_Vertices = new float [this.nodes[f].length][3];
            for (int j = 0; j < this.nodes[f].length; j++) {
              int vNo = this.nodes[f][j];
              base_Vertices[j][0] = allPoints.getX(vNo);
              base_Vertices[j][1] = allPoints.getY(vNo);
              base_Vertices[j][2] = allPoints.getZ(vNo);
            }

            for (int n = 0; n < totalNumberOfSubs; n++) {

              float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

              for (int back_or_front = 1 - int(User3D.export_BackSides); back_or_front <= 1; back_or_front++) {

                if (back_or_front == 1) {

                  radOutput.println("SurfaceMaterial" + nf(mt, 0) + " polygon " + "FACE");
                  radOutput.println("0");
                  radOutput.println("0");
                  radOutput.println("9");

                  radOutput.println(" " + nf(subFace[0][0], 0, User3D.export_PrecisionVertex) + " " +
                                          nf(subFace[0][1], 0, User3D.export_PrecisionVertex) + " " +
                                          nf(subFace[0][2], 0, User3D.export_PrecisionVertex));
                  radOutput.println(" " + nf(subFace[1][0], 0, User3D.export_PrecisionVertex) + " " +
                                          nf(subFace[1][1], 0, User3D.export_PrecisionVertex) + " " +
                                          nf(subFace[1][2], 0, User3D.export_PrecisionVertex));
                  radOutput.println(" " + nf(subFace[2][0], 0, User3D.export_PrecisionVertex) + " " +
                                          nf(subFace[2][1], 0, User3D.export_PrecisionVertex) + " " +
                                          nf(subFace[2][2], 0, User3D.export_PrecisionVertex));

                  if (subFace.length == 4) {

                    radOutput.println("SurfaceMaterial" + nf(mt, 0) + " polygon " + "FACE");
                    radOutput.println("0");
                    radOutput.println("0");
                    radOutput.println("9");

                    radOutput.println(" " + nf(subFace[2][0], 0, User3D.export_PrecisionVertex) + " " +
                                            nf(subFace[2][1], 0, User3D.export_PrecisionVertex) + " " +
                                            nf(subFace[2][2], 0, User3D.export_PrecisionVertex));
                    radOutput.println(" " + nf(subFace[3][0], 0, User3D.export_PrecisionVertex) + " " +
                                            nf(subFace[3][1], 0, User3D.export_PrecisionVertex) + " " +
                                            nf(subFace[3][2], 0, User3D.export_PrecisionVertex));
                    radOutput.println(" " + nf(subFace[0][0], 0, User3D.export_PrecisionVertex) + " " +
                                            nf(subFace[0][1], 0, User3D.export_PrecisionVertex) + " " +
                                            nf(subFace[0][2], 0, User3D.export_PrecisionVertex));
                  }


                } else {

                  radOutput.println("SurfaceMaterial" + nf(mt, 0) + " polygon " + "FACE");
                  radOutput.println("0");
                  radOutput.println("0");
                  radOutput.println("9");

                  radOutput.println(" " + nf(subFace[0][0], 0, User3D.export_PrecisionVertex) + " " +
                                          nf(subFace[0][1], 0, User3D.export_PrecisionVertex) + " " +
                                          nf(subFace[0][2], 0, User3D.export_PrecisionVertex));
                  radOutput.println(" " + nf(subFace[2][0], 0, User3D.export_PrecisionVertex) + " " +
                                          nf(subFace[2][1], 0, User3D.export_PrecisionVertex) + " " +
                                          nf(subFace[2][2], 0, User3D.export_PrecisionVertex));
                  radOutput.println(" " + nf(subFace[1][0], 0, User3D.export_PrecisionVertex) + " " +
                                          nf(subFace[1][1], 0, User3D.export_PrecisionVertex) + " " +
                                          nf(subFace[1][2], 0, User3D.export_PrecisionVertex));

                  if (subFace.length == 4) {

                    radOutput.println("SurfaceMaterial" + nf(mt, 0) + " polygon " + "FACE");
                    radOutput.println("0");
                    radOutput.println("0");
                    radOutput.println("9");

                    radOutput.println(" " + nf(subFace[2][0], 0, User3D.export_PrecisionVertex) + " " +
                                            nf(subFace[2][1], 0, User3D.export_PrecisionVertex) + " " +
                                            nf(subFace[2][2], 0, User3D.export_PrecisionVertex));
                    radOutput.println(" " + nf(subFace[0][0], 0, User3D.export_PrecisionVertex) + " " +
                                            nf(subFace[0][1], 0, User3D.export_PrecisionVertex) + " " +
                                            nf(subFace[0][2], 0, User3D.export_PrecisionVertex));
                    radOutput.println(" " + nf(subFace[3][0], 0, User3D.export_PrecisionVertex) + " " +
                                            nf(subFace[3][1], 0, User3D.export_PrecisionVertex) + " " +
                                            nf(subFace[3][2], 0, User3D.export_PrecisionVertex));
                  }
                }
              }
            }

            radOutput.println();
          }
        }
      }
    }
  }





  void castShadows () {

    if (this.displayAll) {

      for (int f = 0; f < this.nodes.length; f++) {

        int vsb = this.getVisibility(f);

        if (vsb > 0) {

          int  mt = this.getMaterial(f);
          if (allMaterials.Color[mt][0] > 127) {

            int tessellation = this.getTessellation(f);

            int totalNumberOfSubs = 1;
            if (this.getMaterial(f) == 0) {
              tessellation += this.displayTessellation;
            }
            if (tessellation > 0) totalNumberOfSubs = this.nodes[f].length * int(funcs.roundTo(pow(4, tessellation - 1), 1));

            float[][] base_Vertices = new float [this.nodes[f].length][3];
            for (int g = 0; g < this.nodes[f].length; g++) {
              int vNo = this.nodes[f][g];
              base_Vertices[g][0] = allPoints.getX(vNo);
              base_Vertices[g][1] = allPoints.getY(vNo);
              base_Vertices[g][2] = allPoints.getZ(vNo);
            }

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
  }



  float[] intersect (float[] ray_pnt, float[] ray_dir) {

    float[] ray_normal = funcs.vec3_unit(ray_dir);

    float[][] hitPoint = new float [this.nodes.length][7];

    for (int f = 0; f < this.nodes.length; f++) {
      hitPoint[f][0] = FLOAT_undefined;
      hitPoint[f][1] = FLOAT_undefined;
      hitPoint[f][2] = FLOAT_undefined;
      hitPoint[f][3] = FLOAT_undefined;
      hitPoint[f][4] = FLOAT_undefined;
      hitPoint[f][5] = FLOAT_undefined;
      hitPoint[f][6] = FLOAT_undefined;
    }

    for (int f = 0; f < this.nodes.length; f++) {

      int n = this.nodes[f].length;

      if (n > 2) {

        int vsb = this.getVisibility(f);

        if (vsb > 0) {

          float X_intersect = FLOAT_undefined;
          float Y_intersect = FLOAT_undefined;
          float Z_intersect = FLOAT_undefined;
          float dist2intersect = FLOAT_undefined;
          float[] face_norm = {0,0,0};

          boolean InPoly = false;

          if (n < 5) { // works if n==3 or n==4

            float[] A = allPoints.getPosition(this.nodes[f][0]);
            float[] B = allPoints.getPosition(this.nodes[f][1]);
            float[] C = allPoints.getPosition(this.nodes[f][n - 2]);
            float[] D = allPoints.getPosition(this.nodes[f][n - 1]);

            float[] AC = funcs.vec3_diff(A, C);
            float[] BD = funcs.vec3_diff(B, D);

            face_norm = funcs.vec3_cross(AC, BD);

            float face_offset = 0.25 * ((A[0] + B[0] + C[0] + D[0]) * face_norm[0] +
                                        (A[1] + B[1] + C[1] + D[1]) * face_norm[1] +
                                        (A[2] + B[2] + C[2] + D[2]) * face_norm[2]);

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

                if (n == 4) InPoly = funcs.isInside_Quadrangle(P, A, B, C, D);
                else InPoly = funcs.isInside_Triangle(P, A, B, D); // note D is the last vertex while C=B in this case

              }
            }
          }
          else {

            int[] tmpFace = new int[n];
            float[] G = {
              0, 0, 0
            };
            for (int j = 0; j < n; j++) {
              tmpFace[j] = this.nodes[f][j];
              G[0] += allPoints.getX(tmpFace[j]) / float(n);
              G[1] += allPoints.getY(tmpFace[j]) / float(n);
              G[2] += allPoints.getZ(tmpFace[j]) / float(n);
            }

            for (int j = 0; j < n; j++) {

              int j_next = (j + 1) % n;

              float[] A = {
                allPoints.getX(this.nodes[f][j]),
                allPoints.getY(this.nodes[f][j]),
                allPoints.getZ(this.nodes[f][j])
              };

              float[] B = {
                allPoints.getX(this.nodes[f][j_next]),
                allPoints.getY(this.nodes[f][j_next]),
                allPoints.getZ(this.nodes[f][j_next])
              };

              float[] AG = funcs.vec3_diff(A, G);
              float[] BG = funcs.vec3_diff(B, G);

              face_norm = funcs.vec3_cross(AG, BG);

              float face_offset = (1.0 / 3.0) * ((A[0] + B[0] + G[0]) * face_norm[0] +
                                                 (A[1] + B[1] + G[1]) * face_norm[1] +
                                                 (A[2] + B[2] + G[2]) * face_norm[2]);

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

                  InPoly = funcs.isInside_Triangle(P, A, B, G);

                }
              }

              if (InPoly) break;
            }
          }

          if (InPoly) {
            hitPoint[f][0] = X_intersect;
            hitPoint[f][1] = Y_intersect;
            hitPoint[f][2] = Z_intersect;
            hitPoint[f][3] = dist2intersect;
            hitPoint[f][4] = face_norm[0];
            hitPoint[f][5] = face_norm[1];
            hitPoint[f][6] = face_norm[2];
          }

        }
      }
    }

    float[] return_point = {-1, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined};

    float pre_dist = FLOAT_undefined;

    for (int f = 0; f < this.nodes.length; f++) {

      if (pre_dist > hitPoint[f][3]) {

        pre_dist = hitPoint[f][3];

        return_point[0] = f;
        return_point[1] = hitPoint[f][0];
        return_point[2] = hitPoint[f][1];
        return_point[3] = hitPoint[f][2];
        return_point[4] = hitPoint[f][3];
        return_point[5] = hitPoint[f][4];
        return_point[6] = hitPoint[f][5];
        return_point[7] = hitPoint[f][6];

      }

    }

    return return_point;
  }



  public void to_XML (XML xml) {

    println("Saving:" + this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setInt(parent, "ni", this.nodes.length);
    for (int i = 0; i < this.nodes.length; i++) {
      XML child = parent.addChild("item");
      XML_setInt(child, "id", i);
      String txt = "";
      for (int j = 0; j < this.nodes[i].length; j++) {
        txt += nf(this.nodes[i][j], 0);
        if (j < this.nodes[i].length - 1) txt += ",";
      }
      XML_setContent(child, txt);

      XML_setInt(child, "material", this.getMaterial(i));
      XML_setInt(child, "tessellation", this.getTessellation(i));
      XML_setInt(child, "layer", this.getLayer(i));
      XML_setInt(child, "visibility", this.getVisibility(i));
      XML_setInt(child, "weight", this.getWeight(i));
      XML_setInt(child, "close", this.getClose(i));
    }

    XML_setBoolean(parent, "displayAll", this.displayAll);
    XML_setBoolean(parent, "displayNormals", this.displayNormals);
    XML_setBoolean(parent, "displayEdges", this.displayEdges);
    XML_setInt(parent, "displayTessellation", this.displayTessellation);

    XML_setInt(parent, "ACTIVE_pallet_CLR", this.ACTIVE_pallet_CLR);
    XML_setInt(parent, "ACTIVE_pallet_DIR", this.ACTIVE_pallet_DIR);
    XML_setFloat(parent, "ACTIVE_pallet_MLT", this.ACTIVE_pallet_MLT);
    XML_setInt(parent, "PASSIVE_pallet_CLR", this.PASSIVE_pallet_CLR);
    XML_setInt(parent, "PASSIVE_pallet_DIR", this.PASSIVE_pallet_DIR);
    XML_setFloat(parent, "PASSIVE_pallet_MLT", this.PASSIVE_pallet_MLT);
  }

  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);
    int ni = XML_getInt(parent, "ni");

    this.makeEmpty(ni);
    this.nodes = new int [0][0];

    XML[] children = parent.getChildren("item");

    for (int i = 0; i < ni; i++) {
      String txt = XML_getContent(children[i]);
      String[] parts = split(txt, ",");
      int nj = parts.length;
      int[][] newItem = new int [1][nj];
      for (int j = 0; j < nj; j++) {
        newItem[0][j] = int(parts[j]);
      }
      this.nodes = (int[][]) concat(this.nodes, newItem);

      this.setMaterial(i, children[i].getInt("material"));
      this.setTessellation(i, children[i].getInt("tessellation"));
      this.setLayer(i, children[i].getInt("layer"));
      this.setVisibility(i, children[i].getInt("visibility"));
      this.setWeight(i, children[i].getInt("weight"));
      this.setClose(i, children[i].getInt("close"));
    }

    this.displayAll = XML_getBoolean(parent, "displayAll");
    this.displayNormals = XML_getBoolean(parent, "displayNormals");
    this.displayEdges = XML_getBoolean(parent, "displayEdges");
    this.displayTessellation = XML_getInt(parent, "displayTessellation");

    this.ACTIVE_pallet_CLR = XML_getInt(parent, "ACTIVE_pallet_CLR");
    this.ACTIVE_pallet_DIR = XML_getInt(parent, "ACTIVE_pallet_DIR");
    this.ACTIVE_pallet_MLT = XML_getFloat(parent, "ACTIVE_pallet_MLT");
    this.PASSIVE_pallet_CLR = XML_getInt(parent, "PASSIVE_pallet_CLR");
    this.PASSIVE_pallet_DIR = XML_getInt(parent, "PASSIVE_pallet_DIR");
    this.PASSIVE_pallet_MLT = XML_getFloat(parent, "PASSIVE_pallet_MLT");
  }

}
