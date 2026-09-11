int RENDER_HOUR_ANGLE = 8;
int RENDER_DATE_ANGLE = 0;

void SOLARCHVISION_RenderViewport () {

  cursor(WAIT);

  SOLARCHVISION_buildFaceGrid();

  int DATE_ANGLE = RENDER_DATE_ANGLE;
  int HOUR_ANGLE = RENDER_HOUR_ANGLE;
  RENDER_HOUR_ANGLE++;
  if(RENDER_HOUR_ANGLE > 16) {
    RENDER_HOUR_ANGLE = 8;

    RENDER_DATE_ANGLE += 90;
  }
  if(RENDER_DATE_ANGLE >= 360) {
    RENDER_DATE_ANGLE = 0;
  }

  float quality = WIN3D.renderQuality;

  int RES1 = round(WIN3D.dX * quality);
  int RES2 = round(WIN3D.dY * quality);

  Render_RGBA = createImage(RES1, RES2, ARGB);

  Render_RGBA.loadPixels();

  for (int np = 0; np < (RES1 * RES2); np++) {

    int Image_X = np % RES1;
    int Image_Y = np / RES1;

    Image_X -= 0.5 * RES1;
    Image_Y -= 0.5 * RES2;

    float[] ray_direction = new float [3];

    float[] ray_start = {
      WIN3D.CAM_x, WIN3D.CAM_y, WIN3D.CAM_z
    };

    float[] ray_end = WIN3D.calculate_Click3D(
      Image_X / quality,
      Image_Y / quality
    );

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

    RxP = intersectAll(ray_start, ray_direction);

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

      float valuesSUM_RAD = 0;

      float values_R_dir = 1;
      float values_R_dif = 1;

      float[] SunR = funcs.SunPositionRadiation(DATE_ANGLE, HOUR_ANGLE, 0);

      float[] SunV = {
        SunR[1], SunR[2], SunR[3]
      };

      float SunMask = funcs.vec_dot(funcs.vec3_unit(SunV), funcs.vec3_unit(face_norm));
      if (SunMask <= 0) SunMask = 0; // removes backing faces

      float SkyMask = (0.5 * (1.0 + (Alpha / 90.0)));


      ray_start[0] = RxP[1];
      ray_start[1] = RxP[2];
      ray_start[2] = RxP[3];

      ray_direction[0] = SunV[0];
      ray_direction[1] = SunV[1];
      ray_direction[2] = SunV[2];

      //if (funcs.vec_dot(face_norm, ray_direction) > 0)
      { // removes backing faces

        valuesSUM_RAD += values_R_dif * SkyMask; // diffuse radiation

        if (SOLARCHVISION_isIntersected_Faces(ray_start, ray_direction, 0) == 0) {
          valuesSUM_RAD += values_R_dir * SunMask; // direct radiation
        }
      }

      float valuesSUM = valuesSUM_RAD;

      float _u = 0;

      COL = PAINT.getColorStyle(19, 0.125 * valuesSUM);


      Render_RGBA.pixels[np] = color(COL[1], COL[2], COL[3], COL[0]);
    }

    else Render_RGBA.pixels[np] = color(0,0,0,0);
  }

  Render_RGBA.updatePixels();

  cursor(ARROW);

  WIN3D.showRender = true;
}
