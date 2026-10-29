// Waits for every future in the list to finish, propagating the first
// worker exception encountered (wrapped in a RuntimeException) rather
// than losing it - a silent partial result (some pixels never written
// because their chunk's thread died) would be far worse than failing
// loudly here. Shared by every parallel per-pixel chunk loop in this
// codebase - preBakeViewport.pde's own ray-casting loop, ShadeViewport.
// pde's two passes - so the same wait/propagate behavior doesn't have to
// be hand-copied at each call site.
void awaitAll (java.util.List<java.util.concurrent.Future<?>> futures) {
  for (java.util.concurrent.Future<?> future : futures) {
    try {
      future.get();
    } catch (InterruptedException e) {
      Thread.currentThread().interrupt();
      throw new RuntimeException(e);
    } catch (java.util.concurrent.ExecutionException e) {
      throw new RuntimeException(e.getCause());
    }
  }
}

// Same wait-and-propagate contract as awaitAll() just above (including,
// at the very end, the exact same per-future get()/catch sequence - once
// every future is done, that loop returns or throws immediately, same as
// awaitAll() itself would have, so calling it a second "wait" here costs
// nothing extra), but polls completedChunks[0] on the calling thread
// instead of blocking on each future one at a time - the only way a
// caller this synchronous (preBakeViewport(), called straight from a
// click handler within draw()'s own call chain, with nothing to hand
// this work off to) can still periodically draw and present a progress
// bar: Processing's own screen only actually updates once draw() itself
// returns for that frame, and draw() can't return until this whole call
// does, so without manually forcing a present partway through (see
// drawPrebakeProgressBar()'s own comment on the endDraw()/beginDraw()
// trick that does it), a bare blocking wait - the exact shape awaitAll()
// above is - would leave the screen frozen the entire time regardless of
// how precisely progress is tracked underneath.
//
// Scoped to preBakeViewport()'s own call site, not folded into awaitAll()
// itself: every other parallel loop in this codebase (ShadeViewport.
// pde's two passes, SolarImpacts.pde) shares that one and has no
// equivalent mid-bake UI of its own to refresh, so they keep the
// simpler, already-proven plain blocking wait.
//
// progressWindow is owned by the caller now (preBakeViewport.pde's own
// comment on why: that bar now spans several further steps after this
// call returns, not just this one) - null here means exactly what it
// means at every other show*Progress call site in this codebase
// (showPrebakeProgress off, or headless - preBakeViewport.pde already
// resolved canShowProgressWindow() before ever constructing one), so
// this function itself just falls back to the plain blocking wait rather
// than needing its own separate headless check. rangeMin/rangeMax let
// the caller place this call's own share of a bar that covers more than
// just this one step on a 0-1 scale (preBakeViewport() currently passes
// [0, 0.6]) - percent is still computed 0-100 internally exactly as
// before, just mapped into [rangeMin, rangeMax] on the way out.
void awaitAllWithProgress (java.util.List<java.util.concurrent.Future<?>> futures, int[] completedChunks, int numChunks, ProgressWindow progressWindow, float rangeMin, float rangeMax) {
  if (progressWindow == null) {
    awaitAll(futures);
    return;
  }

  int lastDrawnPercent = -1;

  while (true) {
    boolean allDone = true;
    for (java.util.concurrent.Future<?> future : futures) {
      if (!future.isDone()) {
        allDone = false;
        break;
      }
    }

    int percent = (int) floor(100.0f * completedChunks[0] / numChunks);
    if (percent != lastDrawnPercent) {
      progressWindow.updateFraction(rangeMin + (rangeMax - rangeMin) * percent / 100.0f);
      lastDrawnPercent = percent;
    }

    if (allDone) break;

    try {
      Thread.sleep(50); // poll interval - frequent enough to feel live, far too coarse to meaningfully compete with the worker threads' own ray-casting for CPU
    } catch (InterruptedException e) {
      Thread.currentThread().interrupt();
      throw new RuntimeException(e);
    }
  }

  for (java.util.concurrent.Future<?> future : futures) {
    try {
      future.get();
    } catch (InterruptedException e) {
      Thread.currentThread().interrupt();
      throw new RuntimeException(e);
    } catch (java.util.concurrent.ExecutionException e) {
      throw new RuntimeException(e.getCause());
    }
  }
}

