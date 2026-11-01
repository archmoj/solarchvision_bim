STATION[] climateTypicalYearCoordinates;

void loadClimateTypicalYearCoordinates () {

  String[] FileALL = loadStrings(Folder_Coordinates + "/TMYEPW.csv");

  String lineSTR;

  int num_stn = FileALL.length - 1; // to skip the first description line

  climateTypicalYearCoordinates = new STATION [num_stn];

  for (int f = 0; f < num_stn; f++) {
    lineSTR = FileALL[f + 1]; // to skip the first description line

    String[] parts = split(lineSTR, ",");

    climateTypicalYearCoordinates[f] = new STATION();

    climateTypicalYearCoordinates[f].setCountry(parts[0]);
    climateTypicalYearCoordinates[f].setProvince(parts[1]);
    climateTypicalYearCoordinates[f].setCity(parts[2]);
    climateTypicalYearCoordinates[f].setLatitude(float(parts[5]));
    climateTypicalYearCoordinates[f].setLongitude(float(parts[6]));
    climateTypicalYearCoordinates[f].setTimezoneLongitude(float(parts[7]) * 15);
    climateTypicalYearCoordinates[f].setElevation(float(parts[8]));

    String url = parts[9];
    climateTypicalYearCoordinates[f].setClimateTypicalYearDownload(url);

    int lastSlashIndex = url.lastIndexOf('/');
    String filename = url.substring(lastSlashIndex + 1).replace(".zip", "");
    climateTypicalYearCoordinates[f].setClimateTypicalYearFilename(filename);
  }
}
