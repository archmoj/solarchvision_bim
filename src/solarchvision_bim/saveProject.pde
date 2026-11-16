void saveProject (String myFile) {

  // See isFileOperationInProgress's own comment (globalFunctions.pde)
  // for why - bare statement (this function has only the one exit
  // point below, so nothing further to guard); cleared at this
  // function's own end. Covers every caller the same way: the "Save"
  // action, holdProject() ("Hold", and "New"'s own pre-clear backup),
  // _fileSelected_SaveAs() ("Save As"), and extraCommands.pde's own
  // console "save" command.
  isFileOperationInProgress = true;

  myFile = myFile.replace(char(92), '/');

  save_folder = myFile.substring(0, myFile.lastIndexOf("/"));

  XML xml = buildProjectSnapshot(true);

  saveXML(xml, myFile);

  println("End of saving XML:", myFile);

  isFileOperationInProgress = false;
}

// Builds the exact same XML tree saveProject() writes to disk, entirely
// in memory - the one shared list of "everything that makes up a
// project" that every full-state consumer goes through: file Save (via
// saveProject() above) and Hold/Fetch (via saveProject() too). The
// undo/redo snapshot stack (undoRedo.pde) deliberately does NOT go
// through this - it only ever needs the 3D-modeling content itself, a
// narrower list that undoRedo.pde's own buildUndoSnapshot() keeps
// separately; see that function's own comment for why.
//
// copyTexturesAlongside is passed straight through to Terrain.to_XML() -
// see that method's own comment; every other class's to_XML() is pure
// serialization and takes no such flag.
XML buildProjectSnapshot (boolean copyTexturesAlongside) {

  XML xml = parseXML("<?xml version='1.0' encoding='UTF-8'?>" + char(13) + "<empty>" + char(13) + "</empty>");

  xml.setName("solarchvisionV" + version);

  {
    XML parent = xml.addChild("variable");

    XML_setString(parent, "sceneName", SceneName);

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

    XML_setInt(parent, "materialSelection", allMaterials.Selection);
    XML_setFloat(parent, "overallScale", overallScale);

    XML_setInt(parent, "viewLayout", viewLayout);
    XML_setInt(parent, "activeLanguage", activeLanguage);

    XML_setInt(parent, "impactDisplayDay", impactDisplayDay);

    XML_setString(parent, "currentFont", currentFont);
  }


  // Four named group elements collect the ~25 previously-flat top-level
  // siblings by what they actually are, instead of every class landing
  // as an unrelated sibling of every other one directly under the
  // document root (the same flatness Layers used to have on its own,
  // one level up - see layer.pde's own comment on that). Each group is
  // created unconditionally, every save, and handed to its members'
  // own to_XML(xml) exactly as the bare root used to be - no class's
  // own to_XML() changed at all, only which XML node it's told to add
  // its own CLASS_STAMP child(ren) under. Call ORDER below is
  // deliberately identical to before this grouping existed (e.g.
  // allCameras still runs where it always has, between allFaces and
  // allSolids) - only the destination argument of each call changed -
  // so nothing that depends on execution order (groups.pde's own
  // "Groups should be inputted after Faces, Polylines, ..." note,
  // in particular) is affected. See parse_XML_variables()'s matching
  // comment for how an older, pre-grouping save file still loads
  // correctly despite never having these four elements at all.
  XML geometryGroup = xml.addChild("geometry");
  XML environmentGroup = xml.addChild("environment");
  XML viewGroup = xml.addChild("view");
  XML impactsGroup = xml.addChild("impacts");

  STATION.to_XML(xml);

  allPoints.to_XML(geometryGroup);

  allPolylines.to_XML(geometryGroup);

  allFaces.to_XML(geometryGroup);

  allCameras.to_XML(viewGroup);

  allSolids.to_XML(geometryGroup);

  allSections.to_XML(geometryGroup);

  allModel1Ds.to_XML(geometryGroup);

  allModel2Ds.to_XML(geometryGroup);

  allGroups.to_XML(geometryGroup);

  Terrain.to_XML(environmentGroup, copyTexturesAlongside);

  Earth3D.to_XML(environmentGroup);

  Sky3D.to_XML(environmentGroup);

  Tropo3D.to_XML(environmentGroup);

  Moon3D.to_XML(environmentGroup);

  Sun3D.to_XML(environmentGroup);

  WIN3D.to_XML(viewGroup);

  User3D.to_XML(viewGroup);

  Select3D.to_XML(viewGroup);

  WORLD.to_XML(xml);

  STUDY.to_XML(xml);

  allWindRoses.to_XML(impactsGroup);

  allWindFlows.to_XML(impactsGroup);

  allSolidImpacts.to_XML(impactsGroup);

  allSolarImpacts.to_XML(impactsGroup);

  for (int i = 0; i < allLayers.length; i++) {
    allLayers[i].to_XML(geometryGroup);
  }

  return xml;
}


String save_folder = "";

void holdProject () {

  HoldStamp = nf(millis(), 0);

  String myFile = Folder_Project + "/Temp/" + ProjectName + "_tmp" + HoldStamp + ".xml";

  saveProject(myFile);
}

void fetchProject () {

  String myFile = Folder_Project + "/Temp/" + ProjectName + "_tmp" + HoldStamp + ".xml";

  // HoldStamp defaults to "" (globalVariables.pde) until holdProject()
  // first runs, so a Fetch with no prior Hold - same as any Fetch whose
  // held file has since been moved/deleted - points at a file that
  // simply isn't there yet. Checking that up front, rather than letting
  // load_project() -> loadXML() discover it, avoids handing an empty/
  // missing file to the XML parser: Processing's own loadXML() already
  // logs a "file is missing or inaccessible" warning straight to the
  // console for that case, and the SAX parser then throws its own
  // "Content is not allowed in prolog" on top trying to parse nothing -
  // both are harmless (the catch below has always handled it the same
  // way), but they're pure console noise for an entirely expected case.
  // This keeps that exact same fallback behavior (same message, no
  // throw) without ever reaching loadXML() in the first place.
  if (!new File(myFile).isFile()) {
    println("Cannot find the hold file:", myFile);
    return;
  }

  try {
    load_project(myFile);
  }
  catch (Exception e) {
    println("Cannot find the hold file:", myFile);
  }
}
