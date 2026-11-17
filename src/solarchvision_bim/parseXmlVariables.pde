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

  // Matches buildProjectSnapshot()'s own three named sub-elements of
  // "variable" (saveProject.pde) - climate/weather data-source config,
  // develop-layer analysis settings, and display/rendering options,
  // kept apart instead of every one of these ~35 unrelated settings
  // sitting as a flat sibling of every other one. A "variable" block
  // written before this grouping existed has none of these three
  // children - every setting below sat directly on "variable" itself,
  // exactly where XML_getXxx(parent, ...) still looks when the more
  // specific child isn't there. Falling back to "parent" for any
  // missing sub-element reproduces that old flat lookup exactly, so an
  // old file's real settings are still found and restored rather than
  // reset to their defaults.
  XML climate = parent.getChild("climate");
  if (climate == null) climate = parent;
  XML layer = parent.getChild("layer");
  if (layer == null) layer = parent;
  XML display = parent.getChild("display");
  if (display == null) display = parent;

  SceneName = XML_getString(parent, "sceneName");

  currentObjectCategory = XML_getInt(display, "currentObjectCategory"); // see note above - confirm separately

  globalAlbedo = XML_getFloat(display, "globalAlbedo");
  interpolationWeight = XML_getFloat(display, "interpolationWeight");

  climateBasedSolarForecast = XML_getInt(climate, "climateBasedSolarForecast");
  climateBasedWeatherForecast = XML_getInt(climate, "climateBasedWeatherForecast");

  climateTypicalYearStart = XML_getInt(climate, "climateTypicalYearStart");
  climateTypicalYearEnd = XML_getInt(climate, "climateTypicalYearEnd");
  climateEngineeringStart = XML_getInt(climate, "climateEngineeringStart");
  climateEngineeringEnd = XML_getInt(climate, "climateEngineeringEnd");
  climateArchiveStart = XML_getInt(climate, "climateArchiveStart");
  climateArchiveEnd = XML_getInt(climate, "climateArchiveEnd");
  ensembleForecastStart = XML_getInt(climate, "ensembleForecastStart");
  ensembleForecastEnd = XML_getInt(climate, "ensembleForecastEnd");
  ensembleForecastMaxDays = XML_getInt(climate, "ensembleForecastMaxDays");
  ensembleObservationMaxDays = XML_getInt(climate, "ensembleObservationMaxDays");
  nearestWeatherStationCount = XML_getInt(climate, "nearestWeatherStationCount");
  ensembleObservationStart = XML_getInt(climate, "ensembleObservationStart");
  ensembleObservationEnd = XML_getInt(climate, "ensembleObservationEnd");
  sampleYearStart = XML_getInt(climate, "sampleYearStart");
  sampleYearEnd = XML_getInt(climate, "sampleYearEnd");
  sampleMemberStart = XML_getInt(climate, "sampleMemberStart");
  sampleMemberEnd = XML_getInt(climate, "sampleMemberEnd");
  sampleStationStart = XML_getInt(climate, "sampleStationStart");
  sampleStationEnd = XML_getInt(climate, "sampleStationEnd");
  climateTypicalYearShouldLoad = XML_getBoolean(climate, "climateTypicalYearShouldLoad");
  climateEngineeringShouldLoad = XML_getBoolean(climate, "climateEngineeringShouldLoad");
  climateArchiveShouldLoad = XML_getBoolean(climate, "climateArchiveShouldLoad");
  ensembleForecastShouldLoad = XML_getBoolean(climate, "ensembleForecastShouldLoad");
  ensembleObservationShouldLoad = XML_getBoolean(climate, "ensembleObservationShouldLoad");
  developLayerOption = XML_getInt(layer, "developLayerOption");
  developLayerInterval = XML_getInt(layer, "developLayerInterval");
  //developDataUpdate = XML_getBoolean(layer, "developDataUpdate");
  developLayerAngleInclination = XML_getFloat(layer, "developLayerAngleInclination");
  developLayerAngleOrientation = XML_getFloat(layer, "developLayerAngleOrientation");
  developLayerId = XML_getInt(layer, "developLayerId"); // see note above - confirm separately

  changeCurrentLayerTo(XML_getInt(layer, "currentLayerId"));

  currentColorStyle = XML_getInt(display, "currentColorStyle");
  colorStyleCount = XML_getInt(display, "colorStyleCount");

  currentDataSource = XML_getInt(climate, "currentDataSource");

  celestialMagnification = XML_getFloat(display, "celestialMagnification");

  cameraIndex = XML_getInt(display, "cameraIndex");

  allMaterials.Selection = XML_getInt(display, "materialSelection");
  overallScale = XML_getFloat(display, "overallScale");
  // Unlike every other display.getXxx() call here, this one is a
  // brand new attribute - no file saved before this setting existed
  // ever had it under any name, old-flat-"variable" layout included
  // (unlike this session's earlier renames/regroupings, where the
  // value genuinely was always there, just differently named/nested).
  // XML_getFloat()'s own xml.getFloat(tag) (xmlHelpers.pde) returns a
  // bare 0 for a tag that isn't present, which would silently zero out
  // this lift (and bring back the z-fighting FACE_TO_SECTION_LIFT
  // exists to prevent) on every project saved before this change. Its
  // own 2-argument overload takes an explicit fallback instead - used
  // directly here, bypassing the XML_getFloat() wrapper (and its
  // diag_XML_input logging) for this one call - with
  // FACE_TO_SECTION_LIFT's own compiled-in default (faceToSection.pde)
  // as that fallback, so an old file keeps that default instead of
  // silently losing the lift entirely.
  FACE_TO_SECTION_LIFT = display.getFloat("faceToSectionLift", FACE_TO_SECTION_LIFT);

  viewLayout = XML_getInt(display, "viewLayout");
  activeLanguage = XML_getInt(parent, "activeLanguage");

  impactDisplayDay = XML_getInt(display, "impactDisplayDay");

  String new_currentFont = XML_getString(parent, "currentFont");
  if (currentFont.equals(new_currentFont)) {
  } else {
    currentFont = new_currentFont;
    loadCurrentFontStyle();
  }


  // Matches buildProjectSnapshot()'s own four named groups
  // (saveProject.pde) - every file this writes from here on has all
  // four, every time. A file saved before this grouping existed has
  // none of them: each affected class's own CLASS_STAMP child sits
  // directly on the document root instead, exactly where it always
  // did. Falling back to the bare root xml for any group that isn't
  // found reproduces that old lookup exactly - each class's own
  // from_XML() still just does xml.getChild(this.CLASS_STAMP) against
  // whatever "xml" it's handed, so no change there is needed, and an
  // old file's actual saved geometry/environment/view/impacts data is
  // found and restored rather than silently reset to defaults (unlike
  // this session's earlier attribute-level renames, where the old
  // value genuinely no longer exists anywhere in the file under any
  // name). Call order is unchanged from before grouping existed - see
  // buildProjectSnapshot()'s matching comment.
  XML geometryGroup = xml.getChild("geometry");
  if (geometryGroup == null) geometryGroup = xml;
  XML environmentGroup = xml.getChild("environment");
  if (environmentGroup == null) environmentGroup = xml;
  XML viewGroup = xml.getChild("view");
  if (viewGroup == null) viewGroup = xml;
  XML impactsGroup = xml.getChild("impacts");
  if (impactsGroup == null) impactsGroup = xml;

  STATION.from_XML(xml);

  allPoints.from_XML(geometryGroup);

  allPolylines.from_XML(geometryGroup);

  allFaces.from_XML(geometryGroup);

  allCameras.from_XML(viewGroup);

  allSolids.from_XML(geometryGroup);

  allSections.from_XML(geometryGroup);

  allModel1Ds.from_XML(geometryGroup);

  allModel2Ds.from_XML(geometryGroup);

  allGroups.from_XML(geometryGroup); // Note: Groups should be inputted after Faces, Polylines, Model1Ds, Model2Ds, etc.

  Terrain.from_XML(environmentGroup);

  Earth3D.from_XML(environmentGroup);

  Sky3D.from_XML(environmentGroup);

  Tropo3D.from_XML(environmentGroup);

  Moon3D.from_XML(environmentGroup);

  Sun3D.from_XML(environmentGroup);

  if (restoreViewport) WIN3D.from_XML(viewGroup);

  User3D.from_XML(viewGroup);

  Select3D.from_XML(viewGroup);

  WORLD.from_XML(xml);

  STUDY.from_XML(xml);

  hoverPoints_from_XML(viewGroup);

  allWindRoses.from_XML(impactsGroup);

  allWindFlows.from_XML(impactsGroup);

  allSolidImpacts.from_XML(impactsGroup);

  allSolarImpacts.from_XML(impactsGroup);

  for (int i = 0; i < allLayers.length; i++) {
    allLayers[i].from_XML(geometryGroup);
  }

  println("End of loading XML");
}
