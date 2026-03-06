void SOLARCHVISION_calculate_GlobalSolar_array () {

  cursor(WAIT);

  if (GlobalSolar_rebuild_array) {
    GlobalSolar_resize_array();
  }

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

  int l = STUDY.ImpactLayer;

  float[][] TOTALvaluesSUM_RAD = new float [1 + int(180 / Sky3D.stp_slp)][1 + int(360 / Sky3D.stp_dir)];
  float[][] TOTALvaluesSUM_EFF_P = new float [1 + int(180 / Sky3D.stp_slp)][1 + int(360 / Sky3D.stp_dir)];
  float[][] TOTALvaluesSUM_EFF_N = new float [1 + int(180 / Sky3D.stp_slp)][1 + int(360 / Sky3D.stp_dir)];
  int[][] TOTALvaluesNUM = new int [1 + int(180 / Sky3D.stp_slp)][1 + int(360 / Sky3D.stp_dir)];

  for (int a = 0; a <= int (180 / Sky3D.stp_slp); a++) {
    for (int b = 0; b < int (360 / Sky3D.stp_dir); b++) {
      TOTALvaluesSUM_RAD[a][b] = FLOAT_undefined;
      TOTALvaluesSUM_EFF_P[a][b] = FLOAT_undefined;
      TOTALvaluesSUM_EFF_N[a][b] = FLOAT_undefined;
      TOTALvaluesNUM[a][b] = 0;
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

    int[] Normals_COL_N;
    Normals_COL_N = new int [9];
    Normals_COL_N = SOLARCHVISION_PROCESS_DAILY_SCENARIOS(start_k, end_k, j, DATE_ANGLE, Impact_TYPE);

    for (int nk = Normals_COL_N[l]; nk <= Normals_COL_N[l]; nk++) {
      if (nk != -1) {
        int k = int(nk / STUDY.joinDays);
        int j_ADD = nk % STUDY.joinDays;

        for (int a = 0; a <= int (180 / Sky3D.stp_slp); a++) {
          float Alpha = a * Sky3D.stp_slp - 90;
          for (int b = 0; b < int (360 / Sky3D.stp_dir); b++) {
            float Beta = b * Sky3D.stp_dir;

            float valuesSUM_RAD = 0;
            float valuesSUM_EFF_P = 0;
            float valuesSUM_EFF_N = 0;
            int valuesNUM = 0;

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

                        if (values_E_dir < 0) {
                          valuesSUM_EFF_N += -SOLARCHVISION_SolarAtSurface(SunR[1], SunR[2], SunR[3], values_E_dir, values_E_dif, Alpha, Beta, GlobalAlbedo);
                        } else {
                          valuesSUM_EFF_P += SOLARCHVISION_SolarAtSurface(SunR[1], SunR[2], SunR[3], values_E_dir, values_E_dif, Alpha, Beta, GlobalAlbedo);
                        }

                        valuesSUM_RAD += SOLARCHVISION_SolarAtSurface(SunR[1], SunR[2], SunR[3], values_R_dir, values_R_dif, Alpha, Beta, GlobalAlbedo);

                        valuesNUM += 1;
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

              if (TOTALvaluesNUM[a][b] == 0) {
                TOTALvaluesSUM_RAD[a][b] = 0;
                TOTALvaluesSUM_EFF_P[a][b] = 0;
                TOTALvaluesSUM_EFF_N[a][b] = 0;
              }

              TOTALvaluesSUM_RAD[a][b] += valuesSUM_RAD;
              TOTALvaluesSUM_EFF_P[a][b] += valuesSUM_EFF_P;
              TOTALvaluesSUM_EFF_N[a][b] += valuesSUM_EFF_N;
              TOTALvaluesNUM[a][b] += 1;
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

            if (is_defined(valuesSUM_RAD)) {
              GlobalSolar[Impact_ACTIVE][j + 1][a][b] = valuesSUM_RAD;
            }
            if (is_defined(COMPARISON)) {
              GlobalSolar[Impact_PASSIVE][j + 1][a][b] = COMPARISON;
            }
          }
        }
      }
    }
  }



  for (int a = 0; a <= int (180 / Sky3D.stp_slp); a++) {
    float Alpha = a * Sky3D.stp_slp - 90;
    for (int b = 0; b < int (360 / Sky3D.stp_dir); b++) {
      float Beta = b * Sky3D.stp_dir;

      if (TOTALvaluesNUM[a][b] != 0) {
        TOTALvaluesSUM_RAD[a][b] /= 1.0 * TOTALvaluesNUM[a][b];
        TOTALvaluesSUM_EFF_P[a][b] /= 1.0 * TOTALvaluesNUM[a][b];
        TOTALvaluesSUM_EFF_N[a][b] /= 1.0 * TOTALvaluesNUM[a][b];
      } else {
        TOTALvaluesSUM_RAD[a][b] = FLOAT_undefined;
        TOTALvaluesSUM_EFF_P[a][b] = FLOAT_undefined;
        TOTALvaluesSUM_EFF_N[a][b] = FLOAT_undefined;
      }

      float AVERAGE, PERCENTAGE, COMPARISON;

      AVERAGE = (TOTALvaluesSUM_EFF_P[a][b] - TOTALvaluesSUM_EFF_N[a][b]);
      if ((TOTALvaluesSUM_EFF_P[a][b] + TOTALvaluesSUM_EFF_N[a][b]) > 0.00001) PERCENTAGE = (TOTALvaluesSUM_EFF_P[a][b] - TOTALvaluesSUM_EFF_N[a][b]) / (1.0 * (TOTALvaluesSUM_EFF_P[a][b] + TOTALvaluesSUM_EFF_N[a][b]));
      else PERCENTAGE = 0.0;
      COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);

      if (is_defined(TOTALvaluesSUM_RAD[a][b])) {
        GlobalSolar[Impact_ACTIVE][0][a][b] = TOTALvaluesSUM_RAD[a][b];
      }
      if (is_defined(COMPARISON)) {
        GlobalSolar[Impact_PASSIVE][0][a][b] = COMPARISON;
      }

    }
  }


  keep_STUDY_perDays = STUDY.perDays;
  STUDY.joinDays = keep_STUDY_joinDays;

  cursor(ARROW);
}
