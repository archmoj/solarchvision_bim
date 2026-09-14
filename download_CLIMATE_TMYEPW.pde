void download_CLIMATE_TMYEPW () {

  boolean new_files_downloaded = false;

  String FN = STATION.getFilename_NAEFS() + ".epw";

  String the_target = Folder_CLIMATE_TMYEPW + "/" + FN;

  File dir = new File(the_target);
  if (!dir.isFile()) {

    String the_link = STATION.getDownload_TMYEPW();

    println("Try downloading: " + the_link);

    try {
      saveBytes(the_target, loadBytes(the_link));

      new_files_downloaded = true;
    }
    catch (Exception e) {
      println("LINK NOT AVAILABLE:", the_link);
    }
  }

  if (new_files_downloaded) {

    String folder_inout = Folder_CLIMATE_TMYEPW;

    dir = new File(folder_inout);
    File[] zipFiles = dir.listFiles((d, name) -> name.endsWith(".zip"));
    if (zipFiles != null) {
      for (File f : zipFiles) {
        String p = f.getAbsolutePath();

        // strip the ".zip" suffix to get the output filename and add .epw
        String outPath = p.substring(0, p.length() - 4) + ".epw";
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

    CLIMATE_TMYEPW_load = true;
    update_CLIMATE_TMYEPW();
  }
}
