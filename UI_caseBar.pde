class solarchvision_UI_caseBar {

  private final static String CLASS_STAMP = "UI_caseBar";

  boolean update = true;

  float tab;

  String[][] Items = {

    {
      "Hours"
    }
    ,
    {
      "Days"
    }
    ,
    {
      "Scenario"
    }
  };



  void draw () {

    if (this.update) {

      this.updated();

      this.tab = SOLARCHVISION_pixel_C / float(this.Items.length);

      fill(191);
      noStroke();
      rect(0, SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 2 * SOLARCHVISION_pixel_H, width, SOLARCHVISION_pixel_C);



      float displayBarHeight = MessageSize;
      float displayBarWidth = 2 * SOLARCHVISION_pixel_W;

      X_control = 0.5 * displayBarWidth;
      Y_control = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 2 * SOLARCHVISION_pixel_H + 0.5 * this.tab;

      for (int i = 0; i < this.Items.length; i++) {

        float x1 = X_control - 0.3666 * displayBarWidth;
        float x2 = X_control + 0.4875 * displayBarWidth;
        float y1 = Y_control - 0.45 * displayBarHeight;
        float y2 = Y_control + 0.45 * displayBarHeight;

        fill(127);
        noStroke();
        rect(x1, y1, x2 - x1, y2 - y1);

        textAlign(RIGHT, CENTER);
        stroke(0);
        fill(0);
        textSize(1.25 * MessageSize);

        text(this.Items[i][0] + ": ", x1, Y_control - 0.125 * MessageSize);

        if (this.Items[i][0].equals("Hours")) {

          if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, x1, y1, x2, y2)) {

            if (mouseButton == LEFT) {
              STUDY.i_Start = int(funcs.roundTo(24.0 * (SOLARCHVISION_X_clicked - x1) / (x2 - x1) - 0.5, 1));

              ROLLOUT.revise();
              STUDY.revise();
              WORLD.revise();
              SOLARCHVISION_view_changed();

              SOLARCHVISION_find_which_bakings_to_regenerate();
            }

            if (mouseButton == RIGHT) {
              STUDY.i_End = int(funcs.roundTo(24.0 * (SOLARCHVISION_X_clicked - x1) / (x2 - x1) - 0.5, 1));

              ROLLOUT.revise();
              STUDY.revise();
              WORLD.revise();
              SOLARCHVISION_view_changed();

              SOLARCHVISION_find_which_bakings_to_regenerate();
            }
          }

          float x_start = x1 + (x2 - x1) * (STUDY.i_Start) / 24.0;
          float x_end = x1 + (x2 - x1) * (STUDY.i_End + 1) / 24.0;

          fill(0, 191, 0, 191);
          noStroke();

          if (STUDY.i_Start <= STUDY.i_End) {
            rect(x_start, y1, x_end - x_start, y2 - y1);
          } else {
            rect(x1, y1, x_end - x1, y2 - y1);
            rect(x_start, y1, x2 - x_start, y2 - y1);
          }

          textAlign(CENTER, CENTER);
          stroke(0);
          fill(0);
          textSize(MessageSize);

          for (int j = 0; j < 24; j++) {
            text(nf(j, 0), x1 + (x2 - x1) * (j + 0.5) / 24.0, Y_control);
          }
        }

        if (this.Items[i][0].equals("Days")) {

          if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, x1, y1, x2, y2)) {

            if (mouseButton == LEFT) {
              float keep_TIME_Date = TIME.date;
              TIME.date = (int(funcs.roundTo(365.0 * (SOLARCHVISION_X_clicked - x1) / (x2 - x1), 1)) + 286) % 365;
              TIME.updateDate();
              TIME.beginDay = int(TIME.beginDay + (TIME.date - keep_TIME_Date) + 365) % 365;
              update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);

              STUDY.revise();
              ROLLOUT.revise();
              SOLARCHVISION_view_changed();

              SOLARCHVISION_find_which_bakings_to_regenerate();
            }

            if (mouseButton == RIGHT) {

              float _DATE2 = (int(funcs.roundTo(365.0 * (SOLARCHVISION_X_clicked - x1) / (x2 - x1), 1)) + 286) % 365;

              if (TIME.date > _DATE2) _DATE2 += 365;

              STUDY.perDays = funcs.roundTo((_DATE2 - TIME.date) / float(STUDY.j_End - STUDY.j_Start), 0.5);

              if (STUDY.perDays < 1) STUDY.perDays = 1;

              STUDY.revise();
              ROLLOUT.revise();
              SOLARCHVISION_view_changed();

              SOLARCHVISION_find_which_bakings_to_regenerate();
            }
          }

          float keep_STUDY_perDays = STUDY.perDays;
          int keep_STUDY_joinDays = STUDY.joinDays;
          if ((CurrentDataSource == dataID_ENSEMBLE_FORECAST) ||
              (CurrentDataSource == dataID_ENSEMBLE_OBSERVED)) {

            STUDY.perDays = 1;
            STUDY.joinDays = 1;
          }

          for (int j = STUDY.j_Start; j < STUDY.j_End; j++) {
            float first_x_start = -1;
            float last_x_end = -1;
            for (int j_ADD = 0; j_ADD < STUDY.joinDays; j_ADD++) {

              int now_j = int(j * STUDY.perDays + (j_ADD - int(funcs.roundTo(0.5 * STUDY.joinDays, 1))) + TIME.beginDay + 365) % 365;

              if (now_j >= 365) {
                now_j = now_j % 365;
              }
              if (now_j < 0) {
                now_j = (now_j + 365) % 365;
              }

              float x_start = x1 + (x2 - x1) * ((now_j) % 365) / 365.0;
              float x_end = x1 + (x2 - x1) * ((now_j + 1) % 365) / 365.0;
              if(j_ADD == 0) {
                first_x_start = x_start;
              }
              if(j_ADD == STUDY.joinDays - 1) {
                last_x_end = x_end;
              }

              float q = 1.0 * (j - STUDY.j_Start) / (STUDY.j_End - STUDY.j_Start);
              fill(255 * (1 - q), 63, 255 * q, 127);
              noStroke();

              if (x_start <= x_end) {
                rect(x_start, y1, x_end - x_start, y2 - y1);
              } else {
                rect(x1, y1, x_end - x1, y2 - y1);
                rect(x_start, y1, x2 - x_start, y2 - y1);
              }
            }

            strokeWeight(2);
            stroke(255);
            noFill();
            if (first_x_start <= last_x_end) {
              rect(first_x_start, y1, last_x_end - first_x_start, y2 - y1);
            } else {
              rect(x1, y1, last_x_end - x1, y2 - y1);
              rect(first_x_start, y1, x2 - first_x_start, y2 - y1);
            }
            strokeWeight(0);
          }

          {
            textAlign(CENTER, CENTER);
            strokeWeight(1);
            stroke(0);
            fill(0);
            textSize(0.95 * MessageSize);

            for (int j = 0; j < 12; j++) {
              String txt = TIME.namesOfMonths[j][Language_Active];
              // add spaces between characters
              String txt2 = "";
              int len = txt.length();
              for (int k = 0; k < len; k++) {
                txt2 += txt.charAt(k);
                if(k < len - 1) {
                  txt2 += " ";
                }
              }

              text(txt2, x1 + (x2 - x1) * (j + 0.5) / 12.0, Y_control);
            }
            strokeWeight(0);
          }

          STUDY.perDays = keep_STUDY_perDays;
          STUDY.joinDays = keep_STUDY_joinDays;
        }


        if (this.Items[i][0].equals("Scenario")) {

          int n1 = 0;
          int n2 = 1;

          if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
            n1 = 1950;
            n2 = 2050;
          }
          if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
            n1 = 1950;
            n2 = 2050;
          }
          if (CurrentDataSource == dataID_CLIMATE_TMYEPW) {
            n1 = 1950;
            n2 = 2050;
          }
          if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
            n1 = ENSEMBLE_FORECAST_start;
            n2 = ENSEMBLE_FORECAST_end;
          }
          if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
            n1 = ENSEMBLE_OBSERVED_start;
            n2 = ENSEMBLE_OBSERVED_end;
          }

          if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, x1, y1, x2, y2)) {

            if (mouseButton == LEFT) {

              int V_selection = n1 + int(funcs.roundTo((n2 - n1 + 1) * (SOLARCHVISION_X_clicked - x1) / (x2 - x1) - 0.5, 1));

              if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
                SampleYear_Start = V_selection;

                if (SampleYear_Start > SampleYear_End) {
                  int swap_tmp = SampleYear_Start;
                  SampleYear_Start = SampleYear_End;
                  SampleYear_End = swap_tmp;
                }

              }

              if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
                SampleYear_Start = V_selection;

                if (SampleYear_Start > SampleYear_End) {
                  int swap_tmp = SampleYear_Start;
                  SampleYear_Start = SampleYear_End;
                  SampleYear_End = swap_tmp;
                }

              }

              if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
                SampleMember_Start = V_selection;

                if (SampleMember_Start > SampleMember_End) {
                  int swap_tmp = SampleMember_Start;
                  SampleMember_Start = SampleMember_End;
                  SampleMember_End = swap_tmp;
                }

              }

              if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
                SampleStation_Start = V_selection;

                if (SampleStation_Start > SampleStation_End) {
                  int swap_tmp = SampleStation_Start;
                  SampleStation_Start = SampleStation_End;
                  SampleStation_End = swap_tmp;
                }

              }

              ROLLOUT.revise();
              STUDY.revise();
              SOLARCHVISION_view_changed();

              SOLARCHVISION_find_which_bakings_to_regenerate();
            }

            if (mouseButton == RIGHT) {

              int V_selection = n1 + int(funcs.roundTo((n2 - n1 + 1) * (SOLARCHVISION_X_clicked - x1) / (x2 - x1) - 0.5, 1));

              if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
                SampleYear_End = V_selection;

                if (SampleYear_Start > SampleYear_End) {
                  int swap_tmp = SampleYear_Start;
                  SampleYear_Start = SampleYear_End;
                  SampleYear_End = swap_tmp;
                }

              }

              if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
                SampleYear_End = V_selection;

                if (SampleYear_Start > SampleYear_End) {
                  int swap_tmp = SampleYear_Start;
                  SampleYear_Start = SampleYear_End;
                  SampleYear_End = swap_tmp;
                }

              }

              if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
                SampleMember_End = V_selection;

                if (SampleMember_Start > SampleMember_End) {
                  int swap_tmp = SampleMember_Start;
                  SampleMember_Start = SampleMember_End;
                  SampleMember_End = swap_tmp;
                }

              }

              if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
                SampleStation_End = V_selection;

                if (SampleStation_Start > SampleStation_End) {
                  int swap_tmp = SampleStation_Start;
                  SampleStation_Start = SampleStation_End;
                  SampleStation_End = swap_tmp;
                }

              }

              ROLLOUT.revise();
              STUDY.revise();
              SOLARCHVISION_view_changed();

              SOLARCHVISION_find_which_bakings_to_regenerate();
            }
          }

          float V_start = 0;
          float V_end = 0;

          if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
            V_start = SampleYear_Start;
            V_end = SampleYear_End;
          }
          if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
            V_start = SampleYear_Start;
            V_end = SampleYear_End;
          }
          if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
            V_start = SampleMember_Start;
            V_end = SampleMember_End;
          }
          if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
            V_start = SampleStation_Start;
            V_end = SampleStation_End;
          }

          float x_start = x1 + (x2 - x1) * (V_start - n1) / float(n2 - n1 + 1);
          float x_end = x1 + (x2 - x1) * (V_end - n1 + 1) / float(n2 - n1 + 1);

          fill(191, 191, 0, 191);
          noStroke();

          if (x_start <= x_end) {
            rect(x_start, y1, x_end - x_start, y2 - y1);
          }

          textAlign(CENTER, CENTER);
          stroke(0);
          fill(0);
          textSize(MessageSize);

          for (int j = 0; j < n2 - n1 + 1; j++) {

            String txt = ".";

            if (j % 5 == 0) {
              txt = "|";
            }

            if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
              if ((j % 10 == 5)) {
                txt = nf(j - 5 + n1, 0) + "s";
              }
            }
            if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
              if ((j % 10 == 5)) {
                txt = nf(j - 5 + n1, 0) + "s";
              }
            }
            if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
              //if ((j % 1 == 0)) {
              txt = nf(j + n1, 0);
              //}
            }
            if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
              //if ((j % 1 == 0)) {
              txt = SWOB_Coordinates[nearest_Station_ENSEMBLE_OBSERVED_id[j]].getCode();
              //}
            }

            text(txt, x1 + (x2 - x1) * (j + 0.5) / float(n2 - n1 + 1), Y_control - 0.1 * MessageSize);
          }
        }




        Y_control += this.tab;
      }


      displayBarWidth = ROLLOUT.dX; // <<<<<<<<<
      displayBarHeight = 4.5 * MessageSize;

      float temp_offsetX = ROLLOUT.cX + 0.5 * displayBarWidth;
      float temp_offsetY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 2 * SOLARCHVISION_pixel_H + 0.5 * displayBarHeight;

      for (int n = 0; n < 9; n++) {

        int i = 2 - n / 3;
        int j = 2 - n % 3;

        float rx = (i + 0.5) / 3.0 - 0.5;
        float ry = (j + 0.5) / 3.0 - 0.5;

        float x1 = temp_offsetX + (rx - 0.16) * displayBarWidth;
        float x2 = temp_offsetX + (rx + 0.16) * displayBarWidth;
        float y1 = temp_offsetY + (ry - 0.15) * displayBarHeight;
        float y2 = temp_offsetY + (ry + 0.15) * displayBarHeight;

        if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, x1, y1, x2, y2)) {

          STUDY.ImpactLayer = n;

          STUDY.revise();
          ROLLOUT.revise();
          SOLARCHVISION_view_changed();

          SOLARCHVISION_find_which_bakings_to_regenerate();
        }
      }

      for (int n = 0; n < 9; n++) {

        int i = 2 - n / 3;
        int j = 2 - n % 3;

        float rx = (i + 0.5) / 3.0 - 0.5;
        float ry = (j + 0.5) / 3.0 - 0.5;

        float x1 = temp_offsetX + (rx - 0.16) * displayBarWidth;
        float x2 = temp_offsetX + (rx + 0.16) * displayBarWidth;
        float y1 = temp_offsetY + (ry - 0.15) * displayBarHeight;
        float y2 = temp_offsetY + (ry + 0.15) * displayBarHeight;

        if (n == STUDY.ImpactLayer) {
          fill(255, 127, 0);
          noStroke();
        } else if (n / 3 == STUDY.ImpactLayer / 3) {
          fill(127, 63, 0);
          noStroke();
        } else {
          fill(127);
          noStroke();
        }
        rect(x1, y1, x2 - x1, y2 - y1);

        textAlign(CENTER, CENTER);
        if (n == STUDY.ImpactLayer) {
          stroke(0);
          fill(0);
        } else if (n / 3 == STUDY.ImpactLayer / 3) {
          stroke(191);
          fill(191);
        } else {
          stroke(255);
          fill(255);
        }

        textSize(1.125 * MessageSize);

        text(STAT_N_Title[n], 0.5 * (x1 + x2), 0.5 * (y1 + y2) - 0.1125 * MessageSize);
      }

      SOLARCHVISION_X_clicked = -1;
      SOLARCHVISION_Y_clicked = -1;
    }
  }

  void revise () {
    this.update = true;
  }
  void updated () {
    this.update = false;
  }
}
