// One dome's worth of hover-relevant info, captured by plotImpact_global()
// (STUDY.pde) at the moment it finishes drawing that dome (one per day,
// plus one for the summary). valuesSUM_RAD/EFF_P/EFF_N themselves are
// plain local variables inside plotImpact_global()'s own (a,b) loop,
// recomputed fresh for every wedge and never otherwise kept anywhere -
// snapshotRAD/EFF_P/EFF_N below are each day's own fresh [a][b] grid,
// filled in alongside that day's own quad drawing (no deep-clone needed
// here the way Skin Potential's hover needed one for Matrix_ARGB - these
// grids are already a brand new array per call, not a shared one getting
// overwritten by a later call). Still a per-dome snapshot rather than a
// single shared one, for the same reason as Skin Potential's hover:
// setupPlot_4()'s viewLayout==2 branch calls plotImpact_global() twice in
// one render pass (two of the three percentile group members), each its
// own dome, each its own data.
class GlobalPoseHoverInfo {
  float centerX, centerY; // this dome's own center (Alpha=90, radius 0), in this.graphics' own device-pixel space
  float pixelsPerDegree;  // screen-space radius per 1 degree of (90-Alpha) - measured via screenX/screenY, not hand-derived, so it's correct under whichever setupPlot_N layout is active
  int impactTypeIndex;
  float[][] snapshotRAD;   // [a][b]
  float[][] snapshotEFF_P; // [a][b]
  float[][] snapshotEFF_N; // [a][b]
}

// Builds the same {A, R, G, B}-shaped array hoverLines()
// expects, from Pose Potential's own RAD/EFF_P/EFF_N concepts instead of
// Skin Potential's Matrix_ARGB channels - Active's G slot carries the
// received radiation (valuesSUM_RAD), Passive's R/B slots carry N/P
// (valuesSUM_EFF_N/valuesSUM_EFF_P) as benefit/harm, the exact same
// mapping SolarImpacts.pde's own Matrix_ARGB already uses. A (slot 0) is
// never actually displayed by hoverLines() unless
// showARGB_inHover is on, so it's just set to match whatever's shown.
// Mirrors plotImpact_global()'s own AVERAGE/PERCENTAGE/COMPARISON/
// is_defined(valuesSUM) gate exactly (not just approximately) so a wedge
// hovers if and only if it was actually drawn.
float[] globalPoseRawValuesAt (GlobalPoseHoverInfo info, int a, int b) {
  if (info.impactTypeIndex == Impact_ACTIVE) {
    float rad = info.snapshotRAD[a][b];
    if (!is_defined(rad)) return null;
    return new float[] { rad, 0, rad, 0 };
  }

  float p = info.snapshotEFF_P[a][b];
  float n = info.snapshotEFF_N[a][b];

  float average = p - n;
  float percentage = ((p + n) > 0.00001) ? average / (p + n) : 0.0;
  float comparison = abs(percentage) * average;

  if (!is_defined(comparison)) return null;

  return new float[] { p + n, n, 0, p };
}

// The dome entry a hit landed on, plus which of its own (a,b) wedges -
// displayAlpha is the (possibly snapped - see snapInclination() below)
// inclination actually used to pick that wedge, stored directly rather
// than re-derived from a alone: re-deriving it as a*inclinationStepImplied
// would make the snap thresholds drift with the grid's own resolution,
// since ordinary nearest-bucket rounding can already land on the extreme
// bucket for inclinations well outside the 80/10 degree thresholds below.
class GlobalPoseHoverHit {
  GlobalPoseHoverInfo info;
  int a, b;
  float displayAlpha;
}

final String[] compassDirectionNames = { "N", "NE", "E", "SE", "S", "SW", "W", "NW" };

// Beta (this app's own orientation convention - 0 is south, 90 is east,
// confirmed against SolarAtSurface()'s VECT formula and funcs.SunPosition
// ()'s own sunrise/sunset output) as the nearest of the 8 cardinal/
// intercardinal compass directions plus a signed offset, e.g. "NW - 5°"
// for a compass bearing of 310 degrees, rather than the raw angle.
String formatOrientation (float Beta) {
  float compassBearing = ((180 - Beta) % 360 + 360) % 360; // standard bearing: N=0, E=90, S=180, W=270

  int nearestIndex = round(compassBearing / 45.0) % 8;
  float offset = compassBearing - nearestIndex * 45;
  if (offset > 180) offset -= 360;   // wrap e.g. 359 degrees -> "N - 1°", not "N + 359°"
  if (offset < -180) offset += 360;

  String direction = compassDirectionNames[nearestIndex];
  if (abs(offset) < 0.05) return direction;

  String sign = (offset < 0) ? "-" : "+";
  return direction + " " + sign + " " + nf(round(abs(offset)), 1, 0) + "\u00B0";
}

// Snaps a wedge's raw inclination to a round, easy-to-read value when
// it's close enough to count as effectively horizontal or vertical -
// above 80 degrees reads as a clean 90 (horizontal), below 10 degrees
// reads as a clean 0 (vertical). Both are common surfaces to want a
// reading for, and both sit where the dome's own polar projection makes
// precise hovering hardest - horizontal wedges bunch up tightly around
// the dome's own center, so without this, hovering near the middle would
// otherwise land on whichever narrow sliver the mouse happens to be
// closest to rather than a single, simple answer.
float snapInclination (float Alpha) {
  if (Alpha > 80) return 90;
  if (Alpha < 10) return 0;
  return Alpha;
}

