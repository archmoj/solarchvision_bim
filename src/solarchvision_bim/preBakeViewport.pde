void preBakeViewport () {

  int preBakeViewport_startMillis = millis();

  showWaitCursor();

  println("PreBaking for Direct and Diffuse models. Please wait...");

  // Force a fresh build - see ShadeViewport.pde's own comment on this:
  // Model2Ds.addToFaceGrid()'s tree/person billboards are camera-facing,
  // and this method's own intersectAll() below (for each screen pixel)
  // needs that to reflect the camera as it is right now, not whatever it
  // was the last time anything rebuilt the grid. Gated the same way too -
  // no point forcing it when there's nothing camera-facing to refresh, or
  // when the part of the camera that actually matters (X/Y) hasn't moved
  // since the last real build.
  if (allModel2Ds.hasShadingContribution() && cameraHasMovedSinceFaceGridBuild()) {
    should_rebuildFaceGrid = true;
  }
  buildFaceGrid();

  cameraIndex = 0;

  allSolarImpacts.sectionType = 1; // <<<<< so that it analyzed later!

  int start_DATE_ANGLE = 0;
  int step_DATE_ANGLE = 30;
  int end_DATE_ANGLE = 360 - step_DATE_ANGLE;

  int start_HOUR = 4; // to make it faster. Also the images are not needed out of this period.
  int step_HOUR = 1;
  int end_HOUR = 20; // to make it faster. Also the images are not needed out of this period.

  SceneName = "Viewport_" + Viewport_Stamp();

  // The camera this whole bake - Direct/Diffuse PNGs, and the Model2Ds
  // mask - is actually computed from. See win3DOverlay_recordCameraState()'s
  // own comment (SolarImpacts.pde) for why this needs to happen here,
  // rather than wherever calculate_Impact_CurrentPreBaked() next happens
  // to run.
  allSolarImpacts.win3DOverlay_recordCameraState();

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

  int numDateAngles = (end_DATE_ANGLE - start_DATE_ANGLE) / step_DATE_ANGLE + 1;
  int numHours = (end_HOUR - start_HOUR) / step_HOUR + 1;
  int n_Map = numDateAngles * numHours;

  int[] Map_DATE_ANGLE = new int [n_Map];
  float[] Map_HOUR_ANGLE = new float [n_Map];

  {
    int m = 0;
    for (int DATE_ANGLE = start_DATE_ANGLE; DATE_ANGLE <= end_DATE_ANGLE; DATE_ANGLE += step_DATE_ANGLE) {
      for (int i = start_HOUR; i <= end_HOUR; i += step_HOUR) {
        Map_DATE_ANGLE[m] = DATE_ANGLE;
        Map_HOUR_ANGLE[m] = i;
        m += 1;
      }
    }
  }

  float[][] Map_DirectVector = new float [n_Map][3];
  float[][] Map_UnitDirectVector = new float [n_Map][3];
  boolean[] Map_SunBelowHorizon = new boolean [n_Map];

  for (int m = 0; m < n_Map; m++) {
    float[] SunR = funcs.SunPosition(STATION.getLatitude(), Map_DATE_ANGLE[m], Map_HOUR_ANGLE[m]);

    Map_DirectVector[m][0] = SunR[1];
    Map_DirectVector[m][1] = SunR[2];
    Map_DirectVector[m][2] = SunR[3];

    Map_UnitDirectVector[m] = funcs.vec3_unit(Map_DirectVector[m]);

    Map_SunBelowHorizon[m] = (SunR[3] < 0);
  }

  PImage[][] Direct_RGBA = new PImage [n_Map][2];

  int[] lastHitDirect = new int [n_Map]; // zero-filled by default
  int[] lastHitDiffuse = new int [DiffuseVectors.length]; // zero-filled by default

  float[][] UnitDiffuseVectors = new float [DiffuseVectors.length][3];
  for (int n_Ray = 0; n_Ray < DiffuseVectors.length; n_Ray++) {
    UnitDiffuseVectors[n_Ray] = funcs.vec3_unit(DiffuseVectors[n_Ray]);
  }

  for (int m = 0; m < n_Map; m++) {
    for (int SHD = 0; SHD <= 1; SHD++) {
      Direct_RGBA[m][SHD] = createImage(RES1, RES2, ARGB);
      Direct_RGBA[m][SHD].loadPixels();
    }
  }

  float Progress = 0;
  float printed_Progress = 0;
  StringBuilder barBuffer = new StringBuilder();

  progressBarHeader();
  for (int np = 0; np < (RES1 * RES2); np++) {
    int Image_X = np % RES1;
    int Image_Y = np / RES1;

    if (control != USER_AUTO) {
      Progress = 100 * np / float(RES1 * RES2);
      float delta = floor(Progress - printed_Progress);
      if (delta >= 1) {
        barBuffer.setLength(0);
        for (int c = 0; c < delta; c++) {
          barBuffer.append('█');
        }
        print(barBuffer.toString()); // one print() call instead of `delta` calls
        printed_Progress = floor(Progress);
      }
    }

    Image_X -= 0.5 * WIN3D.dX;
    Image_Y -= 0.5 * WIN3D.dY;


    float[] ray_direction = new float [3];

    float[] ray_start = {
      WIN3D.cameraX, WIN3D.cameraY, WIN3D.cameraZ
    };

    float[] ray_end = WIN3D.calculate_Click3D(Image_X * ScaleToFit, Image_Y * ScaleToFit);

    ray_start[0] /= overallScale;
    ray_start[1] /= overallScale;
    ray_start[2] /= overallScale;

    ray_end[0] /= overallScale;
    ray_end[1] /= overallScale;
    ray_end[2] /= overallScale;

    if (WIN3D.projectionTypeIndex == 0) {
      float[] ray_center = WIN3D.calculate_Click3D(0, 0);

      ray_center[0] /= overallScale;
      ray_center[1] /= overallScale;
      ray_center[2] /= overallScale;

      ray_start[0] += ray_end[0] - ray_center[0];
      ray_start[1] += ray_end[1] - ray_center[1];
      ray_start[2] += ray_end[2] - ray_center[2];
    }

    ray_direction[0] = ray_end[0] - ray_start[0];
    ray_direction[1] = ray_end[1] - ray_start[1];
    ray_direction[2] = ray_end[2] - ray_start[2];


    float[] RxP = intersectAll(ray_start, ray_direction);

    if (RxP[0] >= 0) {

      int f = int(RxP[0]);

      float[] COL = {
        0, 0, 0, 0
      };

      float[] face_norm = {RxP[5], RxP[6], RxP[7]};
      face_norm = funcs.vec3_unit(face_norm);

      {

        for (int n_Ray = 0; n_Ray < DiffuseVectors.length; n_Ray++) {

          float SkyMask = funcs.vec_dot(UnitDiffuseVectors[n_Ray], face_norm);

          // A backing direction (this face's normal points away from it)
          // contributes 0 to both Diffuse_Matrix rows regardless of
          // whether isIntersected_Faces() below would find it occluded -
          // SHD=0 adds SkyMask (0 either way) and SHD=1 adds either
          // SkyMask (0) or a flat 0, same result. So there's nothing the
          // ray cast could change here: skip it rather than pay for it
          // only to throw the result away. This is often true for roughly
          // half of DiffuseVectors on a vertical wall, and for nearly all
          // of them on a downward-facing underside.
          if (SkyMask <= 0) continue;

          // when SHD = 0;
          Diffuse_Matrix[0][np] += SkyMask / (float(DiffuseVectors.length) / 2.0);

          // new trace
          ray_start[0] = RxP[1];
          ray_start[1] = RxP[2];
          ray_start[2] = RxP[3];

          ray_direction[0] = DiffuseVectors[n_Ray][0];
          ray_direction[1] = DiffuseVectors[n_Ray][1];
          ray_direction[2] = DiffuseVectors[n_Ray][2];

          lastHitDiffuse[n_Ray] = isIntersected_Faces(ray_start, ray_direction, lastHitDiffuse[n_Ray], true); // people don't cast shadows - see entireFaceCastsShadow's own comment

          // when SHD = 1;
          if (lastHitDiffuse[n_Ray] == 0) {
            Diffuse_Matrix[1][np] += SkyMask / (float(DiffuseVectors.length) / 2.0);
          }
          // else: already left at its default 0 - no occluded-sky contribution.
        }
      }


      for (int m = 0; m < n_Map; m++) {

        // Below the horizon, both SHD=0 and SHD=1 come out color(0, 255)
        // regardless of what isIntersected_Faces() below would find - a
        // sun that isn't up can't light this pixel whether or not
        // something would otherwise have shaded it. Map_SunBelowHorizon[m]
        // depends only on m, not on this pixel, so this also skips every
        // other field the ray cast would otherwise need (ray_direction,
        // SunMask) for the same reason. Nothing the ray cast could change
        // here: skip it rather than pay for it only to throw the result
        // away.
        if (Map_SunBelowHorizon[m]) {
          Direct_RGBA[m][0].pixels[np] = color(0, 255);
          Direct_RGBA[m][1].pixels[np] = color(0, 255);
          continue;
        }

        // new trace
        ray_start[0] = RxP[1];
        ray_start[1] = RxP[2];
        ray_start[2] = RxP[3];

        ray_direction[0] = Map_DirectVector[m][0];
        ray_direction[1] = Map_DirectVector[m][1];
        ray_direction[2] = Map_DirectVector[m][2];

        float SunMask = funcs.vec_dot(Map_UnitDirectVector[m], face_norm);
        //if (SunMask <= 0) SunMask = 0; // removes backing faces

        // when SHD = 0;
        Direct_RGBA[m][0].pixels[np] = color(255 * SunMask, 255);

        // when SHD = 1;

        lastHitDirect[m] = isIntersected_Faces(ray_start, ray_direction, lastHitDirect[m], true); // people don't cast shadows - see entireFaceCastsShadow's own comment

        if (lastHitDirect[m] == 0) {
          Direct_RGBA[m][1].pixels[np] = color(255 * SunMask, 255);
        }
        else Direct_RGBA[m][1].pixels[np] = color(0, 255);
      }
    }
    else {

      for (int m = 0; m < n_Map; m++) {
        for (int SHD = 0; SHD <= 1; SHD++) {
          Direct_RGBA[m][SHD].pixels[np] = color(0,0,0,0);
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

  for (int m = 0; m < n_Map; m++) {

    for (int SHD = 0; SHD <= 1; SHD++) {

      String File_Name = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName;

      File_Name += nf(Map_DATE_ANGLE[m], 3) + "_" + STR_SHD[SHD] + "_" + nf(int(funcs.roundTo(Map_HOUR_ANGLE[m] * 100, 1.0)), 4);

      File_Name += "_Camera" + nf(cameraIndex, 2);

      Direct_RGBA[m][SHD].updatePixels();

      Direct_RGBA[m][SHD].save(File_Name + ".png");

      println(File_Name + ".png");
    }
  }

  PImage[] Diffuse_RGBA = new PImage [2];

  for (int SHD = 0; SHD <= 1; SHD++) {

    String File_Name = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName;

    File_Name += "DIF_" + STR_SHD[SHD];

    File_Name += "_Camera" + nf(cameraIndex, 2);

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



  // Bake the Model2Ds-only (tree/person) visibility mask alongside the
  // Direct/Diffuse images just saved above, at this same prebake
  // resolution and under the same Folder_Shadings/NearLatitude_Stamp()/
  // Camera folder - this is ShadeViewport_2DsTexture()'s own former body,
  // inlined here now that this is its only caller. No need to redo its
  // WIN3D.dX/dY/view_R/transform_3DViewport() setup: WIN3D.dX/dY are
  // already allSolarImpacts.RES1/RES2 from the top of this function, and
  // nothing since has touched them or the camera.
  camera2DTexture = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName + "2Ds_Camera" + nf(cameraIndex, 2) + ".png";

  float preShadingQuality = WIN3D.shadingQuality;
  WIN3D.shadingQuality = 1;

  noShadeOnlyVisible2DTextures = true;
  ShadeViewport();
  noShadeOnlyVisible2DTextures = false;

  // Same reasoning, same setup already in place - just the one extra
  // ShadeViewport() call, in its own mode, saving its own file. Rendered
  // at FACE_EDGE_RESOLUTION_MULTIPLIER times the usual resolution (see
  // that constant's own comment, ShadeViewport.pde): WIN3D.dX/dY
  // temporarily doubled for just this one call - ShadeViewport()'s own
  // invQuality already derives itself from whichever RES1/RES2 actually
  // end up in use (its own comment on that), rather than assuming
  // RES1/RES2 == WIN3D.dX/dY * quality, so the field of view comes out
  // correct at the higher resolution too with no other change needed.
  cameraFaceEdgesTexture = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName + "FaceEdges_Camera" + nf(cameraIndex, 2) + ".png";

  int pre_faceEdges_dX = WIN3D.dX;
  int pre_faceEdges_dY = WIN3D.dY;
  WIN3D.dX = pre_faceEdges_dX * FACE_EDGE_RESOLUTION_MULTIPLIER;
  WIN3D.dY = pre_faceEdges_dY * FACE_EDGE_RESOLUTION_MULTIPLIER;

  noShadeOnlyVisibleFaceEdges = true;
  ShadeViewport();
  noShadeOnlyVisibleFaceEdges = false;

  WIN3D.dX = pre_faceEdges_dX;
  WIN3D.dY = pre_faceEdges_dY;

  WIN3D.shadingQuality = preShadingQuality;

  showArrowCursor();

  WIN3D.dX = pre_WIN3D_dX;
  WIN3D.dY = pre_WIN3D_dY;
  WIN3D.view_R = float(WIN3D.dY) / float(WIN3D.dX);

  // Includes the two ShadeViewport() calls above (2Ds mask, face-edges
  // texture) - each also prints its own elapsed time on the way, so this
  // total and their two sub-totals are both visible, not just the sum.
  println("preBakeViewport() finished in " + nf((millis() - preBakeViewport_startMillis) / 1000.0, 0, 2) + "s");
}
