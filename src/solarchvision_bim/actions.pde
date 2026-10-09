// Menu items only ever need a plain, argument-less trigger (Runnable).
// Commands typed on the command line (runScript.pde) may also come with
// one or more arguments (e.g. "start_day 15"), so allActions is keyed by
// lowercase command/caption and stores an Action: a Runnable that also
// accepts the full, space-split command line (args[0] is the command
// itself, args[1..] are its parameters).
interface Action {
  void run(String[] args);
}

// Getter/setter pair used to plug an existing numeric field (e.g.
// TIME.day) into a generic, reusable spinner-style command action.
interface FloatGetter {
  float get();
}

interface FloatSetter {
  void set(float v);
}

// Follow-up work to run right after a spinner-style command actually
// changes a field's value. Receives the value before and after the
// change, since a few fields (e.g. Select3D.position) apply a delta
// between the two rather than the new value on its own.
interface OnChange {
  void run(float oldValue, float newValue);
}

HashMap<String, Action> allActions;

// Normalizes a name/caption into a command key: lowercase, and spaces
// become underscores (so a multi-word caption becomes one command-line
// token, e.g. "Start day" -> "start_day", "3D-select.rotationVectorIndex" ->
// "3d-select.rotvector"). Nothing else about the text is changed - dots,
// dashes, digits are all left as they are - so any existing field name or
// caption can be passed to putAction as-is and used the same way on the
// command line.
private String normalizeActionKey(String s) {
  return s.toLowerCase().replace(' ', '_');
}

void echoAction(String command, String[] args) {
  if(logLevel <= LOGLEVEL_DISABLED) return;

  StringBuilder line = new StringBuilder(ACTION_HEAD);
  line.append(command);
  for (int i = 1; i < args.length; i++) {
    line.append(" ").append(args[i]);
  }
  displayDirective(line.toString());
}

void echoAction(String command) {
  if(logLevel <= LOGLEVEL_DISABLED) return;
  displayDirective(ACTION_HEAD + command);
}

private void putAction(String s, Runnable fn) {
    String key = normalizeActionKey(s);
    allActions.put(key, (args) -> {
      echoAction(key);
      fn.run(); // ignore any args
    });

    // Also support commands with space in their names
    String withSpace = s.toLowerCase();
    if(!withSpace.equals(key)) {
        allActions.put(withSpace, (args) -> {
          echoAction(withSpace);
          fn.run(); // ignore any args
        });
    }
}

private void putAction(String s, Action fn) {
    String key = normalizeActionKey(s);
    allActions.put(key, (args) -> {
      echoAction(key, args);
      fn.run(args);
    });

    // Also support commands with space in their names
    String withSpace = s.toLowerCase();
    if(!withSpace.equals(key)) {
        allActions.put(withSpace, (args) -> {
          echoAction(withSpace, args);
          fn.run(args);
        });
    }
}

// Calls a putAction-registered action directly - the echoAction(...) a
// normal lookup already wraps it in still fires (one "[Action]: name"
// line, same as always), but runScriptLine's own string-transform and
// switch-case lookup are skipped entirely. For a caller that already
// knows the exact action name at compile time (UI_toolBar.pde's own
// performAction, mainly) and doesn't need runScriptLine's broader
// dispatch (command names, bypassAllActionsFor, etc.), going through
// runScriptLine("CameraRollXY") only to have that command's own no-args
// branch call this exact same action internally is wasted work, and
// doubles the log output ("(Command): CameraRollXY" followed by
// "[Action]: camerarollxy") for no benefit. Only ever call this with a
// name actually registered via putAction - unlike runScriptLine, there
// is no switch-case fallback and no UnrecognizedCommand hint if it
// isn't.
void callAction(String name) {
  allActions.get(name.toLowerCase()).run(new String[]{name});
}

// Shared by putValueAction (below) and _Spinner (UI_rollout.pde): revise
// the views a spinner-style field's update1/update2/update3 flags say
// should refresh when its value actually changes.
void reviseByUpdateFlags(int update1, int update2, int update3) {
  if (update1 != 0) {
    UI_caseBar.revise();
    UI_rollout.revise();
    STUDY.revise();
  }

  if (update2 != 0) {
    UI_rollout.revise();
    WIN3D.revise();
  }

  if (update3 != 0) {
    UI_rollout.revise();
    WORLD.revise();
  }
}

// Registers a command-line-callable action that sets a bounded numeric
// field's value: validate the new value is within range, round it the
// same way this.Spinner(...) does (funcs.roundTo), apply it only if it
// actually changed, and then revise the same views a spinner's
// update1/update2/update3 flags would have revised (STUDY, WIN3D, WORLD).
// This is the same validate/round/apply/revise logic UI_rollout.draw()'s
// this.Spinner(...) calls use, just reachable outside the draw() loop too.
//
// This is the core (min/max evaluated fresh on every call, via getters):
// some fields' min/max come from other fields that can change during a
// session (e.g. a loaded project's climate-year range, camera count, or
// palette size), so baking them in once at registration time would go
// stale. The plain-float overloads below are for the (much more common)
// case of fixed bounds and just wrap a fixed value in a getter.
//
// name       : command-line keyword (e.g. "start_day"), also used in messages.
// getter     : reads the current value of the backing field.
// setter     : writes the new (rounded) value to the backing field.
// minGetter/maxGetter/step : same meaning as the Spinner's min_v/max_v/stp_v,
//                            but min/max are read fresh on every invocation.
// update1/update2/update3 : same meaning as the Spinner's update1/update2/update3
//                            (non-zero revises STUDY, WIN3D, WORLD respectively).
// onChanged  : optional (may be null). Some fields (e.g. TIME.day/month/year)
//              need extra derived-state work beyond a simple revise() when
//              changed interactively - see applyRolloutUpdate.pde, which
//              normally does this work once per frame by diffing the field's
//              value before/after UI_rollout.draw(). A command-line change
//              happens outside that per-frame diff window, so it would never
//              be picked up there; onChanged lets us run that same
//              field-specific follow-up work immediately instead.
void putValueAction(String name, FloatGetter getter, FloatSetter setter, FloatGetter minGetter, FloatGetter maxGetter, float step, int update1, int update2, int update3, OnChange onChanged) {
  putAction(name, (args) -> {
    float min_v = minGetter.get();
    float max_v = maxGetter.get();

    if (args.length < 2) {
      printError(name + " " + nf(min_v, 0, 0) + ".." + nf(max_v, 0, 0));
      return;
    }

    float requested;
    try {
      requested = Float.parseFloat(args[1]);
    }
    catch (Exception ex) {
      printError("Invalid value for " + name + ": " + args[1]);
      return;
    }

    if ((requested < min_v) || (requested > max_v)) {
      printError(name + " must be between " + nf(min_v, 0, 0) + " and " + nf(max_v, 0, 0));
      return;
    }

    float newValue = funcs.roundTo(requested, step);
    float oldValue = getter.get();

    if (newValue != oldValue) {
      setter.set(newValue);

      if (onChanged != null) onChanged.run(oldValue, newValue);

      reviseByUpdateFlags(update1, update2, update3);
    }
  });
}

// Convenience overload for dynamic-bound fields that don't need any
// extra follow-up work beyond the update1/update2/update3 revise() calls.
void putValueAction(String name, FloatGetter getter, FloatSetter setter, FloatGetter minGetter, FloatGetter maxGetter, float step, int update1, int update2, int update3) {
  putValueAction(name, getter, setter, minGetter, maxGetter, step, update1, update2, update3, null);
}

// Convenience overloads for the common case of fixed, constant bounds.
void putValueAction(String name, FloatGetter getter, FloatSetter setter, float min_v, float max_v, float step, int update1, int update2, int update3, OnChange onChanged) {
  putValueAction(name, getter, setter, () -> min_v, () -> max_v, step, update1, update2, update3, onChanged);
}

void putValueAction(String name, FloatGetter getter, FloatSetter setter, float min_v, float max_v, float step, int update1, int update2, int update3) {
  putValueAction(name, getter, setter, () -> min_v, () -> max_v, step, update1, update2, update3, null);
}

