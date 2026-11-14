void update_ensembleForecast (int THE_YEAR, int THE_MONTH, int THE_DAY, int THE_HOUR) {

  ensembleForecastValues = new float [24][365][allLayers.length][(1 + ensembleForecastEnd - ensembleForecastStart)];
  ensembleForecastFlags = new boolean [24][365][allLayers.length][(1 + ensembleForecastEnd - ensembleForecastStart)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < allLayers.length; l++) {
        for (int k = 0; k < (1 + ensembleForecastEnd - ensembleForecastStart); k++) {
          ensembleForecastValues[i][j][l][k] = FLOAT_undefined;
          ensembleForecastFlags[i][j][l][k] = false;
        }
      }
    }
  }

  if (ensembleForecastShouldLoad) {

    findEnsembleForecastNearestStation();

    for (int f = 0; f < allLayers.length; f++) {
      if (allLayers[f].name.equals("")) {
      } else {
        String FN = nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + nf(THE_DAY, 2) + nf(THE_HOUR, 2) + "_GEPS-NAEFS-RAW_" + STATION.getEnsembleForecastFilename() + "_" + allLayers[f].name + "_000-384.xml";

        String the_source = Folder_ensembleForecast + "/" + FN;

        File dir = new File(the_source);
        if (dir.isFile()) load_ensembleForecast(the_source, f);
        else println("\nFILE NOT FOUND:", the_source);
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

// Keeps STATION's own ensembleForecastFilename (the NAEFS grid-point name
// its download/load filenames are built from, above and in
// downloadEnsembleForecast.pde) tracking STATION's actual current lon/lat,
// instead of whatever was last set by a map click - selectEnsembleForecast
// Station() (mouseClicked.pde) only runs on an explicit NAEFS marker click,
// never on a command-line SETLAT/SETLON/SETLATLON/SETLONLAT (extraCommands.
// pde) move, so without this, a station moved only from the command line
// kept downloading/loading forecast data for whichever grid point (if any)
// happened to be clicked before - silently the wrong location, not even an
// empty/missing-file error to notice. findNearestStation() (mouseClicked.
// pde) is the same plain nearest-of-coords lookup already used for every
// other dataset's own "quiet nearest station" bookkeeping there.
//
// Guarded against ensembleForecastCoordinates still being null/empty -
// loadEnsembleForecastCoordinates() (inputEnsembleForecastCoordinates.pde)
// populates it once at real startup, but any code path that drives
// update_station()/update_ensembleForecast() without that having run yet
// (confirmed directly: UndoRedoStationTest's restoreProjectStationSnapshot
// ()/undoStationChange() tests, which construct the sketch and exercise
// update_station(-1) without loading any coordinate files first) would
// otherwise NPE inside findNearestStation() on coords.length.
void findEnsembleForecastNearestStation () {
  if (ensembleForecastCoordinates == null || ensembleForecastCoordinates.length == 0) return;

  NearestStation nearest = findNearestStation(ensembleForecastCoordinates, STATION.getLongitude(), STATION.getLatitude());
  if (nearest.index != -1) {
    STATION.setEnsembleForecastFilename(ensembleForecastCoordinates[nearest.index].getEnsembleForecastFilename());
  }
}
