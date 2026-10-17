PImage Shade_RGBA;

final int SHADE_HOURS_PER_DAY = 5 * 2;
final int SHADE_FIRST_HOUR = 12 - SHADE_HOURS_PER_DAY / 2; // 7 a.m.
final int SHADE_LAST_HOUR = 12 + SHADE_HOURS_PER_DAY / 2; // 17 p.m.
final int SHADE_STEP_DAYS = 30; //90;

// initial values of choice
int SHADE_HOUR_ANGLE = 8;
int SHADE_DATE_ANGLE = 0;

void ShadeViewport () {
  int DATE_ANGLE = SHADE_DATE_ANGLE;
  int HOUR_ANGLE = SHADE_HOUR_ANGLE;

  showWaitCursor();

  // Force a fresh build, rather than relying on should_rebuildFaceGrid
  // (true only after model_changed() - a geometry edit, never a camera
  // move): Model2Ds.addToFaceGrid()'s tree/person billboards are
  // camera-facing, computed from WIN3D's camera fields at build time, so
  // moving the camera between two bakes with no geometry edit in between
  // would otherwise silently reuse billboards still facing wherever the
  // camera was at the *previous* bake. Gated on two cheap checks first,
  // so a bake that can't possibly need this doesn't pay for it:
  // hasShadingContribution() (nothing in the grid is camera-facing to
  // begin with) and cameraHasMovedSinceFaceGridBuild() (the camera's X/Y
  // - the only part that can actually change a billboard's orientation,
  // see that method's own comment - hasn't moved since the last real
  // build anyway).
  if (allModel2Ds.hasShadingContribution() && cameraHasMovedSinceFaceGridBuild()) {
    should_rebuildFaceGrid = true;
  }
  buildFaceGrid();


  float quality = WIN3D.shadingQuality;
  int RES1 = round(WIN3D.dX * quality);
  int RES2 = round(WIN3D.dY * quality);

  Shade_RGBA = createImage(RES1, RES2, ARGB);
  Shade_RGBA.loadPixels();

  float invQuality = 1.0 / quality;
  float invScale    = 1.0 / overallScale;
  float halfRES1 = 0.5 * RES1;
  float halfRES2 = 0.5 * RES2;
  boolean isOrtho = (WIN3D.projectionTypeIndex == 0);

  float baseX = WIN3D.cameraX * invScale;
  float baseY = WIN3D.cameraY * invScale;
  float baseZ = WIN3D.cameraZ * invScale;

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
        int hitFace = (int) RxP[0];

        // Both trees and people are Model2Ds billboards and so both carry
        // a texture here (entireFaceAlphaTexture[hitFace] != null). A tree
        // is always pasted with its own real photo colors (below) -
        // faceCastsShadow() is true for it, the same flag isIntersected_
        // Faces()'s own ignoreNonShadowCasters uses below, since a tree
        // does cast shadows. A person (faceCastsShadow() false - they
        // don't) goes either the same way or through the flat grayscale
        // radiance fill every opaque surface gets, according to
        // Model2Ds.peopleUseExactTexture - see that field's own comment.
        PImage billboardTex = (entireFaceAlphaTexture != null && hitFace < entireFaceAlphaTexture.size())
          ? entireFaceAlphaTexture.get(hitFace) : null;

        boolean paintExactTexture = (billboardTex != null) && (faceCastsShadow(hitFace) || allModel2Ds.peopleUseExactTexture);

        if (paintExactTexture) {
          // Paint the real photographic color at the exact pixel the ray
          // hit, instead of computing a flat grayscale radiance value for
          // it at all - a tree always takes this path; a person does too
          // when peopleUseExactTexture is on (the default). Reuses the
          // very same UV mapping passesAlphaTest() (isIntersected_Faces.
          // pde) already used to confirm this hit landed on a
          // non-transparent part of the silhouette in the first place, so
          // the two can never disagree on which pixel a hit corresponds
          // to.
          float[] hitPoint = { RxP[1], RxP[2], RxP[3] };
          int[] texel = faceTexturePixel(hitFace, hitPoint);
          Shade_RGBA.pixels[np] = billboardTex.get(texel[0], texel[1]);
        } else {
          // Every opaque surface (faces, terrain, model1ds), and a person
          // whenever peopleUseExactTexture is off: unlike a tree, a
          // person should receive shadows - show up darker when something
          // else blocks the sun from them - so this still runs the same
          // diffuse/direct radiance computation every other surface gets.
          // isIntersected_Faces()'s own ignoreNonShadowCasters=true means
          // a person can never shadow anything else (or even themselves)
          // in this same occlusion test, per billboardTex's own comment
          // above - that part is unconditional, independent of
          // peopleUseExactTexture (which only changes how they're
          // painted, not whether they cast a shadow).
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
          if (isIntersected_Faces(ray_start, ray_direction, 0, true) == 0) {
            float SunMask = funcs.vec_dot(SunV_unit, funcs.vec3_unit(face_norm));
            if (SunMask <= 0) SunMask = 0; // removes backing faces

            valuesSUM_RAD += SunMask; // direct radiation
          }

          float v = valuesSUM_RAD * 150;

          if (billboardTex != null) {
            // A person with peopleUseExactTexture off: the exact same
            // flat grayscale radiance fill as any other opaque surface
            // below (not their own photo colors tinted by it - they're
            // just as much a plain gray radiance-mapped surface as a wall
            // is in this mode, the texture's only job is giving that
            // surface a person-shaped silhouette instead of a rectangle).
            // So only alpha comes from the texture (the real,
            // possibly-antialiased edge value at this pixel, for a soft
            // silhouette boundary rather than a hard cutout) - color
            // comes from v, same as the plain-gray branch.
            float[] hitPoint = { RxP[1], RxP[2], RxP[3] };
            int[] texel = faceTexturePixel(hitFace, hitPoint);
            int texAlpha = (billboardTex.get(texel[0], texel[1]) >> 24) & 0xFF;
            Shade_RGBA.pixels[np] = color(v, v, v, texAlpha);
          } else {
            Shade_RGBA.pixels[np] = color(v, v, v, 255);
          }
        }
      } else {
        Shade_RGBA.pixels[np] = color(0, 0, 0, 0);
      }
    }
  }

  Shade_RGBA.updatePixels();
  showArrowCursor();
  WIN3D.showShading = true;
}

void adjustShadeTime (int steps) {
  if(steps > 0) {
    // step forward
    for(int i = 0; i < steps; i++) {
      SHADE_HOUR_ANGLE++;
      if (SHADE_HOUR_ANGLE > SHADE_LAST_HOUR) {
        SHADE_HOUR_ANGLE = SHADE_FIRST_HOUR;
        SHADE_DATE_ANGLE += SHADE_STEP_DAYS;
      }
      if (SHADE_DATE_ANGLE >= 360) {
        SHADE_DATE_ANGLE = 0;
      }
    }
  } else if(steps < 0) {
    // step backward
    for(int i = 0; i > steps; i--) {
      SHADE_HOUR_ANGLE--;
      if (SHADE_HOUR_ANGLE < SHADE_FIRST_HOUR) {
        SHADE_HOUR_ANGLE = SHADE_LAST_HOUR;
        SHADE_DATE_ANGLE -= SHADE_STEP_DAYS;
      }
      if (SHADE_DATE_ANGLE <= -SHADE_STEP_DAYS) {
        SHADE_DATE_ANGLE = 360 - SHADE_STEP_DAYS;
      }
    }
  }
}