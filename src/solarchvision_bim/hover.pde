int[][] allHoverPoints = null;

// Pins a new hover point at (x, y) - screen coordinates, the same space
// drawHoversAt() below (and the live, mouse-following call at the bottom
// of drawAllHovers()) already works in - onto the end of allHoverPoints,
// growing it by one. Same int[][]-of-{x,y}-pairs shape (and the same
// null-means-"no points" convention) the scripted HOVER/CLEARHOVER
// commands (extraCommands.pde's __HOVER__/__CLEARHOVER__) already read
// and write, so a point added here shows up to those too, and vice
// versa - there's only ever the one allHoverPoints, however it got
// added to.
void addHoverPoint (int x, int y) {
  int[][] newPoint = { { x, y } };
  allHoverPoints = (allHoverPoints == null) ? newPoint : (int[][]) concat(allHoverPoints, newPoint);
}

// Drops the OLDEST pinned hover point (allHoverPoints[0], the first one
// clicked that's still pinned) - not the most recently added. This
// matches drawAllHovers()'s own newest-to-oldest draw order (hover.pde):
// the newest pin already gets priority placement and is the one least
// likely to need nudging, so Esc trims away the stalest pin first rather
// than undoing whatever was just clicked. The interactive point that
// follows the live mouse is untouched either way, since it was never
// part of allHoverPoints to begin with. Used by Esc (solarchvision_bim.
// pde's own keyPressed()). Returns true if a point was actually removed,
// false if there was nothing to remove - the same "did this consume the
// Esc" convention cancelActivePickList() (mouseClicked.pde) already
// uses, so Esc's own existing if/else-if chain there can add this as one
// more link without changing how any of the others behave.
boolean removeOldestHoverPoint () {
  if ((allHoverPoints == null) || (allHoverPoints.length == 0)) return false;

  allHoverPoints = (int[][]) subset(allHoverPoints, 1);
  if (allHoverPoints.length == 0) allHoverPoints = null;

  return true;
}

