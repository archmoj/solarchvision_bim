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
  int oldStart = STUDY.startHour;
  int oldEnd = STUDY.endHour;

  if (wheelValue > 0) {
    STUDY.startHour += 1;
    STUDY.endHour += 1;
  }
  if (wheelValue < 0) {
    STUDY.startHour -= 1;
    STUDY.endHour -= 1;
  }

  if (STUDY.startHour < 0) STUDY.startHour = 23;
  if (STUDY.startHour > 23) STUDY.startHour = 0;
  if (STUDY.endHour < 0) STUDY.endHour = 23;
  if (STUDY.endHour > 23) STUDY.endHour = 0;

  if (oldStart != STUDY.startHour || oldEnd != STUDY.endHour) {
    reviseStudyAndRegenerate(true);
  }
}

void handleDaysCaseBarWheel(float wheelValue) {
  int oldJoinDays = STUDY.daysMergedCount;

  if (wheelValue > 0) STUDY.daysMergedCount += 2;
  if (wheelValue < 0) STUDY.daysMergedCount -= 2;

  if (STUDY.daysMergedCount > 365 / STUDY.endDay) STUDY.daysMergedCount = 365 / STUDY.endDay;
  if (STUDY.daysMergedCount < 1) STUDY.daysMergedCount = 1;

  if (oldJoinDays != STUDY.daysMergedCount) {
    reviseStudyAndRegenerate(false);
  }
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
  if (currentDataSource == dataID_climateEngineering) {
    int[] r = shiftAndClampRange(sampleYearStart, sampleYearEnd, wheelValue, climateEngineeringStart, climateEngineeringEnd);
    if (r[0] != sampleYearStart || r[1] != sampleYearEnd) {
      sampleYearStart = r[0];
      sampleYearEnd = r[1];
      reviseStudyAndRegenerate(false);
    }
  }

  if (currentDataSource == dataID_climateArchive) {
    int[] r = shiftAndClampRange(sampleYearStart, sampleYearEnd, wheelValue, climateArchiveStart, climateArchiveEnd);
    if (r[0] != sampleYearStart || r[1] != sampleYearEnd) {
      sampleYearStart = r[0];
      sampleYearEnd = r[1];
      reviseStudyAndRegenerate(false);
    }
  }

  if (currentDataSource == dataID_ensembleForecast) {
    int[] r = shiftAndClampRange(sampleMemberStart, sampleMemberEnd, wheelValue, ensembleForecastStart, ensembleForecastEnd);
    if (r[0] != sampleMemberStart || r[1] != sampleMemberEnd) {
      sampleMemberStart = r[0];
      sampleMemberEnd = r[1];
      reviseStudyAndRegenerate(false);
    }
  }

  if (currentDataSource == dataID_ensembleObservation) {
    int[] r = shiftAndClampRange(sampleStationStart, sampleStationEnd, wheelValue, ensembleObservationStart, ensembleObservationEnd);
    if (r[0] != sampleStationStart || r[1] != sampleStationEnd) {
      sampleStationStart = r[0];
      sampleStationEnd = r[1];
      reviseStudyAndRegenerate(false);
    }
  }
}


void handleWorldZoomWheel(float wheelValue) {
  if (!WORLD.include) return;
  if (!isInside(X_clicked, Y_clicked, WORLD.cX, WORLD.cY, WORLD.cX + WORLD.dX, WORLD.cY + WORLD.dY)) return;

  int oldZoom = WORLD.zoom;

  if (wheelValue < 0) WORLD.zoom += 1;
  if (wheelValue > 0) WORLD.zoom -= 1;

  if (WORLD.zoom < 1) WORLD.zoom = 1;
  if (WORLD.zoom > 9) WORLD.zoom = 9;

  if (oldZoom != WORLD.zoom) {
    WORLD.VIEW_id = WORLD.FindGoodViewport(LocationLON, LocationLAT);
    WORLD.revise();
  }
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
  float r = 5 * -wheelValue;
  int theVector = Select3D.rotationVectorIndex;
  Rotate3D.selection(x0, y0, z0, r, theVector);
  model_changed();
}

void handleScaleWheel(float wheelValue, float x0, float y0, float z0) {
  float s = pow(pow(2.0, 0.25), -wheelValue);

  float sx = s;
  float sy = s;
  float sz = s;

  int theVector = Select3D.scaleVectorIndex;
  if (theVector == 0) { sy = 1; sz = 1; }
  if (theVector == 1) { sz = 1; sx = 1; }
  if (theVector == 2) { sx = 1; sy = 1; }

  Scale3D.selection(x0, y0, z0, sx, sy, sz);
  model_changed();
}

