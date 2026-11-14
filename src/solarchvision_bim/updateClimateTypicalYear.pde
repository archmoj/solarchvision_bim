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

    findClimateTypicalYearNearestStation();

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
// actual current lon/lat, instead of whatever was last set by a map click -
// selectClimateTypicalYearStation() (mouseClicked.pde) only runs on an
// explicit TMYEPW marker click, never on a command-line SETLAT/SETLON/
// SETLATLON/SETLONLAT (extraCommands.pde) move, so without this, a station
// moved only from the command line kept downloading/loading typical-year
// data for whichever city (if any) happened to be clicked before - or, for
// a fresh session that was never clicked at all, STATION's own hardcoded
// startup default (globalVariables.pde), whose climateTypicalYearDownload
// is left blank there - silently the wrong location (or no download link
// at all), not even an empty/missing-file error to notice in the first
// case. findNearestStation() (mouseClicked.pde) is the same plain
// nearest-of-coords lookup already used for every other dataset's own
// "quiet nearest station" bookkeeping there.
//
// Guarded against climateTypicalYearCoordinates still being null/empty -
// loadClimateTypicalYearCoordinates() (inputClimateTypicalYearCoordinates
// .pde) populates it once at real startup, but any code path that drives
// update_station()/update_climateTypicalYear() without that having run
// yet (confirmed directly: UndoRedoStationTest's restoreProjectStation
// Snapshot()/undoStationChange() tests, which construct the sketch and
// exercise update_station(-1) without loading any coordinate files first)
// would otherwise NPE inside findNearestStation() on coords.length.
void findClimateTypicalYearNearestStation () {
  if (climateTypicalYearCoordinates == null || climateTypicalYearCoordinates.length == 0) return;

  NearestStation nearest = findNearestStation(climateTypicalYearCoordinates, STATION.getLongitude(), STATION.getLatitude());
  if (nearest.index != -1) {
    STATION.setClimateTypicalYearFilename(climateTypicalYearCoordinates[nearest.index].getClimateTypicalYearFilename());
    STATION.setClimateTypicalYearDownload(climateTypicalYearCoordinates[nearest.index].getClimateTypicalYearDownload());
  }
}
