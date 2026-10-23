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

// Finds isolated single-pixel hit/miss-flip artifacts without touching
// anything: a residual, very low-probability race in the parallel ray-
// casting these pixels come from (still not fully root-caused, despite a
// long investigation - see ShadeViewport.pde's own comments on what was
// ruled out) can occasionally flip one pixel's alpha the wrong way -
// fully opaque where every neighbor missed, or fully transparent where
// every neighbor hit. That "every available neighbor agrees with each
// other, but not with the center" pattern is exactly what a genuine edge
// or silhouette boundary never looks like - there, neighbors on opposite
// sides of the edge disagree with EACH OTHER too, not just with the
// center - so this only ever flags true isolated outliers, never a real
// boundary. Any neighbor (or the center itself) with alpha outside
// {0, 255} - a genuinely antialiased edge, e.g. a billboard's own
// silhouette in ShadeViewport.pde's normal shading mode - is treated as
// "this is near a real edge" and skipped entirely, rather than guessed
// at.
//
// pixels: a PImage.pixels[]-shaped array (ARGB ints, row-major), RES1
// wide - read only, never written here. Returns the np index of every
// pixel flagged this way; what to actually do about a flagged pixel -
// repairIsolatedPixels() below's own neighbor-color average, or
// something more precise like ShadeViewport.pde's own re-cast-the-ray
// repair - is a separate decision this function has no opinion on.
IntList listIsolatedPixels (int[] pixels, int RES1, int RES2) {
  IntList isolated = new IntList();

  for (int np = 0; np < pixels.length; np++) {
    int centerAlpha = (pixels[np] >> 24) & 0xFF;
    if (centerAlpha != 0 && centerAlpha != 255) continue;
    boolean centerOpaque = (centerAlpha == 255);

    int x = np % RES1;
    int y = np / RES1;

    boolean sawOpaque = false;
    boolean sawTransparent = false;
    boolean sawOther = false;

    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;
        int nx = x + dx;
        int ny = y + dy;
        if (nx < 0 || nx >= RES1 || ny < 0 || ny >= RES2) continue;

        int neighborAlpha = (pixels[ny * RES1 + nx] >> 24) & 0xFF;
        if (neighborAlpha == 255) sawOpaque = true;
        else if (neighborAlpha == 0) sawTransparent = true;
        else sawOther = true;
      }
    }

    if (sawOther) continue; // near a genuine antialiased edge - leave alone

    boolean isolated_outlier = (sawOpaque && !sawTransparent && !centerOpaque) ||
                                (sawTransparent && !sawOpaque && centerOpaque);
    if (isolated_outlier) isolated.append(np);
  }

  return isolated;
}

// Repairs every pixel listIsolatedPixels() above flags, by averaging the
// color of its (all-agreeing) opaque neighbors - or erasing it, if its
// neighbors all agree on transparent instead. See that function's own
// comment for what "isolated" means and why it can't be a real edge.
// Reads from a snapshot taken before any writes, so repairing one pixel
// can never influence whether its own neighbor looks isolated (in
// practice two flagged pixels are never neighbors of each other - each
// would require the other to look uniform, which an isolated pixel by
// definition doesn't - but the snapshot costs little and removes any
// doubt).
void repairIsolatedPixels (int[] pixels, int RES1, int RES2) {
  IntList isolated = listIsolatedPixels(pixels, RES1, RES2);
  int[] original = pixels.clone();

  for (int i = 0; i < isolated.size(); i++) {
    int np = isolated.get(i);
    boolean centerOpaque = (((original[np] >> 24) & 0xFF) == 255);

    int x = np % RES1;
    int y = np / RES1;

    int opaqueNeighborCount = 0;
    long sumR = 0, sumG = 0, sumB = 0;

    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;
        int nx = x + dx;
        int ny = y + dy;
        if (nx < 0 || nx >= RES1 || ny < 0 || ny >= RES2) continue;

        int neighborColor = original[ny * RES1 + nx];
        if (((neighborColor >> 24) & 0xFF) == 255) {
          opaqueNeighborCount++;
          sumR += (neighborColor >> 16) & 0xFF;
          sumG += (neighborColor >> 8) & 0xFF;
          sumB += neighborColor & 0xFF;
        }
      }
    }

    if (!centerOpaque) {
      // every available neighbor hit, this one (alone) missed - repaint
      // with the average color of those (all-opaque) neighbors.
      int avgR = (int) (sumR / opaqueNeighborCount);
      int avgG = (int) (sumG / opaqueNeighborCount);
      int avgB = (int) (sumB / opaqueNeighborCount);
      pixels[np] = color(avgR, avgG, avgB, 255);
    } else {
      // every available neighbor missed, this one (alone) hit - erase it.
      pixels[np] = color(0, 0, 0, 0);
    }
  }
}
