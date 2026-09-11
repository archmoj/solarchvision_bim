void mouseReleased() {
  if (frameCount <= Last_initializationStep) return;
  if (SOLARCHVISION_automated != 0) return;
  if (dragging_started == 0) return;

  normalizeClickRegion();

  if (FRAME_drag_IMG) {
    finishFrameDragSelection();
    FRAME_drag_IMG = false;
  } else {
    finishWin3DSelection();
  }

  dragging_started = 0;
}

void normalizeClickRegion() {
  SOLARCHVISION_X_click2 = mouseX;
  SOLARCHVISION_Y_click2 = mouseY;

  if (SOLARCHVISION_X_click2 < SOLARCHVISION_X_click1) {
    int tmpX = SOLARCHVISION_X_click2;
    SOLARCHVISION_X_click2 = SOLARCHVISION_X_click1;
    SOLARCHVISION_X_click1 = tmpX;
  }
  if (SOLARCHVISION_Y_click2 < SOLARCHVISION_Y_click1) {
    int tmpY = SOLARCHVISION_Y_click2;
    SOLARCHVISION_Y_click2 = SOLARCHVISION_Y_click1;
    SOLARCHVISION_Y_click1 = tmpY;
  }
}

void finishFrameDragSelection() {
  SOLARCHVISION_RecordFrame();

  strokeWeight(2);
  if (mouseButton == RIGHT) {
    noStroke();
    fill(127, 127);
  } else {
    stroke(255, 0, 0);
    noFill();
  }
  rect(SOLARCHVISION_X_click1, SOLARCHVISION_Y_click1,
       SOLARCHVISION_X_click2 - SOLARCHVISION_X_click1,
       SOLARCHVISION_Y_click2 - SOLARCHVISION_Y_click1);
  strokeWeight(0);

  SOLARCHVISION_RecordFrame();
  SOLARCHVISION_view_changed();

  WORLD.revise();
  STUDY.revise();
  ROLLOUT.revise();
  UI_menuBar.revise();
  UI_toolBar.revise();
  UI_caseBar.revise();
}

void finishWin3DSelection() {
  if (!WIN3D.include) return;
  if (!isInside(mouseX, mouseY, WIN3D.cX, WIN3D.cY, WIN3D.cX + WIN3D.dX, WIN3D.cY + WIN3D.dY)) return;

  if (isRectSelectTask()) {
    performRectSelect();
  }
  if (WIN3D.UI_CurrentTask == UITASK.GetLength) {
    performGetLengthMeasurement();
  }
}

boolean isRectSelectTask() {
  return (WIN3D.UI_CurrentTask == UITASK.RectSelect) ||
         (WIN3D.UI_CurrentTask > UITASK.Move);
}

void performRectSelect() {
  float corner1x = SOLARCHVISION_X_click1 - 0.5 * WIN3D.dX - WIN3D.cX;
  float corner1y = SOLARCHVISION_Y_click1 - 0.5 * WIN3D.dY - WIN3D.cY;
  float corner2x = SOLARCHVISION_X_click2 - 0.5 * WIN3D.dX - WIN3D.cX;
  float corner2y = SOLARCHVISION_Y_click2 - 0.5 * WIN3D.dY - WIN3D.cY;

  pushMatrix();
  translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);
  noFill();
  stroke(127);
  strokeWeight(2);
  rect(corner1x, corner1y, corner2x - corner1x, corner2y - corner1y);
  popMatrix();

  Select3D.selectRect(corner1x, corner1y, corner2x, corner2y);
}

void performGetLengthMeasurement() {
  float[] p1 = castClickToWorld(SOLARCHVISION_X_click1, SOLARCHVISION_Y_click1);
  float[] p2 = castClickToWorld(SOLARCHVISION_X_click2, SOLARCHVISION_Y_click2);

  float x1 = p1[0], y1 = p1[1], z1 = p1[2];
  float x2 = p2[0], y2 = p2[1], z2 = p2[2];

  float dx = x2 - x1;
  float dy = y2 - y1;
  float dz = z2 - z1;

  // Undo the viewport's Z rotation so length/width line up with the
  // object's local axes rather than screen axes.
  float dxRot = dx * funcs.cos_ang(-WIN3D.rotation_Z) - dy * funcs.sin_ang(-WIN3D.rotation_Z);
  float dyRot = dx * funcs.sin_ang(-WIN3D.rotation_Z) + dy * funcs.cos_ang(-WIN3D.rotation_Z);
  float dzRot = dz;

  float straightDist = dist(x1, y1, z1, x2, y2, z2);

  switch (WIN3D.UI_TaskModifyParameter) {
    case 0:
      User3D.create_Length = straightDist;
      break;
    case 1:
      User3D.create_Width = straightDist;
      break;
    case 2:
      User3D.create_Height = straightDist;
      break;
    case 3:
      User3D.create_Length = abs(dxRot);
      User3D.create_Width = abs(dyRot);
      User3D.create_Height = abs(dzRot);
      break;
    case 4:
      User3D.create_Length = abs(dxRot);
      User3D.create_Width = abs(dyRot);
      break;
  }

  ROLLOUT.revise();
}

float[] castClickToWorld(float clickX, float clickY) {
  float imageX = clickX - (WIN3D.cX + 0.5 * WIN3D.dX);
  float imageY = clickY - (WIN3D.cY + 0.5 * WIN3D.dY);

  float[] rayStart = { WIN3D.CAM_x, WIN3D.CAM_y, WIN3D.CAM_z };
  float[] rayEnd = WIN3D.calculate_Click3D(imageX, imageY);

  rayStart[0] /= OBJECTS_scale;
  rayStart[1] /= OBJECTS_scale;
  rayStart[2] /= OBJECTS_scale;
  rayEnd[0] /= OBJECTS_scale;
  rayEnd[1] /= OBJECTS_scale;
  rayEnd[2] /= OBJECTS_scale;

  // In this view type the ray must originate from the screen point
  // itself rather than the camera, so shift the start accordingly.
  if (WIN3D.ViewType == 0) {
    float[] rayCenter = WIN3D.calculate_Click3D(0, 0);
    rayCenter[0] /= OBJECTS_scale;
    rayCenter[1] /= OBJECTS_scale;
    rayCenter[2] /= OBJECTS_scale;

    rayStart[0] += rayEnd[0] - rayCenter[0];
    rayStart[1] += rayEnd[1] - rayCenter[1];
    rayStart[2] += rayEnd[2] - rayCenter[2];
  }

  float[] rayDirection = {
    rayEnd[0] - rayStart[0],
    rayEnd[1] - rayStart[1],
    rayEnd[2] - rayStart[2]
  };

  float[] hit = { -1, 0, 0, 0 };
  if (mouseButton == RIGHT) {
    hit = Land3D.intersect(rayStart, rayDirection);
  } else if (mouseButton == LEFT) {
    hit = SOLARCHVISION_snap_Faces(allFaces.intersect(rayStart, rayDirection));
  }

  if (hit[0] >= 0) {
    return new float[] { hit[1], hit[2], hit[3] };
  }
  return new float[] { 0, 0, 0 };
}
