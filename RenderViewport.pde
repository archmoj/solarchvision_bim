void SOLARCHVISION_RenderViewport () {

  cursor(WAIT);

  println("Rendering Viewport. Please wait...");

  int PAL_type = 0;
  int PAL_direction = 1;
  float PAL_multiplier = 1;

  if (WIN3D.Impact_TYPE == Impact_ACTIVE) {
    PAL_type = allFaces.ACTIVE_palette_CLR;
    PAL_direction = allFaces.ACTIVE_palette_DIR;
    PAL_multiplier = allFaces.ACTIVE_palette_MLT;
  }
  if (WIN3D.Impact_TYPE == Impact_PASSIVE) {
    PAL_type = allFaces.PASSIVE_palette_CLR;
    PAL_direction = allFaces.PASSIVE_palette_DIR;
    PAL_multiplier = allFaces.PASSIVE_palette_MLT;
  }


  int RES1 = WIN3D.dX;
  int RES2 = WIN3D.dY;

  PImage Image_RGBA = createImage(RES1, RES2, ARGB);

  Image_RGBA.loadPixels();

  float Progress = 0;
  float printed_Progress = 0;
  progressBarHeader();
  for (int np = 0; np < (RES1 * RES2); np++) {
    Progress = 100 * np / float(RES1 * RES2);
    float delta = floor(Progress - printed_Progress);
    if(delta >= 1) {
      for(int c = 0; c < delta; c++) {
        print("█");
      }
      printed_Progress = floor(Progress);
    }

    int Image_X = np % RES1;
    int Image_Y = np / RES1;

    Image_X -= 0.5 * WIN3D.dX;
    Image_Y -= 0.5 * WIN3D.dY;

    float[] ray_direction = new float [3];

    float[] ray_start = {
      WIN3D.CAM_x, WIN3D.CAM_y, WIN3D.CAM_z
    };

    float[] ray_end = WIN3D.calculate_Click3D(Image_X, Image_Y);

    ray_start[0] /= OBJECTS_scale;
    ray_start[1] /= OBJECTS_scale;
    ray_start[2] /= OBJECTS_scale;

    ray_end[0] /= OBJECTS_scale;
    ray_end[1] /= OBJECTS_scale;
    ray_end[2] /= OBJECTS_scale;

    if (WIN3D.ViewType == 0) {
      float[] ray_center = WIN3D.calculate_Click3D(0, 0);

      ray_center[0] /= OBJECTS_scale;
      ray_center[1] /= OBJECTS_scale;
      ray_center[2] /= OBJECTS_scale;

      ray_start[0] += ray_end[0] - ray_center[0];
      ray_start[1] += ray_end[1] - ray_center[1];
      ray_start[2] += ray_end[2] - ray_center[2];
    }

    ray_direction[0] = ray_end[0] - ray_start[0];
    ray_direction[1] = ray_end[1] - ray_start[1];
    ray_direction[2] = ray_end[2] - ray_start[2];





    float[] RxP = new float [8];

    RxP = allFaces.intersect(ray_start, ray_direction);

    if (RxP[0] >= 0) {

      int f = int(RxP[0]);


      float[] COL = {
        0, 0, 0, 0
      };

      float[] face_norm = {RxP[5], RxP[6], RxP[7]};
      face_norm = funcs.vec3_unit(face_norm);

      if (funcs.vec_dot(face_norm, ray_direction) > 0) { // to render backing faces
        face_norm[0] *= -1;
        face_norm[1] *= -1;
        face_norm[2] *= -1;
      }


      float Alpha = 90 - funcs.acos_ang(face_norm[2]);
      //float Beta = 180 - funcs.atan2_ang(face_norm[0], face_norm[1]);

      float valuesSUM_RAD = 0;
      float valuesSUM_EFF_P = 0;
      float valuesSUM_EFF_N = 0;
      int valuesNUM = 0;

      float values_R_dir = 1;
      float values_R_dif = 1;
      float values_E_dir = 0.1;
      float values_E_dif = 0.1;


      //float[] SunR = funcs.SunPositionRadiation( DATE_ANGLE, HOUR_ANGLE, ENSEMBLE_FORECAST_values[i][j][LAYER_cloudcover.id][k]);
      float[] SunR = funcs.SunPositionRadiation(0, 12, 0);

      float[] SunV = {
        SunR[1], SunR[2], SunR[3]
      };

      float SunMask = funcs.vec_dot(funcs.vec3_unit(SunV), funcs.vec3_unit(face_norm));
      if (SunMask <= 0) SunMask = 0; // removes backing faces

      float SkyMask = (0.5 * (1.0 + (Alpha / 90.0)));


      // new trace
      ray_start[0] = RxP[1];
      ray_start[1] = RxP[2];
      ray_start[2] = RxP[3];

      ray_direction[0] = SunV[0];
      ray_direction[1] = SunV[1];
      ray_direction[2] = SunV[2];

      //if (funcs.vec_dot(face_norm, ray_direction) > 0)
      { // removes backing faces

        if (SOLARCHVISION_isIntersected_Faces(ray_start, ray_direction, 0) != 0) {
          if (values_E_dir < 0) {
            valuesSUM_EFF_P += -(values_E_dir * SunMask);
            valuesSUM_EFF_N += -(values_E_dif * SkyMask); // adding approximate diffuse radiation effect anyway!
          } else {
            valuesSUM_EFF_N += (values_E_dir * SunMask);
            valuesSUM_EFF_P += (values_E_dif * SkyMask); // adding approximate diffuse radiation effect anyway!
          }

          valuesSUM_RAD += (values_R_dif * SkyMask); // only approximate diffuse radiation!
        } else {
          if (values_E_dir < 0) {
            valuesSUM_EFF_N += -((values_E_dir * SunMask) + (values_E_dif * SkyMask));
          } else {
            valuesSUM_EFF_P += ((values_E_dir * SunMask) + (values_E_dif * SkyMask));
          }

          valuesSUM_RAD += ((values_R_dir * SunMask) + (values_R_dif * SkyMask)); // calculates total radiation
        }
      }
      valuesNUM += 1;

      //-----------------------------
      float valuesSUM = valuesSUM_RAD; // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      //-----------------------------

      float _u = 0;

      if (is_defined(valuesSUM)) {

        if (WIN3D.Impact_TYPE == Impact_ACTIVE) _u = (0.1 * PAL_multiplier * valuesSUM);
        if (WIN3D.Impact_TYPE == Impact_PASSIVE) _u = 0.5 + 0.5 * (0.1 * PAL_multiplier * valuesSUM);

        if (PAL_direction == -1) _u = 1 - _u;
        if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
        if (PAL_direction == 2) _u =  0.5 * _u;
      }

      COL = PAINT.getColorStyle(PAL_type, _u);


      Image_RGBA.pixels[np] = color(COL[1], COL[2], COL[3], COL[0]);
    }

    else Image_RGBA.pixels[np] = color(0,0,0,0);
  }

  for(int c = 0; c < floor(100 - printed_Progress); c++) {
    print("█");
  }
  println();

  Image_RGBA.updatePixels();

  String myFile = Folder_ScreenShots + "/" + createStamp(1, "Render") + ".png";
  Image_RGBA.save(myFile);
  println("File created:" + myFile);

  cursor(ARROW);
}
