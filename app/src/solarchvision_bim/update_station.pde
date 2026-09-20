void SOLARCHVISION_update_station (int Step) {

  if ((Step == -1) || (Step == 0)) {
    allWindRoses.rebuild_Image_array = true;
    allSolarImpacts.rebuild_Image_array = true;

    allSolarImpacts.sectionType = 0; // Turn off analysis. It should be prebaked first.

    WORLD.revise();
    STUDY.revise();
    SOLARCHVISION_view_changed();

    LocationLAT = STATION.getLatitude();
    LocationLON = STATION.getLongitude();

    WORLD.VIEW_id = WORLD.FindGoodViewport(LocationLON, LocationLAT);

    TIME.beginDay = TIME.convert2Date(TIME.month, TIME.day);
  }

  if ((Step == -1) || (Step == 1)) update_CLIMATE_TMYEPW();

  if ((Step == -1) || (Step == 2)) update_CLIMATE_CWEEDS();

  if ((Step == -1) || (Step == 3)) update_CLIMATE_CLMREC();

  if ((Step == -1) || (Step == 4)) update_ENSEMBLE_OBSERVED(TIME.year, TIME.month, TIME.day, TIME.hour);

  if ((Step == -1) || (Step == 5)) update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);

  if ((Step == -1) || (Step == 6)) Land3D.update_mesh();

  if ((Step == -1) || (Step == 0)) {
    if (WIN3D.FacesShade == SHADE.Vertex_Solar) {
      SOLARCHVISION_calculate_VertexSolar_array();
    }

    if (
      WIN3D.FacesShade == SHADE.Vertex_Solar || // to render sky
      WIN3D.FacesShade == SHADE.Global_Solar
    ) {
      SOLARCHVISION_calculate_GlobalSolar_array();
    }
  }
}
