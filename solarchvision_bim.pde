import processing.pdf.*;

int SOLARCHVISION_pixel_H = 400;
int SOLARCHVISION_pixel_W = 724;

float MessageSize = 16.0;
int SOLARCHVISION_pixel_A = 24; // menu bar
int SOLARCHVISION_pixel_B = 42; // 3D tool bar
int SOLARCHVISION_pixel_C = 72; // case bar
int SOLARCHVISION_pixel_D = 72; // command bar

/*
  If you modify the above values (e.g., scale them by a constant factor)
  to fit your screen resolution, ensure that you also update the size() call
  inside setup() by recalculating the width and height using the same scale factor
  or according to the formulas below:

  width: 2 * SOLARCHVISION_pixel_W + ROLLOUT.dX
  height: SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 2 * SOLARCHVISION_pixel_H + SOLARCHVISION_pixel_C + SOLARCHVISION_pixel_D

  You should search for the size call like this and modify that.

void setup () {
  size(1846, 1016, P2D);

}
*/

class solarchvision_MESSAGE {

  private final static String CLASS_STAMP = "MESSAGE";

  int cX = 0;
  int cY = 495;
  int dX = 1846;
  int dY = int(2 * MessageSize);
}

solarchvision_MESSAGE MESSAGE = new solarchvision_MESSAGE();

void setup () {
  size(1846, 1016, P2D);
  //size(2 * SOLARCHVISION_pixel_W + ROLLOUT.dX, SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 2 * SOLARCHVISION_pixel_H + SOLARCHVISION_pixel_C + SOLARCHVISION_pixel_D, P2D);

  SOLARCHVISION_draw_frameIcon();

  TIME.date = (286 + TIME.convert2Date(TIME.month, TIME.day)) % 365; // 0 presents March 21, 286 presents Jan.01, 345 presents March.01
  //if (TIME.hour >= 12) TIME.date += 0.5;

  allMaterials.empty_DirectArea();
  allMaterials.empty_DiffuseArea();

  VertexSolar_resize_array();
  GlobalSolar_resize_array();

  Tropo3D.resize_images();

  Earth3D.resize_images();

  Sun3D.load_images();
  Moon3D.load_images();

  WIN3D.graphics = createGraphics(WIN3D.dX, WIN3D.dY, P3D);

  WORLD.graphics = createGraphics(WORLD.dX, WORLD.dY, P2D);

  STUDY.graphics = createGraphics(STUDY.dX, STUDY.dY, P2D);

  SKY2D_graphics = createGraphics(SKY2D_X_View, SKY2D_Y_View, P3D);

  SOLARCHVISION_loadDefaultFontStyle();

  changeCurrentLayerTo(5); // pointing to air temperature variable i.e. on the list of allLayers

  frameRate(24);

  loop();
}

int Last_initializationStep = 1000;
int InitializationStep = 0;

