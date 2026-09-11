void mouseDragged() {
  if (frameCount <= Last_initializationStep) return;
  if (SOLARCHVISION_automated != 0) return;

  if (FRAME_drag_IMG) {
    startFrameDragIfNeeded();
  } else if (WIN3D.include) {
    handleWin3DDrag();
  }
}

// Begins a 2D marquee drag the first time we see movement.
void startFrameDragIfNeeded() {
  if (dragging_started != 0) return;
  SOLARCHVISION_X_click1 = pmouseX;
  SOLARCHVISION_Y_click1 = pmouseY;
  dragging_started = 1;
}

void handleWin3DDrag() {
  boolean wasInside = isInside(pmouseX, pmouseY, WIN3D.cX, WIN3D.cY, WIN3D.cX + WIN3D.dX, WIN3D.cY + WIN3D.dY);
  boolean isNowInside = isInside(mouseX, mouseY, WIN3D.cX, WIN3D.cY, WIN3D.cX + WIN3D.dX, WIN3D.cY + WIN3D.dY);
  if (!wasInside || !isNowInside) return;

  if (dragging_started == 0) {
    SOLARCHVISION_X_click1 = pmouseX;
    SOLARCHVISION_Y_click1 = pmouseY;
    dragging_started = 1;
  }

  float dx = (mouseX - pmouseX) / float(WIN3D.dX);
  float dy = (mouseY - pmouseY) / float(WIN3D.dY);

  dispatchWin3DTaskDrag(dx, dy);
}

void dispatchWin3DTaskDrag(float dx, float dy) {
  if (WIN3D.UI_CurrentTask == UITASK.LandOrbit_Pan_TargetRollZ) {
    if (mouseButton == LEFT) rotateCameraAroundLand(dx);   // CameraLandOrbit
    if (mouseButton == RIGHT) panBothAxes(dx, dy);          // Pan
  }

  if (WIN3D.UI_CurrentTask == UITASK.PanX_TargetRoll) {
    if (mouseButton == LEFT) panXAxis(dx);
    if (mouseButton == RIGHT) panYAxis(dy);
  }

  if (WIN3D.UI_CurrentTask == UITASK.PanY_TargetRoll) {
    if (mouseButton == LEFT) panYAxis(dy);
    if (mouseButton == RIGHT) panXAxis(dx);
  }

  if ((WIN3D.UI_CurrentTask == UITASK.Pan_TargetRoll) ||
      (WIN3D.UI_CurrentTask == UITASK.DistMouseXY_TargetRollXY_TargetRollZ) ||
      (WIN3D.UI_CurrentTask == UITASK.PickSelect)) {
    if (mouseButton == LEFT) panBothAxes(dx, dy);
    if (mouseButton == RIGHT) rotateTargetXY(dx, dy);       // TargetRoll
  }

  if ((WIN3D.UI_CurrentTask == UITASK.CameraRoll_Pan) ||
      (WIN3D.UI_CurrentTask == UITASK.CameraDistance_TargetRollXY_TargetRollZ)) {
    if (mouseButton == LEFT) rotateCameraBoth(dx, dy);      // CameraRoll (XY + Z together)
    if (mouseButton == RIGHT) panBothAxes(dx, dy);          // Pan
  }

  if (WIN3D.UI_CurrentTask == UITASK.CameraRollXY_CameraRollZ) {
    if (mouseButton == LEFT) rotateCameraXY(dx);
    if (mouseButton == RIGHT) rotateCameraZ(dy);
  }

  if (WIN3D.UI_CurrentTask == UITASK.TargetRoll_Pan) {
    if (mouseButton == LEFT) rotateTargetXY(dx, dy);        // TargetRoll
    if (mouseButton == RIGHT) panBothAxes(dx, dy);          // Pan
  }

  if (WIN3D.UI_CurrentTask == UITASK.TargetRollXY_TargetRollZ) {
    // Which axis moves depends on both the button held and
    // UI_OptionXorY, per the original's combined conditions.
    boolean doTargetRollXY = (mouseButton == LEFT && WIN3D.UI_OptionXorY == 1) ||
                              (mouseButton == RIGHT && WIN3D.UI_OptionXorY == 0);
    boolean doTargetRollZ = (mouseButton == LEFT && WIN3D.UI_OptionXorY == 0) ||
                             (mouseButton == RIGHT && WIN3D.UI_OptionXorY == 1);

    if (doTargetRollXY) rotateTargetZOnly(dx); // named "TargetRollXY" in the original UI task
    if (doTargetRollZ) rotateTargetXOnly(dy);  // named "TargetRollZ" in the original UI task
  }

  if ((WIN3D.UI_CurrentTask == UITASK.Zoom_Orbit_Pan) ||
      (WIN3D.UI_CurrentTask == UITASK.SkydomeSize) ||
      (WIN3D.UI_CurrentTask == UITASK.AllModelSize)) {
    if (mouseButton == LEFT) orbitCamera(dx, dy);
    if (mouseButton == RIGHT) panBothAxes(dx, dy);
  }

  if (WIN3D.UI_CurrentTask == UITASK.Pan_Height) {
    if (mouseButton == LEFT) panYAxis(dy);   // move Y
    if (mouseButton == RIGHT) panXAxis(dx);  // move X
  }

  if (WIN3D.UI_CurrentTask == UITASK.ModelSize_Pan_TargetRoll) {
    if (mouseButton == LEFT) panBothAxes(dx, dy);
    if (mouseButton == RIGHT) rotateTargetXY(dx, dy);
  }

  if (WIN3D.UI_CurrentTask == UITASK.Truck_Orbit) {
    handleTruckOrbitTask(dx, dy);
  }
}