void build_allActions() {
  allActions = new HashMap<String, Action>();

  putAction("SOLARCHVISION-BIM6D", () -> {
    link("https://www.dropbox.com/scl/fi/vyfqllzj7hnb3rhvpnwus/BatimentDurable_MojtabaSamimi_20171123.pdf?rlkey=lzpoqyu59vp8wb4qidqtradaw&e=1");
  });

  putAction("Designed & developed by", () -> {
    link("https://depositonce.tu-berlin.de/items/c091139a-09cf-44c3-99a9-6adf59f7eaf8");
  });

  putAction("Mojtaba Samimi", () -> {
    link("https://www.linkedin.com/in/mojtaba-samimi-06178840/");
  });

  putAction("www.solarchvision.com", () -> {
    link("https://solarchvision.com/");
  });

  putAction("New", () -> {
    /////////////////////////////
    holdProject();
    /////////////////////////////

    selectFile_New();

    deleteAll();

    //update_station(-1);
  });

  putAction("Save", () -> {
    saveProject(Folder_Project + "/" + ProjectName + ".xml");
  });

  putAction("Hold", () -> {
    holdProject();
  });

  putAction("Fetch", () -> {
    fetchProject();
  });

  putAction("Open...", () -> {
    selectFile_Open();
  });

  putAction("Save As...", () -> {
    selectFile_SaveAs();
  });

  putAction("Import 3D-model...", () -> {
    selectFile_ImportObj();
  });

  putAction("Import Command File...", () -> {
    selectFile_RunScript();
  });

  putAction("Export 3D-model > OBJ (time-series)", () -> {
    exportObj_timeSeries();
  });

  putAction("Export 3D-model > OBJ (date-series)", () -> {
    exportObj_dateSeries();
  });

  putAction("Export 3D-model > OBJ", () -> {
    exportObj("");
  });

  putAction("Export 3D-model > HTML", () -> {
    exportHtml();
  });

  putAction("Export 3D-model > RAD", () -> {
    exportRadiance();
  });

  putAction("Export 3D-model > SCR", () -> {
    exportAutocadScript();
  });

  putAction("Quit", () -> {
    println();
    exit();
  });

  putAction("Wind pattern (active)", () -> setimpactGraphIndex(impactGraphIndex_WIND_ACTIVE, true));

  putAction("Wind pattern (passive)", () -> setimpactGraphIndex(impactGraphIndex_WIND_PASSIVE, true));

  putAction("Urban solar potential (active)", () -> setimpactGraphIndex(impactGraphIndex_URBAN_ACTIVE, false));

  putAction("Urban solar potential (passive)", () -> setimpactGraphIndex(impactGraphIndex_URBAN_PASSIVE, false));

  putAction("Orientation potential (active)", () -> setimpactGraphIndex(impactGraphIndex_GLOBAL_ACTIVE, false));

  putAction("Orientation potential (passive)", () -> setimpactGraphIndex(impactGraphIndex_GLOBAL_PASSIVE, false));

  putAction("Hourly sun position (active)", () -> setimpactGraphIndex(impactGraphIndex_SUNPATH_ACTIVE, false));

  putAction("Hourly sun position (passive)", () -> setimpactGraphIndex(impactGraphIndex_SUNPATH_PASSIVE, false));

  putAction("Annual cycle sun path (active)", () -> setimpactGraphIndex(impactGraphIndex_CYCLES_ACTIVE, false));

  putAction("Annual cycle sun path (passive)", () -> setimpactGraphIndex(impactGraphIndex_CYCLES_PASSIVE, false));

  putAction("Prebake Selected Sections", () -> {
    allSolarImpacts.render_Shadows_selectedSections();

    view_changed();
  });

  putAction("Process Active Impact", () -> {
    STUDY.impactGraphIndex = impactGraphIndex_URBAN_ACTIVE;
    allSolarImpacts.calculate_Impact_selectedSections();

    view_changed();
  });

  putAction("Process Passive Impact", () -> {
    STUDY.impactGraphIndex = impactGraphIndex_URBAN_PASSIVE;
    allSolarImpacts.calculate_Impact_selectedSections();

    view_changed();
  });

  putAction("Process Solid Impact", () -> {
    allSolidImpacts.calculate_Impact_selectedSections();

    view_changed();
  });

  putAction("Run wind 3D-model", () -> {
    allSolidImpacts.calculate_WindFlow();

    view_changed();
  });

  putAction("Stop REC.", () -> {
    stopAllRecording();

    UI_rollout.revise();
  });

  putAction("REC. Time Graph", () -> {
    stopAllRecording();
    STUDY.record_AUTO = true;

    UI_rollout.revise();
  });

  putAction("REC. Location Graph", () -> {
    stopAllRecording();
    WORLD.record_AUTO = true;

    UI_rollout.revise();
  });

  putAction("REC. Solid Graph", () -> {
    stopAllRecording();
    WIN3D.record_AUTO = true;

    UI_rollout.revise();
  });

  putAction("REC. Screenshot", () -> {
    stopAllRecording();
    FRAME_record_AUTO = true;

    UI_rollout.revise();
  });

  putAction("PDF Time Graph", () -> {
    STUDY.record_PDF = true;
    STUDY.revise();
  });

  putAction("JPG Time Graph", () -> {
    STUDY.record_IMG = true;
    STUDY.revise();
  });

  putAction("JPG Location Graph", () -> {
    WORLD.record_IMG = true;
    WORLD.revise();
  });

  putAction("PDF Location Graph", () -> {
    WORLD.record_PDF = true;
    WORLD.revise();
  });

  putAction("JPG 3D Graph", () -> {
    WIN3D.record_IMG = true;

    view_changed();
  });

  putAction("JPG 3D Full-Period", () -> {
    WIN3D.fullPeriod_IMG = true;
    WIN3D.record_IMG = true;

    view_changed();
  });

  putAction("Screenshot", () -> {
    FRAME_record_IMG = true;
  });

  putAction("Screenshot+Click", () -> {
    FRAME_click_IMG = true;
  });

  putAction("Screenshot+Drag", () -> {
    FRAME_drag_IMG = true;
  });

  putAction("Update Station", () -> {
    update_station(-1);
  });

  putAction("Load Terrain Mesh", () -> {
    Terrain.update_textures();
  });

  putAction("Load Terrain Texture", () -> {
    Terrain.update_textures();
  });

  putAction("Download Terrain Mesh", () -> {
    Terrain.download_mesh();
  });

  putAction("Download Terrain Texture", () -> {
    Terrain.download_textures();
  });

  putAction("Load Toroposphere", () -> {
    Tropo3D.download_images();
    Tropo3D.displaySurface = true;
    WORLD.revise();
    WIN3D.revise();
  });

  putAction("Download Ensemble Observation", () -> {
    download_ensembleObservation(TIME.year, TIME.month, TIME.day, TIME.hour);;
  });

  putAction("Download Ensemble Forecast", () -> {
    download_ensembleForecast(TIME.year, TIME.month, TIME.day, TIME.hour);
  });

  putAction("Download Climate Archive", () -> {
    downloadClimateArchive();
  });

  putAction("Download Climate Typical Year", () -> {
    download_climateTypicalYear();
  });

  putAction("Update Climate Typical Year", () -> {
    currentDataSource = dataID_climateTypicalYear;

    climateTypicalYearShouldLoad = true;
    update_climateTypicalYear();
  });

  putAction("Update Climate Engineering", () -> {
    currentDataSource = dataID_climateEngineering;

    climateEngineeringShouldLoad = true;
    update_climateEngineering();
  });

  putAction("Update Climate Archive", () -> {
    currentDataSource = dataID_climateArchive;

    climateArchiveShouldLoad = true;
    updateClimateArchive();
  });

  putAction("Update Ensemble Observation", () -> {
    currentDataSource = dataID_ensembleObservation;

    ensembleObservationShouldLoad = true;
    update_ensembleObservation(TIME.year, TIME.month, TIME.day, TIME.hour);
  });

  putAction("Update Ensemble Forecast", () -> {
    currentDataSource = dataID_ensembleForecast;

    ensembleForecastShouldLoad = true;
    update_ensembleForecast(TIME.year, TIME.month, TIME.day, TIME.hour);
  });



  putAction("Use Climate Typical Year", () -> {
    currentDataSource = dataID_climateTypicalYear;

    climateTypicalYearShouldLoad = true;
    update_climateTypicalYear();

    view_changed();
    WORLD.revise();
    STUDY.revise();
    UI_rollout.revise();
    UI_caseBar.revise();

    WORLD.hideAllMarkersAndLabels();
    WORLD.climateTypicalYearDisplayAll = 1;
    WORLD.climateTypicalYearDisplayNear = true;
  });

  putAction("Use Climate Engineering", () -> {
    currentDataSource = dataID_climateEngineering;

    climateEngineeringShouldLoad = true;
    update_climateEngineering();

    view_changed();
    WORLD.revise();
    STUDY.revise();
    UI_rollout.revise();
    UI_caseBar.revise();

    WORLD.hideAllMarkersAndLabels();
    WORLD.climateEngineeringDisplayAll = 1;
    WORLD.climateEngineeringDisplayNear = true;
  });

  putAction("Use Climate Archive", () -> {
    currentDataSource = dataID_climateArchive;

    climateArchiveShouldLoad = true;
    updateClimateArchive();

    view_changed();
    WORLD.revise();
    STUDY.revise();
    UI_rollout.revise();
    UI_caseBar.revise();

    WORLD.hideAllMarkersAndLabels();
    WORLD.climateArchiveDisplayAll = 1;
    WORLD.climateArchiveDisplayNear = true;
  });

  putAction("Use Ensemble Observation", () -> {
    currentDataSource = dataID_ensembleObservation;
    STUDY.daysMergedCount = 1;

    ensembleObservationShouldLoad = true;
    update_ensembleObservation(TIME.year, TIME.month, TIME.day, TIME.hour);

    view_changed();
    WORLD.revise();
    STUDY.revise();
    UI_rollout.revise();
    UI_caseBar.revise();

    WORLD.hideAllMarkersAndLabels();
    WORLD.ensembleObservationDisplayAll = 1;
    WORLD.ensembleObservationDisplayNear = true;
  });

  putAction("Use Ensemble Forecast", () -> {
    currentDataSource = dataID_ensembleForecast;
    STUDY.daysMergedCount = 1;

    ensembleForecastShouldLoad = true;
    update_ensembleForecast(TIME.year, TIME.month, TIME.day, TIME.hour);

    view_changed();
    WIN3D.revise();
    STUDY.revise();
    UI_rollout.revise();
    UI_caseBar.revise();

    WORLD.hideAllMarkersAndLabels();
    WORLD.ensembleForecastDisplayAll = 1;
    WORLD.ensembleForecastDisplayNear = true;
  });

  putAction("Active Shade", () -> {
    WIN3D.impactTypeIndex = Impact_ACTIVE;

    if (WIN3D.shadingMode == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
    if (WIN3D.shadingMode == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;

    view_changed();
  });

  putAction("Passive Shade", () -> {
    WIN3D.impactTypeIndex = Impact_PASSIVE;

    if (WIN3D.shadingMode == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
    if (WIN3D.shadingMode == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;

    view_changed();
  });

  putAction("Shade Surface Wire", () -> {
    WIN3D.shadingMode = SHADE.Surface_Wire;
    allFaces.displayEdges = true; //<<<<<<<<<<<<<<<

    view_changed();
  });

  putAction("Shade Surface Base", () -> {
    WIN3D.shadingMode = SHADE.Surface_Base;

    view_changed();
  });

  putAction("Shade Surface White", () -> {
    WIN3D.shadingMode = SHADE.Surface_White;

    view_changed();
  });

  putAction("Shade Surface Materials", () -> {
    WIN3D.shadingMode = SHADE.Surface_Materials;

    view_changed();
  });

  putAction("Shade Global Solar", () -> {
    WIN3D.shadingMode = SHADE.Global_Solar;

    GlobalSolar_rebuild_array = true;

    view_changed();
  });

  putAction("Shade Vertex Solar", () -> {
    WIN3D.shadingMode = SHADE.Vertex_Solar;

    VertexSolar_rebuild_array = true;

    view_changed();
  });

  putAction("Shade Vertex Solid", () -> {
    WIN3D.shadingMode = SHADE.Vertex_Solid;

    view_changed();
  });

  putAction("Shade Vertex Elevation", () -> {
    WIN3D.shadingMode = SHADE.Vertex_Elevation;

    view_changed();
  });

  putAction("Shade Viewport", () -> {
    ShadeViewport();
  });

  putAction("Prebake Viewport", () -> {
    preBakeViewport();
  });

  putAction("Show/Hide Terrain Mesh", () -> {
    Terrain.displaySurface = !Terrain.displaySurface;

    view_changed();
  });

  putAction("Show/Hide Terrain Texture", () -> {
    Terrain.displayTexture = !Terrain.displayTexture;

    view_changed();
  });

  putAction("Show/Hide Terrain Vertices", () -> {
    Terrain.displayPoints = !Terrain.displayPoints;

    view_changed();
  });

  putAction("Show/Hide Terrain Depth", () -> {
    Terrain.displayDepth = !Terrain.displayDepth;

    view_changed();
  });

  putAction("Show/Hide Vertices", () -> {
    allPoints.displayAll = !allPoints.displayAll;

    view_changed();
  });

  putAction("Show/Hide Edges", () -> {
    allFaces.displayEdges = !allFaces.displayEdges;

    view_changed();
  });

  putAction("Show/Hide Normals", () -> {
    allFaces.showNormalLines = !allFaces.showNormalLines;

    view_changed();
  });

  putAction("Show/Hide Leaves", () -> {
    allModel1Ds.displayLeaves = !allModel1Ds.displayLeaves;

    view_changed();
  });

  putAction("Show/Hide Model1Ds", () -> {
    allModel1Ds.displayAll = !allModel1Ds.displayAll;
    allModel1Ds.displayLeaves = allModel1Ds.displayAll; // <<<<<<

    view_changed();
  });

  putAction("Show/Hide Model2Ds", () -> {
    allModel2Ds.displayAll = !allModel2Ds.displayAll;

    view_changed();
  });

  putAction("Show/Hide Polylines", () -> {
    allPolylines.displayAll = !allPolylines.displayAll;

    view_changed();
  });

  putAction("Show/Hide Faces", () -> {
    allFaces.displayAll = !allFaces.displayAll;

    view_changed();
  });

  putAction("Show/Hide Solids", () -> {
    allSolids.displayAll = !allSolids.displayAll;

    view_changed();
  });

  putAction("Show/Hide Sections", () -> {
    allSections.displayAll = !allSections.displayAll;

    view_changed();
  });

  putAction("Show/Hide Cameras", () -> {
    allCameras.displayAll = !allCameras.displayAll;

    view_changed();
  });

  putAction("Show/Hide Sky", () -> {
    Sky3D.displaySurface = !Sky3D.displaySurface;

    view_changed();
  });

  putAction("Show/Hide Sun Grid", () -> {
    Sun3D.displayGrid = !Sun3D.displayGrid;

    view_changed();
  });

  putAction("Show/Hide Sun Path", () -> {
    Sun3D.displayPath = !Sun3D.displayPath;

    view_changed();
  });

  putAction("Show/Hide Sun Pattern", () -> {
    Sun3D.displayPattern = !Sun3D.displayPattern;

    view_changed();
  });

  putAction("Show/Hide Sun Surface", () -> {
    Sun3D.displaySurface = !Sun3D.displaySurface;

    view_changed();
  });

  putAction("Show/Hide Moon Surface", () -> {
    Moon3D.displaySurface = !Moon3D.displaySurface;

    view_changed();
  });

  putAction("Show/Hide Earth Surface", () -> {
    Earth3D.displaySurface = !Earth3D.displaySurface;

    view_changed();
  });

  putAction("Show/Hide Troposphere", () -> {
    Tropo3D.displaySurface = !Tropo3D.displaySurface;

    view_changed();
    WORLD.revise();
  });

  putAction("Show/Hide Solar Section", () -> {
    allSolarImpacts.displayImage = !allSolarImpacts.displayImage;

    view_changed();
  });

  putAction("Show/Hide Solid Section", () -> {
    allSolidImpacts.displayImage = !allSolidImpacts.displayImage;

    view_changed();
  });

  putAction("Show/Hide Selected Solids", () -> {
    Select3D.solidDisplayEdges = !Select3D.solidDisplayEdges;

    view_changed();
  });

  putAction("Show/Hide Selected Sections", () -> {
    Select3D.sectionDisplayEdges = !Select3D.sectionDisplayEdges;

    view_changed();
  });

  putAction("Show/Hide Selected Cameras", () -> {
    Select3D.cameraDisplayFrustum = !Select3D.cameraDisplayFrustum;

    view_changed();
  });

  putAction("Show/Hide Selected Terrain Vertices", () -> {
    Select3D.terrainDisplayVertices = !Select3D.terrainDisplayVertices;

    view_changed();
  });

  putAction("Show/Hide Wind Flow", () -> {
    allWindFlows.displayAll = !allWindFlows.displayAll;

    view_changed();
  });

  putAction("Show/Hide Selected Faces", () -> {
    Select3D.faceDisplayEdges = !Select3D.faceDisplayEdges;

    view_changed();
  });

  putAction("Show/Hide Selected Faces Vertex Count", () -> {
    Select3D.faceDisplayvertexSelection = !Select3D.faceDisplayvertexSelection;

    view_changed();
  });

  putAction("Show/Hide Selected Polylines Vertex Count", () -> {
    Select3D.polylineDisplayvertexSelection = !Select3D.polylineDisplayvertexSelection;

    view_changed();
  });

  putAction("Show/Hide Selected Vertices", () -> {
    Select3D.vertexDisplayMarkers = !Select3D.vertexDisplayMarkers;

    view_changed();
  });

  putAction("Show/Hide Selected Polylines", () -> {
    Select3D.polylineDisplayVertices = !Select3D.polylineDisplayVertices;

    view_changed();
  });

  putAction("Show/Hide Selected REF Pivot", () -> {
    Select3D.pivotDisplayReference = !Select3D.pivotDisplayReference;

    view_changed();
  });

  putAction("Show/Hide Selected Group Pivot", () -> {
    Select3D.groupDisplayPivot = !Select3D.groupDisplayPivot;

    view_changed();
  });

  putAction("Show/Hide Selected Group Edges", () -> {
    Select3D.groupDisplayEdges = !Select3D.groupDisplayEdges;

    view_changed();
  });

  putAction("Show/Hide Selected Group Box", () -> {
    Select3D.groupDisplayBox = !Select3D.groupDisplayBox;

    view_changed();;
  });

  putAction("Show/Hide Selected 2D Edges", () -> {
    Select3D.model2DDisplayBounds = !Select3D.model2DDisplayBounds;

    view_changed();
  });

  putAction("Show/Hide Selected 1D Edges", () -> {
    Select3D.model1DDisplayBounds = !Select3D.model1DDisplayBounds;

    view_changed();
  });

  putAction("Show/Hide Ensemble Observation stations", () -> {
    WORLD.ensembleObservationDisplayAll = (WORLD.ensembleObservationDisplayAll + 1) % 2;

    WORLD.revise();
  });

  putAction("Show/Hide Ensemble Observation nearest", () -> {
    WORLD.ensembleObservationDisplayNear = !WORLD.ensembleObservationDisplayNear;

    WORLD.revise();
  });

  putAction("Show/Hide Ensemble Forecast stations", () -> {
    WORLD.ensembleForecastDisplayAll = (WORLD.ensembleForecastDisplayAll + 1) % 2;

    WORLD.revise();
  });

  putAction("Show/Hide Ensemble Forecast nearest", () -> {
    WORLD.ensembleForecastDisplayNear = !WORLD.ensembleForecastDisplayNear;

    WORLD.revise();
  });

  putAction("Show/Hide Climate Engineering stations", () -> {
    WORLD.climateEngineeringDisplayAll = (WORLD.climateEngineeringDisplayAll + 1) % 2;

    WORLD.revise();
  });

  putAction("Show/Hide Climate Engineering nearest", () -> {
    WORLD.climateEngineeringDisplayNear = !WORLD.climateEngineeringDisplayNear;

    WORLD.revise();
  });

  putAction("Show/Hide Climate Archive stations", () -> {
    WORLD.climateArchiveDisplayAll = (WORLD.climateArchiveDisplayAll + 1) % 2;

    WORLD.revise();
  });

  putAction("Show/Hide Climate Archive nearest", () -> {
    WORLD.climateArchiveDisplayNear = !WORLD.climateArchiveDisplayNear;

    WORLD.revise();
  });

  putAction("Show/Hide Climate Typical Year stations", () -> {
    WORLD.climateTypicalYearDisplayAll = (WORLD.climateTypicalYearDisplayAll + 1) % 2;

    WORLD.revise();
  });

  putAction("Show/Hide Climate Typical Year nearest", () -> {
    WORLD.climateTypicalYearDisplayNear = !WORLD.climateTypicalYearDisplayNear;

    WORLD.revise();
  });

  putAction("1D-Tree", () -> {
    UI_setTo_Create_allModel1Ds();
  });

  putAction("2D-Tree", () -> {
    UI_setTo_Create_Tree();
  });

  putAction("Person", () -> {
    UI_setTo_Create_Person();
  });

  putAction("Point", () -> {
    UI_setTo_Create_Vertex();
  });

  putAction("Polyline", () -> {
    UI_setTo_Create_Polyline();
  });

  putAction("Surface", () -> {
    UI_setTo_Create_Face();
  });

  putAction("Parametric 1", () -> {
    UI_setTo_Create_Parametric(1);
  });

  putAction("Parametric 2", () -> {
    UI_setTo_Create_Parametric(2);
  });

  putAction("Parametric 3", () -> {
    UI_setTo_Create_Parametric(3);
  });

  putAction("Parametric 4", () -> {
    UI_setTo_Create_Parametric(4);
  });

  putAction("Parametric 5", () -> {
    UI_setTo_Create_Parametric(5);
  });

  putAction("Parametric 6", () -> {
    UI_setTo_Create_Parametric(6);
  });

  putAction("Pyramid", () -> {
    UI_setTo_Create_Pyramid();
  });

  putAction("Plane", () -> {
    UI_setTo_Create_Plane();
  });

  putAction("Polygon", () -> {
    UI_setTo_Create_Polygon();
  });

  putAction("Extrude", () -> {
    UI_setTo_Create_Extrude();
  });

  putAction("Hyper", () -> {
    UI_setTo_Create_Hyper();
  });

  putAction("House3", () -> {
    UI_setTo_Create_House3();
  });

  putAction("House2", () -> {
    UI_setTo_Create_House2();
  });

  putAction("House1", () -> {
    UI_setTo_Create_House1();
  });

  putAction("Box", () -> {
    UI_setTo_Create_Box();
  });

  putAction("Icosahedron", () -> {
    UI_setTo_Create_Icosahedron();
  });

  putAction("Octahedron", () -> {
    UI_setTo_Create_Octahedron();
  });

  putAction("Sphere", () -> {
    UI_setTo_Create_Sphere();
  });

  putAction("Cylinder", () -> {
    UI_setTo_Create_Cylinder();
  });

  putAction("Cone", () -> {
    UI_setTo_Create_Cone();
  });

  putAction("Cushion", () -> {
    UI_setTo_Create_Cushion();
  });

  putAction("Drop on LandSurface", () -> {
    UI_setTo_Modify_Drop(0);

    Drop3D.selection();
  });

  putAction("Drop on ModelSurface (Down)", () -> {
    UI_setTo_Modify_Drop(1);

    Drop3D.selection();
  });

  putAction("Drop on ModelSurface (Up)", () -> {
    UI_setTo_Modify_Drop(2);

    Drop3D.selection();
  });

  putAction("Get dX", () -> {
    UI_setTo_Modify_GetLength(0);
  });

  putAction("Get dY", () -> {
    UI_setTo_Modify_GetLength(1);
  });

  putAction("Get dZ", () -> {
    UI_setTo_Modify_GetLength(2);
  });

  putAction("Get dXYZ", () -> {
    UI_setTo_Modify_GetLength(3);
  });

  putAction("Get dXY", () -> {
    UI_setTo_Modify_GetLength(4);
  });

  putAction("MoveX", () -> {
    UI_setTo_Modify_Move(0);
  });

  putAction("MoveY", () -> {
    UI_setTo_Modify_Move(1);
  });

  putAction("MoveZ", () -> {
    UI_setTo_Modify_Move(2);
  });

  putAction("Move", () -> {
    UI_setTo_Modify_Move(3);
  });

  putAction("ScaleX", () -> {
    UI_setTo_Modify_Scale(0);
  });

  putAction("ScaleY", () -> {
    UI_setTo_Modify_Scale(1);
  });

  putAction("ScaleZ", () -> {
    UI_setTo_Modify_Scale(2);
  });

  putAction("Scale", () -> {
    UI_setTo_Modify_Scale(3);
  });

  putAction("PowerX", () -> {
    UI_setTo_Modify_Power(0);
  });

  putAction("PowerY", () -> {
    UI_setTo_Modify_Power(1);
  });

  putAction("PowerZ", () -> {
    UI_setTo_Modify_Power(2);
  });

  putAction("Power", () -> {
    UI_setTo_Modify_Power(3);
  });

  putAction("RotateX", () -> {
    UI_setTo_Modify_Rotate(0);
  });

  putAction("RotateY", () -> {
    UI_setTo_Modify_Rotate(1);
  });

  putAction("RotateZ", () -> {
    UI_setTo_Modify_Rotate(2);
  });

  putAction("Rotate", () -> {
    UI_setTo_Modify_Rotate(2);
  });

  putAction("Pivot", () -> {
    UI_setTo_Modify_Pivot(0);
  });

  putAction("Pick Pivot", () -> {
    UI_setTo_Modify_Pivot(1);
  });

  putAction("Assign Pivot", () -> {
    UI_setTo_Modify_Pivot(2);
  });

  putAction("Save Current ReferenceBox", () -> {
    Select3D.save_current_BoundingBox();
  });

  putAction("Reset Saved ReferenceBox", () -> {
    Select3D.apply_saved_BoundingBox();

    view_changed();
  });

  putAction("Use Selection ReferenceBox", () -> {
    Select3D.calculate_BoundingBox();

    view_changed();
  });

  putAction("Use Origin ReferenceBox", () -> {
    Select3D.apply_origin_ReferenceBox();

    view_changed();
  });

  putAction("Begin New Group at Origin", () -> {
    allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);

    Select3D.groupSelection = new int [1];
    Select3D.groupSelection[0] = allGroups.num - 1;

    model_changed();
  });

  putAction("Begin New Group at Pivot", () -> {
    allGroups.beginNewGroup(
      Select3D.BoundingBox[1 + Select3D.pivotAlignmentX][0],
      Select3D.BoundingBox[1 + Select3D.pivotAlignmentY][1],
      Select3D.BoundingBox[1 + Select3D.pivotAlignmentZ][2],
      Select3D.BoundingBox[1 + Select3D.pivotAlignmentX][3],
      Select3D.BoundingBox[1 + Select3D.pivotAlignmentY][4],
      Select3D.BoundingBox[1 + Select3D.pivotAlignmentZ][5],
      Select3D.BoundingBox[1 + Select3D.pivotAlignmentX][6],
      Select3D.BoundingBox[1 + Select3D.pivotAlignmentY][7],
      Select3D.BoundingBox[1 + Select3D.pivotAlignmentZ][8]
    );

    Select3D.groupSelection = new int [1];
    Select3D.groupSelection[0] = allGroups.num - 1;

    model_changed();
  });

  putAction("Solid", () -> {
    UI_setTo_Create_Solid();
  });

  putAction("Section", () -> {
    UI_setTo_Create_Section();
  });

  putAction("Camera", () -> {
    UI_setTo_Create_Camera();
  });

  putAction("Viewport >> Camera", () -> {
    float Camera_pX = WIN3D.positionX;
    float Camera_pY = WIN3D.positionY;
    float Camera_pZ = WIN3D.positionZ;
    float Camera_pT = WIN3D.positionStep;
    float Camera_rX = WIN3D.rotationX;
    float Camera_rY = WIN3D.rotationY;
    float Camera_rZ = WIN3D.rotationZ;
    float Camera_rT = WIN3D.rotationStep;
    float Camera_zoom = WIN3D.zoom;

    int Camera_type = WIN3D.projectionTypeIndex;

    allCameras.create(Camera_pX, Camera_pY, Camera_pZ, Camera_pT, Camera_rX, Camera_rY, Camera_rZ, Camera_rT, Camera_zoom, Camera_type);

    WIN3D.currentCameraIndex = allCameras.num - 1;
    WIN3D.apply_currentCameraIndex();
    modify_Viewport_Title();

    view_changed();

    UI_toolBar.revise();
  });

  putAction("Camera >> Viewport", () -> {
    allCameras.set_posX(0, allCameras.get_posX(WIN3D.currentCameraIndex));
    allCameras.set_posY(0, allCameras.get_posY(WIN3D.currentCameraIndex));
    allCameras.set_posZ(0, allCameras.get_posZ(WIN3D.currentCameraIndex));
    allCameras.set_posT(0, allCameras.get_posT(WIN3D.currentCameraIndex));
    allCameras.set_rotX(0, allCameras.get_rotX(WIN3D.currentCameraIndex));
    allCameras.set_rotY(0, allCameras.get_rotY(WIN3D.currentCameraIndex));
    allCameras.set_rotZ(0, allCameras.get_rotZ(WIN3D.currentCameraIndex));
    allCameras.set_rotT(0, allCameras.get_rotT(WIN3D.currentCameraIndex));
    allCameras.set_zoom(0, allCameras.get_zoom(WIN3D.currentCameraIndex));
    allCameras.set_type(0, allCameras.get_type(WIN3D.currentCameraIndex));

    WIN3D.currentCameraIndex = 0;
    modify_Viewport_Title();

    view_changed();

    UI_toolBar.revise();
  });

  putAction("Next Camera", () -> {
    WIN3D.currentCameraIndex += 1;
    if (WIN3D.currentCameraIndex > allCameras.num - 1) WIN3D.currentCameraIndex = 0;
    WIN3D.apply_currentCameraIndex();
    modify_Viewport_Title();
  });

  putAction("Previous Camera", () -> {
    WIN3D.currentCameraIndex -= 1;
    // Pre-existing bug, found (not introduced) while testing this move:
    // the original "allCameras.num - 1" wrap-around assumes at least one
    // camera exists - with zero cameras in the scene it computes -1, not
    // a valid index, which crashes downstream (Model2Ds.pde,
    // ArrayIndexOutOfBoundsException) the next time anything renders.
    // Confirmed via `git show` that this exact line, unchanged, already
    // existed before this file started reusing it as an action -
    // clamping to 0 here rather than leaving it as still-latent.
    if (WIN3D.currentCameraIndex < 0) WIN3D.currentCameraIndex = max(0, allCameras.num - 1);
    WIN3D.apply_currentCameraIndex();
    modify_Viewport_Title();
  });

  putAction("Toggle Impact Type", () -> {
    WIN3D.impactTypeIndex = (WIN3D.impactTypeIndex + 1) % numberOfImpactVariations;
    if (WIN3D.shadingMode == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
    if (WIN3D.shadingMode == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;
  });

  putAction("Zoom Out", () -> {
    if (WIN3D.projectionTypeIndex == 1) WIN3D.positionZ += WIN3D.positionStep * overallScale;
    else WIN3D.zoom /= pow(2.0, 0.25);
  });

  putAction("Zoom In", () -> {
    if (WIN3D.projectionTypeIndex == 1) WIN3D.positionZ -= WIN3D.positionStep * overallScale;
    else WIN3D.zoom *= pow(2.0, 0.25);
  });

  putAction("Turn View Left", () -> {
    WIN3D.rotationZ += WIN3D.rotationStep;
    WIN3D.reverseTransform_3DViewport();
  });

  putAction("Turn View Right", () -> {
    WIN3D.rotationZ -= WIN3D.rotationStep;
    WIN3D.reverseTransform_3DViewport();
  });

  putAction("Turn View Up", () -> {
    WIN3D.rotationX -= WIN3D.rotationStep;
    WIN3D.reverseTransform_3DViewport();
  });

  putAction("Turn View Down", () -> {
    WIN3D.rotationX += WIN3D.rotationStep;
    WIN3D.reverseTransform_3DViewport();
  });

  putAction("Pan Left", () -> {
    WIN3D.positionX += WIN3D.positionStep * overallScale;
  });

  putAction("Pan Right", () -> {
    WIN3D.positionX -= WIN3D.positionStep * overallScale;
  });

  putAction("Pan Forward", () -> {
    WIN3D.positionY += WIN3D.positionStep * overallScale;
  });

  putAction("Pan Backward", () -> {
    WIN3D.positionY -= WIN3D.positionStep * overallScale;
  });

  putAction("Dolly Away From Selection", () -> {
    WIN3D.move_3DViewport_towards_Selection(2.0);
  });

  putAction("Dolly Toward Selection", () -> {
    WIN3D.move_3DViewport_towards_Selection(0.5);
  });

  putAction("Narrow Field of View", () -> {
    WIN3D.zoom = 2 * funcs.atan_ang((1.0 / 1.1) * funcs.tan_ang(0.5 * WIN3D.zoom));
  });

  putAction("Widen Field of View", () -> {
    WIN3D.zoom = 2 * funcs.atan_ang((1.1 / 1.0) * funcs.tan_ang(0.5 * WIN3D.zoom));
  });

  putAction("Advance Troposphere Time", () -> {
    Tropo3D.i_Map += TROPO_deltaTime;
    if (Tropo3D.i_Map > STUDY.endHour) Tropo3D.i_Map -= TROPO_deltaTime;
    WORLD.revise();
    WIN3D.revise();
  });

  putAction("Rewind Troposphere Time", () -> {
    Tropo3D.i_Map -= TROPO_deltaTime;
    if (Tropo3D.i_Map < STUDY.startHour) Tropo3D.i_Map += TROPO_deltaTime;
    WORLD.revise();
    WIN3D.revise();
  });

  putAction("Next Impact Day", () -> {
    impactDisplayDay += 1;
    if (impactDisplayDay > STUDY.endDay) impactDisplayDay = 0;
  });

  putAction("Previous Impact Day", () -> {
    impactDisplayDay -= 1;
    if (impactDisplayDay < 0) impactDisplayDay = STUDY.endDay;
  });

  putAction("Recalculate Solar Impact", () -> {
    if (WIN3D.shadingMode == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
    if (WIN3D.shadingMode == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;
  });

  putAction("Shade Time +1 Hour", () -> {
    adjustShadeTime(1);
  });

  putAction("Shade Time -1 Hour", () -> {
    adjustShadeTime(-1);
  });

  putAction("Shade Time +1 Day", () -> {
    adjustShadeTime(SHADE_HOURS_PER_DAY + 1);
  });

  putAction("Shade Time -1 Day", () -> {
    adjustShadeTime(-(SHADE_HOURS_PER_DAY + 1));
  });

  putAction("Nudge Closer to Selection", () -> {
    moveWin3DTowardsSelection(-0.5);
  });

  putAction("Nudge Away from Selection", () -> {
    moveWin3DTowardsSelection(0.5);
  });

  putAction("Orbit Up Around Selection", () -> {
    WIN3D.rotateZ_3DViewport_around_Selection(-WIN3D.rotationStep);
  });

  putAction("Orbit Down Around Selection", () -> {
    WIN3D.rotateZ_3DViewport_around_Selection(WIN3D.rotationStep);
  });

  putAction("Orbit Left Around Selection", () -> {
    WIN3D.rotateXY_3DViewport_around_Selection(-WIN3D.rotationStep);
  });

  putAction("Orbit Right Around Selection", () -> {
    WIN3D.rotateXY_3DViewport_around_Selection(WIN3D.rotationStep);
  });

  putAction("Increase Tool Parameter", () -> {
    WIN3D.incrementParameter(1);
  });

  putAction("Decrease Tool Parameter", () -> {
    WIN3D.incrementParameter(-1);
  });

  putAction("Next Layer", () -> {
    changeCurrentLayerTo((currentLayerId + 1) % allLayers.length);
    requestStudyRedraw();
  });

  putAction("Previous Layer", () -> {
    changeCurrentLayerTo((currentLayerId + allLayers.length - 1) % allLayers.length);
    requestStudyRedraw();
  });

  putAction("Next Graph Index", () -> {
    STUDY.impactGraphIndex = (STUDY.impactGraphIndex + 1) % STUDY.PLOT_IMPACTS_MODE_COUNT;
    requestStudyRedraw();
  });

  putAction("Previous Graph Index", () -> {
    STUDY.impactGraphIndex = (STUDY.impactGraphIndex - 1 + STUDY.PLOT_IMPACTS_MODE_COUNT) % STUDY.PLOT_IMPACTS_MODE_COUNT;
    requestStudyRedraw();
  });

  putAction("Next Plot Layout", () -> {
    STUDY.plotLayoutIndex = -2 + (2 + STUDY.plotLayoutIndex + 1) % STUDY.PLOT_SETUP_MODE_COUNT;
    requestStudyRedraw();
  });

  putAction("Previous Plot Layout", () -> {
    STUDY.plotLayoutIndex = -2 + (2 + STUDY.plotLayoutIndex - 1 + STUDY.PLOT_SETUP_MODE_COUNT) % STUDY.PLOT_SETUP_MODE_COUNT;
    requestStudyRedraw();
  });

  putAction("Toggle Impact Summary", () -> {
    STUDY.showImpactSummary = !STUDY.showImpactSummary;
    requestStudyRedraw();
  });

  putAction("Increase Vertical Scale", () -> {
    STUDY.verticalUnitScale *= sqrt(2.0);
    requestStudyRedraw();
  });

  putAction("Decrease Vertical Scale", () -> {
    STUDY.verticalUnitScale *= sqrt(0.5);
    requestStudyRedraw();
  });

  putAction("Widen Join Window", () -> {
    STUDY.changeJoinDays(2);
    requestStudyRedraw();
  });

  putAction("Narrow Join Window", () -> {
    STUDY.changeJoinDays(-2);
    requestStudyRedraw();
  });

  putAction("Extend Date Range", () -> {
    STUDY.changeJEnd(1);
    requestStudyRedraw();
  });

  putAction("Shrink Date Range", () -> {
    STUDY.changeJEnd(-1);
    requestStudyRedraw();
  });

  putAction("Next Sky Scenario", () -> {
    STUDY.changeSkyScenario(1);
    requestStudyRedraw();
  });

  putAction("Previous Sky Scenario", () -> {
    STUDY.changeSkyScenario(-1);
    requestStudyRedraw();
  });

  putAction("Toggle Raw Lines", () -> {
    STUDY.showRawLines = !STUDY.showRawLines;
    requestStudyRedraw();
  });

  putAction("Toggle Statistical Ranges", () -> {
    STUDY.showStatisticalRanges = !STUDY.showStatisticalRanges;
    requestStudyRedraw();
  });

  putAction("Toggle Study Normal Lines", () -> {
    STUDY.showNormalLines = !STUDY.showNormalLines;
    requestStudyRedraw();
  });

  putAction("Toggle Probabilities", () -> {
    STUDY.showProbabilities = !STUDY.showProbabilities;
    requestStudyRedraw();
  });

  putAction("Increase Probability Height Step", () -> {
    if (STUDY.probabilityHeightInterval < 32) STUDY.probabilityHeightInterval *= 2.0;
    requestStudyRedraw();
  });

  putAction("Decrease Probability Height Step", () -> {
    if (STUDY.probabilityHeightInterval > 2) STUDY.probabilityHeightInterval *= 0.5;
    requestStudyRedraw();
  });

  putAction("Decrease Sum Interval", () -> {
    STUDY.decreaseSumInterval();
    requestStudyRedraw();
  });

  putAction("Increase Sum Interval", () -> {
    STUDY.increaseSumInterval();
    requestStudyRedraw();
  });

  putAction("Map Zoom Out", () -> {
    WORLD.zoom = (WORLD.zoom - 1 + 10) % 10;
    WORLD.VIEW_id = WORLD.FindGoodViewport(locationLongitude, locationLatitude);
    requestWorldRedraw();
  });

  putAction("Map Zoom In", () -> {
    WORLD.zoom = (WORLD.zoom + 1) % 10;
    WORLD.VIEW_id = WORLD.FindGoodViewport(locationLongitude, locationLatitude);
    requestWorldRedraw();
  });

  putAction("Camera View", () -> {
    if (Select3D.cameraSelection.length > 0) {
      WIN3D.currentCameraIndex = Select3D.cameraSelection[Select3D.cameraSelection.length - 1];
      WIN3D.apply_currentCameraIndex();
      modify_Viewport_Title();

      view_changed();

      UI_toolBar.revise();
    }
  });

  putAction("TerrainMesh >> Group", () -> {
    Terrain.draw(TypeWindow.TerrainMesh);

    model_changed();
  });

  putAction("TerrainGap >> Group", () -> {
    Terrain.draw(TypeWindow.LandGap);

    model_changed();
  });

  putAction("Change Seed/Material", () -> {
    UI_setTo_Modify_Seed(0);
  });

  putAction("Pick Seed/Material", () -> {
    UI_setTo_Modify_Seed(1);
  });

  putAction("Assign Seed/Material", () -> {
    UI_setTo_Modify_Seed(2);
  });

  putAction("Change tessellation", () -> {
    UI_setTo_Modify_Tessellation(0);
  });

  putAction("Pick tessellation", () -> {
    UI_setTo_Modify_Tessellation(1);
  });

  putAction("Assign tessellation", () -> {
    UI_setTo_Modify_Tessellation(2);
  });

  putAction("Change Layer", () -> {
    UI_setTo_Modify_Layer(0);
  });

  putAction("Pick Layer", () -> {
    UI_setTo_Modify_Layer(1);
  });

  putAction("Assign Layer", () -> {
    UI_setTo_Modify_Layer(2);
  });

  putAction("Change Visibility", () -> {
    UI_setTo_Modify_Visibility(0);
  });

  putAction("Pick Visibility", () -> {
    UI_setTo_Modify_Visibility(1);
  });

  putAction("Assign Visibility", () -> {
    UI_setTo_Modify_Visibility(2);
  });

  putAction("Change Weight", () -> {
    UI_setTo_Modify_Weight(0);
  });

  putAction("Pick Weight", () -> {
    UI_setTo_Modify_Weight(1);
  });

  putAction("Assign Weight", () -> {
    UI_setTo_Modify_Weight(2);
  });

  putAction("Flip Normal", () -> {
    UI_setTo_Modify_Normal(1);
  });

  putAction("Set-Out Normal", () -> {
    UI_setTo_Modify_Normal(2);
  });

  putAction("Set-In Normal", () -> {
    UI_setTo_Modify_Normal(3);
  });

  putAction("Get FirstVertex", () -> {
    UI_setTo_Modify_FirstVertex(1);
  });

  putAction("Change DegreeMax", () -> {
    UI_setTo_Modify_DegreeMax(0);
  });

  putAction("Pick DegreeMax", () -> {
    UI_setTo_Modify_DegreeMax(1);
  });

  putAction("Assign DegreeMax", () -> {
    UI_setTo_Modify_DegreeMax(2);
  });

  putAction("Change BranchTilt", () -> {
    UI_setTo_Modify_BranchTilt(0);
  });

  putAction("Pick BranchTilt", () -> {
    UI_setTo_Modify_BranchTilt(1);
  });

  putAction("Assign BranchTilt", () -> {
    UI_setTo_Modify_BranchTilt(2);
  });

  putAction("Change BranchTwist", () -> {
    UI_setTo_Modify_BranchTwist(0);
  });

  putAction("Pick BranchTwist", () -> {
    UI_setTo_Modify_BranchTwist(1);
  });

  putAction("Assign BranchTwist", () -> {
    UI_setTo_Modify_BranchTwist(2);
  });

  putAction("Change BranchRatio", () -> {
    UI_setTo_Modify_BranchRatio(0);
  });

  putAction("Pick BranchRatio", () -> {
    UI_setTo_Modify_BranchRatio(1);
  });

  putAction("Assign BranchRatio", () -> {
    UI_setTo_Modify_BranchRatio(2);
  });

  putAction("Change TreeBase", () -> {
    UI_setTo_Modify_TreeBase(0);
  });

  putAction("Pick TreeBase", () -> {
    UI_setTo_Modify_TreeBase(1);
  });

  putAction("Assign TreeBase", () -> {
    UI_setTo_Modify_TreeBase(2);
  });

  putAction("Change TrunkSize", () -> {
    UI_setTo_Modify_TrunkSize(0);
  });

  putAction("Pick TrunkSize", () -> {
    UI_setTo_Modify_TrunkSize(1);
  });

  putAction("Assign TrunkSize", () -> {
    UI_setTo_Modify_TrunkSize(2);
  });

  putAction("Change LeafSize", () -> {
    UI_setTo_Modify_LeafSize(0);
  });

  putAction("Pick LeafSize", () -> {
    UI_setTo_Modify_LeafSize(1);
  });

  putAction("Assign LeafSize", () -> {
    UI_setTo_Modify_LeafSize(2);
  });

  putAction("Model1DsProps", () -> {
    UI_setTo_Modify_Model1DsProps(0);
  });

  putAction("Pick Model1DsProps", () -> {
    UI_setTo_Modify_Model1DsProps(1);
  });

  putAction("Assign Model1DsProps", () -> {
    UI_setTo_Modify_Model1DsProps(2);
  });

  putAction("Orthographic", () -> {
    UI_setTo_View_ProjectionType(0);
  });

  putAction("Perspective", () -> {
    UI_setTo_View_ProjectionType(1);
  });

  putAction("Invert Selection", () -> {
    Select3D.invertSelection();
  });

  putAction("Deselect All", () -> {
    Select3D.deselectAll();
  });

  putAction("Select All", () -> {
    Select3D.selectAll();
  });

  putAction("Select All-Cameras", () -> selectAllOfCategory(ObjectCategory.CAMERA));

  putAction("Select All-Sections", () -> selectAllOfCategory(ObjectCategory.SECTION));

  putAction("Select All-Solids", () -> selectAllOfCategory(ObjectCategory.SOLID));

  putAction("Select All-Faces", () -> selectAllOfCategory(ObjectCategory.FACE));

  putAction("Select All-Polylines", () -> selectAllOfCategory(ObjectCategory.POLYLINE));

  putAction("Select All-Verices", () -> selectAllOfCategory(ObjectCategory.VERTEX));

  putAction("Select All-Groups", () -> selectAllOfCategory(ObjectCategory.GROUP));

  putAction("Select All-Model1Ds", () -> selectAllOfCategory(ObjectCategory.MODEL1D));

  putAction("Select All-Model2Ds", () -> selectAllOfCategory(ObjectCategory.MODEL2D));

  putAction("Select Solid", () -> switch_category(ObjectCategory.SOLID));

  putAction("Select Section", () -> switch_category(ObjectCategory.SECTION));

  putAction("Select Camera", () -> switch_category(ObjectCategory.CAMERA));

  putAction("Select TerrainVertex", () -> switch_category(ObjectCategory.TERRAIN));

  putAction("Select Model1Ds", () -> switch_category(ObjectCategory.MODEL1D));

  putAction("Select Model2Ds", () -> switch_category(ObjectCategory.MODEL2D));

  putAction("Select Group", () -> switch_category(ObjectCategory.GROUP));

  putAction("Select Face", () -> switch_category(ObjectCategory.FACE));

  putAction("Select Polyline", () -> switch_category(ObjectCategory.POLYLINE));

  putAction("Select Vertex", () -> switch_category(ObjectCategory.VERTEX));

  putAction("Soft Selection", () -> {
    Select3D.convert_Vertex_to_softSelection();

    switch_category(ObjectCategory.SOFTVERTEX);
  });

  putAction("Vertices >> Groups", () -> convertAndSwitch(() -> Select3D.convert_Vertices_to_Groups(), ObjectCategory.GROUP));

  putAction("Faces >> Groups", () -> convertAndSwitch(() -> Select3D.convert_Faces_to_Groups(), ObjectCategory.GROUP));

  putAction("Groups >> Faces", () -> convertAndSwitch(() -> Select3D.convert_Groups_to_Faces(), ObjectCategory.FACE));

  putAction("Polylines >> Groups", () -> convertAndSwitch(() -> Select3D.convert_Polylines_to_Groups(), ObjectCategory.GROUP));

  putAction("Groups >> Polylines", () -> convertAndSwitch(() -> Select3D.convert_Groups_to_Polylines(), ObjectCategory.POLYLINE));

  putAction("Polylines >> Vertices", () -> convertAndSwitch(() -> Select3D.convert_Polylines_to_Vertices(), ObjectCategory.VERTEX));

  putAction("Vertices >> Polylines", () -> convertAndSwitch(() -> Select3D.convert_Vertices_to_Polylines(), ObjectCategory.POLYLINE));

  putAction("Groups >> Vertices", () -> convertAndSwitch(() -> Select3D.convert_Groups_to_Vertices(), ObjectCategory.VERTEX));

  putAction("Faces >> Vertices", () -> convertAndSwitch(() -> Select3D.convert_Faces_to_Vertices(), ObjectCategory.VERTEX));

  putAction("Vertices >> Faces", () -> convertAndSwitch(() -> Select3D.convert_Vertices_to_Faces(), ObjectCategory.FACE));

  putAction("Solids >> Groups", () -> convertAndSwitch(() -> Select3D.convert_Solids_to_Groups(), ObjectCategory.GROUP));

  putAction("Groups >> Solids", () -> convertAndSwitch(() -> Select3D.convert_Groups_to_Solids(), ObjectCategory.SOLID));

  putAction("Model2Ds >> Groups", () -> convertAndSwitch(() -> Select3D.convert_Model2Ds_to_Groups(), ObjectCategory.GROUP));

  putAction("Groups >> Model2Ds", () -> convertAndSwitch(() -> Select3D.convert_Groups_to_Model2Ds(), ObjectCategory.MODEL2D));

  putAction("Model1Ds >> Groups", () -> convertAndSwitch(() -> Select3D.convert_Model1Ds_to_Groups(), ObjectCategory.GROUP));

  putAction("Groups >> Model1Ds", () -> convertAndSwitch(() -> Select3D.convert_Groups_to_Model1Ds(), ObjectCategory.MODEL1D));

  putAction("Pick Select", () -> {
    UI_setTo_View_PickSelect(0);
  });

  putAction("Pick Select+", () -> {
    UI_setTo_View_PickSelect(1);
  });

  putAction("Pick Select-", () -> {
    UI_setTo_View_PickSelect(2);
  });

  putAction("Window Select", () -> {
    UI_setTo_View_WindowSelect(0);
  });

  putAction("Window Select+", () -> {
    UI_setTo_View_WindowSelect(1);
  });

  putAction("Window Select-", () -> {
    UI_setTo_View_WindowSelect(2);
  });

  putAction("Select Near Selected Vertices", () -> {
    Select3D.selectNearVertices();
  });

  putAction("Weld Objects Selected Vertices", () -> {
    Modify3D.weldObjectsVertices_Selection(User3D.modifierWeldThreshold);
  });

  putAction("Weld Scene Selected Vertices", () -> {
    Modify3D.weldSceneVertices_Selection(User3D.modifierWeldThreshold);
  });

  putAction("Reposition Selected Vertices", () -> {
    Modify3D.repositionVertices_Selection();
  });

  putAction("Separate Selected Vertices", () -> {
    Modify3D.separateVertices_Selection();
  });

  putAction("Select Scene Isolated Vertices", () -> {
    Select3D.isolatedVertices_Scene();
  });

  putAction("Delete Scene Isolated Vertices", () -> {
    Delete3D.isolatedVertices_Scene();
  });

  putAction("Delete Selection Isolated Vertices", () -> {
    Delete3D.isolatedVertices_Selection();
  });

  putAction("Delete Scene Empty Groups", () -> {
    allGroups.deleteEmptyGroups_Scene();
  });

  putAction("Delete Selection", () -> {
    Delete3D.selection();
  });

  putAction("Dettach from Groups Selection", () -> {
    allGroups.dettachFromGroups_Selection();
  });

  putAction("Ungroup Selection", () -> {
    allGroups.ungroup_Selection();
  });

  putAction("Group Selection", () -> {
    allGroups.group_Selection(1);
  });

  putAction("Attach to Last Group", () -> {
    allGroups.group_Selection(0);
  });

  putAction("Clone Selection (Identical)", () -> {
    Clone3D.selection(true);
  });

  putAction("Clone Selection (Variation)", () -> {
    Clone3D.selection(false);
  });

  putAction("Auto-Normal Selected Faces", () -> {
    Modify3D.autoNormalFaces_Selection();
  });

  putAction("Force Triangulate Selected Faces", () -> {
    Modify3D.forceTriangulateFaces_Selection();
  });

  putAction("Insert Corner Openings", () -> {
    Modify3D.insertCornerOpenings_Selection();
  });

  putAction("Insert Parallel Openings", () -> {
    Modify3D.insertParallelOpenings_Selection();
  });

  putAction("Insert Rotated Openings", () -> {
    Modify3D.insertRotatedOpenings_Selection();
  });

  putAction("Insert Edge Openings", () -> {
    Modify3D.insertEdgeOpenings_Selection();
  });

  putAction("Optimize Faces", () -> {
    Modify3D.optimizeFace_Selection();
  });

  putAction("Tessellate Rows & Columns", () -> {
    Modify3D.tessellateRowsColumns_Selection();
  });

  putAction("Tessellate Rectangular", () -> {
    Modify3D.tessellateRectangular_Selection();
  });

  putAction("Tessellate Triangular", () -> {
    Modify3D.tessellateTriangular_Selection();
  });

  putAction("Extrude Face Edges", () -> {
    Modify3D.extrudeFaceEdges_Selection();
  });

  putAction("Offset(above) Vertices", () -> {
    Modify3D.offsetVertices_Selection(0, abs(User3D.modifierOffsetAmount));
  });

  putAction("Offset(below) Vertices", () -> {
    Modify3D.offsetVertices_Selection(0, -abs(User3D.modifierOffsetAmount));
  });

  putAction("Offset(expand) Vertices", () -> {
    Modify3D.offsetVertices_Selection(1, abs(User3D.modifierOffsetAmount));
  });

  putAction("Offset(shrink) Vertices", () -> {
    Modify3D.offsetVertices_Selection(1, -abs(User3D.modifierOffsetAmount));
  });

  putAction("Reverse Visibility of All-Faces", () -> {
    Modify3D.reverseVisibilityFaces_Scene();
  });

  putAction("Hide All-Faces", () -> {
    Modify3D.changeVisibilityFaces_Scene(0);
  });

  putAction("Unhide All-Faces", () -> {
    Modify3D.changeVisibilityFaces_Scene(1);
  });

  putAction("Hide Selected Faces", () -> {
    Modify3D.changeVisibilityFaces_Selection(0);
  });

  putAction("Unhide Selected Faces", () -> {
    Modify3D.changeVisibilityFaces_Selection(1);
  });

  putAction("Isolate Selection", () -> {
    Modify3D.isolate_Selection();
  });

  putAction("Flatten Selected Terrain Vertices", () -> {
    Modify3D.flattenTerrainVertices();
  });

  putAction("Add People on Land", () -> {
    Create3D.add_onTerrain(1); // 1 = people
  });

  putAction("Add 2D-Trees on Land", () -> {
    Create3D.add_onTerrain(2); // 2 = 2D trees
  });

  putAction("Add 1D-Trees on Land", () -> {
    Create3D.add_onTerrain(3); // 3 = 1D trees
  });

  putAction("Delete All-Model1Ds", () -> {
    allModel1Ds.makeEmpty(0);
  });

  putAction("Delete All-Model2Ds", () -> {
    allModel2Ds.makeEmpty(0);
  });

  putAction("Delete All-Groups", () -> {
    allGroups.makeEmpty(0);
  });

  putAction("Delete All-Solids", () -> {
    allSolids.makeEmpty(0);
  });

  putAction("Delete All-Sections", () -> {
    allSections.makeEmpty(0);
  });

  putAction("Delete All-Cameras", () -> {
    allCameras.makeEmpty(0);
  });

  putAction("Delete All-Faces", () -> {
    allFaces.makeEmpty(0);
  });

  putAction("Delete All-Polylines", () -> {
    allPolylines.makeEmpty(0);
  });

  putAction("Delete All", () -> {
    deleteAll();
  });

  putAction("TargetRoll", () -> {
    UI_setTo_View_TargetRoll(0);
  });

  putAction("TargetRollZ", () -> {
    UI_setTo_View_TargetRoll(1);
  });

  putAction("TargetRollXY", () -> {
    UI_setTo_View_TargetRoll(2);
  });

  putAction("CameraRoll", () -> {
    UI_setTo_View_CameraRoll(0);
  });

  putAction("CameraRollZ", () -> {
    UI_setTo_View_CameraRoll(1);
  });

  putAction("CameraRollXY", () -> {
    UI_setTo_View_CameraRoll(2);
  });

  putAction("Orbit", () -> {
    UI_setTo_View_Orbit(0);
  });

  putAction("OrbitZ", () -> {
    UI_setTo_View_Orbit(1);
  });

  putAction("OrbitXY", () -> {
    UI_setTo_View_Orbit(2);
  });

  putAction("TerrainOrbit", () -> {
    UI_setTo_View_TerrainOrbit(0);
  });

  putAction("Pan", () -> {
    UI_setTo_View_Pan(0);
  });

  putAction("PanX", () -> {
    UI_setTo_View_Pan(1);
  });

  putAction("PanY", () -> {
    UI_setTo_View_Pan(2);
  });

  putAction("Zoom", () -> {
    UI_setTo_View_ZOOM(0);
  });

  putAction("Zoom as default", () -> {
    UI_setTo_View_ZOOM(1);
  });

  putAction("TruckX", () -> {
    UI_setTo_View_Truck(1);
  });

  putAction("TruckY", () -> {
    UI_setTo_View_Truck(2);
  });

  putAction("TruckZ", () -> {
    UI_setTo_View_Truck(0);
  });

  putAction("DistZ", () -> {
    UI_setTo_View_Truck(0);
  });

  putAction("CameraDistance", () -> {
    UI_setTo_View_CameraDistance(0);
  });

  putAction("DistMouseXY", () -> {
    UI_setTo_View_DistMouseXY(0);
  });

  putAction("Look at origin", () -> {
    UI_setTo_View_LookAtOrigin(0);
  });

  putAction("Look at direction", () -> {
    UI_setTo_View_LookAtDirection(0);
  });

  putAction("Look at selection", () -> {
    UI_setTo_View_LookAtSelection(0);
  });

  putAction("3DModelSize", () -> {
    UI_setTo_View_3DModelSize();
  });

  putAction("SkydomeSize", () -> {
    UI_setTo_View_SkydomeSize();
  });

  putAction("AllModelSize", () -> {
    UI_setTo_View_AllModelSize();
  });

  putAction("Display All Viewports", () -> {
    UI_setTo_Viewport(0);
  });

  putAction("Enlarge 3D Viewport", () -> {
    UI_setTo_Viewport(1);
  });

  putAction("Enlarge Time Viewport", () -> {
    UI_setTo_Viewport(2);
  });

  putAction("Enlarge Map Viewport", () -> {
    UI_setTo_Viewport(3);
  });

  putAction("Top", () -> {
    UI_setTo_View_3DViewPoint(0);
  });

  putAction("Front", () -> {
    UI_setTo_View_3DViewPoint(1);
  });

  putAction("Left", () -> {
    UI_setTo_View_3DViewPoint(2);
  });

  putAction("Back", () -> {
    UI_setTo_View_3DViewPoint(3);
  });

  putAction("Right", () -> {
    UI_setTo_View_3DViewPoint(4);
  });

  putAction("Bottom", () -> {
    UI_setTo_View_3DViewPoint(5);
  });

  putAction("S.W.", () -> {
    UI_setTo_View_3DViewPoint(6);
  });

  putAction("S.E.", () -> {
    UI_setTo_View_3DViewPoint(7);
  });

  putAction("N.E.", () -> {
    UI_setTo_View_3DViewPoint(8);
  });

  putAction("N.W.", () -> {
    UI_setTo_View_3DViewPoint(9);
  });

  putAction("PivotX:Minimum", () -> {
    UI_setTo_View_PivotX(-1);
  });

  putAction("PivotX:Center", () -> {
    UI_setTo_View_PivotX(0);
  });

  putAction("PivotX:Maximum", () -> {
    UI_setTo_View_PivotX(1);
  });

  putAction("PivotY:Minimum", () -> {
    UI_setTo_View_PivotY(-1);
  });

  putAction("PivotY:Center", () -> {
    UI_setTo_View_PivotY(0);
  });

  putAction("PivotY:Maximum", () -> {
    UI_setTo_View_PivotY(1);
  });

  putAction("PivotZ:Minimum", () -> {
    UI_setTo_View_PivotZ(-1);
  });

  putAction("PivotZ:Center", () -> {
    UI_setTo_View_PivotZ(0);
  });

  putAction("PivotZ:Maximum", () -> {
    UI_setTo_View_PivotZ(1);
  });

  putAction("Show Ensemble Observation stations",   () -> {WORLD.ensembleObservationDisplayAll = 1; WORLD.revise();});
  putAction("Show Ensemble Observation nearest",    () -> {WORLD.ensembleObservationDisplayNear = true; WORLD.revise();});
  putAction("Show Ensemble Forecast stations",  () -> {WORLD.ensembleForecastDisplayAll = 1; WORLD.revise();});
  putAction("Show Ensemble Forecast nearest",   () -> {WORLD.ensembleForecastDisplayNear = true; WORLD.revise();});
  putAction("Show Climate Engineering stations", () -> {WORLD.climateEngineeringDisplayAll = 1; WORLD.revise();});
  putAction("Show Climate Engineering nearest",  () -> {WORLD.climateEngineeringDisplayNear = true; WORLD.revise();});
  putAction("Show Climate Archive stations", () -> {WORLD.climateArchiveDisplayAll = 1; WORLD.revise();});
  putAction("Show Climate Archive nearest",  () -> {WORLD.climateArchiveDisplayNear = true; WORLD.revise();});
  putAction("Show Climate Typical Year stations", () -> {WORLD.climateTypicalYearDisplayAll = 1; WORLD.revise();});
  putAction("Show Climate Typical Year nearest",  () -> {WORLD.climateTypicalYearDisplayNear = true; WORLD.revise();});

  putAction("Hide Ensemble Observation stations",   () -> {WORLD.ensembleObservationDisplayAll = 0; WORLD.revise();});
  putAction("Hide Ensemble Observation nearest",    () -> {WORLD.ensembleObservationDisplayNear = false; WORLD.revise();});
  putAction("Hide Ensemble Forecast stations",  () -> {WORLD.ensembleForecastDisplayAll = 0; WORLD.revise();});
  putAction("Hide Ensemble Forecast nearest",   () -> {WORLD.ensembleForecastDisplayNear = false; WORLD.revise();});
  putAction("Hide Climate Engineering stations", () -> {WORLD.climateEngineeringDisplayAll = 0; WORLD.revise();});
  putAction("Hide Climate Engineering nearest",  () -> {WORLD.climateEngineeringDisplayNear = false; WORLD.revise();});
  putAction("Hide Climate Archive stations", () -> {WORLD.climateArchiveDisplayAll = 0; WORLD.revise();});
  putAction("Hide Climate Archive nearest",  () -> {WORLD.climateArchiveDisplayNear = false; WORLD.revise();});
  putAction("Hide Climate Typical Year stations", () -> {WORLD.climateTypicalYearDisplayAll = 0; WORLD.revise();});
  putAction("Hide Climate Typical Year nearest",  () -> {WORLD.climateTypicalYearDisplayNear = false; WORLD.revise();});

  putAction("Show Terrain Mesh",     () -> {Terrain.displaySurface = true; view_changed();});
  putAction("Show Terrain Texture",  () -> {Terrain.displayTexture = true; view_changed();});
  putAction("Show Terrain Vertices",   () -> {Terrain.displayPoints = true; view_changed();});
  putAction("Show Terrain Depth",    () -> {Terrain.displayDepth = true; view_changed();});
  putAction("Show Vertices",      () -> {allPoints.displayAll = true; view_changed();});
  putAction("Show Edges",         () -> {allFaces.displayEdges = true; view_changed();});
  putAction("Show Normals",       () -> {allFaces.showNormalLines = true; view_changed();});
  putAction("Show Leaves",        () -> {allModel1Ds.displayLeaves = true; view_changed();});
  putAction("Show Model1Ds",      () -> {allModel1Ds.displayAll = true; view_changed();});
  putAction("Show Model2Ds",      () -> {allModel2Ds.displayAll = true; view_changed();});
  putAction("Show Polylines",     () -> {allPolylines.displayAll = true; view_changed();});
  putAction("Show Faces",         () -> {allFaces.displayAll = true; view_changed();});
  putAction("Show Solids",        () -> {allSolids.displayAll = true; view_changed();});
  putAction("Show Sections",      () -> {allSections.displayAll = true; view_changed();});
  putAction("Show Cameras",       () -> {allCameras.displayAll = true; view_changed();});
  putAction("Show Sky",           () -> {Sky3D.displaySurface = true; view_changed();});
  putAction("Show Sun Grid",      () -> {Sun3D.displayGrid = true; view_changed();});
  putAction("Show Sun Path",      () -> {Sun3D.displayPath = true; view_changed();});
  putAction("Show Sun Pattern",   () -> {Sun3D.displayPattern = true; view_changed();});
  putAction("Show Sun Surface",   () -> {Sun3D.displaySurface = true; view_changed();});
  putAction("Show Moon Surface",  () -> {Moon3D.displaySurface = true; view_changed();});
  putAction("Show Earth Surface", () -> {Earth3D.displaySurface = true; view_changed();});
  putAction("Show Troposphere",   () -> {Tropo3D.displaySurface = true; view_changed();});
  putAction("Show Solar Section", () -> {allSolarImpacts.displayImage = true; view_changed();});
  putAction("Show Solid Section", () -> {allSolidImpacts.displayImage = true; view_changed();});
  putAction("Show Wind Flow",     () -> {allWindFlows.displayAll = true; view_changed();});

  putAction("Hide Terrain Mesh",     () -> {Terrain.displaySurface = false; view_changed();});
  putAction("Hide Terrain Texture",  () -> {Terrain.displayTexture = false; view_changed();});
  putAction("Hide Terrain Vertices",   () -> {Terrain.displayPoints = false; view_changed();});
  putAction("Hide Terrain Depth",    () -> {Terrain.displayDepth = false; view_changed();});
  putAction("Hide Vertices",      () -> {allPoints.displayAll = false; view_changed();});
  putAction("Hide Edges",         () -> {allFaces.displayEdges = false; view_changed();});
  putAction("Hide Normals",       () -> {allFaces.showNormalLines = false; view_changed();});
  putAction("Hide Leaves",        () -> {allModel1Ds.displayLeaves = false; view_changed();});
  putAction("Hide Model1Ds",      () -> {allModel1Ds.displayAll = false; view_changed();});
  putAction("Hide Model2Ds",      () -> {allModel2Ds.displayAll = false; view_changed();});
  putAction("Hide Polylines",     () -> {allPolylines.displayAll = false; view_changed();});
  putAction("Hide Faces",         () -> {allFaces.displayAll = false; view_changed();});
  putAction("Hide Solids",        () -> {allSolids.displayAll = false; view_changed();});
  putAction("Hide Sections",      () -> {allSections.displayAll = false; view_changed();});
  putAction("Hide Cameras",       () -> {allCameras.displayAll = false; view_changed();});
  putAction("Hide Sky",           () -> {Sky3D.displaySurface = false; view_changed();});
  putAction("Hide Sun Grid",      () -> {Sun3D.displayGrid = false; view_changed();});
  putAction("Hide Sun Path",      () -> {Sun3D.displayPath = false; view_changed();});
  putAction("Hide Sun Pattern",   () -> {Sun3D.displayPattern = false; view_changed();});
  putAction("Hide Sun Surface",   () -> {Sun3D.displaySurface = false; view_changed();});
  putAction("Hide Moon Surface",  () -> {Moon3D.displaySurface = false; view_changed();});
  putAction("Hide Earth Surface", () -> {Earth3D.displaySurface = false; view_changed();});
  putAction("Hide Troposphere",   () -> {Tropo3D.displaySurface = false; view_changed();});
  putAction("Hide Solar Section", () -> {allSolarImpacts.displayImage = false; view_changed();});
  putAction("Hide Solid Section", () -> {allSolidImpacts.displayImage = false; view_changed();});
  putAction("Hide Wind Flow",     () -> {allWindFlows.displayAll = false; view_changed();});


  putAction("Show Selected Solids",                 () -> {Select3D.solidDisplayEdges = true; view_changed();});
  putAction("Show Selected Sections",               () -> {Select3D.sectionDisplayEdges = true; view_changed();});
  putAction("Show Selected Cameras",                () -> {Select3D.cameraDisplayFrustum = true; view_changed();});
  putAction("Show Selected Terrain Vertices",             () -> {Select3D.terrainDisplayVertices = true; view_changed();});
  putAction("Show Selected Faces Edges",            () -> {Select3D.faceDisplayEdges = true; view_changed();});
  putAction("Show Selected Polylines",              () -> {Select3D.polylineDisplayVertices = true; view_changed();});
  putAction("Show Selected Faces Vertex Count",     () -> {Select3D.faceDisplayvertexSelection = true; view_changed();});
  putAction("Show Selected Polylines Vertex Count", () -> {Select3D.polylineDisplayvertexSelection = true; view_changed();});
  putAction("Show Selected Vertices",               () -> {Select3D.vertexDisplayMarkers = true; view_changed();});
  putAction("Show Selected REF Pivot",              () -> {Select3D.pivotDisplayReference = true; view_changed();});
  putAction("Show Selected Group Pivot",            () -> {Select3D.groupDisplayPivot = true; view_changed();});
  putAction("Show Selected Group Edges",            () -> {Select3D.groupDisplayEdges = true; view_changed();});
  putAction("Show Selected Group Box",              () -> {Select3D.groupDisplayBox = true; view_changed();});
  putAction("Show Selected 2D Edges",               () -> {Select3D.model2DDisplayBounds = true; view_changed();});
  putAction("Show Selected 1D Edges",               () -> {Select3D.model1DDisplayBounds = true; view_changed();});

  putAction("Hide Selected Solids",                 () -> {Select3D.solidDisplayEdges = false; view_changed();});
  putAction("Hide Selected Sections",               () -> {Select3D.sectionDisplayEdges = false; view_changed();});
  putAction("Hide Selected Cameras",                () -> {Select3D.cameraDisplayFrustum = false; view_changed();});
  putAction("Hide Selected Terrain Vertices",             () -> {Select3D.terrainDisplayVertices = false; view_changed();});
  putAction("Hide Selected Faces Edges",            () -> {Select3D.faceDisplayEdges = false; view_changed();});
  putAction("Hide Selected Polylines",              () -> {Select3D.polylineDisplayVertices = false; view_changed();});
  putAction("Hide Selected Faces Vertex Count",     () -> {Select3D.faceDisplayvertexSelection = false; view_changed();});
  putAction("Hide Selected Polylines Vertex Count", () -> {Select3D.polylineDisplayvertexSelection = false; view_changed();});
  putAction("Hide Selected Vertices",               () -> {Select3D.vertexDisplayMarkers = false; view_changed();});
  putAction("Hide Selected REF Pivot",              () -> {Select3D.pivotDisplayReference = false; view_changed();});
  putAction("Hide Selected Group Pivot",            () -> {Select3D.groupDisplayPivot = false; view_changed();});
  putAction("Hide Selected Group Edges",            () -> {Select3D.groupDisplayEdges = false; view_changed();});
  putAction("Hide Selected Group Box",              () -> {Select3D.groupDisplayBox = false; view_changed();});
  putAction("Hide Selected 2D Edges",               () -> {Select3D.model2DDisplayBounds = false; view_changed();});
  putAction("Hide Selected 1D Edges",               () -> {Select3D.model1DDisplayBounds = false; view_changed();});

  for (int n = -2; n <= 8; n++) {
    final int layoutIndex = n;
    putAction("Layout " + nf(layoutIndex, 0), () -> {
      STUDY.plotLayoutIndex = layoutIndex;
      STUDY.revise();
    });
  }

  for (int n = 1; n <= 11; n++) {
    final int modelIndex = n;
    putAction("3D-model " + nf(modelIndex, 0), () -> {
      deleteAll();
      Create3D.add_DefaultModel(modelIndex);
      allSolidImpacts.calculate_Impact_selectedSections();
      UI_rollout.revise();
      WIN3D.revise();
    });
  }

  UI_rollout.registerSpinnerActions();

  //allActions.keySet().stream().sorted().forEach(System.out::println);
}

void requestStudyRedraw () {
  STUDY.revise();
}

void requestWorldRedraw () {
  WORLD.revise();
}
