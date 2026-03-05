class solarchvision_Moon3D {

  private final static String CLASS_STAMP = "Moon3D";

  boolean displaySurface = false;
  boolean displayTexture = true;

  String Filename = BaseFolder + "/input/images/moon/Moon.jpg";

  PImage Map;

  void load_images () {
    Map = loadImage(Filename);
  }

  void draw () {
    if (this.displaySurface) {

      WIN3D.graphics.strokeWeight(1);

      float OffsetX = 0;
      float OffsetY = 0;

      float ScaleX = 1;
      float ScaleY = 1;

      float CEN_lon = 0;
      float CEN_lat = 0;

      float delta_Alpha = -5;
      float delta_Beta = -10;

      float r = 1737000.0 * Planetary_Magnification;
      float d = 384400000.0 - FLOAT_r_Earth;

      for (float Alpha = 90; Alpha > -90; Alpha += delta_Alpha) {
        for (float Beta = 180; Beta > -180; Beta += delta_Beta) {

          float[][] subFace = new float [4][5];

          for (int s = 0; s < 4; s++) {

            float a = Alpha;
            float b = Beta;

            if ((s == 2) || (s == 3)) {
              a += delta_Alpha;
            }

            if ((s == 1) || (s == 2)) {
              b += delta_Beta;
            }

            float x0 = r * funcs.cos_ang(b - 90) * funcs.cos_ang(a);
            float y0 = r * funcs.sin_ang(b - 90) * funcs.cos_ang(a);
            float z0 = r * funcs.sin_ang(a);

            float _lon = b - CEN_lon;
            float _lat = a - CEN_lat;

            if (this.displayTexture) {
              // calculating u and v
              subFace[s][3] = (_lon / ScaleX / 360.0 + 0.5);
              subFace[s][4] = (-_lat / ScaleY / 180.0 + 0.5);
            }

            // rotating to location coordinates


            float tb = 0;
            float x1 = x0 * funcs.cos_ang(tb) - y0 * funcs.sin_ang(tb);
            float y1 = x0 * funcs.sin_ang(tb) + y0 * funcs.cos_ang(tb);
            float z1 = z0;

            float ta = -90 - STATION.getLatitude();
            float x2 = x1;
            float y2 = z1 * funcs.sin_ang(ta) + y1 * funcs.cos_ang(ta);
            float z2 = z1 * funcs.cos_ang(ta) - y1 * funcs.sin_ang(ta);

            // move it up here!
            y2 += d * funcs.sin_ang(-STATION.getLatitude());
            z2 += d * funcs.cos_ang(-STATION.getLatitude());

            subFace[s][0] = x2;
            subFace[s][1] = y2;
            subFace[s][2] = z2;
          }

          WIN3D.graphics.beginShape();

          WIN3D.graphics.noStroke();

          if (this.displayTexture) {

            WIN3D.graphics.texture(this.Map);
          }

          for (int s = 0; s < subFace.length; s++) {

            WIN3D.graphics.vertex(subFace[s][0] * OBJECTS_scale * WIN3D.scale, -subFace[s][1] * OBJECTS_scale * WIN3D.scale, subFace[s][2] * OBJECTS_scale * WIN3D.scale, subFace[s][3] * this.Map.width, subFace[s][4] * this.Map.height);
          }

          WIN3D.graphics.endShape(CLOSE);
        }
      }
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
