class SolarImpacts {

  final static String CLASS_STAMP = "SolarImpacts";

  boolean rebuild_Image_array = true;

  PImage[][] Image;

  boolean displayImage = false;

  int sectionType = 0; // 0:off, 1:horizontal, 2:vertical(front), 3:vertical(side)

  float Y = 0;
  float X = 0;
  float Z = 0;
  float R = 0; // North is up by default
  float U = 500; // i.e. 500 = 500m
  float V = 500; // i.e. 500 = 500m

  int RES1 = 400;
  int RES2 = 400;



  boolean record_IMG = false;

  // --- WIN3D overlay freshness --------------------------------------------
  // this.Image[][] only ever gets repainted by calculate_Impact_CurrentPreBaked()
  // below, which reads the model's baked Direct/Diffuse PNGs (tied to
  // whatever geometry and camera they were baked from - see
  // preBakeViewport.pde) plus a handful of STUDY/TIME/STATION/palette
  // settings ("the time of the analysis"). The day-navigation and
  // impact-type-toggle actions (actions.pde) re-show the WIN3D overlay by
  // just picking a different already-computed slice of this.Image[][],
  // without recomputing anything - win3DOverlay_isFresh() is what lets
  // draw_WIN3D_layers.pde tell whether that slice is still trustworthy
  // before actually painting it, the same win3DCache-style snapshot/
  // compare pattern Earth3D.pde/Faces.pde/Sun3D.pde use for their own
  // caches.
  //
  // The camera fields are recorded separately from everything else, by a
  // separate method (win3DOverlay_recordCameraState() below), called from
  // a separate place (preBakeViewport.pde, right at its own top, before it
  // overrides WIN3D.dX/dY to fit the impact resolution) - not here. The
  // Direct/Diffuse/mask PNGs calculate_Impact_CurrentPreBaked() reads are
  // tied to whichever camera preBakeViewport() actually baked them from;
  // calculate_Impact_CurrentPreBaked() itself doesn't read the camera at
  // all; it can run again at any time (e.g. clicking over to a Skin
  // Potential graph page re-triggers it) with the live camera sitting
  // anywhere, which has nothing to do with which camera the underlying
  // pixels came from. Recording cameraX/Y/Z etc. here, at
  // calculate_Impact_CurrentPreBaked()'s own completion, would compare
  // future camera positions against wherever the camera happened to be at
  // that click instead - so a camera move away and back would often
  // "match" a snapshot that was itself already wrong, and comparing
  // against a genuinely different camera move would equally often
  // mismatch one that's actually still fine.
  boolean win3DOverlay_cameraSnapshotValid = false;
  boolean win3DOverlay_analysisSnapshotValid = false;

  float win3DOverlay_cameraX = Float.NaN;
  float win3DOverlay_cameraY = Float.NaN;
  float win3DOverlay_cameraZ = Float.NaN;
  float win3DOverlay_rotationX = Float.NaN;
  float win3DOverlay_rotationZ = Float.NaN;
  float win3DOverlay_zoom = Float.NaN;
  int win3DOverlay_projectionTypeIndex = Integer.MIN_VALUE;
  int win3DOverlay_currentCameraIndex = Integer.MIN_VALUE;

  int win3DOverlay_facesGeneration = Integer.MIN_VALUE;
  int win3DOverlay_model1DsGeneration = Integer.MIN_VALUE;
  int win3DOverlay_terrainGeneration = Integer.MIN_VALUE;

  int win3DOverlay_startDay = Integer.MIN_VALUE;
  int win3DOverlay_endDay = Integer.MIN_VALUE;
  float win3DOverlay_dayIncrement = Float.NaN;
  int win3DOverlay_daysMergedCount = Integer.MIN_VALUE;
  int win3DOverlay_impactLayerIndex = Integer.MIN_VALUE;
  int win3DOverlay_temporalFilterSetting = Integer.MIN_VALUE;
  int win3DOverlay_skyScenarioSetting = Integer.MIN_VALUE;
  int win3DOverlay_beginDay = Integer.MIN_VALUE;
  float win3DOverlay_stationLat = Float.NaN;
  int win3DOverlay_currentDataSource = Integer.MIN_VALUE;
  int win3DOverlay_sampleYearStart = Integer.MIN_VALUE;
  int win3DOverlay_sampleYearEnd = Integer.MIN_VALUE;
  int win3DOverlay_sampleMemberStart = Integer.MIN_VALUE;
  int win3DOverlay_sampleMemberEnd = Integer.MIN_VALUE;
  int win3DOverlay_sampleStationStart = Integer.MIN_VALUE;
  int win3DOverlay_sampleStationEnd = Integer.MIN_VALUE;

