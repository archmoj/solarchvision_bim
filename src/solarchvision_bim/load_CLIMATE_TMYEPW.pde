void load_climateTypicalYear (String FileName) {
  String[] FileALL = loadStrings(FileName);

  String lineSTR;
  String[] input;


  for (int f = 8; f < FileALL.length; f++) {

    lineSTR = FileALL[f];

    String[] parts = split(lineSTR, ",");

    int CLIMATE_YEAR = int(parts[0]);
    int CLIMATE_MONTH = int(parts[1]);
    int CLIMATE_DAY = int(parts[2]);
    int CLIMATE_HOUR = int(parts[3]);

    int i = int(CLIMATE_HOUR) - 1;
    int j = TIME.convert2Date(CLIMATE_MONTH, CLIMATE_DAY);
    int k = 0; // on TMYEPW:TMY files we have only one year

    climateTypicalYearValues[i][j][LAYER_pressure.id][k] = float(parts[9]) * 0.01; // 10 times in Pa
    climateTypicalYearValues[i][j][LAYER_drybulb.id][k] = float(parts[6]); // in °C
    climateTypicalYearValues[i][j][LAYER_relhum.id][k] = float(parts[8]); // 0 - 110%
    climateTypicalYearValues[i][j][LAYER_glohorrad.id][k] = float(parts[13]); // Wh/m²
    climateTypicalYearValues[i][j][LAYER_dirnorrad.id][k] = float(parts[14]); // Wh/m²
    climateTypicalYearValues[i][j][LAYER_difhorrad.id][k] = float(parts[15]); // Wh/m²
    climateTypicalYearValues[i][j][LAYER_windspd.id][k] = float(parts[21]); // in m/s
    climateTypicalYearValues[i][j][LAYER_winddir.id][k] = float(parts[20]); // °
    climateTypicalYearValues[i][j][LAYER_cloudcover.id][k] = float(parts[23]); // 0.1 times in % ... there is also total_sky_cover on[22]
    climateTypicalYearValues[i][j][LAYER_ceilingsky.id][k] = float(parts[25]); // in m


    if (climateTypicalYearValues[i][j][LAYER_pressure.id][k] == 999999) climateTypicalYearValues[i][j][LAYER_pressure.id][k] = FLOAT_undefined;

    if (climateTypicalYearValues[i][j][LAYER_drybulb.id][k] == 99.9) climateTypicalYearValues[i][j][LAYER_drybulb.id][k] = FLOAT_undefined;

    if (climateTypicalYearValues[i][j][LAYER_relhum.id][k] == 999) climateTypicalYearValues[i][j][LAYER_relhum.id][k] = FLOAT_undefined;

    if (climateTypicalYearValues[i][j][LAYER_glohorrad.id][k] == 9999) climateTypicalYearValues[i][j][LAYER_glohorrad.id][k] = FLOAT_undefined;

    if (climateTypicalYearValues[i][j][LAYER_dirnorrad.id][k] >= 9999) climateTypicalYearValues[i][j][LAYER_dirnorrad.id][k] = FLOAT_undefined;
    if (climateTypicalYearValues[i][j][LAYER_dirnorrad.id][k] < 0) climateTypicalYearValues[i][j][LAYER_dirnorrad.id][k] = FLOAT_undefined;

    if (climateTypicalYearValues[i][j][LAYER_difhorrad.id][k] >= 9999) climateTypicalYearValues[i][j][LAYER_difhorrad.id][k] = FLOAT_undefined;
    if (climateTypicalYearValues[i][j][LAYER_difhorrad.id][k] < 0) climateTypicalYearValues[i][j][LAYER_difhorrad.id][k] = FLOAT_undefined;

    if (climateTypicalYearValues[i][j][LAYER_windspd.id][k] == 999) climateTypicalYearValues[i][j][LAYER_windspd.id][k] = FLOAT_undefined;
    else climateTypicalYearValues[i][j][LAYER_windspd.id][k] = 3.6 * climateTypicalYearValues[i][j][LAYER_windspd.id][k];

    if (climateTypicalYearValues[i][j][LAYER_winddir.id][k] == 999) climateTypicalYearValues[i][j][LAYER_winddir.id][k] = FLOAT_undefined;

    if (climateTypicalYearValues[i][j][LAYER_cloudcover.id][k] == 99) climateTypicalYearValues[i][j][LAYER_cloudcover.id][k] = FLOAT_undefined;

    if (climateTypicalYearValues[i][j][LAYER_ceilingsky.id][k] == 77777) climateTypicalYearValues[i][j][LAYER_ceilingsky.id][k] = 1000;
    if (climateTypicalYearValues[i][j][LAYER_ceilingsky.id][k] == 88888) climateTypicalYearValues[i][j][LAYER_ceilingsky.id][k] = 1000;
    if (climateTypicalYearValues[i][j][LAYER_ceilingsky.id][k] >= 1000) climateTypicalYearValues[i][j][LAYER_ceilingsky.id][k] = 1000;

    if (climateTypicalYearValues[i][j][LAYER_ceilingsky.id][k] == 99999) climateTypicalYearValues[i][j][LAYER_ceilingsky.id][k] = FLOAT_undefined;
  }

  setDataFlags(dataID_climateTypicalYear);
  postProcess_solarEffects(dataID_climateTypicalYear);
  postProcess_developDATA(dataID_climateTypicalYear);

  WORLD.revise();
  STUDY.revise();
  UI_rollout.revise();
  UI_caseBar.revise();
  view_changed();

}
