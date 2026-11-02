// Undo/Redo pipeline.
//
// This is deliberately just the entry point for now. The Ctrl+Z /
// Ctrl+Shift+Z shortcut (solarchvision_bim.pde's keyPressed()) and the
// "Undo"/"Redo" actions (actions.pde) both already route here, but
// undo()/redo() don't yet have anything to actually undo or redo - what
// gets remembered per step, and how, is still an open design question:
// full project-style snapshots the way holdProject()/fetchProject()
// already do, per-field mementos the way putValueAction() already
// captures oldValue/newValue inline, per-object commands, or some mix -
// and is intentionally not decided here.
//
// These stubs exist so the shortcut and the actions are both already
// wired end to end, and so a keypress gives honest, visible feedback
// (echoed to the console, same as every other action) rather than
// silently doing nothing until the storage layer exists.

void undo () {
  displayDirective("Undo: nothing to undo yet (the undo/redo pipeline isn't implemented).");
}

void redo () {
  displayDirective("Redo: nothing to redo yet (the undo/redo pipeline isn't implemented).");
}