  int win3DOverlay_activeColorscaleIndex = Integer.MIN_VALUE;
  int win3DOverlay_activeColorscaleDirection = Integer.MIN_VALUE;
  float win3DOverlay_activeColorscaleFactor = Float.NaN;
  int win3DOverlay_passiveColorscaleIndex = Integer.MIN_VALUE;
  int win3DOverlay_passiveColorscaleDirection = Integer.MIN_VALUE;
  float win3DOverlay_passiveColorscaleFactor = Float.NaN;

  // Tolerance for win3DOverlay_cameraMatches() below: a mouse-drag orbit is
  // incremental (many small per-frame updates), so rotating away and then
  // back by eye essentially never retraces the exact same floating-point
  // path - without some slack, the camera would almost never compare equal
  // to the snapshot again after the first move, even sitting back exactly
  // where it visually started. Position is in the same world-scaled units
  // as WIN3D.cameraX/Y/Z; angle covers both rotationX/Z and zoom (a
  // field-of-view angle in degrees) - both are generous enough to absorb
  // that drift while staying far too small to notice on screen.
  final float win3DOverlay_cameraPositionTolerance = 0.01;
  final float win3DOverlay_cameraAngleTolerance = 0.01;

  // Just the camera half of win3DOverlay_isFresh() below - position, zoom
  // and projection, i.e. exactly what decides whether this.Image[][] still
  // lines up with what's actually on screen right now. draw_WIN3D_layers.pde
  // checks this on its own, separately from the model/analysis-time fields
  // below, as a precondition before painting the overlay at all (and before
  // its own white backdrop rect) - not as a reason to blank the viewport by
  // itself; a camera mismatch just means win3DOverlay_isFresh() is false
  // too, so nothing in that block runs and the live 3D view shows through
  // untouched. projectionTypeIndex/currentCameraIndex are discrete choices,
  // not drift-prone measurements, so those stay exact.
  boolean win3DOverlay_cameraMatches () {
    return this.win3DOverlay_cameraSnapshotValid &&
      funcs.is_zero(this.win3DOverlay_cameraX - WIN3D.cameraX, win3DOverlay_cameraPositionTolerance) &&
      funcs.is_zero(this.win3DOverlay_cameraY - WIN3D.cameraY, win3DOverlay_cameraPositionTolerance) &&
      funcs.is_zero(this.win3DOverlay_cameraZ - WIN3D.cameraZ, win3DOverlay_cameraPositionTolerance) &&
      funcs.is_zero(this.win3DOverlay_rotationX - WIN3D.rotationX, win3DOverlay_cameraAngleTolerance) &&
      funcs.is_zero(this.win3DOverlay_rotationZ - WIN3D.rotationZ, win3DOverlay_cameraAngleTolerance) &&
      funcs.is_zero(this.win3DOverlay_zoom - WIN3D.zoom, win3DOverlay_cameraAngleTolerance) &&
      this.win3DOverlay_projectionTypeIndex      == WIN3D.projectionTypeIndex &&
      this.win3DOverlay_currentCameraIndex       == WIN3D.currentCameraIndex;
  }

