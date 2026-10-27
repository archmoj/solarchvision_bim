// One thumbnail's worth of hover-relevant info, captured by plotImpact_
// urban() (STUDY.pde) at the moment it draws that thumbnail. daySnapshot
// is a deep clone of whichever 4D [q][component][x][y] array (Matrix_ARGB
// [dayIndex], or total_Matrix_ARGB for the summary) was live at that
// exact moment - cloned rather than referenced because viewLayout==2 can
// call plotImpact_urban() up to three times in one render pass (one row
// per 25th/50th/75th percentile), and each call's own calculate_Impact_
// CurrentPreBaked() overwrites allSolarImpacts' live Matrix_ARGB/
// total_Matrix_ARGB in place - a plain reference into those fields would,
// by the time anyone actually hovers, only ever show whichever row drew
// last.
class UrbanThumbnailHoverInfo {
  float centerX, centerY;
  int impactTypeIndex;
  float[][][][] daySnapshot;
  float mul; // dayValuesMUL[dayIndex] for a real day, or 1.0/dayCount for the summary - see win3DOverlay_rawValuesAt()'s own two cases, SolarImpacts.pde
}

// A real (not shallow) copy of a [q][component][x][y]-shaped array -
// Matrix_ARGB[dayIndex] and total_Matrix_ARGB are both this exact shape.
// Needed because Java's own Object.clone() on a multi-dimensional array
// only copies the outermost level, leaving every inner array still
// shared with (and mutable by) the original.
float[][][][] deepClone4D (float[][][][] src) {
  float[][][][] dst = new float[src.length][][][];
  for (int i = 0; i < src.length; i++) {
    dst[i] = new float[src[i].length][][];
    for (int j = 0; j < src[i].length; j++) {
      dst[i][j] = new float[src[i][j].length][];
      for (int k = 0; k < src[i][j].length; k++) {
        dst[i][j][k] = src[i][j][k].clone();
      }
    }
  }
  return dst;
}

// Same per-pixel logic as win3DOverlay_rawValuesAt() (SolarImpacts.pde),
// reading from an explicitly-passed-in snapshot/multiplier instead of
// allSolarImpacts' own live Matrix_ARGB/total_Matrix_ARGB/dayValuesMUL -
// daySnapshot already has whichever one of those applies baked in (a
// cloned Matrix_ARGB[dayIndex] with mul = dayValuesMUL[dayIndex] for a
// real day, or a cloned total_Matrix_ARGB with mul = 1/dayCount for the
// summary), so this one formula covers both cases the same way the
// original function's own two branches do.
float[] win3DOverlay_rawValuesAt_fromSnapshot (int q, float[][][][] daySnapshot, float mul, int x, int y) {
  float rawA = daySnapshot[q][0][x][y];
  if (!is_defined(rawA)) return null;

  float a = rawA * mul;
  float r = daySnapshot[q][1][x][y] * mul;
  float g = daySnapshot[q][2][x][y] * mul;
  float b = daySnapshot[q][3][x][y] * mul;

  if (a == 0) return null;

  return new float[] { a, r, g, b };
}

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

// Makes sure studyHover_pre_screen is a clean, hover-box-free snapshot of
// the STUDY panel (capturing a fresh one whenever STUDY has genuinely
// redrawn since the last capture), then - if the *previous* pass left a
// hover box drawn on top of it - restores that snapshot to erase it.
// Called exactly once per pass, by drawAllHovers() (hover.pde), before
// any of this pass's hover points are drawn.
//
// This used to be folded into draw_STUDY_hover() itself, gated behind
// "only clear when zIndex == 0" - which relied on drawAllHovers() always
// presenting its very first point at zIndex 0, happened to be true, but
// tied the STUDY panel's own clearing to an unrelated detail: how many
// other points are being hovered this pass and in what order. A point
// that lands on WIN3D rather than over STUDY has nothing to do with
// whether STUDY's own last hover box needs erasing, so a point like that
// landing first shouldn't be able to affect it either way; pulling the
// clear out into its own function, called once up front regardless of
// where any point lands, removes that coupling entirely.
void clearStudyHover () {
  if (isBakingInProgress()) return;

  if (!STUDY.include) return;

  if (STUDY.renderGeneration != studyHover_capturedGeneration) {
    studyHover_pre_screen = get(STUDY.cX, STUDY.cY, int(STUDY.dX / STUDY.ImageScale), int(STUDY.dY / STUDY.ImageScale));
    studyHover_capturedGeneration = STUDY.renderGeneration;
    studyHover_wasShownLastFrame = false; // the fresh redraw already has no hover box on it - nothing to erase
    return; // the capture above IS this pass's clean state; nothing further to restore
  }

  if (!studyHover_wasShownLastFrame) return; // nothing drawn last pass - nothing to erase
  if (studyHover_pre_screen == null) return; // nothing captured yet (STUDY hasn't drawn a single frame)

  image(studyHover_pre_screen, STUDY.cX, STUDY.cY);
  studyHover_wasShownLastFrame = false;
}

