void downloadClimateArchive () {

  if (climateArchiveNearestStationIndex != -1) {

    for (int k = 0; k < (1 + climateArchiveEnd - climateArchiveStart); k++) {
      for (int m = 0; m < 12; m++) {

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

    climateArchiveShouldLoad = true;
    updateClimateArchive();
  }
}
