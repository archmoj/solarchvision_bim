HashMap<String, Runnable> allActions;

private void putAction(String s, Runnable fn) {
    String lower = s.toLowerCase();
    allActions.put(lower, fn); // put lowercase
}

void build_allActions() {
  allActions = new HashMap<String, Runnable>();

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
    exit();
  });

  putAction("Wind pattern (active)", () -> setPlotImpacts(PlotImpacts_WIND_ACTIVE, true));

  putAction("Wind pattern (passive)", () -> setPlotImpacts(PlotImpacts_WIND_PASSIVE, true));

  putAction("Urban solar potential (active)", () -> setPlotImpacts(PlotImpacts_URBAN_ACTIVE, false));

  putAction("Urban solar potential (passive)", () -> setPlotImpacts(PlotImpacts_URBAN_PASSIVE, false));

  putAction("Orientation potential (active)", () -> setPlotImpacts(PlotImpacts_GLOBAL_ACTIVE, false));

  putAction("Orientation potential (passive)", () -> setPlotImpacts(PlotImpacts_GLOBAL_PASSIVE, false));

  putAction("Hourly sun position (active)", () -> setPlotImpacts(PlotImpacts_SUNPATH_ACTIVE, false));

  putAction("Hourly sun position (passive)", () -> setPlotImpacts(PlotImpacts_SUNPATH_PASSIVE, false));

  putAction("Annual cycle sun path (active)", () -> setPlotImpacts(PlotImpacts_CYCLES_ACTIVE, false));

  putAction("Annual cycle sun path (passive)", () -> setPlotImpacts(PlotImpacts_CYCLES_PASSIVE, false));

  putAction("Prebake Selected Sections", () -> {
    allSolarImpacts.render_Shadows_selectedSections();

    view_changed();
  });

  putAction("Process Active Impact", () -> {
    STUDY.PlotImpacts = PlotImpacts_URBAN_ACTIVE;
    allSolarImpacts.calculate_Impact_selectedSections();

    view_changed();
  });

  putAction("Process Passive Impact", () -> {
    STUDY.PlotImpacts = PlotImpacts_URBAN_PASSIVE;
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

  // Each of these 5 menu actions used to reset the same 12 recording
  // flags to false and then flip exactly one of them true. Pulling the
  // reset into stopAllRecording() means each action states
  // only what's actually different: which flag turns on.
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

  putAction("Load Land Mesh", () -> {
    Land3D.update_textures();
  });

  putAction("Load Land Texture", () -> {
    Land3D.update_textures();
  });

  putAction("Download Land Mesh", () -> {
    Land3D.download_mesh();
  });

  putAction("Download Land Texture", () -> {
    Land3D.download_textures();
  });

  putAction("Load Toroposphere", () -> {
    Tropo3D.download_images();
    Tropo3D.displaySurface = true;
    WORLD.revise();
    WIN3D.revise();
  });

  putAction("Download SWOB", () -> {
    download_ENSEMBLE_OBSERVED(TIME.year, TIME.month, TIME.day, TIME.hour);;
  });

  putAction("Download NAEFS", () -> {
    download_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);
  });

  putAction("Download CLMREC", () -> {
    download_CLIMATE_CLMREC();
  });

  putAction("Download TMYEPW", () -> {
    download_CLIMATE_TMYEPW();
  });

  putAction("Update TMYEPW", () -> {
    CurrentDataSource = dataID_CLIMATE_TMYEPW;

    CLIMATE_TMYEPW_load = true;
    update_CLIMATE_TMYEPW();
  });

  putAction("Update CWEEDS", () -> {
    CurrentDataSource = dataID_CLIMATE_CWEEDS;

    CLIMATE_CWEEDS_load = true;
    update_CLIMATE_CWEEDS();
  });

  putAction("Update CLMREC", () -> {
    CurrentDataSource = dataID_CLIMATE_CLMREC;

    CLIMATE_CLMREC_load = true;
    update_CLIMATE_CLMREC();
  });

  putAction("Update SWOB", () -> {
    CurrentDataSource = dataID_ENSEMBLE_OBSERVED;

    ENSEMBLE_OBSERVED_load = true;
    update_ENSEMBLE_OBSERVED(TIME.year, TIME.month, TIME.day, TIME.hour);
  });

  putAction("Update NAEFS", () -> {
    CurrentDataSource = dataID_ENSEMBLE_FORECAST;

    ENSEMBLE_FORECAST_load = true;
    update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);
  });



  putAction("Use typical year (TMY)", () -> {
    CurrentDataSource = dataID_CLIMATE_TMYEPW;

    CLIMATE_TMYEPW_load = true;
    update_CLIMATE_TMYEPW();

    view_changed();
    WORLD.revise();
    STUDY.revise();
    UI_rollout.revise();
    UI_caseBar.revise();

    WORLD.hideAllMarkersAndLabels();
    WORLD.displayAll_TMYEPW = 1;
    WORLD.displayNear_TMYEPW = true;
  });

  putAction("Use long-term (CWEEDS)", () -> {
    CurrentDataSource = dataID_CLIMATE_CWEEDS;

    CLIMATE_CWEEDS_load = true;
    update_CLIMATE_CWEEDS();

    view_changed();
    WORLD.revise();
    STUDY.revise();
    UI_rollout.revise();
    UI_caseBar.revise();

    WORLD.hideAllMarkersAndLabels();
    WORLD.displayAll_CWEEDS = 1;
    WORLD.displayNear_CWEEDS = true;
  });

  putAction("Use long-term (CLMREC)", () -> {
    CurrentDataSource = dataID_CLIMATE_CLMREC;

    CLIMATE_CLMREC_load = true;
    update_CLIMATE_CLMREC();

    view_changed();
    WORLD.revise();
    STUDY.revise();
    UI_rollout.revise();
    UI_caseBar.revise();

    WORLD.hideAllMarkersAndLabels();
    WORLD.displayAll_CLMREC = 1;
    WORLD.displayNear_CLMREC = true;
  });

  putAction("Use real-time observed (SWOB)", () -> {
    CurrentDataSource = dataID_ENSEMBLE_OBSERVED;
    STUDY.joinDays = 1;

    ENSEMBLE_OBSERVED_load = true;
    update_ENSEMBLE_OBSERVED(TIME.year, TIME.month, TIME.day, TIME.hour);

    view_changed();
    WORLD.revise();
    STUDY.revise();
    UI_rollout.revise();
    UI_caseBar.revise();

    WORLD.hideAllMarkersAndLabels();
    WORLD.displayAll_SWOB = 1;
    WORLD.displayNear_SWOB = true;
  });

  putAction("Use weather forecast (NAEFS)", () -> {
    CurrentDataSource = dataID_ENSEMBLE_FORECAST;
    STUDY.joinDays = 1;

    ENSEMBLE_FORECAST_load = true;
    update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);

    view_changed();
    WIN3D.revise();
    STUDY.revise();
    UI_rollout.revise();
    UI_caseBar.revise();

    WORLD.hideAllMarkersAndLabels();
    WORLD.displayAll_NAEFS = 1;
    WORLD.displayNear_NAEFS = true;
  });

  putAction("Active Shade", () -> {
    WIN3D.Impact_TYPE = Impact_ACTIVE;

    if (WIN3D.FacesShade == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
    if (WIN3D.FacesShade == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;

    view_changed();
  });

  putAction("Passive Shade", () -> {
    WIN3D.Impact_TYPE = Impact_PASSIVE;

    if (WIN3D.FacesShade == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
    if (WIN3D.FacesShade == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;

    view_changed();
  });

  putAction("Shade Surface Wire", () -> {
    WIN3D.FacesShade = SHADE.Surface_Wire;
    allFaces.displayEdges = true; //<<<<<<<<<<<<<<<

    view_changed();
  });

  putAction("Shade Surface Base", () -> {
    WIN3D.FacesShade = SHADE.Surface_Base;

    view_changed();
  });

  putAction("Shade Surface White", () -> {
    WIN3D.FacesShade = SHADE.Surface_White;

    view_changed();
  });

  putAction("Shade Surface Materials", () -> {
    WIN3D.FacesShade = SHADE.Surface_Materials;

    view_changed();
  });

  putAction("Shade Global Solar", () -> {
    WIN3D.FacesShade = SHADE.Global_Solar;

    GlobalSolar_rebuild_array = true;

    view_changed();
  });

  putAction("Shade Vertex Solar", () -> {
    WIN3D.FacesShade = SHADE.Vertex_Solar;

    VertexSolar_rebuild_array = true;

    view_changed();
  });

  putAction("Shade Vertex Solid", () -> {
    WIN3D.FacesShade = SHADE.Vertex_Solid;

    view_changed();
  });

  putAction("Shade Vertex Elevation", () -> {
    WIN3D.FacesShade = SHADE.Vertex_Elevation;

    view_changed();
  });

  putAction("Shade Viewport", () -> {
    ShadeViewport();
  });

  putAction("Prebake Viewport", () -> {
    preBakeViewport();
  });

  putAction("Show/Hide Land Mesh", () -> {
    Land3D.displaySurface = !Land3D.displaySurface;

    view_changed();
  });

  putAction("Show/Hide Land Texture", () -> {
    Land3D.displayTexture = !Land3D.displayTexture;

    view_changed();
  });

  putAction("Show/Hide Land Points", () -> {
    Land3D.displayPoints = !Land3D.displayPoints;

    view_changed();
  });

  putAction("Show/Hide Land Depth", () -> {
    Land3D.displayDepth = !Land3D.displayDepth;

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
    allFaces.displayNormals = !allFaces.displayNormals;

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
    Select3D.Solid_displayEdges = !Select3D.Solid_displayEdges;

    view_changed();
  });

  putAction("Show/Hide Selected Sections", () -> {
    Select3D.Section_displayEdges = !Select3D.Section_displayEdges;

    view_changed();
  });

  putAction("Show/Hide Selected Cameras", () -> {
    Select3D.Camera_displayEdges = !Select3D.Camera_displayEdges;

    view_changed();
  });

  putAction("Show/Hide Selected LandPoints", () -> {
    Select3D.LandPoint_displayPoints = !Select3D.LandPoint_displayPoints;

    view_changed();
  });

  putAction("Show/Hide Wind Flow", () -> {
    allWindFlows.displayAll = !allWindFlows.displayAll;

    view_changed();
  });

  putAction("Show/Hide Selected Faces", () -> {
    Select3D.Face_displayEdges = !Select3D.Face_displayEdges;

    view_changed();
  });

  putAction("Show/Hide Selected Faces Vertex Count", () -> {
    Select3D.Face_displayVertexCount = !Select3D.Face_displayVertexCount;

    view_changed();
  });

  putAction("Show/Hide Selected Polylines Vertex Count", () -> {
    Select3D.Polyline_displayVertexCount = !Select3D.Polyline_displayVertexCount;

    view_changed();
  });

  putAction("Show/Hide Selected Vertices", () -> {
    Select3D.Vertex_displayVertices = !Select3D.Vertex_displayVertices;

    view_changed();
  });

  putAction("Show/Hide Selected Polylines", () -> {
    Select3D.Polyline_displayVertices = !Select3D.Polyline_displayVertices;

    view_changed();
  });

  putAction("Show/Hide Selected REF Pivot", () -> {
    Select3D.displayReferencePivot = !Select3D.displayReferencePivot;

    view_changed();
  });

  putAction("Show/Hide Selected Group Pivot", () -> {
    Select3D.Group_displayPivot = !Select3D.Group_displayPivot;

    view_changed();
  });

  putAction("Show/Hide Selected Group Edges", () -> {
    Select3D.Group_displayEdges = !Select3D.Group_displayEdges;

    view_changed();
  });

  putAction("Show/Hide Selected Group Box", () -> {
    Select3D.Group_displayBox = !Select3D.Group_displayBox;

    view_changed();;
  });

  putAction("Show/Hide Selected 2D Edges", () -> {
    Select3D.Model2D_displayEdges = !Select3D.Model2D_displayEdges;

    view_changed();
  });

  putAction("Show/Hide Selected 1D Edges", () -> {
    Select3D.Model1D_displayEdges = !Select3D.Model1D_displayEdges;

    view_changed();
  });

  putAction("Show/Hide SWOB stations", () -> {
    WORLD.displayAll_SWOB = (WORLD.displayAll_SWOB + 1) % 2;

    WORLD.revise();
  });

  putAction("Show/Hide SWOB nearest", () -> {
    WORLD.displayNear_SWOB = !WORLD.displayNear_SWOB;

    WORLD.revise();
  });

  putAction("Show/Hide NAEFS stations", () -> {
    WORLD.displayAll_NAEFS = (WORLD.displayAll_NAEFS + 1) % 2;

    WORLD.revise();
  });

  putAction("Show/Hide NAEFS nearest", () -> {
    WORLD.displayNear_NAEFS = !WORLD.displayNear_NAEFS;

    WORLD.revise();
  });

  putAction("Show/Hide CWEEDS stations", () -> {
    WORLD.displayAll_CWEEDS = (WORLD.displayAll_CWEEDS + 1) % 2;

    WORLD.revise();
  });

  putAction("Show/Hide CWEEDS nearest", () -> {
    WORLD.displayNear_CWEEDS = !WORLD.displayNear_CWEEDS;

    WORLD.revise();
  });

  putAction("Show/Hide CLMREC stations", () -> {
    WORLD.displayAll_CLMREC = (WORLD.displayAll_CLMREC + 1) % 2;

    WORLD.revise();
  });

  putAction("Show/Hide CLMREC nearest", () -> {
    WORLD.displayNear_CLMREC = !WORLD.displayNear_CLMREC;

    WORLD.revise();
  });

  putAction("Show/Hide TMYEPW stations", () -> {
    WORLD.displayAll_TMYEPW = (WORLD.displayAll_TMYEPW + 1) % 2;

    WORLD.revise();
  });

  putAction("Show/Hide TMYEPW nearest", () -> {
    WORLD.displayNear_TMYEPW = !WORLD.displayNear_TMYEPW;

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

    Select3D.Group_ids = new int [1];
    Select3D.Group_ids[0] = allGroups.num - 1;

    model_changed();
  });

  putAction("Begin New Group at Pivot", () -> {
    allGroups.beginNewGroup(Select3D.BoundingBox[1 + Select3D.alignX][0], Select3D.BoundingBox[1 + Select3D.alignX][1], Select3D.BoundingBox[1 + Select3D.alignX][2], Select3D.BoundingBox[1 + Select3D.alignX][3], Select3D.BoundingBox[1 + Select3D.alignX][4], Select3D.BoundingBox[1 + Select3D.alignX][5], Select3D.BoundingBox[1 + Select3D.alignX][6], Select3D.BoundingBox[1 + Select3D.alignX][7], Select3D.BoundingBox[1 + Select3D.alignX][8]);

    Select3D.Group_ids = new int [1];
    Select3D.Group_ids[0] = allGroups.num - 1;

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
    float Camera_pX = WIN3D.position_X;
    float Camera_pY = WIN3D.position_Y;
    float Camera_pZ = WIN3D.position_Z;
    float Camera_pT = WIN3D.position_T;
    float Camera_rX = WIN3D.rotation_X;
    float Camera_rY = WIN3D.rotation_Y;
    float Camera_rZ = WIN3D.rotation_Z;
    float Camera_rT = WIN3D.rotation_T;
    float Camera_zoom = WIN3D.Zoom;

    int Camera_type = WIN3D.ViewType;

    allCameras.create(Camera_pX, Camera_pY, Camera_pZ, Camera_pT, Camera_rX, Camera_rY, Camera_rZ, Camera_rT, Camera_zoom, Camera_type);

    WIN3D.currentCamera = allCameras.num - 1;
    WIN3D.apply_currentCamera();
    modify_Viewport_Title();

    view_changed();

    UI_toolBar.revise();
  });

  putAction("Camera >> Viewport", () -> {
    allCameras.set_posX(0, allCameras.get_posX(WIN3D.currentCamera));
    allCameras.set_posY(0, allCameras.get_posY(WIN3D.currentCamera));
    allCameras.set_posZ(0, allCameras.get_posZ(WIN3D.currentCamera));
    allCameras.set_posT(0, allCameras.get_posT(WIN3D.currentCamera));
    allCameras.set_rotX(0, allCameras.get_rotX(WIN3D.currentCamera));
    allCameras.set_rotY(0, allCameras.get_rotY(WIN3D.currentCamera));
    allCameras.set_rotZ(0, allCameras.get_rotZ(WIN3D.currentCamera));
    allCameras.set_rotT(0, allCameras.get_rotT(WIN3D.currentCamera));
    allCameras.set_zoom(0, allCameras.get_zoom(WIN3D.currentCamera));
    allCameras.set_type(0, allCameras.get_type(WIN3D.currentCamera));

    WIN3D.currentCamera = 0;
    modify_Viewport_Title();

    view_changed();

    UI_toolBar.revise();
  });

  putAction("Camera View", () -> {
    if (Select3D.Camera_ids.length > 0) {
      WIN3D.currentCamera = Select3D.Camera_ids[Select3D.Camera_ids.length - 1];
      WIN3D.apply_currentCamera();
      modify_Viewport_Title();

      view_changed();

      UI_toolBar.revise();
    }
  });

  putAction("LandMesh >> Group", () -> {
    Land3D.draw(TypeWindow.LandMesh);

    model_changed();
  });

  putAction("LandGap >> Group", () -> {
    Land3D.draw(TypeWindow.LandGap);

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

  putAction("Select All Cameras", () -> selectAllOfCategory(ObjectCategory.CAMERA));

  putAction("Select All Sections", () -> selectAllOfCategory(ObjectCategory.SECTION));

  putAction("Select All Solids", () -> selectAllOfCategory(ObjectCategory.SOLID));

  putAction("Select All Faces", () -> selectAllOfCategory(ObjectCategory.FACE));

  putAction("Select All Polylines", () -> selectAllOfCategory(ObjectCategory.POLYLINE));

  putAction("Select All Verices", () -> selectAllOfCategory(ObjectCategory.VERTEX));

  putAction("Select All Groups", () -> selectAllOfCategory(ObjectCategory.GROUP));

  putAction("Select All Model1Ds", () -> selectAllOfCategory(ObjectCategory.MODEL1D));

  putAction("Select All Model2Ds", () -> selectAllOfCategory(ObjectCategory.MODEL2D));

  putAction("Select Solid", () -> switch_category(ObjectCategory.SOLID));

  putAction("Select Section", () -> switch_category(ObjectCategory.SECTION));

  putAction("Select Camera", () -> switch_category(ObjectCategory.CAMERA));

  putAction("Select LandPoint", () -> switch_category(ObjectCategory.LANDPOINT));

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
    Modify3D.weldObjectsVertices_Selection(User3D.modify_WeldTreshold);
  });

  putAction("Weld Scene Selected Vertices", () -> {
    Modify3D.weldSceneVertices_Selection(User3D.modify_WeldTreshold);
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

  putAction("Insert Corner Opennings", () -> {
    Modify3D.insertCornerOpennings_Selection();
  });

  putAction("Insert Parallel Opennings", () -> {
    Modify3D.insertParallelOpennings_Selection();
  });

  putAction("Insert Rotated Opennings", () -> {
    Modify3D.insertRotatedOpennings_Selection();
  });

  putAction("Insert Edge Opennings", () -> {
    Modify3D.insertEdgeOpennings_Selection();
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
    Modify3D.offsetVertices_Selection(0, abs(User3D.modify_OffsetAmount));
  });

  putAction("Offset(below) Vertices", () -> {
    Modify3D.offsetVertices_Selection(0, -abs(User3D.modify_OffsetAmount));
  });

  putAction("Offset(expand) Vertices", () -> {
    Modify3D.offsetVertices_Selection(1, abs(User3D.modify_OffsetAmount));
  });

  putAction("Offset(shrink) Vertices", () -> {
    Modify3D.offsetVertices_Selection(1, -abs(User3D.modify_OffsetAmount));
  });

  putAction("Reverse Visibility of All Faces", () -> {
    Modify3D.reverseVisibilityFaces_Scene();
  });

  putAction("Hide All Faces", () -> {
    Modify3D.changeVisibilityFaces_Scene(0);
  });

  putAction("Unhide All Faces", () -> {
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

  putAction("Flatten Selected LandPoints", () -> {
    Modify3D.flatten_LandPoints();
  });

  putAction("Add People on Land", () -> {
    Create3D.add_onLand(1); // 1 = people
  });

  putAction("Add 2D-Trees on Land", () -> {
    Create3D.add_onLand(2); // 2 = 2D trees
  });

  putAction("Add 1D-Trees on Land", () -> {
    Create3D.add_onLand(3); // 3 = 1D trees
  });

  putAction("Delete All Model1Ds", () -> {
    allModel1Ds.makeEmpty(0);
  });

  putAction("Delete All Model2Ds", () -> {
    allModel2Ds.makeEmpty(0);
  });

  putAction("Delete All Groups", () -> {
    allGroups.makeEmpty(0);
  });

  putAction("Delete All Solids", () -> {
    allSolids.makeEmpty(0);
  });

  putAction("Delete All Sections", () -> {
    allSections.makeEmpty(0);
  });

  putAction("Delete All Cameras", () -> {
    allCameras.makeEmpty(0);
  });

  putAction("Delete All Faces", () -> {
    allFaces.makeEmpty(0);
  });

  putAction("Delete All Polylines", () -> {
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

  putAction("LandOrbit", () -> {
    UI_setTo_View_LandOrbit(0);
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

  putAction("Show SWOB stations",   () -> {WORLD.displayAll_SWOB = 1; WORLD.revise();});
  putAction("Show SWOB nearest",    () -> {WORLD.displayNear_SWOB = true; WORLD.revise();});
  putAction("Show NAEFS stations",  () -> {WORLD.displayAll_NAEFS = 1; WORLD.revise();});
  putAction("Show NAEFS nearest",   () -> {WORLD.displayNear_NAEFS = true; WORLD.revise();});
  putAction("Show CWEEDS stations", () -> {WORLD.displayAll_CWEEDS = 1; WORLD.revise();});
  putAction("Show CWEEDS nearest",  () -> {WORLD.displayNear_CWEEDS = true; WORLD.revise();});
  putAction("Show CLMREC stations", () -> {WORLD.displayAll_CLMREC = 1; WORLD.revise();});
  putAction("Show CLMREC nearest",  () -> {WORLD.displayNear_CLMREC = true; WORLD.revise();});
  putAction("Show TMYEPW stations", () -> {WORLD.displayAll_TMYEPW = 1; WORLD.revise();});
  putAction("Show TMYEPW nearest",  () -> {WORLD.displayNear_TMYEPW = true; WORLD.revise();});

  putAction("Hide SWOB stations",   () -> {WORLD.displayAll_SWOB = 0; WORLD.revise();});
  putAction("Hide SWOB nearest",    () -> {WORLD.displayNear_SWOB = false; WORLD.revise();});
  putAction("Hide NAEFS stations",  () -> {WORLD.displayAll_NAEFS = 0; WORLD.revise();});
  putAction("Hide NAEFS nearest",   () -> {WORLD.displayNear_NAEFS = false; WORLD.revise();});
  putAction("Hide CWEEDS stations", () -> {WORLD.displayAll_CWEEDS = 0; WORLD.revise();});
  putAction("Hide CWEEDS nearest",  () -> {WORLD.displayNear_CWEEDS = false; WORLD.revise();});
  putAction("Hide CLMREC stations", () -> {WORLD.displayAll_CLMREC = 0; WORLD.revise();});
  putAction("Hide CLMREC nearest",  () -> {WORLD.displayNear_CLMREC = false; WORLD.revise();});
  putAction("Hide TMYEPW stations", () -> {WORLD.displayAll_TMYEPW = 0; WORLD.revise();});
  putAction("Hide TMYEPW nearest",  () -> {WORLD.displayNear_TMYEPW = false; WORLD.revise();});

  putAction("Show Land Mesh",     () -> {Land3D.displaySurface = true; view_changed();});
  putAction("Show Land Texture",  () -> {Land3D.displayTexture = true; view_changed();});
  putAction("Show Land Points",   () -> {Land3D.displayPoints = true; view_changed();});
  putAction("Show Land Depth",    () -> {Land3D.displayDepth = true; view_changed();});
  putAction("Show Vertices",      () -> {allPoints.displayAll = true; view_changed();});
  putAction("Show Edges",         () -> {allFaces.displayEdges = true; view_changed();});
  putAction("Show Normals",       () -> {allFaces.displayNormals = true; view_changed();});
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

  putAction("Hide Land Mesh",     () -> {Land3D.displaySurface = false; view_changed();});
  putAction("Hide Land Texture",  () -> {Land3D.displayTexture = false; view_changed();});
  putAction("Hide Land Points",   () -> {Land3D.displayPoints = false; view_changed();});
  putAction("Hide Land Depth",    () -> {Land3D.displayDepth = false; view_changed();});
  putAction("Hide Vertices",      () -> {allPoints.displayAll = false; view_changed();});
  putAction("Hide Edges",         () -> {allFaces.displayEdges = false; view_changed();});
  putAction("Hide Normals",       () -> {allFaces.displayNormals = false; view_changed();});
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


  putAction("Show Selected Solids",                 () -> {Select3D.Solid_displayEdges = true; view_changed();});
  putAction("Show Selected Sections",               () -> {Select3D.Section_displayEdges = true; view_changed();});
  putAction("Show Selected Cameras",                () -> {Select3D.Camera_displayEdges = true; view_changed();});
  putAction("Show Selected LandPoints",             () -> {Select3D.LandPoint_displayPoints = true; view_changed();});
  putAction("Show Selected Faces",                  () -> {Select3D.Face_displayEdges = true; view_changed();});
  putAction("Show Selected Polylines",              () -> {Select3D.Polyline_displayVertices = true; view_changed();});
  putAction("Show Selected Faces Vertex Count",     () -> {Select3D.Face_displayVertexCount = true; view_changed();});
  putAction("Show Selected Polylines Vertex Count", () -> {Select3D.Polyline_displayVertexCount = true; view_changed();});
  putAction("Show Selected Vertices",               () -> {Select3D.Vertex_displayVertices = true; view_changed();});
  putAction("Show Selected REF Pivot",              () -> {Select3D.displayReferencePivot = true; view_changed();});
  putAction("Show Selected Group Pivot",            () -> {Select3D.Group_displayPivot = true; view_changed();});
  putAction("Show Selected Group Edges",            () -> {Select3D.Group_displayEdges = true; view_changed();});
  putAction("Show Selected Group Box",              () -> {Select3D.Group_displayBox = true; view_changed();});
  putAction("Show Selected 2D Edges",               () -> {Select3D.Model2D_displayEdges = true; view_changed();});
  putAction("Show Selected 1D Edges",               () -> {Select3D.Model1D_displayEdges = true; view_changed();});

  putAction("Hide Selected Solids",                 () -> {Select3D.Solid_displayEdges = false; view_changed();});
  putAction("Hide Selected Sections",               () -> {Select3D.Section_displayEdges = false; view_changed();});
  putAction("Hide Selected Cameras",                () -> {Select3D.Camera_displayEdges = false; view_changed();});
  putAction("Hide Selected LandPoints",             () -> {Select3D.LandPoint_displayPoints = false; view_changed();});
  putAction("Hide Selected Faces",                  () -> {Select3D.Face_displayEdges = false; view_changed();});
  putAction("Hide Selected Polylines",              () -> {Select3D.Polyline_displayVertices = false; view_changed();});
  putAction("Hide Selected Faces Vertex Count",     () -> {Select3D.Face_displayVertexCount = false; view_changed();});
  putAction("Hide Selected Polylines Vertex Count", () -> {Select3D.Polyline_displayVertexCount = false; view_changed();});
  putAction("Hide Selected Vertices",               () -> {Select3D.Vertex_displayVertices = false; view_changed();});
  putAction("Hide Selected REF Pivot",              () -> {Select3D.displayReferencePivot = false; view_changed();});
  putAction("Hide Selected Group Pivot",            () -> {Select3D.Group_displayPivot = false; view_changed();});
  putAction("Hide Selected Group Edges",            () -> {Select3D.Group_displayEdges = false; view_changed();});
  putAction("Hide Selected Group Box",              () -> {Select3D.Group_displayBox = false; view_changed();});
  putAction("Hide Selected 2D Edges",               () -> {Select3D.Model2D_displayEdges = false; view_changed();});
  putAction("Hide Selected 1D Edges",               () -> {Select3D.Model1D_displayEdges = false; view_changed();});

  for (int n = -2; n <= 8; n++) {
    final int layoutIndex = n;
    putAction("Layout " + nf(layoutIndex, 0), () -> {
      STUDY.plotSetup = layoutIndex;
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
}
