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

int Impact_TYPE = Impact_PASSIVE;

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
  "", "All data", "Cloudy\nPattern", "Partly Cloudy\nPattern", "Sunny\nPattern"
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
  0.01,
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

float LocationLAT_step = 0.01;
float LocationLON_step = 0.01;
float LocationELE_step = 1.0;

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
        if (pre_ENSEMBLE_OBSERVED_load != ENSEMBLE_OBSERVED_load) SOLARCHVISION_update_ENSEMBLE_OBSERVED();
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

int[] STAT_reverse_N;
{
  STAT_reverse_N = new int [9];
  STAT_reverse_N[STAT_N_MidLow] = STAT_N_MidHigh;
  STAT_reverse_N[STAT_N_Middle] = STAT_N_Middle;
  STAT_reverse_N[STAT_N_MidHigh] = STAT_N_MidLow;
  STAT_reverse_N[STAT_N_M25] = STAT_N_M75;
  STAT_reverse_N[STAT_N_M50] = STAT_N_M50;
  STAT_reverse_N[STAT_N_M75] = STAT_N_M25;
  STAT_reverse_N[STAT_N_Min] = STAT_N_Max;
  STAT_reverse_N[STAT_N_Ave] = STAT_N_Ave;
  STAT_reverse_N[STAT_N_Max] = STAT_N_Min;
}

float[] SOLARCHVISION_NORMAL (float[] _values) {

  float[] weight_array = {
    0, 0, 0, 0, 0, 0, 0, 0, 0
  };
  float[] return_array = {
    0, 0, 0, 0, 0, 0, 0, 0, 0
  };

  int NV = 0; // the number of values without counting undefined values
  float _weight = 0;

  _values = sort(_values);
  for (int i = 0; i < _values.length; i++) {
    if (is_defined(_values[i])) NV += 1;
  }

  if (NV > 0) {
    for (int i = 0; i < NV; i++) {
      if (is_defined(_values[i])) {
        _weight = 1;
        weight_array[STAT_N_Ave] += _weight;
        return_array[STAT_N_Ave] += _values[i];

        _weight = (0.5 * (NV + 1)) - abs((0.5 * (NV + 1)) - (i + 1));
        weight_array[STAT_N_Middle] += _weight;
        return_array[STAT_N_Middle] += _values[i] * _weight;

        _weight = (i + 1);
        weight_array[STAT_N_MidHigh] += _weight;
        return_array[STAT_N_MidHigh] += _values[i] * _weight;

        _weight = (NV + 1 - i);
        weight_array[STAT_N_MidLow] += _weight;
        return_array[STAT_N_MidLow] += _values[i] * _weight;
      }
    }

    return_array[STAT_N_Ave] /= weight_array[STAT_N_Ave];
    return_array[STAT_N_Middle] /= weight_array[STAT_N_Middle];
    return_array[STAT_N_MidHigh] /= weight_array[STAT_N_MidHigh];
    return_array[STAT_N_MidLow] /= weight_array[STAT_N_MidLow];

    return_array[STAT_N_Max] = _values[(NV - 1)];
    return_array[STAT_N_Min] = _values[0];

    if ((NV % 2) == 1) {

      return_array[STAT_N_M50] = _values[(floor(NV / 2))];
    } else {

      return_array[STAT_N_M50] = 0.5 * (_values[(floor(NV / 2))] + _values[(floor(NV / 2) - 1)]);
    }

    int q;

    q = int(funcs.roundTo((NV * 0.75), 1));
    if (q > NV - 1) q = NV - 1;
    return_array[STAT_N_M75] = _values[q];

    q = int(funcs.roundTo((NV * 0.25), 1));
    if (q < 0) q = 0;
    return_array[STAT_N_M25] = _values[q];
  } else {
    for (int i = 0; i < return_array.length; i++) {
      return_array[i] = FLOAT_undefined;
    }
  }

  return return_array;
}



int SOLARCHVISION_filter (int dataID, int cloudCover_id, int type_of_filter, int scenario_of_sky, int now_i, int now_j, int now_k) {

  float total_sky = 0;
  int num_sky = 0;

  int start_q = now_i;
  int end_q = now_i;

  if (type_of_filter == filter_DAILY) {
    start_q = 0;
    end_q = 23;
  }

  for (int q = start_q; q <= end_q; q++) {
    float _sky = FLOAT_undefined;
    if (dataID == dataID_ENSEMBLE_OBSERVED)      _sky = ENSEMBLE_OBSERVED_values[q][now_j][cloudCover_id][now_k];
    else if (dataID == dataID_ENSEMBLE_FORECAST) _sky = ENSEMBLE_FORECAST_values[q][now_j][cloudCover_id][now_k];
    else if (dataID == dataID_CLIMATE_CWEEDS)    _sky = CLIMATE_CWEEDS_values   [q][now_j][cloudCover_id][now_k];
    else if (dataID == dataID_CLIMATE_CLMREC)    _sky = CLIMATE_CLMREC_values   [q][now_j][cloudCover_id][now_k];
    else if (dataID == dataID_CLIMATE_TMYEPW)    _sky = CLIMATE_TMYEPW_values   [q][now_j][cloudCover_id][now_k];
    else {
      println("ERROR: This dataID is not declared:", dataID);
    }

    if (is_undefined(_sky)) {
    } else {
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

  int[] return_array = new int [9];

  for (int l = 0; l < 9; l++) {
    return_array[l] = -1;
    if (is_defined(_normals[l])) {

      float _dist = FLOAT_undefined;

      for (int i = 0; i < _values.length; i++) {
        if (_dist > abs(_normals[l] - _values[i])) {
          _dist = abs(_normals[l] - _values[i]);
          return_array[l] = i;
        }
      }
    } else return_array[l] = -1;
  }

  return return_array;
}


int[] SOLARCHVISION_PROCESS_DAILY_SCENARIOS (int start_k, int end_k, int j, float DATE_ANGLE) {

  int count_k = 1 + end_k - start_k;
  if (count_k < 0) count_k = 0;

  float Pa = FLOAT_undefined;
  float Pb = FLOAT_undefined;
  float Pc = FLOAT_undefined;
  float Pd = FLOAT_undefined;

  float values_R_dir;
  float values_R_dif;
  float values_E_dir;
  float values_E_dif;

  float[] valuesSUM_RAD;
  float[] valuesSUM_EFF;
  float[] valuesNUM;
  valuesSUM_RAD = new float [(count_k * STUDY.joinDays)];
  valuesSUM_EFF = new float [(count_k * STUDY.joinDays)];
  valuesNUM = new float [(count_k * STUDY.joinDays)];

  for (int j_ADD = 0; j_ADD < STUDY.joinDays; j_ADD++) {
    for (int k = 0; k < count_k; k++) {
      valuesSUM_RAD[(k * STUDY.joinDays + j_ADD)] = FLOAT_undefined;
      valuesSUM_EFF[(k * STUDY.joinDays + j_ADD)] = FLOAT_undefined;
      valuesNUM[(k * STUDY.joinDays + j_ADD)] = 0;
    }
  }

  for (int j_ADD = 0; j_ADD < STUDY.joinDays; j_ADD++) {

    for (int k = 0; k < count_k; k++) {

      for (int i = 0; i < 24; i++) {

        float HOUR_ANGLE = i;
        float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);

        int now_k = k + start_k;
        int now_i = i;
        int now_j = int(j * STUDY.perDays + (j_ADD - int(funcs.roundTo(0.5 * STUDY.joinDays, 1))) + TIME.beginDay + 365) % 365;

        if (now_j >= 365) {
          now_j = now_j % 365;
        }
        if (now_j < 0) {
          now_j = (now_j + 365) % 365;
        }

        Pa = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_dirnorrad.id);
        Pb = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_difhorrad.id);
        Pc = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_direffect.id);
        Pd = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_difeffect.id);

        if (is_undefined(Pa) || is_undefined(Pb) || is_undefined(Pc) || is_undefined(Pd)) {
        } else {

          int memberCount = SOLARCHVISION_filter(CurrentDataSource, LAYER_cloudcover.id, STUDY.filter, STUDY.skyScenario, now_i, now_j, now_k);

          if (memberCount == 1) {
            values_R_dir = 0.001 * Pa;
            values_R_dif = 0.001 * Pb;
            values_E_dir = 0.0001 * Pc;
            values_E_dif = 0; //0.0001 * Pd;

            if (is_undefined(valuesSUM_RAD[(k * STUDY.joinDays + j_ADD)])) {
              valuesSUM_RAD[(k * STUDY.joinDays + j_ADD)] = 0;
              valuesSUM_EFF[(k * STUDY.joinDays + j_ADD)] = 0;
              valuesNUM[(k * STUDY.joinDays + j_ADD)] = 0;
            }

            valuesSUM_RAD[(k * STUDY.joinDays + j_ADD)] += ((values_R_dir * SunR[3]) + (values_R_dif)); // calculates total horizontal radiation
            valuesSUM_EFF[(k * STUDY.joinDays + j_ADD)] += ((values_E_dir * SunR[3]) + (values_E_dif)); // calculates total horizontal effects
            valuesNUM[(k * STUDY.joinDays + j_ADD)] += 1;
          }
        }
      }
    }
  }

  if (Impact_TYPE == Impact_PASSIVE)
    return SOLARCHVISION_FIND_SCENARIOS_CLOSE_TO_NORMALS(valuesSUM_EFF);
  else
    return SOLARCHVISION_FIND_SCENARIOS_CLOSE_TO_NORMALS(valuesSUM_RAD);
}

























int FrameVariation = 0;

void SOLARCHVISION_update_frame_layout () {

  if (FrameVariation == 0) {

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
  } else if (FrameVariation == 1) {

    STUDY.include = false;
    WIN3D.include = true;
    WORLD.include = false;

    WIN3D.cX = 0;
    WIN3D.cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 0;
    WIN3D.dX = 2 * SOLARCHVISION_pixel_W;
    WIN3D.dY = 2 * SOLARCHVISION_pixel_H;
    WIN3D.view_R = float(WIN3D.dY) / float(WIN3D.dX);
    WIN3D.graphics = createGraphics(WIN3D.dX, WIN3D.dY, P3D);
  } else if (FrameVariation == 2) {

    STUDY.include = true;
    WIN3D.include = false;
    WORLD.include = false;

    STUDY.cX = 0;
    STUDY.cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 0;
    STUDY.dX = 2 * SOLARCHVISION_pixel_W;
    STUDY.dY = 2 * SOLARCHVISION_pixel_H;
    STUDY.view_R = float(STUDY.dY) / float(STUDY.dX);
    STUDY.graphics = createGraphics(STUDY.dX, STUDY.dY, P2D);
  } else if (FrameVariation == 3) {

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

        }
      }

      if ((STUDY.update) || (WORLD.update) || (WIN3D.update) || (ROLLOUT.update)) redraw();
    }
  }
}

void keyReleased () {

  addNewSelectionToPreviousSelection = 0;
}








































PrintWriter htmlOutput;

void SOLARCHVISION_export_objects_HTML () {

  String fileBasename = ProjectName;

  String htmlFilename = Folder_Export3D + "/" + fileBasename + ".html";

  htmlOutput = createWriter(htmlFilename);

  htmlOutput.println("<html>");
  htmlOutput.println("\t<head>");
  htmlOutput.println("\t\t<title>" + ProjectName + "</title>");
  htmlOutput.println("\t\t<script type='text/javascript' src='https://www.x3dom.org/download/x3dom.js'></script>");
  htmlOutput.println("\t\t<link rel='stylesheet' type='text/css' href='https://www.x3dom.org/download/x3dom.css'></link>");
  htmlOutput.println("\t</head>");
  htmlOutput.println("\t<body>");
  htmlOutput.println("\t\t<x3d width='900px' height='600px'>");
  htmlOutput.println("\t\t\t<scene>");

  htmlOutput.println("\t\t\t\t<viewpoint position='0 0 100'></Viewpoint>");
/*
{
  htmlOutput.print  ("\t\t\t\t<viewpoint id='CAM00'");
  htmlOutput.print  (" position='" + nf(WIN3D.CAM_x, 0, 0) + " " + nf(WIN3D.CAM_y, 0, 0) + " " + nf(WIN3D.CAM_z, 0, 0) + "'");

  float c1 = funcs.cos_ang(WIN3D.rotation_X * 0.5);
  float s1 = funcs.sin_ang(WIN3D.rotation_X * 0.5);
  float c2 = funcs.cos_ang(WIN3D.rotation_Y * 0.5);
  float s2 = funcs.sin_ang(WIN3D.rotation_Y * 0.5);
  float c3 = funcs.cos_ang(WIN3D.rotation_Z * 0.5);
  float s3 = funcs.sin_ang(WIN3D.rotation_Z * 0.5);

  float qw = c1*c2*c3 + s1*s2*s3;
  float qx = s1*s2*c3 - c1*c2*s3;
  float qy = s1*c2*c3 + c1*s2*s3;
  float qz = c1*s2*c3 - s1*c2*s3;

  htmlOutput.print  (" orientation='" + nf(qw, 0, 0) + " " + nf(qx, 0, 0) + " " + nf(qy, 0, 0) + " " + nf(qz, 0, 0) + "'");
  htmlOutput.println("></Viewpoint>");
}


{
  htmlOutput.print  ("\t\t\t\t<viewpoint id='CAM01'");
  htmlOutput.print  (" position='" + nf(WIN3D.CAM_x, 0, 0) + " " + nf(WIN3D.CAM_y, 0, 0) + " " + nf(WIN3D.CAM_z, 0, 0) + "'");

  float c1 = funcs.cos_ang(WIN3D.rotation_Y * 0.5);
  float s1 = funcs.sin_ang(WIN3D.rotation_Y * 0.5);
  float c2 = funcs.cos_ang(WIN3D.rotation_Z * 0.5);
  float s2 = funcs.sin_ang(WIN3D.rotation_Z * 0.5);
  float c3 = funcs.cos_ang(WIN3D.rotation_X * 0.5);
  float s3 = funcs.sin_ang(WIN3D.rotation_X * 0.5);

  float qw = c1*c2*c3 + s1*s2*s3;
  float qx = s1*s2*c3 - c1*c2*s3;
  float qy = s1*c2*c3 + c1*s2*s3;
  float qz = c1*s2*c3 - s1*c2*s3;

  htmlOutput.print  (" orientation='" + nf(qw, 0, 0) + " " + nf(qx, 0, 0) + " " + nf(qy, 0, 0) + " " + nf(qz, 0, 0) + "'");
  htmlOutput.println("></Viewpoint>");
}

{
  htmlOutput.print  ("\t\t\t\t<viewpoint id='CAM02'");
  htmlOutput.print  (" position='" + nf(WIN3D.CAM_x, 0, 0) + " " + nf(WIN3D.CAM_y, 0, 0) + " " + nf(WIN3D.CAM_z, 0, 0) + "'");

  float c1 = funcs.cos_ang(WIN3D.rotation_Z * 0.5);
  float s1 = funcs.sin_ang(WIN3D.rotation_Z * 0.5);
  float c2 = funcs.cos_ang(WIN3D.rotation_X * 0.5);
  float s2 = funcs.sin_ang(WIN3D.rotation_X * 0.5);
  float c3 = funcs.cos_ang(WIN3D.rotation_Y * 0.5);
  float s3 = funcs.sin_ang(WIN3D.rotation_Y * 0.5);

  float qw = c1*c2*c3 + s1*s2*s3;
  float qx = s1*s2*c3 - c1*c2*s3;
  float qy = s1*c2*c3 + c1*s2*s3;
  float qz = c1*s2*c3 - s1*c2*s3;

  htmlOutput.print  (" orientation='" + nf(qw, 0, 0) + " " + nf(qx, 0, 0) + " " + nf(qy, 0, 0) + " " + nf(qz, 0, 0) + "'");
  htmlOutput.println("></Viewpoint>");
}


{
  htmlOutput.print  ("\t\t\t\t<viewpoint id='CAM03'");
  htmlOutput.print  (" position='" + nf(WIN3D.CAM_x, 0, 0) + " " + nf(WIN3D.CAM_y, 0, 0) + " " + nf(WIN3D.CAM_z, 0, 0) + "'");

  float c1 = funcs.cos_ang(WIN3D.rotation_Z * 0.5);
  float s1 = funcs.sin_ang(WIN3D.rotation_Z * 0.5);
  float c2 = funcs.cos_ang(WIN3D.rotation_Y * 0.5);
  float s2 = funcs.sin_ang(WIN3D.rotation_Y * 0.5);
  float c3 = funcs.cos_ang(WIN3D.rotation_X * 0.5);
  float s3 = funcs.sin_ang(WIN3D.rotation_X * 0.5);

  float qw = c1*c2*c3 + s1*s2*s3;
  float qx = s1*s2*c3 - c1*c2*s3;
  float qy = s1*c2*c3 + c1*s2*s3;
  float qz = c1*s2*c3 - s1*c2*s3;

  htmlOutput.print  (" orientation='" + nf(qw, 0, 0) + " " + nf(qx, 0, 0) + " " + nf(qy, 0, 0) + " " + nf(qz, 0, 0) + "'");
  htmlOutput.println("></Viewpoint>");
}


{
  htmlOutput.print  ("\t\t\t\t<viewpoint id='CAM04'");
  htmlOutput.print  (" position='" + nf(WIN3D.CAM_x, 0, 0) + " " + nf(WIN3D.CAM_y, 0, 0) + " " + nf(WIN3D.CAM_z, 0, 0) + "'");

  float c1 = funcs.cos_ang(WIN3D.rotation_X * 0.5);
  float s1 = funcs.sin_ang(WIN3D.rotation_X * 0.5);
  float c2 = funcs.cos_ang(WIN3D.rotation_Z * 0.5);
  float s2 = funcs.sin_ang(WIN3D.rotation_Z * 0.5);
  float c3 = funcs.cos_ang(WIN3D.rotation_Y * 0.5);
  float s3 = funcs.sin_ang(WIN3D.rotation_Y * 0.5);

  float qw = c1*c2*c3 + s1*s2*s3;
  float qx = s1*s2*c3 - c1*c2*s3;
  float qy = s1*c2*c3 + c1*s2*s3;
  float qz = c1*s2*c3 - s1*c2*s3;

  htmlOutput.print  (" orientation='" + nf(qw, 0, 0) + " " + nf(qx, 0, 0) + " " + nf(qy, 0, 0) + " " + nf(qz, 0, 0) + "'");
  htmlOutput.println("></Viewpoint>");
}

{
  htmlOutput.print  ("\t\t\t\t<viewpoint id='CAM05'");
  htmlOutput.print  (" position='" + nf(WIN3D.CAM_x, 0, 0) + " " + nf(WIN3D.CAM_y, 0, 0) + " " + nf(WIN3D.CAM_z, 0, 0) + "'");

  float c1 = funcs.cos_ang(WIN3D.rotation_Y * 0.5);
  float s1 = funcs.sin_ang(WIN3D.rotation_Y * 0.5);
  float c2 = funcs.cos_ang(WIN3D.rotation_X * 0.5);
  float s2 = funcs.sin_ang(WIN3D.rotation_X * 0.5);
  float c3 = funcs.cos_ang(WIN3D.rotation_Z * 0.5);
  float s3 = funcs.sin_ang(WIN3D.rotation_Z * 0.5);

  float qw = c1*c2*c3 + s1*s2*s3;
  float qx = s1*s2*c3 - c1*c2*s3;
  float qy = s1*c2*c3 + c1*s2*s3;
  float qz = c1*s2*c3 - s1*c2*s3;

  htmlOutput.print  (" orientation='" + nf(qw, 0, 0) + " " + nf(qx, 0, 0) + " " + nf(qy, 0, 0) + " " + nf(qz, 0, 0) + "'");
  htmlOutput.println("></Viewpoint>");
}
*/


  Earth3D.draw(TypeWindow.HTML);

  Land3D.draw(TypeWindow.HTML);

  Tropo3D.draw(TypeWindow.HTML);

  allSections.draw(TypeWindow.HTML);

  allModel2Ds.draw(TypeWindow.HTML);

  allFaces.draw(TypeWindow.HTML);





  htmlOutput.println("\t\t\t</scene>");
  htmlOutput.println("\t\t</x3d>");

/*
  htmlOutput.println("\t\t<div id='camera_buttons' style='display: block;'>");
  htmlOutput.println("\t\t\t<button  onclick=\"document.getElementById('CAM00').setAttribute('set_bind","true');\" style='border: none; background: transparent; display: block'>CAM00<br><img src='camera.png'></button>");
  htmlOutput.println("\t\t\t<button  onclick=\"document.getElementById('CAM01').setAttribute('set_bind","true');\" style='border: none; background: transparent; display: block'>CAM01<br><img src='camera.png'></button>");
  htmlOutput.println("\t\t\t<button  onclick=\"document.getElementById('CAM02').setAttribute('set_bind","true');\" style='border: none; background: transparent; display: block'>CAM02<br><img src='camera.png'></button>");
  htmlOutput.println("\t\t\t<button  onclick=\"document.getElementById('CAM03').setAttribute('set_bind","true');\" style='border: none; background: transparent; display: block'>CAM03<br><img src='camera.png'></button>");
  htmlOutput.println("\t\t\t<button  onclick=\"document.getElementById('CAM04').setAttribute('set_bind","true');\" style='border: none; background: transparent; display: block'>CAM04<br><img src='camera.png'></button>");
  htmlOutput.println("\t\t\t<button  onclick=\"document.getElementById('CAM05').setAttribute('set_bind","true');\" style='border: none; background: transparent; display: block'>CAM05<br><img src='camera.png'></button>");
  htmlOutput.println("\t\t</div>");
*/

  htmlOutput.println("\t</body>");
  htmlOutput.println("</html>");

  htmlOutput.flush();
  htmlOutput.close();

  println("End of creating html file.");

  println("File created:" + htmlFilename);

}



void SOLARCHVISION_export_objects_OBJ_timeSeries () {

  int keep_STUDY_i_Start = STUDY.i_Start;

  for (int i = 0; i < 24; i++) {

    STUDY.i_Start = i;

    SOLARCHVISION_find_which_bakings_to_regenerate();
    SOLARCHVISION_regenerate_desired_bakings();


    SOLARCHVISION_export_objects_OBJ("_" + nf(i, 2));

  }

  STUDY.i_Start = keep_STUDY_i_Start;
}



void SOLARCHVISION_export_objects_OBJ_dateSeries () {

  int keep_IMPACTS_displayDay = IMPACTS_displayDay;

  for (int j = STUDY.j_Start; j <= STUDY.j_End; j++) {

    IMPACTS_displayDay = j;

    SOLARCHVISION_export_objects_OBJ("_" + nf(j, 3));

  }

  IMPACTS_displayDay = keep_IMPACTS_displayDay;
}




PrintWriter mtlOutput;
PrintWriter objOutput;


int obj_lastVertexNumber;
int obj_lastVtextureNumber;
int obj_lastFaceNumber;
int obj_lastGroupNumber;



int num_vertices_added = 0;

void SOLARCHVISION_export_objects_OBJ (String suffix) {

  String fileBasename = ProjectName + suffix;

  String objFilename = Folder_Export3D + "/" + fileBasename + ".obj";
  String mtlFilename = Folder_Export3D + "/" + fileBasename + ".mtl";


  if (User3D.export_MaterialLibrary) {
    mtlOutput = createWriter(mtlFilename);
    mtlOutput.println("#SOLARCHVISION");
  }

  objOutput = createWriter(objFilename);
  objOutput.println("#SOLARCHVISION");
  if (User3D.export_MaterialLibrary) {
    objOutput.println("mtllib " + fileBasename + ".mtl");
  }

  obj_lastVertexNumber = 0;
  obj_lastVtextureNumber = 0;
  obj_lastFaceNumber = 0;
  obj_lastGroupNumber = 0;






  Earth3D.draw(TypeWindow.OBJ3D);

  Land3D.draw(TypeWindow.OBJ3D);

  Tropo3D.draw(TypeWindow.OBJ3D);

  allSections.draw(TypeWindow.OBJ3D);

  allModel1Ds.draw(TypeWindow.OBJ3D);

  allModel2Ds.draw(TypeWindow.OBJ3D);

  allFaces.draw(TypeWindow.OBJ3D);

  allWindFlows.draw(TypeWindow.OBJ3D);

  Sky3D.draw(TypeWindow.OBJ3D);

  if (Sun3D.displayPattern) {

    float keep_STUDY_perDays = STUDY.perDays;
    int keep_STUDY_joinDays = STUDY.joinDays;
    if ((CurrentDataSource == dataID_ENSEMBLE_FORECAST) ||
        (CurrentDataSource == dataID_ENSEMBLE_OBSERVED)) {
      STUDY.perDays = 1;
      STUDY.joinDays = 1;
    }

    float previous_DATE = TIME.date;

    Sun3D.drawCycles(TypeWindow.STUDY, 0, 0, 0, 0.975 * Sky3D.scale);

    STUDY.perDays = keep_STUDY_perDays;
    STUDY.joinDays = keep_STUDY_joinDays;
    TIME.date = previous_DATE;
    TIME.updateDate();
  }

  if (User3D.export_MaterialLibrary) {
    mtlOutput.flush();
    mtlOutput.close();
  }

  objOutput.flush();
  objOutput.close();


  println("End of exporting the mesh.");

  println("File created:" + objFilename);
}

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

void SOLARCHVISION_import_objects_OBJ (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {

  if (m == -1) current_Material = 0;
  else current_Material = m;

  int[] importVerticeNumber = {
    0
  };

  String[] FileALL = loadStrings(FileName);

  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  String lineSTR;
  String[] input;

  //println("lines = ", FileALL.length);

  float Progress = 0;

  for (int f = 0; f < FileALL.length; f++) {

    if (1 + Progress < 100 * f / float(FileALL.length)) {
      Progress = 100 * f / float(FileALL.length);
      //println("Progress:", int(Progress), "%");
    }

    lineSTR = FileALL[f];
    //println(lineSTR);

    lineSTR = lineSTR.replace("  ", " ");

    String[] parts = split(lineSTR, ' ');

    if (parts[0].toLowerCase().equals("g")) {
      if (m == -1) current_Material = 1 + (current_Material % 8);

      if (addToLastGroup == false) allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    if (parts[0].toLowerCase().equals("v")) {

      float x = cx + sx * float(parts[1]);
      float y = cy + sy * float(parts[2]);
      float z = cz + sz * float(parts[3]);

      int[] v = {
        allPoints.create(x, y, z)
      };

      importVerticeNumber = concat(importVerticeNumber, v);
    }

    if (parts[0].toLowerCase().equals("f")) {

      //println(parts);

      int FaceDegree = parts.length - 1; // if we don't have space at the end of the line.

      if (parts[FaceDegree].equals("")) {  // if we have 1 space at the end of the line.
        FaceDegree -= 1;
      }

      int[] newFace = new int [FaceDegree];

      for (int n = 0; n < newFace.length; n++) {

        String[] the_numbers = split(parts[n + 1], '/');

        int vertexNumber = int(the_numbers[0]);

        if (vertexNumber > 0) {
          newFace[n] = importVerticeNumber[vertexNumber];
        } else if (vertexNumber < 0) { // for negative numbering
          newFace[n] = allPoints.getLength() - abs(vertexNumber);
        } else { // case 0
        }
      }

      //println(newFace);

      allFaces.create(newFace);
    }
  }

  println("Progress: 100 %");
}






float SOLARCHVISION_import_objects_asParametricBox_OBJ (String FileName, int m, float cx, float cy, float cz, float sx, float sy, float sz) {

  float[][] importVertices = {
    {
    }
  };

  String[] FileALL = loadStrings(FileName);

  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  String lineSTR;
  String[] input;

  //println("lines = ", FileALL.length);

  for (int f = 0; f < FileALL.length; f++) {

    lineSTR = FileALL[f];
    //println(lineSTR);

    lineSTR = lineSTR.replace("  ", " ");

    String[] parts = split(lineSTR, ' ');

    if (parts[0].toLowerCase().equals("v")) {

      float x = cx + sx * float(parts[1]);
      float y = cy + sy * float(parts[2]);
      float z = cz + sz * float(parts[3]);

      float[][] v = {
        {
          x, y, z
        }
      };

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

  float T_out = funcs.atan2_ang(Y_out, X_out);

  X_out = 0;
  Y_out = 0;
  Z_out = 0;

  for (int vNo = 1; vNo < importVertices.length; vNo++) {
    float x = (importVertices[vNo][0] - cen_X) * funcs.cos_ang(-T_out) - (importVertices[vNo][1] - cen_Y) * funcs.sin_ang(-T_out);
    float y = (importVertices[vNo][0] - cen_X) * funcs.sin_ang(-T_out) + (importVertices[vNo][1] - cen_Y) * funcs.cos_ang(-T_out);
    float z = importVertices[vNo][2];

    if (X_out < abs(x)) X_out = abs(x);
    if (Y_out < abs(y)) Y_out = abs(y);
    if (Z_out < abs(z)) Z_out = abs(z);
  }

  //Create3D.add_Box_Core(m, cen_X,cen_Y,cen_Z, X_out,Y_out,Z_out, T_out);
  allSolids.create(cen_X, cen_Y, cen_Z, CubePower, CubePower, CubePower, X_out, Y_out, Z_out, 0, 0, T_out, 1);

  return min_Z;
}












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


void ViewFromTheSky (float SKY2D_position_X, float SKY2D_position_Y, float SKY2D_position_Z, float SKY2D_rotation_X, float SKY2D_rotation_Y, float SKY2D_rotation_Z) {

  SKY2D_graphics.beginDraw();

  SKY2D_graphics.background(233);

  SKY2D_graphics.ortho(SKY2D_X_View / -SKY2D_ZOOM, SKY2D_X_View / SKY2D_ZOOM, SKY2D_Y_View / -SKY2D_ZOOM, SKY2D_Y_View / SKY2D_ZOOM, 0.00001, 100000);

  SKY2D_graphics.translate(0.5 * SKY2D_X_View, 0.5 * SKY2D_Y_View, 0); // << IMPORTANT!

  SKY2D_graphics.translate(SKY2D_position_X, SKY2D_position_Y, SKY2D_position_Z);
  SKY2D_graphics.rotateX(SKY2D_rotation_X * PI / 180);
  SKY2D_graphics.rotateY(SKY2D_rotation_Y * PI / 180);
  SKY2D_graphics.rotateZ(SKY2D_rotation_Z * PI / 180);

  SKY2D_graphics.hint(ENABLE_DEPTH_TEST);

  Land3D.draw(TypeWindow.SKY2D);

  for (int f = 0; f < allFaces.nodes.length; f++) {

    int vsb = allFaces.getVisibility(f);

    if (vsb > 0) {

      color c = color(0, 0, 0);

      int mt = allFaces.getMaterial(f);
      c = color(allMaterials.Color[mt][1], allMaterials.Color[mt][2], allMaterials.Color[mt][3], allMaterials.Color[mt][0]);

      SKY2D_graphics.stroke(c);
      SKY2D_graphics.fill(c);

      int tessellation = allFaces.getTessellation(f);

      int totalNumberOfSubs = 1;
      if (allFaces.getMaterial(f) == 0) {
        tessellation += allFaces.displayTessellation;
      }
      if (tessellation > 0) totalNumberOfSubs = allFaces.nodes[f].length * int(funcs.roundTo(pow(4, tessellation - 1), 1));

      float[][] base_Vertices = new float [allFaces.nodes[f].length][3];
      for (int j = 0; j < allFaces.nodes[f].length; j++) {
        int vNo = allFaces.nodes[f][j];
        base_Vertices[j][0] = allPoints.getX(vNo);
        base_Vertices[j][1] = allPoints.getY(vNo);
        base_Vertices[j][2] = allPoints.getZ(vNo);
      }

      for (int n = 0; n < totalNumberOfSubs; n++) {

        float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

        SKY2D_graphics.beginShape();

        for (int s = 0; s < subFace.length; s++) {

          SKY2D_graphics.vertex(subFace[s][0], -subFace[s][1], subFace[s][2]);
        }

        SKY2D_graphics.endShape(CLOSE);
      }
    }
  }

  SKY2D_graphics.endDraw();
}






















int getLocationTimeZone () {
  return int(funcs.roundTo(STATION.getLongitude() / 15, 15));
}


int[] getNow_inUTC () {

  int LocationTimeZone = getLocationTimeZone();

  int CurrentYear = year();
  int CurrentMonth = month();
  int CurrentDay = day();
  int CurrentHour = hour();


  // converting from local time to global time

  if (LocationTimeZone > 0) {
    CurrentHour -= LocationTimeZone;

    if (CurrentHour < 0) {
      CurrentHour += 24;
      CurrentDay -= 1;

      if (CurrentDay < 1) {

        CurrentMonth -= 1;

        if (CurrentMonth < 1) {
          CurrentMonth = 12;
          CurrentYear -= 1;
        }

        CurrentDay = TIME.lengthOfMonths[CurrentMonth - 1];
      }
    }
  }
  else if (LocationTimeZone < 0) {
    CurrentHour += abs(LocationTimeZone);

    if (CurrentHour > 23) {
      CurrentHour -= 24;
      CurrentDay += 1;

      if (CurrentDay > TIME.lengthOfMonths[CurrentMonth - 1]) {
        CurrentDay = 1;
        CurrentMonth += 1;

        if (CurrentMonth > 12) {
          CurrentMonth = 1;
          CurrentYear += 1;
        }
      }
    }
  }

  int[] return_array = {CurrentYear, CurrentMonth, CurrentDay, CurrentHour};

  return return_array;
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


void SOLARCHVISION_calculate_VertexSolar_array () {

  cursor(WAIT);

  VertexSolar_resize_array();

  float keep_STUDY_perDays = STUDY.perDays;
  int keep_STUDY_joinDays = STUDY.joinDays;
  if ((CurrentDataSource == dataID_ENSEMBLE_FORECAST) ||
      (CurrentDataSource == dataID_ENSEMBLE_OBSERVED)) {
    STUDY.perDays = 1;
    STUDY.joinDays = 1;
  }

  int[] startK_endK = get_startK_endK();
  int start_k = startK_endK[0];
  int end_k = startK_endK[1];
  int count_k = 1 + end_k - start_k;
  if (count_k < 0) count_k = 0;

  float Pa = FLOAT_undefined;
  float Pb = FLOAT_undefined;
  float Pc = FLOAT_undefined;
  float Pd = FLOAT_undefined;

  float values_R_dir;
  float values_R_dif;
  float values_E_dir;
  float values_E_dif;

  int now_k = 0;
  int now_i = 0;
  int now_j = 0;

  int[][] PROCESSED_DAILY_SCENARIOS = {
    {
    }
  };

  float Progress = 0;

  for (int f = 0; f < allFaces.nodes.length; f++) {

    if (1 + Progress < 100 * f / float(allFaces.nodes.length)) {
      Progress = 100 * f / float(allFaces.nodes.length);
      //println("Progress:", int(Progress), "%");
    }

    int vsb = allFaces.getVisibility(f);

    if (vsb > 0) {

      int tessellation = allFaces.getTessellation(f);

      int totalNumberOfSubs = 1;
      if (allFaces.getMaterial(f) == 0) {
        tessellation += allFaces.displayTessellation;
      }
      if (tessellation > 0) totalNumberOfSubs = allFaces.nodes[f].length * int(funcs.roundTo(pow(4, tessellation - 1), 1));

      float[][] base_Vertices = new float [allFaces.nodes[f].length][3];
      for (int j = 0; j < allFaces.nodes[f].length; j++) {
        int vNo = allFaces.nodes[f][j];
        base_Vertices[j][0] = allPoints.getX(vNo);
        base_Vertices[j][1] = allPoints.getY(vNo);
        base_Vertices[j][2] = allPoints.getZ(vNo);
      }

      for (int n = 0; n < totalNumberOfSubs; n++) {

        float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

        for (int s = 0; s < subFace.length; s++) {

          int q = SHADE.findID_SolarImpact_atXYZ(subFace[s][0], subFace[s][1], subFace[s][2]);

          if (q < 0) { // this will compute and add new points to the list only if there are not computed before.

            int s_next = (s + 1) % subFace.length;
            int s_prev = (s + subFace.length - 1) % subFace.length;

            PVector U = new PVector(subFace[s_next][0] - subFace[s][0], subFace[s_next][1] - subFace[s][1], subFace[s_next][2] - subFace[s][2]);
            PVector V = new PVector(subFace[s_prev][0] - subFace[s][0], subFace[s_prev][1] - subFace[s][1], subFace[s_prev][2] - subFace[s][2]);
            PVector UV = U.cross(V);
            float[] W = {
              UV.x, UV.y, UV.z
            };
            W = funcs.vec3_unit(W);

            float Alpha = funcs.asin_ang(W[2]);
            float Beta = funcs.atan2_ang(W[1], W[0]) + 90;

            float[] VECT = {
              0, 0, 0
            };

            if (abs(Alpha) > 89.99) {
              VECT[0] = 0;
              VECT[1] = 0;
              VECT[2] = 1;
            } else if (Alpha < -89.99) {
              VECT[0] = 0;
              VECT[1] = 0;
              VECT[2] = -1;
            } else {
              VECT[0] = funcs.sin_ang(Beta);
              VECT[1] = -funcs.cos_ang(Beta);
              VECT[2] = funcs.tan_ang(Alpha);
            }

            VECT = funcs.vec3_unit(VECT);


            float SkyMask = 0;

            for (int i = 0; i < DiffuseVectors.length; i++) {
              float[] SkyV = {
                DiffuseVectors[i][0], DiffuseVectors[i][1], DiffuseVectors[i][2]
              };

              float tmp = funcs.vec_dot(funcs.vec3_unit(SkyV), funcs.vec3_unit(VECT));
              if (tmp <= 0) tmp = 0; // removes backing faces

              SkyMask += tmp / float(DiffuseVectors.length);
            }



            int l = STUDY.ImpactLayer;

            int DATE_step = 1;

            int J_START = STUDY.j_Start;
            int J_END = STUDY.j_End;

            float TOTALvaluesSUM_RAD = FLOAT_undefined;
            float TOTALvaluesSUM_EFF_P = FLOAT_undefined;
            float TOTALvaluesSUM_EFF_N = FLOAT_undefined;
            int TOTALvaluesNUM = 0;

            for (int j = J_START; j < J_END; j += DATE_step) {

              float valuesSUM_RAD = FLOAT_undefined;
              float valuesSUM_EFF_P = FLOAT_undefined;
              float valuesSUM_EFF_N = FLOAT_undefined;
              int valuesNUM = 0;

              now_j = (j * int(STUDY.perDays) + TIME.beginDay + 365) % 365;

              if (now_j >= 365) {
                now_j = now_j % 365;
              }
              if (now_j < 0) {
                now_j = (now_j + 365) % 365;
              }

              float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);

              int[] Normals_COL_N;


              if (PROCESSED_DAILY_SCENARIOS.length > STUDY.j_End - STUDY.j_Start) {
                Normals_COL_N = PROCESSED_DAILY_SCENARIOS[STUDY.j_End - STUDY.j_Start];
              } else {
                Normals_COL_N = new int [9];
                Normals_COL_N = SOLARCHVISION_PROCESS_DAILY_SCENARIOS(start_k, end_k, j, DATE_ANGLE);

                int[][] newNormals = {
                  Normals_COL_N
                };
                PROCESSED_DAILY_SCENARIOS = (int[][]) concat(PROCESSED_DAILY_SCENARIOS, newNormals);
                //println("length of PROCESSED_DAILY_SCENARIOS =", PROCESSED_DAILY_SCENARIOS.length);
              }

              int nk = Normals_COL_N[l];

              if (nk != -1) {
                int k = int(nk / STUDY.joinDays);
                int j_ADD = nk % STUDY.joinDays;

                for (int i = 0; i < 24; i++) {

                  if (STUDY.isInHourlyRange(i)) {

                    float HOUR_ANGLE = i;
                    float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);

                    if (SunR[3] > 0) {

                      now_k = k + start_k;
                      now_i = i;
                      now_j = int(j * STUDY.perDays + (j_ADD - int(funcs.roundTo(0.5 * STUDY.joinDays, 1))) + TIME.beginDay + 365) % 365;

                      if (now_j >= 365) {
                        now_j = now_j % 365;
                      }
                      if (now_j < 0) {
                        now_j = (now_j + 365) % 365;
                      }

                      Pa = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_dirnorrad.id);
                      Pb = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_difhorrad.id);
                      Pc = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_direffect.id);
                      Pd = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_difeffect.id);

                      if (is_undefined(Pa) || is_undefined(Pb) || is_undefined(Pc) || is_undefined(Pd)) {
                        values_R_dir = FLOAT_undefined;
                        values_R_dif = FLOAT_undefined;
                        values_E_dir = FLOAT_undefined;
                        values_E_dif = FLOAT_undefined;
                      } else {

                        int memberCount = SOLARCHVISION_filter(CurrentDataSource, LAYER_cloudcover.id, STUDY.filter, STUDY.skyScenario, now_i, now_j, now_k);

                        if (memberCount == 1) {
                          values_R_dir = 0.001 * Pa;
                          values_R_dif = 0.001 * Pb;
                          values_E_dir = 0.001 * Pc;
                          values_E_dif = 0.001 * Pd;

                          if (is_undefined(valuesSUM_RAD)) {
                            valuesSUM_RAD = 0;
                            valuesSUM_EFF_P = 0;
                            valuesSUM_EFF_N = 0;
                            valuesNUM = 0;
                          } else {



                            float[] SunV = {
                              SunR[1], SunR[2], SunR[3]
                            };

                            float SunMask = funcs.vec_dot(funcs.vec3_unit(SunV), funcs.vec3_unit(VECT));
                            if (SunMask <= 0) SunMask = 0; // removes backing faces



                            float[] ray_start = subFace[s];
                            float[] ray_direction = {
                              SunR[1], SunR[2], SunR[3]
                            };

                            if (funcs.vec_dot(W, ray_direction) > 0) { // removes backing faces

                              if (SOLARCHVISION_isIntersected_Faces(ray_start, ray_direction, 0) != 0) {
                                if (values_E_dir < 0) {
                                  valuesSUM_EFF_P += -(values_E_dir * SunMask);
                                  valuesSUM_EFF_N += -(values_E_dif * SkyMask);
                                } else {
                                  valuesSUM_EFF_N += (values_E_dir * SunMask);
                                  valuesSUM_EFF_P += (values_E_dif * SkyMask);
                                }

                                valuesSUM_RAD += (values_R_dif * SkyMask);
                              } else {
                                if (values_E_dir < 0) {
                                  valuesSUM_EFF_N += -((values_E_dir * SunMask) + (values_E_dif * SkyMask));
                                } else {
                                  valuesSUM_EFF_P += ((values_E_dir * SunMask) + (values_E_dif * SkyMask));
                                }

                                valuesSUM_RAD += ((values_R_dir * SunMask) + (values_R_dif * SkyMask)); // calculates total radiation
                              }
                            }
                            valuesNUM += 1;
                          }
                        }
                      }
                    }
                  }
                }
              }


              if (valuesNUM != 0) {
                //float valuesMUL = funcs.DayTime(STATION.getLatitude(), DATE_ANGLE) / (1.0 * valuesNUM);
                //float valuesMUL = int(funcs.DayTime(STATION.getLatitude(), DATE_ANGLE)) / (1.0 * valuesNUM);
                float valuesMUL = funcs.roundTo(funcs.DayTime(STATION.getLatitude(), DATE_ANGLE), 1) / (1.0 * valuesNUM);

                valuesSUM_RAD *= valuesMUL;
                valuesSUM_EFF_P *= valuesMUL;
                valuesSUM_EFF_N *= valuesMUL;

                if (TOTALvaluesNUM == 0) {
                  TOTALvaluesSUM_RAD = 0;
                  TOTALvaluesSUM_EFF_P = 0;
                  TOTALvaluesSUM_EFF_N = 0;
                }

                TOTALvaluesSUM_RAD += valuesSUM_RAD;
                TOTALvaluesSUM_EFF_P += valuesSUM_EFF_P;
                TOTALvaluesSUM_EFF_N += valuesSUM_EFF_N;
                TOTALvaluesNUM += 1;
              } else {
                valuesSUM_RAD = FLOAT_undefined;
                valuesSUM_EFF_P = FLOAT_undefined;
                valuesSUM_EFF_N = FLOAT_undefined;
              }

              float AVERAGE, PERCENTAGE, COMPARISON;

              AVERAGE = (valuesSUM_EFF_P - valuesSUM_EFF_N);
              if ((valuesSUM_EFF_P + valuesSUM_EFF_N) > 0.00001) PERCENTAGE = (valuesSUM_EFF_P - valuesSUM_EFF_N) / (1.0 * (valuesSUM_EFF_P + valuesSUM_EFF_N));
              else PERCENTAGE = 0.0;
              COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);

              //println("3D-Model >> valuesSUM_RAD:", valuesSUM_RAD, "|COMPARISON:", COMPARISON);

              float[] ADDvalues_RAD = {
                valuesSUM_RAD
              };
              VertexSolar_amounts[Impact_ACTIVE][j + 1] = (float[]) concat(VertexSolar_amounts[Impact_ACTIVE][j + 1], ADDvalues_RAD);

              float[] ADDvalues_EFF = {
                COMPARISON
              };
              VertexSolar_amounts[Impact_PASSIVE][j + 1] = (float[]) concat(VertexSolar_amounts[Impact_PASSIVE][j + 1], ADDvalues_EFF);

            }


            if (TOTALvaluesNUM != 0) {
              TOTALvaluesSUM_RAD /= 1.0 * TOTALvaluesNUM;
              TOTALvaluesSUM_EFF_P /= 1.0 * TOTALvaluesNUM;
              TOTALvaluesSUM_EFF_N /= 1.0 * TOTALvaluesNUM;
            } else {
              TOTALvaluesSUM_RAD = FLOAT_undefined;
              TOTALvaluesSUM_EFF_P = FLOAT_undefined;
              TOTALvaluesSUM_EFF_N = FLOAT_undefined;
            }


            float AVERAGE, PERCENTAGE, COMPARISON;

            AVERAGE = (TOTALvaluesSUM_EFF_P - TOTALvaluesSUM_EFF_N);
            if ((TOTALvaluesSUM_EFF_P + TOTALvaluesSUM_EFF_N) > 0.00001) PERCENTAGE = (TOTALvaluesSUM_EFF_P - TOTALvaluesSUM_EFF_N) / (1.0 * (TOTALvaluesSUM_EFF_P + TOTALvaluesSUM_EFF_N));
            else PERCENTAGE = 0.0;
            COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);


            float valuesSUM = FLOAT_undefined;
            if (Impact_TYPE == Impact_ACTIVE) valuesSUM = TOTALvaluesSUM_RAD;
            if (Impact_TYPE == Impact_PASSIVE) valuesSUM = COMPARISON;

            //println("3D-Model >> valuesSUM_RAD:", valuesSUM_RAD, "|COMPARISON:", COMPARISON);

            float[] ADDvalues_RAD = {
              TOTALvaluesSUM_RAD
            };
            VertexSolar_amounts[Impact_ACTIVE][0] = (float[]) concat(VertexSolar_amounts[Impact_ACTIVE][0], ADDvalues_RAD);

            float[] ADDvalues_EFF = {
              COMPARISON
            };
            VertexSolar_amounts[Impact_PASSIVE][0] = (float[]) concat(VertexSolar_amounts[Impact_PASSIVE][0], ADDvalues_EFF);

            float[][] ADD_values_XYZ = {
              {
                subFace[s][0], subFace[s][1], subFace[s][2]
              }
            };
            VertexSolar_XYZ = (float[][]) concat(VertexSolar_XYZ, ADD_values_XYZ);

          }

        }

      }
    }
  }

  cursor(ARROW);
}






