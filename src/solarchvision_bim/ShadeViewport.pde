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

final int SHADE_HOURS_PER_DAY = 24;
final int SHADE_FIRST_HOUR = 12 - SHADE_HOURS_PER_DAY / 2;
final int SHADE_LAST_HOUR = 12 + SHADE_HOURS_PER_DAY / 2;
final int SHADE_STEP_DAYS = 30; //90;

// initial values of choice
int SHADE_HOUR_ANGLE = 10;
int SHADE_DATE_ANGLE = -1; // This would be set to TIME.beginDay later in the process.

volatile boolean isShadingViewport = false;

// Derives pixel np's own primary camera ray into the caller's own
// ray_start/ray_direction arrays - the same math for pass 1's per-pixel
// loop below (many threads, one call each) and the single-threaded
// repair loop right after it (a handful of calls, one per flagged
// pixel) - so the two can't quietly drift apart from each other. Takes
// the output arrays as parameters rather than allocating and returning
// a new pair each call, so each caller keeps deciding its own allocation
// pattern (pass 1: a fresh pair per pixel; the repair loop: same).
void deriveShadeRay (
  int np, int RES1, float halfRES1, float halfRES2,
  float invQuality, float invScale, float baseX, float baseY, float baseZ,
  boolean isOrtho, float centerX, float centerY, float centerZ,
  float[] ray_start, float[] ray_direction
) {
  int Image_X_i = np % RES1;
  int Image_Y_i = np / RES1;
  float Image_X = Image_X_i - halfRES1;
  float Image_Y = Image_Y_i - halfRES2;

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
}

