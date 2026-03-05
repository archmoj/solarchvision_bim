void SOLARCHVISION_postProcess_climaticSolarForecast () {

  int num_count = (1 + CLIMATE_CWEEDS_end - CLIMATE_CWEEDS_start);

  for (int k = 0; k < (1 + ENSEMBLE_FORECAST_end - ENSEMBLE_FORECAST_start); k++) {
    for (int j_for = 0; j_for < ENSEMBLE_FORECAST_maxDays; j_for++) {
      int j = ((j_for + TIME.beginDay) % 365);
      for (int i = 0; i < 24; i++) {
        if (is_undefined(ENSEMBLE_FORECAST_values[i][j][LAYER_cloudcover.id][k])) {
        } else {
          float DATE_ANGLE = (360 * ((286 + j) % 365) / 365.0);
          float HOUR_ANGLE = i;

          float[] SunR = funcs.SunPositionRadiation(DATE_ANGLE, HOUR_ANGLE, ENSEMBLE_FORECAST_values[i][j][LAYER_cloudcover.id][k]);

          ENSEMBLE_FORECAST_values[i][j][LAYER_dirnorrad.id][k] = SunR[4];

          ENSEMBLE_FORECAST_values[i][j][LAYER_difhorrad.id][k] = SunR[5];

          ENSEMBLE_FORECAST_values[i][j][LAYER_glohorrad.id][k] = SunR[4] * SunR[3] + SunR[5];

          //---------------------------------------------------------------------

          float Forecast_CC = ENSEMBLE_FORECAST_values[i][j][LAYER_cloudcover.id][k];
          float Forecast_AP = ENSEMBLE_FORECAST_values[i][j][LAYER_pressure.id][k];

          float CC_epsilon = 1.0; // defines a range for finding near previous results: 1.0 results in e.g. 2 < CC < 4 for CC at 3
          float AP_epsilon = 50.0;

          float valuesSUM_DIR = 0;
          float valuesSUM_DIF = 0;
          float valuesSUM_GLO = 0;
          float sum_count = 0;

          float process_add_days = 11;

          for (int q = 0; q < num_count; q++) {

            for (int j_ADD = 0; j_ADD < process_add_days; j_ADD++) {

              int now_i = i;
              int now_j = int(j + (j_ADD - int(0.5 * process_add_days)) + 365) % 365;

              if (now_j >= 365) {
                now_j = now_j % 365;
              }
              if (now_j < 0) {
                now_j = (now_j + 365) % 365;
              }


              if ((is_undefined(CLIMATE_CWEEDS_values[now_i][now_j][LAYER_cloudcover.id][q])) ||
                 (is_undefined(CLIMATE_CWEEDS_values[now_i][now_j][LAYER_pressure.id][q]))) {
              } else {
                float CC_dist = abs(Forecast_CC - CLIMATE_CWEEDS_values[now_i][now_j][LAYER_cloudcover.id][q]);
                float AP_dist = abs(Forecast_AP - CLIMATE_CWEEDS_values[now_i][now_j][LAYER_pressure.id][q]);
                if ((CC_dist < CC_epsilon) && (AP_dist < AP_epsilon)) {

                  float _weight;

                  _weight = 1;
                  _weight *= pow(abs(1 - pow(CC_dist/CC_epsilon, 2)), 2); // to add more wights to closer cases
                  _weight *= pow(abs(1 - pow(AP_dist/AP_epsilon, 2)), 2);

                  sum_count += _weight;

                  if (is_undefined(CLIMATE_CWEEDS_values[now_i][now_j][LAYER_dirnorrad.id][q])) {
                  } else valuesSUM_DIR += _weight * CLIMATE_CWEEDS_values[now_i][now_j][LAYER_dirnorrad.id][q];
                  if (is_undefined(CLIMATE_CWEEDS_values[now_i][now_j][LAYER_difhorrad.id][q])) {
                  } else valuesSUM_DIF += _weight * CLIMATE_CWEEDS_values[now_i][now_j][LAYER_difhorrad.id][q];
                  if (is_undefined(CLIMATE_CWEEDS_values[now_i][now_j][LAYER_glohorrad.id][q])) {
                  } else valuesSUM_GLO += _weight * CLIMATE_CWEEDS_values[now_i][now_j][LAYER_glohorrad.id][q];
                }
              }
            }
          }

          if (sum_count != 0) {
            valuesSUM_DIR /= sum_count;
            valuesSUM_DIF /= sum_count;
            valuesSUM_GLO /= sum_count;

            ENSEMBLE_FORECAST_values[i][j][LAYER_dirnorrad.id][k] = valuesSUM_DIR;
            ENSEMBLE_FORECAST_values[i][j][LAYER_difhorrad.id][k] = valuesSUM_DIF;
            ENSEMBLE_FORECAST_values[i][j][LAYER_glohorrad.id][k] = valuesSUM_GLO;
          } else {
            println("Cannot find simillar conditions in climate file at i:", i, ", j:", j, ", k:", k);
          }

        }
      }
    }
  }
}