// Erases whatever STUDY hover box the previous pass left on screen (see
// clearStudyHover(), hoverOnStudyImpact.pde) exactly once, up front -
// before any of this pass's points are drawn, and regardless of how many
// there are, where they land, or which one happens to be first. Each
// individual point then only ever adds a box, never erases one, so
// multiple simultaneous hover points (allHoverPoints, below) can each
// show their own box at once without one point's draw wiping out
// another's.
//
// Skipped entirely while a UI_menuBar dropdown is open, same reasoning
// as STUDY.draw()'s own guard (STUDY.pde): clearStudyHover()'s own
// restore, and every drawHoversAt() call below it, paint directly onto
// the live screen with no idea the dropdown might be sitting over part
// of whichever region they touch - STUDY's, WIN3D's, or both - so any of
// them could overwrite it. Whatever was on screen (hover boxes included)
// is simply left alone until the menu closes; draw_STUDY_hover() already
// stops offering new hits while selected_parent != -1 (hoverOnStudy
// Impact.pde), so nothing here is actually waiting to happen, it's just
// no longer trying.
//
// Two passes, for two different reasons that each need the OPPOSITE
// order from the other:
//
//  1. Resolving WHERE each box goes has to happen front-to-back
//     (highest-priority point first) - see studyPlacedHoverBoxes/
//     win3DPlacedHoverBoxes's own comment just below hoverBoxPosition()
//     for the full reasoning. This pass only resolves positions and
//     queues everything needed to paint each box later (queueHover()/
//     queuePaletteHover(), both further below) - nothing is actually
//     drawn to the screen yet.
//  2. PAINTING has to happen back-to-front instead: when two boxes
//     can't fully avoid overlapping (resolveHoverBoxPosition()'s own
//     last-resort "least overlap" fallback), whichever one is painted
//     LAST ends up on top - and the box that should stay fully visible
//     is the higher-priority one from pass 1 (the live point, or
//     whichever pin was clicked most recently), not whichever happens
//     to be drawn last by coincidence. So pass 2 drains each panel's
//     queue in the OPPOSITE order it was built in.
//
// Pass 2 deliberately does NOT re-run drawHoversAt()/the hit-testing
// chain a second time: every box's position was already fully decided
// in pass 1, with every OTHER box's final rect as context - re-resolving
// in pass 2 would find that box's own rect still sitting in
// studyPlacedHoverBoxes/win3DPlacedHoverBoxes and could shift it
// somewhere else entirely, undoing pass 1's own priority ordering.
// Queuing once and painting from the queue avoids that outright, rather
// than trying to special-case away a box colliding with itself.
void drawAllHovers () {
  if (UI_menuBar.selected_parent != -1) return;

  clearStudyHover();

  // Fresh per pass - see studyPlacedHoverBoxes/win3DPlacedHoverBoxes
  // (just below hoverBoxPosition()) for what these track and why.
  studyPlacedHoverBoxes = new ArrayList<float[]>();
  win3DPlacedHoverBoxes = new ArrayList<float[]>();
  studyPendingHoverBoxes = new ArrayList<PendingHoverBox>();
  win3DPendingHoverBoxes = new ArrayList<PendingHoverBox>();

  // --- Pass 1: resolve positions, front-to-back priority order ---------
  //
  // drawHoversAt(mouseX, mouseY) genuinely IS resolved (and so, per pass
  // 2 below, painted) first - the live point keeps priority over every
  // pinned point, old or new, same as before. The one adjustment: right
  // before resolving it, peekLastPinnedHoverBoxes() below previews where
  // the MOST RECENTLY pinned point (allHoverPoints' own last entry)
  // would land on its own, and that preview is seeded into
  // studyPlacedHoverBoxes/win3DPlacedHoverBoxes as an extra obstacle for
  // just this one call. So if the live point's own natural spot would
  // land right on the newest pin, resolveHoverBoxPosition() (hover.pde)
  // does its normal job and tries the other quadrants/an axis shift
  // first, same as it would for any other already-placed box - rather
  // than the live point blindly taking its natural spot and leaving the
  // brand new pin to be the one that has to dodge it. The preview is
  // discarded right after (removed from studyPlacedHoverBoxes/
  // win3DPlacedHoverBoxes again): the newest pin's REAL position/content
  // is still decided in its own turn, in the loop below, by then seeing
  // the live point's real (now-resolved) box like any other pin does -
  // this never short-circuits that.
  ArrayList<float[]> lastPinnedPeekStudy = null;
  ArrayList<float[]> lastPinnedPeekWin3D = null;

  if ((allHoverPoints != null) && (allHoverPoints.length > 0)) {
    HoverPeekResult peek = peekLastPinnedHoverBoxes();
    lastPinnedPeekStudy = peek.study;
    lastPinnedPeekWin3D = peek.win3D;

    studyPlacedHoverBoxes.addAll(lastPinnedPeekStudy);
    win3DPlacedHoverBoxes.addAll(lastPinnedPeekWin3D);
  }

  if (control == USER_GUI) {
    drawHoversAt(mouseX, mouseY);
  }

  if (lastPinnedPeekStudy != null) studyPlacedHoverBoxes.removeAll(lastPinnedPeekStudy);
  if (lastPinnedPeekWin3D != null) win3DPlacedHoverBoxes.removeAll(lastPinnedPeekWin3D);

  // Pinned points, newest-to-oldest (not allHoverPoints' own click
  // order), following the live point above - so whichever was JUST
  // clicked still gets first pick of position among the pinned ones.
  // Esc drops the OLDEST pin instead of the newest
  // (removeOldestHoverPoint() below) precisely because of this order:
  // the newest pin already has priority placement and stays put as
  // older ones are trimmed away, rather than Esc repeatedly taking away
  // the one just added.
  if (allHoverPoints != null) {
    for (int i = allHoverPoints.length - 1; i >= 0; i--) {
      int x = allHoverPoints[i][0];
      int y = allHoverPoints[i][1];

      drawHoversAt(x, y);
    }
  }

  // --- Pass 2: paint from the queue, back-to-front ----------------------
  paintHoverQueue(studyPendingHoverBoxes);
  paintHoverQueue(win3DPendingHoverBoxes);
}

// One panel's own throwaway box list from peekLastPinnedHoverBoxes()
// below - each is empty (not null) rather than absent when that panel
// had nothing to show for the peeked point, so drawAllHovers() above
// can addAll()/removeAll() them unconditionally once it's past the
// null-point check.
class HoverPeekResult {
  ArrayList<float[]> study;
  ArrayList<float[]> win3D;
}

