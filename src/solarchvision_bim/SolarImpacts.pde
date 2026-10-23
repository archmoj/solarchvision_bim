class SolarImpacts {

  final static String CLASS_STAMP = "SolarImpacts";

  // volatile: same reasoning as ShadeViewport.pde's own isShadingViewport,
  // which this mirrors - set true/false around calculate_Impact_
  // CurrentPreBaked()'s own parallel work below, read from draw()/
  // keyPressed()/keyReleased() (via isBakingInProgress(), global_
  // functions.pde) on whatever thread runs those, not necessarily the one
  // that called calculate_Impact_CurrentPreBaked(). Added proactively,
  // not after the fact this time - see ShadeViewport.pde's own isShading
  // Viewport for what tracking this down the hard way, after the fact,
  // actually looked like.
  volatile boolean isCalculatingImpact = false;

  final boolean isMultithreaded_calcImpact_perDay = false;

  boolean rebuild_Image_array = true;

  PImage[][] Image;

  // Raw A/R/G/B data calculate_Impact_CurrentPreBaked() builds Image[][]
  // from, retained (not just computed-and-discarded, the way it used to
  // be, as purely local variables) so the WIN3D hover tooltip
  // (solarImpactOverlayHover.pde, via win3DOverlay_rawValuesAt() below)
  // can show the actual underlying data instead of the rendered PImage's
  // RGBA - which has already been through a color palette, the Model2Ds
  // billboard override, and the "else gray" fallback for an untouched
  // pixel, and is no longer the real data (and, for Image[][]'s RGB-
  // format PImages specifically, doesn't even carry a meaningful alpha to
  // gate on - every pixel reads back fully opaque regardless of whether
  // there's real data there).
  //
  // Matrix_ARGB is indexed exactly like Image[q][dayIndex]: dayIndex 0
  // isn't used here (the total/summary slot is total_Matrix_ARGB instead,
  // "j = -1" per that function's own comment on its own total block),
  // dayIndex j + 1 for day j. Each day's own valuesMUL (a single per-day
  // scalar - see where it's computed in calculate_Impact_
  // CurrentPreBaked()) still needs applying on read, same as that
  // function applies it when building Image_RGBA, so it's persisted
  // alongside in dayValuesMUL rather than baked into Matrix_ARGB itself.
  // total_Matrix_ARGB is the raw accumulated sum across the whole day
  // range, with the day-count division calculate_Impact_
  // CurrentPreBaked() applies for the total image's own Image_RGBA
  // likewise applied on read (win3DOverlay_rawValuesAt() below), not
  // baked in.
  float[][][][][] Matrix_ARGB;
  float[] dayValuesMUL;
  float[][][][] total_Matrix_ARGB;

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

  // One-shot: set by win3DOverlay_recordAnalysisState() whenever a fresh
  // computation completes, so draw_WIN3D_layers.pde can tell that
  // happened - and that it's worth re-checking whether the overlay should
  // now show - even on a frame where nothing set WIN3D.update (recomputing
  // via a Skin Potential graph page, say, only calls STUDY.revise()).
  // Consumed (read-and-reset) by draw_WIN3D_layers.pde, same one-shot
  // idiom as WIN3D.showShading/showSolarImpactOverride.
  boolean win3DOverlay_recomputed = false;

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
  // checks this on its own, separately from win3DOverlay_dataFresh() below:
  // when the camera matches, the overlay is drawn straight over the live
  // (matching) WIN3D content with no white backdrop at all - any gap left
  // by an aspect-ratio mismatch between the overlay and the viewport just
  // shows more of that same, correct 3D view through. When it doesn't
  // match, the overlay is only shown at all if the person explicitly asked
  // for it (the day-navigation/impact-type-toggle actions, bound to
  // D/d/Shift+Tab), and in that case a white backdrop is needed, since
  // whatever's behind the gap is now a different perspective than the
  // overlay itself. projectionTypeIndex/currentCameraIndex are discrete
  // choices, not drift-prone measurements, so those stay exact.
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

  // The model/analysis-time half of freshness, independent of the camera -
  // whether this.Image[][] itself is still correct, regardless of where
  // the camera currently is. draw_WIN3D_layers.pde checks this on its own
  // (alongside win3DOverlay_cameraMatches() above) so an explicit
  // day-navigation/impact-type-toggle request can show the overlay even
  // with the camera mismatched, while still refusing to show data that's
  // actually stale (the model changed, the analysis-time settings
  // changed) no matter how the display was requested.
  boolean win3DOverlay_dataFresh () {
    return this.win3DOverlay_analysisSnapshotValid &&
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

  // Convenience: both halves at once - the data is correct AND the camera
  // is the one it was computed from, so the overlay can be shown with no
  // caveats (no white backdrop needed either). See win3DOverlay_dataFresh()
  // and win3DOverlay_cameraMatches() above for the two things this checks.
  boolean win3DOverlay_isFresh () {
    return this.win3DOverlay_dataFresh() && this.win3DOverlay_cameraMatches();
  }

  // Whether draw_WIN3D_layers.pde is about to paint the white clearing
  // rect over the entire WIN3D area this frame - true exactly in the
  // "explicit cycling request, but the camera doesn't match" case (see
  // that file's own comment): the data is fresh, the camera doesn't
  // match, an override was requested, and the requested day/type slice
  // actually exists. WIN3D.draw() calls this at its own top to skip its
  // (otherwise wasted) render work when the result is just going to be
  // painted over anyway - see that method's own comment for why reading
  // WIN3D.showSolarImpactOverride here, rather than a locally-captured
  // copy of it, is still safe to do from inside WIN3D.draw().
  boolean win3DOverlay_needsClearRect () {
    return this.win3DOverlay_dataFresh() &&
      !this.win3DOverlay_cameraMatches() &&
      WIN3D.showSolarImpactOverride &&
      impactDisplayDay < this.Image[WIN3D.impactTypeIndex].length;
  }

  // Returns the raw {A, R, G, B} data calculate_Impact_CurrentPreBaked()
  // actually built this.Image[q][dayIndex]'s pixel (x, y) from -
  // Matrix_ARGB (that day's own accumulated values, with that day's own
  // dayValuesMUL applied) for dayIndex >= 1, or total_Matrix_ARGB (summed
  // across the whole day range, divided by the day count) for the
  // summary image (dayIndex == 0, "j = -1" per that function's own
  // comment on its own total block) - see the fields' own comments above
  // for why this reads these rather than the rendered PImage's RGBA.
  // Null when there's nothing meaningful to show: no computation has
  // filled this slot yet, the ray behind this pixel never actually hit
  // anything (is_defined() on the raw, pre-multiply/pre-division A value
  // - checking afterward isn't reliable, since multiplying or dividing
  // FLOAT_undefined can land back under the is_defined() threshold even
  // though it was never real), or the final A comes out to exactly 0 -
  // the same "has real data" test calculate_Impact_CurrentPreBaked()
  // itself uses (Image_A != 0) to decide between a palette color and the
  // plain gray fallback.
  float[] win3DOverlay_rawValuesAt (int q, int dayIndex, int x, int y) {
    float a, r, g, b;

    if (dayIndex == 0) {
      if (this.total_Matrix_ARGB == null) return null;
      float rawA = this.total_Matrix_ARGB[q][0][x][y];
      if (!is_defined(rawA)) return null;

      float dayCount = STUDY.endDay - STUDY.startDay;
      if (dayCount <= 0) return null;

      a = rawA / dayCount;
      r = this.total_Matrix_ARGB[q][1][x][y] / dayCount;
      g = this.total_Matrix_ARGB[q][2][x][y] / dayCount;
      b = this.total_Matrix_ARGB[q][3][x][y] / dayCount;
    } else {
      if (this.Matrix_ARGB == null || dayIndex >= this.Matrix_ARGB.length || this.Matrix_ARGB[dayIndex] == null) return null;

      float[][][][] day = this.Matrix_ARGB[dayIndex];
      float rawA = day[q][0][x][y];
      if (!is_defined(rawA)) return null;

      float mul = this.dayValuesMUL[dayIndex];
      a = rawA * mul;
      r = day[q][1][x][y] * mul;
      g = day[q][2][x][y] * mul;
      b = day[q][3][x][y] * mul;
    }

    if (a == 0) return null;

    return new float[] { a, r, g, b };
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

  // model_changed() bumps allFaces/allModel1Ds/Terrain's winCacheGeneration
  // counters - exactly what win3DOverlay_dataFresh() above reads as its
  // "has the model changed" signal - for two different reasons: an actual
  // structural/material edit (which should invalidate this.Image[][]), and
  // also, via update_frame_layout.pde, a pure viewport resize (WIN3D.
  // graphics gets recreated by createGraphics(), so the cached PShapes
  // built against the old one need rebuilding - nothing about the model's
  // actual geometry changed). win3DOverlay_dataFresh() can't tell those two
  // reasons apart from the counters alone, so update_frame_layout.pde calls
  // this right after its own resize-triggered model_changed() call, to
  // catch this recorded snapshot up to the new (but data-wise unchanged)
  // generation values - an actual edit elsewhere, which never calls this,
  // still invalidates freshness exactly as before.
  void win3DOverlay_resyncGenerationAfterResize () {
    this.win3DOverlay_facesGeneration    = allFaces.winCacheGeneration;
    this.win3DOverlay_model1DsGeneration = allModel1Ds.winCacheGeneration;
    this.win3DOverlay_terrainGeneration  = Terrain.winCacheGeneration;
  }

  // Called once, right as calculate_Impact_CurrentPreBaked() finishes a
  // successful computation, so every field below is simply "whatever
  // calculate_Impact_CurrentPreBaked() actually used this time" - extend
  // both together if that function ever reads something new. Deliberately
  // leaves the camera fields alone - see win3DOverlay_recordCameraState()
  // above for why those are recorded separately, elsewhere.
  void win3DOverlay_recordAnalysisState () {
    this.win3DOverlay_analysisSnapshotValid = true;
    this.win3DOverlay_recomputed = true;

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

  // Palette-maps already-computed Image_A/R/G/B values for variation q
  // (Impact_ACTIVE or Impact_PASSIVE) into a color - the same formula
  // for calculate_Impact_CurrentPreBaked()'s own per-day parallel loop,
  // its repair loop right after that (re-deriving these same values for
  // one flagged pixel - see that loop's own comment), and its summary
  // loop at the very end. Pure - reads only its own parameters plus the
  // shared, read-only allFaces/STUDY/PAINT (all stateless, see
  // ShadeViewport.pde's own comment on that) - safe to call from many
  // threads at once or a single thread afterward, no special handling
  // either way. Deliberately takes Image_A/R/G/B as parameters rather
  // than Matrix_ARGB/Image_X/Image_Y directly: the parallel loop needs
  // those same values for its own total_Matrix_ARGB accumulation first,
  // and the summary loop derives them from total_Matrix_ARGB instead of
  // Matrix_ARGB - this way every caller computes its own values its own
  // way, and only the palette math itself is shared.
  color paletteMapImpactValue (int q, float Image_A, float Image_R, float Image_G, float Image_B) {
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
      PAL_multiplier = STUDY.paletteColorscaleMultiplier(allFaces.activeColorscaleFactor);

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
      PAL_multiplier = STUDY.paletteColorscaleMultiplier(allFaces.passiveColorscaleFactor);

      //_u = 0.5 + 0.5 * (0.1 * PAL_multiplier * valuesSUM);
      _u = 0.5 + 0.5 * (0.2 * PAL_multiplier * valuesSUM);
    }

    _u = applyPalDirection(_u, PAL_direction);

    _c = PAINT.getColorStyle(PAL_type, _u);

    return (Image_A != 0) ? color(_c[1], _c[2], _c[3]) : color(223, 223, 223);
  }

  void calculate_Impact_CurrentPreBaked () {

    if (allSolarImpacts.rebuild_Image_array) {
      this.resize_Image_array();
    }

    if (this.sectionType != 0) {

      this.isCalculatingImpact = true;

      // STEP 0 (not yet parallelized): timing instrumentation only, no
      // behavior change - a baseline to compare each later parallelized
      // step against. Three categories, matched to the three per-pixel
      // loops identified as parallelization targets: calcImpact_
      // accumulationMillis (the hot loop, run once per qualifying day/
      // hour/RAD_TYPE combination - see its own comment below),
      // calcImpact_perDayPaletteMillis (once per day), calcImpact_
      // summaryPaletteMillis (once, at the end). calcImpact_loadImageMillis
      // is tracked separately since it's file I/O, not CPU-bound pixel
      // work - parallelizing it would mean concurrent disk reads, a
      // different kind of change than threading the per-pixel loops.
      // calcImpact_setupMillis catches everything else (zero-init loops,
      // scenario lookups, sun position, the per-day Matrix_ARGB reset) by
      // being whatever's left over: calcImpact_startMillis's elapsed time
      // minus the other four categories, computed at the end rather than
      // tracked explicitly at each of its several small call sites.
      long calcImpact_startMillis = millis();
      long calcImpact_loadImageMillis = 0;
      long calcImpact_accumulationMillis = 0;
      int calcImpact_accumulationPasses = 0;
      long calcImpact_perDayPaletteMillis = 0;
      long calcImpact_summaryPaletteMillis = 0;

      // One executor, created once here and reused for every one of the
      // accumulation loop's ~hundreds of passes below (one per qualifying
      // day/hour/RAD_TYPE combination) rather than a fresh thread pool per
      // pass - creating and tearing down a pool that many times in one
      // call would be real overhead, and ShadeViewport.pde's own
      // isShadingViewport/volatile saga showed repeated pool churn is
      // worth avoiding on general principle, not just for performance.
      // Shut down once, after the whole function's work is done (see
      // this function's own end).
      int calcImpact_numThreads = max(1, Runtime.getRuntime().availableProcessors() - 1);
      java.util.concurrent.ExecutorService calcImpact_executor = java.util.concurrent.Executors.newFixedThreadPool(calcImpact_numThreads);

      showWaitCursor();

      int[] startK_endK = get_startK_endK();
      int start_k = startK_endK[0];
      int end_k = startK_endK[1];
      int count_k = 1 + end_k - start_k;
      if (count_k < 0) count_k = 0;


      int RES1 = this.RES1;
      int RES2 = this.RES2;
      // Declared here, not inside whichever loop first needed it, so
      // every parallelized loop below (the accumulation loop, deep
      // inside the hour/RAD_TYPE loop; the per-day palette loop, at the
      // day loop's own level; the summary palette loop, after the day
      // loop) can all see the same one, since RES1/RES2 don't change
      // again for the rest of this call.
      int calcImpact_totalPixels = RES1 * RES2;

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

      PImage[] diffuseShadings = new PImage[2];
      for (int SHD = 0; SHD <= 1; SHD++) {
        String diffuseFileName = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName + "DIF_" + STR_SHD[SHD] + "_Camera" + nf(cameraIndex, 2) + ".png";
        diffuseShadings[SHD] = loadImage(diffuseFileName);
      }

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

        // this.total_Matrix_ARGB aliases the same array the code below
        // already builds and accumulates into via the local name - no
        // other line in this function needs to change, this just also
        // keeps a reference reachable after the function returns. Same
        // reasoning for this.Matrix_ARGB/dayValuesMUL, sized here (one
        // slot per this.Image[q]'s own dayIndex) before the day loop
        // below fills each slot in turn.
        float[][][][] total_Matrix_ARGB;
        total_Matrix_ARGB = new float [2][4][RES1][RES2];
        this.total_Matrix_ARGB = total_Matrix_ARGB;

        this.Matrix_ARGB = new float[this.Image[0].length][][][][];
        this.dayValuesMUL = new float[this.Image[0].length];

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
          this.Matrix_ARGB[j + 1] = Matrix_ARGB;

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
                      float RAD_VALUE = (RAD_TYPE == 0) ? values_R_dir : values_R_dif;
                      float EFF_VALUE = (RAD_TYPE == 0) ? values_E_dir : values_E_dif;

                      PImage[] Shadings;
                      if (RAD_TYPE == 1) {
                        Shadings = diffuseShadings;
                      } else {
                        Shadings = new PImage [2];
                        for (int SHD = 0; SHD <= 1; SHD++) {

                          String File_Name = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName;
                          File_Name += nf(DATE_ANGLE_approximate, 3) + "_" + STR_SHD[SHD] + "_" + nf(int(funcs.roundTo(HOUR_ANGLE * 100, 1.0)), 4);
                          File_Name += "_Camera" + nf(cameraIndex, 2) + ".png";

                          long calcImpact_loadImageT0 = millis();
                          Shadings[SHD] = loadImage(File_Name);
                          calcImpact_loadImageMillis += millis() - calcImpact_loadImageT0;
                        }
                      }

                      // Independent per pixel - each np reads only this
                      // pass's own RAD_VALUE/EFF_VALUE (locals, captured
                      // by value) and Shadings[0]/[1] (already loaded,
                      // read-only PImages - loadImage() gives a plain CPU
                      // raster, same as ShadeViewport.pde's own billboard
                      // textures, safe for concurrent .get() reads - see
                      // that file's own comment on why that one wasn't
                      // the actual cause there), and writes only its own
                      // (Image_X, Image_Y) slot of Matrix_ARGB across all
                      // q/c indices - nothing here for two pixels' work
                      // to race on. Reuses calcImpact_executor (this
                      // function's own top) rather than creating a new
                      // pool for every pass.
                      //
                      // One chunk per thread here, not ShadeViewport.pde's
                      // totalPixels/numThreads - that fine split mattered
                      // there for reasons specific to its own raycasting
                      // workload (nothing to do with chunk size itself,
                      // in the end), not something to carry over by
                      // default. This loop's own per-pixel cost is
                      // uniform (two PImage.get() calls and some
                      // arithmetic, no hit/miss branching that varies
                      // much), so there's no load-imbalance reason to
                      // prefer many small chunks - and this loop runs
                      // ~hundreds of times per call, so fine chunking's
                      // dispatch overhead (building and awaiting many
                      // Futures) gets paid that many times over, which is
                      // what was actually dominating here: a jump from
                      // ~22,000 chunks/pass down to ~numThreads chunks/
                      // pass is a many-thousand-fold drop in Future
                      // submissions across the whole call.
                      long calcImpact_accumulationT0 = millis();
                      int calcImpact_numChunks = calcImpact_numThreads;
                      int calcImpact_chunkSize = (calcImpact_totalPixels + calcImpact_numChunks - 1) / calcImpact_numChunks;

                      final float calcImpact_RAD_VALUE = RAD_VALUE;
                      final float calcImpact_EFF_VALUE = EFF_VALUE;
                      final PImage[] calcImpact_Shadings = Shadings;
                      final float[][][][] calcImpact_Matrix_ARGB = Matrix_ARGB;
                      final int calcImpact_RES1 = RES1;

                      java.util.List<java.util.concurrent.Future<?>> calcImpact_accumulationFutures = new java.util.ArrayList<java.util.concurrent.Future<?>>();
                      for (int chunkStart = 0; chunkStart < calcImpact_totalPixels; chunkStart += calcImpact_chunkSize) {
                        final int npFrom = chunkStart;
                        final int npTo = min(calcImpact_totalPixels, chunkStart + calcImpact_chunkSize);

                        calcImpact_accumulationFutures.add(calcImpact_executor.submit(() -> {
                          for (int np = npFrom; np < npTo; np++) {
                            int Image_X = np % calcImpact_RES1;
                            int Image_Y = np / calcImpact_RES1;

                            for (int q = 0; q < numberOfImpactVariations; q++) {
                              if (is_undefined(calcImpact_Matrix_ARGB[q][0][Image_X][Image_Y])) {

                                calcImpact_Matrix_ARGB[q][0][Image_X][Image_Y] = 0;
                                calcImpact_Matrix_ARGB[q][1][Image_X][Image_Y] = 0;
                                calcImpact_Matrix_ARGB[q][2][Image_X][Image_Y] = 0;
                                calcImpact_Matrix_ARGB[q][3][Image_X][Image_Y] = 0;
                              }
                            }

                            color COL0 = calcImpact_Shadings[0].get(Image_X, Image_Y);
                            color COL1 = calcImpact_Shadings[1].get(Image_X, Image_Y);
                            //red: COL >> 16 & 0xFF; green: COL >>8 & 0xFF; blue: COL & 0xFF;
                            float COL_V0 = (COL0 >> 8 & 0xFF) / 255.0;
                            float COL_V1 = (COL1 >> 8 & 0xFF) / 255.0;

                            float COL_Alpha = (COL1 >> 24 & 0xFF);

                            calcImpact_Matrix_ARGB[Impact_ACTIVE][0][Image_X][Image_Y] = COL_Alpha;
                            calcImpact_Matrix_ARGB[Impact_PASSIVE][0][Image_X][Image_Y] = COL_Alpha;

                            calcImpact_Matrix_ARGB[Impact_ACTIVE][2][Image_X][Image_Y] += calcImpact_RAD_VALUE * COL_V1;

                            if (calcImpact_EFF_VALUE < 0) {
                              calcImpact_Matrix_ARGB[Impact_PASSIVE][1][Image_X][Image_Y] -= calcImpact_EFF_VALUE * COL_V1;
                              if (COL_V0 != COL_V1) calcImpact_Matrix_ARGB[Impact_PASSIVE][3][Image_X][Image_Y] -= calcImpact_EFF_VALUE * (COL_V0 - COL_V1);
                            } else {
                              calcImpact_Matrix_ARGB[Impact_PASSIVE][3][Image_X][Image_Y] += calcImpact_EFF_VALUE * COL_V1;
                              if (COL_V0 != COL_V1) calcImpact_Matrix_ARGB[Impact_PASSIVE][1][Image_X][Image_Y] += calcImpact_EFF_VALUE * (COL_V0 - COL_V1);
                            }
                          }
                        }));
                      }
                      awaitAll(calcImpact_accumulationFutures); // see parallel_utils.pde's own comment

                      calcImpact_accumulationMillis += millis() - calcImpact_accumulationT0;
                      calcImpact_accumulationPasses++;
                    }

                    valuesNUM += 1;
                  }
                }
              }
            }
          }

          float valuesMUL = 0;

          if (valuesNUM != 0) {
            valuesMUL = STUDY.effectiveDayTime(STATION.getLatitude(), DATE_ANGLE) / (1.0 * valuesNUM);
          }

          this.dayValuesMUL[j + 1] = valuesMUL;

          // valuesMUL above is reassigned inside its own if-block, so it
          // isn't effectively final and the lambda below can't capture it
          // directly - this copy, taken only after that reassignment has
          // already happened, is what gets captured instead.
          final float calcImpact_valuesMUL = valuesMUL;

          long calcImpact_perDayPaletteT0 = millis();

          for (int q = 0; q < numberOfImpactVariations; q++) {
            Image_RGBA[q].loadPixels();
          }

          // Independent per pixel, same reasoning as the accumulation
          // loop above: each np reads only this day's own Matrix_ARGB at
          // its own (Image_X, Image_Y), this day's own valuesMUL (a
          // local, captured by value), and the shared, read-only
          // Model2DsTexture/allFaces-palette-settings/PAINT (stateless -
          // no instance fields at all, same as Functions.pde's funcs was
          // - see ShadeViewport.pde's own comment on that) - and writes
          // only its own np's slot of Image_RGBA[0]/[1].pixels[] and its
          // own (Image_X, Image_Y) slot of total_Matrix_ARGB across all
          // q/c indices. total_Matrix_ARGB accumulates across days too,
          // but only ever from one day's own parallel dispatch at a time
          // - the day loop itself stays sequential (awaitAll() below
          // finishes before the next day starts), so there's no
          // cross-day write race on it either, same as the accumulation
          // loop's own total_Matrix_ARGB-equivalent reasoning for Matrix_
          // ARGB across hours. One chunk per thread, not totalPixels/
          // numThreads - same reasoning as the accumulation loop above -
          // unless isMultithreaded_calcImpact_perDay (this class's own
          // top) is false, in which case one chunk covers every pixel:
          // still the exact same executor/submit/await structure below,
          // just a single task that ends up running on whichever one
          // thread picks it up, with nothing else to race against it.
          // The repair pass right after awaitAll() already only runs
          // when isMultithreaded_calcImpact_perDay is true, for exactly
          // this reason - with it false, there's no race left for that
          // pass to be repairing.
          java.util.List<java.util.concurrent.Future<?>> calcImpact_perDayFutures = new java.util.ArrayList<java.util.concurrent.Future<?>>();
          int calcImpact_perDayNumChunks = isMultithreaded_calcImpact_perDay ? calcImpact_numThreads : 1;
          int calcImpact_perDayChunkSize = (calcImpact_totalPixels + calcImpact_perDayNumChunks - 1) / calcImpact_perDayNumChunks;
          for (int chunkStart = 0; chunkStart < calcImpact_totalPixels; chunkStart += calcImpact_perDayChunkSize) {
            final int npFrom = chunkStart;
            final int npTo = min(calcImpact_totalPixels, chunkStart + calcImpact_perDayChunkSize);

            calcImpact_perDayFutures.add(calcImpact_executor.submit(() -> {
              for (int np = npFrom; np < npTo; np++) {
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

                  float Image_A = Matrix_ARGB[q][0][Image_X][Image_Y] * calcImpact_valuesMUL;
                  float Image_R = Matrix_ARGB[q][1][Image_X][Image_Y] * calcImpact_valuesMUL;
                  float Image_G = Matrix_ARGB[q][2][Image_X][Image_Y] * calcImpact_valuesMUL;
                  float Image_B = Matrix_ARGB[q][3][Image_X][Image_Y] * calcImpact_valuesMUL;

                  total_Matrix_ARGB[q][0][Image_X][Image_Y] += Image_A;
                  total_Matrix_ARGB[q][1][Image_X][Image_Y] += Image_R;
                  total_Matrix_ARGB[q][2][Image_X][Image_Y] += Image_G;
                  total_Matrix_ARGB[q][3][Image_X][Image_Y] += Image_B;

                  Image_RGBA[q].pixels[np] = paletteMapImpactValue(q, Image_A, Image_R, Image_G, Image_B);
                }
              }
            }));
          }
          awaitAll(calcImpact_perDayFutures); // see parallel_utils.pde's own comment

          if (isMultithreaded_calcImpact_perDay) {
            // Single-threaded, after this day's own parallel dispatch has
            // fully finished. See parallel_utils.pde's own listSuspectPixels()
            // for what "isolated" means and why it can't be a real edge -
            // same residual, never fully root-caused low-level race
            // ShadeViewport.pde's own long investigation chased, appearing
            // to affect any sufficiently-exercised parallel pass in this
            // codebase, not something specific to this loop's own logic.
            // Unlike ShadeViewport.pde's own repair, there's no ray to
            // re-cast here - this loop's own per-pixel work is a pure,
            // deterministic palette-mapping computation over already-
            // computed Matrix_ARGB data, so the authoritative answer for a
            // flagged pixel is just redoing that same computation for it,
            // same formulas as the parallel loop above, line for line.
            // Deliberately does NOT re-add to total_Matrix_ARGB - that
            // already got this day's correct contribution from the
            // parallel pass above; doing it again here would double-count.
            for (int q = 0; q < numberOfImpactVariations; q++) {
              IntList suspectPixels = listSuspectPixels(Image_RGBA[q].pixels, RES1, RES2);

              for (int np : suspectPixels) {
                int Image_X = np % RES1;
                int Image_Y = np / RES1;

                color Model2DsPixel = (Model2DsTexture != null) ? Model2DsTexture.get(Image_X, Image_Y) : 0;
                boolean isModel2DsPixel = (Model2DsTexture != null) && (((Model2DsPixel >> 24) & 0xFF) != 0);

                if (isModel2DsPixel) {
                  Image_RGBA[q].pixels[np] = Model2DsPixel;
                  continue;
                }

                float Image_A = Matrix_ARGB[q][0][Image_X][Image_Y] * calcImpact_valuesMUL;
                float Image_R = Matrix_ARGB[q][1][Image_X][Image_Y] * calcImpact_valuesMUL;
                float Image_G = Matrix_ARGB[q][2][Image_X][Image_Y] * calcImpact_valuesMUL;
                float Image_B = Matrix_ARGB[q][3][Image_X][Image_Y] * calcImpact_valuesMUL;

                Image_RGBA[q].pixels[np] = paletteMapImpactValue(q, Image_A, Image_R, Image_G, Image_B);
              }
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
          calcImpact_perDayPaletteMillis += millis() - calcImpact_perDayPaletteT0;
        }

        {
          int j = -1; // << to put the summary graph before the daily graphs

          long calcImpact_summaryPaletteT0 = millis();

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

              total_Image_RGBA[q].pixels[np] = paletteMapImpactValue(q, Image_A, Image_R, Image_G, Image_B);
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
          calcImpact_summaryPaletteMillis += millis() - calcImpact_summaryPaletteT0;
        }
      }

      this.win3DOverlay_recordAnalysisState();

      showArrowCursor();

      // STEP 0 report: see this function's own top comment for what each
      // category covers. calcImpact_setupMillis is everything else,
      // computed as a remainder rather than tracked at each of its own
      // several small call sites.
      long calcImpact_totalMillis = millis() - calcImpact_startMillis;
      long calcImpact_setupMillis = calcImpact_totalMillis - calcImpact_loadImageMillis - calcImpact_accumulationMillis - calcImpact_perDayPaletteMillis - calcImpact_summaryPaletteMillis;
      println("calculate_Impact_CurrentPreBaked() timing (step 2 parallelized + diffuse files loaded once):");
      println("  total:            " + calcImpact_totalMillis + " ms");
      println("  loadImage:        " + calcImpact_loadImageMillis + " ms (" + nf(100.0 * calcImpact_loadImageMillis / calcImpact_totalMillis, 0, 1) + "%)");
      println("  accumulation:     " + calcImpact_accumulationMillis + " ms (" + nf(100.0 * calcImpact_accumulationMillis / calcImpact_totalMillis, 0, 1) + "%), " + calcImpact_accumulationPasses + " passes, " + (calcImpact_accumulationPasses > 0 ? nf((float) calcImpact_accumulationMillis / calcImpact_accumulationPasses, 0, 2) : "n/a") + " ms/pass");
      println("  per-day palette:  " + calcImpact_perDayPaletteMillis + " ms (" + nf(100.0 * calcImpact_perDayPaletteMillis / calcImpact_totalMillis, 0, 1) + "%)");
      println("  summary palette:  " + calcImpact_summaryPaletteMillis + " ms (" + nf(100.0 * calcImpact_summaryPaletteMillis / calcImpact_totalMillis, 0, 1) + "%)");
      println("  setup/other:      " + calcImpact_setupMillis + " ms (" + nf(100.0 * calcImpact_setupMillis / calcImpact_totalMillis, 0, 1) + "%)");

      calcImpact_executor.shutdown();
      this.isCalculatingImpact = false;
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
