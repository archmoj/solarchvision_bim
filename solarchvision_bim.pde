int X_View = 600;
int Y_View = 600;
float R_View = float(Y_View) / float(X_View);

float X_coordinate = 0 * X_View;
float Y_coordinate = 0 * Y_View;
float Z_coordinate = -100;
float S_coordinate = 5.0;

float RX_coordinate = 0;
float RY_coordinate = 0;
float RZ_coordinate = 0;
float RS_coordinate = 5.0;

float ZOOM_coordinate = 17500.0 / Y_View;

int View_Type = 0; // 0: Ortho 1: Perspective

int _MONTH = -1;
int _DAY = -1; 
int _HOUR = -1; 
float _DATE = -1;

String _Filename = "";

String _undefined = "N/A";
float FLOAT_undefined = 1000000000; // it must be a positive big number that is not included in any data

int STATION_NUMBER = 14; 

String[][] DEFINED_STATIONS = {
  
                                {"MOSCOW_XX_RU", "MOSCOW", "XX", "55.75", "37.63", "45", "156.0"}, 
                                {"Istanbul_XX_TR", "Istanbul", "XX", "40.97", "28.82", "30", "37.0"}, 
                                {"Barcelona_XX_SP", "Barcelona", "XX", "41.28", "2.07", "15", "6.0"}, 
                                {"Bologna_XX_IT", "Bologna", "XX", "44.53", "11.30", "15", "49.0"}, 
                                {"VIENNA_XX_AT", "VIENNA", "XX", "48.12", "16.57", "15", "190.0"}, 
                                
                                {"VANCOUVER_INTL_BC_CA", "VANCOUVER", "BC", "49.25", "-123.25", "-120", "4.30"}, 
                                {"MONTREAL_DORVAL_QC_CA", "MONTREAL", "QC", "45.47", "-73.75", "-75", "31.00"}, 

                                {"NEW_YORK_CITY_NY_US", "NEW_YORK_CITY", "NY", "40.712784", "-74.00594", "-75", "10.0"}, 
                                {"WASHINGTON_DC_US", "WASHINGTON", "DC", "38.907192", "-77.03687", "-75", "22.0"}, 
                                {"LOS_ANGELES_CA_US", "LOS_ANGELES", "CA", "34.052235", "-118.24368", "-120", "87.0"}, 
                                {"CHICAGO_IL_US", "CHICAGO", "IL", "41.878113", "-87.6298", "-90", "181.0"}, 
                                {"HOUSTON_TX_US", "HOUSTON", "TX", "29.760193", "-95.36939", "-90", "15.0"}, 
                                {"MIAMI_FL_US", "MIAMI", "FL", "25.789097", "-80.20404", "-75", "3.0"}, 
                                {"BOSTON_MA_US", "BOSTON", "MA", "42.35843", "-71.05978", "-75", "15.0"}, 
                                {"LAS_VEGAS_NV_US", "LAS_VEGAS", "NV", "36.16994", "-115.13983", "-120", "611.0"}, 
                                {"DENVER_CO_US", "DENVER", "CO", "39.737568", "-104.98472", "-105", "1608.0"}, 
                             
                              };




String CLIMATE_directory = "C:/SOLARCHVISION_2015/Input/WeatherClimate/CLIMATE_EPW";

String[] CLIMATE_EPW_Files = getfiles(CLIMATE_directory);

String THE_STATION;
String StationName;
String StationProvince;
float StationLatitude;
float StationLongitude;
float StationTimeZone;
float StationElevation;
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


void setup () 
{
  size(X_View, Y_View, P3D);
  
  frameRate(24);
  
  SOLARCHVISION_Calendar();  

  _update_station();

  _update_objects();

  LoadFontStyle();
  
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
  
  add_Mesh2(7, -4,-4,0, 4,4,0);
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
    
    stroke(0, 0, 0);
    fill (c);    
    
    beginShape();
    for (int j = 0; j < allFaces[i].length; j++) {
      vertex(allVertices[allFaces[i][j]][0] * objects_scale, allVertices[allFaces[i][j]][1] * objects_scale, allVertices[allFaces[i][j]][2] * objects_scale);
    }
    endShape(CLOSE);
  }

}



