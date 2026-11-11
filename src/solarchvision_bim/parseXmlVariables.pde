// restoreViewport controls one line below: WIN3D.from_XML(xml) - the
// viewport's own live camera position/orientation/zoom, active tool,
// and shading-display settings (see viewport3D.pde's own to_XML()/
// from_XML() for the exact field list). true for Open/Fetch (restoring
// a project should bring back the view it was saved with) - both of
// load_project()'s own two call sites (loadProject.pde) pass true, so
// false is currently unreachable in production, not just the less
// common branch. The name and the original intent are still accurate
// (restore everything EXCEPT the viewport, for a caller that wants the
// person navigating right now to stay looking wherever they're
// currently looking rather than get snapped back to wherever the
// camera happened to be at some earlier/other state) - undo/redo was
// the case this was written for, but undoRedoScene3D.pde's own header
// comment confirms undo/redo deliberately bypasses parse_XML_variables()
// entirely via its own separate snapshot mechanism (restoreScene3DSnapshot())
// that never includes WIN3D's own state in the first place, so there's
// nothing for it to call this with false for. This flag is here for
// whatever future caller DOES want that behavior through this
// function specifically (a future undo/redo rewrite, say) - see
// ParseXmlVariablesTest.java's own restoreViewportFalse_... test, which
// is the only thing currently exercising this branch at all. Everything
// else parse_XML_variables() restores either way - in particular
// allCameras.from_XML() (actual camera OBJECTS placed in the scene,
// legitimate modeling content) is a completely separate call,
// unaffected by this flag.
void parse_XML_variables (XML xml, boolean desired_diag, boolean restoreViewport) {

  diag_XML_input = desired_diag;

  XML parent = xml.getChild("variable");

  SceneName = XML_getString(parent, "sceneName");

  currentObjectCategory = XML_getInt(parent, "currentObjectCategory"); // see note above - confirm separately

  globalAlbedo = XML_getFloat(parent, "globalAlbedo");
  interpolationWeight = XML_getFloat(parent, "interpolationWeight");

  climateBasedSolarForecast = XML_getInt(parent, "climateBasedSolarForecast");
  climateBasedWeatherForecast = XML_getInt(parent, "climateBasedWeatherForecast");

  climateTypicalYearStart = XML_getInt(parent, "climateTypicalYearStart");
  climateTypicalYearEnd = XML_getInt(parent, "climateTypicalYearEnd");
  climateEngineeringStart = XML_getInt(parent, "climateEngineeringStart");
  climateEngineeringEnd = XML_getInt(parent, "climateEngineeringEnd");
  climateArchiveStart = XML_getInt(parent, "climateArchiveStart");
  climateArchiveEnd = XML_getInt(parent, "climateArchiveEnd");
  ensembleForecastStart = XML_getInt(parent, "ensembleForecastStart");
  ensembleForecastEnd = XML_getInt(parent, "ensembleForecastEnd");
  ensembleForecastMaxDays = XML_getInt(parent, "ensembleForecastMaxDays");
  ensembleObservationMaxDays = XML_getInt(parent, "ensembleObservationMaxDays");
  nearestWeatherStationCount = XML_getInt(parent, "nearestWeatherStationCount");
  ensembleObservationStart = XML_getInt(parent, "ensembleObservationStart");
  ensembleObservationEnd = XML_getInt(parent, "ensembleObservationEnd");
  sampleYearStart = XML_getInt(parent, "sampleYearStart");
  sampleYearEnd = XML_getInt(parent, "sampleYearEnd");
  sampleMemberStart = XML_getInt(parent, "sampleMemberStart");
  sampleMemberEnd = XML_getInt(parent, "sampleMemberEnd");
  sampleStationStart = XML_getInt(parent, "sampleStationStart");
  sampleStationEnd = XML_getInt(parent, "sampleStationEnd");
  climateTypicalYearShouldLoad = XML_getBoolean(parent, "climateTypicalYearShouldLoad");
  climateEngineeringShouldLoad = XML_getBoolean(parent, "climateEngineeringShouldLoad");
  climateArchiveShouldLoad = XML_getBoolean(parent, "climateArchiveShouldLoad");
  ensembleForecastShouldLoad = XML_getBoolean(parent, "ensembleForecastShouldLoad");
  ensembleObservationShouldLoad = XML_getBoolean(parent, "ensembleObservationShouldLoad");
  developLayerOption = XML_getInt(parent, "developLayerOption");
  developLayerInterval = XML_getInt(parent, "developLayerInterval");
  //developDataUpdate = XML_getBoolean(parent, "developDataUpdate");
  developLayerAngleInclination = XML_getFloat(parent, "developLayerAngleInclination");
  developLayerAngleOrientation = XML_getFloat(parent, "developLayerAngleOrientation");
  developLayerId = XML_getInt(parent, "developLayerId"); // see note above - confirm separately

  changeCurrentLayerTo(XML_getInt(parent, "currentLayerId"));

  currentColorStyle = XML_getInt(parent, "currentColorStyle");
  colorStyleCount = XML_getInt(parent, "colorStyleCount");

  currentDataSource = XML_getInt(parent, "currentDataSource");

  celestialMagnification = XML_getFloat(parent, "celestialMagnification");

  cameraIndex = XML_getInt(parent, "cameraIndex");

  allMaterials.Selection = XML_getInt(parent, "materialSelection");
  overallScale = XML_getFloat(parent, "overallScale");

  viewLayout = XML_getInt(parent, "viewLayout");
  activeLanguage = XML_getInt(parent, "activeLanguage");

  impactDisplayDay = XML_getInt(parent, "impactDisplayDay");

  String new_currentFont = XML_getString(parent, "currentFont");
  if (currentFont.equals(new_currentFont)) {
  } else {
    currentFont = new_currentFont;
    loadCurrentFontStyle();
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

  Terrain.from_XML(xml);

  Earth3D.from_XML(xml);

  Sky3D.from_XML(xml);

  Tropo3D.from_XML(xml);

  Moon3D.from_XML(xml);

  Sun3D.from_XML(xml);

  if (restoreViewport) WIN3D.from_XML(xml);

  User3D.from_XML(xml);

  Select3D.from_XML(xml);

  WORLD.from_XML(xml);

  STUDY.from_XML(xml);

  allWindRoses.from_XML(xml);

  allWindFlows.from_XML(xml);

  allSolidImpacts.from_XML(xml);

  allSolarImpacts.from_XML(xml);

  for (int i = 0; i < allLayers.length; i++) {
    allLayers[i].from_XML(xml);
  }

  println("End of loading XML");
}
