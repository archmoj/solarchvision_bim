void draw_WIN3D_layers () {
  if (!WIN3D.include) return;

  // Nothing pending, nothing currently shown, nothing just recomputed -
  // skip the rest of this function entirely rather than re-deriving the
  // same "nothing to do" conclusion every frame. The overlay still gets
  // re-checked every frame while it's actually on screen
  // (WIN3D.solarImpactOverlayShown): a few of win3DOverlay_dataFresh()'s
  // inputs (STUDY/TIME/STATION fields, changed directly rather than
  // through an action that revises WIN3D) can make it go stale without
  // ever setting WIN3D.update, and that needs to be caught promptly
  // rather than leaving a now-wrong overlay stuck on screen.
  // allSolarImpacts.win3DOverlay_recomputed covers the symmetric case: a
  // fresh computation that might newly make the overlay valid to show,
  // triggered from somewhere (a Skin Potential graph page, say) that also
  // doesn't set WIN3D.update.
  if (!WIN3D.update && !WIN3D.showShading && !WIN3D.showSolarImpactOverride
      && !WIN3D.solarImpactOverlayShown && !allSolarImpacts.win3DOverlay_recomputed) {
    return;
  }

  // One-shot: consumed here regardless of outcome, same reasoning as
  // WIN3D.showSolarImpactOverride below - a frame that reaches past the
  // early return above because this was the reason has to clear it, or
  // every later frame would too.
  allSolarImpacts.win3DOverlay_recomputed = false;

  // Captured once, up front - before WIN3D.draw() (which checks this same
  // thing itself, at its own top, to skip rendering what would just be
  // covered by it anyway) and before the one-shot
  // WIN3D.showSolarImpactOverride flag gets consumed below. Reused as-is
  // for the actual rect-drawing decision further down, rather than
  // re-deriving it from scratch after that flag has already been reset.
  boolean needsSolarImpactClearRect = allSolarImpacts.win3DOverlay_needsClearRect();

  boolean mayDrawPalette = false;

  if (WIN3D.update) {
    mayDrawPalette = true;

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
  boolean showSolarImpactOverlay = allSolarImpacts.win3DOverlay_dataFresh() && (solarImpactCameraMatches || solarImpactOverrideRequested)
      && impactDisplayDay < allSolarImpacts.Image[WIN3D.impactTypeIndex].length;

  // Recorded for WIN3D.isSolarPaletteMode() to read - see that method's
  // own comment.
  WIN3D.solarImpactOverlayShown = showSolarImpactOverlay;

  if (showSolarImpactOverlay) {
    mayDrawPalette = true;

    // Only needed when the camera doesn't match (needsSolarImpactClearRect,
    // captured above): the overlay's own baked aspect ratio (RES1 x RES2)
    // rarely matches the live viewport's (WIN3D.dX x WIN3D.dY), so the
    // r > 1 branch below draws it narrower than WIN3D.dX, centered,
    // leaving uncovered strips on either side. With a matching camera,
    // those strips just show more of that same, correct 3D view, which is
    // fine left alone. With a mismatched camera, what's behind the gap is
    // a different perspective than the overlay itself - the "two
    // unrelated perspectives on top of one another" this backdrop is here
    // to avoid. Drawn unconditionally on r rather than only for r > 1:
    // harmless where the image call below fully covers it again right
    // after (r == 1, or r < 1's cropped-and-stretched fill).
    if (needsSolarImpactClearRect) {
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

  if(mayDrawPalette == true) {
    // Drawn last, straight onto the main canvas, so it sits on top of both
    // WIN3D's own render and the solar-impact overlay above - and called
    // unconditionally, so it still shows up (over the overlay) on frames
    // where WIN3D.draw() itself was skipped entirely. See drawPalette()'s
    // own comment.
    WIN3D.drawPalette();
  }
}