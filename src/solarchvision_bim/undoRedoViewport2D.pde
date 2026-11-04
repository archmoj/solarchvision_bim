// Undo/Redo pipeline for Viewport2D - same two-piece shape as
// undoRedoViewport3D.pde/undoRedoStation.pde (a chronological list,
// viewport2DHistory[0..n], plus a viewport2DHistoryIndex marking which
// entry is the current live state), tracking STUDY alone via
// STUDY.to_XML()/STUDY.from_XML() - nothing else, and independent of
// the other three histories: undoing a model, 3D-viewport or station
// change never moves STUDY, and undoing a Viewport2D change never
// touches the model, WIN3D or STATION.
//
// WHY THIS FILE FOLLOWS undoRedoViewport3D.pde'S/undoRedoStation.pde'S
// PATTERN, NOT undoRedoScene3D.pde'S: STUDY has no beginScene3DChange()/
// endScene3DChange()-style pre-edit boundary of its own - it's mutated
// directly, inline, from a dozen-plus scattered call sites
// (valueModifier.pde's own spinner functions for End Day/Day Increment/
// Days Merged/Start Hour/End Hour/Sky Scenario/Temporal Filter/Plot
// Layout/Vertical Unit Scale/the Show Raw Lines-Statistical Ranges-
// Normal Lines-Probabilities toggles/..., mouseWheel.pde's own case-bar
// wheel handling, mouseClicked.pde's "toggle impact type"/plot-tab
// clicks, extraCommands.pde's command-line equivalents). The GUI
// spinner path in particular behaves exactly like Viewport3D's own
// camera spinners and STATION's own latitude/longitude spinner: a held
// drag writes a new value straight into STUDY on nearly every frame
// (uiRollout.pde's own `STUDY.endDay = vm.endDay(1);` and its many
// siblings), not just once at the end of the gesture. Wrapping every
// one of these call sites in its own begin/end pair would be a far
// larger, more invasive change than recording STUDY's own state
// actually calls for.
//
// So instead this file polls: trackViewport2DChange() (below), called
// once per frame from draw() (solarchvision_bim.pde, right alongside
// trackViewport3DChange()/trackStationChange()), diffs STUDY's current
// to_XML() output against the live history entry and, if it differs,
// either folds the change into that same entry (when the previous
// frame also changed it - i.e. this is still the same continuous
// spinner-drag gesture) or starts a fresh entry (when the change
// follows at least one quiet frame - a new gesture, or a one-shot
// change like a case-bar wheel notch or a command-line End Day). This
// is the same frame-based coalescing trackViewport3DChange()/
// trackStationChange() use, and for the identical reason: STUDY has no
// begin/end hook of its own to use as a pre-edit boundary instead.
//
// restoreProjectViewport2DSnapshot() below doesn't try to diff which
// particular STUDY fields changed and fire only their own matching
// follow-up (applyRolloutUpdate.pde's own per-field OnChange callbacks,
// react.pde's applyCaseBarAndBake/impactsUpdateFlag/...) - a restore
// has no meaningful "old value" to diff against the way a live spinner
// edit does, just "whatever was live a moment ago" vs. "the restored
// snapshot". So it takes the same broad, unconditional approach
// restoreProjectStationSnapshot() does for STATION: revise every view
// any STUDY-bound spinner's own update1/update2/update3 flags ever
// target (reviseByUpdateFlags(), actions.pde), then force the one
// extra follow-up the day/hour-range fields specifically need
// (react.applyCaseBarAndBake - resizing allSections' own solar-impact
// array to the restored day range, flagging bakings for regeneration,
// syncing the shade-date angle), and force STUDY.updateImpactGraph so
// the Impact graph itself recomputes from the restored plot layout/
// impact type/layer/graph selection too - the same flag
// react.impactsUpdateFlag sets on a live plotLayoutIndex change.

final int MAX_UNDO_VIEWPORT2D = 50; // a Viewport2D snapshot is one small XML element (STUDY's own fields), not a scene graph, so this can comfortably hold more steps than MAX_UNDO_MODEL3D

