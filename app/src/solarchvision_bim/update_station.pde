void update_station (int Step) {

  if ((Step == -1) || (Step == 0)) {
    allWindRoses.rebuild_Image_array = true;
    allSolarImpacts.rebuild_Image_array = true;

    allSolarImpacts.sectionType = 0; // Turn off analysis. It should be prebaked first.

    WORLD.revise();
    STUDY.revise();
    view_changed();

    LocationLAT = STATION.getLatitude();
    LocationLON = STATION.getLongitude();

    WORLD.VIEW_id = WORLD.FindGoodViewport(LocationLON, LocationLAT);

    TIME.beginDay = TIME.convert2Date(TIME.month, TIME.day);
  }

  if ((Step == -1) || (Step == 1)) update_climateTmyEpw();

  if ((Step == -1) || (Step == 2)) update_climateEngineering();

  if ((Step == -1) || (Step == 3)) updateClimateArchive();

  if ((Step == -1) || (Step == 4)) update_ensembleObservation(TIME.year, TIME.month, TIME.day, TIME.hour);

  if ((Step == -1) || (Step == 5)) update_ensembleForecast(TIME.year, TIME.month, TIME.day, TIME.hour);

  if ((Step == -1) || (Step == 6)) Land3D.update_mesh();

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
