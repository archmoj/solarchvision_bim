class solarchvision_Points {

  private final static String CLASS_STAMP = "Points";

  solarchvision_Points () { // constructor
    makeEmpty(0);
  }

  boolean displayAll = false;

  void makeEmpty (int n) {

    allVertices = new float [n][3];

    if (Select3D != null) {
      Select3D.deselect_Groups();
      Select3D.deselect_Faces();
      Select3D.deselect_Polylines();
      Select3D.deselect_Vertices();
    }

    SOLARCHVISION_model_changed();
  }

  void setX (int n, float f) {

    allVertices[n][0] = f;
  }

  void setY (int n, float f) {

    allVertices[n][1] = f;
  }

  void setZ (int n, float f) {

    allVertices[n][2] = f;
  }

  void move (int n, float dx, float dy, float dz) {

    allVertices[n][0] += dx;
    allVertices[n][1] += dy;
    allVertices[n][2] += dz;
  }


  int getLength () {
    return  allVertices.length;
  }

  float getX (int n) {

    return allVertices[n][0];
  }

  float getY (int n) {

    return allVertices[n][1];
  }

  float getZ (int n) {

    return allVertices[n][2];
  }

  float[] getPosition (int n) {

    float[] result = {this.getX(n), this.getY(n), this.getZ(n)};

    return result;
  }


  int create (float x, float y, float z) {

    float[][] newVertex = {
      {
        x, y, z
      }
    };

    allVertices = (float[][]) concat(allVertices, newVertex);

    return(this.getLength() - 1);
  }





  void draw () {

    if (this.displayAll) {

      WIN3D.graphics.strokeWeight(3);

      WIN3D.graphics.stroke(0);

      WIN3D.graphics.noFill();

      float d = 0.5; // <<<<<<<<<<<<<< distance

      for (int f = 0; f < allPoints.getLength(); f++) {

        float x = allPoints.getX(f);
        float y = allPoints.getY(f);
        float z = allPoints.getZ(f);

        WIN3D.graphics.line((x - d) * OBJECTS_scale * WIN3D.scale, -(y * OBJECTS_scale * WIN3D.scale), z * OBJECTS_scale * WIN3D.scale, (x + d) * OBJECTS_scale * WIN3D.scale, -(y * OBJECTS_scale * WIN3D.scale), z * OBJECTS_scale * WIN3D.scale);

        WIN3D.graphics.line(x * OBJECTS_scale * WIN3D.scale, -((y - d) * OBJECTS_scale * WIN3D.scale), z * OBJECTS_scale * WIN3D.scale, x * OBJECTS_scale * WIN3D.scale, -((y + d) * OBJECTS_scale * WIN3D.scale), z * OBJECTS_scale * WIN3D.scale);

        WIN3D.graphics.line(x * OBJECTS_scale * WIN3D.scale, -(y * OBJECTS_scale * WIN3D.scale), (z - d) * OBJECTS_scale * WIN3D.scale, x * OBJECTS_scale * WIN3D.scale, -(y * OBJECTS_scale * WIN3D.scale), (z + d) * OBJECTS_scale * WIN3D.scale);

      }

      WIN3D.graphics.strokeWeight(0);
    }
  }

  public void to_XML (XML xml) {

    println("Saving:" + this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setInt(parent, "ni", allPoints.getLength());
    for (int i = 0; i < allPoints.getLength(); i++) {
      XML child = parent.addChild("item");
      XML_setInt(child, "id", i);
      String txt = "";
      txt += nf(allPoints.getX(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(allPoints.getY(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(allPoints.getZ(i), 0, 4).replace(",", "."); // <<<<
      XML_setContent(child, txt);
    }

    XML_setBoolean(parent, "displayAll", this.displayAll);
  }


  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);

    int ni = XML_getInt(parent, "ni");
    allVertices = new float [ni][3];
    XML[] children = parent.getChildren("item");
    for (int i = 0; i < ni; i++) {
      String txt = XML_getContent(children[i]);
      String[] parts = split(txt, ",");

      allPoints.setX(i, float(parts[0]));
      allPoints.setY(i, float(parts[1]));
      allPoints.setZ(i, float(parts[2]));
    }

    this.displayAll = XML_getBoolean(parent, "displayAll");
  }


}
