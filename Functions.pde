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
    float bb = 1.0 * b;
    float a_floor = floor(a / bb) * bb;
    float a_ceil = ceil(a / bb) * bb;
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
    float sinHalfDLat = this.sin_ang(dLat / 2.0);
    float b = sinHalfDLat * sinHalfDLat +
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
      d += a[i] * a[i];
    }
    return sqrt(d);
  }

  float vec3_mag (float[] a) {
    return sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2]);
  }

  float[] vec_unit (float[] a) {
    float d = this.vec_mag(a);
    float[] b = new float[a.length];
    if (d != 0) {
      float invD = 1.0 / d;
      for (int i = a.length - 1; i > -1; --i) {
        b[i] = a[i] * invD;
      }
    }
    return b;
  }

  float[] vec3_unit (float[] a) {
    float d = this.vec3_mag(a);
    float[] b = new float[3];
    if (d != 0) {
      float invD = 1.0 / d;
      for (int i = 0; i < 3; i++) {
        b[i] = a[i] * invD;
      }
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
    float invN = 1.0 / float(a.length);
    for (int j = 0; j < b.length; j++) {
      b[j] *= invN;
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
    if (tessellation > 0) totalNumberOfSubs = base_Vertices.length * (1 << (2 * (tessellation - 1)));

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
      float invDiv = 1.0 / div;
      for (int i = 0; i < 3; i++) {
        A[i] = base_Vertices[the_first][i];
        B[i] = 0.5 * (A[i] + base_Vertices[the_next][i]);
        D[i] = 0.5 * (A[i] + base_Vertices[the_previous][i]);
        for (int j = 0; j < base_Vertices.length; j++) {
          C[i] += base_Vertices[j][i] * invDiv;
        }
      }

      if (tessellation == 1) {
        return_vertices[0] = A;
        return_vertices[1] = B;
        return_vertices[2] = C;
        return_vertices[3] = D;
      } else {
        int section = n / div;
        int res = 1 << (tessellation - 1);
        int u = section / res;
        int v = section % res;
        float invRes = 1.0 / res;
        float x1 = u * invRes;
        float y1 = v * invRes;
        float x2 = (u + 1) * invRes;
        float y2 = (v + 1) * invRes;
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
    float dx = point2[0] - point1[0];
    float dy = point2[1] - point1[1];
    float dz = point2[2] - point1[2];
    float tol = this.EPSILON_POSITION;
    return (dx * dx + dy * dy + dz * dz) < (tol * tol);
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
      if (false == are3PointsIn1Line(
        polygonVertices[i],
        polygonVertices[i1],
        polygonVertices[i2]
      )) {
        polygonNormal = calculateTriangleNormal(
          polygonVertices[i],
          polygonVertices[i1],
          polygonVertices[i2]
        );
        break;
      }
    }
    return polygonNormal;
  }

  float[][] cleanShape_removeDuplicateVertices (float[][] vertices_IN) {
    int n = vertices_IN.length;
    float[][] buffer = new float[n][];
    int count = 0;
    for (int i = 0; i < n; i++) {
      int prev_i = (i - 1 + n) % n;
      if (false == this.is_zero(this.vec3_mag(this.vec3_diff(vertices_IN[i], vertices_IN[prev_i])), 0.001)) { // i.e. 1mm tolerance, here
        buffer[count++] = new float[]{vertices_IN[i][0], vertices_IN[i][1], vertices_IN[i][2]};
      }
    }
    float[][] vertices_OUT = new float[count][];
    System.arraycopy(buffer, 0, vertices_OUT, 0, count);
    return vertices_OUT;
  }

  float[][] cleanShape_joinParallelSegments (float[][] vertices_IN) {
    int n = vertices_IN.length;
    float[][] buffer = new float[n][];
    int count = 0;
    for (int i = 0; i < n; i++) {
      int prev_i = (i - 1 + n) % n;
      int next_i = (i + 1) % n;
      if (false == are3PointsIn1Line(
        vertices_IN[prev_i],
        vertices_IN[i],
        vertices_IN[next_i]
      )) {
        buffer[count++] = new float[]{vertices_IN[i][0], vertices_IN[i][1], vertices_IN[i][2]};
      }
    }
    float[][] vertices_OUT = new float[count][];
    System.arraycopy(buffer, 0, vertices_OUT, 0, count);
    return vertices_OUT;
  }

  float[][] optimizeVertices (float[][] vertices_IN) {
    float[][] vertices_TMP = this.cleanShape_removeDuplicateVertices(vertices_IN);
    float[][] vertices_OUT = this.cleanShape_joinParallelSegments(vertices_TMP);
    return vertices_OUT;
  };

  float calculatePolygonArea(float[][] polygonVertices) {
    float sx = 0, sy = 0, sz = 0;
    int n = polygonVertices.length;
    for (int i = 0; i < n; i++) {
      int next_i = (i + 1) % n;
      float[] p1 = polygonVertices[i];
      float[] p2 = polygonVertices[next_i];
      sx += p1[1] * p2[2] - p1[2] * p2[1];
      sy += p1[2] * p2[0] - p1[0] * p2[2];
      sz += p1[0] * p2[1] - p1[1] * p2[0];
    }
    return 0.5 * sqrt(sx * sx + sy * sy + sz * sz); // unit m2
  }

  boolean isPointOnSegment(float[] point, float[] pStart, float[] pEnd) {
    float L1 = this.vec3_mag(this.vec3_diff(pStart, point));
    float L2 = this.vec3_mag(this.vec3_diff(point, pEnd));
    float L3 = this.vec3_mag(this.vec3_diff(pStart, pEnd));
    return this.is_zero(L3 -(L2 + L1), this.EPSILON_POSITION);
  }

  float[] getBetween(float[] point1, float[] point2, float ratio) {
    float inv = 1.0 - ratio;
    return new float[] {
      point1[0] * ratio + point2[0] * inv,
      point1[1] * ratio + point2[1] * inv,
      point1[2] * ratio + point2[2] * inv
    };
  }

  float[] intersect_segmentXsegment (float[] A1, float[] A2, float[] B1, float[] B2) {
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
    if (true == this.is_zero(1 - Math.abs(this.vec3_dot(Axis_A, Axis_B)), this.EPSILON_DIRECTION)) {
      return new float[] {FLOAT_undefined, FLOAT_undefined, FLOAT_undefined};
    }
    float[] cross_vect = this.vec3_cross(Axis_A, Axis_B);
    float cross_dist = this.vec3_mag(cross_vect);
    if (this.is_zero(cross_dist)) {
      return new float[] {FLOAT_undefined, FLOAT_undefined, FLOAT_undefined};
    }
    float invCrossDistSq = 1.0 / (cross_dist * cross_dist);
    float[] diffB1A1 = this.vec3_diff(B1, A1);
    float rA = this.vec3_dot(this.vec3_cross(diffB1A1, Axis_B), cross_vect) * invCrossDistSq;
    float rB = this.vec3_dot(this.vec3_cross(diffB1A1, Axis_A), cross_vect) * invCrossDistSq;
    float[] result_A = this.vec3_sum(A1, this.vec3_scale(Axis_A, rA));
    float[] result_B = this.vec3_sum(B1, this.vec3_scale(Axis_B, rB));
    if (false == this.is_zero(this.vec3_mag(this.vec3_diff(result_A, result_B)), this.EPSILON_POSITION)) {
      return new float[] {FLOAT_undefined, FLOAT_undefined, FLOAT_undefined};
    }
    float[] result_AxB = getBetween(result_A , result_B, 0.5);
    if (false == isPointOnSegment(result_AxB, A1, A2)) return new float[] {FLOAT_undefined, FLOAT_undefined, FLOAT_undefined};
    if (false == isPointOnSegment(result_AxB, B1, B2)) return new float[] {FLOAT_undefined, FLOAT_undefined, FLOAT_undefined};
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
    float cosDeclination = this.cos_ang(Declination);
    float a = this.sin_ang(Declination);
    float hourAngle15 = 15.0 * HourAngle;
    float b = cosDeclination * -this.cos_ang(hourAngle15);
    float c = cosDeclination * this.sin_ang(hourAngle15);
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
    float cosDeclination = this.cos_ang(Declination);
    float a = this.sin_ang(Declination);
    float hourAngle15 = 15.0 * HourAngle;
    float b = cosDeclination * -this.cos_ang(hourAngle15);
    float c = cosDeclination * this.sin_ang(hourAngle15);
    float x = c;
    float y = -(a * this.cos_ang(Latitude) + b * this.sin_ang(Latitude));
    float z = -a * this.sin_ang(Latitude) + b * this.cos_ang(Latitude);
    float[] return_array = {
      0, x, y, z
    };
    return return_array;
  }

  private float sunriseHourAngle_Raw (float Latitude, float DateAngle) {
    float Declination = 23.5 * this.sin_ang(DateAngle - 180.0);
    float q = -(this.tan_ang(Declination) * this.tan_ang(Latitude));
    if (q > 1.0) {
      return 0.0;
    } else if (q < -1.0) {
      return 24.0;
    }
    return this.acos_ang(q) / 15.0;
  }

  float Sunrise (float Latitude, float DateAngle) {
    return this.sunriseHourAngle_Raw(Latitude, DateAngle) - EquationOfTime(DateAngle);
  }

  float Sunset (float Latitude, float DateAngle) {
    return 24.0 - this.sunriseHourAngle_Raw(Latitude, DateAngle) - EquationOfTime(DateAngle);
  }

  float DayTime (float Latitude, float DateAngle) {
    float raw = this.sunriseHourAngle_Raw(Latitude, DateAngle);
    float eot = EquationOfTime(DateAngle);
    float sunrise = raw - eot;
    float sunset = 24.0 - raw - eot;
    return abs(sunset - sunrise);
  }
}