// Finds suspected hit/miss-flip artifacts without touching anything: a
// residual, very low-probability race in the parallel ray-casting these
// pixels come from (still not fully root-caused, despite a long
// investigation - see ShadeViewport.pde's own comments on what was ruled
// out) can occasionally flip one pixel's alpha the wrong way - opaque
// where it should have missed, or transparent where it should have hit.
//
// Flags a pixel whenever the MAJORITY of its available neighbors
// disagree with it.
IntList listSuspectPixels (int[] pixels, int RES1, int RES2) {
  IntList list = new IntList();

  // opposite-direction pairs: N-S, E-W, NE-SW, NW-SE
  int[][] pairs = {
    {0, -1,  0,  1},
    {-1, 0,  1,  0},
    {-1,-1,  1,  1},
    {-1, 1,  1, -1}
  };

  for (int np = 0; np < pixels.length; np++) {
    int COL = pixels[np];
    int centerAlpha = (COL >> 24) & 0xFF;
    int centerRed   = (COL >> 16) & 0xFF;
    int centerGreen = (COL >> 8) & 0xFF;
    int centerBlue  = (COL) & 0xFF;
    float centerColor = centerAlpha / 255.0 * (centerRed + centerGreen + centerBlue) / 3.0;

    int x = np % RES1;
    int y = np / RES1;

    int validPairs = 0;
    int bothDifferentPairs = 0;

    for (int[] pair : pairs) {
      int ax = x + pair[0], ay = y + pair[1];
      int bx = x + pair[2], by = y + pair[3];

      boolean aIn = ax >= 0 && ax < RES1 && ay >= 0 && ay < RES2;
      boolean bIn = bx >= 0 && bx < RES1 && by >= 0 && by < RES2;
      if (!aIn || !bIn) continue; // only count pairs fully inside the image

      boolean aDiff = isDifferent(pixels[ay * RES1 + ax], centerAlpha, centerColor);
      boolean bDiff = isDifferent(pixels[by * RES1 + bx], centerAlpha, centerColor);

      validPairs++;
      if (aDiff && bDiff) bothDifferentPairs++;
    }

    // Isolated point: ALL valid opposite pairs differ on both sides.
    // Edge/corner: at least one pair stays "attached" to the center's region.
    if (validPairs > 0 && bothDifferentPairs == validPairs) {
      list.append(np);
    }
  }
/*
  // show suspect pixel
  for (int np : list) {
    int x = np % RES1;
    int y = np / RES1;

    int m = 3;
    for (int dx = -m; dx <= m; dx++) {
      for (int dy = -m; dy <= m; dy++) {
        if (abs(dx) < m && abs(dy) < m) continue;
        int nx = x + dx;
        int ny = y + dy;
        if (nx < 0 || nx >= RES1 || ny < 0 || ny >= RES2) continue;
        pixels[ny * RES1 + nx] = color(255, 255, 0, 255);
      }
    }
  }
*/
  return list;
}

boolean isDifferent(int COL, int centerAlpha, float centerColor) {
  int nAlpha = (COL >> 24) & 0xFF;
  int nRed   = (COL >> 16) & 0xFF;
  int nGreen = (COL >> 8) & 0xFF;
  int nBlue  = (COL) & 0xFF;
  float nColor = nAlpha / 255.0 * (nRed + nGreen + nBlue) / 3.0;

  boolean diffAlpha = abs(nAlpha - centerAlpha) > 191;
  boolean diffColor = abs(nColor - centerColor) > 31;
  return diffAlpha || diffColor;
}