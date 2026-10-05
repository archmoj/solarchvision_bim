void saveProject (String myFile) {

  myFile = myFile.replace(char(92), '/');

  save_folder = myFile.substring(0, myFile.lastIndexOf("/"));

  XML xml = parseXML("<?xml version='1.0' encoding='UTF-8'?>" + char(13) + "<empty>" + char(13) + "</empty>");

  xml.setName("" + version + "_project");

  {
    XML parent = xml.addChild("variables");

    XML_setInt(parent, "currentObjectCategory", currentObjectCategory);

    XML_setFloat(parent, "globalAlbedo", globalAlbedo);
    XML_setFloat(parent, "interpolationWeight", interpolationWeight);

    XML_setInt(parent, "climateBasedSolarForecast", climateBasedSolarForecast);
    XML_setInt(parent, "climateBasedWeatherForecast", climateBasedWeatherForecast);

    XML_setInt(parent, "climateTypicalYearStart", climateTypicalYearStart);
    XML_setInt(parent, "climateTypicalYearEnd", climateTypicalYearEnd);
    XML_setInt(parent, "climateEngineeringStart", climateEngineeringStart);
    XML_setInt(parent, "climateEngineeringEnd", climateEngineeringEnd);
    XML_setInt(parent, "climateArchiveStart", climateArchiveStart);
    XML_setInt(parent, "climateArchiveEnd", climateArchiveEnd);
    XML_setInt(parent, "ensembleForecastStart", ensembleForecastStart);
    XML_setInt(parent, "ensembleForecastEnd", ensembleForecastEnd);
    XML_setInt(parent, "ensembleForecastMaxDays", ensembleForecastMaxDays);
    XML_setInt(parent, "ensembleObservationMaxDays", ensembleObservationMaxDays);
    XML_setInt(parent, "nearestWeatherStationCount", nearestWeatherStationCount);
    XML_setInt(parent, "ensembleObservationStart", ensembleObservationStart);
    XML_setInt(parent, "ensembleObservationEnd", ensembleObservationEnd);
    XML_setInt(parent, "sampleYearStart", sampleYearStart);
    XML_setInt(parent, "sampleYearEnd", sampleYearEnd);
    XML_setInt(parent, "sampleMemberStart", sampleMemberStart);
    XML_setInt(parent, "sampleMemberEnd", sampleMemberEnd);
    XML_setInt(parent, "sampleStationStart", sampleStationStart);
    XML_setInt(parent, "sampleStationEnd", sampleStationEnd);
    XML_setBoolean(parent, "climateTypicalYearShouldLoad", climateTypicalYearShouldLoad);
    XML_setBoolean(parent, "climateEngineeringShouldLoad", climateEngineeringShouldLoad);
    XML_setBoolean(parent, "climateArchiveShouldLoad", climateArchiveShouldLoad);
    XML_setBoolean(parent, "ensembleForecastShouldLoad", ensembleForecastShouldLoad);
    XML_setBoolean(parent, "ensembleObservationShouldLoad", ensembleObservationShouldLoad);
    XML_setInt(parent, "developLayerOption", developLayerOption);
    XML_setInt(parent, "developLayerInterval", developLayerInterval);
    XML_setBoolean(parent, "developDataUpdate", developDataUpdate);

    XML_setFloat(parent, "developLayerAngleInclination", developLayerAngleInclination);
    XML_setFloat(parent, "developLayerAngleOrientation", developLayerAngleOrientation);
    XML_setInt(parent, "developLayerId", developLayerId);
    XML_setInt(parent, "currentLayerId", currentLayerId);

    XML_setInt(parent, "currentColorStyle", currentColorStyle);
    XML_setInt(parent, "colorStyleCount", colorStyleCount);

    XML_setInt(parent, "currentDataSource", currentDataSource);



    XML_setFloat(parent, "celestialMagnification", celestialMagnification);


    //XML_setInt(parent, "cameraIndex", cameraIndex);

    XML_setInt(parent, "allMaterials.Selection", allMaterials.Selection);
    XML_setFloat(parent, "overallScale", overallScale);

    XML_setInt(parent, "viewLayout", viewLayout);
    XML_setInt(parent, "activeLanguage", activeLanguage);

    XML_setInt(parent, "impactDisplayDay", impactDisplayDay);

    XML_setString(parent, "currentFont", currentFont);
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

  Terrain.to_XML(xml);

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

  for (int i = 0; i < allLayers.length; i++) {
    allLayers[i].to_XML(xml);
  }

  saveXML(xml, myFile);

  println("End of saving XML:", myFile);

}


String save_folder = "";

void holdProject () {

  HoldStamp = nf(millis(), 0);

  String myFile = Folder_Project + "/Temp/" + ProjectName + "_tmp" + HoldStamp + ".xml";

  saveProject(myFile);
}

void fetchProject () {

  String myFile = Folder_Project + "/Temp/" + ProjectName + "_tmp" + HoldStamp + ".xml";

  try {
    load_project(myFile);
  }
  catch (Exception e) {
    println("Cannot find the hold file:", myFile);
  }
}