// Called once per hover point in the current pass (possibly several
// times per frame - see drawAllHovers(), hover.pde) - same shape as
// draw_WIN3D_layers() relative to WIN3D.draw(), for the same reason:
// this has to run whether or not STUDY itself redrew this particular
// frame. Clearing any box left over from the previous pass is
// clearStudyHover()'s job, not this function's - called once, up front,
// by drawAllHovers(), before the first of this pass's calls here.
void draw_STUDY_hover (int xMouse, int yMouse) {
  if (isBakingInProgress()) return;

  if (!STUDY.include) return;

  if (studyHover_pre_screen == null) return; // nothing captured yet (STUDY hasn't drawn a single frame)

  // Skin Potential and Pose Potential are gated by whether this frame's
  // own urbanThumbnailHoverInfo/globalPoseHoverInfo actually got anything
  // appended to them - not by STUDY.impactGraphIndex. That single scalar
  // field only ever holds one value at a time, but setupPlot_1() and
  // setupPlot_2() (viewLayout==2) each draw a Skin Potential thumbnail
  // AND a Pose Potential dome in the very same render pass, temporarily
  // flipping this.impactGraphIndex to URBAN_* for one plotImpact() call
  // and to GLOBAL_* for the other, then restoring it to whatever it was
  // before setupPlot_1()/setupPlot_2() ran - so by the time draw_STUDY_
  // hover() reads it here, it reflects only one of the two graphs (or
  // neither), even though both were just drawn and both have hover data
  // waiting in their own lists. Checking those lists directly keys
  // "showing" to what was actually drawn this frame, which is exactly
  // right for both the single-graph layouts (only one list ends up
  // non-empty) and setupPlot_1()/setupPlot_2() (both do).
  boolean showingSkinPotential = (STUDY.urbanThumbnailHoverInfo != null) && !STUDY.urbanThumbnailHoverInfo.isEmpty();
  boolean showingPosePotential = (STUDY.globalPoseHoverInfo != null) && !STUDY.globalPoseHoverInfo.isEmpty();
  boolean showingHourlySun = (STUDY.impactGraphIndex == impactGraphIndex_SUNPATH_ACTIVE) || (STUDY.impactGraphIndex == impactGraphIndex_SUNPATH_PASSIVE);
  boolean showingSunPath = (STUDY.impactGraphIndex == impactGraphIndex_CYCLES_ACTIVE) || (STUDY.impactGraphIndex == impactGraphIndex_CYCLES_PASSIVE);
  boolean showingWind = (STUDY.impactGraphIndex == impactGraphIndex_WIND_ACTIVE) || (STUDY.impactGraphIndex == impactGraphIndex_WIND_PASSIVE);
  boolean showingNormalLines = STUDY.showNormalLines;
  boolean showingProbabilities = STUDY.showProbabilities;
  boolean showingStatisticalRanges = STUDY.showStatisticalRanges;
  boolean showingAPalette = showingSkinPotential || showingPosePotential || showingHourlySun || showingSunPath || showingWind || showingProbabilities || showingStatisticalRanges;

  UrbanHoverHit urbanHit = null;
  GlobalPoseHoverHit poseHit = null;
  SunpathHoverPoint sunpathHit = null;
  NormalsHoverColumn normalsHit = null;
  ProbsHoverBox probsHit = null;
  PaletteSwatchHoverInfo paletteHit = null;

  if ((showingAPalette || showingNormalLines) && UI_menuBar.selected_parent == -1 &&
      isInside(xMouse, yMouse, STUDY.cX, STUDY.cY, STUDY.cX + STUDY.dX / STUDY.ImageScale, STUDY.cY + STUDY.dY / STUDY.ImageScale)) {
    if (showingSkinPotential) urbanHit = studyUrbanHover_hitTest(xMouse, yMouse);
    if (showingPosePotential) poseHit = studyGlobalPoseHover_hitTest(xMouse, yMouse);
    if (showingHourlySun) sunpathHit = studySunpathHover_hitTest(xMouse, yMouse);
    // Probabilities checked before normals: each probability box is an
    // actual filled rectangle (an unambiguous point-in-rect hit), while
    // normals is a generous-radius crosshair match over thin lines - the
    // two are rarely shown at the same screen position at once (see
    // hoverOnStudyProbs.pde's own comment), so this ordering is a
    // starting point, not a carefully resolved priority.
    if (showingProbabilities) probsHit = studyProbsHover_hitTest(xMouse, yMouse);
    if (showingNormalLines && probsHit == null) normalsHit = studyNormalsHover_hitTest(xMouse, yMouse);
    if (showingAPalette && urbanHit == null && poseHit == null && sunpathHit == null) paletteHit = studyPaletteHover_hitTest(xMouse, yMouse);
  }

  if (urbanHit != null) {
    drawStudyUrbanHoverBox(xMouse, yMouse, urbanHit);
    studyHover_wasShownLastFrame = true;
  } else if (poseHit != null) {
    drawGlobalPoseHoverBox(xMouse, yMouse, poseHit);
    studyHover_wasShownLastFrame = true;
  } else if (sunpathHit != null) {
    drawSunpathHoverBox(xMouse, yMouse, sunpathHit);
    studyHover_wasShownLastFrame = true;
  } else if (probsHit != null) {
    drawProbsHoverBox(xMouse, yMouse, probsHit);
    studyHover_wasShownLastFrame = true;
  } else if (normalsHit != null) {
    drawNormalsHoverBox(xMouse, yMouse, normalsHit);
    studyHover_wasShownLastFrame = true;
  } else if (paletteHit != null) {
    drawPaletteHoverBox(xMouse, yMouse, paletteHit);
    studyHover_wasShownLastFrame = true;
  }
}

