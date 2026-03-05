class solarchvision_Polylines {

  private final static String CLASS_STAMP = "Polylines";

  solarchvision_Polylines () { // constructor
    makeEmpty(0);
  }

  boolean displayAll = true;

  int[][] nodes;
  int[][] options;

  void makeEmpty (int n) {

    this.nodes = new int [n][0];
    this.options = new int [n][6];

    if (allGroups != null) {
      for (int q = 0; q < allGroups.num; q++) {
        allGroups.Polylines[q][0] = 0;
        allGroups.Polylines[q][1] = -1;
      }
    }

    if (Select3D != null) {
      Select3D.deselect_Groups();
      Select3D.deselect_Polylines();
    }

    SOLARCHVISION_model_changed();
  }

  int getMaterial (int n) {
    return this.options[n][0];
  }

  int getTessellation (int n) {
    return this.options[n][1];
  }

  int getLayer (int n) {
    return this.options[n][2];
  }

  int getVisibility (int n) {
    return this.options[n][3];
  }

  int getWeight (int n) {
    return this.options[n][4];
  }

  int getClose (int n) {
    return this.options[n][5];
  }

  void setMaterial (int n, int material) {
    this.options[n][0] = material;
  }

  void setTessellation (int n, int tessellation) {
    this.options[n][1] = tessellation;
  }

  void setLayer (int n, int layer) {
    this.options[n][2] = layer;
  }

  void setVisibility (int n, int visibility) {
    this.options[n][3] = visibility;
  }

  void setWeight (int n, int weight) {
    this.options[n][4] = weight;
  }

  void setClose (int n, int close) {
    this.options[n][5] = close;
  }



  void beginNewPolyline () {

    int[] newPolyline_nodes = {};

    this.create(newPolyline_nodes);
  }


  void add_VertexToLastPolyline (float x, float y, float z) {

    int n = this.nodes.length - 1;

    int[] newVertex = {
      allPoints.create(x, y, z)
    };

    this.nodes[n] = (int[]) concat(this.nodes[n], newVertex);

  }


  int create (int[] f) {

    {

      int[][] newPolyline_options = {
        {
          current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed
        }
      };

      this.options =  (int[][]) concat(this.options, newPolyline_options);

      int[][] newPolyline_nodes = {
        f
      };

      this.nodes = (int[][]) concat(this.nodes, newPolyline_nodes);
    }

    if (allGroups.num > 0) allGroups.Polylines[allGroups.num - 1][1] = this.nodes.length - 1;

    return(this.nodes.length - 1);
  }


  void add_Polyline (int m, int tes, int lyr, int vsb, int wgt, int clz, float[][] points) {

    current_Material = m;
    current_Tessellation = tes;
    current_Layer = lyr;
    current_Visibility = vsb;
    current_Weight = wgt;
    current_Closed = clz;

    int[] newPolyline_nodes = new int[points.length];

    for (int i = 0; i < points.length; i++) {
      newPolyline_nodes[i] = allPoints.create(points[i][0], points[i][1], points[i][2]);
    }

    this.create(newPolyline_nodes);
  }


  void add_Arc (int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float r, int n, float rot, float TotalAngle) {

    float AngleStep = TotalAngle / float(n);
    int EndOfLoop = n;
    if (TotalAngle % 360 == 0) {
      EndOfLoop -= 1;
      clz = 1; // for right closing of a circle
    }

    current_Material = m;
    current_Tessellation = tes;
    current_Layer = lyr;
    current_Visibility = vsb;
    current_Weight = wgt;
    current_Closed = clz;


    int[] newPolyline_nodes = {
      allPoints.create(cx + r * funcs.cos_ang(0), cy + r * funcs.sin_ang(0), cz)
    };
    for (int i = 1; i <= EndOfLoop; i++) {
      float t = i * AngleStep + rot;
      int[] f = {
        allPoints.create(cx + r * funcs.cos_ang(t), cy + r * funcs.sin_ang(t), cz)
      };
      newPolyline_nodes = concat(newPolyline_nodes, f);
    }

    this.create(newPolyline_nodes);
  }



  void draw (int target_window) {


    if (allFaces.displayAll) {

      if (target_window == TypeWindow.WIN3D) {

        WIN3D.graphics.strokeWeight(3);

        WIN3D.graphics.noFill();

        for (int f = 0; f < this.nodes.length; f++) {

          int vsb = this.getVisibility(f);

          if (vsb > 0) {

            int mt = this.getMaterial(f);

            float[] COL = {
              allMaterials.Color[mt][0], allMaterials.Color[mt][1], allMaterials.Color[mt][2], allMaterials.Color[mt][3]
            };

            float weight = 0.1 * this.getWeight(f);

            WIN3D.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);

            int tessellation = int(pow(2, this.getTessellation(f)));

            // so that single line to appear!
            if((tessellation == 1) && (this.nodes[f].length == 2)) tessellation = 2;

            float[][] base_Vertices = new float [this.nodes[f].length][3];
            for (int j = 0; j < this.nodes[f].length; j++) {
              int vNo = this.nodes[f][j];
              base_Vertices[j][0] = allPoints.getX(vNo);
              base_Vertices[j][1] = allPoints.getY(vNo);
              base_Vertices[j][2] = allPoints.getZ(vNo);
            }


            WIN3D.graphics.beginShape();

            int div = base_Vertices.length;

            for (int j = 0; j < base_Vertices.length; j++) {

              int drawSegment = 1;

              int nA = j % div;
              int nB = (j + 1)  % div;
              int nB_after = (j + 2) % div;
              int nA_before = (j - 1 + div) % div;

              if (this.getClose(f) == 0) { // if not closed

                if (nB_after < nB) nB_after = nB;
                if (nA_before > nA) nA_before = nA;

                if (j == base_Vertices.length - 1) drawSegment = 0;
              }

              if (drawSegment == 1) {

                for (int q = 0; q <= tessellation; q++) {

                  float[] P = {0, 0, 0};

                  for (int i = 0; i < 3; i++) {
                    P[i] = ((tessellation - q) * base_Vertices[nA][i] + q * base_Vertices[nB][i]) / float(tessellation);
                  }


                  float[] ANG_start = {0, 0, 0};
                  float[] ANG_end = {0, 0, 0};

                  for (int i = 0; i < 3; i++) {
                    ANG_start[i] = base_Vertices[nA][i] - base_Vertices[nA_before][i];

                    ANG_end[i] = base_Vertices[nB][i] - base_Vertices[nB_after][i];
                  }

                  if ((ANG_start[0] != 0) || (ANG_start[1] != 0) || (ANG_start[2] != 0)) {
                    ANG_start = funcs.vec3_unit(ANG_start);
                  }
                  if ((ANG_end[0] != 0) || (ANG_end[1] != 0) || (ANG_end[2] != 0)) {
                    ANG_end = funcs.vec3_unit(ANG_end);
                  }


                  float dist_start = dist(P[0], P[1], P[2], base_Vertices[nA][0], base_Vertices[nA][1], base_Vertices[nA][2]);
                  float dist_end = dist(P[0], P[1], P[2], base_Vertices[nB][0], base_Vertices[nB][1], base_Vertices[nB][2]);

                  for (int i = 0; i < 3; i++) {
                    ANG_start[i] *= dist_start;
                    ANG_end[i] *= dist_end;
                  }

                  for (int i = 0; i < 3; i++) {
                    P[i] += weight * ((tessellation - q) * ANG_start[i] + q * ANG_end[i]) / float(tessellation);
                  }



                  WIN3D.graphics.vertex(P[0] * OBJECTS_scale * WIN3D.scale, -(P[1] * OBJECTS_scale * WIN3D.scale), P[2] * OBJECTS_scale * WIN3D.scale);

                }
              }

            }

            if (this.getClose(f) == 0) { // if not closed
              WIN3D.graphics.endShape();
            }
            else {
              WIN3D.graphics.endShape(CLOSE);
            }


          }
        }

        WIN3D.graphics.strokeWeight(0);
      }
    }
  }




  float[] intersect (float[] ray_pnt, float[] ray_dir) {

    float[] ray_normal = funcs.vec3_unit(ray_dir);

    float[][] hitPoint = new float [this.nodes.length][7];

    for (int f = 0; f < this.nodes.length; f++) {
      hitPoint[f][0] = FLOAT_undefined;
      hitPoint[f][1] = FLOAT_undefined;
      hitPoint[f][2] = FLOAT_undefined;
      hitPoint[f][3] = FLOAT_undefined;
      hitPoint[f][4] = FLOAT_undefined;
      hitPoint[f][5] = FLOAT_undefined;
      hitPoint[f][6] = FLOAT_undefined;
    }

    for (int f = 0; f < this.nodes.length; f++) {

      int n = this.nodes[f].length;

      if (n > 2) {

        int vsb = this.getVisibility(f);

        if (vsb > 0) {

          float X_intersect = FLOAT_undefined;
          float Y_intersect = FLOAT_undefined;
          float Z_intersect = FLOAT_undefined;
          float dist2intersect = FLOAT_undefined;
          float[] face_norm = {0,0,0};

          boolean InPoly = false;

          if (n < 5) { // works if n==3 or n==4

            float[] A = allPoints.getPosition(this.nodes[f][0]);
            float[] B = allPoints.getPosition(this.nodes[f][1]);
            float[] C = allPoints.getPosition(this.nodes[f][n - 2]);
            float[] D = allPoints.getPosition(this.nodes[f][n - 1]);

            float[] AC = funcs.vec3_diff(A, C);
            float[] BD = funcs.vec3_diff(B, D);

            face_norm = funcs.vec3_cross(AC, BD);

            float face_offset = 0.25 * ((A[0] + B[0] + C[0] + D[0]) * face_norm[0] +
                                        (A[1] + B[1] + C[1] + D[1]) * face_norm[1] +
                                        (A[2] + B[2] + C[2] + D[2]) * face_norm[2]);

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

                if (n == 4) InPoly = funcs.isInside_Quadrangle(P, A, B, C, D);
                else InPoly = funcs.isInside_Triangle(P, A, B, D); // note D is the last vertex while C=B in this case

              }
            }
          }
          else {

            int[] tmpPolyline = new int[n];
            float[] G = {
              0, 0, 0
            };
            for (int j = 0; j < n; j++) {
              tmpPolyline[j] = this.nodes[f][j];
              G[0] += allPoints.getX(tmpPolyline[j]) / float(n);
              G[1] += allPoints.getY(tmpPolyline[j]) / float(n);
              G[2] += allPoints.getZ(tmpPolyline[j]) / float(n);
            }

            for (int j = 0; j < n; j++) {

              int j_next = (j + 1) % n;

              float[] A = {
                allPoints.getX(this.nodes[f][j]),
                allPoints.getY(this.nodes[f][j]),
                allPoints.getZ(this.nodes[f][j])
              };

              float[] B = {
                allPoints.getX(this.nodes[f][j_next]),
                allPoints.getY(this.nodes[f][j_next]),
                allPoints.getZ(this.nodes[f][j_next])
              };

              float[] AG = funcs.vec3_diff(A, G);
              float[] BG = funcs.vec3_diff(B, G);

              face_norm = funcs.vec3_cross(AG, BG);

              float face_offset = (1.0 / 3.0) * ((A[0] + B[0] + G[0]) * face_norm[0] +
                                                 (A[1] + B[1] + G[1]) * face_norm[1] +
                                                 (A[2] + B[2] + G[2]) * face_norm[2]);

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

                  InPoly = funcs.isInside_Triangle(P, A, B, G);

                }
              }

              if (InPoly) break;
            }
          }

          if (InPoly) {
            hitPoint[f][0] = X_intersect;
            hitPoint[f][1] = Y_intersect;
            hitPoint[f][2] = Z_intersect;
            hitPoint[f][3] = dist2intersect;
            hitPoint[f][4] = face_norm[0];
            hitPoint[f][5] = face_norm[1];
            hitPoint[f][6] = face_norm[2];
          }

        }
      }
    }

    float[] return_point = {-1, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined};

    float pre_dist = FLOAT_undefined;

    for (int f = 0; f < this.nodes.length; f++) {

      if (pre_dist > hitPoint[f][3]) {

        pre_dist = hitPoint[f][3];

        return_point[0] = f;
        return_point[1] = hitPoint[f][0];
        return_point[2] = hitPoint[f][1];
        return_point[3] = hitPoint[f][2];
        return_point[4] = hitPoint[f][3];
        return_point[5] = hitPoint[f][4];
        return_point[6] = hitPoint[f][5];
        return_point[7] = hitPoint[f][6];

      }

    }

    return return_point;
  }





  public void to_XML (XML xml) {

    println("Saving:" + this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setInt(parent, "ni", this.nodes.length);
    for (int i = 0; i < this.nodes.length; i++) {
      XML child = parent.addChild("item");
      XML_setInt(child, "id", i);
      String txt = "";
      for (int j = 0; j < this.nodes[i].length; j++) {
        txt += nf(this.nodes[i][j], 0);
        if (j < this.nodes[i].length - 1) txt += ",";
      }
      XML_setContent(child, txt);

      XML_setInt(child, "material", this.getMaterial(i));
      XML_setInt(child, "tessellation", this.getTessellation(i));
      XML_setInt(child, "layer", this.getLayer(i));
      XML_setInt(child, "visibility", this.getVisibility(i));
      XML_setInt(child, "weight", this.getWeight(i));
      XML_setInt(child, "close", this.getClose(i));
    }

    XML_setBoolean(parent, "displayAll", this.displayAll);

  }


  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);
    int ni = XML_getInt(parent, "ni");

    this.makeEmpty(ni);
    this.nodes = new int [0][0];

    XML[] children = parent.getChildren("item");

    for (int i = 0; i < ni; i++) {
      String txt = XML_getContent(children[i]);
      String[] parts = split(txt, ",");
      int nj = parts.length;
      int[][] newItem = new int [1][nj];
      for (int j = 0; j < nj; j++) {
        newItem[0][j] = int(parts[j]);
      }
      this.nodes = (int[][]) concat(this.nodes, newItem);

      this.setMaterial(i, children[i].getInt("material"));
      this.setTessellation(i, children[i].getInt("tessellation"));
      this.setLayer(i, children[i].getInt("layer"));
      this.setVisibility(i, children[i].getInt("visibility"));
      this.setWeight(i, children[i].getInt("weight"));
      this.setClose(i, children[i].getInt("close"));
    }

    this.displayAll = XML_getBoolean(parent, "displayAll");

  }

}
