void downloadClimateArchive () {

  if (climateArchiveNearestStationIndex != -1) {

    println("\nDownloading Climate Archive. Please wait...");

    int totalMonths = (1 + climateArchiveEnd - climateArchiveStart) * 12;
    int done = 0;
    float printed_Progress = 0;

    // Same console-bar/ProgressWindow shape as import_objects_OBJ()'s own
    // (importObj.pde, showImportProgress) - a plain single-threaded nested
    // loop, here over (year x month) network downloads instead of file
    // lines/entities, on the calling thread, so the only way to show
    // progress during it is this same manual throttle-and-paint trick.
    ProgressWindow climateArchiveProgressWindow = (showClimateArchiveDownloadProgress && canShowProgressWindow()) ? new ProgressWindow("\nDownloading Climate Archive") : null;
    if (climateArchiveProgressWindow != null) climateArchiveProgressWindow.setVisible(true);

    try {
      for (int k = 0; k < (1 + climateArchiveEnd - climateArchiveStart); k++) {
        for (int m = 0; m < 12; m++) {

          if (control != USER_AUTO) {
            float Progress = 100 * done / float(totalMonths);
            int delta = (int) floor(Progress - printed_Progress);
            if (delta >= 1) {
              StringBuilder barBuffer = new StringBuilder();
              for (int c = 0; c < delta; c++) barBuffer.append('█');
              print(barBuffer.toString());
              printed_Progress = floor(Progress);
              if (climateArchiveProgressWindow != null) climateArchiveProgressWindow.updateFraction(Progress / 100.0f);
            }
          }
          done += 1;

          int THE_YEAR = k + climateArchiveStart;
          int THE_MONTH = m + 1;

          String FN = nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + "_" + climateArchiveCoordinates[climateArchiveNearestStationIndex].getCity() + ".csv";

          String the_target = Folder_climateArchive + "/" + FN;

          File dir = new File(the_target);
          if (!dir.isFile()) {

            // "Day=" and "submit=Download+Data" are both required - without
            // them the server serves the bulk-data form page itself (HTML)
            // instead of running the export and returning real CSV data. Day's
            // own value doesn't affect which rows come back for an
            // hourly/monthly bulk export (the whole month is always returned
            // regardless), so any valid day works; 1 is used here.
            String the_link = "https://climate.weather.gc.ca/climate_data/bulk_data_e.html?format=csv&stationID=" + climateArchiveCoordinates[climateArchiveNearestStationIndex].getCode() + "&Year=" + nf(THE_YEAR, 4) + "&Month=" + nf(THE_MONTH, 2) + "&Day=1&timeframe=1&submit=Download+Data";

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
    } finally {
      if (climateArchiveProgressWindow != null) climateArchiveProgressWindow.dispose();
    }

    int remaining = (int) floor(100 - printed_Progress);
    StringBuilder barBuffer = new StringBuilder();
    for (int c = 0; c < remaining; c++) barBuffer.append('█');
    print(barBuffer.toString());
    println();

    climateArchiveShouldLoad = true;
    updateClimateArchive();

    println("Climate Archive downloaded.");
  }
}
