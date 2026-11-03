// Undo/Redo pipeline - step four: a precise pre-edit hook, replacing
// the frame-boundary heuristics the previous step needed.
//
// Scope, still deliberate: everything that already calls
// beginModelChange()/endModelChange() (globalFunctions.pde) - every
// create, delete, import, and batch move/rotate/scale of Faces,
// Model1Ds, Model2Ds, Solids, Polylines, Points, Cameras, Sections,
// Groups, and Terrain's mesh. NOT wired to pure view/navigation actions
// (camera orbit/pan/zoom, toggling what's displayed, switching tools) -
// those don't call either function and don't record a step. Restoring a
// step deliberately leaves the viewport alone too, via
// parse_XML_variables()'s own restoreViewport flag (false here) - see
// that function's own comment.
//
// THE MODEL: a single chronological list, history[0..n], with
// historyIndex marking which entry is the current live state - same
// shape as the previous step, but what changed is WHEN each entry gets
// written and by what. beginModelChange()/endModelChange() give a real
// pre-edit boundary now (endModelChange()'s own comment covers why
// model_changed() alone couldn't), which replaces two separate
// workarounds the previous step needed to approximate that boundary
// without one:
//
//   - frameCount-based coalescing ("did the last step happen in this
//     same frame") is gone. beginUndoableEdit()/commitUndoableEdit()
//     only fire on the OUTERMOST begin/end transition
//     (modelChangeDepth 0->1 / 1->0 - see beginModelChange()'s own
//     comment), so a composite action like Delete3D.selection() (which
//     now wraps its own several sub-steps, each already wrapped
//     themselves, in one more begin/end pair around the whole thing)
//     coalesces by construction, not by guessing from timing.
//
//   - frameStartSelectionSnapshot (a once-per-frame copy of Select3D's
//     own state, patched into the entry about to be superseded) is
//     gone too. beginUndoableEdit() now simply REPLACES
//     history[historyIndex] with a fresh buildProjectSnapshot() of
//     whatever is actually live right this instant, immediately before
//     the edit that's about to start mutates anything - exact, not
//     approximated from a frame boundary. Select3D's own
//     captureSelectionSnapshot()/applySelectionSnapshotTo() helpers
//     that existed only to support the old surgical per-field patch are
//     gone with it; a plain whole-entry replacement needs no equivalent.
//
// history[0], seeded once by seedUndoHistory() (drawInitialFrames.pde)
// right as the app finishes loading, is the one baseline entry that
// isn't itself refreshed by a beginUndoableEdit() call (there's no
// "edit before the first edit") - it's what makes the very first edit
// of a session undoable at all, and beginUndoableEdit() still keeps it
// current with whatever's selected right up until that first edit
// actually starts.
//
// Builds on buildProjectSnapshot() (saveProject.pde) and
// restoreProjectSnapshot() (this file) - see restoreProjectSnapshot()'s
// own comment for why that's deliberately not load_project() or
// holdProject()/fetchProject().
//
// New/Open/Fetch now DO clear and reseed this history - resolved while
// fixing a more urgent, related bug in the same two places: as more
// classes' makeEmpty() each gained their own complete beginModelChange()/
// endModelChange() pair (see those classes' own comments), both
// deleteAll() (globalFunctions.pde, "New") and load_project()
// (loadProject.pde, "Open"/"Fetch") turned out to be calling several of
// them in a row with no reentrancy guard around the whole sequence -
// deleteAll() recording several spurious history entries for one "New"
// instead of one (now fixed by wrapping the whole sequence in its own
// beginModelChange()/endModelChange() pair, same reasoning as
// Delete3D.selection()'s own comment), and load_project() doing the same
// via parse_XML_variables()'s own from_XML() cascade (now wrapped in
// isRestoringSnapshot, the same guard restoreProjectSnapshot() below
// already relied on, just newly needed by this second caller too). Once
// both were already being touched for that reason, reseeding the history
// right after each succeeds was the natural fix for the history
// correctness question this comment used to flag as open: a different
// project's content, or a freshly emptied one, means the undo history
// needs to start fresh from exactly that state, not keep referring to
// whatever was open before it.

final int MAX_UNDO_STEPS = 50; // bounds memory growth - each entry is a full scene-graph XML tree

ArrayList<XML> history = new ArrayList<XML>();
int historyIndex = -1; // -1 until seedUndoHistory() runs once at startup

