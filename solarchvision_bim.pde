String BaseFolder = "C:/SOLARCHVISION_2015"; 

String ExportFolder;
String BackgroundFolder;
String WorldViewFolder;
String SWOBFolder;
String NAEFSFolder;
String CWEEDSFolder;

void _update_folders () {

  ExportFolder       = BaseFolder + "/Export";
  BackgroundFolder   = BaseFolder + "/Input/BackgroundImages/Standard/Other";
  WorldViewFolder    = BaseFolder + "/Input/BackgroundImages/Standard/World";
  SWOBFolder         = BaseFolder + "/Input/CoordinateFiles/LocationInfo";
  NAEFSFolder        = BaseFolder + "/Input/CoordinateFiles/LocationInfo";
  CWEEDSFolder       = BaseFolder + "/Input/CoordinateFiles/LocationInfo";
}


int _MONTH = -1;
int _DAY = -1; 
int _HOUR = -1; 
float _DATE = -1;

String _Filename = "";

String _undefined = "N/A";
float FLOAT_undefined = 1000000000; // it must be a positive big number that is not included in any data

int STATION_NUMBER = 0; 

String[][] DEFINED_STATIONS = {
/*  
                                {"MOSCOW_XX_RU", "MOSCOW", "XX", "55.75", "37.63", "45", "156.0"}, 
                                {"Istanbul_XX_TR", "Istanbul", "XX", "40.97", "28.82", "30", "37.0"}, 
                                {"Barcelona_XX_SP", "Barcelona", "XX", "41.28", "2.07", "15", "6.0"}, 
                                {"Bologna_XX_IT", "Bologna", "XX", "44.53", "11.30", "15", "49.0"}, 
                                {"VIENNA_XX_AT", "VIENNA", "XX", "48.12", "16.57", "15", "190.0"}, 
*/                                
                                {"MONTREAL_DORVAL_QC_CA", "MONTREAL", "QC", "45.47", "-73.75", "-75", "31.00"},
                                {"CALGARY_INTL_AB_CA", "CALGARY", "AB", "51.10", "-114.02", "-120", "1084.10"},
                                {"EDMONTON_INTL_A_AB_CA", "EDMONTON_INTL_A", "AB", "53.316666", "-113.583336", "-120", "723.3"},
                                {"HALIFAX_INTL_AIRPORT_NS_CA", "HALIFAX", "NS", "44.86", "-63.50", "-60", "145.40"},
                                {"OTTAWA_INTL_ON_CA", "OTTAWA", "ON", "45.38", "-75.72", "-75", "114.00"},
                                {"QUEBEC_QC_CA", "QUEBEC", "QC", "46.8", "-71.38333", "-75", "74.4"},
                                {"SUDBURY_ON_CA", "SUDBURY", "ON", "46.625556", "-80.797778", "-75", "348.00"},
                                {"TORONTO_ISLAND_ON_CA", "TORONTO-ISLAND", "ON", "43.63", "-79.40", "-75", "76.50"},
                                {"TORONTO_PEARSON_INTL_ON_CA", "TORONTO-PEARSON", "ON", "43.67", "-79.63", "-75", "173.40"},
                                {"VANCOUVER_INTL_BC_CA", "VANCOUVER", "BC", "49.25", "-123.25", "-120", "4.30"},
                                {"WINNIPEG_INTL_MB_CA", "WINNIPEG_INTL", "MB", "49.916668", "-97.23333", "-90", "238.7"},
/*                                
                                {"BOSTON_MA_US", "BOSTON", "MA", "42.35843", "-71.05978", "-75", "15.0"},
                                {"CHICAGO_IL_US", "CHICAGO", "IL", "41.878113", "-87.6298", "-90", "181.0"},
                                {"DENVER_CO_US", "DENVER", "CO", "39.737568", "-104.98472", "-105", "1608.0"},
                                {"HOUSTON_TX_US", "HOUSTON", "TX", "29.760193", "-95.36939", "-90", "15.0"},
                                {"LAS_VEGAS_NV_US", "LAS_VEGAS", "NV", "36.16994", "-115.13983", "-120", "611.0"},
                                {"LOS_ANGELES_CA_US", "LOS_ANGELES", "CA", "34.052235", "-118.24368", "-120", "87.0"},
                                {"MIAMI_FL_US", "MIAMI", "FL", "25.789097", "-80.20404", "-75", "3.0"},
                                {"NEW_YORK_CITY_NY_US", "NEW_YORK_CITY", "NY", "40.712784", "-74.00594", "-75", "10.0"},
                                {"WASHINGTON_DC_US", "WASHINGTON", "DC", "38.907192", "-77.03687", "-75", "22.0"},
                                
                                {"BRASILIA_XX_BR", "BRASILIA", "XX", "-29.176456", "-51.22032", "-45", "774.0"},
                                {"RIO_DE_JANEIRO_XX_BR", "RIO_DE_JANEIRO", "XX", "-22.893467", "-43.21391", "-45", "6.0"},
                                {"SAO_PAULO_XX_BR", "SAO_PAULO", "XX", "-14.317596", "-44.45876", "-45", "497.0"},
                                
                                {"CIUDAD_DE_MEXICO_DF_MX", "MEXICO_CITY", "DF", "19.432608", "-99.13321", "-105", "2230.0"},
                                {"HAVANA_XX_CU", "HAVANA", "XX", "23.05407", "-82.34519", "-75", "93.0"},
                                {"SANTO_DOMINGO_XX_DO", "SANTO_DOMINGO", "XX", "18.482439", "-69.96518", "-75", "62.0"},
                                {"SAN_SALVADOR_XX_SV", "SAN_SALVADOR", "XX", "13.679502", "-89.21397", "-90", "796.0"},
                                {"CARACAS_XX_VE", "CARACAS", "XX", "10.960712", "-63.920437", "-60", "32.0"},
                                {"BOGOTA_XX_CO", "BOGOTA", "XX", "7.894716", "-72.504616", "-75", "302.0"},
                                {"GUAYAQUIL_XX_EC", "GUAYAQUIL", "XX", "-2.1241937", "-79.59123", "-75", "11.0"},
                                {"LIMA_XX_PE", "LIMA", "XX", "-12.032012", "-76.92987", "-75", "336.0"},
                                {"ANTOFAGASTA_XX_CL", "ANTOFAGASTA", "XX", "-23.65", "-70.4", "-75", "13.0"}
*/                             
                              };




String CLIMATE_directory = "C:/SOLARCHVISION_2015/Input/WeatherClimate/CLIMATE_EPW";

String[] CLIMATE_EPW_Files = getfiles(CLIMATE_directory);

String THE_STATION;
String LocationName;
String LocationProvince;
float LocationLatitude;
float LocationLongitude;
float LocationTimeZone;
float LocationElevation;
float Delta_NOON;

int CLIMATE_start = 2005;//1953;
int CLIMATE_end = 2005;

String[][][][] CLIMATE;

int _winddir = 0;
int _windspd = 1;
int _precipitation = 2;
int _relhum = 3;
int _drybulb = 4;
int _dirnorrad = 5;
int _difhorrad = 6;
int _glohorrad = 7;
int _developed = 8;
int _direffect = 9;
int _difeffect = 10;
int _opaquesky = 11;
int _cloudcover = _opaquesky;
int _logceilsky = 12;
int _ceilingsky = 13;
int _pressure = 14;
int _heightp500hPa = 15;
int _thicknesses_1000_500 = 16;
int _windspd200hPa = 17;

int num_layers = 18; 

int WIN3D_CX_View = 450;
int WIN3D_CY_View = 0;
int WIN3D_X_View = 450;
int WIN3D_Y_View = 300;
float WIN3D_R_View = float(WIN3D_Y_View) / float(WIN3D_X_View);

float WIN3D_X_coordinate = 0;
float WIN3D_Y_coordinate = 0;
float WIN3D_Z_coordinate = 0;
float WIN3D_S_coordinate = 5.0;

float WIN3D_RX_coordinate = 45;
float WIN3D_RY_coordinate = 0;
float WIN3D_RZ_coordinate = 135;
float WIN3D_RS_coordinate = 5.0;

float WIN3D_ZOOM_coordinate = 13500.0 / WIN3D_Y_View;

int WIN3D_View_Type = 0; // 0: Ortho 1: Perspective

PGraphics WIN3D_Diagrams;

int WIN3D_Update = 1;

int WORLD_CX_View = 0;
int WORLD_CY_View = 0;
int WORLD_X_View = 450;
int WORLD_Y_View = 300;
float WORLD_R_View = float(WORLD_Y_View) / float(WORLD_X_View);