void ShadeViewport () {
  isShadingViewport = true;
  int ShadeViewport_startMillis = millis();

  // Timing breakdown, same spirit as SolarImpacts.pde's own calcImpact_*
  // timers - shadeSetupMillis is whatever's left over (buildFaceGrid(),
  // everything before pass 1 dispatches, and the arraycopy/save/cursor
  // work at the very end), computed as a remainder rather than tracked
  // at each of its own scattered call sites.
  long shadePass1Millis = 0;
  long shadeListSuspectsMillis = 0;
  long shadeFixSuspectsMillis = 0;
  long shadePass2Millis = 0;


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

  int[] shadeBuffer = new int[RES1 * RES2];

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
  // camera/view, not on the pixel -- compute it once per frame. Assigned
  // exactly once along either path (not a default value followed by a
  // conditional overwrite) so these stay effectively final - the
  // parallel pixel loop below captures them in a lambda, which requires
  // it.
  float centerX, centerY, centerZ;
  if (isOrtho) {
    float[] ray_center = WIN3D.calculate_Click3D(0, 0);
    centerX = ray_center[0] * invScale;
    centerY = ray_center[1] * invScale;
    centerZ = ray_center[2] * invScale;
  } else {
    centerX = 0;
    centerY = 0;
    centerZ = 0;
  }

  sync_SHADE_DATE_ANGLE();

  float[] SunR = funcs.SunPositionRadiation(SHADE_DATE_ANGLE, SHADE_HOUR_ANGLE, 0);
  float[] SunV = { SunR[1], SunR[2], SunR[3] };
  float[] SunV_unit = funcs.vec3_unit(new float[]{ SunV[0], SunV[1], SunV[2] });

  // SunR[3] (the sun direction's own z-component) is at/below 0 whenever
  // the sun itself is at/below the horizon - the earth should be
  // blocking every direct-sun ray at that point, but this model has no
  // actual ground geometry for the shadow ray below to intersect, so
  // without this guard isIntersected_Faces() would come back
  // unoccluded and let faces still pick up a spurious direct-radiation
  // contribution at night. Computed once here (SunR is the same for
  // every pixel this call), rather than re-checked per pixel below.
  boolean sunIsBelowHorizon = (SunR[3] <= 0);

  // Moon3D.pde's own simplified model (funcs.MoonPosition's own comment)
  // reused here, same DATE/HOUR inputs the Sun already uses, purely as a
  // second, much weaker light source for the sunIsBelowHorizon case below
  // - a real moon only lights (and casts its own faint shadows) at
  // night, never alongside direct sunlight, and only while it's actually
  // above the horizon itself (MoonR[3] > 0) - a sun-down night with the
  // moon also below the horizon gets no direct light at all, same as
  // before this. Computed unconditionally (cheap, a few trig calls), not
  // just when sunIsBelowHorizon, so moonIsAboveHorizon below reads
  // naturally either way.
  float[] MoonR = funcs.MoonPosition(STATION.getLatitude(), SHADE_DATE_ANGLE, SHADE_HOUR_ANGLE);
  float[] MoonV = { MoonR[1], MoonR[2], MoonR[3] };
  float[] MoonV_unit = funcs.vec3_unit(new float[]{ MoonV[0], MoonV[1], MoonV[2] });
  boolean moonIsAboveHorizon = sunIsBelowHorizon && (MoonR[3] > 0);

  // How much of a full direct-light contribution (the same SunMask/
  // MoonMask dot-product term, see below) the Moon gets, relative to the
  // Sun - "slight" per this feature's own ask, nowhere near the Sun's
  // own full-strength term, just enough to pick out subtle moonlit
  // highlights and shadows against an otherwise flat-diffuse night face.
  final float MOON_DIRECT_RADIATION_FACTOR = 0.15;

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

  // This pass is independent per pixel - it reads only data that's fixed
  // for this whole call (camera, geometry, sun direction) and writes
  // only its own np's slot of Shade_RGBA.pixels[]/faceEdgeHit[]/
  // faceEdgeNormalX,Y,Z[] - so there's nothing for two pixels' work to
  // race on, same reasoning as preBakeViewport.pde's own parallel
  // ray-casting loop (see that loop's own comment). ray_start/
  // ray_direction used to be declared once above the loop and mutated in
  // place every pixel - each pixel below now gets its own fresh pair
  // instead, same as preBakeViewport.pde's own loop: matches that
  // proven-safe pattern exactly, rather than reusing one mutable pair
  // per chunk across many pixels on the same thread.
  //
  // intersectAll()/isIntersected_Faces() are called here through their
  // explicit-stamp overloads (isIntersected_Faces.pde), passing each
  // chunk's own plain local faceTestStampLocal/currentRayStampLocal,
  // rather than through the ThreadLocal-backed overloads every other
  // caller still uses (preBakeViewport.pde, calculate_VertexSolar_array.
  // pde, mouseClicked, etc. - unaffected). ThreadLocal.get(), not the
  // grid walk or its dedup logic itself, turned out to be the actual
  // source of stray per-pixel hit/miss corruption here under real
  // multi-core concurrency - narrowed down empirically against a
  // single-triangle scene simple enough that nothing else could explain
  // it. A plain local array/counter that one thread owns outright for a
  // chunk's whole duration doesn't have that problem: declared once per
  // chunk below (not once per pixel - this lambda runs start to finish
  // on one thread, so there's no one else to share these with), reused
  // across every pixel that chunk processes, the same way the
  // ThreadLocal path reuses one RayStampState across every pixel a given
  // thread ever touches. The single shadow ray this function casts per
  // pixel has always been called with firstGuess=0 (no coherence hint
  // carried between pixels even before any of this), so there's nothing
  // else to seed here beyond the stamp state itself.
  //
  // Chunking also matches preBakeViewport.pde's own choice, not a single
  // big chunk per thread: numChunks here comes out far larger than
  // numThreads (chunkSize works out to roughly numThreads pixels per
  // chunk), so the pool's own work queue keeps handing out many small
  // chunks over the run instead of each thread claiming one giant,
  // unbroken range for the whole pass. totalPixels can be smaller than
  // numThreads (a tiny test image, say), so numChunks is floored at 1 to
  // avoid a division by zero in chunkSize below.
  int numThreads = max(1, Runtime.getRuntime().availableProcessors());
  int totalPixels = shadeBuffer.length;
  int numChunks = max(1, totalPixels / numThreads);
  int chunkSize = (totalPixels + numChunks - 1) / numChunks; // ceiling division

  java.util.concurrent.ExecutorService executor = java.util.concurrent.Executors.newFixedThreadPool(numThreads);

  long shadePass1T0 = millis();
  java.util.List<java.util.concurrent.Future<?>> pass1Futures = new java.util.ArrayList<java.util.concurrent.Future<?>>();
  for (int chunkStart = 0; chunkStart < totalPixels; chunkStart += chunkSize) {
    final int npFrom = chunkStart;
    final int npTo = min(totalPixels, chunkStart + chunkSize);

    pass1Futures.add(executor.submit(() -> {
      int[] faceTestStampLocal = new int[faceTestStampSize];
      int[] currentRayStampLocal = { 0 };

      for (int np = npFrom; np < npTo; np++) {
        float[] ray_start = new float[3];
        float[] ray_direction = new float[3];
        deriveShadeRay(np, RES1, halfRES1, halfRES2, invQuality, invScale, baseX, baseY, baseZ,
          isOrtho, centerX, centerY, centerZ, ray_start, ray_direction);

        float[] RxP = intersectAll(ray_start, ray_direction, 0, faceTestStampLocal, currentRayStampLocal);

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
              shadeBuffer[np] = billboardTex.get(texel[0], texel[1]);
            } else {
              shadeBuffer[np] = color(0, 0, 0, 0);
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
            shadeBuffer[np] = billboardTex.get(texel[0], texel[1]);
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

            float Alpha = 90 - funcs.acos_ang(face_norm[2]);
            float SkyMask = 0.5 * (1.0 + funcs.sin_ang(Alpha));

            float valuesSUM_RAD = SkyMask; // diffuse radiation
            if (!sunIsBelowHorizon) {
              // The common case: full-strength direct sunlight, same as
              // always.
              ray_direction[0] = SunV[0];
              ray_direction[1] = SunV[1];
              ray_direction[2] = SunV[2];

              if (isIntersected_Faces(ray_start, ray_direction, 0, true, faceTestStampLocal, currentRayStampLocal) == 0) {
                float SunMask = funcs.vec_dot(SunV_unit, funcs.vec3_unit(face_norm));
                if (SunMask <= 0) SunMask = 0; // removes backing faces

                valuesSUM_RAD += SunMask; // direct radiation
              }
            } else if (moonIsAboveHorizon) {
              // Sun down, Moon up: the exact same shadow-ray/dot-product
              // shape as the Sun's own branch above, just toward the
              // Moon instead and scaled down to a slight contribution
              // (MOON_DIRECT_RADIATION_FACTOR, above) - a faint, subtly
              // directional moonlit highlight and shadow rather than
              // another full "sun".
              ray_direction[0] = MoonV[0];
              ray_direction[1] = MoonV[1];
              ray_direction[2] = MoonV[2];

              if (isIntersected_Faces(ray_start, ray_direction, 0, true, faceTestStampLocal, currentRayStampLocal) == 0) {
                float MoonMask = funcs.vec_dot(MoonV_unit, funcs.vec3_unit(face_norm));
                if (MoonMask <= 0) MoonMask = 0; // removes backing faces

                valuesSUM_RAD += MOON_DIRECT_RADIATION_FACTOR * MoonMask; // slight moonlit direct contribution
              }
            }
            // else: Sun and Moon both below the horizon - no direct-light
            // ray cast at all, same diffuse-only SkyMask shading as
            // before this feature, for the same no-ground-geometry
            // reason the Sun's own sunIsBelowHorizon guard exists for.

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
              shadeBuffer[np] = color(v, v, v, texAlpha);
            } else {
              shadeBuffer[np] = color(v, v, v, 255);
            }
          }
        } else if (noShadeOnlyVisibleFaceEdges) {
          faceEdgeHit[np] = FACE_EDGE_HIT_BACKGROUND;
        } else {
          shadeBuffer[np] = color(0, 0, 0, 0);
        }
      }
    }));
  }
  awaitAll(pass1Futures); // see parallel_utils.pde's own comment
  shadePass1Millis += millis() - shadePass1T0;

  // Single-threaded, right after pass 1 finishes, before the arraycopy
  // into Shade_RGBA below reads this pass's output. See parallel_utils.
  // pde's own listSuspectPixels() for what "isolated" means and why it
  // can't be a real edge - this re-casts each flagged pixel's own ray
  // and redoes pass 1's own shading logic for it, the same way Solar
  // Impacts.pde's own per-day palette loop re-casts a ray and redoes its
  // own per-pixel palette computation (see that loop's own comment).
  // Only meaningful in plain shaded-preview mode: the 2D-object mask's
  // alpha comes from a billboard texture, not a hit/miss bit, and face-
  // edges mode doesn't write shadeBuffer at all in pass 1 (faceEdgeHit[]/
  // faceEdgeNormalX,Y,Z[] are its real output here) - so this is skipped
  // entirely in both.
  if (!noShadeOnlyVisible2DTextures && !noShadeOnlyVisibleFaceEdges) {
    long shadeListSuspectsT0 = millis();
    IntList suspectPixels = listSuspectPixels(shadeBuffer, RES1, RES2);
    shadeListSuspectsMillis += millis() - shadeListSuspectsT0;

    int[] repairStamp = new int[faceTestStampSize];
    int[] repairCounter = { 0 };

    long shadeFixSuspectsT0 = millis();
    for (int np : suspectPixels) {
      float[] ray_start = new float[3];
      float[] ray_direction = new float[3];
      deriveShadeRay(np, RES1, halfRES1, halfRES2, invQuality, invScale, baseX, baseY, baseZ,
        isOrtho, centerX, centerY, centerZ, ray_start, ray_direction);

      float[] RxP = intersectAll(ray_start, ray_direction, 0, repairStamp, repairCounter);

      if (RxP[0] >= 0) {
        int hitFace = (int) RxP[0];

        PImage billboardTex = (entireFaceAlphaTexture != null && hitFace < entireFaceAlphaTexture.size())
          ? entireFaceAlphaTexture.get(hitFace) : null;

        boolean paintExactTexture = (billboardTex != null) && (faceCastsShadow(hitFace) || allModel2Ds.peopleUseExactTexture);

        if (paintExactTexture) {
          float[] hitPoint = { RxP[1], RxP[2], RxP[3] };
          int[] texel = faceTexturePixel(hitFace, hitPoint);
          shadeBuffer[np] = billboardTex.get(texel[0], texel[1]);
        } else {
          float[] face_norm = { RxP[5], RxP[6], RxP[7] };
          face_norm = funcs.vec3_unit(face_norm);

          if (funcs.vec_dot(face_norm, ray_direction) > 0) {
            face_norm[0] *= -1;
            face_norm[1] *= -1;
            face_norm[2] *= -1;
          }

          ray_start[0] = RxP[1];
          ray_start[1] = RxP[2];
          ray_start[2] = RxP[3];

          float Alpha = 90 - funcs.acos_ang(face_norm[2]);
          float SkyMask = 0.5 * (1.0 + funcs.sin_ang(Alpha));

          // Same sunIsBelowHorizon/moonIsAboveHorizon branching as pass 1
          // above - keeps this repair pass from disagreeing with pass 1
          // on pixels it re-casts.
          float valuesSUM_RAD = SkyMask;
          if (!sunIsBelowHorizon) {
            ray_direction[0] = SunV[0];
            ray_direction[1] = SunV[1];
            ray_direction[2] = SunV[2];

            if (isIntersected_Faces(ray_start, ray_direction, 0, true, repairStamp, repairCounter) == 0) {
              float SunMask = funcs.vec_dot(SunV_unit, funcs.vec3_unit(face_norm));
              if (SunMask <= 0) SunMask = 0;
              valuesSUM_RAD += SunMask;
            }
          } else if (moonIsAboveHorizon) {
            ray_direction[0] = MoonV[0];
            ray_direction[1] = MoonV[1];
            ray_direction[2] = MoonV[2];

            if (isIntersected_Faces(ray_start, ray_direction, 0, true, repairStamp, repairCounter) == 0) {
              float MoonMask = funcs.vec_dot(MoonV_unit, funcs.vec3_unit(face_norm));
              if (MoonMask <= 0) MoonMask = 0;
              valuesSUM_RAD += MOON_DIRECT_RADIATION_FACTOR * MoonMask;
            }
          }

          float v = valuesSUM_RAD * 150;

          if (billboardTex != null) {
            float[] hitPoint = { RxP[1], RxP[2], RxP[3] };
            int[] texel = faceTexturePixel(hitFace, hitPoint);
            int texAlpha = (billboardTex.get(texel[0], texel[1]) >> 24) & 0xFF;
            shadeBuffer[np] = color(v, v, v, texAlpha);
          } else {
            shadeBuffer[np] = color(v, v, v, 255);
          }
        }
      } else {
        shadeBuffer[np] = color(0, 0, 0, 0);
      }
    }
    shadeFixSuspectsMillis += millis() - shadeFixSuspectsT0;
  }

  /*
  // DIAGNOSTIC BUILD: redundantly recompute just the primary ray's hit/
  // miss decision for every pixel, single-threaded, with its own fresh
  // local stamp state (no sharing with anything the parallel pass above
  // used), and compare it against what shadeBuffer actually got from the
  // parallel run. This is a ground-truth check, not a performance path -
  // a single thread casting rays one at a time cannot race with itself,
  // so any mismatch here is proof the parallel run computed a genuinely
  // different answer for that exact pixel, not just noise from comparing
  // two separate program runs' PNGs. Only meaningful in non-mask,
  // non-face-edges mode, where shadeBuffer's alpha channel (0 vs. >0)
  // directly reflects RxP[0]'s hit/miss - the mode this is being run
  // against right now. Prints the first 25 mismatches with enough detail
  // (coordinates, which face each run thought it hit) to chase further;
  // remove this block once the remaining race is found.
  if (!noShadeOnlyVisible2DTextures && !noShadeOnlyVisibleFaceEdges) {
    int[] seqStamp = new int[faceTestStampSize];
    int[] seqCounter = { 0 };
    int mismatches = 0;

    for (int np = 0; np < totalPixels; np++) {
      int Image_X_i = np % RES1;
      int Image_Y_i = np / RES1;
      float Image_X = Image_X_i - halfRES1;
      float Image_Y = Image_Y_i - halfRES2;

      float[] ray_start = new float[3];
      float[] ray_direction = new float[3];

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

      float[] seqRxP = intersectAll(ray_start, ray_direction, 0, seqStamp, seqCounter);
      boolean seqHit = seqRxP[0] >= 0;
      boolean parallelHit = ((shadeBuffer[np] >> 24) & 0xFF) != 0;

      if (seqHit != parallelHit) {
        mismatches++;
        if (mismatches <= 25) {
          println("MISMATCH np=" + np + " (x=" + Image_X_i + ", y=" + Image_Y_i + "): " +
            "sequential=" + (seqHit ? ("HIT face " + (int) seqRxP[0]) : "MISS") + ", " +
            "parallel=" + (parallelHit ? "HIT" : "MISS") + ", " +
            "parallel alpha=" + ((shadeBuffer[np] >> 24) & 0xFF));
        }
      }
    }
    println("Self-verification: " + mismatches + " / " + totalPixels + " pixels disagreed between the parallel run and a fresh single-threaded recompute.");
  }
*/

  // Second pass for the face-edges mode: now that every pixel's hit face
  // and normal are known, paint a pixel black wherever isFaceEdgeBetween()
  // says it and its right or below neighbor are actually a genuine edge
  // (treating "off the edge of the image" as nothing to compare against,
  // not as an edge in itself) - a silhouette against the true background
  // and a real crease between two different Faces both paint; a Face's
  // boundary against a Model1D/Model2Ds billboard in front of or behind
  // it never does (isFaceEdgeBetween()'s own comment) - transparent
  // everywhere else.
  //
  // Independent per pixel the same way pass 1 is - each np only reads
  // faceEdgeHit[]/faceEdgeNormalX,Y,Z[] (fully written by every thread by
  // the time awaitAll(pass1Futures) above returns - neighbors included,
  // since that's a full barrier across the whole image, not just this
  // chunk) and writes only its own np's Shade_RGBA.pixels[] - so again
  // nothing for two pixels' work to race on. Unlike pass 1, this pass
  // never calls isIntersected_Faces()/intersectAll() at all - isFace
  // EdgeBetween() is a pure comparison over already-computed arrays - so
  // there's no RayStampState/ThreadLocal exposure here to begin with, and
  // no per-chunk stamp state to allocate. Reuses the same executor and
  // chunk boundaries as pass 1: this pass is strictly sequential *after*
  // pass 1 (every pixel's neighbors must already be computed), never
  // concurrent with it, so there's no reason to size or pool it
  // differently.
  if (noShadeOnlyVisibleFaceEdges) {
    long shadePass2T0 = millis();
    java.util.List<java.util.concurrent.Future<?>> pass2Futures = new java.util.ArrayList<java.util.concurrent.Future<?>>();
    for (int chunkStart = 0; chunkStart < totalPixels; chunkStart += chunkSize) {
      final int npFrom = chunkStart;
      final int npTo = min(totalPixels, chunkStart + chunkSize);

      pass2Futures.add(executor.submit(() -> {
        for (int np = npFrom; np < npTo; np++) {
          int Image_X_i = np % RES1;
          int Image_Y_i = np / RES1;

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

          shadeBuffer[np] = isEdge ? color(0, 0, 0, 255) : color(0, 0, 0, 0);
        }
      }));
    }
    awaitAll(pass2Futures); // see parallel_utils.pde's own comment
    shadePass2Millis += millis() - shadePass2T0;
  }

  executor.shutdown();

  // Single-threaded, after every worker thread has finished (executor.
  // shutdown() above only stops new tasks from being submitted - both
  // awaitAll() calls above are what actually guarantee every chunk's
  // writes into shadeBuffer are done and visible here). This is the only
  // point in this whole function that touches Shade_RGBA.pixels[].
  System.arraycopy(shadeBuffer, 0, Shade_RGBA.pixels, 0, shadeBuffer.length);

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
    //
    // Sticky from here on (draw_WIN3D_layers.pde no longer clears this
    // itself after one frame) - stays up across camera moves, re-shading
    // to a new hour/day (this same flag, just set true again over
    // whatever Shade_RGBA this call just produced), anything short of an
    // explicit dismissShading() call below, from Esc.
    WIN3D.showShading = true;

    // This bake, whatever triggered it (an explicit "Shade Viewport"/
    // Space/Backspace request, or draw_WIN3D_layers.pde's own auto-
    // rebuild below), reflects the current camera/model state as of right
    // now, so whatever earlier view_changed()/model_changed() call(s) set
    // this mid-bake are moot - clear it here rather than leaving draw_
    // WIN3D_layers.pde to immediately see it still set and redo the same
    // work again next frame for no reason.
    WIN3D.shadingNeedsRebuild = false;

    // Unconditional, regardless of how this bake was triggered - see
    // this field's own comment (WIN3D.pde) for why it has to be, unlike
    // shadingNeedsRebuild just above.
    WIN3D.shadingNeedsRepaint = true;
  }

  long shadeTotalMillis = millis() - ShadeViewport_startMillis;
  long shadeSetupMillis = shadeTotalMillis - shadePass1Millis - shadeListSuspectsMillis - shadeFixSuspectsMillis - shadePass2Millis;
  println("\nShadeViewport() timing:");
  println("  total:            " + shadeTotalMillis + " ms");
  println("  pass 1:           " + shadePass1Millis + " ms (" + nf(100.0 * shadePass1Millis / shadeTotalMillis, 0, 1) + "%)");
  println("  list suspects:    " + shadeListSuspectsMillis + " ms (" + nf(100.0 * shadeListSuspectsMillis / shadeTotalMillis, 0, 1) + "%)");
  println("  fix suspects:     " + shadeFixSuspectsMillis + " ms (" + nf(100.0 * shadeFixSuspectsMillis / shadeTotalMillis, 0, 1) + "%)");
  println("  pass 2:           " + shadePass2Millis + " ms (" + nf(100.0 * shadePass2Millis / shadeTotalMillis, 0, 1) + "%)");
  println("  setup/other:      " + shadeSetupMillis + " ms (" + nf(100.0 * shadeSetupMillis / shadeTotalMillis, 0, 1) + "%)");

  println("ShadeViewport() finished in " + nf((millis() - ShadeViewport_startMillis) / 1000.0, 0, 2) + "s");

  isShadingViewport = false;
}

