int[] SOLARCHVISION_PROCESS_DAILY_SCENARIOS (int start_k, int end_k, int j, float DATE_ANGLE, int Impact_TYPE) {

  int count_k = 1 + end_k - start_k;
  if (count_k < 0) count_k = 0;

  final int joinDays = STUDY.joinDays;
  final int total = count_k * joinDays;

  boolean needEFF = (Impact_TYPE == Impact_PASSIVE);

  int layerDirId = needEFF ? LAYER_direffect.id : LAYER_dirnorrad.id;
  int layerDifId = needEFF ? LAYER_difeffect.id : LAYER_difhorrad.id;
  float scaleDir = needEFF ? 0.0001 : 0.001;

  float[] valuesSUM = new float[total];
  float[] valuesNUM = new float[total]; // already 0-initialized by Processing/Java
  java.util.Arrays.fill(valuesSUM, FLOAT_undefined);

  float lat = STATION.getLatitude();
  float[] sunFactor = new float[24];
  for (int i = 0; i < 24; i++) {
    float[] SunR = funcs.SunPosition(lat, DATE_ANGLE, i);
    sunFactor[i] = SunR[3];
  }

  float baseJ = j * STUDY.perDays + TIME.beginDay + 365 - int(funcs.roundTo(0.5 * joinDays, 1));

  int[] nowJ = new int[joinDays];
  for (int j_ADD = 0; j_ADD < joinDays; j_ADD++) {
    int now_j = int(baseJ + j_ADD) % 365;
    if (now_j >= 365) now_j %= 365;
    if (now_j < 0) now_j = (now_j + 365) % 365;
    nowJ[j_ADD] = now_j;
  }

  for (int j_ADD = 0; j_ADD < joinDays; j_ADD++) {
    int now_j = nowJ[j_ADD];

    for (int i = 0; i < 24; i++) {
      float sunFac = sunFactor[i];

      for (int k = 0; k < count_k; k++) {
        int now_k = k + start_k;
        int idx = k * joinDays + j_ADD;

        float Pdir = getValue_CurrentDataSource(i, now_j, now_k, layerDirId);
        if (is_undefined(Pdir)) continue;

        float valueDir = scaleDir * Pdir;
        float valueDif = 0;

        if (!needEFF) {
          // RAD path: diffuse term is 0.001 * Pdif.
          float Pdif = getValue_CurrentDataSource(i, now_j, now_k, layerDifId);
          if (is_undefined(Pdif)) continue;
          valueDif = 0.001 * Pdif;
        }
        // EFF path: the original always forced values_E_dif = 0 and never
        // used Pd, so the diffuse-effect layer is never fetched at all here.

        int memberCount = SOLARCHVISION_filter(CurrentDataSource, LAYER_cloudcover.id, STUDY.filter, STUDY.skyScenario, i, now_j, now_k);
        if (memberCount != 1) continue;

        if (is_undefined(valuesSUM[idx])) {
          valuesSUM[idx] = 0;
        }
        valuesSUM[idx] += (valueDir * sunFac) + valueDif; // total horizontal radiation or direct effect
        valuesNUM[idx] += 1;
      }
    }
  }

  return SOLARCHVISION_FIND_SCENARIOS_CLOSE_TO_NORMALS(valuesSUM);
}
