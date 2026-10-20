PImage Shade_RGBA;

// When true, ShadeViewport() builds and saves a transparent-background
// PNG mask containing only the pixels whose ray hits a Model2Ds object
// (a tree or person billboard) to camera2DTexture, instead of computing
// the normal shaded/shadowed preview - see preBakeViewport.pde, the only
// place meant to flip this (and camera2DTexture) around a ShadeViewport()
// call.
boolean noShadeOnlyVisible2DTextures = false;

// Full output path of the 2D-object visibility mask PNG that
// ShadeViewport() saves when noShadeOnlyVisible2DTextures is true, e.g.
// "projects/model-01/shadings/44N/Viewport_2Ds_Camera00.png".
String camera2DTexture = "";

// When true, ShadeViewport() builds and saves a transparent-background
// PNG containing just the visible edges of Faces, painted black, to
// cameraFaceEdgesTexture - instead of computing the normal shaded/
// shadowed preview, or the 2D-object mask above. Meant to be overlaid on
// top of the solar-impact overlay (draw_WIN3D_layers.pde) to make
// building outlines and creases easier to pick out against the heatmap -
// see preBakeViewport.pde, the only place meant to flip this (and
// cameraFaceEdgesTexture) around a ShadeViewport() call.
boolean noShadeOnlyVisibleFaceEdges = false;

// Full output path of the face-edges mask PNG that ShadeViewport() saves
// when noShadeOnlyVisibleFaceEdges is true, e.g.
// "projects/model-01/shadings/44N/Viewport_FaceEdges_Camera00.png".
String cameraFaceEdgesTexture = "";

// preBakeViewport.pde renders the face-edges bake at WIN3D.dX/dY times
// this, rather than at allSolarImpacts.RES1/RES2 like the rest of its
// bakes - crisper, closer-to-antialiased-looking lines once Processing's
// own image() scales this (larger) source down to the (same as always)
// on-screen size draw_WIN3D_layers.pde displays it at, without changing
// anything about how or where it's drawn there.
final int FACE_EDGE_RESOLUTION_MULTIPLIER = 2;

// cos(~2.56 degrees) - two neighboring hits whose (unit) normals dot to at
// least this are treated as the same flat surface by isFaceEdgeBetween()
// below, not a real crease. A small tolerance rather than exact equality,
// since two independently-computed normals for what's geometrically the
// same flat plane aren't guaranteed to come out bit-for-bit identical.
final float FACE_EDGE_NORMAL_DOT_THRESHOLD = 0.999;

// The three states a pixel can be in for the face-edges mode's first pass
// (ShadeViewport() below) - a Face is its own index (>= 0); anything else
// is one of these two, which isFaceEdgeBetween() treats differently: true
// background still gets a silhouette edge against a neighboring Face, a
// Model1D/Model2Ds hit never contributes an edge at all, against a Face or
// anything else.
final int FACE_EDGE_HIT_BACKGROUND = -1;
final int FACE_EDGE_HIT_OTHER_OBJECT = -2;

