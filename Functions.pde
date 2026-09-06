class solarchvision_Functions {

  private final static String CLASS_STAMP = "Functions";

  final float EPSILON_DIRECTION = 0.001; // to detect parallels.
  final float EPSILON_POSITION = 0.0001; // to detect intersections i.e. in the world coordinate.




  float asin_ang (float a) {
    return ((asin(a)) * 180/PI);
  }

  float acos_ang (float a) {
    return ((acos(a)) * 180/PI);
  }

  float atan_ang (float a) {
    return ((atan(a)) * 180/PI);
  }

  float atan2_ang (float a, float b) {
    return ((atan2(a, b)) * 180/PI);
  }


  float sin_ang (float a) {
    return sin(a * PI / 180);
  }

  float cos_ang (float a) {
    return cos(a * PI / 180);
  }

  float tan_ang (float a) {
    return tan(a * PI / 180);
  }




  float roundTo (float a, float b) {
    float a_floor = (floor (a / (1.0 * b))) * b;
    float a_ceil =  (ceil (a / (1.0 * b))) * b;
    float c;
    if ((a - a_floor) > (a_ceil - a)) {
      c = a_ceil;
    } else {
      c = a_floor;
    }
    return c;
  }


  float[] convert_lonlat2XY (double lon0, double lat0, double lon, double lat) {

    double du = ((lon - lon0) / 180.0) * (PI * DOUBLE_r_Earth);
    double dv = ((lat - lat0) / 180.0) * (PI * DOUBLE_r_Earth);

    float x = (float) du * this.cos_ang((float) lat);
    float y = (float) dv;

    float[] XY = {x, y};

    return XY;
  }


  float lon_lat_dist (double lon1, double lat1, double lon2, double lat2) {

    float dLon = (float) (lon2 - lon1);
    float dLat = (float) (lat2 - lat1);

    float a = this.sin_ang(dLon / 2.0);
    float b = this.sin_ang(dLat / 2.0) * this.sin_ang(dLat / 2.0) +
              this.cos_ang((float) lat1) * this.cos_ang((float) lat2) * a * a;

    return 2 * atan2(sqrt(b), sqrt(1 - b)) * (float) DOUBLE_r_Earth;
  }

  float[] vec_scale (float[] a, float b) {

    float[] d = new float[a.length];
    for (int i = a.length - 1; i > -1; --i) {
      d[i] = b * a[i];
    }

    return d;
  }

  float[] vec3_scale (float[] a, float b) {

    float[] d = {b * a[0], b * a[1], b * a[2]};

    return d;
  }

  float[] vec_sum (float[] a, float[] b) {

    float[] d = new float[a.length];
    for (int i = a.length - 1; i > -1; --i) {
      d[i] = b[i] + a[i];
    }

    return d;
  }

  float[] vec3_sum (float[] a, float[] b) {

    float[] d = {b[0] + a[0], b[1] + a[1], b[2] + a[2]};

    return d;
  }

  float[] vec_diff (float[] a, float[] b) {

    float[] d = new float[a.length];
    for (int i = a.length - 1; i > -1; --i) {
      d[i] = b[i] - a[i];
    }

    return d;
  }

  float[] vec3_diff (float[] a, float[] b) {

    float[] d = {b[0] - a[0], b[1] - a[1], b[2] - a[2]};

    return d;
  }

  float vec_dist (float[] a, float[] b) {

    return this.vec_mag(this.vec_diff(a, b));
  }

  float vec3_dist (float[] a, float[] b) {

    return this.vec3_mag(this.vec3_diff(a, b));
  }


  float vec_mag (float[] a) {

    float d = 0;
    for (int i = a.length - 1; i > -1 ; --i) {
      d += pow(a[i], 2);
    }
    d = pow(d, 0.5);

    return d;
  }

  float vec3_mag (float[] a) {

    return pow(a[0] * a[0] + a[1] * a[1] + a[2] * a[2], 0.5);
  }

  float[] vec_unit (float[] a) {

    float d = this.vec_mag(a);

    float[] b = new float[a.length];
    for (int i = a.length - 1; i > -1; --i) {
      if (d != 0) b[i] = a[i] / d;
      else b[i] = 0;
    }
    return b;
  }

  float[] vec3_unit (float[] a) {

    float d = this.vec3_mag(a);

    float[] b = new float[3];
    for (int i = 0; i < 3; i++) {
      if (d != 0) b[i] = a[i] / d;
      else b[i] = 0;
    }
    return b;
  }

  float vec_dot (float[] a, float b[]) {
    float d = 0;
    for (int i = a.length - 1; i > -1; --i) {
      d += a[i] * b[i];
    }
    return d;
  }

  float vec2_dot (float x1, float y1, float x2, float y2) {
    return x1 * x2 + y1 * y2;
  }

  float vec3_dot (float[] a, float b[]) {

    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
  }

  float[] vec3_cross (float[] a, float b[]) {

    float[] c = new float [3];

    c[0] = a[1] * b[2] - a[2] * b[1];
    c[1] = a[2] * b[0] - a[0] * b[2];
    c[2] = a[0] * b[1] - a[1] * b[0];

    return c;
  }

  float[] centroid (float[][] a) {
    float[] b = new float[a[0].length];
    for (int i = 0; i < a.length; i++) {
      for (int j = 0; j < b.length; j++) {
        b[j] += a[i][j];
      }
    }
    for (int j = 0; j < b.length; j++) {
      b[j] /= float(a.length);
    }
    return b;
  }

  float bilinear (float f_00, float f_10, float f_11, float f_01, float x, float y) {

    float f_xy = f_00 * (1 - x) * (1 - y) + f_10 * x * (1 - y) + f_01 * (1 - x) * y + f_11 * x * y;

    return f_xy;
  }


  boolean isInside_Triangle (float[] P, float[] A, float[] B, float[] C) {

    float pX = P[0] - C[0];
    float pY = P[1] - C[1];
    float pZ = P[2] - C[2];

    float aX = A[0] - C[0];
    float aY = A[1] - C[1];
    float aZ = A[2] - C[2];

    float bX = B[0] - C[0];
    float bY = B[1] - C[1];
    float bZ = B[2] - C[2];

    float AA = aX * aX + aY * aY + aZ * aZ; // this.vec3_dot(a, a);
    float AB = aX * bX + aY * bY + aZ * bZ; // this.vec3_dot(a, b);
    float AP = aX * pX + aY * pY + aZ * pZ; // this.vec3_dot(a, p);
    float BB = bX * bX + bY * bY + bZ * bZ; // this.vec3_dot(b, b);
    float BP = bX * pX + bY * pY + bZ * pZ; // this.vec3_dot(b, p);

    float r = (AA * BB - AB * AB); if (r == 0.0) return false;
    float u = (BB * AP - AB * BP) / r;
    float v = (AA * BP - AB * AP) / r;

    return ((u >= 0) && (v >= 0) && (u + v <= 1));
  }


  boolean isInside_Quadrangle (float[] P, float[] A, float[] B, float[] C, float[] D) {

    float[] G = {0.25 * (A[0] + B[0] + C[0] + D[0]),
                 0.25 * (A[1] + B[1] + C[1] + D[1]),
                 0.25 * (A[2] + B[2] + C[2] + D[2])};

    float pX = P[0] - G[0];
    float pY = P[1] - G[1];
    float pZ = P[2] - G[2];

    float aX = A[0] - G[0];
    float aY = A[1] - G[1];
    float aZ = A[2] - G[2];

    float bX = B[0] - G[0];
    float bY = B[1] - G[1];
    float bZ = B[2] - G[2];

    float AA = aX * aX + aY * aY + aZ * aZ; // this.vec3_dot(a, a);
    float AB = aX * bX + aY * bY + aZ * bZ; // this.vec3_dot(a, b);
    float AP = aX * pX + aY * pY + aZ * pZ; // this.vec3_dot(a, p);
    float BB = bX * bX + bY * bY + bZ * bZ; // this.vec3_dot(b, b);
    float BP = bX * pX + bY * pY + bZ * pZ; // this.vec3_dot(b, p);

    float r = (AA * BB - AB * AB); if (r == 0.0) return false;
    float u = (BB * AP - AB * BP) / r;
    float v = (AA * BP - AB * AP) / r;

    boolean result = ((u >= 0) && (v >= 0) && (u + v <= 1));

    if (result == false) {

      float cX = C[0] - G[0];
      float cY = C[1] - G[1];
      float cZ = C[2] - G[2];

      float CC = cX * cX + cY * cY + cZ * cZ; // this.vec3_dot(c, c);
      float CP = cX * pX + cY * pY + cZ * pZ; // this.vec3_dot(c, p);
      float BC = bX * cX + bY * cY + bZ * cZ; // this.vec3_dot(b, c);

      r = (BB * CC - BC * BC); if (r == 0.0) return false;
      u = (CC * BP - BC * CP) / r;
      v = (BB * CP - BC * BP) / r;

      result = ((u >= 0) && (v >= 0) && (u + v <= 1));

      if (result == false) {

        float dX = D[0] - G[0];
        float dY = D[1] - G[1];
        float dZ = D[2] - G[2];

        float CD = cX * dX + cY * dY + cZ * dZ; // this.vec3_dot(c, d);
        float DD = dX * dX + dY * dY + dZ * dZ; // this.vec3_dot(d, d);
        float DP = dX * pX + dY * pY + dZ * pZ; // this.vec3_dot(d, p);

        r = (CC * DD - CD * CD); if (r == 0.0) return false;
        u = (DD * CP - CD * DP) / r;
        v = (CC * DP - CD * CP) / r;

        result = ((u >= 0) && (v >= 0) && (u + v <= 1));

        if (result == false) {

          float DA = dX * aX + dY * aY + dZ * aZ; // this.vec3_dot(d, a);

          r = (DD * AA - DA * DA); if (r == 0.0) return false;
          u = (AA * DP - DA * AP) / r;
          v = (DD * AP - DA * DP) / r;

          result = ((u >= 0) && (v >= 0) && (u + v <= 1));
        }
      }
    }

    return result;
  }

  boolean isInside_Rectangle (float[] P, float[] A, float[] O, float[] B) { // good for rectangular surfaces namely for selecting allModel2Ds, etc.

    float pX = P[0] - O[0];
    float pY = P[1] - O[1];
    float pZ = P[2] - O[2];

    float aX = A[0] - O[0];
    float aY = A[1] - O[1];
    float aZ = A[2] - O[2];

    float bX = B[0] - O[0];
    float bY = B[1] - O[1];
    float bZ = B[2] - O[2];

    float AA = aX * aX + aY * aY + aZ * aZ; // this.vec3_dot(a, a);
    float AB = aX * bX + aY * bY + aZ * bZ; // this.vec3_dot(a, b);
    float AP = aX * pX + aY * pY + aZ * pZ; // this.vec3_dot(a, p);
    float BB = bX * bX + bY * bY + bZ * bZ; // this.vec3_dot(b, b);
    float BP = bX * pX + bY * pY + bZ * pZ; // this.vec3_dot(b, p);

    float r = (AA * BB - AB * AB); if (r == 0.0) return false;
    float u = (BB * AP - AB * BP) / r;
    float v = (AA * BP - AB * AP) / r;

    return ((u >= 0) && (v >= 0) && (u <= 1) && (v <= 1));
  }

  float[] uvInside_Rectangle (float[] P, float[] A, float[] O, float[] B) { // copy of the function above but it returns u and v

    float pX = P[0] - O[0];
    float pY = P[1] - O[1];
    float pZ = P[2] - O[2];

    float aX = A[0] - O[0];
    float aY = A[1] - O[1];
    float aZ = A[2] - O[2];

    float bX = B[0] - O[0];
    float bY = B[1] - O[1];
    float bZ = B[2] - O[2];

    float AA = aX * aX + aY * aY + aZ * aZ; // this.vec3_dot(a, a);
    float AB = aX * bX + aY * bY + aZ * bZ; // this.vec3_dot(a, b);
    float AP = aX * pX + aY * pY + aZ * pZ; // this.vec3_dot(a, p);
    float BB = bX * bX + bY * bY + bZ * bZ; // this.vec3_dot(b, b);
    float BP = bX * pX + bY * pY + bZ * pZ; // this.vec3_dot(b, p);

    float[] result = {0, 0};

    float r = (AA * BB - AB * AB); if (r == 0.0) return result;
    float u = (BB * AP - AB * BP) / r;
    float v = (AA * BP - AB * AP) / r;

    result[0] = u;
    result[1] = v;

    return result;
  }


  float[][] getSubFace (float[][] base_Vertices, int tessellation, int n) {

    float[][] return_vertices = {
    };

    int totalNumberOfSubs = 1;
    if (tessellation > 0) totalNumberOfSubs = base_Vertices.length * int(this.roundTo(pow(4, tessellation - 1), 1));

    if ((tessellation <= 0) || (n < 0) || (n >= totalNumberOfSubs)) {
      return_vertices = new float [base_Vertices.length][3];

      for (int j = 0; j < base_Vertices.length; j++) {
        return_vertices[j] = base_Vertices[j];
      }
    } else {
      return_vertices = new float [4][3];

      int div = base_Vertices.length;

      int the_first = n % div;
      int the_next = (the_first + 1) % div;
      int the_previous = (the_first + div - 1) % div;

      float[] A = {
        0, 0, 0
      };
      float[] B = {
        0, 0, 0
      };
      float[] C = {
        0, 0, 0
      };
      float[] D = {
        0, 0, 0
      };

      for (int i = 0; i < 3; i++) {

        A[i] = base_Vertices[the_first][i];
        B[i] = 0.5 * (A[i] + base_Vertices[the_next][i]);
        D[i] = 0.5 * (A[i] + base_Vertices[the_previous][i]);

        for (int j = 0; j < base_Vertices.length; j++) {
          C[i] += base_Vertices[j][i] / (1.0 * base_Vertices.length);
        }
      }

      if (tessellation == 1) {
        return_vertices[0] = A;
        return_vertices[1] = B;
        return_vertices[2] = C;
        return_vertices[3] = D;
      } else {

        int section = n / div;
        int res = int(this.roundTo(pow(2, tessellation - 1), 1));
        int u = section / res;
        int v = section % res;

        float x1 = (1.0 * u) / (1.0 * res);
        float y1 = (1.0 * v) / (1.0 * res);
        float x2 = (1.0 * (u + 1)) / (1.0 * res);
        float y2 = (1.0 * (v + 1)) / (1.0 * res);

        float[] P0 = {
          0, 0, 0
        };
        float[] P1 = {
          0, 0, 0
        };
        float[] P2 = {
          0, 0, 0
        };
        float[] P3 = {
          0, 0, 0
        };

        for (int i = 0; i < 3; i++) {
          P0[i] = this.bilinear(A[i], B[i], C[i], D[i], x1, y1);
          P1[i] = this.bilinear(A[i], B[i], C[i], D[i], x2, y1);
          P2[i] = this.bilinear(A[i], B[i], C[i], D[i], x2, y2);
          P3[i] = this.bilinear(A[i], B[i], C[i], D[i], x1, y2);
        }

        //return_vertices[0] = P0;
        //return_vertices[1] = P1;
        //return_vertices[2] = P2;
        //return_vertices[3] = P3;

        //to rotate tri-grid cells:

        int d = ((u % 2) + ((v + 1) % 2)) % 2;
        if (d == 0) {
          return_vertices[0] = P0;
          return_vertices[1] = P1;
          return_vertices[2] = P2;
          return_vertices[3] = P3;
        } else {
          return_vertices[0] = P1;
          return_vertices[1] = P2;
          return_vertices[2] = P3;
          return_vertices[3] = P0;
        }
      }
    }

    return return_vertices;
  }


  boolean is_zero (float val) {
    return (abs(val) < this.EPSILON_POSITION);
  }

  boolean is_zero (float val, float tolerance) {
    return (abs(val) < tolerance);
  }

  boolean arePointsClose(float[] point1, float[] point2) {
    return this.is_zero(this.vec3_mag(this.vec3_diff(point1, point2)), this.EPSILON_POSITION);
  }

  boolean are3PointsIn1Line(float[] point1, float[] point2, float[] point3) {

    return this.is_zero(1.0 - abs(this.vec3_dot(
                                  this.vec3_unit(this.vec3_diff(point1, point2)),
                                  this.vec3_unit(this.vec3_diff(point2, point3)))), this.EPSILON_DIRECTION);
  }

  float[] calculateTriangleNormal(float[] point1, float[] point2, float[] point3) {
    return this.vec3_unit(this.vec3_cross(
                          this.vec3_diff(point1, point2),
                          this.vec3_diff(point2, point3)));
  }


  float[] calculatePolygonNormal(float[][] polygonVertices) {

    float[] polygonNormal = {0, 0, 0};

    int n = polygonVertices.length;

    for (int i = 0; i < n; i++) {
      int i1 = (i + 1) % n;
      int i2 = (i + 2) % n;

      if (false == are3PointsIn1Line(polygonVertices[i],
                                     polygonVertices[i1],
                                     polygonVertices[i2])) {

        polygonNormal = calculateTriangleNormal(polygonVertices[i],
                                                polygonVertices[i1],
                                                polygonVertices[i2]);

        break;
      }
    }

    return polygonNormal;
  }


  boolean isPointInPolygon(float[] point, float[][] polygon_vertices) {

    float[] polygon_normal = calculatePolygonNormal(polygon_vertices);


    int i, next_i;

    // fisrt check at each vertex, if equal to any we return ture
    for (i = 0; i < polygon_vertices.length; i++) {

      if (true == this.is_zero(this.vec3_mag(this.vec3_diff(point, polygon_vertices[i])))) {
        return true;
      }
    }

    float sumAngles = 0.0;
    for (i = 0; i < polygon_vertices.length; i++) {
      next_i = (i + 1) % polygon_vertices.length;

      float[] AM = this.vec3_diff(point, polygon_vertices[i]);
      float[] BM = this.vec3_diff(point, polygon_vertices[next_i]);

      float divisor = this.vec3_mag(AM) * this.vec3_mag(BM);
      if (divisor > 0.0) {

        float acosine = this.vec3_dot(AM, BM) / divisor;
        if (acosine < -1.0) acosine = -1.0;
        else if (acosine > 1.0) acosine = 1.0;

        float angle = acos(acosine); // returns between 0 and PI
        if (false == Float.isNaN(angle)){
          if (this.vec3_dot(this.vec3_cross(AM, BM), polygon_normal) < 0) {
            angle = -angle;
          }
          sumAngles += angle;
        }
      }
    }

    float remainder = (abs(sumAngles) / (2.0 * PI)) % 2.0;
    if (remainder < 0.9999 || remainder > 1.0001) {
      return false;
    }
    return true;
  }



  float[][] cleanShape_removeDuplicateVertices (float[][] vertices_IN) {

    float[][] vertices_OUT =  new float[0][3];
    int n = vertices_IN.length;
    for (int i = 0; i < n; i++) {
      int prev_i = (i - 1 + n) % n;

      if (false == this.is_zero(this.vec3_mag(this.vec3_diff(vertices_IN[i], vertices_IN[prev_i])), 0.001)) { // i.e. 1mm tolerance, here

        float[][] newVertex = {{vertices_IN[i][0], vertices_IN[i][1], vertices_IN[i][2]}};
        vertices_OUT = (float[][]) concat(vertices_OUT, newVertex);
      }
    }

    return vertices_OUT;
  }



  float[][] cleanShape_joinParallelSegments (float[][] vertices_IN) {

    float[][] vertices_OUT =  new float[0][3];
    int n = vertices_IN.length;
    for (int i = 0; i < n; i++) {
      int prev_i = (i - 1 + n) % n;
      int next_i = (i + 1) % n;

      if (false == are3PointsIn1Line(vertices_IN[prev_i],
                                     vertices_IN[i],
                                     vertices_IN[next_i])) {

        float[][] newVertex = {{vertices_IN[i][0], vertices_IN[i][1], vertices_IN[i][2]}};
        vertices_OUT = (float[][]) concat(vertices_OUT, newVertex);
      }
    }

    return vertices_OUT;
  }



  float[][] optimizeVertices (float[][] vertices_IN) {
    float[][] vertices_TMP = this.cleanShape_removeDuplicateVertices(vertices_IN);
    float[][] vertices_OUT = this.cleanShape_joinParallelSegments(vertices_TMP);

    return vertices_OUT;
  };




  float calculatePolygonArea(float[][] polygonVertices) {

   float[] sumVect = {0, 0, 0};

    for (int i = 0; i < polygonVertices.length; i++) {
      int next_i = (i + 1) % polygonVertices.length;

      float[] A = this.vec3_cross(polygonVertices[i], polygonVertices[next_i]);
      float[] B = sumVect;

      sumVect = this.vec3_sum(A, B);
    }

    return 0.5 * this.vec3_mag(sumVect); // unit m2
  }


  boolean isPointOnSegment(float[] point, float[] pStart, float[] pEnd) {

    float L1 = this.vec3_mag(this.vec3_diff(pStart, point));
    float L2 = this.vec3_mag(this.vec3_diff(point, pEnd));
    float L3 = this.vec3_mag(this.vec3_diff(pStart, pEnd));

    return this.is_zero(L3 -(L2 + L1), this.EPSILON_POSITION);
  }


  float[] getBetween(float[] point1, float[] point2, float ratio) {

    return this.vec3_sum(this.vec3_scale(point1, ratio), this.vec3_scale(point2, 1.0 - ratio));
  }

  float[] intersect_segmentXsegment (float[] A1, float[] A2, float[] B1, float[] B2) {

    float[] nullPoint = {FLOAT_undefined, FLOAT_undefined, FLOAT_undefined};

    if (arePointsClose(A1, B1)) return getBetween(A1, B1, 0.5);
    if (arePointsClose(A1, B2)) return getBetween(A1, B2, 0.5);
    if (arePointsClose(A2, B1)) return getBetween(A2, B1, 0.5);
    if (arePointsClose(A2, B2)) return getBetween(A2, B2, 0.5);

    if (isPointOnSegment(A1, B1, B2)) return A1;
    if (isPointOnSegment(A2, B1, B2)) return A2;
    if (isPointOnSegment(B1, A1, A2)) return B1;
    if (isPointOnSegment(B2, A1, A2)) return B2;

    float[] Axis_A = this.vec3_unit(this.vec3_diff(A1, A2));
    float[] Axis_B = this.vec3_unit(this.vec3_diff(B1, B2));

    if (true == this.is_zero(1 - Math.abs(this.vec3_dot(this.vec3_unit(Axis_A), this.vec3_unit(Axis_B))), this.EPSILON_DIRECTION)) {

      return nullPoint;
    }

    float[] cross_vect = this.vec3_cross(Axis_A, Axis_B);
    float cross_dist = this.vec3_mag(cross_vect);

    if (this.is_zero(cross_dist)) {

      return nullPoint;
    }

    float rA = this.vec3_dot(this.vec3_cross(this.vec3_diff(B1, A1), Axis_B), cross_vect) / (cross_dist * cross_dist);
    float rB = this.vec3_dot(this.vec3_cross(this.vec3_diff(B1, A1), Axis_A), cross_vect) / (cross_dist * cross_dist);

    float[] result_A = this.vec3_sum(A1, this.vec3_scale(Axis_A, rA));
    float[] result_B = this.vec3_sum(B1, this.vec3_scale(Axis_B, rB));



    if (false == this.is_zero(this.vec3_mag(this.vec3_diff(result_A, result_B)), this.EPSILON_POSITION)) {

      return nullPoint;
    }

    float[] result_AxB = getBetween(result_A , result_B, 0.5);

    if (false == isPointOnSegment(result_AxB, A1, A2)) return nullPoint;
    if (false == isPointOnSegment(result_AxB, B1, B2)) return nullPoint;

    return result_AxB;
  }









  float EquationOfTime (float DateAngle) {
    return 0.01 * (9.87 * this.sin_ang(2 * DateAngle) - 7.53 * this.cos_ang(DateAngle) - 1.5 * this.sin_ang(DateAngle));
  }

  float correctHourAngle (float DateAngle, float HourAngleOrigin) {
    return EquationOfTime(DateAngle) + HourAngleOrigin;
  }

  float[] SunPositionRadiation (float DateAngle, float HourAngleOrigin, float CloudCover) {
    float HourAngle = correctHourAngle(DateAngle, HourAngleOrigin);

    float Declination = 23.45 * this.sin_ang(DateAngle - 180.0);

    float a = this.sin_ang(Declination);
    float b = this.cos_ang(Declination) * -this.cos_ang(15.0 * HourAngleOrigin);
    float c = this.cos_ang(Declination) *  this.sin_ang(15.0 * HourAngleOrigin);

    float x = c;
    float y = -(a * this.cos_ang(STATION.getLatitude()) + b * this.sin_ang(STATION.getLatitude()));
    float z = -a * this.sin_ang(STATION.getLatitude()) + b * this.cos_ang(STATION.getLatitude());

    float Io = 1367.0; // W/m²
    Io = Io * (1.0 - (0.0334 * this.sin_ang(DateAngle)));

    float ALT_ = (this.asin_ang(z)) * PI / 180;
    float ALT_true = ALT_ + 0.061359 * (0.1594 + 1.1230 * ALT_ + 0.065656 * ALT_ * ALT_) / (1 + 28.9344 * ALT_ + 277.3971 * ALT_ * ALT_);

    float PPo = pow(FLOAT_e, (-STATION.getElevation() / 8435.2));
    float Bb = ((this.sin_ang (ALT_true * 180 / PI)) + (0.50572 * pow((57.29578 * ALT_true + 6.07995), -1.6364)));
    float m = PPo / Bb;

    float StationTurbidity;

    StationTurbidity = (2.0 - 0.2) * (0.1 * CloudCover) + 0.2;

    float AtmosphereRatio;
    if (z < 0.01) AtmosphereRatio = 0.0;
    else AtmosphereRatio = pow(FLOAT_e, (-m * StationTurbidity));

    float Idirect = Io * AtmosphereRatio; // Optical air mass: global Meteorological Database for Engineers, Planners and Education; Version 5.00 - Edition 2003

    float Idiffuse;
    if (z < 0.01) Idiffuse = 0.0;
    else Idiffuse = ((0.5 + 0.5 * (0.1 * CloudCover)) * z * (Io - Idirect)) / (1.0 - 1.4 * z * log(Idirect / Io));

    float[] return_array = {
      0, x, y, z, Idirect, Idiffuse
    };
    return return_array;
  }

  float[] SunPosition (float Latitude, float DateAngle, float HourAngleOrigin) {
    float HourAngle = correctHourAngle(DateAngle, HourAngleOrigin);

    float Declination = 23.45 * this.sin_ang(DateAngle - 180.0);

    float a = this.sin_ang(Declination);
    float b = this.cos_ang(Declination) * -this.cos_ang(15.0 * HourAngle);
    float c = this.cos_ang(Declination) *  this.sin_ang(15.0 * HourAngle);

    float x = c;
    float y = -(a * this.cos_ang(Latitude) + b * this.sin_ang(Latitude));
    float z = -a * this.sin_ang(Latitude) + b * this.cos_ang(Latitude);

    float[] return_array = {
      0, x, y, z
    };
    return return_array;
  }

  float Sunrise (float Latitude, float DateAngle) {

    float a = 0;

    float Declination = 23.5 * this.sin_ang(DateAngle - 180.0);

    float q = -(this.tan_ang(Declination) * this.tan_ang(Latitude));
    if (q > 1.0) {
      a = 0.0;
    } else if (q < -1.0) {
      a = 24.0;
    } else a = this.acos_ang(q) / 15.0;

    return (a - EquationOfTime(DateAngle));
  }

  float Sunset (float Latitude, float DateAngle) {

    return 24.0 - this.Sunrise(Latitude, DateAngle) - 2 * EquationOfTime(DateAngle);
  }

  float DayTime (float Latitude, float DateAngle) {
    return abs((this.Sunset(Latitude, DateAngle)) - (this.Sunrise(Latitude, DateAngle)));
  }

}
