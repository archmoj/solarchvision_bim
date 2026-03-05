void download_ENSEMBLE_OBSERVED () {

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

        String the_target = Folder_ENSEMBLE_OBSERVED + "/" + FN;

        File dir = new File(the_target);
        if (!dir.isFile()) {

          String the_link = "https://dd.weather.gc.ca/observations/swob-ml/" + nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + nf(THE_DAY, 2) + "/" + split(SWOB_Coordinates[f].getCode(),'-')[0] + "/" + FN;

          println("Try downloading: " + the_link);

          try {
            saveBytes(the_target, loadBytes(the_link));
          }
          catch (Exception e) {
            println("LINK NOT AVAILABLE:", the_link);
          }
        }
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

  Files_ENSEMBLE_OBSERVED = OPESYS.getFiles(Folder_ENSEMBLE_OBSERVED);

  ENSEMBLE_OBSERVED_load = true;
  update_ENSEMBLE_OBSERVED();
}
