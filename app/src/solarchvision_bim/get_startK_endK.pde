int[] get_startK_endK () {
  int[] a = new int [2];

  int start_k = -1;
  int end_k = -1;

  if (currentDataSource == dataID_climateEngineering) {

    start_k = sampleYearStart;
    end_k = sampleYearEnd;

    if (start_k < climateEngineeringStart) start_k = climateEngineeringStart;
    if (end_k > climateEngineeringEnd) end_k = climateEngineeringEnd;

    start_k -= climateEngineeringStart;
    end_k -= climateEngineeringStart;
  }
  if (currentDataSource == dataID_climateArchive) {

    start_k = sampleYearStart;
    end_k = sampleYearEnd;

    if (start_k < climateArchiveStart) start_k = climateArchiveStart;
    if (end_k > climateArchiveEnd) end_k = climateArchiveEnd;

    start_k -= climateArchiveStart;
    end_k -= climateArchiveStart;
  }
  if (currentDataSource == dataID_climateTmyEpw) {

    start_k = 0;
    end_k = 0;
  }
  if (currentDataSource == dataID_ensembleForecast) {

    start_k = sampleMemberStart;
    end_k = sampleMemberEnd;

    start_k -= ensembleForecastStart;
    end_k -= ensembleForecastStart;
  }
  if (currentDataSource == dataID_ensembleObservation) {

    start_k =  sampleStationStart;
    end_k =  sampleStationEnd;

    start_k -= ensembleObservationStart;
    end_k -= ensembleObservationStart;
  }

  //println("start_k=", start_k);
  //println("end_k=", end_k);

  a[0] = start_k;
  a[1] = end_k;

  return  a;
}
