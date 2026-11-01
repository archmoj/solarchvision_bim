void setFlag_currentDataSource (int i, int j, int k, int Parameter_ID, boolean flag) {

  if (currentDataSource == dataID_climateEngineering) {
    climateEngineeringFlags[i][j][Parameter_ID][k] = flag;
  }
  else if (currentDataSource == dataID_climateArchive) {
    climateArchiveFlags[i][j][Parameter_ID][k] = flag;
  }
  else if (currentDataSource == dataID_climateTypicalYear) {
    climateTypicalYearFlags[i][j][Parameter_ID][k] = flag;
  }
  else if (currentDataSource == dataID_ensembleForecast) {
    ensembleForecastFlags[i][j][Parameter_ID][k] = flag;
  }
  else if (currentDataSource == dataID_ensembleObservation) {
    ensembleObservationFlags[i][j][Parameter_ID][k] = flag;
  }

}

void setValue_currentDataSource (int i, int j, int k, int Parameter_ID, float value) {

  if (currentDataSource == dataID_climateEngineering) {
    climateEngineeringValues[i][j][Parameter_ID][k] = value;
  }
  else if (currentDataSource == dataID_climateArchive) {
    climateArchiveValues[i][j][Parameter_ID][k] = value;
  }
  else if (currentDataSource == dataID_climateTypicalYear) {
    climateTypicalYearValues[i][j][Parameter_ID][k] = value;
  }
  else if (currentDataSource == dataID_ensembleForecast) {
    ensembleForecastValues[i][j][Parameter_ID][k] = value;
  }
  else if (currentDataSource == dataID_ensembleObservation) {
    ensembleObservationValues[i][j][Parameter_ID][k] = value;
  }

}

float getValue_currentDataSource (int i, int j, int k, int Parameter_ID) {

  float return_value = FLOAT_undefined;

  if (currentDataSource == dataID_climateEngineering) {
    return_value = climateEngineeringValues[i][j][Parameter_ID][k];
  }
  else if (currentDataSource == dataID_climateArchive) {
    return_value = climateArchiveValues[i][j][Parameter_ID][k];
  }
  else if (currentDataSource == dataID_climateTypicalYear) {
    return_value = climateTypicalYearValues[i][j][Parameter_ID][k];
  }
  else if (currentDataSource == dataID_ensembleForecast) {
    return_value = ensembleForecastValues[i][j][Parameter_ID][k];
  }
  else if (currentDataSource == dataID_ensembleObservation) {
    return_value = ensembleObservationValues[i][j][Parameter_ID][k];
  }

  return return_value;
}

int getStart_currentDataSource () {

  int return_value = -1;

  if (currentDataSource == dataID_climateEngineering) {
    return_value = climateEngineeringStart;
  }
  else if (currentDataSource == dataID_climateArchive) {
    return_value = climateArchiveStart;
  }
  else if (currentDataSource == dataID_climateTypicalYear) {
    return_value = climateTypicalYearStart;
  }
  else if (currentDataSource == dataID_ensembleForecast) {
    return_value = ensembleForecastStart;
  }
  else if (currentDataSource == dataID_ensembleObservation) {
    return_value = ensembleObservationStart;
  }

  return return_value;
}

int getEnd_currentDataSource () {

  int return_value = -1;

  if (currentDataSource == dataID_climateEngineering) {
    return_value = climateEngineeringEnd;
  }
  else if (currentDataSource == dataID_climateArchive) {
    return_value = climateArchiveEnd;
  }
  else if (currentDataSource == dataID_climateTypicalYear) {
    return_value = climateTypicalYearEnd;
  }
  else if (currentDataSource == dataID_ensembleForecast) {
    return_value = ensembleForecastEnd;
  }
  else if (currentDataSource == dataID_ensembleObservation) {
    return_value = ensembleObservationEnd;
  }

  return return_value;
}

String getReference_currentDataSource () {

  String return_value = "";

  if (currentDataSource == dataID_climateEngineering) {
    return_value = STATION.getClimateEngineeringFilename() + ".WY3" + ", Environment and Climate Change Canada: ftp://ftp.tor.ec.gc.ca/Pub/Normals/";
  }
  else if (currentDataSource == dataID_climateArchive) {
    return_value  = "Environment and Climate Change Canada website at https://climate.weather.gc.ca/climate_data";
  }
  else if (currentDataSource == dataID_climateTypicalYear) {
    return_value = STATION.getClimateTypicalYearFilename() + ".epw";
  }
  else if (currentDataSource == dataID_ensembleForecast) {
    return_value = nf(TIME.year, 4) + nf(TIME.month, 2) + nf(TIME.day, 2) + nf(TIME.hour, 2) + "_GEPS-NAEFS-RAW_" + STATION.getEnsembleForecastFilename() + "_" + CurrentLayer_name + "_000-384.xml" + ", Environment and Climate Change Canada: https://dd.weather.gc.ca/ensemble/naefs/";
  }
  else if (currentDataSource == dataID_ensembleObservation) {
    return_value = "Environment and Climate Change Canada website at https://dd.weather.gc.ca/observations/swob-ml/";
  }

  return return_value;
}

void setDataFlags (int desired_DataSource) {

  int keep_currentDataSource = currentDataSource;

  currentDataSource = desired_DataSource;

  int DATA_start = getStart_currentDataSource();
  int DATA_end = getEnd_currentDataSource();
  // setting the flags
  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < allLayers.length; l++) {
        for (int k = 0; k < (1 + DATA_end - DATA_start); k++) {
          if (is_defined(getValue_currentDataSource(i, j, k, l))) {
            setFlag_currentDataSource(i, j, k, l, true);
          }
        }
      }
    }
  }

  currentDataSource = keep_currentDataSource;
}
