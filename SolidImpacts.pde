class solarchvision_SolidImpacts {

  private final static String CLASS_STAMP = "SolidImpacts";

  boolean displayPoints = false;
  boolean displayLines = true;

  int complex = 0; // INTERNAL! 0:simple 1:complex


  float[] X = {
    0, 0, 0, 0
  };
  float[] Y = {
    0, 0, 0, 0
  };

  float[] Z = {
    0, 0.1, 0, 0
  }; // <<<

  float[] R = {
    0, 0, 0, 0
  };

  float[] U = {
    100, 100, 100, 100
  }; // i.e. 100m
  float[] V = {
    100, 100, 100, 100
  }; // i.e. 100m

  int RES1 = 200; //400;
  int RES2 = 200; //400;

  PImage Image = createImage(this.RES1, this.RES2, ARGB);



  boolean displayImage = true;
  int sectionType = 0; // 0:off, 1:horizontal, 2:vertical(front), 3:vertical(side)

  float positionStep = 1.25;


  int record_PDF = 0;
  int record_IMG = 0;

  float WindSpeed = 5; // (5m/s = 18 km/h)
  float WindDirection = 180.0;

  float Power = 1.0; //2.0; //3.0; // 1/2/3
  float Grade = 0.02; //1.0; //0.1; //10.0; //contour lines




  float get_Impact_atXYZ (float x, float y, float z) {

    float v = 0;

    if (this.complex == 0) {
      v = this.calculate_Impact_atXYZ_simple(x, y, z);
    } else {
      v = this.calculate_Impact_atXYZ_complex(x, y, z);
    }

    return v;
  }



  float calculate_Impact_atXYZ_simple (float x, float y, float z) {

    float val = 1;

    for (int n = 0; n < allSolids.DEF.length; n++) {

      float r = allSolids.get_value(n);
      float d = allSolids.get_Distance(n, x, y, z);

      //d *= pow(d, this.Power);
      d *= pow(d, this.Power / float(allSolids.DEF.length));

      if (val < 0) val *= abs(d - r);
      else {
        val *= d - r;
      }
    }

    if (allSolids.DEF.length > 0) {
      float val_sign = 1;
      if (val < 0) {
        val_sign = -1;
        val = abs(val);
      }
      val = pow(val, 1.0 / float(allSolids.DEF.length));
      val *= val_sign;
    }

    return val;
  }



  float calculate_Impact_atXYZ_complex (float x, float y, float z) {

    float deltaX = this.WindSpeed * funcs.cos_ang(this.WindDirection);
    float deltaY = this.WindSpeed * funcs.sin_ang(this.WindDirection);

    float[] val = {
      1, 1
    };

    for (int o = 0; o < 2; o++) {

      for (int n = 0; n < allSolids.DEF.length; n++) {

        float r = allSolids.get_value(n);
        float d = allSolids.get_Distance(n, x + o * deltaX, y + o * deltaY, z);

        //d *= pow(d, this.Power);
        d *= pow(d, this.Power / float(allSolids.DEF.length));

        if (val[o] < 0) val[o] *= abs(d - r);
        else {
          val[o] *= d - r;
        }
      }

      if (allSolids.DEF.length > 0) {
        float val_sign = 1;
        if (val[o] < 0) {
          val_sign = -1;
          val[o] = abs(val[o]);
        }
        val[o] = pow(val[o], 1.0 / float(allSolids.DEF.length));
        val[o] *= val_sign;
      }
    }

    return val[1] - val[0];
  }


  void calculate_Impact_selectedSections () {

    for (int o = Select3D.Section_ids.length - 1; o >= 0; o--) {

      int f = Select3D.Section_ids[o];

      this.sectionType = allSections.get_type(f);
      this.RES1        = allSections.get_res1(f);
      this.RES2        = allSections.get_res2(f);

      this.X[this.sectionType] = allSections.getX(f);
      this.Y[this.sectionType] = allSections.getY(f);
      this.Z[this.sectionType] = allSections.getZ(f);
      this.R[this.sectionType] = allSections.getR(f);
      this.U[this.sectionType] = allSections.getU(f);
      this.V[this.sectionType] = allSections.getV(f);

      {
        if ((this.Image.width != this.RES1) || (this.Image.height != this.RES2)) {
          this.Image = createImage(this.RES1, this.RES2, ARGB);

          allSections.SolidImpact[f] = createImage(this.RES1, this.RES2, ARGB);
        }

        this.calculate_Impact_CurrentSection();

        allSections.SolidImpact[f].copy(this.Image, 0, 0, this.RES1, this.RES2, 0, 0, this.RES1, this.RES2);
      }
    }

  }


  float[] traceContour2D (int tracecomplex, float epsilon, float x, float y, float z, float dx, float dy, float dz, float v) {

    float t_max = FLOAT_undefined;
    float t_min = FLOAT_undefined;
    float t_equ = 0; //FLOAT_undefined;

    float v_max = FLOAT_undefined;
    float v_min = FLOAT_undefined;
    float v_equ = FLOAT_undefined;

    float x_max = FLOAT_undefined;
    float x_min = FLOAT_undefined;
    float x_equ = x + dx; //FLOAT_undefined;

    float y_max = FLOAT_undefined;
    float y_min = FLOAT_undefined;
    float y_equ = y + dy; //FLOAT_undefined;

    float z_max = FLOAT_undefined;
    float z_min = FLOAT_undefined;
    float z_equ = z + dz; //FLOAT_undefined;

    float min_dist = FLOAT_undefined;

    float r = epsilon;

    float t = funcs.atan2_ang(dy, dx);

    //for (int test_t = -180; test_t < 180; test_t += 5) {
    for (int test_t = -150; test_t <= 150; test_t += 5) { // <<<<

      float a = r * funcs.cos_ang(t + test_t);
      float b = r * funcs.sin_ang(t + test_t);
      float c = 0;

      if (this.sectionType == 1) {
        float Qx = a * funcs.cos_ang(-this.R[this.sectionType]) - b * funcs.sin_ang(-this.R[this.sectionType]);
        float Qy = -(a * funcs.sin_ang(-this.R[this.sectionType]) + b * funcs.cos_ang(-this.R[this.sectionType]));
        float Qz = c;

        a = Qx;
        b = Qy;
        c = Qz;
      } else if (this.sectionType == 2) {
        float Qx = a * funcs.cos_ang(this.R[this.sectionType]) - c * funcs.sin_ang(this.R[this.sectionType]);
        float Qy = -(a * funcs.sin_ang(this.R[this.sectionType]) + c * funcs.cos_ang(this.R[this.sectionType]));
        float Qz = -b;

        a = Qx;
        b = Qy;
        c = Qz;
      } else if (this.sectionType == 3) {
        float Qx = a * funcs.cos_ang(90 - this.R[this.sectionType]) - c * funcs.sin_ang(90 - this.R[this.sectionType]);
        float Qy = -(a * funcs.sin_ang(90 - this.R[this.sectionType]) + c * funcs.cos_ang(90 - this.R[this.sectionType]));
        float Qz = -b;

        a = Qx;
        b = Qy;
        c = Qz;
      }

      float test_x = x + a;
      float test_y = y + b;
      float test_z = z + c;

      float test_v = this.get_Impact_atXYZ(test_x, test_y, test_z);

      if ((test_v < v_min) || (is_undefined(v_min))) {
        v_min = test_v;
        t_min = test_t;
        x_min = test_x;
        y_min = test_y;
        z_min = test_z;
      }
      if ((test_v > v_max) || (is_undefined(v_max))) {
        v_max = test_v;
        t_max = test_t;
        x_max = test_x;
        y_max = test_y;
        z_max = test_z;
      }

      //if (((abs(test_v - v) < min_dist) && (funcs.vec2_dot(test_x - x, test_y - y, dx, dy) >= 0)) || (is_undefined(v_equ)))  {
      if ((abs(test_v - v) < min_dist) || (is_undefined(v_equ))) {
        //if (funcs.vec2_dot(test_x - x, test_y - y, dx, dy) >= 0) {

        min_dist = abs(test_v - v);

        v_equ = test_v;
        t_equ = test_t;
        x_equ = test_x;
        y_equ = test_y;
        z_equ = test_z;
        //}
      }
    }


    float the_X = 0, the_Y = 0, the_Z = 0, the_T = 0;

    if (tracecomplex == 0) {
      the_X = x_equ;
      the_Y = y_equ;
      the_Z = z_equ;
      the_T = t_equ;
    }
    if (tracecomplex == -1) {
      the_X = x_min;
      the_Y = y_min;
      the_Z = z_min;
      the_T = t_min;
    }
    if (tracecomplex == 1) {
      the_X = x_max;
      the_Y = y_max;
      the_Z = z_max;
      the_T = t_max;
    }

    float[] return_array = {
      the_X, the_Y, the_Z, funcs.cos_ang(t + the_T), funcs.sin_ang(t + the_T), 0
    };

    return return_array;
  }


  float[][] traceContour3D (float epsilon, float x, float y, float z, float v) {

    float tz_max = FLOAT_undefined;
    float tz_min = FLOAT_undefined;
    float tz_equ = FLOAT_undefined;

    float txy_max = FLOAT_undefined;
    float txy_min = FLOAT_undefined;
    float txy_equ = FLOAT_undefined;

    float v_max = FLOAT_undefined;
    float v_min = FLOAT_undefined;
    float v_equ = FLOAT_undefined;

    float x_max = FLOAT_undefined;
    float x_min = FLOAT_undefined;
    float x_equ = FLOAT_undefined;

    float y_max = FLOAT_undefined;
    float y_min = FLOAT_undefined;
    float y_equ = FLOAT_undefined;

    float z_max = FLOAT_undefined;
    float z_min = FLOAT_undefined;
    float z_equ = FLOAT_undefined;

    float min_dist = FLOAT_undefined;

    float r = epsilon;

    for (int test_tz = -90; test_tz <= 90; test_tz += 30) { // in the space
      //for (int test_tz = 0; test_tz <= 0; test_tz += 30) { // on the surface!

      float c = r * funcs.sin_ang(test_tz);

      for (int test_txy = -180; test_txy < 180; test_txy += 15) {

        float a = r * funcs.cos_ang(test_tz) * funcs.cos_ang(test_txy);
        float b = r * funcs.cos_ang(test_tz) * funcs.sin_ang(test_txy);


        float test_x = x + a;
        float test_y = y + b;
        float test_z = z + c;

        float test_v = this.get_Impact_atXYZ(test_x, test_y, test_z);

        if ((test_v < v_min) || (is_undefined(v_min))) {
          v_min = test_v;
          tz_min = test_tz;
          txy_min = test_txy;
          x_min = test_x;
          y_min = test_y;
          z_min = test_z;
        }
        if ((test_v > v_max) || (is_undefined(v_max))) {
          v_max = test_v;
          tz_max = test_tz;
          txy_max = test_txy;
          x_max = test_x;
          y_max = test_y;
          z_max = test_z;
        }

        if ((abs(test_v - v) < min_dist) || (is_undefined(v_equ))) {

          min_dist = abs(test_v - v);

          v_equ = test_v;
          tz_equ = test_tz;
          txy_equ = test_txy;
          x_equ = test_x;
          y_equ = test_y;
          z_equ = test_z;
        }
      }
    }

    float[][] return_array = {
      {
        x_min, y_min, z_min, v_min
      }
      , {
        x_equ, y_equ, z_equ, v_equ
      }
      , {
        x_max, y_max, z_max, v_max
      }
    };

    return return_array;
  }





  float[][] Contours_U1Vertices = {
    {
      0, 0, 0, 0
    }
  }; // keeping SolidImpact value at the 4th member
  float[][] Contours_V1Vertices = {
    {
      0, 0, 0, 0
    }
  }; // keeping SolidImpact value at the 4th member
  float[][] Contours_V2Vertices = {
    {
      0, 0, 0, 0
    }
  }; // keeping SolidImpact value at the 4th member
  int[][] Contours_U1Lines = {
    {
      0, 0
    }
  };
  int[][] Contours_V1Lines = {
    {
      0, 0
    }
  };
  int[][] Contours_V2Lines = {
    {
      0, 0
    }
  };

  int Process_subDivisions = 1; //1; // 0,1,2,3

  float deltaStep = 0.05;
  float deltaLines = 0.1 * this.deltaStep;


  void calculate_Impact_CurrentSection () {

    if (this.sectionType != 0) {

      cursor(WAIT);

      this.Contours_U1Vertices = new float [1][4];
      this.Contours_U1Vertices[0][0] = 0;
      this.Contours_U1Vertices[0][1] = 0;
      this.Contours_U1Vertices[0][2] = 0;
      this.Contours_U1Vertices[0][3] = 0;

      this.Contours_V1Vertices = new float [1][4];
      this.Contours_V1Vertices[0][0] = 0;
      this.Contours_V1Vertices[0][1] = 0;
      this.Contours_V1Vertices[0][2] = 0;
      this.Contours_V1Vertices[0][3] = 0;

      this.Contours_V2Vertices = new float [1][4];
      this.Contours_V2Vertices[0][0] = 0;
      this.Contours_V2Vertices[0][1] = 0;
      this.Contours_V2Vertices[0][2] = 0;
      this.Contours_V2Vertices[0][3] = 0;

      this.Contours_U1Lines = new int [1][2];
      this.Contours_U1Lines[0][0] = 0;
      this.Contours_U1Lines[0][1] = 0;

      this.Contours_V1Lines = new int [1][2];
      this.Contours_V1Lines[0][0] = 0;
      this.Contours_V1Lines[0][1] = 0;

      this.Contours_V2Lines = new int [1][2];
      this.Contours_V2Lines[0][0] = 0;
      this.Contours_V2Lines[0][1] = 0;


      int PAL_type = allSolids.pallet_CLR;
      int PAL_direction = allSolids.pallet_DIR;
      float PAL_multiplier = allSolids.pallet_MLT;

      this.Image.loadPixels();

      float Section_X = this.X[this.sectionType];
      float Section_Y = this.Y[this.sectionType];
      float Section_Z = this.Z[this.sectionType];
      float Section_R = this.R[this.sectionType];
      float Section_U = this.U[this.sectionType];
      float Section_V = this.V[this.sectionType];

      int Section_complex = this.sectionType;
      int Section_RES1 = this.RES1;
      int Section_RES2 = this.RES2;

      float[][] ImageVertex = allSections.getCorners(Section_complex, Section_X, Section_Y, Section_Z, Section_R, Section_U, Section_V, Section_RES1, Section_RES2);

      float[] SectionCorner_A = ImageVertex[1];
      float[] SectionCorner_B = ImageVertex[2];
      float[] SectionCorner_C = ImageVertex[3];
      float[] SectionCorner_D = ImageVertex[4];

      for (int i = 0; i < this.RES1; i++) {
        for (int j = 0; j < this.RES2; j++) {

          float x = funcs.bilinear(SectionCorner_A[0], SectionCorner_B[0], SectionCorner_C[0], SectionCorner_D[0], i / float(this.RES1), 1 - j / float(this.RES2));
          float y = funcs.bilinear(SectionCorner_A[1], SectionCorner_B[1], SectionCorner_C[1], SectionCorner_D[1], i / float(this.RES1), 1 - j / float(this.RES2));
          float z = funcs.bilinear(SectionCorner_A[2], SectionCorner_B[2], SectionCorner_C[2], SectionCorner_D[2], i / float(this.RES1), 1 - j / float(this.RES2));

          this.complex = 0;
          float val = this.get_Impact_atXYZ(x, y, z);

          float g =      funcs.roundTo(this.Grade * val, this.deltaStep) - 0.5 * this.deltaStep;
          float g_line = funcs.roundTo(this.Grade * val, this.deltaLines);

          float _u = PAL_multiplier * val + 0.5;

          if (PAL_direction == -1) _u = 1 - _u;
          if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
          if (PAL_direction == 2) _u =  0.5 * _u;

          float[] COL = PAINT.getColorStyle(PAL_type, _u);

          if ((this.Process_subDivisions == 1) || (this.Process_subDivisions == 2)) {
            //if ((g == g_line) && (g != 0)) {
            if ((abs(g - g_line) < 0.001) && (g != 0)) {
              COL[0] = 0;
              COL[1] = 0;//255;
              COL[2] = 0;//255;
              COL[3] = 0;//255;
            }
          }

          if ((this.Process_subDivisions == 2) || (this.Process_subDivisions == 3)) {

            if ((abs(g - g_line) < 0.0001) && (g != 0) && (g_line <= 1)) {
              //if ((g_line > 1 - this.deltaLines) && (g_line <= 1)) { // not sure!

              float dx = 1;
              float dy = 0;
              float dz = 0;

              float[] test_point_dir = {
                x, y, z, dx, dy, dz
              };

              trace_U1Line(test_point_dir, g_line, 100);
            }
          }

          this.Image.pixels[i + j * this.RES1] = color(COL[1], COL[2], COL[3], COL[0]);
        }
      }

      this.Image.updatePixels();

      if (this.record_IMG == 1) {
        String myFile = getFilename_SolidImpact() + ".jpg";
        this.Image.save(myFile);
        println("File created:" + myFile);
      }



      if ((this.Process_subDivisions == 2) || (this.Process_subDivisions == 3)) {
        /*
         for (int k = 1; k < this.Contours_U1Vertices.length; k++) {

         float x = this.Contours_U1Vertices[k][0];
         float y = this.Contours_U1Vertices[k][1];
         float z = this.Contours_U1Vertices[k][2];

         float val = this.Contours_U1Vertices[k][3]; //this.get_Impact_atXYZ(x, y, z);

         float g =      funcs.roundTo(this.Grade * val, this.deltaStep) - 0.5 * this.deltaStep;
         float g_line = funcs.roundTo(this.Grade * val, this.deltaLines);

         float dx = 1;
         float dy = 0;
         float dz = 0;

         float[] test_point_dir = {x, y, z, dx, dy, dz};

         // making the first VVertex on the UVertice
         {
         float[][] newVertex = {{test_point_dir[0], test_point_dir[1], test_point_dir[2], g_line / this.Grade}};
         this.Contours_V1Vertices = (float[][]) concat(this.Contours_V1Vertices, newVertex);
         }

         // making the first WVertex on the UVertice
         {
         float[][] newVertex = {{test_point_dir[0], test_point_dir[1], test_point_dir[2], g_line / this.Grade}};
         this.Contours_V2Vertices = (float[][]) concat(this.Contours_V2Vertices, newVertex);
         }


         trace_V1Line(test_point_dir, g_line, 100);
         }
         */
      }

      if (this.record_PDF == 1) {

        String myFile = getFilename_SolidImpact() + ".pdf";

        PGraphics pdf = createGraphics(this.RES1, this.RES2, PDF, myFile);

        pdf.beginDraw();

        pdf.image(this.Image, 0, 0, this.RES1, this.RES2);

        if ((this.Process_subDivisions == 2) || (this.Process_subDivisions == 3)) {
          if (this.displayLines) {

            for (int U_or_V_or_W = 0; U_or_V_or_W < 3; U_or_V_or_W++) {

              if (U_or_V_or_W == 0) {
                pdf.strokeWeight(0.25);
                pdf.stroke(255, 0, 0);
                pdf.fill(255, 0, 0);
              }
              if (U_or_V_or_W == 1) {
                pdf.strokeWeight(0.25);
                pdf.stroke(0, 255, 0);
                pdf.fill(0, 255, 0);
              }
              if (U_or_V_or_W == 2) {
                pdf.strokeWeight(0.25);
                pdf.stroke(0, 0, 255);
                pdf.fill(0, 0, 255);
              }

              int q_num = 0;
              if (U_or_V_or_W == 0) {
                q_num = this.Contours_U1Lines.length;
              }
              if (U_or_V_or_W == 1) {
                q_num = this.Contours_V1Lines.length;
              }
              if (U_or_V_or_W == 2) {
                q_num = this.Contours_V2Lines.length;
              }

              for (int q = 1; q < q_num; q++) {

                float[] i = {
                  0, 0
                };
                float[] j = {
                  0, 0
                };

                for (int p = 0; p < 2; p++) {

                  int n = 0;
                  float x0 = 0, y0 = 0, z0 = 0;

                  if (U_or_V_or_W == 0) {
                    n = this.Contours_U1Lines[q][p];
                    x0 = this.Contours_U1Vertices[n][0];
                    y0 = this.Contours_U1Vertices[n][1];
                    z0 = this.Contours_U1Vertices[n][2];
                  }
                  if (U_or_V_or_W == 1) {
                    n = this.Contours_V1Lines[q][p];
                    x0 = this.Contours_V1Vertices[n][0];
                    y0 = this.Contours_V1Vertices[n][1];
                    z0 = this.Contours_V1Vertices[n][2];
                  }
                  if (U_or_V_or_W == 2) {
                    n = this.Contours_V2Lines[q][p];
                    x0 = this.Contours_V2Vertices[n][0];
                    y0 = this.Contours_V2Vertices[n][1];
                    z0 = this.Contours_V2Vertices[n][2];
                  }

                  float r = 0;

                  if (this.sectionType == 1) {
                    r = -this.R[this.sectionType];
                  } else if (this.sectionType == 2) {
                    r = this.R[this.sectionType];
                  } else if (this.sectionType == 3) {
                    r = -this.R[this.sectionType];
                  }

                  float x = x0 * funcs.cos_ang(r) - y0 * funcs.sin_ang(r);
                  float y = x0 * funcs.sin_ang(r) + y0 * funcs.cos_ang(r);
                  float z = z0;

                  float a = 0;
                  float b = 0;

                  if (this.sectionType == 1) {
                    a = x;
                    b = -y;
                  } else if (this.sectionType == 2) {
                    a = x;
                    b = -z;
                  } else if (this.sectionType == 3) {
                    a = -y;
                    b = -z;
                  }

                  i[p] = this.RES1 * ((a - this.X[this.sectionType]) / this.U[this.sectionType] + 0.5);
                  j[p] = this.RES2 * ((b + this.Y[this.sectionType]) / this.V[this.sectionType] + 0.5);
                }

                pdf.line(i[0], j[0], i[1], j[1]);
              }
            }
          }

          if (this.displayPoints) {
            pdf.strokeWeight(0.5);
            pdf.stroke(255, 127, 0);
            pdf.noFill();
            pdf.ellipseMode(CENTER);

            for (int n = 1; n < this.Contours_U1Vertices.length; n++) {

              float x0 = this.Contours_U1Vertices[n][0];
              float y0 = this.Contours_U1Vertices[n][1];
              float z0 = this.Contours_U1Vertices[n][2];

              float r = 0;

              if (this.sectionType == 1) {
                r = -this.R[this.sectionType];
              } else if (this.sectionType == 2) {
                r = this.R[this.sectionType];
              } else if (this.sectionType == 3) {
                r = -this.R[this.sectionType];
              }

              float x = x0 * funcs.cos_ang(r) - y0 * funcs.sin_ang(r);
              float y = x0 * funcs.sin_ang(r) + y0 * funcs.cos_ang(r);
              float z = z0;

              float a = 0;
              float b = 0;

              if (this.sectionType == 1) {
                a = x;
                b = -y;
              } else if (this.sectionType == 2) {
                a = x;
                b = -z;
              } else if (this.sectionType == 3) {
                a = -y;
                b = -z;
              }

              float i = this.RES1 * ((a - this.X[this.sectionType]) / this.U[this.sectionType] + 0.5);
              float j = this.RES2 * ((b + this.Y[this.sectionType]) / this.V[this.sectionType] + 0.5);

              pdf.ellipse(i, j, 1, 1);
            }

            pdf.strokeWeight(0);
          }
        }


        pdf.dispose();

        pdf.endDraw();

        println("File created:" + myFile);
      }

      cursor(ARROW);
    }
  }



  void draw_lines () {

    if (this.displayLines) {

      WIN3D.graphics.strokeWeight(1);
      WIN3D.graphics.stroke(255, 0, 0);
      WIN3D.graphics.fill(255, 0, 0);

      for (int q = 1; q < this.Contours_U1Lines.length; q++) {

        int n1 = this.Contours_U1Lines[q][0];
        int n2 = this.Contours_U1Lines[q][1];

        float x1 = this.Contours_U1Vertices[n1][0];
        float y1 = this.Contours_U1Vertices[n1][1];
        float z1 = this.Contours_U1Vertices[n1][2];

        float x2 = this.Contours_U1Vertices[n2][0];
        float y2 = this.Contours_U1Vertices[n2][1];
        float z2 = this.Contours_U1Vertices[n2][2];

        WIN3D.graphics.line(x1 * OBJECTS_scale * WIN3D.scale, -y1 * OBJECTS_scale * WIN3D.scale, z1 * OBJECTS_scale * WIN3D.scale, x2 * OBJECTS_scale * WIN3D.scale, -y2 * OBJECTS_scale * WIN3D.scale, z2 * OBJECTS_scale * WIN3D.scale);
      }

      WIN3D.graphics.strokeWeight(1);
      WIN3D.graphics.stroke(0, 255, 0);
      WIN3D.graphics.fill(0, 255, 0);

      for (int q = 1; q < this.Contours_V1Lines.length; q++) {

        int n1 = this.Contours_V1Lines[q][0];
        int n2 = this.Contours_V1Lines[q][1];

        float x1 = this.Contours_V1Vertices[n1][0];
        float y1 = this.Contours_V1Vertices[n1][1];
        float z1 = this.Contours_V1Vertices[n1][2];

        float x2 = this.Contours_V1Vertices[n2][0];
        float y2 = this.Contours_V1Vertices[n2][1];
        float z2 = this.Contours_V1Vertices[n2][2];

        WIN3D.graphics.line(x1 * OBJECTS_scale * WIN3D.scale, -y1 * OBJECTS_scale * WIN3D.scale, z1 * OBJECTS_scale * WIN3D.scale, x2 * OBJECTS_scale * WIN3D.scale, -y2 * OBJECTS_scale * WIN3D.scale, z2 * OBJECTS_scale * WIN3D.scale);
      }

      WIN3D.graphics.strokeWeight(1);
      WIN3D.graphics.stroke(255, 0, 0);
      WIN3D.graphics.fill(255, 0, 0);

      for (int q = 1; q < this.Contours_V2Lines.length; q++) {

        int n1 = this.Contours_V2Lines[q][0];
        int n2 = this.Contours_V2Lines[q][1];

        float x1 = this.Contours_V2Vertices[n1][0];
        float y1 = this.Contours_V2Vertices[n1][1];
        float z1 = this.Contours_V2Vertices[n1][2];

        float x2 = this.Contours_V2Vertices[n2][0];
        float y2 = this.Contours_V2Vertices[n2][1];
        float z2 = this.Contours_V2Vertices[n2][2];

        WIN3D.graphics.line(x1 * OBJECTS_scale * WIN3D.scale, -y1 * OBJECTS_scale * WIN3D.scale, z1 * OBJECTS_scale * WIN3D.scale, x2 * OBJECTS_scale * WIN3D.scale, -y2 * OBJECTS_scale * WIN3D.scale, z2 * OBJECTS_scale * WIN3D.scale);
      }

      WIN3D.graphics.strokeWeight(0);
    }
  }

  void draw_points () {
    if (this.displayPoints) {

      WIN3D.graphics.strokeWeight(0);
      WIN3D.graphics.stroke(255, 127, 0);
      WIN3D.graphics.fill(255, 127, 0);

      float R = 1; //0.2;

      for (int n = 1; n < this.Contours_U1Vertices.length; n++) {

        float x = this.Contours_U1Vertices[n][0];
        float y = this.Contours_U1Vertices[n][1];
        float z = this.Contours_U1Vertices[n][2];

        WIN3D.graphics.pushMatrix();
        WIN3D.graphics.translate(x * OBJECTS_scale * WIN3D.scale, -y * OBJECTS_scale * WIN3D.scale, z * OBJECTS_scale * WIN3D.scale);
        WIN3D.graphics.sphere(R);
        WIN3D.graphics.popMatrix();
      }
    }
  }

  float MinimumDistance_traceU = 1.0;
  float MinimumDistance_traceV = 0.25;

  void trace_U1Line (float[] test_point_dir, float g_line, int n_Tries) {

    int point_prev = 0;
    int point_next = 0;

    for (int n = 0; n < n_Tries; n++) {

      float[][] preVertex = {
        {
          test_point_dir[0], test_point_dir[1], test_point_dir[2], g_line / this.Grade
        }
      };

      if (point_prev == 0) {
        float nearestPointDist = FLOAT_undefined;
        int nearestPointNum = 0;

        for (int q = 1; q < this.Contours_U1Vertices.length; q++) {
          //if (preVertex[0][3] == this.Contours_U1Vertices[q][3]) {
          if (preVertex[0][3] - this.Contours_U1Vertices[q][3] < 0.0001) {

            float d = dist(preVertex[0][0], preVertex[0][1], preVertex[0][2], this.Contours_U1Vertices[q][0], this.Contours_U1Vertices[q][1], this.Contours_U1Vertices[q][2]);

            if (nearestPointDist > d) {
              nearestPointDist = d;
              nearestPointNum = q;
            }
          }
        }

        if (nearestPointDist < 0.5) {  //i.e. 0.5m
          point_prev = nearestPointNum;

          test_point_dir[0] = this.Contours_U1Vertices[point_prev][0];
          test_point_dir[1] = this.Contours_U1Vertices[point_prev][1];
          test_point_dir[2] = this.Contours_U1Vertices[point_prev][2];
        }
      }

      //------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      test_point_dir = this.traceContour2D(0, MinimumDistance_traceU, test_point_dir[0], test_point_dir[1], test_point_dir[2], test_point_dir[3], test_point_dir[4], test_point_dir[5], g_line / this.Grade);
      //------------------------------------------------------------------------------------------------------------------------------------------------------------------------

      float[][] newVertex = {
        {
          test_point_dir[0], test_point_dir[1], test_point_dir[2], g_line / this.Grade
        }
      };
      point_next = 0;

      float nearestPointDist = FLOAT_undefined;
      int nearestPointNum = 0;

      int next_point_existed = 0;

      for (int q = 1; q < this.Contours_U1Vertices.length; q++) {
        //if (newVertex[0][3] == this.Contours_U1Vertices[q][3]) {
        if (abs(newVertex[0][3] - this.Contours_U1Vertices[q][3]) < 0.0001) {

          float d = dist(newVertex[0][0], newVertex[0][1], newVertex[0][2], this.Contours_U1Vertices[q][0], this.Contours_U1Vertices[q][1], this.Contours_U1Vertices[q][2]);

          if ((nearestPointDist > d) && (point_prev != q)) {
            nearestPointDist = d;
            nearestPointNum = q;
          }
        }
      }

      if (nearestPointDist < MinimumDistance_traceU) {
        point_next = nearestPointNum;

        test_point_dir[0] = this.Contours_U1Vertices[point_next][0];
        test_point_dir[1] = this.Contours_U1Vertices[point_next][1];
        test_point_dir[2] = this.Contours_U1Vertices[point_next][2];

        next_point_existed = 1;
      }


      if (point_next == 0) {

        this.Contours_U1Vertices = (float[][]) concat(this.Contours_U1Vertices, newVertex);
        point_next = this.Contours_U1Vertices.length - 1;
      }

      if ((point_prev != 0) && (point_next != 0)) {
        int[][] newU1Line = {
          {
            point_prev, point_next
          }
        };
        this.Contours_U1Lines = (int[][]) concat(this.Contours_U1Lines, newU1Line);

        point_prev = point_next;
      }

      if (next_point_existed == 1) {
        break; // when reaching an existing line
      }
    }
  }

  void trace_V1Line (float[] test_point_dir, float g_line, int n_Tries) {

    int point_prev = this.Contours_V1Vertices.length - 1; // the last added point
    int point_next = 0;

    for (int n = 0; n < n_Tries; n++) {

      //------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      test_point_dir = this.traceContour2D(-1, MinimumDistance_traceV, test_point_dir[0], test_point_dir[1], test_point_dir[2], test_point_dir[3], test_point_dir[4], test_point_dir[5], g_line / this.Grade);
      //------------------------------------------------------------------------------------------------------------------------------------------------------------------------

      float[][] newVertex = {
        {
          test_point_dir[0], test_point_dir[1], test_point_dir[2], g_line / this.Grade
        }
      };

      point_next = 0;

      {
        this.Contours_V1Vertices = (float[][]) concat(this.Contours_V1Vertices, newVertex);
        point_next = this.Contours_V1Vertices.length - 1;
      }

      if ((point_prev != 0) && (point_next != 0)) {
        int[][] newV1Line = {
          {
            point_prev, point_next
          }
        };
        this.Contours_V1Lines = (int[][]) concat(this.Contours_V1Lines, newV1Line);

        float val_new = this.get_Impact_atXYZ(test_point_dir[0], test_point_dir[1], test_point_dir[2]);
        float g_new =      funcs.roundTo(this.Grade * val_new, this.deltaStep) - 0.5 * this.deltaStep;
        float g_line_new = funcs.roundTo(this.Grade * val_new, this.deltaLines);

        if (g_line - g_line_new >= this.deltaStep) {


          float nearestPointDist = FLOAT_undefined;
          int nearestPointNum = 0;

          for (int q = 1; q < this.Contours_U1Vertices.length; q++) {

            //if (abs(g_line_new / this.Grade - this.Contours_U1Vertices[q][3]) < 0.0001) {
            if (g_line - g_line_new < 2 * this.deltaStep) {

              float d = dist(test_point_dir[0], test_point_dir[1], test_point_dir[2], this.Contours_U1Vertices[q][0], this.Contours_U1Vertices[q][1], this.Contours_U1Vertices[q][2]);

              if (nearestPointDist > d) {
                nearestPointDist = d;
                nearestPointNum = q;
              }
            }
          }

          if (nearestPointDist < MinimumDistance_traceU) {

            int q = nearestPointNum;

            float[][] endVertex = {
              {
                this.Contours_U1Vertices[q][0], this.Contours_U1Vertices[q][1], this.Contours_U1Vertices[q][2], this.Contours_U1Vertices[q][3]
              }
            };
            this.Contours_V2Vertices = (float[][]) concat(this.Contours_V2Vertices, endVertex);

            int[][] newV2Line = {
              {
                this.Contours_V2Vertices.length - 2, this.Contours_V2Vertices.length - 1
              }
            }; // last two WVertices
            this.Contours_V2Lines = (int[][]) concat(this.Contours_V2Lines, newV2Line);
          }


          break; // when reaching the area outside contour level
        }

        point_prev = point_next;
      }
    }
  }

  float[][] Wind_Vertices = new float [0][4]; // keeping values at the 4th member
  int[][] Wind_Lines = new int [0][2];

  void calculate_WindFlow () {

    cursor(WAIT);

    this.Wind_Vertices = new float [0][4];

    this.Wind_Lines = new int [0][2];




    float deltaX = -this.WindSpeed * funcs.cos_ang(this.WindDirection);
    float deltaY = -this.WindSpeed * funcs.sin_ang(this.WindDirection);
    float deltaZ = 0;

    /*

     float Section_X = this.X[this.sectionType];
     float Section_Y = this.Y[this.sectionType];
     float Section_Z = this.Z[this.sectionType];
     float Section_R = this.R[this.sectionType];
     float Section_U = this.U[this.sectionType];
     float Section_V = this.V[this.sectionType];

     int Section_complex = this.sectionType;
     int Section_RES1 = this.RES1;
     int Section_RES2 = this.RES2;

     float[][] ImageVertex = allSections.getCorners(Section_complex, Section_X, Section_Y, Section_Z, Section_R, Section_U, Section_V, Section_RES1, Section_RES2);

     float[] SectionCorner_A = ImageVertex[1];
     float[] SectionCorner_B = ImageVertex[2];
     float[] SectionCorner_C = ImageVertex[3];
     float[] SectionCorner_D = ImageVertex[4];

     for (int i = 0; i < this.RES1; i += 10) {
     for (int j = 0; j < this.RES2; j += 10) {

     float x = funcs.bilinear(SectionCorner_A[0], SectionCorner_B[0], SectionCorner_C[0], SectionCorner_D[0], i / float(this.RES1), 1 - j / float(this.RES2));
     float y = funcs.bilinear(SectionCorner_A[1], SectionCorner_B[1], SectionCorner_C[1], SectionCorner_D[1], i / float(this.RES1), 1 - j / float(this.RES2));
     float z = funcs.bilinear(SectionCorner_A[2], SectionCorner_B[2], SectionCorner_C[2], SectionCorner_D[2], i / float(this.RES1), 1 - j / float(this.RES2));

     */


    for (float z = 2.5; z <= 30; z += 5.0) {
      for (float y = -80; y <= 80; y += 5.0) {
        for (float x = -80; x <= 80; x += 5.0) {



          float[] test_point = {
            x, y, z
          };


          int num_steps = 1; //1; //4;

          for (int n = 0; n < num_steps; n++) {

            this.complex = 0;
            float inside_or_outside = this.get_Impact_atXYZ(test_point[0], test_point[1], test_point[2]);

            if (inside_or_outside > 0) {

              this.complex = 1;
              float val = this.get_Impact_atXYZ(test_point[0], test_point[1], test_point[2]);


              float MinimumDistance_trace = 1 / float(num_steps);

              //-----------------------------------------------------------------------------------------------------------------------------------------
              float[][] tracedPoints = this.traceContour3D(MinimumDistance_trace, test_point[0], test_point[1], test_point[2], val);
              //-----------------------------------------------------------------------------------------------------------------------------------------

              float[] point_min = tracedPoints[0];
              //float[] point_equ = tracedPoints[1];
              //float[] point_max = tracedPoints[2];

              float[] v1 = {
                deltaX, deltaY, deltaZ
              };

              float[] v2 = {
                point_min[0] - x, point_min[1] - y, point_min[2] - z
              };

              float acceleration = -this.WindSpeed * (point_min[3] - val);

              float dx = v1[0] + v2[0] * acceleration;
              float dy = v1[1] + v2[1] * acceleration;
              float dz = v1[2] + v2[2] * acceleration;

              //float scale = 1.0 / float(num_steps);
              float scale = 0.1 / float(num_steps); // <<<<<<<<<<<<<<<<<<<<

              float x1 = test_point[0] - 0.5 * dx * scale;
              float y1 = test_point[1] - 0.5 * dy * scale;
              float z1 = test_point[2] - 0.5 * dz * scale;

              float x2 = test_point[0] + 0.5 * dx * scale;
              float y2 = test_point[1] + 0.5 * dy * scale;
              float z2 = test_point[2] + 0.5 * dz * scale;


              float AB = (dist(x1, y1, z1, x2, y2, z2) / scale - this.WindSpeed) / this.WindSpeed;

              int point_prev = 0;
              int point_next = 0;

              {
                float[][] newVertex = {
                  {
                    x1, y1, z1, AB
                  }
                };
                this.Wind_Vertices = (float[][]) concat(this.Wind_Vertices, newVertex);

                point_prev = this.Wind_Vertices.length - 1;
              }


              {
                float[][] newVertex = {
                  {
                    x2, y2, z2, AB
                  }
                };
                this.Wind_Vertices = (float[][]) concat(this.Wind_Vertices, newVertex);

                point_next = this.Wind_Vertices.length - 1;
              }

              if ((point_prev != 0) && (point_next != 0)) {
                int[][] newU1Line = {
                  {
                    point_prev, point_next
                  }
                };
                this.Wind_Lines = (int[][]) concat(this.Wind_Lines, newU1Line);

                point_prev = point_next;
              }


              test_point[0] = x2;
              test_point[1] = y2;
              test_point[2] = z2;
            }
          }
        }
      }
    }

    cursor(ARROW);

    allWindFlows.displayAll = true;
    ROLLOUT.revise();
  }




  public void to_XML (XML xml) {

    println("Saving:" + this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setFloat(parent, this.CLASS_STAMP + ".WindSpeed", this.WindSpeed);
    XML_setFloat(parent, this.CLASS_STAMP + ".WindDirection", this.WindDirection);
    XML_setFloat(parent, this.CLASS_STAMP + ".Power", this.Power);
    XML_setBoolean(parent, this.CLASS_STAMP + ".displayPoints", this.displayPoints);
    XML_setBoolean(parent, this.CLASS_STAMP + ".displayLines", this.displayLines);

    XML_setInt(parent, this.CLASS_STAMP + ".RES1", this.RES1);
    XML_setInt(parent, this.CLASS_STAMP + ".RES2", this.RES2);
    XML_setFloat(parent, this.CLASS_STAMP + ".Grade", this.Grade);
    XML_setBoolean(parent, this.CLASS_STAMP + ".displayImage", this.displayImage);
    XML_setInt(parent, this.CLASS_STAMP + ".sectionType", this.sectionType);
    XML_setFloat(parent, this.CLASS_STAMP + ".positionStep", this.positionStep);
    XML_setInt(parent, this.CLASS_STAMP + ".Process_subDivisions", this.Process_subDivisions);
    XML_setFloat(parent, this.CLASS_STAMP + ".deltaStep", this.deltaStep);
    XML_setFloat(parent, this.CLASS_STAMP + ".deltaLines", this.deltaLines);
    XML_setFloat(parent, this.CLASS_STAMP + ".MinimumDistance_traceU", this.MinimumDistance_traceU);
    XML_setFloat(parent, this.CLASS_STAMP + ".MinimumDistance_traceV", this.MinimumDistance_traceV);

    {
      XML child = xml.addChild(this.CLASS_STAMP + ".Z");
      int ni = this.Z.length;
      XML_setInt(child, "ni", ni);
      String txt = "";
      for (int i = 0; i < ni; i++) {
        txt += nf(this.Z[i], 0, 4).replace(",", "."); // <<<<
        if (i < ni - 1) txt += ",";
      }
      XML_setContent(child, txt);
    }

    {
      XML child = xml.addChild(this.CLASS_STAMP + ".R");
      int ni = this.R.length;
      XML_setInt(child, "ni", ni);
      String txt = "";
      for (int i = 0; i < ni; i++) {
        txt += nf(this.R[i], 0, 4).replace(",", "."); // <<<<
        if (i < ni - 1) txt += ",";
      }
      XML_setContent(child, txt);
    }

    {
      XML child = xml.addChild(this.CLASS_STAMP + ".U");
      int ni = this.U.length;
      XML_setInt(child, "ni", ni);
      String txt = "";
      for (int i = 0; i < ni; i++) {
        txt += nf(this.U[i], 0, 4).replace(",", "."); // <<<<
        if (i < ni - 1) txt += ",";
      }
      XML_setContent(child, txt);
    }

    {
      XML child = xml.addChild(this.CLASS_STAMP + ".V");
      int ni = this.V.length;
      XML_setInt(child, "ni", ni);
      String txt = "";
      for (int i = 0; i < ni; i++) {
        txt += nf(this.V[i], 0, 4).replace(",", "."); // <<<<
        if (i < ni - 1) txt += ",";
      }
      XML_setContent(child, txt);
    }

    {
      XML child = xml.addChild(this.CLASS_STAMP + ".X");
      int ni = this.X.length;
      XML_setInt(child, "ni", ni);
      String txt = "";
      for (int i = 0; i < ni; i++) {
        txt += nf(this.X[i], 0, 4).replace(",", "."); // <<<<
        if (i < ni - 1) txt += ",";
      }
      XML_setContent(child, txt);
    }

    {
      XML child = xml.addChild(this.CLASS_STAMP + ".Y");
      int ni = this.Y.length;
      XML_setInt(child, "ni", ni);
      String txt = "";
      for (int i = 0; i < ni; i++) {
        txt += nf(this.Y[i], 0, 4).replace(",", "."); // <<<<
        if (i < ni - 1) txt += ",";
      }
      XML_setContent(child, txt);
    }

  }



  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);

    this.WindSpeed = XML_getFloat(parent, this.CLASS_STAMP + ".WindSpeed");
    this.WindDirection = XML_getFloat(parent, this.CLASS_STAMP + ".WindDirection");
    this.Power = XML_getFloat(parent, this.CLASS_STAMP + ".Power");

    this.displayPoints = XML_getBoolean(parent, this.CLASS_STAMP + ".displayPoints");
    this.displayLines = XML_getBoolean(parent, this.CLASS_STAMP + ".displayLines");

    this.RES1 = XML_getInt(parent, this.CLASS_STAMP + ".RES1");
    this.RES2 = XML_getInt(parent, this.CLASS_STAMP + ".RES2");
    this.Grade = XML_getFloat(parent, this.CLASS_STAMP + ".Grade");
    this.displayImage = XML_getBoolean(parent, this.CLASS_STAMP + ".displayImage");
    this.sectionType = XML_getInt(parent, this.CLASS_STAMP + ".sectionType");
    this.positionStep = XML_getFloat(parent, this.CLASS_STAMP + ".positionStep");
    this.Process_subDivisions = XML_getInt(parent, this.CLASS_STAMP + ".Process_subDivisions");
    this.deltaStep = XML_getFloat(parent, this.CLASS_STAMP + ".deltaStep");
    this.deltaLines = XML_getFloat(parent, this.CLASS_STAMP + ".deltaLines");
    this.MinimumDistance_traceU = XML_getFloat(parent, this.CLASS_STAMP + ".MinimumDistance_traceU");
    this.MinimumDistance_traceV = XML_getFloat(parent, this.CLASS_STAMP + ".MinimumDistance_traceV");

    {
      XML child = xml.getChild(this.CLASS_STAMP + ".Z");

      int ni = XML_getInt(child, "ni");
      this.Z = new float [ni];
      String txt = XML_getContent(child);
      String[] parts = split(txt, ",");
      for (int i = 0; i < ni; i++) {
        this.Z[i] = float(parts[i]);
      }
    }

    {
      XML child = xml.getChild(this.CLASS_STAMP + ".R");

      int ni = XML_getInt(child, "ni");
      this.R = new float [ni];
      String txt = XML_getContent(child);
      String[] parts = split(txt, ",");
      for (int i = 0; i < ni; i++) {
        this.R[i] = float(parts[i]);
      }
    }

    {
      XML child = xml.getChild(this.CLASS_STAMP + ".U");

      int ni = XML_getInt(child, "ni");
      this.U = new float [ni];
      String txt = XML_getContent(child);
      String[] parts = split(txt, ",");
      for (int i = 0; i < ni; i++) {
        this.U[i] = float(parts[i]);
      }
    }

    {
        XML child = xml.getChild(this.CLASS_STAMP + ".V");

      int ni = XML_getInt(child, "ni");
      this.V = new float [ni];
      String txt = XML_getContent(child);
      String[] parts = split(txt, ",");
      for (int i = 0; i < ni; i++) {
        this.V[i] = float(parts[i]);
      }
    }

    {
      XML child = xml.getChild(this.CLASS_STAMP + ".X");

      int ni = XML_getInt(child, "ni");
      this.X = new float [ni];
      String txt = XML_getContent(child);
      String[] parts = split(txt, ",");
      for (int i = 0; i < ni; i++) {
        this.X[i] = float(parts[i]);
      }
    }


    {
      XML child = xml.getChild(this.CLASS_STAMP + ".Y");

      int ni = XML_getInt(child, "ni");
      this.Y = new float [ni];
      String txt = XML_getContent(child);
      String[] parts = split(txt, ",");
      for (int i = 0; i < ni; i++) {
        this.Y[i] = float(parts[i]);
      }
    }
  }
}
