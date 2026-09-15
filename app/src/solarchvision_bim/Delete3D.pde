class solarchvision_Delete3D {

  private final static String CLASS_STAMP = "Delete3D";

  private float[][] removeIndices(float[][] arr, int[] ids) {
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

  private int[][] removeIndices(int[][] arr, int[] ids) {
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

  private int[] removeIndices(int[] arr, int[] ids) {
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

  private PImage[] removeIndices(PImage[] arr, int[] ids) {
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

  private PImage[][][] removeIndices(PImage[][][] arr, int[] ids) {
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

  void selection () {

    if (current_ObjectCategory == ObjectCategory.LANDPOINT) {
    }
    if (current_ObjectCategory == ObjectCategory.CAMERA) {
      Delete3D.selected_Cameras();
    }
    if (current_ObjectCategory == ObjectCategory.SECTION) {
      Delete3D.selected_Sections();
    }
    if (current_ObjectCategory == ObjectCategory.MODEL1D) {
      Delete3D.selected_Model1Ds();
    }
    if (current_ObjectCategory == ObjectCategory.MODEL2D) {
      Delete3D.selected_Model2Ds();
    }
    if (current_ObjectCategory == ObjectCategory.SOLID) {
      Delete3D.selected_Solids();
    }
    if (current_ObjectCategory == ObjectCategory.FACE) {
      Delete3D.selected_Faces();
    }
    if (current_ObjectCategory == ObjectCategory.POLYLINE) {
      Delete3D.selected_Polylines();
    }
    if (current_ObjectCategory == ObjectCategory.GROUP) {
      Delete3D.selected_Groups();
    }
    if ((current_ObjectCategory == ObjectCategory.VERTEX) ||
        (current_ObjectCategory == ObjectCategory.FACE) ||
        (current_ObjectCategory == ObjectCategory.POLYLINE) ||
        (current_ObjectCategory == ObjectCategory.GROUP)) {
      Delete3D.isolatedVertices_Selection();
    }

    Select3D.deselectAll(); // important to deselect
  }

  void selected_Cameras () {
    int[] ids = sort(Select3D.Camera_ids);
    if (ids.length == 0) return;

    boolean currentCameraDeleted = false;
    int shiftBefore = 0;
    for (int o = 0; o < ids.length; o++) {
      if (ids[o] == WIN3D.currentCamera) currentCameraDeleted = true;
      if (ids[o] < WIN3D.currentCamera) shiftBefore++;
    }

    if (currentCameraDeleted) {
      WIN3D.currentCamera = 0;
      SOLARCHVISION_modify_Viewport_Title();
    } else if (shiftBefore > 0) {
      WIN3D.currentCamera -= shiftBefore;
    }

    allCameras.options = removeIndices(allCameras.options, ids);
    allCameras.Type = removeIndices(allCameras.Type, ids);
    allCameras.num -= ids.length;

    if (allCameras.num == 0) {
      allCameras.add_first();
    }
    SOLARCHVISION_model_changed();
  }

  void selected_Sections () {
    int[] ids = sort(Select3D.Section_ids);
    if (ids.length == 0) return;

    allSections.f_data = removeIndices(allSections.f_data, ids);
    allSections.i_data = removeIndices(allSections.i_data, ids);
    allSections.SolidImpact = removeIndices(allSections.SolidImpact, ids);
    allSections.SolarImpact = removeIndices(allSections.SolarImpact, ids);
    allSections.num -= ids.length;

    SOLARCHVISION_model_changed();
  }

  void selected_Model1Ds () {
    int[] ids = sort(Select3D.Model1D_ids);
    if (ids.length == 0) return;

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

    SOLARCHVISION_model_changed();
  }

  void selected_Model2Ds () {
    int[] ids = sort(Select3D.Model2D_ids);
    if (ids.length == 0) return;

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
    allModel2Ds.MAP = removeIndices(allModel2Ds.MAP, ids);
    allModel2Ds.num -= ids.length;

    SOLARCHVISION_model_changed();
  }

  void selected_Solids () {
    int[] ids = sort(Select3D.Solid_ids);
    if (ids.length == 0) return;

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

    SOLARCHVISION_model_changed();
  }

  void selected_Faces () {
    Select3D.convert_Faces_to_Vertices();

    int[] ids = sort(Select3D.Face_ids);
    if (ids.length == 0) return;

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

    SOLARCHVISION_model_changed();
  }

  void selected_Polylines () {
    Select3D.convert_Polylines_to_Vertices();

    int[] ids = sort(Select3D.Polyline_ids);
    if (ids.length == 0) return;

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

    SOLARCHVISION_model_changed();
  }

  void selected_Groups () {
    /////////////////////////////
    //SOLARCHVISION_hold_project();
    /////////////////////////////
    Select3D.convert_Groups_to_Vertices();

    int[] ids = sort(Select3D.Group_ids);
    if (ids.length == 0) {
      SOLARCHVISION_model_changed();
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

        int[] startListM = (int[]) subset(allModel2Ds.MAP, 0, startModel2Ds);
        int[] endListM = (int[]) subset(allModel2Ds.MAP, endModel2Ds + 1);
        allModel2Ds.MAP = (int[]) concat(startListM, endListM);

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

    if (allSolids_updated) allSolidImpacts.calculate_Impact_selectedSections();
    SOLARCHVISION_model_changed();
  }

  void isolatedVertices_Selection () {
    int[] ids = sort(Select3D.Vertex_ids);
    int n = ids.length;

    if (n == 0) {
      Select3D.deselect_Vertices();
      SOLARCHVISION_model_changed();
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
    SOLARCHVISION_model_changed();
  }

  void isolatedVertices_Scene () {
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
    SOLARCHVISION_model_changed();
  }
}
