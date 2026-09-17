void update_CLIMATE_CWEEDS () {

  CLIMATE_CWEEDS_values = new float [24][365][numberOfLayers][(1 + CLIMATE_CWEEDS_end - CLIMATE_CWEEDS_start)];
  CLIMATE_CWEEDS_flags = new boolean [24][365][numberOfLayers][(1 + CLIMATE_CWEEDS_end - CLIMATE_CWEEDS_start)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < numberOfLayers; l++) {
        java.util.Arrays.fill(CLIMATE_CWEEDS_values[i][j][l], FLOAT_undefined);
        java.util.Arrays.fill(CLIMATE_CWEEDS_flags[i][j][l], false);
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
  UI_rollout.revise();
  UI_caseBar.revise();
  SOLARCHVISION_view_changed();

  SampleYear_Start = CLIMATE_CWEEDS_start;
  SampleYear_End = CLIMATE_CWEEDS_end;
}