void draw () { 
  background(233);
  
  if (View_Type == 1) {
    perspective(ZOOM_coordinate * PI/180, 1.0 / R_View, 0.00001, 100000);  //fovy, aspect, zNear, zFar
    
    translate(0.5 * X_View, 0.5 * Y_View, 0); // << IMPORTANT! 
  }
  else{
    float ZOOM = 0.4425 * ZOOM_coordinate * PI/180; 
    //float ZOOM = 0.0025 * atan_ang(ZOOM_coordinate);
    
    ortho(ZOOM * X_View * -1, ZOOM * X_View * 1, ZOOM  * Y_View * -1, ZOOM  * Y_View * 1, 0.00001, 100000);
    
    translate(0, 1.0 * Y_View, 0); // << IMPORTANT! 
  }

  //lights();


  
  pushMatrix();
  
  translate(0, 0, 0);
  
  fill(0);
  textSize(10.0 * (ZOOM_coordinate / 30));
  textAlign(CENTER, CENTER);    
  text(StationName + " [" + nfp(StationLatitude, 0, 1) + ", " + nfp(StationLongitude, 0, 1) + "]", 0, 120 * (ZOOM_coordinate / 30), 0);
 
  popMatrix();

  translate(X_coordinate, Y_coordinate, Z_coordinate);
  rotateX(RX_coordinate * PI/180);
  rotateY(RY_coordinate * PI/180);
  rotateZ(RZ_coordinate * PI/180);
  
  
  
  fill(127);


  //hint(DISABLE_DEPTH_TEST);

  _draw_objects();
  
  SOLARCHVISION_SunPath(0, 0, 0, 90, StationLatitude); 

  //hint(ENABLE_DEPTH_TEST);

  noLoop();
} 
 
