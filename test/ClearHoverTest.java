import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// clearStudyHover() (hoverOnStudyImpact.pde) and clearWorldHover()
// (hoverOnWorldStations.pde) share the same shape: 4 early-return guards
// in front of 2 remaining branches that read/write real screen pixels
// (get()/image(), only reachable on a live PGraphics context - not
// available headlessly here, so not exercised by this file) to restore
// whatever was on screen before a hover box was drawn. Both had 0%
// coverage; these tests exercise every one of the 4 pure guards, on a
// bare app instance, by setting only the fields each guard itself reads.
class ClearHoverTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= clearStudyHover ========================================

  @Test
  void clearStudyHover_whenAnythingIsInProgress_returnsImmediately_touchingNothing () {
    app.isShadingViewport = true; // any one of isInProgress()'s own 4 flags would do
    app.studyHover_wasShownLastFrame = true; // sentinel: must survive untouched
    app.studyHover_capturedGeneration = 999; // sentinel: distinct from STUDY.renderGeneration (0)

    assertDoesNotThrow(() -> app.clearStudyHover());

    assertTrue(app.studyHover_wasShownLastFrame);
    assertEquals(999, app.studyHover_capturedGeneration);
  }

  @Test
  void clearStudyHover_whenStudyIsNotIncluded_returnsImmediately_touchingNothing () {
    app.STUDY.include = false;
    app.studyHover_wasShownLastFrame = true;
    app.studyHover_capturedGeneration = 999;

    assertDoesNotThrow(() -> app.clearStudyHover());

    assertTrue(app.studyHover_wasShownLastFrame);
    assertEquals(999, app.studyHover_capturedGeneration);
  }

  @Test
  void clearStudyHover_whenNothingWasShownLastFrame_returnsWithoutErasing () {
    // Generation matched (so the capture branch - the one that calls
    // get() - is skipped), but nothing was drawn last pass.
    app.studyHover_capturedGeneration = app.STUDY.renderGeneration;
    app.studyHover_wasShownLastFrame = false;

    assertDoesNotThrow(() -> app.clearStudyHover());

    assertFalse(app.studyHover_wasShownLastFrame, "must stay false - nothing to erase, nothing to flip");
  }

  @Test
  void clearStudyHover_whenNoFrameWasEverCaptured_returnsWithoutErasing () {
    // Generation matched, something was supposedly shown last frame, but
    // STUDY has never actually rendered a frame to capture
    // (studyHover_pre_screen is still its bare-construction null) - must
    // bail out before ever calling image() on a null PImage.
    app.studyHover_capturedGeneration = app.STUDY.renderGeneration;
    app.studyHover_wasShownLastFrame = true;
    assertNull(app.studyHover_pre_screen, "test precondition: no frame captured yet");

    assertDoesNotThrow(() -> app.clearStudyHover());

    assertTrue(app.studyHover_wasShownLastFrame, "unchanged - the function returns before ever resetting it on this path");
  }

  // ================= clearWorldHover (same shape as clearStudyHover) ========

  @Test
  void clearWorldHover_whenAnythingIsInProgress_returnsImmediately_touchingNothing () {
    app.isShadingViewport = true;
    app.worldHover_wasShownLastFrame = true;
    app.worldHover_capturedGeneration = 999;

    assertDoesNotThrow(() -> app.clearWorldHover());

    assertTrue(app.worldHover_wasShownLastFrame);
    assertEquals(999, app.worldHover_capturedGeneration);
  }

  @Test
  void clearWorldHover_whenWorldIsNotIncluded_returnsImmediately_touchingNothing () {
    app.WORLD.include = false;
    app.worldHover_wasShownLastFrame = true;
    app.worldHover_capturedGeneration = 999;

    assertDoesNotThrow(() -> app.clearWorldHover());

    assertTrue(app.worldHover_wasShownLastFrame);
    assertEquals(999, app.worldHover_capturedGeneration);
  }

  @Test
  void clearWorldHover_whenNothingWasShownLastFrame_returnsWithoutErasing () {
    app.worldHover_capturedGeneration = app.WORLD.renderGeneration;
    app.worldHover_wasShownLastFrame = false;

    assertDoesNotThrow(() -> app.clearWorldHover());

    assertFalse(app.worldHover_wasShownLastFrame);
  }

  @Test
  void clearWorldHover_whenNoFrameWasEverCaptured_returnsWithoutErasing () {
    app.worldHover_capturedGeneration = app.WORLD.renderGeneration;
    app.worldHover_wasShownLastFrame = true;
    assertNull(app.worldHover_pre_screen, "test precondition: no frame captured yet");

    assertDoesNotThrow(() -> app.clearWorldHover());

    assertTrue(app.worldHover_wasShownLastFrame);
  }
}
