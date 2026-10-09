void postProcess_solarsUsingCloud (int desired_DataSource) {

  int keep_currentDataSource = currentDataSource;

  currentDataSource = desired_DataSource;

  int DATA_start = getStart_currentDataSource();
  int DATA_end = getEnd_currentDataSource();

  for (int k = 0; k < (1 + DATA_end - DATA_start); k++) {
    for (int j = 0; j < 365; j++) {
      for (int i = 0; i < 24; i++) {

        float CL = getValue_currentDataSource(i, j, k, LAYER_cloudcover.id);

        if (is_defined(CL)) {
          float DATE_ANGLE = (360 * ((286 + j) % 365) / 365.0);
          float HOUR_ANGLE = i;

          float[] SunR = funcs.SunPositionRadiation(DATE_ANGLE, HOUR_ANGLE, CL);

          setValue_currentDataSource(i, j, k, LAYER_dirnorrad.id, SunR[4]);

          setValue_currentDataSource(i, j, k, LAYER_difhorrad.id, SunR[5]);

          setValue_currentDataSource(i, j, k, LAYER_glohorrad.id, SunR[4] * SunR[3] + SunR[5]);
        }

      }
    }
  }

  currentDataSource = keep_currentDataSource;
}
