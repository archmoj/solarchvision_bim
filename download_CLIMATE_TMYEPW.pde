void download_CLIMATE_TMYEPW () {

  boolean new_files_downloaded = false;

  String FN = STATION.getFilename_TMYEPW();

  String the_target = Folder_CLIMATE_TMYEPW + "/" + FN;

  File dir = new File(the_target + ".epw");
  if (!dir.isFile()) {

    String the_link = STATION.getDownload_TMYEPW();

    println("Try downloading: " + the_link);

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

    CLIMATE_TMYEPW_load = true;
    update_CLIMATE_TMYEPW();
  }
}
