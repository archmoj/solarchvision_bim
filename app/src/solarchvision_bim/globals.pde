String RunStamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2);
String ProjectName = "Revision_" + RunStamp;
String HoldStamp = "";

String Subfolder_exportMaps = "maps/";

solarchvision_STATION STATION = new solarchvision_STATION(
  //"", "Montreal", "QC", "CA", 45.47, -73.75, -75, 36, "", "CAN_PQ_Montreal.Intl.AP.716270_CWEC", "CAN_QC_MONTREAL-INTL-A_7025251_CWEEDS2011_1998-2017", "MONTREAL_DORVAL_QC_CA", ""
  "", "Toronto", "ON", "CA", 43.67, -79.63, -75, 173, "", "CAN_ON_Toronto.716240_CWEC", "CAN_ON_TORONTO-INTL-A_6158731_CWEEDS2011_1998-2017", "TORONTO_PEARSON_INTL_ON_CA", "CYYZ-MAN"
  //"", "Vancouver", "BC", "CA", 49.18, -123.17, -120, 2, "", "CAN_BC_Vancouver.718920_CWEC", "CAN_BC_VANCOUVER-INTL-A_1108395_CWEEDS2011_1998-2017", "VANCOUVER_INTL_BC_CA", ""
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

final String[] STR_SHD = {"F", "T"};

class solarchvision_DATATYPE {

  final static String CLASS_STAMP = "DATATYPE";

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

float Planetary_Magnification = 16.0; // <<<<<<<<<<

boolean FRAME_record_AUTO = false;
boolean FRAME_record_IMG = false;
boolean FRAME_click_IMG = false;
boolean FRAME_drag_IMG = false;

//-------------------------------

int CLIMATIC_SolarForecast = 0; //                                   Used for solar radiation only
int CLIMATIC_WeatherForecast = 0; // 0:linear 1:average 2:sky-based. Used for some parameters namely: air temperature, humidity

static final int USER_GUI = 0;
static final int AUTO_PNG = 1;
static final int AUTO_JPG = 2;
static final int AUTO_TIF = 3;
static final int AUTO_BMP = 4;

int SOLARCHVISION_automated = USER_GUI;

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
final float FLOAT_tiny = 0.001; // don't use very tiny values that could result is shading problems

final String STRING_undefined = "N/A";
final float FLOAT_undefined = Float.MAX_VALUE; // it must be a positive big number that is not included in any data

boolean is_defined (float a) {
  if (a < FLOAT_undefined) {
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



solarchvision_OperatingSystem OPESYS = new solarchvision_OperatingSystem();

solarchvision_TIME TIME = new solarchvision_TIME();

solarchvision_Functions funcs = new solarchvision_Functions();

solarchvision_UITASK UITASK = new solarchvision_UITASK();


int ENSEMBLE_FORECAST_maxDays = 16; // Constant
int ENSEMBLE_OBSERVED_maxDays = 3; // Variable

int CLIMATE_TMYEPW_start = 1;
int CLIMATE_TMYEPW_end = 1;

int CLIMATE_CWEEDS_start = 1970;
int CLIMATE_CWEEDS_end = 2017;

int CLIMATE_CLMREC_start = 2000;
int CLIMATE_CLMREC_end = year();

int ENSEMBLE_FORECAST_start = 1;
int ENSEMBLE_FORECAST_end = 43; // NAEFS:1-43,

int ENSEMBLE_OBSERVED_numNearest = 1; //3;

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


class solarchvision_MESSAGE {

  String CLASS_STAMP = "MESSAGE";

  int cX = 0;
  int cY = height / 2;
  int dX = width;
  int dY = int(2 * MessageSize);
}

solarchvision_MESSAGE MESSAGE = new solarchvision_MESSAGE();

solarchvision_STUDY STUDY = new solarchvision_STUDY();

solarchvision_WORLD WORLD = new solarchvision_WORLD();

solarchvision_WIN3D WIN3D = new solarchvision_WIN3D();

solarchvision_OVERLAY3D OVERLAY3D = new solarchvision_OVERLAY3D();

solarchvision_UI_rollout UI_rollout = new solarchvision_UI_rollout();

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

// Remembers what addNewSelectionToPreviousSelection was set to right
// before Ctrl/Alt overrode it, so keyReleased() can restore that value
// instead of always resetting to 0. Guarded by the boolean below so key
// repeat events (which keep firing keyPressed while a key is held) don't
// keep overwriting the backup with the already-overridden value.
int addNewSelectionToPreviousSelection_beforeModifierKey = 0;
boolean addNewSelectionToPreviousSelection_isOverridden = false;

boolean addToLastGroup = false; // internal

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

boolean should_rebuildFaceGrid = true;

void SOLARCHVISION_model_changed () {
  should_rebuildFaceGrid = true;

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

String[] allCommands = {"Command Input:", ""};
String[] allMessages = {"Command Output:", ""};

int typeUserCommand = 0;






PGraphics TREES_graphics;

PGraphics SHADOW_graphics;

float Shades_scaleX;
float Shades_scaleY;

float Shades_offsetX;
float Shades_offsetY;

float[] SunR_Rotated;

String save_folder = "";

void SOLARCHVISION_holdProject () {

  HoldStamp = nf(millis(), 0);

  String myFile = Folder_Project + "/Temp/" + ProjectName + "_tmp" + HoldStamp + ".xml";

  SOLARCHVISION_saveProject(myFile);
}

void SOLARCHVISION_fetchProject () {

  String myFile = Folder_Project + "/Temp/" + ProjectName + "_tmp" + HoldStamp + ".xml";

  try {
    SOLARCHVISION_load_project(myFile);
  }
  catch (Exception e) {
    println("Cannot find the hold file:", myFile);
  }
}

String TERRAINTAP_API_KEY = "";

void SOLARCHVISION_load_env () {
  String[] lines = loadStrings(".env");
  if (lines != null) {
    int len = lines.length;
    for (int i = 0; i < len; i++) {
      String[] parts = lines[i].split("=");
      if(parts.length > 1) {
        String key = parts[0];
        String val = parts[1];
        if(key.equals("TERRAINTAP_API_KEY")) {
          TERRAINTAP_API_KEY = val;
        }
      }
    }
  }
}

void progressBarHeader () {
  println("       10%       20%       30%       40%       50%       60%       70%       80%       90%       100%");
  println(".........|.........|.........|.........|.........|.........|.........|.........|.........|.........|");
}

float applyPalDirection (float u, int PAL_direction) {
  if (PAL_direction == -1) return 1 - u;
  if (PAL_direction == -2) return 0.5 - 0.5 * u;
  if (PAL_direction == 2)  return 0.5 * u;
  return u;
}
