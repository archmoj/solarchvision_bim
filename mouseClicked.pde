void mouseClicked () {

  if (frameCount > Last_initializationStep) {

    if (SOLARCHVISION_automated == 0) {

      if (FRAME_click_IMG) {

        SOLARCHVISION_RecordFrame();

        UI_toolBar.drawMouse(1, mouseX, mouseY, 2 * MessageSize);

        SOLARCHVISION_RecordFrame();
      }


      if ((UI_menuBar.selected_parent != -1) && (isInside(mouseX, mouseY, 0, 0, width, SOLARCHVISION_pixel_A) == false)) {

        String menu_option = UI_menuBar.Items[UI_menuBar.selected_parent][UI_menuBar.selected_child];

        if (mouseButton == LEFT) {
          if (UI_menuBar.selected_child != 0) {

            // should call the functions here!

            if (menu_option.equals("Mojtaba Samimi")) {
              link("https://solarchvision.com/?page_id=102");
            }

            if (menu_option.equals("www.solarchvision.com")) {
              link("https://solarchvision.com/");
            }

            if (menu_option.equals("New")) {

              /////////////////////////////
              SOLARCHVISION_hold_project();
              /////////////////////////////

              selectInput("Specify project name:", "SOLARCHVISION_fileSelected_New");

              SOLARCHVISION_deleteAll();

              //SOLARCHVISION_update_station(0);
            }

            if (menu_option.equals("Save")) {
              SOLARCHVISION_save_project(Folder_Project + "/" + ProjectName + ".xml");
            }

            if (menu_option.equals("Hold")) {

              SOLARCHVISION_hold_project();
            }

            if (menu_option.equals("Fetch")) {

              SOLARCHVISION_fetch_project();
            }

            if (menu_option.equals("Open...")) {
              selectInput("Select a file to open:", "SOLARCHVISION_fileSelected_Open");
            }

            if (menu_option.equals("Save As...")) {
              selectOutput("Select a file to write to:", "SOLARCHVISION_fileSelected_SaveAs");
            }

            if (menu_option.equals("Import 3D-model...")) {
              selectInput("Select OBJ file to import:", "SOLARCHVISION_SelectFile_Import_3DModel");
            }

            if (menu_option.equals("Import Command File...")) {
              selectInput("Select TXT file to execute:", "SOLARCHVISION_SelectFile_Execute_CommandFile");
            }

            if (menu_option.equals("Export 3D-model > OBJ (time-series)")) {
              SOLARCHVISION_export_objects_OBJ_timeSeries();
            }


            if (menu_option.equals("Export 3D-model > OBJ (date-series)")) {
              SOLARCHVISION_export_objects_OBJ_dateSeries();
            }

            if (menu_option.equals("Export 3D-model > OBJ")) {
              SOLARCHVISION_export_objects_OBJ("");
            }

            if (menu_option.equals("Export 3D-model > HTML")) {
              SOLARCHVISION_export_objects_HTML();
            }

            if (menu_option.equals("Export 3D-model > RAD")) {
              SOLARCHVISION_export_objects_RAD();
            }

            if (menu_option.equals("Export 3D-model > SCR")) {
              SOLARCHVISION_export_objects_SCR();
            }

            if (menu_option.equals("Quit")) {
              exit();
            }



            if (menu_option.equals("Wind pattern (active)")) {
              STUDY.PlotImpacts = PlotImpacts_WIND_ACTIVE;
              STUDY.plotSetup = 0;
              STUDY.revise();
              allWindRoses.displayImage = true;
              ROLLOUT.revise();
            }
            if (menu_option.equals("Wind pattern (passive)")) {
              STUDY.PlotImpacts = PlotImpacts_WIND_PASSIVE;
              STUDY.plotSetup = 0;
              STUDY.revise();
              allWindRoses.displayImage = true;
              ROLLOUT.revise();
            }
            if (menu_option.equals("Urban solar potential (active)")) {
              STUDY.PlotImpacts = PlotImpacts_URBAN_ACTIVE;
              STUDY.plotSetup = 0;
              STUDY.revise();
              allWindRoses.displayImage = false;
              ROLLOUT.revise();
            }
            if (menu_option.equals("Urban solar potential (passive)")) {
              STUDY.PlotImpacts = PlotImpacts_URBAN_PASSIVE;
              STUDY.plotSetup = 0;
              STUDY.revise();
              allWindRoses.displayImage = false;
              ROLLOUT.revise();
            }
            if (menu_option.equals("Orientation potential (active)")) {
              STUDY.PlotImpacts = PlotImpacts_GLOBAL_ACTIVE;
              STUDY.plotSetup = 0;
              STUDY.revise();
              allWindRoses.displayImage = false;
              ROLLOUT.revise();
            }
            if (menu_option.equals("Orientation potential (passive)")) {
              STUDY.PlotImpacts = PlotImpacts_GLOBAL_PASSIVE;
              STUDY.plotSetup = 0;
              STUDY.revise();
              allWindRoses.displayImage = false;
              ROLLOUT.revise();
            }
            if (menu_option.equals("Hourly sun position (active)")) {
              STUDY.PlotImpacts = PlotImpacts_SUNPATH_ACTIVE;
              STUDY.plotSetup = 0;
              STUDY.revise();
              allWindRoses.displayImage = false;
              ROLLOUT.revise();
            }
            if (menu_option.equals("Hourly sun position (passive)")) {
              STUDY.PlotImpacts = PlotImpacts_SUNPATH_PASSIVE;
              STUDY.plotSetup = 0;
              STUDY.revise();
              allWindRoses.displayImage = false;
              ROLLOUT.revise();
            }
            if (menu_option.equals("Annual cycle sun path (active)")) {
              STUDY.PlotImpacts = PlotImpacts_CYCLES_ACTIVE;
              STUDY.plotSetup = 0;
              STUDY.revise();
              allWindRoses.displayImage = false;
              ROLLOUT.revise();
            }
            if (menu_option.equals("Annual cycle sun path (passive)")) {
              STUDY.PlotImpacts = PlotImpacts_CYCLES_PASSIVE;
              STUDY.plotSetup = 0;
              STUDY.revise();
              allWindRoses.displayImage = false;
              ROLLOUT.revise();
            }

            if (menu_option.equals("Pre-bake Selected Sections")) {
              allSolarImpacts.render_Shadows_selectedSections();

              SOLARCHVISION_view_changed();
            }

            if (menu_option.equals("Process Active Impact")) {
              STUDY.PlotImpacts = PlotImpacts_URBAN_ACTIVE;
              allSolarImpacts.calculate_Impact_selectedSections();

              SOLARCHVISION_view_changed();
            }

            if (menu_option.equals("Process Passive Impact")) {
              STUDY.PlotImpacts = PlotImpacts_URBAN_PASSIVE;
              allSolarImpacts.calculate_Impact_selectedSections();

              SOLARCHVISION_view_changed();
            }

            if (menu_option.equals("Process Solid Impact")) {
              allSolidImpacts.calculate_Impact_selectedSections();

              SOLARCHVISION_view_changed();
            }

            if (menu_option.equals("Run wind 3D-model")) {
              allSolidImpacts.calculate_WindFlow();

              SOLARCHVISION_view_changed();
            }

            for (int n = -2; n <= 8; n++) {
              if (menu_option.equals("Layout " + nf(n, 0))) {

                STUDY.plotSetup = n;
                STUDY.revise();
              }
            }

            for (int n = 1; n <= 7; n++) {
              if (menu_option.equals("3D-model " + nf(n, 0))) {

                SOLARCHVISION_deleteAll();

                Create3D.add_DefaultModel(n);

                allSolidImpacts.calculate_Impact_selectedSections();

                ROLLOUT.revise();

                WIN3D.revise();
              }
            }




            if (menu_option.equals("Stop REC.")) {
              STUDY.record_AUTO = false;
              STUDY.record_IMG = false;
              STUDY.record_PDF = false;
              WORLD.record_AUTO = false;
              WORLD.record_IMG = false;
              WORLD.record_PDF = false;
              WIN3D.record_AUTO = false;
              WIN3D.record_IMG = false;
              FRAME_record_AUTO = false;
              FRAME_record_IMG = false;
              FRAME_click_IMG = false;
              FRAME_drag_IMG = false;

              ROLLOUT.revise();
            }

            if (menu_option.equals("REC. Time Graph")) {
              STUDY.record_AUTO = true;
              STUDY.record_IMG = false;
              STUDY.record_PDF = false;
              WORLD.record_AUTO = false;
              WORLD.record_IMG = false;
              WORLD.record_PDF = false;
              WIN3D.record_AUTO = false;
              WIN3D.record_IMG = false;
              FRAME_record_AUTO = false;
              FRAME_record_IMG = false;
              FRAME_click_IMG = false;
              FRAME_drag_IMG = false;

              ROLLOUT.revise();
            }

            if (menu_option.equals("REC. Location Graph")) {
              STUDY.record_AUTO = false;
              STUDY.record_IMG = false;
              STUDY.record_PDF = false;
              WORLD.record_AUTO = true;
              WORLD.record_IMG = false;
              WORLD.record_PDF = false;
              WIN3D.record_AUTO = false;
              WIN3D.record_IMG = false;
              FRAME_record_AUTO = false;
              FRAME_record_IMG = false;
              FRAME_click_IMG = false;
              FRAME_drag_IMG = false;

              ROLLOUT.revise();
            }

            if (menu_option.equals("REC. Solid Graph")) {
              STUDY.record_AUTO = false;
              STUDY.record_IMG = false;
              STUDY.record_PDF = false;
              WORLD.record_AUTO = false;
              WORLD.record_IMG = false;
              WORLD.record_PDF = false;
              WIN3D.record_AUTO = true;
              WIN3D.record_IMG = false;
              FRAME_record_AUTO = false;
              FRAME_record_IMG = false;
              FRAME_click_IMG = false;
              FRAME_drag_IMG = false;

              ROLLOUT.revise();
            }

            if (menu_option.equals("REC. Screenshot")) {
              STUDY.record_AUTO = false;
              STUDY.record_IMG = false;
              STUDY.record_PDF = false;
              WORLD.record_AUTO = false;
              WORLD.record_IMG = false;
              WORLD.record_PDF = false;
              WIN3D.record_AUTO = false;
              WIN3D.record_IMG = false;
              FRAME_record_AUTO = true;
              FRAME_record_IMG = false;
              FRAME_click_IMG = false;
              FRAME_drag_IMG = false;

              ROLLOUT.revise();
            }

            if (menu_option.equals("PDF Time Graph")) {
              STUDY.record_PDF = true;
              STUDY.revise();
            }

            if (menu_option.equals("JPG Time Graph")) {
              STUDY.record_IMG = true;
              STUDY.revise();
            }

            if (menu_option.equals("JPG Location Graph")) {
              WORLD.record_IMG = true;
              WORLD.revise();
            }

            if (menu_option.equals("PDF Location Graph")) {
              WORLD.record_PDF = true;
              WORLD.revise();
            }

            if (menu_option.equals("JPG 3D Graph")) {
              WIN3D.record_IMG = true;

              SOLARCHVISION_view_changed();
            }

            if (menu_option.equals("JPG 3D Full-Period")) {
              WIN3D.fullPeriod_IMG = true;
              WIN3D.record_IMG = true;

              SOLARCHVISION_view_changed();
            }

            if (menu_option.equals("Screenshot")) {
              FRAME_record_IMG = true;
            }

            if (menu_option.equals("Screenshot+Click")) {
              FRAME_click_IMG = true;
            }

            if (menu_option.equals("Screenshot+Drag")) {
              FRAME_drag_IMG = true;
            }

            if (menu_option.equals("Update Station")) {
              SOLARCHVISION_update_station(0);
            }

            if (menu_option.equals("Load Land Mesh")) {
              Land3D.update_textures();
            }

            if (menu_option.equals("Load Land Texture")) {
              Land3D.update_textures();
            }

            if (menu_option.equals("Download Land Mesh")) {
              Land3D.download_mesh();
            }

            if (menu_option.equals("Download Land Texture")) {
              Land3D.download_textures();
            }

            if (menu_option.equals("Load Toroposphere")) {
              Tropo3D.download_images();
              Tropo3D.displaySurface = true;
              WORLD.revise();
              WIN3D.revise();
            }

            if (menu_option.equals("Download NAEFS")) {
              download_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);
            }
            if (menu_option.equals("Download CLMREC")) {
              download_CLIMATE_CLMREC();
            }
            if (menu_option.equals("Download SWOB")) {
              download_ENSEMBLE_OBSERVED();
            }





            if (menu_option.equals("Update TMYEPW")) {
              CurrentDataSource = dataID_CLIMATE_TMYEPW;

              CLIMATE_TMYEPW_load = true;
              update_CLIMATE_TMYEPW();
            }
            if (menu_option.equals("Update CWEEDS")) {
              CurrentDataSource = dataID_CLIMATE_CWEEDS;

              CLIMATE_CWEEDS_load = true;
              update_CLIMATE_CWEEDS();
            }
            if (menu_option.equals("Update CLMREC")) {
              CurrentDataSource = dataID_CLIMATE_CLMREC;

              CLIMATE_CLMREC_load = true;
              update_CLIMATE_CLMREC();
            }
            if (menu_option.equals("Update SWOB")) {
              CurrentDataSource = dataID_ENSEMBLE_OBSERVED;

              ENSEMBLE_OBSERVED_load = true;
              update_ENSEMBLE_OBSERVED();
            }
            if (menu_option.equals("Update NAEFS")) {
              CurrentDataSource = dataID_ENSEMBLE_FORECAST;

              ENSEMBLE_FORECAST_load = true;
              update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);
            }
            if (menu_option.equals("Use typical year (TMY)")) {
              CurrentDataSource = dataID_CLIMATE_TMYEPW;

              CLIMATE_TMYEPW_load = true;
              update_CLIMATE_TMYEPW();

              SOLARCHVISION_view_changed();
              WORLD.revise();
              STUDY.revise();
              ROLLOUT.revise();
              UI_caseBar.revise();

              WORLD.displayAll_TMYEPW = 1;
              WORLD.displayNear_TMYEPW = true;
            }
            if (menu_option.equals("Use long-term (CWEEDS)")) {
              CurrentDataSource = dataID_CLIMATE_CWEEDS;

              CLIMATE_CWEEDS_load = true;
              update_CLIMATE_CWEEDS();

              SOLARCHVISION_view_changed();
              WORLD.revise();
              STUDY.revise();
              ROLLOUT.revise();
              UI_caseBar.revise();

              WORLD.displayAll_CWEEDS = 1;
              WORLD.displayNear_CWEEDS = true;
            }
            if (menu_option.equals("Use long-term (CLMREC)")) {
              CurrentDataSource = dataID_CLIMATE_CLMREC;

              CLIMATE_CLMREC_load = true;
              update_CLIMATE_CLMREC();

              SOLARCHVISION_view_changed();
              WORLD.revise();
              STUDY.revise();
              ROLLOUT.revise();
              UI_caseBar.revise();

              WORLD.displayAll_CLMREC = 1;
              WORLD.displayNear_CLMREC = true;
            }
            if (menu_option.equals("Use real-time observed (SWOB)")) {
              CurrentDataSource = dataID_ENSEMBLE_OBSERVED;
              STUDY.joinDays = 1;

              ENSEMBLE_OBSERVED_load = true;
              update_ENSEMBLE_OBSERVED();

              SOLARCHVISION_view_changed();
              WORLD.revise();
              STUDY.revise();
              ROLLOUT.revise();
              UI_caseBar.revise();

              WORLD.displayAll_SWOB = 1;
              WORLD.displayNear_SWOB = true;
            }
            if (menu_option.equals("Use weather forecast (NAEFS)")) {
              CurrentDataSource = dataID_ENSEMBLE_FORECAST;
              STUDY.joinDays = 1;

              ENSEMBLE_FORECAST_load = true;
              update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);

              SOLARCHVISION_view_changed();
              WIN3D.revise();
              STUDY.revise();
              ROLLOUT.revise();
              UI_caseBar.revise();

              WORLD.displayAll_NAEFS = 1;
              WORLD.displayNear_NAEFS = true;
            }




            if (UI_menuBar.Items[UI_menuBar.selected_parent][0].equals("Layer")) {
              if (UI_menuBar.selected_child > 0) {

                if (UI_menuBar.selected_child < numberOfLayers) {

                  changeCurrentLayerTo(UI_menuBar.selected_child - 1);

                  DevelopLayer_id = CurrentLayer_id;

                  STUDY.revise();
                } else if (menu_option.charAt(0) != '—') {
                  Develop_Option = UI_menuBar.selected_child - numberOfLayers - 1; // -1 for the divider

                  SOLARCHVISION_postProcess_developDATA(CurrentDataSource);

                  changeCurrentLayerTo(LAYER_developed.id);

                  STUDY.revise();
                }
              }
            }

            if (menu_option.equals("Active Shade")) {
              Impact_TYPE = Impact_ACTIVE;

              if (WIN3D.FacesShade == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
              if (WIN3D.FacesShade == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Passive Shade")) {
              Impact_TYPE = Impact_PASSIVE;

              if (WIN3D.FacesShade == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
              if (WIN3D.FacesShade == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;

              SOLARCHVISION_view_changed();
            }

            if (menu_option.equals("Shade Surface Wire")) {
              WIN3D.FacesShade = SHADE.Surface_Wire;
              allFaces.displayEdges = true; //<<<<<<<<<<<<<<<

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Shade Surface Base")) {
              WIN3D.FacesShade = SHADE.Surface_Base;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Shade Surface White")) {
              WIN3D.FacesShade = SHADE.Surface_White;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Shade Surface Materials")) {
              WIN3D.FacesShade = SHADE.Surface_Materials;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Shade Global Solar")) {
              WIN3D.FacesShade = SHADE.Global_Solar;

              GlobalSolar_rebuild_array = true;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Shade Vertex Solar")) {
              WIN3D.FacesShade = SHADE.Vertex_Solar;

              VertexSolar_rebuild_array = true;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Shade Vertex Solid")) {
              WIN3D.FacesShade = SHADE.Vertex_Solid;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Shade Vertex Elevation")) {
              WIN3D.FacesShade = SHADE.Vertex_Elevation;

              SOLARCHVISION_view_changed();
            }

            if (menu_option.equals("Render Viewport")) {
              SOLARCHVISION_RenderViewport();
            }
            if (menu_option.equals("PreBake Viewport")) {
              SOLARCHVISION_preBakeViewport();
            }


            if (menu_option.equals("Display/Hide Land Mesh")) {
              Land3D.displaySurface = !Land3D.displaySurface;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Land Texture")) {
              Land3D.displayTexture = !Land3D.displayTexture;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Land Points")) {
              Land3D.displayPoints = !Land3D.displayPoints;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Land Depth")) {
              Land3D.displayDepth = !Land3D.displayDepth;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Vertices")) {
              allPoints.displayAll = !allPoints.displayAll;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Edges")) {
              allFaces.displayEdges = !allFaces.displayEdges;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Normals")) {
              allFaces.displayNormals = !allFaces.displayNormals;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Leaves")) {
              allModel1Ds.displayLeaves = !allModel1Ds.displayLeaves;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Model1Ds")) {
              allModel1Ds.displayAll = !allModel1Ds.displayAll;
              allModel1Ds.displayLeaves = allModel1Ds.displayAll; // <<<<<<

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Model2Ds")) {
              allModel2Ds.displayAll = !allModel2Ds.displayAll;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Polylines")) {
              allPolylines.displayAll = !allPolylines.displayAll;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Faces")) {
              allFaces.displayAll = !allFaces.displayAll;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Solids")) {
              allSolids.displayAll = !allSolids.displayAll;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Sections")) {
              allSections.displayAll = !allSections.displayAll;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Cameras")) {
              allCameras.displayAll = !allCameras.displayAll;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Sky")) {
              Sky3D.displaySurface = !Sky3D.displaySurface;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Sun Grid")) {
              Sun3D.displayGrid = !Sun3D.displayGrid;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Sun Path")) {
              Sun3D.displayPath = !Sun3D.displayPath;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Sun Pattern")) {
              Sun3D.displayPattern = !Sun3D.displayPattern;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Sun Surface")) {
              Sun3D.displaySurface = !Sun3D.displaySurface;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Moon Surface")) {
              Moon3D.displaySurface = !Moon3D.displaySurface;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Earth Surface")) {
              Earth3D.displaySurface = !Earth3D.displaySurface;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Troposphere")) {
              Tropo3D.displaySurface = !Tropo3D.displaySurface;

              SOLARCHVISION_view_changed();
              WORLD.revise();
            }
            if (menu_option.equals("Display/Hide Solar Section")) {
              allSolarImpacts.displayImage = !allSolarImpacts.displayImage;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Solid Section")) {
              allSolidImpacts.displayImage = !allSolidImpacts.displayImage;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Selected Solids")) {
              Select3D.Solid_displayEdges = !Select3D.Solid_displayEdges;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Selected Sections")) {
              Select3D.Section_displayEdges = !Select3D.Section_displayEdges;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Selected Cameras")) {
              Select3D.Camera_displayEdges = !Select3D.Camera_displayEdges;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Selected LandPoints")) {
              Select3D.LandPoint_displayPoints = !Select3D.LandPoint_displayPoints;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Wind Flow")) {
              allWindFlows.displayAll = !allWindFlows.displayAll;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Selected Faces")) {
              Select3D.Face_displayEdges = !Select3D.Face_displayEdges;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Selected Faces Vertex Count")) {
              Select3D.Face_displayVertexCount = !Select3D.Face_displayVertexCount;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Selected Polylines Vertex Count")) {
              Select3D.Polyline_displayVertexCount = !Select3D.Polyline_displayVertexCount;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Selected Vertices")) {
              Select3D.Vertex_displayVertices = !Select3D.Vertex_displayVertices;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Selected Polylines")) {
              Select3D.Polyline_displayVertices = !Select3D.Polyline_displayVertices;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Selected REF Pivot")) {
              Select3D.displayReferencePivot = !Select3D.displayReferencePivot;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Selected Group Pivot")) {
              Select3D.Group_displayPivot = !Select3D.Group_displayPivot;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Selected Group Edges")) {
              Select3D.Group_displayEdges = !Select3D.Group_displayEdges;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Selected Group Box")) {
              Select3D.Group_displayBox = !Select3D.Group_displayBox;

              SOLARCHVISION_view_changed();;
            }
            if (menu_option.equals("Display/Hide Selected 2D Edges")) {
              Select3D.Model2D_displayEdges = !Select3D.Model2D_displayEdges;

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Display/Hide Selected 1D Edges")) {
              Select3D.Model1D_displayEdges = !Select3D.Model1D_displayEdges;

              SOLARCHVISION_view_changed();
            }

            if (menu_option.equals("Display/Hide SWOB stations")) {
              WORLD.displayAll_SWOB = (WORLD.displayAll_SWOB + 1) % 2;

              WORLD.revise();
            }
            if (menu_option.equals("Display/Hide SWOB nearest")) {
              WORLD.displayNear_SWOB = !WORLD.displayNear_SWOB;

              WORLD.revise();
            }
            if (menu_option.equals("Display/Hide NAEFS stations")) {
              WORLD.displayAll_NAEFS = (WORLD.displayAll_NAEFS + 1) % 2;

              WORLD.revise();
            }
            if (menu_option.equals("Display/Hide NAEFS nearest")) {
              WORLD.displayNear_NAEFS = !WORLD.displayNear_NAEFS;

              WORLD.revise();
            }
            if (menu_option.equals("Display/Hide CWEEDS stations")) {
              WORLD.displayAll_CWEEDS = (WORLD.displayAll_CWEEDS + 1) % 2;

              WORLD.revise();
            }
            if (menu_option.equals("Display/Hide CWEEDS nearest")) {
              WORLD.displayNear_CWEEDS = !WORLD.displayNear_CWEEDS;

              WORLD.revise();
            }
            if (menu_option.equals("Display/Hide CLMREC stations")) {
              WORLD.displayAll_CLMREC = (WORLD.displayAll_CLMREC + 1) % 2;

              WORLD.revise();
            }
            if (menu_option.equals("Display/Hide CLMREC nearest")) {
              WORLD.displayNear_CLMREC = !WORLD.displayNear_CLMREC;

              WORLD.revise();
            }
            if (menu_option.equals("Display/Hide TMYEPW stations")) {
              WORLD.displayAll_TMYEPW = (WORLD.displayAll_TMYEPW + 1) % 2;

              WORLD.revise();
            }
            if (menu_option.equals("Display/Hide TMYEPW nearest")) {
              WORLD.displayNear_TMYEPW = !WORLD.displayNear_TMYEPW;

              WORLD.revise();
            }

            if (menu_option.equals("3D-Tree")) {
              UI_set_to_Create_allModel1Ds();
              UI_toolBar.highlight("3D-Tree");
              UI_toolBar.revise();
            }
            if (menu_option.equals("2D-Tree")) {
              UI_set_to_Create_Tree();
              UI_toolBar.highlight("2D-Tree");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Person")) {
              UI_set_to_Create_Person();
              UI_toolBar.highlight("Person");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Point")) {
              UI_set_to_Create_Vertex();
              UI_toolBar.highlight("Point");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Polyline")) {
              UI_set_to_Create_Polyline();
              UI_toolBar.highlight("Polyline");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Surface")) {
              UI_set_to_Create_Face();
              UI_toolBar.highlight("Surface");
              UI_toolBar.revise();
            }


            if (menu_option.equals("Parametric 1")) {
              UI_set_to_Create_Parametric(1);
              UI_toolBar.highlight("Parametric");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Parametric 2")) {
              UI_set_to_Create_Parametric(2);
              UI_toolBar.highlight("Parametric");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Parametric 3")) {
              UI_set_to_Create_Parametric(3);
              UI_toolBar.highlight("Parametric");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Parametric 4")) {
              UI_set_to_Create_Parametric(4);
              UI_toolBar.highlight("Parametric");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Parametric 5")) {
              UI_set_to_Create_Parametric(5);
              UI_toolBar.highlight("Parametric");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Parametric 6")) {
              UI_set_to_Create_Parametric(6);
              UI_toolBar.highlight("Parametric");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Parametric 7")) {
              UI_set_to_Create_Parametric(7);
              UI_toolBar.highlight("Parametric");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Tri")) {
              UI_set_to_Create_Tri();
              UI_toolBar.highlight("Tri");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Plane")) {
              UI_set_to_Create_Plane();
              UI_toolBar.highlight("Plane");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Polygon")) {
              UI_set_to_Create_Polygon();
              UI_toolBar.highlight("Polygon");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Extrude")) {
              UI_set_to_Create_Extrude();
              UI_toolBar.highlight("Extrude");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Hyper")) {
              UI_set_to_Create_Hyper();
              UI_toolBar.highlight("Hyper");
              UI_toolBar.revise();
            }
            if (menu_option.equals("House3")) {
              UI_set_to_Create_House3();
              UI_toolBar.highlight("House3");
              UI_toolBar.revise();
            }
            if (menu_option.equals("House2")) {
              UI_set_to_Create_House2();
              UI_toolBar.highlight("House2");
              UI_toolBar.revise();
            }
            if (menu_option.equals("House1")) {
              UI_set_to_Create_House1();
              UI_toolBar.highlight("House1");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Box")) {
              UI_set_to_Create_Box();
              UI_toolBar.highlight("Box");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Icosahedron")) {
              UI_set_to_Create_Icosahedron();
              UI_toolBar.highlight("Icosahedron");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Octahedron")) {
              UI_set_to_Create_Octahedron();
              UI_toolBar.highlight("Octahedron");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Sphere")) {
              UI_set_to_Create_Sphere();
              UI_toolBar.highlight("Sphere");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Cylinder")) {
              UI_set_to_Create_Cylinder();
              UI_toolBar.highlight("Cylinder");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Cushion")) {
              UI_set_to_Create_Cushion();
              UI_toolBar.highlight("Cushion");
              UI_toolBar.revise();
            }



            if (menu_option.equals("Drop on LandSurface")) {
              UI_set_to_Modify_Drop(0);
              UI_toolBar.highlight("DrL±");
              UI_toolBar.revise();

              Drop3D.selection();
            }
            if (menu_option.equals("Drop on ModelSurface (Down)")) {
              UI_set_to_Modify_Drop(1);
              UI_toolBar.highlight("DrM-");
              UI_toolBar.revise();

              Drop3D.selection();
            }
            if (menu_option.equals("Drop on ModelSurface (Up)")) {
              UI_set_to_Modify_Drop(2);
              UI_toolBar.highlight("DrM+");
              UI_toolBar.revise();

              Drop3D.selection();
            }



            if (menu_option.equals("Get dX")) {
              UI_set_to_Modify_GetLength(0);
              UI_toolBar.highlight("GLx");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Get dY")) {
              UI_set_to_Modify_GetLength(1);
              UI_toolBar.highlight("GLy");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Get dZ")) {
              UI_set_to_Modify_GetLength(2);
              UI_toolBar.highlight("GLz");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Get dXYZ")) {
              UI_set_to_Modify_GetLength(3);
              UI_toolBar.highlight("GL³");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Get dXY")) {
              UI_set_to_Modify_GetLength(4);
              UI_toolBar.highlight("GL²");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Get Angle")) {
              UI_set_to_Modify_GetLength(5);
              UI_toolBar.highlight("GLa");
              UI_toolBar.revise();
            }


            if (menu_option.equals("MoveX")) {
              UI_set_to_Modify_Move(0);
              UI_toolBar.highlight("MVx");
              UI_toolBar.revise();
            }
            if (menu_option.equals("MoveY")) {
              UI_set_to_Modify_Move(1);
              UI_toolBar.highlight("MVy");
              UI_toolBar.revise();
            }
            if (menu_option.equals("MoveZ")) {
              UI_set_to_Modify_Move(2);
              UI_toolBar.highlight("MVz");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Move")) {
              UI_set_to_Modify_Move(3);
              UI_toolBar.highlight("MV³");
              UI_toolBar.revise();
            }


            if (menu_option.equals("ScaleX")) {
              UI_set_to_Modify_Scale(0);
              UI_toolBar.highlight("SCx");
              UI_toolBar.revise();
            }
            if (menu_option.equals("ScaleY")) {
              UI_set_to_Modify_Scale(1);
              UI_toolBar.highlight("SCy");
              UI_toolBar.revise();
            }
            if (menu_option.equals("ScaleZ")) {
              UI_set_to_Modify_Scale(2);
              UI_toolBar.highlight("SCz");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Scale")) {
              UI_set_to_Modify_Scale(3);
              UI_toolBar.highlight("SC³");
              UI_toolBar.revise();
            }


            if (menu_option.equals("PowerX")) {
              UI_set_to_Modify_Power(0);
              UI_toolBar.highlight("PWx");
              UI_toolBar.revise();
            }
            if (menu_option.equals("PowerY")) {
              UI_set_to_Modify_Power(1);
              UI_toolBar.highlight("PWy");
              UI_toolBar.revise();
            }
            if (menu_option.equals("PowerZ")) {
              UI_set_to_Modify_Power(2);
              UI_toolBar.highlight("PWz");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Power")) {
              UI_set_to_Modify_Power(3);
              UI_toolBar.highlight("PW³");
              UI_toolBar.revise();
            }


            if (menu_option.equals("RotateX")) {
              UI_set_to_Modify_Rotate(0);
              UI_toolBar.highlight("RTx");
              UI_toolBar.revise();
            }
            if (menu_option.equals("RotateY")) {
              UI_set_to_Modify_Rotate(1);
              UI_toolBar.highlight("RTy");
              UI_toolBar.revise();
            }
            if (menu_option.equals("RotateZ")) {
              UI_set_to_Modify_Rotate(2);
              UI_toolBar.highlight("RTz");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Rotate")) {
              UI_set_to_Modify_Rotate(2);
              UI_toolBar.revise();
            }

            if (menu_option.equals("Pivot")) {
              UI_set_to_Modify_Pivot(0);
              UI_toolBar.highlight("SPvt0");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Pick Pivot")) {
              UI_set_to_Modify_Pivot(1);
              UI_toolBar.highlight("SPvt1");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Assign Pivot")) {
              UI_set_to_Modify_Pivot(2);
              UI_toolBar.highlight("SPvt2");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Save Current ReferenceBox")) {
              Select3D.save_current_BoundingBox();
              UI_toolBar.highlight("<pvt>");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Reset Saved ReferenceBox")) {
              Select3D.apply_saved_BoundingBox();
              UI_toolBar.highlight(">pvt<");
              UI_toolBar.revise();

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Use Selection ReferenceBox")) {
              Select3D.calculate_BoundingBox();
              UI_toolBar.highlight("|pvt|");
              UI_toolBar.revise();

              SOLARCHVISION_view_changed();
            }
            if (menu_option.equals("Use Origin ReferenceBox")) {
              Select3D.apply_origin_ReferenceBox();
              UI_toolBar.highlight(".pvt.");
              UI_toolBar.revise();

              SOLARCHVISION_view_changed();
            }



            if (menu_option.equals("Begin New Group at Origin")) {

              allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);

              Select3D.Group_ids = new int [1];
              Select3D.Group_ids[0] = allGroups.num - 1;

              SOLARCHVISION_model_changed();
            }

            if (menu_option.equals("Begin New Group at Pivot")) {

              allGroups.beginNewGroup(Select3D.BoundingBox[1 + Select3D.alignX][0], Select3D.BoundingBox[1 + Select3D.alignX][1], Select3D.BoundingBox[1 + Select3D.alignX][2], Select3D.BoundingBox[1 + Select3D.alignX][3], Select3D.BoundingBox[1 + Select3D.alignX][4], Select3D.BoundingBox[1 + Select3D.alignX][5], Select3D.BoundingBox[1 + Select3D.alignX][6], Select3D.BoundingBox[1 + Select3D.alignX][7], Select3D.BoundingBox[1 + Select3D.alignX][8]);

              Select3D.Group_ids = new int [1];
              Select3D.Group_ids[0] = allGroups.num - 1;

              SOLARCHVISION_model_changed();
            }

            if (menu_option.equals("Solid")) {
              UI_set_to_Create_Solid();
              UI_toolBar.highlight("SLD");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Section")) {
              UI_set_to_Create_Section();
              UI_toolBar.highlight("SEC");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Camera")) {
              UI_set_to_Create_Camera();
              UI_toolBar.highlight("CAM");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Viewport >> Camera")) {

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
              SOLARCHVISION_modify_Viewport_Title();

              SOLARCHVISION_view_changed();

              UI_toolBar.revise();
            }

            if (menu_option.equals("Camera >> Viewport")) {

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
              SOLARCHVISION_modify_Viewport_Title();

              SOLARCHVISION_view_changed();

              UI_toolBar.revise();
            }

            if (menu_option.equals("GoTo Selected Camera")) {
              if (Select3D.Camera_ids.length > 0) {
                WIN3D.currentCamera = Select3D.Camera_ids[Select3D.Camera_ids.length - 1];
                WIN3D.apply_currentCamera();
                SOLARCHVISION_modify_Viewport_Title();

                SOLARCHVISION_view_changed();

                UI_toolBar.revise();
              }
            }

            if (menu_option.equals("LandMesh >> Group")) {
              Land3D.draw(TypeWindow.LandMesh);

              SOLARCHVISION_model_changed();
            }

            if (menu_option.equals("LandGap >> Group")) {
              Land3D.draw(TypeWindow.LandGap);

              SOLARCHVISION_model_changed();
            }



            if (menu_option.equals("Change Seed/Material")) {
              UI_set_to_Modify_Seed(0);
              UI_toolBar.highlight("Mat0");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Pick Seed/Material")) {
              UI_set_to_Modify_Seed(1);
              UI_toolBar.highlight("Mat1");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Assign Seed/Material")) {
              UI_set_to_Modify_Seed(2);
              UI_toolBar.highlight("Mat2");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Change tessellation")) {
              UI_set_to_Modify_Tessellation(0);
              UI_toolBar.highlight("Tes0");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Pick tessellation")) {
              UI_set_to_Modify_Tessellation(1);
              UI_toolBar.highlight("Tes1");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Assign tessellation")) {
              UI_set_to_Modify_Tessellation(2);
              UI_toolBar.highlight("Tes2");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Change Layer")) {
              UI_set_to_Modify_Layer(0);
              UI_toolBar.highlight("Lyr0");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Pick Layer")) {
              UI_set_to_Modify_Layer(1);
              UI_toolBar.highlight("Lyr1");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Assign Layer")) {
              UI_set_to_Modify_Layer(2);
              UI_toolBar.highlight("Lyr2");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Change Visibility")) {
              UI_set_to_Modify_Visibility(0);
              UI_toolBar.highlight("Vsb0");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Pick Visibility")) {
              UI_set_to_Modify_Visibility(1);
              UI_toolBar.highlight("Vsb1");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Assign Visibility")) {
              UI_set_to_Modify_Visibility(2);
              UI_toolBar.highlight("Vsb2");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Change Weight")) {
              UI_set_to_Modify_Weight(0);
              UI_toolBar.highlight("Wgt0");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Pick Weight")) {
              UI_set_to_Modify_Weight(1);
              UI_toolBar.highlight("Wgt1");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Assign Weight")) {
              UI_set_to_Modify_Weight(2);
              UI_toolBar.highlight("Wgt2");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Flip Normal")) {
              UI_set_to_Modify_Normal(1);
              UI_toolBar.highlight("Norm1");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Set-Out Normal")) {
              UI_set_to_Modify_Normal(2);
              UI_toolBar.highlight("Norm2");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Set-In Normal")) {
              UI_set_to_Modify_Normal(3);
              UI_toolBar.highlight("Norm3");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Get FirstVertex")) {
              UI_set_to_Modify_FirstVertex(1);
              UI_toolBar.highlight("1stV");
              UI_toolBar.revise();
            }



            if (menu_option.equals("Change DegreeMax")) {
              UI_set_to_Modify_DegreeMax(0);
              UI_toolBar.highlight("dgMax0");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Pick DegreeMax")) {
              UI_set_to_Modify_DegreeMax(1);
              UI_toolBar.highlight("dgMax1");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Assign DegreeMax")) {
              UI_set_to_Modify_DegreeMax(2);
              UI_toolBar.highlight("dgMax2");
              UI_toolBar.revise();
            }




            if (menu_option.equals("Change BranchTilt")) {
              UI_set_to_Modify_BranchTilt(0);
              UI_toolBar.highlight("bTilt0");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Pick BranchTilt")) {
              UI_set_to_Modify_BranchTilt(1);
              UI_toolBar.highlight("bTilt1");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Assign BranchTilt")) {
              UI_set_to_Modify_BranchTilt(2);
              UI_toolBar.highlight("bTilt2");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Change BranchTwist")) {
              UI_set_to_Modify_BranchTwist(0);
              UI_toolBar.highlight("bTwist0");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Pick BranchTwist")) {
              UI_set_to_Modify_BranchTwist(1);
              UI_toolBar.highlight("bTwist1");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Assign BranchTwist")) {
              UI_set_to_Modify_BranchTwist(2);
              UI_toolBar.highlight("bTwist2");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Change BranchRatio")) {
              UI_set_to_Modify_BranchRatio(0);
              UI_toolBar.highlight("bRatio0");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Pick BranchRatio")) {
              UI_set_to_Modify_BranchRatio(1);
              UI_toolBar.highlight("bRatio1");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Assign BranchRatio")) {
              UI_set_to_Modify_BranchRatio(2);
              UI_toolBar.highlight("bRatio2");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Change TreeBase")) {
              UI_set_to_Modify_TreeBase(0);
              UI_toolBar.highlight("tBase0");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Pick TreeBase")) {
              UI_set_to_Modify_TreeBase(1);
              UI_toolBar.highlight("tBase1");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Assign TreeBase")) {
              UI_set_to_Modify_TreeBase(2);
              UI_toolBar.highlight("tBase2");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Change TrunkSize")) {
              UI_set_to_Modify_TrunkSize(0);
              UI_toolBar.highlight("trSz0");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Pick TrunkSize")) {
              UI_set_to_Modify_TrunkSize(1);
              UI_toolBar.highlight("trSz1");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Assign TrunkSize")) {
              UI_set_to_Modify_TrunkSize(2);
              UI_toolBar.highlight("trSz2");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Change LeafSize")) {
              UI_set_to_Modify_LeafSize(0);
              UI_toolBar.highlight("lfSz0");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Pick LeafSize")) {
              UI_set_to_Modify_LeafSize(1);
              UI_toolBar.highlight("lfSz1");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Assign LeafSize")) {
              UI_set_to_Modify_LeafSize(2);
              UI_toolBar.highlight("lfSz2");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Model1DsProps")) {
              UI_set_to_Modify_Model1DsProps(0);
              UI_toolBar.highlight("allFP0");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Pick Model1DsProps")) {
              UI_set_to_Modify_Model1DsProps(1);
              UI_toolBar.highlight("allFP1");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Assign Model1DsProps")) {
              UI_set_to_Modify_Model1DsProps(2);
              UI_toolBar.highlight("allFP2");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Change DegreeMax")) {
              UI_set_to_Modify_DegreeMax(0);
            }
            if (menu_option.equals("Change BranchTilt")) {
              UI_set_to_Modify_BranchTilt(0);
            }
            if (menu_option.equals("Change BranchTwist")) {
              UI_set_to_Modify_BranchTwist(0);
            }
            if (menu_option.equals("Change BranchRatio")) {
              UI_set_to_Modify_BranchRatio(0);
            }
            if (menu_option.equals("Change TreeBase")) {
              UI_set_to_Modify_TreeBase(0);
            }
            if (menu_option.equals("Change TrunkSize")) {
              UI_set_to_Modify_TrunkSize(0);
            }
            if (menu_option.equals("Change LeafSize")) {
              UI_set_to_Modify_LeafSize(0);
            }


            if (menu_option.equals("Orthographic")) {
              UI_set_to_View_ProjectionType(0);
              UI_toolBar.highlight("P<>");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Perspective")) {
              UI_set_to_View_ProjectionType(1);
              UI_toolBar.highlight("P><");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Invert Selection")) {
              Select3D.invertSelection();
            }
            if (menu_option.equals("Deselect All")) {
              Select3D.deselectAll();
            }
            if (menu_option.equals("Select All")) {
              Select3D.selectAll();
            }
            if (menu_option.equals("Select All Cameras")) {
              SOLARCHVISION_switch_category(ObjectCategory.CAMERA);
              Select3D.selectAll();
            }
            if (menu_option.equals("Select All Sections")) {
              SOLARCHVISION_switch_category(ObjectCategory.SECTION);
              Select3D.selectAll();
            }
            if (menu_option.equals("Select All Solids")) {
              SOLARCHVISION_switch_category(ObjectCategory.SOLID);
              Select3D.selectAll();
            }
            if (menu_option.equals("Select All Faces")) {
              SOLARCHVISION_switch_category(ObjectCategory.FACE);
              Select3D.selectAll();
            }
            if (menu_option.equals("Select All Polylines")) {
              SOLARCHVISION_switch_category(ObjectCategory.POLYLINE);
              Select3D.selectAll();
            }
            if (menu_option.equals("Select All Verices")) {
              SOLARCHVISION_switch_category(ObjectCategory.VERTEX);
              Select3D.selectAll();
            }
            if (menu_option.equals("Select All Groups")) {
              SOLARCHVISION_switch_category(ObjectCategory.GROUP);
              Select3D.selectAll();
            }
            if (menu_option.equals("Select All Model1Ds")) {
              SOLARCHVISION_switch_category(ObjectCategory.MODEL1D);
              Select3D.selectAll();
            }
            if (menu_option.equals("Select All Model2Ds")) {
              SOLARCHVISION_switch_category(ObjectCategory.MODEL2D);
              Select3D.selectAll();
            }





            if (menu_option.equals("Select Solid")) {
              SOLARCHVISION_switch_category(ObjectCategory.SOLID);
            }
            if (menu_option.equals("Select Section")) {
              SOLARCHVISION_switch_category(ObjectCategory.SECTION);
            }
            if (menu_option.equals("Select Camera")) {
              SOLARCHVISION_switch_category(ObjectCategory.CAMERA);
            }
            if (menu_option.equals("Select LandPoint")) {
              SOLARCHVISION_switch_category(ObjectCategory.LANDPOINT);
            }
            if (menu_option.equals("Select Model1Ds")) {
              SOLARCHVISION_switch_category(ObjectCategory.MODEL1D);
            }
            if (menu_option.equals("Select Model2Ds")) {
              SOLARCHVISION_switch_category(ObjectCategory.MODEL2D);
            }
            if (menu_option.equals("Select Group")) {
              SOLARCHVISION_switch_category(ObjectCategory.GROUP);
            }
            if (menu_option.equals("Select Face")) {
              SOLARCHVISION_switch_category(ObjectCategory.FACE);
            }
            if (menu_option.equals("Select Polyline")) {
              SOLARCHVISION_switch_category(ObjectCategory.POLYLINE);
            }
            if (menu_option.equals("Select Vertex")) {
              SOLARCHVISION_switch_category(ObjectCategory.VERTEX);
            }
            if (menu_option.equals("Soft Selection")) {
              Select3D.convert_Vertex_to_softSelection();

              SOLARCHVISION_switch_category(ObjectCategory.SOFTVERTEX);
            }
            if (menu_option.equals("Vertices >> Groups")) {
              Select3D.convert_Vertices_to_Groups();
              SOLARCHVISION_switch_category(ObjectCategory.GROUP);
            }
            if (menu_option.equals("Faces >> Groups")) {
              Select3D.convert_Faces_to_Groups();
              SOLARCHVISION_switch_category(ObjectCategory.GROUP);
            }
            if (menu_option.equals("Groups >> Faces")) {
              Select3D.convert_Groups_to_Faces();
              SOLARCHVISION_switch_category(ObjectCategory.FACE);
            }
            if (menu_option.equals("Polylines >> Groups")) {
              Select3D.convert_Polylines_to_Groups();
              SOLARCHVISION_switch_category(ObjectCategory.GROUP);
            }
            if (menu_option.equals("Groups >> Polylines")) {
              Select3D.convert_Groups_to_Polylines();
              SOLARCHVISION_switch_category(ObjectCategory.POLYLINE);
            }
            if (menu_option.equals("Polylines >> Vertices")) {
              Select3D.convert_Polylines_to_Vertices();
              SOLARCHVISION_switch_category(ObjectCategory.VERTEX);
            }
            if (menu_option.equals("Vertices >> Polylines")) {
              Select3D.convert_Vertices_to_Polylines();
              SOLARCHVISION_switch_category(ObjectCategory.POLYLINE);
            }
            if (menu_option.equals("Groups >> Vertices")) {
              Select3D.convert_Groups_to_Vertices();
              SOLARCHVISION_switch_category(ObjectCategory.VERTEX);
            }
            if (menu_option.equals("Faces >> Vertices")) {
              Select3D.convert_Faces_to_Vertices();
              SOLARCHVISION_switch_category(ObjectCategory.VERTEX);
            }
            if (menu_option.equals("Vertices >> Faces")) {
              Select3D.convert_Vertices_to_Faces();
              SOLARCHVISION_switch_category(ObjectCategory.FACE);
            }
            if (menu_option.equals("Solids >> Groups")) {
              Select3D.convert_Solids_to_Groups();
              SOLARCHVISION_switch_category(ObjectCategory.GROUP);
            }
            if (menu_option.equals("Groups >> Solids")) {
              Select3D.convert_Groups_to_Solids();
              SOLARCHVISION_switch_category(ObjectCategory.SOLID);
            }
            if (menu_option.equals("Model2Ds >> Groups")) {
              Select3D.convert_Model2Ds_to_Groups();
              SOLARCHVISION_switch_category(ObjectCategory.GROUP);
            }
            if (menu_option.equals("Groups >> Model2Ds")) {
              Select3D.convert_Groups_to_Model2Ds();
              SOLARCHVISION_switch_category(ObjectCategory.MODEL2D);
            }
            if (menu_option.equals("Model1Ds >> Groups")) {
              Select3D.convert_Model1Ds_to_Groups();
              SOLARCHVISION_switch_category(ObjectCategory.GROUP);
            }
            if (menu_option.equals("Groups >> Model1Ds")) {
              Select3D.convert_Groups_to_Model1Ds();
              SOLARCHVISION_switch_category(ObjectCategory.MODEL1D);
            }

            if (menu_option.equals("Pick Select")) {
              UI_set_to_View_PickSelect(0);
              UI_toolBar.highlight("±PS");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Pick Select+")) {
              UI_set_to_View_PickSelect(1);
              UI_toolBar.highlight("+PS");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Pick Select-")) {
              UI_set_to_View_PickSelect(2);
              UI_toolBar.highlight("-PS");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Window Select")) {
              UI_set_to_View_WindowSelect(0);
              UI_toolBar.highlight("±WS");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Window Select+")) {
              UI_set_to_View_WindowSelect(1);
              UI_toolBar.highlight("+WS");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Window Select-")) {
              UI_set_to_View_WindowSelect(2);
              UI_toolBar.highlight("-WS");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Select Near Selected Vertices")) {
              Select3D.selectNearVertices();
            }

            if (menu_option.equals("Weld Objects Selected Vertices")) {
              Modify3D.weldObjectsVertices_Selection(User3D.modify_WeldTreshold);
            }
            if (menu_option.equals("Weld Scene Selected Vertices")) {
              Modify3D.weldSceneVertices_Selection(User3D.modify_WeldTreshold);
            }
            if (menu_option.equals("Reposition Selected Vertices")) {
              Modify3D.repositionVertices_Selection();
            }
            if (menu_option.equals("Separate Selected Vertices")) {
              Modify3D.separateVertices_Selection();
            }
            if (menu_option.equals("Select Scene Isolated Vertices")) {
              Select3D.isolatedVertices_Scene();
            }
            if (menu_option.equals("Delete Scene Isolated Vertices")) {
              Delete3D.isolatedVertices_Scene();
            }
            if (menu_option.equals("Delete Selection Isolated Vertices")) {
              Delete3D.isolatedVertices_Selection();
            }
            if (menu_option.equals("Delete Scene Empty Groups")) {
              allGroups.deleteEmptyGroups_Scene();
            }
            if (menu_option.equals("Delete Selection")) {
              Delete3D.selection();
            }
            if (menu_option.equals("Dettach from Groups Selection")) {
              allGroups.dettachFromGroups_Selection();
            }
            if (menu_option.equals("Ungroup Selection")) {
              allGroups.ungroup_Selection();
            }
            if (menu_option.equals("Group Selection")) {
              allGroups.group_Selection(1);
            }
            if (menu_option.equals("Attach to Last Group")) {
              allGroups.group_Selection(0);
            }
            if (menu_option.equals("Clone Selection (Identical)")) {
              Clone3D.selection(true);
            }
            if (menu_option.equals("Clone Selection (Variation)")) {
              Clone3D.selection(false);
            }
            if (menu_option.equals("Auto-Normal Selected Faces")) {
              Modify3D.autoNormalFaces_Selection();
            }
            if (menu_option.equals("Force Triangulate Selected Faces")) {
              Modify3D.forceTriangulateFaces_Selection();
            }

            if (menu_option.equals("Insert Corner Opennings")) {
              Modify3D.insertCornerOpennings_Selection();
            }
            if (menu_option.equals("Insert Parallel Opennings")) {
              Modify3D.insertParallelOpennings_Selection();
            }
            if (menu_option.equals("Insert Rotated Opennings")) {
              Modify3D.insertRotatedOpennings_Selection();
            }
            if (menu_option.equals("Insert Edge Opennings")) {
              Modify3D.insertEdgeOpennings_Selection();
            }

            if (menu_option.equals("Optimize Faces")) {
              Modify3D.optimizeFace_Selection();
            }

            if (menu_option.equals("Tessellate Rows & Columns")) {
              Modify3D.tessellateRowsColumns_Selection();
            }
            if (menu_option.equals("Tessellate Rectangular")) {
              Modify3D.tessellateRectangular_Selection();
            }
            if (menu_option.equals("Tessellate Triangular")) {
              Modify3D.tessellateTriangular_Selection();
            }
            if (menu_option.equals("Extrude Face Edges")) {
              Modify3D.extrudeFaceEdges_Selection();
            }
            if (menu_option.equals("Extrude Polyline Edges")) {
              Modify3D.extrudePolylineEdges_Selection();
            }
            if (menu_option.equals("Offset(above) Vertices")) {
              Modify3D.offsetVertices_Selection(0, abs(User3D.modify_OffsetAmount));
            }
            if (menu_option.equals("Offset(below) Vertices")) {
              Modify3D.offsetVertices_Selection(0, -abs(User3D.modify_OffsetAmount));
            }
            if (menu_option.equals("Offset(expand) Vertices")) {
              Modify3D.offsetVertices_Selection(1, -abs(User3D.modify_OffsetAmount));
            }
            if (menu_option.equals("Offset(shrink) Vertices")) {
              Modify3D.offsetVertices_Selection(1, abs(User3D.modify_OffsetAmount));
            }

            if (menu_option.equals("Reverse Visibility of All Faces")) {
              Modify3D.reverseVisibilityFaces_Scene();
            }
            if (menu_option.equals("Hide All Faces")) {
              Modify3D.changeVisibilityFaces_Scene(0);
            }
            if (menu_option.equals("Unhide All Faces")) {
              Modify3D.changeVisibilityFaces_Scene(1);
            }
            if (menu_option.equals("Hide Selected Faces")) {
              Modify3D.changeVisibilityFaces_Selection(0);
            }
            if (menu_option.equals("Unhide Selected Faces")) {
              Modify3D.changeVisibilityFaces_Selection(1);
            }
            if (menu_option.equals("Isolate Selection")) {
              Modify3D.isolate_Selection();
            }

            if (menu_option.equals("Flatten Selected LandPoints")) {
              Modify3D.flatten_LandPoints();
            }

            if (menu_option.equals("Add People on Land")) {
              Create3D.add_onLand(1); // 1 = people
            }

            if (menu_option.equals("Add 2D-Trees on Land")) {
              Create3D.add_onLand(2); // 2 = 2D trees
            }

            if (menu_option.equals("Add 3D-Trees on Land")) {
              Create3D.add_onLand(3); // 3 = 3D trees
            }

            if (menu_option.equals("Erase All Model1Ds")) {
              allModel1Ds.makeEmpty(0);
            }

            if (menu_option.equals("Erase All Model2Ds")) {
              allModel2Ds.makeEmpty(0);
            }

            if (menu_option.equals("Erase All Groups")) {
              allGroups.makeEmpty(0);
            }

            if (menu_option.equals("Erase All Solids")) {
              allSolids.makeEmpty(0);
            }

            if (menu_option.equals("Erase All Sections")) {
              allSections.makeEmpty(0);
            }

            if (menu_option.equals("Erase All Cameras")) {
              allCameras.makeEmpty(0);
            }

            if (menu_option.equals("Erase All Faces")) {
              allFaces.makeEmpty(0);
            }

            if (menu_option.equals("Erase All Polylines")) {
              allPolylines.makeEmpty(0);
            }

            if (menu_option.equals("Erase All")) {
              SOLARCHVISION_deleteAll();
            }


            if (menu_option.equals("TargetRoll")) {
              UI_set_to_View_TargetRoll(0);
              UI_toolBar.highlight("TRL");
              UI_toolBar.revise();
            }
            if (menu_option.equals("TargetRollZ")) {
              UI_set_to_View_TargetRoll(1);
              UI_toolBar.highlight("TRLz");
              UI_toolBar.revise();
            }
            if (menu_option.equals("TargetRollXY")) {
              UI_set_to_View_TargetRoll(2);
              UI_toolBar.highlight("TRLxy");
              UI_toolBar.revise();
            }
            if (menu_option.equals("CameraRoll")) {
              UI_set_to_View_CameraRoll(0);
              UI_toolBar.highlight("CRL");
              UI_toolBar.revise();
            }
            if (menu_option.equals("CameraRollZ")) {
              UI_set_to_View_CameraRoll(1);
              UI_toolBar.highlight("CRLz");
              UI_toolBar.revise();
            }
            if (menu_option.equals("CameraRollXY")) {
              UI_set_to_View_CameraRoll(2);
              UI_toolBar.highlight("CRLxy");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Orbit")) {
              UI_set_to_View_Orbit(0);
              UI_toolBar.highlight("OR");
              UI_toolBar.revise();
            }
            if (menu_option.equals("OrbitZ")) {
              UI_set_to_View_Orbit(1);
              UI_toolBar.highlight("ORz");
              UI_toolBar.revise();
            }
            if (menu_option.equals("OrbitXY")) {
              UI_set_to_View_Orbit(2);
              UI_toolBar.highlight("ORxy");
              UI_toolBar.revise();
            }

            if (menu_option.equals("LandOrbit")) {
              UI_set_to_View_LandOrbit(0);
              UI_toolBar.highlight("LNOR");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Pan")) {
              UI_set_to_View_Pan(0);
              UI_toolBar.highlight("Pan");
              UI_toolBar.revise();
            }
            if (menu_option.equals("PanX")) {
              UI_set_to_View_Pan(1);
              UI_toolBar.highlight("PanX");
              UI_toolBar.revise();
            }
            if (menu_option.equals("PanY")) {
              UI_set_to_View_Pan(2);
              UI_toolBar.highlight("PanY");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Zoom")) {
              UI_set_to_View_ZOOM(0);
              UI_toolBar.highlight("±ZM");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Zoom as default")) {
              UI_set_to_View_ZOOM(1);
              UI_toolBar.highlight("0ZM");
              UI_toolBar.revise();
            }


            if (menu_option.equals("TruckX")) {
              UI_set_to_View_Truck(1);
              UI_toolBar.highlight("DIx");
              UI_toolBar.revise();
            }
            if (menu_option.equals("TruckY")) {
              UI_set_to_View_Truck(2);
              UI_toolBar.highlight("DIy");
              UI_toolBar.revise();
            }
            if (menu_option.equals("TruckZ")) {
              UI_set_to_View_Truck(0);
              UI_toolBar.highlight("DIz");
              UI_toolBar.revise();
            }
            if (menu_option.equals("DistZ")) {
              UI_set_to_View_Truck(0);
              UI_toolBar.highlight("±CDZ");
              UI_toolBar.revise();
            }
            if (menu_option.equals("CameraDistance")) {
              UI_set_to_View_CameraDistance(0);
              UI_toolBar.highlight("±CDS");
              UI_toolBar.revise();
            }
            if (menu_option.equals("DistMouseXY")) {
              UI_set_to_View_DistMouseXY(0);
              UI_toolBar.highlight("±CDM");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Look at origin")) {
              UI_set_to_View_LookAtOrigin(0);
              UI_toolBar.highlight("LAO");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Look at direction")) {
              UI_set_to_View_LookAtDirection(0);
              UI_toolBar.highlight("LAD");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Look at selection")) {
              UI_set_to_View_LookAtSelection(0);
              UI_toolBar.highlight("LAS");
              UI_toolBar.revise();
            }


            if (menu_option.equals("3DModelSize")) {
              UI_set_to_View_3DModelSize();
              UI_toolBar.highlight("±SZ");
              UI_toolBar.revise();
            }

            if (menu_option.equals("SkydomeSize")) {
              UI_set_to_View_SkydomeSize();
              UI_toolBar.highlight("±SK");
              UI_toolBar.revise();
            }

            if (menu_option.equals("AllModelSize")) {
              UI_set_to_View_AllModelSize();
              UI_toolBar.highlight("±SA");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Display All Viewports")) {
              UI_set_to_Viewport(0);
              UI_toolBar.highlight("AllViewports");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Enlarge 3D Viewport")) {
              UI_set_to_Viewport(1);
              UI_toolBar.highlight("Expand3DView");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Enlarge Time Viewport")) {
              UI_set_to_Viewport(2);
              UI_toolBar.highlight("ExpandTimeView");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Enlarge Map Viewport")) {
              UI_set_to_Viewport(3);
              UI_toolBar.highlight("ExpandMapView");
              UI_toolBar.revise();
            }

            if (menu_option.equals("Top")) {
              UI_set_to_View_3DViewPoint(0);
              UI_toolBar.highlight("Top");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Front")) {
              UI_set_to_View_3DViewPoint(1);
              UI_toolBar.highlight("Front");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Left")) {
              UI_set_to_View_3DViewPoint(2);
              UI_toolBar.highlight("Left");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Back")) {
              UI_set_to_View_3DViewPoint(3);
              UI_toolBar.highlight("Back");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Right")) {
              UI_set_to_View_3DViewPoint(4);
              UI_toolBar.highlight("Right");
              UI_toolBar.revise();
            }
            if (menu_option.equals("Bottom")) {
              UI_set_to_View_3DViewPoint(5);
              UI_toolBar.highlight("Bottom");
              UI_toolBar.revise();
            }
            if (menu_option.equals("S.W.")) {
              UI_set_to_View_3DViewPoint(6);
              UI_toolBar.highlight("S.W.");
              UI_toolBar.revise();
            }
            if (menu_option.equals("S.E.")) {
              UI_set_to_View_3DViewPoint(7);
              UI_toolBar.highlight("S.E.");
              UI_toolBar.revise();
            }
            if (menu_option.equals("N.E.")) {
              UI_set_to_View_3DViewPoint(8);
              UI_toolBar.highlight("N.E.");
              UI_toolBar.revise();
            }
            if (menu_option.equals("N.W.")) {
              UI_set_to_View_3DViewPoint(9);
              UI_toolBar.highlight("N.W.");
              UI_toolBar.revise();
            }

            if (menu_option.equals("PivotX:Minimum")) {
              UI_set_to_View_PivotX(-1);
              UI_toolBar.highlight("X<");
              UI_toolBar.revise();
            }
            if (menu_option.equals("PivotX:Center")) {
              UI_set_to_View_PivotX(0);
              UI_toolBar.highlight("X|");
              UI_toolBar.revise();
            }
            if (menu_option.equals("PivotX:Maximum")) {
              UI_set_to_View_PivotX(1);
              UI_toolBar.highlight("X>");
              UI_toolBar.revise();
            }

            if (menu_option.equals("PivotY:Minimum")) {
              UI_set_to_View_PivotY(-1);
              UI_toolBar.highlight("Y<");
              UI_toolBar.revise();
            }
            if (menu_option.equals("PivotY:Center")) {
              UI_set_to_View_PivotY(0);
              UI_toolBar.highlight("Y|");
              UI_toolBar.revise();
            }
            if (menu_option.equals("PivotY:Maximum")) {
              UI_set_to_View_PivotY(1);
              UI_toolBar.highlight("Y>");
              UI_toolBar.revise();
            }

            if (menu_option.equals("PivotZ:Minimum")) {
              UI_set_to_View_PivotZ(-1);
              UI_toolBar.highlight("Z<");
              UI_toolBar.revise();
            }
            if (menu_option.equals("PivotZ:Center")) {
              UI_set_to_View_PivotZ(0);
              UI_toolBar.highlight("Z|");
              UI_toolBar.revise();
            }
            if (menu_option.equals("PivotZ:Maximum")) {
              UI_set_to_View_PivotZ(1);
              UI_toolBar.highlight("Z>");
              UI_toolBar.revise();
            }
          }
        }

        UI_menuBar.selected_parent = -1;
        UI_menuBar.selected_child = 0;

        image(pre_screen, 0, SOLARCHVISION_pixel_A);

        SOLARCHVISION_X_clicked = -1;
        SOLARCHVISION_Y_clicked = -1;
      } else if ((UI_menuBar.selected_parent != -1) && (isInside(mouseX, mouseY, 0, 0, width, SOLARCHVISION_pixel_A) == true)) {
        UI_menuBar.selected_parent = -1;
        UI_menuBar.selected_child = 0;

        image(pre_screen, 0, SOLARCHVISION_pixel_A);

        SOLARCHVISION_X_clicked = -1;
        SOLARCHVISION_Y_clicked = -1;
      } else {

        SOLARCHVISION_X_clicked = mouseX;
        SOLARCHVISION_Y_clicked = mouseY;

        if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, 0, 0, width, SOLARCHVISION_pixel_A)) {
          UI_menuBar.revise();
        }

        if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, 0, SOLARCHVISION_pixel_A, width, SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B)) {
          UI_toolBar.revise();
        }

        if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, 0, SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 2 * SOLARCHVISION_pixel_H, width, SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 2 * SOLARCHVISION_pixel_H + SOLARCHVISION_pixel_C)) {
          UI_caseBar.revise();
        }

        if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, 0, SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 2 * SOLARCHVISION_pixel_H + SOLARCHVISION_pixel_C, width, SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 2 * SOLARCHVISION_pixel_H + SOLARCHVISION_pixel_C + SOLARCHVISION_pixel_D)) {
          typeUserCommand = 1;
          UI_commandBar.revise();
        } else {
          typeUserCommand = 0;
          UI_commandBar.revise();
        }

        if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, ROLLOUT.cX, ROLLOUT.cY, ROLLOUT.cX + ROLLOUT.dX, ROLLOUT.cY + ROLLOUT.dY)) {
          ROLLOUT.revise();
        }

        if (WORLD.include) {
          if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, WORLD.cX, WORLD.cY, WORLD.cX + WORLD.dX, WORLD.cY + WORLD.dY)) {

            float mouse_lon = 360.0 * ((mouseX - WORLD.cX) * WORLD.sX / WORLD.dX - 0.5) + WORLD.oX;
            float mouse_lat = -180.0 * ((mouseY - WORLD.cY) * WORLD.sY / WORLD.dY - 0.5) + WORLD.oY;
            //float mouse_lon = STATION.getLongitude();
            //float mouse_lat = STATION.getLatitude();


            pre_LocationLAT = LocationLAT;
            pre_LocationLON = LocationLON;

            STATION.setLatitude(mouse_lat);
            STATION.setLongitude(mouse_lon);

            if (mouseButton == LEFT) {
              WORLD.Zoom = 6;
            }

            if ((pre_LocationLAT != LocationLAT) ||
                (pre_LocationLON != LocationLON)) {

              WORLD.VIEW_id = WORLD.FindGoodViewport(LocationLON, LocationLAT);
            }



            {
              int nearest_WORLD_NAEFS = -1;
              float nearest_WORLD_NAEFS_dist = FLOAT_undefined;

              for (int f = 0; f < NAEFS_Coordinates.length; f++) {

                float _lat = NAEFS_Coordinates[f].getLatitude();
                float _lon = NAEFS_Coordinates[f].getLongitude();
                if (_lon > 180) _lon -= 360; // << important!

                float d = funcs.lon_lat_dist(_lon, _lat, STATION.getLongitude(), STATION.getLatitude());

                if (nearest_WORLD_NAEFS_dist > d) {
                  nearest_WORLD_NAEFS_dist = d;
                  nearest_WORLD_NAEFS = f;
                }
              }

              {
                int f = nearest_WORLD_NAEFS;

                if (STATION.getFilename_NAEFS().equals(NAEFS_Coordinates[f].getFilename_NAEFS())) {
                } else {

                  STATION.setLatitude(mouse_lat);
                  STATION.setLongitude(mouse_lon);

                  STATION.setFilename_NAEFS(NAEFS_Coordinates[f].getFilename_NAEFS()); // naefs filename

                  println("nearest naefs filename:", NAEFS_Coordinates[f].getFilename_NAEFS());

                  if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
                    STATION.setCity(NAEFS_Coordinates[f].getCity());
                    STATION.setProvince(NAEFS_Coordinates[f].getProvince());
                    STATION.setCountry(NAEFS_Coordinates[f].getCountry());

                    //STATION.setLatitude(NAEFS_Coordinates[f].getLatitude());
                    //STATION.setLongitude(NAEFS_Coordinates[f].getLongitude());
                    STATION.setElevation(NAEFS_Coordinates[f].getElevation());
                    STATION.setTimelong(NAEFS_Coordinates[f].getTimelong());

                    ROLLOUT.parent = 0;
                    ROLLOUT.child = 1;
                    ROLLOUT.revise();


                    SOLARCHVISION_update_station(1);
                    update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);
                  }
                }
              }
            }


            {
              int nearest_WORLD_CWEEDS = -1;
              float nearest_WORLD_CWEEDS_dist = FLOAT_undefined;

              for (int f = 0; f < CWEEDS_coordinates.length; f++) {

                float _lat = CWEEDS_coordinates[f].getLatitude();
                float _lon = CWEEDS_coordinates[f].getLongitude();
                if (_lon > 180) _lon -= 360; // << important!

                float d = funcs.lon_lat_dist(_lon, _lat, STATION.getLongitude(), STATION.getLatitude());

                if (nearest_WORLD_CWEEDS_dist > d) {
                  nearest_WORLD_CWEEDS_dist = d;
                  nearest_WORLD_CWEEDS = f;
                }
              }

              {
                int f = nearest_WORLD_CWEEDS;

                if (STATION.getFilename_CWEEDS().equals(CWEEDS_coordinates[f].getFilename_CWEEDS())) {
                } else {

                  STATION.setLatitude(mouse_lat);
                  STATION.setLongitude(mouse_lon);

                  STATION.setFilename_CWEEDS(CWEEDS_coordinates[f].getFilename_CWEEDS()); // CWEEDS filename

                  println("nearest CWEEDS filename:", CWEEDS_coordinates[f].getFilename_CWEEDS());

                  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {

                    STATION.setCity(CWEEDS_coordinates[f].getCity());
                    STATION.setProvince(CWEEDS_coordinates[f].getProvince());
                    STATION.setCountry(CWEEDS_coordinates[f].getCountry());

                    //STATION.setLatitude(CWEEDS_coordinates[f].getLatitude());
                    //STATION.setLongitude(CWEEDS_coordinates[f].getLongitude());
                    STATION.setElevation(CWEEDS_coordinates[f].getElevation());
                    STATION.setTimelong(funcs.roundTo(STATION.getLongitude(), 15));

                    ROLLOUT.parent = 0;
                    ROLLOUT.child = 1;
                    ROLLOUT.revise();

                    SOLARCHVISION_update_station(1);
                    update_CLIMATE_CWEEDS();
                  }
                }
              }
            }

            {
              int nearest_WORLD_CLMREC = -1;
              float nearest_WORLD_CLMREC_dist = FLOAT_undefined;

              for (int f = 0; f < CLMREC_Coordinates.length; f++) {

                //if (int(CLMREC_Coordinates[f].getEndyear()) == 2016)
                { // only use stations with this condition

                  float _lat = CLMREC_Coordinates[f].getLatitude();
                  float _lon = CLMREC_Coordinates[f].getLongitude();
                  if (_lon > 180) _lon -= 360; // << important!

                  float d = funcs.lon_lat_dist(_lon, _lat, STATION.getLongitude(), STATION.getLatitude());

                  if (nearest_WORLD_CLMREC_dist > d) {
                    nearest_WORLD_CLMREC_dist = d;
                    nearest_WORLD_CLMREC = f;
                  }
                }
              }

              {
                int f = nearest_WORLD_CLMREC;

                if (STATION.getFilename_CWEEDS().equals(CLMREC_Coordinates[f].getFilename_CWEEDS())) {
                } else {

                  STATION.setLatitude(mouse_lat);
                  STATION.setLongitude(mouse_lon);

                  STATION.setFilename_CWEEDS(CLMREC_Coordinates[f].getFilename_CWEEDS()); // CLMREC filename

                  println("nearest CLMREC filename:", CLMREC_Coordinates[f].getFilename_CWEEDS());

                  if (CurrentDataSource == dataID_CLIMATE_CLMREC) {

                    STATION.setCity(CLMREC_Coordinates[f].getCity());
                    STATION.setProvince(CLMREC_Coordinates[f].getProvince());
                    STATION.setCountry(CLMREC_Coordinates[f].getCountry());

                    //STATION.setLatitude(CLMREC_Coordinates[f].getLatitude());
                    //STATION.setLongitude(CLMREC_Coordinates[f].getLongitude());
                    STATION.setElevation(CLMREC_Coordinates[f].getElevation());
                    STATION.setTimelong(CLMREC_Coordinates[f].getTimelong());

                    ROLLOUT.parent = 0;
                    ROLLOUT.child = 1;
                    ROLLOUT.revise();

                    SOLARCHVISION_update_station(1);
                    update_CLIMATE_CLMREC();
                  }
                }
              }
            }


            {
              int nearest_WORLD_TMYEPW = -1;
              float nearest_WORLD_TMYEPW_dist = FLOAT_undefined;

              for (int f = 0; f < TMYEPW_Coordinates.length; f++) {

                float _lat = TMYEPW_Coordinates[f].getLatitude();
                float _lon = TMYEPW_Coordinates[f].getLongitude();
                if (_lon > 180) _lon -= 360; // << important!

                float d = funcs.lon_lat_dist(_lon, _lat, STATION.getLongitude(), STATION.getLatitude());

                if (nearest_WORLD_TMYEPW_dist > d) {
                  nearest_WORLD_TMYEPW_dist = d;
                  nearest_WORLD_TMYEPW = f;
                }
              }

              {
                int f = nearest_WORLD_TMYEPW;

                if (STATION.getFilename_TMYEPW().equals(TMYEPW_Coordinates[f].getFilename_TMYEPW())) {
                } else {

                  STATION.setLatitude(mouse_lat);
                  STATION.setLongitude(mouse_lon);

                  STATION.setFilename_TMYEPW(TMYEPW_Coordinates[f].getFilename_TMYEPW()); // epw filename

                  println("nearest epw filename:", TMYEPW_Coordinates[f].getFilename_TMYEPW());

                  if (CurrentDataSource == dataID_CLIMATE_TMYEPW) {
                    STATION.setCity(TMYEPW_Coordinates[f].getCity());
                    STATION.setProvince(TMYEPW_Coordinates[f].getProvince());
                    STATION.setCountry(TMYEPW_Coordinates[f].getCountry());

                    //STATION.setLatitude(TMYEPW_Coordinates[f].getLatitude());
                    //STATION.setLongitude(TMYEPW_Coordinates[f].getLongitude());
                    STATION.setElevation(TMYEPW_Coordinates[f].getElevation());
                    STATION.setTimelong(TMYEPW_Coordinates[f].getTimelong());

                    ROLLOUT.parent = 0;
                    ROLLOUT.child = 1;
                    ROLLOUT.revise();

                    SOLARCHVISION_update_station(1);
                    update_CLIMATE_TMYEPW();
                  }
                }
              }
            }




            WORLD.revise();
            WIN3D.revise();
          }
        }

        if (WIN3D.include) {
          if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, WIN3D.cX, WIN3D.cY, WIN3D.cX + WIN3D.dX, WIN3D.cY + WIN3D.dY)) {

            float Image_X = 0;
            float Image_Y = 0;

            Image_X = SOLARCHVISION_X_clicked - (WIN3D.cX + 0.5 * WIN3D.dX);
            Image_Y = SOLARCHVISION_Y_clicked - (WIN3D.cY + 0.5 * WIN3D.dY);

            if (WIN3D.UI_CurrentTask == UITASK.LookAtDirection) { // viewport:LookAtDirection

              WIN3D.look_3DViewport_towards_Direction(Image_X, Image_Y);

              SOLARCHVISION_view_changed();
            }
            else {

              float[] ray_direction = new float [3];

              float[] ray_start = {
                WIN3D.CAM_x, WIN3D.CAM_y, WIN3D.CAM_z
              };

              float[] ray_end = WIN3D.calculate_Click3D(Image_X, Image_Y);

              ray_start[0] /= OBJECTS_scale;
              ray_start[1] /= OBJECTS_scale;
              ray_start[2] /= OBJECTS_scale;

              ray_end[0] /= OBJECTS_scale;
              ray_end[1] /= OBJECTS_scale;
              ray_end[2] /= OBJECTS_scale;

              if (WIN3D.ViewType == 0) {
                float[] ray_center = WIN3D.calculate_Click3D(0, 0);

                ray_center[0] /= OBJECTS_scale;
                ray_center[1] /= OBJECTS_scale;
                ray_center[2] /= OBJECTS_scale;

                ray_start[0] += ray_end[0] - ray_center[0];
                ray_start[1] += ray_end[1] - ray_center[1];
                ray_start[2] += ray_end[2] - ray_center[2];
              }

              ray_direction[0] = ray_end[0] - ray_start[0];
              ray_direction[1] = ray_end[1] - ray_start[1];
              ray_direction[2] = ray_end[2] - ray_start[2];

              float[] RxP = new float [8];

              if (mouseButton == RIGHT) {
                RxP = Land3D.intersect(ray_start, ray_direction);
              } else if (mouseButton == LEFT) {

                if ((WIN3D.UI_CurrentTask == UITASK.Create) ||
                    (WIN3D.UI_CurrentTask == UITASK.Move)) {

                   RxP = SOLARCHVISION_snap_Faces(allFaces.intersect(ray_start, ray_direction));

                } else {

                  if (current_ObjectCategory == ObjectCategory.POLYLINE) {
                    RxP = allPolylines.intersect(ray_start, ray_direction);
                  } else if (current_ObjectCategory == ObjectCategory.CAMERA) {
                    RxP = allCameras.intersect(ray_start, ray_direction);
                  } else if (current_ObjectCategory == ObjectCategory.SECTION) {
                    RxP = allSections.intersect(ray_start, ray_direction);
                  } else if (current_ObjectCategory == ObjectCategory.SOLID) {
                    RxP = allSolids.intersect(ray_start, ray_direction);
                  } else if (current_ObjectCategory == ObjectCategory.MODEL1D) {
                    RxP = allModel1Ds.intersect(ray_start, ray_direction);
                  } else if (current_ObjectCategory == ObjectCategory.MODEL2D) {
                    RxP = allModel2Ds.intersect(ray_start, ray_direction);
                  } else {
                    RxP = SOLARCHVISION_snap_Faces(allFaces.intersect(ray_start, ray_direction));
                  }
                }



              }


              //println(ray_start[0], ray_start[1], ray_start[2], ">>", ray_end[0], ray_end[1], ray_end[2], ">>", RxP[1], RxP[2], RxP[3], RxP[4], RxP[0]);

              if (RxP[0] >= 0) {

                if (WIN3D.UI_CurrentTask == UITASK.Move) { // move

                  float x1 = FLOAT_undefined;
                  float y1 = FLOAT_undefined;
                  float z1 = FLOAT_undefined;

                  if (current_ObjectCategory == ObjectCategory.GROUP) {

                    float[] P = Select3D.getPivot();

                    x1 = P[0];
                    y1 = P[1];
                    z1 = P[2];
                  }

                  if (current_ObjectCategory == ObjectCategory.MODEL2D) {

                    x1 = allModel2Ds.getX(Select3D.Model2D_ids[Select3D.Model2D_ids.length - 1]);
                    y1 = allModel2Ds.getY(Select3D.Model2D_ids[Select3D.Model2D_ids.length - 1]);
                    z1 = allModel2Ds.getZ(Select3D.Model2D_ids[Select3D.Model2D_ids.length - 1]);
                  }

                  if (current_ObjectCategory == ObjectCategory.MODEL1D) {

                    x1 = allModel1Ds.getX(Select3D.Model1D_ids[Select3D.Model1D_ids.length - 1]);
                    y1 = allModel1Ds.getY(Select3D.Model1D_ids[Select3D.Model1D_ids.length - 1]);
                    z1 = allModel1Ds.getZ(Select3D.Model1D_ids[Select3D.Model1D_ids.length - 1]);
                  }

                  if (current_ObjectCategory == ObjectCategory.SOLID) {

                    x1 = allSolids.get_posX(Select3D.Solid_ids[Select3D.Solid_ids.length - 1]);
                    y1 = allSolids.get_posY(Select3D.Solid_ids[Select3D.Solid_ids.length - 1]);
                    z1 = allSolids.get_posZ(Select3D.Solid_ids[Select3D.Solid_ids.length - 1]);
                  }

                  if (current_ObjectCategory == ObjectCategory.VERTEX) {

                    x1 = allPoints.getX(Select3D.Vertex_ids[Select3D.Vertex_ids.length - 1]);
                    y1 = allPoints.getY(Select3D.Vertex_ids[Select3D.Vertex_ids.length - 1]);
                    z1 = allPoints.getZ(Select3D.Vertex_ids[Select3D.Vertex_ids.length - 1]);
                  }

                  if ((is_defined(x1)) &&
                      (is_defined(y1)) &&
                      (is_defined(z1))) {

                    float x2 = RxP[1];
                    float y2 = RxP[2];
                    float z2 = RxP[3];

                    float dx, dy, dz;

                    /*
                    float[] p = Select3D.translateOutside_ReferencePivot(x2, y2, z2);
                    dx = p[0] - x1;
                    dy = p[1] - y1;
                    dz = p[2] - z1;
                    */
                    dx = x2 - x1;
                    dy = y2 - y1;
                    dz = z2 - z1;



                    int the_Vector = Select3D.posVector;

                    if (the_Vector == 0) {
                      dy = 0;
                      dz = 0;
                    }
                    if (the_Vector == 1) {
                      dz = 0;
                      dx = 0;
                    }
                    if (the_Vector == 2) {
                      dx = 0;
                      dy = 0;
                    }

                    Move3D.selection(dx, dy, dz);

                    SOLARCHVISION_model_changed();
                  }
                }




                if (mouseButton == LEFT) { // modify should work only with left click because the right click returns the land info, not objects info

                  if ((WIN3D.UI_TaskModifyParameter != 0) && (WIN3D.UI_CurrentTask >= UITASK.Seed_Material)) { // Pick/Assign properties

                    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
                        (current_ObjectCategory == ObjectCategory.FACE) || (current_ObjectCategory == ObjectCategory.POLYLINE)) {

                      int f = int(RxP[0]);

                      if ((WIN3D.UI_CurrentTask == UITASK.Seed_Material) ||
                          (WIN3D.UI_CurrentTask == UITASK.Tessellation) ||
                          (WIN3D.UI_CurrentTask == UITASK.Layer) ||
                          (WIN3D.UI_CurrentTask == UITASK.Visibility) ||
                          (WIN3D.UI_CurrentTask == UITASK.Weight)) {

                        if (WIN3D.UI_TaskModifyParameter == 1) { // Pick
                          if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) User3D.default_Material     = allFaces.getMaterial(f);
                          if (WIN3D.UI_CurrentTask == UITASK.Tessellation)  User3D.default_Tessellation = allFaces.getTessellation(f);
                          if (WIN3D.UI_CurrentTask == UITASK.Layer)         User3D.default_Layer        = allFaces.getLayer(f);
                          if (WIN3D.UI_CurrentTask == UITASK.Visibility)    User3D.default_Visibility   = allFaces.getVisibility(f);
                          if (WIN3D.UI_CurrentTask == UITASK.Weight)        User3D.default_Weight       = allFaces.getWeight(f);
                        }
                        if (WIN3D.UI_TaskModifyParameter == 2) { // Assign(sub)
                          if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) allFaces.setMaterial    (f, User3D.default_Material);
                          if (WIN3D.UI_CurrentTask == UITASK.Tessellation)  allFaces.setTessellation(f, User3D.default_Tessellation);
                          if (WIN3D.UI_CurrentTask == UITASK.Layer)         allFaces.setLayer       (f, User3D.default_Layer);
                          if (WIN3D.UI_CurrentTask == UITASK.Visibility)    allFaces.setVisibility  (f, User3D.default_Visibility);
                          if (WIN3D.UI_CurrentTask == UITASK.Weight)        allFaces.setWeight      (f, User3D.default_Weight);
                        }
                        if (WIN3D.UI_TaskModifyParameter == 3) { // Assign(all)
                          int OBJ_ID = 0;
                          for (int i = 0; i < allGroups.num; i++) {
                            if ((allGroups.Faces[i][0] <= f) && (f <= allGroups.Faces[i][1])) {
                              OBJ_ID = i;
                              break;
                            }
                          }

                          for (int q = allGroups.getStart_Face(OBJ_ID); q <= allGroups.getStop_Face(OBJ_ID); q++) {
                            if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) allFaces.setMaterial    (q, User3D.default_Material);
                            if (WIN3D.UI_CurrentTask == UITASK.Tessellation)  allFaces.setTessellation(q, User3D.default_Tessellation);
                            if (WIN3D.UI_CurrentTask == UITASK.Layer)         allFaces.setLayer       (q, User3D.default_Layer);
                            if (WIN3D.UI_CurrentTask == UITASK.Visibility)    allFaces.setVisibility  (q, User3D.default_Visibility);
                            if (WIN3D.UI_CurrentTask == UITASK.Weight)        allFaces.setClose       (q, User3D.default_Weight);
                          }
                        }
                      }

                      if (WIN3D.UI_CurrentTask == UITASK.Pivot) {
                        if (WIN3D.UI_TaskModifyParameter == 1) { // Pick
                          //?????????????????????????????????????????????????
                        }
                        if (WIN3D.UI_TaskModifyParameter == 2) { // Assign
                          int OBJ_ID = 0;
                          for (int i = 0; i < allGroups.num; i++) {
                            if ((allGroups.Faces[i][0] <= f) && (f <= allGroups.Faces[i][1])) {
                              OBJ_ID = i;
                              break;
                            }
                          }


                          float[] P = Select3D.getPivot();

                          allGroups.Pivots[OBJ_ID][0] = P[0];
                          allGroups.Pivots[OBJ_ID][1] = P[1];
                          allGroups.Pivots[OBJ_ID][2] = P[2];

                          //zzzzzzzzzzzzzzzzzzz should add other components?

                        }
                      }

                      if (WIN3D.UI_CurrentTask == UITASK.Normal) { //Normal

                        if (current_ObjectCategory == ObjectCategory.FACE) {

                          Select3D.Face_ids = new int [1];
                          Select3D.Face_ids[0] = f;

                          Select3D.Face_displayVertexCount = true;

                          int n = allFaces.nodes[f].length;

                          if (n > 2) {
                            int[] tmpFace = new int[n];
                            float[] G = {
                              0, 0, 0
                            };
                            for (int j = 0; j < n; j++) {
                              tmpFace[j] = allFaces.nodes[f][j];
                              G[0] += allPoints.getX(tmpFace[j]) / float(n);
                              G[1] += allPoints.getY(tmpFace[j]) / float(n);
                              G[2] += allPoints.getZ(tmpFace[j]) / float(n);
                            }

                            int flip_face = 0;
                            if (WIN3D.UI_TaskModifyParameter == 1) flip_face = 1;
                            else {
                              PVector AG = new PVector(allPoints.getX(tmpFace[0]) - G[0], allPoints.getY(tmpFace[0]) - G[1], allPoints.getZ(tmpFace[0]) - G[2]);
                              PVector BG = new PVector(allPoints.getX(tmpFace[1]) - G[0], allPoints.getY(tmpFace[1]) - G[1], allPoints.getZ(tmpFace[1]) - G[2]);

                              PVector GAxGB = AG.cross(BG);

                              float[] P = Select3D.getPivot();

                              float x0 = P[0];
                              float y0 = P[1];
                              float z0 = P[2];

                              PVector PG = new PVector(x0 - G[0], y0 - G[1], z0 - G[2]);

                              float V = PG.dot(GAxGB);

                              if (WIN3D.UI_TaskModifyParameter == 2) {
                                if (V > 0) flip_face = 1;
                              }
                              if (WIN3D.UI_TaskModifyParameter == 3) {
                                if (V < 0) flip_face = 1;
                              }
                            }

                            if (flip_face == 1) {
                              for (int j = 0; j < n; j++) {
                                allFaces.nodes[f][j] = tmpFace[n - j - 1];
                              }
                            }
                          }
                        }

                        if (current_ObjectCategory == ObjectCategory.GROUP) {
                          int OBJ_ID = 0;
                          for (int i = 0; i < allGroups.num; i++) {
                            if ((allGroups.Faces[i][0] <= f) && (f <= allGroups.Faces[i][1])) {
                              OBJ_ID = i;
                              break;
                            }
                          }

                          for (int q = allGroups.getStart_Face(OBJ_ID); q <= allGroups.getStop_Face(OBJ_ID); q++) {
                            int n = allFaces.nodes[q].length;

                            if (n > 2) {
                              int[] tmpFace = new int[n];
                              float[] G = {
                                0, 0, 0
                              };
                              for (int j = 0; j < n; j++) {
                                tmpFace[j] = allFaces.nodes[q][j];
                                G[0] += allPoints.getX(tmpFace[j]) / float(n);
                                G[1] += allPoints.getY(tmpFace[j]) / float(n);
                                G[2] += allPoints.getZ(tmpFace[j]) / float(n);
                              }

                              int flip_face = 0;
                              if (WIN3D.UI_TaskModifyParameter == 1) flip_face = 1;
                              else {
                                PVector AG = new PVector(allPoints.getX(tmpFace[0]) - G[0], allPoints.getY(tmpFace[0]) - G[1], allPoints.getZ(tmpFace[0]) - G[2]);
                                PVector BG = new PVector(allPoints.getX(tmpFace[1]) - G[0], allPoints.getY(tmpFace[1]) - G[1], allPoints.getZ(tmpFace[1]) - G[2]);

                                PVector GAxGB = AG.cross(BG);

                                float[] P = Select3D.getPivot();

                                float x0 = P[0];
                                float y0 = P[1];
                                float z0 = P[2];

                                PVector PG = new PVector(x0 - G[0], y0 - G[1], z0 - G[2]);

                                float V = PG.dot(GAxGB);

                                if (WIN3D.UI_TaskModifyParameter == 2) {
                                  if (V > 0) flip_face = 1;
                                }
                                if (WIN3D.UI_TaskModifyParameter == 3) {
                                  if (V < 0) flip_face = 1;
                                }
                              }

                              if (flip_face == 1) {
                                for (int j = 0; j < n; j++) {
                                  allFaces.nodes[q][j] = tmpFace[n - j - 1];
                                }
                              }
                            }
                          }

                        }
                      }


                      if (WIN3D.UI_CurrentTask == UITASK.FirstVertex) { //FirstVertex

                        if (current_ObjectCategory == ObjectCategory.FACE) {

                          Select3D.Face_ids = new int [1];
                          Select3D.Face_ids[0] = f;

                          Select3D.Face_displayVertexCount = true;

                          int n = allFaces.nodes[f].length;

                          if (n > 2) {

                            int min_num = 0;
                            float min_dist = FLOAT_undefined;

                            for (int j = 0; j < n; j++) {
                              int vNo = allFaces.nodes[f][j];

                              float d = dist(RxP[1], RxP[2], RxP[3], allPoints.getX(vNo), allPoints.getY(vNo), allPoints.getZ(vNo));

                              if (min_dist > d) {
                                min_dist = d;
                                min_num = j;
                              }
                            }

                            int[] tmpFace = new int[n];
                            for (int j = 0; j < n; j++) {
                              tmpFace[j] = allFaces.nodes[f][j];
                            }

                            for (int j = 0; j < n; j++) {
                              allFaces.nodes[f][j] = tmpFace[(j + min_num + n) % n];
                            }
                          }
                        }


                        if (current_ObjectCategory == ObjectCategory.POLYLINE) {

                          Select3D.Polyline_ids = new int [1];
                          Select3D.Polyline_ids[0] = f;

                          Select3D.Polyline_displayVertexCount = true;

                          int n = allPolylines.nodes[f].length;

                          if (n > 2) {

                            int min_num = 0;
                            float min_dist = FLOAT_undefined;

                            for (int j = 0; j < n; j++) {
                              int vNo = allPolylines.nodes[f][j];

                              float d = dist(RxP[1], RxP[2], RxP[3], allPoints.getX(vNo), allPoints.getY(vNo), allPoints.getZ(vNo));

                              if (min_dist > d) {
                                min_dist = d;
                                min_num = j;
                              }
                            }

                            int[] tmpPolyline = new int[n];
                            for (int j = 0; j < n; j++) {
                              tmpPolyline[j] = allPolylines.nodes[f][j];
                            }

                            for (int j = 0; j < n; j++) {
                              allPolylines.nodes[f][j] = tmpPolyline[(j + min_num + n) % n];
                            }
                          }
                        }

                      }
                    }










                    if (current_ObjectCategory == ObjectCategory.MODEL2D) {

                      int OBJ_ID = int(RxP[0]);

                      int n = allModel2Ds.MAP[OBJ_ID];
                      int sign_n = 1;
                      if (n < 0) sign_n = -1;
                      n = abs(n);
                      int n1 = allModel2Ds.num_files_PEOPLE;
                      int n2 = allModel2Ds.num_files_PEOPLE + allModel2Ds.num_files_TREES;

                      if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) {

                        if (WIN3D.UI_TaskModifyParameter == 1) { // Pick
                          if (allModel2Ds.isTree(n)) { // case: trees
                            User3D.create_Plant_Type = n - n1;
                          }
                          else { // case: people
                            User3D.create_Person_Type = n;
                          }
                        }
                        if ((WIN3D.UI_TaskModifyParameter == 2) || (WIN3D.UI_TaskModifyParameter == 3)) { // Assign
                          if (allModel2Ds.isTree(n)) { // case: trees
                            allModel2Ds.MAP[OBJ_ID] = sign_n * (User3D.create_Plant_Type + n1);
                          }
                          else { // case: people
                            allModel2Ds.MAP[OBJ_ID] = sign_n * User3D.create_Person_Type;
                          }
                        }
                      }
                    }


                    if (current_ObjectCategory == ObjectCategory.MODEL1D) {

                      int OBJ_ID = int(RxP[0]);

                      if (WIN3D.UI_TaskModifyParameter == 1) { // Pick
                        if (WIN3D.UI_CurrentTask == UITASK.DegreeMax) User3D.create_Model1D_DegreeMax = allModel1Ds.getDegreeMax(OBJ_ID);
                        if (WIN3D.UI_CurrentTask == UITASK.BranchTilt) User3D.create_Model1D_BranchTilt = allModel1Ds.getBranchTilt(OBJ_ID);
                        if (WIN3D.UI_CurrentTask == UITASK.BranchTwist) User3D.create_Model1D_BranchTwist = allModel1Ds.getBranchTwist(OBJ_ID);
                        if (WIN3D.UI_CurrentTask == UITASK.BranchRatio) User3D.create_Model1D_BranchRatio = allModel1Ds.getBranchRatio(OBJ_ID);
                        if (WIN3D.UI_CurrentTask == UITASK.TreeBase) User3D.create_Model1D_TreeBase = allModel1Ds.getTreeBase(OBJ_ID);

                        if (WIN3D.UI_CurrentTask == UITASK.TrunkSize) User3D.create_Model1D_TrunkSize = allModel1Ds.getTrunkSize(OBJ_ID);
                        if (WIN3D.UI_CurrentTask == UITASK.LeafSize) User3D.create_Model1D_LeafSize = allModel1Ds.getLeafSize(OBJ_ID);
                        if (WIN3D.UI_CurrentTask == UITASK.Model1DsProps) { // all properties
                          User3D.create_Model1D_DegreeMax = allModel1Ds.getDegreeMax(OBJ_ID);
                          User3D.create_Model1D_TrunkSize = allModel1Ds.getTrunkSize(OBJ_ID);
                          User3D.create_Model1D_LeafSize = allModel1Ds.getLeafSize(OBJ_ID);
                        }
                      }
                      if (WIN3D.UI_TaskModifyParameter == 2) { // Assign
                        if (WIN3D.UI_CurrentTask == UITASK.DegreeMax) allModel1Ds.setDegreeMax(OBJ_ID, User3D.create_Model1D_DegreeMax);
                        if (WIN3D.UI_CurrentTask == UITASK.BranchTilt) allModel1Ds.setBranchTilt(OBJ_ID, User3D.create_Model1D_BranchTilt);
                        if (WIN3D.UI_CurrentTask == UITASK.BranchTwist) allModel1Ds.setBranchTwist(OBJ_ID, User3D.create_Model1D_BranchTwist);
                        if (WIN3D.UI_CurrentTask == UITASK.BranchRatio) allModel1Ds.setBranchRatio(OBJ_ID, User3D.create_Model1D_BranchRatio);
                        if (WIN3D.UI_CurrentTask == UITASK.TreeBase) allModel1Ds.setTreeBase(OBJ_ID, User3D.create_Model1D_TreeBase);

                        if (WIN3D.UI_CurrentTask == UITASK.TrunkSize) allModel1Ds.setTrunkSize(OBJ_ID, User3D.create_Model1D_TrunkSize);
                        if (WIN3D.UI_CurrentTask == UITASK.LeafSize) allModel1Ds.setLeafSize(OBJ_ID, User3D.create_Model1D_LeafSize);
                        if (WIN3D.UI_CurrentTask == UITASK.Model1DsProps) { // all properties
                          allModel1Ds.setDegreeMax(OBJ_ID, User3D.create_Model1D_DegreeMax);
                          allModel1Ds.setTrunkSize(OBJ_ID, User3D.create_Model1D_TrunkSize);
                          allModel1Ds.setLeafSize(OBJ_ID, User3D.create_Model1D_LeafSize);
                        }
                      }
                    }

                    SOLARCHVISION_model_changed();

                  } else if ((WIN3D.UI_CurrentTask != UITASK.Create) && (WIN3D.UI_CurrentTask != UITASK.Move)) { // PickSelect also if scale, rotate, modify, etc. where selected

                    Select3D.selectPick(RxP);
                  }
                }

                if (WIN3D.UI_CurrentTask == UITASK.Create) { // create

                  int keep_number_of_allGroups = allGroups.num;
                  int keep_number_of_allModel2Ds = allModel2Ds.num;
                  int keep_number_of_allModel1Ds = allModel1Ds.num;
                  int keep_number_of_allSolids = allSolids.DEF.length;
                  int keep_number_of_allSections = allSections.num;
                  int keep_number_of_allCameras = allCameras.num;

                  float x = RxP[1];
                  float y = RxP[2];
                  float z = RxP[3];

                  float rot = User3D.create_Orientation;
                  if (rot == 360) rot = WIN3D.rotation_Z;



                  float rx = 0.5 * User3D.create_Length;
                  if (rx < 0) rx = random(0.25 * abs(rx), abs(rx));

                  float ry = 0.5 * User3D.create_Width;
                  if (ry < 0) ry = random(0.25 * abs(ry), abs(ry));

                  float rz = 0.5 * User3D.create_Height;
                  if (rz < 0) rz = random(0.25 * abs(rz), abs(rz));



                  float px = User3D.create_powX;
                  float py = User3D.create_powY;
                  float pz = User3D.create_powZ;

                  if (User3D.create_powRnd == 1) {
                    px = pow(2, int(random(5)) - 1);
                    py = px;
                    pz = px;
                  }

                  if (User3D.create_Volume != 0) {

                    if ((rx != 0) && (ry != 0)) {
                      rz = User3D.create_Volume / (8 * rx * ry);
                    }

                    //---------------------------------------------------
                    float A = 1;
                    // cube volume: 8*r^3, sphere volume: 4*r^3, so maybe:
                    if (pz >= 8) A = 1;
                    else if (pz == 4) A = 0.75;
                    else if (pz == 2) A = 0.5;
                    else if (pz == 1) A = 0.25;
                    else if (pz == 0.5) A = 0.125;
                    else if (pz == 0.25) A = 0.0625;

                    rx /= pow(A, (1.0 / 3.0));
                    ry /= pow(A, (1.0 / 3.0));
                    rz /= pow(A, (1.0 / 3.0));
                    //---------------------------------------------------
                  }


                  if ((current_ObjectCategory != ObjectCategory.MODEL1D) &&
                      (current_ObjectCategory != ObjectCategory.MODEL2D) &&
                      (current_ObjectCategory != ObjectCategory.LANDPOINT) &&
                      (current_ObjectCategory != ObjectCategory.CAMERA) &&
                      (current_ObjectCategory != ObjectCategory.SECTION)) {

                    x -= rx * Select3D.alignX;
                    y -= ry * Select3D.alignY;
                    z -= rz * Select3D.alignZ;
                  }



                  //if ((current_ObjectCategory == ObjectCategory.GROUP) || (current_ObjectCategory == ObjectCategory.SOLID) || (current_ObjectCategory == ObjectCategory.MODEL1D) || (current_ObjectCategory == ObjectCategory.MODEL2D)) {
                  if (current_ObjectCategory == ObjectCategory.GROUP) {

                    if (addToLastGroup == false) {

                      allGroups.beginNewGroup(x, y, z, 1, 1, 1, 0, 0, rot);
                    }
                  }


                  if (current_ObjectCategory == ObjectCategory.GROUP) { // working with meshes

                    if (CreateObject == CREATE.SuperOBJ) {

                      if ((px == CubePower) && (py == CubePower) && (pz == 2)) {

                        Create3D.add_ParametricSurface(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, ry, rz, 2, rot);
                      } else if ((px == 2) && (py == 2) && (pz == CubePower)) {

                        Create3D.add_SuperCylinder(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, ry, rz, User3D.create_CylinderDegree, rot);
                      } else if ((px == CubePower) && (py == CubePower) && (pz == CubePower)) {

                        Create3D.add_Box_Core(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, ry, rz, rot);
                      } else if ((px == 1) && (py == 1) && (pz == 1)) {

                        Create3D.add_Octahedron(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, ry, rz, rot);
                      } else {

                        Create3D.add_SuperSphere(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, pz, py, pz, rx, ry, rz, User3D.create_SphereDegree, rot);
                      }




                      if (User3D.create_MeshOrSolid != 0) {

                        allSolids.create(x, y, z, px, py, pz, rx, ry, rz, 0, 0, rot, 1);
                      }
                    }



                    if (CreateObject == CREATE.Tri) {

                      Create3D.add_Mesh3(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x-rx, y-ry, z-rz, x+rx, y-ry, z-rz, x, y, z+rz);
                      Create3D.add_Mesh3(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x+rx, y-ry, z-rz, x+rx, y+ry, z-rz, x, y, z+rz);
                      Create3D.add_Mesh3(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x+rx, y+ry, z-rz, x-rx, y+ry, z-rz, x, y, z+rz);
                      Create3D.add_Mesh3(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x-rx, y+ry, z-rz, x-rx, y-ry, z-rz, x, y, z+rz);
                    }


                    if (CreateObject == CREATE.Plane) {

                      Create3D.add_Mesh4(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x-rx, y-ry, z, x+rx, y-ry, z, x+rx, y+ry, z, x-rx, y+ry, z);
                    }

                    if (CreateObject == CREATE.Polygon) {

                      Create3D.add_PolygonMesh(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, User3D.create_PolyDegree, rot);
                    }

                    if (CreateObject == CREATE.Hyper) {

                      Create3D.add_PolygonHyper(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, 2 * rz, User3D.create_PolyDegree, rot);
                    }


                    if (CreateObject == CREATE.Extrude) {

                      Create3D.add_PolygonExtrude(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, 2 * rz, User3D.create_PolyDegree, rot);
                    }

                    if (CreateObject == CREATE.House3) {

                      float h = ry;

                      Create3D.add_House3_Core(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, ry, rz, h, rot);
                    }

                    if (CreateObject == CREATE.House2) {

                      float h = ry;

                      Create3D.add_House2_Core(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, ry, rz, h, rot);
                    }

                    if (CreateObject == CREATE.House1) {

                      float h = ry;

                      if (ry > rx) h = rx;

                      Create3D.add_House1_Core(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, ry, rz, h, rot);
                    }

                    if (CreateObject == CREATE.Parametric) {

                      Create3D.add_ParametricSurface(User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, x, y, z, rx, ry, rz, User3D.create_Parametric_Type, rot);
                    }

                  }

                  if (current_ObjectCategory == ObjectCategory.MODEL2D) { // working with model2Ds
                    if (CreateObject == CREATE.Person) {

                      randomSeed(millis());
                      allModel2Ds.create("PEOPLE", User3D.create_Person_Type, x, y, z, 2.5);
                    }

                    if (CreateObject == CREATE.Plant) {
                      int n = 0;
                      if (User3D.create_Plant_Type > 0) n = User3D.create_Plant_Type + allModel2Ds.num_files_PEOPLE;

                      randomSeed(millis());
                      allModel2Ds.create("TREES", n, x, y, z, 2 * rz);
                    }
                  }

                  if (current_ObjectCategory == ObjectCategory.MODEL1D) { // working with model1Ds
                    if (CreateObject == CREATE.Model1Ds) {

                      randomSeed(millis());
                      allModel1Ds.create(User3D.create_Model1D_Type, User3D.create_Model1D_Seed,
                                         User3D.create_Model1D_DegreeMax,
                                         x, y, z, 2 * rz, floor(random(360)),
                                         User3D.create_Model1D_BranchTilt, User3D.create_Model1D_BranchTwist,
                                         User3D.create_Model1D_BranchRatio, User3D.create_Model1D_TreeBase,
                                         User3D.create_Model1D_TrunkSize, User3D.create_Model1D_LeafSize);
                    }
                  }

                  if (current_ObjectCategory == ObjectCategory.VERTEX) { // working with vertices
                    if (CreateObject == CREATE.Vertex) {
                      allPoints.create(x, y, z);

                    }
                  }


                  if (current_ObjectCategory == ObjectCategory.FACE) { // working with faces
                    if (CreateObject == CREATE.Face) {
                      allFaces.add_VertexToLastFace(x, y, z);

                      Select3D.Face_ids = new int [1];
                      Select3D.Face_ids[0] = allFaces.nodes.length - 1;

                      Select3D.calculate_BoundingBox();
                    }
                  }

                  if (current_ObjectCategory == ObjectCategory.POLYLINE) { // working with polylines
                    if (CreateObject == CREATE.Polyline) {
                      allPolylines.add_VertexToLastPolyline(x, y, z);

                      Select3D.Polyline_ids = new int [1];
                      Select3D.Polyline_ids[0] = allPolylines.nodes.length - 1;

                      Select3D.calculate_BoundingBox();
                    }
                  }



                  if (current_ObjectCategory == ObjectCategory.SOLID) { // working with solids
                    if (CreateObject == CREATE.Solid) {
                      allSolids.create(x, y, z, px, py, pz, rx, ry, rz, 0, 0, rot, 1);
                    }
                  }


                  if (current_ObjectCategory == ObjectCategory.CAMERA) { // working with cameras
                    if (CreateObject == CREATE.Camera) {

                      int f = int(RxP[0]);

                      float keep_WIN3D_CAM_x = WIN3D.CAM_x;
                      float keep_WIN3D_CAM_y = WIN3D.CAM_y;
                      float keep_WIN3D_CAM_z = WIN3D.CAM_z;
                      float keep_WIN3D_position_X = WIN3D.position_X;
                      float keep_WIN3D_position_Y = WIN3D.position_Y;
                      float keep_WIN3D_position_Z = WIN3D.position_Z;
                      float keep_WIN3D_position_T = WIN3D.position_T;
                      float keep_WIN3D_rotation_X = WIN3D.rotation_X;
                      float keep_WIN3D_rotation_Y = WIN3D.rotation_Y;
                      float keep_WIN3D_rotation_Z = WIN3D.rotation_Z;
                      float keep_WIN3D_rotation_T = WIN3D.rotation_T;
                      float keep_WIN3D_Zoom = WIN3D.Zoom;

                      {

                        WIN3D.CAM_x = RxP[1];
                        WIN3D.CAM_y = RxP[2];
                        WIN3D.CAM_z = RxP[3] + EyeLevel;

                        WIN3D.reverseTransform_3DViewport();

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
                      }

                      WIN3D.CAM_x = keep_WIN3D_CAM_x;
                      WIN3D.CAM_y = keep_WIN3D_CAM_y;
                      WIN3D.CAM_z = keep_WIN3D_CAM_z;
                      WIN3D.position_X = keep_WIN3D_position_X;
                      WIN3D.position_Y = keep_WIN3D_position_Y;
                      WIN3D.position_Z = keep_WIN3D_position_Z;
                      WIN3D.position_T = keep_WIN3D_position_T;
                      WIN3D.rotation_X = keep_WIN3D_rotation_X;
                      WIN3D.rotation_Y = keep_WIN3D_rotation_Y;
                      WIN3D.rotation_Z = keep_WIN3D_rotation_Z;
                      WIN3D.rotation_T = keep_WIN3D_rotation_T;
                      WIN3D.Zoom = keep_WIN3D_Zoom;
                    }
                  }


                  if (current_ObjectCategory == ObjectCategory.SECTION) { // working with sections
                    if (CreateObject == CREATE.Section) {

                      int createNewSection = 0;

                      float Section_X = allSolidImpacts.X[allSolidImpacts.sectionType];
                      float Section_Y = allSolidImpacts.Y[allSolidImpacts.sectionType];
                      float Section_Z = allSolidImpacts.Z[allSolidImpacts.sectionType];
                      float Section_R = allSolidImpacts.R[allSolidImpacts.sectionType];
                      float Section_U = allSolidImpacts.U[allSolidImpacts.sectionType];
                      float Section_V = allSolidImpacts.V[allSolidImpacts.sectionType];

                      int Section_Type = allSolidImpacts.sectionType;
                      int Section_RES1 = allSolidImpacts.RES1;
                      int Section_RES2 = allSolidImpacts.RES2;

                      if (mouseButton == LEFT) {

                        int f = int(RxP[0]);

                        int n = allFaces.nodes[f].length;

                        if (n > 2) {

                          //float min_Alpha = 90;
                          float min_Beta = 360;

                          for (int j = 0; j < n; j++) {

                            int j_next = (j + 1) % n;

                            float x1 = allPoints.getX(allFaces.nodes[f][j]);
                            float y1 = allPoints.getY(allFaces.nodes[f][j]);
                            float z1 = allPoints.getZ(allFaces.nodes[f][j]);

                            float x2 = allPoints.getX(allFaces.nodes[f][j_next]);
                            float y2 = allPoints.getY(allFaces.nodes[f][j_next]);
                            float z2 = allPoints.getZ(allFaces.nodes[f][j_next]);


                            //float Alpha = funcs.asin_ang(z2 - z1);
                            float Beta = funcs.atan2_ang(y2 - y1, x2 - x1) + 90;

                            //if (min_Alpha > Alpha) min_Alpha = Alpha;
                            if (min_Beta > Beta) min_Beta = Beta;
                          }

                          //println("min_Alpha", min_Alpha);

                          float[][] tmpVertices = new float[n][3];


                          for (int j = 0; j < n; j++) {

                            float x1 = allPoints.getX(allFaces.nodes[f][j]);
                            float y1 = allPoints.getY(allFaces.nodes[f][j]);
                            float z1 = allPoints.getZ(allFaces.nodes[f][j]);

                            float x2 = x1 * funcs.cos_ang(-min_Beta) - y1 * funcs.sin_ang(-min_Beta);
                            float y2 = x1 * funcs.sin_ang(-min_Beta) + y1 * funcs.cos_ang(-min_Beta);
                            float z2 = z1;

                            tmpVertices[j][0] = x2;
                            tmpVertices[j][1] = y2;
                            tmpVertices[j][2] = z2;
                          }

                          float min_x = FLOAT_undefined;
                          float max_x = -FLOAT_undefined;
                          float min_y = FLOAT_undefined;
                          float max_y = -FLOAT_undefined;
                          float min_z = FLOAT_undefined;
                          float max_z = -FLOAT_undefined;

                          float[] G = {
                            0, 0, 0
                          };
                          for (int j = 0; j < n; j++) {
                            float the_x = tmpVertices[j][0];
                            float the_y = tmpVertices[j][1];
                            float the_z = tmpVertices[j][2];

                            G[0] += the_x / float(n);
                            G[1] += the_y / float(n);
                            G[2] += the_z / float(n);

                            if (min_x > the_x) min_x = the_x;
                            if (max_x < the_x) max_x = the_x;
                            if (min_y > the_y) min_y = the_y;
                            if (max_y < the_y) max_y = the_y;
                            if (min_z > the_z) min_z = the_z;
                            if (max_z < the_z) max_z = the_z;
                          }



                          if ((max_z - min_z < max_x - min_x) && (max_z - min_z < max_y - min_y)) {
                            Section_Type = 1;

                            Section_U = max_x - min_x;
                            Section_V = max_y - min_y;

                            Section_X = G[0];
                            Section_Y = G[1];

                            Section_Z = G[2];

                            Section_R = min_Beta;
                          } else {
                            Section_Type = 2;

                            Section_U = max_y - min_y;
                            Section_V = max_z - min_z;

                            Section_X = -G[1];
                            Section_Y = G[2];

                            Section_Z = -G[0];

                            Section_R = 90 - min_Beta;
                          }


                          // recalculating G...
                          G[0] = 0;
                          G[1] = 0;
                          G[2] = 0;
                          for (int j = 0; j < n; j++) {
                            float the_x = allPoints.getX(allFaces.nodes[f][j]);
                            float the_y = allPoints.getY(allFaces.nodes[f][j]);
                            float the_z = allPoints.getZ(allFaces.nodes[f][j]);

                            G[0] += the_x / float(n);
                            G[1] += the_y / float(n);
                            G[2] += the_z / float(n);
                          }

                          PVector AG = new PVector(allPoints.getX(allFaces.nodes[f][0]) - G[0], allPoints.getY(allFaces.nodes[f][0]) - G[1], allPoints.getZ(allFaces.nodes[f][0]) - G[2]);
                          PVector BG = new PVector(allPoints.getX(allFaces.nodes[f][1]) - G[0], allPoints.getY(allFaces.nodes[f][1]) - G[1], allPoints.getZ(allFaces.nodes[f][1]) - G[2]);

                          PVector GAxGB = AG.cross(BG);

                          float[][] ImageVertex = allSections.getCorners(Section_Type, Section_X, Section_Y, Section_Z, Section_R, Section_U, Section_V, Section_RES1, Section_RES2);

                          float[] SectionCorner_A = ImageVertex[1];
                          float[] SectionCorner_B = ImageVertex[2];
                          float[] SectionCorner_C = ImageVertex[3];
                          float[] SectionCorner_D = ImageVertex[4];

                          float[] ImageCenter = {
                            0, 0, 0
                          };
                          for (int j = 0; j < 3; j++) {
                            ImageCenter[j] = 0.25 * (SectionCorner_A[j] + SectionCorner_B[j] + SectionCorner_C[j] + SectionCorner_D[j]);
                          }

                          PVector AG_other = new PVector(SectionCorner_A[0] - ImageCenter[0], SectionCorner_A[1] - ImageCenter[1], SectionCorner_A[2] - ImageCenter[2]);
                          PVector BG_other = new PVector(SectionCorner_B[0] - ImageCenter[0], SectionCorner_B[1] - ImageCenter[1], SectionCorner_B[2] - ImageCenter[2]);

                          PVector GAxGB_other = AG_other.cross(BG_other);

                          //println("GAxGB", GAxGB);
                          //println("GAxGB_other", GAxGB_other);

                          float V = GAxGB_other.dot(GAxGB);

                          //println("V", nf(V, 0, 6));

                          if (V < 0) {
                            println("flip face!");

                            Section_R = 180 + Section_R;
                            Section_Z *= -1;
                            Section_X *= -1;
                          } else {
                            println("face OK!");
                          }

                          createNewSection = 1;

                        }
                      }

                      if (mouseButton == RIGHT) {

                        Section_Type = 1;

                        Section_X = RxP[1];
                        Section_Y = RxP[2];
                        Section_Z = RxP[3];


                        createNewSection = 1;
                      }

                      if (createNewSection != 0) {

                        allSections.create(Section_X, Section_Y, Section_Z, Section_R, Section_U, Section_V, Section_Type, Section_RES1, Section_RES2);

                        if (keep_number_of_allSections != allSections.num) { // if any Section created during the process

                          Select3D.deselect_Sections();

                          for (int o = keep_number_of_allSections; o < allSections.num; o++) {

                            int[] newlyAddedSection = {o};

                            Select3D.Section_ids = concat(Select3D.Section_ids, newlyAddedSection);
                          }

                          Select3D.calculate_BoundingBox();
                        }

                        allSolidImpacts.X[allSolidImpacts.sectionType] = Section_X;
                        allSolidImpacts.Y[allSolidImpacts.sectionType] = Section_Y;
                        allSolidImpacts.Z[allSolidImpacts.sectionType] = Section_Z;
                        allSolidImpacts.R[allSolidImpacts.sectionType] = Section_R;
                        allSolidImpacts.U[allSolidImpacts.sectionType] = Section_U;
                        allSolidImpacts.V[allSolidImpacts.sectionType] = Section_V;

                        allSolidImpacts.sectionType = Section_Type;
                        allSolidImpacts.RES1 = Section_RES1;
                        allSolidImpacts.RES2 = Section_RES2;

                        allSolidImpacts.calculate_Impact_selectedSections();

                        allSolarImpacts.sectionType = Section_Type;
                      }
                    }
                  }




                  if (keep_number_of_allSolids != allSolids.DEF.length) { // if any Solid created during the process

                    Select3D.deselect_Solids();

                    for (int o = keep_number_of_allSolids; o < allSolids.DEF.length; o++) {

                      int[] newlyAddedSolid = {o};

                      Select3D.Solid_ids = concat(Select3D.Solid_ids, newlyAddedSolid);
                    }

                    Select3D.calculate_BoundingBox();
                  }



                  if (keep_number_of_allCameras != allCameras.num) { // if any Camera created during the process

                    Select3D.deselect_Cameras();

                    for (int o = keep_number_of_allCameras; o < allCameras.num; o++) {

                      int[] newlyAddedCamera = {o};

                      Select3D.Camera_ids = concat(Select3D.Camera_ids, newlyAddedCamera);
                    }

                    Select3D.calculate_BoundingBox();
                  }


                  if (keep_number_of_allGroups != allGroups.num) { // if any Group created during the process

                    Select3D.deselect_Groups();

                    for (int o = keep_number_of_allGroups; o < allGroups.num; o++) {

                      int[] newlyAddedGroup = {o};

                      Select3D.Group_ids = concat(Select3D.Group_ids, newlyAddedGroup);
                    }

                    Select3D.calculate_BoundingBox();
                  }

                  if (keep_number_of_allModel2Ds != allModel2Ds.num) { // if any allModel2Ds created during the process

                    Select3D.deselect_Model2Ds();

                    for (int o = keep_number_of_allModel2Ds; o < allModel2Ds.num; o++) {

                      int[] newlyAddedallModel2Ds = {o};

                      Select3D.Model2D_ids = concat(Select3D.Model2D_ids, newlyAddedallModel2Ds);
                    }

                    Select3D.calculate_BoundingBox();
                  }


                  if (keep_number_of_allModel1Ds != allModel1Ds.num) { // if any allModel1Ds created during the process

                    Select3D.deselect_Model1Ds();

                    for (int o = keep_number_of_allModel1Ds; o < allModel1Ds.num; o++) {

                      int[] newlyAddedallModel1Ds = {o};

                      Select3D.Model1D_ids = concat(Select3D.Model1D_ids, newlyAddedallModel1Ds);
                    }

                    Select3D.calculate_BoundingBox();
                  }




                }
              }

              SOLARCHVISION_view_changed();
            }
          }
        }

        redraw();
      }
    }
  }
}
