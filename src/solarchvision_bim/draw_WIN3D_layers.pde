void draw_WIN3D_layers () {
  if (!WIN3D.include) return;

  if (WIN3D.update) {

    regenerate_desired_bakings();

    WIN3D.draw();
  }

  if (WIN3D.showShading) {
    WIN3D.showShading = false;
    image(Shade_RGBA, WIN3D.cX, WIN3D.cY, WIN3D.dX, WIN3D.dY);
  }

  // One-shot: consumed here regardless of outcome, same as showShading
  // above - see WIN3D.showSolarImpactOverride's own comment.
  boolean solarImpactOverrideRequested = WIN3D.showSolarImpactOverride;
  WIN3D.showSolarImpactOverride = false;

  boolean solarImpactCameraMatches = allSolarImpacts.win3DOverlay_cameraMatches();

  // Shown whenever this.Image[][] is still (or again) valid for the
  // current model/analysis-time state (win3DOverlay_dataFresh(), re-
  // evaluated fresh every frame, not latched) and either the camera
  // matches the one it was baked from, or the person just explicitly
  // asked to see it anyway (D/d/Shift+Tab, even with the camera
  // somewhere else). Checking the camera separately from the rest of
  // freshness, rather than relying on the combined win3DOverlay_isFresh(),
  // is what lets that explicit request bypass just the camera
  // requirement - a stale model or analysis-time setting still hides it
  // no matter how it was requested. impactDisplayDay/WIN3D.impactTypeIndex
  // pick which already-computed slice to show and are read live here too,
  // so the day-navigation/impact-type-toggle actions need only change
  // those (and request the override) - nothing else to re-arm.
  if (allSolarImpacts.win3DOverlay_dataFresh() && (solarImpactCameraMatches || solarImpactOverrideRequested)
      && impactDisplayDay < allSolarImpacts.Image[WIN3D.impactTypeIndex].length) {

    // Only needed when the camera doesn't match: the overlay's own baked
    // aspect ratio (RES1 x RES2) rarely matches the live viewport's
    // (WIN3D.dX x WIN3D.dY), so the r > 1 branch below draws it narrower
    // than WIN3D.dX, centered, leaving uncovered strips on either side.
    // With a matching camera, those strips just show more of that same,
    // correct 3D view, which is fine left alone. With a mismatched camera
    // (only reachable here via the explicit override above), what's
    // behind the gap is a different perspective than the overlay itself -
    // the "two unrelated perspectives on top of one another" this backdrop
    // is here to avoid. Drawn unconditionally on r rather than only for
    // r > 1: harmless where the image call below fully covers it again
    // right after (r == 1, or r < 1's cropped-and-stretched fill).
    if (!solarImpactCameraMatches) {
      noStroke();
      fill(255);
      rect(WIN3D.cX, WIN3D.cY, WIN3D.dX, WIN3D.dY);
    }

    PImage img = allSolarImpacts.Image[WIN3D.impactTypeIndex][impactDisplayDay];
    float w = img.width;
    float h = img.height;
    float aspect1 = 1.0f * w / h;
    float aspect2 = 1.0f * WIN3D.dX / WIN3D.dY;
    float r = aspect2 / aspect1;

    if(r == 1) {
      image(img, WIN3D.cX, WIN3D.cY, WIN3D.dX, WIN3D.dY);
    }
    else if(r > 1) {
      float newWidth = aspect1 * WIN3D.dY;
      image(img,
        WIN3D.cX + (WIN3D.dX - newWidth) / 2,
        WIN3D.cY,
        newWidth,
        WIN3D.dY
      );
    } else { // case of r < 1
      float extraWidth = aspect1 * WIN3D.dY;
      float deltaRatio = (extraWidth - WIN3D.dX) / WIN3D.dX;
      image(img.get(
          (int) (w * deltaRatio / 2),
          (int) 0,
          (int) (w - w * deltaRatio),
          (int) h
        ),
        WIN3D.cX,
        WIN3D.cY,
        WIN3D.dX,
        WIN3D.dY
      );
    }
  }
}