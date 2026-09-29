STATION[] climateArchiveCoordinates;

void loadClimateArchiveCoordinates () {

  String[] FileALL = loadStrings(Folder_Coordinates + "/CLMREC.txt");

  String lineSTR;

  int num_stn = FileALL.length - 1; // to skip the first description line

  climateArchiveCoordinates = new STATION [num_stn];

  for (int f = 0; f < num_stn; f++) {
    lineSTR = FileALL[f + 1]; // to skip the first description line

    String[] parts = split(lineSTR, ",");

    climateArchiveCoordinates[f] = new STATION();

    float latitude = float(parts[6]);
    float longitude = float(parts[7]);

    climateArchiveCoordinates[f].setCity(parts[0].replace('/', '_'));
    climateArchiveCoordinates[f].setProvince(parts[1]);
    climateArchiveCoordinates[f].setCountry("CA");
    climateArchiveCoordinates[f].setLatitude(latitude);
    climateArchiveCoordinates[f].setLongitude(longitude);
    climateArchiveCoordinates[f].setTimezoneLongitude(funcs.roundTo(longitude, 15));
    climateArchiveCoordinates[f].setElevation(float(parts[10]));
    //climateArchiveCoordinates[f].setFilename_CLMREC(?);
  }
}
