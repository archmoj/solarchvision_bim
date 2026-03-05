void mouseReleased () {

  if (frameCount > Last_initializationStep) {

    if (SOLARCHVISION_automated == 0) {

      if (dragging_started != 0) {

        SOLARCHVISION_X_click2 = mouseX;
        SOLARCHVISION_Y_click2 = mouseY;

        int swap_tmp = 0;

        if (SOLARCHVISION_X_click2 < SOLARCHVISION_X_click1) {
          swap_tmp = SOLARCHVISION_X_click2;
          SOLARCHVISION_X_click2 = SOLARCHVISION_X_click1;
          SOLARCHVISION_X_click1 = swap_tmp;
        }

        if (SOLARCHVISION_Y_click2 < SOLARCHVISION_Y_click1) {
          swap_tmp = SOLARCHVISION_Y_click2;
          SOLARCHVISION_Y_click2 = SOLARCHVISION_Y_click1;
          SOLARCHVISION_Y_click1 = swap_tmp;
        }

        if (FRAME_drag_IMG) {

          SOLARCHVISION_RecordFrame();

          strokeWeight(2);
          if (mouseButton == RIGHT) {
            noStroke();
            fill(127, 127);
          } else {
            stroke(255, 0, 0);
            noFill();
          }

          rect(SOLARCHVISION_X_click1, SOLARCHVISION_Y_click1, SOLARCHVISION_X_click2 - SOLARCHVISION_X_click1, SOLARCHVISION_Y_click2 - SOLARCHVISION_Y_click1);
          strokeWeight(0);

          SOLARCHVISION_RecordFrame();

          SOLARCHVISION_view_changed();
          WORLD.revise();
          STUDY.revise();
          ROLLOUT.revise();
          UI_menuBar.revise();
          UI_toolBar.revise();
          UI_caseBar.revise();

          FRAME_drag_IMG = false;

          dragging_started = 0;
        } else {

          if (WIN3D.include) {
            if (isInside(mouseX, mouseY, WIN3D.cX, WIN3D.cY, WIN3D.cX + WIN3D.dX, WIN3D.cY + WIN3D.dY)) {

              if ((WIN3D.UI_CurrentTask == UITASK.RectSelect) ||
                  (WIN3D.UI_CurrentTask > UITASK.Move)) { // RectSelect also if scale, rotate, modify, etc. where selected

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


              if (WIN3D.UI_CurrentTask == UITASK.GetLength) {

                float x1 = 0;
                float y1 = 0;
                float z1 = 0;

                float x2 = 0;
                float y2 = 0;
                float z2 = 0;

                for (int q = 0; q < 2; q++) {

                  float Image_X = 0;
                  float Image_Y = 0;

                  if (q == 0) {
                    Image_X = SOLARCHVISION_X_click1 - (WIN3D.cX + 0.5 * WIN3D.dX);
                    Image_Y = SOLARCHVISION_Y_click1 - (WIN3D.cY + 0.5 * WIN3D.dY);
                  }
                  if (q == 1) {
                    Image_X = SOLARCHVISION_X_click2 - (WIN3D.cX + 0.5 * WIN3D.dX);
                    Image_Y = SOLARCHVISION_Y_click2 - (WIN3D.cY + 0.5 * WIN3D.dY);
                  }

                  float[] ray_direction = new float [3];

                  float[] ray_start = {
                    WIN3D.CAM_x, WIN3D.CAM_y, WIN3D.CAM_z
                  };

                  float[] ray_end = WIN3D.calculate_Click3D(Image_X, Image_Y);

                  ray_start[0] /= OBJECTS_scale;
                  ray_start[1] /= OBJECTS_scale;
                  ray_start[2] /= OBJECTS_scale;

                  ray_end[0] /= OBJECTS_scale;
                  ray_end[1] /= OBJECTS_scale;
                  ray_end[2] /= OBJECTS_scale;

                  if (WIN3D.ViewType == 0) {
                    float[] ray_center = WIN3D.calculate_Click3D(0, 0);

                    ray_center[0] /= OBJECTS_scale;
                    ray_center[1] /= OBJECTS_scale;
                    ray_center[2] /= OBJECTS_scale;

                    ray_start[0] += ray_end[0] - ray_center[0];
                    ray_start[1] += ray_end[1] - ray_center[1];
                    ray_start[2] += ray_end[2] - ray_center[2];
                  }

                  ray_direction[0] = ray_end[0] - ray_start[0];
                  ray_direction[1] = ray_end[1] - ray_start[1];
                  ray_direction[2] = ray_end[2] - ray_start[2];

                  float[] RxP = new float [8];

                  if (mouseButton == RIGHT) {
                    RxP = Land3D.intersect(ray_start, ray_direction);
                  } else if (mouseButton == LEFT) {
                    RxP = SOLARCHVISION_snap_Faces(allFaces.intersect(ray_start, ray_direction));
                  }

                  if (RxP[0] >= 0) {
                    if (q == 0) {
                      x1 = RxP[1];
                      y1 = RxP[2];
                      z1 = RxP[3];
                    }
                    if (q == 1) {
                      x2 = RxP[1];
                      y2 = RxP[2];
                      z2 = RxP[3];
                    }
                  }
                }

                float dx = x2 - x1;
                float dy = y2 - y1;
                float dz = z2 - z1;

                float dx_rot = dx * funcs.cos_ang(-WIN3D.rotation_Z) - dy * funcs.sin_ang(-WIN3D.rotation_Z);
                float dy_rot = dx * funcs.sin_ang(-WIN3D.rotation_Z) + dy * funcs.cos_ang(-WIN3D.rotation_Z);
                float dz_rot = dz;

                if (WIN3D.UI_TaskModifyParameter == 0) {
                  User3D.create_Length = dist(x1, y1, z1, x2, y2, z2);
                }
                if (WIN3D.UI_TaskModifyParameter == 1) {
                  User3D.create_Width = dist(x1, y1, z1, x2, y2, z2);
                }
                if (WIN3D.UI_TaskModifyParameter == 2) {
                  User3D.create_Height = dist(x1, y1, z1, x2, y2, z2);
                }
                if (WIN3D.UI_TaskModifyParameter == 3) {
                  User3D.create_Length = abs(dx_rot);
                  User3D.create_Width = abs(dy_rot);
                  User3D.create_Height = abs(dz_rot);
                }
                if (WIN3D.UI_TaskModifyParameter == 4) {
                  User3D.create_Length = abs(dx_rot);
                  User3D.create_Width = abs(dy_rot);
                }
                if (WIN3D.UI_TaskModifyParameter == 5) {
                  User3D.create_Orientation = funcs.atan2_ang(y2 - y1, x2 - x1) + 90;
                }

                ROLLOUT.revise();
              }
            }
          }

          dragging_started = 0;
        }
      }
    }
  }
}
