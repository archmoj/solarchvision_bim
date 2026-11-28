class Cameras {

  final static String CLASS_STAMP = "camera";

  Cameras () { // constructor
    makeEmpty(0);
  }

  boolean displayAll = true;

  float[][] options;
  int[] Type;
  int num;

  // Opaque, caller-defined JSON metadata, one entry per camera - "" is the
  // canonical "nothing here" value (see extraParamsHelpers.pde's own
  // comment, shared with faces.pde/polylines.pde/groups.pde/model1Ds.pde/
  // model2Ds.pde/solids.pde). Parsed lazily, only via
  // getExtraParamsObject()/setExtraParamsObject() below, never during
  // to_XML/from_XML or any structural resize.
  String[] extraParams;

  // Whether each camera is active/exported at all - 1 (the default, see
  // ensureVisibilityLength() below) is visible, 0 is hidden - same
  // signed-int convention as Faces'/Polylines' own getVisibility()/
  // setVisibility() (faces.pde).
  int[] visibility;

  void makeEmpty (int n) {
    beginScene3DChange();

    this.num = n;
    this.options = new float [n][9];
    this.Type = new int [n];
    this.extraParams = new String [n];
    java.util.Arrays.fill(this.extraParams, "");
    this.visibility = new int [n];
    java.util.Arrays.fill(this.visibility, 1);

    this.add_first();

    if (Select3D != null) {
      Select3D.deselect_Cameras();
    }

    endScene3DChange();
  }


  // New-from-scratch camera - no source to inherit extraParams from, so
  // it gets this field's own "nothing here" default (""). Delegates to
  // the explicit-extraParams overload below.
  void create (float x, float y, float z, float s, float rx, float ry, float rz, float rs, float f, int t) {
    this.create(x, y, z, s, rx, ry, rz, rs, f, t, "");
  }

  // Same as the no-extraParams overload above, but lets the caller supply
  // the new camera's extraParams directly - e.g. clone3D.pde's Cameras()
  // passes its source camera's own extraParams straight through here,
  // instead of this blind-append default plus a later setExtraParams()
  // fixup. Still a blind append and does NOT self-heal/guard itself
  // against extraParams already being out of sync with options/Type/num.
  // A caller about to index extraParams at [this.num] right after this
  // call must call ensureExtraParamsLength() itself first.
  void create (float x, float y, float z, float s, float rx, float ry, float rz, float rs, float f, int t, String extraParams) {

    int[] TempCamera_type = {
      t
    };
    this.Type = concat(this.Type, TempCamera_type);

    float[][] TempCamera_options = {
      {
        x, y, z, s, rx, ry, rz, rs, f
      }
    };
    this.options = (float[][]) concat(this.options, TempCamera_options);

    this.extraParams = (String[]) concat(this.extraParams, new String[]{ extraParams });

    // Same reasoning as solids.pde's own create() - keeps visibility
    // eagerly grown alongside extraParams/Type/options here, rather
    // than relying solely on getVisibility()'s own lazy padding - this
    // is also what add_first() (called by makeEmpty(), just above)
    // relies on to end up with a visibility array that's already the
    // right length for the one default camera it creates.
    this.visibility = concat(this.visibility, new int[]{ 1 });

    this.num += 1;
  }


  String getExtraParams (int n) {
    if (this.extraParams == null || n < 0 || n >= this.extraParams.length) return "";
    return this.extraParams[n];
  }

  void setExtraParams (int n, String json) {
    this.extraParams[n] = json;
  }

  void ensureExtraParamsLength () {
    if (this.extraParams != null && this.extraParams.length == this.num) return;
    String[] resized = new String[this.num];
    int copyLen = (this.extraParams == null) ? 0 : min(this.extraParams.length, resized.length);
    for (int i = 0; i < copyLen; i++) resized[i] = this.extraParams[i];
    for (int i = copyLen; i < resized.length; i++) resized[i] = "";
    this.extraParams = resized;
  }

  int getVisibility (int n) {
    this.ensureVisibilityLength();
    if (n < 0 || n >= this.visibility.length) return 1;
    return this.visibility[n];
  }

  void setVisibility (int n, int visibility) {
    this.ensureVisibilityLength();
    this.visibility[n] = visibility;
  }

  void ensureVisibilityLength () {
    if (this.visibility != null && this.visibility.length == this.num) return;
    int[] resized = new int[this.num];
    int copyLen = (this.visibility == null) ? 0 : min(this.visibility.length, resized.length);
    for (int i = 0; i < copyLen; i++) resized[i] = this.visibility[i];
    for (int i = copyLen; i < resized.length; i++) resized[i] = 1;
    this.visibility = resized;
  }

  JSONObject getExtraParamsObject (int n) {
    return extraParamsToJSONObject(this.getExtraParams(n));
  }

  void setExtraParamsObject (int n, JSONObject obj) {
    this.setExtraParams(n, extraParamsFromJSONObject(obj));
  }

  // Resets every camera's own extraParams back to "" (its documented
  // default, above) regardless of selection - see faces.pde's own
  // identical method for the full reasoning.
  void stripAllExtraParams () {
    this.ensureExtraParamsLength();
    for (int n = 0; n < this.extraParams.length; n++) this.extraParams[n] = "";
  }


  float get_posX (int n) {
    return this.options[n][0];
  }

  float get_posY (int n) {
    return this.options[n][1];
  }

  float get_posZ (int n) {
    return this.options[n][2];
  }

  float get_posT (int n) {
    return this.options[n][3];
  }

  float get_rotX (int n) {
    return this.options[n][4];
  }

  float get_rotY (int n) {
    return this.options[n][5];
  }

  float get_rotZ (int n) {
    return this.options[n][6];
  }

  float get_rotT (int n) {
    return this.options[n][7];
  }

  float get_zoom (int n) {
    return this.options[n][8];
  }

  int get_type (int n) {
    return this.Type[n];
  }

  void set_posX (int n, float f) {
    this.options[n][0] = f;
  }

  void set_posY (int n, float f) {
    this.options[n][1] = f;
  }

  void set_posZ (int n, float f) {
    this.options[n][2] = f;
  }

  void set_posT (int n, float f) {
    this.options[n][3] = f;
  }

  void set_rotX (int n, float f) {
    this.options[n][4] = f;
  }

  void set_rotY (int n, float f) {
    this.options[n][5] = f;
  }

  void set_rotZ (int n, float f) {
    this.options[n][6] = f;
  }

  void set_rotT (int n, float f) {
    this.options[n][7] = f;
  }

  void set_zoom (int n, float f) {
    this.options[n][8] = f;
  }

  void set_type (int n, int t) {
    this.Type[n] = t;
  }


  void move (int n, float dx, float dy, float dz) {
    this.options[n][0] += dx;
    this.options[n][1] += dy;
    this.options[n][2] += dz;
  }




  void add_first () {

    this.create(WIN3D.positionX,
                    WIN3D.positionY,
                    WIN3D.positionZ,
                    WIN3D.positionStep,
                    WIN3D.rotationX,
                    WIN3D.rotationY,
                    WIN3D.rotationZ,
                    WIN3D.rotationStep,
                    WIN3D.zoom,
                    WIN3D.projectionTypeIndex);
  }




  float[][] Vertices;
  int[][] Faces;

  void draw () {

    this.Faces = new int [this.num][4];
    this.Vertices = new float [4 * this.num][3];

    if (this.displayAll) {

      for (int f = 0; f < this.num; f++) {

        float Camera_pX = this.get_posX(f);
        float Camera_pY = this.get_posY(f);
        float Camera_pZ = this.get_posZ(f);
        float Camera_pT = this.get_posT(f);
        float Camera_rX = this.get_rotX(f);
        float Camera_rY = this.get_rotY(f);
        float Camera_rZ = this.get_rotZ(f);
        float Camera_rT = this.get_rotT(f);
        float Camera_zoom = this.get_zoom(f);
        int   Camera_type = this.get_type(f);

        WIN3D.graphics.strokeWeight(1);
        WIN3D.graphics.stroke(0);
        WIN3D.graphics.noFill();

        WIN3D.graphics.beginShape();

        float[][] ImageVertex = getCorners(Camera_type, Camera_pX, Camera_pY, Camera_pZ, Camera_pT, Camera_rX, Camera_rY, Camera_rZ, Camera_rT, Camera_zoom);

        for (int q = 1; q <= 4; q++) {

          float x = ImageVertex[q][0];
          float y = ImageVertex[q][1];
          float z = ImageVertex[q][2];

          WIN3D.graphics.vertex(x * overallScale * WIN3D.scale, -y * overallScale * WIN3D.scale, z * overallScale * WIN3D.scale);

          this.Vertices[f * 4 + q - 1][0] = x;
          this.Vertices[f * 4 + q - 1][1] = y;
          this.Vertices[f * 4 + q - 1][2] = z;
        }

        this.Faces[f][0] = f * 4 + 0;
        this.Faces[f][1] = f * 4 + 1;
        this.Faces[f][2] = f * 4 + 2;
        this.Faces[f][3] = f * 4 + 3;

        WIN3D.graphics.endShape(CLOSE);

        WIN3D.graphics.strokeWeight(1);
        WIN3D.graphics.stroke(0);
        //WIN3D.graphics.fill(127,255,127,127);
        WIN3D.graphics.noFill();

        WIN3D.graphics.beginShape();

        for (int q = 1; q <= 4; q++) {

          {
            float x = ImageVertex[q][0];
            float y = ImageVertex[q][1];
            float z = ImageVertex[q][2];

            WIN3D.graphics.vertex(x * overallScale * WIN3D.scale, -y * overallScale * WIN3D.scale, z * overallScale * WIN3D.scale);
          }

          {
            int next_q = 1 + (q % 4);

            float x = ImageVertex[next_q][0];
            float y = ImageVertex[next_q][1];
            float z = ImageVertex[next_q][2];

            WIN3D.graphics.vertex(x * overallScale * WIN3D.scale, -y * overallScale * WIN3D.scale, z * overallScale * WIN3D.scale);
          }

          {
            int o = 0;

            float x = ImageVertex[o][0];
            float y = ImageVertex[o][1];
            float z = ImageVertex[o][2];

            WIN3D.graphics.vertex(x * overallScale * WIN3D.scale, -y * overallScale * WIN3D.scale, z * overallScale * WIN3D.scale);
          }
        }

        WIN3D.graphics.endShape(CLOSE);
      }

      WIN3D.graphics.strokeWeight(0);
    }
  }


  float[][] getCorners (int Camera_type, float Camera_pX, float Camera_pY, float Camera_pZ, float Camera_pT, float Camera_rX, float Camera_rY, float Camera_rZ, float Camera_rT, float Camera_zoom) {

    float[][] ImageVertex = new float [5][3];

    float r = Camera_pT * 5; // <<<<<<

    float rx = r * funcs.sin_ang(0.5 * Camera_zoom) /  WIN3D.view_R;
    float ry = r * funcs.sin_ang(0.5 * Camera_zoom);
    float rz = r * funcs.cos_ang(0.5 * Camera_zoom);

    for (int q = 0; q < 5; q++) {

      float qx = 0, qy = 0, qz = 0;

      if (q == 0) {
        qx = 0;
        qy = 0;
        qz = 0;
      } else if (q == 1) {
        qx = -1;
        qy = -1;
        qz = -1;
      } else if (q == 2) {
        qx = -1;
        qy = 1;
        qz = -1;
      } else if (q == 3) {
        qx = 1;
        qy = 1;
        qz = -1;
      } else if (q == 4) {
        qx = 1;
        qy = -1;
        qz = -1;
      }

      float x = 0, y = 0, z = 0;

      float keep_WIN3D_cameraX = WIN3D.cameraX;
      float keep_WIN3D_cameraY = WIN3D.cameraY;
      float keep_WIN3D_cameraZ = WIN3D.cameraZ;
      float keep_WIN3D_positionX = WIN3D.positionX;
      float keep_WIN3D_positionY = WIN3D.positionY;
      float keep_WIN3D_positionZ = WIN3D.positionZ;
      float keep_WIN3D_positionStep = WIN3D.positionStep;
      float keep_WIN3D_rotationX = WIN3D.rotationX;
      float keep_WIN3D_rotationY = WIN3D.rotationY;
      float keep_WIN3D_rotationZ = WIN3D.rotationZ;
      float keep_WIN3D_rotationStep = WIN3D.rotationStep;
      float keep_WIN3D_Zoom = WIN3D.zoom;

      {

        WIN3D.positionX = Camera_pX;
        WIN3D.positionY = Camera_pY;
        WIN3D.positionZ = Camera_pZ;
        WIN3D.positionStep = Camera_pT;
        WIN3D.rotationX = Camera_rX;
        WIN3D.rotationY = Camera_rY;
        WIN3D.rotationZ = Camera_rZ;
        WIN3D.rotationStep = Camera_rT;
        WIN3D.zoom = Camera_zoom;

        WIN3D.transform_3DViewport();

        float x1 = rx * qx;
        float y1 = ry * qy;
        float z1 = rz * qz;

        float x2 = x1;
        float y2 = y1 * funcs.cos_ang(Camera_rX) - z1 * funcs.sin_ang(Camera_rX);
        float z2 = y1 * funcs.sin_ang(Camera_rX) + z1 * funcs.cos_ang(Camera_rX);

        float x3 = x2 * funcs.cos_ang(Camera_rZ) - y2 * funcs.sin_ang(Camera_rZ);
        float y3 = x2 * funcs.sin_ang(Camera_rZ) + y2 * funcs.cos_ang(Camera_rZ);
        float z3 = z2;

        x = WIN3D.cameraX + x3;
        y = WIN3D.cameraY + y3;
        z = WIN3D.cameraZ + z3;
      }

      WIN3D.cameraX = keep_WIN3D_cameraX;
      WIN3D.cameraY = keep_WIN3D_cameraY;
      WIN3D.cameraZ = keep_WIN3D_cameraZ;
      WIN3D.positionX = keep_WIN3D_positionX;
      WIN3D.positionY = keep_WIN3D_positionY;
      WIN3D.positionZ = keep_WIN3D_positionZ;
      WIN3D.positionStep = keep_WIN3D_positionStep;
      WIN3D.rotationX = keep_WIN3D_rotationX;
      WIN3D.rotationY = keep_WIN3D_rotationY;
      WIN3D.rotationZ = keep_WIN3D_rotationZ;
      WIN3D.rotationStep = keep_WIN3D_rotationStep;
      WIN3D.zoom = keep_WIN3D_Zoom;

      ImageVertex[q][0] = x;
      ImageVertex[q][1] = y;
      ImageVertex[q][2] = z;
    }

    return ImageVertex;
  }

  float[] intersect (float[] ray_pnt, float[] ray_dir) {

    float[] ray_normal = funcs.vec3_unit(ray_dir);

    float[][] hitPoint = new float [this.Faces.length][4];

    for (int f = 0; f < this.Faces.length; f++) {
      java.util.Arrays.fill(hitPoint[f], FLOAT_undefined);
    }

    for (int f = 0; f < this.Faces.length; f++) {

      int n = this.Faces[f].length;

      float X_intersect = FLOAT_undefined;
      float Y_intersect = FLOAT_undefined;
      float Z_intersect = FLOAT_undefined;
      float dist2intersect = FLOAT_undefined;

      boolean InPoly = false;

      float[] A = this.Vertices[this.Faces[f][0]];
      float[] B = this.Vertices[this.Faces[f][1]];
      float[] C = this.Vertices[this.Faces[f][n - 2]];
      float[] D = this.Vertices[this.Faces[f][n - 1]];

      float[] AC = funcs.vec3_diff(A, C);
      float[] BD = funcs.vec3_diff(B, D);

      float[] face_norm = funcs.vec3_cross(AC, BD);

      float face_offset = 0.25 * ((A[0] + B[0] + C[0] + D[0]) * face_norm[0] + (A[1] + B[1] + C[1] + D[1]) * face_norm[1] + (A[2] + B[2] + C[2] + D[2]) * face_norm[2]);

      float R = -funcs.vec3_dot(ray_dir, face_norm);

      if ((R < FLOAT_tiny) && (R > -FLOAT_tiny)) { // the ray is parallel to the plane
        dist2intersect = FLOAT_huge;
      }
      else {
        dist2intersect = (funcs.vec3_dot(ray_pnt, face_norm) - face_offset) / R;

        //if (dist2intersect > 0) {
        if (dist2intersect > FLOAT_tiny) {

          X_intersect = dist2intersect * ray_dir[0] + ray_pnt[0];
          Y_intersect = dist2intersect * ray_dir[1] + ray_pnt[1];
          Z_intersect = dist2intersect * ray_dir[2] + ray_pnt[2];

          float[] P = {X_intersect, Y_intersect, Z_intersect};

          InPoly = funcs.isInside_Rectangle(P, A, B, C);
        }
      }

      if (InPoly) {
        hitPoint[f][0] = X_intersect;
        hitPoint[f][1] = Y_intersect;
        hitPoint[f][2] = Z_intersect;
        hitPoint[f][3] = dist2intersect;
      }

    }

    float[] return_point = {-1, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined};

    float pre_dist = FLOAT_undefined;

    for (int f = 0; f < this.Faces.length; f++) {

      if (pre_dist > hitPoint[f][3]) {

        pre_dist = hitPoint[f][3];

        return_point[0] = f;
        return_point[1] = hitPoint[f][0];
        return_point[2] = hitPoint[f][1];
        return_point[3] = hitPoint[f][2];
        return_point[4] = hitPoint[f][3];
      }

    }

    return return_point;
  }


  public void to_XML (XML xml) {

    XML parent = xml.addChild(this.CLASS_STAMP);

    int ni = this.num;
    XML_setInt(parent, "ni", ni);
    for (int i = 0; i < ni; i++) {
      XML child = parent.addChild("item");
      XML_setInt(child, "id", i);
      String txt = "";
      txt += nf(this.get_posX(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.get_posY(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.get_posZ(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.get_posT(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.get_rotX(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.get_rotY(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.get_rotZ(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.get_rotT(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.get_zoom(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.get_type(i), 0);

      XML_setContent(child, txt);

      XML_setString(child, "extraParams", this.getExtraParams(i));
      XML_setInt(child, "visibility", this.getVisibility(i));
    }

    XML_setBoolean(parent, "displayAll", this.displayAll);
  }


  public void from_XML (XML xml) {

    XML parent = xml.getChild(this.CLASS_STAMP);

    int ni = XML_getInt(parent, "ni");

    this.options = new float [ni][9];
    this.Type = new int [ni];
    this.extraParams = new String [ni];
    java.util.Arrays.fill(this.extraParams, "");
    this.visibility = new int [ni];
    java.util.Arrays.fill(this.visibility, 1);

    this.num = ni;

    XML[] children = parent.getChildren("item");
    for (int i = 0; i < ni; i++) {

      String txt = XML_getContent(children[i]);
      String[] parts = split(txt, ",");
      this.set_posX(i, float(parts[0]));
      this.set_posY(i, float(parts[1]));
      this.set_posZ(i, float(parts[2]));
      this.set_posT(i, float(parts[3]));
      this.set_rotX(i, float(parts[4]));
      this.set_rotY(i, float(parts[5]));
      this.set_rotZ(i, float(parts[6]));
      this.set_rotT(i, float(parts[7]));
      this.set_zoom(i, float(parts[8]));
      this.set_type(i,   int(parts[9]));

      // Falls back to "" (this field's own "nothing here" default) for a
      // save file written before extraParams existed at all - see the
      // 3-arg XML_getString() overload's own comment (xmlHelpers.pde).
      this.setExtraParams(i, XML_getString(children[i], "extraParams", ""));
      // Falls back to 1 (visible) for a save file written before
      // visibility existed on this class at all - same reasoning as
      // extraParams' own fallback just above.
      this.setVisibility(i, children[i].getInt("visibility", 1));
    }

    this.displayAll = XML_getBoolean(parent, "displayAll");
  }

}
