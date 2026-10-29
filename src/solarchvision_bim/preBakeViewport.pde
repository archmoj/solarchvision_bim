// A small borderless native AWT window showing the progress of a long,
// synchronous computation (preBakeViewport() below; calculate_
// VertexSolar_array.pde, the "Skin Potential" graph's own - see that
// file's own comment, since clicking "Skin Potential" itself (UI_rollout.
// pde's render button, setimpactGraphIndex()) doesn't recompute
// anything, the underlying per-face data does) - NOT drawn through
// Processing's own P2D/JOGL-backed canvas at all. An earlier version
// tried drawing straight onto that canvas and forcing a mid-frame
// present via g.endDraw()/g.beginDraw() - it never actually appeared,
// which lines up with how this sketch's own renderer (P2D,
// solarchvision_bim.pde's own settings()) really presents frames: JOGL/
// NEWT's own animator thread drives the buffer swap on its own cycle,
// not simply whenever endDraw() happens to be called, so calling it
// manually mid an already-open frame didn't trigger one.
//
// AWT is a completely separate windowing toolkit from JOGL/NEWT, with
// its own event-dispatch thread, already running in this same JVM
// process regardless (java.awt.Toolkit/Clipboard are already imported,
// solarchvision_bim.pde's own imports) - a plain AWT Frame updates and
// actually appears on screen the moment repaint() is called, independent
// of whatever Processing's own thread is doing or blocked on. This is
// the standard, portable Java technique for showing progress during a
// long synchronous call, rather than something specific to this
// renderer - but it's still worth confirming directly once built, same
// as the earlier attempt should have been before being taken on faith.
//
// Floats free on screen rather than pinned to any particular Processing
// UI element (UI_rollout.pde's own SOLARCHVISION render button, say) - a
// separate OS window has no reliable way to know any Processing-drawn
// element's exact on-screen position (especially relative to Processing's
// own window, which this doesn't query), so centering on the default
// screen is the simplest, most robustly correct placement for either
// caller; move it if a more precise position turns out to matter once
// this is confirmed working.
// Whether a ProgressWindow (below) can actually be created here, on top
// of whichever show*Progress flag (globals.pde) a given caller checks -
// java.awt.GraphicsEnvironment.isHeadless() is the standard, reliable
// Java check for "is there an actual display to put a window on", NOT
// control != USER_AUTO (the existing console-bar guard throughout this
// codebase, e.g. calculate_VertexSolar_array.pde's own) - that one only
// distinguishes interactive-GUI output from automated/batch output
// (control defaults to USER_GUI, not USER_AUTO, so it's true by default
// in a plain test app too), it was never meant to detect whether a
// display actually exists, and the two aren't reliably the same thing:
// a batch/USER_AUTO run can still have a real display, same as the many
// existing unit tests that call import_objects_OBJ()/import_objects_IFC()
// directly (confirmed, not assumed) do NOT have one at all - without
// this check, every one of those would have thrown
// java.awt.HeadlessException the moment this feature's own window tried
// to construct, something a console print() never risked.
boolean canShowProgressWindow () {
  return !java.awt.GraphicsEnvironment.isHeadless();
}

class ProgressWindow extends java.awt.Frame {
  volatile float fraction = 0;
  String label;

  ProgressWindow (String label) {
    super(label);
    this.label = label;
    this.setUndecorated(true);
    this.setSize(280, 44);
    this.setLocationRelativeTo(null); // centers on the default screen
    this.setAlwaysOnTop(true);
    this.setBackground(new java.awt.Color(240, 240, 240));
  }

  void paint (java.awt.Graphics g) {
    int w = this.getWidth();
    int h = this.getHeight();

    g.setColor(new java.awt.Color(230, 230, 230));
    g.fillRect(0, 0, w, h);

    g.setColor(java.awt.Color.BLACK);
    g.drawRect(5, 5, w - 11, h - 11);

    g.setColor(new java.awt.Color(255, 204, 0)); // same bold amber/gold as the render button itself
    g.fillRect(6, 6, (int) ((w - 12) * constrain(this.fraction, 0, 1)), h - 12);

    g.setColor(java.awt.Color.BLACK);
    g.drawString(this.label + ": " + (int) (this.fraction * 100) + "%", 10, h - 16);
  }

