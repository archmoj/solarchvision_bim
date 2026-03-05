void update_CLIMATE_TMYEPW () {

  CLIMATE_TMYEPW_values = new float [24][365][numberOfLayers][(1 + CLIMATE_TMYEPW_end - CLIMATE_TMYEPW_start)];
  CLIMATE_TMYEPW_flags = new boolean [24][365][numberOfLayers][(1 + CLIMATE_TMYEPW_end - CLIMATE_TMYEPW_start)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < numberOfLayers; l++) {
        for (int k = 0; k < (1 + CLIMATE_TMYEPW_end - CLIMATE_TMYEPW_start); k++) {
          CLIMATE_TMYEPW_values[i][j][l][k] = FLOAT_undefined;
          CLIMATE_TMYEPW_flags[i][j][l][k] = false;
        }
      }
    }
  }

  if (CLIMATE_TMYEPW_load) {

    String FN = STATION.getFilename_TMYEPW() + ".epw";

    String the_source = Folder_CLIMATE_TMYEPW + "/" + FN;

    File dir = new File(the_source);
    if (dir.isFile()) load_CLIMATE_TMYEPW(the_source);
    else println("FILE NOT FOUND:", the_source);

    WORLD.displayAll_TMYEPW = 1;
    WORLD.displayNear_TMYEPW = true;

  }

  WORLD.revise();
  STUDY.revise();
  ROLLOUT.revise();
  UI_caseBar.revise();
  SOLARCHVISION_view_changed();

}
