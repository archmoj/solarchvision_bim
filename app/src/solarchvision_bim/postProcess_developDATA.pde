void postProcess_developDATA (int desired_DataSource) {

  int keep_currentDataSource = currentDataSource;

  currentDataSource = desired_DataSource;

  float keep_STUDY_dailyStep = STUDY.dailyStep;
  int keep_STUDY_daysMergedCount = STUDY.daysMergedCount;

  if ((currentDataSource == dataID_ensembleForecast) ||
      (currentDataSource == dataID_ensembleObservation)) {

    STUDY.dailyStep = 1;
    STUDY.daysMergedCount = 1;
  }

  int DATA_start = getStart_currentDataSource();
  int DATA_end = getEnd_currentDataSource();

  int count_k = 1 + DATA_end - DATA_start;
  if (count_k > 0) {

    float Pa = FLOAT_undefined;
    float Pb = FLOAT_undefined;
    float RAIN, T, WS, R_dir, R_dif;

    float[] valuesSUM;
    valuesSUM = new float [count_k];

    java.util.Arrays.fill(valuesSUM, FLOAT_undefined);

    for (int j = STUDY.startDay; j <= STUDY.endDay; j++) {
      for (int j_ADD = 0; j_ADD < STUDY.daysMergedCount; j_ADD++) {
        for (int k = 0; k < count_k; k++) {
          for (int i = 0; i < 24; i++) {

            int now_k = k;
            int now_i = i;
            int now_j = int(j * STUDY.dailyStep + (j_ADD - int(funcs.roundTo(0.5 * STUDY.daysMergedCount, 1))) + TIME.beginDay + 365) % 365;

            if (now_j >= 365) {
              now_j = now_j % 365;
            }
            if (now_j < 0) {
              now_j = (now_j + 365) % 365;
            }

            int next_i = now_i + 12;
            int next_j = now_j;
            int next_k = now_k;
            if (next_i >= 24) {
              next_i = next_i - 24;
              next_j += 1;
              if (next_j >= 365) {
                next_j = next_j % 365;
              }
            }


            int pre_i = now_i - 12;
            int pre_j = now_j;
            int pre_k = now_k;
            if (pre_i < 0) {
              pre_i = pre_i + 24;
              pre_j -= 1;
              if (pre_j < 0) {
                pre_j = (pre_j + 365) % 365;
              }
            }


            setValue_currentDataSource(now_i, now_j, now_k, LAYER_developed.id, FLOAT_undefined);

            T = FLOAT_undefined;
            R_dir = FLOAT_undefined;
            R_dif = FLOAT_undefined;

            if ((i == 0) && (j == STUDY.startDay)) valuesSUM[now_k] = 0;



            Pa = getValue_currentDataSource(now_i, now_j, now_k, LAYER_dirnorrad.id);

            if (is_undefined(Pa)) {
              R_dir = FLOAT_undefined;
            } else {
              R_dir = Pa;
            }

            Pa = getValue_currentDataSource(now_i, now_j, now_k, LAYER_difhorrad.id);

            if (is_undefined(Pa)) {
              R_dif = FLOAT_undefined;
            } else {
              R_dif = Pa;
            }

            Pa = getValue_currentDataSource(now_i, now_j, now_k, LAYER_drybulb.id);

            if (is_undefined(Pa)) {
              T = FLOAT_undefined;
            } else {
              T = Pa;
            }

            Pa = getValue_currentDataSource(now_i, now_j, now_k, LAYER_windspd.id);

            if (is_undefined(Pa)) {
              WS = FLOAT_undefined;
            } else {
              WS = Pa;
            }

            Pa = getValue_currentDataSource(now_i, now_j, now_k, LAYER_precipitation.id);
            Pb = getValue_currentDataSource(next_i, next_j, now_k, LAYER_precipitation.id);

            if (is_undefined(Pa) || is_undefined(Pb)) {
              RAIN = FLOAT_undefined;
            } else {
              RAIN = Pb - Pa;
              //RAIN = Pa - Pb;

              if (T <= 0) RAIN *= -1;  // <<<<<<<<<<<<<<<<<<<< Lewis
              //if ((T < 5) && (T > -5)) RAIN *= -1;  // <<<<<<<<<<<<<<<<<<<< Mojtaba
            }


            float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);
            float HOUR_ANGLE = now_i;

            float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);

            if (developLayerOption == DEV_WindPower) {

              if (is_defined(WS)) {

                valuesSUM[now_k] = 0.5 * 1.23 * 1 * pow(WS / 3.6, 3);

                setValue_currentDataSource(now_i, now_j, now_k, LAYER_developed.id, valuesSUM[now_k]);
              }

              LAYER_developed.verticalUnitScale = 0.05;
              LAYER_developed.verticalUnitOffset = 0;
              LAYER_developed.verticalNegativePadding = 0;
              LAYER_developed.unit = "W/m²";
              LAYER_developed.descriptions[Language_EN] = "Wind power";
              LAYER_developed.descriptions[Language_FR] = "?"; // ??
            }

            if (developLayerOption == DEV_RadiationOnTracker) {
              float Alpha = funcs.asin_ang(SunR[3]);
              float Beta = funcs.atan2_ang(SunR[2], SunR[1]) + 90;

              if (is_defined(R_dir) && is_defined(R_dif)) {

                valuesSUM[now_k] = SolarAtSurface(SunR[1], SunR[2], SunR[3], R_dir, R_dif, Alpha, Beta, globalAlbedo);

                setValue_currentDataSource(now_i, now_j, now_k, LAYER_developed.id, valuesSUM[now_k]);
              }

              LAYER_developed.verticalUnitScale = 0.1;
              LAYER_developed.verticalUnitOffset = 0;
              LAYER_developed.verticalNegativePadding = 0;
              LAYER_developed.unit = "W/m²";
              LAYER_developed.descriptions[Language_EN] = "Radiation on solar tracker";
              LAYER_developed.descriptions[Language_FR] = "?"; // ??
            }


            if (
              (developLayerOption == DEV_RadiationOnSouth) ||
              (developLayerOption == DEV_RadiationOnEast) ||
              (developLayerOption == DEV_RadiationOnWest) ||
              (developLayerOption == DEV_RadiationOnNorth) ||
              (developLayerOption == DEV_RadiationOnSE) ||
              (developLayerOption == DEV_RadiationOnNE) ||
              (developLayerOption == DEV_RadiationOnNW) ||
              (developLayerOption == DEV_RadiationOnSW) ||
              (developLayerOption == DEV_RadiationOnSurface)
            ) {
              float Alpha = 0;
              float Beta = 0;
              if (developLayerOption == DEV_RadiationOnSurface) {
                Alpha = developLayerAngleInclination;
                Beta = developLayerAngleOrientation;
              } else if (developLayerOption == DEV_RadiationOnSouth) {
                Alpha = 0;
                Beta = 0;
              } else if (developLayerOption == DEV_RadiationOnEast) {
                Alpha = 0;
                Beta = 90;
              } else if (developLayerOption == DEV_RadiationOnNorth) {
                Alpha = 0;
                Beta = 180;
              } else if (developLayerOption == DEV_RadiationOnWest) {
                Alpha = 0;
                Beta = -90;
              } else if (developLayerOption == DEV_RadiationOnSE) {
                Alpha = 0;
                Beta = 45;
              } else if (developLayerOption == DEV_RadiationOnNE) {
                Alpha = 0;
                Beta = 135;
              } else if (developLayerOption == DEV_RadiationOnNW) {
                Alpha = 0;
                Beta = -135;
              } else if (developLayerOption == DEV_RadiationOnSW) {
                Alpha = 0;
                Beta = -45;
              }

              if (is_defined(R_dir) && is_defined(R_dif)) {

                valuesSUM[now_k] = SolarAtSurface(SunR[1], SunR[2], SunR[3], R_dir, R_dif, Alpha, Beta, globalAlbedo);

                setValue_currentDataSource(now_i, now_j, now_k, LAYER_developed.id, valuesSUM[now_k]);
              }

              LAYER_developed.verticalUnitScale = 0.1;
              LAYER_developed.verticalUnitOffset = 0;
              LAYER_developed.verticalNegativePadding = 0;
              LAYER_developed.unit = "W/m²";

              if (developLayerOption == DEV_RadiationOnSurface) {
                LAYER_developed.descriptions[Language_EN] = "Radiation on inclination_" + String.valueOf(Alpha) + "_South-Deviation_" + String.valueOf(Beta);
                LAYER_developed.descriptions[Language_FR] = "?"; // ??
              } else if (developLayerOption == DEV_RadiationOnSouth) {
                LAYER_developed.descriptions[Language_EN] = "Radiation on South surface";
                LAYER_developed.descriptions[Language_FR] = "?"; // ??
              } else if (developLayerOption == DEV_RadiationOnEast) {
                LAYER_developed.descriptions[Language_EN] = "Radiation on East surface";
                LAYER_developed.descriptions[Language_FR] = "?"; // ??
              } else if (developLayerOption == DEV_RadiationOnNorth) {
                LAYER_developed.descriptions[Language_EN] = "Radiation on North surface";
                LAYER_developed.descriptions[Language_FR] = "?"; // ??
              } else if (developLayerOption == DEV_RadiationOnWest) {
                LAYER_developed.descriptions[Language_EN] = "Radiation on West surface";
                LAYER_developed.descriptions[Language_FR] = "?"; // ??
              } else if (developLayerOption == DEV_RadiationOnSE) {
                LAYER_developed.descriptions[Language_EN] = "Radiation on S.E. surface";
                LAYER_developed.descriptions[Language_FR] = "?"; // ??
              } else if (developLayerOption == DEV_RadiationOnNE) {
                LAYER_developed.descriptions[Language_EN] = "Radiation on N.E. surface";
                LAYER_developed.descriptions[Language_FR] = "?"; // ??
              } else if (developLayerOption == DEV_RadiationOnNW) {
                LAYER_developed.descriptions[Language_EN] = "Radiation on N.W. surface";
                LAYER_developed.descriptions[Language_FR] = "?"; // ??
              } else if (developLayerOption == DEV_RadiationOnSW) {
                LAYER_developed.descriptions[Language_EN] = "Radiation on S.W. surface";
                LAYER_developed.descriptions[Language_FR] = "?"; // ??
              }
            }

          }
        }
      }
    }
  }

  // println("developDATA updated!");

  developDataUpdate = false;

  STUDY.dailyStep = keep_STUDY_dailyStep;
  STUDY.daysMergedCount = keep_STUDY_daysMergedCount;

  currentDataSource = keep_currentDataSource;
}