float WORLD_X_coordinate = 0;
float WORLD_Y_coordinate = 0;

PGraphics WORLD_Diagrams;

int WORLD_Update = 1;

int WORLD_VIEW_Number = 0;

String[][] WORLD_VIEW_Name;
float[][] WORLD_VIEW_BoundariesX;
float[][] WORLD_VIEW_BoundariesY; 
int[] WORLD_VIEW_GridDisplay;
String[] WORLD_VIEW_Filename;

int number_of_WORLD_viewports;

void setup () 
{
  size(1200, 600, P2D);
  
  frameRate(24);

  

  WIN3D_Diagrams = createGraphics(WIN3D_X_View, WIN3D_Y_View, P3D);  

  WORLD_Diagrams = createGraphics(WORLD_X_View, WORLD_Y_View, P2D);  

  _update_folders();
  
  LoadFontStyle();    

  LoadWorldImages();
  
  SOLARCHVISION_Calendar();

  getSWOB_Coordinates();
  
  getNAEFS_Coordinates();

  getCWEEDS_Coordinates();  

  _update_location();

  _update_objects();

}



void _update_objects () {
  //add_PolygonExtrude(-1, 0,0,0,  0.5,2.0, 10);
  //add_PolygonExtrude(-1, 0,0,0,  1.5,1.0, 5);

  //add_Polygon(1, 0,0,-1, 2,  16);
  //add_Polygon(2, 0,0,0,  1.5, 5);
  //add_Polygon(5, 0,0,1,  1,   3);
  //add_Pentagon(1, 0,0,0, 1);
  //add_Mesh4(2, -1,-1,1, 1,-1,-1 ,1,1,1, -1,1,-1); // hyper
  //add_Mesh4(7, -1,-1,0, 1,-1,0, 1,1,0, -1,1,0);
  //add_Cube(-1, -1,-1,-1,1,1,1);

  //add_Cube(-1, 0.5,1.0,0.0, 1.5,3.0,0.5);
  add_Cube(-1, 0.0,0.0,0.0, 0.5,1.0,2.0);
  
  add_Mesh2(3, 0.5,0.0,0.75, 0.75,1.0,0.75);
  add_Mesh2(3, 0.5,0.0,1.25, 0.75,1.0,1.25);
  add_Mesh2(3, 0.5,0.0,1.75, 0.75,1.0,1.75);
  
  //add_Mesh2(7, -4,-4,0, 4,4,0);
}

float objects_scale = 10;

void _draw_objects () {
  
  for (int i = 1; i < allFaces.length; i++) {
    
    int face_colorID = allFaces_MAT[i];
    
    color c = color(0, 0, 0);

         if (face_colorID == 0) c = color(255, 127, 0);
    else if (face_colorID == 1) c = color(255, 0, 0);
    else if (face_colorID == 2) c = color(255, 255, 0);
    else if (face_colorID == 3) c = color(0, 255, 0);
    else if (face_colorID == 4) c = color(0, 255, 255);
    else if (face_colorID == 5) c = color(0, 0, 255);
    else if (face_colorID == 6) c = color(255, 0, 255);
    else if (face_colorID == 7) c = color(255, 255, 255);
    
    WIN3D_Diagrams.stroke(0, 0, 0);
    WIN3D_Diagrams.fill (c);    
    
    WIN3D_Diagrams.beginShape();
    for (int j = 0; j < allFaces[i].length; j++) {
      WIN3D_Diagrams.vertex(allVertices[allFaces[i][j]][0] * objects_scale, allVertices[allFaces[i][j]][1] * objects_scale, allVertices[allFaces[i][j]][2] * objects_scale);
    }
    WIN3D_Diagrams.endShape(CLOSE);
  }

}

