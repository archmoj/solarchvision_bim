String RunStamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2);
String ProjectName = "Revision_" + RunStamp;
String HoldStamp = "";

String Subfolder_exportMaps = "maps/";

STATION STATION = new STATION(
  //"", "EPFL", "", "", 46.51835, 6.56825, 0, 0, "", "", "", "", ""
  //"", "Ramsar", "", "IR", 36.9268, 50.6431, 52.5, 0, "", "", "", "", ""
  //"", "National University of Iran", "", "IR", 35.7968, 51.3945, 52.5, 1530, "", "", "", "", ""
  //"", "Montreal", "QC", "CA", 45.47, -73.75, -75, 36, "", "CAN_PQ_Montreal.Intl.AP.716270_CWEC", "CAN_QC_MONTREAL-INTL-A_7025251_CWEEDS2011_1998-2017", "MONTREAL_DORVAL_QC_CA", ""
  "", "Toronto", "ON", "CA", 43.67, -79.63, -75, 173, "", "CAN_ON_Toronto.716240_CWEC", "CAN_ON_TORONTO-INTL-A_6158731_CWEEDS2011_1998-2017", "TORONTO_PEARSON_INTL_ON_CA", "CYYZ-MAN"
  //"", "Vancouver", "BC", "CA", 49.18, -123.17, -120, 2, "", "CAN_BC_Vancouver.718920_CWEC", "CAN_BC_VANCOUVER-INTL-A_1108395_CWEEDS2011_1998-2017", "VANCOUVER_INTL_BC_CA", ""
);

OBJECTTYPE ObjectCategory = new OBJECTTYPE();

WINDOWTYPE TypeWindow = new WINDOWTYPE();

CREATE CREATE = new CREATE();

int CreateObject = CREATE.Nothing;

int currentObjectCategory = ObjectCategory.GROUP;

int current_Material = 7;
int current_Tessellation = 0;
int current_Layer = 0;
int current_Visibility = 1;
int current_Weight = 0;
int current_Closed = 0;

final String[] STR_SHD = {"F", "T"};

class DATATYPE {

  final static String CLASS_STAMP = "DATATYPE";

  final static int SATELLITE_GOES = 0;
  final static int FORECAST_HRDPS = 1;
  final static int FORECAST_RDPS  = 2;
  final static int FORECAST_GDPS  = 3;

}

DATATYPE DataType = new DATATYPE();

int WMS_type = DataType.FORECAST_HRDPS; // <<<<<<<<<<<<<

int TROPO_deltaTime = (WMS_type == DATATYPE.FORECAST_GDPS) ? 3 : 1;
int TROPO_timeSteps = 24;

float interpolationWeight = 0.5;// 0 = linear distance interpolation, 1 = square distance interpolation, 5 = nearest

final int Impact_ACTIVE = 0; // internal
final int Impact_PASSIVE = 1; // internal
final int numberOfImpactVariations = 2; // internal

final int impactGraphIndex_CYCLES_ACTIVE = 0;
final int impactGraphIndex_CYCLES_PASSIVE = 1;
final int impactGraphIndex_SUNPATH_ACTIVE = 2;
final int impactGraphIndex_SUNPATH_PASSIVE = 3;
final int impactGraphIndex_GLOBAL_ACTIVE = 4;
final int impactGraphIndex_GLOBAL_PASSIVE = 5;
final int impactGraphIndex_WIND_ACTIVE = 6;
final int impactGraphIndex_WIND_PASSIVE = 7;
final int impactGraphIndex_URBAN_ACTIVE = 8;
final int impactGraphIndex_URBAN_PASSIVE = 9;

float CubePower = 16; //8;
float StarPower = 0.25;

final float FLOAT_e = 2.7182818284;

final double DOUBLE_r_Earth = 6367470.0; //6373000.0;
final float FLOAT_r_Earth = (float) DOUBLE_r_Earth;

float CrustDepth = 1000; // 1000m .The actual crust ranges from 5–70 km

float EyeLevel = 1.5; // 1.5 abouve ground - applied for setting cameras - intrenal!

float globalAlbedo = 0; // 0-100

float celestialMagnification = 16.0; // <<<<<<<<<<

boolean FRAME_record_AUTO = false;
boolean FRAME_record_IMG = false;
boolean FRAME_click_IMG = false;
boolean FRAME_drag_IMG = false;

//-------------------------------

