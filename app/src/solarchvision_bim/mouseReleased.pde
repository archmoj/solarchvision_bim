void mouseReleased() {
  if (frameCount <= Last_initializationStep) return;
  if (control != USER_GUI) return;
  if (dragging_started == 0) return;

  resetPickListDragState();

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
  X_click2 = mouseX;
  Y_click2 = mouseY;

  if (X_click2 < X_click1) {
    int tmpX = X_click2;
    X_click2 = X_click1;
    X_click1 = tmpX;
  }
  if (Y_click2 < Y_click1) {
    int tmpY = Y_click2;
    Y_click2 = Y_click1;
    Y_click1 = tmpY;
  }
}

void finishFrameDragSelection() {
  RecordFrame();

  strokeWeight(2);
  if (mouseButton == RIGHT) {
    noStroke();
    fill(127, 127);
  } else {
    stroke(255, 0, 0);
    noFill();
  }
  rect(X_click1, Y_click1,
       X_click2 - X_click1,
       Y_click2 - Y_click1);
  strokeWeight(0);

  RecordFrame();
  view_changed();

  WORLD.revise();
  STUDY.revise();
  UI_rollout.revise();
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
  if (WIN3D.currentTool == UITASK.GetLength) {
    performGetLengthMeasurement();
  }
}

boolean isRectSelectTask() {
  return (WIN3D.currentTool == UITASK.RectSelect) ||
         (WIN3D.currentTool > UITASK.Move);
}

void performRectSelect() {
  float corner1x = X_click1 - 0.5 * WIN3D.dX - WIN3D.cX;
  float corner1y = Y_click1 - 0.5 * WIN3D.dY - WIN3D.cY;
  float corner2x = X_click2 - 0.5 * WIN3D.dX - WIN3D.cX;
  float corner2y = Y_click2 - 0.5 * WIN3D.dY - WIN3D.cY;

  pushMatrix();
  translate(WIN3D.cX + 0.5 * WIN3D.dX, WIN3D.cY + 0.5 * WIN3D.dY);
  noFill();
  stroke(127);
  strokeWeight(2);
  rect(corner1x, corner1y, corner2x - corner1x, corner2y - corner1y);
  popMatrix();

  runScriptLine("RectSelect x1=" + corner1x + " y1=" + corner1y + " x2=" + corner2x + " y2=" + corner2y);
}

void performGetLengthMeasurement() {
  // Ray casting is state-dependent on the current mouse button and
  // viewport, so it stays here rather than moving into the command -
  // see runScript.pde's own comment on GETLENGTH. Everything from here
  // on (the rotation-undoing math, which of Length/Width/Height actually
  // gets written) now lives in that command instead.
  float[] p1 = castClickToWorld(X_click1, Y_click1);
  float[] p2 = castClickToWorld(X_click2, Y_click2);

  runScriptLine("GetLength x1=" + p1[0] + " y1=" + p1[1] + " z1=" + p1[2] +
    " x2=" + p2[0] + " y2=" + p2[1] + " z2=" + p2[2]);
}

float[] castClickToWorld(float clickX, float clickY) {
  float imageX = clickX - (WIN3D.cX + 0.5 * WIN3D.dX);
  float imageY = clickY - (WIN3D.cY + 0.5 * WIN3D.dY);

  ClickRay ray = computeClickRay(imageX, imageY);
  float[] rayStart = ray.start;
  float[] rayDirection = ray.direction;

  float[] hit = { -1, 0, 0, 0 };
  if (mouseButton == RIGHT) {
    hit = Terrain.intersect(rayStart, rayDirection);
  } else if (mouseButton == LEFT) {
    hit = snap_Faces(allFaces.intersect(rayStart, rayDirection));
  }

  if (hit[0] >= 0) {
    return new float[] { hit[1], hit[2], hit[3] };
  }
  return new float[] { 0, 0, 0 };
}