  boolean win3DOverlay_isFresh () {
    return this.win3DOverlay_analysisSnapshotValid &&
      this.win3DOverlay_cameraMatches() &&
      this.win3DOverlay_facesGeneration          == allFaces.winCacheGeneration &&
      this.win3DOverlay_model1DsGeneration       == allModel1Ds.winCacheGeneration &&
      this.win3DOverlay_terrainGeneration        == Terrain.winCacheGeneration &&
      this.win3DOverlay_startDay                 == STUDY.startDay &&
      this.win3DOverlay_endDay                   == STUDY.endDay &&
      this.win3DOverlay_dayIncrement              == STUDY.dayIncrement &&
      this.win3DOverlay_daysMergedCount          == STUDY.daysMergedCount &&
      this.win3DOverlay_impactLayerIndex         == STUDY.impactLayerIndex &&
      this.win3DOverlay_temporalFilterSetting    == STUDY.temporalFilterSetting &&
      this.win3DOverlay_skyScenarioSetting       == STUDY.skyScenarioSetting &&
      this.win3DOverlay_beginDay                 == TIME.beginDay &&
      this.win3DOverlay_stationLat                == STATION.getLatitude() &&
      this.win3DOverlay_currentDataSource        == currentDataSource &&
      this.win3DOverlay_sampleYearStart          == sampleYearStart &&
      this.win3DOverlay_sampleYearEnd            == sampleYearEnd &&
      this.win3DOverlay_sampleMemberStart        == sampleMemberStart &&
      this.win3DOverlay_sampleMemberEnd          == sampleMemberEnd &&
      this.win3DOverlay_sampleStationStart       == sampleStationStart &&
      this.win3DOverlay_sampleStationEnd         == sampleStationEnd &&
      this.win3DOverlay_activeColorscaleIndex    == allFaces.activeColorscaleIndex &&
      this.win3DOverlay_activeColorscaleDirection == allFaces.activeColorscaleDirection &&
      this.win3DOverlay_activeColorscaleFactor   == allFaces.activeColorscaleFactor &&
      this.win3DOverlay_passiveColorscaleIndex   == allFaces.passiveColorscaleIndex &&
      this.win3DOverlay_passiveColorscaleDirection == allFaces.passiveColorscaleDirection &&
      this.win3DOverlay_passiveColorscaleFactor  == allFaces.passiveColorscaleFactor;
  }

  // Called once, by preBakeViewport.pde, right at its own top - before it
  // overrides WIN3D.dX/dY to fit the impact resolution - so this is
  // whichever camera actually drove the Direct/Diffuse/mask PNGs it's
  // about to bake, not wherever the camera happens to sit afterward.
  void win3DOverlay_recordCameraState () {
    this.win3DOverlay_cameraSnapshotValid = true;

    this.win3DOverlay_cameraX                  = WIN3D.cameraX;
    this.win3DOverlay_cameraY                  = WIN3D.cameraY;
    this.win3DOverlay_cameraZ                  = WIN3D.cameraZ;
    this.win3DOverlay_rotationX                = WIN3D.rotationX;
    this.win3DOverlay_rotationZ                = WIN3D.rotationZ;
    this.win3DOverlay_zoom                     = WIN3D.zoom;
    this.win3DOverlay_projectionTypeIndex      = WIN3D.projectionTypeIndex;
    this.win3DOverlay_currentCameraIndex       = WIN3D.currentCameraIndex;
  }

  // Called once, right as calculate_Impact_CurrentPreBaked() finishes a
  // successful computation, so every field below is simply "whatever
  // calculate_Impact_CurrentPreBaked() actually used this time" - extend
  // both together if that function ever reads something new. Deliberately
  // leaves the camera fields alone - see win3DOverlay_recordCameraState()
  // above for why those are recorded separately, elsewhere.
  void win3DOverlay_recordAnalysisState () {
    this.win3DOverlay_analysisSnapshotValid = true;

    this.win3DOverlay_facesGeneration          = allFaces.winCacheGeneration;
    this.win3DOverlay_model1DsGeneration       = allModel1Ds.winCacheGeneration;
    this.win3DOverlay_terrainGeneration        = Terrain.winCacheGeneration;

    this.win3DOverlay_startDay                 = STUDY.startDay;
    this.win3DOverlay_endDay                   = STUDY.endDay;
    this.win3DOverlay_dayIncrement              = STUDY.dayIncrement;
    this.win3DOverlay_daysMergedCount          = STUDY.daysMergedCount;
    this.win3DOverlay_impactLayerIndex         = STUDY.impactLayerIndex;
    this.win3DOverlay_temporalFilterSetting    = STUDY.temporalFilterSetting;
    this.win3DOverlay_skyScenarioSetting       = STUDY.skyScenarioSetting;
    this.win3DOverlay_beginDay                 = TIME.beginDay;
    this.win3DOverlay_stationLat                = STATION.getLatitude();
    this.win3DOverlay_currentDataSource        = currentDataSource;
    this.win3DOverlay_sampleYearStart          = sampleYearStart;
    this.win3DOverlay_sampleYearEnd            = sampleYearEnd;
    this.win3DOverlay_sampleMemberStart        = sampleMemberStart;
    this.win3DOverlay_sampleMemberEnd          = sampleMemberEnd;
    this.win3DOverlay_sampleStationStart       = sampleStationStart;
    this.win3DOverlay_sampleStationEnd         = sampleStationEnd;

    this.win3DOverlay_activeColorscaleIndex    = allFaces.activeColorscaleIndex;
    this.win3DOverlay_activeColorscaleDirection = allFaces.activeColorscaleDirection;
    this.win3DOverlay_activeColorscaleFactor   = allFaces.activeColorscaleFactor;
    this.win3DOverlay_passiveColorscaleIndex   = allFaces.passiveColorscaleIndex;
    this.win3DOverlay_passiveColorscaleDirection = allFaces.passiveColorscaleDirection;
    this.win3DOverlay_passiveColorscaleFactor  = allFaces.passiveColorscaleFactor;
  }