// Resolves allHoverPoints' own last entry through the EXACT SAME
// pipeline a real point goes through (drawHoversAt()) - same hit-tests,
// same resolveHoverBoxPosition() call, same box size from the same
// text - but into throwaway placedBoxes/pendingBoxes, swapped in for
// just this one call and swapped back out again right after, so none of
// it is kept: studyPlacedHoverBoxes/win3DPlacedHoverBoxes (the REAL
// ones) and studyPendingHoverBoxes/win3DPendingHoverBoxes are left
// exactly as drawAllHovers() found them. Only called from there, and
// only to seed the live point's OWN resolution with one extra obstacle
// to try to dodge - it doesn't decide anything about the pinned point
// itself, which still gets a normal, independent resolution later in
// drawAllHovers()'s own main loop (by then seeing the live point's real
// box too, same as any other pin would).
HoverPeekResult peekLastPinnedHoverBoxes () {
  ArrayList<float[]> realStudyPlaced = studyPlacedHoverBoxes;
  ArrayList<float[]> realWin3DPlaced = win3DPlacedHoverBoxes;
  ArrayList<PendingHoverBox> realStudyPending = studyPendingHoverBoxes;
  ArrayList<PendingHoverBox> realWin3DPending = win3DPendingHoverBoxes;

  studyPlacedHoverBoxes = new ArrayList<float[]>();
  win3DPlacedHoverBoxes = new ArrayList<float[]>();
  studyPendingHoverBoxes = new ArrayList<PendingHoverBox>();
  win3DPendingHoverBoxes = new ArrayList<PendingHoverBox>();

  int lastIndex = allHoverPoints.length - 1;
  drawHoversAt(allHoverPoints[lastIndex][0], allHoverPoints[lastIndex][1]);

  HoverPeekResult result = new HoverPeekResult();
  result.study = studyPlacedHoverBoxes;
  result.win3D = win3DPlacedHoverBoxes;

  studyPlacedHoverBoxes = realStudyPlaced;
  win3DPlacedHoverBoxes = realWin3DPlaced;
  studyPendingHoverBoxes = realStudyPending;
  win3DPendingHoverBoxes = realWin3DPending;

  return result;
}

// Paints every box a panel's queue collected during pass 1, in reverse -
// see drawAllHovers()'s own comment above for why reverse.
void paintHoverQueue (ArrayList<PendingHoverBox> queue) {
  if (queue == null) return;

  for (int i = queue.size() - 1; i >= 0; i--) {
    PendingHoverBox box = queue.get(i);
    if (box.col == null) paintHover(box);
    else paintPaletteHover(box);
  }
}

void drawHoversAt (int xMouse, int yMouse) {
  draw_WIN3D_hover(xMouse, yMouse);
  draw_STUDY_hover(xMouse, yMouse);
}

// --- solar-impact overlay hover tooltip -----------------------------------
// Shows SOLARCHVISION's actual findings under the mouse, in a small
// floating box near the cursor, whenever there's real data there - see
// hoverLines()'s own comment for what. Set this true to see
// the raw A/R/G/B channel values instead (see win3DOverlay_rawValuesAt()'s
// own comment, SolarImpacts.pde, for what those are).
boolean showARGB_inHover = false;

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
final int hoverMargin = 14; // gap between the cursor and the box
final int hoverTopPad = 6;
final int hoverBottomPad = 8;
final int hoverSidePad = 8;
final int hoverStrokeWeight = 4;
// Processing centers a stroke on its path, so a strokeWeight(2) edge drawn
// exactly at the overlay's own boundary would still stick out 1px past it.
// hoverBoxPosition() below keeps the box this far clear of
// destX..destX+destW/destY..destY+destH, not just boxX..boxX+boxW/
// boxY..boxY+boxH, so the stroke itself never crosses outside the overlay
// - ceil() rather than a plain /2, so an odd strokeWeight still gets a
// whole extra pixel of clearance instead of rounding down short.
final int hoverStrokeInset = (int) ceil(0.5 * hoverStrokeWeight + 1);

