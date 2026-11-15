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
    else println("\nFILE NOT FOUND:", the_source);

    WORLD.climateTypicalYearDisplayAll = 1;
    WORLD.climateTypicalYearDisplayNear = true;

  }

  WORLD.revise();
  STUDY.revise();
  UI_rollout.revise();
  UI_caseBar.revise();
  view_changed();

}

// Keeps STATION's own climateTypicalYearFilename/climateTypicalYearDownload
// (the EPW file its download/load filenames and download link are built
// from, above and in downloadClimateTypicalYearD.pde) tracking STATION's
// actual current lon/lat, instead of whatever was last set by a map click.
// findNearestStation() (mouseClicked.pde) is the same plain nearest-of-
// coords lookup already used for every other dataset's own "quiet nearest
// station" bookkeeping there.
//
// NOT called from update_climateTypicalYear() above, and not on every
// load - only from reloadClimateDataIfStationMovedAway() (extraCommands
// .pde), itself only called right after a command-line SETLAT/SETLON/
// SETLATLON/SETLONLAT move, and only once that move's own distance
// exceeds climateTypicalYearPicker's own "nearby" threshold (mouseClicked
// .pde). An earlier version of this fix (ebaeecd4aa92, reverted in
// a9ddae2c93cd) called this unconditionally on every load instead - which
// also fires at ordinary startup (climateTypicalYearShouldLoad defaults
// to true), on the "Load Climate Typical Year" action, after a completed
// download, and on an explicit TMYEPW marker click, none of which
// represent an actual relocation, and each of which already has the
// right filename set some other way (STATION's own hardcoded startup
// default, or selectClimateTypicalYearStation()'s own direct assignment,
// mouseClicked.pde). Calling this on every one of those silently
// overwrote even those already-correct filenames with whatever TMYEPW
// .csv row the real-world download-coordinates list happens to consider
// nearest - which, for the hardcoded Toronto/Vancouver/Montreal startup
// defaults specifically, is a DIFFERENT, same-city-different-source row
// (TMYEPW.csv carries several near-duplicate Custom/NRC2022v1/SRC-TMYx
// entries per city, at slightly different coordinates, none matching the
// handful of CWEC files actually bundled under input/climate/TMYEPW/) -
// so every image-regression test that depends on this data (test/image/
// README.md) silently started loading blank/undefined climate data
// ("FILE NOT FOUND" above) instead. Gating this on an actual, large-
// enough move (reloadClimateDataIfStationMovedAway()'s own comment) means
// a small command-line nudge leaves the already-loaded station alone,
// exactly like every other non-relocation load above already does,
// while a real relocation still re-derives and reloads, same as intended.
//
// Guarded against climateTypicalYearCoordinates still being null/empty -
// loadClimateTypicalYearCoordinates() (inputClimateTypicalYearCoordinates
// .pde) populates it once at real startup, but any code path that drives
// this without that having run yet would otherwise NPE on coords.length.
void findClimateTypicalYearNearestStation () {
  if (climateTypicalYearCoordinates == null || climateTypicalYearCoordinates.length == 0) return;

  NearestStation nearest = findNearestStation(climateTypicalYearCoordinates, STATION.getLongitude(), STATION.getLatitude());
  if (nearest.index != -1) {
    STATION.setClimateTypicalYearFilename(climateTypicalYearCoordinates[nearest.index].getClimateTypicalYearFilename());
    STATION.setClimateTypicalYearDownload(climateTypicalYearCoordinates[nearest.index].getClimateTypicalYearDownload());
  }
}
