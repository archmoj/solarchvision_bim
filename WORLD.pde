class solarchvision_WORLD {

  private final static String CLASS_STAMP = "WORLD";

  // scales
  float sX = 1;
  float sY = 1;
  // offsets
  float oX = 0;
  float oY = 0;

  // The lon/lat window actually shown on screen right now - set
  // alongside oX/oY/sX/sY wherever the background is drawn. For Zoom 1,
  // 2, and the "L" catch-all this equals VIEW_BoundariesX/Y[VIEW_id]; for
  // panned/tiled zoom levels (see drawZoomedTiles) it's the panned
  // window, which can differ from - and extend beyond - the home tile's
  // own boundary. isWithinView() checks against these, not VIEW_id's
  // bounds, so stations in a composited neighboring tile aren't wrongly
  // filtered out.
  float viewWindowLon1 = 0;
  float viewWindowLon2 = 0;
  float viewWindowLat1 = 0;
  float viewWindowLat2 = 0;

  // Drag-to-pan offset (degrees) applied on top of STATION's lon/lat when
  // computing the center of a Zoom > 2 window in drawZoomedTiles(). Left
  // as-is across zoom-level changes so the effective center (STATION +
  // this offset) stays put when zooming, instead of snapping back to
  // STATION. resetPan() is available for callers that do want to
  // explicitly re-center on STATION.
  float panOffsetLon = 0;
  float panOffsetLat = 0;

  void resetPan () {
    this.panOffsetLon = 0;
    this.panOffsetLat = 0;
  }

  // (top-left) corner
  int cX = 0;
  int cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 0;
  // width and height
  int dX = SOLARCHVISION_pixel_W;
  int dY = SOLARCHVISION_pixel_H;

  boolean update = true;
  boolean include = true;


  int numMaps;
  int Zoom = 8; //1:A 2:B 3:C 4:D 5:E 6:E(2x) 7:E(4x) 8:E(8x) 9:E(16x) and 0:L <<<

  boolean autoView = true;

  boolean record_IMG = false;
  boolean record_PDF = false;
  boolean record_AUTO = false;

  float ImageScale = 1.0;

  String ViewFolder;

  PImage ViewImage;

  PGraphics graphics;

  int VIEW_id = 0;



  String[][] VIEW_Name;
  float[][] VIEW_BoundariesX;
  float[][] VIEW_BoundariesY;
  int[] VIEW_displayGrid;
  String[] VIEW_Filenames;

  // Caches neighbor tiles loaded by drawZoomedTiles() (see getTileImage()
  // below) so panning doesn't re-hit disk for the same tile file on every
  // single frame - loadImage() is comparatively slow, and without this a
  // pan that keeps overlapping the same neighboring tile reloaded it from
  // disk on every redraw, which is what was causing the lag while panning.
  PImage[] VIEW_ImageCache;

  int displayAll_SWOB = 0; // 0-2
  int displayAll_NAEFS = 0; // 0-2
  int displayAll_CWEEDS = 0; // 0-2
  int displayAll_CLMREC = 0; // 0-2
  int displayAll_TMYEPW = 1; // 0-2

  boolean displayNear_SWOB = false;
  boolean displayNear_NAEFS = false;
  boolean displayNear_CWEEDS = false;
  boolean displayNear_CLMREC = false;
  boolean displayNear_TMYEPW = false;

  void listAllImages () {

    this.VIEW_Filenames = sort(OPESYS.getFiles(this.ViewFolder));

    this.numMaps = this.VIEW_Filenames.length;

    this.VIEW_Name = new String [this.numMaps][2];

    this.VIEW_BoundariesX = new float [this.numMaps][2];
    this.VIEW_BoundariesY = new float [this.numMaps][2];

    this.VIEW_displayGrid = new int [this.numMaps];
    this.VIEW_ImageCache = new PImage [this.numMaps];

    for (int i = 0; i < this.numMaps; i++) {
      String MapFilename = this.ViewFolder + "/" + this.VIEW_Filenames[i];

      String[] Parts = split(this.VIEW_Filenames[i], '_');

      this.VIEW_BoundariesX[i][0] = -float(Parts[1]) * 0.001;
      this.VIEW_BoundariesY[i][0] =  float(Parts[2]) * 0.001;
      this.VIEW_BoundariesX[i][1] = -float(Parts[3]) * 0.001;
      this.VIEW_BoundariesY[i][1] =  float(Parts[4]) * 0.001;

      this.VIEW_Name[i][0] = Parts[5];
      this.VIEW_Name[i][1] = Parts[6];

      float a = (this.VIEW_BoundariesY[i][1] - this.VIEW_BoundariesY[i][0]) / 2;
      if (a < 1) a = 1;
      this.VIEW_displayGrid[i] = int(a);
    }
  }


  int FindGoodViewport (float pointLongitude, float pointLatitude) {

    int return_VIEWPORT = this.VIEW_id;

    if (this.autoView) {
      this.resetPan();

      float d1 = FLOAT_undefined;
      float d2 = FLOAT_undefined;

      for (int i = 0; i < this.numMaps; i++) {

        boolean check_it = false;

        String started_with = this.VIEW_Filenames[i].substring(0, 1);

        if (this.Zoom == 1) {
          if (started_with.equals("A")) check_it = true;
        } else if (this.Zoom == 2) {
          if (started_with.equals("B")) check_it = true;
        } else if (this.Zoom == 3) {
          if (started_with.equals("C")) check_it = true;
        } else if (this.Zoom == 4) {
          if (started_with.equals("D")) check_it = true;
        } else if ((this.Zoom == 5) || (this.Zoom == 6) || (this.Zoom == 7) || (this.Zoom == 8) || (this.Zoom == 9)) {
          // 6, 7, 8, and 9 reuse the same "E" bitmaps as 5 - drawView()
          // crops and scales them further in rather than loading dedicated
          // images.
          if (started_with.equals("E")) check_it = true;
        } else {
          check_it = true;
        }

        if (check_it) {

          if (isInside(pointLongitude, pointLatitude, this.VIEW_BoundariesX[i][0], this.VIEW_BoundariesY[i][0], this.VIEW_BoundariesX[i][1], this.VIEW_BoundariesY[i][1])) {
            float d_Center = dist(pointLongitude, pointLatitude, 0.5 * (this.VIEW_BoundariesX[i][0] + this.VIEW_BoundariesX[i][1]), 0.5 * (this.VIEW_BoundariesY[i][0] + this.VIEW_BoundariesY[i][1]));
            float d_Size = dist(this.VIEW_BoundariesX[i][0], this.VIEW_BoundariesY[i][0], this.VIEW_BoundariesX[i][1], this.VIEW_BoundariesY[i][1]);

            if (d2 > 0.99 * d_Size) {
              if (d1 > d_Center) {
                d1 = d_Center;
                d2 = d_Size;

                return_VIEWPORT = i;
              }
            }
          }
        }
      }
    }

    if (return_VIEWPORT != this.VIEW_id) {
      this.loadImages(return_VIEWPORT);

      if (Earth3D.displaySurface) {
        SOLARCHVISION_view_changed();
      }
    }

    return (return_VIEWPORT);
  }


  void loadImages (int n) {

    println("Loading:", this.ViewFolder + "/" + this.VIEW_Filenames[n]);

    this.ViewImage = loadImage(this.ViewFolder + "/" + this.VIEW_Filenames[n]);
    this.VIEW_ImageCache[n] = this.ViewImage; // keep the cache consistent with the currently-selected tile too
  }

  // Returns tile i's image, loading it from disk (and caching it) only
  // the first time it's needed - see VIEW_ImageCache above.
  PImage getTileImage (int i) {
    if (this.VIEW_ImageCache[i] == null) {
      this.VIEW_ImageCache[i] = loadImage(this.ViewFolder + "/" + this.VIEW_Filenames[i]);
    }
    return this.VIEW_ImageCache[i];
  }


  // Projects a longitude/latitude onto the current viewport's pixel space.
  float projX (float lon) {
    return this.dX * (( 1 * (lon - this.oX) / 360.0) + 0.5) / this.sX;
  }

  float projY (float lat) {
    return this.dY * ((-1 * (lat - this.oY) / 180.0) + 0.5) / this.sY;
  }

  boolean isWithinView (float lon, float lat) {
    if (lon < this.viewWindowLon1) return false;
    if (lon > this.viewWindowLon2) return false;
    if (lat < this.viewWindowLat1) return false;
    if (lat > this.viewWindowLat2) return false;
    return true;
  }

  // Draws a lon/lat window of size `zoomFactor` × the native span of a
  // `prefix`-lettered tile (e.g. "E"), centered on STATION instead of
  // anchored to whichever single tile's fixed grid cell contains it.
  // Since the centered window can extend past that tile's own edge, this
  // composites every `prefix` tile that overlaps the window - so panning
  // past one tile's boundary reveals its neighbor instead of blank space.
  // Also sets oX/oY/sX/sY so markers/labels drawn afterward line up with
  // this same (possibly panned) window.
  void drawZoomedTiles (String prefix, float zoomFactor) {

    // Find the tile the (possibly drag-panned) center currently sits
    // inside (to size the window to that zoom level's native tile span),
    // and the combined bounds of every same-prefix tile (so the window
    // never pans past the edge of the available map data).
    int homeTile = -1;
    float combinedLon1 = FLOAT_undefined;
    float combinedLon2 = -FLOAT_undefined;
    float combinedLat1 = FLOAT_undefined;
    float combinedLat2 = -FLOAT_undefined;

    float centerLon = STATION.getLongitude();
    float centerLat = STATION.getLatitude();
    if (centerLon > 180) centerLon -= 360; // << important!

    centerLon += this.panOffsetLon;
    centerLat += this.panOffsetLat;
    if (centerLon > 180) centerLon -= 360; // wrap in case dragging pushed it past the antimeridian
    if (centerLon < -180) centerLon += 360;

    for (int i = 0; i < this.numMaps; i++) {
      if (!this.VIEW_Filenames[i].substring(0, 1).equals(prefix)) continue;

      if (this.VIEW_BoundariesX[i][0] < combinedLon1) combinedLon1 = this.VIEW_BoundariesX[i][0];
      if (this.VIEW_BoundariesX[i][1] > combinedLon2) combinedLon2 = this.VIEW_BoundariesX[i][1];
      if (this.VIEW_BoundariesY[i][0] < combinedLat1) combinedLat1 = this.VIEW_BoundariesY[i][0];
      if (this.VIEW_BoundariesY[i][1] > combinedLat2) combinedLat2 = this.VIEW_BoundariesY[i][1];

      if (isInside(centerLon, centerLat, this.VIEW_BoundariesX[i][0], this.VIEW_BoundariesY[i][0], this.VIEW_BoundariesX[i][1], this.VIEW_BoundariesY[i][1])) {
        homeTile = i;
      }
    }

    if (homeTile == -1) homeTile = this.VIEW_id; // fallback: STATION fell outside every same-prefix tile

    float nativeLonSpan = this.VIEW_BoundariesX[homeTile][1] - this.VIEW_BoundariesX[homeTile][0];
    float nativeLatSpan = this.VIEW_BoundariesY[homeTile][1] - this.VIEW_BoundariesY[homeTile][0];

    float halfLonSpan = 0.5 * zoomFactor * nativeLonSpan;
    float halfLatSpan = 0.5 * zoomFactor * nativeLatSpan;

    float viewLon1 = centerLon - halfLonSpan;
    float viewLon2 = centerLon + halfLonSpan;
    float viewLat1 = centerLat - halfLatSpan;
    float viewLat2 = centerLat + halfLatSpan;

    // Keep the window within the combined extent of every same-prefix
    // tile instead of panning past the edge of the available map data.
    if (viewLon1 < combinedLon1) { viewLon2 += combinedLon1 - viewLon1; viewLon1 = combinedLon1; }
    if (viewLon2 > combinedLon2) { viewLon1 -= viewLon2 - combinedLon2; viewLon2 = combinedLon2; }
    if (viewLat1 < combinedLat1) { viewLat2 += combinedLat1 - viewLat1; viewLat1 = combinedLat1; }
    if (viewLat2 > combinedLat2) { viewLat1 -= viewLat2 - combinedLat2; viewLat2 = combinedLat2; }

    // Set the lon/lat -> pixel mapping for this (possibly panned) window
    // before compositing, so projX/projY below place each tile's portion
    // at the correct screen position. Also record the window itself so
    // isWithinView() reflects it, not just the home tile's own bounds.
    this.oX = viewLon1 + 180;
    this.oY = viewLat2 - 90;
    this.sX = (viewLon2 - viewLon1) / 360.0;
    this.sY = (viewLat2 - viewLat1) / 180.0;

    this.viewWindowLon1 = viewLon1;
    this.viewWindowLon2 = viewLon2;
    this.viewWindowLat1 = viewLat1;
    this.viewWindowLat2 = viewLat2;

    for (int i = 0; i < this.numMaps; i++) {
      if (!this.VIEW_Filenames[i].substring(0, 1).equals(prefix)) continue;

      float tileLon1 = this.VIEW_BoundariesX[i][0];
      float tileLon2 = this.VIEW_BoundariesX[i][1];
      float tileLat1 = this.VIEW_BoundariesY[i][0];
      float tileLat2 = this.VIEW_BoundariesY[i][1];

      float overlapLon1 = max(tileLon1, viewLon1);
      float overlapLon2 = min(tileLon2, viewLon2);
      float overlapLat1 = max(tileLat1, viewLat1);
      float overlapLat2 = min(tileLat2, viewLat2);

      if ((overlapLon1 >= overlapLon2) || (overlapLat1 >= overlapLat2)) continue; // no overlap with this tile

      PImage tileImage = this.getTileImage(i);

      int u1 = int(tileImage.width * (overlapLon1 - tileLon1) / (tileLon2 - tileLon1));
      int u2 = min(tileImage.width, int(ceil(tileImage.width * (overlapLon2 - tileLon1) / (tileLon2 - tileLon1))));
      int v1 = int(tileImage.height * (tileLat2 - overlapLat2) / (tileLat2 - tileLat1));
      int v2 = min(tileImage.height, int(ceil(tileImage.height * (tileLat2 - overlapLat1) / (tileLat2 - tileLat1))));

      // u1/u2/v1/v2 must be integers (a hard constraint of this image()
      // overload). u1/v1 (the near/top-left edge) round down and u2/v2
      // (the far/bottom-right edge) round up, so the corrected window
      // below always covers *at least* the true visible area rather than
      // falling slightly short of it - rounding both edges down would
      // leave the corrected right/bottom edge short of the canvas,
      // producing a visible gap there (worse at high zoom, where the
      // window samples fewer source pixels to begin with).
      float correctedOverlapLon1 = tileLon1 + (tileLon2 - tileLon1) * u1 / float(tileImage.width);
      float correctedOverlapLon2 = tileLon1 + (tileLon2 - tileLon1) * u2 / float(tileImage.width);
      float correctedOverlapLat2 = tileLat2 - (tileLat2 - tileLat1) * v1 / float(tileImage.height);
      float correctedOverlapLat1 = tileLat2 - (tileLat2 - tileLat1) * v2 / float(tileImage.height);

      float destX1 = this.projX(correctedOverlapLon1);
      float destX2 = this.projX(correctedOverlapLon2);
      float destY1 = this.projY(correctedOverlapLat2);
      float destY2 = this.projY(correctedOverlapLat1);

      this.graphics.image(tileImage, destX1, destY1, destX2 - destX1, destY2 - destY1, u1, v1, u2, v2);
    }
  }

  void drawMarker (float x_point, float y_point, float strokeW, int r, int g, int b, int a, boolean filled, float diameter) {
    this.graphics.strokeWeight(strokeW);
    this.graphics.stroke(r, g, b, a);
    if (filled) this.graphics.fill(r, g, b, a);
    else this.graphics.noFill();

    this.graphics.rect(
      x_point - diameter / 2,
      y_point - diameter / 2,
      diameter,
      diameter
    );
  }

  void drawLabel (float x_point, float y_point, String label, float sizeMult) {
    this.graphics.strokeWeight(0);
    this.graphics.stroke(0);
    this.graphics.fill(0);
    this.graphics.textAlign(RIGHT, CENTER);
    this.graphics.textSize(sizeMult * MessageSize * this.ImageScale);
    this.graphics.text(label, x_point, y_point);
  }

  // Sets the marker style once (stroke/fill are the same for every marker
  // in a batch) and opens a single QUADS shape that addMarkerToBatch()
  // adds vertices to - drawing thousands of markers as one shape is far
  // faster than one graphics.rect() draw call per marker.
  void beginMarkerBatch (float strokeW, int r, int g, int b, int a, boolean filled) {
    this.graphics.strokeWeight(strokeW);
    this.graphics.stroke(r, g, b, a);
    if (filled) this.graphics.fill(r, g, b, a);
    else this.graphics.noFill();
    this.graphics.beginShape(QUADS);
  }

  void addMarkerToBatch (float x_point, float y_point, float diameter) {
    float half = 0.5 * diameter;
    this.graphics.vertex(x_point - half, y_point - half);
    this.graphics.vertex(x_point + half, y_point - half);
    this.graphics.vertex(x_point + half, y_point + half);
    this.graphics.vertex(x_point - half, y_point + half);
  }

  void endMarkerBatch () {
    this.graphics.endShape();
  }

  // Draws every station in `coords` that falls inside the current viewport (when displayAllLevel != 0),
  // labels it too when displayAllLevel > 1, and separately labels whichever station is nearest to STATION
  // when displayNear is true. This is the shared "draw all + highlight nearest" behavior used by the
  // NAEFS/CWEEDS/CLMREC/TMYEPW datasets, which differ only in marker style and label source (code vs city).
  // Returns the index of the nearest station within `coords`.
  int drawStationDataset (solarchvision_STATION[] coords, int displayAllLevel, boolean displayNear, float R_station,
                           float strokeW, int r, int g, int b, int a, boolean filled, float diameterMult,
                           boolean useCode, float allLabelSizeMult, float nearLabelSizeMult) {

    int nearest = -1;
    float nearestDist = FLOAT_undefined;

    boolean drawingAll = (displayAllLevel != 0);
    boolean drawingLabels = drawingAll && (displayAllLevel > 1);
    float diameter = diameterMult * R_station;

    // Every marker (and every label) drawn by this call shares the exact
    // same style, so set stroke/fill/text style once here instead of
    // redundantly on every single point, and batch all markers into one
    // shape instead of one draw call per point.
    if (drawingAll) {
      this.beginMarkerBatch(strokeW, r, g, b, a, filled);
    }

    // Labels are collected here and drawn only after endMarkerBatch()
    // below, instead of calling graphics.text() while the marker batch's
    // beginShape(QUADS) is still open - interleaving other drawing calls
    // inside an open shape isn't supported and was producing stale-looking
    // label positions (the actual bug behind "labels still lag").
    ArrayList<float[]> labelPositions = new ArrayList<float[]>();
    ArrayList<String> labelTexts = new ArrayList<String>();

    for (int f = 0; f < coords.length; f++) {

      float _lat = coords[f].getLatitude();
      float _lon = coords[f].getLongitude();
      if (_lon > 180) _lon -= 360; // << important!

      // Check the cheap lon/lat viewport bounds before paying for the
      // projection math and the pixel-space isInside check below.
      if (drawingAll && this.isWithinView(_lon, _lat)) {

        float x_point = this.projX(_lon);
        float y_point = this.projY(_lat);

        if (isInside(x_point, y_point, 0, 0, this.dX, this.dY)) {

          this.addMarkerToBatch(x_point, y_point, diameter);

          if (drawingLabels) {
            labelPositions.add(new float[]{ x_point, y_point });
            labelTexts.add(useCode ? coords[f].getCode() : coords[f].getCity());
          }
        }
      }

      // The "nearest" result is only used for the displayNear label
      // below (every caller discards drawStationDataset's return value),
      // so skip the distance calculation entirely when it won't be used.
      if (displayNear) {
        float d = funcs.lon_lat_dist(_lon, _lat, STATION.getLongitude(), STATION.getLatitude());

        if (nearestDist > d) {
          nearestDist = d;
          nearest = f;
        }
      }
    }

    if (drawingAll) {
      this.endMarkerBatch();
    }

    if (drawingLabels) {
      this.graphics.strokeWeight(0);
      this.graphics.stroke(0);
      this.graphics.fill(0);
      this.graphics.textAlign(RIGHT, CENTER);
      this.graphics.textSize(allLabelSizeMult * MessageSize * this.ImageScale);

      for (int i = 0; i < labelTexts.size(); i++) {
        float[] p = labelPositions.get(i);
        this.graphics.text(labelTexts.get(i), p[0], p[1]);
      }
    }

    if (displayNear && (nearest != -1)) {
      float _lat = coords[nearest].getLatitude();
      float _lon = coords[nearest].getLongitude();
      if (_lon > 180) _lon -= 360; // << important!

      float x_point = this.projX(_lon);
      float y_point = this.projY(_lat);

      if (isInside(x_point, y_point, 0, 0, this.dX, this.dY)) {
        this.drawLabel(x_point, y_point, useCode ? coords[nearest].getCode() : coords[nearest].getCity(), nearLabelSizeMult);
      }
    }

    return nearest;
  }


  void drawView () {

    if (this.update) {

      if (this.record_PDF) this.ImageScale = 1;
      else if (this.record_IMG) this.ImageScale = 1; //2;
      else this.ImageScale = 1;

      //////////////////////////////////
      this.dX *= this.ImageScale;
      this.dY *= this.ImageScale;
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

      this.graphics.background(0, 0, 0);

      if (this.Zoom == 3) {
        this.drawZoomedTiles("C", 1.0);
      } else if (this.Zoom == 4) {
        this.drawZoomedTiles("D", 1.0);
      } else if ((this.Zoom == 5) || (this.Zoom == 6) || (this.Zoom == 7) || (this.Zoom == 8) || (this.Zoom == 9)) {
        // 6, 7, 8, and 9 have no bitmaps of their own - they reuse the
        // same "E" images as 5, at progressively closer zoom fractions.
        float zoomFactor = 1.0;
        if (this.Zoom == 6) zoomFactor = 0.5;
        else if (this.Zoom == 7) zoomFactor = 0.25;
        else if (this.Zoom == 8) zoomFactor = 0.125;
        else if (this.Zoom == 9) zoomFactor = 0.0625;

        this.drawZoomedTiles("E", zoomFactor);
      } else {
        // Zoom 1, 2, and the "L" catch-all (0) keep showing the whole
        // selected tile unpanned, same as before.
        this.graphics.image(this.ViewImage, 0, 0, this.dX, this.dY);

        this.oX = this.VIEW_BoundariesX[this.VIEW_id][0] + 180;
        this.oY = this.VIEW_BoundariesY[this.VIEW_id][1] - 90;

        this.sX = (this.VIEW_BoundariesX[this.VIEW_id][1] - this.VIEW_BoundariesX[this.VIEW_id][0]) / 360.0;
        this.sY = (this.VIEW_BoundariesY[this.VIEW_id][1] - this.VIEW_BoundariesY[this.VIEW_id][0]) / 180.0;

        this.viewWindowLon1 = this.VIEW_BoundariesX[this.VIEW_id][0];
        this.viewWindowLon2 = this.VIEW_BoundariesX[this.VIEW_id][1];
        this.viewWindowLat1 = this.VIEW_BoundariesY[this.VIEW_id][0];
        this.viewWindowLat2 = this.VIEW_BoundariesY[this.VIEW_id][1];
      }

      // Derived from oX/oY/sX/sY (set above, however the background was
      // drawn) rather than tracked separately - kept only because
      // x_point1/y_point1/x_point2/y_point2 below were already unused
      // before this change.
      float _lon1 = this.oX - 180;
      float _lon2 = _lon1 + 360 * this.sX;
      float _lat2 = this.oY + 90;
      float _lat1 = _lat2 - 180 * this.sY;

      int x_point1 = int(this.projX(_lon1));
      int y_point1 = int(this.projY(_lat1));
      int x_point2 = int(this.projX(_lon2));
      int y_point2 = int(this.projY(_lat2));



      Tropo3D.draw(TypeWindow.WORLD);


      float R_station = 2 * this.ImageScale;
      if (this.VIEW_displayGrid[this.VIEW_id] == 1) R_station = 5;

      {
        float _lat = STATION.getLatitude();
        float _lon = STATION.getLongitude();
        if (_lon > 180) _lon -= 360; // << important!

        float x_point = this.projX(_lon);
        float y_point = this.projY(_lat);

        if (isInside(x_point, y_point, 0, 0, this.dX, this.dY)) {
          this.drawMarker(x_point, y_point, 3 * this.ImageScale, 0, 0, 127, 255, false, 5 * R_station);
        }
      }

      // Draws every SWOB station once - this doesn't depend on q, so it's
      // its own pass instead of being redrawn ENSEMBLE_OBSERVED_numNearest
      // times inside the nearest-station bookkeeping loop below.
      if (this.displayAll_SWOB != 0) {

        this.beginMarkerBatch(0, 191, 0, 0, 191, true);

        boolean drawingSwobLabels = this.displayAll_SWOB > 1;

        // Collected here and drawn only after endMarkerBatch() below -
        // see the matching note in drawStationDataset() for why calling
        // graphics.text() while the marker batch's beginShape(QUADS) is
        // still open isn't safe.
        ArrayList<float[]> labelPositions = new ArrayList<float[]>();
        ArrayList<String> labelTexts = new ArrayList<String>();

        for (int f = 0; f < SWOB_Coordinates.length; f++) {

          float _lat = SWOB_Coordinates[f].getLatitude();
          float _lon = SWOB_Coordinates[f].getLongitude();
          if (_lon > 180) _lon -= 360; // << important!

          if (this.isWithinView(_lon, _lat)) {

            float x_point = this.projX(_lon);
            float y_point = this.projY(_lat);

            if (isInside(x_point, y_point, 0, 0, this.dX, this.dY)) {

              this.addMarkerToBatch(x_point, y_point, R_station);

              if (drawingSwobLabels) {
                labelPositions.add(new float[]{ x_point, y_point });
                labelTexts.add(SWOB_Coordinates[f].getCode());
              }
            }
          }
        }

        this.endMarkerBatch();

        if (drawingSwobLabels) {
          this.graphics.strokeWeight(0);
          this.graphics.stroke(0);
          this.graphics.fill(0);
          this.graphics.textAlign(RIGHT, CENTER);
          this.graphics.textSize(1.0 * MessageSize * this.ImageScale);

          for (int i = 0; i < labelTexts.size(); i++) {
            float[] p = labelPositions.get(i);
            this.graphics.text(labelTexts.get(i), p[0], p[1]);
          }
        }
      }

      java.util.Arrays.fill(nearest_Station_ENSEMBLE_OBSERVED_id, -1);
      java.util.Arrays.fill(nearest_Station_ENSEMBLE_OBSERVED_dist, FLOAT_undefined);

      for (int q = 0; q < ENSEMBLE_OBSERVED_numNearest; q++) {
        for (int f = 0; f < SWOB_Coordinates.length; f++) {

          float _lat = SWOB_Coordinates[f].getLatitude();
          float _lon = SWOB_Coordinates[f].getLongitude();
          if (_lon > 180) _lon -= 360; // << important!

          float d = funcs.lon_lat_dist(_lon, _lat, STATION.getLongitude(), STATION.getLatitude());

          if (nearest_Station_ENSEMBLE_OBSERVED_dist[q] > d) {

            int added_before = 0;

            for (int p = 0; p < q; p++) {
              if (nearest_Station_ENSEMBLE_OBSERVED_id[p] == f) added_before = 1;
            }

            if (added_before == 0) {
              nearest_Station_ENSEMBLE_OBSERVED_dist[q] = d;
              nearest_Station_ENSEMBLE_OBSERVED_id[q] = f;
            }
          }

        }

        if (this.displayNear_SWOB) {
          int f = nearest_Station_ENSEMBLE_OBSERVED_id[q];

          float _lat = SWOB_Coordinates[f].getLatitude();
          float _lon = SWOB_Coordinates[f].getLongitude();
          if (_lon > 180) _lon -= 360; // << important!

          float x_point = this.projX(_lon);
          float y_point = this.projY(_lat);

          if (isInside(x_point, y_point, 0, 0, this.dX, this.dY)) {
            this.drawLabel(x_point, y_point, SWOB_Coordinates[f].getCode(), 1.0);
          }
          //println(SWOB_Coordinates[f].getCode());
        }

      }



      this.drawStationDataset(NAEFS_Coordinates, this.displayAll_NAEFS, this.displayNear_NAEFS, R_station,
                               0, 0, 63, 0, 127, true, 5, false, 1.0, 1.0);


      this.drawStationDataset(CWEEDS_coordinates, this.displayAll_CWEEDS, this.displayNear_CWEEDS, R_station,
                               2 * this.ImageScale, 0, 0, 0, 191, false, 3, false, 1.0, 1.0);


      // Note: CLMREC's "show all" labels render at half the usual text size (0.5 mult below),
      // while its "show nearest" label uses the normal size — preserved as-is from the original.
      this.drawStationDataset(CLMREC_Coordinates, this.displayAll_CLMREC, this.displayNear_CLMREC, R_station,
                               1 * this.ImageScale, 0, 0, 0, 191, false, 0.5, false, 0.5, 1.0);

      this.drawStationDataset(TMYEPW_Coordinates, this.displayAll_TMYEPW, this.displayNear_TMYEPW, R_station,
                               2 * this.ImageScale, 255, 0, 0, 127, false, 3, false, 1.0, 1.0);


      this.graphics.strokeWeight(0);


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

        // Drawn directly on the main canvas (not inside this.graphics) so
        // it's redrawn/cleared in step with WORLD's own next repaint.
        SOLARCHVISION_drawPickLists();
      }


      //////////////////////////////////
      this.dX /= this.ImageScale;
      this.dY /= this.ImageScale;
      //////////////////////////////////

      if ((this.ImageScale != 1) || (this.record_PDF)) {
        this.graphics = createGraphics(this.dX, this.dY, P2D);
        this.updated();
      } else {
        this.updated();
      }


      if ((this.record_IMG) || (this.record_AUTO == false)) this.record_IMG = false;
    }
  }


  void keyPressed (KeyEvent e) {
    if(WORLD.include == false) return;

    if ((e.isAltDown() != true) && (e.isControlDown() != true)) {
      switch(key) {
      case '`' :
        this.Zoom = (this.Zoom - 1 + 10) % 10;
        this.VIEW_id = this.FindGoodViewport(LocationLON, LocationLAT);
        this.revise();
        break;

      case '~' :
        this.Zoom = (this.Zoom + 1) % 10;
        this.VIEW_id = this.FindGoodViewport(LocationLON, LocationLAT);
        this.revise();
        break;

      }
    }
  }

  public void to_XML (XML xml) {

    println("Saving:" + this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setInt(parent, "Zoom", this.Zoom);

    XML_setInt(parent, "displayAll_SWOB", this.displayAll_SWOB);
    XML_setInt(parent, "displayAll_NAEFS", this.displayAll_NAEFS);
    XML_setInt(parent, "displayAll_CWEEDS", this.displayAll_CWEEDS);
    XML_setInt(parent, "displayAll_CLMREC", this.displayAll_CLMREC);
    XML_setInt(parent, "displayAll_TMYEPW", this.displayAll_TMYEPW);

    XML_setBoolean(parent, "displayNear_SWOB", this.displayNear_SWOB);
    XML_setBoolean(parent, "displayNear_NAEFS", this.displayNear_NAEFS);
    XML_setBoolean(parent, "displayNear_CWEEDS", this.displayNear_CWEEDS);
    XML_setBoolean(parent, "displayNear_CLMREC", this.displayNear_CLMREC);
    XML_setBoolean(parent, "displayNear_TMYEPW", this.displayNear_TMYEPW);
  }


  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);

    this.Zoom = XML_getInt(parent, "Zoom");

    this.displayAll_SWOB = XML_getInt(parent, "displayAll_SWOB");
    this.displayAll_NAEFS = XML_getInt(parent, "displayAll_NAEFS");
    this.displayAll_CWEEDS = XML_getInt(parent, "displayAll_CWEEDS");
    this.displayAll_CLMREC = XML_getInt(parent, "displayAll_CLMREC");
    this.displayAll_TMYEPW = XML_getInt(parent, "displayAll_TMYEPW");

    this.displayNear_SWOB = XML_getBoolean(parent, "displayNear_SWOB");
    this.displayNear_NAEFS = XML_getBoolean(parent, "displayNear_NAEFS");
    this.displayNear_CWEEDS = XML_getBoolean(parent, "displayNear_CWEEDS");
    this.displayNear_CLMREC = XML_getBoolean(parent, "displayNear_CLMREC");
    this.displayNear_TMYEPW = XML_getBoolean(parent, "displayNear_TMYEPW");
  }

  void revise () {
    this.update = true;
  }
  void updated () {
    this.update = false;
  }

}
