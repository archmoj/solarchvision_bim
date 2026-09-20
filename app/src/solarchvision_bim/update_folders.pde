void SOLARCHVISION_update_folders () {

  Folder_Import = BaseFolder + "/import";

  Folder_Project = BaseFolder + "/projects/model-01";

  Folder_GEOMET = Folder_Project + "/data/GEOMET" + "/" + RunStamp;

  Folder_ENSEMBLE_FORECAST = Folder_Project + "/data/NAEFS";
  Folder_ENSEMBLE_OBSERVED = Folder_Project + "/data/SWOB";

  Folder_CLIMATE_CLMREC = BaseFolder + "/input/climate/CLMREC";
  Folder_CLIMATE_TMYEPW = BaseFolder + "/input/climate/TMYEPW";
  Folder_CLIMATE_CWEEDS = BaseFolder + "/input/climate/CWEEDS";

  Folder_Coordinates = BaseFolder + "/input/coordinates";
  WORLD.ViewFolder   = BaseFolder + "/input/images/worldmap";

  Folder_People = BaseFolder + "/input/images/people";
  Folder_Trees  = BaseFolder + "/input/images/trees";

  Folder_Shadings = Folder_Project + "/shadings";

  Folder_Land = Folder_Project + "/land";

  Folder_Export      = Folder_Project + "/export";
  Folder_Export3D    = Folder_Export + "/3D" + "/" + RunStamp;
  Folder_Graphics    = Folder_Export + "/graphics" + "/" + RunStamp;
  Folder_ScreenShots = Folder_Export + "/screenshots" + "/" + RunStamp;

  String[] filenames = OPESYS.getFiles(Folder_ScreenShots);
  if (filenames != null) SavedScreenShots = filenames.length;
}

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
String Folder_Import;
String Folder_Export;
String Folder_Project;
String Folder_Graphics;
String Folder_Export3D;
String Folder_ScreenShots;
String Folder_Shadings;