int climateBasedSolarForecast = 0; //                                   Used for solar radiation only
int climateBasedWeatherForecast = 0; // 0:linear 1:average 2:sky-based. Used for some parameters namely: air temperature, humidity

static final int USER_GUI = 0;
static final int USER_AUTO = 1;

int control = USER_GUI;

String[] skyScenarioSetting_Title = {
  "", "All", "Cloudy\nPattern", "Partly\nCloudy\nPattern", "Sunny\nPattern"
};
String[] skyScenarioSetting_FileTXT = {
  "", "", "Overcast sky", "Scattered sky", "Clear sky"
};

final int filter_HOURLY = 0;
final int filter_DAILY = 1;

int impactDisplayDay = 0; // 0:total 1:day-1 2:day-2 etc.

final int numberOfLanguages = 2;
final int Language_EN = 0;
final int Language_FR = 1;
int activeLanguage = Language_EN;

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



OperatingSystem OPESYS = new OperatingSystem();

TIME TIME = new TIME();

Functions funcs = new Functions();

UITASK UITASK = new UITASK();


int ensembleForecastMaxDays = 16; // Constant
int ensembleObservationMaxDays = 3; // Variable

int climateTypicalYearStart = 1;
int climateTypicalYearEnd = 1;

int climateEngineeringStart = 1970;
int climateEngineeringEnd = 2017;

int climateArchiveStart = 2000;
int climateArchiveEnd = year();

int ensembleForecastStart = 1;
int ensembleForecastEnd = 43; // NAEFS:1-43,

int nearestWeatherStationCount = 1; //3;

int ensembleObservationStart = 1;
int ensembleObservationEnd = nearestWeatherStationCount;

int[] ensembleObservationNearestStationIndex = new int [nearestWeatherStationCount];
float[] ensembleObservationNearestStationDist = new float [nearestWeatherStationCount];

int climateArchiveNearestStationIndex = -1;
float climateArchiveNearestStationDist = FLOAT_undefined;

int sampleYearStart = 1980;
int sampleYearEnd = year();

int sampleMemberStart = 1;
int sampleMemberEnd = 43;

int sampleStationStart = 1;
int sampleStationEnd = nearestWeatherStationCount;

float[][][][] climateTypicalYearValues;
boolean[][][][] climateTypicalYearFlags;

float[][][][] climateEngineeringValues;
boolean[][][][] climateEngineeringFlags;

float[][][][] climateArchiveValues;
boolean[][][][] climateArchiveFlags;

float[][][][] ensembleForecastValues;
boolean[][][][] ensembleForecastFlags;

float[][][][] ensembleObservationValues;
boolean[][][][] ensembleObservationFlags;

boolean climateTypicalYearShouldLoad = true;
boolean climateEngineeringShouldLoad = false;
boolean climateArchiveShouldLoad = false;
boolean ensembleForecastShouldLoad = false;
boolean ensembleObservationShouldLoad = false;

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

int developLayerOption = DEV_WindPower;
int developLayerInterval = 0; //0:accumulative 1:daily(24h) 2:per12h 3:per6h <should be zero to work well with current menues>

boolean developDataUpdate = true;

float developLayerAngleInclination = 45; // 90 = horizontal surface, 0 = Vertical surface
float developLayerAngleOrientation = 0; // 0 = South, 90 = East

SHADE SHADE = new SHADE();


class MESSAGE {

  String CLASS_STAMP = "MESSAGE";

  int cX = 0;
  int cY = height / 2;
  int dX = width;
  int dY = int(2 * MessageSize);
}

MESSAGE MESSAGE = new MESSAGE();

STUDY STUDY = new STUDY();

WORLD WORLD = new WORLD();

WIN3D WIN3D = new WIN3D();

Overlay3D Overlay3D = new Overlay3D();

UI_rollout UI_rollout = new UI_rollout();
react react = new react();
ValueModifier vm = new ValueModifier();

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
    txt += "CAM" + nf(WIN3D.currentCameraIndex, 2) + "_";
  }
  else {
    txt += "IMG" + nf(SavedScreenShots, 4) + "_";
  }

  txt += STATION.getCity() + "_";

  if (impactDisplayDay != 0) {
    txt += TIME.getMM((impactDisplayDay - 1) * STUDY.dayIncrement + 286 + TIME.beginDay);
  }
  else {
    txt += TIME.getMM( STUDY.startDay    * STUDY.dayIncrement + 286 + TIME.beginDay) + "-" +
           TIME.getMM((STUDY.endDay - 1) * STUDY.dayIncrement + 286 + TIME.beginDay);
  }

  return txt;
}

