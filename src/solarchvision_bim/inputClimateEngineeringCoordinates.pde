STATION[] climateEngineeringCoordinates;

void loadClimateEngineeringCoordinates () {

  String[] FileALL = loadStrings(Folder_Coordinates + "/CWEEDS.txt");

  String lineSTR;

  int num_stn = FileALL.length - 1; // to skip the first description line

  climateEngineeringCoordinates = new STATION [num_stn];

  for (int f = 0; f < num_stn; f++) {
    lineSTR = FileALL[f + 1]; // to skip the first description line

    String[] parts = split(lineSTR, ',');

    float latitude = float(parts[5]);
    float longitude = float(parts[6]);

    climateEngineeringCoordinates[f] = new STATION();

    climateEngineeringCoordinates[f].setCity(parts[1]);
    climateEngineeringCoordinates[f].setProvince(parts[2]);
    climateEngineeringCoordinates[f].setCountry(parts[3]);
    climateEngineeringCoordinates[f].setLatitude(latitude);
    climateEngineeringCoordinates[f].setLongitude(longitude);
    climateEngineeringCoordinates[f].setTimezoneLongitude(float(parts[7]));
    climateEngineeringCoordinates[f].setElevation(float(parts[8]));
    climateEngineeringCoordinates[f].setClimateEngineeringFilename(parts[9]);
  }
}
