class Clone3D {

  final static String CLASS_STAMP = "Clone3D";

  void selection (boolean produce_same_variation) {
    if (currentObjectCategory == ObjectCategory.TERRAIN) {
      // nothing to clone
    } else if (currentObjectCategory == ObjectCategory.MODEL1D) {
      this.Model1Ds(produce_same_variation);
    } else if (currentObjectCategory == ObjectCategory.MODEL2D) {
      this.Model2Ds(produce_same_variation);
    } else if (currentObjectCategory == ObjectCategory.FACE) {
      this.Faces(produce_same_variation);
    } else if (currentObjectCategory == ObjectCategory.POLYLINE) {
      this.Polylines(produce_same_variation);
    } else if (currentObjectCategory == ObjectCategory.SOLID) {
      this.Solids(produce_same_variation);
    } else if (currentObjectCategory == ObjectCategory.SECTION) {
      this.Sections(produce_same_variation);
    } else if (currentObjectCategory == ObjectCategory.CAMERA) {
      this.Cameras(produce_same_variation);
    } else if (currentObjectCategory == ObjectCategory.GROUP) {
      this.Groups(produce_same_variation);
    }
  }

  // Appends the integer range [start, endExclusive) onto `ids` and returns
  // the result. Used to select newly-created objects after a clone pass.
  int[] appendRange (int[] ids, int start, int endExclusive) {
    if (start >= endExclusive) return ids;
    int[] added = new int[endExclusive - start];
    for (int i = 0; i < added.length; i++) added[i] = start + i;
    return concat(ids, added);
  }

  // Clones the vertices referenced by `nodes`. Vertices already present in
  // vertexMap (old vertex id -> new vertex id) are reused instead of being
  // cloned again, so shared edges/vertices stay shared on the clone.
  int[] cloneNodes (int[] nodes, HashMap<Integer, Integer> vertexMap) {
    int[] newNodes = new int[nodes.length];
    for (int j = 0; j < nodes.length; j++) {
      int vNo = nodes[j];
      Integer newVNo = vertexMap.get(vNo);
      if (newVNo == null) {
        float x = allPoints.getX(vNo);
        float y = allPoints.getY(vNo);
        float z = allPoints.getZ(vNo);
        newVNo = allPoints.create(x, y, z);
        vertexMap.put(vNo, newVNo);
      }
      newNodes[j] = newVNo;
    }
    return newNodes;
  }

  void cloneFace (int f, HashMap<Integer, Integer> vertexMap) {
    if (f < 0 || f >= allFaces.nodes.length) return;
    int[] newNodes = cloneNodes(allFaces.nodes[f], vertexMap);
    current_Material = allFaces.getMaterial(f);
    current_Tessellation = allFaces.getTessellation(f);
    current_Layer = allFaces.getLayer(f);
    current_Visibility = allFaces.getVisibility(f);
    allFaces.create(newNodes);
  }

  void clonePolyline (int f, HashMap<Integer, Integer> vertexMap) {
    if (f < 0 || f >= allPolylines.nodes.length) return;
    int[] newNodes = cloneNodes(allPolylines.nodes[f], vertexMap);
    current_Material = allPolylines.getMaterial(f);
    current_Tessellation = allPolylines.getTessellation(f);
    current_Layer = allPolylines.getLayer(f);
    current_Visibility = allPolylines.getVisibility(f);
    current_Weight = allPolylines.getWeight(f);
    current_Closed = allPolylines.getClose(f);
    allPolylines.create(newNodes);
  }

  // randomizeRotationAndSeed matches the extra rot/seed randomization that
  // only happened inside the original Groups() clone of Model1Ds.
  void cloneModel1D (int OBJ_ID, boolean produce_same_variation, boolean randomizeRotationAndSeed) {
    float x = allModel1Ds.getX(OBJ_ID);
    float y = allModel1Ds.getY(OBJ_ID);
    float z = allModel1Ds.getZ(OBJ_ID);
    float d = allModel1Ds.getScale(OBJ_ID);
    float rot = allModel1Ds.getRotation(OBJ_ID);
    float tilt = allModel1Ds.getBranchTilt(OBJ_ID);
    float twist = allModel1Ds.getBranchTwist(OBJ_ID);
    float ratio = allModel1Ds.getBranchRatio(OBJ_ID);
    float base = allModel1Ds.getTreeBase(OBJ_ID);
    int n = allModel1Ds.getType(OBJ_ID);
    int dMax = allModel1Ds.getDegreeMax(OBJ_ID);
    int seed = allModel1Ds.getSeed(OBJ_ID);
    float trunkSize = allModel1Ds.getTrunkSize(OBJ_ID);
    float leafSize = allModel1Ds.getLeafSize(OBJ_ID);

    if (!produce_same_variation) {
      randomSeed(millis());
      if (randomizeRotationAndSeed) {
        rot = floor(random(360));
        seed = int(random(32767));
      }
    }

    allModel1Ds.create(n, seed, dMax, x, y, z, d, rot, tilt, twist, ratio, base, trunkSize, leafSize);
  }

