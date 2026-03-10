class solarchvision_Edit3D {

  private final static String CLASS_STAMP = "Edit3D";

  void selection (int p) {

    if (current_ObjectCategory == ObjectCategory.POLYLINE) {
      this.Polylines(p);
    }

    if (current_ObjectCategory == ObjectCategory.FACE) {
      this.Faces(p);
    }

    if (current_ObjectCategory == ObjectCategory.MODEL1D) {
      this.Model1Ds(p);
    }

    if (current_ObjectCategory == ObjectCategory.MODEL2D) {
      this.Model2Ds(p);
    }

    if (current_ObjectCategory == ObjectCategory.CAMERA) {
      this.Cameras(p);
    }

    if (current_ObjectCategory == ObjectCategory.SOLID) {
      this.Solids(p);
    }

    if (current_ObjectCategory == ObjectCategory.SECTION) {
      this.Sections(p);
    }

    if (current_ObjectCategory == ObjectCategory.GROUP) {
      this.Groups(p);
    }

  }




  void Faces (int p) {

    for (int o = Select3D.Face_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = Select3D.Face_ids[o];

      int f = OBJ_ID;

      if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) {
        int n = allFaces.getMaterial(f);
        n += p;
        if (n > 8) n = 8;
        if (n < 0) n = 0;
        allFaces.setMaterial(f, n);
      }

      if (WIN3D.UI_CurrentTask == UITASK.Tessellation) {
        int n = allFaces.getTessellation(f);
        n += p;
        if (n > 4) n = 4;
        if (n < 0) n = 0;
        allFaces.setTessellation(f, n);
      }

      if (WIN3D.UI_CurrentTask == UITASK.Layer) {
        int n = allFaces.getLayer(f);
        n += p;
        if (n > 16) n = 16;
        if (n < 0) n = 0;
        allFaces.setLayer(f, n);
      }

      if (WIN3D.UI_CurrentTask == UITASK.Visibility) {
        int n = allFaces.getVisibility(f);
        n += p;
        if (n > 2) n = 2;
        if (n < 0) n = 0;
        allFaces.setVisibility(f, n);
      }

      if (WIN3D.UI_CurrentTask == UITASK.Weight) {
        int n = allFaces.getWeight(f);
        n += p;
        if (n > 20) n = 20;
        if (n < -20) n = -20;
        allFaces.setWeight(f, n);
      }
    }
  }

  void Polylines (int p) {

    for (int o = Select3D.Polyline_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = Select3D.Polyline_ids[o];

      int f = OBJ_ID;

      if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) {
        int n = allPolylines.getMaterial(f);
        n += p;
        if (n > 8) n = 8;
        if (n < 0) n = 0;
        allPolylines.setMaterial(f, n);
      }

      if (WIN3D.UI_CurrentTask == UITASK.Tessellation) {
        int n = allPolylines.getTessellation(f);
        n += p;
        if (n > 4) n = 4;
        if (n < 0) n = 0;
        allPolylines.setTessellation(f, n);
      }

      if (WIN3D.UI_CurrentTask == UITASK.Layer) {
        int n = allPolylines.getLayer(f);
        n += p;
        if (n > 16) n = 16;
        if (n < 0) n = 0;
        allPolylines.setLayer(f, n);
      }

      if (WIN3D.UI_CurrentTask == UITASK.Visibility) {
        int n = allPolylines.getVisibility(f);
        n += p;
        if (n > 2) n = 2;
        if (n < 0) n = 0;
        allPolylines.setVisibility(f, n);
      }

      if (WIN3D.UI_CurrentTask == UITASK.Weight) {
        int n = allPolylines.getWeight(f);
        n += p;
        if (n > 20) n = 20;
        if (n < -20) n = -20;
        allPolylines.setWeight(f, n);
      }
    }
  }




  void Groups (int p) {

    for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = Select3D.Group_ids[o];

      for (int f = allGroups.getStart_Face(OBJ_ID); f <= allGroups.getStop_Face(OBJ_ID); f++) {
        if ((0 <= f) && (f < allFaces.nodes.length)) {

          if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) {
            int n = allFaces.getMaterial(f);
            n += p;
            if (n > 8) n = 8;
            if (n < 0) n = 0;
            allFaces.setMaterial(f, n);
          }

          if (WIN3D.UI_CurrentTask == UITASK.Tessellation) {
            int n = allFaces.getTessellation(f);
            n += p;
            if (n > 4) n = 4;
            if (n < 0) n = 0;
            allFaces.setTessellation(f, n);
          }

          if (WIN3D.UI_CurrentTask == UITASK.Layer) {
            int n = allFaces.getLayer(f);
            n += p;
            if (n > 16) n = 16;
            if (n < 0) n = 0;
            allFaces.setLayer(f, n);
          }

          if (WIN3D.UI_CurrentTask == UITASK.Visibility) {
            int n = allFaces.getVisibility(f);
            n += p;
            if (n > 2) n = 2;
            if (n < 0) n = 0;
            allFaces.setVisibility(f, n);
          }

          if (WIN3D.UI_CurrentTask == UITASK.Weight) {
            int n = allFaces.getWeight(f);
            n += p;
            if (n > 20) n = 20;
            if (n < -20) n = -20;
            allFaces.setWeight(f, n);
          }
        }
      }

      for (int f = allGroups.getStart_Polyline(OBJ_ID); f <= allGroups.getStop_Polyline(OBJ_ID); f++) {
        if ((0 <= f) && (f < allPolylines.nodes.length)) {

          if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) {
            int n = allPolylines.getMaterial(f);
            n += p;
            if (n > 8) n = 8;
            if (n < 0) n = 0;
            allPolylines.setMaterial(f, n);
          }

          if (WIN3D.UI_CurrentTask == UITASK.Tessellation) {
            int n = allPolylines.getTessellation(f);
            n += p;
            if (n > 4) n = 4;
            if (n < 0) n = 0;
            allPolylines.setTessellation(f, n);
          }

          if (WIN3D.UI_CurrentTask == UITASK.Layer) {
            int n = allPolylines.getLayer(f);
            n += p;
            if (n > 16) n = 16;
            if (n < 0) n = 0;
            allPolylines.setLayer(f, n);
          }

          if (WIN3D.UI_CurrentTask == UITASK.Visibility) {
            int n = allPolylines.getVisibility(f);
            n += p;
            if (n > 2) n = 2;
            if (n < 0) n = 0;
            allPolylines.setVisibility(f, n);
          }

          if (WIN3D.UI_CurrentTask == UITASK.Weight) {
            int n = allPolylines.getWeight(f);
            n += p;
            if (n > 20) n = 20;
            if (n < -20) n = -20;
            allPolylines.setWeight(f, n);
          }
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
      if (WIN3D.UI_CurrentTask == UITASK.DegreeMax) {
        int q = allModel1Ds.getDegreeMax(OBJ_ID);

        q += p;

        if (q < 0) q = 12;
        if (q > 12) q = 0;

        allModel1Ds.setDegreeMax(OBJ_ID, q);

        User3D.create_Model1D_DegreeMax = q;
        ROLLOUT.revise();
      }
      if (WIN3D.UI_CurrentTask == UITASK.BranchTilt) {
        float q = allModel1Ds.getBranchTilt(OBJ_ID);

        q += p * 5;

        allModel1Ds.setBranchTilt(OBJ_ID, q);

        User3D.create_Model1D_BranchTilt = q;
        ROLLOUT.revise();
      }
      if (WIN3D.UI_CurrentTask == UITASK.BranchTwist) {
        float q = allModel1Ds.getBranchTwist(OBJ_ID);

        q += p * 5;

        allModel1Ds.setBranchTwist(OBJ_ID, q);

        User3D.create_Model1D_BranchTwist = q;
        ROLLOUT.revise();
      }
      if (WIN3D.UI_CurrentTask == UITASK.BranchRatio) {
        float q = allModel1Ds.getBranchRatio(OBJ_ID);

        q += 0.02 * p;

        if (q < 0.1) q = 0.1;
        if (q > 1.0) q = 1.0;

        allModel1Ds.setBranchRatio(OBJ_ID, q);

        User3D.create_Model1D_BranchRatio = q;
        ROLLOUT.revise();
      }
      if (WIN3D.UI_CurrentTask == UITASK.TreeBase) {
        float q = allModel1Ds.getTreeBase(OBJ_ID);

        q += 0.02 * p;

        if (q < 0.0) q = 0.0;
        if (q > 4.0) q = 4.0;

        allModel1Ds.setTreeBase(OBJ_ID, q);

        User3D.create_Model1D_TreeBase = q;
        ROLLOUT.revise();
      }
      if (WIN3D.UI_CurrentTask == UITASK.TrunkSize) {
        float q = allModel1Ds.getTrunkSize(OBJ_ID);

        q += 0.02 * p;

        if (q < 0) q = 0;

        allModel1Ds.setTrunkSize(OBJ_ID, q);

        User3D.create_Model1D_TrunkSize = q;
        ROLLOUT.revise();
      }
      if (WIN3D.UI_CurrentTask == UITASK.LeafSize) {
        float q = allModel1Ds.getLeafSize(OBJ_ID);

        q += 0.02 * p;

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

      if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) {

        int n = allModel2Ds.MAP[OBJ_ID];
        int sign_n = 1;
        if (n < 0) sign_n = -1;

        n = abs(n);

        int n1 = allModel2Ds.num_files_PEOPLE;
        int n2 = allModel2Ds.num_files_PEOPLE + allModel2Ds.num_files_TREES;

        if (allModel2Ds.isTree(n)) { // case: trees

          n += p;

          if (n > n2) {
            n = n1 + 1;
            sign_n *= -1;
          }
          if (n < n1 + 1) {
            n = n2;
            sign_n *= -1;
          }
        }
        else { // case: people

          n += p;

          if (n > n1) {
            n = 1;
            sign_n *= -1;
          }
          if (n < 1) {
            n = n1;
            sign_n *= -1;
          }
        }

        n *= sign_n;

        allModel2Ds.MAP[OBJ_ID] = n;
      }
    }
  }


  void Cameras (int p) {

    for (int o = Select3D.Camera_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = Select3D.Camera_ids[o];

      int f = OBJ_ID;

      if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) {
        int n = allCameras.get_type(f);
        n += p;
        if (n > 1) n = 1;
        if (n < 0) n = 0;
        allCameras.set_type(f, n);

        if (f == WIN3D.currentCamera) WIN3D.ViewType = allCameras.get_type(f);
      }
    }
  }

  void Sections (int p) {

    boolean allSolids_updated = false;

    for (int o = Select3D.Section_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = Select3D.Section_ids[o];

      int f = OBJ_ID;

      if (WIN3D.UI_CurrentTask == UITASK.Seed_Material) {
        int n = allSections.get_type(f);
        n += p;
        if (n > 3) n = 3;
        if (n < 0) n = 0;
        allSections.set_type(f, n);

        allSolids_updated = true;
      }

      if (WIN3D.UI_CurrentTask == UITASK.Tessellation) {
        int n = allSections.get_res1(f);
        if (p > 0) n *= 2;
        if (p < 0) n /= 2;

        if (n > 1600) n = 1600;
        if (n < 100) n = 100;
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

      int OBJ_ID = Select3D.Solid_ids[o];

      int f = OBJ_ID;

      if ((WIN3D.UI_CurrentTask == UITASK.PowerX) ||  (WIN3D.UI_CurrentTask == UITASK.PowerY) ||  (WIN3D.UI_CurrentTask == UITASK.PowerZ) ||  (WIN3D.UI_CurrentTask == UITASK.PowerAll)) {


        float Solid_powX = allSolids.get_powX(f);
        float Solid_powY = allSolids.get_powY(f);
        float Solid_powZ = allSolids.get_powZ(f);


        float n = 2;

        if (WIN3D.UI_CurrentTask == UITASK.PowerX) n = Solid_powX;
        if (WIN3D.UI_CurrentTask == UITASK.PowerY) n = Solid_powY;
        if (WIN3D.UI_CurrentTask == UITASK.PowerZ) n = Solid_powZ;
        if (WIN3D.UI_CurrentTask == UITASK.PowerAll) {
          n = Solid_powX;
        }

        if (p > 0) n *= 2;
        if (p < 0) n /= 2;

        if (n > CubePower) n = StarPower;
        if (n < StarPower) n = CubePower;

        if (WIN3D.UI_CurrentTask == UITASK.PowerX) Solid_powX = n;
        if (WIN3D.UI_CurrentTask == UITASK.PowerY) Solid_powY = n;
        if (WIN3D.UI_CurrentTask == UITASK.PowerZ) Solid_powZ = n;
        if (WIN3D.UI_CurrentTask == UITASK.PowerAll) {
          Solid_powX = n;
          Solid_powY = n;
          Solid_powZ = n;
        }

        allSolids.updatePowers(f, Solid_powX, Solid_powY, Solid_powZ);

        allSolids_updated = true;
      }
    }

    if (allSolids_updated) allSolidImpacts.calculate_Impact_selectedSections();
  }
}
