void SOLARCHVISION_calculate_VertexSolar_array () {

  cursor(WAIT);

  println("Calculating direct and diffuse values at each vertex. Please wait...");

  VertexSolar_resize_array();

  float keep_STUDY_perDays = STUDY.perDays;
  int keep_STUDY_joinDays = STUDY.joinDays;
  if ((CurrentDataSource == dataID_ENSEMBLE_FORECAST) ||
      (CurrentDataSource == dataID_ENSEMBLE_OBSERVED)) {
    STUDY.perDays = 1;
    STUDY.joinDays = 1;
  }

  int[] startK_endK = get_startK_endK();
  int start_k = startK_endK[0];
  int end_k = startK_endK[1];
  int count_k = 1 + end_k - start_k;
  if (count_k < 0) count_k = 0;

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

  float Progress = 0;
  float printed_Progress = 0;
  progressBarHeader();
  for (int f = 0; f < allFaces.nodes.length; f++) {

    Progress = 100 * f / float(allFaces.nodes.length);
    float delta = floor(Progress - printed_Progress);
    if(delta >= 1) {
      for(int c = 0; c < delta; c++) {
        print("█");
      }
      printed_Progress = floor(Progress);
    }

    int vsb = allFaces.getVisibility(f);

    if (vsb > 0) {

      int tessellation = allFaces.getTessellation(f);

      int totalNumberOfSubs = 1;
      if (allFaces.getMaterial(f) == 0) {
        tessellation += allFaces.displayTessellation;
      }
      if (tessellation > 0) totalNumberOfSubs = allFaces.nodes[f].length * int(funcs.roundTo(pow(4, tessellation - 1), 1));

      float[][] base_Vertices = new float [allFaces.nodes[f].length][3];
      for (int j = 0; j < allFaces.nodes[f].length; j++) {
        int vNo = allFaces.nodes[f][j];
        base_Vertices[j][0] = allPoints.getX(vNo);
        base_Vertices[j][1] = allPoints.getY(vNo);
        base_Vertices[j][2] = allPoints.getZ(vNo);
      }

      for (int n = 0; n < totalNumberOfSubs; n++) {

        float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

        for (int s = 0; s < subFace.length; s++) {

          int q = SHADE.findID_SolarImpact_atXYZ(subFace[s][0], subFace[s][1], subFace[s][2]);

          if (q < 0) { // this will compute and add new points to the list only if there are not computed before.

            int s_next = (s + 1) % subFace.length;
            int s_prev = (s + subFace.length - 1) % subFace.length;

            PVector U = new PVector(subFace[s_next][0] - subFace[s][0], subFace[s_next][1] - subFace[s][1], subFace[s_next][2] - subFace[s][2]);
            PVector V = new PVector(subFace[s_prev][0] - subFace[s][0], subFace[s_prev][1] - subFace[s][1], subFace[s_prev][2] - subFace[s][2]);
            PVector UV = U.cross(V);
            float[] W = {
              UV.x, UV.y, UV.z
            };
            W = funcs.vec3_unit(W);

            float Alpha = funcs.asin_ang(W[2]);
            float Beta = funcs.atan2_ang(W[1], W[0]) + 90;

            float[] VECT = {
              0, 0, 0
            };

            if (abs(Alpha) > 89.99) {
              VECT[0] = 0;
              VECT[1] = 0;
              VECT[2] = 1;
            } else if (Alpha < -89.99) {
              VECT[0] = 0;
              VECT[1] = 0;
              VECT[2] = -1;
            } else {
              VECT[0] = funcs.sin_ang(Beta);
              VECT[1] = -funcs.cos_ang(Beta);
              VECT[2] = funcs.tan_ang(Alpha);
            }

            VECT = funcs.vec3_unit(VECT);


            float SkyMask = 0;

            for (int i = 0; i < DiffuseVectors.length; i++) {
              float[] SkyV = {
                DiffuseVectors[i][0], DiffuseVectors[i][1], DiffuseVectors[i][2]
              };

              float tmp = funcs.vec_dot(funcs.vec3_unit(SkyV), funcs.vec3_unit(VECT));
              if (tmp <= 0) tmp = 0; // removes backing faces

              SkyMask += tmp / float(DiffuseVectors.length);
            }



            int l = STUDY.ImpactLayer;

            int DATE_step = 1;

            int J_START = STUDY.j_Start;
            int J_END = STUDY.j_End;

            float TOTALvaluesSUM_RAD = FLOAT_undefined;
            float TOTALvaluesSUM_EFF_P = FLOAT_undefined;
            float TOTALvaluesSUM_EFF_N = FLOAT_undefined;
            int TOTALvaluesNUM = 0;

            for (int j = J_START; j < J_END; j += DATE_step) {

              float valuesSUM_RAD = FLOAT_undefined;
              float valuesSUM_EFF_P = FLOAT_undefined;
              float valuesSUM_EFF_N = FLOAT_undefined;
              int valuesNUM = 0;

              now_j = (j * int(STUDY.perDays) + TIME.beginDay + 365) % 365;

              if (now_j >= 365) {
                now_j = now_j % 365;
              }
              if (now_j < 0) {
                now_j = (now_j + 365) % 365;
              }

              float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);

              int[] Normals_COL_N = SOLARCHVISION_PROCESS_DAILY_SCENARIOS(start_k, end_k, j, DATE_ANGLE, WIN3D.Impact_TYPE);

              int nk = Normals_COL_N[l];

              if (nk != -1) {
                int k = int(nk / STUDY.joinDays);
                int j_ADD = nk % STUDY.joinDays;

                for (int i = 0; i < 24; i++) {

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

                          if (is_undefined(valuesSUM_RAD)) {
                            valuesSUM_RAD = 0;
                            valuesSUM_EFF_P = 0;
                            valuesSUM_EFF_N = 0;
                            valuesNUM = 0;
                          } else {



                            float[] SunV = {
                              SunR[1], SunR[2], SunR[3]
                            };

                            float SunMask = funcs.vec_dot(funcs.vec3_unit(SunV), funcs.vec3_unit(VECT));
                            if (SunMask <= 0) SunMask = 0; // removes backing faces



                            float[] ray_start = subFace[s];
                            float[] ray_direction = {
                              SunR[1], SunR[2], SunR[3]
                            };

                            if (funcs.vec_dot(W, ray_direction) > 0) { // removes backing faces

                              if (SOLARCHVISION_isIntersected_Faces(ray_start, ray_direction, 0) != 0) {
                                if (values_E_dir < 0) {
                                  valuesSUM_EFF_P += -(values_E_dir * SunMask);
                                  valuesSUM_EFF_N += -(values_E_dif * SkyMask);
                                } else {
                                  valuesSUM_EFF_N += (values_E_dir * SunMask);
                                  valuesSUM_EFF_P += (values_E_dif * SkyMask);
                                }

                                valuesSUM_RAD += (values_R_dif * SkyMask);
                              } else {
                                if (values_E_dir < 0) {
                                  valuesSUM_EFF_N += -((values_E_dir * SunMask) + (values_E_dif * SkyMask));
                                } else {
                                  valuesSUM_EFF_P += ((values_E_dir * SunMask) + (values_E_dif * SkyMask));
                                }

                                valuesSUM_RAD += ((values_R_dir * SunMask) + (values_R_dif * SkyMask)); // calculates total radiation
                              }
                            }
                            valuesNUM += 1;
                          }
                        }
                      }
                    }
                  }
                }
              }


              if (valuesNUM != 0) {
                //float valuesMUL = funcs.DayTime(STATION.getLatitude(), DATE_ANGLE) / (1.0 * valuesNUM);
                //float valuesMUL = int(funcs.DayTime(STATION.getLatitude(), DATE_ANGLE)) / (1.0 * valuesNUM);
                float valuesMUL = funcs.roundTo(funcs.DayTime(STATION.getLatitude(), DATE_ANGLE), 1) / (1.0 * valuesNUM);

                valuesSUM_RAD *= valuesMUL;
                valuesSUM_EFF_P *= valuesMUL;
                valuesSUM_EFF_N *= valuesMUL;

                if (TOTALvaluesNUM == 0) {
                  TOTALvaluesSUM_RAD = 0;
                  TOTALvaluesSUM_EFF_P = 0;
                  TOTALvaluesSUM_EFF_N = 0;
                }

                TOTALvaluesSUM_RAD += valuesSUM_RAD;
                TOTALvaluesSUM_EFF_P += valuesSUM_EFF_P;
                TOTALvaluesSUM_EFF_N += valuesSUM_EFF_N;
                TOTALvaluesNUM += 1;
              } else {
                valuesSUM_RAD = FLOAT_undefined;
                valuesSUM_EFF_P = FLOAT_undefined;
                valuesSUM_EFF_N = FLOAT_undefined;
              }

              float AVERAGE, PERCENTAGE, COMPARISON;

              AVERAGE = (valuesSUM_EFF_P - valuesSUM_EFF_N);
              if ((valuesSUM_EFF_P + valuesSUM_EFF_N) > 0.00001) PERCENTAGE = (valuesSUM_EFF_P - valuesSUM_EFF_N) / (1.0 * (valuesSUM_EFF_P + valuesSUM_EFF_N));
              else PERCENTAGE = 0.0;
              COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);

              //println("3D-Model >> valuesSUM_RAD:", valuesSUM_RAD, "|COMPARISON:", COMPARISON);

              float[] ADDvalues_RAD = {
                valuesSUM_RAD
              };
              VertexSolar_amounts[Impact_ACTIVE][j + 1] = (float[]) concat(VertexSolar_amounts[Impact_ACTIVE][j + 1], ADDvalues_RAD);

              float[] ADDvalues_EFF = {
                COMPARISON
              };
              VertexSolar_amounts[Impact_PASSIVE][j + 1] = (float[]) concat(VertexSolar_amounts[Impact_PASSIVE][j + 1], ADDvalues_EFF);

            }


            if (TOTALvaluesNUM != 0) {
              TOTALvaluesSUM_RAD /= 1.0 * TOTALvaluesNUM;
              TOTALvaluesSUM_EFF_P /= 1.0 * TOTALvaluesNUM;
              TOTALvaluesSUM_EFF_N /= 1.0 * TOTALvaluesNUM;
            } else {
              TOTALvaluesSUM_RAD = FLOAT_undefined;
              TOTALvaluesSUM_EFF_P = FLOAT_undefined;
              TOTALvaluesSUM_EFF_N = FLOAT_undefined;
            }


            float AVERAGE, PERCENTAGE, COMPARISON;

            AVERAGE = (TOTALvaluesSUM_EFF_P - TOTALvaluesSUM_EFF_N);
            if ((TOTALvaluesSUM_EFF_P + TOTALvaluesSUM_EFF_N) > 0.00001) PERCENTAGE = (TOTALvaluesSUM_EFF_P - TOTALvaluesSUM_EFF_N) / (1.0 * (TOTALvaluesSUM_EFF_P + TOTALvaluesSUM_EFF_N));
            else PERCENTAGE = 0.0;
            COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);


            float valuesSUM = FLOAT_undefined;
            if (WIN3D.Impact_TYPE == Impact_ACTIVE) valuesSUM = TOTALvaluesSUM_RAD;
            if (WIN3D.Impact_TYPE == Impact_PASSIVE) valuesSUM = COMPARISON;

            //println("3D-Model >> valuesSUM_RAD:", valuesSUM_RAD, "|COMPARISON:", COMPARISON);

            float[] ADDvalues_RAD = {
              TOTALvaluesSUM_RAD
            };
            VertexSolar_amounts[Impact_ACTIVE][0] = (float[]) concat(VertexSolar_amounts[Impact_ACTIVE][0], ADDvalues_RAD);

            float[] ADDvalues_EFF = {
              COMPARISON
            };
            VertexSolar_amounts[Impact_PASSIVE][0] = (float[]) concat(VertexSolar_amounts[Impact_PASSIVE][0], ADDvalues_EFF);

            float[][] ADD_values_XYZ = {
              {
                subFace[s][0], subFace[s][1], subFace[s][2]
              }
            };
            VertexSolar_XYZ = (float[][]) concat(VertexSolar_XYZ, ADD_values_XYZ);

          }

        }

      }
    }
  }

  println();

  cursor(ARROW);
}
