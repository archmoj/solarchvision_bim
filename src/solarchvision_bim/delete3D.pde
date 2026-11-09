class Delete3D {

  final static String CLASS_STAMP = "delete3D";

  float[][] removeIndices(float[][] arr, int[] ids) {
    if (ids.length == 0) return arr;
    boolean[] remove = new boolean[arr.length];
    int removedCount = 0;
    for (int id : ids) {
      if (id >= 0 && id < arr.length && !remove[id]) {
        remove[id] = true;
        removedCount++;
      }
    }
    if (removedCount == 0) return arr;
    float[][] result = new float[arr.length - removedCount][];
    int k = 0;
    for (int i = 0; i < arr.length; i++) {
      if (!remove[i]) result[k++] = arr[i];
    }
    return result;
  }

  int[][] removeIndices(int[][] arr, int[] ids) {
    if (ids.length == 0) return arr;
    boolean[] remove = new boolean[arr.length];
    int removedCount = 0;
    for (int id : ids) {
      if (id >= 0 && id < arr.length && !remove[id]) {
        remove[id] = true;
        removedCount++;
      }
    }
    if (removedCount == 0) return arr;
    int[][] result = new int[arr.length - removedCount][];
    int k = 0;
    for (int i = 0; i < arr.length; i++) {
      if (!remove[i]) result[k++] = arr[i];
    }
    return result;
  }

  int[] removeIndices(int[] arr, int[] ids) {
    if (ids.length == 0) return arr;
    boolean[] remove = new boolean[arr.length];
    int removedCount = 0;
    for (int id : ids) {
      if (id >= 0 && id < arr.length && !remove[id]) {
        remove[id] = true;
        removedCount++;
      }
    }
    if (removedCount == 0) return arr;
    int[] result = new int[arr.length - removedCount];
    int k = 0;
    for (int i = 0; i < arr.length; i++) {
      if (!remove[i]) result[k++] = arr[i];
    }
    return result;
  }

  PImage[] removeIndices(PImage[] arr, int[] ids) {
    if (ids.length == 0) return arr;
    boolean[] remove = new boolean[arr.length];
    int removedCount = 0;
    for (int id : ids) {
      if (id >= 0 && id < arr.length && !remove[id]) {
        remove[id] = true;
        removedCount++;
      }
    }
    if (removedCount == 0) return arr;
    PImage[] result = new PImage[arr.length - removedCount];
    int k = 0;
    for (int i = 0; i < arr.length; i++) {
      if (!remove[i]) result[k++] = arr[i];
    }
    return result;
  }

  PImage[][][] removeIndices(PImage[][][] arr, int[] ids) {
    if (ids.length == 0) return arr;
    boolean[] remove = new boolean[arr.length];
    int removedCount = 0;
    for (int id : ids) {
      if (id >= 0 && id < arr.length && !remove[id]) {
        remove[id] = true;
        removedCount++;
      }
    }
    if (removedCount == 0) return arr;
    PImage[][][] result = new PImage[arr.length - removedCount][][];
    int k = 0;
    for (int i = 0; i < arr.length; i++) {
      if (!remove[i]) result[k++] = arr[i];
    }
    return result;
  }

  // Added for Model2Ds' per-instance identity arrays (Kind[]/Mirror[] -
  // FileIndex[] already works via the existing int[] overload above).
  Model2DKind[] removeIndices(Model2DKind[] arr, int[] ids) {
    if (ids.length == 0) return arr;
    boolean[] remove = new boolean[arr.length];
    int removedCount = 0;
    for (int id : ids) {
      if (id >= 0 && id < arr.length && !remove[id]) {
        remove[id] = true;
        removedCount++;
      }
    }
    if (removedCount == 0) return arr;
    Model2DKind[] result = new Model2DKind[arr.length - removedCount];
    int k = 0;
    for (int i = 0; i < arr.length; i++) {
      if (!remove[i]) result[k++] = arr[i];
    }
    return result;
  }

  boolean[] removeIndices(boolean[] arr, int[] ids) {
    if (ids.length == 0) return arr;
    boolean[] remove = new boolean[arr.length];
    int removedCount = 0;
    for (int id : ids) {
      if (id >= 0 && id < arr.length && !remove[id]) {
        remove[id] = true;
        removedCount++;
      }
    }
    if (removedCount == 0) return arr;
    boolean[] result = new boolean[arr.length - removedCount];
    int k = 0;
    for (int i = 0; i < arr.length; i++) {
      if (!remove[i]) result[k++] = arr[i];
    }
    return result;
  }

  // This composite didn't call model_changed() itself before - only its
  // several sub-methods below did, independently - which is exactly why
  // it needs its OWN beginScene3DChange()/endScene3DChange() pair now, not
  // just a rename: without this wrapping, each sub-method called below
  // would still start and finish its own undo step (e.g. FACE category
  // runs BOTH faceSelection() and isolatedVertices_Selection(), which
  // used to mean two steps for what's one "Delete" to the person using
  // the app - see beginScene3DChange()'s own comment on nesting). With it,
  // every sub-method's own begin/end pair runs nested (scene3DChangeDepth
  // already > 0 by the time they're reached) and correctly becomes a
  // no-op as far as the undo history is concerned - only this outer
  // pair's own 0->1/1->0 transition actually records anything.
  void selection () {
    beginScene3DChange();

    if (currentObjectCategory == ObjectCategory.TERRAIN) {
    }
    if (currentObjectCategory == ObjectCategory.CAMERA) {
      Delete3D.cameraSelection();
    }
    if (currentObjectCategory == ObjectCategory.SECTION) {
      Delete3D.sectionSelection();
    }
    if (currentObjectCategory == ObjectCategory.MODEL1D) {
      Delete3D.model1DSelection();
    }
    if (currentObjectCategory == ObjectCategory.MODEL2D) {
      Delete3D.model2DSelection();
    }
    if (currentObjectCategory == ObjectCategory.SOLID) {
      Delete3D.solidSelection();
    }
    if (currentObjectCategory == ObjectCategory.FACE) {
      Delete3D.faceSelection();
    }
    if (currentObjectCategory == ObjectCategory.POLYLINE) {
      Delete3D.polylineSelection();
    }
    if (currentObjectCategory == ObjectCategory.GROUP) {
      Delete3D.groupSelection();
    }
    if ((currentObjectCategory == ObjectCategory.VERTEX) ||
        (currentObjectCategory == ObjectCategory.FACE) ||
        (currentObjectCategory == ObjectCategory.POLYLINE) ||
        (currentObjectCategory == ObjectCategory.GROUP)) {
      Delete3D.isolatedVertices_Selection();
    }

    Select3D.deselectAll(); // important to deselect

    endScene3DChange();
  }

  void cameraSelection () {
    int[] ids = sort(Select3D.cameraSelection);
    if (ids.length == 0) return; // nothing to delete - no edit, so no beginScene3DChange()/endScene3DChange() pair either

    beginScene3DChange();

    boolean currentCameraIndexDeleted = false;
    int shiftBefore = 0;
    for (int o = 0; o < ids.length; o++) {
      if (ids[o] == WIN3D.currentCameraIndex) currentCameraIndexDeleted = true;
      if (ids[o] < WIN3D.currentCameraIndex) shiftBefore++;
    }

    if (currentCameraIndexDeleted) {
      WIN3D.currentCameraIndex = 0;
      modify_Viewport_Title();
    } else if (shiftBefore > 0) {
      WIN3D.currentCameraIndex -= shiftBefore;
    }

    allCameras.options = removeIndices(allCameras.options, ids);
    allCameras.Type = removeIndices(allCameras.Type, ids);
    allCameras.num -= ids.length;

    if (allCameras.num == 0) {
      allCameras.add_first();
    }
    endScene3DChange();
  }

  void sectionSelection () {
    int[] ids = sort(Select3D.sectionSelection);
    if (ids.length == 0) return;

    beginScene3DChange();

    allSections.f_data = removeIndices(allSections.f_data, ids);
    allSections.i_data = removeIndices(allSections.i_data, ids);
    allSections.SolidImpact = removeIndices(allSections.SolidImpact, ids);
    allSections.SolarImpact = removeIndices(allSections.SolarImpact, ids);
    allSections.num -= ids.length;

    endScene3DChange();
  }

  void model1DSelection () {
    int[] ids = sort(Select3D.model1DSelection);
    if (ids.length == 0) return;

    beginScene3DChange();

    for (int o = ids.length - 1; o >= 0; o--) {
      int OBJ_ID = ids[o];
      for (int q = 0; q < allGroups.num; q++) {
        if ((allGroups.Model1Ds[q][0] <= OBJ_ID) && (OBJ_ID <= allGroups.Model1Ds[q][1])) {
          if (allGroups.Model1Ds[q][1] >= 0) allGroups.Model1Ds[q][1] -= 1;
        } else if (allGroups.Model1Ds[q][0] > OBJ_ID) {
          if (allGroups.Model1Ds[q][0] >= 0) allGroups.Model1Ds[q][0] -= 1;
          if (allGroups.Model1Ds[q][1] >= 0) allGroups.Model1Ds[q][1] -= 1;
        }
      }
    }

    allModel1Ds.f_data = removeIndices(allModel1Ds.f_data, ids);
    allModel1Ds.i_data = removeIndices(allModel1Ds.i_data, ids);
    allModel1Ds.num -= ids.length;

    endScene3DChange();
  }

  void model2DSelection () {
    int[] ids = sort(Select3D.model2DSelection);
    if (ids.length == 0) return;

    beginScene3DChange();

    for (int o = ids.length - 1; o >= 0; o--) {
      int OBJ_ID = ids[o];
      for (int q = 0; q < allGroups.num; q++) {
        if ((allGroups.Model2Ds[q][0] <= OBJ_ID) && (OBJ_ID <= allGroups.Model2Ds[q][1])) {
          if (allGroups.Model2Ds[q][1] >= 0) allGroups.Model2Ds[q][1] -= 1;
        } else if (allGroups.Model2Ds[q][0] > OBJ_ID) {
          if (allGroups.Model2Ds[q][0] >= 0) allGroups.Model2Ds[q][0] -= 1;
          if (allGroups.Model2Ds[q][1] >= 0) allGroups.Model2Ds[q][1] -= 1;
        }
      }
    }

    allModel2Ds.XYZS = removeIndices(allModel2Ds.XYZS, ids);
    allModel2Ds.Kind = removeIndices(allModel2Ds.Kind, ids);
    allModel2Ds.FileIndex = removeIndices(allModel2Ds.FileIndex, ids);
    allModel2Ds.Mirror = removeIndices(allModel2Ds.Mirror, ids);
    allModel2Ds.num -= ids.length;

    endScene3DChange();
  }

  void solidSelection () {
    int[] ids = sort(Select3D.solidSelection);
    if (ids.length == 0) return;

    beginScene3DChange();

    for (int o = ids.length - 1; o >= 0; o--) {
      int OBJ_ID = ids[o];
      for (int q = 0; q < allGroups.num; q++) {
        if ((allGroups.Solids[q][0] <= OBJ_ID) && (OBJ_ID <= allGroups.Solids[q][1])) {
          if (allGroups.Solids[q][1] >= 0) allGroups.Solids[q][1] -= 1;
        } else if (allGroups.Solids[q][0] > OBJ_ID) {
          if (allGroups.Solids[q][0] >= 0) allGroups.Solids[q][0] -= 1;
          if (allGroups.Solids[q][1] >= 0) allGroups.Solids[q][1] -= 1;
        }
      }
    }

    allSolids.DEF = removeIndices(allSolids.DEF, ids);

    endScene3DChange();
  }

  void faceSelection () {
    Select3D.convert_Faces_to_Vertices();

    int[] ids = sort(Select3D.faceSelection);
    if (ids.length == 0) return;

    beginScene3DChange();

    for (int o = ids.length - 1; o >= 0; o--) {
      int OBJ_ID = ids[o];
      for (int q = 0; q < allGroups.num; q++) {
        if ((allGroups.Faces[q][0] <= OBJ_ID) && (OBJ_ID <= allGroups.Faces[q][1])) {
          if (allGroups.Faces[q][1] >= 0) allGroups.Faces[q][1] -= 1;
        } else if (allGroups.Faces[q][0] > OBJ_ID) {
          if (allGroups.Faces[q][0] >= 0) allGroups.Faces[q][0] -= 1;
          if (allGroups.Faces[q][1] >= 0) allGroups.Faces[q][1] -= 1;
        }
      }
    }

    allFaces.nodes = removeIndices(allFaces.nodes, ids);
    allFaces.options = removeIndices(allFaces.options, ids);

    endScene3DChange();
  }

  void polylineSelection () {
    Select3D.convert_Polylines_to_Vertices();

    int[] ids = sort(Select3D.polylineSelection);
    if (ids.length == 0) return;

    beginScene3DChange();

    for (int o = ids.length - 1; o >= 0; o--) {
      int OBJ_ID = ids[o];
      for (int q = 0; q < allGroups.num; q++) {
        if ((allGroups.Polylines[q][0] <= OBJ_ID) && (OBJ_ID <= allGroups.Polylines[q][1])) {
          if (allGroups.Polylines[q][1] >= 0) allGroups.Polylines[q][1] -= 1;
        } else if (allGroups.Polylines[q][0] > OBJ_ID) {
          if (allGroups.Polylines[q][0] >= 0) allGroups.Polylines[q][0] -= 1;
          if (allGroups.Polylines[q][1] >= 0) allGroups.Polylines[q][1] -= 1;
        }
      }
    }

    allPolylines.nodes = removeIndices(allPolylines.nodes, ids);
    allPolylines.options = removeIndices(allPolylines.options, ids);

    endScene3DChange();
  }

  // Unlike its siblings above, the "nothing selected" early return here
  // still calls what's now endScene3DChange() (see that branch below) -
  // so beginScene3DChange() has to cover that path too, not just the
  // normal one, and goes at the true top rather than after the guard.
  void groupSelection () {
    beginScene3DChange();

    /////////////////////////////
    //holdProject();
    /////////////////////////////
    Select3D.convert_Groups_to_Vertices();

    int[] ids = sort(Select3D.groupSelection);
    if (ids.length == 0) {
      endScene3DChange();
      return;
    }

    boolean allSolids_updated = false;
    for (int o = ids.length - 1; o >= 0; o--) {
      int OBJ_ID = ids[o];

      int startFace = allGroups.getStart_Face(OBJ_ID);
      int endFace = allGroups.getStop_Face(OBJ_ID);
      if ((0 <= startFace) && (startFace <= endFace)) {
        for (int i = OBJ_ID + 1; i < allGroups.num; i++) {
          for (int j = 0; j < 2; j++) {
            allGroups.Faces[i][j] -= 1 + endFace - startFace;
          }
        }
        int[][] startList = (int[][]) subset(allFaces.nodes, 0, startFace);
        int[][] endList = (int[][]) subset(allFaces.nodes, endFace + 1);
        allFaces.nodes = (int[][]) concat(startList, endList);

        int[][] startListO = (int[][]) subset(allFaces.options, 0, startFace);
        int[][] endListO = (int[][]) subset(allFaces.options, endFace + 1);
        allFaces.options = (int[][]) concat(startListO, endListO);
      }

      int startPolyline = allGroups.getStart_Polyline(OBJ_ID);
      int endPolyline = allGroups.getStop_Polyline(OBJ_ID);
      if ((0 <= startPolyline) && (startPolyline <= endPolyline)) {
        for (int i = OBJ_ID + 1; i < allGroups.num; i++) {
          for (int j = 0; j < 2; j++) {
            allGroups.Polylines[i][j] -= 1 + endPolyline - startPolyline;
          }
        }
        int[][] startList = (int[][]) subset(allPolylines.nodes, 0, startPolyline);
        int[][] endList = (int[][]) subset(allPolylines.nodes, endPolyline + 1);
        allPolylines.nodes = (int[][]) concat(startList, endList);

        int[][] startListO = (int[][]) subset(allPolylines.options, 0, startPolyline);
        int[][] endListO = (int[][]) subset(allPolylines.options, endPolyline + 1);
        allPolylines.options = (int[][]) concat(startListO, endListO);
      }

      int startModel1Ds = allGroups.getStart_Model1D(OBJ_ID);
      int endModel1Ds = allGroups.getStop_Model1D(OBJ_ID);
      if ((0 <= startModel1Ds) && (startModel1Ds <= endModel1Ds)) {
        for (int i = OBJ_ID + 1; i < allGroups.num; i++) {
          for (int j = 0; j < 2; j++) {
            allGroups.Model1Ds[i][j] -= 1 + endModel1Ds - startModel1Ds;
          }
        }
        float[][] startListF = (float[][]) subset(allModel1Ds.f_data, 0, startModel1Ds);
        float[][] endListF = (float[][]) subset(allModel1Ds.f_data, endModel1Ds + 1);
        allModel1Ds.f_data = (float[][]) concat(startListF, endListF);

        int[][] startListI = (int[][]) subset(allModel1Ds.i_data, 0, startModel1Ds);
        int[][] endListI = (int[][]) subset(allModel1Ds.i_data, endModel1Ds + 1);
        allModel1Ds.i_data = (int[][]) concat(startListI, endListI);

        allModel1Ds.num = allModel1Ds.f_data.length;
      }

      int startModel2Ds = allGroups.getStart_Model2D(OBJ_ID);
      int endModel2Ds = allGroups.getStop_Model2D(OBJ_ID);
      if ((0 <= startModel2Ds) && (startModel2Ds <= endModel2Ds)) {
        for (int i = OBJ_ID + 1; i < allGroups.num; i++) {
          for (int j = 0; j < 2; j++) {
            allGroups.Model2Ds[i][j] -= 1 + endModel2Ds - startModel2Ds;
          }
        }
        float[][] startListF = (float[][]) subset(allModel2Ds.XYZS, 0, startModel2Ds);
        float[][] endListF = (float[][]) subset(allModel2Ds.XYZS, endModel2Ds + 1);
        allModel2Ds.XYZS = (float[][]) concat(startListF, endListF);

        Model2DKind[] startListK = (Model2DKind[]) subset(allModel2Ds.Kind, 0, startModel2Ds);
        Model2DKind[] endListK = (Model2DKind[]) subset(allModel2Ds.Kind, endModel2Ds + 1);
        allModel2Ds.Kind = (Model2DKind[]) concat(startListK, endListK);

        int[] startListFi = (int[]) subset(allModel2Ds.FileIndex, 0, startModel2Ds);
        int[] endListFi = (int[]) subset(allModel2Ds.FileIndex, endModel2Ds + 1);
        allModel2Ds.FileIndex = (int[]) concat(startListFi, endListFi);

        boolean[] startListMi = (boolean[]) subset(allModel2Ds.Mirror, 0, startModel2Ds);
        boolean[] endListMi = (boolean[]) subset(allModel2Ds.Mirror, endModel2Ds + 1);
        allModel2Ds.Mirror = (boolean[]) concat(startListMi, endListMi);

        allModel2Ds.num = allModel2Ds.XYZS.length;
      }

      int startSolid = allGroups.getStart_Solid(OBJ_ID);
      int endSolid = allGroups.getStop_Solid(OBJ_ID);
      if ((0 <= startSolid) && (startSolid <= endSolid)) {
        for (int i = OBJ_ID + 1; i < allGroups.num; i++) {
          for (int j = 0; j < 2; j++) {
            allGroups.Solids[i][j] -= 1 + endSolid - startSolid;
          }
        }
      }
      if ((0 <= startSolid) && (startSolid <= endSolid)) {
        float[][] startListF = (float[][]) subset(allSolids.DEF, 0, startSolid);
        float[][] endListF = (float[][]) subset(allSolids.DEF, endSolid + 1);
        allSolids.DEF = (float[][]) concat(startListF, endListF);
        allSolids_updated = true;
      }
    }

    allGroups.Faces = removeIndices(allGroups.Faces, ids);
    allGroups.Polylines = removeIndices(allGroups.Polylines, ids);
    allGroups.Model1Ds = removeIndices(allGroups.Model1Ds, ids);
    allGroups.Model2Ds = removeIndices(allGroups.Model2Ds, ids);
    allGroups.Solids = removeIndices(allGroups.Solids, ids);
    allGroups.Pivots = removeIndices(allGroups.Pivots, ids);
    allGroups.num -= ids.length;

    if (allSolids_updated) allSolidImpacts.calculate_ImpactOnSections();
    endScene3DChange();
  }

  // Same reasoning as groupSelection()'s own comment above: the n==0
  // early return still calls what's now endScene3DChange(), so
  // beginScene3DChange() goes at the true top.
  void isolatedVertices_Selection () {
    beginScene3DChange();

    int[] ids = sort(Select3D.vertexSelection);
    int n = ids.length;

    if (n == 0) {
      Select3D.deselect_Vertices();
      endScene3DChange();
      return;
    }

    boolean[] used = new boolean[allVertices.length];
    for (int i = 0; i < allFaces.nodes.length; i++) {
      for (int j = 0; j < allFaces.nodes[i].length; j++) {
        used[allFaces.nodes[i][j]] = true;
      }
    }
    for (int i = 0; i < allPolylines.nodes.length; i++) {
      for (int j = 0; j < allPolylines.nodes[i].length; j++) {
        used[allPolylines.nodes[i][j]] = true;
      }
    }

    int m = 0;
    int[] toRemove = new int[n];
    for (int idx = 0; idx < n; idx++) {
      if (!used[ids[idx]]) toRemove[m++] = ids[idx];
    }
    toRemove = (int[]) subset(toRemove, 0, m);

    if (m > 0) {
      int[] shift = new int[allVertices.length];
      int removedSoFar = 0, rPtr = 0;
      for (int v = 0; v < allVertices.length; v++) {
        if (rPtr < m && toRemove[rPtr] == v) {
          removedSoFar++;
          rPtr++;
        }
        shift[v] = removedSoFar;
      }

      for (int i = 0; i < allFaces.nodes.length; i++) {
        for (int j = 0; j < allFaces.nodes[i].length; j++) {
          allFaces.nodes[i][j] -= shift[allFaces.nodes[i][j]];
        }
      }
      for (int i = 0; i < allPolylines.nodes.length; i++) {
        for (int j = 0; j < allPolylines.nodes[i].length; j++) {
          allPolylines.nodes[i][j] -= shift[allPolylines.nodes[i][j]];
        }
      }

      allVertices = removeIndices(allVertices, toRemove);
    }

    Select3D.deselect_Vertices();
    endScene3DChange();
  }

  void isolatedVertices_Scene () {
    beginScene3DChange();

    int len = allVertices.length;

    boolean[] used = new boolean[len];
    for (int i = 0; i < allFaces.nodes.length; i++) {
      for (int j = 0; j < allFaces.nodes[i].length; j++) {
        used[allFaces.nodes[i][j]] = true;
      }
    }
    for (int i = 0; i < allPolylines.nodes.length; i++) {
      for (int j = 0; j < allPolylines.nodes[i].length; j++) {
        used[allPolylines.nodes[i][j]] = true;
      }
    }

    int m = 0;
    int[] toRemove = new int[len];
    for (int v = 0; v < len; v++) {
      if (!used[v]) toRemove[m++] = v;
    }
    toRemove = (int[]) subset(toRemove, 0, m);

    if (m > 0) {
      int[] shift = new int[len];
      int removedSoFar = 0, rPtr = 0;
      for (int v = 0; v < len; v++) {
        if (rPtr < m && toRemove[rPtr] == v) {
          removedSoFar++;
          rPtr++;
        }
        shift[v] = removedSoFar;
      }

      for (int i = 0; i < allFaces.nodes.length; i++) {
        for (int j = 0; j < allFaces.nodes[i].length; j++) {
          allFaces.nodes[i][j] -= shift[allFaces.nodes[i][j]];
        }
      }
      for (int i = 0; i < allPolylines.nodes.length; i++) {
        for (int j = 0; j < allPolylines.nodes[i].length; j++) {
          allPolylines.nodes[i][j] -= shift[allPolylines.nodes[i][j]];
        }
      }

      allVertices = removeIndices(allVertices, toRemove);
    }

    Select3D.deselect_Vertices();
    endScene3DChange();
  }
}
