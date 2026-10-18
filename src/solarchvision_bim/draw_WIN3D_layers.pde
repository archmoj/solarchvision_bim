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

  // Shown whenever this.Image[][] is still (or again) valid for the
  // current model/camera/analysis-time state, re-evaluated fresh every
  // frame rather than latched by a one-shot flag something else has to
  // remember to re-arm - see win3DOverlay_isFresh()'s own comment. That
  // makes this self-healing: rotate away and the overlay drops out as
  // soon as it stops matching, rotate back to exactly where it was
  // computed from and it reappears on its own, no action needed either
  // way. impactDisplayDay/WIN3D.impactTypeIndex pick which already-
  // computed slice to show and are read live here too, so the day-
  // navigation and impact-type-toggle actions need only change those -
  // nothing left to re-arm.
  if (allSolarImpacts.win3DOverlay_isFresh() && impactDisplayDay < allSolarImpacts.Image[WIN3D.impactTypeIndex].length) {
    // The overlay's own baked aspect ratio (RES1 x RES2) rarely matches
    // the live viewport's (WIN3D.dX x WIN3D.dY) - the r > 1 branch below
    // then draws it narrower than WIN3D.dX, centered, leaving uncovered
    // strips on either side. Without this, those strips show whatever the
    // live 3D view painted underneath - a different camera/projection
    // than the overlay itself - which is the "two unrelated perspectives
    // on top of one another" this is here to avoid. Drawn unconditionally
    // rather than only for r > 1: harmless where the image call below
    // fully covers it again right after (r == 1, or r < 1's cropped-and-
    // stretched fill), and keeps this one step simpler than branching on r
    // a second time.
    noStroke();
    fill(255);
    rect(WIN3D.cX, WIN3D.cY, WIN3D.dX, WIN3D.dY);

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