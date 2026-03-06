void SOLARCHVISION_parse_XML_variables (XML xml, boolean desired_diag) {

  diag_XML_input = desired_diag;

  XML parent = xml.getChild("SOLARCHVISION_variables");

  current_ObjectCategory = XML_getInt(parent, "current_ObjectCategory");

  GlobalAlbedo = XML_getFloat(parent, "GlobalAlbedo");
  Interpolation_Weight = XML_getFloat(parent, "Interpolation_Weight");

  CLIMATIC_SolarForecast = XML_getInt(parent, "CLIMATIC_SolarForecast");
  CLIMATIC_WeatherForecast = XML_getInt(parent, "CLIMATIC_WeatherForecast");
  SOLARCHVISION_automated = XML_getInt(parent, "SOLARCHVISION_automated");

  CLIMATE_TMYEPW_start = XML_getInt(parent, "CLIMATE_TMYEPW_start");
  CLIMATE_TMYEPW_end = XML_getInt(parent, "CLIMATE_TMYEPW_end");
  CLIMATE_CWEEDS_start = XML_getInt(parent, "CLIMATE_CWEEDS_start");
  CLIMATE_CWEEDS_end = XML_getInt(parent, "CLIMATE_CWEEDS_end");
  CLIMATE_CLMREC_start = XML_getInt(parent, "CLIMATE_CLMREC_start");
  CLIMATE_CLMREC_end = XML_getInt(parent, "CLIMATE_CLMREC_end");
  ENSEMBLE_FORECAST_start = XML_getInt(parent, "ENSEMBLE_FORECAST_start");
  ENSEMBLE_FORECAST_end = XML_getInt(parent, "ENSEMBLE_FORECAST_end");
  ENSEMBLE_FORECAST_maxDays = XML_getInt(parent, "ENSEMBLE_FORECAST_maxDays");
  ENSEMBLE_OBSERVED_maxDays = XML_getInt(parent, "ENSEMBLE_OBSERVED_maxDays");
  ENSEMBLE_OBSERVED_numNearest = XML_getInt(parent, "ENSEMBLE_OBSERVED_numNearest");
  ENSEMBLE_OBSERVED_start = XML_getInt(parent, "ENSEMBLE_OBSERVED_start");
  ENSEMBLE_OBSERVED_end = XML_getInt(parent, "ENSEMBLE_OBSERVED_end");
  SampleYear_Start = XML_getInt(parent, "SampleYear_Start");
  SampleYear_End = XML_getInt(parent, "SampleYear_End");
  SampleMember_Start = XML_getInt(parent, "SampleMember_Start");
  SampleMember_End = XML_getInt(parent, "SampleMember_End");
  SampleStation_Start = XML_getInt(parent, "SampleStation_Start");
  SampleStation_End = XML_getInt(parent, "SampleStation_End");
  CLIMATE_TMYEPW_load = XML_getBoolean(parent, "CLIMATE_TMYEPW_load");
  CLIMATE_CWEEDS_load = XML_getBoolean(parent, "CLIMATE_CWEEDS_load");
  CLIMATE_CLMREC_load = XML_getBoolean(parent, "CLIMATE_CLMREC_load");
  ENSEMBLE_FORECAST_load = XML_getBoolean(parent, "ENSEMBLE_FORECAST_load");
  ENSEMBLE_OBSERVED_load = XML_getBoolean(parent, "ENSEMBLE_OBSERVED_load");
  Develop_Option = XML_getInt(parent, "Develop_Option");
  Develop_DayHour = XML_getInt(parent, "Develop_DayHour");
  //DevelopData_update = XML_getBoolean(parent, "DevelopData_update");
  numberOfLayers = XML_getInt(parent, "numberOfLayers");
  Develop_AngleInclination = XML_getFloat(parent, "Develop_AngleInclination");
  Develop_AngleOrientation = XML_getFloat(parent, "Develop_AngleOrientation");
  DevelopLayer_id = XML_getInt(parent, "DevelopLayer_id");

  changeCurrentLayerTo(XML_getInt(parent, "CurrentLayer_id"));

  COLOR_STYLE_Current = XML_getInt(parent, "COLOR_STYLE_Current");
  COLOR_STYLE_Number = XML_getInt(parent, "COLOR_STYLE_Number");

  CurrentDataSource = XML_getInt(parent, "CurrentDataSource");
  DrawnFrame = XML_getInt(parent, "DrawnFrame");

  Planetary_Magnification = XML_getFloat(parent, "Planetary_Magnification");

  Camera_Variation = XML_getInt(parent, "Camera_Variation");

  allMaterials.Selection = XML_getInt(parent, "allMaterials.Selection");
  OBJECTS_scale = XML_getFloat(parent, "OBJECTS_scale");

  FrameVariation = XML_getInt(parent, "FrameVariation");
  Language_Active = XML_getInt(parent, "Language_Active");

  IMPACTS_displayDay = XML_getInt(parent, "IMPACTS_displayDay");

  BIOSPHERE_drawResolution = XML_getFloat(parent, "BIOSPHERE_drawResolution");

  String new_Default_Font = XML_getString(parent, "Default_Font");
  if (Default_Font.equals(new_Default_Font)) {
  } else {
    Default_Font = new_Default_Font;
    SOLARCHVISION_loadDefaultFontStyle();
  }


  STATION.from_XML(xml);

  allPoints.from_XML(xml);

  allPolylines.from_XML(xml);

  allFaces.from_XML(xml);

  allCameras.from_XML(xml);

  allSolids.from_XML(xml);

  allSections.from_XML(xml);

  allModel1Ds.from_XML(xml);

  allModel2Ds.from_XML(xml);

  allGroups.from_XML(xml); // Note: Groups should be inputted after Faces, Polylines, Model1Ds, Model2Ds, etc.

  Land3D.from_XML(xml);

  Earth3D.from_XML(xml);

  Sky3D.from_XML(xml);

  Tropo3D.from_XML(xml);

  Moon3D.from_XML(xml);

  Sun3D.from_XML(xml);

  WIN3D.from_XML(xml);

  User3D.from_XML(xml);

  Select3D.from_XML(xml);

  WORLD.from_XML(xml);

  STUDY.from_XML(xml);

  allWindRoses.from_XML(xml);

  allWindFlows.from_XML(xml);

  allSolidImpacts.from_XML(xml);

  allSolarImpacts.from_XML(xml);

  LAYER_ceilingsky.from_XML(xml);
  LAYER_cloudcover.from_XML(xml);
  LAYER_winddir.from_XML(xml);
  LAYER_windspd.from_XML(xml);
  LAYER_pressure.from_XML(xml);
  LAYER_drybulb.from_XML(xml);
  LAYER_relhum.from_XML(xml);
  LAYER_dirnorrad.from_XML(xml);
  LAYER_difhorrad.from_XML(xml);
  LAYER_glohorrad.from_XML(xml);
  LAYER_direffect.from_XML(xml);
  LAYER_difeffect.from_XML(xml);
  LAYER_precipitation.from_XML(xml);
  LAYER_developed.from_XML(xml);

  println("End of loading XML");
}
