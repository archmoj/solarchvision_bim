void castShadows_CurrentSection () {

  showWaitCursor();

  println("\nBaking shadows for the current section. Please wait...");

  SceneName = "Section_" + Section_Stamp();

  String ScenePathPrefix = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName;


  int RES1 = allSolarImpacts.RES1;
  int RES2 = allSolarImpacts.RES2;

  Shades_scaleX = RES1 / allSolarImpacts.U;
  Shades_scaleY = RES2 / allSolarImpacts.V;

  Shades_offsetX = allSolarImpacts.X;
  Shades_offsetY = allSolarImpacts.Y;


  SHADOW_graphics = createGraphics(RES1, RES2, P2D);

  TREES_graphics = createGraphics(RES1, RES2, P2D);

  int keep_allSolarImpacts_sectionType = allSolarImpacts.sectionType;
  float keep_allSolarImpacts_rotation = allSolarImpacts.R;

  if (allSolarImpacts.sectionType == 3) {
    allSolarImpacts.sectionType = 2;
    allSolarImpacts.R = 90 - allSolarImpacts.R;
  }

  boolean rotate = (allSolarImpacts.sectionType == 2);
  float cosR = 0, sinR = 0;
  if (rotate) {
    cosR = funcs.cos_ang(-allSolarImpacts.R);
    sinR = funcs.sin_ang(-allSolarImpacts.R);
  }

  // Total frames this one call will render, so the console bar/
  // ProgressWindow below can show real percent-through-the-whole-call
  // progress, not just per-phase: the Direct loop's own 24 DATE_ANGLEs
  // (0..345 step 15) x 17 HOUR_ANGLEs (4..20) x 2 SHD values below, plus
  // the Diffuse loop's own 2 SHD values x DiffuseVectors.length sky
  // patches - each renderShadowFrame() call, in either loop, is this
  // function's own one real, comparably-sized unit of work (a
  // TREES_graphics render, a SHADOW_graphics render, and up to 3 PNG/
  // JPG saves), so counting those calls rather than, say, DATE_ANGLE
  // steps gives a bar that actually advances at a steady rate.
  int totalDateAngles = 360 / 15;
  int totalHourAngles = 20 - 4 + 1;
  int totalFrames = (totalDateAngles * totalHourAngles * 2) + (2 * DiffuseVectors.length);
  int framesDone = 0;
  float printed_Progress = 0;
  StringBuilder barBuffer = new StringBuilder();

  progressBarHeader();

  // showSectionBakeProgress (globalVariables.pde's own comment) -
  // ProgressWindow (preBakeViewport3D.pde), updated inline alongside the
  // console bar's own delta >= 1 throttle just below, same shape as
  // import_objects_OBJ()'s own (importObj.pde) - this loop, like that
  // one, is plain single-threaded iteration on the calling thread
  // itself, with no concurrent futures to wait on. Wrapped in try/
  // finally, alongside this function's own sectionType/R restore below,
  // so a mid-bake exception still leaves both cleaned up rather than the
  // window stuck on screen and allSolarImpacts left mid-rotation.
  ProgressWindow sectionBakeProgressWindow = (showSectionBakeProgress && canShowProgressWindow()) ? new ProgressWindow("Baking Section") : null;
  if (sectionBakeProgressWindow != null) sectionBakeProgressWindow.setVisible(true);

  try {
    {
      int RAD_TYPE = 0;

      for (int DATE_ANGLE = 0; DATE_ANGLE < 360; DATE_ANGLE += 15) {

        //for (int i = 0; i < 24; i++) {
        for (int i = 4; i <= 20; i++) { // to make it faster. Also the images are not needed out of this period.

          float HOUR_ANGLE = i;
          float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);
          SunR_Rotated = SunR;
          int SunR_Rotated_check = 3;

          if (rotate) {
            float a = SunR_Rotated[1];
            float b = -SunR_Rotated[2];
            float c = SunR_Rotated[3];

            SunR_Rotated[1] = a * cosR - b * sinR;
            SunR_Rotated[2] = c;
            SunR_Rotated[3] = a * sinR + b * cosR;

            SunR_Rotated_check = 2;
          }

          for (int SHD = 0; SHD <= 1; SHD++) {

            String File_Name = ScenePathPrefix;

            File_Name += nf(DATE_ANGLE, 3) + "_" + STR_SHD[SHD] + "_" + nf(int(funcs.roundTo(HOUR_ANGLE * 100, 1.0)), 4);

            File_Name += "_Camera00";

            renderShadowFrame(SunR, SunR_Rotated_check, SHD, RES1, RES2, File_Name, ".png");

            framesDone++;
            if (control != USER_AUTO) {
              float Progress = 100.0 * framesDone / totalFrames;
              int delta = (int) floor(Progress - printed_Progress);
              if (delta >= 1) {
                barBuffer.setLength(0);
                for (int c = 0; c < delta; c++) {
                  barBuffer.append('█');
                }
                print(barBuffer.toString()); // one print() call instead of `delta` calls
                printed_Progress = floor(Progress);
                if (sectionBakeProgressWindow != null) sectionBakeProgressWindow.updateFraction(Progress / 100.0f);
              }
            }
          }
        }
      }
    }


    {
      int RAD_TYPE = 1;

      PGraphics DIFFUSE_graphics = createGraphics(RES1, RES2, P2D);

      for (int SHD = 0; SHD <= 1; SHD++) {

        String File_Name = ScenePathPrefix;

        File_Name += "DIF_" + STR_SHD[SHD];

        PImage[] shadowFrames = new PImage[DiffuseVectors.length];

        for (int i = 0; i < DiffuseVectors.length; i++) {

          float[] SunR= {
            0, DiffuseVectors[i][0], DiffuseVectors[i][1], DiffuseVectors[i][2]
          };

          SunR_Rotated = SunR;
          int SunR_Rotated_check = 3;

          if (rotate) {
            float a = SunR_Rotated[1];
            float b = -SunR_Rotated[2];
            float c = SunR_Rotated[3];

            SunR_Rotated[1] = a * cosR - b * sinR;
            SunR_Rotated[2] = c;
            SunR_Rotated[3] = a * sinR + b * cosR;

            SunR_Rotated_check = 2;
          }



          renderShadowFrame(SunR, SunR_Rotated_check, SHD, RES1, RES2, File_Name + nf(i, 3), ".jpg");

          shadowFrames[i] = SHADOW_graphics.get();

          framesDone++;
          if (control != USER_AUTO) {
            float Progress = 100.0 * framesDone / totalFrames;
            int delta = (int) floor(Progress - printed_Progress);
            if (delta >= 1) {
              barBuffer.setLength(0);
              for (int c = 0; c < delta; c++) {
                barBuffer.append('█');
              }
              print(barBuffer.toString()); // one print() call instead of `delta` calls
              printed_Progress = floor(Progress);
              if (sectionBakeProgressWindow != null) sectionBakeProgressWindow.updateFraction(Progress / 100.0f);
            }
          }
        }



        DIFFUSE_graphics.beginDraw();

        DIFFUSE_graphics.blendMode(REPLACE);

        DIFFUSE_graphics.fill(0);
        DIFFUSE_graphics.stroke(0);
        DIFFUSE_graphics.strokeWeight(0);
        DIFFUSE_graphics.rectMode(CORNER);
        DIFFUSE_graphics.rect(0, 0, RES1, RES2);

        float tintAlpha = 255 / (0.5 * DiffuseVectors.length);

        for (int i = 0; i < DiffuseVectors.length; i++) {

          PImage img = shadowFrames[i];

          DIFFUSE_graphics.blendMode(ADD);

          DIFFUSE_graphics.tint(255, tintAlpha);

          DIFFUSE_graphics.image(img, 0, 0, RES1, RES2);

          DIFFUSE_graphics.noTint();
        }

        DIFFUSE_graphics.endDraw();

        File_Name += "_Camera00.png";

        DIFFUSE_graphics.save(File_Name);
        println("\n" + File_Name);
      }
    }
  } finally {
    if (sectionBakeProgressWindow != null) sectionBakeProgressWindow.dispose();

    allSolarImpacts.sectionType = keep_allSolarImpacts_sectionType;
    allSolarImpacts.R = keep_allSolarImpacts_rotation;
  }

  // Tops the console bar up to exactly 100 characters even if rounding
  // across totalFrames's own many small per-frame deltas left it a
  // character or two short - same wrap-up shape as import_objects_OBJ()'s
  // own identical lines (importObj.pde).
  int remaining = (int) floor(100 - printed_Progress);
  barBuffer.setLength(0);
  for (int c = 0; c < remaining; c++) {
    barBuffer.append('█');
  }
  print(barBuffer.toString());
  println();

  showArrowCursor();
}