void panBothAxes(float dx, float dy) {
  WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;
  WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;
  SOLARCHVISION_view_changed();
}

void panXAxis(float dx) {
  WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;
  SOLARCHVISION_view_changed();
}

void panYAxis(float dy) {
  WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;
  SOLARCHVISION_view_changed();
}

void rotateTargetXY(float dx, float dy) {
  WIN3D.rotation_Z += 10 * dx * WIN3D.rotation_T;
  WIN3D.rotation_X += 10 * dy * WIN3D.rotation_T;
  WIN3D.reverseTransform_3DViewport();
  SOLARCHVISION_view_changed();
}

void rotateTargetZOnly(float dx) {
  WIN3D.rotation_Z += 10 * dx * WIN3D.rotation_T;
  WIN3D.reverseTransform_3DViewport();
  SOLARCHVISION_view_changed();
}

void rotateTargetXOnly(float dy) {
  WIN3D.rotation_X += 10 * dy * WIN3D.rotation_T;
  WIN3D.reverseTransform_3DViewport();
  SOLARCHVISION_view_changed();
}

void rotateCameraXY(float dx) {
  WIN3D.rotateXY_3DViewport_around_Selection(-10 * dx * WIN3D.rotation_T);
  SOLARCHVISION_view_changed();
}

void rotateCameraZ(float dy) {
  WIN3D.rotateZ_3DViewport_around_Selection(-10 * dy * WIN3D.rotation_T);
  SOLARCHVISION_view_changed();
}

void rotateCameraBoth(float dx, float dy) {
  WIN3D.rotateXY_3DViewport_around_Selection(-10 * dx * WIN3D.rotation_T);
  WIN3D.rotateZ_3DViewport_around_Selection(-10 * dy * WIN3D.rotation_T);
  SOLARCHVISION_view_changed();
}

void rotateCameraAroundLand(float dx) {
  WIN3D.rotateXY_3DViewport_around_LandIntersection(10 * dx * WIN3D.rotation_T);
  SOLARCHVISION_view_changed();
}

void orbitCamera(float dx, float dy) {
  WIN3D.rotation_Z -= 10 * dx * WIN3D.rotation_T;
  WIN3D.rotation_X -= 10 * dy * WIN3D.rotation_T;
  SOLARCHVISION_view_changed();
}

void orbitXOnly(float dy) {
  WIN3D.rotation_X -= 10 * dy * WIN3D.rotation_T;
  SOLARCHVISION_view_changed();
}

void orbitZOnly(float dx) {
  WIN3D.rotation_Z -= 10 * dx * WIN3D.rotation_T;
  SOLARCHVISION_view_changed();
}

void handleTruckOrbitTask(float dx, float dy) {
  if (WIN3D.UI_TaskModifyParameter == 0) { // Truck (pan)
    if (WIN3D.UI_OptionXorY == 0) {
      if (mouseButton == LEFT) panXAxis(dx);
      if (mouseButton == RIGHT) panYAxis(dy);
    }
    if (WIN3D.UI_OptionXorY == 1) {
      if (mouseButton == RIGHT) panXAxis(dx);
      if (mouseButton == LEFT) panYAxis(dy);
    }
  }

  if (WIN3D.UI_TaskModifyParameter == 1) { // Orbit
    if (WIN3D.UI_OptionXorY == 0) {
      if (mouseButton == LEFT) orbitXOnly(dy);
      if (mouseButton == RIGHT) orbitZOnly(dx);
    }
    if (WIN3D.UI_OptionXorY == 1) {
      if (mouseButton == RIGHT) orbitXOnly(dy);
      if (mouseButton == LEFT) orbitZOnly(dx);
    }
  }
}
