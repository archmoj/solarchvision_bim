void SOLARCHVISION_update_ENSEMBLE_OBSERVED () {

  ENSEMBLE_OBSERVED_values = new float [24][365][numberOfLayers][(1 + ENSEMBLE_OBSERVED_end - ENSEMBLE_OBSERVED_start)];
  ENSEMBLE_OBSERVED_flags = new boolean [24][365][numberOfLayers][(1 + ENSEMBLE_OBSERVED_end - ENSEMBLE_OBSERVED_start)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < numberOfLayers; l++) {
        for (int k = 0; k < (1 + ENSEMBLE_OBSERVED_end - ENSEMBLE_OBSERVED_start); k++) {
          ENSEMBLE_OBSERVED_values[i][j][l][k] = FLOAT_undefined;
          ENSEMBLE_OBSERVED_flags[i][j][l][k] = false;
        }
      }
    }
  }

  if (ENSEMBLE_OBSERVED_load) {

    // this line tries to update the most recent files! <<
    int THE_YEAR = year();
    int THE_MONTH = month();
    int THE_DAY = day();
    int THE_HOUR = hour();


    float THE_DATE = TIME.date;

    int now_i = int(THE_HOUR);
    int now_j = TIME.convert2Date(THE_MONTH, THE_DAY);

    now_i += int(-STATION.getTimelong() / 15);
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

    for (int j_for = 0; j_for < ENSEMBLE_OBSERVED_maxDays * 24; j_for++) {

      THE_MONTH = TIME.getMonth_fromDate(THE_DATE);
      THE_DAY = TIME.getDay_fromDate(THE_DATE);

      for (int q = 0; q < ENSEMBLE_OBSERVED_numNearest; q++) {

        int f = nearest_Station_ENSEMBLE_OBSERVED_id[q];

        if (f != -1) {

          String FN = nf(THE_YEAR, 4) + "-" + nf(THE_MONTH, 2) + "-" + nf(THE_DAY, 2) + "-" + nf(THE_HOUR, 2) + "00-" + SWOB_Coordinates[f].getCode() + "-swob.xml";

          String the_source = Folder_ENSEMBLE_OBSERVED + "/" + FN;

          File dir = new File(the_source);
          if (dir.isFile()) load_ENSEMBLE_OBSERVED(the_source, q);
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

    SOLARCHVISION_setDataFlags(dataID_ENSEMBLE_OBSERVED);
    SOLARCHVISION_postProcess_solarsUsingCloud(dataID_ENSEMBLE_OBSERVED); // <<<<<<<<<<<<
    SOLARCHVISION_postProcess_solarEffects(dataID_ENSEMBLE_OBSERVED);
    SOLARCHVISION_postProcess_developDATA(dataID_ENSEMBLE_OBSERVED);

    WORLD.displayAll_SWOB = 1;
    WORLD.displayNear_SWOB = true;
  }

  WORLD.revise();
  STUDY.revise();
  ROLLOUT.revise();
  UI_caseBar.revise();
  SOLARCHVISION_view_changed();

  SampleStation_Start = ENSEMBLE_OBSERVED_start;
  SampleStation_End = ENSEMBLE_OBSERVED_end;
}