  void resize_Image_array () {

    this.Image = new PImage [2][(1 + STUDY.endDay - STUDY.startDay)];

    for (int i = 0; i < this.Image.length; i++) {
      for (int j = STUDY.startDay - 1; j < STUDY.endDay; j++) { // total image at j = -1

        this.Image[i][j + 1] = createImage(2, 2, RGB); // empty and small
      }
    }

    allSolarImpacts.rebuild_Image_array = false;
  }


  void calculate_Impact_CurrentPreBaked () {

    if (allSolarImpacts.rebuild_Image_array) {
      this.resize_Image_array();
    }

    if (this.sectionType != 0) {

      showWaitCursor();

      int[] startK_endK = get_startK_endK();
      int start_k = startK_endK[0];
      int end_k = startK_endK[1];
      int count_k = 1 + end_k - start_k;
      if (count_k < 0) count_k = 0;


      int RES1 = this.RES1;
      int RES2 = this.RES2;

      // This camera's Model2Ds (tree/person) visibility mask, baked by
      // preBakeViewport() (via ShadeViewport()'s noShadeOnlyVisible2DTextures
      // mode - see ShadeViewport.pde) at this very same RES1 x RES2 grid, under
      // the same Folder_Shadings/NearLatitude_Stamp()/SceneName/Camera
      // naming the Shadings[] PNGs below are loaded from. Loaded once, up
      // front, rather than per day/hour: it doesn't depend on either.
      // Left null when no bake exists yet for this camera, so every
      // pixel below just falls through to the normal computation.
      String camera2DTextureFile = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName + "2Ds_Camera" + nf(cameraIndex, 2) + ".png";
      PImage Model2DsTexture = new File(camera2DTextureFile).exists() ? loadImage(camera2DTextureFile) : null;

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

      for (int p = 0; p < 1; p++) {
        int l = STUDY.impactLayerIndex;

        PImage[] total_Image_RGBA = new PImage[2];
        for (int q = 0; q < numberOfImpactVariations; q++) {
          total_Image_RGBA[q] = createImage(RES1, RES2, RGB);
        }

        float[][][][] total_Matrix_ARGB;
        total_Matrix_ARGB = new float [2][4][RES1][RES2];

        for (int np = 0; np < (RES1 * RES2); np++) {
          int Image_X = np % RES1;
          int Image_Y = np / RES1;

          for (int q = 0; q < numberOfImpactVariations; q++) {
            total_Matrix_ARGB[q][0][Image_X][Image_Y] = 0;
            total_Matrix_ARGB[q][1][Image_X][Image_Y] = 0;
            total_Matrix_ARGB[q][2][Image_X][Image_Y] = 0;
            total_Matrix_ARGB[q][3][Image_X][Image_Y] = 0;
          }
        }

        for (int j = STUDY.startDay; j < STUDY.endDay; j++) {

          now_j = (j * int(STUDY.dayIncrement) + TIME.beginDay + 365) % 365;

          if (now_j >= 365) {
            now_j = now_j % 365;
          }
          if (now_j < 0) {
            now_j = (now_j + 365) % 365;
          }

          float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);

          int DATE_ANGLE_approximate = int((DATE_ANGLE + 15) / 30) * 30;
          if (DATE_ANGLE_approximate == 360) DATE_ANGLE_approximate = 0;

          int nk = FIND_SCENARIO_CLOSE_TO_DAILY_STAT(l, start_k, end_k, j, DATE_ANGLE, WIN3D.impactTypeIndex);

          if (nk == -1) continue;
          int k = int(nk / STUDY.daysMergedCount);
          int j_ADD = nk % STUDY.daysMergedCount;

          float[][][][] Matrix_ARGB;

          Matrix_ARGB = new float [2][4][RES1][RES2];

          for (int np = 0; np < (RES1 * RES2); np++) {
            int Image_X = np % RES1;
            int Image_Y = np / RES1;

            for (int q = 0; q < numberOfImpactVariations; q++) {
              Matrix_ARGB[q][0][Image_X][Image_Y] = FLOAT_undefined;
              Matrix_ARGB[q][1][Image_X][Image_Y] = FLOAT_undefined;
              Matrix_ARGB[q][2][Image_X][Image_Y] = FLOAT_undefined;
              Matrix_ARGB[q][3][Image_X][Image_Y] = FLOAT_undefined;
            }
          }

          PImage[] Image_RGBA = new PImage[2];
          for (int q = 0; q < numberOfImpactVariations; q++) {
            Image_RGBA[q] = createImage(RES1, RES2, RGB);
          }

          int valuesNUM = 0;

          for (int i = 4; i <= 20; i++) { // to make it faster. Also the images are not available out of this period.
            if (STUDY.isInHourlyRange(i)) {

              float HOUR_ANGLE = i;
              float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);

              if (SunR[3] > 0) {

                now_k = k + start_k;
                now_i = i;
                now_j = int(j * STUDY.dayIncrement + (j_ADD - int(funcs.roundTo(0.5 * STUDY.daysMergedCount, 1))) + TIME.beginDay + 365) % 365;

                if (now_j >= 365) {
                  now_j = now_j % 365;
                }
                if (now_j < 0) {
                  now_j = (now_j + 365) % 365;
                }

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

                  boolean isMemberCounted = filter(currentDataSource, LAYER_cloudcover.id, STUDY.temporalFilterSetting, STUDY.skyScenarioSetting, now_i, now_j, now_k);

                  if (isMemberCounted) {
                    values_R_dir = 0.001 * Pa;
                    values_R_dif = 0.001 * Pb;
                    values_E_dir = 0.001 * Pc;
                    values_E_dif = 0.001 * Pd;

                    for (int RAD_TYPE = 0; RAD_TYPE <= 1; RAD_TYPE++) {
                      float RAD_VALUE = values_R_dir;
                      float EFF_VALUE = values_E_dir;

                      PImage[] Shadings = new PImage [2];
                      for (int SHD = 0; SHD <= 1; SHD++) {

                        String File_Name = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName;

                        if (RAD_TYPE == 0) {
                          File_Name += nf(DATE_ANGLE_approximate, 3) + "_" + STR_SHD[SHD] + "_" + nf(int(funcs.roundTo(HOUR_ANGLE * 100, 1.0)), 4);
                        } else {
                          File_Name += "DIF_" + STR_SHD[SHD];
                        }

                        File_Name += "_Camera" + nf(cameraIndex, 2) + ".png";


                        Shadings[SHD]  = loadImage(File_Name);
                      }

                      for (int np = 0; np < (RES1 * RES2); np++) {
                        int Image_X = np % RES1;
                        int Image_Y = np / RES1;

                        for (int q = 0; q < numberOfImpactVariations; q++) {
                          if (is_undefined(Matrix_ARGB[q][0][Image_X][Image_Y])) {

                            Matrix_ARGB[q][0][Image_X][Image_Y] = 0;
                            Matrix_ARGB[q][1][Image_X][Image_Y] = 0;
                            Matrix_ARGB[q][2][Image_X][Image_Y] = 0;
                            Matrix_ARGB[q][3][Image_X][Image_Y] = 0;
                          }
                        }

                        color COL0 = Shadings[0].get(Image_X, Image_Y);
                        color COL1 = Shadings[1].get(Image_X, Image_Y);
                        //red: COL >> 16 & 0xFF; green: COL >>8 & 0xFF; blue: COL & 0xFF;
                        float COL_V0 = (COL0 >> 8 & 0xFF) / 255.0;
                        float COL_V1 = (COL1 >> 8 & 0xFF) / 255.0;

                        float COL_Alpha = (COL1 >> 24 & 0xFF);

                        Matrix_ARGB[Impact_ACTIVE][0][Image_X][Image_Y] = COL_Alpha;
                        Matrix_ARGB[Impact_PASSIVE][0][Image_X][Image_Y] = COL_Alpha;

                        Matrix_ARGB[Impact_ACTIVE][2][Image_X][Image_Y] += RAD_VALUE * COL_V1;

                        if (EFF_VALUE < 0) {
                          Matrix_ARGB[Impact_PASSIVE][1][Image_X][Image_Y] -= EFF_VALUE * COL_V1;
                          if (COL_V0 != COL_V1) Matrix_ARGB[Impact_PASSIVE][3][Image_X][Image_Y] -= EFF_VALUE * (COL_V0 - COL_V1);
                        } else {
                          Matrix_ARGB[Impact_PASSIVE][3][Image_X][Image_Y] += EFF_VALUE * COL_V1;
                          if (COL_V0 != COL_V1) Matrix_ARGB[Impact_PASSIVE][1][Image_X][Image_Y] += EFF_VALUE * (COL_V0 - COL_V1);
                        }

                        if (np == 0) valuesNUM += 1;
                      }
                    }
                  }
                }
              }
            }
          }

          float valuesMUL = 0;

          if (valuesNUM != 0) {
            valuesMUL = funcs.DayTime(STATION.getLatitude(), DATE_ANGLE) / (1.0 * valuesNUM);
          }

          for (int q = 0; q < numberOfImpactVariations; q++) {
            Image_RGBA[q].loadPixels();
          }

          for (int np = 0; np < (RES1 * RES2); np++) {
            int Image_X = np % RES1;
            int Image_Y = np / RES1;

            // A pixel this camera's Model2Ds mask marks non-transparent -
            // a tree/person was hit there - skips the radiation/impact
            // computation below entirely and is simply painted with that
            // billboard's own real color, so trees and people show up in
            // the analysis the same way they do in the live shaded
            // preview.
            color Model2DsPixel = (Model2DsTexture != null) ? Model2DsTexture.get(Image_X, Image_Y) : 0;
            boolean isModel2DsPixel = (Model2DsTexture != null) && (((Model2DsPixel >> 24) & 0xFF) != 0);

            for (int q = 0; q < numberOfImpactVariations; q++) {

              if (isModel2DsPixel) {
                Image_RGBA[q].pixels[np] = Model2DsPixel;
                continue;
              }

              float Image_A = Matrix_ARGB[q][0][Image_X][Image_Y] * valuesMUL;
              float Image_R = Matrix_ARGB[q][1][Image_X][Image_Y] * valuesMUL;
              float Image_G = Matrix_ARGB[q][2][Image_X][Image_Y] * valuesMUL;
              float Image_B = Matrix_ARGB[q][3][Image_X][Image_Y] * valuesMUL;

              total_Matrix_ARGB[q][0][Image_X][Image_Y] += Image_A;
              total_Matrix_ARGB[q][1][Image_X][Image_Y] += Image_R;
              total_Matrix_ARGB[q][2][Image_X][Image_Y] += Image_G;
              total_Matrix_ARGB[q][3][Image_X][Image_Y] += Image_B;

              float[] _c = {
                0, 0, 0, 0
              };

              float _u = 0;

              float valuesSUM = FLOAT_undefined;

              int PAL_type = 0;
              int PAL_direction = 1;
              float PAL_multiplier = 1;

              if (q == Impact_ACTIVE) {
                valuesSUM = Image_G;

                PAL_type = allFaces.activeColorscaleIndex;
                PAL_direction = allFaces.activeColorscaleDirection;
                PAL_multiplier = allFaces.activeColorscaleFactor;

                //_u = 0.5 * (0.1 * PAL_multiplier * valuesSUM);
                //_u = (0.1 * PAL_multiplier * valuesSUM);
                _u = (0.2 * PAL_multiplier * valuesSUM);
              }

              if (q == Impact_PASSIVE) {
                float AVERAGE, PERCENTAGE, COMPARISON;

                AVERAGE = (Image_B - Image_R);
                if ((Image_B + Image_R) > 0.00001) PERCENTAGE = (Image_B - Image_R) / (1.0 * (Image_B + Image_R));
                else PERCENTAGE = 0.0;
                COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);

                valuesSUM = COMPARISON;

                PAL_type = allFaces.passiveColorscaleIndex;
                PAL_direction = allFaces.passiveColorscaleDirection;
                PAL_multiplier = allFaces.passiveColorscaleFactor;

                //_u = 0.5 + 0.5 * (0.1 * PAL_multiplier * valuesSUM);
                _u = 0.5 + 0.5 * (0.2 * PAL_multiplier * valuesSUM);
              }


              //if ((Image_X == RES1 / 2) && (Image_Y == RES2 / 2)) println("Image Processing: <CENTER> valuesSUM =", valuesSUM);
              //if ((Image_X == RES1 - 1) && (Image_Y == RES2 - 1)) println("Image Processing: <CORNER> valuesSUM =", valuesSUM);

              _u = applyPalDirection(_u, PAL_direction);

              _c = PAINT.getColorStyle(PAL_type, _u);

              if (Image_A != 0) Image_RGBA[q].pixels[np] = color(_c[1], _c[2], _c[3]);
              else Image_RGBA[q].pixels[np] = color(223, 223, 223);
            }
          }