final String ANSI_RESET = "\u001B[0m";

final String ANSI_BLACK = "\u001B[30m";
final String ANSI_RED = "\u001B[31m";
final String ANSI_GREEN = "\u001B[32m";
final String ANSI_YELLOW = "\u001B[33m";
final String ANSI_BLUE = "\u001B[34m";
final String ANSI_PURPLE = "\u001B[35m";
final String ANSI_CYAN = "\u001B[36m";

final String ANSI_BLACK_BG = "\u001B[40m";
final String ANSI_RED_BG = "\u001B[41m";
final String ANSI_GREEN_BG = "\u001B[42m";
final String ANSI_YELLOW_BG = "\u001B[43m";
final String ANSI_BLUE_BG = "\u001B[44m";
final String ANSI_PURPLE_BG = "\u001B[45m";
final String ANSI_CYAN_BG = "\u001B[46m";

final String OSC8_START = "\u001B]8;;";
final String OSC8_END = "\u001B\\";
final String OSC8_CLOSE = "\u001B]8;;\u001B\\";

String terminalLink (String path) {
  File file = new File(path);
  String linkText = path; // file.getName();
  String fileUri = "file://" + file.getAbsolutePath();

  return (OSC8_START + fileUri + OSC8_END + linkText + OSC8_CLOSE);
}

String terminalLinkColor (String path) {
 return (ANSI_BLACK + ANSI_YELLOW_BG + terminalLink(path) + ANSI_RESET);
}

void printlnSaving (String path) {
  println("Saving:", (control == USER_GUI) ? terminalLinkColor(path) : path);
}


String ScreenShotName = "";
String ScreenShotType = ".jpg";

void RecordFrame () {

  String Filename = Folder_ScreenShots + "/";
  if(ScreenShotName.equals("")) {
    Filename += createStamp(1, "Screen");
  } else {
    Filename += ScreenShotName;
    ScreenShotName = ""; // reset here to avoid overwrite
  }
  Filename += ScreenShotType;

  printlnSaving(Filename);

  saveFrame(Filename);
}

void screenShot (String fileFormat) {
  ScreenShotType = fileFormat;
  FRAME_record_IMG = true;
}

void screenShot (String fileFormat, String fileName) {
  ScreenShotName = fileName;
  ScreenShotType = fileFormat;
  FRAME_record_IMG = true;
}

String MAKE_Filename (String beginName) {

  String My_Filenames = Folder_ScreenShots + "/" + beginName;

  return My_Filenames;
}

String MAKE_MainName () {

  String s = "";

  if (currentDataSource == dataID_ensembleForecast) s = nf(TIME.year, 2) + nf(TIME.month, 2) + nf(TIME.day, 2) + "_" + nf(STUDY.endDay, 0) + "dayFORECAST_";

  return s;
}

String getFilename_SolidImpact () {

  return Folder_Graphics + "/" + nf(TIME.year, 2) + "-" + nf(TIME.month, 2) + "-" + nf(TIME.day, 2) + "/" + databaseString[currentDataSource] + "/Impacts/Solid" + nf(allSolidImpacts.sectionType, 0) + "h" + nf(int(funcs.roundTo(allSolidImpacts.Z[allSolidImpacts.sectionType], 1)), 4) + "r" + nf(int(funcs.roundTo(allSolidImpacts.R[allSolidImpacts.sectionType], 1)), 3) + "p" + nf(allSolidImpacts.Power, 2, 2).replace(".", "_") + "m" + nf(allSolidImpacts.Grade, 2, 2).replace(".", "_");
}

String getFilename_SolarImpact () {

  return Folder_Graphics + "/" + nf(TIME.year, 2) + "-" + nf(TIME.month, 2) + "-" + nf(TIME.day, 2) + "/" + databaseString[currentDataSource] + "/Impacts/Solar" + nf(allSolarImpacts.sectionType, 0) + "h" + nf(int(funcs.roundTo(allSolarImpacts.Z, 1)), 4) + "r" + nf(int(funcs.roundTo(allSolarImpacts.R, 1)), 3);
}

float HeightAboveGround = 0; //2.5; // <<<<<<<<<

float locationLatitude = 0.0;
float locationLongitude = 0.0;
float LocationELE = 0.0;

int save_frame_number = 0;