float[] SOLARCHVISION_snap_Faces (float[] RxP) {

  if (RxP[0] >= 0) {

    int f = int(RxP[0]);
    float x = RxP[1];
    float y = RxP[2];
    float z = RxP[3];

    if (User3D.create_Snap == 1) { // nearest endpoint

      float nearest_D = FLOAT_undefined;
      float nearest_X = FLOAT_undefined;
      float nearest_Y = FLOAT_undefined;
      float nearest_Z = FLOAT_undefined;

      int mt = allFaces.getMaterial(f);

      int tessellation = allFaces.getTessellation(f);

      int totalNumberOfSubs = 1;
      if (allFaces.getMaterial(f) == 0) {
        tessellation += allFaces.displayTessellation;
      }
      if (tessellation > 0) totalNumberOfSubs = allFaces.nodes[f].length * int(funcs.roundTo(pow(4, tessellation - 1), 1));

      float[][] base_Vertices = new float [allFaces.nodes[f].length][3];
      for (int j = 0; j < allFaces.nodes[f].length; j++) {
        int vNo = allFaces.nodes[f][j];
        base_Vertices[j][0] = allPoints.getX(vNo);
        base_Vertices[j][1] = allPoints.getY(vNo);
        base_Vertices[j][2] = allPoints.getZ(vNo);
      }

      for (int n = 0; n < totalNumberOfSubs; n++) {

        float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

        WIN3D.graphics.beginShape();

        for (int s = 0; s < subFace.length; s++) {

          float d = dist(x, y, z, subFace[s][0], subFace[s][1], subFace[s][2]);

          if (nearest_D > d) {
            nearest_D = d;
            nearest_X = subFace[s][0];
            nearest_Y = subFace[s][1];
            nearest_Z = subFace[s][2];
          }
        }
      }

      if (is_defined(nearest_D)) {
        RxP[1] = nearest_X;
        RxP[2] = nearest_Y;
        RxP[3] = nearest_Z;
      }
    }
  }

  return RxP;
}


int SOLARCHVISION_isIntersected_Faces (float[] ray_pnt, float[] ray_dir, int firstGuess) {

  float[] ray_normal = funcs.vec3_unit(ray_dir);

  int hit = 0;

  for (int q = 0; q < allFaces.nodes.length; q++) {

    int f = (q + firstGuess) % allFaces.nodes.length;

    if (f > 0) {

      int n = allFaces.nodes[f].length;

      if (n > 2) {

        int vsb = allFaces.getVisibility(f);

          if (vsb > 0) {

          float X_intersect = FLOAT_undefined;
          float Y_intersect = FLOAT_undefined;
          float Z_intersect = FLOAT_undefined;
          float dist2intersect = FLOAT_undefined;
          float[] face_norm = {0,0,0};

          boolean InPoly = false;

          if (n < 5) { // works if n==3 or n==4

            float[] A = allPoints.getPosition(allFaces.nodes[f][0]);
            float[] B = allPoints.getPosition(allFaces.nodes[f][1]);
            float[] C = allPoints.getPosition(allFaces.nodes[f][n - 2]);
            float[] D = allPoints.getPosition(allFaces.nodes[f][n - 1]);

            float[] AC = funcs.vec3_diff(A, C);
            float[] BD = funcs.vec3_diff(B, D);

            face_norm = funcs.vec3_cross(AC, BD);

            float face_offset = 0.25 * ((A[0] + B[0] + C[0] + D[0]) * face_norm[0] +
                                        (A[1] + B[1] + C[1] + D[1]) * face_norm[1] +
                                        (A[2] + B[2] + C[2] + D[2]) * face_norm[2]);

            float R = -funcs.vec3_dot(ray_dir, face_norm);

            if ((R < FLOAT_tiny) && (R > -FLOAT_tiny)) { // the ray is parallel to the plane
              dist2intersect = FLOAT_huge;
            }
            else {
              dist2intersect = (funcs.vec3_dot(ray_pnt, face_norm) - face_offset) / R;

              //if (dist2intersect > 0) {
              if (dist2intersect > FLOAT_tiny) {

                X_intersect = dist2intersect * ray_dir[0] + ray_pnt[0];
                Y_intersect = dist2intersect * ray_dir[1] + ray_pnt[1];
                Z_intersect = dist2intersect * ray_dir[2] + ray_pnt[2];

                float[] P = {X_intersect, Y_intersect, Z_intersect};

                if (n == 4) InPoly = funcs.isInside_Quadrangle(P, A, B, C, D);
                else InPoly = funcs.isInside_Triangle(P, A, B, D); // note D is the last vertex while C=B in this case

              }
            }
          }
          else {

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

            for (int j = 0; j < n; j++) {

              int j_next = (j + 1) % n;

              float[] A = {
                allPoints.getX(allFaces.nodes[f][j]),
                allPoints.getY(allFaces.nodes[f][j]),
                allPoints.getZ(allFaces.nodes[f][j])
              };

              float[] B = {
                allPoints.getX(allFaces.nodes[f][j_next]),
                allPoints.getY(allFaces.nodes[f][j_next]),
                allPoints.getZ(allFaces.nodes[f][j_next])
              };

              float[] AG = funcs.vec3_diff(A, G);
              float[] BG = funcs.vec3_diff(B, G);

              face_norm = funcs.vec3_cross(AG, BG);

              float face_offset = (1.0 / 3.0) * ((A[0] + B[0] + G[0]) * face_norm[0] +
                                                 (A[1] + B[1] + G[1]) * face_norm[1] +
                                                 (A[2] + B[2] + G[2]) * face_norm[2]);

              float R = -funcs.vec3_dot(ray_dir, face_norm);

              if ((R < FLOAT_tiny) && (R > -FLOAT_tiny)) { // the ray is parallel to the plane
                dist2intersect = FLOAT_huge;
              }
              else {
                dist2intersect = (funcs.vec3_dot(ray_pnt, face_norm) - face_offset) / R;

                //if (dist2intersect > 0) {
                if (dist2intersect > FLOAT_tiny) {

                  X_intersect = dist2intersect * ray_dir[0] + ray_pnt[0];
                  Y_intersect = dist2intersect * ray_dir[1] + ray_pnt[1];
                  Z_intersect = dist2intersect * ray_dir[2] + ray_pnt[2];

                  float[] P = {X_intersect, Y_intersect, Z_intersect};

                  InPoly = funcs.isInside_Triangle(P, A, B, G);

                }
              }

              if (InPoly) break;
            }
          }

          if (InPoly) {

            hit = f;

            break;
          }

        }

        if (hit != 0) break;
      }
    }
  }

  return hit;
}















float[][] skyVertices = new float [0][3];
int[][] skyFaces = new int [0][1];

int POINTER_TempObjectVertices = 0;
int POINTER_TempObjectFaces = 0;

float[][] TempObjectVertices = new float [0][3];
int[][] TempObjectFaces = new int [0][1];

float SOLARCHVISION_SolarAtSurface (float SunR1, float SunR2, float SunR3, float SunR4, float SunR5, float Alpha, float Beta, float THE_ALBEDO) {

  float return_value = FLOAT_undefined;

  if (is_defined(SunR1) &&
      is_defined(SunR2) &&
      is_defined(SunR3) &&
      is_defined(SunR4) &&
      is_defined(SunR5)) {

    float[] VECT = {
      0, 0, 0
    };

    if (abs(Alpha) > 89.99) {
      VECT[0] = 0;
      VECT[1] = 0;
      VECT[2] = 1;
    } else if (Alpha < -89.99) {
      VECT[0] = 0;
      VECT[1] = 0;
      VECT[2] = -1;
    } else {
      VECT[0] = funcs.sin_ang(Beta);
      VECT[1] = -funcs.cos_ang(Beta);
      VECT[2] = funcs.tan_ang(Alpha);
    }

    VECT = funcs.vec3_unit(VECT);


    float[] SunV = {
      SunR1, SunR2, SunR3
    };

    float SunMask = funcs.vec_dot(funcs.vec3_unit(SunV), funcs.vec3_unit(VECT));
    if (SunMask <= 0) SunMask = 0; // removes backing faces

    float SkyMask = (0.5 * (1.0 + (Alpha / 90.0)));

    return_value = (SunR4 * SunMask) + (SunR5 * SkyMask);


    /*
    float[] REF_SunV = {SunR1, SunR2, -SunR3};

     float REF_SunMask = funcs.vec_dot(funcs.vec3_unit(REF_SunV), funcs.vec3_unit(VECT));
     if (REF_SunMask <= 0) REF_SunMask = 0; // removes backing faces

     float REF_SkyMask = 1 - (0.5 * (1.0 + (Alpha / 90.0)));

     return_value +=  (0.01 * THE_ALBEDO) * ((SunR4 * REF_SunMask) + (SunR5 * REF_SkyMask));
     */
  }

  return (return_value);
}












void GlobalSolar_resize_array () {

  Sky3D.stp_slp = Sky3D.calculatedResolution;
  Sky3D.stp_dir = Sky3D.calculatedResolution;
  Sky3D.num_slp = int(funcs.roundTo(180.0 / (1.0 * Sky3D.stp_slp), 1)) + 1;
  Sky3D.num_dir = int(funcs.roundTo(360.0 / (1.0 * Sky3D.stp_dir), 1));

  GlobalSolar = new float [2][(1 + STUDY.j_End - STUDY.j_Start)][Sky3D.num_slp][Sky3D.num_dir];

  for (int i = 0; i < GlobalSolar.length; i++) {
    for (int j = 0; j < GlobalSolar[i].length; j++) {

      for (int a = 0; a < Sky3D.num_slp; a++) {
        for (int b = 0; b < Sky3D.num_dir; b++) {
          GlobalSolar[i][j][a][b] = FLOAT_undefined;
        }
      }
    }
  }

  GlobalSolar_rebuild_array = false;
}


void SOLARCHVISION_calculate_GlobalSolar_array () {

  cursor(WAIT);

  if (GlobalSolar_rebuild_array) {
    GlobalSolar_resize_array();
  }

  float keep_STUDY_perDays = STUDY.perDays;
  int keep_STUDY_joinDays = STUDY.joinDays;
  if ((CurrentDataSource == dataID_ENSEMBLE_FORECAST) ||
      (CurrentDataSource == dataID_ENSEMBLE_OBSERVED)) {
    STUDY.perDays = 1;
    STUDY.joinDays = 1;
  }

  int[] startK_endK = get_startK_endK();
  int start_k = startK_endK[0];
  int end_k = startK_endK[1];
  int count_k = 1 + end_k - start_k;
  if (count_k < 0) count_k = 0;

  float Pa = FLOAT_undefined;
  float Pb = FLOAT_undefined;
  float Pc = FLOAT_undefined;
  float Pd = FLOAT_undefined;

  float values_R_dir;
  float values_R_dif;
  float values_E_dir;
  float values_E_dif;

  int now_k = 0;
  int now_i = 0;
  int now_j = 0;

  int l = STUDY.ImpactLayer;

  float[][] TOTALvaluesSUM_RAD = new float [1 + int(180 / Sky3D.stp_slp)][1 + int(360 / Sky3D.stp_dir)];
  float[][] TOTALvaluesSUM_EFF_P = new float [1 + int(180 / Sky3D.stp_slp)][1 + int(360 / Sky3D.stp_dir)];
  float[][] TOTALvaluesSUM_EFF_N = new float [1 + int(180 / Sky3D.stp_slp)][1 + int(360 / Sky3D.stp_dir)];
  int[][] TOTALvaluesNUM = new int [1 + int(180 / Sky3D.stp_slp)][1 + int(360 / Sky3D.stp_dir)];

  for (int a = 0; a <= int (180 / Sky3D.stp_slp); a++) {
    for (int b = 0; b < int (360 / Sky3D.stp_dir); b++) {
      TOTALvaluesSUM_RAD[a][b] = FLOAT_undefined;
      TOTALvaluesSUM_EFF_P[a][b] = FLOAT_undefined;
      TOTALvaluesSUM_EFF_N[a][b] = FLOAT_undefined;
      TOTALvaluesNUM[a][b] = 0;
    }
  }

  for (int j = STUDY.j_Start; j < STUDY.j_End; j++) {

    now_j = (j * int(STUDY.perDays) + TIME.beginDay + 365) % 365;

    if (now_j >= 365) {
      now_j = now_j % 365;
    }
    if (now_j < 0) {
      now_j = (now_j + 365) % 365;
    }

    float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);

    int[] Normals_COL_N;
    Normals_COL_N = new int [9];
    Normals_COL_N = SOLARCHVISION_PROCESS_DAILY_SCENARIOS(start_k, end_k, j, DATE_ANGLE);

    for (int nk = Normals_COL_N[l]; nk <= Normals_COL_N[l]; nk++) {
      if (nk != -1) {
        int k = int(nk / STUDY.joinDays);
        int j_ADD = nk % STUDY.joinDays;

        for (int a = 0; a <= int (180 / Sky3D.stp_slp); a++) {
          float Alpha = a * Sky3D.stp_slp - 90;
          for (int b = 0; b < int (360 / Sky3D.stp_dir); b++) {
            float Beta = b * Sky3D.stp_dir;

            float valuesSUM_RAD = 0;
            float valuesSUM_EFF_P = 0;
            float valuesSUM_EFF_N = 0;
            int valuesNUM = 0;

            for (int i = 0; i < 24; i++) {
              if (STUDY.isInHourlyRange(i)) {

                float HOUR_ANGLE = i;
                float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);

                if (SunR[3] > 0) {

                  now_k = k + start_k;
                  now_i = i;
                  now_j = int(j * STUDY.perDays + (j_ADD - int(funcs.roundTo(0.5 * STUDY.joinDays, 1))) + TIME.beginDay + 365) % 365;

                  if (now_j >= 365) {
                    now_j = now_j % 365;
                  }
                  if (now_j < 0) {
                    now_j = (now_j + 365) % 365;
                  }

                  Pa = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_dirnorrad.id);
                  Pb = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_difhorrad.id);
                  Pc = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_direffect.id);
                  Pd = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_difeffect.id);

                  if (is_undefined(Pa) || is_undefined(Pb) || is_undefined(Pc) || is_undefined(Pd)) {
                    values_R_dir = FLOAT_undefined;
                    values_R_dif = FLOAT_undefined;
                    values_E_dir = FLOAT_undefined;
                    values_E_dif = FLOAT_undefined;
                  } else {

                    int memberCount = SOLARCHVISION_filter(CurrentDataSource, LAYER_cloudcover.id, STUDY.filter, STUDY.skyScenario, now_i, now_j, now_k);

                    if (memberCount == 1) {
                      values_R_dir = 0.001 * Pa;
                      values_R_dif = 0.001 * Pb;
                      values_E_dir = 0.001 * Pc;
                      values_E_dif = 0.001 * Pd;

                      if (is_undefined(valuesSUM_RAD)) {
                        valuesSUM_RAD = 0;
                        valuesSUM_EFF_P = 0;
                        valuesSUM_EFF_N = 0;
                        valuesNUM = 0;
                      } else {

                        if (values_E_dir < 0) {
                          valuesSUM_EFF_N += -SOLARCHVISION_SolarAtSurface(SunR[1], SunR[2], SunR[3], values_E_dir, values_E_dif, Alpha, Beta, GlobalAlbedo);
                        } else {
                          valuesSUM_EFF_P += SOLARCHVISION_SolarAtSurface(SunR[1], SunR[2], SunR[3], values_E_dir, values_E_dif, Alpha, Beta, GlobalAlbedo);
                        }

                        valuesSUM_RAD += SOLARCHVISION_SolarAtSurface(SunR[1], SunR[2], SunR[3], values_R_dir, values_R_dif, Alpha, Beta, GlobalAlbedo);

                        valuesNUM += 1;
                      }
                    }
                  }
                }
              }
            }


            if (valuesNUM != 0) {
              //float valuesMUL = funcs.DayTime(STATION.getLatitude(), DATE_ANGLE) / (1.0 * valuesNUM);
              //float valuesMUL = int(funcs.DayTime(STATION.getLatitude(), DATE_ANGLE)) / (1.0 * valuesNUM);
              float valuesMUL = funcs.roundTo(funcs.DayTime(STATION.getLatitude(), DATE_ANGLE), 1) / (1.0 * valuesNUM);

              valuesSUM_RAD *= valuesMUL;
              valuesSUM_EFF_P *= valuesMUL;
              valuesSUM_EFF_N *= valuesMUL;

              if (TOTALvaluesNUM[a][b] == 0) {
                TOTALvaluesSUM_RAD[a][b] = 0;
                TOTALvaluesSUM_EFF_P[a][b] = 0;
                TOTALvaluesSUM_EFF_N[a][b] = 0;
              }

              TOTALvaluesSUM_RAD[a][b] += valuesSUM_RAD;
              TOTALvaluesSUM_EFF_P[a][b] += valuesSUM_EFF_P;
              TOTALvaluesSUM_EFF_N[a][b] += valuesSUM_EFF_N;
              TOTALvaluesNUM[a][b] += 1;
            } else {
              valuesSUM_RAD = FLOAT_undefined;
              valuesSUM_EFF_P = FLOAT_undefined;
              valuesSUM_EFF_N = FLOAT_undefined;
            }


            float AVERAGE, PERCENTAGE, COMPARISON;

            AVERAGE = (valuesSUM_EFF_P - valuesSUM_EFF_N);
            if ((valuesSUM_EFF_P + valuesSUM_EFF_N) > 0.00001) PERCENTAGE = (valuesSUM_EFF_P - valuesSUM_EFF_N) / (1.0 * (valuesSUM_EFF_P + valuesSUM_EFF_N));
            else PERCENTAGE = 0.0;
            COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);

            if (is_defined(valuesSUM_RAD)) {
              GlobalSolar[Impact_ACTIVE][j + 1][a][b] = valuesSUM_RAD;
            }
            if (is_defined(COMPARISON)) {
              GlobalSolar[Impact_PASSIVE][j + 1][a][b] = COMPARISON;
            }
          }
        }
      }
    }
  }



  for (int a = 0; a <= int (180 / Sky3D.stp_slp); a++) {
    float Alpha = a * Sky3D.stp_slp - 90;
    for (int b = 0; b < int (360 / Sky3D.stp_dir); b++) {
      float Beta = b * Sky3D.stp_dir;

      if (TOTALvaluesNUM[a][b] != 0) {
        TOTALvaluesSUM_RAD[a][b] /= 1.0 * TOTALvaluesNUM[a][b];
        TOTALvaluesSUM_EFF_P[a][b] /= 1.0 * TOTALvaluesNUM[a][b];
        TOTALvaluesSUM_EFF_N[a][b] /= 1.0 * TOTALvaluesNUM[a][b];
      } else {
        TOTALvaluesSUM_RAD[a][b] = FLOAT_undefined;
        TOTALvaluesSUM_EFF_P[a][b] = FLOAT_undefined;
        TOTALvaluesSUM_EFF_N[a][b] = FLOAT_undefined;
      }

      float AVERAGE, PERCENTAGE, COMPARISON;

      AVERAGE = (TOTALvaluesSUM_EFF_P[a][b] - TOTALvaluesSUM_EFF_N[a][b]);
      if ((TOTALvaluesSUM_EFF_P[a][b] + TOTALvaluesSUM_EFF_N[a][b]) > 0.00001) PERCENTAGE = (TOTALvaluesSUM_EFF_P[a][b] - TOTALvaluesSUM_EFF_N[a][b]) / (1.0 * (TOTALvaluesSUM_EFF_P[a][b] + TOTALvaluesSUM_EFF_N[a][b]));
      else PERCENTAGE = 0.0;
      COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);

      if (is_defined(TOTALvaluesSUM_RAD[a][b])) {
        GlobalSolar[Impact_ACTIVE][0][a][b] = TOTALvaluesSUM_RAD[a][b];
      }
      if (is_defined(COMPARISON)) {
        GlobalSolar[Impact_PASSIVE][0][a][b] = COMPARISON;
      }

    }
  }


  keep_STUDY_perDays = STUDY.perDays;
  STUDY.joinDays = keep_STUDY_joinDays;

  cursor(ARROW);
}