// The thumbnail entry a hit landed on, plus which of its own pixels.
class UrbanHoverHit {
  UrbanThumbnailHoverInfo info;
  int ix, iy;
}

// Returns the hover hit under the mouse, or null if it isn't over any of
// this pass's thumbnails. Walks every entry (not just one per dayIndex) -
// with up to three rows sharing the same dayIndex (viewLayout==2's three
// percentile rows), each one needs its own chance to match, since they
// sit at different screen positions and carry different data.
UrbanHoverHit studyUrbanHover_hitTest (int xMouse, int yMouse) {
  if (STUDY.urbanThumbnailHoverInfo == null) return null;

  // Inverse of endFrame()'s own cX/cY/ImageScale compositing transform
  // (image(this.graphics, cX, cY, dX/ImageScale, dY/ImageScale)) - maps
  // actual screen coordinates back into this.graphics' own device-pixel
  // space, the same space each entry's centerX/centerY were recorded in.
  float graphicsX = (xMouse - STUDY.cX) * STUDY.ImageScale;
  float graphicsY = (yMouse - STUDY.cY) * STUDY.ImageScale;

  float halfW = STUDY.urbanThumbnail_sizeX / 2;
  float halfH = STUDY.urbanThumbnail_sizeY / 2;

  for (UrbanThumbnailHoverInfo info : STUDY.urbanThumbnailHoverInfo) {
    float cx = info.centerX, cy = info.centerY;

    if (graphicsX < cx - halfW || graphicsX > cx + halfW || graphicsY < cy - halfH || graphicsY > cy + halfH) continue;

    // daySnapshot's own [q][component][x][y] shape gives the resolution
    // directly - no need to separately look up allSolarImpacts.RES1/RES2
    // (which, by hover time, may not even still match this row's own).
    int resX = info.daySnapshot[0][0].length;
    int resY = info.daySnapshot[0][0][0].length;

    // plotImpact_urban() sizes sizeX/sizeY to already match the image's
    // own aspect ratio (RES1/RES2), so unlike WIN3D's overlay fit rect,
    // there's no letterboxing/cropping to account for here - a plain
    // linear fraction of the thumbnail maps straight onto the data.
    float fx = (graphicsX - (cx - halfW)) / STUDY.urbanThumbnail_sizeX;
    float fy = (graphicsY - (cy - halfH)) / STUDY.urbanThumbnail_sizeY;

    UrbanHoverHit hit = new UrbanHoverHit();
    hit.info = info;
    hit.ix = (int) constrain(fx * resX, 0, resX - 1);
    hit.iy = (int) constrain(fy * resY, 0, resY - 1);
    return hit;
  }

  return null;
}

// Draws the hover box, reusing solarImpactOverlayHover.pde's own text
// formatting (hoverLines()) and box sizing/positioning/edge-
// drawing logic (hoverBoxPosition(), the stroke-inset
// constants) exactly as WIN3D's own hover uses them - same look, same
// behavior, just clamped to STUDY's own dest rect instead of the
// overlay's, and reading from the hit's own snapshot instead of
// allSolarImpacts' live fields.
void drawStudyUrbanHoverBox (int xMouse, int yMouse, UrbanHoverHit hit) {
  float[] raw = win3DOverlay_rawValuesAt_fromSnapshot(hit.info.impactTypeIndex, hit.info.daySnapshot, hit.info.mul, hit.ix, hit.iy);
  String[] lines = hoverLines(xMouse, yMouse, hit.info.impactTypeIndex, raw);
  if (lines == null) return;

  float destX = STUDY.cX, destY = STUDY.cY;
  float destW = STUDY.dX / STUDY.ImageScale, destH = STUDY.dY / STUDY.ImageScale;

  drawHover(xMouse, yMouse, lines, destX, destY, destW, destH, studyPlacedHoverBoxes);
}