void draw () { 
  
  if (WORLD_Update == 1) {
  
    WORLD_Diagrams.beginDraw();
    
    WORLD_Diagrams.background(0, 0, 0);
    
    PImage WORLDViewImage = loadImage(WorldViewFolder + "/" + WORLD_VIEW_Filename[WORLD_VIEW_Number]);
    
    WORLD_Diagrams.image(WORLDViewImage, 0, 0, WORLD_X_View, WORLD_Y_View);
  
    float WORLD_VIEW_OffsetX = WORLD_VIEW_BoundariesX[WORLD_VIEW_Number][0] + 180;
    float WORLD_VIEW_OffsetY = WORLD_VIEW_BoundariesY[WORLD_VIEW_Number][1] - 90;
  
    float WORLD_VIEW_ScaleX = (WORLD_VIEW_BoundariesX[WORLD_VIEW_Number][1] - WORLD_VIEW_BoundariesX[WORLD_VIEW_Number][0]) / 360.0;
    float WORLD_VIEW_ScaleY = (WORLD_VIEW_BoundariesY[WORLD_VIEW_Number][1] - WORLD_VIEW_BoundariesY[WORLD_VIEW_Number][0]) / 180.0;
    
    float _lon1 = WORLD_VIEW_BoundariesX[WORLD_VIEW_Number][0];
    float _lon2 = WORLD_VIEW_BoundariesX[WORLD_VIEW_Number][1];
    float _lat1 = WORLD_VIEW_BoundariesY[WORLD_VIEW_Number][0];
    float _lat2 = WORLD_VIEW_BoundariesY[WORLD_VIEW_Number][1];
    
    int x_point1 = int(WORLD_X_View * (( 1 * (_lon1 - WORLD_VIEW_OffsetX) / 360.0) + 0.5) / WORLD_VIEW_ScaleX);
    int y_point1 = int(WORLD_Y_View * ((-1 * (_lat1 - WORLD_VIEW_OffsetY) / 180.0) + 0.5) / WORLD_VIEW_ScaleY);
    int x_point2 = int(WORLD_X_View * (( 1 * (_lon2 - WORLD_VIEW_OffsetX) / 360.0) + 0.5) / WORLD_VIEW_ScaleX);
    int y_point2 = int(WORLD_Y_View * ((-1 * (_lat2 - WORLD_VIEW_OffsetY) / 180.0) + 0.5) / WORLD_VIEW_ScaleY);              

    float R_station = 2;
    if (WORLD_VIEW_GridDisplay[WORLD_VIEW_Number] == 1) R_station = 5;   
  
    WORLD_Diagrams.ellipseMode(CENTER);

    WORLD_Diagrams.strokeWeight(3);
    WORLD_Diagrams.stroke(0, 0, 127, 255);
    WORLD_Diagrams.noFill();

    {
      float _lat = LocationLatitude;
      float _lon = LocationLongitude; 
      if (_lon > 180) _lon -= 360; // << important!
    
      float x_point = WORLD_X_View * (( 1 * (_lon - WORLD_VIEW_OffsetX) / 360.0) + 0.5) / WORLD_VIEW_ScaleX;
      float y_point = WORLD_Y_View * ((-1 * (_lat - WORLD_VIEW_OffsetY) / 180.0) + 0.5) / WORLD_VIEW_ScaleY;        
  
      WORLD_Diagrams.ellipse(x_point, y_point, 3 * R_station, 3 * R_station);
   
    }   
    
    WORLD_Diagrams.strokeWeight(0);
    WORLD_Diagrams.stroke(127, 0, 0, 127);
    WORLD_Diagrams.fill(127, 0, 0, 127);
              
    for (int f = 0; f < STATION_SWOB_INFO.length; f += 1) {
      float draw_info = 1;
    
      float _lat = float(STATION_SWOB_INFO[f][3]);
      float _lon = float(STATION_SWOB_INFO[f][4]); 
      if (_lon > 180) _lon -= 360; // << important!
    
      if (_lon < WORLD_VIEW_BoundariesX[WORLD_VIEW_Number][0]) draw_info = 0;
      if (_lon > WORLD_VIEW_BoundariesX[WORLD_VIEW_Number][1]) draw_info = 0;
      if (_lat < WORLD_VIEW_BoundariesY[WORLD_VIEW_Number][0]) draw_info = 0;
      if (_lat > WORLD_VIEW_BoundariesY[WORLD_VIEW_Number][1]) draw_info = 0;      
    
      if (draw_info == 1) {
  
        float x_point = WORLD_X_View * (( 1 * (_lon - WORLD_VIEW_OffsetX) / 360.0) + 0.5) / WORLD_VIEW_ScaleX;
        float y_point = WORLD_Y_View * ((-1 * (_lat - WORLD_VIEW_OffsetY) / 180.0) + 0.5) / WORLD_VIEW_ScaleY;
        
        WORLD_Diagrams.ellipse(x_point, y_point, R_station, R_station);
      
      }
    }    

    WORLD_Diagrams.strokeWeight(0);
    WORLD_Diagrams.stroke(0, 63, 0, 127);
    WORLD_Diagrams.fill(0, 63, 0, 127);
              
    for (int f = 0; f < STATION_NAEFS_INFO.length; f += 1) {
      float draw_info = 1;
    
      float _lat = float(STATION_NAEFS_INFO[f][1]);
      float _lon = float(STATION_NAEFS_INFO[f][2]); 
      if (_lon > 180) _lon -= 360; // << important!
    
      if (_lon < WORLD_VIEW_BoundariesX[WORLD_VIEW_Number][0]) draw_info = 0;
      if (_lon > WORLD_VIEW_BoundariesX[WORLD_VIEW_Number][1]) draw_info = 0;
      if (_lat < WORLD_VIEW_BoundariesY[WORLD_VIEW_Number][0]) draw_info = 0;
      if (_lat > WORLD_VIEW_BoundariesY[WORLD_VIEW_Number][1]) draw_info = 0;      
    
      if (draw_info == 1) {
  
        float x_point = WORLD_X_View * (( 1 * (_lon - WORLD_VIEW_OffsetX) / 360.0) + 0.5) / WORLD_VIEW_ScaleX;
        float y_point = WORLD_Y_View * ((-1 * (_lat - WORLD_VIEW_OffsetY) / 180.0) + 0.5) / WORLD_VIEW_ScaleY;
        
        WORLD_Diagrams.ellipse(x_point, y_point, 1.5 * R_station, 1.5 * R_station);
      
      }
    } 

    WORLD_Diagrams.strokeWeight(2);
    WORLD_Diagrams.stroke(63, 63, 63, 63);
    WORLD_Diagrams.noFill();
              
    for (int f = 0; f < STATION_CWEEDS_INFO.length; f += 1) {
      float draw_info = 1;
    
      float _lat = float(STATION_CWEEDS_INFO[f][3]);
      float _lon = float(STATION_CWEEDS_INFO[f][4]); 
      if (_lon > 180) _lon -= 360; // << important!
    
      if (_lon < WORLD_VIEW_BoundariesX[WORLD_VIEW_Number][0]) draw_info = 0;
      if (_lon > WORLD_VIEW_BoundariesX[WORLD_VIEW_Number][1]) draw_info = 0;
      if (_lat < WORLD_VIEW_BoundariesY[WORLD_VIEW_Number][0]) draw_info = 0;
      if (_lat > WORLD_VIEW_BoundariesY[WORLD_VIEW_Number][1]) draw_info = 0;      
    
      if (draw_info == 1) {
  
        float x_point = WORLD_X_View * (( 1 * (_lon - WORLD_VIEW_OffsetX) / 360.0) + 0.5) / WORLD_VIEW_ScaleX;
        float y_point = WORLD_Y_View * ((-1 * (_lat - WORLD_VIEW_OffsetY) / 180.0) + 0.5) / WORLD_VIEW_ScaleY;
        
        WORLD_Diagrams.ellipse(x_point, y_point, 3 * R_station, 3 * R_station);
      
      }
    } 
    
    WORLD_Diagrams.strokeWeight(0);
  
    
    WORLD_Diagrams.endDraw();
    
    image(WORLD_Diagrams, WORLD_CX_View, WORLD_CY_View, WORLD_X_View, WORLD_Y_View);    
  
    WORLD_Update = 0;
  }
  
  if (WIN3D_Update == 1) {
  
    WIN3D_Diagrams.beginDraw();
    
    WIN3D_Diagrams.background(233);
    
    if (WIN3D_View_Type == 1) {
      WIN3D_Diagrams.perspective(WIN3D_ZOOM_coordinate * PI/180, 1.0 / WIN3D_R_View, 0.00001, 100000);  //fovy, aspect, zNear, zFar
      
      WIN3D_Diagrams.translate(0.5 * WIN3D_X_View, 0.5 * WIN3D_Y_View, 0); // << IMPORTANT! 
    }
    else{
      
      float ZOOM = 0.456 * WIN3D_ZOOM_coordinate * PI/180;
      
      WIN3D_Diagrams.ortho(ZOOM * WIN3D_X_View * -1, ZOOM * WIN3D_X_View * 1, ZOOM  * WIN3D_Y_View * -1, ZOOM  * WIN3D_Y_View * 1, 0.00001, 100000);
      
      WIN3D_Diagrams.translate(0, 1.0 * WIN3D_Y_View, 0); // << IMPORTANT! 
    }
  
    //lights();
  
    
    WIN3D_Diagrams.pushMatrix();
    
    WIN3D_Diagrams.translate(0, 0, 0);
    
    WIN3D_Diagrams.fill(0);
    WIN3D_Diagrams.textAlign(CENTER, CENTER);      
    WIN3D_Diagrams.textSize(5 * (WIN3D_ZOOM_coordinate / 30.0));
    WIN3D_Diagrams.text(LocationName + " [" + nfp(LocationLatitude, 0, 1) + ", " + nfp(LocationLongitude, 0, 1) + "]", 0, 45 * (WIN3D_ZOOM_coordinate / 30.0), 0);
   
    WIN3D_Diagrams.popMatrix();
  
    WIN3D_Diagrams.translate(WIN3D_X_coordinate, WIN3D_Y_coordinate, WIN3D_Z_coordinate);
    WIN3D_Diagrams.rotateX(WIN3D_RX_coordinate * PI/180);    
    WIN3D_Diagrams.rotateY(WIN3D_RY_coordinate * PI/180);
    WIN3D_Diagrams.rotateZ(WIN3D_RZ_coordinate * PI/180);    

    //println(nfp(WIN3D_RX_coordinate, 0, 1), nfp(WIN3D_RY_coordinate, 0, 1), nfp(WIN3D_RZ_coordinate, 0, 1));  

    
    
    
    WIN3D_Diagrams.fill(127);
  
  
    //hint(DISABLE_DEPTH_TEST);
  
    _draw_objects();
    
    //SOLARCHVISION_SunPath(0, 0, 0, 90, LocationLatitude); 
  
    //hint(ENABLE_DEPTH_TEST);
  
    WIN3D_Diagrams.endDraw();
    
    image(WIN3D_Diagrams, WIN3D_CX_View, WIN3D_CY_View, WIN3D_X_View, WIN3D_Y_View);


    WIN3D_Update = 0;
  }




} 





 
void SOLARCHVISION_SunPath (float x_SunPath, float y_SunPath, float z_SunPath, float s_SunPath, float LocationLatitude) { 

  float min_sunrise = int(min(SOLARCHVISION_Sunrise(LocationLatitude, 90), SOLARCHVISION_Sunrise(LocationLatitude, 270))); 
  float max_sunset = int(max(SOLARCHVISION_Sunset(LocationLatitude, 90), SOLARCHVISION_Sunset(LocationLatitude, 270)));
 
  
  WIN3D_Diagrams.pushMatrix();
  WIN3D_Diagrams.translate(x_SunPath, y_SunPath, z_SunPath);
  
  WIN3D_Diagrams.line(-1 * s_SunPath, 0, 0, 1 * s_SunPath, 0, 0); 
  WIN3D_Diagrams.line(0, -1 * s_SunPath, 0, 0, 1 * s_SunPath, 0);

  WIN3D_Diagrams.stroke(255, 255, 0);
  
  for (int HOUR = int(roundTo(min_sunrise, 1.0)); HOUR < int(roundTo(max_sunset, 1.0)); HOUR += 1){
    int DATE_step = 1;
    
    for (int DATE_ANGLE = 0; DATE_ANGLE < 360; DATE_ANGLE += DATE_step){
        
      _DATE = Convert2Day(DATE_ANGLE);
  
      _update_date();
      
      //println(_DATE, _MONTH, _DAY, DATE_ANGLE); exit();
     
      float[] Sun = SOLARCHVISION_SunPosition(LocationLatitude, DATE_ANGLE, HOUR);
      
      if (Sun[3] >= 0) {
        
        int i = HOUR - 1;  // ??????
        int j = Convert2Date(_MONTH, _DAY);
        int k = 0; // on EPW:TMY files we have only one year 
        
        //println(i, j, k); exit();
        
        String Pa = CLIMATE[i][j][_direffect][k];
        
        if (Pa.equals(_undefined)){
        }
        else{
       
          float[] COL = SOLARCHVISION_DRYWCBD(0.0002 * float(Pa)); // ????????
  
          WIN3D_Diagrams.stroke(COL[1], COL[2], COL[3], 127);
          WIN3D_Diagrams.fill(COL[1], COL[2], COL[3], 127);
          
          float[] SunA = SOLARCHVISION_SunPosition(LocationLatitude, DATE_ANGLE - 0.5 * DATE_step, HOUR - 0.5);
          float[] SunB = SOLARCHVISION_SunPosition(LocationLatitude, DATE_ANGLE - 0.5 * DATE_step, HOUR + 0.5);
          float[] SunC = SOLARCHVISION_SunPosition(LocationLatitude, DATE_ANGLE + 0.5 * DATE_step, HOUR + 0.5);
          float[] SunD = SOLARCHVISION_SunPosition(LocationLatitude, DATE_ANGLE + 0.5 * DATE_step, HOUR - 0.5);
          
          WIN3D_Diagrams.beginShape();
          WIN3D_Diagrams.vertex(s_SunPath * SunA[1], -s_SunPath * SunA[2], s_SunPath * SunA[3]);
          WIN3D_Diagrams.vertex(s_SunPath * SunB[1], -s_SunPath * SunB[2], s_SunPath * SunB[3]);
          WIN3D_Diagrams.vertex(s_SunPath * SunC[1], -s_SunPath * SunC[2], s_SunPath * SunC[3]);
          WIN3D_Diagrams.vertex(s_SunPath * SunD[1], -s_SunPath * SunD[2], s_SunPath * SunD[3]);

          WIN3D_Diagrams.endShape(CLOSE);
          
        }
      }

    }
  }
  
  WIN3D_Diagrams.stroke(0);
  
  for (int j = 90; j <= 270; j += 30){
    float HOUR_step = (SOLARCHVISION_DayTime(LocationLatitude, j) / 12.0);
    for (float HOUR = SOLARCHVISION_Sunrise(LocationLatitude, j); HOUR <(SOLARCHVISION_Sunset(LocationLatitude, j) + .01 - HOUR_step); HOUR += HOUR_step){
      float[] SunA = SOLARCHVISION_SunPosition(LocationLatitude, j, HOUR);
      float[] SunB = SOLARCHVISION_SunPosition(LocationLatitude, j, (HOUR + HOUR_step));
      WIN3D_Diagrams.line(s_SunPath * SunA[1], -s_SunPath * SunA[2], s_SunPath * SunA[3], s_SunPath * SunB[1], -s_SunPath * SunB[2], s_SunPath * SunB[3]);
    }
  }
  
  for (float HOUR = min_sunrise; HOUR < max_sunset + .01; HOUR += 1){
    float DATE_step = 1;
    for (int j = 0; j <= 360; j += DATE_step){
      float[] SunA = SOLARCHVISION_SunPosition(LocationLatitude, j, HOUR);
      float[] SunB = SOLARCHVISION_SunPosition(LocationLatitude, (j + DATE_step), HOUR);
      if (SunA[3] >= 0 && SunB[3] >= 0) {
        WIN3D_Diagrams.line(s_SunPath * SunA[1], -s_SunPath * SunA[2], s_SunPath * SunA[3], s_SunPath * SunB[1], -s_SunPath * SunB[2], s_SunPath * SunB[3]);
      }
    }
  }
  
  WIN3D_Diagrams.popMatrix();

  WIN3D_Diagrams.stroke(0);
  for (int i = 0; i < 360; i += 5){
    WIN3D_Diagrams.line(s_SunPath * cos(i * PI/180), -s_SunPath * sin(i * PI/180), 0, s_SunPath * cos((i + 5) * PI/180), -s_SunPath * sin((i + 5) * PI/180), 0);  
    
    WIN3D_Diagrams.line(s_SunPath * cos(i * PI/180), -s_SunPath * sin(i * PI/180), 0, 1.05 * s_SunPath * cos((i) * PI/180), -1.05 * s_SunPath * sin((i) * PI/180), 0);
  }
  
  for (int i = 0; i < 360; i += 15){
    WIN3D_Diagrams.pushMatrix();
    WIN3D_Diagrams.translate(1.15 * s_SunPath * cos(i * PI/180), -1.15 * s_SunPath * sin(i * PI/180), 0);
    
    WIN3D_Diagrams.fill(0);
    WIN3D_Diagrams.textSize(s_SunPath * 0.05);
    WIN3D_Diagrams.textAlign(CENTER, CENTER);
    
    String txt = nf((90 - i + 360) % 360, 0);
    if (i == 0) {
      txt = "E"; 
      WIN3D_Diagrams.textSize(s_SunPath * 0.1);
    }
    else if (i == 90) {
      txt = "N"; 
      WIN3D_Diagrams.textSize(s_SunPath * 0.1);
    }
    else if (i == 180) {
      txt = "W"; 
      WIN3D_Diagrams.textSize(s_SunPath * 0.1);
    }
    else if (i == 270) {
      txt = "S"; 
      WIN3D_Diagrams.textSize(s_SunPath * 0.1);
    }
    
    WIN3D_Diagrams.text(txt, 0, 0, 0);
    
    WIN3D_Diagrams.popMatrix();
  }    
} 




