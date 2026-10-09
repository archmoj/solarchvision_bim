void postProcess_solarEffects (int desired_DataSource) {

  int keep_currentDataSource = currentDataSource;

  currentDataSource = desired_DataSource;

  int DATA_start = getStart_currentDataSource();
  int DATA_end = getEnd_currentDataSource();


  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int k = 0; k < (1 + DATA_end - DATA_start); k++) {

        float T     = getValue_currentDataSource(i, j, k, LAYER_drybulb.id);
        float R_dir = getValue_currentDataSource(i, j, k, LAYER_dirnorrad.id);
        float R_dif = getValue_currentDataSource(i, j, k, LAYER_difhorrad.id);

        if (is_defined(T) && is_defined(R_dir) && is_defined(R_dif)) {

          setValue_currentDataSource(i, j, k, LAYER_direffect.id, (18 - T) * R_dir);
          setValue_currentDataSource(i, j, k, LAYER_difeffect.id, (18 - T) * R_dif);

        }
      }
    }
  }

  currentDataSource = keep_currentDataSource;
}