void draw () {

  //println("frameCount:", frameCount);

  if (frameCount == 1) {

    background(223);

    SOLARCHVISION_update_folders();

    float cr;

    cr = SOLARCHVISION_pixel_W / 4.0;
    //PImage SOLARCHVISION_logo = loadImage(BaseFolder + "/input/images/logo/SOLARCHVISION.jpg");
    //imageMode(CENTER);
    //image(SOLARCHVISION_logo, 0.5 * width, 0.5 * height - 0.75 * MessageSize - cr + (0.075 * cr), 3.05 * cr, 3.05 * cr);
    imageMode(CORNER);

    strokeWeight(1);
    stroke(0);
    noFill();

    ellipseMode(CENTER);

    strokeWeight(0);
    stroke(191);
    fill(191);
    ellipse(0.2 * width, 0.5 * height - 0.75 * MessageSize - cr, 2 * cr, 2 * cr);

    SOLARCHVISION_draw_logo(0.2 * width, 0.5 * height - 0.75 * MessageSize - cr, 0, cr, 1, 1);
    strokeWeight(2);
    stroke(0);
    noFill();
    ellipse(0.2 * width, 0.5 * height - 0.75 * MessageSize - cr, 2 * cr, 2 * cr);

    SOLARCHVISION_draw_logo(0.5 * width, 0.5 * height - 0.75 * MessageSize - cr, 0, cr, 0, 1);
    SOLARCHVISION_draw_logo(0.5 * width, 0.5 * height - 0.75 * MessageSize - cr, 0, cr, 0, 2);
    strokeWeight(2);
    stroke(0);
    noFill();
    ellipse(0.5 * width, 0.5 * height - 0.75 * MessageSize - cr, 2 * cr, 2 * cr);

    strokeWeight(0);
    stroke(191);
    fill(191);
    ellipse(0.8 * width, 0.5 * height - 0.75 * MessageSize - cr, 2 * cr, 2 * cr);

    SOLARCHVISION_draw_logo(0.8 * width, 0.5 * height - 0.75 * MessageSize - cr, 0, cr, -1, 1);
    strokeWeight(2);
    stroke(0);
    noFill();
    ellipse(0.8 * width, 0.5 * height - 0.75 * MessageSize - cr, 2 * cr, 2 * cr);

    strokeWeight(0);

    stroke(255);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(3 * MessageSize);
    text(SOLARCHVISION_version + " model integrations (BIM-6D)", 0.5 * width, 0.05 * height);

    stroke(0);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(3 * MessageSize);
    text("SOLARCHVISION", 0.5 * width, 0.6 * height);

    stroke(0);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(1.5 * MessageSize);
    text("Raz, Mehr, Mehraz solarch studio\n1998-" + SOLARCHVISION_version + "\nAuthor: Mojtaba Samimi\nwww.solarchvision.com", 0.5 * width, 0.75 * height);

    textAlign(CENTER, CENTER);
    textSize(1.25 * MessageSize);
  } else if (frameCount == 2) {
    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("WORLD.listAllImages", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 3) {
    WORLD.listAllImages();
    WORLD.loadImages(WORLD.VIEW_id); // to load the globe image into memory

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("Model2Ds.load_images", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 4) {
    allModel2Ds.load_images();

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("inputCoordinates_SWOB", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 5) {
    inputCoordinates_SWOB();

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("inputCoordinates_NAEFS", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 6) {
    inputCoordinates_NAEFS();
    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("inputCoordinates_CWEEDS", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 7) {
    inputCoordinates_CWEEDS();
    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("inputCoordinates_CLMREC", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 8) {
    inputCoordinates_CLMREC();
    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("inputCoordinates_TMYEPW", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 9) {
    inputCoordinates_TMYEPW();
    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("TIME.updateDate", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 10) {
    TIME.updateDate();

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("update_station(start)", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 11) {
    SOLARCHVISION_update_station(1);

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("update_CLIMATE_TMYEPW", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 12) {
    SOLARCHVISION_update_station(2);

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("update_CLIMATE_CWEEDS", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 13) {
    SOLARCHVISION_update_station(3);

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("update_CLIMATE_CLMREC", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 14) {
    SOLARCHVISION_update_station(4);

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("update_ENSEMBLE_OBSERVED", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 15) {
    SOLARCHVISION_update_station(5);

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("update_ENSEMBLE_FORECAST", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 16) {
    SOLARCHVISION_update_station(6);

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("Land3D.update_mesh", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 17) {
    SOLARCHVISION_update_station(7);

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("Earth3D.load_images", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 18) {
    Earth3D.load_images();

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("Tropo3D.load_images", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 19) {
    Tropo3D.load_images();

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("build_SkySphere", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 20) {

    SOLARCHVISION_build_SkySphere(1); //1 - 3
    GlobalSolar_resize_array();
    VertexSolar_resize_array();

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("Please wait while integrating the models.", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);

    MESSAGE.dX = 2 * SOLARCHVISION_pixel_W;

    SOLARCHVISION_X_clicked = -1;
    SOLARCHVISION_Y_clicked = -1;

    UI_menuBar.revise();
    UI_toolBar.revise();
    UI_caseBar.revise();
    UI_commandBar.revise();

    InitializationStep = frameCount;
    Last_initializationStep = frameCount;
  } else {

    if (ROLLOUT.include) {
      if (ROLLOUT.update) {
        ROLLOUT.updated();

        pre_SampleYear_Start = SampleYear_Start;
        pre_SampleYear_End = SampleYear_End;
        pre_SampleMember_Start = SampleMember_Start;
        pre_SampleMember_End = SampleMember_End;
        pre_SampleStation_Start = SampleStation_Start;
        pre_SampleStation_End = SampleStation_End;
        pre_STUDY_joinDays = STUDY.joinDays;
        pre_STUDY_i_Start = STUDY.i_Start;
        pre_STUDY_i_End = STUDY.i_End;
        pre_STUDY_j_End = STUDY.j_End;
        pre_IMPACTS_displayDay = IMPACTS_displayDay;
        pre_STUDY_Setup = STUDY.plotSetup;
        pre_CurrentDataSource = CurrentDataSource;
        pre_TIME_Year = TIME.year;
        pre_TIME_Month = TIME.month;
        pre_TIME_Day = TIME.day;
        pre_TIME_Date = TIME.date;
        pre_TIME_Hour = TIME.hour;
        pre_CLIMATIC_SolarForecast = CLIMATIC_SolarForecast;
        pre_CLIMATIC_WeatherForecast = CLIMATIC_WeatherForecast;

        pre_CLIMATE_TMYEPW_load = CLIMATE_TMYEPW_load;
        pre_CLIMATE_CWEEDS_load = CLIMATE_CWEEDS_load;
        pre_CLIMATE_CLMREC_load = CLIMATE_CLMREC_load;
        pre_ENSEMBLE_FORECAST_load = ENSEMBLE_FORECAST_load;
        pre_ENSEMBLE_OBSERVED_load = ENSEMBLE_OBSERVED_load;

        pre_LocationLAT = LocationLAT;
        pre_LocationLON = LocationLON;

        pre_WORLD_autoView = WORLD.autoView;

        pre_Land3D_loadMesh = Land3D.loadMesh;
        pre_Land3D_loadTextures = Land3D.loadTextures;

        pre_allSolids_pallet_CLR = allSolids.pallet_CLR;
        pre_allSolids_pallet_DIR = allSolids.pallet_DIR;
        pre_allSolids_pallet_MLT = allSolids.pallet_MLT;

        pre_USER_create_powAll = User3D.create_powAll;

        pre_allSolidImpacts_U_scale = allSolidImpacts.U;
        pre_allSolidImpacts_V_scale = allSolidImpacts.V;

        pre_allSolidImpacts_sU_offset = allSolidImpacts.X;
        pre_allSolidImpacts_sV_offset = allSolidImpacts.Y;

        pre_allSolidImpacts_Grade = allSolidImpacts.Grade;
        pre_allSolidImpacts_Power = allSolidImpacts.Power;
        pre_allSolidImpacts_Rotation[allSolidImpacts.sectionType] = allSolidImpacts.R[allSolidImpacts.sectionType];
        pre_allSolidImpacts_Elevation[allSolidImpacts.sectionType] = allSolidImpacts.Z[allSolidImpacts.sectionType];

        pre_allSolidImpacts_Wspd = allSolidImpacts.WindSpeed;
        pre_allSolidImpacts_Wdir = allSolidImpacts.WindDirection;

        pre_allSolidImpacts_Process_subDivisions = allSolidImpacts.Process_subDivisions;

        pre_allSolidImpacts_displayPoints = allSolidImpacts.displayPoints;
        pre_allSolidImpacts_displayLines = allSolidImpacts.displayLines;

        pre_WindFlow_display = allWindFlows.displayAll;

        pre_Selection_Solid_displayEdges = Select3D.Solid_displayEdges;

        pre_Selection_Section_displayEdges = Select3D.Section_displayEdges;

        pre_Selection_Camera_displayEdges = Select3D.Camera_displayEdges;

        pre_Selection_LandPoint_displayPoints = Select3D.LandPoint_displayPoints;

        pre_Selection_Model1D_displayEdges = Select3D.Model1D_displayEdges;
        pre_Selection_Model2D_displayEdges = Select3D.Model2D_displayEdges;
        pre_allPoints_displayAll = allPoints.displayAll;
        pre_allFaces_displayEdges = allFaces.displayEdges;
        pre_allFaces_displayNormals = allFaces.displayNormals;

        pre_Selection_softPower = Select3D.softPower;
        pre_Selection_softRadius = Select3D.softRadius;

        pre_Selection_posValue = Select3D.posValue;
        pre_Selection_rotValue = Select3D.rotValue;
        pre_Selection_scaleValue = Select3D.scaleValue;

        pre_Selection_alignX = Select3D.alignX;
        pre_Selection_alignY = Select3D.alignY;
        pre_Selection_alignZ = Select3D.alignZ;

        pre_Selection_displayReferencePivot = Select3D.displayReferencePivot;

        pre_Selection_Group_displayPivot = Select3D.Group_displayPivot;
        pre_Selection_Group_displayEdges = Select3D.Group_displayEdges;
        pre_Selection_Group_displayBox = Select3D.Group_displayBox;

        pre_Selection_Face_displayEdges = Select3D.Face_displayEdges;
        pre_Selection_Face_displayVertexCount = Select3D.Face_displayVertexCount;
        pre_Selection_Polyline_displayVertexCount = Select3D.Polyline_displayVertexCount;
        pre_Selection_Vertex_displayVertices = Select3D.Vertex_displayVertices;
        pre_Selection_Polyline_displayVertices = Select3D.Polyline_displayVertices;

        pre_WIN3D_currentCamera = WIN3D.currentCamera;

        pre_WIN3D_FacesShade = WIN3D.FacesShade;

        pre_Create3D_Tessellation = allFaces.displayTessellation;

        pre_STUDY_ImpactLayer = STUDY.ImpactLayer;

        pre_Develop_Option = Develop_Option;

        pre_STUDY_CurrentLayer_id = CurrentLayer_id;

        pre_STUDY_SkyScenario = STUDY.skyScenario;

        pre_STUDY_PlotImpacts = STUDY.PlotImpacts;

        ROLLOUT.drawView();

        if (pre_STUDY_PlotImpacts != STUDY.PlotImpacts) {
          STUDY.revise();

          SOLARCHVISION_view_changed();
        }

        if (pre_SampleYear_Start != SampleYear_Start) {
          UI_caseBar.revise();
        }
        if (pre_SampleYear_End != SampleYear_End) {
          UI_caseBar.revise();
        }

        if (pre_SampleMember_Start != SampleMember_Start) {
          UI_caseBar.revise();
        }

        if (pre_SampleMember_End != SampleMember_End) {
          UI_caseBar.revise();
        }

        if (pre_SampleStation_Start != SampleStation_Start) {
          UI_caseBar.revise();
        }

        if (pre_SampleStation_End != SampleStation_End) {
          UI_caseBar.revise();
        }

        if (pre_STUDY_joinDays != STUDY.joinDays) {
          UI_caseBar.revise();
        }

        if (pre_STUDY_i_Start != STUDY.i_Start) {
          UI_caseBar.revise();
        }

        if (pre_STUDY_i_End != STUDY.i_End) {
          UI_caseBar.revise();
        }

        if (pre_STUDY_j_End != STUDY.j_End) {
          UI_caseBar.revise();

          VertexSolar_rebuild_array = true;
          GlobalSolar_rebuild_array = true;
          allSolarImpacts.rebuild_Image_array = true;
          allWindRoses.rebuild_Image_array = true;

          allSections.resize_solarImpact_array();
        }

        if (pre_IMPACTS_displayDay != IMPACTS_displayDay) {
          UI_caseBar.revise();
        }

        if (pre_TIME_Date != TIME.date) {
          UI_caseBar.revise();

          TIME.updateDate();
          ROLLOUT.drawView();
        }

        if ((pre_TIME_Year != TIME.year) ||
            (pre_TIME_Month != TIME.month) ||
            (pre_TIME_Day != TIME.day) ||
            (pre_TIME_Hour != TIME.hour) ||
            (pre_CLIMATIC_SolarForecast != CLIMATIC_SolarForecast) ||
            (pre_CLIMATIC_WeatherForecast != CLIMATIC_WeatherForecast)) {

          UI_caseBar.revise();

          TIME.beginDay = TIME.convert2Date(TIME.month, TIME.day);
          TIME.hour = int(24 * (TIME.date - int(TIME.date)));
          TIME.date = (TIME.hour / 24.0) + (286 + TIME.convert2Date(TIME.month, TIME.day)) % 365;
          println("DATE:", TIME.date, "\tHOUR:", TIME.hour);
          update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);

          ROLLOUT.drawView();
        }

        if (pre_CLIMATE_TMYEPW_load != CLIMATE_TMYEPW_load) update_CLIMATE_TMYEPW();
        if (pre_CLIMATE_CWEEDS_load != CLIMATE_CWEEDS_load) update_CLIMATE_CWEEDS();
        if (pre_CLIMATE_CLMREC_load != CLIMATE_CLMREC_load) update_CLIMATE_CLMREC();
        if (pre_ENSEMBLE_OBSERVED_load != ENSEMBLE_OBSERVED_load) update_ENSEMBLE_OBSERVED();
        if (pre_ENSEMBLE_FORECAST_load != ENSEMBLE_FORECAST_load) update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);

        if (pre_WORLD_autoView != WORLD.autoView) {
          WORLD.VIEW_id = WORLD.FindGoodViewport(LocationLON, LocationLAT);
        }

        if ((pre_LocationLAT != LocationLAT) ||
            (pre_LocationLON != LocationLON)) {

          WORLD.VIEW_id = WORLD.FindGoodViewport(LocationLON, LocationLAT);
          WORLD.revise();
        }

        if (pre_Land3D_loadMesh != Land3D.loadMesh) {
          Land3D.update_mesh();
          SOLARCHVISION_model_changed();
        }

        if (pre_Land3D_loadTextures != Land3D.loadTextures) {
          Land3D.update_textures();
          SOLARCHVISION_model_changed();
        }

        if (pre_Selection_Camera_displayEdges != Select3D.Camera_displayEdges) {
          SOLARCHVISION_view_changed();
        }

        if (pre_Selection_Section_displayEdges != Select3D.Section_displayEdges) {
          SOLARCHVISION_view_changed();
        }

        if (pre_Selection_Solid_displayEdges != Select3D.Solid_displayEdges) {
          SOLARCHVISION_view_changed();
        }

        if (pre_Selection_LandPoint_displayPoints != Select3D.LandPoint_displayPoints) {
          SOLARCHVISION_view_changed();
        }

        if (pre_Selection_Model1D_displayEdges != Select3D.Model1D_displayEdges) {
          SOLARCHVISION_view_changed();
        }

        if (pre_Selection_Model2D_displayEdges != Select3D.Model2D_displayEdges) {
          SOLARCHVISION_view_changed();
        }

        if (pre_Selection_softPower != Select3D.softPower) {
          Select3D.convert_Vertex_to_softSelection();
        }

        if (pre_Selection_softRadius != Select3D.softRadius) {
          Select3D.convert_Vertex_to_softSelection();
        }

        if (pre_Selection_alignX != Select3D.alignX) {
          SOLARCHVISION_selection_changed();
        }

        if (pre_Selection_alignY != Select3D.alignY) {
          SOLARCHVISION_selection_changed();
        }

        if (pre_Selection_alignZ != Select3D.alignZ) {
          SOLARCHVISION_selection_changed();
        }

        if (pre_Selection_posValue != Select3D.posValue) {

          float d = Select3D.posValue - pre_Selection_posValue;

          float dx = d;
          float dy = d;
          float dz = d;

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
        if (pre_Selection_rotValue != Select3D.rotValue) {

          float[] P = Select3D.getPivot();

          float x0 = P[0];
          float y0 = P[1];
          float z0 = P[2];

          float r = Select3D.rotValue - pre_Selection_rotValue;

          int the_Vector = Select3D.rotVector;

          Rotate3D.selection(x0, y0, z0, r, the_Vector);

          SOLARCHVISION_model_changed();
        }
        if (pre_Selection_scaleValue != Select3D.scaleValue) {

          float[] P = Select3D.getPivot();

          float x0 = P[0];
          float y0 = P[1];
          float z0 = P[2];

          float s = pow(2.0, Select3D.scaleValue - pre_Selection_scaleValue);

          float sx = s;
          float sy = s;
          float sz = s;

          int the_Vector = Select3D.scaleVector;

          if (the_Vector == 0) {
            sy = 1;
            sz = 1;
          }
          if (the_Vector == 1) {
            sz = 1;
            sx = 1;
          }
          if (the_Vector == 2) {
            sx = 1;
            sy = 1;
          }

          Scale3D.selection(x0, y0, z0, sx, sy, sz);

          SOLARCHVISION_model_changed();
        }

        if (pre_Selection_displayReferencePivot != Select3D.displayReferencePivot) {
          SOLARCHVISION_view_changed();
        }

        if (pre_Selection_Group_displayPivot != Select3D.Group_displayPivot) {
          SOLARCHVISION_view_changed();
        }

        if (pre_Selection_Group_displayEdges != Select3D.Group_displayEdges) {
          SOLARCHVISION_view_changed();
        }

        if (pre_Selection_Group_displayBox != Select3D.Group_displayBox) {
          SOLARCHVISION_view_changed();
        }

        if (pre_Selection_Face_displayEdges != Select3D.Face_displayEdges) {
          SOLARCHVISION_view_changed();
        }

        if (pre_Selection_Face_displayVertexCount != Select3D.Face_displayVertexCount) {
          SOLARCHVISION_view_changed();
        }

        if (pre_Selection_Polyline_displayVertexCount != Select3D.Polyline_displayVertexCount) {
          SOLARCHVISION_view_changed();
        }

        if (pre_Selection_Vertex_displayVertices != Select3D.Vertex_displayVertices) {
          SOLARCHVISION_view_changed();
        }

        if (pre_Selection_Polyline_displayVertices != Select3D.Polyline_displayVertices) {
          SOLARCHVISION_view_changed();
        }

        if (pre_WIN3D_currentCamera != WIN3D.currentCamera) {
          WIN3D.apply_currentCamera();

          SOLARCHVISION_modify_Viewport_Title();

          SOLARCHVISION_view_changed();
        }

        if (pre_WIN3D_FacesShade != WIN3D.FacesShade) {
          SOLARCHVISION_view_changed();
        }

        if (pre_Create3D_Tessellation != allFaces.displayTessellation) {
          SOLARCHVISION_view_changed();
        }

        if (pre_USER_create_powAll != User3D.create_powAll) {
          User3D.create_powX = User3D.create_powAll;
          User3D.create_powY = User3D.create_powAll;
          User3D.create_powZ = User3D.create_powAll;

          ROLLOUT.revise();
        }

        if (pre_allSolids_pallet_CLR != allSolids.pallet_CLR) {
          allSolidImpacts.calculate_Impact_selectedSections();

          SOLARCHVISION_view_changed();
        }
        if (pre_allSolids_pallet_DIR != allSolids.pallet_DIR) {
          allSolidImpacts.calculate_Impact_selectedSections();

          SOLARCHVISION_view_changed();
        }
        if (pre_allSolids_pallet_MLT != allSolids.pallet_MLT) {
          allSolidImpacts.calculate_Impact_selectedSections();

          SOLARCHVISION_view_changed();
        }

        if (pre_allSolidImpacts_Grade != allSolidImpacts.Grade) {
          allSolidImpacts.calculate_Impact_selectedSections();

          SOLARCHVISION_view_changed();
        }
        if (pre_allSolidImpacts_Power != allSolidImpacts.Power) {
          allSolidImpacts.calculate_Impact_selectedSections();

          SOLARCHVISION_view_changed();
        }
        if (pre_allSolidImpacts_Rotation[allSolidImpacts.sectionType] != allSolidImpacts.R[allSolidImpacts.sectionType]) {
          allSolidImpacts.calculate_Impact_selectedSections();

          SOLARCHVISION_view_changed();
        }
        if (pre_allSolidImpacts_Elevation[allSolidImpacts.sectionType] != allSolidImpacts.Z[allSolidImpacts.sectionType]) {
          allSolidImpacts.calculate_Impact_selectedSections();

          SOLARCHVISION_view_changed();
        }

        if (pre_allSolidImpacts_U_scale[allSolidImpacts.sectionType] != allSolidImpacts.U[allSolidImpacts.sectionType]) {
          allSolidImpacts.calculate_Impact_selectedSections();

          SOLARCHVISION_view_changed();
        }

        if (pre_allSolidImpacts_V_scale[allSolidImpacts.sectionType] != allSolidImpacts.V[allSolidImpacts.sectionType]) {
          allSolidImpacts.calculate_Impact_selectedSections();

          SOLARCHVISION_view_changed();
        }

        if (pre_allSolidImpacts_sU_offset[allSolidImpacts.sectionType] != allSolidImpacts.X[allSolidImpacts.sectionType]) {
          allSolidImpacts.calculate_Impact_selectedSections();

          SOLARCHVISION_view_changed();
        }
        if (pre_allSolidImpacts_sV_offset[allSolidImpacts.sectionType] != allSolidImpacts.Y[allSolidImpacts.sectionType]) {
          allSolidImpacts.calculate_Impact_selectedSections();

          SOLARCHVISION_view_changed();
        }

        if (pre_allSolidImpacts_Wspd != allSolidImpacts.WindSpeed) {
          allSolidImpacts.calculate_Impact_selectedSections();

          SOLARCHVISION_view_changed();
        }
        if (pre_allSolidImpacts_Wdir != allSolidImpacts.WindDirection) {
          allSolidImpacts.calculate_Impact_selectedSections();

          SOLARCHVISION_view_changed();
        }

        if (pre_allSolidImpacts_Process_subDivisions != allSolidImpacts.Process_subDivisions) {
          allSolidImpacts.calculate_Impact_selectedSections();

          SOLARCHVISION_view_changed();
        }

        if (pre_allSolidImpacts_displayPoints != allSolidImpacts.displayPoints) {
          SOLARCHVISION_view_changed();
        }

        if (pre_allSolidImpacts_displayLines != allSolidImpacts.displayLines) {
          SOLARCHVISION_view_changed();
        }

        if (pre_allPoints_displayAll != allPoints.displayAll) {
          SOLARCHVISION_view_changed();
        }

        if (pre_allFaces_displayEdges != allFaces.displayEdges) {
          SOLARCHVISION_view_changed();
        }

        if (pre_allFaces_displayNormals != allFaces.displayNormals) {
          SOLARCHVISION_view_changed();
        }

        if (pre_WindFlow_display != allWindFlows.displayAll) {
          SOLARCHVISION_view_changed();
        }

        if (STUDY.plotSetup != pre_STUDY_Setup) {
          STUDY.Impacts_update = true;
          UI_caseBar.updated();
        }

        if (CurrentDataSource != pre_CurrentDataSource) {
          STUDY.Impacts_update = true;
          UI_caseBar.updated();
        }
      }
    }

    if (FRAME_record_AUTO) {
      if (STUDY.update) FRAME_record_IMG = true;
      if (WIN3D.update) FRAME_record_IMG = true;
      if (WORLD.update) FRAME_record_IMG = true;
      //if (UI_menuBar.update) FRAME_record_IMG = true;
      //if (UI_toolBar.update) FRAME_record_IMG = true;
      //if (UI_caseBar.update) FRAME_record_IMG = true;
    }

    int Illustrations_Animate = 0;

    //if ((STUDY.update == false) && (WIN3D.update == false)) {
    if (STUDY.update == false) {
      //Illustrations_Animate = 1;
    }

    if (STUDY.include) {
      if (STUDY.update) {

        STUDY.drawView();
      }
    }
    STUDY.updated();

    if (STUDY.record_PDF == false) {
      if (WORLD.include) {
        if (WORLD.update) {

          WORLD.drawView();
        }
      }

      if (WORLD.record_PDF == false) {
        if (WIN3D.include) {
          if (WIN3D.update) {

            SOLARCHVISION_regenerate_desired_bakings();

            WIN3D.drawView();
          }
        }

        if(updateBars) {
          updateBars = false;
          UI_menuBar.revise();
          UI_toolBar.revise();
          UI_caseBar.revise();
          UI_commandBar.revise();
        }

        if (UI_menuBar.update) {
          UI_menuBar.draw();
        }

        if (UI_toolBar.update) {
          UI_toolBar.draw();
        }

        if (UI_caseBar.update) {
          UI_caseBar.draw();
        }

        if (UI_commandBar.update) {
          UI_commandBar.draw();
        }

        if (FRAME_record_IMG) {
          SOLARCHVISION_RecordFrame();
          FRAME_record_IMG = false;
        }
      } else {
        WORLD.record_PDF = false;
      }
    } else {
      STUDY.record_PDF = false;
    }

    //WIN3D.updated();
    //WORLD.updated();
    //STUDY.updated();

    //noLoop(); // <<<<<<<<<<<<

  }
}

String SceneName = "";

String SOLARCHVISION_version = "2026";
String BaseFolder = "/home/solarch/org/solarchvision_bim";

String RunStamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2);
String ProjectName = "Revision_" + RunStamp;
String HoldStamp = "";

String Subfolder_exportMaps = "maps/";

solarchvision_STATION STATION = new solarchvision_STATION(
  //"", "Montreal", "QC", "CA", 45.47, -73.75, -75, 36, "MONTREAL_DORVAL_QC_CA", "CAN_QC_MONTREAL-INTL-A_7025251_CWEEDS2011_1998-2017", "CAN_PQ_Montreal.Intl.AP.716270_CWEC"
  "", "Toronto", "ON", "CA", 43.67, -79.63, -75, 173, "TORONTO_PEARSON_INTL_ON_CA", "CAN_ON_TORONTO-INTL-A_6158731_CWEEDS2011_1998-2017", "CAN_ON_Toronto.716240_CWEC"
  //"", "Vancouver", "BC", "CA", 49.18, -123.17, -120, 2, "VANCOUVER_INTL_BC_CA", "CAN_BC_VANCOUVER-INTL-A_1108395_CWEEDS2011_1998-2017", "CAN_BC_Vancouver.718920_CWEC"
);

solarchvision_OBJECTTYPE ObjectCategory = new solarchvision_OBJECTTYPE();

solarchvision_WINDOWTYPE TypeWindow = new solarchvision_WINDOWTYPE();

solarchvision_CREATE CREATE = new solarchvision_CREATE();

int CreateObject = CREATE.Nothing;

int current_ObjectCategory = ObjectCategory.GROUP;

int current_Material = 7;
int current_Tessellation = 0;
int current_Layer = 0;
int current_Visibility = 1;
int current_Weight = 0;
int current_Closed = 0;

class solarchvision_DATATYPE {

  private final static String CLASS_STAMP = "DATATYPE";

  final static int SATELLITE_GOES = 0;
  final static int FORECAST_HRDPS = 1;
  final static int FORECAST_RDPS  = 2;
  final static int FORECAST_GDPS  = 3;

}

solarchvision_DATATYPE DataType = new solarchvision_DATATYPE();

int WMS_type = DataType.FORECAST_HRDPS; // <<<<<<<<<<<<<

int TROPO_deltaTime = (WMS_type == solarchvision_DATATYPE.FORECAST_GDPS) ? 3 : 1;
int TROPO_timeSteps = 24;

float Interpolation_Weight = 0.5;// 0 = linear distance interpolation, 1 = square distance interpolation, 5 = nearest

final int Impact_ACTIVE = 0; // internal
final int Impact_PASSIVE = 1; // internal
final int numberOfImpactVariations = 2; // internal

final int PlotImpacts_CYCLES_ACTIVE = 0;
final int PlotImpacts_CYCLES_PASSIVE = 1;
final int PlotImpacts_SUNPATH_ACTIVE = 2;
final int PlotImpacts_SUNPATH_PASSIVE = 3;
final int PlotImpacts_GLOBAL_ACTIVE = 4;
final int PlotImpacts_GLOBAL_PASSIVE = 5;
final int PlotImpacts_WIND_ACTIVE = 6;
final int PlotImpacts_WIND_PASSIVE = 7;
final int PlotImpacts_URBAN_ACTIVE = 8;
final int PlotImpacts_URBAN_PASSIVE = 9;

float CubePower = 16; //8;
float StarPower = 0.25;

final float FLOAT_e = 2.7182818284;

final double DOUBLE_r_Earth = 6367470.0; //6373000.0;
final float FLOAT_r_Earth = (float) DOUBLE_r_Earth;

float CrustDepth = 1000; // 1000m .The actual crust ranges from 5–70 km

float EyeLevel = 1.5; // 1.5 abouve ground - applied for setting cameras - intrenal!

float GlobalAlbedo = 0; // 0-100

float BIOSPHERE_drawResolution = 1; //2.5; // 5: 5 degrees

float Planetary_Magnification = 4.0; // <<<<<<<<<<

boolean FRAME_record_AUTO = false;
boolean FRAME_record_IMG = false;
boolean FRAME_click_IMG = false;
boolean FRAME_drag_IMG = false;

//-------------------------------

int CLIMATIC_SolarForecast = 0; //                                   Used for solar radiation only
int CLIMATIC_WeatherForecast = 0; // 0:linear 1:average 2:sky-based. Used for some parameters namely: air temperature, humidity

int SOLARCHVISION_automated = 0; //0: User interface, 1: Automatic

String[] skyScenario_Title = {
  "", "All", "Cloudy\nPattern", "Partly\nCloudy\nPattern", "Sunny\nPattern"
};
String[] skyScenario_FileTXT = {
  "", "", "Overcast sky", "Scattered sky", "Clear sky"
};

final int filter_HOURLY = 0;
final int filter_DAILY = 1;

int IMPACTS_displayDay = 0; // 0:total 1:day-1 2:day-2 etc.

final int numberOfLanguages = 2;
final int Language_EN = 0;
final int Language_FR = 1;
int Language_Active = Language_EN;

final float FLOAT_huge = 1000000000;
final float FLOAT_tiny = 0.05; // don't use very tiny values that could result is shading problems at the intersection of faces

final String STRING_undefined = "N/A";
final float FLOAT_undefined = 2000000000; // it must be a positive big number that is not included in any data
final float FLOAT_max_defined = 0.95 * FLOAT_undefined;

boolean is_defined (float a) {
  if (a < FLOAT_max_defined) {
    return true;
  }
  return false;
}

boolean is_undefined (float a) {
  return !is_defined(a);
}

PrintWriter[] FILE_outputRaw;
PrintWriter[] FILE_outputNorms;
PrintWriter[] FILE_outputProbs;

String[] Files_CLIMATE_TMYEPW;
String[] Files_CLIMATE_CWEEDS;
String[] Files_CLIMATE_CLMREC;
String[] Files_ENSEMBLE_OBSERVED;
String[] Files_ENSEMBLE_FORECAST;

String Folder_CLIMATE_TMYEPW;
String Folder_CLIMATE_CWEEDS;
String Folder_CLIMATE_CLMREC;
String Folder_ENSEMBLE_OBSERVED;
String Folder_ENSEMBLE_FORECAST;
String Folder_GEOMET;

String Folder_Coordinates;

String Folder_Land;
String Folder_People;
String Folder_Trees;
String Folder_Export;
String Folder_Project;
String Folder_Graphics;
String Folder_Export3D;
String Folder_ScreenShots;
String Folder_Shadings;

solarchvision_OperatingSystem OPESYS = new solarchvision_OperatingSystem();

solarchvision_TIME TIME = new solarchvision_TIME();

solarchvision_Functions funcs = new solarchvision_Functions();

solarchvision_UITASK UITASK = new solarchvision_UITASK();

int numberOfLayers = 0;

solarchvision_LAYER LAYER_ceilingsky = new solarchvision_LAYER(
  0.1,
  0,
  0,
  "m",
  "Ceiling height",
  "Hauteur sous plafond",
  ""
);

solarchvision_LAYER LAYER_cloudcover = new solarchvision_LAYER(
  10.0,
  0,
  0,
  "tenth",
  "Total Cloud Cover",
  "Couvert nuageux total",
  "TCDC"
);

solarchvision_LAYER LAYER_winddir = new solarchvision_LAYER(
  100.0 / 360.0,
  0,
  0,
  "°",
  "Surface Wind Direction",
  "Direction du vent à la surface",
  "WDIR-SFC"
);

solarchvision_LAYER LAYER_windspd = new solarchvision_LAYER(
  2.5,
  0,
  0,
  "km/h",
  "Surface Wind Speed",
  "Vitesse du vent à la surface",
  "WIND-SFC"
);

solarchvision_LAYER LAYER_pressure = new solarchvision_LAYER(
  2.0,
  -1000,
  1,
  "hPa",
  "Mean Sea level Pressure",
  "Pression moyenne au niveau de la mer",
  "MSLP"
);

solarchvision_LAYER LAYER_drybulb = new solarchvision_LAYER(
  2.5,
  0,
  1,
  "°C",
  "Surface Air Temperature",
  "Température de l'air à la surface",
  "TMP-SFC"
);

solarchvision_LAYER LAYER_relhum = new solarchvision_LAYER(
  1.0,
  0,
  0,
  "%",
  "Surface Relative Humidity",
  "Humidité relative à la surface",
  "RELH-SFC"
);

solarchvision_LAYER LAYER_dirnorrad = new solarchvision_LAYER(
  0.1,
  0,
  0,
  "W/m²",
  "Direct normal radiation",
  "Rayonnement direct normal",
  ""
);

solarchvision_LAYER LAYER_difhorrad = new solarchvision_LAYER(
  0.1,
  0,
  0,
  "W/m²",
  "Diffuse horizontal radiation",
  "Diffus rayonnement horizontal",
  ""
);

solarchvision_LAYER LAYER_glohorrad = new solarchvision_LAYER(
  0.1,
  0,
  0,
  "W/m²",
  "Global horizontal radiation",
  "Rayonnement global horizontal",
  ""
);

solarchvision_LAYER LAYER_direffect = new solarchvision_LAYER(
  0.0025,
  0,
  1,
  "W°C/m²",
  "Direct normal effect <18°C<",
  "Effet direct normal <18°C<",
  ""
);

solarchvision_LAYER LAYER_difeffect = new solarchvision_LAYER(
  0.0025,
  0,
  1,
  "W°C/m²",
  "Diffuse normal effect <18°C<",
  "Effet diffus normal <18°C<",
  ""
);

solarchvision_LAYER LAYER_precipitation = new solarchvision_LAYER(
  4.0,
  0,
  0,
  "mm",
  "Surface Accumulated Precipitation",
  "Précipitations accumulées à la surface",
  "APCP-SFC"
);

solarchvision_LAYER LAYER_developed = new solarchvision_LAYER(
  1,
  0,
  0,
  "",
  "",
  "",
  ""
);

solarchvision_LAYER[] allLayers = {
  LAYER_ceilingsky,
  LAYER_cloudcover,
  LAYER_winddir,
  LAYER_windspd,
  LAYER_pressure,
  LAYER_drybulb,
  LAYER_relhum,
  LAYER_dirnorrad,
  LAYER_difhorrad,
  LAYER_glohorrad,
  LAYER_direffect,
  LAYER_difeffect,
  LAYER_precipitation,
  LAYER_developed
};

int DevelopLayer_id = 0;
int CurrentLayer_id = 0;
String CurrentLayer_unit = allLayers[0].unit;
String CurrentLayer_name = allLayers[0].name;
String[] CurrentLayer_descriptions = {allLayers[0].descriptions[Language_EN],
                                      allLayers[0].descriptions[Language_FR]};

void changeCurrentLayerTo (int new_id) {

  STUDY.V_scale = allLayers[new_id].V_scale;
  STUDY.V_offset = allLayers[new_id].V_offset;
  STUDY.V_belowLine = allLayers[new_id].V_belowLine;

  DevelopLayer_id = new_id;
  CurrentLayer_id = new_id;

  CurrentLayer_unit = allLayers[new_id].unit;
  CurrentLayer_name = allLayers[new_id].name;
  CurrentLayer_descriptions[Language_EN] = allLayers[new_id].descriptions[Language_EN];
  CurrentLayer_descriptions[Language_FR] = allLayers[new_id].descriptions[Language_FR];

}

int ENSEMBLE_FORECAST_maxDays = 16; // Constant
int ENSEMBLE_OBSERVED_maxDays = 3; // Variable

int CLIMATE_TMYEPW_start = 1;
int CLIMATE_TMYEPW_end = 1;

int CLIMATE_CWEEDS_start = 1970;
int CLIMATE_CWEEDS_end = 2017;

int CLIMATE_CLMREC_start = 2000;
int CLIMATE_CLMREC_end = year();

int ENSEMBLE_FORECAST_start = 1;
int ENSEMBLE_FORECAST_end = 43; // NAEFS:1-43, Note we will append REPS/HRDPS or other scenarions at the end  of this list

int ENSEMBLE_OBSERVED_numNearest = 3;  // <<<<<<<<

int ENSEMBLE_OBSERVED_start = 1;
int ENSEMBLE_OBSERVED_end = ENSEMBLE_OBSERVED_numNearest;

int[] nearest_Station_ENSEMBLE_OBSERVED_id = new int [ENSEMBLE_OBSERVED_numNearest];
float[] nearest_Station_ENSEMBLE_OBSERVED_dist = new float [ENSEMBLE_OBSERVED_numNearest];

int nearest_Station_CLMREC_id = -1;
float nearest_Station_CLMREC_dist = FLOAT_undefined;

int SampleYear_Start = 1980;
int SampleYear_End = year();

int SampleMember_Start = 1;
int SampleMember_End = 43;

int SampleStation_Start = 1;
int SampleStation_End = ENSEMBLE_OBSERVED_numNearest;

float[][][][] CLIMATE_TMYEPW_values;
boolean[][][][] CLIMATE_TMYEPW_flags;

float[][][][] CLIMATE_CWEEDS_values;
boolean[][][][] CLIMATE_CWEEDS_flags;

float[][][][] CLIMATE_CLMREC_values;
boolean[][][][] CLIMATE_CLMREC_flags;

float[][][][] ENSEMBLE_FORECAST_values;
boolean[][][][] ENSEMBLE_FORECAST_flags;

float[][][][] ENSEMBLE_OBSERVED_values;
boolean[][][][] ENSEMBLE_OBSERVED_flags;

boolean CLIMATE_TMYEPW_load = true;
boolean CLIMATE_CWEEDS_load = false;
boolean CLIMATE_CLMREC_load = false;
boolean ENSEMBLE_FORECAST_load = false;
boolean ENSEMBLE_OBSERVED_load = false;

final int DEV_WindPower = 0;
final int DEV_RadiationOnTracker = 1;
final int DEV_RadiationOnSurface = 2;
final int DEV_RadiationOnSouth = 3;
final int DEV_RadiationOnEast = 4;
final int DEV_RadiationOnNorth = 5;
final int DEV_RadiationOnWest = 6;
final int DEV_RadiationOnSE = 7;
final int DEV_RadiationOnNE = 8;
final int DEV_RadiationOnNW = 9;
final int DEV_RadiationOnSW = 10;
int numberOfDevelopedLayers = 11;

int Develop_Option = DEV_WindPower;
int Develop_DayHour = 0; //0:accumulative 1:daily(24h) 2:per12h 3:per6h <should be zero to work well with current menues>

boolean DevelopData_update = true;

float Develop_AngleInclination = 45; // 90 = horizontal surface, 0 = Vertical surface
float Develop_AngleOrientation = 0; // 0 = South, 90 = East

solarchvision_SHADE SHADE = new solarchvision_SHADE();

solarchvision_WIN3D WIN3D = new solarchvision_WIN3D();

solarchvision_WORLD WORLD = new solarchvision_WORLD();

solarchvision_STUDY STUDY = new solarchvision_STUDY();

solarchvision_ROLLOUT ROLLOUT = new solarchvision_ROLLOUT();

float[][]   VertexSolar_XYZ;
float[][][] VertexSolar_amounts;

boolean VertexSolar_rebuild_array = true;
boolean GlobalSolar_rebuild_array = true;

float[][][][] GlobalSolar;

int SavedScreenShots = 0;

String createStamp (int increment, String CLASS_STAMP) {

  SavedScreenShots += increment;

  String txt = "";

  if (CLASS_STAMP == "WIN3D") {
    txt += "CAM" + nf(WIN3D.currentCamera, 2) + "_";
  }
  else {
    txt += "IMG" + nf(SavedScreenShots, 4) + "_";
  }

  txt += STATION.getCity() + "_";

  if (IMPACTS_displayDay != 0) {
    txt += TIME.getMM((IMPACTS_displayDay - 1) * STUDY.perDays + 286 + TIME.beginDay);
  }
  else {
    txt += TIME.getMM( STUDY.j_Start    * STUDY.perDays + 286 + TIME.beginDay) + "-" +
           TIME.getMM((STUDY.j_End - 1) * STUDY.perDays + 286 + TIME.beginDay);
  }

  return txt;
}

void SOLARCHVISION_RecordFrame () {

  saveFrame(Folder_ScreenShots + "/" + createStamp(1, "Screen") + ".jpg");
}

String MAKE_Filename (String beginName) {

  String My_Filenames = Folder_ScreenShots + "/" + beginName;

  return My_Filenames;
}

String MAKE_MainName () {

  String s = "";

  if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) s = nf(TIME.year, 2) + nf(TIME.month, 2) + nf(TIME.day, 2) + "_" + nf(STUDY.j_End, 0) + "dayFORECAST_";

  return s;
}

String getFilename_SolidImpact () {

  return Folder_Graphics + "/" + nf(TIME.year, 2) + "-" + nf(TIME.month, 2) + "-" + nf(TIME.day, 2) + "/" + databaseString[CurrentDataSource] + "/Impacts/Solid" + nf(allSolidImpacts.sectionType, 0) + "h" + nf(int(funcs.roundTo(allSolidImpacts.Z[allSolidImpacts.sectionType], 1)), 4) + "r" + nf(int(funcs.roundTo(allSolidImpacts.R[allSolidImpacts.sectionType], 1)), 3) + "p" + nf(allSolidImpacts.Power, 2, 2).replace(".", "_") + "m" + nf(allSolidImpacts.Grade, 2, 2).replace(".", "_");
}

String getFilename_SolarImpact () {

  return Folder_Graphics + "/" + nf(TIME.year, 2) + "-" + nf(TIME.month, 2) + "-" + nf(TIME.day, 2) + "/" + databaseString[CurrentDataSource] + "/Impacts/Solar" + nf(allSolarImpacts.sectionType, 0) + "h" + nf(int(funcs.roundTo(allSolarImpacts.Z, 1)), 4) + "r" + nf(int(funcs.roundTo(allSolarImpacts.R, 1)), 3);
}

float HeightAboveGround = 0; //2.5; // <<<<<<<<<

float LocationLAT = 0.0;
float LocationLON = 0.0;
float LocationELE = 0.0;

int save_frame_number = 0;

int COLOR_STYLE_Current = 0;
int COLOR_STYLE_Number = 20; //6;

final int dataID_ENSEMBLE_OBSERVED = 0;
final int dataID_ENSEMBLE_FORECAST = 1;
final int dataID_CLIMATE_CWEEDS = 2;
final int dataID_CLIMATE_CLMREC = 3;
final int dataID_CLIMATE_TMYEPW = 4;
final int MAXIMUM_dataID = dataID_CLIMATE_TMYEPW;

int CurrentDataSource = dataID_CLIMATE_TMYEPW;

final String[] databaseString = {
  "SWOB", "NAEFS", "CWEEDS", "CLMREC", "TMY"
};

int DrawnFrame = 0;

int SOLARCHVISION_X_clicked = -1;
int SOLARCHVISION_Y_clicked = -1;

int SOLARCHVISION_X_click1 = -1;
int SOLARCHVISION_Y_click1 = -1;
int SOLARCHVISION_X_click2 = -1;
int SOLARCHVISION_Y_click2 = -1;

int Camera_Variation = 0; // 1;

solarchvision_Materials allMaterials = new solarchvision_Materials();

solarchvision_Faces allFaces = new solarchvision_Faces();

solarchvision_Polylines allPolylines = new solarchvision_Polylines();

solarchvision_Groups allGroups = new solarchvision_Groups();

solarchvision_SolidImpacts allSolidImpacts = new solarchvision_SolidImpacts();

solarchvision_SolarImpacts allSolarImpacts = new solarchvision_SolarImpacts();

solarchvision_Edit3D Edit3D = new solarchvision_Edit3D();

solarchvision_Scale3D Scale3D = new solarchvision_Scale3D();

solarchvision_Rotate3D Rotate3D = new solarchvision_Rotate3D();

solarchvision_Move3D Move3D = new solarchvision_Move3D();

solarchvision_Drop3D Drop3D = new solarchvision_Drop3D();

solarchvision_Clone3D Clone3D = new solarchvision_Clone3D();

solarchvision_Delete3D Delete3D = new solarchvision_Delete3D();

solarchvision_Select3D Select3D = new solarchvision_Select3D();

float[][] saved_BoundingBox = Select3D.BoundingBox;

int saved_alignX = Select3D.alignX;
int saved_alignY = Select3D.alignY;
int saved_alignZ = Select3D.alignZ;

int addNewSelectionToPreviousSelection = 0; // internal

boolean addToLastGroup = false; // internal

float pre_TIME_Date;
int pre_TIME_Hour;
int pre_TIME_Day;
int pre_TIME_Month;
int pre_TIME_Year;

int pre_SampleYear_Start;
int pre_SampleYear_End;
int pre_SampleMember_Start;
int pre_SampleMember_End;
int pre_SampleStation_Start;
int pre_SampleStation_End;

int pre_STUDY_joinDays;
int pre_STUDY_i_Start;
int pre_STUDY_i_End;
int pre_STUDY_j_End;
int pre_STUDY_Setup;

int pre_IMPACTS_displayDay;
int pre_CurrentDataSource;

int pre_CLIMATIC_SolarForecast;
int pre_CLIMATIC_WeatherForecast;

boolean pre_CLIMATE_TMYEPW_load;
boolean pre_CLIMATE_CWEEDS_load;
boolean pre_CLIMATE_CLMREC_load;
boolean pre_ENSEMBLE_FORECAST_load;
boolean pre_ENSEMBLE_OBSERVED_load;

boolean pre_Land3D_loadMesh;
boolean pre_Land3D_loadTextures;

float pre_LocationLAT;
float pre_LocationLON;

boolean pre_WORLD_autoView;

boolean pre_Selection_Model1D_displayEdges;
boolean pre_Selection_Model2D_displayEdges;

boolean pre_Selection_Solid_displayEdges;
boolean pre_Selection_Section_displayEdges;
boolean pre_Selection_Camera_displayEdges;

boolean pre_Selection_LandPoint_displayPoints;

float pre_Selection_softPower;
float pre_Selection_softRadius;

float pre_Selection_posValue;
float pre_Selection_rotValue;
float pre_Selection_scaleValue;

int pre_Selection_alignX;
int pre_Selection_alignY;
int pre_Selection_alignZ;

boolean pre_Selection_displayReferencePivot;

boolean pre_Selection_Group_displayPivot;
boolean pre_Selection_Group_displayEdges;
boolean pre_Selection_Group_displayBox;

boolean pre_Selection_Face_displayEdges;
boolean pre_Selection_Face_displayVertexCount;
boolean pre_Selection_Polyline_displayVertexCount;
boolean pre_Selection_Vertex_displayVertices;
boolean pre_Selection_Polyline_displayVertices;

int pre_WIN3D_currentCamera;

int pre_WIN3D_FacesShade;

int pre_Create3D_Tessellation;

boolean pre_allPoints_displayAll;
boolean pre_allFaces_displayEdges;
boolean pre_allFaces_displayNormals;

int pre_Develop_Option;

int pre_STUDY_ImpactLayer;
int pre_STUDY_CurrentLayer_id;

int pre_STUDY_SkyScenario;
int pre_STUDY_PlotImpacts;

int pre_allSolids_pallet_CLR;
int pre_allSolids_pallet_DIR;
float pre_allSolids_pallet_MLT;

float pre_allSolidImpacts_Grade;
float pre_allSolidImpacts_Power;
float[] pre_allSolidImpacts_Rotation = {
  0, 0, 0, 0
};
float[] pre_allSolidImpacts_Elevation = {
  0, 0, 0, 0
};
float[] pre_allSolidImpacts_U_scale = {
  0, 0, 0, 0
};
float[] pre_allSolidImpacts_V_scale = {
  0, 0, 0, 0
};
float[] pre_allSolidImpacts_sU_offset = {
  0, 0, 0, 0
};
float[] pre_allSolidImpacts_sV_offset = {
  0, 0, 0, 0
};

float pre_allSolidImpacts_Wspd;
float pre_allSolidImpacts_Wdir;

boolean pre_allSolidImpacts_displayPoints;
boolean pre_allSolidImpacts_displayLines;

int pre_allSolidImpacts_Process_subDivisions;

boolean pre_WindFlow_display;

float pre_USER_create_powAll;

void SOLARCHVISION_find_which_bakings_to_regenerate () {

  if (WIN3D.FacesShade == SHADE.Global_Solar) {
    GlobalSolar_rebuild_array = true;
  }
  if (WIN3D.FacesShade == SHADE.Vertex_Solar) {
    VertexSolar_rebuild_array = true;
  }
  if (allSolarImpacts.displayImage) {
    allSolarImpacts.rebuild_Image_array = true;
  }
  if (allWindRoses.displayImage) {
    allWindRoses.rebuild_Image_array = true;
  }
}

void SOLARCHVISION_regenerate_desired_bakings () {

  if (VertexSolar_rebuild_array) {
    SOLARCHVISION_calculate_VertexSolar_array();
  }

  if (GlobalSolar_rebuild_array) {
    SOLARCHVISION_calculate_GlobalSolar_array();
  }

}

solarchvision_PAINT PAINT = new solarchvision_PAINT();

int STAT_N_MidLow = 0;
int STAT_N_Middle = 1;
int STAT_N_MidHigh = 2;

int STAT_N_M25 = 3;
int STAT_N_M50 = 4;
int STAT_N_M75 = 5;

int STAT_N_Min = 6;
int STAT_N_Ave = 7;
int STAT_N_Max = 8;

String[] STAT_N_Title = {
  "Mid-Low",
  "Middle",
  "Mid-High",

  "25th Percentile",
  "50th P.(Median)",
  "75th Percentile",

  "Minimum",
  "Average",
  "Maximum"
};

int ViewLayout = 0;

void SOLARCHVISION_update_frame_layout () {

  if (ViewLayout == 0) {

    STUDY.include = true;
    WIN3D.include = true;
    WORLD.include = true;

    WIN3D.cX = SOLARCHVISION_pixel_W;;
    WIN3D.cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 0;
    WIN3D.dX = SOLARCHVISION_pixel_W;
    WIN3D.dY = SOLARCHVISION_pixel_H;
    WIN3D.view_R = float(WIN3D.dY) / float(WIN3D.dX);
    WIN3D.graphics = createGraphics(WIN3D.dX, WIN3D.dY, P3D);

    WORLD.cX = 0;
    WORLD.cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 0;
    WORLD.dX = SOLARCHVISION_pixel_W;
    WORLD.dY = SOLARCHVISION_pixel_H;
    WORLD.graphics = createGraphics(WORLD.dX, WORLD.dY, P2D);

    STUDY.cX = 0;
    STUDY.cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + SOLARCHVISION_pixel_H;
    STUDY.dX = 2 * SOLARCHVISION_pixel_W;
    STUDY.dY = 1 * SOLARCHVISION_pixel_H;
    STUDY.view_R = float(STUDY.dY) / float(STUDY.dX);
    STUDY.graphics = createGraphics(STUDY.dX, STUDY.dY, P2D);
  } else if (ViewLayout == 1) {

    STUDY.include = false;
    WIN3D.include = true;
    WORLD.include = false;

    WIN3D.cX = 0;
    WIN3D.cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 0;
    WIN3D.dX = 2 * SOLARCHVISION_pixel_W;
    WIN3D.dY = 2 * SOLARCHVISION_pixel_H;
    WIN3D.view_R = float(WIN3D.dY) / float(WIN3D.dX);
    WIN3D.graphics = createGraphics(WIN3D.dX, WIN3D.dY, P3D);
  } else if (ViewLayout == 2) {

    STUDY.include = true;
    WIN3D.include = false;
    WORLD.include = false;

    STUDY.cX = 0;
    STUDY.cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 0;
    STUDY.dX = 2 * SOLARCHVISION_pixel_W;
    STUDY.dY = 2 * SOLARCHVISION_pixel_H;
    STUDY.view_R = float(STUDY.dY) / float(STUDY.dX);
    STUDY.graphics = createGraphics(STUDY.dX, STUDY.dY, P2D);
  } else if (ViewLayout == 3) {

    STUDY.include = false;
    WIN3D.include = false;
    WORLD.include = true;

    WORLD.cX = 0;
    WORLD.cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 0;
    WORLD.dX = 2 * SOLARCHVISION_pixel_W;
    WORLD.dY = 2 * SOLARCHVISION_pixel_H;
    WORLD.graphics = createGraphics(WORLD.dX, WORLD.dY, P2D);
  }

  WORLD.revise();
  WIN3D.revise();
  STUDY.revise();
}

void keyPressed (KeyEvent e) {

  //println("key: " + key);
  //println("keyCode: " + keyCode);

  if (frameCount > Last_initializationStep) {

    if (SOLARCHVISION_automated == 0) {
      SOLARCHVISION_X_clicked = -1;
      SOLARCHVISION_Y_clicked = -1;

      if ((UI_menuBar.selected_parent != -1) || (UI_menuBar.selected_child != 0)) {

        UI_menuBar.selected_parent = -1;
        UI_menuBar.selected_child = 0;

        image(pre_screen, 0, SOLARCHVISION_pixel_A);
      }

      addNewSelectionToPreviousSelection = 0;

      if (typeUserCommand == 0) {

        UI_commandBar.updated();

        STUDY.keyPressed(e);
        WORLD.keyPressed(e);
        WIN3D.keyPressed(e);
      }
      else {

        UI_commandBar.revise();

        COMIN_keyPressed(e);
      }

      if ((e.isAltDown() != true) && (e.isControlDown() != true)) {

        if (key != CODED) {
          switch(key) {

            case TAB:
              if (e.isShiftDown() != true) {
                typeUserCommand = (typeUserCommand + 1) % 2;
                UI_commandBar.revise();
              }
              break;
          }

          if(key == ESC) {
            key = 0; // Overrides the default ESC key behavior that exits a Processing sketch
          }

        }
      }

      if ((STUDY.update) || (WORLD.update) || (WIN3D.update) || (ROLLOUT.update)) redraw();
    }
  }
}

void keyReleased () {

  addNewSelectionToPreviousSelection = 0;
}

PrintWriter mtlOutput;
PrintWriter objOutput;

int obj_lastVertexNumber;
int obj_lastVtextureNumber;
int obj_lastFaceNumber;
int obj_lastGroupNumber;

int num_vertices_added = 0;

void SOLARCHVISION_OBJprintVertex (float x, float y, float z) {

  float a = x * User3D.export_Scale;
  float b = y * User3D.export_Scale;
  float c = z * User3D.export_Scale;

  if (User3D.export_FlipZYaxis == 0) {

    objOutput.println("v " + nf(a, 0, User3D.export_PrecisionVertex) + " " +  nf(b, 0, User3D.export_PrecisionVertex) + " " +  nf(c, 0, User3D.export_PrecisionVertex));
  } else {

    objOutput.println("v " + nf(-a, 0, User3D.export_PrecisionVertex) + " " +  nf(c, 0, User3D.export_PrecisionVertex) + " " +  nf(b, 0, User3D.export_PrecisionVertex));
  }
}

void SOLARCHVISION_OBJprintVtexture (float u, float v, float w) {

  objOutput.println("vt " + nf(u, 0, User3D.export_PrecisionVtexture) + " " + nf(v, 0, User3D.export_PrecisionVtexture) + " " + nf(w, 0, User3D.export_PrecisionVtexture));
}

void SOLARCHVISION_HTMLprintVtexture (float u, float v) {

  htmlOutput.print(nf(u, 0, User3D.export_PrecisionVtexture) + " " + nf(v, 0, User3D.export_PrecisionVtexture));
}

String importedObjectName = "";

void SOLARCHVISION_deleteAll () {

  allModel1Ds.makeEmpty(0);
  allModel2Ds.makeEmpty(0);

  allPolylines.makeEmpty(0);
  allFaces.makeEmpty(0);

  allPoints.makeEmpty(0);

  allSolids.makeEmpty(0);
  allSections.makeEmpty(0);
  allCameras.makeEmpty(0);

  allGroups.makeEmpty(0);

}

void SOLARCHVISION_model_added () {

  Select3D.selectLast();

  SOLARCHVISION_selection_changed();
}

void SOLARCHVISION_model_changed () {
  SOLARCHVISION_view_changed();
}

void SOLARCHVISION_view_changed () {
  WIN3D.revise();
}

void SOLARCHVISION_selection_changed () {

  Select3D.reset_selectedRefValues();

  Select3D.revise_BoundingBox();

  SOLARCHVISION_view_changed();
}

void SOLARCHVISION_switch_category (int a) {

  current_ObjectCategory = a;

  UI_toolBar.revise();

  SOLARCHVISION_selection_changed();
}

float OBJECTS_scale = 1.0;

int SKY2D_X_View = 50;
int SKY2D_Y_View = 50;
float SKY2D_ZOOM = 5;
PGraphics SKY2D_graphics;

int getLocationTimeZone () {
  return int(funcs.roundTo(STATION.getLongitude() / 15, 15));
}

solarchvision_Tropo3D Tropo3D = new solarchvision_Tropo3D();

solarchvision_Sky3D Sky3D = new solarchvision_Sky3D();

solarchvision_Sun3D Sun3D = new solarchvision_Sun3D();

solarchvision_Moon3D Moon3D = new solarchvision_Moon3D();

solarchvision_Earth3D Earth3D = new solarchvision_Earth3D();

solarchvision_Land3D Land3D = new solarchvision_Land3D();

solarchvision_Model1Ds allModel1Ds = new solarchvision_Model1Ds();

solarchvision_Model2Ds allModel2Ds = new solarchvision_Model2Ds();

solarchvision_Solids allSolids = new solarchvision_Solids();

float[][] allVertices = new float[0][3];
// to increase performance we defined vertices array outside Points class
solarchvision_Points allPoints = new solarchvision_Points();

solarchvision_User3D User3D = new solarchvision_User3D();

solarchvision_Modify3D Modify3D = new solarchvision_Modify3D();

solarchvision_Create3D Create3D = new solarchvision_Create3D();

solarchvision_Cameras allCameras = new solarchvision_Cameras();

solarchvision_Sections allSections = new solarchvision_Sections();

solarchvision_WindRose allWindRoses = new solarchvision_WindRose();

solarchvision_WindFlow allWindFlows = new solarchvision_WindFlow();

void VertexSolar_resize_array () { // called when STUDY.j_End changes

  VertexSolar_XYZ     = new float [0][3];
  VertexSolar_amounts = new float [2][1 + STUDY.j_End - STUDY.j_Start][0];

  VertexSolar_rebuild_array = false;
}

float[][] skyVertices = new float [0][3];
int[][] skyFaces = new int [0][1];

int POINTER_TempObjectVertices = 0;
int POINTER_TempObjectFaces = 0;

float[][] TempObjectVertices = new float [0][3];
int[][] TempObjectFaces = new int [0][1];

int mouseWheelConsume = 0;
int dragging_started = 0;

void SOLARCHVISION_update_project_info (File selectedFile) {

  ProjectName = selectedFile.getName().replace(".xml", "").replace(".XML", ""); // should work most of the times!
  Folder_Project =  selectedFile.getAbsolutePath().replace(char(92), '/').replace("/" + selectedFile.getName(), "");

  println("New ProjectName:", ProjectName);
  println("New Folder_Project:", Folder_Project);
}

void SOLARCHVISION_fileSelected_New (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
  } else {
    Filename = selectedFile.getAbsolutePath().replace(char(92), '/');

    println("New project:", Filename);

    SOLARCHVISION_update_project_info(selectedFile);
  }
}

void SOLARCHVISION_fileSelected_Open (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
  } else {
    Filename = selectedFile.getAbsolutePath().replace(char(92), '/');

    println("Loading:", Filename);

    noLoop();

    SOLARCHVISION_load_project(Filename);

    SOLARCHVISION_update_project_info(selectedFile);

    loop();
  }
}

void SOLARCHVISION_fileSelected_SaveAs (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
  } else {
    Filename = selectedFile.getAbsolutePath().replace(char(92), '/');

    println("Saving to:", Filename);

    SOLARCHVISION_update_project_info(selectedFile);

    SOLARCHVISION_save_project(Filename);
  }
}

void SOLARCHVISION_SelectFile_Import_3DModel (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
  } else {
    Filename = selectedFile.getAbsolutePath().replace(char(92), '/');

    if (allGroups.num == 0) {
      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    println("Importing:", Filename);

    int number_of_allGroups_before = allGroups.num;

    //SOLARCHVISION_import_objects_OBJ(Filename, -1,0,0,1,0,0, 0,0,0, 1,1,1); // different objects: different materials
    SOLARCHVISION_import_objects_OBJ(Filename, User3D.default_Material, User3D.default_Tessellation, User3D.default_Layer, User3D.default_Visibility, User3D.default_Weight, User3D.default_Closed, 0, 0, 0, 1, 1, 1); // apply default material

    int number_of_allGroups_after = allGroups.num;

    Select3D.Group_ids = new int [1 + number_of_allGroups_after - number_of_allGroups_before];
    for (int i = 0; i < Select3D.Group_ids.length - 1; i++) {
      Select3D.Group_ids[i] = i + number_of_allGroups_before;
      //println(Select3D.Group_ids[i]);
    }

    SOLARCHVISION_switch_category(ObjectCategory.GROUP);
  }
}

void SOLARCHVISION_SelectFile_Execute_CommandFile (File selectedFile) {

  String Filename = "";

  if (selectedFile == null) {
  } else {
    Filename = selectedFile.getAbsolutePath().replace(char(92), '/');

    println("Executing:", Filename);

    SOLARCHVISION_execute_commands_TXT(Filename);
  }
}

boolean isInside (float x, float y, float x1, float y1, float x2, float y2) {
  if ((x1 < x) && (x < x2) && (y1 < y) && (y < y2)) {
    return true;
  }
  return false;
}

String NearLatitude_Stamp () {

  int Round_Latitude = int(funcs.roundTo(STATION.getLatitude(), 1));

  String a = nf(abs(Round_Latitude), 2);

  if (Round_Latitude < 0) a += "S";
  else a += "N";

  return a;
}

String Section_Stamp () {

  String s = "";

  s += "t" + nf(allSolidImpacts.sectionType, 0);
  s += "u" + nf(allSolarImpacts.X, 0, 3);
  s += "v" + nf(allSolarImpacts.Y, 0, 3);
  s += "w" + nf(allSolarImpacts.Z, 0, 3);
  s += "r" + nf(allSolarImpacts.R, 0, 3);

  s = s.replace('.', 'p');
  s = s.replace('-', 'n');

  return s;
}

String Viewport_Stamp () {

  String s = "";

  /*

  s += "x" + nf(WIN3D.position_X, 0, 3);
  s += "y" + nf(WIN3D.position_Y, 0, 3);
  s += "z" + nf(WIN3D.position_Z, 0, 3);

  s += "rx" + nf(WIN3D.rotation_X, 0, 3);
  s += "ry" + nf(WIN3D.rotation_Y, 0, 3);
  s += "rz" + nf(WIN3D.rotation_Z, 0, 3);

  s = s.replace('.', 'p');
  s = s.replace('-', 'n');

  */

  return s;
}

int UI_X_moved = -1;
int UI_Y_moved = -1;

PImage pre_screen;

void SOLARCHVISION_modify_Viewport_Title () {

  String s = "Cam" + nf(WIN3D.currentCamera, 2);

  UI_toolBar.Items[0][11] = s; // <<<<< Note: 3DViewPoint is the first index on BAR_b
  UI_toolBar.highlight(s);

  UI_toolBar.revise();
}

float[][] DiffuseVectors;

float X_control;
float Y_control;

solarchvision_UI_menuBar UI_menuBar = new solarchvision_UI_menuBar();

solarchvision_UI_toolBar UI_toolBar = new solarchvision_UI_toolBar();

solarchvision_UI_commandBar UI_commandBar = new solarchvision_UI_commandBar();

solarchvision_UI_caseBar UI_caseBar = new solarchvision_UI_caseBar();

String[] allCommands = {"SOLARCHVISION Command Input:", ""};
String[] allMessages = {"SOLARCHVISION Command Output:", ""};

int typeUserCommand = 0;

solarchvision_STATION[] TMYEPW_Coordinates;

void inputCoordinates_TMYEPW () {

  String[] FileALL = loadStrings(Folder_Coordinates + "/TMYEPW.txt");

  String lineSTR;

  int num_stn = FileALL.length - 1; // to skip the first description line

  TMYEPW_Coordinates = new solarchvision_STATION [num_stn];

  for (int f = 0; f < num_stn; f++) {
    lineSTR = FileALL[f + 1]; // to skip the first description line

    String[] parts = split(lineSTR, ",");

    TMYEPW_Coordinates[f] = new solarchvision_STATION();

    TMYEPW_Coordinates[f].setCity(parts[1]);
    TMYEPW_Coordinates[f].setProvince(parts[2]);
    TMYEPW_Coordinates[f].setCountry(parts[3]);
    TMYEPW_Coordinates[f].setLatitude(float(parts[6]));
    TMYEPW_Coordinates[f].setLongitude(float(parts[7]));
    TMYEPW_Coordinates[f].setTimelong(float(parts[8]) * 15);
    TMYEPW_Coordinates[f].setElevation(float(parts[9]));
    TMYEPW_Coordinates[f].setFilename_TMYEPW(parts[10]);
  }
}

solarchvision_STATION[] CWEEDS_coordinates;

void inputCoordinates_CWEEDS () {

  String[] FileALL = loadStrings(Folder_Coordinates + "/CWEEDS.txt");

  String lineSTR;

  int num_stn = FileALL.length - 1; // to skip the first description line

  CWEEDS_coordinates = new solarchvision_STATION [num_stn];

  for (int f = 0; f < num_stn; f++) {
    lineSTR = FileALL[f + 1]; // to skip the first description line

    String[] parts = split(lineSTR, ',');

    float latitude = float(parts[5]);
    float longitude = float(parts[6]);

    CWEEDS_coordinates[f] = new solarchvision_STATION();

    CWEEDS_coordinates[f].setCity(parts[1]);
    CWEEDS_coordinates[f].setProvince(parts[2]);
    CWEEDS_coordinates[f].setCountry(parts[3]);
    CWEEDS_coordinates[f].setLatitude(latitude);
    CWEEDS_coordinates[f].setLongitude(longitude);
    CWEEDS_coordinates[f].setTimelong(float(parts[7]));
    CWEEDS_coordinates[f].setElevation(float(parts[8]));
    CWEEDS_coordinates[f].setFilename_CWEEDS(parts[9]);
  }
}

solarchvision_STATION[] CLMREC_Coordinates;

void inputCoordinates_CLMREC () {

  String[] FileALL = loadStrings(Folder_Coordinates + "/CLMREC.txt");

  String lineSTR;

  int num_stn = FileALL.length - 1; // to skip the first description line

  CLMREC_Coordinates = new solarchvision_STATION [num_stn];

  for (int f = 0; f < num_stn; f++) {
    lineSTR = FileALL[f + 1]; // to skip the first description line

    String[] parts = split(lineSTR, ",");

    CLMREC_Coordinates[f] = new solarchvision_STATION();

    float latitude = float(parts[6]);
    float longitude = float(parts[7]);

    CLMREC_Coordinates[f].setCity(parts[0].replace('/', '_'));
    CLMREC_Coordinates[f].setProvince(parts[1]);
    CLMREC_Coordinates[f].setCountry("CA");
    CLMREC_Coordinates[f].setLatitude(latitude);
    CLMREC_Coordinates[f].setLongitude(longitude);
    CLMREC_Coordinates[f].setTimelong(funcs.roundTo(longitude, 15));
    CLMREC_Coordinates[f].setElevation(float(parts[10]));
    //CLMREC_Coordinates[f].setFilename_CLMREC(?);
  }
}

solarchvision_STATION[] SWOB_Coordinates;

void inputCoordinates_SWOB () {

  String[] FileALL = loadStrings(Folder_Coordinates + "/SWOB.txt");

  String lineSTR;

  int num_stn = FileALL.length - 1; // to skip the first description line

  SWOB_Coordinates = new solarchvision_STATION [num_stn];

  for (int f = 0; f < num_stn; f++) {
    lineSTR = FileALL[f + 1]; // to skip the first description line

    String[] parts = split(lineSTR, '\t');

    float latitude = float(parts[5]);
    float longitude = float(parts[6]);

    SWOB_Coordinates[f] = new solarchvision_STATION();

    String code = parts[8];
    if (parts[4].equals("Manned")) code += "-MAN";
    if (parts[4].equals("Auto")) code += "-AUTO";

    SWOB_Coordinates[f].setCode(code);
    SWOB_Coordinates[f].setCity(parts[2]);
    SWOB_Coordinates[f].setProvince(parts[3]);
    SWOB_Coordinates[f].setCountry("CA");
    SWOB_Coordinates[f].setLatitude(latitude);
    SWOB_Coordinates[f].setLongitude(longitude);
    SWOB_Coordinates[f].setTimelong(funcs.roundTo(longitude, 15));
    SWOB_Coordinates[f].setElevation(float(parts[7]));
    //SWOB_Coordinates[f].setFilename_SWOB(?);

  }
}

solarchvision_STATION[] NAEFS_Coordinates;

void inputCoordinates_NAEFS () {

  String[] FileALL = loadStrings(Folder_Coordinates + "/NAEFS.txt");

  String lineSTR;

  int num_stn = FileALL.length - 1; // to skip the first description line

  NAEFS_Coordinates = new solarchvision_STATION [num_stn];

  for (int f = 0; f < num_stn; f++) {
    lineSTR = FileALL[f + 1]; // to skip the first description line

    String[] parts = split(lineSTR, '\t');

    String filename = parts[0];

    String city = split(filename, '_')[0];
    String province = split(filename, '_')[1];
    String country = split(filename, '_')[2];

    float latitude = 0;
    float longitude = 0;
    float elevation = 0;

    int l = 0;

    l = parts[1].length();
    if (((parts[1].substring(l - 1, l)).equals("N")) || ((parts[1].substring(l - 1, l)).equals("S"))) {
      String[] the_parts = split(parts[1], ':');
      latitude = float(the_parts[0]) + (float(the_parts[1]) / 60.0) + (float(the_parts[2]) / 3600.0);
      if ((parts[1].substring(l - 1, l)).equals("S")) latitude *= -1;
    } else {
      latitude = float(parts[1]);
    }

    l = parts[2].length();
    if (((parts[2].substring(l - 1, l)).equals("E")) || ((parts[2].substring(l - 1, l)).equals("W"))) {
      String[] the_parts = split(parts[2], ':');
      longitude = float(the_parts[0]) + (float(the_parts[1]) / 60.0) + (float(the_parts[2]) / 3600.0);
      if ((parts[2].substring(l - 1, l)).equals("W")) longitude *= -1;
    } else {
      longitude = float(parts[2]);
    }

    l = parts[3].length();
    elevation = float(parts[3].substring(0, l - 1));

    NAEFS_Coordinates[f] = new solarchvision_STATION();

    NAEFS_Coordinates[f].setCity(city);
    NAEFS_Coordinates[f].setProvince(province);
    NAEFS_Coordinates[f].setCountry(country);
    NAEFS_Coordinates[f].setLatitude(latitude);
    NAEFS_Coordinates[f].setLongitude(longitude);
    NAEFS_Coordinates[f].setTimelong(funcs.roundTo(longitude, 15));
    NAEFS_Coordinates[f].setElevation(elevation);
    NAEFS_Coordinates[f].setFilename_NAEFS(filename);
  }
}

boolean diag_XML_input = false;
boolean diag_XML_output = false;

String XML_getContent(XML xml) {
 String result = xml.getContent();
 //if (diag_XML_input) println("<" + result + ">");
 return result;
}

String XML_getString(XML xml, String tag) {
 if (diag_XML_input) print(tag + "=");
 String result = xml.getString(tag);
 if (diag_XML_input) println('"' + result + '"');
 return result;
}

float XML_getFloat(XML xml, String tag) {
 if (diag_XML_input) print(tag + "=");
 float result = xml.getFloat(tag);
 if (diag_XML_input) println(result);
 return result;
}

int XML_getInt(XML xml, String tag) {
 if (diag_XML_input) print(tag + "=");
 int result = xml.getInt(tag);
 if (diag_XML_input) println(result);
 return result;
}

Boolean XML_getBoolean(XML xml, String tag) {
 if (diag_XML_input) print(tag + "=");
 Boolean result = Boolean.parseBoolean(xml.getString(tag));
 if (diag_XML_input) println(result);
 return result;
}

void XML_setContent(XML xml, String value) {
 //if (diag_XML_output) println("<" + value + ">");
 xml.setContent(value);
}

void XML_setString(XML xml, String tag, String value) {
 if (diag_XML_output) {
   print(tag + "=");
   println('"' + value + '"');
 }
 xml.setString(tag, value);
}

void XML_setFloat(XML xml, String tag, float value) {
 if (diag_XML_output) {
   print(tag + "=");
   println(value);
 }
 xml.setFloat(tag, value);
}

void XML_setInt(XML xml, String tag, int value) {
 if (diag_XML_output) {
   print(tag + "=");
   println(value);
 }
 xml.setInt(tag, value);
}

void XML_setBoolean(XML xml, String tag, boolean value) {
 if (diag_XML_output) {
   print(tag + "=");
   println(value);
 }
 xml.setString(tag, Boolean.toString(value));
}

PGraphics TREES_graphics;

PGraphics SHADOW_graphics;

float Shades_scaleX;
float Shades_scaleY;

float Shades_offsetX;
float Shades_offsetY;

float[] SunR_Rotated;

String save_folder = "";

void SOLARCHVISION_hold_project () {

  HoldStamp = nf(millis(), 0);

  String myFile = Folder_Project + "/Temp/" + ProjectName + "_tmp" + HoldStamp + ".xml";

  SOLARCHVISION_save_project(myFile);
}

void SOLARCHVISION_fetch_project () {

  String myFile = Folder_Project + "/Temp/" + ProjectName + "_tmp" + HoldStamp + ".xml";

  try {
    SOLARCHVISION_load_project(myFile);
  }
  catch (Exception e) {
    println("Cannot find the hold file:", myFile);
  }
}

String Default_Font = "Liberation Sans";

PFont SOLARCHVISION_font;

void SOLARCHVISION_loadDefaultFontStyle () {

  println("Loading font:", Default_Font);

  SOLARCHVISION_font = createFont(Default_Font, 36, true);

  SOLARCHVISION_ResetFontStyle();
}

void SOLARCHVISION_ResetFontStyle () {

  textFont(SOLARCHVISION_font);
  WORLD.graphics.textFont(SOLARCHVISION_font);
  WIN3D.graphics.textFont(SOLARCHVISION_font);
  STUDY.graphics.textFont(SOLARCHVISION_font);
}

void SOLARCHVISION_draw_frameIcon () {
  int frame_icon_size = 64;

  PGraphics frame_icon = createGraphics(frame_icon_size, frame_icon_size);

  frame_icon.beginDraw();

  //frame_icon.image(loadImage(BaseFolder + "/input/images/icon/s-icon.png"), 0, 0 );

  frame_icon.background(0);
  //frame_icon.background(63,63,255,255);

  //frame_icon.fill(255,127);
  frame_icon.fill(255, 255, 0, 127);

  frame_icon.textAlign(CENTER, CENTER);
  frame_icon.textSize(1.0 * frame_icon_size);
  frame_icon.text("S", 0.20 * frame_icon_size, 0.4 * frame_icon_size);
  frame_icon.text("A", 0.50 * frame_icon_size, 0.4 * frame_icon_size);
  frame_icon.text("V", 0.80 * frame_icon_size, 0.4 * frame_icon_size);

  frame_icon.endDraw();
  //frame.setIconImage(frame_icon.image);

  //frame.setTitle("SOLARCHVISION-" + SOLARCHVISION_version);
}

void SOLARCHVISION_update_station (int Step) {

  if ((Step == 0) || (Step == 1)) {

    VertexSolar_rebuild_array = true;
    GlobalSolar_rebuild_array = true;
    allWindRoses.rebuild_Image_array = true;
    allSolarImpacts.rebuild_Image_array = true;

    allSolarImpacts.sectionType = 0; // Turn off analysis. It should be prebaked first.

    WORLD.revise();
    STUDY.revise();
    SOLARCHVISION_view_changed();

    LocationLAT = STATION.getLatitude();
    LocationLON = STATION.getLongitude();

    WORLD.VIEW_id = WORLD.FindGoodViewport(LocationLON, LocationLAT);

    TIME.beginDay = TIME.convert2Date(TIME.month, TIME.day);
  }

  if ((Step == 0) || (Step == 2)) update_CLIMATE_TMYEPW();

  if ((Step == 0) || (Step == 3)) update_CLIMATE_CWEEDS();

  if ((Step == 0) || (Step == 4)) update_CLIMATE_CLMREC();

  if ((Step == 0) || (Step == 5)) update_ENSEMBLE_OBSERVED();

  if ((Step == 0) || (Step == 6)) update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);

  if ((Step == 0) || (Step == 7)) Land3D.update_mesh();
}

void SOLARCHVISION_update_models (int Step) {

  if ((Step == 0) || (Step == 1)) allGroups.makeEmpty(0); //not deleting all
  if ((Step == 0) || (Step == 2)) Create3D.add_Model_Main();
}

void SOLARCHVISION_update_folders () {

  Folder_Project = BaseFolder + "/projects/model-01";

  Folder_GEOMET = Folder_Project + "/data/GEOMET" + "/" + RunStamp;

  Folder_ENSEMBLE_FORECAST = Folder_Project + "/data/NAEFS";
  Folder_ENSEMBLE_OBSERVED = Folder_Project + "/data/SWOB";

  Folder_CLIMATE_CLMREC = BaseFolder + "/input/climate/CLMREC";
  Folder_CLIMATE_TMYEPW = BaseFolder + "/input/climate/TMYEPW";
  Folder_CLIMATE_CWEEDS = BaseFolder + "/input/climate/CWEEDS";

  Files_CLIMATE_CLMREC = OPESYS.getFiles(Folder_CLIMATE_CLMREC);
  Files_CLIMATE_TMYEPW = OPESYS.getFiles(Folder_CLIMATE_TMYEPW);
  Files_CLIMATE_CWEEDS = OPESYS.getFiles(Folder_CLIMATE_CWEEDS);

  Files_ENSEMBLE_OBSERVED = OPESYS.getFiles(Folder_ENSEMBLE_OBSERVED);
  Files_ENSEMBLE_FORECAST = OPESYS.getFiles(Folder_ENSEMBLE_FORECAST);

  Folder_Coordinates      = BaseFolder + "/input/coordinates";
  WORLD.ViewFolder      = BaseFolder + "/input/images/worldmap";

  Folder_People = BaseFolder + "/input/images/people";
  Folder_Trees  = BaseFolder + "/input/images/trees";

  Folder_Shadings = Folder_Project + "/shadings";

  Folder_Land         = Folder_Project + "/land";

  Folder_Export       = Folder_Project + "/export";
  Folder_Graphics     = Folder_Export + "/graphics" + "/" + RunStamp;
  Folder_Export3D      = Folder_Export + "/3D" + "/" + RunStamp;
  Folder_ScreenShots   = Folder_Export + "/screenshots" + "/" + RunStamp;

  String[] filenames = OPESYS.getFiles(Folder_ScreenShots);
  if (filenames != null) SavedScreenShots = filenames.length;

}

// TODOs:

/*
test these functions:

"LandMesh >> Group"
"LandGap >> Group"

*/

// add to last group remains active when drawing houses then trees are added to the last group!

// Now when adding mulitole objects at once (e.g. trees on land), only the last one selected.

// continue to remove win3d and ui updates from create3D, etc.
// WIN3D.revise();

// move should keep the same distance of bounding box - now only moves the center

// SOLARCHVISION_snap_Faces --> allFaces.snap...

// please define station elevation data for CWEEDS points!

// remember: should optimize vertices after optimizing faces!

//for (int i = 4; i <= 20; i++) { // to make it faster. Also the images are not available out of this period.

// Tropo3D.draw
// note we used .... float r = FLOAT_r_Earth + 10000; for clouds

// pick select LandPoint is not written.

// diffuse model used in render is simple see note "adding approximate diffuse radiation effect anyway!"

// snap for Polyline objects is not developed yet.

// don't know if multiple allModel2Ds.Images[n].get(Image_X, Image_Y) in allModel2Ds selection can produce performance problems?

// note: code for SOLARCHVISION_intersect_allSolids might run a bit slow. But it is OK for now.

// should see where else could add snap3D :)

// drop functions only works for allModel2Ds objects and not at Group level

// could add join/explode groups ?

// export and import of polylines
// converting polylines to faces e.g. Surface, Extrude, Connect

// Modify Normal at Polyline level is not complete...

// Create3D.autoNormalPolyline_Selection

// writing export to rad completed for meshes and land - not Model1Ds and 2Ds yet!

// colud record Climate data flags later.

// exporting shaded land is not written.

// void Rotate3D.selection_Groups
// serach for Rotate3D.selection_Selection ( need to make them all correct for local pivots!
// local pivot

// solid rotations inside groups should be translated to locals to avoid problems!
