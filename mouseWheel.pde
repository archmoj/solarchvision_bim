void mouseWheel (MouseEvent event) {

  if (frameCount > Last_initializationStep) {

    if (UI_menuBar.selected_parent == -1) {

      mouseWheelConsume += 1;
      if (mouseWheelConsume % 2 == 0) {
        mouseWheelConsume = 0;

        float Wheel_Value = event.getCount();

        if (SOLARCHVISION_automated == 0) {
          SOLARCHVISION_X_clicked = mouseX;
          SOLARCHVISION_Y_clicked = mouseY;

          {
            float displayBarHeight = MessageSize;
            float displayBarWidth = 2 * SOLARCHVISION_pixel_W;

            X_control = 0.5 * displayBarWidth;
            Y_control = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 2 * SOLARCHVISION_pixel_H + 0.5 * UI_caseBar.tab;

            for (int i = 0; i < UI_caseBar.Items.length; i++) {

              float x1 = X_control - 0.366 * displayBarWidth;
              float x2 = X_control + 0.5 * displayBarWidth;
              float y1 = Y_control - 0.45 * displayBarHeight;
              float y2 = Y_control + 0.45 * displayBarHeight;

              if (UI_caseBar.Items[i][0].equals("Hours")) {

                if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, x1, y1, x2, y2)) {

                  int keep_STUDY_i_Start = STUDY.i_Start;
                  int keep_STUDY_i_End = STUDY.i_End;

                  if (Wheel_Value > 0) {
                    STUDY.i_Start += 1;
                    STUDY.i_End += 1;
                  }
                  if (Wheel_Value < 0) {
                    STUDY.i_Start -= 1;
                    STUDY.i_End -= 1;
                  }

                  if (STUDY.i_Start < 0) STUDY.i_Start = 23;
                  if (STUDY.i_Start > 23) STUDY.i_Start = 0;
                  if (STUDY.i_End < 0) STUDY.i_End = 23;
                  if (STUDY.i_End > 23) STUDY.i_End = 0;

                  if ((keep_STUDY_i_Start != STUDY.i_Start) ||
                      (keep_STUDY_i_End != STUDY.i_End)) {

                    ROLLOUT.revise();
                    STUDY.revise();
                    WORLD.revise();
                    UI_caseBar.revise();
                    SOLARCHVISION_view_changed();

                    SOLARCHVISION_find_which_bakings_to_regenerate();
                  }
                }
              }

              if (UI_caseBar.Items[i][0].equals("Days")) {

                if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, x1, y1, x2, y2)) {

                  int keep_STUDY_joinDays = STUDY.joinDays;

                  if (Wheel_Value > 0) STUDY.joinDays += 2;
                  if (Wheel_Value < 0) STUDY.joinDays -= 2;

                  if (STUDY.joinDays > 365 / STUDY.j_End) STUDY.joinDays = 365 / STUDY.j_End;
                  if (STUDY.joinDays < 1) STUDY.joinDays = 1;

                  if (keep_STUDY_joinDays != STUDY.joinDays) {

                    ROLLOUT.revise();
                    STUDY.revise();
                    UI_caseBar.revise();
                    SOLARCHVISION_view_changed();

                    SOLARCHVISION_find_which_bakings_to_regenerate();
                  }
                }
              }

              if (UI_caseBar.Items[i][0].equals("Scenario")) {

                if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, x1, y1, x2, y2)) {

                  if (CurrentDataSource == dataID_CLIMATE_CWEEDS) {
                    int keep_SampleYear_Start = SampleYear_Start;
                    int keep_SampleYear_End = SampleYear_End;

                    if (Wheel_Value > 0) {
                      SampleYear_Start += 1;
                      SampleYear_End += 1;
                    }
                    if (Wheel_Value < 0) {
                      SampleYear_Start -= 1;
                      SampleYear_End -= 1;
                    }

                    if (SampleYear_End < SampleYear_Start) SampleYear_End = SampleYear_Start;
                    if (SampleYear_Start > SampleYear_End) SampleYear_Start = SampleYear_End;

                    if (SampleYear_Start < CLIMATE_CWEEDS_start) SampleYear_Start = CLIMATE_CWEEDS_start;
                    if (SampleYear_Start > CLIMATE_CWEEDS_end) SampleYear_Start = CLIMATE_CWEEDS_end;
                    if (SampleYear_End < CLIMATE_CWEEDS_start) SampleYear_End = CLIMATE_CWEEDS_start;
                    if (SampleYear_End > CLIMATE_CWEEDS_end) SampleYear_End = CLIMATE_CWEEDS_end;

                    if ((keep_SampleYear_Start != SampleYear_Start) ||
                        (keep_SampleYear_End != SampleYear_End)) {

                      ROLLOUT.revise();
                      STUDY.revise();
                      UI_caseBar.revise();
                      SOLARCHVISION_view_changed();

                      SOLARCHVISION_find_which_bakings_to_regenerate();
                    }
                  }

                  if (CurrentDataSource == dataID_CLIMATE_CLMREC) {
                    int keep_SampleYear_Start = SampleYear_Start;
                    int keep_SampleYear_End = SampleYear_End;

                    if (Wheel_Value > 0) {
                      SampleYear_Start += 1;
                      SampleYear_End += 1;
                    }
                    if (Wheel_Value < 0) {
                      SampleYear_Start -= 1;
                      SampleYear_End -= 1;
                    }

                    if (SampleYear_End < SampleYear_Start) SampleYear_End = SampleYear_Start;
                    if (SampleYear_Start > SampleYear_End) SampleYear_Start = SampleYear_End;

                    if (SampleYear_Start < CLIMATE_CLMREC_start) SampleYear_Start = CLIMATE_CLMREC_start;
                    if (SampleYear_Start > CLIMATE_CLMREC_end) SampleYear_Start = CLIMATE_CLMREC_end;
                    if (SampleYear_End < CLIMATE_CLMREC_start) SampleYear_End = CLIMATE_CLMREC_start;
                    if (SampleYear_End > CLIMATE_CLMREC_end) SampleYear_End = CLIMATE_CLMREC_end;

                    if ((keep_SampleYear_Start != SampleYear_Start) ||
                        (keep_SampleYear_End != SampleYear_End)) {

                      ROLLOUT.revise();
                      STUDY.revise();
                      UI_caseBar.revise();
                      SOLARCHVISION_view_changed();

                      SOLARCHVISION_find_which_bakings_to_regenerate();
                    }
                  }

                  if (CurrentDataSource == dataID_ENSEMBLE_FORECAST) {
                    int keep_SampleMember_Start = SampleMember_Start;
                    int keep_SampleMember_End = SampleMember_End;

                    if (Wheel_Value > 0) {
                      SampleMember_Start += 1;
                      SampleMember_End += 1;
                    }
                    if (Wheel_Value < 0) {
                      SampleMember_Start -= 1;
                      SampleMember_End -= 1;
                    }

                    if (SampleMember_End < SampleMember_Start) SampleMember_End = SampleMember_Start;
                    if (SampleMember_Start > SampleMember_End) SampleMember_Start = SampleMember_End;

                    if (SampleMember_Start < ENSEMBLE_FORECAST_start) SampleMember_Start = ENSEMBLE_FORECAST_start;
                    if (SampleMember_Start > ENSEMBLE_FORECAST_end) SampleMember_Start = ENSEMBLE_FORECAST_end;
                    if (SampleMember_End < ENSEMBLE_FORECAST_start) SampleMember_End = ENSEMBLE_FORECAST_start;
                    if (SampleMember_End > ENSEMBLE_FORECAST_end) SampleMember_End = ENSEMBLE_FORECAST_end;

                    if ((keep_SampleMember_Start != SampleMember_Start) ||
                        (keep_SampleMember_End != SampleMember_End)) {

                      ROLLOUT.revise();
                      STUDY.revise();
                      UI_caseBar.revise();
                      SOLARCHVISION_view_changed();

                      SOLARCHVISION_find_which_bakings_to_regenerate();
                    }
                  }

                  if (CurrentDataSource == dataID_ENSEMBLE_OBSERVED) {
                    int keep_SampleStation_Start = SampleStation_Start;
                    int keep_SampleStation_End = SampleStation_End;

                    if (Wheel_Value > 0) {
                      SampleStation_Start += 1;
                      SampleStation_End += 1;
                    }
                    if (Wheel_Value < 0) {
                      SampleStation_Start -= 1;
                      SampleStation_End -= 1;
                    }

                    if (SampleStation_End < SampleStation_Start) SampleStation_End = SampleStation_Start;
                    if (SampleStation_Start > SampleStation_End) SampleStation_Start = SampleStation_End;

                    if (SampleStation_Start < ENSEMBLE_OBSERVED_start) SampleStation_Start = ENSEMBLE_OBSERVED_start;
                    if (SampleStation_Start > ENSEMBLE_OBSERVED_end) SampleStation_Start = ENSEMBLE_OBSERVED_end;
                    if (SampleStation_End < ENSEMBLE_OBSERVED_start) SampleStation_End = ENSEMBLE_OBSERVED_start;
                    if (SampleStation_End > ENSEMBLE_OBSERVED_end) SampleStation_End = ENSEMBLE_OBSERVED_end;

                    if ((keep_SampleStation_Start != SampleStation_Start) ||
                        (keep_SampleStation_End != SampleStation_End)) {

                      ROLLOUT.revise();
                      STUDY.revise();
                      UI_caseBar.revise();
                      SOLARCHVISION_view_changed();

                      SOLARCHVISION_find_which_bakings_to_regenerate();
                    }
                  }
                }
              }


              Y_control += UI_caseBar.tab;
            }
          }


          if (WORLD.include) {
            if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, WORLD.cX, WORLD.cY, WORLD.cX + WORLD.dX, WORLD.cY + WORLD.dY)) {

              int keep_WORLD_Zoom = WORLD.Zoom;

              if (Wheel_Value < 0) WORLD.Zoom += 1;
              if (Wheel_Value > 0) WORLD.Zoom -= 1;

              if (WORLD.Zoom < 1) WORLD.Zoom = 1;
              if (WORLD.Zoom > 6) WORLD.Zoom = 6;

              if (keep_WORLD_Zoom != WORLD.Zoom) {
                WORLD.VIEW_id = WORLD.FindGoodViewport(LocationLON, LocationLAT);

                WORLD.revise();
              }
            }
          }

          if (WIN3D.include) {
            if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, WIN3D.cX, WIN3D.cY, WIN3D.cX + WIN3D.dX, WIN3D.cY + WIN3D.dY)) {

              float[] P = Select3D.getPivot();

              float x0 = P[0];
              float y0 = P[1];
              float z0 = P[2];


              if (WIN3D.UI_CurrentTask == UITASK.Rotate) { // rotate

                float r = 5 * -Wheel_Value;

                int the_Vector = Select3D.rotVector;

                Rotate3D.selection(x0, y0, z0, r, the_Vector);

                SOLARCHVISION_model_changed();
              }

              if (WIN3D.UI_CurrentTask == UITASK.Scale) { // scale

                float s = pow(pow(2.0, 0.25), -Wheel_Value);

                float sx = s;
                float sy = s;
                float sz = s;

                int the_Vector = Select3D.scaleVector;

                if (the_Vector == 0) {
                  sy = 1;
                  sz = 1;
                }
                if (the_Vector == 1) {
                  sz = 1;
                  sx = 1;
                }
                if (the_Vector == 2) {
                  sx = 1;
                  sy = 1;
                }

                Scale3D.selection(x0, y0, z0, sx, sy, sz);

                SOLARCHVISION_model_changed();
              }


              if (WIN3D.UI_CurrentTask == UITASK.Move) { // move

                float d = -Wheel_Value;

                float dx = d;
                float dy = d;
                float dz = d;

                int the_Vector = Select3D.posVector;

                if (the_Vector == 0) {
                  dy = 0;
                  dz = 0;
                }
                if (the_Vector == 1) {
                  dz = 0;
                  dx = 0;
                }
                if (the_Vector == 2) {
                  dx = 0;
                  dy = 0;
                }

                Move3D.selection(dx, dy, dz);

                SOLARCHVISION_model_changed();
              }



              if (WIN3D.UI_TaskModifyParameter == 0) {
                if (WIN3D.UI_CurrentTask >= UITASK.Seed_Material) { // other properties

                  int p = int(-Wheel_Value);

                  Edit3D.selection(p);

                  SOLARCHVISION_model_changed();
                }
              }





              if ((WIN3D.UI_CurrentTask == UITASK.Zoom_Orbit_Pan) ||
                  (WIN3D.UI_CurrentTask == UITASK.CameraRoll_Pan) ||
                  (WIN3D.UI_CurrentTask == UITASK.TargetRoll_Pan) ||
                  (WIN3D.UI_CurrentTask == UITASK.Pan_TargetRoll)) { // viewport:zoom

                if (WIN3D.ViewType == 1) {
                  WIN3D.position_Z -= Wheel_Value * WIN3D.position_T * OBJECTS_scale;
                } else {
                  WIN3D.Zoom *= pow(2.0, Wheel_Value);
                }

                SOLARCHVISION_view_changed();
              }

              if (WIN3D.UI_CurrentTask == UITASK.Pan_Height) { // viewport:elevation

                if (Wheel_Value > 0) WIN3D.Zoom = 2 * funcs.atan_ang((1.1 / 1.0) * funcs.tan_ang(0.5 * WIN3D.Zoom));
                if (Wheel_Value < 0) WIN3D.Zoom = 2 * funcs.atan_ang((1.0 / 1.1) * funcs.tan_ang(0.5 * WIN3D.Zoom));

                SOLARCHVISION_view_changed();
              }

              if (WIN3D.UI_CurrentTask == UITASK.ModelSize_Pan_TargetRoll) { // viewport:3DModelSize

                if (Wheel_Value > 0) OBJECTS_scale /= pow(2.0, 0.25);
                if (Wheel_Value < 0) OBJECTS_scale *= pow(2.0, 0.25);

                SOLARCHVISION_view_changed();
              }

              if (WIN3D.UI_CurrentTask == UITASK.Truck_Orbit) { // viewport:different functions with wheel

                if (WIN3D.UI_TaskModifyParameter == 0) { // Truck

                  if (WIN3D.UI_OptionXorY == 0) {

                    WIN3D.position_X += Wheel_Value * WIN3D.position_T * OBJECTS_scale;

                    SOLARCHVISION_view_changed();
                  }

                  if (WIN3D.UI_OptionXorY == 1) {

                    WIN3D.position_Y += Wheel_Value * WIN3D.position_T * OBJECTS_scale;

                    SOLARCHVISION_view_changed();
                  }
                }


                if (WIN3D.UI_TaskModifyParameter == 1) {  // Orbit

                  if (WIN3D.UI_OptionXorY == 0) {

                    WIN3D.rotation_X += Wheel_Value * WIN3D.rotation_T;

                    SOLARCHVISION_view_changed();
                  }

                  if (WIN3D.UI_OptionXorY == 1) {

                    WIN3D.rotation_Z += Wheel_Value * WIN3D.rotation_T;

                    SOLARCHVISION_view_changed();
                  }
                }

              }


              if (WIN3D.UI_CurrentTask == UITASK.SkydomeSize) { // viewport:different functions with wheel

                if (WIN3D.UI_TaskModifyParameter == 0) { // SkydomeSize

                  if (Wheel_Value > 0) Sky3D.scale *= pow(2.0, 0.25);
                  if (Wheel_Value < 0) Sky3D.scale /= pow(2.0, 0.25);

                  SOLARCHVISION_view_changed();
                }
              }

              if (WIN3D.UI_CurrentTask == UITASK.AllModelSize) { // viewport:different functions with wheel

                if (WIN3D.UI_TaskModifyParameter == 0) { // AllModelSize

                  if (Wheel_Value > 0) {
                    OBJECTS_scale /= pow(2.0, 0.25);
                    Sky3D.scale /= pow(2.0, 0.25);
                  }

                  if (Wheel_Value < 0) {
                    OBJECTS_scale *= pow(2.0, 0.25);
                    Sky3D.scale *= pow(2.0, 0.25);
                  }

                  SOLARCHVISION_view_changed();
                }
              }

              if (WIN3D.UI_CurrentTask == UITASK.TargetRollXY_TargetRollZ) { // viewport:TargetRollXY/TargetRoolZ

                if (WIN3D.UI_OptionXorY == 0) {
                  WIN3D.rotation_X += Wheel_Value * WIN3D.rotation_T;

                  WIN3D.reverseTransform_3DViewport();
                }

                if (WIN3D.UI_OptionXorY == 1) {
                  WIN3D.rotation_Z += Wheel_Value * WIN3D.rotation_T;

                  WIN3D.reverseTransform_3DViewport();
                }

                SOLARCHVISION_view_changed();
              }

              if (WIN3D.UI_CurrentTask == UITASK.CameraRollXY_CameraRollZ) { // viewport:CameraRollXY/CameraRoolZ

                if (WIN3D.UI_OptionXorY == 0) {

                  WIN3D.rotateZ_3DViewport_around_Selection(Wheel_Value * WIN3D.rotation_T);
                }

                if (WIN3D.UI_OptionXorY == 1) {

                  WIN3D.rotateXY_3DViewport_around_Selection(Wheel_Value * WIN3D.rotation_T);
                }

                SOLARCHVISION_view_changed();
              }

              if (WIN3D.UI_CurrentTask == UITASK.CameraDistance_TargetRollXY_TargetRollZ) { // viewport:CameraDistance

                WIN3D.move_3DViewport_towards_Selection(pow(2, 0.5 * Wheel_Value));

                SOLARCHVISION_view_changed();
              }

              if (WIN3D.UI_CurrentTask == UITASK.PanX_TargetRoll) { // viewport:PanX

                WIN3D.position_X += Wheel_Value * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }

              if (WIN3D.UI_CurrentTask == UITASK.PanY_TargetRoll) { // viewport:PanY

                WIN3D.position_Y += Wheel_Value * WIN3D.position_T * OBJECTS_scale;

                SOLARCHVISION_view_changed();
              }

              if ((WIN3D.UI_CurrentTask == UITASK.DistMouseXY_TargetRollXY_TargetRollZ) ||
                  (WIN3D.UI_CurrentTask == UITASK.PickSelect)) { // viewport:DistMouseXY

                WIN3D.move_3DViewport_towards_Mouse(pow(2, 0.5 * Wheel_Value));

                SOLARCHVISION_view_changed();
              }

              if (WIN3D.UI_CurrentTask == UITASK.LandOrbit_Pan_TargetRollZ) { // viewport:LandOrbit

                WIN3D.move_3DViewport_towards_Mouse(pow(2, 0.5 * Wheel_Value));

                SOLARCHVISION_view_changed();
              }



            }
          }
        }
      }
    }
  }
}
