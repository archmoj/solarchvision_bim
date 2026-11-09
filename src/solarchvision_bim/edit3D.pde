class Edit3D {

  final static String CLASS_STAMP = "edit3D";

  int clamp (int n, int lo, int hi) {
    if (n > hi) n = hi;
    if (n < lo) n = lo;
    return n;
  }

  float clampF (float n, float lo, float hi) {
    if (n > hi) n = hi;
    if (n < lo) n = lo;
    return n;
  }

  void selection (int p) {
    if (currentObjectCategory == ObjectCategory.POLYLINE)     this.Polylines(p);
    else if (currentObjectCategory == ObjectCategory.FACE)    this.Faces(p);
    else if (currentObjectCategory == ObjectCategory.MODEL1D) this.Model1Ds(p);
    else if (currentObjectCategory == ObjectCategory.MODEL2D) this.Model2Ds(p);
    else if (currentObjectCategory == ObjectCategory.CAMERA)  this.Cameras(p);
    else if (currentObjectCategory == ObjectCategory.SOLID)   this.Solids(p);
    else if (currentObjectCategory == ObjectCategory.SECTION) this.Sections(p);
    else if (currentObjectCategory == ObjectCategory.GROUP)   this.Groups(p);
  }

  // Shared by Faces() and Groups() (for the faces owned by a group).
  void adjustFaceProperties (int f, int p) {
    if (User3D.currentTool == UITASK.Seed_Material) allFaces.setMaterial(f, clamp(allFaces.getMaterial(f) + p, 0, 8));
    else if (User3D.currentTool == UITASK.Tessellation)  allFaces.setTessellation(f, clamp(allFaces.getTessellation(f) + p, 0, 4));
    else if (User3D.currentTool == UITASK.Layer)         allFaces.setLayer(f, clamp(allFaces.getLayer(f) + p, 0, 16));
    else if (User3D.currentTool == UITASK.Visibility)    allFaces.setVisibility(f, clamp(allFaces.getVisibility(f) + p, 0, 2));
    else if (User3D.currentTool == UITASK.Weight)        allFaces.setWeight(f, clamp(allFaces.getWeight(f) + p, -20, 20));
  }

  // Shared by Polylines() and Groups() (for the polylines owned by a group).
  void adjustPolylineProperties (int f, int p) {
    if (User3D.currentTool == UITASK.Seed_Material) allPolylines.setMaterial(f, clamp(allPolylines.getMaterial(f) + p, 0, 8));
    else if (User3D.currentTool == UITASK.Tessellation)  allPolylines.setTessellation(f, clamp(allPolylines.getTessellation(f) + p, 0, 4));
    else if (User3D.currentTool == UITASK.Layer)         allPolylines.setLayer(f, clamp(allPolylines.getLayer(f) + p, 0, 16));
    else if (User3D.currentTool == UITASK.Visibility)    allPolylines.setVisibility(f, clamp(allPolylines.getVisibility(f) + p, 0, 2));
    else if (User3D.currentTool == UITASK.Weight)        allPolylines.setWeight(f, clamp(allPolylines.getWeight(f) + p, -20, 20));
  }

  void Faces (int p) {
    for (int o = Select3D.faceSelection.length - 1; o >= 0; o--) {
      int f = Select3D.faceSelection[o];
      adjustFaceProperties(f, p);
    }
  }

  void Polylines (int p) {
    for (int o = Select3D.polylineSelection.length - 1; o >= 0; o--) {
      int f = Select3D.polylineSelection[o];
      adjustPolylineProperties(f, p);
    }
  }

  void Groups (int p) {
    for (int o = Select3D.groupSelection.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.groupSelection[o];

      for (int f = allGroups.getStart_Face(OBJ_ID); f <= allGroups.getStop_Face(OBJ_ID); f++) {
        if ((0 <= f) && (f < allFaces.nodes.length)) {
          adjustFaceProperties(f, p);
        }
      }

      for (int f = allGroups.getStart_Polyline(OBJ_ID); f <= allGroups.getStop_Polyline(OBJ_ID); f++) {
        if ((0 <= f) && (f < allPolylines.nodes.length)) {
          adjustPolylineProperties(f, p);
        }
      }
    }
  }

  void Model1Ds (int p) {
    for (int o = Select3D.model1DSelection.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.model1DSelection[o];

      if (User3D.currentTool == UITASK.Seed_Material) {
        allModel1Ds.setSeed(OBJ_ID, allModel1Ds.getSeed(OBJ_ID) + p);
      }

      else if (User3D.currentTool == UITASK.DegreeMax) {
        int q = allModel1Ds.getDegreeMax(OBJ_ID) + p;
        if (q < 0) q = 12; // wraps, not a clamp
        if (q > 12) q = 0;

        allModel1Ds.setDegreeMax(OBJ_ID, q);
        User3D.creatorModel1DDegreeMax = q;
        UI_rollout.revise();
      }

      else if (User3D.currentTool == UITASK.BranchTilt) {
        float q = allModel1Ds.getBranchTilt(OBJ_ID) + p * 5;
        allModel1Ds.setBranchTilt(OBJ_ID, q);
        User3D.creatorModel1DBranchTilt = q;
        UI_rollout.revise();
      }

      else if (User3D.currentTool == UITASK.BranchTwist) {
        float q = allModel1Ds.getBranchTwist(OBJ_ID) + p * 5;
        allModel1Ds.setBranchTwist(OBJ_ID, q);
        User3D.creatorModel1DBranchTwist = q;
        UI_rollout.revise();
      }

      else if (User3D.currentTool == UITASK.BranchRatio) {
        float q = clampF(allModel1Ds.getBranchRatio(OBJ_ID) + 0.02 * p, 0.1, 1.0);
        allModel1Ds.setBranchRatio(OBJ_ID, q);
        User3D.creatorModel1DBranchRatio = q;
        UI_rollout.revise();
      }

      else if (User3D.currentTool == UITASK.TreeBase) {
        float q = clampF(allModel1Ds.getTreeBase(OBJ_ID) + 0.02 * p, 0.0, 4.0);
        allModel1Ds.setTreeBase(OBJ_ID, q);
        User3D.creatorModel1DTreeBase = q;
        UI_rollout.revise();
      }

      else if (User3D.currentTool == UITASK.TrunkSize) {
        float q = allModel1Ds.getTrunkSize(OBJ_ID) + 0.02 * p;
        if (q < 0) q = 0;

        allModel1Ds.setTrunkSize(OBJ_ID, q);
        User3D.creatorModel1DTrunkSize = q;
        UI_rollout.revise();
      }

      else if (User3D.currentTool == UITASK.LeafSize) {
        float q = allModel1Ds.getLeafSize(OBJ_ID) + 0.02 * p;
        if (q < 0) q = 0;

        allModel1Ds.setLeafSize(OBJ_ID, q);
        User3D.creatorModel1DLeafSize = q;
        UI_rollout.revise();
      }
    }
  }

  void Model2Ds (int p) {
    for (int o = Select3D.model2DSelection.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.model2DSelection[o];

      if (User3D.currentTool != UITASK.Seed_Material) continue;

      Model2DKind kind = allModel2Ds.Kind[OBJ_ID];
      boolean mirror = allModel2Ds.Mirror[OBJ_ID];

      int n = allModel2Ds.FileIndex[OBJ_ID] + p;

      // Wraps within this instance's own kind only - no more n1/n2
      // cross-family offset math, since each kind now has its own
      // local index space (see model2DKind.pde).
      if (n > kind.fileCount) { n = 1; mirror = !mirror; }
      if (n < 1) { n = kind.fileCount; mirror = !mirror; }

      allModel2Ds.FileIndex[OBJ_ID] = n;
      allModel2Ds.Mirror[OBJ_ID] = mirror;
    }
  }

  void Cameras (int p) {
    for (int o = Select3D.cameraSelection.length - 1; o >= 0; o--) {
      int f = Select3D.cameraSelection[o];

      if (User3D.currentTool == UITASK.Seed_Material) {
        int n = clamp(allCameras.get_type(f) + p, 0, 1);
        allCameras.set_type(f, n);

        if (f == WIN3D.currentCameraIndex) WIN3D.projectionTypeIndex = allCameras.get_type(f);
      }
    }
  }

  void Sections (int p) {
    boolean allSolids_updated = false;

    for (int o = Select3D.sectionSelection.length - 1; o >= 0; o--) {
      int f = Select3D.sectionSelection[o];

      if (User3D.currentTool == UITASK.Seed_Material) {
        allSections.set_type(f, clamp(allSections.get_type(f) + p, 0, 3));
        allSolids_updated = true;
      }

      else if (User3D.currentTool == UITASK.Tessellation) {
        int n = allSections.get_res1(f);
        if (p > 0) n *= 2;
        else if (p < 0) n /= 2;
        n = clamp(n, 100, 1600);

        allSections.set_res1(f, n);
        allSections.set_res2(f, n); // also modifying the other one

        allSolids_updated = true;
      }
    }

    if (allSolids_updated) allSolidImpacts.calculate_ImpactOnSections();
  }

  void Solids (int p) {
    boolean allSolids_updated = false;

    for (int o = Select3D.solidSelection.length - 1; o >= 0; o--) {
      int f = Select3D.solidSelection[o];

      boolean isPowerTask = (User3D.currentTool == UITASK.PowerX) || (User3D.currentTool == UITASK.PowerY) ||
                            (User3D.currentTool == UITASK.PowerZ) || (User3D.currentTool == UITASK.PowerAll);
      if (!isPowerTask) continue;

      float Solid_powX = allSolids.get_powX(f);
      float Solid_powY = allSolids.get_powY(f);
      float Solid_powZ = allSolids.get_powZ(f);

      float n = 2;
      if (User3D.currentTool == UITASK.PowerX) n = Solid_powX;
      else if (User3D.currentTool == UITASK.PowerY) n = Solid_powY;
      else if (User3D.currentTool == UITASK.PowerZ) n = Solid_powZ;
      else if (User3D.currentTool == UITASK.PowerAll) n = Solid_powX;

      if (p > 0) n *= 2;
      else if (p < 0) n /= 2;

      if (n > CubePower) n = StarPower; // wraps, not a clamp
      else if (n < StarPower) n = CubePower;

      if (User3D.currentTool == UITASK.PowerX) Solid_powX = n;
      else if (User3D.currentTool == UITASK.PowerY) Solid_powY = n;
      else if (User3D.currentTool == UITASK.PowerZ) Solid_powZ = n;
      else if (User3D.currentTool == UITASK.PowerAll) {
        Solid_powX = n;
        Solid_powY = n;
        Solid_powZ = n;
      }

      allSolids.updatePowers(f, Solid_powX, Solid_powY, Solid_powZ);
      allSolids_updated = true;
    }

    if (allSolids_updated) allSolidImpacts.calculate_ImpactOnSections();
  }
}