void keyPressed (){
  //println("key: " + key);
  //println("keyCode: " + keyCode); 
  
  if (key == CODED) { 
    switch(keyCode) {
      case LEFT  :WIN3D_X_coordinate -= WIN3D_S_coordinate; break;
      case RIGHT :WIN3D_X_coordinate += WIN3D_S_coordinate; break;  
      case UP    :WIN3D_Y_coordinate -= WIN3D_S_coordinate; break;
      case DOWN  :WIN3D_Y_coordinate += WIN3D_S_coordinate; break;
    }
  }
  else{
    switch(key) {
      case ',' :WIN3D_Z_coordinate += WIN3D_S_coordinate; break;      
      case '.'  :WIN3D_Z_coordinate -= WIN3D_S_coordinate; break;

      case '0' :WIN3D_View_Type = 1; WIN3D_Z_coordinate += WIN3D_S_coordinate; break;
      
      case '5' :WIN3D_RX_coordinate = 0;
                WIN3D_RY_coordinate = 0;
                WIN3D_RZ_coordinate = 0; 
                break;

      case '@' :WIN3D_RX_coordinate = 0;
                WIN3D_RY_coordinate = 0;
                WIN3D_RZ_coordinate = 0; 
                WIN3D_X_coordinate = 0;
                WIN3D_Y_coordinate = 0;
                WIN3D_Z_coordinate = 0;
                WIN3D_ZOOM_coordinate = 13500.0 / WIN3D_Y_View;
                WIN3D_View_Type = 0; 
                break;

      case '1' :WIN3D_RX_coordinate = 45; WIN3D_RY_coordinate = 0; WIN3D_RZ_coordinate = 315; break;
      case '3' :WIN3D_RX_coordinate = 45; WIN3D_RY_coordinate = 0; WIN3D_RZ_coordinate = 45; break;
      case '7' :WIN3D_RX_coordinate = 45; WIN3D_RY_coordinate = 0; WIN3D_RZ_coordinate = 225; break;
      case '9' :WIN3D_RX_coordinate = 45; WIN3D_RY_coordinate = 0; WIN3D_RZ_coordinate = 135; break;

      case '2' :WIN3D_RX_coordinate += WIN3D_RS_coordinate; break;
      case '4' :WIN3D_RZ_coordinate -= WIN3D_RS_coordinate; break;
      case '6' :WIN3D_RZ_coordinate += WIN3D_RS_coordinate; break;      
      case '8' :WIN3D_RX_coordinate -= WIN3D_RS_coordinate; break;

      case '{' :WIN3D_RX_coordinate -= WIN3D_RS_coordinate; break;
      case '}' :WIN3D_RX_coordinate += WIN3D_RS_coordinate; break;
      case '(' :WIN3D_RY_coordinate -= WIN3D_RS_coordinate; break;
      case ')' :WIN3D_RY_coordinate += WIN3D_RS_coordinate; break;
      case '[' :WIN3D_RZ_coordinate -= WIN3D_RS_coordinate; break;
      case ']' :WIN3D_RZ_coordinate += WIN3D_RS_coordinate; break;

      case '*' :objects_scale *= 2.0; break;
      case '/' :objects_scale /= 2.0; break;

      case '+' :WIN3D_ZOOM_coordinate = 2 * atan_ang((1.0 / 1.1) * tan_ang(0.5 * WIN3D_ZOOM_coordinate)); break;
      case '-' :WIN3D_ZOOM_coordinate = 2 * atan_ang((1.1 / 1.0) * tan_ang(0.5 * WIN3D_ZOOM_coordinate)); break;      
      
      case '>' :WIN3D_ZOOM_coordinate = 2 * atan_ang((1.0 / 1.1) * tan_ang(0.5 * WIN3D_ZOOM_coordinate)); break;
      case '<' :WIN3D_ZOOM_coordinate = 2 * atan_ang((1.1 / 1.0) * tan_ang(0.5 * WIN3D_ZOOM_coordinate)); break;
      
      case 'O' :WIN3D_View_Type = 0; break;
      case 'o' :WIN3D_View_Type = 0; break;
      
      case 'P' :WIN3D_View_Type = 1; break;                
      case 'p' :WIN3D_View_Type = 1; break;                
                
      case 'S' :STATION_NUMBER = (STATION_NUMBER + 1) % DEFINED_STATIONS.length; _update_location(); break;
      case 's' :STATION_NUMBER = (STATION_NUMBER - 1 + DEFINED_STATIONS.length) % DEFINED_STATIONS.length; _update_location(); break;
      
      
      case 'F' :LoadFontStyle(); break;
      case 'f' :LoadFontStyle(); break;
           
          
      case '$' :saveFrame("image.jpg"); println("File created."); break;
      case '#' :saveFrame("image_frame####.jpg"); println("File created."); break;
    }

  }
  
  WIN3D_Update = 1;
  
  loop();
}


