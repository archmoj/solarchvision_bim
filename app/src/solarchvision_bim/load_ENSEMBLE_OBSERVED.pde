void load_ENSEMBLE_OBSERVED (String FileName, int Load_Layer) {
  String lineSTR;
  String[] input;

  XML FileALL = loadXML(FileName);

  XML[] children0 = FileALL.getChildren("om:member");
  XML[] children1 = children0[0].getChildren("om:Observation");
  XML[] children2 = children1[0].getChildren("om:samplingTime");
  XML[] children3 = children2[0].getChildren("gml:TimeInstant");
  XML[] children4 = children3[0].getChildren("gml:timePosition");
  String _TimeInstant = String.valueOf(children4[0].getContent());
  //println(_TimeInstant);

  int THE_YEAR = int(_TimeInstant.substring(0, 4));
  int THE_MONTH = int(_TimeInstant.substring(5, 7));
  int THE_DAY = int(_TimeInstant.substring(8, 10));
  int THE_HOUR = int(_TimeInstant.substring(11, 13));

  //println(THE_YEAR, THE_MONTH, THE_DAY, THE_HOUR);

  int now_i = int(THE_HOUR);
  int now_j = TIME.convert2Date(THE_MONTH, THE_DAY);

  //println(now_i, now_j);

  now_i -= int(-STATION.getTimelong() / 15);

  if (now_i < 0) {
    now_i += 24;
    now_j -= 1;
    if (now_j < 0) {
      now_j += 365;
    }
  }

  //println(now_i, now_j);
  //println("-------------");

  children2 = children1[0].getChildren("om:result");
  children3 = children2[0].getChildren("elements");
  children4 = children3[0].getChildren("element");

  for (int Li = 0; Li < children4.length; Li++) {

    String _a1 = children4[Li].getString("name");
    String _a2 = children4[Li].getString("value");
    String _a3 = children4[Li].getString("uom");

    //println("Li=", Li, _a1, _a2, _a3);

    if (_a2.toUpperCase().equals("MSNG")) { // missing values
      _a2 = String.valueOf(FLOAT_undefined);
    }

    if (_a1.equals("stn_pres")) {
      ENSEMBLE_OBSERVED_values[now_i][now_j][LAYER_pressure.id][Load_Layer] = Float.valueOf(_a2);
    }

    if (_a1.equals("air_temp")) {
      ENSEMBLE_OBSERVED_values[now_i][now_j][LAYER_drybulb.id][Load_Layer] = Float.valueOf(_a2);
    }

    if (_a1.equals("rel_hum")) {
      ENSEMBLE_OBSERVED_values[now_i][now_j][LAYER_relhum.id][Load_Layer] = Float.valueOf(_a2);
    }

    if (_a1.equals("tot_cld_amt")) {
      ENSEMBLE_OBSERVED_values[now_i][now_j][LAYER_cloudcover.id][Load_Layer] = 0.1 * Float.valueOf(_a2);
    }

    if (_a1.equals("avg_wnd_dir_10m_mt50-60")) {
      ENSEMBLE_OBSERVED_values[now_i][now_j][LAYER_winddir.id][Load_Layer] = Float.valueOf(_a2);
    }

    if (_a1.equals("avg_wnd_spd_10m_mt50-60")) {
      ENSEMBLE_OBSERVED_values[now_i][now_j][LAYER_windspd.id][Load_Layer] = Float.valueOf(_a2);
    }

    if (_a1.equals("pcpn_amt_pst6hrs")) {
      ENSEMBLE_OBSERVED_values[now_i][now_j][LAYER_precipitation.id][Load_Layer] = Float.valueOf(_a2); // past 6 hours!
    }

    if (_a1.equals("avg_globl_solr_radn_pst1hr")) {
      if (_a2.equals(STRING_undefined)) {
      } else {
        //if (_a3.equals("W/m²")) {
        ENSEMBLE_OBSERVED_values[now_i][now_j][LAYER_glohorrad.id][Load_Layer] = 1000 * Float.valueOf(_a2) / 3.6; // we should check the units!
        //}
      }
    }

    if (_a1.equals("tot_globl_solr_radn_pst1hr")) {
      if (_a2.equals(STRING_undefined)) {
      } else {
        //if (_a3.equals("kJ/m²")) {
        ENSEMBLE_OBSERVED_values[now_i][now_j][LAYER_glohorrad.id][Load_Layer] = Float.valueOf(_a2) / 3.6; // we should check the units!
        //}
      }
    }

  }

}
