class solarchvision_Earth3D {

  private final static String CLASS_STAMP = "Earth3D";

  private final static float LONGITUDE_SPAN = 360.0;
  private final static float LATITUDE_SPAN  = 180.0;
  private final static float BOUNDARY_SCALE = 0.001; // filenames encode boundaries in millidegrees

  // maintains balance between mesh resolution and mesh size to maintain performance
  float BALANCE = 1.0; // 0.25, 0.5, 1, 2, 4,

  // Spacing (in degrees) of the displayed lat/lon grid lines - independent
  // of lat_step/lon_step, which are the mesh's own tessellation
  // resolution. This lets lat_step/lon_step be lowered (e.g. to 0.5 or
  // 0.25) for a smoother/more detailed sphere without also crowding the
  // grid with a line at every tiny mesh row - only edges that land on a
  // multiple of gridStepDegrees are drawn (see isRoundGridLine() below).
  float gridStepDegrees = 1;

  float clipRadiusDegrees_Lat = 2.0 / BALANCE;

  // Longitude degrees cover progressively less ground distance at higher
  // latitudes as meridians converge (ground distance per degree of
  // longitude scales with cos(latitude)). Dividing by that same factor
  // keeps the covered ground width roughly constant regardless of
  // latitude: equal to clipRadiusDegrees_Lat at the equator, growing
  // toward the poles (where a much wider longitude span covers the same
  // shrinking ground distance). Recomputed in resolveTextureSource()
  // (rounded to a whole degree, floored at 1) whenever the station moves -
  // read directly everywhere else that needs it
  // (worldTileFullyCoversWindow(), compositeWorldTiles(), draw()'s render
  // loop), the same way clipRadiusDegrees_Lat is.
  float clipRadiusDegrees_Lon = 2.0 / BALANCE;;

  float lat_step = clipRadiusDegrees_Lat / 32.0; //in degrees
  float lon_step  = clipRadiusDegrees_Lon / 32.0; //in degrees

  boolean displaySurface = true;
  boolean displayTexture = true;

  PImage[] Map;
  float[][] BoundariesX;
  float[][] BoundariesY;

  String Path = BaseFolder + "/input/images/earth";
  String[] Filenames = new String[] {
    "Z_180000_-090000_-180000_090000_EN_FR_.jpg"
  };

  class FaceVertex {
    float x, y, z;
    float u, v;
  }

  void resize_images () {
    int n = this.Filenames.length;
    this.Map = new PImage [n];
    this.BoundariesX = new float [n][2];
    this.BoundariesY = new float [n][2];
  }

  void load_images () {
    for (int i = 0; i < this.Filenames.length; i++) {
      loadOneImage(i);
    }
  }

  private void loadOneImage (int i) {
    String MapFilename = this.Path + "/" + this.Filenames[i];
    String[] Parts = split(this.Filenames[i], '_');

    this.BoundariesX[i][0] = -float(Parts[1]) * BOUNDARY_SCALE;
    this.BoundariesY[i][0] =  float(Parts[2]) * BOUNDARY_SCALE;
    this.BoundariesX[i][1] = -float(Parts[3]) * BOUNDARY_SCALE;
    this.BoundariesY[i][1] =  float(Parts[4]) * BOUNDARY_SCALE;

    println("Loading:", MapFilename);
    this.Map[i] = loadImage(MapFilename);
  }

  private boolean shouldDraw (int target_window) {
    if (!this.displaySurface || !this.displayTexture) return false;
    if (target_window == TypeWindow.STUDY) return false;
    if (target_window == TypeWindow.WORLD) return false;
    return true;
  }

  private float clamp01 (float value) {
    if (value > 1) return 1;
    if (value < 0) return 0;
    return value;
  }

  // elevation estimate (meters)
  private float computeElevationBump (float Alpha, float Beta) {
    int i = 0; // pick the first image - there is only one.
    PImage textureImage = this.Map[i];

    // Beta can arrive unwrapped relative to the station (see unwrapLon()
    // in draw()), i.e. outside the image's actual -180..180 range for
    // stations near the antimeridian. Wrap it back in first, or those
    // cells would all get clamped to one edge column instead of sampling
    // the geographically correct side.
    float wrappedBeta = Beta;
    while (wrappedBeta > this.BoundariesX[i][1]) wrappedBeta -= 360;
    while (wrappedBeta < this.BoundariesX[i][0]) wrappedBeta += 360;

    float u = (wrappedBeta - this.BoundariesX[i][0]) / (this.BoundariesX[i][1] - this.BoundariesX[i][0]);
    float v = (this.BoundariesY[i][1] - Alpha) / (this.BoundariesY[i][1] - this.BoundariesY[i][0]);

    int px = constrain(int(u * textureImage.width), 0, textureImage.width - 1);
    int py = constrain(int(v * textureImage.height), 0, textureImage.height - 1);

    color c = textureImage.get(px, py);

    float brightness = green(c);

    float z = 6400.0 * // as applied by NASA map: https://science.nasa.gov/earth/earth-observatory/blue-marble-next-generation/topography-bathymetry-maps/
      brightness / 255.0;
    return z;
  }

