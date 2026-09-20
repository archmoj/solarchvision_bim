solarchvision_STATION[] TMYEPW_Coordinates;

void inputCoordinates_TMYEPW () {

  String[] FileALL = loadStrings(Folder_Coordinates + "/TMYEPW.csv");

  String lineSTR;

  int num_stn = FileALL.length - 1; // to skip the first description line

  TMYEPW_Coordinates = new solarchvision_STATION [num_stn];

  for (int f = 0; f < num_stn; f++) {
    lineSTR = FileALL[f + 1]; // to skip the first description line

    String[] parts = split(lineSTR, ",");

    TMYEPW_Coordinates[f] = new solarchvision_STATION();

    TMYEPW_Coordinates[f].setCountry(parts[0]);
    TMYEPW_Coordinates[f].setProvince(parts[1]);
    TMYEPW_Coordinates[f].setCity(parts[2]);
    TMYEPW_Coordinates[f].setLatitude(float(parts[5]));
    TMYEPW_Coordinates[f].setLongitude(float(parts[6]));
    TMYEPW_Coordinates[f].setTimelong(float(parts[7]) * 15);
    TMYEPW_Coordinates[f].setElevation(float(parts[8]));

    String url = parts[9];
    TMYEPW_Coordinates[f].setDownload_TMYEPW(url);

    int lastSlashIndex = url.lastIndexOf('/');
    String filename = url.substring(lastSlashIndex + 1).replace(".zip", "");
    TMYEPW_Coordinates[f].setFilename_TMYEPW(filename);
  }
}
