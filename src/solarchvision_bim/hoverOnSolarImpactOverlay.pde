void draw_WIN3D_hover (int xMouse, int yMouse) {
  drawSolarImpactHover(xMouse, yMouse);
}

// Called every frame the solar-impact overlay is shown, right after
// draw_WIN3D_layers.pde draws it - img/fit are that same image and the
// fit rect hoverFitRect() above just computed for it. img
// is only needed here for its width/height - the same RES1 x RES2 grid
// allSolarImpacts.Matrix_ARGB/total_Matrix_ARGB are indexed by, so ix/iy
// below locate the exact data point under the mouse, same as it used to
// locate the exact rendered pixel - not for sampling a color from it
// anymore. draw_WIN3D_layers.pde already returns before ever reaching
// this call while UI_menuBar.selected_parent != -1, so this doesn't need
// to check that itself.
void drawSolarImpactHover (int xMouse, int yMouse) {
  if (!showSolarImpactOverlay) return;
  if (WIN3D_layers_img == null) return;
  if (WIN3D_layers_fit == null) return;

  PImage img = WIN3D_layers_img;
  float[] fit = WIN3D_layers_fit;

  float destX = fit[0], destY = fit[1], destW = fit[2], destH = fit[3];
  if (!isInside(xMouse, yMouse, destX, destY, destX + destW, destY + destH)) return;

  float fx = (xMouse - destX) / destW;
  float fy = (yMouse - destY) / destH;
  int ix = (int) constrain(fit[4] + fx * fit[6], 0, img.width - 1);
  int iy = (int) constrain(fit[5] + fy * fit[7], 0, img.height - 1);

  String[] lines = hoverLines(xMouse, yMouse, WIN3D.impactTypeIndex, impactDisplayDay, ix, iy);
  if (lines == null) return;

  drawHover(xMouse, yMouse, lines, destX, destY, destW, destH);
}