// Returns {boxX, boxY}: where a box of size (boxW, boxH) should be drawn
// so it (and its stroke - see hoverStrokeInset above) stays
// entirely inside destX..destX+destW / destY..destY+destH (the overlay's
// own dest rect, from hoverFitRect() above) - on whichever
// side of (xMouse, yMouse) that rect has more room: left of the cursor
// when it's in the right half, right when it's in the left half, and the
// same above/below for the vertical half, rather than a fixed corner that
// could run past an edge. The final constrain() is a safety net for a box
// wider/taller than half the rect. Pure/no drawing, so it's independently
// checkable without a live PGraphics context - see drawSolarImpactHover()'s
// own comment for why nothing else here is.
float[] hoverBoxPosition (int xMouse, int yMouse, float destX, float destY, float destW, float destH, float boxW, float boxH) {
  boolean rightHalf = (xMouse - destX) > (destW / 2);
  boolean bottomHalf = (yMouse - destY) > (destH / 2);

  return hoverQuadrantPosition(xMouse, yMouse, destX, destY, destW, destH, boxW, boxH, rightHalf, bottomHalf);
}

// --- Multi-box collision avoidance (single-pass greedy) --------------------
//
// hoverBoxPosition() above picks ONE natural spot for a single box, with
// no awareness of any other box on screen. When several hover boxes are
// up at once (several pinned allHoverPoints, plus the live one), later
// boxes need to dodge whichever ones are already placed this pass -
// resolveHoverBoxPosition() further below is that.
//
// Scoped per panel: a STUDY box has no business dodging a WIN3D one or
// vice versa, so each panel gets its own list. Reset once per pass by
// drawAllHovers() above, then appended to by queueHover()/
// queuePaletteHover() themselves, right after they resolve a position -
// so by the time the NEXT box in the same pass is resolved, every
// earlier box's own FINAL rect (not just its natural, pre-collision-
// avoidance one) is already in here. That's what makes placement itself
// single-pass rather than measure-everything-then-resolve: nothing
// placed is ever revisited once resolved, which keeps this fast and
// simple for the handful of simultaneous points this is meant for - see
// the conversation that led here for why a two-pass or force-directed
// approach would be solving a problem this doesn't have at that scale.
// (Painting is a separate, later pass - see drawAllHovers() - but that's
// about paint ORDER for overlap stacking, not about revisiting a
// position once resolved.)
// Each entry is {x, y, w, h}, this box's own full rect in the SAME
// screen space as destX/destY/xMouse/yMouse.
ArrayList<float[]> studyPlacedHoverBoxes = new ArrayList<float[]>();
ArrayList<float[]> win3DPlacedHoverBoxes = new ArrayList<float[]>();

// One box queued by queueHover()/queuePaletteHover() during pass 1
// (drawAllHovers() above), carrying everything paintHover()/
// paintPaletteHover() need to actually draw it later, in pass 2 - its
// resolved rect, the anchor point it points back to (for the near/far
// pointer-line geometry), its text, and - only for a palette swatch
// box - the swatch's own color (null for every other hover type, which
// is how paintHoverQueue() above tells the two apart).
class PendingHoverBox {
  float x, y, w, h;
  int xMouse, yMouse;
  String[] lines;
  float[] col;
}

ArrayList<PendingHoverBox> studyPendingHoverBoxes = new ArrayList<PendingHoverBox>();
ArrayList<PendingHoverBox> win3DPendingHoverBoxes = new ArrayList<PendingHoverBox>();

// True if rectangle A (x,y,w,h) and rectangle B overlap at all.
boolean hoverBoxesOverlap (float ax, float ay, float aw, float ah, float bx, float by, float bw, float bh) {
  return (ax < bx + bw) && (ax + aw > bx) && (ay < by + bh) && (ay + ah > by);
}

// How much of rectangle A's own area overlaps rectangle B - 0 if they
// don't overlap at all.
float hoverBoxOverlapArea (float ax, float ay, float aw, float ah, float bx, float by, float bw, float bh) {
  float ox = max(0, min(ax + aw, bx + bw) - max(ax, bx));
  float oy = max(0, min(ay + ah, by + bh) - max(ay, by));
  return ox * oy;
}

// Whether a candidate box at (x, y, w, h) overlaps ANY box already
// placed this pass.
boolean hoverBoxCollides (float x, float y, float w, float h, ArrayList<float[]> placedBoxes) {
  for (float[] b : placedBoxes) {
    if (hoverBoxesOverlap(x, y, w, h, b[0], b[1], b[2], b[3])) return true;
  }
  return false;
}

