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

// WIN3D's own undo/redo snapshot, plus (see writeVisibilityToggleState()'s
// own comment just below) the "Visibility" menu's Show/Hide display
// toggles and (see writeSelectionDisplayState()'s own comment) the
// "Selection" menu's Show/Hide Selected ... display toggles -
// everything buildScene3DSnapshot()'s own header comment explicitly
// calls out as NOT wired to beginScene3DChange()/endScene3DChange()
// ("toggling what's displayed... those don't call either function and
// don't record a step"). Those toggles used to not record ANY undo step
// at all; they now ride along in this same snapshot/poll pipeline as
// WIN3D's own camera/view fields, so Ctrl+Shift+Z/Ctrl+Shift+Y undo/redo
// them - never Ctrl+Z/Ctrl+Y, which stays scoped to actual model/
// geometry edits. Deliberately still NOT the eleven
// buildScene3DSnapshot() classes themselves, and NOT the per-face/
// per-polyline Visibility VALUE (allFaces/allPolylines.options[.][3],
// set by the Modify menu's Change/Pick/Assign/Reverse Visibility and
// Hide/Unhide Selected Faces/Polylines) - that's real per-face project
// data, potentially thousands of entries, so it stays on the Scene3D
// side (Ctrl+Z), reusing buildOrReuseSubtree()'s already-built sharing
// logic instead of getting duplicated into up to MAX_UNDO_VIEWPORT3D
// snapshots here.
XML buildViewport3DSnapshot () {

  XML xml = parseXML("<?xml version='1.0' encoding='UTF-8'?>" + char(13) + "<empty>" + char(13) + "</empty>");

  xml.setName("solarchvisionV" + version);

  WIN3D.to_XML(xml);
  writeVisibilityToggleState(xml);
  writeSelectionDisplayState(xml);

  return xml;
}

// The ~two dozen plain boolean "what's displayed" flags behind the
// "Visibility" menu (uiMenuBar.pde's PARENT_VISIBILITY block) and their
// matching actions (actions.pde's "Show/Hide ..." putAction() calls) -
// one attribute each, on their own child element so a project's actual
// WIN3D.to_XML()/from_XML() pair (camera/view only) stays untouched by
// this unrelated set of flags living in the same snapshot. Cheap to
// duplicate into every one of the up to MAX_UNDO_VIEWPORT3D entries -
// two dozen booleans, not per-object data - unlike the per-face/
// per-polyline Visibility VALUE this deliberately excludes (see
// buildViewport3DSnapshot()'s own comment).
void writeVisibilityToggleState (XML parent) {
  XML xml = parent.addChild("visibilityToggles");

  XML_setBoolean(xml, "terrainDisplaySurface", Terrain.displaySurface);
  XML_setBoolean(xml, "terrainDisplayTexture", Terrain.displayTexture);
  XML_setBoolean(xml, "terrainDisplayPoints", Terrain.displayPoints);
  XML_setBoolean(xml, "terrainDisplayDepth", Terrain.displayDepth);
  XML_setBoolean(xml, "pointsDisplayAll", allPoints.displayAll);
  XML_setBoolean(xml, "facesDisplayEdges", allFaces.displayEdges);
  XML_setBoolean(xml, "facesShowNormalLines", allFaces.showNormalLines);
  XML_setBoolean(xml, "model1DsDisplayLeaves", allModel1Ds.displayLeaves);
  XML_setBoolean(xml, "model1DsDisplayAll", allModel1Ds.displayAll);
  XML_setBoolean(xml, "model2DsDisplayAll", allModel2Ds.displayAll);
  XML_setBoolean(xml, "polylinesDisplayAll", allPolylines.displayAll);
  XML_setBoolean(xml, "facesDisplayAll", allFaces.displayAll);
  XML_setBoolean(xml, "solidsDisplayAll", allSolids.displayAll);
  XML_setBoolean(xml, "sectionsDisplayAll", allSections.displayAll);
  XML_setBoolean(xml, "camerasDisplayAll", allCameras.displayAll);
  XML_setBoolean(xml, "skyDisplaySurface", Sky3D.displaySurface);
  XML_setBoolean(xml, "sunDisplayGrid", Sun3D.displayGrid);
  XML_setBoolean(xml, "sunDisplayPath", Sun3D.displayPath);
  XML_setBoolean(xml, "sunDisplayPattern", Sun3D.displayPattern);
  XML_setBoolean(xml, "sunDisplaySurface", Sun3D.displaySurface);
  XML_setBoolean(xml, "moonDisplaySurface", Moon3D.displaySurface);
  XML_setBoolean(xml, "earthDisplaySurface", Earth3D.displaySurface);
  XML_setBoolean(xml, "tropoDisplaySurface", Tropo3D.displaySurface);
  XML_setBoolean(xml, "solarImpactsDisplayImage", allSolarImpacts.displayImage);
  XML_setBoolean(xml, "solidImpactsDisplayImage", allSolidImpacts.displayImage);
  XML_setBoolean(xml, "windFlowDisplayAll", allWindFlows.displayAll);
}

