void SOLARCHVISION_draw_logo (float cx, float cy, float cz, float cr, int the_view, int pass) {

  float stp_u = 1.0 / 24.0;
  float stp_v = 1.0 / 24.0;

  int n_a = 1;

  int aI = 0;
  for (float a = -1; a < 1; a += stp_u) {
    aI++;

    n_a *= -1;

    int n_b = n_a;

    int bI = 0;
    for (float b = -1; b < 1; b += stp_v) {
      bI++;

      n_b *= -1;

      float[][] newQuad = {
        {
          0, 0, 0
        }
        , {
          0, 0, 0
        }
        , {
          0, 0, 0
        }
        , {
          0, 0, 0
        }
      };

      for (int i = 0; i < 4; i++) {

        float u = a;
        float v = b;

        if ((i == 1) || (i == 2)) u += stp_u;
        if ((i == 2) || (i == 3)) v += stp_v;

        //---------------------------------------
        float x0 = cos(u * PI);
        float y0 = -sin(u * PI) * cos(v * PI);
        float z0 = sin(v * PI);

        float d = pow(x0*x0 + y0*y0 + z0*z0, 0.5);
        x0 /= d;
        y0 /= d;
        z0 /= d;

        float x = x0;
        float y = y0;
        float z = z0;

        if (the_view == 0) { // corner view: logo
          float t = -0.25 * PI;
          newQuad[i][0] = x0 * cos(t) - z0 * sin(t);
          newQuad[i][1] = y0;
          newQuad[i][2] = x0 * sin(t) + z0 * cos(t);
        } else if (the_view == 1) { // front view
          newQuad[i][0] = x0;
          newQuad[i][1] = y0;
          newQuad[i][2] = z0;
        } else if (the_view == -1) { // top view
          newQuad[i][0] = x0;
          newQuad[i][1] = z0;
          newQuad[i][2] = y0;
        }
      }

      float x1 = cr * newQuad[0][0] + cx;
      float y1 = cr * newQuad[0][1] + cy;
      float z1 = cr * newQuad[0][2] + cz;

      float x2 = cr * newQuad[1][0] + cx;
      float y2 = cr * newQuad[1][1] + cy;
      float z2 = cr * newQuad[1][2] + cz;

      float x3 = cr * newQuad[2][0] + cx;
      float y3 = cr * newQuad[2][1] + cy;
      float z3 = cr * newQuad[2][2] + cz;

      float x4 = cr * newQuad[3][0] + cx;
      float y4 = cr * newQuad[3][1] + cy;
      float z4 = cr * newQuad[3][2] + cz;

      strokeWeight(1);
      stroke(127);
      noFill();

      int q = 0;

      if(pass == 2) {
        if((aI == bI + 2) || (aI == bI + 3) || (aI == bI + 4)) {
          if(aI == bI + 2) q = 1;
          if(aI == bI + 4) q = 2;

          strokeWeight(2);
          stroke(255);
          fill(255,191,127);

          if(
            (aI == 47 && bI == 45) ||
            (aI == 48 && bI == 44) ||
            (aI == 40 && bI == 38) ||
            (aI == 41 && bI == 37)
          ) {
            fill(0);
          }
        } else if((aI + bI == 43) || (aI + bI == 44) || (aI + bI == 45)) {
          if(aI + bI == 43) q = 4;
          if(aI + bI == 45) q = 3;

          strokeWeight(2);
          stroke(255);
          fill(0);
        } else {
          continue;
        }
      }

      if(q == 0) {
        if (n_a * n_b == 1) {
          triangle(x1, y1, x2, y2, x3, y3);
          triangle(x3, y3, x4, y4, x1, y1);
        } else {
          triangle(x4, y4, x1, y1, x2, y2);
          triangle(x2, y2, x3, y3, x4, y4);
        }
      } else {
        if(q == 1) triangle(x1, y1, x2, y2, x3, y3);
        if(q == 2) triangle(x3, y3, x4, y4, x1, y1);
        if(q == 3) triangle(x4, y4, x1, y1, x2, y2);
        if(q == 4) triangle(x2, y2, x3, y3, x4, y4);
      }
    }
  }
}