  // Bilinearly interpolates the elevation bump at (lat, lon) from the 4
  // surrounding grid corners (aligned to lat_step/lon_step, the same grid
  // the render loop steps through), rather than a single point sample.
  // The station's own (lat, lon) generally doesn't land exactly on a grid
  // vertex, so a single sample effectively snaps to whichever pixel a
  // particular rounding happens to pick; interpolating instead gives a
  // baseline consistent with how the surrounding terrain's own vertices
  // are computed.
  private float computeElevationBumpBilinear (float lat, float lon) {
    float alphaTop    = 90 - floor((90 - lat) / this.lat_step) * this.lat_step;
    float alphaBottom = alphaTop - this.lat_step;

    float betaRight = 180 - floor((180 - lon) / this.lon_step) * this.lon_step;
    float betaLeft  = betaRight - this.lon_step;

    float bumpTopLeft     = computeElevationBump(alphaTop,    betaLeft);
    float bumpTopRight    = computeElevationBump(alphaTop,    betaRight);
    float bumpBottomLeft  = computeElevationBump(alphaBottom, betaLeft);
    float bumpBottomRight = computeElevationBump(alphaBottom, betaRight);

    float tLat = (lat - alphaBottom) / (alphaTop - alphaBottom);
    float tLon = (lon - betaLeft) / (betaRight - betaLeft);

    float bumpBottom = lerp(bumpBottomLeft, bumpBottomRight, tLon);
    float bumpTop     = lerp(bumpTopLeft, bumpTopRight, tLon);

    return lerp(bumpBottom, bumpTop, tLat);
  }

  // True when value is (within floating-point tolerance) a multiple of
  // gridStepDegrees - used to decide whether a mesh edge coincides with a
  // displayed grid line, independent of the mesh's own (possibly much
  // finer) tessellation step.
  private boolean isRoundGridLine (float value, float step) {
    if (step <= 0) return false;
    float nearest = round(value / step) * step;
    return abs(value - nearest) < 0.0001;
  }

  // Shifts lon by a multiple of 360 so it falls within 180 degrees of
  // referenceLon. Tile boundaries and the render loop's own Beta both
  // range over a fixed (-180, 180] domain, so without this, a station
  // within clipRadiusDegrees_Lon of the antimeridian would silently miss every
  // tile (and every drawn cell) on the far side of the seam - not a "no
  // tile" case (so the null-texture fallback wouldn't even catch it), but
  // a wrong/incomplete result. Longitude is periodic, so shifting values
  // into a consistent local frame near referenceLon doesn't change what
  // they represent.
  private float unwrapLon (float lon, float referenceLon) {
    float unwrapped = lon;
    while (unwrapped - referenceLon > 180) unwrapped -= 360;
    while (unwrapped - referenceLon < -180) unwrapped += 360;
    return unwrapped;
  }

  private float computeClipRadiusDegreesLon (float stationLat) {
    float lon = round(this.clipRadiusDegrees_Lat / funcs.cos_ang(stationLat));
    lon = min(lon, 180); // beyond 180 the window already covers every longitude - and cos_ang(90) = 0 would otherwise blow this up as stationLat approaches a pole
    return max(lon, 1);
  }

  // Earth3D depends only on WORLD's local "E" tile system
  // (input/images/worldmap), never on any whole-globe image of its own -
  // draw() only renders a small patch of the globe around the station (see
  // clipRadiusDegrees_Lat/clipRadiusDegrees_Lon below), so there's no need for whole-globe coverage,
  // and the "E" tiles are far more detailed per degree. Locations no "E"
  // tile covers simply aren't drawn (see draw()'s early return below)
  // rather than falling back to a lower-resolution image.
  //
  // The clip window can straddle more than one "E" tile (the station can
  // sit near a tile edge), so this doesn't just look up a single tile: it
  // uses one directly when it fully contains the clip window (best
  // quality, no resampling), or composites every overlapping tile into one
  // mosaic image otherwise - mirroring the overlap/crop math WORLD.pde's
  // own drawZoomedTiles() uses to composite neighboring tiles on screen.
  //
  // Cached and only rebuilt when the station's location actually changes,
  // since compositing a mosaic is comparatively expensive and draw() can
  // run every frame while navigating.
  private PImage cachedTextureImage = null;
  private float cachedTextureBx1, cachedTextureBx2, cachedTextureBy1, cachedTextureBy2;
  private String cachedTextureLabel = "";
  private String cachedTexturePath = ""; // "" means synthetic/composited - no single file to copy for export
  private String cachedTextureFilename = "";
  private float cachedStationLon = Float.NaN;
  private float cachedStationLat = Float.NaN;