// Whether two neighboring pixels in the face-edges mask's second pass
// should be painted as an edge between them - hitA/hitB are each a Face
// index (>= 0), FACE_EDGE_HIT_BACKGROUND, or FACE_EDGE_HIT_OTHER_OBJECT;
// nxA/nyA/nzA and nxB/nyB/nzB are that hit's own unit normal, meaningless
// (and unused) when that side isn't a Face. A Model1D/Model2Ds hit never
// contributes an edge, against a Face or against the background - drop
// straight out for either side being FACE_EDGE_HIT_OTHER_OBJECT before
// anything else. Otherwise: true for a Face next to true background (a
// silhouette), false between two background pixels (nothing to outline),
// and between two different Faces only when their normals genuinely
// differ by more than FACE_EDGE_NORMAL_DOT_THRESHOLD - so tessellating
// one flat surface into many same-normal pieces doesn't draw a grid of
// internal edges across it, while an actual crease still shows correctly.
// Pure/no drawing or face-grid access, so it's independently checkable
// without a live PGraphics context, unlike the rest of this per-pixel
// loop.
boolean isFaceEdgeBetween (int hitA, float nxA, float nyA, float nzA, int hitB, float nxB, float nyB, float nzB) {
  if (hitA == FACE_EDGE_HIT_OTHER_OBJECT || hitB == FACE_EDGE_HIT_OTHER_OBJECT) return false;

  boolean aIsFace = hitA >= 0;
  boolean bIsFace = hitB >= 0;

  if (aIsFace != bIsFace) return true;
  if (!aIsFace) return false;
  if (hitA == hitB) return false;

  float dot = nxA * nxB + nyA * nyB + nzA * nzB;
  return dot < FACE_EDGE_NORMAL_DOT_THRESHOLD;
}

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
  //
  // Skipped in mask mode: preBakeViewport() - the only caller that sets
  // noShadeOnlyVisible2DTextures or noShadeOnlyVisibleFaceEdges - already
  // called buildFaceGrid() itself, right before its own main bake loop,
  // with no camera move or geometry edit since, so repeating the same
  // check-and-build here would only pay for it twice.
  if (!noShadeOnlyVisible2DTextures && !noShadeOnlyVisibleFaceEdges) {
    if (allModel2Ds.hasShadingContribution() && cameraHasMovedSinceFaceGridBuild()) {
      should_rebuildFaceGrid = true;
    }
    buildFaceGrid();
  }


  float quality = WIN3D.shadingQuality;
  int RES1 = round(WIN3D.dX * quality);
  int RES2 = round(WIN3D.dY * quality);

  Shade_RGBA = createImage(RES1, RES2, ARGB);
  Shade_RGBA.loadPixels();

  // Maps an offset in RES1/RES2 pixel space back to the click-space
  // calculate_Click3D() below expects. WIN3D.scale is only ever refreshed
  // inside WIN3D.renderFrame() - the normal per-frame draw() cycle - so
  // during a plain live preview it's always in sync with the current
  // WIN3D.dY (renderFrame() just ran this very frame), making this
  // equivalent to the simpler 1/quality. But preBakeViewport() calls this
  // in mask mode after overriding WIN3D.dY to allSolarImpacts.RES2,
  // without ever calling renderFrame() - so WIN3D.scale there is still
  // whatever it was the last time the viewport was actually drawn, at its
  // true on-screen size, not RES2. Deriving
  // invQuality from WIN3D.scale itself - rather than assuming it already
  // matches the current WIN3D.dY/RES2 - keeps the ray mapping correct
  // either way, exactly as preBakeViewport()'s own ScaleToFit does for
  // its Direct/Diffuse bake.
  float invQuality = (WIN3D.scale * WIN3D.referenceScale) / RES2;
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

  // First pass (below) just records which Face each pixel's ray actually
  // hit, -1 for "didn't hit a Face" (no hit at all, or hit something else
  // sharing the same grid - a Model1D or a Model2Ds billboard), and that
  // hit's own (unit) normal; the second pass (after the main loop)
  // compares each pixel against its neighbors and paints the actual
  // black-edges output from that - two different sub-faces only count as
  // an edge if their normals actually differ (isFaceEdgeBetween() below),
  // so tessellating a single flat surface into many pieces doesn't paint
  // a grid of internal edges across it. Two passes because an edge is
  // inherently about a pixel's relationship to ones that, in raster
  // order, haven't been computed yet.
  int[] faceEdgeHit = noShadeOnlyVisibleFaceEdges ? new int[RES1 * RES2] : null;
  float[] faceEdgeNormalX = noShadeOnlyVisibleFaceEdges ? new float[RES1 * RES2] : null;
  float[] faceEdgeNormalY = noShadeOnlyVisibleFaceEdges ? new float[RES1 * RES2] : null;
  float[] faceEdgeNormalZ = noShadeOnlyVisibleFaceEdges ? new float[RES1 * RES2] : null;

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

        if (noShadeOnlyVisibleFaceEdges) {
          // entireFaces_facesEndIndex (isIntersected_Faces.pde) is the
          // exclusive upper bound of the index range allFaces contributed
          // to the shared grid - anything at or past it hit a Model1D or
          // a Model2Ds billboard instead, not a Face.
          if (hitFace < entireFaces_facesEndIndex) {
            faceEdgeHit[np] = hitFace;
            float[] n = funcs.vec3_unit(new float[]{ RxP[5], RxP[6], RxP[7] });
            faceEdgeNormalX[np] = n[0];
            faceEdgeNormalY[np] = n[1];
            faceEdgeNormalZ[np] = n[2];
          } else {
            faceEdgeHit[np] = FACE_EDGE_HIT_OTHER_OBJECT;
          }
          continue;
        }

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

        if (noShadeOnlyVisible2DTextures) {
          // Pure 2D-object (tree/person) visibility mask: paint the real
          // photographic texel at this hit the same way paintExactTexture
          // does below, via the same faceTexturePixel() UV mapping, so
          // this mask and the live shaded preview can never disagree on
          // which pixel a hit corresponds to. Every other pixel - an
          // opaque surface hit, or no hit at all (the RxP[0] < 0 branch
          // below already writes fully transparent) - is left fully
          // transparent, and none of the shadow/radiance work further
          // down runs, since it's irrelevant to a pure mask.
          if (billboardTex != null) {
            float[] hitPoint = { RxP[1], RxP[2], RxP[3] };
            int[] texel = faceTexturePixel(hitFace, hitPoint);
            Shade_RGBA.pixels[np] = billboardTex.get(texel[0], texel[1]);
          } else {
            Shade_RGBA.pixels[np] = color(0, 0, 0, 0);
          }
          continue;
        }

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
          float SkyMask = 0.5 * (1.0 + funcs.sin_ang(Alpha));

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
      } else if (noShadeOnlyVisibleFaceEdges) {
        faceEdgeHit[np] = FACE_EDGE_HIT_BACKGROUND;
      } else {
        Shade_RGBA.pixels[np] = color(0, 0, 0, 0);
      }
    }
  }

  // Second pass for the face-edges mode: now that every pixel's hit face
  // and normal are known, paint a pixel black wherever isFaceEdgeBetween()
  // says it and its right or below neighbor are actually a genuine edge
  // (treating "off the edge of the image" as nothing to compare against,
  // not as an edge in itself) - a silhouette against the true background
  // and a real crease between two different Faces both paint; a Face's
  // boundary against a Model1D/Model2Ds billboard in front of or behind
  // it never does (isFaceEdgeBetween()'s own comment) - transparent
  // everywhere else.
  if (noShadeOnlyVisibleFaceEdges) {
    for (int Image_Y_i = 0; Image_Y_i < RES2; Image_Y_i++) {
      for (int Image_X_i = 0; Image_X_i < RES1; Image_X_i++) {
        int np = Image_Y_i * RES1 + Image_X_i;

        boolean isEdge = (Image_X_i + 1 < RES1) && isFaceEdgeBetween(
          faceEdgeHit[np], faceEdgeNormalX[np], faceEdgeNormalY[np], faceEdgeNormalZ[np],
          faceEdgeHit[np + 1], faceEdgeNormalX[np + 1], faceEdgeNormalY[np + 1], faceEdgeNormalZ[np + 1]
        );
        if (!isEdge && Image_Y_i + 1 < RES2) {
          isEdge = isFaceEdgeBetween(
            faceEdgeHit[np], faceEdgeNormalX[np], faceEdgeNormalY[np], faceEdgeNormalZ[np],
            faceEdgeHit[np + RES1], faceEdgeNormalX[np + RES1], faceEdgeNormalY[np + RES1], faceEdgeNormalZ[np + RES1]
          );
        }

        Shade_RGBA.pixels[np] = isEdge ? color(0, 0, 0, 255) : color(0, 0, 0, 0);
      }
    }
  }

  Shade_RGBA.updatePixels();

  if (noShadeOnlyVisible2DTextures) {
    Shade_RGBA.save(camera2DTexture);
    println(camera2DTexture);
  }

  if (noShadeOnlyVisibleFaceEdges) {
    Shade_RGBA.save(cameraFaceEdgesTexture);
    println(cameraFaceEdgesTexture);
  }

  showArrowCursor();

  if (!noShadeOnlyVisible2DTextures && !noShadeOnlyVisibleFaceEdges) {
    // draw_WIN3D_layers.pde stretches Shade_RGBA to WIN3D.dX x WIN3D.dY
    // with no aspect correction, which only matches the live preview
    // (sized off WIN3D.dX/dY itself). The mask is a background bake, sized
    // at the unrelated allSolarImpacts.RES1/RES2, and was never meant to
    // be shown over the viewport - flagging it for display here would
    // both pop up an overlay nobody asked for and stretch it wrong.
    WIN3D.showShading = true;
  }
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