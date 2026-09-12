void download_ENSEMBLE_FORECAST (int THE_YEAR, int THE_MONTH, int THE_DAY, int THE_HOUR) {

  Files_ENSEMBLE_FORECAST = OPESYS.getFiles(Folder_ENSEMBLE_FORECAST);

  boolean new_files_downloaded = false;

  for (int f = 0; f < numberOfLayers; f++) {
    if (allLayers[f].name.equals("")) {
    } else {
      String dayStr = nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + nf(THE_DAY, 2);

      String FN = dayStr + nf(THE_HOUR, 2) + "_GEPS-NAEFS-RAW_" +
        STATION.getFilename_NAEFS() + "_" + allLayers[f].name + "_000-384.xml";

      String the_target = Folder_ENSEMBLE_FORECAST + "/" + FN;

      File dir = new File(the_target);
      if (!dir.isFile()) {

        String the_directory = dayStr + "/" + nf(THE_HOUR, 2) + "/" +
          allLayers[f].name + "/raw";
        String the_link = "https://dd.weather.gc.ca/" + dayStr +
          "/WXO-DD/ensemble/naefs/xml/" + the_directory + "/" + FN + ".bz2";

        the_target = the_target + ".bz2";

        println("Try downloading: " + the_link);

        try {
          saveBytes(the_target, loadBytes(the_link));

          new_files_downloaded = true;
        }
        catch (Exception e) {
          println("LINK NOT AVAILABLE:", the_link);
        }
      }
    }
  }

  if (new_files_downloaded) {

    String folder_inout = Folder_ENSEMBLE_FORECAST;

    File dir = new File(folder_inout);
    File[] bz2Files = dir.listFiles((d, name) -> name.endsWith(".bz2"));
    if (bz2Files != null) {
      for (File f : bz2Files) {
        // strip the ".bz2" suffix to get the output filename
        String outPath = f.getAbsolutePath().substring(0, f.getAbsolutePath().length() - 4);
        File outFile = new File(outPath);

        try (
          BZip2CompressorInputStream bzIn = new BZip2CompressorInputStream(
            new BufferedInputStream(new FileInputStream(f))
          );
          FileOutputStream out = new FileOutputStream(outFile)
        ) {
          byte[] buffer = new byte[8192];
          int n;
          while ((n = bzIn.read(buffer)) != -1) {
            out.write(buffer, 0, n);
          }

          f.delete(); // only reached if decompression succeeded without throwing
        }
        catch (Exception e) {
          println("Failed to decompress " + f.getName() + ": " + e);
        }
      }
    }
    Files_ENSEMBLE_FORECAST = OPESYS.getFiles(Folder_ENSEMBLE_FORECAST);

    ENSEMBLE_FORECAST_load = true;
    update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);
  }
}