void SOLARCHVISION_draw_logo (float cx, float cy, float cz, float cr, int the_view, int pass) {

  float stp_u = 1.0 / 24.0;
  float stp_v = 1.0 / 24.0;

  int n_a = 1;

  int aI = 0;
  for (float a = -1; a < 1; a += stp_u) {
    aI++;

    n_a *= -1;

    int n_b = n_a;

    int bI = 0;
    for (float b = -1; b < 1; b += stp_v) {
      bI++;

      n_b *= -1;

      float[][] newQuad = {
        {
          0, 0, 0
        }
        , {
          0, 0, 0
        }
        , {
          0, 0, 0
        }
        , {
          0, 0, 0
        }
      };

      for (int i = 0; i < 4; i++) {

        float u = a;
        float v = b;

        if ((i == 1) || (i == 2)) u += stp_u;
        if ((i == 2) || (i == 3)) v += stp_v;

        //---------------------------------------
        float x0 = cos(u * PI);
        float y0 = -sin(u * PI) * cos(v * PI);
        float z0 = sin(v * PI);

        float d = pow(x0*x0 + y0*y0 + z0*z0, 0.5);
        x0 /= d;
        y0 /= d;
        z0 /= d;

        float x = x0;
        float y = y0;
        float z = z0;

        if (the_view == 0) { // corner view: logo
          float t = -0.25 * PI;
          newQuad[i][0] = x0 * cos(t) - z0 * sin(t);
          newQuad[i][1] = y0;
          newQuad[i][2] = x0 * sin(t) + z0 * cos(t);
        } else if (the_view == 1) { // front view
          newQuad[i][0] = x0;
          newQuad[i][1] = y0;
          newQuad[i][2] = z0;
        } else if (the_view == -1) { // top view
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

      strokeWeight(1);
      stroke(127);
      noFill();

      int q = 0;

      if(pass == 2) {
        if((aI == bI + 2) || (aI == bI + 3) || (aI == bI + 4)) {
          if(aI == bI + 2) q = 1;
          if(aI == bI + 4) q = 2;

          strokeWeight(2);
          stroke(255);
          fill(255,191,127);

          if(
            (aI == 47 && bI == 45) ||
            (aI == 48 && bI == 44) ||
            (aI == 40 && bI == 38) ||
            (aI == 41 && bI == 37)
          ) {
            fill(0);
          }
        } else if((aI + bI == 43) || (aI + bI == 44) || (aI + bI == 45)) {
          if(aI + bI == 43) q = 4;
          if(aI + bI == 45) q = 3;

          strokeWeight(2);
          stroke(255);
          fill(0);
        } else {
          continue;
        }
      }

      if(q == 0) {
        if (n_a * n_b == 1) {
          triangle(x1, y1, x2, y2, x3, y3);
          triangle(x3, y3, x4, y4, x1, y1);
        } else {
          triangle(x4, y4, x1, y1, x2, y2);
          triangle(x2, y2, x3, y3, x4, y4);
        }
      } else {
        if(q == 1) triangle(x1, y1, x2, y2, x3, y3);
        if(q == 2) triangle(x3, y3, x4, y4, x1, y1);
        if(q == 3) triangle(x4, y4, x1, y1, x2, y2);
        if(q == 4) triangle(x2, y2, x3, y3, x4, y4);
      }
    }
  }
}













int mouseWheelConsume = 0;

void mouseWheel (MouseEvent event) {

  if (frameCount > Last_initializationStep) {

    if (UI_menuBar.selected_parent == -1) {

      mouseWheelConsume += 1;
      if (mouseWheelConsume % 2 == 0) {
        mouseWheelConsume = 0;

        float Wheel_Value = event.getCount();

        if (SOLARCHVISION_automated == 0) {
          SOLARCHVISION_X_clicked = mouseX;
          SOLARCHVISION_Y_clicked = mouseY;

          {
            float displayBarHeight = MessageSize;
            float displayBarWidth = 2 * SOLARCHVISION_pixel_W;

            STUDY.X_control = 0.5 * displayBarWidth;
            STUDY.Y_control = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 2 * SOLARCHVISION_pixel_H + 0.5 * UI_caseBar.tab;

            for (int i = 0; i < UI_caseBar.Items.length; i++) {

              float x1 = STUDY.X_control - 0.366 * displayBarWidth;
              float x2 = STUDY.X_control + 0.5 * displayBarWidth;
              float y1 = STUDY.Y_control - 0.45 * displayBarHeight;
              float y2 = STUDY.Y_control + 0.45 * displayBarHeight;

              if (UI_caseBar.Items[i][0].equals("Hours")) {

                if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, x1, y1, x2, y2)) {

                  int keep_STUDY_i_Start = STUDY.i_Start;
                  int keep_STUDY_i_End = STUDY.i_End;

                  if (Wheel_Value > 0) {
                    STUDY.i_Start += 1;
                    STUDY.i_End += 1;
                  }
                  if (Wheel_Value < 0) {
                    STUDY.i_Start -= 1;
                    STUDY.i_End -= 1;
                  }

                  if (STUDY.i_Start < 0) STUDY.i_Start = 23;
                  if (STUDY.i_Start > 23) STUDY.i_Start = 0;
                  if (STUDY.i_End < 0) STUDY.i_End = 23;
                  if (STUDY.i_End > 23) STUDY.i_End = 0;

                  if ((keep_STUDY_i_Start != STUDY.i_Start) ||
                      (keep_STUDY_i_End != STUDY.i_End)) {

                    ROLLOUT.revise();
                    STUDY.revise();
                    WORLD.revise();
                    UI_caseBar.revise();
                    SOLARCHVISION_view_changed();

                    SOLARCHVISION_find_which_bakings_to_regenerate();
                  }
                }
              }

              if (UI_caseBar.Items[i][0].equals("Days")) {

                if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, x1, y1, x2, y2)) {

                  int keep_STUDY_joinDays = STUDY.joinDays;

                  if (Wheel_Value > 0) STUDY.joinDays += 2;
                  if (Wheel_Value < 0) STUDY.joinDays -= 2;

                  if (STUDY.joinDays > 365 / STUDY.j_End) STUDY.joinDays = 365 / STUDY.j_End;
                  if (STUDY.joinDays < 1) STUDY.joinDays = 1;

                  if (keep_STUDY_joinDays != STUDY.joinDays) {

                    ROLLOUT.revise();
                    STUDY.revise();
                    UI_caseBar.revise();
                    SOLARCHVISION_view_changed();

                    SOLARCHVISION_find_which_bakings_to_regenerate();
                  }
                }
              }

              if (UI_caseBar.Items[i][0].equals("Scenario")) {

                if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, x1, y1, x2, y2)) {

                  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
                    int keep_SampleYear_Start = SampleYear_Start;
                    int keep_SampleYear_End = SampleYear_End;

                    if (Wheel_Value > 0) {
                      SampleYear_Start += 1;
                      SampleYear_End += 1;
                    }
                    if (Wheel_Value < 0) {
                      SampleYear_Start -= 1;
                      SampleYear_End -= 1;
                    }

                    if (SampleYear_End < SampleYear_Start) SampleYear_End = SampleYear_Start;
                    if (SampleYear_Start > SampleYear_End) SampleYear_Start = SampleYear_End;

                    if (SampleYear_Start < CLIMATE_CWEEDS_start) SampleYear_Start = CLIMATE_CWEEDS_start;
                    if (SampleYear_Start > CLIMATE_CWEEDS_end) SampleYear_Start = CLIMATE_CWEEDS_end;
                    if (SampleYear_End < CLIMATE_CWEEDS_start) SampleYear_End = CLIMATE_CWEEDS_start;
                    if (SampleYear_End > CLIMATE_CWEEDS_end) SampleYear_End = CLIMATE_CWEEDS_end;

                    if ((keep_SampleYear_Start != SampleYear_Start) ||
                        (keep_SampleYear_End != SampleYear_End)) {

                      ROLLOUT.revise();
                      STUDY.revise();
                      UI_caseBar.revise();
                      SOLARCHVISION_view_changed();

                      SOLARCHVISION_find_which_bakings_to_regenerate();
                    }
                  }

                  if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
                    int keep_SampleYear_Start = SampleYear_Start;
                    int keep_SampleYear_End = SampleYear_End;

                    if (Wheel_Value > 0) {
                      SampleYear_Start += 1;
                      SampleYear_End += 1;
                    }
                    if (Wheel_Value < 0) {
                      SampleYear_Start -= 1;
                      SampleYear_End -= 1;
                    }

                    if (SampleYear_End < SampleYear_Start) SampleYear_End = SampleYear_Start;
                    if (SampleYear_Start > SampleYear_End) SampleYear_Start = SampleYear_End;

                    if (SampleYear_Start < CLIMATE_CLMREC_start) SampleYear_Start = CLIMATE_CLMREC_start;
                    if (SampleYear_Start > CLIMATE_CLMREC_end) SampleYear_Start = CLIMATE_CLMREC_end;
                    if (SampleYear_End < CLIMATE_CLMREC_start) SampleYear_End = CLIMATE_CLMREC_start;
                    if (SampleYear_End > CLIMATE_CLMREC_end) SampleYear_End = CLIMATE_CLMREC_end;

                    if ((keep_SampleYear_Start != SampleYear_Start) ||
                        (keep_SampleYear_End != SampleYear_End)) {

                      ROLLOUT.revise();
                      STUDY.revise();
                      UI_caseBar.revise();
                      SOLARCHVISION_view_changed();

                      SOLARCHVISION_find_which_bakings_to_regenerate();
                    }
                  }

                  if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
                    int keep_SampleMember_Start = SampleMember_Start;
                    int keep_SampleMember_End = SampleMember_End;

                    if (Wheel_Value > 0) {
                      SampleMember_Start += 1;
                      SampleMember_End += 1;
                    }
                    if (Wheel_Value < 0) {
                      SampleMember_Start -= 1;
                      SampleMember_End -= 1;
                    }

                    if (SampleMember_End < SampleMember_Start) SampleMember_End = SampleMember_Start;
                    if (SampleMember_Start > SampleMember_End) SampleMember_Start = SampleMember_End;

                    if (SampleMember_Start < ENSEMBLE_FORECAST_start) SampleMember_Start = ENSEMBLE_FORECAST_start;
                    if (SampleMember_Start > ENSEMBLE_FORECAST_end) SampleMember_Start = ENSEMBLE_FORECAST_end;
                    if (SampleMember_End < ENSEMBLE_FORECAST_start) SampleMember_End = ENSEMBLE_FORECAST_start;
                    if (SampleMember_End > ENSEMBLE_FORECAST_end) SampleMember_End = ENSEMBLE_FORECAST_end;

                    if ((keep_SampleMember_Start != SampleMember_Start) ||
                        (keep_SampleMember_End != SampleMember_End)) {

                      ROLLOUT.revise();
                      STUDY.revise();
                      UI_caseBar.revise();
                      SOLARCHVISION_view_changed();

                      SOLARCHVISION_find_which_bakings_to_regenerate();
                    }
                  }

                  if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
                    int keep_SampleStation_Start = SampleStation_Start;
                    int keep_SampleStation_End = SampleStation_End;

                    if (Wheel_Value > 0) {
                      SampleStation_Start += 1;
                      SampleStation_End += 1;
                    }
                    if (Wheel_Value < 0) {
                      SampleStation_Start -= 1;
                      SampleStation_End -= 1;
                    }

                    if (SampleStation_End < SampleStation_Start) SampleStation_End = SampleStation_Start;
                    if (SampleStation_Start > SampleStation_End) SampleStation_Start = SampleStation_End;

                    if (SampleStation_Start < ENSEMBLE_OBSERVED_start) SampleStation_Start = ENSEMBLE_OBSERVED_start;
                    if (SampleStation_Start > ENSEMBLE_OBSERVED_end) SampleStation_Start = ENSEMBLE_OBSERVED_end;
                    if (SampleStation_End < ENSEMBLE_OBSERVED_start) SampleStation_End = ENSEMBLE_OBSERVED_start;
                    if (SampleStation_End > ENSEMBLE_OBSERVED_end) SampleStation_End = ENSEMBLE_OBSERVED_end;

                    if ((keep_SampleStation_Start != SampleStation_Start) ||
                        (keep_SampleStation_End != SampleStation_End)) {

                      ROLLOUT.revise();
                      STUDY.revise();
                      UI_caseBar.revise();
                      SOLARCHVISION_view_changed();

                      SOLARCHVISION_find_which_bakings_to_regenerate();
                    }
                  }
                }
              }


              STUDY.Y_control += UI_caseBar.tab;
            }
          }


          if (WORLD.include) {
            if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, WORLD.cX, WORLD.cY, WORLD.cX + WORLD.dX, WORLD.cY + WORLD.dY)) {

              int keep_WORLD_Zoom = WORLD.Zoom;

              if (Wheel_Value < 0) WORLD.Zoom += 1;
              if (Wheel_Value > 0) WORLD.Zoom -= 1;

              if (WORLD.Zoom < 1) WORLD.Zoom = 1;
              if (WORLD.Zoom > 6) WORLD.Zoom = 6;

              if (keep_WORLD_Zoom != WORLD.Zoom) {
                WORLD.VIEW_id = WORLD.FindGoodViewport(LocationLON, LocationLAT);

                WORLD.revise();
              }
            }
          }

          if (WIN3D.include) {
            if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, WIN3D.cX, WIN3D.cY, WIN3D.cX + WIN3D.dX, WIN3D.cY + WIN3D.dY)) {

              float[] P = Select3D.getPivot();

              float x0 = P[0];
              float y0 = P[1];
              float z0 = P[2];


              if (WIN3D.UI_CurrentTask == UITASK.Rotate) { // rotate

                float r = 5 * Wheel_Value;

                int the_Vector = Select3D.rotVector;

                Rotate3D.selection(x0, y0, z0, r, the_Vector);

                SOLARCHVISION_model_changed();
              }

              if (WIN3D.UI_CurrentTask == UITASK.Scale) { // scale

                float s = pow(pow(2.0, 0.25), Wheel_Value);

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


              if (WIN3D.UI_CurrentTask == UITASK.Move) { // move

                float d = Wheel_Value;

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



              if (WIN3D.UI_TaskModifyParameter == 0) {
                if (WIN3D.UI_CurrentTask >= UITASK.Seed_Material) { // other properties

                  int p = int(Wheel_Value);

                  Edit3D.selection(p);

                  SOLARCHVISION_model_changed();
                }
              }





              if ((WIN3D.UI_CurrentTask == UITASK.Zoom_Orbit_Pan) ||
                  (WIN3D.UI_CurrentTask == UITASK.CameraRoll_Pan) ||
                  (WIN3D.UI_CurrentTask == UITASK.TargetRoll_Pan) ||
                  (WIN3D.UI_CurrentTask == UITASK.Pan_TargetRoll)) { // viewport:zoom

                if (WIN3D.ViewType == 1) {
                  WIN3D.position_Z -= Wheel_Value * WIN3D.position_T * OBJECTS_scale;
                } else {
                  WIN3D.Zoom *= pow(2.0, Wheel_Value);
                }

                SOLARCHVISION_view_changed();
              }

              if (WIN3D.UI_CurrentTask == UITASK.Pan_Height) { // viewport:elevation

                if (Wheel_Value > 0) WIN3D.Zoom = 2 * funcs.atan_ang((1.1 / 1.0) * funcs.tan_ang(0.5 * WIN3D.Zoom));
                if (Wheel_Value < 0) WIN3D.Zoom = 2 * funcs.atan_ang((1.0 / 1.1) * funcs.tan_ang(0.5 * WIN3D.Zoom));

                SOLARCHVISION_view_changed();
              }

              if (WIN3D.UI_CurrentTask == UITASK.ModelSize_Pan_TargetRoll) { // viewport:3DModelSize

                if (Wheel_Value > 0) OBJECTS_scale /= pow(2.0, 0.25);
                if (Wheel_Value < 0) OBJECTS_scale *= pow(2.0, 0.25);

                SOLARCHVISION_view_changed();
              }

              if (WIN3D.UI_CurrentTask == UITASK.Truck_Orbit) { // viewport:different functions with wheel

                if (WIN3D.UI_TaskModifyParameter == 0) { // Truck

                  if (WIN3D.UI_OptionXorY == 0) {

                    WIN3D.position_X += Wheel_Value * WIN3D.position_T * OBJECTS_scale;

                    SOLARCHVISION_view_changed();
                  }

                  if (WIN3D.UI_OptionXorY == 1) {

                    WIN3D.position_Y += Wheel_Value * WIN3D.position_T * OBJECTS_scale;

                    SOLARCHVISION_view_changed();
                  }
                }


                if (WIN3D.UI_TaskModifyParameter == 1) {  // Orbit

                  if (WIN3D.UI_OptionXorY == 0) {

                    WIN3D.rotation_X += Wheel_Value * WIN3D.rotation_T;

                    SOLARCHVISION_view_changed();
                  }

                  if (WIN3D.UI_OptionXorY == 1) {

                    WIN3D.rotation_Z += Wheel_Value * WIN3D.rotation_T;

                    SOLARCHVISION_view_changed();
                  }
                }

              }


              if (WIN3D.UI_CurrentTask == UITASK.SkydomeSize) { // viewport:different functions with wheel

                if (WIN3D.UI_TaskModifyParameter == 0) { // SkydomeSize

                  if (Wheel_Value > 0) Sky3D.scale *= pow(2.0, 0.25);
                  if (Wheel_Value < 0) Sky3D.scale /= pow(2.0, 0.25);

                  SOLARCHVISION_view_changed();
                }
              }

              if (WIN3D.UI_CurrentTask == UITASK.AllModelSize) { // viewport:different functions with wheel

                if (WIN3D.UI_TaskModifyParameter == 0) { // AllModelSize

                  if (Wheel_Value > 0) {
                    OBJECTS_scale /= pow(2.0, 0.25);
                    Sky3D.scale /= pow(2.0, 0.25);
                  }

                  if (Wheel_Value < 0) {
                    OBJECTS_scale *= pow(2.0, 0.25);
                    Sky3D.scale *= pow(2.0, 0.25);
                  }

                  SOLARCHVISION_view_changed();
                }
              }

              if (WIN3D.UI_CurrentTask == UITASK.TargetRollXY_TargetRollZ) { // viewport:TargetRollXY/TargetRoolZ

                if (WIN3D.UI_OptionXorY == 0) {
                  WIN3D.rotation_X += Wheel_Value * WIN3D.rotation_T;

                  WIN3D.reverseTransform_3DViewport();
                }

                if (WIN3D.UI_OptionXorY == 1) {
                  WIN3D.rotation_Z += Wheel_Value * WIN3D.rotation_T;

                  WIN3D.reverseTransform_3DViewport();
                }

                SOLARCHVISION_view_changed();
              }

              if (WIN3D.UI_CurrentTask == UITASK.CameraRollXY_CameraRollZ) { // viewport:CameraRollXY/CameraRoolZ

                if (WIN3D.UI_OptionXorY == 0) {

                  WIN3D.rotateZ_3DViewport_around_Selection(Wheel_Value * WIN3D.rotation_T);
                }

                if (WIN3D.UI_OptionXorY == 1) {

                  WIN3D.rotateXY_3DViewport_around_Selection(Wheel_Value * WIN3D.rotation_T);
                }

                SOLARCHVISION_view_changed();
              }

              if (WIN3D.UI_CurrentTask == UITASK.CameraDistance_TargetRollXY_TargetRollZ) { // viewport:CameraDistance

                WIN3D.move_3DViewport_towards_Selection(pow(2, 0.5 * Wheel_Value));

                SOLARCHVISION_view_changed();
              }

              if (WIN3D.UI_CurrentTask == UITASK.PanX_TargetRollXY_TargetRollZ) { // viewport:PanX

                WIN3D.position_X += Wheel_Value * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }

              if (WIN3D.UI_CurrentTask == UITASK.PanY_TargetRollXY_TargetRollZ) { // viewport:PanY

                WIN3D.position_Y += Wheel_Value * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }

              if ((WIN3D.UI_CurrentTask == UITASK.DistMouseXY_TargetRollXY_TargetRollZ) ||
                  (WIN3D.UI_CurrentTask == UITASK.PickSelect)) { // viewport:DistMouseXY

                WIN3D.move_3DViewport_towards_Mouse(pow(2, 0.5 * Wheel_Value));

                SOLARCHVISION_view_changed();
              }

              if (WIN3D.UI_CurrentTask == UITASK.LandOrbit_Pan_TargetRollZ) { // viewport:LandOrbit

                WIN3D.move_3DViewport_towards_Mouse(pow(2, 0.5 * Wheel_Value));

                SOLARCHVISION_view_changed();
              }



            }
          }
        }
      }
    }
  }
}


int dragging_started = 0;

void mouseReleased () {

  if (frameCount > Last_initializationStep) {

    if (SOLARCHVISION_automated == 0) {

      if (dragging_started != 0) {

        SOLARCHVISION_X_click2 = mouseX;
        SOLARCHVISION_Y_click2 = mouseY;

        int swap_tmp = 0;

        if (SOLARCHVISION_X_click2 < SOLARCHVISION_X_click1) {
          swap_tmp = SOLARCHVISION_X_click2;
          SOLARCHVISION_X_click2 = SOLARCHVISION_X_click1;
          SOLARCHVISION_X_click1 = swap_tmp;
        }

        if (SOLARCHVISION_Y_click2 < SOLARCHVISION_Y_click1) {
          swap_tmp = SOLARCHVISION_Y_click2;
          SOLARCHVISION_Y_click2 = SOLARCHVISION_Y_click1;
          SOLARCHVISION_Y_click1 = swap_tmp;
        }

        if (FRAME_drag_IMG) {

          SOLARCHVISION_RecordFrame();

          strokeWeight(2);
          if (mouseButton == RIGHT) {
            noStroke();
            fill(127, 127);
          } else {
            stroke(255, 0, 0);
            noFill();
          }

          rect(SOLARCHVISION_X_click1, SOLARCHVISION_Y_click1, SOLARCHVISION_X_click2 - SOLARCHVISION_X_click1, SOLARCHVISION_Y_click2 - SOLARCHVISION_Y_click1);
          strokeWeight(0);

          SOLARCHVISION_RecordFrame();

          SOLARCHVISION_view_changed();
          WORLD.revise();
          STUDY.revise();
          ROLLOUT.revise();
          UI_menuBar.revise();
          UI_toolBar.revise();
          UI_caseBar.revise();

          FRAME_drag_IMG = false;

          dragging_started = 0;
        } else {

          if (WIN3D.include) {
            if (isInside(mouseX, mouseY, WIN3D.cX, WIN3D.cY, WIN3D.cX + WIN3D.dX, WIN3D.cY + WIN3D.dY)) {

              if ((WIN3D.UI_CurrentTask == UITASK.RectSelect) ||
                  (WIN3D.UI_CurrentTask > UITASK.Move)) { // RectSelect also if scale, rotate, modify, etc. where selected

                float corner1x = SOLARCHVISION_X_click1 - 0.5 * WIN3D.dX - WIN3D.cX;
                float corner1y = SOLARCHVISION_Y_click1 - 0.5 * WIN3D.dY - WIN3D.cY;

                float corner2x = SOLARCHVISION_X_click2 - 0.5 * WIN3D.dX - WIN3D.cX;
                float corner2y = SOLARCHVISION_Y_click2 - 0.5 * WIN3D.dY - WIN3D.cY;

                pushMatrix();

                translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

                noFill();

                stroke(127);
                strokeWeight(2);

                rect(corner1x, corner1y, corner2x - corner1x, corner2y - corner1y);

                popMatrix();

                Select3D.selectRect(corner1x, corner1y, corner2x, corner2y);
              }


              if (WIN3D.UI_CurrentTask == UITASK.GetLength) {

                float x1 = 0;
                float y1 = 0;
                float z1 = 0;

                float x2 = 0;
                float y2 = 0;
                float z2 = 0;

                for (int q = 0; q < 2; q++) {

                  float Image_X = 0;
                  float Image_Y = 0;

                  if (q == 0) {
                    Image_X = SOLARCHVISION_X_click1 - (WIN3D.cX + 0.5 * WIN3D.dX);
                    Image_Y = SOLARCHVISION_Y_click1 - (WIN3D.cY + 0.5 * WIN3D.dY);
                  }
                  if (q == 1) {
                    Image_X = SOLARCHVISION_X_click2 - (WIN3D.cX + 0.5 * WIN3D.dX);
                    Image_Y = SOLARCHVISION_Y_click2 - (WIN3D.cY + 0.5 * WIN3D.dY);
                  }

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
                    RxP = SOLARCHVISION_snap_Faces(allFaces.intersect(ray_start, ray_direction));
                  }

                  if (RxP[0] >= 0) {
                    if (q == 0) {
                      x1 = RxP[1];
                      y1 = RxP[2];
                      z1 = RxP[3];
                    }
                    if (q == 1) {
                      x2 = RxP[1];
                      y2 = RxP[2];
                      z2 = RxP[3];
                    }
                  }
                }

                float dx = x2 - x1;
                float dy = y2 - y1;
                float dz = z2 - z1;

                float dx_rot = dx * funcs.cos_ang(-WIN3D.rotation_Z) - dy * funcs.sin_ang(-WIN3D.rotation_Z);
                float dy_rot = dx * funcs.sin_ang(-WIN3D.rotation_Z) + dy * funcs.cos_ang(-WIN3D.rotation_Z);
                float dz_rot = dz;

                if (WIN3D.UI_TaskModifyParameter == 0) {
                  User3D.create_Length = dist(x1, y1, z1, x2, y2, z2);
                }
                if (WIN3D.UI_TaskModifyParameter == 1) {
                  User3D.create_Width = dist(x1, y1, z1, x2, y2, z2);
                }
                if (WIN3D.UI_TaskModifyParameter == 2) {
                  User3D.create_Height = dist(x1, y1, z1, x2, y2, z2);
                }
                if (WIN3D.UI_TaskModifyParameter == 3) {
                  User3D.create_Length = abs(dx_rot);
                  User3D.create_Width = abs(dy_rot);
                  User3D.create_Height = abs(dz_rot);
                }
                if (WIN3D.UI_TaskModifyParameter == 4) {
                  User3D.create_Length = abs(dx_rot);
                  User3D.create_Width = abs(dy_rot);
                }
                if (WIN3D.UI_TaskModifyParameter == 5) {
                  User3D.create_Orientation = funcs.atan2_ang(y2 - y1, x2 - x1) + 90;
                }

                ROLLOUT.revise();
              }
            }
          }

          dragging_started = 0;
        }
      }
    }
  }
}

void mouseDragged () {

  if (frameCount > Last_initializationStep) {

    if (SOLARCHVISION_automated == 0) {

      if (FRAME_drag_IMG) {
        if (dragging_started == 0) {
          SOLARCHVISION_X_click1 = pmouseX;
          SOLARCHVISION_Y_click1 = pmouseY;

          dragging_started = 1;
        }
      } else if (WIN3D.include) {
        if (isInside(pmouseX, pmouseY, WIN3D.cX, WIN3D.cY, WIN3D.cX + WIN3D.dX, WIN3D.cY + WIN3D.dY)) {
          if (isInside(mouseX, mouseY, WIN3D.cX, WIN3D.cY, WIN3D.cX + WIN3D.dX, WIN3D.cY + WIN3D.dY)) {

            if (dragging_started == 0) {

              SOLARCHVISION_X_click1 = pmouseX;
              SOLARCHVISION_Y_click1 = pmouseY;

              dragging_started = 1;
            }

            float dx = (mouseX - pmouseX) / float(WIN3D.dX);
            float dy = (mouseY - pmouseY) / float(WIN3D.dY);

            if (WIN3D.UI_CurrentTask == UITASK.LandOrbit_Pan_TargetRollZ) { // viewport

              if (mouseButton == LEFT) { // CameraLandOrbit

                WIN3D.rotateXY_3DViewport_around_LandIntersection(10 * dx * WIN3D.rotation_T);

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // Pan

                WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;
                WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }
            }

            if ((WIN3D.UI_CurrentTask == UITASK.PanX_TargetRollXY_TargetRollZ) ||
                (WIN3D.UI_CurrentTask == UITASK.PanY_TargetRollXY_TargetRollZ)) { // viewport

              if (mouseButton == LEFT) { // CameraRollXY

                WIN3D.rotateXY_3DViewport_around_Selection(10 * dx * WIN3D.rotation_T);

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // CameraRollZ

                WIN3D.rotateZ_3DViewport_around_Selection(10 * dy * WIN3D.rotation_T);

                SOLARCHVISION_view_changed();
              }
            }

            if ((WIN3D.UI_CurrentTask == UITASK.Pan_TargetRoll) ||
                (WIN3D.UI_CurrentTask == UITASK.DistMouseXY_TargetRollXY_TargetRollZ) ||
                (WIN3D.UI_CurrentTask == UITASK.PickSelect)) { // viewport

              if (mouseButton == LEFT) { // Pan

                WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;
                WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // TargetRoll

                WIN3D.rotation_Z += 10 * dx * WIN3D.rotation_T;
                WIN3D.rotation_X += 10 * dy * WIN3D.rotation_T;

                WIN3D.reverseTransform_3DViewport();

                SOLARCHVISION_view_changed();
              }
            }

            if ((WIN3D.UI_CurrentTask == UITASK.CameraRoll_Pan) ||
                (WIN3D.UI_CurrentTask == UITASK.CameraDistance_TargetRollXY_TargetRollZ)) { // viewport

              if (mouseButton == LEFT) { // CameraRoll

                WIN3D.rotateXY_3DViewport_around_Selection(10 * dx * WIN3D.rotation_T);

                WIN3D.rotateZ_3DViewport_around_Selection(10 * dy * WIN3D.rotation_T);

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // Pan

                WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;
                WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }
            }

            if (WIN3D.UI_CurrentTask == UITASK.CameraRollXY_CameraRollZ) { // viewport

              if (mouseButton == LEFT) { // CameraRollXY

                WIN3D.rotateXY_3DViewport_around_Selection(10 * dx * WIN3D.rotation_T);

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // CameraRollZ

                WIN3D.rotateZ_3DViewport_around_Selection(10 * dy * WIN3D.rotation_T);

                SOLARCHVISION_view_changed();
              }
            }

            if (WIN3D.UI_CurrentTask == UITASK.TargetRoll_Pan) { // viewport

              if (mouseButton == LEFT) { // TargetRoll

                WIN3D.rotation_Z += 10 * dx * WIN3D.rotation_T;
                WIN3D.rotation_X += 10 * dy * WIN3D.rotation_T;

                WIN3D.reverseTransform_3DViewport();

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // Pan

                WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;
                WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }
            }

            if (WIN3D.UI_CurrentTask == UITASK.TargetRollXY_TargetRollZ) { // viewport

              if (mouseButton == LEFT) { // TargetRollXY

                WIN3D.rotation_Z += 10 * dx * WIN3D.rotation_T;

                WIN3D.reverseTransform_3DViewport();

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // TargetRollZ

                WIN3D.rotation_X += 10 * dy * WIN3D.rotation_T;

                WIN3D.reverseTransform_3DViewport();

                SOLARCHVISION_view_changed();
              }
            }

            if ((WIN3D.UI_CurrentTask == UITASK.Zoom_Orbit_Pan) ||
                (WIN3D.UI_CurrentTask == UITASK.SkydomeSize) ||
                (WIN3D.UI_CurrentTask == UITASK.AllModelSize)) { // viewport

              if (mouseButton == LEFT) { // orbit

                WIN3D.rotation_Z -= 10 * dx * WIN3D.rotation_T;
                WIN3D.rotation_X -= 10 * dy * WIN3D.rotation_T;

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // Pan

                WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;
                WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }
            }

            if (WIN3D.UI_CurrentTask == UITASK.Pan_Height) {

              if (mouseButton == LEFT) { // move Y

                WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // move X

                WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }
            }

            if (WIN3D.UI_CurrentTask == UITASK.ModelSize_Pan_TargetRoll) { // viewport

              if (mouseButton == LEFT) { // Pan

                WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;
                WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // TargetRoll

                WIN3D.rotation_Z += 10 * dx * WIN3D.rotation_T;
                WIN3D.rotation_X += 10 * dy * WIN3D.rotation_T;

                WIN3D.reverseTransform_3DViewport();

                SOLARCHVISION_view_changed();
              }
            }

            if (WIN3D.UI_CurrentTask == UITASK.Truck_Orbit) { // viewport:different functions

              if (WIN3D.UI_TaskModifyParameter == 0) { // Truck

                if (WIN3D.UI_OptionXorY == 0) {
                  if (mouseButton == LEFT) WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;
                  if (mouseButton == RIGHT) WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                  SOLARCHVISION_view_changed();
                }

                if (WIN3D.UI_OptionXorY == 1) {
                  if (mouseButton == RIGHT) WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;
                  if (mouseButton == LEFT) WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                  SOLARCHVISION_view_changed();
                }
              }


              if (WIN3D.UI_TaskModifyParameter == 1) {  // Orbit

                if (WIN3D.UI_OptionXorY == 0) {
                  if (mouseButton == LEFT) WIN3D.rotation_X -= 10 * dy * WIN3D.rotation_T;
                  if (mouseButton == RIGHT) WIN3D.rotation_Z -= 10 * dx * WIN3D.rotation_T;

                  SOLARCHVISION_view_changed();
                }

                if (WIN3D.UI_OptionXorY == 1) {
                  if (mouseButton == RIGHT) WIN3D.rotation_X -= 10 * dy * WIN3D.rotation_T;
                  if (mouseButton == LEFT) WIN3D.rotation_Z -= 10 * dx * WIN3D.rotation_T;

                  SOLARCHVISION_view_changed();
                }
              }


            }
          }
        }
      }
    }
  }
}


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
              SOLARCHVISION_update_ENSEMBLE_OBSERVED();
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
              SOLARCHVISION_update_ENSEMBLE_OBSERVED();

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

              for (int f = 0; f < NAEFposition_Ts.length; f++) {

                float _lat = NAEFposition_Ts[f].getLatitude();
                float _lon = NAEFposition_Ts[f].getLongitude();
                if (_lon > 180) _lon -= 360; // << important!

                float d = funcs.lon_lat_dist(_lon, _lat, STATION.getLongitude(), STATION.getLatitude());

                if (nearest_WORLD_NAEFS_dist > d) {
                  nearest_WORLD_NAEFS_dist = d;
                  nearest_WORLD_NAEFS = f;
                }
              }

              {
                int f = nearest_WORLD_NAEFS;

                if (STATION.getFilename_NAEFS().equals(NAEFposition_Ts[f].getFilename_NAEFS())) {
                } else {

                  STATION.setLatitude(mouse_lat);
                  STATION.setLongitude(mouse_lon);

                  STATION.setFilename_NAEFS(NAEFposition_Ts[f].getFilename_NAEFS()); // naefs filename

                  println("nearest naefs filename:", NAEFposition_Ts[f].getFilename_NAEFS());

                  if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
                    STATION.setCity(NAEFposition_Ts[f].getCity());
                    STATION.setProvince(NAEFposition_Ts[f].getProvince());
                    STATION.setCountry(NAEFposition_Ts[f].getCountry());

                    //STATION.setLatitude(NAEFposition_Ts[f].getLatitude());
                    //STATION.setLongitude(NAEFposition_Ts[f].getLongitude());
                    STATION.setElevation(NAEFposition_Ts[f].getElevation());
                    STATION.setTimelong(NAEFposition_Ts[f].getTimelong());

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

boolean isInside (float x, float y, float x1, float y1, float x2, float y2) {
  if ((x1 < x) && (x < x2) && (y1 < y) && (y < y2)) {
    return true;
  }
  return false;
}


void SOLARCHVISION_draw_Perspective_Internally () {

  if (current_ObjectCategory == ObjectCategory.LANDPOINT) {

    if (Select3D.LandPoint_displayPoints) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(255, 0, 255, 127);

      strokeWeight(2);

      ellipseMode(CENTER);

      float R = 10;

      for (int o = Select3D.LandPoint_ids.length - 1; o >= 0; o--) {

        int OBJ_ID = Select3D.LandPoint_ids[o];


        int i = OBJ_ID / Land3D.num_columns;
        int j = OBJ_ID % Land3D.num_columns;

        float x = Land3D.Mesh[i][j][0] * OBJECTS_scale;
        float y = Land3D.Mesh[i][j][1] * OBJECTS_scale;
        float z = -Land3D.Mesh[i][j][2] * OBJECTS_scale;

        float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

        if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
          if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX + R, -0.5 * WIN3D.dY + R, 0.5 * WIN3D.dX - R, 0.5 * WIN3D.dY - R)) ellipse(Image_XYZ[0], Image_XYZ[1], R, R);
        }

      }

      strokeWeight(0);

      popMatrix();
    }
  }

  if (current_ObjectCategory == ObjectCategory.CAMERA) {

    if (Select3D.Camera_displayEdges) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(255, 127, 0);
      strokeWeight(2);

      {
        for (int o = Select3D.Camera_ids.length - 1; o >= 0; o--) {

          int f = Select3D.Camera_ids[o];

          beginShape();

          for (int j = 0; j < allCameras.Faces[f].length; j++) {

            int vNo = allCameras.Faces[f][j];

            float x = allCameras.Vertices[vNo][0] * OBJECTS_scale;
            float y = allCameras.Vertices[vNo][1] * OBJECTS_scale;
            float z = -allCameras.Vertices[vNo][2] * OBJECTS_scale;

            float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

            if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
              if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
            }
          }

          endShape(CLOSE);
        }
      }

      strokeWeight(0);

      popMatrix();
    }
  }

  if (current_ObjectCategory == ObjectCategory.SECTION) {

    if (Select3D.Section_displayEdges) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(255, 127, 0);
      strokeWeight(2);

      {
        for (int o = Select3D.Section_ids.length - 1; o >= 0; o--) {

          int f = Select3D.Section_ids[o];

          beginShape();

          for (int j = 0; j < allSections.Faces[f].length; j++) {

            int vNo = allSections.Faces[f][j];

            float x = allSections.Vertices[vNo][0] * OBJECTS_scale;
            float y = allSections.Vertices[vNo][1] * OBJECTS_scale;
            float z = -allSections.Vertices[vNo][2] * OBJECTS_scale;

            float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

            if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
              if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
            }
          }

          endShape(CLOSE);
        }
      }

      strokeWeight(0);

      popMatrix();
    }
  }

  if (current_ObjectCategory == ObjectCategory.SOLID) {

    if (Select3D.Solid_displayEdges) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(255, 127, 0);
      strokeWeight(2);

      {
        for (int o = Select3D.Solid_ids.length - 1; o >= 0; o--) {

          int OBJ_ID = Select3D.Solid_ids[o];

          for (int plane_type = 0; plane_type < allSolids.num_visualFaces; plane_type++) {

            int f = OBJ_ID * allSolids.num_visualFaces + plane_type;

            beginShape();

            for (int j = 0; j < allSolids.Faces[f].length; j++) {

              int vNo = allSolids.Faces[f][j];

              float x = allSolids.Vertices[vNo][0] * OBJECTS_scale;
              float y = allSolids.Vertices[vNo][1] * OBJECTS_scale;
              float z = -allSolids.Vertices[vNo][2] * OBJECTS_scale;

              float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

              if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
                if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
              }
            }

            endShape(CLOSE);
          }
        }

      }


      strokeWeight(0);

      popMatrix();
    }
  }

  if (current_ObjectCategory == ObjectCategory.MODEL2D) {

    if (Select3D.Model2D_displayEdges) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(255, 127, 0);
      strokeWeight(2);

      {
        for (int o = Select3D.Model2D_ids.length - 1; o >= 0; o--) {

          int OBJ_ID = Select3D.Model2D_ids[o];

          for (int plane_type = 0; plane_type < allModel2Ds.num_visualFaces; plane_type++) {

            int f = OBJ_ID * allModel2Ds.num_visualFaces + plane_type;

            beginShape();

            for (int j = 0; j < allModel2Ds.Faces[f].length; j++) {

              int vNo = allModel2Ds.Faces[f][j];

              float x = allModel2Ds.Vertices[vNo][0] * OBJECTS_scale;
              float y = allModel2Ds.Vertices[vNo][1] * OBJECTS_scale;
              float z = -allModel2Ds.Vertices[vNo][2] * OBJECTS_scale;

              float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

              if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
                if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
              }
            }

            endShape(CLOSE);
          }
        }
      }

      strokeWeight(0);

      popMatrix();
    }
  }

  if (current_ObjectCategory == ObjectCategory.MODEL1D) {

    if (Select3D.Model1D_displayEdges) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(255, 127, 0);
      strokeWeight(2);

      {
        for (int o = Select3D.Model1D_ids.length - 1; o >= 0; o--) {

          int f = Select3D.Model1D_ids[o];

          beginShape();

          for (int j = 0; j < allModel1Ds.Faces[f].length; j++) {

            int vNo = allModel1Ds.Faces[f][j];

            float x = allModel1Ds.Vertices[vNo][0] * OBJECTS_scale;
            float y = allModel1Ds.Vertices[vNo][1] * OBJECTS_scale;
            float z = -allModel1Ds.Vertices[vNo][2] * OBJECTS_scale;

            float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

            if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
              if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
            }
          }

          endShape(CLOSE);

        }
      }

      strokeWeight(0);

      popMatrix();
    }
  }

  if (current_ObjectCategory == ObjectCategory.FACE) {

    if (Select3D.Face_displayEdges) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(127, 0, 255);
      strokeWeight(2);

      for (int o = Select3D.Face_ids.length - 1; o >= 0; o--) {

        int f = Select3D.Face_ids[o];

        int tessellation = allFaces.getTessellation(f);

        int totalNumberOfSubs = 1;
        if (allFaces.getMaterial(f) == 0) {
          tessellation += allFaces.displayTessellation;
        }
        if (tessellation > 0) totalNumberOfSubs = allFaces.nodes[f].length * int(funcs.roundTo(pow(4, tessellation - 1), 1));

        float[][] base_Vertices = new float [allFaces.nodes[f].length][3];
        for (int j = 0; j < allFaces.nodes[f].length; j++) {
          int vNo = allFaces.nodes[f][j];
          base_Vertices[j][0] = allPoints.getX(vNo);
          base_Vertices[j][1] = allPoints.getY(vNo);
          base_Vertices[j][2] = allPoints.getZ(vNo);
        }

        for (int n = 0; n < totalNumberOfSubs; n++) {

          float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

          beginShape();

          for (int s = 0; s < subFace.length; s++) {

            float x = subFace[s][0] * OBJECTS_scale;
            float y = subFace[s][1] * OBJECTS_scale;
            float z = -subFace[s][2] * OBJECTS_scale;

            float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

            if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
              if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
            }
          }

          endShape(CLOSE);
        }

      }

      strokeWeight(0);

      popMatrix();
    }


    if (Select3D.Face_displayVertexCount) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      fill(0);

      stroke(0);
      strokeWeight(0);

      textSize(1.5 * MessageSize);
      textAlign(CENTER, BOTTOM);

      for (int o = Select3D.Face_ids.length - 1; o >= 0; o--) {

        int f = Select3D.Face_ids[o];

        for (int j = 0; j < allFaces.nodes[f].length; j++) {
          int vNo = allFaces.nodes[f][j];

          float x = allPoints.getX(vNo) * OBJECTS_scale;
          float y = allPoints.getY(vNo) * OBJECTS_scale;
          float z = -allPoints.getZ(vNo) * OBJECTS_scale;

          float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

          if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
            if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) {
              text(nf(j + 1, 0), Image_XYZ[0], Image_XYZ[1]);
            }
          }
        }
      }

      strokeWeight(0);

      popMatrix();
    }
  }


  if (current_ObjectCategory == ObjectCategory.POLYLINE) {

    if (Select3D.Polyline_displayVertexCount) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      fill(0);

      stroke(0);
      strokeWeight(0);

      textSize(1.5 * MessageSize);
      textAlign(CENTER, BOTTOM);

      for (int o = Select3D.Polyline_ids.length - 1; o >= 0; o--) {

        int f = Select3D.Polyline_ids[o];

        for (int j = 0; j < allPolylines.nodes[f].length; j++) {
          int vNo = allPolylines.nodes[f][j];

          float x = allPoints.getX(vNo) * OBJECTS_scale;
          float y = allPoints.getY(vNo) * OBJECTS_scale;
          float z = -allPoints.getZ(vNo) * OBJECTS_scale;

          float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

          if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
            if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) {
              text(nf(j + 1, 0), Image_XYZ[0], Image_XYZ[1]);
            }
          }
        }
      }

      strokeWeight(0);

      popMatrix();
    }
  }


  if (current_ObjectCategory == ObjectCategory.VERTEX) {

    if (Select3D.Vertex_displayVertices) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(255, 0, 255, 127);

      strokeWeight(2);

      ellipseMode(CENTER);

      float R = 10;

      for (int o = Select3D.Vertex_ids.length - 1; o >= 0; o--) {

        int vNo = Select3D.Vertex_ids[o];

        float x = allPoints.getX(vNo) * OBJECTS_scale;
        float y = allPoints.getY(vNo) * OBJECTS_scale;
        float z = -allPoints.getZ(vNo) * OBJECTS_scale;

        float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

        if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
          if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX + R, -0.5 * WIN3D.dY + R, 0.5 * WIN3D.dX - R, 0.5 * WIN3D.dY - R)) ellipse(Image_XYZ[0], Image_XYZ[1], R, R);
        }
      }

      strokeWeight(0);

      popMatrix();
    }
  }



  if (current_ObjectCategory == ObjectCategory.SOFTVERTEX) {

    if (Select3D.Vertex_displayVertices) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      strokeWeight(0);

      ellipseMode(CENTER);

      float R = 5;

      for (int q = 0; q < Select3D.softSelection_ids.length; q++) {

        int vNo = Select3D.softSelection_ids[q];

        float _u = Select3D.softSelection_values[q];

        float x = allPoints.getX(vNo) * OBJECTS_scale;
        float y = allPoints.getY(vNo) * OBJECTS_scale;
        float z = -allPoints.getZ(vNo) * OBJECTS_scale;

        float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

        if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
          if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX + R, -0.5 * WIN3D.dY + R, 0.5 * WIN3D.dX - R, 0.5 * WIN3D.dY - R)) {

            float[] COL = PAINT.getColorStyle(14, _u); // <<<<<<<<<<<<<<<<<
            fill(COL[1], COL[2], COL[3], COL[0]);
            stroke(COL[1], COL[2], COL[3], COL[0]);

            ellipse(Image_XYZ[0], Image_XYZ[1], R, R);
          }
        }
      }


      strokeWeight(0);

      popMatrix();
    }
  }



  if (current_ObjectCategory == ObjectCategory.GROUP) {

    if (Select3D.Group_displayEdges) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(127);
      strokeWeight(2);

      for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

        int OBJ_ID = Select3D.Group_ids[o];


        for (int f = allGroups.getStart_Face(OBJ_ID); f <= allGroups.getStop_Face(OBJ_ID); f++) {
          if ((0 <= f) && (f < allFaces.nodes.length)) {

            int tessellation = allFaces.getTessellation(f);

            int totalNumberOfSubs = 1;
            if (allFaces.getMaterial(f) == 0) {
              tessellation += allFaces.displayTessellation;
            }
            if (tessellation > 0) totalNumberOfSubs = allFaces.nodes[f].length * int(funcs.roundTo(pow(4, tessellation - 1), 1));

            float[][] base_Vertices = new float [allFaces.nodes[f].length][3];
            for (int j = 0; j < allFaces.nodes[f].length; j++) {
              int vNo = allFaces.nodes[f][j];
              base_Vertices[j][0] = allPoints.getX(vNo);
              base_Vertices[j][1] = allPoints.getY(vNo);
              base_Vertices[j][2] = allPoints.getZ(vNo);
            }

            for (int n = 0; n < totalNumberOfSubs; n++) {

              float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

              beginShape();

              for (int s = 0; s < subFace.length; s++) {

                float x = subFace[s][0] * OBJECTS_scale;
                float y = subFace[s][1] * OBJECTS_scale;
                float z = -subFace[s][2] * OBJECTS_scale;

                float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

                if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
                  if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
                }
              }

              endShape(CLOSE);
            }
          }
        }


        for (int f = allGroups.getStart_Polyline(OBJ_ID); f <= allGroups.getStop_Polyline(OBJ_ID); f++) {
          if ((0 <= f) && (f < allPolylines.nodes.length)) {

            beginShape();

            for (int vNo = 0; vNo < allPolylines.nodes[f].length; vNo++) {

              float x = allPoints.getX(vNo) * OBJECTS_scale;
              float y = allPoints.getY(vNo) * OBJECTS_scale;
              float z = -allPoints.getZ(vNo) * OBJECTS_scale;

              float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

              if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
                if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
              }
            }

            endShape(CLOSE);
          }
        }


        for (int f = allGroups.getStart_Model1D(OBJ_ID); f <= allGroups.getStop_Model1D(OBJ_ID); f++) {

          if ((0 <= f) && (f < allModel1Ds.Faces.length)) {

            beginShape();

            for (int j = 0; j < allModel1Ds.Faces[f].length; j++) {

              int vNo = allModel1Ds.Faces[f][j];

              float x = allModel1Ds.Vertices[vNo][0] * OBJECTS_scale;
              float y = allModel1Ds.Vertices[vNo][1] * OBJECTS_scale;
              float z = -allModel1Ds.Vertices[vNo][2] * OBJECTS_scale;

              float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

              if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
                if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
              }
            }

            endShape(CLOSE);
          }
        }


        for (int f = allGroups.getStart_Model2D(OBJ_ID); f <= allGroups.getStop_Model2D(OBJ_ID); f++) {

          if ((0 <= f) && (f < allModel2Ds.Faces.length)) {

            beginShape();

            for (int j = 0; j < allModel2Ds.Faces[f].length; j++) {

              int vNo = allModel2Ds.Faces[f][j];

              float x = allModel2Ds.Vertices[vNo][0] * OBJECTS_scale;
              float y = allModel2Ds.Vertices[vNo][1] * OBJECTS_scale;
              float z = -allModel2Ds.Vertices[vNo][2] * OBJECTS_scale;

              float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

              if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
                if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
              }
            }

            endShape(CLOSE);
          }
        }

        for (int q = allGroups.getStart_Solid(OBJ_ID); q <= allGroups.getStop_Solid(OBJ_ID); q++) {

          if ((0 < q) && (q < allSolids.Faces.length)) {

            for (int plane_type = 0; plane_type < allSolids.num_visualFaces; plane_type++) {

              int f = (q - 1) * allSolids.num_visualFaces + plane_type + 1;

              if ((0 <= f) && (f < allSolids.Faces.length)) {

                beginShape();

                for (int j = 0; j < allSolids.Faces[f].length; j++) {

                  int vNo = allSolids.Faces[f][j];

                  float x = allSolids.Vertices[vNo][0] * OBJECTS_scale;
                  float y = allSolids.Vertices[vNo][1] * OBJECTS_scale;
                  float z = -allSolids.Vertices[vNo][2] * OBJECTS_scale;

                  float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

                  if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
                    if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
                  }
                }

                endShape(CLOSE);
              }
            }
          }
        }
      }


      strokeWeight(0);

      popMatrix();
    }


    if (Select3D.Group_displayBox) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(0, 127, 0, 127);
      strokeWeight(2);

      int keep_selection_alignX = Select3D.alignX;
      int keep_selection_alignY = Select3D.alignY;
      int keep_selection_alignZ = Select3D.alignZ;

      Select3D.alignX = 0; // apply the centre
      Select3D.alignY = 0; // apply the centre
      Select3D.alignZ = 0; // apply the centre

      float[] P = Select3D.getPivot();

      float posX = P[0];
      float posY = P[1];
      float posZ = P[2];

      float posX_min = Select3D.BoundingBox[0][0];
      float posY_min = Select3D.BoundingBox[0][1];
      float posZ_min = Select3D.BoundingBox[0][2];

      float posX_max = Select3D.BoundingBox[2][0];
      float posY_max = Select3D.BoundingBox[2][1];
      float posZ_max = Select3D.BoundingBox[2][2];

      float[][] BoundingBox_Vertices = {
        {
          posX_min, posY_min, posZ_min
        }
        ,
        {
          posX_max, posY_min, posZ_min
        }
        ,
        {
          posX_max, posY_max, posZ_min
        }
        ,
        {
          posX_min, posY_max, posZ_min
        }
        ,
        {
          posX_min, posY_min, posZ_max
        }
        ,
        {
          posX_max, posY_min, posZ_max
        }
        ,
        {
          posX_max, posY_max, posZ_max
        }
        ,
        {
          posX_min, posY_max, posZ_max
        }
      };


      for (int i = 0; i < BoundingBox_Vertices.length; i++) {

        float x = BoundingBox_Vertices[i][0] - posX;
        float y = BoundingBox_Vertices[i][1] - posY;
        float z = BoundingBox_Vertices[i][2] - posZ;

        float[] A = Select3D.translateInside_ReferencePivot(x, y, z);

        x = A[0];
        y = A[1];
        z = A[2];

        BoundingBox_Vertices[i][0] = x;
        BoundingBox_Vertices[i][1] = y;
        BoundingBox_Vertices[i][2] = z;
      }

      int[][] BoundingBox_Faces = {
        {
          3, 2, 1, 0
        }
        , {
          0, 1, 5, 4
        }
        , {
          1, 2, 6, 5
        }
        , {
          2, 3, 7, 6
        }
        , {
          3, 0, 4, 7
        }
        , {
          4, 5, 6, 7
        }
      };

      for (int f = 0; f < BoundingBox_Faces.length; f++) {

        beginShape();

        for (int g = 0; g < BoundingBox_Faces[f].length; g++) {

          int vNo = BoundingBox_Faces[f][g];

          float x = BoundingBox_Vertices[vNo][0] * OBJECTS_scale;
          float y = BoundingBox_Vertices[vNo][1] * OBJECTS_scale;
          float z = -BoundingBox_Vertices[vNo][2] * OBJECTS_scale;

          float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

          if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
            if (isInside(Image_XYZ[0], Image_XYZ[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) vertex(Image_XYZ[0], Image_XYZ[1]);
          }
        }
        endShape(CLOSE);
      }

      strokeWeight(0);

      popMatrix();


      Select3D.alignX = keep_selection_alignX;
      Select3D.alignY = keep_selection_alignY;
      Select3D.alignZ = keep_selection_alignZ;
    }




    if (Select3D.Group_displayPivot) {

      pushMatrix();

      translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

      noFill();

      stroke(255, 127, 0, 127);

      strokeWeight(5);

      for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

        int OBJ_ID = Select3D.Group_ids[o];

        float[][] Pivot_Vertices = {
          {
            0, 0, 0
          }
          ,
          {
            1, 0, 0
          }
          ,
          {
            0, 1, 0
          }
          ,
          {
            0, 0, 1
          }
        };


        float x0 = allGroups.Pivots[OBJ_ID][0];
        float y0 = allGroups.Pivots[OBJ_ID][1];
        float z0 = allGroups.Pivots[OBJ_ID][2];

        for (int i = 0; i < Pivot_Vertices.length; i++) {

          float x = Pivot_Vertices[i][0];
          float y = Pivot_Vertices[i][1];
          float z = Pivot_Vertices[i][2];

          float r = 10; // <<<<<<<<< display size

          x *= r;
          y *= r;
          z *= r;

          float[] O = Select3D.translateInside_ReferencePivot(0, 0, 0);
          float[] A = Select3D.translateInside_ReferencePivot(x, y, z);

          float dx = A[0] - O[0];
          float dy = A[1] - O[1];
          float dz = A[2] - O[2];

          Pivot_Vertices[i][0] = x0 + dx;
          Pivot_Vertices[i][1] = y0 + dy;
          Pivot_Vertices[i][2] = z0 + dz;
        }


        int[][] Pivot_Lines = {
          {
            0, 1
          }
          , {
            0, 2
          }
          , {
            0, 3
          }
        };

        int f_start = 0;
        int f_end = Pivot_Lines.length - 1;

        for (int f = f_start; f <= f_end; f++) {

          int a = Pivot_Lines[f][0];
          int b = Pivot_Lines[f][1];

          float x1 = Pivot_Vertices[a][0] * OBJECTS_scale;
          float y1 = Pivot_Vertices[a][1] * OBJECTS_scale;
          float z1 = -Pivot_Vertices[a][2] * OBJECTS_scale;

          float x2 = Pivot_Vertices[b][0] * OBJECTS_scale;
          float y2 = Pivot_Vertices[b][1] * OBJECTS_scale;
          float z2 = -Pivot_Vertices[b][2] * OBJECTS_scale;

          float[] Image_XYZa = WIN3D.calculate_Perspective_Internally(x1, y1, z1);
          float[] Image_XYZb = WIN3D.calculate_Perspective_Internally(x2, y2, z2);

          if ((Image_XYZa[2] > 0) && (Image_XYZb[2] > 0)) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
            if (isInside(Image_XYZa[0], Image_XYZa[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) {
              if (isInside(Image_XYZb[0], Image_XYZb[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) {
                line(Image_XYZa[0], Image_XYZa[1], Image_XYZb[0], Image_XYZb[1]);
              }
            }
          }
        }
      }


      strokeWeight(0);

      popMatrix();
    }
  }



  if (Select3D.displayReferencePivot) {

    pushMatrix();

    translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);

    noFill();

    strokeWeight(2);

    float[][] Pivot_Vertices = {
      {
        0, 0, 0
      }
      ,
      {
        1, 0, 0
      }
      ,
      {
        0, 1, 0
      }
      ,
      {
        0, 0, 1
      }
    };

    float[] P = Select3D.getPivot();

    float x0 = P[0];
    float y0 = P[1];
    float z0 = P[2];

    for (int i = 0; i < Pivot_Vertices.length; i++) {

      float x = Pivot_Vertices[i][0];
      float y = Pivot_Vertices[i][1];
      float z = Pivot_Vertices[i][2];

      float r = 5; // <<<<<<<<< display size

      x *= r;
      y *= r;
      z *= r;

      float[] O = Select3D.translateInside_ReferencePivot(0, 0, 0);
      float[] A = Select3D.translateInside_ReferencePivot(x, y, z);

      float dx = A[0] - O[0];
      float dy = A[1] - O[1];
      float dz = A[2] - O[2];

      Pivot_Vertices[i][0] = x0 + dx;
      Pivot_Vertices[i][1] = y0 + dy;
      Pivot_Vertices[i][2] = z0 + dz;
    }

    int[][] Pivot_Lines = {
      {
        0, 1
      }
      , {
        0, 2
      }
      , {
        0, 3
      }
    };


    for (int f = 0; f < Pivot_Lines.length; f++) {

      if (f == 0) stroke(255, 0, 0);
      if (f == 1) stroke(0, 0, 255);
      if (f == 2) stroke(127, 127, 0);

      int a = Pivot_Lines[f][0];
      int b = Pivot_Lines[f][1];

      float x1 = Pivot_Vertices[a][0] * OBJECTS_scale;
      float y1 = Pivot_Vertices[a][1] * OBJECTS_scale;
      float z1 = -Pivot_Vertices[a][2] * OBJECTS_scale;

      float x2 = Pivot_Vertices[b][0] * OBJECTS_scale;
      float y2 = Pivot_Vertices[b][1] * OBJECTS_scale;
      float z2 = -Pivot_Vertices[b][2] * OBJECTS_scale;

      float[] Image_XYZa = WIN3D.calculate_Perspective_Internally(x1, y1, z1);
      float[] Image_XYZb = WIN3D.calculate_Perspective_Internally(x2, y2, z2);

      if ((Image_XYZa[2] > 0) && (Image_XYZb[2] > 0)) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
        if (isInside(Image_XYZa[0], Image_XYZa[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) {
          if (isInside(Image_XYZb[0], Image_XYZb[1], -0.5 * WIN3D.dX, -0.5 * WIN3D.dY, 0.5 * WIN3D.dX, 0.5 * WIN3D.dY)) {
            line(Image_XYZa[0], Image_XYZa[1], Image_XYZb[0], Image_XYZb[1]);
          }
        }
      }
    }

    strokeWeight(0);

    popMatrix();
  }
}