int currentColorStyle = 0;
int colorStyleCount = 20; //6;

final int dataID_ensembleObservation = 0;
final int dataID_ensembleForecast = 1;
final int dataID_climateEngineering = 2;
final int dataID_climateArchive = 3;
final int dataID_climateTypicalYear = 4;
final int MAXIMUM_dataID = dataID_climateTypicalYear;

int currentDataSource = dataID_climateTypicalYear;

final String[] databaseString = {
  "Ensemble Observation", "Ensemble Forecast", "Climate Engineering", "Climate Archive", "Climate Typical Year"
};

int drawnFrame = 0;

int X_clicked = -1;
int Y_clicked = -1;

int X_click1 = -1;
int Y_click1 = -1;
int X_click2 = -1;
int Y_click2 = -1;

int cameraIndex = 0; // 1;

Materials allMaterials = new Materials();

Faces allFaces = new Faces();

Polylines allPolylines = new Polylines();

Groups allGroups = new Groups();

SolidImpacts allSolidImpacts = new SolidImpacts();

SolarImpacts allSolarImpacts = new SolarImpacts();

Edit3D Edit3D = new Edit3D();

Scale3D Scale3D = new Scale3D();

Rotate3D Rotate3D = new Rotate3D();

Move3D Move3D = new Move3D();

Drop3D Drop3D = new Drop3D();

Clone3D Clone3D = new Clone3D();

Delete3D Delete3D = new Delete3D();

Select3D Select3D = new Select3D();

float[][] saved_BoundingBox = Select3D.BoundingBox;

int saved_pivotAlignmentX = Select3D.pivotAlignmentX;
int saved_pivotAlignmentY = Select3D.pivotAlignmentY;
int saved_pivotAlignmentZ = Select3D.pivotAlignmentZ;

int addNewSelectionToPreviousSelection = 0; // internal

// Remembers what addNewSelectionToPreviousSelection was set to right
// before Ctrl/Alt overrode it, so keyReleased() can restore that value
// instead of always resetting to 0. Guarded by the boolean below so key
// repeat events (which keep firing keyPressed while a key is held) don't
// keep overwriting the backup with the already-overridden value.
int addNewSelectionToPreviousSelection_beforeModifierKey = 0;
boolean addNewSelectionToPreviousSelection_isOverridden = false;

boolean addToLastGroup = false; // internal

void find_which_bakings_to_regenerate () {

  if (WIN3D.shadingMode == SHADE.Global_Solar) {
    GlobalSolar_rebuild_array = true;
  }
  if (WIN3D.shadingMode == SHADE.Vertex_Solar) {
    VertexSolar_rebuild_array = true;
  }
  if (allSolarImpacts.displayImage) {
    allSolarImpacts.rebuild_Image_array = true;
  }
  if (allWindRoses.displayImage) {
    allWindRoses.rebuild_Image_array = true;
  }
}

void regenerate_desired_bakings () {

  if (VertexSolar_rebuild_array) {
    calculate_VertexSolar_array();
  }

  if (GlobalSolar_rebuild_array) {
    calculate_GlobalSolar_array();
  }

}

PAINT PAINT = new PAINT();

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

void OBJprintVertex (float x, float y, float z) {

  float a = x * User3D.exporterScale;
  float b = y * User3D.exporterScale;
  float c = z * User3D.exporterScale;

  if (User3D.exporterYaxisUp == 0) {

    objOutput.println("v " + nf(a, 0, User3D.exporterPrecisionVertex) + " " +  nf(b, 0, User3D.exporterPrecisionVertex) + " " +  nf(c, 0, User3D.exporterPrecisionVertex));
  } else {

    objOutput.println("v " + nf(-a, 0, User3D.exporterPrecisionVertex) + " " +  nf(c, 0, User3D.exporterPrecisionVertex) + " " +  nf(b, 0, User3D.exporterPrecisionVertex));
  }
}

void OBJprintVtexture (float u, float v, float w) {

  objOutput.println("vt " + nf(u, 0, User3D.exporterPrecisionVertexTexture) + " " + nf(v, 0, User3D.exporterPrecisionVertexTexture) + " " + nf(w, 0, User3D.exporterPrecisionVertexTexture));
}

void HTMLprintVtexture (float u, float v) {

  htmlOutput.print(nf(u, 0, User3D.exporterPrecisionVertexTexture) + " " + nf(v, 0, User3D.exporterPrecisionVertexTexture));
}

