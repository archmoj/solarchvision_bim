void download_ensembleObservation (int THE_YEAR, int THE_MONTH, int THE_DAY, int THE_HOUR) {

  println("\nDownloading Ensemble Observation. Please wait...");

  Calendar timeNow = Calendar.getInstance();
  timeNow.set(Calendar.YEAR,  THE_YEAR);
  timeNow.set(Calendar.MONTH, THE_MONTH - 1);
  timeNow.set(Calendar.DATE,  THE_DAY);
  timeNow.set(Calendar.HOUR_OF_DAY, THE_HOUR);
  timeNow.add(Calendar.HOUR_OF_DAY, (int) -STATION.getTimezoneLongitude() / 15);

  timeNow.add(Calendar.HOUR_OF_DAY, 1);

  int totalSteps = ensembleObservationMaxDays * 24 * nearestWeatherStationCount;
  int done = 0;
  float printed_Progress = 0;

  // Same console-bar/ProgressWindow shape as import_objects_OBJ()'s own
  // (importObj.pde, showImportProgress) - a plain single-threaded nested
  // loop, here over (hour x nearby weather station) network downloads
  // instead of file lines/entities, on the calling thread, so the only
  // way to show progress during it is this same manual throttle-and-paint
  // trick.
  ProgressWindow ensembleObservationProgressWindow = (showEnsembleObservationDownloadProgress && canShowProgressWindow()) ? new ProgressWindow("\nDownloading Ensemble Observation") : null;
  if (ensembleObservationProgressWindow != null) ensembleObservationProgressWindow.setVisible(true);

  try {
    for (int j_for = 0; j_for < ensembleObservationMaxDays * 24; j_for++) {
      timeNow.add(Calendar.HOUR_OF_DAY, -1);

      int YEAR = timeNow.get(Calendar.YEAR);
      int MONTH = timeNow.get(Calendar.MONTH) + 1;
      int DAY = timeNow.get(Calendar.DATE);
      int HOUR = timeNow.get(Calendar.HOUR_OF_DAY);

      String dayStr = nf(YEAR, 4) + nf(MONTH, 2) + nf(DAY, 2);

      for (int q = 0; q < nearestWeatherStationCount; q++) {

        if (control != USER_AUTO) {
          float Progress = 100 * done / float(totalSteps);
          int delta = (int) floor(Progress - printed_Progress);
          if (delta >= 1) {
            StringBuilder barBuffer = new StringBuilder();
            for (int c = 0; c < delta; c++) barBuffer.append('█');
            print(barBuffer.toString());
            printed_Progress = floor(Progress);
            if (ensembleObservationProgressWindow != null) ensembleObservationProgressWindow.updateFraction(Progress / 100.0f);
          }
        }
        done += 1;

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
  } finally {
    if (ensembleObservationProgressWindow != null) ensembleObservationProgressWindow.dispose();
  }

  int remaining = (int) floor(100 - printed_Progress);
  StringBuilder barBuffer = new StringBuilder();
  for (int c = 0; c < remaining; c++) barBuffer.append('█');
  print(barBuffer.toString());
  println();

  ensembleObservationShouldLoad = true;
  update_ensembleObservation(THE_YEAR, THE_MONTH, THE_DAY, THE_HOUR);

  println("Ensemble Observation downloaded.");
}
