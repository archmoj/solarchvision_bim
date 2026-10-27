// Hover for "Sun Path" - note the UI label (actions.pde, UI_menuBar.pde)
// and the internal name don't match: this is plotImpact_cycles()
// (STUDY.pde), which delegates its actual drawing to Sun3D.pde's
// drawCycles() - the same mesh WIN3D's live 3D view and the OBJ exporter
// both also use, via drawPattern()/export_objects_OBJ.pde. Only the
// target_window == TypeWindow.STUDY branch inside drawCycles() records
// anything here (STUDY.cyclesHoverPoints); WIN3D/OBJ3D/WORLD never touch
// this list, so there's nothing to add or guard against on those - hover
// was only asked for on STUDY.
//
// hoverOnStudySunpath.pde's own header already called this one out as
// "substantially more involved" than Hourly Sun, and the reason is
// structural: Hourly Sun (plotImpact_sunpath()) draws one independent,
// individually-colored ellipse per actual (day, hour) sample - a sparse
// scatter with real gaps between points. This graph instead draws a
// smoothly vertex-interpolated mesh (quads, each corner its own
// Alpha/Beta/valuesSUM, colors blending continuously across each quad's
// face) that tiles the entire visible sky dome with no gaps - so unlike
// Hourly Sun, there's no single "nearest sample" in open space to search
// for; every point ON the mesh is as valid a hover target as any other.
// This still does a nearest-neighbor search over the mesh's own vertices
// (the only approach shared with Hourly Sun) rather than inverting the
// Alpha/Beta-to-screen mapping directly (the way Pose Potential's grid
// does) - vertex-to-vertex spacing on a dome varies with where you are on
// it, so there's no fixed formula to invert the way a regular grid has.
class CyclesHoverPoint {
  float screenX, screenY;
  float hitRadius; // roughly one quad-cell's own on-screen size at this vertex (Sun3D.pde's own drawCycles(), same "offset and measure" trick as SunpathHoverPoint's own hitRadius) - since the mesh tiles solidly, this is generous enough that hovering anywhere actually drawn finds something, while still returning nothing once the mouse leaves the mesh entirely (background, the palette legend, title text)
  float Alpha, Beta; // sun's own altitude/azimuth at this vertex
  float valuesSUM; // this vertex's own value - received radiation (Active) or direct effect (Passive), same single-number display drawCycles() itself already colors the mesh by
  int impactTypeIndex;
  int hour; // 0-23 - this vertex's own hour-grid index (drawCycles()'s own "a"), a single point in time, not a window - unlike calendarDay/daysMergedHalf below, hours are never merged in this graph
  int calendarDay; // drawCycles()'s own "now_j2" for this vertex's ROW (merged-day-group) - the SAME actual date used to fetch the data this vertex's own valuesSUM was computed from, same wrapped 0-364 day index TIME.getDayText() (TIME.pde) expects
  int daysMergedHalf; // STUDY.daysMergedCount's own half-width at the moment this point was recorded, 0 when daysMergedCount <= 1 (no day-merging) - same field/meaning as NormalsHoverColumn's and ProbsHoverBox's own daysMergedHalf
}

// Nearest mesh vertex to the mouse, within that vertex's own hitRadius -
// null if STUDY.cyclesHoverPoints is empty or nothing recorded is close
// enough. Same structure as studySunpathHover_hitTest()
// (hoverOnStudySunpath.pde) - the per-point hitRadius is what makes this
// behave like a continuous surface rather than Hourly Sun's own sparse
// scatter, since the mesh's dense, overlapping coverage means some
// vertex is almost always within reach wherever the mesh was actually
// drawn.
CyclesHoverPoint studyCyclesHover_hitTest (int xMouse, int yMouse) {
  if (STUDY.cyclesHoverPoints == null) return null;

  float graphicsX = (xMouse - STUDY.cX) * STUDY.ImageScale;
  float graphicsY = (yMouse - STUDY.cY) * STUDY.ImageScale;

  CyclesHoverPoint nearest = null;
  float nearestDistSq = Float.MAX_VALUE;

  for (CyclesHoverPoint p : STUDY.cyclesHoverPoints) {
    float dx = graphicsX - p.screenX;
    float dy = graphicsY - p.screenY;
    float distSq = dx * dx + dy * dy;
    if (distSq < nearestDistSq) {
      nearestDistSq = distSq;
      nearest = p;
    }
  }

  if (nearest == null) return null;
  if (nearestDistSq > nearest.hitRadius * nearest.hitRadius) return null;

  return nearest;
}

// Draws the hover box - reuses formatAzimuthAndAltitude() directly
// (hoverOnStudySunpath.pde) rather than redefining it, since both
// graphs show the exact same sun-position formatting. The value line
// gets its own descriptive label (matching plotImpact_cycles()'s own
// on-graph legend text exactly - STUDY.pde - "Direct solar radiation"/
// "Direct solar effects") rather than showing a bare number, since
// unlike Hourly Sun this graph doesn't already show that label next to
// every point it draws. Time/date formatted the same "Window:"/
// "Target:" way drawProbsHoverBox() (hoverOnStudyProbs.pde) and
// drawNormalsHoverBox() (hoverOnStudyNormals.pde) already do for a
// merged-days window, for the same reason: showing just the "found
// match" date on its own, with no indication it's the center of a
// several-day search window, would read as more precise than it is.
void placeCyclesHoverBox (int xMouse, int yMouse, CyclesHoverPoint p) {
  String variableLabel = (p.impactTypeIndex == Impact_ACTIVE) ? "Direct solar radiation" : "Direct solar effects";
  String unit = (p.impactTypeIndex == Impact_ACTIVE) ? " kWh/m\u00B2" : " kWh\u00B0C/m\u00B2";
  String valueLine = variableLabel + ": " + nf(p.valuesSUM, 1, 2) + unit;

  ArrayList<String> lineList = new ArrayList<String>();
  lineList.add(formatAzimuthAndAltitude(p.Beta, p.Alpha));
  lineList.add("Time: " + nf(p.hour, 2) + ":00");

  if (p.daysMergedHalf > 0) {
    String startText = TIME.getDayText(p.calendarDay - p.daysMergedHalf);
    String endText = TIME.getDayText(p.calendarDay + p.daysMergedHalf);
    lineList.add("Window: " + startText + " \u2013 " + endText);
    lineList.add("Target: " + TIME.getDayText(p.calendarDay) + " (\u00B1" + p.daysMergedHalf + " " + TIME.WORDS[2][activeLanguage] + "s)");
  } else {
    lineList.add("Date: " + TIME.getDayText(p.calendarDay));
  }

  lineList.add(___divider___);
  lineList.add(valueLine);

  String[] lines = lineList.toArray(new String[0]);

  float destX = STUDY.cX, destY = STUDY.cY;
  float destW = STUDY.dX / STUDY.ImageScale, destH = STUDY.dY / STUDY.ImageScale;

  queueHover(xMouse, yMouse, lines, destX, destY, destW, destH, studyPlacedHoverBoxes, studyPendingHoverBoxes);
}
