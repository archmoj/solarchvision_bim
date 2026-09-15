void setFlag_CurrentDataSource (int i, int j, int k, int Parameter_ID, boolean flag) {

  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
    CLIMATE_CWEEDS_flags[i][j][Parameter_ID][k] = flag;
  }
  else if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
    CLIMATE_CLMREC_flags[i][j][Parameter_ID][k] = flag;
  }
  else if (CurrentDataSource == dataID_CLIMATE_TMYEPW) {
    CLIMATE_TMYEPW_flags[i][j][Parameter_ID][k] = flag;
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
    ENSEMBLE_FORECAST_flags[i][j][Parameter_ID][k] = flag;
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
    ENSEMBLE_OBSERVED_flags[i][j][Parameter_ID][k] = flag;
  }

}

void setValue_CurrentDataSource (int i, int j, int k, int Parameter_ID, float value) {

  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
    CLIMATE_CWEEDS_values[i][j][Parameter_ID][k] = value;
  }
  else if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
    CLIMATE_CLMREC_values[i][j][Parameter_ID][k] = value;
  }
  else if (CurrentDataSource == dataID_CLIMATE_TMYEPW) {
    CLIMATE_TMYEPW_values[i][j][Parameter_ID][k] = value;
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
    ENSEMBLE_FORECAST_values[i][j][Parameter_ID][k] = value;
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
    ENSEMBLE_OBSERVED_values[i][j][Parameter_ID][k] = value;
  }

}

float getValue_CurrentDataSource (int i, int j, int k, int Parameter_ID) {

  float return_value = FLOAT_undefined;

  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
    return_value = CLIMATE_CWEEDS_values[i][j][Parameter_ID][k];
  }
  else if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
    return_value = CLIMATE_CLMREC_values[i][j][Parameter_ID][k];
  }
  else if (CurrentDataSource == dataID_CLIMATE_TMYEPW) {
    return_value = CLIMATE_TMYEPW_values[i][j][Parameter_ID][k];
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
    return_value = ENSEMBLE_FORECAST_values[i][j][Parameter_ID][k];
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
    return_value = ENSEMBLE_OBSERVED_values[i][j][Parameter_ID][k];
  }

  return return_value;
}

int getStart_CurrentDataSource () {

  int return_value = -1;

  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
    return_value = CLIMATE_CWEEDS_start;
  }
  else if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
    return_value = CLIMATE_CLMREC_start;
  }
  else if (CurrentDataSource == dataID_CLIMATE_TMYEPW) {
    return_value = CLIMATE_TMYEPW_start;
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
    return_value = ENSEMBLE_FORECAST_start;
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
    return_value = ENSEMBLE_OBSERVED_start;
  }

  return return_value;
}

int getEnd_CurrentDataSource () {

  int return_value = -1;

  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
    return_value = CLIMATE_CWEEDS_end;
  }
  else if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
    return_value = CLIMATE_CLMREC_end;
  }
  else if (CurrentDataSource == dataID_CLIMATE_TMYEPW) {
    return_value = CLIMATE_TMYEPW_end;
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
    return_value = ENSEMBLE_FORECAST_end;
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
    return_value = ENSEMBLE_OBSERVED_end;
  }

  return return_value;
}

String getReference_CurrentDataSource () {

  String return_value = "";

  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
    return_value = STATION.getFilename_CWEEDS() + ".WY3" + ", Environment and Climate Change Canada: ftp://ftp.tor.ec.gc.ca/Pub/Normals/";
  }
  else if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
    return_value  = "Environment and Climate Change Canada website at https://climate.weather.gc.ca/climate_data";
  }
  else if (CurrentDataSource == dataID_CLIMATE_TMYEPW) {
    return_value = STATION.getFilename_TMYEPW() + ".epw";
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
    return_value = nf(TIME.year, 4) + nf(TIME.month, 2) + nf(TIME.day, 2) + nf(TIME.hour, 2) + "_GEPS-NAEFS-RAW_" + STATION.getFilename_NAEFS() + "_" + CurrentLayer_name + "_000-384.xml" + ", Environment and Climate Change Canada: https://dd.weather.gc.ca/ensemble/naefs/";
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
    return_value = "Environment and Climate Change Canada website at https://dd.weather.gc.ca/observations/swob-ml/";
  }

  return return_value;
}

void SOLARCHVISION_setDataFlags (int desired_DataSource) {

  int keep_CurrentDataSource = CurrentDataSource;

  CurrentDataSource = desired_DataSource;

  int DATA_start = getStart_CurrentDataSource();
  int DATA_end = getEnd_CurrentDataSource();
  // setting the flags
  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < numberOfLayers; l++) {
        for (int k = 0; k < (1 + DATA_end - DATA_start); k++) {
          if (is_defined(getValue_CurrentDataSource(i, j, k, l))) {
            setFlag_CurrentDataSource(i, j, k, l, true);
          }
        }
      }
    }
  }

  CurrentDataSource = keep_CurrentDataSource;
}
