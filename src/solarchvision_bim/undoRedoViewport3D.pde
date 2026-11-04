// Undo/Redo pipeline for Viewport3D - same two-piece shape as
// undoRedoScene3D.pde (a chronological list, viewport3DHistory[0..n],
// plus a viewport3DHistoryIndex marking which entry is the current live
// state), but tracking a different, non-overlapping slice of state:
// WIN3D's own camera/view settings (position, rotation, zoom,
// projection, the active saved camera, shading mode, impact overlay),
// via WIN3D.to_XML()/WIN3D.from_XML() - nothing else.
// buildScene3DSnapshot() (undoRedoScene3D.pde) deliberately excludes
// WIN3D entirely - see that file's own header comment - so there's no
// overlap between the two histories: undoing a model edit never moves
// the viewport, and undoing a viewport move never touches the model.
//
// WHY THIS FILE CAN'T REUSE beginScene3DChange()/endScene3DChange()'s
// PATTERN: that pair works because every model edit already funnels
// through two explicit call sites, one right before the edit and one
// right after (globalFunctions.pde). Nothing like that wraps viewport
// navigation - orbit/pan/zoom fire from mouseDragged.pde's
// dispatchWin3DTaskDrag() (a fresh +PanView/+TurnView/+OrbitSelection/...
// script line on almost every frame while a drag is held),
// mouseWheel.pde's own +* commands, WIN3D.processHeldKey() (arrow-key
// nudges, polled every frame from draw()), and WIN3D.keyPressed() - a
// dozen-plus call sites, several of them firing many times per second
// during one continuous gesture. Wrapping every one of them in its own
// begin/end pair would be a far larger, more invasive change than
// recording WIN3D's own state actually calls for.
//
// So instead this file polls: trackViewport3DChange() (below), called
// once per frame from draw() (solarchvision_bim.pde, after
// draw_initial_frames() has finished), diffs WIN3D's current to_XML()
// output against the live history entry and, if it differs, either
// folds the change into that same entry (when the previous frame also
// changed it - i.e. this is still the same continuous drag/scroll/
// held-key gesture) or starts a fresh entry (when the change follows at
// least one quiet frame - a new gesture). This is exactly the
// frame-based coalescing idea undoRedoScene3D.pde's own header comment
// describes retiring for model edits, in favor of a real pre-edit hook
// - kept here instead, since Viewport3D has no begin/end hook of its
// own to use for that pre-edit boundary.
//
// Deliberately has no equivalent of restoreScene3DSnapshot()'s
// Select3D.clampSelectionsToCurrentData()/invalidateWin3DRetainedCaches()
// calls: a viewport undo/redo never touches the model, so there's no
// selection to re-clamp and no geometry/material cache to invalidate -
// WIN3D.revise() below is the only follow-up restoring a camera
// position ever needs, the same flag every other camera/view change in
// this codebase already sets.

final int MAX_UNDO_VIEWPORT3D = 50; // a viewport snapshot is one small XML element (WIN3D's own fields), not a whole scene graph, so this can comfortably hold more steps than MAX_UNDO_MODEL3D

ArrayList<XML> viewport3DHistory = new ArrayList<XML>();
int viewport3DHistoryIndex = -1; // -1 until seedViewport3DHistory() runs once at startup

// Guards trackViewport3DChange() against recording a restore as a new
// step of its own - same shape as isRestoringScene3DSnapshot, for the
// same reason: without it, restoreProjectViewport3DSnapshot()'s own
// WIN3D.from_XML() write would otherwise look, to the very next frame's
// trackViewport3DChange(), exactly like a brand new gesture.
boolean isRestoringViewport3DSnapshot = false;

// The frameCount at which the live history entry
// (viewport3DHistory[viewport3DHistoryIndex]) was last written to -
// used by trackViewport3DChange() below to tell "still the same
// gesture" (this frame's change immediately follows last frame's
// change) apart from "a new gesture" (at least one quiet frame in
// between). See that function's own comment.
int viewport3DHistoryLastChangeFrame = -1;

// WIN3D's own undo/redo snapshot - deliberately just the one class,
// unlike buildScene3DSnapshot()'s eleven. See this file's header
// comment for why Viewport3D's undo/redo is scoped to WIN3D alone.
XML buildViewport3DSnapshot () {

  XML xml = parseXML("<?xml version='1.0' encoding='UTF-8'?>" + char(13) + "<empty>" + char(13) + "</empty>");

  xml.setName("solarchvisionV" + version);

  WIN3D.to_XML(xml);

  return xml;
}

