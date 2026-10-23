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
// disagree with it (a simple count, not requiring them to unanimously
// agree with each other first - see below for why that requirement was
// dropped). Any neighbor with alpha outside {0, 255} - a genuinely
// antialiased edge, e.g. a billboard's own silhouette in ShadeViewport.
// pde's normal shading mode - simply isn't counted either way, rather
// than guessed at; the center itself still has to be a clean 0 or 255 to
// be considered at all.
//
// This used to require every available neighbor to unanimously agree
// with each other before flagging anything, specifically so a genuine
// edge or silhouette boundary - where neighbors on opposite sides
// legitimately disagree with EACH OTHER, not just with the center -
// could never be mistaken for noise. That mattered when a flagged pixel
// got "repaired" by averaging neighbor colors: a false positive there
// would visibly blur a real boundary. Now that every caller instead
// re-casts that one pixel's own ray and redoes its own per-pixel
// computation for the authoritative answer (ShadeViewport.pde and
// SolarImpacts.pde, each at their own call site), a false positive just
// re-confirms the same correct value at the cost of one extra
// recompute - not a correctness risk anymore. Loosening this to a
// majority vote catches genuinely corrupted pixels that happen to sit
// near real geometry edges, which the old unanimous-agreement rule could
// never flag even when the center itself was wrong.
//
// pixels: a PImage.pixels[]-shaped array (ARGB ints, row-major), RES1
// wide - read only, never written here. Returns the np index of every
// pixel flagged this way; what to actually do about a flagged pixel is
// a separate decision this function has no opinion on - ShadeViewport.
// pde and SolarImpacts.pde each re-cast that one pixel's own ray and
// redo their own per-pixel computation for it, right where they call
// this (see either one's own comment at that call site).
IntList listSuspectPixels (int[] pixels, int RES1, int RES2) {
  IntList list = new IntList();

  for (int np = 0; np < pixels.length; np++) {
    int centerAlpha = (pixels[np] >> 24) & 0xFF;
    if (centerAlpha != 0 && centerAlpha != 255) continue;
    boolean centerOpaque = (centerAlpha == 255);

    int x = np % RES1;
    int y = np / RES1;

    int opaqueCount = 0;
    int transparentCount = 0;

    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;
        int nx = x + dx;
        int ny = y + dy;
        if (nx < 0 || nx >= RES1 || ny < 0 || ny >= RES2) continue;

        int neighborAlpha = (pixels[ny * RES1 + nx] >> 24) & 0xFF;
        if (neighborAlpha == 255) opaqueCount++;
        else if (neighborAlpha == 0) transparentCount++;
        // alpha outside {0, 255} - near a genuine antialiased edge -
        // simply isn't counted toward either side.
      }
    }

    boolean suspect = centerOpaque ? (transparentCount > opaqueCount) : (opaqueCount > transparentCount);
    if (suspect) list.append(np);
  }

  return list;
}
