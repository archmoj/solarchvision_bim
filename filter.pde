int SOLARCHVISION_filter (int dataID, int cloudCover_id, int type_of_filter, int scenario_of_sky, int now_i, int now_j, int now_k) {

  float total_sky = 0;
  int num_sky = 0;

  int start_q = now_i;
  int end_q = now_i;

  if (type_of_filter == filter_DAILY) {
    start_q = 0;
    end_q = 23;
  }

  for (int q = start_q; q <= end_q; q++) {
    float _sky = FLOAT_undefined;
    if (dataID == dataID_ENSEMBLE_OBSERVED)      _sky = ENSEMBLE_OBSERVED_values[q][now_j][cloudCover_id][now_k];
    else if (dataID == dataID_ENSEMBLE_FORECAST) _sky = ENSEMBLE_FORECAST_values[q][now_j][cloudCover_id][now_k];
    else if (dataID == dataID_CLIMATE_CWEEDS)    _sky = CLIMATE_CWEEDS_values   [q][now_j][cloudCover_id][now_k];
    else if (dataID == dataID_CLIMATE_CLMREC)    _sky = CLIMATE_CLMREC_values   [q][now_j][cloudCover_id][now_k];
    else if (dataID == dataID_CLIMATE_TMYEPW)    _sky = CLIMATE_TMYEPW_values   [q][now_j][cloudCover_id][now_k];
    else {
      println("ERROR: This dataID is not declared:", dataID);
    }

    if (is_undefined(_sky)) {
    } else {
      total_sky += _sky;
      num_sky += 1;
    }
  }


  int _return = 0;

  if (num_sky != 0) {
    total_sky /= num_sky;

    if (scenario_of_sky == 1) _return = 1;
    else if ((scenario_of_sky == 4) && (total_sky <= 3.33)) _return = 1;
    else if ((scenario_of_sky == 3) && (total_sky > 3.33) && (total_sky <= 6.66)) _return = 1;
    else if ((scenario_of_sky == 2) && (total_sky > 6.66)) _return = 1;
  }

  return _return;
}