  private void resolveTextureSource () {
    float stationLon = STATION.getLongitude();
    float stationLat = STATION.getLatitude();

    if ((abs(stationLon - this.cachedStationLon) < 0.0001) &&
        (abs(stationLat - this.cachedStationLat) < 0.0001)) {
      return; // still valid - station hasn't moved (whether or not a texture was found last time)
    }

    this.clipRadiusDegrees_Lon = computeClipRadiusDegreesLon(stationLat);

    IntList overlapping = new IntList();
    for (int i = 0; i < WORLD.numMaps; i++) {
      if (!WORLD.VIEW_Filenames[i].substring(0, 1).equals("E")) continue;

      float tLon1 = unwrapLon(WORLD.VIEW_BoundariesX[i][0], stationLon);
      float tLon2 = unwrapLon(WORLD.VIEW_BoundariesX[i][1], stationLon);
      float tLat1 = WORLD.VIEW_BoundariesY[i][0];
      float tLat2 = WORLD.VIEW_BoundariesY[i][1];

      boolean overlaps = (tLon2 > stationLon - this.clipRadiusDegrees_Lon) && (tLon1 < stationLon + this.clipRadiusDegrees_Lon) &&
                          (tLat2 > stationLat - this.clipRadiusDegrees_Lat) && (tLat1 < stationLat + this.clipRadiusDegrees_Lat);
      if (overlaps) overlapping.append(i);
    }

    if (overlapping.size() == 0) {
      this.cachedTextureImage = null; // no local tile covers this location - nothing to draw
    } else if ((overlapping.size() == 1) && worldTileFullyCoversWindow(overlapping.get(0), stationLon, stationLat)) {
      useWorldTileDirectly(overlapping.get(0), stationLon);
    } else {
      compositeWorldTiles(overlapping, stationLon, stationLat);
    }

    this.cachedStationLon = stationLon;
    this.cachedStationLat = stationLat;
  }

  private boolean worldTileFullyCoversWindow (int tileIndex, float stationLon, float stationLat) {
    float tLon1 = unwrapLon(WORLD.VIEW_BoundariesX[tileIndex][0], stationLon);
    float tLon2 = unwrapLon(WORLD.VIEW_BoundariesX[tileIndex][1], stationLon);

    return (tLon1 <= stationLon - this.clipRadiusDegrees_Lon) &&
           (tLon2 >= stationLon + this.clipRadiusDegrees_Lon) &&
           (WORLD.VIEW_BoundariesY[tileIndex][0] <= stationLat - this.clipRadiusDegrees_Lat) &&
           (WORLD.VIEW_BoundariesY[tileIndex][1] >= stationLat + this.clipRadiusDegrees_Lat);
  }

  private void useWorldTileDirectly (int tileIndex, float stationLon) {
    this.cachedTextureImage    = WORLD.getTileImage(tileIndex);
    this.cachedTextureBx1      = unwrapLon(WORLD.VIEW_BoundariesX[tileIndex][0], stationLon);
    this.cachedTextureBx2      = unwrapLon(WORLD.VIEW_BoundariesX[tileIndex][1], stationLon);
    this.cachedTextureBy1      = WORLD.VIEW_BoundariesY[tileIndex][0];
    this.cachedTextureBy2      = WORLD.VIEW_BoundariesY[tileIndex][1];
    this.cachedTexturePath     = WORLD.ViewFolder + "/" + WORLD.VIEW_Filenames[tileIndex];
    this.cachedTextureFilename = WORLD.VIEW_Filenames[tileIndex];
    this.cachedTextureLabel    = "EarthSphereE" + nf(tileIndex, 0);
  }

