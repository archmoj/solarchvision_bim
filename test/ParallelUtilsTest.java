import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import processing.data.IntList;

// parallelUtils.pde's own functions split cleanly into two groups, both
// previously untested:
//
// - awaitAll()/awaitAllWithProgress(): plain java.util.concurrent
//   wait/propagate helpers shared by every parallel per-pixel chunk loop
//   in this codebase (preBakeViewport3D.pde's ray-casting,
//   shadeViewport3D.pde's two passes) - no Processing/WIN3D dependency
//   at all, directly callable with a real ExecutorService.
//   awaitAllWithProgress() with a null progressWindow (exactly what
//   every caller passes when showPrebakeProgress is off or the
//   environment is headless - see preBakeViewport3D.pde's own
//   canShowProgressWindow() comment) just falls back to awaitAll()
//   itself; the non-null branch needs a real java.awt.Frame-derived
//   ProgressWindow, which risks a HeadlessException in exactly the kind
//   of environment this suite runs in, so it's left uncovered here.
//
// - listSuspectPixels()/isDifferent(): pure int[]-pixel-array logic (see
//   their own file header comment for what they're for) with no
//   WIN3D/PImage involved either - built, and every expected value
//   below confirmed, by hand against the real compiled app before
//   writing this file's assertions.
class ParallelUtilsTest {

