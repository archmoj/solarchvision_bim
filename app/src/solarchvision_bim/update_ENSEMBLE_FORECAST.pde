void update_ENSEMBLE_FORECAST (int THE_YEAR, int THE_MONTH, int THE_DAY, int THE_HOUR) {

  ENSEMBLE_FORECAST_values = new float [24][365][allLayers.length][(1 + ENSEMBLE_FORECAST_end - ENSEMBLE_FORECAST_start)];
  ENSEMBLE_FORECAST_flags = new boolean [24][365][allLayers.length][(1 + ENSEMBLE_FORECAST_end - ENSEMBLE_FORECAST_start)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < allLayers.length; l++) {
        for (int k = 0; k < (1 + ENSEMBLE_FORECAST_end - ENSEMBLE_FORECAST_start); k++) {
          ENSEMBLE_FORECAST_values[i][j][l][k] = FLOAT_undefined;
          ENSEMBLE_FORECAST_flags[i][j][l][k] = false;
        }
      }
    }
  }

  if (ENSEMBLE_FORECAST_load) {

    for (int f = 0; f < allLayers.length; f++) {
      if (allLayers[f].name.equals("")) {
      } else {
        String FN = nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + nf(THE_DAY, 2) + nf(THE_HOUR, 2) + "_GEPS-NAEFS-RAW_" + STATION.getFilename_NAEFS() + "_" + allLayers[f].name + "_000-384.xml";

        String the_source = Folder_ENSEMBLE_FORECAST + "/" + FN;

        File dir = new File(the_source);
        if (dir.isFile()) load_ENSEMBLE_FORECAST(the_source, f);
        else println("FILE NOT FOUND:", the_source);
      }
    }

    setDataFlags(dataID_ENSEMBLE_FORECAST);
    postProcess_fillGaps(dataID_ENSEMBLE_FORECAST);
    if (CLIMATIC_SolarForecast == 1) {
      postProcess_climaticSolarForecast();
    }
    else {
      postProcess_solarsUsingCloud(dataID_ENSEMBLE_FORECAST);
    }
    postProcess_solarEffects(dataID_ENSEMBLE_FORECAST);
    postProcess_developDATA(dataID_ENSEMBLE_FORECAST);

    WORLD.displayAll_NAEFS = 1;
    WORLD.displayNear_NAEFS = true;
  }

  WORLD.revise();
  STUDY.revise();
  UI_rollout.revise();
  UI_caseBar.revise();
  view_changed();

  SampleMember_Start = ENSEMBLE_FORECAST_start;
  SampleMember_End = ENSEMBLE_FORECAST_end;
}
