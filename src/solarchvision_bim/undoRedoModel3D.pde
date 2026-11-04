// Undo/Redo pipeline - step four: a precise pre-edit hook, replacing
// the frame-boundary heuristics the previous step needed.
//
// Scope, still deliberate: everything that already calls
// beginScene3DChange()/endScene3DChange() (globalFunctions.pde) - every
// create, delete, import, and batch move/rotate/scale of Faces,
// Model1Ds, Model2Ds, Solids, Polylines, Points, Cameras, Sections,
// Groups, and Terrain's mesh. NOT wired to pure view/navigation actions
// (camera orbit/pan/zoom, toggling what's displayed, switching tools) -
// those don't call either function and don't record a step. Restoring a
// step deliberately leaves the viewport alone too - a snapshot
// (buildScene3DSnapshot(), below) never includes WIN3D's own state at all,
// so there's nothing for restoreScene3DSnapshot() to put back there even
// to leave alone.
//
// THE MODEL: a single chronological list, scene3DHistory[0..n], with
// scene3DHistoryIndex marking which entry is the current live state - same
// shape as the previous step, but what changed is WHEN each entry gets
// written and by what. beginScene3DChange()/endScene3DChange() give a real
// pre-edit boundary now (endScene3DChange()'s own comment covers why
// model_changed() alone couldn't), which replaces two separate
// workarounds the previous step needed to approximate that boundary
// without one:
//
//   - frameCount-based coalescing ("did the last step happen in this
//     same frame") is gone. beginUndoableScene3DEdit()/commitUndoableScene3DEdit()
//     only fire on the OUTERMOST begin/end transition
//     (scene3DChangeDepth 0->1 / 1->0 - see beginScene3DChange()'s own
//     comment), so a composite action like Delete3D.selection() (which
//     now wraps its own several sub-steps, each already wrapped
//     themselves, in one more begin/end pair around the whole thing)
//     coalesces by construction, not by guessing from timing.
//
//   - frameStartSelectionSnapshot (a once-per-frame copy of Select3D's
//     own state, patched into the entry about to be superseded) is
//     gone too. beginUndoableScene3DEdit() now simply REPLACES
//     scene3DHistory[scene3DHistoryIndex] with a fresh buildScene3DSnapshot() of
//     whatever is actually live right this instant, immediately before
//     the edit that's about to start mutates anything - exact, not
//     approximated from a frame boundary. Select3D's own
//     captureSelectionSnapshot()/applySelectionSnapshotTo() helpers
//     that existed only to support the old surgical per-field patch are
//     gone with it; a plain whole-entry replacement needs no equivalent.
//
// scene3DHistory[0], seeded once by seedScene3DHistory() (drawInitialFrames.pde)
// right as the app finishes loading, is the one baseline entry that
// isn't itself refreshed by a beginUndoableScene3DEdit() call (there's no
// "edit before the first edit") - it's what makes the very first edit
// of a session undoable at all, and beginUndoableScene3DEdit() still keeps it
// current with whatever's selected right up until that first edit
// actually starts.
//
// Builds on buildScene3DSnapshot()/restoreScene3DSnapshot() (this file) - see
// restoreProjectScene3DSnapshot()'s own comment for why that's deliberately
// not load_project() or holdProject()/fetchProject(). Unlike
// saveProject.pde's buildProjectSnapshot()/parseXmlVariables.pde's
// parse_XML_variables() (the Save/Open/Hold/Fetch path), this file's
// own pair is scoped to 3D-modeling content plus the current selection
// (Select3D) only - see buildScene3DSnapshot()'s own comment for exactly
// what that excludes and why.
//
// New/Open/Fetch now DO clear and reseed this scene3DHistory - resolved while
// fixing a more urgent, related bug in the same two places: as more
// classes' makeEmpty() each gained their own complete beginScene3DChange()/
// endScene3DChange() pair (see those classes' own comments), both
// deleteAll() (globalFunctions.pde, "New") and load_project()
// (loadProject.pde, "Open"/"Fetch") turned out to be calling several of
// them in a row with no reentrancy guard around the whole sequence -
// deleteAll() recording several spurious scene3DHistory entries for one "New"
// instead of one (now fixed by wrapping the whole sequence in its own
// beginScene3DChange()/endScene3DChange() pair, same reasoning as
// Delete3D.selection()'s own comment), and load_project() doing the same
// via parse_XML_variables()'s own from_XML() cascade (now wrapped in
// isRestoringScene3DSnapshot, the same guard restoreProjectScene3DSnapshot() below
// already relied on, just newly needed by this second caller too). Once
// both were already being touched for that reason, reseeding the scene3DHistory
// right after each succeeds was the natural fix for the scene3DHistory
// correctness question this comment used to flag as open: a different
// project's content, or a freshly emptied one, means the undo scene3DHistory
// needs to start fresh from exactly that state, not keep referring to
// whatever was open before it.