// The one baseline entry that isn't "state after a change" - same role
// seedScene3DHistory() plays for the model history. Called once from
// drawInitialFrames.pde right before the app starts accepting input,
// and again whenever New/Open/Fetch replace WIN3D's own state wholesale
// (globalFunctions.pde's deleteAll(), loadProject.pde's load_project())
// - a different project (or a freshly emptied one) means the viewport
// history needs to start fresh from exactly that state too, same
// reasoning as seedScene3DHistory()'s own callers.
void seedViewport3DHistory () {
  if (viewport3DHistory == null) viewport3DHistory = new ArrayList<XML>(); // see beginUndoableScene3DEdit()'s own comment on the same null-before-init race (undoRedoScene3D.pde) - WIN3D's own field initializers run in the same tab-concatenation order, so the window this guards against is the same one
  viewport3DHistory.clear();
  viewport3DHistory.add(buildViewport3DSnapshot());
  viewport3DHistoryIndex = 0;
  viewport3DHistoryLastChangeFrame = -1;
}

// Called once per frame from draw() (solarchvision_bim.pde), only after
// draw_initial_frames() has finished (so WIN3D and viewport3DHistory
// both already exist) - see this file's header comment for why polling,
// rather than a begin/end hook, is what Viewport3D's undo/redo needs.
void trackViewport3DChange () {
  if (isRestoringViewport3DSnapshot) return;
  if ((viewport3DHistory == null) || (viewport3DHistoryIndex < 0)) return;

  XML current = buildViewport3DSnapshot();

  // Nothing to record: WIN3D looks exactly like the live entry already
  // does - either nothing moved this frame, or this is the very next
  // frame after an undo/redo restored it to exactly this state.
  if (current.toString().equals(viewport3DHistory.get(viewport3DHistoryIndex).toString())) return;

  if (viewport3DHistoryLastChangeFrame == frameCount - 1) {
    // Still the same continuous gesture as last frame (a held drag, a
    // run of scroll-wheel notches, a held arrow key) - keep refining
    // the entry already in progress rather than recording every
    // in-between frame as its own step.
    viewport3DHistory.set(viewport3DHistoryIndex, current);
  } else {
    // A fresh gesture, separated from whatever last changed WIN3D by at
    // least one quiet frame. Discard any redo branch beyond the current
    // position first - the same "a fresh edit clears the uncovered
    // future" rule commitUndoableScene3DEdit() follows - then record
    // the new step.
    while (viewport3DHistory.size() > viewport3DHistoryIndex + 1) {
      viewport3DHistory.remove(viewport3DHistory.size() - 1);
    }

    viewport3DHistory.add(current);
    viewport3DHistoryIndex = viewport3DHistory.size() - 1;

    while (viewport3DHistory.size() > MAX_UNDO_VIEWPORT3D) {
      viewport3DHistory.remove(0);
      viewport3DHistoryIndex -= 1;
    }
  }

  viewport3DHistoryLastChangeFrame = frameCount;
}

void undoViewport3DChange () {
  if (viewport3DHistoryIndex <= 0) {
    displayDirective("Undo: no viewport change to undo.");
    return;
  }

  viewport3DHistoryIndex -= 1;
  restoreProjectViewport3DSnapshot(viewport3DHistory.get(viewport3DHistoryIndex));
}

void redoViewport3DChange () {
  if (viewport3DHistoryIndex >= viewport3DHistory.size() - 1) {
    displayDirective("Redo: no viewport change to redo.");
    return;
  }

  viewport3DHistoryIndex += 1;
  restoreProjectViewport3DSnapshot(viewport3DHistory.get(viewport3DHistoryIndex));
}

// The from_XML() counterpart to buildViewport3DSnapshot() above - just
// WIN3D.from_XML(), same single-class scope.
void restoreViewport3DSnapshot (XML xml) {
  WIN3D.from_XML(xml);
}

// Safe to call from undo()/redo() only because of
// isRestoringViewport3DSnapshot below - see its own comment:
// trackViewport3DChange() would otherwise see this function's own
// WIN3D.from_XML() write, on the very next frame, as a brand new
// gesture and immediately record it as one more step, turning every
// undo into a redo-able "change" of its own. try/finally so the flag
// can't get stuck true and silently disable all future viewport
// undo/redo recording if something throws partway through a restore.
void restoreProjectViewport3DSnapshot (XML xml) {
  isRestoringViewport3DSnapshot = true;
  try {
    restoreViewport3DSnapshot(xml);

    // Same flag every other camera/view change in this codebase sets
    // (WIN3D.revise()'s own callers) - makes the 3D viewport actually
    // redraw from the restored position/rotation/zoom instead of
    // keeping whatever it had on screen right before the undo/redo.
    WIN3D.revise();
  } finally {
    isRestoringViewport3DSnapshot = false;
  }
}