// Total overlap area a candidate box at (x, y, w, h) would have, summed
// across every box already placed this pass - used only once every
// other candidate has failed to fully clear (see
// resolveHoverBoxPosition() below), to pick whichever one overlaps
// least rather than giving up at an arbitrary one.
float hoverBoxTotalOverlap (float x, float y, float w, float h, ArrayList<float[]> placedBoxes) {
  float total = 0;
  for (float[] b : placedBoxes) {
    total += hoverBoxOverlapArea(x, y, w, h, b[0], b[1], b[2], b[3]);
  }
  return total;
}

// hoverBoxPosition()'s own placement math, parameterized by which
// quadrant to use (right of the anchor or left of it, above or below)
// instead of deriving that from which half of the dest rect the anchor
// itself falls in - hoverBoxPosition() is now just this, called with
// whichever quadrant it always used; resolveHoverBoxPosition() below
// calls it again with the other three when the first one collides.
float[] hoverQuadrantPosition (float xMouse, float yMouse, float destX, float destY, float destW, float destH, float boxW, float boxH, boolean right, boolean bottom) {
  float boxX = right ? (xMouse - hoverMargin - boxW) : (xMouse + hoverMargin);
  float boxY = bottom ? (yMouse - hoverMargin - boxH) : (yMouse + hoverMargin);

  boxX = constrain(boxX, destX + hoverStrokeInset, destX + destW - boxW - hoverStrokeInset);
  boxY = constrain(boxY, destY + hoverStrokeInset, destY + destH - boxH - hoverStrokeInset);

  return new float[] { boxX, boxY };
}

// One axis-shift fallback candidate: the SAME quadrant position `from`
// (one of hoverQuadrantPosition()'s own results), nudged `steps` box-
// widths (alongX true) or box-heights (alongX false) in direction +1/-1,
// clamped back into the dest rect same as every other candidate. Moves
// one axis at a time rather than diagonally, so each candidate still
// reads as a box directly above/below or directly left/right of its
// quadrant's own anchor corner, not an arbitrary point in space.
float[] hoverAxisShiftPosition (float[] from, float destX, float destY, float destW, float destH, float boxW, float boxH, boolean alongX, int direction, int steps) {
  float boxX = from[0];
  float boxY = from[1];

  if (alongX) {
    boxX = constrain(boxX + direction * steps * boxW, destX + hoverStrokeInset, destX + destW - boxW - hoverStrokeInset);
  } else {
    boxY = constrain(boxY + direction * steps * boxH, destY + hoverStrokeInset, destY + destH - boxH - hoverStrokeInset);
  }

  return new float[] { boxX, boxY };
}

