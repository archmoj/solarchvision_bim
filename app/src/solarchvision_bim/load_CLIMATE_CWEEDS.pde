void load_climateEngineering (String FileName) {
  String[] FileALL = loadStrings(FileName);

  String lineSTR;
  String[] input;


  println("lines = ", FileALL.length);

  for (int f = 1; f < FileALL.length; f++) {

    lineSTR = FileALL[f];
    //println(lineSTR);

    int CLIMATE_YEAR = int(lineSTR.substring(8, 12));
    int CLIMATE_MONTH = int(lineSTR.substring(12, 14));
    int CLIMATE_DAY = int(lineSTR.substring(14, 16));
    int CLIMATE_HOUR = int(lineSTR.substring(16, 18));

    //println(CLIMATE_YEAR, CLIMATE_MONTH, CLIMATE_DAY, CLIMATE_HOUR);

    int i = int(CLIMATE_HOUR) - 1;
    int j = TIME.convert2Date(CLIMATE_MONTH, CLIMATE_DAY);
    int k = (CLIMATE_YEAR - climateEngineeringStart);

    //println(i);

    climateEngineering_values[i][j][LAYER_pressure.id][k] = float(lineSTR.substring(87, 92)); // 10 times in Pa
    climateEngineering_values[i][j][LAYER_drybulb.id][k] = float(lineSTR.substring(93, 97)); // 10 times in °C
    //climateEngineering_values[i][j][LAYER_relhum.id][k] = 50; // Relative Humidity is not presented in DCLIMATE files!
    climateEngineering_values[i][j][LAYER_glohorrad.id][k] = float(lineSTR.substring(22, 26)); // Wh/m²
    climateEngineering_values[i][j][LAYER_dirnorrad.id][k] = float(lineSTR.substring(28, 32)); // Wh/m²
    climateEngineering_values[i][j][LAYER_difhorrad.id][k] = float(lineSTR.substring(34, 38)); // Wh/m²
    climateEngineering_values[i][j][LAYER_windspd.id][k] = float(lineSTR.substring(107, 111)); // 10 times in m/s
    climateEngineering_values[i][j][LAYER_winddir.id][k] = float(lineSTR.substring(103, 106)); // °
    climateEngineering_values[i][j][LAYER_cloudcover.id][k] = float(lineSTR.substring(115, 117)); // 0.1 times in %
    climateEngineering_values[i][j][LAYER_ceilingsky.id][k] = float(lineSTR.substring(63, 67)); // 0.1 times in m

    if (climateEngineering_values[i][j][LAYER_pressure.id][k] == 99999) climateEngineering_values[i][j][LAYER_pressure.id][k] = FLOAT_undefined;
    else climateEngineering_values[i][j][LAYER_pressure.id][k] = 0.1 * climateEngineering_values[i][j][LAYER_pressure.id][k];

    if (climateEngineering_values[i][j][LAYER_drybulb.id][k] == 9999) climateEngineering_values[i][j][LAYER_drybulb.id][k] = FLOAT_undefined;
    else climateEngineering_values[i][j][LAYER_drybulb.id][k] = 0.1 * climateEngineering_values[i][j][LAYER_drybulb.id][k];

    if (climateEngineering_values[i][j][LAYER_glohorrad.id][k] == 9999) climateEngineering_values[i][j][LAYER_glohorrad.id][k] = FLOAT_undefined;
    else climateEngineering_values[i][j][LAYER_glohorrad.id][k] = climateEngineering_values[i][j][LAYER_glohorrad.id][k] / 3.6; // Wh/m²

    if (climateEngineering_values[i][j][LAYER_dirnorrad.id][k] == 9999) climateEngineering_values[i][j][LAYER_dirnorrad.id][k] = FLOAT_undefined;
    else climateEngineering_values[i][j][LAYER_dirnorrad.id][k] = climateEngineering_values[i][j][LAYER_dirnorrad.id][k] / 3.6; // Wh/m²

    if (climateEngineering_values[i][j][LAYER_difhorrad.id][k] == 9999) climateEngineering_values[i][j][LAYER_difhorrad.id][k] = FLOAT_undefined;
    else climateEngineering_values[i][j][LAYER_difhorrad.id][k] = climateEngineering_values[i][j][LAYER_difhorrad.id][k] / 3.6; // Wh/m²

    if (climateEngineering_values[i][j][LAYER_windspd.id][k] == 9999) climateEngineering_values[i][j][LAYER_windspd.id][k] = FLOAT_undefined;
    else climateEngineering_values[i][j][LAYER_windspd.id][k] = 0.1 * 3.6 * climateEngineering_values[i][j][LAYER_windspd.id][k];

    if (climateEngineering_values[i][j][LAYER_winddir.id][k] == 999) climateEngineering_values[i][j][LAYER_winddir.id][k] = FLOAT_undefined;

    if (climateEngineering_values[i][j][LAYER_cloudcover.id][k] == 99) climateEngineering_values[i][j][LAYER_cloudcover.id][k] = FLOAT_undefined;

    if (climateEngineering_values[i][j][LAYER_ceilingsky.id][k] == 7777) climateEngineering_values[i][j][LAYER_ceilingsky.id][k] = 1000;
    if (climateEngineering_values[i][j][LAYER_ceilingsky.id][k] >= 1000) climateEngineering_values[i][j][LAYER_ceilingsky.id][k] = 1000; // <<<<<<<<<

    if (climateEngineering_values[i][j][LAYER_ceilingsky.id][k] == 9999) climateEngineering_values[i][j][LAYER_ceilingsky.id][k] = FLOAT_undefined;
    else climateEngineering_values[i][j][LAYER_ceilingsky.id][k] = 10 * climateEngineering_values[i][j][LAYER_ceilingsky.id][k];
  }

  setDataFlags(dataID_climateEngineering);
  postProcess_solarEffects(dataID_climateEngineering);
  postProcess_developDATA(dataID_climateEngineering);

  WORLD.climateEngineeringDisplayAll = 1;
  WORLD.climateEngineeringDisplayNear = true;

}