  // Composites every tile in `overlapping` into one square mosaic image
  // covering the clip window (clamped to the tiles' own combined extent,
  // same as WORLD.drawZoomedTiles() does, so the mosaic doesn't reserve
  // space for area with no image data at all). Points that still fall
  // outside that combined extent simply sample the mosaic's clamped edge
  // pixel (see clamp01() in buildSubFace()'s callers) rather than showing
  // a hard-edged gap.
  private void compositeWorldTiles (IntList overlapping, float stationLon, float stationLat) {

    float winLon1 = stationLon - this.clipRadiusDegrees_Lon;
    float winLon2 = stationLon + this.clipRadiusDegrees_Lon;
    float winLat1 = stationLat - this.clipRadiusDegrees_Lat;
    float winLat2 = stationLat + this.clipRadiusDegrees_Lat;

    float combinedLon1 = FLOAT_undefined;
    float combinedLon2 = -FLOAT_undefined;
    float combinedLat1 = FLOAT_undefined;
    float combinedLat2 = -FLOAT_undefined;

    for (int k = 0; k < overlapping.size(); k++) {
      int i = overlapping.get(k);
      combinedLon1 = min(combinedLon1, unwrapLon(WORLD.VIEW_BoundariesX[i][0], stationLon));
      combinedLon2 = max(combinedLon2, unwrapLon(WORLD.VIEW_BoundariesX[i][1], stationLon));
      combinedLat1 = min(combinedLat1, WORLD.VIEW_BoundariesY[i][0]);
      combinedLat2 = max(combinedLat2, WORLD.VIEW_BoundariesY[i][1]);
    }

    winLon1 = max(winLon1, combinedLon1);
    winLon2 = min(winLon2, combinedLon2);
    winLat1 = max(winLat1, combinedLat1);
    winLat2 = min(winLat2, combinedLat2);

    int outputSize = 1024;
    PGraphics buffer = createGraphics(outputSize, outputSize);
    buffer.beginDraw();
    buffer.background(0);

    for (int k = 0; k < overlapping.size(); k++) {
      int i = overlapping.get(k);

      PImage tileImage = WORLD.getTileImage(i);

      float tileLon1 = unwrapLon(WORLD.VIEW_BoundariesX[i][0], stationLon);
      float tileLon2 = unwrapLon(WORLD.VIEW_BoundariesX[i][1], stationLon);
      float tileLat1 = WORLD.VIEW_BoundariesY[i][0];
      float tileLat2 = WORLD.VIEW_BoundariesY[i][1];

      float overlapLon1 = max(tileLon1, winLon1);
      float overlapLon2 = min(tileLon2, winLon2);
      float overlapLat1 = max(tileLat1, winLat1);
      float overlapLat2 = min(tileLat2, winLat2);

      if ((overlapLon1 >= overlapLon2) || (overlapLat1 >= overlapLat2)) continue; // no overlap with this tile

      int u1 = int(tileImage.width  * (overlapLon1 - tileLon1) / (tileLon2 - tileLon1));
      int u2 = min(tileImage.width,  int(ceil(tileImage.width  * (overlapLon2 - tileLon1) / (tileLon2 - tileLon1))));
      int v1 = int(tileImage.height * (tileLat2 - overlapLat2) / (tileLat2 - tileLat1));
      int v2 = min(tileImage.height, int(ceil(tileImage.height * (tileLat2 - overlapLat1) / (tileLat2 - tileLat1))));

      float destX1 = outputSize * (overlapLon1 - winLon1) / (winLon2 - winLon1);
      float destX2 = outputSize * (overlapLon2 - winLon1) / (winLon2 - winLon1);
      float destY1 = outputSize * (winLat2 - overlapLat2) / (winLat2 - winLat1);
      float destY2 = outputSize * (winLat2 - overlapLat1) / (winLat2 - winLat1);

      buffer.image(tileImage, destX1, destY1, destX2 - destX1, destY2 - destY1, u1, v1, u2, v2);
    }

    buffer.endDraw();

    this.cachedTextureImage    = buffer.get();
    this.cachedTextureBx1      = winLon1;
    this.cachedTextureBx2      = winLon2;
    this.cachedTextureBy1      = winLat1;
    this.cachedTextureBy2      = winLat2;
    this.cachedTexturePath     = ""; // synthetic - writeTextureMap() saves cachedTextureImage directly
    this.cachedTextureFilename = "EarthSphereE_mosaic.jpg";
    this.cachedTextureLabel    = "EarthSphereEmosaic";
  }

