void postProcess_climaticSolarForecast () {

  int num_count = (1 + climateEngineeringEnd - climateEngineeringStart);

  for (int k = 0; k < (1 + ensembleForecastEnd - ensembleForecastStart); k++) {
    for (int j_for = 0; j_for < ensembleForecastMaxDays; j_for++) {
      int j = ((j_for + TIME.beginDay) % 365);
      for (int i = 0; i < 24; i++) {
        if (is_undefined(ensembleForecastValues[i][j][LAYER_cloudcover.id][k])) {
        } else {
          float DATE_ANGLE = (360 * ((286 + j) % 365) / 365.0);
          float HOUR_ANGLE = i;

          float[] SunR = funcs.SunPositionRadiation(DATE_ANGLE, HOUR_ANGLE, ensembleForecastValues[i][j][LAYER_cloudcover.id][k]);

          ensembleForecastValues[i][j][LAYER_dirnorrad.id][k] = SunR[4];

          ensembleForecastValues[i][j][LAYER_difhorrad.id][k] = SunR[5];

          ensembleForecastValues[i][j][LAYER_glohorrad.id][k] = SunR[4] * SunR[3] + SunR[5];

          //---------------------------------------------------------------------

          float Forecast_CC = ensembleForecastValues[i][j][LAYER_cloudcover.id][k];
          float Forecast_AP = ensembleForecastValues[i][j][LAYER_pressure.id][k];

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


              if ((is_undefined(climateEngineeringValues[now_i][now_j][LAYER_cloudcover.id][q])) ||
                 (is_undefined(climateEngineeringValues[now_i][now_j][LAYER_pressure.id][q]))) {
              } else {
                float CC_dist = abs(Forecast_CC - climateEngineeringValues[now_i][now_j][LAYER_cloudcover.id][q]);
                float AP_dist = abs(Forecast_AP - climateEngineeringValues[now_i][now_j][LAYER_pressure.id][q]);
                if ((CC_dist < CC_epsilon) && (AP_dist < AP_epsilon)) {

                  float _weight;

                  _weight = 1;
                  _weight *= pow(abs(1 - pow(CC_dist/CC_epsilon, 2)), 2); // to add more wights to closer cases
                  _weight *= pow(abs(1 - pow(AP_dist/AP_epsilon, 2)), 2);

                  sum_count += _weight;

                  if (is_undefined(climateEngineeringValues[now_i][now_j][LAYER_dirnorrad.id][q])) {
                  } else valuesSUM_DIR += _weight * climateEngineeringValues[now_i][now_j][LAYER_dirnorrad.id][q];
                  if (is_undefined(climateEngineeringValues[now_i][now_j][LAYER_difhorrad.id][q])) {
                  } else valuesSUM_DIF += _weight * climateEngineeringValues[now_i][now_j][LAYER_difhorrad.id][q];
                  if (is_undefined(climateEngineeringValues[now_i][now_j][LAYER_glohorrad.id][q])) {
                  } else valuesSUM_GLO += _weight * climateEngineeringValues[now_i][now_j][LAYER_glohorrad.id][q];
                }
              }
            }
          }

          if (sum_count != 0) {
            valuesSUM_DIR /= sum_count;
            valuesSUM_DIF /= sum_count;
            valuesSUM_GLO /= sum_count;

            ensembleForecastValues[i][j][LAYER_dirnorrad.id][k] = valuesSUM_DIR;
            ensembleForecastValues[i][j][LAYER_difhorrad.id][k] = valuesSUM_DIF;
            ensembleForecastValues[i][j][LAYER_glohorrad.id][k] = valuesSUM_GLO;
          } else {
            println("Cannot find simillar conditions in climate file at i:", i, ", j:", j, ", k:", k);
          }

        }
      }
    }
  }
}
