// --- Skin Potential hover tooltip (STUDY) -----------------------------------
// Shows the same per-pixel findings WIN3D's own solar-impact-overlay hover
// does (solarImpactOverlayHover.pde - reused directly here, not
// reimplemented), but over STUDY's Skin Potential thumbnails instead of
// the live 3D viewport's overlay.
//
// Unlike WIN3D's own overlay, which draw_WIN3D_layers.pde repaints fresh
// every single frame (so a hover box drawn on top of it is naturally
// gone the moment the next frame's overlay is painted over it), STUDY's
// own graph only redraws when STUDY.update is true - solarchvision_bim.
// pde's main loop skips STUDY.draw() entirely otherwise, leaving
// whatever was already on screen untouched. So a hover box drawn here
// would otherwise stick around on every later frame until something else
// happens to paint over that same screen region. The pre_screen
// capture/restore technique (precedented in UI_menuBar.pde's own dropdown
// menus) handles exactly this: capture a clean, hover-free snapshot right
// after STUDY genuinely redraws, then each frame restore that snapshot
// first (erasing whatever hover box was drawn last frame, if any) before
// drawing a new one at the current mouse position. No need to restore
// anything the moment STUDY itself redraws - that redraw already
// overwrites any stale hover box on its own, so the next capture below
// just grabs a fresh, already-clean snapshot.
PImage studyHover_pre_screen;
int studyHover_capturedGeneration = -1;
boolean studyHover_wasShownLastFrame = false;

// Called every frame, unconditionally - same shape as draw_WIN3D_layers()
// relative to WIN3D.draw(), for the same reason: this has to run whether
// or not STUDY itself redrew this particular frame.
void draw_STUDY_hover () {
  if (!STUDY.include) return;

  if (STUDY.renderGeneration != studyHover_capturedGeneration) {
    studyHover_pre_screen = get(STUDY.cX, STUDY.cY, int(STUDY.dX / STUDY.ImageScale), int(STUDY.dY / STUDY.ImageScale));
    studyHover_capturedGeneration = STUDY.renderGeneration;
    studyHover_wasShownLastFrame = false; // the fresh redraw already has no hover box on it - nothing to erase yet
  }

  if (studyHover_pre_screen == null) return; // nothing captured yet (STUDY hasn't drawn a single frame)

  boolean showingSkinPotential = (STUDY.impactGraphIndex == impactGraphIndex_URBAN_ACTIVE) || (STUDY.impactGraphIndex == impactGraphIndex_URBAN_PASSIVE);

  int[] hit = null;
  if (showingSkinPotential && UI_menuBar.selected_parent == -1 &&
      isInside(mouseX, mouseY, STUDY.cX, STUDY.cY, STUDY.cX + STUDY.dX / STUDY.ImageScale, STUDY.cY + STUDY.dY / STUDY.ImageScale)) {
    hit = studyUrbanHover_hitTest(mouseX, mouseY);
  }

  if (studyHover_wasShownLastFrame) {
    image(studyHover_pre_screen, STUDY.cX, STUDY.cY);
    studyHover_wasShownLastFrame = false;
  }

  if (hit != null) {
    drawStudyUrbanHoverBox(hit[0], hit[1], hit[2]);
    studyHover_wasShownLastFrame = true;
  }
}