void nextShadeHour () {
  for (int i = 0; i < 24; i++) {
    SHADE_HOUR_ANGLE++;
    if (SHADE_HOUR_ANGLE > SHADE_LAST_HOUR) {
      SHADE_HOUR_ANGLE = SHADE_FIRST_HOUR;
    }

    if (STUDY.isInHourlyRange(SHADE_HOUR_ANGLE)) return;
  }
}

void previousShadeHour () {
  for (int i = 0; i < 24; i++) {
    SHADE_HOUR_ANGLE--;
    if (SHADE_HOUR_ANGLE < SHADE_FIRST_HOUR) {
      SHADE_HOUR_ANGLE = SHADE_LAST_HOUR;
    }

    if (STUDY.isInHourlyRange(SHADE_HOUR_ANGLE)) return;
  }
}

void nextShadeDay () {
  callAction("Next Impact Day");
}

void previousShadeDay () {
  callAction("Previous Impact Day");
}

// The day-of-year index (TIME.convert2Date()'s own 0-364, Jan-1-is-0
// convention - not the (286 + ...) % 365 shift SHADE_DATE_ANGLE's own
// degrees are built from, see sync_SHADE_DATE_ANGLE() below for that
// extra step) a given impactDisplayDay slot represents. impactDisplayDay
// == 0 ("total") is treated the same as 1 (STUDY.dayIncrement * 0 steps
// from TIME.beginDay) - "use beginDay for the case of total" below.
// Pulled out of sync_SHADE_DATE_ANGLE() itself so Tropo3D.pde's own
// selectedDayHasForecastAvailable() (its own comment) can ask "what
// actual calendar day does impactDisplayDay N represent" without
// duplicating this math a second time and risking the two drifting apart.
int impactDayToDayOfYear (int day) {
  int j = day - 1;
  if (j == -1) j = 0; // use beginDay for the case of total

  int now_j = (j * int(STUDY.dayIncrement) + TIME.beginDay + 365) % 365;

  if (now_j >= 365) {
    now_j = now_j % 365;
  }
  if (now_j < 0) {
    now_j = (now_j + 365) % 365;
  }

  return now_j;
}

