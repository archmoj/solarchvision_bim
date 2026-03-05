class solarchvision_Tropo3D {

  private final static String CLASS_STAMP = "Tropo3D";

  int i_Map = 0; // TODO: export it or reset it?

  boolean displaySurface = false;
  boolean displayTexture = true;

  String[] Filenames;
  PImage[] Map;

  float[][] BoundariesX;
  float[][] BoundariesY;


  void resize_images () {

    this.Filenames = new String [TROPO_timeSteps];
    this.Map = new PImage [TROPO_timeSteps];

    this.BoundariesX = new float[TROPO_timeSteps][2];
    this.BoundariesY = new float[TROPO_timeSteps][2];

    for (int i = 0; i < TROPO_timeSteps; i++) {

      this.Filenames[i] = "";
      this.Map[i] = createImage(2, 2, RGB); // empty and small

      this.BoundariesX[i][0] = 0;
      this.BoundariesX[i][1] = 0;
      this.BoundariesY[i][0] = 0;
      this.BoundariesY[i][1] = 0;

    }
  }


  void load_images () {

    String[] allFilenames = sort(OPESYS.getFiles(Folder_GEOMET));



    int LocationTimeZone = getLocationTimeZone();

    int[] rightNow = getNow_inUTC();

    int CurrentYear = rightNow[0];
    int CurrentMonth = rightNow[1];
    int CurrentDay = rightNow[2];
    int CurrentHour = rightNow[3];

    for (int i = 0; i < TROPO_timeSteps; i++) {

      CurrentHour += 1;

      if (CurrentHour > 23) {
        CurrentHour -= 24;
        CurrentDay += 1;

        if (CurrentDay > TIME.lengthOfMonths[CurrentMonth - 1]) {
          CurrentDay = 1;
          CurrentMonth += 1;

          if (CurrentMonth > 12) {
            CurrentMonth = 1;
            CurrentYear += 1;
          }
        }
      }



      for (int q = 0; q < allFilenames.length; q++) {

        String[] Parts = split(allFilenames[q], '_');

        //if (Parts[0].equals(nf(CurrentYear, 4) + nf(CurrentMonth, 2) + nf(CurrentDay, 2) + nf(CurrentHour, 2))) {
        if (Parts[0].equals(nf((CurrentHour + LocationTimeZone) % 24, 2))) {

          this.Filenames[i] = allFilenames[q];

          this.BoundariesX[i][0] = -float(Parts[1]) * 0.001;
          this.BoundariesY[i][0] =  float(Parts[2]) * 0.001;
          this.BoundariesX[i][1] = -float(Parts[3]) * 0.001;
          this.BoundariesY[i][1] =  float(Parts[4]) * 0.001;

          println("Loading:", Folder_GEOMET + "/" + this.Filenames[i]);

          this.Map[i] = loadImage(Folder_GEOMET + "/" + this.Filenames[i]);

          break;
        }
      }

    }

    SOLARCHVISION_view_changed();
  }


  void download_images () {

    int LocationTimeZone = getLocationTimeZone();

    int[] rightNow = getNow_inUTC();

    int CurrentYear = rightNow[0];
    int CurrentMonth = rightNow[1];
    int CurrentDay = rightNow[2];
    int CurrentHour = rightNow[3];

    for (int i = 0; i < TROPO_timeSteps; i++) {

      if (WMS_type == DataType.SATELLITE_GOES) {

        CurrentHour -= 1;

        if (CurrentHour < 0) {
          CurrentHour += 24;
          CurrentDay -= 1;

          if (CurrentDay < 0) {

            CurrentMonth -= 1;

            if (CurrentMonth < 0) {
              CurrentMonth = 12;
              CurrentYear -= 1;
            }

            CurrentDay = TIME.lengthOfMonths[CurrentMonth - 1];
          }
        }

      }
      else {

        CurrentHour += 1;

        if (CurrentHour > 23) {
          CurrentHour -= 24;
          CurrentDay += 1;

          if (CurrentDay > TIME.lengthOfMonths[CurrentMonth - 1]) {
            CurrentDay = 1;
            CurrentMonth += 1;

            if (CurrentMonth > 12) {
              CurrentMonth = 1;
              CurrentYear += 1;
            }
          }
        }

      }
      String the_service = "";

      if (WMS_type == DataType.SATELLITE_GOES) {
        the_service = "https://mesonet.agron.iastate.edu/cgi-bin/wms/goes/east_vis.cgi";
      }
      else {
        the_service = "https://geo.weather.gc.ca/geomet";
      }


      String the_link = the_service + "?SERVICE=WMS&REQUEST=GetMap&VERSION=1.3.0&FORMAT=image%2Fpng&TRANSPARENT=true";


      String ParameterStamp = "";

      if (WMS_type == DataType.SATELLITE_GOES) {
        ParameterStamp = "";
      }
      else {
        ParameterStamp = "_NT&STYLES=CLOUD"; // Cloud cover
        //ParameterStamp = "_GZ&STYLES=DEFAULT"; // Geopotential height (Value range mapping)
        //ParameterStamp = "_UU&STYLES=WINDSPEED"; // Windspeed in knots
        //ParameterStamp = "_UU&STYLES=WINDSPEEDKMH"; // Windspeed in km/h
        //ParameterStamp = "_UU&STYLES=WINDARROWKMH"; // Wind arrows in km/h
        //ParameterStamp = "_UU&STYLES=WINDARROW"; // Wind arrows in knots
        //ParameterStamp = "_TT&STYLES=TEMPERATURE"; // Air temperature
        //ParameterStamp = "_TT&STYLES=TEMPSUMMER"; // Air temperaturesummer range
        //ParameterStamp = "_TT&STYLES=TEMPWINTER"; // Air temperaturewinter range
        //ParameterStamp = "_ES&STYLES=DEWPOINTDEP"; // Dew point depression
        //ParameterStamp = "_P0&STYLES=PRESSURE"; // Surface pressure
        //ParameterStamp = "_PN&STYLES=PRESSURE4_LINE"; // Sea level pressure contour 4mb
        //ParameterStamp = "_PN&STYLES=PRESSURE4"; // Sea level pressure 4mb
        //ParameterStamp = "_PN&STYLES=PRESSURESEAHIGH"; // Sea level pressure high range
        //ParameterStamp = "_PN&STYLES=PRESSURESEALOW"; // Sea level pressure low range
        //ParameterStamp = "_PR&STYLES=PRECIPMM"; // Precipitations in millimeters
        //ParameterStamp = "_PR&STYLES=CAPA24"; // Precipitations in millimeters (CaPA24)
        //ParameterStamp = "_RT&STYLES=PRECIPRTMMH"; // Rate of precipitations in millimeters per hour
        //ParameterStamp = "_RN&STYLES=PRECIPMM"; // Precipitations in millimeters
        //ParameterStamp = "_FR&STYLES=PRECIPMM"; // Precipitations in millimeters
        //ParameterStamp = "_SN&STYLES=PRECIPSNOW"; // Precipitations in centimeters
        //ParameterStamp = "_I0&STYLES=TEMPSOIL"; // Soil Temperature
        //ParameterStamp = "_I1&STYLES=WATERCONTENT"; // Water content
        //ParameterStamp = "_I2&STYLES=ICECONTENT"; // Soil volumetric ice content
        //ParameterStamp = "_I3&STYLES=WATERRETAINED"; // Water retained on the vegetation
        //ParameterStamp = "_I4&STYLES=WATERRETAINED"; // Water retained in the snow pack
        //ParameterStamp = "_I5&STYLES=SNOWMASS"; // Snow mass
        //ParameterStamp = "_I8&STYLES=ICETHICK"; // Sea ice thickness

        //ParameterStamp = "_WGE&STYLES=MS2KTSGUST"; // Windgust estimate intervals in knots
        //ParameterStamp = "_WGE&STYLES=MS2KTS"; // Windspeed estimate in knots
        //ParameterStamp = "_WGE&STYLES=MS2KMH"; // Windspeed estimate in km/h

        //ParameterStamp = "_WGN&STYLES=MS2KTSGUST"; // Windgust minimum intervals in knots
        //ParameterStamp = "_WGN&STYLES=MS2KTS"; // Windspeed minimum in knots
        //ParameterStamp = "_WGN&STYLES=MS2KMH"; // Windspeed minimum in km/h

        //ParameterStamp = "_WGX&STYLES=MS2KTSGUST"; // Windgust maximum intervals in knots
        //ParameterStamp = "_WGX&STYLES=MS2KTS"; // Windspeed maximum in knots
        //ParameterStamp = "_WGX&STYLES=MS2KMH"; // Windspeed maximum in km/h
      }



      String DomainStamp = "";
      if (WMS_type == DataType.SATELLITE_GOES) {
        DomainStamp = "east_vis_1km";
      }
      else if (WMS_type == DataType.FORECAST_HRDPS) {
        DomainStamp = "HRDPS.CONTINENTAL";
      }
      else if (WMS_type == DataType.FORECAST_RDPS) {
        DomainStamp = "RDPS.ETA";
      }
      else if (WMS_type == DataType.FORECAST_GDPS) {
        DomainStamp = "GDPS.ETA";
      }

      this.BoundariesX[i][0] = STATION.getLongitude() - 5;
      this.BoundariesX[i][1] = STATION.getLongitude() + 5;
      this.BoundariesY[i][0] = STATION.getLatitude() - 5 * funcs.cos_ang(STATION.getLatitude());
      this.BoundariesY[i][1] = STATION.getLatitude() + 5 * funcs.cos_ang(STATION.getLatitude());



      int RES1 = 1200; // 1800;
      int RES2 = 600; // 900;


      the_link += "&LAYERS=" + DomainStamp + ParameterStamp + "&WIDTH=" + nf(RES1, 0) + "&HEIGHT=" + nf(RES2, 0);
      the_link += "&CRS=EPSG%3A4326&BBOX=";
      the_link += nf(this.BoundariesY[i][0], 0, 3) + ",";
      the_link += nf(this.BoundariesX[i][0], 0, 3) + ",";
      the_link += nf(this.BoundariesY[i][1], 0, 3) + ",";
      the_link += nf(this.BoundariesX[i][1], 0, 3);

      int the_hour = int(CurrentHour / TROPO_deltaTime) * TROPO_deltaTime;

      String timeStamp = "";
      if (WMS_type == DataType.SATELLITE_GOES) {
        timeStamp = "&DATE=" + nf(CurrentYear, 4) + "-" + nf(CurrentMonth, 2) + "-" + nf(CurrentDay, 2) + "&time=" + nf(the_hour, 2) + ":00";
      }
      else {
        timeStamp = nf(CurrentYear, 4) + "-" + nf(CurrentMonth, 2) + "-" + nf(CurrentDay, 2) + "T" + nf(the_hour, 2);
      }

      the_link += "&TIME=" + timeStamp +":00:00Z";

      this.Map[i] = createImage(2, 2, RGB); // empty and small

      //String FN = nf(CurrentYear, 4) + nf(CurrentMonth, 2) + nf(CurrentDay, 2) + nf(CurrentHour, 2) + "_";
      String FN = nf((CurrentHour + LocationTimeZone) % 24, 2) + "_";
      FN += nf(int(funcs.roundTo(-1000 * this.BoundariesX[i][0], 1)), 6) + "_";
      FN += nf(int(funcs.roundTo( 1000 * this.BoundariesY[i][0], 1)), 6) + "_";
      FN += nf(int(funcs.roundTo(-1000 * this.BoundariesX[i][1], 1)), 6) + "_";
      FN += nf(int(funcs.roundTo( 1000 * this.BoundariesY[i][1], 1)), 6) + "_";
      FN += ".png";

      String the_target = Folder_GEOMET + "/" + FN;

      File dir = new File(the_target);
      if (!dir.isFile()) {

        boolean new_file_downloaded = false;

        println("Try downloading: " + the_link);

        try {
          saveBytes(the_target, loadBytes(the_link));

          new_file_downloaded = true;
        }

        catch (Exception e) {
          println("LINK NOT AVAILABLE:", the_link);
        }

        if (new_file_downloaded) {

          if (ParameterStamp.equals("_NT&STYLES=CLOUD")) {
            println("image processing cloud layer");

            PImage img = loadImage(the_target);
            img.loadPixels();

            for (int np = 0; np < (RES1 * RES2); np++) {
              int Image_X = np % RES1;
              int Image_Y = np / RES1;

              color COL = img.get(Image_X, Image_Y);
              //alpha: COL >> 24 & 0xFF; red: COL >> 16 & 0xFF; green: COL >>8 & 0xFF; blue: COL & 0xFF;

              float COL_A = (COL >> 24 & 0xFF);

              if (COL_A == 0) {
                img.pixels[np] = color(0,0);
              }
              else {
                float COL_V = (COL >> 16 & 0xFF);
                img.pixels[np] = color(255 - 0.125 * COL_V, COL_V);
              }
            }
            img.updatePixels();
            img.save(the_target);
          }




          if (WMS_type == DataType.SATELLITE_GOES) {
            println("image processing cloud layer");

            PImage img = loadImage(the_target);

            img.loadPixels();

            for (int np = 0; np < (RES1 * RES2); np++) {
              int Image_X = np % RES1;
              int Image_Y = np / RES1;

              color COL = img.get(Image_X, Image_Y);
              //alpha: COL >> 24 & 0xFF; red: COL >> 16 & 0xFF; green: COL >>8 & 0xFF; blue: COL & 0xFF;

              float COL_V = (COL >> 16 & 0xFF);

              float N = 3; //3.5; //4;

              if (COL_V < 255 / N) {
                img.pixels[np] = color(191,191,255,255); //color(0,0);
              }
              else {
                img.pixels[np] = color((255 - COL_V) * N / (N - 1), 255);
              }
            }
            img.updatePixels();
            img.save(the_target);
          }

        }

      }
    }

    Tropo3D.load_images();
  }






  void draw (int target_window) {

    boolean proceed = true;

    if ((displaySurface == false) || (displayTexture == false)) {
      proceed = false;
    }

    if (target_window == TypeWindow.STUDY) {
      proceed = false;
    }

    if (proceed) {

      int n_Map = this.i_Map;

      if (this.Filenames[n_Map].equals("")) { // not to display empty images
        } else {

        if ((target_window == TypeWindow.HTML) || (target_window == TypeWindow.OBJ3D)) {

          if (User3D.export_MaterialLibrary) {

            if (target_window == TypeWindow.HTML) {
              htmlOutput.println("\t\t\t\t<Appearance DEF='TropoSphere" + nf(n_Map, 0) + "'>");
            }

            if (target_window == TypeWindow.OBJ3D) {

              mtlOutput.println("newmtl TropoSphere" + nf(n_Map, 0));
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

            if (Tropo3D.displayTexture) {

              String old_Texture_path = Folder_GEOMET + "/" + this.Filenames[n_Map];

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
              objOutput.println("g TropoSphere" + nf(n_Map, 0));
            }

            if (User3D.export_MaterialLibrary) {
              objOutput.println("usemtl TropoSphere" + nf(n_Map, 0));
            }
          }

        }


        float OffsetX = this.BoundariesX[n_Map][0] + 180;
        float OffsetY = this.BoundariesY[n_Map][1] - 90;

        float ScaleX = (this.BoundariesX[n_Map][1] - this.BoundariesX[n_Map][0]) / 360.0;
        float ScaleY = (this.BoundariesY[n_Map][1] - this.BoundariesY[n_Map][0]) / 180.0;

        float CEN_lon = 0.5 * (this.BoundariesX[n_Map][0] + this.BoundariesX[n_Map][1]);
        float CEN_lat = 0.5 * (this.BoundariesY[n_Map][0] + this.BoundariesY[n_Map][1]);

        float delta_Alpha = -BIOSPHERE_drawResolution;
        float delta_Beta = -BIOSPHERE_drawResolution;

        float r = FLOAT_r_Earth + 10000;


        num_vertices_added = 0;

        int end_turn = 1;
        if (target_window == TypeWindow.OBJ3D) end_turn = 3;
        for (int _turn = 1; _turn <= end_turn; _turn++) {

          int f = 0;
          for (float Alpha = 90; Alpha > -90; Alpha += delta_Alpha) {
            for (float Beta = 180; Beta > -180; Beta += delta_Beta) {
              f += 1;

              float[][] subFace = new float [4][7];

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

                if (Tropo3D.displayTexture) {
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

                subFace[s][5] = a;
                subFace[s][6] = b;
              }

              boolean UVs_OK = true;

              for (int s = 0; s < subFace.length; s++) {
                if (subFace[s][3] < 0) UVs_OK = false;
                if (subFace[s][3] > 1) UVs_OK = false;
                if (subFace[s][4] < 0) UVs_OK = false;
                if (subFace[s][4] > 1) UVs_OK = false;
              }

              if (UVs_OK) {

                if (target_window == TypeWindow.WORLD) {
                  WORLD.graphics.beginShape();
                  WORLD.graphics.noStroke();
                  if (Tropo3D.displayTexture) {
                    WORLD.graphics.texture(this.Map[n_Map]);
                  }

                  for (int s = 0; s < subFace.length; s++) {

                    float _lat = subFace[s][5];
                    float _lon = subFace[s][6];
                    if (_lon > 180) _lon -= 360; // << important!

                    float x_point = WORLD.dX * (( 1 * (_lon - WORLD.oX) / 360.0) + 0.5) / WORLD.sX;
                    float y_point = WORLD.dY * ((-1 * (_lat - WORLD.oY) / 180.0) + 0.5) / WORLD.sY;

                    WORLD.graphics.vertex(x_point, y_point,
                                          subFace[s][3] * this.Map[n_Map].width,
                                          subFace[s][4] * this.Map[n_Map].height);
                  }

                  WORLD.graphics.endShape(CLOSE);

                }


                if (target_window == TypeWindow.HTML) {

                  htmlOutput.println("\t\t\t\t<shape>");

                  if (n_Map != -1) {
                    htmlOutput.println("\t\t\t\t\t<Appearance USE='TropoSphere" + nf(n_Map, 0) + "'></Appearance>");
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
                  if (Tropo3D.displayTexture) {
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

                    WIN3D.graphics.vertex(x * OBJECTS_scale * WIN3D.scale,
                                          -y * OBJECTS_scale * WIN3D.scale,
                                          z * OBJECTS_scale * WIN3D.scale,
                                          u * this.Map[n_Map].width,
                                          v * this.Map[n_Map].height);
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
                      objOutput.println("g TropoSphere" + nf(n_Map, 0) + "_" + nf(f, 0));
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
