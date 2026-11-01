void update_climateEngineering () {

  climateEngineeringValues = new float [24][365][allLayers.length][(1 + climateEngineeringEnd - climateEngineeringStart)];
  climateEngineeringFlags = new boolean [24][365][allLayers.length][(1 + climateEngineeringEnd - climateEngineeringStart)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < allLayers.length; l++) {
        java.util.Arrays.fill(climateEngineeringValues[i][j][l], FLOAT_undefined);
        java.util.Arrays.fill(climateEngineeringFlags[i][j][l], false);
      }
    }
  }


  if (climateEngineeringShouldLoad) {

    String FN = STATION.getClimateEngineeringFilename() + ".WY3";

    String the_source = Folder_climateEngineering + "/" + FN;

    File dir = new File(the_source);
    if (dir.isFile()) load_climateEngineering(the_source);
    else println("FILE NOT FOUND:", the_source);

  }

  WORLD.revise();
  STUDY.revise();
  UI_rollout.revise();
  UI_caseBar.revise();
  view_changed();

  sampleYearStart = climateEngineeringStart;
  sampleYearEnd = climateEngineeringEnd;
}
