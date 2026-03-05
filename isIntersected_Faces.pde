int SOLARCHVISION_isIntersected_Faces (float[] ray_pnt, float[] ray_dir, int firstGuess) {

  float[] ray_normal = funcs.vec3_unit(ray_dir);

  int hit = 0;

  for (int q = 0; q < allFaces.nodes.length; q++) {

    int f = (q + firstGuess) % allFaces.nodes.length;

    if (f > 0) {

      int n = allFaces.nodes[f].length;

      if (n > 2) {

        int vsb = allFaces.getVisibility(f);

          if (vsb > 0) {

          float X_intersect = FLOAT_undefined;
          float Y_intersect = FLOAT_undefined;
          float Z_intersect = FLOAT_undefined;
          float dist2intersect = FLOAT_undefined;
          float[] face_norm = {0,0,0};

          boolean InPoly = false;

          if (n < 5) { // works if n==3 or n==4

            float[] A = allPoints.getPosition(allFaces.nodes[f][0]);
            float[] B = allPoints.getPosition(allFaces.nodes[f][1]);
            float[] C = allPoints.getPosition(allFaces.nodes[f][n - 2]);
            float[] D = allPoints.getPosition(allFaces.nodes[f][n - 1]);

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

            int[] tmpFace = new int[n];
            float[] G = {
              0, 0, 0
            };
            for (int j = 0; j < n; j++) {
              tmpFace[j] = allFaces.nodes[f][j];
              G[0] += allPoints.getX(tmpFace[j]) / float(n);
              G[1] += allPoints.getY(tmpFace[j]) / float(n);
              G[2] += allPoints.getZ(tmpFace[j]) / float(n);
            }

            for (int j = 0; j < n; j++) {

              int j_next = (j + 1) % n;

              float[] A = {
                allPoints.getX(allFaces.nodes[f][j]),
                allPoints.getY(allFaces.nodes[f][j]),
                allPoints.getZ(allFaces.nodes[f][j])
              };

              float[] B = {
                allPoints.getX(allFaces.nodes[f][j_next]),
                allPoints.getY(allFaces.nodes[f][j_next]),
                allPoints.getZ(allFaces.nodes[f][j_next])
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

            hit = f;

            break;
          }

        }

        if (hit != 0) break;
      }
    }
  }

  return hit;
}