void renderShadowFrame(float[] SunR, int SunR_Rotated_check, int SHD,
                        int RES1, int RES2, String File_Name, String finalExt) {

  TREES_graphics.beginDraw();

  TREES_graphics.blendMode(REPLACE);

  TREES_graphics.fill(255);
  TREES_graphics.stroke(255);
  TREES_graphics.strokeWeight(0);
  TREES_graphics.rectMode(CORNER);
  TREES_graphics.rect(0, 0, RES1, RES2);

  if ((SHD == 1) && (SunR[3] > 0) && (SunR_Rotated[SunR_Rotated_check] > 0)) { // i.e. one-sided plane

    TREES_graphics.pushMatrix();
    TREES_graphics.translate(RES1 / 2, RES2 / 2);

    TREES_graphics.stroke(0);
    TREES_graphics.fill(0);

    TREES_graphics.blendMode(BLEND);

    allModel2Ds.castShadows(SunR);

    TREES_graphics.popMatrix();
  }


  TREES_graphics.endDraw();

  TREES_graphics.save(File_Name + "_2D.jpg");



  SHADOW_graphics.beginDraw();

  SHADOW_graphics.blendMode(REPLACE);

  float _val = 0;
  if (SunR_Rotated[3] > 0) _val = SunR_Rotated[3];
  SHADOW_graphics.fill(255 * _val);
  SHADOW_graphics.stroke(255 * _val);
  SHADOW_graphics.strokeWeight(0);
  SHADOW_graphics.rectMode(CORNER);
  SHADOW_graphics.rect(0, 0, RES1, RES2);

  if ((SHD == 1) && (SunR[3] > 0) && (SunR_Rotated[SunR_Rotated_check] > 0)) { // i.e. one-sided plane

    SHADOW_graphics.pushMatrix();
    SHADOW_graphics.translate(RES1 / 2, RES2 / 2);

    SHADOW_graphics.stroke(0);
    SHADOW_graphics.fill(0);

    allFaces.castShadows();

    Terrain.castShadows();

    allModel1Ds.draw(TypeWindow.SHADOW);

    SHADOW_graphics.popMatrix();
  }


  SHADOW_graphics.save(File_Name + "3D_.jpg");

  if (allModel2Ds.displayAll) {

    PImage img = TREES_graphics.get();

    img.filter(THRESHOLD, 0.75); // Converts the image to black and white pixels depending if they are above or below the threshold defined by the level parameter.

    SHADOW_graphics.blendMode(DARKEST);

    SHADOW_graphics.tint(255, 255);

    SHADOW_graphics.image(img, 0, 0, RES1, RES2);

    SHADOW_graphics.noTint();
  }

  SHADOW_graphics.endDraw();


  SHADOW_graphics.save(File_Name + finalExt);
}
