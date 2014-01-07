SOLARCHVISION_SunPath SunPath1 = new SOLARCHVISION_SunPath(0,0,0,90,45); 


int X_View = 500;
int Y_View = 500;

void setup() 
{
  size(X_View, Y_View, P3D);
  frameRate(30);
  
  //noLoop();
}

float X_coordinate = 0.5 * X_View;
float Y_coordinate = 0.5 * Y_View;
float Z_coordinate = 350;
float S_coordinate = 5.0;

float RX_coordinate = 75;
float RY_coordinate = 0;
float RZ_coordinate = -45;
float RS_coordinate = 5.0;

float ZOOM_coordinate = 90.0;


void draw() { 
  background(233);
  
  
  //camera(10.0, 10.0, 10.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
  //frustum(-10, 10, -10, 10, 0.001, 1000);
  perspective(ZOOM_coordinate * PI/180,X_View/Y_View,0.001,1000);  //fovy, aspect, zNear, zFar
  
  lights();
  
  
  translate(X_coordinate, Y_coordinate, Z_coordinate);
  rotateX(RX_coordinate * PI/180);
  rotateY(RY_coordinate * PI/180);
  rotateZ(RZ_coordinate * PI/180);
  
  fill(255);
  box(10, 10, 10);
  
  SunPath1.update(); 

} 
 
class SOLARCHVISION_SunPath { 
  float x_SunPath, y_SunPath, z_SunPath, s_SunPath;
  float StationLatitude; 
  SOLARCHVISION_SunPath (float x, float y, float z, float s, float l) {  
    x_SunPath = x; 
    y_SunPath = y;
    z_SunPath = z;
    s_SunPath = s; 
    StationLatitude = l;
  } 
  void update() { 
    pushMatrix();
    translate(x_SunPath, y_SunPath, z_SunPath);
    
    line(-0.1 * s_SunPath, 0, 0, 0.1 * s_SunPath, 0, 0); 
    line(0, -0.1 * s_SunPath, 0, 0, 0.1 * s_SunPath, 0);
    /*
    for (int DATE = 90; DATE <= 270; DATE += 30){
      float HOUR_step = (DayTime (StationLatitude, DATE) / 120.0);
      for (float HOUR = Sunrise(StationLatitude, DATE); HOUR < (Sunset(StationLatitude, DATE) + .01); HOUR += HOUR_step) {
        float[] Sun = SunPosition (StationLatitude, DATE, HOUR);
        point (s_SunPath * Sun[1], s_SunPath * Sun[2], s_SunPath * Sun[3]);
      }
    }
    */
    
    
    for (int DATE = 90; DATE <= 270; DATE += 30){
      float HOUR_step = (DayTime (StationLatitude, DATE) / 120.0);
      for (float HOUR = Sunrise(StationLatitude, DATE); HOUR < (Sunset(StationLatitude, DATE) + .01 - HOUR_step); HOUR += HOUR_step){
        float[] SunA = SunPosition (StationLatitude, DATE, HOUR);
        float[] SunB = SunPosition (StationLatitude, DATE, (HOUR + HOUR_step));
        line (s_SunPath * SunA[1], s_SunPath * SunA[2], s_SunPath * SunA[3], s_SunPath * SunB[1], s_SunPath * SunB[2], s_SunPath * SunB[3]);
      }
    }
    
    float min_sunrise = int(min(Sunrise(StationLatitude, 90), Sunrise(StationLatitude, 270))); 
    float max_sunset = int(max(Sunset(StationLatitude, 90), Sunset(StationLatitude, 270)));
    for (float HOUR = min_sunrise; HOUR < max_sunset + .01; HOUR += 1){
      float DATE_step = 1;
      for (int DATE = 90; DATE <= 270; DATE += DATE_step){
        float[] SunA = SunPosition (StationLatitude, DATE, HOUR);
        float[] SunB = SunPosition (StationLatitude, (DATE + DATE_step), HOUR);
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
      
      case ',' :ZOOM_coordinate = 2 * atan_ang((1.0 / 1.1) * tan_ang(0.5 * ZOOM_coordinate)); break;
      case '.' :ZOOM_coordinate = 2 * atan_ang((1.1 / 1.0) * tan_ang(0.5 * ZOOM_coordinate)); break;
      
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


float[] SunPosition (float StationLatitude ,float DATE, float HOUR) {
  float DEC = 23.5 * sin_ang(DATE - 180.0);
  
  float a = sin_ang(DEC);
  float b = cos_ang(DEC) * -cos_ang(15.0 * HOUR);
  float c = cos_ang(DEC) *  sin_ang(15.0 * HOUR);
  
  float x =   c; 
  float y = -(a * cos_ang(StationLatitude) + b * sin_ang(StationLatitude));
  float z =  -a * sin_ang(StationLatitude) + b * cos_ang(StationLatitude);
  
  float[] return_array = {0, x, y, z}; 
  return return_array; 
}

float Sunrise (float StationLatitude, float DATE) {
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


float Sunset (float StationLatitude, float DATE) {
  return (24.0 - Sunrise(StationLatitude, DATE));
}


float DayTime (float StationLatitude, float DATE) {
  return abs((Sunset(StationLatitude, DATE)) - (Sunrise(StationLatitude, DATE)));
}




