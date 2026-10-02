class STUDY {

  final static String CLASS_STAMP = "STUDY";

  int statisticalRangesColorscaleIndex = -1;
  int statisticalRangesColorscaleDirection = -1;
  float statisticalRangesColorscaleFactor = 2;

  int probabilitiesColorscaleIndex = -1;
  int probabilitiesColorscaleDirection = 1;
  float probabilitiesColorscaleFactor = 0.5;

  int activeColorscaleIndex = 19; //15; //14;
  int activeColorscaleDirection = 1;
  float activeColorscaleFactor = 1; //2;

  int passiveColorscaleIndex = 1;
  int passiveColorscaleDirection = 1;
  float passiveColorscaleFactor = 0.25;


  int cX = 0;
  int cY = pixel_A + pixel_B + pixel_H;
  int dX = 2 * pixel_W;
  int dY = 1 * pixel_H;
  float view_R = float(dY) / float(dX);
  float view_S;

  boolean update = true;
  boolean include = true;

  boolean record_IMG = false;
  boolean record_PDF = false;
  boolean record_AUTO = false;


  int startHour = 0;
  int endHour = 23;

  int startDay = 0; // constant
  int endDay = 12; //8; //6; //2; //16; // Variable

  float dayIncrement = 30.5; //1; //45; //61;
  int daysMergedCount = 30; //1; //dayIncrement; // it should be set up to 1 in order to plot only one day

  boolean PrintTtitle = true;

  float strokeScale = 0.5;
  float horizontalUnitScale = 18.0 / float(endDay - startDay);

  float verticalUnitScale;
  float verticalUnitOffset;
  float verticalNegativePadding;

  int skyScenarioSetting = 1; // 1: all scenarios, 2: Total Cloud Cover < 0.33, 3: middle range, 4: Total Cloud Cover > 0.66
  int temporalFilterSetting = filter_DAILY;

  boolean rawLinesExporter = false;
  boolean normalLinesExporter = false;
  boolean probabilitiesExporter = false;

  float positionX = 0;
  float positionY = 0;

  float opacityPercentage = 50.0;

  float centralGraphScale = 1.0;
  float centralGraphOffsetX = 0.0;

  boolean showImpactSummary = true;

  int impactLayerIndex = 4; // 4 = Median

  int impactGraphIndex = impactGraphIndex_GLOBAL_PASSIVE;

  boolean updateImpactGraph = true;

  boolean showRawLines = false;
  boolean showStatisticalRanges = true;
  boolean showNormalLines = true;
  boolean showProbabilities = false;

  int probabilityWidthInterval = 4;
  float probabilityHeightInterval = 8;

  color color_data_raws = color(0, 0, 0);

  int plotLayoutIndex = 0;

  float ImageScale = 1.0;

  int impactTypeIndex = 1;

  PGraphics graphics;

  boolean isInHourlyRange (float i) {
    boolean result = true;
    if (this.startHour <= this.endHour) {
      result = false;
      if ((this.startHour <= i) && (i <= (this.endHour + 24) % 24)) result = true;
    } else {
      result = true;
      if ((this.startHour > i) && (i > (this.endHour + 24) % 24)) result = false;
    }
    return result;
  }

  // Maps (j, j_ADD) - a plotted day column and its within-join-window
  // offset - to the actual day-of-year index (0-364) those two values
  // represent, wrapping around the year boundary either direction.
  // Pulled out of plotHourly()/plotImpact_wind()/plotImpact_global()/
  // plotImpact_sunpath(), which each computed this identical 8-line
  // expression inline (character-for-character identical across all 5
  // call sites, confirmed before extracting) - some as a fresh `int
  // now_j = ...` declaration, others as a reassignment of an existing
  // now_j; both call sites now just do `now_j = computeWrappedDayIndex(j,
  // j_ADD);` instead. Note the `now_j >= 365` branch is unreachable in
  // practice (Java's % already bounds the preceding expression to
  // (-364, 364)) - preserved as-is rather than removed, since this is a
  // refactor, not a behavior change.
  int computeWrappedDayIndex (int j, int j_ADD) {
    int now_j = int(j * this.dayIncrement + (j_ADD - int(funcs.roundTo(0.5 * this.daysMergedCount, 1))) + TIME.beginDay + 365) % 365;

    if (now_j >= 365) {
      now_j = now_j % 365;
    }
    if (now_j < 0) {
      now_j = (now_j + 365) % 365;
    }

    return now_j;
  }

  // Counts how many values at the start of a sort()-ed array (undefined
  // values sort to the end) are actually defined - i.e. the number of
  // real values sort() found, before the run of undefined padding
  // begins. Pulled out of drawSorted(), which ran this exact loop twice
  // in a row (once for valuesA, once for valuesB, confirmed identical
  // before extracting).
  int countDefinedPrefix (float[] sortedValues) {
    int count = 0;
    for (int l = 0; l < sortedValues.length; l++) {
      if (is_defined(sortedValues[l])) {
        count += 1;
      } else break;
    }
    return count;
  }


  // Number of impactGraphIndex modes (kept in sync with the impactGraphIndex_* constants).
  final static int PLOT_IMPACTS_MODE_COUNT = 11;

  // Number of plotLayoutIndex modes cycled by Ctrl+PageUp/PageDown.
  final static int PLOT_SETUP_MODE_COUNT = 10;

  final static int PAGE_UP_KEYCODE = 16;
  final static int PAGE_DOWN_KEYCODE = 11;

  void requestRedraw () {
    this.revise();
    UI_rollout.revise();
  }

  void requestDataRefresh () {
    developDataUpdate = true;
    UI_caseBar.revise();
    this.revise();
    WIN3D.revise();
    UI_rollout.revise();
  }

  void keyPressed (KeyEvent e) {
    if (this.include == false) return;

    if (e.isAltDown()) {
      return;
    }

    if (e.isControlDown()) {
      if (key == CODED) {
        handleCtrlCodedKey(e);
      } else {
        handleCtrlCharKey();
      }
      return;
    }

    if (key != CODED) {
      handlePlainCharKey();
    }
  }

  // See actions.pde's own "key2D <descriptor>" section (right after its
  // key3D one) for the full explanation of this naming and which of
  // these calls still need requestRedraw() kept here versus which don't.
  void handleCtrlCodedKey (KeyEvent e) {
    switch (keyCode) {
      case UP :
        runScriptLine("key2D Ctrl+Up");
        requestRedraw();
        break;

      case DOWN :
        runScriptLine("key2D Ctrl+Down");
        requestRedraw();
        break;

      case RIGHT :
        runScriptLine("key2D Ctrl+Right");
        requestRedraw();
        break;

      case LEFT :
        runScriptLine("key2D Ctrl+Left");
        requestRedraw();
        break;

      case PAGE_UP_KEYCODE :
        if (!e.isShiftDown()) {
          runScriptLine("key2D Ctrl+PageUp");
          requestRedraw();
        }
        break;

      case PAGE_DOWN_KEYCODE :
        if (!e.isShiftDown()) {
          runScriptLine("key2D Ctrl+PageDown");
          requestRedraw();
        }
        break;
    }
  }

  void handleCtrlCharKey () {
    switch (key) {
      case ';' :
        runScriptLine("key2D Ctrl+;");
        requestRedraw();
        break;

      case '"' :
        runScriptLine("key2D Ctrl+\"");
        requestRedraw();
        break;

      case '\'' :
        runScriptLine("key2D Ctrl+'");
        requestRedraw();
        break;
    }
  }

  void handlePlainCharKey () {
    switch (key) {

      case '>' :
        runScriptLine("key2D >");
        break;
      case '<' :
        runScriptLine("key2D <");
        break;

      case ')' :
        runScriptLine("key2D )");
        break;
      case '(' :
        runScriptLine("key2D (");
        break;

      case 'S' :
        runScriptLine("key2D Shift+S");
        break;
      case 's' :
        runScriptLine("key2D s");
        break;

      case 'V' :
      case 'v' :
        runScriptLine("key2D v");
        requestRedraw();
        break;

      case 'm' :
      case 'M' :
        runScriptLine("key2D m");
        requestRedraw();
        break;

      case 'n' :
      case 'N' :
        runScriptLine("key2D n");
        requestRedraw();
        break;

      case 'b' :
      case 'B' :
        runScriptLine("key2D b");
        requestRedraw();
        break;

      case '{' :
        runScriptLine("key2D {");
        requestRedraw();
        break;
      case '}' :
        runScriptLine("key2D }");
        requestRedraw();
        break;

      case '[' :
        runScriptLine("key2D [");
        requestRedraw();
        break;
      case ']' :
        runScriptLine("key2D ]");
        requestRedraw();
        break;
    }
  }

  // '>' / '<' : widen or narrow the day-joining (averaging) window, clamped
  // to [1, 365] days.
  void changeJoinDays (int delta) {
    this.daysMergedCount += delta;
    if (this.daysMergedCount > 365) this.daysMergedCount = 365;
    if (this.daysMergedCount < 1) this.daysMergedCount = 1;
    requestDataRefresh();
  }

  // ')' / '(' : grow or shrink the number of date columns (endDay), clamped so
  // the window stays within (startDay, startDay + 61] and always at least one
  // column wide, then flags every dependent view for rebuilding.
  void changeJEnd (int delta) {
    this.endDay += delta;
    if (delta > 0 && this.endDay > this.startDay + 61) this.endDay -= delta;
    if (delta < 0 && this.endDay <= this.startDay) this.endDay -= delta;
    this.horizontalUnitScale = 18.0 / float(this.endDay - this.startDay);

    developDataUpdate = true;

    VertexSolar_rebuild_array = true;
    GlobalSolar_rebuild_array = true;
    allSolarImpacts.rebuild_Image_array = true;
    allWindRoses.rebuild_Image_array = true;
    allSections.resize_solarImpact_array();

    UI_caseBar.revise();
    this.revise();
    UI_rollout.revise();
  }

  // 'S' / 's' : cycle the sky scenario filter forward/backward through its 4
  // states (1..4).
  void changeSkyScenario (int delta) {
    this.skyScenarioSetting = 1 + (((this.skyScenarioSetting - 1) + delta) % 4 + 4) % 4;
    developDataUpdate = true;
    this.revise();
    WIN3D.revise();
    UI_rollout.revise();
  }

  // '[' : shrink the hourly summing interval, following the step sequence
  // ...24 -> 6 -> 1 (skipping 5, snapping it to 4).
  void decreaseSumInterval () {
    if (this.probabilityWidthInterval > 24) this.probabilityWidthInterval -= 24;
    if (this.probabilityWidthInterval > 6) this.probabilityWidthInterval -= 6;
    else if (this.probabilityWidthInterval > 1) this.probabilityWidthInterval -= 1;
    if (this.probabilityWidthInterval == 5) this.probabilityWidthInterval = 4;
  }

  // ']' : grow the hourly summing interval, following the step sequence
  // 1 -> 6 -> 24... (skipping 5, snapping it to 6).
  void increaseSumInterval () {
    if (this.probabilityWidthInterval < 6) this.probabilityWidthInterval += 1;
    else if (this.probabilityWidthInterval < 24) this.probabilityWidthInterval += 6;
    else this.probabilityWidthInterval += 24;
    if (this.probabilityWidthInterval == 5) this.probabilityWidthInterval = 6;
  }



  void applyLegendTextStyle (float[] COL) {
    if (COL[1] + COL[2] + COL[3] > 1.75 * 255) {
      this.graphics.stroke(127);
      this.graphics.fill(127);
      this.graphics.strokeWeight(0);
    } else {
      this.graphics.stroke(255);
      this.graphics.fill(255);
      this.graphics.strokeWeight(2);
    }
  }

  void drawTimeGrid (float x_Plot, float y_Plot, float sx_Plot, float sy_Plot) {
    this.graphics.strokeWeight(this.strokeScale * 1);

    float Shift_DOWN = 0;
    if (this.verticalNegativePadding != 0) Shift_DOWN = -75;

    for (int i = 100; i >= Shift_DOWN; i -= 25) {
      if (-this.verticalUnitOffset + funcs.roundTo(i / this.verticalUnitScale, 0.1) != 0) {
        this.graphics.stroke(0, 63);
        this.graphics.fill(0, 63);
      } else {
        this.graphics.stroke(0);
        this.graphics.fill(0);
      }

      float y = -i * this.view_S;

      this.graphics.line(this.startDay * sx_Plot, y, this.endDay * sx_Plot, y);

      if ((i >= 0) || (this.verticalNegativePadding != 0)) {
        this.graphics.stroke(0);
        this.graphics.fill(0);
        this.graphics.textSize(sx_Plot * 0.150 / this.horizontalUnitScale);
        this.graphics.textAlign(RIGHT, CENTER);
        this.graphics.text(((nf(-this.verticalUnitOffset + funcs.roundTo(i / this.verticalUnitScale, 0.1), 0, 1)) + CurrentLayer_unit), -5, y);
        //this.graphics.text(((String.valueOf(int(-this.verticalUnitOffset + funcs.roundTo(i / this.verticalUnitScale, 0.1)))) + CurrentLayer_unit), -5, y);
      }
    }

    this.graphics.stroke(0, 63);
    this.graphics.fill(0, 63);
    for (int i = this.startDay; i <= this.endDay; i++) {
      if (i < this.endDay) {
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

    for (int i = this.startDay; i < this.endDay; i++) {
      if (this.horizontalUnitScale >= 0.75) {

        float x = (i - ((0 - 12) / 24.0)) * sx_Plot;
        float y = 0.1 * sx_Plot / this.horizontalUnitScale;
        float h = sx_Plot * 0.15 / this.horizontalUnitScale;

        this.graphics.textSize(h);
        this.graphics.text("12:00", x, y);
      }
    }

    this.drawInfo(sx_Plot, this.verticalNegativePadding);
  }



  void drawPositionGrid (float x_Plot, float y_Plot, float sx_Plot, float sy_Plot, int fill_back) {
    this.graphics.strokeWeight(this.strokeScale * 1);

    if (fill_back != 0) {
      for (int i = this.startDay; i < this.endDay; i++) {

        float x1 = (i + (this.centralGraphOffsetX + 0.5)) * sx_Plot;
        float y1 = 0;
        float h = 2 * 90 * (this.centralGraphScale / 200) * sx_Plot;

        this.graphics.stroke(223);
        this.graphics.fill(223);
        this.graphics.ellipse(x1, y1, h, h);
      }
    }

    for (int i = this.startDay; i < this.endDay; i++) {
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

        float x1 = (i + (this.centralGraphOffsetX + 0.5) + r * (this.centralGraphScale / 200) * funcs.cos_ang(t)) * sx_Plot;
        float x2 = (i + (this.centralGraphOffsetX + 0.5) + 90 * (this.centralGraphScale / 200) * funcs.cos_ang(t)) * sx_Plot;
        float y1 = -(r * (this.centralGraphScale / 200) * funcs.sin_ang(t)) * sx_Plot;
        float y2 = -(90 * (this.centralGraphScale / 200) * funcs.sin_ang(t)) * sx_Plot;

        this.graphics.line(x1, y1, x2, y2);

        boolean displayText = false;
        if ((this.endDay == 2) && (t % 45 == 0)) displayText = true;
        else if ((t + 45) % 90 == 0) displayText = true;

        if (displayText) {
          float textR = 105;
          float textSize = sx_Plot * 0.150 / this.horizontalUnitScale;

          if (this.endDay == 2) {
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

          float x = (i + (this.centralGraphOffsetX + 0.5) + textR * (this.centralGraphScale / 200) * funcs.cos_ang(t)) * sx_Plot;
          float y = -(textR * (this.centralGraphScale / 200) * funcs.sin_ang(t)) * sx_Plot;

          this.graphics.text(txt, x, y);
        }
      }

      float impact_scale = 1;
      if ((this.impactGraphIndex == impactGraphIndex_WIND_ACTIVE) || (this.impactGraphIndex == impactGraphIndex_WIND_PASSIVE)) impact_scale = LAYER_windspd.verticalUnitScale * 45 / 50.0;

      for (int r = 90; r > 0; r -= 15) {
        if ((r % 90) != 0) {
          this.graphics.stroke(0, 63);
          this.graphics.noFill();
        } else {
          this.graphics.stroke(0);
          this.graphics.noFill();
        }

        float x1 = (i + (this.centralGraphOffsetX + 0.5)) * sx_Plot;
        float y1 = 0;
        float h = 2 * r * (this.centralGraphScale / 200) * sx_Plot;

        this.graphics.ellipse(x1, y1, h, h);

        int t = 90;
        if (t == 90) {
          float textSize = sx_Plot * 0.150 / this.horizontalUnitScale;
          if (this.endDay == 2) {
            textSize *= 1.5;
          }

          float x = (i + (this.centralGraphOffsetX + 0.5) + r * (this.centralGraphScale / 200) * funcs.cos_ang(t)) * sx_Plot;
          float y = -(r * (this.centralGraphScale / 200) * funcs.sin_ang(t)) * sx_Plot;

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

    for (int j = this.startDay; j < this.endDay; j++) {
      if ((this.horizontalUnitScale >= 0.75) || (((j - this.startDay) % int(1.5 / this.horizontalUnitScale)) == 0)) {

        float x = (j - ((0 - 12) / 24.0)) * sx_Plot;
        float y = -1.2 * sx_Plot / this.horizontalUnitScale;
        float h = sx_Plot * 0.2 / this.horizontalUnitScale;

        this.graphics.textSize(h);
        this.graphics.text(TIME.getDayText(j * this.dayIncrement + 286 + TIME.beginDay), x, y + h);
        if (this.daysMergedCount > 1) {
          this.graphics.text(("±" + int(this.daysMergedCount / 2) + TIME.WORDS[2][activeLanguage] + "s"), x, y);
        }
      }
    }

    this.drawInfo(sx_Plot, 1);
  }


  void drawInfo (float sx_Plot, float verticalNegativePadding) {
    this.graphics.stroke(0);
    this.graphics.fill(0);
    this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
    this.graphics.textAlign(RIGHT, TOP);

    String txt = STATION.getCity();

    if (currentDataSource == dataID_ensembleForecast) {
      txt += "\n(" + nf(TIME.year, 4) + "_" + nf(TIME.month, 2) + "_" + nf(TIME.day, 2) + "_" + nf(TIME.hour, 2) + ")";
    }

    //this.graphics.text(txt, -1.0 * sx_Plot / this.horizontalUnitScale, -1.25 * sx_Plot / this.horizontalUnitScale);

    switch(this.skyScenarioSetting) {
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

    this.graphics.text(skyScenarioSetting_Title[this.skyScenarioSetting], -1.75 * sx_Plot / this.horizontalUnitScale, -0.25 * sx_Plot / this.horizontalUnitScale);
  }



  void drawData (float[] Ax_LINES, float[] Ay_LINES, float[] Bx_LINES, float[] By_LINES) {
    //this.graphics.stroke(this.color_data_raws);
    //this.graphics.fill(this.color_data_raws);
    //this.graphics.strokeWeight(this.strokeScale * 1);

    this.graphics.stroke(0, PAINT.getOpacity(this.opacityPercentage));
    this.graphics.fill(0, PAINT.getOpacity(this.opacityPercentage));
    this.graphics.strokeWeight(this.strokeScale * 0.5);

    for (int i = 0; i < Ax_LINES.length; i++) {
      this.graphics.line(Ax_LINES[i], Ay_LINES[i], Bx_LINES[i], By_LINES[i]);
    }
  }


  void drawProbs (int i, int j, float[] valuesSUM, float[] valuesNUM, float x_Plot, float y_Plot, float sx_Plot, float sy_Plot) {

    //println("view_S=", this.view_S);
    //println("probabilityHeightInterval=", this.probabilityHeightInterval);

    //float _pix = 100.0 * this.view_S / this.probabilityHeightInterval;
    float _pix = 90.0 * this.view_S / this.probabilityHeightInterval;

    //println("_pix=", _pix);


    int PAL_type = this.probabilitiesColorscaleIndex;
    int PAL_direction = this.probabilitiesColorscaleDirection;
    float PAL_multiplier = this.probabilitiesColorscaleFactor;

    float txt_max_width = (this.probabilityWidthInterval * this.view_S * 100 / 24.0) * this.horizontalUnitScale;
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

      if (currentLayerId == LAYER_winddir.id) min_b = 0;

      int[] probs;
      int totalProbs = 0;

      probs = new int [floor(max_b - min_b) + 1];

      for (int k = 0; k < valuesSUM.length; k++) {
        if (is_defined(valuesSUM[k])) {
          float the_value = valuesSUM[k];

          if (currentLayerId == LAYER_winddir.id) {
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

            _u = applyPalDirection(_u, PAL_direction);

            float[] COL = PAINT.getColorStyle(PAL_type, _u);

            float w = (this.probabilityWidthInterval * this.view_S * 100 / 24.0) * this.horizontalUnitScale;
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

            if ((this.probabilitiesExporter) && (this.showProbabilities)) {
              FILE_outputProbs[(j - this.startDay)].print(nfs((min_b + n) * _pix / abs(sy_Plot) - this.verticalUnitOffset, 5, 5) + ":\t" + nf(100 * prob_V, 3, 3) + "\t");
            }

          }
        }

        if ((this.probabilitiesExporter) && (this.showProbabilities)) {
          FILE_outputProbs[(j - this.startDay)].println("");
        }
      }
    }

    float pal_length = 400;
    float pal_ox = 700;
    float pal_oy = (50 * this.verticalNegativePadding) + 40;

    for (int q = 0; q < 11; q++) {
      float prob_V = 10 * q / 100.0;

      float _u = PAL_multiplier * prob_V;

      _u = applyPalDirection(_u, PAL_direction);

      float[] COL = PAINT.getColorStyle(PAL_type, _u);
      this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
      this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

      this.graphics.strokeWeight(0);

      this.graphics.rect((pal_ox + q * (pal_length / 11.0)) * this.view_S, pal_oy * this.view_S, (pal_length / 11.0) * this.view_S, 20 * this.view_S);

      applyLegendTextStyle(COL);

      this.graphics.textSize(15.0 * this.view_S);
      this.graphics.textAlign(CENTER, CENTER);

      float x = (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S;
      float y = (10 + pal_oy - 0.05 * 20) * this.view_S;

      this.graphics.text((String.valueOf(int(funcs.roundTo(100 * prob_V, 1)))), x, y);
    }
  }


  void drawSorted (int i, int j, float[] valuesA, float[] valuesB, float x_Plot, float y_Plot, float sx_Plot, float sy_Plot) {

    int PAL_type = this.statisticalRangesColorscaleIndex;
    int PAL_direction = this.statisticalRangesColorscaleDirection;
    float PAL_multiplier = this.statisticalRangesColorscaleFactor;

    float[] sortedvaluesA = sort(valuesA);
    int num_sortedvaluesA = countDefinedPrefix(sortedvaluesA);

    float[] sortedvaluesB = sort(valuesB);
    int num_sortedvaluesB = countDefinedPrefix(sortedvaluesB);

    int num_sortedvaluesAB = min(num_sortedvaluesA, num_sortedvaluesB);

    for (int l = 0; l < (num_sortedvaluesAB - 1); l++) {
      float sort_V = 1.1 * (0.5 - ((num_sortedvaluesAB - (l + 1)) / float(num_sortedvaluesAB)));

      float _u = 0.5 + 0.5 * (PAL_multiplier * sort_V);

      _u = applyPalDirection(_u, PAL_direction);

      float[] COL = PAINT.getColorStyle(PAL_type, _u);
      this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
      this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

      this.graphics.strokeWeight(this.strokeScale * 0.0);
      //this.graphics.rect((j + ((i + 1) / 24.0)) * sx_Plot, sortedvaluesA[l] * sy_Plot, -(1 * 100 / 24.0) * this.horizontalUnitScale, (sortedvaluesA[(l + 1)] - sortedvaluesA[l]) * sy_Plot);

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
       this.graphics.strokeWeight(this.strokeScale * 0.5);
       this.graphics.line(P1x, P1y, P4x, P4y);
       this.graphics.line(P2x, P2y, P3x, P3y);
       */
    }

    String[] _txt = {
      "MIN", "", "25%", "", "MED", "", "75%", "", "MAX"
    };
    float pal_length = 400;
    float pal_ox = 700;
    float pal_oy = (50 * this.verticalNegativePadding) + 40;

    for (int q = 0; q < 9; q++) {
      float sort_V = 1.1 * (q - 4) / 8.0;

      float _u = 0.5 + 0.5 * (PAL_multiplier * sort_V);

      _u = applyPalDirection(_u, PAL_direction);

      float[] COL = PAINT.getColorStyle(PAL_type, _u);
      this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
      this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

      //this.graphics.strokeWeight(0.0);
      this.graphics.stroke(255);
      this.graphics.strokeWeight(0.5);
      this.graphics.rect((pal_ox + q * (pal_length / 9.0)) * this.view_S, pal_oy * this.view_S, (pal_length / 9.0) * this.view_S, 20 * this.view_S);

      applyLegendTextStyle(COL);

      this.graphics.textSize(15.0 * this.view_S);
      this.graphics.textAlign(CENTER, CENTER);
      this.graphics.text(_txt[q], (25 + pal_ox + q * (pal_length / 9.0)) * this.view_S, (10 + pal_oy - 0.05 * 20) * this.view_S);
    }
  }


  void drawNormals (int i, int j, float[] valuesA, float[] valuesB, float x_Plot, float y_Plot, float sx_Plot, float sy_Plot) {
    float[] NormalsA = NORMAL(valuesA);
    float[] NormalsB = NORMAL(valuesB);

    if (currentLayerId == LAYER_winddir.id) {
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

      float[] X_NormalsA = NORMAL(XvaluesA);
      float[] Y_NormalsA = NORMAL(YvaluesA);

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

      float[] X_NormalsB = NORMAL(XvaluesB);
      float[] Y_NormalsB = NORMAL(YvaluesB);

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
        this.graphics.strokeWeight(this.strokeScale * 1);
        this.graphics.stroke(0, 191, 0);
        this.graphics.fill(0, 191, 0);
      } else if (l == STAT_N_MidHigh) {
        this.graphics.strokeWeight(this.strokeScale * 1);
        this.graphics.stroke(191, 0, 0);
        this.graphics.fill(191, 0, 0);
      } else if (l == STAT_N_MidLow) {
        this.graphics.strokeWeight(this.strokeScale * 1);
        this.graphics.stroke(0, 0, 191);
        this.graphics.fill(0, 0, 191);
      } else if (l == STAT_N_Max) {
        this.graphics.strokeWeight(this.strokeScale * 1);
        this.graphics.stroke(255, 127, 127);
        this.graphics.fill(255, 127, 127);
      } else if (l == STAT_N_Min) {
        this.graphics.strokeWeight(this.strokeScale * 1);
        this.graphics.stroke(127, 127, 255);
        this.graphics.fill(127, 127, 255);
      } else if (l == STAT_N_M50) {
        this.graphics.strokeWeight(this.strokeScale * 1);
        this.graphics.stroke(0, 127, 0);
        this.graphics.fill(0, 127, 0);
      } else if (l == STAT_N_M75) {
        this.graphics.strokeWeight(this.strokeScale * 1);
        this.graphics.stroke(127, 0, 0);
        this.graphics.fill(127, 0, 0);
      } else if (l == STAT_N_M25) {
        this.graphics.strokeWeight(this.strokeScale * 1);
        this.graphics.stroke(0, 0, 127);
        this.graphics.fill(0, 0, 127);
      } else {
        this.graphics.strokeWeight(this.strokeScale * 1);
        this.graphics.stroke(0, 0, 0);
        this.graphics.fill(0, 0, 0);
      }



      if (l == this.impactLayerIndex) {
       this.graphics.strokeWeight(this.strokeScale * 4);
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

      if ((this.normalLinesExporter) && (this.showNormalLines)) {
        if (is_defined(NormalsA[l])) FILE_outputNorms[(j - this.startDay)].print(nfs(NormalsA[l] - this.verticalUnitOffset, 5, 5) + "\t");
        else FILE_outputNorms[(j - this.startDay)].print("[undefined]\t");
      }
    }
    if ((this.normalLinesExporter) && (this.showNormalLines)) FILE_outputNorms[(j - this.startDay)].println();
  }



  // Draws the "[start-end] <layer description>" title above the hourly plot
  // (top-right: the record range in the current data source's own numbering;
  // top-left: the active layer's description).
  void drawColumnRangeTitle (float sx_Plot, int start_k, int end_k) {
    this.graphics.stroke(0);
    this.graphics.fill(0);
    this.graphics.strokeWeight(this.strokeScale * 0);

    this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
    this.graphics.textAlign(RIGHT, CENTER);

    if (currentDataSource == dataID_climateEngineering) this.graphics.text(("[" + String.valueOf(start_k + climateEngineeringStart) + "-" + String.valueOf(end_k + climateEngineeringStart) + "] "), 0, 1.0 * sx_Plot / this.horizontalUnitScale);
    if (currentDataSource == dataID_climateArchive) this.graphics.text(("[" + String.valueOf(start_k + climateArchiveStart) + "-" + String.valueOf(end_k + climateArchiveStart) + "] "), 0, 1.0 * sx_Plot / this.horizontalUnitScale);
    if (currentDataSource == dataID_ensembleForecast) this.graphics.text(("[" + String.valueOf(start_k + ensembleForecastStart) + "-" + String.valueOf(end_k + ensembleForecastStart) + "] "), 0, 1.0 * sx_Plot / this.horizontalUnitScale);

    this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
    this.graphics.textAlign(LEFT, CENTER);
    this.graphics.text((CurrentLayer_descriptions[activeLanguage]), 0, 1.0 * sx_Plot / this.horizontalUnitScale);
  }

  // Draws the date label (and the "±N days" join-window label, if joining
  // more than one day) above column j, unless it's been thinned out by the
  // 1.5/horizontalUnitScale spacing rule.
  void drawDayHeader (int j, float sx_Plot) {
    this.graphics.stroke(0);
    this.graphics.fill(0);
    this.graphics.textAlign(CENTER, CENTER);

    if ((this.horizontalUnitScale >= 0.75) || (((j - this.startDay) % int(1.5 / this.horizontalUnitScale)) == 0)) {

      float x = (j - ((0 - 12) / 24.0)) * sx_Plot;
      float y = -1.4 * sx_Plot / this.horizontalUnitScale;
      float h = sx_Plot * 0.2 / this.horizontalUnitScale;

      this.graphics.textSize(h);
      this.graphics.text(TIME.getDayText(j * this.dayIncrement + 286 + TIME.beginDay), x, y + h);
      if (this.daysMergedCount > 1) {
        this.graphics.text(("±" + int(this.daysMergedCount / 2) + TIME.WORDS[2][activeLanguage] + "s"), x, y);
      }
    }
  }

  // Opens (and writes the header row for) the raw/normal/probability export
  // files for column j, for whichever of the three are currently enabled.
  // Mirrors closePerDayOutputFiles(), which flushes and closes them again
  // once column j is fully drawn.
  void openPerDayOutputFiles (int j, int count_k, int start_k, int end_k, int DATA_start, String Main_name) {
    String _FilenamesAdd = "";
    if (this.daysMergedCount > 1) {
      _FilenamesAdd = ("±" + int(this.daysMergedCount / 2) + TIME.WORDS[2][activeLanguage] + "s");
    }
    if ((this.rawLinesExporter) && (this.showRawLines)) {
      FILE_outputRaw[(j - this.startDay)] = createWriter(Folder_Export + "/" + Main_name + "/" + databaseString[currentDataSource] + "_node_" + STATION.getCity() + "_from_" + String.valueOf(start_k + DATA_start) + "_to_" + String.valueOf(end_k + DATA_start) + "_" + CurrentLayer_descriptions[Language_EN] + "_" + skyScenarioSetting_FileTXT[this.skyScenarioSetting] + "_" + TIME.getDayText(j * this.dayIncrement + 286 + TIME.beginDay) + _FilenamesAdd + ".txt");
      FILE_outputRaw[(j - this.startDay)].println(TIME.getDayText(j * this.dayIncrement + 286 + TIME.beginDay) + _FilenamesAdd + "\t" + skyScenarioSetting_FileTXT[this.skyScenarioSetting] + "\t" + CurrentLayer_descriptions[Language_EN] + "(" + CurrentLayer_unit + ")" + "\tfrom:" + String.valueOf(start_k + DATA_start) + "\tto:" + String.valueOf(end_k + DATA_start) + "\t" + STATION.getCity() + "\tHourly data");

      FILE_outputRaw[(j - this.startDay)].print("Hour\t");
      for (int k = 0; k < count_k; k++) {
        FILE_outputRaw[(j - this.startDay)].print(nf(k, 4) + "        \t");
      }
      FILE_outputRaw[(j - this.startDay)].println("");
    }
    if ((this.normalLinesExporter) && (this.showNormalLines)) {
      FILE_outputNorms[(j - this.startDay)] = createWriter(Folder_Export + "/" + Main_name + "/" + databaseString[currentDataSource] + "_norm_" + STATION.getCity() + "_from_" + String.valueOf(start_k + DATA_start) + "_to_" + String.valueOf(end_k + DATA_start) + "_" + CurrentLayer_descriptions[Language_EN] + "_" + skyScenarioSetting_FileTXT[this.skyScenarioSetting] + "_" + TIME.getDayText(j * this.dayIncrement + 286 + TIME.beginDay) + _FilenamesAdd + ".txt");
      FILE_outputNorms[(j - this.startDay)].println(TIME.getDayText(j * this.dayIncrement + 286 + TIME.beginDay) + _FilenamesAdd + "\t" + skyScenarioSetting_FileTXT[this.skyScenarioSetting] + "\t" + CurrentLayer_descriptions[Language_EN] + "(" + CurrentLayer_unit + ")" + "\tfrom:" + String.valueOf(start_k + DATA_start) + "\tto:" + String.valueOf(end_k + DATA_start) + "\t" + STATION.getCity() + "\tHourly normal");
      FILE_outputNorms[(j - this.startDay)].print("Hour\t");
      for (int l = 0; l < 9; l++) {
        FILE_outputNorms[(j - this.startDay)].print(STAT_N_Title[l] + "\t");
      }
      FILE_outputNorms[(j - this.startDay)].println("");
    }
    if ((this.probabilitiesExporter) && (this.showProbabilities)) {
      FILE_outputProbs[(j - this.startDay)] = createWriter(Folder_Export + "/" + Main_name + "/" + databaseString[currentDataSource] + "_prob_" + STATION.getCity() + "_from_" + String.valueOf(start_k + DATA_start) + "_to_" + String.valueOf(end_k + DATA_start) + "_" + CurrentLayer_descriptions[Language_EN] + "_" + skyScenarioSetting_FileTXT[this.skyScenarioSetting] + "_" + TIME.getDayText(j * this.dayIncrement + 286 + TIME.beginDay) + _FilenamesAdd + ".txt");
      FILE_outputProbs[(j - this.startDay)].println(TIME.getDayText(j * this.dayIncrement + 286 + TIME.beginDay) + _FilenamesAdd + "\t" + skyScenarioSetting_FileTXT[this.skyScenarioSetting] + "\t" + CurrentLayer_descriptions[Language_EN] + "(" + CurrentLayer_unit + ")" + "\tfrom:" + String.valueOf(start_k + DATA_start) + "\tto:" + String.valueOf(end_k + DATA_start) + "\t" + STATION.getCity() + "\tHourly probabilities");

      FILE_outputProbs[(j - this.startDay)].print("Hour:\t");
      FILE_outputProbs[(j - this.startDay)].println("");
    }
  }

  // Flushes and closes whichever of the raw/normal/probability export files
  // for column j were opened by openPerDayOutputFiles().
  void closePerDayOutputFiles (int j) {
    if ((this.rawLinesExporter) && (this.showRawLines)) {
      FILE_outputRaw[(j - this.startDay)].flush();
      FILE_outputRaw[(j - this.startDay)].close();
    }

    if ((this.normalLinesExporter) && (this.showNormalLines)) {
      FILE_outputNorms[(j - this.startDay)].flush();
      FILE_outputNorms[(j - this.startDay)].close();
    }

    if ((this.probabilitiesExporter) && (this.showProbabilities)) {
      FILE_outputProbs[(j - this.startDay)].flush();
      FILE_outputProbs[(j - this.startDay)].close();
    }
  }

  void plotHourly (float x_Plot, float y_Plot, float sx_Plot, float sy_Plot) {

    int DATA_start = getStart_currentDataSource();
    int DATA_end = getEnd_currentDataSource();
    String DATA_reference = getReference_currentDataSource();

    this.graphics.pushMatrix();
    this.graphics.translate(x_Plot, y_Plot);

    this.color_data_raws = color(0, 0, 63, PAINT.getOpacity(this.opacityPercentage));

    this.drawTimeGrid(x_Plot, y_Plot, sx_Plot, sy_Plot);

    int[] startK_endK = get_startK_endK();
    int start_k = startK_endK[0];
    int end_k = startK_endK[1];
    int count_k = 1 + end_k - start_k;
    if (count_k < 0) count_k = 0;


    if (this.PrintTtitle) {
      this.drawColumnRangeTitle(sx_Plot, start_k, end_k);
    }

    float Pa = FLOAT_undefined;
    float Pb = FLOAT_undefined;

    float[] valuesA;
    float[] valuesB;
    valuesA = new float [count_k * this.daysMergedCount];
    valuesB = new float [count_k * this.daysMergedCount];

    float[] valuesSUM;
    float[] valuesNUM;
    int _interval = 0;
    valuesSUM = new float [count_k * this.daysMergedCount];
    valuesNUM = new float [count_k * this.daysMergedCount];

    java.util.Arrays.fill(valuesA, FLOAT_undefined);
    java.util.Arrays.fill(valuesB, FLOAT_undefined);
    java.util.Arrays.fill(valuesSUM, 0);   // Note: must be initialized to zero; not undefined.
    java.util.Arrays.fill(valuesNUM, 0);

    float[] Ax_LINES = new float [0];
    float[] Ay_LINES = new float [0];
    float[] Bx_LINES = new float [0];
    float[] By_LINES = new float [0];

    FILE_outputRaw = new PrintWriter [(this.endDay - this.startDay)];
    FILE_outputNorms = new PrintWriter [(this.endDay - this.startDay)];
    FILE_outputProbs = new PrintWriter [(this.endDay - this.startDay)];

    String Main_name = MAKE_MainName();

    for (int j = this.startDay; j < this.endDay; j++) {

      this.drawDayHeader(j, sx_Plot);
      this.openPerDayOutputFiles(j, count_k, start_k, end_k, DATA_start, Main_name);

      for (int i = 0; i < 24; i++) {
        if (this.isInHourlyRange(i)) {
          if ((this.rawLinesExporter) && (this.showRawLines)) FILE_outputRaw[(j - this.startDay)].print(nf(i, 2) + "\t");
          if ((this.normalLinesExporter) && (this.showNormalLines)) FILE_outputNorms[(j - this.startDay)].print(nf(i, 2) + "\t");
          if ((this.probabilitiesExporter) && (this.showProbabilities)) FILE_outputProbs[(j - this.startDay)].print(nf(i, 2) + "\t");

          for (int k = 0; k < count_k; k++) {
            for (int j_ADD = 0; j_ADD < this.daysMergedCount; j_ADD++) {
              int idx = k * this.daysMergedCount + j_ADD;

              valuesA[idx] = FLOAT_undefined;
              valuesB[idx] = FLOAT_undefined;
              valuesSUM[idx] = 0;
              valuesNUM[idx] = 1;

              float[] COL = PAINT.getColorStyle(currentColorStyle, (1.0 * k / (1 + DATA_end - DATA_start)));
              this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
              this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);


              int now_k = k + start_k;
              int now_i = i;
              int now_j = computeWrappedDayIndex(j, j_ADD);

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

              Pa = getValue_currentDataSource(now_i, now_j, now_k, currentLayerId);

              if (is_undefined(Pa)) {
                valuesA[idx] = FLOAT_undefined;

                if ((this.rawLinesExporter) && (this.showRawLines)) FILE_outputRaw[(j - this.startDay)].print("[undefined]\t");
              } else {
                boolean isMemberCounted = filter(currentDataSource, LAYER_cloudcover.id, this.temporalFilterSetting, this.skyScenarioSetting, now_i, now_j, now_k);

                if (isMemberCounted) {
                  valuesA[idx] = Pa;
                  valuesA[idx] += this.verticalUnitOffset;

                  valuesSUM[idx] += valuesA[idx];
                  valuesNUM[idx] += 1;

                  if ((this.rawLinesExporter) && (this.showRawLines)) {
                    if (is_defined(valuesA[idx])) {
                      FILE_outputRaw[(j - this.startDay)].print(nfs(valuesA[idx] - this.verticalUnitOffset, 5, 5) + "\t");
                    }
                    else {
                      FILE_outputRaw[(j - this.startDay)].print("[undefined]\t");
                    }
                  }

                  if (next_k < (1 + DATA_end - DATA_start)) {

                    Pb = getValue_currentDataSource(next_i, next_j, next_k, currentLayerId);

                    if (is_undefined(Pb)) {
                      valuesB[idx] = FLOAT_undefined;
                    } else {
                      valuesB[idx] = Pb;
                      valuesB[idx] += this.verticalUnitOffset;

                      if (this.showRawLines) {
                        if ((currentLayerId == LAYER_winddir.id) && (abs(valuesB[idx] - valuesA[idx]) > 180)) {
                        } else {
                          Ax_LINES = append(Ax_LINES, (j + ((i + 0.5) / 24.0)) * sx_Plot);
                          Ay_LINES = append(Ay_LINES, valuesA[idx] * sy_Plot);

                          Bx_LINES = append(Bx_LINES, (j + ((i + 1.5) / 24.0)) * sx_Plot);
                          By_LINES = append(By_LINES, valuesB[idx] * sy_Plot);
                        }
                      }
                    }
                  }
                } else {
                  if ((this.rawLinesExporter) && (this.showRawLines)) FILE_outputRaw[(j - this.startDay)].print("not_the_case\t");
                }
              }
            }
          }


          if ((this.rawLinesExporter) && (this.showRawLines)) FILE_outputRaw[(j - this.startDay)].println();

          if (this.showProbabilities) {
            _interval += 1;
            if ((_interval % this.probabilityWidthInterval) == 0) {
              for (int k = 0; k < count_k; k++) {
                for (int j_ADD = 0; j_ADD < this.daysMergedCount; j_ADD++) {
                  int idx = k * this.daysMergedCount + j_ADD;
                  valuesSUM[idx] += valuesA[idx];
                  valuesNUM[idx] += 1;

                  if (valuesNUM[idx] != 0) {
                    valuesSUM[idx] /= valuesNUM[idx];
                  }
                  else {
                    valuesSUM[idx] = FLOAT_undefined;
                  }
                }
              }

              this.drawProbs(i, j, valuesSUM, valuesNUM, x_Plot, y_Plot, sx_Plot, sy_Plot);
            }
          }

          if (this.showStatisticalRanges) {
            this.drawSorted(i, j, valuesA, valuesB, x_Plot, y_Plot, sx_Plot, sy_Plot);
          }

          if (this.showNormalLines) {
            this.drawNormals(i, j, valuesA, valuesB, x_Plot, y_Plot, sx_Plot, sy_Plot);
          }
        }
      }

      this.closePerDayOutputFiles(j);

    }

    if (this.showRawLines) {
      this.drawData(Ax_LINES, Ay_LINES, Bx_LINES, By_LINES);
    }

    this.graphics.popMatrix();
  }


  void setupPlot () {
    if ((this.plotLayoutIndex == -2) || (this.plotLayoutIndex == -1)) {
      setupPlot_cycles();
    }

    if (this.plotLayoutIndex == 0) {
      setupPlot_0();
    }

    if (this.plotLayoutIndex == 1) {
      setupPlot_1();
    }

    if (this.plotLayoutIndex == 2) {
      setupPlot_2();
    }

    if (this.plotLayoutIndex == 3) {
      setupPlot_3();
    }

    if (this.plotLayoutIndex == 4) {
      setupPlot_4();
    }

    if (this.plotLayoutIndex == 5) {
      setupPlot_5();
    }

    if (this.plotLayoutIndex == 6) {
      setupPlot_6();
    }

    if (this.plotLayoutIndex == 7) {
      setupPlot_7();
    }

    if (this.plotLayoutIndex == 8) {
      setupPlot_8();
    }
  }

  // plotLayoutIndex == -2 / -1 : the single "cycles" diagram (annual active/passive
  // solar cycle) used for the YC-book-style layout. Temporarily overrides the
  // date window (a fixed, 5-day-joined, half-year view starting at day 183)
  // and restores every overridden field afterward.
  void setupPlot_cycles () {
    int keep_TIME_BeginDay = TIME.beginDay;
    float keep_STUDY_dayIncrement = this.dayIncrement;
    int keep_daysMergedCount = this.daysMergedCount;
    int keep_STUDY_startDay = this.startDay;
    int keep_STUDY_endDay = this.endDay;
    float keep_STUDY_horizontalUnitScale = this.horizontalUnitScale;
    int keep_STUDY_impactGraphIndex = this.impactGraphIndex;
    int keep_STUDY_impactTypeIndex = this.impactTypeIndex;

    TIME.beginDay = 183; //0; // 183: to put the summer diagram on the left similar to the YC book
    this.dayIncrement = 183;
    this.daysMergedCount = 5;
    this.startDay = 0;
    this.endDay = 2;
    this.horizontalUnitScale = 18.0 / float(this.endDay - this.startDay);
    this.impactGraphIndex = (this.plotLayoutIndex == -1) ? impactGraphIndex_CYCLES_PASSIVE : impactGraphIndex_CYCLES_ACTIVE;
    this.impactTypeIndex = (this.plotLayoutIndex == -1) ? Impact_PASSIVE : Impact_ACTIVE;

    float scale = (viewLayout == 2) ? 1 : 0.65;
    this.plotImpact(0, 0 * this.view_S, scale * (100.0 * this.horizontalUnitScale * this.view_S), scale * (-1.0 * this.verticalUnitScale * this.view_S));

    TIME.beginDay = keep_TIME_BeginDay;
    this.dayIncrement = keep_STUDY_dayIncrement;
    this.daysMergedCount = keep_daysMergedCount;
    this.startDay = keep_STUDY_startDay;
    this.endDay = keep_STUDY_endDay;
    this.horizontalUnitScale = keep_STUDY_horizontalUnitScale;
    this.impactGraphIndex = keep_STUDY_impactGraphIndex;
    this.impactTypeIndex = keep_STUDY_impactTypeIndex;
  }

  // plotLayoutIndex == 0 : the default layout - one impact diagram (or three, split
  // by impactLayerIndex, in the 2-viewport layout) plus a single hourly plot.
  void setupPlot_0 () {
    float sx_Plot = 100.0 * this.horizontalUnitScale * this.view_S;
    float sy_Plot = -1.0 * this.verticalUnitScale * this.view_S;

    if (viewLayout == 2) {
      for (int p = 0; p < 3; p++) {
        this.impactLayerIndex = 3 * int(pre_STUDY_impactLayerIndex / 3) + p;
        this.plotImpact(0, (150 - p * 300) * this.view_S, sx_Plot, sy_Plot);
      }
      this.impactLayerIndex = pre_STUDY_impactLayerIndex;
    } else {
      this.plotImpact(0, -150 * this.view_S, sx_Plot, sy_Plot);
    }

    this.plotHourly(0, ((viewLayout == 2) ? 450 : 150) * this.view_S, sx_Plot, sy_Plot);
  }

  // plotLayoutIndex == 1 : direct-normal-radiation focus - urban/global impact
  // diagrams (2-viewport only) plus hourly plots of direct radiation and
  // cloud cover.
  void setupPlot_1 () {
    float sx_Plot = 100.0 * this.horizontalUnitScale * this.view_S;

    int keep_impactGraphIndex = this.impactGraphIndex;
    int keep_currentLayerId = currentLayerId;

    if (viewLayout == 2) {
      this.impactGraphIndex = impactGraphIndex_URBAN_ACTIVE;
      this.plotImpact(0, -450 * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

      this.impactGraphIndex = impactGraphIndex_GLOBAL_ACTIVE;
      this.plotImpact(0, -150 * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));
    }

    changeCurrentLayerTo(LAYER_dirnorrad.id);
    this.plotHourly(0, ((viewLayout == 2) ? 150 : -150) * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

    changeCurrentLayerTo(LAYER_cloudcover.id);
    this.plotHourly(0, ((viewLayout == 2) ? 450 : 150) * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

    this.impactGraphIndex = keep_impactGraphIndex;
    changeCurrentLayerTo(keep_currentLayerId);
  }

  // plotLayoutIndex == 2 : direct-solar-effect focus - urban/global passive-impact
  // diagrams (2-viewport only) plus hourly plots of direct effect and dry
  // bulb temperature.
  void setupPlot_2 () {
    float sx_Plot = 100.0 * this.horizontalUnitScale * this.view_S;

    int keep_impactGraphIndex = this.impactGraphIndex;
    int keep_currentLayerId = currentLayerId;

    if (viewLayout == 2) {
      this.impactGraphIndex = impactGraphIndex_URBAN_PASSIVE;
      this.plotImpact(0, -450 * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

      this.impactGraphIndex = impactGraphIndex_GLOBAL_PASSIVE;
      this.plotImpact(0, -150 * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));
    }

    changeCurrentLayerTo(LAYER_direffect.id);
    this.plotHourly(0, ((viewLayout == 2) ? 150 : -150) * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

    changeCurrentLayerTo(LAYER_drybulb.id);
    this.plotHourly(0, ((viewLayout == 2) ? 450 : 150) * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

    this.impactGraphIndex = keep_impactGraphIndex;
    changeCurrentLayerTo(keep_currentLayerId);
  }

  // plotLayoutIndex == 3 : wind focus - wind-impact diagrams plus hourly plots of
  // dry bulb temperature and wind speed.
  void setupPlot_3 () {
    float sx_Plot = 100.0 * this.horizontalUnitScale * this.view_S;

    int keep_impactGraphIndex = this.impactGraphIndex;
    int keep_currentLayerId = currentLayerId;

    if (viewLayout == 2) {
      this.impactGraphIndex = impactGraphIndex_WIND_PASSIVE;
      this.plotImpact(0, -450 * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

      changeCurrentLayerTo(LAYER_drybulb.id);
      this.plotHourly(0, -150 * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));
    }

    this.impactGraphIndex = impactGraphIndex_WIND_ACTIVE;
    this.plotImpact(0, ((viewLayout == 2) ? 150 : -150) * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

    changeCurrentLayerTo(LAYER_windspd.id);
    this.plotHourly(0, ((viewLayout == 2) ? 450 : 150) * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

    this.impactGraphIndex = keep_impactGraphIndex;
    changeCurrentLayerTo(keep_currentLayerId);
  }

  // plotLayoutIndex == 4 : dry-bulb temperature focus - global passive-impact
  // diagrams plus one hourly plot showing sorted/normal statistics and a
  // second showing raw data/probabilities, for the same layer.
  void setupPlot_4 () {
    float sx_Plot = 100.0 * this.horizontalUnitScale * this.view_S;

    int keep_impactLayerIndex = this.impactLayerIndex;
    int keep_impactGraphIndex = this.impactGraphIndex;
    int keep_currentLayerId = currentLayerId;
    boolean keep_showStatisticalRanges = this.showStatisticalRanges;
    boolean keep_showNormalLines = this.showNormalLines;
    boolean keep_showRawLines = this.showRawLines;
    boolean keep_showProbabilities = this.showProbabilities;

    if (viewLayout == 2) {
      this.impactGraphIndex = impactGraphIndex_GLOBAL_PASSIVE;

      this.impactLayerIndex = 3 * int(pre_STUDY_impactLayerIndex / 3);
      this.plotImpact(0, -450 * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

      this.impactLayerIndex = 3 * int(pre_STUDY_impactLayerIndex / 3) + 2;
      this.plotImpact(0, -150 * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));
    }

    changeCurrentLayerTo(LAYER_drybulb.id);

    this.showStatisticalRanges = true;
    this.showNormalLines = true;
    this.showRawLines = false;
    this.showProbabilities = false;
    this.plotHourly(0, ((viewLayout == 2) ? 150 : -150) * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

    this.showStatisticalRanges = false;
    this.showNormalLines = false;
    this.showRawLines = true;
    this.showProbabilities = true;
    this.plotHourly(0, ((viewLayout == 2) ? 450 : 150) * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

    this.impactLayerIndex = keep_impactLayerIndex;
    this.impactGraphIndex = keep_impactGraphIndex;
    changeCurrentLayerTo(keep_currentLayerId);
    this.showStatisticalRanges = keep_showStatisticalRanges;
    this.showNormalLines = keep_showNormalLines;
    this.showRawLines = keep_showRawLines;
    this.showProbabilities = keep_showProbabilities;
  }

  // plotLayoutIndex == 5 : dry bulb temperature across all four sky scenarios, one
  // hourly plot per scenario.
  void setupPlot_5 () {
    setupPlot_acrossSkyScenarios(LAYER_drybulb.id);
  }

  // plotLayoutIndex == 6 : wind speed across all four sky scenarios, one hourly
  // plot per scenario. Shares its implementation with setupPlot_5(); only the
  // layer differs.
  void setupPlot_6 () {
    setupPlot_acrossSkyScenarios(LAYER_windspd.id);
  }

  // Shared implementation for setupPlot_5() and setupPlot_6(): plots the
  // given layer across all four sky scenarios, one hourly plot per scenario.
  void setupPlot_acrossSkyScenarios (int layerId) {
    float sx_Plot = 100.0 * this.horizontalUnitScale * this.view_S;

    int keep_skyScenarioSetting = this.skyScenarioSetting;
    int keep_currentLayerId = currentLayerId;

    changeCurrentLayerTo(layerId);

    if (viewLayout == 2) {
      this.skyScenarioSetting = 1;
      this.plotHourly(0, -450 * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));
    }

    this.skyScenarioSetting = 4;
    this.plotHourly(0, ((viewLayout == 2) ? -150 : -150) * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

    if (viewLayout == 2) {
      this.skyScenarioSetting = 3;
      this.plotHourly(0, 150 * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));
    }

    this.skyScenarioSetting = 2;
    this.plotHourly(0, ((viewLayout == 2) ? 450 : 150) * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

    this.skyScenarioSetting = keep_skyScenarioSetting;
    changeCurrentLayerTo(keep_currentLayerId);
  }

  // plotLayoutIndex == 7 : atmospheric layers - pressure and wind speed (2-viewport
  // only), then relative humidity and dry bulb temperature.
  void setupPlot_7 () {
    float sx_Plot = 100.0 * this.horizontalUnitScale * this.view_S;

    int keep_currentLayerId = currentLayerId;

    if (viewLayout == 2) {
      changeCurrentLayerTo(LAYER_pressure.id);
      this.plotHourly(0, -450 * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

      changeCurrentLayerTo(LAYER_windspd.id);
      this.plotHourly(0, -150 * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));
    }

    changeCurrentLayerTo(LAYER_relhum.id);
    this.plotHourly(0, ((viewLayout == 2) ? 150 : -150) * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

    changeCurrentLayerTo(LAYER_drybulb.id);
    this.plotHourly(0, ((viewLayout == 2) ? 450 : 150) * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

    changeCurrentLayerTo(keep_currentLayerId);
  }

  // plotLayoutIndex == 8 : solar overview - global passive impact and sun-path
  // diagrams, plus (2-viewport only) hourly plots of direct and diffuse
  // horizontal radiation.
  void setupPlot_8 () {
    float sx_Plot = 100.0 * this.horizontalUnitScale * this.view_S;

    int keep_currentLayerId = currentLayerId;

    this.impactGraphIndex = impactGraphIndex_GLOBAL_PASSIVE;
    this.plotImpact(0, ((viewLayout == 2) ? -450 : -150) * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

    this.impactGraphIndex = impactGraphIndex_SUNPATH_PASSIVE;
    this.plotImpact(0, ((viewLayout == 2) ? -150 : 150) * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

    if (viewLayout == 2) {
      changeCurrentLayerTo(LAYER_dirnorrad.id);
      this.plotHourly(0, 150 * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));

      changeCurrentLayerTo(LAYER_difhorrad.id);
      this.plotHourly(0, 450 * this.view_S, sx_Plot, (-1.0 * this.verticalUnitScale * this.view_S));
    }

    changeCurrentLayerTo(keep_currentLayerId);
  }


  float prev_ImageScale = 1;

  void draw () {

    cursor(WAIT);

    if (this.update) {
      updateImageScale();
      beginFrame();
      renderFrame();
      endFrame();
    }

    this.rawLinesExporter = false;
    this.normalLinesExporter = false;
    this.probabilitiesExporter = false;

    cursor(ARROW);
  }

  // Decides this.ImageScale from the current record_PDF / record_IMG flags.
  // If it changed since last frame, several views need a full redraw because
  // switching resolution loses the GL context.
  void updateImageScale () {
    if (this.record_PDF) this.ImageScale = 1;
    else if (this.record_IMG) this.ImageScale = 2;
    else this.ImageScale = 1;

    if (prev_ImageScale != this.ImageScale) {
      prev_ImageScale = this.ImageScale;

      // we need to redraw these due to gl context lost
      WORLD.revise();
      WIN3D.revise();
      this.revise();
      UI_rollout.revise();
      UI_menuBar.revise();
      UI_toolBar.revise();
      UI_caseBar.revise();
      UI_consoleBar.revise();
    }
  }

  // Scales the canvas dimensions up by ImageScale (for PDF/high-res export)
  // and opens the right PGraphics context: a PDF recorder, a scaled-up P2D
  // buffer, or the existing on-screen graphics.
  void beginFrame () {
    //////////////////////////////////
    this.dX *= this.ImageScale;
    this.dY *= this.ImageScale;
    this.strokeScale *= this.ImageScale;
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
  }

  // The actual drawing pass: refreshes developed data if needed, sets up the
  // canvas (background, blend mode, font), then delegates the plot itself to
  // setupPlot().
  void renderFrame () {
    drawnFrame += 1;
    //println("frame:", drawnFrame);

    if (developDataUpdate) {
      if (currentLayerId == LAYER_developed.id) {
        postProcess_developDATA(currentDataSource);
      }
    }

    this.view_S = (this.dX / 2100.0);
    this.horizontalUnitScale = 18.0 / float(this.endDay - this.startDay);

    this.positionX = -0.333 * this.dX;
    this.positionY = 1.0 * this.dY;

    this.graphics.background(255);

    this.graphics.blendMode(BLEND);

    this.graphics.strokeJoin(ROUND);

    this.graphics.textFont(font);

    this.graphics.strokeWeight(0);

    //this.graphics.translate(this.positionX * -0.25, this.positionY * 0.5);
    this.graphics.translate(this.positionX * -0.425, this.positionY * 0.5);

    this.setupPlot();

    //this.graphics.translate(this.positionX * 0.25, this.positionY * 0.5);
    this.graphics.translate(this.positionX * 0.425, this.positionY * 0.5);

    this.graphics.strokeWeight(this.strokeScale * 1);

    this.graphics.stroke(63);
    this.graphics.fill(63);
    this.graphics.textAlign(CENTER, CENTER);

    // NOTE: this caption is built but never actually drawn - the this.graphics.text(txt, ...)
    // call below is commented out in the original source. Preserved as-is (dead code, not
    // functional) rather than removed, in case it's meant to be re-enabled later.
    String txt = "SOLARCHVISION post-processing";

    if (currentDataSource == dataID_climateTypicalYear) txt += " based on typical-year data for Building Energy Simulation";  //"(TMYEPW - U.S. Department of Energy)";
    if (currentDataSource == dataID_climateEngineering) txt += " based on long-term Canadian Weather Energy and Engineering Datasets (CWEEDS - Environment and Climate Change Canada)";
    if (currentDataSource == dataID_climateArchive) txt += " based on Environment and Climate Change Canada's Climate website";
    if (currentDataSource == dataID_ensembleForecast) txt += " based on the North American Ensemble Forecast System (NAEFS - Environment and Climate Change Canada)";
    if (currentDataSource == dataID_ensembleObservation) txt += " based on real-time Surface Weather Observation (SWOB - Environment and Climate Change Canada)";

    //txt += ", www.solarchvision.com";

    this.graphics.textSize(this.dX * 0.01);
    ///this.graphics.text(txt, this.dX * 0.55, this.dY * -0.1666 / this.view_R, 0);
  }

  // Closes out the recording/drawing (writing a PDF or JPEG if requested,
  // otherwise blitting the buffer to screen), then restores the canvas
  // dimensions that beginFrame() scaled up.
  void endFrame () {
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
    this.strokeScale /= this.ImageScale;
    //////////////////////////////////

    if ((this.ImageScale != 1) || (this.record_PDF)) {
      this.graphics = createGraphics(this.dX, this.dY, P2D);
    }

    this.updated();

    if ((this.record_IMG) || (this.record_AUTO == false)) this.record_IMG = false;
  }


  void refreshDateTabs () {
    if ((currentDataSource == dataID_climateEngineering) ||
        (currentDataSource == dataID_climateArchive) ||
        (currentDataSource == dataID_climateTypicalYear)) {

      if (this.dayIncrement == 1) {
        this.dayIncrement = int(365 / float(this.endDay - this.startDay));
      } else {
        this.dayIncrement = 1;
      }
    }
    if (currentDataSource == dataID_ensembleForecast) {
      this.dayIncrement = 1;
    }
    if (currentDataSource == dataID_ensembleObservation) {
      if (this.dayIncrement == 1) {
        this.dayIncrement = int(ensembleObservationMaxDays / float(this.endDay - this.startDay));
      } else {
        this.dayIncrement = 1;
      }
    }
  }



  void plotImpact_wind (int start_k, int end_k, int count_k, float x_Plot, float y_Plot, float sx_Plot, float sy_Plot) {

    allWindRoses.resize_Image_array();

    int RES = allWindRoses.imageResolution;

    allWindRoses.renderedResolution = RES;

    if (this.impactGraphIndex == impactGraphIndex_WIND_ACTIVE) this.impactTypeIndex = Impact_ACTIVE;
    if (this.impactGraphIndex == impactGraphIndex_WIND_PASSIVE) this.impactTypeIndex = Impact_PASSIVE;

    float Pa = FLOAT_undefined;
    float Pb = FLOAT_undefined;
    float Pc = FLOAT_undefined;

    float[] values_W_dir;
    float[] values_W_spd;
    float[] values_W_tmp;
    values_W_dir = new float [count_k];
    values_W_spd = new float [count_k];
    values_W_tmp = new float [count_k];

    java.util.Arrays.fill(values_W_dir, FLOAT_undefined);
    java.util.Arrays.fill(values_W_spd, FLOAT_undefined);
    java.util.Arrays.fill(values_W_tmp, FLOAT_undefined);

    int PAL_type = 0;
    int PAL_direction = 1;

    if (this.impactTypeIndex == Impact_ACTIVE) {
      PAL_type = this.activeColorscaleIndex;
      PAL_direction = this.activeColorscaleDirection;
    }
    if (this.impactTypeIndex == Impact_PASSIVE) {
      //PAL_type = this.activeColorscaleIndex; PAL_direction = this.activeColorscaleDirection;
      PAL_type = 12;
      PAL_direction = -1;
    }

    float PAL_multiplier = 1;
    if (this.impactTypeIndex == Impact_ACTIVE) PAL_multiplier = 1.0;
    if (this.impactTypeIndex == Impact_PASSIVE) PAL_multiplier = 1.0 / 30.0;

    for (int j = this.startDay; j < this.endDay; j++) {

      PGraphics WIND_graphics = createGraphics(RES, RES);
      WIND_graphics.beginDraw();
      //WIND_graphics.background(255);
      WIND_graphics.translate(0.5 * RES, 0.5 * RES);

      for (int j_ADD = 0; j_ADD < this.daysMergedCount; j_ADD++) {
        for (int i = 0; i < 24; i++) {
          if (this.isInHourlyRange(i)) {

            java.util.Arrays.fill(values_W_dir, FLOAT_undefined);
            java.util.Arrays.fill(values_W_spd, FLOAT_undefined);
            java.util.Arrays.fill(values_W_tmp, FLOAT_undefined);

            for (int k = 0; k < count_k; k++) {

              int _plot = 1;

              if (_plot == 1) {

                int now_k = k + start_k;
                int now_i = i;
                int now_j = computeWrappedDayIndex(j, j_ADD);

                Pa = getValue_currentDataSource(now_i, now_j, now_k, LAYER_winddir.id);
                Pb = getValue_currentDataSource(now_i, now_j, now_k, LAYER_windspd.id);
                Pc = getValue_currentDataSource(now_i, now_j, now_k, LAYER_drybulb.id);

                if (is_undefined(Pa) || is_undefined(Pb) || is_undefined(Pc)) {
                  values_W_dir[k] = FLOAT_undefined;
                  values_W_spd[k] = FLOAT_undefined;
                  values_W_tmp[k] = FLOAT_undefined;
                } else {
                  boolean isMemberCounted = filter(currentDataSource, LAYER_cloudcover.id, this.temporalFilterSetting, this.skyScenarioSetting, now_i, now_j, now_k);

                  if (isMemberCounted) {

                    values_W_dir[k] = Pa;
                    values_W_spd[k] = Pb;
                    values_W_tmp[k] = Pc;

                    float T = values_W_tmp[k];
                    float teta = values_W_dir[k];
                    float D_teta = 15;
                    float R = (0.5 * RES) * (LAYER_windspd.verticalUnitScale / 2.0) * (values_W_spd[k] / 50.0);

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

                    if (this.impactTypeIndex == Impact_ACTIVE) {

                      float _s = (this.opacityPercentage / 100) * 255 / (0.333 * count_k);

                      if (this.skyScenarioSetting > 1) _s *= 3; // to improve visibility of those cases.

                      _s /= float(this.daysMergedCount);

                      if (_s < 10) _s = 10;

                      WIND_graphics.stroke(0, _s);
                      WIND_graphics.fill(0, _s);

                      WIND_graphics.strokeWeight(this.strokeScale * 0);
                    }
                    if (this.impactTypeIndex == Impact_PASSIVE) {
                      _u = 0.5 + 0.5 * (PAL_multiplier * T);

                      _u = applyPalDirection(_u, PAL_direction);

                      float[] COL = PAINT.getColorStyle(PAL_type, _u);

                      WIND_graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

                      WIND_graphics.strokeWeight(this.strokeScale * 2);
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

    for (int j = this.startDay; j < this.endDay; j++) {
      for (int j_ADD = 0; j_ADD < this.daysMergedCount; j_ADD++) {
        for (int i = 0; i < 24; i++) {
          if (this.isInHourlyRange(i)) {

            java.util.Arrays.fill(values_W_dir, FLOAT_undefined);
            java.util.Arrays.fill(values_W_spd, FLOAT_undefined);
            java.util.Arrays.fill(values_W_tmp, FLOAT_undefined);

            for (int k = 0; k < count_k; k++) {

              int _plot = 1;

              if (_plot == 1) {

                int now_k = k + start_k;
                int now_i = i;
                int now_j = computeWrappedDayIndex(j, j_ADD);

                Pa = getValue_currentDataSource(now_i, now_j, now_k, LAYER_winddir.id);
                Pb = getValue_currentDataSource(now_i, now_j, now_k, LAYER_windspd.id);
                Pc = getValue_currentDataSource(now_i, now_j, now_k, LAYER_drybulb.id);

                if (is_undefined(Pa) || is_undefined(Pb) || is_undefined(Pc)) {
                  values_W_dir[k] = FLOAT_undefined;
                  values_W_spd[k] = FLOAT_undefined;
                  values_W_tmp[k] = FLOAT_undefined;
                } else {
                  boolean isMemberCounted = filter(currentDataSource, LAYER_cloudcover.id, this.temporalFilterSetting, this.skyScenarioSetting, now_i, now_j, now_k);

                  if (isMemberCounted) {

                    values_W_dir[k] = Pa;
                    values_W_spd[k] = Pb;
                    values_W_tmp[k] = Pc;

                    float T = values_W_tmp[k];
                    float teta = values_W_dir[k];
                    float D_teta = 15;
                    float R = (0.5 * RES) * (LAYER_windspd.verticalUnitScale / 2.0) * (values_W_spd[k] / 50.0);

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

                    if (this.impactTypeIndex == Impact_ACTIVE) {

                      float _s = (this.opacityPercentage / 100) * 255 / (0.333 * count_k) / (this.endDay - this.startDay);

                      if (this.skyScenarioSetting > 1) _s *= 3; // to improve visibility of those cases.

                      _s /= float(this.daysMergedCount);

                      if (_s < 10) _s = 10;

                      total_WIND_graphics.stroke(0, _s);
                      total_WIND_graphics.fill(0, _s);

                      total_WIND_graphics.strokeWeight(this.strokeScale * 0);
                    }
                    if (this.impactTypeIndex == Impact_PASSIVE) {
                      _u = 0.5 + 0.5 * (PAL_multiplier * T);

                      _u = applyPalDirection(_u, PAL_direction);

                      float[] COL = PAINT.getColorStyle(PAL_type, _u);
                      total_WIND_graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

                      total_WIND_graphics.strokeWeight(this.strokeScale * 2);
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

    for (int j = this.startDay - 1; j < this.endDay; j++) {
      if ((j != -1) || (this.showImpactSummary)) {
        this.graphics.strokeWeight(this.strokeScale * 0);
        this.graphics.stroke(223);
        this.graphics.fill(223);
        this.graphics.rect((j + (this.centralGraphOffsetX + 0.5) - 100 * (this.centralGraphScale / 200)) * sx_Plot, (-100 * (this.centralGraphScale / 200)) * sx_Plot, (200 * (this.centralGraphScale / 200)) * sx_Plot, (200 * (this.centralGraphScale / 200)) * sx_Plot);

        this.graphics.strokeWeight(this.strokeScale * 2);
        this.graphics.stroke(255);
        this.graphics.noFill();
        this.graphics.rect((j + (this.centralGraphOffsetX + 0.5) - 100 * (this.centralGraphScale / 200)) * sx_Plot, (-100 * (this.centralGraphScale / 200)) * sx_Plot, (200 * (this.centralGraphScale / 200)) * sx_Plot, (200 * (this.centralGraphScale / 200)) * sx_Plot);

        this.graphics.imageMode(CENTER);
        this.graphics.image(allWindRoses.Image[j + 1], (j + 100 * (this.centralGraphScale / 200)) * sx_Plot, 0, int((180 * (this.centralGraphScale / 200)) * sx_Plot), int((180 * (this.centralGraphScale / 200)) * sx_Plot));
      }
    }

    this.drawPositionGrid(x_Plot, y_Plot, sx_Plot, sy_Plot, 0);

    if (this.showImpactSummary) {
      int j = -1; // << to put the summary graph before the daily graphs

      int keep_STUDY_startDay = this.startDay;
      int keep_STUDY_endDay = this.endDay;
      this.startDay = j;
      this.endDay = j + 1;
      this.drawPositionGrid(x_Plot, y_Plot, sx_Plot, sy_Plot, 0);
      this.startDay = keep_STUDY_startDay;
      this.endDay = keep_STUDY_endDay;

      this.graphics.strokeWeight(this.strokeScale * 2);
      this.graphics.stroke(0);
      this.graphics.noFill();
      this.graphics.rect((j + (this.centralGraphOffsetX + 0.5) - 100 * (this.centralGraphScale / 200)) * sx_Plot, (-100 * (this.centralGraphScale / 200)) * sx_Plot, (200 * (this.centralGraphScale / 200)) * sx_Plot, (200 * (this.centralGraphScale / 200)) * sx_Plot);
    }

    if (this.impactTypeIndex != Impact_ACTIVE) {

      float pal_length = 400;
      float pal_ox = 700;
      float pal_oy = 110;
      for (int q = 0; q < 11; q++) {
        float _u = 0;

        if (this.impactTypeIndex == Impact_PASSIVE) _u = 0.1 * q;

        _u = applyPalDirection(_u, PAL_direction);

        float[] COL = PAINT.getColorStyle(PAL_type, _u);
        this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
        this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

        this.graphics.strokeWeight(0);
        this.graphics.rect((pal_ox + q * (pal_length / 11.0)) * this.view_S, pal_oy * this.view_S, (pal_length / 11.0) * this.view_S, 20 * this.view_S);

        applyLegendTextStyle(COL);

        this.graphics.textSize(15.0 * this.view_S);
        this.graphics.textAlign(CENTER, CENTER);

        if (this.impactTypeIndex == Impact_PASSIVE) this.graphics.text(nf(0.2 * (q - 5) / PAL_multiplier, 1, 1), (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S, (10 + pal_oy - 0.05 * 20) * this.view_S);
      }
    }


    if (this.PrintTtitle) {

      this.graphics.stroke(0);
      this.graphics.fill(0);
      this.graphics.strokeWeight(this.strokeScale * 0);

      this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
      this.graphics.textAlign(RIGHT, TOP);
      if (currentDataSource == dataID_climateEngineering) this.graphics.text(("[" + String.valueOf(start_k + climateEngineeringStart) + "-" + String.valueOf(end_k + climateEngineeringStart) + "] "), 0, -1.2 * sx_Plot / this.horizontalUnitScale);
      if (currentDataSource == dataID_climateArchive) this.graphics.text(("[" + String.valueOf(start_k + climateArchiveStart) + "-" + String.valueOf(end_k + climateArchiveStart) + "] "), 0, -1.2 * sx_Plot / this.horizontalUnitScale);
      if (currentDataSource == dataID_ensembleForecast) this.graphics.text(("[" + String.valueOf(start_k + ensembleForecastStart) + "-" + String.valueOf(end_k + ensembleForecastStart) + "] "), 0, -1.2 * sx_Plot / this.horizontalUnitScale);

      this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
      this.graphics.textAlign(LEFT, TOP);
      if (this.impactTypeIndex == Impact_ACTIVE) {
        this.graphics.text(("Wind direction and speed"), 0, 1.1 * sx_Plot / this.horizontalUnitScale);
        //?? French
      }
      if (this.impactTypeIndex == Impact_PASSIVE) {
        this.graphics.text(("Wind direction and speed with air temperature"), 0, 1.1 * sx_Plot / this.horizontalUnitScale);
        //?? French
      }
    }

    if (allWindRoses.displayImage) {
      view_changed();
    }
  }


  void plotImpact_urban (int start_k, int end_k, float sx_Plot) {

    if (this.updateImpactGraph) {

      allSolarImpacts.calculate_Impact_CurrentPreBaked();

      int RES1 = allSolarImpacts.RES1;
      int RES2 = allSolarImpacts.RES2;

      float sizeX = (180 * (this.centralGraphScale / 200)) * sx_Plot;
      float sizeY = sizeX;
      float aspect = 1.0 * RES1 / RES2;
      if (aspect > 1) {
        sizeY /= aspect;
      } else if (aspect < 1) {
        sizeX *= aspect;
      }

      if (this.impactGraphIndex == impactGraphIndex_URBAN_ACTIVE) this.impactTypeIndex = Impact_ACTIVE;
      if (this.impactGraphIndex == impactGraphIndex_URBAN_PASSIVE) this.impactTypeIndex = Impact_PASSIVE;

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

      if (this.impactTypeIndex == Impact_ACTIVE) {
        PAL_type = allFaces.activeColorscaleIndex;
        PAL_direction = allFaces.activeColorscaleDirection;
        PAL_multiplier = allFaces.activeColorscaleFactor;
      }
      if (this.impactTypeIndex == Impact_PASSIVE) {
        PAL_type = allFaces.passiveColorscaleIndex;
        PAL_direction = allFaces.passiveColorscaleDirection;
        PAL_multiplier = allFaces.passiveColorscaleFactor;
      }

      int l = this.impactLayerIndex;

      for (int j = this.startDay; j < this.endDay; j++) {

        now_j = (j * int(this.dayIncrement) + TIME.beginDay + 365) % 365;

        if (now_j >= 365) {
          now_j = now_j % 365;
        }
        if (now_j < 0) {
          now_j = (now_j + 365) % 365;
        }


        this.graphics.strokeWeight(this.strokeScale * 0);
        this.graphics.stroke(223);
        this.graphics.fill(223);
        this.graphics.rect((j + (this.centralGraphOffsetX + 0.5) - 100 * (this.centralGraphScale / 200)) * sx_Plot, (-100 * (this.centralGraphScale / 200)) * sx_Plot, (200 * (this.centralGraphScale / 200)) * sx_Plot, (200 * (this.centralGraphScale / 200)) * sx_Plot);

        this.graphics.strokeWeight(this.strokeScale * 2);
        this.graphics.stroke(255);
        this.graphics.noFill();
        this.graphics.rect((j + (this.centralGraphOffsetX + 0.5) - 100 * (this.centralGraphScale / 200)) * sx_Plot, (-100 * (this.centralGraphScale / 200)) * sx_Plot, (200 * (this.centralGraphScale / 200)) * sx_Plot, (200 * (this.centralGraphScale / 200)) * sx_Plot);

        this.graphics.imageMode(CENTER);
        this.graphics.image(allSolarImpacts.Image[this.impactTypeIndex][j + 1], (j + 100 * (this.centralGraphScale / 200)) * sx_Plot, 0, int(sizeX), int(sizeY));

        this.graphics.stroke(0);
        this.graphics.fill(0);
        this.graphics.textAlign(CENTER, CENTER);
        this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);

        String scenario_text = "";
        //if (currentDataSource == dataID_climateEngineering) scenario_text += "Year: " + nf(nk + climateEngineeringStart - 1, 0);
        //if (currentDataSource == dataID_climateArchive) scenario_text += "Year: " + nf(nk + climateArchiveStart - 1, 0);
        //if (currentDataSource == dataID_ensembleForecast) scenario_text += "Member: " + nf(nk, 0);
        this.graphics.text(scenario_text, (j - ((0 - 12) / 24.0)) * sx_Plot, 0.9 * sx_Plot / this.horizontalUnitScale);
      }

      WIN3D.showSolarImpact = true;

      if (this.showImpactSummary) {
        int j = -1; // << to put the summary graph before the daily graphs

        this.graphics.strokeWeight(this.strokeScale * 0);
        this.graphics.stroke(223);
        this.graphics.fill(223);
        this.graphics.rect((j + (this.centralGraphOffsetX + 0.5) - 100 * (this.centralGraphScale / 200)) * sx_Plot, (-100 * (this.centralGraphScale / 200)) * sx_Plot, (200 * (this.centralGraphScale / 200)) * sx_Plot, (200 * (this.centralGraphScale / 200)) * sx_Plot);

        this.graphics.strokeWeight(this.strokeScale * 2);
        this.graphics.stroke(0);
        this.graphics.noFill();
        this.graphics.rect((j + (this.centralGraphOffsetX + 0.5) - 100 * (this.centralGraphScale / 200)) * sx_Plot, (-100 * (this.centralGraphScale / 200)) * sx_Plot, (200 * (this.centralGraphScale / 200)) * sx_Plot, (200 * (this.centralGraphScale / 200)) * sx_Plot);

        this.graphics.imageMode(CENTER);
        this.graphics.image(allSolarImpacts.Image[this.impactTypeIndex][0], (j + 100 * (this.centralGraphScale / 200)) * sx_Plot, 0, int(sizeX), int(sizeY));

        this.graphics.stroke(0);
        this.graphics.fill(0);
        this.graphics.textAlign(CENTER, CENTER);
        this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
      }

      String scenario_text = "";
      //if (currentDataSource == dataID_climateEngineering) scenario_text += "Year: " + nf(nk + climateEngineeringStart - 1, 0);
      //if (currentDataSource == dataID_climateArchive) scenario_text += "Year: " + nf(nk + climateArchiveStart - 1, 0);
      //if (currentDataSource == dataID_ensembleForecast) scenario_text += "Member: " + nf(nk, 0);
      this.graphics.text(scenario_text, ((this.startDay - 1) - ((0 - 12) / 24.0)) * sx_Plot, 0.9 * sx_Plot / this.horizontalUnitScale);

      this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
      this.graphics.textAlign(RIGHT, CENTER);
      this.graphics.stroke(0);
      this.graphics.fill(0);
      this.graphics.strokeWeight(0);

      this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
      this.graphics.textAlign(RIGHT, CENTER);
      this.graphics.stroke(0);
      this.graphics.fill(0);
      this.graphics.strokeWeight(0);

      this.graphics.text(STAT_N_Title[l], -0.3 * sx_Plot / this.horizontalUnitScale, 1.2 * sx_Plot / this.horizontalUnitScale);
      //?? French


      float pal_length = 400;
      float pal_ox = 700;
      float pal_oy = 110;
      for (int q = 0; q < 11; q++) {
        float _u = 0;

        if (this.impactTypeIndex == Impact_ACTIVE) _u = 0.1 * q;
        if (this.impactTypeIndex == Impact_PASSIVE) _u = 0.2 * q - 0.5;

        _u = applyPalDirection(_u, PAL_direction);

        float[] COL = PAINT.getColorStyle(PAL_type, _u);
        this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
        this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

        this.graphics.strokeWeight(0);
        this.graphics.rect((pal_ox + q * (pal_length / 11.0)) * this.view_S, pal_oy * this.view_S, (pal_length / 11.0) * this.view_S, 20 * this.view_S);

        applyLegendTextStyle(COL);

        this.graphics.textSize(15.0 * this.view_S);
        this.graphics.textAlign(CENTER, CENTER);
        if (this.impactTypeIndex == Impact_ACTIVE) this.graphics.text(nf((funcs.roundTo(0.1 * q / PAL_multiplier, 0.1)), 1, 1), (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S, (10 + pal_oy - 0.05 * 20) * this.view_S);
        if (this.impactTypeIndex == Impact_PASSIVE) this.graphics.text(nf(funcs.roundTo(0.4 * (q - 5) / PAL_multiplier, 0.1), 1, 1), (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S, (10 + pal_oy - 0.05 * 20) * this.view_S);
      }

      if (this.PrintTtitle) {

        this.graphics.stroke(0);
        this.graphics.fill(0);
        this.graphics.strokeWeight(this.strokeScale * 0);

        this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
        this.graphics.textAlign(RIGHT, TOP);
        if (currentDataSource == dataID_climateEngineering) this.graphics.text(("[" + String.valueOf(start_k + climateEngineeringStart) + "-" + String.valueOf(end_k + climateEngineeringStart) + "] "), 0, -1.2 * sx_Plot / this.horizontalUnitScale);
        if (currentDataSource == dataID_climateArchive) this.graphics.text(("[" + String.valueOf(start_k + climateArchiveStart) + "-" + String.valueOf(end_k + climateArchiveStart) + "] "), 0, -1.2 * sx_Plot / this.horizontalUnitScale);
        if (currentDataSource == dataID_ensembleForecast) this.graphics.text(("[" + String.valueOf(start_k + ensembleForecastStart) + "-" + String.valueOf(end_k + ensembleForecastStart) + "] "), 0, -1.2 * sx_Plot / this.horizontalUnitScale);


        String Model_Description = "";


        this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
        this.graphics.textAlign(LEFT, TOP);
        if (this.impactTypeIndex == Impact_ACTIVE) {
          this.graphics.text((Model_Description + "Analysis of Active Potentials (kW/m²)"), 0, 1.1 * sx_Plot / this.horizontalUnitScale);
          //?? French
        }
        if (this.impactTypeIndex == Impact_PASSIVE) {
          this.graphics.text((Model_Description + "Analysis of Passive Potentials (%kW°C/m²)"), 0, 1.1 * sx_Plot / this.horizontalUnitScale);
          //?? French
        }
      }
    }

    if (allSolarImpacts.displayImage) {
      view_changed();
    }

  }


  void plotImpact_global (int start_k, int end_k, float x_Plot, float y_Plot, float sx_Plot, float sy_Plot) {

    if (GlobalSolar_rebuild_array) {
      GlobalSolar_resize_array();
    }

    if (this.impactGraphIndex == impactGraphIndex_GLOBAL_ACTIVE) this.impactTypeIndex = Impact_ACTIVE;
    if (this.impactGraphIndex == impactGraphIndex_GLOBAL_PASSIVE) this.impactTypeIndex = Impact_PASSIVE;

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

    if (this.impactTypeIndex == Impact_ACTIVE) {
      PAL_type = this.activeColorscaleIndex;
      PAL_direction = this.activeColorscaleDirection;
    }
    if (this.impactTypeIndex == Impact_PASSIVE) {
      PAL_type = this.passiveColorscaleIndex;
      PAL_direction = this.passiveColorscaleDirection;
    }

    float PAL_multiplier = 1;
    if (this.impactTypeIndex == Impact_ACTIVE) PAL_multiplier = this.activeColorscaleFactor;
    if (this.impactTypeIndex == Impact_PASSIVE) PAL_multiplier = this.passiveColorscaleFactor;


    int l = this.impactLayerIndex;

    float[][] TOTALvaluesSUM_RAD = new float [1 + int(90 / Sky3D.inclinationStep)][1 + int(360 / Sky3D.orientationStep)];
    float[][] TOTALvaluesSUM_EFF_P = new float [1 + int(90 / Sky3D.inclinationStep)][1 + int(360 / Sky3D.orientationStep)];
    float[][] TOTALvaluesSUM_EFF_N = new float [1 + int(90 / Sky3D.inclinationStep)][1 + int(360 / Sky3D.orientationStep)];
    int[][] TOTALvaluesNUM = new int [1 + int(90 / Sky3D.inclinationStep)][1 + int(360 / Sky3D.orientationStep)];

    for (int a = 0; a <= int (90 / Sky3D.inclinationStep); a++) {
      java.util.Arrays.fill(TOTALvaluesSUM_RAD[a], FLOAT_undefined);
      java.util.Arrays.fill(TOTALvaluesSUM_EFF_P[a], FLOAT_undefined);
      java.util.Arrays.fill(TOTALvaluesSUM_EFF_N[a], FLOAT_undefined);
      java.util.Arrays.fill(TOTALvaluesNUM[a], 0);
    }

    for (int j = this.startDay; j < this.endDay; j++) {

      now_j = (j * int(this.dayIncrement) + TIME.beginDay + 365) % 365;

      if (now_j >= 365) {
        now_j = now_j % 365;
      }
      if (now_j < 0) {
        now_j = (now_j + 365) % 365;
      }

      float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);

      int nk = FIND_SCENARIO_CLOSE_TO_DAILY_STAT(l, start_k, end_k, j, DATE_ANGLE, this.impactTypeIndex);
      if (nk == -1) continue;

      int k = int(nk / this.daysMergedCount);
      int j_ADD = nk % this.daysMergedCount;

      for (int a = 0; a <= int (90 / Sky3D.inclinationStep); a++) {
        float Alpha = a * Sky3D.inclinationStep;
        for (int b = 0; b < int (360 / Sky3D.orientationStep); b++) {
          float Beta = b * Sky3D.orientationStep;

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
                now_j = computeWrappedDayIndex(j, j_ADD);

                Pa = getValue_currentDataSource(now_i, now_j, now_k, LAYER_dirnorrad.id);
                Pb = getValue_currentDataSource(now_i, now_j, now_k, LAYER_difhorrad.id);
                Pc = getValue_currentDataSource(now_i, now_j, now_k, LAYER_direffect.id);
                Pd = getValue_currentDataSource(now_i, now_j, now_k, LAYER_difeffect.id);

                if (is_undefined(Pa) || is_undefined(Pb) || is_undefined(Pc) || is_undefined(Pd)) {
                  values_R_dir = FLOAT_undefined;
                  values_R_dif = FLOAT_undefined;
                  values_E_dir = FLOAT_undefined;
                  values_E_dif = FLOAT_undefined;
                } else {

                  boolean isMemberCounted = filter(currentDataSource, LAYER_cloudcover.id, this.temporalFilterSetting, this.skyScenarioSetting, now_i, now_j, now_k);

                  if (isMemberCounted) {
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
                        valuesSUM_EFF_N += -SolarAtSurface(SunR[1], SunR[2], SunR[3], values_E_dir, values_E_dif, Alpha, Beta, globalAlbedo);
                      } else {
                        valuesSUM_EFF_P += SolarAtSurface(SunR[1], SunR[2], SunR[3], values_E_dir, values_E_dif, Alpha, Beta, globalAlbedo);
                      }

                      valuesSUM_RAD += SolarAtSurface(SunR[1], SunR[2], SunR[3], values_R_dir, values_R_dif, Alpha, Beta, globalAlbedo);

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
          if (this.impactTypeIndex == Impact_ACTIVE) valuesSUM = valuesSUM_RAD;
          if (this.impactTypeIndex == Impact_PASSIVE) valuesSUM = COMPARISON;

          //if ((Alpha == 90.0) && (Beta == 0.0)) println("SPHERICAL >> valuesSUM_RAD:", valuesSUM_RAD, "COMPARISON:", COMPARISON);

          if (is_defined(valuesSUM)) {

            float _u = 0;

            if (this.impactTypeIndex == Impact_ACTIVE) _u = (0.1 * PAL_multiplier * valuesSUM);
            if (this.impactTypeIndex == Impact_PASSIVE) _u = 0.5 + 0.5 * (0.1 * PAL_multiplier * valuesSUM);

            _u = applyPalDirection(_u, PAL_direction);

            //float[] COL = PAINT.getColorStyle(PAL_type, _u);
            float[] COL = PAINT.getColorStyle(PAL_type, funcs.roundTo(_u, 0.1));
            this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
            this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);


            this.graphics.strokeWeight(0);

            float x1 = (j + (this.centralGraphOffsetX + 0.5) + (90 - Alpha - 0.5 * Sky3D.inclinationStep) * (this.centralGraphScale / 200) * (funcs.cos_ang(Beta - 90 - 0.5 * Sky3D.orientationStep))) * sx_Plot;
            float y1 = (                         -(90 - Alpha - 0.5 * Sky3D.inclinationStep) * (this.centralGraphScale / 200) * (funcs.sin_ang(Beta - 90 - 0.5 * Sky3D.orientationStep))) * sx_Plot;
            float x2 = (j + (this.centralGraphOffsetX + 0.5) + (90 - Alpha + 0.5 * Sky3D.inclinationStep) * (this.centralGraphScale / 200) * (funcs.cos_ang(Beta - 90 - 0.5 * Sky3D.orientationStep))) * sx_Plot;
            float y2 = (                         -(90 - Alpha + 0.5 * Sky3D.inclinationStep) * (this.centralGraphScale / 200) * (funcs.sin_ang(Beta - 90 - 0.5 * Sky3D.orientationStep))) * sx_Plot;

            float x3 = (j + (this.centralGraphOffsetX + 0.5) + (90 - Alpha + 0.5 * Sky3D.inclinationStep) * (this.centralGraphScale / 200) * (funcs.cos_ang(Beta - 90 + 0.5 * Sky3D.orientationStep))) * sx_Plot;
            float y3 = (                         -(90 - Alpha + 0.5 * Sky3D.inclinationStep) * (this.centralGraphScale / 200) * (funcs.sin_ang(Beta - 90 + 0.5 * Sky3D.orientationStep))) * sx_Plot;
            float x4 = (j + (this.centralGraphOffsetX + 0.5) + (90 - Alpha - 0.5 * Sky3D.inclinationStep) * (this.centralGraphScale / 200) * (funcs.cos_ang(Beta - 90 + 0.5 * Sky3D.orientationStep))) * sx_Plot;
            float y4 = (                         -(90 - Alpha - 0.5 * Sky3D.inclinationStep) * (this.centralGraphScale / 200) * (funcs.sin_ang(Beta - 90 + 0.5 * Sky3D.orientationStep))) * sx_Plot;

            this.graphics.quad(x1, y1, x2, y2, x3, y3, x4, y4);
          }
        }
      }

      this.graphics.stroke(0);
      this.graphics.fill(0);
      this.graphics.textAlign(CENTER, CENTER);
      this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);

      String scenario_text = "";
      //if (currentDataSource == dataID_climateEngineering) scenario_text += "Year: " + nf(nk + climateEngineeringStart - 1, 0);
      //if (currentDataSource == dataID_climateArchive) scenario_text += "Year: " + nf(nk + climateArchiveStart - 1, 0);
      //if (currentDataSource == dataID_ensembleForecast) scenario_text += "Member: " + nf(nk, 0);
      this.graphics.text(scenario_text, (j - ((0 - 12) / 24.0)) * sx_Plot, 0.95 * sx_Plot / this.horizontalUnitScale);
    }



    if (this.showImpactSummary) {

      int j = -1; // << to put the summary graph before the daily graphs

      for (int a = 0; a <= int (90 / Sky3D.inclinationStep); a++) {
        float Alpha = a * Sky3D.inclinationStep;
        for (int b = 0; b < int (360 / Sky3D.orientationStep); b++) {
          float Beta = b * Sky3D.orientationStep;

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
          if (this.impactTypeIndex == Impact_ACTIVE) valuesSUM = TOTALvaluesSUM_RAD[a][b];
          if (this.impactTypeIndex == Impact_PASSIVE) valuesSUM = COMPARISON;

          //if ((Alpha == 90.0) && (Beta == 0.0)) println("SPHERICAL >> (TOTAL) valuesSUM_RAD:", TOTALvaluesSUM_RAD[a][b], "COMPARISON:", COMPARISON);

          if (is_defined(valuesSUM)) {

            float _u = 0;

            if (this.impactTypeIndex == Impact_ACTIVE) _u = (0.1 * PAL_multiplier * valuesSUM);
            if (this.impactTypeIndex == Impact_PASSIVE) _u = 0.5 + 0.5 * (0.1 * PAL_multiplier * valuesSUM);

            _u = applyPalDirection(_u, PAL_direction);

            //float[] COL = PAINT.getColorStyle(PAL_type, _u);
            float[] COL = PAINT.getColorStyle(PAL_type, funcs.roundTo(_u, 0.1));
            this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
            this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

            this.graphics.strokeWeight(0);

            float x1 = (j + (this.centralGraphOffsetX + 0.5) + (90 - Alpha - 0.5 * Sky3D.inclinationStep) * (this.centralGraphScale / 200) * (funcs.cos_ang(Beta - 90 - 0.5 * Sky3D.orientationStep))) * sx_Plot;
            float y1 = (                         -(90 - Alpha - 0.5 * Sky3D.inclinationStep) * (this.centralGraphScale / 200) * (funcs.sin_ang(Beta - 90 - 0.5 * Sky3D.orientationStep))) * sx_Plot;
            float x2 = (j + (this.centralGraphOffsetX + 0.5) + (90 - Alpha + 0.5 * Sky3D.inclinationStep) * (this.centralGraphScale / 200) * (funcs.cos_ang(Beta - 90 - 0.5 * Sky3D.orientationStep))) * sx_Plot;
            float y2 = (                         -(90 - Alpha + 0.5 * Sky3D.inclinationStep) * (this.centralGraphScale / 200) * (funcs.sin_ang(Beta - 90 - 0.5 * Sky3D.orientationStep))) * sx_Plot;

            float x3 = (j + (this.centralGraphOffsetX + 0.5) + (90 - Alpha + 0.5 * Sky3D.inclinationStep) * (this.centralGraphScale / 200) * (funcs.cos_ang(Beta - 90 + 0.5 * Sky3D.orientationStep))) * sx_Plot;
            float y3 = (                         -(90 - Alpha + 0.5 * Sky3D.inclinationStep) * (this.centralGraphScale / 200) * (funcs.sin_ang(Beta - 90 + 0.5 * Sky3D.orientationStep))) * sx_Plot;
            float x4 = (j + (this.centralGraphOffsetX + 0.5) + (90 - Alpha - 0.5 * Sky3D.inclinationStep) * (this.centralGraphScale / 200) * (funcs.cos_ang(Beta - 90 + 0.5 * Sky3D.orientationStep))) * sx_Plot;
            float y4 = (                         -(90 - Alpha - 0.5 * Sky3D.inclinationStep) * (this.centralGraphScale / 200) * (funcs.sin_ang(Beta - 90 + 0.5 * Sky3D.orientationStep))) * sx_Plot;

            this.graphics.quad(x1, y1, x2, y2, x3, y3, x4, y4);
          }
        }
      }

      this.graphics.strokeWeight(this.strokeScale * 2);
      this.graphics.stroke(0);
      this.graphics.noFill();
      this.graphics.rect((j + (this.centralGraphOffsetX + 0.5) - 100 * (this.centralGraphScale / 200)) * sx_Plot, (-100 * (this.centralGraphScale / 200)) * sx_Plot, (200 * (this.centralGraphScale / 200)) * sx_Plot, (200 * (this.centralGraphScale / 200)) * sx_Plot);


      this.graphics.stroke(0);
      this.graphics.fill(0);
      this.graphics.textAlign(CENTER, CENTER);
      this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);

      String scenario_text = "";
      //if (currentDataSource == dataID_climateEngineering) scenario_text += "Year: " + nf(nk + climateEngineeringStart - 1, 0);
      //if (currentDataSource == dataID_climateArchive) scenario_text += "Year: " + nf(nk + climateArchiveStart - 1, 0);
      //if (currentDataSource == dataID_ensembleForecast) scenario_text += "Member: " + nf(nk, 0);
      this.graphics.text(scenario_text, (j - ((0 - 12) / 24.0)) * sx_Plot, 0.95 * sx_Plot / this.horizontalUnitScale);

      int keep_STUDY_startDay = this.startDay;
      int keep_STUDY_endDay = this.endDay;
      this.startDay = j;
      this.endDay = j + 1;
      this.drawPositionGrid(x_Plot, y_Plot, sx_Plot, sy_Plot, 0);
      this.startDay = keep_STUDY_startDay;
      this.endDay = keep_STUDY_endDay;
    }


    String scenario_text = "";
    //if (currentDataSource == dataID_climateEngineering) scenario_text += "Year: " + nf(nk + climateEngineeringStart - 1, 0);
    //if (currentDataSource == dataID_climateArchive) scenario_text += "Year: " + nf(nk + climateArchiveStart - 1, 0);
    //if (currentDataSource == dataID_ensembleForecast) scenario_text += "Member: " + nf(nk, 0);
    this.graphics.text(scenario_text, ((this.startDay - 1) - ((0 - 12) / 24.0)) * sx_Plot, 0.9 * sx_Plot / this.horizontalUnitScale);

    this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
    this.graphics.textAlign(RIGHT, CENTER);
    this.graphics.stroke(0);
    this.graphics.fill(0);
    this.graphics.strokeWeight(0);
    this.graphics.text(STAT_N_Title[l], -0.3 * sx_Plot / this.horizontalUnitScale, 1.2 * sx_Plot / this.horizontalUnitScale);
    //?? French

    float pal_length = 400;
    float pal_ox = 700;
    float pal_oy = 110;
    for (int q = 0; q < 11; q++) {
      float _u = 0;

      if (this.impactTypeIndex == Impact_ACTIVE) _u = 0.1 * q;
      if (this.impactTypeIndex == Impact_PASSIVE) _u = 0.2 * q - 0.5;

      _u = applyPalDirection(_u, PAL_direction);

      float[] COL = PAINT.getColorStyle(PAL_type, _u);
      this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
      this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

      this.graphics.strokeWeight(0);
      this.graphics.rect((pal_ox + q * (pal_length / 11.0)) * this.view_S, pal_oy * this.view_S, (pal_length / 11.0) * this.view_S, 20 * this.view_S);

      applyLegendTextStyle(COL);

      this.graphics.textSize(15.0 * this.view_S);
      this.graphics.textAlign(CENTER, CENTER);
      if (this.impactTypeIndex == Impact_ACTIVE) this.graphics.text(nf((funcs.roundTo(0.1 * q / PAL_multiplier, 0.1)), 1, 1), (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S, (10 + pal_oy - 0.05 * 20) * this.view_S);
      if (this.impactTypeIndex == Impact_PASSIVE) this.graphics.text(nf(funcs.roundTo(0.4 * (q - 5) / PAL_multiplier, 0.1), 1, 1), (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S, (10 + pal_oy - 0.05 * 20) * this.view_S);
    }


    if (this.PrintTtitle) {

      this.graphics.stroke(0);
      this.graphics.fill(0);
      this.graphics.strokeWeight(this.strokeScale * 0);

      this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
      this.graphics.textAlign(RIGHT, TOP);

      if (currentDataSource == dataID_climateEngineering) this.graphics.text(("[" + String.valueOf(start_k + climateEngineeringStart) + "-" + String.valueOf(end_k + climateEngineeringStart) + "] "), 0, -1.2 * sx_Plot / this.horizontalUnitScale);
      if (currentDataSource == dataID_climateArchive) this.graphics.text(("[" + String.valueOf(start_k + climateArchiveStart) + "-" + String.valueOf(end_k + climateArchiveStart) + "] "), 0, -1.2 * sx_Plot / this.horizontalUnitScale);
      if (currentDataSource == dataID_ensembleForecast) this.graphics.text(("[" + String.valueOf(start_k + ensembleForecastStart) + "-" + String.valueOf(end_k + ensembleForecastStart) + "] "), 0, -1.2 * sx_Plot / this.horizontalUnitScale);


      this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
      this.graphics.textAlign(LEFT, TOP);
      if (this.impactTypeIndex == Impact_ACTIVE) {
        this.graphics.text(("Solar radiation on hemisphere (kW/m²)"), 0, 1.1 * sx_Plot / this.horizontalUnitScale);
        //?? French
      }
      if (this.impactTypeIndex == Impact_PASSIVE) {
        this.graphics.text(("Solar effects on hemisphere (%kW°C/m²)"), 0, 1.1 * sx_Plot / this.horizontalUnitScale);
        //?? French
      }
    }

    this.drawPositionGrid(x_Plot, y_Plot, sx_Plot, sy_Plot, 0);
  }


  void plotImpact_sunpath (int start_k, int end_k, float x_Plot, float y_Plot, float sx_Plot, float sy_Plot) {
    if (this.impactGraphIndex == impactGraphIndex_SUNPATH_ACTIVE) this.impactTypeIndex = Impact_ACTIVE;
    if (this.impactGraphIndex == impactGraphIndex_SUNPATH_PASSIVE) this.impactTypeIndex = Impact_PASSIVE;

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

    if (this.impactTypeIndex == Impact_ACTIVE) {
      PAL_type = this.activeColorscaleIndex;
      PAL_direction = this.activeColorscaleDirection;
    }
    if (this.impactTypeIndex == Impact_PASSIVE) {
      PAL_type = this.passiveColorscaleIndex;
      PAL_direction = this.passiveColorscaleDirection;
    }

    float PAL_multiplier = 1;
    if (this.impactTypeIndex == Impact_ACTIVE) PAL_multiplier = this.activeColorscaleFactor;
    if (this.impactTypeIndex == Impact_PASSIVE) PAL_multiplier = this.passiveColorscaleFactor;

    this.drawPositionGrid(x_Plot, y_Plot, sx_Plot, sy_Plot, 0);

    int l = this.impactLayerIndex;

    for (int j = this.startDay; j < this.endDay; j++) {

      now_j = (j * int(this.dayIncrement) + TIME.beginDay + 365) % 365;

      if (now_j >= 365) {
        now_j = now_j % 365;
      }
      if (now_j < 0) {
        now_j = (now_j + 365) % 365;
      }

      float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);

      int nk = FIND_SCENARIO_CLOSE_TO_DAILY_STAT(l, start_k, end_k, j, DATE_ANGLE, this.impactTypeIndex);
      if (nk == -1) continue;

      int k = int(nk / this.daysMergedCount);
      int j_ADD = nk % this.daysMergedCount;

      float valuesSUM_RAD = 0;
      float valuesSUM_EFF = 0;
      int valuesNUM = 0;

      for (int i = 0; i < 24; i++) {
        if (this.isInHourlyRange(i)) {
          float HOUR_ANGLE = i;
          float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);

          if (SunR[3] > 0) {
            float Alpha = 90 - funcs.acos_ang(SunR[3]);
            float Beta = 180 - funcs.atan2_ang(SunR[1], SunR[2]);

            now_k = k + start_k;
            now_i = i;
            now_j = computeWrappedDayIndex(j, j_ADD);

            Pa = getValue_currentDataSource(now_i, now_j, now_k, LAYER_dirnorrad.id);
            Pb = getValue_currentDataSource(now_i, now_j, now_k, LAYER_difhorrad.id);
            Pc = getValue_currentDataSource(now_i, now_j, now_k, LAYER_direffect.id);
            Pd = getValue_currentDataSource(now_i, now_j, now_k, LAYER_difeffect.id);

            if (is_undefined(Pa) || is_undefined(Pb) || is_undefined(Pc) || is_undefined(Pd)) {
              values_R_dir = FLOAT_undefined;
              values_R_dif = FLOAT_undefined;
              values_E_dir = FLOAT_undefined;
              values_E_dif = FLOAT_undefined;
            } else {

              boolean isMemberCounted = filter(currentDataSource, LAYER_cloudcover.id, this.temporalFilterSetting, this.skyScenarioSetting, now_i, now_j, now_k);

              if (isMemberCounted) {
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
            if (this.impactTypeIndex == Impact_ACTIVE) valuesSUM = valuesSUM_RAD;
            if (this.impactTypeIndex == Impact_PASSIVE) valuesSUM = valuesSUM_EFF;

            if (is_defined(valuesSUM)) {

              float _u = 0;

              if (this.impactTypeIndex == Impact_ACTIVE) _u = (PAL_multiplier * valuesSUM);
              if (this.impactTypeIndex == Impact_PASSIVE) _u = 0.5 + 0.5 * (PAL_multiplier * valuesSUM);

              _u = applyPalDirection(_u, PAL_direction);

              float[] COL = PAINT.getColorStyle(PAL_type, _u);
              this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
              this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

              this.graphics.strokeWeight(0);

              this.graphics.ellipse((j + (this.centralGraphOffsetX + 0.5) + (90 - Alpha) * (this.centralGraphScale / 200) * (funcs.cos_ang(Beta - 90))) * sx_Plot, -((90 - Alpha) * (this.centralGraphScale / 200) * (funcs.sin_ang(Beta - 90))) * sx_Plot, 0.075 * sx_Plot, 0.075 * sx_Plot);

              applyLegendTextStyle(COL);

              this.graphics.textSize(this.view_S * 4.0 * this.horizontalUnitScale);

              this.graphics.textAlign(CENTER, CENTER);
              if (this.impactTypeIndex == Impact_ACTIVE) this.graphics.text(nf(valuesSUM, 1, 1), (j + (this.centralGraphOffsetX + 0.5) + (90 - Alpha) * (this.centralGraphScale / 200) * (funcs.cos_ang(Beta - 90))) * sx_Plot, -((90 - Alpha) * (this.centralGraphScale / 200) * (funcs.sin_ang(Beta - 90))) * sx_Plot);
              if (this.impactTypeIndex == Impact_PASSIVE) this.graphics.text(nf(valuesSUM, 1, 1), (j + (this.centralGraphOffsetX + 0.5) + (90 - Alpha) * (this.centralGraphScale / 200) * (funcs.cos_ang(Beta - 90))) * sx_Plot, -((90 - Alpha) * (this.centralGraphScale / 200) * (funcs.sin_ang(Beta - 90))) * sx_Plot);
            }
          }
        }
      }

      this.graphics.stroke(0);
      this.graphics.fill(0);
      this.graphics.textAlign(CENTER, CENTER);
      this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);

      String scenario_text = "";
      //if (currentDataSource == dataID_climateEngineering) scenario_text += "Year: " + nf(nk + climateEngineeringStart - 1, 0);
      //if (currentDataSource == dataID_climateArchive) scenario_text += "Year: " + nf(nk + climateArchiveStart - 1, 0);
      //if (currentDataSource == dataID_ensembleForecast) scenario_text += "Member: " + nf(nk, 0);
      this.graphics.text(scenario_text, (j - ((0 - 12) / 24.0)) * sx_Plot, 0.95  * sx_Plot / this.horizontalUnitScale);
    }

    String scenario_text = "";
    //if (currentDataSource == dataID_climateEngineering) scenario_text += "Year: " + nf(nk + climateEngineeringStart - 1, 0);
    //if (currentDataSource == dataID_climateArchive) scenario_text += "Year: " + nf(nk + climateArchiveStart - 1, 0);
    //if (currentDataSource == dataID_ensembleForecast) scenario_text += "Member: " + nf(nk, 0);
    this.graphics.text(scenario_text, ((this.startDay - 1) - ((0 - 12) / 24.0)) * sx_Plot, 0.9 * sx_Plot / this.horizontalUnitScale);

    this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
    this.graphics.textAlign(RIGHT, CENTER);
    this.graphics.stroke(0);
    this.graphics.fill(0);
    this.graphics.strokeWeight(0);
    this.graphics.text(STAT_N_Title[l], -0.3 * sx_Plot / this.horizontalUnitScale, 1.2 * sx_Plot / this.horizontalUnitScale);
    //?? French


    float pal_length = 400;
    float pal_ox = 700;
    float pal_oy = 110;
    for (int q = 0; q < 11; q++) {
      float _u = 0;

      if (this.impactTypeIndex == Impact_ACTIVE) _u = 0.1 * q;
      if (this.impactTypeIndex == Impact_PASSIVE) _u = 0.2 * q - 0.5;

      _u = applyPalDirection(_u, PAL_direction);

      float[] COL = PAINT.getColorStyle(PAL_type, _u);
      this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
      this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

      this.graphics.strokeWeight(0);
      this.graphics.rect((pal_ox + q * (pal_length / 11.0)) * this.view_S, pal_oy * this.view_S, (pal_length / 11.0) * this.view_S, 20 * this.view_S);

      applyLegendTextStyle(COL);

      this.graphics.textSize(15.0 * this.view_S);
      this.graphics.textAlign(CENTER, CENTER);

      if (this.impactTypeIndex == Impact_ACTIVE) this.graphics.text(nf(0.1 * q / PAL_multiplier, 1, 1), (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S, (10 + pal_oy - 0.05 * 20) * this.view_S);
      if (this.impactTypeIndex == Impact_PASSIVE) this.graphics.text(nf(funcs.roundTo(0.4 * (q - 5) / PAL_multiplier, 0.1), 1, 1), (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S, (10 + pal_oy - 0.05 * 20) * this.view_S);
    }


    if (this.PrintTtitle) {

      this.graphics.stroke(0);
      this.graphics.fill(0);
      this.graphics.strokeWeight(this.strokeScale * 0);

      this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
      this.graphics.textAlign(RIGHT, TOP);

      if (currentDataSource == dataID_climateEngineering) this.graphics.text(("[" + String.valueOf(start_k + climateEngineeringStart) + "-" + String.valueOf(end_k + climateEngineeringStart) + "] "), 0, -1.2 * sx_Plot / this.horizontalUnitScale);
      if (currentDataSource == dataID_climateArchive) this.graphics.text(("[" + String.valueOf(start_k + climateArchiveStart) + "-" + String.valueOf(end_k + climateArchiveStart) + "] "), 0, -1.2 * sx_Plot / this.horizontalUnitScale);
      if (currentDataSource == dataID_ensembleForecast) this.graphics.text(("[" + String.valueOf(start_k + ensembleForecastStart) + "-" + String.valueOf(end_k + ensembleForecastStart) + "] "), 0, -1.2 * sx_Plot / this.horizontalUnitScale);


      this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
      this.graphics.textAlign(LEFT, TOP);
      if (this.impactTypeIndex == Impact_ACTIVE) {
        this.graphics.text(("Direct solar radiation (kWh/m²)"), 0, 1.1 * sx_Plot / this.horizontalUnitScale);
        //?? French
      }
      if (this.impactTypeIndex == Impact_PASSIVE) {
        this.graphics.text(("Direct solar effects (kWh°C/m²)"), 0, 1.1 * sx_Plot / this.horizontalUnitScale);
        //?? French
      }
    }

  }


  void plotImpact_cycles (int start_k, int end_k, float x_Plot, float y_Plot, float sx_Plot, float sy_Plot) {

    int l = this.impactLayerIndex;

    int target_window = TypeWindow.STUDY;

    Sun3D.drawPattern(TypeWindow.STUDY, x_Plot, y_Plot, 0, sx_Plot);

    if (this.endDay == 2) {
      for (int j = this.startDay; j < this.endDay; j++) {

        float ox = (j + (this.centralGraphOffsetX + 0.5)) * sx_Plot;

        Sun3D.drawGrid(TypeWindow.STUDY, ox + x_Plot, y_Plot, 0, sx_Plot, j * 180 - 90, j * 180 + 90);

      }
    }

    this.drawPositionGrid(x_Plot, y_Plot, sx_Plot, sy_Plot, 0);

    String scenario_text = "";
    //if (currentDataSource == dataID_climateEngineering) scenario_text += "Year: " + nf(nk + climateEngineeringStart - 1, 0);
    //if (currentDataSource == dataID_climateArchive) scenario_text += "Year: " + nf(nk + climateArchiveStart - 1, 0);
    //if (currentDataSource == dataID_ensembleForecast) scenario_text += "Member: " + nf(nk, 0);
    this.graphics.text(scenario_text, ((this.startDay - 1) - ((0 - 12) / 24.0)) * sx_Plot, 0.9 * sx_Plot / this.horizontalUnitScale);

    this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
    this.graphics.textAlign(RIGHT, CENTER);
    this.graphics.stroke(0);
    this.graphics.fill(0);
    this.graphics.strokeWeight(0);
    this.graphics.text(STAT_N_Title[l], -0.3 * sx_Plot / this.horizontalUnitScale, 1.2 * sx_Plot / this.horizontalUnitScale);
    //?? French

    int PAL_type = 0;
    int PAL_direction = 1;

    if (this.impactGraphIndex == impactGraphIndex_CYCLES_ACTIVE) {
      PAL_type = this.activeColorscaleIndex;
      PAL_direction = this.activeColorscaleDirection;
    }
    if (this.impactGraphIndex == impactGraphIndex_CYCLES_PASSIVE) {
      PAL_type = this.passiveColorscaleIndex;
      PAL_direction = this.passiveColorscaleDirection;
    }

    float PAL_multiplier = 1;
    if (this.impactGraphIndex == impactGraphIndex_CYCLES_ACTIVE) PAL_multiplier = this.activeColorscaleFactor;
    if (this.impactGraphIndex == impactGraphIndex_CYCLES_PASSIVE) PAL_multiplier = this.passiveColorscaleFactor;

    float pal_length = 400;
    float pal_ox = 700;
    float pal_oy = 110;

    if (this.endDay == 2) {
      pal_ox = (viewLayout == 2) ? 700 : 380;
      pal_oy = (viewLayout == 2) ? -375 : 275;
    }

    for (int q = 0; q < 11; q++) {
      float _u = 0;

      if (this.impactGraphIndex == impactGraphIndex_CYCLES_ACTIVE) _u = 0.1 * q;
      if (this.impactGraphIndex == impactGraphIndex_CYCLES_PASSIVE) _u = 0.2 * q - 0.5;

      _u = applyPalDirection(_u, PAL_direction);

      float[] COL = PAINT.getColorStyle(PAL_type, _u);
      this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
      this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

      this.graphics.strokeWeight(0);
      this.graphics.rect((pal_ox + q * (pal_length / 11.0)) * this.view_S, -pal_oy * this.view_S, (pal_length / 11.0) * this.view_S, 20 * this.view_S);

      applyLegendTextStyle(COL);

      this.graphics.textSize(15.0 * this.view_S);
      this.graphics.textAlign(CENTER, CENTER);
      if (this.impactGraphIndex == impactGraphIndex_CYCLES_ACTIVE) this.graphics.text(nf(0.1 * q / PAL_multiplier, 1, 1), (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S, (10 - pal_oy - 0.05 * 20) * this.view_S);
      if (this.impactGraphIndex == impactGraphIndex_CYCLES_PASSIVE) this.graphics.text(nf(funcs.roundTo(0.4 * (q - 5) / PAL_multiplier, 0.1), 1, 1), (20 + pal_ox + q * (pal_length / 11.0)) * this.view_S, (10 - pal_oy - 0.05 * 20) * this.view_S);
    }


    if (this.PrintTtitle) {

      this.graphics.stroke(0);
      this.graphics.fill(0);
      this.graphics.strokeWeight(this.strokeScale * 0);

      this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
      this.graphics.textAlign(RIGHT, TOP);

      if (currentDataSource == dataID_climateEngineering) this.graphics.text(("[" + String.valueOf(start_k + climateEngineeringStart) + "-" + String.valueOf(end_k + climateEngineeringStart) + "] "), 0, -1.2 * sx_Plot / this.horizontalUnitScale);
      if (currentDataSource == dataID_climateArchive) this.graphics.text(("[" + String.valueOf(start_k + climateArchiveStart) + "-" + String.valueOf(end_k + climateArchiveStart) + "] "), 0, -1.2 * sx_Plot / this.horizontalUnitScale);
      if (currentDataSource == dataID_ensembleForecast) this.graphics.text(("[" + String.valueOf(start_k + ensembleForecastStart) + "-" + String.valueOf(end_k + ensembleForecastStart) + "] "), 0, -1.2 * sx_Plot / this.horizontalUnitScale);

      this.graphics.textSize(sx_Plot * 0.250 / this.horizontalUnitScale);
      this.graphics.textAlign(CENTER, TOP);
      if (this.impactGraphIndex == impactGraphIndex_CYCLES_ACTIVE) {
        this.graphics.text(("Direct solar radiation (kWh/m²)"), (pal_ox + 5 * (pal_length / 11.0)) * this.view_S + (pal_length / 11.0) * this.view_S, -pal_oy * this.view_S + 25 * this.view_S);
        //?? French
      }
      if (this.impactGraphIndex == impactGraphIndex_CYCLES_PASSIVE) {
        this.graphics.text(("Direct solar effects (kWh°C/m²)"), (pal_ox + 5 * (pal_length / 11.0)) * this.view_S + (pal_length / 11.0) * this.view_S, -pal_oy * this.view_S + 25 * this.view_S);
        //?? French
      }
    }

  }


  void plotImpact (float x_Plot, float y_Plot, float sx_Plot, float sy_Plot) {

    this.graphics.pushMatrix();
    this.graphics.translate(x_Plot, y_Plot);

    float keep_STUDY_dayIncrement = this.dayIncrement;
    int keep_STUDY_daysMergedCount = this.daysMergedCount;

    if ((currentDataSource == dataID_ensembleForecast) ||
        (currentDataSource == dataID_ensembleObservation)) {

      this.dayIncrement = 1;
      this.daysMergedCount = 1;
    }

    int[] startK_endK = get_startK_endK();
    int start_k = startK_endK[0];
    int end_k = startK_endK[1];
    int count_k = 1 + end_k - start_k;
    if (count_k < 0) count_k = 0;


    if ((this.impactGraphIndex == impactGraphIndex_WIND_ACTIVE) || (this.impactGraphIndex == impactGraphIndex_WIND_PASSIVE)) {
      this.plotImpact_wind(start_k, end_k, count_k, x_Plot, y_Plot, sx_Plot, sy_Plot);
    }




    if ((this.impactGraphIndex == impactGraphIndex_URBAN_ACTIVE) || (this.impactGraphIndex == impactGraphIndex_URBAN_PASSIVE)) {
      this.plotImpact_urban(start_k, end_k, sx_Plot);
    }



    if ((this.impactGraphIndex == impactGraphIndex_GLOBAL_ACTIVE) || (this.impactGraphIndex == impactGraphIndex_GLOBAL_PASSIVE)) {
      this.plotImpact_global(start_k, end_k, x_Plot, y_Plot, sx_Plot, sy_Plot);
    }


    if ((this.impactGraphIndex == impactGraphIndex_SUNPATH_ACTIVE) || (this.impactGraphIndex == impactGraphIndex_SUNPATH_PASSIVE)) {
      this.plotImpact_sunpath(start_k, end_k, x_Plot, y_Plot, sx_Plot, sy_Plot);
    }


    if ((this.impactGraphIndex == impactGraphIndex_CYCLES_ACTIVE) || (this.impactGraphIndex == impactGraphIndex_CYCLES_PASSIVE)) {
      this.plotImpact_cycles(start_k, end_k, x_Plot, y_Plot, sx_Plot, sy_Plot);
    }





    if ((this.impactGraphIndex == impactGraphIndex_CYCLES_ACTIVE) || (this.impactGraphIndex == impactGraphIndex_CYCLES_PASSIVE)) {
    } else {
      this.drawDailyGrid(x_Plot, y_Plot, sx_Plot, sy_Plot);
    }

    if ((currentDataSource == dataID_ensembleForecast) ||
        (currentDataSource == dataID_ensembleObservation)) {
    } else {
      this.dayIncrement = keep_STUDY_dayIncrement;
      this.daysMergedCount = keep_STUDY_daysMergedCount;
    }


    this.graphics.popMatrix();
  }




  public void to_XML (XML xml) {

    //printlnSaving(this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setInt(parent, "startHour", this.startHour);
    XML_setInt(parent, "endHour", this.endHour);
    XML_setInt(parent, "startDay", this.startDay);
    XML_setInt(parent, "endDay", this.endDay);
    XML_setFloat(parent, "dayIncrement", this.dayIncrement);
    XML_setInt(parent, "daysMergedCount", this.daysMergedCount);

    XML_setFloat(parent, "strokeScale", this.strokeScale);
    XML_setFloat(parent, "horizontalUnitScale", this.horizontalUnitScale);

    XML_setInt(parent, "skyScenarioSetting", this.skyScenarioSetting);
    XML_setInt(parent, "temporalFilterSetting", this.temporalFilterSetting);

    XML_setBoolean(parent, "rawLinesExporter", this.rawLinesExporter);
    XML_setBoolean(parent, "normalLinesExporter", this.normalLinesExporter);
    XML_setBoolean(parent, "probabilitiesExporter", this.probabilitiesExporter);

    XML_setInt(parent, "statisticalRangesColorscaleIndex", this.statisticalRangesColorscaleIndex);
    XML_setInt(parent, "statisticalRangesColorscaleDirection", this.statisticalRangesColorscaleDirection);
    XML_setFloat(parent, "statisticalRangesColorscaleFactor", this.statisticalRangesColorscaleFactor);

    XML_setInt(parent, "probabilitiesColorscaleIndex", this.probabilitiesColorscaleIndex);
    XML_setInt(parent, "probabilitiesColorscaleDirection", this.probabilitiesColorscaleDirection);
    XML_setFloat(parent, "probabilitiesColorscaleFactor", this.probabilitiesColorscaleFactor);

    XML_setInt(parent, "activeColorscaleIndex", this.activeColorscaleIndex);
    XML_setInt(parent, "activeColorscaleDirection", this.activeColorscaleDirection);
    XML_setFloat(parent, "activeColorscaleFactor", this.activeColorscaleFactor);

    XML_setInt(parent, "passiveColorscaleIndex", this.passiveColorscaleIndex);
    XML_setInt(parent, "passiveColorscaleDirection", this.passiveColorscaleDirection);
    XML_setFloat(parent, "passiveColorscaleFactor", this.passiveColorscaleFactor);

    XML_setFloat(parent, "opacityPercentage", this.opacityPercentage);
    XML_setFloat(parent, "centralGraphScale", centralGraphScale);
    XML_setFloat(parent, "centralGraphOffsetX", this.centralGraphOffsetX);

    XML_setInt(parent, "plotLayoutIndex", this.plotLayoutIndex);
    XML_setInt(parent, "impactTypeIndex", this.impactTypeIndex);
    XML_setInt(parent, "impactLayerIndex", this.impactLayerIndex);
    XML_setInt(parent, "impactGraphIndex", this.impactGraphIndex);
    XML_setBoolean(parent, "updateImpactGraph", this.updateImpactGraph);
    XML_setBoolean(parent, "showImpactSummary", this.showImpactSummary);

    XML_setBoolean(parent, "showRawLines", this.showRawLines);
    XML_setBoolean(parent, "showStatisticalRanges", this.showStatisticalRanges);
    XML_setBoolean(parent, "showNormalLines", this.showNormalLines);
    XML_setBoolean(parent, "showProbabilities", this.showProbabilities);
    XML_setInt(parent, "probabilityWidthInterval", this.probabilityWidthInterval);
    XML_setFloat(parent, "probabilityHeightInterval", this.probabilityHeightInterval);
  }


  public void from_XML (XML xml) {

    //println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);

    this.startHour = XML_getInt(parent, "startHour");
    this.endHour = XML_getInt(parent, "endHour");
    this.startDay = XML_getInt(parent, "startDay");
    this.endDay = XML_getInt(parent, "endDay");
    this.dayIncrement = XML_getFloat(parent, "dayIncrement");
    this.daysMergedCount = XML_getInt(parent, "daysMergedCount");

    this.strokeScale = XML_getFloat(parent, "strokeScale");
    this.horizontalUnitScale = XML_getFloat(parent, "horizontalUnitScale");

    this.skyScenarioSetting = XML_getInt(parent, "skyScenarioSetting");
    this.temporalFilterSetting = XML_getInt(parent, "temporalFilterSetting");

    this.rawLinesExporter = XML_getBoolean(parent, "rawLinesExporter");
    this.normalLinesExporter = XML_getBoolean(parent, "normalLinesExporter");
    this.probabilitiesExporter = XML_getBoolean(parent, "probabilitiesExporter");

    this.statisticalRangesColorscaleIndex = XML_getInt(parent, "statisticalRangesColorscaleIndex");
    this.statisticalRangesColorscaleDirection = XML_getInt(parent, "statisticalRangesColorscaleDirection");
    this.statisticalRangesColorscaleFactor = XML_getFloat(parent, "statisticalRangesColorscaleFactor");

    this.probabilitiesColorscaleIndex = XML_getInt(parent, "probabilitiesColorscaleIndex");
    this.probabilitiesColorscaleDirection = XML_getInt(parent, "probabilitiesColorscaleDirection");
    this.probabilitiesColorscaleFactor = XML_getFloat(parent, "probabilitiesColorscaleFactor");

    this.activeColorscaleIndex = XML_getInt(parent, "activeColorscaleIndex");
    this.activeColorscaleDirection = XML_getInt(parent, "activeColorscaleDirection");
    this.activeColorscaleFactor = XML_getFloat(parent, "activeColorscaleFactor");

    this.passiveColorscaleIndex = XML_getInt(parent, "passiveColorscaleIndex");
    this.passiveColorscaleDirection = XML_getInt(parent, "passiveColorscaleDirection");
    this.passiveColorscaleFactor = XML_getFloat(parent, "passiveColorscaleFactor");


    this.opacityPercentage = XML_getFloat(parent, "opacityPercentage");
    this.centralGraphScale = XML_getFloat(parent, "centralGraphScale");
    this.centralGraphOffsetX = XML_getFloat(parent, "centralGraphOffsetX");

    this.plotLayoutIndex = XML_getInt(parent, "plotLayoutIndex");
    this.impactTypeIndex = XML_getInt(parent, "impactTypeIndex");
    this.impactLayerIndex = XML_getInt(parent, "impactLayerIndex");
    this.impactGraphIndex = XML_getInt(parent, "impactGraphIndex");
    this.updateImpactGraph = XML_getBoolean(parent, "updateImpactGraph");
    this.showImpactSummary = XML_getBoolean(parent, "showImpactSummary");

    this.showRawLines = XML_getBoolean(parent, "showRawLines");
    this.showStatisticalRanges = XML_getBoolean(parent, "showStatisticalRanges");
    this.showNormalLines = XML_getBoolean(parent, "showNormalLines");
    this.showProbabilities = XML_getBoolean(parent, "showProbabilities");
    this.probabilityWidthInterval = XML_getInt(parent, "probabilityWidthInterval");
    this.probabilityHeightInterval = XML_getFloat(parent, "probabilityHeightInterval");
  }


  void revise () {
    this.update = true;
  }
  void updated () {
    this.update = false;
  }
}
