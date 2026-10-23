// Hover for drawNormals() (STUDY.pde) - the 9-statistic-line overlay
// (Min/Max/Average/25th/50th/75th percentile/Mid-Low/Middle/Mid-High)
// shared by every plotHourly() graph: temperature, humidity, wind speed,
// direct/diffuse radiation, whichever layer is actually active when a
// given plotHourly() call runs. Structurally different from the other
// three STUDY hover features - this is an ordinary X/Y time-series chart
// (X = day+hour, Y = the layer's own value, both plain linear axes), not
// a polar dome, a scatter of individually-positioned points, or a grid of
// thumbnails.
//
// Hover here works like a vertical crosshair, common in charting
// libraries: find the nearest column (by time, i.e. X distance) to the
// mouse, and show every statistic's own value at that exact hour, rather
// than hunting for one single nearest line among nine overlapping ones.
// Several plotHourly() graphs can be stacked at different screen heights
// in one view (setupPlot_3() alone shows two at once), so the hit-test
// also checks the mouse's Y against each column's own line envelope (the
// min/max of its defined statistics, plus a margin) - otherwise a column
// from one graph could falsely match a hover meant for a completely
// different graph sitting directly below or above it at the same X.
class NormalsHoverColumn {
  float screenX;
  float hitRadiusX; // half an hour's width, measured in screen space
  float screenY1, screenY2; // this column's own line envelope (min/max Y of its defined statistics) - order not assumed, min()/max() applied at hit-test time
  String dayText;
  int hourIndex;
  float[] normalsValues; // the 9 statistics (NORMAL()'s own return shape) at this column - STAT_N_* constants index into it
  String layerName;
  String layerUnit;
  float verticalUnitOffset; // subtracted back out before display - plotHourly() adds this to every raw value before it ever reaches NORMAL(), the same offset drawNormals()'s own file-export code already subtracts back out
}

// Returns the nearest column (by time) whose own line envelope also
// contains the mouse's Y position, or null if none does - two separate
// checks (X within half an hour, Y within that column's own envelope)
// rather than a single circular radius, since a time-series column's
// "extent" is fundamentally a vertical band of lines, not a point.
NormalsHoverColumn studyNormalsHover_hitTest (float mouseXPos, float mouseYPos) {
  if (STUDY.normalsHoverColumns == null) return null;

  float graphicsX = (mouseXPos - STUDY.cX) * STUDY.ImageScale;
  float graphicsY = (mouseYPos - STUDY.cY) * STUDY.ImageScale;

  NormalsHoverColumn nearest = null;
  float nearestXDist = Float.MAX_VALUE;

  for (NormalsHoverColumn col : STUDY.normalsHoverColumns) {
    float xDist = abs(graphicsX - col.screenX);
    if (xDist > col.hitRadiusX) continue;

    float yLo = min(col.screenY1, col.screenY2) - col.hitRadiusX;
    float yHi = max(col.screenY1, col.screenY2) + col.hitRadiusX;
    if (graphicsY < yLo || graphicsY > yHi) continue;

    if (xDist < nearestXDist) {
      nearestXDist = xDist;
      nearest = col;
    }
  }

  return nearest;
}

// Returns the indices of values[] that are defined, sorted so the
// largest value's own index comes first and the smallest comes last -
// maximum at top, minimum at bottom, matching how the graph itself
// visually stacks higher-valued lines above lower ones, rather than the
// fixed STAT_N_* index order the underlying array uses. A plain selection
// sort, since there are at most 9 entries here - not worth reaching for a
// Comparator. Pure/no drawing, so it's independently checkable without a
// live PGraphics context, unlike the rest of this file's box-drawing.
int[] sortedDefinedIndicesByValueDescending (float[] values) {
  int definedCount = 0;
  int[] definedIndex = new int[values.length];
  float[] definedValue = new float[values.length];
  for (int l = 0; l < values.length; l++) {
    if (is_defined(values[l])) {
      definedIndex[definedCount] = l;
      definedValue[definedCount] = values[l];
      definedCount++;
    }
  }

  for (int a = 0; a < definedCount - 1; a++) {
    int maxPos = a;
    for (int b = a + 1; b < definedCount; b++) {
      if (definedValue[b] > definedValue[maxPos]) maxPos = b;
    }
    if (maxPos != a) {
      float tmpVal = definedValue[a]; definedValue[a] = definedValue[maxPos]; definedValue[maxPos] = tmpVal;
      int tmpIdx = definedIndex[a]; definedIndex[a] = definedIndex[maxPos]; definedIndex[maxPos] = tmpIdx;
    }
  }

  return java.util.Arrays.copyOf(definedIndex, definedCount);
}

// Draws the hover box - a header line (layer name, day, hour) followed by
// one line per defined statistic, skipping any that are undefined for
// this particular column. Reuses the same box sizing/positioning/edge-
// drawing as every other STUDY hover box, built from a dynamically-sized
// line list instead of a fixed count, since how many statistics are
// actually defined varies column to column.
void drawNormalsHoverBox (NormalsHoverColumn col) {
  ArrayList<String> lineList = new ArrayList<String>();
  lineList.add(col.layerName + ", " + col.dayText + " " + nf(col.hourIndex, 2) + ":00");

  int[] sortedIndices = sortedDefinedIndicesByValueDescending(col.normalsValues);
  for (int l : sortedIndices) {
    float value = col.normalsValues[l] - col.verticalUnitOffset;
    lineList.add(STAT_N_Title[l] + ": " + nf(value, 1, 2) + col.layerUnit);
  }

  if (lineList.size() <= 1) return; // header only, nothing defined - shouldn't normally happen since the column was only recorded when at least one statistic was defined, but no reason to show an empty box if it somehow does

  String[] lines = lineList.toArray(new String[0]);

  textSize(MessageSize);
  float lineHeight = textAscent() + textDescent();
  float boxH = hoverTopPad + lines.length * lineHeight + hoverBottomPad;

  float maxTextWidth = 0;
  for (int i = 0; i < lines.length; i++) {
    maxTextWidth = max(maxTextWidth, textWidth(lines[i]));
  }
  float boxW = 2 * hoverSidePad + maxTextWidth;

  float destX = STUDY.cX, destY = STUDY.cY;
  float destW = STUDY.dX / STUDY.ImageScale, destH = STUDY.dY / STUDY.ImageScale;

  float[] boxPos = solarImpactHover_boxPosition(mouseX, mouseY, destX, destY, destW, destH, boxW, boxH);
  float boxX = boxPos[0];
  float boxY = boxPos[1];

  noStroke();
  fill(255, 230);
  rect(boxX, boxY, boxW, boxH);

  stroke(0);
  strokeWeight(hoverStrokeWeight);
  float nearX = (boxX > mouseX) ? boxX : (boxX + boxW);
  float nearY = (boxY > mouseY) ? boxY : (boxY + boxH);
  line(nearX, boxY, nearX, boxY + boxH);
  line(boxX, nearY, boxX + boxW, nearY);

  noStroke();
  fill(0);
  textAlign(LEFT, TOP);
  for (int i = 0; i < lines.length; i++) {
    text(lines[i], boxX + hoverSidePad, boxY + hoverTopPad + i * lineHeight);
  }
}
