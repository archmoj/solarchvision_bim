import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// placeHoversAt() (hover.pde) just forwards to place_WIN3D_hover()/
// place_STUDY_hover()/place_WORLD_hover() - all 4 functions were at 0%
// coverage. Each of the three sub-dispatchers leads with its own chain
// of pure early-return guards (isInProgress(), the owning viewport's
// .include flag, and - the one every one of them shares - "has this
// viewport captured a single frame yet", via its own *_pre_screen field,
// null by bare-construction default) before any real hit-testing: the
// same clearStudyHover()/clearWorldHover() shape ClearHoverTest.java
// already established as safe. What's past those guards - especially
// place_STUDY_hover()'s own 309 missed instructions, 86 branches - needs
// a real captured frame and scene data to exercise meaningfully, so it's
// deliberately left untested here; these tests cover only the guards.
class PlaceHoversAtTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void placeHoversAt_onABareApp_doesNotThrow () {
    // Every one of the three sub-dispatchers' own guards fires by
    // default (showSolarImpactOverlay false; studyHover_pre_screen/
    // worldHover_pre_screen both null) - a full, safe no-op.
    assertDoesNotThrow(() -> app.placeHoversAt(10, 10));
  }

  // ================= place_WIN3D_hover / drawSolarImpactHover ================

  @Test
  void placeWIN3DHover_whenTheSolarImpactOverlayIsOff_doesNotThrow () {
    assertFalse(app.showSolarImpactOverlay, "test precondition: the bare default");

    assertDoesNotThrow(() -> app.place_WIN3D_hover(10, 10));
  }

  // ================= place_STUDY_hover ========================================

  @Test
  void placeSTUDYHover_whenAnythingIsInProgress_returnsImmediately () {
    app.isShadingViewport = true; // any one of isInProgress()'s own flags would do

    assertDoesNotThrow(() -> app.place_STUDY_hover(10, 10));
  }

  @Test
  void placeSTUDYHover_whenStudyIsNotIncluded_returnsImmediately () {
    app.STUDY.include = false;

    assertDoesNotThrow(() -> app.place_STUDY_hover(10, 10));
  }

  @Test
  void placeSTUDYHover_whenNoFrameHasEverBeenCaptured_returnsImmediately () {
    app.STUDY.include = true;
    assertNull(app.studyHover_pre_screen, "test precondition: no frame captured yet");

    assertDoesNotThrow(() -> app.place_STUDY_hover(10, 10));
  }

  // ================= place_WORLD_hover =========================================

  @Test
  void placeWORLDHover_whenAnythingIsInProgress_returnsImmediately () {
    app.isShadingViewport = true;

    assertDoesNotThrow(() -> app.place_WORLD_hover(10, 10));
  }

  @Test
  void placeWORLDHover_whenWorldIsNotIncluded_returnsImmediately () {
    app.WORLD.include = false;

    assertDoesNotThrow(() -> app.place_WORLD_hover(10, 10));
  }

  @Test
  void placeWORLDHover_whenNoFrameHasEverBeenCaptured_returnsImmediately () {
    app.WORLD.include = true;
    assertNull(app.worldHover_pre_screen, "test precondition: no frame captured yet");

    assertDoesNotThrow(() -> app.place_WORLD_hover(10, 10));
  }
}