String importedObjectName = "";

void deleteAll () {

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

void model_added () {

  Select3D.selectLast();

  selection_changed();
}

boolean should_rebuildFaceGrid = true;

void model_changed () {
  should_rebuildFaceGrid = true;

  view_changed();
}

void view_changed () {
  WIN3D.revise();
}

void selection_changed () {

  Select3D.reset_selectedRefValues();

  Select3D.revise_BoundingBox();

  view_changed();
}

void switch_category (int a) {

  currentObjectCategory = a;

  UI_toolBar.revise();

  selection_changed();
}

float overallScale = 1.0;

int SKY2D_X_View = 50;
int SKY2D_Y_View = 50;
float SKY2D_ZOOM = 5;
PGraphics SKY2D_graphics;

int getLocationTimeZone () {
  return int(funcs.roundTo(STATION.getLongitude() / 15, 15));
}

Tropo3D Tropo3D = new Tropo3D();

Sky3D Sky3D = new Sky3D();

Sun3D Sun3D = new Sun3D();

Moon3D Moon3D = new Moon3D();

Earth3D Earth3D = new Earth3D();

Terrain Terrain = new Terrain();

Model1Ds allModel1Ds = new Model1Ds();

Model2Ds allModel2Ds = new Model2Ds();

Solids allSolids = new Solids();

float[][] allVertices = new float[0][3];
// to increase performance we defined vertices array outside Points class
Points allPoints = new Points();

User3D User3D = new User3D();

Modify3D Modify3D = new Modify3D();

Create3D Create3D = new Create3D();

Cameras allCameras = new Cameras();

Sections allSections = new Sections();

WindRose allWindRoses = new WindRose();

WindFlow allWindFlows = new WindFlow();

void VertexSolar_resize_array () { // called when STUDY.endDay changes

  VertexSolar_XYZ     = new float [0][3];
  VertexSolar_amounts = new float [2][1 + STUDY.endDay - STUDY.startDay][0];

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

  s += "x" + nf(WIN3D.positionX, 0, 3);
  s += "y" + nf(WIN3D.positionY, 0, 3);
  s += "z" + nf(WIN3D.positionZ, 0, 3);

  s += "rx" + nf(WIN3D.rotationX, 0, 3);
  s += "ry" + nf(WIN3D.rotationY, 0, 3);
  s += "rz" + nf(WIN3D.rotationZ, 0, 3);

  s = s.replace('.', 'p');
  s = s.replace('-', 'n');

  */

  return s;
}

int UI_X_moved = -1;
int UI_Y_moved = -1;

void modify_Viewport_Title () {

  String s = "Cam" + nf(WIN3D.currentCameraIndex, 2);

  UI_toolBar.Items[0][11] = s; // <<<<< Note: 3DViewPoint is the first index on BAR_b
  UI_toolBar.highlight(s);

  UI_toolBar.revise();
}

float[][] DiffuseVectors;

float X_control;
float Y_control;

UI_menuBar UI_menuBar = new UI_menuBar();

UI_toolBar UI_toolBar = new UI_toolBar();

UI_consoleBar UI_consoleBar = new UI_consoleBar();

UI_caseBar UI_caseBar = new UI_caseBar();

String[] allCommands = {"Command Input:", ""};
String[] allMessages = {"Command Output:", ""};

int typeUserCommand = 0;

float MessageSize = 0.0;
int pixel_A = 0;
int pixel_B = 0;
int pixel_C = 0;
int pixel_D = 0;

int pixel_H = 0;
int pixel_W = 0;

int screenWidth = 0;
int screenHeight = 0;


PGraphics TREES_graphics;

PGraphics SHADOW_graphics;

float Shades_scaleX;
float Shades_scaleY;

float Shades_offsetX;
float Shades_offsetY;

float[] SunR_Rotated;

String save_folder = "";

void holdProject () {

  HoldStamp = nf(millis(), 0);

  String myFile = Folder_Project + "/Temp/" + ProjectName + "_tmp" + HoldStamp + ".xml";

  saveProject(myFile);
}

void fetchProject () {

  String myFile = Folder_Project + "/Temp/" + ProjectName + "_tmp" + HoldStamp + ".xml";

  try {
    load_project(myFile);
  }
  catch (Exception e) {
    println("Cannot find the hold file:", myFile);
  }
}

String TERRAINTAP_API_KEY = "";

void load_env () {
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
