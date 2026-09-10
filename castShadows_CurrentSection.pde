void SOLARCHVISION_castShadows_CurrentSection () {

  cursor(WAIT);

  SceneName = "Section_" + Section_Stamp();


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

  // allSolarImpacts.sectionType / .R don't change again until the very end
  // of this function, so the rotation trig only needs to be computed once
  // instead of on every one of the hundreds of inner-loop iterations below.
  boolean rotate = (allSolarImpacts.sectionType == 2);
  float cosR = 0, sinR = 0;
  if (rotate) {
    cosR = funcs.cos_ang(-allSolarImpacts.R);
    sinR = funcs.sin_ang(-allSolarImpacts.R);
  }

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

          String File_Name = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName;

          File_Name += nf(DATE_ANGLE, 3) + "_" + STR_SHD[SHD] + "_" + nf(int(funcs.roundTo(HOUR_ANGLE * 100, 1.0)), 4);

          File_Name += "_Camera00";

          renderShadowFrame(SunR, SunR_Rotated_check, SHD, RES1, RES2, File_Name, ".png");
        }
      }
    }
  }


  {
    int RAD_TYPE = 1;

    // Created once here instead of inside the SHD loop below (was being
    // recreated twice per call) - matches the pattern already used for
    // TREES_graphics/SHADOW_graphics, which are created once and reused
    // via beginDraw()/rect() each pass rather than reallocated.
    PGraphics DIFFUSE_graphics = createGraphics(RES1, RES2, P2D);

    for (int SHD = 0; SHD <= 1; SHD++) {

      String File_Name = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName;

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

        // Grab the frame we just rendered straight from SHADOW_graphics
        // instead of reloading the JPEG renderShadowFrame() just saved -
        // same round-trip-avoidance as the TREES_graphics change earlier,
        // applied here since these per-diffuse-vector frames get
        // recomposited into DIFFUSE_graphics right below.
        shadowFrames[i] = SHADOW_graphics.get();
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
      println(File_Name);
    }
  }

  allSolarImpacts.sectionType = keep_allSolarImpacts_sectionType;
  allSolarImpacts.R = keep_allSolarImpacts_rotation;

  cursor(ARROW);
}

// Renders one shadow frame (TREES_graphics mask pass + SHADOW_graphics pass)
// and saves both. This is the logic that used to be duplicated identically
// in the direct-sun block and the diffuse-sky block; extracted here
// unchanged, just parameterized on the values that differed between the
// two call sites (File_Name, and the SHADOW output's extension).
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

    Land3D.castShadows();

    allModel1Ds.draw(TypeWindow.SHADOW);

    SHADOW_graphics.popMatrix();
  }


  SHADOW_graphics.save(File_Name + "3D_.jpg"); //just to test

  if (allModel2Ds.displayAll) {

    // Use the pixels already sitting in TREES_graphics instead of
    // reloading the JPEG we just wrote to disk one line above -
    // avoids a full JPEG encode+decode round trip per frame.
    // NOTE: this reads the uncompressed render rather than the
    // JPEG-compressed copy, so the threshold mask may differ very
    // slightly (fewer compression artifacts) from the original.
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