  void cloneModel2D (int OBJ_ID, boolean produce_same_variation) {
    float x = allModel2Ds.getX(OBJ_ID);
    float y = allModel2Ds.getY(OBJ_ID);
    float z = allModel2Ds.getZ(OBJ_ID);
    float s = allModel2Ds.getS(OBJ_ID);
    int n = allModel2Ds.MAP[OBJ_ID];
    String family = allModel2Ds.isTree(n) ? "TREES" : "PEOPLE";
    if (!produce_same_variation) n = 0; // 0 means "pick a random variant"
    allModel2Ds.create(family, n, x, y, z, s);
  }

  void cloneSolid (int OBJ_ID) {
    float posX = allSolids.get_posX(OBJ_ID);
    float posY = allSolids.get_posY(OBJ_ID);
    float posZ = allSolids.get_posZ(OBJ_ID);
    float powX = allSolids.get_powX(OBJ_ID);
    float powY = allSolids.get_powY(OBJ_ID);
    float powZ = allSolids.get_powZ(OBJ_ID);
    float scaleX = allSolids.get_scaleX(OBJ_ID);
    float scaleY = allSolids.get_scaleY(OBJ_ID);
    float scaleZ = allSolids.get_scaleZ(OBJ_ID);
    float rotX = allSolids.get_rotX(OBJ_ID);
    float rotY = allSolids.get_rotY(OBJ_ID);
    float rotZ = allSolids.get_rotZ(OBJ_ID);
    float value = allSolids.get_value(OBJ_ID);
    allSolids.create(posX, posY, posZ, powX, powY, powZ, scaleX, scaleY, scaleZ, rotX, rotY, rotZ, value);
  }


  void Model1Ds (boolean produce_same_variation) {
    int numberBefore = allModel1Ds.num;

    for (int o = 0; o < Select3D.model1DSelection.length; o++) {
      cloneModel1D(Select3D.model1DSelection[o], produce_same_variation, false);
    }

    Select3D.deselect_Model1Ds();
    Select3D.model1DSelection = appendRange(Select3D.model1DSelection, numberBefore, allModel1Ds.num);
    selection_changed();
  }

  void Model2Ds (boolean produce_same_variation) {
    int numberBefore = allModel2Ds.num;

    for (int o = 0; o < Select3D.model2DSelection.length; o++) {
      cloneModel2D(Select3D.model2DSelection[o], produce_same_variation);
    }

    Select3D.deselect_Model2Ds();
    Select3D.model2DSelection = appendRange(Select3D.model2DSelection, numberBefore, allModel2Ds.num);
    selection_changed();
  }

  void Faces (boolean produce_same_variation) {
    int numberBefore = allFaces.nodes.length;

    for (int o = 0; o < Select3D.faceSelection.length; o++) {
      // Fresh map per source face, matching the original per-face dedupe scope.
      HashMap<Integer, Integer> vertexMap = new HashMap<Integer, Integer>();
      cloneFace(Select3D.faceSelection[o], vertexMap);
    }

    Select3D.faceSelection = appendRange(new int[0], numberBefore, allFaces.nodes.length);
    selection_changed();
  }

  void Polylines (boolean produce_same_variation) {
    int numberBefore = allPolylines.nodes.length;

    for (int o = 0; o < Select3D.polylineSelection.length; o++) {
      HashMap<Integer, Integer> vertexMap = new HashMap<Integer, Integer>();
      clonePolyline(Select3D.polylineSelection[o], vertexMap);
    }

    Select3D.polylineSelection = appendRange(new int[0], numberBefore, allPolylines.nodes.length);
    selection_changed();
  }

  void Solids (boolean produce_same_variation) {
    int numberBefore = allSolids.DEF.length;

    for (int o = 0; o < Select3D.solidSelection.length; o++) {
      cloneSolid(Select3D.solidSelection[o]);
    }

    Select3D.deselect_Solids();
    Select3D.solidSelection = appendRange(Select3D.solidSelection, numberBefore, allSolids.DEF.length);
    selection_changed();
  }

