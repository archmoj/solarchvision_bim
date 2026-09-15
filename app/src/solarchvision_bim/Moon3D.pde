class solarchvision_Moon3D {

  private final static String CLASS_STAMP = "Moon3D";

  private final static float LONGITUDE_SPAN = 360.0;
  private final static float LATITUDE_SPAN  = 180.0;
  private final static float MOON_RADIUS_M = 1737000.0;
  private final static float EARTH_MOON_DISTANCE_M = 384400000.0;

  boolean displaySurface = false;
  boolean displayTexture = true;

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

    float delta_Alpha = -5;
    float delta_Beta  = -10;

    float r = MOON_RADIUS_M * Planetary_Magnification;
    float d = EARTH_MOON_DISTANCE_M - FLOAT_r_Earth;

    for (float Alpha = 90; Alpha > -90; Alpha += delta_Alpha) {
      for (float Beta = 180; Beta > -180; Beta += delta_Beta) {
        FaceVertex[] subFace = buildSubFace(Alpha, Beta, delta_Alpha, delta_Beta, r, d, CEN_lon, CEN_lat, ScaleX, ScaleY);
        writeFaceWIN3D(subFace);
      }
    }
  }

  private FaceVertex[] buildSubFace (float Alpha, float Beta, float delta_Alpha, float delta_Beta,
                                      float r, float d, float CEN_lon, float CEN_lat, float ScaleX, float ScaleY) {
    FaceVertex[] subFace = new FaceVertex[4];

    float tb = 0;
    float stationLat = STATION.getLatitude();
    float ta = -90 - stationLat;

    for (int s = 0; s < 4; s++) {
      FaceVertex vtx = new FaceVertex();

      float a = Alpha;
      float b = Beta;
      if (s == 2 || s == 3) a += delta_Alpha;
      if (s == 1 || s == 2) b += delta_Beta;

      // corner position on the moon sphere
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

      // move it out to lunar distance, above the station
      y2 += d * funcs.sin_ang(-stationLat);
      z2 += d * funcs.cos_ang(-stationLat);

      vtx.x = x2;
      vtx.y = y2;
      vtx.z = z2;

      subFace[s] = vtx;
    }

    return subFace;
  }

  private void writeFaceWIN3D (FaceVertex[] subFace) {
    WIN3D.graphics.beginShape();
    WIN3D.graphics.noStroke();
    if (this.displayTexture) {
      WIN3D.graphics.texture(this.Map);
    }

    for (int s = 0; s < subFace.length; s++) {
      WIN3D.graphics.vertex(
        subFace[s].x * OBJECTS_scale * WIN3D.scale,
        -subFace[s].y * OBJECTS_scale * WIN3D.scale,
        subFace[s].z * OBJECTS_scale * WIN3D.scale,
        subFace[s].u * this.Map.width,
        subFace[s].v * this.Map.height
      );
    }

    WIN3D.graphics.endShape(CLOSE);
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
