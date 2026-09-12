class solarchvision_WORLD {

  private final static String CLASS_STAMP = "WORLD";

  // scales
  float sX = 1;
  float sY = 1;
  // offsets
  float oX = 0;
  float oY = 0;
  // (top-left) corner
  int cX = 0;
  int cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 0;
  // width and height
  int dX = SOLARCHVISION_pixel_W;
  int dY = SOLARCHVISION_pixel_H;

  boolean update = true;
  boolean include = true;


  int numMaps;
  int Zoom = 6; //1:A 2:B 3:C 4:D 5:E and 6:L <<<

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
        } else if (this.Zoom == 5) {
          if (started_with.equals("E")) check_it = true;
        } else {
          check_it = true;
        }

        if (check_it) {

          if (isInside(pointLongitude, pointLatitude, this.VIEW_BoundariesX[i][0], this.VIEW_BoundariesY[i][0], this.VIEW_BoundariesX[i][1], this.VIEW_BoundariesY[i][1])) {
            float d_Center = dist(pointLongitude, pointLatitude, 0.5 * (this.VIEW_BoundariesX[i][0] + this.VIEW_BoundariesX[i][1]), 0.5 * (this.VIEW_BoundariesY[i][0] + this.VIEW_BoundariesY[i][1]));
            float d_Size = dist(this.VIEW_BoundariesX[i][0], this.VIEW_BoundariesY[i][0], this.VIEW_BoundariesX[i][1], this.VIEW_BoundariesY[i][1]);

            if (d2 > 0.95 * d_Size) {
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
  }


  // Projects a longitude/latitude onto the current viewport's pixel space.
  float projX (float lon) {
    return this.dX * (( 1 * (lon - this.oX) / 360.0) + 0.5) / this.sX;
  }

  float projY (float lat) {
    return this.dY * ((-1 * (lat - this.oY) / 180.0) + 0.5) / this.sY;
  }

  boolean isWithinView (float lon, float lat) {
    if (lon < this.VIEW_BoundariesX[this.VIEW_id][0]) return false;
    if (lon > this.VIEW_BoundariesX[this.VIEW_id][1]) return false;
    if (lat < this.VIEW_BoundariesY[this.VIEW_id][0]) return false;
    if (lat > this.VIEW_BoundariesY[this.VIEW_id][1]) return false;
    return true;
  }

  void drawMarker (float x_point, float y_point, float strokeW, int r, int g, int b, int a, boolean filled, float diameter) {
    this.graphics.strokeWeight(strokeW);
    this.graphics.stroke(r, g, b, a);
    if (filled) this.graphics.fill(r, g, b, a);
    else this.graphics.noFill();
    this.graphics.ellipse(x_point, y_point, diameter, diameter);
  }

  void drawLabel (float x_point, float y_point, String label, float sizeMult) {
    this.graphics.strokeWeight(0);
    this.graphics.stroke(0);
    this.graphics.fill(0);
    this.graphics.textAlign(RIGHT, CENTER);
    this.graphics.textSize(sizeMult * MessageSize * this.ImageScale);
    this.graphics.text(label, x_point, y_point);
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

    for (int f = 0; f < coords.length; f++) {

      float _lat = coords[f].getLatitude();
      float _lon = coords[f].getLongitude();
      if (_lon > 180) _lon -= 360; // << important!

      if ((displayAllLevel != 0) && this.isWithinView(_lon, _lat)) {

        float x_point = this.projX(_lon);
        float y_point = this.projY(_lat);

        this.drawMarker(x_point, y_point, strokeW, r, g, b, a, filled, diameterMult * R_station);

        if (displayAllLevel > 1) {
          this.drawLabel(x_point, y_point, useCode ? coords[f].getCode() : coords[f].getCity(), allLabelSizeMult);
        }
      }

      float d = funcs.lon_lat_dist(_lon, _lat, STATION.getLongitude(), STATION.getLatitude());

      if (nearestDist > d) {
        nearestDist = d;
        nearest = f;
      }
    }

    if (displayNear && (nearest != -1)) {
      float _lat = coords[nearest].getLatitude();
      float _lon = coords[nearest].getLongitude();
      if (_lon > 180) _lon -= 360; // << important!

      this.drawLabel(this.projX(_lon), this.projY(_lat), useCode ? coords[nearest].getCode() : coords[nearest].getCity(), nearLabelSizeMult);
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

      this.graphics.image(this.ViewImage, 0, 0, this.dX, this.dY);

      this.oX = this.VIEW_BoundariesX[this.VIEW_id][0] + 180;
      this.oY = this.VIEW_BoundariesY[this.VIEW_id][1] - 90;

      this.sX = (this.VIEW_BoundariesX[this.VIEW_id][1] - this.VIEW_BoundariesX[this.VIEW_id][0]) / 360.0;
      this.sY = (this.VIEW_BoundariesY[this.VIEW_id][1] - this.VIEW_BoundariesY[this.VIEW_id][0]) / 180.0;

      float _lon1 = this.VIEW_BoundariesX[this.VIEW_id][0];
      float _lon2 = this.VIEW_BoundariesX[this.VIEW_id][1];
      float _lat1 = this.VIEW_BoundariesY[this.VIEW_id][0];
      float _lat2 = this.VIEW_BoundariesY[this.VIEW_id][1];

      int x_point1 = int(this.projX(_lon1));
      int y_point1 = int(this.projY(_lat1));
      int x_point2 = int(this.projX(_lon2));
      int y_point2 = int(this.projY(_lat2));



      Tropo3D.draw(TypeWindow.WORLD);


      float R_station = 2 * this.ImageScale;
      if (this.VIEW_displayGrid[this.VIEW_id] == 1) R_station = 5;

      this.graphics.ellipseMode(CENTER);

      {
        float _lat = STATION.getLatitude();
        float _lon = STATION.getLongitude();
        if (_lon > 180) _lon -= 360; // << important!

        this.drawMarker(this.projX(_lon), this.projY(_lat), 3 * this.ImageScale, 0, 0, 127, 255, false, 5 * R_station);
      }

      for ( int q = 0; q < ENSEMBLE_OBSERVED_numNearest; q++) {

        nearest_Station_ENSEMBLE_OBSERVED_id[q] = -1;
        nearest_Station_ENSEMBLE_OBSERVED_dist[q] = FLOAT_undefined;

        for (int f = 0; f < SWOB_Coordinates.length; f++) {

          float _lat = SWOB_Coordinates[f].getLatitude();
          float _lon = SWOB_Coordinates[f].getLongitude();
          if (_lon > 180) _lon -= 360; // << important!

          if ((this.displayAll_SWOB != 0) && this.isWithinView(_lon, _lat)) {

            float x_point = this.projX(_lon);
            float y_point = this.projY(_lat);

            this.drawMarker(x_point, y_point, 0, 191, 0, 0, 191, true, R_station);

            if (this.displayAll_SWOB > 1) {
              this.drawLabel(x_point, y_point, SWOB_Coordinates[f].getCode(), 1.0);
            }
          }

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

          this.drawLabel(this.projX(_lon), this.projY(_lat), SWOB_Coordinates[f].getCode(), 1.0);
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
        this.Zoom = (this.Zoom - 1 + 6) % 6;
        this.VIEW_id = this.FindGoodViewport(LocationLON, LocationLAT);
        this.revise();
        break;

      case '~' :
        this.Zoom = (this.Zoom + 1) % 6;
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