String NearLatitude_Stamp () {

  int Round_Latitude = int(funcs.roundTo(STATION.getLatitude(), 5));
  if (Round_Latitude > 70) Round_Latitude = 70; // <<<<<<<<<<<<<<<
  if (Round_Latitude < -45) Round_Latitude = -45; // <<<<<<<<<<<<<<<

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


void mouseMoved () {

  if (frameCount > Last_initializationStep) {

    if (SOLARCHVISION_automated == 0) {

      if (UI_menuBar.selected_parent != -1) {

        if ((UI_X_moved != mouseX) || (UI_Y_moved != mouseY)) {

          UI_X_moved = mouseX;
          UI_Y_moved = mouseY;

          UI_menuBar.revise();

          redraw();
        }
      }
    }
  }
}



PImage pre_screen;




void SOLARCHVISION_modify_Viewport_Title () {

  String s = "Cam" + nf(WIN3D.currentCamera, 2);

  UI_toolBar.Items[0][11] = s; // <<<<< Note: 3DViewPoint is the first index on BAR_b
  UI_toolBar.highlight(s);

  UI_toolBar.revise();
}






void UI_set_to_Create_Nothing () {

  CreateObject = CREATE.Nothing;

  WIN3D.UI_CurrentTask = UITASK.Create;

  ROLLOUT.revise();
}


void UI_set_to_Create_allModel1Ds () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Model1Ds;
  SOLARCHVISION_switch_category(ObjectCategory.MODEL1D);
}


void UI_set_to_Create_Tree () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Plant;
  SOLARCHVISION_switch_category(ObjectCategory.MODEL2D);
}

void UI_set_to_Create_Person () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Person;
  SOLARCHVISION_switch_category(ObjectCategory.MODEL2D);
}

void UI_set_to_Create_Vertex () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Vertex;
  SOLARCHVISION_switch_category(ObjectCategory.VERTEX);
}

void UI_set_to_Create_Face () {
  UI_set_to_Create_Nothing();

  current_Material = User3D.default_Material;
  current_Tessellation = User3D.default_Tessellation;
  current_Layer = User3D.default_Layer;
  current_Visibility = User3D.default_Visibility;
  current_Weight = User3D.default_Weight;
  current_Closed = User3D.default_Closed;

  allFaces.beginNewFace();

  CreateObject = CREATE.Face;
  SOLARCHVISION_switch_category(ObjectCategory.FACE);
}

void UI_set_to_Create_Polyline () {
  UI_set_to_Create_Nothing();

  current_Material = User3D.default_Material;
  current_Tessellation = User3D.default_Tessellation;
  current_Layer = User3D.default_Layer;
  current_Visibility = User3D.default_Visibility;
  current_Weight = User3D.default_Weight;
  current_Closed = User3D.default_Closed;

  allPolylines.beginNewPolyline();

  CreateObject = CREATE.Polyline;
  SOLARCHVISION_switch_category(ObjectCategory.POLYLINE);
}

void UI_set_to_Create_Solid () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Solid;
  SOLARCHVISION_switch_category(ObjectCategory.SOLID);
}

void UI_set_to_Create_Section () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Section;
  SOLARCHVISION_switch_category(ObjectCategory.SECTION);
}


void UI_set_to_Create_Camera () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Camera;
  SOLARCHVISION_switch_category(ObjectCategory.CAMERA);
}






void UI_set_to_Create_Parametric (int n) {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Parametric;
  User3D.create_Parametric_Type = n;

  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Tri () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Tri;
  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Plane () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Plane;
  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Polygon () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Polygon;
  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Extrude () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Extrude;
  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Hyper () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.Hyper;
  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_House3 () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.House3;
  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_House2 () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.House2;
  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_House1 () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.House1;
  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Box () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.SuperOBJ;

  User3D.create_powX = CubePower;
  User3D.create_powY = CubePower;
  User3D.create_powZ = CubePower;

  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}


void UI_set_to_Create_Icosahedron () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.SuperOBJ;

  User3D.create_powX = 1;
  User3D.create_powY = 1;
  User3D.create_powZ = 1;

  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Octahedron () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.SuperOBJ;

  User3D.create_powX = 1;
  User3D.create_powY = 1;
  User3D.create_powZ = 1;

  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Sphere () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.SuperOBJ;

  User3D.create_powX = 2;
  User3D.create_powY = 2;
  User3D.create_powZ = 2;

  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Cylinder () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.SuperOBJ;

  User3D.create_powX = 2;
  User3D.create_powY = 2;
  User3D.create_powZ = CubePower;

  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}

void UI_set_to_Create_Cushion () {
  UI_set_to_Create_Nothing();

  CreateObject = CREATE.SuperOBJ;

  User3D.create_powX = CubePower;
  User3D.create_powY = CubePower;
  User3D.create_powZ = 2;

  SOLARCHVISION_switch_category(ObjectCategory.GROUP);
}




void UI_set_to_Modify_Move (int n) {
  WIN3D.UI_CurrentTask = UITASK.Move;

  Select3D.posVector = n;

  ROLLOUT.revise();
}

void UI_set_to_Modify_Scale (int n) {
  WIN3D.UI_CurrentTask = UITASK.Scale;

  Select3D.scaleVector = n;

  ROLLOUT.revise();
}


void UI_set_to_Modify_Rotate (int n) {
  WIN3D.UI_CurrentTask = UITASK.Rotate;

  Select3D.rotVector = n;

  ROLLOUT.revise();
}