void SOLARCHVISION_SunPath (float x_SunPath, float y_SunPath, float z_SunPath, float s_SunPath, float StationLatitude) { 

  float min_sunrise = int(min(SOLARCHVISION_Sunrise(StationLatitude, 90), SOLARCHVISION_Sunrise(StationLatitude, 270))); 
  float max_sunset = int(max(SOLARCHVISION_Sunset(StationLatitude, 90), SOLARCHVISION_Sunset(StationLatitude, 270)));
 
  
  pushMatrix();
  translate(x_SunPath, y_SunPath, z_SunPath);
  
  line(-1 * s_SunPath, 0, 0, 1 * s_SunPath, 0, 0); 
  line(0, -1 * s_SunPath, 0, 0, 1 * s_SunPath, 0);

  stroke(255, 255, 0);
  
  for (int HOUR = int(roundTo(min_sunrise, 1.0)); HOUR < int(roundTo(max_sunset, 1.0)); HOUR += 1){
    int DATE_step = 1;
    
    for (int DATE_ANGLE = 0; DATE_ANGLE < 360; DATE_ANGLE += DATE_step){
        
      _DATE = Convert2Day(DATE_ANGLE);
  
      _update_date();
      
      //println(_DATE, _MONTH, _DAY, DATE_ANGLE); exit();
     
      float[] Sun = SOLARCHVISION_SunPosition(StationLatitude, DATE_ANGLE, HOUR);
      
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
  
          stroke(COL[1], COL[2], COL[3], 127);
          fill(COL[1], COL[2], COL[3], 127);
          
          float[] SunA = SOLARCHVISION_SunPosition(StationLatitude, DATE_ANGLE - 0.5 * DATE_step, HOUR - 0.5);
          float[] SunB = SOLARCHVISION_SunPosition(StationLatitude, DATE_ANGLE - 0.5 * DATE_step, HOUR + 0.5);
          float[] SunC = SOLARCHVISION_SunPosition(StationLatitude, DATE_ANGLE + 0.5 * DATE_step, HOUR + 0.5);
          float[] SunD = SOLARCHVISION_SunPosition(StationLatitude, DATE_ANGLE + 0.5 * DATE_step, HOUR - 0.5);
          
          beginShape();
          vertex(s_SunPath * SunA[1], -s_SunPath * SunA[2], s_SunPath * SunA[3]);
          vertex(s_SunPath * SunB[1], -s_SunPath * SunB[2], s_SunPath * SunB[3]);
          vertex(s_SunPath * SunC[1], -s_SunPath * SunC[2], s_SunPath * SunC[3]);
          vertex(s_SunPath * SunD[1], -s_SunPath * SunD[2], s_SunPath * SunD[3]);

          endShape(CLOSE);
          
        }
      }

    }
  }
  
  stroke(0);
  
  for (int j = 90; j <= 270; j += 30){
    float HOUR_step = (SOLARCHVISION_DayTime(StationLatitude, j) / 12.0);
    for (float HOUR = SOLARCHVISION_Sunrise(StationLatitude, j); HOUR <(SOLARCHVISION_Sunset(StationLatitude, j) + .01 - HOUR_step); HOUR += HOUR_step){
      float[] SunA = SOLARCHVISION_SunPosition(StationLatitude, j, HOUR);
      float[] SunB = SOLARCHVISION_SunPosition(StationLatitude, j, (HOUR + HOUR_step));
      line(s_SunPath * SunA[1], -s_SunPath * SunA[2], s_SunPath * SunA[3], s_SunPath * SunB[1], -s_SunPath * SunB[2], s_SunPath * SunB[3]);
    }
  }
  
  for (float HOUR = min_sunrise; HOUR < max_sunset + .01; HOUR += 1){
    float DATE_step = 1;
    for (int j = 0; j <= 360; j += DATE_step){
      float[] SunA = SOLARCHVISION_SunPosition(StationLatitude, j, HOUR);
      float[] SunB = SOLARCHVISION_SunPosition(StationLatitude, (j + DATE_step), HOUR);
      if (SunA[3] >= 0 && SunB[3] >= 0) {
        line(s_SunPath * SunA[1], -s_SunPath * SunA[2], s_SunPath * SunA[3], s_SunPath * SunB[1], -s_SunPath * SunB[2], s_SunPath * SunB[3]);
      }
    }
  }
  
  popMatrix();

  stroke(0);
  for (int i = 0; i < 360; i += 5){
    line(s_SunPath * cos(i * PI/180), -s_SunPath * sin(i * PI/180), 0, s_SunPath * cos((i + 5) * PI/180), -s_SunPath * sin((i + 5) * PI/180), 0);  
    
    line(s_SunPath * cos(i * PI/180), -s_SunPath * sin(i * PI/180), 0, 1.05 * s_SunPath * cos((i) * PI/180), -1.05 * s_SunPath * sin((i) * PI/180), 0);
  }
  
  for (int i = 0; i < 360; i += 15){
    pushMatrix();
    translate(1.15 * s_SunPath * cos(i * PI/180), -1.15 * s_SunPath * sin(i * PI/180), 0);
    
    fill(0);
    textSize(s_SunPath * 0.05);
    textAlign(CENTER, CENTER);
    
    String txt = nf((90 - i + 360) % 360, 0);
    if (i == 0) {txt = "E"; textSize(s_SunPath * 0.1);}
    else if (i == 90) {txt = "N"; textSize(s_SunPath * 0.1);}
    else if (i == 180) {txt = "W"; textSize(s_SunPath * 0.1);}
    else if (i == 270) {txt = "S"; textSize(s_SunPath * 0.1);}
    
    text(txt, 0, 0, 0);
    
    popMatrix();
  }    
} 