  private solarchvision_bim app;
  private int opaqueWhite;
  private int transparentBlack;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    opaqueWhite = app.color(255, 255, 255, 255);
    transparentBlack = app.color(0, 0, 0, 0);
  }

  // ================= awaitAll() ===========================================

  @Test
  void awaitAll_waitsForEveryFutureToActuallyFinish () throws Exception {
    ExecutorService pool = Executors.newFixedThreadPool(4);
    try {
      List<Future<?>> futures = new ArrayList<>();
      int[] counter = {0};
      for (int i = 0; i < 5; i++) {
        futures.add(pool.submit(() -> { synchronized (counter) { counter[0]++; } }));
      }

      app.awaitAll(futures);

      // The actual point of this test: by the time awaitAll() returns,
      // every one of the 5 submitted tasks must have already run - not
      // just been submitted.
      assertEquals(5, counter[0]);
    } finally {
      pool.shutdown();
    }
  }

  @Test
  void awaitAll_wrapsAWorkerExceptionInARuntimeException_preservingItsCause () throws Exception {
    ExecutorService pool = Executors.newFixedThreadPool(1);
    try {
      List<Future<?>> futures = new ArrayList<>();
      IllegalStateException original = new IllegalStateException("boom");
      futures.add(pool.submit(() -> { throw original; }));

      RuntimeException thrown = assertThrows(RuntimeException.class, () -> app.awaitAll(futures));

      // future.get() itself wraps a worker's own thrown exception in an
      // ExecutionException - awaitAll()'s own catch unwraps THAT back
      // down to the original cause (e.getCause()), not the
      // ExecutionException itself, before rethrowing.
      assertSame(original, thrown.getCause());
    } finally {
      pool.shutdown();
    }
  }

  @Test
  void awaitAll_withNoFutures_isANoOp () {
    assertDoesNotThrow(() -> app.awaitAll(new ArrayList<>()));
  }

  // ================= awaitAllWithProgress() (null progressWindow only) ===
  // See this file's own header comment on why only the null-progressWindow
  // branch (awaitAllWithProgress()'s own early "if (progressWindow == null)
  // { awaitAll(futures); return; }") is covered here.

  @Test
  void awaitAllWithProgress_withNullProgressWindow_fallsBackToPlainAwaitAll () throws Exception {
    ExecutorService pool = Executors.newFixedThreadPool(4);
    try {
      List<Future<?>> futures = new ArrayList<>();
      int[] counter = {0};
      for (int i = 0; i < 3; i++) {
        futures.add(pool.submit(() -> { synchronized (counter) { counter[0]++; } }));
      }

      app.awaitAllWithProgress(futures, new int[]{0}, 3, null, 0f, 1f);

      assertEquals(3, counter[0]);
    } finally {
      pool.shutdown();
    }
  }

  @Test
  void awaitAllWithProgress_withNullProgressWindow_stillPropagatesAWorkerException () throws Exception {
    ExecutorService pool = Executors.newFixedThreadPool(1);
    try {
      List<Future<?>> futures = new ArrayList<>();
      IllegalStateException original = new IllegalStateException("boom");
      futures.add(pool.submit(() -> { throw original; }));

      RuntimeException thrown = assertThrows(RuntimeException.class,
          () -> app.awaitAllWithProgress(futures, new int[]{0}, 1, null, 0f, 1f));

      assertSame(original, thrown.getCause());
    } finally {
      pool.shutdown();
    }
  }

  // ================= isDifferent() ========================================
  // Both thresholds are a strict `>`, not `>=` - confirmed directly
  // against the real compiled app: the exact boundary value itself
  // (191 for alpha, 31 for color) is NOT considered different, one past
  // it is.

  @Test
  void isDifferent_alphaThreshold_isStrictlyGreaterThan191 () {
    // nColor is 0 either way here (RGB all 0), so only the alpha term
    // can make these differ.
    int centerAlpha = 255;
    float centerColor = 0f;

    int alphaDiff191 = app.color(0, 0, 0, 255 - 191); // alpha=64
    int alphaDiff192 = app.color(0, 0, 0, 255 - 192); // alpha=63

    assertFalse(app.isDifferent(alphaDiff191, centerAlpha, centerColor), "exactly 191 should NOT count as different");
    assertTrue(app.isDifferent(alphaDiff192, centerAlpha, centerColor), "192 should count as different");
  }

  @Test
  void isDifferent_colorThreshold_isStrictlyGreaterThan31 () {
    // Alpha held equal (255) on both sides, so only the color term can
    // make these differ. nColor = nAlpha/255 * (R+G+B)/3, so with alpha
    // at its max and R==G==B, nColor reduces to that one channel's own
    // value - centered on 255 (white) here.
    int centerAlpha = 255;
    float centerColor = 255f;

    int colorDiff31 = app.color(224, 224, 224, 255);
    int colorDiff32 = app.color(223, 223, 223, 255);

    assertFalse(app.isDifferent(colorDiff31, centerAlpha, centerColor), "exactly 31 should NOT count as different");
    assertTrue(app.isDifferent(colorDiff32, centerAlpha, centerColor), "32 should count as different");
  }

  @Test
  void isDifferent_identicalPixel_isNeverDifferent () {
    int c = app.color(128, 64, 32, 200);
    // Reconstruct the same centerAlpha/centerColor listSuspectPixels()
    // itself would have computed for this exact color, rather than
    // picking arbitrary numbers - this is the "compared against itself"
    // case every non-isolated pixel in listSuspectPixels() relies on.
    int centerAlpha = 200;
    float centerColor = centerAlpha / 255.0f * (128 + 64 + 32) / 3.0f;

    assertFalse(app.isDifferent(c, centerAlpha, centerColor));
  }

  // ================= listSuspectPixels() ==================================

  private int[] uniformGrid (int w, int h, int fill) {
    int[] pixels = new int[w * h];
    java.util.Arrays.fill(pixels, fill);
    return pixels;
  }

  @Test
  void listSuspectPixels_flagsAPixelWhoseEveryValidNeighborPairFullyDisagreesWithIt () {
    // 3x3 grid, opaque white everywhere except the exact center, which
    // is transparent black - all 4 of the center's own opposite pairs
    // (N-S, W-E, NW-SE, SW-NE) are fully inside this 3x3 grid, and every
    // one of those 8 surrounding pixels differs from the center.
    int[] pixels = uniformGrid(3, 3, opaqueWhite);
    pixels[1 * 3 + 1] = transparentBlack; // center, index 4

    IntList suspects = app.listSuspectPixels(pixels, 3, 3);

    assertEquals(1, suspects.size());
    assertEquals(4, suspects.get(0));
  }

  @Test
  void listSuspectPixels_aUniformImage_hasNoSuspects () {
    int[] pixels = uniformGrid(3, 3, opaqueWhite);

    IntList suspects = app.listSuspectPixels(pixels, 3, 3);

    assertEquals(0, suspects.size());
  }

  @Test
  void listSuspectPixels_aPixelThatAgreesWithOnlyOneOppositePair_isNotFlagged () {
    // Same 3x3 grid as the fully-isolated test above, but the center
    // keeps matching its W/E neighbors - leaving 2 of its 4 valid pairs
    // (W-E, and both diagonals, which still match too) NOT fully
    // disagreeing, so validPairs (4) != bothDifferentPairs (only the
    // N-S pair, 1) and the center itself is never flagged. The two
    // pixels that DO get flagged here (N and S themselves) are a
    // separate, real finding worth pinning down explicitly - see the
    // next test.
    int[] pixels = uniformGrid(3, 3, opaqueWhite);
    pixels[0 * 3 + 1] = transparentBlack; // N, index 1
    pixels[2 * 3 + 1] = transparentBlack; // S, index 7
    // center (index 4), W (index 3) and E (index 5) all stay opaqueWhite

    IntList suspects = app.listSuspectPixels(pixels, 3, 3);

    assertFalse(suspects.hasValue(4), "the center itself disagrees with only 1 of its 4 valid pairs - not isolated");
  }

  @Test
  void listSuspectPixels_evaluatesEveryPixelAsItsOwnCenter_notJustTheMiddleOne () {
    // Same fixture as the test just above - confirms what actually DOES
    // get flagged there: N (index 1) and S (index 7) are each evaluated
    // as their OWN center too, not merely as neighbors of index 4. N's
    // (1,0) own N-S pair is out of bounds (skipped), its NW/SE and
    // SW/NE diagonal pairs each have one out-of-bounds member (skipped
    // too, since a pair only counts "fully inside" - see this class's
    // own header comment), leaving only its W-E pair valid - W=(0,0)
    // and E=(2,0) are both still opaqueWhite, disagreeing with N's own
    // transparentBlack on both sides at once, so N is isolated by its
    // own single valid pair. S is the mirror image of this on the
    // bottom row.
    int[] pixels = uniformGrid(3, 3, opaqueWhite);
    pixels[0 * 3 + 1] = transparentBlack; // N, index 1
    pixels[2 * 3 + 1] = transparentBlack; // S, index 7

    IntList suspects = app.listSuspectPixels(pixels, 3, 3);

    assertEquals(2, suspects.size());
    assertTrue(suspects.hasValue(1));
    assertTrue(suspects.hasValue(7));
  }

  @Test
  void listSuspectPixels_aCornerPixel_isNeverFlagged_evenWhenFullyIsolated () {
    // Every one of a corner's 4 candidate pairs has at least one member
    // outside the image (e.g. top-left's own N-S pair needs (0,-1),
    // which doesn't exist) - validPairs stays 0 regardless of how
    // different the corner actually looks from its real neighbors, and
    // listSuspectPixels()'s own "if (validPairs > 0 ...)" guard means a
    // corner can never be flagged at all, no matter its content.
    int[] pixels = uniformGrid(3, 3, opaqueWhite);
    pixels[0] = transparentBlack; // top-left corner, (0,0), index 0

    IntList suspects = app.listSuspectPixels(pixels, 3, 3);

    assertFalse(suspects.hasValue(0));
  }

  @Test
  void listSuspectPixels_anEdgePixelWithExactlyOneValidPair_canStillBeFlagged () {
    // Top-middle (1,0): its N-S and both diagonal pairs each have one
    // member off the top edge (skipped, same reasoning as the corner
    // test above), leaving only its own W-E pair (both members - (0,0)
    // and (2,0) - safely on the same row) as "fully inside". That one
    // pair disagreeing on both sides is enough to flag it, despite most
    // of its candidate pairs never counting at all.
    int[] pixels = uniformGrid(3, 3, opaqueWhite);
    pixels[0 * 3 + 1] = transparentBlack; // top-middle, (1,0), index 1

    IntList suspects = app.listSuspectPixels(pixels, 3, 3);

    assertEquals(1, suspects.size());
    assertEquals(1, suspects.get(0));
  }

  @Test
  void listSuspectPixels_onAnEmptyPixelArray_returnsAnEmptyList () {
    IntList suspects = app.listSuspectPixels(new int[0], 0, 0);

    assertEquals(0, suspects.size());
  }
}