void UI_set_to_Modify_Seed (int n) {
  WIN3D.UI_CurrentTask = UITASK.Seed_Material;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_Tessellation (int n) {
  WIN3D.UI_CurrentTask = UITASK.Tessellation;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_Layer (int n) {
  WIN3D.UI_CurrentTask = UITASK.Layer;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_Visibility (int n) {
  WIN3D.UI_CurrentTask = UITASK.Visibility;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_Weight (int n) {
  WIN3D.UI_CurrentTask = UITASK.Weight;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_DegreeMax (int n) {
  WIN3D.UI_CurrentTask = UITASK.DegreeMax;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_BranchTilt (int n) {
  WIN3D.UI_CurrentTask = UITASK.BranchTilt;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_BranchTwist (int n) {
  WIN3D.UI_CurrentTask = UITASK.BranchTwist;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_BranchRatio (int n) {
  WIN3D.UI_CurrentTask = UITASK.BranchRatio;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_TreeBase (int n) {
  WIN3D.UI_CurrentTask = UITASK.TreeBase;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}


void UI_set_to_Modify_TrunkSize (int n) {
  WIN3D.UI_CurrentTask = UITASK.TrunkSize;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_LeafSize (int n) {
  WIN3D.UI_CurrentTask = UITASK.LeafSize;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_Model1DsProps (int n) {
  WIN3D.UI_CurrentTask = UITASK.Model1DsProps;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_Pivot (int n) {
  WIN3D.UI_CurrentTask = UITASK.Pivot;
  WIN3D.UI_TaskModifyParameter = n; // 0:change selection 1:pick from 2:assign to

  ROLLOUT.revise();
}

void UI_set_to_Modify_Normal (int n) {
  WIN3D.UI_CurrentTask = UITASK.Normal;
  WIN3D.UI_TaskModifyParameter = n; // 1:flip normal, 2:set out from pivot, 3:set in from pivot

  ROLLOUT.revise();
}

void UI_set_to_Modify_FirstVertex (int n) {
  WIN3D.UI_CurrentTask = UITASK.FirstVertex;
  WIN3D.UI_TaskModifyParameter = n; // 1:default

  ROLLOUT.revise();
}




void UI_set_to_Modify_Drop (int n) {
  WIN3D.UI_CurrentTask = UITASK.Drop;

  WIN3D.UI_TaskModifyParameter = n; // 0:LandSurface± 1:ModelSurface- 2:ModelSurface+

  ROLLOUT.revise();
}


void UI_set_to_Modify_GetLength (int n) {
  WIN3D.UI_CurrentTask = UITASK.GetLength;

  WIN3D.UI_TaskModifyParameter = n; // 0:x 1:y 2:z 3:xyz 4:xy 5:angle(on XY plane)

  ROLLOUT.revise();
}

void UI_set_to_Modify_Power (int n) {

  if (n == 0) WIN3D.UI_CurrentTask = UITASK.PowerX; // x
  if (n == 1) WIN3D.UI_CurrentTask = UITASK.PowerY; // y
  if (n == 2) WIN3D.UI_CurrentTask = UITASK.PowerZ; // z
  if (n == 3) WIN3D.UI_CurrentTask = UITASK.PowerAll; // xyz

  WIN3D.UI_TaskModifyParameter = 0; // 0:change

  ROLLOUT.revise();
}










void UI_set_to_View_ProjectionType (int n) {
  WIN3D.ViewType = n;

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}

void UI_set_to_View_PickSelect (int n) {

  WIN3D.UI_CurrentTask = UITASK.PickSelect;

  addNewSelectionToPreviousSelection = 0;

  if (n == 1) {
    addNewSelectionToPreviousSelection = 1;
  }

  if (n == 2) {
    addNewSelectionToPreviousSelection = -1;
  }

  ROLLOUT.revise();
}

void UI_set_to_View_WindowSelect (int n) {
  WIN3D.UI_CurrentTask = UITASK.RectSelect;

  addNewSelectionToPreviousSelection = 0;

  if (n == 1) {
    addNewSelectionToPreviousSelection = 1;
  }

  if (n == 2) {
    addNewSelectionToPreviousSelection = -1;
  }

  ROLLOUT.revise();
}

void UI_set_to_View_PivotX (int n) {

  Select3D.alignX = n;

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}

void UI_set_to_View_PivotY (int n) {

  Select3D.alignY = n;

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}

void UI_set_to_View_PivotZ (int n) {

  Select3D.alignZ = n;

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}


void UI_set_to_View_Truck (int n) {

  if (n == 0) {
    WIN3D.UI_CurrentTask = UITASK.Zoom_Orbit_Pan;
  }

  if (n == 1) {
    WIN3D.UI_CurrentTask = UITASK.Truck_Orbit;
    WIN3D.UI_TaskModifyParameter = 0;
    WIN3D.UI_OptionXorY = 0;
  }

  if (n == 2) {
    WIN3D.UI_CurrentTask = UITASK.Truck_Orbit;
    WIN3D.UI_TaskModifyParameter = 0;
    WIN3D.UI_OptionXorY = 1;
  }

  ROLLOUT.revise();
}


void UI_set_to_View_DistMouseXY (int n) {

  if (n == 0) {
    WIN3D.UI_CurrentTask = UITASK.DistMouseXY_TargetRollXY_TargetRollZ;
  }

  ROLLOUT.revise();
}



void UI_set_to_View_CameraDistance (int n) {

  if (n == 0) {
    WIN3D.UI_CurrentTask = UITASK.CameraDistance_TargetRollXY_TargetRollZ;
  }

  ROLLOUT.revise();
}



void UI_set_to_View_CameraRoll (int n) {

  if (n == 0) {
    WIN3D.UI_CurrentTask = UITASK.CameraRoll_Pan;
  }

  if (n == 1) {
    WIN3D.UI_CurrentTask = UITASK.CameraRollXY_CameraRollZ;
    WIN3D.UI_TaskModifyParameter = 0;
    WIN3D.UI_OptionXorY = 0;
  }

  if (n == 2) {
    WIN3D.UI_CurrentTask = UITASK.CameraRollXY_CameraRollZ;
    WIN3D.UI_TaskModifyParameter = 0;
    WIN3D.UI_OptionXorY = 1;
  }

  ROLLOUT.revise();
}



void UI_set_to_View_TargetRoll (int n) {

  if (n == 0) {
    WIN3D.UI_CurrentTask = UITASK.TargetRoll_Pan;
  }

  if (n == 1) {
    WIN3D.UI_CurrentTask = UITASK.TargetRollXY_TargetRollZ;
    WIN3D.UI_TaskModifyParameter = 0;
    WIN3D.UI_OptionXorY = 0;
  }

  if (n == 2) {
    WIN3D.UI_CurrentTask = UITASK.TargetRollXY_TargetRollZ;
    WIN3D.UI_TaskModifyParameter = 0;
    WIN3D.UI_OptionXorY = 1;
  }

  ROLLOUT.revise();
}


void UI_set_to_View_Orbit (int n) {

  if (n == 0) {
    WIN3D.UI_CurrentTask = UITASK.Zoom_Orbit_Pan;
  }

  if (n == 1) {
    WIN3D.UI_CurrentTask = UITASK.Truck_Orbit;
    WIN3D.UI_TaskModifyParameter = 1;
    WIN3D.UI_OptionXorY = 0;
  }

  if (n == 2) {
    WIN3D.UI_CurrentTask = UITASK.Truck_Orbit;
    WIN3D.UI_TaskModifyParameter = 1;
    WIN3D.UI_OptionXorY = 1;
  }

  ROLLOUT.revise();
}



void UI_set_to_View_LandOrbit (int n) {

  WIN3D.UI_CurrentTask = UITASK.LandOrbit_Pan_TargetRollZ;

  ROLLOUT.revise();
}



void UI_set_to_View_LookAtSelection (int n) {

  WIN3D.look_3DViewport_towards_Selection();

  { // automatically set another choice of ineterest
    UI_set_to_View_CameraDistance(0);
    UI_toolBar.highlight("±CDS");
    UI_toolBar.revise();
  }

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}


void UI_set_to_View_LookAtDirection (int n) {

  WIN3D.UI_CurrentTask = UITASK.LookAtDirection;

  ROLLOUT.revise();
}


void UI_set_to_View_LookAtOrigin (int n) {

  WIN3D.position_X = 0;
  WIN3D.position_Y = 0;
  WIN3D.position_Z = 0;

  {
    // automatically set another choice of ineterest

    UI_set_to_View_Truck(0);
    UI_toolBar.highlight("±CDZ");
    UI_toolBar.revise();
  }

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}


void UI_set_to_View_Pan (int n) {

  if (n == 0) {
    WIN3D.UI_CurrentTask = UITASK.Pan_TargetRoll;
  }

  if (n == 1) {
    WIN3D.UI_CurrentTask = UITASK.PanX_TargetRollXY_TargetRollZ;
  }

  if (n == 2) {
    WIN3D.UI_CurrentTask = UITASK.PanY_TargetRollXY_TargetRollZ;
  }


  ROLLOUT.revise();
}

void UI_set_to_View_ZOOM (int n) {
  WIN3D.UI_CurrentTask = UITASK.Pan_Height;

  ROLLOUT.revise();

  if (n == 1) {
    WIN3D.Zoom = 60;

    SOLARCHVISION_view_changed();
  }
}

void UI_set_to_View_3DModelSize () {

  WIN3D.UI_CurrentTask = UITASK.ModelSize_Pan_TargetRoll;

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}

void UI_set_to_View_SkydomeSize () {

  WIN3D.UI_CurrentTask = UITASK.SkydomeSize;

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}

void UI_set_to_View_AllModelSize () {

  WIN3D.UI_CurrentTask = UITASK.AllModelSize;

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}

boolean updateBars = false;

void UI_set_to_Viewport (int n) {

  updateBars = true;

  FrameVariation = n;
  SOLARCHVISION_update_frame_layout();

  ROLLOUT.revise();
}

void UI_set_to_View_3DViewPoint (int n) {

  WIN3D.currentCamera = 0;

  WIN3D.apply_currentCamera();

  if (n == 0) {
    WIN3D.rotateZ_3DViewport_around_Selection(0 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(0 - WIN3D.rotation_Z);
  }

  if (n == 1) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(0 - WIN3D.rotation_Z);
  }

  if (n == 2) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(-90 - WIN3D.rotation_Z);
  }

  if (n == 3) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(180 - WIN3D.rotation_Z);
  }

  if (n == 4) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(90 - WIN3D.rotation_Z);
  }

  if (n == 5) {
    WIN3D.rotateZ_3DViewport_around_Selection(180 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(0 - WIN3D.rotation_Z);
  }

  if (n == 6) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(-45 - WIN3D.rotation_Z);
  }

  if (n == 7) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(45 - WIN3D.rotation_Z);
  }

  if (n == 8) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(135 - WIN3D.rotation_Z);
  }

  if (n == 9) {
    WIN3D.rotateZ_3DViewport_around_Selection(90 - WIN3D.rotation_X);
    WIN3D.rotateXY_3DViewport_around_Selection(-135 - WIN3D.rotation_Z);
  }


  UI_toolBar.revise();

  ROLLOUT.revise();

  SOLARCHVISION_view_changed();
}























int[] get_startK_endK () {
  int[] a = new int [2];

  int start_k = -1;
  int end_k = -1;

  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {

    start_k = SampleYear_Start;
    end_k = SampleYear_End;

    if (start_k < CLIMATE_CWEEDS_start) start_k = CLIMATE_CWEEDS_start;
    if (end_k > CLIMATE_CWEEDS_end) end_k = CLIMATE_CWEEDS_end;

    start_k -= CLIMATE_CWEEDS_start;
    end_k -= CLIMATE_CWEEDS_start;
  }
  if (CurrentDataSource == dataID_CLIMATE_CLMREC) {

    start_k = SampleYear_Start;
    end_k = SampleYear_End;

    if (start_k < CLIMATE_CLMREC_start) start_k = CLIMATE_CLMREC_start;
    if (end_k > CLIMATE_CLMREC_end) end_k = CLIMATE_CLMREC_end;

    start_k -= CLIMATE_CLMREC_start;
    end_k -= CLIMATE_CLMREC_start;
  }
  if (CurrentDataSource == dataID_CLIMATE_TMYEPW) {

    start_k = 0;
    end_k = 0;
  }
  if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {

    start_k = SampleMember_Start;
    end_k = SampleMember_End;

    start_k -= ENSEMBLE_FORECAST_start;
    end_k -= ENSEMBLE_FORECAST_start;
  }
  if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {

    start_k =  SampleStation_Start;
    end_k =  SampleStation_End;

    start_k -= ENSEMBLE_OBSERVED_start;
    end_k -= ENSEMBLE_OBSERVED_start;
  }


  //println("start_k=", start_k);
  //println("end_k=", end_k);

  a[0] = start_k;
  a[1] = end_k;

  return  a;
}
































void SOLARCHVISION_preBakeViewport () {

  cursor(WAIT);

  println("PreBaking Direct and Diffuse Models. Please wait...");

  Camera_Variation = 0;

  allSolarImpacts.sectionType = 1; // <<<<< so that it analyzed later!

  int start_DATE_ANGLE = 0;
  int step_DATE_ANGLE = 15;
  int end_DATE_ANGLE = 360 - step_DATE_ANGLE;

  int start_HOUR = 4; // to make it faster. Also the images are not needed out of this period.
  int step_HOUR = 1;
  int end_HOUR = 20; // to make it faster. Also the images are not needed out of this period.

  SceneName = "Viewport_" + Viewport_Stamp();

  int pre_WIN3D_dX = WIN3D.dX;
  int pre_WIN3D_dY = WIN3D.dY;

  WIN3D.dX = allSolarImpacts.RES1;
  WIN3D.dY = allSolarImpacts.RES2;
  WIN3D.view_R = float(WIN3D.dY) / float(WIN3D.dX);

  WIN3D.transform_3DViewport();

  //WIN3D.put_3DViewport();  //????????????

  float ScaleToFit = float(pre_WIN3D_dY) / float(WIN3D.dY);


  int RES1 = WIN3D.dX;
  int RES2 = WIN3D.dY;

  float[][] Diffuse_Matrix = new float [2][(RES1 * RES2)];

  for (int SHD = 0; SHD <= 1; SHD++) {
    for (int np = 0; np < (RES1 * RES2); np++) {
      Diffuse_Matrix[SHD][np] = 0;
    }
  }

  int n_Map = 0;
  for (int DATE_ANGLE = start_DATE_ANGLE; DATE_ANGLE <= end_DATE_ANGLE; DATE_ANGLE += step_DATE_ANGLE) {

    for (int i = start_HOUR; i <= end_HOUR; i += step_HOUR) {
      n_Map += 1;
    }
  }

  PImage[][] Direct_RGBA = new PImage [n_Map][2];


  int[] lastHitDirect = new int [n_Map];

  for (int i = 0; i < lastHitDirect.length; i++) {
    lastHitDirect[i] = 0;
  }

  int[] lastHitDiffuse = new int [DiffuseVectors.length];

  for (int i = 0; i < lastHitDiffuse.length; i++) {
    lastHitDiffuse[i] = 0;
  }


  n_Map = -1;
  for (int DATE_ANGLE = start_DATE_ANGLE; DATE_ANGLE <= end_DATE_ANGLE; DATE_ANGLE += step_DATE_ANGLE) {

    for (int i = start_HOUR; i <= end_HOUR; i += step_HOUR) {
      n_Map += 1;

      for (int SHD = 0; SHD <= 1; SHD++) {

        Direct_RGBA[n_Map][SHD] = createImage(RES1, RES2, ARGB);

        Direct_RGBA[n_Map][SHD].loadPixels();
      }
    }
  }

  float Progress = 0;

  for (int np = 0; np < (RES1 * RES2); np++) {
    int Image_X = np % RES1;
    int Image_Y = np / RES1;

    if (1 + Progress < 100 * np / float(RES1 * RES2)) {
      Progress = 100 * np / float(RES1 * RES2);
      //println("Progress:", int(Progress), "%");
    }

    Image_X -= 0.5 * WIN3D.dX;
    Image_Y -= 0.5 * WIN3D.dY;


    float[] ray_direction = new float [3];

    float[] ray_start = {
      WIN3D.CAM_x, WIN3D.CAM_y, WIN3D.CAM_z
    };

    float[] ray_end = WIN3D.calculate_Click3D(Image_X * ScaleToFit, Image_Y * ScaleToFit);

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

    RxP = allFaces.intersect(ray_start, ray_direction);

    if (RxP[0] >= 0) {

      int f = int(RxP[0]);

      float[] COL = {
        0, 0, 0, 0
      };

      float[] face_norm = {RxP[5], RxP[6], RxP[7]};
      face_norm = funcs.vec3_unit(face_norm);

      if (funcs.vec_dot(face_norm, ray_direction) > 0) { // to render backing faces
        face_norm[0] *= -1;
        face_norm[1] *= -1;
        face_norm[2] *= -1;
      }

      float Alpha = 90 - funcs.acos_ang(face_norm[2]);
      float Beta = 180 - funcs.atan2_ang(face_norm[0], face_norm[1]);

      float[] VECT = {
        0, 0, 0
      };

      if (abs(Alpha) > 89.99) {
        VECT[0] = 0;
        VECT[1] = 0;
        VECT[2] = 1;
      } else if (Alpha < -89.99) {
        VECT[0] = 0;
        VECT[1] = 0;
        VECT[2] = -1;
      } else {
        VECT[0] = funcs.sin_ang(Beta);
        VECT[1] = -funcs.cos_ang(Beta);
        VECT[2] = funcs.tan_ang(Alpha);
      }

      VECT = funcs.vec3_unit(VECT);

      {

        for (int n_Ray = 0; n_Ray < DiffuseVectors.length; n_Ray++) {

          // new trace
          ray_start[0] = RxP[1];
          ray_start[1] = RxP[2];
          ray_start[2] = RxP[3];

          ray_direction[0] = DiffuseVectors[n_Ray][0];
          ray_direction[1] = DiffuseVectors[n_Ray][1];
          ray_direction[2] = DiffuseVectors[n_Ray][2];

          float SkyMask = funcs.vec_dot(funcs.vec3_unit(DiffuseVectors[n_Ray]), funcs.vec3_unit(VECT));
          //if (SkyMask <= 0) SkyMask = 0; // removes backing faces

          // when SHD = 0;
          Diffuse_Matrix[0][np] += SkyMask / float(DiffuseVectors.length);

          lastHitDiffuse[n_Ray] = SOLARCHVISION_isIntersected_Faces(ray_start, ray_direction, lastHitDiffuse[n_Ray]);

          // when SHD = 1;
          if (lastHitDiffuse[n_Ray] == 0) {
            Diffuse_Matrix[1][np] += SkyMask / float(DiffuseVectors.length);
          }
          else Diffuse_Matrix[1][np] += 0;
        }
      }


      n_Map = -1;
      for (int DATE_ANGLE = start_DATE_ANGLE; DATE_ANGLE <= end_DATE_ANGLE; DATE_ANGLE += step_DATE_ANGLE) {

        for (int i = start_HOUR; i <= end_HOUR; i += step_HOUR) {
          n_Map += 1;

          float HOUR_ANGLE = i;

          float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);

          float[] DirectVector = {
            SunR[1], SunR[2], SunR[3]
          };

          // new trace
          ray_start[0] = RxP[1];
          ray_start[1] = RxP[2];
          ray_start[2] = RxP[3];

          ray_direction[0] = DirectVector[0];
          ray_direction[1] = DirectVector[1];
          ray_direction[2] = DirectVector[2];

          float SunMask = funcs.vec_dot(funcs.vec3_unit(DirectVector), funcs.vec3_unit(VECT));
          //if (SunMask <= 0) SunMask = 0; // removes backing faces

          // when SHD = 0;
          Direct_RGBA[n_Map][0].pixels[np] = color(255 * SunMask, 255);

          // when SHD = 1;

          lastHitDirect[n_Map] = SOLARCHVISION_isIntersected_Faces(ray_start, ray_direction, lastHitDirect[n_Map]);

          if (lastHitDirect[n_Map] == 0) {
            Direct_RGBA[n_Map][1].pixels[np] = color(255 * SunMask, 255);
          }
          else Direct_RGBA[n_Map][1].pixels[np] = color(0, 255);
        }
      }
    }
    else {

      n_Map = -1;
      for (int DATE_ANGLE = start_DATE_ANGLE; DATE_ANGLE <= end_DATE_ANGLE; DATE_ANGLE += step_DATE_ANGLE) {

        for (int i = start_HOUR; i <= end_HOUR; i += step_HOUR) {
          n_Map += 1;

          for (int SHD = 0; SHD <= 1; SHD++) {

            Direct_RGBA[n_Map][SHD].pixels[np] = color(0,0,0,0);

          }
        }
      }

      for (int SHD = 0; SHD <= 1; SHD++) {

        Diffuse_Matrix[SHD][np] = FLOAT_undefined;

      }

    }

  }

  println("Progress: 100 %");

  n_Map = -1;
  for (int DATE_ANGLE = start_DATE_ANGLE; DATE_ANGLE <= end_DATE_ANGLE; DATE_ANGLE += step_DATE_ANGLE) {

    for (int i = start_HOUR; i <= end_HOUR; i += step_HOUR) {
      n_Map += 1;

      float HOUR_ANGLE = i;

      for (int SHD = 0; SHD <= 1; SHD++) {

        String[] STR_SHD = {
          "F", "T"
        };
        String File_Name = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName;

        File_Name += nf(DATE_ANGLE, 3) + "_" + STR_SHD[SHD] + "_" + nf(int(funcs.roundTo(HOUR_ANGLE * 100, 1.0)), 4);

        File_Name += "_Camera" + nf(Camera_Variation, 2);

        Direct_RGBA[n_Map][SHD].updatePixels();

        Direct_RGBA[n_Map][SHD].save(File_Name + ".png");

        println(File_Name + ".png");
      }
    }
  }

  PImage[] Diffuse_RGBA = new PImage [2];

  for (int SHD = 0; SHD <= 1; SHD++) {

    String[] STR_SHD = {
      "F", "T"
    };
    String File_Name = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName;

    File_Name += "DIF_" + STR_SHD[SHD];

    File_Name += "_Camera" + nf(Camera_Variation, 2);

    Diffuse_RGBA[SHD] = createImage(RES1, RES2, ARGB);

    Diffuse_RGBA[SHD].loadPixels();

    for (int np = 0; np < (RES1 * RES2); np++) {

      if (is_defined(Diffuse_Matrix[SHD][np])) {

        Diffuse_RGBA[SHD].pixels[np] = color(255 * Diffuse_Matrix[SHD][np], 255);
      }
      else {

        Diffuse_RGBA[SHD].pixels[np] = color(0,0,0,0);
      }
    }

    Diffuse_RGBA[SHD].updatePixels();


    Diffuse_RGBA[SHD].save(File_Name + ".png");

    println(File_Name + ".png");
  }



  cursor(ARROW);

  WIN3D.dX = pre_WIN3D_dX;
  WIN3D.dY = pre_WIN3D_dY;
  WIN3D.view_R = float(WIN3D.dY) / float(WIN3D.dX);
}






void SOLARCHVISION_RenderViewport () {

  println("Render started!");

  int PAL_type = 0;
  int PAL_direction = 1;
  float PAL_multiplier = 1;

  if (Impact_TYPE == Impact_ACTIVE) {
    PAL_type = allFaces.ACTIVE_pallet_CLR;
    PAL_direction = allFaces.ACTIVE_pallet_DIR;
    PAL_multiplier = allFaces.ACTIVE_pallet_MLT;
  }
  if (Impact_TYPE == Impact_PASSIVE) {
    PAL_type = allFaces.PASSIVE_pallet_CLR;
    PAL_direction = allFaces.PASSIVE_pallet_DIR;
    PAL_multiplier = allFaces.PASSIVE_pallet_MLT;
  }


  int RES1 = WIN3D.dX;
  int RES2 = WIN3D.dY;

  PImage Image_RGBA = createImage(RES1, RES2, ARGB);

  Image_RGBA.loadPixels();

  float Progress = 0;




  for (int np = 0; np < (RES1 * RES2); np++) {
    int Image_X = np % RES1;
    int Image_Y = np / RES1;

    Image_X -= 0.5 * WIN3D.dX;
    Image_Y -= 0.5 * WIN3D.dY;

    if (1 + Progress < 100 * np / float(RES1 * RES2)) {
      Progress = 100 * np / float(RES1 * RES2);
      //println("Progress:", int(Progress), "%");
    }

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

    RxP = allFaces.intersect(ray_start, ray_direction);

    if (RxP[0] >= 0) {

      int f = int(RxP[0]);


      float[] COL = {
        0, 0, 0, 0
      };

      float[] face_norm = {RxP[5], RxP[6], RxP[7]};
      face_norm = funcs.vec3_unit(face_norm);

      if (funcs.vec_dot(face_norm, ray_direction) > 0) { // to render backing faces
        face_norm[0] *= -1;
        face_norm[1] *= -1;
        face_norm[2] *= -1;
      }


      float Alpha = 90 - funcs.acos_ang(face_norm[2]);
      float Beta = 180 - funcs.atan2_ang(face_norm[0], face_norm[1]);

float valuesSUM_RAD = 0;
float valuesSUM_EFF_P = 0;
float valuesSUM_EFF_N = 0;
int valuesNUM = 0;

float values_R_dir = 1;
float values_R_dif = 1;
float values_E_dir = 0.1;
float values_E_dif = 0.1;


//float[] SunR = funcs.SunPositionRadiation( DATE_ANGLE, HOUR_ANGLE, ENSEMBLE_FORECAST_values[i][j][LAYER_cloudcover.id][k]);
float[] SunR = funcs.SunPositionRadiation(0, 12, 0);
float[] VECT = {
  0, 0, 0
};

if (abs(Alpha) > 89.99) {
  VECT[0] = 0;
  VECT[1] = 0;
  VECT[2] = 1;
} else if (Alpha < -89.99) {
  VECT[0] = 0;
  VECT[1] = 0;
  VECT[2] = -1;
} else {
  VECT[0] = funcs.sin_ang(Beta);
  VECT[1] = -funcs.cos_ang(Beta);
  VECT[2] = funcs.tan_ang(Alpha);
}

VECT = funcs.vec3_unit(VECT);


float[] SunV = {
  SunR[1], SunR[2], SunR[3]
};

float SunMask = funcs.vec_dot(funcs.vec3_unit(SunV), funcs.vec3_unit(VECT));
if (SunMask <= 0) SunMask = 0; // removes backing faces

float SkyMask = (0.5 * (1.0 + (Alpha / 90.0)));


// new trace
ray_start[0] = RxP[1];
ray_start[1] = RxP[2];
ray_start[2] = RxP[3];

ray_direction[0] = SunV[0];
ray_direction[1] = SunV[1];
ray_direction[2] = SunV[2];

//if (funcs.vec_dot(face_norm, ray_direction) > 0)
{ // removes backing faces

  if (SOLARCHVISION_isIntersected_Faces(ray_start, ray_direction, 0) != 0) {
    if (values_E_dir < 0) {
      valuesSUM_EFF_P += -(values_E_dir * SunMask);
      valuesSUM_EFF_N += -(values_E_dif * SkyMask); // adding approximate diffuse radiation effect anyway!
    } else {
      valuesSUM_EFF_N += (values_E_dir * SunMask);
      valuesSUM_EFF_P += (values_E_dif * SkyMask); // adding approximate diffuse radiation effect anyway!
    }

    valuesSUM_RAD += (values_R_dif * SkyMask); // only approximate diffuse radiation!
  } else {
    if (values_E_dir < 0) {
      valuesSUM_EFF_N += -((values_E_dir * SunMask) + (values_E_dif * SkyMask));
    } else {
      valuesSUM_EFF_P += ((values_E_dir * SunMask) + (values_E_dif * SkyMask));
    }

    valuesSUM_RAD += ((values_R_dir * SunMask) + (values_R_dif * SkyMask)); // calculates total radiation
  }
}
valuesNUM += 1;

//-----------------------------
float valuesSUM = valuesSUM_RAD; // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
//-----------------------------

      float _u = 0;

      if (is_defined(valuesSUM)) {

        if (Impact_TYPE == Impact_ACTIVE) _u = (0.1 * PAL_multiplier * valuesSUM);
        if (Impact_TYPE == Impact_PASSIVE) _u = 0.5 + 0.5 * (0.1 * PAL_multiplier * valuesSUM);

        if (PAL_direction == -1) _u = 1 - _u;
        if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
        if (PAL_direction == 2) _u =  0.5 * _u;
      }

      COL = PAINT.getColorStyle(PAL_type, _u);


      Image_RGBA.pixels[np] = color(COL[1], COL[2], COL[3], COL[0]);
    }

    else Image_RGBA.pixels[np] = color(0,0,0,0);
  }

  Image_RGBA.updatePixels();

  String myFile = Folder_ScreenShots + "/" + createStamp(1, "Render") + ".png";
  Image_RGBA.save(myFile);
  println("File created:" + myFile);

}





float[][] DiffuseVectors;

void SOLARCHVISION_build_SkySphere (int tessellation) {

  //Create3D.add_CrystalSphere(0, 0, 0, 1, 0, 0, 0,0,0, 1, tessellation, 1, 90); // SKY
  //Create3D.add_CrystalSphere(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 4, 1, 90); // SKY
  Create3D.add_CrystalSphere(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 3, 1, 90); // SKY

  DiffuseVectors = new float[0][3];

  for (int i = 0; i < skyFaces.length; i++) {

    float x = 0;
    float y = 0;
    float z = 0;

    for (int j = 0; j < skyFaces[i].length; j++) {

      x += skyVertices[skyFaces[i][j]][0] / float(skyFaces[i].length);
      y += skyVertices[skyFaces[i][j]][1] / float(skyFaces[i].length);
      z += skyVertices[skyFaces[i][j]][2] / float(skyFaces[i].length);

      if (z > 0) {
        float[][] new_Vector = {{x, y, z}};
        DiffuseVectors = (float[][]) concat(DiffuseVectors, new_Vector);
      }
    }
  }

}






void setFlag_CurrentDataSource (int i, int j, int k, int Parameter_ID, boolean flag) {

  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
    CLIMATE_CWEEDS_flags[i][j][Parameter_ID][k] = flag;
  }
  else if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
    CLIMATE_CLMREC_flags[i][j][Parameter_ID][k] = flag;
  }
  else if (CurrentDataSource == dataID_CLIMATE_TMYEPW) {
    CLIMATE_TMYEPW_flags[i][j][Parameter_ID][k] = flag;
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
    ENSEMBLE_FORECAST_flags[i][j][Parameter_ID][k] = flag;
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
    ENSEMBLE_OBSERVED_flags[i][j][Parameter_ID][k] = flag;
  }

}

void setValue_CurrentDataSource (int i, int j, int k, int Parameter_ID, float value) {

  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
    CLIMATE_CWEEDS_values[i][j][Parameter_ID][k] = value;
  }
  else if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
    CLIMATE_CLMREC_values[i][j][Parameter_ID][k] = value;
  }
  else if (CurrentDataSource == dataID_CLIMATE_TMYEPW) {
    CLIMATE_TMYEPW_values[i][j][Parameter_ID][k] = value;
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
    ENSEMBLE_FORECAST_values[i][j][Parameter_ID][k] = value;
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
    ENSEMBLE_OBSERVED_values[i][j][Parameter_ID][k] = value;
  }

}


float getValue_CurrentDataSource (int i, int j, int k, int Parameter_ID) {

  float return_value = FLOAT_undefined;

  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
    return_value = CLIMATE_CWEEDS_values[i][j][Parameter_ID][k];
  }
  else if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
    return_value = CLIMATE_CLMREC_values[i][j][Parameter_ID][k];
  }
  else if (CurrentDataSource == dataID_CLIMATE_TMYEPW) {
    return_value = CLIMATE_TMYEPW_values[i][j][Parameter_ID][k];
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
    return_value = ENSEMBLE_FORECAST_values[i][j][Parameter_ID][k];
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
    return_value = ENSEMBLE_OBSERVED_values[i][j][Parameter_ID][k];
  }

  return return_value;
}


int getStart_CurrentDataSource () {

  int return_value = -1;

  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
    return_value = CLIMATE_CWEEDS_start;
  }
  else if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
    return_value = CLIMATE_CLMREC_start;
  }
  else if (CurrentDataSource == dataID_CLIMATE_TMYEPW) {
    return_value = CLIMATE_TMYEPW_start;
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
    return_value = ENSEMBLE_FORECAST_start;
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
    return_value = ENSEMBLE_OBSERVED_start;
  }

  return return_value;
}

int getEnd_CurrentDataSource () {

  int return_value = -1;

  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
    return_value = CLIMATE_CWEEDS_end;
  }
  else if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
    return_value = CLIMATE_CLMREC_end;
  }
  else if (CurrentDataSource == dataID_CLIMATE_TMYEPW) {
    return_value = CLIMATE_TMYEPW_end;
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
    return_value = ENSEMBLE_FORECAST_end;
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
    return_value = ENSEMBLE_OBSERVED_end;
  }

  return return_value;
}

String getReference_CurrentDataSource () {

  String return_value = "";

  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
    return_value = STATION.getFilename_CWEEDS() + ".WY3" + ", Environment and Climate Change Canada: ftp://ftp.tor.ec.gc.ca/Pub/Normals/";
  }
  else if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
    return_value  = "Environment and Climate Change Canada website at https://climate.weather.gc.ca/climate_data";
  }
  else if (CurrentDataSource == dataID_CLIMATE_TMYEPW) {
    return_value = STATION.getFilename_TMYEPW() + ".epw";
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
    return_value = nf(TIME.year, 4) + nf(TIME.month, 2) + nf(TIME.day, 2) + nf(TIME.hour, 2) + "_GEPS-NAEFS-RAW_" + STATION.getFilename_NAEFS() + "_" + CurrentLayer_name + "_000-384.xml" + ", Environment and Climate Change Canada: https://dd.weather.gc.ca/ensemble/naefs/";
  }
  else if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
    return_value = "Environment and Climate Change Canada website at https://dd.weather.gc.ca/observations/swob-ml/";
  }

  return return_value;
}



void SOLARCHVISION_setDataFlags (int desired_DataSource) {

  int keep_CurrentDataSource = CurrentDataSource;

  CurrentDataSource = desired_DataSource;

  int DATA_start = getStart_CurrentDataSource();
  int DATA_end = getEnd_CurrentDataSource();
  // setting the flags
  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < numberOfLayers; l++) {
        for (int k = 0; k < (1 + DATA_end - DATA_start); k++) {
          if (is_defined(getValue_CurrentDataSource(i, j, k, l))) {
            setFlag_CurrentDataSource(i, j, k, l, true);
          }
        }
      }
    }
  }

  CurrentDataSource = keep_CurrentDataSource;
}

void SOLARCHVISION_postProcess_fillGaps (int desired_DataSource) {

  int keep_CurrentDataSource = CurrentDataSource;

  CurrentDataSource = desired_DataSource;

  int DATA_start = getStart_CurrentDataSource();
  int DATA_end = getEnd_CurrentDataSource();

  int MAX_SEARCH = 6; // It defines how many hours the program should seek for each point to find next available data.

  for (int l = 0; l < numberOfLayers; l++) {

    for (int k = 0; k < (1 + DATA_end - DATA_start); k++) {
      float pre_v = FLOAT_undefined;
      int pre_num = 0;

      for (int j = 0; j < 365; j++) {

        for (int i = 0; i < 24; i++) {

          if (is_undefined(getValue_CurrentDataSource(i, j, k, l))) {
            if (is_defined(pre_v)) {
              pre_num += 1;

              float next_v = FLOAT_undefined;
              int next_i = i;
              int next_j = j;
              int next_num = 0;
              while ((next_num < MAX_SEARCH) && (is_undefined(next_v))) {
                next_num += 1;
                next_i += 1;
                if (next_i == 24) {
                  next_i -= 24;
                  next_j += 1;
                }
                if (next_j == 365) {
                  next_j = 0;
                }
                if (is_defined(getValue_CurrentDataSource(next_i, next_j, k, l))) {
                  next_v = getValue_CurrentDataSource(next_i, next_j, k, l);

                  if (l == LAYER_winddir.id) {
                    if ((next_v - pre_v) > 180) next_v -= 360;
                    if ((next_v - pre_v) < -180) next_v += 360;
                  }
                }
              }
              if (next_num < MAX_SEARCH) {
                if (l == LAYER_winddir.id) setValue_CurrentDataSource(i, j, k, l, ((next_num * pre_v + pre_num * next_v) / (pre_num + next_num) + 360) % 360);
                else setValue_CurrentDataSource(i, j, k, l, (next_num * pre_v + pre_num * next_v) / (pre_num + next_num));

                float interpolation_pow = pow(2.0, Interpolation_Weight);

                setValue_CurrentDataSource(i, j, k, l, (pow(next_num, interpolation_pow) * pre_v + pow(pre_num, interpolation_pow) * next_v) / (pow(next_num, interpolation_pow) + pow(pre_num, interpolation_pow)));
                if (l == LAYER_winddir.id) setValue_CurrentDataSource(i, j, k, l, (getValue_CurrentDataSource(i, j, k, l) + 360) % 360);
              }
            }
          } else {
            pre_v = getValue_CurrentDataSource(i, j, k, l);
            pre_num = 0;
          }

        }
      }

    }
  }

  CurrentDataSource = keep_CurrentDataSource;
}






void SOLARCHVISION_postProcess_solarsUsingCloud (int desired_DataSource) {

  int keep_CurrentDataSource = CurrentDataSource;

  CurrentDataSource = desired_DataSource;

  int DATA_start = getStart_CurrentDataSource();
  int DATA_end = getEnd_CurrentDataSource();

  for (int k = 0; k < (1 + DATA_end - DATA_start); k++) {
    for (int j = 0; j < 365; j++) {
      for (int i = 0; i < 24; i++) {

        float CL = getValue_CurrentDataSource(i, j, k, LAYER_cloudcover.id);

        if (is_defined(CL)) {
          float DATE_ANGLE = (360 * ((286 + j) % 365) / 365.0);
          float HOUR_ANGLE = i;

          float[] SunR = funcs.SunPositionRadiation(DATE_ANGLE, HOUR_ANGLE, CL);

          setValue_CurrentDataSource(i, j, k, LAYER_dirnorrad.id, SunR[4]);

          setValue_CurrentDataSource(i, j, k, LAYER_difhorrad.id, SunR[5]);

          setValue_CurrentDataSource(i, j, k, LAYER_glohorrad.id, SunR[4] * SunR[3] + SunR[5]);
        }

      }
    }
  }

  CurrentDataSource = keep_CurrentDataSource;
}


void SOLARCHVISION_postProcess_solarEffects (int desired_DataSource) {

  int keep_CurrentDataSource = CurrentDataSource;

  CurrentDataSource = desired_DataSource;

  int DATA_start = getStart_CurrentDataSource();
  int DATA_end = getEnd_CurrentDataSource();


  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int k = 0; k < (1 + DATA_end - DATA_start); k++) {

        float T     = getValue_CurrentDataSource(i, j, k, LAYER_drybulb.id);
        float R_dir = getValue_CurrentDataSource(i, j, k, LAYER_dirnorrad.id);
        float R_dif = getValue_CurrentDataSource(i, j, k, LAYER_difhorrad.id);

        if (is_defined(T) && is_defined(R_dir) && is_defined(R_dif)) {

          setValue_CurrentDataSource(i, j, k, LAYER_direffect.id, (18 - T) * R_dir);
          setValue_CurrentDataSource(i, j, k, LAYER_difeffect.id, (18 - T) * R_dif);

        }
      }
    }
  }

  CurrentDataSource = keep_CurrentDataSource;
}


void SOLARCHVISION_postProcess_climaticSolarForecast () {

  int num_count = (1 + CLIMATE_CWEEDS_end - CLIMATE_CWEEDS_start);

  for (int k = 0; k < (1 + ENSEMBLE_FORECAST_end - ENSEMBLE_FORECAST_start); k++) {
    for (int j_for = 0; j_for < ENSEMBLE_FORECAST_maxDays; j_for++) {
      int j = ((j_for + TIME.beginDay) % 365);
      for (int i = 0; i < 24; i++) {
        if (is_undefined(ENSEMBLE_FORECAST_values[i][j][LAYER_cloudcover.id][k])) {
        } else {
          float DATE_ANGLE = (360 * ((286 + j) % 365) / 365.0);
          float HOUR_ANGLE = i;

          float[] SunR = funcs.SunPositionRadiation(DATE_ANGLE, HOUR_ANGLE, ENSEMBLE_FORECAST_values[i][j][LAYER_cloudcover.id][k]);

          ENSEMBLE_FORECAST_values[i][j][LAYER_dirnorrad.id][k] = SunR[4];

          ENSEMBLE_FORECAST_values[i][j][LAYER_difhorrad.id][k] = SunR[5];

          ENSEMBLE_FORECAST_values[i][j][LAYER_glohorrad.id][k] = SunR[4] * SunR[3] + SunR[5];

          //---------------------------------------------------------------------

          float Forecast_CC = ENSEMBLE_FORECAST_values[i][j][LAYER_cloudcover.id][k];
          float Forecast_AP = ENSEMBLE_FORECAST_values[i][j][LAYER_pressure.id][k];

          float CC_epsilon = 1.0; // defines a range for finding near previous results: 1.0 results in e.g. 2 < CC < 4 for CC at 3
          float AP_epsilon = 50.0;

          float valuesSUM_DIR = 0;
          float valuesSUM_DIF = 0;
          float valuesSUM_GLO = 0;
          float sum_count = 0;

          float process_add_days = 11;

          for (int q = 0; q < num_count; q++) {

            for (int j_ADD = 0; j_ADD < process_add_days; j_ADD++) {

              int now_i = i;
              int now_j = int(j + (j_ADD - int(0.5 * process_add_days)) + 365) % 365;

              if (now_j >= 365) {
                now_j = now_j % 365;
              }
              if (now_j < 0) {
                now_j = (now_j + 365) % 365;
              }


              if ((is_undefined(CLIMATE_CWEEDS_values[now_i][now_j][LAYER_cloudcover.id][q])) ||
                 (is_undefined(CLIMATE_CWEEDS_values[now_i][now_j][LAYER_pressure.id][q]))) {
              } else {
                float CC_dist = abs(Forecast_CC - CLIMATE_CWEEDS_values[now_i][now_j][LAYER_cloudcover.id][q]);
                float AP_dist = abs(Forecast_AP - CLIMATE_CWEEDS_values[now_i][now_j][LAYER_pressure.id][q]);
                if ((CC_dist < CC_epsilon) && (AP_dist < AP_epsilon)) {

                  float _weight;

                  _weight = 1;
                  _weight *= pow(abs(1 - pow(CC_dist/CC_epsilon, 2)), 2); // to add more wights to closer cases
                  _weight *= pow(abs(1 - pow(AP_dist/AP_epsilon, 2)), 2);

                  sum_count += _weight;

                  if (is_undefined(CLIMATE_CWEEDS_values[now_i][now_j][LAYER_dirnorrad.id][q])) {
                  } else valuesSUM_DIR += _weight * CLIMATE_CWEEDS_values[now_i][now_j][LAYER_dirnorrad.id][q];
                  if (is_undefined(CLIMATE_CWEEDS_values[now_i][now_j][LAYER_difhorrad.id][q])) {
                  } else valuesSUM_DIF += _weight * CLIMATE_CWEEDS_values[now_i][now_j][LAYER_difhorrad.id][q];
                  if (is_undefined(CLIMATE_CWEEDS_values[now_i][now_j][LAYER_glohorrad.id][q])) {
                  } else valuesSUM_GLO += _weight * CLIMATE_CWEEDS_values[now_i][now_j][LAYER_glohorrad.id][q];
                }
              }
            }
          }

          if (sum_count != 0) {
            valuesSUM_DIR /= sum_count;
            valuesSUM_DIF /= sum_count;
            valuesSUM_GLO /= sum_count;

            ENSEMBLE_FORECAST_values[i][j][LAYER_dirnorrad.id][k] = valuesSUM_DIR;
            ENSEMBLE_FORECAST_values[i][j][LAYER_difhorrad.id][k] = valuesSUM_DIF;
            ENSEMBLE_FORECAST_values[i][j][LAYER_glohorrad.id][k] = valuesSUM_GLO;
          } else {
            println("Cannot find simillar conditions in climate file at i:", i, ", j:", j, ", k:", k);
          }

        }
      }
    }
  }
}




void SOLARCHVISION_postProcess_developDATA (int desired_DataSource) {

  int keep_CurrentDataSource = CurrentDataSource;

  CurrentDataSource = desired_DataSource;

  float keep_STUDY_perDays = STUDY.perDays;
  int keep_STUDY_joinDays = STUDY.joinDays;

  if ((CurrentDataSource == dataID_ENSEMBLE_FORECAST) ||
      (CurrentDataSource == dataID_ENSEMBLE_OBSERVED)) {

    STUDY.perDays = 1;
    STUDY.joinDays = 1;
  }

  int DATA_start = getStart_CurrentDataSource();
  int DATA_end = getEnd_CurrentDataSource();

  int count_k = 1 + DATA_end - DATA_start;
  if (count_k > 0) {

    float Pa = FLOAT_undefined;
    float Pb = FLOAT_undefined;
    float RAIN, T, WS, R_dir, R_dif;

    float[] valuesSUM;
    valuesSUM = new float [count_k];

    for (int k = 0; k < count_k; k++) {
      valuesSUM[k] = FLOAT_undefined;
    }

    for (int j = STUDY.j_Start; j <= STUDY.j_End; j++) {
      for (int j_ADD = 0; j_ADD < STUDY.joinDays; j_ADD++) {
        for (int k = 0; k < count_k; k++) {
          for (int i = 0; i < 24; i++) {

            int now_k = k;
            int now_i = i;
            int now_j = int(j * STUDY.perDays + (j_ADD - int(funcs.roundTo(0.5 * STUDY.joinDays, 1))) + TIME.beginDay + 365) % 365;

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


            setValue_CurrentDataSource(now_i, now_j, now_k, LAYER_developed.id, FLOAT_undefined);

            T = FLOAT_undefined;
            R_dir = FLOAT_undefined;
            R_dif = FLOAT_undefined;

            if ((i == 0) && (j == STUDY.j_Start)) valuesSUM[now_k] = 0;



            Pa = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_dirnorrad.id);

            if (is_undefined(Pa)) {
              R_dir = FLOAT_undefined;
            } else {
              R_dir = Pa;
            }

            Pa = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_difhorrad.id);

            if (is_undefined(Pa)) {
              R_dif = FLOAT_undefined;
            } else {
              R_dif = Pa;
            }

            Pa = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_drybulb.id);

            if (is_undefined(Pa)) {
              T = FLOAT_undefined;
            } else {
              T = Pa;
            }

            Pa = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_windspd.id);

            if (is_undefined(Pa)) {
              WS = FLOAT_undefined;
            } else {
              WS = Pa;
            }

            Pa = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_precipitation.id);
            Pb = getValue_CurrentDataSource(next_i, next_j, now_k, LAYER_precipitation.id);

            if (is_undefined(Pa) || is_undefined(Pb)) {
              RAIN = FLOAT_undefined;
            } else {
              RAIN = Pb - Pa;
              //RAIN = Pa - Pb;

              if (T <= 0) RAIN *= -1;  // <<<<<<<<<<<<<<<<<<<< Lewis
              //if ((T < 5) && (T > -5)) RAIN *= -1;  // <<<<<<<<<<<<<<<<<<<< Mojtaba
            }


            float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);
            float HOUR_ANGLE = now_i;

            float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);

            if (Develop_Option == DEV_WindPower) {

              if (is_defined(WS)) {

                valuesSUM[now_k] = 0.5 * 1.23 * 1 * pow(WS / 3.6, 3);

                setValue_CurrentDataSource(now_i, now_j, now_k, LAYER_developed.id, valuesSUM[now_k]);
              }

              LAYER_developed.V_scale = 0.05;
              LAYER_developed.V_offset = 0;
              LAYER_developed.V_belowLine = 0;
              LAYER_developed.unit = "W/m²";
              LAYER_developed.descriptions[Language_EN] = "Wind power";
              LAYER_developed.descriptions[Language_FR] = "?"; // ??
            }

            if (Develop_Option == DEV_RadiationOnTracker) {
              float Alpha = funcs.asin_ang(SunR[3]);
              float Beta = funcs.atan2_ang(SunR[2], SunR[1]) + 90;

              if (is_defined(R_dir) && is_defined(R_dif)) {

                valuesSUM[now_k] = SOLARCHVISION_SolarAtSurface(SunR[1], SunR[2], SunR[3], R_dir, R_dif, Alpha, Beta, GlobalAlbedo);

                setValue_CurrentDataSource(now_i, now_j, now_k, LAYER_developed.id, valuesSUM[now_k]);
              }

              LAYER_developed.V_scale = 0.1;
              LAYER_developed.V_offset = 0;
              LAYER_developed.V_belowLine = 0;
              LAYER_developed.unit = "W/m²";
              LAYER_developed.descriptions[Language_EN] = "Radiation on solar tracker";
              LAYER_developed.descriptions[Language_FR] = "?"; // ??
            }


            if (
              (Develop_Option == DEV_RadiationOnSouth) ||
              (Develop_Option == DEV_RadiationOnEast) ||
              (Develop_Option == DEV_RadiationOnWest) ||
              (Develop_Option == DEV_RadiationOnNorth) ||
              (Develop_Option == DEV_RadiationOnSE) ||
              (Develop_Option == DEV_RadiationOnNE) ||
              (Develop_Option == DEV_RadiationOnNW) ||
              (Develop_Option == DEV_RadiationOnSW) ||
              (Develop_Option == DEV_RadiationOnSurface)
            ) {
              float Alpha = 0;
              float Beta = 0;
              if (Develop_Option == DEV_RadiationOnSurface) {
                Alpha = Develop_AngleInclination;
                Beta = Develop_AngleOrientation;
              } else if (Develop_Option == DEV_RadiationOnSouth) {
                Alpha = 0;
                Beta = 0;
              } else if (Develop_Option == DEV_RadiationOnEast) {
                Alpha = 0;
                Beta = 90;
              } else if (Develop_Option == DEV_RadiationOnNorth) {
                Alpha = 0;
                Beta = 180;
              } else if (Develop_Option == DEV_RadiationOnWest) {
                Alpha = 0;
                Beta = -90;
              } else if (Develop_Option == DEV_RadiationOnSE) {
                Alpha = 0;
                Beta = 45;
              } else if (Develop_Option == DEV_RadiationOnNE) {
                Alpha = 0;
                Beta = 135;
              } else if (Develop_Option == DEV_RadiationOnNW) {
                Alpha = 0;
                Beta = -135;
              } else if (Develop_Option == DEV_RadiationOnSW) {
                Alpha = 0;
                Beta = -45;
              }

              if (is_defined(R_dir) && is_defined(R_dif)) {

                valuesSUM[now_k] = SOLARCHVISION_SolarAtSurface(SunR[1], SunR[2], SunR[3], R_dir, R_dif, Alpha, Beta, GlobalAlbedo);

                setValue_CurrentDataSource(now_i, now_j, now_k, LAYER_developed.id, valuesSUM[now_k]);
              }

              LAYER_developed.V_scale = 0.1;
              LAYER_developed.V_offset = 0;
              LAYER_developed.V_belowLine = 0;
              LAYER_developed.unit = "W/m²";

              if (Develop_Option == DEV_RadiationOnSurface) {
                LAYER_developed.descriptions[Language_EN] = "Radiation on inclination_" + String.valueOf(Alpha) + "_South-Deviation_" + String.valueOf(Beta);
                LAYER_developed.descriptions[Language_FR] = "?"; // ??
              } else if (Develop_Option == DEV_RadiationOnSouth) {
                LAYER_developed.descriptions[Language_EN] = "Radiation on South surface";
                LAYER_developed.descriptions[Language_FR] = "?"; // ??
              } else if (Develop_Option == DEV_RadiationOnEast) {
                LAYER_developed.descriptions[Language_EN] = "Radiation on East surface";
                LAYER_developed.descriptions[Language_FR] = "?"; // ??
              } else if (Develop_Option == DEV_RadiationOnNorth) {
                LAYER_developed.descriptions[Language_EN] = "Radiation on North surface";
                LAYER_developed.descriptions[Language_FR] = "?"; // ??
              } else if (Develop_Option == DEV_RadiationOnWest) {
                LAYER_developed.descriptions[Language_EN] = "Radiation on West surface";
                LAYER_developed.descriptions[Language_FR] = "?"; // ??
              } else if (Develop_Option == DEV_RadiationOnSE) {
                LAYER_developed.descriptions[Language_EN] = "Radiation on S.E. surface";
                LAYER_developed.descriptions[Language_FR] = "?"; // ??
              } else if (Develop_Option == DEV_RadiationOnNE) {
                LAYER_developed.descriptions[Language_EN] = "Radiation on N.E. surface";
                LAYER_developed.descriptions[Language_FR] = "?"; // ??
              } else if (Develop_Option == DEV_RadiationOnNW) {
                LAYER_developed.descriptions[Language_EN] = "Radiation on N.W. surface";
                LAYER_developed.descriptions[Language_FR] = "?"; // ??
              } else if (Develop_Option == DEV_RadiationOnSW) {
                LAYER_developed.descriptions[Language_EN] = "Radiation on S.W. surface";
                LAYER_developed.descriptions[Language_FR] = "?"; // ??
              }
            }

          }
        }
      }
    }
  }

  println("developDATA updated!");

  DevelopData_update = false;

  STUDY.perDays = keep_STUDY_perDays;
  STUDY.joinDays = keep_STUDY_joinDays;

  CurrentDataSource = keep_CurrentDataSource;
}


