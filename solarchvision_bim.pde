SOLARCHVISION_SunPath SunPath1 = new SOLARCHVISION_SunPath(); 

String StationName = ""; 
float StationLatitude = 0;
float StationLongitude = 0;
float Delta_NOON = 0;
float StationElevation = 0;

float[][][] EPW;

int _drybulb = 0;
int _relhum = 1;
int _glohorrad = 2;
int _dirnorrad = 3;
int _difhorrad = 4;
int _winddir = 5;
int _windspd = 6;

int X_View = 500;
int Y_View = 500;
float R_View = float(Y_View) / float(X_View);

String _Filename = "Diagram";

float X_coordinate = 0 * X_View;
float Y_coordinate = 1 * Y_View;
float Z_coordinate = 0;
float S_coordinate = 5.0;

float RX_coordinate = 45;
float RY_coordinate = 0;
float RZ_coordinate = -45;
float RS_coordinate = 5.0;

float ZOOM_coordinate = 20000 / X_View;

int View_Type = 0; // 0: Ortho 1: Perspective
{
  if (View_Type == 1) {
    X_coordinate += 0.5 * X_View; 
    Y_coordinate += -0.5 * Y_View;
  }
}

void setup() 
{
  size(X_View, Y_View, P3D);
  frameRate(24);
  
  
  
  //LoadEPW("C:/SOLARCHVISION_2015/Input/WeatherClimate/CLIMATE_EPW/LAS_VEGAS_NV_US.epw");
  //LoadEPW("C:/SOLARCHVISION_2015/Input/WeatherClimate/CLIMATE_EPW/HOUSTON_TX_US.epw");
  LoadEPW("C:/SOLARCHVISION_2015/Input/WeatherClimate/CLIMATE_EPW/MONTREAL_DORVAL_QC_CA.epw");
  

  
  //noLoop();
}



void draw() { 
  background(233);
  
  
  //camera(10.0, 10.0, 10.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
  //frustum(-10, 10, -10, 10, 0.001, 1000);
  //perspective(ZOOM_coordinate * PI/180,X_View/Y_View,0.001,1000);  //fovy, aspect, zNear, zFar

  if (View_Type == 1) {
    perspective(ZOOM_coordinate * PI/180, X_View/Y_View, 0.00001, 100000);  //fovy, aspect, zNear, zFar
  }
  else{
    float ZOOM = 0.4567 * ZOOM_coordinate * PI/180; 
    ortho(ZOOM * X_View * -1, ZOOM * X_View * 1, ZOOM  * Y_View * -1, ZOOM  * Y_View * 1, 0.00001, 100000);
  }


  
  //lights();
  
  
  translate(X_coordinate, Y_coordinate, Z_coordinate);
  rotateX(RX_coordinate * PI/180);
  rotateY(RY_coordinate * PI/180);
  rotateZ(RZ_coordinate * PI/180);
  
  fill(255);
  box(10, 10, 10);
  line (0, 0, 0, 0, 0, 50);
  
  SunPath1.update(0, 0, 0, 90, StationLatitude); 

} 
 
