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
// frame of a live drag would. NOT wired to pure view/navigation actions
// (camera orbit/pan/zoom, toggling what's displayed, switching tools) -
// those don't call model_changed() and don't record a step. More than
// that, though: restoring a step deliberately leaves the viewport alone
// too, via parse_XML_variables()'s own restoreViewport flag (false here)
// - without it, undoing a model edit would also snap the camera back to
// wherever it was at that earlier edit, which is no part of "undo my
// last edit" as far as this step's scope goes. Everything else WIN3D
// holds (current tool, shading-display mode, ...) is left alone the
// same way, for the same reason - it's "what you're doing right now",
// not modeling content. STUDY/WORLD settings that don't go through
// model_changed() are a separate, open question for a later step.
// "Should Undo itself be
// undoable" very much WAS a real question here, not a moot one:
// restoring a snapshot does end up calling model_changed() - repeatedly,
// in fact, since from_XML() calls makeEmpty() (Faces/Model1Ds/Model2Ds/
// Solids/Polylines/Points/Cameras/Sections/Groups), which calls
// model_changed() unconditionally at its own end - so parse_XML_variables()
// alone fires it close to nine times per restore. isRestoringSnapshot
// below exists specifically to stop each of those from recursively
// recording itself as a new history step.
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

// Guards recordHistoryStep() against firing WHILE a restore is already
// in progress - see restoreProjectSnapshot()'s own comment for why this
// is necessary, not just defensive: makeEmpty() (Faces/Model1Ds/
// Model2Ds/Solids/Polylines/Points/Cameras/Sections/Groups all follow
// the same pattern) unconditionally calls model_changed() at its own
// end, and from_XML() calls makeEmpty() as its first step to reset the
// class to the right size before refilling it - so parse_XML_variables()
// alone fires model_changed() (and so, without this guard,
// recordHistoryStep()) around nine times per restore, each one
// capturing a snapshot of whatever is STILL only half-restored at that
// exact point in the from_XML() sequence, and stomping on historyIndex
// along the way. This was the actual bug behind undo "not working as
// expected": not a rendering issue, history itself was getting
// scrambled by its own restore.
boolean isRestoringSnapshot = false;

// Updated once per frame, right at the start of each frame's real
// processing (solarchvision_bim.pde's draw() - see that call site's own
// comment), to whatever Select3D.captureSelectionSnapshot() currently
// holds.
//
// Why this exists: a pure selection change (clicking to select a face)
// never calls model_changed() and so never gets its own history step -
// deliberately, per this file's own header comment, since not every
// click should be its own undo step. But that means a history entry's
// OWN originally-recorded selection can go stale the moment the user
// selects something else afterward without editing anything yet: build
// a grid of openings (one entry, whatever got auto-selected when the
// modifier finished), manually select the middle one (no new entry),
// delete it (a new entry, selection now cleared) - undoing that delete
// would otherwise restore the grid-of-openings entry's own OLD
// selection from when the modifier itself finished, not the middle
// face the user actually selected afterward and deleted - a real
// report: "undo - the selected face is not the correct one in the
// middle; it is another face". recordHistoryStep() below patches the
// entry it's about to supersede with this value, right before
// recording the new one, so what undo lands back on reflects what was
// actually selected right before that next edit started - not whatever
// was selected back when the entry being returned to was itself first
// captured.
XML frameStartSelectionSnapshot = null;

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
  // See isRestoringSnapshot's own comment: a restore isn't a new edit to
  // record, it's replaying an old one - without this, every single
  // undo()/redo() would corrupt the very history it's reading from.
  if (isRestoringSnapshot) return;

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

  // See frameStartSelectionSnapshot's own comment: patch the entry
  // we're about to supersede with whatever was actually selected right
  // before this edit started, not whatever its own selection happened
  // to be when it was originally recorded.
  if (frameStartSelectionSnapshot != null) {
    Select3D.applySelectionSnapshotTo(history.get(historyIndex), frameStartSelectionSnapshot);
  }

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

// A restored snapshot's own selection state is internally consistent at
// the moment it was captured, but a long tail of code elsewhere reads a
// selection lazily (sometimes a whole frame later) and indexes straight
// into the restored data with no bounds check - each one a genuinely
// different call site, found one crash report at a time (faces.pde/
// clone3D.pde/mouseClicked.pde/overlay3D.pde/select3D.pde's own fixes).
// Select3D.clampSelectionsToCurrentData(), called below right after
// parse_XML_variables(), closes that off at the source instead of
// chasing further consumers - see its own comment for the full
// reasoning.
//
// The lean counterpart to load_project(): runs the same from_XML()
// dispatch (parse_XML_variables(), shared with Open/Fetch) plus only
// the cheap, state-size-dependent refresh that has to happen whenever
// the scene graph's shape changes (vertex/face/day-range counts feeding
// into the solar arrays' dimensions, stale bake/impact-image flags,
// redrawing every view) - never the file-open-specific work
// load_project() does on top of that (re-reading climate/weather files
// and reallocating their arrays, resetting the viewport to "find a good
// view", resetting the active creation tool). Safe to call from
// undo()/redo() only because of isRestoringSnapshot below - see its own
// comment: parse_XML_variables() does reach model_changed() repeatedly
// (via several classes' from_XML() -> makeEmpty()), and without that
// guard each of those would recursively record itself as a new step.
void restoreProjectSnapshot (XML xml) {
  // isRestoringSnapshot (set for the entire call, including every
  // from_XML() parse_XML_variables() below reaches) is what makes this
  // safe to call at all - see that field's own comment. try/finally so
  // it can't get stuck "true" and silently disable all future undo/redo
  // recording if something throws partway through a restore.
  isRestoringSnapshot = true;
  try {
    // restoreViewport: false - undo/redo is scoped to 3D-modeling edits
    // only (model_changed()'s own reach), not camera/viewport
    // navigation. The person's current view stays exactly where they
    // left it; see parse_XML_variables()'s own comment on this flag.
    parse_XML_variables(xml, false, false);

    // See Select3D.clampSelectionsToCurrentData()'s own comment: drops
    // any selected index that doesn't exist in what was just restored,
    // before anything else below (or on a later frame) reads the
    // selection against the new data.
    Select3D.clampSelectionsToCurrentData();

    // Without this, WIN3D's retained-mode viewport cache would keep
    // rendering whatever it had built before this restore - from_XML()
    // writes straight into allFaces/allModel1Ds/Terrain's own arrays the
    // same way an OBJ import does, and neither bumps the cache's own
    // generation counter by itself. See globalFunctions.pde's own comment
    // on invalidateWin3DRetainedCaches() for the full reasoning (and the
    // bug this exact gap caused: undo correctly reverting the data but
    // the view still showing the undone edit). Deliberately calling this
    // directly rather than model_changed() itself - a restore isn't a new
    // edit to record, so it must not also go through recordHistoryStep()
    // (doubly so now, given isRestoringSnapshot would block it anyway -
    // this keeps the cache invalidation itself unconditional regardless).
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
  } finally {
    isRestoringSnapshot = false;
  }
}