// The hover box's first line - orientation and inclination together for
// a general tilt, "Roof" alone (no orientation, which is meaningless once
// a surface is flat) once inclination has snapped to 90, and orientation
// alone (inclination dropped as implied/redundant) once it's snapped to
// 0, since reading a vertical surface's own compass direction is the
// common case worth keeping simple.
String formatOrientationAndInclination (float Beta, float Alpha) {
  if (Alpha >= 90) return "Roof";
  if (Alpha <= 0) return formatOrientation(Beta);
  return formatOrientation(Beta) + ", Inclination " + nf(round(Alpha), 1, 0) + "\u00B0";
}

// Returns the hover hit under the mouse, or null if it isn't over any of
// this pass's domes. Converts the mouse into polar coordinates around
// each candidate dome's own center (radius in degrees via
// pixelsPerDegree, angle via atan2 matching the exact same x=r*cos(Beta-
// 90), y=-r*sin(Beta-90) convention plotImpact_global() itself draws
// with - see that function's own vertex formulas), then snaps to the
// nearest (a,b) wedge - a direct computation rather than looping every
// wedge checking which one contains the point, since polar wedges aren't
// simple rects the way Skin Potential's thumbnails are.
GlobalPoseHoverHit studyGlobalPoseHover_hitTest (int xMouse, int yMouse) {
  if (STUDY.globalPoseHoverInfo == null) return null;

  float graphicsX = (xMouse - STUDY.cX) * STUDY.ImageScale;
  float graphicsY = (yMouse - STUDY.cY) * STUDY.ImageScale;

  for (GlobalPoseHoverInfo info : STUDY.globalPoseHoverInfo) {
    if (info.pixelsPerDegree <= 0) continue;

    float dx = graphicsX - info.centerX;
    float dy = graphicsY - info.centerY;
    float distPixels = sqrt(dx * dx + dy * dy);
    float radiusDegrees = distPixels / info.pixelsPerDegree;

    if (radiusDegrees > 90) continue; // outside this dome's own outer edge entirely

    float angleDeg = degrees(atan2(-dy, dx)); // inverse of x=r*cos(angle), y=-r*sin(angle)
    float Beta = angleDeg + 90;
    Beta = ((Beta % 360) + 360) % 360;
    float Alpha = snapInclination(90 - radiusDegrees);

    int aCount = info.snapshotRAD.length;
    int bCount = info.snapshotRAD[0].length;
    // Step sizes implied by the snapshot's own shape, rather than reading
    // Sky3D.inclinationStep/orientationStep live - self-contained, same
    // reasoning as reading a thumbnail's resolution off its own snapshot
    // shape in studyImpactHover.pde.
    float inclinationStepImplied = 90.0 / (aCount - 1);
    float orientationStepImplied = 360.0 / bCount;

    int a = constrain(round(Alpha / inclinationStepImplied), 0, aCount - 1);
    int b = round(Beta / orientationStepImplied) % bCount;

    GlobalPoseHoverHit hit = new GlobalPoseHoverHit();
    hit.info = info;
    hit.a = a;
    hit.b = b;
    // Rounded to the bucket actually selected (a), not the continuous
    // mouse-derived angle before bucketing - so the label always matches
    // the wedge whose data is being shown below it, not some in-between
    // value the mouse happened to be near. For the snapped cases (Alpha
    // 90 or 0) this is unchanged either way, since a's own bucket already
    // lands on exactly 90 or 0 by construction.
    hit.displayAlpha = a * inclinationStepImplied;
    return hit;
  }

  return null;
}

// Draws the hover box - same formatting/sizing/positioning/edge-drawing
// reuse as drawStudyUrbanHoverBox() (studyImpactHover.pde), just reading
// from globalPoseRawValuesAt() instead.
void drawGlobalPoseHoverBox (int xMouse, int yMouse, GlobalPoseHoverHit hit) {
  float[] raw = globalPoseRawValuesAt(hit.info, hit.a, hit.b);
  String[] valueLines = hoverLines(xMouse, yMouse, hit.info.impactTypeIndex, raw);
  if (valueLines == null) return;

  // Beta still comes from hit.b the same way as before (only inclination
  // gets snapped, never orientation); hit.displayAlpha is used directly
  // rather than re-derived from hit.a, since hit.a only identifies which
  // bucket matched, not whether snapInclination() actually moved it there.
  int bCount = hit.info.snapshotRAD[0].length;
  float Beta = hit.b * (360.0 / bCount);

  String[] lines = new String[valueLines.length + 1];
  lines[0] = formatOrientationAndInclination(Beta, hit.displayAlpha);
  System.arraycopy(valueLines, 0, lines, 1, valueLines.length);

  float destX = STUDY.cX, destY = STUDY.cY;
  float destW = STUDY.dX / STUDY.ImageScale, destH = STUDY.dY / STUDY.ImageScale;

  queueHover(xMouse, yMouse, lines, destX, destY, destW, destH, studyPlacedHoverBoxes, studyPendingHoverBoxes);
}
