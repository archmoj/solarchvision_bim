void download_ensembleForecast (int THE_YEAR, int THE_MONTH, int THE_DAY, int THE_HOUR) {

  // findEnsembleForecastNearestStation() (updateEnsembleForecast.pde) used
  // to only ever run from inside update_ensembleForecast()'s own
  // ensembleForecastShouldLoad branch (now; see that function's own
  // comment on it) - never called from here - so STATION's own
  // ensembleForecastFilename could still be whatever a NAEFS marker click
  // last set it to (or the hardcoded startup default), not the grid point
  // nearest STATION's actual current position, if STATION had instead
  // been moved from the command line (SETLAT/SETLON/SETLATLON/SETLONLAT,
  // extraCommands.pde). Calling it here too, unconditionally, means this
  // action finds (or re-finds) the nearest grid point on its own first,
  // the same way "Download Climate Archive" (downloadClimateArchive.pde)
  // now does.
  findEnsembleForecastNearestStation();

  println("\nDownloading Ensemble Forecast. Please wait...");

  boolean new_files_downloaded = false;

  float printed_Progress = 0;

  // Same console-bar/ProgressWindow shape as import_objects_OBJ()'s own
  // (importObj.pde, showImportProgress) - a plain single-threaded loop,
  // here over allLayers network downloads instead of file lines/entities,
  // on the calling thread, so the only way to show progress during it is
  // this same manual throttle-and-paint trick.
  ProgressWindow ensembleForecastProgressWindow = (showEnsembleForecastDownloadProgress && canShowProgressWindow()) ? new ProgressWindow("\nDownloading Ensemble Forecast") : null;
  if (ensembleForecastProgressWindow != null) ensembleForecastProgressWindow.setVisible(true);

  try {
    for (int f = 0; f < allLayers.length; f++) {
      if (control != USER_AUTO) {
        float Progress = 100 * f / float(allLayers.length);
        int delta = (int) floor(Progress - printed_Progress);
        if (delta >= 1) {
          StringBuilder barBuffer = new StringBuilder();
          for (int c = 0; c < delta; c++) barBuffer.append('█');
          print(barBuffer.toString());
          printed_Progress = floor(Progress);
          if (ensembleForecastProgressWindow != null) ensembleForecastProgressWindow.updateFraction(Progress / 100.0f);
        }
      }

      if (allLayers[f].name.equals("")) {
      } else {
        String dayStr = nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + nf(THE_DAY, 2);

        String FN = dayStr + nf(THE_HOUR, 2) + "_GEPS-NAEFS-RAW_" +
          STATION.getEnsembleForecastFilename() + "_" + allLayers[f].name + "_000-384.xml";

        String the_target = Folder_ensembleForecast + "/" + FN;

        File dir = new File(the_target);
        if (!dir.isFile()) {

          String the_directory = dayStr + "/" + nf(THE_HOUR, 2) + "/" +
            allLayers[f].name + "/raw";
          String the_link = "https://dd.weather.gc.ca/" + dayStr +
            "/WXO-DD/ensemble/naefs/xml/" + the_directory + "/" + FN + ".bz2";

          the_target = the_target + ".bz2";

          println("\nTry downloading: " + the_link);

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
  } finally {
    if (ensembleForecastProgressWindow != null) ensembleForecastProgressWindow.dispose();
  }

  int remaining = (int) floor(100 - printed_Progress);
  StringBuilder barBuffer = new StringBuilder();
  for (int c = 0; c < remaining; c++) barBuffer.append('█');
  print(barBuffer.toString());
  println();

  if (new_files_downloaded) {

    String folder_inout = Folder_ensembleForecast;

    File dir = new File(folder_inout);
    File[] bz2Files = dir.listFiles((d, name) -> name.endsWith(".bz2"));
    if (bz2Files != null) {
      for (File f : bz2Files) {
        String p = f.getAbsolutePath();

        // strip the ".bz2" suffix to get the output filename
        String outPath = p.substring(0, p.length() - 4);
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
          // println("Failed to decompress " + f.getName() + ": " + e);
        }
      }
    }

    ensembleForecastShouldLoad = true;
    update_ensembleForecast(TIME.year, TIME.month, TIME.day, TIME.hour);
  }

  println("Ensemble Forecast downloaded.");
}
