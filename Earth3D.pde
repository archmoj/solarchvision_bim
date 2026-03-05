class solarchvision_Earth3D {

  private final static String CLASS_STAMP = "Earth3D";

  boolean displaySurface = true;
  boolean displayTexture = true;

  PImage[] Map;

  float[][] BoundariesX;
  float[][] BoundariesY;

  String Path = BaseFolder + "/input/images/earth";

  String[] Filenames = sort(OPESYS.getFiles(this.Path));


  void resize_images () {

    int n = this.Filenames.length;

    this.Map = new PImage [n];

    this.BoundariesX = new float [n][2];
    this.BoundariesY = new float [n][2];

  }


  void load_images () {

    for (int i = 0; i < this.Filenames.length; i++) {

      String MapFilename = this.Path + "/" + this.Filenames[i];

      String[] Parts = split(this.Filenames[i], '_');

      this.BoundariesX[i][0] = -float(Parts[1]) * 0.001;
      this.BoundariesY[i][0] =  float(Parts[2]) * 0.001;
      this.BoundariesX[i][1] = -float(Parts[3]) * 0.001;
      this.BoundariesY[i][1] =  float(Parts[4]) * 0.001;

      println("Loading:", MapFilename);

      this.Map[i] = loadImage(MapFilename);
    }
  }



  void draw (int target_window) {

    boolean proceed = true;

    if ((this.displaySurface == false) || (this.displayTexture == false)) {
      proceed = false;
    }

    if ((target_window == TypeWindow.STUDY) ||
        (target_window == TypeWindow.WORLD)) {

      proceed = false;
    }

    if (proceed) {

      int n_Map = 0;
      if (IMPACTS_displayDay < this.Map.length) n_Map = IMPACTS_displayDay;

      float OffsetX = this.BoundariesX[n_Map][0] + 180;
      float OffsetY = this.BoundariesY[n_Map][1] - 90;

      float ScaleX = (this.BoundariesX[n_Map][1] - this.BoundariesX[n_Map][0]) / 360.0;
      float ScaleY = (this.BoundariesY[n_Map][1] - this.BoundariesY[n_Map][0]) / 180.0;

      float CEN_lon = 0.5 * (this.BoundariesX[n_Map][0] + this.BoundariesX[n_Map][1]);
      float CEN_lat = 0.5 * (this.BoundariesY[n_Map][0] + this.BoundariesY[n_Map][1]);

      float delta_Alpha = -BIOSPHERE_drawResolution;
      float delta_Beta = -BIOSPHERE_drawResolution;

      float r = FLOAT_r_Earth;


      if ((target_window == TypeWindow.HTML) ||
          (target_window == TypeWindow.OBJ3D)) {

        if (User3D.export_MaterialLibrary) {

          if (target_window == TypeWindow.HTML) {
            htmlOutput.println("\t\t\t\t<Appearance DEF='EarthSphere" + nf(n_Map, 0) + "'>");
          }

          if (target_window == TypeWindow.OBJ3D) {

            mtlOutput.println("newmtl EarthSphere");
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

          if (this.displayTexture) {

            String old_Texture_path = this.Path + "/" + this.Filenames[n_Map];

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


      num_vertices_added = 0;

      int end_turn = 1;
      if (target_window == TypeWindow.OBJ3D) end_turn = 3;
      for (int _turn = 1; _turn <= end_turn; _turn++) {

        int f = 0;
        for (float Alpha = 90; Alpha > -90; Alpha += delta_Alpha) {
          for (float Beta = 180; Beta > -180; Beta += delta_Beta) {
            f += 1;

            float[][] subFace = new float [4][5];

            for (int s = 0; s < 4; s++) {

              float a = Alpha;
              float b = Beta;

              if ((s == 2) || (s == 3)) {
                a += delta_Alpha;
              }

              if ((s == 1) || (s == 2)) {
                b += delta_Beta;
              }

              float x0 = r * funcs.cos_ang(b - 90) * funcs.cos_ang(a);
              float y0 = r * funcs.sin_ang(b - 90) * funcs.cos_ang(a);
              float z0 = r * funcs.sin_ang(a);

              float _lon = b - CEN_lon;
              float _lat = a - CEN_lat;

              if (this.displayTexture) {
                // calculating u and v
                subFace[s][3] = (_lon / ScaleX / 360.0 + 0.5);
                subFace[s][4] = (-_lat / ScaleY / 180.0 + 0.5);
              }

              // rotating to location coordinates
              float tb = -STATION.getLongitude();
              float x1 = x0 * funcs.cos_ang(tb) - y0 * funcs.sin_ang(tb);
              float y1 = x0 * funcs.sin_ang(tb) + y0 * funcs.cos_ang(tb);
              float z1 = z0;

              float ta = 90 - STATION.getLatitude();
              float x2 = x1;
              float y2 = z1 * funcs.sin_ang(ta) + y1 * funcs.cos_ang(ta);
              float z2 = z1 * funcs.cos_ang(ta) - y1 * funcs.sin_ang(ta);

              // move it down!
              z2 -= FLOAT_r_Earth;

              subFace[s][0] = x2;
              subFace[s][1] = y2;
              subFace[s][2] = z2;
            }


            if (target_window == TypeWindow.HTML) {

              htmlOutput.println("\t\t\t\t<shape>");

              if (n_Map != -1) {
                htmlOutput.println("\t\t\t\t\t<Appearance USE='EarthSphere" + nf(n_Map, 0) + "'></Appearance>");
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

            if (target_window == TypeWindow.WIN3D) {

              WIN3D.graphics.strokeWeight(1);

              WIN3D.graphics.beginShape();

              WIN3D.graphics.noStroke();

              if (this.displayTexture) {

                WIN3D.graphics.texture(this.Map[n_Map]);
              }
            }



            for (int s = 0; s < subFace.length; s++) {

              float x = subFace[s][0];
              float y = subFace[s][1];
              float z = subFace[s][2];
              float u = subFace[s][3];
              float v = subFace[s][4];

              if (u > 1) u = 1;
              if (u < 0) u = 0;
              if (v > 1) v = 1;
              if (v < 0) v = 0;

              if (target_window == TypeWindow.WIN3D) {

                WIN3D.graphics.vertex(x * OBJECTS_scale * WIN3D.scale, -y * OBJECTS_scale * WIN3D.scale, z * OBJECTS_scale * WIN3D.scale, u * this.Map[n_Map].width, v * this.Map[n_Map].height);
              }


              if (target_window == TypeWindow.OBJ3D) {
                if (_turn == 1) {
                  SOLARCHVISION_OBJprintVertex(x, y, z);
                }

                if (_turn == 2) {

                  v = 1 - v; // mirroring the image <<<<<<<<<<<<<<<<<<

                  SOLARCHVISION_OBJprintVtexture(u, v, 0);
                }

                if (_turn == 3) {
                  obj_lastVertexNumber += 1;
                  obj_lastVtextureNumber += 1;
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

            if (target_window == TypeWindow.HTML) {

              htmlOutput.println("\t\t\t\t\t</IndexedFaceSet>");

              htmlOutput.println("\t\t\t\t</shape>");

            }

            if (target_window == TypeWindow.WIN3D) {
              WIN3D.graphics.endShape(CLOSE);
            }

            if (target_window == TypeWindow.OBJ3D) {
              String n1_txt = nf(obj_lastVertexNumber - 3, 0);
              String n2_txt = nf(obj_lastVertexNumber - 2, 0);
              String n3_txt = nf(obj_lastVertexNumber - 1, 0);
              String n4_txt = nf(obj_lastVertexNumber - 0, 0);

              String m1_txt = nf(obj_lastVtextureNumber - 3, 0);
              String m2_txt = nf(obj_lastVtextureNumber - 2, 0);
              String m3_txt = nf(obj_lastVtextureNumber - 1, 0);
              String m4_txt = nf(obj_lastVtextureNumber - 0, 0);

              if (User3D.export_PolyToPoly == 0) {
                if (_turn == 3) {
                  obj_lastGroupNumber += 1;
                  objOutput.println("g EarthSphere_" + nf(f, 0));
                }
              }

              if (_turn == 3) {
                obj_lastFaceNumber += 1;
                objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n2_txt + "/" + m2_txt + " " + n3_txt + "/" + m3_txt + " " + n4_txt + "/" + m4_txt);
                if (User3D.export_BackSides) {
                  obj_lastFaceNumber += 1;
                  objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n4_txt + "/" + m4_txt + " " + n3_txt + "/" + m3_txt + " " + n2_txt + "/" + m2_txt);
                }
              }
            }
          }
        }
      }
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
