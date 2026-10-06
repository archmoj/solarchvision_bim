class Moon3D {

  final static String CLASS_STAMP = "Moon3D";

  final static float LONGITUDE_SPAN = 360.0;
  final static float LATITUDE_SPAN  = 180.0;
  final static float MOON_RADIUS = 1737000.0;
  final static float EARTH_MOON_DISTANCE = 384400000.0;

  float lat_step = 5; //in degrees
  float lon_step  = 10; //in degrees

  boolean displaySurface = false;
  boolean displayTexture = true;

  boolean fitInSkyDome = true;

  String Filename = BaseFolder + "/input/images/moon/Moon.jpg";
  PImage Map;

  class FaceVertex {
    float x, y, z;
    float u, v;
  }

  void load_images () {
    this.Map = loadImage(this.Filename);
  }

  void draw () {
    if (!this.displaySurface) return;

    WIN3D.graphics.strokeWeight(1);

    float ScaleX  = 1;
    float ScaleY  = 1;
    float CEN_lon = 0;
    float CEN_lat = 0;

    float r = MOON_RADIUS * celestialMagnification;
    float d = EARTH_MOON_DISTANCE - FLOAT_r_Earth;

    if(this.fitInSkyDome) {
      // fit the moon inside the sky sphere
      // bring it closer and resize it
      r *= Sky3D.radius / d;
      d = Sky3D.radius;
    }


    for (float Alpha = 90; Alpha > -90; Alpha -= this.lat_step) {
      for (float Beta = 180; Beta > -180; Beta -= this.lon_step) {
        FaceVertex[] subFace = buildSubFace(Alpha, Beta, r, d, CEN_lon, CEN_lat, ScaleX, ScaleY);
        writeFaceWIN3D(subFace);
      }
    }
  }

  FaceVertex[] buildSubFace (float Alpha, float Beta,
                                      float r, float d, float CEN_lon, float CEN_lat, float ScaleX, float ScaleY) {
    FaceVertex[] subFace = new FaceVertex[4];

    float tb = 0;
    float stationLat = STATION.getLatitude();
    float ta = 90 - stationLat;

    // Real position tracking, same architecture as Sun3D.pde: MoonR/tA/tB
    // move the sphere's POSITION across the sky via the translation step
    // below, using the exact same SHADE_DATE_ANGLE/SHADE_HOUR_ANGLE this
    // app already drives the Sun with (see funcs.MoonPosition's own
    // comment for what this simplified model does and doesn't capture).
    float[] MoonR = funcs.MoonPosition(stationLat, SHADE_DATE_ANGLE, SHADE_HOUR_ANGLE);
    float tA = funcs.asin_ang(MoonR[3]);
    float tB = funcs.atan2_ang(MoonR[2], MoonR[1]);

    // Tidal locking, same (forward, up, right) construction as Sun3D.pde -
    // a plain (lat, lon) shift only locks WHICH POINT faces the station,
    // not the texture's roll around that point (checked by hand, same
    // conclusion as Sun3D.pde: it isn't enough on its own). F is "which
    // point faces the station"; pole is the celestial pole's direction in
    // this same frame (Declination = 90 in MoonPosition's underlying
    // formula - hour angle drops out entirely there, as it should).
    float Fx = 0, Fy = 0, Fz = 0;
    float Rupx = 0, Rupy = 0, Rupz = 0;
    float Rrightx = 0, Rrighty = 0, Rrightz = 0;
    if (this.displayTexture) {
      Fx = -funcs.cos_ang(tB) * funcs.cos_ang(tA);
      Fy = -funcs.sin_ang(tB) * funcs.cos_ang(tA);
      Fz = -funcs.sin_ang(tA);

      float poleX = 0;
      float poleY = -funcs.cos_ang(stationLat);
      float poleZ = -funcs.sin_ang(stationLat);

      // right = pole x F
      Rrightx = poleY * Fz - poleZ * Fy;
      Rrighty = poleZ * Fx - poleX * Fz;
      Rrightz = poleX * Fy - poleY * Fx;
      float rightLen = sqrt(Rrightx * Rrightx + Rrighty * Rrighty + Rrightz * Rrightz);
      if (rightLen < 0.0001) {
        // Degenerate only if the Moon sits exactly at the celestial pole
        // itself (not physically possible here - Declination maxes out
        // at 23.45 - but guarded for safety rather than risking a NaN).
        Rrightx = 1;
        Rrighty = 0;
        Rrightz = 0;
        rightLen = 1;
      }
      Rrightx /= rightLen;
      Rrighty /= rightLen;
      Rrightz /= rightLen;

      // up = F x right
      Rupx = Fy * Rrightz - Fz * Rrighty;
      Rupy = Fz * Rrightx - Fx * Rrightz;
      Rupz = Fx * Rrighty - Fy * Rrightx;
    }

    for (int s = 0; s < 4; s++) {
      FaceVertex vtx = new FaceVertex();

      float a = Alpha;
      float b = Beta;
      if (s == 2 || s == 3) a -= this.lat_step;
      if (s == 1 || s == 2) b -= this.lon_step;

      // corner position on the moon sphere
      float x0 = r * funcs.cos_ang(b - 90) * funcs.cos_ang(a);
      float y0 = r * funcs.sin_ang(b - 90) * funcs.cos_ang(a);
      float z0 = r * funcs.sin_ang(a);

      if (this.displayTexture) {
        // This vertex's own direction (unit sphere, tb/ta applied, no
        // translation) - same transform as x1/y1/z1/x2/y2/z2 below, just
        // computed early and unscaled (divide out r) so it can be
        // decomposed against the (Fx,Fy,Fz)/(Rupx,Rupy,Rupz)/
        // (Rrightx,Rrighty,Rrightz) frame above.
        float ux0 = x0 / r;
        float uy0 = y0 / r;
        float uz0 = z0 / r;

        float ux1 = ux0 * funcs.cos_ang(tb) - uy0 * funcs.sin_ang(tb);
        float uy1 = ux0 * funcs.sin_ang(tb) + uy0 * funcs.cos_ang(tb);
        float uz1 = uz0;

        float ux2 = ux1;
        float uy2 = uz1 * funcs.sin_ang(ta) + uy1 * funcs.cos_ang(ta);
        float uz2 = uz1 * funcs.cos_ang(ta) - uy1 * funcs.sin_ang(ta);

        float compForward = ux2 * Fx + uy2 * Fy + uz2 * Fz;
        float compUp = ux2 * Rupx + uy2 * Rupy + uz2 * Rupz;
        float compRight = ux2 * Rrightx + uy2 * Rrighty + uz2 * Rrightz;

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

      // move out to lunar distance, in the Moon's real current sky direction
      x2 += d * funcs.cos_ang(tB) * funcs.cos_ang(tA);
      y2 += d * funcs.sin_ang(tB) * funcs.cos_ang(tA);
      z2 += d * funcs.sin_ang(tA);

      vtx.x = x2;
      vtx.y = y2;
      vtx.z = z2;

      subFace[s] = vtx;
    }

    return subFace;
  }

  void writeFaceWIN3D (FaceVertex[] subFace) {
    WIN3D.graphics.beginShape();
    WIN3D.graphics.noStroke();
    if (this.displayTexture) {
      WIN3D.graphics.texture(this.Map);
    }

    for (int s = 0; s < subFace.length; s++) {
      WIN3D.graphics.vertex(
        subFace[s].x * overallScale * WIN3D.scale,
        -subFace[s].y * overallScale * WIN3D.scale,
        subFace[s].z * overallScale * WIN3D.scale,
        subFace[s].u * this.Map.width,
        subFace[s].v * this.Map.height
      );
    }

    WIN3D.graphics.endShape(CLOSE);
  }


  public void to_XML (XML xml) {    XML parent = xml.addChild(this.CLASS_STAMP);
    XML_setBoolean(parent, "displaySurface", this.displaySurface);
    XML_setBoolean(parent, "displayTexture", this.displayTexture);
    XML_setBoolean(parent, "fitInSkyDome", this.fitInSkyDome);
  }

  public void from_XML (XML xml) {    XML parent = xml.getChild(this.CLASS_STAMP);
    this.displaySurface = XML_getBoolean(parent, "displaySurface");
    this.displayTexture = XML_getBoolean(parent, "displayTexture");
    this.fitInSkyDome = XML_getBoolean(parent, "fitInSkyDome");
  }
}