final int MAX_UNDO_MODEL3D = 16; // bounds memory growth - each entry is a full scene-graph XML tree

ArrayList<XML> scene3DHistory = new ArrayList<XML>();
int scene3DHistoryIndex = -1; // -1 until seedScene3DHistory() runs once at startup

// Guards beginUndoableScene3DEdit()/commitUndoableScene3DEdit() against firing WHILE a
// restore is already in progress - see restoreProjectScene3DSnapshot()'s own
// comment for why this is necessary, not just defensive: makeEmpty()
// (Faces/Model1Ds/Model2Ds/Solids/Polylines/Points/Cameras/Sections/
// Groups all follow the same pattern) unconditionally calls
// endScene3DChange() at its own end (now preceded by its own
// beginScene3DChange(), per this step's own conversion), and from_XML()
// calls makeEmpty() as its first step to reset the class to the right
// size before refilling it - so restoreScene3DSnapshot() alone fires
// several begin/end pairs per restore, each one operating on whatever
// is STILL only half-restored at that exact point in the from_XML()
// sequence, and stomping on scene3DHistoryIndex along the way, without this
// guard.
boolean isRestoringScene3DSnapshot = false;

// The undo/redo stack's own snapshot format - deliberately narrower
// than buildProjectSnapshot() (saveProject.pde), which is Save/Hold/
// Fetch's "everything that makes up a project" tree (settings,
// climate/weather configuration, the celestial/sky/viewport objects,
// WORLD/STUDY, wind roses, impacts, layers...). None of that is in
// scope here: undo/redo, per this file's own header comment, only ever
// follows beginScene3DChange()/endScene3DChange(), and that pair only ever
// wraps edits to Points/Polylines/Faces/Cameras/Solids/Sections/
// Model1Ds/Model2Ds/Groups/Terrain's mesh - so those are the only
// classes whose state a model-change undo/redo step can ever need to
// recreate. Select3D is the one addition to that list: it's not itself
// touched by beginScene3DChange()/endScene3DChange(), but beginUndoableScene3DEdit()'s
// own comment is why it still belongs here - landing on the right
// SELECTION after an undo/redo, not just the right geometry, needs the
// selection captured in the same snapshot as the geometry it refers to.
// Serializing the rest on every single edit (previously via
// buildProjectSnapshot()) was pure overhead a scene3DHistory of up to
// MAX_UNDO_MODEL3D entries paid for repeatedly, and restoring it on every
// undo/redo was reverting state (WORLD/STUDY settings, the active
// camera/viewport, and so on) that undo/redo was never meant to touch
// in the first place - restoreScene3DSnapshot() below leaves all of it
// alone, exactly as live as it was right before the undo/redo.
//
// copyTexturesAlongside is always false here, same as every previous
// caller of buildProjectSnapshot() from this file: undo/redo snapshots
// live purely in memory and never touch disk, so Terrain.to_XML()'s own
// texture-copying side effect (see that method's own comment) is
// never wanted here.
XML buildScene3DSnapshot () {

  XML xml = parseXML("<?xml version='1.0' encoding='UTF-8'?>" + char(13) + "<empty>" + char(13) + "</empty>");

  xml.setName("solarchvisionV" + version);

  allPoints.to_XML(xml);

  allPolylines.to_XML(xml);

  allFaces.to_XML(xml);

  allCameras.to_XML(xml);

  allSolids.to_XML(xml);

  allSections.to_XML(xml);

  allModel1Ds.to_XML(xml);

  allModel2Ds.to_XML(xml);

  allGroups.to_XML(xml);

  Terrain.to_XML(xml, false);

  Select3D.to_XML(xml);

  return xml;
}

