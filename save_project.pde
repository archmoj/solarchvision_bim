void SOLARCHVISION_save_project (String myFile) {

  myFile = myFile.replace(char(92), '/');

  save_folder = myFile.substring(0, myFile.lastIndexOf("/"));

  XML xml = parseXML("<?xml version='1.0' encoding='UTF-8'?>" + char(13) + "<empty>" + char(13) + "</empty>");

  xml.setName("SOLARCHVISION_" + SOLARCHVISION_version + "_project");

  {
    XML parent = xml.addChild("SOLARCHVISION_variables");

    XML_setInt(parent, "current_ObjectCategory", current_ObjectCategory);

    XML_setFloat(parent, "GlobalAlbedo", GlobalAlbedo);
    XML_setFloat(parent, "Interpolation_Weight", Interpolation_Weight);

    XML_setInt(parent, "CLIMATIC_SolarForecast", CLIMATIC_SolarForecast);
    XML_setInt(parent, "CLIMATIC_WeatherForecast", CLIMATIC_WeatherForecast);
    XML_setInt(parent, "SOLARCHVISION_automated", SOLARCHVISION_automated);

    XML_setInt(parent, "CLIMATE_TMYEPW_start", CLIMATE_TMYEPW_start);
    XML_setInt(parent, "CLIMATE_TMYEPW_end", CLIMATE_TMYEPW_end);
    XML_setInt(parent, "CLIMATE_CWEEDS_start", CLIMATE_CWEEDS_start);
    XML_setInt(parent, "CLIMATE_CWEEDS_end", CLIMATE_CWEEDS_end);
    XML_setInt(parent, "CLIMATE_CLMREC_start", CLIMATE_CLMREC_start);
    XML_setInt(parent, "CLIMATE_CLMREC_end", CLIMATE_CLMREC_end);
    XML_setInt(parent, "ENSEMBLE_FORECAST_start", ENSEMBLE_FORECAST_start);
    XML_setInt(parent, "ENSEMBLE_FORECAST_end", ENSEMBLE_FORECAST_end);
    XML_setInt(parent, "ENSEMBLE_FORECAST_maxDays", ENSEMBLE_FORECAST_maxDays);
    XML_setInt(parent, "ENSEMBLE_OBSERVED_maxDays", ENSEMBLE_OBSERVED_maxDays);
    XML_setInt(parent, "ENSEMBLE_OBSERVED_numNearest", ENSEMBLE_OBSERVED_numNearest);
    XML_setInt(parent, "ENSEMBLE_OBSERVED_start", ENSEMBLE_OBSERVED_start);
    XML_setInt(parent, "ENSEMBLE_OBSERVED_end", ENSEMBLE_OBSERVED_end);
    XML_setInt(parent, "SampleYear_Start", SampleYear_Start);
    XML_setInt(parent, "SampleYear_End", SampleYear_End);
    XML_setInt(parent, "SampleMember_Start", SampleMember_Start);
    XML_setInt(parent, "SampleMember_End", SampleMember_End);
    XML_setInt(parent, "SampleStation_Start", SampleStation_Start);
    XML_setInt(parent, "SampleStation_End", SampleStation_End);
    XML_setBoolean(parent, "CLIMATE_TMYEPW_load", CLIMATE_TMYEPW_load);
    XML_setBoolean(parent, "CLIMATE_CWEEDS_load", CLIMATE_CWEEDS_load);
    XML_setBoolean(parent, "CLIMATE_CLMREC_load", CLIMATE_CLMREC_load);
    XML_setBoolean(parent, "ENSEMBLE_FORECAST_load", ENSEMBLE_FORECAST_load);
    XML_setBoolean(parent, "ENSEMBLE_OBSERVED_load", ENSEMBLE_OBSERVED_load);
    XML_setInt(parent, "Develop_Option", Develop_Option);
    XML_setInt(parent, "Develop_DayHour", Develop_DayHour);
    XML_setBoolean(parent, "DevelopData_update", DevelopData_update);
    XML_setInt(parent, "numberOfLayers", numberOfLayers);

    XML_setFloat(parent, "Develop_AngleInclination", Develop_AngleInclination);
    XML_setFloat(parent, "Develop_AngleOrientation", Develop_AngleOrientation);
    XML_setInt(parent, "DevelopLayer_id", DevelopLayer_id);
    XML_setInt(parent, "CurrentLayer_id", CurrentLayer_id);


    XML_setInt(parent, "Impact_TYPE", Impact_TYPE);

    XML_setInt(parent, "COLOR_STYLE_Current", COLOR_STYLE_Current);
    XML_setInt(parent, "COLOR_STYLE_Number", COLOR_STYLE_Number);

    XML_setInt(parent, "CurrentDataSource", CurrentDataSource);
    XML_setInt(parent, "DrawnFrame", DrawnFrame);



    XML_setFloat(parent, "Planetary_Magnification", Planetary_Magnification);


    //XML_setInt(parent, "Camera_Variation", Camera_Variation);

    XML_setInt(parent, "allMaterials.Selection", allMaterials.Selection);
    XML_setFloat(parent, "OBJECTS_scale", OBJECTS_scale);

    XML_setInt(parent, "FrameVariation", FrameVariation);
    XML_setInt(parent, "Language_Active", Language_Active);

    XML_setInt(parent, "IMPACTS_displayDay", IMPACTS_displayDay);

    XML_setFloat(parent, "BIOSPHERE_drawResolution", BIOSPHERE_drawResolution);

    XML_setString(parent, "Default_Font", Default_Font);
  }


  STATION.to_XML(xml);

  allPoints.to_XML(xml);

  allPolylines.to_XML(xml);

  allFaces.to_XML(xml);

  allCameras.to_XML(xml);

  allSolids.to_XML(xml);

  allSections.to_XML(xml);

  allModel1Ds.to_XML(xml);

  allModel2Ds.to_XML(xml);

  allGroups.to_XML(xml);

  Land3D.to_XML(xml);

  Earth3D.to_XML(xml);

  Sky3D.to_XML(xml);

  Tropo3D.to_XML(xml);

  Moon3D.to_XML(xml);

  Sun3D.to_XML(xml);

  WIN3D.to_XML(xml);

  User3D.to_XML(xml);

  Select3D.to_XML(xml);

  WORLD.to_XML(xml);

  STUDY.to_XML(xml);

  allWindRoses.to_XML(xml);

  allWindFlows.to_XML(xml);

  allSolidImpacts.to_XML(xml);

  allSolarImpacts.to_XML(xml);

  LAYER_ceilingsky.to_XML(xml);
  LAYER_cloudcover.to_XML(xml);
  LAYER_winddir.to_XML(xml);
  LAYER_windspd.to_XML(xml);
  LAYER_pressure.to_XML(xml);
  LAYER_drybulb.to_XML(xml);
  LAYER_relhum.to_XML(xml);
  LAYER_dirnorrad.to_XML(xml);
  LAYER_difhorrad.to_XML(xml);
  LAYER_glohorrad.to_XML(xml);
  LAYER_direffect.to_XML(xml);
  LAYER_difeffect.to_XML(xml);
  LAYER_precipitation.to_XML(xml);
  LAYER_developed.to_XML(xml);

  saveXML(xml, myFile);

  println("End of saving XML:", myFile);

}