// The from_XML() counterpart to writeVisibilityToggleState() above - see
// that function's own comment. Reads back the same "visibilityToggles"
// child restoreViewport3DSnapshot() (below) looks for; a snapshot built
// before this child existed (there shouldn't be one - this is an
// in-memory-only history, never written to a project file - but just in
// case) leaves every flag at whatever it already was, rather than
// forcing them all to XML_getBoolean()'s own missing-attribute default
// of false.
void readVisibilityToggleState (XML parent) {
  XML xml = parent.getChild("visibilityToggles");
  if (xml == null) return;

  Terrain.displaySurface = XML_getBoolean(xml, "terrainDisplaySurface");
  Terrain.displayTexture = XML_getBoolean(xml, "terrainDisplayTexture");
  Terrain.displayPoints = XML_getBoolean(xml, "terrainDisplayPoints");
  Terrain.displayDepth = XML_getBoolean(xml, "terrainDisplayDepth");
  allPoints.displayAll = XML_getBoolean(xml, "pointsDisplayAll");
  allFaces.displayEdges = XML_getBoolean(xml, "facesDisplayEdges");
  allFaces.showNormalLines = XML_getBoolean(xml, "facesShowNormalLines");
  allModel1Ds.displayLeaves = XML_getBoolean(xml, "model1DsDisplayLeaves");
  allModel1Ds.displayAll = XML_getBoolean(xml, "model1DsDisplayAll");
  allModel2Ds.displayAll = XML_getBoolean(xml, "model2DsDisplayAll");
  allPolylines.displayAll = XML_getBoolean(xml, "polylinesDisplayAll");
  allFaces.displayAll = XML_getBoolean(xml, "facesDisplayAll");
  allSolids.displayAll = XML_getBoolean(xml, "solidsDisplayAll");
  allSections.displayAll = XML_getBoolean(xml, "sectionsDisplayAll");
  allCameras.displayAll = XML_getBoolean(xml, "camerasDisplayAll");
  Sky3D.displaySurface = XML_getBoolean(xml, "skyDisplaySurface");
  Sun3D.displayGrid = XML_getBoolean(xml, "sunDisplayGrid");
  Sun3D.displayPath = XML_getBoolean(xml, "sunDisplayPath");
  Sun3D.displayPattern = XML_getBoolean(xml, "sunDisplayPattern");
  Sun3D.displaySurface = XML_getBoolean(xml, "sunDisplaySurface");
  Moon3D.displaySurface = XML_getBoolean(xml, "moonDisplaySurface");
  Earth3D.displaySurface = XML_getBoolean(xml, "earthDisplaySurface");
  Tropo3D.displaySurface = XML_getBoolean(xml, "tropoDisplaySurface");
  allSolarImpacts.displayImage = XML_getBoolean(xml, "solarImpactsDisplayImage");
  allSolidImpacts.displayImage = XML_getBoolean(xml, "solidImpactsDisplayImage");
  allWindFlows.displayAll = XML_getBoolean(xml, "windFlowDisplayAll");
}

