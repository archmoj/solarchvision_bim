class solarchvision_UI_caseBar {

  private final static String CLASS_STAMP = "UI_caseBar";

  boolean update = true;
  float tab;

  String[][] Items = {
    {"Hours"},
    {"Days"},
    {"Scenario"}
  };

  // ---------------------------------------------------------------------
  // Entry point
  // ---------------------------------------------------------------------

  void draw () {
    if (!this.update) return;

    this.updated();
    this.tab = SOLARCHVISION_pixel_C / float(this.Items.length);

    drawTrackBackground();
    drawTabs();
    drawImpactLayerSelector();

    SOLARCHVISION_X_clicked = -1;
    SOLARCHVISION_Y_clicked = -1;
  }

  void revise () {
    this.update = true;
  }

  void updated () {
    this.update = false;
  }

  // ---------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------

  // Maps a click's x-position within [x1, x2] onto an integer "index" scaled
  // to `count` buckets, with an optional offset applied before rounding.
  // (Hours/Scenario pass offset -0.5 so the click lands mid-bucket; Days
  // passes 0, matching the original per-tab formulas.)
  int scaledIndexFromClick (float clickX, float x1, float x2, float count, float offset) {
    return int(funcs.roundTo(count * (clickX - x1) / (x2 - x1) + offset, 1));
  }

  // Returns {min, max} of a and b.
  int[] orderPair (int a, int b) {
    if (a > b) return new int[]{b, a};
    return new int[]{a, b};
  }

  // Draws a rect from x_start to x_end that may wrap around the [x1, x2]
  // track. `notWrapped` is passed in explicitly rather than inferred from
  // x_start/x_end because the original code sometimes tests the underlying
  // integer indices instead of the pixel positions (Hours tab) and sometimes
  // tests the pixel positions themselves (Days tab) - those aren't always
  // equivalent at the boundary, so each caller supplies the right test.
  void drawWrappedRect (boolean notWrapped, float x_start, float x_end, float x1, float x2, float y1, float y2) {
    if (notWrapped) {
      rect(x_start, y1, x_end - x_start, y2 - y1);
    } else {
      rect(x1, y1, x_end - x1, y2 - y1);
      rect(x_start, y1, x2 - x_start, y2 - y1);
    }
  }

  // Inserts a single space between every character of a string
  // (used to letter-space the month labels on the Days tab).
  String letterSpaced (String txt) {
    String out = "";
    int len = txt.length();
    for (int k = 0; k < len; k++) {
      out += txt.charAt(k);
      if (k < len - 1) out += " ";
    }
    return out;
  }

  void notifyChanged () {
    ROLLOUT.revise();
    STUDY.revise();
    SOLARCHVISION_view_changed();
    SOLARCHVISION_find_which_bakings_to_regenerate();
  }

  // ---------------------------------------------------------------------
  // Tab track (background + per-item dispatch)
  // ---------------------------------------------------------------------

  void drawTrackBackground () {
    fill(191);
    noStroke();
    rect(0, SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 2 * SOLARCHVISION_pixel_H, width, SOLARCHVISION_pixel_C);
  }

  void drawTabs () {
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

      String item = this.Items[i][0];
      if (item.equals("Hours")) {
        drawHoursTab(x1, y1, x2, y2);
      } else if (item.equals("Days")) {
        drawDaysTab(x1, y1, x2, y2);
      } else if (item.equals("Scenario")) {
        drawScenarioTab(x1, y1, x2, y2);
      }

      Y_control += this.tab;
    }
  }

  // ---------------------------------------------------------------------
  // "Hours" tab
  // ---------------------------------------------------------------------

  void drawHoursTab (float x1, float y1, float x2, float y2) {
    if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, x1, y1, x2, y2)) {
      if (mouseButton == LEFT) {
        STUDY.i_Start = scaledIndexFromClick(SOLARCHVISION_X_clicked, x1, x2, 24.0, -0.5);
        notifyChanged();
      }
      if (mouseButton == RIGHT) {
        STUDY.i_End = scaledIndexFromClick(SOLARCHVISION_X_clicked, x1, x2, 24.0, -0.5);
        notifyChanged();
      }
    }

    float x_start = x1 + (x2 - x1) * (STUDY.i_Start) / 24.0;
    float x_end = x1 + (x2 - x1) * (STUDY.i_End + 1) / 24.0;

    fill(0, 191, 0, 191);
    noStroke();
    drawWrappedRect(STUDY.i_Start <= STUDY.i_End, x_start, x_end, x1, x2, y1, y2);

    textAlign(CENTER, CENTER);
    stroke(0);
    fill(0);
    textSize(MessageSize);
    for (int j = 0; j < 24; j++) {
      text(nf(j, 0), x1 + (x2 - x1) * (j + 0.5) / 24.0, Y_control);
    }
  }

  // ---------------------------------------------------------------------
  // "Days" tab
  // ---------------------------------------------------------------------

  void drawDaysTab (float x1, float y1, float x2, float y2) {
    handleDaysClick(x1, y1, x2, y2);

    float keep_STUDY_perDays = STUDY.perDays;
    int keep_STUDY_joinDays = STUDY.joinDays;
    if ((CurrentDataSource == dataID_ENSEMBLE_FORECAST) ||
        (CurrentDataSource == dataID_ENSEMBLE_OBSERVED)) {
      STUDY.perDays = 1;
      STUDY.joinDays = 1;
    }

    drawDaysBands(x1, x2, y1, y2);
    drawDaysMonthLabels(x1, x2);

    STUDY.perDays = keep_STUDY_perDays;
    STUDY.joinDays = keep_STUDY_joinDays;
  }

  // Shared by both mouse buttons: maps the click x-position to a day-of-year.
  int dayOfYearFromClick (float clickX, float x1, float x2) {
    return (scaledIndexFromClick(clickX, x1, x2, 365.0, 0) + 286) % 365;
  }

  void handleDaysClick (float x1, float y1, float x2, float y2) {
    if (!isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, x1, y1, x2, y2)) return;

    if (mouseButton == LEFT) {
      float keep_TIME_Date = TIME.date;
      TIME.date = dayOfYearFromClick(SOLARCHVISION_X_clicked, x1, x2);
      TIME.updateDate();
      TIME.beginDay = int(TIME.beginDay + (TIME.date - keep_TIME_Date) + 365) % 365;
      update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);
      notifyChanged();
    }

    if (mouseButton == RIGHT) {
      float _DATE2 = dayOfYearFromClick(SOLARCHVISION_X_clicked, x1, x2);
      if (TIME.date > _DATE2) _DATE2 += 365;
      STUDY.perDays = funcs.roundTo((_DATE2 - TIME.date) / float(STUDY.j_End - STUDY.j_Start), 0.5);
      if (STUDY.perDays < 1) STUDY.perDays = 1;
      notifyChanged();
    }
  }

  void drawDaysBands (float x1, float x2, float y1, float y2) {
    for (int j = STUDY.j_Start; j < STUDY.j_End; j++) {
      float first_x_start = -1;
      float last_x_end = -1;

      for (int j_ADD = 0; j_ADD < STUDY.joinDays; j_ADD++) {
        int now_j = int(j * STUDY.perDays + (j_ADD - int(funcs.roundTo(0.5 * STUDY.joinDays, 1))) + TIME.beginDay + 365) % 365;
        if (now_j >= 365) now_j = now_j % 365;
        if (now_j < 0) now_j = (now_j + 365) % 365;

        float x_start = x1 + (x2 - x1) * ((now_j) % 365) / 365.0;
        float x_end = x1 + (x2 - x1) * ((now_j + 1) % 365) / 365.0;

        if (j_ADD == 0) first_x_start = x_start;
        if (j_ADD == STUDY.joinDays - 1) last_x_end = x_end;

        float q = 1.0 * (j - STUDY.j_Start) / (STUDY.j_End - STUDY.j_Start);
        fill(255 * (1 - q), 63, 255 * q, 127);
        noStroke();
        drawWrappedRect(x_start <= x_end, x_start, x_end, x1, x2, y1, y2);
      }

      strokeWeight(2);
      stroke(255);
      noFill();
      drawWrappedRect(first_x_start <= last_x_end, first_x_start, last_x_end, x1, x2, y1, y2);
      strokeWeight(0);
    }
  }

  void drawDaysMonthLabels (float x1, float x2) {
    textAlign(CENTER, CENTER);
    strokeWeight(1);
    stroke(0);
    fill(0);
    textSize(0.95 * MessageSize);
    for (int j = 0; j < 12; j++) {
      String txt = TIME.namesOfMonths[j][Language_Active];
      text(letterSpaced(txt), x1 + (x2 - x1) * (j + 0.5) / 12.0, Y_control);
    }
    strokeWeight(0);
  }

  // ---------------------------------------------------------------------
  // "Scenario" tab
  // ---------------------------------------------------------------------

  void drawScenarioTab (float x1, float y1, float x2, float y2) {
    int[] range = scenarioRange(CurrentDataSource);
    int n1 = range[0];
    int n2 = range[1];

    if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, x1, y1, x2, y2)) {
      int V_selection = n1 + scaledIndexFromClick(SOLARCHVISION_X_clicked, x1, x2, n2 - n1 + 1, -0.5);
      if (mouseButton == LEFT) {
        setScenarioStart(CurrentDataSource, V_selection);
        notifyChanged();
      }
      if (mouseButton == RIGHT) {
        setScenarioEnd(CurrentDataSource, V_selection);
        notifyChanged();
      }
    }

    int[] current = scenarioCurrentValues(CurrentDataSource);
    float V_start = current[0];
    float V_end = current[1];

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
      String txt = scenarioTickLabel(CurrentDataSource, j, n1);
      text(txt, x1 + (x2 - x1) * (j + 0.5) / float(n2 - n1 + 1), Y_control - 0.1 * MessageSize);
    }
  }

  int[] scenarioRange (int dataSource) {
    if (dataSource == dataID_CLIMATE_CWEEDS ||
        dataSource == dataID_CLIMATE_CLMREC ||
        dataSource == dataID_CLIMATE_TMYEPW) {
      return new int[]{1950, 2050};
    }
    if (dataSource == dataID_ENSEMBLE_FORECAST) {
      return new int[]{ENSEMBLE_FORECAST_start, ENSEMBLE_FORECAST_end};
    }
    if (dataSource == dataID_ENSEMBLE_OBSERVED) {
      return new int[]{ENSEMBLE_OBSERVED_start, ENSEMBLE_OBSERVED_end};
    }
    return new int[]{0, 1};
  }

  int[] scenarioCurrentValues (int dataSource) {
    if (dataSource == dataID_CLIMATE_CWEEDS || dataSource == dataID_CLIMATE_CLMREC) {
      return new int[]{SampleYear_Start, SampleYear_End};
    }
    if (dataSource == dataID_ENSEMBLE_FORECAST) {
      return new int[]{SampleMember_Start, SampleMember_End};
    }
    if (dataSource == dataID_ENSEMBLE_OBSERVED) {
      return new int[]{SampleStation_Start, SampleStation_End};
    }
    return new int[]{0, 0};
  }

  void setScenarioStart (int dataSource, int value) {
    if (dataSource == dataID_CLIMATE_CWEEDS || dataSource == dataID_CLIMATE_CLMREC) {
      SampleYear_Start = value;
      int[] ord = orderPair(SampleYear_Start, SampleYear_End);
      SampleYear_Start = ord[0];
      SampleYear_End = ord[1];
    } else if (dataSource == dataID_ENSEMBLE_FORECAST) {
      SampleMember_Start = value;
      int[] ord = orderPair(SampleMember_Start, SampleMember_End);
      SampleMember_Start = ord[0];
      SampleMember_End = ord[1];
    } else if (dataSource == dataID_ENSEMBLE_OBSERVED) {
      SampleStation_Start = value;
      int[] ord = orderPair(SampleStation_Start, SampleStation_End);
      SampleStation_Start = ord[0];
      SampleStation_End = ord[1];
    }
  }

  void setScenarioEnd (int dataSource, int value) {
    if (dataSource == dataID_CLIMATE_CWEEDS || dataSource == dataID_CLIMATE_CLMREC) {
      SampleYear_End = value;
      int[] ord = orderPair(SampleYear_Start, SampleYear_End);
      SampleYear_Start = ord[0];
      SampleYear_End = ord[1];
    } else if (dataSource == dataID_ENSEMBLE_FORECAST) {
      SampleMember_End = value;
      int[] ord = orderPair(SampleMember_Start, SampleMember_End);
      SampleMember_Start = ord[0];
      SampleMember_End = ord[1];
    } else if (dataSource == dataID_ENSEMBLE_OBSERVED) {
      SampleStation_End = value;
      int[] ord = orderPair(SampleStation_Start, SampleStation_End);
      SampleStation_Start = ord[0];
      SampleStation_End = ord[1];
    }
  }

  String scenarioTickLabel (int dataSource, int j, int n1) {
    String txt = (j % 5 == 0) ? "|" : ".";
    if ((dataSource == dataID_CLIMATE_CWEEDS || dataSource == dataID_CLIMATE_CLMREC) && (j % 10 == 5)) {
      txt = nf(j - 5 + n1, 0) + "s";
    } else if (dataSource == dataID_ENSEMBLE_FORECAST) {
      txt = nf(j + n1, 0);
    } else if (dataSource == dataID_ENSEMBLE_OBSERVED) {
      txt = SWOB_Coordinates[nearest_Station_ENSEMBLE_OBSERVED_id[j]].getCode();
    }
    return txt;
  }

  // ---------------------------------------------------------------------
  // Impact layer selector (3x3 grid)
  // ---------------------------------------------------------------------

  void drawImpactLayerSelector () {
    float displayBarWidth = ROLLOUT.dX;
    float displayBarHeight = 4.5 * MessageSize;
    float offsetX = ROLLOUT.cX + 0.5 * displayBarWidth;
    float offsetY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 2 * SOLARCHVISION_pixel_H + 0.5 * displayBarHeight;

    handleImpactLayerClicks(offsetX, offsetY, displayBarWidth, displayBarHeight);
    renderImpactLayerGrid(offsetX, offsetY, displayBarWidth, displayBarHeight);
  }

  // Bounds of grid cell n (0..8) as {x1, x2, y1, y2}.
  float[] impactCellBounds (int n, float offsetX, float offsetY, float w, float h) {
    int i = 2 - n / 3;
    int j = 2 - n % 3;
    float rx = (i + 0.5) / 3.0 - 0.5;
    float ry = (j + 0.5) / 3.0 - 0.5;
    float x1 = offsetX + (rx - 0.16) * w;
    float x2 = offsetX + (rx + 0.16) * w;
    float y1 = offsetY + (ry - 0.15) * h;
    float y2 = offsetY + (ry + 0.15) * h;
    return new float[]{x1, x2, y1, y2};
  }

  void handleImpactLayerClicks (float offsetX, float offsetY, float w, float h) {
    for (int n = 0; n < 9; n++) {
      float[] b = impactCellBounds(n, offsetX, offsetY, w, h);
      if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, b[0], b[2], b[1], b[3])) {
        STUDY.ImpactLayer = n;
        notifyChanged();
      }
    }
  }

  void renderImpactLayerGrid (float offsetX, float offsetY, float w, float h) {
    for (int n = 0; n < 9; n++) {
      float[] b = impactCellBounds(n, offsetX, offsetY, w, h);
      float x1 = b[0], x2 = b[1], y1 = b[2], y2 = b[3];

      if (n == STUDY.ImpactLayer) {
        fill(255, 127, 0);
      } else if (n / 3 == STUDY.ImpactLayer / 3) {
        fill(127, 63, 0);
      } else {
        fill(127);
      }
      noStroke();
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
  }
}