          for (int q = 0; q < numberOfImpactVariations; q++) {
            Image_RGBA[q].updatePixels();


            //if (cameraIndex == 0) {
            this.Image[q][j + 1] = Image_RGBA[q];
            if (this.record_IMG == true) {
              String myFile = getFilename_SolarImpact() + "_solar_" + nf(q, 1) + "_" + nf(j + 1, 0) + ".jpg";
              this.Image[q][j + 1].save(myFile);
              println("File created:" + myFile);
            }
            //}
          }
        }

        {
          int j = -1; // << to put the summary graph before the daily graphs

          for (int q = 0; q < numberOfImpactVariations; q++) {
            total_Image_RGBA[q].loadPixels();
          }

          for (int np = 0; np < (RES1 * RES2); np++) {
            int Image_X = np % RES1;
            int Image_Y = np / RES1;

            // Same Model2Ds mask bypass as the per-day loop above, applied
            // here to the summary image too.
            color Model2DsPixel = (Model2DsTexture != null) ? Model2DsTexture.get(Image_X, Image_Y) : 0;
            boolean isModel2DsPixel = (Model2DsTexture != null) && (((Model2DsPixel >> 24) & 0xFF) != 0);

            for (int q = 0; q < numberOfImpactVariations; q++) {

              if (isModel2DsPixel) {
                total_Image_RGBA[q].pixels[np] = Model2DsPixel;
                continue;
              }

              float Image_A = total_Matrix_ARGB[q][0][Image_X][Image_Y] / (1.0 * (STUDY.endDay - STUDY.startDay));
              float Image_R = total_Matrix_ARGB[q][1][Image_X][Image_Y] / (1.0 * (STUDY.endDay - STUDY.startDay));
              float Image_G = total_Matrix_ARGB[q][2][Image_X][Image_Y] / (1.0 * (STUDY.endDay - STUDY.startDay));
              float Image_B = total_Matrix_ARGB[q][3][Image_X][Image_Y] / (1.0 * (STUDY.endDay - STUDY.startDay));

              float[] _c = {
                0, 0, 0, 0
              };

              float _u = 0;

              float valuesSUM = FLOAT_undefined;

              int PAL_type = 0;
              int PAL_direction = 1;
              float PAL_multiplier = 1;

              if (q == Impact_ACTIVE) {
                valuesSUM = Image_G;

                PAL_type = allFaces.activeColorscaleIndex;
                PAL_direction = allFaces.activeColorscaleDirection;
                PAL_multiplier = allFaces.activeColorscaleFactor;

                //_u = 0.5 * (0.1 * PAL_multiplier * valuesSUM);
                //_u = (0.1 * PAL_multiplier * valuesSUM);
                _u = (0.2 * PAL_multiplier * valuesSUM);
              }

              if (q == Impact_PASSIVE) {
                float AVERAGE, PERCENTAGE, COMPARISON;

                AVERAGE = (Image_B - Image_R);
                if ((Image_B + Image_R) > 0.00001) PERCENTAGE = (Image_B - Image_R) / (1.0 * (Image_B + Image_R));
                else PERCENTAGE = 0.0;
                COMPARISON = ((abs(PERCENTAGE)) * AVERAGE);

                valuesSUM = COMPARISON;

                PAL_type = allFaces.passiveColorscaleIndex;
                PAL_direction = allFaces.passiveColorscaleDirection;
                PAL_multiplier = allFaces.passiveColorscaleFactor;

                //_u = 0.5 + 0.5 * (0.1 * PAL_multiplier * valuesSUM);
                _u = 0.5 + 0.5 * (0.2 * PAL_multiplier * valuesSUM);
              }

              _u = applyPalDirection(_u, PAL_direction);

              _c = PAINT.getColorStyle(PAL_type, _u);

              if (Image_A != 0) total_Image_RGBA[q].pixels[np] = color(_c[1], _c[2], _c[3]);
              else total_Image_RGBA[q].pixels[np] = color(223, 223, 223);
            }
          }

          for (int q = 0; q < numberOfImpactVariations; q++) {

            total_Image_RGBA[q].updatePixels();

            //if (cameraIndex == 0) {
            this.Image[q][0] = total_Image_RGBA[q];
            if (this.record_IMG == true) {
              String myFile = getFilename_SolarImpact() + "_solar_" + nf(q, 1) + "_" + nf(0, 0) + ".jpg";
              this.Image[q][0].save(myFile);
              println("File created:" + myFile);
            }
            //}
          }
        }
      }

      this.win3DOverlay_recordAnalysisState();

      showArrowCursor();
    }
  }



  void render_Shadows_selectedSections () {

    for (int o = Select3D.sectionSelection.length - 1; o >= 0; o--) {

      int f = Select3D.sectionSelection[o];

      this.sectionType = allSections.get_type(f);
      this.RES1 = allSections.get_res1(f);
      this.RES2 = allSections.get_res2(f);

      this.X = allSections.getX(f);
      this.Y = allSections.getY(f);
      this.Z = allSections.getZ(f) + 0.1; // <<
      this.R = allSections.getR(f);
      this.U = allSections.getU(f);
      this.V = allSections.getV(f);

      SceneName = "Section_" + Section_Stamp();

      castShadows_CurrentSection();
    }

    this.displayImage = true;
    allSolidImpacts.displayImage = false;
    UI_rollout.revise();
  }




  void calculate_Impact_selectedSections () {

    for (int o = Select3D.sectionSelection.length - 1; o >= 0; o--) {

      int f = Select3D.sectionSelection[o];

      this.sectionType = allSections.get_type(f);
      this.RES1        = allSections.get_res1(f);
      this.RES2        = allSections.get_res2(f);

      this.X = allSections.getX(f);
      this.Y = allSections.getY(f);
      this.Z = allSections.getZ(f) + 0.1; // <<
      this.R = allSections.getR(f);
      this.U = allSections.getU(f);
      this.V = allSections.getV(f);

      SceneName = "Section_" + Section_Stamp();

      this.calculate_Impact_CurrentPreBaked();


      for (int j = STUDY.startDay - 1; j < STUDY.endDay; j++) {
        for (int q = 0; q < numberOfImpactVariations; q++) {
          allSections.SolarImpact[f][j + 1][q] = createImage(this.RES1, this.RES2, RGB);

          allSections.SolarImpact[f][j + 1][q].copy(this.Image[q][j + 1], 0, 0, this.RES1, this.RES2, 0, 0, this.RES1, this.RES2);
        }
      }
    }
  }


  public void to_XML (XML xml) {

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setBoolean(parent, "displayImage", this.displayImage);

    XML_setFloat(parent, "X", this.X);
    XML_setFloat(parent, "Y", this.Y);
    XML_setFloat(parent, "Z", this.Z);
    XML_setFloat(parent, "R", this.R);
    XML_setFloat(parent, "U", this.U);
    XML_setFloat(parent, "V", this.V);

    XML_setInt(parent, "RES1", this.RES1);
    XML_setInt(parent, "RES2", this.RES2);

    XML_setInt(parent, "sectionType", this.sectionType);
  }


  public void from_XML (XML xml) {

    XML parent = xml.getChild(this.CLASS_STAMP);

    this.displayImage = XML_getBoolean(parent, "displayImage");

    this.X = XML_getFloat(parent, "X");
    this.Y = XML_getFloat(parent, "Y");
    this.Z = XML_getFloat(parent, "Z");
    this.R = XML_getFloat(parent, "R");
    this.U = XML_getFloat(parent, "U");
    this.V = XML_getFloat(parent, "V");

    this.RES1 = XML_getInt(parent, "RES1");
    this.RES2 = XML_getInt(parent, "RES2");
    this.sectionType = XML_getInt(parent, "sectionType");
  }


}
