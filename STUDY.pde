class solarchvision_STUDY {

  private final static String CLASS_STAMP = "STUDY";

  int SORT_pallet_CLR = -1;
  int SORT_pallet_DIR = -1;
  float SORT_pallet_MLT = 2;

  int PROB_pallet_CLR = -1;
  int PROB_pallet_DIR = 1;
  float PROB_pallet_MLT = 0.5;

  int ACTIVE_pallet_CLR = 19; //15; //14;
  int ACTIVE_pallet_DIR = 1;
  float ACTIVE_pallet_MLT = 1; //2;

  int PASSIVE_pallet_CLR = 1;
  int PASSIVE_pallet_DIR = 1;
  float PASSIVE_pallet_MLT = 0.2;


  int cX = 0;
  int cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + SOLARCHVISION_pixel_H;
  int dX = 2 * SOLARCHVISION_pixel_W;
  int dY = 1 * SOLARCHVISION_pixel_H;
  float view_R = float(dY) / float(dX);
  float view_S;

  boolean update = true;
  boolean include = true;

  boolean record_IMG = false;
  boolean record_PDF = false;
  boolean record_AUTO = false;


  int i_Start = 0;
  int i_End = 23;

  int j_Start = 0; // constant
  int j_End = 12; //8; //6; //2; //16; // Variable

  float perDays = 30.5; //1; //45; //61; //30.5;
  int joinDays = 30; //1; //30;//perDays; // it should be set up to 1 in order to plot only one day

  boolean PrintTtitle = true;

  float T_scale = 0.5;
  float U_scale = 18.0 / float(j_End - j_Start);

  float V_scale;
  float V_offset;
  float V_belowLine;

  int skyScenario = 1; // 1: all scenarios, 2: Total Cloud Cover < 0.33, 3: middle range, 4: Total Cloud Cover > 0.66
  int filter = filter_DAILY;

  int TrendJoinHours = 24; //48;
  int TrendJoinType = -1; // -1: increasing weights, +1: equal weights

  boolean export_info_node = false;
  boolean export_info_norm = false;
  boolean export_info_prob = false;

  float position_X = 0;
  float position_Y = 0;

  float O_scale = 50.0;
  float W_scale = 3.0;

  float rect_scale = 0.005;
  float rect_offset_x = 0.5;

  boolean impact_summary = false;

  int ImpactLayer = 4; // 4 = Median

  int PlotImpacts = PlotImpacts_GLOBAL_PASSIVE;

  boolean Impacts_update = true;

  boolean displayRaws = false;
  boolean displaySorted = true;
  boolean displayNormals = true;
  boolean displayProbs = false;

  int sumInterval = 4;
  float LevelPix = 8;

  color color_data_raws = color(0, 0, 0);

  int plotSetup = 0;

  float ImageScale = 1.0;

  int Impact_TYPE = 1;

  PGraphics graphics;

  boolean isInHourlyRange (float i) {
    boolean result = true;
    if (this.i_Start <= this.i_End) {
      result = false;
      if ((this.i_Start <= i) && (i <= (this.i_End + 24) % 24)) result = true;
    } else {
      result = true;
      if ((this.i_Start > i) && (i > (this.i_End + 24) % 24)) result = false;
    }
    return result;
  }


  void keyPressed (KeyEvent e) {

    if (e.isAltDown()) {
    } else if (e.isControlDown()) {
      if (key == CODED) {
        switch(keyCode) {
          case UP :
          changeCurrentLayerTo((CurrentLayer_id + 1) % numberOfLayers);
          this.revise();
          ROLLOUT.revise();
          break;

          case DOWN :
          changeCurrentLayerTo((CurrentLayer_id + numberOfLayers - 1) % numberOfLayers);
          this.revise();
          ROLLOUT.revise();
          break;

          case RIGHT :
          this.PlotImpacts = (this.PlotImpacts + 1) % 11;
          this.revise();
          ROLLOUT.revise();
          break;

          case LEFT :
          this.PlotImpacts = (this.PlotImpacts - 1 + 11) % 11;
          this.revise();
          ROLLOUT.revise();
          break;

          case 16: // PAGE_UP
          if(!e.isShiftDown()) {
            STUDY.plotSetup = -2 + (2 + STUDY.plotSetup + 1) % 10;
            this.revise();
            ROLLOUT.revise();
          }
          break;

          case 11: // PAGE_DOWN
          if(!e.isShiftDown()) {
            STUDY.plotSetup = -2 + (2 + STUDY.plotSetup - 1 + 10) % 10;
            this.revise();
            ROLLOUT.revise();
          }
          break;
        }
      } else {
        switch(key) {
        case ';':
          this.impact_summary = !(this.impact_summary);
          this.revise();
          ROLLOUT.revise();
          break;

        case '"' :
          this.V_scale *= pow(2.0, (1.0 / 2.0));
          this.revise();
          ROLLOUT.revise();
          break;
        case '\'' :
          this.V_scale *= pow(0.5, (1.0 / 2.0));
          this.revise();
          ROLLOUT.revise();
          break;
        }
      }
    }

    if ((e.isAltDown() != true) && (e.isControlDown() != true)) {

      if (key != CODED) {
        switch(key) {

        case '>' :
          this.joinDays += 2;
          if (this.joinDays > 365) this.joinDays = 365;
          DevelopData_update = true;
          UI_caseBar.revise();
          this.revise();
          WIN3D.revise();
          ROLLOUT.revise();
          break;
        case '<' :
          this.joinDays -= 2;
          if (this.joinDays < 1) this.joinDays = 1;
          DevelopData_update = true;
          UI_caseBar.revise();
          this.revise();
          WIN3D.revise();
          ROLLOUT.revise();
          break;

        case ')' :
          this.j_End += 1;
          if (this.j_End > this.j_Start + 61) this.j_End -= 1;
          this.U_scale = 18.0 / float(this.j_End - this.j_Start);
          /*
           if ((CurrentDataSource == dataID_CLIMATE_CWEEDS) || CurrentDataSource == dataID_CLIMATE_CLMREC) || (CurrentDataSource == dataID_CLIMATE_TMYEPW)) {
           this.perDays = int(365 / float(this.j_End - this.j_Start));
           }
           if ((CurrentDataSource == dataID_ENSEMBLE_FORECAST) || (CurrentDataSource == dataID_ENSEMBLE_OBSERVED)) {
           this.perDays = 1;
           }
           */
          DevelopData_update = true;

          VertexSolar_rebuild_array = true;
          GlobalSolar_rebuild_array = true;
          allSolarImpacts.rebuild_Image_array = true;
          allWindRoses.rebuild_Image_array = true;
          allSections.resize_solarImpact_array();

          UI_caseBar.revise();
          this.revise();
          ROLLOUT.revise();
          break;

        case '(' :
          this.j_End -= 1;
          if (this.j_End <= this.j_Start) this.j_End += 1;
          this.U_scale = 18.0 / float(this.j_End - this.j_Start);
          /*
           if ((CurrentDataSource == dataID_CLIMATE_CWEEDS) || CurrentDataSource == dataID_CLIMATE_CLMREC) || (CurrentDataSource == dataID_CLIMATE_TMYEPW)) {
           this.perDays = int(365 / float(this.j_End - this.j_Start));
           }
           if ((CurrentDataSource == dataID_ENSEMBLE_FORECAST) || (CurrentDataSource == dataID_ENSEMBLE_OBSERVED)) {
           this.perDays = 1;
           }
           */
          DevelopData_update = true;

          VertexSolar_rebuild_array = true;
          GlobalSolar_rebuild_array = true;
          allSolarImpacts.rebuild_Image_array = true;
          allWindRoses.rebuild_Image_array = true;
          allSections.resize_solarImpact_array();

          UI_caseBar.revise();
          this.revise();
          ROLLOUT.revise();
          break;

        case 'S' :
          this.skyScenario = 1 + (-1 + this.skyScenario + 1) % 4;
          DevelopData_update = true;
          this.revise();
          WIN3D.revise();
          ROLLOUT.revise();
          break;
        case 's' :
          this.skyScenario = 1 + (-1 + this.skyScenario - 1 + 4) % 4;
          DevelopData_update = true;
          this.revise();
          WIN3D.revise();
          ROLLOUT.revise();
          break;

        case 'V' :
          this.displayRaws = !this.displayRaws;
          this.revise();
          ROLLOUT.revise();
          break;
        case 'v' :
          this.displayRaws = !this.displayRaws;
          this.revise();
          ROLLOUT.revise();
          break;

        case 'm' :
          this.displaySorted = !this.displaySorted;
          this.revise();
          ROLLOUT.revise();
          break;
        case 'M' :
          this.displaySorted = !this.displaySorted;
          this.revise();
          ROLLOUT.revise();
          break;

        case 'n' :
          this.displayNormals = !this.displayNormals;
          this.revise();
          ROLLOUT.revise();
          break;
        case 'N' :
          this.displayNormals = !this.displayNormals;
          this.revise();
          ROLLOUT.revise();
          break;

        case 'b' :
          this.displayProbs = !this.displayProbs;
          this.revise();
          ROLLOUT.revise();
          break;
        case 'B' :
          this.displayProbs = !this.displayProbs;
          this.revise();
          ROLLOUT.revise();
          break;

        case '{' :
          if (this.LevelPix < 32) this.LevelPix *= pow(2.0, (1.0 / 1.0));
          this.revise();
          ROLLOUT.revise();
          break;
        case '}' :
          if (this.LevelPix > 2) this.LevelPix *= pow(0.5, (1.0 / 1.0));
          this.revise();
          ROLLOUT.revise();
          break;

        case '[' :
          if (this.sumInterval > 24) this.sumInterval -= 24;
          if (this.sumInterval > 6) this.sumInterval -= 6;
          else if (this.sumInterval > 1) this.sumInterval -= 1;
          if (this.sumInterval == 5) this.sumInterval = 4;
          this.revise();
          ROLLOUT.revise();
          break;
        case ']' :
          if (this.sumInterval < 6) this.sumInterval += 1;
          else if (this.sumInterval < 24) this.sumInterval += 6;
          else this.sumInterval += 24;
          if (this.sumInterval == 5) this.sumInterval = 6;
          this.revise();
          ROLLOUT.revise();
          break;

        }
      }
    }
  }



  void drawTimeGrid (float x_Plot, float y_Plot, float sx_Plot, float sy_Plot) {
    this.graphics.strokeWeight(this.T_scale * 1);

    float Shift_DOWN = 0;
    if (this.V_belowLine != 0) Shift_DOWN = -75;

    for (int i = 100; i >= Shift_DOWN; i -= 25) {
      if (-this.V_offset + funcs.roundTo(i / this.V_scale, 0.1) != 0) {
        this.graphics.stroke(0, 63);
        this.graphics.fill(0, 63);
      } else {
        this.graphics.stroke(0);
        this.graphics.fill(0);
      }

      float y = -i * this.view_S;

      this.graphics.line(this.j_Start * sx_Plot, y, this.j_End * sx_Plot, y);

      if ((i >= 0) || (this.V_belowLine != 0)) {
        this.graphics.stroke(0);
        this.graphics.fill(0);
        this.graphics.textSize(sx_Plot * 0.150 / this.U_scale);
        this.graphics.textAlign(RIGHT, CENTER);
        this.graphics.text(((nf(-this.V_offset + funcs.roundTo(i / this.V_scale, 0.1), 0, 1)) + CurrentLayer_unit), -5, y);
        //this.graphics.text(((String.valueOf(int(-this.V_offset + funcs.roundTo(i / this.V_scale, 0.1)))) + CurrentLayer_unit), -5, y);
      }
    }

    this.graphics.stroke(0, 63);
    this.graphics.fill(0, 63);
    for (int i = this.j_Start; i <= this.j_End; i++) {
      if (i < this.j_End) {
        int j_step = 3;
        for (int j = j_step; j <= 24; j += j_step) {

          float x = (i + j / 24.0) * sx_Plot;

          if (j != 24) {
            this.graphics.line(x, -5 * this.view_S, x, 5 * this.view_S);
          } else {
            this.graphics.line(x, -105 * this.view_S, x, (5 - Shift_DOWN) * this.view_S);
          }
        }
      }
    }

    this.graphics.stroke(0);
    this.graphics.fill(0);
    this.graphics.textAlign(CENTER, CENTER);

    for (int i = this.j_Start; i < this.j_End; i++) {
      if (this.U_scale >= 0.75) {

        float x = (i - ((0 - 12) / 24.0)) * sx_Plot;
        float y = 0.1 * sx_Plot / this.U_scale;
        float h = sx_Plot * 0.15 / this.U_scale;

        this.graphics.textSize(h);
        this.graphics.text("12:00", x, y);
      }
    }

    this.drawInfo(sx_Plot, this.V_belowLine);
  }



  void drawPositionGrid (float x_Plot, float y_Plot, float sx_Plot, float sy_Plot, int fill_back) {
    this.graphics.strokeWeight(this.T_scale * 1);

    if (fill_back != 0) {
      for (int i = this.j_Start; i < this.j_End; i++) {

        float x1 = (i + this.rect_offset_x) * sx_Plot;
        float y1 = 0;
        float h = 2 * 90 * this.rect_scale * sx_Plot;

        this.graphics.stroke(223);
        this.graphics.fill(223);
        this.graphics.ellipse(x1, y1, h, h);
      }
    }

    for (int i = this.j_Start; i < this.j_End; i++) {
      for (int t = 0; t < 360; t += 15) {

        if ((t % 45) != 0) {
          this.graphics.stroke(0, 63);
          this.graphics.fill(0, 63);
        } else {

          this.graphics.stroke(0);
          this.graphics.fill(0);
        }
        int r = 0;
        if ((t % 45) != 0) r = 15;

        float x1 = (i + this.rect_offset_x + r * this.rect_scale * funcs.cos_ang(t)) * sx_Plot;
        float x2 = (i + this.rect_offset_x + 90 * this.rect_scale * funcs.cos_ang(t)) * sx_Plot;
        float y1 = -(r * this.rect_scale * funcs.sin_ang(t)) * sx_Plot;
        float y2 = -(90 * this.rect_scale * funcs.sin_ang(t)) * sx_Plot;

        this.graphics.line(x1, y1, x2, y2);

        boolean displayText = false;
        if ((this.j_End == 2) && (t % 45 == 0)) displayText = true;
        else if ((t + 45) % 90 == 0) displayText = true;

        if (displayText) {
          float textR = 105;
          float textSize = sx_Plot * 0.150 / this.U_scale;

          if (this.j_End == 2) {
            textR = 95;
            textSize *= 1.5;
          }

          this.graphics.stroke(0, 127);
          this.graphics.fill(0, 127);
          this.graphics.textSize(textSize);
          this.graphics.textAlign(CENTER, CENTER);

          String txt = "";
          switch((360 + 90 - t) % 360) {
          case 0 :
            txt = "N";
            break;
          case 45 :
            txt = "NE";
            break;
          case 90 :
            txt = "E";
            break;
          case 135 :
            txt = "SE";
            break;
          case 180 :
            txt = "S";
            break;
          case 225 :
            txt = "SW";
            break;
          case 270 :
            txt = "W";
            break;
          case 315 :
            txt = "NW";
            break;
          }

          float x = (i + this.rect_offset_x + textR * this.rect_scale * funcs.cos_ang(t)) * sx_Plot;
          float y = -(textR * this.rect_scale * funcs.sin_ang(t)) * sx_Plot;

          this.graphics.text(txt, x, y);
        }
      }

      float impact_scale = 1;
      if ((this.PlotImpacts == PlotImpacts_WIND_ACTIVE) || (this.PlotImpacts == PlotImpacts_WIND_PASSIVE)) impact_scale = LAYER_windspd.V_scale * 45 / 50.0;

      for (int r = 90; r > 0; r -= 15) {
        if ((r % 90) != 0) {
          this.graphics.stroke(0, 63);
          this.graphics.noFill();
        } else {
          this.graphics.stroke(0);
          this.graphics.noFill();
        }

        float x1 = (i + this.rect_offset_x) * sx_Plot;
        float y1 = 0;
        float h = 2 * r * this.rect_scale * sx_Plot;

        this.graphics.ellipse(x1, y1, h, h);

        int t = 90;
        if (t == 90) {
          float textSize = sx_Plot * 0.150 / this.U_scale;
          if (this.j_End == 2) {
            textSize *= 1.5;
          }

          float x = (i + this.rect_offset_x + r * this.rect_scale * funcs.cos_ang(t)) * sx_Plot;
          float y = -(r * this.rect_scale * funcs.sin_ang(t)) * sx_Plot;

          this.graphics.stroke(0, 127);
          this.graphics.fill(0, 127);
          this.graphics.textSize(textSize);
          this.graphics.textAlign(CENTER, CENTER);
          this.graphics.text(nf(int(r / impact_scale), 1), x, y);
        }
      }
    }
  }


  void drawDailyGrid (float x_Plot, float y_Plot, float sx_Plot, float sy_Plot) {

    this.graphics.stroke(0);
    this.graphics.fill(0);
    this.graphics.textAlign(CENTER, CENTER);

    for (int j = this.j_Start; j < this.j_End; j++) {
      if ((this.U_scale >= 0.75) || (((j - this.j_Start) % int(1.5 / this.U_scale)) == 0)) {

        float x = (j - ((0 - 12) / 24.0)) * sx_Plot;
        float y = -1.2 * sx_Plot / this.U_scale;
        float h = sx_Plot * 0.2 / this.U_scale;

        this.graphics.textSize(h);
        this.graphics.text(TIME.getDayText(j * this.perDays + 286 + TIME.beginDay), x, y + h);
        if (this.joinDays > 1) {
          this.graphics.text(("±" + int(this.joinDays / 2) + TIME.WORDS[2][Language_Active] + "s"), x, y);
        }
      }
    }

    this.drawInfo(sx_Plot, 1);
  }


  void drawInfo (float sx_Plot, float V_belowLine) {
    this.graphics.stroke(0);
    this.graphics.fill(0);
    this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
    this.graphics.textAlign(RIGHT, TOP);

    String txt = STATION.getCity();

    if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
      txt += "\n(" + nf(TIME.year, 4) + "_" + nf(TIME.month, 2) + "_" + nf(TIME.day, 2) + "_" + nf(TIME.hour, 2) + ")";
    }

    //this.graphics.text(txt, -1.0 * sx_Plot / this.U_scale, -1.25 * sx_Plot / this.U_scale);

    switch(this.skyScenario) {
    case 1 :
      this.graphics.stroke(0, 0, 0);
      this.graphics.fill(0, 0, 0);
      break;
    case 2 :
      this.graphics.stroke(0, 0, 255);
      this.graphics.fill(0, 0, 255);
      break;
    case 3 :
      this.graphics.stroke(0, 127, 0);
      this.graphics.fill(0, 127, 0);
      break;
    case 4 :
      this.graphics.stroke(255, 0, 0);
      this.graphics.fill(255, 0, 0);
      break;
    }

    this.graphics.textAlign(RIGHT, TOP);

    this.graphics.text(skyScenario_Title[this.skyScenario], -1 * sx_Plot / this.U_scale, -0.25 * sx_Plot / this.U_scale);
  }



  void drawData (float[] Ax_LINES, float[] Ay_LINES, float[] Bx_LINES, float[] By_LINES) {
    //this.graphics.stroke(this.color_data_raws);
    //this.graphics.fill(this.color_data_raws);
    //this.graphics.strokeWeight(this.T_scale * 1);

    this.graphics.stroke(0, PAINT.getOpacity(this.O_scale));
    this.graphics.fill(0, PAINT.getOpacity(this.O_scale));
    this.graphics.strokeWeight(this.T_scale * 0.5);

    for (int i = 0; i < Ax_LINES.length; i++) {
      this.graphics.line(Ax_LINES[i], Ay_LINES[i], Bx_LINES[i], By_LINES[i]);
    }
  }


  void drawProbs (int i, int j, float[] valuesSUM, float[] valuesNUM, float x_Plot, float y_Plot, float sx_Plot, float sy_Plot) {

    //println("view_S=", this.view_S);
    //println("LevelPix=", this.LevelPix);

    //float _pix = 100.0 * this.view_S / this.LevelPix;
    float _pix = 90.0 * this.view_S / this.LevelPix;

    //println("_pix=", _pix);


    int PAL_type = this.PROB_pallet_CLR;
    int PAL_direction = this.PROB_pallet_DIR;
    float PAL_multiplier = this.PROB_pallet_MLT;

    float txt_max_width = (this.sumInterval * this.view_S * 100 / 24.0) * this.U_scale;
    float txt_max_height = _pix;
    float txt_size = 1;
    if (txt_max_height > txt_max_width) {
      txt_size = 0.9 * txt_max_width;
    }
    else {
      txt_size = 0.9 * txt_max_height;
    }
    this.graphics.textSize(txt_size);


    this.graphics.rectMode(CORNER);
    this.graphics.textAlign(CENTER, CENTER);

    float min_V = FLOAT_undefined;
    float max_V = -FLOAT_undefined;

    for (int k = 0; k < valuesSUM.length; k++) {
      if (is_defined(valuesSUM[k])) {
        if (min_V > valuesSUM[k]) min_V = valuesSUM[k];
        if (max_V < valuesSUM[k]) max_V = valuesSUM[k];
      }
    }

    if ((is_defined(min_V)) && (is_defined(-max_V))) {
      int min_b = int(funcs.roundTo((min_V * abs(sy_Plot)), _pix) / _pix);
      int max_b = int(funcs.roundTo((max_V * abs(sy_Plot)), _pix) / _pix);

      if (CurrentLayer_id == LAYER_winddir.id) min_b = 0;

      int[] probs;
      int totalProbs = 0;

      probs = new int [floor(max_b - min_b) + 1];

      for (int k = 0; k < valuesSUM.length; k++) {
        if (is_defined(valuesSUM[k])) {
          float the_value = valuesSUM[k];

          if (CurrentLayer_id == LAYER_winddir.id) {
            if (funcs.roundTo((the_value * abs(sy_Plot)), _pix) >= (360 * abs(sy_Plot))) the_value -= 360;
          }

          int h = int(funcs.roundTo((funcs.roundTo((the_value * abs(sy_Plot)), _pix) / _pix) - min_b, 1));

          if (h < 0) h = 0;
          else if (h > probs.length - 1) h = probs.length - 1;
          probs[h] += 1;
          totalProbs += 1;
        }
      }

      if (totalProbs != 0) {
        for (int n = 0; n < probs.length; n++) {
          float prob_V = 1.0 * probs[n] / totalProbs;

          //if (int(funcs.roundTo(100 * prob_V, 1)) > 0) {
          if ((100 * prob_V) > 0) {

            float _u = PAL_multiplier * prob_V;

            if (PAL_direction == -1) _u = 1 - _u;
            if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
            if (PAL_direction == 2) _u =  0.5 * _u;

            float[] COL = PAINT.getColorStyle(PAL_type, _u);

            float w = (this.sumInterval * this.view_S * 100 / 24.0) * this.U_scale;
            float h = _pix * 1.5;

            float x1 = (j + ((i + 1) / 24.0)) * sx_Plot;
            float y1 = -(min_b + n + 0.5) * h;

            this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
            this.graphics.noStroke();
            this.graphics.rect(x1 - w, y1, w, h);

            if (COL[1] + COL[2] + COL[3] > 1.75 * 255) {
              this.graphics.fill(127);
              this.graphics.noStroke();
            } else {
              this.graphics.fill(255);
              this.graphics.stroke(255);
              this.graphics.strokeWeight(2);
            }

            this.graphics.text((String.valueOf(int(funcs.roundTo(100 * prob_V, 1)))), x1 - 0.5 * w, y1 + 0.5 * h - 0.25 * txt_size);

            if ((this.export_info_prob) && (this.displayProbs)) {
              FILE_outputProbs[(j - this.j_Start)].print(nfs((min_b + n) * _pix / abs(sy_Plot) - this.V_offset, 5, 5) + ":\t" + nf(100 * prob_V, 3, 3) + "\t");
            }

          }
        }

        if ((this.export_info_prob) && (this.displayProbs)) {
          FILE_outputProbs[(j - this.j_Start)].println("");
        }
      }
    }

    float pal_length = 400;
    float pal_ox = 700;
    float pal_oy = (50 * this.V_belowLine) + 40;

    for (int q = 0; q < 11; q++) {
      float prob_V = 10 * q / 100.0;

      float _u = PAL_multiplier * prob_V;

      if (PAL_direction == -1) _u = 1 - _u;
      if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
      if (PAL_direction == 2) _u =  0.5 * _u;

      float[] COL = PAINT.getColorStyle(PAL_type, _u);
      this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
      this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

      this.graphics.strokeWeight(0);

      this.graphics.rect((pal_ox + q * (pal_length / 11.0)) * this.view_S, pal_oy * this.view_S, (pal_length / 11.0) * this.view_S, 20 * this.view_S);

      if (COL[1] + COL[2] + COL[3] > 1.75 * 255) {
        this.graphics.stroke(127);
        this.graphics.fill(127);
        this.graphics.strokeWeight(0);
      } else {
        this.graphics.stroke(255);
        this.graphics.fill(255);
        this.graphics.strokeWeight(2);
      }

      this.graphics.textSize(15.0 * this.view_S);
      this.graphics.textAlign(CENTER, CENTER);

      float x = (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S;
      float y = (10 + pal_oy - 0.05 * 20) * this.view_S;

      this.graphics.text((String.valueOf(int(funcs.roundTo(100 * prob_V, 1)))), x, y);
    }
  }


  void drawSorted (int i, int j, float[] valuesA, float[] valuesB, float x_Plot, float y_Plot, float sx_Plot, float sy_Plot) {

    int PAL_type = this.SORT_pallet_CLR;
    int PAL_direction = this.SORT_pallet_DIR;
    float PAL_multiplier = this.SORT_pallet_MLT;

    float[] sortedvaluesA = sort(valuesA);
    int num_sortedvaluesA = 0;
    for (int l = 0; l < sortedvaluesA.length; l++) {
      if (is_defined(sortedvaluesA[l])) {
        num_sortedvaluesA += 1;
      } else break;
    }

    float[] sortedvaluesB = sort(valuesB);
    int num_sortedvaluesB = 0;
    for (int l = 0; l < sortedvaluesB.length; l++) {
      if (is_defined(sortedvaluesB[l])) {
        num_sortedvaluesB += 1;
      } else break;
    }

    int num_sortedvaluesAB = min(num_sortedvaluesA, num_sortedvaluesB);

    for (int l = 0; l < (num_sortedvaluesAB - 1); l++) {
      float sort_V = 1.1 * (0.5 - ((num_sortedvaluesAB - (l + 1)) / float(num_sortedvaluesAB)));

      float _u = 0.5 + 0.5 * (PAL_multiplier * sort_V);

      if (PAL_direction == -1) _u = 1 - _u;
      if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
      if (PAL_direction == 2) _u =  0.5 * _u;

      float[] COL = PAINT.getColorStyle(PAL_type, _u);
      this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
      this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

      this.graphics.strokeWeight(this.T_scale * 0.0);
      //this.graphics.rect((j + ((i + 1) / 24.0)) * sx_Plot, sortedvaluesA[l] * sy_Plot, -(1 * 100 / 24.0) * this.U_scale, (sortedvaluesA[(l + 1)] - sortedvaluesA[l]) * sy_Plot);

      float P1x = (j + ((i + 0.5) / 24.0)) * sx_Plot;
      float P2x = (j + ((i + 0.5) / 24.0)) * sx_Plot;
      float P3x = (j + ((i + 1.5) / 24.0)) * sx_Plot;
      float P4x = (j + ((i + 1.5) / 24.0)) * sx_Plot;

      float P1y = sortedvaluesA[l] * sy_Plot;
      float P2y = sortedvaluesA[(l + 1)] * sy_Plot;
      float P3y = sortedvaluesB[(l + 1)] * sy_Plot;
      float P4y = sortedvaluesB[l] * sy_Plot;

      this.graphics.quad(P1x, P1y, P2x, P2y, P3x, P3y, P4x, P4y);
      /*
      this.graphics.stroke(255);
       this.graphics.strokeWeight(this.T_scale * 0.5);
       this.graphics.line(P1x, P1y, P4x, P4y);
       this.graphics.line(P2x, P2y, P3x, P3y);
       */
    }

    String[] _txt = {
      "MIN", "", "25%", "", "MED", "", "75%", "", "MAX"
    };
    float pal_length = 400;
    float pal_ox = 700;
    float pal_oy = (50 * this.V_belowLine) + 40;

    for (int q = 0; q < 9; q++) {
      float sort_V = 1.1 * (q - 4) / 8.0;

      float _u = 0.5 + 0.5 * (PAL_multiplier * sort_V);

      if (PAL_direction == -1) _u = 1 - _u;
      if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
      if (PAL_direction == 2) _u =  0.5 * _u;

      float[] COL = PAINT.getColorStyle(PAL_type, _u);
      this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
      this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

      //this.graphics.strokeWeight(0.0);
      this.graphics.stroke(255);
      this.graphics.strokeWeight(0.5);
      this.graphics.rect((pal_ox + q * (pal_length / 9.0)) * this.view_S, pal_oy * this.view_S, (pal_length / 9.0) * this.view_S, 20 * this.view_S);

      if (COL[1] + COL[2] + COL[3] > 1.75 * 255) {
        this.graphics.stroke(127);
        this.graphics.fill(127);
        this.graphics.strokeWeight(0);
      } else {
        this.graphics.stroke(255);
        this.graphics.fill(255);
        this.graphics.strokeWeight(2);
      }

      this.graphics.textSize(15.0 * this.view_S);
      this.graphics.textAlign(CENTER, CENTER);
      this.graphics.text(_txt[q], (25 + pal_ox + q * (pal_length / 9.0)) * this.view_S, (10 + pal_oy - 0.05 * 20) * this.view_S);
    }
  }


  void drawNormals (int i, int j, float[] valuesA, float[] valuesB, float x_Plot, float y_Plot, float sx_Plot, float sy_Plot) {
    float[] NormalsA = SOLARCHVISION_NORMAL(valuesA);
    float[] NormalsB = SOLARCHVISION_NORMAL(valuesB);

    if (CurrentLayer_id == LAYER_winddir.id) {
      float[] XvaluesA;
      float[] YvaluesA;
      XvaluesA = new float [valuesA.length];
      YvaluesA = new float [valuesA.length];

      for (int l = 0; l < valuesA.length; l++) {
        if (is_defined(valuesA[l])) {
          XvaluesA[l] = funcs.cos_ang(90 - valuesA[l]);
          YvaluesA[l] = funcs.sin_ang(90 - valuesA[l]);
        } else {
          XvaluesA[l] = FLOAT_undefined;
          YvaluesA[l] = FLOAT_undefined;
        }
      }

      float[] X_NormalsA = SOLARCHVISION_NORMAL(XvaluesA);
      float[] Y_NormalsA = SOLARCHVISION_NORMAL(YvaluesA);

      for (int l = 0; l < NormalsA.length; l++) {
        if (is_defined(NormalsA[l])) {
          NormalsA[l] = 90 - funcs.atan2_ang(Y_NormalsA[l], X_NormalsA[l]);
          if (NormalsA[l] < 0) NormalsA[l] += 360;
        }

        if ((l == STAT_N_Max) || (l == STAT_N_Min)) {
          NormalsA[l] = FLOAT_undefined;
        }
      }

      float[] XvaluesB;
      float[] YvaluesB;
      XvaluesB = new float [valuesB.length];
      YvaluesB = new float [valuesB.length];

      for (int l = 0; l < valuesB.length; l++) {
        if (is_defined(valuesB[l])) {
          XvaluesB[l] = funcs.cos_ang(90 - valuesB[l]);
          YvaluesB[l] = funcs.sin_ang(90 - valuesB[l]);
        } else {
          XvaluesB[l] = FLOAT_undefined;
          YvaluesB[l] = FLOAT_undefined;
        }
      }

      float[] X_NormalsB = SOLARCHVISION_NORMAL(XvaluesB);
      float[] Y_NormalsB = SOLARCHVISION_NORMAL(YvaluesB);

      for (int l = 0; l < NormalsB.length; l++) {
        if (is_defined(NormalsB[l])) {
          NormalsB[l] = 90 - funcs.atan2_ang(Y_NormalsB[l], X_NormalsB[l]);
          if (NormalsB[l] < 0) NormalsB[l] += 360;
        }

        if ((l == STAT_N_Max) || (l == STAT_N_Min)) {
          NormalsB[l] = FLOAT_undefined;
        }
      }
    }
    int _OPACITY = 191;

    for (int l = 0; l < 9; l++) {


      if (l == STAT_N_Middle) {
        this.graphics.strokeWeight(this.T_scale * 1);
        this.graphics.stroke(0, 191, 0);
        this.graphics.fill(0, 191, 0);
      } else if (l == STAT_N_MidHigh) {
        this.graphics.strokeWeight(this.T_scale * 1);
        this.graphics.stroke(191, 0, 0);
        this.graphics.fill(191, 0, 0);
      } else if (l == STAT_N_MidLow) {
        this.graphics.strokeWeight(this.T_scale * 1);
        this.graphics.stroke(0, 0, 191);
        this.graphics.fill(0, 0, 191);
      } else if (l == STAT_N_Max) {
        this.graphics.strokeWeight(this.T_scale * 1);
        this.graphics.stroke(255, 127, 127);
        this.graphics.fill(255, 127, 127);
      } else if (l == STAT_N_Min) {
        this.graphics.strokeWeight(this.T_scale * 1);
        this.graphics.stroke(127, 127, 255);
        this.graphics.fill(127, 127, 255);
      } else if (l == STAT_N_M50) {
        this.graphics.strokeWeight(this.T_scale * 1);
        this.graphics.stroke(0, 127, 0);
        this.graphics.fill(0, 127, 0);
      } else if (l == STAT_N_M75) {
        this.graphics.strokeWeight(this.T_scale * 1);
        this.graphics.stroke(127, 0, 0);
        this.graphics.fill(127, 0, 0);
      } else if (l == STAT_N_M25) {
        this.graphics.strokeWeight(this.T_scale * 1);
        this.graphics.stroke(0, 0, 127);
        this.graphics.fill(0, 0, 127);
      } else {
        this.graphics.strokeWeight(this.T_scale * 1);
        this.graphics.stroke(0, 0, 0);
        this.graphics.fill(0, 0, 0);
      }



      if (l == this.ImpactLayer) {
       this.graphics.strokeWeight(this.T_scale * 4);
       this.graphics.stroke(127, 127, 127, _OPACITY);
       this.graphics.fill(127, 127, 127, _OPACITY);
      }




      float z_l = 60; //l;
      if (l == STAT_N_M75) z_l = 61;
      if (l == STAT_N_M50) z_l = 61;
      if (l == STAT_N_M25) z_l = 61;
      if (l == STAT_N_Ave) z_l = 62;

      if ((is_defined(NormalsA[l])) && (is_defined(NormalsB[l]))) {

        float x1 = (j + ((i + 0.5) / 24.0)) * sx_Plot;
        float y1 = NormalsA[l] * sy_Plot;
        float x2 = (j + ((i + 0.5 + TIME.interval) / 24.0)) * sx_Plot;
        float y2 = NormalsB[l] * sy_Plot;

        this.graphics.line(x1, y1, x2, y2);
      }

      if ((this.export_info_norm) && (this.displayNormals)) {
        if (is_defined(NormalsA[l])) FILE_outputNorms[(j - this.j_Start)].print(nfs(NormalsA[l] - this.V_offset, 5, 5) + "\t");
        else FILE_outputNorms[(j - this.j_Start)].print("[undefined]\t");
      }
    }
    if ((this.export_info_norm) && (this.displayNormals)) FILE_outputNorms[(j - this.j_Start)].println();
  }



  void plotHourly (float x_Plot, float y_Plot, float sx_Plot, float sy_Plot) {

    int DATA_start = getStart_CurrentDataSource();
    int DATA_end = getEnd_CurrentDataSource();
    String DATA_reference = getReference_CurrentDataSource();

    this.graphics.pushMatrix();
    this.graphics.translate(x_Plot, y_Plot);

    this.color_data_raws = color(0, 0, 63, PAINT.getOpacity(this.O_scale));

    this.drawTimeGrid(x_Plot, y_Plot, sx_Plot, sy_Plot);

    int[] startK_endK = get_startK_endK();
    int start_k = startK_endK[0];
    int end_k = startK_endK[1];
    int count_k = 1 + end_k - start_k;
    if (count_k < 0) count_k = 0;


    if (this.PrintTtitle) {

      this.graphics.stroke(0);
      this.graphics.fill(0);
      this.graphics.strokeWeight(this.T_scale * 0);

      this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
      this.graphics.textAlign(RIGHT, CENTER);

      if (CurrentDataSource == dataID_CLIMATE_CWEEDS) this.graphics.text(("[" + String.valueOf(start_k + CLIMATE_CWEEDS_start) + "-" + String.valueOf(end_k + CLIMATE_CWEEDS_start) + "] "), 0, 1.0 * sx_Plot / this.U_scale);
      if (CurrentDataSource == dataID_CLIMATE_CLMREC) this.graphics.text(("[" + String.valueOf(start_k + CLIMATE_CLMREC_start) + "-" + String.valueOf(end_k + CLIMATE_CLMREC_start) + "] "), 0, 1.0 * sx_Plot / this.U_scale);
      if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) this.graphics.text(("[" + String.valueOf(start_k + ENSEMBLE_FORECAST_start) + "-" + String.valueOf(end_k + ENSEMBLE_FORECAST_start) + "] "), 0, 1.0 * sx_Plot / this.U_scale);

      this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
      this.graphics.textAlign(LEFT, CENTER);
      this.graphics.text((CurrentLayer_descriptions[Language_Active]), 0, 1.0 * sx_Plot / this.U_scale);
    }

    float Pa = FLOAT_undefined;
    float Pb = FLOAT_undefined;

    float[] valuesA;
    float[] valuesB;
    valuesA = new float [count_k * this.joinDays];
    valuesB = new float [count_k * this.joinDays];

    float[] valuesSUM;
    float[] valuesNUM;
    int _interval = 0;
    valuesSUM = new float [count_k * this.joinDays];
    valuesNUM = new float [count_k * this.joinDays];

    for (int k = 0; k < count_k; k++) {
      for (int j_ADD = 0; j_ADD < this.joinDays; j_ADD++) {
        valuesA[(k * this.joinDays + j_ADD)] = FLOAT_undefined;
        valuesB[(k * this.joinDays + j_ADD)] = FLOAT_undefined;
        valuesSUM[(k * this.joinDays + j_ADD)] = 0; // Note: must be initialized to zero; not undefined.
        valuesNUM[(k * this.joinDays + j_ADD)] = 0;
      }
    }

    float[] Ax_LINES = new float [0];
    float[] Ay_LINES = new float [0];
    float[] Bx_LINES = new float [0];
    float[] By_LINES = new float [0];

    FILE_outputRaw = new PrintWriter [(this.j_End - this.j_Start)];
    FILE_outputNorms = new PrintWriter [(this.j_End - this.j_Start)];
    FILE_outputProbs = new PrintWriter [(this.j_End - this.j_Start)];

    String Main_name = MAKE_MainName();

    for (int j = this.j_Start; j < this.j_End; j++) {

      this.graphics.stroke(0);
      this.graphics.fill(0);
      this.graphics.textAlign(CENTER, CENTER);

      if ((this.U_scale >= 0.75) || (((j - this.j_Start) % int(1.5 / this.U_scale)) == 0)) {

        float x = (j - ((0 - 12) / 24.0)) * sx_Plot;
        float y = -1.4 * sx_Plot / this.U_scale;
        float h = sx_Plot * 0.2 / this.U_scale;

        this.graphics.textSize(h);
        this.graphics.text(TIME.getDayText(j * this.perDays + 286 + TIME.beginDay), x, y + h);
        if (this.joinDays > 1) {
          this.graphics.text(("±" + int(this.joinDays / 2) + TIME.WORDS[2][Language_Active] + "s"), x, y);
        }
      }

      String _FilenamesAdd = "";
      if (this.joinDays > 1) {
        _FilenamesAdd = ("±" + int(this.joinDays / 2) + TIME.WORDS[2][Language_Active] + "s");
      }
      if ((this.export_info_node) && (this.displayRaws)) {
        FILE_outputRaw[(j - this.j_Start)] = createWriter(Folder_Export + "/" + Main_name + "/" + databaseString[CurrentDataSource] + "_node_" + STATION.getCity() + "_from_" + String.valueOf(start_k + DATA_start) + "_to_" + String.valueOf(end_k + DATA_start) + "_" + CurrentLayer_descriptions[Language_EN] + "_" + skyScenario_FileTXT[this.skyScenario] + "_" + TIME.getDayText(j * this.perDays + 286 + TIME.beginDay) + _FilenamesAdd + ".txt");
        FILE_outputRaw[(j - this.j_Start)].println(TIME.getDayText(j * this.perDays + 286 + TIME.beginDay) + _FilenamesAdd + "\t" + skyScenario_FileTXT[this.skyScenario] + "\t" + CurrentLayer_descriptions[Language_EN] + "(" + CurrentLayer_unit + ")" + "\tfrom:" + String.valueOf(start_k + DATA_start) + "\tto:" + String.valueOf(end_k + DATA_start) + "\t" + STATION.getCity() + "\tHourly data");

        FILE_outputRaw[(j - this.j_Start)].print("Hour\t");
        for (int k = 0; k < count_k; k++) {
          FILE_outputRaw[(j - this.j_Start)].print(nf(k, 4) + "        \t");
        }
        FILE_outputRaw[(j - this.j_Start)].println("");
      }
      if ((this.export_info_norm) && (this.displayNormals)) {
        FILE_outputNorms[(j - this.j_Start)] = createWriter(Folder_Export + "/" + Main_name + "/" + databaseString[CurrentDataSource] + "_norm_" + STATION.getCity() + "_from_" + String.valueOf(start_k + DATA_start) + "_to_" + String.valueOf(end_k + DATA_start) + "_" + CurrentLayer_descriptions[Language_EN] + "_" + skyScenario_FileTXT[this.skyScenario] + "_" + TIME.getDayText(j * this.perDays + 286 + TIME.beginDay) + _FilenamesAdd + ".txt");
        FILE_outputNorms[(j - this.j_Start)].println(TIME.getDayText(j * this.perDays + 286 + TIME.beginDay) + _FilenamesAdd + "\t" + skyScenario_FileTXT[this.skyScenario] + "\t" + CurrentLayer_descriptions[Language_EN] + "(" + CurrentLayer_unit + ")" + "\tfrom:" + String.valueOf(start_k + DATA_start) + "\tto:" + String.valueOf(end_k + DATA_start) + "\t" + STATION.getCity() + "\tHourly normal");
        FILE_outputNorms[(j - this.j_Start)].print("Hour\t");
        for (int l = 0; l < 9; l++) {
          FILE_outputNorms[(j - this.j_Start)].print(STAT_N_Title[l] + "\t");
        }
        FILE_outputNorms[(j - this.j_Start)].println("");
      }
      if ((this.export_info_prob) && (this.displayProbs)) {
        FILE_outputProbs[(j - this.j_Start)] = createWriter(Folder_Export + "/" + Main_name + "/" + databaseString[CurrentDataSource] + "_prob_" + STATION.getCity() + "_from_" + String.valueOf(start_k + DATA_start) + "_to_" + String.valueOf(end_k + DATA_start) + "_" + CurrentLayer_descriptions[Language_EN] + "_" + skyScenario_FileTXT[this.skyScenario] + "_" + TIME.getDayText(j * this.perDays + 286 + TIME.beginDay) + _FilenamesAdd + ".txt");
        FILE_outputProbs[(j - this.j_Start)].println(TIME.getDayText(j * this.perDays + 286 + TIME.beginDay) + _FilenamesAdd + "\t" + skyScenario_FileTXT[this.skyScenario] + "\t" + CurrentLayer_descriptions[Language_EN] + "(" + CurrentLayer_unit + ")" + "\tfrom:" + String.valueOf(start_k + DATA_start) + "\tto:" + String.valueOf(end_k + DATA_start) + "\t" + STATION.getCity() + "\tHourly probabilities");

        FILE_outputProbs[(j - this.j_Start)].print("Hour:\t");
        FILE_outputProbs[(j - this.j_Start)].println("");
      }

      for (int i = 0; i < 24; i++) {
        if (this.isInHourlyRange(i)) {
          if ((this.export_info_node) && (this.displayRaws)) FILE_outputRaw[(j - this.j_Start)].print(nf(i, 2) + "\t");
          if ((this.export_info_norm) && (this.displayNormals)) FILE_outputNorms[(j - this.j_Start)].print(nf(i, 2) + "\t");
          if ((this.export_info_prob) && (this.displayProbs)) FILE_outputProbs[(j - this.j_Start)].print(nf(i, 2) + "\t");

          for (int k = 0; k < count_k; k++) {
            for (int j_ADD = 0; j_ADD < this.joinDays; j_ADD++) {

              valuesA[(k * this.joinDays + j_ADD)] = FLOAT_undefined;
              valuesB[(k * this.joinDays + j_ADD)] = FLOAT_undefined;
              valuesSUM[(k * this.joinDays + j_ADD)] = 0;
              valuesNUM[(k * this.joinDays + j_ADD)] = 1;

              float[] COL = PAINT.getColorStyle(COLOR_STYLE_Current, (1.0 * k / (1 + DATA_end - DATA_start)));
              this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
              this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);


              int now_k = k + start_k;
              int now_i = i;
              int now_j = int(j * this.perDays + (j_ADD - int(funcs.roundTo(0.5 * this.joinDays, 1))) + TIME.beginDay + 365) % 365;


              if (now_j >= 365) {
                now_j = now_j % 365;
              }
              if (now_j < 0) {
                now_j = (now_j + 365) % 365;
              }

              int next_i = now_i + 1;
              int next_j = now_j;
              int next_k = now_k;
              if (next_i == 24) {
                next_i = 0;
                next_j += 1;
                if (next_j == 365) {
                  next_j = 0;
                  next_k += 1;
                }
              }

              Pa = getValue_CurrentDataSource(now_i, now_j, now_k, CurrentLayer_id);

              if (is_undefined(Pa)) {
                valuesA[(k * this.joinDays + j_ADD)] = FLOAT_undefined;

                if ((this.export_info_node) && (this.displayRaws)) FILE_outputRaw[(j - this.j_Start)].print("[undefined]\t");
              } else {
                int memberCount = SOLARCHVISION_filter(CurrentDataSource, LAYER_cloudcover.id, this.filter, this.skyScenario, now_i, now_j, now_k);

                if (memberCount == 1) {
                  valuesA[(k * this.joinDays + j_ADD)] = Pa;
                  valuesA[(k * this.joinDays + j_ADD)] += this.V_offset;

                  valuesSUM[(k * this.joinDays + j_ADD)] += valuesA[(k * this.joinDays + j_ADD)];
                  valuesNUM[(k * this.joinDays + j_ADD)] += 1;

                  if ((this.export_info_node) && (this.displayRaws)) {
                    if (is_defined(valuesA[(k * this.joinDays + j_ADD)])) {
                      FILE_outputRaw[(j - this.j_Start)].print(nfs(valuesA[(k * this.joinDays + j_ADD)] - this.V_offset, 5, 5) + "\t");
                    }
                    else {
                      FILE_outputRaw[(j - this.j_Start)].print("[undefined]\t");
                    }
                  }

                  if (next_k < (1 + DATA_end - DATA_start)) {

                    Pb = getValue_CurrentDataSource(next_i, next_j, next_k, CurrentLayer_id);

                    if (is_undefined(Pb)) {
                      valuesB[(k * this.joinDays + j_ADD)] = FLOAT_undefined;
                    } else {
                      valuesB[(k * this.joinDays + j_ADD)] = Pb;
                      valuesB[(k * this.joinDays + j_ADD)] += this.V_offset;

                      if (this.displayRaws) {
                        if ((CurrentLayer_id == LAYER_winddir.id) && (abs(valuesB[(k * this.joinDays + j_ADD)] - valuesA[(k * this.joinDays + j_ADD)]) > 180)) {
                        } else {
                          Ax_LINES = append(Ax_LINES, (j + ((i + 0.5) / 24.0)) * sx_Plot);
                          Ay_LINES = append(Ay_LINES, valuesA[(k * this.joinDays + j_ADD)] * sy_Plot);

                          Bx_LINES = append(Bx_LINES, (j + ((i + 1.5) / 24.0)) * sx_Plot);
                          By_LINES = append(By_LINES, valuesB[(k * this.joinDays + j_ADD)] * sy_Plot);
                        }
                      }
                    }
                  }
                } else {
                  if ((this.export_info_node) && (this.displayRaws)) FILE_outputRaw[(j - this.j_Start)].print("not_the_case\t");
                }
              }
            }
          }


          if ((this.export_info_node) && (this.displayRaws)) FILE_outputRaw[(j - this.j_Start)].println();

          if (this.displayProbs) {
            _interval += 1;
            if ((_interval % this.sumInterval) == 0) {
              for (int k = 0; k < count_k; k++) {
                for (int j_ADD = 0; j_ADD < this.joinDays; j_ADD++) {
                  valuesSUM[(k * this.joinDays + j_ADD)] += valuesA[(k * this.joinDays + j_ADD)];
                  valuesNUM[(k * this.joinDays + j_ADD)] += 1;

                  if (valuesNUM[(k * this.joinDays + j_ADD)] != 0) {
                    valuesSUM[(k * this.joinDays + j_ADD)] /= valuesNUM[(k * this.joinDays + j_ADD)];
                  }
                  else {
                    valuesSUM[(k * this.joinDays + j_ADD)] = FLOAT_undefined;
                  }
                }
              }

              this.drawProbs(i, j, valuesSUM, valuesNUM, x_Plot, y_Plot, sx_Plot, sy_Plot);
            }
          }

          if (this.displaySorted) {
            this.drawSorted(i, j, valuesA, valuesB, x_Plot, y_Plot, sx_Plot, sy_Plot);
          }

          if (this.displayNormals) {
            this.drawNormals(i, j, valuesA, valuesB, x_Plot, y_Plot, sx_Plot, sy_Plot);
          }
        }
      }

      if ((this.export_info_node) && (this.displayRaws)) {
        FILE_outputRaw[(j - this.j_Start)].flush();
        FILE_outputRaw[(j - this.j_Start)].close();
      }

      if ((this.export_info_norm) && (this.displayNormals)) {
        FILE_outputNorms[(j - this.j_Start)].flush();
        FILE_outputNorms[(j - this.j_Start)].close();
      }

      if ((this.export_info_prob) && (this.displayProbs)) {
        FILE_outputProbs[(j - this.j_Start)].flush();
        FILE_outputProbs[(j - this.j_Start)].close();
      }


    }

    if (this.displayRaws) {
      this.drawData(Ax_LINES, Ay_LINES, Bx_LINES, By_LINES);
    }

    this.graphics.popMatrix();
  }


  void setupPlot () {
    if ((this.plotSetup == -2) || (this.plotSetup == -1)) {
      int keep_TIME_BeginDay = TIME.beginDay;
      float keep_STUDY_perDays = this.perDays;
      int keep_joinDays = this.joinDays;
      int keep_STUDY_j_Start = this.j_Start;
      int keep_STUDY_j_End = this.j_End;
      float keep_STUDY_U_scale = this.U_scale;
      int keep_STUDY_PlotImpacts = this.PlotImpacts;
      int keep_STUDY_Impact_TYPE = this.Impact_TYPE;

      TIME.beginDay = 183; //0; // 183: to put the summer diagram on the left similar to the YC book
      this.perDays = 183;
      this.joinDays = 5;
      this.j_Start = 0;
      this.j_End = 2;
      this.U_scale = 18.0 / float(this.j_End - this.j_Start);
      this.PlotImpacts = (this.plotSetup == -1) ? PlotImpacts_CYCLES_PASSIVE : PlotImpacts_CYCLES_ACTIVE;
      this.Impact_TYPE = (this.plotSetup == -1) ? Impact_PASSIVE : Impact_ACTIVE;

      float scale = (FrameVariation == 2) ? 1 : 0.65;
      this.plotImpact(0, 0 * this.view_S, scale * (100.0 * this.U_scale * this.view_S), scale * (-1.0 * this.V_scale * this.view_S));

      TIME.beginDay = keep_TIME_BeginDay;
      this.perDays = keep_STUDY_perDays;
      this.joinDays = keep_joinDays;
      this.j_Start = keep_STUDY_j_Start;
      this.j_End = keep_STUDY_j_End;
      this.U_scale = keep_STUDY_U_scale;
      this.PlotImpacts = keep_STUDY_PlotImpacts;
      this.Impact_TYPE = keep_STUDY_Impact_TYPE;
    }


    if (this.plotSetup == 0) {

      if (FrameVariation == 2) {

        for (int p = 0; p < 3; p++) {
          this.ImpactLayer = 3 * int(pre_STUDY_ImpactLayer / 3) + p;
          this.plotImpact(0, (150 - p * 300) * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));
        }
        this.ImpactLayer = pre_STUDY_ImpactLayer;

      } else {
        this.plotImpact(0, -150 * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));
      }

      this.plotHourly(0, ((FrameVariation == 2) ? 450 : 150) * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));
    }


    if (this.plotSetup == 1) {
      int keep_PlotImpacts = this.PlotImpacts;
      int keep_CurrentLayer_id = CurrentLayer_id;

      if (FrameVariation == 2) {
        this.PlotImpacts = PlotImpacts_URBAN_ACTIVE;
        this.plotImpact(0, -450 * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

        this.PlotImpacts = PlotImpacts_GLOBAL_ACTIVE;
        this.plotImpact(0, -150 * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));
      }

      changeCurrentLayerTo(LAYER_dirnorrad.id);
      this.plotHourly(0, ((FrameVariation == 2) ? 150 : -150) * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

      changeCurrentLayerTo(LAYER_cloudcover.id);
      this.plotHourly(0, ((FrameVariation == 2) ? 450 : 150) * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

      this.PlotImpacts = keep_PlotImpacts;
      changeCurrentLayerTo(keep_CurrentLayer_id);
    }


    if (this.plotSetup == 2) {
      int keep_PlotImpacts = this.PlotImpacts;
      int keep_CurrentLayer_id = CurrentLayer_id;

      if (FrameVariation == 2) {
        this.PlotImpacts = PlotImpacts_URBAN_PASSIVE;
        this.plotImpact(0, -450 * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

        this.PlotImpacts = PlotImpacts_GLOBAL_PASSIVE;
        this.plotImpact(0, -150 * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));
      }

      changeCurrentLayerTo(LAYER_direffect.id);
      this.plotHourly(0, ((FrameVariation == 2) ? 150 : -150) * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

      changeCurrentLayerTo(LAYER_drybulb.id);
      this.plotHourly(0, ((FrameVariation == 2) ? 450 : 150) * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

      this.PlotImpacts = keep_PlotImpacts;
      changeCurrentLayerTo(keep_CurrentLayer_id);
    }


    if (this.plotSetup == 3) {
      int keep_PlotImpacts = this.PlotImpacts;
      int keep_CurrentLayer_id = CurrentLayer_id;

      if (FrameVariation == 2) {
        this.PlotImpacts = PlotImpacts_WIND_PASSIVE;
        this.plotImpact(0, -450 * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

        changeCurrentLayerTo(LAYER_drybulb.id);
        this.plotHourly(0, -150 * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));
      }

      this.PlotImpacts = PlotImpacts_WIND_ACTIVE;
      this.plotImpact(0, ((FrameVariation == 2) ? 150 : -150) * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

      changeCurrentLayerTo(LAYER_windspd.id);
      this.plotHourly(0, ((FrameVariation == 2) ? 450 : 150) * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

      this.PlotImpacts = keep_PlotImpacts;
      changeCurrentLayerTo(keep_CurrentLayer_id);
    }


    if (this.plotSetup == 4) {
      int keep_ImpactLayer = this.ImpactLayer;
      int keep_PlotImpacts = this.PlotImpacts;
      int keep_CurrentLayer_id = CurrentLayer_id;
      boolean keep_displaySorted = this.displaySorted;
      boolean keep_displayNormals = this.displayNormals;
      boolean keep_displayRaws = this.displayRaws;
      boolean keep_displayProbs = this.displayProbs;

      if (FrameVariation == 2) {
        this.PlotImpacts = PlotImpacts_GLOBAL_PASSIVE;

        this.ImpactLayer = 3 * int(pre_STUDY_ImpactLayer / 3);
        this.plotImpact(0, -450 * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

        this.ImpactLayer = 3 * int(pre_STUDY_ImpactLayer / 3) + 2;
        this.plotImpact(0, -150 * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));
      }

      changeCurrentLayerTo(LAYER_drybulb.id);

      this.displaySorted = true;
      this.displayNormals = true;
      this.displayRaws = false;
      this.displayProbs = false;
      this.plotHourly(0, ((FrameVariation == 2) ? 150 : -150) * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

      this.displaySorted = false;
      this.displayNormals = false;
      this.displayRaws = true;
      this.displayProbs = true;
      this.plotHourly(0, ((FrameVariation == 2) ? 450 : 150) * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

      this.ImpactLayer = keep_ImpactLayer;
      this.PlotImpacts = keep_PlotImpacts;
      changeCurrentLayerTo(keep_CurrentLayer_id);
      this.displaySorted = keep_displaySorted;
      this.displayNormals = keep_displayNormals;
      this.displayRaws = keep_displayRaws;
      this.displayProbs = keep_displayProbs;
    }


    if (this.plotSetup == 5) {
      int keep_skyScenario = this.skyScenario;
      int keep_CurrentLayer_id = CurrentLayer_id;

      changeCurrentLayerTo(LAYER_drybulb.id);

      if (FrameVariation == 2) {
        this.skyScenario = 1;
        this.plotHourly(0, -450 * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));
      }

      this.skyScenario = 4;
      this.plotHourly(0, ((FrameVariation == 2) ? -150 : -150) * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

      if (FrameVariation == 2) {
        this.skyScenario = 3;
        this.plotHourly(0, 150 * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));
      }

      this.skyScenario = 2;
      this.plotHourly(0, ((FrameVariation == 2) ? 450 : 150) * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

      this.skyScenario = keep_skyScenario;
      changeCurrentLayerTo(keep_CurrentLayer_id);
    }


    if (this.plotSetup == 6) {
      int keep_skyScenario = this.skyScenario;
      int keep_CurrentLayer_id = CurrentLayer_id;

      changeCurrentLayerTo(LAYER_windspd.id);

      if (FrameVariation == 2) {
        this.skyScenario = 1;
        this.plotHourly(0, -450 * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));
      }

      this.skyScenario = 4;
      this.plotHourly(0, ((FrameVariation == 2) ? -150 : -150) * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

      if (FrameVariation == 2) {
        this.skyScenario = 3;
        this.plotHourly(0, 150 * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));
      }

      this.skyScenario = 2;
      this.plotHourly(0, ((FrameVariation == 2) ? 450 : 150) * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

      this.skyScenario = keep_skyScenario;
      changeCurrentLayerTo(keep_CurrentLayer_id);
    }


    if (this.plotSetup == 7) {
      int keep_CurrentLayer_id = CurrentLayer_id;

      if (FrameVariation == 2) {
        changeCurrentLayerTo(LAYER_pressure.id);
        this.plotHourly(0, -450 * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

        changeCurrentLayerTo(LAYER_windspd.id);
        this.plotHourly(0, -150 * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));
      }

      changeCurrentLayerTo(LAYER_relhum.id);
      this.plotHourly(0, ((FrameVariation == 2) ? 150 : -150) * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

      changeCurrentLayerTo(LAYER_drybulb.id);
      this.plotHourly(0, ((FrameVariation == 2) ? 450 : 150) * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

      changeCurrentLayerTo(keep_CurrentLayer_id);
    }


    if (this.plotSetup == 8) {
      int keep_CurrentLayer_id = CurrentLayer_id;

      this.PlotImpacts = PlotImpacts_GLOBAL_PASSIVE;
      this.plotImpact(0, ((FrameVariation == 2) ? -450 : -150) * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

      this.PlotImpacts = PlotImpacts_SUNPATH_PASSIVE;
      this.plotImpact(0, ((FrameVariation == 2) ? -150 : 150) * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

      if (FrameVariation == 2) {
        changeCurrentLayerTo(LAYER_dirnorrad.id);
        this.plotHourly(0, 150 * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));

        changeCurrentLayerTo(LAYER_difhorrad.id);
        this.plotHourly(0, 450 * this.view_S, (100.0 * this.U_scale * this.view_S), (-1.0 * this.V_scale * this.view_S));
      }

      changeCurrentLayerTo(keep_CurrentLayer_id);
    }
  }


  float prev_ImageScale = 1;

  void drawView () {

    cursor(WAIT);


    if (this.update) {

      if (this.record_PDF) this.ImageScale = 1;
      else if (this.record_IMG) this.ImageScale = 2;
      else this.ImageScale = 1;

      if(prev_ImageScale != this.ImageScale) {
        prev_ImageScale = this.ImageScale;

        // we need to redraw these due to gl context lost
        WORLD.revise();
        WIN3D.revise();
        STUDY.revise();
        ROLLOUT.revise();
        UI_menuBar.revise();
        UI_toolBar.revise();
        UI_caseBar.revise();
        UI_commandBar.revise();
      }

      //////////////////////////////////
      this.dX *= this.ImageScale;
      this.dY *= this.ImageScale;
      this.T_scale *= this.ImageScale;
      //////////////////////////////////

      if (this.record_PDF) {
        println("PDF:begin");
        this.graphics = createGraphics(this.dX, this.dY, PDF, MAKE_Filename(createStamp(1, CLASS_STAMP)) + ".pdf");
        beginRecord(this.graphics);
      } else if (this.ImageScale != 1) {
        println("IMG:high-res");
        this.graphics = createGraphics(this.dX, this.dY, P2D);
        this.graphics.beginDraw();
      } else {
        this.graphics.beginDraw();
      }

      DrawnFrame += 1;
      //println("frame:", DrawnFrame);

      if (DevelopData_update) {
        if (CurrentLayer_id == LAYER_developed.id) {
          SOLARCHVISION_postProcess_developDATA(CurrentDataSource);

        }
      }


      this.view_S = (this.dX / 2100.0);
      this.U_scale = 18.0 / float(this.j_End - this.j_Start);


      this.position_X = -0.333 * this.dX;

      this.position_Y = 1.0 * this.dY;


      this.graphics.background(255);

      this.graphics.blendMode(BLEND);

      this.graphics.strokeJoin(ROUND);

      this.graphics.textFont(SOLARCHVISION_font);

      this.graphics.strokeWeight(0);

      //this.graphics.translate(this.position_X * -0.25, this.position_Y * 0.5);
      this.graphics.translate(this.position_X * -0.425, this.position_Y * 0.5);

      this.setupPlot();

      //this.graphics.translate(this.position_X * 0.25, this.position_Y * 0.5);
      this.graphics.translate(this.position_X * 0.425, this.position_Y * 0.5);

      this.graphics.strokeWeight(this.T_scale * 1);

      this.graphics.stroke(63);
      this.graphics.fill(63);
      this.graphics.textAlign(CENTER, CENTER);

      String txt = "SOLARCHVISION post-processing";

      if (CurrentDataSource == dataID_CLIMATE_TMYEPW) txt += " based on typical-year data for Building Energy Simulation";  //"(TMYEPW - U.S. Department of Energy)";
      if (CurrentDataSource == dataID_CLIMATE_CWEEDS) txt += " based on long-term Canadian Weather Energy and Engineering Datasets (CWEEDS - Environment and Climate Change Canada)";
      if (CurrentDataSource == dataID_CLIMATE_CLMREC) txt += " based on Environment and Climate Change Canada's Climate website";
      if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) txt += " based on the North American Ensemble Forecast System (NAEFS - Environment and Climate Change Canada)";
      if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) txt += " based on real-time Surface Weather Observation (SWOB - Environment and Climate Change Canada)";

      //txt += ", www.solarchvision.com";

      this.graphics.textSize(this.dX * 0.01);
      ///this.graphics.text(txt, this.dX * 0.55, this.dY * -0.1666 / this.view_R, 0);

      if (this.record_PDF) {
        endRecord();

        String myFile = MAKE_Filename(createStamp(0, CLASS_STAMP)) + ".pdf";
        println("File created:" + myFile);
      } else {
        this.graphics.endDraw();

        if ((this.record_IMG) || (this.record_AUTO)) {
          String myFile = MAKE_Filename(createStamp(1, CLASS_STAMP)) + ".jpg";
          this.graphics.save(myFile);
          println("File created:" + myFile);
        }

        imageMode(CORNER);
        image(this.graphics, this.cX, this.cY, this.dX / this.ImageScale, this.dY / this.ImageScale);
      }

      //////////////////////////////////
      this.dX /= this.ImageScale;
      this.dY /= this.ImageScale;
      this.T_scale /= this.ImageScale;
      //////////////////////////////////

      if ((this.ImageScale != 1) || (this.record_PDF)) {
        this.graphics = createGraphics(this.dX, this.dY, P2D);
        this.updated(); //1;
      } else {
        this.updated();
      }


      if ((this.record_IMG) || (this.record_AUTO == false)) this.record_IMG = false;
    }

    this.export_info_node = false;
    this.export_info_norm = false;
    this.export_info_prob = false;

    cursor(ARROW);
  }


  void refreshDateTabs () {
    if ((CurrentDataSource == dataID_CLIMATE_CWEEDS) ||
        (CurrentDataSource == dataID_CLIMATE_CLMREC) ||
        (CurrentDataSource == dataID_CLIMATE_TMYEPW)) {

      if (this.perDays == 1) {
        this.perDays = int(365 / float(this.j_End - this.j_Start));
      } else {
        this.perDays = 1;
      }
    }
    if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
      this.perDays = 1;
    }
    if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
      if (this.perDays == 1) {
        this.perDays = int(ENSEMBLE_OBSERVED_maxDays / float(this.j_End - this.j_Start));
      } else {
        this.perDays = 1;
      }
    }
  }



  void plotImpact (float x_Plot, float y_Plot, float sx_Plot, float sy_Plot) {

    this.graphics.pushMatrix();
    this.graphics.translate(x_Plot, y_Plot);

    float keep_STUDY_perDays = this.perDays;
    int keep_STUDY_joinDays = this.joinDays;

    if ((CurrentDataSource == dataID_ENSEMBLE_FORECAST) ||
        (CurrentDataSource == dataID_ENSEMBLE_OBSERVED)) {

      this.perDays = 1;
      this.joinDays = 1;
    }

    int[] startK_endK = get_startK_endK();
    int start_k = startK_endK[0];
    int end_k = startK_endK[1];
    int count_k = 1 + end_k - start_k;
    if (count_k < 0) count_k = 0;


    if ((this.PlotImpacts == PlotImpacts_WIND_ACTIVE) || (this.PlotImpacts == PlotImpacts_WIND_PASSIVE)) {

      allWindRoses.resize_Image_array();

      int RES = allWindRoses.RES;

      allWindRoses.renderedRES = RES;

      if (this.PlotImpacts == PlotImpacts_WIND_ACTIVE) this.Impact_TYPE = Impact_ACTIVE;
      if (this.PlotImpacts == PlotImpacts_WIND_PASSIVE) this.Impact_TYPE = Impact_PASSIVE;

      float Pa = FLOAT_undefined;
      float Pb = FLOAT_undefined;
      float Pc = FLOAT_undefined;

      float[] values_W_dir;
      float[] values_W_spd;
      float[] values_W_tmp;
      values_W_dir = new float [count_k];
      values_W_spd = new float [count_k];
      values_W_tmp = new float [count_k];

      for (int k = 0; k < count_k; k++) {
        values_W_dir[k] = FLOAT_undefined;
        values_W_spd[k] = FLOAT_undefined;
        values_W_tmp[k] = FLOAT_undefined;
      }

      int PAL_type = 0;
      int PAL_direction = 1;

      if (this.Impact_TYPE == Impact_ACTIVE) {
        PAL_type = this.ACTIVE_pallet_CLR;
        PAL_direction = this.ACTIVE_pallet_DIR;
      }
      if (this.Impact_TYPE == Impact_PASSIVE) {
        //PAL_type = this.ACTIVE_pallet_CLR; PAL_direction = this.ACTIVE_pallet_DIR;
        PAL_type = 12;
        PAL_direction = -1;
      }

      float PAL_multiplier = 1;
      if (this.Impact_TYPE == Impact_ACTIVE) PAL_multiplier = 1.0;
      if (this.Impact_TYPE == Impact_PASSIVE) PAL_multiplier = 1.0 / 30.0;

      for (int j = this.j_Start; j < this.j_End; j++) {

        PGraphics WIND_graphics = createGraphics(RES, RES);
        WIND_graphics.beginDraw();
        //WIND_graphics.background(255);
        WIND_graphics.translate(0.5 * RES, 0.5 * RES);

        for (int j_ADD = 0; j_ADD < this.joinDays; j_ADD++) {
          for (int i = 0; i < 24; i++) {
            if (this.isInHourlyRange(i)) {

              for (int k = 0; k < count_k; k++) {

                values_W_dir[k] = FLOAT_undefined;
                values_W_spd[k] = FLOAT_undefined;
                values_W_tmp[k] = FLOAT_undefined;

                int _plot = 1;

                if (_plot == 1) {

                  int now_k = k + start_k;
                  int now_i = i;
                  int now_j = int(j * this.perDays + (j_ADD - int(funcs.roundTo(0.5 * this.joinDays, 1))) + TIME.beginDay + 365) % 365;

                  if (now_j >= 365) {
                    now_j = now_j % 365;
                  }
                  if (now_j < 0) {
                    now_j = (now_j + 365) % 365;
                  }

                  Pa = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_winddir.id);
                  Pb = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_windspd.id);
                  Pc = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_drybulb.id);

                  if (is_undefined(Pa) || is_undefined(Pb) || is_undefined(Pc)) {
                    values_W_dir[k] = FLOAT_undefined;
                    values_W_spd[k] = FLOAT_undefined;
                    values_W_tmp[k] = FLOAT_undefined;
                  } else {
                    int memberCount = SOLARCHVISION_filter(CurrentDataSource, LAYER_cloudcover.id, this.filter, this.skyScenario, now_i, now_j, now_k);

                    if ((CurrentDataSource == dataID_ENSEMBLE_FORECAST) && (ENSEMBLE_FORECAST_flags[now_i][now_j][LAYER_winddir.id][now_k] == false)) memberCount = 0;

                    if (memberCount == 1) {

                      values_W_dir[k] = Pa;
                      values_W_spd[k] = Pb;
                      values_W_tmp[k] = Pc;

                      float T = values_W_tmp[k];
                      float teta = values_W_dir[k];
                      float D_teta = 15;
                      float R = (0.5 * RES) * (LAYER_windspd.V_scale / 2.0) * (values_W_spd[k] / 50.0);

                      float R_in = 0; //0.75 * R;
                      float x1 = R_in * funcs.cos_ang(90 - (teta - 0.5 * D_teta));
                      float y1 = R_in * -funcs.sin_ang(90 - (teta - 0.5 * D_teta));
                      float x2 = R_in * funcs.cos_ang(90 - (teta + 0.5 * D_teta));
                      float y2 = R_in * -funcs.sin_ang(90 - (teta + 0.5 * D_teta));

                      float x4 = R * funcs.cos_ang(90 - (teta - 0.5 * D_teta));
                      float y4 = R * -funcs.sin_ang(90 - (teta - 0.5 * D_teta));
                      float x3 = R * funcs.cos_ang(90 - (teta + 0.5 * D_teta));
                      float y3 = R * -funcs.sin_ang(90 - (teta + 0.5 * D_teta));

                      float _u = 0;

                      if (this.Impact_TYPE == Impact_ACTIVE) {

                        float _s = (this.O_scale / 100) * 255 / (0.333 * count_k);

                        if (this.skyScenario > 1) _s *= 3; // to improve visibility of those cases.

                        _s /= float(this.joinDays);

                        if (_s < 10) _s = 10;

                        WIND_graphics.stroke(0, _s);
                        WIND_graphics.fill(0, _s);

                        WIND_graphics.strokeWeight(this.T_scale * 0);
                      }
                      if (this.Impact_TYPE == Impact_PASSIVE) {
                        _u = 0.5 + 0.5 * (PAL_multiplier * T);

                        if (PAL_direction == -1) _u = 1 - _u;
                        if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
                        if (PAL_direction == 2) _u =  0.5 * _u;

                        float[] COL = PAINT.getColorStyle(PAL_type, _u);

                        WIND_graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

                        WIND_graphics.strokeWeight(this.T_scale * 2);
                        WIND_graphics.noFill();
                      }

                      WIND_graphics.quad(x1, y1, x2, y2, x3, y3, x4, y4);
                    }
                  }
                }
              }
            }
          }
        }
        WIND_graphics.endDraw();
        allWindRoses.Image[j + 1] = WIND_graphics;
      }




      PGraphics total_WIND_graphics = createGraphics(RES, RES);
      total_WIND_graphics.beginDraw();
      //total_WIND_graphics.background(255);
      total_WIND_graphics.translate(0.5 * RES, 0.5 * RES);

      for (int j = this.j_Start; j < this.j_End; j++) {
        for (int j_ADD = 0; j_ADD < this.joinDays; j_ADD++) {
          for (int i = 0; i < 24; i++) {
            if (this.isInHourlyRange(i)) {

              for (int k = 0; k < count_k; k++) {

                values_W_dir[k] = FLOAT_undefined;
                values_W_spd[k] = FLOAT_undefined;
                values_W_tmp[k] = FLOAT_undefined;

                int _plot = 1;

                if (_plot == 1) {

                  int now_k = k + start_k;
                  int now_i = i;
                  int now_j = int(j * this.perDays + (j_ADD - int(funcs.roundTo(0.5 * this.joinDays, 1))) + TIME.beginDay + 365) % 365;

                  if (now_j >= 365) {
                    now_j = now_j % 365;
                  }
                  if (now_j < 0) {
                    now_j = (now_j + 365) % 365;
                  }

                  Pa = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_winddir.id);
                  Pb = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_windspd.id);
                  Pc = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_drybulb.id);

                  if (is_undefined(Pa) || is_undefined(Pb) || is_undefined(Pc)) {
                    values_W_dir[k] = FLOAT_undefined;
                    values_W_spd[k] = FLOAT_undefined;
                    values_W_tmp[k] = FLOAT_undefined;
                  } else {
                    int memberCount = SOLARCHVISION_filter(CurrentDataSource, LAYER_cloudcover.id, this.filter, this.skyScenario, now_i, now_j, now_k);

                    if ((CurrentDataSource == dataID_ENSEMBLE_FORECAST) && (ENSEMBLE_FORECAST_flags[now_i][now_j][LAYER_winddir.id][now_k] == false)) memberCount = 0;

                    if (memberCount == 1) {

                      values_W_dir[k] = Pa;
                      values_W_spd[k] = Pb;
                      values_W_tmp[k] = Pc;

                      float T = values_W_tmp[k];
                      float teta = values_W_dir[k];
                      float D_teta = 15;
                      float R = (0.5 * RES) * (LAYER_windspd.V_scale / 2.0) * (values_W_spd[k] / 50.0);

                      float R_in = 0; //0.75 * R;
                      float x1 = R_in * funcs.cos_ang(90 - (teta - 0.5 * D_teta));
                      float y1 = R_in * -funcs.sin_ang(90 - (teta - 0.5 * D_teta));
                      float x2 = R_in * funcs.cos_ang(90 - (teta + 0.5 * D_teta));
                      float y2 = R_in * -funcs.sin_ang(90 - (teta + 0.5 * D_teta));

                      float x4 = R * funcs.cos_ang(90 - (teta - 0.5 * D_teta));
                      float y4 = R * -funcs.sin_ang(90 - (teta - 0.5 * D_teta));
                      float x3 = R * funcs.cos_ang(90 - (teta + 0.5 * D_teta));
                      float y3 = R * -funcs.sin_ang(90 - (teta + 0.5 * D_teta));

                      float _u = 0;

                      if (this.Impact_TYPE == Impact_ACTIVE) {

                        float _s = (this.O_scale / 100) * 255 / (0.333 * count_k) / (this.j_End - this.j_Start);

                        if (this.skyScenario > 1) _s *= 3; // to improve visibility of those cases.

                        _s /= float(this.joinDays);

                        if (_s < 10) _s = 10;

                        total_WIND_graphics.stroke(0, _s);
                        total_WIND_graphics.fill(0, _s);

                        total_WIND_graphics.strokeWeight(this.T_scale * 0);
                      }
                      if (this.Impact_TYPE == Impact_PASSIVE) {
                        _u = 0.5 + 0.5 * (PAL_multiplier * T);

                        if (PAL_direction == -1) _u = 1 - _u;
                        if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
                        if (PAL_direction == 2) _u =  0.5 * _u;

                        float[] COL = PAINT.getColorStyle(PAL_type, _u);
                        total_WIND_graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

                        total_WIND_graphics.strokeWeight(this.T_scale * 2);
                        total_WIND_graphics.noFill();
                      }

                      total_WIND_graphics.quad(x1, y1, x2, y2, x3, y3, x4, y4);
                    }
                  }
                }
              }
            }
          }
        }
      }
      total_WIND_graphics.endDraw();
      allWindRoses.Image[0] = total_WIND_graphics;

      for (int j = this.j_Start - 1; j < this.j_End; j++) {
        if ((j != -1) || (this.impact_summary)) {
          this.graphics.strokeWeight(this.T_scale * 0);
          this.graphics.stroke(223);
          this.graphics.fill(223);
          this.graphics.rect((j + this.rect_offset_x - 100 * this.rect_scale) * sx_Plot, (-100 * this.rect_scale) * sx_Plot, (200 * this.rect_scale) * sx_Plot, (200 * this.rect_scale) * sx_Plot);

          this.graphics.strokeWeight(this.T_scale * 2);
          this.graphics.stroke(255);
          this.graphics.noFill();
          this.graphics.rect((j + this.rect_offset_x - 100 * this.rect_scale) * sx_Plot, (-100 * this.rect_scale) * sx_Plot, (200 * this.rect_scale) * sx_Plot, (200 * this.rect_scale) * sx_Plot);

          this.graphics.imageMode(CENTER);
          this.graphics.image(allWindRoses.Image[j + 1], (j + 100 * this.rect_scale) * sx_Plot, 0, int((180 * this.rect_scale) * sx_Plot), int((180 * this.rect_scale) * sx_Plot));
        }
      }

      this.drawPositionGrid(x_Plot, y_Plot, sx_Plot, sy_Plot, 0);

      if (this.impact_summary) {
        int j = -1; // << to put the summary graph before the daily graphs

        int keep_STUDY_j_Start = this.j_Start;
        int keep_STUDY_j_End = this.j_End;
        this.j_Start = j;
        this.j_End = j + 1;
        this.drawPositionGrid(x_Plot, y_Plot, sx_Plot, sy_Plot, 0);
        this.j_Start = keep_STUDY_j_Start;
        this.j_End = keep_STUDY_j_End;

        this.graphics.strokeWeight(this.T_scale * 2);
        this.graphics.stroke(0);
        this.graphics.noFill();
        this.graphics.rect((j + this.rect_offset_x - 100 * this.rect_scale) * sx_Plot, (-100 * this.rect_scale) * sx_Plot, (200 * this.rect_scale) * sx_Plot, (200 * this.rect_scale) * sx_Plot);
      }

      if (this.Impact_TYPE != Impact_ACTIVE) {

        float pal_length = 400;
        float pal_ox = 700;
        float pal_oy = 110;
        for (int q = 0; q < 11; q++) {
          float _u = 0;

          if (this.Impact_TYPE == Impact_PASSIVE) _u = 0.1 * q;

          if (PAL_direction == -1) _u = 1 - _u;
          if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
          if (PAL_direction == 2) _u =  0.5 * _u;

          float[] COL = PAINT.getColorStyle(PAL_type, _u);
          this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
          this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

          this.graphics.strokeWeight(0);
          this.graphics.rect((pal_ox + q * (pal_length / 11.0)) * this.view_S, pal_oy * this.view_S, (pal_length / 11.0) * this.view_S, 20 * this.view_S);

          if (COL[1] + COL[2] + COL[3] > 1.75 * 255) {
            this.graphics.stroke(127);
            this.graphics.fill(127);
            this.graphics.strokeWeight(0);
          } else {
            this.graphics.stroke(255);
            this.graphics.fill(255);
            this.graphics.strokeWeight(2);
          }

          this.graphics.textSize(15.0 * this.view_S);
          this.graphics.textAlign(CENTER, CENTER);

          if (this.Impact_TYPE == Impact_PASSIVE) this.graphics.text(nf(0.2 * (q - 5) / PAL_multiplier, 1, 1), (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S, (10 + pal_oy - 0.05 * 20) * this.view_S);
        }
      }


      if (this.PrintTtitle) {

        this.graphics.stroke(0);
        this.graphics.fill(0);
        this.graphics.strokeWeight(this.T_scale * 0);

        this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
        this.graphics.textAlign(RIGHT, TOP);
        if (CurrentDataSource == dataID_CLIMATE_CWEEDS) this.graphics.text(("[" + String.valueOf(start_k + CLIMATE_CWEEDS_start) + "-" + String.valueOf(end_k + CLIMATE_CWEEDS_start) + "] "), 0, -1.2 * sx_Plot / this.U_scale);
        if (CurrentDataSource == dataID_CLIMATE_CLMREC) this.graphics.text(("[" + String.valueOf(start_k + CLIMATE_CLMREC_start) + "-" + String.valueOf(end_k + CLIMATE_CLMREC_start) + "] "), 0, -1.2 * sx_Plot / this.U_scale);
        if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) this.graphics.text(("[" + String.valueOf(start_k + ENSEMBLE_FORECAST_start) + "-" + String.valueOf(end_k + ENSEMBLE_FORECAST_start) + "] "), 0, -1.2 * sx_Plot / this.U_scale);

        this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
        this.graphics.textAlign(LEFT, TOP);
        if (this.Impact_TYPE == Impact_ACTIVE) {
          this.graphics.text(("Wind direction and speed"), 0, 1.1 * sx_Plot / this.U_scale);
          //?? French
        }
        if (this.Impact_TYPE == Impact_PASSIVE) {
          this.graphics.text(("Wind direction and speed with air temperature"), 0, 1.1 * sx_Plot / this.U_scale);
          //?? French
        }
      }

      if (allWindRoses.displayImage) {
        SOLARCHVISION_view_changed();
      }
    }




    if ((this.PlotImpacts == PlotImpacts_URBAN_ACTIVE) || (this.PlotImpacts == PlotImpacts_URBAN_PASSIVE)) {

      if (this.Impacts_update) {

        allSolarImpacts.calculate_Impact_CurrentPreBaked();

        int RES1 = allSolarImpacts.RES1;
        int RES2 = allSolarImpacts.RES2;

        if (this.PlotImpacts == PlotImpacts_URBAN_ACTIVE) this.Impact_TYPE = Impact_ACTIVE;
        if (this.PlotImpacts == PlotImpacts_URBAN_PASSIVE) this.Impact_TYPE = Impact_PASSIVE;

        float Pa = FLOAT_undefined;
        float Pb = FLOAT_undefined;
        float Pc = FLOAT_undefined;
        float Pd = FLOAT_undefined;

        float values_R_dir;
        float values_R_dif;

        float values_E_dir;
        float values_E_dif;

        int now_k = 0;
        int now_i = 0;
        int now_j = 0;

        int PAL_type = 0;
        int PAL_direction = 1;
        float PAL_multiplier = 1;

        if (this.Impact_TYPE == Impact_ACTIVE) {
          PAL_type = allFaces.ACTIVE_pallet_CLR;
          PAL_direction = allFaces.ACTIVE_pallet_DIR;
          PAL_multiplier = allFaces.ACTIVE_pallet_MLT;
        }
        if (this.Impact_TYPE == Impact_PASSIVE) {
          PAL_type = allFaces.PASSIVE_pallet_CLR;
          PAL_direction = allFaces.PASSIVE_pallet_DIR;
          PAL_multiplier = allFaces.PASSIVE_pallet_MLT;
        }

        int l = this.ImpactLayer;

        for (int j = this.j_Start; j < this.j_End; j++) {

          now_j = (j * int(this.perDays) + TIME.beginDay + 365) % 365;

          if (now_j >= 365) {
            now_j = now_j % 365;
          }
          if (now_j < 0) {
            now_j = (now_j + 365) % 365;
          }


          this.graphics.strokeWeight(this.T_scale * 0);
          this.graphics.stroke(223);
          this.graphics.fill(223);
          this.graphics.rect((j + this.rect_offset_x - 100 * this.rect_scale) * sx_Plot, (-100 * this.rect_scale) * sx_Plot, (200 * this.rect_scale) * sx_Plot, (200 * this.rect_scale) * sx_Plot);

          this.graphics.strokeWeight(this.T_scale * 2);
          this.graphics.stroke(255);
          this.graphics.noFill();
          this.graphics.rect((j + this.rect_offset_x - 100 * this.rect_scale) * sx_Plot, (-100 * this.rect_scale) * sx_Plot, (200 * this.rect_scale) * sx_Plot, (200 * this.rect_scale) * sx_Plot);

          this.graphics.imageMode(CENTER);
          this.graphics.image(allSolarImpacts.Image[this.Impact_TYPE][j + 1], (j + 100 * this.rect_scale) * sx_Plot, 0, int((180 * this.rect_scale) * sx_Plot), int((180 * this.rect_scale) * sx_Plot));

          this.graphics.stroke(0);
          this.graphics.fill(0);
          this.graphics.textAlign(CENTER, CENTER);
          this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);

          String scenario_text = "";
          //if (CurrentDataSource == dataID_CLIMATE_CWEEDS) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_CWEEDS_start - 1, 0);
          //if (CurrentDataSource == dataID_CLIMATE_CLMREC) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_CLMREC_start - 1, 0);
          //if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) scenario_text += "Member: " + nf(Normals_COL_N[l], 0);
          this.graphics.text(scenario_text, (j - ((0 - 12) / 24.0)) * sx_Plot, 0.9 * sx_Plot / this.U_scale);
        }

        ////////////////////////////
        this.impact_summary = true;
        ////////////////////////////

        if (this.impact_summary) {
          int j = -1; // << to put the summary graph before the daily graphs

          this.graphics.strokeWeight(this.T_scale * 0);
          this.graphics.stroke(223);
          this.graphics.fill(223);
          //this.graphics.rect((j + this.rect_offset_x - 100 * this.rect_scale) * sx_Plot, (-100 * this.rect_scale) * sx_Plot - (p * sx_Plot / this.U_scale), (200 * this.rect_scale) * sx_Plot, (200 * this.rect_scale) * sx_Plot);

          this.graphics.strokeWeight(this.T_scale * 2);
          this.graphics.stroke(0);
          this.graphics.noFill();
          //this.graphics.rect((j + this.rect_offset_x - 100 * this.rect_scale) * sx_Plot, (-100 * this.rect_scale) * sx_Plot - (p * sx_Plot / this.U_scale), (200 * this.rect_scale) * sx_Plot, (200 * this.rect_scale) * sx_Plot);

          this.graphics.imageMode(CENTER);
          //this.graphics.image(allSolarImpacts.Image[this.Impact_TYPE][j + 1], (j + 100 * this.rect_scale) * sx_Plot, - (p * sx_Plot / this.U_scale), int((180 * this.rect_scale) * sx_Plot), int((180 * this.rect_scale) * sx_Plot));

          this.graphics.stroke(0);
          this.graphics.fill(0);
          this.graphics.textAlign(CENTER, CENTER);
          this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
        }

        String scenario_text = "";
        //if (CurrentDataSource == dataID_CLIMATE_CWEEDS) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_CWEEDS_start - 1, 0);
        //if (CurrentDataSource == dataID_CLIMATE_CLMREC) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_CLMREC_start - 1, 0);
        //if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) scenario_text += "Member: " + nf(Normals_COL_N[l], 0);
        this.graphics.text(scenario_text, ((this.j_Start - 1) - ((0 - 12) / 24.0)) * sx_Plot, 0.9 * sx_Plot / this.U_scale);

        this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
        this.graphics.textAlign(RIGHT, CENTER);
        this.graphics.stroke(0);
        this.graphics.fill(0);
        this.graphics.strokeWeight(0);

        this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
        this.graphics.textAlign(RIGHT, CENTER);
        this.graphics.stroke(0);
        this.graphics.fill(0);
        this.graphics.strokeWeight(0);

        if (this.Impact_TYPE == Impact_ACTIVE) {
          this.graphics.text(STAT_N_Title[l], -0.3 * sx_Plot / this.U_scale, 1.2 * sx_Plot / this.U_scale);
        }
        if (this.Impact_TYPE == Impact_PASSIVE) {
          this.graphics.text(STAT_N_Title[STAT_reverse_N[l]], -0.3 * sx_Plot / this.U_scale, 1.2 * sx_Plot / this.U_scale);
        }
        //?? French


        float pal_length = 400;
        float pal_ox = 700;
        float pal_oy = 110;
        for (int q = 0; q < 11; q++) {
          float _u = 0;

          if (this.Impact_TYPE == Impact_ACTIVE) _u = 0.1 * q;
          if (this.Impact_TYPE == Impact_PASSIVE) _u = 0.2 * q - 0.5;

          if (PAL_direction == -1) _u = 1 - _u;
          if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
          if (PAL_direction == 2) _u =  0.5 * _u;

          float[] COL = PAINT.getColorStyle(PAL_type, _u);
          this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
          this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

          this.graphics.strokeWeight(0);
          this.graphics.rect((pal_ox + q * (pal_length / 11.0)) * this.view_S, pal_oy * this.view_S, (pal_length / 11.0) * this.view_S, 20 * this.view_S);

          if (COL[1] + COL[2] + COL[3] > 1.75 * 255) {
            this.graphics.stroke(127);
            this.graphics.fill(127);
            this.graphics.strokeWeight(0);
          } else {
            this.graphics.stroke(255);
            this.graphics.fill(255);
            this.graphics.strokeWeight(2);
          }

          this.graphics.textSize(15.0 * this.view_S);
          this.graphics.textAlign(CENTER, CENTER);
          if (this.Impact_TYPE == Impact_ACTIVE) this.graphics.text(nf((funcs.roundTo(0.1 * q / PAL_multiplier, 0.1)), 1, 1), (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S, (10 + pal_oy - 0.05 * 20) * this.view_S);
          if (this.Impact_TYPE == Impact_PASSIVE) this.graphics.text(nf(int(funcs.roundTo(0.4 * (q - 5) / PAL_multiplier, 1)), 1), (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S, (10 + pal_oy - 0.05 * 20) * this.view_S);
        }

        if (this.PrintTtitle) {

          this.graphics.stroke(0);
          this.graphics.fill(0);
          this.graphics.strokeWeight(this.T_scale * 0);

          this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
          this.graphics.textAlign(RIGHT, TOP);
          if (CurrentDataSource == dataID_CLIMATE_CWEEDS) this.graphics.text(("[" + String.valueOf(start_k + CLIMATE_CWEEDS_start) + "-" + String.valueOf(end_k + CLIMATE_CWEEDS_start) + "] "), 0, -1.2 * sx_Plot / this.U_scale);
          if (CurrentDataSource == dataID_CLIMATE_CLMREC) this.graphics.text(("[" + String.valueOf(start_k + CLIMATE_CLMREC_start) + "-" + String.valueOf(end_k + CLIMATE_CLMREC_start) + "] "), 0, -1.2 * sx_Plot / this.U_scale);
          if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) this.graphics.text(("[" + String.valueOf(start_k + ENSEMBLE_FORECAST_start) + "-" + String.valueOf(end_k + ENSEMBLE_FORECAST_start) + "] "), 0, -1.2 * sx_Plot / this.U_scale);


          String Model_Description = "";


          this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
          this.graphics.textAlign(LEFT, TOP);
          if (this.Impact_TYPE == Impact_ACTIVE) {
            this.graphics.text((Model_Description + "Analysis of Active Potentials (kW/m²)"), 0, 1.1 * sx_Plot / this.U_scale);
            //?? French
          }
          if (this.Impact_TYPE == Impact_PASSIVE) {
            this.graphics.text((Model_Description + "Analysis of Passive Potentials (%kW°C/m²)"), 0, 1.1 * sx_Plot / this.U_scale);
            //?? French
          }
        }
      }

      if (allSolarImpacts.displayImage) {
        SOLARCHVISION_view_changed();
      }

    }



    if ((this.PlotImpacts == PlotImpacts_GLOBAL_ACTIVE) || (this.PlotImpacts == PlotImpacts_GLOBAL_PASSIVE)) {

      if (GlobalSolar_rebuild_array) {
        GlobalSolar_resize_array();
      }

      if (this.PlotImpacts == PlotImpacts_GLOBAL_ACTIVE) this.Impact_TYPE = Impact_ACTIVE;
      if (this.PlotImpacts == PlotImpacts_GLOBAL_PASSIVE) this.Impact_TYPE = Impact_PASSIVE;

      float Pa = FLOAT_undefined;
      float Pb = FLOAT_undefined;
      float Pc = FLOAT_undefined;
      float Pd = FLOAT_undefined;

      float values_R_dir;
      float values_R_dif;
      float values_E_dir;
      float values_E_dif;

      int now_k = 0;
      int now_i = 0;
      int now_j = 0;

      int PAL_type = 0;
      int PAL_direction = 1;

      if (this.Impact_TYPE == Impact_ACTIVE) {
        PAL_type = this.ACTIVE_pallet_CLR;
        PAL_direction = this.ACTIVE_pallet_DIR;
      }
      if (this.Impact_TYPE == Impact_PASSIVE) {
        PAL_type = this.PASSIVE_pallet_CLR;
        PAL_direction = this.PASSIVE_pallet_DIR;
      }

      float PAL_multiplier = 1;
      if (this.Impact_TYPE == Impact_ACTIVE) PAL_multiplier = this.ACTIVE_pallet_MLT;
      if (this.Impact_TYPE == Impact_PASSIVE) PAL_multiplier = this.PASSIVE_pallet_MLT;


      int l = this.ImpactLayer;

      float[][] TOTALvaluesSUM_RAD = new float [1 + int(90 / Sky3D.stp_slp)][1 + int(360 / Sky3D.stp_dir)];
      float[][] TOTALvaluesSUM_EFF_P = new float [1 + int(90 / Sky3D.stp_slp)][1 + int(360 / Sky3D.stp_dir)];
      float[][] TOTALvaluesSUM_EFF_N = new float [1 + int(90 / Sky3D.stp_slp)][1 + int(360 / Sky3D.stp_dir)];
      int[][] TOTALvaluesNUM = new int [1 + int(90 / Sky3D.stp_slp)][1 + int(360 / Sky3D.stp_dir)];

      for (int a = 0; a <= int (90 / Sky3D.stp_slp); a++) {
        for (int b = 0; b < int (360 / Sky3D.stp_dir); b++) {
          TOTALvaluesSUM_RAD[a][b] = FLOAT_undefined;
          TOTALvaluesSUM_EFF_P[a][b] = FLOAT_undefined;
          TOTALvaluesSUM_EFF_N[a][b] = FLOAT_undefined;
          TOTALvaluesNUM[a][b] = 0;
        }
      }

      for (int j = this.j_Start; j < this.j_End; j++) {

        now_j = (j * int(this.perDays) + TIME.beginDay + 365) % 365;

        if (now_j >= 365) {
          now_j = now_j % 365;
        }
        if (now_j < 0) {
          now_j = (now_j + 365) % 365;
        }

        float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);

        int[] Normals_COL_N;
        Normals_COL_N = new int [9];
        Normals_COL_N = SOLARCHVISION_PROCESS_DAILY_SCENARIOS(start_k, end_k, j, DATE_ANGLE);

        for (int nk = Normals_COL_N[l]; nk <= Normals_COL_N[l]; nk++) {
          if (nk != -1) {
            int k = int(nk / this.joinDays);
            int j_ADD = nk % this.joinDays;

            for (int a = 0; a <= int (90 / Sky3D.stp_slp); a++) {
              float Alpha = a * Sky3D.stp_slp;
              for (int b = 0; b < int (360 / Sky3D.stp_dir); b++) {
                float Beta = b * Sky3D.stp_dir;

                float valuesSUM_RAD = 0;
                float valuesSUM_EFF_P = 0;
                float valuesSUM_EFF_N = 0;
                int valuesNUM = 0;


                for (int i = 0; i < 24; i++) {
                  if (this.isInHourlyRange(i)) {
                    float HOUR_ANGLE = i;
                    float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);

                    if (SunR[3] > 0) {

                      now_k = k + start_k;
                      now_i = i;
                      now_j = int(j * this.perDays + (j_ADD - int(funcs.roundTo(0.5 * this.joinDays, 1))) + TIME.beginDay + 365) % 365;

                      if (now_j >= 365) {
                        now_j = now_j % 365;
                      }
                      if (now_j < 0) {
                        now_j = (now_j + 365) % 365;
                      }

                      Pa = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_dirnorrad.id);
                      Pb = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_difhorrad.id);
                      Pc = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_direffect.id);
                      Pd = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_difeffect.id);

                      if (is_undefined(Pa) || is_undefined(Pb) || is_undefined(Pc) || is_undefined(Pd)) {
                        values_R_dir = FLOAT_undefined;
                        values_R_dif = FLOAT_undefined;
                        values_E_dir = FLOAT_undefined;
                        values_E_dif = FLOAT_undefined;
                      } else {

                        int memberCount = SOLARCHVISION_filter(CurrentDataSource, LAYER_cloudcover.id, this.filter, this.skyScenario, now_i, now_j, now_k);

                        if (memberCount == 1) {
                          values_R_dir = 0.001 * Pa;
                          values_R_dif = 0.001 * Pb;
                          values_E_dir = 0.001 * Pc;
                          values_E_dif = 0.001 * Pd;

                          if (is_undefined(valuesSUM_RAD)) {
                            valuesSUM_RAD = 0;
                            valuesSUM_EFF_P = 0;
                            valuesSUM_EFF_N = 0;
                            valuesNUM = 0;
                          } else {

                            if (values_E_dir < 0) {
                              valuesSUM_EFF_N += -SOLARCHVISION_SolarAtSurface(SunR[1], SunR[2], SunR[3], values_E_dir, values_E_dif, Alpha, Beta, GlobalAlbedo);
                            } else {
                              valuesSUM_EFF_P += SOLARCHVISION_SolarAtSurface(SunR[1], SunR[2], SunR[3], values_E_dir, values_E_dif, Alpha, Beta, GlobalAlbedo);
                            }

                            valuesSUM_RAD += SOLARCHVISION_SolarAtSurface(SunR[1], SunR[2], SunR[3], values_R_dir, values_R_dif, Alpha, Beta, GlobalAlbedo);

                            valuesNUM += 1;
                          }
                        }
                      }
                    }
                  }
                }


                if (valuesNUM != 0) {
                  //float valuesMUL = funcs.DayTime(STATION.getLatitude(), DATE_ANGLE) / (1.0 * valuesNUM);
                  //float valuesMUL = int(funcs.DayTime(STATION.getLatitude(), DATE_ANGLE)) / (1.0 * valuesNUM);
                  float valuesMUL = funcs.roundTo(funcs.DayTime(STATION.getLatitude(), DATE_ANGLE), 1) / (1.0 * valuesNUM);

                  valuesSUM_RAD *= valuesMUL;
                  valuesSUM_EFF_P *= valuesMUL;
                  valuesSUM_EFF_N *= valuesMUL;

                  if (TOTALvaluesNUM[a][b] == 0) {
                    TOTALvaluesSUM_RAD[a][b] = 0;
                    TOTALvaluesSUM_EFF_P[a][b] = 0;
                    TOTALvaluesSUM_EFF_N[a][b] = 0;
                  }

                  TOTALvaluesSUM_RAD[a][b] += valuesSUM_RAD;
                  TOTALvaluesSUM_EFF_P[a][b] += valuesSUM_EFF_P;
                  TOTALvaluesSUM_EFF_N[a][b] += valuesSUM_EFF_N;
                  TOTALvaluesNUM[a][b] += 1;
                } else {
                  valuesSUM_RAD = FLOAT_undefined;
                  valuesSUM_EFF_P = FLOAT_undefined;
                  valuesSUM_EFF_N = FLOAT_undefined;
                }


                float AVERAGE, PERCENTAGE, COMPARISON;

                AVERAGE = (valuesSUM_EFF_P - valuesSUM_EFF_N);
                if ((valuesSUM_EFF_P + valuesSUM_EFF_N) > 0.00001) PERCENTAGE = (valuesSUM_EFF_P - valuesSUM_EFF_N) / (1.0 * (valuesSUM_EFF_P + valuesSUM_EFF_N));
                else PERCENTAGE = 0.0;
                COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);


                float valuesSUM = FLOAT_undefined;
                if (this.Impact_TYPE == Impact_ACTIVE) valuesSUM = valuesSUM_RAD;
                if (this.Impact_TYPE == Impact_PASSIVE) valuesSUM = COMPARISON;

                //if ((Alpha == 90.0) && (Beta == 0.0)) println("SPHERICAL >> valuesSUM_RAD:", valuesSUM_RAD, "COMPARISON:", COMPARISON);

                if (is_defined(valuesSUM)) {

                  float _u = 0;

                  if (this.Impact_TYPE == Impact_ACTIVE) _u = (0.1 * PAL_multiplier * valuesSUM);
                  if (this.Impact_TYPE == Impact_PASSIVE) _u = 0.5 + 0.5 * (0.1 * PAL_multiplier * valuesSUM);

                  if (PAL_direction == -1) _u = 1 - _u;
                  if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
                  if (PAL_direction == 2) _u =  0.5 * _u;

                  //float[] COL = PAINT.getColorStyle(PAL_type, _u);
                  float[] COL = PAINT.getColorStyle(PAL_type, funcs.roundTo(_u, 0.1));
                  this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
                  this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);


                  this.graphics.strokeWeight(0);

                  float x1 = (j + this.rect_offset_x + (90 - Alpha - 0.5 * Sky3D.stp_slp) * this.rect_scale * (funcs.cos_ang(Beta - 90 - 0.5 * Sky3D.stp_dir))) * sx_Plot;
                  float y1 = (                         -(90 - Alpha - 0.5 * Sky3D.stp_slp) * this.rect_scale * (funcs.sin_ang(Beta - 90 - 0.5 * Sky3D.stp_dir))) * sx_Plot;
                  float x2 = (j + this.rect_offset_x + (90 - Alpha + 0.5 * Sky3D.stp_slp) * this.rect_scale * (funcs.cos_ang(Beta - 90 - 0.5 * Sky3D.stp_dir))) * sx_Plot;
                  float y2 = (                         -(90 - Alpha + 0.5 * Sky3D.stp_slp) * this.rect_scale * (funcs.sin_ang(Beta - 90 - 0.5 * Sky3D.stp_dir))) * sx_Plot;

                  float x3 = (j + this.rect_offset_x + (90 - Alpha + 0.5 * Sky3D.stp_slp) * this.rect_scale * (funcs.cos_ang(Beta - 90 + 0.5 * Sky3D.stp_dir))) * sx_Plot;
                  float y3 = (                         -(90 - Alpha + 0.5 * Sky3D.stp_slp) * this.rect_scale * (funcs.sin_ang(Beta - 90 + 0.5 * Sky3D.stp_dir))) * sx_Plot;
                  float x4 = (j + this.rect_offset_x + (90 - Alpha - 0.5 * Sky3D.stp_slp) * this.rect_scale * (funcs.cos_ang(Beta - 90 + 0.5 * Sky3D.stp_dir))) * sx_Plot;
                  float y4 = (                         -(90 - Alpha - 0.5 * Sky3D.stp_slp) * this.rect_scale * (funcs.sin_ang(Beta - 90 + 0.5 * Sky3D.stp_dir))) * sx_Plot;

                  this.graphics.quad(x1, y1, x2, y2, x3, y3, x4, y4);
                }
              }
            }

            this.graphics.stroke(0);
            this.graphics.fill(0);
            this.graphics.textAlign(CENTER, CENTER);
            this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);

            String scenario_text = "";
            //if (CurrentDataSource == dataID_CLIMATE_CWEEDS) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_CWEEDS_start - 1, 0);
            //if (CurrentDataSource == dataID_CLIMATE_CLMREC) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_CLMREC_start - 1, 0);
            //if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) scenario_text += "Member: " + nf(Normals_COL_N[l], 0);
            this.graphics.text(scenario_text, (j - ((0 - 12) / 24.0)) * sx_Plot, 0.95 * sx_Plot / this.U_scale);
          }
        }
      }



      if (this.impact_summary) {

        int j = -1; // << to put the summary graph before the daily graphs

        for (int a = 0; a <= int (90 / Sky3D.stp_slp); a++) {
          float Alpha = a * Sky3D.stp_slp;
          for (int b = 0; b < int (360 / Sky3D.stp_dir); b++) {
            float Beta = b * Sky3D.stp_dir;

            if (TOTALvaluesNUM[a][b] != 0) {
              TOTALvaluesSUM_RAD[a][b] /= 1.0 * TOTALvaluesNUM[a][b];
              TOTALvaluesSUM_EFF_P[a][b] /= 1.0 * TOTALvaluesNUM[a][b];
              TOTALvaluesSUM_EFF_N[a][b] /= 1.0 * TOTALvaluesNUM[a][b];
            } else {
              TOTALvaluesSUM_RAD[a][b] = FLOAT_undefined;
              TOTALvaluesSUM_EFF_P[a][b] = FLOAT_undefined;
              TOTALvaluesSUM_EFF_N[a][b] = FLOAT_undefined;
            }


            float AVERAGE, PERCENTAGE, COMPARISON;

            AVERAGE = (TOTALvaluesSUM_EFF_P[a][b] - TOTALvaluesSUM_EFF_N[a][b]);
            if ((TOTALvaluesSUM_EFF_P[a][b] + TOTALvaluesSUM_EFF_N[a][b]) > 0.00001) PERCENTAGE = (TOTALvaluesSUM_EFF_P[a][b] - TOTALvaluesSUM_EFF_N[a][b]) / (1.0 * (TOTALvaluesSUM_EFF_P[a][b] + TOTALvaluesSUM_EFF_N[a][b]));
            else PERCENTAGE = 0.0;
            COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);


            float valuesSUM = FLOAT_undefined;
            if (this.Impact_TYPE == Impact_ACTIVE) valuesSUM = TOTALvaluesSUM_RAD[a][b];
            if (this.Impact_TYPE == Impact_PASSIVE) valuesSUM = COMPARISON;

            //if ((Alpha == 90.0) && (Beta == 0.0)) println("SPHERICAL >> (TOTAL) valuesSUM_RAD:", TOTALvaluesSUM_RAD[a][b], "COMPARISON:", COMPARISON);

            if (is_defined(valuesSUM)) {

              float _u = 0;

              if (this.Impact_TYPE == Impact_ACTIVE) _u = (0.1 * PAL_multiplier * valuesSUM);
              if (this.Impact_TYPE == Impact_PASSIVE) _u = 0.5 + 0.5 * (0.1 * PAL_multiplier * valuesSUM);

              if (PAL_direction == -1) _u = 1 - _u;
              if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
              if (PAL_direction == 2) _u =  0.5 * _u;

              //float[] COL = PAINT.getColorStyle(PAL_type, _u);
              float[] COL = PAINT.getColorStyle(PAL_type, funcs.roundTo(_u, 0.1));
              this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
              this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

              this.graphics.strokeWeight(0);

              float x1 = (j + this.rect_offset_x + (90 - Alpha - 0.5 * Sky3D.stp_slp) * this.rect_scale * (funcs.cos_ang(Beta - 90 - 0.5 * Sky3D.stp_dir))) * sx_Plot;
              float y1 = (                         -(90 - Alpha - 0.5 * Sky3D.stp_slp) * this.rect_scale * (funcs.sin_ang(Beta - 90 - 0.5 * Sky3D.stp_dir))) * sx_Plot;
              float x2 = (j + this.rect_offset_x + (90 - Alpha + 0.5 * Sky3D.stp_slp) * this.rect_scale * (funcs.cos_ang(Beta - 90 - 0.5 * Sky3D.stp_dir))) * sx_Plot;
              float y2 = (                         -(90 - Alpha + 0.5 * Sky3D.stp_slp) * this.rect_scale * (funcs.sin_ang(Beta - 90 - 0.5 * Sky3D.stp_dir))) * sx_Plot;

              float x3 = (j + this.rect_offset_x + (90 - Alpha + 0.5 * Sky3D.stp_slp) * this.rect_scale * (funcs.cos_ang(Beta - 90 + 0.5 * Sky3D.stp_dir))) * sx_Plot;
              float y3 = (                         -(90 - Alpha + 0.5 * Sky3D.stp_slp) * this.rect_scale * (funcs.sin_ang(Beta - 90 + 0.5 * Sky3D.stp_dir))) * sx_Plot;
              float x4 = (j + this.rect_offset_x + (90 - Alpha - 0.5 * Sky3D.stp_slp) * this.rect_scale * (funcs.cos_ang(Beta - 90 + 0.5 * Sky3D.stp_dir))) * sx_Plot;
              float y4 = (                         -(90 - Alpha - 0.5 * Sky3D.stp_slp) * this.rect_scale * (funcs.sin_ang(Beta - 90 + 0.5 * Sky3D.stp_dir))) * sx_Plot;

              this.graphics.quad(x1, y1, x2, y2, x3, y3, x4, y4);
            }
          }
        }

        this.graphics.strokeWeight(this.T_scale * 2);
        this.graphics.stroke(0);
        this.graphics.noFill();
        this.graphics.rect((j + this.rect_offset_x - 100 * this.rect_scale) * sx_Plot, (-100 * this.rect_scale) * sx_Plot, (200 * this.rect_scale) * sx_Plot, (200 * this.rect_scale) * sx_Plot);


        this.graphics.stroke(0);
        this.graphics.fill(0);
        this.graphics.textAlign(CENTER, CENTER);
        this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);

        String scenario_text = "";
        //if (CurrentDataSource == dataID_CLIMATE_CWEEDS) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_CWEEDS_start - 1, 0);
        //if (CurrentDataSource == dataID_CLIMATE_CLMREC) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_CLMREC_start - 1, 0);
        //if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) scenario_text += "Member: " + nf(Normals_COL_N[l], 0);
        this.graphics.text(scenario_text, (j - ((0 - 12) / 24.0)) * sx_Plot, 0.95 * sx_Plot / this.U_scale);

        int keep_STUDY_j_Start = this.j_Start;
        int keep_STUDY_j_End = this.j_End;
        this.j_Start = j;
        this.j_End = j + 1;
        this.drawPositionGrid(x_Plot, y_Plot, sx_Plot, sy_Plot, 0);
        this.j_Start = keep_STUDY_j_Start;
        this.j_End = keep_STUDY_j_End;
      }


      String scenario_text = "";
      //if (CurrentDataSource == dataID_CLIMATE_CWEEDS) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_CWEEDS_start - 1, 0);
      //if (CurrentDataSource == dataID_CLIMATE_CLMREC) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_CLMREC_start - 1, 0);
      //if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) scenario_text += "Member: " + nf(Normals_COL_N[l], 0);
      this.graphics.text(scenario_text, ((this.j_Start - 1) - ((0 - 12) / 24.0)) * sx_Plot, 0.9 * sx_Plot / this.U_scale);

      this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
      this.graphics.textAlign(RIGHT, CENTER);
      this.graphics.stroke(0);
      this.graphics.fill(0);
      this.graphics.strokeWeight(0);
      if (this.Impact_TYPE == Impact_ACTIVE) {
        this.graphics.text(STAT_N_Title[l], -0.3 * sx_Plot / this.U_scale, 1.2 * sx_Plot / this.U_scale);
      }
      if (this.Impact_TYPE == Impact_PASSIVE) {
        this.graphics.text(STAT_N_Title[STAT_reverse_N[l]], -0.3 * sx_Plot / this.U_scale, 1.2 * sx_Plot / this.U_scale);
      }
      //?? French

      float pal_length = 400;
      float pal_ox = 700;
      float pal_oy = 110;
      for (int q = 0; q < 11; q++) {
        float _u = 0;

        if (this.Impact_TYPE == Impact_ACTIVE) _u = 0.1 * q;
        if (this.Impact_TYPE == Impact_PASSIVE) _u = 0.2 * q - 0.5;

        if (PAL_direction == -1) _u = 1 - _u;
        if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
        if (PAL_direction == 2) _u =  0.5 * _u;

        float[] COL = PAINT.getColorStyle(PAL_type, _u);
        this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
        this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

        this.graphics.strokeWeight(0);
        this.graphics.rect((pal_ox + q * (pal_length / 11.0)) * this.view_S, pal_oy * this.view_S, (pal_length / 11.0) * this.view_S, 20 * this.view_S);

        if (COL[1] + COL[2] + COL[3] > 1.75 * 255) {
          this.graphics.stroke(127);
          this.graphics.fill(127);
          this.graphics.strokeWeight(0);
        } else {
          this.graphics.stroke(255);
          this.graphics.fill(255);
          this.graphics.strokeWeight(2);
        }

        this.graphics.textSize(15.0 * this.view_S);
        this.graphics.textAlign(CENTER, CENTER);
        if (this.Impact_TYPE == Impact_ACTIVE) this.graphics.text(nf((funcs.roundTo(0.1 * q / PAL_multiplier, 0.1)), 1, 1), (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S, (10 + pal_oy - 0.05 * 20) * this.view_S);
        if (this.Impact_TYPE == Impact_PASSIVE) this.graphics.text(nf(int(funcs.roundTo(0.4 * (q - 5) / PAL_multiplier, 1)), 1), (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S, (10 + pal_oy - 0.05 * 20) * this.view_S);
      }


      if (this.PrintTtitle) {

        this.graphics.stroke(0);
        this.graphics.fill(0);
        this.graphics.strokeWeight(this.T_scale * 0);

        this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
        this.graphics.textAlign(RIGHT, TOP);

        if (CurrentDataSource == dataID_CLIMATE_CWEEDS) this.graphics.text(("[" + String.valueOf(start_k + CLIMATE_CWEEDS_start) + "-" + String.valueOf(end_k + CLIMATE_CWEEDS_start) + "] "), 0, -1.2 * sx_Plot / this.U_scale);
        if (CurrentDataSource == dataID_CLIMATE_CLMREC) this.graphics.text(("[" + String.valueOf(start_k + CLIMATE_CLMREC_start) + "-" + String.valueOf(end_k + CLIMATE_CLMREC_start) + "] "), 0, -1.2 * sx_Plot / this.U_scale);
        if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) this.graphics.text(("[" + String.valueOf(start_k + ENSEMBLE_FORECAST_start) + "-" + String.valueOf(end_k + ENSEMBLE_FORECAST_start) + "] "), 0, -1.2 * sx_Plot / this.U_scale);


        this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
        this.graphics.textAlign(LEFT, TOP);
        if (this.Impact_TYPE == Impact_ACTIVE) {
          this.graphics.text(("Solar radiation on hemisphere (kW/m²)"), 0, 1.1 * sx_Plot / this.U_scale);
          //?? French
        }
        if (this.Impact_TYPE == Impact_PASSIVE) {
          this.graphics.text(("Solar effects on hemisphere (%kW°C/m²)"), 0, 1.1 * sx_Plot / this.U_scale);
          //?? French
        }
      }

      this.drawPositionGrid(x_Plot, y_Plot, sx_Plot, sy_Plot, 0);
    }


    if ((this.PlotImpacts == PlotImpacts_SUNPATH_ACTIVE) || (this.PlotImpacts == PlotImpacts_SUNPATH_PASSIVE)) {
      if (this.PlotImpacts == PlotImpacts_SUNPATH_ACTIVE) this.Impact_TYPE = Impact_ACTIVE;
      if (this.PlotImpacts == PlotImpacts_SUNPATH_PASSIVE) this.Impact_TYPE = Impact_PASSIVE;

      float Pa = FLOAT_undefined;
      float Pb = FLOAT_undefined;
      float Pc = FLOAT_undefined;
      float Pd = FLOAT_undefined;

      float values_R_dir;
      float values_R_dif;
      float values_E_dir;
      float values_E_dif;

      int now_k = 0;
      int now_i = 0;
      int now_j = 0;

      int PAL_type = 0;
      int PAL_direction = 1;

      if (this.Impact_TYPE == Impact_ACTIVE) {
        PAL_type = this.ACTIVE_pallet_CLR;
        PAL_direction = this.ACTIVE_pallet_DIR;
      }
      if (this.Impact_TYPE == Impact_PASSIVE) {
        PAL_type = this.PASSIVE_pallet_CLR;
        PAL_direction = this.PASSIVE_pallet_DIR;
      }

      float PAL_multiplier = 1;
      if (this.Impact_TYPE == Impact_ACTIVE) PAL_multiplier = this.ACTIVE_pallet_MLT;
      if (this.Impact_TYPE == Impact_PASSIVE) PAL_multiplier = this.PASSIVE_pallet_MLT;

      this.drawPositionGrid(x_Plot, y_Plot, sx_Plot, sy_Plot, 0);

      int l = this.ImpactLayer;

      for (int j = this.j_Start; j < this.j_End; j++) {

        now_j = (j * int(this.perDays) + TIME.beginDay + 365) % 365;

        if (now_j >= 365) {
          now_j = now_j % 365;
        }
        if (now_j < 0) {
          now_j = (now_j + 365) % 365;
        }

        float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);

        float sunrise = funcs.Sunrise(STATION.getLatitude(), DATE_ANGLE);
        float sunset = funcs.Sunset(STATION.getLatitude(), DATE_ANGLE);

        int[] Normals_COL_N;
        Normals_COL_N = new int [9];
        Normals_COL_N = SOLARCHVISION_PROCESS_DAILY_SCENARIOS(start_k, end_k, j, DATE_ANGLE);

        for (int nk = Normals_COL_N[l]; nk <= Normals_COL_N[l]; nk++) {
          if (nk != -1) {
            int k = int(nk / this.joinDays);
            int j_ADD = nk % this.joinDays;

            float valuesSUM_RAD = 0;
            float valuesSUM_EFF = 0;
            int valuesNUM = 0;

            for (int i = 0; i < 24; i++) {
              if (this.isInHourlyRange(i)) {
                if ((i+0.5 >= sunrise) && (i+0.5 <= sunset)) {

                  float HOUR_ANGLE = i;
                  float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);

                  float Alpha = 90 - funcs.acos_ang(SunR[3]);
                  float Beta = 180 - funcs.atan2_ang(SunR[1], SunR[2]);

                  now_k = k + start_k;
                  now_i = i;
                  now_j = int(j * this.perDays + (j_ADD - int(funcs.roundTo(0.5 * this.joinDays, 1))) + TIME.beginDay + 365) % 365;

                  if (now_j >= 365) {
                    now_j = now_j % 365;
                  }
                  if (now_j < 0) {
                    now_j = (now_j + 365) % 365;
                  }

                  Pa = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_dirnorrad.id);
                  Pb = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_difhorrad.id);
                  Pc = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_direffect.id);
                  Pd = getValue_CurrentDataSource(now_i, now_j, now_k, LAYER_difeffect.id);

                  if (is_undefined(Pa) || is_undefined(Pb) || is_undefined(Pc) || is_undefined(Pd)) {
                    values_R_dir = FLOAT_undefined;
                    values_R_dif = FLOAT_undefined;
                    values_E_dir = FLOAT_undefined;
                    values_E_dif = FLOAT_undefined;
                  } else {

                    int memberCount = SOLARCHVISION_filter(CurrentDataSource, LAYER_cloudcover.id, this.filter, this.skyScenario, now_i, now_j, now_k);

                    if (memberCount == 1) {
                      values_R_dir = 0.001 * Pa;
                      values_R_dif = 0.001 * Pb;
                      values_E_dir = 0.001 * Pc;
                      values_E_dif = 0.001 * Pd;

                      if (is_undefined(valuesSUM_RAD)) {
                        valuesSUM_RAD = 0;
                        valuesSUM_EFF = 0;
                        valuesNUM = 0;
                      } else {
                        valuesSUM_RAD = (values_R_dir); // direct beam radiation
                        valuesSUM_EFF = (values_E_dir); // direct beam effect
                        valuesNUM = 1;
                      }
                    }
                  }

                  float valuesSUM = FLOAT_undefined;
                  if (this.Impact_TYPE == Impact_ACTIVE) valuesSUM = valuesSUM_RAD;
                  if (this.Impact_TYPE == Impact_PASSIVE) valuesSUM = valuesSUM_EFF;

                  if (is_defined(valuesSUM)) {

                    float _u = 0;

                    if (this.Impact_TYPE == Impact_ACTIVE) _u = (PAL_multiplier * valuesSUM);
                    if (this.Impact_TYPE == Impact_PASSIVE) _u = 0.5 + 0.5 * (PAL_multiplier * valuesSUM);

                    if (PAL_direction == -1) _u = 1 - _u;
                    if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
                    if (PAL_direction == 2) _u =  0.5 * _u;

                    float[] COL = PAINT.getColorStyle(PAL_type, _u);
                    this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
                    this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

                    this.graphics.strokeWeight(0);

                    this.graphics.ellipse((j + this.rect_offset_x + (90 - Alpha) * this.rect_scale * (funcs.cos_ang(Beta - 90))) * sx_Plot, -((90 - Alpha) * this.rect_scale * (funcs.sin_ang(Beta - 90))) * sx_Plot, 0.075 * sx_Plot, 0.075 * sx_Plot);

                    if (COL[1] + COL[2] + COL[3] > 1.75 * 255) {
                      this.graphics.stroke(127);
                      this.graphics.fill(127);
                      this.graphics.strokeWeight(0);
                    } else {
                      this.graphics.stroke(255);
                      this.graphics.fill(255);
                      this.graphics.strokeWeight(2);
                    }

                    this.graphics.textSize(this.view_S * 4.0 * this.U_scale);

                    this.graphics.textAlign(CENTER, CENTER);
                    if (this.Impact_TYPE == Impact_ACTIVE) this.graphics.text(nf(valuesSUM, 1, 1), (j + this.rect_offset_x + (90 - Alpha) * this.rect_scale * (funcs.cos_ang(Beta - 90))) * sx_Plot, -((90 - Alpha) * this.rect_scale * (funcs.sin_ang(Beta - 90))) * sx_Plot);
                    if (this.Impact_TYPE == Impact_PASSIVE) this.graphics.text(nf(int(valuesSUM), 1), (j + this.rect_offset_x + (90 - Alpha) * this.rect_scale * (funcs.cos_ang(Beta - 90))) * sx_Plot, -((90 - Alpha) * this.rect_scale * (funcs.sin_ang(Beta - 90))) * sx_Plot);
                  }
                }
              }
            }

            this.graphics.stroke(0);
            this.graphics.fill(0);
            this.graphics.textAlign(CENTER, CENTER);
            this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);

            String scenario_text = "";
            //if (CurrentDataSource == dataID_CLIMATE_CWEEDS) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_CWEEDS_start - 1, 0);
            //if (CurrentDataSource == dataID_CLIMATE_CLMREC) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_CLMREC_start - 1, 0);
            //if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) scenario_text += "Member: " + nf(Normals_COL_N[l], 0);
            this.graphics.text(scenario_text, (j - ((0 - 12) / 24.0)) * sx_Plot, 0.95  * sx_Plot / this.U_scale);
          }
        }
      }

      String scenario_text = "";
      //if (CurrentDataSource == dataID_CLIMATE_CWEEDS) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_CWEEDS_start - 1, 0);
      //if (CurrentDataSource == dataID_CLIMATE_CLMREC) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_CLMREC_start - 1, 0);
      //if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) scenario_text += "Member: " + nf(Normals_COL_N[l], 0);
      this.graphics.text(scenario_text, ((this.j_Start - 1) - ((0 - 12) / 24.0)) * sx_Plot, 0.9 * sx_Plot / this.U_scale);

      this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
      this.graphics.textAlign(RIGHT, CENTER);
      this.graphics.stroke(0);
      this.graphics.fill(0);
      this.graphics.strokeWeight(0);
      if (this.Impact_TYPE == Impact_ACTIVE) {
        this.graphics.text(STAT_N_Title[l], -0.3 * sx_Plot / this.U_scale, 1.2 * sx_Plot / this.U_scale);
      }
      if (this.Impact_TYPE == Impact_PASSIVE) {
        this.graphics.text(STAT_N_Title[STAT_reverse_N[l]], -0.3 * sx_Plot / this.U_scale, 1.2 * sx_Plot / this.U_scale);
      }
      //?? French


      float pal_length = 400;
      float pal_ox = 700;
      float pal_oy = 110;
      for (int q = 0; q < 11; q++) {
        float _u = 0;

        if (this.Impact_TYPE == Impact_ACTIVE) _u = 0.1 * q;
        if (this.Impact_TYPE == Impact_PASSIVE) _u = 0.2 * q - 0.5;

        if (PAL_direction == -1) _u = 1 - _u;
        if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
        if (PAL_direction == 2) _u =  0.5 * _u;

        float[] COL = PAINT.getColorStyle(PAL_type, _u);
        this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
        this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

        this.graphics.strokeWeight(0);
        this.graphics.rect((pal_ox + q * (pal_length / 11.0)) * this.view_S, pal_oy * this.view_S, (pal_length / 11.0) * this.view_S, 20 * this.view_S);

        if (COL[1] + COL[2] + COL[3] > 1.75 * 255) {
          this.graphics.stroke(127);
          this.graphics.fill(127);
          this.graphics.strokeWeight(0);
        } else {
          this.graphics.stroke(255);
          this.graphics.fill(255);
          this.graphics.strokeWeight(2);
        }

        this.graphics.textSize(15.0 * this.view_S);
        this.graphics.textAlign(CENTER, CENTER);

        if (this.Impact_TYPE == Impact_ACTIVE) this.graphics.text(nf(0.1 * q / PAL_multiplier, 1, 1), (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S, (10 + pal_oy - 0.05 * 20) * this.view_S);
        if (this.Impact_TYPE == Impact_PASSIVE) this.graphics.text(nf(int(funcs.roundTo(0.4 * (q - 5) / PAL_multiplier, 1)), 1), (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S, (10 + pal_oy - 0.05 * 20) * this.view_S);
      }


      if (this.PrintTtitle) {

        this.graphics.stroke(0);
        this.graphics.fill(0);
        this.graphics.strokeWeight(this.T_scale * 0);

        this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
        this.graphics.textAlign(RIGHT, TOP);

        if (CurrentDataSource == dataID_CLIMATE_CWEEDS) this.graphics.text(("[" + String.valueOf(start_k + CLIMATE_CWEEDS_start) + "-" + String.valueOf(end_k + CLIMATE_CWEEDS_start) + "] "), 0, -1.2 * sx_Plot / this.U_scale);
        if (CurrentDataSource == dataID_CLIMATE_CLMREC) this.graphics.text(("[" + String.valueOf(start_k + CLIMATE_CLMREC_start) + "-" + String.valueOf(end_k + CLIMATE_CLMREC_start) + "] "), 0, -1.2 * sx_Plot / this.U_scale);
        if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) this.graphics.text(("[" + String.valueOf(start_k + ENSEMBLE_FORECAST_start) + "-" + String.valueOf(end_k + ENSEMBLE_FORECAST_start) + "] "), 0, -1.2 * sx_Plot / this.U_scale);


        this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
        this.graphics.textAlign(LEFT, TOP);
        if (this.Impact_TYPE == Impact_ACTIVE) {
          this.graphics.text(("Direct solar radiation (kWh/m²)"), 0, 1.1 * sx_Plot / this.U_scale);
          //?? French
        }
        if (this.Impact_TYPE == Impact_PASSIVE) {
          this.graphics.text(("Direct solar effects (kWh°C/m²)"), 0, 1.1 * sx_Plot / this.U_scale);
          //?? French
        }
      }

    }


    if ((this.PlotImpacts == PlotImpacts_CYCLES_ACTIVE) || (this.PlotImpacts == PlotImpacts_CYCLES_PASSIVE)) {

      int l = this.ImpactLayer;

      int target_window = TypeWindow.STUDY;

      Sun3D.drawPattern(TypeWindow.STUDY, x_Plot, y_Plot, 0, sx_Plot);

      if (this.j_End == 2) {
        for (int j = STUDY.j_Start; j < STUDY.j_End; j++) {

          float ox = (j + STUDY.rect_offset_x) * sx_Plot;

          Sun3D.drawGrid(TypeWindow.STUDY, ox + x_Plot, y_Plot, 0, sx_Plot, j * 180 - 90, j * 180 + 90);

        }
      }

      this.drawPositionGrid(x_Plot, y_Plot, sx_Plot, sy_Plot, 0);

      String scenario_text = "";
      //if (CurrentDataSource == dataID_CLIMATE_CWEEDS) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_CWEEDS_start - 1, 0);
      //if (CurrentDataSource == dataID_CLIMATE_CLMREC) scenario_text += "Year: " + nf(Normals_COL_N[l] + CLIMATE_CLMREC_start - 1, 0);
      //if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) scenario_text += "Member: " + nf(Normals_COL_N[l], 0);
      this.graphics.text(scenario_text, ((this.j_Start - 1) - ((0 - 12) / 24.0)) * sx_Plot, 0.9 * sx_Plot / this.U_scale);

      this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
      this.graphics.textAlign(RIGHT, CENTER);
      this.graphics.stroke(0);
      this.graphics.fill(0);
      this.graphics.strokeWeight(0);
      if (this.PlotImpacts == PlotImpacts_CYCLES_ACTIVE) {
        this.graphics.text(STAT_N_Title[l], -0.3 * sx_Plot / this.U_scale, 1.2 * sx_Plot / this.U_scale);
      }
      if (this.PlotImpacts == PlotImpacts_CYCLES_PASSIVE) {
        this.graphics.text(STAT_N_Title[STAT_reverse_N[l]], -0.3 * sx_Plot / this.U_scale, 1.2 * sx_Plot / this.U_scale);
      }
      //?? French

      int PAL_type = 0;
      int PAL_direction = 1;

      if (this.PlotImpacts == PlotImpacts_CYCLES_ACTIVE) {
        PAL_type = this.ACTIVE_pallet_CLR;
        PAL_direction = this.ACTIVE_pallet_DIR;
      }
      if (this.PlotImpacts == PlotImpacts_CYCLES_PASSIVE) {
        PAL_type = this.PASSIVE_pallet_CLR;
        PAL_direction = this.PASSIVE_pallet_DIR;
      }

      float PAL_multiplier = 1;
      if (this.PlotImpacts == PlotImpacts_CYCLES_ACTIVE) PAL_multiplier = this.ACTIVE_pallet_MLT;
      if (this.PlotImpacts == PlotImpacts_CYCLES_PASSIVE) PAL_multiplier = this.PASSIVE_pallet_MLT;

      float pal_length = 400;
      float pal_ox = 700;
      float pal_oy = 110;

      if (this.j_End == 2) {
        pal_ox = (FrameVariation == 2) ? 700 : 380;
        pal_oy = (FrameVariation == 2) ? -375 : 275;
      }

      for (int q = 0; q < 11; q++) {
        float _u = 0;

        if (this.PlotImpacts == PlotImpacts_CYCLES_ACTIVE) _u = 0.1 * q;
        if (this.PlotImpacts == PlotImpacts_CYCLES_PASSIVE) _u = 0.2 * q - 0.5;

        if (PAL_direction == -1) _u = 1 - _u;
        if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
        if (PAL_direction == 2) _u =  0.5 * _u;

        float[] COL = PAINT.getColorStyle(PAL_type, _u);
        this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
        this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

        this.graphics.strokeWeight(0);
        this.graphics.rect((pal_ox + q * (pal_length / 11.0)) * this.view_S, -pal_oy * this.view_S, (pal_length / 11.0) * this.view_S, 20 * this.view_S);

        if (COL[1] + COL[2] + COL[3] > 1.75 * 255) {
          this.graphics.stroke(127);
          this.graphics.fill(127);
          this.graphics.strokeWeight(0);
        } else {
          this.graphics.stroke(255);
          this.graphics.fill(255);
          this.graphics.strokeWeight(2);
        }

        this.graphics.textSize(15.0 * this.view_S);
        this.graphics.textAlign(CENTER, CENTER);
        if (this.PlotImpacts == PlotImpacts_CYCLES_ACTIVE) this.graphics.text(nf(0.1 * q / PAL_multiplier, 1, 1), (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S, (10 - pal_oy - 0.05 * 20) * this.view_S);
        if (this.PlotImpacts == PlotImpacts_CYCLES_PASSIVE) this.graphics.text(nf(int(funcs.roundTo(0.4 * (q - 5) / PAL_multiplier, 1)), 1), (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S, (10 - pal_oy - 0.05 * 20) * this.view_S);
      }


      if (this.PrintTtitle) {

        this.graphics.stroke(0);
        this.graphics.fill(0);
        this.graphics.strokeWeight(this.T_scale * 0);

        this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
        this.graphics.textAlign(RIGHT, TOP);

        if (CurrentDataSource == dataID_CLIMATE_CWEEDS) this.graphics.text(("[" + String.valueOf(start_k + CLIMATE_CWEEDS_start) + "-" + String.valueOf(end_k + CLIMATE_CWEEDS_start) + "] "), 0, -1.2 * sx_Plot / this.U_scale);
        if (CurrentDataSource == dataID_CLIMATE_CLMREC) this.graphics.text(("[" + String.valueOf(start_k + CLIMATE_CLMREC_start) + "-" + String.valueOf(end_k + CLIMATE_CLMREC_start) + "] "), 0, -1.2 * sx_Plot / this.U_scale);
        if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) this.graphics.text(("[" + String.valueOf(start_k + ENSEMBLE_FORECAST_start) + "-" + String.valueOf(end_k + ENSEMBLE_FORECAST_start) + "] "), 0, -1.2 * sx_Plot / this.U_scale);

        this.graphics.textSize(sx_Plot * 0.250 / this.U_scale);
        this.graphics.textAlign(CENTER, TOP);
        if (this.PlotImpacts == PlotImpacts_CYCLES_ACTIVE) {
          this.graphics.text(("Direct solar radiation (kWh/m²)"), (pal_ox + 5 * (pal_length / 11.0)) * this.view_S + (pal_length / 11.0) * this.view_S, -pal_oy * this.view_S + 25 * this.view_S);
          //?? French
        }
        if (this.PlotImpacts == PlotImpacts_CYCLES_PASSIVE) {
          this.graphics.text(("Direct solar effects (kWh°C/m²)"), (pal_ox + 5 * (pal_length / 11.0)) * this.view_S + (pal_length / 11.0) * this.view_S, -pal_oy * this.view_S + 25 * this.view_S);
          //?? French
        }
      }

    }





    if ((this.PlotImpacts == PlotImpacts_CYCLES_ACTIVE) || (this.PlotImpacts == PlotImpacts_CYCLES_PASSIVE)) {
    } else {
      this.drawDailyGrid(x_Plot, y_Plot, sx_Plot, sy_Plot);
    }

    keep_STUDY_perDays = this.perDays;
    this.joinDays = keep_STUDY_joinDays;




    this.graphics.popMatrix();
  }




  public void to_XML (XML xml) {

    println("Saving:" + this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setInt(parent, "i_Start", this.i_Start);
    XML_setInt(parent, "i_End", this.i_End);
    XML_setInt(parent, "j_Start", this.j_Start);
    XML_setInt(parent, "j_End", this.j_End);
    XML_setFloat(parent, "perDays", this.perDays);
    XML_setInt(parent, "joinDays", this.joinDays);

    XML_setFloat(parent, "T_scale", this.T_scale);
    XML_setFloat(parent, "U_scale", this.U_scale);

    XML_setInt(parent, "skyScenario", this.skyScenario);
    XML_setInt(parent, "filter", this.filter);
    XML_setInt(parent, "TrendJoinHours", this.TrendJoinHours);
    XML_setInt(parent, "TrendJoinType", this.TrendJoinType);
    XML_setBoolean(parent, "export_info_node", this.export_info_node);
    XML_setBoolean(parent, "export_info_norm", this.export_info_norm);
    XML_setBoolean(parent, "export_info_prob", this.export_info_prob);
    XML_setInt(parent, "SORT_pallet_CLR", this.SORT_pallet_CLR);
    XML_setInt(parent, "SORT_pallet_DIR", this.SORT_pallet_DIR);
    XML_setFloat(parent, "SORT_pallet_MLT", this.SORT_pallet_MLT);
    XML_setInt(parent, "PROB_pallet_CLR", this.PROB_pallet_CLR);
    XML_setInt(parent, "PROB_pallet_DIR", this.PROB_pallet_DIR);
    XML_setFloat(parent, "PROB_pallet_MLT", this.PROB_pallet_MLT);
    XML_setInt(parent, "ACTIVE_pallet_CLR", this.ACTIVE_pallet_CLR);
    XML_setInt(parent, "ACTIVE_pallet_DIR", this.ACTIVE_pallet_DIR);
    XML_setFloat(parent, "ACTIVE_pallet_MLT", this.ACTIVE_pallet_MLT);
    XML_setInt(parent, "PASSIVE_pallet_CLR", this.PASSIVE_pallet_CLR);
    XML_setInt(parent, "PASSIVE_pallet_DIR", this.PASSIVE_pallet_DIR);
    XML_setFloat(parent, "PASSIVE_pallet_MLT", this.PASSIVE_pallet_MLT);

    XML_setFloat(parent, "O_scale", this.O_scale);
    XML_setFloat(parent, "W_scale", this.W_scale);
    XML_setFloat(parent, "rect_scale", this.rect_scale);
    XML_setFloat(parent, "rect_offset_x", this.rect_offset_x);

    XML_setBoolean(parent, "impact_summary", this.impact_summary);
    XML_setInt(parent, "ImpactLayer", this.ImpactLayer);
    XML_setInt(parent, "PlotImpacts", this.PlotImpacts);
    XML_setBoolean(parent, "Impacts_update", this.Impacts_update);

    XML_setBoolean(parent, "displayRaws", this.displayRaws);
    XML_setBoolean(parent, "displaySorted", this.displaySorted);
    XML_setBoolean(parent, "displayNormals", this.displayNormals);
    XML_setBoolean(parent, "displayProbs", this.displayProbs);
    XML_setInt(parent, "sumInterval", this.sumInterval);
    XML_setFloat(parent, "LevelPix", this.LevelPix);
    XML_setInt(parent, "plotSetup", this.plotSetup);
    XML_setInt(parent, "Impact_TYPE", this.Impact_TYPE);
  }


  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);

    this.i_Start = XML_getInt(parent, "i_Start");
    this.i_End = XML_getInt(parent, "i_End");
    this.j_Start = XML_getInt(parent, "j_Start");
    this.j_End = XML_getInt(parent, "j_End");
    this.perDays = XML_getFloat(parent, "perDays");
    this.joinDays = XML_getInt(parent, "joinDays");

    this.T_scale = XML_getFloat(parent, "T_scale");
    this.U_scale = XML_getFloat(parent, "U_scale");
    this.skyScenario = XML_getInt(parent, "skyScenario");
    this.filter = XML_getInt(parent, "filter");
    this.TrendJoinHours = XML_getInt(parent, "TrendJoinHours");
    this.TrendJoinType = XML_getInt(parent, "TrendJoinType");
    this.export_info_node = XML_getBoolean(parent, "export_info_node");
    this.export_info_norm = XML_getBoolean(parent, "export_info_norm");
    this.export_info_prob = XML_getBoolean(parent, "export_info_prob");
    this.SORT_pallet_CLR = XML_getInt(parent, "SORT_pallet_CLR");
    this.SORT_pallet_DIR = XML_getInt(parent, "SORT_pallet_DIR");
    this.SORT_pallet_MLT = XML_getFloat(parent, "SORT_pallet_MLT");
    this.PROB_pallet_CLR = XML_getInt(parent, "PROB_pallet_CLR");
    this.PROB_pallet_DIR = XML_getInt(parent, "PROB_pallet_DIR");
    this.PROB_pallet_MLT = XML_getFloat(parent, "PROB_pallet_MLT");
    this.ACTIVE_pallet_CLR = XML_getInt(parent, "ACTIVE_pallet_CLR");
    this.ACTIVE_pallet_DIR = XML_getInt(parent, "ACTIVE_pallet_DIR");
    this.ACTIVE_pallet_MLT = XML_getFloat(parent, "ACTIVE_pallet_MLT");
    this.PASSIVE_pallet_CLR = XML_getInt(parent, "PASSIVE_pallet_CLR");
    this.PASSIVE_pallet_DIR = XML_getInt(parent, "PASSIVE_pallet_DIR");
    this.PASSIVE_pallet_MLT = XML_getFloat(parent, "PASSIVE_pallet_MLT");


    this.O_scale = XML_getFloat(parent, "O_scale");
    this.W_scale = XML_getFloat(parent, "W_scale");
    this.rect_scale = XML_getFloat(parent, "rect_scale");
    this.rect_offset_x = XML_getFloat(parent, "rect_offset_x");

    this.impact_summary = XML_getBoolean(parent, "impact_summary");
    this.ImpactLayer = XML_getInt(parent, "ImpactLayer");
    this.PlotImpacts = XML_getInt(parent, "PlotImpacts");
    this.Impacts_update = XML_getBoolean(parent, "Impacts_update");

    this.displayRaws = XML_getBoolean(parent, "displayRaws");
    this.displaySorted = XML_getBoolean(parent, "displaySorted");
    this.displayNormals = XML_getBoolean(parent, "displayNormals");
    this.displayProbs = XML_getBoolean(parent, "displayProbs");
    this.sumInterval = XML_getInt(parent, "sumInterval");
    this.LevelPix = XML_getFloat(parent, "LevelPix");
    this.plotSetup = XML_getInt(parent, "plotSetup");
    this.Impact_TYPE = XML_getInt(parent, "Impact_TYPE");
  }


  void revise () {
    this.update = true;
  }
  void updated () {
    this.update = false;
  }
}
