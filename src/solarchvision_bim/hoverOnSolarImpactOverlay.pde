void place_WIN3D_hover (int xMouse, int yMouse) {
  drawSolarImpactHover(xMouse, yMouse);
}

// --- WIN3D pin position tracking (viewport resize/enlarge, and panel size) -
//
// Maps a WIN3D-sourced pinned point's own {x,y} row (hover.pde's own
// allHoverPoints - object identity, not value, the same keying convention
// hoverPointPreferredPosition/worldHoverPointGeo/studyHoverPointLocalFrac
// already use) to the position it was pinned at, expressed as an offset
// from WIN3D's own panel CENTER (WIN3D.cX + WIN3D.dX/2, WIN3D.cY +
// WIN3D.dY/2), itself expressed as a FRACTION of WIN3D's own panel size
// (offset / WIN3D.dX, offset / WIN3D.dY) rather than an absolute pixel
// offset. A row with no entry here is a plain screen-fixed pin, same as
// before this existed; a row WITH one is instead kept in sync with it,
// every frame, by syncWin3DHoverPointPositions() below - so a WIN3D pin
// stays centered the same way relative to the viewport when it's
// enlarged or restored (Enlarge 3D Viewport, Display All Viewports -
// update_frame_layout(), updateFrameLayout.pde), rather than drifting
// toward whichever corner happens to end up closest once the panel's own
// cX/cY/dX/dY change.
//
// Storing a FRACTION of WIN3D.dX/dY, rather than an absolute pixel
// offset, is what also makes a WIN3D pin survive a save/load onto a
// different screen size: this app launches fullScreen() by default (see
// settings(), solarchvision_bim.pde), so WIN3D's own panel pixel
// dimensions genuinely differ across devices. A perspective camera with
// the same field of view, rendered into a differently-sized pixel
// buffer, still places a given 3D feature at the SAME fraction of the
// viewport's own width/height (NDC-to-pixel mapping scales with the
// viewport's own dimensions) - so a fixed FRACTION of dX/dY tracks the
// same feature across screen sizes where a fixed absolute pixel offset
// would not.
//
// Deliberately still just a center-relative tracking, with no attempt at
// a true camera-aware reprojection of the original 3D point through the
// camera's own projection matrix (the 3D viewport has no userZoom/
// userPanX/userPanY of its own the way STUDY does, so there's no simple
// transform to invert the way studyHoverPointLocalFrac/
// syncStudyHoverPointPositions(), hoverOnStudyImpact.pde, do) - good
// enough for the common case (enlarging/restoring a preset layout, or
// reopening on another screen), not a guarantee against every possible
// camera change.
//
// Populated by mouseClicked.pde's own WIN3D left-click handling (while
// the solar-impact overlay is showing), right after the addHoverPoint()
// call that creates the row; read (and pruned, for a pin that's since
// been dropped) only here.
java.util.IdentityHashMap<int[], float[]> win3DHoverPointOffsetFrac = new java.util.IdentityHashMap<int[], float[]>();

// Converts a screen-space point (same space allHoverPoints/
// placeHoversAt() already work in) into its own offset from WIN3D's
// panel center, expressed as a FRACTION of WIN3D's CURRENT dX/dY - the
// inverse of win3DScreenXFromOffsetFrac()/win3DScreenYFromOffsetFrac()
// just below. Used once, at pin time, to capture the base position
// win3DHoverPointOffsetFrac stores for a new WIN3D pin.
float win3DOffsetFracXFromScreen (float screenX) {
  return (screenX - (WIN3D.cX + 0.5 * WIN3D.dX)) / WIN3D.dX;
}

float win3DOffsetFracYFromScreen (float screenY) {
  return (screenY - (WIN3D.cY + 0.5 * WIN3D.dY)) / WIN3D.dY;
}

