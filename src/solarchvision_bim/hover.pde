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

  float boxX = rightHalf ? (xMouse - hoverMargin - boxW) : (xMouse + hoverMargin);
  float boxY = bottomHalf ? (yMouse - hoverMargin - boxH) : (yMouse + hoverMargin);

  boxX = constrain(boxX, destX + hoverStrokeInset, destX + destW - boxW - hoverStrokeInset);
  boxY = constrain(boxY, destY + hoverStrokeInset, destY + destH - boxH - hoverStrokeInset);

  return new float[] { boxX, boxY };
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


void drawHover (int xMouse, int yMouse, String[] lines, float destX, float destY, float destW, float destH) {
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

  float[] boxPos = hoverBoxPosition(xMouse, yMouse, destX, destY, destW, destH, boxW, boxH);
  float boxX = boxPos[0];
  float boxY = boxPos[1];

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


void drawPaletteHover (int xMouse, int yMouse, String[] lines, float destX, float destY, float destW, float destH, float[] col) {
  textSize(MessageSize);
  float lineHeight = textAscent() + textDescent();
  float boxH = hoverTopPad + lines.length * lineHeight + hoverBottomPad;
  float boxW = 2 * hoverSidePad + textWidth(lines[0]);

  float[] boxPos = hoverBoxPosition(xMouse, yMouse, destX, destY, destW, destH, boxW, boxH);
  float boxX = boxPos[0];
  float boxY = boxPos[1];

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
