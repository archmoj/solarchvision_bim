void SOLARCHVISION_calculate_VertexSolar_array () {

  cursor(WAIT);

  println("Calculating direct and diffuse values at each vertex. Please wait...");

  SOLARCHVISION_buildFaceGrid();

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

  int l = STUDY.ImpactLayer;
  int DATE_step = 1;
  int J_START = STUDY.j_Start;
  int J_END = STUDY.j_End;
  int numDays = J_END - J_START;
  if (numDays < 0) numDays = 0;

  boolean[] TS_dayHasData = new boolean [max(numDays, 1)];
  float[] TS_DayTime = new float [max(numDays, 1)];

  boolean[][] TS_valid = new boolean [max(numDays, 1)][24];
  float[][][] TS_SunDir = new float [max(numDays, 1)][24][3];      // raw {SunR[1],SunR[2],SunR[3]}
  float[][][] TS_SunDirUnit = new float [max(numDays, 1)][24][3];  // unit version, used for SunMask
  float[][] TS_R_dir = new float [max(numDays, 1)][24];
  float[][] TS_R_dif = new float [max(numDays, 1)][24];
  float[][] TS_E_dir = new float [max(numDays, 1)][24];
  float[][] TS_E_dif = new float [max(numDays, 1)][24];

  for (int j = J_START; j < J_END; j += DATE_step) {
    int jIdx = j - J_START;

    int day_now_j = (j * int(STUDY.perDays) + TIME.beginDay + 365) % 365;
    if (day_now_j >= 365) day_now_j = day_now_j % 365;
    if (day_now_j < 0) day_now_j = (day_now_j + 365) % 365;

    float DATE_ANGLE = (360 * ((286 + day_now_j) % 365) / 365.0);
    TS_DayTime[jIdx] = funcs.roundTo(funcs.DayTime(STATION.getLatitude(), DATE_ANGLE), 1);

    int[] Normals_COL_N = SOLARCHVISION_PROCESS_DAILY_SCENARIOS(start_k, end_k, j, DATE_ANGLE, WIN3D.Impact_TYPE);
    int nk = Normals_COL_N[l];

    if (nk == -1) continue;

    TS_dayHasData[jIdx] = true;
    int k = int(nk / STUDY.joinDays);
    int j_ADD = nk % STUDY.joinDays;
    int now_k = k + start_k;

    int now_j = int(j * STUDY.perDays + (j_ADD - int(funcs.roundTo(0.5 * STUDY.joinDays, 1))) + TIME.beginDay + 365) % 365;
    if (now_j >= 365) now_j = now_j % 365;
    if (now_j < 0) now_j = (now_j + 365) % 365;

    for (int i = 0; i < 24; i++) {

      if (!STUDY.isInHourlyRange(i)) continue;

      float HOUR_ANGLE = i;
      float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);
      if (SunR[3] <= 0) continue;

      float Pa = getValue_CurrentDataSource(i, now_j, now_k, LAYER_dirnorrad.id);
      float Pb = getValue_CurrentDataSource(i, now_j, now_k, LAYER_difhorrad.id);
      float Pc = getValue_CurrentDataSource(i, now_j, now_k, LAYER_direffect.id);
      float Pd = getValue_CurrentDataSource(i, now_j, now_k, LAYER_difeffect.id);

      if (is_undefined(Pa) || is_undefined(Pb) || is_undefined(Pc) || is_undefined(Pd)) continue;

      int memberCount = SOLARCHVISION_filter(CurrentDataSource, LAYER_cloudcover.id, STUDY.filter, STUDY.skyScenario, i, now_j, now_k);
      if (memberCount != 1) continue;

      float[] SunDir = { SunR[1], SunR[2], SunR[3] };
      TS_SunDir[jIdx][i] = SunDir;
      TS_SunDirUnit[jIdx][i] = funcs.vec3_unit(SunDir);

      TS_R_dir[jIdx][i] = 0.001 * Pa;
      TS_R_dif[jIdx][i] = 0.001 * Pb;
      TS_E_dir[jIdx][i] = 0.001 * Pc;
      TS_E_dif[jIdx][i] = 0.001 * Pd;

      TS_valid[jIdx][i] = true;
    }
  }

  int numDaySlots = VertexSolar_amounts[Impact_ACTIVE].length;
  FloatList[] activeDayValues = new FloatList [numDaySlots];
  FloatList[] passiveDayValues = new FloatList [numDaySlots];
  for (int idx = 0; idx < numDaySlots; idx++) {
    activeDayValues[idx] = new FloatList();
    passiveDayValues[idx] = new FloatList();
  }
  ArrayList<float[]> vertexXYZ_list = new ArrayList<float[]>();

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

          int s_next = (s + 1) % subFace.length;
          int s_prev = (s + subFace.length - 1) % subFace.length;

          int q = SHADE.findID_SolarImpact_atXYZ(
            subFace[s][0], subFace[s][1], subFace[s][2],
            subFace[s_prev][0], subFace[s_prev][1], subFace[s_prev][2],
            subFace[s_next][0], subFace[s_next][1], subFace[s_next][2]
          );

          if (q < 0) { // this will compute and add new points to the list only if there are not computed before.
            PVector U = new PVector(subFace[s_next][0] - subFace[s][0], subFace[s_next][1] - subFace[s][1], subFace[s_next][2] - subFace[s][2]);
            PVector V = new PVector(subFace[s_prev][0] - subFace[s][0], subFace[s_prev][1] - subFace[s][1], subFace[s_prev][2] - subFace[s][2]);
            PVector UV = U.cross(V);
            float[] W = {
              UV.x, UV.y, UV.z
            };

            float[] VECT = funcs.vec3_unit(W); // already a unit vector -- do not re-normalize it below

            float SkyMask = 0;

            for (int i = 0; i < DiffuseVectors.length; i++) {
              float[] SkyV = {
                DiffuseVectors[i][0], DiffuseVectors[i][1], DiffuseVectors[i][2]
              };

              float tmp = funcs.vec_dot(funcs.vec3_unit(SkyV), VECT);
              if (tmp <= 0) tmp = 0; // removes backing faces

              SkyMask += tmp / float(DiffuseVectors.length);
            }

            float TOTALvaluesSUM_RAD = FLOAT_undefined;
            float TOTALvaluesSUM_EFF_P = FLOAT_undefined;
            float TOTALvaluesSUM_EFF_N = FLOAT_undefined;
            int TOTALvaluesNUM = 0;

            for (int j = J_START; j < J_END; j += DATE_step) {
              int jIdx = j - J_START;

              float valuesSUM_RAD = FLOAT_undefined;
              float valuesSUM_EFF_P = FLOAT_undefined;
              float valuesSUM_EFF_N = FLOAT_undefined;
              int valuesNUM = 0;

              if (TS_dayHasData[jIdx]) {
                for (int i = 0; i < 24; i++) {

                  if (!TS_valid[jIdx][i]) continue;

                  float values_R_dir = TS_R_dir[jIdx][i];
                  float values_R_dif = TS_R_dif[jIdx][i];
                  float values_E_dir = TS_E_dir[jIdx][i];
                  float values_E_dif = TS_E_dif[jIdx][i];

                  if (is_undefined(valuesSUM_RAD)) {
                    valuesSUM_RAD = 0;
                    valuesSUM_EFF_P = 0;
                    valuesSUM_EFF_N = 0;
                    valuesNUM = 0;
                  } else {

                    float SunMask = funcs.vec_dot(TS_SunDirUnit[jIdx][i], VECT);
                    if (SunMask <= 0) SunMask = 0; // removes backing faces

                    float[] ray_start = subFace[s];
                    float[] ray_direction = TS_SunDir[jIdx][i];

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

              if (valuesNUM != 0) {
                float valuesMUL = TS_DayTime[jIdx] / (1.0 * valuesNUM);

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

              activeDayValues[j + 1].append(valuesSUM_RAD);
              passiveDayValues[j + 1].append(COMPARISON);

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

            float TOTAL_AVERAGE, TOTAL_PERCENTAGE, TOTAL_COMPARISON;

            TOTAL_AVERAGE = (TOTALvaluesSUM_EFF_P - TOTALvaluesSUM_EFF_N);
            if ((TOTALvaluesSUM_EFF_P + TOTALvaluesSUM_EFF_N) > 0.00001) TOTAL_PERCENTAGE = (TOTALvaluesSUM_EFF_P - TOTALvaluesSUM_EFF_N) / (1.0 * (TOTALvaluesSUM_EFF_P + TOTALvaluesSUM_EFF_N));
            else TOTAL_PERCENTAGE = 0.0;
            TOTAL_COMPARISON = ((abs(TOTAL_PERCENTAGE)) * TOTAL_AVERAGE);

            float valuesSUM = FLOAT_undefined;
            if (WIN3D.Impact_TYPE == Impact_ACTIVE) valuesSUM = TOTALvaluesSUM_RAD;
            if (WIN3D.Impact_TYPE == Impact_PASSIVE) valuesSUM = TOTAL_COMPARISON;

            activeDayValues[0].append(TOTALvaluesSUM_RAD);
            passiveDayValues[0].append(TOTAL_COMPARISON);

            vertexXYZ_list.add(new float[] {
              subFace[s][0], subFace[s][1], subFace[s][2],
              subFace[s_prev][0], subFace[s_prev][1], subFace[s_prev][2],
              subFace[s_next][0], subFace[s_next][1], subFace[s_next][2]
            });

          }

        }

      }
    }
  }

  for (int idx = 0; idx < numDaySlots; idx++) {
    VertexSolar_amounts[Impact_ACTIVE][idx] = activeDayValues[idx].array();
    VertexSolar_amounts[Impact_PASSIVE][idx] = passiveDayValues[idx].array();
  }

  VertexSolar_XYZ = new float [vertexXYZ_list.size()][9];
  for (int idx = 0; idx < vertexXYZ_list.size(); idx++) {
    VertexSolar_XYZ[idx] = vertexXYZ_list.get(idx);
  }

  for(int c = 0; c < floor(100 - printed_Progress); c++) {
    print("█");
  }

  println();

  cursor(ARROW);
}
