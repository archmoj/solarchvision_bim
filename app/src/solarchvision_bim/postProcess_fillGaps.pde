void SOLARCHVISION_postProcess_fillGaps (int desired_DataSource) {

  int keep_CurrentDataSource = CurrentDataSource;

  CurrentDataSource = desired_DataSource;

  int DATA_start = getStart_CurrentDataSource();
  int DATA_end = getEnd_CurrentDataSource();

  int MAX_SEARCH = 6; // It defines how many hours the program should seek for each point to find next available data.

  for (int l = 0; l < numberOfLayers; l++) {

    for (int k = 0; k < (1 + DATA_end - DATA_start); k++) {
      float pre_v = FLOAT_undefined;
      int pre_num = 0;

      for (int j = 0; j < 365; j++) {

        for (int i = 0; i < 24; i++) {

          if (is_undefined(getValue_CurrentDataSource(i, j, k, l))) {
            if (is_defined(pre_v)) {
              pre_num += 1;

              float next_v = FLOAT_undefined;
              int next_i = i;
              int next_j = j;
              int next_num = 0;
              while ((next_num < MAX_SEARCH) && (is_undefined(next_v))) {
                next_num += 1;
                next_i += 1;
                if (next_i == 24) {
                  next_i -= 24;
                  next_j += 1;
                }
                if (next_j == 365) {
                  next_j = 0;
                }
                if (is_defined(getValue_CurrentDataSource(next_i, next_j, k, l))) {
                  next_v = getValue_CurrentDataSource(next_i, next_j, k, l);

                  if (l == LAYER_winddir.id) {
                    if ((next_v - pre_v) > 180) next_v -= 360;
                    if ((next_v - pre_v) < -180) next_v += 360;
                  }
                }
              }
              if (next_num < MAX_SEARCH) {
                if (l == LAYER_winddir.id) setValue_CurrentDataSource(i, j, k, l, ((next_num * pre_v + pre_num * next_v) / (pre_num + next_num) + 360) % 360);
                else setValue_CurrentDataSource(i, j, k, l, (next_num * pre_v + pre_num * next_v) / (pre_num + next_num));

                float interpolation_pow = pow(2.0, Interpolation_Weight);

                setValue_CurrentDataSource(i, j, k, l, (pow(next_num, interpolation_pow) * pre_v + pow(pre_num, interpolation_pow) * next_v) / (pow(next_num, interpolation_pow) + pow(pre_num, interpolation_pow)));
                if (l == LAYER_winddir.id) setValue_CurrentDataSource(i, j, k, l, (getValue_CurrentDataSource(i, j, k, l) + 360) % 360);
              }
            }
          } else {
            pre_v = getValue_CurrentDataSource(i, j, k, l);
            pre_num = 0;
          }

        }
      }

    }
  }

  CurrentDataSource = keep_CurrentDataSource;
}