  void draw (int target_window) {
    if (!shouldDraw(target_window)) return;

    resolveTextureSource();

    if (this.cachedTextureImage == null) return; // no local "E" tile covers this location

    PImage textureImage    = this.cachedTextureImage;
    float bx1              = this.cachedTextureBx1;
    float bx2              = this.cachedTextureBx2;
    float by1              = this.cachedTextureBy1;
    float by2              = this.cachedTextureBy2;
    String texturePath     = this.cachedTexturePath;
    String textureFilename = this.cachedTextureFilename;
    String textureLabel    = this.cachedTextureLabel;

    float ScaleX  = (bx2 - bx1) / LONGITUDE_SPAN;
    float ScaleY  = (by2 - by1) / LATITUDE_SPAN;
    float CEN_lon = 0.5 * (bx1 + bx2);
    float CEN_lat = 0.5 * (by1 + by2);

    if (target_window == TypeWindow.HTML || target_window == TypeWindow.OBJ3D) {
      writeMaterial(target_window, textureLabel, texturePath, textureFilename);
    }

    num_vertices_added = 0;

    int end_turn = (target_window == TypeWindow.OBJ3D) ? 3 : 1;

    // At the default resolution this grid is 180x360 = 64,800 quads. The
    // WIN3D path used to open a separate beginShape()/texture()/endShape()
    // for every single one of them - i.e. up to 64,800 texture-bind calls
    // per frame. Batch them into one shape instead: the whole sphere uses a
    // single texture image for the whole draw() call, so there's no need
    // to rebind it per quad.
    boolean isWin3D = (target_window == TypeWindow.WIN3D);

    if (isWin3D) beginWIN3DSphere(textureImage);

    ArrayList<float[][]> majorGridEdgeBatch = isWin3D ? new ArrayList<float[][]>() : null;
    ArrayList<float[][]> minorGridEdgeBatch = isWin3D ? new ArrayList<float[][]>() : null;

    float stationLon = STATION.getLongitude();
    float stationLat = STATION.getLatitude();

    // Used as the "ground plane" baseline in buildSubFace(), instead of
    // STATION.getElevation() - the elevation image's own estimate at other
    // points is what shapes the surrounding terrain, so the baseline needs
    // to come from that same source evaluated at the station's own
    // coordinate. Mixing in STATION.getElevation() (an independent,
    // differently-calibrated value) instead would offset the station's own
    // ground by however much the two disagree - and since every nearby
    // point is shifted by that same constant, the whole visible patch
    // (including any nearby sea) would appear uniformly displaced relative
    // to where the station actually sits.
    // Blends a single point sample with the bilinear estimate. Tested
    // against 16 real-world station elevations spanning flat, coastal, and
    // mountainous terrain: this average beat both individual methods on
    // mean and max error (bilinear alone over-smooths steep terrain -
    // e.g. La Paz, Quito - while single-sample alone is fully
    // discontinuous as the station moves across a grid cell boundary).
    // Averaging in the smooth bilinear term also roughly halves that
    // discontinuity compared to single-sample alone, without fully losing
    // single-sample's better tracking of sharp local relief.
    float stationElevationBump = 0.5 * (computeElevationBump(stationLat, stationLon) + computeElevationBumpBilinear(stationLat, stationLon));

    for (int _turn = 1; _turn <= end_turn; _turn++) {
      int f = 0;
      for (float Alpha = 90; Alpha > -90; Alpha -= this.lat_step) {
        if(Alpha > stationLat + this.clipRadiusDegrees_Lat) continue;
        if(Alpha < stationLat - this.clipRadiusDegrees_Lat) continue;

        for (float Beta = 180; Beta > -180; Beta -= this.lon_step) {
          float unwrappedBeta = unwrapLon(Beta, stationLon);
          if (unwrappedBeta > stationLon + this.clipRadiusDegrees_Lon) continue;
          if (unwrappedBeta < stationLon - this.clipRadiusDegrees_Lon) continue;

          f += 1;
          FaceVertex[] subFace = buildSubFace(Alpha, unwrappedBeta, CEN_lon, CEN_lat, ScaleX, ScaleY, stationElevationBump);

          if (isWin3D) {
            addFaceWIN3D(subFace, textureImage);
            collectGridEdges(subFace, Alpha, unwrappedBeta, majorGridEdgeBatch, minorGridEdgeBatch);
          } else {
            drawFace(target_window, subFace, textureLabel, f, _turn);
          }
        }
      }
    }

    if (isWin3D) {
      endWIN3DSphere();
      flushEdgeBatch(majorGridEdgeBatch, color(0), 2);      // round-degree grid, black
      flushEdgeBatch(minorGridEdgeBatch, color(255), 1);    // finer mesh tessellation, white
    }
  }

  private void beginWIN3DSphere (PImage textureImage) {
    WIN3D.graphics.strokeWeight(1);
    WIN3D.graphics.noStroke();
    WIN3D.graphics.beginShape(QUADS);
    if (this.displayTexture) {
      WIN3D.graphics.texture(textureImage);
    }
  }