float sin_ang (float a) {
 return sin(a * PI/180); 
}

float cos_ang (float a) {
 return cos(a * PI/180); 
}

float tan_ang (float a) {
 return tan(a * PI/180); 
}


float asin_ang (float a) {
 return((asin(a)) * 180/PI); 
}

float acos_ang (float a) {
 return((acos(a)) * 180/PI); 
}

float atan_ang (float a) {
 return((atan(a)) * 180/PI); 
}

float atan2_ang (float a, float b) {
 return((atan2(a, b)) * 180/PI); 
}

float roundTo (float a, float b) {
  float a_floor = (floor(a /(1.0 * b))) * b;
  float a_ceil = (ceil(a /(1.0 * b))) * b;
  float c;
  if ((a - a_floor) >(a_ceil - a)) {
    c = a_ceil;
  }
  else{
    c = a_floor;
  }
  return c;
}

float EquationOfTime (float DateAngle) {
  float b = DateAngle;

  return 0.01  * (9.87 * sin_ang(2 * b) - 7.53 * cos_ang(b) - 1.5 * sin_ang(b));
}

float[] SOLARCHVISION_SunPosition (float Latitude, float DateAngle, float HourAngleOrigin) {
  float HourAngle = HourAngleOrigin + EquationOfTime(DateAngle);
  
  float Declination = 23.45 * sin_ang(DateAngle - 180.0);

  float a = sin_ang(Declination);
  float b = cos_ang(Declination) * -cos_ang(15.0 * HourAngle);
  float c = cos_ang(Declination) *  sin_ang(15.0 * HourAngle);

  float x = c; 
  float y = -(a * cos_ang(Latitude) + b * sin_ang(Latitude));
  float z = -a * sin_ang(Latitude) + b * cos_ang(Latitude);

  float[] return_array = {0, x, y, z}; 
  return return_array; 
}


float SOLARCHVISION_Sunrise (float Latitude, float DateAngle) {
  
  float a = 0;
  
  float Declination = 23.5 * sin_ang(DateAngle - 180.0);
  
  float q = -(tan_ang(Declination) * tan_ang(Latitude));
  if (q > 1.0) {
    a = 0.0;
  }
  else if (q < -1.0) {
    a = 24.0;
  }
  else a = acos_ang(q) / 15.0;
  
  
  return (a - EquationOfTime(DateAngle));
}

float SOLARCHVISION_Sunset (float Latitude, float DateAngle) {
  
  float a = 0;
  
  float Declination = 23.5 * sin_ang(DateAngle - 180.0);
  
  float q = -(tan_ang(Declination) * tan_ang(Latitude));
  if (q > 1.0) {
    a = 0.0;
  }
  else if (q < -1.0) {
    a = 24.0;
  }
  else a = acos_ang(q) / 15.0;
  
  
  return ((24 - a) - EquationOfTime(DateAngle));
}

float SOLARCHVISION_DayTime (float Latitude, float DateAngle) {
  return abs((SOLARCHVISION_Sunset(Latitude, DateAngle)) -(SOLARCHVISION_Sunrise(Latitude, DateAngle)));
}

int try_update_CLIMATE () {
  int File_Found = 0;
  
  CLIMATE = new String[24][365][num_layers][(1 + CLIMATE_end - CLIMATE_start)];
 
  for (int i = 0; i < 24; i += 1){
    for (int j = 0; j < 365; j += 1){
      for (int l = 0; l < num_layers; l += 1){
        for (int k = 0; k <(1 + CLIMATE_end - CLIMATE_start); k += 1){
          CLIMATE[i][j][l][k] = _undefined;
        }
      }
    }
  }
    
  String FN = THE_STATION;

  for (int i = 0; i < CLIMATE_EPW_Files.length; i++) {
    
    int _L = CLIMATE_EPW_Files[i].length();
    String _Extention = CLIMATE_EPW_Files[i].substring(_L - 4, _L);
    //println(_Extention);
    if (_Extention.toLowerCase().equals(".epw")) {
      _Filename = CLIMATE_EPW_Files[i].substring(0, _L - 4);
      
      if (_Filename.equals(FN)){
        File_Found = 1;
        SOLARCHVISION_LoadCLIMATE((CLIMATE_directory + "/" + CLIMATE_EPW_Files[i]));
      }
    }
  }
  
  if (File_Found == 0) println("FILE NOT FOUND:", FN);
  
  return File_Found;
}

