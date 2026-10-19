// Returns {destX, destY, destW, destH, srcX, srcY, srcW, srcH}: where img
// actually lands on screen, and which part of it, under the same
// aspect-fit rules draw_WIN3D_layers.pde's own drawing code always has
// (centered pillarbox for a wider image, center-cropped-and-stretched for
// a taller one). Shared between that drawing code and
// drawSolarImpactHover() below, rather than each recomputing this
// independently, so the hover tooltip can never end up sampling a
// slightly different pixel than the one actually on screen under the
// mouse.
float[] solarImpactOverlay_fitRect (PImage img) {
  float w = img.width;
  float h = img.height;
  float aspect1 = 1.0f * w / h;
  float aspect2 = 1.0f * WIN3D.dX / WIN3D.dY;
  float r = aspect2 / aspect1;

  if (r == 1) {
    return new float[] { WIN3D.cX, WIN3D.cY, WIN3D.dX, WIN3D.dY, 0, 0, w, h };
  } else if (r > 1) {
    float newWidth = aspect1 * WIN3D.dY;
    return new float[] { WIN3D.cX + (WIN3D.dX - newWidth) / 2, WIN3D.cY, newWidth, WIN3D.dY, 0, 0, w, h };
  } else { // r < 1
    float croppedWidth = h * aspect2; // full height, at the viewport's own aspect ratio
    return new float[] { WIN3D.cX, WIN3D.cY, WIN3D.dX, WIN3D.dY, (w - croppedWidth) / 2, 0, croppedWidth, h };
  }
}

// --- solar-impact overlay hover tooltip -----------------------------------
// Shows the raw A/R/G/B data under the mouse (see win3DOverlay_
// rawValuesAt()'s own comment, SolarImpacts.pde, for what these actually
// are - not the rendered overlay PImage's own RGBA, which has already
// been through a color palette and isn't the real data), four lines in a
// small floating box near the cursor, whenever there's real data there.
//
// No snapshot/restore trick here (tried twice now - see git history on
// this file for both attempts). UI_menuBar.pde's dropdown can use one
// (its own pre_screen field) because nothing else repaints that region on
// its own; this area doesn't have that guarantee in either direction - the
// overlay's own per-frame redraw fights a restore when the mouse holds
// still, and WIN3D's own 3D render fights it the other way whenever the
// viewport itself updates in between a save and its restore, painting
// back outdated pixels. So instead, the box is kept entirely inside the
// overlay's own dest rect (fit[0..3]), which that redraw already repaints
// fresh every single frame regardless of what this draws on top of it -
// there's nothing to restore because there's nothing left outside this
// function's own control. It's offset to whichever side of the mouse
// keeps it inside that rect - left when the mouse is in the right half,
// right when it's in the left half, and the same above/below for the
// vertical half - rather than a fixed corner that could run past an edge.
final int solarImpactHover_boxW = 100;
final int solarImpactHover_boxH = 78;
final int solarImpactHover_margin = 14; // gap between the cursor and the box

// Returns {boxX, boxY}: where the hover box should be drawn so it stays
// entirely inside destX..destX+destW / destY..destY+destH (the overlay's
// own dest rect, from solarImpactOverlay_fitRect() above) - on whichever
// side of (mouseX, mouseY) that rect has more room: left of the cursor
// when it's in the right half, right when it's in the left half, and the
// same above/below for the vertical half, rather than a fixed corner that
// could run past an edge. The final constrain() is a safety net for a box
// wider/taller than half the rect. Pure/no drawing, so it's independently
// checkable without a live PGraphics context - see
// drawSolarImpactHover()'s own comment for why nothing else here is.
float[] solarImpactHover_boxPosition (float mouseX, float mouseY, float destX, float destY, float destW, float destH) {
  boolean rightHalf = (mouseX - destX) > (destW / 2);
  boolean bottomHalf = (mouseY - destY) > (destH / 2);

  float boxX = rightHalf ? (mouseX - solarImpactHover_margin - solarImpactHover_boxW) : (mouseX + solarImpactHover_margin);
  float boxY = bottomHalf ? (mouseY - solarImpactHover_margin - solarImpactHover_boxH) : (mouseY + solarImpactHover_margin);

  boxX = constrain(boxX, destX, destX + destW - solarImpactHover_boxW);
  boxY = constrain(boxY, destY, destY + destH - solarImpactHover_boxH);

  return new float[] { boxX, boxY };
}

// Called every frame the solar-impact overlay is shown, right after
// draw_WIN3D_layers.pde draws it - img/fit are that same image and the
// fit rect solarImpactOverlay_fitRect() above just computed for it. img
// is only needed here for its width/height - the same RES1 x RES2 grid
// allSolarImpacts.Matrix_ARGB/total_Matrix_ARGB are indexed by, so ix/iy
// below locate the exact data point under the mouse, same as it used to
// locate the exact rendered pixel - not for sampling a color from it
// anymore; see win3DOverlay_rawValuesAt()'s own comment (SolarImpacts.pde)
// for why. draw_WIN3D_layers.pde already returns before ever reaching
// this call while UI_menuBar.selected_parent != -1, so this doesn't need
// to check that itself.
void drawSolarImpactHover (PImage img, float[] fit) {
  float destX = fit[0], destY = fit[1], destW = fit[2], destH = fit[3];
  if (!isInside(mouseX, mouseY, destX, destY, destX + destW, destY + destH)) return;

  float fx = (mouseX - destX) / destW;
  float fy = (mouseY - destY) / destH;
  int ix = (int) constrain(fit[4] + fx * fit[6], 0, img.width - 1);
  int iy = (int) constrain(fit[5] + fy * fit[7], 0, img.height - 1);

  float[] values = allSolarImpacts.win3DOverlay_rawValuesAt(WIN3D.impactTypeIndex, impactDisplayDay, ix, iy);
  if (values == null) return;

  float[] boxPos = solarImpactHover_boxPosition(mouseX, mouseY, destX, destY, destW, destH);
  float boxX = boxPos[0];
  float boxY = boxPos[1];

  noStroke();
  fill(255, 230);
  rect(boxX, boxY, solarImpactHover_boxW, solarImpactHover_boxH);
  noFill();
  stroke(0);
  strokeWeight(1);
  rect(boxX, boxY, solarImpactHover_boxW, solarImpactHover_boxH);

  noStroke();
  fill(0);
  textAlign(LEFT, TOP);
  textSize(14);
  text("A: " + nf(values[0], 1, 2), boxX + 8, boxY + 6);
  text("R: " + nf(values[1], 1, 2), boxX + 8, boxY + 22);
  text("G: " + nf(values[2], 1, 2), boxX + 8, boxY + 38);
  text("B: " + nf(values[3], 1, 2), boxX + 8, boxY + 54);
}
