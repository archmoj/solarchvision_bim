void SOLARCHVISION_postProcess_solarsUsingCloud (int desired_DataSource) {

  int keep_CurrentDataSource = CurrentDataSource;

  CurrentDataSource = desired_DataSource;

  int DATA_start = getStart_CurrentDataSource();
  int DATA_end = getEnd_CurrentDataSource();

  for (int k = 0; k < (1 + DATA_end - DATA_start); k++) {
    for (int j = 0; j < 365; j++) {
      for (int i = 0; i < 24; i++) {

        float CL = getValue_CurrentDataSource(i, j, k, LAYER_cloudcover.id);

        if (is_defined(CL)) {
          float DATE_ANGLE = (360 * ((286 + j) % 365) / 365.0);
          float HOUR_ANGLE = i;

          float[] SunR = funcs.SunPositionRadiation(DATE_ANGLE, HOUR_ANGLE, CL);

          setValue_CurrentDataSource(i, j, k, LAYER_dirnorrad.id, SunR[4]);

          setValue_CurrentDataSource(i, j, k, LAYER_difhorrad.id, SunR[5]);

          setValue_CurrentDataSource(i, j, k, LAYER_glohorrad.id, SunR[4] * SunR[3] + SunR[5]);
        }

      }
    }
  }

  CurrentDataSource = keep_CurrentDataSource;
}