solarchvision_UI_menuBar UI_menuBar = new solarchvision_UI_menuBar();

solarchvision_UI_toolBar UI_toolBar = new solarchvision_UI_toolBar();

solarchvision_UI_commandBar UI_commandBar = new solarchvision_UI_commandBar();

solarchvision_UI_caseBar UI_caseBar = new solarchvision_UI_caseBar();






String[] allCommands = {"SOLARCHVISION Command Input:", ""};
String[] allMessages = {"SOLARCHVISION Command Output:", ""};


int typeUserCommand = 0;

void COMIN_keyPressed (KeyEvent e) {

  if ((e.isAltDown() != true) && (e.isControlDown() != true) && (e.isShiftDown() != true)) {

    if (key == CODED) {
      switch(keyCode) {
      }
    }
  }

  if ((e.isAltDown() != true) && (e.isControlDown() != true)) {

    if (key != CODED) {
      switch(key) {

       case ENTER:
         String[] newCommand = {""};
         String[] newMessage = {""};

         allMessages[allMessages.length - 1] = SOLARCHVISION_executeCommand(allCommands[allCommands.length - 1]);

         allCommands = concat(allCommands, newCommand);
         allMessages = concat(allMessages, newMessage);
         break;

       case BACKSPACE:
          if (allCommands[allCommands.length - 1].length() > 0) {
            allCommands[allCommands.length - 1] = allCommands[allCommands.length - 1].substring(0, allCommands[allCommands.length - 1].length() - 1);
          }
          break;

        default:
          if ((31 < key) && (key < 127)) {
            allCommands[allCommands.length - 1] += key;
          }
          break;
      }


    }
  }
}

void SOLARCHVISION_execute_commands_TXT (String FileName) {

  String[] FileALL = loadStrings(FileName);

  for (int f = 0; f < FileALL.length; f++) {

    String lineSTR = FileALL[f];

    SOLARCHVISION_executeCommand(lineSTR);
  }

}

String SOLARCHVISION_executeCommand (String lineSTR) {

  String return_message = "";

  lineSTR = lineSTR.replace("\"", "");

  String[] parts = split(lineSTR, ' ');

  String Command_CAPITAL = parts[0].toUpperCase();

  if (Command_CAPITAL.equals("CLS")) {
    allCommands = new String[1];
    allMessages = new String[1];

    allCommands[0] = "";
    allMessages[0] = "";
  }

  else if (Command_CAPITAL.equals("OPEN")) {
    selectInput("Select a file to open:", "SOLARCHVISION_fileSelected_Open");
  }

  else if (Command_CAPITAL.equals("SAVE.AS")) {
    selectOutput("Select a file to write to:", "SOLARCHVISION_fileSelected_SaveAs");
  }

  else if (Command_CAPITAL.equals("SAVE")) {
    SOLARCHVISION_save_project(Folder_Project + "/" + ProjectName + ".xml");
  }

  else if (Command_CAPITAL.equals("HOLD")) {
    SOLARCHVISION_hold_project();
  }

  else if (Command_CAPITAL.equals("FETCH")) {
    SOLARCHVISION_fetch_project();
  }

  else if (Command_CAPITAL.equals("IMPORT")) {
    selectInput("Select OBJ file to import:", "SOLARCHVISION_SelectFile_Import_3DModel");
  }

  else if (Command_CAPITAL.equals("EXECUTE")) {
    selectInput("Select TXT file to execute:", "SOLARCHVISION_SelectFile_Execute_CommandFile");
  }

  else if (Command_CAPITAL.equals("EXPORT.OBJ.TIMESERIES")) {
    SOLARCHVISION_export_objects_OBJ_timeSeries();
  }

  else if (Command_CAPITAL.equals("EXPORT.OBJ.DATESERIES")) {
    SOLARCHVISION_export_objects_OBJ_dateSeries();
  }

  else if (Command_CAPITAL.equals("EXPORT.OBJ")) {
    SOLARCHVISION_export_objects_OBJ("");
  }

  else if (Command_CAPITAL.equals("EXPORT.RAD")) {
    SOLARCHVISION_export_objects_RAD();
  }

  else if (Command_CAPITAL.equals("EXPORT.SCR")) {
    SOLARCHVISION_export_objects_SCR();
  }

  else if (Command_CAPITAL.equals("QUIT")) {
    exit();
  }





  else if (Command_CAPITAL.equals("MOVE")) {
    if (parts.length > 1) {
      float dx = 0;
      float dy = 0;
      float dz = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("dx")) dx = float(parameters[1]);
          else if (low_case.equals("dy")) dy = float(parameters[1]);
          else if (low_case.equals("dz")) dz = float(parameters[1]);
        }
        else {
               if (q == 1) dx = float(parameters[0]);
          else if (q == 2) dy = float(parameters[0]);
          else if (q == 3) dz = float(parameters[0]);
        }
      }
      Move3D.selection(dx, dy, dz);
      SOLARCHVISION_view_changed();
    }
    else {
      return_message = "Move dx=? dy=? dz=?";

      UI_toolBar.highlight("MV³");
      UI_toolBar.revise();
    }
  }

  else if ((Command_CAPITAL.equals("ROTATE")) ||
          (Command_CAPITAL.equals("ROTATEX")) ||
          (Command_CAPITAL.equals("ROTATEY")) ||
          (Command_CAPITAL.equals("ROTATEZ"))) {
    if (parts.length > 1) {
      int v = 2;
      if (Command_CAPITAL.equals("ROTATEX")) v = 0;
      if (Command_CAPITAL.equals("ROTATEY")) v = 1;
      if (Command_CAPITAL.equals("ROTATEZ")) v = 2;

      float x = 0;
      float y = 0;
      float z = 0;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("r")) r = float(parameters[1]);
          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
        }
        else {
          if (q == 1) r = float(parameters[0]);
        }
      }
      Rotate3D.selection(x, y, z, r, v);
      SOLARCHVISION_view_changed();
    }
    else {
      return_message = "Rotate[X|Y|Z] r=? x=? y=? z=?";

      UI_set_to_Modify_Rotate(2);
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("SCALE")) {
    if (parts.length > 1) {
      float sx = 1;
      float sy = 1;
      float sz = 1;

      float x = 0;
      float y = 0;
      float z = 0;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("s")) {sx = float(parameters[1]); sy = sx; sz = sx;}
          else if (low_case.equals("sxy")) {sx = float(parameters[1]); sy = sx;}
          else if (low_case.equals("syz")) {sy = float(parameters[1]); sz = sy;}
          else if (low_case.equals("szx")) {sz = float(parameters[1]); sx = sz;}
          else if (low_case.equals("sx")) sx = float(parameters[1]);
          else if (low_case.equals("sy")) sy = float(parameters[1]);
          else if (low_case.equals("sz")) sz = float(parameters[1]);
          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
        }
        else {
          if (q == 1) {sx = float(parameters[0]); sy = sx; sz = sx;}
        }
      }
      Scale3D.selection(x, y, z, sx, sy, sz);
      SOLARCHVISION_view_changed();
    }
    else {
      return_message = "Scale s=? sx=? sy=? sz=? x=? y=? z=?";

      UI_toolBar.highlight("SC³");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("DELETE")) {
    if (parts.length > 1) {
      for (int q = 1; q < parts.length; q++) {
        String low_case = parts[q].toLowerCase();
             if (low_case.equals("all")) SOLARCHVISION_deleteAll();
        else if (low_case.equals("groups")) allGroups.makeEmpty(0);
        else if (low_case.equals("model2ds")) allModel2Ds.makeEmpty(0);
        else if (low_case.equals("model1ds")) allModel1Ds.makeEmpty(0);
        else if (low_case.equals("faces")) allFaces.makeEmpty(0);
        else if (low_case.equals("lines")) allPolylines.makeEmpty(0);
        else if (low_case.equals("solids")) allSolids.makeEmpty(0);
        else if (low_case.equals("sections")) allSections.makeEmpty(0);
        else if (low_case.equals("cameras")) allCameras.makeEmpty(0);
        else if (low_case.equals("vertices")) Delete3D.isolatedVertices_Selection();
        else if (low_case.equals("selection")) Delete3D.selection();
      }
      SOLARCHVISION_view_changed();
    }
    else {
      return_message = "Delete all/selection/groups/model2ds/model1ds/vertices/faces/solids/sections/cameras";
    }
  }

  else if (Command_CAPITAL.equals("COPY")) {
    if (parts.length > 1) {
      int n = 1;
      float dx = 0;
      float dy = 0;
      float dz = 0;
      float rx = 0;
      float ry = 0;
      float rz = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("n")) n = int(parameters[1]);
          else if (low_case.equals("dx")) dx = float(parameters[1]);
          else if (low_case.equals("dy")) dy = float(parameters[1]);
          else if (low_case.equals("dz")) dz = float(parameters[1]);
          else if (low_case.equals("rx")) rx = float(parameters[1]);
          else if (low_case.equals("ry")) ry = float(parameters[1]);
          else if (low_case.equals("rz")) rz = float(parameters[1]);
        }
      }

      for (int q = 0; q < n; q++) {
        Clone3D.selection(true);
        if ((dx != 0) || (dy != 0) || (dz != 0)) Move3D.selection(dx, dy, dz);
        if (rx != 0) Rotate3D.selection(0, 0, 0, rx, 0);
        if (ry != 0) Rotate3D.selection(0, 0, 0, ry, 1);
        if (rz != 0) Rotate3D.selection(0, 0, 0, rz, 2);
      }

      SOLARCHVISION_view_changed();
    }
    else {
      return_message = "Copy n=? dx=? dy=? dz=? rx=? ry=? rz=?";
    }
  }

  else if (Command_CAPITAL.equals("SELECT")) {
    if (parts.length > 1) {
      for (int q = 1; q < parts.length; q++) {
        String low_case = parts[q].toLowerCase();
             if (low_case.equals("groups")) SOLARCHVISION_switch_category(ObjectCategory.GROUP);
        else if (low_case.equals("model2ds")) SOLARCHVISION_switch_category(ObjectCategory.MODEL2D);
        else if (low_case.equals("model1ds")) SOLARCHVISION_switch_category(ObjectCategory.MODEL1D);
        else if (low_case.equals("vertices")) SOLARCHVISION_switch_category(ObjectCategory.VERTEX);
        else if (low_case.equals("faces")) SOLARCHVISION_switch_category(ObjectCategory.FACE);
        else if (low_case.equals("lines")) SOLARCHVISION_switch_category(ObjectCategory.POLYLINE);
        else if (low_case.equals("solids")) SOLARCHVISION_switch_category(ObjectCategory.SOLID);
        else if (low_case.equals("sections")) SOLARCHVISION_switch_category(ObjectCategory.SECTION);
        else if (low_case.equals("cameras")) SOLARCHVISION_switch_category(ObjectCategory.CAMERA);
        else if (low_case.equals("landpoints")) SOLARCHVISION_switch_category(ObjectCategory.LANDPOINT);
      }

      for (int q = 1; q < parts.length; q++) {
        String low_case = parts[q].toLowerCase();
             if (low_case.equals("all")) Select3D.selectAll();
        else if (low_case.equals("invert")) Select3D.invertSelection();
        else if (low_case.equals("nothing")) Select3D.deselectAll();
        else if (low_case.equals("last")) Select3D.selectLast();
      }

      SOLARCHVISION_view_changed();
    }
    else {
      return_message = "Select all/last/nothing/invert/groups/model2ds/model1ds/vertices/faces/solids/sections/cameras/landpoint";
    }
  }






  else if (Command_CAPITAL.equals("PERSON")) {
    if (parts.length > 1) {
      String t = "PEOPLE";
      int m = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
        }
      }
      allModel2Ds.create(t, m, x, y, z, 2.5);
      SOLARCHVISION_view_changed();
    }
    else {
      return_message = "2Dman m=? x=? y=? z=?";

      UI_set_to_Create_Person();
      UI_toolBar.highlight("Person");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("TREE")) {
    if (parts.length > 1) {
      String t = "TREES";
      int m = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float h = 5.0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("h")) h = float(parameters[1]);
        }
      }
      if (h != 0) {
        allModel2Ds.create(t, m, x, y, z, h);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "2Dtree m=? x=? y=? z=? h=?";

      UI_set_to_Create_Tree();
      UI_toolBar.highlight("2D-Tree");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("FRACTALTREE")) {
    if (parts.length > 1) {
      int m = 0;
      int seed = 0; //PlantSeed
      int degree = 5; //PlantDegree
      float x = 0;
      float y = 0;
      float z = 0;
      float h = 5.0;
      float r = floor(random(360));
      float tilt = floor(random(90));
      float twist = floor(random(360));
      float ratio = 0.5 + random(0.5);
      float base = 0.0 + random(2.0);
      float Tk = 1.0; //TrunkSize
      float Lf = 0.1; //LeafSize

      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("seed")) seed = int(parameters[1]);
          else if (low_case.equals("degree")) degree = int(parameters[1]);
          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("h")) h = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]) * PI / 180.0;
          else if (low_case.equals("tilt")) tilt = float(parameters[1]) * PI / 180.0;
          else if (low_case.equals("twist")) twist = float(parameters[1]) * PI / 180.0;
          else if (low_case.equals("ratio")) ratio = float(parameters[1]);
          else if (low_case.equals("base")) base = float(parameters[1]);
          else if (low_case.equals("tk")) Tk = float(parameters[1]);
          else if (low_case.equals("lf")) Lf = float(parameters[1]);
        }
      }
      if (h != 0) {
        allModel1Ds.create(m, seed, degree, x, y, z, h, r, tilt, twist, ratio, base, Tk, Lf);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "3Dtree m=? degree=? seed=? x=? y=? z=? h=? r=? tilt=? twist=? ratio=? base=? Tk=? Lf=?";

      UI_set_to_Create_allModel1Ds();
      UI_toolBar.highlight("3D-Tree");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("BOX2P")) {
    if (parts.length > 1) {
      int m = -1;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x1 = 0;
      float y1 = 0;
      float z1 = 0;
      float x2 = 0;
      float y2 = 0;
      float z2 = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x1")) x1 = float(parameters[1]);
          else if (low_case.equals("y1")) y1 = float(parameters[1]);
          else if (low_case.equals("z1")) z1 = float(parameters[1]);
          else if (low_case.equals("x2")) x2 = float(parameters[1]);
          else if (low_case.equals("y2")) y2 = float(parameters[1]);
          else if (low_case.equals("z2")) z2 = float(parameters[1]);
        }
      }
      if ((x2 - x1 != 0) && (y2 - y1 != 0) && (z2 - z1 != 0)) {
        Create3D.add_Box_Corners(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Box2P m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=?";

      UI_set_to_Create_Box();
      UI_toolBar.highlight("Box");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("BOX")) {
    if (parts.length > 1) {
      int m = -1;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float dx = 6;
      float dy = 6;
      float dz = 6;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("dx")) dx = float(parameters[1]);
          else if (low_case.equals("dy")) dy = float(parameters[1]);
          else if (low_case.equals("dz")) dz = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
        }
      }
      if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_Box_Core(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Box m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?";

      UI_set_to_Create_Box();
      UI_toolBar.highlight("Box");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("HOUSE3")) {
    if (parts.length > 1) {
      int m = -1;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float dx = 6;
      float dy = 6;
      float dz = 6;
      float h = 3;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("dx")) dx = float(parameters[1]);
          else if (low_case.equals("dy")) dy = float(parameters[1]);
          else if (low_case.equals("dz")) dz = float(parameters[1]);
          else if (low_case.equals("h")) h = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
        }
      }
      if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_House3_Core(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, h, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "House3 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?";

      UI_set_to_Create_House3();
      UI_toolBar.highlight("House3");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("HOUSE2")) {
    if (parts.length > 1) {
      int m = -1;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float dx = 6;
      float dy = 6;
      float dz = 6;
      float h = 3;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("dx")) dx = float(parameters[1]);
          else if (low_case.equals("dy")) dy = float(parameters[1]);
          else if (low_case.equals("dz")) dz = float(parameters[1]);
          else if (low_case.equals("h")) h = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
        }
      }
      if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_House2_Core(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, h, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "House2 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?";

      UI_set_to_Create_House2();
      UI_toolBar.highlight("House2");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("HOUSE1")) {
    if (parts.length > 1) {
      int m = -1;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float dx = 6;
      float dy = 6;
      float dz = 6;
      float h = 3;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("dx")) dx = float(parameters[1]);
          else if (low_case.equals("dy")) dy = float(parameters[1]);
          else if (low_case.equals("dz")) dz = float(parameters[1]);
          else if (low_case.equals("h")) h = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
        }
      }
      if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_House1_Core(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, h, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "House1 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?";

      UI_set_to_Create_House2();
      UI_toolBar.highlight("House1");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("CYLINDER")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 16;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float d = 6;
      float h = 6;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("d")) d = float(parameters[1]);
          else if (low_case.equals("h")) h = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
          else if (low_case.equals("deg")) deg = int(parameters[1]);
        }
      }
      if ((d != 0) && (h != 0)) {
        Create3D.add_SuperCylinder(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, 0.5 * d, 0.5 * h, deg, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Cylinder m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?";

      UI_set_to_Create_Cylinder();
      UI_toolBar.highlight("Cylinder");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("SPHERE")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 3;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float d = 6;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("d")) d = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
          else if (low_case.equals("deg")) deg = int(parameters[1]);
        }
      }
      if (d != 0) {
        Create3D.add_CrystalSphere(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, deg, 0, 90 + r); // passing with isSky:0
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Sphere m=? tes=? lyr=? x=? y=? z=? d=? deg=? r=?";

      UI_set_to_Create_Sphere();
      UI_toolBar.highlight("Sphere");
      UI_toolBar.revise();
    }
  }


  else if (Command_CAPITAL.equals("SUPERSPHERE")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 3;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float dx = 6;
      float dy = 6;
      float dz = 6;
      float px = 2;
      float py = 2;
      float pz = 2;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("dx")) dx = float(parameters[1]);
          else if (low_case.equals("dy")) dy = float(parameters[1]);
          else if (low_case.equals("dz")) dz = float(parameters[1]);
          else if (low_case.equals("px")) px = float(parameters[1]);
          else if (low_case.equals("py")) py = float(parameters[1]);
          else if (low_case.equals("pz")) pz = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
          else if (low_case.equals("deg")) deg = int(parameters[1]);
        }
      }
      if ((dx != 0) && (dy != 0) && (dz != 0) && (px > 0) && (py > 0) && (pz > 0)) {
        Create3D.add_SuperSphere(m, tes, lyr, vsb, wgt, clz, x, y, z, px, py, pz, 0.5 * dx, 0.5 * dy, 0.5 * dz, deg, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "SuperSphere m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? px=? py=? pz=? deg=? r=?";

      UI_set_to_Create_Sphere();
      UI_toolBar.highlight("Sphere");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("CUSHION")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 3;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float dx = 6;
      float dy = 6;
      float dz = 6;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("dx")) dx = float(parameters[1]);
          else if (low_case.equals("dy")) dy = float(parameters[1]);
          else if (low_case.equals("dz")) dz = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
          else if (low_case.equals("deg")) deg = int(parameters[1]);
        }
      }
      if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_SuperSphere(m, tes, lyr, vsb, wgt, clz, x, y, z, CubePower, CubePower, 2, 0.5 * dx, 0.5 * dy, 0.5 * dz, deg, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Cushion m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?";

      UI_set_to_Create_Cushion();
      UI_toolBar.highlight("Cushion");
      UI_toolBar.revise();
    }
  }


  else if (Command_CAPITAL.equals("OCTAHEDRON")) {
    if (parts.length > 1) {
      int m = 7;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float dx = 6;
      float dy = 6;
      float dz = 6;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("dx")) dx = float(parameters[1]);
          else if (low_case.equals("dy")) dy = float(parameters[1]);
          else if (low_case.equals("dz")) dz = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
        }
      }
      if ((dx != 0) && (dy != 0) && (dz != 0)) {
        Create3D.add_Octahedron(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * dx, 0.5 * dy, 0.5 * dz, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Octahedron m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?";

      UI_set_to_Create_Octahedron();
      UI_toolBar.highlight("Octahedron");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("ICOSAHEDRON")) {
    if (parts.length > 1) {
      int m = 7;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float d = 6;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("d")) d = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
        }
      }
      if (d != 0) {
        Create3D.add_Icosahedron(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Icosahedron m=? tes=? lyr=? x=? y=? z=? d=? r=?";

      UI_set_to_Create_Icosahedron();
      UI_toolBar.highlight("Icosahedron");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("POLYGONEXTRUDE")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float d = 6;
      float h = 6;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("d")) d = float(parameters[1]);
          else if (low_case.equals("h")) h = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
          else if (low_case.equals("deg")) deg = int(parameters[1]);
        }
      }
      if ((d != 0) && (h != 0)) {
        Create3D.add_PolygonExtrude(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, h, deg, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "PolygonExtrude m=? tes=? lyr=? x=? y=? z=? d=? h=? deg=? r=?";

      UI_set_to_Create_Extrude();
      UI_toolBar.highlight("Extrude");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("POLYGONHYPER")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float d = 6;
      float h = 6;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("d")) d = float(parameters[1]);
          else if (low_case.equals("h")) h = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
          else if (low_case.equals("deg")) deg = int(parameters[1]);
        }
      }
      if ((d != 0) && (h != 0)) {
        Create3D.add_PolygonHyper(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, h, deg, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "PolygonHyper m=? tes=? lyr=? x=? y=? z=? d=? h=? deg=? r=?";

      UI_set_to_Create_Hyper();
      UI_toolBar.highlight("Hyper");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("POLYGONMESH")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float d = 6;
      float r = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("d")) d = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
          else if (low_case.equals("deg")) deg = int(parameters[1]);
        }
      }
      if (d != 0) {
        Create3D.add_PolygonMesh(m, tes, lyr, vsb, wgt, clz, x, y, z, 0.5 * d, deg, r);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "PolygonMesh m=? tes=? lyr=? x=? y=? z=? d=? deg=? r=?";

      UI_set_to_Create_Plane();
      UI_toolBar.highlight("Polygon");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("MESH2")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x1 = 0;
      float y1 = 0;
      float z1 = 0;
      float x2 = 0;
      float y2 = 0;
      float z2 = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x1")) x1 = float(parameters[1]);
          else if (low_case.equals("y1")) y1 = float(parameters[1]);
          else if (low_case.equals("z1")) z1 = float(parameters[1]);
          else if (low_case.equals("x2")) x2 = float(parameters[1]);
          else if (low_case.equals("y2")) y2 = float(parameters[1]);
          else if (low_case.equals("z2")) z2 = float(parameters[1]);
        }
      }
      if ((x1 == x2) || (y1 == y2) || (z1 == z2)) {
        Create3D.add_Mesh2(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Mesh2 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=?";
    }
  }

  else if (Command_CAPITAL.equals("MESH3")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x1 = 0;
      float y1 = 0;
      float z1 = 0;
      float x2 = 0;
      float y2 = 0;
      float z2 = 0;
      float x3 = 0;
      float y3 = 0;
      float z3 = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x1")) x1 = float(parameters[1]);
          else if (low_case.equals("y1")) y1 = float(parameters[1]);
          else if (low_case.equals("z1")) z1 = float(parameters[1]);
          else if (low_case.equals("x2")) x2 = float(parameters[1]);
          else if (low_case.equals("y2")) y2 = float(parameters[1]);
          else if (low_case.equals("z2")) z2 = float(parameters[1]);
          else if (low_case.equals("x3")) x3 = float(parameters[1]);
          else if (low_case.equals("y3")) y3 = float(parameters[1]);
          else if (low_case.equals("z3")) z3 = float(parameters[1]);
        }
      }
      {
        Create3D.add_Mesh3(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Mesh3 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=?";
    }
  }

  else if (Command_CAPITAL.equals("MESH4")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x1 = 0;
      float y1 = 0;
      float z1 = 0;
      float x2 = 0;
      float y2 = 0;
      float z2 = 0;
      float x3 = 0;
      float y3 = 0;
      float z3 = 0;
      float x4 = 0;
      float y4 = 0;
      float z4 = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x1")) x1 = float(parameters[1]);
          else if (low_case.equals("y1")) y1 = float(parameters[1]);
          else if (low_case.equals("z1")) z1 = float(parameters[1]);
          else if (low_case.equals("x2")) x2 = float(parameters[1]);
          else if (low_case.equals("y2")) y2 = float(parameters[1]);
          else if (low_case.equals("z2")) z2 = float(parameters[1]);
          else if (low_case.equals("x3")) x3 = float(parameters[1]);
          else if (low_case.equals("y3")) y3 = float(parameters[1]);
          else if (low_case.equals("z3")) z3 = float(parameters[1]);
          else if (low_case.equals("x4")) x4 = float(parameters[1]);
          else if (low_case.equals("y4")) y4 = float(parameters[1]);
          else if (low_case.equals("z4")) z4 = float(parameters[1]);
        }
      }
      {
        Create3D.add_Mesh4(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Mesh4 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=? x4=? y4=? z4=?";
    }
  }

  else if (Command_CAPITAL.equals("MESH5")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x1 = 0;
      float y1 = 0;
      float z1 = 0;
      float x2 = 0;
      float y2 = 0;
      float z2 = 0;
      float x3 = 0;
      float y3 = 0;
      float z3 = 0;
      float x4 = 0;
      float y4 = 0;
      float z4 = 0;
      float x5 = 0;
      float y5 = 0;
      float z5 = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x1")) x1 = float(parameters[1]);
          else if (low_case.equals("y1")) y1 = float(parameters[1]);
          else if (low_case.equals("z1")) z1 = float(parameters[1]);
          else if (low_case.equals("x2")) x2 = float(parameters[1]);
          else if (low_case.equals("y2")) y2 = float(parameters[1]);
          else if (low_case.equals("z2")) z2 = float(parameters[1]);
          else if (low_case.equals("x3")) x3 = float(parameters[1]);
          else if (low_case.equals("y3")) y3 = float(parameters[1]);
          else if (low_case.equals("z3")) z3 = float(parameters[1]);
          else if (low_case.equals("x4")) x4 = float(parameters[1]);
          else if (low_case.equals("y4")) y4 = float(parameters[1]);
          else if (low_case.equals("z4")) z4 = float(parameters[1]);
          else if (low_case.equals("x5")) x5 = float(parameters[1]);
          else if (low_case.equals("y5")) y5 = float(parameters[1]);
          else if (low_case.equals("z5")) z5 = float(parameters[1]);
        }
      }
      {
        Create3D.add_Mesh5(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, x5, y5, z5);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Mesh5 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=? x4=? y4=? z4=? x5=? y5=? z5=?";
    }
  }

  else if (Command_CAPITAL.equals("MESH6")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x1 = 0;
      float y1 = 0;
      float z1 = 0;
      float x2 = 0;
      float y2 = 0;
      float z2 = 0;
      float x3 = 0;
      float y3 = 0;
      float z3 = 0;
      float x4 = 0;
      float y4 = 0;
      float z4 = 0;
      float x5 = 0;
      float y5 = 0;
      float z5 = 0;
      float x6 = 0;
      float y6 = 0;
      float z6 = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x1")) x1 = float(parameters[1]);
          else if (low_case.equals("y1")) y1 = float(parameters[1]);
          else if (low_case.equals("z1")) z1 = float(parameters[1]);
          else if (low_case.equals("x2")) x2 = float(parameters[1]);
          else if (low_case.equals("y2")) y2 = float(parameters[1]);
          else if (low_case.equals("z2")) z2 = float(parameters[1]);
          else if (low_case.equals("x3")) x3 = float(parameters[1]);
          else if (low_case.equals("y3")) y3 = float(parameters[1]);
          else if (low_case.equals("z3")) z3 = float(parameters[1]);
          else if (low_case.equals("x4")) x4 = float(parameters[1]);
          else if (low_case.equals("y4")) y4 = float(parameters[1]);
          else if (low_case.equals("z4")) z4 = float(parameters[1]);
          else if (low_case.equals("x5")) x5 = float(parameters[1]);
          else if (low_case.equals("y5")) y5 = float(parameters[1]);
          else if (low_case.equals("z5")) z5 = float(parameters[1]);
          else if (low_case.equals("x6")) x6 = float(parameters[1]);
          else if (low_case.equals("y6")) y6 = float(parameters[1]);
          else if (low_case.equals("z6")) z6 = float(parameters[1]);
        }
      }
      {
        Create3D.add_Mesh6(m, tes, lyr, vsb, wgt, clz, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, x5, y5, z5, x6, y6, z6);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Mesh6 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=? x4=? y4=? z4=? x5=? y5=? z5=? x6=? y6=? z6=?";
    }
  }

  else if (Command_CAPITAL.equals("H_SHADE")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float d = 0;
      float w = 0;
      float a = 0;
      float b = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("d")) d = float(parameters[1]);
          else if (low_case.equals("w")) w = float(parameters[1]);
          else if (low_case.equals("a")) a = float(parameters[1]);
          else if (low_case.equals("b")) b = float(parameters[1]);
        }
      }
      if ((d != 0) && (w != 0)) {
        Create3D.add_H_shade(m, tes, lyr, vsb, wgt, clz, x, y, z, d, w, a, b);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "H_Shade m=? tes=? lyr=? x=? y=? z=? d=? w=? a=? b=?";
    }
  }

  else if (Command_CAPITAL.equals("V_SHADE")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float x = 0;
      float y = 0;
      float z = 0;
      float d = 0;
      float h = 0;
      float a = 0;
      float b = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);

          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("d")) d = float(parameters[1]);
          else if (low_case.equals("h")) h = float(parameters[1]);
          else if (low_case.equals("a")) a = float(parameters[1]);
          else if (low_case.equals("b")) b = float(parameters[1]);
        }
      }
      if ((d != 0) && (h != 0)) {
        Create3D.add_V_shade(m, tes, lyr, vsb, wgt, clz, x, y, z, h, d, a, b);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "V_Shade m=? tes=? lyr=? x=? y=? z=? d=? h=? a=? b=?";
    }
  }

  else if (Command_CAPITAL.equals("SOLID")) {
    if (parts.length > 1) {
      float v = 1;
      float x = 0;
      float y = 0;
      float z = 0;
      float px = 2;
      float py = 2;
      float pz = 2;
      float sx = 1;
      float sy = 1;
      float sz = 1;
      float rx = 0;
      float ry = 0;
      float rz = 0;
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("v")) v = float(parameters[1]);
          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("px")) px = float(parameters[1]);
          else if (low_case.equals("py")) py = float(parameters[1]);
          else if (low_case.equals("pz")) pz = float(parameters[1]);
          else if (low_case.equals("sx")) sx = float(parameters[1]);
          else if (low_case.equals("sy")) sy = float(parameters[1]);
          else if (low_case.equals("sz")) sz = float(parameters[1]);
          else if (low_case.equals("rx")) rx = float(parameters[1]);
          else if (low_case.equals("ry")) ry = float(parameters[1]);
          else if (low_case.equals("rz")) rz = float(parameters[1]);
        }
      }
      if ((px != 0) && (py != 0) && (pz != 0) && (sx != 0) && (sy != 0) && (sz != 0) && (v != 0)) {
        allSolids.create(x, y, z, px, py, pz, sx, sy, sz, rx, ry, rz, v);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Solid x=? y=? z=? px=? py=? pz=? sx=? sy=? sz=? rx=? ry=? rz=? v=?";

      UI_set_to_Create_Solid();
      UI_toolBar.highlight("SLD");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("SECTION")) {
    if (parts.length > 1) {

      float x = 0;
      float y = 0;
      float z = 0;
      float r = 0;
      float u = 20;
      float v = 20;

      int t = 1;
      int i = 200;
      int j = 200;

      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
          else if (low_case.equals("u")) u = float(parameters[1]);
          else if (low_case.equals("v")) v = float(parameters[1]);
          else if (low_case.equals("t")) t = int(parameters[1]);
          else if (low_case.equals("i")) i = int(parameters[1]);
          else if (low_case.equals("j")) j = int(parameters[1]);

        }
      }
      if ((t > 0) && (i > 0) && (j > 0) && (u > 0) && (v > 0)) {
        allSections.create(x, y, z, r, u, v, t, i, j);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Section x=? y=? z=? r=? u=? v=? t=? i=? j=?";

      UI_set_to_Create_Section();
      UI_toolBar.highlight("SEC");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("CAMERA")) {
    if (parts.length > 1) {

      float px = 0;
      float py = 0;
      float pz = 0;
      float pt = 1;
      float rx = 0;
      float ry = 0;
      float rz = 0;
      float rt = 5;
      float a = 60;
      int t = 1;

      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("px")) px = float(parameters[1]);
          else if (low_case.equals("py")) py = float(parameters[1]);
          else if (low_case.equals("pz")) pz = float(parameters[1]);
          else if (low_case.equals("pt")) pt = float(parameters[1]);
          else if (low_case.equals("rx")) rx = float(parameters[1]);
          else if (low_case.equals("ry")) ry = float(parameters[1]);
          else if (low_case.equals("rz")) rz = float(parameters[1]);
          else if (low_case.equals("rt")) rt = float(parameters[1]);
          else if (low_case.equals("a")) a = float(parameters[1]);
          else if (low_case.equals("t")) t = int(parameters[1]);
        }
      }
      if (a != 0) {
        allCameras.create(px, py, pz, pt, rx, ry, rz, rt, a, t);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Camera px=? py=? pz=? pt=? rx=? ry=? rz=? rt=? a=? t=?";

      UI_set_to_Create_Camera();
      UI_toolBar.highlight("CAM");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("PLOYLINE")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 0;
      float[][] points = new float [0][3];
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);
          else if (low_case.equals("wgt")) wgt = int(parameters[1]);
          else if (low_case.equals("clz")) clz = int(parameters[1]);
        }
        else {
          String[] xyz = split(parts[q], ",");
          if (xyz.length > 2) {
            float[][] newPoint = {{float(xyz[0]), float(xyz[1]), float(xyz[2])}};
            points = (float[][]) concat(points, newPoint);
          }
        }
      }
      if (points.length > 1) {
        allPolylines.add_Polyline(m, tes, lyr, vsb, wgt, clz, points);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Polyline m=? tes=? lyr=? xtr=? wgt=? clz=? x1,y1,z1 x2,y2,z2 etc.";

      UI_set_to_Create_Polyline();
      UI_toolBar.highlight("Polyline");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("ARC")) {
    if (parts.length > 1) {
      int m = 7;
      int deg = 6;
      int tes = 0;
      int lyr = 0;
      int vsb = 1;
      int wgt = 0;
      int clz = 1;
      float x = 0;
      float y = 0;
      float z = 0;
      float r = 0;
      float rot = 0;
      float ang = 360; // complete circle
      for (int q = 1; q < parts.length; q++) {
        String[] parameters = split(parts[q], '=');
        if (parameters.length > 1) {
          String low_case = parameters[0].toLowerCase();
               if (low_case.equals("m")) m = int(parameters[1]);
          else if (low_case.equals("tes")) tes = int(parameters[1]);
          else if (low_case.equals("lyr")) lyr = int(parameters[1]);
          else if (low_case.equals("wgt")) wgt = int(parameters[1]);
          else if (low_case.equals("clz")) clz = int(parameters[1]);
          else if (low_case.equals("x")) x = float(parameters[1]);
          else if (low_case.equals("y")) y = float(parameters[1]);
          else if (low_case.equals("z")) z = float(parameters[1]);
          else if (low_case.equals("r")) r = float(parameters[1]);
          else if (low_case.equals("rot")) rot = float(parameters[1]);
          else if (low_case.equals("ang")) ang = float(parameters[1]);
          else if (low_case.equals("deg")) deg = int(parameters[1]);
        }
      }
      if ((r != 0) && (deg > 2)) {
        allPolylines.add_Arc(m, tes, lyr, vsb, wgt, clz, x, y, z, r, deg, rot, ang);
        SOLARCHVISION_view_changed();
      }
    }
    else {
      return_message = "Arc m=? tes=? lyr=? xtr=? wgt=? clz=? x=? y=? z=? r=? deg=? rot=? ang=?";

      UI_set_to_Create_Polyline();
      UI_toolBar.highlight("Polyline");
      UI_toolBar.revise();
    }
  }

  else if (Command_CAPITAL.equals("PIVOT")) {
    if (parts.length > 1) {
      for (int q = 1; q < parts.length; q++) {
        String low_case = parts[q].toLowerCase();
             if (low_case.equals("minx")) UI_set_to_View_PivotX(-1);
        else if (low_case.equals("midx")) UI_set_to_View_PivotX(0);
        else if (low_case.equals("maxx")) UI_set_to_View_PivotX(1);
        else if (low_case.equals("miny")) UI_set_to_View_PivotY(-1);
        else if (low_case.equals("midy")) UI_set_to_View_PivotY(0);
        else if (low_case.equals("maxy")) UI_set_to_View_PivotY(1);
        else if (low_case.equals("minz")) UI_set_to_View_PivotZ(-1);
        else if (low_case.equals("midz")) UI_set_to_View_PivotZ(0);
        else if (low_case.equals("maxz")) UI_set_to_View_PivotZ(1);
      }
      SOLARCHVISION_view_changed();
    }
    else {
      return_message = "PIVOT minX midY maxZ or other variations";
    }
  }

  else if (Command_CAPITAL.equals("VERTEX>GROUP")) {
    Select3D.convert_Vertices_to_Groups();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("FACE>GROUP")) {
    Select3D.convert_Faces_to_Groups();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("GROUP>FACE")) {
    Select3D.convert_Groups_to_Faces();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("POLYLINE>GROUP")) {
    Select3D.convert_Polylines_to_Groups();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("GROUP>POLYLINE")) {
    Select3D.convert_Groups_to_Polylines();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("POLYLINE>VERTEX")) {
    Select3D.convert_Polylines_to_Vertices();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("VERTEX>POLYLINE")) {
    Select3D.convert_Vertices_to_Polylines();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("GROUP>VERTEX")) {
    Select3D.convert_Groups_to_Vertices();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("FACE>VERTEX")) {
    Select3D.convert_Faces_to_Vertices();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("VERTEX>FACE")) {
    Select3D.convert_Vertices_to_Faces();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("SOLID>GROUP")) {
    Select3D.convert_Solids_to_Groups();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("GROUP>SOLID")) {
    Select3D.convert_Groups_to_Solids();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("2D>GROUP")) {
    Select3D.convert_Model2Ds_to_Groups();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("GROUP>2D")) {
    Select3D.convert_Groups_to_Model2Ds();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("1D>GROUP")) {
    Select3D.convert_Model1Ds_to_Groups();
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("GROUP>1D")) {
    Select3D.convert_Groups_to_Model1Ds();
    SOLARCHVISION_view_changed();
  }

  else if (Command_CAPITAL.equals("DISTZ")) {
    UI_set_to_View_Truck(0);
    UI_toolBar.highlight("±CDZ");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("DISTC")) {
    UI_set_to_View_CameraDistance(0);
    UI_toolBar.highlight("±CDS");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("DISTP")) {
    UI_set_to_View_DistMouseXY(0);
    UI_toolBar.highlight("±CDM");
    UI_toolBar.revise();
  }


  else if (Command_CAPITAL.equals("SIZEALL")) {
    UI_set_to_View_AllModelSize();
    UI_toolBar.highlight("±SA");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("SIZESKY")) {
    UI_set_to_View_SkydomeSize();
    UI_toolBar.highlight("±SK");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("SIZE3D")) {
    UI_set_to_View_3DModelSize();
    UI_toolBar.highlight("±SZ");
    UI_toolBar.revise();
  }

  else if (Command_CAPITAL.equals("ALLVIEWPORTS")) {
    UI_set_to_Viewport(0);
    UI_toolBar.highlight("AllViewports");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("ENLARGE3D")) {
    UI_set_to_Viewport(1);
    UI_toolBar.highlight("Expand3DView");
    UI_toolBar.revise();
  }

  else if (Command_CAPITAL.equals("LOOKORG")) {
    UI_set_to_View_LookAtOrigin(0);
    UI_toolBar.highlight("LAO");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("LOOKDIR")) {
    UI_set_to_View_LookAtDirection(0);
    UI_toolBar.highlight("LAD");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("LOOKSEL")) {
    UI_set_to_View_LookAtSelection(0);
    UI_toolBar.highlight("LAS");
    UI_toolBar.revise();
  }

  else if (Command_CAPITAL.equals("TRUCKZ")) {
    UI_set_to_View_Truck(0);
    UI_toolBar.highlight("DIz");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("TRUCKX")) {
    UI_set_to_View_Truck(1);
    UI_toolBar.highlight("DIx");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("TRUCKY")) {
    UI_set_to_View_Truck(2);
    UI_toolBar.highlight("DIy");
    UI_toolBar.revise();
  }

  else if (Command_CAPITAL.equals("TARGETROLL")) {
    UI_set_to_View_TargetRoll(0);
    UI_toolBar.highlight("TRL");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("TARGETROLLZ")) {
    UI_set_to_View_TargetRoll(1);
    UI_toolBar.highlight("TRLz");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("TARGETROLLXY")) {
    UI_set_to_View_TargetRoll(2);
    UI_toolBar.highlight("TRLxy");
    UI_toolBar.revise();
  }

  else if (Command_CAPITAL.equals("CAMERAROLL")) {
    UI_set_to_View_CameraRoll(0);
    UI_toolBar.highlight("CRL");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("CAMERAROLLZ")) {
    UI_set_to_View_CameraRoll(1);
    UI_toolBar.highlight("CRLz");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("CAMERAROLLXY")) {
    UI_set_to_View_CameraRoll(2);
    UI_toolBar.highlight("CRLxy");
    UI_toolBar.revise();
  }


  else if (Command_CAPITAL.equals("ORBIT")) {
    UI_set_to_View_Orbit(0);
    UI_toolBar.highlight("OR");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("ORBITZ")) {
    UI_set_to_View_Orbit(1);
    UI_toolBar.highlight("ORz");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("ORBITXY")) {
    UI_set_to_View_Orbit(2);
    UI_toolBar.highlight("ORxy");
    UI_toolBar.revise();
  }

  else if (Command_CAPITAL.equals("LANDORBIT")) {
    UI_set_to_View_LandOrbit(0);
    UI_toolBar.highlight("LNOR");
    UI_toolBar.revise();
  }

  else if (Command_CAPITAL.equals("PAN")) {
    UI_set_to_View_Pan(0);
    UI_toolBar.highlight("Pan");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("PANX")) {
    UI_set_to_View_Pan(1);
    UI_toolBar.highlight("PanX");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("PANY")) {
    UI_set_to_View_Pan(2);
    UI_toolBar.highlight("PanY");
    UI_toolBar.revise();
  }

  else if (Command_CAPITAL.equals("ZOOM")) {
    UI_set_to_View_ZOOM(0);
    UI_toolBar.highlight("±ZM");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("NORMALZOOM")) {
    UI_set_to_View_ZOOM(1);
    UI_toolBar.highlight("0ZM");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("ORTHOGRAPHIC")) {
    UI_set_to_View_ProjectionType(0);
    UI_toolBar.highlight("P<>");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("PERSPECTIVE")) {
    UI_set_to_View_ProjectionType(1);
    UI_toolBar.highlight("P><");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("TOP")) {
    UI_set_to_View_3DViewPoint(0);
    UI_toolBar.highlight("Top");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("FRONT")) {
    UI_set_to_View_3DViewPoint(1);
    UI_toolBar.highlight("Front");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("LEFT")) {
    UI_set_to_View_3DViewPoint(2);
    UI_toolBar.highlight("Left");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("BACK")) {
    UI_set_to_View_3DViewPoint(3);
    UI_toolBar.highlight("Back");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("RIGHT")) {
    UI_set_to_View_3DViewPoint(4);
    UI_toolBar.highlight("Right");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("BOTTOM")) {
    UI_set_to_View_3DViewPoint(5);
    UI_toolBar.highlight("Bottom");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("S.W.")) {
    UI_set_to_View_3DViewPoint(6);
    UI_toolBar.highlight("S.W.");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("S.E.")) {
    UI_set_to_View_3DViewPoint(7);
    UI_toolBar.highlight("S.E.");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("N.E.")) {
    UI_set_to_View_3DViewPoint(8);
    UI_toolBar.highlight("N.E.");
    UI_toolBar.revise();
  }
  else if (Command_CAPITAL.equals("N.W.")) {
    UI_set_to_View_3DViewPoint(9);
    UI_toolBar.highlight("N.W.");
    UI_toolBar.revise();
  }


  else if (Command_CAPITAL.equals("SHADE.WIRE")) {
    WIN3D.FacesShade = SHADE.Surface_Wire;
    allFaces.displayEdges = true; //<<<<<<<<<<<<<<<
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("SHADE.BASE")) {
    WIN3D.FacesShade = SHADE.Surface_Base;
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("SHADE.WHITE")) {
    WIN3D.FacesShade = SHADE.Surface_White;
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("SHADE.MATERIALS")) {
    WIN3D.FacesShade = SHADE.Surface_Materials;
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("SHADE.GLOBAL")) {
    WIN3D.FacesShade = SHADE.Global_Solar;
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("SHADE.REAL")) {
    WIN3D.FacesShade = SHADE.Vertex_Solar;
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("SHADE.SOLID")) {
    WIN3D.FacesShade = SHADE.Vertex_Solid;
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("SHADE.ELEVATION")) {
    WIN3D.FacesShade = SHADE.Vertex_Elevation;
    SOLARCHVISION_view_changed();
  }
  else if (Command_CAPITAL.equals("RENDER.VIEWPORT")) {
    SOLARCHVISION_RenderViewport();
  }
  else if (Command_CAPITAL.equals("PREBAKE.VIEWPORT")) {
    SOLARCHVISION_preBakeViewport();
  }


  else if (Command_CAPITAL.equals("LONLAT")) {
    if (parts.length > 2) {

      STATION.setLatitude(float(parts[2]));
      STATION.setLongitude(float(parts[1]));

      SOLARCHVISION_update_station(1);
    }
    else {
      return_message = "LonLat ? ?";
    }
  }


  return return_message;
}



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








