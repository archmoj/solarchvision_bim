// Hover for "Hourly Sun" - note the UI label (actions.pde, UI_menuBar.pde)
// and the internal name (plotImpact_sunpath(), impactGraphIndex_SUNPATH_*)
// don't match: "Hourly Sun" is plotImpact_sunpath() internally, while
// "Sun Path" (the other UI label) is plotImpact_cycles() internally.
// This file is for "Hourly Sun"/plotImpact_sunpath() - the simpler of the
// two to add hover to, since it draws one independent, individually-
// colored ellipse per actual (day, hour) sample, at the sun's own
// continuous altitude/azimuth position - not a regular grid of buckets
// (Pose Potential) or a smoothly vertex-interpolated mesh surface shared
// with WIN3D's own live 3D view and OBJ export (plotImpact_cycles(), via
// Sun3D.pde's drawCycles() - substantially more involved, and not
// attempted here).
//
// Unlike Pose Potential's dome, there's no grid to invert a polar
// coordinate into - the hit-test just finds whichever recorded point the
// mouse is nearest to, within that point's own on-screen radius.
//
// No snapping here (unlike Pose Potential's inclination) - Alpha/Beta are
// shown exactly as they are, called altitude/azimuth rather than
// inclination/orientation since these describe the sun's own actual
// position in the sky, not a building surface's tilt.
class SunpathHoverPoint {
  float screenX, screenY;
  float hitRadius; // this point's own on-screen ellipse radius, measured via screenX/screenY same as everywhere else this session
  float Alpha, Beta; // sun's own altitude/azimuth at this sample
  float valuesSUM; // the single value this graph itself already displays as text on the point - received radiation (Active) or direct effect (Passive), no P/N/Score breakdown the way Skin/Pose Potential have
  int impactTypeIndex;
}

// Azimuth: the sun's own compass bearing, read directly off the same Beta
// this graph's own quad math already treats as degrees from south (see
// plotImpact_sunpath()'s own Beta = 180 - atan2_ang(SunR[1], SunR[2])) -
// converted to a standard compass bearing (N=0) the same way
// studyPoseHover.pde's formatOrientation() does, but shown as a plain
// angle rather than a nearest-direction label, since azimuth is
// conventionally read as a number, not a compass point.
// Altitude: the sun's own angle above the horizon, shown plainly.
String formatAzimuthAndAltitude (float Beta, float Alpha) {
  float compassBearing = ((180 - Beta) % 360 + 360) % 360;
  return "Azimuth " + nf(round(compassBearing), 1, 0) + "\u00B0, Altitude " + nf(round(Alpha), 1, 0) + "\u00B0";
}

// Returns the nearest recorded point to the mouse, or null if nothing is
// within that point's own hit radius - a simple nearest-neighbor search
// over a scatter of independent points, rather than Pose Potential's
// direct polar-to-bucket computation (there's no grid here to compute
// into) or Skin Potential's per-thumbnail rect containment check (points
// here are circular, not rectangular regions).
SunpathHoverPoint studySunpathHover_hitTest (int xMouse, int yMouse) {
  if (STUDY.sunpathHoverPoints == null) return null;

  float graphicsX = (xMouse - STUDY.cX) * STUDY.ImageScale;
  float graphicsY = (yMouse - STUDY.cY) * STUDY.ImageScale;

  SunpathHoverPoint nearest = null;
  float nearestDistSq = Float.MAX_VALUE;

  for (SunpathHoverPoint p : STUDY.sunpathHoverPoints) {
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

// Draws the hover box - same formatting/sizing/positioning/edge-drawing
// reuse as the other two hover boxes, with a plain single-value line
// instead of hoverLines()'s Active/Passive formatting, since
// this graph only ever displays the one number (no P/N/Score split) for
// either impact type.
void drawSunpathHoverBox (int xMouse, int yMouse, SunpathHoverPoint p) {
  String unit = (p.impactTypeIndex == Impact_ACTIVE) ? " kWh/m\u00B2" : " kWh\u00B0C/m\u00B2";
  String valueLine = nf(p.valuesSUM, 1, 2) + unit;

  String[] lines = { formatAzimuthAndAltitude(p.Beta, p.Alpha), valueLine };

  float destX = STUDY.cX, destY = STUDY.cY;
  float destW = STUDY.dX / STUDY.ImageScale, destH = STUDY.dY / STUDY.ImageScale;

  queueHover(xMouse, yMouse, lines, destX, destY, destW, destH, studyPlacedHoverBoxes, studyPendingHoverBoxes);
}
