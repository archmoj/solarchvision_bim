void update_climateTmyEpw () {

  climateTmyEpw_values = new float [24][365][allLayers.length][(1 + climateTypicalYearEnd - climateTypicalYearStart)];
  climateTmyEpw_flags = new boolean [24][365][allLayers.length][(1 + climateTypicalYearEnd - climateTypicalYearStart)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < allLayers.length; l++) {
        for (int k = 0; k < (1 + climateTypicalYearEnd - climateTypicalYearStart); k++) {
          climateTmyEpw_values[i][j][l][k] = FLOAT_undefined;
          climateTmyEpw_flags[i][j][l][k] = false;
        }
      }
    }
  }

  if (climateTypicalYearShouldLoad) {

    String FN = STATION.getClimateTypicalYearFilename() + ".epw";

    String the_source = Folder_climateTmyEpw + "/" + FN;

    File dir = new File(the_source);
    if (dir.isFile()) load_climateTmyEpw(the_source);
    else println("FILE NOT FOUND:", the_source);

    WORLD.climateTypicalYearDisplayAll = 1;
    WORLD.climateTypicalYearDisplayNear = true;

  }

  WORLD.revise();
  STUDY.revise();
  UI_rollout.revise();
  UI_caseBar.revise();
  view_changed();

}
