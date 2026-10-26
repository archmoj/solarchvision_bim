// Hover for drawProbs() (STUDY.pde) - the probability histogram overlay
// shared by every plotHourly() graph, same as drawNormals()'s own hover
// (hoverOnStudyNormals.pde). Structurally simpler than that one, though:
// drawNormals() hovers over thin lines, which have no area of their own,
// so it needs a generous hit radius and a "nearest column" search.
// drawProbs() instead draws an actual filled rectangle per bin, so each
// one already has its own screen-space area - hover here is just a plain
// point-in-rect test against that same rectangle, no radius or nearest-
// match logic needed.
//
// Per the brief this was built from: probabilities and normals are drawn
// at the same screen position only when both STUDY.showProbabilities and
// STUDY.showNormalLines are on at once, which isn't the common case (one
// or the other is typically shown, not both) - so to start, this doesn't
// attempt to resolve overlap between the two the way urban/pose/sunpath's
// priority order does; draw_STUDY_hover() just checks probs before (or
// after) normals. Worth revisiting if showing both at once turns out to
// be more common than expected.
class ProbsHoverBox {
  float screenX1, screenY1, screenX2, screenY2; // this box's own screen-space rectangle - order not assumed, min()/max() applied at hit-test time
  float binLow, binHigh; // the real-world value range this bin covers (verticalUnitOffset already subtracted back out, same as drawNormals()'s own hover)
  float probPercent; // 100 * prob_V - the same percentage already drawn inside the box itself
  int sampleCount; // probs[n] - how many of this window's individual readings landed in this bin
  int totalCount; // totalProbs - how many readings this window had in total, across every bin
  float targetDate; // raw date value (TIME.getDayText()'s own float argument), the centre of the merged-days window - see NormalsHoverColumn's own identical field
  int daysMergedHalf; // int(daysMergedCount / 2) at the moment this box was recorded; 0 when daysMergedCount <= 1 (no day-merging)
  int hourEnd; // the hour drawProbs() was called at - the last hour of its own probabilityWidthInterval-hour window
  int hourWidth; // probabilityWidthInterval at the moment this box was recorded - hourEnd - hourWidth + 1 is the window's first hour
  String layerName;
  String layerUnit;
}

// Returns the box the mouse is over, or null if it isn't over any of this
// pass's boxes. A plain point-in-rect test, tried against every recorded
// box - boxes from the same window stack without gaps or overlap (see
// drawProbs()'s own h = _pix), and boxes from different windows/days sit
// at entirely different screen positions, so at most one can ever match;
// first match found is returned rather than searching for a "nearest" one.
ProbsHoverBox studyProbsHover_hitTest (int xMouse, int yMouse) {
  if (STUDY.probsHoverBoxes == null) return null;

  float graphicsX = (xMouse - STUDY.cX) * STUDY.ImageScale;
  float graphicsY = (yMouse - STUDY.cY) * STUDY.ImageScale;

  for (ProbsHoverBox box : STUDY.probsHoverBoxes) {
    float xLo = min(box.screenX1, box.screenX2);
    float xHi = max(box.screenX1, box.screenX2);
    float yLo = min(box.screenY1, box.screenY2);
    float yHi = max(box.screenY1, box.screenY2);

    if (graphicsX < xLo || graphicsX > xHi || graphicsY < yLo || graphicsY > yHi) continue;

    return box;
  }

  return null;
}

// Formats the window's hour range as display text, e.g. "Time: 04:00 -
// 08:00" for a 4-hour window ending at hour 7 (hourEnd=7, hourWidth=4),
// or "Time: 07:00 - 08:00" for a single hour (hourEnd=7, hourWidth=1).
// hourEnd is drawProbs()'s own "i" - the window's LAST hour, which is
// itself the START of that hour's own one-hour span - so the window's
// true end time is hourEnd + 1, not hourEnd: a 4-hour window covering
// hours 4, 5, 6, 7 spans from 04:00 up through the end of the 7:00 hour,
// i.e. 08:00, not 07:00 (which would under-represent it by a full hour,
// and would make a 1-hour window display as a single instant rather than
// the hour-long span it actually covers). No day-boundary wraparound
// (hourEnd=23 displays as "... - 24:00") - the window's own date doesn't
// change just because its end time reads as the next day's midnight, and
// adding that would mean deciding which day to show set alongside which
// hour text, not just reformatting a number. Pulled out as its own pure
// function (no live graphics touched) so it's testable on its own,
// unlike the rest of drawProbsHoverBox() below.
String probsHoverTimeRangeText (int hourEnd, int hourWidth) {
  int hourStart = hourEnd - hourWidth + 1;
  return "Time: " + nf(hourStart, 2) + ":00 \u2013 " + nf(hourEnd + 1, 2) + ":00";
}

// Draws the hover box - layer name, the window's own date/hour range, the
// bin's value range, and its probability (both the percentage and the
// raw sample count it's based on). Same box sizing/positioning/edge-
// drawing as every other STUDY hover feature (drawHover(), hover.pde).
void drawProbsHoverBox (int xMouse, int yMouse, ProbsHoverBox box) {
  ArrayList<String> lineList = new ArrayList<String>();
  lineList.add(box.layerName);
  lineList.add(probsHoverTimeRangeText(box.hourEnd, box.hourWidth));

  // Same Window/Target split as drawNormalsHoverBox() - see that
  // function's own comment for why daysMergedHalf gets its own line
  // rather than being folded into one line with the target date.
  if (box.daysMergedHalf > 0) {
    String startText = TIME.getDayText(box.targetDate - box.daysMergedHalf);
    String endText = TIME.getDayText(box.targetDate + box.daysMergedHalf);
    lineList.add("Window: " + startText + " \u2013 " + endText);
    lineList.add("Target: " + TIME.getDayText(box.targetDate) + " (\u00B1" + box.daysMergedHalf + " " + TIME.WORDS[2][activeLanguage] + "s)");
  } else {
    lineList.add("Target: " + TIME.getDayText(box.targetDate));
  }

  lineList.add(___divider___);

  lineList.add("Range: " + nf(box.binLow, 1, 2) + " \u2013 " + nf(box.binHigh, 1, 2) + box.layerUnit);
  lineList.add("Probability: " + nf(box.probPercent, 1, 1) + "%");
  lineList.add("Samples: " + box.sampleCount + " / " + box.totalCount);

  String[] lines = lineList.toArray(new String[0]);

  float destX = STUDY.cX, destY = STUDY.cY;
  float destW = STUDY.dX / STUDY.ImageScale, destH = STUDY.dY / STUDY.ImageScale;

  drawHover(xMouse, yMouse, lines, destX, destY, destW, destH);
}