ArrayList<XML> viewport2DHistory = new ArrayList<XML>();
int viewport2DHistoryIndex = -1; // -1 until seedViewport2DHistory() runs once at startup

// Guards trackViewport2DChange() against recording a restore as a new
// step of its own - same shape and same reason as
// isRestoringViewport3DSnapshot/isRestoringStationSnapshot: without it,
// restoreProjectViewport2DSnapshot()'s own STUDY.from_XML() write would
// otherwise look, to the very next frame's trackViewport2DChange(),
// exactly like a brand new gesture.
boolean isRestoringViewport2DSnapshot = false;

// The frameCount at which the live history entry
// (viewport2DHistory[viewport2DHistoryIndex]) was last written to -
// used by trackViewport2DChange() below to tell "still the same
// gesture" (this frame's change immediately follows last frame's
// change) apart from "a new gesture" (at least one quiet frame in
// between). See that function's own comment.
int viewport2DHistoryLastChangeFrame = -1;

// STUDY's own undo/redo snapshot - just the one class, same single-
// class scope as buildViewport3DSnapshot()/buildStationSnapshot(), for
// the same reason: undo/redo here is deliberately scoped to STUDY
// alone.
XML buildViewport2DSnapshot () {

  XML xml = parseXML("<?xml version='1.0' encoding='UTF-8'?>" + char(13) + "<empty>" + char(13) + "</empty>");

  xml.setName("solarchvisionV" + version);

  STUDY.to_XML(xml);

  return xml;
}

// The one baseline entry that isn't "state after a change" - same role
// seedScene3DHistory()/seedViewport3DHistory()/seedStationHistory() play
// for their own histories. Called once from drawInitialFrames.pde right
// before the app starts accepting input, and again whenever Open/Fetch
// replace STUDY's own state wholesale (loadProject.pde's load_project(),
// via parse_XML_variables()'s own STUDY.from_XML() call) - a different
// project means different case/study settings, so the Viewport2D
// history needs to start fresh from exactly that state too, same
// reasoning as the other three histories' own callers.
//
// Deliberately NOT called from globalFunctions.pde's deleteAll() ("New"):
// unlike the model, "New" leaves STUDY untouched on purpose (case/study
// display settings aren't part of the 3D model deleteAll() clears) -
// same reasoning seedStationHistory()'s own comment gives for STATION.
void seedViewport2DHistory () {
  if (viewport2DHistory == null) viewport2DHistory = new ArrayList<XML>(); // see beginUndoableScene3DEdit()'s own comment (undoRedoScene3D.pde) on the same null-before-init race - STUDY's own field initializers run in the same tab-concatenation order, so the window this guards against is the same one
  viewport2DHistory.clear();
  viewport2DHistory.add(buildViewport2DSnapshot());
  viewport2DHistoryIndex = 0;
  viewport2DHistoryLastChangeFrame = -1;
}

// Called once per frame from draw() (solarchvision_bim.pde), only after
// draw_initial_frames() has finished (so STUDY and viewport2DHistory
// both already exist) - see this file's header comment for why
// polling, rather than a begin/end hook, is what Viewport2D's undo/redo
// needs.
void trackViewport2DChange () {
  if (isRestoringViewport2DSnapshot) return;
  if ((viewport2DHistory == null) || (viewport2DHistoryIndex < 0)) return;

  XML current = buildViewport2DSnapshot();

  // Nothing to record: STUDY looks exactly like the live entry already
  // does - either nothing moved this frame, or this is the very next
  // frame after an undo/redo restored it to exactly this state.
  if (current.toString().equals(viewport2DHistory.get(viewport2DHistoryIndex).toString())) return;

  if (viewport2DHistoryLastChangeFrame == frameCount - 1) {
    // Still the same continuous gesture as last frame (a held spinner
    // drag) - keep refining the entry already in progress rather than
    // recording every in-between frame as its own step. A one-shot
    // change (a case-bar wheel notch, a command-line End Day) never
    // reaches this branch in the first place - the very next frame is
    // quiet, so its own single entry is never coalesced into anything
    // else.
    viewport2DHistory.set(viewport2DHistoryIndex, current);
  } else {
    // A fresh gesture, separated from whatever last changed STUDY by
    // at least one quiet frame. Discard any redo branch beyond the
    // current position first - the same "a fresh edit clears the
    // uncovered future" rule commitUndoableScene3DEdit() follows - then
    // record the new step.
    while (viewport2DHistory.size() > viewport2DHistoryIndex + 1) {
      viewport2DHistory.remove(viewport2DHistory.size() - 1);
    }

    viewport2DHistory.add(current);
    viewport2DHistoryIndex = viewport2DHistory.size() - 1;

    while (viewport2DHistory.size() > MAX_UNDO_VIEWPORT2D) {
      viewport2DHistory.remove(0);
      viewport2DHistoryIndex -= 1;
    }
  }

  viewport2DHistoryLastChangeFrame = frameCount;
}