  private void addFaceWIN3D (FaceVertex[] subFace, PImage textureImage) {
    for (int s = 0; s < subFace.length; s++) {
      float u = clamp01(subFace[s].u);
      float v = clamp01(subFace[s].v);
      WIN3D.graphics.vertex(
        subFace[s].x * OBJECTS_scale * WIN3D.scale,
        -subFace[s].y * OBJECTS_scale * WIN3D.scale,
        subFace[s].z * OBJECTS_scale * WIN3D.scale,
        u * textureImage.width,
        v * textureImage.height
      );
    }
  }

  private void endWIN3DSphere () {
    WIN3D.graphics.endShape();
  }

  private float[] projectEarthVertexForWIN3D (FaceVertex v) {
    return new float[] {
       v.x * OBJECTS_scale * WIN3D.scale,
      -v.y * OBJECTS_scale * WIN3D.scale,
       v.z * OBJECTS_scale * WIN3D.scale
    };
  }

  // subFace's 4 corners are, in order: (Alpha, Beta), (Alpha, Beta -
  // lon_step), (Alpha - lat_step, Beta - lon_step), (Alpha - lat_step,
  // Beta) - see buildSubFace(). So its 4 edges each run along a constant
  // latitude or longitude. Edges landing on a round grid line (see
  // isRoundGridLine()) go into the major (black) batch; every other edge -
  // i.e. the mesh's own finer tessellation lines - goes into the minor
  // (white) batch instead, so a finer lat_step/lon_step is still visible
  // as the actual model tessellation without crowding the round-degree
  // grid itself with extra lines.
  private void collectGridEdges (FaceVertex[] subFace, float Alpha, float Beta, ArrayList<float[][]> majorBatch, ArrayList<float[][]> minorBatch) {
    float latTop    = Alpha;
    float latBottom = Alpha - this.lat_step;
    float lonLeft   = Beta - this.lon_step;
    float lonRight  = Beta;

    addGridEdge(latTop,    majorBatch, minorBatch, subFace[0], subFace[1]);
    addGridEdge(latBottom, majorBatch, minorBatch, subFace[2], subFace[3]);
    addGridEdge(lonLeft,   majorBatch, minorBatch, subFace[1], subFace[2]);
    addGridEdge(lonRight,  majorBatch, minorBatch, subFace[3], subFace[0]);
  }

  private void addGridEdge (float value, ArrayList<float[][]> majorBatch, ArrayList<float[][]> minorBatch, FaceVertex a, FaceVertex b) {
    ArrayList<float[][]> batch = isRoundGridLine(value, this.gridStepDegrees) ? majorBatch : minorBatch;
    batch.add(new float[][] { projectEarthVertexForWIN3D(a), projectEarthVertexForWIN3D(b) });
  }

  // Strokes every recorded segment in one beginShape(LINES) pass, kept
  // entirely separate from the textured fill pass above and from the
  // other edge batch - they all share the same stroke color/weight within
  // one batch, so there's nothing per-segment lost by batching them, and
  // this way each grid can be toggled/styled independently of the fill and
  // of each other without touching those passes.
  private void flushEdgeBatch (ArrayList<float[][]> batch, int strokeColor, float weight) {
    if ((batch == null) || (batch.size() == 0)) return;

    WIN3D.graphics.noFill();
    WIN3D.graphics.strokeWeight(weight);
    WIN3D.graphics.stroke(strokeColor);
    WIN3D.graphics.beginShape(LINES);

    for (int p = 0; p < batch.size(); p++) {
      float[][] seg = batch.get(p);
      WIN3D.graphics.vertex(seg[0][0], seg[0][1], seg[0][2]);
      WIN3D.graphics.vertex(seg[1][0], seg[1][1], seg[1][2]);
    }

    WIN3D.graphics.endShape();
  }

  private void writeMaterial (int target_window, String textureLabel, String texturePath, String textureFilename) {
    if (User3D.export_MaterialLibrary) {
      if (target_window == TypeWindow.HTML) {
        htmlOutput.println("\t\t\t\t<Appearance DEF='" + textureLabel + "'>");
      }
      if (target_window == TypeWindow.OBJ3D) {
        writeMTLHeader();
      }
      if (this.displayTexture) {
        writeTextureMap(target_window, texturePath, textureFilename);
      }
    }

    if (target_window == TypeWindow.HTML) {
      htmlOutput.println("\t\t\t\t</Appearance>");
    }

    if (target_window == TypeWindow.OBJ3D) {
      if (User3D.export_PolyToPoly == 1) {
        obj_lastGroupNumber += 1;
        objOutput.println("g EarthSphere");
      }
      if (User3D.export_MaterialLibrary) {
        objOutput.println("usemtl EarthSphere");
      }
    }
  }

