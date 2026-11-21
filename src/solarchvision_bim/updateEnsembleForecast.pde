void update_ensembleForecast (int THE_YEAR, int THE_MONTH, int THE_DAY, int THE_HOUR) {

  ensembleForecastValues = new float [24][366][allLayers.length][(1 + ensembleForecastEnd - ensembleForecastStart)];
  ensembleForecastFlags = new boolean [24][366][allLayers.length][(1 + ensembleForecastEnd - ensembleForecastStart)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 366; j++) {
      for (int l = 0; l < allLayers.length; l++) {
        for (int k = 0; k < (1 + ensembleForecastEnd - ensembleForecastStart); k++) {
          ensembleForecastValues[i][j][l][k] = FLOAT_undefined;
          ensembleForecastFlags[i][j][l][k] = false;
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
// instead of whatever was last set by a map click. findNearestStation()
// (mouseClicked.pde) is the same plain nearest-of-coords lookup already
// used for every other dataset's own "quiet nearest station" bookkeeping
// there.
//
// NOT called from update_ensembleForecast() above, and not on every
// load - only from reloadClimateDataIfStationMovedAway() (extraCommands
// .pde), itself only called right after a command-line SETLAT/SETLON/
// SETLATLON/SETLONLAT move, and only once that move's own distance
// exceeds ensembleForecastPicker's own "nearby" threshold (mouseClicked
// .pde). An earlier version of this fix (ebaeecd4aa92, reverted in
// a9ddae2c93cd) called this unconditionally on every load instead - which
// also fires at ordinary startup, on the "Load Ensemble Forecast" action,
// after a completed download, and on an explicit NAEFS marker click,
// none of which represent an actual relocation, and each of which
// already has the right filename set some other way (STATION's own
// hardcoded startup default, or selectEnsembleForecastStation()'s own
// direct assignment, mouseClicked.pde). Calling this on every one of
// those silently overwrote even those already-correct filenames with
// whatever grid-point row the real-world download-coordinates list
// happens to consider nearest - which, for the hardcoded Toronto/
// Vancouver/Montreal startup defaults specifically, is a DIFFERENT,
// same-city-different-source row with no matching local file under
// input/, breaking every image-regression test that depends on this data
// (test/image/README.md). Gating this on an actual, large-enough move
// (reloadClimateDataIfStationMovedAway()'s own comment) means a small
// command-line nudge leaves the already-loaded station alone, exactly
// like every other non-relocation load above already does, while a real
// relocation still re-derives and reloads, same as intended.
//
// Guarded against ensembleForecastCoordinates still being null/empty -
// loadEnsembleForecastCoordinates() (inputEnsembleForecastCoordinates.pde)
// populates it once at real startup, but any code path that drives this
// without that having run yet would otherwise NPE on coords.length.
void findEnsembleForecastNearestStation () {
  if (ensembleForecastCoordinates == null || ensembleForecastCoordinates.length == 0) return;

  NearestStation nearest = findNearestStation(ensembleForecastCoordinates, STATION.getLongitude(), STATION.getLatitude());
  if (nearest.index != -1) {
    STATION.setEnsembleForecastFilename(ensembleForecastCoordinates[nearest.index].getEnsembleForecastFilename());
  }
}
