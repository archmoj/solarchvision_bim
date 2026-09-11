void mouseWheel(MouseEvent event) {
  if (frameCount <= Last_initializationStep) return;
  if (UI_menuBar.selected_parent != -1) return;

  // Wheel events arrive in pairs on some platforms;
  // only act on every second one
  mouseWheelConsume += 1;
  if (mouseWheelConsume % 2 != 0) return;
  mouseWheelConsume = 0;

  float Wheel_Value = event.getCount();
  if (SOLARCHVISION_automated != 0) return;

  SOLARCHVISION_X_clicked = mouseX;
  SOLARCHVISION_Y_clicked = mouseY;

  handleCaseBarWheel(Wheel_Value);
  handleWorldZoomWheel(Wheel_Value);
  handleWin3DWheel(Wheel_Value);
}


void handleCaseBarWheel(float wheelValue) {
  float displayBarHeight = MessageSize;
  float displayBarWidth = 2 * SOLARCHVISION_pixel_W;

  X_control = 0.5 * displayBarWidth;
  Y_control = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 2 * SOLARCHVISION_pixel_H + 0.5 * UI_caseBar.tab;

  for (int i = 0; i < UI_caseBar.Items.length; i++) {
    float x1 = X_control - 0.366 * displayBarWidth;
    float x2 = X_control + 0.5 * displayBarWidth;
    float y1 = Y_control - 0.45 * displayBarHeight;
    float y2 = Y_control + 0.45 * displayBarHeight;

    if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, x1, y1, x2, y2)) {
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
  ROLLOUT.revise();
  STUDY.revise();
  if (alsoWorld) WORLD.revise();
  UI_caseBar.revise();
  SOLARCHVISION_view_changed();
  SOLARCHVISION_find_which_bakings_to_regenerate();
}

void handleHoursCaseBarWheel(float wheelValue) {
  int oldStart = STUDY.i_Start;
  int oldEnd = STUDY.i_End;

  if (wheelValue > 0) {
    STUDY.i_Start += 1;
    STUDY.i_End += 1;
  }
  if (wheelValue < 0) {
    STUDY.i_Start -= 1;
    STUDY.i_End -= 1;
  }

  if (STUDY.i_Start < 0) STUDY.i_Start = 23;
  if (STUDY.i_Start > 23) STUDY.i_Start = 0;
  if (STUDY.i_End < 0) STUDY.i_End = 23;
  if (STUDY.i_End > 23) STUDY.i_End = 0;

  if (oldStart != STUDY.i_Start || oldEnd != STUDY.i_End) {
    reviseStudyAndRegenerate(true);
  }
}

void handleDaysCaseBarWheel(float wheelValue) {
  int oldJoinDays = STUDY.joinDays;

  if (wheelValue > 0) STUDY.joinDays += 2;
  if (wheelValue < 0) STUDY.joinDays -= 2;

  if (STUDY.joinDays > 365 / STUDY.j_End) STUDY.joinDays = 365 / STUDY.j_End;
  if (STUDY.joinDays < 1) STUDY.joinDays = 1;

  if (oldJoinDays != STUDY.joinDays) {
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
  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
    int[] r = shiftAndClampRange(SampleYear_Start, SampleYear_End, wheelValue, CLIMATE_CWEEDS_start, CLIMATE_CWEEDS_end);
    if (r[0] != SampleYear_Start || r[1] != SampleYear_End) {
      SampleYear_Start = r[0];
      SampleYear_End = r[1];
      reviseStudyAndRegenerate(false);
    }
  }

  if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
    int[] r = shiftAndClampRange(SampleYear_Start, SampleYear_End, wheelValue, CLIMATE_CLMREC_start, CLIMATE_CLMREC_end);
    if (r[0] != SampleYear_Start || r[1] != SampleYear_End) {
      SampleYear_Start = r[0];
      SampleYear_End = r[1];
      reviseStudyAndRegenerate(false);
    }
  }

  if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
    int[] r = shiftAndClampRange(SampleMember_Start, SampleMember_End, wheelValue, ENSEMBLE_FORECAST_start, ENSEMBLE_FORECAST_end);
    if (r[0] != SampleMember_Start || r[1] != SampleMember_End) {
      SampleMember_Start = r[0];
      SampleMember_End = r[1];
      reviseStudyAndRegenerate(false);
    }
  }

  if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
    int[] r = shiftAndClampRange(SampleStation_Start, SampleStation_End, wheelValue, ENSEMBLE_OBSERVED_start, ENSEMBLE_OBSERVED_end);
    if (r[0] != SampleStation_Start || r[1] != SampleStation_End) {
      SampleStation_Start = r[0];
      SampleStation_End = r[1];
      reviseStudyAndRegenerate(false);
    }
  }
}


