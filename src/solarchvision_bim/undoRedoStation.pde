// Undo/Redo pipeline for STATION - same two-piece shape as
// undoRedoScene3D.pde/undoRedoViewport3D.pde (a chronological list,
// stationHistory[0..n], plus a stationHistoryIndex marking which entry
// is the current live state), tracking STATION alone via
// STATION.to_XML()/STATION.from_XML() - nothing else, and independent
// of both of those other histories: undoing a model or viewport change
// never moves the station, and undoing a station change never touches
// the model or the viewport.
//
// WHY THIS FILE FOLLOWS undoRedoViewport3D.pde'S PATTERN, NOT
// undoRedoScene3D.pde'S: STATION has no beginScene3DChange()/
// endScene3DChange()-style pre-edit boundary of its own - it's mutated
// directly, inline, from a dozen-plus scattered call sites
// (mouseClicked.pde's several map-click handlers, each setting half a
// dozen STATION fields at once; extraCommands.pde's SETLAT/SETLON/
// SETLATLON/SETLONLAT commands; valueModifier.pde's "Location Latitude"/
// "Location Longitude" command-line path; react.pde's own
// applyLocationChange, which is what the GUI spinner drag actually
// funnels through once UI_rollout.draw() has already applied its
// returned value - see that OnChange's own comment). That last path in
// particular behaves exactly like Viewport3D's own camera spinners: a
// held drag re-fires applyLocationChange, and so re-mutates STATION,
// on almost every frame, not just once at the end of the gesture.
// Wrapping every one of these call sites in its own begin/end pair
// would be a far larger, more invasive change than recording STATION's
// own state actually calls for.
//
// So instead this file polls: trackStationChange() (below), called
// once per frame from draw() (solarchvision_bim.pde, right alongside
// trackViewport3DChange()), diffs STATION's current to_XML() output
// against the live history entry and, if it differs, either folds the
// change into that same entry (when the previous frame also changed
// it - i.e. this is still the same continuous spinner-drag gesture) or
// starts a fresh entry (when the change follows at least one quiet
// frame - a new gesture, or a one-shot change like a map click or a
// command-line SETLAT). This is the same frame-based coalescing
// trackViewport3DChange() uses, and for the identical reason: STATION,
// like Viewport3D, has no begin/end hook of its own to use as a
// pre-edit boundary instead.
//
// restoreProjectStationSnapshot() below calls UI_rollout.revise() (so
// the Location panel's own text fields redraw) and update_station(-1)
// after restoring - the full reload, same call the "Update Station"
// menu action (actions.pde) makes, not the cheap Step 0 every LIVE
// STATION-moving path uses on itself instead (react.pde's
// applyLocationChange, valueModifier.pde's Location Latitude/Longitude
// setters, mouseClicked.pde's map-click handlers, extraCommands.pde's
// SETLAT/SETLON/...) - those fire on nearly every frame of a held drag,
// so they deliberately skip the expensive parts (re-reading climate-
// dataset files, Terrain.update_mesh()'s own disk reads - see that
// function's own comment). An undo/redo is the opposite: a single,
// deliberate, infrequent action, so it can afford - and needs - the
// full reload: otherwise the restored STATION's own climate-typical-
// year/climate-engineering/climate-archive/ensemble-observation/
// ensemble-forecast datasets and the terrain mesh would keep reflecting
// whichever station was active before the undo/redo, not the one it
// just restored. Nothing beyond that is needed - an undo/redo here
// never changes which datasets are loaded, just where STATION is
// pointing.

final int MAX_UNDO_STATION = 50; // a station snapshot is one small XML element (STATION's own scalar fields), not a scene graph, so this can comfortably hold more steps than MAX_UNDO_MODEL3D

ArrayList<XML> stationHistory = new ArrayList<XML>();
int stationHistoryIndex = -1; // -1 until seedStationHistory() runs once at startup

// Guards trackStationChange() against recording a restore as a new step
// of its own - same shape and same reason as
// isRestoringViewport3DSnapshot (undoRedoViewport3D.pde): without it,
// restoreProjectStationSnapshot()'s own STATION.from_XML() write would
// otherwise look, to the very next frame's trackStationChange(), exactly
// like a brand new gesture.
boolean isRestoringStationSnapshot = false;

// The frameCount at which the live history entry
// (stationHistory[stationHistoryIndex]) was last written to - used by
// trackStationChange() below to tell "still the same gesture" (this
// frame's change immediately follows last frame's change) apart from "a
// new gesture" (at least one quiet frame in between). See that
// function's own comment.
int stationHistoryLastChangeFrame = -1;

// STATION's own undo/redo snapshot - just the one class, same single-
// class scope as buildViewport3DSnapshot() (undoRedoViewport3D.pde),
// for the same reason: undo/redo here is deliberately scoped to STATION
// alone.
XML buildStationSnapshot () {

  XML xml = parseXML("<?xml version='1.0' encoding='UTF-8'?>" + char(13) + "<empty>" + char(13) + "</empty>");

  xml.setName("solarchvisionV" + version);

  STATION.to_XML(xml);

  return xml;
}

