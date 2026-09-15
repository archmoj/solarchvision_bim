class solarchvision_Tropo3D {

  private final static String CLASS_STAMP = "Tropo3D";

  private final static float LONGITUDE_SPAN = 360.0;
  private final static float LATITUDE_SPAN  = 180.0;
  private final static float BOUNDARY_SCALE = 0.001; // filenames encode boundaries in millidegrees
  private final static float TROPOSPHERE_ALTITUDE_M = 10000;

  private final static int   TROPO_DOWNLOAD_WIDTH  = 1200; // 1800
  private final static int   TROPO_DOWNLOAD_HEIGHT = 600;  // 900
  private final static float TROPO_BOUNDARY_HALF_SPAN = 5;

  int i_Map = 0; // TODO: export it or reset it?

  boolean displaySurface = false;
  boolean displayTexture = true;

  String[] Filenames;
  PImage[] Map;
  float[][] BoundariesX;
  float[][] BoundariesY;

  class FaceVertex {
    float x, y, z;
    float u, v;
    float lat, lon;
  }

  class DateTimeUTC {
    int year, month, day, hour;
  }

  void resize_images () {
    this.Filenames  = new String[TROPO_timeSteps];
    this.Map        = new PImage[TROPO_timeSteps];
    this.BoundariesX = new float[TROPO_timeSteps][2];
    this.BoundariesY = new float[TROPO_timeSteps][2];

    for (int i = 0; i < TROPO_timeSteps; i++) {
      resetSlot(i);
    }
  }

  private void resetSlot (int i) {
    this.Filenames[i] = "";
    this.Map[i] = createImage(2, 2, RGB); // empty and small
    this.BoundariesX[i][0] = 0;
    this.BoundariesX[i][1] = 0;
    this.BoundariesY[i][0] = 0;
    this.BoundariesY[i][1] = 0;
  }

  void load_images () {
    String[] allFilenames = sort(OPESYS.getFiles(Folder_GEOMET));
    int LocationTimeZone = getLocationTimeZone();

    DateTimeUTC dt = currentUTC();

    for (int i = 0; i < TROPO_timeSteps; i++) {
      advanceHourForward(dt);
      String targetHourLabel = nf((dt.hour + LocationTimeZone) % 24, 2);
      loadSlotIfMatch(i, allFilenames, targetHourLabel);
    }

    SOLARCHVISION_view_changed();
  }

  private DateTimeUTC currentUTC () {
    int[] rightNow = getNow_inUTC();
    DateTimeUTC dt = new DateTimeUTC();
    dt.year  = rightNow[0];
    dt.month = rightNow[1];
    dt.day   = rightNow[2];
    dt.hour  = rightNow[3];
    return dt;
  }

  private void advanceHourForward (DateTimeUTC dt) {
    dt.hour += 1;
    if (dt.hour > 23) {
      dt.hour -= 24;
      dt.day += 1;
      if (dt.day > TIME.lengthOfMonths[dt.month - 1]) {
        dt.day = 1;
        dt.month += 1;
        if (dt.month > 12) {
          dt.month = 1;
          dt.year += 1;
        }
      }
    }
  }

  private void advanceHourBackward (DateTimeUTC dt) {
    dt.hour -= 1;
    if (dt.hour < 0) {
      dt.hour += 24;
      dt.day -= 1;
      if (dt.day < 0) {
        dt.month -= 1;
        if (dt.month < 0) {
          dt.month = 12;
          dt.year -= 1;
        }
        dt.day = TIME.lengthOfMonths[dt.month - 1];
      }
    }
  }

  private void loadSlotIfMatch (int i, String[] allFilenames, String targetHourLabel) {
    for (int q = 0; q < allFilenames.length; q++) {
      String[] Parts = split(allFilenames[q], '_');
      if (Parts[0].equals(targetHourLabel)) {
        this.Filenames[i] = allFilenames[q];
        this.BoundariesX[i][0] = -float(Parts[1]) * BOUNDARY_SCALE;
        this.BoundariesY[i][0] =  float(Parts[2]) * BOUNDARY_SCALE;
        this.BoundariesX[i][1] = -float(Parts[3]) * BOUNDARY_SCALE;
        this.BoundariesY[i][1] =  float(Parts[4]) * BOUNDARY_SCALE;

        println("Loading:", Folder_GEOMET + "/" + this.Filenames[i]);
        this.Map[i] = loadImage(Folder_GEOMET + "/" + this.Filenames[i]);
        return;
      }
    }
  }

  void download_images () {
    int LocationTimeZone = getLocationTimeZone();
    DateTimeUTC dt = currentUTC();

    for (int i = 0; i < TROPO_timeSteps; i++) {
      if (WMS_type == DataType.SATELLITE_GOES) {
        advanceHourBackward(dt);
      } else {
        advanceHourForward(dt);
      }

      String parameterStamp = buildParameterStamp();
      String domainStamp = buildDomainStamp();
      computeDownloadBoundaries(i);

      String link = buildRequestUrl(domainStamp, parameterStamp, dt, i);

      this.Map[i] = createImage(2, 2, RGB); // empty and small, until (if) the download succeeds

      String filename = buildLocalFilename(i, LocationTimeZone, dt);
      String target = Folder_GEOMET + "/" + filename;

      File dir = new File(target);
      if (!dir.isFile()) {
        boolean downloaded = tryDownload(target, link);
        if (downloaded) {
          if (parameterStamp.equals("_NT&STYLES=CLOUD")) {
            recolorCloudLayer(target);
          }
          if (WMS_type == DataType.SATELLITE_GOES) {
            recolorSatelliteVisibility(target);
          }
        }
      }
    }

    this.load_images();
  }

  private String buildParameterStamp () {
    if (WMS_type == DataType.SATELLITE_GOES) {
      return "";
    }
    // Other WMS layers/styles available from the GeoMet service - kept here as a
    // reference menu for quickly swapping which layer gets downloaded. Only the
    // cloud-cover layer is currently active.
    //return "_GZ&STYLES=DEFAULT"; // Geopotential height (Value range mapping)
    //return "_UU&STYLES=WINDSPEED"; // Windspeed in knots
    //return "_UU&STYLES=WINDSPEEDKMH"; // Windspeed in km/h
    //return "_UU&STYLES=WINDARROWKMH"; // Wind arrows in km/h
    //return "_UU&STYLES=WINDARROW"; // Wind arrows in knots
    //return "_TT&STYLES=TEMPERATURE"; // Air temperature
    //return "_TT&STYLES=TEMPSUMMER"; // Air temperaturesummer range
    //return "_TT&STYLES=TEMPWINTER"; // Air temperaturewinter range
    //return "_ES&STYLES=DEWPOINTDEP"; // Dew point depression
    //return "_P0&STYLES=PRESSURE"; // Surface pressure
    //return "_PN&STYLES=PRESSURE4_LINE"; // Sea level pressure contour 4mb
    //return "_PN&STYLES=PRESSURE4"; // Sea level pressure 4mb
    //return "_PN&STYLES=PRESSURESEAHIGH"; // Sea level pressure high range
    //return "_PN&STYLES=PRESSURESEALOW"; // Sea level pressure low range
    //return "_PR&STYLES=PRECIPMM"; // Precipitations in millimeters
    //return "_PR&STYLES=CAPA24"; // Precipitations in millimeters (CaPA24)
    //return "_RT&STYLES=PRECIPRTMMH"; // Rate of precipitations in millimeters per hour
    //return "_RN&STYLES=PRECIPMM"; // Precipitations in millimeters
    //return "_FR&STYLES=PRECIPMM"; // Precipitations in millimeters
    //return "_SN&STYLES=PRECIPSNOW"; // Precipitations in centimeters
    //return "_I0&STYLES=TEMPSOIL"; // Soil Temperature
    //return "_I1&STYLES=WATERCONTENT"; // Water content
    //return "_I2&STYLES=ICECONTENT"; // Soil volumetric ice content
    //return "_I3&STYLES=WATERRETAINED"; // Water retained on the vegetation
    //return "_I4&STYLES=WATERRETAINED"; // Water retained in the snow pack
    //return "_I5&STYLES=SNOWMASS"; // Snow mass
    //return "_I8&STYLES=ICETHICK"; // Sea ice thickness
    //return "_WGE&STYLES=MS2KTSGUST"; // Windgust estimate intervals in knots
    //return "_WGE&STYLES=MS2KTS"; // Windspeed estimate in knots
    //return "_WGE&STYLES=MS2KMH"; // Windspeed estimate in km/h
    //return "_WGN&STYLES=MS2KTSGUST"; // Windgust minimum intervals in knots
    //return "_WGN&STYLES=MS2KTS"; // Windspeed minimum in knots
    //return "_WGN&STYLES=MS2KMH"; // Windspeed minimum in km/h
    //return "_WGX&STYLES=MS2KTSGUST"; // Windgust maximum intervals in knots
    //return "_WGX&STYLES=MS2KTS"; // Windspeed maximum in knots
    //return "_WGX&STYLES=MS2KMH"; // Windspeed maximum in km/h
    return "_NT&STYLES=CLOUD"; // Cloud cover
  }

  private String buildDomainStamp () {
    if (WMS_type == DataType.SATELLITE_GOES)  return "east_vis_1km";
    if (WMS_type == DataType.FORECAST_HRDPS)  return "HRDPS.CONTINENTAL";
    if (WMS_type == DataType.FORECAST_RDPS)   return "RDPS.ETA";
    if (WMS_type == DataType.FORECAST_GDPS)   return "GDPS.ETA";
    return "";
  }

  private void computeDownloadBoundaries (int i) {
    this.BoundariesX[i][0] = STATION.getLongitude() - TROPO_BOUNDARY_HALF_SPAN;
    this.BoundariesX[i][1] = STATION.getLongitude() + TROPO_BOUNDARY_HALF_SPAN;
    this.BoundariesY[i][0] = STATION.getLatitude() - TROPO_BOUNDARY_HALF_SPAN * funcs.cos_ang(STATION.getLatitude());
    this.BoundariesY[i][1] = STATION.getLatitude() + TROPO_BOUNDARY_HALF_SPAN * funcs.cos_ang(STATION.getLatitude());
  }

  private String buildRequestUrl (String domainStamp, String parameterStamp, DateTimeUTC dt, int i) {
    String service = (WMS_type == DataType.SATELLITE_GOES)
      ? "https://mesonet.agron.iastate.edu/cgi-bin/wms/goes/east_vis.cgi"
      : "https://geo.weather.gc.ca/geomet";

    String link = service + "?SERVICE=WMS&REQUEST=GetMap&VERSION=1.3.0&FORMAT=image%2Fpng&TRANSPARENT=true";

    link += "&LAYERS=" + domainStamp + parameterStamp + "&WIDTH=" + nf(TROPO_DOWNLOAD_WIDTH, 0) + "&HEIGHT=" + nf(TROPO_DOWNLOAD_HEIGHT, 0);
    link += "&CRS=EPSG%3A4326&BBOX=";
    link += nf(this.BoundariesY[i][0], 0, 3) + ",";
    link += nf(this.BoundariesX[i][0], 0, 3) + ",";
    link += nf(this.BoundariesY[i][1], 0, 3) + ",";
    link += nf(this.BoundariesX[i][1], 0, 3);

    int the_hour = int(dt.hour / TROPO_deltaTime) * TROPO_deltaTime;

    String timeStamp;
    if (WMS_type == DataType.SATELLITE_GOES) {
      timeStamp = "&DATE=" + nf(dt.year, 4) + "-" + nf(dt.month, 2) + "-" + nf(dt.day, 2) + "&time=" + nf(the_hour, 2) + ":00";
    } else {
      timeStamp = nf(dt.year, 4) + "-" + nf(dt.month, 2) + "-" + nf(dt.day, 2) + "T" + nf(the_hour, 2);
    }
    link += "&TIME=" + timeStamp + ":00:00Z";

    return link;
  }

  private String buildLocalFilename (int i, int LocationTimeZone, DateTimeUTC dt) {
    String fn = nf((dt.hour + LocationTimeZone) % 24, 2) + "_";
    fn += nf(int(funcs.roundTo(-1000 * this.BoundariesX[i][0], 1)), 6) + "_";
    fn += nf(int(funcs.roundTo( 1000 * this.BoundariesY[i][0], 1)), 6) + "_";
    fn += nf(int(funcs.roundTo(-1000 * this.BoundariesX[i][1], 1)), 6) + "_";
    fn += nf(int(funcs.roundTo( 1000 * this.BoundariesY[i][1], 1)), 6) + "_";
    fn += ".png";
    return fn;
  }

  private boolean tryDownload (String target, String link) {
    println("Try downloading: " + link);
    try {
      saveBytes(target, loadBytes(link));
      return true;
    }
    catch (Exception e) {
      println("LINK NOT AVAILABLE:", link);
      return false;
    }
  }

  private void recolorCloudLayer (String target) {
    println("image processing cloud layer");
    PImage img = loadImage(target);
    img.loadPixels();

    for (int np = 0; np < (TROPO_DOWNLOAD_WIDTH * TROPO_DOWNLOAD_HEIGHT); np++) {
      int imageX = np % TROPO_DOWNLOAD_WIDTH;
      int imageY = np / TROPO_DOWNLOAD_WIDTH;
      color col = img.get(imageX, imageY);
      // alpha: col >> 24 & 0xFF; red: col >> 16 & 0xFF; green: col >> 8 & 0xFF; blue: col & 0xFF
      float colAlpha = (col >> 24 & 0xFF);
      if (colAlpha == 0) {
        img.pixels[np] = color(0, 0);
      } else {
        float colValue = (col >> 16 & 0xFF);
        img.pixels[np] = color(255 - 0.125 * colValue, colValue);
      }
    }

    img.updatePixels();
    img.save(target);
  }

  private void recolorSatelliteVisibility (String target) {
    println("image processing cloud layer");
    PImage img = loadImage(target);
    img.loadPixels();

    for (int np = 0; np < (TROPO_DOWNLOAD_WIDTH * TROPO_DOWNLOAD_HEIGHT); np++) {
      int imageX = np % TROPO_DOWNLOAD_WIDTH;
      int imageY = np / TROPO_DOWNLOAD_WIDTH;
      color col = img.get(imageX, imageY);
      float colValue = (col >> 16 & 0xFF);
      float n = 3; //3.5; //4;
      if (colValue < 255 / n) {
        img.pixels[np] = color(191, 191, 255, 255); //color(0,0);
      } else {
        img.pixels[np] = color((255 - colValue) * n / (n - 1), 255);
      }
    }

    img.updatePixels();
    img.save(target);
  }

  private boolean shouldDraw (int target_window) {
    if (!this.displaySurface || !this.displayTexture) return false;
    if (target_window == TypeWindow.STUDY) return false;
    return true;
  }

  private float clamp01 (float value) {
    if (value > 1) return 1;
    if (value < 0) return 0;
    return value;
  }

  private boolean allUVsInRange (FaceVertex[] subFace) {
    for (int s = 0; s < subFace.length; s++) {
      if (subFace[s].u < 0 || subFace[s].u > 1) return false;
      if (subFace[s].v < 0 || subFace[s].v > 1) return false;
    }
    return true;
  }

  void draw (int target_window) {
    if (!shouldDraw(target_window)) return;

    int n_Map = this.i_Map;
    if (this.Filenames[n_Map].equals("")) return; // not to display empty images

    if (target_window == TypeWindow.HTML || target_window == TypeWindow.OBJ3D) {
      writeMaterial(target_window, n_Map);
    }

    float ScaleX  = (this.BoundariesX[n_Map][1] - this.BoundariesX[n_Map][0]) / LONGITUDE_SPAN;
    float ScaleY  = (this.BoundariesY[n_Map][1] - this.BoundariesY[n_Map][0]) / LATITUDE_SPAN;
    float CEN_lon = 0.5 * (this.BoundariesX[n_Map][0] + this.BoundariesX[n_Map][1]);
    float CEN_lat = 0.5 * (this.BoundariesY[n_Map][0] + this.BoundariesY[n_Map][1]);

    float delta_Alpha = -BIOSPHERE_drawResolution;
    float delta_Beta  = -BIOSPHERE_drawResolution;
    float r = FLOAT_r_Earth + TROPOSPHERE_ALTITUDE_M;

    num_vertices_added = 0;

    int end_turn = (target_window == TypeWindow.OBJ3D) ? 3 : 1;

    for (int _turn = 1; _turn <= end_turn; _turn++) {
      int f = 0;
      for (float Alpha = 90; Alpha > -90; Alpha += delta_Alpha) {
        for (float Beta = 180; Beta > -180; Beta += delta_Beta) {
          f += 1;
          FaceVertex[] subFace = buildSubFace(Alpha, Beta, delta_Alpha, delta_Beta, r, CEN_lon, CEN_lat, ScaleX, ScaleY);
          if (!allUVsInRange(subFace)) continue; // outside this tile's texture, nothing to draw
          drawFace(target_window, subFace, n_Map, f, _turn);
        }
      }
    }
  }

  private void writeMaterial (int target_window, int n_Map) {
    if (User3D.export_MaterialLibrary) {
      if (target_window == TypeWindow.HTML) {
        htmlOutput.println("\t\t\t\t<Appearance DEF='TropoSphere" + nf(n_Map, 0) + "'>");
      }
      if (target_window == TypeWindow.OBJ3D) {
        writeMTLHeader(n_Map);
      }
      if (this.displayTexture) {
        writeTextureMap(target_window, n_Map);
      }
    }

    if (target_window == TypeWindow.HTML) {
      htmlOutput.println("\t\t\t\t</Appearance>");
    }

    if (target_window == TypeWindow.OBJ3D) {
      if (User3D.export_PolyToPoly == 1) {
        obj_lastGroupNumber += 1;
        objOutput.println("g TropoSphere" + nf(n_Map, 0));
      }
      if (User3D.export_MaterialLibrary) {
        objOutput.println("usemtl TropoSphere" + nf(n_Map, 0));
      }
    }
  }

  private void writeMTLHeader (int n_Map) {
    mtlOutput.println("newmtl TropoSphere" + nf(n_Map, 0));
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

  private void writeTextureMap (int target_window, int n_Map) {
    String old_Texture_path = Folder_GEOMET + "/" + this.Filenames[n_Map];
    String the_filename = old_Texture_path.substring(old_Texture_path.lastIndexOf("/") + 1);
    String new_Texture_path = Folder_Export3D + "/" + Subfolder_exportMaps + the_filename;

    println("Copying texture:", old_Texture_path, ">", new_Texture_path);
    saveBytes(new_Texture_path, loadBytes(old_Texture_path));

    if (target_window == TypeWindow.OBJ3D) {
      mtlOutput.println("\tmap_Kd " + Subfolder_exportMaps + the_filename); // diffuse map
      mtlOutput.println("\tmap_d " + Subfolder_exportMaps + the_filename);  // alpha map
    }
    if (target_window == TypeWindow.HTML) {
      htmlOutput.println("\t\t\t\t\t<ImageTexture url='" + Subfolder_exportMaps + the_filename + "'><ImageTexture/>");
    }
  }

  private FaceVertex[] buildSubFace (float Alpha, float Beta, float delta_Alpha, float delta_Beta,
                                      float r, float CEN_lon, float CEN_lat, float ScaleX, float ScaleY) {
    FaceVertex[] subFace = new FaceVertex[4];

    float tb = -STATION.getLongitude();
    float ta = 90 - STATION.getLatitude();

    for (int s = 0; s < 4; s++) {
      FaceVertex vtx = new FaceVertex();

      float a = Alpha;
      float b = Beta;
      if (s == 2 || s == 3) a += delta_Alpha;
      if (s == 1 || s == 2) b += delta_Beta;

      // corner position on the troposphere shell
      float x0 = r * funcs.cos_ang(b - 90) * funcs.cos_ang(a);
      float y0 = r * funcs.sin_ang(b - 90) * funcs.cos_ang(a);
      float z0 = r * funcs.sin_ang(a);

      if (this.displayTexture) {
        float lon = b - CEN_lon;
        float lat = a - CEN_lat;
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

      z2 -= FLOAT_r_Earth; // drop the shell below the station

      vtx.x = x2;
      vtx.y = y2;
      vtx.z = z2;
      vtx.lat = a; // kept for the WORLD target's lat/lon-based 2D projection
      vtx.lon = b;

      subFace[s] = vtx;
    }

    return subFace;
  }


  private void drawFace (int target_window, FaceVertex[] subFace, int n_Map, int f, int _turn) {
    if (target_window == TypeWindow.WORLD) {
      writeFaceWORLD(subFace, n_Map);
      return;
    }
    if (target_window == TypeWindow.HTML) {
      writeFaceHTML(subFace, n_Map);
      return;
    }
    if (target_window == TypeWindow.WIN3D) {
      writeFaceWIN3D(subFace, n_Map);
      return;
    }
    if (target_window == TypeWindow.OBJ3D) {
      writeFaceOBJ(subFace, f, _turn, n_Map);
    }
  }

  private void writeFaceWORLD (FaceVertex[] subFace, int n_Map) {
    WORLD.graphics.beginShape();
    WORLD.graphics.noStroke();
    if (this.displayTexture) {
      WORLD.graphics.texture(this.Map[n_Map]);
    }

    for (int s = 0; s < subFace.length; s++) {
      float lat = subFace[s].lat;
      float lon = subFace[s].lon;
      if (lon > 180) lon -= 360; // important!

      float x_point = WORLD.dX * ((1 * (lon - WORLD.oX) / 360.0) + 0.5) / WORLD.sX;
      float y_point = WORLD.dY * ((-1 * (lat - WORLD.oY) / 180.0) + 0.5) / WORLD.sY;

      WORLD.graphics.vertex(x_point, y_point,
                             subFace[s].u * this.Map[n_Map].width,
                             subFace[s].v * this.Map[n_Map].height);
    }

    WORLD.graphics.endShape(CLOSE);
  }

  private void writeFaceHTML (FaceVertex[] subFace, int n_Map) {
    htmlOutput.println("\t\t\t\t<shape>");
    if (n_Map != -1) {
      htmlOutput.println("\t\t\t\t\t<Appearance USE='TropoSphere" + nf(n_Map, 0) + "'></Appearance>");
    }

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

    if (n_Map != -1) {
      htmlOutput.print("\t\t\t\t\t\t<TextureCoordinate point='");
      for (int s = 0; s < subFace.length; s++) {
        if (s > 0) htmlOutput.print(",");
        float u = clamp01(subFace[s].u);
        float v = 1 - clamp01(subFace[s].v); // mirroring the image
        SOLARCHVISION_HTMLprintVtexture(u, v);
      }
      htmlOutput.println("'></TextureCoordinate>");
    }

    htmlOutput.println("\t\t\t\t\t</IndexedFaceSet>");
    htmlOutput.println("\t\t\t\t</shape>");
  }

  private void writeFaceWIN3D (FaceVertex[] subFace, int n_Map) {
    WIN3D.graphics.strokeWeight(1);
    WIN3D.graphics.beginShape();
    WIN3D.graphics.noStroke();
    if (this.displayTexture) {
      WIN3D.graphics.texture(this.Map[n_Map]);
    }

    for (int s = 0; s < subFace.length; s++) {
      float u = clamp01(subFace[s].u);
      float v = clamp01(subFace[s].v);
      WIN3D.graphics.vertex(
        subFace[s].x * OBJECTS_scale * WIN3D.scale,
        -subFace[s].y * OBJECTS_scale * WIN3D.scale,
        subFace[s].z * OBJECTS_scale * WIN3D.scale,
        u * this.Map[n_Map].width,
        v * this.Map[n_Map].height
      );
    }

    WIN3D.graphics.endShape(CLOSE);
  }

  private void writeFaceOBJ (FaceVertex[] subFace, int f, int _turn, int n_Map) {
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
      writeOBJFaceIndices(f, n_Map);
    }
  }

  private void writeOBJFaceIndices (int f, int n_Map) {
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
      objOutput.println("g TropoSphere" + nf(n_Map, 0) + "_" + nf(f, 0));
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
