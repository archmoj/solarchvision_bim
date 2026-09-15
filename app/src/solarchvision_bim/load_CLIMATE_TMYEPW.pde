void load_CLIMATE_TMYEPW (String FileName) {
  String[] FileALL = loadStrings(FileName);

  String lineSTR;
  String[] input;


  //println("lines = ", FileALL.length);

  for (int f = 8; f < FileALL.length; f++) {

    lineSTR = FileALL[f];

    String[] parts = split(lineSTR, ",");

    int CLIMATE_YEAR = int(parts[0]);
    int CLIMATE_MONTH = int(parts[1]);
    int CLIMATE_DAY = int(parts[2]);
    int CLIMATE_HOUR = int(parts[3]);

    //println(CLIMATE_YEAR, CLIMATE_MONTH, CLIMATE_DAY, CLIMATE_HOUR);

    int i = int(CLIMATE_HOUR) - 1;
    int j = TIME.convert2Date(CLIMATE_MONTH, CLIMATE_DAY);
    int k = 0; // on TMYEPW:TMY files we have only one year

    //println(i);

    CLIMATE_TMYEPW_values[i][j][LAYER_pressure.id][k] = float(parts[9]) * 0.01; // 10 times in Pa
    CLIMATE_TMYEPW_values[i][j][LAYER_drybulb.id][k] = float(parts[6]); // in °C
    CLIMATE_TMYEPW_values[i][j][LAYER_relhum.id][k] = float(parts[8]); // 0 - 110%
    CLIMATE_TMYEPW_values[i][j][LAYER_glohorrad.id][k] = float(parts[13]); // Wh/m²
    CLIMATE_TMYEPW_values[i][j][LAYER_dirnorrad.id][k] = float(parts[14]); // Wh/m²
    CLIMATE_TMYEPW_values[i][j][LAYER_difhorrad.id][k] = float(parts[15]); // Wh/m²
    CLIMATE_TMYEPW_values[i][j][LAYER_windspd.id][k] = float(parts[21]); // in m/s
    CLIMATE_TMYEPW_values[i][j][LAYER_winddir.id][k] = float(parts[20]); // °
    CLIMATE_TMYEPW_values[i][j][LAYER_cloudcover.id][k] = float(parts[23]); // 0.1 times in % ... there is also total_sky_cover on[22]
    CLIMATE_TMYEPW_values[i][j][LAYER_ceilingsky.id][k] = float(parts[25]); // in m


    if (CLIMATE_TMYEPW_values[i][j][LAYER_pressure.id][k] == 999999) CLIMATE_TMYEPW_values[i][j][LAYER_pressure.id][k] = FLOAT_undefined;

    if (CLIMATE_TMYEPW_values[i][j][LAYER_drybulb.id][k] == 99.9) CLIMATE_TMYEPW_values[i][j][LAYER_drybulb.id][k] = FLOAT_undefined;

    if (CLIMATE_TMYEPW_values[i][j][LAYER_relhum.id][k] == 999) CLIMATE_TMYEPW_values[i][j][LAYER_relhum.id][k] = FLOAT_undefined;

    if (CLIMATE_TMYEPW_values[i][j][LAYER_glohorrad.id][k] == 9999) CLIMATE_TMYEPW_values[i][j][LAYER_glohorrad.id][k] = FLOAT_undefined;

    if (CLIMATE_TMYEPW_values[i][j][LAYER_dirnorrad.id][k] >= 9999) CLIMATE_TMYEPW_values[i][j][LAYER_dirnorrad.id][k] = FLOAT_undefined;
    if (CLIMATE_TMYEPW_values[i][j][LAYER_dirnorrad.id][k] < 0) CLIMATE_TMYEPW_values[i][j][LAYER_dirnorrad.id][k] = FLOAT_undefined;

    if (CLIMATE_TMYEPW_values[i][j][LAYER_difhorrad.id][k] >= 9999) CLIMATE_TMYEPW_values[i][j][LAYER_difhorrad.id][k] = FLOAT_undefined;
    if (CLIMATE_TMYEPW_values[i][j][LAYER_difhorrad.id][k] < 0) CLIMATE_TMYEPW_values[i][j][LAYER_difhorrad.id][k] = FLOAT_undefined;

    if (CLIMATE_TMYEPW_values[i][j][LAYER_windspd.id][k] == 999) CLIMATE_TMYEPW_values[i][j][LAYER_windspd.id][k] = FLOAT_undefined;
    else CLIMATE_TMYEPW_values[i][j][LAYER_windspd.id][k] = 3.6 * CLIMATE_TMYEPW_values[i][j][LAYER_windspd.id][k];

    if (CLIMATE_TMYEPW_values[i][j][LAYER_winddir.id][k] == 999) CLIMATE_TMYEPW_values[i][j][LAYER_winddir.id][k] = FLOAT_undefined;

    if (CLIMATE_TMYEPW_values[i][j][LAYER_cloudcover.id][k] == 99) CLIMATE_TMYEPW_values[i][j][LAYER_cloudcover.id][k] = FLOAT_undefined;

    if (CLIMATE_TMYEPW_values[i][j][LAYER_ceilingsky.id][k] == 77777) CLIMATE_TMYEPW_values[i][j][LAYER_ceilingsky.id][k] = 1000;
    if (CLIMATE_TMYEPW_values[i][j][LAYER_ceilingsky.id][k] == 88888) CLIMATE_TMYEPW_values[i][j][LAYER_ceilingsky.id][k] = 1000;
    if (CLIMATE_TMYEPW_values[i][j][LAYER_ceilingsky.id][k] >= 1000) CLIMATE_TMYEPW_values[i][j][LAYER_ceilingsky.id][k] = 1000;

    if (CLIMATE_TMYEPW_values[i][j][LAYER_ceilingsky.id][k] == 99999) CLIMATE_TMYEPW_values[i][j][LAYER_ceilingsky.id][k] = FLOAT_undefined;
  }

  SOLARCHVISION_setDataFlags(dataID_CLIMATE_TMYEPW);
  SOLARCHVISION_postProcess_solarEffects(dataID_CLIMATE_TMYEPW);
  SOLARCHVISION_postProcess_developDATA(dataID_CLIMATE_TMYEPW);

  WORLD.revise();
  STUDY.revise();
  ROLLOUT.revise();
  UI_caseBar.revise();
  SOLARCHVISION_view_changed();

}
