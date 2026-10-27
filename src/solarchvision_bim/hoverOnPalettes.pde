// Hover for STUDY's own palette legends - the 11-swatch color bars drawn
// by Skin Potential (plotImpact_urban), Pose Potential (plotImpact_
// global), Hourly Sun (plotImpact_sunpath), and Sun Path (plotImpact_
// cycles), all four of which share the exact same rectangular swatch
// layout (pal_ox/pal_oy/pal_length, 11 equal-width rects). The legend
// itself already prints a small number on each swatch, but at
// this.view_S-scaled 15px text it can be hard to read - hovering shows
// the same value in a larger, legible size, and in the swatch's own
// color so it's unambiguous which section is being described.
//
// Not yet wired up for drawProbs()'s or plotImpact_wind()'s own 11-swatch
// legends - both use the same rect layout and could be added the same
// way, but weren't part of what was asked for here.
//
// Unlike the other three STUDY hover features, there's no per-call data
// snapshot to worry about - each swatch's value is a direct function of
// its own index and PAL_multiplier, recomputed fresh (and identically)
// every time that legend redraws, not read back from any data that a
// later call could overwrite.
class PaletteSwatchHoverInfo {
  float screenX1, screenY1, screenX2, screenY2; // this swatch's own rect, opposite corners, in screen space - order not assumed, min()/max() applied at hit-test time
  String label; // the value, already formatted with its own unit
  float[] col; // this swatch's own RGBA (PAINT.getColorStyle()'s own return shape: {alpha, r, g, b}), reused for the hover box's own background
}

// Returns the swatch under the mouse, or null if none - a plain rect
// containment check, since (unlike Pose Potential's polar wedges) these
// are ordinary axis-aligned rectangles.
PaletteSwatchHoverInfo studyPaletteHover_hitTest (int xMouse, int yMouse) {
  if (STUDY.paletteSwatchHoverInfo == null) return null;

  float graphicsX = (xMouse - STUDY.cX) * STUDY.ImageScale;
  float graphicsY = (yMouse - STUDY.cY) * STUDY.ImageScale;

  for (PaletteSwatchHoverInfo info : STUDY.paletteSwatchHoverInfo) {
    float xLo = min(info.screenX1, info.screenX2);
    float xHi = max(info.screenX1, info.screenX2);
    float yLo = min(info.screenY1, info.screenY2);
    float yHi = max(info.screenY1, info.screenY2);

    if (graphicsX < xLo || graphicsX > xHi || graphicsY < yLo || graphicsY > yHi) continue;

    return info;
  }

  return null;
}

// Draws the hover box using the swatch's own color as its background,
// with a text color chosen for contrast against it (standard relative-
// luminance threshold) rather than always black - "readable text size
// and color" on a palette whose own colors range from very light to very
// dark needs the text color to adapt, not just the size.
void drawPaletteHoverBox (int xMouse, int yMouse, PaletteSwatchHoverInfo info) {
  String[] lines = { info.label };

  float destX = STUDY.cX, destY = STUDY.cY;
  float destW = STUDY.dX / STUDY.ImageScale, destH = STUDY.dY / STUDY.ImageScale;

  drawPaletteHover(xMouse, yMouse, lines, destX, destY, destW, destH, info.col, studyPlacedHoverBoxes);
}
