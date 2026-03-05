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

      int x_point1 = int(this.dX * (( 1 * (_lon1 - this.oX) / 360.0) + 0.5) / this.sX);
      int y_point1 = int(this.dY * ((-1 * (_lat1 - this.oY) / 180.0) + 0.5) / this.sY);
      int x_point2 = int(this.dX * (( 1 * (_lon2 - this.oX) / 360.0) + 0.5) / this.sX);
      int y_point2 = int(this.dY * ((-1 * (_lat2 - this.oY) / 180.0) + 0.5) / this.sY);



      Tropo3D.draw(TypeWindow.WORLD);


      float R_station = 2 * this.ImageScale;
      if (this.VIEW_displayGrid[this.VIEW_id] == 1) R_station = 5;

      this.graphics.ellipseMode(CENTER);

      {
        float _lat = STATION.getLatitude();
        float _lon = STATION.getLongitude();
        if (_lon > 180) _lon -= 360; // << important!

        float x_point = this.dX * (( 1 * (_lon - this.oX) / 360.0) + 0.5) / this.sX;
        float y_point = this.dY * ((-1 * (_lat - this.oY) / 180.0) + 0.5) / this.sY;

        this.graphics.strokeWeight(3 * this.ImageScale);
        this.graphics.stroke(0, 0, 127, 255);
        this.graphics.noFill();

        this.graphics.ellipse(x_point, y_point, 5 * R_station, 5 * R_station);
      }

      for ( int q = 0; q < ENSEMBLE_OBSERVED_numNearest; q++) {

        nearest_Station_ENSEMBLE_OBSERVED_id[q] = -1;
        nearest_Station_ENSEMBLE_OBSERVED_dist[q] = FLOAT_undefined;

        for (int f = 0; f < SWOB_Coordinates.length; f++) {
          boolean draw_info = false;

          if (this.displayAll_SWOB != 0) draw_info = true;

          float _lat = SWOB_Coordinates[f].getLatitude();
          float _lon = SWOB_Coordinates[f].getLongitude();
          if (_lon > 180) _lon -= 360; // << important!

          if (_lon < this.VIEW_BoundariesX[this.VIEW_id][0]) draw_info = false;
          if (_lon > this.VIEW_BoundariesX[this.VIEW_id][1]) draw_info = false;
          if (_lat < this.VIEW_BoundariesY[this.VIEW_id][0]) draw_info = false;
          if (_lat > this.VIEW_BoundariesY[this.VIEW_id][1]) draw_info = false;

          if (draw_info) {

            float x_point = this.dX * (( 1 * (_lon - this.oX) / 360.0) + 0.5) / this.sX;
            float y_point = this.dY * ((-1 * (_lat - this.oY) / 180.0) + 0.5) / this.sY;

            this.graphics.strokeWeight(0);
            this.graphics.stroke(191, 0, 0, 191);
            this.graphics.fill(191, 0, 0, 191);
            this.graphics.ellipse(x_point, y_point, R_station, R_station);

            if (this.displayAll_SWOB > 1) {
              this.graphics.strokeWeight(0);
              this.graphics.stroke(0);
              this.graphics.fill(0);
              this.graphics.textAlign(RIGHT, CENTER);
              this.graphics.textSize(MessageSize * this.ImageScale);
              this.graphics.text(SWOB_Coordinates[f].getCode(), x_point, y_point);
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

          float x_point = this.dX * (( 1 * (_lon - this.oX) / 360.0) + 0.5) / this.sX;
          float y_point = this.dY * ((-1 * (_lat - this.oY) / 180.0) + 0.5) / this.sY;

          this.graphics.strokeWeight(0);
          this.graphics.stroke(0);
          this.graphics.fill(0);
          this.graphics.textAlign(RIGHT, CENTER);
          this.graphics.textSize(MessageSize * this.ImageScale);
          this.graphics.text(SWOB_Coordinates[f].getCode(), x_point, y_point);
          //println(SWOB_Coordinates[f].getCode());
        }

      }



      int nearest_WORLD_NAEFS = -1;
      float nearest_WORLD_NAEFS_dist = FLOAT_undefined;

      for (int f = 0; f < NAEFS_Coordinates.length; f++) {
        boolean draw_info = false;

        if (this.displayAll_NAEFS != 0) draw_info = true;

        float _lat = NAEFS_Coordinates[f].getLatitude();
        float _lon = NAEFS_Coordinates[f].getLongitude();
        if (_lon > 180) _lon -= 360; // << important!

        if (_lon < this.VIEW_BoundariesX[this.VIEW_id][0]) draw_info = false;
        if (_lon > this.VIEW_BoundariesX[this.VIEW_id][1]) draw_info = false;
        if (_lat < this.VIEW_BoundariesY[this.VIEW_id][0]) draw_info = false;
        if (_lat > this.VIEW_BoundariesY[this.VIEW_id][1]) draw_info = false;

        if (draw_info) {

          float x_point = this.dX * (( 1 * (_lon - this.oX) / 360.0) + 0.5) / this.sX;
          float y_point = this.dY * ((-1 * (_lat - this.oY) / 180.0) + 0.5) / this.sY;

          this.graphics.strokeWeight(0);
          this.graphics.stroke(0, 63, 0, 127);
          this.graphics.fill(0, 63, 0, 127);

          this.graphics.ellipse(x_point, y_point, 5 * R_station, 5 * R_station);

          if (this.displayAll_NAEFS > 1) {
            this.graphics.strokeWeight(0);
            this.graphics.stroke(0);
            this.graphics.fill(0);
            this.graphics.textAlign(RIGHT, CENTER);
            this.graphics.textSize(MessageSize * this.ImageScale);
            this.graphics.text(NAEFS_Coordinates[f].getCity(), x_point, y_point);
          }
        }

        float d = funcs.lon_lat_dist(_lon, _lat, STATION.getLongitude(), STATION.getLatitude());

        if (nearest_WORLD_NAEFS_dist > d) {
          nearest_WORLD_NAEFS_dist = d;
          nearest_WORLD_NAEFS = f;
        }
      }

      if (this.displayNear_NAEFS) {
        int f = nearest_WORLD_NAEFS;

        float _lat = NAEFS_Coordinates[f].getLatitude();
        float _lon = NAEFS_Coordinates[f].getLongitude();
        if (_lon > 180) _lon -= 360; // << important!

        float x_point = this.dX * (( 1 * (_lon - this.oX) / 360.0) + 0.5) / this.sX;
        float y_point = this.dY * ((-1 * (_lat - this.oY) / 180.0) + 0.5) / this.sY;

        this.graphics.strokeWeight(0);
        this.graphics.stroke(0);
        this.graphics.fill(0);
        this.graphics.textAlign(RIGHT, CENTER);
        this.graphics.textSize(MessageSize * this.ImageScale);
        this.graphics.text(NAEFS_Coordinates[f].getCity(), x_point, y_point);
        //println(NAEFS_Coordinates[f].getCity());
      }


      int nearest_WORLD_CWEEDS = -1;
      float nearest_WORLD_CWEEDS_dist = FLOAT_undefined;

      for (int f = 0; f < CWEEDS_coordinates.length; f++) {
        boolean draw_info = false;

        if (this.displayAll_CWEEDS != 0) draw_info = true;

        float _lat = CWEEDS_coordinates[f].getLatitude();
        float _lon = CWEEDS_coordinates[f].getLongitude();
        if (_lon > 180) _lon -= 360; // << important!

        if (_lon < this.VIEW_BoundariesX[this.VIEW_id][0]) draw_info = false;
        if (_lon > this.VIEW_BoundariesX[this.VIEW_id][1]) draw_info = false;
        if (_lat < this.VIEW_BoundariesY[this.VIEW_id][0]) draw_info = false;
        if (_lat > this.VIEW_BoundariesY[this.VIEW_id][1]) draw_info = false;

        if (draw_info) {

          float x_point = this.dX * (( 1 * (_lon - this.oX) / 360.0) + 0.5) / this.sX;
          float y_point = this.dY * ((-1 * (_lat - this.oY) / 180.0) + 0.5) / this.sY;

          this.graphics.strokeWeight(2 * this.ImageScale);
          this.graphics.stroke(0, 0, 0, 191);
          this.graphics.noFill();
          this.graphics.ellipse(x_point, y_point, 3 * R_station, 3 * R_station);

          if (this.displayAll_CWEEDS > 1) {
            this.graphics.strokeWeight(0);
            this.graphics.stroke(0);
            this.graphics.fill(0);
            this.graphics.textAlign(RIGHT, CENTER);
            this.graphics.textSize(MessageSize * this.ImageScale);
            this.graphics.text(CWEEDS_coordinates[f].getCity(), x_point, y_point);
          }
        }

        float d = funcs.lon_lat_dist(_lon, _lat, STATION.getLongitude(), STATION.getLatitude());

        if (nearest_WORLD_CWEEDS_dist > d) {
          nearest_WORLD_CWEEDS_dist = d;
          nearest_WORLD_CWEEDS = f;
        }
      }

      if (this.displayNear_CWEEDS) {
        int f = nearest_WORLD_CWEEDS;

        float _lat = CWEEDS_coordinates[f].getLatitude();
        float _lon = CWEEDS_coordinates[f].getLongitude();
        if (_lon > 180) _lon -= 360; // << important!

        float x_point = this.dX * (( 1 * (_lon - this.oX) / 360.0) + 0.5) / this.sX;
        float y_point = this.dY * ((-1 * (_lat - this.oY) / 180.0) + 0.5) / this.sY;

        this.graphics.strokeWeight(0);
        this.graphics.stroke(0);
        this.graphics.fill(0);
        this.graphics.textAlign(RIGHT, CENTER);
        this.graphics.textSize(MessageSize * this.ImageScale);
        this.graphics.text(CWEEDS_coordinates[f].getCity(), x_point, y_point);
        //println(CWEEDS_coordinates[f].getCity());
      }


      int nearest_WORLD_CLMREC = -1;
      float nearest_WORLD_CLMREC_dist = FLOAT_undefined;

      for (int f = 0; f < CLMREC_Coordinates.length; f++) {
        boolean draw_info = false;

        if (this.displayAll_CLMREC != 0) draw_info = true;

        float _lat = CLMREC_Coordinates[f].getLatitude();
        float _lon = CLMREC_Coordinates[f].getLongitude();
        if (_lon > 180) _lon -= 360; // << important!

        if (_lon < this.VIEW_BoundariesX[this.VIEW_id][0]) draw_info = false;
        if (_lon > this.VIEW_BoundariesX[this.VIEW_id][1]) draw_info = false;
        if (_lat < this.VIEW_BoundariesY[this.VIEW_id][0]) draw_info = false;
        if (_lat > this.VIEW_BoundariesY[this.VIEW_id][1]) draw_info = false;

        if (draw_info) {

          float x_point = this.dX * (( 1 * (_lon - this.oX) / 360.0) + 0.5) / this.sX;
          float y_point = this.dY * ((-1 * (_lat - this.oY) / 180.0) + 0.5) / this.sY;

          this.graphics.strokeWeight(1 * this.ImageScale);
          this.graphics.stroke(0, 0, 0, 191);
          this.graphics.noFill();
          this.graphics.ellipse(x_point, y_point, 0.5 * R_station, 0.5 * R_station);

          if (this.displayAll_CLMREC > 1) {
            this.graphics.strokeWeight(0);
            this.graphics.stroke(0);
            this.graphics.fill(0);
            this.graphics.textAlign(RIGHT, CENTER);
            this.graphics.textSize(0.5 * MessageSize * this.ImageScale);
            this.graphics.text(CLMREC_Coordinates[f].getCity(), x_point, y_point);
          }
        }

        float d = funcs.lon_lat_dist(_lon, _lat, STATION.getLongitude(), STATION.getLatitude());

        if (nearest_WORLD_CLMREC_dist > d) {
          nearest_WORLD_CLMREC_dist = d;
          nearest_WORLD_CLMREC = f;
        }
      }

      if (this.displayNear_CLMREC) {
        int f = nearest_WORLD_CLMREC;

        float _lat = CLMREC_Coordinates[f].getLatitude();
        float _lon = CLMREC_Coordinates[f].getLongitude();
        if (_lon > 180) _lon -= 360; // << important!

        float x_point = this.dX * (( 1 * (_lon - this.oX) / 360.0) + 0.5) / this.sX;
        float y_point = this.dY * ((-1 * (_lat - this.oY) / 180.0) + 0.5) / this.sY;

        this.graphics.strokeWeight(0);
        this.graphics.stroke(0);
        this.graphics.fill(0);
        this.graphics.textAlign(RIGHT, CENTER);
        this.graphics.textSize(MessageSize * this.ImageScale);
        this.graphics.text(CLMREC_Coordinates[f].getCity(), x_point, y_point);
        //println(CLMREC_Coordinates[f].getCity());
      }

      int nearest_WORLD_TMYEPW = -1;
      float nearest_WORLD_TMYEPW_dist = FLOAT_undefined;

      for (int f = 0; f < TMYEPW_Coordinates.length; f++) {
        boolean draw_info = false;

        if (this.displayAll_TMYEPW != 0) draw_info = true;

        float _lat = TMYEPW_Coordinates[f].getLatitude();
        float _lon = TMYEPW_Coordinates[f].getLongitude();
        if (_lon > 180) _lon -= 360; // << important!

        if (_lon < this.VIEW_BoundariesX[this.VIEW_id][0]) draw_info = false;
        if (_lon > this.VIEW_BoundariesX[this.VIEW_id][1]) draw_info = false;
        if (_lat < this.VIEW_BoundariesY[this.VIEW_id][0]) draw_info = false;
        if (_lat > this.VIEW_BoundariesY[this.VIEW_id][1]) draw_info = false;

        if (draw_info) {

          float x_point = this.dX * (( 1 * (_lon - this.oX) / 360.0) + 0.5) / this.sX;
          float y_point = this.dY * ((-1 * (_lat - this.oY) / 180.0) + 0.5) / this.sY;

          this.graphics.strokeWeight(2 * this.ImageScale);
          this.graphics.stroke(255, 0, 0, 127);
          this.graphics.noFill();
          this.graphics.ellipse(x_point, y_point, 3 * R_station, 3 * R_station);

          if (this.displayAll_TMYEPW > 1) {
            this.graphics.strokeWeight(0);
            this.graphics.stroke(0);
            this.graphics.fill(0);
            this.graphics.textAlign(RIGHT, CENTER);
            this.graphics.textSize(MessageSize * this.ImageScale);
            this.graphics.text(TMYEPW_Coordinates[f].getCity(), x_point, y_point);
          }
        }

        float d = funcs.lon_lat_dist(_lon, _lat, STATION.getLongitude(), STATION.getLatitude());

        if (nearest_WORLD_TMYEPW_dist > d) {
          nearest_WORLD_TMYEPW_dist = d;
          nearest_WORLD_TMYEPW = f;
        }
      }

      if (this.displayNear_TMYEPW) {
        int f = nearest_WORLD_TMYEPW;

        float _lat = TMYEPW_Coordinates[f].getLatitude();
        float _lon = TMYEPW_Coordinates[f].getLongitude();
        if (_lon > 180) _lon -= 360; // << important!

        float x_point = this.dX * (( 1 * (_lon - this.oX) / 360.0) + 0.5) / this.sX;
        float y_point = this.dY * ((-1 * (_lat - this.oY) / 180.0) + 0.5) / this.sY;

        this.graphics.strokeWeight(0);
        this.graphics.stroke(0);
        this.graphics.fill(0);
        this.graphics.textAlign(RIGHT, CENTER);
        this.graphics.textSize(MessageSize * this.ImageScale);
        this.graphics.text(TMYEPW_Coordinates[f].getCity(), x_point, y_point);
        //println(TMYEPW_Coordinates[f].getCity());
      }


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