// The 16 plain boolean "what's displayed" flags behind the "Selection"
// menu's Show/Hide Selected ... items (uiMenuBar.pde's PARENT_SELECTION
// block) - Select3D's own display fields, as opposed to its selection-
// set fields (faceSelection, model1DSelection, etc.), which stay out of
// this and keep being tracked only via Select3D's inclusion in
// buildScene3DSnapshot()'s eleven classes, same as before.
//
// Select3D.to_XML()/from_XML() (select3D.pde) already writes these same
// 16 flags too - it's both one of buildScene3DSnapshot()'s eleven
// classes AND the actual project-file format (saveProject.pde/
// parseXmlVariables.pde), and removing them from it would silently stop
// persisting these display preferences across Save/Open. So this is
// deliberately additive, not a replacement: the live fields now have two
// readers/writers, exactly like Terrain's own four flags above (Terrain
// is simultaneously one of buildScene3DSnapshot()'s eleven classes and a
// writeVisibilityToggleState() entry). The trade-off that comes with
// that, same as Terrain's: undoing/redoing far enough back through
// Scene3D's own history (Ctrl+Z/Ctrl+Y) can still incidentally carry one
// of these flags back to whatever it was at that older model edit, as a
// side effect of Select3D being swapped wholesale - buildScene3DSnapshot()'s
// own header comment already documents this class of imprecision
// ("toggling what's displayed... not yet precise for that case") for
// exactly this reason, and this fix doesn't make it any less precise
// than it already was. What's new here is that Ctrl+Shift+Z/Ctrl+Shift+Y
// now gives each toggle its own correct, dedicated undo step, which
// didn't exist at all before.
void writeSelectionDisplayState (XML parent) {
  XML xml = parent.addChild("selectionDisplayToggles");

  XML_setBoolean(xml, "solidDisplayEdges", Select3D.solidDisplayEdges);
  XML_setBoolean(xml, "sectionDisplayEdges", Select3D.sectionDisplayEdges);
  XML_setBoolean(xml, "cameraDisplayFrustum", Select3D.cameraDisplayFrustum);
  XML_setBoolean(xml, "terrainDisplayVertices", Select3D.terrainDisplayVertices);
  XML_setBoolean(xml, "faceDisplayEdges", Select3D.faceDisplayEdges);
  XML_setBoolean(xml, "polylineDisplayVertices", Select3D.polylineDisplayVertices);
  XML_setBoolean(xml, "faceDisplayVertexSelection", Select3D.faceDisplayVertexSelection);
  XML_setBoolean(xml, "polylineDisplayVertexSelection", Select3D.polylineDisplayVertexSelection);
  XML_setBoolean(xml, "vertexDisplayMarkers", Select3D.vertexDisplayMarkers);
  XML_setBoolean(xml, "pivotDisplayReference", Select3D.pivotDisplayReference);
  XML_setBoolean(xml, "groupDisplayPivot", Select3D.groupDisplayPivot);
  XML_setBoolean(xml, "groupDisplayEdges", Select3D.groupDisplayEdges);
  XML_setBoolean(xml, "groupDisplayBox", Select3D.groupDisplayBox);
  XML_setBoolean(xml, "model2DDisplayBounds", Select3D.model2DDisplayBounds);
  XML_setBoolean(xml, "model1DDisplayBounds", Select3D.model1DDisplayBounds);
  XML_setBoolean(xml, "modifierDisplayBoundingBox", Select3D.modifierDisplayBoundingBox);
}

// The from_XML() counterpart to writeSelectionDisplayState() above - see
// that function's own comment. Same "leave it alone if the child is
// missing" fallback as readVisibilityToggleState().
void readSelectionDisplayState (XML parent) {
  XML xml = parent.getChild("selectionDisplayToggles");
  if (xml == null) return;

  Select3D.solidDisplayEdges = XML_getBoolean(xml, "solidDisplayEdges");
  Select3D.sectionDisplayEdges = XML_getBoolean(xml, "sectionDisplayEdges");
  Select3D.cameraDisplayFrustum = XML_getBoolean(xml, "cameraDisplayFrustum");
  Select3D.terrainDisplayVertices = XML_getBoolean(xml, "terrainDisplayVertices");
  Select3D.faceDisplayEdges = XML_getBoolean(xml, "faceDisplayEdges");
  Select3D.polylineDisplayVertices = XML_getBoolean(xml, "polylineDisplayVertices");
  Select3D.faceDisplayVertexSelection = XML_getBoolean(xml, "faceDisplayVertexSelection");
  Select3D.polylineDisplayVertexSelection = XML_getBoolean(xml, "polylineDisplayVertexSelection");
  Select3D.vertexDisplayMarkers = XML_getBoolean(xml, "vertexDisplayMarkers");
  Select3D.pivotDisplayReference = XML_getBoolean(xml, "pivotDisplayReference");
  Select3D.groupDisplayPivot = XML_getBoolean(xml, "groupDisplayPivot");
  Select3D.groupDisplayEdges = XML_getBoolean(xml, "groupDisplayEdges");
  Select3D.groupDisplayBox = XML_getBoolean(xml, "groupDisplayBox");
  Select3D.model2DDisplayBounds = XML_getBoolean(xml, "model2DDisplayBounds");
  Select3D.model1DDisplayBounds = XML_getBoolean(xml, "model1DDisplayBounds");
  Select3D.modifierDisplayBoundingBox = XML_getBoolean(xml, "modifierDisplayBoundingBox");
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

// The from_XML() counterpart to buildViewport3DSnapshot() above -
// WIN3D.from_XML() plus readVisibilityToggleState() and
// readSelectionDisplayState() (see buildViewport3DSnapshot()'s own
// comment for why the latter two ride along in this same snapshot).
void restoreViewport3DSnapshot (XML xml) {
  WIN3D.from_XML(xml);
  readVisibilityToggleState(xml);
  readSelectionDisplayState(xml);
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

    // view_changed() (globalFunctions.pde) calls WIN3D.revise() itself -
    // same redraw every other camera/view change in this codebase
    // triggers - and is also exactly what every live "Show/Hide ..."
    // action (actions.pde) already calls after flipping one of these
    // same flags directly, so a restored toggle redraws the same way a
    // live one does.
    view_changed();
  } finally {
    isRestoringViewport3DSnapshot = false;
  }
}
