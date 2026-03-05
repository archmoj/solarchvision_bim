void update_CLIMATE_CWEEDS () {

  CLIMATE_CWEEDS_values = new float [24][365][numberOfLayers][(1 + CLIMATE_CWEEDS_end - CLIMATE_CWEEDS_start)];
  CLIMATE_CWEEDS_flags = new boolean [24][365][numberOfLayers][(1 + CLIMATE_CWEEDS_end - CLIMATE_CWEEDS_start)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < numberOfLayers; l++) {
        for (int k = 0; k < (1 + CLIMATE_CWEEDS_end - CLIMATE_CWEEDS_start); k++) {
          CLIMATE_CWEEDS_values[i][j][l][k] = FLOAT_undefined;
          CLIMATE_CWEEDS_flags[i][j][l][k] = false;
        }
      }
    }
  }


  if (CLIMATE_CWEEDS_load) {

    String FN = STATION.getFilename_CWEEDS() + ".WY3";

    String the_source = Folder_CLIMATE_CWEEDS + "/" + FN;

    File dir = new File(the_source);
    if (dir.isFile()) load_CLIMATE_CWEEDS(the_source);
    else println("FILE NOT FOUND:", the_source);

  }

  WORLD.revise();
  STUDY.revise();
  ROLLOUT.revise();
  UI_caseBar.revise();
  SOLARCHVISION_view_changed();

  SampleYear_Start = CLIMATE_CWEEDS_start;
  SampleYear_End = CLIMATE_CWEEDS_end;
}
