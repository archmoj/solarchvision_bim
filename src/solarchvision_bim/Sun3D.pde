class Sun3D {
  final static String CLASS_STAMP = "Sun3D";

  final static float LONGITUDE_SPAN = 360.0;
  final static float LATITUDE_SPAN  = 180.0;
  final static float MEGAMETER = 1000000.0;
  final static float SUN_RADIUS  = 696.0 * MEGAMETER;
  final static float SUN_DISTANCE = 150000.0 * MEGAMETER;

  float lat_step = 5; //in degrees
  float lon_step  = 10; //in degrees

  int activeColorscaleIndex = 15;
  int activeColorscaleDirection = 1;
  float activeColorscaleFactor = 1;
  int passiveColorscaleIndex = 18;
  int passiveColorscaleDirection = -1;
  float passiveColorscaleFactor = 0.25;

  boolean displayGrid = true;
  boolean displayPath = true;
  boolean displayPattern = false;
  boolean displaySurface = true;
  boolean displayTexture = true;

  boolean fitInSkyDome = true;

  // Same reasoning as Moon3D.pde's own brightenLevel: the bundled
  // texture's own raw pixels render dimmer than the real Sun looks to
  // the naked eye, and this is the one thing that can fix that - a
  // one-time multiply of the loaded texture's own pixels (see
  // load_images()), not a per-vertex/per-frame tint. 1 leaves it
  // unchanged; 2.5 raises it two and a half times over (clamped at 255).
  float brightenLevel = 2.5;

  String Filename;

  PImage Map;

  class FaceVertex {
    float x, y, z;
    float u, v;
  }

  void load_images () {
    Map = loadImage(Filename);
    brightenTexture(Map, brightenLevel);
  }

  // Multiplies every pixel's own R/G/B by level, in place, clamped to
  // 255 - see Moon3D.pde's own brightenTexture() for the full reasoning;
  // this is the identical construction, just duplicated rather than
  // shared, the same way the two files' (right, up) frame construction
  // already is.
  void brightenTexture (PImage img, float level) {
    if (level == 1) return; // no-op - skip the loadPixels()/updatePixels() cost for nothing
    img.loadPixels();
    for (int i = 0; i < img.pixels.length; i++) {
      int c = img.pixels[i];
      int a = (c >> 24) & 0xFF;
      int r = min(255, round(((c >> 16) & 0xFF) * level));
      int g = min(255, round(((c >> 8) & 0xFF) * level));
      int b = min(255, round((c & 0xFF) * level));
      img.pixels[i] = (a << 24) | (r << 16) | (g << 8) | b;
    }
    img.updatePixels();
  }

  int wrapDayIndex (float rawDay) {
    int day = int(rawDay + 365) % 365;
    if (day >= 365) day = day % 365;
    if (day < 0) day = (day + 365) % 365;
    return day;
  }

  float[] activePalette (boolean useStudySettings) {
    int type = 0;
    int direction = 1;
    float multiplier = 1;
    if (WIN3D.impactTypeIndex == Impact_ACTIVE) {
      type = useStudySettings ? STUDY.activeColorscaleIndex : this.activeColorscaleIndex;
      direction = useStudySettings ? STUDY.activeColorscaleDirection : this.activeColorscaleDirection;
      multiplier = useStudySettings ? STUDY.activeColorscaleFactor : this.activeColorscaleFactor;
    }
    if (WIN3D.impactTypeIndex == Impact_PASSIVE) {
      type = useStudySettings ? STUDY.passiveColorscaleIndex : this.passiveColorscaleIndex;
      direction = useStudySettings ? STUDY.passiveColorscaleDirection : this.passiveColorscaleDirection;
      multiplier = useStudySettings ? STUDY.passiveColorscaleFactor : this.passiveColorscaleFactor;
    }
    return new float[] { type, direction, multiplier };
  }

  float[] paletteValueToColor (float rawValue, int palType, int palDirection) {
    float u = 0;
    if (WIN3D.impactTypeIndex == Impact_ACTIVE) u = rawValue;
    if (WIN3D.impactTypeIndex == Impact_PASSIVE) u = 0.5 + 0.5 * rawValue;
    u = applyPalDirection(u, palDirection);
    return PAINT.getColorStyle(palType, u);
  }

  // Everything buildSubFace used to recompute from scratch on every one of
  // its calls (1296 per draw() at the default lat_step=5/lon_step=10 - 36
  // x 36 - and some of it 4x again per call, once per vertex) that doesn't
  // actually depend on that call's own (Alpha, Beta): the station tilt,
  // tA/tB from SunPosition(), and the tidal-locking (forward, up, right)
  // frame. None of it changes within one draw() call, so it's computed
  // once there instead and passed in.
  class SkyFrame {
    float ta;
    float tA, tB;
    // F ("forward"): direction from the sphere toward the station. Used
    // for the translation step below (equivalent to -d*F, see its own
    // comment) regardless of displayTexture, and additionally as the
    // tidal-locking frame's forward axis when displayTexture is on.
    float Fx, Fy, Fz;
    // Rup/Rright: only meaningful (and only computed) when displayTexture
    // is on - see buildSubFace's own comment on why locking F alone isn't
    // enough.
    float Rupx, Rupy, Rupz;
    float Rrightx, Rrighty, Rrightz;
  }

  SkyFrame computeFrame () {
    SkyFrame f = new SkyFrame();

    float stationLat = STATION.getLatitude();
    f.ta = 90 - stationLat;

    float[] SunR = funcs.SunPosition(stationLat, SHADE_DATE_ANGLE, SHADE_HOUR_ANGLE);
    f.tA = funcs.asin_ang(SunR[3]);
    f.tB = funcs.atan2_ang(SunR[2], SunR[1]);

    f.Fx = -funcs.cos_ang(f.tB) * funcs.cos_ang(f.tA);
    f.Fy = -funcs.sin_ang(f.tB) * funcs.cos_ang(f.tA);
    f.Fz = -funcs.sin_ang(f.tA);

    // Unlike the sphere's own body rotation (tb, still always 0 here, same
    // as Moon3D.pde), tA/tB move the sphere's POSITION across the sky
    // over the course of a day - but the texture-to-surface mapping never
    // follows that move, so a station-facing patch of texture at one hour
    // becomes whatever patch happened to be on that side of the
    // (orientation-wise unmoving) body at another hour, as the sphere
    // swings from one side of the sky to the other.
    //
    // Locking only WHICH POINT faces the station (shifting lon/lat by a
    // single offset) isn't enough on its own - checked by hand before
    // settling on this: it fixes the center but leaves the texture free
    // to roll around that center point, which still visibly spins hour to
    // hour. Fully locking it needs an actual (forward, up, right) frame:
    // F is "which point faces the station" (as before); pole is the one
    // reference that itself barely moves within a day, so using it to pin
    // the texture's "up" is what keeps the whole disk's apparent rotation
    // down to the sun's real year-over-year declination drift (via
    // SHADE_DATE_ANGLE, part of SunPosition's own inputs, feeding tA/tB
    // here too) instead of its hour-to-hour one.
    if (this.displayTexture) {
      // This is the NORTH celestial pole, not the south one - confirmed
      // by hand against the real compiled app: dot this against
      // funcs.SunPosition()'s own output at a genuinely high (northern)
      // vs. low (southern) declination and the north one comes out
      // positive here, the south one negative. (An earlier derivation
      // here assumed the negated version - substituting Declination = 90
      // into SunPosition()'s own x/y/z formula - was already north,
      // which was backwards; see Moon3D.pde's buildRightUp(), which this
      // same construction was later copied from, for the real bug that
      // caused - the Moon's north pole visibly at the bottom of its own
      // texture.)
      float poleX = 0;
      float poleY = funcs.cos_ang(stationLat);
      float poleZ = funcs.sin_ang(stationLat);

      // right = pole x F
      f.Rrightx = poleY * f.Fz - poleZ * f.Fy;
      f.Rrighty = poleZ * f.Fx - poleX * f.Fz;
      f.Rrightz = poleX * f.Fy - poleY * f.Fx;
      float rightLen = sqrt(f.Rrightx * f.Rrightx + f.Rrighty * f.Rrighty + f.Rrightz * f.Rrightz);
      if (rightLen < 0.0001) {
        // Degenerate only if the sun sits exactly at the celestial pole
        // itself (not physically possible - Declination maxes out at
        // 23.45 - but guarded for safety rather than risking a NaN).
        f.Rrightx = 1;
        f.Rrighty = 0;
        f.Rrightz = 0;
        rightLen = 1;
      }
      f.Rrightx /= rightLen;
      f.Rrighty /= rightLen;
      f.Rrightz /= rightLen;

      // up = F x right
      f.Rupx = f.Fy * f.Rrightz - f.Fz * f.Rrighty;
      f.Rupy = f.Fz * f.Rrightx - f.Fx * f.Rrightz;
      f.Rupz = f.Fx * f.Rrighty - f.Fy * f.Rrightx;
    }

    return f;
  }

  // --- WIN3D retained-mode cache (sun disc) --------------------------------
  // draw() is WIN3D-only already (no target_window dispatch, unlike
  // drawGrid()/drawPath()/drawPattern() below), so this is a straight
  // build-once-and-replay like Faces.pde/Sky3D.pde: the disc's shape
  // depends only on where the sun currently is (station latitude +
  // SHADE_DATE_ANGLE/SHADE_HOUR_ANGLE - the same two globals
  // adjustShadeTime()/ShadeViewport.pde's own "move time" controls change)
  // plus a handful of display toggles - never on the camera.
  PShape win3DCache = null;
  float win3DCache_stationLat = Float.NaN;
  int win3DCache_SHADE_DATE_ANGLE = Integer.MIN_VALUE;
  int win3DCache_SHADE_HOUR_ANGLE = Integer.MIN_VALUE;
  boolean win3DCache_displayTexture = true;
  boolean win3DCache_fitInSkyDome = true;
  float win3DCache_celestialMagnification = Float.NaN;
  float win3DCache_skyRadius = Float.NaN;

  boolean win3DCache_isValid () {
    return this.win3DCache != null &&
      this.win3DCache_stationLat             == STATION.getLatitude() &&
      this.win3DCache_SHADE_DATE_ANGLE       == SHADE_DATE_ANGLE &&
      this.win3DCache_SHADE_HOUR_ANGLE       == SHADE_HOUR_ANGLE &&
      this.win3DCache_displayTexture         == this.displayTexture &&
      this.win3DCache_fitInSkyDome           == this.fitInSkyDome &&
      this.win3DCache_celestialMagnification == celestialMagnification &&
      this.win3DCache_skyRadius              == Sky3D.radius;
  }

  void win3DCache_recordState () {
    this.win3DCache_stationLat             = STATION.getLatitude();
    this.win3DCache_SHADE_DATE_ANGLE       = SHADE_DATE_ANGLE;
    this.win3DCache_SHADE_HOUR_ANGLE       = SHADE_HOUR_ANGLE;
    this.win3DCache_displayTexture         = this.displayTexture;
    this.win3DCache_fitInSkyDome           = this.fitInSkyDome;
    this.win3DCache_celestialMagnification = celestialMagnification;
    this.win3DCache_skyRadius              = Sky3D.radius;
  }

  PShape build_win3DCache () {
    PShape group = createShape(GROUP);

    float ScaleX  = 1;
    float ScaleY  = 1;
    float CEN_lon = 0;
    float CEN_lat = 0;

    float r = SUN_RADIUS * celestialMagnification;
    float d = SUN_DISTANCE;

    if(this.fitInSkyDome) {
      // fit the sun inside the sky sphere
      // bring it closer and resize it
      r *= Sky3D.radius / d;
      d = Sky3D.radius;
    }

    SkyFrame frame = computeFrame();

    for (float Alpha = 90; Alpha > -90; Alpha -= this.lat_step) {
      for (float Beta = 180; Beta > -180; Beta -= this.lon_step) {
        FaceVertex[] subFace = buildSubFace(Alpha, Beta, r, d, CEN_lon, CEN_lat, ScaleX, ScaleY, frame);
        cacheWriteFaceWIN3D(group, subFace);
      }
    }

    return group;
  }

  void cacheWriteFaceWIN3D (PShape group, FaceVertex[] subFace) {
    PShape child = createShape();
    child.beginShape();
    child.noStroke();
    if (this.displayTexture) {
      child.texture(this.Map);
    }

    for (int s = 0; s < subFace.length; s++) {
      child.vertex(
        subFace[s].x * overallScale * WIN3D.scale,
        -subFace[s].y * overallScale * WIN3D.scale,
        subFace[s].z * overallScale * WIN3D.scale,
        subFace[s].u * this.Map.width,
        subFace[s].v * this.Map.height
      );
    }

    child.endShape(CLOSE);
    group.addChild(child);
  }

  void draw () {
    if (!this.displaySurface) return;

    if (!this.win3DCache_isValid()) {
      this.win3DCache = this.build_win3DCache();
      this.win3DCache_recordState();
    }

    WIN3D.graphics.shape(this.win3DCache);
  }

  // --- WIN3D retained-mode cache (sky grid lines) --------------------------
  // drawGrid() is shared with the STUDY target, unlike draw() above, so it
  // can't just be replaced outright - see drawGrid()'s own cache-hit/
  // cache-miss split below. The grid lines are plain segments (no fill),
  // and the earlier Earth3D.pde/Faces.pde edges bug showed PShape LINES
  // children don't reliably render here - so, same fix as those: cache the
  // raw endpoint data, not a PShape, and replay it through the same
  // drawGridSegment()-shaped WIN3D.graphics.line() calls that already work.
  ArrayList<float[]> win3DCache_gridSegments = null;
  float win3DCache_grid_stationLat = Float.NaN;
  float win3DCache_grid_sSunPath = Float.NaN;
  int win3DCache_grid_startJ = Integer.MIN_VALUE;
  int win3DCache_grid_endJ = Integer.MIN_VALUE;

  boolean win3DCache_gridIsValid (float s_SunPath, int start_j, int end_j) {
    return this.win3DCache_gridSegments != null &&
      this.win3DCache_grid_stationLat == STATION.getLatitude() &&
      this.win3DCache_grid_sSunPath   == s_SunPath &&
      this.win3DCache_grid_startJ     == start_j &&
      this.win3DCache_grid_endJ       == end_j;
  }

  void win3DCache_gridRecordState (float s_SunPath, int start_j, int end_j) {
    this.win3DCache_grid_stationLat = STATION.getLatitude();
    this.win3DCache_grid_sSunPath   = s_SunPath;
    this.win3DCache_grid_startJ     = start_j;
    this.win3DCache_grid_endJ       = end_j;
  }


  FaceVertex[] buildSubFace (float Alpha, float Beta,
                                      float r, float d, float CEN_lon, float CEN_lat, float ScaleX, float ScaleY, SkyFrame frame) {
    FaceVertex[] subFace = new FaceVertex[4];

    float tb = 0;
    float ta = frame.ta;

    for (int s = 0; s < 4; s++) {
      FaceVertex vtx = new FaceVertex();

      float a = Alpha;
      float b = Beta;
      if (s == 2 || s == 3) a -= this.lat_step;
      if (s == 1 || s == 2) b -= this.lon_step;

      // corner position on the sun disc
      float x0 = r * funcs.cos_ang(b - 90) * funcs.cos_ang(a);
      float y0 = r * funcs.sin_ang(b - 90) * funcs.cos_ang(a);
      float z0 = r * funcs.sin_ang(a);

      if (this.displayTexture) {
        // This vertex's own direction (unit sphere, tb/ta applied, no
        // translation) - same transform as x1/y1/z1/x2/y2/z2 below, just
        // computed early and unscaled (divide out r) so it can be
        // decomposed against frame's (forward, up, right) axes.
        float ux0 = x0 / r;
        float uy0 = y0 / r;
        float uz0 = z0 / r;

        float ux1 = ux0 * funcs.cos_ang(tb) - uy0 * funcs.sin_ang(tb);
        float uy1 = ux0 * funcs.sin_ang(tb) + uy0 * funcs.cos_ang(tb);
        float uz1 = uz0;

        float ux2 = ux1;
        float uy2 = uz1 * funcs.sin_ang(ta) + uy1 * funcs.cos_ang(ta);
        float uz2 = uz1 * funcs.cos_ang(ta) - uy1 * funcs.sin_ang(ta);

        float compForward = ux2 * frame.Fx + uy2 * frame.Fy + uz2 * frame.Fz;
        float compUp = ux2 * frame.Rupx + uy2 * frame.Rupy + uz2 * frame.Rupz;
        float compRight = ux2 * frame.Rrightx + uy2 * frame.Rrighty + uz2 * frame.Rrightz;

        float lat = funcs.asin_ang(constrain(compUp, -1, 1)) - CEN_lat;
        float lon = Earth3D.unwrapLon(funcs.atan2_ang(-compForward, compRight) + 90 - CEN_lon, 0);
        vtx.u = (lon / ScaleX / LONGITUDE_SPAN + 0.5);
        vtx.v = (-lat / ScaleY / LATITUDE_SPAN + 0.5);
      }

      // rotate to location coordinates
      float x1 = x0 * funcs.cos_ang(tb) - y0 * funcs.sin_ang(tb);
      float y1 = x0 * funcs.sin_ang(tb) + y0 * funcs.cos_ang(tb);
      float z1 = z0;

      float x2 = x1;
      float y2 = z1 * funcs.sin_ang(ta) + y1 * funcs.cos_ang(ta);
      float z2 = z1 * funcs.cos_ang(ta) - y1 * funcs.sin_ang(ta);

      // move out to the sun's distance, in the sun's real current sky
      // direction - exactly -d*frame.F (F is defined as the direction
      // FROM the sphere TOWARD the station, so the sphere's own center,
      // relative to the station, sits at -F); reusing the already-computed
      // frame.Fx/Fy/Fz instead of recomputing cos(tB)*cos(tA) etc. here.
      x2 += -d * frame.Fx;
      y2 += -d * frame.Fy;
      z2 += -d * frame.Fz;

      vtx.x = x2;
      vtx.y = y2;
      vtx.z = z2;

      subFace[s] = vtx;
    }

    return subFace;
  }


  void drawGridSegment (int target_window, float[] SunA, float[] SunB, float s_SunPath, ArrayList<float[]> win3DCacheSink) {
    if ((SunA[3] <= 0) && (SunB[3] <= 0)) return; // both points below horizon

    if (target_window == TypeWindow.WIN3D) {
      float x1 =  SunA[1] * s_SunPath * WIN3D.scale;
      float y1 = -SunA[2] * s_SunPath * WIN3D.scale;
      float z1 =  SunA[3] * s_SunPath * WIN3D.scale;
      float x2 =  SunB[1] * s_SunPath * WIN3D.scale;
      float y2 = -SunB[2] * s_SunPath * WIN3D.scale;
      float z2 =  SunB[3] * s_SunPath * WIN3D.scale;

      WIN3D.graphics.line(x1, y1, z1, x2, y2, z2);

      if (win3DCacheSink != null) win3DCacheSink.add(new float[] { x1, y1, z1, x2, y2, z2 });
    }
    if (target_window == TypeWindow.STUDY) {
      float A_Alpha = 90 - funcs.acos_ang(SunA[3]);
      float A_Beta = 180 - funcs.atan2_ang(SunA[1], SunA[2]);
      float B_Alpha = 90 - funcs.acos_ang(SunB[3]);
      float B_Beta = 180 - funcs.atan2_ang(SunB[1], SunB[2]);
      STUDY.graphics.line((90 - A_Alpha) * (funcs.cos_ang(A_Beta - 90)) * s_SunPath * STUDY.view_S / 90.0,
                           -(90 - A_Alpha) * (funcs.sin_ang(A_Beta - 90)) * s_SunPath * STUDY.view_S / 90.0,
                           (90 - B_Alpha) * (funcs.cos_ang(B_Beta - 90)) * s_SunPath * STUDY.view_S / 90.0,
                           -(90 - B_Alpha) * (funcs.sin_ang(B_Beta - 90)) * s_SunPath * STUDY.view_S / 90.0);
    }
  }

  void drawGrid (int target_window, float x_SunPath, float y_SunPath, float z_SunPath, float s_SunPath, int start_j, int end_j) {
    if (target_window == TypeWindow.STUDY) {
      s_SunPath *= 0.65; // TODO: why do we need this?
      s_SunPath /= STUDY.ImageScale;
    }

    if (!this.displayGrid) return;

    boolean isWin3D = (target_window == TypeWindow.WIN3D);

    // Camera-only WIN3D frames with a valid cache skip the SunPosition()/
    // drawGridSegment() loops below entirely - x_SunPath/y_SunPath/
    // z_SunPath don't affect the segments themselves (only the translate
    // wrapper, reapplied either way), so they aren't part of the key.
    if (isWin3D && this.win3DCache_gridIsValid(s_SunPath, start_j, end_j)) {
      WIN3D.graphics.pushMatrix();
      WIN3D.graphics.translate(x_SunPath, y_SunPath, z_SunPath);
      WIN3D.graphics.strokeWeight(1);
      WIN3D.graphics.stroke(0);

      int len = this.win3DCache_gridSegments.size();
      for (int p = 0; p < len; p++) {
        float[] seg = this.win3DCache_gridSegments.get(p);
        WIN3D.graphics.line(seg[0], seg[1], seg[2], seg[3], seg[4], seg[5]);
      }

      WIN3D.graphics.popMatrix();
      return;
    }

    // Rebuilding (or STUDY target, which isn't cached): the live drawing
    // below is unchanged: on a WIN3D rebuild it also collects the same
    // segments it's drawing into a fresh list for next frame's cache hit.
    ArrayList<float[]> newWin3DCacheSegments = isWin3D ? new ArrayList<float[]>() : null;

    if (isWin3D) {
      WIN3D.graphics.pushMatrix();
      WIN3D.graphics.translate(x_SunPath, y_SunPath, z_SunPath);
      WIN3D.graphics.strokeWeight(1);
      WIN3D.graphics.stroke(0);
    }
    if (target_window == TypeWindow.STUDY) {
      STUDY.graphics.pushMatrix();
      STUDY.graphics.translate(x_SunPath, y_SunPath);
      STUDY.graphics.strokeWeight(1);
      STUDY.graphics.stroke(0);
    }

    float HOUR_step = 0.1;
    for (float j = start_j; j <= end_j; j += 30) {
      for (float i = 0; i <= 24; i += HOUR_step) {
        float[] SunA = funcs.SunPosition(STATION.getLatitude(), j, i);
        float[] SunB = funcs.SunPosition(STATION.getLatitude(), j, i + HOUR_step);
        drawGridSegment(target_window, SunA, SunB, s_SunPath, newWin3DCacheSegments);
      }
    }

    float DATE_step = 1;
    for (float i = 0; i <= 24; i += 1) {
      for (float j = start_j; j <= end_j; j += DATE_step) {
        float[] SunA = funcs.SunPosition(STATION.getLatitude(), j, i);
        float[] SunB = funcs.SunPosition(STATION.getLatitude(), j + DATE_step, i);
        drawGridSegment(target_window, SunA, SunB, s_SunPath, newWin3DCacheSegments);
      }
    }

    if (isWin3D) WIN3D.graphics.popMatrix();
    if (target_window == TypeWindow.STUDY) STUDY.graphics.popMatrix();

    if (isWin3D) {
      this.win3DCache_gridSegments = newWin3DCacheSegments;
      this.win3DCache_gridRecordState(s_SunPath, start_j, end_j);
    }
  }


  // --- WIN3D retained-mode cache (drawPath/drawPattern) ---------------------
  // Unlike every other WIN3D.pde-drawn class so far, these two don't shade
  // from the precomputed GlobalSolar/VertexSolar_amounts arrays - they read
  // live climate/weather data via getValue_currentDataSource()/
  // FIND_SCENARIO_CLOSE_TO_DAILY_STAT(), gated by a much wider set of
  // STUDY/case-bar/data-source inputs. Tracked directly below: STUDY's
  // day/hour range and filter settings, currentDataSource, TIME.beginDay,
  // station latitude, WIN3D.impactTypeIndex, and the resolved palette.
  // winCache_dataGeneration is the safety net for everything NOT cheaply
  // enumerable this way - the case-bar sample-range sliders
  // (sampleYearStart/End, sampleMemberStart/End, sampleStationStart/End -
  // get_startK_endK()'s own inputs) and the data actually being reloaded -
  // bumped from UI_caseBar.revise() (see UI_caseBar.pde), which is already
  // the pervasive "something about the active case/data selection changed"
  // hook for exactly these (every "Use <data source>" action, the case-bar
  // range-slider drag/release/wheel handlers, and file loads all call it).
  int winCache_dataGeneration = 0;

  boolean win3DCache_dataIsValid (int builtGeneration, int PAL_type, int builtPAL_type, int PAL_direction, int builtPAL_direction, float PAL_multiplier, float builtPAL_multiplier,
                                   int dataSource, int builtDataSource, float dayIncrement, float builtDayIncrement, int daysMergedCount, int builtDaysMergedCount,
                                   int startDay, int builtStartDay, int endDay, int builtEndDay, int impactLayerIndex, int builtImpactLayerIndex,
                                   int temporalFilterSetting, int builtTemporalFilterSetting, int skyScenarioSetting, int builtSkyScenarioSetting,
                                   float startHour, float builtStartHour, float endHour, float builtEndHour, int beginDay, int builtBeginDay,
                                   float stationLat, float builtStationLat, int impactTypeIndex, int builtImpactTypeIndex) {
    return builtGeneration == this.winCache_dataGeneration &&
      PAL_type == builtPAL_type && PAL_direction == builtPAL_direction && PAL_multiplier == builtPAL_multiplier &&
      dataSource == builtDataSource && dayIncrement == builtDayIncrement && daysMergedCount == builtDaysMergedCount &&
      startDay == builtStartDay && endDay == builtEndDay && impactLayerIndex == builtImpactLayerIndex &&
      temporalFilterSetting == builtTemporalFilterSetting && skyScenarioSetting == builtSkyScenarioSetting &&
      startHour == builtStartHour && endHour == builtEndHour && beginDay == builtBeginDay &&
      stationLat == builtStationLat && impactTypeIndex == builtImpactTypeIndex;
  }

  PShape win3DCache_pattern = null;
  int win3DCache_pattern_builtGeneration = -1;
  int win3DCache_pattern_PAL_type = -1;
  int win3DCache_pattern_PAL_direction = 0;
  float win3DCache_pattern_PAL_multiplier = -1;
  int win3DCache_pattern_dataSource = -1;
  float win3DCache_pattern_dayIncrement = Float.NaN;
  int win3DCache_pattern_daysMergedCount = -1;
  int win3DCache_pattern_startDay = Integer.MIN_VALUE;
  int win3DCache_pattern_endDay = Integer.MIN_VALUE;
  int win3DCache_pattern_impactLayerIndex = -1;
  int win3DCache_pattern_temporalFilterSetting = -1;
  int win3DCache_pattern_skyScenarioSetting = -1;
  float win3DCache_pattern_startHour = Float.NaN;
  float win3DCache_pattern_endHour = Float.NaN;
  int win3DCache_pattern_beginDay = Integer.MIN_VALUE;
  float win3DCache_pattern_stationLat = Float.NaN;
  int win3DCache_pattern_impactTypeIndex = -1;

  boolean win3DCache_patternIsValid (int PAL_type, int PAL_direction, float PAL_multiplier) {
    return this.win3DCache_pattern != null &&
      win3DCache_dataIsValid(this.win3DCache_pattern_builtGeneration,
        PAL_type, this.win3DCache_pattern_PAL_type, PAL_direction, this.win3DCache_pattern_PAL_direction, PAL_multiplier, this.win3DCache_pattern_PAL_multiplier,
        currentDataSource, this.win3DCache_pattern_dataSource, STUDY.dayIncrement, this.win3DCache_pattern_dayIncrement, STUDY.daysMergedCount, this.win3DCache_pattern_daysMergedCount,
        STUDY.startDay, this.win3DCache_pattern_startDay, STUDY.endDay, this.win3DCache_pattern_endDay, STUDY.impactLayerIndex, this.win3DCache_pattern_impactLayerIndex,
        STUDY.temporalFilterSetting, this.win3DCache_pattern_temporalFilterSetting, STUDY.skyScenarioSetting, this.win3DCache_pattern_skyScenarioSetting,
        STUDY.startHour, this.win3DCache_pattern_startHour, STUDY.endHour, this.win3DCache_pattern_endHour, TIME.beginDay, this.win3DCache_pattern_beginDay,
        STATION.getLatitude(), this.win3DCache_pattern_stationLat, WIN3D.impactTypeIndex, this.win3DCache_pattern_impactTypeIndex);
  }

  void win3DCache_patternRecordState (int PAL_type, int PAL_direction, float PAL_multiplier) {
    this.win3DCache_pattern_builtGeneration        = this.winCache_dataGeneration;
    this.win3DCache_pattern_PAL_type               = PAL_type;
    this.win3DCache_pattern_PAL_direction          = PAL_direction;
    this.win3DCache_pattern_PAL_multiplier         = PAL_multiplier;
    this.win3DCache_pattern_dataSource             = currentDataSource;
    this.win3DCache_pattern_dayIncrement           = STUDY.dayIncrement;
    this.win3DCache_pattern_daysMergedCount        = STUDY.daysMergedCount;
    this.win3DCache_pattern_startDay               = STUDY.startDay;
    this.win3DCache_pattern_endDay                 = STUDY.endDay;
    this.win3DCache_pattern_impactLayerIndex       = STUDY.impactLayerIndex;
    this.win3DCache_pattern_temporalFilterSetting  = STUDY.temporalFilterSetting;
    this.win3DCache_pattern_skyScenarioSetting     = STUDY.skyScenarioSetting;
    this.win3DCache_pattern_startHour              = STUDY.startHour;
    this.win3DCache_pattern_endHour                = STUDY.endHour;
    this.win3DCache_pattern_beginDay               = TIME.beginDay;
    this.win3DCache_pattern_stationLat             = STATION.getLatitude();
    this.win3DCache_pattern_impactTypeIndex        = WIN3D.impactTypeIndex;
  }

  // Segments cached as raw endpoint + stroke-color + weight data, NOT a
  // PShape - same fix as Faces.pde's/Earth3D.pde's edges: PShape LINES
  // children don't reliably render here, in any ordering of the style
  // calls, so these are replayed through the same live WIN3D.graphics.
  // line() call that already works, just reading cached values instead of
  // recomputing them. Each entry: {x1,y1,z1,x2,y2,z2, strokeR,G,B,A, weight}.
  ArrayList<float[]> win3DCache_pathSegments = null;
  int win3DCache_path_builtGeneration = -1;
  int win3DCache_path_PAL_type = -1;
  int win3DCache_path_PAL_direction = 0;
  float win3DCache_path_PAL_multiplier = -1;
  int win3DCache_path_dataSource = -1;
  float win3DCache_path_dayIncrement = Float.NaN;
  int win3DCache_path_daysMergedCount = -1;
  int win3DCache_path_startDay = Integer.MIN_VALUE;
  int win3DCache_path_endDay = Integer.MIN_VALUE;
  int win3DCache_path_impactLayerIndex = -1;
  int win3DCache_path_temporalFilterSetting = -1;
  int win3DCache_path_skyScenarioSetting = -1;
  float win3DCache_path_startHour = Float.NaN;
  float win3DCache_path_endHour = Float.NaN;
  int win3DCache_path_beginDay = Integer.MIN_VALUE;
  float win3DCache_path_stationLat = Float.NaN;
  int win3DCache_path_impactTypeIndex = -1;
  int win3DCache_path_impactDisplayDay = Integer.MIN_VALUE;

  boolean win3DCache_pathIsValid (int PAL_type, int PAL_direction, float PAL_multiplier) {
    return this.win3DCache_pathSegments != null &&
      win3DCache_dataIsValid(this.win3DCache_path_builtGeneration,
        PAL_type, this.win3DCache_path_PAL_type, PAL_direction, this.win3DCache_path_PAL_direction, PAL_multiplier, this.win3DCache_path_PAL_multiplier,
        currentDataSource, this.win3DCache_path_dataSource, STUDY.dayIncrement, this.win3DCache_path_dayIncrement, STUDY.daysMergedCount, this.win3DCache_path_daysMergedCount,
        STUDY.startDay, this.win3DCache_path_startDay, STUDY.endDay, this.win3DCache_path_endDay, STUDY.impactLayerIndex, this.win3DCache_path_impactLayerIndex,
        STUDY.temporalFilterSetting, this.win3DCache_path_temporalFilterSetting, STUDY.skyScenarioSetting, this.win3DCache_path_skyScenarioSetting,
        STUDY.startHour, this.win3DCache_path_startHour, STUDY.endHour, this.win3DCache_path_endHour, TIME.beginDay, this.win3DCache_path_beginDay,
        STATION.getLatitude(), this.win3DCache_path_stationLat, WIN3D.impactTypeIndex, this.win3DCache_path_impactTypeIndex) &&
      this.win3DCache_path_impactDisplayDay == impactDisplayDay;
  }

  void win3DCache_pathRecordState (int PAL_type, int PAL_direction, float PAL_multiplier) {
    this.win3DCache_path_builtGeneration        = this.winCache_dataGeneration;
    this.win3DCache_path_PAL_type               = PAL_type;
    this.win3DCache_path_PAL_direction          = PAL_direction;
    this.win3DCache_path_PAL_multiplier         = PAL_multiplier;
    this.win3DCache_path_dataSource             = currentDataSource;
    this.win3DCache_path_dayIncrement           = STUDY.dayIncrement;
    this.win3DCache_path_daysMergedCount        = STUDY.daysMergedCount;
    this.win3DCache_path_startDay               = STUDY.startDay;
    this.win3DCache_path_endDay                 = STUDY.endDay;
    this.win3DCache_path_impactLayerIndex       = STUDY.impactLayerIndex;
    this.win3DCache_path_temporalFilterSetting  = STUDY.temporalFilterSetting;
    this.win3DCache_path_skyScenarioSetting     = STUDY.skyScenarioSetting;
    this.win3DCache_path_startHour              = STUDY.startHour;
    this.win3DCache_path_endHour                = STUDY.endHour;
    this.win3DCache_path_beginDay               = TIME.beginDay;
    this.win3DCache_path_stationLat             = STATION.getLatitude();
    this.win3DCache_path_impactTypeIndex        = WIN3D.impactTypeIndex;
    this.win3DCache_path_impactDisplayDay       = impactDisplayDay;
  }

  void drawPath (int target_window, float x_SunPath, float y_SunPath, float z_SunPath, float s_SunPath) {
    if (!this.displayPath) return;

    // drawPath is only ever called for WIN3D today (unlike drawPattern/
    // drawCycles below, which are genuinely shared with STUDY/OBJ3D) -
    // target_window is kept as a parameter for the same reason the rest of
    // this file does, but the cache only ever applies here.
    boolean isWin3D = (target_window == TypeWindow.WIN3D);

    float[] palette = activePalette(false);
    int PAL_type = int(palette[0]);
    int PAL_direction = int(palette[1]);
    float PAL_multiplier = palette[2];

    if (isWin3D && this.win3DCache_pathIsValid(PAL_type, PAL_direction, PAL_multiplier)) {
      WIN3D.graphics.pushMatrix();
      WIN3D.graphics.translate(x_SunPath, y_SunPath, z_SunPath);
      WIN3D.graphics.strokeWeight(0);
      WIN3D.graphics.stroke(0, 0, 0);
      WIN3D.graphics.fill(0, 0, 0);
      WIN3D.graphics.line(-1 * s_SunPath, 0, 0, 1 * s_SunPath, 0, 0);
      WIN3D.graphics.line(0, -1 * s_SunPath, 0, 0, 1 * s_SunPath, 0);

      int len = this.win3DCache_pathSegments.size();
      for (int p = 0; p < len; p++) {
        float[] seg = this.win3DCache_pathSegments.get(p);
        WIN3D.graphics.stroke(seg[6], seg[7], seg[8], seg[9]);
        WIN3D.graphics.strokeWeight(seg[10]);
        WIN3D.graphics.line(seg[0], seg[1], seg[2], seg[3], seg[4], seg[5]);
      }

      WIN3D.graphics.popMatrix();
      return;
    }

    float keep_STUDY_dayIncrement = STUDY.dayIncrement;
    int keep_STUDY_daysMergedCount = STUDY.daysMergedCount;
    if ((currentDataSource == dataID_ensembleForecast) ||
        (currentDataSource == dataID_ensembleObservation)) {
      STUDY.dayIncrement = 1;
      STUDY.daysMergedCount = 1;
    }
    float previous_DATE = TIME.date;

    int TES_hour = 4; // 1 = every 1 hour, 4 = every 15 minutes

    WIN3D.graphics.pushMatrix();
    WIN3D.graphics.translate(x_SunPath, y_SunPath, z_SunPath);
    WIN3D.graphics.strokeWeight(0);
    WIN3D.graphics.stroke(0, 0, 0);
    WIN3D.graphics.fill(0, 0, 0);
    WIN3D.graphics.line(-1 * s_SunPath, 0, 0, 1 * s_SunPath, 0, 0);
    WIN3D.graphics.line(0, -1 * s_SunPath, 0, 0, 1 * s_SunPath, 0);
    WIN3D.graphics.stroke(255, 255, 0);

    int[] startK_endK = get_startK_endK();
    int start_k = startK_endK[0];
    int end_k = startK_endK[1];

    int l = STUDY.impactLayerIndex;
    int J_START = STUDY.startDay;
    int J_END = STUDY.endDay;
    if (impactDisplayDay > 0) {
      J_START = impactDisplayDay - 1;
      J_END = impactDisplayDay;
    }

    ArrayList<float[]> newWin3DCacheSegments = isWin3D ? new ArrayList<float[]>() : null;

    for (int j = J_START; j < J_END; j += 1) {
      int now_j = wrapDayIndex(j * int(STUDY.dayIncrement) + TIME.beginDay);
      float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);

      int nk = FIND_SCENARIO_CLOSE_TO_DAILY_STAT(l,
        start_k, end_k, j, DATE_ANGLE,
        target_window == TypeWindow.STUDY ? STUDY.impactTypeIndex : WIN3D.impactTypeIndex);

      if (nk == -1) continue;

      int k = int(nk / STUDY.daysMergedCount);
      int j_ADD = nk % STUDY.daysMergedCount;

      for (float i = 0; i < 24; i += 1.0 / float(TES_hour)) {
        if (!STUDY.isInHourlyRange(i)) continue;

        float HOUR_ANGLE = i;
        int now_k = k + start_k;
        int now_i1 = floor(i);
        int now_i2 = (1 + now_i1) % 24;
        float i_ratio = i - now_i1;
        now_j = wrapDayIndex(j * STUDY.dayIncrement + (j_ADD - int(funcs.roundTo(0.5 * STUDY.daysMergedCount, 1))) + TIME.beginDay);

        float Pa1 = FLOAT_undefined;
        float Pa2 = FLOAT_undefined;
        int layerId = (WIN3D.impactTypeIndex == Impact_ACTIVE) ? LAYER_dirnorrad.id
                    : (WIN3D.impactTypeIndex == Impact_PASSIVE) ? LAYER_direffect.id : -1;
        if (layerId != -1) {
          Pa1 = getValue_currentDataSource(now_i1, now_j, now_k, layerId);
          Pa2 = getValue_currentDataSource(now_i2, now_j, now_k, layerId);
        }

        if (is_undefined(Pa1) && is_undefined(Pa2)) continue; // no data for this hour

        float sun_V = 0.001 * (Pa1 * (1 - i_ratio) + Pa2 * i_ratio);
        float[] COL = paletteValueToColor(PAL_multiplier * sun_V, PAL_type, PAL_direction);
        WIN3D.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);
        WIN3D.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
        WIN3D.graphics.strokeWeight(0.01 * WIN3D.dY);

        float halfStep = 0.5 * (1.0 / float(TES_hour));
        float[] SunA = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE - halfStep);
        float[] SunB = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE + halfStep);
        if ((SunA[3] > 0) || (SunB[3] > 0)) {
          float x1 = SunA[1] * WIN3D.scale * s_SunPath;
          float y1 = SunA[2] * WIN3D.scale * s_SunPath;
          float z1 = SunA[3] * WIN3D.scale * s_SunPath;
          float x2 = SunB[1] * WIN3D.scale * s_SunPath;
          float y2 = SunB[2] * WIN3D.scale * s_SunPath;
          float z2 = SunB[3] * WIN3D.scale * s_SunPath;
          WIN3D.graphics.line(x1, -y1, z1, x2, -y2, z2);

          if (newWin3DCacheSegments != null) {
            newWin3DCacheSegments.add(new float[] {
              x1, -y1, z1, x2, -y2, z2,
              COL[1], COL[2], COL[3], COL[0],
              0.01f * WIN3D.dY
            });
          }
        }
      }
    }

    WIN3D.graphics.popMatrix();
    STUDY.dayIncrement = keep_STUDY_dayIncrement;
    STUDY.daysMergedCount = keep_STUDY_daysMergedCount;
    TIME.date = previous_DATE;
    TIME.updateDate();

    if (isWin3D) {
      this.win3DCache_pathSegments = newWin3DCacheSegments;
      this.win3DCache_pathRecordState(PAL_type, PAL_direction, PAL_multiplier);
    }
  }

  void drawPattern (int target_window, float x_SunPath, float y_SunPath, float z_SunPath, float s_SunPath) {
    if (!(this.displayPattern || (target_window == TypeWindow.STUDY))) return;

    boolean isWin3D = (target_window == TypeWindow.WIN3D);

    float[] palette = activePalette(target_window == TypeWindow.STUDY);
    int PAL_type = int(palette[0]);
    int PAL_direction = int(palette[1]);
    float PAL_multiplier = palette[2];

    if (isWin3D && this.win3DCache_patternIsValid(PAL_type, PAL_direction, PAL_multiplier)) {
      WIN3D.graphics.shape(this.win3DCache_pattern);
      return;
    }

    float keep_STUDY_dayIncrement = STUDY.dayIncrement;
    int keep_STUDY_daysMergedCount = STUDY.daysMergedCount;
    if ((currentDataSource == dataID_ensembleForecast) ||
        (currentDataSource == dataID_ensembleObservation)) {
      STUDY.dayIncrement = 1;
      STUDY.daysMergedCount = 1;
    }
    float previous_DATE = TIME.date;

    PShape newWin3DCacheGroup = isWin3D ? createShape(GROUP) : null;
    this.drawCycles(target_window, x_SunPath, y_SunPath, z_SunPath, s_SunPath, newWin3DCacheGroup);

    STUDY.dayIncrement = keep_STUDY_dayIncrement;
    STUDY.daysMergedCount = keep_STUDY_daysMergedCount;
    TIME.date = previous_DATE;
    TIME.updateDate();

    if (isWin3D) {
      this.win3DCache_pattern = newWin3DCacheGroup;
      this.win3DCache_patternRecordState(PAL_type, PAL_direction, PAL_multiplier);
    }
  }

  void writeSunPatternMaterial (int PAL_type, String filename, String texturePath) {
    println("Saving texture:", texturePath);

    int RES1 = User3D.exporterColorscaleResolution;
    int RES2 = User3D.exporterColorscaleResolution / 16;
    PImage palette_Texture = createImage(RES1, RES2, ARGB);
    palette_Texture.loadPixels();
    for (int np = 0; np < (RES1 * RES2); np++) {
      int Image_X = np % RES1;
      float val = (Image_X / (0.5 * RES1)) - 1;
      float u = 0.5 + val;
      if (WIN3D.impactTypeIndex == Impact_ACTIVE) u = 0.5 + 0.5 * val;
      float[] COL = PAINT.getColorStyle(PAL_type, u);
      palette_Texture.pixels[np] = color(COL[1], COL[2], COL[3], COL[0]);
    }
    palette_Texture.updatePixels();
    palette_Texture.save(texturePath);

    String matName = filename.replace('.', '_');
    mtlOutput.println("newmtl " + matName);
    mtlOutput.println("\tilum 2");                   // 0:Color+Ambient off, 1:Color+Ambient on, 2:Highlight on, etc.
    mtlOutput.println("\tKa 1.000 1.000 1.000");      // ambient
    mtlOutput.println("\tKd 1.000 1.000 1.000");      // diffuse
    mtlOutput.println("\tKs 0.000 0.000 0.000");      // specular
    mtlOutput.println("\tNs 10.00");                  // 0-1000 specular exponent
    mtlOutput.println("\tNi 1.500");                  // 0.001-10 (glass:1.5) index of refraction
    mtlOutput.println("\td 1.000");                   // 0-1 transparency (d = 1 - Tr)
    mtlOutput.println("\tTr 1.000");                  // 0-1 transparency
    mtlOutput.println("\tTf 1.000 1.000 1.000");      // transmission filter
    mtlOutput.println("\tmap_Kd " + Subfolder_exportMaps + filename); // diffuse map
  }

  void writeSunPatternObjFace () {
    String n1 = nf(obj_lastVertexNumber + num_vertices_added - 3, 0);
    String n2 = nf(obj_lastVertexNumber + num_vertices_added - 2, 0);
    String n3 = nf(obj_lastVertexNumber + num_vertices_added - 1, 0);
    String n4 = nf(obj_lastVertexNumber + num_vertices_added - 0, 0);
    String m1 = nf(obj_lastVtextureNumber + num_vertices_added - 3, 0);
    String m2 = nf(obj_lastVtextureNumber + num_vertices_added - 2, 0);
    String m3 = nf(obj_lastVtextureNumber + num_vertices_added - 1, 0);
    String m4 = nf(obj_lastVtextureNumber + num_vertices_added - 0, 0);
    obj_lastFaceNumber += 1;
    objOutput.println("f " + n1 + "/" + m1 + " " + n2 + "/" + m2 + " " + n3 + "/" + m3 + " " + n4 + "/" + m4);
  }

  void drawCycles (int target_window, float x_Plot, float y_Plot, float z_Plot, float s_Plot) {
    this.drawCycles(target_window, x_Plot, y_Plot, z_Plot, s_Plot, null);
  }

  // win3DCacheGroup is non-null only when drawPattern() is rebuilding the
  // WIN3D cache: the quad-emission block below then also records each
  // quad it draws into a PShape child added to that group, alongside the
  // unchanged live WIN3D.graphics.* calls - same dual live+cache pattern
  // as Earth3D.pde's sphere. Every other caller (export_objects_OBJ.pde's
  // direct STUDY-target call, and drawPattern() itself for STUDY/OBJ3D)
  // passes null here and this behaves exactly as before.
  void drawCycles (int target_window, float x_Plot, float y_Plot, float z_Plot, float s_Plot, PShape win3DCacheGroup) {
    int TES_hour = 1; // 1 = every 1 hour, 4 = every 15 minutes
    float STUDY_dayIncrement = STUDY.dayIncrement;
    if (STUDY_dayIncrement <= STUDY.daysMergedCount) STUDY_dayIncrement = STUDY.daysMergedCount + 0.5;

    int[] startK_endK = get_startK_endK();
    int start_k = startK_endK[0];
    int end_k = startK_endK[1];

    int keep_impactTypeIndex = WIN3D.impactTypeIndex;
    if (target_window == TypeWindow.STUDY) {
      WIN3D.impactTypeIndex = (STUDY.impactGraphIndex % 2 == 0) ? Impact_ACTIVE : Impact_PASSIVE;
    }

    float[] palette = activePalette(target_window == TypeWindow.STUDY);
    int PAL_type = int(palette[0]);
    int PAL_direction = int(palette[1]);
    float PAL_multiplier = palette[2];


    String the_filename = "";
    if (target_window == TypeWindow.OBJ3D) {
      num_vertices_added = 0;
      if (User3D.exporterMaterialLibrary) {
        the_filename = "sunPatternPalette.bmp";
        String texturePath = Folder_Export3D + "/" + Subfolder_exportMaps + the_filename;
        writeSunPatternMaterial(PAL_type, the_filename, texturePath);
      }
    }

    num_vertices_added = 0;
    int end_turn = (target_window == TypeWindow.OBJ3D) ? 3 : 1;

    for (int _turn = 1; _turn <= end_turn; _turn++) {
      if ((target_window == TypeWindow.OBJ3D) && (_turn == 3)) {
        obj_lastGroupNumber += 1;
        objOutput.println("g sunPattern");
        if (User3D.exporterMaterialLibrary) {
          objOutput.println("usemtl " + the_filename.replace('.', '_'));
        }
      }

      for (int j = STUDY.startDay; j < STUDY.endDay; j++) {
        float[][][] SunPathMesh = new float[24 * TES_hour][1 + int(STUDY_dayIncrement / STUDY.daysMergedCount)][3];

        for (int more_J = 0; more_J < STUDY_dayIncrement; more_J += STUDY.daysMergedCount) {
          int now_j = wrapDayIndex(more_J + j * int(STUDY_dayIncrement) + TIME.beginDay);
          float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);
          float sunrise_origin = funcs.Sunrise(STATION.getLatitude(), DATE_ANGLE) + funcs.EquationOfTime(DATE_ANGLE);
          float sunset_origin = funcs.Sunset(STATION.getLatitude(), DATE_ANGLE) + funcs.EquationOfTime(DATE_ANGLE);

          int l = STUDY.impactLayerIndex;

          int keep_filter_type = STUDY.temporalFilterSetting;
          STUDY.temporalFilterSetting = filter_HOURLY;
          int nk = FIND_SCENARIO_CLOSE_TO_DAILY_STAT(l,
            start_k, end_k, more_J + j, DATE_ANGLE,
            target_window == TypeWindow.STUDY ? STUDY.impactTypeIndex : WIN3D.impactTypeIndex);
          STUDY.temporalFilterSetting = keep_filter_type;

          int row_J = more_J / STUDY.daysMergedCount;

          if (nk != -1) {
            int k = int(nk / STUDY.daysMergedCount);
            int j_ADD = nk % STUDY.daysMergedCount;

            float valuesSUM_RAD = 0;
            float valuesSUM_EFF = 0;

            for (float i = 0; i < 24; i += 1.0 / float(TES_hour)) {
              float HOUR_ANGLE = i;
              float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);
              float Alpha = 90 - funcs.acos_ang(SunR[3]);
              float Beta = 180 - funcs.atan2_ang(SunR[1], SunR[2]);

              // extend the graph to the horizon when the sun is below it
              if (Alpha < 0) {
                float[] SunR_temp = (i < 12)
                  ? funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, sunrise_origin)
                  : funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, sunset_origin);
                Alpha = 0;
                Beta = 180 - funcs.atan2_ang(SunR_temp[1], SunR_temp[2]);
              }

              int now_k = k + start_k;
              int now_i1 = floor(i);
              int now_i2 = (1 + now_i1) % 24;
              float i_ratio = i - now_i1;
              int now_j2 = wrapDayIndex(more_J + j * STUDY_dayIncrement + (j_ADD - int(funcs.roundTo(0.5 * STUDY.daysMergedCount, 1))) + TIME.beginDay);

              float Pa1 = getValue_currentDataSource(now_i1, now_j2, now_k, LAYER_dirnorrad.id);
              float Pb1 = getValue_currentDataSource(now_i1, now_j2, now_k, LAYER_difhorrad.id);
              float Pc1 = getValue_currentDataSource(now_i1, now_j2, now_k, LAYER_direffect.id);
              float Pd1 = getValue_currentDataSource(now_i1, now_j2, now_k, LAYER_difeffect.id);
              float Pa2 = getValue_currentDataSource(now_i2, now_j2, now_k, LAYER_dirnorrad.id);
              float Pb2 = getValue_currentDataSource(now_i2, now_j2, now_k, LAYER_difhorrad.id);
              float Pc2 = getValue_currentDataSource(now_i2, now_j2, now_k, LAYER_direffect.id);
              float Pd2 = getValue_currentDataSource(now_i2, now_j2, now_k, LAYER_difeffect.id);

              boolean anyUndefined = is_undefined(Pa1) || is_undefined(Pb1) || is_undefined(Pc1) || is_undefined(Pd1)
                                   || is_undefined(Pa2) || is_undefined(Pb2) || is_undefined(Pc2) || is_undefined(Pd2);
              if (!anyUndefined) {
                boolean isMemberCounted = filter(currentDataSource, LAYER_cloudcover.id, STUDY.temporalFilterSetting, STUDY.skyScenarioSetting, now_i1, now_j2, now_k);
                if (isMemberCounted) {
                  valuesSUM_RAD = 0.001 * (Pa1 * (1 - i_ratio) + Pa2 * i_ratio);
                  valuesSUM_EFF = 0.001 * (Pc1 * (1 - i_ratio) + Pc2 * i_ratio);
                }
              }

              float valuesSUM = FLOAT_undefined;
              if (WIN3D.impactTypeIndex == Impact_ACTIVE) valuesSUM = valuesSUM_RAD;
              if (WIN3D.impactTypeIndex == Impact_PASSIVE) valuesSUM = valuesSUM_EFF;

              SunPathMesh[floor(i * TES_hour)][row_J][0] = Alpha;
              SunPathMesh[floor(i * TES_hour)][row_J][1] = Beta;
              SunPathMesh[floor(i * TES_hour)][row_J][2] = valuesSUM;
            }
          } else {
            for (float i = 0; i < 24; i += 1.0 / float(TES_hour)) {
              float HOUR_ANGLE = i;
              float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);
              float Alpha = 90 - funcs.acos_ang(SunR[3]);
              float Beta = 180 - funcs.atan2_ang(SunR[1], SunR[2]);
              SunPathMesh[floor(i * TES_hour)][row_J][0] = Alpha;
              SunPathMesh[floor(i * TES_hour)][row_J][1] = Beta;
              SunPathMesh[floor(i * TES_hour)][row_J][2] = FLOAT_undefined;
            }
          }
        }

        for (int more_J = 0; more_J < STUDY_dayIncrement - STUDY.daysMergedCount; more_J += STUDY.daysMergedCount) { // count one less!
          int now_j = wrapDayIndex(more_J + j * int(STUDY_dayIncrement) + TIME.beginDay);
          float DATE_ANGLE = (360 * ((286 + now_j) % 365) / 365.0);
          float sunrise = funcs.Sunrise(STATION.getLatitude(), DATE_ANGLE);
          float sunset = funcs.Sunset(STATION.getLatitude(), DATE_ANGLE);

          for (float i = 0; i < 24; i += 1.0 / float(TES_hour)) {
            if (!STUDY.isInHourlyRange(i)) continue;
            if (!((i > sunrise - 1.0 / float(TES_hour)) && (i < sunset + 1.0 / float(TES_hour)))) continue;

            PShape patternChild = null;

            if (target_window == TypeWindow.WIN3D) {
              WIN3D.graphics.beginShape();
              WIN3D.graphics.noStroke();
              if (win3DCacheGroup != null) {
                patternChild = createShape();
                patternChild.beginShape();
                patternChild.noStroke();
              }
            } else if (target_window == TypeWindow.WORLD) {
              WORLD.graphics.beginShape();
              WORLD.graphics.noStroke();
            } else if (target_window == TypeWindow.STUDY) {
              STUDY.graphics.beginShape();
              STUDY.graphics.noStroke();
            }

            for (int s = 0; s < 4; s++) {
              int a = int(i * TES_hour);
              int b = more_J / STUDY.daysMergedCount;
              if ((s == 1) || (s == 2)) a += 1;
              if ((s == 2) || (s == 3)) b += 1;
              if (a > (24 * TES_hour - 1)) a = a % (24 * TES_hour);

              float Alpha = SunPathMesh[a][b][0];
              float Beta = SunPathMesh[a][b][1];
              float valuesSUM = SunPathMesh[a][b][2];

              if ((Alpha < 0) || !is_defined(valuesSUM)) continue;

              float _u = 0;
              if (WIN3D.impactTypeIndex == Impact_ACTIVE) _u = (PAL_multiplier * valuesSUM);
              if (WIN3D.impactTypeIndex == Impact_PASSIVE) _u = 0.5 + 0.5 * (PAL_multiplier * valuesSUM);
              _u = applyPalDirection(_u, PAL_direction);
              float[] COL = PAINT.getColorStyle(PAL_type, _u);

              if (target_window == TypeWindow.OBJ3D) {
                float x = funcs.cos_ang(Alpha) * (funcs.cos_ang(Beta - 90)) * WIN3D.scale * s_Plot + x_Plot;
                float y = funcs.cos_ang(Alpha) * (funcs.sin_ang(Beta - 90)) * WIN3D.scale * s_Plot + y_Plot;
                float z = funcs.sin_ang(Alpha) * WIN3D.scale * s_Plot + z_Plot;

                if (_turn == 1) {
                  OBJprintVertex(x, y, z);
                } else if (_turn == 2) {
                  float u1 = 0.5 * (_u + 0.5);
                  boolean solarShade = (WIN3D.shadingMode == SHADE.Global_Solar) || (WIN3D.shadingMode == SHADE.Vertex_Solar);
                  if (solarShade && (WIN3D.impactTypeIndex == Impact_ACTIVE)) u1 = _u;
                  u1 = constrain(u1, 0.001, 0.999);
                  OBJprintVtexture(u1, 0.5, 0);
                } else { // _turn == 3
                  num_vertices_added += 1;
                }
              } else if (target_window == TypeWindow.WIN3D) {
                WIN3D.graphics.fill(COL[1], COL[2], COL[3], 127);
                float x = funcs.cos_ang(Alpha) * (funcs.cos_ang(Beta - 90)) * WIN3D.scale * s_Plot + x_Plot;
                float y = funcs.cos_ang(Alpha) * (funcs.sin_ang(Beta - 90)) * WIN3D.scale * s_Plot + y_Plot;
                float z = funcs.sin_ang(Alpha) * WIN3D.scale * s_Plot + z_Plot;
                WIN3D.graphics.vertex(x, -y, z);
                if (patternChild != null) {
                  patternChild.fill(COL[1], COL[2], COL[3], 127);
                  patternChild.vertex(x, -y, z);
                }
              } else if (target_window == TypeWindow.WORLD) {
                // not yet implemented for the WORLD window
              } else if (target_window == TypeWindow.STUDY) {
                STUDY.graphics.fill(COL[1], COL[2], COL[3], COL[0]);
                float x = (90 - Alpha) * (funcs.cos_ang(Beta - 90)) * (STUDY.centralGraphScale / 200) * s_Plot + x_Plot * (STUDY.centralGraphScale / 200);
                float y = (90 - Alpha) * (funcs.sin_ang(Beta - 90)) * (STUDY.centralGraphScale / 200) * s_Plot + y_Plot * (STUDY.centralGraphScale / 200);
                float ox = (j + (STUDY.centralGraphOffsetX + 0.5)) * s_Plot;
                STUDY.graphics.vertex(ox + x, -y);
              }
            }

            if (target_window == TypeWindow.OBJ3D) {
              if (_turn == 3) writeSunPatternObjFace();
            } else if (target_window == TypeWindow.WIN3D) {
              WIN3D.graphics.endShape(CLOSE);
              if (patternChild != null) {
                patternChild.endShape(CLOSE);
                win3DCacheGroup.addChild(patternChild);
              }
            } else if (target_window == TypeWindow.WORLD) {
              WORLD.graphics.endShape(CLOSE);
            } else if (target_window == TypeWindow.STUDY) {
              STUDY.graphics.endShape(CLOSE);
            }
          }
        }
      }

      if (target_window == TypeWindow.OBJ3D) {
        obj_lastVertexNumber += num_vertices_added;
        obj_lastVtextureNumber += num_vertices_added;
      }
    }

    WIN3D.impactTypeIndex = keep_impactTypeIndex;
  }


  public void to_XML (XML xml) {    XML parent = xml.addChild(this.CLASS_STAMP);
    XML_setInt(parent, "activeColorscaleIndex", this.activeColorscaleIndex);
    XML_setInt(parent, "activeColorscaleDirection", this.activeColorscaleDirection);
    XML_setFloat(parent, "activeColorscaleFactor", this.activeColorscaleFactor);
    XML_setInt(parent, "passiveColorscaleIndex", this.passiveColorscaleIndex);
    XML_setInt(parent, "passiveColorscaleDirection", this.passiveColorscaleDirection);
    XML_setFloat(parent, "passiveColorscaleFactor", this.passiveColorscaleFactor);
    XML_setBoolean(parent, "displayGrid", this.displayGrid);
    XML_setBoolean(parent, "displayPath", this.displayPath);
    XML_setBoolean(parent, "displayPattern", this.displayPattern);
    XML_setBoolean(parent, "displaySurface", this.displaySurface);
    XML_setBoolean(parent, "displayTexture", this.displayTexture);
    XML_setBoolean(parent, "fitInSkyDome", this.fitInSkyDome);
  }

  public void from_XML (XML xml) {    XML parent = xml.getChild(this.CLASS_STAMP);
    this.activeColorscaleIndex = XML_getInt(parent, "activeColorscaleIndex");
    this.activeColorscaleDirection = XML_getInt(parent, "activeColorscaleDirection");
    this.activeColorscaleFactor = XML_getFloat(parent, "activeColorscaleFactor");
    this.passiveColorscaleIndex = XML_getInt(parent, "passiveColorscaleIndex");
    this.passiveColorscaleDirection = XML_getInt(parent, "passiveColorscaleDirection");
    this.passiveColorscaleFactor = XML_getFloat(parent, "passiveColorscaleFactor");
    this.displayGrid = XML_getBoolean(parent, "displayGrid");
    this.displayPath = XML_getBoolean(parent, "displayPath");
    this.displayPattern = XML_getBoolean(parent, "displayPattern");
    this.displaySurface = XML_getBoolean(parent, "displaySurface");
    this.displayTexture = XML_getBoolean(parent, "displayTexture");
    this.fitInSkyDome = XML_getBoolean(parent, "fitInSkyDome");
  }
}
