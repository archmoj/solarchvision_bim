void load_CLIMATE_CLMREC (String FileName) {

  String[] FileALL = loadStrings(FileName);

  String lineSTR;
  String[] input;

  println("lines = ", FileALL.length);

  for (int f = 18; f < FileALL.length; f++) {

    lineSTR = FileALL[f];
    //println(lineSTR);

    lineSTR = lineSTR.replace("\"", "");
    String[] parts = split(lineSTR, ",");

    int CLIMATE_YEAR = int(parts[1]);
    int CLIMATE_MONTH = int(parts[2]);
    int CLIMATE_DAY = int(parts[3]);
    int CLIMATE_HOUR = int(parts[4].substring(0, 2));

    //println(CLIMATE_YEAR, CLIMATE_MONTH, CLIMATE_DAY, CLIMATE_HOUR);

    int i = int(CLIMATE_HOUR);
    int j = TIME.convert2Date(CLIMATE_MONTH, CLIMATE_DAY);
    int k = (CLIMATE_YEAR - CLIMATE_CLMREC_start);

    //println(i);

    if (parts.length > 24) {

      String str = "";

      str = parts[24];

      //println(str);

      if (str.equals("NA")) CLIMATE_CLMREC_values[i][j][LAYER_cloudcover.id][k] = FLOAT_undefined;
      else if (str.equals("Clear")) CLIMATE_CLMREC_values[i][j][LAYER_cloudcover.id][k] = 0;
      else if (str.equals("Mainly Clear")) CLIMATE_CLMREC_values[i][j][LAYER_cloudcover.id][k] = 2.5;
      else if (str.equals("Mostly Cloudy")) CLIMATE_CLMREC_values[i][j][LAYER_cloudcover.id][k] = 5;
      else if (str.equals("Cloudy")) CLIMATE_CLMREC_values[i][j][LAYER_cloudcover.id][k] = 7.5;
      else CLIMATE_CLMREC_values[i][j][LAYER_cloudcover.id][k] = 10;

      //println(CLIMATE_CLMREC_values[i][j][LAYER_cloudcover.id][k]);

      str = parts[6];
      if (!str.equals("")) CLIMATE_CLMREC_values[i][j][LAYER_drybulb.id][k] = float(str); // °C

      str = parts[10];
      if (!str.equals("")) CLIMATE_CLMREC_values[i][j][LAYER_relhum.id][k] = float(str); // %

      str = parts[12];
      if (!str.equals("")) CLIMATE_CLMREC_values[i][j][LAYER_winddir.id][k] = float(str) * 10; // °

      str = parts[14];
      if (!str.equals("")) CLIMATE_CLMREC_values[i][j][LAYER_windspd.id][k] = float(str); // km/h

      str = parts[18];
      if (!str.equals("")) CLIMATE_CLMREC_values[i][j][LAYER_pressure.id][k] = float(str) * 10; // hPa


    }
  }

}