// The one baseline entry that isn't "state after an edit" - see this
// file's own header comment. Called once, from drawInitialFrames.pde,
// right before the app starts accepting input.
void seedScene3DHistory () {
  if (scene3DHistory == null) scene3DHistory = new ArrayList<XML>(); // see beginUndoableScene3DEdit()'s own comment on why this can't be assumed
  scene3DHistory.clear();
  scene3DHistory.add(buildScene3DSnapshot());
  scene3DHistoryIndex = 0;
}

// Called from beginScene3DChange() itself, only on the outermost (depth
// 0 -> 1) transition - see that function's own comment for why nesting
// matters here. This is what makes undo land on the right SELECTION
// (not just the right geometry) after a later edit: a pure selection
// change (clicking a different face) never gets its own scene3DHistory step on
// purpose, but replacing the CURRENT entry with a fresh snapshot right
// here means whatever was selected right up until the moment an edit
// actually starts is what that entry ends up holding - not whatever was
// selected back when it was itself first recorded.
void beginUndoableScene3DEdit () {
  if (isRestoringScene3DSnapshot) return;

  // beginScene3DChange() can fire before this file's own field
  // initializers above (scene3DHistory/scene3DHistoryIndex) have run at all:
  // Processing/Java initializes a class's fields in tab-concatenation
  // order, and several of the "all<Thing>" container classes (Faces,
  // Model1Ds, Model2Ds, Solids, ...) call makeEmpty() ->
  // beginScene3DChange()+endScene3DChange() from their OWN constructor -
  // which fires the moment the sketch's own `allFaces = new Faces();`-
  // style field initializer runs, during the sketch object's
  // construction, possibly before scene3DHistory/scene3DHistoryIndex further up this
  // same file have been assigned. At that point `scene3DHistory` is still null
  // (its own `= new ArrayList<XML>()` hasn't executed yet) and
  // `scene3DHistoryIndex` is still Java's bare default int value of 0 (not yet
  // its explicit `= -1` either) - so a `scene3DHistoryIndex < 0` check alone
  // can't tell "too early" apart from "ready", hence the null check
  // here instead. None of this is a real edit to record anyway - it's
  // empty-initialization boilerplate, long before setup() - the actual
  // baseline is seedScene3DHistory(), called from drawInitialFrames.pde
  // well after every such constructor has already run.
  if ((scene3DHistory == null) || (scene3DHistoryIndex < 0)) return;

  scene3DHistory.set(scene3DHistoryIndex, buildScene3DSnapshot());
}

// Called from endScene3DChange() itself, only on the outermost (depth
// 1 -> 0) transition.
void commitUndoableScene3DEdit () {
  if (isRestoringScene3DSnapshot) return;
  if ((scene3DHistory == null) || (scene3DHistoryIndex < 0)) return;

  // Discard any redo branch sitting beyond the current position: a
  // fresh edit after one or more undos means that uncovered "future"
  // can never be reached again (the standard rule).
  while (scene3DHistory.size() > scene3DHistoryIndex + 1) {
    scene3DHistory.remove(scene3DHistory.size() - 1);
  }

  scene3DHistory.add(buildScene3DSnapshot());
  scene3DHistoryIndex = scene3DHistory.size() - 1;

  while (scene3DHistory.size() > MAX_UNDO_MODEL3D) {
    scene3DHistory.remove(0);
    scene3DHistoryIndex -= 1;
  }
}

void undoScene3DChange () {
  if (scene3DHistoryIndex <= 0) {
    displayDirective("Undo: no model change to undo.");
    return;
  }

  scene3DHistoryIndex -= 1;
  restoreProjectScene3DSnapshot(scene3DHistory.get(scene3DHistoryIndex));
}

void redoScene3DChange () {
  if (scene3DHistoryIndex >= scene3DHistory.size() - 1) {
    displayDirective("Redo: no model change to redo.");
    return;
  }

  scene3DHistoryIndex += 1;
  restoreProjectScene3DSnapshot(scene3DHistory.get(scene3DHistoryIndex));
}