solarchvision_STATION[] NAEFposition_Ts;

void inputCoordinates_NAEFS () {

  String[] FileALL = loadStrings(Folder_Coordinates + "/NAEFS.txt");

  String lineSTR;

  int num_stn = FileALL.length - 1; // to skip the first description line

  NAEFposition_Ts = new solarchvision_STATION [num_stn];

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


    NAEFposition_Ts[f] = new solarchvision_STATION();

    NAEFposition_Ts[f].setCity(city);
    NAEFposition_Ts[f].setProvince(province);
    NAEFposition_Ts[f].setCountry(country);
    NAEFposition_Ts[f].setLatitude(latitude);
    NAEFposition_Ts[f].setLongitude(longitude);
    NAEFposition_Ts[f].setTimelong(funcs.roundTo(longitude, 15));
    NAEFposition_Ts[f].setElevation(elevation);
    NAEFposition_Ts[f].setFilename_NAEFS(filename);
  }
}



void download_ENSEMBLE_FORECAST (int THE_YEAR, int THE_MONTH, int THE_DAY, int THE_HOUR) {

  boolean new_files_downloaded = false;

  for (int f = 0; f < numberOfLayers; f++) {
    if (allLayers[f].name.equals("")) {
    } else {
      String FN = nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + nf(THE_DAY, 2) + nf(THE_HOUR, 2) + "_GEPS-NAEFS-RAW_" + STATION.getFilename_NAEFS() + "_" + allLayers[f].name + "_000-384.xml";

      String the_target = Folder_ENSEMBLE_FORECAST + "/" + FN;

      File dir = new File(the_target);
      if (!dir.isFile()) {

        String the_directory = nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + nf(THE_DAY, 2) + "/" + nf(THE_HOUR, 2) + "/" + allLayers[f].name + "/raw";
        String the_link = "https://dd.weather.gc.ca/" + nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + nf(THE_DAY, 2) + "/WXO-DD/ensemble/naefs/xml/" + the_directory + "/" + FN + ".bz2";
        the_target = the_target + ".bz2";

        println("Try downloading: " + the_link);

        try {
          saveBytes(the_target, loadBytes(the_link));

          new_files_downloaded = true;
        }
        catch (Exception e) {
          println("LINK NOT AVAILABLE:", the_link);
        }
      }
    }
  }



  if (new_files_downloaded) {

    String folder_inout = Folder_ENSEMBLE_FORECAST;
    // on Windows:
    //folder_inout = folder_inout.replace('/', char(92));

    {
      // on Windows:
      //String Command1 = "cmd /c \"\"C:\\Program Files (x86)\\7-Zip\\7z.exe\"\" e " + folder_inout + "\\*.bz2 -o" + folder_inout + " -y";
      String Command1 = "for bz2 in " + folder_inout + "/*.bz2; do 7z e $bz2 -o" + folder_inout + " -y; done";
      println(Command1);

      // on Windows:
      //String Command2 = "del " + folder_inout + "\\*.bz2 /q";
      String Command2 = "rm " + folder_inout + "/*.bz2";
      println(Command2);

      try {
        // on Windows:
        //launch(Command1 + " & " + Command2);
        exec(Command1 + " && " + Command2);
      }
      catch (Exception e) {
        println(e);
      }
    }

    Files_ENSEMBLE_FORECAST = OPESYS.getFiles(Folder_ENSEMBLE_FORECAST);

    ENSEMBLE_FORECAST_load = true;
    update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);
  }
}


void update_ENSEMBLE_FORECAST (int THE_YEAR, int THE_MONTH, int THE_DAY, int THE_HOUR) {

  Files_ENSEMBLE_FORECAST = OPESYS.getFiles(Folder_ENSEMBLE_FORECAST); // slow <<<<<<<<<<<< this line didn't work well below... but it is rather slow here!

  ENSEMBLE_FORECAST_values = new float [24][365][numberOfLayers][(1 + ENSEMBLE_FORECAST_end - ENSEMBLE_FORECAST_start)];
  ENSEMBLE_FORECAST_flags = new boolean [24][365][numberOfLayers][(1 + ENSEMBLE_FORECAST_end - ENSEMBLE_FORECAST_start)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < numberOfLayers; l++) {
        for (int k = 0; k < (1 + ENSEMBLE_FORECAST_end - ENSEMBLE_FORECAST_start); k++) {
          ENSEMBLE_FORECAST_values[i][j][l][k] = FLOAT_undefined;
          ENSEMBLE_FORECAST_flags[i][j][l][k] = false;
        }
      }
    }
  }

  if (ENSEMBLE_FORECAST_load) {

    for (int f = 0; f < numberOfLayers; f++) {
      if (allLayers[f].name.equals("")) {
      } else {
        String FN = nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + nf(THE_DAY, 2) + nf(THE_HOUR, 2) + "_GEPS-NAEFS-RAW_" + STATION.getFilename_NAEFS() + "_" + allLayers[f].name + "_000-384.xml";

        String the_source = Folder_ENSEMBLE_FORECAST + "/" + FN;

        File dir = new File(the_source);
        if (dir.isFile()) load_ENSEMBLE_FORECAST(the_source, f);
        else println("FILE NOT FOUND:", the_source);
      }
    }

    SOLARCHVISION_setDataFlags(dataID_ENSEMBLE_FORECAST);
    SOLARCHVISION_postProcess_fillGaps(dataID_ENSEMBLE_FORECAST);
    if (CLIMATIC_SolarForecast == 1) {
      SOLARCHVISION_postProcess_climaticSolarForecast();
    }
    else {
      SOLARCHVISION_postProcess_solarsUsingCloud(dataID_ENSEMBLE_FORECAST);
    }
    SOLARCHVISION_postProcess_solarEffects(dataID_ENSEMBLE_FORECAST);
    SOLARCHVISION_postProcess_developDATA(dataID_ENSEMBLE_FORECAST);

    WORLD.displayAll_NAEFS = 1;
    WORLD.displayNear_NAEFS = true;
  }

  WORLD.revise();
  STUDY.revise();
  ROLLOUT.revise();
  UI_caseBar.revise();
  SOLARCHVISION_view_changed();

  SampleMember_Start = ENSEMBLE_FORECAST_start;
  SampleMember_End = ENSEMBLE_FORECAST_end;
}







void load_ENSEMBLE_FORECAST (String FileName, int Load_Layer) {
  String lineSTR;
  String[] input;

  boolean continue_process = true;

  XML FileALL = parseXML("<?xml version='1.0' encoding='UTF-8'?>" + char(13) + "<empty>" + char(13) + "</empty>");

  try {
    FileALL = loadXML(FileName);
  }
  catch (Exception e) {
    println("Can't read:", FileName);
    continue_process = false;
  }

  if (continue_process) {

    //println(TIME.year, TIME.month, TIME.day, TIME.hour);

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

        //println(THE_YEAR, THE_MONTH, THE_DAY, THE_HOUR);

        int now_i = int(THE_HOUR);
        int now_j = TIME.convert2Date(THE_MONTH, THE_DAY);

        //println(now_i, now_j);

        now_i -= int(-STATION.getTimelong() / 15);
        if (now_i < 0) {
          now_i += 24;
          now_j -= 1;
          if (now_j < 0) {
            now_j += 365;
          }
        }

        //println(now_i, now_j);
        //println("-------------");

        XML[] _c = children0[Li].getChildren("model");
        //println("number of members:", _c.length);

        for (int Lk = 0; Lk < _c.length; Lk++) {
          int k = _c[Lk].getInt("id") - 1;

          if (k < (1 + ENSEMBLE_FORECAST_end - ENSEMBLE_FORECAST_start)) {

            ENSEMBLE_FORECAST_values[now_i][now_j][Load_Layer][k] = Float.valueOf(_c[Lk].getContent());
          }
        }
      }
    }
  }
}




void update_CLIMATE_CWEEDS () {

  CLIMATE_CWEEDS_values = new float [24][365][numberOfLayers][(1 + CLIMATE_CWEEDS_end - CLIMATE_CWEEDS_start)];
  CLIMATE_CWEEDS_flags = new boolean [24][365][numberOfLayers][(1 + CLIMATE_CWEEDS_end - CLIMATE_CWEEDS_start)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < numberOfLayers; l++) {
        for (int k = 0; k < (1 + CLIMATE_CWEEDS_end - CLIMATE_CWEEDS_start); k++) {
          CLIMATE_CWEEDS_values[i][j][l][k] = FLOAT_undefined;
          CLIMATE_CWEEDS_flags[i][j][l][k] = false;
        }
      }
    }
  }


  if (CLIMATE_CWEEDS_load) {

    String FN = STATION.getFilename_CWEEDS() + ".WY3";

    String the_source = Folder_CLIMATE_CWEEDS + "/" + FN;

    File dir = new File(the_source);
    if (dir.isFile()) load_CLIMATE_CWEEDS(the_source);
    else println("FILE NOT FOUND:", the_source);

  }

  WORLD.revise();
  STUDY.revise();
  ROLLOUT.revise();
  UI_caseBar.revise();
  SOLARCHVISION_view_changed();

  SampleYear_Start = CLIMATE_CWEEDS_start;
  SampleYear_End = CLIMATE_CWEEDS_end;
}


void load_CLIMATE_CWEEDS (String FileName) {
  String[] FileALL = loadStrings(FileName);

  String lineSTR;
  String[] input;


  println("lines = ", FileALL.length);

  for (int f = 1; f < FileALL.length; f++) {

    lineSTR = FileALL[f];
    //println(lineSTR);

    int CLIMATE_YEAR = int(lineSTR.substring(8, 12));
    int CLIMATE_MONTH = int(lineSTR.substring(12, 14));
    int CLIMATE_DAY = int(lineSTR.substring(14, 16));
    int CLIMATE_HOUR = int(lineSTR.substring(16, 18));

    //println(CLIMATE_YEAR, CLIMATE_MONTH, CLIMATE_DAY, CLIMATE_HOUR);

    int i = int(CLIMATE_HOUR) - 1;
    int j = TIME.convert2Date(CLIMATE_MONTH, CLIMATE_DAY);
    int k = (CLIMATE_YEAR - CLIMATE_CWEEDS_start);

    //println(i);

    CLIMATE_CWEEDS_values[i][j][LAYER_pressure.id][k] = float(lineSTR.substring(87, 92)); // 10 times in Pa
    CLIMATE_CWEEDS_values[i][j][LAYER_drybulb.id][k] = float(lineSTR.substring(93, 97)); // 10 times in °C
    //CLIMATE_CWEEDS_values[i][j][LAYER_relhum.id][k] = 50; // Relative Humidity is not presented in DCLIMATE files!
    CLIMATE_CWEEDS_values[i][j][LAYER_glohorrad.id][k] = float(lineSTR.substring(22, 26)); // Wh/m²
    CLIMATE_CWEEDS_values[i][j][LAYER_dirnorrad.id][k] = float(lineSTR.substring(28, 32)); // Wh/m²
    CLIMATE_CWEEDS_values[i][j][LAYER_difhorrad.id][k] = float(lineSTR.substring(34, 38)); // Wh/m²
    CLIMATE_CWEEDS_values[i][j][LAYER_windspd.id][k] = float(lineSTR.substring(107, 111)); // 10 times in m/s
    CLIMATE_CWEEDS_values[i][j][LAYER_winddir.id][k] = float(lineSTR.substring(103, 106)); // °
    CLIMATE_CWEEDS_values[i][j][LAYER_cloudcover.id][k] = float(lineSTR.substring(115, 117)); // 0.1 times in %
    CLIMATE_CWEEDS_values[i][j][LAYER_ceilingsky.id][k] = float(lineSTR.substring(63, 67)); // 0.1 times in m

    if (CLIMATE_CWEEDS_values[i][j][LAYER_pressure.id][k] == 99999) CLIMATE_CWEEDS_values[i][j][LAYER_pressure.id][k] = FLOAT_undefined;
    else CLIMATE_CWEEDS_values[i][j][LAYER_pressure.id][k] = 0.1 * CLIMATE_CWEEDS_values[i][j][LAYER_pressure.id][k];

    if (CLIMATE_CWEEDS_values[i][j][LAYER_drybulb.id][k] == 9999) CLIMATE_CWEEDS_values[i][j][LAYER_drybulb.id][k] = FLOAT_undefined;
    else CLIMATE_CWEEDS_values[i][j][LAYER_drybulb.id][k] = 0.1 * CLIMATE_CWEEDS_values[i][j][LAYER_drybulb.id][k];

    if (CLIMATE_CWEEDS_values[i][j][LAYER_glohorrad.id][k] == 9999) CLIMATE_CWEEDS_values[i][j][LAYER_glohorrad.id][k] = FLOAT_undefined;
    else CLIMATE_CWEEDS_values[i][j][LAYER_glohorrad.id][k] = CLIMATE_CWEEDS_values[i][j][LAYER_glohorrad.id][k] / 3.6; // Wh/m²

    if (CLIMATE_CWEEDS_values[i][j][LAYER_dirnorrad.id][k] == 9999) CLIMATE_CWEEDS_values[i][j][LAYER_dirnorrad.id][k] = FLOAT_undefined;
    else CLIMATE_CWEEDS_values[i][j][LAYER_dirnorrad.id][k] = CLIMATE_CWEEDS_values[i][j][LAYER_dirnorrad.id][k] / 3.6; // Wh/m²

    if (CLIMATE_CWEEDS_values[i][j][LAYER_difhorrad.id][k] == 9999) CLIMATE_CWEEDS_values[i][j][LAYER_difhorrad.id][k] = FLOAT_undefined;
    else CLIMATE_CWEEDS_values[i][j][LAYER_difhorrad.id][k] = CLIMATE_CWEEDS_values[i][j][LAYER_difhorrad.id][k] / 3.6; // Wh/m²

    if (CLIMATE_CWEEDS_values[i][j][LAYER_windspd.id][k] == 9999) CLIMATE_CWEEDS_values[i][j][LAYER_windspd.id][k] = FLOAT_undefined;
    else CLIMATE_CWEEDS_values[i][j][LAYER_windspd.id][k] = 0.1 * 3.6 * CLIMATE_CWEEDS_values[i][j][LAYER_windspd.id][k];

    if (CLIMATE_CWEEDS_values[i][j][LAYER_winddir.id][k] == 999) CLIMATE_CWEEDS_values[i][j][LAYER_winddir.id][k] = FLOAT_undefined;

    if (CLIMATE_CWEEDS_values[i][j][LAYER_cloudcover.id][k] == 99) CLIMATE_CWEEDS_values[i][j][LAYER_cloudcover.id][k] = FLOAT_undefined;

    if (CLIMATE_CWEEDS_values[i][j][LAYER_ceilingsky.id][k] == 7777) CLIMATE_CWEEDS_values[i][j][LAYER_ceilingsky.id][k] = 1000;
    if (CLIMATE_CWEEDS_values[i][j][LAYER_ceilingsky.id][k] >= 1000) CLIMATE_CWEEDS_values[i][j][LAYER_ceilingsky.id][k] = 1000; // <<<<<<<<<

    if (CLIMATE_CWEEDS_values[i][j][LAYER_ceilingsky.id][k] == 9999) CLIMATE_CWEEDS_values[i][j][LAYER_ceilingsky.id][k] = FLOAT_undefined;
    else CLIMATE_CWEEDS_values[i][j][LAYER_ceilingsky.id][k] = 10 * CLIMATE_CWEEDS_values[i][j][LAYER_ceilingsky.id][k];
  }

  SOLARCHVISION_setDataFlags(dataID_CLIMATE_CWEEDS);
  SOLARCHVISION_postProcess_solarEffects(dataID_CLIMATE_CWEEDS);
  SOLARCHVISION_postProcess_developDATA(dataID_CLIMATE_CWEEDS);

  WORLD.displayAll_CWEEDS = 1;
  WORLD.displayNear_CWEEDS = true;

}







void download_CLIMATE_CLMREC () {

  if (nearest_Station_CLMREC_id != -1) {

    for (int k = 0; k < (1 + CLIMATE_CLMREC_end - CLIMATE_CLMREC_start); k++) {
      for (int m = 0; m < 12; m++) {

        int THE_YEAR = k + CLIMATE_CLMREC_start;
        int THE_MONTH = m + 1;

        String FN = nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + "_" + CLMREC_Coordinates[nearest_Station_CLMREC_id].getCity() + ".csv";

        String the_target = Folder_CLIMATE_CLMREC + "/" + FN;

        File dir = new File(the_target);
        if (!dir.isFile()) {

          String the_link = "https://climate.weather.gc.ca/climate_data/bulk_data_e.html?format=csv&stationID=" + CLMREC_Coordinates[nearest_Station_CLMREC_id].getCode() + "&Year=" + nf(THE_YEAR, 4) + "&Month=" + nf(THE_MONTH, 2) + "&timeframe=1";

          println("Try downloading: " + the_link);

          try {
            saveBytes(the_target, loadBytes(the_link));
          }
          catch (Exception e) {
            println("LINK NOT AVAILABLE:", the_link);
          }
        }
      }
    }

    Files_CLIMATE_CLMREC = OPESYS.getFiles(Folder_CLIMATE_CLMREC);

    CLIMATE_CLMREC_load = true;
    update_CLIMATE_CLMREC();
  }
}


void update_CLIMATE_CLMREC () {

  CLIMATE_CLMREC_values = new float [24][365][numberOfLayers][(1 + CLIMATE_CLMREC_end - CLIMATE_CLMREC_start)];
  CLIMATE_CLMREC_flags = new boolean [24][365][numberOfLayers][(1 + CLIMATE_CLMREC_end - CLIMATE_CLMREC_start)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < numberOfLayers; l++) {
        for (int k = 0; k < (1 + CLIMATE_CLMREC_end - CLIMATE_CLMREC_start); k++) {
          CLIMATE_CLMREC_values[i][j][l][k] = FLOAT_undefined;
          CLIMATE_CLMREC_flags[i][j][l][k] = false;
        }
      }
    }
  }

  if (CLIMATE_CLMREC_load) {

    nearest_Station_CLMREC_id = -1;
    nearest_Station_CLMREC_dist = FLOAT_undefined;

    for (int f = 0; f < CLMREC_Coordinates.length; f++) {

      //if (int(CLMREC_Coordinates[f].getEndyear()) == 2016)
      { // only use stations with this condition

        float _lat = CLMREC_Coordinates[f].getLatitude();
        float _lon = CLMREC_Coordinates[f].getLongitude();
        if (_lon > 180) _lon -= 360; // << important!

        float d = funcs.lon_lat_dist(_lon, _lat, STATION.getLongitude(), STATION.getLatitude());

        if (nearest_Station_CLMREC_dist > d) {

          nearest_Station_CLMREC_dist = d;
          nearest_Station_CLMREC_id = f;
        }
      }
    }


    for (int k = 0; k < (1 + CLIMATE_CLMREC_end - CLIMATE_CLMREC_start); k++) {
      for (int m = 0; m < 12; m++) {

        int THE_YEAR = k + CLIMATE_CLMREC_start;
        int THE_MONTH = m + 1;

        String FN = nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + "_" + CLMREC_Coordinates[nearest_Station_CLMREC_id].getCity() + ".csv";

        String the_source = Folder_CLIMATE_CLMREC + "/" + FN;

        File dir = new File(the_source);
        if (dir.isFile()) load_CLIMATE_CLMREC(the_source);
        else println("FILE NOT FOUND:", the_source);

      }
    }

    SOLARCHVISION_setDataFlags(dataID_CLIMATE_CLMREC);
    SOLARCHVISION_postProcess_fillGaps(dataID_CLIMATE_CLMREC);
    SOLARCHVISION_postProcess_solarsUsingCloud(dataID_CLIMATE_CLMREC);
    SOLARCHVISION_postProcess_solarEffects(dataID_CLIMATE_CLMREC);

    WORLD.displayAll_CLMREC = 1;
    WORLD.displayNear_CLMREC = true;

  }

  WORLD.revise();
  STUDY.revise();
  ROLLOUT.revise();
  UI_caseBar.revise();
  SOLARCHVISION_view_changed();

  SampleYear_Start = CLIMATE_CLMREC_start;
  SampleYear_End = CLIMATE_CLMREC_end;
}


void load_CLIMATE_CLMREC (String FileName) {

  String[] FileALL = loadStrings(FileName);

  String lineSTR;
  String[] input;

  println("lines = ", FileALL.length);

  for (int f = 18; f < FileALL.length; f++) {

    lineSTR = FileALL[f];
    //println(lineSTR);

    lineSTR = lineSTR.replace("\"", "");
    String[] parts = split(lineSTR, ",");

    int CLIMATE_YEAR = int(parts[1]);
    int CLIMATE_MONTH = int(parts[2]);
    int CLIMATE_DAY = int(parts[3]);
    int CLIMATE_HOUR = int(parts[4].substring(0, 2));

    //println(CLIMATE_YEAR, CLIMATE_MONTH, CLIMATE_DAY, CLIMATE_HOUR);

    int i = int(CLIMATE_HOUR);
    int j = TIME.convert2Date(CLIMATE_MONTH, CLIMATE_DAY);
    int k = (CLIMATE_YEAR - CLIMATE_CLMREC_start);

    //println(i);

    if (parts.length > 24) {

      String str = "";

      str = parts[24];

      //println(str);

      if (str.equals("NA")) CLIMATE_CLMREC_values[i][j][LAYER_cloudcover.id][k] = FLOAT_undefined;
      else if (str.equals("Clear")) CLIMATE_CLMREC_values[i][j][LAYER_cloudcover.id][k] = 0;
      else if (str.equals("Mainly Clear")) CLIMATE_CLMREC_values[i][j][LAYER_cloudcover.id][k] = 2.5;
      else if (str.equals("Mostly Cloudy")) CLIMATE_CLMREC_values[i][j][LAYER_cloudcover.id][k] = 5;
      else if (str.equals("Cloudy")) CLIMATE_CLMREC_values[i][j][LAYER_cloudcover.id][k] = 7.5;
      else CLIMATE_CLMREC_values[i][j][LAYER_cloudcover.id][k] = 10;

      //println(CLIMATE_CLMREC_values[i][j][LAYER_cloudcover.id][k]);

      str = parts[6];
      if (!str.equals("")) CLIMATE_CLMREC_values[i][j][LAYER_drybulb.id][k] = float(str); // °C

      str = parts[10];
      if (!str.equals("")) CLIMATE_CLMREC_values[i][j][LAYER_relhum.id][k] = float(str); // %

      str = parts[12];
      if (!str.equals("")) CLIMATE_CLMREC_values[i][j][LAYER_winddir.id][k] = float(str) * 10; // °

      str = parts[14];
      if (!str.equals("")) CLIMATE_CLMREC_values[i][j][LAYER_windspd.id][k] = float(str); // km/h

      str = parts[18];
      if (!str.equals("")) CLIMATE_CLMREC_values[i][j][LAYER_pressure.id][k] = float(str) * 10; // hPa


    }
  }

}









void update_CLIMATE_TMYEPW () {

  CLIMATE_TMYEPW_values = new float [24][365][numberOfLayers][(1 + CLIMATE_TMYEPW_end - CLIMATE_TMYEPW_start)];
  CLIMATE_TMYEPW_flags = new boolean [24][365][numberOfLayers][(1 + CLIMATE_TMYEPW_end - CLIMATE_TMYEPW_start)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < numberOfLayers; l++) {
        for (int k = 0; k < (1 + CLIMATE_TMYEPW_end - CLIMATE_TMYEPW_start); k++) {
          CLIMATE_TMYEPW_values[i][j][l][k] = FLOAT_undefined;
          CLIMATE_TMYEPW_flags[i][j][l][k] = false;
        }
      }
    }
  }

  if (CLIMATE_TMYEPW_load) {

    String FN = STATION.getFilename_TMYEPW() + ".epw";

    String the_source = Folder_CLIMATE_TMYEPW + "/" + FN;

    File dir = new File(the_source);
    if (dir.isFile()) load_CLIMATE_TMYEPW(the_source);
    else println("FILE NOT FOUND:", the_source);

    WORLD.displayAll_TMYEPW = 1;
    WORLD.displayNear_TMYEPW = true;

  }

  WORLD.revise();
  STUDY.revise();
  ROLLOUT.revise();
  UI_caseBar.revise();
  SOLARCHVISION_view_changed();

}




void load_CLIMATE_TMYEPW (String FileName) {
  String[] FileALL = loadStrings(FileName);

  String lineSTR;
  String[] input;


  //println("lines = ", FileALL.length);

  for (int f = 8; f < FileALL.length; f++) {

    lineSTR = FileALL[f];

    String[] parts = split(lineSTR, ",");

    int CLIMATE_YEAR = int(parts[0]);
    int CLIMATE_MONTH = int(parts[1]);
    int CLIMATE_DAY = int(parts[2]);
    int CLIMATE_HOUR = int(parts[3]);

    //println(CLIMATE_YEAR, CLIMATE_MONTH, CLIMATE_DAY, CLIMATE_HOUR);

    int i = int(CLIMATE_HOUR) - 1;
    int j = TIME.convert2Date(CLIMATE_MONTH, CLIMATE_DAY);
    int k = 0; // on TMYEPW:TMY files we have only one year

    //println(i);

    CLIMATE_TMYEPW_values[i][j][LAYER_pressure.id][k] = float(parts[9]) * 0.01; // 10 times in Pa
    CLIMATE_TMYEPW_values[i][j][LAYER_drybulb.id][k] = float(parts[6]); // in °C
    CLIMATE_TMYEPW_values[i][j][LAYER_relhum.id][k] = float(parts[8]); // 0 - 110%
    CLIMATE_TMYEPW_values[i][j][LAYER_glohorrad.id][k] = float(parts[13]); // Wh/m²
    CLIMATE_TMYEPW_values[i][j][LAYER_dirnorrad.id][k] = float(parts[14]); // Wh/m²
    CLIMATE_TMYEPW_values[i][j][LAYER_difhorrad.id][k] = float(parts[15]); // Wh/m²
    CLIMATE_TMYEPW_values[i][j][LAYER_windspd.id][k] = float(parts[21]); // in m/s
    CLIMATE_TMYEPW_values[i][j][LAYER_winddir.id][k] = float(parts[20]); // °
    CLIMATE_TMYEPW_values[i][j][LAYER_cloudcover.id][k] = float(parts[23]); // 0.1 times in % ... there is also total_sky_cover on[22]
    CLIMATE_TMYEPW_values[i][j][LAYER_ceilingsky.id][k] = float(parts[25]); // in m


    if (CLIMATE_TMYEPW_values[i][j][LAYER_pressure.id][k] == 999999) CLIMATE_TMYEPW_values[i][j][LAYER_pressure.id][k] = FLOAT_undefined;

    if (CLIMATE_TMYEPW_values[i][j][LAYER_drybulb.id][k] == 99.9) CLIMATE_TMYEPW_values[i][j][LAYER_drybulb.id][k] = FLOAT_undefined;

    if (CLIMATE_TMYEPW_values[i][j][LAYER_relhum.id][k] == 999) CLIMATE_TMYEPW_values[i][j][LAYER_relhum.id][k] = FLOAT_undefined;

    if (CLIMATE_TMYEPW_values[i][j][LAYER_glohorrad.id][k] == 9999) CLIMATE_TMYEPW_values[i][j][LAYER_glohorrad.id][k] = FLOAT_undefined;

    if (CLIMATE_TMYEPW_values[i][j][LAYER_dirnorrad.id][k] >= 9999) CLIMATE_TMYEPW_values[i][j][LAYER_dirnorrad.id][k] = FLOAT_undefined;
    if (CLIMATE_TMYEPW_values[i][j][LAYER_dirnorrad.id][k] < 0) CLIMATE_TMYEPW_values[i][j][LAYER_dirnorrad.id][k] = FLOAT_undefined;

    if (CLIMATE_TMYEPW_values[i][j][LAYER_difhorrad.id][k] >= 9999) CLIMATE_TMYEPW_values[i][j][LAYER_difhorrad.id][k] = FLOAT_undefined;
    if (CLIMATE_TMYEPW_values[i][j][LAYER_difhorrad.id][k] < 0) CLIMATE_TMYEPW_values[i][j][LAYER_difhorrad.id][k] = FLOAT_undefined;

    if (CLIMATE_TMYEPW_values[i][j][LAYER_windspd.id][k] == 999) CLIMATE_TMYEPW_values[i][j][LAYER_windspd.id][k] = FLOAT_undefined;
    else CLIMATE_TMYEPW_values[i][j][LAYER_windspd.id][k] = 3.6 * CLIMATE_TMYEPW_values[i][j][LAYER_windspd.id][k];

    if (CLIMATE_TMYEPW_values[i][j][LAYER_winddir.id][k] == 999) CLIMATE_TMYEPW_values[i][j][LAYER_winddir.id][k] = FLOAT_undefined;

    if (CLIMATE_TMYEPW_values[i][j][LAYER_cloudcover.id][k] == 99) CLIMATE_TMYEPW_values[i][j][LAYER_cloudcover.id][k] = FLOAT_undefined;

    if (CLIMATE_TMYEPW_values[i][j][LAYER_ceilingsky.id][k] == 77777) CLIMATE_TMYEPW_values[i][j][LAYER_ceilingsky.id][k] = 1000;
    if (CLIMATE_TMYEPW_values[i][j][LAYER_ceilingsky.id][k] == 88888) CLIMATE_TMYEPW_values[i][j][LAYER_ceilingsky.id][k] = 1000;
    if (CLIMATE_TMYEPW_values[i][j][LAYER_ceilingsky.id][k] >= 1000) CLIMATE_TMYEPW_values[i][j][LAYER_ceilingsky.id][k] = 1000;

    if (CLIMATE_TMYEPW_values[i][j][LAYER_ceilingsky.id][k] == 99999) CLIMATE_TMYEPW_values[i][j][LAYER_ceilingsky.id][k] = FLOAT_undefined;
  }

  SOLARCHVISION_setDataFlags(dataID_CLIMATE_TMYEPW);
  SOLARCHVISION_postProcess_solarEffects(dataID_CLIMATE_TMYEPW);
  SOLARCHVISION_postProcess_developDATA(dataID_CLIMATE_TMYEPW);

  WORLD.revise();
  STUDY.revise();
  ROLLOUT.revise();
  UI_caseBar.revise();
  SOLARCHVISION_view_changed();

}



