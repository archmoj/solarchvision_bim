boolean filter (int dataID, int cloudCover_id, int type_of_filter, int scenario_of_sky, int now_i, int now_j, int now_k) {

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
    if (dataID == dataID_ensembleObservation)      _sky = ensembleObservationValues[q][now_j][cloudCover_id][now_k];
    else if (dataID == dataID_ensembleForecast) _sky = ensembleForecastValues[q][now_j][cloudCover_id][now_k];
    else if (dataID == dataID_climateEngineering)    _sky = climateEngineeringValues   [q][now_j][cloudCover_id][now_k];
    else if (dataID == dataID_climateArchive)    _sky = climateArchiveValues   [q][now_j][cloudCover_id][now_k];
    else if (dataID == dataID_climateTypicalYear)    _sky = climateTypicalYearValues   [q][now_j][cloudCover_id][now_k];
    else {
      println("ERROR: This dataID is not declared:", dataID);
    }

    if (is_undefined(_sky)) {
    } else {
      total_sky += _sky;
      num_sky += 1;
    }
  }


  if (num_sky != 0) {
    total_sky /= num_sky;

    if (scenario_of_sky == 1) return true;
    else if ((scenario_of_sky == 4) && (total_sky <= 3.33)) return true;
    else if ((scenario_of_sky == 3) && (total_sky > 3.33) && (total_sky <= 6.66)) return true;
    else if ((scenario_of_sky == 2) && (total_sky > 6.66)) return true;
  }

  return false;
}