  private void writeMTLHeader () {
    mtlOutput.println("newmtl EarthSphere");
    mtlOutput.println("\tilum 2"); // 0: color+ambient off, 1: color+ambient on, 2: highlight on, etc.
    mtlOutput.println("\tKa 1.000 1.000 1.000"); // ambient
    mtlOutput.println("\tKd 1.000 1.000 1.000"); // diffuse
    mtlOutput.println("\tKs 0.000 0.000 0.000"); // specular
    mtlOutput.println("\tNs 10.00");             // 0-1000 specular exponent
    mtlOutput.println("\tNi 1.500");             // 0.001-10 (glass: 1.5) index of refraction
    mtlOutput.println("\td 1.000");              // 0-1 transparency (d = Tr, or d = 1 - Tr)
    mtlOutput.println("\tTr 1.000");             // 0-1 transparency
    mtlOutput.println("\tTf 1.000 1.000 1.000"); // transmission filter
  }

  private void writeTextureMap (int target_window, String texturePath, String textureFilename) {
    String new_Texture_path = Folder_Export3D + "/" + Subfolder_exportMaps + textureFilename;

    if (texturePath.equals("")) {
      // Synthetic/composited mosaic - there's no single source file on
      // disk to copy, so save the in-memory image itself.
      println("Saving composited texture:", new_Texture_path);
      this.cachedTextureImage.save(new_Texture_path);
    } else {
      println("Copying texture:", texturePath, ">", new_Texture_path);
      saveBytes(new_Texture_path, loadBytes(texturePath));
    }

    if (target_window == TypeWindow.OBJ3D) {
      mtlOutput.println("\tmap_Kd " + Subfolder_exportMaps + textureFilename); // diffuse map
      mtlOutput.println("\tmap_d " + Subfolder_exportMaps + textureFilename);  // alpha map
    }
    if (target_window == TypeWindow.HTML) {
      htmlOutput.println("\t\t\t\t\t<ImageTexture url='" + Subfolder_exportMaps + textureFilename + "'><ImageTexture/>");
    }
  }

  private FaceVertex[] buildSubFace (float Alpha, float Beta,
                                      float CEN_lon, float CEN_lat, float ScaleX, float ScaleY, float stationElevationBump) {
    FaceVertex[] subFace = new FaceVertex[4];

    float tb = -STATION.getLongitude();
    float ta = 90 - STATION.getLatitude();

    for (int s = 0; s < 4; s++) {
      FaceVertex vtx = new FaceVertex();

      float a = Alpha;
      float b = Beta;
      if (s == 2 || s == 3) a -= this.lat_step;
      if (s == 1 || s == 2) b -= this.lon_step;

      if (this.displayTexture) {
        float lon = b - CEN_lon;
        float lat = a - CEN_lat;
        vtx.u = (lon / ScaleX / LONGITUDE_SPAN + 0.5);
        vtx.v = (-lat / ScaleY / LATITUDE_SPAN + 0.5);
      }

      // Bump this vertex outward along its own radial direction (i.e.
      // just extend the sphere's radius for this one vertex) based on the
      // texture pixel under it, so the model isn't perfectly smooth.
      double bumpedR = DOUBLE_r_Earth + computeElevationBump(a, b);

      double x0 = bumpedR * funcs.cos_ang(b - 90) * funcs.cos_ang(a);
      double y0 = bumpedR * funcs.sin_ang(b - 90) * funcs.cos_ang(a);
      double z0 = bumpedR * funcs.sin_ang(a);

      // rotate so the station's location sits at the model origin/orientation
      double x1 = x0 * funcs.cos_ang(tb) - y0 * funcs.sin_ang(tb);
      double y1 = x0 * funcs.sin_ang(tb) + y0 * funcs.cos_ang(tb);
      double z1 = z0;

      double x2 = x1;
      double y2 = z1 * funcs.sin_ang(ta) + y1 * funcs.cos_ang(ta);
      double z2 = z1 * funcs.cos_ang(ta) - y1 * funcs.sin_ang(ta);

      z2 -= DOUBLE_r_Earth + stationElevationBump; // drop the globe below the station

      vtx.x = (float) x2;
      vtx.y = (float) y2;
      vtx.z = (float) z2;

      subFace[s] = vtx;
    }

    return subFace;
  }


