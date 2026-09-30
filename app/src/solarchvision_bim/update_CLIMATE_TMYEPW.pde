void update_climateTypicalYear () {

  climateTypicalYearValues = new float [24][365][allLayers.length][(1 + climateTypicalYearEnd - climateTypicalYearStart)];
  climateTypicalYearFlags = new boolean [24][365][allLayers.length][(1 + climateTypicalYearEnd - climateTypicalYearStart)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < allLayers.length; l++) {
        for (int k = 0; k < (1 + climateTypicalYearEnd - climateTypicalYearStart); k++) {
          climateTypicalYearValues[i][j][l][k] = FLOAT_undefined;
          climateTypicalYearFlags[i][j][l][k] = false;
        }
      }
    }
  }

  if (climateTypicalYearShouldLoad) {

    String FN = STATION.getClimateTypicalYearFilename() + ".epw";

    String the_source = Folder_climateTypicalYear + "/" + FN;

    File dir = new File(the_source);
    if (dir.isFile()) load_climateTypicalYear(the_source);
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