// Returns {dayIndex, ix, iy} for the allSolarImpacts data point under the
// mouse, or null if the mouse isn't over any of this pass's thumbnails.
// dayIndex already matches win3DOverlay_rawValuesAt()'s own convention (0
// is the summary, dayIndex is day dayIndex-1), since that's exactly how
// plotImpact_urban() itself indexes STUDY.urbanThumbnail_centerX/Y.
int[] studyUrbanHover_hitTest (float mouseXPos, float mouseYPos) {
  if (STUDY.urbanThumbnail_centerX == null) return null;

  // Inverse of endFrame()'s own cX/cY/ImageScale compositing transform
  // (image(this.graphics, cX, cY, dX/ImageScale, dY/ImageScale)) - maps
  // actual screen coordinates back into this.graphics' own device-pixel
  // space, the same space urbanThumbnail_centerX/Y were recorded in.
  float graphicsX = (mouseXPos - STUDY.cX) * STUDY.ImageScale;
  float graphicsY = (mouseYPos - STUDY.cY) * STUDY.ImageScale;

  float halfW = STUDY.urbanThumbnail_sizeX / 2;
  float halfH = STUDY.urbanThumbnail_sizeY / 2;

  for (int dayIndex = 0; dayIndex < STUDY.urbanThumbnail_centerX.length; dayIndex++) {
    float cx = STUDY.urbanThumbnail_centerX[dayIndex];
    float cy = STUDY.urbanThumbnail_centerY[dayIndex];
    if (is_undefined(cx) || is_undefined(cy)) continue; // this slot wasn't drawn this pass (e.g. showImpactSummary off)

    if (graphicsX < cx - halfW || graphicsX > cx + halfW || graphicsY < cy - halfH || graphicsY > cy + halfH) continue;

    if (dayIndex >= allSolarImpacts.Image[STUDY.impactTypeIndex].length) continue;
    PImage img = allSolarImpacts.Image[STUDY.impactTypeIndex][dayIndex];
    if (img == null) continue;

    // plotImpact_urban() sizes sizeX/sizeY to already match the image's
    // own aspect ratio (RES1/RES2), so unlike WIN3D's overlay fit rect,
    // there's no letterboxing/cropping to account for here - a plain
    // linear fraction of the thumbnail maps straight onto the image.
    float fx = (graphicsX - (cx - halfW)) / STUDY.urbanThumbnail_sizeX;
    float fy = (graphicsY - (cy - halfH)) / STUDY.urbanThumbnail_sizeY;

    int ix = (int) constrain(fx * img.width, 0, img.width - 1);
    int iy = (int) constrain(fy * img.height, 0, img.height - 1);

    return new int[] { dayIndex, ix, iy };
  }

  return null;
}

// Draws the hover box, reusing solarImpactOverlayHover.pde's own text
// formatting (solarImpactHover_lines()) and box sizing/positioning/edge-
// drawing logic (solarImpactHover_boxPosition(), the stroke-inset
// constants) exactly as WIN3D's own hover uses them - same look, same
// behavior, just clamped to STUDY's own dest rect instead of the
// overlay's.
void drawStudyUrbanHoverBox (int dayIndex, int ix, int iy) {
  String[] lines = solarImpactHover_lines(STUDY.impactTypeIndex, dayIndex, ix, iy);
  if (lines == null) return;

  textSize(MessageSize);
  float lineHeight = textAscent() + textDescent();
  float boxH = solarImpactHover_topPad + lines.length * lineHeight + solarImpactHover_bottomPad;

  float maxTextWidth = 0;
  for (int i = 0; i < lines.length; i++) {
    maxTextWidth = max(maxTextWidth, textWidth(lines[i]));
  }
  float boxW = 2 * solarImpactHover_sidePad + maxTextWidth;

  float destX = STUDY.cX, destY = STUDY.cY;
  float destW = STUDY.dX / STUDY.ImageScale, destH = STUDY.dY / STUDY.ImageScale;

  float[] boxPos = solarImpactHover_boxPosition(mouseX, mouseY, destX, destY, destW, destH, boxW, boxH);
  float boxX = boxPos[0];
  float boxY = boxPos[1];

  noStroke();
  fill(255, 230);
  rect(boxX, boxY, boxW, boxH);

  stroke(0);
  strokeWeight(solarImpactHover_strokeWeight);
  float nearX = (boxX > mouseX) ? boxX : (boxX + boxW);
  float nearY = (boxY > mouseY) ? boxY : (boxY + boxH);
  line(nearX, boxY, nearX, boxY + boxH);
  line(boxX, nearY, boxX + boxW, nearY);

  noStroke();
  fill(0);
  textAlign(LEFT, TOP);
  for (int i = 0; i < lines.length; i++) {
    text(lines[i], boxX + solarImpactHover_sidePad, boxY + solarImpactHover_topPad + i * lineHeight);
  }
}
