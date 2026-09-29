void update_ensembleForecast (int THE_YEAR, int THE_MONTH, int THE_DAY, int THE_HOUR) {

  ensembleForecast_values = new float [24][365][allLayers.length][(1 + ensembleForecastEnd - ensembleForecastStart)];
  ensembleForecast_flags = new boolean [24][365][allLayers.length][(1 + ensembleForecastEnd - ensembleForecastStart)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < allLayers.length; l++) {
        for (int k = 0; k < (1 + ensembleForecastEnd - ensembleForecastStart); k++) {
          ensembleForecast_values[i][j][l][k] = FLOAT_undefined;
          ensembleForecast_flags[i][j][l][k] = false;
        }
      }
    }
  }

  if (ensembleForecastShouldLoad) {

    for (int f = 0; f < allLayers.length; f++) {
      if (allLayers[f].name.equals("")) {
      } else {
        String FN = nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + nf(THE_DAY, 2) + nf(THE_HOUR, 2) + "_GEPS-NAEFS-RAW_" + STATION.getEnsembleForecastFilename() + "_" + allLayers[f].name + "_000-384.xml";

        String the_source = Folder_ensembleForecast + "/" + FN;

        File dir = new File(the_source);
        if (dir.isFile()) load_ensembleForecast(the_source, f);
        else println("FILE NOT FOUND:", the_source);
      }
    }

    setDataFlags(dataID_ensembleForecast);
    postProcess_fillGaps(dataID_ensembleForecast);
    if (climateBasedSolarForecast == 1) {
      postProcess_climaticSolarForecast();
    }
    else {
      postProcess_solarsUsingCloud(dataID_ensembleForecast);
    }
    postProcess_solarEffects(dataID_ensembleForecast);
    postProcess_developDATA(dataID_ensembleForecast);

    WORLD.ensembleForecastDisplayAll = 1;
    WORLD.ensembleForecastDisplayNear = true;
  }

  WORLD.revise();
  STUDY.revise();
  UI_rollout.revise();
  UI_caseBar.revise();
  view_changed();

  sampleMemberStart = ensembleForecastStart;
  sampleMemberEnd = ensembleForecastEnd;
}
