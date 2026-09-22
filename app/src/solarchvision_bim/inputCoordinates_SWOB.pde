STATION[] SWOB_Coordinates;

void inputCoordinates_SWOB () {

  String[] FileALL = loadStrings(Folder_Coordinates + "/SWOB.txt");

  String lineSTR;

  int num_stn = FileALL.length - 1; // to skip the first description line

  SWOB_Coordinates = new STATION [num_stn];

  for (int f = 0; f < num_stn; f++) {
    lineSTR = FileALL[f + 1]; // to skip the first description line

    String[] parts = split(lineSTR, '\t');

    float latitude = float(parts[5]);
    float longitude = float(parts[6]);

    SWOB_Coordinates[f] = new STATION();

    String code = parts[8];
    if (parts[4].equals("Manned")) code += "-MAN";
    if (parts[4].equals("Auto")) code += "-AUTO";

    SWOB_Coordinates[f].setCode(code);
    SWOB_Coordinates[f].setCity(parts[2]);
    SWOB_Coordinates[f].setProvince(parts[3]);
    SWOB_Coordinates[f].setCountry("CA");
    SWOB_Coordinates[f].setLatitude(latitude);
    SWOB_Coordinates[f].setLongitude(longitude);
    SWOB_Coordinates[f].setTimelong(funcs.roundTo(longitude, 15));
    SWOB_Coordinates[f].setElevation(float(parts[7]));
    //SWOB_Coordinates[f].setFilename_SWOB(?);

  }
}
