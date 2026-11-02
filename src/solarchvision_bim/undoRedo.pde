// Undo/Redo pipeline - step three: hooked up to every 3D-model edit.
//
// Scope for this step, deliberately: everything that already calls
// model_changed() (globalFunctions.pde) - every create, delete, import,
// and batch move/rotate/scale of Faces, Model1Ds, Model2Ds, Solids,
// Polylines, Points, Cameras, Sections, Groups, and Terrain's mesh.
// Spot-checked across the 182 call sites: it's consistently called once
// per discrete, composite user action (e.g. add_House3_Core() builds an
// entire house from several solids and calls it exactly once at the
// end, same as Delete3D.model2DSelection() for a whole multi-object
// delete) - never once per sub-object or per animation frame. There is
// also no continuous mouse-drag editing anywhere in this app (Move3D/
// Rotate3D/Scale3D are only ever driven by spinners, keyboard nudges,
// mouse wheel, or import placement - never mouseDragged.pde), and
// GUI spinners themselves change value on a click/commit basis (the
// increment/decrement buttons, right-click-on-bar jump, and committed
// text edit in uiRollout.pde's _Spinner()), not continuously while
// held - so hooking this one already-central signal doesn't flood the
// history with near-duplicate snapshots the way hooking, say, every
// frame of a live drag would. NOT yet wired to pure view/navigation
// actions (camera orbit/pan/zoom, toggling what's displayed, switching
// tools) or to anything outside model_changed()'s own reach (e.g.
// WIN3D/STUDY/WORLD settings that don't go through it) - those are
// separate, open questions for a later step, same as "should Undo
// itself be undoable" isn't a question here since restoring a snapshot
// never calls model_changed() (confirmed: no from_XML() or to_XML()
// anywhere calls it, so undo()/redo() can't recursively record
// themselves as new steps).
//
// THE MODEL: a single chronological list, history[0..n], with
// historyIndex marking which entry is the current live state. Not the
// push-before-edit stack pair from the previous step - that shape
// needed to capture a snapshot right BEFORE an edit, which model_changed()
// can't give it (it only ever fires AFTER the edit it's reporting).
// Here, every entry already IS a "state after some edit" snapshot, in
// order, and undo/redo just move historyIndex backward/forward through
// that list and restore whichever entry it now points at - no separate
// redo list to keep in sync. history[0], seeded once by
// seedUndoHistory() (drawInitialFrames.pde) right as the app finishes
// loading, is the one baseline that isn't "after an edit" - it's what
// makes the very first edit of a session undoable at all.
//
// Builds on buildProjectSnapshot() (saveProject.pde) and
// restoreProjectSnapshot() (this file) exactly as laid out in the
// previous step - see restoreProjectSnapshot()'s own comment for why
// that's deliberately not load_project() or holdProject()/fetchProject().
//
// Still NOT decided, on purpose: whether New/Open/Fetch should clear and
// reseed this history (right now they don't - the history silently
// keeps referring to whatever project was open before, which is wrong
// the moment someone opens a different file mid-session and then
// presses Ctrl+Z). Flagging it rather than quietly leaving it unnoticed,
// but treating it as its own follow-up rather than guessing at it here.

final int MAX_UNDO_STEPS = 50; // bounds memory growth - each entry is a full scene-graph XML tree

ArrayList<XML> history = new ArrayList<XML>();
int historyIndex = -1; // -1 until seedUndoHistory() runs once at startup

// The one baseline entry that isn't "state after an edit" - see this
// file's own header comment. Called once, from drawInitialFrames.pde,
// right before the app starts accepting input.
void seedUndoHistory () {
  if (history == null) history = new ArrayList<XML>(); // see recordHistoryStep()'s own comment on why this can't be assumed
  history.clear();
  history.add(buildProjectSnapshot(false));
  historyIndex = 0;
}