void SOLARCHVISION_LoadCLIMATE (String FileName) {
  String[] FileALL = loadStrings(FileName);

  String lineSTR;
  String[] input;
  
    
  //println("lines = ", FileALL.length);

  for (int f = 8; f < FileALL.length; f += 1){
    
    lineSTR = FileALL[f];
    
    String[] parts = split(lineSTR, ',');
    
    int CLIMATE_YEAR = int(parts[0]);
    int CLIMATE_MONTH = int(parts[1]);
    int CLIMATE_DAY = int(parts[2]);
    int CLIMATE_HOUR = int(parts[3]);
    
    //println(CLIMATE_YEAR, CLIMATE_MONTH, CLIMATE_DAY, CLIMATE_HOUR);
    
    int i = int(CLIMATE_HOUR) - 1;
    int j = Convert2Date(CLIMATE_MONTH, CLIMATE_DAY);
    int k = 0; // on EPW:TMY files we have only one year 
    
    //println(i);
    
    CLIMATE[i][j][_pressure][k] = parts[9]; // in Pa
    CLIMATE[i][j][_drybulb][k] = parts[6]; // in °C
    CLIMATE[i][j][_relhum][k] = parts[8]; // 0 - 110%
    CLIMATE[i][j][_glohorrad][k] = parts[13]; // Wh/m²
    CLIMATE[i][j][_dirnorrad][k] = parts[14]; // Wh/m²
    CLIMATE[i][j][_difhorrad][k] = parts[15]; // Wh/m²
    CLIMATE[i][j][_windspd][k] = parts[21]; // in m/s
    CLIMATE[i][j][_winddir][k] = parts[20]; // ° 
    CLIMATE[i][j][_opaquesky][k] = parts[23]; // 0.1 times in % ... there is also total_sky_cover on[22]
    CLIMATE[i][j][_ceilingsky][k] = parts[25]; // in m
    
    
    if (CLIMATE[i][j][_pressure][k].equals("999999")) CLIMATE[i][j][_pressure][k] = _undefined;
    
    if (CLIMATE[i][j][_drybulb][k].equals("99.9")) CLIMATE[i][j][_drybulb][k] = _undefined;
    
    if (CLIMATE[i][j][_relhum][k].equals("999")) CLIMATE[i][j][_relhum][k] = _undefined;
    
    if (CLIMATE[i][j][_glohorrad][k].equals("9999")) CLIMATE[i][j][_glohorrad][k] = _undefined;
    
    if (int(CLIMATE[i][j][_dirnorrad][k]) >= 9999) CLIMATE[i][j][_dirnorrad][k] = _undefined;
    if (int(CLIMATE[i][j][_dirnorrad][k]) < 0) CLIMATE[i][j][_dirnorrad][k] = _undefined;
    
    if (int(CLIMATE[i][j][_difhorrad][k]) >= 9999) CLIMATE[i][j][_difhorrad][k] = _undefined;
    if (int(CLIMATE[i][j][_difhorrad][k]) < 0) CLIMATE[i][j][_difhorrad][k] = _undefined;
    
    if (CLIMATE[i][j][_windspd][k].equals("999")) CLIMATE[i][j][_windspd][k] = _undefined;
    else CLIMATE[i][j][_windspd][k] = String.valueOf(3.6 * float(CLIMATE[i][j][_windspd][k]));
    
    if (CLIMATE[i][j][_winddir][k].equals("999")) CLIMATE[i][j][_winddir][k] = _undefined;
    
    if (CLIMATE[i][j][_opaquesky][k].equals("99")) CLIMATE[i][j][_opaquesky][k] = _undefined;
    
    if (CLIMATE[i][j][_ceilingsky][k].equals("77777")) CLIMATE[i][j][_ceilingsky][k] = "1000";
    if (CLIMATE[i][j][_ceilingsky][k].equals("88888")) CLIMATE[i][j][_ceilingsky][k] = "1000";
    if (int(CLIMATE[i][j][_ceilingsky][k]) >= 1000) CLIMATE[i][j][_ceilingsky][k] = "1000";    
    
    if (CLIMATE[i][j][_ceilingsky][k].equals("99999")) CLIMATE[i][j][_ceilingsky][k] = _undefined;

  }

  String Pa, Pb, Pc;
  float T, R_dir, R_dif;
  for (int i = 0; i < 24; i += 1){
    for (int j = 0; j < 365; j += 1){
      for (int k = 0; k <(1 + CLIMATE_end - CLIMATE_start); k += 1){
        Pa = CLIMATE[i][j][_drybulb][k];
        Pb = CLIMATE[i][j][_dirnorrad][k];
        Pc = CLIMATE[i][j][_difhorrad][k];
                  
        if ((Pa.equals(_undefined)) ||(Pb.equals(_undefined)) ||(Pc.equals(_undefined))){
        }
        else{
          T = float(Pa);
          R_dir = float(Pb);
          R_dif = float(Pc);
          CLIMATE[i][j][_direffect][k] = String.valueOf((18 - T) * R_dir);
          CLIMATE[i][j][_difeffect][k] = String.valueOf((18 - T) * R_dif);
        }
        
        Pa = CLIMATE[i][j][_ceilingsky][k];
        if (Pa.equals(_undefined)){
        }
        else{
          float Px = log(float(Pa)) / log(10.0);
          if (Px > 2) CLIMATE[i][j][_logceilsky][k] = String.valueOf(roundTo(Px, 0.1));
          else CLIMATE[i][j][_logceilsky][k] = "2";
        }
      }
    }
  }
}


float[] SOLARCHVISION_DRYWCBD (float _variable) {
  _variable  *= 2.75;
  
  float v;
  float[] COL = {255, 0, 0, 0};
  if (_variable < -2.75) {
    COL[1] = 63;
    COL[2] = 0;
    COL[3] = 0;
  }
  else if (_variable < -2) {
    v = (-(_variable + 2) * 255);
    COL[1] = 255 - v;
    COL[2] = 0;
    COL[3] = 0;
  }
  else if (_variable < -1) {
    v = (-(_variable + 1) * 255);
    COL[1] = 255;
    COL[2] = 255 - v;
    COL[3] = 0;
  }
  else if (_variable < 0) {
    v = (-_variable * 255);
    COL[1] = 255;
    COL[2] = 255;
    COL[3] = 255 - v;
  }
  else if (_variable < 1) {
    v = (_variable * 255);
    COL[1] = 255 - v;
    COL[2] = 255;
    COL[3] = 255;
  }
  else if (_variable < 2) {
    v = ((_variable - 1) * 255);
    COL[1] = 0;
    COL[2] = 255 - v;
    COL[3] = 255;
  }
  else if (_variable < 2.75) {
    v = ((_variable - 2) * 255);
    COL[1] = 0;
    COL[2] = 0;
    COL[3] = 255 - v;
  }
  else {
    COL[1] = 0;
    COL[2] = 0;
    COL[3] = 63;
  }
  /*
  float _r = COL[1];
  COL[1] = COL[3];
  COL[3] = _r;
  */
  return COL;
}


String[][] CalendarMonth = {
  {"January", "janvier"}, 
  {"February", "février"}, 
  {"March", "mars"}, 
  {"April", "avril"}, 
  {"May", "mai"}, 
  {"June", "juin"}, 
  {"July", "juillet"}, 
  {"August", "août"}, 
  {"September", "septembre"}, 
  {"October", "octobre"}, 
  {"November", "novembre"}, 
  {"December", "décembre"}
};

int CalendarLength[] = {31     , 28     , 31     , 30     , 31     , 30     , 31     , 31     , 30     , 31     , 30     , 31};
String CalendarDay[][];
String CalendarMM[][];
String CalendarDD[][];
int CalendarDate[][];

void SOLARCHVISION_Calendar () {
  CalendarMM = new String[365][2];
  CalendarDD = new String[365][2];
  CalendarDay = new String[365][2];
  
  CalendarDate = new int[365][2];
  
  int k = 285;
  for (int l = 0; l < 2; l += 1){
    for (int i = 0; i < 12; i += 1){
      for (int j = 0; j < CalendarLength[i]; j += 1){
        k += 1;
        if (k == 365) k = 0; 
        CalendarMM[k][l] = CalendarMonth[i][l];
        CalendarDD[k][l] = String.valueOf(j + 1);
        CalendarDay[k][l] = CalendarDD[k][l] + " " + CalendarMM[k][l];
        
        CalendarDate[k][0] = i + 1;
        CalendarDate[k][1] = j + 1;
      }
    }
  }
}

int Convert2Day (int Date_Angle) {
  int DAY = (Date_Angle + 360) % 360;
  if (DAY >=  31) DAY += 1;
  if (DAY >=  62) DAY += 1;
  if (DAY >=  93) DAY += 1;
  if (DAY >= 124) DAY += 1;
  if (DAY >= 155) DAY += 1;
  DAY = DAY % 365;
  return DAY; 
}

int Convert2Date (int _MONTH, int _DAY) {
  int k = 0;
  for (int i = 0; i <(_MONTH - 1); i += 1){
    for (int j = 0; j < CalendarLength[i]; j += 1){
      k += 1;
      if (k == 365) k = 0; 
    }
  }
  k += _DAY - 1;
  
  k = k % 365;
  return k;
}

void _update_date() {
  _MONTH = CalendarDate[int(_DATE)][0]; 
  _DAY = CalendarDate[int(_DATE)][1];
  _HOUR = int(24  * (_DATE - int(_DATE)));
}

void _update_location () {
  THE_STATION = DEFINED_STATIONS[STATION_NUMBER][0];
  LocationName = DEFINED_STATIONS[STATION_NUMBER][1];
  LocationProvince = DEFINED_STATIONS[STATION_NUMBER][2];
  LocationLatitude = float(DEFINED_STATIONS[STATION_NUMBER][3]);
  LocationLongitude = float(DEFINED_STATIONS[STATION_NUMBER][4]);
  LocationTimeZone = float(DEFINED_STATIONS[STATION_NUMBER][5]);
  LocationElevation = float(DEFINED_STATIONS[STATION_NUMBER][6]);
  Delta_NOON = (LocationTimeZone - LocationLongitude) / 15.0;

  try_update_CLIMATE();
  
  WORLD_VIEW_Number = FindGoodViewport(LocationLongitude, LocationLatitude);
 
}

String[] getfiles(String _Folder) {
  File dir = new File(_Folder);
  
  String[] filenames = dir.list();
  
  if (filenames != null) {
    for (int i = 0; i < filenames.length; i++) {
      //println(filenames[i]);
    }
  }
  return filenames;
}


void LoadFontStyle () {
  
  int _size = 36;

  textFont(createFont("MS Sans Serif", _size, true));

  //textFont(createFont("MS Sans Serif", _size));
  //textFont(createFont("Microsoft Sans Serif", _size));
  //textFont(createFont("Arial Narrow", _size));
  //textFont(createFont("Arial", _size));
  //textFont(createFont("Times New Roman", _size));
  //textFont(createFont("Calibri", _size));
  //textFont(createFont("Cambria", _size));
  //textFont(createFont("Georgia", _size));
  //textFont(createFont("Courier New", _size));
  //textFont(createFont("Franklin Gothic Medium", _size));
  //textFont(createFont("BankGothic Md BT", _size));

}


