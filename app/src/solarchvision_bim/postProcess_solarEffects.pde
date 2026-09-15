void SOLARCHVISION_postProcess_solarEffects (int desired_DataSource) {

  int keep_CurrentDataSource = CurrentDataSource;

  CurrentDataSource = desired_DataSource;

  int DATA_start = getStart_CurrentDataSource();
  int DATA_end = getEnd_CurrentDataSource();


  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int k = 0; k < (1 + DATA_end - DATA_start); k++) {

        float T     = getValue_CurrentDataSource(i, j, k, LAYER_drybulb.id);
        float R_dir = getValue_CurrentDataSource(i, j, k, LAYER_dirnorrad.id);
        float R_dif = getValue_CurrentDataSource(i, j, k, LAYER_difhorrad.id);

        if (is_defined(T) && is_defined(R_dir) && is_defined(R_dif)) {

          setValue_CurrentDataSource(i, j, k, LAYER_direffect.id, (18 - T) * R_dir);
          setValue_CurrentDataSource(i, j, k, LAYER_difeffect.id, (18 - T) * R_dif);

        }
      }
    }
  }

  CurrentDataSource = keep_CurrentDataSource;
}
