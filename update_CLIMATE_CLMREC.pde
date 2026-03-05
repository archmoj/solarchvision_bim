void update_CLIMATE_CLMREC () {

  CLIMATE_CLMREC_values = new float [24][365][numberOfLayers][(1 + CLIMATE_CLMREC_end - CLIMATE_CLMREC_start)];
  CLIMATE_CLMREC_flags = new boolean [24][365][numberOfLayers][(1 + CLIMATE_CLMREC_end - CLIMATE_CLMREC_start)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < numberOfLayers; l++) {
        for (int k = 0; k < (1 + CLIMATE_CLMREC_end - CLIMATE_CLMREC_start); k++) {
          CLIMATE_CLMREC_values[i][j][l][k] = FLOAT_undefined;
          CLIMATE_CLMREC_flags[i][j][l][k] = false;
        }
      }
    }
  }

  if (CLIMATE_CLMREC_load) {

    nearest_Station_CLMREC_id = -1;
    nearest_Station_CLMREC_dist = FLOAT_undefined;

    for (int f = 0; f < CLMREC_Coordinates.length; f++) {

      //if (int(CLMREC_Coordinates[f].getEndyear()) == 2016)
      { // only use stations with this condition

        float _lat = CLMREC_Coordinates[f].getLatitude();
        float _lon = CLMREC_Coordinates[f].getLongitude();
        if (_lon > 180) _lon -= 360; // << important!

        float d = funcs.lon_lat_dist(_lon, _lat, STATION.getLongitude(), STATION.getLatitude());

        if (nearest_Station_CLMREC_dist > d) {

          nearest_Station_CLMREC_dist = d;
          nearest_Station_CLMREC_id = f;
        }
      }
    }


    for (int k = 0; k < (1 + CLIMATE_CLMREC_end - CLIMATE_CLMREC_start); k++) {
      for (int m = 0; m < 12; m++) {

        int THE_YEAR = k + CLIMATE_CLMREC_start;
        int THE_MONTH = m + 1;

        String FN = nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + "_" + CLMREC_Coordinates[nearest_Station_CLMREC_id].getCity() + ".csv";

        String the_source = Folder_CLIMATE_CLMREC + "/" + FN;

        File dir = new File(the_source);
        if (dir.isFile()) load_CLIMATE_CLMREC(the_source);
        else println("FILE NOT FOUND:", the_source);

      }
    }

    SOLARCHVISION_setDataFlags(dataID_CLIMATE_CLMREC);
    SOLARCHVISION_postProcess_fillGaps(dataID_CLIMATE_CLMREC);
    SOLARCHVISION_postProcess_solarsUsingCloud(dataID_CLIMATE_CLMREC);
    SOLARCHVISION_postProcess_solarEffects(dataID_CLIMATE_CLMREC);

    WORLD.displayAll_CLMREC = 1;
    WORLD.displayNear_CLMREC = true;

  }

  WORLD.revise();
  STUDY.revise();
  ROLLOUT.revise();
  UI_caseBar.revise();
  SOLARCHVISION_view_changed();

  SampleYear_Start = CLIMATE_CLMREC_start;
  SampleYear_End = CLIMATE_CLMREC_end;
}