void handleWorldZoomWheel(float wheelValue) {
  if (!WORLD.include) return;
  if (!isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, WORLD.cX, WORLD.cY, WORLD.cX + WORLD.dX, WORLD.cY + WORLD.dY)) return;

  int oldZoom = WORLD.Zoom;

  if (wheelValue < 0) WORLD.Zoom += 1;
  if (wheelValue > 0) WORLD.Zoom -= 1;

  if (WORLD.Zoom < 1) WORLD.Zoom = 1;
  if (WORLD.Zoom > 6) WORLD.Zoom = 6;

  if (oldZoom != WORLD.Zoom) {
    WORLD.VIEW_id = WORLD.FindGoodViewport(LocationLON, LocationLAT);
    WORLD.revise();
  }
}


void handleWin3DWheel(float wheelValue) {
  if (!WIN3D.include) return;
  if (!isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, WIN3D.cX, WIN3D.cY, WIN3D.cX + WIN3D.dX, WIN3D.cY + WIN3D.dY)) return;

  float[] pivot = Select3D.getPivot();
  float x0 = pivot[0];
  float y0 = pivot[1];
  float z0 = pivot[2];

  handleObjectEditWheel(wheelValue, x0, y0, z0);
  handleViewportWheel(wheelValue);
}


void handleObjectEditWheel(float wheelValue, float x0, float y0, float z0) {
  if (WIN3D.UI_CurrentTask == UITASK.Rotate) {
    handleRotateWheel(wheelValue, x0, y0, z0);
  }
  if (WIN3D.UI_CurrentTask == UITASK.Scale) {
    handleScaleWheel(wheelValue, x0, y0, z0);
  }
  if (WIN3D.UI_CurrentTask == UITASK.Move) {
    handleMoveWheel(wheelValue);
  }
  if (WIN3D.UI_TaskModifyParameter == 0) {
    if (WIN3D.UI_CurrentTask >= UITASK.Seed_Material) { // other properties
      handlePropertyEditWheel(wheelValue);
    }
  }
}

void handleRotateWheel(float wheelValue, float x0, float y0, float z0) {
  float r = 5 * -wheelValue;
  int theVector = Select3D.rotVector;
  Rotate3D.selection(x0, y0, z0, r, theVector);
  SOLARCHVISION_model_changed();
}

void handleScaleWheel(float wheelValue, float x0, float y0, float z0) {
  float s = pow(pow(2.0, 0.25), -wheelValue);

  float sx = s;
  float sy = s;
  float sz = s;

  int theVector = Select3D.scaleVector;
  if (theVector == 0) { sy = 1; sz = 1; }
  if (theVector == 1) { sz = 1; sx = 1; }
  if (theVector == 2) { sx = 1; sy = 1; }

  Scale3D.selection(x0, y0, z0, sx, sy, sz);
  SOLARCHVISION_model_changed();
}

void handleMoveWheel(float wheelValue) {
  float d = -wheelValue;

  float dx = d;
  float dy = d;
  float dz = d;

  int theVector = Select3D.posVector;
  if (theVector == 0) { dy = 0; dz = 0; }
  if (theVector == 1) { dz = 0; dx = 0; }
  if (theVector == 2) { dx = 0; dy = 0; }

  Move3D.selection(dx, dy, dz);
  SOLARCHVISION_model_changed();
}

