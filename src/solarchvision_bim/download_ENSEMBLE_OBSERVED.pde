void download_ensembleObservation (int THE_YEAR, int THE_MONTH, int THE_DAY, int THE_HOUR) {

  Calendar timeNow = Calendar.getInstance();
  timeNow.set(Calendar.YEAR,  THE_YEAR);
  timeNow.set(Calendar.MONTH, THE_MONTH - 1);
  timeNow.set(Calendar.DATE,  THE_DAY);
  timeNow.set(Calendar.HOUR_OF_DAY, THE_HOUR);
  timeNow.add(Calendar.HOUR_OF_DAY, (int) -STATION.getTimezoneLongitude() / 15);

  timeNow.add(Calendar.HOUR_OF_DAY, 1);
  for (int j_for = 0; j_for < ensembleObservationMaxDays * 24; j_for++) {
    timeNow.add(Calendar.HOUR_OF_DAY, -1);

    int YEAR = timeNow.get(Calendar.YEAR);
    int MONTH = timeNow.get(Calendar.MONTH) + 1;
    int DAY = timeNow.get(Calendar.DATE);
    int HOUR = timeNow.get(Calendar.HOUR_OF_DAY);

    String dayStr = nf(YEAR, 4) + nf(MONTH, 2) + nf(DAY, 2);

    for (int q = 0; q < nearestWeatherStationCount; q++) {

      int f = ensembleObservationNearestStationIndex[q];

      if (f != -1) {

        String FN = nf(YEAR, 4) + "-" + nf(MONTH, 2) + "-" + nf(DAY, 2) + "-" + nf(HOUR, 2) + "00-" +
          ensembleObservationCoordinates[f].getCode() + "-swob.xml";

        String the_target = Folder_ensembleObservation + "/" + FN;

        File dir = new File(the_target);
        if (!dir.isFile()) {

          String the_link = "https://dd.weather.gc.ca/" + dayStr +"/WXO-DD/observations/swob-ml/" + dayStr + "/" +
            split(ensembleObservationCoordinates[f].getCode(),'-')[0] + "/" + FN;

          println("\nTry downloading: " + the_link);

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

  ensembleObservationShouldLoad = true;
  update_ensembleObservation(THE_YEAR, THE_MONTH, THE_DAY, THE_HOUR);
}