class SOLARCHVISION_SunPath { 
  float x_SunPath, y_SunPath, z_SunPath, s_SunPath;
  float StationLatitude; 
  SOLARCHVISION_SunPath () {  
  } 
  void update(float x, float y, float z, float s, float l) {
    x_SunPath = x; 
    y_SunPath = y;
    z_SunPath = z;
    s_SunPath = s; 
    StationLatitude = l;
 
    float min_sunrise = int(min(SOLARCHVISION_Sunrise(StationLatitude, 90), SOLARCHVISION_Sunrise(StationLatitude, 270))); 
    float max_sunset = int(max(SOLARCHVISION_Sunset(StationLatitude, 90), SOLARCHVISION_Sunset(StationLatitude, 270)));
   
    
    pushMatrix();
    translate(x_SunPath, y_SunPath, z_SunPath);
    
    line(-0.1 * s_SunPath, 0, 0, 0.1 * s_SunPath, 0, 0); 
    line(0, -0.1 * s_SunPath, 0, 0, 0.1 * s_SunPath, 0);
/*
    for (int DATE = 90; DATE <= 270; DATE += 30){
      float HOUR_step = (DayTime (StationLatitude, DATE) / 18.0);
      for (float HOUR = Sunrise(StationLatitude, DATE); HOUR < (Sunset(StationLatitude, DATE) + .01); HOUR += HOUR_step) {
        float[] Sun = SunPosition (StationLatitude, DATE, HOUR);
        point (s_SunPath * Sun[1], s_SunPath * Sun[2], s_SunPath * Sun[3]);
      }
    }
*/
    
    
    
    stroke(255,255,0);
    
    for (float HOUR = min_sunrise; HOUR < max_sunset + .01; HOUR += 1){
      float DATE_step = 4; //1;
      
      for (int DATE = 90; DATE <= 270; DATE += DATE_step){
        
        float[] Sun = SOLARCHVISION_SunPosition (StationLatitude, DATE, HOUR);
        
        if (Sun[3] >= 0) {
          float DIR_RAD1 = EPW[int(HOUR)][int(DATE)][_dirnorrad];
          float NEED_SS1 = 18 - EPW[int(HOUR)][int(DATE)][_drybulb];
          
          float DIR_RAD2 = EPW[int(HOUR)][int((DATE + 180) % 360)][_dirnorrad];
          float NEED_SS2 = 18 - EPW[int(HOUR)][int((DATE + 180) % 360)][_drybulb];
          
          float v = NEED_SS1;
          if (abs(NEED_SS2) > abs(v)) {
            v =  NEED_SS2;
          }
          
          float[] COL = SOLARCHVISION_DRYWCBD(v * 0.05);
  
          stroke(COL[1], COL[2], COL[3]);
  
          //float _effect = (1 - 0.03 * v);
          //line (s_SunPath * Sun[1], s_SunPath * Sun[2], s_SunPath * Sun[3], _effect * s_SunPath * Sun[1], _effect * s_SunPath * Sun[2], _effect * s_SunPath * Sun[3]);
          
          fill(COL[1], COL[2], COL[3]);
          
          float[] SunA = SOLARCHVISION_SunPosition (StationLatitude, DATE - 0.5 * DATE_step, HOUR - 0.5);
          float[] SunB = SOLARCHVISION_SunPosition (StationLatitude, DATE - 0.5 * DATE_step, HOUR + 0.5);
          float[] SunC = SOLARCHVISION_SunPosition (StationLatitude, DATE + 0.5 * DATE_step, HOUR + 0.5);
          float[] SunD = SOLARCHVISION_SunPosition (StationLatitude, DATE + 0.5 * DATE_step, HOUR - 0.5);
          
          beginShape();
          vertex(s_SunPath * SunA[1], s_SunPath * SunA[2], s_SunPath * SunA[3]);
          vertex(s_SunPath * SunB[1], s_SunPath * SunB[2], s_SunPath * SunB[3]);
          vertex(s_SunPath * SunC[1], s_SunPath * SunC[2], s_SunPath * SunC[3]);
          vertex(s_SunPath * SunD[1], s_SunPath * SunD[2], s_SunPath * SunD[3]);

          endShape(CLOSE);
        }
      }
    }
    
    stroke(0);
    
    for (int DATE = 90; DATE <= 270; DATE += 30){
      float HOUR_step = (SOLARCHVISION_DayTime (StationLatitude, DATE) / 72.0);
      for (float HOUR = SOLARCHVISION_Sunrise(StationLatitude, DATE); HOUR < (SOLARCHVISION_Sunset(StationLatitude, DATE) + .01 - HOUR_step); HOUR += HOUR_step){
        float[] SunA = SOLARCHVISION_SunPosition (StationLatitude, DATE, HOUR);
        float[] SunB = SOLARCHVISION_SunPosition (StationLatitude, DATE, (HOUR + HOUR_step));
        line (s_SunPath * SunA[1], s_SunPath * SunA[2], s_SunPath * SunA[3], s_SunPath * SunB[1], s_SunPath * SunB[2], s_SunPath * SunB[3]);
      }
    }
    
    for (float HOUR = min_sunrise; HOUR < max_sunset + .01; HOUR += 1){
      float DATE_step = 1;
      for (int DATE = 90; DATE <= 270; DATE += DATE_step){
        float[] SunA = SOLARCHVISION_SunPosition (StationLatitude, DATE, HOUR);
        float[] SunB = SOLARCHVISION_SunPosition (StationLatitude, (DATE + DATE_step), HOUR);
        if (SunA[3] >= 0 && SunB[3] >= 0) {
          line (s_SunPath * SunA[1], s_SunPath * SunA[2], s_SunPath * SunA[3], s_SunPath * SunB[1], s_SunPath * SunB[2], s_SunPath * SunB[3]);
        }
      }
    }
    
    popMatrix();

    stroke(0);
    for (int i = 0; i < 360; i = i + 5){
      line (s_SunPath * cos(i * PI/180), s_SunPath * sin(i * PI/180), 0, s_SunPath * cos((i + 5) * PI/180), s_SunPath * sin((i + 5) * PI/180), 0);  
    }
    
    for (int i = 0; i < 360; i = i + 90){
      pushMatrix();
      translate(1.1 * s_SunPath * cos(i * PI/180),1.1 * s_SunPath * sin (i * PI/180),0);
      rotateZ(PI);
      
      
      fill(0);
      textSize(s_SunPath * 0.1);
      textAlign(CENTER, CENTER);
      text(String.valueOf(((i - 90) % 360)), 0,0,0);
      popMatrix();
    }    
    
    
 
  } 
} 




