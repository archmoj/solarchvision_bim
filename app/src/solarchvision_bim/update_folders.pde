void update_project_folders () {

  Folder_Project = BaseFolder + "/projects/model-01";

  Folder_GEOMET = Folder_Project + "/data/GEOMET" + "/" + RunStamp;

  Folder_ensembleForecast = Folder_Project + "/data/NAEFS";
  Folder_ensembleObservation = Folder_Project + "/data/SWOB";

  Folder_Shadings = Folder_Project + "/shadings";

  Folder_Land = Folder_Project + "/land";

  Folder_Export      = Folder_Project + "/export";
  Folder_Export3D    = Folder_Export + "/3D" + "/" + RunStamp;
  Folder_Graphics    = Folder_Export + "/graphics" + "/" + RunStamp;
  Folder_ScreenShots = Folder_Export + "/screenshots" + "/" + RunStamp;

  String[] filenames = OPESYS.getFiles(Folder_ScreenShots);
  if (filenames != null) SavedScreenShots = filenames.length;
}

String Folder_climateTmyEpw = BaseFolder + "/input/climate/TMYEPW";
String Folder_climateEngineering = BaseFolder + "/input/climate/CWEEDS";
String Folder_climateArchive = BaseFolder + "/input/climate/CLMREC";
String Folder_ensembleObservation;
String Folder_ensembleForecast;
String Folder_GEOMET;

String Folder_Coordinates = BaseFolder + "/input/coordinates";

String Folder_Land;
String Folder_People = BaseFolder + "/input/images/people";
String Folder_Trees = BaseFolder + "/input/images/trees";

String Folder_Import = BaseFolder + "/import";

String Folder_Export;
String Folder_Project;
String Folder_Graphics;
String Folder_Export3D;
String Folder_ScreenShots;
String Folder_Shadings;