  void Sections (boolean produce_same_variation) {
    int numberBefore = allSections.num;

    for (int o = 0; o < Select3D.sectionSelection.length; o++) {
      int OBJ_ID = Select3D.sectionSelection[o];
      allSections.create(
        allSections.getX(OBJ_ID), allSections.getY(OBJ_ID), allSections.getZ(OBJ_ID),
        allSections.getR(OBJ_ID), allSections.getU(OBJ_ID), allSections.getV(OBJ_ID),
        allSections.get_type(OBJ_ID), allSections.get_res1(OBJ_ID), allSections.get_res2(OBJ_ID)
      );
    }

    Select3D.deselect_Sections();
    Select3D.sectionSelection = appendRange(Select3D.sectionSelection, numberBefore, allSections.num);
    selection_changed();
  }

  void Cameras (boolean produce_same_variation) {
    int numberBefore = allCameras.num;

    for (int o = 0; o < Select3D.cameraSelection.length; o++) {
      int OBJ_ID = Select3D.cameraSelection[o];
      allCameras.create(
        allCameras.get_posX(OBJ_ID), allCameras.get_posY(OBJ_ID), allCameras.get_posZ(OBJ_ID), allCameras.get_posT(OBJ_ID),
        allCameras.get_rotX(OBJ_ID), allCameras.get_rotY(OBJ_ID), allCameras.get_rotZ(OBJ_ID), allCameras.get_rotT(OBJ_ID),
        allCameras.get_zoom(OBJ_ID), allCameras.get_type(OBJ_ID)
      );
    }

    Select3D.deselect_Cameras();
    Select3D.cameraSelection = appendRange(Select3D.cameraSelection, numberBefore, allCameras.num);
    selection_changed();
  }

  void Groups (boolean produce_same_variation) {
    int SOLID_added = 0;
    int numberOfGroupsBefore = allGroups.num;

    for (int o = 0; o < Select3D.groupSelection.length; o++) {
      int OBJ_ID = Select3D.groupSelection[o];

      boolean hasFaces = (0 <= allGroups.getStart_Face(OBJ_ID)) && (allGroups.getStart_Face(OBJ_ID) <= allGroups.getStop_Face(OBJ_ID));
      boolean hasPolylines = (0 <= allGroups.getStart_Polyline(OBJ_ID)) && (allGroups.getStart_Polyline(OBJ_ID) <= allGroups.getStop_Polyline(OBJ_ID));

      if (!hasFaces && !hasPolylines) continue;

      allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
      int new_OBJ_ID = allGroups.num - 1;
      for (int j = 0; j < allGroups.Pivots[OBJ_ID].length; j++) {
        allGroups.Pivots[new_OBJ_ID][j] = allGroups.Pivots[OBJ_ID][j];
      }

      if ((0 <= allGroups.getStop_Model1D(OBJ_ID)) && (allGroups.getStart_Model1D(OBJ_ID) <= allGroups.getStop_Model1D(OBJ_ID))) {
        for (int q = allGroups.getStart_Model1D(OBJ_ID); q <= allGroups.getStop_Model1D(OBJ_ID); q++) {
          cloneModel1D(q, produce_same_variation, true);
        }
      }

      if ((0 <= allGroups.getStop_Model2D(OBJ_ID)) && (allGroups.getStart_Model2D(OBJ_ID) <= allGroups.getStop_Model2D(OBJ_ID))) {
        for (int q = allGroups.getStart_Model2D(OBJ_ID); q <= allGroups.getStop_Model2D(OBJ_ID); q++) {
          cloneModel2D(q, produce_same_variation);
        }
      }

      if ((0 <= allGroups.getStop_Solid(OBJ_ID)) && (allGroups.getStart_Solid(OBJ_ID) <= allGroups.getStop_Solid(OBJ_ID))) {
        for (int q = allGroups.getStart_Solid(OBJ_ID); q <= allGroups.getStop_Solid(OBJ_ID); q++) {
          cloneSolid(q);
          SOLID_added += 1;
        }
      }

      if (hasFaces) {
        HashMap<Integer, Integer> vertexMap = new HashMap<Integer, Integer>();
        for (int f = allGroups.getStart_Face(OBJ_ID); f <= allGroups.getStop_Face(OBJ_ID); f++) {
          cloneFace(f, vertexMap);
        }
      }

      if (hasPolylines) {
        HashMap<Integer, Integer> vertexMap = new HashMap<Integer, Integer>();
        for (int f = allGroups.getStart_Polyline(OBJ_ID); f <= allGroups.getStop_Polyline(OBJ_ID); f++) {
          clonePolyline(f, vertexMap);
        }
      }
    }

    Select3D.deselect_Groups();
    Select3D.groupSelection = appendRange(Select3D.groupSelection, numberOfGroupsBefore, allGroups.num);

    if (SOLID_added != 0) allSolidImpacts.calculate_Impact_selectedSections();
    selection_changed();
  }
}
