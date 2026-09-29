STATION[] ensembleObservationCoordinates;

void loadEnsembleObservationCoordinates () {

  String[] FileALL = loadStrings(Folder_Coordinates + "/SWOB.txt");

  String lineSTR;

  int num_stn = FileALL.length - 1; // to skip the first description line

  ensembleObservationCoordinates = new STATION [num_stn];

  for (int f = 0; f < num_stn; f++) {
    lineSTR = FileALL[f + 1]; // to skip the first description line

    String[] parts = split(lineSTR, '\t');

    float latitude = float(parts[5]);
    float longitude = float(parts[6]);

    ensembleObservationCoordinates[f] = new STATION();

    String code = parts[8];
    if (parts[4].equals("Manned")) code += "-MAN";
    if (parts[4].equals("Auto")) code += "-AUTO";

    ensembleObservationCoordinates[f].setCode(code);
    ensembleObservationCoordinates[f].setCity(parts[2]);
    ensembleObservationCoordinates[f].setProvince(parts[3]);
    ensembleObservationCoordinates[f].setCountry("CA");
    ensembleObservationCoordinates[f].setLatitude(latitude);
    ensembleObservationCoordinates[f].setLongitude(longitude);
    ensembleObservationCoordinates[f].setTimezoneLongitude(funcs.roundTo(longitude, 15));
    ensembleObservationCoordinates[f].setElevation(float(parts[7]));
    //ensembleObservationCoordinates[f].setEnsembleObservationFilename(?);

  }
}