void sync_SHADE_DATE_ANGLE () {
  int now_j = impactDayToDayOfYear(impactDisplayDay);

  SHADE_DATE_ANGLE = (int) (360 * ((286 + now_j) % 365) / 365.0);
}

// Turns off the sticky shaded-viewport overlay ShadeViewport() leaves on
// screen (see WIN3D.showShading's own comment there and in
// draw_WIN3D_layers.pde) - the Esc cascade's own way of ending that
// preview, same boolean-returning-"did I actually have something to do"
// shape as cancelActivePickList()/removeLastHoverPoint() (mouseClicked.
// pde/hover.pde) that the rest of that same cascade already uses, so Esc
// only consumes itself here (and stops short of also removing a pinned
// hover point the person never asked to touch) when shading was actually
// showing.
boolean dismissShading () {
  if (!WIN3D.showShading) return false;

  WIN3D.showShading = false;
  WIN3D.shadingNeedsRebuild = false; // nothing left to rebuild towards
  WIN3D.shadingNeedsRepaint = false; // nothing left to paint towards, either

  // Turning showShading off alone wouldn't actually repaint anything:
  // draw_WIN3D_layers.pde's own early-return gate (its own comment)
  // skips WIN3D.draw() entirely on a frame where nothing else needs it,
  // which - with no camera/model change, just this flag flipping - would
  // leave the last-drawn shaded pixels sitting on screen forever instead
  // of clearing back to the live, un-shaded view. view_changed() forces
  // that one real repaint. Safe to call here, after showShading is
  // already false: view_changed()'s own shadingNeedsRebuild check
  // (global_functions.pde) only fires while showShading is still true,
  // so this can't turn around and immediately re-flag a rebuild for an
  // overlay that's no longer shown.
  view_changed();

  return true;
}