// The from_XML() counterpart to buildScene3DSnapshot() above - same
// eleven classes, same order (Groups after Faces/Polylines/Model1Ds/
// Model2Ds, same as parseXmlVariables.pde's own dispatch and for the
// same reason; Select3D last, since its own from_XML() just reads back
// index lists with no further ordering requirement of its own - see
// that method's own comment). Deliberately not parse_XML_variables()
// (saveProject.pde/parseXmlVariables.pde's Save/Open/Hold/Fetch
// dispatch): that function also reads a "variable" child and several
// other classes' own children (STATION, Earth3D, Sky3D, WORLD, ...)
// that a buildScene3DSnapshot() tree never has, and would throw reaching
// for them.
void restoreScene3DSnapshot (XML xml) {

  allPoints.from_XML(xml);

  allPolylines.from_XML(xml);

  allFaces.from_XML(xml);

  allCameras.from_XML(xml);

  allSolids.from_XML(xml);

  allSections.from_XML(xml);

  allModel1Ds.from_XML(xml);

  allModel2Ds.from_XML(xml);

  allGroups.from_XML(xml); // Note: Groups should be inputted after Faces, Polylines, Model1Ds, Model2Ds, etc.

  Terrain.from_XML(xml);

  Select3D.from_XML(xml);
}

// A restored snapshot's own selection state is internally consistent at
// the moment it was captured, but a long tail of code elsewhere reads a
// selection lazily (sometimes a whole frame later) and indexes straight
// into the restored data with no bounds check - each one a genuinely
// different call site, found one crash report at a time (faces.pde/
// clone3D.pde/mouseClicked.pde/overlay3D.pde/select3D.pde's own fixes).
// Select3D.clampSelectionsToCurrentData(), called below right after
// restoreScene3DSnapshot(), closes that off at the source instead of
// chasing further consumers - see its own comment for the full
// reasoning. Select3D.from_XML() (part of restoreScene3DSnapshot() above)
// already puts back the selection exactly as it was captured alongside
// that entry's geometry, so this clamp is what it always was: a
// defensive pass, not the thing that decides what ends up selected.
//
// The lean counterpart to load_project(): runs restoreScene3DSnapshot()
// above (undo/redo's own narrower from_XML() dispatch, not
// parse_XML_variables()'s full one) plus only the cheap, state-size-
// dependent refresh that has to happen whenever the scene graph's shape
// changes (vertex/face/day-range counts feeding into the solar arrays'
// dimensions, stale bake/impact-image flags, invalidating the viewport's
// retained render cache) - never the file-open-specific work
// load_project() does (re-reading climate/weather files and
// reallocating their arrays, resetting the viewport to "find a good
// view", resetting the active creation tool), nor the UI-panel/menu
// refresh load_project() also does on top of that: Open/Fetch swaps in
// a whole different project (new settings, a viewport that may now be
// looking at nothing), so UI_rollout/WORLD/STUDY/UI_menuBar/UI_toolBar/
// UI_caseBar/the viewport title all genuinely need telling to redraw
// themselves from scratch; an undo/redo step changes neither of those
// panels' own settings (WORLD/STUDY, the active camera) nor anything
// menu/toolbar-level, so there is nothing stale in them for a
// revise()/modify_Viewport_Title() call to fix - the one thing an
// undo/redo step does change beyond the geometry itself is the
// selection (Select3D.from_XML(), restored above), and that already
// has its own dedicated refresh path (clampSelectionsToCurrentData()
// below, same as it always has). invalidateWin3DRetainedCaches() below
// is what makes the 3D viewport itself pick up the restored geometry.
// Safe to call from undo()/redo() only because of isRestoringScene3DSnapshot
// below - see its own comment: restoreScene3DSnapshot() does reach
// beginScene3DChange()/endScene3DChange() repeatedly (via several classes'
// from_XML() -> makeEmpty()), and without that guard each of those
// would recursively record itself as a new step.
void restoreProjectScene3DSnapshot (XML xml) {
  // isRestoringScene3DSnapshot (set for the entire call, including every
  // from_XML() restoreScene3DSnapshot() below reaches) is what makes this
  // safe to call at all - see that field's own comment. try/finally so
  // it can't get stuck "true" and silently disable all future undo/redo
  // recording if something throws partway through a restore.
  isRestoringScene3DSnapshot = true;
  try {
    restoreScene3DSnapshot(xml);

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
    // directly rather than endScene3DChange() itself - a restore isn't a
    // new edit to record, so it must not also go through
    // commitUndoableScene3DEdit() (doubly so now, given isRestoringScene3DSnapshot
    // would block it anyway - this keeps the cache invalidation itself
    // unconditional regardless).
    invalidateWin3DRetainedCaches();

    find_which_bakings_to_regenerate();
    VertexSolar_resize_array();
    GlobalSolar_resize_array();
  } finally {
    isRestoringScene3DSnapshot = false;
  }
}
