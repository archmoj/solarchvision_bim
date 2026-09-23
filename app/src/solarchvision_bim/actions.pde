HashMap<String, Runnable> allActions;

void buildAllActions() {
  allActions = new HashMap<String, Runnable>();

  allActions.put("SOLARCHVISION-BIM6D", () -> {
    link("https://www.dropbox.com/scl/fi/vyfqllzj7hnb3rhvpnwus/BatimentDurable_MojtabaSamimi_20171123.pdf?rlkey=lzpoqyu59vp8wb4qidqtradaw&e=1");
  });

  allActions.put("Designed & developed by", () -> {
    link("https://depositonce.tu-berlin.de/items/c091139a-09cf-44c3-99a9-6adf59f7eaf8");
  });

  allActions.put("Mojtaba Samimi", () -> {
    link("https://www.linkedin.com/in/mojtaba-samimi-06178840/");
  });

  allActions.put("www.solarchvision.com", () -> {
    link("https://solarchvision.com/");
  });

  allActions.put("New", () -> {
    /////////////////////////////
    holdProject();
    /////////////////////////////

    selectFile_New();

    deleteAll();

    //update_station(-1);
  });

  allActions.put("Save", () -> {
    saveProject(Folder_Project + "/" + ProjectName + ".xml");
  });

  allActions.put("Hold", () -> {
    holdProject();
  });

  allActions.put("Fetch", () -> {
    fetchProject();
  });

  allActions.put("Open...", () -> {
    selectFile_Open();
  });

  allActions.put("Save As...", () -> {
    selectFile_SaveAs();
  });

  allActions.put("Import 3D-model...", () -> {
    selectFile_ImportObj();
  });

  allActions.put("Import Command File...", () -> {
    selectFile_RunScript();
  });

  allActions.put("Export 3D-model > OBJ (time-series)", () -> {
    exportObj_timeSeries();
  });

  allActions.put("Export 3D-model > OBJ (date-series)", () -> {
    exportObj_dateSeries();
  });

  allActions.put("Export 3D-model > OBJ", () -> {
    exportObj("");
  });

  allActions.put("Export 3D-model > HTML", () -> {
    exportHtml();
  });

  allActions.put("Export 3D-model > RAD", () -> {
    exportRadiance();
  });

  allActions.put("Export 3D-model > SCR", () -> {
    exportAutocadScript();
  });

  allActions.put("Quit", () -> {
    exit();
  });

  allActions.put("Wind pattern (active)", () -> setPlotImpacts(PlotImpacts_WIND_ACTIVE, true));

  allActions.put("Wind pattern (passive)", () -> setPlotImpacts(PlotImpacts_WIND_PASSIVE, true));

  allActions.put("Urban solar potential (active)", () -> setPlotImpacts(PlotImpacts_URBAN_ACTIVE, false));

  allActions.put("Urban solar potential (passive)", () -> setPlotImpacts(PlotImpacts_URBAN_PASSIVE, false));

  allActions.put("Orientation potential (active)", () -> setPlotImpacts(PlotImpacts_GLOBAL_ACTIVE, false));

  allActions.put("Orientation potential (passive)", () -> setPlotImpacts(PlotImpacts_GLOBAL_PASSIVE, false));

  allActions.put("Hourly sun position (active)", () -> setPlotImpacts(PlotImpacts_SUNPATH_ACTIVE, false));

  allActions.put("Hourly sun position (passive)", () -> setPlotImpacts(PlotImpacts_SUNPATH_PASSIVE, false));

  allActions.put("Annual cycle sun path (active)", () -> setPlotImpacts(PlotImpacts_CYCLES_ACTIVE, false));

  allActions.put("Annual cycle sun path (passive)", () -> setPlotImpacts(PlotImpacts_CYCLES_PASSIVE, false));

  allActions.put("Prebake Selected Sections", () -> {
    allSolarImpacts.render_Shadows_selectedSections();

    view_changed();
  });

  allActions.put("Process Active Impact", () -> {
    STUDY.PlotImpacts = PlotImpacts_URBAN_ACTIVE;
    allSolarImpacts.calculate_Impact_selectedSections();

    view_changed();
  });

  allActions.put("Process Passive Impact", () -> {
    STUDY.PlotImpacts = PlotImpacts_URBAN_PASSIVE;
    allSolarImpacts.calculate_Impact_selectedSections();

    view_changed();
  });

  allActions.put("Process Solid Impact", () -> {
    allSolidImpacts.calculate_Impact_selectedSections();

    view_changed();
  });

  allActions.put("Run wind 3D-model", () -> {
    allSolidImpacts.calculate_WindFlow();

    view_changed();
  });

  // Each of these 5 menu actions used to reset the same 12 recording
  // flags to false and then flip exactly one of them true. Pulling the
  // reset into stopAllRecording() means each action states
  // only what's actually different: which flag turns on.
  allActions.put("Stop REC.", () -> {
    stopAllRecording();

    UI_rollout.revise();
  });

  allActions.put("REC. Time Graph", () -> {
    stopAllRecording();
    STUDY.record_AUTO = true;

    UI_rollout.revise();
  });

  allActions.put("REC. Location Graph", () -> {
    stopAllRecording();
    WORLD.record_AUTO = true;

    UI_rollout.revise();
  });

  allActions.put("REC. Solid Graph", () -> {
    stopAllRecording();
    WIN3D.record_AUTO = true;

    UI_rollout.revise();
  });

  allActions.put("REC. Screenshot", () -> {
    stopAllRecording();
    FRAME_record_AUTO = true;

    UI_rollout.revise();
  });

  allActions.put("PDF Time Graph", () -> {
    STUDY.record_PDF = true;
    STUDY.revise();
  });

  allActions.put("JPG Time Graph", () -> {
    STUDY.record_IMG = true;
    STUDY.revise();
  });

  allActions.put("JPG Location Graph", () -> {
    WORLD.record_IMG = true;
    WORLD.revise();
  });

  allActions.put("PDF Location Graph", () -> {
    WORLD.record_PDF = true;
    WORLD.revise();
  });

  allActions.put("JPG 3D Graph", () -> {
    WIN3D.record_IMG = true;

    view_changed();
  });

  allActions.put("JPG 3D Full-Period", () -> {
    WIN3D.fullPeriod_IMG = true;
    WIN3D.record_IMG = true;

    view_changed();
  });

  allActions.put("Screenshot", () -> {
    FRAME_record_IMG = true;
  });

  allActions.put("Screenshot+Click", () -> {
    FRAME_click_IMG = true;
  });

  allActions.put("Screenshot+Drag", () -> {
    FRAME_drag_IMG = true;
  });

  allActions.put("Update Station", () -> {
    update_station(-1);
  });

  allActions.put("Load Land Mesh", () -> {
    Land3D.update_textures();
  });

  allActions.put("Load Land Texture", () -> {
    Land3D.update_textures();
  });

  allActions.put("Download Land Mesh", () -> {
    Land3D.download_mesh();
  });

  allActions.put("Download Land Texture", () -> {
    Land3D.download_textures();
  });

  allActions.put("Load Toroposphere", () -> {
    Tropo3D.download_images();
    Tropo3D.displaySurface = true;
    WORLD.revise();
    WIN3D.revise();
  });

  allActions.put("Download SWOB", () -> {
    download_ENSEMBLE_OBSERVED(TIME.year, TIME.month, TIME.day, TIME.hour);;
  });

  allActions.put("Download NAEFS", () -> {
    download_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);
  });

  allActions.put("Download CLMREC", () -> {
    download_CLIMATE_CLMREC();
  });

  allActions.put("Download TMYEPW", () -> {
    download_CLIMATE_TMYEPW();
  });

  allActions.put("Update TMYEPW", () -> {
    CurrentDataSource = dataID_CLIMATE_TMYEPW;

    CLIMATE_TMYEPW_load = true;
    update_CLIMATE_TMYEPW();
  });

  allActions.put("Update CWEEDS", () -> {
    CurrentDataSource = dataID_CLIMATE_CWEEDS;

    CLIMATE_CWEEDS_load = true;
    update_CLIMATE_CWEEDS();
  });

  allActions.put("Update CLMREC", () -> {
    CurrentDataSource = dataID_CLIMATE_CLMREC;

    CLIMATE_CLMREC_load = true;
    update_CLIMATE_CLMREC();
  });

  allActions.put("Update SWOB", () -> {
    CurrentDataSource = dataID_ENSEMBLE_OBSERVED;

    ENSEMBLE_OBSERVED_load = true;
    update_ENSEMBLE_OBSERVED(TIME.year, TIME.month, TIME.day, TIME.hour);
  });

  allActions.put("Update NAEFS", () -> {
    CurrentDataSource = dataID_ENSEMBLE_FORECAST;

    ENSEMBLE_FORECAST_load = true;
    update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);
  });



  allActions.put("Use typical year (TMY)", () -> {
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

  allActions.put("Use long-term (CWEEDS)", () -> {
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

  allActions.put("Use long-term (CLMREC)", () -> {
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

  allActions.put("Use real-time observed (SWOB)", () -> {
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

  allActions.put("Use weather forecast (NAEFS)", () -> {
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

  allActions.put("Active Shade", () -> {
    WIN3D.Impact_TYPE = Impact_ACTIVE;

    if (WIN3D.FacesShade == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
    if (WIN3D.FacesShade == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;

    view_changed();
  });

  allActions.put("Passive Shade", () -> {
    WIN3D.Impact_TYPE = Impact_PASSIVE;

    if (WIN3D.FacesShade == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
    if (WIN3D.FacesShade == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;

    view_changed();
  });

  allActions.put("Shade Surface Wire", () -> {
    WIN3D.FacesShade = SHADE.Surface_Wire;
    allFaces.displayEdges = true; //<<<<<<<<<<<<<<<

    view_changed();
  });

  allActions.put("Shade Surface Base", () -> {
    WIN3D.FacesShade = SHADE.Surface_Base;

    view_changed();
  });

  allActions.put("Shade Surface White", () -> {
    WIN3D.FacesShade = SHADE.Surface_White;

    view_changed();
  });

  allActions.put("Shade Surface Materials", () -> {
    WIN3D.FacesShade = SHADE.Surface_Materials;

    view_changed();
  });

  allActions.put("Shade Global Solar", () -> {
    WIN3D.FacesShade = SHADE.Global_Solar;

    GlobalSolar_rebuild_array = true;

    view_changed();
  });

  allActions.put("Shade Vertex Solar", () -> {
    WIN3D.FacesShade = SHADE.Vertex_Solar;

    VertexSolar_rebuild_array = true;

    view_changed();
  });

  allActions.put("Shade Vertex Solid", () -> {
    WIN3D.FacesShade = SHADE.Vertex_Solid;

    view_changed();
  });

  allActions.put("Shade Vertex Elevation", () -> {
    WIN3D.FacesShade = SHADE.Vertex_Elevation;

    view_changed();
  });

  allActions.put("Shade Viewport", () -> {
    ShadeViewport();
  });

  allActions.put("Prebake Viewport", () -> {
    preBakeViewport();
  });

  allActions.put("Show/Hide Land Mesh", () -> {
    Land3D.displaySurface = !Land3D.displaySurface;

    view_changed();
  });

  allActions.put("Show/Hide Land Texture", () -> {
    Land3D.displayTexture = !Land3D.displayTexture;

    view_changed();
  });

  allActions.put("Show/Hide Land Points", () -> {
    Land3D.displayPoints = !Land3D.displayPoints;

    view_changed();
  });

  allActions.put("Show/Hide Land Depth", () -> {
    Land3D.displayDepth = !Land3D.displayDepth;

    view_changed();
  });

  allActions.put("Show/Hide Vertices", () -> {
    allPoints.displayAll = !allPoints.displayAll;

    view_changed();
  });

  allActions.put("Show/Hide Edges", () -> {
    allFaces.displayEdges = !allFaces.displayEdges;

    view_changed();
  });

  allActions.put("Show/Hide Normals", () -> {
    allFaces.displayNormals = !allFaces.displayNormals;

    view_changed();
  });

  allActions.put("Show/Hide Leaves", () -> {
    allModel1Ds.displayLeaves = !allModel1Ds.displayLeaves;

    view_changed();
  });

  allActions.put("Show/Hide Model1Ds", () -> {
    allModel1Ds.displayAll = !allModel1Ds.displayAll;
    allModel1Ds.displayLeaves = allModel1Ds.displayAll; // <<<<<<

    view_changed();
  });

  allActions.put("Show/Hide Model2Ds", () -> {
    allModel2Ds.displayAll = !allModel2Ds.displayAll;

    view_changed();
  });

  allActions.put("Show/Hide Polylines", () -> {
    allPolylines.displayAll = !allPolylines.displayAll;

    view_changed();
  });

  allActions.put("Show/Hide Faces", () -> {
    allFaces.displayAll = !allFaces.displayAll;

    view_changed();
  });

  allActions.put("Show/Hide Solids", () -> {
    allSolids.displayAll = !allSolids.displayAll;

    view_changed();
  });

  allActions.put("Show/Hide Sections", () -> {
    allSections.displayAll = !allSections.displayAll;

    view_changed();
  });

  allActions.put("Show/Hide Cameras", () -> {
    allCameras.displayAll = !allCameras.displayAll;

    view_changed();
  });

  allActions.put("Show/Hide Sky", () -> {
    Sky3D.displaySurface = !Sky3D.displaySurface;

    view_changed();
  });

  allActions.put("Show/Hide Sun Grid", () -> {
    Sun3D.displayGrid = !Sun3D.displayGrid;

    view_changed();
  });

  allActions.put("Show/Hide Sun Path", () -> {
    Sun3D.displayPath = !Sun3D.displayPath;

    view_changed();
  });

  allActions.put("Show/Hide Sun Pattern", () -> {
    Sun3D.displayPattern = !Sun3D.displayPattern;

    view_changed();
  });

  allActions.put("Show/Hide Sun Surface", () -> {
    Sun3D.displaySurface = !Sun3D.displaySurface;

    view_changed();
  });

  allActions.put("Show/Hide Moon Surface", () -> {
    Moon3D.displaySurface = !Moon3D.displaySurface;

    view_changed();
  });

  allActions.put("Show/Hide Earth Surface", () -> {
    Earth3D.displaySurface = !Earth3D.displaySurface;

    view_changed();
  });

  allActions.put("Show/Hide Troposphere", () -> {
    Tropo3D.displaySurface = !Tropo3D.displaySurface;

    view_changed();
    WORLD.revise();
  });

  allActions.put("Show/Hide Solar Section", () -> {
    allSolarImpacts.displayImage = !allSolarImpacts.displayImage;

    view_changed();
  });

  allActions.put("Show/Hide Solid Section", () -> {
    allSolidImpacts.displayImage = !allSolidImpacts.displayImage;

    view_changed();
  });

  allActions.put("Show/Hide Selected Solids", () -> {
    Select3D.Solid_displayEdges = !Select3D.Solid_displayEdges;

    view_changed();
  });

  allActions.put("Show/Hide Selected Sections", () -> {
    Select3D.Section_displayEdges = !Select3D.Section_displayEdges;

    view_changed();
  });

  allActions.put("Show/Hide Selected Cameras", () -> {
    Select3D.Camera_displayEdges = !Select3D.Camera_displayEdges;

    view_changed();
  });

  allActions.put("Show/Hide Selected LandPoints", () -> {
    Select3D.LandPoint_displayPoints = !Select3D.LandPoint_displayPoints;

    view_changed();
  });

  allActions.put("Show/Hide Wind Flow", () -> {
    allWindFlows.displayAll = !allWindFlows.displayAll;

    view_changed();
  });

  allActions.put("Show/Hide Selected Faces", () -> {
    Select3D.Face_displayEdges = !Select3D.Face_displayEdges;

    view_changed();
  });

  allActions.put("Show/Hide Selected Faces Vertex Count", () -> {
    Select3D.Face_displayVertexCount = !Select3D.Face_displayVertexCount;

    view_changed();
  });

  allActions.put("Show/Hide Selected Polylines Vertex Count", () -> {
    Select3D.Polyline_displayVertexCount = !Select3D.Polyline_displayVertexCount;

    view_changed();
  });

  allActions.put("Show/Hide Selected Vertices", () -> {
    Select3D.Vertex_displayVertices = !Select3D.Vertex_displayVertices;

    view_changed();
  });

  allActions.put("Show/Hide Selected Polylines", () -> {
    Select3D.Polyline_displayVertices = !Select3D.Polyline_displayVertices;

    view_changed();
  });

  allActions.put("Show/Hide Selected REF Pivot", () -> {
    Select3D.displayReferencePivot = !Select3D.displayReferencePivot;

    view_changed();
  });

  allActions.put("Show/Hide Selected Group Pivot", () -> {
    Select3D.Group_displayPivot = !Select3D.Group_displayPivot;

    view_changed();
  });

  allActions.put("Show/Hide Selected Group Edges", () -> {
    Select3D.Group_displayEdges = !Select3D.Group_displayEdges;

    view_changed();
  });

  allActions.put("Show/Hide Selected Group Box", () -> {
    Select3D.Group_displayBox = !Select3D.Group_displayBox;

    view_changed();;
  });

  allActions.put("Show/Hide Selected 2D Edges", () -> {
    Select3D.Model2D_displayEdges = !Select3D.Model2D_displayEdges;

    view_changed();
  });

  allActions.put("Show/Hide Selected 1D Edges", () -> {
    Select3D.Model1D_displayEdges = !Select3D.Model1D_displayEdges;

    view_changed();
  });

  allActions.put("Show/Hide SWOB stations", () -> {
    WORLD.displayAll_SWOB = (WORLD.displayAll_SWOB + 1) % 2;

    WORLD.revise();
  });

  allActions.put("Show/Hide SWOB nearest", () -> {
    WORLD.displayNear_SWOB = !WORLD.displayNear_SWOB;

    WORLD.revise();
  });

  allActions.put("Show/Hide NAEFS stations", () -> {
    WORLD.displayAll_NAEFS = (WORLD.displayAll_NAEFS + 1) % 2;

    WORLD.revise();
  });

  allActions.put("Show/Hide NAEFS nearest", () -> {
    WORLD.displayNear_NAEFS = !WORLD.displayNear_NAEFS;

    WORLD.revise();
  });

  allActions.put("Show/Hide CWEEDS stations", () -> {
    WORLD.displayAll_CWEEDS = (WORLD.displayAll_CWEEDS + 1) % 2;

    WORLD.revise();
  });

  allActions.put("Show/Hide CWEEDS nearest", () -> {
    WORLD.displayNear_CWEEDS = !WORLD.displayNear_CWEEDS;

    WORLD.revise();
  });

  allActions.put("Show/Hide CLMREC stations", () -> {
    WORLD.displayAll_CLMREC = (WORLD.displayAll_CLMREC + 1) % 2;

    WORLD.revise();
  });

  allActions.put("Show/Hide CLMREC nearest", () -> {
    WORLD.displayNear_CLMREC = !WORLD.displayNear_CLMREC;

    WORLD.revise();
  });

  allActions.put("Show/Hide TMYEPW stations", () -> {
    WORLD.displayAll_TMYEPW = (WORLD.displayAll_TMYEPW + 1) % 2;

    WORLD.revise();
  });

  allActions.put("Show/Hide TMYEPW nearest", () -> {
    WORLD.displayNear_TMYEPW = !WORLD.displayNear_TMYEPW;

    WORLD.revise();
  });

  allActions.put("1D-Tree", () -> {
    UI_setTo_Create_allModel1Ds();
  });

  allActions.put("2D-Tree", () -> {
    UI_setTo_Create_Tree();
  });

  allActions.put("Person", () -> {
    UI_setTo_Create_Person();
  });

  allActions.put("Point", () -> {
    UI_setTo_Create_Vertex();
  });

  allActions.put("Polyline", () -> {
    UI_setTo_Create_Polyline();
  });

  allActions.put("Surface", () -> {
    UI_setTo_Create_Face();
  });

  allActions.put("Parametric 1", () -> {
    UI_setTo_Create_Parametric(1);
  });

  allActions.put("Parametric 2", () -> {
    UI_setTo_Create_Parametric(2);
  });

  allActions.put("Parametric 3", () -> {
    UI_setTo_Create_Parametric(3);
  });

  allActions.put("Parametric 4", () -> {
    UI_setTo_Create_Parametric(4);
  });

  allActions.put("Parametric 5", () -> {
    UI_setTo_Create_Parametric(5);
  });

  allActions.put("Parametric 6", () -> {
    UI_setTo_Create_Parametric(6);
  });

  allActions.put("Pyramid", () -> {
    UI_setTo_Create_Pyramid();
  });

  allActions.put("Plane", () -> {
    UI_setTo_Create_Plane();
  });

  allActions.put("Polygon", () -> {
    UI_setTo_Create_Polygon();
  });

  allActions.put("Extrude", () -> {
    UI_setTo_Create_Extrude();
  });

  allActions.put("Hyper", () -> {
    UI_setTo_Create_Hyper();
  });

  allActions.put("House3", () -> {
    UI_setTo_Create_House3();
  });

  allActions.put("House2", () -> {
    UI_setTo_Create_House2();
  });

  allActions.put("House1", () -> {
    UI_setTo_Create_House1();
  });

  allActions.put("Box", () -> {
    UI_setTo_Create_Box();
  });

  allActions.put("Icosahedron", () -> {
    UI_setTo_Create_Icosahedron();
  });

  allActions.put("Octahedron", () -> {
    UI_setTo_Create_Octahedron();
  });

  allActions.put("Sphere", () -> {
    UI_setTo_Create_Sphere();
  });

  allActions.put("Cylinder", () -> {
    UI_setTo_Create_Cylinder();
  });

  allActions.put("Cushion", () -> {
    UI_setTo_Create_Cushion();
  });

  allActions.put("Drop on LandSurface", () -> {
    UI_setTo_Modify_Drop(0);

    Drop3D.selection();
  });

  allActions.put("Drop on ModelSurface (Down)", () -> {
    UI_setTo_Modify_Drop(1);

    Drop3D.selection();
  });

  allActions.put("Drop on ModelSurface (Up)", () -> {
    UI_setTo_Modify_Drop(2);

    Drop3D.selection();
  });

  allActions.put("Get dX", () -> {
    UI_setTo_Modify_GetLength(0);
  });

  allActions.put("Get dY", () -> {
    UI_setTo_Modify_GetLength(1);
  });

  allActions.put("Get dZ", () -> {
    UI_setTo_Modify_GetLength(2);
  });

  allActions.put("Get dXYZ", () -> {
    UI_setTo_Modify_GetLength(3);
  });

  allActions.put("Get dXY", () -> {
    UI_setTo_Modify_GetLength(4);
  });

  allActions.put("MoveX", () -> {
    UI_setTo_Modify_Move(0);
  });

  allActions.put("MoveY", () -> {
    UI_setTo_Modify_Move(1);
  });

  allActions.put("MoveZ", () -> {
    UI_setTo_Modify_Move(2);
  });

  allActions.put("Move", () -> {
    UI_setTo_Modify_Move(3);
  });

  allActions.put("ScaleX", () -> {
    UI_setTo_Modify_Scale(0);
  });

  allActions.put("ScaleY", () -> {
    UI_setTo_Modify_Scale(1);
  });

  allActions.put("ScaleZ", () -> {
    UI_setTo_Modify_Scale(2);
  });

  allActions.put("Scale", () -> {
    UI_setTo_Modify_Scale(3);
  });

  allActions.put("PowerX", () -> {
    UI_setTo_Modify_Power(0);
  });

  allActions.put("PowerY", () -> {
    UI_setTo_Modify_Power(1);
  });

  allActions.put("PowerZ", () -> {
    UI_setTo_Modify_Power(2);
  });

  allActions.put("Power", () -> {
    UI_setTo_Modify_Power(3);
  });

  allActions.put("RotateX", () -> {
    UI_setTo_Modify_Rotate(0);
  });

  allActions.put("RotateY", () -> {
    UI_setTo_Modify_Rotate(1);
  });

  allActions.put("RotateZ", () -> {
    UI_setTo_Modify_Rotate(2);
  });

  allActions.put("Rotate", () -> {
    UI_setTo_Modify_Rotate(2);
  });

  allActions.put("Pivot", () -> {
    UI_setTo_Modify_Pivot(0);
  });

  allActions.put("Pick Pivot", () -> {
    UI_setTo_Modify_Pivot(1);
  });

  allActions.put("Assign Pivot", () -> {
    UI_setTo_Modify_Pivot(2);
  });

  allActions.put("Save Current ReferenceBox", () -> {
    Select3D.save_current_BoundingBox();
  });

  allActions.put("Reset Saved ReferenceBox", () -> {
    Select3D.apply_saved_BoundingBox();

    view_changed();
  });

  allActions.put("Use Selection ReferenceBox", () -> {
    Select3D.calculate_BoundingBox();

    view_changed();
  });

  allActions.put("Use Origin ReferenceBox", () -> {
    Select3D.apply_origin_ReferenceBox();

    view_changed();
  });

  allActions.put("Begin New Group at Origin", () -> {
    allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);

    Select3D.Group_ids = new int [1];
    Select3D.Group_ids[0] = allGroups.num - 1;

    model_changed();
  });

  allActions.put("Begin New Group at Pivot", () -> {
    allGroups.beginNewGroup(Select3D.BoundingBox[1 + Select3D.alignX][0], Select3D.BoundingBox[1 + Select3D.alignX][1], Select3D.BoundingBox[1 + Select3D.alignX][2], Select3D.BoundingBox[1 + Select3D.alignX][3], Select3D.BoundingBox[1 + Select3D.alignX][4], Select3D.BoundingBox[1 + Select3D.alignX][5], Select3D.BoundingBox[1 + Select3D.alignX][6], Select3D.BoundingBox[1 + Select3D.alignX][7], Select3D.BoundingBox[1 + Select3D.alignX][8]);

    Select3D.Group_ids = new int [1];
    Select3D.Group_ids[0] = allGroups.num - 1;

    model_changed();
  });

  allActions.put("Solid", () -> {
    UI_setTo_Create_Solid();
  });

  allActions.put("Section", () -> {
    UI_setTo_Create_Section();
  });

  allActions.put("Camera", () -> {
    UI_setTo_Create_Camera();
  });

  allActions.put("Viewport >> Camera", () -> {
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

  allActions.put("Camera >> Viewport", () -> {
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

  allActions.put("Camera View", () -> {
    if (Select3D.Camera_ids.length > 0) {
      WIN3D.currentCamera = Select3D.Camera_ids[Select3D.Camera_ids.length - 1];
      WIN3D.apply_currentCamera();
      modify_Viewport_Title();

      view_changed();

      UI_toolBar.revise();
    }
  });

  allActions.put("LandMesh >> Group", () -> {
    Land3D.draw(TypeWindow.LandMesh);

    model_changed();
  });

  allActions.put("LandGap >> Group", () -> {
    Land3D.draw(TypeWindow.LandGap);

    model_changed();
  });

  allActions.put("Change Seed/Material", () -> {
    UI_setTo_Modify_Seed(0);
  });

  allActions.put("Pick Seed/Material", () -> {
    UI_setTo_Modify_Seed(1);
  });

  allActions.put("Assign Seed/Material", () -> {
    UI_setTo_Modify_Seed(2);
  });

  allActions.put("Change tessellation", () -> {
    UI_setTo_Modify_Tessellation(0);
  });

  allActions.put("Pick tessellation", () -> {
    UI_setTo_Modify_Tessellation(1);
  });

  allActions.put("Assign tessellation", () -> {
    UI_setTo_Modify_Tessellation(2);
  });

  allActions.put("Change Layer", () -> {
    UI_setTo_Modify_Layer(0);
  });

  allActions.put("Pick Layer", () -> {
    UI_setTo_Modify_Layer(1);
  });

  allActions.put("Assign Layer", () -> {
    UI_setTo_Modify_Layer(2);
  });

  allActions.put("Change Visibility", () -> {
    UI_setTo_Modify_Visibility(0);
  });

  allActions.put("Pick Visibility", () -> {
    UI_setTo_Modify_Visibility(1);
  });

  allActions.put("Assign Visibility", () -> {
    UI_setTo_Modify_Visibility(2);
  });

  allActions.put("Change Weight", () -> {
    UI_setTo_Modify_Weight(0);
  });

  allActions.put("Pick Weight", () -> {
    UI_setTo_Modify_Weight(1);
  });

  allActions.put("Assign Weight", () -> {
    UI_setTo_Modify_Weight(2);
  });

  allActions.put("Flip Normal", () -> {
    UI_setTo_Modify_Normal(1);
  });

  allActions.put("Set-Out Normal", () -> {
    UI_setTo_Modify_Normal(2);
  });

  allActions.put("Set-In Normal", () -> {
    UI_setTo_Modify_Normal(3);
  });

  allActions.put("Get FirstVertex", () -> {
    UI_setTo_Modify_FirstVertex(1);
  });

  allActions.put("Change DegreeMax", () -> {
    UI_setTo_Modify_DegreeMax(0);
  });

  allActions.put("Pick DegreeMax", () -> {
    UI_setTo_Modify_DegreeMax(1);
  });

  allActions.put("Assign DegreeMax", () -> {
    UI_setTo_Modify_DegreeMax(2);
  });

  allActions.put("Change BranchTilt", () -> {
    UI_setTo_Modify_BranchTilt(0);
  });

  allActions.put("Pick BranchTilt", () -> {
    UI_setTo_Modify_BranchTilt(1);
  });

  allActions.put("Assign BranchTilt", () -> {
    UI_setTo_Modify_BranchTilt(2);
  });

  allActions.put("Change BranchTwist", () -> {
    UI_setTo_Modify_BranchTwist(0);
  });

  allActions.put("Pick BranchTwist", () -> {
    UI_setTo_Modify_BranchTwist(1);
  });

  allActions.put("Assign BranchTwist", () -> {
    UI_setTo_Modify_BranchTwist(2);
  });

  allActions.put("Change BranchRatio", () -> {
    UI_setTo_Modify_BranchRatio(0);
  });

  allActions.put("Pick BranchRatio", () -> {
    UI_setTo_Modify_BranchRatio(1);
  });

  allActions.put("Assign BranchRatio", () -> {
    UI_setTo_Modify_BranchRatio(2);
  });

  allActions.put("Change TreeBase", () -> {
    UI_setTo_Modify_TreeBase(0);
  });

  allActions.put("Pick TreeBase", () -> {
    UI_setTo_Modify_TreeBase(1);
  });

  allActions.put("Assign TreeBase", () -> {
    UI_setTo_Modify_TreeBase(2);
  });

  allActions.put("Change TrunkSize", () -> {
    UI_setTo_Modify_TrunkSize(0);
  });

  allActions.put("Pick TrunkSize", () -> {
    UI_setTo_Modify_TrunkSize(1);
  });

  allActions.put("Assign TrunkSize", () -> {
    UI_setTo_Modify_TrunkSize(2);
  });

  allActions.put("Change LeafSize", () -> {
    UI_setTo_Modify_LeafSize(0);
  });

  allActions.put("Pick LeafSize", () -> {
    UI_setTo_Modify_LeafSize(1);
  });

  allActions.put("Assign LeafSize", () -> {
    UI_setTo_Modify_LeafSize(2);
  });

  allActions.put("Model1DsProps", () -> {
    UI_setTo_Modify_Model1DsProps(0);
  });

  allActions.put("Pick Model1DsProps", () -> {
    UI_setTo_Modify_Model1DsProps(1);
  });

  allActions.put("Assign Model1DsProps", () -> {
    UI_setTo_Modify_Model1DsProps(2);
  });

  allActions.put("Orthographic", () -> {
    UI_setTo_View_ProjectionType(0);
  });

  allActions.put("Perspective", () -> {
    UI_setTo_View_ProjectionType(1);
  });

  allActions.put("Invert Selection", () -> {
    Select3D.invertSelection();
  });

  allActions.put("Deselect All", () -> {
    Select3D.deselectAll();
  });

  allActions.put("Select All", () -> {
    Select3D.selectAll();
  });

  allActions.put("Select All Cameras", () -> selectAllOfCategory(ObjectCategory.CAMERA));

  allActions.put("Select All Sections", () -> selectAllOfCategory(ObjectCategory.SECTION));

  allActions.put("Select All Solids", () -> selectAllOfCategory(ObjectCategory.SOLID));

  allActions.put("Select All Faces", () -> selectAllOfCategory(ObjectCategory.FACE));

  allActions.put("Select All Polylines", () -> selectAllOfCategory(ObjectCategory.POLYLINE));

  allActions.put("Select All Verices", () -> selectAllOfCategory(ObjectCategory.VERTEX));

  allActions.put("Select All Groups", () -> selectAllOfCategory(ObjectCategory.GROUP));

  allActions.put("Select All Model1Ds", () -> selectAllOfCategory(ObjectCategory.MODEL1D));

  allActions.put("Select All Model2Ds", () -> selectAllOfCategory(ObjectCategory.MODEL2D));

  allActions.put("Select Solid", () -> switch_category(ObjectCategory.SOLID));

  allActions.put("Select Section", () -> switch_category(ObjectCategory.SECTION));

  allActions.put("Select Camera", () -> switch_category(ObjectCategory.CAMERA));

  allActions.put("Select LandPoint", () -> switch_category(ObjectCategory.LANDPOINT));

  allActions.put("Select Model1Ds", () -> switch_category(ObjectCategory.MODEL1D));

  allActions.put("Select Model2Ds", () -> switch_category(ObjectCategory.MODEL2D));

  allActions.put("Select Group", () -> switch_category(ObjectCategory.GROUP));

  allActions.put("Select Face", () -> switch_category(ObjectCategory.FACE));

  allActions.put("Select Polyline", () -> switch_category(ObjectCategory.POLYLINE));

  allActions.put("Select Vertex", () -> switch_category(ObjectCategory.VERTEX));

  allActions.put("Soft Selection", () -> {
    Select3D.convert_Vertex_to_softSelection();

    switch_category(ObjectCategory.SOFTVERTEX);
  });

  allActions.put("Vertices >> Groups", () -> convertAndSwitch(() -> Select3D.convert_Vertices_to_Groups(), ObjectCategory.GROUP));

  allActions.put("Faces >> Groups", () -> convertAndSwitch(() -> Select3D.convert_Faces_to_Groups(), ObjectCategory.GROUP));

  allActions.put("Groups >> Faces", () -> convertAndSwitch(() -> Select3D.convert_Groups_to_Faces(), ObjectCategory.FACE));

  allActions.put("Polylines >> Groups", () -> convertAndSwitch(() -> Select3D.convert_Polylines_to_Groups(), ObjectCategory.GROUP));

  allActions.put("Groups >> Polylines", () -> convertAndSwitch(() -> Select3D.convert_Groups_to_Polylines(), ObjectCategory.POLYLINE));

  allActions.put("Polylines >> Vertices", () -> convertAndSwitch(() -> Select3D.convert_Polylines_to_Vertices(), ObjectCategory.VERTEX));

  allActions.put("Vertices >> Polylines", () -> convertAndSwitch(() -> Select3D.convert_Vertices_to_Polylines(), ObjectCategory.POLYLINE));

  allActions.put("Groups >> Vertices", () -> convertAndSwitch(() -> Select3D.convert_Groups_to_Vertices(), ObjectCategory.VERTEX));

  allActions.put("Faces >> Vertices", () -> convertAndSwitch(() -> Select3D.convert_Faces_to_Vertices(), ObjectCategory.VERTEX));

  allActions.put("Vertices >> Faces", () -> convertAndSwitch(() -> Select3D.convert_Vertices_to_Faces(), ObjectCategory.FACE));

  allActions.put("Solids >> Groups", () -> convertAndSwitch(() -> Select3D.convert_Solids_to_Groups(), ObjectCategory.GROUP));

  allActions.put("Groups >> Solids", () -> convertAndSwitch(() -> Select3D.convert_Groups_to_Solids(), ObjectCategory.SOLID));

  allActions.put("Model2Ds >> Groups", () -> convertAndSwitch(() -> Select3D.convert_Model2Ds_to_Groups(), ObjectCategory.GROUP));

  allActions.put("Groups >> Model2Ds", () -> convertAndSwitch(() -> Select3D.convert_Groups_to_Model2Ds(), ObjectCategory.MODEL2D));

  allActions.put("Model1Ds >> Groups", () -> convertAndSwitch(() -> Select3D.convert_Model1Ds_to_Groups(), ObjectCategory.GROUP));

  allActions.put("Groups >> Model1Ds", () -> convertAndSwitch(() -> Select3D.convert_Groups_to_Model1Ds(), ObjectCategory.MODEL1D));

  allActions.put("Pick Select", () -> {
    UI_setTo_View_PickSelect(0);
  });

  allActions.put("Pick Select+", () -> {
    UI_setTo_View_PickSelect(1);
  });

  allActions.put("Pick Select-", () -> {
    UI_setTo_View_PickSelect(2);
  });

  allActions.put("Window Select", () -> {
    UI_setTo_View_WindowSelect(0);
  });

  allActions.put("Window Select+", () -> {
    UI_setTo_View_WindowSelect(1);
  });

  allActions.put("Window Select-", () -> {
    UI_setTo_View_WindowSelect(2);
  });

  allActions.put("Select Near Selected Vertices", () -> {
    Select3D.selectNearVertices();
  });

  allActions.put("Weld Objects Selected Vertices", () -> {
    Modify3D.weldObjectsVertices_Selection(User3D.modify_WeldTreshold);
  });

  allActions.put("Weld Scene Selected Vertices", () -> {
    Modify3D.weldSceneVertices_Selection(User3D.modify_WeldTreshold);
  });

  allActions.put("Reposition Selected Vertices", () -> {
    Modify3D.repositionVertices_Selection();
  });

  allActions.put("Separate Selected Vertices", () -> {
    Modify3D.separateVertices_Selection();
  });

  allActions.put("Select Scene Isolated Vertices", () -> {
    Select3D.isolatedVertices_Scene();
  });

  allActions.put("Delete Scene Isolated Vertices", () -> {
    Delete3D.isolatedVertices_Scene();
  });

  allActions.put("Delete Selection Isolated Vertices", () -> {
    Delete3D.isolatedVertices_Selection();
  });

  allActions.put("Delete Scene Empty Groups", () -> {
    allGroups.deleteEmptyGroups_Scene();
  });

  allActions.put("Delete Selection", () -> {
    Delete3D.selection();
  });

  allActions.put("Dettach from Groups Selection", () -> {
    allGroups.dettachFromGroups_Selection();
  });

  allActions.put("Ungroup Selection", () -> {
    allGroups.ungroup_Selection();
  });

  allActions.put("Group Selection", () -> {
    allGroups.group_Selection(1);
  });

  allActions.put("Attach to Last Group", () -> {
    allGroups.group_Selection(0);
  });

  allActions.put("Clone Selection (Identical)", () -> {
    Clone3D.selection(true);
  });

  allActions.put("Clone Selection (Variation)", () -> {
    Clone3D.selection(false);
  });

  allActions.put("Auto-Normal Selected Faces", () -> {
    Modify3D.autoNormalFaces_Selection();
  });

  allActions.put("Force Triangulate Selected Faces", () -> {
    Modify3D.forceTriangulateFaces_Selection();
  });

  allActions.put("Insert Corner Opennings", () -> {
    Modify3D.insertCornerOpennings_Selection();
  });

  allActions.put("Insert Parallel Opennings", () -> {
    Modify3D.insertParallelOpennings_Selection();
  });

  allActions.put("Insert Rotated Opennings", () -> {
    Modify3D.insertRotatedOpennings_Selection();
  });

  allActions.put("Insert Edge Opennings", () -> {
    Modify3D.insertEdgeOpennings_Selection();
  });

  allActions.put("Optimize Faces", () -> {
    Modify3D.optimizeFace_Selection();
  });

  allActions.put("Tessellate Rows & Columns", () -> {
    Modify3D.tessellateRowsColumns_Selection();
  });

  allActions.put("Tessellate Rectangular", () -> {
    Modify3D.tessellateRectangular_Selection();
  });

  allActions.put("Tessellate Triangular", () -> {
    Modify3D.tessellateTriangular_Selection();
  });

  allActions.put("Extrude Face Edges", () -> {
    Modify3D.extrudeFaceEdges_Selection();
  });

  allActions.put("Offset(above) Vertices", () -> {
    Modify3D.offsetVertices_Selection(0, abs(User3D.modify_OffsetAmount));
  });

  allActions.put("Offset(below) Vertices", () -> {
    Modify3D.offsetVertices_Selection(0, -abs(User3D.modify_OffsetAmount));
  });

  allActions.put("Offset(expand) Vertices", () -> {
    Modify3D.offsetVertices_Selection(1, abs(User3D.modify_OffsetAmount));
  });

  allActions.put("Offset(shrink) Vertices", () -> {
    Modify3D.offsetVertices_Selection(1, -abs(User3D.modify_OffsetAmount));
  });

  allActions.put("Reverse Visibility of All Faces", () -> {
    Modify3D.reverseVisibilityFaces_Scene();
  });

  allActions.put("Hide All Faces", () -> {
    Modify3D.changeVisibilityFaces_Scene(0);
  });

  allActions.put("Unhide All Faces", () -> {
    Modify3D.changeVisibilityFaces_Scene(1);
  });

  allActions.put("Hide Selected Faces", () -> {
    Modify3D.changeVisibilityFaces_Selection(0);
  });

  allActions.put("Unhide Selected Faces", () -> {
    Modify3D.changeVisibilityFaces_Selection(1);
  });

  allActions.put("Isolate Selection", () -> {
    Modify3D.isolate_Selection();
  });

  allActions.put("Flatten Selected LandPoints", () -> {
    Modify3D.flatten_LandPoints();
  });

  allActions.put("Add People on Land", () -> {
    Create3D.add_onLand(1); // 1 = people
  });

  allActions.put("Add 2D-Trees on Land", () -> {
    Create3D.add_onLand(2); // 2 = 2D trees
  });

  allActions.put("Add 1D-Trees on Land", () -> {
    Create3D.add_onLand(3); // 3 = 1D trees
  });

  allActions.put("Delete All Model1Ds", () -> {
    allModel1Ds.makeEmpty(0);
  });

  allActions.put("Delete All Model2Ds", () -> {
    allModel2Ds.makeEmpty(0);
  });

  allActions.put("Delete All Groups", () -> {
    allGroups.makeEmpty(0);
  });

  allActions.put("Delete All Solids", () -> {
    allSolids.makeEmpty(0);
  });

  allActions.put("Delete All Sections", () -> {
    allSections.makeEmpty(0);
  });

  allActions.put("Delete All Cameras", () -> {
    allCameras.makeEmpty(0);
  });

  allActions.put("Delete All Faces", () -> {
    allFaces.makeEmpty(0);
  });

  allActions.put("Delete All Polylines", () -> {
    allPolylines.makeEmpty(0);
  });

  allActions.put("Delete All", () -> {
    deleteAll();
  });

  allActions.put("TargetRoll", () -> {
    UI_setTo_View_TargetRoll(0);
  });

  allActions.put("TargetRollZ", () -> {
    UI_setTo_View_TargetRoll(1);
  });

  allActions.put("TargetRollXY", () -> {
    UI_setTo_View_TargetRoll(2);
  });

  allActions.put("CameraRoll", () -> {
    UI_setTo_View_CameraRoll(0);
  });

  allActions.put("CameraRollZ", () -> {
    UI_setTo_View_CameraRoll(1);
  });

  allActions.put("CameraRollXY", () -> {
    UI_setTo_View_CameraRoll(2);
  });

  allActions.put("Orbit", () -> {
    UI_setTo_View_Orbit(0);
  });

  allActions.put("OrbitZ", () -> {
    UI_setTo_View_Orbit(1);
  });

  allActions.put("OrbitXY", () -> {
    UI_setTo_View_Orbit(2);
  });

  allActions.put("LandOrbit", () -> {
    UI_setTo_View_LandOrbit(0);
  });

  allActions.put("Pan", () -> {
    UI_setTo_View_Pan(0);
  });

  allActions.put("PanX", () -> {
    UI_setTo_View_Pan(1);
  });

  allActions.put("PanY", () -> {
    UI_setTo_View_Pan(2);
  });

  allActions.put("Zoom", () -> {
    UI_setTo_View_ZOOM(0);
  });

  allActions.put("Zoom as default", () -> {
    UI_setTo_View_ZOOM(1);
  });

  allActions.put("TruckX", () -> {
    UI_setTo_View_Truck(1);
  });

  allActions.put("TruckY", () -> {
    UI_setTo_View_Truck(2);
  });

  allActions.put("TruckZ", () -> {
    UI_setTo_View_Truck(0);
  });

  allActions.put("DistZ", () -> {
    UI_setTo_View_Truck(0);
  });

  allActions.put("CameraDistance", () -> {
    UI_setTo_View_CameraDistance(0);
  });

  allActions.put("DistMouseXY", () -> {
    UI_setTo_View_DistMouseXY(0);
  });

  allActions.put("Look at origin", () -> {
    UI_setTo_View_LookAtOrigin(0);
  });

  allActions.put("Look at direction", () -> {
    UI_setTo_View_LookAtDirection(0);
  });

  allActions.put("Look at selection", () -> {
    UI_setTo_View_LookAtSelection(0);
  });

  allActions.put("3DModelSize", () -> {
    UI_setTo_View_3DModelSize();
  });

  allActions.put("SkydomeSize", () -> {
    UI_setTo_View_SkydomeSize();
  });

  allActions.put("AllModelSize", () -> {
    UI_setTo_View_AllModelSize();
  });

  allActions.put("Display All Viewports", () -> {
    UI_setTo_Viewport(0);
  });

  allActions.put("Enlarge 3D Viewport", () -> {
    UI_setTo_Viewport(1);
  });

  allActions.put("Enlarge Time Viewport", () -> {
    UI_setTo_Viewport(2);
  });

  allActions.put("Enlarge Map Viewport", () -> {
    UI_setTo_Viewport(3);
  });

  allActions.put("Top", () -> {
    UI_setTo_View_3DViewPoint(0);
  });

  allActions.put("Front", () -> {
    UI_setTo_View_3DViewPoint(1);
  });

  allActions.put("Left", () -> {
    UI_setTo_View_3DViewPoint(2);
  });

  allActions.put("Back", () -> {
    UI_setTo_View_3DViewPoint(3);
  });

  allActions.put("Right", () -> {
    UI_setTo_View_3DViewPoint(4);
  });

  allActions.put("Bottom", () -> {
    UI_setTo_View_3DViewPoint(5);
  });

  allActions.put("S.W.", () -> {
    UI_setTo_View_3DViewPoint(6);
  });

  allActions.put("S.E.", () -> {
    UI_setTo_View_3DViewPoint(7);
  });

  allActions.put("N.E.", () -> {
    UI_setTo_View_3DViewPoint(8);
  });

  allActions.put("N.W.", () -> {
    UI_setTo_View_3DViewPoint(9);
  });

  allActions.put("PivotX:Minimum", () -> {
    UI_setTo_View_PivotX(-1);
  });

  allActions.put("PivotX:Center", () -> {
    UI_setTo_View_PivotX(0);
  });

  allActions.put("PivotX:Maximum", () -> {
    UI_setTo_View_PivotX(1);
  });

  allActions.put("PivotY:Minimum", () -> {
    UI_setTo_View_PivotY(-1);
  });

  allActions.put("PivotY:Center", () -> {
    UI_setTo_View_PivotY(0);
  });

  allActions.put("PivotY:Maximum", () -> {
    UI_setTo_View_PivotY(1);
  });

  allActions.put("PivotZ:Minimum", () -> {
    UI_setTo_View_PivotZ(-1);
  });

  allActions.put("PivotZ:Center", () -> {
    UI_setTo_View_PivotZ(0);
  });

  allActions.put("PivotZ:Maximum", () -> {
    UI_setTo_View_PivotZ(1);
  });

  for (int n = -2; n <= 8; n++) {
    final int layoutIndex = n;
    allActions.put("Layout " + nf(layoutIndex, 0), () -> {
      STUDY.plotSetup = layoutIndex;
      STUDY.revise();
    });
  }

  for (int n = 1; n <= 11; n++) {
    final int modelIndex = n;
    allActions.put("3D-model " + nf(modelIndex, 0), () -> {
      deleteAll();
      Create3D.add_DefaultModel(modelIndex);
      allSolidImpacts.calculate_Impact_selectedSections();
      UI_rollout.revise();
      WIN3D.revise();
    });
  }
}