// Guards beginUndoableEdit()/commitUndoableEdit() against firing WHILE a
// restore is already in progress - see restoreProjectSnapshot()'s own
// comment for why this is necessary, not just defensive: makeEmpty()
// (Faces/Model1Ds/Model2Ds/Solids/Polylines/Points/Cameras/Sections/
// Groups all follow the same pattern) unconditionally calls
// endModelChange() at its own end (now preceded by its own
// beginModelChange(), per this step's own conversion), and from_XML()
// calls makeEmpty() as its first step to reset the class to the right
// size before refilling it - so parse_XML_variables() alone fires
// several begin/end pairs per restore, each one operating on whatever
// is STILL only half-restored at that exact point in the from_XML()
// sequence, and stomping on historyIndex along the way, without this
// guard.
boolean isRestoringSnapshot = false;

// The one baseline entry that isn't "state after an edit" - see this
// file's own header comment. Called once, from drawInitialFrames.pde,
// right before the app starts accepting input.
void seedUndoHistory () {
  if (history == null) history = new ArrayList<XML>(); // see beginUndoableEdit()'s own comment on why this can't be assumed
  history.clear();
  history.add(buildProjectSnapshot(false));
  historyIndex = 0;
}

// Called from beginModelChange() itself, only on the outermost (depth
// 0 -> 1) transition - see that function's own comment for why nesting
// matters here. This is what makes undo land on the right SELECTION
// (not just the right geometry) after a later edit: a pure selection
// change (clicking a different face) never gets its own history step on
// purpose, but replacing the CURRENT entry with a fresh snapshot right
// here means whatever was selected right up until the moment an edit
// actually starts is what that entry ends up holding - not whatever was
// selected back when it was itself first recorded.
void beginUndoableEdit () {
  if (isRestoringSnapshot) return;

  // beginModelChange() can fire before this file's own field
  // initializers above (history/historyIndex) have run at all:
  // Processing/Java initializes a class's fields in tab-concatenation
  // order, and several of the "all<Thing>" container classes (Faces,
  // Model1Ds, Model2Ds, Solids, ...) call makeEmpty() ->
  // beginModelChange()+endModelChange() from their OWN constructor -
  // which fires the moment the sketch's own `allFaces = new Faces();`-
  // style field initializer runs, during the sketch object's
  // construction, possibly before history/historyIndex further up this
  // same file have been assigned. At that point `history` is still null
  // (its own `= new ArrayList<XML>()` hasn't executed yet) and
  // `historyIndex` is still Java's bare default int value of 0 (not yet
  // its explicit `= -1` either) - so a `historyIndex < 0` check alone
  // can't tell "too early" apart from "ready", hence the null check
  // here instead. None of this is a real edit to record anyway - it's
  // empty-initialization boilerplate, long before setup() - the actual
  // baseline is seedUndoHistory(), called from drawInitialFrames.pde
  // well after every such constructor has already run.
  if ((history == null) || (historyIndex < 0)) return;

  history.set(historyIndex, buildProjectSnapshot(false));
}

// Called from endModelChange() itself, only on the outermost (depth
// 1 -> 0) transition.
void commitUndoableEdit () {
  if (isRestoringSnapshot) return;
  if ((history == null) || (historyIndex < 0)) return;

  // Discard any redo branch sitting beyond the current position: a
  // fresh edit after one or more undos means that uncovered "future"
  // can never be reached again (the standard rule).
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
// comment: parse_XML_variables() does reach beginModelChange()/
// endModelChange() repeatedly (via several classes' from_XML() ->
// makeEmpty()), and without that guard each of those would recursively
// record itself as a new step.
void restoreProjectSnapshot (XML xml) {
  // isRestoringSnapshot (set for the entire call, including every
  // from_XML() parse_XML_variables() below reaches) is what makes this
  // safe to call at all - see that field's own comment. try/finally so
  // it can't get stuck "true" and silently disable all future undo/redo
  // recording if something throws partway through a restore.
  isRestoringSnapshot = true;
  try {
    // restoreViewport: false - undo/redo is scoped to 3D-modeling edits
    // only (beginModelChange()/endModelChange()'s own reach), not
    // camera/viewport navigation. The person's current view stays
    // exactly where they left it; see parse_XML_variables()'s own
    // comment on this flag.
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
    // directly rather than endModelChange() itself - a restore isn't a
    // new edit to record, so it must not also go through
    // commitUndoableEdit() (doubly so now, given isRestoringSnapshot
    // would block it anyway - this keeps the cache invalidation itself
    // unconditional regardless).
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
