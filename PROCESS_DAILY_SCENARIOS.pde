int[] SOLARCHVISION_PROCESS_DAILY_SCENARIOS (int start_k, int end_k, int j, float DATE_ANGLE, int Impact_TYPE) {

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

  float[] valuesSUM_RAD;
  float[] valuesSUM_EFF;
  float[] valuesNUM;
  valuesSUM_RAD = new float [(count_k * STUDY.joinDays)];
  valuesSUM_EFF = new float [(count_k * STUDY.joinDays)];
  valuesNUM = new float [(count_k * STUDY.joinDays)];

  for (int j_ADD = 0; j_ADD < STUDY.joinDays; j_ADD++) {
    for (int k = 0; k < count_k; k++) {
      valuesSUM_RAD[(k * STUDY.joinDays + j_ADD)] = FLOAT_undefined;
      valuesSUM_EFF[(k * STUDY.joinDays + j_ADD)] = FLOAT_undefined;
      valuesNUM[(k * STUDY.joinDays + j_ADD)] = 0;
    }
  }

  for (int j_ADD = 0; j_ADD < STUDY.joinDays; j_ADD++) {

    for (int k = 0; k < count_k; k++) {

      for (int i = 0; i < 24; i++) {

        float HOUR_ANGLE = i;
        float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);

        int now_k = k + start_k;
        int now_i = i;
        int now_j = int(j * STUDY.perDays + (j_ADD - int(funcs.roundTo(0.5 * STUDY.joinDays, 1))) + TIME.beginDay + 365) % 365;

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
        } else {

          int memberCount = SOLARCHVISION_filter(CurrentDataSource, LAYER_cloudcover.id, STUDY.filter, STUDY.skyScenario, now_i, now_j, now_k);

          if (memberCount == 1) {
            values_R_dir = 0.001 * Pa;
            values_R_dif = 0.001 * Pb;
            values_E_dir = 0.0001 * Pc;
            values_E_dif = 0; //0.0001 * Pd;

            if (is_undefined(valuesSUM_RAD[(k * STUDY.joinDays + j_ADD)])) {
              valuesSUM_RAD[(k * STUDY.joinDays + j_ADD)] = 0;
              valuesSUM_EFF[(k * STUDY.joinDays + j_ADD)] = 0;
              valuesNUM[(k * STUDY.joinDays + j_ADD)] = 0;
            }

            valuesSUM_RAD[(k * STUDY.joinDays + j_ADD)] += ((values_R_dir * SunR[3]) + (values_R_dif)); // calculates total horizontal radiation
            valuesSUM_EFF[(k * STUDY.joinDays + j_ADD)] += ((values_E_dir * SunR[3]) + (values_E_dif)); // calculates total horizontal effects
            valuesNUM[(k * STUDY.joinDays + j_ADD)] += 1;
          }
        }
      }
    }
  }

  if (Impact_TYPE == Impact_PASSIVE)
    return SOLARCHVISION_FIND_SCENARIOS_CLOSE_TO_NORMALS(valuesSUM_EFF);
  else
    return SOLARCHVISION_FIND_SCENARIOS_CLOSE_TO_NORMALS(valuesSUM_RAD);
}
