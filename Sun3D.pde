class solarchvision_Sun3D {

  private final static String CLASS_STAMP = "Sun3D";

  int ACTIVE_palette_CLR = 15;
  int ACTIVE_palette_DIR = 1;
  float ACTIVE_palette_MLT = 1;

  int PASSIVE_palette_CLR = 18;
  int PASSIVE_palette_DIR = -1;
  float PASSIVE_palette_MLT = 0.5;

  boolean displayGrid = true;
  boolean displayPath = true;
  boolean displayPattern = false;

  boolean displaySurface = false;
  boolean displayTexture = true;

  String Filename = BaseFolder + "/input/images/sun/Sun.jpg";

  PImage Map;

  void load_images () {
    Map = loadImage(Filename);
  }

  void draw () {
    if (this.displaySurface) {

      WIN3D.graphics.noStroke();

      float OffsetX = 0;
      float OffsetY = 0;

      float ScaleX = 1;
      float ScaleY = 1;

      float CEN_lon = 0;
      float CEN_lat = 0;

      float delta_Alpha = -5;
      float delta_Beta = -10;

      float r = 696.0 * Planetary_Magnification; // * 1000000; // multiply this later
      float d = 150000.0; // * 1000000; // multiply this later

      for (float Alpha = 90; Alpha > -90; Alpha += delta_Alpha) {
        for (float Beta = 180; Beta > -180; Beta += delta_Beta) {

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

            float tb = 0;
            float x1 = x0 * funcs.cos_ang(tb) - y0 * funcs.sin_ang(tb);
            float y1 = x0 * funcs.sin_ang(tb) + y0 * funcs.cos_ang(tb);
            float z1 = z0;

            float ta = -90 - STATION.getLatitude();
            float x2 = x1;
            float y2 = z1 * funcs.sin_ang(ta) + y1 * funcs.cos_ang(ta);
            float z2 = z1 * funcs.cos_ang(ta) - y1 * funcs.sin_ang(ta);

            // scale it here!
            x2 *= 1000000.0;
            y2 *= 1000000.0;
            z2 *= 1000000.0;

            // move it to scale here!
            y2 += 1000000.0 * d * funcs.sin_ang(-STATION.getLatitude());
            z2 += 1000000.0 * d * funcs.cos_ang(-STATION.getLatitude());

            subFace[s][0] = x2;
            subFace[s][1] = y2;
            subFace[s][2] = z2;
          }

          WIN3D.graphics.beginShape();

          if (this.displayTexture) {
            WIN3D.graphics.texture(this.Map);
          }

          for (int s = 0; s < subFace.length; s++) {

            WIN3D.graphics.vertex(subFace[s][0] * OBJECTS_scale * WIN3D.scale,
                                 -subFace[s][1] * OBJECTS_scale * WIN3D.scale,
                                  subFace[s][2] * OBJECTS_scale * WIN3D.scale,
                                  subFace[s][3] * this.Map.width,
                                  subFace[s][4] * this.Map.height);
          }

          WIN3D.graphics.endShape(CLOSE);
        }
      }
    }
  }








  void drawGrid (int target_window, float x_SunPath, float y_SunPath, float z_SunPath, float s_SunPath, int start_j, int end_j) {
    if (target_window == TypeWindow.STUDY) {
      s_SunPath *= 0.65; // TODO: why do we need this?

      s_SunPath /= STUDY.ImageScale;
    }

    if (this.displayGrid) {

      if (target_window == TypeWindow.WIN3D) {

        WIN3D.graphics.pushMatrix();
        WIN3D.graphics.translate(x_SunPath, y_SunPath, z_SunPath);

        WIN3D.graphics.strokeWeight(1);
        WIN3D.graphics.stroke(0);
      }

      if (target_window == TypeWindow.STUDY) {

        STUDY.graphics.pushMatrix();
        STUDY.graphics.translate(x_SunPath, y_SunPath);

        STUDY.graphics.strokeWeight(1);
        STUDY.graphics.stroke(0);
      }

      for (float j = start_j; j <= end_j; j += 30) {

        float HOUR_step = 0.1;
        for (float i = 0; i <= 24; i += HOUR_step) {

          float[] SunA = funcs.SunPosition(STATION.getLatitude(), j, i);
          float[] SunB = funcs.SunPosition(STATION.getLatitude(), j, i + HOUR_step);

          if ((SunA[3] > 0) || (SunB[3] > 0)) {

            if (target_window == TypeWindow.WIN3D) {

              WIN3D.graphics.line(SunA[1] * s_SunPath * WIN3D.scale,
                                 -SunA[2] * s_SunPath * WIN3D.scale,
                                  SunA[3] * s_SunPath * WIN3D.scale,
                                  SunB[1] * s_SunPath * WIN3D.scale,
                                 -SunB[2] * s_SunPath * WIN3D.scale,
                                  SunB[3] * s_SunPath * WIN3D.scale);
            }

            if (target_window == TypeWindow.STUDY) {

              float A_Alpha = 90 - funcs.acos_ang(SunA[3]);
              float A_Beta = 180 - funcs.atan2_ang(SunA[1], SunA[2]);

              float B_Alpha = 90 - funcs.acos_ang(SunB[3]);
              float B_Beta = 180 - funcs.atan2_ang(SunB[1], SunB[2]);

              STUDY.graphics.line((90 - A_Alpha) * (funcs.cos_ang(A_Beta - 90)) * s_SunPath * STUDY.view_S / 90.0,
                                 -(90 - A_Alpha) * (funcs.sin_ang(A_Beta - 90)) * s_SunPath * STUDY.view_S / 90.0,
                                  (90 - B_Alpha) * (funcs.cos_ang(B_Beta - 90)) * s_SunPath * STUDY.view_S / 90.0,
                                 -(90 - B_Alpha) * (funcs.sin_ang(B_Beta - 90)) * s_SunPath * STUDY.view_S / 90.0);
            }
          }
        }
      }

      for (float i = 0; i <= 24; i += 1) {
        float DATE_step = 1;
        for (float j = start_j; j <= end_j; j += DATE_step) {

          float[] SunA = funcs.SunPosition(STATION.getLatitude(), j, i);
          float[] SunB = funcs.SunPosition(STATION.getLatitude(),  j + DATE_step, i);

          if ((SunA[3] > 0) || (SunB[3] > 0)) {

            if (target_window == TypeWindow.WIN3D) {

              WIN3D.graphics.line(SunA[1] * s_SunPath * WIN3D.scale,
                                 -SunA[2] * s_SunPath * WIN3D.scale,
                                  SunA[3] * s_SunPath * WIN3D.scale,
                                  SunB[1] * s_SunPath * WIN3D.scale,
                                 -SunB[2] * s_SunPath * WIN3D.scale,
                                  SunB[3] * s_SunPath * WIN3D.scale);
            }

            if (target_window == TypeWindow.STUDY) {

              float A_Alpha = 90 - funcs.acos_ang(SunA[3]);
              float A_Beta = 180 - funcs.atan2_ang(SunA[1], SunA[2]);

              float B_Alpha = 90 - funcs.acos_ang(SunB[3]);
              float B_Beta = 180 - funcs.atan2_ang(SunB[1], SunB[2]);

              STUDY.graphics.line((90 - A_Alpha) * (funcs.cos_ang(A_Beta - 90)) * s_SunPath * STUDY.view_S / 90.0,
                                 -(90 - A_Alpha) * (funcs.sin_ang(A_Beta - 90)) * s_SunPath * STUDY.view_S / 90.0,
                                  (90 - B_Alpha) * (funcs.cos_ang(B_Beta - 90)) * s_SunPath * STUDY.view_S / 90.0,
                                 -(90 - B_Alpha) * (funcs.sin_ang(B_Beta - 90)) * s_SunPath * STUDY.view_S / 90.0);
            }
          }
        }
      }

      if (target_window == TypeWindow.WIN3D) {
        WIN3D.graphics.popMatrix();
      }

      if (target_window == TypeWindow.STUDY) {
        STUDY.graphics.popMatrix();
      }
    }

  }




  void drawPath (int target_window, float x_SunPath, float y_SunPath, float z_SunPath, float s_SunPath) {

    if (this.displayPath) {

      float keep_STUDY_perDays = STUDY.perDays;
      int keep_STUDY_joinDays = STUDY.joinDays;
      if ((CurrentDataSource == dataID_ENSEMBLE_FORECAST) ||
          (CurrentDataSource == dataID_ENSEMBLE_OBSERVED)) {

        STUDY.perDays = 1;
        STUDY.joinDays = 1;
      }

      float previous_DATE = TIME.date;




      int TES_hour = 4; // 1 = every 1 hour, 4 = every 15 minutes

      int PAL_type = 0;
      int PAL_direction = 1;

      if (WIN3D.Impact_TYPE == Impact_ACTIVE) {
        PAL_type = this.ACTIVE_palette_CLR;
        PAL_direction = this.ACTIVE_palette_DIR;
      }
      if (WIN3D.Impact_TYPE == Impact_PASSIVE) {
        PAL_type = this.PASSIVE_palette_CLR;
        PAL_direction = this.PASSIVE_palette_DIR;
      }

      float PAL_multiplier = 1;
      if (WIN3D.Impact_TYPE == Impact_ACTIVE) PAL_multiplier = this.ACTIVE_palette_MLT;
      if (WIN3D.Impact_TYPE == Impact_PASSIVE) PAL_multiplier = this.PASSIVE_palette_MLT;



      WIN3D.graphics.pushMatrix();
      WIN3D.graphics.translate(x_SunPath, y_SunPath, z_SunPath);

      WIN3D.graphics.strokeWeight(0);
      WIN3D.graphics.stroke(0, 0, 0);
      WIN3D.graphics.fill(0, 0, 0);

      WIN3D.graphics.line(-1 * s_SunPath, 0, 0, 1 * s_SunPath, 0, 0);
      WIN3D.graphics.line(0, -1 * s_SunPath, 0, 0, 1 * s_SunPath, 0);

      WIN3D.graphics.stroke(255, 255, 0);



      int[] startK_endK = get_startK_endK();
      int start_k = startK_endK[0];
      int end_k = startK_endK[1];
      int count_k = 1 + end_k - start_k;
      if (count_k < 0) count_k = 0;

      for (int p = 0; p < 1; p++) {

        int l = STUDY.ImpactLayer;

        int DATE_step = 1;

        int J_START = STUDY.j_Start;
        int J_END = STUDY.j_End;

        if (IMPACTS_displayDay > 0) {
          J_START = IMPACTS_displayDay - 1;
          J_END = IMPACTS_displayDay;
        }

        for (int j = J_START; j < J_END; j += DATE_step) {

          int now_k = 0;
          int now_i1 = 0;
          int now_i2 = 0;
          int now_j = 0;

          now_j = (j * int(STUDY.perDays) + TIME.beginDay + 365) % 365;

          if (now_j >= 365) {
            now_j = now_j % 365;
          }
          if (now_j < 0) {
            now_j = (now_j + 365) % 365;
          }

          float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);

          //println(j, now_j, DATE_ANGLE);

          int[] Normals_COL_N;
          Normals_COL_N = new int [9];
          Normals_COL_N = SOLARCHVISION_PROCESS_DAILY_SCENARIOS(start_k, end_k, j, DATE_ANGLE, target_window == TypeWindow.STUDY ? STUDY.Impact_TYPE : WIN3D.Impact_TYPE);

          for (int nk = Normals_COL_N[l]; nk <= Normals_COL_N[l]; nk++) {
            if (nk != -1) {
              int k = int(nk / STUDY.joinDays);
              int j_ADD = nk % STUDY.joinDays;

              for (float i = 0; i < 24; i += 1.0 / float (TES_hour)) {
                if (STUDY.isInHourlyRange(i)) {

                  float HOUR_ANGLE = i;
                  float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);

                  now_k = k + start_k;

                  now_i1 = floor(i);
                  now_i2 = (1 + now_i1) % 24;
                  float i_ratio = i - now_i1;

                  now_j = int(j * STUDY.perDays + (j_ADD - int(funcs.roundTo(0.5 * STUDY.joinDays, 1))) + TIME.beginDay + 365) % 365;

                  if (now_j >= 365) {
                    now_j = now_j % 365;
                  }
                  if (now_j < 0) {
                    now_j = (now_j + 365) % 365;
                  }

                  float Pa1 = FLOAT_undefined;
                  float Pa2 = FLOAT_undefined;

                  if (WIN3D.Impact_TYPE == Impact_ACTIVE) {

                    Pa1 = getValue_CurrentDataSource(now_i1, now_j, now_k, LAYER_dirnorrad.id);
                    Pa2 = getValue_CurrentDataSource(now_i2, now_j, now_k, LAYER_dirnorrad.id);

                  }

                  if (WIN3D.Impact_TYPE == Impact_PASSIVE) {

                    Pa1 = getValue_CurrentDataSource(now_i1, now_j, now_k, LAYER_direffect.id);
                    Pa2 = getValue_CurrentDataSource(now_i2, now_j, now_k, LAYER_direffect.id);

                  }

                  if ((is_undefined(Pa1)) && (is_undefined(Pa2))) {
                  } else {

                    float sun_V = 0.001 * (Pa1 * (1 - i_ratio) + Pa2 * i_ratio);

                    float _u = 0;

                    if (WIN3D.Impact_TYPE == Impact_ACTIVE) _u = (PAL_multiplier * sun_V);
                    if (WIN3D.Impact_TYPE == Impact_PASSIVE) _u = 0.5 + 0.5 * (PAL_multiplier * sun_V);

                    if (PAL_direction == -1) _u = 1 - _u;
                    if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
                    if (PAL_direction == 2) _u =  0.5 * _u;

                    float[] COL = PAINT.getColorStyle(PAL_type, _u);

                    WIN3D.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);
                    WIN3D.graphics.fill(COL[1], COL[2], COL[3], COL[0]);

                    WIN3D.graphics.strokeWeight(0.01 * WIN3D.dY);

                    float[] SunA = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE - 0.5 * (1.0 / float(TES_hour)));
                    float[] SunB = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE + 0.5 * (1.0 / float(TES_hour)));

                    if ((SunA[3] > 0) || (SunB[3] > 0)) {

                      float x1 = SunA[1] * WIN3D.scale * s_SunPath;
                      float y1 = SunA[2] * WIN3D.scale * s_SunPath;
                      float z1 = SunA[3] * WIN3D.scale * s_SunPath;

                      float x2 = SunB[1] * WIN3D.scale * s_SunPath;
                      float y2 = SunB[2] * WIN3D.scale * s_SunPath;
                      float z2 = SunB[3] * WIN3D.scale * s_SunPath;

                      WIN3D.graphics.line(x1, -y1, z1, x2, -y2, z2);
                    }
                  }
                }
              }
            }
          }
        }
      }

      WIN3D.graphics.popMatrix();



      STUDY.perDays = keep_STUDY_perDays;
      STUDY.joinDays = keep_STUDY_joinDays;
      TIME.date = previous_DATE;
      TIME.updateDate();
    }
  }



  void drawPattern (int target_window, float x_SunPath, float y_SunPath, float z_SunPath, float s_SunPath) {

    if (this.displayPattern || (target_window == TypeWindow.STUDY)) {

      float keep_STUDY_perDays = STUDY.perDays;
      int keep_STUDY_joinDays = STUDY.joinDays;
      if ((CurrentDataSource == dataID_ENSEMBLE_FORECAST) ||
          (CurrentDataSource == dataID_ENSEMBLE_OBSERVED)) {

        STUDY.perDays = 1;
        STUDY.joinDays = 1;
      }

      float previous_DATE = TIME.date;

      this.drawCycles(target_window, x_SunPath, y_SunPath, z_SunPath, s_SunPath);

      STUDY.perDays = keep_STUDY_perDays;
      STUDY.joinDays = keep_STUDY_joinDays;
      TIME.date = previous_DATE;
      TIME.updateDate();
    }
  }



  void drawCycles (int target_window, float x_Plot, float y_Plot, float z_Plot, float s_Plot) {

    int TES_hour = 1; //4; // 1 = every 1 hour, 4 = every 15 minutes

    float STUDY_perDays = STUDY.perDays;
    if(STUDY_perDays <= STUDY.joinDays) STUDY_perDays = STUDY.joinDays + 0.5;

    int[] startK_endK = get_startK_endK();
    int start_k = startK_endK[0];
    int end_k = startK_endK[1];
    int count_k = 1 + end_k - start_k;
    if (count_k < 0) count_k = 0;

    int keep_Impact_TYPE = WIN3D.Impact_TYPE;

    if (target_window == TypeWindow.STUDY) {
      WIN3D.Impact_TYPE = (STUDY.PlotImpacts % 2 == 0) ? Impact_ACTIVE : Impact_PASSIVE;
    }

    float Pa1 = FLOAT_undefined;
    float Pb1 = FLOAT_undefined;
    float Pc1 = FLOAT_undefined;
    float Pd1 = FLOAT_undefined;

    float Pa2 = FLOAT_undefined;
    float Pb2 = FLOAT_undefined;
    float Pc2 = FLOAT_undefined;
    float Pd2 = FLOAT_undefined;

    float values_R_dir;
    float values_R_dif;
    float values_E_dir;
    float values_E_dif;

    int now_k = 0;
    int now_i1 = 0;
    int now_i2 = 0;
    int now_j = 0;

    int PAL_type = 0;
    int PAL_direction = 1;

    float PAL_multiplier = 1;

    if (target_window == TypeWindow.STUDY) {

      if (WIN3D.Impact_TYPE == Impact_ACTIVE) {
        PAL_type = STUDY.ACTIVE_palette_CLR;
        PAL_direction = STUDY.ACTIVE_palette_DIR;
        PAL_multiplier = STUDY.ACTIVE_palette_MLT;
      }
      if (WIN3D.Impact_TYPE == Impact_PASSIVE) {
        PAL_type = STUDY.PASSIVE_palette_CLR;
        PAL_direction = STUDY.PASSIVE_palette_DIR;
        PAL_multiplier = STUDY.PASSIVE_palette_MLT;
      }
    }
    else {

      if (WIN3D.Impact_TYPE == Impact_ACTIVE) {
        PAL_type = this.ACTIVE_palette_CLR;
        PAL_direction = this.ACTIVE_palette_DIR;
        PAL_multiplier = this.ACTIVE_palette_MLT;
      }
      if (WIN3D.Impact_TYPE == Impact_PASSIVE) {
        PAL_type = this.PASSIVE_palette_CLR;
        PAL_direction = this.PASSIVE_palette_DIR;
        PAL_multiplier = this.PASSIVE_palette_MLT;
      }
    }


    String the_filename = "";
    String TEXTURE_path = "";

    if (target_window == TypeWindow.OBJ3D) {

      num_vertices_added = 0;

      if (User3D.export_MaterialLibrary) {

        the_filename = "sunPatternPalette.bmp";

        TEXTURE_path = Folder_Export3D + "/" + Subfolder_exportMaps + the_filename;

        println("Saving texture:", TEXTURE_path);

        int RES1 = User3D.export_PaletteResolution;
        int RES2 = User3D.export_PaletteResolution / 16;

        PImage palette_Texture = createImage(RES1, RES2, ARGB);


        palette_Texture.loadPixels();

        for (int np = 0; np < (RES1 * RES2); np++) {
          int Image_X = np % RES1;
          int Image_Y = np / RES1;

          float _val = (Image_X / (0.5 * RES1)) - 1;

          float _u = 0.5 + _val;

          if (WIN3D.Impact_TYPE == Impact_ACTIVE) _u = 0.5 + 0.5 * _val;

          float[] COL = PAINT.getColorStyle(PAL_type, _u);

          palette_Texture.pixels[np] = color(COL[1], COL[2], COL[3], COL[0]);
        }

        palette_Texture.updatePixels();

        palette_Texture.save(TEXTURE_path);


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
    }



    num_vertices_added = 0;

    int end_turn = 1;
    if (target_window == TypeWindow.OBJ3D) end_turn = 3;
    for (int _turn = 1; _turn <= end_turn; _turn++) {


      if (target_window == TypeWindow.OBJ3D) {

        if (_turn == 3) {

          obj_lastGroupNumber += 1;
          objOutput.println("g sunPattern");

          if (User3D.export_MaterialLibrary) {
            objOutput.println("usemtl " +  the_filename.replace('.', '_'));
          }
        }
      }



      for (int j = STUDY.j_Start; j < STUDY.j_End; j++) {

        float[][][] SunPathMesh = new float [24 * TES_hour][1 + int(STUDY_perDays / STUDY.joinDays)][3];

        for (int more_J = 0; more_J < STUDY_perDays; more_J += STUDY.joinDays) {

          now_j = (more_J + j * int(STUDY_perDays) + TIME.beginDay + 365) % 365;

          if (now_j >= 365) {
            now_j = now_j % 365;
          }
          if (now_j < 0) {
            now_j = (now_j + 365) % 365;
          }

          float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);

          float sunrise_origin = funcs.Sunrise(STATION.getLatitude(), DATE_ANGLE) + funcs.EquationOfTime(DATE_ANGLE);
          float sunset_origin = funcs.Sunset(STATION.getLatitude(), DATE_ANGLE) + funcs.EquationOfTime(DATE_ANGLE);

          //println("rise=", sunrise_origin);
          //println("set=", sunset_origin);
          //println("mid=", (sunrise_origin + sunset_origin) * 0.5);

          int[] Normals_COL_N;
          Normals_COL_N = new int [9];
          {
            int keep_filter_type = STUDY.filter;
            STUDY.filter = filter_HOURLY;

            Normals_COL_N = SOLARCHVISION_PROCESS_DAILY_SCENARIOS(start_k, end_k, more_J + j, DATE_ANGLE, target_window == TypeWindow.STUDY ? STUDY.Impact_TYPE : WIN3D.Impact_TYPE);

            STUDY.filter = keep_filter_type;
          }

          int l = STUDY.ImpactLayer;

          for (int nk = Normals_COL_N[l]; nk <= Normals_COL_N[l]; nk++) {
            if (nk != -1) {
              int k = int(nk / STUDY.joinDays);
              int j_ADD = nk % STUDY.joinDays;

              float valuesSUM_RAD = 0;
              float valuesSUM_EFF = 0;
              int valuesNUM = 0;

              for (float i = 0; i < 24; i += 1.0 / float (TES_hour)) {

                float HOUR_ANGLE = i;
                float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);

                float Alpha = 90 - funcs.acos_ang(SunR[3]);
                float Beta = 180 - funcs.atan2_ang(SunR[1], SunR[2]);

                //-------------- to extend graph to the horizon ---------------
                if (Alpha < 0) {

                  float[] SunR_temp;
                  if (i < 12) {
                    SunR_temp = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, sunrise_origin);
                  }
                  else {
                    SunR_temp = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, sunset_origin);
                  }

                  //println("x=", SunR_temp[1]);
                  //println("y=", SunR_temp[2]);
                  //println("z=", SunR_temp[3]);

                  Alpha = 0;
                  Beta = 180 - funcs.atan2_ang(SunR_temp[1], SunR_temp[2]);
                }
                //-----------------------------------------------------------

                now_k = k + start_k;

                now_i1 = floor(i);
                now_i2 = (1 + now_i1) % 24;
                float i_ratio = i - now_i1;

                now_j = int(more_J + j * STUDY_perDays + (j_ADD - int(funcs.roundTo(0.5 * STUDY.joinDays, 1))) + TIME.beginDay + 365) % 365;

                if (now_j >= 365) {
                  now_j = now_j % 365;
                }
                if (now_j < 0) {
                  now_j = (now_j + 365) % 365;
                }

                Pa1 = getValue_CurrentDataSource(now_i1, now_j, now_k, LAYER_dirnorrad.id);
                Pb1 = getValue_CurrentDataSource(now_i1, now_j, now_k, LAYER_difhorrad.id);
                Pc1 = getValue_CurrentDataSource(now_i1, now_j, now_k, LAYER_direffect.id);
                Pd1 = getValue_CurrentDataSource(now_i1, now_j, now_k, LAYER_difeffect.id);

                Pa2 = getValue_CurrentDataSource(now_i2, now_j, now_k, LAYER_dirnorrad.id);
                Pb2 = getValue_CurrentDataSource(now_i2, now_j, now_k, LAYER_difhorrad.id);
                Pc2 = getValue_CurrentDataSource(now_i2, now_j, now_k, LAYER_direffect.id);
                Pd2 = getValue_CurrentDataSource(now_i2, now_j, now_k, LAYER_difeffect.id);

                if ((is_undefined(Pa1)) || (is_undefined(Pb1)) || (is_undefined(Pc1)) || (is_undefined(Pd1))
                  || (is_undefined(Pa2)) || (is_undefined(Pb2)) || (is_undefined(Pc2)) || (is_undefined(Pd2))) {
                  values_R_dir = FLOAT_undefined;
                  values_R_dif = FLOAT_undefined;
                  values_E_dir = FLOAT_undefined;
                  values_E_dif = FLOAT_undefined;
                } else {

                  int memberCount = SOLARCHVISION_filter(CurrentDataSource, LAYER_cloudcover.id, STUDY.filter, STUDY.skyScenario, now_i1, now_j, now_k);

                  if (memberCount == 1) {
                    values_R_dir = 0.001 * (Pa1 * (1 - i_ratio) + Pa2 * i_ratio);
                    values_R_dif = 0.001 * (Pb1 * (1 - i_ratio) + Pb2 * i_ratio);
                    values_E_dir = 0.001 * (Pc1 * (1 - i_ratio) + Pc2 * i_ratio);
                    values_E_dif = 0.001 * (Pd1 * (1 - i_ratio) + Pd2 * i_ratio);

                    if (is_undefined(valuesSUM_RAD)) {
                      valuesSUM_RAD = 0;
                      valuesSUM_EFF = 0;
                      valuesNUM = 0;
                    } else {
                      valuesSUM_RAD = (values_R_dir); // direct beam radiation
                      valuesSUM_EFF = (values_E_dir); // direct beam effect
                      valuesNUM = 1;
                    }
                  }
                }

                float valuesSUM = FLOAT_undefined;
                if (WIN3D.Impact_TYPE == Impact_ACTIVE) valuesSUM = valuesSUM_RAD;
                if (WIN3D.Impact_TYPE == Impact_PASSIVE) valuesSUM = valuesSUM_EFF;

                int row_J = more_J / STUDY.joinDays;

                SunPathMesh[floor(i * TES_hour)][row_J][0] = Alpha;
                SunPathMesh[floor(i * TES_hour)][row_J][1] = Beta;
                SunPathMesh[floor(i * TES_hour)][row_J][2] = valuesSUM;
              }
            } else {
              for (float i = 0; i < 24; i += 1.0 / float (TES_hour)) {

                float valuesSUM = FLOAT_undefined;

                float HOUR_ANGLE = i;
                float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);

                float Alpha = 90 - funcs.acos_ang(SunR[3]);
                float Beta = 180 - funcs.atan2_ang(SunR[1], SunR[2]);

                int row_J = more_J / STUDY.joinDays;

                SunPathMesh[floor(i * TES_hour)][row_J][0] = Alpha;
                SunPathMesh[floor(i * TES_hour)][row_J][1] = Beta;
                SunPathMesh[floor(i * TES_hour)][row_J][2] = valuesSUM;
              }
            }
          }
        }




        for (int more_J = 0; more_J < STUDY_perDays - STUDY.joinDays; more_J += STUDY.joinDays) { //count one less!

          now_j = (more_J + j * int(STUDY_perDays) + TIME.beginDay + 365) % 365;

          if (now_j >= 365) {
            now_j = now_j % 365;
          }
          if (now_j < 0) {
            now_j = (now_j + 365) % 365;
          }

          float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);

          float sunrise = funcs.Sunrise(STATION.getLatitude(), DATE_ANGLE);
          float sunset = funcs.Sunset(STATION.getLatitude(), DATE_ANGLE);

          for (float i = 0; i < 24; i += 1.0 / float (TES_hour)) {
            if (STUDY.isInHourlyRange(i)) {
              if ((i > sunrise - 1.0 / float(TES_hour)) && (i < sunset + 1.0 / float(TES_hour))) {

                if (target_window == TypeWindow.OBJ3D) {
                } else if (target_window == TypeWindow.WIN3D) {
                  WIN3D.graphics.beginShape();
                  WIN3D.graphics.noStroke();
                } else if (target_window == TypeWindow.WORLD) {
                  WORLD.graphics.beginShape();
                  WORLD.graphics.noStroke();
                } else if (target_window == TypeWindow.STUDY) {
                  STUDY.graphics.beginShape();
                  STUDY.graphics.noStroke();
                }

                for (int s = 0; s < 4; s++) {

                  int a = int(i * TES_hour);
                  int b = more_J / STUDY.joinDays;

                  if ((s == 1) || (s == 2)) {
                    a += 1;
                  }

                  if ((s == 2) || (s == 3)) {
                    b += 1;
                  }

                  if (a > (24 * TES_hour - 1)) a = a % (24 * TES_hour);

                  float Alpha = SunPathMesh[a][b][0];
                  float Beta = SunPathMesh[a][b][1];
                  float valuesSUM = SunPathMesh[a][b][2];

                  if (Alpha >= 0) {

                    if (is_defined(valuesSUM)) {

                      float _u = 0;

                      if (WIN3D.Impact_TYPE == Impact_ACTIVE) _u = (PAL_multiplier * valuesSUM);
                      if (WIN3D.Impact_TYPE == Impact_PASSIVE) _u = 0.5 + 0.5 * (PAL_multiplier * valuesSUM);

                      if (PAL_direction == -1) _u = 1 - _u;
                      if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
                      if (PAL_direction == 2) _u =  0.5 * _u;

                      float[] COL = PAINT.getColorStyle(PAL_type, _u);

                      if (target_window == TypeWindow.OBJ3D) {

                        float x = funcs.cos_ang(Alpha) * (funcs.cos_ang(Beta - 90)) * WIN3D.scale * s_Plot + x_Plot;
                        float y = funcs.cos_ang(Alpha) * (funcs.sin_ang(Beta - 90)) * WIN3D.scale * s_Plot + y_Plot;
                        float z = funcs.sin_ang(Alpha) * WIN3D.scale * s_Plot + z_Plot;

                        if (_turn == 1) {
                          SOLARCHVISION_OBJprintVertex(x, y, z);
                        }

                        if (_turn == 2) {
                          float u1 = 0.5 * (_u + 0.5);

                          if ((WIN3D.FacesShade == SHADE.Global_Solar) ||
                              (WIN3D.FacesShade == SHADE.Vertex_Solar)) {

                            if (WIN3D.Impact_TYPE == Impact_ACTIVE) u1 = _u;
                          }

                          if (u1 > 0.999) u1 = 0.999;
                          if (u1 < 0.001) u1 = 0.001;

                          SOLARCHVISION_OBJprintVtexture(u1, 0.5, 0);
                        }

                        if (_turn == 3) {
                          num_vertices_added += 1;
                        }
                      } else if (target_window == TypeWindow.WIN3D) {
                        WIN3D.graphics.fill(COL[1], COL[2], COL[3], 127);

                        float x = funcs.cos_ang(Alpha) * (funcs.cos_ang(Beta - 90)) * WIN3D.scale * s_Plot + x_Plot;
                        float y = funcs.cos_ang(Alpha) * (funcs.sin_ang(Beta - 90)) * WIN3D.scale * s_Plot + y_Plot;
                        float z = funcs.sin_ang(Alpha) * WIN3D.scale * s_Plot + z_Plot;

                        WIN3D.graphics.vertex(x, -y, z);
                      } else if (target_window == TypeWindow.WORLD) {
                        // ??????????????????????????
                      } else if (target_window == TypeWindow.STUDY) {

                        STUDY.graphics.fill(COL[1], COL[2], COL[3], COL[0]);

                        float x = (90 - Alpha) * (funcs.cos_ang(Beta - 90)) * STUDY.rect_scale * s_Plot + x_Plot * STUDY.rect_scale;
                        float y = (90 - Alpha) * (funcs.sin_ang(Beta - 90)) * STUDY.rect_scale * s_Plot + y_Plot * STUDY.rect_scale;

                        float ox = (j + STUDY.rect_offset_x) * s_Plot;

                        STUDY.graphics.vertex(ox + x, -y);
                      }
                    }
                  }
                }

                if (target_window == TypeWindow.OBJ3D) {

                  if (_turn == 3) {

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
                  }
                } else if (target_window == TypeWindow.WIN3D) {
                  WIN3D.graphics.endShape(CLOSE);
                } else if (target_window == TypeWindow.WORLD) {
                  WORLD.graphics.endShape(CLOSE);
                } else if (target_window == TypeWindow.STUDY) {
                  STUDY.graphics.endShape(CLOSE);
                }
              }
            }
          }
        }
      }


      if (target_window == TypeWindow.OBJ3D) {
        obj_lastVertexNumber += num_vertices_added;
        obj_lastVtextureNumber += num_vertices_added;
      }
    }

    WIN3D.Impact_TYPE = keep_Impact_TYPE;
  }







  public void to_XML (XML xml) {

    println("Saving:" + this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setInt(parent, "ACTIVE_palette_CLR", this.ACTIVE_palette_CLR);
    XML_setInt(parent, "ACTIVE_palette_DIR", this.ACTIVE_palette_DIR);
    XML_setFloat(parent, "ACTIVE_palette_MLT", this.ACTIVE_palette_MLT);
    XML_setInt(parent, "PASSIVE_palette_CLR", this.PASSIVE_palette_CLR);
    XML_setInt(parent, "PASSIVE_palette_DIR", this.PASSIVE_palette_DIR);
    XML_setFloat(parent, "PASSIVE_palette_MLT", this.PASSIVE_palette_MLT);

    XML_setBoolean(parent, "displayGrid", this.displayGrid);
    XML_setBoolean(parent, "displayPath", this.displayPath);
    XML_setBoolean(parent, "displayPattern", this.displayPattern);


    XML_setBoolean(parent, "displaySurface", this.displaySurface);
    XML_setBoolean(parent, "displayTexture", this.displayTexture);
  }


  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);

    this.ACTIVE_palette_CLR = XML_getInt(parent, "ACTIVE_palette_CLR");
    this.ACTIVE_palette_DIR = XML_getInt(parent, "ACTIVE_palette_DIR");
    this.ACTIVE_palette_MLT = XML_getFloat(parent, "ACTIVE_palette_MLT");
    this.PASSIVE_palette_CLR = XML_getInt(parent, "PASSIVE_palette_CLR");
    this.PASSIVE_palette_DIR = XML_getInt(parent, "PASSIVE_palette_DIR");
    this.PASSIVE_palette_MLT = XML_getFloat(parent, "PASSIVE_palette_MLT");

    this.displayGrid = XML_getBoolean(parent, "displayGrid");
    this.displayPath = XML_getBoolean(parent, "displayPath");
    this.displayPattern = XML_getBoolean(parent, "displayPattern");

    this.displaySurface = XML_getBoolean(parent, "displaySurface");
    this.displayTexture = XML_getBoolean(parent, "displayTexture");
  }
}
