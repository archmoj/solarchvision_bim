void update_station (int Step) {

  if ((Step == -1) || (Step == 0)) {
    allWindRoses.rebuild_Image_array = true;
    allSolarImpacts.rebuild_Image_array = true;

    allSolarImpacts.sectionType = 0; // Turn off analysis. It should be prebaked first.

    WORLD.revise();
    STUDY.revise();
    view_changed();

    locationLatitude = STATION.getLatitude();
    locationLongitude = STATION.getLongitude();

    WORLD.VIEW_id = WORLD.FindGoodViewport(locationLongitude, locationLatitude);

    TIME.beginDay = TIME.convert2Date(TIME.month, TIME.day);
    sync_SHADE_DATE_ANGLE();

    // Keep already-loaded textures tracking the real lon/lat they were
    // captured at as the station moves (see land3D.pde's
    // recomputeTextureOffsets()). This is every live way the station can
    // move - the GUI spinners, clicking the map, and the SETLAT/SETLON/
    // SETLATLON/SETLONLAT commands all funnel through Step 0 - so without
    // this, textures only ever re-pan on the separate, explicit "Update
    // Station" action (Step -1) or at startup, not on a normal move.
    // Deliberately NOT the full Terrain.update_mesh() here: that re-reads
    // elevation files and reloads every texture image from disk, which is
    // too expensive to repeat on every single live edit - this is pure
    // offset math over the already-loaded texture list instead.
    Terrain.recomputeTextureOffsets();
  }

  if ((Step == -1) || (Step == 1)) update_climateTypicalYear();

  if ((Step == -1) || (Step == 2)) update_climateEngineering();

  if ((Step == -1) || (Step == 3)) updateClimateArchive();

  if ((Step == -1) || (Step == 4)) update_ensembleObservation(TIME.year, TIME.month, TIME.day, TIME.hour);

  if ((Step == -1) || (Step == 5)) update_ensembleForecast(TIME.year, TIME.month, TIME.day, TIME.hour);

  if ((Step == -1) || (Step == 6)) Terrain.update_mesh();

  if ((Step == -1) || (Step == 0)) {
    if (WIN3D.shadingMode == SHADE.Vertex_Solar) {
      calculate_VertexSolar_array();
    }

    if (
      WIN3D.shadingMode == SHADE.Vertex_Solar || // to render sky
      WIN3D.shadingMode == SHADE.Global_Solar
    ) {
      calculate_GlobalSolar_array();
    }
  }
}

// Called right after SETLAT/SETLON/SETLATLON/SETLONLAT (extraCommands.pde)
// changes STATION's own lon/lat - the one live way the station can move
// that has no station selection of its own to begin with (a map click
// always explicitly picks its own exact TMYEPW/NAEFS station via
// selectClimateTypicalYearStation()/selectEnsembleForecastStation(),
// mouseClicked.pde). Without this, a command-line move just kept
// downloading/loading Climate Typical Year/Ensemble Forecast data for
// whichever station (if any) a PRIOR map click had picked, or the
// untouched startup default, however far the move actually was
// (ebaeecd4aa92's own original bug).
//
// But re-deriving the nearest station on EVERY command-line move,
// however small, is itself what broke test/image/README.md's whole
// image-regression suite the first time this was attempted (ebaeecd4aa92,
// then reverted, a9ddae2c93cd): the "nearest" TMYEPW.csv/NAEFS-grid row
// for Toronto/Vancouver/Montreal's own hardcoded startup defaults turned
// out to be a different, same-city-different-source entry with no
// matching local file, silently blanking out the already-correct default
// data. So this only re-derives (and only actually reloads) each dataset
// once the move is big enough that oldLon/oldLat no longer counts as
// "nearby" STATION's own new position - using the exact same maxDist
// each dataset's own StationPicker (mouseClicked.pde) already uses to
// decide whether a map click landed unambiguously on one station or
// needs to ask which of several close-together ones was meant. A small
// edit (nudging a decimal place, fixing a typo) leaves the already-
// loaded station alone, exactly like a map click re-clicking the same
// marker would; an actual relocation re-derives and reloads, exactly as
// ebaeecd4aa92 intended.
//
// Climate Typical Year and Ensemble Forecast are judged and reloaded
// independently - TMYEPW stations (climateTypicalYearPicker's own 10000m)
// sit much closer together than NAEFS grid points (ensembleForecastPicker's
// own, much coarser 50000m), so a move that's "far" for one can still be
// "near" for the other.
void reloadClimateDataIfStationMovedAway (float oldLon, float oldLat) {
  float moved = funcs.lon_lat_dist(oldLon, oldLat, STATION.getLongitude(), STATION.getLatitude());

  if (moved > climateTypicalYearPicker.maxDist) {
    findClimateTypicalYearNearestStation();
    update_station(1);
  }

  if (moved > ensembleForecastPicker.maxDist) {
    findEnsembleForecastNearestStation();
    update_station(5);
  }
}