void download_ENSEMBLE_OBSERVED () {

  // this line tries to update the most recent files! <<
  int THE_YEAR = year();
  int THE_MONTH = month();
  int THE_DAY = day();
  int THE_HOUR = hour();


  float THE_DATE = TIME.date;

  int now_i = int(THE_HOUR);
  int now_j = TIME.convert2Date(THE_MONTH, THE_DAY);

  now_i += int(-STATION.getTimelong() / 15);
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

  for (int j_for = 0; j_for < ENSEMBLE_OBSERVED_maxDays * 24; j_for++) {

    THE_MONTH = TIME.getMonth_fromDate(THE_DATE);
    THE_DAY = TIME.getDay_fromDate(THE_DATE);

    for (int q = 0; q < ENSEMBLE_OBSERVED_numNearest; q++) {

      int f = nearest_Station_ENSEMBLE_OBSERVED_id[q];

      if (f != -1) {

        String FN = nf(THE_YEAR, 4) + "-" + nf(THE_MONTH, 2) + "-" + nf(THE_DAY, 2) + "-" + nf(THE_HOUR, 2) + "00-" + SWOB_Coordinates[f].getCode() + "-swob.xml";

        String the_target = Folder_ENSEMBLE_OBSERVED + "/" + FN;

        File dir = new File(the_target);
        if (!dir.isFile()) {

          String the_link = "https://dd.weather.gc.ca/observations/swob-ml/" + nf(THE_YEAR, 4) + nf(THE_MONTH, 2) + nf(THE_DAY, 2) + "/" + split(SWOB_Coordinates[f].getCode(),'-')[0] + "/" + FN;

          println("Try downloading: " + the_link);

          try {
            saveBytes(the_target, loadBytes(the_link));
          }
          catch (Exception e) {
            println("LINK NOT AVAILABLE:", the_link);
          }
        }
      }
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


  Files_ENSEMBLE_OBSERVED = OPESYS.getFiles(Folder_ENSEMBLE_OBSERVED);

  ENSEMBLE_OBSERVED_load = true;
  SOLARCHVISION_update_ENSEMBLE_OBSERVED();
}

void SOLARCHVISION_update_ENSEMBLE_OBSERVED () {

  ENSEMBLE_OBSERVED_values = new float [24][365][numberOfLayers][(1 + ENSEMBLE_OBSERVED_end - ENSEMBLE_OBSERVED_start)];
  ENSEMBLE_OBSERVED_flags = new boolean [24][365][numberOfLayers][(1 + ENSEMBLE_OBSERVED_end - ENSEMBLE_OBSERVED_start)]; // true: direct input , false: no-input, interpolated or post-processed

  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 365; j++) {
      for (int l = 0; l < numberOfLayers; l++) {
        for (int k = 0; k < (1 + ENSEMBLE_OBSERVED_end - ENSEMBLE_OBSERVED_start); k++) {
          ENSEMBLE_OBSERVED_values[i][j][l][k] = FLOAT_undefined;
          ENSEMBLE_OBSERVED_flags[i][j][l][k] = false;
        }
      }
    }
  }

  if (ENSEMBLE_OBSERVED_load) {

    // this line tries to update the most recent files! <<
    int THE_YEAR = year();
    int THE_MONTH = month();
    int THE_DAY = day();
    int THE_HOUR = hour();


    float THE_DATE = TIME.date;

    int now_i = int(THE_HOUR);
    int now_j = TIME.convert2Date(THE_MONTH, THE_DAY);

    now_i += int(-STATION.getTimelong() / 15);
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

    for (int j_for = 0; j_for < ENSEMBLE_OBSERVED_maxDays * 24; j_for++) {

      THE_MONTH = TIME.getMonth_fromDate(THE_DATE);
      THE_DAY = TIME.getDay_fromDate(THE_DATE);

      for (int q = 0; q < ENSEMBLE_OBSERVED_numNearest; q++) {

        int f = nearest_Station_ENSEMBLE_OBSERVED_id[q];

        if (f != -1) {

          String FN = nf(THE_YEAR, 4) + "-" + nf(THE_MONTH, 2) + "-" + nf(THE_DAY, 2) + "-" + nf(THE_HOUR, 2) + "00-" + SWOB_Coordinates[f].getCode() + "-swob.xml";

          String the_source = Folder_ENSEMBLE_OBSERVED + "/" + FN;

          File dir = new File(the_source);
          if (dir.isFile()) load_ENSEMBLE_OBSERVED(the_source, q);
          else println("FILE NOT FOUND:", the_source);

        }
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

    SOLARCHVISION_setDataFlags(dataID_ENSEMBLE_OBSERVED);
    SOLARCHVISION_postProcess_solarsUsingCloud(dataID_ENSEMBLE_OBSERVED); // <<<<<<<<<<<<
    SOLARCHVISION_postProcess_solarEffects(dataID_ENSEMBLE_OBSERVED);
    SOLARCHVISION_postProcess_developDATA(dataID_ENSEMBLE_OBSERVED);

    WORLD.displayAll_SWOB = 1;
    WORLD.displayNear_SWOB = true;
  }

  WORLD.revise();
  STUDY.revise();
  ROLLOUT.revise();
  UI_caseBar.revise();
  SOLARCHVISION_view_changed();

  SampleStation_Start = ENSEMBLE_OBSERVED_start;
  SampleStation_End = ENSEMBLE_OBSERVED_end;
}


void load_ENSEMBLE_OBSERVED (String FileName, int Load_Layer) {
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

  //println(THE_YEAR, THE_MONTH, THE_DAY, THE_HOUR);

  int now_i = int(THE_HOUR);
  int now_j = TIME.convert2Date(THE_MONTH, THE_DAY);

  //println(now_i, now_j);

  now_i -= int(-STATION.getTimelong() / 15);

  if (now_i < 0) {
    now_i += 24;
    now_j -= 1;
    if (now_j < 0) {
      now_j += 365;
    }
  }

  //println(now_i, now_j);
  //println("-------------");

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
      ENSEMBLE_OBSERVED_values[now_i][now_j][LAYER_pressure.id][Load_Layer] = Float.valueOf(_a2);
    }

    if (_a1.equals("air_temp")) {
      ENSEMBLE_OBSERVED_values[now_i][now_j][LAYER_drybulb.id][Load_Layer] = Float.valueOf(_a2);
    }

    if (_a1.equals("rel_hum")) {
      ENSEMBLE_OBSERVED_values[now_i][now_j][LAYER_relhum.id][Load_Layer] = Float.valueOf(_a2);
    }

    if (_a1.equals("tot_cld_amt")) {
      ENSEMBLE_OBSERVED_values[now_i][now_j][LAYER_cloudcover.id][Load_Layer] = 0.1 * Float.valueOf(_a2);
    }

    if (_a1.equals("avg_wnd_dir_10m_mt50-60")) {
      ENSEMBLE_OBSERVED_values[now_i][now_j][LAYER_winddir.id][Load_Layer] = Float.valueOf(_a2);
    }

    if (_a1.equals("avg_wnd_spd_10m_mt50-60")) {
      ENSEMBLE_OBSERVED_values[now_i][now_j][LAYER_windspd.id][Load_Layer] = Float.valueOf(_a2);
    }

    if (_a1.equals("pcpn_amt_pst6hrs")) {
      ENSEMBLE_OBSERVED_values[now_i][now_j][LAYER_precipitation.id][Load_Layer] = Float.valueOf(_a2); // past 6 hours!
    }

    if (_a1.equals("avg_globl_solr_radn_pst1hr")) {
      if (_a2.equals(STRING_undefined)) {
      } else {
        //if (_a3.equals("W/m²")) {
        ENSEMBLE_OBSERVED_values[now_i][now_j][LAYER_glohorrad.id][Load_Layer] = 1000 * Float.valueOf(_a2) / 3.6; // we should check the units!
        //}
      }
    }

    if (_a1.equals("tot_globl_solr_radn_pst1hr")) {
      if (_a2.equals(STRING_undefined)) {
      } else {
        //if (_a3.equals("kJ/m²")) {
        ENSEMBLE_OBSERVED_values[now_i][now_j][LAYER_glohorrad.id][Load_Layer] = Float.valueOf(_a2) / 3.6; // we should check the units!
        //}
      }
    }

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


void SOLARCHVISION_castShadows_CurrentSection () {

  cursor(WAIT);

  SceneName = "Section_" + Section_Stamp();


  int RES1 = allSolarImpacts.RES1;
  int RES2 = allSolarImpacts.RES2;

  Shades_scaleX = RES1 / allSolarImpacts.U;
  Shades_scaleY = RES2 / allSolarImpacts.V;

  Shades_offsetX = allSolarImpacts.X;
  Shades_offsetY = allSolarImpacts.Y;


  SHADOW_graphics = createGraphics(RES1, RES2, P2D);

  TREES_graphics = createGraphics(RES1, RES2, P2D);

  int keep_allSolarImpacts_sectionType = allSolarImpacts.sectionType;
  float keep_allSolarImpacts_rotation = allSolarImpacts.R;

  if (allSolarImpacts.sectionType == 3) {
    allSolarImpacts.sectionType = 2;
    allSolarImpacts.R = 90 - allSolarImpacts.R;
  }

  {
    int RAD_TYPE = 0;

    for (int DATE_ANGLE = 0; DATE_ANGLE < 360; DATE_ANGLE += 15) {

      //for (int i = 0; i < 24; i++) {
      for (int i = 4; i <= 20; i++) { // to make it faster. Also the images are not needed out of this period.

        float HOUR_ANGLE = i;
        float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);
        SunR_Rotated = SunR;
        int SunR_Rotated_check = 3;

        if (allSolarImpacts.sectionType == 2) {
          float a = SunR_Rotated[1];
          float b = -SunR_Rotated[2];
          float c = SunR_Rotated[3];

          SunR_Rotated[1] = a * funcs.cos_ang(-allSolarImpacts.R) - b * funcs.sin_ang(-allSolarImpacts.R);
          SunR_Rotated[2] = c;
          SunR_Rotated[3] = a * funcs.sin_ang(-allSolarImpacts.R) + b * funcs.cos_ang(-allSolarImpacts.R);

          SunR_Rotated_check = 2;
        } else if (allSolarImpacts.sectionType == 3) {
        }

        for (int SHD = 0; SHD <= 1; SHD++) {

          String[] STR_SHD = {
            "F", "T"
          };
          String File_Name = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName;

          File_Name += nf(DATE_ANGLE, 3) + "_" + STR_SHD[SHD] + "_" + nf(int(funcs.roundTo(HOUR_ANGLE * 100, 1.0)), 4);

          File_Name += "_Camera00";

          TREES_graphics.beginDraw();

          TREES_graphics.blendMode(REPLACE);

          TREES_graphics.fill(255);
          TREES_graphics.stroke(255);
          TREES_graphics.strokeWeight(0);
          TREES_graphics.rectMode(CORNER);
          TREES_graphics.rect(0, 0, RES1, RES2);

          if ((SHD == 1) && (SunR[3] > 0) && (SunR_Rotated[SunR_Rotated_check] > 0)) { // i.e. one-sided plane

            TREES_graphics.pushMatrix();
            TREES_graphics.translate(allSolarImpacts.RES1 / 2, allSolarImpacts.RES2 / 2);

            TREES_graphics.stroke(0);
            TREES_graphics.fill(0);

            TREES_graphics.blendMode(BLEND);

            allModel2Ds.castShadows(SunR);

            TREES_graphics.popMatrix();
          }


          TREES_graphics.endDraw();

          TREES_graphics.save(File_Name + "_2D.jpg");



          SHADOW_graphics.beginDraw();

          SHADOW_graphics.blendMode(REPLACE);

          float _val = 0;
          if (SunR_Rotated[3] > 0) _val = SunR_Rotated[3];
          SHADOW_graphics.fill(255 * _val);
          SHADOW_graphics.stroke(255 * _val);
          SHADOW_graphics.strokeWeight(0);
          SHADOW_graphics.rectMode(CORNER);
          SHADOW_graphics.rect(0, 0, RES1, RES2);

          if ((SHD == 1) && (SunR[3] > 0) && (SunR_Rotated[SunR_Rotated_check] > 0)) { // i.e. one-sided plane

            SHADOW_graphics.pushMatrix();
            SHADOW_graphics.translate(allSolarImpacts.RES1 / 2, allSolarImpacts.RES2 / 2);

            SHADOW_graphics.stroke(0);
            SHADOW_graphics.fill(0);

            allFaces.castShadows();

            Land3D.castShadows();

            allModel1Ds.draw(TypeWindow.SHADOW);

            SHADOW_graphics.popMatrix();
          }


          SHADOW_graphics.save(File_Name + "3D_.jpg"); //just to test

          if (allModel2Ds.displayAll) {

            PImage img = loadImage(File_Name + "_2D.jpg");

            img.filter(THRESHOLD, 0.75); // Converts the image to black and white pixels depending if they are above or below the threshold defined by the level parameter.

            SHADOW_graphics.blendMode(DARKEST);

            SHADOW_graphics.tint(255, 255);

            SHADOW_graphics.image(img, 0, 0, RES1, RES2);

            SHADOW_graphics.noTint();
          }

          SHADOW_graphics.endDraw();


          SHADOW_graphics.save(File_Name + ".png");
        }
      }
    }
  }


  {
    int RAD_TYPE = 1;

    for (int SHD = 0; SHD <= 1; SHD++) {

      String[] STR_SHD = {
        "F", "T"
      };
      String File_Name = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName;

      File_Name += "DIF_" + STR_SHD[SHD];

      for (int i = 0; i < DiffuseVectors.length; i++) {

        float[] SunR= {
          0, DiffuseVectors[i][0], DiffuseVectors[i][1], DiffuseVectors[i][2]
        };

        SunR_Rotated = SunR;
        int SunR_Rotated_check = 3;

        if (allSolarImpacts.sectionType == 2) {
          float a = SunR_Rotated[1];
          float b = -SunR_Rotated[2];
          float c = SunR_Rotated[3];

          SunR_Rotated[1] = a * funcs.cos_ang(-allSolarImpacts.R) - b * funcs.sin_ang(-allSolarImpacts.R);
          SunR_Rotated[2] = c;
          SunR_Rotated[3] = a * funcs.sin_ang(-allSolarImpacts.R) + b * funcs.cos_ang(-allSolarImpacts.R);

          SunR_Rotated_check = 2;
        } else if (allSolarImpacts.sectionType == 3) {
        }



        TREES_graphics.beginDraw();

        TREES_graphics.blendMode(REPLACE);

        TREES_graphics.fill(255);
        TREES_graphics.stroke(255);
        TREES_graphics.strokeWeight(0);
        TREES_graphics.rectMode(CORNER);
        TREES_graphics.rect(0, 0, RES1, RES2);

        if ((SHD == 1) && (SunR[3] > 0) && (SunR_Rotated[SunR_Rotated_check] > 0)) { // i.e. one-sided plane

          TREES_graphics.pushMatrix();
          TREES_graphics.translate(allSolarImpacts.RES1 / 2, allSolarImpacts.RES2 / 2);

          TREES_graphics.stroke(0);
          TREES_graphics.fill(0);

          TREES_graphics.blendMode(BLEND);

          allModel2Ds.castShadows(SunR);

          TREES_graphics.popMatrix();
        }


        TREES_graphics.endDraw();

        TREES_graphics.save(File_Name + nf(i, 3) + "_2D.jpg");



        SHADOW_graphics.beginDraw();

        SHADOW_graphics.blendMode(REPLACE);

        float _val = 0;
        if (SunR_Rotated[3] > 0) _val = SunR_Rotated[3];
        SHADOW_graphics.fill(255 * _val);
        SHADOW_graphics.stroke(255 * _val);
        SHADOW_graphics.strokeWeight(0);
        SHADOW_graphics.rectMode(CORNER);
        SHADOW_graphics.rect(0, 0, RES1, RES2);

        if ((SHD == 1) && (SunR[3] > 0) && (SunR_Rotated[SunR_Rotated_check] > 0)) { // i.e. one-sided plane

          SHADOW_graphics.pushMatrix();
          SHADOW_graphics.translate(allSolarImpacts.RES1 / 2, allSolarImpacts.RES2 / 2);

          SHADOW_graphics.stroke(0);
          SHADOW_graphics.fill(0);

          allFaces.castShadows();

          Land3D.castShadows();

          allModel1Ds.draw(TypeWindow.SHADOW);

          SHADOW_graphics.popMatrix();
        }

        SHADOW_graphics.save(File_Name + "3D_.jpg"); //just to test

        if (allModel2Ds.displayAll) {

          PImage img = loadImage(File_Name + nf(i, 3) + "_2D.jpg");

          img.filter(THRESHOLD, 0.75); // Converts the image to black and white pixels depending if they are above or below the threshold defined by the level parameter.

          SHADOW_graphics.blendMode(DARKEST);

          SHADOW_graphics.tint(255, 255);

          SHADOW_graphics.image(img, 0, 0, RES1, RES2);

          SHADOW_graphics.noTint();
        }

        SHADOW_graphics.endDraw();

        SHADOW_graphics.save(File_Name + nf(i, 3) + ".jpg");
      }



      PGraphics DIFFUSE_graphics = createGraphics(RES1, RES2, P2D);

      DIFFUSE_graphics.beginDraw();

      DIFFUSE_graphics.blendMode(REPLACE);

      DIFFUSE_graphics.fill(0);
      DIFFUSE_graphics.stroke(0);
      DIFFUSE_graphics.strokeWeight(0);
      DIFFUSE_graphics.rectMode(CORNER);
      DIFFUSE_graphics.rect(0, 0, RES1, RES2);

      for (int i = 0; i < skyFaces.length; i++) {

        PImage img = loadImage(File_Name + nf(i, 3) + ".jpg");

        DIFFUSE_graphics.blendMode(ADD);

        DIFFUSE_graphics.tint(255, 255 / (0.5 * float(skyFaces.length)));

        DIFFUSE_graphics.image(img, 0, 0, RES1, RES2);

        DIFFUSE_graphics.noTint();
      }

      DIFFUSE_graphics.endDraw();

      File_Name += "_Camera00.png";

      DIFFUSE_graphics.save(File_Name);
      println(File_Name);
    }
  }

  allSolarImpacts.sectionType = keep_allSolarImpacts_sectionType;
  allSolarImpacts.R = keep_allSolarImpacts_rotation;

  cursor(ARROW);
}










String save_folder = "";

void SOLARCHVISION_save_project (String myFile) {

  myFile = myFile.replace(char(92), '/');

  save_folder = myFile.substring(0, myFile.lastIndexOf("/"));

  XML xml = parseXML("<?xml version='1.0' encoding='UTF-8'?>" + char(13) + "<empty>" + char(13) + "</empty>");

  xml.setName("SOLARCHVISION_" + SOLARCHVISION_version + "_project");

  {
    XML parent = xml.addChild("SOLARCHVISION_variables");

    XML_setInt(parent, "current_ObjectCategory", current_ObjectCategory);

    XML_setFloat(parent, "GlobalAlbedo", GlobalAlbedo);
    XML_setFloat(parent, "Interpolation_Weight", Interpolation_Weight);

    XML_setInt(parent, "CLIMATIC_SolarForecast", CLIMATIC_SolarForecast);
    XML_setInt(parent, "CLIMATIC_WeatherForecast", CLIMATIC_WeatherForecast);
    XML_setInt(parent, "SOLARCHVISION_automated", SOLARCHVISION_automated);

    XML_setInt(parent, "CLIMATE_TMYEPW_start", CLIMATE_TMYEPW_start);
    XML_setInt(parent, "CLIMATE_TMYEPW_end", CLIMATE_TMYEPW_end);
    XML_setInt(parent, "CLIMATE_CWEEDS_start", CLIMATE_CWEEDS_start);
    XML_setInt(parent, "CLIMATE_CWEEDS_end", CLIMATE_CWEEDS_end);
    XML_setInt(parent, "CLIMATE_CLMREC_start", CLIMATE_CLMREC_start);
    XML_setInt(parent, "CLIMATE_CLMREC_end", CLIMATE_CLMREC_end);
    XML_setInt(parent, "ENSEMBLE_FORECAST_start", ENSEMBLE_FORECAST_start);
    XML_setInt(parent, "ENSEMBLE_FORECAST_end", ENSEMBLE_FORECAST_end);
    XML_setInt(parent, "ENSEMBLE_FORECAST_maxDays", ENSEMBLE_FORECAST_maxDays);
    XML_setInt(parent, "ENSEMBLE_OBSERVED_maxDays", ENSEMBLE_OBSERVED_maxDays);
    XML_setInt(parent, "ENSEMBLE_OBSERVED_numNearest", ENSEMBLE_OBSERVED_numNearest);
    XML_setInt(parent, "ENSEMBLE_OBSERVED_start", ENSEMBLE_OBSERVED_start);
    XML_setInt(parent, "ENSEMBLE_OBSERVED_end", ENSEMBLE_OBSERVED_end);
    XML_setInt(parent, "SampleYear_Start", SampleYear_Start);
    XML_setInt(parent, "SampleYear_End", SampleYear_End);
    XML_setInt(parent, "SampleMember_Start", SampleMember_Start);
    XML_setInt(parent, "SampleMember_End", SampleMember_End);
    XML_setInt(parent, "SampleStation_Start", SampleStation_Start);
    XML_setInt(parent, "SampleStation_End", SampleStation_End);
    XML_setBoolean(parent, "CLIMATE_TMYEPW_load", CLIMATE_TMYEPW_load);
    XML_setBoolean(parent, "CLIMATE_CWEEDS_load", CLIMATE_CWEEDS_load);
    XML_setBoolean(parent, "CLIMATE_CLMREC_load", CLIMATE_CLMREC_load);
    XML_setBoolean(parent, "ENSEMBLE_FORECAST_load", ENSEMBLE_FORECAST_load);
    XML_setBoolean(parent, "ENSEMBLE_OBSERVED_load", ENSEMBLE_OBSERVED_load);
    XML_setInt(parent, "Develop_Option", Develop_Option);
    XML_setInt(parent, "Develop_DayHour", Develop_DayHour);
    XML_setBoolean(parent, "DevelopData_update", DevelopData_update);
    XML_setInt(parent, "numberOfLayers", numberOfLayers);

    XML_setFloat(parent, "Develop_AngleInclination", Develop_AngleInclination);
    XML_setFloat(parent, "Develop_AngleOrientation", Develop_AngleOrientation);
    XML_setInt(parent, "DevelopLayer_id", DevelopLayer_id);
    XML_setInt(parent, "CurrentLayer_id", CurrentLayer_id);


    XML_setInt(parent, "Impact_TYPE", Impact_TYPE);

    XML_setInt(parent, "COLOR_STYLE_Current", COLOR_STYLE_Current);
    XML_setInt(parent, "COLOR_STYLE_Number", COLOR_STYLE_Number);

    XML_setInt(parent, "CurrentDataSource", CurrentDataSource);
    XML_setInt(parent, "DrawnFrame", DrawnFrame);



    XML_setFloat(parent, "Planetary_Magnification", Planetary_Magnification);


    //XML_setInt(parent, "Camera_Variation", Camera_Variation);

    XML_setInt(parent, "allMaterials.Selection", allMaterials.Selection);
    XML_setFloat(parent, "OBJECTS_scale", OBJECTS_scale);

    XML_setInt(parent, "FrameVariation", FrameVariation);
    XML_setInt(parent, "Language_Active", Language_Active);

    XML_setInt(parent, "IMPACTS_displayDay", IMPACTS_displayDay);

    XML_setFloat(parent, "BIOSPHERE_drawResolution", BIOSPHERE_drawResolution);

    XML_setString(parent, "Default_Font", Default_Font);
  }


  STATION.to_XML(xml);

  allPoints.to_XML(xml);

  allPolylines.to_XML(xml);

  allFaces.to_XML(xml);

  allCameras.to_XML(xml);

  allSolids.to_XML(xml);

  allSections.to_XML(xml);

  allModel1Ds.to_XML(xml);

  allModel2Ds.to_XML(xml);

  allGroups.to_XML(xml);

  Land3D.to_XML(xml);

  Earth3D.to_XML(xml);

  Sky3D.to_XML(xml);

  Tropo3D.to_XML(xml);

  Moon3D.to_XML(xml);

  Sun3D.to_XML(xml);

  WIN3D.to_XML(xml);

  User3D.to_XML(xml);

  Select3D.to_XML(xml);

  WORLD.to_XML(xml);

  STUDY.to_XML(xml);

  allWindRoses.to_XML(xml);

  allWindFlows.to_XML(xml);

  allSolidImpacts.to_XML(xml);

  allSolarImpacts.to_XML(xml);

  LAYER_ceilingsky.to_XML(xml);
  LAYER_cloudcover.to_XML(xml);
  LAYER_winddir.to_XML(xml);
  LAYER_windspd.to_XML(xml);
  LAYER_pressure.to_XML(xml);
  LAYER_drybulb.to_XML(xml);
  LAYER_relhum.to_XML(xml);
  LAYER_dirnorrad.to_XML(xml);
  LAYER_difhorrad.to_XML(xml);
  LAYER_glohorrad.to_XML(xml);
  LAYER_direffect.to_XML(xml);
  LAYER_difeffect.to_XML(xml);
  LAYER_precipitation.to_XML(xml);
  LAYER_developed.to_XML(xml);

  saveXML(xml, myFile);

  println("End of saving XML:", myFile);

}


void SOLARCHVISION_load_project (String myFile) {

  myFile = myFile.replace(char(92), '/');


  boolean continue_process = true;

  XML xml = parseXML("<?xml version='1.0' encoding='UTF-8'?>" + char(13) + "<empty>" + char(13) + "</empty>");

  try {
    xml = loadXML(myFile);
  }
  catch (Exception e) {
    println("Can't read:", myFile);
    continue_process = false;
  }

  if (continue_process) {

    try {
      SOLARCHVISION_parse_XML_variables(xml, false); // first try: loading without printing logs
    }
    catch (Exception e) {
      println("Problem loading variables:", myFile);

      SOLARCHVISION_parse_XML_variables(xml, true); // second try with printing logs
      System.exit(1);
    }

    // loading only weather data //
    SOLARCHVISION_update_station(2);
    SOLARCHVISION_update_station(3);
    SOLARCHVISION_update_station(4);
    SOLARCHVISION_update_station(5);
    ///////////////////////////////

    addNewSelectionToPreviousSelection = 0;

    addToLastGroup = false;

    UI_set_to_Create_Nothing();

    WORLD.autoView = true;

    WORLD.VIEW_id = WORLD.FindGoodViewport(LocationLON, LocationLAT);

    SOLARCHVISION_update_frame_layout();

    ROLLOUT.revise();
    WORLD.revise();
    STUDY.revise();
    UI_menuBar.revise();
    UI_toolBar.revise();
    UI_caseBar.revise();
    SOLARCHVISION_view_changed();


    allSolarImpacts.rebuild_Image_array = true;
    allWindRoses.rebuild_Image_array = true;

    VertexSolar_rebuild_array = true;
    GlobalSolar_rebuild_array = true;

    VertexSolar_resize_array();
    GlobalSolar_resize_array();


    SOLARCHVISION_modify_Viewport_Title();
  }

}


void SOLARCHVISION_parse_XML_variables (XML xml, boolean desired_diag) {

  diag_XML_input = desired_diag;

  XML parent = xml.getChild("SOLARCHVISION_variables");

  current_ObjectCategory = XML_getInt(parent, "current_ObjectCategory");

  GlobalAlbedo = XML_getFloat(parent, "GlobalAlbedo");
  Interpolation_Weight = XML_getFloat(parent, "Interpolation_Weight");

  CLIMATIC_SolarForecast = XML_getInt(parent, "CLIMATIC_SolarForecast");
  CLIMATIC_WeatherForecast = XML_getInt(parent, "CLIMATIC_WeatherForecast");
  SOLARCHVISION_automated = XML_getInt(parent, "SOLARCHVISION_automated");

  CLIMATE_TMYEPW_start = XML_getInt(parent, "CLIMATE_TMYEPW_start");
  CLIMATE_TMYEPW_end = XML_getInt(parent, "CLIMATE_TMYEPW_end");
  CLIMATE_CWEEDS_start = XML_getInt(parent, "CLIMATE_CWEEDS_start");
  CLIMATE_CWEEDS_end = XML_getInt(parent, "CLIMATE_CWEEDS_end");
  CLIMATE_CLMREC_start = XML_getInt(parent, "CLIMATE_CLMREC_start");
  CLIMATE_CLMREC_end = XML_getInt(parent, "CLIMATE_CLMREC_end");
  ENSEMBLE_FORECAST_start = XML_getInt(parent, "ENSEMBLE_FORECAST_start");
  ENSEMBLE_FORECAST_end = XML_getInt(parent, "ENSEMBLE_FORECAST_end");
  ENSEMBLE_FORECAST_maxDays = XML_getInt(parent, "ENSEMBLE_FORECAST_maxDays");
  ENSEMBLE_OBSERVED_maxDays = XML_getInt(parent, "ENSEMBLE_OBSERVED_maxDays");
  ENSEMBLE_OBSERVED_numNearest = XML_getInt(parent, "ENSEMBLE_OBSERVED_numNearest");
  ENSEMBLE_OBSERVED_start = XML_getInt(parent, "ENSEMBLE_OBSERVED_start");
  ENSEMBLE_OBSERVED_end = XML_getInt(parent, "ENSEMBLE_OBSERVED_end");
  SampleYear_Start = XML_getInt(parent, "SampleYear_Start");
  SampleYear_End = XML_getInt(parent, "SampleYear_End");
  SampleMember_Start = XML_getInt(parent, "SampleMember_Start");
  SampleMember_End = XML_getInt(parent, "SampleMember_End");
  SampleStation_Start = XML_getInt(parent, "SampleStation_Start");
  SampleStation_End = XML_getInt(parent, "SampleStation_End");
  CLIMATE_TMYEPW_load = XML_getBoolean(parent, "CLIMATE_TMYEPW_load");
  CLIMATE_CWEEDS_load = XML_getBoolean(parent, "CLIMATE_CWEEDS_load");
  CLIMATE_CLMREC_load = XML_getBoolean(parent, "CLIMATE_CLMREC_load");
  ENSEMBLE_FORECAST_load = XML_getBoolean(parent, "ENSEMBLE_FORECAST_load");
  ENSEMBLE_OBSERVED_load = XML_getBoolean(parent, "ENSEMBLE_OBSERVED_load");
  Develop_Option = XML_getInt(parent, "Develop_Option");
  Develop_DayHour = XML_getInt(parent, "Develop_DayHour");
  //DevelopData_update = XML_getBoolean(parent, "DevelopData_update");
  numberOfLayers = XML_getInt(parent, "numberOfLayers");
  Develop_AngleInclination = XML_getFloat(parent, "Develop_AngleInclination");
  Develop_AngleOrientation = XML_getFloat(parent, "Develop_AngleOrientation");
  DevelopLayer_id = XML_getInt(parent, "DevelopLayer_id");

  changeCurrentLayerTo(XML_getInt(parent, "CurrentLayer_id"));

  Impact_TYPE = XML_getInt(parent, "Impact_TYPE");

  COLOR_STYLE_Current = XML_getInt(parent, "COLOR_STYLE_Current");
  COLOR_STYLE_Number = XML_getInt(parent, "COLOR_STYLE_Number");

  CurrentDataSource = XML_getInt(parent, "CurrentDataSource");
  DrawnFrame = XML_getInt(parent, "DrawnFrame");

  Planetary_Magnification = XML_getFloat(parent, "Planetary_Magnification");

  Camera_Variation = XML_getInt(parent, "Camera_Variation");

  allMaterials.Selection = XML_getInt(parent, "allMaterials.Selection");
  OBJECTS_scale = XML_getFloat(parent, "OBJECTS_scale");

  FrameVariation = XML_getInt(parent, "FrameVariation");
  Language_Active = XML_getInt(parent, "Language_Active");

  IMPACTS_displayDay = XML_getInt(parent, "IMPACTS_displayDay");

  BIOSPHERE_drawResolution = XML_getFloat(parent, "BIOSPHERE_drawResolution");

  String new_Default_Font = XML_getString(parent, "Default_Font");
  if (Default_Font.equals(new_Default_Font)) {
  } else {
    Default_Font = new_Default_Font;
    SOLARCHVISION_loadDefaultFontStyle();
  }


  STATION.from_XML(xml);

  allPoints.from_XML(xml);

  allPolylines.from_XML(xml);

  allFaces.from_XML(xml);

  allCameras.from_XML(xml);

  allSolids.from_XML(xml);

  allSections.from_XML(xml);

  allModel1Ds.from_XML(xml);

  allModel2Ds.from_XML(xml);

  allGroups.from_XML(xml); // Note: Groups should be inputted after Faces, Polylines, Model1Ds, Model2Ds, etc.

  Land3D.from_XML(xml);

  Earth3D.from_XML(xml);

  Sky3D.from_XML(xml);

  Tropo3D.from_XML(xml);

  Moon3D.from_XML(xml);

  Sun3D.from_XML(xml);

  WIN3D.from_XML(xml);

  User3D.from_XML(xml);

  Select3D.from_XML(xml);

  WORLD.from_XML(xml);

  STUDY.from_XML(xml);

  allWindRoses.from_XML(xml);

  allWindFlows.from_XML(xml);

  allSolidImpacts.from_XML(xml);

  allSolarImpacts.from_XML(xml);

  LAYER_ceilingsky.from_XML(xml);
  LAYER_cloudcover.from_XML(xml);
  LAYER_winddir.from_XML(xml);
  LAYER_windspd.from_XML(xml);
  LAYER_pressure.from_XML(xml);
  LAYER_drybulb.from_XML(xml);
  LAYER_relhum.from_XML(xml);
  LAYER_dirnorrad.from_XML(xml);
  LAYER_difhorrad.from_XML(xml);
  LAYER_glohorrad.from_XML(xml);
  LAYER_direffect.from_XML(xml);
  LAYER_difeffect.from_XML(xml);
  LAYER_precipitation.from_XML(xml);
  LAYER_developed.from_XML(xml);

  println("End of loading XML");
}



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
    allSolarImpacts.rebuild_Image_array = true;
    allWindRoses.rebuild_Image_array = true;

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

  if ((Step == 0) || (Step == 5)) SOLARCHVISION_update_ENSEMBLE_OBSERVED();

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