// Called from model_changed() itself - see this file's own header
// comment for why that one hook is enough for this step's scope.
void recordHistoryStep () {
  // model_changed() can fire before this file's own field initializers
  // below (history/historyIndex) have run at all: Processing/Java
  // initializes a class's fields in tab-concatenation order, and
  // several of the "all<Thing>" container classes (Faces, Model1Ds,
  // Model2Ds, Solids, ...) call makeEmpty() -> model_changed() from
  // their OWN constructor - which fires the moment the sketch's own
  // `allFaces = new Faces();`-style field initializer runs, during the
  // sketch object's construction, possibly before history/historyIndex
  // further down this same file have been assigned. At that point
  // `history` is still null (its own `= new ArrayList<XML>()` hasn't
  // executed yet) and `historyIndex` is still Java's bare default int
  // value of 0 (not yet its explicit `= -1` either) - so a
  // `historyIndex < 0` check alone can't tell "too early" apart from
  // "ready", hence the null check here instead. None of this is a real
  // edit to record anyway - it's empty-initialization boilerplate, long
  // before setup() - the actual baseline is seedUndoHistory(), called
  // from drawInitialFrames.pde well after every such constructor has
  // already run.
  if ((history == null) || (historyIndex < 0)) return;

  // Discard any redo branch sitting beyond the current position: a
  // fresh edit after one or more undos means that uncovered "future"
  // can never be reached again (the standard rule - see this file's own
  // header comment on the previous step's design, which this still
  // follows).
  while (history.size() > historyIndex + 1) {
    history.remove(history.size() - 1);
  }

  history.add(buildProjectSnapshot(false));
  historyIndex = history.size() - 1;

  while (history.size() > MAX_UNDO_STEPS) {
    history.remove(0);
    historyIndex -= 1;
  }
}

void undo () {
  if (historyIndex <= 0) {
    displayDirective("Undo: nothing to undo.");
    return;
  }

  historyIndex -= 1;
  restoreProjectSnapshot(history.get(historyIndex));
}

void redo () {
  if (historyIndex >= history.size() - 1) {
    displayDirective("Redo: nothing to redo.");
    return;
  }

  historyIndex += 1;
  restoreProjectSnapshot(history.get(historyIndex));
}

// The lean counterpart to load_project(): runs the same from_XML()
// dispatch (parse_XML_variables(), shared with Open/Fetch) plus only
// the cheap, state-size-dependent refresh that has to happen whenever
// the scene graph's shape changes (vertex/face/day-range counts feeding
// into the solar arrays' dimensions, stale bake/impact-image flags,
// redrawing every view) - never the file-open-specific work
// load_project() does on top of that (re-reading climate/weather files
// and reallocating their arrays, resetting the viewport to "find a good
// view", resetting the active creation tool). Confirmed safe to call
// from undo()/redo() without recursing back into recordHistoryStep():
// neither parse_XML_variables() nor any from_XML()/to_XML() it reaches
// calls model_changed().
void restoreProjectSnapshot (XML xml) {
  parse_XML_variables(xml, false);

  // Without this, WIN3D's retained-mode viewport cache would keep
  // rendering whatever it had built before this restore - from_XML()
  // writes straight into allFaces/allModel1Ds/Terrain's own arrays the
  // same way an OBJ import does, and neither bumps the cache's own
  // generation counter by itself. See globalFunctions.pde's own comment
  // on invalidateWin3DRetainedCaches() for the full reasoning (and the
  // bug this exact gap caused: undo correctly reverting the data but
  // the view still showing the undone edit). Deliberately calling this
  // directly rather than model_changed() itself - a restore isn't a new
  // edit to record, so it must not also go through recordHistoryStep().
  invalidateWin3DRetainedCaches();

  find_which_bakings_to_regenerate();
  VertexSolar_resize_array();
  GlobalSolar_resize_array();

  UI_rollout.revise();
  WORLD.revise();
  STUDY.revise();
  UI_menuBar.revise();
  UI_toolBar.revise();
  UI_caseBar.revise();
  view_changed();

  modify_Viewport_Title();
}
