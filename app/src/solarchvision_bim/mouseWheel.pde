void mouseWheel(MouseEvent event) {
  if (frameCount <= Last_initializationStep) return;
  if (UI_menuBar.selected_parent != -1) return;

  // Wheel events arrive in pairs on some platforms;
  // only act on every second one
  mouseWheelConsume += 1;
  if (mouseWheelConsume % 2 != 0) return;
  mouseWheelConsume = 0;

  float Wheel_Value = event.getCount();
  if (control != USER_GUI) return;

  X_clicked = mouseX;
  Y_clicked = mouseY;

  handleCaseBarWheel(Wheel_Value);
  if (!handlePickListWheel(Wheel_Value)) {
    handleWorldZoomWheel(Wheel_Value);
  }
  handleWin3DWheel(Wheel_Value);
}


void handleCaseBarWheel(float wheelValue) {
  float displayBarHeight = MessageSize;
  float displayBarWidth = 2 * pixel_W;

  X_control = 0.5 * displayBarWidth;
  Y_control = pixel_A + pixel_B + 2 * pixel_H + 0.5 * UI_caseBar.tab;

  for (int i = 0; i < UI_caseBar.Items.length; i++) {
    float x1 = X_control - 0.366 * displayBarWidth;
    float x2 = X_control + 0.5 * displayBarWidth;
    float y1 = Y_control - 0.45 * displayBarHeight;
    float y2 = Y_control + 0.45 * displayBarHeight;

    if (isInside(X_clicked, Y_clicked, x1, y1, x2, y2)) {
      if (UI_caseBar.Items[i][0].equals("Hours")) {
        handleHoursCaseBarWheel(wheelValue);
      } else if (UI_caseBar.Items[i][0].equals("Days")) {
        handleDaysCaseBarWheel(wheelValue);
      } else if (UI_caseBar.Items[i][0].equals("Scenario")) {
        handleScenarioCaseBarWheel(wheelValue);
      }
    }

    Y_control += UI_caseBar.tab;
  }
}

void reviseStudyAndRegenerate(boolean alsoWorld) {
  UI_rollout.revise();
  STUDY.revise();
  if (alsoWorld) WORLD.revise();
  UI_caseBar.revise();
  view_changed();
  find_which_bakings_to_regenerate();
}

void handleHoursCaseBarWheel(float wheelValue) {
  runScriptLine("WheelHours " + wheelValue);
}

void handleDaysCaseBarWheel(float wheelValue) {
  runScriptLine("WheelDays " + wheelValue);
}

int[] shiftAndClampRange(int start, int end, float wheelValue, int lo, int hi) {
  if (wheelValue > 0) {
    start += 1;
    end += 1;
  }
  if (wheelValue < 0) {
    start -= 1;
    end -= 1;
  }

  if (end < start) end = start;
  if (start > end) start = end;

  if (start < lo) start = lo;
  if (start > hi) start = hi;
  if (end < lo) end = lo;
  if (end > hi) end = hi;

  return new int[] { start, end };
}

void handleScenarioCaseBarWheel(float wheelValue) {
  runScriptLine("WheelScenario " + wheelValue);
}


void handleWorldZoomWheel(float wheelValue) {
  if (!WORLD.include) return;
  if (!isInside(X_clicked, Y_clicked, WORLD.cX, WORLD.cY, WORLD.cX + WORLD.dX, WORLD.cY + WORLD.dY)) return;

  runScriptLine("WheelWorldZoom " + wheelValue);
}


void handleWin3DWheel(float wheelValue) {
  if (!WIN3D.include) return;
  if (!isInside(X_clicked, Y_clicked, WIN3D.cX, WIN3D.cY, WIN3D.cX + WIN3D.dX, WIN3D.cY + WIN3D.dY)) return;

  float[] pivot = Select3D.getPivot();
  float x0 = pivot[0];
  float y0 = pivot[1];
  float z0 = pivot[2];

  handleObjectEditWheel(wheelValue, x0, y0, z0);
  handleViewportWheel(wheelValue);
}


void handleObjectEditWheel(float wheelValue, float x0, float y0, float z0) {
  if (WIN3D.currentTool == UITASK.Rotate) {
    handleRotateWheel(wheelValue, x0, y0, z0);
  }
  if (WIN3D.currentTool == UITASK.Scale) {
    handleScaleWheel(wheelValue, x0, y0, z0);
  }
  if (WIN3D.currentTool == UITASK.Move) {
    handleMoveWheel(wheelValue);
  }
  if (WIN3D.toolParameterModifier == 0) {
    if (WIN3D.currentTool >= UITASK.Seed_Material) { // other properties
      handlePropertyEditWheel(wheelValue);
    }
  }
}

void handleRotateWheel(float wheelValue, float x0, float y0, float z0) {
  runScriptLine("WheelRotateSelection wheelValue=" + wheelValue + " x0=" + x0 + " y0=" + y0 + " z0=" + z0);
}

void handleScaleWheel(float wheelValue, float x0, float y0, float z0) {
  runScriptLine("WheelScaleSelection wheelValue=" + wheelValue + " x0=" + x0 + " y0=" + y0 + " z0=" + z0);
}

void handleMoveWheel(float wheelValue) {
  float d = -wheelValue;

  // Same axis-zeroing-by-Select3D.positionVectorIndex logic as
  // computeMoveDelta (mouseClicked.pde): moving the same
  // distance d on all three axes from the origin, then letting that
  // function zero out whichever axes positionVectorIndex excludes, is exactly
  // equivalent to the dx=dy=dz=d then zero-by-positionVectorIndex this used to do
  // inline.
  //
  // No dedicated Wheel* command here, unlike every other handler in this
  // file: this already builds the exact same (dx,dy,dz) the existing
  // "MOVE" command's own Move3D.selection(dx,dy,dz) call expects, so it
  // reuses that command directly instead of getting its own.
  float[] delta = computeMoveDelta(0, 0, 0, d, d, d);

  runScriptLine("Move dx=" + delta[0] + " dy=" + delta[1] + " dz=" + delta[2]);
}