void handlePropertyEditWheel(float wheelValue) {
  int p = int(-wheelValue);
  Edit3D.selection(p);
  SOLARCHVISION_model_changed();
}


void handleViewportWheel(float wheelValue) {
  if ((WIN3D.UI_CurrentTask == UITASK.Zoom_Orbit_Pan) ||
      (WIN3D.UI_CurrentTask == UITASK.CameraRoll_Pan) ||
      (WIN3D.UI_CurrentTask == UITASK.TargetRoll_Pan) ||
      (WIN3D.UI_CurrentTask == UITASK.Pan_TargetRoll)) { // viewport:zoom
    zoomWin3DViewport(wheelValue);
  }

  if (WIN3D.UI_CurrentTask == UITASK.Pan_Height) { // viewport:elevation
    adjustWin3DElevationWheel(wheelValue);
  }

  if (WIN3D.UI_CurrentTask == UITASK.ModelSize_Pan_TargetRoll) { // viewport:3DModelSize
    scaleObjectsWheel(wheelValue);
  }

  if (WIN3D.UI_CurrentTask == UITASK.Truck_Orbit) { // viewport:different functions with wheel
    handleTruckOrbitWheel(wheelValue);
  }

  if (WIN3D.UI_CurrentTask == UITASK.SkydomeSize) { // viewport:different functions with wheel
    if (WIN3D.UI_TaskModifyParameter == 0) { // SkydomeSize
      scaleSkydomeWheel(wheelValue);
    }
  }

  if (WIN3D.UI_CurrentTask == UITASK.AllModelSize) { // viewport:different functions with wheel
    if (WIN3D.UI_TaskModifyParameter == 0) { // AllModelSize
      scaleAllModelWheel(wheelValue);
    }
  }

  if (WIN3D.UI_CurrentTask == UITASK.TargetRollXY_TargetRollZ) { // viewport:TargetRollXY/TargetRollZ
    handleTargetRollXYZWheel(wheelValue);
  }

  if (WIN3D.UI_CurrentTask == UITASK.CameraRollXY_CameraRollZ) { // viewport:CameraRollXY/CameraRollZ
    handleCameraRollXYZWheel(wheelValue);
  }

  if (WIN3D.UI_CurrentTask == UITASK.CameraDistance_TargetRollXY_TargetRollZ) { // viewport:CameraDistance
    moveWin3DTowardsSelection(wheelValue);
  }

  if (WIN3D.UI_CurrentTask == UITASK.PanX_TargetRoll) { // viewport:PanX
    adjustPositionXWheel(wheelValue);
  }

  if (WIN3D.UI_CurrentTask == UITASK.PanY_TargetRoll) { // viewport:PanY
    adjustPositionYWheel(wheelValue);
  }

  if ((WIN3D.UI_CurrentTask == UITASK.DistMouseXY_TargetRollXY_TargetRollZ) ||
      (WIN3D.UI_CurrentTask == UITASK.PickSelect)) { // viewport:DistMouseXY
    moveWin3DTowardsMouse(wheelValue);
  }

  if (WIN3D.UI_CurrentTask == UITASK.LandOrbit_Pan_TargetRollZ) { // viewport:LandOrbit
    moveWin3DTowardsMouse(wheelValue);
  }
}

void zoomWin3DViewport(float wheelValue) {
  if (WIN3D.ViewType == 1) {
    WIN3D.position_Z -= wheelValue * WIN3D.position_T * OBJECTS_scale;
  } else {
    WIN3D.Zoom *= pow(2.0, wheelValue);
  }
  SOLARCHVISION_view_changed();
}

void adjustWin3DElevationWheel(float wheelValue) {
  if (wheelValue > 0) WIN3D.Zoom = 2 * funcs.atan_ang((1.1 / 1.0) * funcs.tan_ang(0.5 * WIN3D.Zoom));
  if (wheelValue < 0) WIN3D.Zoom = 2 * funcs.atan_ang((1.0 / 1.1) * funcs.tan_ang(0.5 * WIN3D.Zoom));
  SOLARCHVISION_view_changed();
}

