import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import processing.core.PImage;
import processing.core.PConstants;

// recolorCloudLayer()/recolorSatelliteVisibility() (tropo3D.pde) used to
// assume loadImage(target) always comes back TROPO_DOWNLOAD_WIDTH x
// TROPO_DOWNLOAD_HEIGHT - true whenever the download actually was a real
// WMS tile, but tryDownload()'s own saveBytes(target, loadBytes(link))
// (above, in download_images()) only means the HTTP request itself
// didn't throw, not that the bytes it got back decode into an image of
// that size. A server error page (or any other malformed response)
// saved under a ".png" name decodes into a much smaller placeholder
// image instead, and looping np up to the full WIDTH*HEIGHT against that
// placeholder's own tiny pixels[] is exactly what threw
// ArrayIndexOutOfBoundsException in a real run:
//   tropo3D.pde:374:0:374:0: ArrayIndexOutOfBoundsException: Index 1 out
//   of bounds for length 1
// (a 1x1 decoded "failure" image, pixels.length == 1, np reaching 1 on
// the loop's second iteration). The fix added a size check right after
// loadImage() that discards the corrupt file and returns instead of
// looping - these tests cover that regression, plus confirm a
// correctly-sized image still gets recolored exactly as before.
class RecolorCloudLayerTest {

  private solarchvision_bim app;
  private Path tempDir;

  @BeforeEach
  void setUp () throws Exception {
    app = new solarchvision_bim();
    app.sketchPath(); // loadImage()/save() both go through Processing's own file-loading guard - see SaveProjectTest.java's own comment on why this is needed
    tempDir = Files.createTempDirectory("solarchvision-bim-test");
  }

  // --- the actual regression: a corrupt/undersized download must not throw, and must be discarded ---

  @Test
  void recolorCloudLayerDiscardsAnUndersizedImageInsteadOfThrowing () throws Exception {
    File badFile = writeDummyPng(1, 1);

    assertDoesNotThrow(() -> app.Tropo3D.recolorCloudLayer(badFile.getAbsolutePath()));

    assertFalse(badFile.exists(), "a corrupt/undersized download should be deleted, not left behind as a false 'already downloaded' marker");
  }

  @Test
  void recolorSatelliteVisibilityDiscardsAnUndersizedImageInsteadOfThrowing () throws Exception {
    File badFile = writeDummyPng(1, 1);

    assertDoesNotThrow(() -> app.Tropo3D.recolorSatelliteVisibility(badFile.getAbsolutePath()));

    assertFalse(badFile.exists(), "a corrupt/undersized download should be deleted, not left behind as a false 'already downloaded' marker");
  }

  @Test
  void recolorCloudLayerDiscardsAWrongAspectRatioImageToo () throws Exception {
    // Same bug, different shape: an image that happens to have the right
    // pixel COUNT but the wrong width/height (so np % width / np / width
    // would silently read the wrong pixel, not throw) is still not the
    // real WMS tile this function expects - width/height are checked
    // explicitly (not just pixels.length) specifically to catch this
    // case too.
    File wrongShapeFile = writeDummyPng(900, 1800); // swapped width/height vs. TROPO_DOWNLOAD_WIDTH x TROPO_DOWNLOAD_HEIGHT

    assertDoesNotThrow(() -> app.Tropo3D.recolorCloudLayer(wrongShapeFile.getAbsolutePath()));

    assertFalse(wrongShapeFile.exists());
  }

  // --- confirm the normal path still works: a correctly-sized image gets recolored, not discarded ---

  @Test
  void recolorCloudLayerStillRecolorsACorrectlySizedImage () throws Exception {
    int w = app.Tropo3D.TROPO_DOWNLOAD_WIDTH;
    int h = app.Tropo3D.TROPO_DOWNLOAD_HEIGHT;
    File goodFile = writeDummyPng(w, h);

    app.Tropo3D.recolorCloudLayer(goodFile.getAbsolutePath());

    assertTrue(goodFile.exists(), "a correctly-sized image should be recolored in place, not discarded");

    PImageDimensions dims = readPngDimensions(goodFile);
    assertEquals(w, dims.width);
    assertEquals(h, dims.height);
  }

  // --- helpers -----------------------------------------------------------

  private File writeDummyPng (int w, int h) {
    PImage img = app.createImage(w, h, PConstants.RGB);
    img.loadPixels();
    for (int i = 0; i < img.pixels.length; i++) img.pixels[i] = 0xFF808080; // opaque mid-gray - colAlpha != 0, exercises the "else" recolor branch too
    img.updatePixels();
    File f = new File(tempDir.toFile(), "dummy_" + w + "x" + h + ".png");
    img.save(f.getAbsolutePath());
    return f;
  }

  private static class PImageDimensions {
    int width;
    int height;
  }

  private PImageDimensions readPngDimensions (File f) {
    PImage img = app.loadImage(f.getAbsolutePath());
    PImageDimensions d = new PImageDimensions();
    d.width = img.width;
    d.height = img.height;
    return d;
  }
}