  // Paints synchronously, directly on the calling thread, rather than
  // calling this.repaint() (AWT's normal path) - repaint() only queues a
  // paint event for AWT's own event-dispatch thread to get to whenever it
  // next runs, which is fine when each call here is separated by enough
  // real work (preBakeViewport()'s own ray-casting, calculate_
  // VertexSolar_array()'s own per-face loop) for the EDT to catch up in
  // between, but import_objects_IFC()'s/import_objects_OBJ()'s own per-
  // entity/per-line parsing can be fast enough that the whole import
  // finishes and dispose()s this window before the EDT ever gets a single
  // chance to actually paint anything - an empty window that flashes by,
  // confirmed against a real IFC import, not a hypothetical. Painting
  // directly here - still just as cheap and rare as before (only called
  // from inside each caller's own delta >= 1 throttle, not every single
  // iteration) - guarantees the bar is actually drawn before this method,
  // and whatever loop iteration called it, returns, regardless of how
  // fast the surrounding work is.
  void updateFraction (float f) {
    this.fraction = f;
    java.awt.Graphics g = this.getGraphics();
    if (g != null) {
      this.paint(g);
      g.dispose();
    }
  }
}

void preBakeViewport () {

  int preBakeViewport_startMillis = millis();

  showWaitCursor();

  println("PreBaking for Direct and Diffuse models. Please wait...");

  // Force a fresh build - see ShadeViewport.pde's own comment on this:
  // Model2Ds.addToFaceGrid()'s tree/person billboards are camera-facing,
  // and this method's own intersectAll() below (for each screen pixel)
  // needs that to reflect the camera as it is right now, not whatever it
  // was the last time anything rebuilt the grid. Gated the same way too -
  // no point forcing it when there's nothing camera-facing to refresh, or
  // when the part of the camera that actually matters (X/Y) hasn't moved
  // since the last real build.
  if (allModel2Ds.hasShadingContribution() && cameraHasMovedSinceFaceGridBuild()) {
    should_rebuildFaceGrid = true;
  }
  buildFaceGrid();

  // Per-phase breakdown, to find out where time actually goes instead of
  // guessing: reset after each phase's own print below. Separate from
  // preBakeViewport_startMillis, which stays fixed for the one final
  // grand-total line.
  int phaseStartMillis = millis();
  println("buildFaceGrid() finished in " + nf((phaseStartMillis - preBakeViewport_startMillis) / 1000.0, 0, 2) + "s");

  cameraIndex = 0;

  allSolarImpacts.sectionType = 1; // <<<<< so that it analyzed later!

  int start_DATE_ANGLE = 0;
  int step_DATE_ANGLE = 30;
  int end_DATE_ANGLE = 360 - step_DATE_ANGLE;

  int start_HOUR = 4; // to make it faster. Also the images are not needed out of this period.
  int step_HOUR = 1;
  int end_HOUR = 20; // to make it faster. Also the images are not needed out of this period.

  SceneName = "Viewport_" + Viewport_Stamp();

  // The camera this whole bake - Direct/Diffuse PNGs, and the Model2Ds
  // mask - is actually computed from. See win3DOverlay_recordCameraState()'s
  // own comment (SolarImpacts.pde) for why this needs to happen here,
  // rather than wherever calculate_Impact_CurrentPreBaked() next happens
  // to run.
  allSolarImpacts.win3DOverlay_recordCameraState();

  int pre_WIN3D_dX = WIN3D.dX;
  int pre_WIN3D_dY = WIN3D.dY;

  WIN3D.dX = allSolarImpacts.RES1;
  WIN3D.dY = allSolarImpacts.RES2;
  WIN3D.view_R = float(WIN3D.dY) / float(WIN3D.dX);

  WIN3D.transform_3DViewport();

  //WIN3D.put_3DViewport();  //????????????

  float ScaleToFit = float(pre_WIN3D_dY) / float(WIN3D.dY);


  int RES1 = WIN3D.dX;
  int RES2 = WIN3D.dY;

  float[][] Diffuse_Matrix = new float [2][(RES1 * RES2)];

  int numDateAngles = (end_DATE_ANGLE - start_DATE_ANGLE) / step_DATE_ANGLE + 1;
  int numHours = (end_HOUR - start_HOUR) / step_HOUR + 1;
  int n_Map = numDateAngles * numHours;

  int[] Map_DATE_ANGLE = new int [n_Map];
  float[] Map_HOUR_ANGLE = new float [n_Map];

  {
    int m = 0;
    for (int DATE_ANGLE = start_DATE_ANGLE; DATE_ANGLE <= end_DATE_ANGLE; DATE_ANGLE += step_DATE_ANGLE) {
      for (int i = start_HOUR; i <= end_HOUR; i += step_HOUR) {
        Map_DATE_ANGLE[m] = DATE_ANGLE;
        Map_HOUR_ANGLE[m] = i;
        m += 1;
      }
    }
  }

  float[][] Map_DirectVector = new float [n_Map][3];
  float[][] Map_UnitDirectVector = new float [n_Map][3];
  boolean[] Map_SunBelowHorizon = new boolean [n_Map];

  for (int m = 0; m < n_Map; m++) {
    float[] SunR = funcs.SunPosition(STATION.getLatitude(), Map_DATE_ANGLE[m], Map_HOUR_ANGLE[m]);

    Map_DirectVector[m][0] = SunR[1];
    Map_DirectVector[m][1] = SunR[2];
    Map_DirectVector[m][2] = SunR[3];

    Map_UnitDirectVector[m] = funcs.vec3_unit(Map_DirectVector[m]);

    Map_SunBelowHorizon[m] = (SunR[3] < 0);
  }

  PImage[][] Direct_RGBA = new PImage [n_Map][2];

  // lastHitDirect/lastHitDiffuse (the isIntersected_Faces() firstGuess
  // coherence hints) used to be single arrays shared and carried across
  // every pixel in raster order. Now that the pixel loop below is
  // parallelized, each chunk gets its own fresh pair instead - see that
  // loop's own comment on why this doesn't change any pixel's final
  // value, only how much of the hint survives at a chunk boundary.

  float[][] UnitDiffuseVectors = new float [DiffuseVectors.length][3];
  for (int n_Ray = 0; n_Ray < DiffuseVectors.length; n_Ray++) {
    UnitDiffuseVectors[n_Ray] = funcs.vec3_unit(DiffuseVectors[n_Ray]);
  }

  for (int m = 0; m < n_Map; m++) {
    for (int SHD = 0; SHD <= 1; SHD++) {
      Direct_RGBA[m][SHD] = createImage(RES1, RES2, ARGB);
      Direct_RGBA[m][SHD].loadPixels();
    }
  }

  // Parallel ray-casting: every pixel's work (intersectAll() for the
  // primary ray, then DiffuseVectors.length + n_Map secondary rays off
  // that hit point) reads only data that's fixed for the whole bake
  // (camera, geometry, sun/sky directions) and writes only to indices
  // (np, and np within its own m-indexed slot) that no other pixel ever
  // touches - Diffuse_Matrix[][np], Direct_RGBA[m][SHD].pixels[np] - so
  // there's nothing for two pixels' work to race on. The one piece of
  // state that WAS shared and mutated across pixels before - the
  // lastHitDirect/lastHitDiffuse firstGuess hints - only ever affects how
  // fast isIntersected_Faces() finds a ray's nearest hit, never which
  // face it finds (that function's own comment, and
  // FaceIntersectionTest's firstGuess-correctness tests), so giving each
  // chunk below its own fresh copies instead of one shared pair doesn't
  // change a single pixel's final value - only how much of that
  // coherence survives at a chunk boundary.
  //
  // intersectAll()/isIntersected_Faces() are called here through their
  // explicit-stamp overloads (isIntersected_Faces.pde), passing each
  // chunk's own plain local faceTestStampLocal/currentRayStampLocal,
  // rather than through the ThreadLocal-backed overloads this loop used
  // to go through (and that every other caller - mouseClicked,
  // calculate_VertexSolar_array.pde, etc. - still does; unaffected).
  // ShadeViewport.pde's own parallel pass hit stray per-pixel hit/miss
  // corruption traced to ThreadLocal.get() itself under real multi-core
  // concurrency, not to the grid walk or its dedup logic - see that
  // file's own comment on how that was narrowed down - and this loop
  // calls the very same ThreadLocal-backed isIntersected_Faces() from
  // multiple threads at once, so it carries the identical exposure even
  // without a report of it having been noticed here yet. A plain local
  // array/counter that one thread owns outright for a chunk's whole
  // duration doesn't have that problem.
  //
  // The progress bar tracks completed CHUNKS now, not individual pixels:
  // chunks finish concurrently and out of order across threads, so
  // there's no single increasing np to measure percent-through-the-image
  // against any more. Each chunk, on finishing, grabs progressPrintLock
  // and prints however many of the 100 block characters its own
  // completion newly covers (same floor()-based delta as the old
  // per-pixel version, just keyed on chunks-done instead of
  // pixels-done) - so the bar still reaches exactly 100 characters when
  // the last chunk finishes, same as before, just filled in out of
  // left-to-right order as whichever chunk happens to finish next.
  int numThreads = max(1, Runtime.getRuntime().availableProcessors());
  int totalPixels = RES1 * RES2;
  // Several chunks per thread, not one: a pixel that hits geometry costs
  // far more (DiffuseVectors.length + n_Map secondary ray casts) than one
  // that misses straight into transparent background, so splitting into
  // more, smaller chunks than threads lets the pool's own work queue even
  // that unevenness out across threads, instead of some thread getting
  // stuck with a geometry-heavy region while others, done with their
  // mostly-background chunks, sit idle.
  int numChunks = min(totalPixels, numThreads * 8);
  int chunkSize = (totalPixels + numChunks - 1) / numChunks; // ceiling division

  // completedChunks is only ever mutated inside the synchronized block
  // below, alongside printedBlocks - the lock, not the atomic increment,
  // is what keeps two threads from computing overlapping block-character
  // ranges, so a plain int[1] holder (mutable through the lambda's
  // effectively-final reference to it) is enough; no actual AtomicInteger
  // needed.
  final int[] completedChunks = {0};
  final int[] printedBlocks = {0};
  final Object progressPrintLock = new Object();

  if (control != USER_AUTO) progressBarHeader();

  java.util.concurrent.ExecutorService executor = java.util.concurrent.Executors.newFixedThreadPool(numThreads);
  java.util.List<java.util.concurrent.Future<?>> futures = new java.util.ArrayList<java.util.concurrent.Future<?>>();

  for (int chunkStart = 0; chunkStart < totalPixels; chunkStart += chunkSize) {
    final int npFrom = chunkStart;
    final int npTo = min(totalPixels, chunkStart + chunkSize);

    futures.add(executor.submit(() -> {
      int[] lastHitDirect_local = new int[n_Map]; // zero-filled, fresh per chunk - see this loop's own comment above
      int[] lastHitDiffuse_local = new int[DiffuseVectors.length];
      int[] faceTestStampLocal = new int[faceTestStampSize];
      int[] currentRayStampLocal = { 0 };

      for (int np = npFrom; np < npTo; np++) {
        int Image_X = np % RES1;
        int Image_Y = np / RES1;

        Image_X -= 0.5 * WIN3D.dX;
        Image_Y -= 0.5 * WIN3D.dY;

        float[] ray_direction = new float [3];

        float[] ray_start = {
          WIN3D.cameraX, WIN3D.cameraY, WIN3D.cameraZ
        };

        float[] ray_end = WIN3D.calculate_Click3D(Image_X * ScaleToFit, Image_Y * ScaleToFit);

        ray_start[0] /= overallScale;
        ray_start[1] /= overallScale;
        ray_start[2] /= overallScale;

        ray_end[0] /= overallScale;
        ray_end[1] /= overallScale;
        ray_end[2] /= overallScale;

        if (WIN3D.projectionTypeIndex == 0) {
          float[] ray_center = WIN3D.calculate_Click3D(0, 0);

          ray_center[0] /= overallScale;
          ray_center[1] /= overallScale;
          ray_center[2] /= overallScale;

          ray_start[0] += ray_end[0] - ray_center[0];
          ray_start[1] += ray_end[1] - ray_center[1];
          ray_start[2] += ray_end[2] - ray_center[2];
        }

        ray_direction[0] = ray_end[0] - ray_start[0];
        ray_direction[1] = ray_end[1] - ray_start[1];
        ray_direction[2] = ray_end[2] - ray_start[2];


        float[] RxP = intersectAll(ray_start, ray_direction, 0, faceTestStampLocal, currentRayStampLocal);

        if (RxP[0] >= 0) {

          float[] face_norm = {RxP[5], RxP[6], RxP[7]};
          face_norm = funcs.vec3_unit(face_norm);

          for (int n_Ray = 0; n_Ray < DiffuseVectors.length; n_Ray++) {

            float SkyMask = funcs.vec_dot(UnitDiffuseVectors[n_Ray], face_norm);

            // A backing direction (this face's normal points away from it)
            // contributes 0 to both Diffuse_Matrix rows regardless of
            // whether isIntersected_Faces() below would find it occluded -
            // SHD=0 adds SkyMask (0 either way) and SHD=1 adds either
            // SkyMask (0) or a flat 0, same result. So there's nothing the
            // ray cast could change here: skip it rather than pay for it
            // only to throw the result away. This is often true for roughly
            // half of DiffuseVectors on a vertical wall, and for nearly all
            // of them on a downward-facing underside.
            if (SkyMask <= 0) continue;

            // when SHD = 0;
            Diffuse_Matrix[0][np] += SkyMask / (float(DiffuseVectors.length) / 2.0);

            // new trace
            ray_start[0] = RxP[1];
            ray_start[1] = RxP[2];
            ray_start[2] = RxP[3];

            ray_direction[0] = DiffuseVectors[n_Ray][0];
            ray_direction[1] = DiffuseVectors[n_Ray][1];
            ray_direction[2] = DiffuseVectors[n_Ray][2];

            lastHitDiffuse_local[n_Ray] = isIntersected_Faces(ray_start, ray_direction, lastHitDiffuse_local[n_Ray], true, faceTestStampLocal, currentRayStampLocal); // people don't cast shadows - see entireFaceCastsShadow's own comment

            // when SHD = 1;
            if (lastHitDiffuse_local[n_Ray] == 0) {
              Diffuse_Matrix[1][np] += SkyMask / (float(DiffuseVectors.length) / 2.0);
            }
            // else: already left at its default 0 - no occluded-sky contribution.
          }

          for (int m = 0; m < n_Map; m++) {

            // Below the horizon, both SHD=0 and SHD=1 come out color(0, 255)
            // regardless of what isIntersected_Faces() below would find - a
            // sun that isn't up can't light this pixel whether or not
            // something would otherwise have shaded it. Map_SunBelowHorizon[m]
            // depends only on m, not on this pixel, so this also skips every
            // other field the ray cast would otherwise need (ray_direction,
            // SunMask) for the same reason. Nothing the ray cast could change
            // here: skip it rather than pay for it only to throw the result
            // away.
            if (Map_SunBelowHorizon[m]) {
              Direct_RGBA[m][0].pixels[np] = color(0, 255);
              Direct_RGBA[m][1].pixels[np] = color(0, 255);
              continue;
            }

            // new trace
            ray_start[0] = RxP[1];
            ray_start[1] = RxP[2];
            ray_start[2] = RxP[3];

            ray_direction[0] = Map_DirectVector[m][0];
            ray_direction[1] = Map_DirectVector[m][1];
            ray_direction[2] = Map_DirectVector[m][2];

            float SunMask = funcs.vec_dot(Map_UnitDirectVector[m], face_norm);
            //if (SunMask <= 0) SunMask = 0; // removes backing faces

            // when SHD = 0;
            Direct_RGBA[m][0].pixels[np] = color(255 * SunMask, 255);

            // when SHD = 1;

            lastHitDirect_local[m] = isIntersected_Faces(ray_start, ray_direction, lastHitDirect_local[m], true, faceTestStampLocal, currentRayStampLocal); // people don't cast shadows - see entireFaceCastsShadow's own comment

            if (lastHitDirect_local[m] == 0) {
              Direct_RGBA[m][1].pixels[np] = color(255 * SunMask, 255);
            }
            else Direct_RGBA[m][1].pixels[np] = color(0, 255);
          }
        }
        else {

          for (int m = 0; m < n_Map; m++) {
            for (int SHD = 0; SHD <= 1; SHD++) {
              Direct_RGBA[m][SHD].pixels[np] = color(0,0,0,0);
            }
          }

          for (int SHD = 0; SHD <= 1; SHD++) {
            Diffuse_Matrix[SHD][np] = FLOAT_undefined;
          }

        }
      }

      if (control != USER_AUTO) {
        synchronized (progressPrintLock) {
          int done = ++completedChunks[0];
          int targetBlocks = floor(100.0f * done / numChunks);
          if (targetBlocks > printedBlocks[0]) {
            StringBuilder barBuffer = new StringBuilder();
            for (int c = printedBlocks[0]; c < targetBlocks; c++) {
              barBuffer.append('█');
            }
            print(barBuffer.toString()); // one print() call instead of `delta` calls
            printedBlocks[0] = targetBlocks;
          }
        }
      }
    }));
  }

  // showPrebakeProgress (globals.pde) off: the exact same, already-proven
  // blocking wait as every other parallel loop in this codebase. On: a
  // polling wait that also draws and presents the progress bar
  // (awaitAllWithProgress()'s own comment, parallel_utils.pde, on why a
  // bare blocking wait can't show one at all).
  if (showPrebakeProgress) {
    awaitAllWithProgress(futures, completedChunks, numChunks);
  } else {
    awaitAll(futures); // see parallel_utils.pde's own comment
  }
  executor.shutdown();

  // Rounding each chunk's own target down to whole block characters can
  // leave the bar a character or two short of 100 once every chunk has
  // actually finished (same as the old per-pixel version's own
  // wrap-up) - top it up here, single-threaded, now that nothing's
  // still writing to printedBlocks.
  if (control != USER_AUTO) {
    for (int c = printedBlocks[0]; c < 100; c++) {
      print("█");
    }
    println();
  }

  println("Ray-casting loop (" + (RES1 * RES2) + " pixels) finished in " + nf((millis() - phaseStartMillis) / 1000.0, 0, 2) + "s");
  phaseStartMillis = millis();

  for (int m = 0; m < n_Map; m++) {

    for (int SHD = 0; SHD <= 1; SHD++) {

      String File_Name = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName;

      File_Name += nf(Map_DATE_ANGLE[m], 3) + "_" + STR_SHD[SHD] + "_" + nf(int(funcs.roundTo(Map_HOUR_ANGLE[m] * 100, 1.0)), 4);

      File_Name += "_Camera" + nf(cameraIndex, 2);

      Direct_RGBA[m][SHD].updatePixels();

      Direct_RGBA[m][SHD].save(File_Name + ".png");

      // only print first and last files
      if (m == 0 || m == n_Map - 1) {
        println(File_Name + ".png");
      } else if (m == 1 && SHD == 0) {
        println("...");
      }
    }
  }

  println("Direct_RGBA PNG saves (" + (n_Map * 2) + " files) finished in " + nf((millis() - phaseStartMillis) / 1000.0, 0, 2) + "s");
  phaseStartMillis = millis();

  PImage[] Diffuse_RGBA = new PImage [2];

  for (int SHD = 0; SHD <= 1; SHD++) {

    String File_Name = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName;

    File_Name += "DIF_" + STR_SHD[SHD];

    File_Name += "_Camera" + nf(cameraIndex, 2);

    Diffuse_RGBA[SHD] = createImage(RES1, RES2, ARGB);

    Diffuse_RGBA[SHD].loadPixels();

    for (int np = 0; np < (RES1 * RES2); np++) {

      if (is_defined(Diffuse_Matrix[SHD][np])) {

        Diffuse_RGBA[SHD].pixels[np] = color(255 * Diffuse_Matrix[SHD][np], 255);
      }
      else {

        Diffuse_RGBA[SHD].pixels[np] = color(0,0,0,0);
      }
    }

    Diffuse_RGBA[SHD].updatePixels();


    Diffuse_RGBA[SHD].save(File_Name + ".png");

    println(File_Name + ".png");
  }

  println("Diffuse_RGBA PNG saves (2 files) finished in " + nf((millis() - phaseStartMillis) / 1000.0, 0, 2) + "s");

  // Bake the Model2Ds-only (tree/person) visibility mask alongside the
  // Direct/Diffuse images just saved above, at this same prebake
  // resolution and under the same Folder_Shadings/NearLatitude_Stamp()/
  // Camera folder - this is ShadeViewport_2DsTexture()'s own former body,
  // inlined here now that this is its only caller. No need to redo its
  // WIN3D.dX/dY/view_R/transform_3DViewport() setup: WIN3D.dX/dY are
  // already allSolarImpacts.RES1/RES2 from the top of this function, and
  // nothing since has touched them or the camera.
  camera2DTexture = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName + "2Ds_Camera" + nf(cameraIndex, 2) + ".png";

  float preShadingQuality = WIN3D.shadingQuality;
  WIN3D.shadingQuality = 1;

  println("Baking Model2Ds visibility mask (ShadeViewport() call #1 below)...");
  noShadeOnlyVisible2DTextures = true;
  ShadeViewport();
  noShadeOnlyVisible2DTextures = false;

  // Same reasoning, same setup already in place - just the one extra
  // ShadeViewport() call, in its own mode, saving its own file. Rendered
  // at FACE_EDGE_RESOLUTION_MULTIPLIER times the usual resolution (see
  // that constant's own comment, ShadeViewport.pde): WIN3D.dX/dY
  // temporarily doubled for just this one call - ShadeViewport()'s own
  // invQuality already derives itself from whichever RES1/RES2 actually
  // end up in use (its own comment on that), rather than assuming
  // RES1/RES2 == WIN3D.dX/dY * quality, so the field of view comes out
  // correct at the higher resolution too with no other change needed.
  cameraFaceEdgesTexture = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName + "FaceEdges_Camera" + nf(cameraIndex, 2) + ".png";

  int pre_faceEdges_dX = WIN3D.dX;
  int pre_faceEdges_dY = WIN3D.dY;
  WIN3D.dX = pre_faceEdges_dX * FACE_EDGE_RESOLUTION_MULTIPLIER;
  WIN3D.dY = pre_faceEdges_dY * FACE_EDGE_RESOLUTION_MULTIPLIER;

  println("Baking face-edges texture at " + FACE_EDGE_RESOLUTION_MULTIPLIER + "x resolution (ShadeViewport() call #2 below)...");
  noShadeOnlyVisibleFaceEdges = true;
  ShadeViewport();
  noShadeOnlyVisibleFaceEdges = false;

  WIN3D.dX = pre_faceEdges_dX;
  WIN3D.dY = pre_faceEdges_dY;

  WIN3D.shadingQuality = preShadingQuality;

  showArrowCursor();

  WIN3D.dX = pre_WIN3D_dX;
  WIN3D.dY = pre_WIN3D_dY;
  WIN3D.view_R = float(WIN3D.dY) / float(WIN3D.dX);

  // Includes the two ShadeViewport() calls above (2Ds mask, face-edges
  // texture) - each also prints its own elapsed time on the way, so this
  // total and their two sub-totals are both visible, not just the sum.
  println("preBakeViewport() finished in " + nf((millis() - preBakeViewport_startMillis) / 1000.0, 0, 2) + "s");
}
