import processing.pdf.*;

float Field_Image_Power = 2.0; // 1/2/3

float GlobalAlbedo = 0; // 0-100

float MAX_SHADING_DIST = 100; // the biggest object should be 100

int SavedScreenShots = 0;

int MODEL_RUN = 0; //12; 

float interpolation_weight = 0.5;// 0 = linear distance interpolation, 1 = square distance interpolation, 5 = nearest

float GlobeRES = 2.5; //1, 2.5, 5


int Climatic_solar_model = 0; //                                   Used for solar radiation only
int Climatic_weather_model = 1; // 0:linear 1:average 2:sky-based. Used for some parameters namely: air temperature, humidity

int automated = 0; //0: User interface, 1: Automatic

String CLIMATE_EPW_directory = "C:/SOLARCHVISION_2015/Input/WeatherClimate/CLIMATE_EPW";

//String CLIMATE_WY2_directory = "C:/SOLARCHVISION_2015/Input/WeatherClimate/CLIMATE_CWEED_EMPTY"; 
//String CLIMATE_WY2_directory = "C:/SOLARCHVISION_2015/Input/WeatherClimate/CLIMATE_CWEED_90s"; 
String CLIMATE_WY2_directory = "C:/SOLARCHVISION_2015/Input/WeatherClimate/CLIMATE_CWEED";

String ENSEMBLE_directory = "C:/SOLARCHVISION_2015/Input/WeatherForecast/FORECAST_NAEFS";

String OBSERVED_directory = "C:/SOLARCHVISION_2015/Input/WeatherRealTime/OBSERVATION_SWOB";

int _YEAR = year(); 
int _MONTH = month();
int _DAY = day(); 
int _HOUR = MODEL_RUN; //hour(); 
int BEGIN_DAY;
float _DATE;

String MAKE_mainname () {
  return (nf(_YEAR, 2) + nf(_MONTH, 2) + nf(_DAY, 2) + "_" + nf(j_end, 0) + "dayFORECAST");
  //return (nf(_YEAR, 2) + nf(_MONTH, 2) + nf(_DAY, 2) + "_" + nf(_HOUR, 2) + "Z");
}

String MAKE_Filenames () {
  String My_Filenames = "";
  String Main_name = MAKE_mainname();
  
  My_Filenames = "C:/SOLARCHVISION_2015/TEST_Output" + "/";
  My_Filenames += nf(_YEAR, 2) + "-" + nf(_MONTH, 2) + "-" + nf(_DAY, 2) + "/";
  My_Filenames += "NAEFS_" + nf(MODEL_RUN, 2) + "/";

  
  String sub_folder = "OTHER";
  String the_country = THE_STATION.substring(THE_STATION.length() - 2, THE_STATION.length());
  if (the_country.toUpperCase().equals("US")) sub_folder = the_country;
  if (the_country.toUpperCase().equals("CA")) sub_folder = the_country;
  if (the_country.toUpperCase().equals("BR")) sub_folder = the_country;
  My_Filenames += sub_folder + "/"; 
  
  My_Filenames += "SOLARCHVISION_";
  My_Filenames += DEFINED_STATIONS[STATION_NUMBER][1] + "_";
  My_Filenames += Main_name + "_";
  
  //My_Filenames += "S" + nf(100 + GRAPHS_setup, 3);
  //My_Filenames += "V" + nf(camera_variation, 0); 
  
  //My_Filenames += nf(draw_data_lines, 0);
  //My_Filenames += nf(draw_sorted, 0);
  //My_Filenames += nf(draw_normals, 0);
  //My_Filenames += nf(draw_probs, 0);

  return My_Filenames;
}


int STATION_NUMBER = 0;

String[][] DEFINED_STATIONS = {
     
                                {"TORONTO_ISLAND_ON_CA", "Financial_District", "ON", "43.6488", "-79.3817", "-75", "86"},
                                
                                {"TORONTO_ISLAND_ON_CA", "Ryerson_University", "ON", "43.6593", "-79.3779", "-75", "95"}, 
  
                                {"MONTREAL_DORVAL_QC_CA", "Place_Bonaventure", "QC", "45.4995", "-73.5650", "-75", "30"},
/*                                
                                {"MONTREAL_DORVAL_QC_CA", "Montreal_Dorval", "QC", "45.470556", "-73.740833", "-75", "36"},
                                
                                {"CALGARY_INTL_AB_CA", "CALGARY", "AB", "51.113889", "-114.02", "-120", "1084.1"}, 
                                {"EDMONTON_INTL_A_AB_CA", "EDMONTON", "AB", "53.31", "-113.579444", "-120", "723.3"}, 
                                {"HALIFAX_INTL_AIRPORT_NS_CA", "HALIFAX", "NS", "44.881111", "-63.508611", "-60", "145.4"}, 
                                {"OTTAWA_INTL_ON_CA", "OTTAWA", "ON", "45.383333", "-75.716667", "-75", "79.2"}, 
                                {"QUEBEC_QC_CA", "QUEBEC", "QC", "46.803611", "-71.381667", "-75", "60"}, 
                                {"SUDBURY_ON_CA", "SUDBURY", "ON", "46.625556", "-80.797778", "-75", "348.4"}, 
                                {"TORONTO_ISLAND_ON_CA", "TORONTO-ISLAND", "ON", "43.6275", "-79.396111", "-75", "76.8"}, 
                                {"TORONTO_PEARSON_INTL_ON_CA", "TORONTO-PEARSON", "ON", "43.676667", "-79.630556", "-75", "173.4"}, 
                                {"VANCOUVER_INTL_BC_CA", "VANCOUVER_Harbour", "BC", "49.295353", "-123.121869", "-120", "2.5"}, 
                                {"WINNIPEG_INTL_MB_CA", "WINNIPEG", "MB", "49.91", "-97.24", "-90", "238.7"},
                               
*/


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


String THE_STATION;
String LocationName;
String LocationProvince;
float LocationLatitude;
float LocationLongitude;
float LocationTimeZone;
float LocationElevation;
float Delta_NOON;


int save_frame_number = 0;
int frame_index_number = 0;

int GRAPHS_record_JPG = 0;

int GRAPHS_record_PDF = 0;

int j_start = 0;
int j_end = 2; //16; // Variable

int max_j_end_forecast = 16; // Constant
int max_j_end_observed = 0; // Variable

float per_day = 1; //45; //61; //30.5;
int num_add_days = 1; //30;//per_day; // it should be set up to 1 in order to plot only one day  

// Note: The first observed station below should match the forecast station because the non-linear interpolation function only uses this station.
String[][] OBSERVED_STATIONS = {
                                {"CWTQ", "AUTO", "Dorval"}  
                               };
                              
/*                              
String[][] OBSERVED_STATIONS = {
                                {"CWTQ", "AUTO", "Dorval"}    
                              , {"CYUL", "MAN", "Trudeau Int'l A."}
                              , {"CWTA", "AUTO", "McTavish"}                                                         
                              , {"CYHU", "AUTO", "Saint-Hubert A."}
                              , {"CYMX", "MAN", "Mirabel Int'l A."}                              
                              , {"CWIZ", "AUTO", "L'Acadie"} 
                              , {"CWEW", "AUTO", "L'Assomption"}
                              , {"CWHM", "AUTO", "Varennes"}
                              , {"CWVQ", "AUTO", "Sainte-Anne-de-Bellevue"} 
                               }; 
*/

int CLIMATE_EPW_start = 1; 
int CLIMATE_EPW_end = 1;

int CLIMATE_WY2_start = 1953;
int CLIMATE_WY2_end = 2005;

int ENSEMBLE_start = 1; // min: 1
int ENSEMBLE_end = 43; // max: 43

int OBSERVED_start = 1; 
int OBSERVED_end = OBSERVED_STATIONS.length;

int Sample_Year = 2005; // 2003 as a year with extreme condition
int Sample_Member = 22; // deterministic
int Sample_Station = 1; // Montreal-Dorval

float[][][][] CLIMATE_EPW;

float[][][][] CLIMATE_WY2;

float[][][][] ENSEMBLE;
int[][][][] ENSEMBLE_DATA;

float[][][][] OBSERVED;
int[][][][] OBSERVED_DATA;

int Load_CLIMATE_EPW = 0;
int Load_CLIMATE_WY2 = 0;
int Load_ENSEMBLE = 1;
int Load_OBSERVED = 0;


PrintWriter[] File_output_node;
PrintWriter[] File_output_norm;
PrintWriter[] File_output_prob;

int H_layer_option = 0; //6;
int F_layer_option = 0; //1;
int O_layer_option = 0; //1;

int develop_option = 0; //2; // between 0 - 12....
int develop_per_day = 1;

int update_DevelopDATA = 1;

float Angle_inclination = 45; // 90 = horizontal surface, 0 = Vertical surface 
float Angle_orientation = 0; // 0 = South, 90 = East

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

int drw_Layer = _cloudcover; //_drybulb; //_developed; 

int develop_Layer = drw_Layer;

int GRAPHS_print_title = 1;

float GRAPHS_T_scale = 0;
float GRAPHS_U_scale = 18.0 / float(j_end - j_start);
float[] GRAPHS_V_scale = {(100.0/360.0), (10.0/5.0), 4.0, 1.0, (2.5 * pow(2, 0.5)), 0.1, 0.1, 0.1, 0.0, 0.0025, 0.0025, 10.0, 25.0, 0.01, 2.0, 1, 1, 0.5};
float[] V_offset = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1000, -500, -500, 0};
float[] V_belowLine = {0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0};

int sky_scenario = 1; // 1: all scenarios, 2: Total Cloud Cover < 0.33, 3: middle range, 4: Total Cloud Cover > 0.66
String[] sky_scenario_text = {"", "", "[66% < Total Cloud Cover]", "[33% < Total Cloud Cover < 66%]", "[Total Cloud Cover < 33%]"};
String[] sky_scenario_file = {"", "", "Overcast sky", "Scattered sky", "Clear sky"};

int _hourly = 0;
int _daily = 1;
int filter_type = _daily;

int join_hour_numbers = 24; //48;
int join_type = -1; // -1: increasing weights, +1: equal weights

String _Filenames = "";

String _undefined = "N/A";
float FLOAT_undefined = 1000000000; // it must be a positive big number that is not included in any data

int dT = 1;

int save_info_node = 0;
int save_info_norm = 0;
int save_info_prob = 0;

int _EN = 0;
int _FR = 1;
int _LAN = _EN;

//int Pallet_ACTIVE = 8, Pallet_ACTIVE_DIR = -1;
//int Pallet_ACTIVE = -1, Pallet_ACTIVE_DIR = -1;
//int Pallet_ACTIVE = 6, Pallet_ACTIVE_DIR = -1;
//int Pallet_ACTIVE = 14, Pallet_ACTIVE_DIR = 1;
int Pallet_ACTIVE = 12, Pallet_ACTIVE_DIR = 1;
//int Pallet_ACTIVE = -1, Pallet_ACTIVE_DIR = 2;
//int Pallet_ACTIVE = -1, Pallet_ACTIVE_DIR = -2;

int Pallet_PASSIVE = 1, Pallet_PASSIVE_DIR = 1;

int Impact_ACTIVE = 1;
int Impact_PASSIVE = 2;
int Impact_SPD_DIR = 1;
int Impact_SPD_DIR_TMP = 2;

int Impact_TYPE = 1; 

String[][] _LAYERS = {
  {"°", "Surface Wind Direction", "Direction du vent à la surface"}, 
  {"km/h", "Surface Wind Speed", "Vitesse du vent à la surface"}, 
  {"mm", "Surface Accumulated Precipitation", "Précipitations accumulées à la surface"}, 
  {"%", "Surface Relative Humidity", "Humidité relative à la surface"}, 
  {"°C", "Surface Air Temperature", "Température de l'air à la surface"}, 
  {"W/m²", "direct normal radiation", "rayonnement direct normal"}, 
  {"W/m²", "diffuse horizontal radiation", "diffus rayonnement horizontal"}, 
  {"W/m²", "global horizontal radiation", "rayonnement global horizontal"}, 
  {"", "", ""}, 
  {"W°C/m²", "direct normal effect (based on 18°C)", "effet direct normal (basé sur 18°C)"}, 
  {"W°C/m²", "diffuse normal effect (based on 18°C)", "effet diffus normal (basé sur 18°C)"}, 
  {"tenth", "Total Cloud Cover", "Couvert nuageux total"}, 
  {"log(m)", "ceiling height", "hauteur sous plafond"}, 
  {"m", "ceiling height", "hauteur sous plafond"}, 
  {"hPa", "Mean Sea level Pressure", "Pression moyenne au niveau de la mer"}, 
  {"dam", "Geopotential at 500 hPa", "Géopotentiel à 500 hPa" }, 
  {"dam", "Thicknesses (Geopotentiel Difference) between 1000 and 500 hPa", "Épaisseurs (différence de géopotentiel entre 1000 et 500 hPa"}, 
  {"knots", "Wind Speed at 200 hPa", "Vitesse du vent à 200 hPa"}
};

String[] THE_LAYERS = { "WDIR-SFC", 
                        "WIND-SFC", 
                        "APCP-SFC", 
                        "RELH-SFC", 
                        "TMP-SFC", 
                        "", 
                        "", 
                        "", 
                        "", 
                        "", 
                        "", 
                        "TCDC", 
                        "", 
                        "", 
                        "MSLP", 
                        "HGT-500HPA", 
                        "LAYER-1000-500HPA", 
                        "WIND-200HPA"
                      };

String[][] _WORDS = {
 {"", ""}, 
 {"at hour", "à l'heure"}, 
 {"day", "jour"}, 
 {"month", "mois"}, 
 {"year", "année"}, 
 {"date", "date"} 
}; 

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
  {"December",  "décembre"}
};

int CalendarLength[] = {31     , 28     , 31     , 30     , 31     , 30     , 31     , 31     , 30     , 31     , 30     , 31};
String CalendarDay[][];
String CalendarMM[][];
String CalendarDD[][];
int CalendarDate[][];

float GRAPHS_X_coordinate = 0;
float GRAPHS_Y_coordinate = 0;

float GRAPHS_O_scale = 50.0;
float GRAPHS_W_scale = 3.0;

int GRAPHS_record_AUTO = 0;

float X_spinner, Y_spinner;

int COLOR_STYLE = 0;
int n_COLOR_STYLE = 16; //6;

float sky_scale = 900; //90;

float obj_scale = 0.005;
float obj_offset_x = 0.5;

PGraphics Diagrams;

int databaseNumber_CLIMATE_WY2 = 0;
int databaseNumber_ENSEMBLE = 1;
int databaseNumber_OBSERVED = 2;
int databaseNumber_CLIMATE_EPW = 3;
int impacts_source = 1; // 0 = Climate WY2, 1 = Forecast, 2 = Observation, 3 = Climate EPW

int draw_impact_summary = 0;

int impact_layer = 1; // 4 = Median
int plot_impacts = 4; 
int update_impacts = 1; 



int draw_frame = 0;

int X_clicked = 0;
int Y_clicked = 0;

String[] CLIMATE_EPW_Files = getfiles(CLIMATE_EPW_directory);
String[] CLIMATE_WY2_Files = getfiles(CLIMATE_WY2_directory);
String[] FORECAST_XML_Files = getfiles(ENSEMBLE_directory);
String[] OBSERVED_XML_Files = getfiles(OBSERVED_directory);


int Load_LAND = 0;
int Display_LAND = 1;
int Skip_LAND_Center = 1;


int Load_URBAN = 0;


int camera_variation = 1;

int draw_data_lines = 0;
int draw_sorted = 1;
int draw_normals = 1;
int draw_probs = 0;
int sum_interval = 2;
float level_pix = 8;

float _pix = 0; 

color color_data_lines = color(0, 0, 0);

int off_screen = 1; // 1: off 0: on

float Image_Scale = 1.0;
float pre_Image_Scale = Image_Scale; 

PGraphics pre_Diagrams;
int preGRAPHS_setup;
int pre_impacts_source;
int pre_STATION_NUMBER;
int pre_YEAR;
int pre_MONTH;
int pre_DAY;
int pre_HOUR;
float pre_DATE;
int pre_Climatic_solar_model;
int pre_Climatic_weather_model;
int pre_Load_CLIMATE_EPW;
int pre_Load_CLIMATE_WY2;
int pre_Load_ENSEMBLE;
int pre_Load_OBSERVED;     
float pre_LocationLatitude;
float pre_LocationLongitude;
float pre_LocationElevation;
int pre_Load_LAND;
int pre_Display_LAND;
int pre_Skip_LAND_Center;
int pre_Load_URBAN;


int GRAPHS_setup = 100; //4; //12; //13;



String BaseFolder = "C:/SOLARCHVISION_2015"; 

String ExportFolder;
String BackgroundFolder;
String WorldViewFolder;
String SWOBFolder;
String NAEFSFolder;
String CWEEDSFolder;
String LandFolder;
String Object2DFolder_PEOPLE;
String Object2DFolder_TREES;

void SOLARCHVISION_update_folders () {

  ExportFolder          = BaseFolder + "/Export";
  BackgroundFolder      = BaseFolder + "/Input/BackgroundImages/Standard/Other";
  WorldViewFolder       = BaseFolder + "/Input/BackgroundImages/Standard/World";
  SWOBFolder            = BaseFolder + "/Input/CoordinateFiles/LocationInfo";
  NAEFSFolder           = BaseFolder + "/Input/CoordinateFiles/LocationInfo";
  CWEEDSFolder          = BaseFolder + "/Input/CoordinateFiles/LocationInfo";
  LandFolder            = BaseFolder + "/Input/CoordinateFiles/Land";
  Object2DFolder_PEOPLE = BaseFolder + "/Input/BackgroundImages/Standard/Maps/People_SEL";
  Object2DFolder_TREES  = BaseFolder + "/Input/BackgroundImages/Standard/Maps/Trees_ALL";

}

int Materials_Number = 11; // 0, 1, 2, ... , 10

int Materials_Selection = 1; //2; // yellow

float[][][] Materials_DirectArea = new float [Materials_Number][24][365]; 
int[][] Materials_DirectArea_Flag = new int [24][365];

float[][][] Materials_DiffuseArea = new float [Materials_Number][24][365]; 
int[][] Materials_DiffuseArea_Flag = new int [24][365];

int[][] Materials_Color = new int [Materials_Number][4]; // ARGB                            
{
  {
    int[] COL = {255, 255, 127, 0};    
    Materials_Color[0] = COL;
  }
  {
    int[] COL = {255, 255, 0, 0};    
    Materials_Color[1] = COL;
  }  
  {
    int[] COL = {255, 255, 255, 0};    
    Materials_Color[2] = COL;
  }
  {
    int[] COL = {255, 0, 255, 0};    
    Materials_Color[3] = COL;
  }
  {
    int[] COL = {255, 0, 255, 255};    
    Materials_Color[4] = COL;
  }
  {
    int[] COL = {255, 0, 0, 255};    
    Materials_Color[5] = COL;
  }
  {
    int[] COL = {255, 255, 0, 255};    
    Materials_Color[6] = COL;
  }
  {
    int[] COL = {255, 255, 255, 255};    
    Materials_Color[7] = COL;
  }
  {
    int[] COL = {255, 63, 63, 63};    
    Materials_Color[8] = COL;
  }
  {
    int[] COL = {255, 127, 127, 127};    
    Materials_Color[9] = COL;
  }
  {
    int[] COL = {255, 191, 191, 191};    
    Materials_Color[10] = COL;
  }
}

void empty_Materials_DirectArea () {

  for (int mt = 0; mt < Materials_Number; mt++) {
    for (int i = 0; i < 24; i += 1) {
      for (int j = 0; j < 365; j += 1) {
        Materials_DirectArea[mt][i][j] = FLOAT_undefined;
        Materials_DirectArea_Flag[i][j] = -1;
      }
    }  
  }

}

void empty_Materials_DiffuseArea () {

  for (int mt = 0; mt < Materials_Number; mt++) {
    for (int i = 0; i < 24; i += 1) {
      for (int j = 0; j < 365; j += 1) {
        Materials_DiffuseArea[mt][i][j] = FLOAT_undefined;
        Materials_DiffuseArea_Flag[i][j] = -1;
      }
    }  
  }

}


                  
int h_pixel = 325; 
int w_pixel = int(h_pixel * 1.5);

int WIN3D_CX_View = 0;
int WIN3D_CY_View = h_pixel;
int WIN3D_X_View = w_pixel;
int WIN3D_Y_View = h_pixel;
float WIN3D_R_View = float(WIN3D_Y_View) / float(WIN3D_X_View);

float WIN3D_X_coordinate = 0;
float WIN3D_Y_coordinate = 0;
float WIN3D_Z_coordinate = 0; //180 * (h_pixel / 300.0);
float WIN3D_S_coordinate = 5.0;

float WIN3D_RX_coordinate = 75; //45;
float WIN3D_RY_coordinate = 0;
float WIN3D_RZ_coordinate = 180; //135;
float WIN3D_RS_coordinate = 5.0;

float WIN3D_ZOOM_coordinate = 60; // / (h_pixel / 300.0);

int WIN3D_View_Type = 1; // 0: Ortho 1: Perspective

PGraphics WIN3D_Diagrams;

int WIN3D_Update = 1;
int WIN3D_include = 1;

int WIN3D_EDGES_SHOW = 1;
int WIN3D_FACES_SHADE = 1;

int MODEL3D_TESELATION = 0;

float[] WIN3D_VerticesSolarEnergy;
float[] WIN3D_VerticesSolarEffect;
int WIN3D_update_VerticesSolarValue = 1;




int WORLD_CX_View = w_pixel;
int WORLD_CY_View = h_pixel;
int WORLD_X_View = w_pixel;
int WORLD_Y_View = h_pixel;
float WORLD_R_View = float(WORLD_Y_View) / float(WORLD_X_View);

PGraphics WORLD_Diagrams;

int WORLD_Update = 1;
int WORLD_include = 1;

int WORLD_VIEW_Number = 0;

String[][] WORLD_VIEW_Name;
float[][] WORLD_VIEW_BoundariesX;
float[][] WORLD_VIEW_BoundariesY; 
int[] WORLD_VIEW_GridDisplay;
String[] WORLD_VIEW_Filenames;
String[] Object2D_Filenames;
String[] Object2D_Filenames_PEOPLE;
String[] Object2D_Filenames_TREES;

int number_of_WORLD_viewports;


int GRAPHS_CX_View = 0;
int GRAPHS_CY_View = 0;
int GRAPHS_X_View = 2 * w_pixel;
int GRAPHS_Y_View = 1 * h_pixel;
float GRAPHS_R_View = float(GRAPHS_Y_View) / float(GRAPHS_X_View);
float GRAPHS_S_View;

int GRAPHS_Update = 1;
int GRAPHS_include = 1;

int ROLLOUT_CX_View = 2 * w_pixel;
int ROLLOUT_CY_View = 0;
int ROLLOUT_X_View = 1 * h_pixel;
int ROLLOUT_Y_View = 2 * h_pixel;
float ROLLOUT_R_View = float(ROLLOUT_Y_View) / float(ROLLOUT_X_View);
float ROLLOUT_S_View = 1; //0.75; // ?????

int ROLLOUT_Update = 1;
int ROLLOUT_include = 1;



float CAM_x, CAM_y, CAM_z;


void setup () {

  //size(2 * w_pixel, 2 * h_pixel, P2D);
  size(2 * w_pixel + h_pixel, 2 * h_pixel, P2D);

  _DATE = (286 + Convert2Date(_MONTH, _DAY)) % 365; // 0 presents March 21, 286 presents Jan.01, 345 presents March.01
  //if (_HOUR >= 12) _DATE += 0.5;   

  empty_Materials_DirectArea();
  empty_Materials_DiffuseArea();

  WIN3D_VerticesSolarEnergy = new float [1];
  WIN3D_VerticesSolarEffect = new float [1];
  WIN3D_VerticesSolarEnergy[0] = FLOAT_undefined;
  WIN3D_VerticesSolarEffect[0] = FLOAT_undefined;

  WIN3D_Diagrams = createGraphics(WIN3D_X_View, WIN3D_Y_View, P3D); 

  WORLD_Diagrams = createGraphics(WORLD_X_View, WORLD_Y_View, P2D);


  frameRate(24);

  loop();
}




void SOLARCHVISION_update_station (int Step) {
  
  if ((Step == 0) || (Step == 1)) {
    
    WIN3D_FACES_SHADE = 1;
    WIN3D_update_VerticesSolarValue = 1;
    
    
    WORLD_Update = 1;
    WIN3D_Update = 1; 
    GRAPHS_Update = 1;    
    
    THE_STATION = DEFINED_STATIONS[STATION_NUMBER][0];
    LocationName = DEFINED_STATIONS[STATION_NUMBER][1];
    LocationProvince = DEFINED_STATIONS[STATION_NUMBER][2];
    LocationLatitude = float(DEFINED_STATIONS[STATION_NUMBER][3]);
    LocationLongitude = float(DEFINED_STATIONS[STATION_NUMBER][4]);
    LocationTimeZone = float(DEFINED_STATIONS[STATION_NUMBER][5]);
    LocationElevation = float(DEFINED_STATIONS[STATION_NUMBER][6]);
    Delta_NOON = (LocationTimeZone - LocationLongitude) / 15.0;
    
    WORLD_VIEW_Number = FindGoodViewport(LocationLongitude, LocationLatitude);
    
    BEGIN_DAY = Convert2Date(_MONTH, _DAY);
  }
  
  if ((Step == 0) || (Step == 2)) SOLARCHVISION_try_update_CLIMATE_EPW();
  
  if ((Step == 0) || (Step == 3)) SOLARCHVISION_try_update_CLIMATE_WY2();  
  
  if ((Step == 0) || (Step == 4)) SOLARCHVISION_try_update_observed();
  
  if ((Step == 0) || (Step == 5)) SOLARCHVISION_try_update_forecast(_YEAR, _MONTH, _DAY, _HOUR);

  if ((Step == 0) || (Step == 6)) SOLARCHVISION_LoadLAND(LocationName);
  
  if ((Step == 0) || (Step == 7)) SOLARCHVISION_remove_2Dobjects();

  if ((Step == 0) || (Step == 8)) SOLARCHVISION_add_2Dobjects_onLand();

}

void SOLARCHVISION_update_models (int Step) {
 
   if ((Step == 0) || (Step == 1)) SOLARCHVISION_remove_3Dobjects();
   //if ((Step == 0) || (Step == 2)) SOLARCHVISION_add_3Dobjects();
   //if ((Step == 0) || (Step == 3)) SOLARCHVISION_add_ParametricSurfaces(1);
   if ((Step == 0) || (Step == 4)) SOLARCHVISION_remove_ParametricGeometries();
   if ((Step == 0) || (Step == 5)) SOLARCHVISION_add_ParametricGeometries();
   if ((Step == 0) || (Step == 6)) SOLARCHVISION_calculate_ParametricGeometries_Field();

}


float message_size = w_pixel / 40.0;

float last_initializationStep = 0;

void draw () {
  
  //println("frameCount:", frameCount);

  if (frameCount == 1) {

    background(223);

    SOLARCHVISION_update_folders();
    LoadFontStyle();

    float cr;

    cr = w_pixel / 4.0;
    PImage SOLARCHVISION_logo = loadImage(BackgroundFolder + "/" + "SOLARCHVISION.jpg");
    imageMode(CENTER);
    image(SOLARCHVISION_logo, 0.5 * width, 0.5 * height - 0.75 * message_size - cr + (0.075 * cr), 3.05 * cr, 3.05 * cr);
    imageMode(CORNER);

    strokeWeight(1);
    stroke(0);
    noFill();
    
    
    ellipseMode(CENTER);

    strokeWeight(0);
    stroke(191);
    fill(191);    
    ellipse(0.2 * width, 0.5 * height - 0.75 * message_size - cr, 2 * cr, 2 * cr);
    strokeWeight(1);
    stroke(255);
    noFill();    
    SOLARCHVISION_draw_logo(0.2 * width, 0.5 * height - 0.75 * message_size - cr, 0, cr, 1);
    strokeWeight(2);
    stroke(0);
    noFill();    
    ellipse(0.2 * width, 0.5 * height - 0.75 * message_size - cr, 2 * cr, 2 * cr);
    
    strokeWeight(1);
    stroke(127);
    noFill();  
    //SOLARCHVISION_draw_logo(0.5 * width, 0.5 * height - 0.75 * message_size - cr, 0, cr, 0);
    strokeWeight(2);
    stroke(0);
    noFill();    
    ellipse(0.5 * width, 0.5 * height - 0.75 * message_size - cr, 2 * cr, 2 * cr);

    strokeWeight(0);
    stroke(191);
    fill(191);    
    ellipse(0.8 * width, 0.5 * height - 0.75 * message_size - cr, 2 * cr, 2 * cr);    
    strokeWeight(1);
    stroke(255);
    noFill();  
    SOLARCHVISION_draw_logo(0.8 * width, 0.5 * height - 0.75 * message_size - cr, 0, cr, -1);
    strokeWeight(2);
    stroke(0);
    noFill();    
    ellipse(0.8 * width, 0.5 * height - 0.75 * message_size - cr, 2 * cr, 2 * cr);
    
    strokeWeight(0);

    stroke(255);
    fill(255);
    textAlign(CENTER, CENTER); 
    textSize(3 * message_size);
    text("SOLARCHVISION model integrations 2015", 0.5 * width, 0.05 * height); 

    stroke(0);
    fill(0);
    textSize(message_size);
    text("Raz, Mehr, Mehraz solarch studio\n1998-2015\nAuthor: Mojtaba Samimi\nwww.solarchvision.com", 0.5 * width, 0.75 * height);

    textSize(message_size);
    
      
    
  }  
  else if (frameCount == 2) {
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_LoadWorldImages", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 3) {
    SOLARCHVISION_LoadWorldImages();

    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_LoadObject2DImages", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 4) {
    SOLARCHVISION_LoadObject2DImages();
    
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_Calendar", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 5) {
    SOLARCHVISION_Calendar(); 

    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_getSWOB_Coordinates", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 6) {
    SOLARCHVISION_getSWOB_Coordinates(); 
    
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_getNAEFS_Coordinates", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 7) {
    SOLARCHVISION_getNAEFS_Coordinates(); 
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_getCWEEDS_Coordinates", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 8) {
    SOLARCHVISION_getCWEEDS_Coordinates();  
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_update_date", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 9) {
    SOLARCHVISION_update_date(); 
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_update_station(start)", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 10) {
    SOLARCHVISION_update_station(1);
    
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_try_update_CLIMATE_EPW", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 11) {
    SOLARCHVISION_update_station(2);
    
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_try_update_CLIMATE_WY2", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 12) {
    SOLARCHVISION_update_station(3);
    
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_try_update_observed", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 13) {
    SOLARCHVISION_update_station(4);
    
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_try_update_forecast", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 14) {
    SOLARCHVISION_update_station(5);
    
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_LoadLAND", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 15) {
    SOLARCHVISION_update_station(6);

    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_remove_2Dobjects", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 16) {
    SOLARCHVISION_update_station(7);

    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_add_2Dobjects_onLand", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 17) {
    SOLARCHVISION_update_station(8);
    
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_remove_3Dobjects", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 18) {
    SOLARCHVISION_update_models(1);
    
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_add_3Dobjects", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 19) {
    SOLARCHVISION_update_models(2);
    
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_add_ParametricSurfaces", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 20) {
    SOLARCHVISION_update_models(3);

    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_remove_ParametricGeometries", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 21) {
    SOLARCHVISION_update_models(4);    
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_add_ParametricGeometries", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 22) {
    SOLARCHVISION_update_models(5);
    
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_calculate_ParametricGeometries_Field", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 23) {
    SOLARCHVISION_update_models(6);
    
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 

    stroke(255);
    fill(255);
    text("SOLARCHVISION_build_SkySphere", 0.5 * width, 0.5 * height);
    
  }    
  else if (frameCount == 24) {
    SOLARCHVISION_build_SkySphere(3);
    
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size); 
    
    stroke(255);
    fill(255);
    text("SOLARCHVISION_build_SolarProjection_array", 0.5 * width, 0.5 * height);
  }
  else if (frameCount == 25) {  
    SOLARCHVISION_build_SolarProjection_array();
     
    stroke(0);
    fill(0);
    rect(0, 0.5 * height - 0.75 * message_size, width, 1.5 * message_size);
   
    stroke(255);
    fill(255);
    text("Please wait while integrating the models.", 0.5 * width, 0.5 * height);

    last_initializationStep = frameCount; 
  }
  else {
    
    CAM_x = 0;
    CAM_y = 0;
    CAM_z = 0;
    
    if (ROLLOUT_include == 1) {
      if (ROLLOUT_Update == 1) {
        
        preGRAPHS_setup = GRAPHS_setup;
        pre_impacts_source = impacts_source;
        pre_STATION_NUMBER = STATION_NUMBER;
        pre_YEAR = _YEAR;
        pre_MONTH = _MONTH;
        pre_DAY = _DAY;
        pre_DATE = _DATE;
        pre_HOUR = _HOUR;
        pre_Climatic_solar_model = Climatic_solar_model;
        pre_Climatic_weather_model = Climatic_weather_model;

        pre_Load_CLIMATE_EPW = Load_CLIMATE_EPW;
        pre_Load_CLIMATE_WY2 = Load_CLIMATE_WY2;
        pre_Load_ENSEMBLE = Load_ENSEMBLE;
        pre_Load_OBSERVED = Load_OBSERVED;       
        
        pre_LocationLatitude = LocationLatitude;
        pre_LocationLongitude = LocationLongitude;
        pre_LocationElevation = LocationElevation;
        
        pre_Load_LAND = Load_LAND;
        pre_Display_LAND = Display_LAND;
        pre_Skip_LAND_Center = Skip_LAND_Center;
        
        pre_Load_URBAN = Load_URBAN;


       
        
        SOLARCHVISION_draw_ROLLOUT();
        
        if (pre_DATE != _DATE) {
          SOLARCHVISION_update_date();
          SOLARCHVISION_draw_ROLLOUT();
        }
        
        if ((pre_YEAR != _YEAR) || (pre_MONTH != _MONTH) || (pre_DAY != _DAY) || (pre_HOUR != _HOUR) || (pre_Climatic_solar_model != Climatic_solar_model) || (pre_Climatic_weather_model != Climatic_weather_model)) {
          
          BEGIN_DAY = Convert2Date(_MONTH, _DAY);
          _HOUR = int(24 * (_DATE - int(_DATE)));
          _DATE = (_HOUR / 24.0) + (286 + Convert2Date(_MONTH, _DAY)) % 365;
          println("DATE:", _DATE, "\tHOUR:", _HOUR);
          SOLARCHVISION_try_update_forecast(_YEAR, _MONTH, _DAY, _HOUR);
          
          SOLARCHVISION_draw_ROLLOUT();
        }
      
        if (pre_STATION_NUMBER != STATION_NUMBER) SOLARCHVISION_update_station(0);
        
        if (pre_Load_CLIMATE_EPW != Load_CLIMATE_EPW) SOLARCHVISION_try_update_CLIMATE_EPW();
        if (pre_Load_CLIMATE_WY2 != Load_CLIMATE_WY2) SOLARCHVISION_try_update_CLIMATE_WY2();
        if (pre_Load_OBSERVED != Load_OBSERVED) SOLARCHVISION_try_update_observed();
        if (pre_Load_ENSEMBLE != Load_ENSEMBLE) SOLARCHVISION_try_update_forecast(_YEAR, _MONTH, _DAY, _HOUR);

        if ((pre_LocationLatitude != LocationLatitude) || (pre_LocationLongitude != LocationLongitude)) {

          WORLD_VIEW_Number = FindGoodViewport(LocationLongitude, LocationLatitude);
          WORLD_Update = 1; 
          WIN3D_Update = 1;
          GRAPHS_Update = 1;
        }
        
        if (pre_LocationElevation != LocationElevation) {

          WIN3D_Update = 1;
          GRAPHS_Update = 1;
        }        
        
        if (pre_Load_LAND != Load_LAND) {
          SOLARCHVISION_LoadLAND(LocationName);
          WIN3D_Update = 1;
        }

        if ((pre_Display_LAND != Display_LAND) || (pre_Skip_LAND_Center != Skip_LAND_Center)) {
          WIN3D_Update = 1;
        }            
        
        if (pre_Load_URBAN != Load_URBAN) {
          SOLARCHVISION_add_urban();
          
          WIN3D_Update = 1;
        }
            
        if (GRAPHS_setup != preGRAPHS_setup) update_impacts = 1;
        if (impacts_source != pre_impacts_source) update_impacts = 1; 
        if (GRAPHS_record_PDF == 1) update_impacts = 1;         
            
      }
    }
    ROLLOUT_Update = 0;

    
    if (GRAPHS_include == 1) {
      if (GRAPHS_Update == 1) {
        
        SOLARCHVISION_draw_GRAPHS();
        
      }
    }
    GRAPHS_Update = 0;


    if (WORLD_include == 1) {
      if (WORLD_Update == 1) {
        
        SOLARCHVISION_draw_WORLD();
        
      }
    }
    WORLD_Update = 0;
    
    if (WIN3D_include == 1) {
      if (WIN3D_Update == 1) {
        
        SOLARCHVISION_draw_WIN3D();
      
      }
    }
    WIN3D_Update = 0;

    if (GRAPHS_include == 1) {
      if (GRAPHS_Update == 1) {
        
        SOLARCHVISION_draw_GRAPHS();
        
      }
    }
    GRAPHS_Update = 0;

    noLoop();
  }
} 



void SOLARCHVISION_draw_WIN3D () {
  
  WIN3D_Diagrams.beginDraw();
  
  WIN3D_Diagrams.background(233);
  
  if (WIN3D_View_Type == 1) {

    float fov = WIN3D_ZOOM_coordinate * PI / 180;
    
    CAM_x = 0;
    CAM_y = 0;
    CAM_z = 0.5 * WIN3D_Diagrams.height / tan(PI / 6.0);
    //CAM_z = 0.5 * WIN3D_Diagrams.height / tan(0.5 * fov);
    //CAM_z = (300.0 / (1.0 * h_pixel)) * 0.5 * WIN3D_Diagrams.height / tan(0.5 * fov);
    

    //println("CAM_fov =", fov * 180 / PI);
    //println(CAM_x, CAM_y, CAM_z);
    
    float aspect = 1.0 / WIN3D_R_View;
    
    float zFar = CAM_z * 100; 
    float zNear = CAM_z * 0.01;
    
    float ymax = zNear * tan(0.5 * fov);
    float ymin = -ymax;
    float xmin = ymin * aspect;
    float xmax = ymax * aspect;

    //println(xmin, xmax, ymin, ymax, zNear, zFar);
    WIN3D_Diagrams.frustum(xmin, xmax, ymin, ymax, zNear, zFar);

    WIN3D_Diagrams.translate(0.5 * WIN3D_X_View, 0.5 * WIN3D_Y_View, 0); // << IMPORTANT!
  }
  else {
    
    //float ZOOM = 0.456 * WIN3D_ZOOM_coordinate * PI / 180;
    float ZOOM = 0.125 * WIN3D_ZOOM_coordinate * PI / 180;
    
    WIN3D_Diagrams.ortho(ZOOM * WIN3D_X_View * -1, ZOOM * WIN3D_X_View * 1, ZOOM  * WIN3D_Y_View * -1, ZOOM  * WIN3D_Y_View * 1, 0.00001, 100000);
    
    WIN3D_Diagrams.translate(0, 1.0 * WIN3D_Y_View, 0); // << IMPORTANT! 
  }

  //lights();

  
  WIN3D_Diagrams.pushMatrix();
  
  WIN3D_Diagrams.translate(0, 0, 0);
  
  WIN3D_Diagrams.fill(0);
  WIN3D_Diagrams.textAlign(CENTER, CENTER); 
  WIN3D_Diagrams.textSize(5 * (WIN3D_ZOOM_coordinate / 30.0));
  WIN3D_Diagrams.text(LocationName + " [" + nfp(LocationLatitude, 0, 1) + ", " + nfp(LocationLongitude, 0, 1) + "]", 0, 60 * (WIN3D_ZOOM_coordinate / 30.0), 0);
 
  WIN3D_Diagrams.popMatrix();

  WIN3D_Diagrams.translate(WIN3D_X_coordinate, WIN3D_Y_coordinate, WIN3D_Z_coordinate);
  WIN3D_Diagrams.rotateX(WIN3D_RX_coordinate * PI / 180); 
  WIN3D_Diagrams.rotateY(WIN3D_RY_coordinate * PI / 180);
  WIN3D_Diagrams.rotateZ(WIN3D_RZ_coordinate * PI / 180); 

  //println(nfp(WIN3D_RX_coordinate, 0, 1), nfp(WIN3D_RY_coordinate, 0, 1), nfp(WIN3D_RZ_coordinate, 0, 1)); 


  
  WIN3D_Diagrams.fill(127);



  WIN3D_Diagrams.hint(ENABLE_DEPTH_TEST);

  SOLARCHVISION_SunPath(0, 0, 0, 0.95 * sky_scale, LocationLatitude);
  
  //SOLARCHVISION_draw_sky();
  
  SOLARCHVISION_draw_land();
  
  SOLARCHVISION_draw_field_image();
  
  SOLARCHVISION_draw_objects();
  


  WIN3D_Diagrams.endDraw();

  imageMode(CORNER);    
  image(WIN3D_Diagrams, WIN3D_CX_View, WIN3D_CY_View, WIN3D_X_View, WIN3D_Y_View);



}


void SOLARCHVISION_draw_WORLD () {
    
  WORLD_Diagrams.beginDraw();
  
  WORLD_Diagrams.background(0, 0, 0);
  
  PImage WORLDViewImage = loadImage(WorldViewFolder + "/" + WORLD_VIEW_Filenames[WORLD_VIEW_Number]);

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

      WORLD_Diagrams.strokeWeight(0);
      WORLD_Diagrams.stroke(127, 0, 0, 127);
      WORLD_Diagrams.fill(127, 0, 0, 127);      
      WORLD_Diagrams.ellipse(x_point, y_point, R_station, R_station);

      WORLD_Diagrams.strokeWeight(0);
      WORLD_Diagrams.stroke(0);
      WORLD_Diagrams.fill(0);      
      WORLD_Diagrams.textAlign(RIGHT, CENTER); 
      WORLD_Diagrams.textSize(message_size);
      WORLD_Diagrams.text(STATION_SWOB_INFO[f][6], x_point, y_point);
    
    }
  }    

  WORLD_Diagrams.strokeWeight(0);
  WORLD_Diagrams.stroke(0, 63, 0, 127);
  WORLD_Diagrams.fill(0, 63, 0, 127);

  int nearest_STATION_NAEFS = -1;
  float nearest_STATION_NAEFS_dist = FLOAT_undefined;
            
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
    
    float d = dist_lon_lat(_lon, _lat,  LocationLongitude, LocationLatitude);
    
    if (nearest_STATION_NAEFS_dist > d) {
      nearest_STATION_NAEFS_dist = d;
      nearest_STATION_NAEFS = f;
    } 
    
  }
  
  {   
      int f = nearest_STATION_NAEFS;
    
      float _lat = float(STATION_NAEFS_INFO[f][1]);
      float _lon = float(STATION_NAEFS_INFO[f][2]); 
      if (_lon > 180) _lon -= 360; // << important!      
      
      float x_point = WORLD_X_View * (( 1 * (_lon - WORLD_VIEW_OffsetX) / 360.0) + 0.5) / WORLD_VIEW_ScaleX;
      float y_point = WORLD_Y_View * ((-1 * (_lat - WORLD_VIEW_OffsetY) / 180.0) + 0.5) / WORLD_VIEW_ScaleY;
      
      WORLD_Diagrams.strokeWeight(0);
      WORLD_Diagrams.stroke(0);
      WORLD_Diagrams.fill(0);      
      WORLD_Diagrams.textAlign(RIGHT, CENTER); 
      WORLD_Diagrams.textSize(message_size);
      WORLD_Diagrams.text(STATION_NAEFS_INFO[f][0], x_point, y_point);
      //println(STATION_NAEFS_INFO[f][0]);
  }
  


            
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

      WORLD_Diagrams.strokeWeight(2);
      WORLD_Diagrams.stroke(63, 63, 63, 63);
      WORLD_Diagrams.noFill();
      WORLD_Diagrams.ellipse(x_point, y_point, 3 * R_station, 3 * R_station);

      WORLD_Diagrams.strokeWeight(0);
      WORLD_Diagrams.stroke(0);
      WORLD_Diagrams.fill(0);      
      WORLD_Diagrams.textAlign(RIGHT, CENTER); 
      WORLD_Diagrams.textSize(message_size);
      WORLD_Diagrams.text(STATION_CWEEDS_INFO[f][0], x_point, y_point); 
    }
  } 
  
  WORLD_Diagrams.strokeWeight(0);

  
  WORLD_Diagrams.endDraw();

  imageMode(CORNER);    
  image(WORLD_Diagrams, WORLD_CX_View, WORLD_CY_View, WORLD_X_View, WORLD_Y_View); 
}


void SOLARCHVISION_draw_GRAPHS () {

  cursor(WAIT);
  
  //resetMatrix();

  pushMatrix();
  translate(GRAPHS_CX_View, GRAPHS_CY_View);
 

  stroke(255); 
  fill(255);
  strokeWeight(0);
  rect(0, 0, GRAPHS_X_View, GRAPHS_Y_View);


  GRAPHS_S_View = (GRAPHS_X_View / 1200.0);
  GRAPHS_U_scale = 18.0 / float(j_end - j_start);
  
  update_DevelopDATA = 1; // ????

  
  if ((GRAPHS_record_JPG == 1) || (GRAPHS_record_AUTO == 1)) {
    if (off_screen == 0) {
      off_screen = 1;
      GRAPHS_Update = 1; 
    }
  }
  else {
    off_screen = 0;
  }
  
  if (GRAPHS_Update != 0) {
    
    if (GRAPHS_record_PDF == 1) Image_Scale = 1;
    else {
      if (off_screen == 0) Image_Scale = 1; 
      else Image_Scale = 1; //1.5; //2;
    }
    
    draw_frame += 1;
    println("frame:", draw_frame);
  
    GRAPHS_X_coordinate = -0.333 * GRAPHS_X_View * Image_Scale;      
    
    GRAPHS_Y_coordinate = 1.0 * GRAPHS_Y_View * Image_Scale;
    
    GRAPHS_S_View *= 0.575 * Image_Scale; 
    GRAPHS_T_scale = 0.5 * Image_Scale;  
  
    if (GRAPHS_record_PDF == 1) {
      println("PDF:begin");
      Diagrams = createGraphics(GRAPHS_X_View, GRAPHS_Y_View, PDF, MAKE_Filenames() + ".pdf");
      beginRecord(Diagrams);
    }
    else {
      Diagrams = createGraphics(int(GRAPHS_X_View * Image_Scale), int(GRAPHS_Y_View * Image_Scale), P2D);
      Diagrams_beginDraw();
    }
  
    
    Diagrams_background(255);
    
    Diagrams_blendMode(BLEND);
  
    Diagrams_strokeJoin(ROUND); 
    
    //Diagrams_textFont(createFont("Arial Narrow", 36)); 
    
    Diagrams_strokeWeight(0);
    
    //Diagrams_translate(GRAPHS_X_coordinate * -0.25, GRAPHS_Y_coordinate * 0.5); 
    Diagrams_translate(GRAPHS_X_coordinate * -0.425, GRAPHS_Y_coordinate * 0.5);

    Plot_Setup();
    
    //Diagrams_translate(GRAPHS_X_coordinate * 0.25, GRAPHS_Y_coordinate * 0.5);
    Diagrams_translate(GRAPHS_X_coordinate * 0.425, GRAPHS_Y_coordinate * 0.5);

    Diagrams_strokeWeight(GRAPHS_T_scale * 1);
      
    Diagrams_stroke(63);
    Diagrams_fill(63);
    Diagrams_textAlign(CENTER, CENTER);

    String _text = "SOLARCHVISION post-processing";

    if (impacts_source == databaseNumber_CLIMATE_EPW) _text += " based on typical-year data for Building Energy Simulation (EPW - U.S. Department of Energy)";
    if (impacts_source == databaseNumber_CLIMATE_WY2) _text += " based on long-term Canadian Weather Energy and Engineering Datasets (CWEEDS - Environment Canada)";
    if (impacts_source == databaseNumber_ENSEMBLE) _text += " based on the North American Ensemble Forecast System (NAEFS - Environment Canada)";
    if (impacts_source == databaseNumber_OBSERVED) _text += " based on real-time Surface Weather Observation (SWOB - Environment Canada)";
    
    _text += ", www.solarchvision.com";

    if (GRAPHS_record_PDF == 1) {
      Diagrams_textSize(GRAPHS_X_View * 0.01 * 2.0 / 3.0);
      my_text(_text, GRAPHS_X_View * 0.55, GRAPHS_Y_View * -0.4925, 0);
    }
    else {
      if (Image_Scale == 1) Diagrams_textSize(GRAPHS_X_View * 0.01 * Image_Scale);
      else Diagrams_textSize(GRAPHS_X_View * 0.01 * Image_Scale * 2.0 / 3.0);
      
      my_text(_text, GRAPHS_X_View * 0.55 * Image_Scale, GRAPHS_Y_View * -0.4925 * Image_Scale, 0);
    }

   
  
    if (update_DevelopDATA != 0) {
      SOLARCHVISION_DevelopDATA(impacts_source);
      update_DevelopDATA = 0;
    }     
    if (GRAPHS_record_PDF == 1) {
      endRecord();
      println("PDF:end");
      
      GRAPHS_record_PDF = 0;
      if (off_screen != 0) {
        //resetMatrix();
        
        stroke(0); 
        fill(0);
        strokeWeight(0);
        //rect(0, 0, GRAPHS_Y_View, GRAPHS_Y_View);
        rect(0, 0, GRAPHS_X_View, GRAPHS_Y_View);
        blendMode(REPLACE);
        
        imageMode(CORNER);
        image(pre_Diagrams, 0, 0, GRAPHS_X_View, GRAPHS_Y_View);
      }
    }
    else if (off_screen != 0) {
      Diagrams_endDraw();
      
      if ((GRAPHS_record_JPG == 1) || (GRAPHS_record_AUTO == 1)) {
        Diagrams_save(MAKE_Filenames() + ".jpg");
        println("Image created");
      }
      
      //resetMatrix();
      
      stroke(0); 
      fill(0);
      strokeWeight(0);
      //rect(0, 0, GRAPHS_Y_View, GRAPHS_Y_View);
      rect(0, 0, GRAPHS_X_View, GRAPHS_Y_View);
      blendMode(REPLACE);

      imageMode(CORNER);
      image(Diagrams, 0, 0, GRAPHS_X_View, GRAPHS_Y_View);
      pre_Diagrams = Diagrams;
      pre_Image_Scale = Image_Scale;
 
    }
    else {
      PImage get_screen;
      get_screen = get(0, 0, GRAPHS_X_View, GRAPHS_Y_View);
      pre_Diagrams = createGraphics(GRAPHS_X_View, GRAPHS_Y_View, P2D);
      pre_Diagrams.beginDraw();
      pre_Diagrams.image(get_screen, 0, 0, GRAPHS_X_View, GRAPHS_Y_View);
      pre_Diagrams.endDraw();
      pre_Image_Scale = 1;
    }
  }
  else {
    //resetMatrix();
    
    stroke(0); 
    fill(0);
    strokeWeight(0);
    rect(0, 0, GRAPHS_X_View, GRAPHS_Y_View);
    blendMode(REPLACE);
    
    imageMode(CORNER);
    image(pre_Diagrams, 0, 0, GRAPHS_X_View, GRAPHS_Y_View);
  }

  save_info_node = 0;
  save_info_norm = 0;
  save_info_prob = 0;

  GRAPHS_Update = 0;
   
  if ((GRAPHS_record_JPG == 1) || (GRAPHS_record_AUTO == 0)) GRAPHS_record_JPG = 0;

  popMatrix();

  cursor(HAND);

  GRAPHS_Update = 0;
  
} 



int now_drawing = -1; // -1 = Nothing, 0 = Climate WY2, 1 = Forecast, 2 = Observation, 3 = Climate EPW 

void SOLARCHVISION_PlotHOURLY (float x, float y, float z, float sx, float sy, float sz) {

  int draw_climate_WY2 = 0;
  int draw_forecast = 0;
  int draw_observed = 0;
  int draw_climate_EPW = 0; 
  
  if (impacts_source == databaseNumber_CLIMATE_WY2) draw_climate_WY2 = 1;
  if (impacts_source == databaseNumber_ENSEMBLE) draw_forecast = 1;
  if (impacts_source == databaseNumber_OBSERVED) draw_observed = 1;
  if (impacts_source == databaseNumber_CLIMATE_EPW) draw_climate_EPW = 1;
  
  //////////////////
  draw_observed = 1;
  //////////////////  

  if (draw_climate_EPW == 1) {
    now_drawing = databaseNumber_CLIMATE_EPW;
    SOLARCHVISION_PlotCLIMATE_EPW(x, y, z, sx, sy, sz);
  }  
  if (draw_climate_WY2 == 1) {
    now_drawing = databaseNumber_CLIMATE_WY2;
    SOLARCHVISION_PlotCLIMATE_WY2(x, y, z, sx, sy, sz);
  }
  if (draw_forecast == 1) {
    now_drawing = databaseNumber_ENSEMBLE;
    SOLARCHVISION_PlotENSEMBLE(x, y, z, sx, sy, sz);
  }
  if (draw_observed == 1) {

    int pre_draw_data_lines = draw_data_lines;
    int pre_draw_sorted = draw_sorted;
    int pre_draw_normals = draw_normals;
    int pre_draw_probs = draw_probs;
    
    draw_data_lines = 1;
    draw_sorted = 0;
    draw_normals = 1;
    draw_probs = 0; 
    
    now_drawing = databaseNumber_OBSERVED;
    SOLARCHVISION_PlotOBSERVED(x, y, z, sx, sy, sz);
    
    draw_data_lines = pre_draw_data_lines;
    draw_sorted = pre_draw_sorted;
    draw_normals = pre_draw_normals;
    draw_probs = pre_draw_probs; 
  }
  
  now_drawing = -1;
}





void Plot_Setup () {

  if (GRAPHS_setup == 100) {

    SOLARCHVISION_PlotIMPACT(0, -175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View); 
    
    SOLARCHVISION_PlotHOURLY(0, 175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

  }  
  
  // -----------------------------------------------
  
  if (GRAPHS_setup == -2) {
    if (impacts_source == databaseNumber_ENSEMBLE) {
      pre_DATE = _DATE;
      int pre_BEGIN_DAY = BEGIN_DAY;
      int delta = 4;
      
      SOLARCHVISION_PlotHOURLY(0, 525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
  
      _DATE -= delta;
      SOLARCHVISION_update_date();
      BEGIN_DAY = Convert2Date(_MONTH, _DAY);
      SOLARCHVISION_try_update_forecast(_YEAR, _MONTH, _DAY, _HOUR);
      BEGIN_DAY = (BEGIN_DAY + delta) % 365;
      SOLARCHVISION_PlotHOURLY(0, 175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
  
      _DATE -= delta;
      SOLARCHVISION_update_date();
      BEGIN_DAY = Convert2Date(_MONTH, _DAY);
      SOLARCHVISION_try_update_forecast(_YEAR, _MONTH, _DAY, _HOUR);
      BEGIN_DAY = (BEGIN_DAY + 2 * delta) % 365;
      SOLARCHVISION_PlotHOURLY(0, -175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
  
      _DATE -= delta;
      SOLARCHVISION_update_date();
      BEGIN_DAY = Convert2Date(_MONTH, _DAY);
      SOLARCHVISION_try_update_forecast(_YEAR, _MONTH, _DAY, _HOUR);
      BEGIN_DAY = (BEGIN_DAY + 3 * delta) % 365;
      SOLARCHVISION_PlotHOURLY(0, -525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
      
      _DATE = pre_DATE;
      SOLARCHVISION_update_date();
      BEGIN_DAY = Convert2Date(_MONTH, _DAY);
      SOLARCHVISION_try_update_forecast(_YEAR, _MONTH, _DAY, _HOUR);
      BEGIN_DAY = pre_BEGIN_DAY;
    }
  }
  
  
  if (GRAPHS_setup == -1) {
    pre_impacts_source = impacts_source;
    
    impacts_source = databaseNumber_ENSEMBLE; 

    draw_sorted = 0;
    draw_normals = 0;
    draw_data_lines = 1;
    draw_probs = 1;
    SOLARCHVISION_PlotHOURLY(0, 525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View); 
    
    draw_sorted = 1;
    draw_normals = 1;
    draw_data_lines = 0;
    draw_probs = 0; 
    SOLARCHVISION_PlotHOURLY(0, 175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    impacts_source = databaseNumber_CLIMATE_WY2;
    
    draw_sorted = 0;
    draw_normals = 0;
    draw_data_lines = 1;
    draw_probs = 1;
    
    SOLARCHVISION_PlotHOURLY(0, -175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View); 
    
    draw_sorted = 1;
    draw_normals = 1;
    draw_data_lines = 0;
    draw_probs = 0; 
    SOLARCHVISION_PlotHOURLY(0, -525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
    
    impacts_source = pre_impacts_source;
  }
  
  
  if (GRAPHS_setup == 0) {
    if (impacts_source == databaseNumber_CLIMATE_WY2) {
      int pre_H_layer_option = H_layer_option;
      
      H_layer_option = 3;
      SOLARCHVISION_PlotHOURLY(0, -525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View); 
  
      H_layer_option = 4;
      SOLARCHVISION_PlotHOURLY(0, -175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View); 
  
      H_layer_option = 5;
      SOLARCHVISION_PlotHOURLY(0, 175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View); 
  
      H_layer_option = 0;
      SOLARCHVISION_PlotHOURLY(0, 525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
      
      H_layer_option = pre_H_layer_option;
    }       
    if (impacts_source == databaseNumber_ENSEMBLE) {
      int pre_F_layer_option = F_layer_option;
      
      F_layer_option = 4;
      SOLARCHVISION_PlotHOURLY(0, -525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View); 
  
      F_layer_option = 3;
      SOLARCHVISION_PlotHOURLY(0, -175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View); 
  
      F_layer_option = 1;
      SOLARCHVISION_PlotHOURLY(0, 175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View); 
  
      F_layer_option = 0;
      SOLARCHVISION_PlotHOURLY(0, 525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
      
      F_layer_option = pre_F_layer_option;
    } 
  }


  if (GRAPHS_setup == 1) {
    int pre_drw_Layer = drw_Layer;
    int pre_develop_option = develop_option;
    
    develop_Layer = drw_Layer;
    drw_Layer = _developed; 
    
    develop_option = 1;
    SOLARCHVISION_DevelopDATA(impacts_source);
    SOLARCHVISION_PlotHOURLY(0, -525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View); 

    develop_option = 2;
    SOLARCHVISION_DevelopDATA(impacts_source);
    SOLARCHVISION_PlotHOURLY(0, -175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View); 

    develop_option = 3;
    SOLARCHVISION_DevelopDATA(impacts_source);
    SOLARCHVISION_PlotHOURLY(0, 175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View); 

    develop_option = 4;
    SOLARCHVISION_DevelopDATA(impacts_source);
    SOLARCHVISION_PlotHOURLY(0, 525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View); 

    develop_option = pre_develop_option;
    drw_Layer = pre_drw_Layer; 
  }  
  
  
  if (GRAPHS_setup == 2) {
    if (drw_Layer != _developed) {
      int pre_drw_Layer = drw_Layer;
      
      SOLARCHVISION_PlotHOURLY(0, -525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
  
      develop_Layer = drw_Layer;
      drw_Layer = _developed;
  
      develop_option = 6; 
      SOLARCHVISION_DevelopDATA(impacts_source);
      SOLARCHVISION_PlotHOURLY(0, -175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
  
      develop_option = 7; 
      SOLARCHVISION_DevelopDATA(impacts_source);
      SOLARCHVISION_PlotHOURLY(0, 175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
  
      develop_option = 8; 
      SOLARCHVISION_DevelopDATA(impacts_source);
      SOLARCHVISION_PlotHOURLY(0, 525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
      
      drw_Layer = pre_drw_Layer; 
    }
  }  
  
  
  if (GRAPHS_setup == 3) {
    int pre_drw_Layer = drw_Layer;
    
    drw_Layer = _windspd200hPa;
    SOLARCHVISION_PlotHOURLY(0, -525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    drw_Layer = _pressure;
    SOLARCHVISION_PlotHOURLY(0, -175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    drw_Layer = _heightp500hPa;
    SOLARCHVISION_PlotHOURLY(0, 175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    drw_Layer = _thicknesses_1000_500;
    SOLARCHVISION_PlotHOURLY(0, 525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    drw_Layer = pre_drw_Layer;
  }
  
  
  if (GRAPHS_setup == 4) {
    int pre_drw_Layer = drw_Layer;
    
    drw_Layer = _windspd;
    //SOLARCHVISION_PlotHOURLY(0, -525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    //drw_Layer = _precipitation;
    drw_Layer = _pressure;
    //drw_Layer = _glohorrad;
    SOLARCHVISION_PlotHOURLY(0, -175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    //drw_Layer = _relhum;
    drw_Layer = _drybulb;
    SOLARCHVISION_PlotHOURLY(0, 175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    drw_Layer = _drybulb;
    //SOLARCHVISION_PlotHOURLY(0, 525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    drw_Layer = pre_drw_Layer;
  }  
  
  
  if (GRAPHS_setup == 5) {
    int pre_drw_Layer = drw_Layer;
    int pre_develop_option = develop_option;
    
    drw_Layer = _dirnorrad;
    SOLARCHVISION_PlotHOURLY(0, -525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    drw_Layer = _difhorrad;
    SOLARCHVISION_PlotHOURLY(0, -175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    drw_Layer = _developed;
    develop_option = 1; 
    SOLARCHVISION_DevelopDATA(impacts_source);
    SOLARCHVISION_PlotHOURLY(0, 175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    drw_Layer = _developed;
    develop_option = 3; 
    SOLARCHVISION_DevelopDATA(impacts_source);
    SOLARCHVISION_PlotHOURLY(0, 525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    drw_Layer = pre_drw_Layer;
    develop_option = pre_develop_option;
  }
  
  
  if (GRAPHS_setup == 6) {
    int pre_sky_scenario = sky_scenario;
    
    sky_scenario = 4;
    SOLARCHVISION_PlotHOURLY(0, -525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    sky_scenario = 3;
    SOLARCHVISION_PlotHOURLY(0, -175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    sky_scenario = 2;
    SOLARCHVISION_PlotHOURLY(0, 175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    sky_scenario = 1;
    SOLARCHVISION_PlotHOURLY(0, 525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    sky_scenario = pre_sky_scenario;
  }  
  
  
  if (GRAPHS_setup == 7) {
    int pre_plot_impacts = plot_impacts;
    
    draw_sorted = 0;
    draw_normals = 0;
    draw_data_lines = 1;
    draw_probs = 1; 
    SOLARCHVISION_PlotHOURLY(0, 525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    draw_sorted = 1;
    draw_normals = 1;
    draw_data_lines = 0;
    draw_probs = 0;
    SOLARCHVISION_PlotHOURLY(0, 175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
    
    plot_impacts = -2;
    SOLARCHVISION_PlotIMPACT(0, -200 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
    
    plot_impacts = -1;
    SOLARCHVISION_PlotIMPACT(0, -525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
   
    plot_impacts = pre_plot_impacts; 
  }
  

  if (GRAPHS_setup == 8) {
    int pre_plot_impacts = plot_impacts;
    int pre_impact_layer = impact_layer;
    
    draw_sorted = 0;
    draw_normals = 0;
    draw_data_lines = 1;
    draw_probs = 1;
    SOLARCHVISION_PlotHOURLY(0, 525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View); 

    draw_sorted = 1;
    draw_normals = 1;
    draw_data_lines = 0;
    draw_probs = 0; 
    SOLARCHVISION_PlotHOURLY(0, 175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    if (update_impacts == 1) {    
      plot_impacts = 3;
      SOLARCHVISION_PlotIMPACT(0, -200 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
    }
    else if (GRAPHS_record_PDF == 0) {
      //resetMatrix();
      
      stroke(0); 
      fill(0);
      strokeWeight(0);
      rect(0, 0, GRAPHS_Y_View, GRAPHS_Y_View / 2);
      blendMode(REPLACE);
      
      Diagrams_copy(pre_Diagrams, 0, 0, int(pre_Image_Scale * GRAPHS_Y_View), int(pre_Image_Scale * GRAPHS_Y_View / 2), 0, 0, int(Image_Scale * GRAPHS_Y_View), int(Image_Scale * GRAPHS_Y_View / 2));
    }
    
    plot_impacts = pre_plot_impacts; 
    impact_layer = pre_impact_layer;
  }


  if (GRAPHS_setup == 9) {
    int pre_plot_impacts = plot_impacts;
    int pre_impact_layer = impact_layer;

    
    draw_sorted = 0;
    draw_normals = 0;
    draw_data_lines = 1;
    draw_probs = 1;
    SOLARCHVISION_PlotHOURLY(0, 525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View); 

    draw_sorted = 1;
    draw_normals = 1;
    draw_data_lines = 0;
    draw_probs = 0; 
    SOLARCHVISION_PlotHOURLY(0, 175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
    
    if (update_impacts == 1) {    
      plot_impacts = 2;
      SOLARCHVISION_PlotIMPACT(0, -200 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
    }
    else if (GRAPHS_record_PDF == 0) {  
      //resetMatrix();
      
      stroke(0); 
      fill(0);
      strokeWeight(0);
      rect(0, 0, GRAPHS_Y_View, GRAPHS_Y_View / 2);
      blendMode(REPLACE);
  
      Diagrams_copy(pre_Diagrams, 0, 0, int(pre_Image_Scale * GRAPHS_Y_View), int(pre_Image_Scale * GRAPHS_Y_View / 2), 0, 0, int(Image_Scale * GRAPHS_Y_View), int(Image_Scale * GRAPHS_Y_View / 2));
    }
    
    plot_impacts = pre_plot_impacts;
    impact_layer = pre_impact_layer;
  }

  if (GRAPHS_setup == 10) {
    int pre_plot_impacts = plot_impacts;
    int pre_impact_layer = impact_layer;

    
    draw_sorted = 0;
    draw_normals = 0;
    draw_data_lines = 1;
    draw_probs = 1;
    SOLARCHVISION_PlotHOURLY(0, 525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    draw_sorted = 1;
    draw_normals = 1;
    draw_data_lines = 0;
    draw_probs = 0;
    SOLARCHVISION_PlotHOURLY(0, 175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
    
    plot_impacts = 4;
    SOLARCHVISION_PlotIMPACT(0, -200 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    plot_impacts = pre_plot_impacts; 
    impact_layer = pre_impact_layer;
  }
  
  if (GRAPHS_setup == 11) {
    int pre_plot_impacts = plot_impacts;
    int pre_impact_layer = impact_layer;
    
    draw_sorted = 0;
    draw_normals = 0;
    draw_data_lines = 1;
    draw_probs = 1;
    SOLARCHVISION_PlotHOURLY(0, 525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    draw_sorted = 1;
    draw_normals = 1;
    draw_data_lines = 0;
    draw_probs = 0;
    SOLARCHVISION_PlotHOURLY(0, 175 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
    
    plot_impacts = 5;
    SOLARCHVISION_PlotIMPACT(0, -200 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    plot_impacts = pre_plot_impacts; 
    impact_layer = pre_impact_layer;
  }  

  if (GRAPHS_setup == 12) {
    int pre_plot_impacts = plot_impacts;
    int pre_impact_layer = impact_layer;
    
    if (automated != 0) {
      draw_sorted = 0;
      draw_normals = 1;
      draw_data_lines = 0;
      draw_probs = 1;
    }
/*   
    drw_Layer = _windspd; 
    SOLARCHVISION_PlotHOURLY(0, 125 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View); 

    drw_Layer = _precipitation ; 
    develop_Layer = drw_Layer;
    drw_Layer = _developed; 
    develop_option = 9;
    SOLARCHVISION_DevelopDATA(impacts_source); 
    SOLARCHVISION_PlotHOURLY(0, 325 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    drw_Layer = _drybulb; 
    SOLARCHVISION_PlotHOURLY(0, 525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    plot_impacts = 1;
    camera_variation = 2;
    SOLARCHVISION_PlotIMPACT(0, -625 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
    camera_variation = 1;
    SOLARCHVISION_PlotIMPACT(0, -425 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    plot_impacts = -2;
    SOLARCHVISION_PlotIMPACT(0, -150 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
*/
/*
    plot_impacts = -2;
    SOLARCHVISION_PlotIMPACT(0, -150 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    drw_Layer = _precipitation ; 
    develop_Layer = drw_Layer;
    drw_Layer = _developed; 
    develop_option = 9;
    SOLARCHVISION_DevelopDATA(impacts_source); 
    SOLARCHVISION_PlotHOURLY(0, 125 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
*/

    plot_impacts = 1;
    camera_variation = 2;
    SOLARCHVISION_PlotIMPACT(0, -100 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
    camera_variation = 1;
    SOLARCHVISION_PlotIMPACT(0, 100 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    plot_impacts = pre_plot_impacts; 
    impact_layer = pre_impact_layer;
  }

  if (GRAPHS_setup == 13) {
    int pre_plot_impacts = plot_impacts;
    int pre_impact_layer = impact_layer;

    if (automated != 0) {
      draw_sorted = 1;
      draw_normals = 1;
      draw_data_lines = 0;
      draw_probs = 0;
    }
    

    drw_Layer = drw_Layer = _dirnorrad; 
    SOLARCHVISION_PlotHOURLY(0, 125 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View); 

    drw_Layer = _glohorrad; //_difhorrad; // <<<<<<<<<<<<<< 
    SOLARCHVISION_PlotHOURLY(0, 325 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    drw_Layer = _cloudcover;
    SOLARCHVISION_PlotHOURLY(0, 525 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    plot_impacts = 0;
    camera_variation = 2;
    SOLARCHVISION_PlotIMPACT(0, -625 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);
    camera_variation = 1;
    SOLARCHVISION_PlotIMPACT(0, -425 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);

    plot_impacts = 2; //4;
    SOLARCHVISION_PlotIMPACT(0, -150 * GRAPHS_S_View, 0, (100.0 * GRAPHS_U_scale * GRAPHS_S_View), (-1.0 * GRAPHS_V_scale[drw_Layer] * GRAPHS_S_View), 1.0 * GRAPHS_S_View);


    plot_impacts = pre_plot_impacts; 
    impact_layer = pre_impact_layer;

  }  
    
}






String[] getfiles (String _Folder) {
  File dir = new File(_Folder);
  
  String[] filenames = dir.list();
  
  if (filenames != null) {
    for (int i = 0; i < filenames.length; i++) {
      //println(filenames[i]);
    }
  }
  return filenames;
}

void my_line (float ax, float ay, float az, float bx, float by, float bz) {
  //line(ax, ay, az, bx, by, bz);
  Diagrams_line(ax, ay, bx, by);
}

void my_text (String s, float a, float b, float c) {
  //text(s, a, b, c);
  Diagrams_text(s, a, b);
}


int _Opacity (float GRAPHS_O_scale) {
 int k = int(GRAPHS_O_scale * 0.01 * 256);
 if (k > 255) k = 255;
 if (k < 0) k = 0;
 
 return k; 
}


float sin_ang (float a) {
 return sin(a * PI / 180); 
}

float cos_ang (float a) {
 return cos(a * PI / 180); 
}

float tan_ang (float a) {
 return tan(a * PI / 180); 
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

float atan2_ang (float a, float b) {
 return ((atan2(a, b)) * 180/PI); 
}

float roundTo (float a, float b) {
  float a_floor = (floor (a / (1.0 * b))) * b;
  float a_ceil =  (ceil (a / (1.0 * b))) * b;
  float c;
  if ((a - a_floor) > (a_ceil - a)) {
    c = a_ceil;
  }
  else {
    c = a_floor;
  }
  return c;
}

float dist_lon_lat (double lon1, double lat1, double lon2, double lat2) {

  float dLon = (float) (lon2 - lon1); 
  float dLat = (float) (lat2 - lat1);

  float a = sin_ang(dLon / 2.0);
  float b = sin_ang(dLat / 2.0) * sin_ang(dLat / 2.0) + cos_ang((float) lat1) * cos_ang((float) lat2) * a * a;
  float d = 2 * atan2(sqrt(b), sqrt(1 - b)) * (float) R_earth; 

  return(d);
}

float fn_dist (float[] a, float[] b) {

  float d = 0;
  for (int i = 0; i < a.length; i++) {
    d += pow(b[i] - a[i], 2);
  }
  d = pow(d, 0.5);
  
  return d;
}

float[] fn_G (float[][] a) {

  float[] b = a[0]; // initializing to the first node
  
  // adding other nodes
  for (int i = 1; i < a.length; i++) {
    for (int j = 0; j < b.length; j++) {
      b[j] += a[i][j];
    }
  }

  // dividing to the number of nodes
  for (int j = 0; j < b.length; j++) {
    b[j] /= float(a.length);
  }
  
  return b;
}

float[] fn_normalize (float[] a) {
  float[] b = a;
  float d = 0;
  for (int i = 0; i < a.length; i++) {
    d += pow(a[i], 2);
  }
  d = pow(d, 0.5);
  
  for (int i = 0; i < a.length; i++) {
    if (d != 0) b[i] = a[i]/d;
    else b[i] = 0;
  } 
  return b;
}

float fn_dot (float[] a, float b[]) {
  float d = 0;
  for (int i = 0; i < min(a.length, b.length); i++) {
    d += a[i] * b[i];
  }
  return d;
}



float[] SOLARCHVISION_WBGRW (float _variable) {
  _variable *= 600.0;
  
  float v;
  float[] COL = {255, 0, 0, 0};

  if (_variable < 0) {
    COL[1] = 255;
    COL[2] = 255;
    COL[3] = 255;
  }
  else if (_variable < 100) {
    v = ((_variable) * 2.55);
    COL[1] = (255 - v);
    COL[2] = (255 - v);
    COL[3] = 255;
  }
  else if (_variable < 200) {
    v = ((_variable - 100) * 2.55);
    COL[1] = 0;
    COL[2] = v;
    COL[3] = 255;
  }
  else if (_variable < 300) {
    v = ((_variable - 200) * 2.55);
    COL[1] = 0;
    COL[2] = 255;
    COL[3] = (255 - v);
  }
  else if (_variable < 400) {
    v = ((_variable - 300) * 2.55);
    COL[1] = v;
    COL[2] = 255;
    COL[3] = 0;
  }
  else if (_variable < 500) {
    v = ((_variable - 400) * 2.55);
    COL[1] = 255;
    COL[2] = (255 - v);
    COL[3] = 0;
  }
  else if (_variable < 600) {
    v = ((_variable - 500) * 2.55);
    COL[1] = 255;
    COL[2] = v;
    COL[3] = v;
  }
  else {
    COL[1] = 255;
    COL[2] = 255;
    COL[3] = 255;
  }
  
  return COL;
}

float[] SOLARCHVISION_BGR (float _variable) {
  _variable *= 400.0;
  
  float v;
  float[] COL = {255, 0, 0, 0};

  if (_variable < 0) {
    COL[1] = 0;
    COL[2] = 0;
    COL[3] = 255;
  }
  else if (_variable < 100) {
    v = ((_variable) * 2.55);
    COL[1] = 0;
    COL[2] = v;
    COL[3] = 255;
  }
  else if (_variable < 200) {
    v = ((_variable - 100) * 2.55);
    COL[1] = 0;
    COL[2] = 255;
    COL[3] = (255 - v);
  }
  else if (_variable < 300) {
    v = ((_variable - 200) * 2.55);
    COL[1] = v;
    COL[2] = 255;
    COL[3] = 0;
  }
  else if (_variable < 400) {
    v = ((_variable - 300) * 2.55);
    COL[1] = 255;
    COL[2] = (255 - v);
    COL[3] = 0;
  }
  else {
    COL[1] = 255;
    COL[2] = 0;
    COL[3] = 0;
  }
  
  return COL;
}

float[] SOLARCHVISION_DBGR (float _variable) {
  _variable *= 500.0;
  
  float v;
  float[] COL = {255, 0, 0, 0};
  if (_variable < 0) {
    COL[1] = 0;
    COL[2] = 0;
    COL[3] = 0;
  }
  else if (_variable < 100) {
    v = ((_variable) * 2.55);
    COL[1] = 0;
    COL[2] = 0;
    COL[3] = v;
  }
  else if (_variable < 200) {
    v = ((_variable - 100) * 2.55);
    COL[1] = 0;
    COL[2] = v;
    COL[3] = 255;
  }
  else if (_variable < 300) {
    v = ((_variable - 200) * 2.55);
    COL[1] = 0;
    COL[2] = 255;
    COL[3] = (255 - v);
  }
  else if (_variable < 400) {
    v = ((_variable - 300) * 2.55);
    COL[1] = v;
    COL[2] = 255;
    COL[3] = 0;
  }
  else if (_variable < 500) {
    v = ((_variable - 400) * 2.55);
    COL[1] = 255;
    COL[2] = (255 - v);
    COL[3] = 0;
  }
  else {
    COL[1] = 255;
    COL[2] = 0;
    COL[3] = 0;
  }
  
  return COL;
}

float[] SOLARCHVISION_DWBGR (float _variable) {
  _variable *= 600.0;
  
  float v;
  float[] COL = {255, 0, 0, 0};
  if (_variable < 0) {
    COL[1] = 0;
    COL[2] = 0;
    COL[3] = 0;
  }
  else if (_variable < 100) {
    v = ((_variable) * 2.55);
    COL[1] = v;
    COL[2] = v;
    COL[3] = v;
  }
  else if (_variable < 200) {
    v = ((_variable - 100) * 2.55);
    COL[1] = (255 - v);
    COL[2] = (255 - v);
    COL[3] = 255;
  }
  else if (_variable < 300) {
    v = ((_variable - 200) * 2.55);
    COL[1] = 0;
    COL[2] = v;
    COL[3] = 255;
  }
  else if (_variable < 400) {
    v = ((_variable - 300) * 2.55);
    COL[1] = 0;
    COL[2] = 255;
    COL[3] = (255 - v);
  }
  else if (_variable < 500) {
    v = ((_variable - 400) * 2.55);
    COL[1] = v;
    COL[2] = 255;
    COL[3] = 0;
  }
  else if (_variable < 600) {
    v = ((_variable - 500) * 2.55);
    COL[1] = 255;
    COL[2] = (255 - v);
    COL[3] = 0;
  }
  else {
    COL[1] = 255;
    COL[2] = 0;
    COL[3] = 0;
  }
  
  return COL;
}

float[] SOLARCHVISION_VDWBGR (float _variable) {
  _variable *= 700.0;
  
  float v;
  float[] COL = {255, 0, 0, 0};
  if (_variable < 0) {
    COL[1] = 255;
    COL[2] = 0;
    COL[3] = 255;
  }
  else if (_variable < 100) {
    v = ((_variable - 0) * 2.55);
    COL[1] = (255 - v);
    COL[2] = 0;
    COL[3] = (255 - v);
  } 
  else if (_variable < 200) {
    v = ((_variable - 100) * 2.55);
    COL[1] = v;
    COL[2] = v;
    COL[3] = v;
  }
  else if (_variable < 300) {
    v = ((_variable - 200) * 2.55);
    COL[1] = (255 - v);
    COL[2] = (255 - v);
    COL[3] = 255;
  }
  else if (_variable < 400) {
    v = ((_variable - 300) * 2.55);
    COL[1] = 0;
    COL[2] = v;
    COL[3] = 255;
  }
  else if (_variable < 500) {
    v = ((_variable - 400) * 2.55);
    COL[1] = 0;
    COL[2] = 255;
    COL[3] = (255 - v);
  }
  else if (_variable < 600) {
    v = ((_variable - 500) * 2.55);
    COL[1] = v;
    COL[2] = 255;
    COL[3] = 0;
  }
  else if (_variable < 700) {
    v = ((_variable - 600) * 2.55);
    COL[1] = 255;
    COL[2] = (255 - v);
    COL[3] = 0;
  }
  else {
    COL[1] = 255;
    COL[2] = 0;
    COL[3] = 0;
  }
  
  return COL;
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


float[] GET_COLOR_STYLE (int COLOR_STYLE, float j) {
  float[] c = {255, 0, 0, 0};
  
  if (COLOR_STYLE == 0) {
    c[0] = _Opacity(GRAPHS_O_scale);
    c[1] = 0;
    c[2] = 0;
    c[3] = 0;
  }
  else if (COLOR_STYLE == 15) {
    float[] _COL = SOLARCHVISION_DRYW(j);
    c[0] = 255;
    c[1] = _COL[1];
    c[2] = _COL[2];
    c[3] = _COL[3];
  } 
  else if (COLOR_STYLE == 14) {
    float[] _COL = SOLARCHVISION_DBGR(j);
    c[0] = 255;
    c[1] = _COL[1];
    c[2] = _COL[2];
    c[3] = _COL[3];
  } 
  else if (COLOR_STYLE == 13) {
    float[] _COL = SOLARCHVISION_DWBGR(j);
    c[0] = 255;
    c[1] = _COL[1];
    c[2] = _COL[2];
    c[3] = _COL[3];
  } 
  else if (COLOR_STYLE == 12) {
    float[] _COL = SOLARCHVISION_BGR(j);
    c[0] = 255;
    c[1] = _COL[1];
    c[2] = _COL[2];
    c[3] = _COL[3];
  } 
  else if (COLOR_STYLE == 11) {
    float[] _COL = SOLARCHVISION_BGR(j);
    c[0] = 127;
    c[1] = 255 - 0.5 * _COL[1];
    c[2] = 255 - 0.5 * _COL[2];
    c[3] = 255 - 0.5 * _COL[3];
    Diagrams_stroke(255 - 0.5 * _COL[1], 255 - 0.5 * _COL[2], 255 - 0.5 * _COL[3], 127);
  }  
  else if (COLOR_STYLE == 10) {
    float[] _COL = SOLARCHVISION_BGR(j);
    c[0] = 255;
    c[1] = 255 - _COL[1];
    c[2] = 255 - _COL[2];
    c[3] = 255 - _COL[3];
  } 
  else if (COLOR_STYLE == 9) {
    float[] _COL = SOLARCHVISION_WBGRW(j);
    c[0] = 255;
    c[1] = _COL[1];
    c[2] = _COL[2];
    c[3] = _COL[3];
  } 
  else if (COLOR_STYLE == 8) {
    float[] _COL = SOLARCHVISION_BGR(j);
    c[0] = 255;
    c[1] = 255 - _COL[1];
    c[2] = 255 - _COL[2];
    c[3] = 255 - _COL[3];
  }
  else if (COLOR_STYLE == 7) {
    float[] _COL = SOLARCHVISION_WBGRW(j);
    c[0] = 255;
    c[1] = 255 - _COL[1];
    c[2] = 255 - _COL[2];
    c[3] = 255 - _COL[3];
  }     
  else if (COLOR_STYLE == 6) {
    float[] _COL = SOLARCHVISION_BGR(j);
    c[0] = 255;
    c[1] = _COL[3];
    c[2] = _COL[2];
    c[3] = _COL[1];
  } 
  else if (COLOR_STYLE == 4) {
    float[] _COL = SOLARCHVISION_VDWBGR(j);
    c[0] = GRAPHS_O_scale;
    c[1] = _COL[1];
    c[2] = _COL[2];
    c[3] = _COL[3];
  }      
  else if (COLOR_STYLE == 3) {
    float[] _COL = SOLARCHVISION_VDWBGR(j);
    c[0] = 255;
    c[1] = _COL[1];
    c[2] = _COL[2];
    c[3] = _COL[3];
  } 
  else if (COLOR_STYLE == 2) {
    float[] _COL = SOLARCHVISION_DRYWCBD (2.0 * (j - 0.5) * (2.0 / 2.75));
    c[0] = GRAPHS_O_scale;
    c[1] = _COL[1];
    c[2] = _COL[2];
    c[3] = _COL[3];
  }      
  else if (COLOR_STYLE == 1) {
    float[] _COL = SOLARCHVISION_DRYWCBD (2.0 * (j - 0.5) * (2.0 / 2.75));
    c[0] = 255;
    c[1] = _COL[1];
    c[2] = _COL[2];
    c[3] = _COL[3];
  } 
  else if (COLOR_STYLE == 5) {
    c[0] = 255;
    c[1] = 0;
    c[2] = 0;
    c[3] = 0;
  }
  else if (COLOR_STYLE == -1) {
    float[] _COL = SOLARCHVISION_DRYWCBD (2.0 * (j - 0.5) * (2.0 / 2.75));
    c[0] = 255;
    c[1] = 255 - _COL[3];
    c[2] = 255 - _COL[2];
    c[3] = 255 - _COL[1];
  } 
  
  
  return c;
}


void SET_COLOR_STYLE (int COLOR_STYLE, float j) {
  float[] _COL = GET_COLOR_STYLE(COLOR_STYLE, j);

  Diagrams_stroke(_COL[1], _COL[2], _COL[3], _COL[0]);
  Diagrams_fill(_COL[1], _COL[2], _COL[3], _COL[0]);
}

void SOLARCHVISION_Calendar () {
  CalendarMM = new String [365][2];
  CalendarDD = new String [365][2];
  CalendarDay = new String [365][2];
  
  CalendarDate = new int [365][2];
  
  int k = 285;
  for (int l = 0; l < 2; l += 1) {
    for (int i = 0; i < 12; i += 1) {
      for (int j = 0; j < CalendarLength[i]; j += 1) {
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
  for (int i = 0; i < (_MONTH - 1); i += 1) {
    for (int j = 0; j < CalendarLength[i]; j += 1) {
      k += 1;
      if (k == 365) k = 0; 
    }
  }
  k += _DAY - 1;
  
  k = k % 365;
  return k;
}

void SOLARCHVISION_update_date () {
  _MONTH = CalendarDate[int(_DATE)][0]; 
  _DAY = CalendarDate[int(_DATE)][1];
  _HOUR = int(24 * (_DATE - int(_DATE)));
}

int SOLARCHVISION_try_update_forecast (int THE_YEAR, int THE_MONTH, int THE_DAY, int THE_HOUR) {
  int File_Found = 0;

  ENSEMBLE = new float [24][365][num_layers][(1 + ENSEMBLE_end - ENSEMBLE_start)];
  ENSEMBLE_DATA = new int [24][365][num_layers][(1 + ENSEMBLE_end - ENSEMBLE_start)]; // -1: undefined, 0: interpolated, 1: data

  for (int i = 0; i < 24; i += 1) {
    for (int j = 0; j < 365; j += 1) {
      for (int l = 0; l < num_layers; l += 1) {
        for (int k = 0; k < (1 + ENSEMBLE_end - ENSEMBLE_start); k += 1) {
          ENSEMBLE[i][j][l][k] = FLOAT_undefined;
          ENSEMBLE_DATA[i][j][l][k] = -1; 
        }
      }
    }
  }
  
  if (Load_ENSEMBLE == 1) {
  
    for (int f = 0; f < num_layers; f++) {
      if (THE_LAYERS[f].equals("")) {
      }
      else {
        String FN = nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + nf(THE_DAY, 2) + nf(THE_HOUR, 2) + "_GEPS-NAEFS-RAW_" + THE_STATION + "_" + THE_LAYERS[f] + "_000-384";
      
        //println (FN);
        for (int i = 0; i < FORECAST_XML_Files.length; i++) {
          //println(FORECAST_XML_Files[i]); 
          
          int _L = FORECAST_XML_Files[i].length();
          String _Extention = FORECAST_XML_Files[i].substring(_L - 4, _L);
          //println(_Extention);
          if (_Extention.toLowerCase().equals(".xml")) {
            _Filenames = FORECAST_XML_Files[i].substring(0, _L - 4);
            
            //println (FN);
            //println (_Filenames);
            //println ("");
            
            if (_Filenames.equals(FN)) {
              //println ("FILE FOUND:", FN);
              File_Found = 1;
              SOLARCHVISION_LoadENSEMBLE((ENSEMBLE_directory + "/" + FORECAST_XML_Files[i]), f);
            }
          }
        }
        if (File_Found == 0) println ("FILE NOT FOUND:", FN);
      }
    }
    
    println("End of initializing xml files.");
    
    int MAX_SEARCH = 6; // It defines how many hours the program should seek for each point to find next available data.  
    
    for (int l = 0; l < num_layers; l += 1) {
      if (THE_LAYERS[l].equals("")) {
      }
      else {
    
        //////////////////////////////////////  PASS 1  //////////////////////////////////////  
        
        for (int k = 0; k < (1 + ENSEMBLE_end - ENSEMBLE_start); k += 1) {
          float pre_v = FLOAT_undefined;
          int pre_num = 0;
          
          for (int j_for = 0; j_for < max_j_end_forecast; j_for += 1) { 
          int j = (int(j_for + _DATE + 365 - 286) % 365);
  
            for (int i = 0; i < 24; i += 1) {
              
              if (ENSEMBLE[i][j][l][k] > 0.9 * FLOAT_undefined) {
                if (pre_v < 0.9 * FLOAT_undefined) {
                  pre_num += 1;
                  
                  float next_v = FLOAT_undefined;
                  int next_i = i;
                  int next_j = j;
                  int next_num = 0;
                  while ((next_num < MAX_SEARCH) && (next_v > 0.9 * FLOAT_undefined)) {
                    next_num += 1;
                    next_i += 1;
                    if (next_i == 24) {
                      next_i -= 24;
                      next_j += 1; 
                    }
                    if (next_j == 365) {
                      next_j = 0;
                    }
                    if (ENSEMBLE[next_i][next_j][l][k] > 0.9 * FLOAT_undefined) {
                    }
                    else {
                      next_v = ENSEMBLE[next_i][next_j][l][k];
                      
                      if (l == _winddir) {
                        if ((next_v - pre_v) > 180) next_v -= 360;
                        if ((next_v - pre_v) < -180) next_v += 360;
                      } 
                    }  
                  }
                  if (next_num < MAX_SEARCH) {
                    //if (l == _winddir) ENSEMBLE[i][j][l][k] = ((next_num * pre_v + pre_num * next_v) / (pre_num + next_num) + 360) % 360;
                    //else ENSEMBLE[i][j][l][k] = (next_num * pre_v + pre_num * next_v) / (pre_num + next_num);
                    
                    float interpolation_pow = pow(2.0, interpolation_weight);
                
                    ENSEMBLE[i][j][l][k] = (pow(next_num, interpolation_pow) * pre_v + pow(pre_num, interpolation_pow) * next_v) / (pow(next_num, interpolation_pow) + pow(pre_num, interpolation_pow));
                    if (l == _winddir) ENSEMBLE[i][j][l][k] = (ENSEMBLE[i][j][l][k] + 360) % 360;
                    
                    
                    //println("[i][j][l][k]", i, j, l, k);
                    ENSEMBLE_DATA[i][j][l][k] = 0; // On Layers: RH and TMP it didn't work with MODEL_RUN == 12!!!!!!!!!!!!!!!!!!??????????
                  }
                  else {
                    ENSEMBLE_DATA[i][j][l][k] = -1;
                  }
                }
              }
              else {
                ENSEMBLE_DATA[i][j][l][k] = 1;
                pre_v = ENSEMBLE[i][j][l][k];
                pre_num = 0;
              }
            }
          }
        }
        
        //////////////////////////////////////  PASS 2  //////////////////////////////////////      
        
        if (Climatic_weather_model != 0) {
        
          int pre_num_add_days = num_add_days;
          
          num_add_days = 7; // 1; for faster results      
        
          float[][][] _valuesO;
          float[][][] _valuesO_overcast;
          float[][][] _valuesO_scattered;
          float[][][] _valuesO_clear;
          
          _valuesO           = new float[24][max_j_end_forecast][((1 + CLIMATE_WY2_end - CLIMATE_WY2_start) * num_add_days)];
          _valuesO_overcast  = new float[24][max_j_end_forecast][((1 + CLIMATE_WY2_end - CLIMATE_WY2_start) * num_add_days)];
          _valuesO_scattered = new float[24][max_j_end_forecast][((1 + CLIMATE_WY2_end - CLIMATE_WY2_start) * num_add_days)];
          _valuesO_clear     = new float[24][max_j_end_forecast][((1 + CLIMATE_WY2_end - CLIMATE_WY2_start) * num_add_days)];
    
          for (int i = 0; i < 24; i += 1) {      
          
            for (int k = 0; k < (1 + CLIMATE_WY2_end - CLIMATE_WY2_start); k += 1) {
              for (int j_ADD = 0; j_ADD < num_add_days; j_ADD += 1) {
                
                for (int j = 0; j < max_j_end_forecast; j += 1) {
                  
                  int now_j = int(j * per_day + (j_ADD - int(0.5 * num_add_days)) + BEGIN_DAY + 365) % 365;
    
                  if (now_j >= 365) {
                    now_j = now_j % 365; 
                  }
                  if (now_j < 0) {
                    now_j = (now_j + 365) % 365; 
                  }           
              
  
                  _valuesO          [i][j][(k * num_add_days + j_ADD)] = FLOAT_undefined;
                  _valuesO_overcast [i][j][(k * num_add_days + j_ADD)] = FLOAT_undefined;
                  _valuesO_scattered[i][j][(k * num_add_days + j_ADD)] = FLOAT_undefined;
                  _valuesO_clear    [i][j][(k * num_add_days + j_ADD)] = FLOAT_undefined; 
          
                  float Pa = CLIMATE_WY2[i][now_j][l][k];
        
                  if (Pa > 0.9 * FLOAT_undefined) {
                  }
                  else {
                    _valuesO[i][j][(k * num_add_days + j_ADD)] = Float.valueOf(Pa);
                    
                    if (SOLARCHVISION_filter("CLIMATE_WY2", _cloudcover, _daily, 2, i, now_j, k) == 1) {
                      _valuesO_overcast[i][j][(k * num_add_days + j_ADD)] = Float.valueOf(Pa);
                    }
                    
                    if (SOLARCHVISION_filter("CLIMATE_WY2", _cloudcover, _daily, 3, i, now_j, k) == 1) {
                      _valuesO_scattered[i][j][(k * num_add_days + j_ADD)] = Float.valueOf(Pa);
                    }
                    
                    if (SOLARCHVISION_filter("CLIMATE_WY2", _cloudcover, _daily, 4, i, now_j, k) == 1) {
                      _valuesO_clear[i][j][(k * num_add_days + j_ADD)] = Float.valueOf(Pa);
                    }                  
                  }
                  
                }        
              }
            }  
          }
        
          float[][] _valuesH;
          float[][] _valuesH_overcast;
          float[][] _valuesH_scattered;
          float[][] _valuesH_clear;
          
          _valuesH           = new float[24][max_j_end_forecast];
          _valuesH_overcast  = new float[24][max_j_end_forecast];
          _valuesH_scattered = new float[24][max_j_end_forecast];
          _valuesH_clear     = new float[24][max_j_end_forecast];
          
          for (int i = 0; i < 24; i += 1) {
            for (int j = 0; j < max_j_end_forecast; j += 1) {      
              _valuesH          [i][j] = SOLARCHVISION_NORMAL(_valuesO          [i][j])[N_Middle];
              _valuesH_overcast [i][j] = SOLARCHVISION_NORMAL(_valuesO_overcast [i][j])[N_Middle];
              _valuesH_scattered[i][j] = SOLARCHVISION_NORMAL(_valuesO_scattered[i][j])[N_Middle];
              _valuesH_clear    [i][j] = SOLARCHVISION_NORMAL(_valuesO_clear    [i][j])[N_Middle];
              
              //if (l == _drybulb) println("Average at hour", i, ", day", j, "=", _valuesH[i][j]);
            }
          }
    
          num_add_days = pre_num_add_days;
          
    
    
    
          for (int k = 0; k < (1 + ENSEMBLE_end - ENSEMBLE_start); k += 1) {
            int pre_num = 0;
            
            float pre_v = FLOAT_undefined;
            int pre_hour = -1; // that means it is undefined.
            int pre_day = -1; // that means it is undefined.
            
            for (int j_for = 0; j_for < max_j_end_forecast; j_for += 1) { 
              int now_j = (int(j_for + _DATE + 365 - 286) % 365);
               if (now_j >= 365) {
                now_j = now_j % 365; 
              }
              if (now_j < 0) {
                now_j = (now_j + 365) % 365; 
              }        
              
              for (int i = 0; i < 24; i += 1) {
                if (ENSEMBLE_DATA[i][now_j][l][k] == 0) { // if it was interpolated then ...
                
                  if (pre_v < 0.9 * FLOAT_undefined) {
                    pre_num += 1;
                    
                    float next_v = FLOAT_undefined;
                    int next_hour = -1; // that means it is undefined.
                    int next_day = -1; // that means it is undefined.
                    
                    int next_i = i;
                    int next_j = now_j;
                    int next_num = 0;
                    
                    while ((next_num < MAX_SEARCH) && (next_v > 0.9 * FLOAT_undefined)) {
                      next_num += 1;
                      next_i += 1;
                      if (next_i == 24) {
                        next_i -= 24;
                        next_j += 1; 
                      }
                      if (next_j == 365) {
                        next_j = 0; 
                      }
                      if (ENSEMBLE_DATA[next_i][next_j][l][k] != 0) { // if it wasn't interpolated then ...
                        next_v = ENSEMBLE[next_i][next_j][l][k];
                        next_hour = next_i;
                        next_day = (int(next_j - _DATE + 286 + 365) % 365); 
    
    
                        // non-linear post processing for some parameters
                        if ((l == _drybulb) || (l == _relhum)) {
                            
                          if ((pre_v < 0.9 * FLOAT_undefined) && (next_v < 0.9 * FLOAT_undefined)) {
                            // replacing linear interpolated forecast with new values based on hourly patterns of observations in recent days.
                            
                            float linear_climate = 0;
                            float current_dist = 0;
    
                            if (Climatic_weather_model == 1) {
                              linear_climate = (next_num * _valuesH[pre_hour][pre_day] + pre_num * _valuesH[next_hour][next_day]) / (pre_num + next_num);
                              current_dist = _valuesH[i][j_for] - linear_climate;
                            }
                            else {                    
                              if ((SOLARCHVISION_filter("ENSEMBLE", _cloudcover, _daily, 2, i, now_j, k)) == 1) {
                                linear_climate = (next_num * _valuesH_overcast[pre_hour][pre_day] + pre_num * _valuesH_overcast[next_hour][next_day]) / (pre_num + next_num);
                                current_dist = _valuesH_overcast[i][j_for] - linear_climate;
                              }
                              else if ((SOLARCHVISION_filter("ENSEMBLE", _cloudcover, _daily, 3, i, now_j, k)) == 1) {
                                linear_climate = (next_num * _valuesH_scattered[pre_hour][pre_day] + pre_num * _valuesH_scattered[next_hour][next_day]) / (pre_num + next_num);
                                current_dist = _valuesH_scattered[i][j_for] - linear_climate;
                              }
                              //else if ((SOLARCHVISION_filter("ENSEMBLE", _cloudcover, _daily, 4, i, now_j, k)) == 1) {
                              else {
                                linear_climate = (next_num * _valuesH_clear[pre_hour][pre_day] + pre_num * _valuesH_clear[next_hour][next_day]) / (pre_num + next_num);
                                current_dist = _valuesH_clear[i][j_for] - linear_climate;
                              }
                            }                          
  
    
                            ENSEMBLE[i][now_j][l][k] = ENSEMBLE[i][now_j][l][k] + current_dist;
                          }
                        }       
                        
                        
                        if (l == _winddir) {
                          if ((next_v - pre_v) > 180) next_v -= 360;
                          if ((next_v - pre_v) < -180) next_v += 360;
                        } 
                      }  
                    }
            
                    ENSEMBLE_DATA[i][now_j][l][k] = 0;
                  }
                  else {
                    ENSEMBLE_DATA[i][now_j][l][k] = -1;
                  }
                  
                }
                else {
                  ENSEMBLE_DATA[i][now_j][l][k] = 1;
                  pre_v = ENSEMBLE[i][now_j][l][k];
                  pre_num = 0;
                  
                  pre_hour = i;
                  pre_day = j_for;
    
                }
              }
            }
            
          }
        }
        
        //////////////////////////////////////  END PASS 2  //////////////////////////////////////
        
      }
    }
    
    println("Post-processing solar components ...");
  
    int num_count = (1 + CLIMATE_WY2_end - CLIMATE_WY2_start);
    
    for (int k = 0; k < (1 + ENSEMBLE_end - ENSEMBLE_start); k += 1) {
      for (int j_for = 0; j_for < max_j_end_forecast; j_for += 1) { 
        int j = ((j_for + BEGIN_DAY) % 365);
        for (int i = 0; i < 24; i += 1) {
          if (ENSEMBLE[i][j][_cloudcover][k] > 0.9 * FLOAT_undefined) {
          }
          else {
            float DATE_ANGLE = (360 * ((286 + j) % 365) / 365.0);
            float HOUR_ANGLE = i; 
            
            float[] SunR = SOLARCHVISION_SunPositionRadiation(LocationLatitude, DATE_ANGLE, HOUR_ANGLE, ENSEMBLE[i][j][_cloudcover][k]);
            float T = ENSEMBLE[i][j][_drybulb][k];
    
            ENSEMBLE[i][j][_dirnorrad][k] = SunR[4];
            ENSEMBLE_DATA[i][j][_dirnorrad][k] = 0;
            
            ENSEMBLE[i][j][_difhorrad][k] = SunR[5];
            ENSEMBLE_DATA[i][j][_difhorrad][k] = 0;
  
            ENSEMBLE[i][j][_glohorrad][k] = SunR[4] * SunR[3] + SunR[5];
            ENSEMBLE_DATA[i][j][_glohorrad][k] = 0;
  
         
  //---------------------------------------------------------------------
            if (Climatic_solar_model == 1) {
    
              float Forecast_CC = ENSEMBLE[i][j][_cloudcover][k];
              float Forecast_AP = ENSEMBLE[i][j][_pressure][k];
              
              float CC_epsilon = 1.0; // defines a range for finding near previous results: 1.0 results in e.g. 2 < CC < 4 for CC at 3  
              float AP_epsilon = 50.0;
              
              float _valuesSUM_DIR = 0;
              float _valuesSUM_DIF = 0;
              float _valuesSUM_GLO = 0;
              float sum_count = 0;
              
              float process_add_days = 11;
              
              for (int q = 0; q < num_count; q += 1) {
                   
                for (int j_ADD = 0; j_ADD < process_add_days; j_ADD += 1) { 
            
                  int now_i = i;
                  int now_j = int(j + (j_ADD - int(0.5 * process_add_days)) + 365) % 365;
                  
                  if (now_j >= 365) {
                   now_j = now_j % 365; 
                  }
                  if (now_j < 0) {
                   now_j = (now_j + 365) % 365; 
                  }
        
                
                  if ((CLIMATE_WY2[now_i][now_j][_cloudcover][q] > 0.9 * FLOAT_undefined) || (CLIMATE_WY2[now_i][now_j][_pressure][q] > 0.9 * FLOAT_undefined)) {
                  }
                  else {
                    float CC_dist = abs(Forecast_CC - CLIMATE_WY2[now_i][now_j][_cloudcover][q]);
                    float AP_dist = abs(Forecast_AP - CLIMATE_WY2[now_i][now_j][_pressure][q]);
                    if ((CC_dist < CC_epsilon) && (AP_dist < AP_epsilon)) {
                      
                      float _weight;
                      
                      _weight = 1; 
                      _weight *= pow(abs(1 - pow(CC_dist/CC_epsilon, 2)), 2); // to add more wights to closer cases
                      _weight *= pow(abs(1 - pow(AP_dist/AP_epsilon, 2)), 2);
                      
                      sum_count += _weight;
                      
                      if (CLIMATE_WY2[now_i][now_j][_dirnorrad][q] > 0.9 * FLOAT_undefined) {} else _valuesSUM_DIR += _weight * CLIMATE_WY2[now_i][now_j][_dirnorrad][q]; 
                      if (CLIMATE_WY2[now_i][now_j][_difhorrad][q] > 0.9 * FLOAT_undefined) {} else _valuesSUM_DIF += _weight * CLIMATE_WY2[now_i][now_j][_difhorrad][q]; 
                      if (CLIMATE_WY2[now_i][now_j][_glohorrad][q] > 0.9 * FLOAT_undefined) {} else _valuesSUM_GLO += _weight * CLIMATE_WY2[now_i][now_j][_glohorrad][q]; 
        
                    }
                  }
                }
              }
              
              if (sum_count != 0) {
                _valuesSUM_DIR /= sum_count;
                _valuesSUM_DIF /= sum_count;
                _valuesSUM_GLO /= sum_count;
    
                ENSEMBLE[i][j][_dirnorrad][k] = _valuesSUM_DIR;
                ENSEMBLE[i][j][_difhorrad][k] = _valuesSUM_DIF;
                ENSEMBLE[i][j][_glohorrad][k] = _valuesSUM_GLO;
                
              }  
              else {
                //println("Cannot find simillar conditions in climate file at i:", i, ", j:", j, ", k:", k); 
              }
            }      
  
  //---------------------------------------------------------------------
         
            ENSEMBLE[i][j][_direffect][k] = ENSEMBLE[i][j][_dirnorrad][k] * (18 - T);
            ENSEMBLE_DATA[i][j][_direffect][k] = 0;
            
            ENSEMBLE[i][j][_difeffect][k] = ENSEMBLE[i][j][_difhorrad][k] * (18 - T);
            ENSEMBLE_DATA[i][j][_difeffect][k] = 0; 
            
          }     
        }
      }
    }
  

  }
  
  //SOLARCHVISION_DevelopDATA(impacts_source);
 
  return File_Found;
}


void SOLARCHVISION_LoadENSEMBLE (String FileName, int Load_Layer) {
  String lineSTR;
  String[] input;
  
  XML FileALL = loadXML(FileName);
  
  //println (_YEAR, _MONTH, _DAY, _HOUR);
 
  XML[] children0 = FileALL.getChildren("forecast");
 
  for (int Li = 0; Li < children0.length; Li++) {
      
    int _a1 = children0[Li].getInt("forecast_hour");
    String _a2 = children0[Li].getString("valid_time");

    //println("Li=", Li, "hour =", _a1, "date:", _a2);
    
    if (Li >= 0) {
      
      int THE_YEAR = int(_a2.substring(0, 4));
      int THE_MONTH = int(_a2.substring(4, 6));
      int THE_DAY = int(_a2.substring(6, 8));
      int THE_HOUR = int(_a2.substring(8));
      
      //println (THE_YEAR, THE_MONTH, THE_DAY, THE_HOUR);

      int now_i = int(THE_HOUR);
      int now_j = Convert2Date(THE_MONTH, THE_DAY);
      
      //println (now_i, now_j);
      
      now_i -= int(-LocationTimeZone / 15);
      if (now_i < 0) {
        now_i += 24;
        now_j -= 1;
        if (now_j < 0) {
          now_j += 365;
        } 
      }
      
      //println (now_i, now_j);
      //println ("-------------");
      
      XML[] _c = children0[Li].getChildren("model");
      //println("number of members:", _c.length);
    
      for (int Lk = 0; Lk < _c.length; Lk++) {
        int k = _c[Lk].getInt("id") - 1;
       
        if (k < (1 + ENSEMBLE_end - ENSEMBLE_start)) {

          ENSEMBLE[now_i][now_j][Load_Layer][k] = Float.valueOf(_c[Lk].getContent());
        }
      }
    }
  }  
}


void SOLARCHVISION_PlotENSEMBLE (float x_Plot, float y_Plot, float z_Plot, float sx_Plot, float sy_Plot, float sz_Plot) {
  
  _pix = (100.0 * GRAPHS_S_View / level_pix);

  Diagrams_pushMatrix();
  Diagrams_translate(x_Plot, y_Plot);
  
  color_data_lines = color(0, 0, 63, _Opacity(GRAPHS_O_scale));
  
  SOLARCHVISION_draw_Grid_Cartesian_TIME(x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot);

  int start_z = get_startZ_endZ(databaseNumber_ENSEMBLE)[0];
  int end_z = get_startZ_endZ(databaseNumber_ENSEMBLE)[1]; 
  
  if (GRAPHS_print_title != 0) {
    
    Diagrams_stroke(0); 
    Diagrams_fill(0);
    Diagrams_strokeWeight(GRAPHS_T_scale * 0);
  
    Diagrams_textSize(sx_Plot * 0.150 / GRAPHS_U_scale);
    Diagrams_textAlign(RIGHT, CENTER); 
    my_text(("[Members:" + String.valueOf(start_z) + "-" + String.valueOf(end_z) + "] "), 0, (0.3 + V_belowLine[drw_Layer]) * sx_Plot / GRAPHS_U_scale, 0);

    Diagrams_textSize(sx_Plot * 0.150 / GRAPHS_U_scale);
    Diagrams_textAlign(LEFT, CENTER); 
    my_text((_LAYERS[drw_Layer][(_LAN + 1)]), 0, (0.3 + V_belowLine[drw_Layer]) * sx_Plot / GRAPHS_U_scale, 0);
  
  }
  
  float Pa = FLOAT_undefined;
  float Pb = FLOAT_undefined;

  float[] _valuesA;
  float[] _valuesB; 
  _valuesA = new float[(1 + ENSEMBLE_end - ENSEMBLE_start)];
  _valuesB = new float[(1 + ENSEMBLE_end - ENSEMBLE_start)]; 

  float[] _valuesSUM; 
  float[] _valuesNUM;
  int _interval = 0;
  _valuesSUM = new float[(1 + ENSEMBLE_end - ENSEMBLE_start)];
  _valuesNUM = new float[(1 + ENSEMBLE_end - ENSEMBLE_start)];
 
  for (int k = 0; k < (1 + ENSEMBLE_end - ENSEMBLE_start); k += 1) { 
    _valuesA[k] = FLOAT_undefined;
    _valuesB[k] = FLOAT_undefined;
    _valuesSUM[k] = FLOAT_undefined;
    _valuesNUM[k] = 0;
  }
  
  float[] Ax_LINES = {0};
  float[] Ay_LINES = {0};
  float[] Az_LINES = {0};
  float[] Bx_LINES = {0};
  float[] By_LINES = {0};
  float[] Bz_LINES = {0};
  
  File_output_node = new PrintWriter [(j_end - j_start)];
  File_output_norm = new PrintWriter [(j_end - j_start)];
  File_output_prob = new PrintWriter [(j_end - j_start)];
  
  String Main_name = MAKE_mainname();

  for (int j = j_start; j < j_end; j += 1) { 
    
    Diagrams_stroke(0);
    Diagrams_fill(0);
    Diagrams_textAlign(CENTER, CENTER); 

    if ((GRAPHS_U_scale >= 0.75) || (((j - j_start) % int(1.5 / GRAPHS_U_scale)) == 0)) {
      Diagrams_textSize(sx_Plot * 0.15 / GRAPHS_U_scale);
      
      my_text(CalendarDay[int((365 + j + 286 + BEGIN_DAY) % 365)][_LAN], (j - ((0 - 12) / 24.0)) * sx_Plot, -1.25 * sx_Plot / GRAPHS_U_scale, 0);
      if (num_add_days > 1) {
        //my_text(("±" + int(num_add_days / 2) + _WORDS[2][_LAN] + "s"), (0 + j - ((0 - 12) / 24.0)) * sx_Plot, -1 * sx_Plot, 0);
      }
    }
    
    String _FilenamesAdd = "";
    if (num_add_days > 1) {
        //_FilenamesAdd = ("±" + int(num_add_days / 2) + _WORDS[2][_LAN] + "s");
    }
    if ((save_info_node == 1) && (draw_data_lines == 1)) {
      File_output_node[(j - j_start)] = createWriter("/" + Main_name + "/FORECAST_node_" + LocationName + "_from_" + String.valueOf(start_z) + "_to_" + String.valueOf(end_z) + "_" + _LAYERS[drw_Layer][(_EN + 1)] + "_" + sky_scenario_file[sky_scenario] + "_" + CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + ".txt");
      File_output_node[(j - j_start)].println(CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + "\t" + sky_scenario_file[sky_scenario] + "\t" + _LAYERS[drw_Layer][(_EN + 1)] + "(" + _LAYERS[drw_Layer][0] + ")" + "\tfrom:" + String.valueOf(start_z) + "\tto:" + String.valueOf(end_z) + "\t" + LocationName + "\tHourly data(FORECAST)");

      File_output_node[(j - j_start)].print("Hour\t");
      for (int l = start_z; l < (1 + end_z); l += 1) {
        File_output_node[(j - j_start)].print(nf(l, 4) + "        \t");
      }
      File_output_node[(j - j_start)].println("");
    }
    if ((save_info_norm == 1) && (draw_normals == 1)) {
      File_output_norm[(j - j_start)] = createWriter("/" + Main_name + "/FORECAST_norm_" + LocationName + "_from_" + String.valueOf(start_z) + "_to_" + String.valueOf(end_z) + "_" + _LAYERS[drw_Layer][(_EN + 1)] + "_" + sky_scenario_file[sky_scenario] + "_" + CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + ".txt");
      File_output_norm[(j - j_start)].println(CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + "\t" + sky_scenario_file[sky_scenario] + "\t" + _LAYERS[drw_Layer][(_EN + 1)] + "(" + _LAYERS[drw_Layer][0] + ")" + "\tfrom:" + String.valueOf(start_z) + "\tto:" + String.valueOf(end_z) + "\t" + LocationName + "\tHourly normal(FORECAST)");
      File_output_norm[(j - j_start)].print("Hour\t");
      for (int l = 0; l < 9; l += 1) {
        File_output_norm[(j - j_start)].print(N_Title[l] + "\t"); 
      }
      File_output_norm[(j - j_start)].println("");
    }
    if ((save_info_prob == 1) && (draw_probs == 1)) {
      File_output_prob[(j - j_start)] = createWriter("/" + Main_name + "/FORECAST_prob_" + LocationName + "_from_" + String.valueOf(start_z) + "_to_" + String.valueOf(end_z) + "_" + _LAYERS[drw_Layer][(_EN + 1)] + "_" + sky_scenario_file[sky_scenario] + "_" + CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + ".txt");
      File_output_prob[(j - j_start)].println(CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + "\t" + sky_scenario_file[sky_scenario] + "\t" + _LAYERS[drw_Layer][(_EN + 1)] + "(" + _LAYERS[drw_Layer][0] + ")" + "\tfrom:" + String.valueOf(start_z) + "\tto:" + String.valueOf(end_z) + "\t" + LocationName + "\tHourly probabilities(FORECAST)");

      File_output_prob[(j - j_start)].print("Hour:\t");
      File_output_prob[(j - j_start)].println("");
    }

    for (int i = 0; i < 24; i += 1) {
      if ((save_info_node == 1) && (draw_data_lines == 1)) File_output_node[(j - j_start)].print(nf(i, 2) + "\t");
      if ((save_info_norm == 1) && (draw_normals == 1)) File_output_norm[(j - j_start)].print(nf(i, 2) + "\t");
      if ((save_info_prob == 1) && (draw_probs == 1)) File_output_prob[(j - j_start)].print(nf(i, 2) + "\t");

      for (int k = (start_z - 1); k <= (end_z - 1); k += 1) {

        _valuesA[k] = FLOAT_undefined;
        _valuesB[k] = FLOAT_undefined;
        
        if ((k + 1) == 22) {
          Diagrams_stroke(127, 0, 255, 127); 
          Diagrams_fill(127, 0, 255);
          Diagrams_strokeWeight(GRAPHS_T_scale * 6);
        }
        else {
          SET_COLOR_STYLE(COLOR_STYLE, (1.0 * k / (1 + ENSEMBLE_end - ENSEMBLE_start)));
          Diagrams_strokeWeight(GRAPHS_T_scale * 1);
        }
        
        int _plot = 1;
        
        if (_plot == 1) {
          
          int now_k = k;
          int now_i = i;
          int now_j = (j + BEGIN_DAY + 365) % 365;

          if (now_j >= 365) {
           now_j = now_j % 365; 
          }
          if (now_j < 0) {
           now_j = (now_j + 365) % 365; 
          }

          int next_i = now_i + dT;
          int next_j = now_j;
          int next_k = now_k;
          if (next_i >= 24) {
            next_i = 0; //i % 24;
            next_j += 1; //int((i / 24);
            if (next_j >= 365) {
              next_j = next_j % 365;
              //next_k += 1; 
            }
          }

          Pa = ENSEMBLE[now_i][now_j][drw_Layer][now_k]; 
          if (Pa > 0.9 * FLOAT_undefined) {
            _valuesA[k] = FLOAT_undefined;
            
            if ((save_info_node == 1) && (draw_data_lines == 1)) File_output_node[(j - j_start)].print("[undefined]\t"); 
          }
          else {
            int drw_count = SOLARCHVISION_filter("ENSEMBLE", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
            
            if (drw_count == 1) {

              _valuesA[k] = Pa;
              _valuesA[k] += V_offset[drw_Layer];
              
              _valuesSUM[k] += _valuesA[k];
              _valuesNUM[k] += 1;

              if ((ENSEMBLE_DATA[now_i][now_j][drw_Layer][now_k] == 1) && ((draw_data_lines == 1))) Diagrams_ellipse((j + ((i + 0.5) / 24.0)) * sx_Plot, _valuesA[k] * sy_Plot, 5, 5);

                if ((save_info_node == 1) && (draw_data_lines == 1)) {
                  if (_valuesA[k] < 0.9 * FLOAT_undefined) File_output_node[(j - j_start)].print(nfs(_valuesA[k] - V_offset[drw_Layer], 5, 5) + "\t"); 
                  else File_output_node[(j - j_start)].print("[undefined]\t");
                }
                            
              if (next_k < (1 + ENSEMBLE_end - ENSEMBLE_start)) {
                
                Pb = ENSEMBLE[next_i][next_j][drw_Layer][next_k];
                if (Pb > 0.9 * FLOAT_undefined) {
                  _valuesB[k] = FLOAT_undefined;
                }
                else {
                  _valuesB[k] = Pb;
                  _valuesB[k] += V_offset[drw_Layer];
                  
                  if (draw_data_lines == 1) {
                    if ((drw_Layer == _winddir) && (abs(_valuesB[k] - _valuesA[k]) > 180)) {
                      
                    }
                    else {
                      Ax_LINES = append(Ax_LINES, (j + ((i + 0.5) / 24.0)) * sx_Plot);
                      Ay_LINES = append(Ay_LINES, _valuesA[k] * sy_Plot);
                      Az_LINES = append(Az_LINES, now_k * sz_Plot * GRAPHS_W_scale);
                      Bx_LINES = append(Bx_LINES, (j + ((i + 0.5 + dT) / 24.0)) * sx_Plot);
                      By_LINES = append(By_LINES, _valuesB[k] * sy_Plot);
                      Bz_LINES = append(Bz_LINES, next_k * sz_Plot * GRAPHS_W_scale);
                    } 
                  }
                }
              }
            }
            else {
              if ((save_info_node == 1) && (draw_data_lines == 1)) File_output_node[(j - j_start)].print("not_the_case\t");
            }
          }          
        }
      }
 
      if ((save_info_node == 1) && (draw_data_lines == 1)) File_output_node[(j - j_start)].println();
  
      _interval += 1; 
      if ((_interval % sum_interval) == 0) {
        for (int k = (start_z - 1); k <= (end_z - 1); k += 1) {
          _valuesSUM[k] += _valuesA[k];
          _valuesNUM[k] += 1;
          
          if ((_valuesSUM[k] < 0.9 * FLOAT_undefined) && (_valuesNUM[k] != 0)) {
            _valuesSUM[k] /= _valuesNUM[k];
          }
        }    
        if (draw_probs == 1) {
          SOLARCHVISION_draw_probabilities(i, j, start_z, end_z, _valuesSUM, _valuesNUM, x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot);
        }  

        for (int k = 0; k < (1 + ENSEMBLE_end - ENSEMBLE_start); k += 1) {
          _valuesSUM[k] = 0;
          _valuesNUM[k] = 0;
        }
        
      }        

      if (draw_sorted == 1) {
        SOLARCHVISION_draw_sorted(i, j, _valuesA, _valuesB, x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot);
      }

      if (draw_normals == 1) {
        SOLARCHVISION_draw_normals(i, j, _valuesA, _valuesB, x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot);
      }
    }

    if ((save_info_node == 1) && (draw_data_lines == 1)) {
      File_output_node[(j - j_start)].println("Source: " + nf(_YEAR, 4) + nf(_MONTH, 2) + nf(_DAY, 2) + nf(_HOUR, 2) + "_GEPS-NAEFS-RAW_" + THE_STATION + "_" + THE_LAYERS[drw_Layer] + "_000-384.xml" + ", Environment Canada: http://dd.weatheroffice.ec.gc.ca/ensemble/naefs/");
      File_output_node[(j - j_start)].println("Interpolated and processed by SOLARCHVISION 2014: www.solarchvision.com");
      if (_LAYERS[drw_Layer][0].equals("kW°C/m²") || _LAYERS[drw_Layer][0].equals("W/m²")) File_output_node[(j - j_start)].println("Note: direct and diffuse radiation models are derived form cloud cover and air pressure information using SOLARCHVISION program.");
      File_output_node[(j - j_start)].flush(); 
      File_output_node[(j - j_start)].close(); 
    }
    
    if ((save_info_norm == 1) && (draw_normals == 1)) {
      File_output_norm[(j - j_start)].println("Source: " + nf(_YEAR, 4) + nf(_MONTH, 2) + nf(_DAY, 2) + nf(_HOUR, 2) + "_GEPS-NAEFS-RAW_" + THE_STATION + "_" + THE_LAYERS[drw_Layer] + "_000-384.xml" + ", Environment Canada: http://dd.weatheroffice.ec.gc.ca/ensemble/naefs/");
      File_output_norm[(j - j_start)].println("Calculated and processed by SOLARCHVISION 2014: www.solarchvision.com");
      File_output_norm[(j - j_start)].println("* : SOLARCHVISION internal algorithm");
      if (_LAYERS[drw_Layer][0].equals("kW°C/m²") || _LAYERS[drw_Layer][0].equals("W/m²")) File_output_norm[(j - j_start)].println("Note: direct and diffuse radiation models are derived form cloud cover and air pressure information using SOLARCHVISION program.");
      File_output_norm[(j - j_start)].flush(); 
      File_output_norm[(j - j_start)].close(); 
    }

    if ((save_info_prob == 1) && (draw_probs == 1)) {
      File_output_prob[(j - j_start)].println("Source: " + nf(_YEAR, 4) + nf(_MONTH, 2) + nf(_DAY, 2) + nf(_HOUR, 2) + "_GEPS-NAEFS-RAW_" + THE_STATION + "_" + THE_LAYERS[drw_Layer] + "_000-384.xml" + ", Environment Canada: http://dd.weatheroffice.ec.gc.ca/ensemble/naefs/");
      File_output_prob[(j - j_start)].println("Calculated and processed by SOLARCHVISION 2014: www.solarchvision.com");
      if (_LAYERS[drw_Layer][0].equals("kW°C/m²") || _LAYERS[drw_Layer][0].equals("W/m²")) File_output_prob[(j - j_start)].println("Note: direct and diffuse radiation models are derived form cloud cover and air pressure information using SOLARCHVISION program.");
      File_output_prob[(j - j_start)].flush(); 
      File_output_prob[(j - j_start)].close(); 
    }

  }

  if (draw_data_lines == 1) {
    SOLARCHVISION_draw_data_lines(Ax_LINES, Ay_LINES, Az_LINES, Bx_LINES, By_LINES, Bz_LINES);
  }    

  Diagrams_popMatrix();
} 


int SOLARCHVISION_try_update_CLIMATE_WY2 () {
  int File_Found = 0;
  
  CLIMATE_WY2 = new float [24][365][num_layers][(1 + CLIMATE_WY2_end - CLIMATE_WY2_start)];
 
  for (int i = 0; i < 24; i += 1) {
    for (int j = 0; j < 365; j += 1) {
      for (int l = 0; l < num_layers; l += 1) {
        for (int k = 0; k < (1 + CLIMATE_WY2_end - CLIMATE_WY2_start); k += 1) {
          CLIMATE_WY2[i][j][l][k] = FLOAT_undefined;
        }
      }
    }
  }
  
  
  if (Load_CLIMATE_WY2 == 1) {

    String FN = THE_STATION;
  
    //println (FN);
    for (int i = 0; i < CLIMATE_WY2_Files.length; i++) {
      //println(FORECAST_XML_Files[i]); 
      
      int _L = CLIMATE_WY2_Files[i].length();
      String _Extention = CLIMATE_WY2_Files[i].substring(_L - 4, _L);
      //println(_Extention);
      if (_Extention.toLowerCase().equals(".wy2")) {
        _Filenames = CLIMATE_WY2_Files[i].substring(0, _L - 4);
        
        //println (FN);
        //println (_Filenames);
        //println ("");
        
        if (_Filenames.equals(FN)) {
          //println ("FILE FOUND:", FN);
          File_Found = 1;
          SOLARCHVISION_LoadCLIMATE_WY2((CLIMATE_WY2_directory + "/" + CLIMATE_WY2_Files[i]));
        }
      }
    }
    
    if (File_Found == 0) println ("FILE NOT FOUND:", FN);
  }
  
  return File_Found;
}


void SOLARCHVISION_LoadCLIMATE_WY2 (String FileName) {
  String[] FileALL = loadStrings(FileName);

  String lineSTR;
  String[] input;
  
    
  println("lines = ", FileALL.length);

  for (int f = 0; f < FileALL.length; f += 1) {
    
    lineSTR = FileALL[f];
    //println (lineSTR);
    
    int CLIMATE_YEAR = int(lineSTR.substring(6, 10));
    int CLIMATE_MONTH = int(lineSTR.substring(10, 12));
    int CLIMATE_DAY = int(lineSTR.substring(12, 14));
    int CLIMATE_HOUR = int(lineSTR.substring(14, 16));
    
    //println (CLIMATE_YEAR, CLIMATE_MONTH, CLIMATE_DAY, CLIMATE_HOUR);
    
    int i = int(CLIMATE_HOUR) - 1;
    int j = Convert2Date(CLIMATE_MONTH, CLIMATE_DAY);
    int k = (CLIMATE_YEAR - CLIMATE_WY2_start);
    
    //println (i);
    
    CLIMATE_WY2[i][j][_pressure][k] = float(lineSTR.substring(85, 90)); // 10 times in Pa
    CLIMATE_WY2[i][j][_drybulb][k] = float(lineSTR.substring(91, 95)); // 10 times in °C
    //CLIMATE_WY2[i][j][_relhum][k] = 50; // Relative Humidity is not presented in DCLIMATE files!
    CLIMATE_WY2[i][j][_glohorrad][k] = float(lineSTR.substring(20, 24)); // Wh/m²
    CLIMATE_WY2[i][j][_dirnorrad][k] = float(lineSTR.substring(26, 30)); // Wh/m²
    CLIMATE_WY2[i][j][_difhorrad][k] = float(lineSTR.substring(32, 36)); // Wh/m²
    CLIMATE_WY2[i][j][_windspd][k] = float(lineSTR.substring(105, 109)); // 10 times in m/s
    CLIMATE_WY2[i][j][_winddir][k] = float(lineSTR.substring(101, 104)); // °
    CLIMATE_WY2[i][j][_opaquesky][k] = float(lineSTR.substring(113, 115)); // 0.1 times in %
    CLIMATE_WY2[i][j][_ceilingsky][k] = float(lineSTR.substring(61, 65)); // 0.1 times in m
    
    if (CLIMATE_WY2[i][j][_pressure][k] == 99999) CLIMATE_WY2[i][j][_pressure][k] = FLOAT_undefined;
    else CLIMATE_WY2[i][j][_pressure][k] = 0.1 * CLIMATE_WY2[i][j][_pressure][k];
    
    if (CLIMATE_WY2[i][j][_drybulb][k] == 9999) CLIMATE_WY2[i][j][_drybulb][k] = FLOAT_undefined;
    else CLIMATE_WY2[i][j][_drybulb][k] = 0.1 * CLIMATE_WY2[i][j][_drybulb][k];
    
    if (CLIMATE_WY2[i][j][_glohorrad][k] == 9999) CLIMATE_WY2[i][j][_glohorrad][k] = FLOAT_undefined;
    else CLIMATE_WY2[i][j][_glohorrad][k] = CLIMATE_WY2[i][j][_glohorrad][k] / 3.6; // Wh/m²
    
    if (CLIMATE_WY2[i][j][_dirnorrad][k] == 9999) CLIMATE_WY2[i][j][_dirnorrad][k] = FLOAT_undefined;
    else CLIMATE_WY2[i][j][_dirnorrad][k] = CLIMATE_WY2[i][j][_dirnorrad][k] / 3.6; // Wh/m²
    
    if (CLIMATE_WY2[i][j][_difhorrad][k] == 9999) CLIMATE_WY2[i][j][_difhorrad][k] = FLOAT_undefined;
    else CLIMATE_WY2[i][j][_difhorrad][k] = CLIMATE_WY2[i][j][_difhorrad][k] / 3.6; // Wh/m²
    
    if (CLIMATE_WY2[i][j][_windspd][k] == 9999) CLIMATE_WY2[i][j][_windspd][k] = FLOAT_undefined;
    else CLIMATE_WY2[i][j][_windspd][k] = 0.1 * 3.6 * CLIMATE_WY2[i][j][_windspd][k];
    
    if (CLIMATE_WY2[i][j][_winddir][k] == 999) CLIMATE_WY2[i][j][_winddir][k] = FLOAT_undefined;
    
    if (CLIMATE_WY2[i][j][_opaquesky][k] == 99) CLIMATE_WY2[i][j][_opaquesky][k] = FLOAT_undefined;
    
    if (CLIMATE_WY2[i][j][_ceilingsky][k] == 7777) CLIMATE_WY2[i][j][_ceilingsky][k] = 1000;
    if (CLIMATE_WY2[i][j][_ceilingsky][k] >= 1000) CLIMATE_WY2[i][j][_ceilingsky][k] = 1000; // <<<<<<<<<
    
    if (CLIMATE_WY2[i][j][_ceilingsky][k] == 9999) CLIMATE_WY2[i][j][_ceilingsky][k] = FLOAT_undefined;
    else CLIMATE_WY2[i][j][_ceilingsky][k] = 10 * CLIMATE_WY2[i][j][_ceilingsky][k];

  }

  float Pa, Pb, Pc;
  float T, R_dir, R_dif;
  for (int i = 0; i < 24; i += 1) {
    for (int j = 0; j < 365; j += 1) {
      for (int k = 0; k < (1 + CLIMATE_WY2_end - CLIMATE_WY2_start); k += 1) {
        Pa = CLIMATE_WY2[i][j][_drybulb][k];
        Pb = CLIMATE_WY2[i][j][_dirnorrad][k];
        Pc = CLIMATE_WY2[i][j][_difhorrad][k];
                  
        if ((Pa > 0.9 * FLOAT_undefined) || (Pb > 0.9 * FLOAT_undefined) || (Pc > 0.9 * FLOAT_undefined)) {
        }
        else {
          T = Pa;
          R_dir = Pb;
          R_dif = Pc;
          CLIMATE_WY2[i][j][_direffect][k] = (18 - T) * R_dir;
          CLIMATE_WY2[i][j][_difeffect][k] = (18 - T) * R_dif;
        }
        
        Pa = CLIMATE_WY2[i][j][_ceilingsky][k];
        if (Pa > 0.9 * FLOAT_undefined) {
        }
        else {
          float Px = log(Pa) / log(10.0);
          if (Px > 2) CLIMATE_WY2[i][j][_logceilsky][k] = Px;
          else CLIMATE_WY2[i][j][_logceilsky][k] = 2;
        }
      }
    }
  }
}


void SOLARCHVISION_PlotCLIMATE_WY2 (float x_Plot, float y_Plot, float z_Plot, float sx_Plot, float sy_Plot, float sz_Plot) {
    
  Diagrams_pushMatrix();
  Diagrams_translate(x_Plot, y_Plot);
  
  SOLARCHVISION_draw_Grid_Cartesian_TIME(x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot);
  
  _pix = (100.0 * GRAPHS_S_View / level_pix);
  
  int start_z = get_startZ_endZ(databaseNumber_CLIMATE_WY2)[0];
  int end_z = get_startZ_endZ(databaseNumber_CLIMATE_WY2)[1]; 
  
  if (GRAPHS_print_title != 0) {
    
      Diagrams_stroke(0); 
      Diagrams_fill(0);
      Diagrams_strokeWeight(GRAPHS_T_scale * 0);
    
      Diagrams_textSize(sx_Plot * 0.150 / GRAPHS_U_scale);
      Diagrams_textAlign(RIGHT, CENTER);
      my_text(("[" + String.valueOf(start_z + CLIMATE_WY2_start) + "-" + String.valueOf(end_z + CLIMATE_WY2_start) + "] "), 0, (0.3 + V_belowLine[drw_Layer]) * sx_Plot / GRAPHS_U_scale, 0);
  
      Diagrams_textSize(sx_Plot * 0.150 / GRAPHS_U_scale);
      Diagrams_textAlign(LEFT, CENTER); 
      my_text((_LAYERS[drw_Layer][(_LAN + 1)]), 0, (0.3 + V_belowLine[drw_Layer]) * sx_Plot / GRAPHS_U_scale, 0);
    
  }   

  float Pa = FLOAT_undefined;
  float Pb = FLOAT_undefined;

  float[] _valuesA;
  float[] _valuesB; 
  _valuesA = new float[((1 + CLIMATE_WY2_end - CLIMATE_WY2_start) * num_add_days)];
  _valuesB = new float[((1 + CLIMATE_WY2_end - CLIMATE_WY2_start) * num_add_days)];

  float[] _valuesSUM; 
  float[] _valuesNUM;
  int _interval = 0;
  _valuesSUM = new float[((1 + CLIMATE_WY2_end - CLIMATE_WY2_start) * num_add_days)];
  _valuesNUM = new float[((1 + CLIMATE_WY2_end - CLIMATE_WY2_start) * num_add_days)];
  
  float[] Ax_LINES = {0};
  float[] Ay_LINES = {0};
  float[] Az_LINES = {0};
  float[] Bx_LINES = {0};
  float[] By_LINES = {0};
  float[] Bz_LINES = {0};

  File_output_node = new PrintWriter [(j_end - j_start)];
  File_output_norm = new PrintWriter [(j_end - j_start)];
  File_output_prob = new PrintWriter [(j_end - j_start)];
  
  String Main_name = MAKE_mainname();
  
  for (int j = j_start; j < j_end; j += 1) {
    
    Diagrams_stroke(0);
    Diagrams_fill(0);
    Diagrams_textAlign(CENTER, CENTER); 

    if ((GRAPHS_U_scale >= 0.75) || (((j - j_start) % int(1.5 / GRAPHS_U_scale)) == 0)) {
      Diagrams_textSize(sx_Plot * 0.15 / GRAPHS_U_scale);
      
      my_text(CalendarDay[int((365 + j * per_day + 286 + BEGIN_DAY) % 365)][_LAN], (j - ((0 - 12) / 24.0)) * sx_Plot, -1.25 * sx_Plot / GRAPHS_U_scale, 0);
      if (num_add_days > 1) {
        //my_text(("±" + int(num_add_days / 2) + _WORDS[2][_LAN] + "s"), (0 + j - ((0 - 12) / 24.0)) * sx_Plot, -1 * sx_Plot, 0);
      }
    }    
    
    String _FilenamesAdd = "";
    if (num_add_days > 1) {
        _FilenamesAdd = ("±" + int(num_add_days / 2) + _WORDS[2][_LAN] + "s");
    }
    if ((save_info_node == 1) && (draw_data_lines == 1)) {
      File_output_node[(j - j_start)] = createWriter("/" + Main_name + "/Climate_node_" + LocationName + "_from_" + String.valueOf(start_z + CLIMATE_WY2_start) + "_to_" + String.valueOf(end_z + CLIMATE_WY2_start) + "_" + _LAYERS[drw_Layer][(_EN + 1)] + "_" + sky_scenario_file[sky_scenario] + "_" + CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + ".txt");
      File_output_node[(j - j_start)].println(CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + "\t" + sky_scenario_file[sky_scenario] + "\t" + _LAYERS[drw_Layer][(_EN + 1)] + "(" + _LAYERS[drw_Layer][0] + ")" + "\tfrom:" + String.valueOf(start_z) + "\tto:" + String.valueOf(end_z) + "\t" + LocationName + "\tHourly data(CWEED)");

      File_output_node[(j - j_start)].print("Hour:\t");
      for (int l = start_z; l < (1 + end_z); l += 1) {
        File_output_node[(j - j_start)].print(nf(l, 4) + "        \t");
      }
      File_output_node[(j - j_start)].println("");
    }
    if ((save_info_norm == 1) && (draw_normals == 1)) {
      File_output_norm[(j - j_start)] = createWriter("/" + Main_name + "Climate_norm_" + LocationName + "_from_" + String.valueOf(start_z + CLIMATE_WY2_start) + "_to_" + String.valueOf(end_z + CLIMATE_WY2_start) + "_" + _LAYERS[drw_Layer][(_EN + 1)] + "_" + sky_scenario_file[sky_scenario] + "_" + CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + ".txt");
      File_output_norm[(j - j_start)].println(CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + "\t" + sky_scenario_file[sky_scenario] + "\t" + _LAYERS[drw_Layer][(_EN + 1)] + "(" + _LAYERS[drw_Layer][0] + ")" + "\tfrom:" + String.valueOf(start_z) + "\tto:" + String.valueOf(end_z) + "\t" + LocationName + "\tHourly normal(CWEED)");
      File_output_norm[(j - j_start)].print("Hour:\t");
      for (int l = 0; l < 9; l += 1) {
        File_output_norm[(j - j_start)].print(N_Title[l] + "\t"); 
      }
      File_output_norm[(j - j_start)].println("");
    }
    if ((save_info_prob == 1) && (draw_probs == 1)) {
      File_output_prob[(j - j_start)] = createWriter("/" + Main_name + "Climate_prob_" + LocationName + "_from_" + String.valueOf(start_z + CLIMATE_WY2_start) + "_to_" + String.valueOf(end_z + CLIMATE_WY2_start) + "_" + _LAYERS[drw_Layer][(_EN + 1)] + "_" + sky_scenario_file[sky_scenario] + "_" + CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + ".txt");
      File_output_prob[(j - j_start)].println(CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + "\t" + sky_scenario_file[sky_scenario] + "\t" + _LAYERS[drw_Layer][(_EN + 1)] + "(" + _LAYERS[drw_Layer][0] + ")" + "\tfrom:" + String.valueOf(start_z) + "\tto:" + String.valueOf(end_z) + "\t" + LocationName + "\tHourly probabilities(CWEED)");

      File_output_prob[(j - j_start)].print("Hour:\t");
      File_output_prob[(j - j_start)].println("");
    }

    for (int i = 0; i < 24; i += 1) {
      if ((save_info_node == 1) && (draw_data_lines == 1)) File_output_node[(j - j_start)].print(nf(i, 2) + "\t");
      if ((save_info_norm == 1) && (draw_normals == 1)) File_output_norm[(j - j_start)].print(nf(i, 2) + "\t");
      if ((save_info_prob == 1) && (draw_probs == 1)) File_output_prob[(j - j_start)].print(nf(i, 2) + "\t");

      for (int k = 0; k < (1 + CLIMATE_WY2_end - CLIMATE_WY2_start); k += 1) {
        for (int j_ADD = 0; j_ADD < num_add_days; j_ADD += 1) {
          
          _valuesA[(k * num_add_days + j_ADD)] = FLOAT_undefined;
          _valuesB[(k * num_add_days + j_ADD)] = FLOAT_undefined;
       
          SET_COLOR_STYLE(COLOR_STYLE, (1.0 * k / (1 + CLIMATE_WY2_end - CLIMATE_WY2_start)));

          int _plot = 0;
          
          if ((start_z <= k) && (end_z >= k)) {
            _plot = 1;
          }
          
          if (_plot == 1) {
            
            int now_k = k;
            int now_i = i;
            int now_j = int(j * per_day + (j_ADD - int(0.5 * num_add_days)) + BEGIN_DAY + 365) % 365;
            
            
            if (now_j >= 365) {
             now_j = now_j % 365; 
            }
            if (now_j < 0) {
             now_j = (now_j + 365) % 365; 
            }
  
            int next_i = now_i + 1;
            int next_j = now_j;
            int next_k = now_k;
            if (next_i == 24) {
              next_i = 0;
              next_j += 1;
              if (next_j == 365) {
                next_j = 0;
                next_k += 1; 
              }
            }

            Pa = CLIMATE_WY2[now_i][now_j][drw_Layer][now_k]; 
            if (Pa > 0.9 * FLOAT_undefined) {
              _valuesA[(k * num_add_days + j_ADD)] = FLOAT_undefined;
              
              if ((save_info_node == 1) && (draw_data_lines == 1)) File_output_node[(j - j_start)].print("[undefined]\t");
            }
            else {
              int drw_count = SOLARCHVISION_filter("CLIMATE_WY2", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);

              if (drw_count == 1) {
                _valuesA[(k * num_add_days + j_ADD)] = Pa;
                _valuesA[(k * num_add_days + j_ADD)] += V_offset[drw_Layer];
                
                _valuesSUM[(k * num_add_days + j_ADD)] += _valuesA[(k * num_add_days + j_ADD)];
                _valuesNUM[(k * num_add_days + j_ADD)] += 1;

                if ((save_info_node == 1) && (draw_data_lines == 1)) {
                  if (_valuesA[(k * num_add_days + j_ADD)] < 0.9 * FLOAT_undefined) File_output_node[(j - j_start)].print(nfs(_valuesA[(k * num_add_days + j_ADD)] - V_offset[drw_Layer], 5, 5) + "\t"); 
                  else File_output_node[(j - j_start)].print("[undefined]\t");
                }

                if (next_k < (1 + CLIMATE_WY2_end - CLIMATE_WY2_start)) {
                  Pb = CLIMATE_WY2[next_i][next_j][drw_Layer][next_k];
                  if (Pb > 0.9 * FLOAT_undefined) {
                    _valuesB[(k * num_add_days + j_ADD)] = FLOAT_undefined;
                  }
                  else {
                    _valuesB[(k * num_add_days + j_ADD)] = Pb;
                    _valuesB[(k * num_add_days + j_ADD)] += V_offset[drw_Layer];
                    
                    if (draw_data_lines == 1) {
                      if ((drw_Layer == _winddir) && (abs(_valuesB[(k * num_add_days + j_ADD)] - _valuesA[(k * num_add_days + j_ADD)]) > 180)) {
                      }
                      else {                        
                        Ax_LINES = append(Ax_LINES, (j + ((i + 0.5) / 24.0)) * sx_Plot);
                        Ay_LINES = append(Ay_LINES, _valuesA[(k * num_add_days + j_ADD)] * sy_Plot);
                        Az_LINES = append(Az_LINES, now_k * sz_Plot * GRAPHS_W_scale);
                        Bx_LINES = append(Bx_LINES, (j + ((i + 1.5) / 24.0)) * sx_Plot);
                        By_LINES = append(By_LINES, _valuesB[(k * num_add_days + j_ADD)] * sy_Plot);
                        Bz_LINES = append(Bz_LINES, next_k * sz_Plot * GRAPHS_W_scale);
                      } 
                    }
                  }
                }
              }
              else {
                if ((save_info_node == 1) && (draw_data_lines == 1)) File_output_node[(j - j_start)].print("not_the_case\t");
              }
            }
          }
        }
      }
      
      if ((save_info_node == 1) && (draw_data_lines == 1)) File_output_node[(j - j_start)].println();
        
      _interval += 1; 
      if ((_interval % sum_interval) == 0) {
        for (int k = 0; k < (1 + CLIMATE_WY2_end - CLIMATE_WY2_start); k += 1) {
          for (int j_ADD = 0; j_ADD < num_add_days; j_ADD += 1) {
            _valuesSUM[(k * num_add_days + j_ADD)] += _valuesA[(k * num_add_days + j_ADD)];
            _valuesNUM[(k * num_add_days + j_ADD)] += 1;
            
            if ((_valuesSUM[(k * num_add_days + j_ADD)] < 0.9 * FLOAT_undefined) && (_valuesNUM[(k * num_add_days + j_ADD)] != 0)) {
              _valuesSUM[(k * num_add_days + j_ADD)] /= _valuesNUM[(k * num_add_days + j_ADD)];
            }
          }
        }        
        if (draw_probs == 1) {
          SOLARCHVISION_draw_probabilities(i, j, ((start_z - 1) * num_add_days + 1), ((end_z - 1) * num_add_days + num_add_days), _valuesSUM, _valuesNUM, x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot);
        }
        for (int k = 0; k < (1 + CLIMATE_WY2_end - CLIMATE_WY2_start); k += 1) {
          for (int j_ADD = 0; j_ADD < num_add_days; j_ADD += 1) {
            _valuesSUM[(k * num_add_days + j_ADD)] = 0;
            _valuesNUM[(k * num_add_days + j_ADD)] = 0;
          }
        }    
      }      
      
      if (draw_sorted == 1) {
        SOLARCHVISION_draw_sorted(i, j, _valuesA, _valuesB, x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot);
      }

      if (draw_normals == 1) {
        SOLARCHVISION_draw_normals(i, j, _valuesA, _valuesB, x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot);
      }
    
    }
    
    if ((save_info_node == 1) && (draw_data_lines == 1)) {
      File_output_node[(j - j_start)].println("Source: " + THE_STATION + ".wy2" + ", Environment Canada: ftp://ftp.tor.ec.gc.ca/Pub/Normals/");
      File_output_node[(j - j_start)].println("Calculated and processed by SOLARCHVISION 2014: www.solarchvision.com");
      File_output_node[(j - j_start)].flush(); 
      File_output_node[(j - j_start)].close(); 
    }
    
    if ((save_info_norm == 1) && (draw_normals == 1)) {
      File_output_norm[(j - j_start)].println("Source: " + THE_STATION + ".wy2" + ", Environment Canada: ftp://ftp.tor.ec.gc.ca/Pub/Normals/");
      File_output_norm[(j - j_start)].println("Calculated and processed by SOLARCHVISION 2014: www.solarchvision.com");
      File_output_norm[(j - j_start)].println("* : SOLARCHVISION internal algorithm");
      File_output_norm[(j - j_start)].flush(); 
      File_output_norm[(j - j_start)].close(); 
    }

    if ((save_info_prob == 1) && (draw_probs == 1)) {
      File_output_prob[(j - j_start)].println("Source: " + THE_STATION + ".wy2" + ", Environment Canada: ftp://ftp.tor.ec.gc.ca/Pub/Normals/");
      File_output_prob[(j - j_start)].println("Calculated and processed by SOLARCHVISION 2014: www.solarchvision.com");
      File_output_prob[(j - j_start)].flush(); 
      File_output_prob[(j - j_start)].close(); 
    }

  }
  
  if (draw_data_lines == 1) {
    SOLARCHVISION_draw_data_lines(Ax_LINES, Ay_LINES, Az_LINES, Bx_LINES, By_LINES, Bz_LINES);
  }       
  
  Diagrams_popMatrix();
} 


int SOLARCHVISION_try_update_CLIMATE_EPW () {
  int File_Found = 0;
  
  CLIMATE_EPW = new float[24][365][num_layers][(1 + CLIMATE_EPW_end - CLIMATE_EPW_start)];
 
  for (int i = 0; i < 24; i += 1) {
    for (int j = 0; j < 365; j += 1) {
      for (int l = 0; l < num_layers; l += 1) {
        for (int k = 0; k <(1 + CLIMATE_EPW_end - CLIMATE_EPW_start); k += 1) {
          CLIMATE_EPW[i][j][l][k] = FLOAT_undefined;
        }
      }
    }
  }

  if (Load_CLIMATE_EPW == 1) {
    
    String FN = THE_STATION;
  
    for (int i = 0; i < CLIMATE_EPW_Files.length; i++) {
      
      int _L = CLIMATE_EPW_Files[i].length();
      String _Extention = CLIMATE_EPW_Files[i].substring(_L - 4, _L);
      //println(_Extention);
      if (_Extention.toLowerCase().equals(".epw")) {
        _Filenames = CLIMATE_EPW_Files[i].substring(0, _L - 4);
        
        if (_Filenames.equals(FN)) {
          File_Found = 1;
          SOLARCHVISION_LoadCLIMATE_EPW((CLIMATE_EPW_directory + "/" + CLIMATE_EPW_Files[i]));
        }
      }
    }
    
    if (File_Found == 0) println("FILE NOT FOUND:", FN);
  }
  
  return File_Found;
}

void SOLARCHVISION_LoadCLIMATE_EPW (String FileName) {
  String[] FileALL = loadStrings(FileName);

  String lineSTR;
  String[] input;
  
    
  //println("lines = ", FileALL.length);

  for (int f = 8; f < FileALL.length; f += 1) {
    
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
    
    CLIMATE_EPW[i][j][_pressure][k] = float(parts[9]) * 0.01; // 10 times in Pa
    CLIMATE_EPW[i][j][_drybulb][k] = float(parts[6]); // in °C
    CLIMATE_EPW[i][j][_relhum][k] = float(parts[8]); // 0 - 110%
    CLIMATE_EPW[i][j][_glohorrad][k] = float(parts[13]); // Wh/m²
    CLIMATE_EPW[i][j][_dirnorrad][k] = float(parts[14]); // Wh/m²
    CLIMATE_EPW[i][j][_difhorrad][k] = float(parts[15]); // Wh/m²
    CLIMATE_EPW[i][j][_windspd][k] = float(parts[21]); // in m/s
    CLIMATE_EPW[i][j][_winddir][k] = float(parts[20]); // ° 
    CLIMATE_EPW[i][j][_opaquesky][k] = float(parts[23]); // 0.1 times in % ... there is also total_sky_cover on[22]
    CLIMATE_EPW[i][j][_ceilingsky][k] = float(parts[25]); // in m
    
    
    if (CLIMATE_EPW[i][j][_pressure][k] == 999999) CLIMATE_EPW[i][j][_pressure][k] = FLOAT_undefined;
    
    if (CLIMATE_EPW[i][j][_drybulb][k] == 99.9) CLIMATE_EPW[i][j][_drybulb][k] = FLOAT_undefined;
    
    if (CLIMATE_EPW[i][j][_relhum][k] == 999) CLIMATE_EPW[i][j][_relhum][k] = FLOAT_undefined;
    
    if (CLIMATE_EPW[i][j][_glohorrad][k] == 9999) CLIMATE_EPW[i][j][_glohorrad][k] = FLOAT_undefined;
    
    if (CLIMATE_EPW[i][j][_dirnorrad][k] >= 9999) CLIMATE_EPW[i][j][_dirnorrad][k] = FLOAT_undefined;
    if (CLIMATE_EPW[i][j][_dirnorrad][k] < 0) CLIMATE_EPW[i][j][_dirnorrad][k] = FLOAT_undefined;
    
    if (CLIMATE_EPW[i][j][_difhorrad][k] >= 9999) CLIMATE_EPW[i][j][_difhorrad][k] = FLOAT_undefined;
    if (CLIMATE_EPW[i][j][_difhorrad][k] < 0) CLIMATE_EPW[i][j][_difhorrad][k] = FLOAT_undefined;
    
    if (CLIMATE_EPW[i][j][_windspd][k] == 999) CLIMATE_EPW[i][j][_windspd][k] = FLOAT_undefined;
    else CLIMATE_EPW[i][j][_windspd][k] = 3.6 * CLIMATE_EPW[i][j][_windspd][k];
    
    if (CLIMATE_EPW[i][j][_winddir][k] == 999) CLIMATE_EPW[i][j][_winddir][k] = FLOAT_undefined;
    
    if (CLIMATE_EPW[i][j][_opaquesky][k] == 99) CLIMATE_EPW[i][j][_opaquesky][k] = FLOAT_undefined;
    
    if (CLIMATE_EPW[i][j][_ceilingsky][k] == 77777) CLIMATE_EPW[i][j][_ceilingsky][k] = 1000;
    if (CLIMATE_EPW[i][j][_ceilingsky][k] == 88888) CLIMATE_EPW[i][j][_ceilingsky][k] = 1000;
    if (CLIMATE_EPW[i][j][_ceilingsky][k] >= 1000) CLIMATE_EPW[i][j][_ceilingsky][k] = 1000; 
    
    if (CLIMATE_EPW[i][j][_ceilingsky][k] == 99999) CLIMATE_EPW[i][j][_ceilingsky][k] = FLOAT_undefined;

  }

  float Pa, Pb, Pc;
  float T, R_dir, R_dif;
  for (int i = 0; i < 24; i += 1) {
    for (int j = 0; j < 365; j += 1) {
      for (int k = 0; k <(1 + CLIMATE_EPW_end - CLIMATE_EPW_start); k += 1) {
        Pa = CLIMATE_EPW[i][j][_drybulb][k];
        Pb = CLIMATE_EPW[i][j][_dirnorrad][k];
        Pc = CLIMATE_EPW[i][j][_difhorrad][k];
                  
        if ((Pa > 0.9 * FLOAT_undefined) ||(Pb > 0.9 * FLOAT_undefined) ||(Pc > 0.9 * FLOAT_undefined)) {
        }
        else {
          T = Pa;
          R_dir = Pb;
          R_dif = Pc;
          CLIMATE_EPW[i][j][_direffect][k] = (18 - T) * R_dir;
          CLIMATE_EPW[i][j][_difeffect][k] = (18 - T) * R_dif;
        }
        
        Pa = CLIMATE_EPW[i][j][_ceilingsky][k];
        if (Pa > 0.9 * FLOAT_undefined) {
        }
        else {
          float Px = log(Pa) / log(10.0);
          if (Px > 2) CLIMATE_EPW[i][j][_logceilsky][k] = roundTo(Px, 0.1);
          else CLIMATE_EPW[i][j][_logceilsky][k] = 2;
        }
      }
    }
  }
}

void SOLARCHVISION_PlotCLIMATE_EPW (float x_Plot, float y_Plot, float z_Plot, float sx_Plot, float sy_Plot, float sz_Plot) {
  
  Diagrams_pushMatrix();
  Diagrams_translate(x_Plot, y_Plot);
  
  SOLARCHVISION_draw_Grid_Cartesian_TIME(x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot);
  
  _pix = (100.0 * GRAPHS_S_View / level_pix);

  int start_z = get_startZ_endZ(databaseNumber_CLIMATE_EPW)[0];
  int end_z = get_startZ_endZ(databaseNumber_CLIMATE_EPW)[1]; 
  
  if (GRAPHS_print_title != 0) {
    
      Diagrams_stroke(0); 
      Diagrams_fill(0);
      Diagrams_strokeWeight(GRAPHS_T_scale * 0);
    
      Diagrams_textSize(sx_Plot * 0.150 / GRAPHS_U_scale);
      Diagrams_textAlign(RIGHT, CENTER);
      my_text(("[Typical Year] "), 0, (0.3 + V_belowLine[drw_Layer]) * sx_Plot / GRAPHS_U_scale, 0);
  
      Diagrams_textSize(sx_Plot * 0.150 / GRAPHS_U_scale);
      Diagrams_textAlign(LEFT, CENTER); 
      my_text((_LAYERS[drw_Layer][(_LAN + 1)]), 0, (0.3 + V_belowLine[drw_Layer]) * sx_Plot / GRAPHS_U_scale, 0);
    
  }    

  float Pa = FLOAT_undefined;
  float Pb = FLOAT_undefined;

  float[] _valuesA;
  float[] _valuesB; 
  _valuesA = new float[((1 + CLIMATE_EPW_end - CLIMATE_EPW_start) * num_add_days)];
  _valuesB = new float[((1 + CLIMATE_EPW_end - CLIMATE_EPW_start) * num_add_days)];

  float[] _valuesSUM; 
  float[] _valuesNUM;
  int _interval = 0;
  _valuesSUM = new float[((1 + CLIMATE_EPW_end - CLIMATE_EPW_start) * num_add_days)];
  _valuesNUM = new float[((1 + CLIMATE_EPW_end - CLIMATE_EPW_start) * num_add_days)];
  
  float[] Ax_LINES = {0};
  float[] Ay_LINES = {0};
  float[] Az_LINES = {0};
  float[] Bx_LINES = {0};
  float[] By_LINES = {0};
  float[] Bz_LINES = {0};

  File_output_node = new PrintWriter [(j_end - j_start)];
  File_output_norm = new PrintWriter [(j_end - j_start)];
  File_output_prob = new PrintWriter [(j_end - j_start)];
  
  String Main_name = MAKE_mainname();
  
  for (int j = j_start; j < j_end; j += 1) {

    Diagrams_stroke(0);
    Diagrams_fill(0);
    Diagrams_textAlign(CENTER, CENTER); 

    if ((GRAPHS_U_scale >= 0.75) || (((j - j_start) % int(1.5 / GRAPHS_U_scale)) == 0)) {
      Diagrams_textSize(sx_Plot * 0.15 / GRAPHS_U_scale);
      
      my_text(CalendarDay[int((365 + j * per_day + 286 + BEGIN_DAY) % 365)][_LAN], (j - ((0 - 12) / 24.0)) * sx_Plot, -1.25 * sx_Plot / GRAPHS_U_scale, 0);
      if (num_add_days > 1) {
        //my_text(("±" + int(num_add_days / 2) + _WORDS[2][_LAN] + "s"), (0 + j - ((0 - 12) / 24.0)) * sx_Plot, -1 * sx_Plot, 0);
      }
    }    
    
    String _FilenamesAdd = "";
    if (num_add_days > 1) {
        _FilenamesAdd = ("±" + int(num_add_days / 2) + _WORDS[2][_LAN] + "s");
    }
    if ((save_info_node == 1) && (draw_data_lines == 1)) {
      File_output_node[(j - j_start)] = createWriter("/" + Main_name + "/Climate_node_" + LocationName + "_" + _LAYERS[drw_Layer][(_EN + 1)] + "_" + sky_scenario_file[sky_scenario] + "_" + CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + ".txt");
      File_output_node[(j - j_start)].println(CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + "\t" + sky_scenario_file[sky_scenario] + "\t" + _LAYERS[drw_Layer][(_EN + 1)] + "(" + _LAYERS[drw_Layer][0] + ")" + "\tfrom:" + String.valueOf(start_z) + "\tto:" + String.valueOf(end_z) + "\t" + LocationName + "\tHourly data(CWEED)");

      File_output_node[(j - j_start)].print("Hour:\t");
      for (int l = start_z; l < (1 + end_z); l += 1) {
        File_output_node[(j - j_start)].print(nf(l, 4) + "        \t");
      }
      File_output_node[(j - j_start)].println("");
    }
    if ((save_info_norm == 1) && (draw_normals == 1)) {
      File_output_norm[(j - j_start)] = createWriter("/" + Main_name + "Climate_norm_" + LocationName + "_" + _LAYERS[drw_Layer][(_EN + 1)] + "_" + sky_scenario_file[sky_scenario] + "_" + CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + ".txt");
      File_output_norm[(j - j_start)].println(CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + "\t" + sky_scenario_file[sky_scenario] + "\t" + _LAYERS[drw_Layer][(_EN + 1)] + "(" + _LAYERS[drw_Layer][0] + ")" + "\tfrom:" + String.valueOf(start_z) + "\tto:" + String.valueOf(end_z) + "\t" + LocationName + "\tHourly normal(CWEED)");
      File_output_norm[(j - j_start)].print("Hour:\t");
      for (int l = 0; l < 9; l += 1) {
        File_output_norm[(j - j_start)].print(N_Title[l] + "\t"); 
      }
      File_output_norm[(j - j_start)].println("");
    }
    if ((save_info_prob == 1) && (draw_probs == 1)) {
      File_output_prob[(j - j_start)] = createWriter("/" + Main_name + "Climate_prob_" + LocationName + "_" + _LAYERS[drw_Layer][(_EN + 1)] + "_" + sky_scenario_file[sky_scenario] + "_" + CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + ".txt");
      File_output_prob[(j - j_start)].println(CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + "\t" + sky_scenario_file[sky_scenario] + "\t" + _LAYERS[drw_Layer][(_EN + 1)] + "(" + _LAYERS[drw_Layer][0] + ")" + "\tfrom:" + String.valueOf(start_z) + "\tto:" + String.valueOf(end_z) + "\t" + LocationName + "\tHourly probabilities(CWEED)");

      File_output_prob[(j - j_start)].print("Hour:\t");
      File_output_prob[(j - j_start)].println("");
    }

    for (int i = 0; i < 24; i += 1) {
      if ((save_info_node == 1) && (draw_data_lines == 1)) File_output_node[(j - j_start)].print(nf(i, 2) + "\t");
      if ((save_info_norm == 1) && (draw_normals == 1)) File_output_norm[(j - j_start)].print(nf(i, 2) + "\t");
      if ((save_info_prob == 1) && (draw_probs == 1)) File_output_prob[(j - j_start)].print(nf(i, 2) + "\t");

      for (int k = 0; k < (1 + CLIMATE_EPW_end - CLIMATE_EPW_start); k += 1) {
        for (int j_ADD = 0; j_ADD < num_add_days; j_ADD += 1) {
          
          _valuesA[(k * num_add_days + j_ADD)] = FLOAT_undefined;
          _valuesB[(k * num_add_days + j_ADD)] = FLOAT_undefined;
       
          SET_COLOR_STYLE(COLOR_STYLE, (1.0 * k / (1 + CLIMATE_EPW_end - CLIMATE_EPW_start)));

          int _plot = 0;

          //if ((start_z <= k + 1) && (end_z >= k + 1)) {
            _plot = 1;
          //}
          
          if (_plot == 1) {
            
            int now_k = k;
            int now_i = i;
            int now_j = int(j * per_day + (j_ADD - int(0.5 * num_add_days)) + BEGIN_DAY + 365) % 365;
            
            
            if (now_j >= 365) {
             now_j = now_j % 365; 
            }
            if (now_j < 0) {
             now_j = (now_j + 365) % 365; 
            }
  
            int next_i = now_i + 1;
            int next_j = now_j;
            int next_k = now_k;
            if (next_i == 24) {
              next_i = 0;
              next_j += 1;
              if (next_j == 365) {
                next_j = 0;
                next_k += 1; 
              }
            }

            Pa = CLIMATE_EPW[now_i][now_j][drw_Layer][now_k]; 
            if (Pa > 0.9 * FLOAT_undefined) {
              _valuesA[(k * num_add_days + j_ADD)] = FLOAT_undefined;
              
              if ((save_info_node == 1) && (draw_data_lines == 1)) File_output_node[(j - j_start)].print("[undefined]\t");
            }
            else {
              int drw_count = SOLARCHVISION_filter("CLIMATE_EPW", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);

              if (drw_count == 1) {
                _valuesA[(k * num_add_days + j_ADD)] = Pa;
                _valuesA[(k * num_add_days + j_ADD)] += V_offset[drw_Layer];
                
                _valuesSUM[(k * num_add_days + j_ADD)] += _valuesA[(k * num_add_days + j_ADD)];
                _valuesNUM[(k * num_add_days + j_ADD)] += 1;

                if ((save_info_node == 1) && (draw_data_lines == 1)) {
                  if (_valuesA[(k * num_add_days + j_ADD)] < 0.9 * FLOAT_undefined) File_output_node[(j - j_start)].print(nfs(_valuesA[(k * num_add_days + j_ADD)] - V_offset[drw_Layer], 5, 5) + "\t"); 
                  else File_output_node[(j - j_start)].print("[undefined]\t");
                }

                if (next_k < (1 + CLIMATE_EPW_end - CLIMATE_EPW_start)) {
                  Pb = CLIMATE_EPW[next_i][next_j][drw_Layer][next_k];
                  if (Pb > 0.9 * FLOAT_undefined) {
                    _valuesB[(k * num_add_days + j_ADD)] = FLOAT_undefined;
                  }
                  else {
                    _valuesB[(k * num_add_days + j_ADD)] = Pb;
                    _valuesB[(k * num_add_days + j_ADD)] += V_offset[drw_Layer];
                    
                    if (draw_data_lines == 1) {
                      if ((drw_Layer == _winddir) && (abs(_valuesB[(k * num_add_days + j_ADD)] - _valuesA[(k * num_add_days + j_ADD)]) > 180)) {
                      }
                      else {                        
                        Ax_LINES = append(Ax_LINES, (j + ((i + 0.5) / 24.0)) * sx_Plot);
                        Ay_LINES = append(Ay_LINES, _valuesA[(k * num_add_days + j_ADD)] * sy_Plot);
                        Az_LINES = append(Az_LINES, now_k * sz_Plot * GRAPHS_W_scale);
                        Bx_LINES = append(Bx_LINES, (j + ((i + 1.5) / 24.0)) * sx_Plot);
                        By_LINES = append(By_LINES, _valuesB[(k * num_add_days + j_ADD)] * sy_Plot);
                        Bz_LINES = append(Bz_LINES, next_k * sz_Plot * GRAPHS_W_scale);
                      } 
                    }
                  }
                }
              }
              else {
                if ((save_info_node == 1) && (draw_data_lines == 1)) File_output_node[(j - j_start)].print("not_the_case\t");
              }
            }
          }
        }
      }
      
      if ((save_info_node == 1) && (draw_data_lines == 1)) File_output_node[(j - j_start)].println();
        
      _interval += 1; 
      if ((_interval % sum_interval) == 0) {
        for (int k = 0; k < (1 + CLIMATE_EPW_end - CLIMATE_EPW_start); k += 1) {
          for (int j_ADD = 0; j_ADD < num_add_days; j_ADD += 1) {
            _valuesSUM[(k * num_add_days + j_ADD)] += _valuesA[(k * num_add_days + j_ADD)];
            _valuesNUM[(k * num_add_days + j_ADD)] += 1;
            
            if ((_valuesSUM[(k * num_add_days + j_ADD)] < 0.9 * FLOAT_undefined) && (_valuesNUM[(k * num_add_days + j_ADD)] != 0)) {
              _valuesSUM[(k * num_add_days + j_ADD)] /= _valuesNUM[(k * num_add_days + j_ADD)];
            }
          }
        }        
        if (draw_probs == 1) {
          SOLARCHVISION_draw_probabilities(i, j, ((start_z - CLIMATE_EPW_start) * num_add_days + 1), ((end_z - CLIMATE_EPW_start) * num_add_days + num_add_days), _valuesSUM, _valuesNUM, x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot);
        }
        for (int k = 0; k < (1 + CLIMATE_EPW_end - CLIMATE_EPW_start); k += 1) {
          for (int j_ADD = 0; j_ADD < num_add_days; j_ADD += 1) {
            _valuesSUM[(k * num_add_days + j_ADD)] = 0;
            _valuesNUM[(k * num_add_days + j_ADD)] = 0;
          }
        }    
      }      
      
      if (draw_sorted == 1) {
        SOLARCHVISION_draw_sorted(i, j, _valuesA, _valuesB, x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot);
      }

      if (draw_normals == 1) {
        SOLARCHVISION_draw_normals(i, j, _valuesA, _valuesB, x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot);
      }
    
    }
    
    if ((save_info_node == 1) && (draw_data_lines == 1)) {
      File_output_node[(j - j_start)].println("Source: " + THE_STATION + ".epw");
      File_output_node[(j - j_start)].println("Calculated and processed by SOLARCHVISION 2014: www.solarchvision.com");
      File_output_node[(j - j_start)].flush(); 
      File_output_node[(j - j_start)].close(); 
    }
    
    if ((save_info_norm == 1) && (draw_normals == 1)) {
      File_output_norm[(j - j_start)].println("Source: " + THE_STATION + ".epw");
      File_output_norm[(j - j_start)].println("Calculated and processed by SOLARCHVISION 2014: www.solarchvision.com");
      File_output_norm[(j - j_start)].println("* : SOLARCHVISION internal algorithm");
      File_output_norm[(j - j_start)].flush(); 
      File_output_norm[(j - j_start)].close(); 
    }

    if ((save_info_prob == 1) && (draw_probs == 1)) {
      File_output_prob[(j - j_start)].println("Source: " + THE_STATION + ".epw");
      File_output_prob[(j - j_start)].println("Calculated and processed by SOLARCHVISION 2014: www.solarchvision.com");
      File_output_prob[(j - j_start)].flush(); 
      File_output_prob[(j - j_start)].close(); 
    }

  }
  
  if (draw_data_lines == 1) {
    SOLARCHVISION_draw_data_lines(Ax_LINES, Ay_LINES, Az_LINES, Bx_LINES, By_LINES, Bz_LINES);
  }       
  
  Diagrams_popMatrix();
} 


int SOLARCHVISION_try_update_observed () {
  int File_Found = 0;
  
  OBSERVED = new float [24][365][num_layers][(1 + OBSERVED_end - OBSERVED_start)];
  OBSERVED_DATA = new int [24][365][num_layers][(1 + OBSERVED_end - OBSERVED_start)]; // -1: undefined, 0: interpolated, 1: data
 
  for (int i = 0; i < 24; i += 1) {
    for (int j = 0; j < 365; j += 1) {
      for (int l = 0; l < num_layers; l += 1) {
        for (int k = 0; k < (1 + OBSERVED_end - OBSERVED_start); k += 1) {
          OBSERVED[i][j][l][k] = FLOAT_undefined;
          OBSERVED_DATA[i][j][l][k] = -1; 
        }
      }
    }
  }

  if (Load_OBSERVED == 1) {

    // this line tries to update the most recent files! << 
    int THE_YEAR = year(); 
    int THE_MONTH = month();
    int THE_DAY = day();
    int THE_HOUR = hour(); 
  
  
    float THE_DATE = _DATE;
  
    int now_i = int(THE_HOUR);
    int now_j = Convert2Date(THE_MONTH, THE_DAY);
  
    now_i += int(-LocationTimeZone / 15);
    if (now_i > 23) {
      now_i -= 24;
      now_j += 1;
      if (now_j > 364) {
        now_j -= 365;
        THE_YEAR += 1;
      }
      THE_DATE += 1;
      if (THE_DATE > 364) THE_DATE -= 365; 
    }         
    THE_HOUR = now_i;
  
    for (int j_for = 0; j_for < max_j_end_observed * 24; j_for += 1) {
      
      THE_MONTH = CalendarDate[int(THE_DATE)][0]; 
      THE_DAY = CalendarDate[int(THE_DATE)][1];
      
      for (int f = 0; f < 1; f++) {
      //for (int f = 0; f < (1 + OBSERVED_end - OBSERVED_start); f++) {
        
        String FN = nf(THE_YEAR, 4) + "-" + nf(THE_MONTH, 2) + "-" + nf(THE_DAY, 2) + "-" + nf(THE_HOUR, 2) + "00-" + OBSERVED_STATIONS[f][0] + "-" + OBSERVED_STATIONS[f][1] + "-swob";
      
        //println (FN);
        for (int i = 0; i < OBSERVED_XML_Files.length; i++) {
          //println(OBSERVED_XML_Files[i]); 
          
          int _L = OBSERVED_XML_Files[i].length();
          String _Extention = OBSERVED_XML_Files[i].substring(_L - 4, _L);
          //println(_Extention);
          if (_Extention.toLowerCase().equals(".xml")) {
            _Filenames = OBSERVED_XML_Files[i].substring(0, _L - 4);
  
            if (_Filenames.equals(FN)) {
              //println ("FILE:", FN);
              File_Found = 1;
              SOLARCHVISION_LoadOBSERVED((OBSERVED_directory + "/" + OBSERVED_XML_Files[i]), f);
            }
    
          }
        }
        if (File_Found == 0) println ("FILE NOT FOUND:", FN);
      }
      
      now_i -= 1;
      if (now_i < 0) {
        now_i += 24;
        now_j -= 1;
        if (now_j < 0) {
          now_j += 365;
          THE_YEAR -= 1;
        }
        THE_DATE -= 1;
        if (THE_DATE < 0) THE_DATE += 364; 
      }
      THE_HOUR = now_i;
    }
    
    
    
    int MAX_SEARCH = 6; // It defines how many hours the program should seek for each point to find next available data.  
    
    for (int l = 0; l < num_layers; l += 1) {
      if (THE_LAYERS[l].equals("")) {
      }
      else {
        for (int k = 0; k < (1 + OBSERVED_end - OBSERVED_start); k += 1) {
          float pre_v = FLOAT_undefined;
          int pre_num = 0;
          
          for (int j_for = 0; j_for <= max_j_end_observed; j_for += 1) { // should be controlled.
          int j = (int(j_for + _DATE - max_j_end_observed + 365 - 286) % 365); // should be controlled.
          
            for (int i = 0; i < 24; i += 1) {
              if (OBSERVED[i][j][l][k] > 0.9 * FLOAT_undefined) {
                if (pre_v < 0.9 * FLOAT_undefined) {
                  pre_num += 1;
                  
                  float next_v = FLOAT_undefined;
                  int next_i = i;
                  int next_j = j;
                  int next_num = 0;
                  while ((next_num < MAX_SEARCH) && (next_v > 0.9 * FLOAT_undefined)) {
                    next_num += 1;
                    next_i += 1;
                    if (next_i == 24) {
                      next_i -= 24;
                      next_j += 1; 
                    }
                    if (next_j == 365) {
                      next_j = 0; 
                    }
                    if (OBSERVED[next_i][next_j][l][k] > 0.9 * FLOAT_undefined) {
                    }
                    else {
                      next_v = OBSERVED[next_i][next_j][l][k];
                      
                      if (l == _winddir) {
                        if ((next_v - pre_v) > 180) next_v -= 360;
                        if ((next_v - pre_v) < -180) next_v += 360;
                      } 
                    }  
                  }
                  if (next_num < MAX_SEARCH) {
                    if (l == _winddir) OBSERVED[i][j][l][k] = ((next_num * pre_v + pre_num * next_v) / (pre_num + next_num) + 360) % 360;
                    else OBSERVED[i][j][l][k] = (next_num * pre_v + pre_num * next_v) / (pre_num + next_num);
                    
                    OBSERVED_DATA[i][j][l][k] = 0;
                  }
                  else {
                    OBSERVED_DATA[i][j][l][k] = -1;
                  }
                }
              }
              else {
                OBSERVED_DATA[i][j][l][k] = 1;
                pre_v = OBSERVED[i][j][l][k];
                pre_num = 0;
              }
            }
          }
        }
      }
    }
  
  }
  

  return File_Found;
}


void SOLARCHVISION_LoadOBSERVED (String FileName, int Load_Layer) {
  String lineSTR;
  String[] input;
  
  XML FileALL = loadXML(FileName);

  XML[] children0 = FileALL.getChildren("om:member");
  XML[] children1 = children0[0].getChildren("om:Observation");
  XML[] children2 = children1[0].getChildren("om:samplingTime");
  XML[] children3 = children2[0].getChildren("gml:TimeInstant");
  XML[] children4 = children3[0].getChildren("gml:timePosition");
  String _TimeInstant = String.valueOf(children4[0].getContent());
  //println(_TimeInstant);
  
  int THE_YEAR = int(_TimeInstant.substring(0, 4));
  int THE_MONTH = int(_TimeInstant.substring(5, 7));
  int THE_DAY = int(_TimeInstant.substring(8, 10));
  int THE_HOUR = int(_TimeInstant.substring(11, 13));
  
  //println (THE_YEAR, THE_MONTH, THE_DAY, THE_HOUR);

  int now_i = int(THE_HOUR);
  int now_j = Convert2Date(THE_MONTH, THE_DAY);
  
  //println (now_i, now_j);
  
  now_i -= int(-LocationTimeZone / 15);
  
  if (now_i < 0) {
    now_i += 24;
    now_j -= 1;
    if (now_j < 0) {
      now_j += 365;
    } 
  }
  
  //println (now_i, now_j);
  //println ("-------------");
  
  children2 = children1[0].getChildren("om:result");
  children3 = children2[0].getChildren("elements");
  children4 = children3[0].getChildren("element");
  
  for (int Li = 0; Li < children4.length; Li++) {
    
    String _a1 = children4[Li].getString("name");
    String _a2 = children4[Li].getString("value");
    String _a3 = children4[Li].getString("uom");

    //println("Li=", Li, _a1, _a2, _a3);
    
    if (_a2.toUpperCase().equals("MSNG")) { // missing values
      _a2 = String.valueOf(FLOAT_undefined);
    }
    
    if (_a1.equals("stn_pres")) {
      OBSERVED[now_i][now_j][_pressure][Load_Layer] = Float.valueOf(_a2);
      OBSERVED_DATA[now_i][now_j][_pressure][Load_Layer] = 1;
    }
    
    if (_a1.equals("air_temp")) {
      OBSERVED[now_i][now_j][_drybulb][Load_Layer] = Float.valueOf(_a2);
      OBSERVED_DATA[now_i][now_j][_drybulb][Load_Layer] = 1;
    }
    
    if (_a1.equals("rel_hum")) {
      OBSERVED[now_i][now_j][_relhum][Load_Layer] = Float.valueOf(_a2);
      OBSERVED_DATA[now_i][now_j][_relhum][Load_Layer] = 1;
    } 
    
    if (_a1.equals("tot_cld_amt")) {
      OBSERVED[now_i][now_j][_cloudcover][Load_Layer] = Float.valueOf(_a2);
      OBSERVED_DATA[now_i][now_j][_cloudcover][Load_Layer] = 1;
    }    
    
    if (_a1.equals("avg_wnd_dir_10m_mt50-60")) {
      OBSERVED[now_i][now_j][_winddir][Load_Layer] = Float.valueOf(_a2);
      OBSERVED_DATA[now_i][now_j][_winddir][Load_Layer] = 1;
    }    
    
    if (_a1.equals("avg_wnd_spd_10m_mt50-60")) {
      OBSERVED[now_i][now_j][_windspd][Load_Layer] = Float.valueOf(_a2);
      OBSERVED_DATA[now_i][now_j][_windspd][Load_Layer] = 1;
    }
    
    if (_a1.equals("pcpn_amt_pst6hrs")) {
      OBSERVED[now_i][now_j][_precipitation][Load_Layer] = Float.valueOf(_a2); // past 6 hours!
      OBSERVED_DATA[now_i][now_j][_precipitation][Load_Layer] = 1;
    }
    
    if (_a1.equals("avg_globl_solr_radn_pst1hr")) {
      if (_a2.equals(_undefined)) {
      }
      else {
        //if (_a3.equals("W/m²")) {
          OBSERVED[now_i][now_j][_glohorrad][Load_Layer] = 1000 * Float.valueOf(_a2) / 3.6; // we should check the units!
          OBSERVED_DATA[now_i][now_j][_glohorrad][Load_Layer] = 1;
        //}
      }
    }
    
    if (_a1.equals("tot_globl_solr_radn_pst1hr")) {
      if (_a2.equals(_undefined)) {
      }
      else {
        //if (_a3.equals("kJ/m²")) {
          OBSERVED[now_i][now_j][_glohorrad][Load_Layer] = Float.valueOf(_a2) / 3.6; // we should check the units!
          OBSERVED_DATA[now_i][now_j][_glohorrad][Load_Layer] = 1;
        //}
      }
    }
    

  }  
}


void SOLARCHVISION_PlotOBSERVED (float x_Plot, float y_Plot, float z_Plot, float sx_Plot, float sy_Plot, float sz_Plot) {
  
  _pix = (100.0 * GRAPHS_S_View / level_pix);

  Diagrams_pushMatrix();
  Diagrams_translate(x_Plot, y_Plot);
  
  color_data_lines = color(63, 0, 0, _Opacity(GRAPHS_O_scale)); 
  
  SOLARCHVISION_draw_Grid_Cartesian_TIME(x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot);

  int start_z = get_startZ_endZ(databaseNumber_OBSERVED)[0];
  int end_z = get_startZ_endZ(databaseNumber_OBSERVED)[1]; 
  
  if (GRAPHS_print_title != 0) {
    
    Diagrams_stroke(0); 
    Diagrams_fill(0);
    Diagrams_strokeWeight(GRAPHS_T_scale * 0);
  
    Diagrams_textSize(sx_Plot * 0.150 / GRAPHS_U_scale);
    Diagrams_textAlign(RIGHT, CENTER); 
    //my_text(("[Observations:" + String.valueOf(start_z) + "-" + String.valueOf(end_z) + "] "), 0, (0.3 + V_belowLine[drw_Layer]) * sx_Plot / GRAPHS_U_scale, 0);

    Diagrams_textSize(sx_Plot * 0.150 / GRAPHS_U_scale);
    Diagrams_textAlign(LEFT, CENTER); 
    my_text((_LAYERS[drw_Layer][(_LAN + 1)]), 0, (0.3 + V_belowLine[drw_Layer]) * sx_Plot / GRAPHS_U_scale, 0);
  
  }
  
  float Pa = FLOAT_undefined;
  float Pb = FLOAT_undefined;

  float[] _valuesA;
  float[] _valuesB; 
  _valuesA = new float[(1 + OBSERVED_end - OBSERVED_start)];
  _valuesB = new float[(1 + OBSERVED_end - OBSERVED_start)]; 

  float[] _valuesSUM; 
  float[] _valuesNUM;
  int _interval = 0;
  _valuesSUM = new float[(1 + OBSERVED_end - OBSERVED_start)];
  _valuesNUM = new float[(1 + OBSERVED_end - OBSERVED_start)];
 
  for (int k = 0; k < (1 + OBSERVED_end - OBSERVED_start); k += 1) { 
    _valuesA[k] = FLOAT_undefined;
    _valuesB[k] = FLOAT_undefined;
    _valuesSUM[k] = FLOAT_undefined;
    _valuesNUM[k] = 0;
  }
  
  float[] Ax_LINES = {0};
  float[] Ay_LINES = {0};
  float[] Az_LINES = {0};
  float[] Bx_LINES = {0};
  float[] By_LINES = {0};
  float[] Bz_LINES = {0};

  File_output_node = new PrintWriter [(j_end - j_start)];
  File_output_norm = new PrintWriter [(j_end - j_start)];
  File_output_prob = new PrintWriter [(j_end - j_start)];
  
  String Main_name = MAKE_mainname();

  for (int j = j_start; j < j_end; j += 1) { 
    String _FilenamesAdd = "";
    if (num_add_days > 1) {
        //_FilenamesAdd = ("±" + int(num_add_days / 2) + _WORDS[2][_LAN] + "s");
    }
    if ((save_info_node == 1) && (draw_data_lines == 1)) {
      File_output_node[(j - j_start)] = createWriter("/" + Main_name + "/OBSERVATION_node_" + LocationName + "_from_" + String.valueOf(start_z) + "_to_" + String.valueOf(end_z) + "_" + _LAYERS[drw_Layer][(_EN + 1)] + "_" + sky_scenario_file[sky_scenario] + "_" + CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + ".txt");
      File_output_node[(j - j_start)].println(CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + "\t" + sky_scenario_file[sky_scenario] + "\t" + _LAYERS[drw_Layer][(_EN + 1)] + "(" + _LAYERS[drw_Layer][0] + ")" + "\tfrom:" + String.valueOf(start_z) + "\tto:" + String.valueOf(end_z) + "\t" + LocationName + "\tHourly data(OBSERVATION)");

      File_output_node[(j - j_start)].print("Hour\t");
      for (int l = start_z; l < (1 + end_z); l += 1) {
        File_output_node[(j - j_start)].print(OBSERVED_STATIONS[(l - 1)][2] + "\t"); 
      }
      File_output_node[(j - j_start)].println("");
    }
    if ((save_info_norm == 1) && (draw_normals == 1)) {
      File_output_norm[(j - j_start)] = createWriter("/" + Main_name + "/OBSERVATION_norm_" + LocationName + "_from_" + String.valueOf(start_z) + "_to_" + String.valueOf(end_z) + "_" + _LAYERS[drw_Layer][(_EN + 1)] + "_" + sky_scenario_file[sky_scenario] + "_" + CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + ".txt");
      File_output_norm[(j - j_start)].println(CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + "\t" + sky_scenario_file[sky_scenario] + "\t" + _LAYERS[drw_Layer][(_EN + 1)] + "(" + _LAYERS[drw_Layer][0] + ")" + "\tfrom:" + String.valueOf(start_z) + "\tto:" + String.valueOf(end_z) + "\t" + LocationName + "\tHourly normal(OBSERVATION)");
      File_output_norm[(j - j_start)].print("Hour\t");
      for (int l = 0; l < 9; l += 1) {
        File_output_norm[(j - j_start)].print(N_Title[l] + "\t"); 
      }
      File_output_norm[(j - j_start)].println("");
    }
    if ((save_info_prob == 1) && (draw_probs == 1)) {
      File_output_prob[(j - j_start)] = createWriter("/" + Main_name + "/OBSERVATION_prob_" + LocationName + "_from_" + String.valueOf(start_z) + "_to_" + String.valueOf(end_z) + "_" + _LAYERS[drw_Layer][(_EN + 1)] + "_" + sky_scenario_file[sky_scenario] + "_" + CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + ".txt");
      File_output_prob[(j - j_start)].println(CalendarDay[((365 + j + 286 + BEGIN_DAY) % 365)][_LAN] + _FilenamesAdd + "\t" + sky_scenario_file[sky_scenario] + "\t" + _LAYERS[drw_Layer][(_EN + 1)] + "(" + _LAYERS[drw_Layer][0] + ")" + "\tfrom:" + String.valueOf(start_z) + "\tto:" + String.valueOf(end_z) + "\t" + LocationName + "\tHourly probabilities(OBSERVATION)");

      File_output_prob[(j - j_start)].print("Hour:\t");
      File_output_prob[(j - j_start)].println("");
    }

    for (int i = 0; i < 24; i += 1) {
      if ((save_info_node == 1) && (draw_data_lines == 1)) File_output_node[(j - j_start)].print(nf(i, 2) + "\t");
      if ((save_info_norm == 1) && (draw_normals == 1)) File_output_norm[(j - j_start)].print(nf(i, 2) + "\t");
      if ((save_info_prob == 1) && (draw_probs == 1)) File_output_prob[(j - j_start)].print(nf(i, 2) + "\t");

      for (int k = (start_z - 1); k <= (end_z - 1); k += 1) {

        _valuesA[k] = FLOAT_undefined;
        _valuesB[k] = FLOAT_undefined;
        
        if ((k + 1) == 22) {
          Diagrams_stroke(127, 0, 255, 127); 
          Diagrams_fill(127, 0, 255);
          Diagrams_strokeWeight(GRAPHS_T_scale * 6);
        }
        else {
          SET_COLOR_STYLE(COLOR_STYLE, (1.0 * k / (1 + OBSERVED_end - OBSERVED_start)));
          Diagrams_strokeWeight(GRAPHS_T_scale * 1);
        }
        
        int _plot = 1;
        
        if (_plot == 1) {
          
          int now_k = k;
          int now_i = i;
          int now_j = (j + BEGIN_DAY + 365) % 365;

          if (now_j >= 365) {
           now_j = now_j % 365; 
          }
          if (now_j < 0) {
           now_j = (now_j + 365) % 365; 
          }

          int next_i = now_i + dT;
          int next_j = now_j;
          int next_k = now_k;
          if (next_i >= 24) {
            next_i = 0; //i % 24;
            next_j += 1; //int((i / 24);
            if (next_j >= 365) {
              next_j = next_j % 365;
              //next_k += 1; 
            }
          }

          Pa = OBSERVED[now_i][now_j][drw_Layer][now_k]; 
          if (Pa > 0.9 * FLOAT_undefined) {
            _valuesA[k] = FLOAT_undefined;

            if ((save_info_node == 1) && (draw_data_lines == 1)) File_output_node[(j - j_start)].print("[undefined]\t"); 
          }
          else {
            int drw_count = 1; //SOLARCHVISION_filter("OBSERVED", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
            
            if (drw_count == 1) {

              _valuesA[k] = Pa;
              _valuesA[k] += V_offset[drw_Layer];
              
              _valuesSUM[k] += _valuesA[k];
              _valuesNUM[k] += 1;

              //if ((OBSERVED_DATA[now_i][now_j][drw_Layer][now_k] == 1) && ((draw_data_lines == 1))) Diagrams_ellipse((j + ((i + 0.5) / 24.0)) * sx_Plot, _valuesA[k] * sy_Plot, 5, 5);

                if ((save_info_node == 1) && (draw_data_lines == 1)) {
                  if (_valuesA[k] < 0.9 * FLOAT_undefined) File_output_node[(j - j_start)].print(nfs(_valuesA[k] - V_offset[drw_Layer], 5, 5) + "\t"); 
                  else File_output_node[(j - j_start)].print("[undefined]\t");
                }
                            
              if (next_k < (1 + OBSERVED_end - OBSERVED_start)) {
                
                Pb = OBSERVED[next_i][next_j][drw_Layer][next_k];
                if (Pb > 0.9 * FLOAT_undefined) {
                  _valuesB[k] = FLOAT_undefined;
                }
                else {
                  _valuesB[k] = Pb;
                  _valuesB[k] += V_offset[drw_Layer];
                  
                  if (draw_data_lines == 1) {
                    if ((drw_Layer == _winddir) && (abs(_valuesB[k] - _valuesA[k]) > 180)) {
                      
                    }
                    else {
                      Ax_LINES = append(Ax_LINES, (j + ((i + 0.5) / 24.0)) * sx_Plot);
                      Ay_LINES = append(Ay_LINES, _valuesA[k] * sy_Plot);
                      Az_LINES = append(Az_LINES, now_k * sz_Plot * GRAPHS_W_scale);
                      Bx_LINES = append(Bx_LINES, (j + ((i + 0.5 + dT) / 24.0)) * sx_Plot);
                      By_LINES = append(By_LINES, _valuesB[k] * sy_Plot);
                      Bz_LINES = append(Bz_LINES, next_k * sz_Plot * GRAPHS_W_scale);
                    } 
                  }
                }
              }
            }
            else {
              if ((save_info_node == 1) && (draw_data_lines == 1)) File_output_node[(j - j_start)].print("not_the_case\t");
            }
          }          
        }
      }
 
      if ((save_info_node == 1) && (draw_data_lines == 1)) File_output_node[(j - j_start)].println();
  
      _interval += 1; 
      if ((_interval % sum_interval) == 0) {
        for (int k = (start_z - 1); k <= (end_z - 1); k += 1) {
          _valuesSUM[k] += _valuesA[k];
          _valuesNUM[k] += 1;
          
          if ((_valuesSUM[k] < 0.9 * FLOAT_undefined) && (_valuesNUM[k] != 0)) {
            _valuesSUM[k] /= _valuesNUM[k];
          }
        }    
        if (draw_probs == 1) {
          //SOLARCHVISION_draw_probabilities(i, j, start_z, end_z, _valuesSUM, _valuesNUM, x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot);
        }  

        for (int k = 0; k < (1 + OBSERVED_end - OBSERVED_start); k += 1) {
          _valuesSUM[k] = 0;
          _valuesNUM[k] = 0;
        }
        
      }        

      if (draw_sorted == 1) {
        SOLARCHVISION_draw_sorted(i, j, _valuesA, _valuesB, x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot);
      }

      if (draw_normals == 1) {
        SOLARCHVISION_draw_normals(i, j, _valuesA, _valuesB, x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot);
      }
    }

    if ((save_info_node == 1) && (draw_data_lines == 1)) {
      File_output_node[(j - j_start)].println("Source: Environment Canada website at http://dd.weatheroffice.ec.gc.ca/observations/swob-ml/");
      File_output_node[(j - j_start)].println("The data might be interpolated and processed by SOLARCHVISION 2014: www.solarchvision.com");
      File_output_node[(j - j_start)].flush(); 
      File_output_node[(j - j_start)].close(); 
    }
    
    if ((save_info_norm == 1) && (draw_normals == 1)) {
      File_output_norm[(j - j_start)].println("Source: Environment Canada website at http://dd.weatheroffice.ec.gc.ca/observations/swob-ml/");
      File_output_norm[(j - j_start)].println("Calculated and processed by SOLARCHVISION 2014: www.solarchvision.com");
      File_output_norm[(j - j_start)].println("* : SOLARCHVISION internal algorithm");
      File_output_norm[(j - j_start)].flush(); 
      File_output_norm[(j - j_start)].close(); 
    }

    if ((save_info_prob == 1) && (draw_probs == 1)) {
      File_output_prob[(j - j_start)].println("Source: Environment Canada website at http://dd.weatheroffice.ec.gc.ca/observations/swob-ml/");
      File_output_prob[(j - j_start)].println("Calculated and processed by SOLARCHVISION 2014: www.solarchvision.com");
      File_output_prob[(j - j_start)].flush(); 
      File_output_prob[(j - j_start)].close(); 
    }

  }

  if (draw_data_lines == 1) {
    SOLARCHVISION_draw_data_lines(Ax_LINES, Ay_LINES, Az_LINES, Bx_LINES, By_LINES, Bz_LINES);
  }    

  Diagrams_popMatrix();
} 



void SOLARCHVISION_draw_Grid_Cartesian_TIME (float x_Plot, float y_Plot, float z_Plot, float sx_Plot, float sy_Plot, float sz_Plot) {
  Diagrams_strokeWeight(GRAPHS_T_scale * 1);
  
  float Shift_DOWN = 0;
  if (V_belowLine[drw_Layer] != 0) Shift_DOWN = -100;
  
  for (int i = 100; i >= Shift_DOWN; i -= 25) {
    if (-V_offset[drw_Layer] + roundTo(i / GRAPHS_V_scale[drw_Layer], 0.1) != 0) {
      Diagrams_stroke(0, 63);
      Diagrams_fill(0, 63);
    }
    else {
      Diagrams_stroke(0);
      Diagrams_fill(0);
    }
    my_line(j_start * sx_Plot, -i * GRAPHS_S_View, 0, j_end * sx_Plot, -i * GRAPHS_S_View, 0); 
    
    if ((i >= 0) || (V_belowLine[drw_Layer] != 0)) {  
      Diagrams_stroke(0);
      Diagrams_fill(0);
      Diagrams_textSize(sx_Plot * 0.125 / GRAPHS_U_scale);
      Diagrams_textAlign(RIGHT, CENTER);
      my_text(((String.valueOf(nf(-V_offset[drw_Layer] + roundTo(i / GRAPHS_V_scale[drw_Layer], 0.1), 0, 1))) + _LAYERS[drw_Layer][0]), -5, -i * GRAPHS_S_View, 0);
      //my_text(((String.valueOf(int(-V_offset[drw_Layer] + roundTo(i / GRAPHS_V_scale[drw_Layer], 0.1)))) + _LAYERS[drw_Layer][0]), -5, -i * GRAPHS_S_View, 0);
    }
  }
  
  Diagrams_stroke(0, 63);
  Diagrams_fill(0, 63); 
  for (int i = j_start; i <= j_end; i += 1) {
    if (i < j_end) {
      int j_step = 3;
      for (int j = j_step; j <= 24; j += j_step) {
        if (j != 24) {
          my_line((i + j / 24.0) * sx_Plot, -5 * GRAPHS_S_View, 0, (i + j / 24.0) * sx_Plot, 5 * GRAPHS_S_View, 0);
        }
        else {
          my_line((i + j / 24.0) * sx_Plot, -105 * GRAPHS_S_View, 0, (i + j / 24.0) * sx_Plot, (5 - Shift_DOWN) * GRAPHS_S_View, 0);
        }
      }
    }
  }
  
  Diagrams_stroke(0);
  Diagrams_fill(0);
  Diagrams_textAlign(CENTER, CENTER); 

  for (int i = j_start; i < j_end; i += 1) {
    if (GRAPHS_U_scale >= 0.75) {
      Diagrams_textSize(sx_Plot * 0.125 / GRAPHS_U_scale);
      my_text("12:00", (i - ((0 - 12) / 24.0)) * sx_Plot, 0.1 * sx_Plot / GRAPHS_U_scale, 0);
    }
  }

  SOLARCHVISION_print_other_info(sx_Plot, V_belowLine[drw_Layer]);
}  



void SOLARCHVISION_draw_Grid_Spherical_POSITION (float x_Plot, float y_Plot, float z_Plot, float sx_Plot, float sy_Plot, float sz_Plot, int fill_back) {
  Diagrams_strokeWeight(GRAPHS_T_scale * 1);
  
  if (fill_back != 0) {
    for (int i = j_start; i < j_end; i += 1) {
    
      Diagrams_stroke(223);
      Diagrams_fill(223);
      Diagrams_ellipse((i + obj_offset_x) * sx_Plot, 0, 2 * 90 * obj_scale * sx_Plot , 2 * 90 * obj_scale * sx_Plot);
    }
  }

  for (int i = j_start; i < j_end; i += 1) {
    for (int t = 0; t < 360; t += 15) {
      
      if ((t % 45) != 0) {
        Diagrams_stroke(0, 63);
        Diagrams_fill(0, 63);
      }
      else {
        
        Diagrams_stroke(0);
        Diagrams_fill(0);
      }
      int r = 0;
      if ((t % 45) != 0) r = 15;
      
      my_line((i + obj_offset_x + r * obj_scale * (cos_ang(t))) * sx_Plot, -(r * obj_scale * (sin_ang(t))) * sx_Plot, 0, (i + obj_offset_x + 90 * obj_scale * (cos_ang(t))) * sx_Plot, -(90 * obj_scale * (sin_ang(t))) * sx_Plot, 0); 
      
      if (((t + 45) % 90) == 0) {
        Diagrams_stroke(0, 127);
        Diagrams_fill(0, 127);
        Diagrams_textSize(sx_Plot * 0.125 / GRAPHS_U_scale);
        Diagrams_textAlign(CENTER, CENTER);
        
        String ORI = "";
        switch((360 + 90 - t) % 360) {
          case 0 : ORI = "N"; break;
          case 45 : ORI = "NE"; break;
          case 90 : ORI = "E"; break;
          case 135 : ORI = "SE"; break;
          case 180 : ORI = "S"; break;
          case 225 : ORI = "SW"; break;
          case 270 : ORI = "W"; break;
          case 315 : ORI = "NW"; break; 
        }
        
        my_text(ORI, (i + obj_offset_x + 110 * obj_scale * (cos_ang(t))) * sx_Plot, -(110 * obj_scale * (sin_ang(t))) * sx_Plot, 0);
        //my_text(String.valueOf((360 + 90 - t) % 360), (i + obj_offset_x + 110 * obj_scale * (cos_ang(t))) * sx_Plot, -(110 * obj_scale * (sin_ang(t))) * sx_Plot, 0);
      }
    }
    
    float impact_scale = 1;
    if ((plot_impacts == -2) || (plot_impacts == -1)) impact_scale = GRAPHS_V_scale[_windspd] * 45 / 50.0;
    
    for (int r = 90; r > 0; r -= 15) {
      if ((r % 90) != 0) {
        Diagrams_stroke(0, 63);
        Diagrams_noFill();
      }
      else {
        Diagrams_stroke(0);
        Diagrams_noFill(); 
      }
      
      Diagrams_ellipse((i + obj_offset_x) * sx_Plot, 0, 2 * r * obj_scale * sx_Plot , 2 * r * obj_scale * sx_Plot);
      
      int t = 90;
      if (t == 90) {
        Diagrams_stroke(0, 127);
        Diagrams_fill(0, 127);
        Diagrams_textSize(sx_Plot * 0.125 / GRAPHS_U_scale);
        Diagrams_textAlign(CENTER, CENTER);
        my_text(nf(int(r / impact_scale), 1), (i + obj_offset_x + r * obj_scale * (cos_ang(t))) * sx_Plot, -(r * obj_scale * (sin_ang(t))) * sx_Plot, 0);
      }      
    }
  }
 
}  


void SOLARCHVISION_draw_Grid_DAILY (float x_Plot, float y_Plot, float z_Plot, float sx_Plot, float sy_Plot, float sz_Plot) {
  
  Diagrams_stroke(0);
  Diagrams_fill(0);
  Diagrams_textAlign(CENTER, CENTER); 

  for (int i = j_start; i < j_end; i += 1) {
    if ((GRAPHS_U_scale >= 0.75) || (((i - j_start) % int(1.5 / GRAPHS_U_scale)) == 0)) {
      Diagrams_textSize(sx_Plot * 0.15 / GRAPHS_U_scale);
      
      my_text(CalendarDay[int((365 + i * per_day + 286 + BEGIN_DAY) % 365)][_LAN], (i - ((0 - 12) / 24.0)) * sx_Plot, -1.25 * sx_Plot / GRAPHS_U_scale, 0);
      if (num_add_days > 1) {
        my_text(("±" + int(num_add_days / 2) + _WORDS[2][_LAN] + "s"), (0 + i - ((0 - 12) / 24.0)) * sx_Plot, -1 * sx_Plot, 0);
      }
    }
  }
  
  SOLARCHVISION_print_other_info(sx_Plot, 1);
  
}


void SOLARCHVISION_print_other_info (float sx_Plot, float the_V_belowLine) {
  Diagrams_stroke(0);
  Diagrams_fill(0);
  Diagrams_textSize(sx_Plot * 0.150 / GRAPHS_U_scale);
  Diagrams_textAlign(LEFT, CENTER);

  if (impacts_source == databaseNumber_CLIMATE_EPW) my_text((_WORDS[0][_LAN] + ":" + LocationName + "\n"), -1.5 * sx_Plot / GRAPHS_U_scale, (0.3 + the_V_belowLine) * sx_Plot / GRAPHS_U_scale, 0);
  if (impacts_source == databaseNumber_CLIMATE_WY2) my_text((_WORDS[0][_LAN] + ":" + LocationName + "\n("), -1.5 * sx_Plot / GRAPHS_U_scale, (0.3 + the_V_belowLine) * sx_Plot / GRAPHS_U_scale, 0);
  if (impacts_source == databaseNumber_ENSEMBLE)    my_text((_WORDS[0][_LAN] + ":" + LocationName + "\n(" + nf(_YEAR, 4) + "_" + nf(_MONTH, 2) + "_" + nf(_DAY, 2) + "_" + nf(_HOUR, 2) + ")"), -1.5 * sx_Plot / GRAPHS_U_scale, (0.3 + the_V_belowLine) * sx_Plot / GRAPHS_U_scale, 0);
  if (impacts_source == databaseNumber_OBSERVED)    my_text((_WORDS[0][_LAN] + ":" + LocationName + "\n(" + nf(_YEAR, 4) + "_" + nf(_MONTH, 2) + "_" + nf(_DAY, 2) + "_" + nf(_HOUR, 2) + ")"), -1.5 * sx_Plot / GRAPHS_U_scale, (0.3 + the_V_belowLine) * sx_Plot / GRAPHS_U_scale, 0);

  switch(sky_scenario) {
    case 1 : Diagrams_stroke(0, 0, 0); Diagrams_fill(0, 0, 0); break;
    case 2 : Diagrams_stroke(0, 0, 255); Diagrams_fill(0, 0, 255); break;
    case 3 : Diagrams_stroke(0, 127, 0); Diagrams_fill(0, 127, 0); break;
    case 4 : Diagrams_stroke(255, 0, 0); Diagrams_fill(255, 0, 0); break;
  }
  
  Diagrams_textAlign(RIGHT, CENTER);

  my_text(sky_scenario_text[sky_scenario], (j_end - j_start) * sx_Plot, (0.3 + the_V_belowLine) * sx_Plot / GRAPHS_U_scale, 0);
}  



void SOLARCHVISION_draw_data_lines (float[] Ax_LINES, float[] Ay_LINES, float[] Az_LINES, float[] Bx_LINES, float[] By_LINES, float[] Bz_LINES) {
  //Diagrams_stroke(color_data_lines);
  //Diagrams_fill(color_data_lines);
  //Diagrams_strokeWeight(GRAPHS_T_scale * 1);
  
  Diagrams_stroke(0, _Opacity(GRAPHS_O_scale));
  Diagrams_fill(0, _Opacity(GRAPHS_O_scale));
  Diagrams_strokeWeight(GRAPHS_T_scale * 3);
  
  for (int i = 1; i < Ax_LINES.length; i += 1) {
    my_line(Ax_LINES[i], Ay_LINES[i], Az_LINES[i], Bx_LINES[i], By_LINES[i], Bz_LINES[i]); 
  } 
}


void SOLARCHVISION_draw_probabilities (int i, int j, int start_z, int end_z, float[] _valuesSUM, float[] _valuesNUM, float x_Plot, float y_Plot, float z_Plot, float sx_Plot, float sy_Plot, float sz_Plot) {

  float txt_max_width = (sum_interval * GRAPHS_S_View * 100 / 24.0) * GRAPHS_U_scale;
  float txt_max_height = _pix;
  if (txt_max_height > txt_max_width) Diagrams_textSize(0.9 * txt_max_width);
  else Diagrams_textSize(0.9 * txt_max_height);
   
  Diagrams_textAlign(CENTER, CENTER);
  
  Diagrams_strokeWeight(GRAPHS_T_scale * 0);
  
  float min_v = tan_ang(89.99);
  float max_v = tan_ang(-89.99);
  
  for (int k = 0; k < _valuesSUM.length; k += 1) {
    if (_valuesSUM[k] < 0.9 * FLOAT_undefined) {
      if (min_v > _valuesSUM[k]) min_v = _valuesSUM[k];
      if (max_v < _valuesSUM[k]) max_v = _valuesSUM[k];
    }
  } 
  
  if ((min_v != tan_ang(89.99)) && (max_v != tan_ang(-89.99))) {    
    min_v = roundTo((min_v * abs(sy_Plot)), _pix) / _pix;
    max_v = roundTo((max_v * abs(sy_Plot)), _pix) / _pix;
    
    if (drw_Layer == _winddir) min_v = 0;

    int[] _probs;
    int total_probs = 0;
    
    _probs = new int[int((1 + max_v - min_v))];
    
    for (int k = (start_z - 1); k <= (end_z - 1); k += 1) {
      if (_valuesSUM[k] < 0.9 * FLOAT_undefined) {
        float the_value = _valuesSUM[k];
        
        if (drw_Layer == _winddir) {
          if (roundTo((the_value * abs(sy_Plot)), _pix) >= (360 * abs(sy_Plot))) the_value -= 360;
        }
        
        int h = int(roundTo((roundTo((the_value * abs(sy_Plot)), _pix) / _pix) - min_v, 1));
        _probs[h] += 1;
        total_probs += 1;
      }
    }

    if (total_probs != 0) {
      for (int n = 0; n < _probs.length; n += 1) {
        float _u = 1.0 * _probs[n] / total_probs;
        
        //if (int(roundTo(100 * _u, 1)) > 0) {
        if ((100 * _u) > 0) {
        
          SET_COLOR_STYLE(-1, (0.5 * _u)); 
          Diagrams_strokeWeight(GRAPHS_T_scale * 0); 
          Diagrams_rect((j + ((i + 1) / 24.0)) * sx_Plot, -((min_v + n) * _pix) - 0.5 * _pix, -(sum_interval * GRAPHS_S_View * 100 / 24.0) * GRAPHS_U_scale, _pix); 
          
          Diagrams_stroke(0);
          Diagrams_fill(0);
          Diagrams_strokeWeight(GRAPHS_T_scale * 1);
          my_text((String.valueOf(int(roundTo(100 * _u, 1)))), (j + ((i + 1) / 24.0)) * sx_Plot - 0.5 * (sum_interval * GRAPHS_S_View * 100 / 24.0) * GRAPHS_U_scale, -((min_v + n) * _pix) - 0.05 * txt_max_height, 1);
          
          if ((save_info_prob == 1) && (draw_probs == 1)) {
            File_output_prob[(j - j_start)].print(nfs((min_v + n) * _pix / abs(sy_Plot) - V_offset[drw_Layer], 5, 5) + ":\t" + nf(100 * _u, 3, 3) + "\t"); 
          }
        }
      }  
      
      if ((save_info_prob == 1) && (draw_probs == 1)) {
        File_output_prob[(j - j_start)].println(""); 
      }
    }
  }

  float pal_length = 400;
  for (int q = 0; q < 11; q += 1) {
    float _u = 10 * q / 100.0;
    
    Diagrams_strokeWeight(0); 
    SET_COLOR_STYLE(-1, (0.5 * _u));
    
    float Y_OFFSET = (0.25 + V_belowLine[drw_Layer]) * sx_Plot / GRAPHS_U_scale;
 
    //Diagrams_rect((700 + q * (pal_length / 11.0)) * GRAPHS_S_View, 125 * GRAPHS_S_View, (pal_length / 11.0) * GRAPHS_S_View, 20 * GRAPHS_S_View); 
    Diagrams_rect((700 + q * (pal_length / 11.0)) * GRAPHS_S_View, Y_OFFSET, (pal_length / 11.0) * GRAPHS_S_View, 20 * GRAPHS_S_View);
    
    Diagrams_strokeWeight(2); 
    Diagrams_stroke(255);
    Diagrams_fill(255); 
    
    Diagrams_textSize(15.0 * GRAPHS_S_View);
    Diagrams_textAlign(CENTER, CENTER);
    //my_text((String.valueOf(int(roundTo(100 * _u, 1)))), (20 + 700 + q * (pal_length / 11.0)) * GRAPHS_S_View, (10 + 125 - 0.05 * 20) * GRAPHS_S_View, 1 * GRAPHS_S_View);
    my_text((String.valueOf(int(roundTo(100 * _u, 1)))), (20 + 700 + q * (pal_length / 11.0)) * GRAPHS_S_View, Y_OFFSET + (10 - 0.05 * 20) * GRAPHS_S_View, 1 * GRAPHS_S_View);
  }
}


void SOLARCHVISION_draw_sorted (int i, int j, float[] _valuesA, float[] _valuesB, float x_Plot, float y_Plot, float z_Plot, float sx_Plot, float sy_Plot, float sz_Plot) {
  float[] sorted_valuesA = sort(_valuesA);
  int num_sorted_valuesA = 0;
  for (int l = 0; l < sorted_valuesA.length; l += 1) {
    if (sorted_valuesA[l] < 0.9 * FLOAT_undefined) {
      num_sorted_valuesA += 1;
    }
    else break;
  }
  
  float[] sorted_valuesB = sort(_valuesB);
  int num_sorted_valuesB = 0;
  for (int l = 0; l < sorted_valuesB.length; l += 1) {
    if (sorted_valuesB[l] < 0.9 * FLOAT_undefined) {
      num_sorted_valuesB += 1;
    }
    else break;
  }
  
  int num_sorted_valuesAB = min(num_sorted_valuesA, num_sorted_valuesB);
  
  for (int l = 0; l < (num_sorted_valuesAB - 1); l += 1) {
    float _u = 1.1 * (0.5 - ((num_sorted_valuesAB - (l + 1)) / float(num_sorted_valuesAB)));
    
    SET_COLOR_STYLE(-1, (0.5 - 1.0 * _u));
    //SET_COLOR_STYLE(7, (0.5 - 1.0 * _u));
    //SET_COLOR_STYLE(10, (0.5 - 1.0 * _u));
    //SET_COLOR_STYLE(11, (0.5 - 1.0 * _u));
    
    Diagrams_strokeWeight(GRAPHS_T_scale * 0.0); 
    //Diagrams_rect((j + ((i + 1) / 24.0)) * sx_Plot, sorted_valuesA[l] * sy_Plot, -(1 * 100 / 24.0) * GRAPHS_U_scale, (sorted_valuesA[(l + 1)] - sorted_valuesA[l]) * sy_Plot);
    
    float P1x = (j + ((i + 0.5) / 24.0)) * sx_Plot;
    float P2x = (j + ((i + 0.5) / 24.0)) * sx_Plot;
    float P3x = (j + ((i + 1.5) / 24.0)) * sx_Plot;
    float P4x = (j + ((i + 1.5) / 24.0)) * sx_Plot;
    
    float P1y = sorted_valuesA[l] * sy_Plot;
    float P2y = sorted_valuesA[(l + 1)] * sy_Plot;
    float P3y = sorted_valuesB[(l + 1)] * sy_Plot;
    float P4y = sorted_valuesB[l] * sy_Plot; 
    
    Diagrams_quad(P1x, P1y, P2x, P2y, P3x, P3y, P4x, P4y);
    /*
    Diagrams_stroke(255);
    Diagrams_strokeWeight(GRAPHS_T_scale * 0.5); 
    Diagrams_line(P1x, P1y, P4x, P4y); 
    Diagrams_line(P2x, P2y, P3x, P3y);
    */
  }
  
  String[] _txt = {"MIN", "", "25%", "", "MED", "", "75%", "", "MAX"}; 
  float pal_length = 400;
  for (int q = 0; q < 9; q += 1) {
    float _u = 1.1 * (q - 4) / 8.0;
    
    SET_COLOR_STYLE(-1, (0.5 - 1.0 * _u)); 
    //SET_COLOR_STYLE(7, (0.5 - 1.0 * _u));
    //SET_COLOR_STYLE(10, (0.5 - 1.0 * _u));
    //SET_COLOR_STYLE(11, (0.5 - 1.0 * _u));
     
    float Y_OFFSET = (0.25 + V_belowLine[drw_Layer]) * sx_Plot / GRAPHS_U_scale;

    Diagrams_strokeWeight(0.0);
    Diagrams_stroke(255); Diagrams_strokeWeight(0.5); 
    //Diagrams_rect((700 + q * (pal_length / 9.0)) * GRAPHS_S_View, 125 * GRAPHS_S_View, (pal_length / 9.0) * GRAPHS_S_View, 20 * GRAPHS_S_View);
    Diagrams_rect((700 + q * (pal_length / 9.0)) * GRAPHS_S_View, Y_OFFSET, (pal_length / 9.0) * GRAPHS_S_View, 20 * GRAPHS_S_View);
    
    Diagrams_strokeWeight(0); 
    Diagrams_stroke(63);
    Diagrams_fill(63);
    if ((q != 0) && (q != 8)) {   
      Diagrams_strokeWeight(2); 
      Diagrams_stroke(255);
      Diagrams_fill(255); 
    } 

    Diagrams_textSize(15.0 * GRAPHS_S_View);
    Diagrams_textAlign(CENTER, CENTER);
    //my_text(_txt[q], (25 + 700 + q * (pal_length / 9.0)) * GRAPHS_S_View, (10 + 125 - 0.05 * 20) * GRAPHS_S_View, 1);
    my_text(_txt[q], (25 + 700 + q * (pal_length / 9.0)) * GRAPHS_S_View, Y_OFFSET + (10 - 0.05 * 20) * GRAPHS_S_View, 1);
    
  }   
}


void SOLARCHVISION_draw_normals (int i, int j, float[] _valuesA, float[] _valuesB, float x_Plot, float y_Plot, float z_Plot, float sx_Plot, float sy_Plot, float sz_Plot) {
  float[] NormalsA = SOLARCHVISION_NORMAL(_valuesA);
  float[] NormalsB = SOLARCHVISION_NORMAL(_valuesB);
  
  if (drw_Layer == _winddir) {
    float[] X_valuesA;
    float[] Y_valuesA;
    X_valuesA = new float[_valuesA.length];
    Y_valuesA = new float[_valuesA.length];
    
    for (int l = 0; l < _valuesA.length; l += 1) {
      if (_valuesA[l] < 0.9 * FLOAT_undefined) {
        X_valuesA[l] = cos_ang(90 - _valuesA[l]); 
        Y_valuesA[l] = sin_ang(90 - _valuesA[l]);
      }
      else {
        X_valuesA[l] = FLOAT_undefined; 
        Y_valuesA[l] = FLOAT_undefined;
      }
    }
            
    float[] X_NormalsA = SOLARCHVISION_NORMAL(X_valuesA);
    float[] Y_NormalsA = SOLARCHVISION_NORMAL(Y_valuesA);
    
    for (int l = 0; l < NormalsA.length; l += 1) {
      if (NormalsA[l] < 0.9 * FLOAT_undefined) {
        NormalsA[l] = 90 - atan2_ang(Y_NormalsA[l], X_NormalsA[l]);
        if (NormalsA[l] < 0) NormalsA[l] += 360;
      }
      
      if ((l == N_Max) || (l == N_Min)) {
        NormalsA[l] = FLOAT_undefined;
      }
    }
    
    float[] X_valuesB;
    float[] Y_valuesB;
    X_valuesB = new float[_valuesB.length];
    Y_valuesB = new float[_valuesB.length];
    
    for (int l = 0; l < _valuesB.length; l += 1) {
      if (_valuesB[l] < 0.9 * FLOAT_undefined) {
        X_valuesB[l] = cos_ang(90 - _valuesB[l]); 
        Y_valuesB[l] = sin_ang(90 - _valuesB[l]);
      }
      else {
        X_valuesB[l] = FLOAT_undefined; 
        Y_valuesB[l] = FLOAT_undefined;
      }
    }
            
    float[] X_NormalsB = SOLARCHVISION_NORMAL(X_valuesB);
    float[] Y_NormalsB = SOLARCHVISION_NORMAL(Y_valuesB);
    
    for (int l = 0; l < NormalsB.length; l += 1) {
      if (NormalsB[l] < 0.9 * FLOAT_undefined) {
        NormalsB[l] = 90 - atan2_ang(Y_NormalsB[l], X_NormalsB[l]);
        if (NormalsB[l] < 0) NormalsB[l] += 360;
      }
      
      if ((l == N_Max) || (l == N_Min)) {
        NormalsB[l] = FLOAT_undefined;
      }
    }
  }
  int _OPACITY = 191;
  
  //for (int l = 0; l < 9; l += 1) {
  //for (int l = 0; l < 3; l += 1) {
  //for (int l = 3; l < 9; l += 1) {
  
  //for (int p = 0; p < 3; p += 1) { 
    //int l = 3 * int(impact_layer / 3) + p;

  for (int p = 0; p < 1; p += 1) { 
    int l = impact_layer;
    
    if (l == N_Middle) {
      Diagrams_strokeWeight(GRAPHS_T_scale * 2);
      Diagrams_stroke(0, 191, 0, _OPACITY);
      Diagrams_fill(0, 191, 0, _OPACITY);
    }
    else if (l == N_MidHigh) {
      Diagrams_strokeWeight(GRAPHS_T_scale * 1);
      Diagrams_stroke(191, 0, 0, _OPACITY);
      Diagrams_fill(191, 0, 0, _OPACITY);
    } 
    else if (l == N_MidLow) {
      Diagrams_strokeWeight(GRAPHS_T_scale * 1);
      Diagrams_stroke(0, 0, 191, _OPACITY);
      Diagrams_fill(0, 0, 191, _OPACITY);
    } 
    else if (l == N_Max) {
      Diagrams_strokeWeight(GRAPHS_T_scale * 1);
      Diagrams_stroke(255, 127, 127, _OPACITY);
      Diagrams_fill(255, 127, 127, _OPACITY);
    } 
    else if (l == N_Min) {
      Diagrams_strokeWeight(GRAPHS_T_scale * 1);
      Diagrams_stroke(127, 127, 255, _OPACITY);
      Diagrams_fill(127, 127, 255, _OPACITY);
    }
    else if (l == N_M50) {
      Diagrams_strokeWeight(GRAPHS_T_scale * 0.25);
      Diagrams_stroke(0, 127, 0);
      Diagrams_fill(0, 127, 0);
    }
    else if (l == N_M75) {
      Diagrams_strokeWeight(GRAPHS_T_scale * 0.25);
      Diagrams_stroke(127, 0, 0);
      Diagrams_fill(127, 0, 0);
    } 
    else if (l == N_M25) {
      Diagrams_strokeWeight(GRAPHS_T_scale * 0.25);
      Diagrams_stroke(0, 0, 127);
      Diagrams_fill(0, 0, 127);
    } 
    else {
      Diagrams_strokeWeight(GRAPHS_T_scale * 0.5);
      Diagrams_stroke(0, 0, 0);
      Diagrams_fill(0, 0, 0);
    }



/////////////////////////////// 
/*
    if (now_drawing == databaseNumber_CLIMATE_WY2) {
      Diagrams_strokeWeight(GRAPHS_T_scale * 4);
      Diagrams_stroke(0, 127, 0);
      Diagrams_fill(0, 127, 0);
    }
    if (now_drawing == databaseNumber_ENSEMBLE) {
      Diagrams_strokeWeight(GRAPHS_T_scale * 4);
      Diagrams_stroke(127, 0, 0);
      Diagrams_fill(127, 0, 0);
    }
    if (now_drawing == databaseNumber_OBSERVED) {
      Diagrams_strokeWeight(GRAPHS_T_scale * 4);
      Diagrams_stroke(0, 0, 127);
      Diagrams_fill(0, 0, 127);
    }
    if (now_drawing == databaseNumber_CLIMATE_EPW) {
      Diagrams_strokeWeight(GRAPHS_T_scale * 4);
      Diagrams_stroke(0, 127, 0);
      Diagrams_fill(0, 127, 0);
    }    
*/    
    
    Diagrams_strokeWeight(GRAPHS_T_scale * 4);
    Diagrams_stroke(0, 127, 0);
    Diagrams_fill(0, 127, 0);
    
/////////////////////////////// 

    
    float z_l = 60; //l;
    if (l == N_M75) z_l = 61;
    if (l == N_M50) z_l = 61;
    if (l == N_M25) z_l = 61;
    if (l == N_Ave) z_l = 62;
    
    if ((NormalsA[l] < 0.9 * FLOAT_undefined) && (NormalsB[l] < 0.9 * FLOAT_undefined)) {
      my_line((j + ((i + 0.5) / 24.0)) * sx_Plot, NormalsA[l] * sy_Plot, z_l * sz_Plot * GRAPHS_W_scale, (j + ((i + 0.5 + dT) / 24.0)) * sx_Plot, NormalsB[l] * sy_Plot, z_l * sz_Plot * GRAPHS_W_scale); 
    } 
    
    if ((save_info_norm == 1) && (draw_normals == 1)) {
      if (NormalsA[l] < 0.9 * FLOAT_undefined) File_output_norm[(j - j_start)].print(nfs(NormalsA[l] - V_offset[drw_Layer], 5, 5) + "\t"); 
      else File_output_norm[(j - j_start)].print("[undefined]\t");
    }

  }
  if ((save_info_norm == 1) && (draw_normals == 1)) File_output_norm[(j - j_start)].println();
}  


int[] get_startZ_endZ (int data_source) {
  int[] a = new int[3];

  int start_z = -1;
  int end_z = -1; 
  int layers_count = -1;

  if (data_source == databaseNumber_CLIMATE_WY2) {

    start_z = CLIMATE_WY2_start;
    end_z = CLIMATE_WY2_end; 
    
    switch(H_layer_option) {
      case 1 : start_z = 1953; end_z = 1959; break;
      case 2 : start_z = 1960; end_z = 1969; break;
      case 3 : start_z = 1970; end_z = 1979; break;
      case 4 : start_z = 1980; end_z = 1989; break;
      case 5 : start_z = 1990; end_z = 1999; break;
      case 6 : start_z = 2000; end_z = 2005; break;
      case 7: start_z = Sample_Year; end_z = Sample_Year; break;
    }
    
    start_z -= CLIMATE_WY2_start - 1;
    end_z -= CLIMATE_WY2_start - 1;
  }
  if (data_source == databaseNumber_ENSEMBLE) {

    start_z = ENSEMBLE_start;
    end_z = ENSEMBLE_end;
    
    switch(F_layer_option) {
      case 1 : start_z = 1; end_z = 21; break;
      case 2 : start_z = 1; end_z = 22; break;
      case 3 : start_z = 23; end_z = 43; break;
      case 4: start_z = Sample_Member; end_z = Sample_Member; break;
    }

  }    
  if (data_source == databaseNumber_OBSERVED) {

    start_z = OBSERVED_start;
    end_z = OBSERVED_end;
    
    switch(O_layer_option) {
      case 1 : start_z = 1; end_z = 1; break;
      case 2 : start_z = Sample_Station; end_z = Sample_Station; break;
    }

  }   
  if (data_source == databaseNumber_CLIMATE_EPW) {

    start_z = 1;
    end_z = 1;
    
  }   



  if (impacts_source == databaseNumber_CLIMATE_WY2) layers_count = (1 + CLIMATE_WY2_end - CLIMATE_WY2_start);
  if (impacts_source == databaseNumber_ENSEMBLE) layers_count = (1 + ENSEMBLE_end - ENSEMBLE_start); 
  if (impacts_source == databaseNumber_OBSERVED) layers_count = (1 + OBSERVED_end - OBSERVED_start);
  if (impacts_source == databaseNumber_CLIMATE_EPW) layers_count = 1;
  
  a[0] = start_z;
  a[1] = end_z;
  a[2] = layers_count;
  
  return  a;
}

void SOLARCHVISION_DevelopDATA (int data_source) {

  int start_z = get_startZ_endZ(data_source)[0];
  int end_z = get_startZ_endZ(data_source)[1]; 
  int layers_count = get_startZ_endZ(data_source)[2]; 
 
  float Pa = FLOAT_undefined;
  float Pb = FLOAT_undefined;
  float RAIN, T, R_dir, R_dif;

  float[] _valuesSUM; 
  _valuesSUM = new float[layers_count];
  
  for (int k = 0; k < layers_count; k += 1) {
      _valuesSUM[k] = FLOAT_undefined;
  }
  
  for (int j = j_start; j <= j_end; j += 1) { 
    for (int k = (start_z - 1); k <= (end_z - 1); k += 1) {
      for (int i = 0; i < 24; i += 1) {

        int now_k = k;
        int now_i = i;
        int now_j = (j + BEGIN_DAY + 365) % 365;
        
        if (now_j >= 365) {
         now_j = now_j % 365; 
        }
        if (now_j < 0) {
         now_j = (now_j + 365) % 365; 
        }
        
        int next_i = now_i + 12;
        int next_j = now_j;
        int next_k = now_k;
        if (next_i >= 24) {
          next_i = next_i - 24; 
          next_j += 1; 
          if (next_j >= 365) {
            next_j = next_j % 365;
          }
        }
        
        
        int pre_i = now_i - 12;
        int pre_j = now_j;
        int pre_k = now_k;
        if (pre_i < 0) {
          pre_i = pre_i + 24; 
          pre_j -= 1; 
          if (pre_j < 0) {
            pre_j = (pre_j + 365) % 365;
          }
        }       
        
        if (data_source == databaseNumber_CLIMATE_EPW) CLIMATE_EPW[now_i][now_j][_developed][now_k] = FLOAT_undefined;
        if (data_source == databaseNumber_CLIMATE_WY2) CLIMATE_WY2[now_i][now_j][_developed][now_k] = FLOAT_undefined;
        if (data_source == databaseNumber_ENSEMBLE) ENSEMBLE[now_i][now_j][_developed][now_k] = FLOAT_undefined;
        
        T = FLOAT_undefined;
        R_dir = FLOAT_undefined;
        R_dif = FLOAT_undefined;
        
        if ((i == 0) && (j == j_start)) _valuesSUM[now_k] = 0; 

        if (data_source == databaseNumber_CLIMATE_EPW) Pa = CLIMATE_EPW[now_i][now_j][_dirnorrad][now_k];
        if (data_source == databaseNumber_CLIMATE_WY2) Pa = CLIMATE_WY2[now_i][now_j][_dirnorrad][now_k]; 
        if (data_source == databaseNumber_ENSEMBLE) Pa = ENSEMBLE[now_i][now_j][_dirnorrad][now_k];
        if (Pa > 0.9 * FLOAT_undefined) {
          R_dir = FLOAT_undefined;
        }
        else {
          R_dir = Pa;
        }
  
        if (data_source == databaseNumber_CLIMATE_EPW) Pa = CLIMATE_EPW[now_i][now_j][_difhorrad][now_k];
        if (data_source == databaseNumber_CLIMATE_WY2) Pa = CLIMATE_WY2[now_i][now_j][_difhorrad][now_k];
        if (data_source == databaseNumber_ENSEMBLE) Pa = ENSEMBLE[now_i][now_j][_difhorrad][now_k];
        if (Pa > 0.9 * FLOAT_undefined) {
          R_dif = FLOAT_undefined;
        }
        else {
          R_dif = Pa;
        }
        
        if (data_source == databaseNumber_CLIMATE_EPW) Pa = CLIMATE_EPW[now_i][now_j][_drybulb][now_k];
        if (data_source == databaseNumber_CLIMATE_WY2) Pa = CLIMATE_WY2[now_i][now_j][_drybulb][now_k];
        if (data_source == databaseNumber_ENSEMBLE) Pa = ENSEMBLE[now_i][now_j][_drybulb][now_k];
        if (Pa > 0.9 * FLOAT_undefined) {
          T = FLOAT_undefined;
        }
        else {
          T = Pa;
        }
        
        if (data_source == databaseNumber_CLIMATE_EPW) Pa = CLIMATE_EPW[now_i][now_j][_precipitation][now_k];
        if (data_source == databaseNumber_CLIMATE_WY2) Pa = CLIMATE_WY2[now_i][now_j][_precipitation][now_k];
        if (data_source == databaseNumber_ENSEMBLE) Pa = ENSEMBLE[now_i][now_j][_precipitation][now_k];
        
        if (data_source == databaseNumber_CLIMATE_EPW) Pb = CLIMATE_EPW[next_i][next_j][_precipitation][now_k];
        if (data_source == databaseNumber_CLIMATE_WY2) Pb = CLIMATE_WY2[next_i][next_j][_precipitation][now_k];
        if (data_source == databaseNumber_ENSEMBLE) Pb = ENSEMBLE[next_i][next_j][_precipitation][now_k];
        //if (data_source == databaseNumber_CLIMATE_EPW) Pb = CLIMATE_EPW[pre_i][pre_j][_precipitation][now_k];
        //if (data_source == databaseNumber_CLIMATE_WY2) Pb = CLIMATE_WY2[pre_i][pre_j][_precipitation][now_k];
        //if (data_source == databaseNumber_ENSEMBLE) Pb = ENSEMBLE[pre_i][pre_j][_precipitation][now_k];
        
        if ((Pa > 0.9 * FLOAT_undefined) || (Pb > 0.9 * FLOAT_undefined)) {
          RAIN = FLOAT_undefined;
        }
        else {
          RAIN = Pb - Pa;
          //RAIN = Pa - Pb;
          
          //if (T <= 0) RAIN *= -1; // <<<<<<<<<<<<<<<<<<<<
        }    
        
          
        float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);
        float HOUR_ANGLE = now_i; 
        
        float[] SunR = SOLARCHVISION_SunPosition(LocationLatitude, DATE_ANGLE, HOUR_ANGLE);






        if (develop_option == 0) {  
          
          if ((R_dir < 0.9 * FLOAT_undefined) && (R_dif < 0.9 * FLOAT_undefined)) { 
           
            if (Materials_DirectArea_Flag[now_i][now_j] == -1) {
              _valuesSUM[now_k] = FLOAT_undefined;
            } 
            else {
              _valuesSUM[now_k] = 0.001 * (R_dir * Materials_DirectArea[Materials_Selection][now_i][now_j] + R_dif * Materials_DiffuseArea[Materials_Selection][now_i][now_j]);
            }


            
            if (data_source == databaseNumber_CLIMATE_EPW) CLIMATE_EPW[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
            if (data_source == databaseNumber_CLIMATE_WY2) CLIMATE_WY2[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
            if (data_source == databaseNumber_ENSEMBLE) ENSEMBLE[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
          }
            
          GRAPHS_V_scale[_developed] = 0.5;
          V_offset[_developed] = 0;
          V_belowLine[_developed] = 1;
          _LAYERS[_developed][0] = "KW";
          _LAYERS[_developed][1] = "Direct radiation on surfaces with material #" + String.valueOf(Materials_Selection);
          _LAYERS[_developed][2] = _LAYERS[_developed][1]; // ?? 
        }         

 
        if (develop_option == 1) {
          float Alpha = Angle_inclination;
          float Beta = Angle_orientation;
          
           
          
          if ((R_dir < 0.9 * FLOAT_undefined) && (R_dif < 0.9 * FLOAT_undefined)) { 
           
            _valuesSUM[now_k] = SolarAtSurface(SunR[1], SunR[2], SunR[3], R_dir, R_dif, Alpha, Beta, GlobalAlbedo);
            
            if (data_source == databaseNumber_CLIMATE_EPW) CLIMATE_EPW[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
            if (data_source == databaseNumber_CLIMATE_WY2) CLIMATE_WY2[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
            if (data_source == databaseNumber_ENSEMBLE) ENSEMBLE[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
          }
            
          GRAPHS_V_scale[_developed] = 0.1;
          V_offset[_developed] = 0;
          V_belowLine[_developed] = 0;
          _LAYERS[_developed][0] = "W/m²";
          _LAYERS[_developed][1] = "Radiation on inclination_" + String.valueOf(Alpha) + "_South-Deviation_" + String.valueOf(Beta);
          _LAYERS[_developed][2] = _LAYERS[_developed][1]; // ??         
        } 
        
        if (develop_option == 2) {
          float Alpha = Angle_inclination;
          float Beta = Angle_orientation;
          
          if ((R_dir < 0.9 * FLOAT_undefined) && (R_dif < 0.9 * FLOAT_undefined)) { 
            
            _valuesSUM[now_k] += SolarAtSurface(SunR[1], SunR[2], SunR[3], R_dir, R_dif, Alpha, Beta, GlobalAlbedo);
            
            if (data_source == databaseNumber_CLIMATE_EPW) CLIMATE_EPW[now_i][now_j][_developed][now_k] = 0.001 * _valuesSUM[now_k];
            if (data_source == databaseNumber_CLIMATE_WY2) CLIMATE_WY2[now_i][now_j][_developed][now_k] = 0.001 * _valuesSUM[now_k];
            if (data_source == databaseNumber_ENSEMBLE) ENSEMBLE[now_i][now_j][_developed][now_k] = 0.001 * _valuesSUM[now_k];
          }

            
          GRAPHS_V_scale[_developed] = 2.5;
          V_offset[_developed] = -40;
          V_belowLine[_developed] = 1;
          _LAYERS[_developed][0] = "kWh/m²";
          _LAYERS[_developed][1] = "Accumulated radiation on inclination_" + String.valueOf(Alpha) + "_South-Deviation_" + String.valueOf(Beta);
          _LAYERS[_developed][2] = _LAYERS[_developed][1]; // ?? 
        } 
        
        if (develop_option == 3) {
          float Alpha = asin_ang(SunR[3]);
          float Beta = atan2_ang(SunR[2], SunR[1]) + 90;
          
          if ((R_dir < 0.9 * FLOAT_undefined) && (R_dif < 0.9 * FLOAT_undefined)) { 
           
            _valuesSUM[now_k] = SolarAtSurface(SunR[1], SunR[2], SunR[3], R_dir, R_dif, Alpha, Beta, GlobalAlbedo);
            
            if (data_source == databaseNumber_CLIMATE_EPW) CLIMATE_EPW[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
            if (data_source == databaseNumber_CLIMATE_WY2) CLIMATE_WY2[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
            if (data_source == databaseNumber_ENSEMBLE) ENSEMBLE[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
          }
            
          GRAPHS_V_scale[_developed] = 0.1;
          V_offset[_developed] = 0;
          V_belowLine[_developed] = 0;
          _LAYERS[_developed][0] = "W/m²";
          _LAYERS[_developed][1] = "Radiation on solar tracker";
          _LAYERS[_developed][2] = _LAYERS[_developed][1]; // ?? 
        }         
        
        if (develop_option == 4) {
          float Alpha = asin_ang(SunR[3]);
          float Beta = atan2_ang(SunR[2], SunR[1]) + 90;
          
          if ((R_dir < 0.9 * FLOAT_undefined) && (R_dif < 0.9 * FLOAT_undefined)) { 
           
            _valuesSUM[now_k] += SolarAtSurface(SunR[1], SunR[2], SunR[3], R_dir, R_dif, Alpha, Beta, GlobalAlbedo);
            
            if (data_source == databaseNumber_CLIMATE_EPW) CLIMATE_EPW[now_i][now_j][_developed][now_k] = 0.001 * _valuesSUM[now_k];
            if (data_source == databaseNumber_CLIMATE_WY2) CLIMATE_WY2[now_i][now_j][_developed][now_k] = 0.001 * _valuesSUM[now_k];
            if (data_source == databaseNumber_ENSEMBLE) ENSEMBLE[now_i][now_j][_developed][now_k] = 0.001 * _valuesSUM[now_k];
          }
            
          GRAPHS_V_scale[_developed] = 2.5;
          V_offset[_developed] = -40;
          V_belowLine[_developed] = 1;
          _LAYERS[_developed][0] = "kWh/m²";
          _LAYERS[_developed][1] = "Accumulated radiation on solar tracker";
          _LAYERS[_developed][2] = _LAYERS[_developed][1]; // ?? 
        } 
        
        
        if (develop_option == 5) {
          
          if (T < 0.9 * FLOAT_undefined) { 
            _valuesSUM[now_k] += (18 - T) / 24;
            
            if (data_source == databaseNumber_CLIMATE_EPW) CLIMATE_EPW[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
            if (data_source == databaseNumber_CLIMATE_WY2) CLIMATE_WY2[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
            if (data_source == databaseNumber_ENSEMBLE) ENSEMBLE[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
          }
            
          GRAPHS_V_scale[_developed] = 1.0;
          V_offset[_developed] = 0;
          V_belowLine[_developed] = 0;
          _LAYERS[_developed][0] = "°C";
          _LAYERS[_developed][1] = "Accumulated degree day (based on 18°C)";
          _LAYERS[_developed][2] = _LAYERS[_developed][1]; // ??         
        } 
        
        if (develop_option == 6) {
          
          _valuesSUM[now_k] = 0;
          float sum_count = 0;
          
          int num_count = join_hour_numbers;
          
    
          for (int _count = 1; _count <= num_count; _count += 1) {
            
            int plus_i = - (_count - 1);
            
            int new_k = k;
            int new_i = ((i + plus_i) + 24 * 365 + 24 * (floor((i + plus_i) / 24.0))) % 24;
            int new_j = (j + BEGIN_DAY + 365 + floor((i + plus_i) / 24.0)) % 365;
            
            if (new_j >= 365) {
             new_j = new_j % 365; 
            }
            if (now_j < 0) {
             new_j = (new_j + 365) % 365; 
            }
            
            float T_new = FLOAT_undefined;
            if (data_source == databaseNumber_CLIMATE_EPW) Pa = CLIMATE_EPW[new_i][new_j][develop_Layer][new_k];
            if (data_source == databaseNumber_CLIMATE_WY2) Pa = CLIMATE_WY2[new_i][new_j][develop_Layer][new_k];
            if (data_source == databaseNumber_ENSEMBLE) Pa = ENSEMBLE[new_i][new_j][develop_Layer][new_k];

            if (Pa > 0.9 * FLOAT_undefined) {
              T_new = FLOAT_undefined;
            }
            else {
              T_new = Pa;
            }            
            
            if (T_new < 0.9 * FLOAT_undefined) {
              float _weight = (num_count - _count + 1);
              if (join_type == 1) _weight = 1;
              sum_count += _weight;
              _valuesSUM[now_k] += _weight * T_new;
              
            }           
          } 
         
          if (sum_count != 0) {
            _valuesSUM[now_k] /= sum_count;
            if (data_source == databaseNumber_CLIMATE_EPW) CLIMATE_EPW[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
            if (data_source == databaseNumber_CLIMATE_WY2) CLIMATE_WY2[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
            if (data_source == databaseNumber_ENSEMBLE) ENSEMBLE[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
          }
          else {
            _valuesSUM[now_k] = FLOAT_undefined;
            if (data_source == databaseNumber_CLIMATE_EPW) CLIMATE_EPW[now_i][now_j][_developed][now_k] = FLOAT_undefined;
            if (data_source == databaseNumber_CLIMATE_WY2) CLIMATE_WY2[now_i][now_j][_developed][now_k] = FLOAT_undefined;
            if (data_source == databaseNumber_ENSEMBLE) ENSEMBLE[now_i][now_j][_developed][now_k] = FLOAT_undefined;
          }
          
          _valuesSUM[now_k] = 0;

            
          GRAPHS_V_scale[_developed] = GRAPHS_V_scale[develop_Layer];
          V_offset[_developed] = V_offset[develop_Layer];
          V_belowLine[_developed] = V_belowLine[develop_Layer];
          _LAYERS[_developed][0] = _LAYERS[develop_Layer][0];
          _LAYERS[_developed][1] = String.valueOf(join_hour_numbers) + "-hour PASSIVE trend of " + _LAYERS[develop_Layer][1];
          _LAYERS[_developed][2] = String.valueOf(join_hour_numbers) + "-hour PASSIVE trend of " + _LAYERS[develop_Layer][2]; // ??    
        }     
    
    
        if (develop_option == 7) {
          
          _valuesSUM[now_k] = 0;
          float sum_count = 0;
          
          int num_count = join_hour_numbers;
          
    
          for (int _count = 1; _count <= ceil((num_count + 1) / 2); _count += 1) {
            for (int dir_count = -1; dir_count <= 1; dir_count += 2) {
            
              int plus_i = dir_count * (_count - 1);
              
              int new_k = k;
              int new_i = ((i + plus_i) + 24 * 365 + 24 * (floor((i + plus_i) / 24.0))) % 24;
              int new_j = (j + BEGIN_DAY + 365 + floor((i + plus_i) / 24.0)) % 365;
              
              if (new_j >= 365) {
               new_j = new_j % 365; 
              }
              if (now_j < 0) {
               new_j = (new_j + 365) % 365; 
              }
              
              float T_new = FLOAT_undefined;
              
              if (data_source == databaseNumber_CLIMATE_EPW) Pa = CLIMATE_EPW[new_i][new_j][develop_Layer][new_k];
              if (data_source == databaseNumber_CLIMATE_WY2) Pa = CLIMATE_WY2[new_i][new_j][develop_Layer][new_k];
              if (data_source == databaseNumber_ENSEMBLE) Pa = ENSEMBLE[new_i][new_j][develop_Layer][new_k];
              
              if (Pa > 0.9 * FLOAT_undefined) {
                T_new = FLOAT_undefined;
              }
              else {
                T_new = Pa;
              }            
              
              if (T_new < 0.9 * FLOAT_undefined) {
                float _weight = (num_count - _count + 1);
                if (join_type == 1) _weight = 1;
                sum_count += _weight;
                _valuesSUM[now_k] += _weight * T_new;
                
              }    
            }       
          } 
         
          if (sum_count != 0) {
            _valuesSUM[now_k] /= sum_count;
            if (data_source == databaseNumber_CLIMATE_EPW) CLIMATE_EPW[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
            if (data_source == databaseNumber_CLIMATE_WY2) CLIMATE_WY2[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
            if (data_source == databaseNumber_ENSEMBLE) ENSEMBLE[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
          }
          else {
            _valuesSUM[now_k] = FLOAT_undefined;
            if (data_source == databaseNumber_CLIMATE_EPW) CLIMATE_EPW[now_i][now_j][_developed][now_k] = FLOAT_undefined;
            if (data_source == databaseNumber_CLIMATE_WY2) CLIMATE_WY2[now_i][now_j][_developed][now_k] = FLOAT_undefined;
            if (data_source == databaseNumber_ENSEMBLE) ENSEMBLE[now_i][now_j][_developed][now_k] = FLOAT_undefined;
          }
          
          _valuesSUM[now_k] = 0;

            
          GRAPHS_V_scale[_developed] = GRAPHS_V_scale[develop_Layer];
          V_offset[_developed] = V_offset[develop_Layer];
          V_belowLine[_developed] = V_belowLine[develop_Layer];
          _LAYERS[_developed][0] = _LAYERS[develop_Layer][0];
          _LAYERS[_developed][1] = String.valueOf(join_hour_numbers) + "-hour NORMAL trend of " + _LAYERS[develop_Layer][1];
          _LAYERS[_developed][2] = String.valueOf(join_hour_numbers) + "-hour NORMAL trend of " + _LAYERS[develop_Layer][2]; // ??

        }           
        
        if (develop_option == 8) {
          
          _valuesSUM[now_k] = 0;
          float sum_count = 0;
          
          int num_count = join_hour_numbers;
          
    
          for (int _count = num_count; _count > 0; _count -= 1) {
            
            int plus_i = _count - 1;
            
            int new_k = k;
            int new_i = ((i + plus_i) + 24 * floor((i + plus_i) / 24.0)) % 24;
            int new_j = (j + BEGIN_DAY + 365 + floor((i + plus_i) / 24.0)) % 365;
            
            if (new_j >= 365) {
             new_j = new_j % 365; 
            }
            if (now_j < 0) {
             new_j = (new_j + 365) % 365; 
            }
            
            float T_new = FLOAT_undefined;
            
            if (data_source == databaseNumber_CLIMATE_EPW) Pa = CLIMATE_EPW[new_i][new_j][develop_Layer][new_k];
            if (data_source == databaseNumber_CLIMATE_WY2) Pa = CLIMATE_WY2[new_i][new_j][develop_Layer][new_k];
            if (data_source == databaseNumber_ENSEMBLE) Pa = ENSEMBLE[new_i][new_j][develop_Layer][new_k];

            if (Pa > 0.9 * FLOAT_undefined) {
              T_new = FLOAT_undefined;
            }
            else {
              T_new = Pa;
            }            
            
            if (T_new < 0.9 * FLOAT_undefined) {
              float _weight = (num_count - _count + 1);
              if (join_type == 1) _weight = 1;
              sum_count += _weight;
              _valuesSUM[now_k] += _weight * T_new;
              
            }           
          } 
         
          if (sum_count != 0) {
            _valuesSUM[now_k] /= sum_count;
            if (data_source == databaseNumber_CLIMATE_EPW) CLIMATE_EPW[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
            if (data_source == databaseNumber_CLIMATE_WY2) CLIMATE_WY2[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
            if (data_source == databaseNumber_ENSEMBLE) ENSEMBLE[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
          }
          else {
            _valuesSUM[now_k] = FLOAT_undefined;
            if (data_source == databaseNumber_CLIMATE_EPW) CLIMATE_EPW[now_i][now_j][_developed][now_k] = FLOAT_undefined;
            if (data_source == databaseNumber_CLIMATE_WY2) CLIMATE_WY2[now_i][now_j][_developed][now_k] = FLOAT_undefined;
            if (data_source == databaseNumber_ENSEMBLE) ENSEMBLE[now_i][now_j][_developed][now_k] = FLOAT_undefined;
          }
          
          _valuesSUM[now_k] = 0;

            
          GRAPHS_V_scale[_developed] = GRAPHS_V_scale[develop_Layer];
          V_offset[_developed] = V_offset[develop_Layer];
          V_belowLine[_developed] = V_belowLine[develop_Layer];
          _LAYERS[_developed][0] = _LAYERS[develop_Layer][0];
          _LAYERS[_developed][1] = String.valueOf(join_hour_numbers) + "-hour ACTIVE trend of " + _LAYERS[develop_Layer][1];
          _LAYERS[_developed][2] = String.valueOf(join_hour_numbers) + "-hour ACTIVE trend of " + _LAYERS[develop_Layer][2]; // ??    
        } 
        

        if (develop_option == 9) {
          
          if (RAIN < 0.9 * FLOAT_undefined) { 
            _valuesSUM[now_k] = RAIN;
            
            if (data_source == databaseNumber_CLIMATE_EPW) CLIMATE_EPW[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
            if (data_source == databaseNumber_CLIMATE_WY2) CLIMATE_WY2[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
            if (data_source == databaseNumber_ENSEMBLE) ENSEMBLE[now_i][now_j][_developed][now_k] = _valuesSUM[now_k];
          }
            
          GRAPHS_V_scale[_developed] = 2.5;
          V_offset[_developed] = 0; //-20.0 / (1.0 * level_pix); // so that we can have two views on probabilites above and below zero.
          V_belowLine[_developed] = 0; //1;
          _LAYERS[_developed][0] = "mm/12hours  ";
          _LAYERS[_developed][1] = "12-hour Surface Accumulated Precipitation";
          _LAYERS[_developed][2] = _LAYERS[_developed][1]; // ??         
        } 
        

        
        
        
        
        
       
        if ((develop_option == 2) || (develop_option == 4)) {
         
          if ((i == 23) && (develop_per_day == 1)) {
            for (int l = i + 1 - 24; l <= i ; l += 1) {
              if (data_source == databaseNumber_CLIMATE_EPW) CLIMATE_EPW[l][now_j][_developed][now_k] = CLIMATE_WY2[now_i][now_j][_developed][now_k];
              if (data_source == databaseNumber_CLIMATE_WY2) CLIMATE_WY2[l][now_j][_developed][now_k] = CLIMATE_WY2[now_i][now_j][_developed][now_k];
              if (data_source == databaseNumber_ENSEMBLE) ENSEMBLE[l][now_j][_developed][now_k] = ENSEMBLE[now_i][now_j][_developed][now_k];
            }
            //sum_interval = 24;
            GRAPHS_V_scale[_developed] = 10;
            V_offset[_developed] = 0;
            V_belowLine[_developed] = 0;
            _LAYERS[_developed][0] += "/day";
            
            _valuesSUM[now_k] = 0;
          }
          
          if (((i == 11) || (i == 23)) && (develop_per_day == 2)) {
            for (int l = i + 1 - 12 ; l <= i; l += 1) {
              if (data_source == databaseNumber_CLIMATE_EPW) CLIMATE_EPW[l][now_j][_developed][now_k] = CLIMATE_WY2[now_i][now_j][_developed][now_k];
              if (data_source == databaseNumber_CLIMATE_WY2) CLIMATE_WY2[l][now_j][_developed][now_k] = CLIMATE_WY2[now_i][now_j][_developed][now_k];
              if (data_source == databaseNumber_ENSEMBLE) ENSEMBLE[l][now_j][_developed][now_k] = ENSEMBLE[now_i][now_j][_developed][now_k];
            }
            //sum_interval = 12;
            GRAPHS_V_scale[_developed] = 10;
            V_offset[_developed] = 0;
            V_belowLine[_developed] = 0;
            _LAYERS[_developed][0] += "/12hours";
            
            _valuesSUM[now_k] = 0;
          }   

          if (((i == 5) || (i == 11) || (i == 17) || (i == 23)) && (develop_per_day == 3)) {
            for (int l = i + 1 - 6 ; l <= i; l += 1) {
              if (data_source == databaseNumber_CLIMATE_EPW) CLIMATE_EPW[l][now_j][_developed][now_k] = CLIMATE_WY2[now_i][now_j][_developed][now_k];
              if (data_source == databaseNumber_CLIMATE_WY2) CLIMATE_WY2[l][now_j][_developed][now_k] = CLIMATE_WY2[now_i][now_j][_developed][now_k];
              if (data_source == databaseNumber_ENSEMBLE) ENSEMBLE[l][now_j][_developed][now_k] = ENSEMBLE[now_i][now_j][_developed][now_k];
            }
            //sum_interval = 6;
            GRAPHS_V_scale[_developed] = 10;
            V_offset[_developed] = 0;
            V_belowLine[_developed] = 0;
            _LAYERS[_developed][0] += "/6hours";
            
            _valuesSUM[now_k] = 0;
          }     
        }
      }
    }
  } 

}


int N_MidLow = 0;
int N_Middle = 1;
int N_MidHigh = 2;

int N_M25 = 3;
int N_M50 = 4;
int N_M75 = 5;

int N_Min = 6;
int N_Ave = 7;
int N_Max = 8;

String[] N_Title = {
  "Mid-LOW*       ",   
  "MIDDLE*        ", 
  "Mid-HIGH*      ", 
 
  "25th Percentile", 
  "50th P.(Median)", 
  "75th Percentile", 

  "MINIMUM        ", 
  "AVERAGE        ", 
  "MAXIMUM        "

};

int[] reverse_N;
{
  reverse_N = new int[9];
  reverse_N[N_MidLow] = N_MidHigh;
  reverse_N[N_Middle] = N_Middle;
  reverse_N[N_MidHigh] = N_MidLow;
  reverse_N[N_M25] = N_M75;
  reverse_N[N_M50] = N_M50;
  reverse_N[N_M75] = N_M25;
  reverse_N[N_Min] = N_Max;
  reverse_N[N_Ave] = N_Ave;
  reverse_N[N_Max] = N_Min;
}

float[] SOLARCHVISION_NORMAL (float[] _values) {
  float[] weight_array = {0, 0, 0, 0, 0, 0, 0, 0, 0};
  float[] return_array = {0, 0, 0, 0, 0, 0, 0, 0, 0};
  
  int NV = 0; // the number of values without counting undefined values
  float _weight = 0; 
  
  _values = sort(_values);
  for (int i = 0; i < _values.length; i += 1) {
    if (_values[i] < 0.9 * FLOAT_undefined) NV += 1;
  }

  if (NV > 0) {
    for (int i = 0; i < NV; i += 1) {
      if (_values[i] < 0.9 * FLOAT_undefined) {
        _weight = 1;
        weight_array[N_Ave] += _weight;
        return_array[N_Ave] += _values[i];
        
        _weight = (0.5 * (NV + 1)) - abs((0.5 * (NV + 1)) - (i + 1));
        weight_array[N_Middle] += _weight;
        return_array[N_Middle] += _values[i] * _weight;
        
        _weight = (i + 1);
        weight_array[N_MidHigh] += _weight;
        return_array[N_MidHigh] += _values[i] * _weight;
        
        _weight = (NV + 1 - i);
        weight_array[N_MidLow] += _weight;
        return_array[N_MidLow] += _values[i] * _weight; 
      }
    }

    return_array[N_Ave] /= weight_array[N_Ave];
    return_array[N_Middle] /= weight_array[N_Middle];
    return_array[N_MidHigh] /= weight_array[N_MidHigh];
    return_array[N_MidLow] /= weight_array[N_MidLow];
    
    return_array[N_Max] = _values[(NV - 1)];
    return_array[N_Min] = _values[0];

    if ((NV % 2) == 1) {
      return_array[N_M50] = _values[(NV / 2)];
    }
    else {
      return_array[N_M50] = 0.5 * (_values[(int(NV / 2))] + _values[(1 + int(NV / 2))]);
    }
    
    
    int q;
    
    q = int(roundTo((NV * 0.75), 1));
    if (q > NV - 1) q = NV - 1;
    return_array[N_M75] = _values[q];

    q = int(roundTo((NV * 0.25), 1));
    if (q < 0) q = 0;
    return_array[N_M25] = _values[q];
  }
  else {
    for (int i = 0; i < return_array.length; i += 1) {
      return_array[i] = FLOAT_undefined;
    }
  }
  
  return return_array; 
}


int SOLARCHVISION_filter (String data_type, int _cloudcover, int type_of_filter, int scenario_of_sky, int now_i, int now_j, int now_k) {
  
  float total_sky = 0;
  int num_sky = 0;
  
  int start_q = now_i;
  int end_q = now_i;
  
  if (type_of_filter == _daily) {
    start_q = 0;
    end_q = 23;
  }
  
  for (int q = start_q; q <= end_q; q += 1) {
    float _sky = FLOAT_undefined;
    if (data_type.equals("OBSERVED")) _sky = OBSERVED[q][now_j][_cloudcover][now_k];
    if (data_type.equals("ENSEMBLE")) _sky = ENSEMBLE[q][now_j][_cloudcover][now_k];
    if (data_type.equals("CLIMATE_WY2")) _sky = CLIMATE_WY2[q][now_j][_cloudcover][now_k];
    if (data_type.equals("CLIMATE_EPW")) _sky = CLIMATE_EPW[q][now_j][_cloudcover][now_k];
    
    if (_sky > 0.9 * FLOAT_undefined) {
    }
    else {
      total_sky += _sky;
      num_sky += 1;
    }
  }
  

  int _return = 0;
  
  if (num_sky != 0) {
    total_sky /= num_sky;
    
    if (scenario_of_sky == 1) _return = 1;
    else if ((scenario_of_sky == 4) && (total_sky <= 3.33)) _return = 1;
    else if ((scenario_of_sky == 3) && (total_sky > 3.33) && (total_sky <= 6.66)) _return = 1; 
    else if ((scenario_of_sky == 2) && (total_sky > 6.66)) _return = 1;
  }
  
  return _return;
}


int[] SOLARCHVISION_FIND_SCENARIOS_CLOSE_TO_NORMALS (float[] _values) {
  
  float[] _normals = SOLARCHVISION_NORMAL(_values);
  
  int[] return_array = new int[9];
  
  for (int l = 0; l < 9; l += 1) {
    return_array[l] = -1;
    if (_normals[l] < 0.9 * FLOAT_undefined) {
    
      float _dist = FLOAT_undefined;
      
      for (int i = 0; i < _values.length; i += 1) {
        if (_dist > abs(_normals[l] - _values[i])) {
          _dist = abs(_normals[l] - _values[i]);
          return_array[l] = i;
        }
      }
    }
    else return_array[l] = -1;
  }
  
  return return_array; 
}


int[] SOLARCHVISION_PROCESS_DAILY_SCENARIOS (int layers_count, int start_z, int end_z, int j, float DATE_ANGLE) {

  float Pa = FLOAT_undefined;
  float Pb = FLOAT_undefined;
  float Pc = FLOAT_undefined;
  float Pd = FLOAT_undefined;
 
  float _values_R_dir;
  float _values_R_dif;
  float _values_E_dir;
  float _values_E_dif;

  float[] _valuesSUM_RAD; 
  float[] _valuesSUM_EFF;
  float[] _valuesNUM;
  _valuesSUM_RAD = new float[(layers_count * num_add_days)];
  _valuesSUM_EFF = new float[(layers_count * num_add_days)];
  _valuesNUM = new float[(layers_count * num_add_days)];
  
  for (int j_ADD = 0; j_ADD < num_add_days; j_ADD += 1) {
    for (int k = 0; k < layers_count; k += 1) { 
      _valuesSUM_RAD[(k * num_add_days + j_ADD)] = FLOAT_undefined;
      _valuesSUM_EFF[(k * num_add_days + j_ADD)] = FLOAT_undefined;
      _valuesNUM[(k * num_add_days + j_ADD)] = 0;
    }          
  }

  for (int j_ADD = 0; j_ADD < num_add_days; j_ADD += 1) {
    
    for (int k = (start_z - 1); k <= (end_z - 1); k += 1) {
      
      for (int i = 0; i < 24; i += 1) {
        
        float HOUR_ANGLE = i; 
        float[] SunR = SOLARCHVISION_SunPosition(LocationLatitude, DATE_ANGLE, HOUR_ANGLE);
        
        int now_k = k;
        int now_i = i;
        int now_j = int(j * per_day + (j_ADD - int(0.5 * num_add_days)) + BEGIN_DAY + 365) % 365;

        if (now_j >= 365) {
         now_j = now_j % 365; 
        }
        if (now_j < 0) {
         now_j = (now_j + 365) % 365; 
        }
        
        if (impacts_source == databaseNumber_CLIMATE_WY2) {
            Pa = CLIMATE_WY2[now_i][now_j][_dirnorrad][now_k]; 
            Pb = CLIMATE_WY2[now_i][now_j][_difhorrad][now_k]; 
            Pc = CLIMATE_WY2[now_i][now_j][_direffect][now_k]; 
            Pd = CLIMATE_WY2[now_i][now_j][_difeffect][now_k]; 
        }
        if (impacts_source == databaseNumber_ENSEMBLE) {
            Pa = ENSEMBLE[now_i][now_j][_dirnorrad][now_k]; 
            Pb = ENSEMBLE[now_i][now_j][_difhorrad][now_k]; 
            Pc = ENSEMBLE[now_i][now_j][_direffect][now_k]; 
            Pd = ENSEMBLE[now_i][now_j][_difeffect][now_k]; 
        }            
        if (impacts_source == databaseNumber_OBSERVED) {
            Pa = OBSERVED[now_i][now_j][_dirnorrad][now_k]; 
            Pb = OBSERVED[now_i][now_j][_difhorrad][now_k]; 
            Pc = OBSERVED[now_i][now_j][_direffect][now_k]; 
            Pd = OBSERVED[now_i][now_j][_difeffect][now_k]; 
        }   
        if (impacts_source == databaseNumber_CLIMATE_EPW) {
            Pa = CLIMATE_EPW[now_i][now_j][_dirnorrad][now_k]; 
            Pb = CLIMATE_EPW[now_i][now_j][_difhorrad][now_k]; 
            Pc = CLIMATE_EPW[now_i][now_j][_direffect][now_k]; 
            Pd = CLIMATE_EPW[now_i][now_j][_difeffect][now_k]; 
        }   
        
        if ((Pa > 0.9 * FLOAT_undefined) || (Pb > 0.9 * FLOAT_undefined) || (Pc > 0.9 * FLOAT_undefined) || (Pd > 0.9 * FLOAT_undefined)) {
        }
        else {
    
          int drw_count = 0;
          if (impacts_source == databaseNumber_CLIMATE_EPW) drw_count = SOLARCHVISION_filter("CLIMATE_EPW", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
          if (impacts_source == databaseNumber_CLIMATE_WY2) drw_count = SOLARCHVISION_filter("CLIMATE_WY2", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
          if (impacts_source == databaseNumber_ENSEMBLE) drw_count = SOLARCHVISION_filter("ENSEMBLE", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
          if (impacts_source == databaseNumber_OBSERVED) drw_count = SOLARCHVISION_filter("OBSERVED", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
          
          if (drw_count == 1) {
            _values_R_dir = 0.001 * Pa;
            _values_R_dif = 0.001 * Pb;
            _values_E_dir = 0.0001 * Pc;
            _values_E_dif = 0.0001 * Pd;
            
            if (_valuesSUM_RAD[(k * num_add_days + j_ADD)] > 0.9 * FLOAT_undefined) {
              _valuesSUM_RAD[(k * num_add_days + j_ADD)] = 0;
              _valuesSUM_EFF[(k * num_add_days + j_ADD)] = 0;
              _valuesNUM[(k * num_add_days + j_ADD)] = 0; 
            }                  
    
            _valuesSUM_RAD[(k * num_add_days + j_ADD)] += ((_values_R_dir * SunR[3]) + (_values_R_dif)); // calculates total horizontal radiation
            _valuesSUM_EFF[(k * num_add_days + j_ADD)] += ((_values_E_dir * SunR[3]) + (_values_E_dif)); // calculates total horizontal effects
            _valuesNUM[(k * num_add_days + j_ADD)] += 1;
          }
        }
      }
    }
  }
  
  if (Impact_TYPE == Impact_PASSIVE) 
    return SOLARCHVISION_FIND_SCENARIOS_CLOSE_TO_NORMALS(_valuesSUM_EFF);
  else 
    return SOLARCHVISION_FIND_SCENARIOS_CLOSE_TO_NORMALS(_valuesSUM_RAD);
}


void SOLARCHVISION_PlotIMPACT (float x_Plot, float y_Plot, float z_Plot, float sx_Plot, float sy_Plot, float sz_Plot) {
  
  Diagrams_pushMatrix();
  Diagrams_translate(x_Plot, y_Plot);

  float pre_per_day = per_day;
  int pre_num_add_days = num_add_days;
  if ((impacts_source == databaseNumber_ENSEMBLE) || (impacts_source == databaseNumber_OBSERVED)) {
    per_day = 1;
    num_add_days = 1;
  }
  
  int start_z = get_startZ_endZ(impacts_source)[0];
  int end_z = get_startZ_endZ(impacts_source)[1]; 
  int layers_count = get_startZ_endZ(impacts_source)[2]; 


  if ((plot_impacts == -2) || (plot_impacts == -1)) {
    if (plot_impacts == -2) Impact_TYPE = Impact_SPD_DIR; 
    if (plot_impacts == -1) Impact_TYPE = Impact_SPD_DIR_TMP;
    
    float Pa = FLOAT_undefined;
    float Pb = FLOAT_undefined;
    float Pc = FLOAT_undefined;

    float[] _values_w_dir;
    float[] _values_w_spd; 
    float[] _values_w_tmp; 
    _values_w_dir = new float[layers_count];
    _values_w_spd = new float[layers_count]; 
    _values_w_tmp = new float[layers_count]; 

    for (int k = 0; k < layers_count; k += 1) { 
      _values_w_dir[k] = FLOAT_undefined;
      _values_w_spd[k] = FLOAT_undefined;
      _values_w_tmp[k] = FLOAT_undefined;
    }

    int PAL_TYPE = 0; 
    int PAL_DIR = 1;
    
    if (Impact_TYPE == Impact_SPD_DIR) {  
      PAL_TYPE = Pallet_ACTIVE; PAL_DIR = Pallet_ACTIVE_DIR;
    }
    if (Impact_TYPE == Impact_SPD_DIR_TMP) {  
      PAL_TYPE = Pallet_ACTIVE; PAL_DIR = Pallet_ACTIVE_DIR;
    }             

    float _Multiplier = 1; 
    if (Impact_TYPE == Impact_SPD_DIR) _Multiplier = 1.0;
    if (Impact_TYPE == Impact_SPD_DIR_TMP) _Multiplier = 1.0 / 30.0;

    for (int j_ADD = 0; j_ADD < num_add_days; j_ADD += 1) {
      for (int j = j_start; j < j_end; j += 1) { 
        for (int i = 0; i < 24; i += 1) {
          for (int k = (start_z - 1); k <= (end_z - 1); k += 1) {
  
            _values_w_dir[k] = FLOAT_undefined;
            _values_w_spd[k] = FLOAT_undefined;
            _values_w_tmp[k] = FLOAT_undefined;
           
            int _plot = 1;
            
            if (_plot == 1) {
              
              int now_k = k;
              int now_i = i;
              int now_j = int(j * per_day + (j_ADD - int(0.5 * num_add_days)) + BEGIN_DAY + 365) % 365;
  
              if (now_j >= 365) {
               now_j = now_j % 365; 
              }
              if (now_j < 0) {
               now_j = (now_j + 365) % 365; 
              }



              if (impacts_source == databaseNumber_CLIMATE_WY2) {
                  Pa = CLIMATE_WY2[now_i][now_j][_winddir][now_k]; 
                  Pb = CLIMATE_WY2[now_i][now_j][_windspd][now_k]; 
                  Pc = CLIMATE_WY2[now_i][now_j][_drybulb][now_k];
              }
              if (impacts_source == databaseNumber_ENSEMBLE) {
                  Pa = ENSEMBLE[now_i][now_j][_winddir][now_k]; 
                  Pb = ENSEMBLE[now_i][now_j][_windspd][now_k]; 
                  Pc = ENSEMBLE[now_i][now_j][_drybulb][now_k];
              }            
              if (impacts_source == databaseNumber_OBSERVED) {
                  Pa = OBSERVED[now_i][now_j][_winddir][now_k]; 
                  Pb = OBSERVED[now_i][now_j][_windspd][now_k]; 
                  Pc = OBSERVED[now_i][now_j][_drybulb][now_k];
              }   
              if (impacts_source == databaseNumber_CLIMATE_EPW) {
                  Pa = CLIMATE_EPW[now_i][now_j][_winddir][now_k]; 
                  Pb = CLIMATE_EPW[now_i][now_j][_windspd][now_k]; 
                  Pc = CLIMATE_EPW[now_i][now_j][_drybulb][now_k];
              }   
              
              if (Pa > 0.9 * FLOAT_undefined || Pb > 0.9 * FLOAT_undefined || Pc > 0.9 * FLOAT_undefined) {
                _values_w_dir[k] = FLOAT_undefined;
                _values_w_spd[k] = FLOAT_undefined;
                _values_w_tmp[k] = FLOAT_undefined;
              }
              else {
                int drw_count = 0;
                if (impacts_source == databaseNumber_CLIMATE_EPW) drw_count = SOLARCHVISION_filter("CLIMATE_EPW", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                if (impacts_source == databaseNumber_CLIMATE_WY2) drw_count = SOLARCHVISION_filter("CLIMATE_WY2", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                if (impacts_source == databaseNumber_ENSEMBLE) drw_count = SOLARCHVISION_filter("ENSEMBLE", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                if (impacts_source == databaseNumber_OBSERVED) drw_count = SOLARCHVISION_filter("OBSERVED", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                    
                if ((impacts_source == databaseNumber_ENSEMBLE) && (ENSEMBLE_DATA[now_i][now_j][_winddir][now_k] != 1)) drw_count = 0;
                  
                if (drw_count == 1) {

                  _values_w_dir[k] = Pa;
                  _values_w_spd[k] = Pb;
                  _values_w_tmp[k] = Pc;
            
                  float T = _values_w_tmp[k];
                  float teta = _values_w_dir[k];
                  float D_teta = 15; 
                  float R = GRAPHS_V_scale[_windspd] * _values_w_spd[k] * 45 / 50.0;
                  
                  float R_in = 0.75 * R; 
                  float x1 = (j + obj_offset_x + obj_scale * R_in * cos_ang(90 - (teta - 0.5 * D_teta))) * sx_Plot;
                  float y1 = (                   obj_scale * R_in * -sin_ang(90 - (teta - 0.5 * D_teta))) * sx_Plot;
                  float x2 = (j + obj_offset_x + obj_scale * R_in * cos_ang(90 - (teta + 0.5 * D_teta))) * sx_Plot;
                  float y2 = (                   obj_scale * R_in * -sin_ang(90 - (teta + 0.5 * D_teta))) * sx_Plot; 
             
                  float x4 = (j + obj_offset_x + obj_scale * R * cos_ang(90 - (teta - 0.5 * D_teta))) * sx_Plot;
                  float y4 = (                   obj_scale * R * -sin_ang(90 - (teta - 0.5 * D_teta))) * sx_Plot;
                  float x3 = (j + obj_offset_x + obj_scale * R * cos_ang(90 - (teta + 0.5 * D_teta))) * sx_Plot;
                  float y3 = (                   obj_scale * R * -sin_ang(90 - (teta + 0.5 * D_teta))) * sx_Plot;
       
                  float _u = 0;
                   
       
                  if (Impact_TYPE == Impact_SPD_DIR) {

                    float _s = (GRAPHS_O_scale / 100) * 255 / (0.333 * layers_count); 

                    if (sky_scenario > 1) _s *= 3; // to improve visibility of those cases.
                    
                    _s /= float(num_add_days);
                    
                    if (_s < 10) _s = 10;
                    
                    Diagrams_stroke(0, _s);
                    Diagrams_fill(0, _s); 

                    Diagrams_strokeWeight(GRAPHS_T_scale * 0);
                  }
                  if (Impact_TYPE == Impact_SPD_DIR_TMP) {
                    _u = 0.5 + 0.5 * (_Multiplier * T);
                    
                    if (PAL_DIR == -1) _u = 1 - _u;
                    if (PAL_DIR == -2) _u = 0.5 - 0.5 * _u;
                    if (PAL_DIR == 2) _u =  0.5 * _u;
                    
                    SET_COLOR_STYLE(PAL_TYPE, _u);
                    
                    Diagrams_strokeWeight(GRAPHS_T_scale * 1);
                    Diagrams_noFill(); 
                  }
                  
                  Diagrams_quad(x1, y1, x2, y2, x3, y3, x4, y4);
                  
                  if (draw_impact_summary == 1) { 
                    
                    if (Impact_TYPE == Impact_SPD_DIR) {

                      float _s = (GRAPHS_O_scale / 100) * 255 / (0.333 * layers_count) / (j_end - j_start);
  
                      if (sky_scenario > 1) _s *= 3; // to improve visibility of those cases.
                      
                      _s /= float(num_add_days);
                      
                      if (_s < 10) _s = 10;
                      
                      Diagrams_stroke(0, _s);
                      Diagrams_fill(0, _s); 
  
                      Diagrams_strokeWeight(GRAPHS_T_scale * 0);
                    }
                    
                    x1 -= (j + 1) * sx_Plot;
                    x2 -= (j + 1) * sx_Plot;
                    x3 -= (j + 1) * sx_Plot;
                    x4 -= (j + 1) * sx_Plot;
                    
                    Diagrams_quad(x1, y1, x2, y2, x3, y3, x4, y4);
                    
                  }
                }
              }
            }
          }
        }
      }
    }
    
    SOLARCHVISION_draw_Grid_Spherical_POSITION(x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot, 0);
    
    if (draw_impact_summary == 1) {
      int j = -1; // << to put the summary graph before the daily graphs
      
      int pre_j_start = j_start;
      int pre_j_end = j_end;
      j_start = j;
      j_end = j + 1;
      SOLARCHVISION_draw_Grid_Spherical_POSITION(x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot, 0);
      j_start = pre_j_start;
      j_end = pre_j_end;

      Diagrams_strokeWeight(GRAPHS_T_scale * 2);
      Diagrams_stroke(0);
      Diagrams_noFill(); 
      Diagrams_rect((j + obj_offset_x - 100 * obj_scale) * sx_Plot, (-100 * obj_scale) * sx_Plot, (200 * obj_scale) * sx_Plot, (200 * obj_scale) * sx_Plot);      
    }
    
    if (Impact_TYPE != Impact_SPD_DIR) { 
      
      float pal_length = 400;
      for (int q = 0; q < 11; q += 1) {
        float _u = 0;
      
        if (Impact_TYPE == Impact_SPD_DIR_TMP) _u = 0.1 * q;
        
        if (PAL_DIR == -1) _u = 1 - _u;
        if (PAL_DIR == -2) _u = 0.5 - 0.5 * _u;
        if (PAL_DIR == 2) _u =  0.5 * _u;
        
        SET_COLOR_STYLE(PAL_TYPE, _u); 
        
        Diagrams_strokeWeight(0);
        Diagrams_rect((700 + q * (pal_length / 11.0)) * GRAPHS_S_View, -175 * GRAPHS_S_View, (pal_length / 11.0) * GRAPHS_S_View, 20 * GRAPHS_S_View); 

        Diagrams_strokeWeight(2);
        Diagrams_stroke(255);
        Diagrams_fill(255); 
        Diagrams_textSize(15.0 * GRAPHS_S_View);
        Diagrams_textAlign(CENTER, CENTER);

        if (Impact_TYPE == Impact_SPD_DIR_TMP) my_text(nf(0.2 * (q - 5) / _Multiplier, 1, 1), (20 + 700 + q * (pal_length / 11.0)) * GRAPHS_S_View, (10 - 175 - 0.05 * 20) * GRAPHS_S_View, 1 * GRAPHS_S_View);
      }
    }         


    if (GRAPHS_print_title != 0) {
    
      Diagrams_stroke(0); 
      Diagrams_fill(0);
      Diagrams_strokeWeight(GRAPHS_T_scale * 0);
      
      Diagrams_textSize(sx_Plot * 0.150 / GRAPHS_U_scale);
      Diagrams_textAlign(RIGHT, CENTER); 
      //if (impacts_source == databaseNumber_CLIMATE_WY2) my_text(("[" + String.valueOf(start_z + CLIMATE_WY2_start - 1) + "-" + String.valueOf(end_z + CLIMATE_WY2_start - 1) + "] "), 0, 1.3 * sx_Plot / GRAPHS_U_scale, 0);
      //if (impacts_source == databaseNumber_ENSEMBLE) //my_text(("[Members:" + String.valueOf(start_z) + "-" + String.valueOf(end_z) + "] "), 0, 1.3 * sx_Plot / GRAPHS_U_scale, 0);
      
      Diagrams_textSize(sx_Plot * 0.150 / GRAPHS_U_scale);
      Diagrams_textAlign(LEFT, CENTER); 
      if (Impact_TYPE == Impact_SPD_DIR) {  
        my_text(("Wind direction and speed"), 0, 1.3 * sx_Plot / GRAPHS_U_scale, 0);
        //?? French
      }
      if (Impact_TYPE == Impact_SPD_DIR_TMP) {  
        my_text(("Wind direction and speed with air temperature"), 0, 1.3 * sx_Plot / GRAPHS_U_scale, 0);
        //?? French
      }           
    }
  } 




  
  if ((plot_impacts == 0) || (plot_impacts == 1)) {

    if (plot_impacts == 0) Impact_TYPE = Impact_ACTIVE; 
    if (plot_impacts == 1) Impact_TYPE = Impact_PASSIVE;
    
    int RES1 = 200;
    int RES2 = 200;

    float Pa = FLOAT_undefined;
    float Pb = FLOAT_undefined;
    float Pc = FLOAT_undefined;
    float Pd = FLOAT_undefined;
    
    float _values_R_dir;
    float _values_R_dif;
    
    float _values_E_dir;
    float _values_E_dif;
    
    int now_k = 0;
    int now_i = 0;
    int now_j = 0;

    int PAL_TYPE = 0; 
    int PAL_DIR = 1;
    
    if (Impact_TYPE == Impact_ACTIVE) {  
      PAL_TYPE = 15; PAL_DIR = 1;
      
    }
    if (Impact_TYPE == Impact_PASSIVE) {  
      PAL_TYPE = Pallet_PASSIVE; PAL_DIR = Pallet_PASSIVE_DIR;
    }             
    
    float _Multiplier = 1; 
    if (Impact_TYPE == Impact_ACTIVE) _Multiplier = 0.1; 
    if (Impact_TYPE == Impact_PASSIVE) _Multiplier = 0.02; 

    //for (int p = 0; p < 3; p += 1) { 
      //int l = 3 * int(impact_layer / 3) + p;

    //for (int p = 0; p < 3; p += 2) { 
      //int l = 3 * int(impact_layer / 3) + p;
      
    for (int p = 0; p < 1; p += 1) { 
      int l = impact_layer;

      
      PImage total_Image_RGBA = createImage(RES1, RES2, RGB);
      
      float[][][] total_Matrix_ARGB;
      total_Matrix_ARGB = new float[4][RES1][RES2];

      for (int np = 0; np < (RES1 * RES2); np++) {
        int Image_X = np % RES1;
        int Image_Y = np / RES1;
        
        total_Matrix_ARGB[0][Image_X][Image_Y] = 0;
        total_Matrix_ARGB[1][Image_X][Image_Y] = 0;
        total_Matrix_ARGB[2][Image_X][Image_Y] = 0;
        total_Matrix_ARGB[3][Image_X][Image_Y] = 0; 
      }

      for (int j = j_start; j < j_end; j += 1) {
      //for (int j = j_start; j <= j_start; j += 1) {

        now_j = (j * int(per_day) + BEGIN_DAY + 365) % 365;
    
        if (now_j >= 365) {
         now_j = now_j % 365; 
        }
        if (now_j < 0) {
         now_j = (now_j + 365) % 365; 
        }
 
        float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0); 

        int DATE_ANGLE_approximate = int((DATE_ANGLE + 15) / 30) * 30;
        if (DATE_ANGLE_approximate == 360) DATE_ANGLE_approximate = 0;
        
        float _sunrise = SOLARCHVISION_Sunrise(LocationLatitude, DATE_ANGLE); 
        float _sunset = SOLARCHVISION_Sunset(LocationLatitude, DATE_ANGLE);
        
        //println(DATE_ANGLE, DATE_ANGLE_approximate);

        int[] Normals_COL_N;
        Normals_COL_N = new int[9];
        Normals_COL_N = SOLARCHVISION_PROCESS_DAILY_SCENARIOS(layers_count, start_z, end_z, j, DATE_ANGLE);
        
        //println("j =", j);
        //println(Normals_COL_N);
        
        for (int nk = Normals_COL_N[l]; nk <= Normals_COL_N[l]; nk += 1) {
          if (nk != -1) {
            int k = int(nk / num_add_days);
            int j_ADD = nk % num_add_days; 

            float[][][] Matrix_ARGB;
            
            Matrix_ARGB = new float[4][RES1][RES2];

            for (int np = 0; np < (RES1 * RES2); np++) {
              int Image_X = np % RES1;
              int Image_Y = np / RES1;
              
              Matrix_ARGB[0][Image_X][Image_Y] = FLOAT_undefined;
              Matrix_ARGB[1][Image_X][Image_Y] = FLOAT_undefined;
              Matrix_ARGB[2][Image_X][Image_Y] = FLOAT_undefined;
              Matrix_ARGB[3][Image_X][Image_Y] = FLOAT_undefined;
            }

            PImage Image_RGBA = createImage(RES1, RES2, RGB);

            for (int i = 4; i <= 20; i += 1) { // to make it faster. Also the images are not available out of this period. 

              float HOUR_ANGLE = i; 
              float[] SunR = SOLARCHVISION_SunPosition(LocationLatitude, DATE_ANGLE, HOUR_ANGLE);

              now_k = k;
              now_i = i;
              now_j = int(j * per_day + (j_ADD - int(0.5 * num_add_days)) + BEGIN_DAY + 365) % 365;
  
              if (now_j >= 365) {
               now_j = now_j % 365; 
              }
              if (now_j < 0) {
               now_j = (now_j + 365) % 365; 
              }

              if (impacts_source == databaseNumber_CLIMATE_WY2) {
                  Pa = CLIMATE_WY2[now_i][now_j][_dirnorrad][now_k]; 
                  Pb = CLIMATE_WY2[now_i][now_j][_difhorrad][now_k]; 
                  Pc = CLIMATE_WY2[now_i][now_j][_direffect][now_k]; 
                  Pd = CLIMATE_WY2[now_i][now_j][_difeffect][now_k]; 
              }
              if (impacts_source == databaseNumber_ENSEMBLE) {
                  Pa = ENSEMBLE[now_i][now_j][_dirnorrad][now_k]; 
                  Pb = ENSEMBLE[now_i][now_j][_difhorrad][now_k]; 
                  Pc = ENSEMBLE[now_i][now_j][_direffect][now_k]; 
                  Pd = ENSEMBLE[now_i][now_j][_difeffect][now_k]; 
              }            
              if (impacts_source == databaseNumber_OBSERVED) {
                  Pa = OBSERVED[now_i][now_j][_dirnorrad][now_k]; 
                  Pb = OBSERVED[now_i][now_j][_difhorrad][now_k]; 
                  Pc = OBSERVED[now_i][now_j][_direffect][now_k]; 
                  Pd = OBSERVED[now_i][now_j][_difeffect][now_k]; 
              }   
              if (impacts_source == databaseNumber_CLIMATE_EPW) {
                  Pa = CLIMATE_EPW[now_i][now_j][_dirnorrad][now_k]; 
                  Pb = CLIMATE_EPW[now_i][now_j][_difhorrad][now_k]; 
                  Pc = CLIMATE_EPW[now_i][now_j][_direffect][now_k]; 
                  Pd = CLIMATE_EPW[now_i][now_j][_difeffect][now_k]; 
              }   

              if ((Pa > 0.9 * FLOAT_undefined) || (Pb > 0.9 * FLOAT_undefined) || (Pc > 0.9 * FLOAT_undefined) || (Pd > 0.9 * FLOAT_undefined)) {
                _values_R_dir = FLOAT_undefined;
                _values_R_dif = FLOAT_undefined;
                _values_E_dir = FLOAT_undefined;
                _values_E_dif = FLOAT_undefined; 
              }
              else {
  
                int drw_count = 0;
                if (impacts_source == databaseNumber_CLIMATE_EPW) drw_count = SOLARCHVISION_filter("CLIMATE_EPW", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                if (impacts_source == databaseNumber_CLIMATE_WY2) drw_count = SOLARCHVISION_filter("CLIMATE_WY2", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                if (impacts_source == databaseNumber_ENSEMBLE) drw_count = SOLARCHVISION_filter("ENSEMBLE", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                if (impacts_source == databaseNumber_OBSERVED) drw_count = SOLARCHVISION_filter("OBSERVED", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                
                if (drw_count == 1) {
                  _values_R_dir = 0.001 * Pa;  
                  _values_R_dif = 0.001 * Pb; 
                  _values_E_dir = 0.001 * Pc;
                  _values_E_dif = 0.001 * Pd;
                  
                  for (int RAD_TYPE = 0; RAD_TYPE <= 1; RAD_TYPE += 1) { 
                    float RAD_VALUE = 0;
                    float EFF_VALUE = 0;
                    if (RAD_TYPE == 0) {
                      RAD_VALUE = _values_R_dir; 
                      EFF_VALUE = _values_E_dir;
                    }
                    else { 
                      //float MULT_dif = SOLARCHVISION_DayTime(LocationLatitude, DATE_ANGLE) / 5.0; //(2 * PI); // base on the adjustments
                      //float MULT_dif = int(SOLARCHVISION_DayTime(LocationLatitude, DATE_ANGLE)) / 5.0; //(2 * PI); // base on the adjustments
                      float MULT_dif = 2.0;
                      
                      RAD_VALUE = _values_R_dif * MULT_dif;
                      EFF_VALUE = _values_E_dif * MULT_dif;
                    }

                    PImage[] Shadings = new PImage[2];
                    for (int SHD = 0; SHD <= 1; SHD += 1) {
                      String[] STR_SHD = {"F" , "T"};
                      String File_Name = "";
                      
                      int Round_Latitude = int(roundTo(LocationLatitude, 5));
                      if (Round_Latitude > 60) Round_Latitude = 60; // <<<<<<<<<<<<<<<
                      if (Round_Latitude < -45) Round_Latitude = -45; // <<<<<<<<<<<<<<<
                      String Near_Latitude = nf(abs(Round_Latitude), 2);
                      
                      if (Round_Latitude < 0) Near_Latitude += "S";
                      else Near_Latitude += "N";


                      if (DEFINED_STATIONS[STATION_NUMBER][1].equals("Financial_District")) { 
                        File_Name = "C:/SOLARCHVISION_2015/Input/ShadingAnalysis/" + "Financial_District" + "/";
                      }   
                      else if (DEFINED_STATIONS[STATION_NUMBER][1].equals("Ryerson_University")) { 
                        File_Name = "C:/SOLARCHVISION_2015/Input/ShadingAnalysis/" + "Ryerson_University" + "/";
                      }   
                      else if (DEFINED_STATIONS[STATION_NUMBER][1].equals("Place_Bonaventure")) { 
                        File_Name = "C:/SOLARCHVISION_2015/Input/ShadingAnalysis/" + "Place_Bonaventure" + "/";
                      }                      
                      else if (DEFINED_STATIONS[STATION_NUMBER][1].equals("Montreal_Downtown")) { 
                        if (camera_variation == 1) File_Name = "C:/SOLARCHVISION_2015/Input/ShadingAnalysis/MONTREAL_DOWNTOWN" + "/";
                        if (camera_variation == 2) File_Name = "C:/SOLARCHVISION_2015/Input/ShadingAnalysis/EV_BUILDING" + "/";
                      }
                      else {
                        File_Name = "C:/SOLARCHVISION_2015/Input/ShadingAnalysis/Complex_" + Near_Latitude + "/";
                      }                          
                      
                      
                      if (RAD_TYPE == 0) {
                        File_Name += nf(DATE_ANGLE_approximate, 3) + "_" + STR_SHD[SHD] + "_" + nf(int(roundTo(HOUR_ANGLE * 100, 1.0)), 4);
                      }
                      else {
                        File_Name += "DIF_" + STR_SHD[SHD];
                      }
                      
                      
                      if (DEFINED_STATIONS[STATION_NUMBER][1].equals("Financial_District")) { 
                        File_Name += "_" + "Financial_District" + "_Camera" + nf(camera_variation, 2) + ".PNG";
                      }    
                      else if (DEFINED_STATIONS[STATION_NUMBER][1].equals("Ryerson_University")) { 
                        File_Name += "_" + "Ryerson_University" + "_Camera" + nf(camera_variation, 2) + ".PNG";
                      }    
                      else if (DEFINED_STATIONS[STATION_NUMBER][1].equals("Place_Bonaventure")) { 
                        File_Name += "_" + "Place_Bonaventure" + "_Camera" + nf(camera_variation, 2) + ".PNG";
                      }                      
                      else if (DEFINED_STATIONS[STATION_NUMBER][1].equals("Montreal_Downtown")) { 
                        if (camera_variation == 1) File_Name += "_" + "Montreal_Downtown.PNG";
                        if (camera_variation == 2) File_Name += "_" + "Montreal_EV_BUILDING_B.PNG";
                      }
                      else {
                        File_Name += "_" + "Complex_" + Near_Latitude + "_Camera" + nf(camera_variation, 2) + ".PNG";
                      }

                      //println (File_Name);
                      Shadings[SHD]  = loadImage(File_Name);
                    }   
   
                    for (int np = 0; np < (RES1 * RES2); np++) {
                      int Image_X = np % RES1;
                      int Image_Y = np / RES1;
                      
                      if (Matrix_ARGB[0][Image_X][Image_Y] > 0.9 * FLOAT_undefined) {
                        Matrix_ARGB[0][Image_X][Image_Y] = 0;
                        Matrix_ARGB[1][Image_X][Image_Y] = 0;
                        Matrix_ARGB[2][Image_X][Image_Y] = 0;
                        Matrix_ARGB[3][Image_X][Image_Y] = 0;
                      }                             
              
                      color COL0 = Shadings[0].get(Image_X, Image_Y);
                      color COL1 = Shadings[1].get(Image_X, Image_Y);
                      //red: COL >> 16 & 0xFF; green: COL >>8 & 0xFF; blue: COL & 0xFF;
                      float COL_V0 = (COL0 >> 8 & 0xFF) / 255.0; 
                      float COL_V1 = (COL1 >> 8 & 0xFF) / 255.0;
                     
                      float COL_Alpha = (COL1 >> 24 & 0xFF);
                      
                      Matrix_ARGB[0][Image_X][Image_Y] = COL_Alpha;
                      
                      if (Impact_TYPE == Impact_ACTIVE) {  
                        Matrix_ARGB[2][Image_X][Image_Y] += RAD_VALUE * COL_V1;
                      }
                      if (Impact_TYPE == Impact_PASSIVE) {
                        if (EFF_VALUE < 0) {
                          Matrix_ARGB[1][Image_X][Image_Y] -= EFF_VALUE * COL_V1;
                          if (COL_V0 != COL_V1) Matrix_ARGB[3][Image_X][Image_Y] -= EFF_VALUE * (COL_V0 - COL_V1); 
                        }
                        else {
                          Matrix_ARGB[3][Image_X][Image_Y] += EFF_VALUE * COL_V1;
                          if (COL_V0 != COL_V1) Matrix_ARGB[1][Image_X][Image_Y] += EFF_VALUE * (COL_V0 - COL_V1);
                        }
                      }

                    }
                  }
                }
              }
            }
  
           
            Image_RGBA.loadPixels();
  
            for (int np = 0; np < (RES1 * RES2); np++) {
              int Image_X = np % RES1;
              int Image_Y = np / RES1;
  
              float Image_A = Matrix_ARGB[0][Image_X][Image_Y];
              float Image_R = Matrix_ARGB[1][Image_X][Image_Y];
              float Image_G = Matrix_ARGB[2][Image_X][Image_Y];
              float Image_B = Matrix_ARGB[3][Image_X][Image_Y];
              
              total_Matrix_ARGB[0][Image_X][Image_Y] += Image_A;
              total_Matrix_ARGB[1][Image_X][Image_Y] += Image_R;
              total_Matrix_ARGB[2][Image_X][Image_Y] += Image_G;
              total_Matrix_ARGB[3][Image_X][Image_Y] += Image_B; 

             
              float[] _c = {0, 0, 0, 0};
              
              float _u = 0;
              
              float _valuesSUM = FLOAT_undefined;
              
              if (Impact_TYPE == Impact_ACTIVE) {
                _valuesSUM = Image_G;
                _u = (_Multiplier * _valuesSUM);
              }
           
              if (Impact_TYPE == Impact_PASSIVE) {
                float AVERAGE, PERCENTAGE, COMPARISON;
                
                AVERAGE = (Image_B - Image_R);
                if ((Image_B + Image_R) > 0.00001) PERCENTAGE = (Image_B - Image_R) / (1.0 * (Image_B + Image_R)); 
                else PERCENTAGE = 0.0;
                COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);
                
                _valuesSUM = COMPARISON;
                _u = 0.5 + 0.5 * 0.75 * (_Multiplier * _valuesSUM);
              }
              
              
              //if ((Image_X == RES1 / 2) && (Image_Y == RES2 / 2)) println("Image Processing: <CENTER> _valuesSUM =", _valuesSUM); 
              //if ((Image_X == RES1 - 1) && (Image_Y == RES2 - 1)) println("Image Processing: <CORNER> _valuesSUM =", _valuesSUM); 
              
              if (PAL_DIR == -1) _u = 1 - _u;
              if (PAL_DIR == -2) _u = 0.5 - 0.5 * _u;
              if (PAL_DIR == 2) _u =  0.5 * _u;
              
              _c = GET_COLOR_STYLE(PAL_TYPE, _u);
              
              if (Image_A != 0) Image_RGBA.pixels[np] = color(_c[1], _c[2], _c[3]);
              else Image_RGBA.pixels[np] = color(223, 223, 223);
  
            }
          
            Image_RGBA.updatePixels(); 
           
            Diagrams_strokeWeight(GRAPHS_T_scale * 0);
            Diagrams_stroke(223);
            Diagrams_fill(223); 
            Diagrams_rect((j + obj_offset_x - 100 * obj_scale) * sx_Plot, (-100 * obj_scale) * sx_Plot - (1 * p * sx_Plot / GRAPHS_U_scale), (200 * obj_scale) * sx_Plot, (200 * obj_scale) * sx_Plot);

          
            Diagrams_strokeWeight(GRAPHS_T_scale * 2);
            Diagrams_stroke(255);
            Diagrams_noFill(); 
            Diagrams_rect((j + obj_offset_x - 100 * obj_scale) * sx_Plot, (-100 * obj_scale) * sx_Plot - (1 * p * sx_Plot / GRAPHS_U_scale), (200 * obj_scale) * sx_Plot, (200 * obj_scale) * sx_Plot);
      
      
            Diagrams_imageMode(CENTER); 
            Diagrams_image(Image_RGBA, (j + 100 * obj_scale) * sx_Plot, - (1 * p * sx_Plot / GRAPHS_U_scale), int((180 * obj_scale) * sx_Plot), int((180 * obj_scale) * sx_Plot));
            
  
            Diagrams_stroke(0);
            Diagrams_fill(0);
            Diagrams_textAlign(CENTER, CENTER); 
            Diagrams_textSize(sx_Plot * 0.15 / GRAPHS_U_scale);
            
            String scenario_text = "";
            //if (impacts_source == databaseNumber_CLIMATE_WY2) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_WY2_start - 1, 0);
            //if (impacts_source == databaseNumber_ENSEMBLE) scenario_text += "Member: " + nf(Normals_COL_N[l], 0);
            my_text(scenario_text, (j - ((0 - 12) / 24.0)) * sx_Plot, (0.9 - 1 * (p - 0.25)) * sx_Plot / GRAPHS_U_scale, 0);
            
          }
        }
      }
      
      if (draw_impact_summary == 1) { 
        int j = -1; // << to put the summary graph before the daily graphs
        
        total_Image_RGBA.loadPixels();
        
        for (int np = 0; np < (RES1 * RES2); np++) {
          int Image_X = np % RES1;
          int Image_Y = np / RES1;
        
          float Image_A = total_Matrix_ARGB[0][Image_X][Image_Y] / (1.0 * (j_end - j_start));
          float Image_R = total_Matrix_ARGB[1][Image_X][Image_Y] / (1.0 * (j_end - j_start));
          float Image_G = total_Matrix_ARGB[2][Image_X][Image_Y] / (1.0 * (j_end - j_start));
          float Image_B = total_Matrix_ARGB[3][Image_X][Image_Y] / (1.0 * (j_end - j_start));
         
          float[] _c = {0, 0, 0, 0};
          
          float _u = 0;
          
          float _valuesSUM = FLOAT_undefined;
          
          if (Impact_TYPE == Impact_ACTIVE) {
            _valuesSUM = Image_G;
            _u = (_Multiplier * _valuesSUM);
          }
         
          if (Impact_TYPE == Impact_PASSIVE) {
            float AVERAGE, PERCENTAGE, COMPARISON;
            
            AVERAGE = (Image_B - Image_R);
            if ((Image_B + Image_R) > 0.00001) PERCENTAGE = (Image_B - Image_R) / (1.0 * (Image_B + Image_R)); 
            else PERCENTAGE = 0.0;
            COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);
            
            _valuesSUM = COMPARISON;
            _u = 0.5 + 0.5 * 0.75 * (_Multiplier * _valuesSUM);
          }
          
          if (PAL_DIR == -1) _u = 1 - _u;
          if (PAL_DIR == -2) _u = 0.5 - 0.5 * _u;
          if (PAL_DIR == 2) _u =  0.5 * _u;
          
          _c = GET_COLOR_STYLE(PAL_TYPE, _u);
          
          if (Image_A != 0) total_Image_RGBA.pixels[np] = color(_c[1], _c[2], _c[3]);
          else total_Image_RGBA.pixels[np] = color(223, 223, 223);
        
        }
        
        total_Image_RGBA.updatePixels(); 

        Diagrams_strokeWeight(GRAPHS_T_scale * 0);
        Diagrams_stroke(223);
        Diagrams_fill(223); 
        Diagrams_rect((j + obj_offset_x - 100 * obj_scale) * sx_Plot, (-100 * obj_scale) * sx_Plot - (1 * p * sx_Plot / GRAPHS_U_scale), (200 * obj_scale) * sx_Plot, (200 * obj_scale) * sx_Plot);
        
        
        Diagrams_strokeWeight(GRAPHS_T_scale * 2);
        Diagrams_stroke(0);
        Diagrams_noFill(); 
        Diagrams_rect((j + obj_offset_x - 100 * obj_scale) * sx_Plot, (-100 * obj_scale) * sx_Plot - (1 * p * sx_Plot / GRAPHS_U_scale), (200 * obj_scale) * sx_Plot, (200 * obj_scale) * sx_Plot);
        
        
        Diagrams_imageMode(CENTER); 
        Diagrams_image(total_Image_RGBA, (j + 100 * obj_scale) * sx_Plot, - (1 * p * sx_Plot / GRAPHS_U_scale), int((180 * obj_scale) * sx_Plot), int((180 * obj_scale) * sx_Plot));
        
        
        Diagrams_stroke(0);
        Diagrams_fill(0);
        Diagrams_textAlign(CENTER, CENTER); 
        Diagrams_textSize(sx_Plot * 0.15 / GRAPHS_U_scale);
      }
      
      String scenario_text = "";
      //if (impacts_source == databaseNumber_CLIMATE_WY2) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_WY2_start - 1, 0);
      //if (impacts_source == databaseNumber_ENSEMBLE) scenario_text += "Member: " + nf(Normals_COL_N[l], 0);
      my_text(scenario_text, ((j_start - 1) - ((0 - 12) / 24.0)) * sx_Plot, (0.9 - 1 * (p - 0.25)) * sx_Plot / GRAPHS_U_scale, 0);

      Diagrams_textSize(sx_Plot * 0.15 / GRAPHS_U_scale);
      Diagrams_textAlign(RIGHT, CENTER); 
      Diagrams_stroke(0);
      Diagrams_fill(0);
      Diagrams_strokeWeight(0); 

      Diagrams_textSize(sx_Plot * 0.15 / GRAPHS_U_scale);
      Diagrams_textAlign(RIGHT, CENTER); 
      Diagrams_stroke(0);
      Diagrams_fill(0);
      Diagrams_strokeWeight(0); 
      
      if (Impact_TYPE == Impact_ACTIVE) {  
        my_text(N_Title[l], 0, - (1 * p * sx_Plot / GRAPHS_U_scale), 0);
      }
      if (Impact_TYPE == Impact_PASSIVE) {  
        my_text(N_Title[reverse_N[l]], 0, - (1 * p * sx_Plot / GRAPHS_U_scale), 0);
      }            
      //?? French

    }      

    float pal_length = 400;
    for (int q = 0; q < 11; q += 1) {
      float _u = 0;
      
      if (Impact_TYPE == Impact_ACTIVE) _u = 0.1 * q;
      if (Impact_TYPE == Impact_PASSIVE) {
        _u = 0.2 * q - 0.5;
        _u = (_u - 0.5) * 0.75 + 0.5;
      }        
      
      if (PAL_DIR == -1) _u = 1 - _u;
      if (PAL_DIR == -2) _u = 0.5 - 0.5 * _u;
      if (PAL_DIR == 2) _u =  0.5 * _u;
      
      SET_COLOR_STYLE(PAL_TYPE, _u); 
      
      Diagrams_strokeWeight(0);
      Diagrams_rect((700 + q * (pal_length / 11.0)) * GRAPHS_S_View, -175 * GRAPHS_S_View, (pal_length / 11.0) * GRAPHS_S_View, 20 * GRAPHS_S_View); 

      Diagrams_strokeWeight(2);
      Diagrams_stroke(255);
      Diagrams_fill(255); 
      Diagrams_textSize(15.0 * GRAPHS_S_View);
      Diagrams_textAlign(CENTER, CENTER);
      if (Impact_TYPE == Impact_ACTIVE) my_text(nf((roundTo(0.1 * q / _Multiplier, 0.1)), 1, 1), (20 + 700 + q * (pal_length / 11.0)) * GRAPHS_S_View, (10 - 175 - 0.05 * 20) * GRAPHS_S_View, 1 * GRAPHS_S_View);
      if (Impact_TYPE == Impact_PASSIVE) my_text(nf(int(roundTo(0.4 * (q - 5) / _Multiplier, 1)), 1), (20 + 700 + q * (pal_length / 11.0)) * GRAPHS_S_View, (10 - 175 - 0.05 * 20) * GRAPHS_S_View, 1 * GRAPHS_S_View);
    }

    if (GRAPHS_print_title != 0) {
    
      Diagrams_stroke(0); 
      Diagrams_fill(0);
      Diagrams_strokeWeight(GRAPHS_T_scale * 0);
      
      Diagrams_textSize(sx_Plot * 0.150 / GRAPHS_U_scale);
      Diagrams_textAlign(RIGHT, CENTER); 
      //if (impacts_source == databaseNumber_CLIMATE_WY2) my_text(("[" + String.valueOf(start_z + CLIMATE_WY2_start - 1) + "-" + String.valueOf(end_z + CLIMATE_WY2_start - 1) + "] "), 0, 1.3 * sx_Plot / GRAPHS_U_scale, 0);
      //if (impacts_source == databaseNumber_ENSEMBLE) //my_text(("[Members:" + String.valueOf(start_z) + "-" + String.valueOf(end_z) + "] "), 0, 1.3 * sx_Plot / GRAPHS_U_scale, 0);

      String Model_Description = "";
      //if (camera_variation == 1) Model_Description = "TR: Place-des-Arts";
      //if (camera_variation == 2) Model_Description = "EV_BUILDING";

      Diagrams_textSize(sx_Plot * 0.150 / GRAPHS_U_scale);
      Diagrams_textAlign(LEFT, TOP); 
      if (Impact_TYPE == Impact_ACTIVE) {  
        my_text((Model_Description + "Analysis of Active Potentials (kWh/m²/day)"), 0, 1.25 * sx_Plot / GRAPHS_U_scale, 0);
        //?? French
      }
      if (Impact_TYPE == Impact_PASSIVE) {  
        my_text((Model_Description + "Analysis of Passive Potentials (%kWh°C/m²/day)"), 0, 1.25 * sx_Plot / GRAPHS_U_scale, 0);
        //?? French
      }    
      
    }


  }





  if ((plot_impacts == 2) || (plot_impacts == 3)) {
    if (plot_impacts == 2) Impact_TYPE = Impact_ACTIVE; 
    if (plot_impacts == 3) Impact_TYPE = Impact_PASSIVE;

    float Pa = FLOAT_undefined;
    float Pb = FLOAT_undefined;
    float Pc = FLOAT_undefined;
    float Pd = FLOAT_undefined;

    float _values_R_dir;
    float _values_R_dif;
    float _values_E_dir;
    float _values_E_dif;
    
    int now_k = 0;
    int now_i = 0;
    int now_j = 0;

    int PAL_TYPE = 0; 
    int PAL_DIR = 1;
    
    if (Impact_TYPE == Impact_ACTIVE) {  
      //PAL_TYPE = Pallet_ACTIVE; PAL_DIR = Pallet_ACTIVE_DIR;
      //PAL_TYPE = 13; PAL_DIR = Pallet_ACTIVE_DIR; // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      //PAL_TYPE = -1; PAL_DIR = 2;
      //PAL_TYPE = -1; PAL_DIR = -2;
      PAL_TYPE = 15; PAL_DIR = 1;
      
    }
    if (Impact_TYPE == Impact_PASSIVE) {  
      PAL_TYPE = Pallet_PASSIVE; PAL_DIR = Pallet_PASSIVE_DIR;
    }             
    
    float _Multiplier = 1; 
    if (Impact_TYPE == Impact_ACTIVE) _Multiplier = 0.1; //0.1 / 0.75; //0.1; <<<<<<<<<<<<<<<<<<<<<
    if (Impact_TYPE == Impact_PASSIVE) _Multiplier = 0.02; 

    //for (int p = 0; p < 3; p += 1) { 
      //int l = 3 * int(impact_layer / 3) + p;
      
    //for (int p = 0; p < 3; p += 2) { 
      //int l = 3 * int(impact_layer / 3) + p; 

    for (int p = 0; p < 1; p += 1) { 
      int l = 3 * int(impact_layer / 3) + 1; //impact_layer;

      float[][] TOTAL_valuesSUM_RAD = new float [1 + int(90 / stp_slp)][1 + int(360 / stp_dir)];
      float[][] TOTAL_valuesSUM_EFF_P = new float [1 + int(90 / stp_slp)][1 + int(360 / stp_dir)];
      float[][] TOTAL_valuesSUM_EFF_N = new float [1 + int(90 / stp_slp)][1 + int(360 / stp_dir)];
      int[][] TOTAL_valuesNUM = new int [1 + int(90 / stp_slp)][1 + int(360 / stp_dir)];

      for (int a = 0; a <= int(90 / stp_slp); a += 1) { 
        for (int b = 0; b < int(360 / stp_dir); b += 1) {
          TOTAL_valuesSUM_RAD[a][b] = FLOAT_undefined;
          TOTAL_valuesSUM_EFF_P[a][b] = FLOAT_undefined;
          TOTAL_valuesSUM_EFF_N[a][b] = FLOAT_undefined;
          TOTAL_valuesNUM[a][b] = 0;
        }
      }
      
      for (int j = j_start; j < j_end; j += 1) {

        now_j = (j * int(per_day) + BEGIN_DAY + 365) % 365;
    
        if (now_j >= 365) {
         now_j = now_j % 365; 
        }
        if (now_j < 0) {
         now_j = (now_j + 365) % 365; 
        }
 
        float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0); 

        float _sunrise = SOLARCHVISION_Sunrise(LocationLatitude, DATE_ANGLE); 
        float _sunset = SOLARCHVISION_Sunset(LocationLatitude, DATE_ANGLE);

        int[] Normals_COL_N;
        Normals_COL_N = new int[9];
        Normals_COL_N = SOLARCHVISION_PROCESS_DAILY_SCENARIOS(layers_count, start_z, end_z, j, DATE_ANGLE);

        for (int nk = Normals_COL_N[l]; nk <= Normals_COL_N[l]; nk += 1) {
          if (nk != -1) {
            int k = int(nk / num_add_days);
            int j_ADD = nk % num_add_days; 

            for (int a = 0; a <= int(90 / stp_slp); a += 1) { 
              float Alpha = a * stp_slp;
              for (int b = 0; b < int(360 / stp_dir); b += 1) {
                float Beta = b * stp_dir;
                
                float _valuesSUM_RAD = 0;
                float _valuesSUM_EFF_P = 0;
                float _valuesSUM_EFF_N = 0;
                int _valuesNUM = 0; 

                for (int i = 0; i < 24; i += 1) {
                  
                  float HOUR_ANGLE = i; 
                  float[] SunR = SOLARCHVISION_SunPosition(LocationLatitude, DATE_ANGLE, HOUR_ANGLE);

                  if (SunR[3] > 0) {
  
                    now_k = k;
                    now_i = i;
                    now_j = int(j * per_day + (j_ADD - int(0.5 * num_add_days)) + BEGIN_DAY + 365) % 365;
  
                    if (now_j >= 365) {
                     now_j = now_j % 365; 
                    }
                    if (now_j < 0) {
                     now_j = (now_j + 365) % 365; 
                    }
  
                    if (impacts_source == databaseNumber_CLIMATE_WY2) {
                        Pa = CLIMATE_WY2[now_i][now_j][_dirnorrad][now_k]; 
                        Pb = CLIMATE_WY2[now_i][now_j][_difhorrad][now_k]; 
                        Pc = CLIMATE_WY2[now_i][now_j][_direffect][now_k]; 
                        Pd = CLIMATE_WY2[now_i][now_j][_difeffect][now_k]; 
                    }
                    if (impacts_source == databaseNumber_ENSEMBLE) {
                        Pa = ENSEMBLE[now_i][now_j][_dirnorrad][now_k]; 
                        Pb = ENSEMBLE[now_i][now_j][_difhorrad][now_k]; 
                        Pc = ENSEMBLE[now_i][now_j][_direffect][now_k]; 
                        Pd = ENSEMBLE[now_i][now_j][_difeffect][now_k]; 
                    }            
                    if (impacts_source == databaseNumber_OBSERVED) {
                        Pa = OBSERVED[now_i][now_j][_dirnorrad][now_k]; 
                        Pb = OBSERVED[now_i][now_j][_difhorrad][now_k]; 
                        Pc = OBSERVED[now_i][now_j][_direffect][now_k]; 
                        Pd = OBSERVED[now_i][now_j][_difeffect][now_k]; 
                    }   
                    if (impacts_source == databaseNumber_CLIMATE_EPW) {
                        Pa = CLIMATE_EPW[now_i][now_j][_dirnorrad][now_k]; 
                        Pb = CLIMATE_EPW[now_i][now_j][_difhorrad][now_k]; 
                        Pc = CLIMATE_EPW[now_i][now_j][_direffect][now_k]; 
                        Pd = CLIMATE_EPW[now_i][now_j][_difeffect][now_k]; 
                    }       
        
                    if ((Pa > 0.9 * FLOAT_undefined) || (Pb > 0.9 * FLOAT_undefined) || (Pc > 0.9 * FLOAT_undefined) || (Pd > 0.9 * FLOAT_undefined)) {
                      _values_R_dir = FLOAT_undefined;
                      _values_R_dif = FLOAT_undefined;
                      _values_E_dir = FLOAT_undefined;
                      _values_E_dif = FLOAT_undefined;
                    }
                    else {
    
                      int drw_count = 0;
                      if (impacts_source == databaseNumber_CLIMATE_EPW) drw_count = SOLARCHVISION_filter("CLIMATE_EPW", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                      if (impacts_source == databaseNumber_CLIMATE_WY2) drw_count = SOLARCHVISION_filter("CLIMATE_WY2", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                      if (impacts_source == databaseNumber_ENSEMBLE) drw_count = SOLARCHVISION_filter("ENSEMBLE", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                      if (impacts_source == databaseNumber_OBSERVED) drw_count = SOLARCHVISION_filter("OBSERVED", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                      
                      if (drw_count == 1) {
                        _values_R_dir = 0.001 * Pa;
                        _values_R_dif = 0.001 * Pb;
                        _values_E_dir = 0.001 * Pc;
                        _values_E_dif = 0.001 * Pd;
                        
                        if (_valuesSUM_RAD > 0.9 * FLOAT_undefined) {
                          _valuesSUM_RAD = 0;
                          _valuesSUM_EFF_P = 0;
                          _valuesSUM_EFF_N = 0;
                          _valuesNUM = 0; 
                        }                             
                        else {

                          if (_values_E_dir < 0) {
                            _valuesSUM_EFF_N += -SolarAtSurface(SunR[1], SunR[2], SunR[3], _values_E_dir, _values_E_dif, Alpha, Beta, GlobalAlbedo); 
                          }
                          else {
                            _valuesSUM_EFF_P += SolarAtSurface(SunR[1], SunR[2], SunR[3], _values_E_dir, _values_E_dif, Alpha, Beta, GlobalAlbedo); 
                          }

                          _valuesSUM_RAD += SolarAtSurface(SunR[1], SunR[2], SunR[3], _values_R_dir, _values_R_dif, Alpha, Beta, GlobalAlbedo); 
                          
                          _valuesNUM += 1;
                          
                        }
                      }
                    }
                  }
                }
                
      
                if (_valuesNUM != 0) {
                  //float _valuesMUL = SOLARCHVISION_DayTime(LocationLatitude, DATE_ANGLE) / (1.0 * _valuesNUM);  
                  //float _valuesMUL = int(SOLARCHVISION_DayTime(LocationLatitude, DATE_ANGLE)) / (1.0 * _valuesNUM);
                  float _valuesMUL = roundTo(SOLARCHVISION_DayTime(LocationLatitude, DATE_ANGLE), 1) / (1.0 * _valuesNUM);
                                     
                  _valuesSUM_RAD *= _valuesMUL;
                  _valuesSUM_EFF_P *= _valuesMUL;
                  _valuesSUM_EFF_N *= _valuesMUL;
                  
                  if (TOTAL_valuesNUM[a][b] == 0) {
                    TOTAL_valuesSUM_RAD[a][b] = 0;
                    TOTAL_valuesSUM_EFF_P[a][b] = 0;
                    TOTAL_valuesSUM_EFF_N[a][b] = 0;
                  }

                  TOTAL_valuesSUM_RAD[a][b] += _valuesSUM_RAD;
                  TOTAL_valuesSUM_EFF_P[a][b] += _valuesSUM_EFF_P;
                  TOTAL_valuesSUM_EFF_N[a][b] += _valuesSUM_EFF_N;
                  TOTAL_valuesNUM[a][b] += 1;
                }
                else {
                  _valuesSUM_RAD = FLOAT_undefined;
                  _valuesSUM_EFF_P = FLOAT_undefined;
                  _valuesSUM_EFF_N = FLOAT_undefined;
                }


                float AVERAGE, PERCENTAGE, COMPARISON;
                
                AVERAGE = (_valuesSUM_EFF_P - _valuesSUM_EFF_N);
                if ((_valuesSUM_EFF_P + _valuesSUM_EFF_N) > 0.00001) PERCENTAGE = (_valuesSUM_EFF_P - _valuesSUM_EFF_N) / (1.0 * (_valuesSUM_EFF_P + _valuesSUM_EFF_N)); 
                else PERCENTAGE = 0.0;
                COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);

      
                float _valuesSUM = FLOAT_undefined;
                if (Impact_TYPE == Impact_ACTIVE) _valuesSUM = _valuesSUM_RAD;
                if (Impact_TYPE == Impact_PASSIVE) _valuesSUM = COMPARISON; 
                
                //if ((Alpha == 90.0) && (Beta == 0.0)) println("SPHERICAL >> _valuesSUM_RAD:", _valuesSUM_RAD, "COMPARISON:", COMPARISON);  
                
                if (_valuesSUM < 0.9 * FLOAT_undefined) {
                
                  float _u = 0;
                  
                  if (Impact_TYPE == Impact_ACTIVE) _u = (_Multiplier * _valuesSUM);
                  if (Impact_TYPE == Impact_PASSIVE) _u = 0.5 + 0.5 * 0.75 * (_Multiplier * _valuesSUM);
                  
                  if (PAL_DIR == -1) _u = 1 - _u;
                  if (PAL_DIR == -2) _u = 0.5 - 0.5 * _u;
                  if (PAL_DIR == 2) _u =  0.5 * _u;
                  
                  //SET_COLOR_STYLE(PAL_TYPE, _u);
                  SET_COLOR_STYLE(PAL_TYPE, roundTo(_u, 0.1));
                  //SET_COLOR_STYLE(PAL_TYPE, roundTo(_u, 0.05));
                  
                  
                  Diagrams_strokeWeight(0);
                  
                  float x1 = (j + obj_offset_x + (90 - Alpha - 0.5 * stp_slp) * obj_scale * (cos_ang(Beta - 90 - 0.5 * stp_dir))) * sx_Plot;
                  float y1 = (                  -(90 - Alpha - 0.5 * stp_slp) * obj_scale * (sin_ang(Beta - 90 - 0.5 * stp_dir))) * sx_Plot;
                  float x2 = (j + obj_offset_x + (90 - Alpha + 0.5 * stp_slp) * obj_scale * (cos_ang(Beta - 90 - 0.5 * stp_dir))) * sx_Plot;
                  float y2 = (                  -(90 - Alpha + 0.5 * stp_slp) * obj_scale * (sin_ang(Beta - 90 - 0.5 * stp_dir))) * sx_Plot; 
          
                  float x3 = (j + obj_offset_x + (90 - Alpha + 0.5 * stp_slp) * obj_scale * (cos_ang(Beta - 90 + 0.5 * stp_dir))) * sx_Plot;
                  float y3 = (                  -(90 - Alpha + 0.5 * stp_slp) * obj_scale * (sin_ang(Beta - 90 + 0.5 * stp_dir))) * sx_Plot; 
                  float x4 = (j + obj_offset_x + (90 - Alpha - 0.5 * stp_slp) * obj_scale * (cos_ang(Beta - 90 + 0.5 * stp_dir))) * sx_Plot;
                  float y4 = (                  -(90 - Alpha - 0.5 * stp_slp) * obj_scale * (sin_ang(Beta - 90 + 0.5 * stp_dir))) * sx_Plot; 
          
                  Diagrams_quad(x1, y1, x2, y2, x3, y3, x4, y4); 
                  
                }
              }
            }

            Diagrams_stroke(0);
            Diagrams_fill(0);
            Diagrams_textAlign(CENTER, CENTER); 
            Diagrams_textSize(sx_Plot * 0.15 / GRAPHS_U_scale);
            
            String scenario_text = "";
            //if (impacts_source == databaseNumber_CLIMATE_WY2) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_WY2_start - 1, 0);
            //if (impacts_source == databaseNumber_ENSEMBLE) scenario_text += "Member: " + nf(Normals_COL_N[l], 0);
            my_text(scenario_text, (j - ((0 - 12) / 24.0)) * sx_Plot, 0.95 * sx_Plot / GRAPHS_U_scale, 0);
          }
        }
      }
      
      
  
      if (draw_impact_summary == 1) { 

        int j = -1; // << to put the summary graph before the daily graphs

        for (int a = 0; a <= int(90 / stp_slp); a += 1) { 
          float Alpha = a * stp_slp;
          for (int b = 0; b < int(360 / stp_dir); b += 1) {
            float Beta = b * stp_dir;

            if (TOTAL_valuesNUM[a][b] != 0) {
              TOTAL_valuesSUM_RAD[a][b] /= 1.0 * TOTAL_valuesNUM[a][b];
              TOTAL_valuesSUM_EFF_P[a][b] /= 1.0 * TOTAL_valuesNUM[a][b];
              TOTAL_valuesSUM_EFF_N[a][b] /= 1.0 * TOTAL_valuesNUM[a][b];
            }
            else {
              TOTAL_valuesSUM_RAD[a][b] = FLOAT_undefined;
              TOTAL_valuesSUM_EFF_P[a][b] = FLOAT_undefined;
              TOTAL_valuesSUM_EFF_N[a][b] = FLOAT_undefined;
            }
      
      
            float AVERAGE, PERCENTAGE, COMPARISON;
            
            AVERAGE = (TOTAL_valuesSUM_EFF_P[a][b] - TOTAL_valuesSUM_EFF_N[a][b]);
            if ((TOTAL_valuesSUM_EFF_P[a][b] + TOTAL_valuesSUM_EFF_N[a][b]) > 0.00001) PERCENTAGE = (TOTAL_valuesSUM_EFF_P[a][b] - TOTAL_valuesSUM_EFF_N[a][b]) / (1.0 * (TOTAL_valuesSUM_EFF_P[a][b] + TOTAL_valuesSUM_EFF_N[a][b])); 
            else PERCENTAGE = 0.0;
            COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);
      
      
            float _valuesSUM = FLOAT_undefined;
            if (Impact_TYPE == Impact_ACTIVE) _valuesSUM = TOTAL_valuesSUM_RAD[a][b];
            if (Impact_TYPE == Impact_PASSIVE) _valuesSUM = COMPARISON; 
            
            //if ((Alpha == 90.0) && (Beta == 0.0)) println("SPHERICAL >> (TOTAL) _valuesSUM_RAD:", TOTAL_valuesSUM_RAD[a][b], "COMPARISON:", COMPARISON);  
            
            if (_valuesSUM < 0.9 * FLOAT_undefined) {
            
              float _u = 0;
              
              if (Impact_TYPE == Impact_ACTIVE) _u = (_Multiplier * _valuesSUM);
              if (Impact_TYPE == Impact_PASSIVE) _u = 0.5 + 0.5 * 0.75 * (_Multiplier * _valuesSUM);
              
              if (PAL_DIR == -1) _u = 1 - _u;
              if (PAL_DIR == -2) _u = 0.5 - 0.5 * _u;
              if (PAL_DIR == 2) _u =  0.5 * _u;
              
              //SET_COLOR_STYLE(PAL_TYPE, _u);
              SET_COLOR_STYLE(PAL_TYPE, roundTo(_u, 0.1));
              //SET_COLOR_STYLE(PAL_TYPE, roundTo(_u, 0.05));
              
              
              Diagrams_strokeWeight(0);
              
              float x1 = (j + obj_offset_x + (90 - Alpha - 0.5 * stp_slp) * obj_scale * (cos_ang(Beta - 90 - 0.5 * stp_dir))) * sx_Plot;
              float y1 = (                  -(90 - Alpha - 0.5 * stp_slp) * obj_scale * (sin_ang(Beta - 90 - 0.5 * stp_dir))) * sx_Plot;
              float x2 = (j + obj_offset_x + (90 - Alpha + 0.5 * stp_slp) * obj_scale * (cos_ang(Beta - 90 - 0.5 * stp_dir))) * sx_Plot;
              float y2 = (                  -(90 - Alpha + 0.5 * stp_slp) * obj_scale * (sin_ang(Beta - 90 - 0.5 * stp_dir))) * sx_Plot; 
      
              float x3 = (j + obj_offset_x + (90 - Alpha + 0.5 * stp_slp) * obj_scale * (cos_ang(Beta - 90 + 0.5 * stp_dir))) * sx_Plot;
              float y3 = (                  -(90 - Alpha + 0.5 * stp_slp) * obj_scale * (sin_ang(Beta - 90 + 0.5 * stp_dir))) * sx_Plot; 
              float x4 = (j + obj_offset_x + (90 - Alpha - 0.5 * stp_slp) * obj_scale * (cos_ang(Beta - 90 + 0.5 * stp_dir))) * sx_Plot;
              float y4 = (                  -(90 - Alpha - 0.5 * stp_slp) * obj_scale * (sin_ang(Beta - 90 + 0.5 * stp_dir))) * sx_Plot; 
      
              Diagrams_quad(x1, y1, x2, y2, x3, y3, x4, y4); 
              
            }
          }
        }

        Diagrams_strokeWeight(GRAPHS_T_scale * 2);
        Diagrams_stroke(0);
        Diagrams_noFill(); 
        Diagrams_rect((j + obj_offset_x - 100 * obj_scale) * sx_Plot, (-100 * obj_scale) * sx_Plot - (1 * p * sx_Plot / GRAPHS_U_scale), (200 * obj_scale) * sx_Plot, (200 * obj_scale) * sx_Plot);

        
        Diagrams_stroke(0);
        Diagrams_fill(0);
        Diagrams_textAlign(CENTER, CENTER); 
        Diagrams_textSize(sx_Plot * 0.15 / GRAPHS_U_scale);
        
        String scenario_text = "";
        //if (impacts_source == databaseNumber_CLIMATE_WY2) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_WY2_start - 1, 0);
        //if (impacts_source == databaseNumber_ENSEMBLE) scenario_text += "Member: " + nf(Normals_COL_N[l], 0);
        my_text(scenario_text, (j - ((0 - 12) / 24.0)) * sx_Plot, 0.95 * sx_Plot / GRAPHS_U_scale, 0);

        int pre_j_start = j_start;
        int pre_j_end = j_end;
        j_start = j;
        j_end = j + 1;
        SOLARCHVISION_draw_Grid_Spherical_POSITION(x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot, 0);
        j_start = pre_j_start;
        j_end = pre_j_end;
      }


      String scenario_text = "";
      //if (impacts_source == databaseNumber_CLIMATE_WY2) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_WY2_start - 1, 0);
      //if (impacts_source == databaseNumber_ENSEMBLE) scenario_text += "Member: " + nf(Normals_COL_N[l], 0);
      my_text(scenario_text, ((j_start - 1) - ((0 - 12) / 24.0)) * sx_Plot, (0.9 - 1 * (p - 0.25)) * sx_Plot / GRAPHS_U_scale, 0);

      Diagrams_textSize(sx_Plot * 0.15 / GRAPHS_U_scale);
      Diagrams_textAlign(RIGHT, CENTER); 
      Diagrams_stroke(0);
      Diagrams_fill(0);
      Diagrams_strokeWeight(0); 
      if (Impact_TYPE == Impact_ACTIVE) {  
        my_text(N_Title[l], 0, - (1 * p * sx_Plot / GRAPHS_U_scale), 0);
      }
      if (Impact_TYPE == Impact_PASSIVE) {  
        my_text(N_Title[reverse_N[l]], 0, - (1 * p * sx_Plot / GRAPHS_U_scale), 0);
      }            
      //?? French        
    }
    
    float pal_length = 400;
    for (int q = 0; q < 11; q += 1) {
      float _u = 0;
      
      if (Impact_TYPE == Impact_ACTIVE) _u = 0.1 * q;
      if (Impact_TYPE == Impact_PASSIVE) {
        _u = 0.2 * q - 0.5;
        _u = (_u - 0.5) * 0.75 + 0.5;
      }        
      
      if (PAL_DIR == -1) _u = 1 - _u;
      if (PAL_DIR == -2) _u = 0.5 - 0.5 * _u;
      if (PAL_DIR == 2) _u =  0.5 * _u;
      
      SET_COLOR_STYLE(PAL_TYPE, _u); 
      
      Diagrams_strokeWeight(0);
      Diagrams_rect((700 + q * (pal_length / 11.0)) * GRAPHS_S_View, -175 * GRAPHS_S_View, (pal_length / 11.0) * GRAPHS_S_View, 20 * GRAPHS_S_View); 

      Diagrams_strokeWeight(2);
      Diagrams_stroke(255);
      Diagrams_fill(255); 
      Diagrams_textSize(15.0 * GRAPHS_S_View);
      Diagrams_textAlign(CENTER, CENTER);
      if (Impact_TYPE == Impact_ACTIVE) my_text(nf((roundTo(0.1 * q / _Multiplier, 0.1)), 1, 1), (20 + 700 + q * (pal_length / 11.0)) * GRAPHS_S_View, (10 - 175 - 0.05 * 20) * GRAPHS_S_View, 1 * GRAPHS_S_View);
      if (Impact_TYPE == Impact_PASSIVE) my_text(nf(int(roundTo(0.4 * (q - 5) / _Multiplier, 1)), 1), (20 + 700 + q * (pal_length / 11.0)) * GRAPHS_S_View, (10 - 175 - 0.05 * 20) * GRAPHS_S_View, 1 * GRAPHS_S_View);
    }
    
    
    if (GRAPHS_print_title != 0) {
    
      Diagrams_stroke(0); 
      Diagrams_fill(0);
      Diagrams_strokeWeight(GRAPHS_T_scale * 0);
      
      Diagrams_textSize(sx_Plot * 0.150 / GRAPHS_U_scale);
      Diagrams_textAlign(RIGHT, CENTER); 
      //if (impacts_source == databaseNumber_CLIMATE_WY2) my_text(("[" + String.valueOf(start_z + CLIMATE_WY2_start - 1) + "-" + String.valueOf(end_z + CLIMATE_WY2_start - 1) + "] "), 0, 1.3 * sx_Plot / GRAPHS_U_scale, 0);
      //if (impacts_source == databaseNumber_ENSEMBLE) my_text(("[Members:" + String.valueOf(start_z) + "-" + String.valueOf(end_z) + "] "), 0, 1.3 * sx_Plot / GRAPHS_U_scale, 0);
      
      Diagrams_textSize(sx_Plot * 0.150 / GRAPHS_U_scale);
      Diagrams_textAlign(LEFT, TOP); 
      if (Impact_TYPE == Impact_ACTIVE) {  
        my_text(("Solar radiation on hemisphere (kWh/m²/day)"), 0, 1.25 * sx_Plot / GRAPHS_U_scale, 0);
        //?? French
      }
      if (Impact_TYPE == Impact_PASSIVE) {  
        my_text(("Solar effects on hemisphere (%kWh°C/m²/day)"), 0, 1.25 * sx_Plot / GRAPHS_U_scale, 0);
        //?? French
      }  

    }

    SOLARCHVISION_draw_Grid_Spherical_POSITION(x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot, 0); 
  } 



  if ((plot_impacts == 4) || (plot_impacts == 5)) {
    if (plot_impacts == 4) Impact_TYPE = Impact_ACTIVE; 
    if (plot_impacts == 5) Impact_TYPE = Impact_PASSIVE;

    float Pa = FLOAT_undefined;
    float Pb = FLOAT_undefined;
    float Pc = FLOAT_undefined;
    float Pd = FLOAT_undefined;

    float _values_R_dir;
    float _values_R_dif;
    float _values_E_dir;
    float _values_E_dif;
   
    int now_k = 0;
    int now_i = 0;
    int now_j = 0;

    int PAL_TYPE = 0; 
    int PAL_DIR = 1;
    
    if (Impact_TYPE == Impact_ACTIVE) {  
      //PAL_TYPE = Pallet_ACTIVE; PAL_DIR = Pallet_ACTIVE_DIR;
      //PAL_TYPE = 13; PAL_DIR = Pallet_ACTIVE_DIR; // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      PAL_TYPE = -1; PAL_DIR = 2;
    }
    if (Impact_TYPE == Impact_PASSIVE) {  
      PAL_TYPE = Pallet_PASSIVE; PAL_DIR = Pallet_PASSIVE_DIR;
    }             

    float _Multiplier = 1; 
    if (Impact_TYPE == Impact_ACTIVE) _Multiplier = 1.0;
    if (Impact_TYPE == Impact_PASSIVE) _Multiplier = 0.05;

    SOLARCHVISION_draw_Grid_Spherical_POSITION(x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot, 0);

    //for (int p = 0; p < 3; p += 1) { 
      //int l = 3 * int(impact_layer / 3) + p;

    //for (int p = 0; p < 3; p += 2) { 
      //int l = 3 * int(impact_layer / 3) + p; 

    for (int p = 0; p < 1; p += 1) { 
      int l = impact_layer;
 
      for (int j = j_start; j < j_end; j += 1) {

        now_j = (j * int(per_day) + BEGIN_DAY + 365) % 365;
    
        if (now_j >= 365) {
         now_j = now_j % 365; 
        }
        if (now_j < 0) {
         now_j = (now_j + 365) % 365; 
        }
 
        float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0); 

        float _sunrise = SOLARCHVISION_Sunrise(LocationLatitude, DATE_ANGLE); 
        float _sunset = SOLARCHVISION_Sunset(LocationLatitude, DATE_ANGLE);

        int[] Normals_COL_N;
        Normals_COL_N = new int[9];
        Normals_COL_N = SOLARCHVISION_PROCESS_DAILY_SCENARIOS(layers_count, start_z, end_z, j, DATE_ANGLE);

        for (int nk = Normals_COL_N[l]; nk <= Normals_COL_N[l]; nk += 1) {
          if (nk != -1) {
            int k = int(nk / num_add_days);
            int j_ADD = nk % num_add_days; 
            
            float _valuesSUM_RAD = 0;
            float _valuesSUM_EFF = 0;
            int _valuesNUM = 0; 

            for (int i = 0; i < 24; i += 1) {
              if ((i > _sunrise) && (i < _sunset)) {
                
                float HOUR_ANGLE = i; 
                float[] SunR = SOLARCHVISION_SunPosition(LocationLatitude, DATE_ANGLE, HOUR_ANGLE);
                
                float Alpha = 90 - acos_ang(SunR[3]);
                float Beta = 180 - atan2_ang(SunR[1], SunR[2]);

                now_k = k;
                now_i = i;
                now_j = int(j * per_day + (j_ADD - int(0.5 * num_add_days)) + BEGIN_DAY + 365) % 365;
    
                if (now_j >= 365) {
                 now_j = now_j % 365; 
                }
                if (now_j < 0) {
                 now_j = (now_j + 365) % 365; 
                }

                if (impacts_source == databaseNumber_CLIMATE_WY2) {
                    Pa = CLIMATE_WY2[now_i][now_j][_dirnorrad][now_k]; 
                    Pb = CLIMATE_WY2[now_i][now_j][_difhorrad][now_k]; 
                    Pc = CLIMATE_WY2[now_i][now_j][_direffect][now_k]; 
                    Pd = CLIMATE_WY2[now_i][now_j][_difeffect][now_k]; 
                }
                if (impacts_source == databaseNumber_ENSEMBLE) {
                    Pa = ENSEMBLE[now_i][now_j][_dirnorrad][now_k]; 
                    Pb = ENSEMBLE[now_i][now_j][_difhorrad][now_k]; 
                    Pc = ENSEMBLE[now_i][now_j][_direffect][now_k]; 
                    Pd = ENSEMBLE[now_i][now_j][_difeffect][now_k]; 
                }            
                if (impacts_source == databaseNumber_OBSERVED) {
                    Pa = OBSERVED[now_i][now_j][_dirnorrad][now_k]; 
                    Pb = OBSERVED[now_i][now_j][_difhorrad][now_k]; 
                    Pc = OBSERVED[now_i][now_j][_direffect][now_k]; 
                    Pd = OBSERVED[now_i][now_j][_difeffect][now_k]; 
                }   
                if (impacts_source == databaseNumber_CLIMATE_EPW) {
                    Pa = CLIMATE_EPW[now_i][now_j][_dirnorrad][now_k]; 
                    Pb = CLIMATE_EPW[now_i][now_j][_difhorrad][now_k]; 
                    Pc = CLIMATE_EPW[now_i][now_j][_direffect][now_k]; 
                    Pd = CLIMATE_EPW[now_i][now_j][_difeffect][now_k]; 
                }          
    
                if ((Pa > 0.9 * FLOAT_undefined) || (Pb > 0.9 * FLOAT_undefined) || (Pc > 0.9 * FLOAT_undefined) || (Pd > 0.9 * FLOAT_undefined)) {
                  _values_R_dir = FLOAT_undefined;
                  _values_R_dif = FLOAT_undefined;
                  _values_E_dir = FLOAT_undefined;
                  _values_E_dif = FLOAT_undefined;
                }
                else {

                  int drw_count = 0;
                  if (impacts_source == databaseNumber_CLIMATE_EPW) drw_count = SOLARCHVISION_filter("CLIMATE_EPW", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                  if (impacts_source == databaseNumber_CLIMATE_WY2) drw_count = SOLARCHVISION_filter("CLIMATE_WY2", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                  if (impacts_source == databaseNumber_ENSEMBLE) drw_count = SOLARCHVISION_filter("ENSEMBLE", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                  if (impacts_source == databaseNumber_OBSERVED) drw_count = SOLARCHVISION_filter("OBSERVED", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                    
                  if (drw_count == 1) {
                    _values_R_dir = 0.001 * Pa;
                    _values_R_dif = 0.001 * Pb;
                    _values_E_dir = 0.001 * Pc;
                    _values_E_dif = 0.001 * Pd;
                    
                    if (_valuesSUM_RAD > 0.9 * FLOAT_undefined) {
                      _valuesSUM_RAD = 0;
                      _valuesSUM_EFF = 0;
                      _valuesNUM = 0; 
                    }                             
                    else {
                      _valuesSUM_RAD = (_values_R_dir); // direct beam radiation
                      _valuesSUM_EFF = (_values_E_dir); // direct beam effect
                      _valuesNUM = 1;
                    }
                  }
                }
      
                float _valuesSUM = FLOAT_undefined;
                if (Impact_TYPE == Impact_ACTIVE) _valuesSUM = _valuesSUM_RAD;
                if (Impact_TYPE == Impact_PASSIVE) _valuesSUM = _valuesSUM_EFF; 
                
                if (_valuesSUM < 0.9 * FLOAT_undefined) {
                
                  float _u = 0;
                  
                  if (Impact_TYPE == Impact_ACTIVE) _u = (_Multiplier * _valuesSUM);
                  if (Impact_TYPE == Impact_PASSIVE) _u = 0.5 + 0.5 * 0.75 * (_Multiplier * _valuesSUM);
                  
                  if (PAL_DIR == -1) _u = 1 - _u;
                  if (PAL_DIR == -2) _u = 0.5 - 0.5 * _u;
                  if (PAL_DIR == 2) _u =  0.5 * _u;
                  
                  SET_COLOR_STYLE(PAL_TYPE, _u);
                  
                  Diagrams_strokeWeight(0);
                  
                  Diagrams_ellipse((j + obj_offset_x + (90 - Alpha) * obj_scale * (cos_ang(Beta - 90))) * sx_Plot, -((90 - Alpha) * obj_scale * (sin_ang(Beta - 90))) * sx_Plot, 0.075 * sx_Plot, 0.075 * sx_Plot);
                  
                  if ((_u >= 0.95) || (_u <= 0.05)) {
                    Diagrams_stroke(255);
                    Diagrams_fill(255); 
                  }
                  else {
                    Diagrams_stroke(0);
                    Diagrams_fill(0);
                  }
                  
                  Diagrams_textSize(GRAPHS_S_View * 4.0 * GRAPHS_U_scale);
                  
                  Diagrams_textAlign(CENTER, CENTER);
                  if (Impact_TYPE == Impact_ACTIVE) my_text (nf(_valuesSUM, 1, 1), (j + obj_offset_x + (90 - Alpha) * obj_scale * (cos_ang(Beta - 90))) * sx_Plot, -((90 - Alpha) * obj_scale * (sin_ang(Beta - 90))) * sx_Plot, 0);
                  if (Impact_TYPE == Impact_PASSIVE) my_text (nf(int(_valuesSUM), 1), (j + obj_offset_x + (90 - Alpha) * obj_scale * (cos_ang(Beta - 90))) * sx_Plot, -((90 - Alpha) * obj_scale * (sin_ang(Beta - 90))) * sx_Plot, 0);
    
                }
              }
            }
            
            Diagrams_stroke(0);
            Diagrams_fill(0);
            Diagrams_textAlign(CENTER, CENTER); 
            Diagrams_textSize(sx_Plot * 0.15 / GRAPHS_U_scale);
            
            String scenario_text = "";
            //if (impacts_source == databaseNumber_CLIMATE_WY2) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_WY2_start - 1, 0);
            //if (impacts_source == databaseNumber_ENSEMBLE) scenario_text += "Member: " + nf(Normals_COL_N[l], 0);
            my_text(scenario_text, (j - ((0 - 12) / 24.0)) * sx_Plot, 0.95  * sx_Plot / GRAPHS_U_scale, 0);
            
          }
        }
      }
      
      String scenario_text = "";
      //if (impacts_source == databaseNumber_CLIMATE_WY2) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_WY2_start - 1, 0);
      //if (impacts_source == databaseNumber_ENSEMBLE) scenario_text += "Member: " + nf(Normals_COL_N[l], 0);
      my_text(scenario_text, ((j_start - 1) - ((0 - 12) / 24.0)) * sx_Plot, (0.9 - 1 * (p - 0.25)) * sx_Plot / GRAPHS_U_scale, 0);

      Diagrams_textSize(sx_Plot * 0.15 / GRAPHS_U_scale);
      Diagrams_textAlign(RIGHT, CENTER); 
      Diagrams_stroke(0);
      Diagrams_fill(0);
      Diagrams_strokeWeight(0); 
      if (Impact_TYPE == Impact_ACTIVE) {  
        my_text(N_Title[l], 0, - (1 * p * sx_Plot / GRAPHS_U_scale), 0);
      }
      if (Impact_TYPE == Impact_PASSIVE) {  
        my_text(N_Title[reverse_N[l]], 0, - (1 * p * sx_Plot / GRAPHS_U_scale), 0);
      }            
      //?? French
    }
    
    float pal_length = 400;
    for (int q = 0; q < 11; q += 1) {
      float _u = 0;
      
      if (Impact_TYPE == Impact_ACTIVE) _u = 0.1 * q;
      if (Impact_TYPE == Impact_PASSIVE) {
        _u = 0.2 * q - 0.5;
        _u = (_u - 0.5) * 0.75 + 0.5;
      }        
      
      if (PAL_DIR == -1) _u = 1 - _u;
      if (PAL_DIR == -2) _u = 0.5 - 0.5 * _u;
      if (PAL_DIR == 2) _u =  0.5 * _u;
      
      SET_COLOR_STYLE(PAL_TYPE, _u); 
      
      Diagrams_strokeWeight(0);
      Diagrams_rect((700 + q * (pal_length / 11.0)) * GRAPHS_S_View, -175 * GRAPHS_S_View, (pal_length / 11.0) * GRAPHS_S_View, 20 * GRAPHS_S_View); 

      Diagrams_strokeWeight(2);
      Diagrams_stroke(255);
      Diagrams_fill(255); 
      Diagrams_textSize(15.0 * GRAPHS_S_View);
      Diagrams_textAlign(CENTER, CENTER);
      if (Impact_TYPE == Impact_ACTIVE) my_text(nf(0.1 * q / _Multiplier, 1, 1), (20 + 700 + q * (pal_length / 11.0)) * GRAPHS_S_View, (10 - 175 - 0.05 * 20) * GRAPHS_S_View, 1 * GRAPHS_S_View);
      if (Impact_TYPE == Impact_PASSIVE) my_text(nf(0.4 * (q - 5) / _Multiplier, 1, 1), (20 + 700 + q * (pal_length / 11.0)) * GRAPHS_S_View, (10 - 175 - 0.05 * 20) * GRAPHS_S_View, 1 * GRAPHS_S_View);
    } 
    
    
    if (GRAPHS_print_title != 0) {
    
      Diagrams_stroke(0); 
      Diagrams_fill(0);
      Diagrams_strokeWeight(GRAPHS_T_scale * 0);
      
      Diagrams_textSize(sx_Plot * 0.150 / GRAPHS_U_scale);
      Diagrams_textAlign(RIGHT, CENTER); 
      //if (impacts_source == databaseNumber_CLIMATE_WY2) my_text(("[" + String.valueOf(start_z + CLIMATE_WY2_start - 1) + "-" + String.valueOf(end_z + CLIMATE_WY2_start - 1) + "] "), 0, 1.3 * sx_Plot / GRAPHS_U_scale, 0);
      //if (impacts_source == databaseNumber_ENSEMBLE) //my_text(("[Members:" + String.valueOf(start_z) + "-" + String.valueOf(end_z) + "] "), 0, 1.3 * sx_Plot / GRAPHS_U_scale, 0);
      
      Diagrams_textSize(sx_Plot * 0.150 / GRAPHS_U_scale);
      Diagrams_textAlign(LEFT, CENTER); 
      if (Impact_TYPE == Impact_ACTIVE) {  
        my_text(("Direct solar radiation (kWh/m²)"), 0, 1.3 * sx_Plot / GRAPHS_U_scale, 0);
        //?? French
      }
      if (Impact_TYPE == Impact_PASSIVE) {  
        my_text(("Direct solar effects (kWh°C/m²)"), 0, 1.3 * sx_Plot / GRAPHS_U_scale, 0);
        //?? French
      }  
    }   
  } 



  if ((plot_impacts == 6) || (plot_impacts == 7)) {
    if (plot_impacts == 6) Impact_TYPE = Impact_ACTIVE; 
    if (plot_impacts == 7) Impact_TYPE = Impact_PASSIVE;

    float Pa = FLOAT_undefined;
    float Pb = FLOAT_undefined;
    float Pc = FLOAT_undefined;
    float Pd = FLOAT_undefined;

    float _values_R_dir;
    float _values_R_dif;
    float _values_E_dir;
    float _values_E_dif;
   
    int now_k = 0;
    int now_i = 0;
    int now_j = 0;

    int PAL_TYPE = 0; 
    int PAL_DIR = 1;
    
    if (Impact_TYPE == Impact_ACTIVE) {  
      //PAL_TYPE = Pallet_ACTIVE; PAL_DIR = Pallet_ACTIVE_DIR;
      //PAL_TYPE = 13; PAL_DIR = Pallet_ACTIVE_DIR; // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      PAL_TYPE = -1; PAL_DIR = 2;
    }
    if (Impact_TYPE == Impact_PASSIVE) {  
      PAL_TYPE = Pallet_PASSIVE; PAL_DIR = Pallet_PASSIVE_DIR;
    }             

    float _Multiplier = 1; 
    if (Impact_TYPE == Impact_ACTIVE) _Multiplier = 1.0;
    if (Impact_TYPE == Impact_PASSIVE) _Multiplier = 0.05;

    SOLARCHVISION_draw_Grid_Spherical_POSITION(x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot, 0);

 
    for (int j = j_start; j < j_end; j += 1) {

      now_j = (j * int(per_day) + BEGIN_DAY + 365) % 365;
  
      if (now_j >= 365) {
       now_j = now_j % 365; 
      }
      if (now_j < 0) {
       now_j = (now_j + 365) % 365; 
      }
 
      float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0); 

      float _sunrise = SOLARCHVISION_Sunrise(LocationLatitude, DATE_ANGLE); 
      float _sunset = SOLARCHVISION_Sunset(LocationLatitude, DATE_ANGLE);

      int[] Normals_COL_N;
      Normals_COL_N = new int[9];
      Normals_COL_N = SOLARCHVISION_PROCESS_DAILY_SCENARIOS(layers_count, start_z, end_z, j, DATE_ANGLE);
      
      for (int i = 0; i < 24; i += 1) {
      //for (int i = 10; i <= 14; i += 2) {
      //for (int i = 12; i <= 12; i += 2) {

        float HOUR_ANGLE = i; 
        float[] SunR = SOLARCHVISION_SunPosition(LocationLatitude, DATE_ANGLE, HOUR_ANGLE);
        
        float Alpha = 90 - acos_ang(SunR[3]);
        float Beta = 180 - atan2_ang(SunR[1], SunR[2]);

        now_i = i;
        now_j = int(j * per_day + BEGIN_DAY + 365) % 365;

        if (now_j >= 365) {
         now_j = now_j % 365; 
        }
        if (now_j < 0) {
         now_j = (now_j + 365) % 365; 
        }

        
        { // Direct 
          int RES1 = 50; // 100; 
          int RES2 = RES1;
          float ZOOM = 7200 / float(RES1); // ??? might not be correct!!!!
  
          PGraphics Image_RGBA = ViewFromTheSky(RES1,RES2,ZOOM, 0,0,0, 90-Alpha,0,Beta);

          Diagrams_imageMode(CENTER); 
          Diagrams_image(Image_RGBA, (j + obj_offset_x + (90 - Alpha) * obj_scale * (cos_ang(Beta - 90))) * sx_Plot, -((90 - Alpha) * obj_scale * (sin_ang(Beta - 90))) * sx_Plot, RES1, RES2);

          if (Materials_DirectArea_Flag[now_i][now_j] == -1) {

            Materials_DirectArea_Flag[now_i][now_j] = 1; 

            for (int mt = 0; mt < Materials_Number; mt++) {                 
              Materials_DirectArea[mt][now_i][now_j] = 0;
            }   
              
            if ((i > _sunrise) && (i < _sunset)) {
                     
              for (int np = 0; np < (RES1 * RES2); np++) {
                int Image_X = np % RES1;
                int Image_Y = np / RES1;
                
                color COL = Image_RGBA.get(Image_X, Image_Y);
  
                int COL_A = COL >> 24 & 0xFF;
                
                if (COL_A != 0) {
                  int COL_R = COL >> 16 & 0xFF; 
                  int COL_G = COL >> 8 & 0xFF; 
                  int COL_B = COL & 0xFF;
                  
                  for (int mt = 0; mt < Materials_Number; mt++) {  
                  
                    if ((COL_R == Materials_Color[mt][1]) && (COL_G == Materials_Color[mt][2]) && (COL_B == Materials_Color[mt][3])) {
                      Materials_DirectArea[mt][now_i][now_j] += 1;
                    }
                  }
                }
              }  
  
              for (int mt = 0; mt < Materials_Number; mt++) {                 
                Materials_DirectArea[mt][now_i][now_j] *= 0.975 * 1000.0 / (RES1 * RES2) ; //???
                
                if (Materials_Selection == mt) println("Direct:", mt, now_i, now_j, Materials_DirectArea[mt][now_i][now_j]); 
              }

              Diagrams_imageMode(CORNER);              
            }
          }
        }

        { // Diffuse
          int RES1 = 25; // 100; 
          int RES2 = RES1;
          float ZOOM = 7200 / float(RES1); // ??? might not be correct!!!!

          if (Materials_DiffuseArea_Flag[now_i][now_j] == -1) {
            
            Materials_DiffuseArea_Flag[now_i][now_j] = 1; 
            
            for (int mt = 0; mt < Materials_Number; mt++) {                 
              Materials_DiffuseArea[mt][now_i][now_j] = 0;
            }                 
            
            int num_diffuse_views = 0;
          
            for (int vNo = 1; vNo < skyVertices.length; vNo++) {
              
              float skyAngle_Alpha = asin_ang(skyVertices[vNo][2]);
              float skyAngle_Beta = atan2_ang(skyVertices[vNo][1], skyVertices[vNo][0]) + 90;
                
              if (skyAngle_Alpha >= 0) {
                
                num_diffuse_views += 1;
    
                PGraphics Image_RGBA = ViewFromTheSky(RES1,RES2,ZOOM, 0,0,0, 90-skyAngle_Alpha,0,skyAngle_Beta);
      
                Diagrams_imageMode(CENTER); 
                Diagrams_image(Image_RGBA, (j + obj_offset_x + (90 - skyAngle_Alpha) * obj_scale * (cos_ang(skyAngle_Beta - 90))) * sx_Plot, -((90 - skyAngle_Alpha) * obj_scale * (sin_ang(skyAngle_Beta - 90))) * sx_Plot, RES1, RES2);
                       
                for (int np = 0; np < (RES1 * RES2); np++) {
                  int Image_X = np % RES1;
                  int Image_Y = np / RES1;
                  
                  color COL = Image_RGBA.get(Image_X, Image_Y);
    
                  int COL_A = COL >> 24 & 0xFF;
                  
                  if (COL_A != 0) {
                    int COL_R = COL >> 16 & 0xFF; 
                    int COL_G = COL >> 8 & 0xFF; 
                    int COL_B = COL & 0xFF;
                    
                    for (int mt = 0; mt < Materials_Number; mt++) {  
                    
                      if ((COL_R == Materials_Color[mt][1]) && (COL_G == Materials_Color[mt][2]) && (COL_B == Materials_Color[mt][3])) {
                        Materials_DiffuseArea[mt][now_i][now_j] += 1;
                      }
                    }
                  }
                }  
    
                Diagrams_imageMode(CORNER);
              }
            }
            for (int mt = 0; mt < Materials_Number; mt++) {                 
              Materials_DiffuseArea[mt][now_i][now_j] *= 0.975 * 1000.0 / (RES1 * RES2); //???
              Materials_DiffuseArea[mt][now_i][now_j] *= 2.0 / float(num_diffuse_views); // note: multiply by 2 to have a area equal to roof!
              
              if (Materials_Selection == mt) println("Diffuse:", mt, now_i, now_j, Materials_DiffuseArea[mt][now_i][now_j]); 
            }
            
            //---------------------------------------------
            // applying calculated diffuse model at this time for the rest of year.
            for (int mt = 0; mt < Materials_Number; mt++) {
              for (int loop_i = 0; loop_i < 24; loop_i += 1) {
                for (int loop_j = 0; loop_j < 365; loop_j += 1) {
                  Materials_DiffuseArea[mt][loop_i][loop_j] = Materials_DiffuseArea[mt][now_i][now_j];
                  Materials_DiffuseArea_Flag[loop_i][loop_j] = 1;
                }
              }  
            }
            //---------------------------------------------                          
          }
        }
        
      }
    }
    
    if (GRAPHS_print_title != 0) {
    
      Diagrams_stroke(0); 
      Diagrams_fill(0);
      Diagrams_strokeWeight(GRAPHS_T_scale * 0);
      
      Diagrams_textSize(sx_Plot * 0.150 / GRAPHS_U_scale);
      Diagrams_textAlign(LEFT, CENTER); 
  
      my_text(("Solar perspectives"), 0, 1.3 * sx_Plot / GRAPHS_U_scale, 0);
    }   
  } 




  SOLARCHVISION_draw_Grid_DAILY(x_Plot, y_Plot, z_Plot, sx_Plot, sy_Plot, sz_Plot);

  pre_per_day = per_day;
  num_add_days = pre_num_add_days;

  Diagrams_popMatrix();
} 



void GRAPHS_keyPressed (KeyEvent e) {
    
  if (automated == 0) {
    X_clicked = 0;
    Y_clicked = 0;

    if (e.isAltDown() == true) {
      if (key == CODED) { 
        switch(keyCode) {

        }
      }
      else {
        switch(key) {
          case '0' : camera_variation = 0; GRAPHS_Update = 1; break;
          case '1' : camera_variation = 1; GRAPHS_Update = 1; break;
          case '2' : camera_variation = 2; GRAPHS_Update = 1; break;
          case '3' : camera_variation = 3; GRAPHS_Update = 1; break;
          case '4' : camera_variation = 4; GRAPHS_Update = 1; break;
          case '5' : camera_variation = 5; GRAPHS_Update = 1; break;
          case '6' : camera_variation = 6; GRAPHS_Update = 1; break;
          case '7' : camera_variation = 7; GRAPHS_Update = 1; break;
          case '8' : camera_variation = 8; GRAPHS_Update = 1; break;
          case '9' : camera_variation = 9; GRAPHS_Update = 1; break;
          
   
        }
      }    
    }
    else if (e.isControlDown() == true) {
      if (key == CODED) { 
        switch(keyCode) {

        }
      }
      else {
        switch(key) {

          case 'r' : GRAPHS_record_AUTO = (GRAPHS_record_AUTO + 1) % 2; GRAPHS_Update = 0; break;
  
          case 'j' : GRAPHS_record_JPG = 1; GRAPHS_Update = 1; break;
          case 'p' : GRAPHS_record_PDF = 1; GRAPHS_record_JPG = 0; GRAPHS_Update = 1; break; 
          
          case '^' : draw_data_lines = 1; save_info_node = 1; GRAPHS_record_JPG = 0; GRAPHS_Update = 1; break;
          case '&' : draw_normals = 1; save_info_norm = 1; GRAPHS_record_JPG = 0; GRAPHS_Update = 1; break;
          case '%' : draw_probs = 1; save_info_prob = 1; GRAPHS_record_JPG = 0; GRAPHS_Update = 1; break;                 
          
        }
      }    
    }
    else {
    
      if (key == CODED) { 
        switch(keyCode) {
          /*
          case 112 : develop_option = 1; update_DevelopDATA = 1; GRAPHS_Update = 1; break;
          case 113 : develop_option = 2; update_DevelopDATA = 1; GRAPHS_Update = 1; break;
          case 114 : develop_option = 3; update_DevelopDATA = 1; GRAPHS_Update = 1; break;
          case 115 : develop_option = 4; update_DevelopDATA = 1; GRAPHS_Update = 1; break;
          case 116 : develop_option = 5; update_DevelopDATA = 1; GRAPHS_Update = 1; break;
          case 117 : develop_option = 6; update_DevelopDATA = 1; GRAPHS_Update = 1; break;
          case 118 : develop_option = 7; update_DevelopDATA = 1; GRAPHS_Update = 1; break;
          case 119 : develop_option = 8; update_DevelopDATA = 1; GRAPHS_Update = 1; break;
          case 120 : develop_option = 9; update_DevelopDATA = 1; GRAPHS_Update = 1; break;
          case 121 : develop_option = 10; update_DevelopDATA = 1; GRAPHS_Update = 1; break;
          case 122 : develop_option = 11; update_DevelopDATA = 1; GRAPHS_Update = 1; break;
          case 123 : develop_option = 12; update_DevelopDATA = 1; GRAPHS_Update = 1; break;
          */
          
          case 112 : impacts_source = databaseNumber_ENSEMBLE; GRAPHS_Update = 1; break;
          case 113 : impacts_source = databaseNumber_CLIMATE_WY2; GRAPHS_Update = 1; break;
          case 114 : impacts_source = databaseNumber_CLIMATE_EPW; GRAPHS_Update = 1; break;
          //case 115 : impacts_source = databaseNumber_OBSERVED; GRAPHS_Update = 1; break;
          
          case 115 : if (((abs(plot_impacts) % 2 == 0) && (plot_impacts != 6)) || (plot_impacts == 7)) plot_impacts = 6;
                     else plot_impacts = 7; 
                     GRAPHS_Update = 1; break;        
  
          case 116 : if (((abs(plot_impacts) % 2 == 0) && (plot_impacts != 4)) || (plot_impacts == 5)) plot_impacts = 4;
                     else plot_impacts = 5; 
                     GRAPHS_Update = 1; break;
          case 117 : if (((abs(plot_impacts) % 2 == 0) && (plot_impacts != 2)) || (plot_impacts == 3)) plot_impacts = 2;
                     else plot_impacts = 3; 
                     GRAPHS_Update = 1; break;                   
          case 118 : if (((abs(plot_impacts) % 2 == 0) && (plot_impacts != 0)) || (plot_impacts == 1)) plot_impacts = 0;
                     else plot_impacts = 1; 
                     GRAPHS_Update = 1; break;           
          case 119 : if (((abs(plot_impacts) % 2 == 0) && (plot_impacts != -2)) || (plot_impacts == -1)) plot_impacts = -2;
                     else plot_impacts = -1; 
                     GRAPHS_Update = 1; break;
                     
          
          case 35  :_DATE += 1;
                    if (int(_DATE) == 365) _DATE -= 365;
                    if (int(_DATE) == 286) _YEAR += 1;
                    SOLARCHVISION_update_date(); 
                    SOLARCHVISION_try_update_forecast(_YEAR, _MONTH, _DAY, _HOUR);
                    GRAPHS_Update = 1; break;
                    
          case 36  :_DATE -= 1;
                    if (int(_DATE) < 0) _DATE += 365;
                    if (int(_DATE) == 285) _YEAR -= 1;
                    SOLARCHVISION_update_date(); 
                    SOLARCHVISION_try_update_forecast(_YEAR, _MONTH, _DAY, _HOUR);
                    GRAPHS_Update = 1; break;
       
          case 33:_DATE += 1; 
                    if (_DATE >= 365) _DATE -= 365;
                    if ((_DATE == 286) || (_DATE == 286.5)) _YEAR += 1;
                    SOLARCHVISION_update_date(); 
                    BEGIN_DAY = int(BEGIN_DAY + 1) % 365; 
                    SOLARCHVISION_try_update_forecast(_YEAR, _MONTH, _DAY, _HOUR);
                    GRAPHS_Update = 1; break; 
                    
          case 34 :_DATE -= 1; 
                    if (_DATE < 0) _DATE += 365;
                    if ((_DATE == 285) || (_DATE == 285.5)) _YEAR -= 1;
                    SOLARCHVISION_update_date(); 
                    BEGIN_DAY = int(365 + BEGIN_DAY - 1) % 365;
                    SOLARCHVISION_try_update_forecast(_YEAR, _MONTH, _DAY, _HOUR);
                    GRAPHS_Update = 1; break; 
                   
          case LEFT  :BEGIN_DAY = (365 + BEGIN_DAY - 1) % 365; GRAPHS_Update = 1; break;
          case RIGHT :BEGIN_DAY = (BEGIN_DAY + 1) % 365; GRAPHS_Update = 1; break;
                
          case UP   :drw_Layer = (drw_Layer + 1) % num_layers; GRAPHS_Update = 1; break;
          case DOWN :drw_Layer = (drw_Layer + num_layers - 1) % num_layers; GRAPHS_Update = 1; break; 
       
          default: GRAPHS_record_JPG = 0; GRAPHS_Update = 0; break;
        }
      }
      else {
        switch(key) {
    
          case '|' :if (_DATE == 1.0 * int(_DATE)) _DATE += 0.5;
                    else _DATE -= 0.5;
                    SOLARCHVISION_update_date(); 
                    SOLARCHVISION_try_update_forecast(_YEAR, _MONTH, _DAY, _HOUR);
                    GRAPHS_Update = 1; break;
                   
          case ';': draw_impact_summary = (draw_impact_summary + 1) % 2;
                    GRAPHS_Update = 1; break;
  
          case TAB :if ((impacts_source == databaseNumber_CLIMATE_WY2) || (impacts_source == databaseNumber_CLIMATE_EPW)) { 
                      if (per_day == 1) { 
                        per_day = int(365 / float(j_end - j_start));
                      }
                      else {
                        per_day = 1;
                      }
                    } 
                    if (impacts_source == databaseNumber_ENSEMBLE) {
                      per_day = 1;
                    }           
                    if (impacts_source == databaseNumber_OBSERVED) {
                      if (per_day == 1) { 
                        per_day = int(max_j_end_observed / float(j_end - j_start));
                      }
                      else {
                        per_day = 1;
                      }
                    }                     
                    update_DevelopDATA = 1;
                    GRAPHS_Update = 1; break;
                  
          case ']' :j_end += 1; 
                    if (j_end > j_start + 61) j_end -= 1;
                    GRAPHS_U_scale = 18.0 / float(j_end - j_start);
                    /*
                    if ((impacts_source == databaseNumber_CLIMATE_WY2) || (impacts_source == databaseNumber_CLIMATE_EPW)) { 
                      per_day = int(365 / float(j_end - j_start));
                    } 
                    if ((impacts_source == databaseNumber_ENSEMBLE) || (impacts_source == databaseNumber_OBSERVED)) {
                      per_day = 1;
                    }
                    */
                    update_DevelopDATA = 1;
                    GRAPHS_Update = 1; break; 
          case '[' :j_end -= 1; 
                    if (j_end <= j_start) j_end += 1;
                    GRAPHS_U_scale = 18.0 / float(j_end - j_start);
                    /*
                    if ((impacts_source == databaseNumber_CLIMATE_WY2) || (impacts_source == databaseNumber_CLIMATE_EPW)) { 
                      per_day = int(365 / float(j_end - j_start));
                    } 
                    if ((impacts_source == databaseNumber_ENSEMBLE) || (impacts_source == databaseNumber_OBSERVED)) {
                      per_day = 1;
                    }                  
                    */
                    update_DevelopDATA = 1;
                    GRAPHS_Update = 1; break;
  
          case '}' :join_hour_numbers += 1;
                    if (join_hour_numbers > 240) join_hour_numbers = 240;
                    update_DevelopDATA = 1;
                    GRAPHS_Update = 1; break; 
          case '{' :join_hour_numbers -= 1;
                    if (join_hour_numbers < 1) join_hour_numbers = 1;
                    update_DevelopDATA = 1;
                    GRAPHS_Update = 1; break; 
          /*      
          case '*' :join_type *= -1;
                    update_DevelopDATA = 1;
                    GRAPHS_Update = 1; break; 
          */
  
      
          case 'a'  :Angle_inclination -= 5;
                    if (Angle_inclination < -90) Angle_inclination = -90;
                    update_DevelopDATA = 1;
                    GRAPHS_Update = 1; break; 
          case 'A'  :Angle_inclination += 5;
                    if (Angle_inclination > 90) Angle_inclination = 90;
                    update_DevelopDATA = 1;
                    GRAPHS_Update = 1; break;
          case 'z' :Angle_orientation = (Angle_orientation - 5 + 360) % 360;
                    update_DevelopDATA = 1;
                    GRAPHS_Update = 1; break; 
          case 'Z' :Angle_orientation = (Angle_orientation + 5) % 360;
                    GRAPHS_Update = 1; break; 
          
          case 'd' :develop_per_day = (develop_per_day + 1) % 4;
                    update_DevelopDATA = 1;
                    GRAPHS_Update = 1; break; 
          case 'D' :develop_per_day = (develop_per_day - 1 + 4) % 4;
                    update_DevelopDATA = 1;
                    GRAPHS_Update = 1; break; 
        
          case '>' :if ((plot_impacts == -2) || (plot_impacts == -1)) {
                      GRAPHS_O_scale *= pow(2.0, (1.0 / 4.0)); 
                    }
                    else {
                      impact_layer = (impact_layer + 1) % 9; 
                    }
                    GRAPHS_Update = 1;
                    break;
          case '<' :if ((plot_impacts == -2) || (plot_impacts == -1)) {
                      GRAPHS_O_scale *= pow(0.5, (1.0 / 4.0)); 
                    }
                    else {
                      impact_layer = (impact_layer + 9 - 1) % 9;
                       
                    }
                    GRAPHS_Update = 1;
                    break;
  
          case 'y' :Sample_Year += 1; if (Sample_Year > CLIMATE_WY2_end) Sample_Year = CLIMATE_WY2_start; GRAPHS_Update = 1; break; 
          case 'Y' :Sample_Year -= 1; if (Sample_Year < CLIMATE_WY2_start) Sample_Year = CLIMATE_WY2_end; GRAPHS_Update = 1; break;
          case 'h' :H_layer_option = (H_layer_option + 1) % 8; GRAPHS_Update = 1; break;
          case 'H' :H_layer_option = (H_layer_option + 8 - 1) % 8; GRAPHS_Update = 1; break;
          case 'f' :F_layer_option = (F_layer_option + 1) % 5; GRAPHS_Update = 1; break;
          case 'F' :F_layer_option = (F_layer_option + 5 - 1) % 5; GRAPHS_Update = 1; break;
          case 'e' :Sample_Member += 1; if (Sample_Member > ENSEMBLE_end) Sample_Member = ENSEMBLE_start; GRAPHS_Update = 1; break; 
          case 'E' :Sample_Member -= 1; if (Sample_Member < ENSEMBLE_start) Sample_Member = ENSEMBLE_end; GRAPHS_Update = 1; break;
    
          case 'g' :filter_type = (filter_type + 1) % 2; GRAPHS_Update = 1; break;
          case 'G' :filter_type = (filter_type + 2 - 1) % 2; GRAPHS_Update = 1; break;
    
          case '=' :GRAPHS_V_scale[drw_Layer] *= pow(2.0, (1.0 / 2.0)); GRAPHS_Update = 1; break;
          case '_' :GRAPHS_V_scale[drw_Layer] *= pow(0.5, (1.0 / 2.0)); GRAPHS_Update = 1; break;
          
          case 'c' :COLOR_STYLE = (COLOR_STYLE + 1) % n_COLOR_STYLE; GRAPHS_Update = 1; break;
          case 'C' :COLOR_STYLE = (COLOR_STYLE - 1 + n_COLOR_STYLE) % n_COLOR_STYLE; GRAPHS_Update = 1; break;
          
          case 'V' :draw_data_lines = int((draw_data_lines + 1) % 2); GRAPHS_Update = 1; break;
          case 'v' :draw_data_lines = int((draw_data_lines + 1) % 2); GRAPHS_Update = 1; break;
    
          case '`' :num_add_days += 2;
                    if (num_add_days > 365) num_add_days = 365;
                    GRAPHS_Update = 1; break;
          case '~' :num_add_days -= 2;
                    if (num_add_days < 1) num_add_days = 1;
                    GRAPHS_Update = 1; break;
                    
          case 'l' :Materials_Selection += 1;
                    Materials_Selection %= Materials_Number; 
                    update_DevelopDATA = 1;
                    GRAPHS_Update = 1; break;
          case 'L' :Materials_Selection += Materials_Number - 1;
                    Materials_Selection %= Materials_Number;
                    update_DevelopDATA = 1; 
                    GRAPHS_Update = 1; break;  
          
          case 'm' :draw_sorted = int((draw_sorted + 1) % 2); GRAPHS_Update = 1; break;
          case 'M' :draw_sorted = int((draw_sorted + 1) % 2); GRAPHS_Update = 1; break;
    
          case 'n' :draw_normals = int((draw_normals + 1) % 2); GRAPHS_Update = 1; break;
          case 'N' :draw_normals = int((draw_normals + 1) % 2); GRAPHS_Update = 1; break;
    
          case 'b' :draw_probs = int((draw_probs + 1) % 2); GRAPHS_Update = 1; break;
          case 'B' :draw_probs = int((draw_probs + 1) % 2); GRAPHS_Update = 1; break;
          
          case 'j' :if (level_pix < 32) level_pix *= pow(2.0, (1.0 / 1.0)); GRAPHS_Update = 1; break;
          case 'J' :if (level_pix > 2) level_pix *= pow(0.5, (1.0 / 1.0)); GRAPHS_Update = 1; break;
    
          case 'i' :if (sum_interval > 24) sum_interval -= 24;
                    if (sum_interval > 6) sum_interval -= 6; 
                    else if (sum_interval > 1) sum_interval -= 1;
                    if (sum_interval == 5) sum_interval = 4;
                    println("sum_interval =", sum_interval);
                    GRAPHS_Update = 1; break;
          case 'I' :if (sum_interval < 6) sum_interval += 1;
                    else if (sum_interval < 24) sum_interval += 6;
                    else sum_interval += 24;
                    if (sum_interval == 5) sum_interval = 6;
                    println("sum_interval =", sum_interval);
                    GRAPHS_Update = 1; break;
                    
          case '!' :sky_scenario = 1; GRAPHS_Update = 1; break;
          case '@' :sky_scenario = 2; GRAPHS_Update = 1; break;
          case '#' :sky_scenario = 3; GRAPHS_Update = 1; break;
          case '$' :sky_scenario = 4; GRAPHS_Update = 1; break;
    

          
          default: GRAPHS_record_JPG = 0; GRAPHS_Update = 0; break;
        }
    
      }
    }
  }

  if (GRAPHS_Update == 1) {
    GRAPHS_Update = 1;
  }
  
}









void Diagrams_beginDraw () {
  if (off_screen == 1) {
    Diagrams.beginDraw();
  }
  else {
    
  } 
}


void Diagrams_endDraw () {
  if (off_screen == 1) {
    Diagrams.endDraw();
  }
  else {
    
  } 
}


void Diagrams_save (String a) {
  if (off_screen == 1) {
    Diagrams.save(a);
  }
  else {
    save(a);
  } 
}


void Diagrams_copy (PGraphics src, int sx, int sy, int sw, int sh, int dx, int dy, int dw, int dh) {
  if (off_screen == 1) {
    Diagrams.copy(src, sx, sy, sw, sh, dx, dy, dw, dh);
  }
  else {
    copy(src, sx, sy, sw, sh, dx, dy, dw, dh);
  } 
}


void Diagrams_imageMode (int a) {
  if (off_screen == 1) {
    Diagrams.imageMode(a);
  }
  else {
    imageMode(a);
  } 
}


void Diagrams_image (PImage img, float a, float b) {
  if (off_screen == 1) {
    Diagrams.image(img, a, b);
  }
  else {
    image(img, a, b);
  } 
}


void Diagrams_image (PImage img, float a, float b, float c, float d) {
  if (off_screen == 1) {
    Diagrams.image(img, a, b, c, d);
  }
  else {
    image(img, a, b, c, d);
  } 
}


void Diagrams_translate (float a, float b) {
  if (off_screen == 1) {
    Diagrams.translate(a, b);
  }
  else {
    translate(a, b);
  } 
}


void Diagrams_pushMatrix () {
  if (off_screen == 1) {
    Diagrams.pushMatrix();
  }
  else {
    pushMatrix();
  } 
}


void Diagrams_popMatrix () {
  if (off_screen == 1) {
    Diagrams.popMatrix();
  }
  else {
    popMatrix();
  } 
}


void Diagrams_background (float a) {
  if (off_screen == 1) {
    Diagrams.background(a);
  }
  else {
    //background(a); // we need to remark this to avoid CLS!
  } 
}


void Diagrams_blendMode (int a) {
  if (off_screen == 1) {
    Diagrams.blendMode(a);
  }
  else {
    blendMode(a);
  } 
}


void Diagrams_strokeJoin (int a) {
  if (off_screen == 1) {
    Diagrams.strokeJoin(a);
  }
  else {
    strokeJoin(a);
  } 
}


void Diagrams_textFont (PFont a) {
  if (off_screen == 1) {
    Diagrams.textFont(a);
  }
  else {
    textFont(a);
  } 
}


void Diagrams_strokeWeight (float a) {
  if (off_screen == 1) {
    Diagrams.strokeWeight(a);
  }
  else {
    strokeWeight(a);
  } 
}


void Diagrams_stroke (float a) {
  if (off_screen == 1) {
    Diagrams.stroke(a);
  }
  else {
    stroke(a);
  } 
}

void Diagrams_stroke (float a, float b) {
  if (off_screen == 1) {
    Diagrams.stroke(a, b);
  }
  else {
    stroke(a, b);
  } 
}

void Diagrams_stroke (float a, float b, float c) {
  if (off_screen == 1) {
    Diagrams.stroke(a, b, c);
  }
  else {
    stroke(a, b, c);
  } 
}

void Diagrams_stroke (float a, float b, float c, float d) {
  if (off_screen == 1) {
    Diagrams.stroke(a, b, c, d);
  }
  else {
    stroke(a, b, c, d);
  } 
}

void Diagrams_fill (float a) {
  if (off_screen == 1) {
    Diagrams.fill(a);
  }
  else {
    fill(a);
  } 
}

void Diagrams_fill (float a, float b) {
  if (off_screen == 1) {
    Diagrams.fill(a, b);
  }
  else {
    fill(a, b);
  } 
}

void Diagrams_fill (float a, float b, float c) {
  if (off_screen == 1) {
    Diagrams.fill(a, b, c);
  }
  else {
    fill(a, b, c);
  } 
}

void Diagrams_fill (float a, float b, float c, float d) {
  if (off_screen == 1) {
    Diagrams.fill(a, b, c, d);
  }
  else {
    fill(a, b, c, d);
  } 
}

void Diagrams_noFill () {
  if (off_screen == 1) {
    Diagrams.noFill();
  }
  else {
    noFill();
  } 
}


void Diagrams_textAlign (int a, int b) {
  if (off_screen == 1) {
    Diagrams.textAlign(a, b);
  }
  else {
    textAlign(a, b);
  } 
}


void Diagrams_textSize (float a) {
  if (off_screen == 1) {
    Diagrams.textSize(a * 1.25);
  }
  else {
    textSize(a * 1.25);
  } 
}


void Diagrams_text (String s, float a, float b) {
  if (off_screen == 1) {
    Diagrams.text(s, a, b);
  }
  else {
    text(s, a, b);
  } 
}


void Diagrams_ellipse (float a, float b, float c, float d) {
  if (off_screen == 1) {
    Diagrams.ellipse(a, b, c, d);
  }
  else {
    ellipse(a, b, c, d);
  } 
}


void Diagrams_line (float a, float b, float c, float d) {
  if (off_screen == 1) {
    Diagrams.line(a, b, c, d);
  }
  else {
    line(a, b, c, d);
  } 
}


void Diagrams_rect (float a, float b, float c, float d) {
  if (off_screen == 1) {
    Diagrams.rect(a, b, c, d);
  }
  else {
    rect(a, b, c, d);
  } 
}


void Diagrams_quad (float ax, float ay, float bx, float by, float cx, float cy, float dx, float dy) {
  if (off_screen == 1) {
    Diagrams.quad(ax, ay, bx, by, cx, cy, dx, dy);
  }
  else {
    quad(ax, ay, bx, by, cx, cy, dx, dy);
  } 
}




float[] SOLARCHVISION_DRYW (float _variable) {
  _variable = 1 - _variable;
  _variable *= -3;

  float v;
  float[] COL = {
    255, 0, 0, 0
  };
  if (_variable < -3) {
    COL[1] = 0;
    COL[2] = 0;
    COL[3] = 0;
  } else if (_variable < -2) {
    v = (-(_variable + 2) * 255);
    COL[1] = 255 - v;
    COL[2] = 0;
    COL[3] = 0;
  } else if (_variable < -1) {
    v = (-(_variable + 1) * 255);
    COL[1] = 255;
    COL[2] = 255 - v;
    COL[3] = 0;
  } else if (_variable < 0) {
    v = (-_variable * 255);
    COL[1] = 255;
    COL[2] = 255;
    COL[3] = 255 - v;
  } else {
    COL[1] = 255;
    COL[2] = 255;
    COL[3] = 255;
  }
  
  return COL;
}

float[] SOLARCHVISION_WYRD (float _variable) {
  _variable *= -3;

  float v;
  float[] COL = {
    255, 0, 0, 0
  };
  if (_variable < -3) {
    COL[1] = 0;
    COL[2] = 0;
    COL[3] = 0;
  } else if (_variable < -2) {
    v = (-(_variable + 2) * 255);
    COL[1] = 255 - v;
    COL[2] = 0;
    COL[3] = 0;
  } else if (_variable < -1) {
    v = (-(_variable + 1) * 255);
    COL[1] = 255;
    COL[2] = 255 - v;
    COL[3] = 0;
  } else if (_variable < 0) {
    v = (-_variable * 255);
    COL[1] = 255;
    COL[2] = 255;
    COL[3] = 255 - v;
  } else {
    COL[1] = 255;
    COL[2] = 255;
    COL[3] = 255;
  }

  return COL;
}


 
void SOLARCHVISION_SunPath (float x_SunPath, float y_SunPath, float z_SunPath, float s_SunPath, float LocationLatitude) { 

  float previous_DATE = _DATE;
  
  float min_sunrise = int(min(SOLARCHVISION_Sunrise(LocationLatitude, 90), SOLARCHVISION_Sunrise(LocationLatitude, 270))); 
  float max_sunset = int(max(SOLARCHVISION_Sunset(LocationLatitude, 90), SOLARCHVISION_Sunset(LocationLatitude, 270)));

  
  WIN3D_Diagrams.pushMatrix();
  WIN3D_Diagrams.translate(x_SunPath, y_SunPath, z_SunPath);

  WIN3D_Diagrams.strokeWeight(0); 
  WIN3D_Diagrams.stroke(0, 0, 0);
  WIN3D_Diagrams.fill(0, 0, 0);
  
  WIN3D_Diagrams.line(-1 * s_SunPath, 0, 0, 1 * s_SunPath, 0, 0); 
  WIN3D_Diagrams.line(0, -1 * s_SunPath, 0, 0, 1 * s_SunPath, 0);

  WIN3D_Diagrams.stroke(255, 255, 0);
  
  float pre_per_day = per_day;
  int pre_num_add_days = num_add_days;
  if ((impacts_source == databaseNumber_ENSEMBLE) || (impacts_source == databaseNumber_OBSERVED)) {
    per_day = 1;
    num_add_days = 1;
  }
  
  int start_z = get_startZ_endZ(impacts_source)[0];
  int end_z = get_startZ_endZ(impacts_source)[1]; 
  int layers_count = get_startZ_endZ(impacts_source)[2]; 
  
  for (int p = 0; p < 1; p += 1) { 
    
    int l = impact_layer;
  
    int DATE_step = 1;
  
    for (int j = j_start; j < j_end; j += DATE_step) {
      
      int now_i;
      int now_j;
      int now_k;
  
      now_j = (j * int(per_day) + BEGIN_DAY + 365) % 365;
  
      if (now_j >= 365) {
       now_j = now_j % 365; 
      }
      if (now_j < 0) {
       now_j = (now_j + 365) % 365; 
      }
   
      float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0); 
      
      //println(j, now_j, DATE_ANGLE);
     
      float _sunrise = SOLARCHVISION_Sunrise(LocationLatitude, DATE_ANGLE); 
      float _sunset = SOLARCHVISION_Sunset(LocationLatitude, DATE_ANGLE);
      
      int[] Normals_COL_N;
      Normals_COL_N = new int[9];
      Normals_COL_N = SOLARCHVISION_PROCESS_DAILY_SCENARIOS(layers_count, start_z, end_z, j, DATE_ANGLE);
      
      for (int nk = Normals_COL_N[l]; nk <= Normals_COL_N[l]; nk += 1) {
        if (nk != -1) {
          int k = int(nk / num_add_days);
          int j_ADD = nk % num_add_days; 
  
          for (int i = 0; i < 24; i += 1) {
            
            float HOUR_ANGLE = i; 
            float[] SunR = SOLARCHVISION_SunPosition(LocationLatitude, DATE_ANGLE, HOUR_ANGLE);
            
            now_k = k;
            now_i = i;
            now_j = int(j * per_day + (j_ADD - int(0.5 * num_add_days)) + BEGIN_DAY + 365) % 365;
  
            if (now_j >= 365) {
             now_j = now_j % 365; 
            }
            if (now_j < 0) {
             now_j = (now_j + 365) % 365; 
            }
            
            float Pa = FLOAT_undefined;
  
            if (impacts_source == databaseNumber_CLIMATE_WY2) {
                Pa = CLIMATE_WY2[now_i][now_j][_direffect][now_k]; 
            }
            if (impacts_source == databaseNumber_ENSEMBLE) {
                Pa = ENSEMBLE[now_i][now_j][_direffect][now_k]; 
            }   
            if (impacts_source == databaseNumber_OBSERVED) {
                Pa = OBSERVED[now_i][now_j][_direffect][now_k]; 
            }   
            if (impacts_source == databaseNumber_CLIMATE_EPW) {
                Pa = CLIMATE_EPW[now_i][now_j][_direffect][now_k]; 
            }    
 
            if (Pa > 0.9 * FLOAT_undefined) {
            }
            else {
           
              float[] COL = SOLARCHVISION_DRYWCBD(0.0002 * Pa); // ????????
      
              WIN3D_Diagrams.stroke(COL[1], COL[2], COL[3], 127);
              WIN3D_Diagrams.fill(COL[1], COL[2], COL[3], 127);
              
              float[] SunA = SOLARCHVISION_SunPosition(LocationLatitude, DATE_ANGLE - 0.5 * DATE_step, HOUR_ANGLE - 0.5);
              float[] SunB = SOLARCHVISION_SunPosition(LocationLatitude, DATE_ANGLE - 0.5 * DATE_step, HOUR_ANGLE + 0.5);
              float[] SunC = SOLARCHVISION_SunPosition(LocationLatitude, DATE_ANGLE + 0.5 * DATE_step, HOUR_ANGLE + 0.5);
              float[] SunD = SOLARCHVISION_SunPosition(LocationLatitude, DATE_ANGLE + 0.5 * DATE_step, HOUR_ANGLE - 0.5);
              
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
    }
  }  

  WIN3D_Diagrams.strokeWeight(1);
  WIN3D_Diagrams.stroke(0);
  
  for (int j = 90; j <= 270; j += 30) {
    float HOUR_step = (SOLARCHVISION_DayTime(LocationLatitude, j) / 12.0);
    for (float HOUR = SOLARCHVISION_Sunrise(LocationLatitude, j); HOUR <(SOLARCHVISION_Sunset(LocationLatitude, j) + .01 - HOUR_step); HOUR += HOUR_step) {
      float[] SunA = SOLARCHVISION_SunPosition(LocationLatitude, j, HOUR);
      float[] SunB = SOLARCHVISION_SunPosition(LocationLatitude, j, (HOUR + HOUR_step));
      WIN3D_Diagrams.line(s_SunPath * SunA[1], -s_SunPath * SunA[2], s_SunPath * SunA[3], s_SunPath * SunB[1], -s_SunPath * SunB[2], s_SunPath * SunB[3]);
    }
  }
  
  for (float HOUR = min_sunrise; HOUR < max_sunset + .01; HOUR += 1) {
    float DATE_step = 1;
    for (int j = 0; j <= 360; j += DATE_step) {
      float[] SunA = SOLARCHVISION_SunPosition(LocationLatitude, j, HOUR);
      float[] SunB = SOLARCHVISION_SunPosition(LocationLatitude, (j + DATE_step), HOUR);
      if (SunA[3] >= 0 && SunB[3] >= 0) {
        WIN3D_Diagrams.line(s_SunPath * SunA[1], -s_SunPath * SunA[2], s_SunPath * SunA[3], s_SunPath * SunB[1], -s_SunPath * SunB[2], s_SunPath * SunB[3]);
      }
    }
  }
  
  WIN3D_Diagrams.popMatrix();

  WIN3D_Diagrams.stroke(0);
  for (int i = 0; i < 360; i += 5) {
    WIN3D_Diagrams.line(s_SunPath * cos(i * PI / 180), -s_SunPath * sin(i * PI / 180), 0, s_SunPath * cos((i + 5) * PI / 180), -s_SunPath * sin((i + 5) * PI / 180), 0); 
    
    WIN3D_Diagrams.line(s_SunPath * cos(i * PI / 180), -s_SunPath * sin(i * PI / 180), 0, 1.05 * s_SunPath * cos((i) * PI / 180), -1.05 * s_SunPath * sin((i) * PI / 180), 0);
  }
  
  for (int i = 0; i < 360; i += 15) {
    WIN3D_Diagrams.pushMatrix();
    WIN3D_Diagrams.translate(1.15 * s_SunPath * cos(i * PI / 180), -1.15 * s_SunPath * sin(i * PI / 180), 0);
    
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

  per_day = pre_per_day;
  num_add_days = pre_num_add_days; 
  _DATE = previous_DATE;
  SOLARCHVISION_update_date();
} 



void WIN3D_keyPressed (KeyEvent e) {

  if (e.isAltDown() == true) {
    if (key == CODED) { 
      switch(keyCode) {

        case RIGHT :Field_Image_rotation[display_Field_Image] = (Field_Image_rotation[display_Field_Image] + 15) % 360; 
                  if (display_Field_Image != 0) SOLARCHVISION_calculate_ParametricGeometries_Field(); WIN3D_Update = 1; 
                  break;
        case LEFT :Field_Image_rotation[display_Field_Image] = (Field_Image_rotation[display_Field_Image] + 360 - 15) % 360; 
                  if (display_Field_Image != 0) SOLARCHVISION_calculate_ParametricGeometries_Field(); WIN3D_Update = 1; 
                  break;           
        
        case UP   :Field_Elevation[display_Field_Image] += 2.5;
                  if (display_Field_Image != 0) SOLARCHVISION_calculate_ParametricGeometries_Field(); WIN3D_Update = 1; 
                  break;        
        case DOWN :Field_Elevation[display_Field_Image] -= 2.5; 
                  if (display_Field_Image != 0) SOLARCHVISION_calculate_ParametricGeometries_Field(); WIN3D_Update = 1; 
                  break; 

        case 33 :Field_Elevation[display_Field_Image] += 10;
                  if (display_Field_Image != 0) SOLARCHVISION_calculate_ParametricGeometries_Field(); WIN3D_Update = 1; 
                  break;        
        case 34 :Field_Elevation[display_Field_Image] -= 10; 
                  if (display_Field_Image != 0) SOLARCHVISION_calculate_ParametricGeometries_Field(); WIN3D_Update = 1; 
                  break; 
        
        case 35 :Field_scale_U *= pow(2.0, 0.5); Field_scale_V *= pow(2.0, 0.5); 
                  if (display_Field_Image != 0) SOLARCHVISION_calculate_ParametricGeometries_Field(); WIN3D_Update = 1; 
                  break;
        case 36 :Field_scale_U /= pow(2.0, 0.5); Field_scale_V /= pow(2.0, 0.5);                   
                  if (display_Field_Image != 0) SOLARCHVISION_calculate_ParametricGeometries_Field(); WIN3D_Update = 1; 
                  break;
                 
      }
    }
    else {
      switch(key) {

        case ']' :display_Field_Image = (display_Field_Image + 1) % 4; 
                  if (display_Field_Image != 0) SOLARCHVISION_calculate_ParametricGeometries_Field(); WIN3D_Update = 1; 
                  break;
        case '[' :display_Field_Image = (display_Field_Image + 4 - 1) % 4;
                  if (display_Field_Image != 0) SOLARCHVISION_calculate_ParametricGeometries_Field(); WIN3D_Update = 1; 
                  break;        
        
        case '0' :Field_Elevation[display_Field_Image] = 0; 
                  if (display_Field_Image != 0) SOLARCHVISION_calculate_ParametricGeometries_Field(); WIN3D_Update = 1; 
                  break;
                  
        case '.' :Field_Image_rotation[display_Field_Image] = 0; 
                  if (display_Field_Image != 0) SOLARCHVISION_calculate_ParametricGeometries_Field(); WIN3D_Update = 1; 
                  break;                  
        
        case '/' :Field_Image_Power *= pow(2.0, 0.5); 
                  if (display_Field_Image != 0) SOLARCHVISION_calculate_ParametricGeometries_Field(); WIN3D_Update = 1; 
                  break;
        case '*' :Field_Image_Power /= pow(2.0, 0.5);  
                  if (display_Field_Image != 0) SOLARCHVISION_calculate_ParametricGeometries_Field(); WIN3D_Update = 1; 
                  break;
        
        case '+' :Field_Multiplier *= pow(2.0, 0.5); 
                  if (display_Field_Image != 0) SOLARCHVISION_calculate_ParametricGeometries_Field(); WIN3D_Update = 1; 
                  break;
        case '-' :Field_Multiplier /= pow(2.0, 0.5); 
                  if (display_Field_Image != 0) SOLARCHVISION_calculate_ParametricGeometries_Field(); WIN3D_Update = 1; 
                  break;

        case '>' :Field_Multiplier /= pow(2.0, 0.25); 
                  Field_Image_Power /= pow(2.0, 0.5); 
                  if (display_Field_Image != 0) SOLARCHVISION_calculate_ParametricGeometries_Field(); WIN3D_Update = 1; 
                  break;
        case '<' :Field_Multiplier *= pow(2.0, 0.25); 
                  Field_Image_Power *= pow(2.0, 0.5); 
                  if (display_Field_Image != 0) SOLARCHVISION_calculate_ParametricGeometries_Field(); WIN3D_Update = 1; 
                  break;


 
      }
    }    
  }

 
  else if (e.isControlDown() == true) {
    if (key == CODED) { 
      switch(keyCode) {
        
        case LEFT  :WIN3D_X_coordinate += WIN3D_S_coordinate; WIN3D_Update = 1; break;
        case RIGHT :WIN3D_X_coordinate -= WIN3D_S_coordinate; WIN3D_Update = 1; break; 
        case UP    :WIN3D_Y_coordinate += WIN3D_S_coordinate; WIN3D_Update = 1; break;
        case DOWN  :WIN3D_Y_coordinate -= WIN3D_S_coordinate; WIN3D_Update = 1; break;
      }
    }
    else {
      switch(key) {
        case '0' :WIN3D_X_coordinate = 0;
                  WIN3D_Y_coordinate = 0;
                  WIN3D_Update = 1; break;
          
        case '2' :display_allyObject2D = (display_allyObject2D + 1) % 2; WIN3D_Update = 1; break;
 
      }
    }    
  }
  else {
    
    if (key == CODED) { 
      switch(keyCode) {

      }
    }
    else {
      switch(key) {
        case ',' :WIN3D_Z_coordinate += WIN3D_S_coordinate; WIN3D_Update = 1; break; 
        case '.' :WIN3D_Z_coordinate -= WIN3D_S_coordinate; WIN3D_Update = 1; break;
  
        case '0' :WIN3D_Z_coordinate += WIN3D_S_coordinate; WIN3D_Update = 1; break;
        
        case '5' :WIN3D_RX_coordinate = 0;
                  WIN3D_RY_coordinate = 0;
                  WIN3D_RZ_coordinate = 0; 
                  
                  WIN3D_X_coordinate = 0;
                  WIN3D_Y_coordinate = 0;
                  WIN3D_Z_coordinate = 0;   
   
                  //WIN3D_ZOOM_coordinate = 60;               
                  WIN3D_Update = 1; break;

        case '1' :WIN3D_RX_coordinate = 45; WIN3D_RY_coordinate = 0; WIN3D_RZ_coordinate = 315; WIN3D_Update = 1; break;
        case '3' :WIN3D_RX_coordinate = 45; WIN3D_RY_coordinate = 0; WIN3D_RZ_coordinate = 45; WIN3D_Update = 1; break;
        case '7' :WIN3D_RX_coordinate = 45; WIN3D_RY_coordinate = 0; WIN3D_RZ_coordinate = 225; WIN3D_Update = 1; break;
        case '9' :WIN3D_RX_coordinate = 45; WIN3D_RY_coordinate = 0; WIN3D_RZ_coordinate = 135; WIN3D_Update = 1; break;
  
        case '2' :WIN3D_RX_coordinate += WIN3D_RS_coordinate; WIN3D_Update = 1; break;
        case '4' :WIN3D_RZ_coordinate -= WIN3D_RS_coordinate; WIN3D_Update = 1; break;
        case '6' :WIN3D_RZ_coordinate += WIN3D_RS_coordinate; WIN3D_Update = 1; break; 
        case '8' :WIN3D_RX_coordinate -= WIN3D_RS_coordinate; WIN3D_Update = 1; break;
  
        case '*' :objects_scale *= 2.0; WIN3D_Update = 1; break;
        case '/' :objects_scale /= 2.0; WIN3D_Update = 1; break;
  
        case '+' :WIN3D_ZOOM_coordinate = 2 * atan_ang((1.0 / 1.1) * tan_ang(0.5 * WIN3D_ZOOM_coordinate)); WIN3D_Update = 1; break;
        case '-' :WIN3D_ZOOM_coordinate = 2 * atan_ang((1.1 / 1.0) * tan_ang(0.5 * WIN3D_ZOOM_coordinate)); WIN3D_Update = 1; break; 
        
        case 'O' :WIN3D_View_Type = 0; WIN3D_Update = 1; break;
        case 'o' :WIN3D_View_Type = 0; WIN3D_Update = 1; break;
        
        case 'P' :WIN3D_View_Type = 1; WIN3D_Update = 1; break; 
        case 'p' :WIN3D_View_Type = 1; WIN3D_Update = 1; break; 
  
        //case 'E' :WIN3D_EDGES_SHOW = (WIN3D_EDGES_SHOW + 1) % 2; WIN3D_Update = 1; break; 
        //case 'e' :WIN3D_EDGES_SHOW = (WIN3D_EDGES_SHOW + 1) % 2; WIN3D_Update = 1; break; 
  
        case 'K' :WIN3D_FACES_SHADE = (WIN3D_FACES_SHADE + 5 - 1) % 5; WIN3D_Update = 1;
                  if (WIN3D_FACES_SHADE == 3) SolarProjection(); 
                  break;
        case 'k' :WIN3D_FACES_SHADE = (WIN3D_FACES_SHADE + 1) % 5; WIN3D_Update = 1;
                  if (WIN3D_FACES_SHADE == 3) SolarProjection(); 
                  break; 
         
        
        case 't' :MODEL3D_TESELATION += 1; WIN3D_update_VerticesSolarValue = 1; WIN3D_Update = 1; break; 
        case 'T' :MODEL3D_TESELATION -= 1;
                  if (MODEL3D_TESELATION < 0) MODEL3D_TESELATION = 0;
                  WIN3D_update_VerticesSolarValue = 1; 
                  WIN3D_Update = 1; break;
                  
        case ENTER: if (WIN3D_FACES_SHADE == 3) SolarProjection();  
                    if (WIN3D_FACES_SHADE == 4) WIN3D_update_VerticesSolarValue = 1; WIN3D_Update = 1; 
                    break;                  
          
        case ' ': SavedScreenShots += 1; 
                  saveFrame("/Output/" + nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + "_IMG" + nf(SavedScreenShots , 3) + ".jpg");
                  WIN3D_Update = 1; break;              
          



        case 'F' :LoadFontStyle(); WIN3D_Update = 1; break;
        case 'f' :LoadFontStyle(); WIN3D_Update = 1; break;
        
        
        case 'x' :SOLARCHVISION_export_objects(); WIN3D_Update = 1; break;
        case 'X' :SOLARCHVISION_export_objects(); WIN3D_Update = 1; break;
        
      }
    }
  }
}

int frame_variation = 0;

void SOLARCHVISION_update_frame_layout () {
 
 if (frame_variation == 0) {

    GRAPHS_include = 1;
    WIN3D_include = 1;
    WORLD_include = 1;
   
    GRAPHS_CX_View = 0;
    GRAPHS_CY_View = 0;
    GRAPHS_X_View = 2 * w_pixel;
    GRAPHS_Y_View = 1 * h_pixel;
    GRAPHS_R_View = float(GRAPHS_Y_View) / float(GRAPHS_X_View);   
   
    WIN3D_CX_View = 0;
    WIN3D_CY_View = h_pixel;
    WIN3D_X_View = w_pixel;
    WIN3D_Y_View = h_pixel;
    WIN3D_R_View = float(WIN3D_Y_View) / float(WIN3D_X_View);
    WIN3D_Diagrams = createGraphics(WIN3D_X_View, WIN3D_Y_View, P3D);
    
    WORLD_CX_View = w_pixel;
    WORLD_CY_View = h_pixel;
    WORLD_X_View = w_pixel;
    WORLD_Y_View = h_pixel;
    WORLD_R_View = float(WORLD_Y_View) / float(WORLD_X_View);
    WORLD_Diagrams = createGraphics(WORLD_X_View, WORLD_Y_View, P2D);    
 }
 else if (frame_variation == 1) {
   
    GRAPHS_include = 0;
    WIN3D_include = 0;
    WORLD_include = 1;
   
    WORLD_CX_View = 0;
    WORLD_CY_View = 0;
    WORLD_X_View = 2 * w_pixel;
    WORLD_Y_View = 2 * h_pixel;
    WORLD_R_View = float(WORLD_Y_View) / float(WORLD_X_View);
    WORLD_Diagrams = createGraphics(WORLD_X_View, WORLD_Y_View, P2D);    
 }    
 else if (frame_variation == 2) {

    GRAPHS_include = 0;
    WIN3D_include = 1;
    WORLD_include = 0;
   
    WIN3D_CX_View = 0;
    WIN3D_CY_View = 0;
    WIN3D_X_View = 2 * w_pixel;
    WIN3D_Y_View = 2 * h_pixel;
    WIN3D_R_View = float(WIN3D_Y_View) / float(WIN3D_X_View);
    WIN3D_Diagrams = createGraphics(WIN3D_X_View, WIN3D_Y_View, P3D);
 }
 else if (frame_variation == 3) {

    GRAPHS_include = 1;
    WIN3D_include = 0;
    WORLD_include = 0;
   
    GRAPHS_CX_View = 0;
    GRAPHS_CY_View = 0;
    GRAPHS_X_View = 2 * w_pixel;
    GRAPHS_Y_View = 2 * h_pixel;
    GRAPHS_R_View = float(GRAPHS_Y_View) / float(GRAPHS_X_View);   
  }
 
  WORLD_Update = 1;
  WIN3D_Update = 1; 
  GRAPHS_Update = 1;    
    
}
    

void keyPressed (KeyEvent e) {

  //println("key: " + key);
  //println("keyCode: " + keyCode);
  
  if (frameCount > last_initializationStep) {  

    GRAPHS_keyPressed(e);
  
    WIN3D_keyPressed(e);

    if (e.isAltDown() == true) {
      if (key == CODED) { 
        switch(keyCode) {
          case 112 : ROLLOUT_child = 1; ROLLOUT_Update = 1; break;
          case 113 : ROLLOUT_child = 2; ROLLOUT_Update = 1; break;
          case 114 : ROLLOUT_child = 3; ROLLOUT_Update = 1; break;
          case 115 : ROLLOUT_child = 4; ROLLOUT_Update = 1; break;
          case 116 : ROLLOUT_child = 5; ROLLOUT_Update = 1; break;
          case 117 : ROLLOUT_child = 6; ROLLOUT_Update = 1; break;
          case 118 : ROLLOUT_child = 7; ROLLOUT_Update = 1; break;
          case 119 : ROLLOUT_child = 8; ROLLOUT_Update = 1; break;
        }
      }
      else {
        switch(key) {
          case 'l' : frame_variation = (frame_variation + 1) % 4; SOLARCHVISION_update_frame_layout(); break;
          case 'L' : frame_variation = (frame_variation + 4 - 1) % 4; SOLARCHVISION_update_frame_layout(); break;
        }
      }    
    }
    else if (e.isControlDown() == true) {
      if (key == CODED) { 
        switch(keyCode) {
          case 112 : ROLLOUT_parent = 0; ROLLOUT_Update = 1; break;
          case 113 : ROLLOUT_parent = 1; ROLLOUT_Update = 1; break;
          case 114 : ROLLOUT_parent = 2; ROLLOUT_Update = 1; break;
          case 115 : ROLLOUT_parent = 3; ROLLOUT_Update = 1; break;
          case 116 : ROLLOUT_parent = 4; ROLLOUT_Update = 1; break;
          case 117 : ROLLOUT_parent = 5; ROLLOUT_Update = 1; break;
          case 118 : ROLLOUT_parent = 6; ROLLOUT_Update = 1; break;
          case 119 : ROLLOUT_parent = 7; ROLLOUT_Update = 1; break;
        }
      }
      else {
        switch(key) {
        }
      }    
    }
    else {
      if (key == CODED) { 
        switch(keyCode) {
        }
      }
      else {
        switch(key) {
          
          case 's' :STATION_NUMBER = (STATION_NUMBER + 1) % DEFINED_STATIONS.length; 
                    //SOLARCHVISION_update_station(0); GRAPHS_Update = 1; WIN3D_Update = 1; 
                    frameCount = 8; loop(); 
                    break;
          case 'S' :STATION_NUMBER = (STATION_NUMBER - 1 + DEFINED_STATIONS.length) % DEFINED_STATIONS.length; 
                    //SOLARCHVISION_update_station(0); GRAPHS_Update = 1; WIN3D_Update = 1; 
                    frameCount = 8; loop();
                    break;          
        }
      }  
    }      

    if ((GRAPHS_Update != 0) || (WORLD_Update != 0) || (WIN3D_Update != 0) || (ROLLOUT_Update != 0)) redraw();    
  }
}


float EquationOfTime (float DateAngle) {
  float b = DateAngle;

  return 0.01  * (9.87 * sin_ang(2 * b) - 7.53 * cos_ang(b) - 1.5 * sin_ang(b));
}

float E = 2.7182818284;

float[] SOLARCHVISION_SunPositionRadiation (float LocationLatitude, float DateAngle, float HourAngleOrigin, float CloudCover) {
  float HourAngle = HourAngleOrigin + EquationOfTime(DateAngle); 
  
  float Declination = 23.45 * sin_ang(DateAngle - 180.0);
  
  float a = sin_ang(Declination);
  float b = cos_ang(Declination) * -cos_ang(15.0 * HourAngleOrigin);
  float c = cos_ang(Declination) *  sin_ang(15.0 * HourAngleOrigin);
  
  float x = c; 
  float y = -(a * cos_ang(LocationLatitude) + b * sin_ang(LocationLatitude));
  float z = -a * sin_ang(LocationLatitude) + b * cos_ang(LocationLatitude);
  
  float Io = 1367.0; // W/m²
  Io = Io * (1.0 - (0.0334 * sin_ang(DateAngle)));
  
  float ALT_ = (asin_ang(z)) * PI / 180; 
  float ALT_true = ALT_ + 0.061359 * (0.1594 + 1.1230 * ALT_ + 0.065656 * ALT_ * ALT_) / (1 + 28.9344 * ALT_ + 277.3971 * ALT_ * ALT_);
  
  float PPo = pow(E, (-LocationElevation / 8435.2));
  float Bb = ((sin_ang (ALT_true * 180 / PI)) + (0.50572 * pow((57.29578 * ALT_true + 6.07995), -1.6364)));
  float m = PPo / Bb;
  
  float StationTurbidity;

  StationTurbidity = (2.0 - 0.2) * (0.1 * CloudCover) + 0.2;
  
  float AtmosphereRatio;
  if (z < 0.01) AtmosphereRatio = 0.0; 
  else AtmosphereRatio = pow(E, (-m * StationTurbidity));
    
  float Idirect = Io * AtmosphereRatio; // Optical air mass: global Meteorological Database for Engineers, Planners and Education; Version 5.00 - Edition 2003
  
  float Idiffuse;
  if (z < 0.01) Idiffuse = 0.0;
  else Idiffuse = ((0.5 + 0.5 * (0.1 * CloudCover)) * z * (Io - Idirect)) / (1.0 - 1.4 * z * log(Idirect / Io));
  
  float[] return_array = {0, x, y, z, Idirect, Idiffuse}; 
  return return_array; 
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


void add_Object2D (String t, int m, float x, float y, float z, float s) {

  int n = m;
  
  if (n == 0) {
    if (t.equals("PEOPLE")) n = int(random(1, 1 + Object2D_Filenames_PEOPLE.length));
    else if (t.equals("TREES")) n = int(random(1 + Object2D_Filenames_PEOPLE.length, 1 + Object2D_Filenames_PEOPLE.length + Object2D_Filenames_TREES.length));
  }

  //println(t, n);
  
  int d = 1; 
  int r = int(random(2));
  if (r == 0) d = -1; 

  int[] TempObject2D_MAP = {d * n}; 
  
  allObject2D_MAP = concat(allObject2D_MAP, TempObject2D_MAP);

  
  float[][] TempObject2D_XYZS = {{x, y, z, s}};
  
  allObject2D_XYZS = (float[][]) concat(allObject2D_XYZS, TempObject2D_XYZS);
  allObject2D_num += 1;
}



PImage[] Object2DImage;

void SOLARCHVISION_LoadObject2DImages () {

  Object2D_Filenames = new String[1];
  Object2D_Filenames[0] = "";
  
  Object2D_Filenames_PEOPLE = sort(getfiles(Object2DFolder_PEOPLE));
  Object2D_Filenames_TREES = sort(getfiles(Object2DFolder_TREES));
  
  Object2D_Filenames = concat(Object2D_Filenames, Object2D_Filenames_PEOPLE);
  Object2D_Filenames = concat(Object2D_Filenames, Object2D_Filenames_TREES);
  
  int n = Object2D_Filenames.length;
  
  Object2DImage = new PImage [n + 1];
 
  for (int i = 1; i < n; i += 1) {
    
    //println("i=",i);
    
    if (i <= Object2D_Filenames_PEOPLE.length) {
      Object2DImage[i] = loadImage(Object2DFolder_PEOPLE + "/" + Object2D_Filenames[i]);
    }
    else {
      Object2DImage[i] = loadImage(Object2DFolder_TREES + "/" + Object2D_Filenames[i]);      
    }
  }

}




void SOLARCHVISION_LoadWorldImages () {

  WORLD_VIEW_Filenames = sort(getfiles(WorldViewFolder));

  number_of_WORLD_viewports = WORLD_VIEW_Filenames.length;

  WORLD_VIEW_Name = new String[number_of_WORLD_viewports][2];
  
  WORLD_VIEW_BoundariesX = new float[number_of_WORLD_viewports][2];
  WORLD_VIEW_BoundariesY = new float[number_of_WORLD_viewports][2];
    
  WORLD_VIEW_GridDisplay = new int[number_of_WORLD_viewports];

  for (int i = 0; i < number_of_WORLD_viewports; i += 1) {
    String MapFilename = WorldViewFolder + "/" + WORLD_VIEW_Filenames[i];
    
    String[] Parts = split(WORLD_VIEW_Filenames[i], '_');
    
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
  
  return (return_VIEWPORT);
}


String StationICAO;
String StationType;

float StationLatitude;
float StationLongitude;
float StationElevation;

int STATION_SWOB_NUMBER = 0;
String[][] STATION_SWOB_INFO;

void SOLARCHVISION_getSWOB_Coordinates () {
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

void SOLARCHVISION_getNAEFS_Coordinates () {
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
        else {
          StationLatitude = float(parts[1]);
        }
  
        l = parts[2].length();
        if (((parts[2].substring(l - 1, l)).equals("E")) || ((parts[2].substring(l - 1, l)).equals("W"))) {
          String[] the_parts = split(parts[2], ':');
          StationLongitude = float(the_parts[0]) + (float(the_parts[1]) / 60.0) + (float(the_parts[2]) / 3600.0);
          if ((parts[2].substring(l - 1, l)).equals("W")) StationLongitude *= -1;
        }
        else {
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

void SOLARCHVISION_getCWEEDS_Coordinates () {
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


int defaultMaterial = 7;

float[][] allVertices = {{0,0,0}};
int[][] allFaces = {{0,0,0}};
int[] allFaces_MAT = {0};

float[][] allObject2D_XYZS = {{0,0,0}};
int[] allObject2D_MAP = {0};
int allObject2D_num = 0; 

int display_allyObject2D = 0;

int addToVertices (float x, float y, float z) {
  
  float[][] newVertice = {{x, y, z}}; 
  
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


void add_Box_Core (int m, float x, float y, float z, float dx, float dy, float dz, float rot) {
  
  float teta = rot * PI / 180.0;

  int t1 = addToVertices(x + (dx * cos(teta) - dy * sin(teta)), y + (dx * sin(teta) + dy * cos(teta)), z + dz);
  int t2 = addToVertices(x + (-dx * cos(teta) - dy * sin(teta)), y + (-dx * sin(teta) + dy * cos(teta)), z + dz);
  int t3 = addToVertices(x + (-dx * cos(teta) + dy * sin(teta)), y + (-dx * sin(teta) - dy * cos(teta)), z + dz);
  int t4 = addToVertices(x + (dx * cos(teta) + dy * sin(teta)), y + (dx * sin(teta) - dy * cos(teta)), z + dz);

  int b1 = addToVertices(x + (dx * cos(teta) - dy * sin(teta)), y + (dx * sin(teta) + dy * cos(teta)), z - dz);
  int b2 = addToVertices(x + (-dx * cos(teta) - dy * sin(teta)), y + (-dx * sin(teta) + dy * cos(teta)), z - dz);
  int b3 = addToVertices(x + (-dx * cos(teta) + dy * sin(teta)), y + (-dx * sin(teta) - dy * cos(teta)), z - dz);
  int b4 = addToVertices(x + (dx * cos(teta) + dy * sin(teta)), y + (dx * sin(teta) - dy * cos(teta)), z - dz);


  if (m == -1) defaultMaterial = 7;
  else defaultMaterial = m;

  {//Bottom
    int[] newFace = {b4, b3, b2, b1};
    if (m == -1) defaultMaterial -= 1;
    addToFaces(newFace);
  }    
  {//North
    int[] newFace = {t2, t1, b1, b2};
    if (m == -1) defaultMaterial -= 1;
    addToFaces(newFace);
  }
  {//East
    int[] newFace = {t1, t4, b4, b1};
    if (m == -1) defaultMaterial -= 1;
    addToFaces(newFace);
  }    
  {//South
    int[] newFace = {t4, t3, b3, b4};
    if (m == -1) defaultMaterial -= 1;
    addToFaces(newFace);
  }    
  {//West
    int[] newFace = {t3, t2, b2, b3};
    if (m == -1) defaultMaterial -= 1;
    addToFaces(newFace);
  }    
  {//Roof
    int[] newFace = {t1, t2, t3, t4};
    if (m == -1) defaultMaterial -= 1;
    addToFaces(newFace);
  }
}


void add_Box_Corners (int m, float x1, float y1, float z1, float x2, float y2, float z2) {

  int t1 = addToVertices(x2, y2, z2);
  int t2 = addToVertices(x1, y2, z2);
  int t3 = addToVertices(x1, y1, z2);
  int t4 = addToVertices(x2, y1, z2);

  int b1 = addToVertices(x2, y2, z1);
  int b2 = addToVertices(x1, y2, z1);
  int b3 = addToVertices(x1, y1, z1);
  int b4 = addToVertices(x2, y1, z1);

  if (m == -1) defaultMaterial = 7;
  else defaultMaterial = m;

  {//Bottom
    int[] newFace = {b4, b3, b2, b1};
    if (m == -1) defaultMaterial -= 1;
    addToFaces(newFace);
  }    
  {//North
    int[] newFace = {t2, t1, b1, b2};
    if (m == -1) defaultMaterial -= 1;
    addToFaces(newFace);
  }
  {//East
    int[] newFace = {t1, t4, b4, b1};
    if (m == -1) defaultMaterial -= 1;
    addToFaces(newFace);
  }    
  {//South
    int[] newFace = {t4, t3, b3, b4};
    if (m == -1) defaultMaterial -= 1;
    addToFaces(newFace);
  }    
  {//West
    int[] newFace = {t3, t2, b2, b3};
    if (m == -1) defaultMaterial -= 1;
    addToFaces(newFace);
  }    
  {//Roof
    int[] newFace = {t1, t2, t3, t4};
    if (m == -1) defaultMaterial -= 1;
    addToFaces(newFace);
  }
}


void add_Mesh2 (int m, float x1, float y1, float z1, float x3, float y3, float z3) {

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
  
  int v1 = addToVertices(x1, y1, z1);
  int v2 = addToVertices(x2, y2, z2);
  int v3 = addToVertices(x3, y3, z3);
  int v4 = addToVertices(x4, y4, z4);
  
  defaultMaterial = m;
  
  {
    int[] newFace = {v1, v2, v3, v4};
    addToFaces(newFace);
  }

}

void add_Mesh4 (int m, float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3, float x4, float y4, float z4) {

  int v1 = addToVertices(x1, y1, z1);
  int v2 = addToVertices(x2, y2, z2);
  int v3 = addToVertices(x3, y3, z3);
  int v4 = addToVertices(x4, y4, z4);

  defaultMaterial = m;
  
  {
    int[] newFace = {v1, v2, v3, v4};
    addToFaces(newFace);
  }

}

void add_Mesh3 (int m, float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3) {

  int v1 = addToVertices(x1, y1, z1);
  int v2 = addToVertices(x2, y2, z2);
  int v3 = addToVertices(x3, y3, z3);

  defaultMaterial = m;

  {
    int[] newFace = {v1, v2, v3};
    addToFaces(newFace);
  }

}

void add_Mesh5 (int m, float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3, float x4, float y4, float z4, float x5, float y5, float z5) {

  int v1 = addToVertices(x1, y1, z1);
  int v2 = addToVertices(x2, y2, z2);
  int v3 = addToVertices(x3, y3, z3);
  int v4 = addToVertices(x4, y4, z4);
  int v5 = addToVertices(x5, y5, z5);

  defaultMaterial = m;
  
  {
    int[] newFace = {v1, v2, v3, v4, v5};
    addToFaces(newFace);
  }

}

void add_Pentagon (int m, float cx, float cy, float cz, float r) {

  int v1 = addToVertices(cos_ang(1*72), sin_ang(1*72), 0);
  int v2 = addToVertices(cos_ang(2*72), sin_ang(2*72), 0);
  int v3 = addToVertices(cos_ang(3*72), sin_ang(3*72), 0);
  int v4 = addToVertices(cos_ang(4*72), sin_ang(4*72), 0);
  int v5 = addToVertices(cos_ang(5*72), sin_ang(5*72), 0);

  defaultMaterial = m;
    
  {
    int[] newFace = {v1, v2, v3, v4, v5};
    addToFaces(newFace);
  }

}

void add_Polygon (int m, float cx, float cy, float cz, float r, int n) {

  int[] newFace = {addToVertices(cx + r * cos_ang(0), cy + r * sin_ang(0), cz)};
  for (int i = 1; i < n; i++) {
    float t = i * 360.0 / float(n);
    int[] f = {addToVertices(cx + r * cos_ang(t), cy + r * sin_ang(t), cz)};
    newFace = concat(newFace, f);
  } 
 
  defaultMaterial = m;

  addToFaces(newFace);

}


void add_PolygonExtrude_CENTER (int m, float cx, float cy, float cz, float r, float h, int n) {
  add_PolygonExtrude(m, cx, cy, cz - h/2, r, h, n);
}


void add_PolygonExtrude (int m, float cx, float cy, float cz, float r, float h, int n) {

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


void add_PolygonHyper (int m, float cx, float cy, float cz, float r, float h, int n) {

  int[] newFace = {addToVertices(cx + r * cos_ang(0), cy + r * sin_ang(0), cz)};
  for (int i = 1; i < n; i++) {
    float t = i * 360.0 / float(n);
    int[] f = {addToVertices(cx + r * cos_ang(t), cy + r * sin_ang(t), cz + (i % 2) * h)};
    newFace = concat(newFace, f);
  } 
 
  defaultMaterial = m;

  addToFaces(newFace);

}



void add_Icosahedron (int m, float cx, float cy, float cz, float r) {

  int[] vT = new int[6];
  int[] vB = new int[6];
  
  vT[0] = addToVertices(cx, cy, cz + r);
  vB[0] = addToVertices(cx, cy, cz - r);
  
  for (int i = 1; i <= 5; i++) {
    float t = i * 72;
    
    float R_in = r * pow(5.0, 0.5) * 2.0 / 5.0;  
    float H_in = r * pow(5.0, 0.5) * 1.0 / 5.0;
    
    vT[i] = addToVertices(cx + R_in * cos_ang(t), cy + R_in * sin_ang(t), cz + H_in);
    vB[i] = addToVertices(cx + R_in * cos_ang(t + 36), cy + R_in * sin_ang(t + 36), cz - H_in);
  } 


  if (m == -1) defaultMaterial = 1;
  else defaultMaterial = m;

  for (int i = 1; i <= 5; i++) {
    
    int next_i = (i % 5) + 1;
    
    {
      int[] newFaceT = new int [3];
      int[] newFaceB = new int [3];
      
      newFaceT[0] = vT[i];
      newFaceT[1] = vT[next_i];
      newFaceT[2] = vT[0];
  
      newFaceB[0] = vB[i];
      newFaceB[1] = vB[next_i];
      newFaceB[2] = vT[next_i]; 
      
      addToFaces(newFaceT);
      addToFaces(newFaceB);
      if (m == -1) defaultMaterial += 1;
    }
    
    {
      int[] newFaceT = new int [3];
      int[] newFaceB = new int [3];
  
      newFaceT[0] = vT[next_i];
      newFaceT[1] = vT[i];
      newFaceT[2] = vB[i];

      newFaceB[0] = vB[next_i];
      newFaceB[1] = vB[i];
      newFaceB[2] = vB[0];    
      
      addToFaces(newFaceT);
      addToFaces(newFaceB);
      if (m == -1) defaultMaterial += 1; 
    }
  }   
  
}  
  

void add_QuadSphere (int m, float cx, float cy, float cz, float r, int Teselation) {

  // i.e. Rhombic Triacontahedron
  
  int[] vT = new int[6];
  int[] vB = new int[6];
  
  vT[0] = addToVertices(cx, cy, cz + r);
  vB[0] = addToVertices(cx, cy, cz - r);
  
  for (int i = 1; i <= 5; i++) {
    float t = i * 72;
    
    float R_in = r * pow(5.0, 0.5) * 2.0 / 5.0;  
    float H_in = r * pow(5.0, 0.5) * 1.0 / 5.0;
    
    vT[i] = addToVertices(cx + R_in * cos_ang(t), cy + R_in * sin_ang(t), cz + H_in);
    vB[i] = addToVertices(cx + R_in * cos_ang(t + 36), cy + R_in * sin_ang(t + 36), cz - H_in);
  } 

  int[] vM1 = new int[6]; // between T0 and Ti  
  int[] vM2 = new int[6]; // between Ti and Bi
  int[] vM3 = new int[6]; // between Ti and Bi
  int[] vM4 = new int[6]; // between Bi and B0
  //CAUTION: VMx[0] will remain undefined below to keep simillar i variables! 
  for (int i = 1; i <= 5; i++) {
    
    int next_i = (i % 5) + 1;
    
    float[] G;
    
    int A, B, C;
   
    { 
      A = i;
      B = next_i;
      C = 0;
      
      float[][] the_points = {{allVertices[vT[A]][0] - cx, allVertices[vT[A]][1] - cy, allVertices[vT[A]][2] - cz}
                            , {allVertices[vT[B]][0] - cx, allVertices[vT[B]][1] - cy, allVertices[vT[B]][2] - cz}
                            , {allVertices[vT[C]][0] - cx, allVertices[vT[C]][1] - cy, allVertices[vT[C]][2] - cz}};

      G = fn_normalize(fn_G(the_points));
      vM1[i] = addToVertices(cx + r * G[0], cy + r * G[1], cz + r * G[2]);
    }
    
    { 
      A = next_i;
      B = i;
      C = i;
      
      float[][] the_points = {{allVertices[vT[A]][0] - cx, allVertices[vT[A]][1] - cy, allVertices[vT[A]][2] - cz}
                            , {allVertices[vT[B]][0] - cx, allVertices[vT[B]][1] - cy, allVertices[vT[B]][2] - cz}
                            , {allVertices[vB[C]][0] - cx, allVertices[vB[C]][1] - cy, allVertices[vB[C]][2] - cz}};

      G = fn_normalize(fn_G(the_points));
      vM2[i] = addToVertices(cx + r * G[0], cy + r * G[1], cz + r * G[2]);
    } 
    
    { 
      A = i;
      B = next_i;
      C = next_i;
      
      float[][] the_points = {{allVertices[vB[A]][0] - cx, allVertices[vB[A]][1] - cy, allVertices[vB[A]][2] - cz}
                            , {allVertices[vB[B]][0] - cx, allVertices[vB[B]][1] - cy, allVertices[vB[B]][2] - cz}
                            , {allVertices[vT[C]][0] - cx, allVertices[vT[C]][1] - cy, allVertices[vT[C]][2] - cz}};
      
      G = fn_normalize(fn_G(the_points));
      vM3[i] = addToVertices(cx + r * G[0], cy + r * G[1], cz + r * G[2]);
    }    
    
    { 
      A = next_i;
      B = i;
      C = 0;
      
      float[][] the_points = {{allVertices[vB[A]][0] - cx, allVertices[vB[A]][1] - cy, allVertices[vB[A]][2] - cz}
                            , {allVertices[vB[B]][0] - cx, allVertices[vB[B]][1] - cy, allVertices[vB[B]][2] - cz}
                            , {allVertices[vB[C]][0] - cx, allVertices[vB[C]][1] - cy, allVertices[vB[C]][2] - cz}};
      
      G = fn_normalize(fn_G(the_points));
      vM4[i] = addToVertices(cx + r * G[0], cy + r * G[1], cz + r * G[2]);
    }      
    
  }    


  if (m == -1) defaultMaterial = 1;
  else defaultMaterial = m;

  for (int i = 1; i <= 5; i++) {
    
    int next_i = (i % 5) + 1;
    int prev_i = ((i + 5 - 2) % 5) + 1;

    {
      int[] newFace = new int [4];
      
      newFace[0] = vT[0];
      newFace[1] = vM1[prev_i];
      newFace[2] = vT[i];
      newFace[3] = vM1[i];
      
      if (Teselation == 0) {
        addToFaces(newFace);
      }
      else{
        addToFaces_afterSphericalTeselation(m, cx, cy, cz, r, newFace);
      }
    }

    {
      int[] newFace = new int [4];
      
      newFace[0] = vT[i];
      newFace[1] = vM2[i];
      newFace[2] = vT[next_i];
      newFace[3] = vM1[i];
      
      if (Teselation == 0) {
        addToFaces(newFace);
      }
      else{
        addToFaces_afterSphericalTeselation(m, cx, cy, cz, r, newFace);
      }
    }
    
    {
      int[] newFace = new int [4];
      
      newFace[0] = vT[i];
      newFace[1] = vM3[prev_i];
      newFace[2] = vB[i];
      newFace[3] = vM2[i];
      
      if (Teselation == 0) {
        addToFaces(newFace);
      }
      else{
        addToFaces_afterSphericalTeselation(m, cx, cy, cz, r, newFace);
      }
    }    
    
    {
      int[] newFace = new int [4];
      
      newFace[0] = vT[next_i];
      newFace[1] = vM2[i];
      newFace[2] = vB[i];
      newFace[3] = vM3[i];
      
      if (Teselation == 0) {
        addToFaces(newFace);
      }
      else{
        addToFaces_afterSphericalTeselation(m, cx, cy, cz, r, newFace);
      }
    }     

    {
      int[] newFace = new int [4];
      
      newFace[0] = vB[i];
      newFace[1] = vM4[i];
      newFace[2] = vB[next_i];
      newFace[3] = vM3[i];
      
      if (Teselation == 0) {
        addToFaces(newFace);
      }
      else{
        addToFaces_afterSphericalTeselation(m, cx, cy, cz, r, newFace);
      }
    }
    
    {
      int[] newFace = new int [4];
      
      newFace[0] = vB[i];
      newFace[1] = vM4[prev_i];
      newFace[2] = vB[0];
      newFace[3] = vM4[i];
      
      if (Teselation == 0) {
        addToFaces(newFace);
      }
      else{
        addToFaces_afterSphericalTeselation(m, cx, cy, cz, r, newFace);
      }
    }    
    
    if (m == -1) defaultMaterial += 1;
  }    

}


void addToFaces_afterSphericalTeselation (int m, float cx, float cy, float cz, float r, int[] f) {

  int A = f[0];
  int B = f[1];
  int C = f[2];
  int D = f[3];

  int M, N;  // 
  int MM, NN; // MM: mirror of M based on AB; NN: mirror of N baesd on CD

  float[] G;
  
  { 
    float[][] the_points = {{allVertices[D][0] - cx, allVertices[D][1] - cy, allVertices[D][2] - cz}
                          , {allVertices[A][0] - cx, allVertices[A][1] - cy, allVertices[A][2] - cz}
                          , {allVertices[B][0] - cx, allVertices[B][1] - cy, allVertices[B][2] - cz}};
    
    G = fn_normalize(fn_G(the_points));
    M = addToVertices(cx + r * G[0], cy + r * G[1], cz + r * G[2]);
    
    G[0] = (allVertices[C][0] - cx) + (allVertices[D][0] - cx) - (allVertices[M][0] - cx);
    G[1] = (allVertices[C][1] - cy) + (allVertices[D][1] - cy) - (allVertices[M][1] - cy);
    G[2] = (allVertices[C][2] - cz) + (allVertices[D][2] - cz) - (allVertices[M][2] - cz);
    G = fn_normalize(G);
    MM = addToVertices(cx + r * G[0], cy + r * G[1], cz + r * G[2]);    
  }   
 

  { 
    float[][] the_points = {{allVertices[B][0] - cx, allVertices[B][1] - cy, allVertices[B][2] - cz}
                          , {allVertices[C][0] - cx, allVertices[C][1] - cy, allVertices[C][2] - cz}
                          , {allVertices[D][0] - cx, allVertices[D][1] - cy, allVertices[D][2] - cz}};
    
    G = fn_normalize(fn_G(the_points));
    N = addToVertices(cx + r * G[0], cy + r * G[1], cz + r * G[2]);

    
    G[0] = (allVertices[A][0] - cx) + (allVertices[B][0] - cx) - (allVertices[N][0] - cx);
    G[1] = (allVertices[A][1] - cy) + (allVertices[B][1] - cy) - (allVertices[N][1] - cy);
    G[2] = (allVertices[A][2] - cz) + (allVertices[B][2] - cz) - (allVertices[N][2] - cz);
    G = fn_normalize(G);    
    NN = addToVertices(cx + r * G[0], cy + r * G[1], cz + r * G[2]);
    
  }




  
  {
    int[] newFace_MAT = {defaultMaterial}; 
    
    allFaces_MAT = concat(allFaces_MAT, newFace_MAT);
    
    
    int[][] newFace = {{M, B, N, D}}; 
    
    allFaces = (int[][]) concat(allFaces, newFace);
  }

  {
    int[] newFace_MAT = {defaultMaterial}; 
    
    allFaces_MAT = concat(allFaces_MAT, newFace_MAT);
    
    
    int[][] newFace = {{MM, B, M, A}}; 
    
    //allFaces = (int[][]) concat(allFaces, newFace);
  }

}




void SOLARCHVISION_export_objects () {
  
  PrintWriter File_output_mesh = createWriter("/MeshModel/Mesh.txt");

  File_output_mesh.println("Vertices:" + nf(allVertices.length - 1, 0));
  File_output_mesh.println("{");
  for (int i = 1; i < allVertices.length; i++) {
    for (int j = 0; j < 3; j++) {
      File_output_mesh.print(allVertices[i][j]);
      if (j + 1 < 3) {
        File_output_mesh.print("\t");
      }
      else {
        File_output_mesh.println();
      }          
    }    
  }
  File_output_mesh.println("}");

  File_output_mesh.println("Faces:" + nf(allFaces.length - 1, 0));
  File_output_mesh.println("{");
  for (int f = 1; f < allFaces.length; f++) {
    for (int j = 0; j < allFaces[f].length; j++) {
      File_output_mesh.print(allFaces[f][j]);
      if (j + 1 < allFaces[f].length) {
        File_output_mesh.print(",");
      }
      else {
        File_output_mesh.println();
      }          
    }    
  }
  File_output_mesh.println("}");
  
  File_output_mesh.flush(); 
  File_output_mesh.close();   
  
  println("End of exporting the mesh."); 
  
}
  
  
void SOLARCHVISION_import_objects (String FileName, int m, float cx, float cy, float cz, float sx, float sy, float sz) {
  
  if (m == -1) defaultMaterial = 0;
  else defaultMaterial = m;
  
  int[] importVerticeNumber = {0};
  
  String[] FileALL = loadStrings(FileName);

  String lineSTR;
  String[] input;
    
  //println("lines = ", FileALL.length);

  for (int f = 0; f < FileALL.length; f += 1) {
    
    lineSTR = FileALL[f];
    //println (lineSTR);
    
    lineSTR = lineSTR.replace("  ", " ");
    
    String[] parts = split(lineSTR, ' ');

    if (parts[0].toLowerCase().equals("g")) {
      if (m == -1) defaultMaterial = 1 + (defaultMaterial % 8);
    }
    
    if (parts[0].toLowerCase().equals("v")) {

      float x = cx + sx * float(parts[1]);
      float y = cy + sy * float(parts[2]);
      float z = cz + sz * float(parts[3]);
      
      int[] v = {addToVertices(x, y, z)};
      
      importVerticeNumber = concat(importVerticeNumber, v);
    }
    
    if (parts[0].toLowerCase().equals("f")) {
      //int[] newFace = new int[parts.length - 1]; // if we don't have space at the end of the line.
      int[] newFace = new int[parts.length - 2]; // if we have 1 space at the end of the line. 
    
      //println(parts);
    
      for (int n = 0; n < newFace.length; n += 1) {
        
        newFace[n] = importVerticeNumber[int(parts[n + 1])];
      }
      
      //println(newFace);
      
      addToFaces(newFace);
    }
    
  }
}  


float SOLARCHVISION_import_objects_asParametricBox (String FileName, int m, float cx, float cy, float cz, float sx, float sy, float sz) {

  float[][] importVertices = {{}};
  
  String[] FileALL = loadStrings(FileName);

  String lineSTR;
  String[] input;
    
  //println("lines = ", FileALL.length);

  for (int f = 0; f < FileALL.length; f += 1) {
    
    lineSTR = FileALL[f];
    //println (lineSTR);
    
    lineSTR = lineSTR.replace("  ", " ");
    
    String[] parts = split(lineSTR, ' ');
    
    if (parts[0].toLowerCase().equals("v")) {

      float x = cx + sx * float(parts[1]);
      float y = cy + sy * float(parts[2]);
      float z = cz + sz * float(parts[3]);
      
      float[][] v = {{x, y, z}};
      
      importVertices = (float[][]) concat(importVertices, v);
    }
  }
  
  float min_X = FLOAT_undefined;
  float max_X = -FLOAT_undefined;
  float min_Y = FLOAT_undefined;
  float max_Y = -FLOAT_undefined;
  float min_Z = FLOAT_undefined;
  float max_Z = -FLOAT_undefined;
  
  for (int vNo = 1; vNo < importVertices.length; vNo++) {
    float x = importVertices[vNo][0];
    float y = importVertices[vNo][1];
    float z = importVertices[vNo][2];
    
    if (min_X > x) min_X = x;
    if (max_X < x) max_X = x;
    if (min_Y > y) min_Y = y;
    if (max_Y < y) max_Y = y;
    if (min_Z > z) min_Z = z;
    if (max_Z < z) max_Z = z;
  }
  
  float cen_X = 0.5 * (min_X + max_X);
  float cen_Y = 0.5 * (min_Y + max_Y);
  float cen_Z = 0.5 * (min_Z + max_Z);

  float R_out = 0;
  float X_out = 0;
  float Y_out = 0;
  float Z_out = 0;
  
  for (int vNo = 1; vNo < importVertices.length; vNo++) {
    float x = importVertices[vNo][0];
    float y = importVertices[vNo][1];
    float z = importVertices[vNo][2];
    
    float r = dist(cen_X, cen_Y, cen_Z, x, y, z);
    
    if (R_out < r) {
      R_out = r;
      
      X_out = x;
      Y_out = y;
      Z_out = z;
    }
  }  

  float T_out = atan2_ang(Y_out, X_out);

  X_out = 0;
  Y_out = 0;
  Z_out = 0;
  
  for (int vNo = 1; vNo < importVertices.length; vNo++) {
    float x = (importVertices[vNo][0] - cen_X) * cos_ang(-T_out) - (importVertices[vNo][1] - cen_Y) * sin_ang(-T_out);
    float y = (importVertices[vNo][0] - cen_X) * sin_ang(-T_out) + (importVertices[vNo][1] - cen_Y) * cos_ang(-T_out);
    float z = importVertices[vNo][2];
    
    if (X_out < abs(x)) X_out = abs(x);
    if (Y_out < abs(y)) Y_out = abs(y);
    if (Z_out < abs(z)) Z_out = abs(z);
  }  
  
  //add_Box_Core(m, cen_X,cen_Y,cen_Z, X_out,Y_out,Z_out, T_out);
  ParametricGeometry[] newSolidBuilding = {new ParametricGeometry(1, cen_X,cen_Y,cen_Z, 8,8,8, X_out,Y_out,Z_out, T_out)}; 
  SolidBuildings = (ParametricGeometry[]) concat(SolidBuildings, newSolidBuilding);
  
  return min_Z;
}  




void SOLARCHVISION_add_2Dobjects_onLand () {

  for (int i = 0; i < LAND_n_I - 1; i += 1) {
  //for (int i = 1; i < LAND_n_I - 1; i += 1) { // to ignoring the center!
    for (int j = 0; j < LAND_n_J - 1; j += 1) {
      
      // Material -2 for colored elevations
      //add_Mesh4(-2, LAND_MESH[i][j][0], LAND_MESH[i][j][1], LAND_MESH[i][j][2] , LAND_MESH[i+1][j][0], LAND_MESH[i+1][j][1], LAND_MESH[i+1][j][2] , LAND_MESH[i+1][j+1][0], LAND_MESH[i+1][j+1][1], LAND_MESH[i+1][j+1][2] , LAND_MESH[i][j+1][0], LAND_MESH[i][j+1][1], LAND_MESH[i][j+1][2] );
      
      float pixel_area = dist(LAND_MESH[i][j][0], LAND_MESH[i][j][1], LAND_MESH[i+1][j+1][0], LAND_MESH[i+1][j+1][1]) * dist(LAND_MESH[i+1][j][0], LAND_MESH[i+1][j][1], LAND_MESH[i][j+1][0], LAND_MESH[i][j+1][1]);
      
      int max_n = int(pixel_area / 2500.0);
      if (max_n > 100) max_n = 100; 
      
      //for (int n = 0; n < 50; n += 1) {
      for (int n = 0; n < max_n; n += 1) {
        
        float di = random(1);
        float dj = random(1);

        float x = Bilinear(LAND_MESH[i][j][0], LAND_MESH[i][j+1][0], LAND_MESH[i+1][j+1][0], LAND_MESH[i+1][j][0], di, dj);
        float y = Bilinear(LAND_MESH[i][j][1], LAND_MESH[i][j+1][1], LAND_MESH[i+1][j+1][1], LAND_MESH[i+1][j][1], di, dj);
        float z = Bilinear(LAND_MESH[i][j][2], LAND_MESH[i][j+1][2], LAND_MESH[i+1][j+1][2], LAND_MESH[i+1][j][2], di, dj);
        
        if (i > 1) { 
          add_Object2D("TREES", 0, x, y, z, 5 + random(10));
        }
        else {
          add_Object2D("PEOPLE", 0, x, y, z, 2.5);
        }
      }  
    }
  }

}

void SOLARCHVISION_remove_2Dobjects () {
  allObject2D_XYZS = new float[1][3]; 
  allObject2D_XYZS[0][0] = 0;
  allObject2D_XYZS[0][1] = 0;
  allObject2D_XYZS[0][2] = 0;
  
  allObject2D_MAP = new int[1];
  allObject2D_MAP[0] = 0;
  
  allObject2D_num = 0;
}

void SOLARCHVISION_remove_3Dobjects () {

 allVertices = new float[1][3];
 allVertices[0][0] = 0;
 allVertices[0][1] = 0;
 allVertices[0][2] = 0;
 
 allFaces = new int[1][3];
 allFaces[0][0] = 0;
 allFaces[0][1] = 0;
 allFaces[0][2] = 0;
  
 allFaces_MAT = new int[1];
 allFaces_MAT[0] = 0;
 
}

int urbanVertices_start = 0;
int urbanVertices_end = 0;

int urbanFaces_start = 0;
int urbanFaces_end = 0;


void SOLARCHVISION_add_urban () {
  if (Load_URBAN == 1) {
    urbanVertices_start = allVertices.length;
    urbanFaces_start = allFaces.length;

    SOLARCHVISION_import_objects("C:/SOLARCHVISION_2015/Projects/Import/Stations/" + DEFINED_STATIONS[STATION_NUMBER][1] + ".obj", -1, 0,0,0, 1,1,1);
    
    urbanVertices_end = allVertices.length;
    urbanFaces_end = allFaces.length;
  }
}

void SOLARCHVISION_add_3Dobjects () {

  SOLARCHVISION_add_urban();
  
  //SOLARCHVISION_import_objects("C:/SOLARCHVISION_2015/Projects/Import/Teapot.obj", 0, 0,0,0, 1,1,1);
  //SOLARCHVISION_import_objects("C:/SOLARCHVISION_2015/Projects/Import/EV.obj", 0, 0,0,0, 1,1,1);
  //SOLARCHVISION_import_objects("C:/SOLARCHVISION_2015/Projects/Import/MontrealDowntown.obj", 7, -1135,-755,0, 1,1,1);

/* 
  //for (int i = 1; i <= 123; i += 1) {
  for (int i = 1; i <= 6; i += 1) {
  //for (int i = 20; i <= 30; i += 1) {
    
    int m = 1 + (i % 6); 
    
    if ((i != 15) && (i != 26) && (i != 52) && (i != 87)) {
      
      float x = -1135;
      float y = -755;
      float z = SOLARCHVISION_import_objects_asParametricBox("C:/SOLARCHVISION_2015/Projects/Import/MontrealDowntown/Group" + nf(i, 3) + ".obj", m, x,y,0, 1,1,1);
      SOLARCHVISION_import_objects("C:/SOLARCHVISION_2015/Projects/Import/MontrealDowntown/Group" + nf(i, 3) + ".obj", m, x,y,z, 1,1,1);
    }
  }
//  



  /*
  add_Mesh2(0, 0, 0, 0, 40, 40, 0);
  
  add_Mesh5(1, 10,10,0, 10,10,5, 10,15,10, 10,20,5, 10,20,0);
  add_Mesh5(2, 20,20,0, 20,20,5, 20,15,10, 20,10,5, 20,10,0);  
  add_Mesh4(3, 10,10,0, 20,10,0, 20,10,5, 10,10,5);
  add_Mesh4(4, 10,20,0, 10,20,5, 20,20,5, 20,20,0);
  add_Mesh4(5, 10,10,5, 20,10,5, 20,15,10, 10,15,10);
  add_Mesh4(6, 10,20,5, 10,15,10, 20,15,10, 20,20,5);    
  */
  
  //add_RecursiveSphere(0, 0,0,0, 50, 3, 0);
  

  
  /*
  add_RecursiveSphere(0, 0,0,0, 50, 5, 0);
  add_RecursiveSphere(0, 100,0,0, 40, 4, 0);
  add_RecursiveSphere(0, 180,0,0, 30, 3, 0);
  add_RecursiveSphere(0, 240,0,0, 20, 2, 0);
  add_RecursiveSphere(0, 280,0,0, 10, 1, 0);
  */




  
  //add_Mesh2(0, -20, -20, 0, 20, 20, 0);
  //add_PolygonHyper(0, 0, 0, 0,  10, 10, 4);
  //add_Polygon(3, 0, 0, 0, 50, 24);  
  
  //add_PolygonExtrude(-1, 0, 0, 0,  50, 20, 3);
  //add_PolygonExtrude(-1, 0, 0, 0,  50, 20, 5);

  //add_Polygon(1, 0, 0, -1, 2,  16);
  //add_Polygon(2, 0, 0, 0,  1.5, 5);
  //add_Polygon(5, 0, 0, 1,  50,   5);
  //add_Pentagon(1, 0, 0, 0, 1);
  
  //add_Polygon(2, 0, 0, 0,  50, 5);
  //add_PolygonHyper(2, 0, 0, 0,  50, 50, 6);
  //add_PolygonHyper(2, 0, 0, 0,  50, 50, 4);
  
  //add_Mesh4(2, -50, -50, 50, 50, -50, -50, 50, 50, 50, -50, 50, -50); // hyper
  //add_Mesh4(2, -50, -50, 150, 50, -50, -50, 50, 50, 50, -50, 50, -50); // hyper
 
  
  //add_Mesh4(7, -1, -1, 0, 1, -1, 0, 1, 1, 0, -1, 1, 0);
  



  //add_Mesh2(0, -20, -20, 0, 20, 20, 0);
  //add_PolygonHyper(0, 0, 0, 0,  15, 15, 4);


  
  //add_Mesh2(2, 60, 0, 0, 0, 0, 60);
  //add_Mesh2(3, 0, -60, 45, 60, 0, 45);
 
 /* 
  for (int i = 0; i < 60; i += 10) {
    add_Mesh2(2, 60, 0, i, 0, 0, i + 10);
  }
  add_Mesh2(3, 0, -60, 45, 60, 0, 45);
  */ 
  
  //add_Box_Corners(-1, 0, 0, 0, 30, 10, 10);
  //add_Box_Corners(-1, 0, 0, 10, 10, 10, 20);
  //add_Box_Corners(-1, 20, 0, 10, 30, 10, 20);
  //add_Box_Corners(-1, 0, 0, 20, 30, 10, 30);
  //add_Mesh2(3, -60, -60, 0, 60, 60, 0);
  
  //add_Polygon(3, 0, 0, 0, 50, 24);
  //add_Mesh2(0, -30, -30, 0, 30, 30, 0);
  //add_PolygonHyper(0, 0, 0, 0,  10, 10, 4);
/*  
  add_Mesh5(0, 10,10,0, 10,10,10, 10,15,15, 10,20,10, 10,20,0);
  add_Mesh5(0, 20,20,0, 20,20,10, 20,15,15, 20,10,10, 20,10,0);  
  add_Mesh4(0, 10,10,0, 20,10,0, 20,10,10, 10,10,10);
  add_Mesh4(0, 10,20,0, 10,20,10, 20,20,10, 20,20,0);
  add_Mesh4(0, 10,10,10, 20,10,10, 20,15,15, 10,15,15);
  add_Mesh4(0, 10,20,10, 10,15,15, 20,15,15, 20,20,10);
*/  
  
  
  //add_Box_Corners(-1, -40, -40, -40, 40, 40, 40);
  
  //add_Mesh2(6, -60, -60, 60, 60, 60, 60);
  //add_Mesh2(6, -60, -60, 60, 0, 60, 60);
  //add_Mesh2(6, -60, -60, 20, 0, 60, 20);
  

  //add_Box_Corners(-1, 0.5, 1.0, 0.0, 1.5, 3.0, 0.5);
  //add_Box_Corners(-1, 0.0, 0.0, 0.0, 0.5, 1.0, 2.0);
  
  //add_Mesh2(3, 0.5, 0.0, 0.75, 0.75, 1.0, 0.75);
  //add_Mesh2(3, 0.5, 0.0, 1.25, 0.75, 1.0, 1.25);
  //add_Mesh2(3, 0.5, 0.0, 1.75, 0.75, 1.0, 1.75);
  
  //add_Mesh2(7, -40, -40, 0, 40, 40, 0);
  
/*
  //SOLARCHVISION Complex:
  {
    //add_Box_Corners(-1, 0, 0, 0, 1, 3, 3);
    add_Box_Corners(-1, 0, 0, 0, 1, 3, 1);
    add_Box_Corners(-1, 0, 0, 1, 1, 1, 2);
    add_Box_Corners(-1, 0, 2, 1, 1, 3, 2);
    add_Box_Corners(-1, 0, 0, 2, 1, 3, 3);
    
    add_Box_Corners(-1, 2, 0, 0, 6, 4, 0.5);
    
    add_Box_Corners(-1, 7, 0, 0, 9, 2, 2);
    
    add_Box_Corners(-1, 7, 3, 0, 9, 4, 4);
    
    //add_Box_Corners(-1, 10, 0, 0, 13, 4, 1);
    add_Box_Corners(-1, 10, 0, 0, 13, 1, 1);
    add_Box_Corners(-1, 10, 1, 0, 10.5, 3, 1);
    add_Box_Corners(-1, 12.5, 1, 0, 13, 3, 1);
    add_Box_Corners(-1, 10, 3, 0, 13, 4, 1);
    
    add_Box_Corners(-1, 0, 4, 0, 1, 8, 2);
    
    //add_Box_Corners(-1, 2, 5, 0, 4, 8, 2);
    add_Box_Corners(-1, 2, 5, 0, 4, 5.5, 2);
    add_Box_Corners(-1, 2, 5.5, 0, 2.5, 7.5, 2);
    add_Box_Corners(-1, 3.5, 5.5, 0, 4, 7.5, 2);
    add_Box_Corners(-1, 2, 7.5, 0, 4, 8, 2);
    
    add_Box_Corners(-1, 5, 5, 0, 8, 8, 1);
    
    add_Box_Corners(-1, 9, 5, 0, 11, 9, 1);
    
    add_Box_Corners(-1, 12, 5, 0, 13, 7, 4);
    
    add_Box_Corners(-1, 12, 8, 0, 13, 9, 8);
    
    add_Box_Corners(-1, 0, 9, 0, 4, 11, 1);
    
    //add_Box_Corners(-1, 5, 9, 0, 8, 11, 2);
    add_Box_Corners(-1, 5, 9, 0, 5.5, 11, 2);
    add_Box_Corners(-1, 5.5, 9, 0, 7.5, 9.5, 2);
    add_Box_Corners(-1, 5.5, 10.5, 0, 7.5, 11, 2);
    add_Box_Corners(-1, 7.5, 9, 0, 8, 11, 2);
    
    //add_Box_Corners(-1, 0, 12, 0, 3, 13, 3);
    add_Box_Corners(-1, 0, 12, 0, 3, 13, 1);
    add_Box_Corners(-1, 0, 12, 1, 1, 13, 2);
    add_Box_Corners(-1, 2, 12, 1, 3, 13, 2);
    add_Box_Corners(-1, 0, 12, 2, 3, 13, 3);
    
    add_Box_Corners(-1, 4, 12, 0, 8, 13, 2);
    
    //add_Box_Corners(-1, 9, 10, 0, 13, 13, 1);
    add_Box_Corners(-1, 9, 10, 0, 10, 13, 1);
    add_Box_Corners(-1, 10, 10, 0, 12, 10.5, 1);
    add_Box_Corners(-1, 10, 12.5, 0, 12, 13, 1);
    add_Box_Corners(-1, 12, 10, 0, 13, 13, 1);
    
    float model_scale = 12; // to make grid scale equal to 12m. <<<<

    for (int i = 1; i < allVertices.length; i++) {
      allVertices[i][0] -= 6.5;
      allVertices[i][1] -= 6.5; 

      allVertices[i][0] *= model_scale;
      allVertices[i][1] *= model_scale; 
      allVertices[i][2] *= model_scale; 
      
    }

  }
*/





/*
  add_Mesh5(1, -10,-10,0, -10,-10,5, -10,0,10, -10,10,5, -10,10,0);
  add_Mesh5(2, 10,10,0, 10,10,5, 10,0,10, 10,-10,5, 10,-10,0);  
  add_Mesh4(3, -10,-10,0, 10,-10,0, 10,-10,5, -10,-10,5);
  add_Mesh4(4, -10,10,0, -10,10,5, 10,10,5, 10,10,0);
  add_Mesh4(5, -10,-10,5, 10,-10,5, 10,0,10, -10,0,10);
  add_Mesh4(6, -10,10,5, -10,0,10, 10,0,10, 10,10,5);
  
  //add_Mesh2(3, -10,-10.75,3.75, 10,-10,3.75);
  //add_Mesh2(3, -10,-10.75,2.5, 10,-10,2.5);
  //add_Mesh2(3, -10,-10.75,1.25, 10,-10,1.25);

  //add_Mesh2(0, -10,-30,0, 10,-10,0);
  add_PolygonHyper(0, 0, -20, 0,  5, 5, 4);
*/
  

  //add_Box_Corners(-1, -5, -5, 0, 5, 5, 10);

  
/*  
  //add_Box_Corners(0, -20, 0, 0, 20, 20, 30);
  {
    float x1 = -20;
    float y1 = 0;
    float z1 = 0;
    
    float x2 = 20;
    float y2 = 20;
    float z2 = 30;
    
    add_Mesh2(0, x2,y1,z1, x1,y1,z2); //south
    add_Mesh2(1, x2,y1,z1, x2,y2,z2); //east
    add_Mesh2(1, x1,y2,z1, x2,y2,z2); //north
    add_Mesh2(1, x1,y2,z1, x1,y1,z2); //west
    add_Mesh2(1, x1,y1,z2, x2,y2,z2); //top
  }
  
  add_Mesh2(0, -20, -40, 0, 20, 0, 0);
  add_Mesh2(1, -15, -10, 25, 15, 0, 25);
  add_PolygonHyper(0, 0, -20, 0,  15, 15, 4);
  
  //add_RecursiveSphere(0, 0,0,0, 92.5, 1, 0); 

*/  


}



void SOLARCHVISION_add_ParametricSurfaces (int m) {

  float stp_u = 0.05;
  float stp_v = 0.05;
  
  for (float a = -1; a < 1; a += stp_u) {
    for (float b = -1; b < 1; b += stp_v) {

      int[] newFace = {};
      
      for (int i = 0; i < 4; i++) {
        
        float u = a;
        float v = b;
        
        if ((i == 1) || (i == 2)) u += stp_u;
        if ((i == 2) || (i == 3)) v += stp_v;
        
        /*
        // LOGO:
        //--------------------------------------- 
        float x0 = cos(u * PI); 
        float y0 = sin(v * PI);
        float z0 = -sin(u * PI) * cos(v * PI);
        
        float d = pow(x0*x0 + y0*y0 + z0*z0, 0.5);
        float x = 0;
        float y = 0;
        float z = 0;
        if (d != 0) {
          x = 10 * x0 / d;  
          y = 10 * y0 / d;  
          z = 10 * z0 / d;  
        }        
        //---------------------------------------
        */
        
        //---------------------------------------
        float x = 20 * u; 
        float y = 20 * v; 
        float z = 10 * sin(u * PI) * cos(v * PI); 
        //---------------------------------------
        

        /*
        //---------------------------------------
        float x = 10 * sin(u * PI); 
        float y = 10 * sin(v * PI);
        float z = 10 * cos((u + v) * PI);
        //---------------------------------------
        */   

        
        /*
        //---------------------------------------
        float x0 = sin(u * PI); 
        float y0 = sin(v * PI);
        float z0 = cos((u + v) * PI);
        
        float d = pow(x0*x0 + y0*y0 + z0*z0, 0.5);
        float x = 0;
        float y = 0;
        float z = 0;
        if (d != 0) {
          x = 10 * x0 / d;  
          y = 10 * y0 / d;  
          z = 10 * z0 / d;  
        }
        //---------------------------------------   
        */     



        int[] f = {addToVertices(x,y,z)};
        newFace = concat(newFace, f);
      }
      defaultMaterial = m;
    
      addToFaces(newFace);      
    }
  }
}




void SOLARCHVISION_build_SkySphere (int Teselation) {
  
  add_RecursiveSphere(0, 0,0,0, 1, Teselation, 1); // SKY
  
}



float objects_scale = 1.0; 



PGraphics ViewFromTheSky (int SKY3D_X_View, int SKY3D_Y_View, float SKY3D_ZOOM_coordinate, float SKY3D_X_coordinate, float SKY3D_Y_coordinate, float SKY3D_Z_coordinate, float SKY3D_RX_coordinate, float SKY3D_RY_coordinate, float SKY3D_RZ_coordinate) {

  PGraphics SKY3D_Diagrams = createGraphics(SKY3D_X_View, SKY3D_Y_View, P3D);   
  
  SKY3D_Diagrams.beginDraw();
  
  SKY3D_Diagrams.background(233);
  
  //float ZOOM = 0.456 * SKY3D_ZOOM_coordinate * PI / 180;
  float ZOOM = 0.125 * SKY3D_ZOOM_coordinate * PI / 180;
  
  SKY3D_Diagrams.ortho(ZOOM * SKY3D_X_View * -1, ZOOM * SKY3D_X_View * 1, ZOOM  * SKY3D_Y_View * -1, ZOOM  * SKY3D_Y_View * 1, 0.00001, 100000);
  
  SKY3D_Diagrams.translate(0, 1.0 * SKY3D_Y_View, 0); // << IMPORTANT! 

  SKY3D_Diagrams.pushMatrix();
  
  SKY3D_Diagrams.translate(0, 0, 0);
  
  SKY3D_Diagrams.fill(0);
  SKY3D_Diagrams.textAlign(CENTER, CENTER); 
  SKY3D_Diagrams.textSize(5 * (SKY3D_ZOOM_coordinate / 30.0));
  SKY3D_Diagrams.text(LocationName + " [" + nfp(LocationLatitude, 0, 1) + ", " + nfp(LocationLongitude, 0, 1) + "]", 0, 60 * (SKY3D_ZOOM_coordinate / 30.0), 0);
 
  SKY3D_Diagrams.popMatrix();

  SKY3D_Diagrams.translate(SKY3D_X_coordinate, SKY3D_Y_coordinate, SKY3D_Z_coordinate);
  SKY3D_Diagrams.rotateX(SKY3D_RX_coordinate * PI / 180); 
  SKY3D_Diagrams.rotateY(SKY3D_RY_coordinate * PI / 180);
  SKY3D_Diagrams.rotateZ(SKY3D_RZ_coordinate * PI / 180); 

  SKY3D_Diagrams.hint(ENABLE_DEPTH_TEST);

  for (int f = 1; f < allFaces.length; f++) {
    
    color c = color(0, 0, 0);

    if (allFaces_MAT[f] == -2) {
      c = color(127, 255, 127);
    }
    else{
      int mt = allFaces_MAT[f];
      c = color(Materials_Color[mt][1], Materials_Color[mt][2], Materials_Color[mt][3], Materials_Color[mt][0]);
    }
    
    SKY3D_Diagrams.stroke(c);
    SKY3D_Diagrams.fill(c);

    int Teselation = 0;
    
    int TotalSubNo = 1;  
    if (allFaces_MAT[f] == 0) {
      Teselation = MODEL3D_TESELATION;
      if (Teselation > 0) TotalSubNo = allFaces[f].length * int(roundTo(pow(4, Teselation - 1), 1));
    }

    for (int n = 0; n < TotalSubNo; n++) {
      float[][] subFace = getSubFace(allFaces[f], Teselation, n);
   
      SKY3D_Diagrams.beginShape();
      
      for (int s = 0; s < subFace.length; s++) {
  
        if (allFaces_MAT[f] == -2) {
          
          int PAL_TYPE = 1; 
         
          float[] _COL = GET_COLOR_STYLE(PAL_TYPE, 0.5 - 0.0025 * subFace[s][2]);
          
          SKY3D_Diagrams.fill(_COL[1], _COL[2], _COL[3]);
        }
        //else SKY3D_Diagrams.fill(255, 127, 0);

        SKY3D_Diagrams.vertex(subFace[s][0], -subFace[s][1], subFace[s][2]);
      }
      
      SKY3D_Diagrams.endShape(CLOSE);
    }
    
  }

  SKY3D_Diagrams.endDraw();

  return SKY3D_Diagrams;
}


void SOLARCHVISION_draw_sky () {
  
  for (int f = 1; f < skyFaces.length; f++) {
    
    color c = color(191, 191, 255);

    if (WIN3D_EDGES_SHOW == 1) {
      //WIN3D_Diagrams.stroke(0, 0, 0);
      WIN3D_Diagrams.stroke(255, 255, 255);
    }
    else {
      WIN3D_Diagrams.stroke(c);
    }

    if (WIN3D_FACES_SHADE == 1) {
      //WIN3D_Diagrams.fill(255, 255, 255);
      WIN3D_Diagrams.noFill();
    }
    else {
      WIN3D_Diagrams.fill(c);
    }    

      
    WIN3D_Diagrams.beginShape();
    
    for (int j = 0; j < skyFaces[f].length; j++) {
      int vNo = skyFaces[f][j];
      WIN3D_Diagrams.vertex(skyVertices[vNo][0] * sky_scale, -(skyVertices[vNo][1] * sky_scale), skyVertices[vNo][2] * sky_scale);
    }    
    
    WIN3D_Diagrams.endShape(CLOSE);

  }

}


void SOLARCHVISION_draw_land () {

  if ((Display_LAND == 1) && (Load_LAND == 1)) {

    for (int i = Skip_LAND_Center; i < LAND_n_I - 1; i += 1) {
      for (int j = 0; j < LAND_n_J - 1; j += 1) {
        
        WIN3D_Diagrams.beginShape();
        
        for (int vNo = 0; vNo < 4; vNo += 1) {
          int plus_i = 0; 
          int plus_j = 0;
          if ((vNo == 1) || (vNo == 2)) {
            plus_i = 1;
          }
          if ((vNo == 2) || (vNo == 3)) {
            plus_j = 1;
          }
          
          float x = LAND_MESH[i + plus_i][j + plus_j][0];
          float y = LAND_MESH[i + plus_i][j + plus_j][1];
          float z = LAND_MESH[i + plus_i][j + plus_j][2];
          
  
          int PAL_TYPE = 1; 
          //float[] _COL = GET_COLOR_STYLE(PAL_TYPE, 0.5 - 0.0025 * z);
          float[] _COL = GET_COLOR_STYLE(PAL_TYPE, 0.5 - 0.01 * z);
          WIN3D_Diagrams.fill(_COL[1], _COL[2], _COL[3]);
          WIN3D_Diagrams.stroke(0);
        
          WIN3D_Diagrams.vertex(x * objects_scale, -y * objects_scale, z * objects_scale);
        }
        
        WIN3D_Diagrams.endShape(CLOSE);
      }
    }
    
  }

}


void SOLARCHVISION_draw_field_image () {

  if (display_Field_Image == 1) {
    WIN3D_Diagrams.beginShape();
    WIN3D_Diagrams.texture(Field_Image);    
    
    //WIN3D_Diagrams.stroke(255, 255, 255, 0);
    WIN3D_Diagrams.stroke(0);
    
    WIN3D_Diagrams.fill(255, 255, 255, 0);  
    
    float c = Field_Elevation[display_Field_Image] * objects_scale;
    
    {
      float a = -0.5 * Field_scale_U * objects_scale;
      float b = -0.5 * Field_scale_V * objects_scale;    
      float x = a * cos_ang(Field_Image_rotation[display_Field_Image]) - b * sin_ang(Field_Image_rotation[display_Field_Image]);
      float y = a * sin_ang(Field_Image_rotation[display_Field_Image]) + b * cos_ang(Field_Image_rotation[display_Field_Image]);
      float z = c; 
      WIN3D_Diagrams.vertex(x, y, z, 0, Field_RES2);
    }
    {
      float a = 0.5 * Field_scale_U * objects_scale;
      float b = -0.5 * Field_scale_V * objects_scale;    
      float x = a * cos_ang(Field_Image_rotation[display_Field_Image]) - b * sin_ang(Field_Image_rotation[display_Field_Image]);
      float y = a * sin_ang(Field_Image_rotation[display_Field_Image]) + b * cos_ang(Field_Image_rotation[display_Field_Image]);
      float z = c;  
      WIN3D_Diagrams.vertex(x, y, z, Field_RES1, Field_RES2);
    }  
    {
      float a = 0.5 * Field_scale_U * objects_scale;
      float b = 0.5 * Field_scale_V * objects_scale;    
      float x = a * cos_ang(Field_Image_rotation[display_Field_Image]) - b * sin_ang(Field_Image_rotation[display_Field_Image]);
      float y = a * sin_ang(Field_Image_rotation[display_Field_Image]) + b * cos_ang(Field_Image_rotation[display_Field_Image]);
      float z = c;  
      WIN3D_Diagrams.vertex(x, y, z, Field_RES1, 0);
    }  
    {
      float a = -0.5 * Field_scale_U * objects_scale;
      float b = 0.5 * Field_scale_V * objects_scale;    
      float x = a * cos_ang(Field_Image_rotation[display_Field_Image]) - b * sin_ang(Field_Image_rotation[display_Field_Image]);
      float y = a * sin_ang(Field_Image_rotation[display_Field_Image]) + b * cos_ang(Field_Image_rotation[display_Field_Image]);
      float z = c;  
      WIN3D_Diagrams.vertex(x, y, z, 0, 0);
    }  
    
    WIN3D_Diagrams.endShape(CLOSE);
  }
 
  else if (display_Field_Image == 2) {
    WIN3D_Diagrams.beginShape();
    WIN3D_Diagrams.texture(Field_Image);    
    
    //WIN3D_Diagrams.stroke(255, 255, 255, 0);
    WIN3D_Diagrams.stroke(0);
    
    WIN3D_Diagrams.fill(255, 255, 255, 0);  
    
    float c = Field_Elevation[display_Field_Image] * objects_scale;
    
    {
      float a = -0.5 * Field_scale_U * objects_scale;
      float b = -0.5 * Field_scale_V * objects_scale;    
      float x = a * cos_ang(Field_Image_rotation[display_Field_Image]) - c * sin_ang(Field_Image_rotation[display_Field_Image]);
      float y = a * sin_ang(Field_Image_rotation[display_Field_Image]) + c * cos_ang(Field_Image_rotation[display_Field_Image]);
      float z = b; 
      WIN3D_Diagrams.vertex(x, y, z, 0, Field_RES2);
    }
    {
      float a = 0.5 * Field_scale_U * objects_scale;
      float b = -0.5 * Field_scale_V * objects_scale;    
      float x = a * cos_ang(Field_Image_rotation[display_Field_Image]) - c * sin_ang(Field_Image_rotation[display_Field_Image]);
      float y = a * sin_ang(Field_Image_rotation[display_Field_Image]) + c * cos_ang(Field_Image_rotation[display_Field_Image]);
      float z = b; 
      WIN3D_Diagrams.vertex(x, y, z, Field_RES1, Field_RES2);
    }  
    {
      float a = 0.5 * Field_scale_U * objects_scale;
      float b = 0.5 * Field_scale_V * objects_scale;    
      float x = a * cos_ang(Field_Image_rotation[display_Field_Image]) - c * sin_ang(Field_Image_rotation[display_Field_Image]);
      float y = a * sin_ang(Field_Image_rotation[display_Field_Image]) + c * cos_ang(Field_Image_rotation[display_Field_Image]);
      float z = b; 
      WIN3D_Diagrams.vertex(x, y, z, Field_RES1, 0);
    }  
    {
      float a = -0.5 * Field_scale_U * objects_scale;
      float b = 0.5 * Field_scale_V * objects_scale;    
      float x = a * cos_ang(Field_Image_rotation[display_Field_Image]) - c * sin_ang(Field_Image_rotation[display_Field_Image]);
      float y = a * sin_ang(Field_Image_rotation[display_Field_Image]) + c * cos_ang(Field_Image_rotation[display_Field_Image]);
      float z = b; 
      WIN3D_Diagrams.vertex(x, y, z, 0, 0);
    }  
    
    WIN3D_Diagrams.endShape(CLOSE);
  }

  else if (display_Field_Image == 3) {
    WIN3D_Diagrams.beginShape();
    WIN3D_Diagrams.texture(Field_Image);    
    
    //WIN3D_Diagrams.stroke(255, 255, 255, 0);
    WIN3D_Diagrams.stroke(0);
    
    WIN3D_Diagrams.fill(255, 255, 255, 0);  
    
    float c = Field_Elevation[display_Field_Image] * objects_scale;
    
    {
      float a = -0.5 * Field_scale_U * objects_scale;
      float b = -0.5 * Field_scale_V * objects_scale;    
      float x = c * cos_ang(Field_Image_rotation[display_Field_Image]) - b * sin_ang(Field_Image_rotation[display_Field_Image]);
      float y = c * sin_ang(Field_Image_rotation[display_Field_Image]) + b * cos_ang(Field_Image_rotation[display_Field_Image]);
      float z = a; 
      WIN3D_Diagrams.vertex(x, y, z, 0, Field_RES2);
    }
    {
      float a = 0.5 * Field_scale_U * objects_scale;
      float b = -0.5 * Field_scale_V * objects_scale;    
      float x = c * cos_ang(Field_Image_rotation[display_Field_Image]) - b * sin_ang(Field_Image_rotation[display_Field_Image]);
      float y = c * sin_ang(Field_Image_rotation[display_Field_Image]) + b * cos_ang(Field_Image_rotation[display_Field_Image]);
      float z = a; 
      WIN3D_Diagrams.vertex(x, y, z, Field_RES1, Field_RES2);
    }  
    {
      float a = 0.5 * Field_scale_U * objects_scale;
      float b = 0.5 * Field_scale_V * objects_scale;    
      float x = c * cos_ang(Field_Image_rotation[display_Field_Image]) - b * sin_ang(Field_Image_rotation[display_Field_Image]);
      float y = c * sin_ang(Field_Image_rotation[display_Field_Image]) + b * cos_ang(Field_Image_rotation[display_Field_Image]);
      float z = a; 
      WIN3D_Diagrams.vertex(x, y, z, Field_RES1, 0);
    }  
    {
      float a = -0.5 * Field_scale_U * objects_scale;
      float b = 0.5 * Field_scale_V * objects_scale;    
      float x = c * cos_ang(Field_Image_rotation[display_Field_Image]) - b * sin_ang(Field_Image_rotation[display_Field_Image]);
      float y = c * sin_ang(Field_Image_rotation[display_Field_Image]) + b * cos_ang(Field_Image_rotation[display_Field_Image]);
      float z = a; 
      WIN3D_Diagrams.vertex(x, y, z, 0, 0);
    }  
    
    WIN3D_Diagrams.endShape(CLOSE);
  }

}

void SOLARCHVISION_draw_objects () {

  for (int f = 1; f < allFaces.length; f++) {
    
    color c = color(0, 0, 0);

    if (allFaces_MAT[f] == -2) {
      c = color(127, 255, 127);
    }
    else{
      int mt = allFaces_MAT[f];
      c = color(Materials_Color[mt][1], Materials_Color[mt][2], Materials_Color[mt][3], Materials_Color[mt][0]);
    }
    
    if (WIN3D_EDGES_SHOW == 1) {
      WIN3D_Diagrams.stroke(0, 0, 0);
    }
    else {
      WIN3D_Diagrams.stroke(c);
    }

    if (WIN3D_FACES_SHADE == 1) {
      WIN3D_Diagrams.fill(255, 255, 255);
      //WIN3D_Diagrams.noFill();
    }
    else {
      WIN3D_Diagrams.fill(c);
    }    
    
    

    if (WIN3D_FACES_SHADE < 2) {
      
      WIN3D_Diagrams.beginShape();
      
      for (int j = 0; j < allFaces[f].length; j++) {
        int vNo = allFaces[f][j];
        WIN3D_Diagrams.vertex(allVertices[vNo][0] * objects_scale, -(allVertices[vNo][1] * objects_scale), allVertices[vNo][2] * objects_scale);
      }    
      
      WIN3D_Diagrams.endShape(CLOSE);
    }
    else if (WIN3D_FACES_SHADE == 2) {
      int Teselation = 0;
      
      int TotalSubNo = 1;  
      if (allFaces_MAT[f] == 0) {
        Teselation = MODEL3D_TESELATION;
        if (Teselation > 0) TotalSubNo = allFaces[f].length * int(roundTo(pow(4, Teselation - 1), 1));
      }

      for (int n = 0; n < TotalSubNo; n++) {
        float[][] subFace = getSubFace(allFaces[f], Teselation, n);
     
        WIN3D_Diagrams.beginShape();
        
        for (int s = 0; s < subFace.length; s++) {
    
          if (allFaces_MAT[f] == -2) {
            
            int PAL_TYPE = 1; 
           
            float[] _COL = GET_COLOR_STYLE(PAL_TYPE, 0.5 - 0.0025 * subFace[s][2]);
            
            WIN3D_Diagrams.fill(_COL[1], _COL[2], _COL[3]);
          }
          //else WIN3D_Diagrams.fill(255, 127, 0);
  
          WIN3D_Diagrams.vertex(subFace[s][0] * objects_scale, -(subFace[s][1] * objects_scale), subFace[s][2] * objects_scale);
        }
        
        WIN3D_Diagrams.endShape(CLOSE);
      }
    }
    else if (WIN3D_FACES_SHADE == 3) {
      
      int PAL_TYPE = 0; 
      int PAL_DIR = 1;
      
      if (Impact_TYPE == Impact_ACTIVE) {  
        PAL_TYPE = 15; PAL_DIR = 1;
        
      }
      if (Impact_TYPE == Impact_PASSIVE) {  
        PAL_TYPE = Pallet_PASSIVE; PAL_DIR = Pallet_PASSIVE_DIR;
      }             
      
      float _Multiplier = 1; 
      if (Impact_TYPE == Impact_ACTIVE) _Multiplier = 0.1; 
      if (Impact_TYPE == Impact_PASSIVE) _Multiplier = 0.02;            

      int Teselation = 0;
      
      int TotalSubNo = 1;  
      if (allFaces_MAT[f] == 0) {
        Teselation = MODEL3D_TESELATION;
        if (Teselation > 0) TotalSubNo = allFaces[f].length * int(roundTo(pow(4, Teselation - 1), 1));
      }
  
      for (int n = 0; n < TotalSubNo; n++) {
        float[][] subFace = getSubFace(allFaces[f], Teselation, n);
     
        WIN3D_Diagrams.beginShape();
        
        for (int s = 0; s < subFace.length; s++) {
  
          int s_next = (s + 1) % subFace.length;
          int s_prev = (s + subFace.length - 1) % subFace.length;
          
          PVector U = new PVector(subFace[s_next][0] - subFace[s][0], subFace[s_next][1] - subFace[s][1], subFace[s_next][2] - subFace[s][2]);
          PVector V = new PVector(subFace[s_prev][0] - subFace[s][0], subFace[s_prev][1] - subFace[s][1], subFace[s_prev][2] - subFace[s][2]);
          PVector UV = U.cross(V);
          float[] W = {UV.x, UV.y, UV.z};
          W = fn_normalize(W);
          
          float Alpha = asin_ang(W[2]);
          float Beta = atan2_ang(W[1], W[0]) + 90;       
          
          int a = int((Alpha + 90) / stp_slp);
          int b = int(Beta / stp_dir);
          
          if (a < 0) a += int(180 / stp_slp);
          if (b < 0) b += int(360 / stp_dir);
          if (a > int(180 / stp_slp)) a -= int(180 / stp_slp);
          if (b > int(360 / stp_dir)) b -= int(360 / stp_dir);
          
          float _valuesSUM = LocationExposure[a][b];
          
          if (_valuesSUM < 0.9 * FLOAT_undefined) {
          
            float _u = 0;
            
            if (Impact_TYPE == Impact_ACTIVE) _u = (_Multiplier * _valuesSUM);
            if (Impact_TYPE == Impact_PASSIVE) _u = 0.5 + 0.5 * 0.75 * (_Multiplier * _valuesSUM);
            
            if (PAL_DIR == -1) _u = 1 - _u;
            if (PAL_DIR == -2) _u = 0.5 - 0.5 * _u;
            if (PAL_DIR == 2) _u =  0.5 * _u;
  
            float[] _COL = GET_COLOR_STYLE(PAL_TYPE, _u);
  
            WIN3D_Diagrams.noStroke(); // <<<<<<<<<<<<
  
            WIN3D_Diagrams.fill(_COL[1], _COL[2], _COL[3], _COL[0]);
          }
          else {
            WIN3D_Diagrams.fill(223); 
          }
          
          WIN3D_Diagrams.vertex(subFace[s][0] * objects_scale, -(subFace[s][1] * objects_scale), subFace[s][2] * objects_scale);
  
        }
        
        WIN3D_Diagrams.endShape(CLOSE);
      }
    }
  }
  
  if (WIN3D_FACES_SHADE == 4) {
    if (WIN3D_update_VerticesSolarValue == 0) {
      
      int PAL_TYPE = 0; 
      int PAL_DIR = 1;
      
      if (Impact_TYPE == Impact_ACTIVE) {  
        PAL_TYPE = 15; PAL_DIR = 1;
        
      }
      if (Impact_TYPE == Impact_PASSIVE) {  
        PAL_TYPE = Pallet_PASSIVE; PAL_DIR = Pallet_PASSIVE_DIR;
      }             
      
      float _Multiplier = 1; 
      if (Impact_TYPE == Impact_ACTIVE) _Multiplier = 0.1; 
      if (Impact_TYPE == Impact_PASSIVE) _Multiplier = 0.02;       

      int N_baked = 0;
      
      for (int f = 1; f < allFaces.length; f++) {

        int Teselation = 0;
        
        int TotalSubNo = 1;  
        if (allFaces_MAT[f] == 0) {
          Teselation = MODEL3D_TESELATION;
          if (Teselation > 0) TotalSubNo = allFaces[f].length * int(roundTo(pow(4, Teselation - 1), 1));
        }
        
        for (int n = 0; n < TotalSubNo; n++) {
          float[][] subFace = getSubFace(allFaces[f], Teselation, n);
       
          WIN3D_Diagrams.beginShape();
          
          for (int s = 0; s < subFace.length; s++) {

            N_baked += 1;
            
            float _valuesSUM = 0;
            if (Impact_TYPE == Impact_ACTIVE) _valuesSUM = WIN3D_VerticesSolarEnergy[N_baked];
            if (Impact_TYPE == Impact_PASSIVE) _valuesSUM = WIN3D_VerticesSolarEffect[N_baked];
            
            if (_valuesSUM < 0.9 * FLOAT_undefined) {
              
              float _u = 0;
            
              if (Impact_TYPE == Impact_ACTIVE) _u = (_Multiplier * _valuesSUM);
              if (Impact_TYPE == Impact_PASSIVE) _u = 0.5 + 0.5 * 0.75 * (_Multiplier * _valuesSUM);
              
              if (PAL_DIR == -1) _u = 1 - _u;
              if (PAL_DIR == -2) _u = 0.5 - 0.5 * _u;
              if (PAL_DIR == 2) _u =  0.5 * _u;
    
              float[] _COL = GET_COLOR_STYLE(PAL_TYPE, _u);
              
              WIN3D_Diagrams.fill(_COL[1], _COL[2], _COL[3], _COL[0]);          
      
              WIN3D_Diagrams.vertex(subFace[s][0] * objects_scale, -(subFace[s][1] * objects_scale), subFace[s][2] * objects_scale);
            }
          }
          
          WIN3D_Diagrams.endShape(CLOSE);
        }
      }
    }
    else {
      WIN3D_VerticesSolarEnergy = new float [1];
      WIN3D_VerticesSolarEffect = new float [1];
      WIN3D_VerticesSolarEnergy[0] = FLOAT_undefined; 
      WIN3D_VerticesSolarEffect[0] = FLOAT_undefined; 
      
      float pre_per_day = per_day;
      int pre_num_add_days = num_add_days;
      if ((impacts_source == databaseNumber_ENSEMBLE) || (impacts_source == databaseNumber_OBSERVED)) {
        per_day = 1;
        num_add_days = 1;
      }
      
      int start_z = get_startZ_endZ(impacts_source)[0];
      int end_z = get_startZ_endZ(impacts_source)[1]; 
      int layers_count = get_startZ_endZ(impacts_source)[2]; 
        
      Impact_TYPE = Impact_ACTIVE; 
      if (plot_impacts % 2 == 1) Impact_TYPE = Impact_PASSIVE;
  
      float Pa = FLOAT_undefined;
      float Pb = FLOAT_undefined;
      float Pc = FLOAT_undefined;
      float Pd = FLOAT_undefined;
      
      float _values_R_dir;
      float _values_R_dif;
      float _values_E_dir;
      float _values_E_dif;
      
      int now_k = 0;
      int now_i = 0;
      int now_j = 0;
      
      int PAL_TYPE = 0; 
      int PAL_DIR = 1;
      
      if (Impact_TYPE == Impact_ACTIVE) {  
        PAL_TYPE = 15; PAL_DIR = 1;
        
      }
      if (Impact_TYPE == Impact_PASSIVE) {  
        PAL_TYPE = Pallet_PASSIVE; PAL_DIR = Pallet_PASSIVE_DIR;
      }             
      
      float _Multiplier = 1; 
      if (Impact_TYPE == Impact_ACTIVE) _Multiplier = 0.1; 
      if (Impact_TYPE == Impact_PASSIVE) _Multiplier = 0.02; 

      int[][] PROCESSED_DAILY_SCENARIOS = {{}};  
  
      for (int f = 1; f < allFaces.length; f++) {
    
        int Teselation = 0;
        
        int TotalSubNo = 1;  
        if (allFaces_MAT[f] == 0) {
          Teselation = MODEL3D_TESELATION;
          if (Teselation > 0) TotalSubNo = allFaces[f].length * int(roundTo(pow(4, Teselation - 1), 1));
        }
                
        for (int n = 0; n < TotalSubNo; n++) {
          float[][] subFace = getSubFace(allFaces[f], Teselation, n);
          
          WIN3D_Diagrams.beginShape();
          
          for (int s = 0; s < subFace.length; s++) {
            
            int s_next = (s + 1) % subFace.length;
            int s_prev = (s + subFace.length - 1) % subFace.length;
            
            PVector U = new PVector(subFace[s_next][0] - subFace[s][0], subFace[s_next][1] - subFace[s][1], subFace[s_next][2] - subFace[s][2]);
            PVector V = new PVector(subFace[s_prev][0] - subFace[s][0], subFace[s_prev][1] - subFace[s][1], subFace[s_prev][2] - subFace[s][2]);
            PVector UV = U.cross(V);
            float[] W = {UV.x, UV.y, UV.z};
            W = fn_normalize(W);
            
            float Alpha = asin_ang(W[2]);
            float Beta = atan2_ang(W[1], W[0]) + 90; 
            
            float _valuesSUM_RAD = 0;
            float _valuesSUM_EFF_P = 0;
            float _valuesSUM_EFF_N = 0;
            int _valuesNUM = 0; 
            
            
            int l = impact_layer;
            
            for (int j = j_start; j < j_end; j += 1) {
            
              now_j = (j * int(per_day) + BEGIN_DAY + 365) % 365;
            
              if (now_j >= 365) {
               now_j = now_j % 365; 
              }
              if (now_j < 0) {
               now_j = (now_j + 365) % 365; 
              }
             
              float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0); 
            
              float _sunrise = SOLARCHVISION_Sunrise(LocationLatitude, DATE_ANGLE); 
              float _sunset = SOLARCHVISION_Sunset(LocationLatitude, DATE_ANGLE);

              int[] Normals_COL_N;
              
            
              if (PROCESSED_DAILY_SCENARIOS.length > j_end - j_start) {
                Normals_COL_N = PROCESSED_DAILY_SCENARIOS[j_end - j_start];
              }
              else{
                Normals_COL_N = new int[9];
                Normals_COL_N = SOLARCHVISION_PROCESS_DAILY_SCENARIOS(layers_count, start_z, end_z, j, DATE_ANGLE);
                
                int[][] newNormals = {Normals_COL_N};
                PROCESSED_DAILY_SCENARIOS = (int[][]) concat(PROCESSED_DAILY_SCENARIOS, newNormals);
                println("length of PROCESSED_DAILY_SCENARIOS =", PROCESSED_DAILY_SCENARIOS.length);
              }
            
              int nk = Normals_COL_N[l];
              
              if (nk != -1) {
                int k = int(nk / num_add_days);
                int j_ADD = nk % num_add_days; 
            
      
                for (int i = 0; i < 24; i += 1) {
                //for (int i = 6; i <= 18; i += 3) { // for a quick result! 
                
                  float HOUR_ANGLE = i; 
                  float[] SunR = SOLARCHVISION_SunPosition(LocationLatitude, DATE_ANGLE, HOUR_ANGLE);
  
                  if (SunR[3] > 0) {
          
                    now_k = k;
                    now_i = i;
                    now_j = int(j * per_day + (j_ADD - int(0.5 * num_add_days)) + BEGIN_DAY + 365) % 365;
              
                    if (now_j >= 365) {
                     now_j = now_j % 365; 
                    }
                    if (now_j < 0) {
                     now_j = (now_j + 365) % 365; 
                    }
              
                    if (impacts_source == databaseNumber_CLIMATE_WY2) {
                        Pa = CLIMATE_WY2[now_i][now_j][_dirnorrad][now_k]; 
                        Pb = CLIMATE_WY2[now_i][now_j][_difhorrad][now_k]; 
                        Pc = CLIMATE_WY2[now_i][now_j][_direffect][now_k]; 
                        Pd = CLIMATE_WY2[now_i][now_j][_difeffect][now_k]; 
                    }
                    if (impacts_source == databaseNumber_ENSEMBLE) {
                        Pa = ENSEMBLE[now_i][now_j][_dirnorrad][now_k]; 
                        Pb = ENSEMBLE[now_i][now_j][_difhorrad][now_k]; 
                        Pc = ENSEMBLE[now_i][now_j][_direffect][now_k]; 
                        Pd = ENSEMBLE[now_i][now_j][_difeffect][now_k]; 
                    }            
                    if (impacts_source == databaseNumber_OBSERVED) {
                        Pa = OBSERVED[now_i][now_j][_dirnorrad][now_k]; 
                        Pb = OBSERVED[now_i][now_j][_difhorrad][now_k]; 
                        Pc = OBSERVED[now_i][now_j][_direffect][now_k]; 
                        Pd = OBSERVED[now_i][now_j][_difeffect][now_k]; 
                    }   
                    if (impacts_source == databaseNumber_CLIMATE_EPW) {
                        Pa = CLIMATE_EPW[now_i][now_j][_dirnorrad][now_k]; 
                        Pb = CLIMATE_EPW[now_i][now_j][_difhorrad][now_k]; 
                        Pc = CLIMATE_EPW[now_i][now_j][_direffect][now_k]; 
                        Pd = CLIMATE_EPW[now_i][now_j][_difeffect][now_k]; 
                    }       
              
                    if ((Pa > 0.9 * FLOAT_undefined) || (Pb > 0.9 * FLOAT_undefined) || (Pc > 0.9 * FLOAT_undefined) || (Pd > 0.9 * FLOAT_undefined)) {
                      _values_R_dir = FLOAT_undefined;
                      _values_R_dif = FLOAT_undefined;
                      _values_E_dir = FLOAT_undefined;
                      _values_E_dif = FLOAT_undefined;
                    }
                    else {
              
                      int drw_count = 0;
                      if (impacts_source == databaseNumber_CLIMATE_EPW) drw_count = SOLARCHVISION_filter("CLIMATE_EPW", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                      if (impacts_source == databaseNumber_CLIMATE_WY2) drw_count = SOLARCHVISION_filter("CLIMATE_WY2", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                      if (impacts_source == databaseNumber_ENSEMBLE) drw_count = SOLARCHVISION_filter("ENSEMBLE", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                      if (impacts_source == databaseNumber_OBSERVED) drw_count = SOLARCHVISION_filter("OBSERVED", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                      
                      if (drw_count == 1) {
                        _values_R_dir = 0.001 * Pa; 
                        _values_R_dif = 0.001 * Pb;  
                        _values_E_dir = 0.001 * Pc;
                        _values_E_dif = 0.001 * Pd;
                        
                        if (_valuesSUM_RAD > 0.9 * FLOAT_undefined) {
                          _valuesSUM_RAD = 0;
                          _valuesSUM_EFF_P = 0;
                          _valuesSUM_EFF_N = 0;
                          _valuesNUM = 0; 
                        }                             
                        else {
                          float[] VECT = {0, 0, 0}; 
                          
                          if (abs(Alpha) > 89.99) {
                            VECT[0] = 0;
                            VECT[1] = 0;
                            VECT[2] = 1;      
                          } else if (Alpha < -89.99) {
                            VECT[0] = 0;
                            VECT[1] = 0;
                            VECT[2] = -1;
                          } else {
                            VECT[0] = sin_ang(Beta);
                            VECT[1] = -cos_ang(Beta);
                            VECT[2] = tan_ang(Alpha);      
                          }  
                          
                          VECT = fn_normalize(VECT);
                          
                          float[] SunV = {SunR[1], SunR[2], SunR[3]};
                          
                          float SunMask = fn_dot(fn_normalize(SunV), fn_normalize(VECT));
                          if (SunMask <= 0) SunMask = 0; // removes backing faces 
                          
                          float SkyMask = (0.5 * (1.0 + (Alpha / 90.0)));
                    
                          float[] ray_start = subFace[s];     
                          float[] ray_direction = {SunR[1],SunR[2],SunR[3]}; // NOT SURE!
                          
                          if (fn_dot(W, ray_direction) > 0) { // removes backing faces
                          
                            if (isIntersected(ray_start, ray_direction, MAX_SHADING_DIST) == 1) { 
                              if (_values_E_dir < 0) {
                                _valuesSUM_EFF_P += -(_values_E_dir * SunMask); 
                                _valuesSUM_EFF_N += -(_values_E_dif * SkyMask); // adding approximate diffuse radiation effect anyway!
                              }
                              else {
                                _valuesSUM_EFF_N += (_values_E_dir * SunMask); 
                                _valuesSUM_EFF_P += (_values_E_dif * SkyMask); // adding approximate diffuse radiation effect anyway!
                              }
                              
                              _valuesSUM_RAD += (_values_R_dif * SkyMask); // only approximate diffuse radiation!
                            }
                            else{ 
                              if (_values_E_dir < 0) {
                                _valuesSUM_EFF_N += -((_values_E_dir * SunMask) + (_values_E_dif * SkyMask)); 
                              }
                              else {
                                _valuesSUM_EFF_P += ((_values_E_dir * SunMask) + (_values_E_dif * SkyMask)); 
                              }
                              
                              _valuesSUM_RAD += ((_values_R_dir * SunMask) + (_values_R_dif * SkyMask)); // calculates total radiation
                            }
                          
                          }
                          _valuesNUM += 1;
                          
                        }
                      }
                    }
                  }
                }
              }
            }    
            if (_valuesNUM != 0) {
               float _valuesMUL = 1.0 / float(j_end - j_start);
                                 
              _valuesSUM_RAD *= _valuesMUL;
              _valuesSUM_EFF_P *= _valuesMUL;
              _valuesSUM_EFF_N *= _valuesMUL;
            }
            else {
              _valuesSUM_RAD = 0; //FLOAT_undefined;
              _valuesSUM_EFF_P = 0; //FLOAT_undefined;
              _valuesSUM_EFF_N = 0; //FLOAT_undefined;
            }


            float AVERAGE, PERCENTAGE, COMPARISON;
            
            AVERAGE = (_valuesSUM_EFF_P - _valuesSUM_EFF_N);
            if ((_valuesSUM_EFF_P + _valuesSUM_EFF_N) > 0.00001) PERCENTAGE = (_valuesSUM_EFF_P - _valuesSUM_EFF_N) / (1.0 * (_valuesSUM_EFF_P + _valuesSUM_EFF_N)); 
            else PERCENTAGE = 0.0;
            COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);
            
            //println("3D-Model >> _valuesSUM_RAD:", _valuesSUM_RAD, "|COMPARISON:", COMPARISON);
            
            {
              float[] ADD_values_RAD = {_valuesSUM_RAD};
              WIN3D_VerticesSolarEnergy = concat(WIN3D_VerticesSolarEnergy, ADD_values_RAD);
              
              float[] ADD_values_EFF = {COMPARISON};
              WIN3D_VerticesSolarEffect = concat(WIN3D_VerticesSolarEffect, ADD_values_EFF);
            }

            float _valuesSUM = 0;
            if (Impact_TYPE == Impact_ACTIVE) _valuesSUM = _valuesSUM_RAD;
            if (Impact_TYPE == Impact_PASSIVE) _valuesSUM = COMPARISON;
            
            if (_valuesSUM < 0.9 * FLOAT_undefined) {
            
              float _u = 0;
              
              if (Impact_TYPE == Impact_ACTIVE) _u = (_Multiplier * _valuesSUM);
              if (Impact_TYPE == Impact_PASSIVE) _u = 0.5 + 0.5 * 0.75 * (_Multiplier * _valuesSUM);
              
              if (PAL_DIR == -1) _u = 1 - _u;
              if (PAL_DIR == -2) _u = 0.5 - 0.5 * _u;
              if (PAL_DIR == 2) _u =  0.5 * _u;
    
              float[] _COL = GET_COLOR_STYLE(PAL_TYPE, _u);
    
              WIN3D_Diagrams.fill(_COL[1], _COL[2], _COL[3], _COL[0]);
      
              WIN3D_Diagrams.vertex(subFace[s][0] * objects_scale, -(subFace[s][1] * objects_scale), subFace[s][2] * objects_scale);
            }
          }
          WIN3D_Diagrams.endShape(CLOSE);
        }
      }
      WIN3D_update_VerticesSolarValue = 0;
    }
  }
    
  CAM_x -= WIN3D_X_coordinate;
  CAM_y += WIN3D_Y_coordinate;
  CAM_z -= WIN3D_Z_coordinate;
  
  float px, py, pz;
  
  px = CAM_x;
  py = CAM_y * cos_ang(WIN3D_RX_coordinate) - CAM_z * sin_ang(WIN3D_RX_coordinate);
  pz = CAM_y * sin_ang(WIN3D_RX_coordinate) + CAM_z * cos_ang(WIN3D_RX_coordinate);
  
  CAM_x = px;
  CAM_y = py;
  CAM_z = pz;
  
  py = CAM_y;
  pz = CAM_z * cos_ang(WIN3D_RY_coordinate) - CAM_x * sin_ang(WIN3D_RY_coordinate);
  px = CAM_z * sin_ang(WIN3D_RY_coordinate) + CAM_x * cos_ang(WIN3D_RY_coordinate);
  
  CAM_x = px;
  CAM_y = py;
  CAM_z = pz;  
  
  pz = CAM_z;
  px = CAM_x * cos_ang(WIN3D_RZ_coordinate) - CAM_y * sin_ang(WIN3D_RZ_coordinate);
  py = CAM_x * sin_ang(WIN3D_RZ_coordinate) + CAM_y * cos_ang(WIN3D_RZ_coordinate);
  
  CAM_x = px;
  CAM_y = py;
  CAM_z = pz;   
  
  //println(CAM_x, CAM_y, CAM_z);

  if (display_allyObject2D != 0) {
    for (int i = 1; i <= allObject2D_num; i++) {
      
      WIN3D_Diagrams.beginShape();
      
      int n = abs(allObject2D_MAP[i]);
      
      int w = Object2DImage[n].width; 
      int h = Object2DImage[n].height;
              
      float x = allObject2D_XYZS[i][0] * objects_scale;
      float y = allObject2D_XYZS[i][1] * objects_scale;
      float z = allObject2D_XYZS[i][2] * objects_scale;
      
      float r = allObject2D_XYZS[i][3] * 0.5 * objects_scale;
      
      float t = atan2(y - CAM_y, x - CAM_x) + 0.5 * PI;
      if (allObject2D_MAP[i] < 0) t += PI; 
  
      WIN3D_Diagrams.texture(Object2DImage[n]);    
      WIN3D_Diagrams.stroke(255, 255, 255, 0);
      WIN3D_Diagrams.fill(255, 255, 255, 0);
      
      WIN3D_Diagrams.vertex(x - r * cos(t), -(y - r * sin(t)), z, 0, h);
      WIN3D_Diagrams.vertex(x + r * cos(t), -(y + r * sin(t)), z, w, h);
      WIN3D_Diagrams.vertex(x + r * cos(t), -(y + r * sin(t)), z + 2 * r, w, 0);
      WIN3D_Diagrams.vertex(x - r * cos(t), -(y - r * sin(t)), z + 2 * r, 0, 0);
      
      WIN3D_Diagrams.endShape(CLOSE);
    }  
  }

}


int isIntersected (float[] ray_pnt, float[] ray_dir, float max_distance) {

  float[] ray_normal = fn_normalize(ray_dir);   

  int hit = 0;

  for (int f = 1; f < allFaces.length; f++) {
    
    if (hit == 0) {

      float backAngles = FLOAT_undefined;  
      float foreAngles = FLOAT_undefined;
  
      float delta = 0.5; 
      float delta_step = -0.5; // going the other way
      
      float[] x = {FLOAT_undefined, FLOAT_undefined};
      float[] y = {FLOAT_undefined, FLOAT_undefined};
      float[] z = {FLOAT_undefined, FLOAT_undefined};
      
      float[] AnglesAll = {0, 0};   
      
      float MAX_AnglesAll = 0;
      int MAX_o = -1;
  
      for (int q = 0; q < 16; q++) {
      //for (int q = 0; q < 12; q++) {
        
        if (hit == 0) {
        
          for (int o = 0; o < 2; o++) {
    
            float delta_test = delta;
            
            if (o == 0) delta_test -= delta_step;
            else delta_test += delta_step;
            
            if (delta_test < 0.01) delta_test = 0.01; // << in order to avoid returning the initial ray point on the surface!
            
            x[o] = ray_pnt[0] + delta_test * ray_normal[0] * max_distance; 
            y[o] = ray_pnt[1] + delta_test * ray_normal[1] * max_distance; 
            z[o] = ray_pnt[2] + delta_test * ray_normal[2] * max_distance; 
            
            AnglesAll[o] = 0;      
          
            for (int i = 0; i < allFaces[f].length; i++) {
              int next_i = (i + 1) % allFaces[f].length;
              
              float[] vectA = {allVertices[allFaces[f][i]][0] - x[o], allVertices[allFaces[f][i]][1] - y[o], allVertices[allFaces[f][i]][2] - z[o]}; 
              float[] vectB = {allVertices[allFaces[f][next_i]][0] - x[o], allVertices[allFaces[f][next_i]][1] - y[o], allVertices[allFaces[f][next_i]][2] - z[o]};
              
              float t = acos_ang(fn_dot(fn_normalize(vectA), fn_normalize(vectB)));
              
              AnglesAll[o] += t;
      
            }
          }

          if (q == 0) {
            foreAngles = AnglesAll[0];
            backAngles = AnglesAll[1];

            MAX_o = 0; 
            delta = 0;
          } 
          else {
            
            if (AnglesAll[0] < AnglesAll[1]) {
              MAX_o = 1;          
              MAX_AnglesAll = AnglesAll[1];
              
              backAngles = AnglesAll[1]; 
              
              delta += delta_step;   
            }
            else {
              MAX_o = 0;
              MAX_AnglesAll = AnglesAll[0];
              
              foreAngles = AnglesAll[0];
              
              delta -= delta_step;
            } 
            
            delta_step *= 0.666; // 0.5; <<<<<<<<<<<<<<<          
    
          }
    
          if (MAX_AnglesAll > 359) {
          //if (MAX_AnglesAll > 357) {
            
            if (delta > 0.01) { // << in order to avoid returning the initial ray point on the surface!
              hit = 1;
            }
          }
        }
      }
    }
  }

  return hit;
}




float[][] getSubFace (int[] the_Face, int Teselation, int n) {

  float[][] return_vertices = {};
    
  int TotalSubNo = 1;
  if (Teselation > 0) TotalSubNo = the_Face.length * int(roundTo(pow(4, Teselation - 1), 1));   
  
  if ((Teselation <= 0) || (n < 0) || (n >= TotalSubNo)) {
    return_vertices = new float[the_Face.length][3];
    
    for (int j = 0; j < the_Face.length; j++) {
      return_vertices[j] = allVertices[the_Face[j]];
    }
  }
  else{
    return_vertices = new float[4][3];
      
    int div = the_Face.length;
    
    int the_first = n % div;
    int the_next = (the_first + 1) % div;
    int the_previous = (the_first + div - 1) % div;

    float[] A = {0,0,0};
    float[] B = {0,0,0};
    float[] C = {0,0,0};
    float[] D = {0,0,0};
    
    for (int i = 0; i < 3; i++) {

      A[i] = allVertices[the_Face[the_first]][i];
      B[i] = 0.5 * (A[i] + allVertices[the_Face[the_next]][i]);
      D[i] = 0.5 * (A[i] + allVertices[the_Face[the_previous]][i]);
      
      for (int j = 0; j < the_Face.length; j++) {
        C[i] += allVertices[the_Face[j]][i] / (1.0 * the_Face.length);
      }
    }
    
    if (Teselation == 1) {
      return_vertices[0] = A; 
      return_vertices[1] = B; 
      return_vertices[2] = C; 
      return_vertices[3] = D; 
    } 
    else {

      int section = n / div;
      int res = int(roundTo(pow(2, Teselation - 1), 1));
      int u = section / res;
      int v = section % res;
      
      float x1 = (1.0 * u) / (1.0 * res);
      float y1 = (1.0 * v) / (1.0 * res);
      float x2 = (1.0 * (u + 1)) / (1.0 * res);
      float y2 = (1.0 * (v + 1)) / (1.0 * res);
      
      float[] P0 = {0,0,0};
      float[] P1 = {0,0,0};
      float[] P2 = {0,0,0};
      float[] P3 = {0,0,0};
      
      for (int i = 0; i < 3; i++) {
        P0[i] = Bilinear(A[i], B[i], C[i], D[i], x1, y1); 
        P1[i] = Bilinear(A[i], B[i], C[i], D[i], x2, y1); 
        P2[i] = Bilinear(A[i], B[i], C[i], D[i], x2, y2); 
        P3[i] = Bilinear(A[i], B[i], C[i], D[i], x1, y2); 
      }      
      
      //return_vertices[0] = P0; 
      //return_vertices[1] = P1; 
      //return_vertices[2] = P2; 
      //return_vertices[3] = P3;

      //to rotate tri-grid cells:

      int d = ((u % 2) + ((v + 1) % 2)) % 2; 
      if (d == 0) {
        return_vertices[0] = P0; 
        return_vertices[1] = P1; 
        return_vertices[2] = P2; 
        return_vertices[3] = P3;     
      }
      else {
        return_vertices[0] = P1; 
        return_vertices[1] = P2; 
        return_vertices[2] = P3; 
        return_vertices[3] = P0;          
      }  
    }
      
  }
  
 
  return return_vertices;
}

float Bilinear (float f_00, float f_10, float f_11, float f_01, float x, float y) {
  
  float f_xy = f_00 * (1 - x) * (1 - y) + f_10 * x * (1 - y) + f_01 * (1 - x) * y + f_11 * x * y;

  return f_xy;
}
  
  
  
  
// ---------------------------------------------------------



   

//Cartesian
//int LAND_n_I_base = 15;
//int LAND_n_J_base = 15;
//int LAND_n_I = LAND_n_I_base * 2 + 1;
//int LAND_n_J = LAND_n_J_base * 2 + 1;    

//Polar
int LAND_n_I_base = 0;
int LAND_n_J_base = 0;
int LAND_n_I = 16 + 1; //8 + 1;
int LAND_n_J = 24 + 1;     

double R_earth = 6373 * 1000;


double LAND_mid_lat;
double LAND_mid_lon;

float[][][] LAND_MESH;

void SOLARCHVISION_LoadLAND (String ProjectSite) {

  LAND_mid_lat = LocationLatitude;
  LAND_mid_lon = LocationLongitude;
  
  LAND_MESH = new float[LAND_n_I][LAND_n_J][3];
  
  if (Load_LAND == 1) {

    for (int i = 0; i < LAND_n_I; i += 1) {
  
      String the_link = "";
      
      XML FileALL = loadXML(LandFolder + "/" + ProjectSite + "/"  + ProjectSite + "/" + nf(i - LAND_n_I_base, 0) + ".xml");
  
      XML[] children0 = FileALL.getChildren("result");
  
      for (int j = 0; j < LAND_n_J; j += 1) {
  
        String txt_elevation = children0[j].getChild("elevation").getContent();
        
        XML[] children1 = children0[j].getChildren("location");
        
        String txt_latitude = children1[0].getChild("lat").getContent();
        String txt_longitude = children1[0].getChild("lng").getContent();
        
        //println(txt_longitude, txt_latitude, txt_elevation);
  
        double _lon = Double.parseDouble(txt_longitude); 
        double _lat = Double.parseDouble(txt_latitude); 
  
        double du = ((_lon - LAND_mid_lon) / 180.0) * (PI * R_earth);
        double dv = ((_lat - LAND_mid_lat) / 180.0) * (PI * R_earth);
        
        float x = (float) du * cos_ang((float) _lat);
        float y = (float) dv; 
        float z = float(txt_elevation);
  
        //println(i, j);
        //println(x,y,z);
        
        LAND_MESH[i][j][0] = x;      
        LAND_MESH[i][j][1] = y;      
        LAND_MESH[i][j][2] = z;      
      }
    }
    
    float h = LAND_MESH[LAND_n_I_base][LAND_n_J_base][2];
    
    //h += 5; // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    for (int i = 0; i < LAND_n_I; i += 1) {
      for (int j = 0; j < LAND_n_J; j += 1) {
        
        LAND_MESH[i][j][2] -= h; 
        
      }
    }
  
  }

}

 
class ParametricGeometry { 
  float value, posX, posY, posZ, powX, powY, powZ, scaleX, scaleY, scaleZ, rotZ; 
  
  ParametricGeometry (float v, float x, float y, float z, float px, float py, float pz, float sx, float sy, float sz, float t) {  
    value = v;
    posX = x;
    posY = y; 
    posZ = z;    
    powX = px;
    powY = py;
    powZ = pz;    
    scaleX = sx;
    scaleY = sy; 
    scaleZ = sz;    
    rotZ = t;
  } 
  
  void updatePosition (float x, float y, float z) {  
    posX = x;
    posY = y; 
    posZ = z;
  }   
  
  void RotateZ (float t) {  
    rotZ += t;
  }    
 
  void Scale (float a, float b, float c) {  
    scaleX *= a;
    scaleY *= b;
    scaleZ *= c;
  }     
  
  float Distance (float a, float b, float c) {
    a -= posX;
    b -= posY;    
    c -= posZ;
    
    float x = a * cos_ang(rotZ) - b * sin_ang(rotZ);
    float y = a * sin_ang(rotZ) + b * cos_ang(rotZ); 
    float z = c;

    x += posX;
    y += posY;  
    z += posZ;

    return(pow((pow(abs(x - posX) / scaleX, powX) + pow(abs(y - posY) / scaleY, powY) + pow(abs(z - posZ) / scaleZ, powZ)), (3.0 / (powX + powY + powZ))) / value); 
    
  } 
  
} 


void SOLARCHVISION_remove_ParametricGeometries () {
  SolidBuildings = new ParametricGeometry[0];
}


ParametricGeometry[] SolidBuildings = {};

void SOLARCHVISION_add_ParametricGeometries () {
/*
  {
    float x = 0;
    float y = 0;
    float z = 0;
    float r = 10;
    add_RecursiveSphere(1, x,y,z, r, 5, 0);
    ParametricGeometry[] newSolidBuilding = {new ParametricGeometry(1, x,y,z, 2,2,2, r,r,r, 0)};
    SolidBuildings = (ParametricGeometry[]) concat(SolidBuildings, newSolidBuilding);
  }

  {
    float x = 30;
    float y = 0;
    float z = 0;
    float r = 8;
    add_RecursiveSphere(2, x,y,z, r, 4, 0);
    ParametricGeometry[] newSolidBuilding = {new ParametricGeometry(1, x,y,z, 2,2,2, r,r,r, 0)};
    SolidBuildings = (ParametricGeometry[]) concat(SolidBuildings, newSolidBuilding);
  }

  {
    float x = 0;
    float y = 20;
    float z = 0;
    float r = 8;
    add_RecursiveSphere(3, x,y,z, r, 3, 0);
    ParametricGeometry[] newSolidBuilding = {new ParametricGeometry(1, x,y,z, 2,2,2, r,r,r, 0)};
    SolidBuildings = (ParametricGeometry[]) concat(SolidBuildings, newSolidBuilding);
  }
*/


  {
    float x = 0;
    float y = 0;
    float z = -0.5;
    float dx = 100;
    float dy = 100;
    float dz = 1;
    float t = 0;
    add_Box_Core(7, x,y,z, dx, dy, dz, t);
    ParametricGeometry[] newSolidBuilding = {new ParametricGeometry(1, x,y,z, 8,8,8, dx,dy,dz, t)};
    SolidBuildings = (ParametricGeometry[]) concat(SolidBuildings, newSolidBuilding);
  }  


  {
    float x = 0;
    float y = 0;
    float z = 0;
    float dx = 15;
    float dy = 10;
    float dz = 5;
    float t = 0;
    add_Box_Core(1, x,y,z, dx, dy, dz, t);
    ParametricGeometry[] newSolidBuilding = {new ParametricGeometry(1, x,y,z, 8,8,8, dx,dy,dz, t)};
    SolidBuildings = (ParametricGeometry[]) concat(SolidBuildings, newSolidBuilding);
  }

  {
    float x = 50;
    float y = 0;
    float z = 0;
    float dx = 5;
    float dy = 10;
    float dz = 15;
    float t = 0;
    add_Box_Core(2, x,y,z, dx, dy, dz, t);
    ParametricGeometry[] newSolidBuilding = {new ParametricGeometry(1, x,y,z, 8,8,8, dx,dy,dz, t)};
    SolidBuildings = (ParametricGeometry[]) concat(SolidBuildings, newSolidBuilding);
  }

  {
    float x = 0;
    float y = 50;
    float z = 0;
    float dx = 10;
    float dy = 10;
    float dz = 10;
    float t = 45;
    add_Box_Core(3, x,y,z, dx, dy, dz, t);
    ParametricGeometry[] newSolidBuilding = {new ParametricGeometry(1, x,y,z, 8,8,8, dx,dy,dz, t)};
    SolidBuildings = (ParametricGeometry[]) concat(SolidBuildings, newSolidBuilding);
  }

  {
    float x = 25;
    float y = 25;
    float z = 25;
    float r = 10;
    add_RecursiveSphere(4, x,y,z, r, 4, 0);
    ParametricGeometry[] newSolidBuilding = {new ParametricGeometry(1, x,y,z, 2,2,2, r,r,r, 0)};
    SolidBuildings = (ParametricGeometry[]) concat(SolidBuildings, newSolidBuilding);
  }  

/*
  {
    float x = -25;
    float y = -25;
    float z = 25;
    float rx = 40;
    float ry = 10;
    float rz = 20;
    float px = 2;
    float py = 2;
    float pz = 2;
    
    add_SuperSphere (5, x,y,z, pz,py,pz, rx,ry,rz, 5);
    ParametricGeometry[] newSolidBuilding = {new ParametricGeometry(1, x,y,z, px,py,pz, rx,ry,rz, 0)};
    SolidBuildings = (ParametricGeometry[]) concat(SolidBuildings, newSolidBuilding);
  }  
*/



}

float Field_scale_U = 200; //800;
float Field_scale_V = 200; //800;

int Field_RES1 = 400;
int Field_RES2 = 400;

PImage Field_Image = createImage(Field_RES1, Field_RES2, RGB);

float Field_Multiplier = 1.0; //0.1; //10.0; 

int display_Field_Image = 0; // 0:off, 1:horizontal, 2:vertical(front), 3:vertical(side)

float[] Field_Elevation = {0, 0, 0, 0};
float[] Field_Image_rotation = {0, 0, 0, 0};

void SOLARCHVISION_calculate_ParametricGeometries_Field () {

  Field_Image.loadPixels();
  
  for (int i = 0; i < Field_RES1; i++) {
    for (int j = 0; j < Field_RES2; j++) {
      
      float val = 0;
      for (int n = 0; n < SolidBuildings.length; n++) {
        
        float d = 0; 
        
        if (display_Field_Image == 1) {
          float a = (i - 0.5 * Field_RES1) * (Field_scale_U / Field_RES1);
          float b = (j - 0.5 * Field_RES2) * (Field_scale_V / Field_RES2);
          float c = Field_Elevation[display_Field_Image];
          
          float x = a * cos_ang(-Field_Image_rotation[display_Field_Image]) - b * sin_ang(-Field_Image_rotation[display_Field_Image]);
          float y = a * sin_ang(-Field_Image_rotation[display_Field_Image]) + b * cos_ang(-Field_Image_rotation[display_Field_Image]);
          float z = c;
          
          d = SolidBuildings[n].Distance(x, y, z);
        }
        else if (display_Field_Image == 2) {
          float a = (i - 0.5 * Field_RES1) * (Field_scale_U / Field_RES1);
          float b = (j - 0.5 * Field_RES2) * (Field_scale_V / Field_RES2);
          float c = -Field_Elevation[display_Field_Image];
          
          float x = a * cos_ang(-Field_Image_rotation[display_Field_Image]) - c * sin_ang(-Field_Image_rotation[display_Field_Image]);
          float y = a * sin_ang(-Field_Image_rotation[display_Field_Image]) + c * cos_ang(-Field_Image_rotation[display_Field_Image]);
          float z = b; 
          
          d = SolidBuildings[n].Distance(x, y, -z);
        }
        else if (display_Field_Image == 3) {
          float a = (i - 0.5 * Field_RES1) * (Field_scale_U / Field_RES1);
          float b = (j - 0.5 * Field_RES2) * (Field_scale_V / Field_RES2);
          float c = Field_Elevation[display_Field_Image];
          
          float x = c * cos_ang(-Field_Image_rotation[display_Field_Image]) - b * sin_ang(-Field_Image_rotation[display_Field_Image]);
          float y = c * sin_ang(-Field_Image_rotation[display_Field_Image]) + b * cos_ang(-Field_Image_rotation[display_Field_Image]);
          float z = a; 
          
          d = SolidBuildings[n].Distance(x, y, z);
        }
        
        if (d > 0) {
          val += 1.0 / pow(d, Field_Image_Power);
        } 
      }
      
      //float _u = -Field_Multiplier * val;
      float _u = Field_Multiplier * val;

      float[] _COL = SOLARCHVISION_DRYWCBD(roundTo(_u, 0.05));

      Field_Image.pixels[i + j * Field_RES1] = color(_COL[1], _COL[2], _COL[3]);
    }
  }
  
 
  Field_Image.updatePixels();
  
  
}




float[][] skyVertices = {{0,0,0}};
int[][] skyFaces = {{0}};

int POINTER_skyVertices = 1;
int POINTER_skyFaces = 1;


float[][] TempObjectVertices = {{0,0,0}};
int[][] TempObjectFaces = {{0}};

int POINTER_TempObjectVertices = 1;
int POINTER_TempObjectFaces = 1;

void add_RecursiveSphere (int m, float cx, float cy, float cz, float r, int Teselation, int isSky) {

  defaultMaterial = m;
  
  int[] vT = new int[6];
  int[] vB = new int[6];
  
  vT[0] = addToTempObjectVertices(0,0,1);
  vB[0] = addToTempObjectVertices(0,0,-1);
  
  for (int i = 1; i <= 5; i++) {
    float t = i * 72;
    
    float R_in = pow(5.0, 0.5) * 2.0 / 5.0;  
    float H_in = pow(5.0, 0.5) * 1.0 / 5.0;
    
    vT[i] = addToTempObjectVertices(R_in * cos_ang(t), R_in * sin_ang(t), H_in);
    vB[i] = addToTempObjectVertices(R_in * cos_ang(t + 36), R_in * sin_ang(t + 36), -H_in);
  } 


  int BuildFaces = 0;

  for (int Loop_Teselation = 1; Loop_Teselation <= Teselation; Loop_Teselation++) { // added so that the tree generated from the bottom to the top!

    if (Loop_Teselation == Teselation) BuildFaces = 1;
    else BuildFaces = 0;

    for (int i = 1; i <= 5; i++) {
      
      int next_i = (i % 5) + 1;
      int prev_i = ((i + 5 - 2) % 5) + 1;
      
      {
        myLozenge(
                  TempObjectVertices[vT[prev_i]][0], TempObjectVertices[vT[prev_i]][1], TempObjectVertices[vT[prev_i]][2],
                  TempObjectVertices[vT[i]][0], TempObjectVertices[vT[i]][1], TempObjectVertices[vT[i]][2],
                  TempObjectVertices[vT[next_i]][0], TempObjectVertices[vT[next_i]][1], TempObjectVertices[vT[next_i]][2],
                  TempObjectVertices[vT[0]][0], TempObjectVertices[vT[0]][1], TempObjectVertices[vT[0]][2],                  
                  Loop_Teselation, BuildFaces);
      }
      
      {
        myLozenge(
                  TempObjectVertices[vT[0]][0], TempObjectVertices[vT[0]][1], TempObjectVertices[vT[0]][2],
                  TempObjectVertices[vT[i]][0], TempObjectVertices[vT[i]][1], TempObjectVertices[vT[i]][2],
                  TempObjectVertices[vB[i]][0], TempObjectVertices[vB[i]][1], TempObjectVertices[vB[i]][2],
                  TempObjectVertices[vT[next_i]][0], TempObjectVertices[vT[next_i]][1], TempObjectVertices[vT[next_i]][2],
                  Loop_Teselation, BuildFaces);
      }      

      {
        myLozenge(
                  TempObjectVertices[vB[i]][0], TempObjectVertices[vB[i]][1], TempObjectVertices[vB[i]][2],
                  TempObjectVertices[vT[i]][0], TempObjectVertices[vT[i]][1], TempObjectVertices[vT[i]][2],
                  TempObjectVertices[vT[prev_i]][0], TempObjectVertices[vT[prev_i]][1], TempObjectVertices[vT[prev_i]][2],
                  TempObjectVertices[vB[prev_i]][0], TempObjectVertices[vB[prev_i]][1], TempObjectVertices[vB[prev_i]][2],
                  Loop_Teselation, BuildFaces);
      }     

      {
        myLozenge(
  
                  TempObjectVertices[vT[i]][0], TempObjectVertices[vT[i]][1], TempObjectVertices[vT[i]][2],
                  TempObjectVertices[vB[prev_i]][0], TempObjectVertices[vB[prev_i]][1], TempObjectVertices[vB[prev_i]][2],                    
                  TempObjectVertices[vB[0]][0], TempObjectVertices[vB[0]][1], TempObjectVertices[vB[0]][2],
                  TempObjectVertices[vB[i]][0], TempObjectVertices[vB[i]][1], TempObjectVertices[vB[i]][2],
              
                  Loop_Teselation, BuildFaces);
      }

      {
        myLozenge(
                  TempObjectVertices[vB[prev_i]][0], TempObjectVertices[vB[prev_i]][1], TempObjectVertices[vB[prev_i]][2],
                  TempObjectVertices[vB[0]][0], TempObjectVertices[vB[0]][1], TempObjectVertices[vB[0]][2],
                  TempObjectVertices[vB[next_i]][0], TempObjectVertices[vB[next_i]][1], TempObjectVertices[vB[next_i]][2],
                  TempObjectVertices[vB[i]][0], TempObjectVertices[vB[i]][1], TempObjectVertices[vB[i]][2],
                  
                  Loop_Teselation, BuildFaces);
      }      

  
    }   

  }


  println("Vertices:", POINTER_TempObjectVertices);
  println("Faces:", POINTER_TempObjectFaces);

  if (isSky == 0) {
    addTempObjectToScene(cx,cy,cz,r,r,r);
  }
  else if (isSky == 1) {
    
    skyVertices = TempObjectVertices;
    skyFaces = TempObjectFaces;
    
    POINTER_skyVertices = POINTER_TempObjectVertices;
    POINTER_skyFaces = POINTER_TempObjectFaces;    

    POINTER_TempObjectVertices = 1;
    POINTER_TempObjectFaces = 1;  
  }  
  else {
    // Nothing. In this case we should add temp object outside this function. See SuperSphere
  }
  
}  


void add_SuperSphere (int m, float cx, float cy, float cz, float px, float py, float pz, float sx, float sy, float sz, int Teselation) {

  add_RecursiveSphere(m, cx, cy, cz, 1, Teselation, -1); // passing with isSky:-1

  float value, posX, posY, posZ, powX, powY, powZ, scaleX, scaleY, scaleZ, rotZ; 
  value = 1;
  posX = 0;
  posY = 0; 
  posZ = 0;    
  powX = px;
  powY = py;
  powZ = pz;    
  scaleX = 1;
  scaleY = 1; 
  scaleZ = 1;    

  for (int i = 1; i < POINTER_TempObjectVertices; i++) {
    
    float x = TempObjectVertices[i][0];
    float y = TempObjectVertices[i][1];
    float z = TempObjectVertices[i][2];

    float the_dist = (pow((pow(abs(x - posX) / scaleX, powX) + pow(abs(y - posY) / scaleY, powY) + pow(abs(z - posZ) / scaleZ, powZ)), (3.0 / (powX + powY + powZ))) / value);
    if (the_dist != 0) {
      TempObjectVertices[i][0] = x / the_dist;
      TempObjectVertices[i][1] = y / the_dist;
      TempObjectVertices[i][2] = z / the_dist;
    }
  }

  addTempObjectToScene(cx,cy,cz,sx,sy,sz);
}  


int addToTempObjectVertices (float x, float y, float z) {

  float[][] newVertice = {{x, y, z}}; 
  
  int vertice_existed = 0;

  float min_dist = FLOAT_undefined;

  for (int i = 1; i < POINTER_TempObjectVertices; i++) {

    float the_dist = fn_dist(newVertice[0], TempObjectVertices[i]);
    
    if (the_dist < 0.1) { // avoid creating duplicate vertices - WELD is necessary for recursive spheres!

      if (min_dist > the_dist) {
        min_dist = the_dist;
        vertice_existed = i;
      }
    }
  }

  if (vertice_existed == 0) { 

    if (POINTER_TempObjectVertices >= TempObjectVertices.length) {
      TempObjectVertices = (float[][]) concat(TempObjectVertices, newVertice);
    }
    else{
      TempObjectVertices[POINTER_TempObjectVertices][0] = x;
      TempObjectVertices[POINTER_TempObjectVertices][1] = y;
      TempObjectVertices[POINTER_TempObjectVertices][2] = z;
    }

    vertice_existed = POINTER_TempObjectVertices;

    POINTER_TempObjectVertices += 1;

  }

  return(vertice_existed);
}

int addToTempObjectFaces (int[] f) {

  int face_existed = 0;
  
  for (int i = 1; i < POINTER_TempObjectFaces; i++) {
    if (f.length == TempObjectFaces[i].length) {

      for (int k = 0; k < f.length; k++) { // "k" introduces different variations that two faces could match

        for (int dir = -1; dir <= 1; dir += 2) { // "dir" introduces different diretions that two faces could match

          //println("\ndir=", dir);
          
          float total_distances = 0; 
          
          for (int j = 0; j < f.length; j++) {

            int q = (j * dir + k + f.length) % f.length;

            //print("q=", q, "; k=" );
          
            total_distances += fn_dist(TempObjectVertices[f[q]], TempObjectVertices[TempObjectFaces[i][j]]);
  
          }

          if (total_distances < 0.0001) { // avoid creating duplicate faces
            //println("A duplicate face detected :", i);
          
            face_existed = i;
            break;
          }   

        }

      }
      
    }
    if (face_existed != 0) break; 
  }
  
  if (face_existed == 0) { 
  
    if (POINTER_TempObjectFaces >= TempObjectFaces.length) {
      int[][] newFace = {f}; 
    
      TempObjectFaces = (int[][]) concat(TempObjectFaces, newFace);
    }
    else{
      for (int i = 0; i < f.length; i++) {
        TempObjectFaces[POINTER_TempObjectFaces][i] = f[i];
      }
    }

    face_existed = POINTER_TempObjectFaces;
    
    POINTER_TempObjectFaces += 1;    
    
  }
  
  return(face_existed);
  
}

void addTempObjectToScene (float cx, float cy, float cz, float sx, float sy, float sz) {
  
  for (int i = 1; i < POINTER_TempObjectFaces; i++) {
    
    int[] new_vert_numbers = new int [TempObjectFaces[i].length];
    
    for (int j = 0; j < TempObjectFaces[i].length; j++) {
      
      new_vert_numbers[j] = addToVertices(
                                          TempObjectVertices[TempObjectFaces[i][j]][0] * sx + cx,
                                          TempObjectVertices[TempObjectFaces[i][j]][1] * sy + cy,
                                          TempObjectVertices[TempObjectFaces[i][j]][2] * sz + cz);
    }
    addToFaces(new_vert_numbers);    
  }

  POINTER_TempObjectVertices = 1;
  POINTER_TempObjectFaces = 1;
}

void myLozenge (float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3, float x4, float y4, float z4, int Teselation, int BuildFaces) {
  

  if (Teselation > 0) {
 
    if (Teselation == 1) {

      int[] newPoly = new int [4];
      
      newPoly[0] = addToTempObjectVertices(x1,y1,z1);    
      newPoly[1] = addToTempObjectVertices(x2,y2,z2);
      newPoly[2] = addToTempObjectVertices(x3,y3,z3);
      newPoly[3] = addToTempObjectVertices(x4,y4,z4);
      
      if (BuildFaces != 0) {
        addToTempObjectFaces(newPoly);
      }
      
      {
        // because the vertices might be welded to a nearest point:  
        
        x1 = TempObjectVertices[newPoly[0]][0];
        y1 = TempObjectVertices[newPoly[0]][1];
        z1 = TempObjectVertices[newPoly[0]][2];

        x2 = TempObjectVertices[newPoly[1]][0];
        y2 = TempObjectVertices[newPoly[1]][1];
        z2 = TempObjectVertices[newPoly[1]][2];
 
        x3 = TempObjectVertices[newPoly[2]][0];
        y3 = TempObjectVertices[newPoly[2]][1];
        z3 = TempObjectVertices[newPoly[2]][2];
 
        x4 = TempObjectVertices[newPoly[3]][0];
        y4 = TempObjectVertices[newPoly[3]][1];
        z4 = TempObjectVertices[newPoly[3]][2];
        
      }       
    }
   


    Teselation -= 1;

    float[] M = {(x1 + x2 + x4) / 3.0, (y1 + y2 + y4) / 3.0, (z1 + z2 + z4) / 3.0};
    float[] N = {(x3 + x2 + x4) / 3.0, (y3 + y2 + y4) / 3.0, (z3 + z2 + z4) / 3.0};
    
    M = fn_normalize(M);
    N = fn_normalize(N);

    myLozenge(x2,y2,z2, N[0],N[1],N[2], x4,y4,z4, M[0],M[1],M[2], Teselation, BuildFaces);     


    if (BuildFaces != 0) 
    {
      
      float[] P = M;
      
      PVector A_vec = new PVector(x1,y1,z1);
      PVector B_vec = new PVector(x2,y2,z2);
      
      PVector AxB_vec = A_vec.cross(B_vec);
      AxB_vec.normalize();
      
      float distP_OAB = P[0] * AxB_vec.x + P[1] * AxB_vec.y + P[2] * AxB_vec.z;
        
      float[] Q = {P[0] - 2 * distP_OAB * AxB_vec.x, P[1] - 2 * distP_OAB * AxB_vec.y, P[2] - 2 * distP_OAB * AxB_vec.z};
      
      Q = fn_normalize(Q);
      
      myLozenge(x2,y2,z2, P[0],P[1],P[2], x1,y1,z1, Q[0],Q[1],Q[2], Teselation, BuildFaces);
    }


    if (BuildFaces != 0) 
    {
      
      float[] P = N;
      
      PVector A_vec = new PVector(x3,y3,z3);
      PVector B_vec = new PVector(x4,y4,z4);
      
      PVector AxB_vec = A_vec.cross(B_vec);
      AxB_vec.normalize();
      
      float distP_OAB = P[0] * AxB_vec.x + P[1] * AxB_vec.y + P[2] * AxB_vec.z;
        
      float[] Q = {P[0] - 2 * distP_OAB * AxB_vec.x, P[1] - 2 * distP_OAB * AxB_vec.y, P[2] - 2 * distP_OAB * AxB_vec.z};
      
      Q = fn_normalize(Q);
      
      myLozenge(x4,y4,z4, P[0],P[1],P[2], x3,y3,z3, Q[0],Q[1],Q[2], Teselation, BuildFaces);
    }


  }

}

PVector fn_perpendicular (PVector M, PVector A, PVector B) {

  PVector AB = PVector.sub(B, A);
  PVector AM = PVector.sub(M, A);
  PVector HM = PVector.sub(AM, PVector.mult(AB, PVector.dot(AM, AB) / AB.magSq()));
  
  PVector H = PVector.sub(M, HM);
  
  return H;
}




float SolarAtSurface (float SunR1, float SunR2, float SunR3, float SunR4, float SunR5, float Alpha, float Beta, float THE_ALBEDO) {

  float return_value = FLOAT_undefined;

  if ((SunR1 < 0.9 * FLOAT_undefined) && (SunR2 < 0.9 * FLOAT_undefined) && (SunR3 < 0.9 * FLOAT_undefined) && (SunR4 < 0.9 * FLOAT_undefined) && (SunR5 < 0.9 * FLOAT_undefined)) { 

    float[] VECT = {0, 0, 0}; 

    if (abs(Alpha) > 89.99) {
      VECT[0] = 0;
      VECT[1] = 0;
      VECT[2] = 1;      
    } else if (Alpha < -89.99) {
      VECT[0] = 0;
      VECT[1] = 0;
      VECT[2] = -1;
    } else {
      VECT[0] = sin_ang(Beta);
      VECT[1] = -cos_ang(Beta);
      VECT[2] = tan_ang(Alpha);      
    }   
  
    VECT = fn_normalize(VECT);


    float[] SunV = {SunR1, SunR2, SunR3};
  
    float SunMask = fn_dot(fn_normalize(SunV), fn_normalize(VECT));
    if (SunMask <= 0) SunMask = 0; // removes backing faces 
    
    float SkyMask = (0.5 * (1.0 + (Alpha / 90.0)));
    
    return_value = (SunR4 * SunMask) + (SunR5 * SkyMask);    

    
/*
    float[] REF_SunV = {SunR1, SunR2, -SunR3};
  
    float REF_SunMask = fn_dot(fn_normalize(REF_SunV), fn_normalize(VECT));
    if (REF_SunMask <= 0) REF_SunMask = 0; // removes backing faces 
   
    float REF_SkyMask = 1 - (0.5 * (1.0 + (Alpha / 90.0)));      
    
    return_value +=  (0.01 * THE_ALBEDO) * ((SunR4 * REF_SunMask) + (SunR5 * REF_SkyMask));
*/

  }
  
  return (return_value);
}



float stp_slp;
float stp_dir;
int n_slp;  
int n_dir;

float[][]LocationExposure;

void SOLARCHVISION_build_SolarProjection_array () {
  
  stp_slp = GlobeRES;
  stp_dir = GlobeRES;
  n_slp = int(roundTo(180.0 / (1.0 * stp_slp), 1)) + 1;  
  n_dir = int(roundTo(360.0 / (1.0 * stp_dir), 1));

  LocationExposure = new float[n_slp][n_dir];

  for (int a = 0; a < n_slp; a += 1) {
    for (int b = 0; b < n_dir; b += 1) {  
      LocationExposure[a][b] = FLOAT_undefined;
    }
  } 
}


void SolarProjection () {
  
  float pre_per_day = per_day;
  int pre_num_add_days = num_add_days;
  if ((impacts_source == databaseNumber_ENSEMBLE) || (impacts_source == databaseNumber_OBSERVED)) {
    per_day = 1;
    num_add_days = 1;
  }
  
  int start_z = get_startZ_endZ(impacts_source)[0];
  int end_z = get_startZ_endZ(impacts_source)[1]; 
  int layers_count = get_startZ_endZ(impacts_source)[2];   



  if (plot_impacts % 2 == 0) Impact_TYPE = Impact_ACTIVE; 
  else Impact_TYPE = Impact_PASSIVE;



  float Pa = FLOAT_undefined;
  float Pb = FLOAT_undefined;
  float Pc = FLOAT_undefined;
  float Pd = FLOAT_undefined;

  float _values_R_dir;
  float _values_R_dif;
  float _values_E_dir;
  float _values_E_dif;
  
  int now_k = 0;
  int now_i = 0;
  int now_j = 0;

  int l = impact_layer;

  float[][] TOTAL_valuesSUM_RAD = new float [1 + int(180 / stp_slp)][1 + int(360 / stp_dir)];
  float[][] TOTAL_valuesSUM_EFF_P = new float [1 + int(180 / stp_slp)][1 + int(360 / stp_dir)];
  float[][] TOTAL_valuesSUM_EFF_N = new float [1 + int(180 / stp_slp)][1 + int(360 / stp_dir)];
  int[][] TOTAL_valuesNUM = new int [1 + int(180 / stp_slp)][1 + int(360 / stp_dir)];

  for (int a = 0; a <= int(180 / stp_slp); a += 1) { 
    for (int b = 0; b < int(360 / stp_dir); b += 1) {
      TOTAL_valuesSUM_RAD[a][b] = FLOAT_undefined;
      TOTAL_valuesSUM_EFF_P[a][b] = FLOAT_undefined;
      TOTAL_valuesSUM_EFF_N[a][b] = FLOAT_undefined;
      TOTAL_valuesNUM[a][b] = 0;
    }
  }
  
  for (int j = j_start; j < j_end; j += 1) {

    now_j = (j * int(per_day) + BEGIN_DAY + 365) % 365;

    if (now_j >= 365) {
     now_j = now_j % 365; 
    }
    if (now_j < 0) {
     now_j = (now_j + 365) % 365; 
    }
 
    float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0); 

    float _sunrise = SOLARCHVISION_Sunrise(LocationLatitude, DATE_ANGLE); 
    float _sunset = SOLARCHVISION_Sunset(LocationLatitude, DATE_ANGLE);

    int[] Normals_COL_N;
    Normals_COL_N = new int[9];
    Normals_COL_N = SOLARCHVISION_PROCESS_DAILY_SCENARIOS(layers_count, start_z, end_z, j, DATE_ANGLE);

    for (int nk = Normals_COL_N[l]; nk <= Normals_COL_N[l]; nk += 1) {
      if (nk != -1) {
        int k = int(nk / num_add_days);
        int j_ADD = nk % num_add_days; 

        for (int a = 0; a <= int(180 / stp_slp); a += 1) { 
          float Alpha = a * stp_slp - 90;
          for (int b = 0; b < int(360 / stp_dir); b += 1) {
            float Beta = b * stp_dir;
            
            float _valuesSUM_RAD = 0;
            float _valuesSUM_EFF_P = 0;
            float _valuesSUM_EFF_N = 0;
            int _valuesNUM = 0; 

            for (int i = 0; i < 24; i += 1) {
              
              float HOUR_ANGLE = i; 
              float[] SunR = SOLARCHVISION_SunPosition(LocationLatitude, DATE_ANGLE, HOUR_ANGLE);

              if (SunR[3] > 0) {

                now_k = k;
                now_i = i;
                now_j = int(j * per_day + (j_ADD - int(0.5 * num_add_days)) + BEGIN_DAY + 365) % 365;

                if (now_j >= 365) {
                 now_j = now_j % 365; 
                }
                if (now_j < 0) {
                 now_j = (now_j + 365) % 365; 
                }

                if (impacts_source == databaseNumber_CLIMATE_WY2) {
                    Pa = CLIMATE_WY2[now_i][now_j][_dirnorrad][now_k]; 
                    Pb = CLIMATE_WY2[now_i][now_j][_difhorrad][now_k]; 
                    Pc = CLIMATE_WY2[now_i][now_j][_direffect][now_k]; 
                    Pd = CLIMATE_WY2[now_i][now_j][_difeffect][now_k]; 
                }
                if (impacts_source == databaseNumber_ENSEMBLE) {
                    Pa = ENSEMBLE[now_i][now_j][_dirnorrad][now_k]; 
                    Pb = ENSEMBLE[now_i][now_j][_difhorrad][now_k]; 
                    Pc = ENSEMBLE[now_i][now_j][_direffect][now_k]; 
                    Pd = ENSEMBLE[now_i][now_j][_difeffect][now_k]; 
                }            
                if (impacts_source == databaseNumber_OBSERVED) {
                    Pa = OBSERVED[now_i][now_j][_dirnorrad][now_k]; 
                    Pb = OBSERVED[now_i][now_j][_difhorrad][now_k]; 
                    Pc = OBSERVED[now_i][now_j][_direffect][now_k]; 
                    Pd = OBSERVED[now_i][now_j][_difeffect][now_k]; 
                }   
                if (impacts_source == databaseNumber_CLIMATE_EPW) {
                    Pa = CLIMATE_EPW[now_i][now_j][_dirnorrad][now_k]; 
                    Pb = CLIMATE_EPW[now_i][now_j][_difhorrad][now_k]; 
                    Pc = CLIMATE_EPW[now_i][now_j][_direffect][now_k]; 
                    Pd = CLIMATE_EPW[now_i][now_j][_difeffect][now_k]; 
                }       
    
                if ((Pa > 0.9 * FLOAT_undefined) || (Pb > 0.9 * FLOAT_undefined) || (Pc > 0.9 * FLOAT_undefined) || (Pd > 0.9 * FLOAT_undefined)) {
                  _values_R_dir = FLOAT_undefined;
                  _values_R_dif = FLOAT_undefined;
                  _values_E_dir = FLOAT_undefined;
                  _values_E_dif = FLOAT_undefined;
                }
                else {

                  int drw_count = 0;
                  if (impacts_source == databaseNumber_CLIMATE_EPW) drw_count = SOLARCHVISION_filter("CLIMATE_EPW", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                  if (impacts_source == databaseNumber_CLIMATE_WY2) drw_count = SOLARCHVISION_filter("CLIMATE_WY2", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                  if (impacts_source == databaseNumber_ENSEMBLE) drw_count = SOLARCHVISION_filter("ENSEMBLE", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                  if (impacts_source == databaseNumber_OBSERVED) drw_count = SOLARCHVISION_filter("OBSERVED", _cloudcover, filter_type, sky_scenario, now_i, now_j, now_k);
                  
                  if (drw_count == 1) {
                    _values_R_dir = 0.001 * Pa;
                    _values_R_dif = 0.001 * Pb;
                    _values_E_dir = 0.001 * Pc;
                    _values_E_dif = 0.001 * Pd;
                    
                    if (_valuesSUM_RAD > 0.9 * FLOAT_undefined) {
                      _valuesSUM_RAD = 0;
                      _valuesSUM_EFF_P = 0;
                      _valuesSUM_EFF_N = 0;
                      _valuesNUM = 0; 
                    }                             
                    else {

                      if (_values_E_dir < 0) {
                        _valuesSUM_EFF_N += -SolarAtSurface(SunR[1], SunR[2], SunR[3], _values_E_dir, _values_E_dif, Alpha, Beta, GlobalAlbedo); 
                      }
                      else {
                        _valuesSUM_EFF_P += SolarAtSurface(SunR[1], SunR[2], SunR[3], _values_E_dir, _values_E_dif, Alpha, Beta, GlobalAlbedo); 
                      }

                      _valuesSUM_RAD += SolarAtSurface(SunR[1], SunR[2], SunR[3], _values_R_dir, _values_R_dif, Alpha, Beta, GlobalAlbedo); 
                      
                      _valuesNUM += 1;
                      
                    }
                  }
                }
              }
            }
            
  
            if (_valuesNUM != 0) {
              //float _valuesMUL = SOLARCHVISION_DayTime(LocationLatitude, DATE_ANGLE) / (1.0 * _valuesNUM);  
              //float _valuesMUL = int(SOLARCHVISION_DayTime(LocationLatitude, DATE_ANGLE)) / (1.0 * _valuesNUM);
              float _valuesMUL = roundTo(SOLARCHVISION_DayTime(LocationLatitude, DATE_ANGLE), 1) / (1.0 * _valuesNUM);
                                 
              _valuesSUM_RAD *= _valuesMUL;
              _valuesSUM_EFF_P *= _valuesMUL;
              _valuesSUM_EFF_N *= _valuesMUL;
              
              if (TOTAL_valuesNUM[a][b] == 0) {
                TOTAL_valuesSUM_RAD[a][b] = 0;
                TOTAL_valuesSUM_EFF_P[a][b] = 0;
                TOTAL_valuesSUM_EFF_N[a][b] = 0;
              }

              TOTAL_valuesSUM_RAD[a][b] += _valuesSUM_RAD;
              TOTAL_valuesSUM_EFF_P[a][b] += _valuesSUM_EFF_P;
              TOTAL_valuesSUM_EFF_N[a][b] += _valuesSUM_EFF_N;
              TOTAL_valuesNUM[a][b] += 1;
            }
            else {
              _valuesSUM_RAD = FLOAT_undefined;
              _valuesSUM_EFF_P = FLOAT_undefined;
              _valuesSUM_EFF_N = FLOAT_undefined;
            }
            /*

            float AVERAGE, PERCENTAGE, COMPARISON;
            
            AVERAGE = (_valuesSUM_EFF_P - _valuesSUM_EFF_N);
            if ((_valuesSUM_EFF_P + _valuesSUM_EFF_N) > 0.00001) PERCENTAGE = (_valuesSUM_EFF_P - _valuesSUM_EFF_N) / (1.0 * (_valuesSUM_EFF_P + _valuesSUM_EFF_N)); 
            else PERCENTAGE = 0.0;
            COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);
  
            float _valuesSUM = FLOAT_undefined;
            if (Impact_TYPE == Impact_ACTIVE) _valuesSUM = _valuesSUM_RAD;
            if (Impact_TYPE == Impact_PASSIVE) _valuesSUM = COMPARISON; 

            if (_valuesSUM < 0.9 * FLOAT_undefined) {
            
              
            }
            */
          }
        }
      }
    }
  }


  for (int a = 0; a <= int(180 / stp_slp); a += 1) { 
    float Alpha = a * stp_slp - 90;
    for (int b = 0; b < int(360 / stp_dir); b += 1) {
      float Beta = b * stp_dir;

      if (TOTAL_valuesNUM[a][b] != 0) {
        TOTAL_valuesSUM_RAD[a][b] /= 1.0 * TOTAL_valuesNUM[a][b];
        TOTAL_valuesSUM_EFF_P[a][b] /= 1.0 * TOTAL_valuesNUM[a][b];
        TOTAL_valuesSUM_EFF_N[a][b] /= 1.0 * TOTAL_valuesNUM[a][b];
      }
      else {
        TOTAL_valuesSUM_RAD[a][b] = FLOAT_undefined;
        TOTAL_valuesSUM_EFF_P[a][b] = FLOAT_undefined;
        TOTAL_valuesSUM_EFF_N[a][b] = FLOAT_undefined;
      }


      float AVERAGE, PERCENTAGE, COMPARISON;
      
      AVERAGE = (TOTAL_valuesSUM_EFF_P[a][b] - TOTAL_valuesSUM_EFF_N[a][b]);
      if ((TOTAL_valuesSUM_EFF_P[a][b] + TOTAL_valuesSUM_EFF_N[a][b]) > 0.00001) PERCENTAGE = (TOTAL_valuesSUM_EFF_P[a][b] - TOTAL_valuesSUM_EFF_N[a][b]) / (1.0 * (TOTAL_valuesSUM_EFF_P[a][b] + TOTAL_valuesSUM_EFF_N[a][b])); 
      else PERCENTAGE = 0.0;
      COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);


      float _valuesSUM = FLOAT_undefined;
      if (Impact_TYPE == Impact_ACTIVE) _valuesSUM = TOTAL_valuesSUM_RAD[a][b];
      if (Impact_TYPE == Impact_PASSIVE) _valuesSUM = COMPARISON; 

      if (_valuesSUM < 0.9 * FLOAT_undefined) {
        
        LocationExposure[a][b] = _valuesSUM;
      }
    }
  }

  pre_per_day = per_day;
  num_add_days = pre_num_add_days;
}


void SOLARCHVISION_draw_logo (float cx, float cy, float cz, float cr, int the_view) {
  
  float stp_u = 1.0 / 12.0;
  float stp_v = 1.0 / 12.0;
  
  int n_a = 1;
  
  for (float a = -1; a < 1; a += stp_u) {
    
    n_a *= -1;
    
    int n_b = n_a;
    
    for (float b = -1; b < 1; b += stp_v) {
      
      n_b *= -1;

      float[][] newQuad = {{0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}};
      
      for (int i = 0; i < 4; i++) {
        
        float u = a;
        float v = b;
        
        if ((i == 1) || (i == 2)) u += stp_u;
        if ((i == 2) || (i == 3)) v += stp_v;

        //---------------------------------------
        float x0 = cos(u * PI); 
        float y0 = sin(u * PI) * cos(v * PI);
        float z0 = sin(v * PI);
        
        float d = pow(x0*x0 + y0*y0 + z0*z0, 0.5);
        x0 /= d;  
        y0 /= d;  
        z0 /= d;  
        
        float x = x0;
        float y = y0;
        float z = z0;

        if (the_view == 0) { // corner view: logo
          float t = 0.25 * PI;
          newQuad[i][0] = x0 * cos(t) - z0 * sin(t);
          newQuad[i][1] = y0;   
          newQuad[i][2] = x0 * sin(t) + z0 * cos(t);
        }           
        else if (the_view == 1) { // front view
          newQuad[i][0] = x0;
          newQuad[i][1] = y0;   
          newQuad[i][2] = z0;
        }   
        else if (the_view == -1) { // top view
          newQuad[i][0] = x0;
          newQuad[i][1] = z0;   
          newQuad[i][2] = y0;
        }   

      }
      
      float x1 = cr * newQuad[0][0] + cx;
      float y1 = cr * newQuad[0][1] + cy;
      float z1 = cr * newQuad[0][2] + cz;

      float x2 = cr * newQuad[1][0] + cx;
      float y2 = cr * newQuad[1][1] + cy;
      float z2 = cr * newQuad[1][2] + cz;

      float x3 = cr * newQuad[2][0] + cx;
      float y3 = cr * newQuad[2][1] + cy;
      float z3 = cr * newQuad[2][2] + cz;

      float x4 = cr * newQuad[3][0] + cx;
      float y4 = cr * newQuad[3][1] + cy;
      float z4 = cr * newQuad[3][2] + cz;

      if (n_a * n_b == 1) {
        triangle(x1,y1, x2,y2, x3,y3);
        triangle(x3,y3, x4,y4, x1,y1);
      }
      else{
        triangle(x4,y4, x1,y1, x2,y2);
        triangle(x2,y2, x3,y3, x4,y4);
      }
      
    
    }
  }
}


void mouseClicked () {
  if (automated == 0) {
    X_clicked = mouseX;
    Y_clicked = mouseY;
    
    ROLLOUT_Update = 1;
    
    redraw();
  }
}
 
int isInside (float x, float y, float x1, float y1, float x2, float y2) {
  if ((x1 < x) && (x < x2) && (y1 < y) && (y < y2)) return 1;
  else return 0;
} 




class SOLARCHVISION_Spinner { 
  float x_Plot, y_Plot;
  float new_value;
  
  SOLARCHVISION_Spinner () {  
  }
  
  float update(float x, float y, String caption, float v, float min_v, float max_v, float stp_v) {
    x_Plot = x; 
    y_Plot = y;
    new_value = v;
    
    float cx, cy, cr;
    float w1, w2, h, o, t_o; 
    
    w1 = 32.5 * ROLLOUT_S_View;
    w2 = 142.5 * ROLLOUT_S_View;
    h = 16 * ROLLOUT_S_View;
    o = 2 * ROLLOUT_S_View;
    t_o = h * ROLLOUT_S_View / 8.0;
    
    Y_spinner += 25 * ROLLOUT_S_View; //(h + 2 * o) * 1.25;

    strokeWeight(0); 
    stroke(0); 
    fill(0);
    rect(x + o, y - (h / 2) - o, 0.5 * (h + 2 * o) , 0.5 * (h + 2 * o));
    rect(x + o, y - (h / 2) - o + 0.5 * (h + 2 * o), 0.5 * (h + 2 * o) , 0.5 * (h + 2 * o));
    stroke(255); 
    fill(255);
    cx = x + o + 0.25 * (h + 2 * o);
    cy = y - (h / 2) - o + 0.25 * (h + 2 * o);
    cr = 0.25 * (h + 2 * o);
    triangle(cx + cr * cos_ang(270), cy + 0.75 * cr * sin_ang(270), cx + 0.75 * cr * cos_ang(30), cy + 0.75 * cr * sin_ang(30), cx + 0.75 * cr * cos_ang(150), cy + 0.75 * cr * sin_ang(150));
    
    if (isInside(X_clicked, Y_clicked, cx - cr, cy - cr, cx + cr, cy + cr) == 1) {
      if (stp_v < 0) {
        new_value *= abs(stp_v); 
      }
      else { 
        new_value += abs(stp_v);
      }
      
      GRAPHS_Update = 1;
    }
    
    cy += 2 * cr;
    triangle(cx + cr * cos_ang(90), cy + 0.75 * cr * sin_ang(90), cx + 0.75 * cr * cos_ang(210), cy + 0.75 * cr * sin_ang(210), cx + 0.75 * cr * cos_ang(330), cy + 0.75 * cr * sin_ang(330));

    if (isInside(X_clicked, Y_clicked, cx - cr, cy - cr, cx + cr, cy + cr) == 1) {
      if (stp_v < 0) {
        new_value /= abs(stp_v); 
      }
      else { 
        new_value -= abs(stp_v);
      }
      
      GRAPHS_Update = 1;
    }

    if (new_value < min_v) new_value = max_v; 
    if (new_value > max_v) new_value = min_v; 
    

    strokeWeight(0); 
    stroke(191); 
    fill(191);
    rect(x - (w1 + w2) - o, y - (h / 2) - o, (w1 + w2) + 2 * o, h + 2 * o);

    strokeWeight(2); 
    stroke(0); 
    fill(255);
    rect(x - w1, y - (h / 2), w1, h);

    strokeWeight(0);
    stroke(0); 
    fill(0);
    textSize(1.0 * h);
    textAlign(RIGHT, CENTER);
    if ((new_value == int(new_value)) || (new_value >= 100)) {
      text(String.valueOf(int(new_value)), x - t_o, y - t_o);
    }
    else {
      text(nf(new_value, 0, 0), x - t_o, y - t_o);
    }

    
    strokeWeight(0);
    stroke(0); 
    fill(0);
    //textSize(1.0 * h);
    textSize(0.85 * h);
    //textAlign(RIGHT, CENTER); text(caption + ":", x - w1 - t_o, y - t_o);
    textAlign(LEFT, CENTER); text(caption + ":", x - w1 - w2 + t_o, y - t_o);


    return new_value;
  }
}

String[][] ROLLOUTS = {
                        {"Location", "1"}, 
                        {"Geometry", "1"}, 
                        {"Time", "1"}, 
                        {"Data", "1"}, 
                        {"Process", "1"}, 
                        {"Products", "1"},
                        {"Display", "1"}
                      };

int ROLLOUT_parent = 0; // 0: Location, 1: Geometry, 2: Time, etc.
int ROLLOUT_child = 1; // number of the category inside e.g. 1, 2, ...




void SOLARCHVISION_draw_ROLLOUT () {
  
  stroke(255); 
  fill(255);
  strokeWeight(0);
  rect(ROLLOUT_CX_View, ROLLOUT_CY_View, ROLLOUT_X_View, ROLLOUT_Y_View);
  

  float h = 20 * ROLLOUT_S_View;

  strokeWeight(0);
  stroke(0); 
  fill(0);
  textSize(20 * ROLLOUT_S_View);
  textAlign(LEFT, CENTER);
  if (ROLLOUT_parent < ROLLOUTS.length){
    text(ROLLOUTS[ROLLOUT_parent][0] + "//", ROLLOUT_CX_View + 10 * ROLLOUT_S_View, ROLLOUT_CY_View + 10 * ROLLOUT_S_View);
    
    if (ROLLOUT_child < ROLLOUTS[ROLLOUT_parent].length){
      text(nf(ROLLOUT_child, 0) + ": " + ROLLOUTS[ROLLOUT_parent][ROLLOUT_child] + "//", ROLLOUT_CX_View + 10 * ROLLOUT_S_View, ROLLOUT_CY_View + 35 * ROLLOUT_S_View);
    }
  }

  X_spinner = ROLLOUT_CX_View;
  Y_spinner = ROLLOUT_CY_View;
  
  X_spinner += 185 * ROLLOUT_S_View;
  Y_spinner += 65 * ROLLOUT_S_View;


  if (ROLLOUT_parent == 0) { // Location
    STATION_NUMBER = int(MySpinner.update(X_spinner, Y_spinner, "Station", STATION_NUMBER, 0, DEFINED_STATIONS.length, 1));
    
    LocationLatitude = MySpinner.update(X_spinner, Y_spinner, "Latitude", LocationLatitude, -90, 90, 0.1);
    LocationLongitude = MySpinner.update(X_spinner, Y_spinner, "Longitude", LocationLongitude, -180, 180, 0.1);
    LocationElevation = int(MySpinner.update(X_spinner, Y_spinner, "Elevation", LocationElevation, -100, 8000, 1.0));

    Load_CLIMATE_EPW = int(MySpinner.update(X_spinner, Y_spinner, "Load_CLIMATE_EPW" , Load_CLIMATE_EPW, 0, 1, 1));
    Load_CLIMATE_WY2 = int(MySpinner.update(X_spinner, Y_spinner, "Load_CLIMATE_WY2" , Load_CLIMATE_WY2, 0, 1, 1));
    Load_ENSEMBLE = int(MySpinner.update(X_spinner, Y_spinner, "Load_ENSEMBLE" , Load_ENSEMBLE, 0, 1, 1));
    Load_OBSERVED = int(MySpinner.update(X_spinner, Y_spinner, "Load_OBSERVED" , Load_OBSERVED, 0, 1, 1));
   
    Load_LAND = int(MySpinner.update(X_spinner, Y_spinner, "Load_LAND" , Load_LAND, 0, 1, 1));
    Display_LAND = int(MySpinner.update(X_spinner, Y_spinner, "Display_LAND" , Display_LAND, 0, 1, 1));
    Skip_LAND_Center = int(MySpinner.update(X_spinner, Y_spinner, "Skip_LAND_Center" , Skip_LAND_Center, 0, LAND_n_I - 1, 1));     
    
    Load_URBAN = int(MySpinner.update(X_spinner, Y_spinner, "Load_URBAN" , Load_URBAN, 0, 1, 1));
                
   
  }
  else if (ROLLOUT_parent == 1) { // Geometry
    
  }
  else if (ROLLOUT_parent == 2) { // Time
    
    j_end = int(MySpinner.update(X_spinner, Y_spinner, "No. of days to plot" , j_end, 1, 61, 1));
  
    BEGIN_DAY = int(MySpinner.update(X_spinner, Y_spinner, "Plot start date" , BEGIN_DAY, 0, 364, 1));
  
    //_DATE = MySpinner.update(X_spinner, Y_spinner, "Solar date", _DATE, 0, 364.5, 0.5);
    _DATE = MySpinner.update(X_spinner, Y_spinner, "Solar date", _DATE, 0, 364, 1);
    
    _DAY = int(MySpinner.update(X_spinner, Y_spinner, "Forecast day" , _DAY, 1, 31, 1));
    _MONTH = int(MySpinner.update(X_spinner, Y_spinner, "Forecast month", _MONTH, 1, 12, 1));
    _YEAR = int(MySpinner.update(X_spinner, Y_spinner, "Forecast year" , _YEAR, 1953, 2100, 1));    
  }  
  else if (ROLLOUT_parent == 3) { // Process
  
    drw_Layer = int(MySpinner.update(X_spinner, Y_spinner, "Layer", drw_Layer, 0, (num_layers - 1), 1));
    GRAPHS_V_scale[drw_Layer] = MySpinner.update(X_spinner, Y_spinner, "V_scale[" + nf(drw_Layer, 2) + "]", GRAPHS_V_scale[drw_Layer], 0.0001, 10000, -pow(2.0, (1.0 / 2.0)));
    GRAPHS_O_scale = MySpinner.update(X_spinner, Y_spinner, "O_scale", GRAPHS_O_scale, 1, 100, -pow(2.0, (1.0 / 4.0)));
  
    draw_data_lines = int(MySpinner.update(X_spinner, Y_spinner, "Draw data", draw_data_lines, 0, 1, 1));
    draw_sorted = int(MySpinner.update(X_spinner, Y_spinner, "Draw sorted", draw_sorted, 0, 1, 1));
    draw_normals = int(MySpinner.update(X_spinner, Y_spinner, "Draw statistics", draw_normals, 0, 1, 1));
    draw_probs = int(MySpinner.update(X_spinner, Y_spinner, "Draw probabilities", draw_probs, 0, 1, 1));
    sum_interval = int(MySpinner.update(X_spinner, Y_spinner, "Probabilities interval", sum_interval, 1, 24, 1));
    level_pix = int(MySpinner.update(X_spinner, Y_spinner, "Probabilities range", level_pix, 2, 32, -2));
  
    sky_scenario = int(MySpinner.update(X_spinner, Y_spinner, "Sky status", sky_scenario, 1, 4, 1));
    filter_type = int(MySpinner.update(X_spinner, Y_spinner, "Hourly/daily filter", filter_type, 0, 1, 1));
  
    F_layer_option = int(MySpinner.update(X_spinner, Y_spinner, "Forecast filter option" , F_layer_option, 0, 4, 1));
    Sample_Member = int(MySpinner.update(X_spinner, Y_spinner, "Single member" , Sample_Member, 1, 43, 1));  
  
    H_layer_option = int(MySpinner.update(X_spinner, Y_spinner, "Climate filter option" , H_layer_option, 0, 7, 1));
    Sample_Year = int(MySpinner.update(X_spinner, Y_spinner, "Single year" , Sample_Year, 1953, 2005, 1));
  
    Climatic_solar_model = int(MySpinner.update(X_spinner, Y_spinner, "Climatic solar model", Climatic_solar_model, 0, 1, 1));
    Climatic_weather_model = int(MySpinner.update(X_spinner, Y_spinner, "Climatic weather model", Climatic_weather_model, 0, 2, 1));    
  
    //GRAPHS_setup = int(MySpinner.update(X_spinner, Y_spinner, "Diagram setup", GRAPHS_setup, -2, 13, 1));
    GRAPHS_setup = int(MySpinner.update(X_spinner, Y_spinner, "Diagram setup", GRAPHS_setup, 100, 110, 1));
    GRAPHS_Update = int(MySpinner.update(X_spinner, Y_spinner, "Redraw scene", GRAPHS_Update, 0, 1, 1));
      
    impacts_source = int(MySpinner.update(X_spinner, Y_spinner, "Draw climate/forecast/obs.", impacts_source, 0, 3, 1));
    impact_layer = int(MySpinner.update(X_spinner, Y_spinner, "Impact Min/50%/Max", impact_layer, 0, 8, 1));
    
    update_impacts = int(MySpinner.update(X_spinner, Y_spinner, "Update impacts", update_impacts, 0, 1, 1));
  
  
    develop_option = int(MySpinner.update(X_spinner, Y_spinner, "Develop layer" , develop_option, 0, 12, 1));
    develop_per_day = int(MySpinner.update(X_spinner, Y_spinner, "Dev. per day option" , develop_per_day, 0, 3, 1));
  
    join_hour_numbers = int(MySpinner.update(X_spinner, Y_spinner, "Trend period hours", join_hour_numbers, 1, 24 * 16, 1));
    join_type = int(MySpinner.update(X_spinner, Y_spinner, "Weighted/equal trend", join_type, -1, 1, 2));
  
    Angle_inclination = int(MySpinner.update(X_spinner, Y_spinner, "Inclination angle", Angle_inclination, 0, 90, 5));
    Angle_orientation = int(MySpinner.update(X_spinner, Y_spinner, "Orientation angle", Angle_orientation, 0, 360, 15));    
  }  
  else if (ROLLOUT_parent == 4) { // Product
  
  
  
    GRAPHS_record_PDF = int(MySpinner.update(X_spinner, Y_spinner, "Record PDF", GRAPHS_record_PDF, 0, 1, 1));
    GRAPHS_record_JPG = int(MySpinner.update(X_spinner, Y_spinner, "Record JPG", GRAPHS_record_JPG, 0, 1, 1));
  
    save_info_node = int(MySpinner.update(X_spinner, Y_spinner, "Create data-Ascii", save_info_node, 0, 1, 1));
    save_info_norm = int(MySpinner.update(X_spinner, Y_spinner, "Create stat-Ascii", save_info_norm, 0, 1, 1));
    save_info_prob = int(MySpinner.update(X_spinner, Y_spinner, "Create prob-Ascii", save_info_prob, 0, 1, 1));  
    
  }    
  else if (ROLLOUT_parent == 5) { // Display
    Pallet_ACTIVE = int(MySpinner.update(X_spinner, Y_spinner, "Active pallet option", Pallet_ACTIVE, -1, 14, 1));
    Pallet_ACTIVE_DIR = int(MySpinner.update(X_spinner, Y_spinner, "Active pallet direction", Pallet_ACTIVE_DIR, -2, 2, 1));
    
    Pallet_PASSIVE = int(MySpinner.update(X_spinner, Y_spinner, "Passive pallet option", Pallet_PASSIVE, -1, 14, 1));
    Pallet_PASSIVE_DIR = int(MySpinner.update(X_spinner, Y_spinner, "Passive pallet direction", Pallet_PASSIVE_DIR, -1, 1, 2));
  
    COLOR_STYLE = int(MySpinner.update(X_spinner, Y_spinner, "Color scheme", COLOR_STYLE, 0, (n_COLOR_STYLE - 1), 1));  
  
  }
  else {

  } 





  
  X_clicked = 0;
  Y_clicked = 0;
}


SOLARCHVISION_Spinner MySpinner = new SOLARCHVISION_Spinner(); 
