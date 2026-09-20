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
