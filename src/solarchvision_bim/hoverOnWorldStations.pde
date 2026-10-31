// --- WORLD stations hover tooltip ------------------------------------------
//
// Shows the short name of whichever station marker(s) are near the mouse
// over the WORLD map - a lightweight discovery tool ("which stations are
// around here?"), not a data readout like the other hover boxes in this
// file's neighbors (hoverOnSolarImpactOverlay.pde, hoverOnStudyImpact.pde,
// etc). Deliberately different from those in a few ways:
//
//  - Can be pinned by a left click (mouseClicked.pde's own WORLD click
//    handling, addHoverPoint(), hover.pde), same as STUDY's/WIN3D's own
//    hovers can be - but, uniquely among them, a WORLD-sourced pin tracks
//    the real-world spot it was pinned at rather than a fixed screen
//    position: worldHoverPointGeo and syncWorldHoverPointPositions() below
//    keep it (and any box already placed for it) riding along as WORLD
//    pans/zooms, dropping it outright once that spot pans/zooms outside
//    WORLD's own current view - see syncWorldHoverPointPositions()'s own
//    comment for the full reasoning. The live, mouse-following point has
//    no such tracking of its own to do - it's simply re-resolved fresh
//    against the current mouse position every frame regardless, the same
//    as it always has been.
//  - No per-pixel data to format - just a short list of names, so there's
//    no equivalent of hoverLines()/win3DOverlay_rawValuesAt() here.
//  - Several stations can legitimately be this close to the mouse at once
//    (collectNearbyWorldStationNames() below), unlike every other hover in
//    this app, which always resolves to at most one hit.
//
// Reuses queueHover()/hoverBoxPosition() (hover.pde) for the actual box -
// same look, same "stays inside the given dest rect" placement logic - and
// the same pre_screen capture/restore technique clearStudyHover()
// (hoverOnStudyImpact.pde) already uses, for the same reason: WORLD.draw()
// only repaints this panel while WORLD.update is true (solarchvision_bim.pde's
// own "if (WORLD.include && WORLD.update) WORLD.draw();"), so a hover box
// drawn directly on top of it would otherwise still be sitting there on
// every later frame until something else happens to repaint that same
// screen region.

PImage worldHover_pre_screen;
int worldHover_capturedGeneration = -1;
boolean worldHover_wasShownLastFrame = false;

// Maps a WORLD-sourced pinned point's own {x,y} row (hover.pde's own
// allHoverPoints - object identity, not value, the same keying convention
// hoverPointPreferredPosition (hover.pde) already uses for a pin's own
// remembered box position) to the (lon, lat) it was actually pinned at.
// A row with no entry here is a plain STUDY/WIN3D-style pin, fixed in
// screen space for good, same as before this existed; a row WITH one is
// instead kept in sync with it, every frame, by
// syncWorldHoverPointPositions() below - so a WORLD pin tracks a place ON
// THE MAP, not a spot on screen, surviving a pan or a zoom the way a
// label on the map itself would, rather than drifting away from whatever
// station(s) it was actually pinned to point out. Populated by
// mouseClicked.pde's own WORLD left-click handling, right after the
// addHoverPoint() call that creates the row; read (and pruned, for a pin
// that's since been dropped) only here.
java.util.IdentityHashMap<int[], float[]> worldHoverPointGeo = new java.util.IdentityHashMap<int[], float[]>();