int defaultMaterial = 7;

float[][] allVertices = {{}};
int[][] allFaces = {{}};
int[] allFaces_MAT = {0};

int addToVertices (float x, float y, float z) {
  
  float[][] newVertice = {{x,y,z}}; 
  
  allVertices = (float[][]) concat(allVertices, newVertice);
  
  return(allVertices.length - 1);
}

int addToFaces (int[] f) {

  int[] newFace_MAT = {defaultMaterial}; 
  
  allFaces_MAT = concat(allFaces_MAT, newFace_MAT);
  
  
  int[][] newFace = {f}; 
  
  allFaces = (int[][]) concat(allFaces, newFace);

  return(allFaces.length - 1);
}



void add_Cube (int m, float x1, float y1, float z1, float x2, float y2, float z2) {

  int t1 = addToVertices(x2,y2,z2);
  int t2 = addToVertices(x1,y2,z2);
  int t3 = addToVertices(x1,y1,z2);
  int t4 = addToVertices(x2,y1,z2);

  int b1 = addToVertices(x2,y2,z1);
  int b2 = addToVertices(x1,y2,z1);
  int b3 = addToVertices(x1,y1,z1);
  int b4 = addToVertices(x2,y1,z1);

  if (m == -1) defaultMaterial = 0;
  else defaultMaterial = m;

  {
    int[] newFace = {t4,t3,t2,t1};
    if (m == -1) defaultMaterial += 1;
    addToFaces(newFace);
  }
  {
    int[] newFace = {t1,t2,b2,b1};
    if (m == -1) defaultMaterial += 1;
    addToFaces(newFace);
  }
  {
    int[] newFace = {t2,t3,b3,b2};
    if (m == -1) defaultMaterial += 1;
    addToFaces(newFace);
  }
  {
    int[] newFace = {t3,t4,b4,b3};
    if (m == -1) defaultMaterial += 1;
    addToFaces(newFace);
  }
  {
    int[] newFace = {t4,t1,b1,b4};
    if (m == -1) defaultMaterial += 1;
    addToFaces(newFace);
  }
  {
    int[] newFace = {b1,b2,b3,b4};
    if (m == -1) defaultMaterial += 1;
    addToFaces(newFace);
  }  

}


void add_Mesh2(int m, float x1, float y1, float z1, float x3, float y3, float z3) {

  float x2 = x3;
  float y2 = y3;
  float z2 = z3;

  float x4 = x1;
  float y4 = y1;
  float z4 = z1;
  
  if (z1 == z3) {
    y2 = y1;
    y4 = y3;
  }
  else if (y1 == y3) {
    x2 = x1;
    x4 = x3;
  }
  else if (x1 == x3) {
    z2 = z1;
    z4 = z3;
  }  
  
  int v1 = addToVertices(x1,y1,z1);
  int v2 = addToVertices(x2,y2,z2);
  int v3 = addToVertices(x3,y3,z3);
  int v4 = addToVertices(x4,y4,z4);
  
  defaultMaterial = m;
  
  {
    int[] newFace = {v1,v2,v3,v4};
    addToFaces(newFace);
  }

}

void add_Mesh4(int m, float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3, float x4, float y4, float z4) {

  int v1 = addToVertices(x1,y1,z1);
  int v2 = addToVertices(x2,y2,z2);
  int v3 = addToVertices(x3,y3,z3);
  int v4 = addToVertices(x4,y4,z4);

  defaultMaterial = m;
  
  {
    int[] newFace = {v1,v2,v3,v4};
    addToFaces(newFace);
  }

}

void add_Mesh3(int m, float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3) {

  int v1 = addToVertices(x1,y1,z1);
  int v2 = addToVertices(x2,y2,z2);
  int v3 = addToVertices(x3,y3,z3);

  defaultMaterial = m;

  {
    int[] newFace = {v1,v2,v3};
    addToFaces(newFace);
  }

}

void add_Mesh5(int m, float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3, float x4, float y4, float z4, float x5, float y5, float z5) {

  int v1 = addToVertices(x1,y1,z1);
  int v2 = addToVertices(x2,y2,z2);
  int v3 = addToVertices(x3,y3,z3);
  int v4 = addToVertices(x4,y4,z4);
  int v5 = addToVertices(x5,y5,z5);

  defaultMaterial = m;
  
  {
    int[] newFace = {v1,v2,v3,v4,v5};
    addToFaces(newFace);
  }

}

void add_Pentagon(int m, float cx, float cy, float cz, float r) {

  int v1 = addToVertices(cos_ang(1*72),sin_ang(1*72),0);
  int v2 = addToVertices(cos_ang(2*72),sin_ang(2*72),0);
  int v3 = addToVertices(cos_ang(3*72),sin_ang(3*72),0);
  int v4 = addToVertices(cos_ang(4*72),sin_ang(4*72),0);
  int v5 = addToVertices(cos_ang(5*72),sin_ang(5*72),0);

  defaultMaterial = m;
    
  {
    int[] newFace = {v1,v2,v3,v4,v5};
    addToFaces(newFace);
  }

}

void add_Polygon(int m, float cx, float cy, float cz, float r, int n) {

  int[] newFace = {addToVertices(cx + r * cos_ang(0), cy + r * sin_ang(0), cz)};
  for (int i = 1; i < n; i++) {
    float t = i * 360.0 / float(n);
    int[] f = {addToVertices(cx + r * cos_ang(t), cy + r * sin_ang(t), cz)};
    newFace = concat(newFace, f);
  } 
 
  defaultMaterial = m;

  addToFaces(newFace);

}

void add_PolygonExtrude(int m, float cx, float cy, float cz, float r, float h, int n) {

  int[] vT = new int[n];
  int[] vB = new int[n];
  
  vT[0] = addToVertices(cx + r * cos_ang(0), cy + r * sin_ang(0), cz + h);
  vB[0] = addToVertices(cx + r * cos_ang(0), cy + r * sin_ang(0), cz);
  
  int[] newFaceT = {vT[0]};
  int[] newFaceB = {vB[0]};
  for (int i = 1; i < n; i++) {
    float t = i * 360.0 / float(n);
    
    vT[i] = addToVertices(cx + r * cos_ang(t), cy + r * sin_ang(t), cz + h);
    vB[i] = addToVertices(cx + r * cos_ang(t), cy + r * sin_ang(t), cz);
    int[] fT = {vT[i]};
    int[] fB = {vB[i]};
    
    newFaceT = concat(newFaceT, fT);
    newFaceB = concat(newFaceB, fB);
  } 
 
  if (m == -1) defaultMaterial = 1;
  else defaultMaterial = m;

  addToFaces(newFaceT);
  addToFaces(newFaceB);
  
  for (int i = 0; i < n; i++) {
    int next_i = (i + 1) % n;
   
    int[] newFace = {vT[i], vT[next_i], vB[next_i], vB[i]};
    if (m == -1) defaultMaterial += 1;    
    addToFaces(newFace);
  }

}



void LoadWorldImages () {

  WORLD_VIEW_Filename = sort(getfiles(WorldViewFolder));

  number_of_WORLD_viewports = WORLD_VIEW_Filename.length;

  WORLD_VIEW_Name = new String[number_of_WORLD_viewports][2];
  
  WORLD_VIEW_BoundariesX = new float[number_of_WORLD_viewports][2];
  WORLD_VIEW_BoundariesY = new float[number_of_WORLD_viewports][2];
    
  WORLD_VIEW_GridDisplay = new int[number_of_WORLD_viewports];
  

  
  
  for (int i = 0; i < number_of_WORLD_viewports; i += 1) {
    String MapFilename = WorldViewFolder + "/" + WORLD_VIEW_Filename[i];
    
    String[] Parts = split(WORLD_VIEW_Filename[i], '_');
    
    WORLD_VIEW_BoundariesX[i][0] = -float(Parts[1]) * 0.001;
    WORLD_VIEW_BoundariesY[i][0] =  float(Parts[2]) * 0.001;
    WORLD_VIEW_BoundariesX[i][1] = -float(Parts[3]) * 0.001;
    WORLD_VIEW_BoundariesY[i][1] =  float(Parts[4]) * 0.001;
    
    WORLD_VIEW_Name[i][0] = Parts[5];
    WORLD_VIEW_Name[i][1] = Parts[6];
    
    float a = (WORLD_VIEW_BoundariesY[i][1] - WORLD_VIEW_BoundariesY[i][0]) / 2;
    if (a < 1) a = 1;
    WORLD_VIEW_GridDisplay[i] = int(a);
    
  }      
}