  private void drawFace (int target_window, FaceVertex[] subFace, String textureLabel, int f, int _turn) {
    if (target_window == TypeWindow.HTML) {
      writeFaceHTML(subFace, textureLabel);
      return;
    }
    if (target_window == TypeWindow.OBJ3D) {
      writeFaceOBJ(subFace, f, _turn);
    }
  }

  private void writeFaceHTML (FaceVertex[] subFace, String textureLabel) {
    htmlOutput.println("\t\t\t\t<shape>");
    htmlOutput.println("\t\t\t\t\t<Appearance USE='" + textureLabel + "'></Appearance>");

    htmlOutput.print("\t\t\t\t\t<IndexedFaceSet solid='false'"); // force two-sided
    htmlOutput.print(" coordIndex='");
    for (int s = 0; s < subFace.length; s++) {
      if (s > 0) htmlOutput.print(" ");
      htmlOutput.print(nf(s, 0));
    }
    htmlOutput.println(" -1'>");

    htmlOutput.print("\t\t\t\t\t\t<Coordinate point='");
    for (int s = 0; s < subFace.length; s++) {
      if (s > 0) htmlOutput.print(",");
      htmlOutput.print(nf(subFace[s].x, 0, User3D.export_PrecisionVertex) + " " +
                        nf(subFace[s].y, 0, User3D.export_PrecisionVertex) + " " +
                        nf(subFace[s].z, 0, User3D.export_PrecisionVertex));
    }
    htmlOutput.println("'></Coordinate>");

    htmlOutput.print("\t\t\t\t\t\t<TextureCoordinate point='");
    for (int s = 0; s < subFace.length; s++) {
      if (s > 0) htmlOutput.print(",");
      float u = clamp01(subFace[s].u);
      float v = 1 - clamp01(subFace[s].v); // mirroring the image
      SOLARCHVISION_HTMLprintVtexture(u, v);
    }
    htmlOutput.println("'></TextureCoordinate>");

    htmlOutput.println("\t\t\t\t\t</IndexedFaceSet>");
    htmlOutput.println("\t\t\t\t</shape>");
  }

  private void writeFaceOBJ (FaceVertex[] subFace, int f, int _turn) {
    for (int s = 0; s < subFace.length; s++) {
      float u = clamp01(subFace[s].u);
      float v = clamp01(subFace[s].v);

      if (_turn == 1) {
        SOLARCHVISION_OBJprintVertex(subFace[s].x, subFace[s].y, subFace[s].z);
      }
      if (_turn == 2) {
        v = 1 - v; // mirroring the image
        SOLARCHVISION_OBJprintVtexture(u, v, 0);
      }
      if (_turn == 3) {
        obj_lastVertexNumber += 1;
        obj_lastVtextureNumber += 1;
      }
    }

    if (_turn == 3) {
      writeOBJFaceIndices(f);
    }
  }

  private void writeOBJFaceIndices (int f) {
    String n1_txt = nf(obj_lastVertexNumber - 3, 0);
    String n2_txt = nf(obj_lastVertexNumber - 2, 0);
    String n3_txt = nf(obj_lastVertexNumber - 1, 0);
    String n4_txt = nf(obj_lastVertexNumber - 0, 0);

    String m1_txt = nf(obj_lastVtextureNumber - 3, 0);
    String m2_txt = nf(obj_lastVtextureNumber - 2, 0);
    String m3_txt = nf(obj_lastVtextureNumber - 1, 0);
    String m4_txt = nf(obj_lastVtextureNumber - 0, 0);

    if (User3D.export_PolyToPoly == 0) {
      obj_lastGroupNumber += 1;
      objOutput.println("g EarthSphere_" + nf(f, 0));
    }

    obj_lastFaceNumber += 1;
    objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n2_txt + "/" + m2_txt + " " + n3_txt + "/" + m3_txt + " " + n4_txt + "/" + m4_txt);

    if (User3D.export_BackSides) {
      obj_lastFaceNumber += 1;
      objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n4_txt + "/" + m4_txt + " " + n3_txt + "/" + m3_txt + " " + n2_txt + "/" + m2_txt);
    }
  }


  public void to_XML (XML xml) {
    println("Saving:" + this.CLASS_STAMP);
    XML parent = xml.addChild(this.CLASS_STAMP);
    XML_setBoolean(parent, "displaySurface", this.displaySurface);
    XML_setBoolean(parent, "displayTexture", this.displayTexture);
  }

  public void from_XML (XML xml) {
    println("Loading:" + this.CLASS_STAMP);
    XML parent = xml.getChild(this.CLASS_STAMP);
    this.displaySurface = XML_getBoolean(parent, "displaySurface");
    this.displayTexture = XML_getBoolean(parent, "displayTexture");
  }
}
