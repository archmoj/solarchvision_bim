void mouseDragged() {
  if (frameCount <= Last_initializationStep) return;
  if (control != USER_GUI) return;

  if (FRAME_drag_IMG) {
    startFrameDragIfNeeded();
    return;
  }

  // Dragging the picker list's scrollbar thumb takes priority: if this
  // drag gesture is grabbing (or already grabbed) the thumb, don't also
  // let WORLD interpret the same drag as panning the map.
  if (handlePickListScrollDrag()) return;

  // Not mutually exclusive: both handlers internally gate on whether the
  // mouse is actually within their own view's rectangle, so a drag over
  // WORLD still reaches handleWorldDrag() even when WIN3D.include is also
  // true (previously this was an else-if chain, so handleWorldDrag()
  // could never run whenever WIN3D happened to be included).
  if (WIN3D.include) {
    handleWin3DDrag();
  }

  if (WORLD.include) {
    handleWorldDrag();
  }
}

// Begins a 2D marquee drag the first time we see movement.
void startFrameDragIfNeeded() {
  if (dragging_started != 0) return;
  X_click1 = pmouseX;
  Y_click1 = pmouseY;
  dragging_started = 1;
}

void handleWin3DDrag() {
  boolean wasInside = isInside(pmouseX, pmouseY, WIN3D.cX, WIN3D.cY, WIN3D.cX + WIN3D.dX, WIN3D.cY + WIN3D.dY);
  boolean isNowInside = isInside(mouseX, mouseY, WIN3D.cX, WIN3D.cY, WIN3D.cX + WIN3D.dX, WIN3D.cY + WIN3D.dY);
  if (!wasInside || !isNowInside) return;

  if (dragging_started == 0) {
    X_click1 = pmouseX;
    Y_click1 = pmouseY;
    dragging_started = 1;
  }

  float dx = (mouseX - pmouseX) / float(WIN3D.dX);
  float dy = (mouseY - pmouseY) / float(WIN3D.dY);

  dispatchWin3DTaskDrag(dx, dy);
}

// Pans WORLD's centered/tiled view (Zoom > 2 - see drawZoomedTiles) by
// dragging: the map moves with the cursor, same as handleWin3DDrag()'s
// panBothAxes() convention for the 3D viewport.
void handleWorldDrag() {
  if (WORLD.zoom <= 2) return; // Zoom 1, 2, and the "L" catch-all aren't panned

  boolean wasInside = isInside(pmouseX, pmouseY, WORLD.cX, WORLD.cY, WORLD.cX + WORLD.dX, WORLD.cY + WORLD.dY);
  boolean isNowInside = isInside(mouseX, mouseY, WORLD.cX, WORLD.cY, WORLD.cX + WORLD.dX, WORLD.cY + WORLD.dY);
  if (!wasInside || !isNowInside) return;

  if (dragging_started == 0) {
    X_click1 = pmouseX;
    Y_click1 = pmouseY;
    dragging_started = 1;
  }

  float dxPixels = mouseX - pmouseX;
  float dyPixels = mouseY - pmouseY;

  // Degrees-per-pixel at the current zoom, derived from projX/projY's
  // own lon/lat -> pixel mapping (dX/dY canvas size, sX/sY fraction of
  // the full 360°/180° world shown).
  float lonPerPixel = (360.0 * WORLD.sX) / WORLD.dX;
  float latPerPixel = (180.0 * WORLD.sY) / WORLD.dY;

  WORLD.panOffsetLon -= dxPixels * lonPerPixel;
  WORLD.panOffsetLat += dyPixels * latPerPixel; // screen Y grows downward, latitude grows upward

  WORLD.revise();
}