int FindGoodViewport (float pointLongitude, float pointLatitude) {
  int return_VIEWPORT = 0;
  
  float d = FLOAT_undefined;
  for (int i = 0; i < number_of_WORLD_viewports; i++) {
    if (isInside(pointLongitude, pointLatitude, WORLD_VIEW_BoundariesX[i][0], WORLD_VIEW_BoundariesY[i][0], WORLD_VIEW_BoundariesX[i][1], WORLD_VIEW_BoundariesY[i][1]) == 1) {
      float di = dist(WORLD_VIEW_BoundariesX[i][0], WORLD_VIEW_BoundariesY[i][0], WORLD_VIEW_BoundariesX[i][1], WORLD_VIEW_BoundariesY[i][1]);
      
      if (d > di) {
        d = di;
        return_VIEWPORT = i;
      }
    }
  }
  
  WORLD_Update = 1;
  
  return (return_VIEWPORT);
}

int isInside (float x, float y, float x1, float y1, float x2, float y2) {
  if ((x1 < x) && (x < x2) && (y1 < y) && (y < y2)) return 1;
  else return 0;
} 

String StationICAO;
String StationType;

float StationLatitude;
float StationLongitude;
float StationElevation;

int STATION_SWOB_NUMBER = 0;
String[][] STATION_SWOB_INFO;

void getSWOB_Coordinates () {
  try {
    String[] FileALL = loadStrings(SWOBFolder + "/SWOB_UTF8.txt");
  
    String lineSTR;
    String[] input;
  
    STATION_SWOB_NUMBER = FileALL.length - 1; // to skip the first description line 
  
    STATION_SWOB_INFO = new String[STATION_SWOB_NUMBER][11]; 
  
    int n_Locations = 0;
  
    for (int f = 0; f < STATION_SWOB_NUMBER; f += 1) {
      lineSTR = FileALL[f + 1]; // to skip the first description line  
  
      String StationNameEnglish = "";
      String StationNameFrench = "";
      String StationProvince = "";
      float StationLatitude = 0.0;
      float StationLongitude = 0.0;
      float StationElevation = 0.0;  
      String StationICAO = "";
      String StationWMO = "";     
      String StationClimate = "";
      String StationDST = ""; //Daylight saving time
      String StationSTD = ""; //Standard Time      
  
      String[] parts = split(lineSTR, '\t');
  
      if (12 < parts.length) {
        
        StationNameFrench = parts[1];
        StationNameEnglish = parts[2];
        StationProvince = parts[3];
    
        StationLatitude = float(parts[5]);
        StationLongitude = float(parts[6]);
        StationElevation = float(parts[7]);
    
        StationICAO = parts[8];
        StationWMO = parts[9];
        StationClimate = parts[10];
        StationDST = parts[11];
        StationSTD = parts[12];      
    
        STATION_SWOB_INFO[n_Locations][0] = StationNameEnglish;
        STATION_SWOB_INFO[n_Locations][1] = StationNameFrench;
        STATION_SWOB_INFO[n_Locations][2] = StationProvince;
        STATION_SWOB_INFO[n_Locations][3] = String.valueOf(StationLatitude);
        STATION_SWOB_INFO[n_Locations][4] = String.valueOf(StationLongitude);
        STATION_SWOB_INFO[n_Locations][5] = String.valueOf(StationElevation);
        STATION_SWOB_INFO[n_Locations][6] = StationICAO;
        STATION_SWOB_INFO[n_Locations][7] = StationWMO;
        STATION_SWOB_INFO[n_Locations][8] = StationClimate;
        STATION_SWOB_INFO[n_Locations][9] = StationDST;
        STATION_SWOB_INFO[n_Locations][10] = StationSTD;
  
        n_Locations += 1;
      }
    }
  }
  catch (Exception e) {
    println("ERROR reading SWOB coordinates.");
  }
}



int STATION_NAEFS_NUMBER = 0;
String[][] STATION_NAEFS_INFO;

void getNAEFS_Coordinates () {
  try {
    String[] FileALL = loadStrings(NAEFSFolder + "/NAEFS_UTF8.txt");
  
    String lineSTR;
    String[] input;
  
    STATION_NAEFS_NUMBER = FileALL.length - 1; // to skip the first description line 
  
    STATION_NAEFS_INFO = new String[STATION_NAEFS_NUMBER][11]; 
  
    int n_Locations = 0;
  
    for (int f = 0; f < STATION_NAEFS_NUMBER; f += 1) {
      lineSTR = FileALL[f + 1]; // to skip the first description line  
  
      String StationNameEnglish = "";
      float StationLatitude = 0.0;
      float StationLongitude = 0.0;
      float StationElevation = 0.0;  
  
      String[] parts = split(lineSTR, '\t');
  
      if (3 < parts.length) {
        
        StationNameEnglish = parts[0];
    
        int l = 0;
        
        l = parts[1].length();
        if (((parts[1].substring(l - 1, l)).equals("N")) || ((parts[1].substring(l - 1, l)).equals("S"))) {
          String[] the_parts = split(parts[1], ':');
          StationLatitude = float(the_parts[0]) + (float(the_parts[1]) / 60.0) + (float(the_parts[2]) / 3600.0);
          if ((parts[1].substring(l - 1, l)).equals("S")) StationLatitude *= -1;
        }
        else{
          StationLatitude = float(parts[1]);
        }
  
        l = parts[2].length();
        if (((parts[2].substring(l - 1, l)).equals("E")) || ((parts[2].substring(l - 1, l)).equals("W"))) {
          String[] the_parts = split(parts[2], ':');
          StationLongitude = float(the_parts[0]) + (float(the_parts[1]) / 60.0) + (float(the_parts[2]) / 3600.0);
          if ((parts[2].substring(l - 1, l)).equals("W")) StationLongitude *= -1;
        }
        else{
          StationLongitude = float(parts[2]);
        }
  
        l = parts[3].length();
        StationElevation = float(parts[3].substring(0, l - 1));
    
        STATION_NAEFS_INFO[n_Locations][0] = StationNameEnglish;
        STATION_NAEFS_INFO[n_Locations][1] = String.valueOf(StationLatitude);
        STATION_NAEFS_INFO[n_Locations][2] = String.valueOf(StationLongitude);
        STATION_NAEFS_INFO[n_Locations][3] = String.valueOf(StationElevation);
  
        n_Locations += 1;
      }
    }
  }
  catch (Exception e) {
    println("ERROR reading NAEFS coordinates.");
  }
}


int STATION_CWEEDS_NUMBER = 0;
String[][] STATION_CWEEDS_INFO;

void getCWEEDS_Coordinates () {
  try {
    String[] FileALL = loadStrings(CWEEDSFolder + "/CWEEDS_UTF8.txt");
  
    String lineSTR;
    String[] input;
  
    STATION_CWEEDS_NUMBER = FileALL.length - 1; // to skip the first description line 
  
    STATION_CWEEDS_INFO = new String[STATION_CWEEDS_NUMBER][11]; 
  
    int n_Locations = 0;
  
    for (int f = 0; f < STATION_CWEEDS_NUMBER; f += 1) {
      lineSTR = FileALL[f + 1]; // to skip the first description line  

      String StationNameEnglish = "";
      String StationProvince = "";
      String StationCountry = "";
      float StationLatitude = 0.0;
      float StationLongitude = 0.0;
      float StationElevation = 0.0;   
      
      String[] parts = split(lineSTR, '_');
      
      if (4 < parts.length) {
  
        StationCountry = "CA";
        StationProvince = parts[0];
        StationNameEnglish = parts[1];
    
        
        StationLatitude = float(parts[2]) * 0.01;
        StationLongitude = float(parts[3]) * -0.01;
        StationElevation = 0; // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
        STATION_CWEEDS_INFO[n_Locations][0] = StationNameEnglish;
        STATION_CWEEDS_INFO[n_Locations][1] = StationProvince;
        STATION_CWEEDS_INFO[n_Locations][2] = StationCountry;
        STATION_CWEEDS_INFO[n_Locations][3] = String.valueOf(StationLatitude);
        STATION_CWEEDS_INFO[n_Locations][4] = String.valueOf(StationLongitude);
        STATION_CWEEDS_INFO[n_Locations][5] = String.valueOf(StationElevation);
  
        n_Locations += 1;
      }
    }
  }
  catch (Exception e) {
    println("ERROR reading CWEEDS coordinates.");
  }
}
