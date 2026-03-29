void mouseDragged () {

  if (frameCount > Last_initializationStep) {

    if (SOLARCHVISION_automated == 0) {

      if (FRAME_drag_IMG) {
        if (dragging_started == 0) {
          SOLARCHVISION_X_click1 = pmouseX;
          SOLARCHVISION_Y_click1 = pmouseY;

          dragging_started = 1;
        }
      } else if (WIN3D.include) {
        if (isInside(pmouseX, pmouseY, WIN3D.cX, WIN3D.cY, WIN3D.cX + WIN3D.dX, WIN3D.cY + WIN3D.dY)) {
          if (isInside(mouseX, mouseY, WIN3D.cX, WIN3D.cY, WIN3D.cX + WIN3D.dX, WIN3D.cY + WIN3D.dY)) {

            if (dragging_started == 0) {

              SOLARCHVISION_X_click1 = pmouseX;
              SOLARCHVISION_Y_click1 = pmouseY;

              dragging_started = 1;
            }

            float dx = (mouseX - pmouseX) / float(WIN3D.dX);
            float dy = (mouseY - pmouseY) / float(WIN3D.dY);

            if (WIN3D.UI_CurrentTask == UITASK.LandOrbit_Pan_TargetRollZ) { // viewport

              if (mouseButton == LEFT) { // CameraLandOrbit
                // println("CameraLandOrbit");
                WIN3D.rotateXY_3DViewport_around_LandIntersection(10 * dx * WIN3D.rotation_T);

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // Pan
                // println("Pan");
                WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;
                WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }
            }

            if (WIN3D.UI_CurrentTask == UITASK.PanX_TargetRollXY_TargetRollZ) {

              if (mouseButton == LEFT) { // PanX
                // println("PanX");
                WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // PanY
                // println("PanY");
                WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }
            }

            if (WIN3D.UI_CurrentTask == UITASK.PanY_TargetRollXY_TargetRollZ) {

              if (mouseButton == LEFT) { // PanY
                // println("PanY");
                WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // PanX
                // println("PanX");
                WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }
            }

            if ((WIN3D.UI_CurrentTask == UITASK.Pan_TargetRoll) ||
                (WIN3D.UI_CurrentTask == UITASK.DistMouseXY_TargetRollXY_TargetRollZ) ||
                (WIN3D.UI_CurrentTask == UITASK.PickSelect)) { // viewport

              if (mouseButton == LEFT) { // Pan
                // println("Pan");
                WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;
                WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // TargetRoll
                // println("TargetRoll");
                WIN3D.rotation_Z += 10 * dx * WIN3D.rotation_T;
                WIN3D.rotation_X += 10 * dy * WIN3D.rotation_T;

                WIN3D.reverseTransform_3DViewport();

                SOLARCHVISION_view_changed();
              }
            }

            if ((WIN3D.UI_CurrentTask == UITASK.CameraRoll_Pan) ||
                (WIN3D.UI_CurrentTask == UITASK.CameraDistance_TargetRollXY_TargetRollZ)) { // viewport

              if (mouseButton == LEFT) { // CameraRoll
                // println("CameraRoll");
                WIN3D.rotateXY_3DViewport_around_Selection(-10 * dx * WIN3D.rotation_T);

                WIN3D.rotateZ_3DViewport_around_Selection(-10 * dy * WIN3D.rotation_T);

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // Pan
                // println("Pan");
                WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;
                WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }
            }

            if (WIN3D.UI_CurrentTask == UITASK.CameraRollXY_CameraRollZ) { // viewport

              if (mouseButton == LEFT) { // CameraRollXY
                // println("CameraRollXY");
                WIN3D.rotateXY_3DViewport_around_Selection(-10 * dx * WIN3D.rotation_T);

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // CameraRollZ
                // println("CameraRollZ");
                WIN3D.rotateZ_3DViewport_around_Selection(-10 * dy * WIN3D.rotation_T);

                SOLARCHVISION_view_changed();
              }
            }

            if (WIN3D.UI_CurrentTask == UITASK.TargetRoll_Pan) { // viewport

              if (mouseButton == LEFT) { // TargetRoll
                // println("TargetRoll");
                WIN3D.rotation_Z += 10 * dx * WIN3D.rotation_T;
                WIN3D.rotation_X += 10 * dy * WIN3D.rotation_T;

                WIN3D.reverseTransform_3DViewport();

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // Pan
                // println("Pan");
                WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;
                WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }
            }

            if (WIN3D.UI_CurrentTask == UITASK.TargetRollXY_TargetRollZ) { // viewport

              if (
                (mouseButton == LEFT && WIN3D.UI_OptionXorY == 1) ||
                (mouseButton == RIGHT && WIN3D.UI_OptionXorY == 0)
              ) { // TargetRollXY
                // println("TargetRollXY");
                WIN3D.rotation_Z += 10 * dx * WIN3D.rotation_T;

                WIN3D.reverseTransform_3DViewport();

                SOLARCHVISION_view_changed();
              }

              if (
                (mouseButton == LEFT && WIN3D.UI_OptionXorY == 0) ||
                (mouseButton == RIGHT && WIN3D.UI_OptionXorY == 1)
              ) { // TargetRollZ
                // println("TargetRollZ");
                WIN3D.rotation_X += 10 * dy * WIN3D.rotation_T;

                WIN3D.reverseTransform_3DViewport();

                SOLARCHVISION_view_changed();
              }
            }

            if ((WIN3D.UI_CurrentTask == UITASK.Zoom_Orbit_Pan) ||
                (WIN3D.UI_CurrentTask == UITASK.SkydomeSize) ||
                (WIN3D.UI_CurrentTask == UITASK.AllModelSize)) { // viewport

              if (mouseButton == LEFT) { // Orbit
                // println("Orbit");
                WIN3D.rotation_Z -= 10 * dx * WIN3D.rotation_T;
                WIN3D.rotation_X -= 10 * dy * WIN3D.rotation_T;

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // Pan
                // println("Pan");
                WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;
                WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }
            }

            if (WIN3D.UI_CurrentTask == UITASK.Pan_Height) {

              if (mouseButton == LEFT) { // move Y
                // println("move Y");
                WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // move X
                // println("move X");
                WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }
            }

            if (WIN3D.UI_CurrentTask == UITASK.ModelSize_Pan_TargetRoll) { // viewport

              if (mouseButton == LEFT) { // Pan
                // println("Pan");
                WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;
                WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }

              if (mouseButton == RIGHT) { // TargetRoll
                // println("TargetRoll");
                WIN3D.rotation_Z += 10 * dx * WIN3D.rotation_T;
                WIN3D.rotation_X += 10 * dy * WIN3D.rotation_T;

                WIN3D.reverseTransform_3DViewport();

                SOLARCHVISION_view_changed();
              }
            }

            if (WIN3D.UI_CurrentTask == UITASK.Truck_Orbit) { // viewport:different functions

              if (WIN3D.UI_TaskModifyParameter == 0) { // Truck
                // println("Truck");
                if (WIN3D.UI_OptionXorY == 0) {
                  if (mouseButton == LEFT) WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;
                  if (mouseButton == RIGHT) WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                  SOLARCHVISION_view_changed();
                }

                if (WIN3D.UI_OptionXorY == 1) {
                  if (mouseButton == RIGHT) WIN3D.position_X += 100 * dx * WIN3D.position_T * OBJECTS_scale;
                  if (mouseButton == LEFT) WIN3D.position_Y += 100 * dy * WIN3D.position_T * OBJECTS_scale;

                  SOLARCHVISION_view_changed();
                }
              }


              if (WIN3D.UI_TaskModifyParameter == 1) { // Orbit
                // println("Orbit");
                if (WIN3D.UI_OptionXorY == 0) {
                  if (mouseButton == LEFT) WIN3D.rotation_X -= 10 * dy * WIN3D.rotation_T;
                  if (mouseButton == RIGHT) WIN3D.rotation_Z -= 10 * dx * WIN3D.rotation_T;

                  SOLARCHVISION_view_changed();
                }

                if (WIN3D.UI_OptionXorY == 1) {
                  if (mouseButton == RIGHT) WIN3D.rotation_X -= 10 * dy * WIN3D.rotation_T;
                  if (mouseButton == LEFT) WIN3D.rotation_Z -= 10 * dx * WIN3D.rotation_T;

                  SOLARCHVISION_view_changed();
                }
              }


            }
          }
        }
      }
    }
  }
}