void undoViewport2DChange () {
  if (viewport2DHistoryIndex <= 0) {
    displayDirective("Undo: no viewport2D change to undo.");
    return;
  }

  viewport2DHistoryIndex -= 1;
  restoreProjectViewport2DSnapshot(viewport2DHistory.get(viewport2DHistoryIndex));
}

void redoViewport2DChange () {
  if (viewport2DHistoryIndex >= viewport2DHistory.size() - 1) {
    displayDirective("Redo: no viewport2D change to redo.");
    return;
  }

  viewport2DHistoryIndex += 1;
  restoreProjectViewport2DSnapshot(viewport2DHistory.get(viewport2DHistoryIndex));
}

// The from_XML() counterpart to buildViewport2DSnapshot() above - just
// STUDY.from_XML(), same single-class scope.
void restoreViewport2DSnapshot (XML xml) {
  STUDY.from_XML(xml);
}

// Safe to call from undo()/redo() only because of
// isRestoringViewport2DSnapshot below - see its own comment:
// trackViewport2DChange() would otherwise see this function's own
// STUDY.from_XML() write, on the very next frame, as a brand new
// gesture and immediately record it as one more step, turning every
// undo into a redo-able "change" of its own. try/finally so the flag
// can't get stuck true and silently disable all future Viewport2D
// undo/redo recording if something throws partway through a restore.
void restoreProjectViewport2DSnapshot (XML xml) {
  isRestoringViewport2DSnapshot = true;
  try {
    restoreViewport2DSnapshot(xml);

    // No meaningful "old value" to diff per field here, unlike a live
    // spinner edit - just whatever was live a moment ago vs. the
    // restored snapshot - so this takes the same broad, unconditional
    // approach restoreProjectStationSnapshot() does for STATION rather
    // than trying to replay applyRolloutUpdate.pde's own per-field
    // diffs: revise every view any STUDY-bound spinner's own
    // update1/update2/update3 flags ever target (UI_caseBar/UI_rollout/
    // STUDY itself/WIN3D/WORLD - see reviseByUpdateFlags()'s own body,
    // actions.pde).
    reviseByUpdateFlags(1, 1, 1);

    // Forces the one extra follow-up the day/hour-range fields
    // specifically need - resizing allSections' own solar-impact array
    // to the restored day range, flagging bakings for regeneration, and
    // syncing the shade-date angle (react.pde's own applyCaseBarAndBake,
    // which applyRolloutUpdate.pde fires whenever any of
    // startHour/endHour/endDay/dayIncrement/daysMergedCount genuinely
    // changes). (0, 1) stands in for "definitely different" - there's
    // no real old/new pair to compare at restore time, so this forces
    // the follow-up unconditionally rather than skipping it on an o==n
    // guard that was only ever meant to skip REDUNDANT work on a live
    // edit, not to gate a restore.
    react.applyCaseBarAndBake.run(0, 1);

    // Same flag react.impactsUpdateFlag sets on a live plotLayoutIndex
    // change - makes sure the Impact graph itself recomputes from the
    // restored plot layout/impact type/layer/graph selection too,
    // rather than keeping whatever it had drawn before the undo/redo.
    STUDY.updateImpactGraph = true;

    view_changed();
  } finally {
    isRestoringViewport2DSnapshot = false;
  }
}
