int[] get_startK_endK () {
  int[] a = new int [2];

  int start_k = -1;
  int end_k = -1;

  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {

    start_k = SampleYear_Start;
    end_k = SampleYear_End;

    if (start_k < CLIMATE_CWEEDS_start) start_k = CLIMATE_CWEEDS_start;
    if (end_k > CLIMATE_CWEEDS_end) end_k = CLIMATE_CWEEDS_end;

    start_k -= CLIMATE_CWEEDS_start;
    end_k -= CLIMATE_CWEEDS_start;
  }
  if (CurrentDataSource == dataID_CLIMATE_CLMREC) {

    start_k = SampleYear_Start;
    end_k = SampleYear_End;

    if (start_k < CLIMATE_CLMREC_start) start_k = CLIMATE_CLMREC_start;
    if (end_k > CLIMATE_CLMREC_end) end_k = CLIMATE_CLMREC_end;

    start_k -= CLIMATE_CLMREC_start;
    end_k -= CLIMATE_CLMREC_start;
  }
  if (CurrentDataSource == dataID_CLIMATE_TMYEPW) {

    start_k = 0;
    end_k = 0;
  }
  if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {

    start_k = SampleMember_Start;
    end_k = SampleMember_End;

    start_k -= ENSEMBLE_FORECAST_start;
    end_k -= ENSEMBLE_FORECAST_start;
  }
  if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {

    start_k =  SampleStation_Start;
    end_k =  SampleStation_End;

    start_k -= ENSEMBLE_OBSERVED_start;
    end_k -= ENSEMBLE_OBSERVED_start;
  }

  //println("start_k=", start_k);
  //println("end_k=", end_k);

  a[0] = start_k;
  a[1] = end_k;

  return  a;
}
