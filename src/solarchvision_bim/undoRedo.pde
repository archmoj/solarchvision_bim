// Undo/Redo pipeline - step two: the in-memory snapshot stack itself.
//
// Builds on buildProjectSnapshot() (saveProject.pde) and
// parse_XML_variables() (parseXmlVariables.pde) - the exact same
// full-state XML this app already builds for Save and Hold/Fetch, kept
// here as XML objects in memory instead of ever touching disk.
//
// Deliberately NOT reusing holdProject()/fetchProject() as-is: those
// write an actual file (saveXML()/loadXML()), and Terrain.to_XML()'s
// "copy every texture alongside the file being written" behavior (see
// land3D.pde's own comment on copyTexturesAlongside) only makes sense
// for a real file someone might move or share - not a snapshot that
// only ever needs to exist for the next few Ctrl+Z/Ctrl+Shift+Z presses.
// buildProjectSnapshot(false) skips that part entirely.
//
// Deliberately NOT reusing load_project() to restore a snapshot either:
// load_project() does a lot more than restore state from XML - it also
// re-reads climate/weather files and unconditionally reallocates their
// (sizable) arrays (update_station(1..4)), resets the viewport to "find
// a good view of the whole scene" (WORLD.autoView / FindGoodViewport() /
// update_frame_layout()), and resets the active creation tool
// (UI_setTo_Create_Nothing()) - all correct and wanted when opening a
// different file, all wrong for undoing one edit: nobody expects
// Ctrl+Z to also recentre their camera, refetch weather data over the
// network, or cancel whatever they were about to place. restoreProjectSnapshot()
// below calls parse_XML_variables() directly - the same from_XML()
// dispatch load_project() itself goes through - then only the cheap,
// state-size-dependent refresh load_project() also does afterward
// (resizing the solar arrays, flagging stale bakes/impact images,
// redrawing every view) - never the heavier parts above it.
//
// What's still NOT decided here, on purpose: WHEN a snapshot gets
// pushed. Nothing currently calls pushUndoSnapshot() - that's a real
// design question of its own (every putAction dispatch? every committed
// putValueAction change, and what counts as "committed" while a spinner
// is being dragged? excluding camera/navigation actions, the way most
// 3D/CAD tools do? excluding Undo/Redo themselves, obviously?) and
// deserves to be worked out as its own step rather than guessed at
// here. For now: Ctrl+Z/Ctrl+Shift+Z and the "Undo"/"Redo" actions are
// real, pushUndoSnapshot() is ready to be called, and undo()/redo()
// will correctly restore whatever was last pushed - but nothing pushes
// yet, so the stack stays empty (and says so) until that next step.

final int MAX_UNDO_STEPS = 50; // bounds memory growth - each snapshot is a full scene-graph XML tree

ArrayList<XML> undoStack = new ArrayList<XML>();
ArrayList<XML> redoStack = new ArrayList<XML>();

// Captures the current state and pushes it as the next undo step,
// clearing the redo stack - the standard rule that a fresh edit after
// an undo discards whatever "future" that undo had uncovered, since
// redoing past a brand-new edit would mean redoing into a timeline that
// no longer exists. Not yet called from anywhere - see this file's own
// header comment.
void pushUndoSnapshot () {
  undoStack.add(buildProjectSnapshot(false));

  if (undoStack.size() > MAX_UNDO_STEPS) {
    undoStack.remove(0);
  }

  redoStack.clear();
}

void undo () {
  if (undoStack.isEmpty()) {
    displayDirective("Undo: nothing to undo.");
    return;
  }

  // Capture where we are now, so Redo can come back to exactly this,
  // before it gets overwritten by the restore below.
  redoStack.add(buildProjectSnapshot(false));

  XML snapshot = undoStack.remove(undoStack.size() - 1);
  restoreProjectSnapshot(snapshot);
}

void redo () {
  if (redoStack.isEmpty()) {
    displayDirective("Redo: nothing to redo.");
    return;
  }

  // Symmetric with undo() above: capture where we are now, so a later
  // Undo can come back to exactly this.
  undoStack.add(buildProjectSnapshot(false));

  XML snapshot = redoStack.remove(redoStack.size() - 1);
  restoreProjectSnapshot(snapshot);
}

// The lean counterpart to load_project(): runs the same from_XML()
// dispatch (parse_XML_variables(), shared with Open/Fetch) plus only
// the cheap, state-size-dependent refresh that has to happen whenever
// the scene graph's shape changes (vertex/face/day-range counts feeding
// into the solar arrays' dimensions, stale bake/impact-image flags,
// redrawing every view) - never the file-open-specific work
// load_project() does on top of that. See this file's own header
// comment for the full reasoning on why those two are kept apart.
void restoreProjectSnapshot (XML xml) {
  parse_XML_variables(xml, false);

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
