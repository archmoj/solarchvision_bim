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

  {
    int RAD_TYPE = 0;

    for (int DATE_ANGLE = 0; DATE_ANGLE < 360; DATE_ANGLE += 15) {

      //for (int i = 0; i < 24; i++) {
      for (int i = 4; i <= 20; i++) { // to make it faster. Also the images are not needed out of this period.

        float HOUR_ANGLE = i;
        float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);
        SunR_Rotated = SunR;
        int SunR_Rotated_check = 3;

        if (allSolarImpacts.sectionType == 2) {
          float a = SunR_Rotated[1];
          float b = -SunR_Rotated[2];
          float c = SunR_Rotated[3];

          SunR_Rotated[1] = a * funcs.cos_ang(-allSolarImpacts.R) - b * funcs.sin_ang(-allSolarImpacts.R);
          SunR_Rotated[2] = c;
          SunR_Rotated[3] = a * funcs.sin_ang(-allSolarImpacts.R) + b * funcs.cos_ang(-allSolarImpacts.R);

          SunR_Rotated_check = 2;
        } else if (allSolarImpacts.sectionType == 3) {
        }

        for (int SHD = 0; SHD <= 1; SHD++) {

          String[] STR_SHD = {
            "F", "T"
          };
          String File_Name = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName;

          File_Name += nf(DATE_ANGLE, 3) + "_" + STR_SHD[SHD] + "_" + nf(int(funcs.roundTo(HOUR_ANGLE * 100, 1.0)), 4);

          File_Name += "_Camera00";

          TREES_graphics.beginDraw();

          TREES_graphics.blendMode(REPLACE);

          TREES_graphics.fill(255);
          TREES_graphics.stroke(255);
          TREES_graphics.strokeWeight(0);
          TREES_graphics.rectMode(CORNER);
          TREES_graphics.rect(0, 0, RES1, RES2);

          if ((SHD == 1) && (SunR[3] > 0) && (SunR_Rotated[SunR_Rotated_check] > 0)) { // i.e. one-sided plane

            TREES_graphics.pushMatrix();
            TREES_graphics.translate(allSolarImpacts.RES1 / 2, allSolarImpacts.RES2 / 2);

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
            SHADOW_graphics.translate(allSolarImpacts.RES1 / 2, allSolarImpacts.RES2 / 2);

            SHADOW_graphics.stroke(0);
            SHADOW_graphics.fill(0);

            allFaces.castShadows();

            Land3D.castShadows();

            allModel1Ds.draw(TypeWindow.SHADOW);

            SHADOW_graphics.popMatrix();
          }


          SHADOW_graphics.save(File_Name + "3D_.jpg"); //just to test

          if (allModel2Ds.displayAll) {

            PImage img = loadImage(File_Name + "_2D.jpg");

            img.filter(THRESHOLD, 0.75); // Converts the image to black and white pixels depending if they are above or below the threshold defined by the level parameter.

            SHADOW_graphics.blendMode(DARKEST);

            SHADOW_graphics.tint(255, 255);

            SHADOW_graphics.image(img, 0, 0, RES1, RES2);

            SHADOW_graphics.noTint();
          }

          SHADOW_graphics.endDraw();


          SHADOW_graphics.save(File_Name + ".png");
        }
      }
    }
  }


  {
    int RAD_TYPE = 1;

    for (int SHD = 0; SHD <= 1; SHD++) {

      String[] STR_SHD = {
        "F", "T"
      };
      String File_Name = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName;

      File_Name += "DIF_" + STR_SHD[SHD];

      for (int i = 0; i < DiffuseVectors.length; i++) {

        float[] SunR= {
          0, DiffuseVectors[i][0], DiffuseVectors[i][1], DiffuseVectors[i][2]
        };

        SunR_Rotated = SunR;
        int SunR_Rotated_check = 3;

        if (allSolarImpacts.sectionType == 2) {
          float a = SunR_Rotated[1];
          float b = -SunR_Rotated[2];
          float c = SunR_Rotated[3];

          SunR_Rotated[1] = a * funcs.cos_ang(-allSolarImpacts.R) - b * funcs.sin_ang(-allSolarImpacts.R);
          SunR_Rotated[2] = c;
          SunR_Rotated[3] = a * funcs.sin_ang(-allSolarImpacts.R) + b * funcs.cos_ang(-allSolarImpacts.R);

          SunR_Rotated_check = 2;
        } else if (allSolarImpacts.sectionType == 3) {
        }



        TREES_graphics.beginDraw();

        TREES_graphics.blendMode(REPLACE);

        TREES_graphics.fill(255);
        TREES_graphics.stroke(255);
        TREES_graphics.strokeWeight(0);
        TREES_graphics.rectMode(CORNER);
        TREES_graphics.rect(0, 0, RES1, RES2);

        if ((SHD == 1) && (SunR[3] > 0) && (SunR_Rotated[SunR_Rotated_check] > 0)) { // i.e. one-sided plane

          TREES_graphics.pushMatrix();
          TREES_graphics.translate(allSolarImpacts.RES1 / 2, allSolarImpacts.RES2 / 2);

          TREES_graphics.stroke(0);
          TREES_graphics.fill(0);

          TREES_graphics.blendMode(BLEND);

          allModel2Ds.castShadows(SunR);

          TREES_graphics.popMatrix();
        }


        TREES_graphics.endDraw();

        TREES_graphics.save(File_Name + nf(i, 3) + "_2D.jpg");



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
          SHADOW_graphics.translate(allSolarImpacts.RES1 / 2, allSolarImpacts.RES2 / 2);

          SHADOW_graphics.stroke(0);
          SHADOW_graphics.fill(0);

          allFaces.castShadows();

          Land3D.castShadows();

          allModel1Ds.draw(TypeWindow.SHADOW);

          SHADOW_graphics.popMatrix();
        }

        SHADOW_graphics.save(File_Name + "3D_.jpg"); //just to test

        if (allModel2Ds.displayAll) {

          PImage img = loadImage(File_Name + nf(i, 3) + "_2D.jpg");

          img.filter(THRESHOLD, 0.75); // Converts the image to black and white pixels depending if they are above or below the threshold defined by the level parameter.

          SHADOW_graphics.blendMode(DARKEST);

          SHADOW_graphics.tint(255, 255);

          SHADOW_graphics.image(img, 0, 0, RES1, RES2);

          SHADOW_graphics.noTint();
        }

        SHADOW_graphics.endDraw();

        SHADOW_graphics.save(File_Name + nf(i, 3) + ".jpg");
      }



      PGraphics DIFFUSE_graphics = createGraphics(RES1, RES2, P2D);

      DIFFUSE_graphics.beginDraw();

      DIFFUSE_graphics.blendMode(REPLACE);

      DIFFUSE_graphics.fill(0);
      DIFFUSE_graphics.stroke(0);
      DIFFUSE_graphics.strokeWeight(0);
      DIFFUSE_graphics.rectMode(CORNER);
      DIFFUSE_graphics.rect(0, 0, RES1, RES2);

      for (int i = 0; i < skyFaces.length; i++) {

        PImage img = loadImage(File_Name + nf(i, 3) + ".jpg");

        DIFFUSE_graphics.blendMode(ADD);

        DIFFUSE_graphics.tint(255, 255 / (0.5 * float(skyFaces.length)));

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