void keyPressed(){
  //println("key: "+key);
  //println("keyCode: "+keyCode); 
  
  if(key == CODED) { 
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
                RZ_coordinate = 180; 
                ZOOM_coordinate = 20000 / X_View;            
                X_coordinate = 0.5 * X_View;
                Y_coordinate = 0.5 * Y_View;
                Z_coordinate = 0;
                View_Type = 1; 
                break;
      
      
      
      case ',' :ZOOM_coordinate = 2 * atan_ang((1.0 / 1.1) * tan_ang(0.5 * ZOOM_coordinate)); break;
      case '.' :ZOOM_coordinate = 2 * atan_ang((1.1 / 1.0) * tan_ang(0.5 * ZOOM_coordinate)); break;
      
      case 'o' :if (View_Type != 0) {View_Type = 0; X_coordinate -= 0.5 * X_View; Y_coordinate -= -0.5 * Y_View;}
                break;
      case 'p' :if (View_Type != 1) {View_Type = 1; X_coordinate += 0.5 * X_View; Y_coordinate += -0.5 * Y_View;} 
                break;
          
      case '$' :saveFrame("SOLARCHVISION_PLOT_" + _Filename + ".jpg"); println("File created."); break;
      case '#' :saveFrame("SOLARCHVISION_PLOT_" + _Filename + "_frame####.jpg"); println("File created."); break;
    }

  }
  
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
 return ((asin(a)) * 180/PI); 
}

float acos_ang (float a) {
 return ((acos(a)) * 180/PI); 
}

float atan_ang (float a) {
 return ((atan(a)) * 180/PI); 
}


float[] SOLARCHVISION_SunPosition (float StationLatitude, float DATE, float HOUR) {
  float DEC = 23.45 * sin_ang(DATE - 180.0);
  
  float a = sin_ang(DEC);
  float b = cos_ang(DEC) * -cos_ang(15.0 * HOUR);
  float c = cos_ang(DEC) *  sin_ang(15.0 * HOUR);
  
  float x = c; 
  float y = -(a * cos_ang(StationLatitude) + b * sin_ang(StationLatitude));
  float z = -a * sin_ang(StationLatitude) + b * cos_ang(StationLatitude);
  
  float[] return_array = {0, x, y, z}; 
  return return_array; 
}

float SOLARCHVISION_Sunrise (float StationLatitude, float DATE) {
  float DEC = 23.5 * sin_ang(DATE - 180.0);
  
  float q = -(tan_ang(DEC) * tan_ang(StationLatitude));
  if (q > 1.0) {
    return 0.0;
  }
  else if (q < -1.0) {
    return 24.0;
  }
  else return (acos_ang(q) / 15.0);
}

float SOLARCHVISION_Sunset (float StationLatitude, float DATE) {
  return (24.0 - SOLARCHVISION_Sunrise(StationLatitude, DATE));
}

float SOLARCHVISION_DayTime (float StationLatitude, float DATE) {
  return abs((SOLARCHVISION_Sunset(StationLatitude, DATE)) - (SOLARCHVISION_Sunrise(StationLatitude, DATE)));
}



void LoadEPW (String FileName) {
  BufferedReader FileSTR = createReader(FileName);
  String lineSTR;
  String[] input;
  
  EPW = new float [24][365][7];

  try {
    lineSTR = FileSTR.readLine();

    input = split(lineSTR, ',');

    StationName = input[1];
    StationLatitude = float(input[6]);
    StationLongitude = - float(input[7]);
    Delta_NOON = float(input[8]) + StationLongitude / 15.0;
    StationElevation = float(input[9]);
    
    println(StationName); 
    println(StationLatitude);
    println(StationLongitude);
    println(Delta_NOON);
    println(StationElevation);
    
    int _OK = 1;
    while (_OK == 1){
      lineSTR = FileSTR.readLine();

      input = split(lineSTR, ',');
      
      if (input[0].equals("DATA PERIODS")) {
        _OK = 0;
      }
    }
    

    
    for (int k = 1; k < 365; k += 1){
      for (int i = 1; i < 24; i += 1){
        lineSTR = FileSTR.readLine();
        
        input = split(lineSTR, ',');
        
        EPW[i][k][_drybulb] = float(input[6]);
        EPW[i][k][_relhum] = float(input[8]);
        EPW[i][k][_glohorrad] = float(input[13]);
        EPW[i][k][_dirnorrad] = float(input[14]);
        EPW[i][k][_difhorrad] = float(input[15]);
        EPW[i][k][_winddir] = float(input[20]);
        if (EPW[i][k][_winddir] < 45) {
          EPW[i][k][_winddir] += 360;
        }
        EPW[i][k][_windspd] = float(input[21]);

      }
    }
     
    println ("Climate Created Successfully.");
  }
  
  catch (IOException e) {
    println("Unable to read the whole file!");  
  }

}


float[] SOLARCHVISION_DRYWCBD (float _variable) {
  _variable *= 2.75;
  
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



