void download_CLIMATE_CLMREC () {

  if (nearest_Station_CLMREC_id != -1) {

    for (int k = 0; k < (1 + CLIMATE_CLMREC_end - CLIMATE_CLMREC_start); k++) {
      for (int m = 0; m < 12; m++) {

        int THE_YEAR = k + CLIMATE_CLMREC_start;
        int THE_MONTH = m + 1;

        String FN = nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + "_" + CLMREC_Coordinates[nearest_Station_CLMREC_id].getCity() + ".csv";

        String the_target = Folder_CLIMATE_CLMREC + "/" + FN;

        File dir = new File(the_target);
        if (!dir.isFile()) {

          String the_link = "https://climate.weather.gc.ca/climate_data/bulk_data_e.html?format=csv&stationID=" + CLMREC_Coordinates[nearest_Station_CLMREC_id].getCode() + "&Year=" + nf(THE_YEAR, 4) + "&Month=" + nf(THE_MONTH, 2) + "&timeframe=1";

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

    Files_CLIMATE_CLMREC = OPESYS.getFiles(Folder_CLIMATE_CLMREC);

    CLIMATE_CLMREC_load = true;
    update_CLIMATE_CLMREC();
  }
}