// Single-pass greedy collision resolution for one box: tries
// hoverBoxPosition()'s own natural spot first, then (only if that
// collides with something already in placedBoxes) the other three
// quadrants, then - if all four still collide - nudging the natural
// position along a single axis at a time (see hoverAxisShiftPosition()
// above), stepping outward until clear or the dest rect's own edge is
// reached. If nothing tried fully clears every placed box, returns
// whichever candidate had the smallest total overlap rather than
// picking an arbitrary one. Pure/no drawing (same as hoverBoxPosition()
// itself), so independently testable without a live PGraphics context -
// queueHover()/queuePaletteHover() (both below) are the only callers,
// and both append this result to placedBoxes themselves right after, so
// the next box resolved in the same pass sees it too.
float[] resolveHoverBoxPosition (float xMouse, float yMouse, float destX, float destY, float destW, float destH, float boxW, float boxH, ArrayList<float[]> placedBoxes) {
  float[] natural = hoverBoxPosition((int) xMouse, (int) yMouse, destX, destY, destW, destH, boxW, boxH);

  if ((placedBoxes == null) || placedBoxes.isEmpty() || !hoverBoxCollides(natural[0], natural[1], boxW, boxH, placedBoxes)) {
    return natural;
  }

  ArrayList<float[]> candidates = new ArrayList<float[]>();
  candidates.add(natural);

  boolean naturalRight = (xMouse - destX) > (destW / 2);
  boolean naturalBottom = (yMouse - destY) > (destH / 2);

  // The other three quadrants - same anchor, opposite side(s).
  float[][] otherQuadrants = {
    hoverQuadrantPosition(xMouse, yMouse, destX, destY, destW, destH, boxW, boxH, !naturalRight, naturalBottom),
    hoverQuadrantPosition(xMouse, yMouse, destX, destY, destW, destH, boxW, boxH, naturalRight, !naturalBottom),
    hoverQuadrantPosition(xMouse, yMouse, destX, destY, destW, destH, boxW, boxH, !naturalRight, !naturalBottom)
  };
  for (float[] c : otherQuadrants) {
    candidates.add(c);
    if (!hoverBoxCollides(c[0], c[1], boxW, boxH, placedBoxes)) return c;
  }

  // None of the four quadrants cleared it - fall back to nudging the
  // natural position along a single axis, one box-width/box-height at a
  // time, in whichever direction, until the dest rect's own edge is
  // reached on that axis.
  int maxStepsX = max(1, (int) floor(destW / boxW));
  int maxStepsY = max(1, (int) floor(destH / boxH));

  for (int steps = 1; steps <= max(maxStepsX, maxStepsY); steps++) {
    if (steps <= maxStepsX) {
      float[] right = hoverAxisShiftPosition(natural, destX, destY, destW, destH, boxW, boxH, true, 1, steps);
      candidates.add(right);
      if (!hoverBoxCollides(right[0], right[1], boxW, boxH, placedBoxes)) return right;

      float[] left = hoverAxisShiftPosition(natural, destX, destY, destW, destH, boxW, boxH, true, -1, steps);
      candidates.add(left);
      if (!hoverBoxCollides(left[0], left[1], boxW, boxH, placedBoxes)) return left;
    }

    if (steps <= maxStepsY) {
      float[] down = hoverAxisShiftPosition(natural, destX, destY, destW, destH, boxW, boxH, false, 1, steps);
      candidates.add(down);
      if (!hoverBoxCollides(down[0], down[1], boxW, boxH, placedBoxes)) return down;

      float[] up = hoverAxisShiftPosition(natural, destX, destY, destW, destH, boxW, boxH, false, -1, steps);
      candidates.add(up);
      if (!hoverBoxCollides(up[0], up[1], boxW, boxH, placedBoxes)) return up;
    }
  }

  // Nothing tried fully clears every placed box - use whichever
  // candidate overlaps the least rather than giving up at an arbitrary
  // one (the natural position, say, which is already candidates.get(0)
  // and is as reasonable a last resort as any, but not necessarily the
  // least-overlapping one tried).
  float[] best = candidates.get(0);
  float bestOverlap = hoverBoxTotalOverlap(best[0], best[1], boxW, boxH, placedBoxes);
  for (int k = 1; k < candidates.size(); k++) {
    float[] c = candidates.get(k);
    float overlap = hoverBoxTotalOverlap(c[0], c[1], boxW, boxH, placedBoxes);
    if (overlap < bestOverlap) {
      bestOverlap = overlap;
      best = c;
    }
  }
  return best;
}

// Returns the text lines to show for Image[q][dayIndex]'s pixel (x, y),
// or null if there's no real data there (see win3DOverlay_rawValuesAt()'s
// own comment, SolarImpacts.pde).
//
// Defaults (showARGB_inHover false) to what SOLARCHVISION's passive/
// active solar-climatic impact method actually found there, rather than
// the raw channel values themselves - see Mojtaba Samimi's "Degree of
// Need to Shade/Shine" (TU Berlin, 2014): every hour's sun on a surface is
// weighted by base minus outdoor temperature, so a map says not just
// where the sun lands but whether it's wanted there.
//   Active (G): the solar radiation actually received, kWh/m2.
//   Passive (R, B): sun received in cold hours or blocked in warm hours
//   counts as a benefit (P, kept in B); the reverse counts as harm (N,
//   kept in R) - see Matrix_ARGB's own build site (SolarImpacts.pde) for
//   exactly how these get accumulated hour by hour. The comparison score
//   S = (P - N)*|P - N|/(P + N), kWh*C/m2, is the same formula the
//   passive palette color itself is already chosen from.
String[] hoverLines (int xMouse, int yMouse, int q, int dayIndex, int x, int y) {
  float[] raw = allSolarImpacts.win3DOverlay_rawValuesAt(q, dayIndex, x, y);
  return hoverLines(xMouse, yMouse, q, raw);
}