// The one baseline entry that isn't "state after a change" - same role
// seedScene3DHistory()/seedViewport3DHistory() play for their own
// histories. Called once from drawInitialFrames.pde right before the
// app starts accepting input, and again whenever Open/Fetch replace
// STATION's own state wholesale (loadProject.pde's load_project(), via
// parse_XML_variables()'s own STATION.from_XML() call) - a different
// project means a different station, so the station history needs to
// start fresh from exactly that state too, same reasoning as
// seedScene3DHistory()'s/seedViewport3DHistory()'s own callers.
//
// Deliberately NOT called from globalFunctions.pde's deleteAll() ("New"):
// unlike the model and the viewport, "New" leaves STATION untouched on
// purpose (location/climate-station data isn't part of the 3D model
// deleteAll() clears) - so there's nothing for a reseed to do there, and
// reseeding anyway would silently throw away whatever station undo
// history was already in progress for no reason tied to what "New"
// actually does.
void seedStationHistory () {
  if (stationHistory == null) stationHistory = new ArrayList<XML>(); // see beginUndoableScene3DEdit()'s own comment (undoRedoScene3D.pde) on the same null-before-init race - STATION's own field initializers run in the same tab-concatenation order, so the window this guards against is the same one
  stationHistory.clear();
  stationHistory.add(buildStationSnapshot());
  stationHistoryIndex = 0;
  stationHistoryLastChangeFrame = -1;
}

// Called once per frame from draw() (solarchvision_bim.pde), only after
// draw_initial_frames() has finished (so STATION and stationHistory both
// already exist) - see this file's header comment for why polling,
// rather than a begin/end hook, is what STATION's undo/redo needs.
void trackStationChange () {
  if (isRestoringStationSnapshot) return;
  if ((stationHistory == null) || (stationHistoryIndex < 0)) return;

  XML current = buildStationSnapshot();

  // Nothing to record: STATION looks exactly like the live entry
  // already does - either nothing moved this frame, or this is the very
  // next frame after an undo/redo restored it to exactly this state.
  if (current.toString().equals(stationHistory.get(stationHistoryIndex).toString())) return;

  if (stationHistoryLastChangeFrame == frameCount - 1) {
    // Still the same continuous gesture as last frame (a held
    // latitude/longitude spinner drag) - keep refining the entry
    // already in progress rather than recording every in-between frame
    // as its own step. A one-shot change (a map click, a command-line
    // SETLAT) never reaches this branch in the first place - the very
    // next frame is quiet, so its own single entry is never coalesced
    // into anything else.
    stationHistory.set(stationHistoryIndex, current);
  } else {
    // A fresh gesture, separated from whatever last changed STATION by
    // at least one quiet frame. Discard any redo branch beyond the
    // current position first - the same "a fresh edit clears the
    // uncovered future" rule commitUndoableScene3DEdit() follows - then
    // record the new step.
    while (stationHistory.size() > stationHistoryIndex + 1) {
      stationHistory.remove(stationHistory.size() - 1);
    }

    stationHistory.add(current);
    stationHistoryIndex = stationHistory.size() - 1;

    while (stationHistory.size() > MAX_UNDO_STATION) {
      stationHistory.remove(0);
      stationHistoryIndex -= 1;
    }
  }

  stationHistoryLastChangeFrame = frameCount;
}

void undoStationChange () {
  if (stationHistoryIndex <= 0) {
    displayDirective("Undo: no station change to undo.");
    return;
  }

  stationHistoryIndex -= 1;
  restoreProjectStationSnapshot(stationHistory.get(stationHistoryIndex));
}

void redoStationChange () {
  if (stationHistoryIndex >= stationHistory.size() - 1) {
    displayDirective("Redo: no station change to redo.");
    return;
  }

  stationHistoryIndex += 1;
  restoreProjectStationSnapshot(stationHistory.get(stationHistoryIndex));
}

// The from_XML() counterpart to buildStationSnapshot() above - just
// STATION.from_XML(), same single-class scope.
void restoreStationSnapshot (XML xml) {
  STATION.from_XML(xml);
}

// Safe to call from undo()/redo() only because of
// isRestoringStationSnapshot below - see its own comment:
// trackStationChange() would otherwise see this function's own
// STATION.from_XML() write, on the very next frame, as a brand new
// gesture and immediately record it as one more step, turning every
// undo into a redo-able "change" of its own. try/finally so the flag
// can't get stuck true and silently disable all future station
// undo/redo recording if something throws partway through a restore.
void restoreProjectStationSnapshot (XML xml) {
  isRestoringStationSnapshot = true;
  try {
    restoreStationSnapshot(xml);

    // Same call every live STATION-moving call site already fires on
    // itself (mouseClicked.pde's map-click handlers call both, in this
    // order, right after setting STATION's fields - see e.g.
    // selectClimateTypicalYearStation()'s own body): UI_rollout.revise()
    // is what the "Location & Data" panel's own code/city/province/
    // country/elevation/... text fields need to actually redraw with
    // the restored values - applyRolloutUpdate.pde (where those fields
    // are read straight off STATION, via valueModifier.pde's own
    // getters) bails out immediately unless UI_rollout.update is set.
    // Without this, an undo/redo still correctly restores STATION
    // itself, but LOOKS like it only moved the map pin (that panel is
    // driven separately, by update_station(-1)'s own WORLD.revise()/
    // view_changed() below) while the visible location fields stay
    // stuck showing whatever was there right before the undo/redo.
    UI_rollout.revise();

    // Step -1, not 0: every LIVE STATION-moving path (a held spinner
    // drag, a map click fired on nearly every frame it's held) uses the
    // cheap Step 0 on purpose - see update_station()'s own comment and
    // react.pde's applyLocationChange, which explains paying for a full
    // Terrain.update_mesh()/climate-dataset reload on every one of
    // those would be far too expensive. An undo/redo is the opposite:
    // a single, deliberate, infrequent action - the same shape as the
    // "Update Station" menu action (actions.pde), which already calls
    // update_station(-1) for exactly that reason. Step 0 alone left the
    // restored STATION's own climate-typical-year/climate-engineering/
    // climate-archive/ensemble-observation/ensemble-forecast datasets
    // and the terrain mesh still reflecting whatever station was active
    // before the undo/redo, not the one just restored.
    update_station(-1);
  } finally {
    isRestoringStationSnapshot = false;
  }
}
