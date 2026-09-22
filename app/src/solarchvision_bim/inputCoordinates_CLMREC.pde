STATION[] CLMREC_Coordinates;

void inputCoordinates_CLMREC () {

  String[] FileALL = loadStrings(Folder_Coordinates + "/CLMREC.txt");

  String lineSTR;

  int num_stn = FileALL.length - 1; // to skip the first description line

  CLMREC_Coordinates = new STATION [num_stn];

  for (int f = 0; f < num_stn; f++) {
    lineSTR = FileALL[f + 1]; // to skip the first description line

    String[] parts = split(lineSTR, ",");

    CLMREC_Coordinates[f] = new STATION();

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