void scaleObjectsWheel(float wheelValue) {
  if (wheelValue > 0) OBJECTS_scale /= pow(2.0, 0.25);
  if (wheelValue < 0) OBJECTS_scale *= pow(2.0, 0.25);
  SOLARCHVISION_view_changed();
}

void scaleSkydomeWheel(float wheelValue) {
  if (wheelValue > 0) Sky3D.scale *= pow(2.0, 0.25);
  if (wheelValue < 0) Sky3D.scale /= pow(2.0, 0.25);
  SOLARCHVISION_view_changed();
}

void scaleAllModelWheel(float wheelValue) {
  if (wheelValue > 0) {
    OBJECTS_scale /= pow(2.0, 0.25);
    Sky3D.scale /= pow(2.0, 0.25);
  }
  if (wheelValue < 0) {
    OBJECTS_scale *= pow(2.0, 0.25);
    Sky3D.scale *= pow(2.0, 0.25);
  }
  SOLARCHVISION_view_changed();
}

void handleTargetRollXYZWheel(float wheelValue) {
  if (WIN3D.UI_OptionXorY == 0) {
    WIN3D.rotation_X += wheelValue * WIN3D.rotation_T;
    WIN3D.reverseTransform_3DViewport();
  }
  if (WIN3D.UI_OptionXorY == 1) {
    WIN3D.rotation_Z += wheelValue * WIN3D.rotation_T;
    WIN3D.reverseTransform_3DViewport();
  }
  SOLARCHVISION_view_changed();
}

void handleCameraRollXYZWheel(float wheelValue) {
  if (WIN3D.UI_OptionXorY == 0) {
    WIN3D.rotateZ_3DViewport_around_Selection(wheelValue * WIN3D.rotation_T);
  }
  if (WIN3D.UI_OptionXorY == 1) {
    WIN3D.rotateXY_3DViewport_around_Selection(wheelValue * WIN3D.rotation_T);
  }
  SOLARCHVISION_view_changed();
}

void moveWin3DTowardsSelection(float wheelValue) {
  WIN3D.move_3DViewport_towards_Selection(pow(2, 0.5 * wheelValue));
  SOLARCHVISION_view_changed();
}

void moveWin3DTowardsMouse(float wheelValue) {
  WIN3D.move_3DViewport_towards_Mouse(pow(2, 0.5 * wheelValue));
  SOLARCHVISION_view_changed();
}

void adjustPositionXWheel(float wheelValue) {
  WIN3D.position_X += wheelValue * WIN3D.position_T * OBJECTS_scale;
  SOLARCHVISION_view_changed();
}

void adjustPositionYWheel(float wheelValue) {
  WIN3D.position_Y += wheelValue * WIN3D.position_T * OBJECTS_scale;
  SOLARCHVISION_view_changed();
}

void adjustRotationXWheel(float wheelValue) {
  WIN3D.rotation_X += wheelValue * WIN3D.rotation_T;
  SOLARCHVISION_view_changed();
}

void adjustRotationZWheel(float wheelValue) {
  WIN3D.rotation_Z += wheelValue * WIN3D.rotation_T;
  SOLARCHVISION_view_changed();
}

void handleTruckOrbitWheel(float wheelValue) {
  if (WIN3D.UI_TaskModifyParameter == 0) { // Truck
    if (WIN3D.UI_OptionXorY == 0) adjustPositionXWheel(wheelValue);
    if (WIN3D.UI_OptionXorY == 1) adjustPositionYWheel(wheelValue);
  }

  if (WIN3D.UI_TaskModifyParameter == 1) { // Orbit
    if (WIN3D.UI_OptionXorY == 0) adjustRotationXWheel(wheelValue);
    if (WIN3D.UI_OptionXorY == 1) adjustRotationZWheel(wheelValue);
  }
}
