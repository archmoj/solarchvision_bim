class solarchvision_Solids {

  private final static String CLASS_STAMP = "Solids";

  solarchvision_Solids () { // constructor
    makeEmpty(0);
  }

  boolean displayAll = true;
  int pallet_CLR = 17; //1;
  int pallet_DIR = -1;
  float pallet_MLT = 0.4; //1;

  float[][] DEF;

  void makeEmpty (int n) {
    this.DEF = new float [n][13];

    if (allGroups != null) {
      for (int q = 0; q < allGroups.num; q++) {
        allGroups.Solids[q][0] = 0;
        allGroups.Solids[q][1] = -1;
      }
    }

    if (Select3D != null) {
      Select3D.deselect_Groups();
      Select3D.deselect_Solids();
    }

    SOLARCHVISION_model_changed();
  }

  void updatePosition (int n, float a, float b, float c) {

    this.DEF[n][0] = a;
    this.DEF[n][1] = b;
    this.DEF[n][2] = c;
  }

  void updatePowers (int n, float a, float b, float c) {

    this.DEF[n][3] = a;
    this.DEF[n][4] = b;
    this.DEF[n][5] = c;
  }

  void Scale (int n, float a, float b, float c) {

    this.DEF[n][6] *= a;
    this.DEF[n][7] *= b;
    this.DEF[n][8] *= c;
  }

  void RotateX (int n, float f) {

    this.DEF[n][9] += f;
  }

  void RotateY (int n, float f) {

    this.DEF[n][10] += f;
  }

  void RotateZ (int n, float f) {

    this.DEF[n][11] += f;
  }

  void set_posX (int n, float f) {

    this.DEF[n][0] = f;
  }

  void set_posY (int n, float f) {

    this.DEF[n][1] = f;
  }

  void set_posZ (int n, float f) {

    this.DEF[n][2] = f;
  }

  void set_powX (int n, float f) {

    this.DEF[n][3] = f;
  }

  void set_powY (int n, float f) {

    this.DEF[n][4] = f;
  }

  void set_powZ (int n, float f) {

    this.DEF[n][5] = f;
  }

  void set_scaleX (int n, float f) {

    this.DEF[n][6] = f;
  }

  void set_scaleY (int n, float f) {

    this.DEF[n][7] = f;
  }

  void set_scaleZ (int n, float f) {

    this.DEF[n][8] = f;
  }

  void set_rotX (int n, float f) {

    this.DEF[n][9] = f;
  }


  void set_rotY (int n, float f) {

    this.DEF[n][10] = f;
  }

  void set_rotZ (int n, float f) {

    this.DEF[n][11] = f;
  }

  void set_value (int n, float f) {

    this.DEF[n][12] = f;
  }

  float get_posX (int n) {

    return this.DEF[n][0];
  }

  float get_posY (int n) {

    return this.DEF[n][1];
  }

  float get_posZ (int n) {

    return this.DEF[n][2];
  }

  float get_powX (int n) {

    return this.DEF[n][3];
  }

  float get_powY (int n) {

    return this.DEF[n][4];
  }

  float get_powZ (int n) {

    return this.DEF[n][5];
  }

  float get_scaleX (int n) {

    return this.DEF[n][6];
  }

  float get_scaleY (int n) {

    return this.DEF[n][7];
  }

  float get_scaleZ (int n) {

    return this.DEF[n][8];
  }

  float get_rotX (int n) {

    return this.DEF[n][9];
  }


  float get_rotY (int n) {

    return this.DEF[n][10];
  }

  float get_rotZ (int n) {

    return this.DEF[n][11];
  }

  float get_value (int n) {

    return this.DEF[n][12];
  }

  float get_Distance (int n, float a, float b, float c) {

    float posX = this.DEF[n][0];
    float posY = this.DEF[n][1];
    float posZ = this.DEF[n][2];
    float powX = this.DEF[n][3];
    float powY = this.DEF[n][4];
    float powZ = this.DEF[n][5];
    float scaleX = this.DEF[n][6];
    float scaleY = this.DEF[n][7];
    float scaleZ = this.DEF[n][8];
    float rotX = this.DEF[n][9];
    float rotY = this.DEF[n][10];
    float rotZ = this.DEF[n][11];
    float value = this.DEF[n][12];

    a -= posX;
    b -= posY;
    c -= posZ;

    ///////////////////////// NOT SURE START!

    float y1 = b * funcs.cos_ang(-rotX) - c * funcs.sin_ang(-rotX);
    float z1 = b * funcs.sin_ang(-rotX) + c * funcs.cos_ang(-rotX);
    float x1 = a;

    a = x1;
    b = y1;
    c = z1;

    float z2 = c * funcs.cos_ang(-rotY) - a * funcs.sin_ang(-rotY);
    float x2 = c * funcs.sin_ang(-rotY) + a * funcs.cos_ang(-rotY);
    float y2 = b;

    a = x2;
    b = y2;
    c = z2;
    ///////////////////////// NOT SURE END!

    float x = a * funcs.cos_ang(-rotZ) - b * funcs.sin_ang(-rotZ);
    float y = a * funcs.sin_ang(-rotZ) + b * funcs.cos_ang(-rotZ);
    float z = c;

    x += posX;
    y += posY;
    z += posZ;


    return(pow((pow(abs(x - posX) / scaleX, powX) + pow(abs(y - posY) / scaleY, powY) + pow(abs(z - posZ) / scaleZ, powZ)), (3.0 / (powX + powY + powZ))));
    //return(pow((pow(abs(x - posX) / scaleX, powX) + pow(abs(y - posY) / scaleY, powY) + pow(abs(z - posZ) / scaleZ, powZ)), (3.0 / (powX + powY + powZ))) / value);
    //return(pow((pow(abs(x - posX) / scaleX, powX) + pow(abs(y - posY) / scaleY, powY) + pow(abs(z - posZ) / scaleZ, powZ)), (3.0 / (powX + powY + powZ))) / (value * scaleX * scaleY * scaleZ * 0.001));
    //return(scaleX * scaleY * scaleZ * 0.01 * pow((pow(abs(x - posX) / scaleX, powX) + pow(abs(y - posY) / scaleY, powY) + pow(abs(z - posZ) / scaleZ, powZ)), (3.0 / (powX + powY + powZ))) / value);


  }







  int create (float x, float y, float z, float px, float py, float pz, float sx, float sy, float sz, float tx, float ty, float tz, float v) {

    float[][] newSolid = {
      {
        x, y, z, px, py, pz, sx, sy, sz, tx, ty, tz, v
      }
    };
    this.DEF = (float[][]) concat(this.DEF, newSolid);

    if (allGroups.num > 0) allGroups.Solids[allGroups.num - 1][1] = this.DEF.length - 1;

    return(this.DEF.length - 1);
  }









  int num_visualFaces = 3; // internal - number of faces: XY, YZ, ZX
  int numdisplayAllDegree = 16; //8; // internal - number of each face corners

  private float[][] Vertices;
  private int[][] Faces;

  void draw () {

    this.Faces = new int [this.num_visualFaces * this.DEF.length][this.numdisplayAllDegree];
    this.Vertices = new float [this.num_visualFaces * this.numdisplayAllDegree * this.DEF.length][3];

    if (this.displayAll) {

      WIN3D.graphics.strokeWeight(2);

      for (int f = 0; f < this.DEF.length; f++) {

        float Solid_posX = this.get_posX(f);
        float Solid_posY = this.get_posY(f);
        float Solid_posZ = this.get_posZ(f);
        float Solid_powX = this.get_powX(f);
        float Solid_powY = this.get_powY(f);
        float Solid_powZ = this.get_powZ(f);
        float Solid_scaleX = this.get_scaleX(f);
        float Solid_scaleY = this.get_scaleY(f);
        float Solid_scaleZ = this.get_scaleZ(f);
        float Solid_rotX = this.get_rotX(f);
        float Solid_rotY = this.get_rotY(f);
        float Solid_rotZ = this.get_rotZ(f);
        float Solid_value = this.get_value(f);

        for (int plane_type = 0; plane_type < this.num_visualFaces; plane_type++) {

          WIN3D.graphics.noFill();
          WIN3D.graphics.stroke(0);

          if (plane_type == 0) {
            WIN3D.graphics.stroke(0, 255, 0);
          }
          if (plane_type == 1) {
            WIN3D.graphics.stroke(255, 0, 0);
          }
          if (plane_type == 2) {
            WIN3D.graphics.stroke(0, 0, 255);
          }

          WIN3D.graphics.beginShape();

          float[][] ImageVertex = this.getCorners(plane_type, Solid_posX, Solid_posY, Solid_posZ, Solid_powX, Solid_powY, Solid_powZ, Solid_scaleX, Solid_scaleY, Solid_scaleZ, Solid_rotX, Solid_rotY, Solid_rotZ, Solid_value);

          for (int q = 1; q <= this.numdisplayAllDegree; q++) {

            float x = ImageVertex[q][0];
            float y = ImageVertex[q][1];
            float z = ImageVertex[q][2];

            WIN3D.graphics.vertex(x * OBJECTS_scale * WIN3D.scale, -y * OBJECTS_scale * WIN3D.scale, z * OBJECTS_scale * WIN3D.scale);

            if (q != 0) {

              int vNo = (f * this.num_visualFaces + plane_type) * this.numdisplayAllDegree + q - 1;

              this.Vertices[vNo][0] = x;
              this.Vertices[vNo][1] = y;
              this.Vertices[vNo][2] = z;

              int fNo = (f * this.num_visualFaces + plane_type);

              this.Faces[fNo][q - 1] = vNo;
            }
          }

          WIN3D.graphics.endShape(CLOSE);
        }
      }

      WIN3D.graphics.noStroke();
      WIN3D.graphics.strokeWeight(0);
    }
  }


  float[][] getCorners (int plane_type, float Solid_posX, float Solid_posY, float Solid_posZ, float Solid_powX, float Solid_powY, float Solid_powZ, float Solid_scaleX, float Solid_scaleY, float Solid_scaleZ, float Solid_rotX, float Solid_rotY, float Solid_rotZ, float Solid_value) {

    float[][] ImageVertex = new float [this.numdisplayAllDegree + 1][3];

    for (int q = 0; q <= this.numdisplayAllDegree; q++) {

      float qx = 0;
      float qy = 0;
      float qz = 0;

      if (q != 0) {
        if (plane_type == 0) {
          qx = funcs.cos_ang(q * 360.0 / float(this.numdisplayAllDegree));
          qy = funcs.sin_ang(q * 360.0 / float(this.numdisplayAllDegree));
        }

        if (plane_type == 1) {
          qy = funcs.cos_ang(q * 360.0 / float(this.numdisplayAllDegree));
          qz = funcs.sin_ang(q * 360.0 / float(this.numdisplayAllDegree));
        }

        if (plane_type == 2) {
          qz = funcs.cos_ang(q * 360.0 / float(this.numdisplayAllDegree));
          qx = funcs.sin_ang(q * 360.0 / float(this.numdisplayAllDegree));
        }
      }

      if (q != 0) { // normalizing

        float d = pow(pow(abs(qx), Solid_powX) + pow(abs(qy), Solid_powY) + pow(abs(qz), Solid_powZ), 3.0 / (Solid_powX + Solid_powY + Solid_powZ));

        if (d != 0) {
          qx /= d;
          qy /= d;
          qz /= d;
        }
      }


      float a = qx * Solid_scaleX;
      float b = qy * Solid_scaleY;
      float c = qz * Solid_scaleZ;

      ///////////////////////// NOT SURE START!

      float y1 = b * funcs.cos_ang(Solid_rotX) - c * funcs.sin_ang(Solid_rotX);
      float z1 = b * funcs.sin_ang(Solid_rotX) + c * funcs.cos_ang(Solid_rotX);
      float x1 = a;

      a = x1;
      b = y1;
      c = z1;

      float z2 = c * funcs.cos_ang(Solid_rotY) - a * funcs.sin_ang(Solid_rotY);
      float x2 = c * funcs.sin_ang(Solid_rotY) + a * funcs.cos_ang(Solid_rotY);
      float y2 = b;

      a = x2;
      b = y2;
      c = z2;
      ///////////////////////// NOT SURE END!

      float x = a * funcs.cos_ang(Solid_rotZ) - b * funcs.sin_ang(Solid_rotZ);
      float y = a * funcs.sin_ang(Solid_rotZ) + b * funcs.cos_ang(Solid_rotZ);
      float z = c;


      x += Solid_posX;
      y += Solid_posY;
      z += Solid_posZ;

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
      hitPoint[f][0] = FLOAT_undefined;
      hitPoint[f][1] = FLOAT_undefined;
      hitPoint[f][2] = FLOAT_undefined;
      hitPoint[f][3] = FLOAT_undefined;
    }

    for (int f = 0; f < this.Faces.length; f++) {

      int n = this.Faces[f].length;

      float[] A = this.Vertices[this.Faces[f][0]];
      float[] B = this.Vertices[this.Faces[f][1]];
      float[] C = this.Vertices[this.Faces[f][n - 2]];
      float[] D = this.Vertices[this.Faces[f][n - 1]];

      float[] AC = funcs.vec3_diff(A, C);
      float[] BD = funcs.vec3_diff(B, D);

      float[] face_norm = funcs.vec3_cross(AC, BD);

      float face_offset = 0.25 * ((A[0] + B[0] + C[0] + D[0]) * face_norm[0] + (A[1] + B[1] + C[1] + D[1]) * face_norm[1] + (A[2] + B[2] + C[2] + D[2]) * face_norm[2]);

      float dist2intersect = FLOAT_undefined;

      float R = -funcs.vec3_dot(ray_dir, face_norm);

      if ((R < FLOAT_tiny) && (R > -FLOAT_tiny)) { // the ray is parallel to the plane
        dist2intersect = FLOAT_huge;
      }
      else {
        dist2intersect = (funcs.vec3_dot(ray_pnt, face_norm) - face_offset) / R;

        //if (dist2intersect > 0) {
        if (dist2intersect > FLOAT_tiny) {

          float X_intersect = dist2intersect * ray_dir[0] + ray_pnt[0];
          float Y_intersect = dist2intersect * ray_dir[1] + ray_pnt[1];
          float Z_intersect = dist2intersect * ray_dir[2] + ray_pnt[2];

          float AnglesAll = 0;

          for (int i = 0; i < n; i++) {
            int next_i = (i + 1) % n;

            float[] vect1 = {this.Vertices[this.Faces[f][i]][0] - X_intersect, this.Vertices[this.Faces[f][i]][1] - Y_intersect, this.Vertices[this.Faces[f][i]][2] - Z_intersect};
            float[] vect2 = {this.Vertices[this.Faces[f][next_i]][0] - X_intersect, this.Vertices[this.Faces[f][next_i]][1] - Y_intersect, this.Vertices[this.Faces[f][next_i]][2] - Z_intersect};

            float t = funcs.acos_ang(funcs.vec_dot(funcs.vec3_unit(vect1), funcs.vec3_unit(vect2)));

            AnglesAll += t;
          }

          if (AnglesAll > 359) { // <<<<<<<<<

            hitPoint[f][0] = X_intersect;
            hitPoint[f][1] = Y_intersect;
            hitPoint[f][2] = Z_intersect;
            hitPoint[f][3] = dist2intersect;
          }
        }
      }
    }

    float[] return_point = {-1, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined};

    float pre_dist = FLOAT_undefined;

    for (int f = 0; f < this.Faces.length; f++) {

      if (pre_dist > hitPoint[f][3]) {

        pre_dist = hitPoint[f][3];

        return_point[0] = int(f / this.num_visualFaces);
        return_point[1] = hitPoint[f][0];
        return_point[2] = hitPoint[f][1];
        return_point[3] = hitPoint[f][2];
        return_point[4] = hitPoint[f][3];

      }

    }

    return return_point;
  }



  public void to_XML (XML xml) {

    println("Saving:" + this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    int ni = this.DEF.length;
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
      txt += nf(this.get_powX(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.get_powY(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.get_powZ(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.get_scaleX(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.get_scaleY(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.get_scaleZ(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.get_rotX(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.get_rotY(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.get_rotZ(i), 0, 4).replace(",", "."); // <<<<
      txt += ",";
      txt += nf(this.get_value(i), 0, 4).replace(",", "."); // <<<<

      XML_setContent(child, txt);
    }

    XML_setBoolean(parent, "displayAll", this.displayAll);
    XML_setInt(parent, "pallet_CLR", this.pallet_CLR);
    XML_setInt(parent, "pallet_DIR", this.pallet_DIR);
    XML_setFloat(parent, "pallet_MLT", this.pallet_MLT);
  }


  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);

    int ni = XML_getInt(parent, "ni");

    this.makeEmpty(ni);

    XML[] children = parent.getChildren("item");
    for (int i = 0; i < ni; i++) {

      String txt = XML_getContent(children[i]);
      String[] parts = split(txt, ",");
      this.set_posX(i, float(parts[0]));
      this.set_posY(i, float(parts[1]));
      this.set_posZ(i, float(parts[2]));
      this.set_powX(i, float(parts[3]));
      this.set_powY(i, float(parts[4]));
      this.set_powZ(i, float(parts[5]));
      this.set_scaleX(i, float(parts[6]));
      this.set_scaleY(i, float(parts[7]));
      this.set_scaleZ(i, float(parts[8]));
      this.set_rotX(i, float(parts[9]));
      this.set_rotY(i, float(parts[10]));
      this.set_rotZ(i, float(parts[11]));
    }

    this.displayAll = XML_getBoolean(parent, "displayAll");
    this.pallet_CLR = XML_getInt(parent, "pallet_CLR");
    this.pallet_DIR = XML_getInt(parent, "pallet_DIR");
    this.pallet_MLT = XML_getFloat(parent, "pallet_MLT");
  }

}