void handlePropertyEditWheel(float wheelValue) {
  runScriptLine("WheelEditSelection " + wheelValue);
}


void handleViewportWheel(float wheelValue) {
  if ((WIN3D.currentTool == UITASK.zoom_Orbit_Pan) ||
      (WIN3D.currentTool == UITASK.CameraRoll_Pan) ||
      (WIN3D.currentTool == UITASK.TargetRoll_Pan) ||
      (WIN3D.currentTool == UITASK.Pan_TargetRoll)) { // viewport:zoom
    zoomWin3DViewport(wheelValue);
  }

  if (WIN3D.currentTool == UITASK.Pan_Height) { // viewport:elevation
    adjustWin3DElevationWheel(wheelValue);
  }

  if (WIN3D.currentTool == UITASK.ModelSize_Pan_TargetRoll) { // viewport:3DModelSize
    scaleObjectsWheel(wheelValue);
  }

  if (WIN3D.currentTool == UITASK.Truck_Orbit) { // viewport:different functions with wheel
    handleTruckOrbitWheel(wheelValue);
  }

  if (WIN3D.currentTool == UITASK.SkydomeSize) { // viewport:different functions with wheel
    if (WIN3D.toolParameterModifier == 0) { // SkydomeSize
      scaleSkydomeWheel(wheelValue);
    }
  }

  if (WIN3D.currentTool == UITASK.AllModelSize) { // viewport:different functions with wheel
    if (WIN3D.toolParameterModifier == 0) { // AllModelSize
      scaleAllModelWheel(wheelValue);
    }
  }

  if (WIN3D.currentTool == UITASK.TargetRollXY_TargetRollZ) { // viewport:TargetRollXY/TargetRollZ
    handleTargetRollXYZWheel(wheelValue);
  }

  if (WIN3D.currentTool == UITASK.CameraRollXY_CameraRollZ) { // viewport:CameraRollXY/CameraRollZ
    handleCameraRollXYZWheel(wheelValue);
  }

  if (WIN3D.currentTool == UITASK.CameraDistance_TargetRollXY_TargetRollZ) { // viewport:CameraDistance
    moveWin3DTowardsSelection(wheelValue);
  }

  if (WIN3D.currentTool == UITASK.PanX_TargetRoll) { // viewport:PanX
    adjustPositionXWheel(wheelValue);
  }

  if (WIN3D.currentTool == UITASK.PanY_TargetRoll) { // viewport:PanY
    adjustPositionYWheel(wheelValue);
  }

  if ((WIN3D.currentTool == UITASK.DistMouseXY_TargetRollXY_TargetRollZ) ||
      (WIN3D.currentTool == UITASK.PickSelect)) { // viewport:DistMouseXY
    moveWin3DTowardsMouse(wheelValue);
  }

  if (WIN3D.currentTool == UITASK.TerrainOrbit_Pan_TargetRollZ) { // viewport:TerrainOrbit
    moveWin3DTowardsMouse(wheelValue);
  }
}

void zoomWin3DViewport(float wheelValue) {
  runScriptLine("WheelZoomViewport " + wheelValue);
}

void adjustWin3DElevationWheel(float wheelValue) {
  runScriptLine("WheelElevation " + wheelValue);
}

void scaleObjectsWheel(float wheelValue) {
  runScriptLine("WheelScaleObjects " + wheelValue);
}

void scaleSkydomeWheel(float wheelValue) {
  runScriptLine("WheelScaleSkydome " + wheelValue);
}

void scaleAllModelWheel(float wheelValue) {
  runScriptLine("WheelScaleAllModel " + wheelValue);
}

void handleTargetRollXYZWheel(float wheelValue) {
  runScriptLine("WheelTargetRollXYZ " + wheelValue);
}

void handleCameraRollXYZWheel(float wheelValue) {
  runScriptLine("WheelCameraRollXYZ " + wheelValue);
}

void moveWin3DTowardsSelection(float wheelValue) {
  runScriptLine("WheelMoveTowardsSelection " + wheelValue);
}

void moveWin3DTowardsMouse(float wheelValue) {
  runScriptLine("WheelMoveTowardsMouse " + wheelValue);
}

void adjustPositionXWheel(float wheelValue) {
  runScriptLine("WheelPositionX " + wheelValue);
}

void adjustPositionYWheel(float wheelValue) {
  runScriptLine("WheelPositionY " + wheelValue);
}

void adjustRotationXWheel(float wheelValue) {
  runScriptLine("WheelRotationX " + wheelValue);
}

void adjustRotationZWheel(float wheelValue) {
  runScriptLine("WheelRotationZ " + wheelValue);
}

void handleTruckOrbitWheel(float wheelValue) {
  if (WIN3D.toolParameterModifier == 0) { // Truck
    if (WIN3D.targetAxisIndex == 0) adjustPositionXWheel(wheelValue);
    if (WIN3D.targetAxisIndex == 1) adjustPositionYWheel(wheelValue);
  }

  if (WIN3D.toolParameterModifier == 1) { // Orbit
    if (WIN3D.targetAxisIndex == 0) adjustRotationXWheel(wheelValue);
    if (WIN3D.targetAxisIndex == 1) adjustRotationZWheel(wheelValue);
  }
}
