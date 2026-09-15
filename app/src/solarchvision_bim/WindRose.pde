class solarchvision_WindRose {

  private final static String CLASS_STAMP = "WindRose";

  boolean rebuild_Image_array = true;

  PImage[] Image;

  boolean displayImage = false;

  int renderedRES = 1;
  int RES = 400;

  float scale = 400;


  void resize_Image_array () {

    this.Image = new PImage [(1 + STUDY.j_End - STUDY.j_Start)];

    for (int j = STUDY.j_Start; j < STUDY.j_End; j++) {

      this.Image[j + 1] = createImage(2, 2, RGB); // empty and small
    }

    this.rebuild_Image_array = false;
  }


  void draw () {

    if (this.displayImage) {

      if (this.rebuild_Image_array) {
        this.resize_Image_array();
      }

      WIN3D.graphics.stroke(0);
      WIN3D.graphics.fill(127, 127, 127);

      WIN3D.graphics.beginShape();

      float elevation = 0.0 + allSolidImpacts.Z[1];
      float U_scale = this.scale;
      float V_scale = this.scale;

      float minU = 0;
      float maxU = this.renderedRES;
      float minV = 0;
      float maxV = this.renderedRES;

      //float c = HeightAboveGround * OBJECTS_scale; // <<< or zero i.e. height of the plane in 3D  // ?????????
      float c = elevation * OBJECTS_scale;

      c += 1; // put this.Image it at level 1m. // <<<<<<<<<<<

      WIN3D.graphics.beginShape();

      WIN3D.graphics.texture(this.Image[IMPACTS_displayDay]);
      WIN3D.graphics.stroke(255, 255, 255, 0);
      WIN3D.graphics.fill(255, 255, 255, 0);

      for (int q = 0; q < 4; q++) {

        float qx = 0, qy = 0, u = 0, v = 0;

        if (q == 0) {
          qx = -1;
          qy = -1;
          u = minU;
          v = maxV;
        } else if (q == 1) {
          qx = 1;
          qy = -1;
          u = maxU;
          v = maxV;
        } else if (q == 2) {
          qx = 1;
          qy = 1;
          u = maxU;
          v = minV;
        } else if (q == 3) {
          qx = -1;
          qy = 1;
          u = minU;
          v = minV;
        }

        float a = qx * 0.5;
        float b = qy * 0.5;

        float x = 0, y = 0, z = 0;

        x = a;
        y = b;
        z = c;

        WIN3D.graphics.vertex(x * OBJECTS_scale * WIN3D.scale, -y * OBJECTS_scale * WIN3D.scale, z * OBJECTS_scale * WIN3D.scale, u * U_scale, v * V_scale);
      }

      WIN3D.graphics.endShape(CLOSE);
    }
  }




  public void to_XML (XML xml) {

    println("Saving:" + this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setBoolean(parent, "displayImage", this.displayImage);
    XML_setInt(parent, "RES", this.RES);
    XML_setInt(parent, "renderedRES", this.renderedRES);
    XML_setFloat(parent, "scale", this.scale);
  }


  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);

    this.displayImage = XML_getBoolean(parent, "displayImage");
    this.RES = XML_getInt(parent, "RES");
    this.renderedRES = XML_getInt(parent, "renderedRES");
    this.scale = XML_getFloat(parent, "scale");
  }
}
