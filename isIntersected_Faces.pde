int SOLARCHVISION_isIntersected_Faces (float[] ray_pnt, float[] ray_dir, int firstGuess) {

  int hit = 0;
  int numFaces = allFaces.nodes.length;
  float[] P = new float[3]; // reused scratch buffer, filled in-place below

  // Walk faces starting at firstGuess, wrapping around, without using modulo.
  outer:
  for (int pass = 0; pass < 2; pass++) {
    int start = (pass == 0) ? firstGuess : 0;
    int end = (pass == 0) ? numFaces : firstGuess;

    for (int f = start; f < end; f++) {
      if (f == 0) continue;

      int[] faceNodes = allFaces.nodes[f];
      int n = faceNodes.length;
      if (n <= 2) continue;

      int vsb = allFaces.getVisibility(f);
      if (vsb <= 0) continue;

      boolean InPoly = false;

      if (n < 5) { // works if n==3 or n==4
        float[] A = allPoints.getPosition(faceNodes[0]);
        float[] B = allPoints.getPosition(faceNodes[1]);
        float[] C = allPoints.getPosition(faceNodes[n - 2]);
        float[] D = allPoints.getPosition(faceNodes[n - 1]);

        // face_norm = (A - C) x (B - D), inlined to avoid two extra allocations
        float ACx = A[0] - C[0], ACy = A[1] - C[1], ACz = A[2] - C[2];
        float BDx = B[0] - D[0], BDy = B[1] - D[1], BDz = B[2] - D[2];
        float nx = ACy * BDz - ACz * BDy;
        float ny = ACz * BDx - ACx * BDz;
        float nz = ACx * BDy - ACy * BDx;

        float R = -(ray_dir[0] * nx + ray_dir[1] * ny + ray_dir[2] * nz);

        if (!(R < FLOAT_tiny && R > -FLOAT_tiny)) {
          float face_offset = 0.25 * ((A[0] + B[0] + C[0] + D[0]) * nx +
                                       (A[1] + B[1] + C[1] + D[1]) * ny +
                                       (A[2] + B[2] + C[2] + D[2]) * nz);
          float numer = (ray_pnt[0] * nx + ray_pnt[1] * ny + ray_pnt[2] * nz) - face_offset;
          float dist2intersect = numer / R;

          if (dist2intersect > FLOAT_tiny) {
            P[0] = dist2intersect * ray_dir[0] + ray_pnt[0];
            P[1] = dist2intersect * ray_dir[1] + ray_pnt[1];
            P[2] = dist2intersect * ray_dir[2] + ray_pnt[2];

            if (n == 4) InPoly = funcs.isInside_Quadrangle(P, A, B, C, D);
            else InPoly = funcs.isInside_Triangle(P, A, B, D); // D is last vertex, C==B here
          }
        }
        // R ~ 0 means ray parallel to plane -> no intersection, InPoly stays false
      }
      else {
        // Centroid: sum first, divide once (was dividing inside the loop before)
        float Gx = 0, Gy = 0, Gz = 0;
        for (int j = 0; j < n; j++) {
          int idx = faceNodes[j];
          Gx += allPoints.getX(idx);
          Gy += allPoints.getY(idx);
          Gz += allPoints.getZ(idx);
        }
        float invN = 1.0 / n;
        Gx *= invN; Gy *= invN; Gz *= invN;

        for (int j = 0; j < n; j++) {
          int j_next = (j + 1 == n) ? 0 : j + 1;
          int ai = faceNodes[j];
          int bi = faceNodes[j_next];

          float Ax = allPoints.getX(ai), Ay = allPoints.getY(ai), Az = allPoints.getZ(ai);
          float Bx = allPoints.getX(bi), By = allPoints.getY(bi), Bz = allPoints.getZ(bi);

          float AGx = Ax - Gx, AGy = Ay - Gy, AGz = Az - Gz;
          float BGx = Bx - Gx, BGy = By - Gy, BGz = Bz - Gz;

          float nx = AGy * BGz - AGz * BGy;
          float ny = AGz * BGx - AGx * BGz;
          float nz = AGx * BGy - AGy * BGx;

          float R = -(ray_dir[0] * nx + ray_dir[1] * ny + ray_dir[2] * nz);

          if (!(R < FLOAT_tiny && R > -FLOAT_tiny)) {
            float face_offset = (1.0 / 3.0) * ((Ax + Bx + Gx) * nx +
                                                (Ay + By + Gy) * ny +
                                                (Az + Bz + Gz) * nz);
            float numer = (ray_pnt[0] * nx + ray_pnt[1] * ny + ray_pnt[2] * nz) - face_offset;
            float dist2intersect = numer / R;

            if (dist2intersect > FLOAT_tiny) {
              P[0] = dist2intersect * ray_dir[0] + ray_pnt[0];
              P[1] = dist2intersect * ray_dir[1] + ray_pnt[1];
              P[2] = dist2intersect * ray_dir[2] + ray_pnt[2];

              float[] A = {Ax, Ay, Az};
              float[] B = {Bx, By, Bz};
              float[] G = {Gx, Gy, Gz};
              InPoly = funcs.isInside_Triangle(P, A, B, G);
            }
          }

          if (InPoly) break;
        }
      }

      if (InPoly) {
        hit = f;
        break outer;
      }
    }
  }

  return hit;
}
