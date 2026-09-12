void download_ENSEMBLE_OBSERVED (int THE_YEAR, int THE_MONTH, int THE_DAY, int THE_HOUR) {

  Calendar timeNow = Calendar.getInstance();
  timeNow.set(Calendar.YEAR,  THE_YEAR);
  timeNow.set(Calendar.MONTH, THE_MONTH - 1);
  timeNow.set(Calendar.DATE,  THE_DAY);
  timeNow.set(Calendar.HOUR_OF_DAY, THE_HOUR);
  timeNow.add(Calendar.HOUR_OF_DAY, (int) -STATION.getTimelong() / 15);

  timeNow.add(Calendar.HOUR_OF_DAY, 1);
  for (int j_for = 0; j_for < ENSEMBLE_OBSERVED_maxDays * 24; j_for++) {
    timeNow.add(Calendar.HOUR_OF_DAY, -1);

    int YEAR = timeNow.get(Calendar.YEAR);
    int MONTH = timeNow.get(Calendar.MONTH) + 1;
    int DAY = timeNow.get(Calendar.DATE);
    int HOUR = timeNow.get(Calendar.HOUR_OF_DAY);

    String dayStr = nf(YEAR, 4) + nf(MONTH, 2) + nf(DAY, 2);

    for (int q = 0; q < ENSEMBLE_OBSERVED_numNearest; q++) {

      int f = nearest_Station_ENSEMBLE_OBSERVED_id[q];

      if (f != -1) {

        String FN = nf(YEAR, 4) + "-" + nf(MONTH, 2) + "-" + nf(DAY, 2) + "-" + nf(HOUR, 2) + "00-" +
          SWOB_Coordinates[f].getCode() + "-swob.xml";

        String the_target = Folder_ENSEMBLE_OBSERVED + "/" + FN;

        File dir = new File(the_target);
        if (!dir.isFile()) {

          String the_link = "https://dd.weather.gc.ca/" + dayStr +"/WXO-DD/observations/swob-ml/" + dayStr + "/" +
            split(SWOB_Coordinates[f].getCode(),'-')[0] + "/" + FN;

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
  }

  ENSEMBLE_OBSERVED_load = true;
  update_ENSEMBLE_OBSERVED(THE_YEAR, THE_MONTH, THE_DAY, THE_HOUR);
}
