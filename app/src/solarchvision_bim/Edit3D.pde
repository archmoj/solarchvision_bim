class solarchvision_Edit3D {

  private final static String CLASS_STAMP = "Edit3D";

  private int clamp (int n, int lo, int hi) {
    if (n > hi) n = hi;
    if (n < lo) n = lo;
    return n;
  }

  private float clampF (float n, float lo, float hi) {
    if (n > hi) n = hi;
    if (n < lo) n = lo;
    return n;
  }

  void selection (int p) {
    if (current_ObjectCategory == ObjectCategory.POLYLINE)     this.Polylines(p);
    else if (current_ObjectCategory == ObjectCategory.FACE)    this.Faces(p);
    else if (current_ObjectCategory == ObjectCategory.MODEL1D) this.Model1Ds(p);
    else if (current_ObjectCategory == ObjectCategory.MODEL2D) this.Model2Ds(p);
    else if (current_ObjectCategory == ObjectCategory.CAMERA)  this.Cameras(p);
    else if (current_ObjectCategory == ObjectCategory.SOLID)   this.Solids(p);
    else if (current_ObjectCategory == ObjectCategory.SECTION) this.Sections(p);
    else if (current_ObjectCategory == ObjectCategory.GROUP)   this.Groups(p);
  }

  // Shared by Faces() and Groups() (for the faces owned by a group).
  private void adjustFaceProperties (int f, int p) {
    if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) allFaces.setMaterial(f, clamp(allFaces.getMaterial(f) + p, 0, 8));
    else if (WIN3D.UI_CurrentTask == UITASK.Tessellation)  allFaces.setTessellation(f, clamp(allFaces.getTessellation(f) + p, 0, 4));
    else if (WIN3D.UI_CurrentTask == UITASK.Layer)         allFaces.setLayer(f, clamp(allFaces.getLayer(f) + p, 0, 16));
    else if (WIN3D.UI_CurrentTask == UITASK.Visibility)    allFaces.setVisibility(f, clamp(allFaces.getVisibility(f) + p, 0, 2));
    else if (WIN3D.UI_CurrentTask == UITASK.Weight)        allFaces.setWeight(f, clamp(allFaces.getWeight(f) + p, -20, 20));
  }

  // Shared by Polylines() and Groups() (for the polylines owned by a group).
  private void adjustPolylineProperties (int f, int p) {
    if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) allPolylines.setMaterial(f, clamp(allPolylines.getMaterial(f) + p, 0, 8));
    else if (WIN3D.UI_CurrentTask == UITASK.Tessellation)  allPolylines.setTessellation(f, clamp(allPolylines.getTessellation(f) + p, 0, 4));
    else if (WIN3D.UI_CurrentTask == UITASK.Layer)         allPolylines.setLayer(f, clamp(allPolylines.getLayer(f) + p, 0, 16));
    else if (WIN3D.UI_CurrentTask == UITASK.Visibility)    allPolylines.setVisibility(f, clamp(allPolylines.getVisibility(f) + p, 0, 2));
    else if (WIN3D.UI_CurrentTask == UITASK.Weight)        allPolylines.setWeight(f, clamp(allPolylines.getWeight(f) + p, -20, 20));
  }

  void Faces (int p) {
    for (int o = Select3D.Face_ids.length - 1; o >= 0; o--) {
      int f = Select3D.Face_ids[o];
      adjustFaceProperties(f, p);
    }
  }

  void Polylines (int p) {
    for (int o = Select3D.Polyline_ids.length - 1; o >= 0; o--) {
      int f = Select3D.Polyline_ids[o];
      adjustPolylineProperties(f, p);
    }
  }

  void Groups (int p) {
    for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.Group_ids[o];

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
    for (int o = Select3D.Model1D_ids.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.Model1D_ids[o];

      if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) {
        allModel1Ds.setSeed(OBJ_ID, allModel1Ds.getSeed(OBJ_ID) + p);
      }

      else if (WIN3D.UI_CurrentTask == UITASK.DegreeMax) {
        int q = allModel1Ds.getDegreeMax(OBJ_ID) + p;
        if (q < 0) q = 12; // wraps, not a clamp
        if (q > 12) q = 0;

        allModel1Ds.setDegreeMax(OBJ_ID, q);
        User3D.create_Model1D_DegreeMax = q;
        ROLLOUT.revise();
      }

      else if (WIN3D.UI_CurrentTask == UITASK.BranchTilt) {
        float q = allModel1Ds.getBranchTilt(OBJ_ID) + p * 5;
        allModel1Ds.setBranchTilt(OBJ_ID, q);
        User3D.create_Model1D_BranchTilt = q;
        ROLLOUT.revise();
      }

      else if (WIN3D.UI_CurrentTask == UITASK.BranchTwist) {
        float q = allModel1Ds.getBranchTwist(OBJ_ID) + p * 5;
        allModel1Ds.setBranchTwist(OBJ_ID, q);
        User3D.create_Model1D_BranchTwist = q;
        ROLLOUT.revise();
      }

      else if (WIN3D.UI_CurrentTask == UITASK.BranchRatio) {
        float q = clampF(allModel1Ds.getBranchRatio(OBJ_ID) + 0.02 * p, 0.1, 1.0);
        allModel1Ds.setBranchRatio(OBJ_ID, q);
        User3D.create_Model1D_BranchRatio = q;
        ROLLOUT.revise();
      }

      else if (WIN3D.UI_CurrentTask == UITASK.TreeBase) {
        float q = clampF(allModel1Ds.getTreeBase(OBJ_ID) + 0.02 * p, 0.0, 4.0);
        allModel1Ds.setTreeBase(OBJ_ID, q);
        User3D.create_Model1D_TreeBase = q;
        ROLLOUT.revise();
      }

      else if (WIN3D.UI_CurrentTask == UITASK.TrunkSize) {
        float q = allModel1Ds.getTrunkSize(OBJ_ID) + 0.02 * p;
        if (q < 0) q = 0;

        allModel1Ds.setTrunkSize(OBJ_ID, q);
        User3D.create_Model1D_TrunkSize = q;
        ROLLOUT.revise();
      }

      else if (WIN3D.UI_CurrentTask == UITASK.LeafSize) {
        float q = allModel1Ds.getLeafSize(OBJ_ID) + 0.02 * p;
        if (q < 0) q = 0;

        allModel1Ds.setLeafSize(OBJ_ID, q);
        User3D.create_Model1D_LeafSize = q;
        ROLLOUT.revise();
      }
    }
  }

  void Model2Ds (int p) {
    for (int o = Select3D.Model2D_ids.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.Model2D_ids[o];

      if (WIN3D.UI_CurrentTask != UITASK.Seed_Material) continue;

      int n = allModel2Ds.MAP[OBJ_ID];
      int sign_n = (n < 0) ? -1 : 1;
      n = abs(n);

      int n1 = allModel2Ds.num_files_PEOPLE;
      int n2 = allModel2Ds.num_files_PEOPLE + allModel2Ds.num_files_TREES;

      n += p;

      if (allModel2Ds.isTree(n)) { // case: trees
        if (n > n2) { n = n1 + 1; sign_n *= -1; }
        if (n < n1 + 1) { n = n2; sign_n *= -1; }
      } else { // case: people
        if (n > n1) { n = 1; sign_n *= -1; }
        if (n < 1) { n = n1; sign_n *= -1; }
      }

      allModel2Ds.MAP[OBJ_ID] = n * sign_n;
    }
  }

  void Cameras (int p) {
    for (int o = Select3D.Camera_ids.length - 1; o >= 0; o--) {
      int f = Select3D.Camera_ids[o];

      if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) {
        int n = clamp(allCameras.get_type(f) + p, 0, 1);
        allCameras.set_type(f, n);

        if (f == WIN3D.currentCamera) WIN3D.ViewType = allCameras.get_type(f);
      }
    }
  }

  void Sections (int p) {
    boolean allSolids_updated = false;

    for (int o = Select3D.Section_ids.length - 1; o >= 0; o--) {
      int f = Select3D.Section_ids[o];

      if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) {
        allSections.set_type(f, clamp(allSections.get_type(f) + p, 0, 3));
        allSolids_updated = true;
      }

      else if (WIN3D.UI_CurrentTask == UITASK.Tessellation) {
        int n = allSections.get_res1(f);
        if (p > 0) n *= 2;
        else if (p < 0) n /= 2;
        n = clamp(n, 100, 1600);

        allSections.set_res1(f, n);
        allSections.set_res2(f, n); // also modifying the other one
        println("RES:", n);

        allSolids_updated = true;
      }
    }

    if (allSolids_updated) allSolidImpacts.calculate_Impact_selectedSections();
  }

  void Solids (int p) {
    boolean allSolids_updated = false;

    for (int o = Select3D.Solid_ids.length - 1; o >= 0; o--) {
      int f = Select3D.Solid_ids[o];

      boolean isPowerTask = (WIN3D.UI_CurrentTask == UITASK.PowerX) || (WIN3D.UI_CurrentTask == UITASK.PowerY) ||
                            (WIN3D.UI_CurrentTask == UITASK.PowerZ) || (WIN3D.UI_CurrentTask == UITASK.PowerAll);
      if (!isPowerTask) continue;

      float Solid_powX = allSolids.get_powX(f);
      float Solid_powY = allSolids.get_powY(f);
      float Solid_powZ = allSolids.get_powZ(f);

      float n = 2;
      if (WIN3D.UI_CurrentTask == UITASK.PowerX) n = Solid_powX;
      else if (WIN3D.UI_CurrentTask == UITASK.PowerY) n = Solid_powY;
      else if (WIN3D.UI_CurrentTask == UITASK.PowerZ) n = Solid_powZ;
      else if (WIN3D.UI_CurrentTask == UITASK.PowerAll) n = Solid_powX;

      if (p > 0) n *= 2;
      else if (p < 0) n /= 2;

      if (n > CubePower) n = StarPower; // wraps, not a clamp
      else if (n < StarPower) n = CubePower;

      if (WIN3D.UI_CurrentTask == UITASK.PowerX) Solid_powX = n;
      else if (WIN3D.UI_CurrentTask == UITASK.PowerY) Solid_powY = n;
      else if (WIN3D.UI_CurrentTask == UITASK.PowerZ) Solid_powZ = n;
      else if (WIN3D.UI_CurrentTask == UITASK.PowerAll) {
        Solid_powX = n;
        Solid_powY = n;
        Solid_powZ = n;
      }

      allSolids.updatePowers(f, Solid_powX, Solid_powY, Solid_powZ);
      allSolids_updated = true;
    }

    if (allSolids_updated) allSolidImpacts.calculate_Impact_selectedSections();
  }
}