// The forward direction: given an offset-from-center fraction, returns
// where that same fraction of WIN3D's CURRENT panel lands on screen
// right now - the exact inverse of win3DOffsetFracXFromScreen()/
// win3DOffsetFracYFromScreen() above. This is what lets
// syncWin3DHoverPointPositions() below recompute a WIN3D pin's own (x,y)
// fresh every frame (or after a save/load onto a different screen
// size), the same way studyScreenXFromLocalFrac()/
// studyScreenYFromLocalFrac() (hoverOnStudyImpact.pde) do for a STUDY
// pin.
float win3DScreenXFromOffsetFrac (float fracX) {
  return WIN3D.cX + 0.5 * WIN3D.dX + fracX * WIN3D.dX;
}

float win3DScreenYFromOffsetFrac (float fracY) {
  return WIN3D.cY + 0.5 * WIN3D.dY + fracY * WIN3D.dY;
}

// Keeps every WIN3D-sourced pin (win3DHoverPointOffsetFrac above)
// centered on the same spot in the viewport as its own cX/cY/dX/dY
// change - called once per pass, by drawAllHovers() (hover.pde),
// alongside syncWorldHoverPointPositions()/syncStudyHoverPointPositions(),
// before anything in that pass gets resolved, for the exact same reason
// those functions' own comments give (both this pass's own pin-position
// resolution and its collision-avoidance "peek" need to see this pass's
// already-up-to-date positions, not last frame's).
//
// For each WIN3D-tracked row: re-derives its own screen position fresh
// from win3DScreenXFromOffsetFrac()/win3DScreenYFromOffsetFrac() (which
// already reflect this frame's own cX/cY/dX/dY) - if the recomputed
// position now falls outside WIN3D's own current panel rect, the pin no
// longer points at anything actually on screen, so it's dropped
// (removeHoverPointAt(), hover.pde), the same off-view treatment
// syncWorldHoverPointPositions()/syncStudyHoverPointPositions() give
// their own pins. Otherwise, if the recomputed position has moved since
// last frame, the row's own x/y (mutated in place) is updated to the new
// position, AND, if this pin already has its own remembered box position
// (hoverPointPreferredPosition, hover.pde), that's shifted by the exact
// same delta - same reasoning as those two functions' own comments for
// why.
void syncWin3DHoverPointPositions () {
  if (allHoverPoints == null) return;
  if (win3DHoverPointOffsetFrac.isEmpty()) return;
  if (!WIN3D.include) return;

  for (int i = allHoverPoints.length - 1; i >= 0; i--) {
    int[] row = allHoverPoints[i];
    float[] offset = win3DHoverPointOffsetFrac.get(row);
    if (offset == null) continue; // not a WIN3D-tracked pin - leave it alone entirely

    float newXf = win3DScreenXFromOffsetFrac(offset[0]);
    float newYf = win3DScreenYFromOffsetFrac(offset[1]);

    if (!isInside(newXf, newYf, WIN3D.cX, WIN3D.cY, WIN3D.cX + WIN3D.dX, WIN3D.cY + WIN3D.dY)) {
      removeHoverPointAt(i);
      continue;
    }

    int newX = round(newXf);
    int newY = round(newYf);

    int dx = newX - row[0];
    int dy = newY - row[1];
    if ((dx == 0) && (dy == 0)) continue; // nothing actually moved since last frame

    float[] preferred = hoverPointPreferredPosition.get(row);
    if (preferred != null) {
      preferred[0] += dx;
      preferred[1] += dy;
    }

    row[0] = newX;
    row[1] = newY;
  }
}

// Called every frame the solar-impact overlay is shown, right after
// drawViewport3DLayers.pde draws it - img/fit are that same image and the
// fit rect hoverFitRect() above just computed for it. img
// is only needed here for its width/height - the same resX x resY grid
// allSolarImpacts.Matrix_ARGB/total_Matrix_ARGB are indexed by, so ix/iy
// below locate the exact data point under the mouse, same as it used to
// locate the exact rendered pixel - not for sampling a color from it
// anymore. drawViewport3DLayers.pde already returns before ever reaching
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

  queueHover(xMouse, yMouse, lines, destX, destY, destW, destH, win3DPlacedHoverBoxes, win3DPendingHoverBoxes);
}
