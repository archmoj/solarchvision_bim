int SHADE_HOUR_ANGLE = 8;
int SHADE_DATE_ANGLE = 0;

PImage Shade_RGBA;

void SOLARCHVISION_ShadeViewport () {
  cursor(WAIT);
  SOLARCHVISION_buildFaceGrid();

  int DATE_ANGLE = SHADE_DATE_ANGLE;
  int HOUR_ANGLE = SHADE_HOUR_ANGLE;

  SHADE_HOUR_ANGLE++;
  if (SHADE_HOUR_ANGLE > 16) {
    SHADE_HOUR_ANGLE = 8;
    SHADE_DATE_ANGLE += 90;
  }
  if (SHADE_DATE_ANGLE >= 360) {
    SHADE_DATE_ANGLE = 0;
  }

  float quality = WIN3D.shadingQuality;
  int RES1 = round(WIN3D.dX * quality);
  int RES2 = round(WIN3D.dY * quality);

  Shade_RGBA = createImage(RES1, RES2, ARGB);
  Shade_RGBA.loadPixels();

  float invQuality = 1.0 / quality;
  float invScale    = 1.0 / OBJECTS_scale;
  float halfRES1 = 0.5 * RES1;
  float halfRES2 = 0.5 * RES2;
  boolean isOrtho = (WIN3D.ViewType == 0);

  float baseX = WIN3D.CAM_x * invScale;
  float baseY = WIN3D.CAM_y * invScale;
  float baseZ = WIN3D.CAM_z * invScale;

  // For orthographic views, the ray-center offset only depends on the
  // camera/view, not on the pixel -- compute it once per frame.
  float centerX = 0, centerY = 0, centerZ = 0;
  if (isOrtho) {
    float[] ray_center = WIN3D.calculate_Click3D(0, 0);
    centerX = ray_center[0] * invScale;
    centerY = ray_center[1] * invScale;
    centerZ = ray_center[2] * invScale;
  }

  float[] SunR = funcs.SunPositionRadiation(DATE_ANGLE, HOUR_ANGLE, 0);
  float[] SunV = { SunR[1], SunR[2], SunR[3] };
  float[] SunV_unit = funcs.vec3_unit(new float[]{ SunV[0], SunV[1], SunV[2] });

  float[] ray_start = new float[3];
  float[] ray_direction = new float[3];

  for (int Image_Y_i = 0; Image_Y_i < RES2; Image_Y_i++) {
    float Image_Y = Image_Y_i - halfRES2;

    for (int Image_X_i = 0; Image_X_i < RES1; Image_X_i++) {
      float Image_X = Image_X_i - halfRES1;
      int np = Image_Y_i * RES1 + Image_X_i;

      float[] ray_end = WIN3D.calculate_Click3D(Image_X * invQuality, Image_Y * invQuality);
      ray_end[0] *= invScale;
      ray_end[1] *= invScale;
      ray_end[2] *= invScale;

      ray_start[0] = baseX;
      ray_start[1] = baseY;
      ray_start[2] = baseZ;

      if (isOrtho) {
        ray_start[0] += ray_end[0] - centerX;
        ray_start[1] += ray_end[1] - centerY;
        ray_start[2] += ray_end[2] - centerZ;
      }

      ray_direction[0] = ray_end[0] - ray_start[0];
      ray_direction[1] = ray_end[1] - ray_start[1];
      ray_direction[2] = ray_end[2] - ray_start[2];

      float[] RxP = intersectAll(ray_start, ray_direction);

      if (RxP[0] >= 0) {
        float[] face_norm = { RxP[5], RxP[6], RxP[7] };
        face_norm = funcs.vec3_unit(face_norm);

        if (funcs.vec_dot(face_norm, ray_direction) > 0) { // to render backing faces
          face_norm[0] *= -1;
          face_norm[1] *= -1;
          face_norm[2] *= -1;
        }

        ray_start[0] = RxP[1];
        ray_start[1] = RxP[2];
        ray_start[2] = RxP[3];
        ray_direction[0] = SunV[0];
        ray_direction[1] = SunV[1];
        ray_direction[2] = SunV[2];

        float Alpha = 90 - funcs.acos_ang(face_norm[2]);
        float SkyMask = 0.5 * (1.0 + (Alpha / 90.0));

        float valuesSUM_RAD = SkyMask; // diffuse radiation
        if (SOLARCHVISION_isIntersected_Faces(ray_start, ray_direction, 0) == 0) {
          float SunMask = funcs.vec_dot(SunV_unit, funcs.vec3_unit(face_norm));
          if (SunMask <= 0) SunMask = 0; // removes backing faces

          valuesSUM_RAD += SunMask; // direct radiation
        }

        float v = valuesSUM_RAD * 150;
        Shade_RGBA.pixels[np] = color(v, v, v, 255);
      } else {
        Shade_RGBA.pixels[np] = color(0, 0, 0, 0);
      }
    }
  }

  Shade_RGBA.updatePixels();
  cursor(ARROW);
  WIN3D.showShading = true;
}
