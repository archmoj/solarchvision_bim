STATION[] ensembleForecastCoordinates;

void loadEnsembleForecastCoordinates () {

  String[] FileALL = loadStrings(Folder_Coordinates + "/NAEFS.txt");

  String lineSTR;

  int num_stn = FileALL.length - 1; // to skip the first description line

  ensembleForecastCoordinates = new STATION [num_stn];

  for (int f = 0; f < num_stn; f++) {
    lineSTR = FileALL[f + 1]; // to skip the first description line

    String[] parts = split(lineSTR, '\t');

    String filename = parts[0];

    String city = split(filename, '_')[0];
    String province = split(filename, '_')[1];
    String country = split(filename, '_')[2];

    float latitude = 0;
    float longitude = 0;
    float elevation = 0;

    int l = 0;

    l = parts[1].length();
    if (((parts[1].substring(l - 1, l)).equals("N")) || ((parts[1].substring(l - 1, l)).equals("S"))) {
      String[] the_parts = split(parts[1], ':');
      latitude = float(the_parts[0]) + (float(the_parts[1]) / 60.0) + (float(the_parts[2]) / 3600.0);
      if ((parts[1].substring(l - 1, l)).equals("S")) latitude *= -1;
    } else {
      latitude = float(parts[1]);
    }

    l = parts[2].length();
    if (((parts[2].substring(l - 1, l)).equals("E")) || ((parts[2].substring(l - 1, l)).equals("W"))) {
      String[] the_parts = split(parts[2], ':');
      longitude = float(the_parts[0]) + (float(the_parts[1]) / 60.0) + (float(the_parts[2]) / 3600.0);
      if ((parts[2].substring(l - 1, l)).equals("W")) longitude *= -1;
    } else {
      longitude = float(parts[2]);
    }

    l = parts[3].length();
    elevation = float(parts[3].substring(0, l - 1));

    ensembleForecastCoordinates[f] = new STATION();

    ensembleForecastCoordinates[f].setCity(city);
    ensembleForecastCoordinates[f].setProvince(province);
    ensembleForecastCoordinates[f].setCountry(country);
    ensembleForecastCoordinates[f].setLatitude(latitude);
    ensembleForecastCoordinates[f].setLongitude(longitude);
    ensembleForecastCoordinates[f].setTimezoneLongitude(funcs.roundTo(longitude, 15));
    ensembleForecastCoordinates[f].setElevation(elevation);
    ensembleForecastCoordinates[f].setEnsembleForecastFilename(filename);
  }
}
