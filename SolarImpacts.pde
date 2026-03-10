class solarchvision_SolarImpacts {

  private final static String CLASS_STAMP = "SolarImpacts";

  boolean rebuild_Image_array = true;

  PImage[][] Image;

  boolean displayImage = false;

  int sectionType = 0; // 0:off, 1:horizontal, 2:vertical(front), 3:vertical(side)

  float Y = 0;
  float X = 0;
  float Z = 0;
  float R = 0; // North is up by default
  float U = 500; // i.e. 500 = 500m
  float V = 500; // i.e. 500 = 500m

  int RES1 = 200;
  int RES2 = 200;



  int record_IMG = 0;

  void resize_Image_array () {

    this.Image = new PImage [2][(1 + STUDY.j_End - STUDY.j_Start)];

    for (int i = 0; i < this.Image.length; i++) {
      for (int j = STUDY.j_Start - 1; j < STUDY.j_End; j++) { // total image at j = -1

        this.Image[i][j + 1] = createImage(2, 2, RGB); // empty and small
      }
    }

    allSolarImpacts.rebuild_Image_array = false;
  }


  void calculate_Impact_CurrentPreBaked () {

    if (allSolarImpacts.rebuild_Image_array) {
      this.resize_Image_array();
    }

    if (this.sectionType != 0) {

      cursor(WAIT);

      int[] startK_endK = get_startK_endK();
      int start_k = startK_endK[0];
      int end_k = startK_endK[1];
      int count_k = 1 + end_k - start_k;
      if (count_k < 0) count_k = 0;


      int RES1 = this.RES1;
      int RES2 = this.RES2;

      float Pa = FLOAT_undefined;
      float Pb = FLOAT_undefined;
      float Pc = FLOAT_undefined;
      float Pd = FLOAT_undefined;

      float values_R_dir;
      float values_R_dif;

      float values_E_dir;
      float values_E_dif;

      int now_k = 0;
      int now_i = 0;
      int now_j = 0;

      for (int p = 0; p < 1; p++) {
        int l = STUDY.ImpactLayer;

        PImage[] total_Image_RGBA = new PImage[2];
        for (int q = 0; q < numberOfImpactVariations; q++) {
          total_Image_RGBA[q] = createImage(RES1, RES2, RGB);
        }

        float[][][][] total_Matrix_ARGB;
        total_Matrix_ARGB = new float [2][4][RES1][RES2];

        for (int np = 0; np < (RES1 * RES2); np++) {
          int Image_X = np % RES1;
          int Image_Y = np / RES1;

          for (int q = 0; q < numberOfImpactVariations; q++) {
            total_Matrix_ARGB[q][0][Image_X][Image_Y] = 0;
            total_Matrix_ARGB[q][1][Image_X][Image_Y] = 0;
            total_Matrix_ARGB[q][2][Image_X][Image_Y] = 0;
            total_Matrix_ARGB[q][3][Image_X][Image_Y] = 0;
          }
        }

        for (int j = STUDY.j_Start; j < STUDY.j_End; j++) {

          now_j = (j * int(STUDY.perDays) + TIME.beginDay + 365) % 365;

          if (now_j >= 365) {
            now_j = now_j % 365;
          }
          if (now_j < 0) {
            now_j = (now_j + 365) % 365;
          }

          float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);

          int DATE_ANGLE_approximate = int((DATE_ANGLE + 15) / 30) * 30;
          if (DATE_ANGLE_approximate == 360) DATE_ANGLE_approximate = 0;

          //println(DATE_ANGLE, DATE_ANGLE_approximate);

          int[] Normals_COL_N;
          Normals_COL_N = new int [9];
          Normals_COL_N = SOLARCHVISION_PROCESS_DAILY_SCENARIOS(start_k, end_k, j, DATE_ANGLE, STUDY.Impact_TYPE);

          //println("j =", j);
          //println(Normals_COL_N);

          for (int nk = Normals_COL_N[l]; nk <= Normals_COL_N[l]; nk++) {
            if (nk != -1) {
              int k = int(nk / STUDY.joinDays);
              int j_ADD = nk % STUDY.joinDays;

              float[][][][] Matrix_ARGB;

              Matrix_ARGB = new float [2][4][RES1][RES2];

              for (int np = 0; np < (RES1 * RES2); np++) {
                int Image_X = np % RES1;
                int Image_Y = np / RES1;

                for (int q = 0; q < numberOfImpactVariations; q++) {
                  Matrix_ARGB[q][0][Image_X][Image_Y] = FLOAT_undefined;
                  Matrix_ARGB[q][1][Image_X][Image_Y] = FLOAT_undefined;
                  Matrix_ARGB[q][2][Image_X][Image_Y] = FLOAT_undefined;
                  Matrix_ARGB[q][3][Image_X][Image_Y] = FLOAT_undefined;
                }
              }

              PImage[] Image_RGBA = new PImage[2];
              for (int q = 0; q < numberOfImpactVariations; q++) {
                Image_RGBA[q] = createImage(RES1, RES2, RGB);
              }

              int valuesNUM = 0;

              for (int i = 4; i <= 20; i++) { // to make it faster. Also the images are not available out of this period.
                if (STUDY.isInHourlyRange(i)) {

                  float HOUR_ANGLE = i;
                  float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);

                  if (SunR[3] > 0) {

                    now_k = k + start_k;
                    now_i = i;
                    now_j = int(j * STUDY.perDays + (j_ADD - int(funcs.roundTo(0.5 * STUDY.joinDays, 1))) + TIME.beginDay + 365) % 365;

                    if (now_j >= 365) {
                      now_j = now_j % 365;
                    }
                    if (now_j < 0) {
                      now_j = (now_j + 365) % 365;
                    }

                    Pa = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_dirnorrad.id);
                    Pb = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_difhorrad.id);
                    Pc = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_direffect.id);
                    Pd = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_difeffect.id);

                    if (is_undefined(Pa) || is_undefined(Pb) || is_undefined(Pc) || is_undefined(Pd)) {
                      values_R_dir = FLOAT_undefined;
                      values_R_dif = FLOAT_undefined;
                      values_E_dir = FLOAT_undefined;
                      values_E_dif = FLOAT_undefined;
                    } else {

                      int memberCount = SOLARCHVISION_filter(CurrentDataSource, LAYER_cloudcover.id, STUDY.filter, STUDY.skyScenario, now_i, now_j, now_k);

                      if (memberCount == 1) {
                        values_R_dir = 0.001 * Pa;
                        values_R_dif = 0.001 * Pb;
                        values_E_dir = 0.001 * Pc;
                        values_E_dif = 0.001 * Pd;

                        for (int RAD_TYPE = 0; RAD_TYPE <= 1; RAD_TYPE++) {
                          float RAD_VALUE = 0;
                          float EFF_VALUE = 0;
                          if (RAD_TYPE == 0) {
                            RAD_VALUE = values_R_dir;
                            EFF_VALUE = values_E_dir;
                          } else {
                            //float MULT_dif = 2.0;
                            float MULT_dif = FLOAT_e; // 2.718

                            RAD_VALUE = values_R_dif * MULT_dif;
                            EFF_VALUE = values_E_dif * MULT_dif;
                          }

                          PImage[] Shadings = new PImage [2];
                          for (int SHD = 0; SHD <= 1; SHD++) {
                            String[] STR_SHD = {
                              "F", "T"
                            };
                            String File_Name = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName;

                            if (RAD_TYPE == 0) {
                              File_Name += nf(DATE_ANGLE_approximate, 3) + "_" + STR_SHD[SHD] + "_" + nf(int(funcs.roundTo(HOUR_ANGLE * 100, 1.0)), 4);
                            } else {
                              File_Name += "DIF_" + STR_SHD[SHD];
                            }

                            File_Name += "_Camera" + nf(Camera_Variation, 2) + ".png";


                            println(File_Name);
                            Shadings[SHD]  = loadImage(File_Name);
                          }

                          for (int np = 0; np < (RES1 * RES2); np++) {
                            int Image_X = np % RES1;
                            int Image_Y = np / RES1;

                            for (int q = 0; q < numberOfImpactVariations; q++) {
                              if (is_undefined(Matrix_ARGB[q][0][Image_X][Image_Y])) {

                                Matrix_ARGB[q][0][Image_X][Image_Y] = 0;
                                Matrix_ARGB[q][1][Image_X][Image_Y] = 0;
                                Matrix_ARGB[q][2][Image_X][Image_Y] = 0;
                                Matrix_ARGB[q][3][Image_X][Image_Y] = 0;
                              }
                            }

                            color COL0 = Shadings[0].get(Image_X, Image_Y);
                            color COL1 = Shadings[1].get(Image_X, Image_Y);
                            //red: COL >> 16 & 0xFF; green: COL >>8 & 0xFF; blue: COL & 0xFF;
                            float COL_V0 = (COL0 >> 8 & 0xFF) / 255.0;
                            float COL_V1 = (COL1 >> 8 & 0xFF) / 255.0;

                            float COL_Alpha = (COL1 >> 24 & 0xFF);

                            Matrix_ARGB[Impact_ACTIVE][0][Image_X][Image_Y] = COL_Alpha;
                            Matrix_ARGB[Impact_PASSIVE][0][Image_X][Image_Y] = COL_Alpha;

                            Matrix_ARGB[Impact_ACTIVE][2][Image_X][Image_Y] += RAD_VALUE * COL_V1;

                            if (EFF_VALUE < 0) {
                              Matrix_ARGB[Impact_PASSIVE][1][Image_X][Image_Y] -= EFF_VALUE * COL_V1;
                              if (COL_V0 != COL_V1) Matrix_ARGB[Impact_PASSIVE][3][Image_X][Image_Y] -= EFF_VALUE * (COL_V0 - COL_V1);
                            } else {
                              Matrix_ARGB[Impact_PASSIVE][3][Image_X][Image_Y] += EFF_VALUE * COL_V1;
                              if (COL_V0 != COL_V1) Matrix_ARGB[Impact_PASSIVE][1][Image_X][Image_Y] += EFF_VALUE * (COL_V0 - COL_V1);
                            }

                            if (np == 0) valuesNUM += 1;
                          }
                        }
                      }
                    }
                  }
                }
              }

              float valuesMUL = 0;

              if (valuesNUM != 0) {
                //valuesMUL = funcs.DayTime(STATION.getLatitude(), DATE_ANGLE) / (1.0 * valuesNUM);
                //valuesMUL = int(funcs.DayTime(STATION.getLatitude(), DATE_ANGLE)) / (1.0 * valuesNUM);
                valuesMUL = funcs.roundTo(funcs.DayTime(STATION.getLatitude(), DATE_ANGLE), 1) / (1.0 * valuesNUM);
              }


              for (int q = 0; q < numberOfImpactVariations; q++) {
                Image_RGBA[q].loadPixels();
              }

              for (int np = 0; np < (RES1 * RES2); np++) {
                int Image_X = np % RES1;
                int Image_Y = np / RES1;

                for (int q = 0; q < numberOfImpactVariations; q++) {

                  float Image_A = Matrix_ARGB[q][0][Image_X][Image_Y] * valuesMUL;
                  float Image_R = Matrix_ARGB[q][1][Image_X][Image_Y] * valuesMUL;
                  float Image_G = Matrix_ARGB[q][2][Image_X][Image_Y] * valuesMUL;
                  float Image_B = Matrix_ARGB[q][3][Image_X][Image_Y] * valuesMUL;

                  total_Matrix_ARGB[q][0][Image_X][Image_Y] += Image_A;
                  total_Matrix_ARGB[q][1][Image_X][Image_Y] += Image_R;
                  total_Matrix_ARGB[q][2][Image_X][Image_Y] += Image_G;
                  total_Matrix_ARGB[q][3][Image_X][Image_Y] += Image_B;

                  float[] _c = {
                    0, 0, 0, 0
                  };

                  float _u = 0;

                  float valuesSUM = FLOAT_undefined;

                  int PAL_type = 0;
                  int PAL_direction = 1;
                  float PAL_multiplier = 1;

                  if (q == Impact_ACTIVE) {
                    valuesSUM = Image_G;

                    PAL_type = allFaces.ACTIVE_pallet_CLR;
                    PAL_direction = allFaces.ACTIVE_pallet_DIR;
                    PAL_multiplier = allFaces.ACTIVE_pallet_MLT;

                    //_u = 0.5 * (0.1 * PAL_multiplier * valuesSUM);
                    //_u = (0.1 * PAL_multiplier * valuesSUM);
                    _u = (0.2 * PAL_multiplier * valuesSUM);
                  }

                  if (q == Impact_PASSIVE) {
                    float AVERAGE, PERCENTAGE, COMPARISON;

                    AVERAGE = (Image_B - Image_R);
                    if ((Image_B + Image_R) > 0.00001) PERCENTAGE = (Image_B - Image_R) / (1.0 * (Image_B + Image_R));
                    else PERCENTAGE = 0.0;
                    COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);

                    valuesSUM = COMPARISON;

                    PAL_type = allFaces.PASSIVE_pallet_CLR;
                    PAL_direction = allFaces.PASSIVE_pallet_DIR;
                    PAL_multiplier = allFaces.PASSIVE_pallet_MLT;

                    //_u = 0.5 + 0.5 * (0.1 * PAL_multiplier * valuesSUM);
                    _u = 0.5 + 0.5 * (0.2 * PAL_multiplier * valuesSUM);
                  }


                  //if ((Image_X == RES1 / 2) && (Image_Y == RES2 / 2)) println("Image Processing: <CENTER> valuesSUM =", valuesSUM);
                  //if ((Image_X == RES1 - 1) && (Image_Y == RES2 - 1)) println("Image Processing: <CORNER> valuesSUM =", valuesSUM);

                  if (PAL_direction == -1) _u = 1 - _u;
                  if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
                  if (PAL_direction == 2) _u =  0.5 * _u;

                  _c = PAINT.getColorStyle(PAL_type, _u);

                  if (Image_A != 0) Image_RGBA[q].pixels[np] = color(_c[1], _c[2], _c[3]);
                  else Image_RGBA[q].pixels[np] = color(223, 223, 223);
                }
              }

              for (int q = 0; q < numberOfImpactVariations; q++) {
                Image_RGBA[q].updatePixels();


                //if (Camera_Variation == 0) {
                this.Image[q][j + 1] = Image_RGBA[q];
                if (this.record_IMG == 1) {
                  String myFile = getFilename_SolarImpact() + "_solar_" + nf(q, 1) + "_" + nf(j + 1, 0) + ".jpg";
                  this.Image[q][j + 1].save(myFile);
                  println("File created:" + myFile);
                }
                //}
              }
            }
          }
        }

        {
          int j = -1; // << to put the summary graph before the daily graphs

          for (int q = 0; q < numberOfImpactVariations; q++) {
            total_Image_RGBA[q].loadPixels();
          }

          for (int np = 0; np < (RES1 * RES2); np++) {
            int Image_X = np % RES1;
            int Image_Y = np / RES1;

            for (int q = 0; q < numberOfImpactVariations; q++) {

              float Image_A = total_Matrix_ARGB[q][0][Image_X][Image_Y] / (1.0 * (STUDY.j_End - STUDY.j_Start));
              float Image_R = total_Matrix_ARGB[q][1][Image_X][Image_Y] / (1.0 * (STUDY.j_End - STUDY.j_Start));
              float Image_G = total_Matrix_ARGB[q][2][Image_X][Image_Y] / (1.0 * (STUDY.j_End - STUDY.j_Start));
              float Image_B = total_Matrix_ARGB[q][3][Image_X][Image_Y] / (1.0 * (STUDY.j_End - STUDY.j_Start));

              float[] _c = {
                0, 0, 0, 0
              };

              float _u = 0;

              float valuesSUM = FLOAT_undefined;

              int PAL_type = 0;
              int PAL_direction = 1;
              float PAL_multiplier = 1;

              if (q == Impact_ACTIVE) {
                valuesSUM = Image_G;

                PAL_type = allFaces.ACTIVE_pallet_CLR;
                PAL_direction = allFaces.ACTIVE_pallet_DIR;
                PAL_multiplier = allFaces.ACTIVE_pallet_MLT;

                //_u = 0.5 * (0.1 * PAL_multiplier * valuesSUM);
                //_u = (0.1 * PAL_multiplier * valuesSUM);
                _u = (0.2 * PAL_multiplier * valuesSUM);
              }

              if (q == Impact_PASSIVE) {
                float AVERAGE, PERCENTAGE, COMPARISON;

                AVERAGE = (Image_B - Image_R);
                if ((Image_B + Image_R) > 0.00001) PERCENTAGE = (Image_B - Image_R) / (1.0 * (Image_B + Image_R));
                else PERCENTAGE = 0.0;
                COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);

                valuesSUM = COMPARISON;

                PAL_type = allFaces.PASSIVE_pallet_CLR;
                PAL_direction = allFaces.PASSIVE_pallet_DIR;
                PAL_multiplier = allFaces.PASSIVE_pallet_MLT;

                //_u = 0.5 + 0.5 * (0.1 * PAL_multiplier * valuesSUM);
                _u = 0.5 + 0.5 * (0.2 * PAL_multiplier * valuesSUM);
              }

              if (PAL_direction == -1) _u = 1 - _u;
              if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
              if (PAL_direction == 2) _u =  0.5 * _u;

              _c = PAINT.getColorStyle(PAL_type, _u);

              if (Image_A != 0) total_Image_RGBA[q].pixels[np] = color(_c[1], _c[2], _c[3]);
              else total_Image_RGBA[q].pixels[np] = color(223, 223, 223);
            }
          }

          for (int q = 0; q < numberOfImpactVariations; q++) {

            total_Image_RGBA[q].updatePixels();

            //if (Camera_Variation == 0) {
            this.Image[q][0] = total_Image_RGBA[q];
            if (this.record_IMG == 1) {
              String myFile = getFilename_SolarImpact() + "_solar_" + nf(q, 1) + "_" + nf(0, 0) + ".jpg";
              this.Image[q][0].save(myFile);
              println("File created:" + myFile);
            }
            //}
          }
        }
      }

      cursor(ARROW);
    }
  }



  void render_Shadows_selectedSections () {

    for (int o = Select3D.Section_ids.length - 1; o >= 0; o--) {

      int f = Select3D.Section_ids[o];

      this.sectionType = allSections.get_type(f);
      this.RES1 = allSections.get_res1(f);
      this.RES2 = allSections.get_res2(f);

      this.X = allSections.getX(f);
      this.Y = allSections.getY(f);
      this.Z = allSections.getZ(f) + 0.1; // <<
      this.R = allSections.getR(f);
      this.U = allSections.getU(f);
      this.V = allSections.getV(f);

      SceneName = "Section_" + Section_Stamp();

      SOLARCHVISION_castShadows_CurrentSection();
    }

    this.displayImage = true;
    allSolidImpacts.displayImage = false;
    ROLLOUT.revise();
  }




  void calculate_Impact_selectedSections () {

    for (int o = Select3D.Section_ids.length - 1; o >= 0; o--) {

      int f = Select3D.Section_ids[o];

      this.sectionType = allSections.get_type(f);
      this.RES1        = allSections.get_res1(f);
      this.RES2        = allSections.get_res2(f);

      this.X = allSections.getX(f);
      this.Y = allSections.getY(f);
      this.Z = allSections.getZ(f) + 0.1; // <<
      this.R = allSections.getR(f);
      this.U = allSections.getU(f);
      this.V = allSections.getV(f);

      SceneName = "Section_" + Section_Stamp();

      this.calculate_Impact_CurrentPreBaked();


      for (int j = STUDY.j_Start - 1; j < STUDY.j_End; j++) {
        for (int q = 0; q < numberOfImpactVariations; q++) {
          allSections.SolarImpact[f][j + 1][q] = createImage(this.RES1, this.RES2, RGB);

          allSections.SolarImpact[f][j + 1][q].copy(this.Image[q][j + 1], 0, 0, this.RES1, this.RES2, 0, 0, this.RES1, this.RES2);
        }
      }
    }
  }


  public void to_XML (XML xml) {

    println("Saving:" + this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setBoolean(parent, "displayImage", this.displayImage);

    XML_setFloat(parent, "X", this.X);
    XML_setFloat(parent, "Y", this.Y);
    XML_setFloat(parent, "Z", this.Z);
    XML_setFloat(parent, "R", this.R);
    XML_setFloat(parent, "U", this.U);
    XML_setFloat(parent, "V", this.V);

    XML_setInt(parent, "RES1", this.RES1);
    XML_setInt(parent, "RES2", this.RES2);

    XML_setInt(parent, "sectionType", this.sectionType);
  }


  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);

    this.displayImage = XML_getBoolean(parent, "displayImage");

    this.X = XML_getFloat(parent, "X");
    this.Y = XML_getFloat(parent, "Y");
    this.Z = XML_getFloat(parent, "Z");
    this.R = XML_getFloat(parent, "R");
    this.U = XML_getFloat(parent, "U");
    this.V = XML_getFloat(parent, "V");

    this.RES1 = XML_getInt(parent, "RES1");
    this.RES2 = XML_getInt(parent, "RES2");
    this.sectionType = XML_getInt(parent, "sectionType");
  }


}
