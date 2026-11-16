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
    // Same flatness problem the four groups above just solved, one
    // level down: every setting below used to sit directly on
    // "variable" regardless of what it actually was - climate/weather
    // data-source config, the develop-layer analysis settings, and
    // ordinary display/rendering options all mixed together with no
    // grouping at all. Three named sub-elements now collect those by
    // kind; a handful of true scene-identity settings (the project's
    // own name, its active UI language, its current font) stay
    // directly on "variable" itself, same as before. Nothing here
    // changed what gets saved, how, or in what order - only which of
    // the four elements each XML_setXxx call's own "parent" argument
    // points at. See parse_XML_variables()'s matching comment for how
    // an older, pre-grouping file (no climate/layer/display children
    // under its own "variable" at all) still loads correctly.
    XML parent = xml.addChild("variable");
    XML climate = parent.addChild("climate");
    XML layer = parent.addChild("layer");
    XML display = parent.addChild("display");

    XML_setString(parent, "sceneName", SceneName);
    XML_setInt(parent, "activeLanguage", activeLanguage);
    XML_setString(parent, "currentFont", currentFont);

    XML_setInt(display, "currentObjectCategory", currentObjectCategory);

    XML_setFloat(display, "globalAlbedo", globalAlbedo);
    XML_setFloat(display, "interpolationWeight", interpolationWeight);

    XML_setInt(climate, "climateBasedSolarForecast", climateBasedSolarForecast);
    XML_setInt(climate, "climateBasedWeatherForecast", climateBasedWeatherForecast);

    XML_setInt(climate, "climateTypicalYearStart", climateTypicalYearStart);
    XML_setInt(climate, "climateTypicalYearEnd", climateTypicalYearEnd);
    XML_setInt(climate, "climateEngineeringStart", climateEngineeringStart);
    XML_setInt(climate, "climateEngineeringEnd", climateEngineeringEnd);
    XML_setInt(climate, "climateArchiveStart", climateArchiveStart);
    XML_setInt(climate, "climateArchiveEnd", climateArchiveEnd);
    XML_setInt(climate, "ensembleForecastStart", ensembleForecastStart);
    XML_setInt(climate, "ensembleForecastEnd", ensembleForecastEnd);
    XML_setInt(climate, "ensembleForecastMaxDays", ensembleForecastMaxDays);
    XML_setInt(climate, "ensembleObservationMaxDays", ensembleObservationMaxDays);
    XML_setInt(climate, "nearestWeatherStationCount", nearestWeatherStationCount);
    XML_setInt(climate, "ensembleObservationStart", ensembleObservationStart);
    XML_setInt(climate, "ensembleObservationEnd", ensembleObservationEnd);
    XML_setInt(climate, "sampleYearStart", sampleYearStart);
    XML_setInt(climate, "sampleYearEnd", sampleYearEnd);
    XML_setInt(climate, "sampleMemberStart", sampleMemberStart);
    XML_setInt(climate, "sampleMemberEnd", sampleMemberEnd);
    XML_setInt(climate, "sampleStationStart", sampleStationStart);
    XML_setInt(climate, "sampleStationEnd", sampleStationEnd);
    XML_setBoolean(climate, "climateTypicalYearShouldLoad", climateTypicalYearShouldLoad);
    XML_setBoolean(climate, "climateEngineeringShouldLoad", climateEngineeringShouldLoad);
    XML_setBoolean(climate, "climateArchiveShouldLoad", climateArchiveShouldLoad);
    XML_setBoolean(climate, "ensembleForecastShouldLoad", ensembleForecastShouldLoad);
    XML_setBoolean(climate, "ensembleObservationShouldLoad", ensembleObservationShouldLoad);
    XML_setInt(climate, "currentDataSource", currentDataSource);

    XML_setInt(layer, "developLayerOption", developLayerOption);
    XML_setInt(layer, "developLayerInterval", developLayerInterval);
    XML_setBoolean(layer, "developDataUpdate", developDataUpdate);

    XML_setFloat(layer, "developLayerAngleInclination", developLayerAngleInclination);
    XML_setFloat(layer, "developLayerAngleOrientation", developLayerAngleOrientation);
    XML_setInt(layer, "developLayerId", developLayerId);
    XML_setInt(layer, "currentLayerId", currentLayerId);

    XML_setInt(display, "currentColorStyle", currentColorStyle);
    XML_setInt(display, "colorStyleCount", colorStyleCount);



    XML_setFloat(display, "celestialMagnification", celestialMagnification);


    //XML_setInt(display, "cameraIndex", cameraIndex);

    XML_setInt(display, "materialSelection", allMaterials.Selection);
    XML_setFloat(display, "overallScale", overallScale);
    XML_setFloat(display, "faceToSectionLift", FACE_TO_SECTION_LIFT);

    XML_setInt(display, "viewLayout", viewLayout);

    XML_setInt(display, "impactDisplayDay", impactDisplayDay);
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
