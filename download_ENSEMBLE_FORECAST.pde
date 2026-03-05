void download_ENSEMBLE_FORECAST (int THE_YEAR, int THE_MONTH, int THE_DAY, int THE_HOUR) {

  boolean new_files_downloaded = false;

  for (int f = 0; f < numberOfLayers; f++) {
    if (allLayers[f].name.equals("")) {
    } else {
      String FN = nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + nf(THE_DAY, 2) + nf(THE_HOUR, 2) + "_GEPS-NAEFS-RAW_" + STATION.getFilename_NAEFS() + "_" + allLayers[f].name + "_000-384.xml";

      String the_target = Folder_ENSEMBLE_FORECAST + "/" + FN;

      File dir = new File(the_target);
      if (!dir.isFile()) {

        String the_directory = nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + nf(THE_DAY, 2) + "/" + nf(THE_HOUR, 2) + "/" + allLayers[f].name + "/raw";
        String the_link = "https://dd.weather.gc.ca/" + nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + nf(THE_DAY, 2) + "/WXO-DD/ensemble/naefs/xml/" + the_directory + "/" + FN + ".bz2";
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
    // on Windows:
    //folder_inout = folder_inout.replace('/', char(92));

    {
      // on Windows:
      //String Command1 = "cmd /c \"\"C:\\Program Files (x86)\\7-Zip\\7z.exe\"\" e " + folder_inout + "\\*.bz2 -o" + folder_inout + " -y";
      String Command1 = "for bz2 in " + folder_inout + "/*.bz2; do 7z e $bz2 -o" + folder_inout + " -y; done";
      println(Command1);

      // on Windows:
      //String Command2 = "del " + folder_inout + "\\*.bz2 /q";
      String Command2 = "rm " + folder_inout + "/*.bz2";
      println(Command2);

      try {
        // on Windows:
        //launch(Command1 + " & " + Command2);
        exec(Command1 + " && " + Command2);
      }
      catch (Exception e) {
        println(e);
      }
    }

    Files_ENSEMBLE_FORECAST = OPESYS.getFiles(Folder_ENSEMBLE_FORECAST);

    ENSEMBLE_FORECAST_load = true;
    update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);
  }
}
