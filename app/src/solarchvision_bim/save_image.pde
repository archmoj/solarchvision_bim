String ScreenShotName = "";
String ScreenShotType = ".jpg";

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
    txt += TIME.getMM((impactDisplayDay - 1) * STUDY.dailyStep + 286 + TIME.beginDay);
  }
  else {
    txt += TIME.getMM( STUDY.startDay    * STUDY.dailyStep + 286 + TIME.beginDay) + "-" +
           TIME.getMM((STUDY.endDay - 1) * STUDY.dailyStep + 286 + TIME.beginDay);
  }

  return txt;
}


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
