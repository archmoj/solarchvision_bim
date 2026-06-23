void SOLARCHVISION_preBakeViewport () {

  cursor(WAIT);

  println("PreBaking for Direct and Diffuse models. Please wait...");

  Camera_Variation = 0;

  allSolarImpacts.sectionType = 1; // <<<<< so that it analyzed later!

  int start_DATE_ANGLE = 0;
  int step_DATE_ANGLE = 30;
  int end_DATE_ANGLE = 360 - step_DATE_ANGLE;

  int start_HOUR = 4; // to make it faster. Also the images are not needed out of this period.
  int step_HOUR = 1;
  int end_HOUR = 20; // to make it faster. Also the images are not needed out of this period.

  SceneName = "Viewport_" + Viewport_Stamp();

  int pre_WIN3D_dX = WIN3D.dX;
  int pre_WIN3D_dY = WIN3D.dY;

  WIN3D.dX = allSolarImpacts.RES1;
  WIN3D.dY = allSolarImpacts.RES2;
  WIN3D.view_R = float(WIN3D.dY) / float(WIN3D.dX);

  WIN3D.transform_3DViewport();

  //WIN3D.put_3DViewport();  //????????????

  float ScaleToFit = float(pre_WIN3D_dY) / float(WIN3D.dY);


  int RES1 = WIN3D.dX;
  int RES2 = WIN3D.dY;

  float[][] Diffuse_Matrix = new float [2][(RES1 * RES2)];

  for (int SHD = 0; SHD <= 1; SHD++) {
    for (int np = 0; np < (RES1 * RES2); np++) {
      Diffuse_Matrix[SHD][np] = 0;
    }
  }

  int n_Map = 0;
  for (int DATE_ANGLE = start_DATE_ANGLE; DATE_ANGLE <= end_DATE_ANGLE; DATE_ANGLE += step_DATE_ANGLE) {

    for (int i = start_HOUR; i <= end_HOUR; i += step_HOUR) {
      n_Map += 1;
    }
  }

  PImage[][] Direct_RGBA = new PImage [n_Map][2];


  int[] lastHitDirect = new int [n_Map];

  for (int i = 0; i < lastHitDirect.length; i++) {
    lastHitDirect[i] = 0;
  }

  int[] lastHitDiffuse = new int [DiffuseVectors.length];

  for (int i = 0; i < lastHitDiffuse.length; i++) {
    lastHitDiffuse[i] = 0;
  }


  n_Map = -1;
  for (int DATE_ANGLE = start_DATE_ANGLE; DATE_ANGLE <= end_DATE_ANGLE; DATE_ANGLE += step_DATE_ANGLE) {

    for (int i = start_HOUR; i <= end_HOUR; i += step_HOUR) {
      n_Map += 1;

      for (int SHD = 0; SHD <= 1; SHD++) {

        Direct_RGBA[n_Map][SHD] = createImage(RES1, RES2, ARGB);

        Direct_RGBA[n_Map][SHD].loadPixels();
      }
    }
  }

  float Progress = 0;
  float printed_Progress = 0;
  progressBarHeader();
  for (int np = 0; np < (RES1 * RES2); np++) {
    int Image_X = np % RES1;
    int Image_Y = np / RES1;

    Progress = 100 * np / float(RES1 * RES2);
    float delta = floor(Progress - printed_Progress);
    if(delta >= 1) {
      for(int c = 0; c < delta; c++) {
        print("█");
      }
      printed_Progress = floor(Progress);
    }

    Image_X -= 0.5 * WIN3D.dX;
    Image_Y -= 0.5 * WIN3D.dY;


    float[] ray_direction = new float [3];

    float[] ray_start = {
      WIN3D.CAM_x, WIN3D.CAM_y, WIN3D.CAM_z
    };

    float[] ray_end = WIN3D.calculate_Click3D(Image_X * ScaleToFit, Image_Y * ScaleToFit);

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

    RxP = allFaces.intersect(ray_start, ray_direction);

    if (RxP[0] >= 0) {

      int f = int(RxP[0]);

      float[] COL = {
        0, 0, 0, 0
      };

      float[] face_norm = {RxP[5], RxP[6], RxP[7]};
      face_norm = funcs.vec3_unit(face_norm);

      {

        for (int n_Ray = 0; n_Ray < DiffuseVectors.length; n_Ray++) {

          // new trace
          ray_start[0] = RxP[1];
          ray_start[1] = RxP[2];
          ray_start[2] = RxP[3];

          ray_direction[0] = DiffuseVectors[n_Ray][0];
          ray_direction[1] = DiffuseVectors[n_Ray][1];
          ray_direction[2] = DiffuseVectors[n_Ray][2];

          float SkyMask = funcs.vec_dot(funcs.vec3_unit(DiffuseVectors[n_Ray]), funcs.vec3_unit(face_norm));
          if (SkyMask < 0) SkyMask = 0; // removes backing faces

          // when SHD = 0;
          Diffuse_Matrix[0][np] += SkyMask / float(DiffuseVectors.length);

          lastHitDiffuse[n_Ray] = SOLARCHVISION_isIntersected_Faces(ray_start, ray_direction, lastHitDiffuse[n_Ray]);

          // when SHD = 1;
          if (lastHitDiffuse[n_Ray] == 0) {
            Diffuse_Matrix[1][np] += SkyMask / float(DiffuseVectors.length);
          }
          else Diffuse_Matrix[1][np] += 0;
        }
      }


      n_Map = -1;
      for (int DATE_ANGLE = start_DATE_ANGLE; DATE_ANGLE <= end_DATE_ANGLE; DATE_ANGLE += step_DATE_ANGLE) {

        for (int i = start_HOUR; i <= end_HOUR; i += step_HOUR) {
          n_Map += 1;

          float HOUR_ANGLE = i;

          float[] SunR = funcs.SunPosition(STATION.getLatitude(), DATE_ANGLE, HOUR_ANGLE);

          float[] DirectVector = {
            SunR[1], SunR[2], SunR[3]
          };

          // new trace
          ray_start[0] = RxP[1];
          ray_start[1] = RxP[2];
          ray_start[2] = RxP[3];

          ray_direction[0] = DirectVector[0];
          ray_direction[1] = DirectVector[1];
          ray_direction[2] = DirectVector[2];

          float SunMask = funcs.vec_dot(funcs.vec3_unit(DirectVector), funcs.vec3_unit(face_norm));
          //if (SunMask <= 0) SunMask = 0; // removes backing faces

          // when SHD = 0;
          Direct_RGBA[n_Map][0].pixels[np] = (SunR[3] < 0) ? color(0, 255) : color(255 * SunMask, 255);

          // when SHD = 1;

          lastHitDirect[n_Map] = SOLARCHVISION_isIntersected_Faces(ray_start, ray_direction, lastHitDirect[n_Map]);

          if (lastHitDirect[n_Map] == 0) {
            Direct_RGBA[n_Map][1].pixels[np] = (SunR[3] < 0) ? color(0, 255) : color(255 * SunMask, 255);
          }
          else Direct_RGBA[n_Map][1].pixels[np] = color(0, 255);
        }
      }
    }
    else {

      n_Map = -1;
      for (int DATE_ANGLE = start_DATE_ANGLE; DATE_ANGLE <= end_DATE_ANGLE; DATE_ANGLE += step_DATE_ANGLE) {

        for (int i = start_HOUR; i <= end_HOUR; i += step_HOUR) {
          n_Map += 1;

          for (int SHD = 0; SHD <= 1; SHD++) {

            Direct_RGBA[n_Map][SHD].pixels[np] = color(0,0,0,0);

          }
        }
      }

      for (int SHD = 0; SHD <= 1; SHD++) {

        Diffuse_Matrix[SHD][np] = FLOAT_undefined;

      }

    }

  }

  for(int c = 0; c < floor(100 - printed_Progress); c++) {
    print("█");
  }
  println();

  n_Map = -1;
  for (int DATE_ANGLE = start_DATE_ANGLE; DATE_ANGLE <= end_DATE_ANGLE; DATE_ANGLE += step_DATE_ANGLE) {

    for (int i = start_HOUR; i <= end_HOUR; i += step_HOUR) {
      n_Map += 1;

      float HOUR_ANGLE = i;

      for (int SHD = 0; SHD <= 1; SHD++) {

        String[] STR_SHD = {
          "F", "T"
        };
        String File_Name = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName;

        File_Name += nf(DATE_ANGLE, 3) + "_" + STR_SHD[SHD] + "_" + nf(int(funcs.roundTo(HOUR_ANGLE * 100, 1.0)), 4);

        File_Name += "_Camera" + nf(Camera_Variation, 2);

        Direct_RGBA[n_Map][SHD].updatePixels();

        Direct_RGBA[n_Map][SHD].save(File_Name + ".png");

        println(File_Name + ".png");
      }
    }
  }

  PImage[] Diffuse_RGBA = new PImage [2];

  for (int SHD = 0; SHD <= 1; SHD++) {

    String[] STR_SHD = {
      "F", "T"
    };
    String File_Name = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName;

    File_Name += "DIF_" + STR_SHD[SHD];

    File_Name += "_Camera" + nf(Camera_Variation, 2);

    Diffuse_RGBA[SHD] = createImage(RES1, RES2, ARGB);

    Diffuse_RGBA[SHD].loadPixels();

    for (int np = 0; np < (RES1 * RES2); np++) {

      if (is_defined(Diffuse_Matrix[SHD][np])) {

        Diffuse_RGBA[SHD].pixels[np] = color(255 * Diffuse_Matrix[SHD][np], 255);
      }
      else {

        Diffuse_RGBA[SHD].pixels[np] = color(0,0,0,0);
      }
    }

    Diffuse_RGBA[SHD].updatePixels();


    Diffuse_RGBA[SHD].save(File_Name + ".png");

    println(File_Name + ".png");
  }



  cursor(ARROW);

  WIN3D.dX = pre_WIN3D_dX;
  WIN3D.dY = pre_WIN3D_dY;
  WIN3D.view_R = float(WIN3D.dY) / float(WIN3D.dX);
}
