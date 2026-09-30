class WindRose {

  final static String CLASS_STAMP = "WindRose";

  boolean rebuild_Image_array = true;

  PImage[] Image;

  boolean displayImage = false;

  int renderedResolution = 1;
  int imageResolution = 400;
  float planeSize = 400; // horizontal world-space footprint of the quad drawn in draw() (X/Y only - height is fixed separately below); renamed from textureSize, which no longer described what this does once the fix below stopped using it as a texture-coordinate multiplier

  void resize_Image_array () {

    this.Image = new PImage [(1 + STUDY.endDay - STUDY.startDay)];

    for (int j = STUDY.startDay; j < STUDY.endDay; j++) {

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

      float minU = 0;
      float maxU = this.renderedResolution;
      float minV = 0;
      float maxV = this.renderedResolution;

      float c = 0;
      c += 1; // put this.Image it at level 1m. // <<<<<<<<<<<
      c *= overallScale;

      WIN3D.graphics.beginShape();

      WIN3D.graphics.texture(this.Image[impactDisplayDay]);
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
        WIN3D.graphics.vertex(
          x * overallScale * WIN3D.scale * this.planeSize,
          -y * overallScale * WIN3D.scale * this.planeSize,
          z * overallScale * WIN3D.scale,
          u,
          v
        );
      }

      WIN3D.graphics.endShape(CLOSE);
    }
  }




  public void to_XML (XML xml) {

    //printlnSaving(this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setBoolean(parent, "displayImage", this.displayImage);
    XML_setInt(parent, "imageResolution", this.imageResolution);
    XML_setInt(parent, "renderedResolution", this.renderedResolution);
    XML_setFloat(parent, "planeSize", this.planeSize);
  }


  public void from_XML (XML xml) {

    //println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);

    this.displayImage = XML_getBoolean(parent, "displayImage");
    this.imageResolution = XML_getInt(parent, "imageResolution");
    this.renderedResolution = XML_getInt(parent, "renderedResolution");
    this.planeSize = XML_getFloat(parent, "planeSize");
  }
}
