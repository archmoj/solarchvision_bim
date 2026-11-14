// Resets Folder_Project to the default project - startup's own first
// project, before anything has been opened or newly created. Kept
// separate from update_project_folders() below (which this is always
// followed by - see drawInitialFrames.pde) specifically so that
// update_project_info() (fileSelected.pde, called from both
// _fileSelected_Open() and _fileSelected_New()) can call
// update_project_folders() on its own, AFTER it has already set
// Folder_Project to the just-opened/just-created project's own real
// folder - update_project_folders() previously hardcoded this same
// default assignment itself, silently overwriting whatever
// update_project_info() had just set and making OPEN/NEW unable to
// actually switch projects via this path at all.
void reset_project_folder_to_default () {
  Folder_Project = BaseFolder + "/projects/model-01";
}

// Derives every other project-scoped folder from Folder_Project as it
// currently stands - does NOT itself decide what Folder_Project is.
// Callers that want the startup default call reset_project_folder_to_default()
// immediately before this; callers switching to a different project
// (update_project_info()) set Folder_Project themselves first instead.
void update_project_folders () {

  Folder_GEOMET = Folder_Project + "/data/GEOMET" + "/" + RunStamp;

  Folder_ensembleForecast = Folder_Project + "/data/NAEFS";
  Folder_ensembleObservation = Folder_Project + "/data/SWOB";

  Folder_Shadings = Folder_Project + "/shadings";

  Folder_Terrain = Folder_Project + "/terrain";

  Folder_Export      = Folder_Project + "/export";
  Folder_Export3D    = Folder_Export + "/3D" + "/" + RunStamp;
  Folder_Graphics    = Folder_Export + "/graphics" + "/" + RunStamp;
  Folder_ScreenShots = Folder_Export + "/screenshots" + "/" + RunStamp;

  String[] filenames = OPESYS.getFiles(Folder_ScreenShots);
  if (filenames != null) SavedScreenShots = filenames.length;
}

String Folder_Export;
String Folder_Project;
String Folder_Graphics;
String Folder_Export3D;
String Folder_ScreenShots;
String Folder_Shadings;

String Folder_Input;

String Folder_climateTypicalYear;
String Folder_climateEngineering;
String Folder_climateArchive;
String Folder_ensembleObservation;
String Folder_ensembleForecast;
String Folder_GEOMET;

String Folder_Coordinates;

String Folder_Terrain;
String Folder_People;
String Folder_Trees;

String Folder_Import;

void update_input_folders () {
  Folder_Input = BaseFolder + "/input";

  Folder_climateTypicalYear = Folder_Input + "/climate/TMYEPW";
  Folder_climateEngineering = Folder_Input + "/climate/CWEEDS";
  Folder_climateArchive = Folder_Input + "/climate/CLMREC";

  Folder_Coordinates = Folder_Input + "/coordinates";

  Folder_People = Folder_Input + "/images/people";
  Folder_Trees = Folder_Input + "/images/trees";

  Folder_Import = BaseFolder + "/import";

  Moon3D.Filename = Folder_Input + "/images/moon/Moon.jpg";
  Sun3D.Filename = Folder_Input + "/images/sun/Sun.jpg";
  WORLD.ViewFolder = Folder_Input + "/images/worldmap";
  Earth3D.Path = Folder_Input +
      "/images/earth";
  //  "/images/earth_high_res";
}

void locateBaseFolder () {
  BaseFolder = sketchPath();
  boolean foundInputFolder = false;
  File inputDir;
  // walk up the folders to find the input directory
  for (int i = 0; i < 3; i++) {
    inputDir = new File(BaseFolder, "input");
    if (inputDir.exists() && inputDir.isDirectory()) {
      foundInputFolder = true;
      break;
    }
    BaseFolder += "/..";
  }
  if (!foundInputFolder) {
    println("Error: Unable to locate input directory.");
    System.exit(1);
  }
}
