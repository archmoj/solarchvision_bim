void updateClimateArchive () {

  climateArchiveValues = new float [24][365][allLayers.length][(1 + climateArchiveEnd - climateArchiveStart)];
  climateArchiveFlags = new boolean [24][365][allLayers.length][(1 + climateArchiveEnd - climateArchiveStart)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < allLayers.length; l++) {
        java.util.Arrays.fill(climateArchiveValues[i][j][l], FLOAT_undefined);
        java.util.Arrays.fill(climateArchiveFlags[i][j][l], false);
      }
    }
  }

  if (climateArchiveShouldLoad) {

    climateArchiveNearestStationIndex = -1;
    climateArchiveNearestStationDist = FLOAT_undefined;

    for (int f = 0; f < climateArchiveCoordinates.length; f++) {

      //if (int(climateArchiveCoordinates[f].getEndyear()) == 2016)
      { // only use stations with this condition

        float _lat = climateArchiveCoordinates[f].getLatitude();
        float _lon = climateArchiveCoordinates[f].getLongitude();
        if (_lon > 180) _lon -= 360; // << important!

        float d = funcs.lon_lat_dist(_lon, _lat, STATION.getLongitude(), STATION.getLatitude());

        if (climateArchiveNearestStationDist > d) {

          climateArchiveNearestStationDist = d;
          climateArchiveNearestStationIndex = f;
        }
      }
    }


    for (int k = 0; k < (1 + climateArchiveEnd - climateArchiveStart); k++) {
      for (int m = 0; m < 12; m++) {

        int THE_YEAR = k + climateArchiveStart;
        int THE_MONTH = m + 1;

        String FN = nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + "_" + climateArchiveCoordinates[climateArchiveNearestStationIndex].getCity() + ".csv";

        String the_source = Folder_climateArchive + "/" + FN;

        File dir = new File(the_source);
        if (dir.isFile()) load_climateArchive(the_source);
        else println("FILE NOT FOUND:", the_source);

      }
    }

    setDataFlags(dataID_climateArchive);
    postProcess_fillGaps(dataID_climateArchive);
    postProcess_solarsUsingCloud(dataID_climateArchive);
    postProcess_solarEffects(dataID_climateArchive);

    WORLD.climateArchiveDisplayAll = 1;
    WORLD.climateArchiveDisplayNear = true;

  }

  WORLD.revise();
  STUDY.revise();
  UI_rollout.revise();
  UI_caseBar.revise();
  view_changed();

  sampleYearStart = climateArchiveStart;
  sampleYearEnd = climateArchiveEnd;
}