// Same formatting, for a raw A/R/G/B that's already been looked up some
// other way - e.g. studyImpactHover.pde's own snapshot-based lookup,
// which can't go through allSolarImpacts' live fields the way the
// overload above does (see UrbanThumbnailHoverInfo's own comment on why).
String[] hoverLines (int xMouse, int yMouse, int q, float[] raw) {
  if (raw == null) return null;

  if (showARGB_inHover) {
    return new String[] {
      "A: " + nf(raw[0], 1, 2),
      "R: " + nf(raw[1], 1, 2),
      "G: " + nf(raw[2], 1, 2),
      "B: " + nf(raw[3], 1, 2)
    };
  }

  if (q == Impact_ACTIVE) {
    float received = raw[2]; // G
    return new String[] { "Received: " + nf(received, 1, 2) + " kWh/m\u00B2" };
  }

  // Impact_PASSIVE
  float P = raw[3]; // B
  float N = raw[1]; // R
  float S = ((P + N) > 0.00001) ? (P - N) * abs(P - N) / (P + N) : 0;

  return new String[] {
    "Positive: +" + nf(P, 1, 2) + " kWh\u00B0C/m\u00B2",
    "Negative: -" + nf(N, 1, 2) + " kWh\u00B0C/m\u00B2",
    "Final Score: " + nf(S, 1, 2) + " %kWh\u00B0C/m\u00B2"
  };
}


// Resolves where this box belongs (claiming that spot in placedBoxes
// for whatever's resolved next) and queues it to be painted later in
// pass 2 (pendingBoxes - see drawAllHovers()'s own comment on why
// painting is deferred and reversed). Nothing is drawn to the screen by
// this call.
void queueHover (int xMouse, int yMouse, String[] lines, float destX, float destY, float destW, float destH, ArrayList<float[]> placedBoxes, ArrayList<PendingHoverBox> pendingBoxes) {
  // textWidth()/textAscent()/textDescent() below all read the current text
  // size, so this has to happen before measuring anything.
  textSize(MessageSize);

  float lineHeight = textAscent() + textDescent();
  float boxH = hoverTopPad + lines.length * lineHeight + hoverBottomPad;

  float maxTextWidth = 0;
  for (int i = 0; i < lines.length; i++) {
    maxTextWidth = max(maxTextWidth, textWidth(lines[i]));
  }
  float boxW = 2 * hoverSidePad + maxTextWidth;

  float[] boxPos = resolveHoverBoxPosition(xMouse, yMouse, destX, destY, destW, destH, boxW, boxH, placedBoxes);
  float boxX = boxPos[0];
  float boxY = boxPos[1];

  if (placedBoxes != null) placedBoxes.add(new float[] { boxX, boxY, boxW, boxH });

  if (pendingBoxes != null) {
    PendingHoverBox box = new PendingHoverBox();
    box.x = boxX;
    box.y = boxY;
    box.w = boxW;
    box.h = boxH;
    box.xMouse = xMouse;
    box.yMouse = yMouse;
    box.lines = lines;
    box.col = null;
    pendingBoxes.add(box);
  }
}