void keyPressed (){
  //println("key: " + key);
  //println("keyCode: " + keyCode); 
  
  if (key == CODED) { 
    switch(keyCode) {
      case LEFT  :X_coordinate -= S_coordinate; break;
      case RIGHT :X_coordinate += S_coordinate; break;  
      case UP    :Y_coordinate -= S_coordinate; break;
      case DOWN  :Y_coordinate += S_coordinate; break;
    }
  }
  else{
    switch(key) {
      case '<'  :Z_coordinate -= S_coordinate; break;
      case '>' :Z_coordinate += S_coordinate; break;
      
      case '{' :RX_coordinate -= RS_coordinate; break;
      case '}' :RX_coordinate += RS_coordinate; break;
      case '(' :RY_coordinate -= RS_coordinate; break;
      case ')' :RY_coordinate += RS_coordinate; break;
      case '[' :RZ_coordinate -= RS_coordinate; break;
      case ']' :RZ_coordinate += RS_coordinate; break;
      case '@' :RX_coordinate = 0;
                RY_coordinate = 0;
                RZ_coordinate = 0; 
                X_coordinate = 0;
                Y_coordinate = 0;
                Z_coordinate = 0;
                ZOOM_coordinate = 17500.0 / Y_View;
                View_Type = 0; 
                break;

      case '8' :RX_coordinate -= RS_coordinate; break;
      case '2' :RX_coordinate += RS_coordinate; break;
      case '6' :RZ_coordinate -= RS_coordinate; break;
      case '4' :RZ_coordinate += RS_coordinate; break;      

      case '0' :View_Type = 1; Z_coordinate -= S_coordinate; break;
      case '5' :View_Type = 1; Z_coordinate += S_coordinate; break;

      case '*' :objects_scale *= 2.0; break;
      case '/' :objects_scale /= 2.0; break;

      case '+' :ZOOM_coordinate = 2 * atan_ang((1.0 / 1.1) * tan_ang(0.5 * ZOOM_coordinate)); break;
      case '-' :ZOOM_coordinate = 2 * atan_ang((1.1 / 1.0) * tan_ang(0.5 * ZOOM_coordinate)); break;      
      
      case ',' :ZOOM_coordinate = 2 * atan_ang((1.0 / 1.1) * tan_ang(0.5 * ZOOM_coordinate)); break;
      case '.' :ZOOM_coordinate = 2 * atan_ang((1.1 / 1.0) * tan_ang(0.5 * ZOOM_coordinate)); break;
      
      case 'O' :View_Type = 0; break;
      case 'o' :View_Type = 0; break;
      
      case 'P' :View_Type = 1; break;                
      case 'p' :View_Type = 1; break;                
                
      case 'S' :STATION_NUMBER = (STATION_NUMBER + 1) % DEFINED_STATIONS.length; _update_station(); break;
      case 's' :STATION_NUMBER = (STATION_NUMBER - 1 + DEFINED_STATIONS.length) % DEFINED_STATIONS.length; _update_station(); break;
      
      
      case 'F' :LoadFontStyle(); break;
      case 'f' :LoadFontStyle(); break;
           
          
      case '$' :saveFrame("image.jpg"); println("File created."); break;
      case '#' :saveFrame("image_frame####.jpg"); println("File created."); break;
    }

  }
  
  
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

void _update_station () {
  THE_STATION = DEFINED_STATIONS[STATION_NUMBER][0];
  StationName = DEFINED_STATIONS[STATION_NUMBER][1];
  StationProvince = DEFINED_STATIONS[STATION_NUMBER][2];
  StationLatitude = float(DEFINED_STATIONS[STATION_NUMBER][3]);
  StationLongitude = float(DEFINED_STATIONS[STATION_NUMBER][4]);
  StationTimeZone = float(DEFINED_STATIONS[STATION_NUMBER][5]);
  StationElevation = float(DEFINED_STATIONS[STATION_NUMBER][6]);
  Delta_NOON = (StationTimeZone - StationLongitude) / 15.0;
  
  try_update_CLIMATE();
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
