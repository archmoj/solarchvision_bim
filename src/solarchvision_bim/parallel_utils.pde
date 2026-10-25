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

  for (int np = 0; np < pixels.length; np++) {
    int COL = pixels[np];
    int centerAlpha = (COL >> 24) & 0xFF;
    int centerRed   = (COL >> 16) & 0xFF;
    int centerGreen = (COL >> 8) & 0xFF;
    int centerBlue  = (COL) & 0xFF;

    int x = np % RES1;
    int y = np / RES1;

    int neighborAlpha = 0;
    int neighborRed = 0;
    int neighborGreen = 0;
    int neighborBlue = 0;
    int neighborCount = 0;
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;
        int nx = x + dx;
        int ny = y + dy;
        if (nx < 0 || nx >= RES1 || ny < 0 || ny >= RES2) continue;

        COL = pixels[ny * RES1 + nx];
        neighborAlpha += (COL >> 24) & 0xFF;
        neighborRed   += (COL >> 16) & 0xFF;
        neighborGreen += (COL >> 8) & 0xFF;
        neighborBlue  += (COL) & 0xFF;
        neighborCount++;
      }
    }
    if (neighborCount > 0) {
      neighborAlpha /= neighborCount;
      neighborRed   /= neighborCount;
      neighborGreen /= neighborCount;
      neighborBlue  /= neighborCount;
    }

    float neighborColor = neighborAlpha / 255.0 * (neighborRed + neighborGreen + neighborBlue) / 3.0;
    float centerColor = centerAlpha / 255.0 * (centerRed + centerGreen + centerBlue) / 3.0;

    boolean suspectAlpha = abs(neighborAlpha - centerAlpha) > 191;
    boolean suspectColor = abs(neighborColor - centerColor) > 63;

    if (suspectAlpha || suspectColor) list.append(np);
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