// Paints a box queueHover() already resolved and queued - see this
// section's own header comment (drawAllHovers()) for when this runs
// relative to queueHover() itself.
void paintHover (PendingHoverBox box) {
  float boxX = box.x, boxY = box.y, boxW = box.w, boxH = box.h;
  int xMouse = box.xMouse, yMouse = box.yMouse;
  String[] lines = box.lines;

  textSize(MessageSize);
  float lineHeight = textAscent() + textDescent();

  stroke(0);
  strokeWeight(1);
  fill(255, 230);
  rect(
    boxX - hoverStrokeWeight / 2,
    boxY - hoverStrokeWeight / 2,
    boxW + hoverStrokeWeight,
    boxH + hoverStrokeWeight
  );

  // Just the one horizontal and one vertical edge closest to the cursor,
  // rather than a full border: whichever ones that is tells you which
  // corner points back at the actual hovered pixel, instead of leaving
  // that ambiguous with a box outlined on all four sides.
  stroke(0);
  strokeWeight(hoverStrokeWeight);
  float nearX = (boxX > xMouse) ? boxX : (boxX + boxW);
  float nearY = (boxY > yMouse) ? boxY : (boxY + boxH);
  line(nearX, boxY, nearX, boxY + boxH);
  line(boxX, nearY, boxX + boxW, nearY);

  float farX = (boxX < xMouse) ? boxX : (boxX + boxW);
  float farY = (boxY < yMouse) ? boxY : (boxY + boxH);
  strokeWeight(1);
  line(xMouse, yMouse, nearX, nearY);
  if (xMouse < boxX || xMouse > boxX + boxW) {
    line(xMouse, yMouse, nearX + (boxX > xMouse ? -1 : 1) * hoverStrokeWeight / 2, farY);
  }
  if (yMouse < boxY || yMouse > boxY + boxH) {
    line(xMouse, yMouse, farX, nearY + (boxY > yMouse ? -1 : 1) * hoverStrokeWeight / 2);
  }

  noStroke();
  fill(0);
  textAlign(LEFT, TOP);
  for (int i = 0; i < lines.length; i++) {
    float y = boxY + hoverTopPad + i * lineHeight;
    if (lines[i].equals(___divider___)) {
      stroke(0);
      strokeWeight(1);
      line(
        boxX + hoverSidePad,        y + lineHeight / 2,
        boxX + boxW - hoverSidePad, y + lineHeight / 2
      );
      noStroke();
      strokeWeight(0);
    } else {
      text(lines[i], boxX + hoverSidePad, y);
    }
  }
}


// Same split as queueHover()/paintHover() above, for the palette-swatch
// variant - resolves and queues here, actually paints in
// paintPaletteHover() below.
void queuePaletteHover (int xMouse, int yMouse, String[] lines, float destX, float destY, float destW, float destH, float[] col, ArrayList<float[]> placedBoxes, ArrayList<PendingHoverBox> pendingBoxes) {
  textSize(MessageSize);
  float lineHeight = textAscent() + textDescent();
  float boxH = hoverTopPad + lines.length * lineHeight + hoverBottomPad;
  float boxW = 2 * hoverSidePad + textWidth(lines[0]);

  float[] boxPos = resolveHoverBoxPosition(xMouse, yMouse, destX, destY, destW, destH, boxW, boxH, placedBoxes);
  float boxX = boxPos[0];
  float boxY = boxPos[1];

  if (placedBoxes != null) placedBoxes.add(new float[] { boxX, boxY, boxW, boxH });

  if (pendingBoxes != null) {
    PendingHoverBox box = new PendingHoverBox();
    box.x = boxX;
    box.y = boxY;
    box.w = boxW;
    box.h = boxH;
    box.xMouse = xMouse;
    box.yMouse = yMouse;
    box.lines = lines;
    box.col = col;
    pendingBoxes.add(box);
  }
}

void paintPaletteHover (PendingHoverBox box) {
  float boxX = box.x, boxY = box.y, boxW = box.w, boxH = box.h;
  int xMouse = box.xMouse, yMouse = box.yMouse;
  String[] lines = box.lines;
  float[] col = box.col;

  textSize(MessageSize);

  // col is {alpha, r, g, b} (PAINT.getColorStyle()'s own order) - alpha isn't needed here.
  float swatchR = col[1], swatchG = col[2], swatchB = col[3];
  float luminance = (0.299 * swatchR + 0.587 * swatchG + 0.114 * swatchB) / 255.0;
  boolean useWhiteText = luminance < 0.5;

  stroke(0);
  strokeWeight(1);
  fill(swatchR, swatchG, swatchB, 230);
  rect(
    boxX - hoverStrokeWeight / 2,
    boxY - hoverStrokeWeight / 2,
    boxW + hoverStrokeWeight,
    boxH + hoverStrokeWeight
  );

  stroke(0);
  strokeWeight(hoverStrokeWeight);
  float nearX = (boxX > xMouse) ? boxX : (boxX + boxW);
  float nearY = (boxY > yMouse) ? boxY : (boxY + boxH);
  line(nearX, boxY, nearX, boxY + boxH);
  line(boxX, nearY, boxX + boxW, nearY);

  noStroke();
  fill(useWhiteText ? 255 : 0);
  textAlign(LEFT, TOP);
  text(lines[0], boxX + hoverSidePad, boxY + hoverTopPad);
}
