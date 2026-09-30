void update_ensembleObservation (int THE_YEAR, int THE_MONTH, int THE_DAY, int THE_HOUR) {

  ensembleObservationValues = new float [24][365][allLayers.length][(1 + ensembleObservationEnd - ensembleObservationStart)];
  ensembleObservationFlags = new boolean [24][365][allLayers.length][(1 + ensembleObservationEnd - ensembleObservationStart)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < allLayers.length; l++) {
        for (int k = 0; k < (1 + ensembleObservationEnd - ensembleObservationStart); k++) {
          ensembleObservationValues[i][j][l][k] = FLOAT_undefined;
          ensembleObservationFlags[i][j][l][k] = false;
        }
      }
    }
  }

  if (ensembleObservationShouldLoad) {

    float THE_DATE = TIME.date;

    int now_i = int(THE_HOUR);
    int now_j = TIME.convert2Date(THE_MONTH, THE_DAY);

    now_i += int(-STATION.getTimezoneLongitude() / 15);
    if (now_i > 23) {
      now_i -= 24;
      now_j += 1;
      if (now_j > 364) {
        now_j -= 365;
        THE_YEAR += 1;
      }
      THE_DATE += 1;
      if (THE_DATE > 364) THE_DATE -= 365;
    }
    THE_HOUR = now_i;

    for (int j_for = 0; j_for < ensembleObservationMaxDays * 24; j_for++) {

      THE_MONTH = TIME.getMonth_fromDate(THE_DATE);
      THE_DAY = TIME.getDay_fromDate(THE_DATE);

      for (int q = 0; q < nearestWeatherStationCount; q++) {

        int f = ensembleObservationNearestStationIndex[q];

        if (f != -1) {

          String FN = nf(THE_YEAR, 4) + "-" + nf(THE_MONTH, 2) + "-" + nf(THE_DAY, 2) + "-" + nf(THE_HOUR, 2) + "00-" + ensembleObservationCoordinates[f].getCode() + "-swob.xml";

          String the_source = Folder_ensembleObservation + "/" + FN;

          File dir = new File(the_source);
          if (dir.isFile()) load_ensembleObservation(the_source, q);
          else println("FILE NOT FOUND:", the_source);

        }
      }

      now_i -= 1;
      if (now_i < 0) {
        now_i += 24;
        now_j -= 1;
        if (now_j < 0) {
          now_j += 365;
          THE_YEAR -= 1;
        }
        THE_DATE -= 1;
        if (THE_DATE < 0) THE_DATE += 364;
      }
      THE_HOUR = now_i;
    }

    setDataFlags(dataID_ensembleObservation);
    postProcess_solarsUsingCloud(dataID_ensembleObservation); // <<<<<<<<<<<<
    postProcess_solarEffects(dataID_ensembleObservation);
    postProcess_developDATA(dataID_ensembleObservation);

    WORLD.ensembleObservationDisplayAll = 1;
    WORLD.ensembleObservationDisplayNear = true;
  }

  WORLD.revise();
  STUDY.revise();
  UI_rollout.revise();
  UI_caseBar.revise();
  view_changed();

  sampleStationStart = ensembleObservationStart;
  sampleStationEnd = ensembleObservationEnd;
}
