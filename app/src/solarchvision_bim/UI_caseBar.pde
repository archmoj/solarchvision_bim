class UI_caseBar {

  final static String CLASS_STAMP = "UI_caseBar";

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
    this.tab = pixel_C / float(this.Items.length);

    drawTrackBackground();
    drawTabs();
    drawimpactLayerIndexSelector();

    X_clicked = -1;
    Y_clicked = -1;
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

  // ---------------------------------------------------------------------
  // Tab track (background + per-item dispatch)
  // ---------------------------------------------------------------------

  void drawTrackBackground () {
    fill(191);
    noStroke();
    rect(0, pixel_A + pixel_B + 2 * pixel_H, width, pixel_C);
  }

  void drawTabs () {
    float displayBarHeight = MessageSize;
    float displayBarWidth = 2 * pixel_W;

    X_control = 0.5 * displayBarWidth;
    Y_control = pixel_A + pixel_B + 2 * pixel_H + 0.5 * this.tab;

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
      textSize(1.15 * MessageSize);
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
    if (isInside(X_clicked, Y_clicked, x1, y1, x2, y2)) {
      int selectedValue = scaledIndexFromClick(X_clicked, x1, x2, 24.0, -0.5);
      if (mouseButton == LEFT) runScriptLine("Start Hour " + selectedValue);
      if (mouseButton == RIGHT) runScriptLine("End Hour " + selectedValue);
    }

    float x_start = x1 + (x2 - x1) * (STUDY.startHour) / 24.0;
    float x_end = x1 + (x2 - x1) * (STUDY.endHour + 1) / 24.0;

    fill(0, 191, 0, 191);
    noStroke();
    drawWrappedRect(STUDY.startHour <= STUDY.endHour, x_start, x_end, x1, x2, y1, y2);

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

    float keep_STUDY_dailyStep = STUDY.dailyStep;
    int keep_STUDY_daysMergedCount = STUDY.daysMergedCount;
    if ((currentDataSource == dataID_ensembleForecast) ||
        (currentDataSource == dataID_ensembleObservation)) {
      STUDY.dailyStep = 1;
      STUDY.daysMergedCount = 1;
    }

    drawDaysBands(x1, x2, y1, y2);
    drawDaysMonthLabels(x1, x2);

    STUDY.dailyStep = keep_STUDY_dailyStep;
    STUDY.daysMergedCount = keep_STUDY_daysMergedCount;
  }

  // Shared by both mouse buttons: maps the click x-position to a day-of-year.
  int dayOfYearFromClick (float clickX, float x1, float x2) {
    return (scaledIndexFromClick(clickX, x1, x2, 365.0, 0) + 286) % 365;
  }

  void handleDaysClick (float x1, float y1, float x2, float y2) {
    if (!isInside(X_clicked, Y_clicked, x1, y1, x2, y2)) return;

    if (mouseButton == LEFT) {
      float keep_TIME_Date = TIME.date;
      runScriptLine("date " + dayOfYearFromClick(X_clicked, x1, x2));
      TIME.beginDay = int(TIME.beginDay + (TIME.date - keep_TIME_Date) + 365) % 365;
      update_ensembleForecast(TIME.year, TIME.month, TIME.day, TIME.hour);
      UI_rollout.revise();
      STUDY.revise();
      view_changed();
      find_which_bakings_to_regenerate();
    }

    if (mouseButton == RIGHT) {
      float _DATE2 = dayOfYearFromClick(X_clicked, x1, x2);
      if (TIME.date > _DATE2) _DATE2 += 365;
      float selectedValue = funcs.roundTo((_DATE2 - TIME.date) / float(STUDY.endDay - STUDY.startDay), 0.5);
      if (selectedValue < 1) selectedValue = 1;
      runScriptLine("Daily Step " + selectedValue);
    }
  }

  void drawDaysBands (float x1, float x2, float y1, float y2) {
    for (int j = STUDY.startDay; j < STUDY.endDay; j++) {
      float first_x_start = -1;
      float last_x_end = -1;

      for (int j_ADD = 0; j_ADD < STUDY.daysMergedCount; j_ADD++) {
        int now_j = int(j * STUDY.dailyStep + (j_ADD - int(funcs.roundTo(0.5 * STUDY.daysMergedCount, 1))) + TIME.beginDay + 365) % 365;
        if (now_j >= 365) now_j = now_j % 365;
        if (now_j < 0) now_j = (now_j + 365) % 365;

        float x_start = x1 + (x2 - x1) * ((now_j) % 365) / 365.0;
        float x_end = x1 + (x2 - x1) * ((now_j + 1) % 365) / 365.0;

        if (j_ADD == 0) first_x_start = x_start;
        if (j_ADD == STUDY.daysMergedCount - 1) last_x_end = x_end;

        float q = 1.0 * (j - STUDY.startDay) / (STUDY.endDay - STUDY.startDay);
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
    noStroke();
    fill(0);
    textSize(1.0 * MessageSize);
    for (int j = 0; j < 12; j++) {
      String txt = TIME.namesOfMonths[j][activeLanguage];
      text("[" + txt + "]", x1 + (x2 - x1) * (j + 0.5) / 12.0, Y_control);
    }
    strokeWeight(0);
  }

  // ---------------------------------------------------------------------
  // "Scenario" tab
  // ---------------------------------------------------------------------

  void drawScenarioTab (float x1, float y1, float x2, float y2) {
    int[] range = scenarioRange(currentDataSource);
    int n1 = range[0];
    int n2 = range[1];

    if (isInside(X_clicked, Y_clicked, x1, y1, x2, y2)) {
      int selectedValue = n1 + scaledIndexFromClick(X_clicked, x1, x2, n2 - n1 + 1, -0.5);
      if (mouseButton == LEFT) {
        if (currentDataSource == dataID_climateEngineering || currentDataSource == dataID_climateArchive) {
          runScriptLine("Sample Year Start " + selectedValue);
        } else if (currentDataSource == dataID_ensembleForecast) {
          runScriptLine("Sample Member Start " + selectedValue);
        } else if (currentDataSource == dataID_ensembleObservation) {
          runScriptLine("Sample Station Start " + selectedValue);
        }
      }
      if (mouseButton == RIGHT) {
        if (currentDataSource == dataID_climateEngineering || currentDataSource == dataID_climateArchive) {
          runScriptLine("Sample Year End " + selectedValue);
        } else if (currentDataSource == dataID_ensembleForecast) {
          runScriptLine("Sample Member End " + selectedValue);
        } else if (currentDataSource == dataID_ensembleObservation) {
          runScriptLine("Sample Station End " + selectedValue);
        }
      }
    }

    int[] current = scenarioCurrentValues(currentDataSource);
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
      String txt = scenarioTickLabel(currentDataSource, j, n1);
      text(txt, x1 + (x2 - x1) * (j + 0.5) / float(n2 - n1 + 1), Y_control - 0.1 * MessageSize);
    }
  }

  int[] scenarioRange (int dataSource) {
    if (dataSource == dataID_climateEngineering ||
        dataSource == dataID_climateArchive ||
        dataSource == dataID_climateTypicalYear) {
      return new int[]{1950, 2050};
    }
    if (dataSource == dataID_ensembleForecast) {
      return new int[]{ensembleForecastStart, ensembleForecastEnd};
    }
    if (dataSource == dataID_ensembleObservation) {
      return new int[]{ensembleObservationStart, ensembleObservationEnd};
    }
    return new int[]{0, 1};
  }

  int[] scenarioCurrentValues (int dataSource) {
    if (dataSource == dataID_climateEngineering || dataSource == dataID_climateArchive) {
      return new int[]{sampleYearStart, sampleYearEnd};
    }
    if (dataSource == dataID_ensembleForecast) {
      return new int[]{sampleMemberStart, sampleMemberEnd};
    }
    if (dataSource == dataID_ensembleObservation) {
      return new int[]{sampleStationStart, sampleStationEnd};
    }
    return new int[]{0, 0};
  }

  String scenarioTickLabel (int dataSource, int j, int n1) {
    String txt = (j % 5 == 0) ? "|" : ".";
    if ((dataSource == dataID_climateEngineering || dataSource == dataID_climateArchive) && (j % 10 == 5)) {
      txt = nf(j - 5 + n1, 0) + "s";
    } else if (dataSource == dataID_ensembleForecast) {
      txt = nf(j + n1, 0);
    } else if (dataSource == dataID_ensembleObservation) {
      txt = ensembleObservationCoordinates[ensembleObservationNearestStationIndex[j]].getCode();
    }
    return txt;
  }

  // ---------------------------------------------------------------------
  // Impact layer selector (3x3 grid)
  // ---------------------------------------------------------------------

  void drawimpactLayerIndexSelector () {
    float displayBarWidth = UI_rollout.dX;
    float displayBarHeight = 4.5 * MessageSize;
    float offsetX = UI_rollout.cX + 0.5 * displayBarWidth;
    float offsetY = pixel_A + pixel_B + 2 * pixel_H + 0.5 * displayBarHeight;

    handleimpactLayerIndexClicks(offsetX, offsetY, displayBarWidth, displayBarHeight);
    renderimpactLayerIndexGrid(offsetX, offsetY, displayBarWidth, displayBarHeight);
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

  void handleimpactLayerIndexClicks (float offsetX, float offsetY, float w, float h) {
    for (int n = 0; n < 9; n++) {
      float[] b = impactCellBounds(n, offsetX, offsetY, w, h);
      if (isInside(X_clicked, Y_clicked, b[0], b[2], b[1], b[3])) {
        runScriptLine("Impact Layer Index " + n);
      }
    }
  }

  void renderimpactLayerIndexGrid (float offsetX, float offsetY, float w, float h) {
    for (int n = 0; n < 9; n++) {
      float[] b = impactCellBounds(n, offsetX, offsetY, w, h);
      float x1 = b[0], x2 = b[1], y1 = b[2], y2 = b[3];

      if (n == STUDY.impactLayerIndex) {
        fill(255, 127, 0);
      } else if (n / 3 == STUDY.impactLayerIndex / 3) {
        fill(127, 63, 0);
      } else {
        fill(127);
      }
      noStroke();
      rect(x1, y1, x2 - x1, y2 - y1);

      textAlign(CENTER, CENTER);
      if (n == STUDY.impactLayerIndex) {
        stroke(0);
        fill(0);
      } else if (n / 3 == STUDY.impactLayerIndex / 3) {
        stroke(191);
        fill(191);
      } else {
        stroke(255);
        fill(255);
      }
      textSize(1.0 * MessageSize);
      text(STAT_N_Title[n], 0.5 * (x1 + x2), 0.5 * (y1 + y2));
    }
  }
}