void dispatchWin3DTaskDrag(float dx, float dy) {
  if (WIN3D.currentTool == UITASK.TerrainOrbit_Pan_TargetRollZ) {
    if (mouseButton == LEFT) rotateCameraAroundLand(dx);   // CameraTerrainOrbit
    if (mouseButton == RIGHT) panBothAxes(dx, dy);          // Pan
  }

  if (WIN3D.currentTool == UITASK.PanX_TargetRoll) {
    if (mouseButton == LEFT) panXAxis(dx);
    if (mouseButton == RIGHT) panYAxis(dy);
  }

  if (WIN3D.currentTool == UITASK.PanY_TargetRoll) {
    if (mouseButton == LEFT) panYAxis(dy);
    if (mouseButton == RIGHT) panXAxis(dx);
  }

  if ((WIN3D.currentTool == UITASK.Pan_TargetRoll) ||
      (WIN3D.currentTool == UITASK.DistMouseXY_TargetRollXY_TargetRollZ) ||
      (WIN3D.currentTool == UITASK.PickSelect)) {
    if (mouseButton == LEFT) panBothAxes(dx, dy);
    if (mouseButton == RIGHT) rotateTargetXY(dx, dy);       // TargetRoll
  }

  if ((WIN3D.currentTool == UITASK.CameraRoll_Pan) ||
      (WIN3D.currentTool == UITASK.CameraDistance_TargetRollXY_TargetRollZ)) {
    if (mouseButton == LEFT) rotateCameraBoth(dx, dy);      // CameraRoll (XY + Z together)
    if (mouseButton == RIGHT) panBothAxes(dx, dy);          // Pan
  }

  if (WIN3D.currentTool == UITASK.CameraRollXY_CameraRollZ) {
    if (mouseButton == LEFT) rotateCameraXY(dx);
    if (mouseButton == RIGHT) rotateCameraZ(dy);
  }

  if (WIN3D.currentTool == UITASK.TargetRoll_Pan) {
    if (mouseButton == LEFT) rotateTargetXY(dx, dy);        // TargetRoll
    if (mouseButton == RIGHT) panBothAxes(dx, dy);          // Pan
  }

  if (WIN3D.currentTool == UITASK.TargetRollXY_TargetRollZ) {
    // Which axis moves depends on both the button held and
    // targetAxisIndex, per the original's combined conditions.
    boolean doTargetRollXY = (mouseButton == LEFT && WIN3D.targetAxisIndex == 1) ||
                              (mouseButton == RIGHT && WIN3D.targetAxisIndex == 0);
    boolean doTargetRollZ = (mouseButton == LEFT && WIN3D.targetAxisIndex == 0) ||
                             (mouseButton == RIGHT && WIN3D.targetAxisIndex == 1);

    if (doTargetRollXY) rotateTargetZOnly(dx); // named "TargetRollXY" in the original UI task
    if (doTargetRollZ) rotateTargetXOnly(dy);  // named "TargetRollZ" in the original UI task
  }

  if ((WIN3D.currentTool == UITASK.zoom_Orbit_Pan) ||
      (WIN3D.currentTool == UITASK.SkydomeSize) ||
      (WIN3D.currentTool == UITASK.AllModelSize)) {
    if (mouseButton == LEFT) orbitCamera(dx, dy);
    if (mouseButton == RIGHT) panBothAxes(dx, dy);
  }

  if (WIN3D.currentTool == UITASK.Pan_Height) {
    if (mouseButton == LEFT) panYAxis(dy);   // move Y
    if (mouseButton == RIGHT) panXAxis(dx);  // move X
  }

  if (WIN3D.currentTool == UITASK.ModelSize_Pan_TargetRoll) {
    if (mouseButton == LEFT) panBothAxes(dx, dy);
    if (mouseButton == RIGHT) rotateTargetXY(dx, dy);
  }

  if (WIN3D.currentTool == UITASK.Truck_Orbit) {
    handleTruckOrbitTask(dx, dy);
  }
}

// Each of these now just builds the matching "Drag ..." command string
// and routes through runScriptLine - see actions.pde's own comment on
// the thirteen putDragAction1/putDragAction2 registrations for why
// (same "develop the public API, not the internal calls" reasoning as
// mouseClicked.pde's own UITASK.Create block) and the naming/collision
// notes. Function names/signatures kept exactly as they were so
// dispatchWin3DTaskDrag() and handleTruckOrbitTask() below needed no
// changes at their own call sites - only what each function's body does
// changed.

void panBothAxes(float dx, float dy) {
  runScriptLine("DragPanView dx=" + dx + " dy=" + dy);
}

void panXAxis(float dx) {
  runScriptLine("DragPanViewX dx=" + dx);
}

void panYAxis(float dy) {
  runScriptLine("DragPanViewY dy=" + dy);
}

void rotateTargetXY(float dx, float dy) {
  runScriptLine("DragTurnTarget dx=" + dx + " dy=" + dy);
}

void rotateTargetZOnly(float dx) {
  runScriptLine("DragTurnTargetZ dx=" + dx);
}

void rotateTargetXOnly(float dy) {
  runScriptLine("DragTurnTargetX dy=" + dy);
}

void rotateCameraXY(float dx) {
  runScriptLine("DragOrbitSelectionXY dx=" + dx);
}

void rotateCameraZ(float dy) {
  runScriptLine("DragOrbitSelectionZ dy=" + dy);
}

void rotateCameraBoth(float dx, float dy) {
  runScriptLine("DragOrbitSelection dx=" + dx + " dy=" + dy);
}

void rotateCameraAroundLand(float dx) {
  runScriptLine("DragOrbitLand dx=" + dx);
}

void orbitCamera(float dx, float dy) {
  runScriptLine("DragTurnView dx=" + dx + " dy=" + dy);
}

void orbitXOnly(float dy) {
  runScriptLine("DragTurnViewX dy=" + dy);
}

void orbitZOnly(float dx) {
  runScriptLine("DragTurnViewZ dx=" + dx);
}

void handleTruckOrbitTask(float dx, float dy) {
  if (WIN3D.toolParameterModifier == 0) { // Truck (pan)
    if (WIN3D.targetAxisIndex == 0) {
      if (mouseButton == LEFT) panXAxis(dx);
      if (mouseButton == RIGHT) panYAxis(dy);
    }
    if (WIN3D.targetAxisIndex == 1) {
      if (mouseButton == RIGHT) panXAxis(dx);
      if (mouseButton == LEFT) panYAxis(dy);
    }
  }

  if (WIN3D.toolParameterModifier == 1) { // Orbit
    if (WIN3D.targetAxisIndex == 0) {
      if (mouseButton == LEFT) orbitXOnly(dy);
      if (mouseButton == RIGHT) orbitZOnly(dx);
    }
    if (WIN3D.targetAxisIndex == 1) {
      if (mouseButton == RIGHT) orbitXOnly(dy);
      if (mouseButton == LEFT) orbitZOnly(dx);
    }
  }
}
