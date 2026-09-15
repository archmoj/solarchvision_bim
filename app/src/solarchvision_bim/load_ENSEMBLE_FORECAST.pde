void load_ENSEMBLE_FORECAST (String FileName, int Load_Layer) {
  String lineSTR;
  String[] input;

  boolean continue_process = true;

  XML FileALL = parseXML("<?xml version='1.0' encoding='UTF-8'?>" + char(13) + "<empty>" + char(13) + "</empty>");

  try {
    FileALL = loadXML(FileName);
  }
  catch (Exception e) {
    println("Can't read:", FileName);
    continue_process = false;
  }

  if (continue_process) {

    //println(TIME.year, TIME.month, TIME.day, TIME.hour);

    XML[] children0 = FileALL.getChildren("forecast");

    for (int Li = 0; Li < children0.length; Li++) {

      int _a1 = children0[Li].getInt("forecast_hour");
      String _a2 = children0[Li].getString("valid_time");

      //println("Li=", Li, "hour =", _a1, "date:", _a2);

      if (Li >= 0) {

        int THE_YEAR = int(_a2.substring(0, 4));
        int THE_MONTH = int(_a2.substring(4, 6));
        int THE_DAY = int(_a2.substring(6, 8));
        int THE_HOUR = int(_a2.substring(8));

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

        XML[] _c = children0[Li].getChildren("model");
        //println("number of members:", _c.length);

        for (int Lk = 0; Lk < _c.length; Lk++) {
          int k = _c[Lk].getInt("id") - 1;

          if (k < (1 + ENSEMBLE_FORECAST_end - ENSEMBLE_FORECAST_start)) {

            ENSEMBLE_FORECAST_values[now_i][now_j][Load_Layer][k] = Float.valueOf(_c[Lk].getContent());
          }
        }
      }
    }
  }
}
