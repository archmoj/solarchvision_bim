void download_climateTypicalYear () {

  // findClimateTypicalYearNearestStation() (updateClimateTypicalYear.pde)
  // used to only ever run from inside update_climateTypicalYear()'s own
  // climateTypicalYearShouldLoad branch (now; see that function's own
  // comment on it) - never called from here - so STATION's own
  // climateTypicalYearFilename/climateTypicalYearDownload could still be
  // whatever a TMYEPW marker click last set them to (or the hardcoded
  // startup default, whose climateTypicalYearDownload is blank), not the
  // city nearest STATION's actual current position, if STATION had
  // instead been moved from the command line (SETLAT/SETLON/SETLATLON/
  // SETLONLAT, extraCommands.pde). Calling it here too, unconditionally,
  // means this action finds (or re-finds) the nearest city on its own
  // first, the same way "Download Climate Archive" (downloadClimateArchive
  // .pde) now does.
  findClimateTypicalYearNearestStation();

  boolean new_files_downloaded = false;

  String FN = STATION.getClimateTypicalYearFilename();

  String the_target = Folder_climateTypicalYear + "/" + FN;

  File dir = new File(the_target + ".epw");
  if (!dir.isFile()) {

    String the_link = STATION.getClimateTypicalYearDownload();

    println("\nTry downloading: " + the_link);

    try {
      saveBytes(the_target + ".zip", loadBytes(the_link));

      new_files_downloaded = true;
    }
    catch (Exception e) {
      println("LINK NOT AVAILABLE:", the_link);
    }
  }

  if (new_files_downloaded) {

    File f = new File(the_target + ".zip");
    File outFile = new File(the_target + ".epw");

    try (
      ZipInputStream zipIn = new ZipInputStream(new BufferedInputStream(new FileInputStream(f)))
    ) {
      ZipEntry entry;
      boolean foundEpw = false;

      while ((entry = zipIn.getNextEntry()) != null) {
        if (entry.getName().toLowerCase().endsWith(".epw")) {

          try (FileOutputStream out = new FileOutputStream(outFile)) {
            byte[] buffer = new byte[8192];
            int n;
            while ((n = zipIn.read(buffer)) != -1) {
              out.write(buffer, 0, n);
            }
          }

          foundEpw = true;
          break; // ignore the archive's other files (.stat, .ddy, .clm, .wea, .rain, etc.)
        }
        zipIn.closeEntry();
      }

      if (foundEpw) {
        f.delete(); // only reached if extraction succeeded without throwing
      }
    }
    catch (Exception e) {
      // println("Failed to extract " + f.getName() + ": " + e);
    }

    climateTypicalYearShouldLoad = true;
    update_climateTypicalYear();
  }
}
