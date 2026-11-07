class Points {

  final static String CLASS_STAMP = "vertex";

  Points () { // constructor
    makeEmpty(0);
  }

  boolean displayAll = false;

  void makeEmpty (int n) {
    beginScene3DChange();

    allVertices = new float [n][3];

    if (Select3D != null) {
      Select3D.deselect_Groups();
      Select3D.deselect_Faces();
      Select3D.deselect_Polylines();
      Select3D.deselect_Vertices();
    }

    endScene3DChange();
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

  // Same result as calling create() once per row of newVertices, in
  // order, but with a single concat() for the WHOLE batch instead of
  // one per point - added for importLas.pde's own box-grid meshing
  // (lasCreateBoxGridFaces()), which creates many thousands of brand-
  // new points (never reusing/deduplicating any of them - see that
  // function's own comment) in one pass: concat() copies the WHOLE
  // existing array just to append one more row, so calling create() in
  // a tight loop costs roughly the SQUARE of the final point count, not
  // something close to linear in it - fine for a handful of points, but
  // the real reason a box-grid import that comfortably handles 10,000
  // points can still take drastically, visibly longer (not just 10x
  // longer) at 100,000. One concat() for the whole batch instead keeps
  // this the same roughly-linear cost every other point-creating path
  // in this app already has. Returns each new point's own real index,
  // in the same order as newVertices, the same way a loop of plain
  // create() calls would have.
  int[] createBatch (float[][] newVertices) {
    int startIndex = this.getLength();

    allVertices = (float[][]) concat(allVertices, newVertices);

    int[] indices = new int[newVertices.length];
    for (int i = 0; i < newVertices.length; i++) indices[i] = startIndex + i;
    return indices;
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

        WIN3D.graphics.line((x - d) * overallScale * WIN3D.scale, -(y * overallScale * WIN3D.scale), z * overallScale * WIN3D.scale, (x + d) * overallScale * WIN3D.scale, -(y * overallScale * WIN3D.scale), z * overallScale * WIN3D.scale);

        WIN3D.graphics.line(x * overallScale * WIN3D.scale, -((y - d) * overallScale * WIN3D.scale), z * overallScale * WIN3D.scale, x * overallScale * WIN3D.scale, -((y + d) * overallScale * WIN3D.scale), z * overallScale * WIN3D.scale);

        WIN3D.graphics.line(x * overallScale * WIN3D.scale, -(y * overallScale * WIN3D.scale), (z - d) * overallScale * WIN3D.scale, x * overallScale * WIN3D.scale, -(y * overallScale * WIN3D.scale), (z + d) * overallScale * WIN3D.scale);

      }

      WIN3D.graphics.strokeWeight(0);
    }
  }

  public void to_XML (XML xml) {

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
