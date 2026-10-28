void calculate_GlobalSolar_array () {

  showWaitCursor();

  if (GlobalSolar_rebuild_array) {
    GlobalSolar_resize_array();
  }

  float keep_STUDY_dayIncrement = STUDY.dayIncrement;
  int keep_STUDY_daysMergedCount = STUDY.daysMergedCount;
  if ((currentDataSource == dataID_ensembleForecast) ||
      (currentDataSource == dataID_ensembleObservation)) {
    STUDY.dayIncrement = 1;
    STUDY.daysMergedCount = 1;
  }

  int[] startK_endK = get_startK_endK();
  int start_k = startK_endK[0];
  int end_k = startK_endK[1];
  int count_k = 1 + end_k - start_k;
  if (count_k < 0) count_k = 0;

  float values_R_dir;
  float values_R_dif;
  float values_E_dir;
  float values_E_dif;

  int now_i = 0;
  int now_j = 0;

  int l = STUDY.impactLayerIndex;

  int a_max = int(180 / Sky3D.inclinationStep);
  int b_max = int(360 / Sky3D.orientationStep);

  float[][] TOTALvaluesSUM_RAD = new float [1 + a_max][1 + b_max];
  float[][] TOTALvaluesSUM_EFF_P = new float [1 + a_max][1 + b_max];
  float[][] TOTALvaluesSUM_EFF_N = new float [1 + a_max][1 + b_max];
  int[][] TOTALvaluesNUM = new int [1 + a_max][1 + b_max];

  for (int a = 0; a <= a_max; a++) {
    java.util.Arrays.fill(TOTALvaluesSUM_RAD[a],   FLOAT_undefined);
    java.util.Arrays.fill(TOTALvaluesSUM_EFF_P[a], FLOAT_undefined);
    java.util.Arrays.fill(TOTALvaluesSUM_EFF_N[a], FLOAT_undefined);
    java.util.Arrays.fill(TOTALvaluesNUM[a],       0);
  }

  boolean[] hourValid = new boolean [24];
  float[] cache_SunR1 = new float [24];
  float[] cache_SunR2 = new float [24];
  float[] cache_SunR3 = new float [24];
  float[] cache_R_dir = new float [24];
  float[] cache_R_dif = new float [24];
  float[] cache_E_dir = new float [24];
  float[] cache_E_dif = new float [24];

  for (int j = STUDY.startDay; j < STUDY.endDay; j++) {

    now_j = (j * int(STUDY.dayIncrement) + TIME.beginDay + 365) % 365;

    if (now_j >= 365) {
      now_j = now_j % 365;
    }
    if (now_j < 0) {
      now_j = (now_j + 365) % 365;
    }

    float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);

    int[] allNk = FIND_SCENARIOS_CLOSE_TO_DAILY_STAT(SCENARIO_SAMPLE_COUNT, l, start_k, end_k, j, DATE_ANGLE, WIN3D.impactTypeIndex);
    if (allNk.length == 0) continue;

    // One (now_k, now_j) pair per sampled scenario - averagedScenarioHourlyValues()
    // below reads and averages across these instead of a single scenario's
    // own (possibly noisy/extreme) hourly values.
    int[] sampleNowK = new int[allNk.length];
    int[] sampleNowJ = new int[allNk.length];
    for (int s = 0; s < allNk.length; s++) {
      int sample_k = int(allNk[s] / STUDY.daysMergedCount);
      int sample_j_ADD = allNk[s] % STUDY.daysMergedCount;
      sampleNowK[s] = sample_k + start_k;

      int sample_now_j = int(j * STUDY.dayIncrement + (sample_j_ADD - int(funcs.roundTo(0.5 * STUDY.daysMergedCount, 1))) + TIME.beginDay + 365) % 365;
      if (sample_now_j >= 365) sample_now_j = sample_now_j % 365;
      if (sample_now_j < 0) sample_now_j = (sample_now_j + 365) % 365;
      sampleNowJ[s] = sample_now_j;
    }

    for (int i = 0; i < 24; i++) {
      hourValid[i] = false;

      if (STUDY.isInHourlyRange(i)) {

        float HOUR_ANGLE = i;
        float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);

        if (SunR[3] > 0) {

          now_i = i;

          float[] avg = averagedScenarioHourlyValues(now_i, sampleNowK, sampleNowJ, l);

          if (avg == null) {
            values_R_dir = FLOAT_undefined;
            values_R_dif = FLOAT_undefined;
            values_E_dir = FLOAT_undefined;
            values_E_dif = FLOAT_undefined;
          } else {

            values_R_dir = avg[0];
            values_R_dif = avg[1];
            values_E_dir = avg[2];
            values_E_dif = avg[3];

            hourValid[i] = true;
            cache_SunR1[i] = SunR[1];
            cache_SunR2[i] = SunR[2];
            cache_SunR3[i] = SunR[3];
            cache_R_dir[i] = values_R_dir;
            cache_R_dif[i] = values_R_dif;
            cache_E_dir[i] = values_E_dir;
            cache_E_dif[i] = values_E_dif;
          }
        }
      }
    }

    for (int a = 0; a <= a_max; a++) {
      float Alpha = a * Sky3D.inclinationStep - 90;
      for (int b = 0; b < b_max; b++) {
        float Beta = b * Sky3D.orientationStep;

        float valuesSUM_RAD = 0;
        float valuesSUM_EFF_P = 0;
        float valuesSUM_EFF_N = 0;
        int valuesNUM = 0;

        for (int i = 0; i < 24; i++) {
          if (hourValid[i]) {

            if (is_undefined(valuesSUM_RAD)) {
              valuesSUM_RAD = 0;
              valuesSUM_EFF_P = 0;
              valuesSUM_EFF_N = 0;
              valuesNUM = 0;
            } else {

              if (cache_E_dir[i] < 0) {
                valuesSUM_EFF_N += -SolarAtSurface(cache_SunR1[i], cache_SunR2[i], cache_SunR3[i], cache_E_dir[i], cache_E_dif[i], Alpha, Beta, globalAlbedo);
              } else {
                valuesSUM_EFF_P += SolarAtSurface(cache_SunR1[i], cache_SunR2[i], cache_SunR3[i], cache_E_dir[i], cache_E_dif[i], Alpha, Beta, globalAlbedo);
              }

              valuesSUM_RAD += SolarAtSurface(cache_SunR1[i], cache_SunR2[i], cache_SunR3[i], cache_R_dir[i], cache_R_dif[i], Alpha, Beta, globalAlbedo);

              valuesNUM += 1;
            }
          }
        }


        if (valuesNUM != 0) {
          //float valuesMUL = funcs.DayTime(STATION.getLatitude(), DATE_ANGLE) / (1.0 * valuesNUM);
          //float valuesMUL = int(funcs.DayTime(STATION.getLatitude(), DATE_ANGLE)) / (1.0 * valuesNUM);
          float valuesMUL = funcs.roundTo(STUDY.effectiveDayTime(STATION.getLatitude(), DATE_ANGLE), 1) / (1.0 * valuesNUM);

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



  for (int a = 0; a <= a_max; a++) {
    float Alpha = a * Sky3D.inclinationStep - 90;
    for (int b = 0; b < b_max; b++) {
      float Beta = b * Sky3D.orientationStep;

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


  STUDY.dayIncrement = keep_STUDY_dayIncrement;
  STUDY.daysMergedCount = keep_STUDY_daysMergedCount;

  // Global-solar shading colors just changed without going through
  // model_changed() - invalidate the WIN3D retained-mode face cache so the
  // next WIN3D.draw() rebuilds it instead of reusing stale colors.
  if (allFaces != null) {
    // Same reasoning as calculate_VertexSolar_array.pde's own identical
    // block - see that one's comment. This bump is a "repaint stale face
    // colors" signal, not a structural/material edit, and allSolarImpacts.
    // Image[][] (the WIN3D solar-impact overlay) never reads GlobalSolar
    // data, so it shouldn't be marked stale by it either.
    if (allSolarImpacts.win3DOverlay_facesGeneration == allFaces.winCacheGeneration) {
      allSolarImpacts.win3DOverlay_facesGeneration++;
    }
    allFaces.winCacheGeneration++;
  }
  if (Sky3D != null) Sky3D.winCacheGeneration++;

  showArrowCursor();
}