void handleMoveWheel(float wheelValue) {
  float d = -wheelValue;

  // Same axis-zeroing-by-Select3D.positionVectorIndex logic as
  // computeMoveDelta (mouseClicked.pde): moving the same
  // distance d on all three axes from the origin, then letting that
  // function zero out whichever axes positionVectorIndex excludes, is exactly
  // equivalent to the dx=dy=dz=d then zero-by-positionVectorIndex this used to do
  // inline.
  float[] delta = computeMoveDelta(0, 0, 0, d, d, d);

  Move3D.selection(delta[0], delta[1], delta[2]);
  model_changed();
}

void handlePropertyEditWheel(float wheelValue) {
  int p = int(-wheelValue);
  Edit3D.selection(p);
  model_changed();
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
  if (WIN3D.projectionTypeIndex == 1) {
    WIN3D.positionZ -= wheelValue * WIN3D.positionStep * overallScale;
  } else {
    WIN3D.zoom *= pow(2.0, wheelValue);
  }
  view_changed();
}

void adjustWin3DElevationWheel(float wheelValue) {
  if (wheelValue > 0) WIN3D.zoom = 2 * funcs.atan_ang((1.1 / 1.0) * funcs.tan_ang(0.5 * WIN3D.zoom));
  if (wheelValue < 0) WIN3D.zoom = 2 * funcs.atan_ang((1.0 / 1.1) * funcs.tan_ang(0.5 * WIN3D.zoom));
  view_changed();
}

void scaleObjectsWheel(float wheelValue) {
  if (wheelValue > 0) overallScale /= pow(2.0, 0.25);
  if (wheelValue < 0) overallScale *= pow(2.0, 0.25);
  view_changed();
}

void scaleSkydomeWheel(float wheelValue) {
  if (wheelValue > 0)   Sky3D.radius *= pow(2.0, 0.25);
  if (wheelValue < 0)   Sky3D.radius /= pow(2.0, 0.25);
  view_changed();
}

void scaleAllModelWheel(float wheelValue) {
  if (wheelValue > 0) {
    overallScale /= pow(2.0, 0.25);
      Sky3D.radius /= pow(2.0, 0.25);
  }
  if (wheelValue < 0) {
    overallScale *= pow(2.0, 0.25);
      Sky3D.radius *= pow(2.0, 0.25);
  }
  view_changed();
}

void handleTargetRollXYZWheel(float wheelValue) {
  if (WIN3D.targetAxisIndex == 0) {
    WIN3D.rotationX += wheelValue * WIN3D.rotationStep;
    WIN3D.reverseTransform_3DViewport();
  }
  if (WIN3D.targetAxisIndex == 1) {
    WIN3D.rotationZ += wheelValue * WIN3D.rotationStep;
    WIN3D.reverseTransform_3DViewport();
  }
  view_changed();
}

void handleCameraRollXYZWheel(float wheelValue) {
  if (WIN3D.targetAxisIndex == 0) {
    WIN3D.rotateZ_3DViewport_around_Selection(wheelValue * WIN3D.rotationStep);
  }
  if (WIN3D.targetAxisIndex == 1) {
    WIN3D.rotateXY_3DViewport_around_Selection(wheelValue * WIN3D.rotationStep);
  }
  view_changed();
}

void moveWin3DTowardsSelection(float wheelValue) {
  WIN3D.move_3DViewport_towards_Selection(pow(2, 0.5 * wheelValue));
  view_changed();
}

void moveWin3DTowardsMouse(float wheelValue) {
  WIN3D.move_3DViewport_towards_Mouse(pow(2, 0.5 * wheelValue));
  view_changed();
}

void adjustPositionXWheel(float wheelValue) {
  WIN3D.positionX += wheelValue * WIN3D.positionStep * overallScale;
  view_changed();
}

void adjustPositionYWheel(float wheelValue) {
  WIN3D.positionY += wheelValue * WIN3D.positionStep * overallScale;
  view_changed();
}

void adjustRotationXWheel(float wheelValue) {
  WIN3D.rotationX += wheelValue * WIN3D.rotationStep;
  view_changed();
}

void adjustRotationZWheel(float wheelValue) {
  WIN3D.rotationZ += wheelValue * WIN3D.rotationStep;
  view_changed();
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