// Keeps every WORLD-sourced pin (worldHoverPointGeo above) tracking the
// same real-world spot as WORLD itself pans and zooms, instead of staying
// nailed to wherever it first landed on screen - called once per pass, by
// drawAllHovers() (hover.pde), before anything in that pass gets
// resolved, so both pass 1's own pin-position resolution and its
// collision-avoidance "peek" (peekAllPinnedHoverBoxes(), hover.pde) see
// this pass's already-up-to-date positions, not last frame's.
//
// For each WORLD-tracked row: re-derives its own screen position fresh
// from WORLD's CURRENT projX()/projY() (which already reflect this
// frame's own pan/zoom - WORLD.draw() runs before drawAllHovers() in the
// same frame, see solarchvision_bim.pde's own draw()) - if its geography
// has since panned/zoomed outside WORLD's own current view (isWithinView()/
// isInside(), the exact same bounds check a station marker itself would
// have to pass to even be drawn - see addNearbyWorldStationCandidates()'s
// own comment on why), the pin no longer points at anything actually on
// screen, so it's dropped (removeHoverPointAt(), hover.pde) rather than
// left dangling off the edge of the map. Otherwise, if the recomputed
// position has moved since last frame, the row's own x/y (mutated in
// place - int[] elements are mutable, so this doesn't disturb either
// identity map's own keying) is updated to the new position, AND, if this
// pin already has its own remembered box position
// (hoverPointPreferredPosition, hover.pde), that's shifted by the exact
// same delta - so an already-placed box rides along WITH its anchor
// (staying, say, "down-right of the pin") rather than either staying
// nailed to the old absolute screen position (visibly detaching it from
// its own anchor) or snapping back to a freshly-computed natural quadrant
// every single frame while actively panning (which would look jumpy).
void syncWorldHoverPointPositions () {
  if (allHoverPoints == null) return;
  if (worldHoverPointGeo.isEmpty()) return;

  // Iterate backwards: removeHoverPointAt() can shrink allHoverPoints out
  // from under a forward loop, but a backwards one is unaffected by any
  // shrinking that's already happened at higher indices.
  for (int i = allHoverPoints.length - 1; i >= 0; i--) {
    int[] row = allHoverPoints[i];
    float[] geo = worldHoverPointGeo.get(row);
    if (geo == null) continue; // not a WORLD-tracked pin - leave it alone entirely

    float lon = geo[0];
    float lat = geo[1];

    if (!WORLD.isWithinView(lon, lat)) {
      removeHoverPointAt(i);
      continue;
    }

    float localX = WORLD.projX(lon);
    float localY = WORLD.projY(lat);

    if (!isInside(localX, localY, 0, 0, WORLD.dX, WORLD.dY)) {
      removeHoverPointAt(i);
      continue;
    }

    int newX = round(WORLD.cX + localX);
    int newY = round(WORLD.cY + localY);

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

// How close (in screen pixels) a station marker has to be to the mouse to
// show up in the hover - NOT keyed to WORLD.zoom directly. What actually
// makes this "depend on zoom level" (as asked for) is that every
// candidate's on-screen position is computed fresh, each call, through
// WORLD's own current projX()/projY() - which already bake in whatever
// window the current zoom/pan is showing - before being compared against
// this same fixed pixel radius. The same screen-pixel distance therefore
// covers far fewer degrees of longitude/latitude zoomed in than zoomed
// out, so the EFFECTIVE geographic search radius shrinks and grows with
// zoom on its own, with no separate per-zoom-level table to keep in sync
// here.
final float worldStationHoverRadius = 10;

// How many station names the hover box will ever list at once, closest
// first - without this, zooming out over a dataset that has hundreds of
// stations (CWEEDS/NAEFS easily do) puts hundreds of candidates within
// worldStationHoverRadius screen pixels of the mouse at once (the same
// fixed pixel radius that makes the SEARCH itself "depend on zoom level" -
// see worldStationHoverRadius's own comment - means the geographic area it
// covers, and so how many real stations fall inside it, grows right along
// with it as the view zooms out), and the resulting box would keep
// growing taller with every one of them rather than staying a quick,
// readable "what's around here" list. collectNearbyWorldStationNames()
// below truncates to this many (keeping the closest ones - a farther
// station is exactly the one a user zoomed out this far cares least about
// seeing by name) and notes how many more there were, rather than quietly
// dropping them with no indication there's more straining to be shown.
final int worldStationHoverMaxNames = 8;

// Same role (and same reasoning) as clearStudyHover() (hoverOnStudyImpact.pde)
// has for STUDY's own panel - see this file's own header comment above for
// why WORLD needs the same treatment. Called once per pass, by
// drawAllHovers() (hover.pde), before any of this pass's hover points are
// resolved.
void clearWorldHover () {
  if (isBakingInProgress()) return;

  if (!WORLD.include) return;

  if (WORLD.renderGeneration != worldHover_capturedGeneration) {
    worldHover_pre_screen = get(WORLD.cX, WORLD.cY, int(WORLD.dX / WORLD.ImageScale), int(WORLD.dY / WORLD.ImageScale));
    worldHover_capturedGeneration = WORLD.renderGeneration;
    worldHover_wasShownLastFrame = false; // the fresh redraw already has no hover box on it - nothing to erase
    return; // the capture above IS this pass's clean state; nothing further to restore
  }

  if (!worldHover_wasShownLastFrame) return; // nothing drawn last pass - nothing to erase
  if (worldHover_pre_screen == null) return; // nothing captured yet (WORLD hasn't drawn a single frame)

  image(worldHover_pre_screen, WORLD.cX, WORLD.cY);
  worldHover_wasShownLastFrame = false;
}

// Called once per hover point in the current pass (see placeHoversAt(),
// hover.pde) - same shape as place_STUDY_hover()/place_WIN3D_hover(), for
// the same reason: this has to run whether or not WORLD itself redrew this
// particular frame. Clearing any box left over from the previous pass is
// clearWorldHover()'s job, not this function's.
void place_WORLD_hover (int xMouse, int yMouse) {
  if (isBakingInProgress()) return;

  if (!WORLD.include) return;

  // A station picker's own list (mouseClicked.pde's StationPicker.draw(),
  // called from WORLD.draw() via drawPickLists()) paints an opaque panel
  // directly over WORLD - but drawAllHovers() (hover.pde) runs AFTER
  // WORLD.draw() each frame, so without this guard a hover box (the live,
  // mouse-following one, or any already-pinned point's) would still get
  // queued and painted right on top of that list, on top of whatever row
  // the user is trying to read/click. Skipping this entirely while any
  // list is showing hides both - live preview and pinned points alike -
  // for as long as the list stays open; clearWorldHover() (this file)
  // then erases whatever hover box was left over from the frame before
  // the list opened, the same way it already does whenever this function
  // simply has nothing to show.
  if (isAnyPickListActive()) return;

  if (worldHover_pre_screen == null) return; // nothing captured yet (WORLD hasn't drawn a single frame)

  // A pan/drag in progress means the map underneath is actively sliding
  // out from under the cursor every frame - a hover box anchored to a
  // station position that's constantly shifting would be more distracting
  // than useful here, so this simply doesn't offer one while dragging_
  // started is set. Shared with every other drag gesture in the app
  // (globals.pde), not a WORLD-specific flag - but the only one of those
  // that can ever BE set while the mouse sits inside WORLD's own rect is
  // handleWorldDrag() itself (mouseDragged.pde), which only sets it after
  // confirming the mouse was and still is inside that same rect, so there
  // is no other drag this could be mistaking for WORLD's own.
  if (dragging_started != 0) return;

  float destX = WORLD.cX, destY = WORLD.cY;
  float destW = WORLD.dX / WORLD.ImageScale, destH = WORLD.dY / WORLD.ImageScale;

  if (!isInside(xMouse, yMouse, destX, destY, destX + destW, destY + destH)) return;

  // projX()/projY() place markers in WORLD's own local graphics space -
  // (0,0) at this panel's own top-left corner, not the screen's - so the
  // mouse position needs that same cX/cY offset removed before the two are
  // compared. Unlike STUDY's own hit-tests (e.g. studyUrbanHover_hitTest(),
  // hoverOnStudyImpact.pde), there's no further ImageScale correction
  // needed here: those re-use POSITIONS CACHED mid-draw, while this panel's
  // graphics was still at its scaled-up resolution, so converting the
  // mouse into that same scaled space takes an explicit multiply. Here,
  // projX()/projY() are instead called fresh, right now, against WORLD's
  // CURRENT dX/dY/sX/sY/oX/oY - which by this point (outside WORLD.draw()'s
  // own update block) are already back at their final, unscaled, on-screen
  // values (see WORLD.draw()'s own "this.dX /= this.ImageScale;" at the
  // end of that block) - so both sides of the comparison are already in
  // the same, plain on-screen pixel space with nothing further to correct.
  String[] names = collectNearbyWorldStationNames(xMouse - destX, yMouse - destY);
  if (names == null || names.length == 0) return;

  queueHover(xMouse, yMouse, names, destX, destY, destW, destH, worldPlacedHoverBoxes, worldPendingHoverBoxes);
  worldHover_wasShownLastFrame = true;
}

// Returns the short display name of every currently-visible station marker
// within worldStationHoverRadius screen pixels of (localMouseX, localMouseY)
// - both already in WORLD's own local graphics space, the same space
// projX()/projY() place markers in (see place_WORLD_hover()'s own comment
// on that) - closest first, each short name included only once even when
// several datasets/stations happen to share it. Returns null (not an empty
// array) when nothing is close enough, so callers can treat that as "don't
// draw a box" with a single null check.
//
// "Currently visible" follows the exact same isWithinView()/isInside()
// checks WORLD.pde's own drawStationDataset() (and the SWOB-specific inline
// loop right above it in WORLD.draw(), which predates drawStationDataset())
// already use to decide what to actually draw, and only looks at a dataset
// at all while that dataset's own "show all" markers are switched on
// (displayAllLevel != 0, checked in addNearbyWorldStationCandidates()
// below) - this is meant to help the user make sense of markers already on
// screen, not surface a station they have no marker for to point at.
String[] collectNearbyWorldStationNames (float localMouseX, float localMouseY) {
  ArrayList<String> names = new ArrayList<String>();
  ArrayList<Float> distsSq = new ArrayList<Float>();

  // true/false here is exactly drawStationDataset()'s own useCode flag for
  // this same dataset (WORLD.draw()) - getCode() for Ensemble Observation
  // (SWOB; handled by WORLD.draw()'s own inline loop rather than a
  // drawStationDataset() call, but it uses getCode() for its own labels
  // the same way), getCity() for the other four - so a station's hover
  // name is never something different from what its own on-map label
  // (when "show all" labels are switched on) would already say.
  addNearbyWorldStationCandidates(ensembleObservationCoordinates, WORLD.ensembleObservationDisplayAll, true, localMouseX, localMouseY, names, distsSq);
  addNearbyWorldStationCandidates(ensembleForecastCoordinates, WORLD.ensembleForecastDisplayAll, false, localMouseX, localMouseY, names, distsSq);
  addNearbyWorldStationCandidates(climateEngineeringCoordinates, WORLD.climateEngineeringDisplayAll, false, localMouseX, localMouseY, names, distsSq);
  addNearbyWorldStationCandidates(climateArchiveCoordinates, WORLD.climateArchiveDisplayAll, false, localMouseX, localMouseY, names, distsSq);
  addNearbyWorldStationCandidates(climateTypicalYearCoordinates, WORLD.climateTypicalYearDisplayAll, false, localMouseX, localMouseY, names, distsSq);

  if (names.isEmpty()) return null;

  // Insertion sort by ascending distance - same small-candidate-count
  // approach findNearbyStations() (mouseClicked.pde) already uses for its
  // own nearby-station search; candidate counts this close to the mouse
  // are always tiny, so there's no need for anything fancier.
  for (int i = 1; i < names.size(); i++) {
    String name = names.get(i);
    float d = distsSq.get(i);
    int j = i - 1;
    while ((j >= 0) && (distsSq.get(j) > d)) {
      names.set(j + 1, names.get(j));
      distsSq.set(j + 1, distsSq.get(j));
      j--;
    }
    names.set(j + 1, name);
    distsSq.set(j + 1, d);
  }

  // Drop duplicate names, closest occurrence wins. A plain linear scan
  // rather than a Set: there are only ever a handful of candidates this
  // close to the mouse at once, so there's nothing to gain from a hash-
  // based structure here, and this keeps the closest-first order from the
  // sort above exactly as-is.
  ArrayList<String> deduped = new ArrayList<String>();
  for (String name : names) {
    boolean alreadyIncluded = false;
    for (String existing : deduped) {
      if (existing.equals(name)) { alreadyIncluded = true; break; }
    }
    if (!alreadyIncluded) deduped.add(name);
  }

  // Cap the list, keeping the closest worldStationHoverMaxNames - see that
  // constant's own comment for why this exists. Trimmed from the END
  // rather than the start: deduped is still in the ascending-distance
  // order the sort above produced, so everything past index
  // worldStationHoverMaxNames-1 is, by construction, farther away than
  // everything kept.
  if (deduped.size() > worldStationHoverMaxNames) {
    int hiddenCount = deduped.size() - worldStationHoverMaxNames;
    while (deduped.size() > worldStationHoverMaxNames) {
      deduped.remove(deduped.size() - 1);
    }
    deduped.add("+" + hiddenCount + " more nearby");
  }

  return deduped.toArray(new String[0]);
}

// Scans one dataset's own coordinates array for stations within
// worldStationHoverRadius screen pixels of (localMouseX, localMouseY),
// appending each hit's short display name (and its squared screen-pixel
// distance, for collectNearbyWorldStationNames()'s own closest-first sort
// afterward) onto `names`/`distsSq`. Squared distance throughout - no need
// to actually sqrt() anything, either for the radius test below or for the
// sort this feeds, since both only ever compare distances against each
// other or against one fixed threshold.
void addNearbyWorldStationCandidates (STATION[] coords, int displayAllLevel, boolean useCode, float localMouseX, float localMouseY, ArrayList<String> names, ArrayList<Float> distsSq) {
  if (displayAllLevel == 0) return; // this dataset's own markers aren't even being drawn right now
  if (coords == null) return;

  float radiusSq = worldStationHoverRadius * worldStationHoverRadius;

  for (int f = 0; f < coords.length; f++) {

    float _lat = coords[f].getLatitude();
    float _lon = coords[f].getLongitude();
    if (_lon > 180) _lon -= 360; // << important! - same wraparound every other WORLD station loop applies

    // Cheap lon/lat bounds check before paying for the projection math and
    // the pixel-space distance test below - same ordering drawStationDataset()
    // itself already uses.
    if (!WORLD.isWithinView(_lon, _lat)) continue;

    float x_point = WORLD.projX(_lon);
    float y_point = WORLD.projY(_lat);

    if (!isInside(x_point, y_point, 0, 0, WORLD.dX, WORLD.dY)) continue;

    float dx = x_point - localMouseX;
    float dy = y_point - localMouseY;
    float distSq = dx * dx + dy * dy;
    if (distSq > radiusSq) continue;

    names.add(useCode ? coords[f].getCode() : coords[f].getCity());
    distsSq.add(distSq);
  }
}
